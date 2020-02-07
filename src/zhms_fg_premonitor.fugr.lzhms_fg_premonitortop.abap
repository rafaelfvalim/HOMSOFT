FUNCTION-POOL zhms_fg_premonitor.

*** ---------------------------------------------------------------- ***
*** Classes Locais: SAP Evento HTML
*** ---------------------------------------------------------------- ***
CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    METHODS on_sapevent FOR EVENT sapevent OF cl_gui_html_viewer
                        IMPORTING action
                                  frame
                                  getdata
                                  postdata
                                  query_table.
ENDCLASS.               "LCL_EVENT_HANDLER

*** ---------------------------------------------------------------- ***
*** Variáveis Globais
*** ---------------------------------------------------------------- ***
DATA: vg_url        TYPE cndp_url.

*** ---------------------------------------------------------------- ***
*** Tabelas Internas
*** ---------------------------------------------------------------- ***
DATA: t_srscd       TYPE STANDARD TABLE OF zhms_st_html_srscd,
      t_srscd_ev    TYPE w3htmltab,
      t_wwwdata     TYPE TABLE OF wwwdata,
      t_events      TYPE cntl_simple_events,
      t_parameters  LIKE streeprop OCCURS 1 WITH HEADER LINE.

*** ---------------------------------------------------------------- ***
*** Áreas de Trabalho
*** ---------------------------------------------------------------- ***
DATA: wa_srscd      TYPE zhms_st_html_srscd,
      wa_event      TYPE cntl_simple_event,
      wa_wwwdata    TYPE wwwdata,
      wa_ttreet     TYPE ttreet.
*** ---------------------------------------------------------------- ***
*** Objetos
*** ---------------------------------------------------------------- ***
DATA: ob_cc_home    TYPE REF TO cl_gui_custom_container,
      ob_html_home  TYPE REF TO cl_gui_html_viewer,
      ob_receiver   TYPE REF TO lcl_event_handler.
