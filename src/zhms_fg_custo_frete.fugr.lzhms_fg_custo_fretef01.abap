*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_CUSTO_FRETEF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  ZEXECUTA_VI01
*&---------------------------------------------------------------------*
*       Criação do documento de custos de frete (VI01)
*----------------------------------------------------------------------*
FORM pf_executa_vi01 USING    p_tknum
                              p_nct
                              p_erro. " " 04/08/2019

  DATA: lv_msg(132) TYPE c.

  REFRESH: ti_bdcdata, ti_msgs.
  CLEAR:   wa_bdcdata, wa_msgs.

  PERFORM pf_insere_bdcdata USING:
        'X'  'SAPMV54A'    '10'          ,
        ' '  'BDC_CURSOR'  'RV54A-FKART' ,
        ' '  'BDC_OKCODE'  '=UEBP'       ,
        ' '  'VTTK-TKNUM'  p_tknum       ,   "Doc Transporte = TKNUM
        ' '  'RV54A-FKART' 'YBR1'        .

  PERFORM pf_insere_bdcdata USING:
        'X'  'SAPMV54A'    '30'          ,
*        ' '  'BDC_CURSOR'  'VFKP-POSTX(01)' ,
        ' '  'BDC_OKCODE'  '=SICH'       .
*        ' '  'VFKP-POSTX(01)'  p_nct .
  DATA lv_mode   TYPE char01 VALUE 'N'.

  CALL TRANSACTION 'VI01' USING  ti_bdcdata
                          MODE lv_mode
                          MESSAGES INTO ti_msgs.

  CLEAR lv_msg.
  "Verifica mensagem de sucesso
  CLEAR: wa_msgs, v_fknum.
  READ TABLE ti_msgs INTO wa_msgs WITH KEY msgtyp = 'S'
                                           msgid  = 'VY'
                                           msgnr  = '007'.
  " roho.
  IF sy-subrc IS INITIAL.

    v_fknum = wa_msgs-msgv1. " num custo frete gerado

    "Documento de custo de frete criado: xxxxx
    CLEAR v_mensagem.
    CONCATENATE TEXT-030 v_fknum INTO v_mensagem
                SEPARATED BY space.
    PERFORM pf_atualiza_log_2    USING wa_zentrada_valid
                                           wa_lfa1-lifnr
                                           v_mensagem
                                           '20'
                                           'S'.
    COMMIT WORK.

    WAIT UP TO 5 SECONDS.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    PERFORM pf_atualiza_status  USING wa_zentrada_valid
                                  wa_vttp_vbrp-tknum
                                  wa_lfa1-lifnr
                                  '20'.

*** 4. Atualizar tabela ZHMS_TB_STATUS

  ELSE.         "Erro de execução VI01

    DELETE ADJACENT DUPLICATES FROM ti_msgs
    COMPARING ALL FIELDS.

    READ TABLE ti_msgs INTO wa_msgs WITH KEY tcode = 'VI01'
                                          msgtyp   = 'S'
                                          msgspra	 = 'P'
                                          msgid	   = 'VY'
                                          msgnr	   = '122'.

    IF sy-subrc EQ 0.
      DATA lv_fknum TYPE vfkn-fknum.
      SELECT SINGLE fknum FROM vfkn INTO lv_fknum  WHERE rebel = wa_vbrp-vgbel. "#EC CI_NOFIELD
      IF sy-subrc EQ 0.
        PERFORM pf_executa_vi02 USING wa_zentrada_valid-nct
                                lv_fknum.
      ELSE.
        PERFORM pf_log_msg USING  sy-msgid
                        sy-msgno
                        sy-msgv1
                        sy-msgv2
                        sy-msgv3
                        sy-msgv4
                 CHANGING  lv_msg.


        CLEAR v_mensagem. v_mensagem = lv_msg.
        PERFORM pf_atualiza_log  USING wa_zentrada_valid
                                       wa_lfa1-lifnr
                                       v_mensagem
                                       '20'.

        " Erro ao criar Documento de Custo de Frete para
        p_erro = 'A'.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PF_INSERE_BDCDATA
*&---------------------------------------------------------------------*
*       BDCDATA
*----------------------------------------------------------------------*
FORM pf_insere_bdcdata USING p_flag
                             p_field
                             p_value.

  CLEAR   wa_bdcdata.

  IF p_flag EQ 'X'.
    MOVE: p_field  TO  wa_bdcdata-program,
          p_value  TO  wa_bdcdata-dynpro,
          p_flag   TO  wa_bdcdata-dynbegin.
  ELSE.
    MOVE: p_field  TO  wa_bdcdata-fnam,
          p_value  TO  wa_bdcdata-fval.
  ENDIF.

  APPEND wa_bdcdata  TO ti_bdcdata.
  CLEAR  wa_bdcdata.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PF_LOG_MSG
*&---------------------------------------------------------------------*
*      Writes Log
*&---------------------------------------------------------------------*
FORM pf_log_msg USING     p_msgid
                          p_msg_no
                          p_msgv1
                          p_msgv2
                          p_msgv3
                          p_msgv4
                 CHANGING p_mensagem.

  DATA: lv_msg_no TYPE t100-msgnr,
        lv_msgid  TYPE t100-arbgb,
        lv_msgv1  TYPE balm-msgv1,
        lv_msgv2  TYPE balm-msgv2,
        lv_msgv3  TYPE balm-msgv3,
        lv_msgv4  TYPE balm-msgv4.


  lv_msg_no = p_msg_no.
  lv_msgid  = p_msgid.
  lv_msgv1  = p_msgv1.
  lv_msgv2  = p_msgv2.
  lv_msgv3  = p_msgv3.
  lv_msgv4  = p_msgv4.

*** Show the Error
  CALL FUNCTION 'MESSAGE_PREPARE'
    EXPORTING
      msg_id                 = lv_msgid
      msg_no                 = lv_msg_no
      msg_var1               = lv_msgv1
      msg_var2               = lv_msgv2
      msg_var3               = lv_msgv3
      msg_var4               = lv_msgv4
    IMPORTING
      msg_text               = p_mensagem
    EXCEPTIONS
      function_not_completed = 1
      message_not_found      = 2
      OTHERS                 = 3.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  PF_EXECUTA_VI02
*&---------------------------------------------------------------------*
*       Addicionar o valor ao item do documento de custo de frete
*----------------------------------------------------------------------*
FORM pf_executa_vi02 USING p_nct    TYPE any
                           p_fknum  TYPE any.

  DATA: lv_msg_2(132) TYPE c,
        lv_vtprest    TYPE zhms_de_value,
        lv_vtprest_1  TYPE komv-kbetr,
        lv_nct        TYPE znct,
        lv_fknum      TYPE vfkn-fknum,
        lv_cont(3)    TYPE i.

  DATA: lv_vim_marked(18) TYPE c,
        lv_komv_kbetr(18) TYPE c,
        lv_vfsi_kposn(18) TYPE c,
        lv_vfkn_kposn(18) TYPE c,
        lv_vfkp_fkpos(18) TYPE c.

  DATA: lti_likp     TYPE STANDARD TABLE OF ty_likp,
        lti_vfkn     TYPE STANDARD TABLE OF ty_vfkn,
        lwa_likp     TYPE ty_likp,
        lv_peso      TYPE gsgew,
        lv_preco     TYPE komv-kbetr,
        lv_btgew     TYPE gsgew,
        lv_btgew_tot TYPE gsgew,
        lv_brgew     TYPE gsgew,
        vl_vgbel_ax  TYPE vbrp-vgbel.

  REFRESH: ti_j1bnflin_aux, ti_j1bnfdoc_aux, ti_vbrp_aux.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_fknum
    IMPORTING
      output = lv_fknum.

*  SELECT SINGLE fknum fkpos lfnkn rebel repos
*    FROM vfkn
*    INTO wa_vfkn
*   WHERE fknum = lv_fknum
*     AND rebel = wa_vbrp-vgbel.
*
*  IF sy-subrc EQ 0.
*    SELECT vbeln btgew
*      FROM likp
*      INTO TABLE lti_likp
*     WHERE vbeln = wa_vfkn-rebel.
*    IF sy-subrc EQ 0.
*      LOOP AT lti_likp INTO lwa_likp.
*        Soma todos os BTGEW
*        lv_btgew = lv_btgew + lwa_likp-btgew.
*      ENDLOOP.
*      SELECT SINGLE brgew FROM lips INTO lv_brgew
*                                    WHERE vbeln = wa_vfkn-rebel
*                                      AND posnr = wa_vfkn-repos.
*      IF sy-subrc EQ 0.
*        IF lv_btgew IS NOT INITIAL.
*          lv_peso = lv_brgew / lv_btgew.
*        ENDIF.
*      ENDIF.
*
*
*    ENDIF.
*  ENDIF.
  vl_vgbel_ax = wa_vbrp-vgbel.
  IF p_nct IS INITIAL.

    "Buscar o NCT
    CLEAR: wa_j1bnflin, lv_nct.
    READ TABLE ti_j1bnflin INTO wa_j1bnflin
                           WITH KEY tknum = wa_vttp-tknum.
    IF sy-subrc IS INITIAL.
      lv_nct = wa_j1bnflin-nct.
      p_nct  = lv_nct.
      IF wa_j1bnflin-nct IS INITIAL.

        "Busca No.do CTe
        CLEAR wa_j1bnfdoc.
        READ TABLE ti_j1bnfdoc INTO wa_j1bnfdoc
                               WITH KEY docnum = wa_j1bnflin-docnum.
        IF sy-subrc IS INITIAL.

          CLEAR lv_nct.
          CLEAR wa_zentrada.
          READ TABLE ti_zentrada2 INTO wa_zentrada2
                                 WITH KEY ndoc = wa_j1bnfdoc-nfenum.

          IF sy-subrc IS INITIAL.
            lv_nct = wa_zentrada2-nct.
            p_nct  = lv_nct.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  SELECT SINGLE fknum fkpos lfnkn rebel repos
    FROM vfkn
    INTO wa_vfkn
   WHERE fknum = lv_fknum
     AND rebel = wa_vbrp-vgbel.
  DATA lv_tknum LIKE vttp-tknum.
  CLEAR: lv_cont, lv_tknum.
  LOOP AT ti_zentrada_valid INTO wa_zentrada_valid
    WHERE nct = p_nct.
    READ TABLE ti_j1bnfdoc INTO wa_j1bnfdoc WITH KEY nfenum = wa_zentrada_valid-ndoc. " Nota
    IF sy-subrc EQ 0.
      READ TABLE ti_j1bnflin INTO wa_j1bnflin WITH KEY docnum = wa_j1bnfdoc-docnum. " Referência Doc origem
      IF sy-subrc EQ 0.
        READ TABLE ti_refkey INTO wa_refkey WITH KEY refkey = wa_j1bnflin-refkey. " Referência Doc origem
        IF sy-subrc EQ 0.
          READ TABLE ti_vttp_vbrp INTO wa_vttp_vbrp WITH KEY vbeln = wa_refkey-vbeln. "Fatura x Remessa        IF lv_tknum IS INITIAL.
          IF sy-subrc = 0.
            IF lv_tknum IS INITIAL.
              lv_cont = lv_cont + 1.
              lv_tknum = wa_vttp_vbrp-tknum.
            ELSE.
              IF lv_tknum <> wa_vttp_vbrp-tknum.
                lv_cont = lv_cont + 1.
                lv_tknum = wa_vttp_vbrp-tknum.
              ELSE.
                lv_tknum = wa_vttp_vbrp-tknum.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDLOOP.

  IF lv_cont > 1.

    LOOP AT ti_j1bnfdoc INTO wa_j1bnfdoc.
      READ TABLE ti_zentrada_valid INTO wa_zentrada_valid WITH KEY nct = p_nct
                                                                   ndoc = wa_j1bnfdoc-nfenum.
      IF sy-subrc = 0.
        APPEND wa_j1bnfdoc TO ti_j1bnfdoc_aux.
      ENDIF.
    ENDLOOP.

    LOOP AT ti_j1bnflin INTO wa_j1bnflin.
      READ TABLE ti_j1bnfdoc_aux INTO wa_j1bnfdoc WITH KEY docnum = wa_j1bnflin-docnum.
      IF sy-subrc = 0.
        APPEND wa_j1bnflin TO ti_j1bnflin_aux.
      ENDIF.
    ENDLOOP.


    LOOP AT ti_vbrp INTO wa_vbrp.
      READ TABLE ti_j1bnflin_aux INTO wa_j1bnflin WITH KEY refkey = wa_vbrp-vbeln.
      IF sy-subrc = 0.
        APPEND wa_vbrp TO ti_vbrp_aux.
      ENDIF.
    ENDLOOP.


    IF NOT ti_vbrp_aux[] IS INITIAL.
      REFRESH: lti_likp.
      SELECT vbeln btgew
        INTO TABLE lti_likp
        FROM likp
        FOR ALL ENTRIES IN ti_vbrp_aux
        WHERE vbeln = ti_vbrp_aux-vgbel.

      IF NOT lti_likp[] IS INITIAL.
        LOOP AT lti_likp INTO lwa_likp.
*        Soma todos os BTGEW
          lv_btgew = lv_btgew + lwa_likp-btgew.
        ENDLOOP.
      ENDIF.

      READ TABLE lti_likp INTO lwa_likp  WITH KEY vbeln = vl_vgbel_ax.
      IF sy-subrc = 0.
