FUNCTION-POOL zhms_fg_report.               "MESSAGE-ID ..

* INCLUDE LZHMS_FG_REPORTD...                " Local class definition

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
*       CLASS lcl_hotspot_click IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
*  METHOD HANDLE_HOTSPOT_CLICK.
*
*    IF E_COLUMN_ID = 'DOC_MIGO'.
**      PERFORM Z_CALL_TRANSACTION USING E_ROW_ID.   " Subroutine to handle hotspot on customer number
*    ENDIF.
*
*    IF E_COLUMN_ID = 'DOC_MIRO'.
**      PERFORM Z_CALL_TRANSACTION_2 USING E_ROW_ID.   " Subroutine to handle hotspot on customer number
*    ENDIF.
*
*  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK

*** Delcaração de tipos
TYPES: BEGIN OF ty_tabs.
        INCLUDE STRUCTURE rsdstabs.
TYPES: END OF ty_tabs.

TYPES: BEGIN OF ty_flds.
        INCLUDE STRUCTURE rsdsfields.
TYPES: END OF ty_flds.

TYPES: BEGIN OF ty_vld,
  natdc TYPE zhms_de_natdc,
  typed TYPE zhms_de_typed,
  docnr	TYPE zhms_de_dcnro,
  atitm TYPE zhms_de_atitm,
  dtreg	TYPE zhms_de_dtreg,
  hrreg TYPE zhms_de_hrreg,
  vldv2	TYPE zhms_de_vldgv,
END OF ty_vld.

TYPES: BEGIN OF ty_hist,
   docnr  TYPE zhms_de_dcnro,
   dcitm  TYPE zhms_de_dcitm,
   ebeln  TYPE ebeln,
   atitm  TYPE zhms_de_atitm,
   docum  TYPE char50,
  END OF ty_hist.

TYPES: BEGIN OF ty_flowd,
  flowd   TYPE zhms_tb_scen_flo-flowd,
  END OF ty_flowd.

*** Declaração de objetos de sistema
DATA: ok_code          TYPE sy-ucomm,
      ob_cc_html_index TYPE REF TO cl_gui_custom_container,
      ob_html_index    TYPE REF TO cl_gui_html_viewer,
      ob_receiver      TYPE REF TO lcl_event_handler,
      e_object         TYPE REF TO cl_alv_event_toolbar_set,
      ob_cc_vld_item   TYPE REF TO cl_gui_custom_container,
      ob_cc_grid       TYPE REF TO cl_gui_alv_grid.

*** Declaração de tabelas internas
DATA: t_srscd_ev       TYPE w3htmltab,
      t_srscd          TYPE STANDARD TABLE OF zhms_st_html_srscd,
      t_index          TYPE STANDARD TABLE OF zhms_st_html_index,
      t_nature         TYPE STANDARD TABLE OF zhms_tb_nature,
      t_nature_t       TYPE STANDARD TABLE OF zhms_tx_nature,
      t_type_t         TYPE STANDARD TABLE OF zhms_tx_type,
      t_grpfld_s       TYPE STANDARD TABLE OF zhms_tb_grpfld_s,
      t_events         TYPE cntl_simple_events,
      t_type           TYPE STANDARD TABLE OF zhms_tb_type,
      t_twhere         TYPE rsds_twhere,
      t_tabs           TYPE TABLE OF ty_tabs,
      t_flds           TYPE TABLE OF ty_flds,
      t_texpr          TYPE rsds_texpr,
      t_status01       TYPE STANDARD TABLE OF zhms_es_rp_status01,
      t_cabdoc         TYPE STANDARD TABLE OF zhms_tb_cabdoc,
      t_cabdoc_ref     TYPE STANDARD TABLE OF zhms_tb_cabdoc,
      t_docst_new      TYPE STANDARD TABLE OF zhms_tb_docst,
      t_docst	         TYPE STANDARD TABLE OF zhms_tb_docst,
      t_docrf	         TYPE STANDARD TABLE OF zhms_tb_docrf,
      t_docrf_es       TYPE STANDARD TABLE OF zhms_es_docrf,
      t_param          TYPE STANDARD TABLE OF zhms_st_html_param,
      t_lfa1           TYPE STANDARD TABLE OF lfa1,
      t_kna1           TYPE STANDARD TABLE OF kna1,
      lt_flwdoc        TYPE STANDARD TABLE OF zhms_tb_flwdoc,
      lt_docst         TYPE STANDARD TABLE OF zhms_tb_docst,
      lt_sen_flo       TYPE STANDARD TABLE OF zhms_tb_scen_flo,
      lt_docmn1        TYPE STANDARD TABLE OF zhms_tb_docmn,
      lT_LOGDOC        TYPE STANDARD TABLE OF zhms_tb_LOGDOC,
      lt_typedomn      TYPE STANDARD TABLE OF zhms_tx_type,
      lt_hrvalid       TYPE STANDARD TABLE OF zhms_tb_hrvalid,
      lt_vld_out       TYPE STANDARD TABLE OF ty_vld,
      ls_vld_out       LIKE LINE OF lt_vld_out,
      ls_hrvalid       LIKE LINE OF lt_hrvalid,
      t_hvalid_fldc    TYPE lvc_t_fcat,
      t_hist_out       TYPE STANDARD TABLE OF ty_hist,
      t_flowd          TYPE STANDARD TABLE OF ty_flowd,
      it_logunk        TYPE TABLE OF zhms_tb_logunk,
      it_fieldcat      TYPE slis_t_fieldcat_alv,
      T_SORT           TYPE STANDARD TABLE OF LVC_S_SORT.



