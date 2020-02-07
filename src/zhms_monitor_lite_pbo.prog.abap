*&---------------------------------------------------------------------*
*&  Include           ZHMS_MONITOR_LITE_PBO
*&---------------------------------------------------------------------*
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
*&      Module  F_MONTA_ALV  OUTPUT
*&---------------------------------------------------------------------*
MODULE f_monta_alv OUTPUT.

  DATA: wa_layout               TYPE lvc_s_layo.

  CHECK ob_cc_0100 IS INITIAL.

  PERFORM f_fieldcat USING: 'CHECKBOX'  text-007 'X' '' 'X' 'X' '',
                            'STHMS'     text-009 'X' '' '' '' 'X',
                            'FLOW'      text-012 'X' 'X' '' '' '',
                            'SHOWXML'   text-013 'X' 'X' '' '' '',
                            'DOCNR'     text-002 'X' 'X' '' '' '',
                            'DOCDT'     text-003 'X' '' '' '' '',
                            'CNPJ'      text-005 'X' '' '' '' '',
                            'NAME1'     text-004 'X' '' '' '' '',
                            'VNF'       text-006 'X' '' '' '' '',
                            'CHAVE'     text-008 'X' '' '' '' ''.

** CC para o alv do XML
  IF ob_cc_0100 IS NOT INITIAL.
    CALL METHOD ob_cc_0100->free.
  ENDIF.

  CREATE OBJECT ob_cc_0100
    EXPORTING
      container_name = 'CC_0100'.

  CREATE OBJECT ob_cc_0100_grid
    EXPORTING
      i_parent = ob_cc_0100.

  wa_layout-zebra = 'X'.

* Remove Botoes
  PERFORM zf_exclude.

  SORT t_0100 BY docnr.

  CALL METHOD ob_cc_0100_grid->set_table_for_first_display
    EXPORTING
      it_toolbar_excluding          = it_exclude
      is_layout                     = wa_layout
    CHANGING
      it_outtab                     = t_0100
      it_fieldcatalog               = t_ht_field
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.

  CALL METHOD ob_cc_0100_grid->refresh_table_display.

  CREATE OBJECT lcl_event_receiver.
  SET HANDLER lcl_event_receiver->handel_hotspot_click FOR ob_cc_0100_grid.

ENDMODULE.                 " F_MONTA_ALV  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  F_PREPARA_DADOS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f_prepara_dados OUTPUT.
  SORT t_lfa1 BY lifnr.

  IF ob_cc_0100_grid IS NOT INITIAL.
    CALL METHOD ob_cc_0100_grid->refresh_table_display.
  ENDIF.

  CHECK t_0100 IS INITIAL.

  LOOP AT t_cabdoc INTO wa_cabdoc.

* Busca status do documento
    READ TABLE t_docst INTO wa_docst WITH KEY chave = wa_cabdoc-chave BINARY SEARCH.
    IF sy-subrc EQ 0.
* Suceso - OK
      IF wa_docst-sthms = 1.
        wa_0100-sthms = '@0V@'.

* Waiting
      ELSEIF wa_docst-sthms = 2.
        wa_0100-sthms = '@9R@'.

* Warning
      ELSEIF wa_docst-sthms = 3.
        wa_0100-sthms = '@5D@'.

* Error
      ELSEIF wa_docst-sthms = 4.
        wa_0100-sthms = '@0W@'.
      ENDIF.
    ENDIF.
    wa_0100-chave = wa_cabdoc-chave.
    wa_0100-docnr = wa_cabdoc-docnr.
    wa_0100-docdt = wa_cabdoc-docdt.
    wa_0100-flow = '@5O@'.
    wa_0100-showxml = '@R4@'.

    READ TABLE t_lfa1 INTO wa_lfa1 WITH KEY lifnr = wa_cabdoc-parid BINARY SEARCH.
    IF sy-subrc EQ 0.
      wa_0100-name1 = wa_lfa1-name1.
      wa_0100-cnpj = wa_lfa1-stcd1.
    ENDIF.

    SELECT SINGLE value
      FROM zhms_tb_docmn
      INTO wa_docmn-value
      WHERE chave = wa_cabdoc-chave
        AND mneum = 'VNF'.

    IF sy-subrc EQ 0.
      wa_0100-vnf = wa_docmn-value.
    ENDIF.

    APPEND wa_0100 TO t_0100.
  ENDLOOP.
ENDMODULE.                 " F_PREPARA_DADOS  OUTPUT

*----------------------------------------------------------------------*
*   Module  M_STATUS_0500  OUTPUT
*----------------------------------------------------------------------*
*   Botões e Menus da Tela 0500
*----------------------------------------------------------------------*
MODULE m_status_0500 OUTPUT.
  DATA: tl_codes       TYPE TABLE OF sy-ucomm.

  SET TITLEBAR  '0500'.
  REFRESH tl_codes.

  IF vg_0500 EQ '0501'.
    APPEND: 'ATR_GRAVAR' TO tl_codes.
  ENDIF.

  SET PF-STATUS '0500' EXCLUDING tl_codes.

ENDMODULE.                 " M_STATUS_0500  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  M_SHOW_ATRITENS  OUTPUT
*&---------------------------------------------------------------------*
*       Controles para ítens de documento - Atribuição
*----------------------------------------------------------------------*
MODULE m_show_atritens OUTPUT.
  CHECK NOT vg_chave IS INITIAL.

***   Carregando Estrutura de Campos
  PERFORM f_build_fieldcat_itens.

  IF ob_cc_atr_itens IS INITIAL.
***     Criando Container para TREE do XML
    CREATE OBJECT ob_cc_atr_itens
      EXPORTING
        container_name              = 'CC_ATR_ITENS'
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.

    IF sy-subrc NE 0.
***       Erro Interno. Contatar Suporte.
      MESSAGE e000 WITH text-000.
      STOP.
    ENDIF.
  ENDIF.

  IF NOT ob_atr_itens IS INITIAL.

    CALL METHOD ob_atr_itens->free
      EXCEPTIONS
        cntl_error        = 1
        cntl_system_error = 2
        OTHERS            = 3.

  ENDIF.

***     Criando Objeto TREE para XML
  CREATE OBJECT ob_atr_itens
    EXPORTING
      parent                      = ob_cc_atr_itens
      node_selection_mode         = cl_gui_column_tree=>node_sel_mode_single
      item_selection              = 'X'
      no_html_header              = 'X'
      no_toolbar                  = 'X'
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      illegal_node_selection_mode = 5
      failed                      = 6
      illegal_column_name         = 7.

  IF sy-subrc <> 0.
***       Erro Interno. Contatar Suporte.
    MESSAGE e000 WITH text-000.
    STOP.
  ENDIF.

***   Setando valores do Header da TREE
  PERFORM f_build_hier_header_itens.

  CLEAR wa_variant.
  MOVE  sy-repid TO wa_variant-report.

***   create emty tree-control
  REFRESH t_itensview.

  CALL METHOD ob_atr_itens->set_table_for_first_display
    EXPORTING
      is_hierarchy_header = wa_hier_header
      is_variant          = wa_variant
    CHANGING
      it_outtab           = t_itensview
      it_fieldcatalog     = t_fieldcatitm.

***   Criando Hierarquia da TREE do XML
  PERFORM f_create_hier_itens_atr.

  CALL METHOD cl_gui_cfw=>flush
    EXCEPTIONS
      cntl_system_error = 1
      cntl_error        = 2
      OTHERS            = 3.

  IF sy-subrc <> 0.
***     Erro Interno. Contatar Suporte.
    MESSAGE e000 WITH text-000.
  ENDIF.

  CALL METHOD ob_atr_itens->column_optimize.

***   Registrando Eventos da Tree de Atribuição
  PERFORM f_reg_events_atr.


ENDMODULE.                 " M_SHOW_ATRITENS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  M_SHOW_DOCITENS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_show_docitens OUTPUT.
  CHECK NOT vg_chave IS INITIAL.

  IF ob_vis_itens IS NOT INITIAL.
    CALL METHOD ob_vis_itens->free.
    CLEAR ob_vis_itens.
  ENDIF.
  IF ob_cc_vis_itens IS NOT INITIAL.
    CALL METHOD ob_cc_vis_itens->free.
    CLEAR ob_cc_vis_itens.
  ENDIF.

***   Carregando Estrutura de Campos
  PERFORM f_build_fieldcat_itens.

  IF ob_cc_vis_itens IS INITIAL.
***     Criando Container para TREE do XML
    CREATE OBJECT ob_cc_vis_itens
      EXPORTING
        container_name              = 'CC_VIS_ITENS'
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.

    IF sy-subrc NE 0.
***       Erro Interno. Contatar Suporte.
      MESSAGE e000 WITH text-000.
      STOP.
    ENDIF.
  ENDIF.

**    Verifica existencia da tree
  IF NOT ob_vis_itens IS INITIAL.
**      Caso exista, limpa os registros
    CALL METHOD ob_vis_itens->delete_all_nodes
      EXCEPTIONS
        failed            = 1
        cntl_system_error = 2
        OTHERS            = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ELSE.

***     Criando Objeto TREE para XML
    CREATE OBJECT ob_vis_itens
      EXPORTING
        parent                      = ob_cc_vis_itens
        node_selection_mode         = cl_gui_column_tree=>node_sel_mode_single
        item_selection              = 'X'
        no_html_header              = 'X'
        no_toolbar                  = 'X'
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        illegal_node_selection_mode = 5
        failed                      = 6
        illegal_column_name         = 7.

    IF sy-subrc <> 0.
***       Erro Interno. Contatar Suporte.
      MESSAGE e000 WITH text-000.
      STOP.
    ENDIF.
  ENDIF.

***   Setando valores do Header da TREE
  PERFORM f_build_hier_header_itens.

  CLEAR wa_variant.
  MOVE  sy-repid TO wa_variant-report.

***   create emty tree-control
  REFRESH t_itensview.

  CALL METHOD ob_vis_itens->set_table_for_first_display
    EXPORTING
      is_hierarchy_header = wa_hier_header
      is_variant          = wa_variant
    CHANGING
      it_outtab           = t_itensview
      it_fieldcatalog     = t_fieldcatitm.

  REFRESH t_fieldcatitm.
  CLEAR t_fieldcatitm.

***   Criando Hierarquia da TREE do XML
  PERFORM f_create_hier_itens.

  CALL METHOD cl_gui_cfw=>flush
    EXCEPTIONS
      cntl_system_error = 1
      cntl_error        = 2
      OTHERS            = 3.

  IF sy-subrc <> 0.
***     Erro Interno. Contatar Suporte.
    MESSAGE e000 WITH text-000.
  ENDIF.

  CALL METHOD ob_vis_itens->column_optimize.
ENDMODULE.                 " M_SHOW_DOCITENS  OUTPUT

*----------------------------------------------------------------------*
*  MODULE tc_show_po_change_tc_attr OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
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

*&---------------------------------------------------------------------*
*&      Module  STATUS_0503  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0503 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.
  REFRESH t_show_po[].
  CALL FUNCTION 'ZHMS_FM_BUSCA_PO_POSSIVEIS'
    EXPORTING
      chave     = vg_chave
    TABLES
      t_show_po = t_show_po.

ENDMODULE.                 " STATUS_0503  OUTPUT

*----------------------------------------------------------------------*
*  MODULE tc_show_po_mark INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE tc_show_po_mark INPUT.
  DATA: g_tc_show_po_wa2 LIKE LINE OF t_show_po.
  IF tc_show_po-line_sel_mode = 1
  AND wa_show_po-mark = 'X'.
    LOOP AT t_show_po INTO g_tc_show_po_wa2
      WHERE mark = 'X'.
      g_tc_show_po_wa2-mark = ''.
      MODIFY t_show_po
        FROM g_tc_show_po_wa2
        TRANSPORTING mark.
    ENDLOOP.
  ENDIF.
  MODIFY t_show_po
    FROM wa_show_po
    INDEX tc_show_po-current_line
    TRANSPORTING mark.