*Calcula a porcentagem do peso
        lv_peso = lwa_likp-btgew * 100 / lv_btgew.

      ENDIF.
    ENDIF.
  ENDIF.
***** BUSCAR NA J_1BNFE_ACTIVE COM A MONTAGEM DA CHAVE DE ACESSO ABAIXO,
***** E COM ESTA CHAVE, BUSCAR NA DOCMN COM O MNEUMONICO DO XML REFERENTE AO VALOR
***** OU VALOR DA TABELA DE ENTRADA
  CLEAR: lv_vtprest.

  "Buscar o Valor do CTE na tabela do XML no Homsoft
  SELECT SINGLE value
    FROM zhms_tb_docmn
    INTO lv_vtprest
    WHERE chave = wa_zentrada_valid-chave_cte " v_ch_acesso
      AND mneum = 'VTPREST'.

  IF NOT sy-subrc IS INITIAL.

*Buscar o valor da linha da tabela de entrada
    CLEAR wa_j1bnfdoc.
    READ TABLE ti_j1bnfdoc INTO wa_j1bnfdoc
                           WITH KEY docnum = wa_j1bnflin-docnum.

    IF sy-subrc IS INITIAL.

      CLEAR wa_zentrada.
      READ TABLE ti_zentrada2 INTO wa_zentrada2
                              WITH KEY nct = p_nct
                                       ndoc = wa_j1bnfdoc-nfenum.

      IF sy-subrc IS INITIAL.
        lv_vtprest_1 = wa_zentrada2-vtprest.
      ENDIF.

    ENDIF.

  ELSE.   " se encontrou na tabela do xml
    TRANSLATE lv_vtprest USING ',.'.
    CONDENSE lv_vtprest.
    lv_vtprest_1 = lv_vtprest.

  ENDIF.
  IF NOT lv_peso IS INITIAL.
    lv_preco = lv_peso * lv_vtprest_1 / 100.
  ELSE.
    lv_preco = lv_vtprest_1.
  ENDIF.
  IF lv_preco IS NOT INITIAL.
    lv_vtprest_1 = lv_preco.
  ENDIF.
  WRITE lv_vtprest_1 TO lv_vtprest CURRENCY 'BRL'.
  CONDENSE lv_vtprest.


  REFRESH: ti_bdcdata, ti_msgs.
  CLEAR:   wa_bdcdata, wa_msgs.

  CLEAR: lv_vim_marked, lv_komv_kbetr, lv_vfsi_kposn.

  CONCATENATE 'VFKN-KPOSN(' wa_vfkn-fkpos ')' INTO lv_vfkn_kposn.
  CONCATENATE 'VFKP-FKPOS(' wa_vfkn-fkpos ')' INTO lv_vfkp_fkpos.

  PERFORM pf_insere_bdcdata USING:
        'X'  'SAPMV54A'         '20'          ,
        ' '  'BDC_CURSOR'       'VFKK-FKNUM'  ,
        ' '  'BDC_OKCODE'       '=UEBP'       ,
        ' '  'VFKK-FKNUM'       p_fknum.

  DATA lv_index TYPE i.
  DATA lv_mod   TYPE i.
  DATA lv_item  TYPE vfkn-fkpos.

  lv_item = wa_vfkn-fkpos.

  " A tela do batch input VI02 possui 9 linhas com a opção defsize = X,
  " a cada 9 linhas, 1 pagedown é necessário e o posnr se renova à posição 1.
*  IF wa_vfkn-fkpos > 9.
*    CLEAR lv_index.
*    lv_index = lv_item / 9. " Maior que 9, próximas telas, múltiplos de 9
*    lv_index = lv_index - 1.
*    IF lv_index IS NOT INITIAL.
*      DO lv_index TIMES.
*        lv_item = lv_item - 9.
*      ENDDO.
*    ENDIF.
*  ENDIF.

*  CLEAR lv_vfkp_fkpos.
*  CONCATENATE 'VFKP-FKPOS(' lv_item ')' INTO lv_vfkp_fkpos.
*
*  IF lv_index IS NOT INITIAL.
*    DO lv_index TIMES. "Mapeia page down N vezes necessário
*      PERFORM pf_insere_bdcdata USING:
*            'X'  'SAPMV54A'         '30'          ,
*             ' '  'BDC_OKCODE'  '=P+'             .
*    ENDDO.
*  ENDIF.
  PERFORM pf_insere_bdcdata USING:
          'X'  'SAPMV54A'         '30'            ,
          ' '  'BDC_CURSOR'       'VFKP-POSTX(01)',
          ' '  'BDC_OKCODE'       '=KSMA'         .

  PERFORM pf_insere_bdcdata USING:
      'X'  'SAPMV54A'         '30'            ,
      ' '  'BDC_CURSOR'       'VFKP-POSTX(01)',
      ' '  'BDC_OKCODE'       '=PDET'         .

  lv_item = lv_item - 1.

  IF lv_item > 0.
    DO lv_item TIMES.
      PERFORM pf_insere_bdcdata USING:
       'X'  'SAPMV54A'         '40'            ,
       ' '  'BDC_CURSOR'       'VFKP-POSTX'    ,
       ' '  'BDC_OKCODE'       '=PNEX'         .
    ENDDO.


    PERFORM pf_insere_bdcdata USING:
          'X'  'SAPMV54A'         '40'          ,
          ' '  'BDC_CURSOR'       'VFKP-POSTX'  ,
          ' '  'BDC_OKCODE'       '=PREF'       ,
          ' '  'VFKP-WAERS'       'BRL'         ,
          ' '  'VFKP-POSTX'       p_nct        .

    PERFORM pf_insere_bdcdata USING:
          'X'  'SAPMV54A'         '40'          ,
          ' '  'BDC_OKCODE'       '=PKON'       ,
          ' '  'BDC_CURSOR'       'VFSI-KPOSN(01)',
          ' '  'VFKP-EXTI2'       p_nct        .      "Numero do Cte do XML

    PERFORM pf_insere_bdcdata USING:
          'X'  'SAPLV69A'         '9000'        ,
          ' '  'BDC_OKCODE'       '/00'         ,
          ' '  'BDC_CURSOR'       'KOMV-KBETR(01)' ,
          ' '  'KOMV-KBETR(01)'   lv_vtprest    .

    PERFORM pf_insere_bdcdata USING:
          'X'  'SAPLV69A'         '9000'        ,
          ' '  'BDC_OKCODE'       '=BACK'       ,
          ' '  'BDC_CURSOR'       'KOMV-KSCHL(05)' .

    PERFORM pf_insere_bdcdata USING:
          'X'  'SAPMV54A'         '40'          ,
          ' '  'BDC_OKCODE'       '=SICH'       ,
          ' '  'BDC_CURSOR'       'VFSI-KPOSN(01)' ,
          ' '  'VFKP-EXTI2'       p_nct        .      "Numero do Cte do XML    .

  ELSE.

    PERFORM pf_insere_bdcdata USING:
          'X'  'SAPMV54A'         '40'          ,
          ' '  'BDC_CURSOR'       'VFKP-POSTX'  ,
          ' '  'BDC_OKCODE'       '=PREF'       ,
          ' '  'VFKP-WAERS'       'BRL'         ,
          ' '  'VFKP-POSTX'       p_nct        .

    PERFORM pf_insere_bdcdata USING:
          'X'  'SAPMV54A'         '40'          ,
          ' '  'BDC_OKCODE'       '=PKON'       ,
          ' '  'BDC_CURSOR'       'VFSI-KPOSN(01)',
          ' '  'VFKP-EXTI2'       p_nct        .      "Numero do Cte do XML

    PERFORM pf_insere_bdcdata USING:
          'X'  'SAPLV69A'         '9000'        ,
          ' '  'BDC_OKCODE'       '/00'         ,
          ' '  'BDC_CURSOR'       'KOMV-KBETR(01)' ,
          ' '  'KOMV-KBETR(01)'   lv_vtprest    .

    PERFORM pf_insere_bdcdata USING:
          'X'  'SAPLV69A'         '9000'        ,
          ' '  'BDC_OKCODE'       '=BACK'       ,
          ' '  'BDC_CURSOR'       'KOMV-KSCHL(05)' .

    PERFORM pf_insere_bdcdata USING:
          'X'  'SAPMV54A'         '40'          ,
          ' '  'BDC_OKCODE'       '=SICH'       ,
          ' '  'BDC_CURSOR'       'VFSI-KPOSN(01)' ,
          ' '  'VFKP-EXTI2'       p_nct        .      "Numero do Cte do XML    .
  ENDIF.
  DATA lv_mode   TYPE sy-ftype VALUE 'N'.
  DATA lv_update TYPE sy-ftype VALUE 'A'.


  DATA: lwa_ctu TYPE ctu_params.
  lwa_ctu-dismode      =  'N'.
  lwa_ctu-defsize      =  'X'.

  CALL TRANSACTION 'VI02' USING  ti_bdcdata
                         " MODE lv_mode
                         OPTIONS FROM lwa_ctu
                         MESSAGES INTO ti_msgs.

  CLEAR lv_msg_2.

  "Verifica mensagem de sucesso
  CLEAR: wa_msgs. "v_fknum.
  READ TABLE ti_msgs INTO wa_msgs WITH KEY msgtyp = 'S'
                                           msgid  = 'VY'
                                           msgnr  = '007'.

  IF sy-subrc IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
    COMMIT WORK AND WAIT .
    WAIT UP TO 5 SECONDS.
*** Mensagem sucesso
    CLEAR v_mensagem.
*    "Valor do documento de custo de frete: xxxxx  atualizado com sucesso
    CONCATENATE TEXT-032 wa_vfkn-fknum TEXT-033 INTO v_mensagem
                SEPARATED BY space.
    PERFORM pf_atualiza_log_2    USING wa_zentrada_valid
                                           wa_lfa1-lifnr
                                           v_mensagem
                                           '20'
                                           'I'.

  ELSE. "Erro de execução VI02

    DELETE ADJACENT DUPLICATES FROM ti_msgs
    COMPARING ALL FIELDS.


    CLEAR lv_msg_2.
    PERFORM pf_log_msg USING  sy-msgid
                              sy-msgno
                              sy-msgv1
                              sy-msgv2
                              sy-msgv3
                              sy-msgv4
                         CHANGING  lv_msg_2.

    READ TABLE ti_msgs INTO wa_msgs INDEX 1.
    IF sy-subrc EQ 0.
      IF wa_msgs-msgtyp EQ 'E'.
        CLEAR v_mensagem. v_mensagem = lv_msg_2.
        PERFORM pf_atualiza_log_2    USING wa_zentrada_valid
                                               wa_lfa1-lifnr
                                               v_mensagem
                                               '20'
                                               wa_msgs-msgtyp.
      ELSE.
        PERFORM pf_atualiza_status  USING wa_zentrada_valid
                            wa_vttp_vbrp-tknum
                            wa_lfa1-lifnr
                            '20'.
      ENDIF.
    ENDIF.
  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PF_DELETE
*&---------------------------------------------------------------------*
*       Exclui documento custo de frete
*----------------------------------------------------------------------*
*      -->P_FKNUM  Doc.custo frete
*----------------------------------------------------------------------*
FORM pf_delete  USING    p_fknum.

  DATA: lv_msg_3(132) TYPE c.

  REFRESH: ti_bdcdata, ti_msgs.
  CLEAR:   wa_bdcdata, wa_msgs.

  PERFORM pf_insere_bdcdata USING:
        'X'  'SAPMV54A '        '20'          ,
        ' '  'BDC_CURSOR'       p_fknum       ,
        ' '  'BDC_OKCODE'       '=UEBP'       .

  PERFORM pf_insere_bdcdata USING:
        'X'  'SAPMV54A '        '30'          ,
        ' '  'BDC_OKCODE'       '/ELOES'      ,
        ' '  'BDC_CURSOR'       'VFKP-POSTX(01)' .

  DATA lv_mode   TYPE char01 VALUE 'N'.
  CALL TRANSACTION 'VI02' USING  ti_bdcdata
                          MODE lv_mode
                          MESSAGES INTO ti_msgs.

  CLEAR lv_msg_3.

  "Verifica mensagem de sucesso
  CLEAR: wa_msgs.
  READ TABLE ti_msgs INTO wa_msgs WITH KEY msgtyp = 'S'
                                           msgid  = 'VY'.

  IF sy-subrc IS INITIAL.

* Mensagem de sucesso
    CLEAR wa_return.
    "Documento de custo de frete excluído com sucesso: xxxxx
    CONCATENATE TEXT-034 p_fknum INTO wa_return-message
                SEPARATED BY space.
    APPEND wa_return TO ti_return.
    CLEAR wa_return.


*** 4. Atualizar tabela ZHMS_TB_STATUS
    PERFORM pf_atualiza_tabela_delete USING p_fknum.

  ELSE.         "Erro

    DELETE ADJACENT DUPLICATES FROM ti_msgs
    COMPARING ALL FIELDS.

    PERFORM pf_log_msg USING  sy-msgid
                              sy-msgno
                              sy-msgv1
                              sy-msgv2
                              sy-msgv3
                              sy-msgv4
                         CHANGING  lv_msg_3.

    wa_return-message = lv_msg_3.
    APPEND wa_return TO ti_return.
    CLEAR wa_return.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PF_VERIFICA_OK
