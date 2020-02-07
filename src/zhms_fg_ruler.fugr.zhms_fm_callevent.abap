*-------------------------------------------------------------------*
*   HomSoft - Documentos Eletrônicos : Automator/Connector: Ruler   *
*-------------------------------------------------------------------*
* Descrição	: Realiza chamada de eventos durante a execução de      *
*    etapa de fluxo do cenário                                      *
*-------------------------------------------------------------------*
FUNCTION zhms_fm_callevent.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(NATDC) TYPE  ZHMS_DE_NATDC
*"     REFERENCE(TYPED) TYPE  ZHMS_DE_TYPED
*"     REFERENCE(LOCTP) TYPE  ZHMS_DE_LOCTP
*"     REFERENCE(EVENT) TYPE  ZHMS_DE_EVENT
*"  TABLES
*"      MNDATA STRUCTURE  ZHMS_ES_MNDATA
*"----------------------------------------------------------------------

*** Chamada do Executor de eventos
  CALL FUNCTION 'ZHMS_FM_EXEC'
    EXPORTING
      natdc                      = natdc
      typed                      = typed
      loctp                      = loctp
      event                      = event
    EXCEPTIONS
      nature_not_informed        = 1
      document_type_not_informed = 2
      event_scenery_not_informed = 3
      OTHERS                     = 4.

*** Tratamento de Excessões
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFUNCTION.