*** Declaração de Work Areas
DATA: wa_srscd         TYPE zhms_st_html_srscd,
      wa_nature        TYPE zhms_tb_nature,
      wa_nature_t      TYPE zhms_tx_nature,
      wa_index         TYPE zhms_st_html_index,
      vg_icon_id       TYPE cndp_url,
      wa_type          TYPE zhms_tb_type,
      wa_type_t        TYPE zhms_tx_type,
      wa_grpfld_s      TYPE zhms_tb_grpfld_s,
      wa_event         TYPE cntl_simple_event,
      wa_tabs          TYPE ty_tabs,
      wa_flds          TYPE ty_flds,
      wa_sen_flo       TYPE zhms_tb_scen_flo,
      wa_LOGDOC        TYPE zhms_tb_LOGDOC,
      wa_docmn1        TYPE zhms_tb_docmn,
      wa_status01      LIKE LINE OF t_status01,
      wa_cabdoc        TYPE zhms_tb_cabdoc,
      wa_cabdoc_main   TYPE zhms_tb_cabdoc,
      wa_docst         TYPE zhms_tb_docst,
      wa_docrf         TYPE zhms_tb_docrf,
      wa_docrf_es      TYPE zhms_es_docrf,
      wa_param         TYPE zhms_st_html_param,
      wa_lfa1          TYPE lfa1,
      wa_kna1          TYPE kna1,
      wa_twhere        LIKE LINE OF t_twhere,
      wa_flwdoc        LIKE LINE OF lt_flwdoc,
      wa_typedomn      LIKE LINE OF lt_typedomn,
      wa_hvalid_fldc   TYPE lvc_s_fcat,
      wa_hist_out      LIKE LINE OF t_hist_out,
      ls_show_lay      TYPE zhms_tb_show_lay,
      wa_flowd         TYPE ty_flowd,
      wa_fieldcat      TYPE slis_fieldcat_alv,
      WA_SORT          TYPE LVC_S_SORT.

*** Declaração de Vriaveis de sistema
DATA: vg_url           TYPE cndp_url,
      vg_icon_url      TYPE cndp_url,
      vg_selid         TYPE rsdynsel-selid,
      vg_actnum        TYPE sy-tfill,
      vg_title         TYPE sy-title,
      v_index          TYPE sy-tabix,
      vg_screen        TYPE sy-dynnr,
      vg_screen2       TYPE sy-dynnr,
      vg_action        TYPE char10,
      vg_actionx       TYPE char10,
      vg_flowd         TYPE zhms_de_flowd,
      vg_ICON_GREEN    TYPE ICON-ID,
      Vg_ICON_YELLOW   TYPE ICON-ID,
      Vg_ICON_RED      TYPE ICON-ID.
