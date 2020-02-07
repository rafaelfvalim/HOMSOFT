FUNCTION zhms_estorno_ml81n.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(LBLNI) TYPE  LBLNI
*"  TABLES
*"      RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------

  DATA: lv_lblni   TYPE lblni,
        ws_wait    TYPE bapita-wait.

  DATA: lt_message LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE,
        ls_message LIKE LINE OF lt_message.

  DATA: lt_return  TYPE bapiret2 OCCURS 0 WITH HEADER LINE,
        lt_return2 TYPE bapiret2 OCCURS 0 WITH HEADER LINE,
        ls_return  TYPE bapiret2.



  REFRESH: gt_bdc, lt_message, lt_return, lt_return2.
  CLEAR:   lv_lblni, ls_message, gs_bdc, ls_message, ls_return.

  lv_lblni = lblni.

  IF NOT lv_lblni IS INITIAL.

*Desabilitar o ACEITE da folha de serviço
    PERFORM  zf_preenche_bdc USING:
      'X' 'SAPLMLSR'                '0400',
      ' ' 'BDC_CURSOR'              'RM11P-NEW_ROW',
      ' ' 'BDC_OKCODE'              '=SELP',
      ' ' 'RM11P-NEW_ROW'           '10'.

    PERFORM  zf_preenche_bdc USING:
      'X' 'SAPLMLSR'                '0340',
      ' ' 'BDC_CURSOR'              'RM11R-LBLNI',
      ' ' 'BDC_OKCODE'              '=ENTE',
      ' ' 'RM11R-LBLNI'             lv_lblni.

    PERFORM  zf_preenche_bdc USING:
      'X' 'SAPLMLSR'                '0400',
      ' ' 'BDC_OKCODE'              '=AKCH',
      ' ' 'BDC_CURSOR'              'RM11P-NEW_ROW',
      ' ' 'RM11P-NEW_ROW'           '10'.

    PERFORM  zf_preenche_bdc USING:
      'X' 'SAPLMLSR'                '0400',
      ' ' 'BDC_OKCODE'              '=ACCR',
      ' ' 'BDC_CURSOR'              'RM11P-NEW_ROW',
      ' ' 'RM11P-NEW_ROW'           '10'.

    PERFORM  zf_preenche_bdc USING:
      'X' 'SAPLMLSR'                '0400',
      ' ' 'BDC_OKCODE'              '=SAVE',
      ' ' 'BDC_CURSOR'              'RM11P-NEW_ROW',
      ' ' 'RM11P-NEW_ROW'           '10'.

    PERFORM  zf_preenche_bdc USING:
      'X' 'SAPLMLSR'                '0110',
      ' ' 'BDC_CURSOR'              'IMKPF-BLDAT',
      ' ' 'BDC_OKCODE'              '=ENTE'.

    PERFORM  zf_preenche_bdc USING:
      'X' 'SAPLMLSR'                '0400',
      ' ' 'BDC_OKCODE'              '=BACK',
      ' ' 'BDC_CURSOR'              'RM11P-NEW_ROW'.

    CALL TRANSACTION 'ML81N' USING gt_bdc
            UPDATE 'S'
            MODE 'N'
            MESSAGES INTO lt_message.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    CLEAR ls_message.
    READ TABLE lt_message INTO ls_message WITH KEY msgtyp = 'S'.

    IF NOT sy-subrc IS INITIAL.
*Erro ao retirar o ACEITE da Folha de Serviço
      ls_return-type       = ls_message-msgtyp.
      ls_return-id         = ls_message-msgid.
      ls_return-number     = ls_message-msgnr.
      ls_return-message    = text-e03. "
      ls_return-message_v1 = ls_message-msgv1.
      ls_return-message_v2 = ls_message-msgv2.
      ls_return-message_v3 = ls_message-msgv3.
      ls_return-message_v4 = ls_message-msgv4.
      ls_return-system     = ls_message-fldname.
      APPEND ls_return TO lt_return.

    ELSE.

*Excluir a folha de serviço
      CALL FUNCTION 'BAPI_ENTRYSHEET_DELETE'
        EXPORTING
          entrysheet = lv_lblni
        TABLES
          return     = lt_return2.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.

      lt_return[] = lt_return2[].

    ENDIF.

  ELSE.

*Folha de Serviço não informada
    ls_return-type       = 'E'.
    ls_return-message    = text-e01.
    APPEND ls_return TO lt_return.

  ENDIF.

  return[] = lt_return[].


ENDFUNCTION.
*&---------------------------------------------------------------------*
*&      Form  ZF_PREENCHE_BDC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0056   text
*      -->P_0057   text
*      -->P_0058   text
*----------------------------------------------------------------------*
FORM zf_preenche_bdc USING p_tela
                           p_name
                           p_value.
  CLEAR gs_bdc.
  IF p_tela = 'X'.
    gs_bdc-program   =  p_name.
    gs_bdc-dynpro    =  p_value.
    gs_bdc-dynbegin  =  p_tela.
  ELSE.
    gs_bdc-fnam      =  p_name.
    gs_bdc-fval      =  p_value.
  ENDIF.
  APPEND gs_bdc TO gt_bdc.


ENDFORM.                    " ZF_PREENCHE_BDC