ENDMODULE.                    "TC_SHOW_PO_MARK INPUT

*&---------------------------------------------------------------------*
*&      Module  TC_SHOW_PO_GET_LINES  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_show_po_get_lines OUTPUT.
  g_tc_show_po_lines = sy-loopc.
ENDMODULE.                 " TC_SHOW_PO_GET_LINES  OUTPUT
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
*&      Module  TAB_01_ACTIVE_TAB_SET  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
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
ENDMODULE.                 " TAB_01_ACTIVE_TAB_SET  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0408  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0408 OUTPUT.

*  TYPES:
*  BEGIN OF ty_grp,
*    grp TYPE zhms_de_grp,
*  END OF ty_grp.
*
  DATA: event_receiver TYPE REF TO lcl_hotspot_click.
*        e_object       TYPE REF TO cl_alv_event_toolbar_set,
*        ls_cabdoc      TYPE zhms_tb_cabdoc,
*        lt_itmatr      TYPE STANDARD TABLE OF zhms_tb_itmatr,
*        ls_itmatr      LIKE LINE OF lt_itmatr,
*        lt_grp         TYPE STANDARD TABLE OF ty_grp,
*        ls_grp         LIKE LINE OF lt_grp.

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
*  SELECT SINGLE * FROM zhms_tb_cabdoc INTO wa_cabdoc WHERE chave EQ wa_chave.
  SELECT SINGLE * FROM zhms_tb_cabdoc INTO wa_cabdoc WHERE chave EQ wa_cabdoc-chave.

  IF sy-subrc IS INITIAL.
    CONCATENATE ls_cabdoc-docnr '-' ls_cabdoc-serie INTO vg_nfenum.
  ENDIF.

  IF ob_cc_vld_head IS NOT
     INITIAL.
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
*&---------------------------------------------------------------------*
*&      Module  STATUS_0110  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0110 OUTPUT.

*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.

*  TYPES:
*  BEGIN OF ty_grp,
*    grp TYPE zhms_de_grp,
*  END OF ty_grp.

*  DATA: event_receiver TYPE REF TO lcl_hotspot_click,
*        e_object       TYPE REF TO cl_alv_event_toolbar_set,
*        ls_cabdoc      TYPE zhms_tb_cabdoc,
*        lt_itmatr      TYPE STANDARD TABLE OF zhms_tb_itmatr,
*        ls_itmatr      LIKE LINE OF lt_itmatr,
*        lt_grp         TYPE STANDARD TABLE OF ty_grp,
*        ls_grp         LIKE LINE OF lt_grp.

  REFRESH: t_out_vld_i[], t_hvalid_fldc[].

  CLEAR wa_hvalid_fldc.
  wa_hvalid_fldc-fieldname = 'ICON'.
  wa_hvalid_fldc-reptext   = 'Status'.
  wa_hvalid_fldc-col_opt   = 'X'.
  APPEND wa_hvalid_fldc TO t_hvalid_fldc.
  CLEAR wa_hvalid_fldc.

  wa_hvalid_fldc-fieldname = 'ATITM'.
  wa_hvalid_fldc-reptext   = 'Nº Item Atribuição'.
  wa_hvalid_fldc-col_opt   = 'X'.
  APPEND wa_hvalid_fldc TO t_hvalid_fldc.
  CLEAR wa_hvalid_fldc.

  wa_hvalid_fldc-fieldname = 'DCITM'.
  wa_hvalid_fldc-reptext   = 'Nº Item NF-e'.
  wa_hvalid_fldc-col_opt   = 'X'.
  APPEND wa_hvalid_fldc TO t_hvalid_fldc.
  CLEAR wa_hvalid_fldc.

  wa_hvalid_fldc-fieldname = 'LTEXT'.
  wa_hvalid_fldc-reptext   = 'Descrição erro'.
  wa_hvalid_fldc-hotspot   = 'X'.
*      wa_hvalid_fldc-col_opt   = 'X'.
  wa_hvalid_fldc-outputlen = '200'.
  APPEND wa_hvalid_fldc TO t_hvalid_fldc.
  CLEAR wa_hvalid_fldc.

*  READ TABLE t_chave INTO wa_chave INDEX 1.
  wa_chave = wa_cabdoc-chave.

*  IF sy-subrc IS INITIAL .

*** Seleciona Niveis de prioridade
  SELECT DISTINCT grp FROM zhms_tb_messages INTO TABLE lt_grp WHERE grp IS NOT NULL.

  IF sy-subrc IS INITIAL.
    LOOP AT lt_grp INTO ls_grp.
      SELECT * FROM zhms_tb_hrvalid INTO TABLE t_hrvalid WHERE chave EQ wa_chave
                                                           AND vldty EQ 'E'
                                                           AND atitm NE '00000'
                                                           AND grp   EQ ls_grp-grp
                                                           AND ativo EQ 'X'.
      IF sy-subrc IS INITIAL.
        EXIT.
      ENDIF.
    ENDLOOP.

    REFRESH  t_es_vld_i[].
    IF sy-subrc IS INITIAL.

*        SELECT * FROM zhms_tb_itmatr INTO TABLE lt_itmatr WHERE chave EQ wa_chave.
      SELECT * FROM zhms_tb_itmatr INTO TABLE lt_itmatr WHERE chave EQ wa_cabdoc-chave.

      LOOP AT t_hrvalid INTO wa_hrvalid.

        READ TABLE lt_itmatr INTO ls_itmatr WITH KEY atitm = wa_hrvalid-atitm BINARY SEARCH.

        IF sy-subrc IS INITIAL.
          MOVE: ls_itmatr-dcitm TO wa_out_vld_i-dcitm.
        ELSE.
          CLEAR wa_out_vld_i-dcitm.
        ENDIF.

        MOVE: '@0A@' TO wa_out_vld_i-icon,
              wa_hrvalid-atitm TO wa_out_vld_i-atitm,
              wa_hrvalid-vldv2 TO wa_out_vld_i-ltext.
        APPEND wa_out_vld_i TO t_out_vld_i.
        CLEAR wa_out_vld_i.
      ENDLOOP.
    ENDIF.
  ENDIF.
*  ENDIF.

** Busca Numero da nota e serie
*  SELECT SINGLE * FROM zhms_tb_cabdoc INTO ls_cabdoc WHERE chave EQ wa_chave.
  SELECT SINGLE * FROM zhms_tb_cabdoc INTO ls_cabdoc WHERE chave EQ wa_cabdoc-chave.

  IF sy-subrc IS INITIAL.
    CONCATENATE ls_cabdoc-docnr '-' ls_cabdoc-serie INTO vg_nfenum.
  ENDIF.
  IF ob_cc_vld_item IS NOT INITIAL.
    CALL METHOD ob_cc_vld_item->free.
  ENDIF.

  CREATE OBJECT ob_cc_vld_item
    EXPORTING
      container_name = 'CL_GUI_ALV_GRID'.

  CREATE OBJECT ob_cc_grid
    EXPORTING
      i_parent = ob_cc_vld_item.

  CALL METHOD ob_cc_grid->set_table_for_first_display
    CHANGING
      it_outtab                     = t_out_vld_i[]
      it_fieldcatalog               = t_hvalid_fldc[]
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.
  CREATE OBJECT event_receiver.
  SET HANDLER event_receiver->handle_hotspot_click FOR ob_cc_grid.
  CREATE OBJECT e_object.
ENDMODULE.                 " STATUS_0110  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0301  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0301 OUTPUT.

  SET PF-STATUS '0301'.
  SET TITLEBAR  '0301'.

  REFRESH t_ht_field[].

*** Natureza Documento
  CLEAR wa_hvalid_fldc.
  wa_ht_field-fieldname = 'NATDC'.
  wa_ht_field-reptext   = 'Natureza Doc.'.
  wa_ht_field-col_opt   = 'X'.
  APPEND wa_ht_field TO t_ht_field.
  CLEAR wa_ht_field.

*** Tipo Documento
  CLEAR wa_hvalid_fldc.
  wa_ht_field-fieldname = 'TYPED'.
  wa_ht_field-reptext   = 'Tipo Doc.'.
  wa_ht_field-col_opt   = 'X'.
  APPEND wa_ht_field TO t_ht_field.
  CLEAR wa_ht_field.

*** Evento
  CLEAR wa_hvalid_fldc.
  wa_ht_field-fieldname = 'EVENT'.
  wa_ht_field-reptext   = 'Evento'.
  wa_ht_field-col_opt   = 'X'.
  APPEND wa_ht_field TO t_ht_field.
  CLEAR wa_ht_field.

*** Tipo do evento entidade tributária
  CLEAR wa_hvalid_fldc.
  wa_ht_field-fieldname = 'TPEVE'.
  wa_ht_field-reptext   = 'Tipo do evento'.
  wa_ht_field-col_opt   = 'X'.
  APPEND wa_ht_field TO t_ht_field.
  CLEAR wa_ht_field.

*** Nº Sequencia
  CLEAR wa_hvalid_fldc.
  wa_ht_field-fieldname = 'NSEQEV'.
  wa_ht_field-reptext   = 'Nº Seq.Evento'.
  wa_ht_field-col_opt   = 'X'.
  APPEND wa_ht_field TO t_ht_field.
  CLEAR wa_ht_field.

*** Nº Lote
  CLEAR wa_hvalid_fldc.
  wa_ht_field-fieldname = 'LOTE'.
  wa_ht_field-reptext   = 'Nº Lote'.
  wa_ht_field-col_opt   = 'X'.
  APPEND wa_ht_field TO t_ht_field.
  CLEAR wa_ht_field.

*** Xmotivo
  CLEAR wa_hvalid_fldc.
  wa_ht_field-fieldname = 'XMOTIVO'.
  wa_ht_field-reptext   = 'Texto Histórico'.
  wa_ht_field-col_opt   = 'X'.
  APPEND wa_ht_field TO t_ht_field.
  CLEAR wa_ht_field.

*** Data e Hora do registro
  CLEAR wa_hvalid_fldc.
  wa_ht_field-fieldname = 'DTHRREG'.
  wa_ht_field-reptext   = 'Data e Hora gravação do registro'.
  wa_ht_field-col_opt   = 'X'.
  APPEND wa_ht_field TO t_ht_field.
  CLEAR wa_ht_field.

*** Nº Protocolo
  CLEAR wa_hvalid_fldc.
  wa_ht_field-fieldname = 'PROTOCO'.
  wa_ht_field-reptext   = 'Nº Protocolo'.
  wa_ht_field-col_opt   = 'X'.
  APPEND wa_ht_field TO t_ht_field.
  CLEAR wa_ht_field.

*** Data envio
  CLEAR wa_hvalid_fldc.
  wa_ht_field-fieldname = 'DATAENV'.
  wa_ht_field-reptext   = 'Data envio do evento'.
  wa_ht_field-col_opt   = 'X'.
  APPEND wa_ht_field TO t_ht_field.
  CLEAR wa_ht_field.

*** Hora envio
  CLEAR wa_hvalid_fldc.
  wa_ht_field-fieldname = 'HORAENV'.
  wa_ht_field-reptext   = 'Hora envio do evento'.
  wa_ht_field-col_opt   = 'X'.
  APPEND wa_ht_field TO t_ht_field.
  CLEAR wa_ht_field.

*** Usuário
  CLEAR wa_hvalid_fldc.
  wa_ht_field-fieldname = 'USUARIO'.
  wa_ht_field-reptext   = 'Usuario Responsável'.
  wa_ht_field-col_opt   = 'X'.
  APPEND wa_ht_field TO t_ht_field.
  CLEAR wa_ht_field.

*  READ TABLE t_chave INTO wa_chave INDEX 1.

*  IF sy-subrc IS INITIAL .

  REFRESH t_ht_out[].
  CLEAR wa_ht_out.
