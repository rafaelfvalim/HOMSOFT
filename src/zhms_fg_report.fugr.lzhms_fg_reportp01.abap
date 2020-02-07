*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_REPORTP01 .
CLASS lcl_event_handler IMPLEMENTATION.
***   ---------------------------------------------------------------- *
***   Implementação da Classe de Eventos do HTML
***   ---------------------------------------------------------------- *
  METHOD on_sapevent.

    CLEAR vg_action.
    IF NOT action IS INITIAL.
      CASE action.
        WHEN '02|NFE|'. " Recepção NF-e
          MOVE action TO vg_action.
          CALL SCREEN 0200.
        WHEN '02|NFSE|'." Recepção NF de serviço
          MOVE action TO vg_action.
          CALL SCREEN 0200.
        WHEN '01|NFS|'. " Emissão NF de serviço
          MOVE action TO vg_action.
          CALL SCREEN 0200.
        WHEN '01|NFE|'. " Emissão NF-e
          MOVE action TO vg_action.
          CALL SCREEN 0200.
        WHEN '02|CTE|'. "CTe
          MOVE action TO vg_action.
          CALL SCREEN 0200.
        when '02|NFSE|3550308'.
          call TRANSACTION 'ZHMS_CARGA_REL'.
        WHEN OTHERS.

      ENDCASE.
    ENDIF.

  ENDMETHOD.                    "lcl_event_handler
ENDCLASS.               "lcl_event_handler
