*----------------------------------------------------------------------*
*                      H  o  m  S  o  f  t                             *
*          Gestão Eletrônica de Documentos e Processos                 *
*----------------------------------------------------------------------*
* Descrição: Recebimento de Documentos: Portaria e             *
*            Declarações Globais                                       *
*----------------------------------------------------------------------*
FUNCTION-POOL zhms_fg_gate MESSAGE-ID zhms_ms_monitor.

*** ---------------------------------------------------------------- ***
*** Classes Locais: HTML Script's
*** ---------------------------------------------------------------- ***
CLASS lcl_html_script DEFINITION INHERITING FROM cl_gui_html_viewer.
  PUBLIC SECTION.
***     Método Construtor
    METHODS constructor
              IMPORTING
                value(parent) TYPE REF TO cl_gui_container
              EXCEPTIONS
                cntl_error.

***     Executo de JavaScript por Demanda
    METHODS run_script_on_demand
              IMPORTING
                value(script) TYPE STANDARD TABLE.

***     Gerador de Documentos
    METHODS load_bds_doc
              IMPORTING
                value(doc_name)        TYPE c
                value(doc_langu)       TYPE c OPTIONAL
                value(doc_description) TYPE c OPTIONAL
                value(bds_objectkey)   TYPE c
                !value(bds_classname)  TYPE c DEFAULT 'SAPHTML'
                !value(bds_classtyp)   TYPE c DEFAULT 'OT'
              EXPORTING
                value(assigned_url)    TYPE c.

***     Gerador de Ícones
    METHODS load_bds_icon
              IMPORTING
                value(icon_name) TYPE iconname
              EXPORTING
                value(assigned_url) TYPE c
                value(file_name)    TYPE c.
ENDCLASS.                    "lcl_html_script DEFINITION
*----------------------------------------------------------------------*
*   CLASS lcl_html_script IMPLEMENTATION
*----------------------------------------------------------------------*
*   Implementação da Classe para Execução de JavaScript
*----------------------------------------------------------------------*
CLASS lcl_html_script IMPLEMENTATION.
***   ---------------------------------------------------------------- *
***   Método Construtor
***   ---------------------------------------------------------------- *
  METHOD constructor.
    CALL METHOD super->constructor
      EXPORTING
        parent   = parent
        saphtmlp = 'X'
        uiflag   = cl_gui_html_viewer=>uiflag_noiemenu
      EXCEPTIONS
        OTHERS   = 1.

    IF sy-subrc NE 0.
      RAISE cntl_error.
    ENDIF.
  ENDMETHOD.                    "lcl_html_script

***   ---------------------------------------------------------------- *
***   Executor de JavaScript
***   ---------------------------------------------------------------- *
  METHOD run_script_on_demand.
    CALL METHOD me->set_script
      EXPORTING
        script = script.

    CALL METHOD me->execute_script.

  ENDMETHOD.                    "lcl_html_script

***   ---------------------------------------------------------------- *
***   Carregando Documento
***   ---------------------------------------------------------------- *
  METHOD load_bds_doc.
    CALL METHOD me->load_bds_object
      EXPORTING
        doc_name        = doc_name
        doc_langu       = doc_langu
        doc_description = doc_description
        bds_classname   = bds_classname
        bds_objectkey   = bds_objectkey
      IMPORTING
        assigned_url    = assigned_url
      EXCEPTIONS
        OTHERS          = 1.
  ENDMETHOD.                    "lcl_html_script

***   ---------------------------------------------------------------- *
***   Carregando Ícones
***   ---------------------------------------------------------------- *
  METHOD load_bds_icon.
    CALL METHOD me->load_bds_sap_icon
      EXPORTING
        sap_icon     = icon_name
      IMPORTING
        assigned_url = assigned_url
        file_name    = file_name
      EXCEPTIONS
        OTHERS       = 1.
  ENDMETHOD.                    "lcl_html_script
ENDCLASS.                    "lcl_html_script IMPLEMENTATION

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


*----------------------------------------------------------------------*
*       CLASS lcl_event_handler IMPLEMENTATION
*----------------------------------------------------------------------*
*
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
        WHEN 'portaria'.
          PERFORM f_validaportaria TABLES postdata.
        WHEN 'cancel'.
          PERFORM f_cancelaportaria.
        WHEN 'check'.
          PERFORM f_executehtml_timer.
        WHEN 'consu'.
          PERFORM f_consulta_status.
      ENDCASE.
    ENDIF.
  ENDMETHOD.                    "lcl_event_handler
