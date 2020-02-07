FUNCTION zhms_estorno_vi02.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(FLWDOC) TYPE  ZHMS_TB_FLWDOC
*"  TABLES
*"      LT_RETURN STRUCTURE  BAPIRET2 OPTIONAL
*"----------------------------------------------------------------------

  TYPES: BEGIN OF ltype_fatura,
           idtitulo        TYPE zhms_tb_fatura-idtitulo,
           numerodocumento TYPE zhms_tb_fatura-numerodocumento,
           chave           TYPE zhms_tb_fatura-chave,
           chave_fat       TYPE zhms_tb_fatura-chave_fat,
           numdoc          TYPE zhms_tb_status-zfatt,
           exti1           TYPE vfkp-exti1,  "cct
           exti2           TYPE vfkp-exti2,  "nct
         END OF ltype_fatura.

  TYPES: BEGIN OF ltype_vfkp,
           fknum TYPE vfkp-fknum,
           fkpos TYPE vfkp-fkpos,
           netwr TYPE vfkp-netwr,
           postx TYPE vfkp-postx,
           exti1 TYPE vfkp-exti1, "CCT
           exti2 TYPE vfkp-exti2, "NCT
         END OF ltype_vfkp.

  TYPES: BEGIN OF ltype_status,
           zctet      TYPE zhms_tb_status-zctet,
           tknum      TYPE zhms_tb_status-tknum,
           zfatt      TYPE zhms_tb_status-zfatt,
           fknum      TYPE zhms_tb_status-fknum,
           zstcf      TYPE zhms_tb_status-zstcf,
           estorno(2) TYPE c,
         END OF ltype_status.

  DATA: lt_vfkp           TYPE TABLE OF ltype_vfkp,
        lt_fatura         TYPE TABLE OF ltype_fatura,
        lt_status         TYPE TABLE OF ltype_status,
        lt_zhms_tb_status TYPE STANDARD TABLE OF zhms_tb_status.
  DATA: lw_vfkp           LIKE LINE OF lt_vfkp,
        lw_fatura         LIKE LINE OF lt_fatura,
        lw_status         LIKE LINE OF lt_status,
        lw_zhms_tb_status LIKE LINE OF lt_zhms_tb_status.

  DATA: lv_zfatt(10) TYPE n.
  DATA: ti_bdcdata TYPE STANDARD TABLE OF  bdcdata,
        ti_msgs    TYPE STANDARD TABLE OF  bdcmsgcoll,
        wa_bdcdata TYPE bdcdata,
        wa_msgs    TYPE bdcmsgcoll,
        wa_mensg   TYPE message.

  DATA: lv_item           TYPE vfkn-fkpos,
        lv_vfkn_kposn(18) TYPE c,
        lv_vfkp_fkpos(18) TYPE c,
        lv_postx          TYPE vfkp-postx,
        lv_msg(100)       TYPE c.

  SELECT idtitulo numerodocumento chave chave_fat numerodocumento
           FROM zhms_tb_fatura
           INTO TABLE lt_fatura
           WHERE chave_fat = flwdoc-chave.
  CHECK: sy-subrc = 0.

*  FIELD-SYMBOLS <fatura> TYPE ltype_fatura.
*  LOOP AT lt_fatura ASSIGNING <fatura>.
*    <fatura>-numdoc = <fatura>-numerodocumento.
*    SELECT SINGLE value INTO <fatura>-exti1
*           FROM zhms_tb_docmn
*           WHERE chave = <fatura>-chave AND
*                 mneum = 'CCT'.
*    SELECT SINGLE value INTO <fatura>-exti2
*        FROM zhms_tb_docmn
*        WHERE chave = <fatura>-chave AND
*              mneum = 'NCT'.
*
*  ENDLOOP.

  SELECT zctet tknum zfatt fknum zstcf INTO TABLE lt_status
           FROM zhms_tb_status
           FOR ALL ENTRIES IN lt_fatura
           WHERE zfatt = lt_fatura-numdoc AND
                 zstcf = 'C'.
  CHECK: sy-subrc = 0.

*  SELECT fknum fkpos netwr postx exti1 exti2
*         INTO TABLE lt_vfkp
*         FROM vfkp
*         FOR ALL ENTRIES IN lt_status
*         WHERE fknum = lt_status-fknum.
*
*  CHECK: sy-subrc = 0.

  FIELD-SYMBOLS <status> TYPE ltype_status.