*    SELECT * FROM zhms_tb_histev INTO TABLE t_ht_histo WHERE chave EQ wa_chave.
  SELECT * FROM zhms_tb_histev INTO TABLE t_ht_histo WHERE chave EQ wa_cabdoc-chave.

  IF sy-subrc IS INITIAL.
    LOOP AT t_ht_histo INTO wa_ht_histo.

      SELECT SINGLE denom
        FROM zhms_tx_events
        INTO wa_ht_out-event
       WHERE natdc EQ wa_cabdoc-natdc
         AND typed EQ wa_cabdoc-typed.

      IF sy-subrc IS INITIAL.
        CASE wa_ht_histo-natdc .
          WHEN '01'.
            MOVE 'Emissão de Documentos' TO wa_ht_out-natdc.
          WHEN '02'.
            MOVE 'Recepção de Documentos' TO wa_ht_out-natdc.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.

      MOVE: wa_ht_histo-typed   TO wa_ht_out-typed,
            wa_ht_histo-tpeve   TO wa_ht_out-tpeve,
            wa_ht_histo-nseqev  TO wa_ht_out-nseqev,
            wa_ht_histo-lote    TO wa_ht_out-lote,
            wa_ht_histo-xmotivo TO wa_ht_out-xmotivo,
            wa_ht_histo-dthrreg TO wa_ht_out-dthrreg,
            wa_ht_histo-protoco TO wa_ht_out-protoco,
            wa_ht_histo-dataenv TO wa_ht_out-dataenv,
            wa_ht_histo-horaenv TO wa_ht_out-horaenv,
            wa_ht_histo-usuario TO wa_ht_out-usuario.
      APPEND wa_ht_out TO t_ht_out.
      CLEAR wa_ht_out.
    ENDLOOP.
  ENDIF.

*  ENDIF.

  IF ob_cc_ht IS NOT INITIAL.
    CALL METHOD ob_cc_ht->free.
  ENDIF.

  CREATE OBJECT ob_cc_ht
    EXPORTING
      container_name = 'CC_HIST_ETAPA'.

  CREATE OBJECT ob_cc_ht_grid
    EXPORTING
      i_parent = ob_cc_ht.

  CALL METHOD ob_cc_ht_grid->set_table_for_first_display
    CHANGING
      it_outtab                     = t_ht_out[]
      it_fieldcatalog               = t_ht_field[]
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.


ENDMODULE.                 " STATUS_0301  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0605  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0605 OUTPUT.
  SET PF-STATUS '0606'.
  SET TITLEBAR '0606'.
ENDMODULE.                 " STATUS_0605  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  M_CALC_AUDI  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_calc_audi OUTPUT.
  DATA: po_number     TYPE bapimepoheader-po_number,
        ls_po_header  TYPE  bapimepoheader,
        lt_po_item    TYPE STANDARD TABLE OF bapimepoitem,
        lt_hist_total TYPE STANDARD TABLE OF bapiekbes,
        ls_hist_total LIKE LINE OF lt_hist_total,
        ls_po_item    LIKE LINE OF lt_po_item,
        lv_item       TYPE zhms_de_value,
        lv_qtd        TYPE zhms_de_value,
        lv_atqtde     TYPE zhms_de_value,
        lv_qtd_at     TYPE zhms_de_value,
        lv_icms       TYPE zhms_de_value,
        lv_ipi        TYPE zhms_de_value,
        lv_sqn        TYPE zhms_de_value,
        lv_pis        TYPE zhms_de_value,
        lv_cof        TYPE zhms_de_value,
        lv_sst        TYPE zhms_de_value,
        lv_calc       TYPE wemng,
        lv_calc2      TYPE wemng,
        lv_calc3      TYPE wemng,
        lv_calc4      TYPE wemng,
        lv_tot_kbetr  TYPE komv-kbetr,
        lv_cont_1baj  TYPE i,
        lv_div_ped    TYPE komv-kbetr,
        lv_div_xml    TYPE komv-kbetr,
        lv_div_ped_c  TYPE char20,
        lv_div_xml_c  TYPE char20,
        lv_dif        TYPE p DECIMALS 2 VALUE '0.10',
        lv_sub        TYPE komv-kbetr,
        lv_ebeln      TYPE ebeln,
        lv_baseped    TYPE p DECIMALS 2,
        vg_ncm_xml    TYPE char8,
        vg_ncm_mne    TYPE char8,
        lv_val_unit   TYPE p DECIMALS 2.

  DATA: wa_ekko       TYPE ekko,
        vg_message    TYPE string,
        it_docmni     TYPE TABLE OF zhms_tb_docmn,
        wa_docmni     TYPE zhms_tb_docmn,
        t_tb_vld_tax  TYPE TABLE OF zhms_tb_vld_tax,
        ls_tb_vld_tax LIKE LINE OF t_tb_vld_tax,
        t_komv        TYPE STANDARD TABLE OF komv,
        t_1baj        TYPE STANDARD TABLE OF j_1baj,
        it_komk       TYPE STANDARD TABLE OF komk,
        it_komp       TYPE STANDARD TABLE OF komp,
        it_docmnx TYPE TABLE OF zhms_tb_docmn,

        wa_komk       LIKE LINE OF it_komk,
        wa_komp       LIKE LINE OF it_komp,
        wa_komv               LIKE LINE OF t_komv,
        wa_1baj               TYPE j_1baj.

  CLEAR: t_alv_ped, t_alv_xml, t_alv_comp.

*      break rsantos.

*** Seleciona quis validações estão habilitadas
  REFRESH t_tb_vld_tax[].
  SELECT *
    FROM zhms_tb_vld_tax
    INTO TABLE t_tb_vld_tax
   WHERE tax_type NE ' '.

  SELECT *
    FROM zhms_tb_itmatr
    INTO TABLE t_itmatr
    WHERE chave = wa_cabdoc-chave.

  LOOP AT t_itmatr INTO wa_itmatr.

    REFRESH lt_po_item[].
    CLEAR: wa_docmnx, wa_ekko, vg_message, ls_po_item.

**** Verifica se o pedido existe
    SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_itmatr-chave
                                                         AND mneum EQ 'ATPED'
                                                         AND atitm EQ wa_itmatr-atitm.
    IF sy-subrc IS INITIAL.
      MOVE wa_docmnx-value TO lv_ebeln.
    ELSE.
      MOVE wa_itmatr-nrsrf TO lv_ebeln.
    ENDIF.

    CHECK lv_ebeln IS NOT INITIAL.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = lv_ebeln
      IMPORTING
        output = lv_ebeln.

*** Busca Detalhes Pedido de compras
*** Inicio alteração david rosin 16/07/2015
*    MOVE wa_docmnx-value TO po_number.
    MOVE lv_ebeln TO po_number.
*** Fim alteração david rosin 16/07/2015

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = po_number
      IMPORTING
        output = po_number.

    CALL FUNCTION 'BAPI_PO_GETDETAIL1'
      EXPORTING
        purchaseorder    = po_number
      IMPORTING
        poheader         = ls_po_header
      TABLES
        poitem           = lt_po_item
        pohistory_totals = lt_hist_total.

    SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_itmatr-chave
                                                         AND mneum EQ 'XPROD'
                                                         AND dcitm EQ wa_itmatr-atitm.
    IF sy-subrc EQ 0.
      wa_alv_xml-item = wa_itmatr-atitm.
      wa_alv_xml-desc = wa_docmnx-value.
    ENDIF.

    SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_itmatr-chave
                                                         AND mneum EQ 'UCOM'
                                                         AND dcitm EQ wa_itmatr-atitm.
    IF sy-subrc EQ 0.
      wa_alv_xml-item = wa_itmatr-atitm.
      wa_alv_xml-unidade = wa_docmnx-value.
    ENDIF.

    SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_itmatr-chave
                                                         AND mneum EQ 'QCOM'
                                                         AND dcitm EQ wa_itmatr-atitm.
    IF sy-subrc EQ 0.
      wa_alv_xml-item = wa_itmatr-atitm.
      wa_alv_xml-qtde = wa_docmnx-value.
    ENDIF.

    SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_itmatr-chave
                                                         AND mneum EQ 'VPROD'
                                                         AND dcitm EQ wa_itmatr-atitm.
    IF sy-subrc EQ 0.
      wa_alv_xml-item = wa_itmatr-atitm.
      wa_alv_xml-vprod = wa_docmnx-value.
    ENDIF.

    SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_itmatr-chave
                                                         AND mneum EQ 'PICMS'
                                                         AND dcitm EQ wa_itmatr-atitm.
    IF sy-subrc EQ 0.
      wa_alv_xml-item = wa_itmatr-atitm.
      wa_alv_xml-picms = wa_docmnx-value.
    ENDIF.

    SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_itmatr-chave
                                                         AND mneum EQ 'VICMS'
                                                         AND dcitm EQ wa_itmatr-atitm.
    IF sy-subrc EQ 0.
      wa_alv_xml-item = wa_itmatr-atitm.
      wa_alv_xml-vicms = wa_docmnx-value.
    ENDIF.

    SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_itmatr-chave
                                                         AND mneum EQ 'PIPI'
                                                         AND dcitm EQ wa_itmatr-atitm.
    IF sy-subrc EQ 0.
      wa_alv_xml-item = wa_itmatr-atitm.
      wa_alv_xml-pipi = wa_docmnx-value.
    ENDIF.

    SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_itmatr-chave
                                                         AND mneum EQ 'VIPI'
                                                         AND dcitm EQ wa_itmatr-atitm.
    IF sy-subrc EQ 0.
      wa_alv_xml-item = wa_itmatr-atitm.
      wa_alv_xml-vipi = wa_docmnx-value.
    ENDIF.

    SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_itmatr-chave
                                                         AND mneum EQ 'PPIS'
                                                         AND dcitm EQ wa_itmatr-atitm.
    IF sy-subrc EQ 0.
      wa_alv_xml-item = wa_itmatr-atitm.
      wa_alv_xml-ppis = wa_docmnx-value.
    ENDIF.

    SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_itmatr-chave
                                                         AND mneum EQ 'VPIS'
                                                         AND dcitm EQ wa_itmatr-atitm.
    IF sy-subrc EQ 0.
      wa_alv_xml-item = wa_itmatr-atitm.
      wa_alv_xml-vpis = wa_docmnx-value.
    ENDIF.

    SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_itmatr-chave
                                                         AND mneum EQ 'PCOFINS'
                                                         AND dcitm EQ wa_itmatr-atitm.
    IF sy-subrc EQ 0.
      wa_alv_xml-item = wa_itmatr-atitm.
      wa_alv_xml-pcofins = wa_docmnx-value.
    ENDIF.

    SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_itmatr-chave
                                                         AND mneum EQ 'VCOFINS'
                                                         AND dcitm EQ wa_itmatr-atitm.
    IF sy-subrc EQ 0.
      wa_alv_xml-item = wa_itmatr-atitm.
      wa_alv_xml-vcofins = wa_docmnx-value.
    ENDIF.
    APPEND wa_alv_xml TO t_alv_xml.
*        CLEAR wa_alv_xml.


* Valorer unitarios
    SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_itmatr-chave
                                                         AND mneum EQ 'VUNCOM'
                                                         AND dcitm EQ wa_itmatr-atitm.
    IF sy-subrc EQ 0.
      lv_val_unit = wa_docmnx-value.
      wa_alv_comp-valor2 = lv_val_unit.
    ENDIF.

    CLEAR wa_docmnx.
    SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_cabdoc-chave
                                                         AND mneum EQ 'ATITMPED'
                                                         AND atitm EQ wa_itmatr-atitm.
    IF sy-subrc IS INITIAL.
      READ TABLE lt_po_item INTO ls_po_item WITH KEY po_item = wa_docmnx-value BINARY SEARCH.

      IF sy-subrc EQ 0.
        lv_val_unit = ls_po_item-net_price.
        wa_alv_comp-valor = lv_val_unit.
      ENDIF.
    ENDIF.
    wa_alv_comp-item = wa_itmatr-atitm.
    IF wa_alv_comp-valor NE wa_alv_comp-valor2.
      wa_alv_comp-farol = 1.
    ELSE.
      wa_alv_comp-farol = 3.
    ENDIF.
    wa_alv_comp-impo = 'Val. Unit.'.
    APPEND wa_alv_comp TO t_alv_comp.
    CLEAR wa_alv_comp.

