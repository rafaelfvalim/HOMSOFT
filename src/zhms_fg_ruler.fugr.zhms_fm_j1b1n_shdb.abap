FUNCTION zhms_fm_j1b1n_shdb.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(CHAVE) TYPE  CHAR44
*"----------------------------------------------------------------------
****J1B1N Via SHDB
*** Declração de tabelas
  DATA: tl_logdoc   TYPE TABLE OF zhms_tb_logdoc,
        tl_docum    TYPE TABLE OF zhms_es_docum,
        lt_docmn    TYPE STANDARD TABLE OF zhms_tb_docmn,
        lt_docmnx   TYPE STANDARD TABLE OF zhms_tb_docmn,
        lt_message  LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE,
        lt_branch   TYPE STANDARD TABLE OF bapibranch,
        lt_returnb  TYPE STANDARD TABLE OF bapiret2.

*** Declaração de workareas
  DATA: wl_logdoc   TYPE zhms_tb_logdoc,
        wl_docum    TYPE zhms_es_docum,
        ls_docmn    LIKE LINE OF lt_docmn,
        ls_docmnx   LIKE LINE OF lt_docmn,
        ls_cabdoc   TYPE zhms_tb_cabdoc,
        ls_bdcdata  LIKE LINE OF lt_bdcdata,
        ls_message  LIKE LINE OF lt_message,
        ls_mapdata  TYPE zhms_tb_mapdata,
        ls_branch   LIKE LINE OF lt_branch.

*** Declaração de variaveis
  DATA: vl_answer   TYPE c,
        lv_bukrs    TYPE bukrs,
        lv_forn     TYPE char12,
        lv_datum    TYPE char10,
        lv_datum2   TYPE char10,
        lv_cont     TYPE i,
        lv_lines    TYPE i,
        lv_item     TYPE char22,
        lv_maktx    TYPE char22,
        lv_matkl    TYPE char22,
        lv_menge    TYPE char22,
        lv_meins    TYPE char22,
        lv_netpr    TYPE char22,
        lv_cfop     TYPE char22,
        lv_taxlw1   TYPE char22,
        lv_taxlw2   TYPE char22,
        lv_matorg   TYPE char22,
        lv_matuse   TYPE char22,
        lv_nbm      TYPE char22,
        lv_branch   TYPE j_1bbranc_,
        lv_line     TYPE i,
        vl_seqnr    TYPE zhms_de_seqnr,
        lv_message  TYPE string,
        p_mode,
        lv_flwst    TYPE zhms_de_flwst,
        lv_4        TYPE char4,
        lv_2        TYPE char2.

*** limpeza
  REFRESH: tl_logdoc[],
           tl_docum[],
           lt_docmn[],
           lt_docmnx[],
           lt_message[],
           lt_branch[],
           lt_returnb[],
           lt_bdcdata[].

  CLEAR: wl_logdoc,
         wl_docum,
         ls_docmn,
         ls_docmnx,
         ls_cabdoc,
         ls_bdcdata,
         ls_message,
         ls_mapdata,
         ls_branch,
         lt_docmn,
         lt_docmnx,
         lt_bdcdata.

  CLEAR: vl_answer,
          lv_bukrs,
          lv_forn,
          lv_datum,
          lv_datum2,
          lv_cont,
          lv_lines,
          lv_item,
          lv_maktx,
          lv_matkl,
          lv_menge,
          lv_meins,
          lv_netpr,
          lv_cfop,
          lv_taxlw1,
          lv_taxlw2,
          lv_matorg,
          lv_matuse,
          lv_nbm,
          lv_branch,
          lv_line,
          vl_seqnr,
          lv_message,
          p_mode,
          lv_flwst,
          lv_4,
          lv_2.

*** Verifica se chave existe
  SELECT SINGLE *
    FROM zhms_tb_cabdoc
    INTO ls_cabdoc WHERE chave EQ chave.

  CHECK sy-subrc IS INITIAL.

