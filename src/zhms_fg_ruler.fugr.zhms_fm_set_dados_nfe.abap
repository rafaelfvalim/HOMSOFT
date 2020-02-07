FUNCTION zhms_fm_set_dados_nfe.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(CHAVE) TYPE  CHAR44
*"----------------------------------------------------------------------
  DATA: ls_cabdoc   TYPE zhms_tb_cabdoc,
        tl_logdoc   TYPE TABLE OF zhms_tb_logdoc,
        wl_logdoc   TYPE zhms_tb_logdoc,
        lt_docmn    TYPE STANDARD TABLE OF zhms_tb_docmn,
        lt_bnfdoc   TYPE STANDARD TABLE OF j_1bnfdoc,
        ls_bnfdoc   LIKE LINE OF lt_bnfdoc,
        lt_message  LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE,
        ls_message  LIKE LINE OF lt_message,
        ls_docmn    LIKE LINE OF lt_docmn.

  DATA: lv_docum   TYPE j_1bdocnum,
        lv_num_ale TYPE j_1bdocnum8,
        lv_di_v    TYPE j_1bcheckdigit,
        lv_prot    TYPE j_1bnfeauthcode,
        lv_data    TYPE char10,
        lv_parid   TYPE lifnr,
        lv_nfe     TYPE j_1bnfnum9,
        lv_flwst   TYPE zhms_de_flwst,
        lv_tpemis  TYPE j_1bnfe_tpemis,
        p_mode.
break rhitokaz.
*** Verifica se chave existe
  SELECT SINGLE *
    FROM zhms_tb_cabdoc
    INTO ls_cabdoc WHERE chave EQ wa_cabdoc-chave.

  CHECK sy-subrc IS INITIAL.

*** Busca Mneumonicos
  SELECT *
    FROM zhms_tb_docmn
     INTO TABLE lt_docmn
    WHERE chave EQ wa_cabdoc-chave.

  CHECK NOT lt_docmn[] IS INITIAL.

** Verifica se já foi realizado MIRO
*  CLEAR ls_docmn.
*  READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'INVDOCNO'.
*
*  IF sy-subrc IS INITIAL.

*** Seleciona CNPJ Fornecedor
  CLEAR ls_docmn.
  IF wa_cabdoc-typed = 'CTE'.
    READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'EMITCNPJ'.
  ELSEIF wa_cabdoc-typed = 'NFE'.
    READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'CNPJ'.
  ENDIF.

  IF sy-subrc IS INITIAL.

    SELECT SINGLE lifnr FROM lfa1 INTO lv_parid WHERE stcd1 EQ ls_docmn-value.

    IF sy-subrc IS INITIAL.

*** Seleciona numero da nota fiscal
      CLEAR ls_docmn.
      IF wa_cabdoc-typed = 'CTE'.
        READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'NCT'.
      ELSEIF wa_cabdoc-typed = 'NFE'.
        READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'NNF'.
      ENDIF.


      IF sy-subrc IS INITIAL.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = ls_docmn-value
          IMPORTING
            output = lv_nfe.

        IF wa_cabdoc-typed = 'NFE'.

          SELECT *
            FROM j_1bnfdoc
            INTO TABLE lt_bnfdoc
           WHERE parid  EQ lv_parid
             AND nfenum EQ lv_nfe
             AND nftype EQ '55'.

        ELSEIF wa_cabdoc-typed = 'CTE'.

          SELECT *
            FROM j_1bnfdoc
            INTO TABLE lt_bnfdoc
           WHERE parid  EQ lv_parid
             AND nfenum EQ lv_nfe
             AND nftype EQ '55'.

        ENDIF.

        IF sy-subrc IS INITIAL.

          SORT lt_bnfdoc DESCENDING BY docnum.

          READ TABLE lt_bnfdoc INTO ls_bnfdoc INDEX 1.

*** Move numero do documento
          MOVE: ls_bnfdoc-docnum TO lv_docum.

*** nusca numero aleatorio
          CLEAR ls_docmn.
          READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'TPEMIS'.

          IF sy-subrc IS INITIAL.
            MOVE ls_docmn-value TO lv_tpemis.
          ENDIF.