* Unidade de Medida
    SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_itmatr-chave
                                                         AND mneum EQ 'UCOM'
                                                         AND dcitm EQ wa_itmatr-atitm.
    IF sy-subrc EQ 0.
      wa_alv_comp-valor2 = wa_docmnx-value.
    ENDIF.

    CLEAR wa_docmnx.
    SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_cabdoc-chave
                                                         AND mneum EQ 'ATITMPED'
                                                         AND atitm EQ wa_itmatr-atitm.
    IF sy-subrc IS INITIAL.
      READ TABLE lt_po_item INTO ls_po_item WITH KEY po_item = wa_docmnx-value BINARY SEARCH.

      IF sy-subrc EQ 0.
        CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
          EXPORTING
            input          = ls_po_item-po_unit
            language       = sy-langu
          IMPORTING
*           LONG_TEXT      =
            output         = ls_po_item-po_unit
*           SHORT_TEXT     =
          EXCEPTIONS
            unit_not_found = 1
            OTHERS         = 2.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.
        wa_alv_comp-valor = ls_po_item-po_unit.
      ENDIF.
    ENDIF.

    wa_alv_comp-item = wa_itmatr-atitm.
    IF wa_alv_comp-valor NE wa_alv_comp-valor2.
      wa_alv_comp-farol = 1.
    ELSE.
      wa_alv_comp-farol = 3.
    ENDIF.
    wa_alv_comp-impo = 'Un. Medida'.
    APPEND wa_alv_comp TO t_alv_comp.
    CLEAR wa_alv_comp.

** Valida NCM
    CLEAR wa_docmnx.
    CLEAR: vg_ncm_xml, vg_ncm_mne.
    SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_cabdoc-chave
                                                         AND mneum EQ 'XMLNCM'
                                                         AND dcitm EQ wa_itmatr-atitm.

    IF sy-subrc EQ 0.
      TRANSLATE wa_docmnx-value USING '. '.
      CONDENSE wa_docmnx-value NO-GAPS.
      MOVE: wa_docmnx-value TO vg_ncm_xml.
    ENDIF.

    CLEAR wa_docmnx.
    SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_cabdoc-chave
                                                         AND mneum EQ 'ATITMPED'
                                                         AND atitm EQ wa_itmatr-atitm.
    IF sy-subrc EQ 0.
      READ TABLE lt_po_item INTO ls_po_item WITH KEY po_item = wa_docmnx-value BINARY SEARCH.

      TRANSLATE ls_po_item-bras_nbm USING '. '. CONDENSE ls_po_item-bras_nbm NO-GAPS.
      vg_ncm_mne = ls_po_item-bras_nbm.

      READ TABLE t_tb_vld_tax INTO ls_tb_vld_tax WITH KEY tax_type = 'NCM'.

      wa_alv_comp-item = wa_itmatr-atitm.
      wa_alv_comp-impo = 'NCM'.
      wa_alv_comp-valor = vg_ncm_mne.
      wa_alv_comp-valor2 = vg_ncm_xml.
      IF vg_ncm_mne NE vg_ncm_xml.
        wa_alv_comp-farol = 1.
      ELSE.
        wa_alv_comp-farol = 3.
      ENDIF.
      APPEND wa_alv_comp TO t_alv_comp.
      CLEAR wa_alv_comp.

    ENDIF.


*        REFRESH it_docmni[].
*        SELECT * FROM zhms_tb_docmn INTO TABLE it_docmni  WHERE chave EQ wa_cabdoc-chave
*                                                            AND mneum EQ 'NCM'
*                                                            AND dcitm EQ wa_docmnx-dcitm.
*
*        LOOP AT it_docmni INTO wa_docmni.
*
*          TRANSLATE wa_docmni-value USING '. '.
*          TRANSLATE wa_docmnx-value USING '. '.
*          CONDENSE wa_docmni-value NO-GAPS.
*          CONDENSE wa_docmnx-value NO-GAPS.
*
*          CLEAR: vg_ncm_xml, vg_ncm_mne.
*          MOVE: wa_docmni-value TO vg_ncm_mne,
*                wa_docmnx-value TO vg_ncm_xml.
*
*          READ TABLE t_tb_vld_tax INTO ls_tb_vld_tax WITH KEY tax_type = 'NCM'.
*
*          wa_alv_comp-item = wa_itmatr-atitm.
*          wa_alv_comp-impo = 'NCM'.
*          wa_alv_comp-valor = vg_ncm_mne.
*          wa_alv_comp-valor2 = vg_ncm_xml.
*          IF vg_ncm_mne NE vg_ncm_xml.
*            wa_alv_comp-farol = 1.
*          ELSE.
*            wa_alv_comp-farol = 3.
*          ENDIF.
*          APPEND wa_alv_comp TO t_alv_comp.
*          CLEAR wa_alv_comp.
*
*          IF vg_ncm_mne NE vg_ncm_xml AND ls_tb_vld_tax-ativo IS NOT INITIAL.
*
*          ENDIF.
*        ENDLOOP.

*** Validação das condições do pedido de compra
    REFRESH: t_komv[], it_komk[], it_komp[].
    CLEAR: wa_komk, wa_komp.
*        PERFORM f_preenche_t_komk.

    REFRESH it_docmnx.
    SELECT * FROM zhms_tb_docmn INTO TABLE it_docmnx  WHERE chave EQ wa_cabdoc-chave AND
                                                           ( atitm EQ wa_itmatr-atitm OR
                                                            atitm EQ '00000' ).

    IF sy-subrc IS INITIAL AND it_docmnx[] IS NOT INITIAL.

      MOVE: sy-mandt TO wa_komk-mandt.
      CLEAR wa_docmn.
      READ TABLE it_docmnx  INTO wa_docmn WITH KEY mneum = 'VATCNTRY'.

      IF sy-subrc IS INITIAL.
        MOVE wa_docmn-value TO wa_komk-aland.
      ENDIF.

      CLEAR wa_docmn.
      READ TABLE it_docmnx  INTO wa_docmn WITH KEY mneum = 'COMPCODE'.

      IF sy-subrc IS INITIAL.
        MOVE wa_docmn-value TO wa_komk-bukrs.
      ENDIF.

      CLEAR wa_docmn.
      READ TABLE it_docmnx  INTO wa_docmn WITH KEY mneum = 'CURRENCY'.

      IF sy-subrc IS INITIAL.
        MOVE wa_docmn-value TO wa_komk-waerk.
      ENDIF.

      CLEAR wa_docmn.
      READ TABLE it_docmnx  INTO wa_docmn WITH KEY mneum = 'DIFFINV'.

      IF sy-subrc IS INITIAL.
        MOVE wa_docmn-value TO wa_komk-lifnr.
      ENDIF.

      MOVE 'TX'     TO wa_komk-kappl.
      MOVE 'TAXBRA' TO wa_komk-kalsm.

      CLEAR wa_docmn.
      READ TABLE it_docmnx  INTO wa_docmn WITH KEY mneum = 'CREATEDATE'.

      IF sy-subrc IS INITIAL.
        MOVE wa_docmn-value TO wa_komk-prsdt.
      ENDIF.

      CLEAR wa_docmn.
      READ TABLE it_docmnx  INTO wa_docmn WITH KEY mneum = 'TAXJURCODE'.

      IF sy-subrc IS INITIAL.
        MOVE wa_docmn-value TO wa_komk-txjcd.
      ENDIF.

      CLEAR wa_docmn.
      READ TABLE it_docmnx  INTO wa_docmn WITH KEY mneum = 'PURCHORG'.

      IF sy-subrc IS INITIAL.
        MOVE wa_docmn-value TO wa_komk-ekorg.
      ENDIF.

      CLEAR wa_docmn.
      READ TABLE it_docmnx INTO wa_docmn WITH KEY mneum = 'COAREA'.

      IF sy-subrc IS INITIAL.
        MOVE wa_docmn-value TO wa_komk-kokrs.
      ENDIF.

      CLEAR wa_docmn.
      READ TABLE it_docmnx  INTO wa_docmn WITH KEY mneum = 'COSTCENTER'.

      IF sy-subrc IS INITIAL.
        MOVE wa_docmn-value TO wa_komk-kostl.
      ENDIF.

      CLEAR wa_docmn.
      READ TABLE it_docmnx  INTO wa_docmn WITH KEY mneum = 'TAXCODE'.

      IF sy-subrc IS INITIAL.
        MOVE wa_docmn-value TO wa_komk-mwskz.
      ENDIF.

      APPEND wa_komk TO it_komk.

    ENDIF.

*        PERFORM f_preenche_t_komp.

    REFRESH it_docmnx[].
    SELECT * FROM zhms_tb_docmn INTO TABLE it_docmnx  WHERE chave EQ wa_cabdoc-chave AND
                                                            ( atitm EQ wa_itmatr-atitm OR
                                                              atitm EQ '00000' ).


    IF sy-subrc IS INITIAL AND it_docmnx[] IS NOT INITIAL.

      CLEAR wa_docmn.
      READ TABLE it_docmnx INTO wa_docmn WITH KEY mneum = 'ATITMPED'.

      IF sy-subrc IS INITIAL.
        MOVE wa_docmn-value TO wa_komp-kposn.
      ENDIF.

      CLEAR wa_docmn.
      READ TABLE it_docmnx INTO wa_docmn WITH KEY mneum = 'MATERIAL'.

      IF sy-subrc IS INITIAL.
        MOVE wa_docmn-value TO wa_komp-matnr.
      ENDIF.

      CLEAR wa_docmn.
      READ TABLE it_docmnx INTO wa_docmn WITH KEY mneum = 'PLANT'.

      IF sy-subrc IS INITIAL.
        MOVE wa_docmn-value TO wa_komp-werks.
      ENDIF.

      CLEAR wa_docmn.
      READ TABLE it_docmnx INTO wa_docmn WITH KEY mneum = 'TAXJURCODE'.

      IF sy-subrc IS INITIAL.
        MOVE: wa_docmn-value(2) TO wa_komp-wkreg,
              wa_docmn-value(2) TO wa_komp-txreg_sf,
              wa_docmn-value(2) TO wa_komp-txreg_st,
              wa_docmn-value    TO wa_komp-loc_pr,
              wa_docmn-value    TO wa_komp-loc_se,
              wa_docmn-value    TO wa_komp-loc_sr.
      ENDIF.

      CLEAR wa_docmn.
      READ TABLE it_docmnx INTO wa_docmn WITH KEY mneum = 'MATLGROUP'.

      IF sy-subrc IS INITIAL.
        MOVE wa_docmn-value TO wa_komp-matkl.
      ENDIF.

      CLEAR wa_docmn.
      READ TABLE it_docmnx INTO wa_docmn WITH KEY mneum = 'ENRYUOMISO'.

      IF sy-subrc IS INITIAL.
        MOVE: wa_docmn-value TO wa_komp-meins,
              wa_docmn-value TO wa_komp-vrkme.
      ENDIF.

      CLEAR wa_docmn.
      READ TABLE it_docmnx INTO wa_docmn WITH KEY mneum = 'ATQTDE'.

      IF sy-subrc IS INITIAL.
        MOVE: wa_docmn-value TO wa_komp-mglme,
              wa_docmn-value TO wa_komp-mgame.
      ENDIF.

      CLEAR wa_docmn.
      READ TABLE it_docmnx INTO wa_docmn WITH KEY mneum = 'NETPRICE'.

      IF sy-subrc IS INITIAL.
        MOVE wa_docmn-value TO wa_komp-wrbtr.
      ENDIF.

      CLEAR wa_docmn.
      READ TABLE it_docmnx INTO wa_docmn WITH KEY mneum = 'TAXCODE'.

      IF sy-subrc IS INITIAL.
        MOVE wa_docmn-value TO wa_komp-mwskz.
      ENDIF.

      CLEAR wa_docmn.
      READ TABLE it_docmnx INTO wa_docmn WITH KEY mneum = 'ATPED'.

      IF sy-subrc IS INITIAL.
        MOVE wa_docmn-value TO wa_komp-evrtn.
      ENDIF.

      CLEAR wa_docmn.
      READ TABLE it_docmnx INTO wa_docmn WITH KEY mneum = 'ATITMPED'.

      IF sy-subrc IS INITIAL.
        MOVE wa_docmn-value TO wa_komp-evrtp.
      ENDIF.

      SELECT SINGLE mtart FROM mara INTO wa_komp-mtart WHERE matnr EQ wa_komp-matnr.

      CLEAR wa_docmn.
      READ TABLE it_docmnx INTO wa_docmn WITH KEY mneum = 'MATLUSAGE'.

      IF sy-subrc IS INITIAL.
        MOVE: wa_docmn-value TO wa_komp-mtuse,
              wa_docmn-value TO wa_komp-mtuse_marc.
      ENDIF.

      CLEAR wa_docmn.
      READ TABLE it_docmnx INTO wa_docmn WITH KEY mneum = 'MATORIGIN'.

      IF sy-subrc IS INITIAL.
        MOVE wa_docmn-value TO wa_komp-mtorg.
      ENDIF.

      CLEAR wa_docmn.
      READ TABLE it_docmnx INTO wa_docmn WITH KEY mneum = 'NCM'.

      IF sy-subrc IS INITIAL.
        CONDENSE wa_docmn-value NO-GAPS.
        MOVE wa_docmn-value TO wa_komp-steuc.
      ENDIF.

      DATA: lv_po        TYPE bapiekko-po_number,
            lt_items_aux TYPE STANDARD TABLE OF bapiekpo,
            ls_items_aux LIKE LINE OF lt_items_aux.

      REFRESH: lt_items_aux[].
      CLEAR: ls_items_aux, lv_po.

      MOVE wa_komp-evrtn TO lv_po.