* Estorna Custo de frete.
  LOOP AT lt_status ASSIGNING <status>.

    lv_postx = <status>-zctet.
    SHIFT lv_postx LEFT DELETING LEADING '0'. "elimina zeros a esquerda
    SELECT SINGLE fkpos INTO lv_item
           FROM vfkp
           WHERE fknum = <status>-fknum AND
                 postx = lv_postx.

    IF sy-subrc = 0.

      DATA: ls_message LIKE LINE OF lt_message,
            ls_return  TYPE bapiret2.

      REFRESH: gt_bdc[], lt_message[].
      CLEAR:  ls_message, gt_bdc, lt_message.


      CONCATENATE 'VFKN-KPOSN(' lv_item ')' INTO lv_vfkn_kposn.
      CONCATENATE 'VFKP-FKPOS(' lv_item ')' INTO lv_vfkp_fkpos.

      PERFORM  zf_preenche_bdc USING:
         'X'  'SAPMV54A'         '20'          ,
         ' '  'BDC_CURSOR'       'VFKK-FKNUM'  ,
         ' '  'BDC_OKCODE'       '=UEBP'       ,
         ' '  'VFKK-FKNUM'       <status>-fknum.

      PERFORM zf_preenche_bdc USING:
              'X'  'SAPMV54A'         '30'            ,
              ' '  'BDC_CURSOR'       'VFKP-POSTX(01)',
              ' '  'BDC_OKCODE'       '=KSMA'         .

      PERFORM zf_preenche_bdc USING:
          'X'  'SAPMV54A'         '30'            ,
          ' '  'BDC_CURSOR'       'VFKP-POSTX(01)',
          ' '  'BDC_OKCODE'       '=PDET'         .
      lv_item = lv_item - 1.

      IF lv_item > 0.
        DO lv_item TIMES.
          PERFORM zf_preenche_bdc USING:
           'X'  'SAPMV54A'         '40'            ,
           ' '  'BDC_CURSOR'       'VFKP-POSTX'    ,
           ' '  'BDC_OKCODE'       '=PNEX'         .
        ENDDO.
      ENDIF.

      PERFORM zf_preenche_bdc USING:
            'X'  'SAPMV54A'         '40'          ,
            ' '  'BDC_CURSOR'       'VFKP-POSTX'  ,
            ' '  'BDC_OKCODE'       '=PABR'       ,
            ' '  'VFKP-POSTX'       lv_postx.

      PERFORM zf_preenche_bdc USING:
            'X'  'SAPMV54A'         '40'          ,
            ' '  'BDC_OKCODE'       '=SICH'       ,
            ' '  'VFKP-POSTX'       lv_postx,
            ' '  'BDC_CURSOR'       'VFKPD-SLSTOR',
            ' '  'VFKPD-SLSTOR'     'X'           .

      DATA: lwa_ctu TYPE ctu_params.
      lwa_ctu-dismode      =  'N'.
      lwa_ctu-defsize      =  'X'.

      CALL TRANSACTION 'VI02' USING gt_bdc
                       OPTIONS FROM lwa_ctu
                       MESSAGES INTO lt_message.

      READ TABLE lt_message INTO ls_message WITH KEY msgtyp = 'S'
                                                     msgid  = 'VY'
                                                     msgnr  = '007'.
      IF NOT sy-subrc IS INITIAL.
        lv_msg = TEXT-e03.
        REPLACE '&1' WITH <status>-fknum INTO lv_msg.
        REPLACE '&2' WITH lv_postx INTO lv_msg.

** Registra LOG Erro
        ls_return-type       = ls_message-msgtyp.
        ls_return-id         = ls_message-msgid.
        ls_return-number     = ls_message-msgnr.
        ls_return-message    = lv_msg.
        ls_return-message_v1 = ls_message-msgv1.
        ls_return-message_v2 = ls_message-msgv2.
        ls_return-message_v3 = ls_message-msgv3.
        ls_return-message_v4 = ls_message-msgv4.
        ls_return-system     = ls_message-fldname.
        APPEND ls_return TO lt_return.
      ELSE.