ENDCLASS.               "lcl_event_handler

*** ---------------------------------------------------------------- ***
*** Estruturas
*** ---------------------------------------------------------------- ***
TYPES: BEGIN OF ty_docrcbto,
        check TYPE flag,
        icon  TYPE icon_d.
        INCLUDE STRUCTURE zhms_tb_docrcbto.
TYPES: END OF ty_docrcbto.

TYPES: BEGIN OF ty_docconf,
        check TYPE flag,
        icon  TYPE icon_d.
        INCLUDE STRUCTURE zhms_tb_docconf.
TYPES: END OF ty_docconf.

TYPES: BEGIN OF ty_datconf,
        dcitm TYPE zhms_de_dcitm,
        cfqtd TYPE zhms_de_cfqtd,
        charg TYPE zhms_de_charg,
        denom	TYPE zhms_de_denom,
        dcqtd	TYPE zhms_de_dcqtd,
        dcunm	TYPE zhms_de_dcunm,
       END OF ty_datconf.

TYPES: html_dso_line(250) TYPE c.

*** ---------------------------------------------------------------- ***
*** Tabelas
*** ---------------------------------------------------------------- ***
TABLES: zhms_tb_cabdoc.

*** ---------------------------------------------------------------- ***
*** Objetos
*** ---------------------------------------------------------------- ***
DATA: ob_cc_html_rcp   TYPE REF TO cl_gui_custom_container,
      ob_html_rcp      TYPE REF TO lcl_html_script,
      ob_receiver      TYPE REF TO lcl_event_handler,
      ob_cc_img_docs   TYPE REF TO cl_gui_custom_container,
      ob_img_docs      TYPE REF TO cl_gui_picture,
      ob_cc_html_det   TYPE REF TO cl_gui_custom_container,
      ob_html_det      TYPE REF TO lcl_html_script.

*** ---------------------------------------------------------------- ***
*** Variaveis
*** ---------------------------------------------------------------- ***
DATA:  save_ok         TYPE sy-ucomm,
       ok_code         TYPE sy-ucomm,
       v_gate          TYPE zhms_de_gate,
       v_observ        TYPE string,
       vg_cnf_chave    TYPE zhms_de_chave,
       vg_cnf_chave_a  TYPE zhms_de_chave,
       vg_prt_chave    TYPE zhms_de_chave,
       vg_prt_chave_a  TYPE zhms_de_chave,
       vg_conf_status  TYPE icon_d,
       vg_url          TYPE cndp_url,
       vg_msgimg       TYPE i,
       v_detdoc        TYPE sy-dynnr  VALUE '0504',
       v_conf          TYPE sy-dynnr  VALUE '0401',
       vg_stent        TYPE zhms_de_stent,
       vg_time         TYPE char1,
**   Begin of change - c_flag - MZAGATO - DE2K906251 - 15/10/2019.
       c_flag          TYPE char1 VALUE ''.
**   End of change - c_flag - MZAGATO - DE2K906251 - 15/10/2019.
*** ---------------------------------------------------------------- ***
*** Tabelas Internas
*** ---------------------------------------------------------------- ***
DATA: t_events      TYPE cntl_simple_events,
      t_srscd_ev    TYPE w3htmltab,
      t_gatemneu    TYPE TABLE OF zhms_tb_gatemneu,
      t_gatemneux   TYPE TABLE OF zhms_tx_gatemneu,
      t_gateobs     TYPE TABLE OF zhms_tb_gateobs,
      t_wwwdata     TYPE TABLE OF wwwdata,
      t_docrcbto_ax TYPE TABLE OF ty_docrcbto,
      t_docconf_ax  TYPE TABLE OF ty_docconf,
      t_docrcbto    TYPE TABLE OF zhms_tb_docrcbto,
      t_datrcbto    TYPE TABLE OF zhms_tb_datrcbto,
      t_docconf     TYPE TABLE OF zhms_tb_docconf,
      t_datconf     TYPE TABLE OF zhms_tb_datconf,
      t_datconf_ax  TYPE TABLE OF ty_datconf,
      t_datasrc     TYPE TABLE OF html_dso_line INITIAL SIZE 20,
      t_srscd       TYPE STANDARD TABLE OF zhms_st_html_srscd,
      t_itmdoc      TYPE TABLE OF zhms_tb_itmdoc.

