*&---------------------------------------------------------------------*
*&  Include           LZHMS_FG_MONITORO01
*&---------------------------------------------------------------------*

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_001'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE tc_001_change_tc_attr OUTPUT.
  DESCRIBE TABLE t_vld_itemx LINES tc_001-lines.
ENDMODULE.                    "TC_001_CHANGE_TC_ATTR OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TS 'TAB_01'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: SETS ACTIVE TAB
MODULE tab_01_active_tab_set OUTPUT.
  tab_01-activetab = g_tab_01-pressed_tab.
  CASE g_tab_01-pressed_tab.
    WHEN c_tab_01-tab1.
      g_tab_01-subscreen = '0408'.
    WHEN c_tab_01-tab2.
      g_tab_01-subscreen = '0409'.
    WHEN OTHERS.
*&SPWIZARD:      DO NOTHING
  ENDCASE.
ENDMODULE.                    "TAB_01_ACTIVE_TAB_SET OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0407  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0407 OUTPUT.
  SET PF-STATUS '0407'.
*  SET TITLEBAR 'xxx'.
ENDMODULE.                 " STATUS_0407  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0408  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0408 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.

  CLEAR wa_hvalid_fldc.
  wa_hvalid_fldc-fieldname = 'ICON'.
  wa_hvalid_fldc-reptext   = 'Status'.
  wa_hvalid_fldc-col_opt   = 'X'.
  APPEND wa_hvalid_fldc TO t_hvalid_fldc.
  CLEAR wa_hvalid_fldc.

  CLEAR wa_hvalid_fldc.
  wa_hvalid_fldc-fieldname = 'ATRIBUTO'.
  wa_hvalid_fldc-reptext   = 'Atributo'.
  wa_hvalid_fldc-col_opt   = 'X'.
  APPEND wa_hvalid_fldc TO t_hvalid_fldc.
  CLEAR wa_hvalid_fldc.

  wa_hvalid_fldc-fieldname = 'LTEXT'.
  wa_hvalid_fldc-reptext   = 'Descrição erro'.
  wa_hvalid_fldc-col_opt   = 'X'.
  APPEND wa_hvalid_fldc TO t_hvalid_fldc.
  CLEAR wa_hvalid_fldc.

  READ TABLE t_chave INTO wa_chave INDEX 1.

  IF sy-subrc IS INITIAL .
    SELECT * FROM zhms_tb_hrvalid INTO TABLE t_hrvalid WHERE chave EQ wa_chave
                                                         AND vldty EQ 'E'
                                                         AND atitm EQ '00000'
                                                         AND ativo EQ 'X'.

    REFRESH  t_es_vld_h[].
    IF sy-subrc IS INITIAL.
      LOOP AT t_hrvalid INTO wa_hrvalid.
        MOVE: '@0A@'           TO wa_es_vld_h-icon,
              wa_hrvalid-vldv2 TO wa_es_vld_h-atributo,
              wa_hrvalid-vldv2 TO wa_es_vld_h-text.
        APPEND wa_es_vld_h     TO t_es_vld_h.
        CLEAR wa_es_vld_h.
      ENDLOOP.
    ENDIF.
  ENDIF.

*** Busca Numero da nota e serie
  SELECT SINGLE * FROM zhms_tb_cabdoc INTO wa_cabdoc WHERE chave EQ  wa_chave.

  IF sy-subrc IS INITIAL.
    CONCATENATE ls_cabdoc-docnr '-' ls_cabdoc-serie INTO vg_nfenum.
  ENDIF.

  IF ob_cc_vld_head IS NOT INITIAL.
    CALL METHOD ob_cc_vld_head->free.
  ENDIF.

  CREATE OBJECT ob_cc_vld_head
    EXPORTING
      container_name = 'CONTAINER_HEADER'.

  CREATE OBJECT ob_cc_grid_head
    EXPORTING
      i_parent = ob_cc_vld_head.

  CALL METHOD ob_cc_grid_head->set_table_for_first_display
    CHANGING
      it_outtab                     = t_es_vld_h[]
      it_fieldcatalog               = t_hvalid_fldc[]
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.

  REFRESH: t_out_vld_i[], t_hvalid_fldc[].