** Registra LOG Sucesso
        lv_msg = TEXT-s03.
        REPLACE '&1' WITH <status>-fknum INTO lv_msg.
        REPLACE '&2' WITH lv_postx INTO lv_msg.

        ls_return-type       = ls_message-msgtyp.
        ls_return-id         = ls_message-msgid.
        ls_return-number     = ls_message-msgnr.
        ls_return-message    = lv_msg.
        ls_return-message_v1 = ls_message-msgv1.
        ls_return-message_v2 = ls_message-msgv2.
        ls_return-message_v3 = ls_message-msgv3.
        ls_return-message_v4 = ls_message-msgv4.
        ls_return-system     = ls_message-fldname.
        APPEND ls_return TO lt_return.
        <status>-estorno = 'OK'.
      ENDIF.


    ENDIF.

  ENDLOOP.

  REFRESH: gt_bdc[], lt_message[].
  CLEAR:  ls_message, gt_bdc, lt_message.
** Elimina custo de frete.
*  LOOP AT lt_status ASSIGNING <status>.
**    IF <status>-estorno = 'OK'.
*      PERFORM  zf_preenche_bdc USING:
*           'X'  'SAPMV54A'         '20'          ,
*           ' '  'BDC_CURSOR'       'VFKK-FKNUM'  ,
*           ' '  'BDC_OKCODE'       '=UEBP'       ,
*           ' '  'VFKK-FKNUM'       <status>-fknum.
*      PERFORM  zf_preenche_bdc USING:
*           'X'  'SAPMV54A'         '30'            ,
*           ' '  'BDC_CURSOR'       'VFKP-POSTX(01)',
*           ' '  'BDC_OKCODE'       '/ELOES'        .
*
*      PERFORM  zf_preenche_bdc USING:
*           'X'  'SAPMV54A'         '30'            ,
*           ' '  'BDC_CURSOR'       'VFKP-POSTX(01)',
*           ' '  'BDC_OKCODE'       '/EBEEN'        .
*
*      CALL TRANSACTION 'VI02' USING gt_bdc
*                          OPTIONS FROM lwa_ctu
*                          MESSAGES INTO lt_message.
*
*      READ TABLE lt_message INTO ls_message WITH KEY msgtyp = 'S'
*                                                     msgid  = 'VY'
*                                                     msgnr  = '013'.
*
*      IF NOT sy-subrc IS INITIAL.
*        lv_msg = TEXT-e04.
*        REPLACE '&1' WITH <status>-fknum INTO lv_msg.
*
*** Registra LOG Erro
*        ls_return-type       = ls_message-msgtyp.
*        ls_return-id         = ls_message-msgid.
*        ls_return-number     = ls_message-msgnr.
*        ls_return-message    = lv_msg.
*        ls_return-message_v1 = ls_message-msgv1.
*        ls_return-message_v2 = ls_message-msgv2.
*        ls_return-message_v3 = ls_message-msgv3.
*        ls_return-message_v4 = ls_message-msgv4.
*        ls_return-system     = ls_message-fldname.
*        APPEND ls_return TO lt_return.
*      ELSE.
*** Registra LOG Sucesso
*        lv_msg = TEXT-s04.
*        REPLACE '&1' WITH <status>-fknum INTO lv_msg.
*
*        ls_return-type       = ls_message-msgtyp.
*        ls_return-id         = ls_message-msgid.
*        ls_return-number     = ls_message-msgnr.
*        ls_return-message    = lv_msg.
*        ls_return-message_v1 = ls_message-msgv1.
*        ls_return-message_v2 = ls_message-msgv2.
*        ls_return-message_v3 = ls_message-msgv3.
*        ls_return-message_v4 = ls_message-msgv4.
*        ls_return-system     = ls_message-fldname.
*        APPEND ls_return TO lt_return.
** Elimina campo fknum fkpos e zstcf da tabela zhms_tb_status
*        SELECT SINGLE * INTO lw_zhms_tb_status
*               FROM zhms_tb_status
*               WHERE zctet = <status>-zctet AND
*                     tknum = <status>-tknum AND
*                     zfatt = <status>-zfatt.
*        CLEAR: lw_zhms_tb_status-fknum, "nr.custo de frete
*               lw_zhms_tb_status-fkpos, "item custo de frete
*               lw_zhms_tb_status-zstcf. "status custo de frete
*
*        MODIFY zhms_tb_status FROM lw_zhms_tb_status.
*      ENDIF.
**    ENDIF.
*  ENDLOOP.

ENDFUNCTION.