*** Busca Mneumonicos
  SELECT *
    FROM zhms_tb_docmn
     INTO TABLE lt_docmn
    WHERE chave EQ chave.

  CHECK NOT lt_docmn[] IS INITIAL.
** Verifica se já foi criada J1B1N
  READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'MATDOC'.

  IF sy-subrc IS INITIAL.
    CONCATENATE 'Documento já foi criado:' ls_docmn-value
           INTO lv_message SEPARATED BY space.

    MESSAGE i000(zhmsm_clas_msg) WITH lv_message.
    EXIT.
  ENDIF.

*** Deseja Continuar ?
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = text-q01
      text_question         = text-q02
      text_button_1         = text-q03
      icon_button_1         = 'ICON_CHECKED'
      text_button_2         = text-q04
      icon_button_2         = 'ICON_INCOMPLETE'
      default_button        = '2'
      display_cancel_button = ' '
    IMPORTING
      answer                = vl_answer
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.

*** = SIM
  CHECK vl_answer EQ 1.

** Empresa
  CLEAR ls_docmn.
  READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'CNPJDEST'.

  IF sy-subrc IS INITIAL.
    SELECT SINGLE bukrs
    FROM t001z
    INTO lv_bukrs WHERE paval EQ ls_docmn-value(8).
  ENDIF.

*** Verifica ID Parceiro
  CLEAR vl_answer.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar       = text-q01
      text_question  = text-q05
      text_button_1  = text-q06
      text_button_2  = text-q07
    IMPORTING
      answer         = vl_answer
    EXCEPTIONS
      text_not_found = 1
      OTHERS         = 2.

*** Busca Mneumonico CNPJ
  CLEAR ls_docmn.
  READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'CNPJ'.

  CASE vl_answer.
    WHEN '1'.
      SELECT SINGLE lifnr
        FROM lfa1
        INTO lv_forn WHERE stcd1 EQ ls_docmn-value.
    WHEN '2'.
      SELECT SINGLE kunnr
        FROM kna1
        INTO lv_forn WHERE stcd1 EQ ls_docmn-value.
    WHEN OTHERS.
  ENDCASE.

*** Busca Local de negócios
  CALL FUNCTION 'BAPI_BRANCH_GETLIST'
    EXPORTING
      company     = lv_bukrs
    TABLES
      branch_list = lt_branch
      return      = lt_returnb.

  CLEAR ls_docmn.
  READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'CNPJDEST'.

  IF NOT lt_branch[] IS INITIAL.
    LOOP AT lt_branch INTO ls_branch.

      TRANSLATE ls_docmn-value USING '. '.
      TRANSLATE ls_docmn-value USING '- '.
      TRANSLATE ls_docmn-value USING '/ '.
      CONDENSE ls_docmn-value NO-GAPS.

      TRANSLATE ls_branch-cgc_number USING '. '.
      TRANSLATE ls_branch-cgc_number USING '- '.
      TRANSLATE ls_branch-cgc_number USING '/ '.
      CONDENSE ls_branch-cgc_number NO-GAPS.

      IF ls_branch-cgc_number EQ ls_docmn-value.
        MOVE ls_branch-branch TO lv_branch.
        EXIT.
      ENDIF.

    ENDLOOP.
  ENDIF.

*** Executa Batch input
  PERFORM f_bdc_field USING 'X'  'SAPMJ1B1'          '0900'.
  PERFORM f_bdc_field USING ' '  'BDC_OKCODE'        '/00'.
  PERFORM f_bdc_field USING ' '  'J_1BDYDOC-NFTYPE'  'ZC'.
  PERFORM f_bdc_field USING ' '  'J_1BDYDOC-BUKRS'   lv_bukrs.
  PERFORM f_bdc_field USING ' '  'J_1BDYDOC-BRANCH'  lv_branch.