*** Declarações para relatórios graficos
DATA: g_graph_container TYPE REF TO cl_gui_custom_container.
DATA: g_ce_viewer       TYPE REF TO cl_gui_chart_engine.
DATA: g_ce_viewer2      TYPE REF TO cl_gui_chart_engine.
DATA: g_ixml            TYPE REF TO if_ixml.
DATA: g_ixml_sf         TYPE REF TO if_ixml_stream_factory.
DATA: okcode            LIKE sy-ucomm.
DATA: lt_cabdoc         TYPE STANDARD TABLE OF zhms_tb_cabdoc.
DATA: ls_cabdoc         LIKE LINE OF lt_cabdoc.
DATA: ls_cabdocx        LIKE LINE OF lt_cabdoc.
DATA: lt_cabdocx        TYPE STANDARD TABLE OF zhms_tb_cabdoc.

DATA: g_graph_container_vld TYPE REF TO cl_gui_custom_container.
DATA: g_ce_viewer_vld       TYPE REF TO cl_gui_chart_engine.
DATA: g_ce_viewer2_vld      TYPE REF TO cl_gui_chart_engine.
DATA: g_ixml_vld            TYPE REF TO if_ixml.
DATA: g_ixml_sf_vld         TYPE REF TO if_ixml_stream_factory.
DATA: okcode_vld            LIKE sy-ucomm.

DATA: g_graph_container_erro TYPE REF TO cl_gui_custom_container.
DATA: g_ce_viewer_erro       TYPE REF TO cl_gui_chart_engine.
DATA: g_ce_viewer2_erro     TYPE REF TO cl_gui_chart_engine.
DATA: g_ixml_erro            TYPE REF TO if_ixml.
DATA: g_ixml_sf_erro         TYPE REF TO if_ixml_stream_factory.
DATA: okcode_erro           LIKE sy-ucomm.

*&---------------------------------------------------------------------*
*&       Class LCL_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
CLASS LCL_HOTSPOT_CLICK DEFINITION.
  PUBLIC SECTION.
    METHODS:
    HANDLE_HOTSPOT_CLICK
    FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID IMPORTING E_ROW_ID
                                                         E_COLUMN_ID.
ENDCLASS.               "LCL_HOTSPOT_CLICK

*----------------------------------------------------------------------*
*       CLASS lcl_hotspot_click IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS LCL_HOTSPOT_CLICK IMPLEMENTATION.
  METHOD HANDLE_HOTSPOT_CLICK.
    READ TABLE t_status01 INTO WA_STATUS01 INDEX E_ROW_ID .

    if e_column_id = 'MIGO'.
      SET PARAMETER ID 'MBN' FIELD WA_STATUS01-MIGO.
      CALL TRANSACTION  'MB03' AND SKIP FIRST SCREEN.
    elseif e_column_id = 'MIRO'.
      SET PARAMETER ID 'RBN' FIELD WA_STATUS01-MIRO.
      CALL TRANSACTION  'MIR4' AND SKIP FIRST SCREEN.
    elseif e_column_id = 'ML81N'.
      SET PARAMETER ID 'LBL' FIELD WA_STATUS01-ML81N.
      CALL TRANSACTION  'ML81N' AND SKIP FIRST SCREEN.
    endif.



  ENDMETHOD.                    "handle_hotspot_click
ENDCLASS.               "LCL_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*&      Module  STATUS_0402  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0402 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.
* REFRESH t_hvalid_fldc[].
*
*  CLEAR wa_hvalid_fldc.
*  wa_hvalid_fldc-fieldname = 'ICONE'.
*  wa_hvalid_fldc-reptext   = 'Status'.
*  wa_hvalid_fldc-col_opt   = 'X'.
*  APPEND wa_hvalid_fldc TO t_hvalid_fldc.
*  CLEAR wa_hvalid_fldc.




*
*  IF ob_cc_vld_item IS NOT INITIAL.
*    CALL METHOD ob_cc_vld_item->free.
*  ENDIF.
*
*  CREATE OBJECT ob_cc_vld_item
*    EXPORTING
*      container_name = 'CL_GUI_ALV_GRID'.
*
*  CREATE OBJECT ob_cc_grid
*    EXPORTING
*      i_parent = ob_cc_vld_item.
*
*  CALL METHOD ob_cc_grid->set_table_for_first_display
*    CHANGING
*      it_outtab                     = t_status01[]
*      it_fieldcatalog               = t_hvalid_fldc[]
*    EXCEPTIONS
*      invalid_parameter_combination = 1
*      program_error                 = 2
*      too_many_lines                = 3
*      OTHERS                        = 4.
ENDMODULE.                 " STATUS_0402  OUTPUT