*&---------------------------------------------------------------------*
*       Após a execução da VI01, efetuar a busca novamente
*----------------------------------------------------------------------*
*      -->P_V_FKNUM  text
*      <--P_V_FLAG  text
*----------------------------------------------------------------------*
FORM pf_verifica_ok  USING    p_v_fknum TYPE vfkn-fknum
                     CHANGING p_v_flag  TYPE char1.


  DATA: lti_vfkn TYPE TABLE OF ty_vfkn,
        lwa_vfkn TYPE          ty_vfkn.


  REFRESH: lti_vfkn.
  CLEAR: p_v_flag.
  DATA lv_fknum TYPE vfkn-fknum.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_v_fknum
    IMPORTING
      output = lv_fknum.

  DO 20 TIMES.
    SELECT fknum fkpos lfnkn rebel
      FROM vfkn
      INTO TABLE lti_vfkn
      WHERE fknum = lv_fknum.
    IF sy-subrc EQ 0.
      EXIT.
    ENDIF.
  ENDDO.

  IF lti_vfkn[] IS NOT INITIAL.
    p_v_flag = 'S'.
  ELSE.
    p_v_flag = 'N'.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PF_ATUALIZA_TABELA_DELETE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM pf_atualiza_tabela_delete USING p_p_fknum.

  DATA: lv_tabix TYPE sy-tabix.


  REFRESH: ti_status.
  CLEAR:   wa_status.

  SELECT *
    FROM zhms_tb_status
    INTO TABLE ti_status
    WHERE fknum = p_p_fknum.
*      AND fkpos = wa_vfkp-fkpos.

  IF sy-subrc IS INITIAL.

    CLEAR wa_status.
    LOOP AT ti_status INTO wa_status.

      lv_tabix = sy-tabix.

      CLEAR: wa_status-fknum,
             wa_status-fkpos,
             wa_status-zstcf.

      MODIFY ti_status FROM wa_status INDEX lv_tabix.
      CLEAR wa_status.

    ENDLOOP.

    "Atualizando tabela Z
    MODIFY zhms_tb_status FROM TABLE ti_status.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PF_CRIA_PO
*&---------------------------------------------------------------------*
*       Cria PO do documento de custo de frete
*----------------------------------------------------------------------*
FORM pf_cria_po  USING    p_wa_vfkp_fknum
                          p_wa_vfkp_fkpos.

  DATA: lv_msg_4(132)       TYPE c,
        lv_vfkpd_slfrei(20) TYPE c.

  CLEAR: lv_vfkpd_slfrei.

  CONCATENATE 'VFKPD-SLFREI(' p_wa_vfkp_fkpos ')' INTO lv_vfkpd_slfrei.

  REFRESH: ti_bdcdata, ti_msgs.
  CLEAR:   wa_bdcdata, wa_msgs.

  PERFORM pf_insere_bdcdata USING:
        'X'  'SAPMV54A'         '20'             ,
        ' '  'BDC_CURSOR'       'VFKK-FKNUM'     ,
        ' '  'BDC_OKCODE'       '=UEBP'          ,
        ' '  'VFKK-FKNUM'       p_wa_vfkp_fknum  .

  DATA lv_index TYPE i.
  DATA lv_mod   TYPE i.
  DATA lv_item  TYPE vfkn-fkpos.

*  lv_item = p_wa_vfkp_fknum.
  lv_item = p_wa_vfkp_fkpos.

  " A tela do batch input VI02 possui 9 linhas com a opção defsize = X,
  " a cada 9 linhas, 1 pagedown é necessário e o posnr se renova à posição 1.
  CLEAR lv_index.
*  IF p_wa_vfkp_fknum > 9.
**    CLEAR lv_index.
**    lv_index = lv_item / 9. " Maior que 9, próximas telas, múltiplos de 9
**    lv_index = lv_index - 1.
**    IF lv_index IS NOT INITIAL.
*       while lv_item > 9.
*        lv_item = lv_item - 9.
*        lv_index = lv_index + 1.
*      ENDWHILE.
**    ENDIF.
*
*  ENDIF.
*
*  CLEAR lv_vfkpd_slfrei.
**  CONCATENATE 'VFKP-FKPOS(' lv_item ')' INTO lv_vfkpd_slfrei.
*  CONCATENATE 'VFKPD-SLFREI(' lv_item ')' INTO lv_vfkpd_slfrei.
*  IF lv_index IS NOT INITIAL. "Mapeia page down N vezes necessário
*    DO lv_index TIMES.
*      PERFORM pf_insere_bdcdata USING:
*            'X'  'SAPMV54A'         '30'          ,
*             ' '  'BDC_OKCODE'  '=P+'             .
*    ENDDO.
*  ENDIF.
*
*  PERFORM pf_insere_bdcdata USING:
*  'X'  'SAPMV54A'         '30',
**  ' '  'BDC_CURSOR'       p_wa_vfkp_fkpos  .
*  ' '  'BDC_CURSOR'       lv_vfkpd_slfrei  .
*
*  PERFORM pf_insere_bdcdata USING:
*    ' '  'BDC_OKCODE'       '=SICH'          ,
*    ' '  lv_vfkpd_slfrei    'X'              .


  PERFORM pf_insere_bdcdata USING:
        'X'  'SAPMV54A'         '30'            ,
        ' '  'BDC_CURSOR'       'VFKP-POSTX(01)',
        ' '  'BDC_OKCODE'       '=KSMA'         .

  PERFORM pf_insere_bdcdata USING:
      'X'  'SAPMV54A'         '30'            ,
      ' '  'BDC_CURSOR'       'VFKP-POSTX(01)',
      ' '  'BDC_OKCODE'       '=PDET'         .

  lv_item = lv_item - 1.

  IF lv_item > 0.
    DO lv_item TIMES.
      PERFORM pf_insere_bdcdata USING:
       'X'  'SAPMV54A'         '40'            ,
       ' '  'BDC_CURSOR'       'VFKP-POSTX'    ,
       ' '  'BDC_OKCODE'       '=PNEX'         .
    ENDDO.
    PERFORM pf_insere_bdcdata USING:
     'X'  'SAPMV54A'         '40'            ,
     ' '  'BDC_CURSOR'       'VFKP-POSTX'    ,
     ' '  'BDC_OKCODE'       '=PABR'         .
    PERFORM pf_insere_bdcdata USING:
     'X'  'SAPMV54A'         '40'            ,
     ' '  'BDC_CURSOR'       'VFKPD-SLFREI'  ,
     ' '  'VFKPD-SLFREI'     'X'             ,
     ' '  'BDC_OKCODE'       '=SICH'         .

  ELSE.
    PERFORM pf_insere_bdcdata USING:
   'X'  'SAPMV54A'         '40'            ,
   ' '  'BDC_CURSOR'       'VFKP-POSTX'    ,
   ' '  'BDC_OKCODE'       '=PABR'         .
    PERFORM pf_insere_bdcdata USING:
     'X'  'SAPMV54A'         '40'            ,
     ' '  'BDC_CURSOR'       'VFKPD-SLFREI'  ,
     ' '  'VFKPD-SLFREI'     'X'             ,
     ' '  'BDC_OKCODE'       '=SICH'         .
  ENDIF.
  DATA: lwa_ctu TYPE ctu_params.
  lwa_ctu-dismode      =  'N'.
  lwa_ctu-defsize      =  'X'.

  DATA lv_mode TYPE char01 VALUE 'N'.
  CALL TRANSACTION 'VI02' USING  ti_bdcdata
                         " MODE lv_mode
                         OPTIONS FROM lwa_ctu
                         MESSAGES INTO ti_msgs.

  CLEAR lv_msg_4.

  "Verifica mensagem de sucesso
  CLEAR: wa_msgs.
  DELETE ti_msgs WHERE msgv1 = 'VFKPD-SLFREI'.
  READ TABLE ti_msgs INTO wa_msgs WITH KEY msgtyp = 'S'
                                           msgid  = 'VY'
                                           msgnr  = '007'.

  IF sy-subrc IS INITIAL.
**** 4. Atualizar tabela ZHMS_TB_STATUS
    CLEAR v_mensagem. v_mensagem = TEXT-041.
    PERFORM pf_atualiza_log_2    USING wa_zentrada_valid
                                           wa_lfa1-lifnr
                                           v_mensagem
                                           '30'
                                           'S'.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
    WAIT UP TO 10 SECONDS.

    PERFORM pf_atualiza_status  USING wa_zentrada_valid
                                  wa_vttp_vbrp-tknum
                                  wa_lfa1-lifnr
                                  '30'.
  ELSE.

    CLEAR wa_return_erro.
    "Erro na criação PO para Nº custos de frete: xxxxx / xxxxx
    CONCATENATE TEXT-038 p_wa_vfkp_fknum '/' p_wa_vfkp_fkpos
                INTO wa_return_erro-message
                SEPARATED BY space.
    APPEND wa_return_erro TO ti_return_erro.
    CLEAR wa_return_erro.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PF_ESTORNA_PO
*&---------------------------------------------------------------------*
*       Estorna PO do documento de custo de frete
*----------------------------------------------------------------------*
FORM pf_estorna_po  USING    p_wa_vfkp_fknum
                             p_wa_vfkp_fkpos.

  DATA: lv_msg_5(132)     TYPE c,
        lv_vim_marked(16) TYPE c.

  CLEAR: lv_vim_marked.

  CONCATENATE 'VIM_MARKED(' p_wa_vfkp_fkpos+4(2) ')' INTO lv_vim_marked.

  REFRESH: ti_bdcdata, ti_msgs.
  CLEAR:   wa_bdcdata, wa_msgs.

  PERFORM pf_insere_bdcdata USING:
        'X'  'SAPMV54A'         '20'             ,
        ' '  'BDC_CURSOR'       'VFKK-FKNUM'     ,
        ' '  'BDC_OKCODE'       '=UEBP'          ,
        ' '  'VFKK-FKNUM'       p_wa_vfkp_fknum  .

  PERFORM pf_insere_bdcdata USING:
        'X'  'SAPMV54A'         '30'             ,
        ' '  'BDC_CURSOR'       p_wa_vfkp_fkpos  ,
        ' '  'BDC_OKCODE'       '=PDET'          ,
        ' '  lv_vim_marked      'X'              .

  PERFORM pf_insere_bdcdata USING:
          'X'  'SAPMV54A'         '40'           ,
          ' '  'BDC_CURSOR'       'VFKP-POSTX'   ,
          ' '  'BDC_OKCODE'       '=PABR'        .

  PERFORM pf_insere_bdcdata USING:
          'X'  'SAPMV54A'         '40'           ,
          ' '  'BDC_OKCODE'       '=SICH'        ,
          ' '  'BDC_CURSOR'       'VFKPD-SLSTOR' ,
          ' '  'VFKPD-SLSTOR'     'X'            .

  DATA lv_mode TYPE char01 VALUE 'N'.
  CALL TRANSACTION 'VI02' USING  ti_bdcdata
                          MODE lv_mode
                          MESSAGES INTO ti_msgs.

  CLEAR lv_msg_5.

  "Verifica mensagem de sucesso
  CLEAR: wa_msgs.
  READ TABLE ti_msgs INTO wa_msgs WITH KEY msgtyp = 'S'
                                           msgid  = 'VY'
                                           msgnr  = '007'.

  IF sy-subrc IS INITIAL.

**** 4. Atualizar tabela ZHMS_TB_STATUS
  ELSE.         "Erro

    CLEAR wa_return_erro.
    "Erro no estorno da PO para Nº custos de frete: xxxxx / xxxxx
    CONCATENATE TEXT-042 p_wa_vfkp_fknum '/' p_wa_vfkp_fkpos
                INTO wa_return_erro-message
                SEPARATED BY space.
    APPEND wa_return_erro TO ti_return_erro.
    CLEAR wa_return_erro.


  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PF_ATUALIZA2_TABELA_STATUS_PO
*&---------------------------------------------------------------------*
*       Atualiza tabela ZHMS_TB_STATUS, após estorno de PO
*----------------------------------------------------------------------*
FORM pf_atualiza2_tabela_status_po  USING    p_wa_vfkp_fknum
                                             p_wa_vfkp_fkpos.

  DATA: lv_tabix TYPE sy-tabix.

  DATA: lti_vfkp TYPE TABLE OF ty_vfkp,
        lwa_vfkp TYPE  ty_vfkp.



  REFRESH: ti_status, lti_vfkp.
  CLEAR:   wa_status, lwa_vfkp.

*Buscar na tabela ZHMS_TB_STATUS o registro onde ZHMS_TB_STATUS-FKNUM = FKNUM
*processado e ZHMS_TB_STATUS-FKPOS = FKPOS do documento processado
  SELECT *
    FROM zhms_tb_status
    INTO TABLE ti_status
    WHERE fknum = p_wa_vfkp_fknum
      AND fkpos = p_wa_vfkp_fkpos.

  IF sy-subrc IS INITIAL.

    CLEAR wa_status.
    LOOP AT ti_status INTO wa_status.

      lv_tabix = sy-tabix.

      CLEAR: wa_status-ebeln, wa_status-zstpo.

      MODIFY ti_status FROM wa_status INDEX lv_tabix.
      CLEAR wa_status.

    ENDLOOP.

    "Atualizando tabela Z
    MODIFY zhms_tb_status FROM TABLE ti_status.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PF_EXECUTA_MIRO