*** Tipo do parceiro
  IF vl_answer EQ '1'.
    PERFORM f_bdc_field USING ' '  'J_1BDYDOC-PARVW'  'LF'.
  ELSEIF vl_answer EQ '2'.
    PERFORM f_bdc_field USING ' '  'J_1BDYDOC-PARVW'  'AG'.
  ENDIF.

  PERFORM f_bdc_field USING ' '  'J_1BDYDOC-PARID'  lv_forn.
  PERFORM f_bdc_field USING ' '  'J_1BDYLIN-INCLTX' 'X'.

*** Busca Numero NFE
  CLEAR ls_docmn.
  READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'NNF'.

  PERFORM f_bdc_field USING 'X'  'SAPLJ1BB2'         '2000'.
  PERFORM f_bdc_field USING ' '  'BDC_OKCODE'        '=ADIT'.
  PERFORM f_bdc_field USING ' '  'J_1BDYDOC-NFENUM'  ls_docmn-value.


*** Busca Numero Série
  CLEAR ls_docmn.
  READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'SERIE'.
  PERFORM f_bdc_field  USING:
        ' '   'J_1BDYDOC-SERIES'   ls_docmn-value.

*** Busca Data do documento
  CLEAR ls_docmn.
  READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'DHEMI'.

  WRITE sy-datum USING EDIT MASK '__.__.____' TO lv_datum.

  CONCATENATE ls_docmn-value+8(2) '.'
              ls_docmn-value+5(2) '.'
              ls_docmn-value(4)
         INTO lv_datum2.

  PERFORM f_bdc_field USING ' '  'J_1BDYDOC-DOCDAT'  lv_datum2.
  PERFORM f_bdc_field USING ' '  'J_1BDYDOC-PSTDAT'  lv_datum.

*** Busca Natureza do documento
  CLEAR ls_docmn.
  READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'NATOP'.
  PERFORM f_bdc_field  USING:
        ' '   'J_1BDYDOC-OBSERVAT'  ls_docmn-value.

*** Insere itens
  MOVE  lt_docmn[] TO  lt_docmnx[].
  DELETE  lt_docmnx WHERE dcitm EQ '000000'.
  DELETE ADJACENT DUPLICATES FROM lt_docmnx COMPARING dcitm.
  SORT lt_docmnx ASCENDING BY dcitm.
  CLEAR: lv_lines, lv_cont.
  DESCRIBE TABLE lt_docmnx LINES lv_lines.

  LOOP AT lt_docmnx INTO ls_docmnx.
    ADD 1 TO lv_cont.

    CLEAR ls_docmn.
    READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'NNF'.

    PERFORM f_bdc_field USING ' '  'J_1BDYDOC-NFENUM' ls_docmn-value.
    PERFORM f_bdc_field USING 'X'  'SAPLJ1BB2'        '3000'.

    CLEAR ls_docmn.
    READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'NNF'.

    PERFORM f_bdc_field USING ' '  'J_1BDYDOC-NFENUM' ls_docmn-value.
    PERFORM f_bdc_field USING ' '  'J_1BDYLIN-ITMTYP' '1'.

*** Descrição
    CLEAR ls_docmn.
    READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'XPROD'
                                               dcitm = ls_docmnx-dcitm.

    PERFORM f_bdc_field USING ' '  'J_1BDYLIN-MAKTX' ls_docmn-value(40).
*    PERFORM f_bdc_field USING ' '  'J_1BDYLIN-MATKL' 'Z555'.

*** Quantidade
    CLEAR ls_docmn.
    READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'QCOM'
                                               dcitm =  ls_docmnx-dcitm.

    PERFORM f_bdc_field USING ' '  'J_1BDYLIN-MENGE' ls_docmn-value.

*** Unidade de Medida
    CLEAR ls_docmn.
    READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'UCOM'
                                               dcitm = ls_docmnx-dcitm.

    PERFORM f_bdc_field USING ' '  'J_1BDYLIN-MEINS' ls_docmn-value.

*** Valor
    CLEAR ls_docmn.
    READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'VUNCOM'
                                               dcitm = ls_docmnx-dcitm.

    PERFORM f_bdc_field USING ' '  'J_1BDYLIN-NETPR' ls_docmn-value.