*** Busca  valor liquido sem impostos
      CALL FUNCTION 'BAPI_PO_GETDETAIL'
        EXPORTING
          purchaseorder = lv_po
          items         = 'X'
        TABLES
          po_items      = lt_items_aux.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = wa_komp-evrtp
        IMPORTING
          output = wa_komp-evrtp.

      READ TABLE lt_items_aux INTO ls_items_aux WITH KEY po_item = wa_komp-evrtp.

      IF sy-subrc IS INITIAL.
        MOVE: ls_items_aux-net_value TO wa_komp-netwr,
              ls_items_aux-net_value TO wa_komp-wrbtr.

        MOVE ls_items_aux-eff_value TO wa_komp-kzwi1.
      ENDIF.

      APPEND wa_komp TO it_komp.

    ENDIF.

    CALL FUNCTION 'PRICING'
      EXPORTING
        calculation_type = 'B'
        comm_head_i      = wa_komk
        comm_item_i      = wa_komp
      TABLES
        tkomv            = t_komv.

    IF t_komv[] IS NOT INITIAL.

      SELECT *
        FROM j_1baj
        INTO TABLE t_1baj
        FOR ALL ENTRIES IN t_komv
       WHERE taxtyp = t_komv-kschl
         AND taxgrp = 'ICMS'.

      CLEAR lv_tot_kbetr.
      LOOP AT t_1baj INTO wa_1baj.
        LOOP AT t_komv INTO wa_komv WHERE kschl EQ wa_1baj-taxtyp.
          lv_tot_kbetr = lv_tot_kbetr + wa_komv-kawrt.
        ENDLOOP.
      ENDLOOP.

      CLEAR lv_qtd .
      SELECT SINGLE value FROM zhms_tb_docmn INTO lv_qtd  WHERE chave EQ wa_cabdoc-chave
                                                            AND mneum EQ 'QUANTITY'
                                                            AND atitm EQ wa_itmatr-atitm.
      IF sy-subrc IS INITIAL.
*** Valor unitário do ICMS no Pedido
        TRY .
            lv_div_ped = lv_tot_kbetr / lv_qtd.
          CATCH cx_sy_zerodivide.
        ENDTRY.

*** Valor unitário do ICMS no XML
        CLEAR lv_icms.
        SELECT SINGLE value FROM zhms_tb_docmn INTO lv_icms WHERE chave EQ wa_cabdoc-chave
                                                              AND mneum EQ 'ATVICMS'
                                                              AND atitm EQ wa_itmatr-atitm.

        CLEAR lv_qtd_at .
        SELECT SINGLE value FROM zhms_tb_docmn INTO lv_qtd_at WHERE chave EQ wa_cabdoc-chave
                                                                AND mneum EQ 'ATQTDE'
                                                                AND atitm EQ wa_itmatr-atitm.

        IF sy-subrc IS INITIAL.
          TRY .
              lv_div_xml = lv_icms / lv_qtd_at.
            CATCH cx_sy_zerodivide.
          ENDTRY.

* Alv de Auditoria
          wa_alv_ped-item = wa_itmatr-atitm.
          wa_alv_ped-impo = 'ICMS'.
          wa_alv_ped-valor = lv_div_ped.
          wa_alv_ped-valor2 = lv_div_xml.
          IF lv_div_ped NE lv_div_xml.
            wa_alv_ped-farol = 2.
          ENDIF.

* Base de calculo
          READ TABLE t_komv INTO wa_komv WITH KEY kschl = 'BIC0'.
          IF sy-subrc EQ 0.
            lv_baseped = wa_komv-kbetr / 10.
            wa_alv_ped-baseped = lv_baseped.
            wa_alv_ped-basexml = wa_alv_xml-picms.
          ENDIF.

          APPEND wa_alv_ped TO t_alv_ped.
          CLEAR wa_alv_ped.


*** Validar se o Valor unitário do ICMS no Pedido <> Valor unitário do ICMS no XML.
          READ TABLE t_tb_vld_tax INTO ls_tb_vld_tax WITH KEY tax_type = 'ICMS'.

          IF lv_div_ped NE lv_div_xml AND ls_tb_vld_tax-ativo IS NOT INITIAL.

          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

*** Valor do IPI do XML difere do pedido de compra
    REFRESH t_1baj[].
    SELECT *
      FROM j_1baj
      INTO TABLE t_1baj
      FOR ALL ENTRIES IN t_komv
     WHERE taxtyp = t_komv-kschl
       AND taxgrp = 'IPI'.

    CLEAR lv_tot_kbetr .
    LOOP AT t_1baj INTO wa_1baj.
      LOOP AT t_komv INTO wa_komv WHERE kschl EQ wa_1baj-taxtyp.
        lv_tot_kbetr = lv_tot_kbetr + wa_komv-kawrt.
      ENDLOOP.
    ENDLOOP.

*** Valor unitário do IPI no Pedido
    CLEAR lv_div_ped .
    TRY .
        lv_div_ped = lv_tot_kbetr / lv_qtd.
      CATCH cx_sy_zerodivide.
    ENDTRY.

*** Valor unitário do IPI no XML
    CLEAR lv_ipi.
    SELECT SINGLE value FROM zhms_tb_docmn INTO lv_ipi  WHERE chave EQ wa_cabdoc-chave
                                                          AND mneum EQ 'ATVIPI'
                                                          AND atitm EQ wa_itmatr-atitm.

    IF sy-subrc IS INITIAL.
      CLEAR lv_div_xml.
      TRY .
          lv_div_xml = lv_ipi / lv_qtd_at.
        CATCH  cx_sy_zerodivide.
      ENDTRY.

* Alv de Auditoria
      wa_alv_ped-item = wa_itmatr-atitm.
      wa_alv_ped-impo = 'IPI'.
      wa_alv_ped-valor = lv_div_ped.
      wa_alv_ped-valor2 = lv_div_xml.
      IF lv_div_ped NE lv_div_xml.
        wa_alv_ped-farol = 1.
      ENDIF.

* Base de calculo
      READ TABLE t_komv INTO wa_komv WITH KEY kschl = 'BIP0'.
      IF sy-subrc EQ 0.
        lv_baseped = wa_komv-kbetr / 10.
        wa_alv_ped-baseped = lv_baseped.
        wa_alv_ped-basexml = wa_alv_xml-pipi.
      ENDIF.

      APPEND wa_alv_ped TO t_alv_ped.
      CLEAR wa_alv_ped.

      READ TABLE t_tb_vld_tax INTO ls_tb_vld_tax WITH KEY tax_type = 'IPI'.

      IF lv_div_ped NE lv_div_xml AND ls_tb_vld_tax-ativo IS NOT INITIAL.

      ENDIF.
    ENDIF.
*
*** Valor do PIS do XML difere do pedido de compra
    REFRESH t_1baj[].
    SELECT *
      FROM j_1baj
      INTO TABLE t_1baj
      FOR ALL ENTRIES IN t_komv
     WHERE taxtyp = t_komv-kschl
       AND taxgrp = 'PIS'.

    CLEAR: lv_cont_1baj, lv_tot_kbetr .
    LOOP AT t_1baj INTO wa_1baj.
      LOOP AT t_komv INTO wa_komv WHERE kschl EQ wa_1baj-taxtyp.
        lv_tot_kbetr = lv_tot_kbetr + wa_komv-kawrt.
        IF wa_komv-kawrt IS NOT INITIAL.
          ADD 1 TO lv_cont_1baj.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

*** Valor unitário do PIS no Pedido
    CLEAR lv_div_ped .
    TRY .
        lv_div_ped = lv_tot_kbetr / lv_cont_1baj.
        lv_div_ped = lv_div_ped / lv_qtd.
      CATCH  cx_sy_zerodivide.
    ENDTRY.

*** Valor unitário do PIS no XML
    CLEAR lv_pis.
    SELECT SINGLE value FROM zhms_tb_docmn INTO lv_pis  WHERE chave EQ wa_cabdoc-chave
                                                          AND mneum EQ 'ATVPIS'
                                                          AND atitm EQ wa_itmatr-atitm.

    IF sy-subrc IS INITIAL.
      CLEAR lv_div_xml.
      TRY .
          lv_div_xml = lv_pis / lv_qtd_at.
        CATCH cx_sy_zerodivide.
      ENDTRY.

* Alv de Auditoria
      wa_alv_ped-item = wa_itmatr-atitm.
      wa_alv_ped-impo = 'PIS'.
      wa_alv_ped-valor = lv_div_ped.
      wa_alv_ped-valor2 = lv_div_xml.
      IF lv_div_ped NE lv_div_xml.
        wa_alv_ped-farol = 1.
      ENDIF.

* Base de calculo
      READ TABLE t_komv INTO wa_komv WITH KEY kschl = 'BPI1'.
      IF sy-subrc EQ 0.
        lv_baseped = wa_komv-kbetr / 10.
        wa_alv_ped-baseped = lv_baseped.
        wa_alv_ped-basexml = wa_alv_xml-ppis.
      ENDIF.

      APPEND wa_alv_ped TO t_alv_ped.
      CLEAR wa_alv_ped.

      READ TABLE t_tb_vld_tax INTO ls_tb_vld_tax WITH KEY tax_type = 'PIS'.

      IF lv_div_ped NE lv_div_xml AND ls_tb_vld_tax-ativo IS NOT INITIAL.

      ENDIF.
    ENDIF.

