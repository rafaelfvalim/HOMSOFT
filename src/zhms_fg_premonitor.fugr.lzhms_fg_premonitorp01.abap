*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_PREMONITORP01 .
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*   CLASS lcl_event_handler IMPLEMENTATION
*----------------------------------------------------------------------*
*   Implementação da Classe de Eventos do HTML
*----------------------------------------------------------------------*
    CLASS lcl_event_handler IMPLEMENTATION.
***   ---------------------------------------------------------------- *
***   Implementação da Classe de Eventos do HTML
***   ---------------------------------------------------------------- *
      METHOD on_sapevent.
        DATA: v_postdata TYPE string.
        CLEAR v_postdata.

        IF NOT action IS INITIAL.
          CASE action.
**          Chamada das transações
            WHEN 'MONITOR'.
*** Verifica Autorização usuario
              CALL FUNCTION 'ZHMS_FM_SECURITY'
                EXPORTING
                  value         = 'MONITOR'
                EXCEPTIONS
                  authorization = 1
                  OTHERS        = 2.

              IF sy-subrc <> 0.
                MESSAGE e000(zhms_security). "   Usuário sem autorização
              ENDIF.
              CALL TRANSACTION 'ZHMS_MONITOR'.
            WHEN 'PORTARIA'.
*** Verifica Autorização usuario
              CALL FUNCTION 'ZHMS_FM_SECURITY'
                EXPORTING
                  value         = 'PORTARIA'
                EXCEPTIONS
                  authorization = 1
                  OTHERS        = 2.

              IF sy-subrc <> 0.
                MESSAGE e001(zhms_security). "   Usuário sem autorização
              ENDIF.
           CALL TRANSACTION 'ZHMS_GATE'.
*             CALL TRANSACTION 'ZHMS_GATE_PORTA'. "chamada para o portal fake

            WHEN 'CONFERENCIA'.
*** Verifica Autorização usuario
              CALL FUNCTION 'ZHMS_FM_SECURITY'
                EXPORTING
                  value         = 'CONFERENCIA'
                EXCEPTIONS
                  authorization = 1
                  OTHERS        = 2.

              IF sy-subrc <> 0.
                MESSAGE e001(zhms_security). "   Usuário sem autorização
              ENDIF.
              CALL TRANSACTION 'ZHMS_GATE_CONF'.
            WHEN 'RELATORIOS'.
*** Verifica Autorização usuario
              CALL FUNCTION 'ZHMS_FM_SECURITY'
                EXPORTING
                  value         = 'RELATORIOS'
                EXCEPTIONS
                  authorization = 1
                  OTHERS        = 2.

              IF sy-subrc <> 0.
                MESSAGE e000(zhms_security). "   Usuário sem autorização
              ENDIF.
*              CALL TRANSACTION 'ZHMREL'.

CALL TRANSACTION 'ZHMS_REPORT'.
*CALL TRANSACTION 'ZHMS_REPORT'.

            WHEN 'DATAENTRY'.
*** Verifica Autorização usuario
              CALL FUNCTION 'ZHMS_FM_SECURITY'
                EXPORTING
                  value         = 'ENTRADA_MANUAL'
                EXCEPTIONS
                  authorization = 1
                  OTHERS        = 2.

              IF sy-subrc <> 0.
                MESSAGE e001(zhms_security). "   Usuário sem autorização
              ENDIF.
*DDPT
*              CALL TRANSACTION 'ZHMS_DATAENTRY'.
               CALL TRANSACTION 'ZHMS_DATAENTRY_AUX'.
*DDPT
            WHEN 'CONFIG'.
*** Verifica Autorização usuario
              CALL FUNCTION 'ZHMS_FM_SECURITY'
                EXPORTING
                  value         = 'CONFIGURACOES'
                EXCEPTIONS
                  authorization = 1
                  OTHERS        = 2.

              IF sy-subrc <> 0.
                MESSAGE e000(zhms_security). "   Usuário sem autorização
              ENDIF.
              PERFORM f_showimg.
            WHEN OTHERS.


          ENDCASE.
        ENDIF.
      ENDMETHOD.                    "lcl_event_handler
    ENDCLASS.               "lcl_event_handler