**** Valor CFOP
    CLEAR ls_docmn.
    READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'CFOP'
                                               dcitm = ls_docmnx-dcitm.

    PERFORM f_bdc_field USING ' '  'J_1BDYLIN-CFOP'    ls_docmn-value.
*    PERFORM f_bdc_field USING ' '  'J_1BDYLIN-MATKL'   '999999'.
    PERFORM f_bdc_field USING ' '  'J_1BDYLIN-TAXLW1'  ' '.
    PERFORM f_bdc_field USING ' '  'J_1BDYLIN-TAXLW2'  ' '.
    PERFORM f_bdc_field USING ' '  'J_1BDYLIN-MATORG'  '0'.
    PERFORM f_bdc_field USING ' '  'J_1BDYLIN-MATUSE'  '2'.

*** NCM
*    CLEAR ls_docmn.
*    READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'XMLNCM'
*                                               dcitm = ls_docmnx-dcitm.
*
*    IF sy-subrc IS INITIAL.
*      lv_4 = ls_docmn-value(4).
*      lv_2 = ls_docmn-value+4(2).
*      CONCATENATE lv_4 lv_2 ls_docmn-value+6(2)
*             INTO ls_docmn-value.
*    ENDIF.

    CLEAR: ls_docmn.
    READ TABLE lt_docmn INTO ls_docmn WITH KEY dcitm = ls_docmnx-dcitm
                                               mneum = 'XMLNCM'.
*                                               BINARY SEARCH.

    WRITE ls_docmn-value TO ls_docmn-value USING EDIT MASK '____.__.__'.
    PERFORM f_bdc_field USING ' '  'J_1BDYLIN-NBM' ls_docmn-value.

    IF lv_lines > 1.
      IF lv_cont < lv_lines.
        PERFORM f_bdc_field USING ' ' 'SAPLJ1BB2'  '3000'.
        PERFORM f_bdc_field USING ' ' 'BDC_OKCODE' '=ADIT'.
      ENDIF.
    ENDIF.

  ENDLOOP.

  PERFORM f_bdc_field USING 'X' 'SAPLJ1BB2'  '3000'.
  PERFORM f_bdc_field USING ' ' 'BDC_OKCODE' '=TAB1'.
  PERFORM f_bdc_field USING 'X' 'SAPLJ1BB2'  '2000'.
  PERFORM f_bdc_field USING ' ' 'BDC_OKCODE' '=SLCA'.
  PERFORM f_bdc_field USING 'X' 'SAPLJ1BB2'  '2000'.
  PERFORM f_bdc_field USING ' ' 'BDC_OKCODE' '=TAXS'.

*** Inicial Impostos
  DESCRIBE TABLE lt_docmnx  LINES lv_line.
  lv_line = lv_line - 1.

  DO lv_line TIMES.
    PERFORM f_bdc_field USING 'X' 'SAPLJ1BB2'  '3000'.
    PERFORM f_bdc_field USING ' ' 'BDC_OKCODE' '=NELI'.
  ENDDO.