ENDMODULE.                 " STATUS_0408  OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TS 'TABSTRIPLOGS'. DO NOT CHANGE THIS LINE
*&SPWIZARD: SETS ACTIVE TAB
MODULE tabstriplogs_active_tab_set OUTPUT.
  tabstriplogs-activetab = g_tabstriplogs-pressed_tab.
  CASE g_tabstriplogs-pressed_tab.
    WHEN c_tabstriplogs-tab1.
      g_tabstriplogs-subscreen = '0604'.
    WHEN c_tabstriplogs-tab2.
      g_tabstriplogs-subscreen = '0605'.
    WHEN OTHERS.
*&SPWIZARD:      DO NOTHING
  ENDCASE.
ENDMODULE.                    "TABSTRIPLOGS_ACTIVE_TAB_SET OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_LOGSCONEC'. DO NOT CHANGE THIS LINE
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE tc_logsconec_change_tc_attr OUTPUT.
  DESCRIBE TABLE t_logunk LINES tc_logsconec-lines.
ENDMODULE.                    "TC_LOGSCONEC_CHANGE_TC_ATTR OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_LOGSCONEC'. DO NOT CHANGE THIS LINE
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE tc_logsconec_get_lines OUTPUT.
  g_tc_logsconec_lines = sy-loopc.
ENDMODULE.                    "TC_LOGSCONEC_GET_LINES OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_ERROSLOG'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE tc_erroslog_change_tc_attr OUTPUT.
  DESCRIBE TABLE t_logunk LINES tc_erroslogc-lines.
ENDMODULE.                    "TC_ERROSLOG_CHANGE_TC_ATTR OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_ERROSLOG'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE tc_erroslog_get_lines OUTPUT.
  g_tc_erroslog_lines = sy-loopc.
ENDMODULE.                    "TC_ERROSLOG_GET_LINES OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_ERROSLOGS'. DO NOT CHANGE THIS LINE
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE tc_erroslogs_change_tc_attr OUTPUT.
  DESCRIBE TABLE t_logunk LINES tc_erroslogs-lines.
ENDMODULE.                    "TC_ERROSLOGS_CHANGE_TC_ATTR OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_ERROSLOGC'. DO NOT CHANGE THIS LINE
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE tc_erroslogc_change_tc_attr OUTPUT.
  DESCRIBE TABLE t_logunk LINES tc_erroslogc-lines.
ENDMODULE.                    "TC_ERROSLOGC_CHANGE_TC_ATTR OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_ERROSLOGC'. DO NOT CHANGE THIS LINE
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE tc_erroslogc_get_lines OUTPUT.
  g_tc_erroslogc_lines = sy-loopc.
ENDMODULE.                    "TC_ERROSLOGC_GET_LINES OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_ERROSLOGCO'. DO NOT CHANGE THIS LIN
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE tc_erroslogco_change_tc_attr OUTPUT.
  DESCRIBE TABLE t_logunk LINES tc_erroslogco-lines.
ENDMODULE.                    "TC_ERROSLOGCO_CHANGE_TC_ATTR OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_ERROSLOGCO'. DO NOT CHANGE THIS LIN
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE tc_erroslogco_get_lines OUTPUT.
  g_tc_erroslogco_lines = sy-loopc.
ENDMODULE.                    "TC_ERROSLOGCO_GET_LINES OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_ERROSLOGDET'. DO NOT CHANGE THIS LI
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE tc_erroslogdet_change_tc_attr OUTPUT.
  DESCRIBE TABLE t_logdetal LINES tc_erroslogdet-lines.
ENDMODULE.                    "TC_ERROSLOGDET_CHANGE_TC_ATTR OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_ERROSLOGDET'. DO NOT CHANGE THIS LI
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE tc_erroslogdet_get_lines OUTPUT.
  g_tc_erroslogdet_lines = sy-loopc.