*** ---------------------------------------------------------------- ***
*** Work Areas
*** ---------------------------------------------------------------- ***
DATA: wa_event         TYPE cntl_simple_event,
      wa_gate          TYPE zhms_tb_gate,
      wa_gatemneu      TYPE zhms_tb_gatemneu,
      wa_gatemneux     TYPE zhms_tx_gatemneu,
      wa_gateobs       TYPE zhms_tb_gateobs,
      wa_wwwdata       TYPE wwwdata,
      wa_srscd         TYPE zhms_st_html_srscd,
      wa_docrcbto_ax   TYPE ty_docrcbto,
      wa_docconf_ax    TYPE ty_docconf,
      wa_docrcbto      TYPE zhms_tb_docrcbto,
      wa_datrcbto      TYPE zhms_tb_datrcbto,
      wa_docconf       TYPE zhms_tb_docconf,
      wa_datconf       TYPE zhms_tb_datconf,
      wa_cabdoc        TYPE zhms_tb_cabdoc,
      wa_datconf_ax    TYPE ty_datconf,
      wa_datasrc       TYPE html_dso_line,
      wa_return        TYPE zhms_es_return,
      wa_itmdoc        TYPE zhms_tb_itmdoc,
      wa_flwdoc        TYPE zhms_tb_flwdoc,
      wa_docmn         TYPE zhms_tb_docmn,
      wa_show_lay      TYPE zhms_tb_show_lay.

*** ---------------------------------------------------------------- ***
*** Controles
*** ---------------------------------------------------------------- ***

CONTROLS: tc_prt_docrcbto TYPE TABLEVIEW USING SCREEN 0500.

CONSTANTS: BEGIN OF c_ts_header,
             tab1 LIKE sy-ucomm VALUE 'TS_HEADER_FC1',
             tab2 LIKE sy-ucomm VALUE 'TS_HEADER_FC2',
             tab3 LIKE sy-ucomm VALUE 'TS_HEADER_FC3',
           END OF c_ts_header.

CONTROLS:  ts_header TYPE TABSTRIP.
DATA:      BEGIN OF g_ts_header,
             subscreen   LIKE sy-dynnr,
             prog        LIKE sy-repid VALUE 'SAPLZHMS_FG_MONITOR',
             pressed_tab LIKE sy-ucomm VALUE c_ts_header-tab1,
           END OF g_ts_header.

CONSTANTS: BEGIN OF c_ts_rcb_meth,
             tab1 LIKE sy-ucomm VALUE 'TS_RCB_METH_FC1',
             tab2 LIKE sy-ucomm VALUE 'TS_RCB_METH_FC2',
           END OF c_ts_rcb_meth.

CONTROLS:  ts_rcb_meth TYPE TABSTRIP.
DATA:      BEGIN OF g_ts_rcb_meth,
             subscreen   LIKE sy-dynnr,
             prog        LIKE sy-repid VALUE 'SAPLZHMS_FG_GATE',
             pressed_tab LIKE sy-ucomm VALUE c_ts_rcb_meth-tab1,
           END OF g_ts_rcb_meth.

CONSTANTS: BEGIN OF c_ts_conf_meth,
             tab1 LIKE sy-ucomm VALUE 'TS_CONF_METH_FC1',
             tab2 LIKE sy-ucomm VALUE 'TS_CONF_METH_FC2',
           END OF c_ts_conf_meth.
CONTROLS:  ts_conf_meth TYPE TABSTRIP.

DATA:      BEGIN OF g_ts_conf_meth,
             subscreen   LIKE sy-dynnr,
             prog        LIKE sy-repid VALUE 'SAPLZHMS_FG_GATE',
             pressed_tab LIKE sy-ucomm VALUE c_ts_conf_meth-tab1,
           END OF g_ts_conf_meth.

CONTROLS: tc_cnf_datconf TYPE TABLEVIEW USING SCREEN 0401.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TC_CNF_DOCCONF' ITSELF
CONTROLS: tc_cnf_docconf TYPE TABLEVIEW USING SCREEN 0400.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TC_CNF_DOCCONF2' ITSELF
CONTROLS: tc_cnf_docconf2 TYPE TABLEVIEW USING SCREEN 0402.