*** Valor do Cofins do XML difere do pedido de compra
    REFRESH t_1baj[].
    SELECT *
      FROM j_1baj
      INTO TABLE t_1baj
      FOR ALL ENTRIES IN t_komv
     WHERE taxtyp = t_komv-kschl
       AND taxgrp = 'COFI'.

    CLEAR lv_tot_kbetr .
*          IF sy-subrc IS INITIAL.
    CLEAR lv_cont_1baj.
    LOOP AT t_1baj INTO wa_1baj.
      LOOP AT t_komv INTO wa_komv WHERE kschl EQ wa_1baj-taxtyp.
        lv_tot_kbetr = lv_tot_kbetr + wa_komv-kawrt.
        IF wa_komv-kawrt IS NOT INITIAL.
          ADD 1 TO lv_cont_1baj.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

*** Valor unitário do COFINS no Pedido
    CLEAR lv_div_ped .
    TRY .
        lv_div_ped = lv_tot_kbetr / lv_cont_1baj.
        lv_div_ped = lv_div_ped / lv_qtd_at.
      CATCH  cx_sy_zerodivide.
    ENDTRY.

*** Valor unitário do COFINS no XML
    CLEAR lv_cof.
    SELECT SINGLE value FROM zhms_tb_docmn INTO lv_cof WHERE chave EQ wa_cabdoc-chave
                                                         AND mneum EQ 'ATVCOFINS'
                                                         AND atitm EQ wa_itmatr-atitm.

    IF sy-subrc IS INITIAL.
      CLEAR lv_div_xml.
      TRY .
          lv_div_xml = lv_cof / lv_qtd_at.
        CATCH  cx_sy_zerodivide.
      ENDTRY.

* Alv de Auditoria
      wa_alv_ped-item = wa_itmatr-atitm.
      wa_alv_ped-impo = 'COFINS'.
      wa_alv_ped-valor = lv_div_ped.
      wa_alv_ped-valor2 = lv_div_xml.
      IF lv_div_ped NE lv_div_xml.
        wa_alv_ped-farol = 1.
      ENDIF.

* Base de calculo
      READ TABLE t_komv INTO wa_komv WITH KEY kschl = 'BCO1'.
      IF sy-subrc EQ 0.
        lv_baseped = wa_komv-kbetr / 10.
        wa_alv_ped-baseped = lv_baseped.
        wa_alv_ped-basexml = wa_alv_xml-pcofins.
      ENDIF.

      APPEND wa_alv_ped TO t_alv_ped.
      CLEAR wa_alv_ped.

      READ TABLE t_tb_vld_tax INTO ls_tb_vld_tax WITH KEY tax_type = 'COFINS'.

      IF lv_div_ped NE lv_div_xml AND ls_tb_vld_tax-ativo IS NOT INITIAL.

      ENDIF.
    ENDIF.

*** Valor do ISS do XML difere do pedido de compra
    REFRESH t_1baj[].
    SELECT *
      FROM j_1baj
      INTO TABLE t_1baj
      FOR ALL ENTRIES IN t_komv
     WHERE taxtyp = t_komv-kschl
       AND taxgrp = 'ISS'.

    CLEAR lv_tot_kbetr .
*          IF sy-subrc IS INITIAL.
    LOOP AT t_1baj INTO wa_1baj.
      LOOP AT t_komv INTO wa_komv WHERE kschl EQ wa_1baj-taxtyp.
        lv_tot_kbetr = lv_tot_kbetr + wa_komv-kawrt.
      ENDLOOP.
    ENDLOOP.

*** Valor unitário do ISS no Pedido
    CLEAR lv_div_ped .
    TRY .
        lv_div_ped = lv_tot_kbetr / lv_qtd.
      CATCH cx_sy_zerodivide.
    ENDTRY.

*** Valor unitário do ISS no XML
    CLEAR lv_sqn.
    SELECT SINGLE value FROM zhms_tb_docmn INTO lv_sqn WHERE chave EQ wa_cabdoc-chave
                                                         AND mneum EQ 'ATVISSQN'
                                                         AND atitm EQ wa_itmatr-atitm.

    IF sy-subrc IS INITIAL.
      CLEAR lv_div_xml.
      lv_div_xml = lv_sqn / lv_qtd_at.

* Alv de Auditoria
      wa_alv_ped-item = wa_itmatr-atitm.
      wa_alv_ped-impo = 'ISS'.
      wa_alv_ped-valor = lv_div_ped.
      wa_alv_ped-valor2 = lv_div_xml.
      IF lv_div_ped NE lv_div_xml.
        wa_alv_ped-farol = 1.
      ENDIF.

      APPEND wa_alv_ped TO t_alv_ped.
      CLEAR wa_alv_ped.

      READ TABLE t_tb_vld_tax INTO ls_tb_vld_tax WITH KEY tax_type = 'ISS'.

      IF lv_div_ped NE lv_div_xml AND ls_tb_vld_tax-ativo IS NOT INITIAL.

      ENDIF.
    ENDIF.

*** Valor do ICMSST do XML difere do pedido de compra
    REFRESH t_1baj[].
    SELECT *
      FROM j_1baj
      INTO TABLE t_1baj
      FOR ALL ENTRIES IN t_komv
     WHERE taxtyp = t_komv-kschl
       AND taxgrp = 'ICST'.

    CLEAR lv_tot_kbetr .
    LOOP AT t_1baj INTO wa_1baj.
      LOOP AT t_komv INTO wa_komv WHERE kschl EQ wa_1baj-taxtyp.
        lv_tot_kbetr = lv_tot_kbetr + wa_komv-kawrt.
      ENDLOOP.
    ENDLOOP.

*** Valor unitário do ICST no Pedido
    CLEAR lv_div_ped .
    TRY .
        lv_div_ped = lv_tot_kbetr / lv_qtd.
      CATCH cx_sy_zerodivide .
    ENDTRY.

*** Valor unitário do ICST no XML
    CLEAR lv_sst.
    SELECT SINGLE value FROM zhms_tb_docmn INTO lv_sst  WHERE chave EQ wa_cabdoc-chave
                                                          AND mneum EQ 'ATVICMSST'
                                                          AND atitm EQ wa_itmatr-atitm.

    IF sy-subrc IS INITIAL.
      CLEAR lv_div_xml.
      TRY .
          lv_div_xml = lv_sst / lv_qtd_at.
        CATCH cx_sy_zerodivide.
      ENDTRY.

* Alv de Auditoria
      wa_alv_ped-item = wa_itmatr-atitm.
      wa_alv_ped-impo = 'ICST'.
      wa_alv_ped-valor = lv_div_ped.
      wa_alv_ped-valor2 = lv_div_xml.
      IF lv_div_ped NE lv_div_xml.
        wa_alv_ped-farol = 1.
      ENDIF.
      APPEND wa_alv_ped TO t_alv_ped.
      CLEAR wa_alv_ped.


      READ TABLE t_tb_vld_tax INTO ls_tb_vld_tax WITH KEY tax_type = 'ICMSST'.

      IF lv_div_ped NE lv_div_xml AND ls_tb_vld_tax-ativo IS NOT INITIAL.

      ENDIF.
    ENDIF.
*      ENDIF.

  ENDLOOP.
  CLEAR t_itmatr.

ENDMODULE.                 " M_CALC_AUDI  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  M_ALV_AUDITORIA_0606  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_alv_auditoria_0606 OUTPUT.

*  DATA: it_exclude TYPE ui_functions.

*      break rsantos.

  REFRESH t_ht_field[].
  REFRESH t_ht_field2[].
*      DATA: it_exclude TYPE ui_functions.
  DATA:
*        lcl_event_receiver      TYPE REF TO lcl_receiver,
        wa_layout_comp          TYPE lvc_s_layo,
        wa_layout_ped           TYPE lvc_s_layo,
        g_lights_name           TYPE lvc_cifnm VALUE 'FAROL'.


  CLEAR wa_hvalid_fldc.
  wa_ht_field-fieldname = 'ITEM'.
  wa_ht_field-reptext   = 'Item'.
  wa_ht_field-col_opt   = 'X'.
  wa_ht_field-hotspot   = 'X'.
  APPEND wa_ht_field TO t_ht_field.
  CLEAR wa_ht_field.

  CLEAR wa_hvalid_fldc.
  wa_ht_field-fieldname = 'DESC'.
  wa_ht_field-reptext   = 'Desc. Item'.
  wa_ht_field-col_opt   = 'X'.
*  wa_ht_field-hotspot   = 'X'.
  APPEND wa_ht_field TO t_ht_field.
  CLEAR wa_ht_field.

  CLEAR wa_hvalid_fldc.
  wa_ht_field-fieldname = 'UNIDADE'.
  wa_ht_field-reptext   = 'Unidade'.
  wa_ht_field-col_opt   = 'X'.
*  wa_ht_field-hotspot   = 'X'.
  APPEND wa_ht_field TO t_ht_field.
  CLEAR wa_ht_field.

  CLEAR wa_hvalid_fldc.
  wa_ht_field-fieldname = 'QTDE'.
  wa_ht_field-reptext   = 'Quantidade'.
  wa_ht_field-col_opt   = 'X'.
*  wa_ht_field-hotspot   = 'X'.
  APPEND wa_ht_field TO t_ht_field.
  CLEAR wa_ht_field.

  CLEAR wa_hvalid_fldc.
  wa_ht_field-fieldname = 'VPROD'.
  wa_ht_field-reptext   = 'Val. Prod.'.
  wa_ht_field-col_opt   = 'X'.
*  wa_ht_field-hotspot   = 'X'.
  APPEND wa_ht_field TO t_ht_field.
  CLEAR wa_ht_field.

  CLEAR wa_hvalid_fldc.
  wa_ht_field-fieldname = 'PICMS'.
  wa_ht_field-reptext   = 'Aliq. ICMS'.
  wa_ht_field-col_opt   = 'X'.
*  wa_ht_field-hotspot   = 'X'.
  APPEND wa_ht_field TO t_ht_field.
  CLEAR wa_ht_field.

  CLEAR wa_hvalid_fldc.
  wa_ht_field-fieldname = 'VICMS'.
  wa_ht_field-reptext   = 'Val. ICMS'.
  wa_ht_field-col_opt   = 'X'.
*  wa_ht_field-hotspot   = 'X'.
  APPEND wa_ht_field TO t_ht_field.
  CLEAR wa_ht_field.

  CLEAR wa_hvalid_fldc.
  wa_ht_field-fieldname = 'PIPI'.
  wa_ht_field-reptext   = 'Aliq. IPI'.
  wa_ht_field-col_opt   = 'X'.
*  wa_ht_field-hotspot   = 'X'.
  APPEND wa_ht_field TO t_ht_field.
  CLEAR wa_ht_field.

  CLEAR wa_hvalid_fldc.
  wa_ht_field-fieldname = 'VIPI'.
  wa_ht_field-reptext   = 'Val. IPI'.
  wa_ht_field-col_opt   = 'X'.
*  wa_ht_field-hotspot   = 'X'.
  APPEND wa_ht_field TO t_ht_field.
  CLEAR wa_ht_field.

  CLEAR wa_hvalid_fldc.
  wa_ht_field-fieldname = 'PPIS'.
  wa_ht_field-reptext   = 'Aliq. PIS'.
  wa_ht_field-col_opt   = 'X'.
*  wa_ht_field-hotspot   = 'X'.
  APPEND wa_ht_field TO t_ht_field.
  CLEAR wa_ht_field.

  CLEAR wa_hvalid_fldc.
  wa_ht_field-fieldname = 'VPIS'.
  wa_ht_field-reptext   = 'Val. PIS'.
  wa_ht_field-col_opt   = 'X'.
*  wa_ht_field-hotspot   = 'X'.
  APPEND wa_ht_field TO t_ht_field.
  CLEAR wa_ht_field.

  CLEAR wa_hvalid_fldc.
  wa_ht_field-fieldname = 'PCOFINS'.
  wa_ht_field-reptext   = 'Aliq. COFINS'.
  wa_ht_field-col_opt   = 'X'.