*&---------------------------------------------------------------------*
*       Executar BAPI para entrada da fatura
*----------------------------------------------------------------------*
FORM pf_executa_miro.


  DATA: lwa_headdata TYPE bapi_incinv_create_header,
        lwa_itemdata TYPE bapi_incinv_create_item,
        lwa_acctdata TYPE bapi_incinv_create_gl_account,
        lwa_withtax  TYPE bapi_incinv_create_withtax,
        lwa_return   TYPE bapiret2.

  DATA: lwa_j1bnfdoc TYPE ty_j1bnfdoc,
        lwa_j1bnflin TYPE ty_j1bnflin.

  DATA: lti_itemdata TYPE TABLE OF bapi_incinv_create_item,
        lti_acctdata TYPE TABLE OF bapi_incinv_create_gl_account,
        lti_withtax  TYPE TABLE OF bapi_incinv_create_withtax,
        lti_return   TYPE TABLE OF bapiret2.

  DATA: lti_j1bnfdoc TYPE TABLE OF ty_j1bnfdoc,
        lti_j1bnflin TYPE TABLE OF ty_j1bnflin.

  DATA: lv_demi      TYPE bapi_incinv_create_header-doc_date,
        lv_nct       TYPE bapi_incinv_create_header-ref_doc_no,
        lv_kzwi1     TYPE bapi_incinv_create_header-gross_amount,
        lv_vencto    TYPE bapi_incinv_create_header-bline_date,
        lv_days1     TYPE bapi_incinv_create_header-dsct_days1,
        lv_taxc      TYPE bapi_incinv_create_header-del_costs_taxc,
        lv_item_text TYPE bapi_incinv_create_header-item_text,
        lv_it_amount TYPE bapi_incinv_create_item-item_amount.

  DATA: lv_mwskz TYPE vfkp-mwskz,
        lv_tdlnr TYPE vfkp-tdlnr,
        lv_kzwi2 TYPE vfkp-kzwi2,
        lv_lblni TYPE vfkp-lblni,
        lv_name1 TYPE lfa1-name1,
        lv_ebelp TYPE vfkp-ebelp.

  CLEAR:   lwa_headdata,
           lwa_itemdata, lwa_acctdata, lwa_withtax, lwa_return,
           lwa_j1bnfdoc, lwa_j1bnflin.

  REFRESH: lti_itemdata, lti_acctdata, lti_withtax, lti_return,
           lti_j1bnfdoc, lti_j1bnflin.

  CLEAR:   lv_demi, lv_nct, lv_kzwi1, lv_vencto, lv_days1,
           lv_taxc, lv_item_text, lv_it_amount,
           lv_mwskz, lv_tdlnr, lv_kzwi2, lv_lblni, lv_name1,
           v_inv_doc_no, v_fisc_year.

  lti_j1bnfdoc[]      = ti_j1bnfdoc[].
  lti_j1bnflin[]      = ti_j1bnflin[].


  DATA lv_fatura TYPE char10.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = wa_zentrada_valid-numerodocumento
    IMPORTING
      output = lv_fatura.

* Buscar dados do CTE na entrada da função
  CLEAR lwa_j1bnflin.
  READ TABLE lti_j1bnflin INTO lwa_j1bnflin
                          WITH KEY refkey(10) = wa_vbrp-vbeln.
  IF sy-subrc IS INITIAL.
    CLEAR lwa_j1bnfdoc.
    READ TABLE lti_j1bnfdoc INTO lwa_j1bnfdoc
                            WITH KEY docnum = lwa_j1bnflin-docnum.

    IF sy-subrc IS INITIAL.

      CLEAR wa_zentrada_valid.
      READ TABLE ti_zentrada_valid INTO wa_zentrada_valid
                                   WITH KEY ndoc = lwa_j1bnfdoc-nfenum.  "Numero do Nfe

      IF sy-subrc IS INITIAL.

*        lv_demi = wa_zentrada_valid-nemi.
        DATA lv_vencimento TYPE zhms_tb_fatura-vencimento.
        DATA lv_emissaxml  TYPE zhms_tb_fatura-emissao.
        SELECT SINGLE vencimento emissao FROM zhms_tb_fatura
          INTO (lv_vencimento, lv_emissaxml) WHERE idtitulo         = wa_zentrada_valid-idtitulo
                               AND numerodocumento  = wa_zentrada_valid-numerodocumento.

        lv_vencimento = lv_vencimento(10).
        TRANSLATE lv_vencimento USING ', '.
        TRANSLATE lv_vencimento USING '/ '.
        CONDENSE  lv_vencimento NO-GAPS.
        CONCATENATE lv_vencimento+4(4) lv_vencimento+2(2) lv_vencimento(2) INTO lv_vencto.

        lv_emissaxml = lv_emissaxml(10).
        TRANSLATE lv_emissaxml USING ', '.
        TRANSLATE lv_emissaxml USING '/ '.
        CONDENSE  lv_emissaxml NO-GAPS.
        CONCATENATE lv_emissaxml+4(4) lv_emissaxml+2(2) lv_emissaxml(2) INTO lv_demi.


        WRITE wa_zentrada_valid-nct TO lv_nct.

*        lv_days1 = lv_vencto - sy-datum.
        lv_days1 = lv_vencto - lv_demi.
        IF lv_days1 < 0.
          lv_days1 = 0.
        ENDIF.

        SELECT ebeln ebelp wrbtr lfbnr lfpos
        INTO TABLE ti_ekbe
          FROM ekbe
          FOR ALL ENTRIES IN ti_vfkp
          WHERE ebeln = ti_vfkp-ebeln
            AND zekkn > '00'.


*** Percorre todos os pedidos
        DATA lv_item TYPE rblgp.
        LOOP AT ti_vfkp INTO wa_vfkp WHERE kzwi1 <> 0."stabr = 'C'.
          lv_kzwi1 = lv_kzwi1 + wa_vfkp-kzwi1. " Soma valores - Custos de frete: dados do item
          CLEAR: lv_mwskz, lv_tdlnr, lv_kzwi2, lv_lblni, lv_ebelp.
          SELECT SINGLE mwskz tdlnr kzwi2 lblni ebelp
          FROM vfkp
           INTO ( lv_mwskz, lv_tdlnr, lv_kzwi2, lv_lblni, lv_ebelp )
          WHERE ebeln = wa_vfkp-ebeln.                  "#EC CI_NOFIELD


          IF sy-subrc IS INITIAL.
            lv_taxc = lv_mwskz.
            SELECT SINGLE name1
              FROM lfa1
              INTO lv_name1
              WHERE lifnr = lv_tdlnr.
          ENDIF.
          CLEAR lv_it_amount.
          lv_it_amount = lv_kzwi2.
          LOOP AT ti_ekbe INTO wa_ekbe WHERE ebeln = wa_vfkp-ebeln
                                         AND ebelp = lv_ebelp.
*** Estrutura ITEMDATA
            CLEAR lv_it_amount.
            lv_it_amount = wa_ekbe-wrbtr.
            ADD 1 TO lv_item.
            lwa_itemdata-invoice_doc_item = lv_item.
            lwa_itemdata-po_number        = wa_vfkp-ebeln. "Número da PO processada
            lwa_itemdata-po_item          = lv_ebelp.
            lwa_itemdata-tax_code         = lv_mwskz.        "VFKP-MWSKZ onde VFKP-EBELN = PO processada
            lwa_itemdata-item_amount      = lv_it_amount.    "VFKP-KZWI2 onde VFKP-EBELN = PO processada
            lwa_itemdata-quantity         = 1.
            lwa_itemdata-po_unit          = 'LE'.  "'AU'
            lwa_itemdata-sheet_no         = wa_ekbe-lfbnr.        "VFKP-LBLNI onde VFKP-EBELN = PO processada
            lwa_itemdata-sheet_item       = wa_ekbe-lfpos * 10.

            APPEND lwa_itemdata TO lti_itemdata.
            CLEAR lwa_itemdata.
          ENDLOOP.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.
  CONCATENATE TEXT-050 lv_fatura
            lv_name1
            INTO lv_item_text SEPARATED BY space.

*Se VFKP-MWSKZ (onde VFKP-EBELN = PO processada) encontrada for igual a “Y8”, então preencher a estrutura abaixo.
*Caso contrário não preencher a estrutura WITHTAXDATA
  IF lv_mwskz = 'Y8'.

*Preencher WITHTAXDATA
    lwa_withtax-split_key   = 1.
    lwa_withtax-wi_tax_type = 'IW'.
    lwa_withtax-wi_tax_code = 'IW'.
    lwa_withtax-wi_tax_base = lv_kzwi1.

    APPEND lwa_withtax TO lti_withtax.
    CLEAR lwa_withtax.

  ELSE.
    lwa_withtax-split_key   = 1.
    lwa_withtax-wi_tax_type = 'IW'.
    APPEND lwa_withtax TO lti_withtax.
    CLEAR lwa_withtax.

  ENDIF.

*** Estrutura HEADERDATA
  lwa_headdata-invoice_ind    = 'X'.
  lwa_headdata-doc_type       = 'RE'.
  lwa_headdata-doc_date       = lv_demi.        "Data de emissão do Cte do XML
  lwa_headdata-pstng_date     = sy-datum.       "Data atual
  lwa_headdata-ref_doc_no     = wa_zentrada_valid-numerodocumento.
  lwa_headdata-comp_code      = '6000'.
  lwa_headdata-currency       = 'BRL'.
  lwa_headdata-gross_amount	  = lv_kzwi1.       "VFKP-KZWI1 onde VFKP-EBELN = PO processada
  lwa_headdata-calc_tax_ind   = 'X'.
  lwa_headdata-bline_date     = lv_demi.
*  lwa_headdata-bline_date     = lv_vencto.      "Data de vencimento da fatura do XML
  lwa_headdata-dsct_days1     = lv_days1.       "Número inteiro (Data de vencimento da fatura – Data atual)
  lwa_headdata-del_costs_taxc = lv_taxc.        "VFKP-MWSKZ onde VFKP-EBELN = PO processada
  lwa_headdata-item_text      = lv_item_text.   "VL. REF.FAT. + Numero da Fatura  + LFA1-NAME1 onde VFKP-TDLNR = LFA1-LIFNR e VFKP-EBELN = PO processada

  IF lti_withtax[] IS INITIAL.
    CLEAR:  v_inv_doc_no, v_fisc_year.
    CALL FUNCTION 'BAPI_INCOMINGINVOICE_CREATE'
      EXPORTING
        headerdata       = lwa_headdata
      IMPORTING
        invoicedocnumber = v_inv_doc_no
        fiscalyear       = v_fisc_year
      TABLES
        itemdata         = lti_itemdata
        glaccountdata    = lti_acctdata
        return           = lti_return.

  ELSE.
    CLEAR:  v_inv_doc_no, v_fisc_year.
    CALL FUNCTION 'BAPI_INCOMINGINVOICE_CREATE'
      EXPORTING
        headerdata       = lwa_headdata
      IMPORTING
        invoicedocnumber = v_inv_doc_no
        fiscalyear       = v_fisc_year
      TABLES
        itemdata         = lti_itemdata
        glaccountdata    = lti_acctdata
        withtaxdata      = lti_withtax
        return           = lti_return.
  ENDIF.

*TYPE 1 Tipo  BAPI_MTYPE  CHAR  1 0 Ctg.mens.: S sucesso, E erro, W aviso, I inform., A cancel.
  CLEAR lwa_return.
  LOOP AT lti_return INTO lwa_return.

    " E erro / A cancel
    IF lwa_return-type = 'E' OR lwa_return-type = 'A' OR lwa_return-type = 'X'.