*** inicio inclusão preenchimento dos dados de NFE
*  IF sy-uname EQ 'JUNPSAMP'.
  PERFORM f_bdc_field USING 'X' 'SAPLJ1BB2'  '3000'.
  PERFORM f_bdc_field USING ' ' 'BDC_OKCODE' '/00'.

  PERFORM f_bdc_field USING 'X' 'SAPLJ1BB2'  '3000'.
  PERFORM f_bdc_field USING ' ' 'BDC_OKCODE' '=BACK'.

  PERFORM f_bdc_field USING 'X' 'SAPLJ1BB2'  '2000'.
  PERFORM f_bdc_field USING ' ' 'BDC_OKCODE' '=TAB8'.

  PERFORM f_bdc_field USING 'X' 'SAPLJ1BB2'  '2000'.
  PERFORM f_bdc_field USING ' ' 'BDC_OKCODE' '/00'.

  CLEAR ls_docmn.
  READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'DHEMI'.

  CLEAR lv_datum2.
  CONCATENATE ls_docmn-value+8(2) '.'
              ls_docmn-value+5(2) '.'
              ls_docmn-value(4)
         INTO lv_datum2.

  PERFORM f_bdc_field USING: ' ' 'J_1BDYDOC-DOCDAT' lv_datum2.

  CLEAR ls_docmn.
  READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'CNF'.

  PERFORM f_bdc_field  USING:
    ' '  'J_1BNFE_DOCNUM9_DIVIDED-DOCNUM8' ls_docmn-value.

  CLEAR ls_docmn.
  READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'CDV'.

  PERFORM f_bdc_field  USING:
    ' '  'J_1BNFE_ACTIVE-CDV' ls_docmn-value.

  CLEAR ls_docmn.
  READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'NPROT'.

  PERFORM f_bdc_field USING: ' ' 'J_1BDYDOC-AUTHCOD'  ls_docmn-value.
  PERFORM f_bdc_field USING: ' ' 'J_1BDYDOC-AUTHDATE' lv_datum2.
  PERFORM f_bdc_field USING: 'X' 'SAPLJ1BB2'          '2000',
                             ' ' 'BDC_OKCODE'         '=SAVE'.

*  ENDIF.
*** fim inclusão dos dados de NFE

*  IF sy-uname NE 'JUNPSAMP'.
*    PERFORM f_bdc_field  USING:
*    'X'  'SAPLJ1BB2' '3000',
*    ' '  'BDC_OKCODE' '=SAVE'.
*  ENDIF.

  CLEAR: lt_message[].
  p_mode = 'A'.
  CALL TRANSACTION 'J1B1N' USING lt_bdcdata MODE p_mode
                           MESSAGES INTO lt_message.

** verifica Documento Criado
  READ TABLE lt_message INTO ls_message WITH KEY msgtyp = 'S'
                                                 msgid  = '8B'
                                                 msgnr  = '161'.

  IF NOT sy-subrc IS INITIAL.
*** Registra LOG Erro
    REFRESH tl_logdoc.
    wl_logdoc-logty = 'E'.
    wl_logdoc-logno = ls_message-msgnr.
    APPEND wl_logdoc TO tl_logdoc.

    lv_flwst = 'E'.

  ELSE.
*** Registra LOG Sucesso
    REFRESH tl_logdoc.
    wl_logdoc-logty = 'S'.
    wl_logdoc-logno = ls_message-msgnr.
    wl_logdoc-logv1 = ls_message-msgv1.
    APPEND wl_logdoc TO tl_logdoc.

*** insere Nº Documento gerado
    CLEAR: ls_docmn.
    SELECT SINGLE MAX( seqnr )
      INTO vl_seqnr
      FROM zhms_tb_docmn
     WHERE chave EQ ls_cabdoc-chave.

    ADD 1 TO vl_seqnr.

    MOVE: ls_cabdoc-chave  TO ls_docmn-chave,
          'MATDOC'         TO ls_docmn-mneum,
          ls_message-msgv1 TO ls_docmn-value,
          vl_seqnr         TO ls_docmn-seqnr.

    MODIFY zhms_tb_docmn FROM ls_docmn.

    IF sy-subrc IS INITIAL.
      COMMIT WORK.
    ENDIF.

    lv_flwst = 'M'.

  ENDIF.

** verifica Documento cancelado
  READ TABLE lt_message INTO ls_message WITH KEY msgtyp = 'A'
                                                 msgid  = '00'
                                                 msgnr  = '359'.

  IF NOT sy-subrc IS INITIAL.

    CALL FUNCTION 'ZHMS_FM_REGLOG'
      EXPORTING
        cabdoc = ls_cabdoc
        flowd  = '10'
        flwst  = lv_flwst
      TABLES
        logdoc = tl_logdoc.

    CALL FUNCTION 'ZHMS_FM_STATUS'
      EXPORTING
        cabdoc = ls_cabdoc.
  ENDIF.

ENDFUNCTION.