*  wa_ht_field-hotspot   = 'X'.
  APPEND wa_ht_field TO t_ht_field.
  CLEAR wa_ht_field.

  CLEAR wa_hvalid_fldc.
  wa_ht_field-fieldname = 'VCOFINS'.
  wa_ht_field-reptext   = 'Val. COFINS'.
  wa_ht_field-col_opt   = 'X'.
*  wa_ht_field-hotspot   = 'X'.
  APPEND wa_ht_field TO t_ht_field.
  CLEAR wa_ht_field.

* ALV 2
  CLEAR wa_hvalid_fldc.
  wa_ht_field-fieldname = 'IMPO'.
  wa_ht_field-reptext   = 'Imposto'.
  wa_ht_field-col_opt   = 'X'.
  APPEND wa_ht_field TO t_ht_field2.
  CLEAR wa_ht_field.

  CLEAR wa_hvalid_fldc.
  wa_ht_field-fieldname = 'BASEPED'.
  wa_ht_field-reptext   = 'Base Ped.'.
  wa_ht_field-col_opt   = 'X'.
  APPEND wa_ht_field TO t_ht_field2.
  CLEAR wa_ht_field.

  CLEAR wa_hvalid_fldc.
  wa_ht_field-fieldname = 'VALOR'.
  wa_ht_field-reptext   = 'Valor Pedido'.
  wa_ht_field-col_opt   = 'X'.
  APPEND wa_ht_field TO t_ht_field2.
  CLEAR wa_ht_field.

  CLEAR wa_hvalid_fldc.
  wa_ht_field-fieldname = 'BASEXML'.
  wa_ht_field-reptext   = 'Base XML'.
  wa_ht_field-col_opt   = 'X'.
  APPEND wa_ht_field TO t_ht_field2.
  CLEAR wa_ht_field.

  CLEAR wa_hvalid_fldc.
  wa_ht_field-fieldname = 'VALOR2'.
  wa_ht_field-reptext   = 'Valor XML'.
  wa_ht_field-col_opt   = 'X'.
  APPEND wa_ht_field TO t_ht_field2.
  CLEAR wa_ht_field.

  CLEAR wa_hvalid_fldc.
  wa_ht_field-fieldname = 'FAROL'.
  wa_ht_field-reptext   = 'Diferença'.
  wa_ht_field-col_opt   = 'X'.
  APPEND wa_ht_field TO t_ht_field2.
  CLEAR wa_ht_field.

* ALV 3 - Comparações simples (valor unit, ncm...)
  CLEAR t_ht_field3.
  CLEAR wa_hvalid_fldc.
  wa_ht_field-fieldname = 'IMPO'.
  wa_ht_field-reptext   = 'Tipo'.
  wa_ht_field-col_opt   = 'X'.
  APPEND wa_ht_field TO t_ht_field3.
  CLEAR wa_ht_field.

  CLEAR wa_hvalid_fldc.
  wa_ht_field-fieldname = 'VALOR'.
  wa_ht_field-reptext   = 'Valor P.O.'.
  wa_ht_field-col_opt   = 'X'.
  APPEND wa_ht_field TO t_ht_field3.
  CLEAR wa_ht_field.

  CLEAR wa_hvalid_fldc.
  wa_ht_field-fieldname = 'VALOR2'.
  wa_ht_field-reptext   = 'Valor XML'.
  wa_ht_field-col_opt   = 'X'.
  APPEND wa_ht_field TO t_ht_field3.
  CLEAR wa_ht_field.

* Remove Botoes
  PERFORM zf_exclude.

** CC para o alv do XML
  IF ob_cc_ped IS NOT INITIAL.
    CALL METHOD ob_cc_ped->free.
  ENDIF.

  CREATE OBJECT ob_cc_ped
    EXPORTING
      container_name = 'CC_ITEM'.

  CREATE OBJECT ob_cc_ped_grid
    EXPORTING
      i_parent = ob_cc_ped.

  wa_layout_ped-zebra = 'X'.

  CALL METHOD ob_cc_ped_grid->set_table_for_first_display
    EXPORTING
      it_toolbar_excluding          = it_exclude
      is_layout                     = wa_layout_ped
    CHANGING
      it_outtab                     = t_alv_xml[]
      it_fieldcatalog               = t_ht_field[]
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.

  CREATE OBJECT lcl_event_receiver.
  SET HANDLER lcl_event_receiver->handel_hotspot_click FOR ob_cc_ped_grid.

** CC para o alv do PEDIDO
  IF ob_cc_xml IS NOT INITIAL.
    CALL METHOD ob_cc_xml->free.
  ENDIF.

  CREATE OBJECT ob_cc_xml
    EXPORTING
      container_name = 'CC_ITEM_DETALHE '.

  CREATE OBJECT ob_cc_xml_grid
    EXPORTING
      i_parent = ob_cc_xml.

  wa_layout_comp-excp_fname = g_lights_name.
  wa_layout_comp-zebra      = 'X'.

  CALL METHOD ob_cc_xml_grid->set_table_for_first_display
    EXPORTING
      it_toolbar_excluding          = it_exclude
      is_layout                     = wa_layout_comp
    CHANGING
      it_outtab                     = t_alv_ped_aux[]
      it_fieldcatalog               = t_ht_field2[]
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.

** CC para o alv do XML
  IF ob_cc_comp IS NOT INITIAL.
    CALL METHOD ob_cc_comp->free.
  ENDIF.

  CREATE OBJECT ob_cc_comp
    EXPORTING
      container_name = 'CC_COMP'.

  CREATE OBJECT ob_cc_comp_grid
    EXPORTING
      i_parent = ob_cc_comp.

  wa_layout_comp-excp_fname = g_lights_name.
  wa_layout_comp-zebra      = 'X'.

  CALL METHOD ob_cc_comp_grid->set_table_for_first_display
    EXPORTING
      it_toolbar_excluding          = it_exclude
      is_layout                     = wa_layout_comp
    CHANGING
      it_outtab                     = t_alv_comp_au[]
      it_fieldcatalog               = t_ht_field3[]
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.

ENDMODULE.                 " M_ALV_AUDITORIA_0606  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  M_STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_status_0300 OUTPUT.
  SET PF-STATUS '0300'.
  SET TITLEBAR  '0300'.
ENDMODULE.                 " M_STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  M_GET_LOGS_DOC  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_get_logs_doc OUTPUT.
*     Limpar tabelas de logs
  REFRESH: t_logdoc, t_logdoc_aux.

*     Seleciona logs para documento
  IF vg_flowd IS INITIAL.
    SELECT *
            INTO TABLE t_logdoc
            FROM zhms_tb_logdoc
           WHERE natdc EQ vg_natdc
             AND typed EQ vg_typed
             AND loctp EQ wa_cabdoc-loctp
             AND chave EQ wa_cabdoc-chave.
  ELSE.
    SELECT *
          INTO TABLE t_logdoc
          FROM zhms_tb_logdoc
         WHERE natdc EQ vg_natdc
           AND typed EQ vg_typed
           AND loctp EQ wa_cabdoc-loctp
           AND chave EQ wa_cabdoc-chave
           AND flowd EQ vg_flowd.
  ENDIF.

*     Seleção por Data / Hora / Sequencia
  SORT t_logdoc BY dtreg DESCENDING
                   hrreg DESCENDING
                   seqnr DESCENDING.

*     Percorrer tabela de logs para tratamento
  LOOP AT t_logdoc INTO wa_logdoc.
*       Mover dados para tabela de exibição
    MOVE-CORRESPONDING wa_logdoc TO wa_logdoc_aux.

*       Tratamento de Icones
    CASE wa_logdoc-logty.
      WHEN 'E'.
        wa_logdoc_aux-icon = '@0A@'.
      WHEN 'W'.
        wa_logdoc_aux-icon = '@09@'.
      WHEN 'I'.
        wa_logdoc_aux-icon = '@08@'.
      WHEN 'S'.
        wa_logdoc_aux-icon = '@01@'.
    ENDCASE.
*       Seleciona o ID da mensagem
    IF wa_logdoc-logid IS INITIAL.
      wa_logdoc-logid = 'ZHMS_MC_LOGDOC'.
    ENDIF.
*       Busca log na classe de mensagem
    MESSAGE ID wa_logdoc-logid TYPE wa_logdoc-logty NUMBER wa_logdoc-logno
            INTO wa_logdoc_aux-ltext
            WITH wa_logdoc-logv1 wa_logdoc-logv2 wa_logdoc-logv3 wa_logdoc-logv4.

*       Adiciona dados a tabela de exibição
    APPEND wa_logdoc_aux TO t_logdoc_aux.
  ENDLOOP.
ENDMODULE.                 " M_GET_LOGS_DOC  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_LOGDOC_CHANGE_TC_ATTR  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_logdoc_change_tc_attr OUTPUT.
  DESCRIBE TABLE t_logdoc_aux LINES tc_logdoc-lines.
ENDMODULE.                 " TC_LOGDOC_CHANGE_TC_ATTR  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  M_STATUS_0171  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_status_0171 OUTPUT.
*
*
***    Variáveis Locais
*  DATA: tl_nodetable TYPE treev_ntab,
*        tl_itemtable TYPE item_table_type.
*
*  IF ob_vis_itens IS NOT INITIAL.
*    CALL METHOD ob_vis_itens->free.
*    CLEAR ob_vis_itens.
*  ENDIF.
*  IF ob_flow IS NOT INITIAL.
*    CALL METHOD ob_flow->free.
*    CLEAR ob_flow.
*  ENDIF.
*
*  IF ob_cc_vis_itens IS INITIAL.
****     Criando Objeto de Container do ALV
*    CREATE OBJECT ob_cc_vis_itens
*      EXPORTING
*        container_name              = 'CC_VIS_ITENS'
*      EXCEPTIONS
*        cntl_error                  = 1
*        cntl_system_error           = 2
*        create_error                = 3
*        lifetime_error              = 4
*        lifetime_dynpro_dynpro_link = 5.
*
*    IF sy-subrc NE 0.
****       Erro Interno. Contatar Suporte.
*      MESSAGE e000 WITH text-000.
*      STOP.
*    ENDIF.
*  ENDIF.
*
***    Objeto de TREE para FLOW
*  IF ob_vis_itens IS INITIAL.
****   Setando valores do Header da TREE
*    PERFORM f_build_hier_header_itens.
*
*    CREATE OBJECT ob_flow
*      EXPORTING
*        parent                      = ob_cc_vis_itens
*        node_selection_mode         = cl_gui_column_tree=>node_sel_mode_single
*        item_selection              = 'X'
*        hierarchy_column_name       = 'Etapas'
*        hierarchy_header            = wa_hier_header
*      EXCEPTIONS
*        cntl_system_error           = 1
*        create_error                = 2
*        failed                      = 3
*        illegal_node_selection_mode = 4
*        illegal_column_name         = 5
*        lifetime_error              = 6.
*    IF sy-subrc <> 0.
*      MESSAGE a000.
*    ENDIF.
*
****   Carregando catálogo de campo (flow)
*    PERFORM f_build_fieldcat_flow.
*
****   Registrando Eventos da Tree de Atribuição
*    PERFORM f_reg_events_flow.
*
*  ENDIF.
*
***    Limpar itens da tabela
*  CALL METHOD ob_flow->delete_all_nodes
*    EXCEPTIONS
*      failed            = 1
*      cntl_system_error = 2
*      OTHERS            = 3.
*
***    Criar nós
*  REFRESH: tl_nodetable, tl_itemtable.
*
****   Criando Hierarquia da TREE do XML
*  PERFORM f_create_hier_itens_flow USING tl_nodetable tl_itemtable.
*
***    Adicionar os nós criados
*  CALL METHOD ob_flow->add_nodes_and_items
*    EXPORTING
*      node_table                     = tl_nodetable
*      item_table                     = tl_itemtable
*      item_table_structure_name      = 'MTREEITM'
*    EXCEPTIONS
*      failed                         = 1
*      cntl_system_error              = 3
*      error_in_tables                = 4
*      dp_error                       = 5
*      table_structure_name_not_found = 6.
*  IF sy-subrc <> 0.
*    MESSAGE a000.
*  ENDIF.
*
***    Expandir os nós
*  CALL METHOD ob_flow->expand_root_nodes
*    EXCEPTIONS
*      failed              = 1
*      illegal_level_count = 2
*      cntl_system_error   = 3
*      OTHERS              = 4.
*
***    Ajustar largura
*  CALL METHOD ob_flow->hierarchy_header_adjust_width
*    EXCEPTIONS
*      OTHERS = 1.

