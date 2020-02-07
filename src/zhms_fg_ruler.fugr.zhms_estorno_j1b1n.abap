FUNCTION ZHMS_ESTORNO_J1B1N.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(CHAVE) TYPE  ZHMS_DE_CHAVE OPTIONAL
*"  TABLES
*"      LT_RETURN STRUCTURE  BAPIRET2 OPTIONAL
*"----------------------------------------------------------------------

  DATA: lv_nfe     TYPE zhms_tb_docmn-value.
  DATA: ls_message LIKE LINE OF lt_message,
        ls_return  TYPE bapiret2.

  REFRESH: gt_bdc[], lt_message[].
  CLEAR: lv_nfe, ls_message, gt_bdc, lt_message.

  SELECT SINGLE value
    INTO lv_nfe
    FROM zhms_tb_docmn
   WHERE chave EQ chave
     AND mneum EQ 'MATDOC'.

  IF sy-subrc IS INITIAL AND NOT lv_nfe IS INITIAL.

    PERFORM  zf_preenche_bdc USING:
      'X' 'SAPMJ1B1'                '1100',
      ' ' 'BDC_CURSOR'              'J_1BDYDOC-DOCNUM',
      ' ' 'BDC_OKCODE'              '=CANF',
      ' ' 'J_1BDYDOC-DOCNUM'        lv_nfe.

    PERFORM  zf_preenche_bdc USING:
        'X' 'SAPLSPO1'                '0100',
        ' ' 'BDC_OKCODE'              '=YES'.

    CALL TRANSACTION 'J1B3N' USING gt_bdc
            UPDATE 'S'
            MODE  'N'
            MESSAGES INTO lt_message.

    break homine.
*** verifica documento criado
    READ TABLE lt_message INTO ls_message WITH KEY msgtyp = 'S'
                                                   msgid  = '8B'
                                                   msgnr  = '191'.
    IF NOT sy-subrc IS INITIAL.
** Registra LOG Erro
      ls_return-type       = ls_message-msgtyp.
      ls_return-id         = ls_message-msgid.
      ls_return-number     = ls_message-msgnr.
      ls_return-message    = text-e03.
      ls_return-message_v1 = ls_message-msgv1.
      ls_return-message_v2 = ls_message-msgv2.
      ls_return-message_v3 = ls_message-msgv3.
      ls_return-message_v4 = ls_message-msgv4.
      ls_return-system     = ls_message-fldname.
      APPEND ls_return TO lt_return.
    ELSE.
** Registra LOG Sucesso
      ls_return-type       = ls_message-msgtyp.
      ls_return-id         = ls_message-msgid.
      ls_return-number     = ls_message-msgnr.
      ls_return-message    = text-s03.
      ls_return-message_v1 = ls_message-msgv1.
      ls_return-message_v2 = ls_message-msgv2.
      ls_return-message_v3 = ls_message-msgv3.
      ls_return-message_v4 = ls_message-msgv4.
      ls_return-system     = ls_message-fldname.
      APPEND ls_return TO lt_return.

      DELETE FROM zhms_tb_docmn WHERE chave EQ chave
                                  AND mneum EQ 'MATDOCEST'.

    ENDIF.

  ENDIF.





ENDFUNCTION.
