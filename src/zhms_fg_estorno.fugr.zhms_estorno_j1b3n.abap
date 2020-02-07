FUNCTION zhms_estorno_j1b3n.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(FLWDOC) TYPE  ZHMS_TB_FLWDOC OPTIONAL
*"  TABLES
*"      LT_RETURN STRUCTURE  BAPIRET2 OPTIONAL
*"----------------------------------------------------------------------

  TYPES: BEGIN OF ltype_fatura,
           idtitulo        TYPE zhms_tb_fatura-idtitulo,
           numerodocumento TYPE zhms_tb_fatura-numerodocumento,
           chave           TYPE zhms_tb_fatura-chave,
           chave_fat       TYPE zhms_tb_fatura-chave_fat,
           numdoc          TYPE zhms_tb_status-zfatt,
         END OF ltype_fatura.

  TYPES: BEGIN OF ltype_status,
           zctet  TYPE zhms_tb_status-zctet,
           tknum  TYPE zhms_tb_status-tknum,
           zfatt  TYPE zhms_tb_status-zfatt,
           docnum TYPE zhms_tb_status-docnum,
           NFENUM type zhms_tb_status-NFENUM,
           zstnf  TYPE zhms_tb_status-zstnf,
         END OF ltype_status.

  DATA: lt_fatura TYPE TABLE OF ltype_fatura,
        lt_status TYPE TABLE OF ltype_status,
        lt_zhms_tb_status TYPE STANDARD TABLE OF zhms_tb_status,
        lw_zhms_tb_status LIKE LINE OF lt_zhms_tb_status.

  DATA: lv_nfe      TYPE zhms_tb_docmn-value,
        lv_msg(100) TYPE c.

  DATA: ls_message LIKE LINE OF lt_message,
        ls_return  TYPE bapiret2.

  SELECT idtitulo numerodocumento chave chave_fat numerodocumento
           FROM zhms_tb_fatura
           INTO TABLE lt_fatura
           WHERE chave_fat = flwdoc-chave.
  CHECK: sy-subrc = 0.

  SELECT zctet tknum zfatt docnum NFENUM zstnf INTO TABLE lt_status
           FROM zhms_tb_status
           FOR ALL ENTRIES IN lt_fatura
           WHERE zfatt = lt_fatura-numdoc AND
                 zstnf = 'C'.
  CHECK: sy-subrc = 0.

  FIELD-SYMBOLS <status> TYPE ltype_status.
* Estorna Custo de frete.
  LOOP AT lt_status ASSIGNING <status>.
    REFRESH: gt_bdc[], lt_message[].
    CLEAR: ls_message, gt_bdc, lt_message.

    PERFORM  zf_preenche_bdc USING:
      'X' 'SAPMJ1B1'                '1100',
      ' ' 'BDC_CURSOR'              'J_1BDYDOC-DOCNUM',
      ' ' 'BDC_OKCODE'              '=CANF',
      ' ' 'J_1BDYDOC-DOCNUM'        <status>-docnum.

    PERFORM  zf_preenche_bdc USING:
        'X' 'SAPLSPO1'                '0100',
        ' ' 'BDC_OKCODE'              '=YES'.

    CALL TRANSACTION 'J1B3N' USING gt_bdc
            UPDATE 'S'
            MODE  'N'
            MESSAGES INTO lt_message.

    BREAK homine.
*** verifica documento criado
    READ TABLE lt_message INTO ls_message WITH KEY msgtyp = 'S'
                                                   msgid  = '8B'
                                                   msgnr  = '191'.
    IF NOT sy-subrc IS INITIAL.
** Registra LOG Erro
      lv_msg = TEXT-e04.
      REPLACE '&1' WITH <status>-docnum INTO lv_msg.

      ls_return-type       = ls_message-msgtyp.
      ls_return-id         = ls_message-msgid.
      ls_return-number     = ls_message-msgnr.
      ls_return-message    = TEXT-e04.
      ls_return-message_v1 = ls_message-msgv1.
      ls_return-message_v2 = ls_message-msgv2.
      ls_return-message_v3 = ls_message-msgv3.
      ls_return-message_v4 = ls_message-msgv4.
      ls_return-system     = ls_message-fldname.
      APPEND ls_return TO lt_return.
    ELSE.
** Registra LOG Sucesso
      lv_msg = TEXT-s04.
      REPLACE '&1' WITH <status>-docnum INTO lv_msg.

      ls_return-type       = ls_message-msgtyp.
      ls_return-id         = ls_message-msgid.
      ls_return-number     = ls_message-msgnr.
      ls_return-message    = TEXT-s04.
      ls_return-message_v1 = ls_message-msgv1.
      ls_return-message_v2 = ls_message-msgv2.
      ls_return-message_v3 = ls_message-msgv3.
      ls_return-message_v4 = ls_message-msgv4.
      ls_return-system     = ls_message-fldname.
      APPEND ls_return TO lt_return.
* Elimina campo fknum fkpos e zstcf da tabela zhms_tb_status
*        SELECT SINGLE * INTO lw_zhms_tb_status
*               FROM zhms_tb_status
*               WHERE zctet = <status>-zctet AND
*                     tknum = <status>-tknum AND
*                     zfatt = <status>-zfatt.
*        CLEAR: lw_zhms_tb_status-docnum, "nr doc sap nfe
*               lw_zhms_tb_status-nfenum, "nf
*               lw_zhms_tb_status-zstnf. "status nf
*
*        MODIFY zhms_tb_status FROM lw_zhms_tb_status.

*      DELETE FROM zhms_tb_docmn WHERE chave EQ lv_chave
*                                  AND mneum EQ 'MATDOCEST'.
    ENDIF.
  ENDLOOP.

ENDFUNCTION.