ENDMODULE.                 " M_STATUS_0171  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT_FLOW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_fieldcat_flow .

  DATA: vl_name TYPE tv_itmname,
              vl_text TYPE tv_heading.

  REFRESH t_flow_fldc.
  CLEAR:  t_flow_fldc, wa_flow_fldc.

***   Obtendo catálogo de campos
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'ZHMS_ES_FLWDOC'
    CHANGING
      ct_fieldcat      = t_flow_fldc.

  IF sy-subrc EQ 0.
    LOOP AT t_flow_fldc INTO wa_flow_fldc.
      CASE wa_flow_fldc-fieldname.
        WHEN 'SELEC'
          OR 'MANDT'
          OR 'NATDC'
          OR 'TYPED'
          OR 'LOCTP'
          OR 'CHAVE'
          OR 'FLWST'
          OR 'DENOM'
          OR 'ICON'.
          wa_flow_fldc-no_out = 'X'.
          wa_flow_fldc-key    = ''.

        WHEN OTHERS.
          CLEAR: vl_name, vl_text.

          vl_name = wa_flow_fldc-fieldname.
          vl_text = wa_flow_fldc-reptext.

          CALL METHOD ob_flow->add_column
            EXPORTING
              name                         = vl_name
              width                        = 21
              header_text                  = vl_text
            EXCEPTIONS
              column_exists                = 1
              illegal_column_name          = 2
              too_many_columns             = 3
              illegal_alignment            = 4
              different_column_types       = 5
              cntl_system_error            = 6
              failed                       = 7
              predecessor_column_not_found = 8.
          IF sy-subrc <> 0.
            MESSAGE a000.
          ENDIF.

      ENDCASE.

      MODIFY t_flow_fldc FROM wa_flow_fldc.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " F_BUILD_FIELDCAT_FLOW
*&---------------------------------------------------------------------*
*&      Form  F_REG_EVENTS_FLOW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_reg_events_flow .

*     Variáveis locais
  DATA: wl_event  TYPE cntl_simple_event,
        tl_events TYPE cntl_simple_events,
        g_application TYPE REF TO lcl_application.

  " node double click
  wl_event-eventid = cl_gui_column_tree=>eventid_node_double_click.
  wl_event-appl_event = 'X'. " process PAI if event occurs
  APPEND wl_event TO tl_events.

  " item double click
  wl_event-eventid = cl_gui_column_tree=>eventid_item_double_click.
  wl_event-appl_event = 'X'.
  APPEND wl_event TO tl_events.

  " link click
  wl_event-eventid = cl_gui_column_tree=>eventid_link_click.
  wl_event-appl_event = 'X'.
  APPEND wl_event TO tl_events.

  " button click
  wl_event-eventid = cl_gui_column_tree=>eventid_button_click.
  wl_event-appl_event = 'X'.
  APPEND wl_event TO tl_events.

  CALL METHOD ob_flow->set_registered_events
    EXPORTING
      events                    = tl_events
    EXCEPTIONS
      cntl_error                = 1
      cntl_system_error         = 2
      illegal_event_combination = 3.
  IF sy-subrc <> 0.
    MESSAGE a000.
  ENDIF.

* assign event handlers in the application class to each desired event
  CREATE OBJECT g_application.
  SET HANDLER g_application->handle_link_click FOR ob_flow.
  SET HANDLER g_application->handle_button_click FOR ob_flow.

ENDFORM.                    " F_REG_EVENTS_FLOW
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_HIER_ITENS_FLOW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TL_NODETABLE  text
*      -->P_TL_ITEMTABLE  text
*----------------------------------------------------------------------*
FORM f_create_hier_itens_flow USING node_table TYPE treev_ntab
                                    item_table TYPE item_table_type.


**   variaveis locais
  DATA: node          TYPE treev_node,
        item          TYPE mtreeitm,
        vl_code       TYPE tv_nodekey,
        vl_text       TYPE string.

*      Adiciona primeiro nó a arvore
  node-node_key = c_nodekey-root.
  CLEAR node-relatkey.
  CLEAR node-relatship.
  CLEAR node-n_image.
  CLEAR node-exp_image.
  CLEAR node-expander.
  node-hidden = ' '.
  node-disabled = ' '.
  node-isfolder = 'X'.
  APPEND node TO node_table.

**    Adicionar Itens nas colunas
  vl_text = text-f02.
  CLEAR item.
  item-node_key = c_nodekey-root.
  item-item_name = 'Etapas'.
  item-class = cl_gui_column_tree=>item_class_text.
  item-text = vl_text.
  APPEND item TO item_table.

***   Construíndo tabela de saída
  PERFORM f_select_values_flow.
  CLEAR vl_code.
**   Percorre tabela de itens para montar
  t_flwdoc_ax2[] = t_flwdoc_ax[].
  LOOP AT t_flwdoc_ax2 INTO wa_flwdoc_ax.
    vl_code = vl_code + 1.
**        Adiciona histórico à arvore
    CONCATENATE wa_flwdoc_ax-flowd ' - ' wa_flwdoc_ax-denom INTO vl_text SEPARATED BY space.

    node-node_key = vl_code.
    node-relatkey = c_nodekey-root.
    node-relatship = cl_gui_column_tree=>relat_last_child.
    node-isfolder = ' '.
    node-exp_image = wa_flwdoc_ax-icon.
    node-n_image   = wa_flwdoc_ax-icon.
    APPEND node TO node_table.

**      Etapa / Descrição
    CLEAR item.
    item-node_key = vl_code.
    item-item_name = 'Etapas'.
    item-class = cl_gui_column_tree=>item_class_text.
    item-text = vl_text.
    item-ignoreimag = 'X'.
    APPEND item TO item_table.

**      Logs

    CLEAR item.
    item-node_key = vl_code.
    item-item_name = 'FLOWD'.
    item-class = cl_gui_column_tree=>item_class_button.
    item-text = ''.
    item-t_image = '@DH@'.
*        item-ignoreimag = 'X'.
    APPEND item TO item_table.

**** Inicio inclusão David Rosin 06/02/2014
    PERFORM f_habilita_botao.
    IF vg_funct IS NOT INITIAL.
      CLEAR item.
      item-node_key = vl_code.
      item-item_name = 'ESTOR'.
      item-class = cl_gui_column_tree=>item_class_button.
      item-text = ''.
      item-t_image = '@2W@'.
*        item-ignoreimag = 'X'.
      APPEND item TO item_table.
    ENDIF.
**** Fim Inclusão David Rosin 06/02/2014

**      Data do log
    CLEAR item.
    item-node_key = vl_code.
    item-item_name = 'DTREG'.
    item-class = cl_gui_column_tree=>item_class_text.
    item-ignoreimag = 'X'.

    CONCATENATE wa_flwdoc_ax-dtreg+6(2) '.' wa_flwdoc_ax-dtreg+4(2) '.' wa_flwdoc_ax-dtreg(4) INTO item-text.
    APPEND item TO item_table.

**      Hora do Log
    CLEAR item.
    item-node_key = vl_code.
    item-item_name = 'HRREG'.
    item-class = cl_gui_column_tree=>item_class_text.
    item-ignoreimag = 'X'.
    item-text = wa_flwdoc_ax-hrreg.
    CONCATENATE wa_flwdoc_ax-hrreg(2) ':' wa_flwdoc_ax-hrreg+2(2) ':' wa_flwdoc_ax-hrreg+4 INTO item-text.
    APPEND item TO item_table.

**      Usuario
    CLEAR item.
    item-node_key = vl_code.
    item-item_name = 'UNAME'.
    item-class = cl_gui_column_tree=>item_class_text.
    item-ignoreimag = 'X'.
    item-text = wa_flwdoc_ax-uname.
    APPEND item TO item_table.

**      Número do Documento
    CLEAR item.
    item-node_key = vl_code.
    item-item_name = 'NRDCG'.
    item-class = cl_gui_column_tree=>item_class_link.
    item-ignoreimag = 'X'.
    item-text = wa_flwdoc_ax-nrdcg.
    APPEND item TO item_table.

**      Ano do Documento
    CLEAR item.
    item-node_key = vl_code.
    item-item_name = 'YRDCG'.
    item-class = cl_gui_column_tree=>item_class_link.
    item-ignoreimag = 'X'.
    item-text = wa_flwdoc_ax-yrdcg.
    APPEND item TO item_table.
  ENDLOOP.
ENDFORM.                    " F_CREATE_HIER_ITENS_FLOW

*&---------------------------------------------------------------------*
*&      Form  F_HABILITA_BOTAO
*&---------------------------------------------------------------------*
FORM f_habilita_botao .


  DATA: ls_scen_flo TYPE zhms_tb_scen_flo,
        lt_mneum    TYPE STANDARD TABLE OF zhms_tb_docmn,
        ls_mneum    LIKE LINE OF lt_mneum,
        lt_mapping  TYPE STANDARD TABLE OF zhms_tb_mapdata,
        ls_mapping  LIKE LINE OF lt_mapping.

  READ TABLE t_chave INTO wa_chave INDEX 1.
  IF sy-subrc NE 0.
    wa_chave = vg_chave.
    APPEND wa_chave TO t_chave.
  ENDIF.

  CLEAR: wa_cabdoc, vg_funct.
  SELECT SINGLE * FROM zhms_tb_cabdoc INTO wa_cabdoc WHERE chave EQ wa_chave.

  IF sy-subrc IS INITIAL.

    SELECT SINGLE * FROM zhms_tb_scen_flo INTO ls_scen_flo WHERE natdc EQ wa_flwdoc_ax-natdc
                                                                       AND typed EQ wa_flwdoc_ax-typed
                                                                       AND scena EQ wa_cabdoc-scena
                                                                       AND flowd EQ wa_flwdoc_ax-flowd.

    IF sy-subrc IS INITIAL AND ls_scen_flo-funct_estorno IS NOT INITIAL.

*** Busca todos mneumonicos por chave
      SELECT * FROM zhms_tb_docmn INTO TABLE lt_mneum WHERE chave EQ wa_chave.

      IF sy-subrc IS NOT INITIAL.
        SELECT * FROM zhms_tb_docmn_hs INTO TABLE lt_mneum WHERE chave EQ wa_chave.
      ENDIF.

*** Busca mapeamento para esse cenario
      SELECT * FROM zhms_tb_mapdata INTO TABLE lt_mapping WHERE codmp EQ ls_scen_flo-codmp_estorno.

*** Busca numero da miro ou migo ou J1B1N
      SORT lt_mneum DESCENDING BY seqnr.
      READ TABLE lt_mneum INTO ls_mneum WITH KEY mneum = ls_scen_flo-mndoc.

      IF sy-subrc IS INITIAL.
        MOVE ls_scen_flo-funct_estorno TO vg_funct.
      ENDIF.

    ENDIF.

  ENDIF.

ENDFORM.                    " F_HABILITA_BOTAO
*&---------------------------------------------------------------------*
*&      Module  M_SHOW_XML_DOCS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_show_xml_docs OUTPUT.


ENDMODULE.                 " M_SHOW_XML_DOCS  OUTPUT