ENDMODULE.                    "TC_ERROSLOGDET_GET_LINES OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_SHOW_PO'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE tc_show_po_change_tc_attr OUTPUT.
  DESCRIBE TABLE t_show_po LINES tc_show_po-lines.

  SELECT SINGLE value FROM zhms_tb_docmn INTO wa_docmn WHERE chave EQ wa_cabdoc-chave
                                                       AND ( mneum EQ 'MATDOC'
                                                        OR   mneum EQ 'INVDOCNO' ).

  IF sy-subrc IS INITIAL.
    MOVE abap_true TO lv_block_atrib.
  ELSE.
    CLEAR lv_block_atrib.
  ENDIF.

  IF  lv_block_atrib IS NOT INITIAL.
    LOOP AT SCREEN.

      IF screen-group1 EQ 'BLK'.
        IF vg_just_ok IS NOT INITIAL.
          screen-input = 1.
        ELSE.
          screen-input = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDMODULE.                    "TC_SHOW_PO_CHANGE_TC_ATTR OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_SHOW_PO'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE tc_show_po_get_lines OUTPUT.
  g_tc_show_po_lines = sy-loopc.
ENDMODULE.                    "TC_SHOW_PO_GET_LINES OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0700  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0700 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.

ENDMODULE.                 " STATUS_0700  OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_J1B1N_IMP'. DO NOT CHANGE THIS LINE
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE tc_j1b1n_imp_change_tc_attr OUTPUT.
  DESCRIBE TABLE t_impostos LINES tc_j1b1n_imp-lines.
ENDMODULE.                    "TC_J1B1N_IMP_CHANGE_TC_ATTR OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TEXT_EDITOR  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE text_editor OUTPUT.

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


  SELECT SINGLE *
    FROM zhms_tb_justific
    INTO wa_just
   WHERE chave EQ vg_chave
     AND item  EQ wa_itmatr-dcitm.

  IF sy-subrc IS INITIAL.
    REFRESH tl_textnote.
    APPEND wa_just-just TO tl_textnote.

** Recupera o texto digitado no editor
    CALL METHOD ob_dcevt_obs->set_text_as_r3table
      EXPORTING
        table = tl_textnote.

  ENDIF.

ENDMODULE.                 " TEXT_EDITOR  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0504  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0504 OUTPUT.

  SET PF-STATUS '0504'.
  SET TITLEBAR  '0504'.

  IF ob_dcevt_obs IS NOT INITIAL.
    SELECT SINGLE *
      FROM zhms_tb_justific
      INTO wa_just
     WHERE chave EQ vg_chave
       AND item  EQ wa_itmatr-dcitm.

    IF sy-subrc IS INITIAL.
      REFRESH tl_textnote.
      APPEND wa_just-just TO tl_textnote.

** Recupera o texto digitado no editor
      CALL METHOD ob_dcevt_obs->set_text_as_r3table
        EXPORTING
          table = tl_textnote.

    ENDIF.
  ENDIF.
ENDMODULE.                 " STATUS_0504  OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TS 'ABA_001'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: SETS ACTIVE TAB
MODULE aba_001_active_tab_set OUTPUT.
  aba_001-activetab = g_aba_001-pressed_tab.
  CASE g_aba_001-pressed_tab.
    WHEN c_aba_001-tab1.
      g_aba_001-subscreen = '0801'.
    WHEN c_aba_001-tab2.
      g_aba_001-subscreen = '0802'.
    WHEN c_aba_001-tab3.
      g_aba_001-subscreen = '0803'.
    WHEN OTHERS.
*&SPWIZARD:      DO NOTHING
  ENDCASE.
ENDMODULE.                    "ABA_001_ACTIVE_TAB_SET OUTPUT
*&---------------------------------------------------------------------*
*&      Module  M_ATR_CALCULO_QTN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_atr_calculo_qtn OUTPUT.

  IF vg_atprp IS NOT INITIAL.
    LOOP AT t_itmatr_ax INTO wa_itmatr_ax.
      MOVE sy-tabix TO v_index.

      READ TABLE t_docmn INTO wa_docmn WITH KEY chave = wa_itmatr_ax-chave
                                                dcitm = wa_itmatr_ax-dcitm
                                                mneum = 'VUNCOM'.

      IF sy-subrc IS INITIAL.
        wa_itmatr_ax-atprc = wa_itmatr_ax-atqtd * wa_docmn-value.
        MODIFY t_itmatr_ax FROM wa_itmatr_ax INDEX v_index.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDMODULE.                 " M_ATR_CALCULO_QTN  OUTPUT