*** Mensagem erro ou cancel
      CLEAR wa_return_erro.
      "Erro na MIRO. PO: xxxxxxxx
      CLEAR v_mensagem.
      CLEAR v_mensagem. v_mensagem = lwa_return-message(50).
      PERFORM pf_atualiza_log  USING wa_zentrada_valid
                                     wa_lfa1-lifnr
                                     v_mensagem
                                     '40'.
    ENDIF.

  ENDLOOP.
  """.
  IF v_inv_doc_no IS NOT INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    DATA lwa_docmn   TYPE zhms_tb_docmn.
    DATA lv_idtitulo TYPE char10.
    DATA lv_numerodocumento TYPE char10.
    DATA lti_docmn          TYPE TABLE OF zhms_tb_docmn.
    DATA lv_seqnr TYPE zhms_tb_docmn-seqnr.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = wa_zentrada_valid-idtitulo
      IMPORTING
        output = lv_idtitulo.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = wa_zentrada_valid-numerodocumento
      IMPORTING
        output = lv_numerodocumento.

    CONCATENATE lv_idtitulo lv_numerodocumento  INTO
    lwa_docmn-chave.
    SELECT mandt
           chave
           seqnr
           mneum
           dcitm
           atitm
           value
           lote
      FROM zhms_tb_docmn
      INTO TABLE lti_docmn WHERE
      chave EQ lwa_docmn-chave
      ORDER BY seqnr DESCENDING.


    READ TABLE lti_docmn INTO lwa_docmn INDEX 1.
    IF sy-subrc EQ 0.
      CLEAR lti_docmn[].
      ADD 1 TO lwa_docmn-seqnr.
      lwa_docmn-mneum = 'INVDOCNO'.
      lwa_docmn-value = v_inv_doc_no.
      APPEND lwa_docmn TO lti_docmn.
      CONCATENATE lv_idtitulo lv_numerodocumento  INTO
      lwa_docmn-chave.
      ADD 1 TO lwa_docmn-seqnr.
      lwa_docmn-mneum = 'FISCALYEAR'.
      lwa_docmn-value = v_fisc_year.
      APPEND lwa_docmn TO lti_docmn.
      MODIFY zhms_tb_docmn FROM TABLE lti_docmn.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.
    ENDIF.
*      PERFORM pf_atualiza_tabela_status_miro USING wa_vfkp-rebel
*                                                   wa_vfkp-fknum.

    PERFORM pf_atualiza_status  USING wa_zentrada_valid
                            wa_vttp-tknum
                            wa_lfa1-lifnr
                            '40'.
    CLEAR v_mensagem.
    CONCATENATE TEXT-049 v_inv_doc_no INTO v_mensagem SEPARATED BY space.
    PERFORM pf_atualiza_log_2    USING wa_zentrada_valid
                                           wa_lfa1-lifnr
                                           v_mensagem
                                           '40'
                                           'I'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PF_ATUALIZA_TABELA_STATUS_MIRO
*&---------------------------------------------------------------------*
*       Atualiza tabela ZHMS_TB_STATUS, após a MIRO
*----------------------------------------------------------------------*
FORM pf_atualiza_tabela_status_miro  USING   p_wa_vfkp_rebel
                                             p_wa_vfkp_fknum.

  DATA: lv_tabix TYPE sy-tabix.

  REFRESH: ti_status.
  CLEAR:   wa_status.

*Buscar na tabela ZHMS_TB_STATUS o registro onde ZHMS_TB_STATU-TKNUM = VFKP-REBEL
*do documento processado
  SELECT *
    FROM zhms_tb_status
    INTO TABLE ti_status
    WHERE tknum = p_wa_vfkp_rebel.

  IF sy-subrc IS INITIAL.
    CLEAR wa_status.
    LOOP AT ti_status INTO wa_status.
      lv_tabix = sy-tabix.
      wa_status-fknum = p_wa_vfkp_fknum.
      wa_status-belnr = v_inv_doc_no.
      wa_status-zstmi = 'C'.

      MODIFY ti_status FROM wa_status INDEX lv_tabix.
      CLEAR wa_status.
    ENDLOOP.
    "Atualizando tabela Z
    MODIFY zhms_tb_status FROM TABLE ti_status.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PF_ESTORNA_MIRO_CTE
*&---------------------------------------------------------------------*
*       Estorna MIRO do CTe
*----------------------------------------------------------------------*
FORM pf_estorna_miro_cte .

  DATA: lv_msg_6(132) TYPE c.

  TYPES: BEGIN OF lty_rbkp,
           belnr TYPE rbkp-belnr,
           gjahr TYPE rbkp-gjahr,
           budat TYPE rbkp-budat,
         END OF lty_rbkp.

  DATA: lti_rbkp TYPE TABLE OF lty_rbkp,
        lwa_rbkp TYPE          lty_rbkp.



  REFRESH: ti_bdcdata, ti_msgs, lti_rbkp.
  CLEAR:   wa_bdcdata, wa_msgs, lwa_rbkp.


  IF NOT ti_status[] IS INITIAL.

    SELECT belnr gjahr budat
      FROM rbkp
      INTO TABLE lti_rbkp
      FOR ALL ENTRIES IN ti_status
      WHERE belnr = ti_status-belnr.     "tem que ter o ano (gjahr)

    IF NOT sy-subrc IS INITIAL.

      "Nenhum documento de faturamento encontrado no SAP
      wa_return-message = TEXT-054.
      APPEND wa_return TO ti_return.
      CLEAR wa_return.

    ENDIF.

    SORT lti_rbkp BY belnr.


    LOOP AT ti_status INTO wa_status.

      CLEAR lwa_rbkp.
      READ TABLE lti_rbkp INTO lwa_rbkp
                          WITH KEY belnr = wa_status-belnr
                          BINARY SEARCH.

      IF sy-subrc IS INITIAL.

        PERFORM pf_insere_bdcdata USING:
              'X'  'SAPLMR1M'         '300'            ,
              ' '  'BDC_CURSOR'       'G_BUDAT'        ,
              ' '  'BDC_OKCODE'       '=CANC'          ,
              ' '  'RBKPV-BELNR'      lwa_rbkp-belnr   ,
              ' '  'RBKPV-GJAHR'      lwa_rbkp-gjahr   ,
              ' '  'UF05A-STGRD'      '01'             ,
              ' '  'G_BUDAT'          lwa_rbkp-budat   .

        DATA lv_mode TYPE char01 VALUE 'N'.
        CALL TRANSACTION 'MR8M' USING  ti_bdcdata
                                MODE lv_mode
                                MESSAGES INTO ti_msgs.

        CLEAR lv_msg_6.

        "Verifica mensagem de sucesso
        CLEAR: wa_msgs.
        READ TABLE ti_msgs INTO wa_msgs WITH KEY msgtyp = 'S'.
*                                                 msgid  = 'VY'
*                                                 msgnr  = '007'.

        IF sy-subrc IS INITIAL.

***4.	Atualizar tabela ZHMS_TB_STATUS
          PERFORM pf_atualiza2_tab_status_miro USING wa_status-fknum
                                                     wa_status-fkpos.

        ELSE.         "Erro

          CLEAR wa_return_erro.
          "Erro no estorno da MIRO: XXXXXXX
          CONCATENATE TEXT-055 wa_status-belnr
                      INTO wa_return_erro-message
                      SEPARATED BY space.
          APPEND wa_return_erro TO ti_return_erro.
          CLEAR wa_return_erro.

        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PF_ATUALIZA2_TAB_STATUS_MIRO
*&---------------------------------------------------------------------*
*       Atualiza tabela Status (ZHMS_TB_STATUS) após execução do
*       estorno da MIRO
*----------------------------------------------------------------------*
FORM pf_atualiza2_tab_status_miro  USING    p_wa_status_fknum
                                            p_wa_status_fkpos.

  DATA: lv_tabix TYPE sy-tabix.

  DATA: lti_status TYPE TABLE OF zhms_tb_status,
        lwa_status TYPE          zhms_tb_status.


  REFRESH: lti_status.

  lti_status[] = ti_status[].

  SORT lti_status BY fknum fkpos.


  CLEAR lwa_status.
  READ TABLE lti_status INTO lwa_status
                        WITH KEY fknum = p_wa_status_fknum
                                 fkpos = p_wa_status_fkpos
                        BINARY SEARCH.
  IF sy-subrc IS INITIAL.

    lv_tabix = sy-tabix.

    CLEAR: lwa_status-fknum, lwa_status-belnr, lwa_status-zstmi.

    MODIFY lti_status FROM lwa_status INDEX lv_tabix.
    CLEAR lwa_status.

    "Atualizando tabela Z
    MODIFY zhms_tb_status FROM TABLE lti_status.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PF_EXECUTA_J1B1N
*&---------------------------------------------------------------------*
*       Executar BAPI para escrituração
*----------------------------------------------------------------------*
FORM pf_executa_j1b1n USING p_wa_vttp_tknum.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PF_ESTRUTURA_BAPI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM pf_estrutura_bapi  USING    p_lwa_status_belnr
                        CHANGING p_erro
                                 p_lifnr.

  DATA: lv_docnum TYPE bapi_j_1bnfdoc-docnum,
        lv_zuonr  TYPE bseg-zuonr, " " 04/08/2019
        lv_wrbtr  TYPE bseg-wrbtr, " " 04/08/2019
        lv_ebeln  TYPE rseg-ebeln,
        lv_ebelp  TYPE rseg-ebelp.

  DATA: lwa_header     TYPE bapi_j_1bnfdoc,
        lwa_item       TYPE bapi_j_1bnflin,
        lwa_header_msg TYPE bapi_j_1bnfftx,
        lwa_refer_msg  TYPE bapi_j_1bnfref,
        lwa_item_tax   TYPE bapi_j_1bnfstx,
        lwa_return     TYPE bapiret2,
        lwa_tb_log     TYPE zhms_tb_log.   " " 04/08/2019

  DATA: lti_item       TYPE TABLE OF bapi_j_1bnflin,
        lti_header_msg TYPE TABLE OF bapi_j_1bnfftx,
        lti_refer_msg  TYPE TABLE OF bapi_j_1bnfref,
        lti_item_tax   TYPE TABLE OF bapi_j_1bnfstx,
        lti_return     TYPE TABLE OF bapiret2.

  DATA: lti_rbkp TYPE TABLE OF ty_rbkp,
        lwa_rbkp TYPE ty_rbkp,
        lti_rseg TYPE TABLE OF ty_rseg,    " " 04/08/2019
        lwa_rseg TYPE ty_rseg.             " " 04/08/2019

  DATA: lv_cte(10)   TYPE c,
        lv_chave     TYPE zhms_tb_docmn-chave,
        lv_aleatorio TYPE bapi_j_1bnfdoc-docnum9,
        lv_tpemis    TYPE bapi_j_1bnfdoc-tpemis,
        lv_ufreme    TYPE zhms_tb_docmn-value,
        lv_ufdest    TYPE zhms_tb_docmn-value.

  CLEAR: lwa_header, lwa_item, lwa_header_msg,
         lwa_refer_msg, lwa_item_tax, lwa_return.

  REFRESH: lti_item, lti_header_msg, lti_refer_msg,
           lti_item_tax, lti_return, lti_rbkp.

  SELECT belnr gjahr xblnr lifnr rmwwr mwskz1
    FROM rbkp
    INTO TABLE lti_rbkp
    WHERE belnr = p_lwa_status_belnr.

  IF NOT lti_rbkp[] IS INITIAL.
    SELECT belnr gjahr buzei ebeln ebelp wrbtr mwskz werks
       FROM rseg INTO TABLE lti_rseg
      WHERE belnr = p_lwa_status_belnr.

    CLEAR lwa_rbkp.
    READ TABLE lti_rbkp INTO lwa_rbkp INDEX 1.

***Estrutura OBJ_HEADER
    lwa_header-mandt  = sy-mandt.

    "Se RBKP-MWSKZ1 onde RBKP-BELNR = BELNR processado for igual a “Y8”, então “YY”. Senão “YC”
*    IF lwa_rbkp-mwskz1  = 'Y8'.
*      lwa_header-nftype = 'YY'.
*      lwa_header-model  = '55'.
*    ELSE.
*      lwa_header-nftype = 'YC'.
*      lwa_header-model  = '57'.
*    ENDIF.

    lwa_header-doctyp	= '4'.

    IF sy-sysid EQ 'DPA'.
      lwa_header-doctyp	= '7'.
    ENDIF.
    lwa_header-direct	= '1'.

*    lwa_header-docdat  = wa_zentrada_valid-nemi.
    lwa_header-pstdat	= sy-datum.     "Data do sistema
    lwa_header-credat	= sy-datum.     "Data do sistema
    lwa_header-cretim	= sy-uzeit.     "Hora do sistema
    lwa_header-crenam	= sy-uname.     "Usuário que executou a função
*    lwa_header-form   = '57'.

*        lwa_header-series =  '1'.
    lwa_header-manual	= 'X'.
    lwa_header-waerk  = 'BRL'.
    lwa_header-bukrs  = '6000'.
*    lwa_header-branch  = '0001'.
    READ TABLE lti_rseg INTO lwa_rseg INDEX 1.
    SELECT SINGLE j_1bbranch
      INTO lwa_header-branch
      FROM t001w
      WHERE werks = lwa_rseg-werks.
    lwa_header-parvw  = 'SP'.
    READ TABLE ti_vfkp INTO wa_vfkp WITH KEY ebeln = lwa_rseg-ebeln.
    IF sy-subrc = 0.
      READ TABLE ti_docmn INTO wa_docmn WITH KEY mneum = 'NCT'
                                                 value = wa_vfkp-postx.
      IF sy-subrc = 0.
        lv_chave = wa_docmn-chave.
        READ TABLE ti_docmn INTO wa_docmn WITH KEY mneum = 'EMITCNPJ'
                                                   chave = lv_chave.
        IF sy-subrc = 0.

          SELECT SINGLE lifnr
            INTO lwa_header-parid
            FROM lfa1
            WHERE lifnr >= '0000000000'
              AND stcd1 = wa_docmn-value.
        ENDIF.
        READ TABLE ti_docmn INTO wa_docmn WITH KEY mneum = 'DHEMI'
                                           chave = lv_chave.
        IF sy-subrc = 0.
          CONCATENATE wa_docmn-value(4) wa_docmn-value+5(2) wa_docmn-value+8(2) INTO lwa_header-docdat.
        ENDIF.
      ENDIF.
    ENDIF.

    IF lwa_header-docdat IS INITIAL.
      lwa_header-docdat	= wa_zentrada_valid-nemi.
    ENDIF.
    IF lwa_header-parid IS INITIAL.
      lwa_header-parid  = lwa_rbkp-lifnr.   "RBKP-LIFNR onde RBKP-BELNR = BELNR processado
    ENDIF.
*          DATA lv_region TYPE lfa1-regio.
*          SELECT SINGLE regio
*          INTO lv_region
*          FROM lfa1
*          WHERE lifnr = lwa_rbkp-lifnr.
*    ENDIF.
    lwa_header-partyp	= 'V'.
    lwa_header-nfe    = 'X'.
    lwa_header-docstat      = '1'.
    lwa_header-xmlvers      = '2.00'.
    lwa_header-code         = '1'.
    lwa_header-cte_strt_lct	= 'SP 3518800'.
    lwa_header-transp_mode  =	'1'.

*** Estrutura OBJ_HEADER_MSG (linha 1)
    lwa_header_msg-mandt    = sy-mandt.
    lwa_header_msg-seqnum   = '01'.
    lwa_header_msg-linnum   = '01'.
    lwa_header_msg-message  =	'TRIBUTADA INTEGRALMENTE'.


    APPEND lwa_header_msg TO lti_header_msg.
    CLEAR lwa_header_msg.

    DATA lv_fat TYPE char10.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = wa_zentrada_valid-numerodocumento
      IMPORTING
        output = lv_fat.
    CLEAR: lv_ebeln, lv_ebelp.
    DATA: lv_item TYPE j_1bitmnum.
    DATA lv_mode TYPE char01 VALUE 'N'.
    LOOP AT lti_rseg INTO lwa_rseg.
      IF lv_ebeln IS INITIAL.
*        DATA: lv_item TYPE j_1bitmnum.

        ADD 10 TO lv_item.
        CLEAR: lwa_item, lti_item, lwa_item_tax, lti_item_tax, lv_chave.
*        IF lwa_rseg-mwskz  = 'Y8'.
*          lwa_header-nftype = 'YY'.
*          lwa_header-model  = '00'.
*          lwa_item-tmiss = 'X'.
*          lwa_header-doctyp = '1'.
*                  lwa_item-itmtyp     = '1'.
*        ELSE.
*          lwa_header-nftype = 'YC'.
*          lwa_header-model  = '57'.
*                  lwa_item-itmtyp     = '01'.
*        ENDIF.
        READ TABLE ti_vfkp INTO wa_vfkp WITH KEY ebeln = lwa_rseg-ebeln.
        IF sy-subrc = 0.
          READ TABLE ti_docmn INTO wa_docmn WITH KEY mneum = 'NCT'
                                                     value = wa_vfkp-postx.
          IF sy-subrc = 0.
            lv_chave = wa_docmn-chave.
            READ TABLE ti_docmn INTO wa_docmn WITH KEY mneum = 'NPROT'
                                                       chave = lv_chave.
            IF sy-subrc = 0.
              lwa_header-authcod = wa_docmn-value.
            ENDIF.
            READ TABLE ti_docmn INTO wa_docmn WITH KEY mneum = 'DHRECBTO'
                                             chave = lv_chave.
            IF sy-subrc = 0.
              CONCATENATE wa_docmn-value(4) wa_docmn-value+5(2) wa_docmn-value+8(2) INTO lwa_header-authdate.
              CONCATENATE wa_docmn-value+11(2) wa_docmn-value+14(2) wa_docmn-value+17(2) INTO lwa_header-authtime.

            ENDIF.
            READ TABLE ti_docmn INTO wa_docmn WITH KEY mneum = 'REMEUF'
                                             chave = lv_chave.
            IF sy-subrc = 0.
              lv_ufreme = wa_docmn-value.
            ENDIF.
            READ TABLE ti_docmn INTO wa_docmn WITH KEY mneum = 'DESTCPAIS'
                                            chave = lv_chave.
            IF sy-subrc = 0.
              lv_ufdest = wa_docmn-value.
            ENDIF.


            READ TABLE ti_docmn INTO wa_docmn WITH KEY mneum = 'VTPREST'
                                             chave = lv_chave.
            IF sy-subrc = 0.
              lwa_rseg-wrbtr = wa_docmn-value.

            ENDIF.
            READ TABLE ti_docmn INTO wa_docmn WITH KEY mneum = 'SERIE'
                                             chave = lv_chave.
            IF sy-subrc = 0.
              lwa_header-series = wa_docmn-value.
            ENDIF.

            READ TABLE ti_docmn INTO wa_docmn WITH KEY mneum = 'DHEMI'
                                   chave = lv_chave.
            IF sy-subrc = 0.
              CONCATENATE wa_docmn-value(4) wa_docmn-value+5(2) wa_docmn-value+8(2) INTO lwa_header-docdat.
            ENDIF.
            lv_aleatorio = lv_chave+35(8).
            lv_tpemis  = lv_chave+34(1).


            lv_aleatorio = lv_chave+35(8).
            lv_tpemis  = lv_chave+34(1).
          ENDIF.
        ENDIF.

        SELECT SINGLE zctet
                 INTO lv_cte
                 FROM zhms_tb_status
                WHERE zfatt = lv_fat
                  AND ebeln = lwa_rseg-ebeln.
        IF sy-subrc EQ 0.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              input  = lv_cte
            IMPORTING
              output = lv_cte.
          UNPACK lv_cte TO lv_cte.
          lwa_header-nfenum  = lv_cte+1(9) . "lwa_rbkp-xblnr.   "RBKP-XBLNR onde RBKP-BELNR = BELNR processado
*        CONCATENATE '135160' lv_cte INTO lwa_header-authcod.    " “135160” + NFENUM acima
        ENDIF.
*** Estrutura OBJ_ITEM
        lwa_item-mandt    = sy-mandt.
        lwa_item-itmnum   = lv_item.
        lwa_item-matkl    = 'MS150'.
        lwa_item-maktx    = 'FRETE'.
        IF lv_ufreme <> lv_ufdest.
          lwa_item-cfop_10  = '2352AA'.
          lwa_item-cfop  = '2352AA'.
        ELSE.
          lwa_item-cfop_10  = '1352AA'.
          lwa_item-cfop  = '1352AA'.
        ENDIF.
        lwa_item-nbm      = 'NBM1'.
        lwa_item-matuse   = '2'.
        lwa_item-reftyp   = 'LI'.

        "BELNR + GJAHR da tabela RBKP onde RBKP-BELNR = BELNR processado
        CONCATENATE lwa_rbkp-belnr lwa_rbkp-gjahr INTO lwa_item-refkey.
        IF sy-subrc EQ 0.
          lwa_item-refitm     = lwa_rseg-buzei.
        ENDIF.
        lwa_item-menge      = '1'.
        lwa_item-meins      = 'LE'.       "AU
        lwa_item-netpr      = lwa_rseg-wrbtr.     " da tabela RBKP onde RBKP-BELNR = BELNR processado
        lwa_item-netwr      = lwa_rseg-wrbtr.     " da tabela RBKP onde RBKP-BELNR = BELNR processado
        lwa_item-taxlw1     =	'IC0'.
        lwa_item-taxlw2     = 'IP1'.
*        lwa_item-itmtyp     = '01'.
        lwa_item-matorg     = '0'.
        lwa_item-incltx	    = 'X'.
        lwa_item-taxlw4	    = '050'.
        lwa_item-taxsi4     = '50'.
        lwa_item-taxlw5     = '050'.
        lwa_item-taxsi5     = '50'.
        lwa_item-meins_trib	= 'LE'.     "AU
        lwa_item-menge_trib	= '1'.

        IF lwa_rseg-mwskz   = 'Y8'.
          lwa_header-nftype = 'YY'.
          lwa_header-model  = '00'.
          lwa_item-tmiss    = 'X'.
          lwa_header-doctyp = '1'.
          lwa_item-itmtyp   = '1'.
          lwa_header-nfnum = lwa_header-nfenum+3(6).
          lwa_header-nfesrv = 'X'.
          CLEAR: lwa_header-nfe,
                 lwa_header-nfenum,
                 lwa_header-authcod,
                 lwa_header-docstat,
                 lwa_header-xmlvers,
                 lwa_header-code,
                 lwa_header-access_key,
                 lwa_header-cte_strt_lct,
                 lwa_header-transp_mode.
        ELSE.
          lwa_header-nftype = 'YC'.
          lwa_header-model  = '57'.
          lwa_item-itmtyp   = '01'.
          lwa_header-doctyp = '4'.
          lwa_item-itmtyp   = '01'.
          lwa_header-partyp  = 'V'.
          lwa_header-nfe    = 'X'.
          lwa_header-docstat      = '1'.
          lwa_header-xmlvers      = '2.00'.
          lwa_header-code         = '1'.
          lwa_header-cte_strt_lct	= 'SP 3518800'.
          lwa_header-transp_mode  =	'1'.

*** Estrutura OBJ_HEADER_MSG (linha 1)
          lwa_header_msg-mandt    = sy-mandt.
          lwa_header_msg-seqnum   = '01'.
          lwa_header_msg-linnum   = '01'.
          lwa_header_msg-message  =	'TRIBUTADA INTEGRALMENTE'.


        ENDIF.

        APPEND lwa_item TO lti_item.
        CLEAR lwa_item.

*** Estrutura OBJ_ITEM_TAX (linha 1 )
        IF sy-subrc EQ 0.
          CLEAR lv_wrbtr.
          CLEAR lv_zuonr.
          CONCATENATE lwa_rseg-ebeln lwa_rseg-buzei INTO lv_zuonr.

          IF sy-subrc EQ 0.
            lwa_item_tax-mandt     = sy-mandt.
            lwa_item_tax-itmnum    = lv_item.
            lwa_item_tax-base      = lwa_rseg-wrbtr.
            lwa_item_tax-basered1  = '100'.

            IF lwa_rseg-mwskz EQ 'Y8'.
              lwa_item_tax-taxtyp = 'ISF3'.
            ELSE.
              lwa_item_tax-taxtyp = 'ICM2'.
            ENDIF .

            CASE lwa_rseg-mwskz.
              WHEN 'Y8'.
                lwa_item_tax-rate = '5.0'.
              WHEN 'YK'.
                lwa_item_tax-rate = '7.0'.
              WHEN 'YL'.
                lwa_item_tax-rate = '12.0'.
              WHEN OTHERS.
            ENDCASE.

            lv_wrbtr = ( lwa_item_tax-base * lwa_item_tax-rate / 100 ).
            lwa_item_tax-taxval    = lv_wrbtr.

            APPEND lwa_item_tax TO lti_item_tax.
            CLEAR lwa_item_tax.
          ENDIF.

*** Estrutura OBJ_ITEM_TAX (linha 2)
          CLEAR lv_wrbtr.
          CLEAR lv_zuonr.
          CONCATENATE lwa_rseg-ebeln '00001' INTO lv_zuonr.

          IF sy-subrc EQ 0.
            lwa_item_tax-mandt     = sy-mandt.
            lwa_item_tax-itmnum    = lv_item.
            lwa_item_tax-base      = lwa_rseg-wrbtr.
            lwa_item_tax-basered1  = '100'.
            lwa_item_tax-taxtyp    = 'ICOF'.
            lwa_item_tax-rate      = '7.6'.
            lv_wrbtr = ( lwa_item_tax-base * lwa_item_tax-rate / 100 ).
            lwa_item_tax-taxval    = lv_wrbtr.



            APPEND lwa_item_tax TO lti_item_tax.
            CLEAR lwa_item_tax.

            lwa_item_tax-mandt     = sy-mandt.
            lwa_item_tax-itmnum    = lv_item.
            lwa_item_tax-base      = lwa_rseg-wrbtr.
            lwa_item_tax-basered1  = '100'.
            lwa_item_tax-taxtyp    = 'IPIS'.
            lwa_item_tax-rate      = '1.65'.
            lv_wrbtr = ( lwa_item_tax-base * lwa_item_tax-rate / 100 ).
            lwa_item_tax-taxval    = lv_wrbtr.

            APPEND lwa_item_tax TO lti_item_tax.
            CLEAR lwa_item_tax.

            CLEAR: lv_docnum.

            CALL FUNCTION 'BAPI_J_1B_NF_CREATEFROMDATA'
              EXPORTING
                obj_header     = lwa_header
              IMPORTING
                e_docnum       = lv_docnum
              TABLES
                obj_item       = lti_item
                obj_item_tax   = lti_item_tax
                obj_header_msg = lti_header_msg
                obj_refer_msg  = lti_refer_msg
                return         = lti_return.

            LOOP AT lti_return INTO lwa_return.

              p_lifnr = lwa_rbkp-lifnr.
              IF lwa_return-type EQ 'E'.

                CLEAR v_mensagem. v_mensagem = lwa_return-message.
                PERFORM pf_atualiza_log  USING wa_zentrada_valid
                                               wa_lfa1-lifnr
                                               v_mensagem
                                               '50'.
              ENDIF.

            ENDLOOP.

            IF lv_docnum IS NOT INITIAL.

              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                EXPORTING
                  wait = 'X'.

              REFRESH: ti_bdcdata, ti_msgs.
              CLEAR:   wa_bdcdata, wa_msgs.

              PERFORM pf_insere_bdcdata USING:
                    'X'  'SAPMJ1B1'         '1100'             ,
                    ' '  'BDC_CURSOR'       'J_1BDYDOC-DOCNUM' ,
                    ' '  'BDC_OKCODE'       '/00'          ,
                    ' '  'J_1BDYDOC-DOCNUM' lv_docnum  .

              PERFORM pf_insere_bdcdata USING:
                    'X'  'SAPLJ1BB2'         '2000'             ,
                    ' '  'BDC_OKCODE'       '=TAB8'          .

              PERFORM pf_insere_bdcdata USING:
                      'X'  'SAPLJ1BB2'         '2000'           ,
                      ' '  'BDC_CURSOR'       'J_1BNFE_DOCNUM9_DIVIDED-TPEMIS'   ,
                      ' '  'BDC_OKCODE'       '/00'        ,
                      ' '  'J_1BNFE_DOCNUM9_DIVIDED-TPEMIS'  lv_tpemis  ,
                      ' '  'J_1BNFE_DOCNUM9_DIVIDED-DOCNUM8' lv_aleatorio  .

              PERFORM pf_insere_bdcdata USING:
                      'X'  'SAPLJ1BB2'         '2000'           ,
                      ' '  'BDC_OKCODE'       '=SAVE'        .

              CALL TRANSACTION 'J1B2N' USING  ti_bdcdata
                                      MODE lv_mode
                                      MESSAGES INTO ti_msgs.

              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = lv_cte
                IMPORTING
                  output = lv_cte.
              CLEAR v_cte_esct. v_cte_esct = lv_cte.
              CLEAR v_docnum. v_docnum = lv_docnum.
              CLEAR v_pedido. v_pedido = lwa_rseg-ebeln.
              PERFORM pf_atualiza_status  USING wa_zentrada_valid
                                            wa_vttp_vbrp-tknum
                                            wa_lfa1-lifnr
                                            '50'.

              CLEAR v_mensagem.
              CONCATENATE  TEXT-074 lv_docnum TEXT-073 INTO v_mensagem SEPARATED BY space.
              PERFORM pf_atualiza_log_2    USING wa_zentrada_valid
                                                     wa_lfa1-lifnr
                                                     v_mensagem
                                                     '50'
                                                     'S'.
            ENDIF.
          ENDIF.
        ENDIF.
        lv_ebeln = lwa_rseg-ebeln.
        lv_ebelp = lwa_rseg-ebelp.

      ELSE.
        IF lv_ebeln <> lwa_rseg-ebeln.


          ADD 10 TO lv_item.
          CLEAR: lwa_item, lti_item, lwa_item_tax, lti_item_tax, lv_chave.

*          IF lwa_rseg-mwskz  = 'Y8'.
*            lwa_header-nftype = 'YY'.
*            lwa_header-model  = '00'.
*            lwa_header-doctyp = '1'.
*            lwa_item-tmiss = 'X'.
*                    lwa_item-itmtyp     = '1'.
*
*          ELSE.
*            lwa_header-nftype = 'YC'.
*            lwa_header-model  = '57'.
*                    lwa_item-itmtyp     = '01'.
*
*          ENDIF.
          READ TABLE ti_vfkp INTO wa_vfkp WITH KEY ebeln = lwa_rseg-ebeln.
          IF sy-subrc = 0.
            READ TABLE ti_docmn INTO wa_docmn WITH KEY mneum = 'NCT'
                                                       value = wa_vfkp-postx.
            IF sy-subrc = 0.
              lv_chave = wa_docmn-chave.
              READ TABLE ti_docmn INTO wa_docmn WITH KEY mneum = 'NPROT'
                                                         chave = lv_chave.
              IF sy-subrc = 0.
                lwa_header-authcod = wa_docmn-value.
              ENDIF.
              READ TABLE ti_docmn INTO wa_docmn WITH KEY mneum = 'DHRECBTO'
                                               chave = lv_chave.
              IF sy-subrc = 0.
                CONCATENATE wa_docmn-value(4) wa_docmn-value+5(2) wa_docmn-value+8(2) INTO lwa_header-authdate.
                CONCATENATE wa_docmn-value+11(2) wa_docmn-value+14(2) wa_docmn-value+17(2) INTO lwa_header-authtime.

              ENDIF.



              READ TABLE ti_docmn INTO wa_docmn WITH KEY mneum = 'REMEUF'
                                               chave = lv_chave.
              IF sy-subrc = 0.
                lv_ufreme = wa_docmn-value.
              ENDIF.
              READ TABLE ti_docmn INTO wa_docmn WITH KEY mneum = 'DESTCPAIS'
                                              chave = lv_chave.
              IF sy-subrc = 0.
                lv_ufdest = wa_docmn-value.
              ENDIF.


              READ TABLE ti_docmn INTO wa_docmn WITH KEY mneum = 'VTPREST'
                                               chave = lv_chave.
              IF sy-subrc = 0.
                lwa_rseg-wrbtr = wa_docmn-value.

              ENDIF.
              READ TABLE ti_docmn INTO wa_docmn WITH KEY mneum = 'SERIE'
                                               chave = lv_chave.
              IF sy-subrc = 0.
                lwa_header-series = wa_docmn-value.
              ENDIF.

              READ TABLE ti_docmn INTO wa_docmn WITH KEY mneum = 'DHEMI'
                                   chave = lv_chave.
              IF sy-subrc = 0.
                CONCATENATE wa_docmn-value(4) wa_docmn-value+5(2) wa_docmn-value+8(2) INTO lwa_header-docdat.
              ENDIF.

              lv_aleatorio = lv_chave+35(8).
              lv_tpemis  = lv_chave+34(1).


              lv_aleatorio = lv_chave+35(8).
              lv_tpemis  = lv_chave+34(1).
            ENDIF.
          ENDIF.

          SELECT SINGLE zctet
                   INTO lv_cte
                   FROM zhms_tb_status
                  WHERE zfatt = lv_fat
                    AND ebeln = lwa_rseg-ebeln.
          IF sy-subrc EQ 0.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
              EXPORTING
                input  = lv_cte
              IMPORTING
                output = lv_cte.
            UNPACK lv_cte TO lv_cte.
            lwa_header-nfenum  = lv_cte+1(9) . "lwa_rbkp-xblnr.   "RBKP-XBLNR onde RBKP-BELNR = BELNR processado
*        CONCATENATE '135160' lv_cte INTO lwa_header-authcod.    " “135160” + NFENUM acima
          ENDIF.
*** Estrutura OBJ_ITEM
          lwa_item-mandt    = sy-mandt.
          lwa_item-itmnum   = lv_item.
          lwa_item-matkl    = 'MS150'.
          lwa_item-maktx    = 'FRETE'.
          IF lv_ufreme <> lv_ufdest.
            lwa_item-cfop_10  = '2352AA'.
            lwa_item-cfop  = '2352AA'.
          ELSE.
            lwa_item-cfop_10  = '1352AA'.
            lwa_item-cfop  = '1352AA'.
          ENDIF.
          lwa_item-nbm      = 'NBM1'.
          lwa_item-matuse   = '2'.
          lwa_item-reftyp   = 'LI'.

          "BELNR + GJAHR da tabela RBKP onde RBKP-BELNR = BELNR processado
          CONCATENATE lwa_rbkp-belnr lwa_rbkp-gjahr INTO lwa_item-refkey.
          IF sy-subrc EQ 0.
            lwa_item-refitm     = lwa_rseg-buzei.
          ENDIF.
          lwa_item-menge      = '1'.
          lwa_item-meins      = 'LE'.       "AU
          lwa_item-netpr      = lwa_rseg-wrbtr.     " da tabela RBKP onde RBKP-BELNR = BELNR processado
          lwa_item-netwr      = lwa_rseg-wrbtr.     " da tabela RBKP onde RBKP-BELNR = BELNR processado
          lwa_item-taxlw1     =	'IC0'.
          lwa_item-taxlw2     = 'IP1'.
*          lwa_item-itmtyp     = '01'.
          lwa_item-matorg     = '0'.
          lwa_item-incltx	    = 'X'.
          lwa_item-taxlw4	    = '050'.
          lwa_item-taxsi4     = '50'.
          lwa_item-taxlw5     = '050'.
          lwa_item-taxsi5     = '50'.
          lwa_item-meins_trib	= 'LE'.     "AU
          lwa_item-menge_trib	= '1'.

          IF lwa_rseg-mwskz   = 'Y8'.
            lwa_header-nftype = 'YY'.
            lwa_header-model  = '00'.
            lwa_item-tmiss    = 'X'.
            lwa_header-doctyp = '1'.
            lwa_item-itmtyp   = '1'.
            lwa_header-nfnum = lwa_header-nfenum+3(6).
            lwa_header-nfesrv = 'X'.
            CLEAR: lwa_header-nfe,
                   lwa_header-nfenum,
                   lwa_header-authcod,
                   lwa_header-docstat,
                   lwa_header-xmlvers,
                   lwa_header-code,
                   lwa_header-access_key,
                   lwa_header-cte_strt_lct,
                   lwa_header-transp_mode.
          ELSE.
            lwa_header-nftype = 'YC'.
            lwa_header-model  = '57'.
            lwa_item-itmtyp   = '01'.
            lwa_header-doctyp = '4'.
            lwa_item-itmtyp   = '01'.
            lwa_header-partyp  = 'V'.
            lwa_header-nfe    = 'X'.
            lwa_header-docstat      = '1'.
            lwa_header-xmlvers      = '2.00'.
            lwa_header-code         = '1'.
            lwa_header-cte_strt_lct	= 'SP 3518800'.
            lwa_header-transp_mode  =	'1'.

*** Estrutura OBJ_HEADER_MSG (linha 1)
            lwa_header_msg-mandt    = sy-mandt.
            lwa_header_msg-seqnum   = '01'.
            lwa_header_msg-linnum   = '01'.
            lwa_header_msg-message  =	'TRIBUTADA INTEGRALMENTE'.


          ENDIF.

          APPEND lwa_item TO lti_item.
          CLEAR lwa_item.

*** Estrutura OBJ_ITEM_TAX (linha 1 )
          IF sy-subrc EQ 0.
            CLEAR lv_wrbtr.
            CLEAR lv_zuonr.
            CONCATENATE lwa_rseg-ebeln lwa_rseg-buzei INTO lv_zuonr.

            IF sy-subrc EQ 0.
              lwa_item_tax-mandt     = sy-mandt.
              lwa_item_tax-itmnum    = lv_item.
              lwa_item_tax-base      = lwa_rseg-wrbtr.
              lwa_item_tax-basered1  = '100'.

              IF lwa_rseg-mwskz EQ 'Y8'.
                lwa_item_tax-taxtyp = 'ISF3'.
              ELSE.
                lwa_item_tax-taxtyp = 'ICM2'.
              ENDIF .

              CASE lwa_rseg-mwskz.
                WHEN 'Y8'.
                  lwa_item_tax-rate = '5.0'.
                WHEN 'YK'.
                  lwa_item_tax-rate = '7.0'.
                WHEN 'YL'.
                  lwa_item_tax-rate = '12.0'.
                WHEN OTHERS.
              ENDCASE.

              lv_wrbtr = ( lwa_item_tax-base * lwa_item_tax-rate / 100 ).
              lwa_item_tax-taxval    = lv_wrbtr.

              APPEND lwa_item_tax TO lti_item_tax.
              CLEAR lwa_item_tax.
            ENDIF.

*** Estrutura OBJ_ITEM_TAX (linha 2)
            CLEAR lv_wrbtr.
            CLEAR lv_zuonr.
            CONCATENATE lwa_rseg-ebeln '00001' INTO lv_zuonr.

            IF sy-subrc EQ 0.
              lwa_item_tax-mandt     = sy-mandt.
              lwa_item_tax-itmnum    = lv_item.
              lwa_item_tax-base      = lwa_rseg-wrbtr.
              lwa_item_tax-basered1  = '100'.
              lwa_item_tax-taxtyp    = 'ICOF'.
              lwa_item_tax-rate      = '7.6'.
              lv_wrbtr = ( lwa_item_tax-base * lwa_item_tax-rate / 100 ).
              lwa_item_tax-taxval    = lv_wrbtr.



              APPEND lwa_item_tax TO lti_item_tax.
              CLEAR lwa_item_tax.

              lwa_item_tax-mandt     = sy-mandt.
              lwa_item_tax-itmnum    = lv_item.
              lwa_item_tax-base      = lwa_rseg-wrbtr.
              lwa_item_tax-basered1  = '100'.
              lwa_item_tax-taxtyp    = 'IPIS'.
              lwa_item_tax-rate      = '1.65'.
              lv_wrbtr = ( lwa_item_tax-base * lwa_item_tax-rate / 100 ).
              lwa_item_tax-taxval    = lv_wrbtr.

              APPEND lwa_item_tax TO lti_item_tax.
              CLEAR lwa_item_tax.

              CLEAR: lv_docnum.

              CALL FUNCTION 'BAPI_J_1B_NF_CREATEFROMDATA'
                EXPORTING
                  obj_header     = lwa_header
                IMPORTING
                  e_docnum       = lv_docnum
                TABLES
                  obj_item       = lti_item
                  obj_item_tax   = lti_item_tax
                  obj_header_msg = lti_header_msg
                  obj_refer_msg  = lti_refer_msg
                  return         = lti_return.

              LOOP AT lti_return INTO lwa_return.

                p_lifnr = lwa_rbkp-lifnr.
                IF lwa_return-type EQ 'E'.

                  CLEAR v_mensagem. v_mensagem = lwa_return-message.
                  PERFORM pf_atualiza_log  USING wa_zentrada_valid
                                                 wa_lfa1-lifnr
                                                 v_mensagem
                                                 '50'.
                ENDIF.

              ENDLOOP.

              IF lv_docnum IS NOT INITIAL.

                CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                  EXPORTING
                    wait = 'X'.

                REFRESH: ti_bdcdata, ti_msgs.
                CLEAR:   wa_bdcdata, wa_msgs.

                PERFORM pf_insere_bdcdata USING:
                      'X'  'SAPMJ1B1'         '1100'             ,
                      ' '  'BDC_CURSOR'       'J_1BDYDOC-DOCNUM' ,
                      ' '  'BDC_OKCODE'       '/00'          ,
                      ' '  'J_1BDYDOC-DOCNUM' lv_docnum  .

                PERFORM pf_insere_bdcdata USING:
                      'X'  'SAPLJ1BB2'         '2000'             ,
                      ' '  'BDC_OKCODE'       '=TAB8'          .

                PERFORM pf_insere_bdcdata USING:
                        'X'  'SAPLJ1BB2'         '2000'           ,
                        ' '  'BDC_CURSOR'       'J_1BNFE_DOCNUM9_DIVIDED-TPEMIS'   ,
                        ' '  'BDC_OKCODE'       '/00'        ,
                        ' '  'J_1BNFE_DOCNUM9_DIVIDED-TPEMIS'  lv_tpemis  ,
                        ' '  'J_1BNFE_DOCNUM9_DIVIDED-DOCNUM8' lv_aleatorio  .

                PERFORM pf_insere_bdcdata USING:
                        'X'  'SAPLJ1BB2'         '2000'           ,
                        ' '  'BDC_OKCODE'       '=SAVE'        .

                CALL TRANSACTION 'J1B2N' USING  ti_bdcdata
                                        MODE lv_mode
                                        MESSAGES INTO ti_msgs.

                CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                  EXPORTING
                    input  = lv_cte
                  IMPORTING
                    output = lv_cte.
                CLEAR v_cte_esct. v_cte_esct = lv_cte.
                CLEAR v_docnum. v_docnum = lv_docnum.
                CLEAR v_pedido. v_pedido = lwa_rseg-ebeln.
                PERFORM pf_atualiza_status  USING wa_zentrada_valid
                                              wa_vttp_vbrp-tknum
                                              wa_lfa1-lifnr
                                              '50'.

                CLEAR v_mensagem.
                CONCATENATE  TEXT-074 lv_docnum TEXT-073 INTO v_mensagem SEPARATED BY space.
                PERFORM pf_atualiza_log_2    USING wa_zentrada_valid
                                                       wa_lfa1-lifnr
                                                       v_mensagem
                                                       '50'
                                                       'S'.
              ENDIF.
            ENDIF.
          ENDIF.
          lv_ebeln = lwa_rseg-ebeln.
          lv_ebelp = lwa_rseg-ebelp.
        ELSE.
          lv_ebeln = lwa_rseg-ebeln.
          lv_ebelp = lwa_rseg-ebelp.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PF_ATUALIZA_LOG
*&---------------------------------------------------------------------*
*       Atualiza tabela ZHMS_TB_LOG
*----------------------------------------------------------------------*
FORM pf_atualiza_log  USING    p_zentrada_valid TYPE zent_valida_dt
                               p_lifnr          TYPE lifnr
                               p_message        TYPE char50
                               p_fase           TYPE char02.

  IF p_zentrada_valid-numerodocumento IS NOT INITIAL.
**** Atualiza ZHMS_TB_LOG
    wa_tb_log-zfatt = p_zentrada_valid-numerodocumento.
    wa_tb_log-tdlnr = p_lifnr.
    wa_tb_log-erdat = sy-datum.
    wa_tb_log-erzet = sy-uzeit.
    wa_tb_log-zctet = p_zentrada_valid-nct.
    wa_tb_log-ernam = sy-uname.
    wa_tb_log-zfase = p_fase.
    wa_tb_log-zerro = p_message.
    APPEND wa_tb_log TO ti_tb_log.
    CLEAR wa_tb_log.
  ENDIF.

*** Atualiza ZHMS_TB_DOCLOG - a tabela ti_return será movido para o processamento standard do HomSoft
  wa_return-type       = 'E'.
  wa_return-code       = '00001'.
  wa_return-message_v1 = p_message.
  APPEND wa_return TO ti_return.
  CLEAR wa_return.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  PF_ATUALIZA_SATUS
*&---------------------------------------------------------------------*
*       Atualiza tabela ZHMS_TB_STATUS
*----------------------------------------------------------------------*
FORM pf_atualiza_status  USING p_zentrada_valid TYPE zent_valida_dt
                               p_tknum          TYPE vttp-tknum
                               p_lifnr          TYPE lifnr
                               p_fase           TYPE char02.
  DATA lv_tdlnr   TYPE vttk-tdlnr.
  DATA lti_status TYPE STANDARD TABLE OF zhms_tb_status.
  DATA: lti_vfkp   TYPE TABLE OF ty_vfkp,
        lwa_vfkp   TYPE ty_vfkp,
        lv_cont(4) TYPE i.
  DATA: lv_zctet TYPE zhms_tb_status-zctet. " 04/10/2019
  FIELD-SYMBOLS: <fs_status> TYPE zhms_tb_status.
  IF p_zentrada_valid-numerodocumento IS NOT INITIAL.
    CASE p_fase.

      WHEN '10'.
        wa_tb_status-zctet   = p_zentrada_valid-nct.
        wa_tb_status-tknum   = p_tknum.
        wa_tb_status-zfatt   = p_zentrada_valid-numerodocumento.
        wa_tb_status-tdlnr   = p_lifnr.
        wa_tb_status-erdat   = sy-datum .
        wa_tb_status-ernam   = sy-uname.
        wa_tb_status-zdctt   = p_zentrada_valid-nemi .
        SELECT SINGLE tdlnr INTO lv_tdlnr  FROM vttk WHERE tknum = p_tknum.
        IF sy-subrc EQ 0.
          IF lv_tdlnr <= 3.
            wa_tb_status-zstdt   = 'A' .
          ELSE.
            wa_tb_status-zstdt   = 'C'.
          ENDIF.
        ENDIF.
        MODIFY zhms_tb_status FROM wa_tb_status.
        COMMIT WORK AND WAIT.

      WHEN '20'.
        SELECT *
*               mandt
*               zctet
*               tknum
*               zfatt
*               tdlnr
*               erdat
*               ernam
*               zdctt
*               zstdt
*               fknum
*               fkpos
*               zstcf
*               ebeln
*               zstpo
*               BELNR
*               ZBELNRES
*               ZSTMI
*               DOCNUM
*               NFENUM
*               ZSTNF
*               ZDOCNUMES
*               ZMIGO
                FROM zhms_tb_status
                INTO TABLE ti_tb_status_ax
               WHERE tknum = p_tknum
                 AND zfatt = wa_zentrada_valid-numerodocumento.

        IF sy-subrc EQ 0.
          DO 20 TIMES.
            SELECT fknum fkpos rebel stfre stabr kzwi1 ebeln
               FROM vfkp
               INTO TABLE lti_vfkp
               WHERE rebel = p_tknum.
            IF sy-subrc EQ 0.
              EXIT.
            ENDIF.
          ENDDO.
          IF sy-subrc EQ 0.
            lv_cont = 1.
            LOOP AT lti_vfkp INTO lwa_vfkp.
              READ TABLE ti_tb_status_ax INTO wa_tb_status INDEX lv_cont.
              wa_tb_status-fknum  = lwa_vfkp-fknum. " Custo de Frete
              wa_tb_status-fkpos  = lwa_vfkp-fkpos. " Item Custo de Frete
              wa_tb_status-zstcf  = lwa_vfkp-stfre. " Status

              APPEND wa_tb_status TO lti_status.
              lv_cont = lv_cont + 1.
            ENDLOOP.
            MODIFY zhms_tb_status FROM TABLE lti_status.
            COMMIT WORK AND WAIT.
          ENDIF.
        ENDIF.

      WHEN '30'.
        lv_zctet = p_zentrada_valid-nct. "04/10/2019
        SELECT fknum fkpos rebel stfre stabr kzwi1 ebeln
           FROM vfkp
           INTO TABLE lti_vfkp
           WHERE rebel = p_tknum
             AND fknum = wa_vfkp-fknum
             AND fkpos = wa_vfkp-fkpos.
        IF sy-subrc EQ 0.
          LOOP AT lti_vfkp INTO lwa_vfkp.
            SELECT SINGLE *
*               mandt
*               zctet
*               tknum
*               zfatt
*               tdlnr
*               erdat
*               ernam
*               zdctt
*               zstdt
*               fknum
*               fkpos
*               zstcf
*               ebeln
*               zstpo
*               BELNR
*               ZBELNRES
*               ZSTMI
*               DOCNUM
*               NFENUM
*               ZSTNF
*               ZDOCNUMES
*               ZMIGO
                    FROM zhms_tb_status
                    INTO wa_tb_status
                   WHERE zctet = lv_zctet   "   p_zentrada_valid-nct
                     AND tknum = p_tknum
                     AND fknum = wa_vfkp-fknum
                     AND zfatt = wa_zentrada_valid-numerodocumento.
*                     AND fkpos = wa_vfkp-fkpos.

            IF sy-subrc EQ 0 AND
               lwa_vfkp-ebeln IS NOT INITIAL.
              wa_tb_status-ebeln  = lwa_vfkp-ebeln. "   Pedido
              wa_tb_status-zstpo  = 'C'.
              APPEND wa_tb_status TO lti_status.
              CLEAR wa_tb_status .
            ENDIF.
          ENDLOOP.
          MODIFY zhms_tb_status FROM TABLE lti_status.
          COMMIT WORK AND WAIT.
        ENDIF.

      WHEN 40.
        lv_zctet = p_zentrada_valid-nct.
        SELECT *
*              mandt
*               zctet
*               tknum
*               zfatt
*               tdlnr
*               erdat
*               ernam
*               zdctt
*               zstdt
*               fknum
*               fkpos
*               zstcf
*               ebeln
*               zstpo
*               BELNR
*               ZBELNRES
*               ZSTMI
*               DOCNUM
*               NFENUM
*               ZSTNF
*               ZDOCNUMES
*               ZMIGO
                 FROM zhms_tb_status
                 INTO TABLE lti_status
                WHERE zfatt = p_zentrada_valid-numerodocumento.
*                  AND zctet = lv_zctet.
        IF sy-subrc EQ 0.
          SELECT fknum fkpos rebel stfre stabr kzwi1 ebeln
             FROM vfkp
             INTO TABLE lti_vfkp
             WHERE rebel = p_tknum.
          IF sy-subrc EQ 0.
            LOOP AT lti_status ASSIGNING <fs_status>.
              <fs_status>-belnr  = v_inv_doc_no.
              <fs_status>-zstmi  = 'C'.
*              APPEND wa_tb_status TO lti_status.
            ENDLOOP.
            MODIFY zhms_tb_status FROM TABLE lti_status.
            COMMIT WORK AND WAIT.
          ENDIF.
        ENDIF.

      WHEN '50'.

        DO 20 TIMES.
          SELECT SINGLE *
*               mandt
*               zctet
*               tknum
*               zfatt
*               tdlnr
*               erdat
*               ernam
*               zdctt
*               zstdt
*               fknum
*               fkpos
*               zstcf
*               ebeln
*               zstpo
*               BELNR
*               ZBELNRES
*               ZSTMI
*               DOCNUM
*               NFENUM
*               ZSTNF
*               ZDOCNUMES
*               ZMIGO
                  FROM zhms_tb_status
                  INTO wa_tb_status
                 WHERE zctet = v_cte_esct
                   AND ebeln = v_pedido.
          IF sy-subrc EQ 0.
            EXIT.
          ENDIF.
        ENDDO.
        IF sy-subrc EQ 0.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              input  = v_cte_esct
            IMPORTING
              output = v_cte_esct.
          wa_tb_status-docnum = v_docnum.
          wa_tb_status-nfenum = v_cte_esct. "   Pedido
          wa_tb_status-zstnf  = 'C'.
          MODIFY zhms_tb_status FROM wa_tb_status.
          COMMIT WORK AND WAIT.
        ENDIF.
    ENDCASE.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PF_ATUALIZA_LOG_SUCESSO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_ZENTRADA_VALID  text
*      -->P_WA_LFA1_LIFNR  text
*      -->P_LV_MENSAGEM  text
*      -->P_0973   text
*      -->P_0974   text
*----------------------------------------------------------------------*
FORM pf_atualiza_log_2  USING          p_zentrada_valid TYPE zent_valida_dt
                                       p_lifnr          TYPE lifnr
                                       p_message        TYPE char50
                                       p_fase           TYPE char02
                                       p_tipo           TYPE char1.
  wa_return-type       = p_tipo.
  wa_return-code       = '00001'.
  wa_return-message_v1 = p_message.
  APPEND wa_return TO ti_return.
  CLEAR wa_return.

  IF p_zentrada_valid-numerodocumento IS NOT INITIAL.
**** Atualiza ZHMS_TB_LOG
    wa_tb_log-zfatt = p_zentrada_valid-numerodocumento.
    wa_tb_log-tdlnr = p_lifnr.
    wa_tb_log-erdat = sy-datum.
    wa_tb_log-erzet = sy-uzeit.
    wa_tb_log-zctet = p_zentrada_valid-nct.
    wa_tb_log-ernam = sy-uname.
    wa_tb_log-zfase = p_fase.
    wa_tb_log-zerro = p_message.
    APPEND wa_tb_log TO ti_tb_log.
    CLEAR wa_tb_log.
  ENDIF.

ENDFORM.