*** nusca numero aleatorio
          CLEAR ls_docmn.
          IF wa_cabdoc-typed = 'CTE'.
            READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'CCT'.
          ELSEIF wa_cabdoc-typed = 'NFE'.
            READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'CNF'.
          ENDIF.


          IF sy-subrc IS INITIAL.
            MOVE ls_docmn-value TO lv_num_ale.
          ENDIF.

*** nusca numero aleatorio
          CLEAR ls_docmn.
          READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'CDV'.

          IF sy-subrc IS INITIAL.
            MOVE ls_docmn-value TO lv_di_v.
          ENDIF.

*** nusca numero aleatorio
          READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'NPROT'.

          IF sy-subrc IS INITIAL.
            MOVE ls_docmn-value TO lv_prot.
          ENDIF.

*** nusca numero aleatorio
          CLEAR ls_docmn.
          READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'DHRECBTO'.

          IF sy-subrc IS INITIAL.
            CONCATENATE ls_docmn-value+8(2) '.' ls_docmn-value+5(2) '.'
ls_docmn-value(4) INTO lv_data.
          ENDIF.

*** Executa Batch input
          PERFORM f_bdc_field  USING:
          'X'   'SAPMJ1B1'                        '1100',
          ' '   'BDC_OKCODE'                      '/00',
          ' '   'J_1BDYDOC-DOCNUM'                lv_docum.

          PERFORM f_bdc_field  USING:
          'X'   'SAPLJ1BB2'                       '2000',
          ' '   'BDC_OKCODE'                      '=TAB8'.

          PERFORM f_bdc_field  USING:
          'X'   'SAPLJ1BB2'                       '2000',
          ' '   'BDC_OKCODE'                      '/00',
          ' '   'J_1BNFE_DOCNUM9_DIVIDED-DOCNUM8' lv_num_ale,
          ' '   'J_1BNFE_DOCNUM9_DIVIDED-TPEMIS'  lv_tpemis,
          ' '   'J_1BNFE_ACTIVE-CDV'              lv_di_v,
          ' '   'J_1BDYDOC-AUTHCOD'               lv_prot,
          ' '   'J_1BDYDOC-AUTHDATE'              lv_data.

          PERFORM f_bdc_field  USING:
          'X'   'SAPLJ1BB2'                       '2000',
          ' '   'BDC_OKCODE'                      '=SAVE'.

          CLEAR: lt_message[].
          p_mode = 'N'.
          CALL TRANSACTION 'J1B2N' USING lt_bdcdata MODE p_mode
                                   MESSAGES INTO lt_message.

** verifica Documento Criado
          READ TABLE lt_message INTO ls_message WITH KEY msgtyp = 'S'
                                                         msgid  = '8B'
                                                         msgnr  = '164'.

          IF sy-subrc IS INITIAL.

*** Registra LOG Sucesso
            REFRESH tl_logdoc.
            wl_logdoc-logty = 'S'.
            wl_logdoc-logno = ls_message-msgnr.
            wl_logdoc-logv1 = ls_message-msgv1.
            APPEND wl_logdoc TO tl_logdoc.

            IF wa_cabdoc-typed = 'NFE'.

              lv_flwst = 'A'.
              CALL FUNCTION 'ZHMS_FM_REGLOG'
                EXPORTING
                  cabdoc = wa_cabdoc
*                  flowd  = '50'
*O valor do campo FLOWD tem que ser o mesmo parametrizado para Atualização chave de acesso
                  flowd  = '70'
                  flwst  = lv_flwst
                TABLES
                  logdoc = tl_logdoc.

            ELSEIF wa_cabdoc-typed = 'CTE'.

              lv_flwst = 'A'.
              CALL FUNCTION 'ZHMS_FM_REGLOG'
                EXPORTING
                  cabdoc = wa_cabdoc
*O valor do campo FLOWD tem que ser o mesmo parametrizado para Atualização chave de acesso
                  flowd  = '40'
                  flwst  = lv_flwst
                TABLES
                  logdoc = tl_logdoc.
            ENDIF.

            CALL FUNCTION 'ZHMS_FM_STATUS'
              EXPORTING
                cabdoc = ls_cabdoc.

          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
*  ENDIF.


ENDFUNCTION.
