*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_DOWNLOAD_XMLO01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  SET PF-STATUS '0100'.
  SET TITLEBAR '0100'.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_screen OUTPUT.

  MOVE sy-ucomm TO ok_code.

  IF vg_screen IS INITIAL.
    MOVE '0101' TO vg_screen.
  ENDIF.

  IF vg_screen2 IS INITIAL.
    MOVE '0104' TO vg_screen2.
  ENDIF.

  CASE ok_code.
    WHEN 'PESQ'.
      MOVE '0103' TO vg_screen2.
  ENDCASE.

  REFRESH lt_tb_evmn[].
  SELECT *
    FROM zhms_tb_evmn
    INTO TABLE lt_tb_evmn
    FOR ALL ENTRIES IN lt_doctos
    WHERE chave EQ lt_doctos-chave.

  SORT lt_hist_evento BY dataenv horaenv.

  REFRESH lt_hist_eventox[].
  SELECT *
    FROM zhms_tb_histev
    INTO TABLE lt_hist_eventox
    FOR ALL ENTRIES IN lt_doctos
    WHERE chave EQ lt_doctos-chave
      AND ( event EQ '4' OR event EQ '5' ).

  LOOP AT   lt_doctos
       INTO ls_doctos.
    MOVE sy-tabix TO lv_index.

*** Monta LED status MDE
    READ TABLE lt_tb_evmn INTO ls_tb_evmn WITH KEY chave = ls_doctos-chave
                                                   mneum = 'CSTATMDE'.

    IF sy-subrc IS INITIAL.

      CASE ls_tb_evmn-value.
        WHEN '89'.
          ls_doctos-detalmde = '@08@'.
        WHEN '90'.
          ls_doctos-detalmde = '@0A@'.
      ENDCASE.

    ELSE.

      READ TABLE  lt_hist_eventox INTO  ls_hist_eventox WITH KEY chave = ls_doctos-chave BINARY SEARCH.

      IF sy-subrc IS INITIAL AND ls_hist_eventox-xmotivo IS INITIAL.
        ls_doctos-detalmde = '@09@'.
      ELSE.
        ls_doctos-detalmde = '@5F@'.
      ENDIF.

    ENDIF.

    MODIFY lt_doctos FROM ls_doctos INDEX lv_index.
    CLEAR ls_doctos.

  ENDLOOP.

ENDMODULE.                 " MODIFY_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  SUB001  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE sub001 OUTPUT.



ENDMODULE.                 " SUB001  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  M_TEXTEDITOR  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_texteditor OUTPUT.

  DATA: vl_textnote_repid LIKE sy-repid.

*   create control container
  IF ob_cc_dcevt_obs IS INITIAL.

    CREATE OBJECT ob_cc_dcevt_obs
      EXPORTING
        container_name              = 'CC_001'
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.
  ENDIF.

  IF ob_dcevt_obs IS INITIAL.
*   create calls constructor, which initializes, creats and links
*   TextEdit Control
    CREATE OBJECT ob_dcevt_obs
      EXPORTING
        parent                     = ob_cc_dcevt_obs
        wordwrap_mode              = cl_gui_textedit=>wordwrap_at_fixed_position
        wordwrap_position          = 72
        wordwrap_to_linebreak_mode = cl_gui_textedit=>true.

  ENDIF.

  CALL METHOD ob_cc_dcevt_obs->link
    EXPORTING
      repid     = vl_textnote_repid
      container = 'CC_001'.

*    show toolbar and statusbar on this screen
  CALL METHOD ob_dcevt_obs->set_toolbar_mode
    EXPORTING
      toolbar_mode = ob_dcevt_obs->true.

  CALL METHOD ob_dcevt_obs->set_statusbar_mode
    EXPORTING
      statusbar_mode = ob_dcevt_obs->true.

* finally flush
  CALL METHOD cl_gui_cfw=>flush
    EXCEPTIONS
      OTHERS = 1.

ENDMODULE.                 " M_TEXTEDITOR  OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_001'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE tc_001_change_tc_attr OUTPUT.
  DESCRIBE TABLE lt_tc_status LINES tc_001-lines.
ENDMODULE.                    "TC_001_CHANGE_TC_ATTR OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_001'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE tc_001_get_lines OUTPUT.
  g_tc_001_lines = sy-loopc.
ENDMODULE.                    "TC_001_GET_LINES OUTPUT
*&---------------------------------------------------------------------*
*&      Module  M_SEL_EVENT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_sel_event OUTPUT.

**    Verifica se foi selecionado algum valor
  IF ls_eventos-evtet IS INITIAL.
    vg_screen3 = '0104'.
  ENDIF.
  CHECK NOT ls_eventos-evtet IS INITIAL.

**    Seleciona tipo de evento com ET
  READ TABLE lt_eventos INTO ls_eventos WITH KEY evtet = ls_eventos-evtet.

**    Identifica necessidade de justificativa
  IF ls_eventos-cpobs NE 0 AND ls_eventos-evtet  EQ '210240'.
    vg_screen3 = '0102'.
  ELSE.
    vg_screen3 = '0104'.
  ENDIF.

ENDMODULE.                 " M_SEL_EVENT  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0105  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0105 OUTPUT.
  SET PF-STATUS '0105'.
*  SET TITLEBAR 'xxx'.

  REFRESH t_hvalid_fldc[].
  CLEAR wa_hvalid_fldc.
  wa_hvalid_fldc-fieldname = 'CHAVE'.
  wa_hvalid_fldc-reptext   = 'Chaves'.
  wa_hvalid_fldc-col_opt   = 'X'.
  APPEND wa_hvalid_fldc TO t_hvalid_fldc.
  CLEAR wa_hvalid_fldc.

  IF ob_cc_vis_item IS NOT INITIAL.
    CALL METHOD ob_cc_vis_item->free.
  ENDIF.

  CREATE OBJECT ob_cc_vis_item
    EXPORTING
      container_name = 'CL_GUI_VIS_GRID'.

  CREATE OBJECT ob_cc_grid
    EXPORTING
      i_parent = ob_cc_vis_item.

  CALL METHOD ob_cc_grid->set_table_for_first_display
    CHANGING
      it_outtab                     = lt_arq[]
      it_fieldcatalog               = t_hvalid_fldc[]
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.


ENDMODULE.                 " STATUS_0105  OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_LOG_MDE'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE tc_log_mde_change_tc_attr OUTPUT.
  DESCRIBE TABLE lt_doctos LINES tc_log_mde-lines.
ENDMODULE.                    "TC_LOG_MDE_CHANGE_TC_ATTR OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_LOG_MDE'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE tc_log_mde_get_lines OUTPUT.
  g_tc_log_mde_lines = sy-loopc.
ENDMODULE.                    "TC_LOG_MDE_GET_LINES OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_LOG_EV_MDE'. DO NOT CHANGE THIS LIN
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE tc_log_ev_mde_change_tc_attr OUTPUT.
  DESCRIBE TABLE lt_hist_evento LINES tc_log_ev_mde-lines.
ENDMODULE.                    "TC_LOG_EV_MDE_CHANGE_TC_ATTR OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_LOG_EV_MDE'. DO NOT CHANGE THIS LIN
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE tc_log_ev_mde_get_lines OUTPUT.
  g_tc_log_ev_mde_lines = sy-loopc.
ENDMODULE.                    "TC_LOG_EV_MDE_GET_LINES OUTPUT
