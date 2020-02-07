*&---------------------------------------------------------------------*
*&  Include           ZHMS_MONITOR_LITE_F01
*&---------------------------------------------------------------------*
    FORM zf_check_auto_ext .
      TYPES: BEGIN OF ty_ekbe,
        ebeln TYPE ekbe-ebeln,
        ebelp TYPE ekbe-ebelp,
        zekkn TYPE ekbe-zekkn,
        vgabe TYPE ekbe-vgabe,
        gjahr TYPE ekbe-gjahr,
        belnr TYPE ekbe-belnr,
        buzei TYPE ekbe-buzei,
        bewtp TYPE ekbe-bewtp,
        bwart TYPE ekbe-bwart,
            END OF ty_ekbe.

      DATA: t_docmn       TYPE TABLE OF zhms_tb_docmn,
            w_docmn       TYPE zhms_tb_docmn,
            t_ekbe        TYPE TABLE OF ty_ekbe,
            w_ekbe        TYPE ty_ekbe,
            vl_xblnr      TYPE ekbe-xblnr,
            vl_tabix      TYPE sy-tabix,
            w_flwdoc_aux  TYPE zhms_tb_flwdoc,
            vl_migo       TYPE c LENGTH 10,
            vl_miro       TYPE c LENGTH 10,
            vl_lifnr      TYPE lfa1-lifnr,
            vl_lifnr_ekko TYPE lfa1-lifnr,
            vl_cnpj       TYPE lfa1-stcd1.


* Verifica se documento tem o MATDOC (MIRO) feita. Caso tenha, não
* faz verificação na EKBE em busca em MIRO externa
      SELECT *
        FROM zhms_tb_docmn
        INTO TABLE t_docmn
        FOR ALL ENTRIES IN t_cabdoc
        WHERE chave = t_cabdoc-chave.

      IF sy-subrc EQ 0.
        DELETE t_docmn
          WHERE mneum NE 'NNF'
            AND mneum NE 'SERIE'
            AND mneum NE 'MATDOC'
            AND mneum NE 'INVDOCNO'
            AND mneum NE 'CNPJ'.

        LOOP AT t_docmn INTO w_docmn.

          READ TABLE t_docmn INTO w_docmn WITH KEY chave = w_docmn-chave
                                                   mneum = 'NNF'.
          IF sy-subrc EQ 0.
            vl_xblnr = w_docmn-value.
            CONDENSE vl_xblnr NO-GAPS.
          ENDIF.

          READ TABLE t_docmn INTO w_docmn WITH KEY chave = w_docmn-chave
                                                   mneum = 'SERIE'.
          IF sy-subrc EQ 0.
            CONCATENATE vl_xblnr '-' w_docmn-value INTO vl_xblnr.
            CONDENSE vl_xblnr NO-GAPS.
          ENDIF.

          READ TABLE t_docmn INTO w_docmn WITH KEY chave = w_docmn-chave
                                                   mneum = 'CNPJ'.
          IF sy-subrc EQ 0.
            vl_cnpj = w_docmn-value.
            CONDENSE vl_cnpj NO-GAPS.
          ENDIF.

          SELECT ebeln ebelp zekkn vgabe gjahr belnr buzei bewtp bwart
            FROM ekbe
            INTO TABLE t_ekbe
            WHERE xblnr = vl_xblnr
              AND bewtp = 'E'
            ORDER BY belnr DESCENDING.
          IF sy-subrc EQ 0.
            READ TABLE t_ekbe INTO w_ekbe INDEX 1.

            SELECT SINGLE lifnr
              FROM ekko
              INTO vl_lifnr
              WHERE ebeln = w_ekbe-ebeln.
            IF sy-subrc EQ 0.
              SELECT SINGLE lifnr
                FROM lfa1
                INTO vl_lifnr_ekko
                WHERE stcd1 = vl_cnpj.
              IF sy-subrc EQ 0.
                IF vl_lifnr_ekko NE vl_lifnr.
                  EXIT.
                ENDIF.
              ENDIF.
            ENDIF.

            CLEAR w_flwdoc_aux.
            SELECT SINGLE *
              FROM zhms_tb_flwdoc
              INTO w_flwdoc_aux
              WHERE chave = w_docmn-chave
                AND flowd = '50'.

* MIGO feita por fora
            IF w_ekbe-bwart = '101' AND w_flwdoc_aux-uname NE 'HomSoft'.

              READ TABLE t_cabdoc INTO wa_cabdoc WITH KEY chave = w_docmn-chave.
              IF sy-subrc EQ 0.
                READ TABLE t_docst INTO wa_docst WITH KEY natdc = wa_cabdoc-natdc
                                                          typed = wa_cabdoc-typed
                                                          chave = wa_cabdoc-chave.
                IF sy-subrc EQ 0.
                  IF wa_docst-sthms NE 3.
                    vl_tabix = sy-tabix.
                    wa_docst-sthms = 3.
                    wa_docst-dtalt = sy-datum.
                    wa_docst-hralt = sy-uzeit.
                    MODIFY t_docst FROM wa_docst INDEX vl_tabix.
                    MODIFY zhms_tb_docst FROM wa_docst.
                  ENDIF.
                ENDIF.
              ENDIF.

            ELSE.

              CLEAR vl_migo.
              READ TABLE t_docmn INTO w_docmn WITH KEY chave = w_docmn-chave
                                                       mneum = 'MATDOC'.
              IF sy-subrc EQ 0.
                vl_migo = w_docmn-value.
              ENDIF.

              CLEAR vl_miro.
              READ TABLE t_docmn INTO w_docmn WITH KEY chave = w_docmn-chave
                                                       mneum = 'INVDOCNO'.
              IF sy-subrc EQ 0.
                vl_miro = w_docmn-value.
              ENDIF.


              READ TABLE t_cabdoc INTO wa_cabdoc WITH KEY chave = w_docmn-chave.
              IF sy-subrc EQ 0.
                READ TABLE t_docst INTO wa_docst WITH KEY natdc = wa_cabdoc-natdc
                                                         typed = wa_cabdoc-typed
                                                         chave = wa_cabdoc-chave.
                IF sy-subrc EQ 0.
                  vl_tabix = sy-tabix.

* Verifica se não é uma nota de cancelamento
                  IF wa_docst-sthms = 3 AND wa_docst-strec = 9.
                    EXIT.
                  ENDIF.

                  IF vl_migo IS NOT INITIAL AND vl_miro IS NOT INITIAL.
                    wa_docst-sthms = 1.
                  ELSE.
                    wa_docst-sthms = 2.
                  ENDIF.

                  wa_docst-dtalt = sy-datum.
                  wa_docst-hralt = sy-uzeit.
                  MODIFY t_docst FROM wa_docst INDEX vl_tabix.
                  MODIFY zhms_tb_docst FROM wa_docst.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.

      ENDIF.


    ENDFORM.                    " ZF_CHECK_AUTO_EXT

*&---------------------------------------------------------------------*
*&      Form  F_FIELDCAT
*&---------------------------------------------------------------------*
    FORM f_fieldcat  USING    value(p_0209)
                              p_text_002
                              value(p_0211)
                              value(p_0212)
                              value(check)
                              value(edit)
                              value(icon).

      CLEAR wa_hvalid_fldc.
      wa_hvalid_fldc-fieldname = p_0209.
      wa_hvalid_fldc-reptext   = p_text_002.
      wa_hvalid_fldc-col_opt   = p_0211.
      wa_hvalid_fldc-hotspot   = p_0212.
      wa_hvalid_fldc-checkbox  = check.
      wa_hvalid_fldc-edit      = edit.
      wa_hvalid_fldc-icon      = icon.
      APPEND wa_hvalid_fldc TO t_ht_field.
      CLEAR wa_hvalid_fldc.

    ENDFORM.                    " F_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  ZF_EXCLUDE
*&---------------------------------------------------------------------*
    FORM zf_exclude .

      DATA ls_exclude TYPE ui_func.

      CLEAR it_exclude.

      ls_exclude = cl_gui_alv_grid=>mc_fc_auf. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_average. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_back_classic. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_call_abc. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_call_chain. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_call_crbatch. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_call_crweb. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_call_lineitems. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_call_master_data. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_call_more. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_call_report. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_call_xint. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_call_xxl. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_check. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_col_invisible. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_col_optimize. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_count. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_current_variant. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_data_save. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_delete_filter. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_deselect_all. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_detail. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_excl_all. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_expcrdata. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_expcrdesig. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_expcrtempl. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_expmdb. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_extend. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_f4. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_filter. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_find. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_fix_columns. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_graph. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_help. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_html. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_info. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_load_variant. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_loc_move_row. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_maintain_variant. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_maximum. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_minimum. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_pc_file. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_print. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_print_back. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_print_prev. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_refresh. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_reprep. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_save_variant. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_select_all. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_send. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_separator. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_sort. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_sort_asc. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_sort_dsc. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_subtot. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_sum. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_to_office. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_to_rep_tree. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_unfix_columns. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_url_copy_to_clipboard. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_variant_admin. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_views. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_view_crystal. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_view_excel. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_view_grid. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_view_lotus. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row. APPEND ls_exclude TO it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_auf. APPEND ls_exclude TO it_exclude.
    ENDFORM.                    " ZF_EXCLUDE

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT_ITENS
*&---------------------------------------------------------------------*
    FORM f_build_fieldcat_itens .
      REFRESH t_fieldcatitm.
      CLEAR   wa_fieldcat.

***   Obtendo campos
      CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
        EXPORTING
          i_structure_name       = 'ZHMS_ES_ITMVIEW'
        CHANGING
          ct_fieldcat            = t_fieldcatitm
        EXCEPTIONS
          inconsistent_interface = 1
          program_error          = 2
          OTHERS                 = 3.

      IF sy-subrc EQ 0.
***     Alterando campos a serem exibidos
        LOOP AT t_fieldcatitm INTO wa_fieldcat.
          CASE wa_fieldcat-fieldname.
            WHEN 'SEQNR' OR 'DENOM' OR 'DCITM' OR 'TDSRF' OR 'NRSRF' OR 'ATPRP'.
              wa_fieldcat-no_out = 'X'.
              wa_fieldcat-key    = ''.

            WHEN 'DCCMT'.
              wa_fieldcat-outputlen = 15.
            WHEN 'DCQTD'.
              wa_fieldcat-outputlen = 15.
            WHEN 'DCUNM'.
              wa_fieldcat-outputlen = 10.
            WHEN 'DCPRC'.
              wa_fieldcat-outputlen = 17.
            WHEN 'ATLOT'.
              wa_fieldcat-outputlen = 15.

            WHEN OTHERS.

          ENDCASE.

          MODIFY t_fieldcatitm FROM wa_fieldcat.
        ENDLOOP.
      ENDIF.
    ENDFORM.                    " F_BUILD_FIELDCAT_ITENS

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_HIER_HEADER_ITENS
*&---------------------------------------------------------------------*
    FORM f_build_hier_header_itens .
      CLEAR wa_hier_header.
      MOVE: 'Item'   TO wa_hier_header-heading,
            text-h02 TO wa_hier_header-tooltip,
            20       TO wa_hier_header-width.
    ENDFORM.                    " F_BUILD_HIER_HEADER_ITENS

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_HIER_ITENS
*&---------------------------------------------------------------------*
    FORM f_create_hier_itens .

      DATA: vl_last_key   TYPE lvc_nkey,
            vl_parent_key TYPE lvc_nkey,
            vl_text       TYPE string,
            vl_text2      TYPE string,
            vl_node_exp   TYPE lvc_t_nkey.


***   Construíndo tabela de saída
*      PERFORM f_build_outtab_itens.
**    limpa variáveis
      REFRESH: t_itmdoc, t_itmatr, t_itensview.

**    Seleciona Itens
      SELECT *
        FROM zhms_tb_itmdoc
        INTO TABLE t_itmdoc
       WHERE natdc EQ vg_natdc     AND
             typed EQ vg_typed     AND
             loctp EQ wa_cabdoc-loctp    AND
             chave EQ vg_chave.

**    Seleciona Atribuições
      IF NOT t_itmdoc[] IS INITIAL.
        SELECT *
          FROM zhms_tb_itmatr
          INTO TABLE t_itmatr
           FOR ALL ENTRIES IN t_itmdoc
         WHERE natdc EQ t_itmdoc-natdc     AND
               typed EQ t_itmdoc-typed     AND
               loctp EQ t_itmdoc-loctp     AND
               chave EQ t_itmdoc-chave.
      ENDIF.
**   Ordena Tabelas
      SORT t_itmdoc BY dcitm ASCENDING.
      SORT t_itmatr BY dcitm ASCENDING
                       seqnr ASCENDING.

**   Percorre tabela de itens para montar
      LOOP AT t_itmdoc INTO wa_itmdoc.
**      Limpar variável de pai.
        CLEAR vl_parent_key.

        CLEAR wa_itensview.
        MOVE-CORRESPONDING wa_itmdoc TO wa_itensview.

        IF vg_typed EQ 'CTE'.
          CLEAR wa_docmn.
          SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmn WHERE chave EQ vg_chave
                                                             AND mneum EQ 'VTPREST'.

          IF sy-subrc IS INITIAL.
            MOVE wa_docmn-value TO  wa_itensview-dcprc.
          ENDIF.

        ENDIF.

**      Adiciona item do documento
**      Ajusta nome de ítem
**      Zeros a esquerda
        PERFORM f_remove_zeros USING wa_itmdoc-dcitm
                            CHANGING vl_text.
**      Remove espaços
        CONDENSE vl_text NO-GAPS.

**      Número Ítem + Descrição
        CONCATENATE vl_text '.' wa_itmdoc-denom INTO vl_text SEPARATED BY space.

        PERFORM f_add_no_itens    USING wa_itensview ''
                                        vl_text
                               CHANGING vl_parent_key.
**      Percorre atribuídos
        LOOP AT t_itmatr INTO wa_itmatr WHERE dcitm = wa_itmdoc-dcitm.
          CLEAR vl_text.

**        Tratamento para Denominação: Tipo de Documento
          CASE wa_itmatr-tdsrf.
            WHEN 1.
              MOVE text-s01 TO vl_text.
            WHEN 2.
              MOVE text-s02 TO vl_text.
            WHEN 3.
              MOVE text-s03 TO vl_text.
            WHEN 4.
              MOVE text-s04 TO vl_text.
            WHEN 5.
              MOVE text-s05 TO vl_text.
            WHEN 6.
              MOVE text-s06 TO vl_text.
            WHEN 7.
              MOVE text-s07 TO vl_text.
            WHEN 8.
              MOVE text-s08 TO vl_text.
            WHEN 9.
              MOVE text-s09 TO vl_text.
            WHEN 10.
              MOVE text-s10 TO vl_text.
            WHEN 11.
              MOVE text-s11 TO vl_text.
            WHEN 12.
              MOVE text-s12 TO vl_text.
            WHEN 13.
              MOVE text-s13 TO vl_text.
            WHEN 14.
              MOVE text-s14 TO vl_text.
            WHEN 15.
              MOVE text-s15 TO vl_text.
            WHEN 16.
              MOVE text-s16 TO vl_text.
            WHEN 17.
              MOVE text-s17 TO vl_text.
            WHEN 18.
              MOVE text-s18 TO vl_text.
            WHEN 19.
              MOVE text-s19 TO vl_text.
          ENDCASE.

**      Zeros a esquerda
          MOVE wa_itmatr-itsrf TO vl_text2.

**      Remove espaços
          CONDENSE vl_text2 NO-GAPS.

**      Número Atribuição + Tipo Documento + Numero Documento
          CONCATENATE  vl_text ':' wa_itmatr-nrsrf '(' vl_text2 ')' INTO vl_text SEPARATED BY space.

**      Demais campos
          wa_itensview-atlot = wa_itmatr-atlot.

**        Adiciona filhos (documentos atribuídos) à arvore
          PERFORM f_add_no_itens    USING wa_itensview vl_parent_key
                                          vl_text
                                 CHANGING vl_last_key.

**        Insere nó para expandir
          APPEND vl_parent_key TO vl_node_exp.

        ENDLOOP.

      ENDLOOP.

**      Expandir todos os nós
      CALL METHOD ob_vis_itens->expand_nodes
        EXPORTING
          it_node_key = vl_node_exp.

***   Atualizando valores no Objeto TREE criado
      CALL METHOD ob_vis_itens->frontend_update.

    ENDFORM.                    " F_CREATE_HIER_ITENS
*&---------------------------------------------------------------------*
*&      Form  F_BUILD_OUTTAB_ITENS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
    FORM f_build_outtab_itens .

    ENDFORM.                    " F_BUILD_OUTTAB_ITENS

*----------------------------------------------------------------------*
*   Form  f_add_no_itens
*----------------------------------------------------------------------*
*   Adicionando nós na árvore
*----------------------------------------------------------------------*
    FORM f_add_no_itens  USING  p_wa_itmview TYPE zhms_es_itmview
                                p_relat_key
                                p_text
                      CHANGING  p_node_key TYPE lvc_nkey.

***   Variáveis locais para controle de exibição da Árvore
      DATA: lt_item_layout TYPE lvc_t_layi,
            ls_item_layout TYPE lvc_s_layi,
            l_node_text    TYPE lvc_value.

***   Texto para exibição
      l_node_text =  p_text.

***   Layout da Árvore
      ls_item_layout-fieldname = ob_vis_itens->c_hierarchy_column_name.
      APPEND ls_item_layout TO lt_item_layout.

***   Chamada do método que insere linhas na árvore
      CALL METHOD ob_vis_itens->add_node
        EXPORTING
          i_relat_node_key = p_relat_key
          i_relationship   = cl_gui_column_tree=>relat_last_child
          is_outtab_line   = p_wa_itmview
          i_node_text      = l_node_text
          it_item_layout   = lt_item_layout
        IMPORTING
          e_new_node_key   = p_node_key.

    ENDFORM.                    " F_ADD_NO

*&---------------------------------------------------------------------*
*&      Form  f_remove_zeros
*&---------------------------------------------------------------------*
*       Remoção de zeros genérica
*----------------------------------------------------------------------*
    FORM f_remove_zeros USING p_input
                     CHANGING p_output.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = p_input
        IMPORTING
          output = p_output.

    ENDFORM.                    "f_remove_zeros

*&---------------------------------------------------------------------*
*&      Form  HANDEL_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    FORM handel_hotspot_click  USING    p_e_row_id
                                        p_e_column_id.
*      break rsantos.

      IF vg_chave IS INITIAL.
        READ TABLE t_0100 INTO wa_0100 INDEX p_e_row_id.
        IF sy-subrc EQ 0.
          vg_chave = wa_0100-chave.
        ENDIF.
      ENDIF.

      CHECK vg_chave IS NOT INITIAL.

      IF ob_cc_vis_itens IS NOT INITIAL.
        CALL METHOD ob_cc_vis_itens->free.
        CLEAR ob_cc_vis_itens.
      ENDIF.

      IF ob_vis_itens IS NOT INITIAL.
*        CALL METHOD ob_vis_itens->free.
        CLEAR ob_vis_itens.
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
      CLEAR vg_chave.
    ENDFORM.                    " HANDEL_HOTSPOT_CLICK

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_HIER_ITENS_ATR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
    FORM f_create_hier_itens_atr .
      DATA: vl_last_key   TYPE lvc_nkey,
            vl_parent_key TYPE lvc_nkey,
            vl_text       TYPE string,
            vl_text2      TYPE string,
            vl_node_exp   TYPE lvc_t_nkey.

***   Construíndo tabela de saída
      PERFORM f_build_outtab_itens_atr.

      IF vg_typed EQ 'CTE'.

        CLEAR wa_docmn.
        SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmn WHERE chave EQ vg_chave
                                                           AND mneum EQ 'VTPREST'.

        IF sy-subrc IS INITIAL.
          MOVE wa_docmn-value TO wa_itensview-dcprc.
        ENDIF.

      ENDIF.

**   Percorre tabela de itens para montar
      LOOP AT t_itmdoc_atr INTO wa_itmdoc.
**      Limpar variável de pai.
        CLEAR vl_parent_key.

        CLEAR wa_itensview.
        MOVE-CORRESPONDING wa_itmdoc TO wa_itensview.

        IF vg_typed EQ 'CTE'.

          CLEAR wa_docmn.
          SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmn WHERE chave EQ vg_chave
                                                             AND mneum EQ 'VTPREST'.

          IF sy-subrc IS INITIAL.
            MOVE wa_docmn-value TO wa_itensview-dcprc.
          ENDIF.

        ENDIF.

**      Adiciona item do documento

**      Ajusta nome de ítem
**      Zeros a esquerda
        PERFORM f_remove_zeros USING wa_itmdoc-dcitm
                            CHANGING vl_text.
**      Remove espaços
        CONDENSE vl_text NO-GAPS.

**      Número Ítem + Descrição
        CONCATENATE vl_text '.' wa_itmdoc-denom INTO vl_text SEPARATED BY space.

**      Limpar variaveis
        CLEAR vl_parent_key.

        PERFORM f_add_no_itens_atr    USING wa_itensview ''
                                            vl_text
                                   CHANGING vl_parent_key.
**      Percorre atribuídos
        LOOP AT t_itmatr_atr INTO wa_itmatr WHERE dcitm EQ wa_itmdoc-dcitm.
          CLEAR vl_text.

**        Tratamento para Denominação: Tipo de Documento
          CASE wa_itmatr-tdsrf.
            WHEN 1.
              MOVE text-s01 TO vl_text.
            WHEN 2.
              MOVE text-s02 TO vl_text.
            WHEN 3.
              MOVE text-s03 TO vl_text.
            WHEN 4.
              MOVE text-s04 TO vl_text.
            WHEN 5.
              MOVE text-s05 TO vl_text.
            WHEN 6.
              MOVE text-s06 TO vl_text.
            WHEN 7.
              MOVE text-s07 TO vl_text.
            WHEN 8.
              MOVE text-s08 TO vl_text.
            WHEN 9.
              MOVE text-s09 TO vl_text.
            WHEN 10.
              MOVE text-s10 TO vl_text.
            WHEN 11.
              MOVE text-s11 TO vl_text.
            WHEN 12.
              MOVE text-s12 TO vl_text.
            WHEN 13.
              MOVE text-s13 TO vl_text.
            WHEN 14.
              MOVE text-s14 TO vl_text.
            WHEN 15.
              MOVE text-s15 TO vl_text.
            WHEN 16.
              MOVE text-s16 TO vl_text.
            WHEN 17.
              MOVE text-s17 TO vl_text.
            WHEN 18.
              MOVE text-s18 TO vl_text.
            WHEN 19.
              MOVE text-s19 TO vl_text.
          ENDCASE.

**      Zeros a esquerda
          MOVE wa_itmatr-itsrf TO vl_text2.

**      Remove espaços
          CONDENSE vl_text2 NO-GAPS.

**      Demais campos
          wa_itensview-atlot = wa_itmatr-atlot.
          wa_itensview-dcqtd = wa_itmatr-atqtd.
          wa_itensview-dcprc = wa_itmatr-atprc.

**      Número Atribuição + Tipo Documento + Numero Documento
          CONCATENATE  vl_text ':' wa_itmatr-nrsrf '(' vl_text2 ')' INTO vl_text SEPARATED BY space.

**        Adiciona filhos (documentos atribuídos) à arvore
          PERFORM f_add_no_itens_atr    USING wa_itensview vl_parent_key
                                              vl_text
                                     CHANGING vl_last_key.
**        Insere nó para expandir
          APPEND vl_parent_key TO vl_node_exp.
        ENDLOOP.

      ENDLOOP.

**      Expandir todos os nós
      CALL METHOD ob_atr_itens->expand_nodes
        EXPORTING
          it_node_key = vl_node_exp.

***   Atualizando valores no Objeto TREE criado
      CALL METHOD ob_atr_itens->frontend_update.
    ENDFORM.                    " F_CREATE_HIER_ITENS_ATR

*&---------------------------------------------------------------------*
*&      Form  F_ADD_NO_ITENS_ATR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_ITENSVIEW  text
*      -->P_2033   text
*      -->P_VL_TEXT  text
*      <--P_VL_PARENT_KEY  text
*----------------------------------------------------------------------*
    FORM f_add_no_itens_atr  USING  p_wa_itmview TYPE zhms_es_itmview
                                    p_relat_key
                                    p_text
                          CHANGING  p_node_key TYPE lvc_nkey.

***   Variáveis locais para controle de exibição da Árvore
      DATA: lt_item_layout TYPE lvc_t_layi,
            ls_item_layout TYPE lvc_s_layi,
            l_node_text    TYPE lvc_value.

***   Texto para exibição
      l_node_text =  p_text.

***   Layout da Árvore
      ls_item_layout-fieldname = ob_vis_itens->c_hierarchy_column_name.
      APPEND ls_item_layout TO lt_item_layout.

***   Chamada do método que insere linhas na árvore
      CALL METHOD ob_atr_itens->add_node
        EXPORTING
          i_relat_node_key = p_relat_key
          i_relationship   = cl_gui_column_tree=>relat_last_child
          is_outtab_line   = p_wa_itmview
          i_node_text      = l_node_text
          it_item_layout   = lt_item_layout
        IMPORTING
          e_new_node_key   = p_node_key.

    ENDFORM.                    " F_ADD_NO_ITENS_ATR

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_OUTTAB_ITENS_ATR
*&---------------------------------------------------------------------*
    FORM f_build_outtab_itens_atr .
**    Seleciona Itens
      SELECT *
        FROM zhms_tb_itmdoc
        INTO TABLE t_itmdoc_atr
       WHERE natdc EQ vg_natdc     AND
             typed EQ vg_typed     AND
             loctp EQ wa_cabdoc-loctp    AND
             chave EQ vg_chave.

**    Seleciona Atribuições
      IF NOT t_itmdoc_atr[] IS INITIAL.
        SELECT *
          FROM zhms_tb_itmatr
          INTO TABLE t_itmatr_atr
           FOR ALL ENTRIES IN t_itmdoc_atr
         WHERE natdc EQ t_itmdoc_atr-natdc     AND
               typed EQ t_itmdoc_atr-typed     AND
               loctp EQ t_itmdoc_atr-loctp     AND
               chave EQ t_itmdoc_atr-chave.
      ENDIF.

**   Ordena Tabelas
      SORT t_itmdoc_atr BY dcitm ASCENDING.
      SORT t_itmatr_atr BY dcitm ASCENDING
                           seqnr ASCENDING.
    ENDFORM.                    " F_BUILD_OUTTAB_ITENS_ATR

*&---------------------------------------------------------------------*
*&      Form  F_REG_EVENTS_ATR
*&---------------------------------------------------------------------*
    FORM f_reg_events_atr .
* define the events which will be passed to the backend
      DATA: lt_events TYPE cntl_simple_events,
            l_event TYPE cntl_simple_event.

* define the events which will be passed to the backend
      l_event-eventid = cl_gui_column_tree=>eventid_item_double_click.
      APPEND l_event TO lt_events.

      CALL METHOD ob_atr_itens->set_registered_events
        EXPORTING
          events                    = lt_events
        EXCEPTIONS
          cntl_error                = 1
          cntl_system_error         = 2
          illegal_event_combination = 3.

* set Handler
      DATA: l_event_receiver TYPE REF TO lcl_tree_event_receiver.
      CREATE OBJECT l_event_receiver.
      SET HANDLER l_event_receiver->handle_item_double_click FOR ob_atr_itens.
    ENDFORM.                    " F_REG_EVENTS_ATR

*&---------------------------------------------------------------------*
*       Exibe atribuição para ítem selecionado
*----------------------------------------------------------------------*
*      -->P_ITEMSEL  text
*----------------------------------------------------------------------*
    FORM f_show_atr USING wa_itemsel STRUCTURE zhms_es_itmview.
**    Identifica o item selecionado
      CLEAR wa_itmdoc_ax.
      READ TABLE t_itmdoc INTO wa_itmdoc_ax WITH KEY dcitm = wa_itemsel-dcitm.
      vg_0500 = '502'.

**    Limpa dados anteriores
      REFRESH: t_itmatr_ax.

**    Recarrega a janela
      LEAVE TO SCREEN 500.

    ENDFORM.                    "f_show_atr

*&---------------------------------------------------------------------*
*&      Form  f_atr_proporcional
*&---------------------------------------------------------------------*
*       Calculos realizados caso atribuição proporcional esteja marcada
*----------------------------------------------------------------------*
    FORM f_atr_proporcional.
**    Verifica se ja foi digitado algum valor
      CHECK NOT t_itmatr_ax[] IS INITIAL.
**    Realiza contas para atribuição proporcional
      DATA: vl_atr_atprc TYPE zhms_de_atprc,
            vl_atr_atqtd TYPE zhms_de_atqtd,
            vl_pre_atprc TYPE zhms_de_atprc,
            vl_pre_atqtd TYPE zhms_de_atqtd,
            vl_qtd_atr   TYPE sy-tabix,
            vl_index     TYPE sy-tabix.

*      IF T_DOCMN[] IS INITIAL.
      READ TABLE t_itmatr_ax INTO wa_itmatr_ax INDEX 1.

      SELECT *
        FROM zhms_tb_docmn
        INTO TABLE t_docmn
*          WHERE CHAVE EQ WA_ITMATR_AX-CHAVE.
        WHERE chave EQ wa_cabdoc-chave.
*      ENDIF.

**    Inicio da conta: Identificar valor sem conversões
      "Quantidade de Linhas do split
      DESCRIBE TABLE t_itmatr_ax LINES vl_qtd_atr.

**    Verifica se a atribuição é simples (1 linha) ou split (várias linhas)
      IF vl_qtd_atr EQ 1.
**      Modifica o valor da primeira linha
        READ TABLE t_itmatr_ax INTO wa_itmatr_ax INDEX 1.
        wa_itmatr_ax-atprc = wa_itmdoc_ax-dcprc.
        IF wa_itmatr_ax-atqtd IS INITIAL.
          wa_itmatr_ax-atqtd = wa_itmdoc_ax-dcqtd.
        ENDIF.

        READ TABLE t_docmn INTO wa_docmn WITH KEY chave = wa_itmatr_ax-chave
                                                  dcitm = wa_itmatr_ax-dcitm
                                                  mneum = 'VUNCOM'.

        IF sy-subrc IS INITIAL.
          READ TABLE t_docmn INTO wa_docmnx WITH KEY mneum = 'IDDEST'.
          IF sy-subrc IS INITIAL AND wa_docmnx-value EQ '3'.

            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
              EXPORTING
                input  = wa_itmatr_ax-nrsrf
              IMPORTING
                output = wa_itmatr_ax-nrsrf.

            SELECT SINGLE netwr FROM ekpo INTO wa_itmatr_ax-atprc WHERE ebeln = wa_itmatr_ax-nrsrf
                                                                    AND ebelp = wa_itmatr_ax-itsrf.
          ELSE.

            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
              EXPORTING
                input  = wa_itmatr_ax-nrsrf
              IMPORTING
                output = wa_itmatr_ax-nrsrf.

            wa_itmatr_ax-atprc = wa_itmatr_ax-atqtd * wa_docmn-value.
          ENDIF.

        ENDIF.

        MODIFY t_itmatr_ax FROM wa_itmatr_ax INDEX 1.

      ENDIF.

      CHECK vl_qtd_atr GT 1.

**    Limpa as variáveis
      CLEAR: vl_atr_atqtd, vl_atr_atprc.

      "Divisão do total pela quantidade de linhas
*      vl_pre_atprc = wa_itmdoc_ax-dcprc / vl_qtd_atr. "Valor
      IF wa_itmdoc_ax-dcqtd IS INITIAL.
        vl_pre_atqtd = wa_itmdoc_ax-dcqtd / vl_qtd_atr. "Quantidades
      ENDIF.

**    Percorre estrutura de atribuição
      LOOP AT t_itmatr_ax INTO wa_itmatr_ax.
**      Manter o valor do indice em variável
        vl_index = sy-tabix.

**      Os itens terão os valores arredondados para baixo (exceto o ultimo)
**      Arrendodamento para baixo
        CALL FUNCTION 'ROUND'
          EXPORTING
            decimals      = 2
            input         = vl_pre_atprc
            sign          = '-'
          IMPORTING
            output        = wa_itmatr_ax-atprc
          EXCEPTIONS
            input_invalid = 1
            overflow      = 2
            type_invalid  = 3
            OTHERS        = 4.

**      Quantidade encontrada
        IF wa_itmatr_ax-atqtd IS INITIAL.
          wa_itmatr_ax-atqtd = vl_pre_atqtd.
        ENDIF.

**      Mantem valores já distribuídos
        vl_atr_atqtd = vl_atr_atqtd + wa_itmatr_ax-atqtd.
        vl_atr_atprc = vl_atr_atprc + wa_itmatr_ax-atprc.

        READ TABLE t_docmn INTO wa_docmn WITH KEY chave = wa_itmatr_ax-chave
                                                  dcitm = wa_itmatr_ax-dcitm
                                                  mneum = 'VUNCOM'.

        IF sy-subrc IS INITIAL.
          wa_itmatr_ax-atprc = wa_itmatr_ax-atqtd * wa_docmn-value.
        ENDIF.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = wa_itmatr_ax-nrsrf
          IMPORTING
            output = wa_itmatr_ax-nrsrf.

**      Insere os resultados na estrutura de atribução
        MODIFY t_itmatr_ax FROM wa_itmatr_ax INDEX vl_index.
      ENDLOOP.


**    O último item receberá apenas os valores restantes para igualar a conta
*      READ TABLE t_itmatr_ax INTO wa_itmatr_ax INDEX vl_qtd_atr.
***    Retira os ultimos valores da conta
*      vl_atr_atprc = vl_atr_atprc - wa_itmatr_ax-atprc.
*      vl_atr_atqtd = vl_atr_atqtd - wa_itmatr_ax-atqtd.
*
***    Realiza conta dos valores faltantes
*      wa_itmatr_ax-atprc = wa_itmdoc_ax-dcprc - vl_atr_atprc. "Valor
*      wa_itmatr_ax-atqtd = wa_itmdoc_ax-dcqtd - vl_atr_atqtd. "Quantidade
*
***    Insere os resultados na estrutura de atribução
*      MODIFY t_itmatr_ax FROM wa_itmatr_ax INDEX vl_qtd_atr.


    ENDFORM.                    "f_atr_proporcional

*&---------------------------------------------------------------------*
*&      Form  f_atr_completalista
*&---------------------------------------------------------------------*
*       Completa a lista de atribuição para exibição
*----------------------------------------------------------------------*
    FORM f_atr_completalista.

      DATA: vl_index     TYPE sy-tabix,
            vl_seqnr     TYPE zhms_de_seqnr,
            wl_ekpo      TYPE ekpo,
            tl_ekpo_res  TYPE TABLE OF ekpo,
            tl_ekpo      TYPE TABLE OF ekpo.

      CLEAR vl_seqnr.

      LOOP AT t_itmatr_ax INTO wa_itmatr_ax .
        wa_itmatr_ax-chave = vg_chave.
        MODIFY t_itmatr_ax FROM wa_itmatr_ax INDEX sy-tabix.
      ENDLOOP.

**    Tratamento para tipos de documentos do SAP
      CASE vg_tdsrf.
        WHEN 01. " Pedido de Compras
**        Cria uma tabela interna para pedidos de compra
          REFRESH tl_ekpo.
          LOOP AT t_itmatr_ax INTO wa_itmatr_ax.
            vl_index = sy-tabix.
            CLEAR wl_ekpo.

            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
              EXPORTING
                input  = wa_itmatr_ax-nrsrf
              IMPORTING
                output = wa_itmatr_ax-nrsrf.

            MOVE wa_itmatr_ax-nrsrf TO wl_ekpo-ebeln.
            MOVE wa_itmatr_ax-itsrf TO wl_ekpo-ebelp.

            APPEND wl_ekpo TO tl_ekpo.
            MODIFY t_itmatr_ax FROM wa_itmatr_ax INDEX vl_index.
          ENDLOOP.

**        Seleciona dados na EKPO
          IF tl_ekpo[] IS NOT INITIAL.
            REFRESH tl_ekpo_res[].
            SELECT *
              INTO TABLE tl_ekpo_res
              FROM ekpo
               FOR ALL ENTRIES IN tl_ekpo
             WHERE ebeln EQ tl_ekpo-ebeln
               AND ebelp EQ tl_ekpo-ebelp.
          ENDIF.

        WHEN OTHERS.
      ENDCASE.

**    Percorre estrutura de atribuição
      LOOP AT t_itmatr_ax INTO wa_itmatr_ax.

        SELECT SINGLE *
          FROM zhms_tb_itmdoc
          INTO wa_itmdoc_ax
         WHERE chave EQ wa_itmatr_ax-chave
           AND dcitm EQ wa_itmatr_ax-dcitm.

**      Manter o valor do indice em variável
        vl_index = sy-tabix.

**      Sequência numérica: Chave única
        ADD 1 TO vl_seqnr.
        wa_itmatr_ax-seqnr = vl_seqnr.

**      Unidade de Medida
*        wa_itmatr_ax-atunm = wa_itmdoc_ax-dcunm.

**      Processamento Proporcional
        wa_itmatr_ax-atprp = vg_atprp.

**      Tipo de documento SAP de referencia
        wa_itmatr_ax-tdsrf = vg_tdsrf.

**      Campos provenientes da tabela de itens.
        wa_itmatr_ax-natdc = wa_itmdoc_ax-natdc.
        wa_itmatr_ax-typed = wa_itmdoc_ax-typed.
        wa_itmatr_ax-loctp = wa_itmdoc_ax-loctp.
        wa_itmatr_ax-chave = wa_itmdoc_ax-chave.
        wa_itmatr_ax-dcitm = wa_itmdoc_ax-dcitm.

**      Seleção de material atribuído no pedido
        CLEAR wl_ekpo.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = wa_itmatr_ax-nrsrf
          IMPORTING
            output = wa_itmatr_ax-nrsrf.

        MOVE wa_itmatr_ax-nrsrf TO wl_ekpo-ebeln.
        MOVE wa_itmatr_ax-itsrf TO wl_ekpo-ebelp.

        READ TABLE tl_ekpo_res
              INTO wl_ekpo
          WITH KEY ebelp = wl_ekpo-ebelp
                   ebeln = wl_ekpo-ebeln.
        IF sy-subrc IS INITIAL.
          wa_itmatr_ax-atmat = wl_ekpo-matnr.
          wa_itmatr_ax-atunm = wl_ekpo-meins.
        ELSE.

          IF wl_ekpo-ebelp IS NOT INITIAL AND wl_ekpo-ebeln IS NOT INITIAL.

            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = wl_ekpo-ebeln
              IMPORTING
                output = wl_ekpo-ebeln.

            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = wl_ekpo-ebelp
              IMPORTING
                output = wl_ekpo-ebelp.

            SELECT SINGLE matnr meins
              FROM ekpo
              INTO (wa_itmatr_ax-atmat, wa_itmatr_ax-atunm)
              WHERE ebeln = wl_ekpo-ebeln
                AND ebelp = wl_ekpo-ebelp.

          ENDIF.
        ENDIF.

**      Insere os resultados na estrutura de atribução
        MODIFY t_itmatr_ax FROM wa_itmatr_ax INDEX vl_index.

      ENDLOOP.
    ENDFORM.                    "f_atr_completalista

*&---------------------------------------------------------------------*
*&      Form  F_ATR_VALIDAR
*&---------------------------------------------------------------------*
*       Validar atribuição
*----------------------------------------------------------------------*
    FORM f_atr_valida  CHANGING p_vl_erro.
      DATA: vl_tot_atprc TYPE zhms_de_atprc,
            vl_tot_atqtd TYPE zhms_de_atqtd.

      DATA: wl_ekko TYPE ekko.

**    Verifica se foi inserido algum registro na tabela de atribuição
      IF t_itmatr_ax IS INITIAL.
        p_vl_erro = 'X'.
      ENDIF.

*      Verifica se algum erro foi encontrado
      CHECK p_vl_erro IS INITIAL.

**    Identifica se os campos foram preenchidos
      IF vg_tdsrf IS INITIAL.
        p_vl_erro = 'X'.
        MESSAGE i053 .
      ENDIF.

**    Verificação na estrutura
      LOOP AT t_itmatr_ax INTO wa_itmatr_ax.
        "Verifica se o numero de documento sap de referencia foi informado
        IF wa_itmatr_ax-nrsrf EQ 0.
          CHECK p_vl_erro IS INITIAL.
          p_vl_erro = 'X'.
          MESSAGE i054 .
        ENDIF.

        "Verifica se o numero de documento sap de referencia foi informado
        IF wa_itmatr_ax-itsrf EQ 0.
          CHECK p_vl_erro IS INITIAL.
          p_vl_erro = 'X'.
          MESSAGE i055 .
        ENDIF.

*       Verifica se algum erro foi encontrado
        CHECK p_vl_erro IS INITIAL.

        IF vg_tdsrf EQ 1. "Verifica se o pedido é válido
          CLEAR wl_ekko.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              input  = wa_itmatr_ax-nrsrf
            IMPORTING
              output = wa_itmatr_ax-nrsrf.

          MOVE wa_itmatr_ax-nrsrf TO wl_ekko-ebeln.


          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wl_ekko-ebeln
            IMPORTING
              output = wl_ekko-ebeln.

**        Busca na tabela
          SELECT SINGLE *
            INTO wl_ekko
            FROM ekko
           WHERE ebeln EQ wl_ekko-ebeln.

**        Verifica se existe registro
          IF NOT sy-subrc IS INITIAL.
            p_vl_erro = 'X'.
            MESSAGE i056 WITH wl_ekko-ebeln.
          ENDIF.

*         Verifica se algum erro foi encontrado
          CHECK p_vl_erro IS INITIAL.
**        Verifica se o pedido é correspondente ao fornecedor do documento

          IF wl_ekko-lifnr NE wa_cabdoc-parid.
            p_vl_erro = 'X'.
            MESSAGE i057 WITH wl_ekko-lifnr wl_ekko-ebeln wa_cabdoc-parid.
          ENDIF.

        ENDIF.
      ENDLOOP.

*      Verifica se algum erro foi encontrado
      CHECK p_vl_erro IS INITIAL.

**    Caso a atribuição proporcional esteja ativada não é necessário realizar contas
      IF NOT vg_atprp EQ 'X'.
*      Limpa variaveis de totais para iniciar somas
        CLEAR: vl_tot_atprc, vl_tot_atqtd.

        LOOP AT t_itmatr_ax INTO wa_itmatr_ax.
**        Quantidades
          vl_tot_atqtd = vl_tot_atqtd + wa_itmatr_ax-atqtd.
**        Preço
          vl_tot_atprc = vl_tot_atprc + wa_itmatr_ax-atprc.
        ENDLOOP.

        IF wa_cabdoc-typed NE 'CTE'.
**      Verifica Quantidades
          IF wa_cabdoc-typed NE 'NFSE'.
            IF vl_tot_atqtd NE wa_itmdoc_ax-dcqtd.
**        Exibe mensagem  e registra o erro
              p_vl_erro = 'X'.
              MESSAGE i050 WITH wa_itmdoc_ax-dcqtd vl_tot_atqtd.
            ENDIF.
          ENDIF.

**      Verifica Valores
          IF vl_tot_atprc NE wa_itmdoc_ax-dcprc.
**        Exibe mensagem  e registra o erro
            p_vl_erro = 'X'.
            MESSAGE i051 WITH wa_itmdoc_ax-dcprc vl_tot_atprc.
          ENDIF.
        ENDIF.
      ENDIF.

    ENDFORM.                    " F_ATR_VALIDAR
*&---------------------------------------------------------------------*
*&      Form  F_ATR_GRAVAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
    FORM f_atr_gravar .

**    Variáveis locais
      DATA: vl_seqnr     TYPE zhms_de_seqnr,
*            vl_atitmproc TYPE i,
            vl_atitm     TYPE zhms_de_atitm,
            vl_last      TYPE flag,
            lv_po        TYPE ebeln.

      DATA: tl_docum     TYPE TABLE OF zhms_es_docum,
            wl_docum     TYPE zhms_es_docum,
            tl_itmatr    TYPE TABLE OF zhms_tb_itmatr,
            wl_itmatr    TYPE zhms_tb_itmatr,
            tl_logdoc    TYPE TABLE OF zhms_tb_logdoc,
            wl_logdoc    TYPE zhms_tb_logdoc.
      REFRESH: t_atrbuffer.

      CLEAR: vl_seqnr.
**    Seleciona o primeiro registro inserido
      READ TABLE t_itmatr_ax INTO wa_itmatr_ax INDEX 1.

**    Verifica se existe o primeiro registro. Caso não a tabela está vazia
      CHECK sy-subrc IS INITIAL.

**    Deleta outras ocorrencias antes de gravar
      DELETE FROM zhms_tb_itmatr
       WHERE natdc EQ wa_itmatr_ax-natdc
         AND typed EQ wa_itmatr_ax-typed
         AND loctp EQ wa_itmatr_ax-loctp
         AND chave EQ wa_itmatr_ax-chave
         AND dcitm EQ wa_itmatr_ax-dcitm.
**    Garante a deleção
      COMMIT WORK AND WAIT.

**    Insere atribuição na tabela de atribuições.
      LOOP AT t_itmatr_ax INTO wa_itmatr_ax.

        IF wa_itmatr_ax-nrsrf IS NOT INITIAL.
          CLEAR lv_po.
          MOVE wa_itmatr_ax-nrsrf TO lv_po.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = lv_po
            IMPORTING
              output = lv_po.
          CLEAR wa_itmatr_ax-nrsrf.
          MOVE lv_po TO wa_itmatr_ax-nrsrf.
        ENDIF.

        MOVE-CORRESPONDING wa_itmatr_ax TO wa_itmatr.

        INSERT INTO zhms_tb_itmatr VALUES wa_itmatr.
      ENDLOOP.

**    Ajusta item de processamento
      SELECT *
        INTO TABLE tl_itmatr
        FROM zhms_tb_itmatr
       WHERE natdc EQ wa_itmatr_ax-natdc
         AND typed EQ wa_itmatr_ax-typed
         AND loctp EQ wa_itmatr_ax-loctp
         AND chave EQ wa_itmatr_ax-chave.

**    Ordenar
      SORT tl_itmatr BY dcitm ASCENDING
                        atitm ASCENDING.
      CLEAR vl_atitm.

      LOOP AT tl_itmatr INTO wl_itmatr.
        vl_atitm = vl_atitm + 1.
**      Atualizar tabela
        UPDATE zhms_tb_itmatr
           SET atitm = vl_atitm
         WHERE natdc EQ wl_itmatr-natdc
           AND typed EQ wl_itmatr-typed
           AND loctp EQ wl_itmatr-loctp
           AND chave EQ wl_itmatr-chave
           AND dcitm EQ wl_itmatr-dcitm
           AND seqnr EQ wl_itmatr-seqnr.

        COMMIT WORK AND WAIT.

**      Atualizar tabela interna
        READ TABLE t_itmatr_ax
              INTO wa_itmatr_ax
          WITH KEY  natdc = wl_itmatr-natdc
                    typed = wl_itmatr-typed
                    loctp = wl_itmatr-loctp
                    chave = wl_itmatr-chave
                    dcitm = wl_itmatr-dcitm
                    seqnr = wl_itmatr-seqnr.
        IF sy-subrc IS INITIAL.

          IF  wa_itmatr_ax-nrsrf IS NOT INITIAL.
            CLEAR lv_po.
            MOVE wa_itmatr_ax-nrsrf TO lv_po.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = lv_po
              IMPORTING
                output = lv_po.
            CLEAR wa_itmatr_ax-nrsrf.
            MOVE lv_po TO wa_itmatr_ax-nrsrf.
          ENDIF.

          wa_itmatr_ax-atitm = vl_atitm.
          MODIFY t_itmatr_ax FROM wa_itmatr_ax INDEX sy-tabix.
        ENDIF.
      ENDLOOP.


**    Buscar mneumonicos a serem gerados
      SELECT *
        INTO TABLE t_mneuatr
        FROM zhms_tb_mneuatr.

* Apaga atribuição anterior
      IF vg_just_ok IS INITIAL.
        READ TABLE t_itmatr_ax INTO wa_itmatr_ax INDEX 1.
        DELETE FROM zhms_tb_docmn
         WHERE chave EQ wa_itmatr-chave
           AND dcitm EQ wa_itmatr_ax-dcitm
           AND ( mneum EQ 'ATQTD'
              OR mneum EQ 'ATUM'
              OR mneum EQ 'ATPED'
              OR mneum EQ 'ATITMPED'
              OR mneum EQ 'ATITMXML'
              OR mneum EQ 'ATITMPROC'
*            OR mneum EQ 'XMLNCM'
              OR mneum EQ 'ATVLR'
              OR mneum EQ 'AEXTLOT'
              OR mneum EQ 'DATAPROD'
              OR mneum EQ 'DATAVENC'
              OR mneum EQ 'ATTLOT'
              OR mneum EQ 'ATITMXML'
              OR mneum EQ 'ATITMPED'
              OR mneum EQ 'ATQTDE'
              OR mneum EQ 'ATVCOFINS'
              OR mneum EQ 'ATVCOFINSS'
              OR mneum EQ 'ATCRICMSST'
              OR mneum EQ 'ATDESC'
              OR mneum EQ 'ATFRT'
              OR mneum EQ 'ATVICMS'
              OR mneum EQ 'ATVICMSST'
              OR mneum EQ 'ATICMSSDES'
              OR mneum EQ 'ATICMSSRET'
              OR mneum EQ 'ATVII'
              OR mneum EQ 'ATVIOF'
              OR mneum EQ 'ATVIPI'
              OR mneum EQ 'ATVISSQN'
              OR mneum EQ 'ATDESPAC'
              OR mneum EQ 'ATVPIS'
              OR mneum EQ 'ATVPISST'
              OR mneum EQ 'ATVLR'
              OR mneum EQ 'ATSEG'
              OR mneum EQ 'NCM'
              OR mneum EQ 'ATPED'
              OR mneum EQ 'MATDOC'
              OR mneum EQ 'FISCALYEAR'
              OR mneum EQ 'MATDOCYEA'
              OR mneum = 'ACTIVITY'
              OR mneum = 'ASSETNO'
              OR mneum = 'BUDGPERIOD'
              OR mneum = 'BUSAREA'
              OR mneum = 'CMMTITEM'
              OR mneum = 'CMMTITMLON'
              OR mneum = 'COAREA'
              OR mneum = 'COSTCENTER'
              OR mneum = 'COSTCTR'
              OR mneum = 'COSTOBJ'
              OR mneum = 'CUSTOMER'
              OR mneum = 'DELIVITEM'
              OR mneum = 'DELIVNUMB'
              OR mneum = 'DISTRPERC'
              OR mneum = 'ENRYUOMISO'
              OR mneum = 'FUNAREALON'
              OR mneum = 'FUNCAREA'
              OR mneum = 'FUND'
              OR mneum = 'FUNDSCTR'
              OR mneum = 'FUNDSRES'
              OR mneum = 'GLACCOUNT'
              OR mneum = 'GLACCT'
              OR mneum = 'GRANTNBR'
              OR mneum = 'GRRCPT'
              OR mneum = 'MATDOCYEA'
              OR mneum = 'MATERIAL'
              OR mneum = 'MATLGROUP'
              OR mneum = 'MATLUSAGE'
              OR mneum = 'MATORIGIN'
              OR mneum = 'MVTIND'
              OR mneum = 'NBSLIPS'
              OR mneum = 'NETPRICE'
              OR mneum = 'NETWORK'
              OR mneum = 'ORDERID'
              OR mneum = 'ORDERNO'
              OR mneum = 'PARTACCT'
              OR mneum = 'PLANT'
              OR mneum = 'PROFITCTR'
              OR mneum = 'PROFSEGM'
              OR mneum = 'PROFSEGMNO'
              OR mneum = 'PROJEXT'
              OR mneum = 'QUANTITY'
              OR mneum = 'RECIND'
              OR mneum = 'REFDATE'
              OR mneum = 'RESITEM'
              OR mneum = 'RLESTKEY'
              OR mneum = 'ROUTINGNO'
              OR mneum = 'SCHEDLINE'
              OR mneum = 'SDDOC'
              OR mneum = 'SDOCITEM'
              OR mneum = 'SERIALNO'
              OR mneum = 'STGELOC'
              OR mneum = 'SUBNUMBER'
              OR mneum = 'TAXCODE'
              OR mneum = 'TAXJURCODE'
              OR mneum = 'TOCOSTCTR'
              OR mneum = 'TOORDER'
              OR mneum = 'TOPROJECT'
              OR mneum = 'VALTYPE'
              OR mneum = 'VENDOR'
              OR mneum = 'WBSELEM'
              OR mneum = 'WBSELEME' ).
        COMMIT WORK AND WAIT.
      ELSE.
*** Inicio Inclusão David Rosin
*** Limpa mneumonicos da tabela interna
        DELETE t_docmn  WHERE chave EQ wa_itmatr-chave
                  AND dcitm EQ wa_itmatr_ax-dcitm
                  AND ( mneum EQ 'ATQTD'
                   OR mneum EQ 'ATUM'
                   OR mneum EQ 'ATPED'
                   OR mneum EQ 'ATITMPED'
                   OR mneum EQ 'ATITMXML'
                   OR mneum EQ 'ATITMPROC'
                   OR mneum EQ 'ATVLR'
                   OR mneum EQ 'AEXTLOT'
                   OR mneum EQ 'DATAPROD'
                   OR mneum EQ 'DATAVENC'
                   OR mneum EQ 'XMLNCM'
                   OR mneum EQ 'ATTLOT'
                   OR mneum EQ 'ATITMXML'
                   OR mneum EQ 'ATITMPED'
                   OR mneum EQ 'ATQTDE'
                   OR mneum EQ 'ATVCOFINS'
                   OR mneum EQ 'ATVCOFINSS'
                   OR mneum EQ 'ATCRICMSST'
                   OR mneum EQ 'ATDESC'
                   OR mneum EQ 'ATFRT'
                   OR mneum EQ 'ATVICMS'
                   OR mneum EQ 'ATVICMSST'
                   OR mneum EQ 'ATICMSSDES'
                   OR mneum EQ 'ATICMSSRET'
                   OR mneum EQ 'ATVII'
                   OR mneum EQ 'ATVIOF'
                   OR mneum EQ 'ATVIPI'
                   OR mneum EQ 'ATVISSQN'
                   OR mneum EQ 'ATDESPAC'
                   OR mneum EQ 'ATVPIS'
                   OR mneum EQ 'ATVPISST'
                   OR mneum EQ 'ATVLR'
                   OR mneum EQ 'ATSEG'
                   OR mneum EQ 'NCM'
                   OR mneum EQ 'ATPED'
                   OR mneum EQ 'MATDOC'
                   OR mneum EQ 'FISCALYEAR'
                   OR mneum EQ 'MATDOCYEA'
                   OR mneum = 'ACTIVITY'
                   OR mneum = 'ASSETNO'
                   OR mneum = 'BUDGPERIOD'
                   OR mneum = 'BUSAREA'
                   OR mneum = 'CMMTITEM'
                   OR mneum = 'CMMTITMLON'
                   OR mneum = 'COAREA'
                   OR mneum = 'COSTCENTER'
                   OR mneum = 'COSTCTR'
                   OR mneum = 'COSTOBJ'
                   OR mneum = 'CUSTOMER'
                   OR mneum = 'DELIVITEM'
                   OR mneum = 'DELIVNUMB'
                   OR mneum = 'DISTRPERC'
                   OR mneum = 'ENRYUOMISO'
                   OR mneum = 'FUNAREALON'
                   OR mneum = 'FUNCAREA'
                   OR mneum = 'FUND'
                   OR mneum = 'FUNDSCTR'
                   OR mneum = 'FUNDSRES'
                   OR mneum = 'GLACCOUNT'
                   OR mneum = 'GLACCT'
                   OR mneum = 'GRANTNBR'
                   OR mneum = 'GRRCPT'
                   OR mneum = 'MATDOCYEA'
                   OR mneum = 'MATERIAL'
                   OR mneum = 'MATLGROUP'
                   OR mneum = 'MATLUSAGE'
                   OR mneum = 'MATORIGIN'
                   OR mneum = 'MVTIND'
                   OR mneum = 'NBSLIPS'
                   OR mneum = 'NETPRICE'
                   OR mneum = 'NETWORK'
                   OR mneum = 'ORDERID'
                   OR mneum = 'ORDERNO'
                   OR mneum = 'PARTACCT'
                   OR mneum = 'PLANT'
                   OR mneum = 'PROFITCTR'
                   OR mneum = 'PROFSEGM'
                   OR mneum = 'PROFSEGMNO'
                   OR mneum = 'PROJEXT'
                   OR mneum = 'QUANTITY'
                   OR mneum = 'RECIND'
                   OR mneum = 'REFDATE'
                   OR mneum = 'RESITEM'
                   OR mneum = 'RLESTKEY'
                   OR mneum = 'ROUTINGNO'
                   OR mneum = 'SCHEDLINE'
                   OR mneum = 'SDDOC'
                   OR mneum = 'SDOCITEM'
                   OR mneum = 'SERIALNO'
                   OR mneum = 'STGELOC'
                   OR mneum = 'SUBNUMBER'
                   OR mneum = 'TAXCODE'
                   OR mneum = 'TAXJURCODE'
                   OR mneum = 'TOCOSTCTR'
                   OR mneum = 'TOORDER'
                   OR mneum = 'TOPROJECT'
                   OR mneum = 'VALTYPE'
                   OR mneum = 'VENDOR'
                   OR mneum = 'WBSELEM'
                   OR mneum = 'WBSELEME' ).
*** Fim Inclusão David Rosin
      ENDIF.

      IF vg_just_ok IS INITIAL.
*** Inicio Inclusão David Rosin
*** Limpa mneumonicos da tabela interna
        DELETE t_docmn  WHERE chave EQ wa_itmatr-chave
                    AND dcitm EQ wa_itmatr_ax-dcitm
                    AND ( mneum EQ 'ATQTD'
                     OR mneum EQ 'ATQTDE'
                     OR mneum EQ 'ATUM'
                     OR mneum EQ 'ATPED'
                     OR mneum EQ 'ATITMPED'
                     OR mneum EQ 'ATITMXML'
                     OR mneum EQ 'ATITMPROC'
*              OR mneum EQ 'NCM'
                     OR mneum EQ 'AEXTLOT'
                     OR mneum EQ 'DATAPROD'
                     OR mneum EQ 'DATAVENC'
                     OR mneum EQ 'ATVLR'
                     OR mneum EQ 'ATTLOT'
                     OR mneum EQ 'ATITMXML'
                     OR mneum EQ 'ATITMPED'
                     OR mneum EQ 'ATQTDE'
                     OR mneum EQ 'ATVCOFINS'
                     OR mneum EQ 'ATVCOFINSS'
                     OR mneum EQ 'ATCRICMSST'
                     OR mneum EQ 'ATDESC'
                     OR mneum EQ 'ATFRT'
                     OR mneum EQ 'ATVICMS'
                     OR mneum EQ 'ATVICMSST'
                     OR mneum EQ 'ATICMSSDES'
                     OR mneum EQ 'ATICMSSRET'
                     OR mneum EQ 'ATVII'
                     OR mneum EQ 'ATVIOF'
                     OR mneum EQ 'ATVIPI'
                     OR mneum EQ 'ATVISSQN'
                     OR mneum EQ 'ATDESPAC'
                     OR mneum EQ 'ATVPIS'
                     OR mneum EQ 'ATVPISST'
                     OR mneum EQ 'ATVLR'
                     OR mneum EQ 'ATSEG'
                     OR mneum EQ 'NCM'
                     OR mneum EQ 'ATPED'
                     OR mneum EQ 'MATDOC'
                     OR mneum EQ 'FISCALYEAR'
                     OR mneum EQ 'MATDOCYEA'
                     OR mneum = 'ACTIVITY'
                     OR mneum = 'ASSETNO'
                     OR mneum = 'BUDGPERIOD'
                     OR mneum = 'BUSAREA'
                     OR mneum = 'CMMTITEM'
                     OR mneum = 'CMMTITMLON'
                     OR mneum = 'COAREA'
                     OR mneum = 'COSTCENTER'
                     OR mneum = 'COSTCTR'
                     OR mneum = 'COSTOBJ'
                     OR mneum = 'CUSTOMER'
                     OR mneum = 'DELIVITEM'
                     OR mneum = 'DELIVNUMB'
                     OR mneum = 'DISTRPERC'
                     OR mneum = 'ENRYUOMISO'
                     OR mneum = 'FUNAREALON'
                     OR mneum = 'FUNCAREA'
                     OR mneum = 'FUND'
                     OR mneum = 'FUNDSCTR'
                     OR mneum = 'FUNDSRES'
                     OR mneum = 'GLACCOUNT'
                     OR mneum = 'GLACCT'
                     OR mneum = 'GRANTNBR'
                     OR mneum = 'GRRCPT'
                     OR mneum = 'MATDOCYEA'
                     OR mneum = 'MATERIAL'
                     OR mneum = 'MATLGROUP'
                     OR mneum = 'MATLUSAGE'
                     OR mneum = 'MATORIGIN'
                     OR mneum = 'MVTIND'
                     OR mneum = 'NBSLIPS'
                     OR mneum = 'NETPRICE'
                     OR mneum = 'NETWORK'
                     OR mneum = 'ORDERID'
                     OR mneum = 'ORDERNO'
                     OR mneum = 'PARTACCT'
                     OR mneum = 'PLANT'
                     OR mneum = 'PROFITCTR'
                     OR mneum = 'PROFSEGM'
                     OR mneum = 'PROFSEGMNO'
                     OR mneum = 'PROJEXT'
                     OR mneum = 'QUANTITY'
                     OR mneum = 'RECIND'
                     OR mneum = 'REFDATE'
                     OR mneum = 'RESITEM'
                     OR mneum = 'RLESTKEY'
                     OR mneum = 'ROUTINGNO'
                     OR mneum = 'SCHEDLINE'
                     OR mneum = 'SDDOC'
                     OR mneum = 'SDOCITEM'
                     OR mneum = 'SERIALNO'
                     OR mneum = 'STGELOC'
                     OR mneum = 'SUBNUMBER'
                     OR mneum = 'TAXCODE'
                     OR mneum = 'TAXJURCODE'
                     OR mneum = 'TOCOSTCTR'
                     OR mneum = 'TOORDER'
                     OR mneum = 'TOPROJECT'
                     OR mneum = 'VALTYPE'
                     OR mneum = 'VENDOR'
                     OR mneum = 'WBSELEM'
                     OR mneum = 'WBSELEME' ).
*** Fim Inclusão David Rosin
      ELSE.
        DELETE t_docmn  WHERE chave EQ wa_itmatr-chave
                   AND dcitm EQ wa_itmatr_ax-dcitm
                   AND ( mneum EQ 'ATQTD'
                    OR mneum EQ 'ATUM'
                    OR mneum EQ 'ATPED'
                    OR mneum EQ 'ATITMPED'
                    OR mneum EQ 'ATITMXML'
                    OR mneum EQ 'ATITMPROC'
                    OR mneum EQ 'XMLNCM'
                    OR mneum EQ 'ATVLR'
                    OR mneum EQ 'AEXTLOT'
                    OR mneum EQ 'DATAPROD'
                    OR mneum EQ 'DATAVENC'
                    OR mneum EQ 'ATTLOT'
                    OR mneum EQ 'ATITMXML'
                    OR mneum EQ 'ATITMPED'
                    OR mneum EQ 'ATQTDE'
                    OR mneum EQ 'ATVCOFINS'
                    OR mneum EQ 'ATVCOFINSS'
                    OR mneum EQ 'ATCRICMSST'
                    OR mneum EQ 'ATDESC'
                    OR mneum EQ 'ATFRT'
                    OR mneum EQ 'ATVICMS'
                    OR mneum EQ 'ATVICMSST'
                    OR mneum EQ 'ATICMSSDES'
                    OR mneum EQ 'ATICMSSRET'
                    OR mneum EQ 'ATVII'
                    OR mneum EQ 'ATVIOF'
                    OR mneum EQ 'ATVIPI'
                    OR mneum EQ 'ATVISSQN'
                    OR mneum EQ 'ATDESPAC'
                    OR mneum EQ 'ATVPIS'
                    OR mneum EQ 'ATVPISST'
                    OR mneum EQ 'ATVLR'
                    OR mneum EQ 'ATSEG'
                    OR mneum EQ 'NCM'
                    OR mneum EQ 'ATPED'
                    OR mneum EQ 'MATDOC'
                    OR mneum EQ 'FISCALYEAR'
                    OR mneum EQ 'MATDOCYEA'
                    OR mneum = 'ACTIVITY'
                    OR mneum = 'ASSETNO'
                    OR mneum = 'BUDGPERIOD'
                    OR mneum = 'BUSAREA'
                    OR mneum = 'CMMTITEM'
                    OR mneum = 'CMMTITMLON'
                    OR mneum = 'COAREA'
                    OR mneum = 'COSTCENTER'
                    OR mneum = 'COSTCTR'
                    OR mneum = 'COSTOBJ'
                    OR mneum = 'CUSTOMER'
                    OR mneum = 'DELIVITEM'
                    OR mneum = 'DELIVNUMB'
                    OR mneum = 'DISTRPERC'
                    OR mneum = 'ENRYUOMISO'
                    OR mneum = 'FUNAREALON'
                    OR mneum = 'FUNCAREA'
                    OR mneum = 'FUND'
                    OR mneum = 'FUNDSCTR'
                    OR mneum = 'FUNDSRES'
                    OR mneum = 'GLACCOUNT'
                    OR mneum = 'GLACCT'
                    OR mneum = 'GRANTNBR'
                    OR mneum = 'GRRCPT'
                    OR mneum = 'MATDOCYEA'
                    OR mneum = 'MATERIAL'
                    OR mneum = 'MATLGROUP'
                    OR mneum = 'MATLUSAGE'
                    OR mneum = 'MATORIGIN'
                    OR mneum = 'MVTIND'
                    OR mneum = 'NBSLIPS'
                    OR mneum = 'NETPRICE'
                    OR mneum = 'NETWORK'
                    OR mneum = 'ORDERID'
                    OR mneum = 'ORDERNO'
                    OR mneum = 'PARTACCT'
                    OR mneum = 'PLANT'
                    OR mneum = 'PROFITCTR'
                    OR mneum = 'PROFSEGM'
                    OR mneum = 'PROFSEGMNO'
                    OR mneum = 'PROJEXT'
                    OR mneum = 'QUANTITY'
                    OR mneum = 'RECIND'
                    OR mneum = 'REFDATE'
                    OR mneum = 'RESITEM'
                    OR mneum = 'RLESTKEY'
                    OR mneum = 'ROUTINGNO'
                    OR mneum = 'SCHEDLINE'
                    OR mneum = 'SDDOC'
                    OR mneum = 'SDOCITEM'
                    OR mneum = 'SERIALNO'
                    OR mneum = 'STGELOC'
                    OR mneum = 'SUBNUMBER'
                    OR mneum = 'TAXCODE'
                    OR mneum = 'TAXJURCODE'
                    OR mneum = 'TOCOSTCTR'
                    OR mneum = 'TOORDER'
                    OR mneum = 'TOPROJECT'
                    OR mneum = 'VALTYPE'
                    OR mneum = 'VENDOR'
                    OR mneum = 'WBSELEM'
                    OR mneum = 'WBSELEME' ).
      ENDIF.

**    Gerar Mneumonicos com base na atribuição feita
      PERFORM f_nextseq_mneum CHANGING vl_seqnr.

**    Percorre Items
      LOOP AT t_itmatr_ax INTO wa_itmatr_ax.

**      Ponteiro ITMDOC
        READ TABLE t_itmdoc INTO wa_itmdoc WITH KEY chave = wa_itmatr_ax-chave
                                                    dcitm = wa_itmatr_ax-dcitm.

**      definir Ultimo
        CLEAR vl_last.
        AT LAST.
          vl_last = 'X'.
        ENDAT.

* Quantidade final
        CLEAR wa_docmn.
        vl_seqnr = vl_seqnr + 1.
        wa_docmn-chave = wa_itmatr-chave.
        wa_docmn-seqnr = vl_seqnr.
        wa_docmn-mneum = 'ATQTD'.
        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
        wa_docmn-atitm = wa_itmatr_ax-atitm.
        wa_docmn-value = wa_itmatr_ax-atqtd.
        CONDENSE wa_docmn-value NO-GAPS.
        APPEND wa_docmn TO t_docmn.

*Unidade final
        CLEAR wa_docmn.
        vl_seqnr = vl_seqnr + 1.
        wa_docmn-chave = wa_itmatr-chave.
        wa_docmn-seqnr = vl_seqnr.
        wa_docmn-mneum = 'ATUM'.
        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
        wa_docmn-atitm = wa_itmatr_ax-atitm.
        wa_docmn-value = wa_itmatr_ax-atunm.
        CONDENSE wa_docmn-value NO-GAPS.
        APPEND wa_docmn TO t_docmn.

*
*        CASE WA_ITMATR_AX-TDSRF.
*          WHEN '1'. " Pedido de compra

*           Documento Referencia
        CLEAR wa_docmn.
        vl_seqnr = vl_seqnr + 1.
        wa_docmn-chave = wa_itmatr-chave.
        wa_docmn-seqnr = vl_seqnr.
        wa_docmn-mneum = 'ATPED'.
        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
        wa_docmn-atitm = wa_itmatr_ax-atitm.

        IF wa_itmatr_ax-nrsrf IS NOT INITIAL.
          CLEAR lv_po.
          MOVE wa_itmatr_ax-nrsrf TO lv_po.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = lv_po
            IMPORTING
              output = lv_po.
          CLEAR wa_itmatr_ax-nrsrf.
          MOVE lv_po TO wa_itmatr_ax-nrsrf.
        ENDIF.

        wa_docmn-value = wa_itmatr_ax-nrsrf.
        CONDENSE wa_docmn-value NO-GAPS.
        APPEND wa_docmn TO t_docmn.

*           Item Documento referencia
        CLEAR wa_docmn.
        vl_seqnr = vl_seqnr + 1.
        wa_docmn-chave = wa_itmatr-chave.
        wa_docmn-seqnr = vl_seqnr.
        wa_docmn-mneum = 'ATITMPED'.
        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
        wa_docmn-atitm = wa_itmatr_ax-atitm.
        wa_docmn-value = wa_itmatr_ax-itsrf.
        CONDENSE wa_docmn-value NO-GAPS.
        APPEND wa_docmn TO t_docmn.

*          WHEN OTHERS.
*        ENDCASE.



*Item do XML
        CLEAR wa_docmn.
        vl_seqnr = vl_seqnr + 1.
        wa_docmn-chave = wa_itmatr-chave.
        wa_docmn-seqnr = vl_seqnr.
        wa_docmn-mneum = 'ATITMXML'.
        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
        wa_docmn-atitm = wa_itmatr_ax-atitm.
        wa_docmn-value = wa_itmatr_ax-dcitm.
        CONDENSE wa_docmn-value NO-GAPS.
        APPEND wa_docmn TO t_docmn.


*Item para processamento
        CLEAR wa_docmn.
        vl_seqnr       = vl_seqnr + 1.
        wa_docmn-chave = wa_itmatr-chave.
        wa_docmn-seqnr = vl_seqnr.
        wa_docmn-mneum = 'ATITMPROC'.
        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
        wa_docmn-atitm = wa_itmatr_ax-atitm.
        wa_docmn-value = wa_itmatr_ax-atitm.
        CONDENSE wa_docmn-value NO-GAPS.
        APPEND wa_docmn TO t_docmn.


*valor do item
        CLEAR wa_docmn.
        vl_seqnr = vl_seqnr + 1.
        wa_docmn-chave = wa_itmatr-chave.
        wa_docmn-seqnr = vl_seqnr.
        wa_docmn-mneum = 'ATVLR'.
        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
        wa_docmn-atitm = wa_itmatr_ax-atitm.
        wa_docmn-value = wa_itmatr_ax-atprc.
        CONDENSE wa_docmn-value NO-GAPS.
        APPEND wa_docmn TO t_docmn.

        IF NOT wa_itmatr_ax-ncm IS INITIAL AND NOT vg_just_ok IS INITIAL..
* Quantidade final
          CLEAR wa_docmn.
          vl_seqnr = vl_seqnr + 1.
          wa_docmn-chave = wa_itmatr-chave.
          wa_docmn-seqnr = vl_seqnr.
          wa_docmn-mneum = 'XMLNCM'.
          wa_docmn-dcitm = wa_itmatr_ax-dcitm.
          wa_docmn-atitm = wa_itmatr_ax-atitm.
          wa_docmn-value = wa_itmatr_ax-ncm.
          CONDENSE wa_docmn-value NO-GAPS.
          APPEND wa_docmn TO t_docmn.
        ENDIF.

* Lote
        CLEAR wa_docmn.
        vl_seqnr = vl_seqnr + 1.
        wa_docmn-chave = wa_itmatr-chave.
        wa_docmn-seqnr = vl_seqnr.
        wa_docmn-mneum = 'ATTLOT'.
        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
        wa_docmn-atitm = wa_itmatr_ax-atitm.
        wa_docmn-value = wa_itmatr_ax-atlot.
        CONDENSE wa_docmn-value NO-GAPS.
        APPEND wa_docmn TO t_docmn.

        CLEAR wa_docmn.
        vl_seqnr = vl_seqnr + 1.
        wa_docmn-chave = wa_itmatr-chave.
        wa_docmn-seqnr = vl_seqnr.
        wa_docmn-mneum = 'AEXTLOT'.
        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
        wa_docmn-atitm = wa_itmatr_ax-atitm.
        wa_docmn-value = wa_itmatr_ax-exlot.
        CONDENSE wa_docmn-value NO-GAPS.
        APPEND wa_docmn TO t_docmn.

        CLEAR wa_docmn.
        vl_seqnr = vl_seqnr + 1.
        wa_docmn-chave = wa_itmatr-chave.
        wa_docmn-seqnr = vl_seqnr.
        wa_docmn-mneum = 'DATAPROD'.
        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
        wa_docmn-atitm = wa_itmatr_ax-atitm.
        wa_docmn-value = wa_itmatr_ax-data_prod.
        CONDENSE wa_docmn-value NO-GAPS.
        APPEND wa_docmn TO t_docmn.

        CLEAR wa_docmn.
        vl_seqnr = vl_seqnr + 1.
        wa_docmn-chave = wa_itmatr-chave.
        wa_docmn-seqnr = vl_seqnr.
        wa_docmn-mneum = 'DATAVENC'.
        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
        wa_docmn-atitm = wa_itmatr_ax-atitm.
        wa_docmn-value = wa_itmatr_ax-data_venc.
        CONDENSE wa_docmn-value NO-GAPS.
        APPEND wa_docmn TO t_docmn.

**      Percorre Mneumônicos de valores a serem gerados pela Atribuição
        LOOP AT t_mneuatr INTO wa_mneuatr.


**        Busca mneumonico de origem para geração do mneumonico de atribuição
          READ TABLE t_docmn_rep INTO wa_docmn_ax WITH KEY mneum = wa_mneuatr-mnorg
                                                       dcitm = wa_itmatr_ax-dcitm.

**        Verifica se existe mneumonico de origem
          CHECK sy-subrc IS INITIAL.

          IF wa_docmn_ax-mneum EQ 'NITEMPED'.
            IF wa_docmn_ax-value NE wa_itmatr_ax-itsrf.
              CONTINUE.
            ENDIF.
          ENDIF.

* Apaga atribuição anterior
          DELETE FROM zhms_tb_docmn
           WHERE chave EQ wa_itmatr-chave
             AND dcitm EQ wa_itmatr_ax-dcitm
             AND mneum EQ wa_mneuatr-mndst.

          COMMIT WORK AND WAIT.

**        Transfere valores
          CLEAR wa_docmn.
          vl_seqnr = vl_seqnr + 1.
          wa_docmn-chave = wa_itmatr-chave.
          wa_docmn-seqnr = vl_seqnr.
          wa_docmn-mneum = wa_mneuatr-mndst.
          wa_docmn-dcitm = wa_itmatr_ax-dcitm.
          wa_docmn-atitm = wa_itmatr_ax-atitm.

**        Cálculos de proporção para distribuição
          IF wa_mneuatr-mnorg NE 'NITEMPED'.
            PERFORM f_calcula_proporcao USING wa_docmn_ax-value wa_itmdoc-dcqtd wa_itmatr_ax-atqtd vl_last wa_docmn-mneum
                                     CHANGING wa_docmn-value.
          ELSE.
            MOVE wa_docmn_ax-value TO wa_docmn-value.
          ENDIF.
          CONDENSE wa_docmn-value NO-GAPS.
          APPEND wa_docmn TO t_docmn.
        ENDLOOP.

      ENDLOOP.

      SORT t_docmn ASCENDING BY mneum dcitm atitm.
      DELETE ADJACENT DUPLICATES FROM t_docmn COMPARING mneum dcitm atitm.

**     Corrige os zeros a esquera
      LOOP AT t_docmn INTO wa_docmn.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = wa_docmn-seqnr
          IMPORTING
            output = wa_docmn-seqnr.
        MODIFY t_docmn FROM wa_docmn INDEX sy-tabix.
      ENDLOOP.

**    Insere/Modifica dados no repositorio de mneumonicos
*      INSERT zhms_tb_docmn FROM TABLE t_docmn.
      MODIFY zhms_tb_docmn FROM TABLE t_docmn.
      COMMIT WORK AND WAIT.

**    Executa regras identificação de cenário
      CLEAR wl_docum.
      wl_docum-dctyp = 'CHAVE'.
      wl_docum-dcnro = wa_cabdoc-chave.
      APPEND wl_docum TO tl_docum.

*      CALL FUNCTION 'ZHMS_FM_TRACER'
*        EXPORTING
*          natdc                 = wa_cabdoc-natdc
*          typed                 = wa_cabdoc-typed
*          loctp                 = wa_cabdoc-loctp
*          just_ident            = 'X'
*        TABLES
*          docum                 = tl_docum
*        EXCEPTIONS
*          document_not_informed = 1
*          scenario_not_found    = 2
*          OTHERS                = 3.

** Registra LOG
      wl_logdoc-logty = 'S'.
      wl_logdoc-logno = '500'.
      APPEND wl_logdoc TO tl_logdoc.

      CALL FUNCTION 'ZHMS_FM_REGLOG'
        EXPORTING
          cabdoc = wa_cabdoc
          flwst  = 'M'
          tpprm  = 4
        TABLES
          logdoc = tl_logdoc.

**    Limpa as estruturas de atribução
      CLEAR: wa_itmatr_ax.
      REFRESH: t_itmatr_ax.

**    Seta tela inicial
      vg_0500 = '0501'.

**    Exibe mensagem de sucesso
      MESSAGE s052.
    ENDFORM.                    " F_ATR_GRAVAR
*&---------------------------------------------------------------------*
*&      Form  f_calcula_proporcao
*&---------------------------------------------------------------------*
*       Efetua os cálculos de proporção
*----------------------------------------------------------------------*
    FORM f_calcula_proporcao USING p_antvlr p_antqtd p_newqtd p_last p_field
                          CHANGING p_newvlr.
*    Variáveis Locais
      DATA: vl_indexbuff TYPE sy-tabix,
            vl_newvlr    TYPE zhms_de_usprc.

*    Busca dados ja atribuidos (soma)
      CLEAR wa_atrbuffer.
      READ TABLE t_atrbuffer INTO wa_atrbuffer WITH KEY field = p_field.
      vl_indexbuff = sy-tabix.

*    Caso não seja o ultimo realiza a conta via regra de 3
      IF p_last IS INITIAL.
        vl_newvlr = ( p_newqtd * p_antvlr ) / p_antqtd.
        MOVE vl_newvlr TO p_newvlr.

      ELSE.
*    Caso seja o último realiza a conta via subtração do valor total
        vl_newvlr = p_antvlr - wa_atrbuffer-sumat.
        MOVE vl_newvlr TO p_newvlr.

      ENDIF.

*     Mantem total armazenado
      IF NOT vl_indexbuff IS INITIAL.
        wa_atrbuffer-sumat = wa_atrbuffer-sumat + vl_newvlr.
        MODIFY t_atrbuffer FROM wa_atrbuffer INDEX vl_indexbuff.
      ELSE.
        wa_atrbuffer-field = p_field.
        wa_atrbuffer-sumat = vl_newvlr.
        APPEND wa_atrbuffer TO t_atrbuffer.
      ENDIF.

    ENDFORM.                    "f_calcula_proporcao

*&---------------------------------------------------------------------*
*&      Form  F_NEXTSEQ_MNEUM
*&---------------------------------------------------------------------*
*       recupera próximo seqnr para mneumonicos
*----------------------------------------------------------------------*
    FORM f_nextseq_mneum  CHANGING p_vl_seqnr.
**    Variáveis locais
      DATA: tl_seqnr TYPE TABLE OF zhms_de_seqnr,
            wl_seqnr TYPE zhms_de_seqnr.

**    Seleção das sequencias
      SELECT seqnr
        INTO TABLE tl_seqnr
        FROM zhms_tb_docmn
       WHERE chave EQ wa_cabdoc-chave.

      IF sy-subrc IS NOT INITIAL.
**    Seleção das sequencias
        SELECT seqnr
          INTO TABLE tl_seqnr
          FROM zhms_tb_docmn_hs
         WHERE chave EQ wa_cabdoc-chave.
      ENDIF.

**    Identifica a ultima
      SORT tl_seqnr DESCENDING.
      READ TABLE tl_seqnr INTO wl_seqnr INDEX 1.

      p_vl_seqnr = wl_seqnr.

    ENDFORM.                    " F_NEXTSEQ_MNEUM

*&---------------------------------------------------------------------*
*&      Module  m_atr_buscaanteriores  OUTPUT
*&---------------------------------------------------------------------*
*     Buscar atribuições anteriores para edição
*----------------------------------------------------------------------*
    MODULE m_atr_buscaanteriores OUTPUT.
      CHECK t_itmatr_ax IS INITIAL.

**    Percorre estrutura de mapeamento preenchida pela TREE
      LOOP AT t_itmatr_atr INTO wa_itmatr WHERE dcitm EQ wa_itmdoc_ax-dcitm.
**      Move para estrutura de atribuição
        CLEAR wa_itmatr_ax.

        MOVE-CORRESPONDING wa_itmatr TO wa_itmatr_ax.

*** Seleciona valores NCM
        IF wa_itmatr_ax-ncm IS INITIAL.
          SELECT SINGLE value
            FROM zhms_tb_docmn
            INTO wa_itmatr_ax-ncm
           WHERE chave EQ wa_itmatr-chave
             AND dcitm EQ wa_itmatr-dcitm
             AND mneum EQ 'XMLNCM'
             AND atitm EQ wa_itmatr-atitm.

          IF sy-subrc IS NOT INITIAL." OR  wa_itmatr_ax-ncm IS INITIAL.

            READ TABLE t_docmn_rep INTO wa_docmn_rep
              WITH KEY dcitm = wa_itmatr-dcitm
                       mneum = 'XMLNCM'
                       atitm = wa_itmatr-atitm.

            IF sy-subrc IS INITIAL.
              MOVE wa_docmn_rep-value TO wa_itmatr_ax-ncm.
            ENDIF.
          ENDIF.
        ENDIF.

        APPEND wa_itmatr_ax TO t_itmatr_ax.

**      Preenche variaveis de seleção na tela
        vg_tdsrf = wa_itmatr_ax-tdsrf.
        vg_atprp = wa_itmatr_ax-atprp.

      ENDLOOP.
    ENDMODULE. "m_atr_buscaanteriores

*&---------------------------------------------------------------------*
*&      Module  M_ATR_PROPORCIONAL  OUTPUT
*&---------------------------------------------------------------------*
*       Controle para seleção de tipo de documento
*----------------------------------------------------------------------*
    MODULE m_atr_tipodocumento OUTPUT.
**    Verifica se ja possui valor no campo
      IF vg_tdsrf IS INITIAL.
**      Percorre a tela para encontrar o campo vg_tdsrf e o botão BTN_UNLOCK
        LOOP AT SCREEN.
**        Esconde o botão
          IF screen-name EQ 'BTN_UNLOCK'.
            screen-invisible = 1.
            MODIFY SCREEN.
          ENDIF.
**        Habilita a edição do campo
          IF screen-name EQ 'VG_TDSRF'.
            screen-input = 1.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.
      ELSE.
**      Percorre a tela para encontrar o campo vg_tdsrf e o botão BTN_UNLOCK
        LOOP AT SCREEN.
**        Exibe o botão
          IF screen-name EQ 'BTN_UNLOCK'.
            screen-invisible = 0.
            MODIFY SCREEN.
          ENDIF.
**        Desabilita a edição do campo
          IF screen-name EQ 'VG_TDSRF'.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.
      ENDIF.

      REFRESH t_show_po[].
      CALL FUNCTION 'ZHMS_FM_BUSCA_PO_POSSIVEIS'
        EXPORTING
          chave     = vg_chave
        TABLES
          t_show_po = t_show_po.

    ENDMODULE.                    "m_atr_tipodocumento OUTPUT


*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
    FORM user_ok_tc USING    p_tc_name TYPE dynfnam
                             p_table_name
                             p_mark_name
                    CHANGING p_ok      LIKE sy-ucomm.

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
      DATA: l_ok              TYPE sy-ucomm,
            l_offset          TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

*&SPWIZARD: Table control specific operations                          *
*&SPWIZARD: evaluate TC name and operations                            *
      SEARCH p_ok FOR p_tc_name.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
      l_offset = strlen( p_tc_name ) + 1.
      l_ok = p_ok+l_offset.
*&SPWIZARD: execute general and TC specific operations                 *
      CASE l_ok.
        WHEN 'INSR'.                      "insert row
          PERFORM fcode_insert_row USING    p_tc_name
                                            p_table_name.
          CLEAR p_ok.

        WHEN 'DELE'.                      "delete row
          PERFORM fcode_delete_row USING    p_tc_name
                                            p_table_name
                                            p_mark_name.
          CLEAR p_ok.

        WHEN 'P--' OR                     "top of list
             'P-'  OR                     "previous page
             'P+'  OR                     "next page
             'P++'.                       "bottom of list
          PERFORM compute_scrolling_in_tc USING p_tc_name
                                                l_ok.
          CLEAR p_ok.
*     WHEN 'L--'.                       "total left
*       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
*
*     WHEN 'L-'.                        "column left
*       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
*
*     WHEN 'R+'.                        "column right
*       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
*
*     WHEN 'R++'.                       "total right
*       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
*
        WHEN 'MARK'.                      "mark all filled lines
          PERFORM fcode_tc_mark_lines USING p_tc_name
                                            p_table_name
                                            p_mark_name   .
          CLEAR p_ok.

        WHEN 'DMRK'.                      "demark all filled lines
          PERFORM fcode_tc_demark_lines USING p_tc_name
                                              p_table_name
                                              p_mark_name .
          CLEAR p_ok.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.

      ENDCASE.

    ENDFORM.                              " USER_OK_TC


*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
    FORM fcode_insert_row
                  USING    p_tc_name           TYPE dynfnam
                           p_table_name             .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
      DATA l_lines_name       LIKE feld-name.
      DATA l_selline          LIKE sy-stepl.
      DATA l_lastline         TYPE i.
      DATA l_line             TYPE i.
      DATA l_table_name       LIKE feld-name.
      FIELD-SYMBOLS <tc>                 TYPE cxtab_control.
      FIELD-SYMBOLS <table>              TYPE STANDARD TABLE.
      FIELD-SYMBOLS <lines>              TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

      ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
      CONCATENATE p_table_name '[]' INTO l_table_name. "table body
      ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: get looplines of TableControl                              *
      CONCATENATE 'G_' p_tc_name '_LINES' INTO l_lines_name.
      ASSIGN (l_lines_name) TO <lines>.

*&SPWIZARD: get current line                                           *
      GET CURSOR LINE l_selline.
      IF sy-subrc <> 0.                   " append line to table
        l_selline = <tc>-lines + 1.
*&SPWIZARD: set top line                                               *
        IF l_selline > <lines>.
          <tc>-top_line = l_selline - <lines> + 1 .
        ELSE.
          <tc>-top_line = 1.
        ENDIF.
      ELSE.                               " insert line into table
        l_selline = <tc>-top_line + l_selline - 1.
        l_lastline = <tc>-top_line + <lines> - 1.
      ENDIF.
*&SPWIZARD: set new cursor line                                        *
      l_line = l_selline - <tc>-top_line + 1.

*&SPWIZARD: insert initial line                                        *
      INSERT INITIAL LINE INTO <table> INDEX l_selline.
      <tc>-lines = <tc>-lines + 1.
*&SPWIZARD: set cursor                                                 *
      SET CURSOR LINE l_line.

    ENDFORM.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
    FORM fcode_delete_row
                  USING    p_tc_name           TYPE dynfnam
                           p_table_name
                           p_mark_name   .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
      DATA l_table_name       LIKE feld-name.

      FIELD-SYMBOLS <tc>         TYPE cxtab_control.
      FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
      FIELD-SYMBOLS <wa>.
      FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

      ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
      CONCATENATE p_table_name '[]' INTO l_table_name. "table body
      ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: delete marked lines                                        *
      DESCRIBE TABLE <table> LINES <tc>-lines.

      LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
        ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

*        IF <mark_field> = 'X'.
*          DELETE t_ITMATR_AX INDEX syst-tabix.
*          IF sy-subrc = 0.
*            <tc>-lines = <tc>-lines - 1.
*          ENDIF.
*        ENDIF.

        IF <mark_field> = 'X'.
          DELETE <table> INDEX syst-tabix.
          IF sy-subrc = 0.
            <tc>-lines = <tc>-lines - 1.
          ENDIF.
        ENDIF.
      ENDLOOP.

    ENDFORM.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*      -->P_OK       ok code
*----------------------------------------------------------------------*
    FORM compute_scrolling_in_tc USING    p_tc_name
                                          p_ok.
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
      DATA l_tc_new_top_line     TYPE i.
      DATA l_tc_name             LIKE feld-name.
      DATA l_tc_lines_name       LIKE feld-name.
      DATA l_tc_field_name       LIKE feld-name.

      FIELD-SYMBOLS <tc>         TYPE cxtab_control.
      FIELD-SYMBOLS <lines>      TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

      ASSIGN (p_tc_name) TO <tc>.
*&SPWIZARD: get looplines of TableControl                              *
      CONCATENATE 'G_' p_tc_name '_LINES' INTO l_tc_lines_name.
      ASSIGN (l_tc_lines_name) TO <lines>.


*&SPWIZARD: is no line filled?                                         *
      IF <tc>-lines = 0.
*&SPWIZARD: yes, ...                                                   *
        l_tc_new_top_line = 1.
      ELSE.
*&SPWIZARD: no, ...                                                    *
        CALL FUNCTION 'SCROLLING_IN_TABLE'
          EXPORTING
            entry_act             = <tc>-top_line
            entry_from            = 1
            entry_to              = <tc>-lines
            last_page_full        = 'X'
            loops                 = <lines>
            ok_code               = p_ok
            overlapping           = 'X'
          IMPORTING
            entry_new             = l_tc_new_top_line
          EXCEPTIONS
*           NO_ENTRY_OR_PAGE_ACT  = 01
*           NO_ENTRY_TO           = 02
*           NO_OK_CODE_OR_PAGE_GO = 03
            OTHERS                = 0.
      ENDIF.

*&SPWIZARD: get actual tc and column                                   *
      GET CURSOR FIELD l_tc_field_name
                 AREA  l_tc_name.

      IF syst-subrc = 0.
        IF l_tc_name = p_tc_name.
*&SPWIZARD: et actual column                                           *
          SET CURSOR FIELD l_tc_field_name LINE 1.
        ENDIF.
      ENDIF.

*&SPWIZARD: set the new top line                                       *
      <tc>-top_line = l_tc_new_top_line.


    ENDFORM.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
    FORM fcode_tc_mark_lines USING p_tc_name
                                   p_table_name
                                   p_mark_name.
*&SPWIZARD: EGIN OF LOCAL DATA-----------------------------------------*
      DATA l_table_name       LIKE feld-name.

      FIELD-SYMBOLS <tc>         TYPE cxtab_control.
      FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
      FIELD-SYMBOLS <wa>.
      FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

      ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
      CONCATENATE p_table_name '[]' INTO l_table_name. "table body
      ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: mark all filled lines                                      *
      LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
        ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

        <mark_field> = 'X'.
      ENDLOOP.
    ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
    FORM fcode_tc_demark_lines USING p_tc_name
                                     p_table_name
                                     p_mark_name .
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
      DATA l_table_name       LIKE feld-name.

      FIELD-SYMBOLS <tc>         TYPE cxtab_control.
      FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
      FIELD-SYMBOLS <wa>.
      FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

      ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
      CONCATENATE p_table_name '[]' INTO l_table_name. "table body
      ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: demark all filled lines                                    *
      LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
        ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

        <mark_field> = space.
      ENDLOOP.
    ENDFORM.                                          "fcode_tc_mark_lines
*&---------------------------------------------------------------------*
*&      Form  F_EXEC_VALIDACOES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
    FORM f_exec_validacoes .


**    Variáveis Locais
      DATA: vl_vldty  TYPE zhms_de_vldty.
      DATA: tl_docum  TYPE TABLE OF zhms_es_docum,
            wl_docum  TYPE zhms_es_docum.
      CLEAR vl_vldty.

**    Executa funções de validação
      CALL FUNCTION 'ZHMS_FM_VALIDAR'
        EXPORTING
          vldcd  = wa_hvalid_vw-vldcd
          cabdoc = wa_cabdoc
        IMPORTING
          vldty  = vl_vldty.

**    Caso não tenha retornado erro executa chamada do fluxo
      IF vl_vldty NE 'E'.

**      Executa fluxo
        REFRESH: tl_docum.
        CLEAR wl_docum.
        wl_docum-dctyp = 'CHAVE'.
        wl_docum-dcnro = wa_cabdoc-chave.
        APPEND wl_docum TO tl_docum.

        CALL FUNCTION 'ZHMS_FM_TRACER'
          EXPORTING
            natdc                 = wa_cabdoc-natdc
            typed                 = wa_cabdoc-typed
            loctp                 = wa_cabdoc-loctp
*           just_ident            = 'X'
          TABLES
            docum                 = tl_docum
          EXCEPTIONS
            document_not_informed = 1
            scenario_not_found    = 2
            OTHERS                = 3.

      ENDIF.

    ENDFORM.                    " F_EXEC_VALIDACOES
*&---------------------------------------------------------------------*
*&      Form  HANDEL_HOTSPOT_CLICK_AUDIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW_ID  text
*      -->P_E_COLUMN_ID  text
*----------------------------------------------------------------------*
    FORM handel_hotspot_click_audit  USING    p_e_row_id
                                              p_e_column_id.
      DATA: t_dyfld TYPE STANDARD TABLE OF dynpread,
                l_dyfld TYPE dynpread.

*      break rsantos.
      CLEAR: t_alv_ped_aux, t_alv_comp_au.
* Comparações simples
      READ TABLE t_alv_xml INTO wa_alv_xml INDEX p_e_row_id.
      IF sy-subrc EQ 0.
        LOOP AT t_alv_comp INTO wa_alv_comp WHERE item = wa_alv_xml-item.
          APPEND wa_alv_comp TO t_alv_comp_au.
        ENDLOOP.
      ENDIF.

* Comparações de impostos
      READ TABLE t_alv_xml INTO wa_alv_xml INDEX p_e_row_id.
      IF sy-subrc EQ 0.
        LOOP AT t_alv_ped INTO wa_alv_ped WHERE item = wa_alv_xml-item.
          APPEND wa_alv_ped TO t_alv_ped_aux.
        ENDLOOP.
      ENDIF.
    ENDFORM.                    " HANDEL_HOTSPOT_CLICK_AUDIT
*&---------------------------------------------------------------------*
*&      Form  F_SELECT_VALUES_FLOW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
    FORM f_select_values_flow .


**    Icone Local
      DATA: vl_icon TYPE icon_d VALUE '@03@',
            lt_mapping TYPE STANDARD TABLE OF zhms_tb_mapdata,
            ls_mapping LIKE LINE OF lt_mapping.

**    Limpar as variáveis
      CLEAR: wa_flwdoc_ax, wa_flwdoc, wa_scenflox.
      REFRESH: t_flwdoc_ax, t_flwdoc, t_scenflox.

**    Mneumonicos do documento
      CLEAR wa_docmn.

**    Limpar tabela interna
      REFRESH t_docmn_rep.

**    Selecionar dados
      SELECT *
        INTO TABLE t_docmn_rep
        FROM zhms_tb_docmn
       WHERE chave EQ vg_chave.

      IF sy-subrc IS NOT INITIAL.
**    Selecionar dados
        SELECT *
          INTO TABLE t_docmn_rep
          FROM zhms_tb_docmn_hs
         WHERE chave EQ vg_chave.
      ENDIF.
*      PERFORM f_refresh_docmn.

**    Selecionar fluxo para este tipo de documento
      SELECT *
        INTO TABLE t_scenflo
        FROM zhms_tb_scen_flo
       WHERE natdc EQ wa_cabdoc-natdc
         AND typed EQ wa_cabdoc-typed
         AND loctp EQ wa_cabdoc-loctp
         AND scena EQ wa_cabdoc-scena.

**     Seleciona etapas do documento.
      IF NOT t_scenflo[] IS INITIAL.

        SELECT *
          INTO TABLE t_flwdoc
          FROM zhms_tb_flwdoc
          FOR ALL ENTRIES IN t_scenflo
        WHERE natdc EQ wa_cabdoc-natdc
          AND typed EQ wa_cabdoc-typed
          AND loctp EQ wa_cabdoc-loctp
          AND chave EQ wa_cabdoc-chave
          AND flowd EQ t_scenflo-flowd.

        SELECT *
          INTO TABLE t_scenflox
          FROM zhms_tx_scen_flo
           FOR ALL ENTRIES IN t_scenflo
          WHERE natdc	EQ t_scenflo-natdc
            AND typed	EQ t_scenflo-typed
            AND loctp EQ t_scenflo-loctp
            AND scena	EQ t_scenflo-scena
            AND flowd EQ t_scenflo-flowd
            AND spras	EQ sy-langu.

      ENDIF.

** Percorre dados encontrados movendo para estrutura de exibição
      LOOP AT t_scenflo INTO wa_scenflo.

        READ TABLE t_scenflox INTO wa_scenflox WITH KEY natdc = wa_scenflo-natdc
                                                        typed = wa_scenflo-typed
                                                        loctp = wa_scenflo-loctp
                                                        scena = wa_scenflo-scena
                                                        flowd = wa_scenflo-flowd.

        CLEAR wa_flwdoc_ax.

**      Move etapa do fluxo
        MOVE-CORRESPONDING wa_scenflox TO wa_flwdoc_ax.

**      Recupera status da etapa
        CLEAR wa_flwdoc.

**      Move dados do registro caso encontre
        READ TABLE t_flwdoc INTO wa_flwdoc WITH KEY flowd = wa_scenflox-flowd.
        IF sy-subrc IS INITIAL.
          MOVE-CORRESPONDING wa_flwdoc TO wa_flwdoc_ax.
        ENDIF.

**      Tratativa para Icones
        CASE wa_flwdoc-flwst.
          WHEN 'M'. "Concluído Manualmente
            wa_flwdoc_ax-icon = '@3J@'.
          WHEN 'A'. "Concluído Automaticamente
            wa_flwdoc_ax-icon = '@01@'.

          WHEN 'W'. "Aguardando
            wa_flwdoc_ax-icon = vl_icon.
            vl_icon = '@5F@'.
          WHEN 'E'. "Erro
            wa_flwdoc_ax-icon = '@1D@'.
            vl_icon = '@5F@'.
          WHEN 'C'. "Cancelada
            wa_flwdoc_ax-icon = '@02@'.
            vl_icon = '@5F@'.
          WHEN OTHERS. "Outros
            wa_flwdoc_ax-icon = vl_icon.
            vl_icon = '@5F@'.
        ENDCASE.

** Valores processados
** Documento
        CLEAR wa_docmn.
        READ TABLE t_docmn_rep INTO wa_docmn WITH KEY mneum = wa_scenflo-mndoc.
        IF sy-subrc IS INITIAL.
          wa_flwdoc_ax-nrdcg = wa_docmn-value.
        ENDIF.

*** Inicio Alteração David Rosin 10/02/2014 altera passagem de ano para numero do estorno
** Ano

*** Busca Mneumonico de estorno
        IF wa_scenflo-funct_estorno IS NOT INITIAL.

          SELECT * FROM zhms_tb_mapdata INTO TABLE lt_mapping WHERE codmp EQ wa_scenflo-codmp_estorno.

          READ TABLE lt_mapping INTO ls_mapping INDEX 1.

          IF sy-subrc IS INITIAL.
            CLEAR wa_docmn.
            READ TABLE t_docmn_rep INTO wa_docmn WITH KEY mneum = wa_scenflo-mndoc.

            IF sy-subrc IS INITIAL.
*              READ TABLE t_docmn_rep INTO wa_docmn WITH KEY mneum = wa_scenflo-mndoc.
*              IF sy-subrc IS INITIAL.
*                wa_flwdoc_ax-yrdcg = wa_docmn-value.
*              ENDIF.
              CLEAR wa_flwdoc_ax-yrdcg.
            ELSE.
              READ TABLE t_docmn_rep INTO wa_docmn WITH KEY mneum = ls_mapping-mneum.
              IF sy-subrc IS INITIAL.
                wa_flwdoc_ax-yrdcg = wa_docmn-value.
              ENDIF.
            ENDIF.


          ENDIF.
        ENDIF.
*** Fim Alteração David Rosin 10/02/2014 altera passagem de ano para numero do estorno

**      Insere na tabela
        APPEND wa_flwdoc_ax TO t_flwdoc_ax.
      ENDLOOP.

    ENDFORM.                    " F_SELECT_VALUES_FLOW

*&---------------------------------------------------------------------*
*&      Form  HANDEL_HOTSPOT_FLOW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    FORM handel_hotspot_flow  USING    p_e_row_id
                                       p_e_column_id.

**    Variáveis Locais
      DATA: tl_nodetable TYPE treev_ntab,
            tl_itemtable TYPE item_table_type.

      IF vg_chave IS INITIAL.
        READ TABLE t_0100 INTO wa_0100 INDEX p_e_row_id.
        IF sy-subrc EQ 0.
          vg_chave = wa_0100-chave.
          SELECT SINGLE *
            FROM zhms_tb_cabdoc
            INTO wa_cabdoc
            WHERE chave = vg_chave.
        ENDIF.
      ENDIF.

*      IF ob_vis_itens IS NOT INITIAL.
*        CALL METHOD ob_vis_itens->free.
*        CLEAR ob_vis_itens.
*      ENDIF.
      IF ob_cc_vis_itens IS NOT INITIAL.
        CALL METHOD ob_cc_vis_itens->free.
        CLEAR ob_cc_vis_itens.
      ENDIF.
      IF ob_flow IS NOT INITIAL.
        CLEAR ob_flow.
      ENDIF.

      IF ob_cc_vis_itens IS INITIAL.
***     Criando Objeto de Container do ALV
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

**    Objeto de TREE para FLOW
      IF NOT ob_cc_vis_itens IS INITIAL.
***   Setando valores do Header da TREE
        PERFORM f_build_hier_header_itens.

        CREATE OBJECT ob_flow
          EXPORTING
            parent                      = ob_cc_vis_itens
            node_selection_mode         = cl_gui_column_tree=>node_sel_mode_single
            item_selection              = 'X'
            hierarchy_column_name       = 'Etapas'
            hierarchy_header            = wa_hier_header
          EXCEPTIONS
            cntl_system_error           = 1
            create_error                = 2
            failed                      = 3
            illegal_node_selection_mode = 4
            illegal_column_name         = 5
            lifetime_error              = 6.
        IF sy-subrc <> 0.
          MESSAGE a000.
        ENDIF.

***   Carregando catálogo de campo (flow)
        PERFORM f_build_fieldcat_flow.

***   Registrando Eventos da Tree de Atribuição
        PERFORM f_reg_events_flow.

      ENDIF.

**    Limpar itens da tabela
      CALL METHOD ob_flow->delete_all_nodes
        EXCEPTIONS
          failed            = 1
          cntl_system_error = 2
          OTHERS            = 3.

**    Criar nós
      REFRESH: tl_nodetable, tl_itemtable.

***   Criando Hierarquia da TREE do XML
      PERFORM f_create_hier_itens_flow USING tl_nodetable tl_itemtable.

**    Adicionar os nós criados
      CALL METHOD ob_flow->add_nodes_and_items
        EXPORTING
          node_table                     = tl_nodetable
          item_table                     = tl_itemtable
          item_table_structure_name      = 'MTREEITM'
        EXCEPTIONS
          failed                         = 1
          cntl_system_error              = 3
          error_in_tables                = 4
          dp_error                       = 5
          table_structure_name_not_found = 6.
      IF sy-subrc <> 0.
        MESSAGE a000.
      ENDIF.

**    Expandir os nós
      CALL METHOD ob_flow->expand_root_nodes
        EXCEPTIONS
          failed              = 1
          illegal_level_count = 2
          cntl_system_error   = 3
          OTHERS              = 4.

**    Ajustar largura
      CALL METHOD ob_flow->hierarchy_header_adjust_width
        EXCEPTIONS
          OTHERS = 1.

      CALL METHOD cl_gui_cfw=>flush
        EXCEPTIONS
          cntl_system_error = 1
          cntl_error        = 2
          OTHERS            = 3.

      CLEAR vg_chave.

    ENDFORM.                    " HANDEL_HOTSPOT_FLOW
*&---------------------------------------------------------------------*
*&      Form  F_ESTORNO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_VL_INDEX  text
*----------------------------------------------------------------------*
    FORM f_estorno USING vl_index.


*** Declaração de Tabelas
      DATA: lt_mneum    TYPE STANDARD TABLE OF zhms_tb_docmn,
            lt_mneumx   TYPE STANDARD TABLE OF zhms_tb_docmn,
            lt_mapping  TYPE STANDARD TABLE OF zhms_tb_mapdata,
            lt_return   TYPE STANDARD TABLE OF bapiret2.

*** Declaração de WorkAreas
      DATA: ls_mapping  LIKE LINE OF lt_mapping,
            ls_return   LIKE LINE OF lt_return,
            ls_mneum    LIKE LINE OF lt_mneum,
            ls_headret  TYPE bapi2017_gm_head_ret,
            ls_scen_flo TYPE zhms_tb_scen_flo.

*** Declaração de Variaveis
      DATA: lv_docnum   TYPE mblnr,
            lv_year     TYPE mjahr,
            lv_index    TYPE sy-tabix,
            lv_answer   TYPE c,
            lv_chave    TYPE zhms_de_chave,
            lv_reason   TYPE stgrd,
            vl_seqnr    TYPE zhms_de_seqnr,
            lv_mneum    TYPE zhms_de_mneum.

*** Pop-up de confirmação do estorno
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar              = text-q01
          text_question         = text-q10
          text_button_1         = text-q03
          icon_button_1         = 'ICON_CHECKED'
          text_button_2         = text-q04
          icon_button_2         = 'ICON_INCOMPLETE'
          default_button        = '2'
          display_cancel_button = ' '
        IMPORTING
          answer                = lv_answer
        EXCEPTIONS
          text_not_found        = 1
          OTHERS                = 2.

      CHECK lv_answer EQ 1.

      IF sy-subrc IS INITIAL.

        READ TABLE t_flwdoc_ax INTO wa_flwdoc_ax INDEX vl_index.

        CLEAR: vg_codmp, vg_funct, lv_chave.
        SELECT SINGLE *
           FROM zhms_tb_scen_flo
          INTO ls_scen_flo
          WHERE natdc EQ wa_flwdoc_ax-natdc
            AND typed EQ wa_flwdoc_ax-typed
            AND flowd EQ wa_flwdoc_ax-flowd
            AND scena EQ wa_cabdoc-scena.

*and SCENA eq wa_cabdoc-SCENA.

        IF sy-subrc IS INITIAL.

          READ TABLE t_chave INTO lv_chave INDEX 1.

          CHECK NOT lv_chave IS INITIAL.

*** Busca todos mneumonicos por chave
          SELECT * FROM zhms_tb_docmn INTO TABLE lt_mneum WHERE chave EQ lv_chave.

          IF NOT sy-subrc IS INITIAL.
            SELECT * FROM zhms_tb_docmn_hs INTO TABLE lt_mneum WHERE chave EQ lv_chave.
          ENDIF.

*** Busca mapeamento para esse cenario
          SELECT * FROM zhms_tb_mapdata INTO TABLE lt_mapping WHERE codmp EQ ls_scen_flo-codmp_estorno.

          IF NOT lt_mapping[] IS INITIAL.
            CLEAR lv_index.

*** Busca numero da miro ou migo
            SORT lt_mneum DESCENDING BY seqnr.
            READ TABLE lt_mneum INTO ls_mneum WITH KEY mneum = ls_scen_flo-mndoc.

            IF sy-subrc IS INITIAL.
*          break homine.
              CASE ls_scen_flo-funct_estorno.
                WHEN 'BAPI_GOODSMVT_CANCEL'.

*** Verifica Autorização usuario
                  CALL FUNCTION 'ZHMS_FM_SECURITY'
                    EXPORTING
                      value         = 'ESTORNO_MIGO'
                    EXCEPTIONS
                      authorization = 1
                      OTHERS        = 2.

                  IF sy-subrc <> 0.
                    MESSAGE e000(zhms_security). "
                  ENDIF.

                  MOVE: ls_mneum-value TO lv_docnum,
                        sy-datum(4) TO lv_year.

*** Executa extorno da MIGO
                  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
                    EXPORTING
                      materialdocument = lv_docnum
                      matdocumentyear  = lv_year
                    IMPORTING
                      goodsmvt_headret = ls_headret
                    TABLES
                      return           = lt_return.

*** Verifica caso ERRO
                  READ TABLE lt_return INTO ls_return WITH KEY type = 'E'.

                  IF sy-subrc IS INITIAL.
*** Grava log de erro
                    PERFORM f_grava_log TABLES lt_return USING:
                                               ls_return
                                               wa_flwdoc_ax-natdc
                                               wa_flwdoc_ax-typed
                                               ls_scen_flo-loctp
                                               lv_chave.

                    MESSAGE ls_return-message TYPE 'I'.
                    EXIT.

                  ELSE.

*** Caso sucesso grava operação
                    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                      EXPORTING
                        wait = 'X'.

*** Modifica Tabela ZHMS_TB_DOCMN
                    IF NOT ls_headret IS INITIAL.

                      DELETE FROM zhms_tb_docmn WHERE chave EQ lv_chave
                                             AND mneum EQ ls_scen_flo-mndoc.

*** Commit banco de dados
                      IF sy-subrc IS INITIAL.
                        COMMIT WORK.
                      ELSE.
                        ROLLBACK WORK.
                      ENDIF.

*** Insere Numero do documento de estorno
                      REFRESH lt_mneumx[].
                      CLEAR ls_mneum.

                      LOOP AT lt_mapping INTO ls_mapping.
                        MOVE sy-tabix TO lv_index.
                        MOVE: lv_chave         TO ls_mneum-chave,
                              ls_mapping-mneum TO ls_mneum-mneum.

                        CASE lv_index.
                          WHEN 1.
                            MOVE ls_headret-mat_doc TO ls_mneum-value.
                          WHEN 2.
                            MOVE ls_headret-doc_year TO ls_mneum-value.
                        ENDCASE.

*** Busca ultimo numero de chave
                        SELECT MAX( seqnr )
                          INTO vl_seqnr
                          FROM zhms_tb_docmn
                         WHERE chave EQ lv_chave.

                        SELECT SINGLE mneum
                                  FROM zhms_tb_docmn
                                  INTO lv_mneum
                                  WHERE chave EQ lv_chave
                                  AND mneum EQ ls_mapping-mneum .

                        IF NOT sy-subrc IS INITIAL.
                          ADD 1 TO vl_seqnr.
                          MOVE vl_seqnr TO ls_mneum-seqnr.

                          CONDENSE ls_mneum-seqnr NO-GAPS.
                          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
                            EXPORTING
                              input  = ls_mneum-seqnr
                            IMPORTING
                              output = ls_mneum-seqnr.

                          INSERT zhms_tb_docmn  FROM ls_mneum.

                        ENDIF.

*** Commit Banco de dados
                        IF sy-subrc IS INITIAL.
                          COMMIT WORK.
                        ELSE.
                          ROLLBACK WORK.
                        ENDIF.

                      ENDLOOP.

**** Muda Status da etapa
                      MOVE: wa_flwdoc_ax-natdc TO wa_flwdoc-natdc,
                            wa_flwdoc_ax-typed TO wa_flwdoc-typed,
                            lv_chave           TO wa_flwdoc-chave,
                            wa_flwdoc_ax-flowd TO wa_flwdoc-flowd,
                            sy-datum           TO wa_flwdoc-dtreg,
                            sy-uzeit           TO wa_flwdoc-hrreg,
                            sy-uname           TO wa_flwdoc-uname,
                            'W' TO wa_flwdoc-flwst.
                      MODIFY zhms_tb_flwdoc FROM wa_flwdoc.
                      CLEAR wa_flwdoc.

                      IF sy-subrc IS INITIAL.
                        COMMIT WORK.
                      ELSE.
                        ROLLBACK WORK.
                      ENDIF.

*** Altera status do documento
                      SELECT SINGLE *
                        FROM zhms_tb_docst
                        INTO wa_docstx
                        WHERE natdc EQ wa_flwdoc_ax-natdc
                          AND typed EQ wa_flwdoc_ax-typed
                          AND chave EQ lv_chave.

                      IF sy-subrc IS INITIAL.
                        UPDATE zhms_tb_docst
                        SET sthms = '2'
                        WHERE natdc EQ wa_flwdoc_ax-natdc
                           AND typed EQ wa_flwdoc_ax-typed
                           AND chave EQ lv_chave.

                        IF sy-subrc IS INITIAL.
                          COMMIT WORK.
                        ELSE.
                          ROLLBACK WORK.
                        ENDIF.
                      ENDIF.

*** Grava Log de sucesso para o estorno
                      PERFORM f_change_return TABLES lt_return USING lv_docnum.
                      PERFORM f_grava_log TABLES lt_return USING: ls_return wa_flwdoc_ax-natdc
                            wa_flwdoc_ax-typed ls_scen_flo-loctp lv_chave.

                    ENDIF.
                  ENDIF.

                WHEN 'BAPI_INCOMINGINVOICE_CANCEL'.

*** Verifica Autorização usuario
                  CALL FUNCTION 'ZHMS_FM_SECURITY'
                    EXPORTING
                      value         = 'ESTORNO_MIRO'
                    EXCEPTIONS
                      authorization = 1
                      OTHERS        = 2.

                  IF sy-subrc <> 0.
                    MESSAGE e000(zhms_security).
                  ENDIF.

                  MOVE: ls_mneum-value TO lv_docnum,
                        sy-datum(4)    TO lv_year.

                  READ TABLE lt_mapping INTO ls_mapping WITH KEY tbfld =
    'REASONREVERSAL'.

                  IF sy-subrc IS INITIAL.
                    MOVE ls_mapping-vlfix TO lv_reason.
                  ENDIF.

                  CLEAR ls_headret.
                  CALL FUNCTION 'BAPI_INCOMINGINVOICE_CANCEL'
                    EXPORTING
                      invoicedocnumber          = lv_docnum
                      fiscalyear                = lv_year
                      reasonreversal            = lv_reason
                    IMPORTING
                      invoicedocnumber_reversal = ls_headret-mat_doc
                      fiscalyear_reversal       = ls_headret-doc_year
                    TABLES
                      return                    = lt_return.

*** Verifica caso ERRO
                  READ TABLE lt_return INTO ls_return WITH KEY type =
    'E'.

                  IF sy-subrc IS INITIAL.
*** Grava Log de Erro
                    PERFORM f_grava_log TABLES lt_return USING:
                                               ls_return
                                               wa_flwdoc_ax-natdc
                                               wa_flwdoc_ax-typed
                                               ls_scen_flo-loctp
                                               lv_chave.

                    MESSAGE ls_return-message TYPE 'I'.
                    EXIT.

                  ELSE.

*** Caso sucesso grava operação
                    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                      EXPORTING
                        wait = 'X'.

*** Modifica Tabela ZHMS_TB_DOCMN
                    IF NOT ls_headret IS INITIAL.

                      DELETE FROM zhms_tb_docmn WHERE chave EQ lv_chave
                                          AND mneum EQ ls_scen_flo-mndoc.

*** Commit banco de dados
                      IF sy-subrc IS INITIAL.
                        COMMIT WORK.
                      ELSE.
                        ROLLBACK WORK.
                      ENDIF.

*** Insere Numero do documento de estorno
                      REFRESH lt_mneumx[].
                      CLEAR ls_mneum.

                      LOOP AT lt_mapping INTO ls_mapping.
                        MOVE sy-tabix TO lv_index.

                        MOVE: lv_chave         TO ls_mneum-chave,
                              ls_mapping-mneum TO ls_mneum-mneum.

                        CASE lv_index.
                          WHEN 1.
*** Armazena numero do estorno
                            MOVE ls_headret-mat_doc TO ls_mneum-value.
                          WHEN 2.
*** Armazena ano do estorno
                            MOVE ls_headret-doc_year TO ls_mneum-value.
                          WHEN 3.
*** Armazena ano do estorno
                            MOVE ls_headret-mat_doc TO ls_mneum-value.

                          WHEN OTHERS.
                        ENDCASE.

*** Busca ultimo numero de chave
                        SELECT MAX( seqnr )
                          INTO vl_seqnr
                          FROM zhms_tb_docmn
                         WHERE chave EQ lv_chave.

                        SELECT SINGLE mneum
                                  FROM zhms_tb_docmn
                                  INTO lv_mneum
                                  WHERE chave EQ lv_chave
                                  AND mneum EQ ls_mapping-mneum .

                        IF NOT sy-subrc IS INITIAL.
                          ADD 1 TO vl_seqnr.
                          MOVE vl_seqnr TO ls_mneum-seqnr.

                          CONDENSE ls_mneum-seqnr NO-GAPS.
                          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
                            EXPORTING
                              input  = ls_mneum-seqnr
                            IMPORTING
                              output = ls_mneum-seqnr.

*                          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*                            EXPORTING
*                              input  = ls_mneum-seqnr
*                            IMPORTING
*                              output = ls_mneum-seqnr.


                          INSERT zhms_tb_docmn FROM ls_mneum.
                        ENDIF.

*** Commit Banco de dados
                        IF sy-subrc IS INITIAL.
                          COMMIT WORK.
                        ELSE.
                          ROLLBACK WORK.
                        ENDIF.

                      ENDLOOP.


*** Muda Status da etapa
                      MOVE: wa_flwdoc_ax-natdc TO wa_flwdoc-natdc,
                            wa_flwdoc_ax-typed TO wa_flwdoc-typed,
                            lv_chave           TO wa_flwdoc-chave,
                            wa_flwdoc_ax-flowd TO wa_flwdoc-flowd,
                            sy-datum           TO wa_flwdoc-dtreg,
                            sy-uzeit           TO wa_flwdoc-hrreg,
                            sy-uname           TO wa_flwdoc-uname,
                           'W' TO wa_flwdoc-flwst.
                      MODIFY zhms_tb_flwdoc FROM wa_flwdoc.
                      CLEAR wa_flwdoc.

                      IF sy-subrc IS INITIAL.
                        COMMIT WORK.
                      ELSE.
                        ROLLBACK WORK.
                      ENDIF.


*** Volta etapa 50
                      CLEAR vg_line.
                      DESCRIBE TABLE t_scenflo LINES vg_line.
                      READ TABLE t_scenflo INTO wa_scenflo INDEX vg_line.
                      CLEAR wa_flwdoc.
                      MOVE: wa_flwdoc_ax-natdc TO wa_flwdoc-natdc,
                            wa_flwdoc_ax-typed TO wa_flwdoc-typed,
                            lv_chave           TO wa_flwdoc-chave,
                            wa_scenflo-flowd   TO wa_flwdoc-flowd,
                            sy-datum           TO wa_flwdoc-dtreg,
                            sy-uzeit           TO wa_flwdoc-hrreg,
                            sy-uname           TO wa_flwdoc-uname,
                            'W' TO wa_flwdoc-flwst.
                      MODIFY zhms_tb_flwdoc FROM wa_flwdoc.
                      CLEAR wa_flwdoc.

                      IF sy-subrc IS INITIAL.
                        COMMIT WORK.
                      ELSE.
                        ROLLBACK WORK.
                      ENDIF.

*** Altera status do documento
                      SELECT SINGLE *
                        FROM zhms_tb_docst
                        INTO wa_docstx
                        WHERE natdc EQ wa_flwdoc_ax-natdc
                          AND typed EQ wa_flwdoc_ax-typed
                          AND chave EQ lv_chave.

                      IF sy-subrc IS INITIAL.
                        UPDATE zhms_tb_docst
                        SET sthms = '2'
                        WHERE natdc EQ wa_flwdoc_ax-natdc
                           AND typed EQ wa_flwdoc_ax-typed
                           AND chave EQ lv_chave.

                        IF sy-subrc IS INITIAL.
                          COMMIT WORK.
                        ELSE.
                          ROLLBACK WORK.
                        ENDIF.
                      ENDIF.

*** Grava Log de sucesso para o estorno
                      PERFORM f_change_return TABLES lt_return USING lv_docnum.
                      PERFORM f_grava_log TABLES lt_return USING: ls_return wa_flwdoc_ax-natdc
                            wa_flwdoc_ax-typed ls_scen_flo-loctp lv_chave.

                    ENDIF.
                  ENDIF.

                WHEN 'ZHMS_ESTORNO_J1B1N'.

*              break homine.
                  CALL FUNCTION 'ZHMS_ESTORNO_J1B1N'
                    EXPORTING
                      chave     = lv_chave
                    TABLES
                      lt_return = lt_return.


*** Verifica caso ERRO
                  READ TABLE lt_return INTO ls_return WITH KEY type = 'E'.

                  IF  sy-subrc IS INITIAL.

*** Grava Log de Erro
                    PERFORM f_grava_log TABLES lt_return USING:
                                               ls_return
                                               wa_flwdoc_ax-natdc
                                               wa_flwdoc_ax-typed
                                               ls_scen_flo-loctp
                                               lv_chave.


                  ELSE.

*** verifica documento criado
                    READ TABLE lt_return INTO ls_return WITH KEY type = 'S'
                                                                id   = '8B'
                                                           number   = '191'.

*** Insere Numero do documento de estorno
*                REFRESH lt_mneumx[].
                    CLEAR ls_mneum.

                    DELETE FROM zhms_tb_docmn WHERE chave EQ lv_chave
                                                AND mneum EQ 'MATDOC'.

                    IF sy-subrc IS INITIAL.
                      COMMIT WORK.
                    ENDIF.

                    MOVE: lv_chave         TO ls_mneum-chave,
                          'MATDOCEST'      TO ls_mneum-mneum.

*** Armazena ano do estorno
                    MOVE ls_return-message_v2 TO ls_mneum-value.


*** Busca ultimo numero de chave
                    SELECT MAX( seqnr )
                      INTO vl_seqnr
                      FROM zhms_tb_docmn
                     WHERE chave EQ lv_chave.

                    IF sy-subrc IS INITIAL.
                      ADD 1 TO vl_seqnr.
                      MOVE vl_seqnr TO ls_mneum-seqnr.

                      CONDENSE ls_mneum-seqnr NO-GAPS.
                      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                        EXPORTING
                          input  = ls_mneum-seqnr
                        IMPORTING
                          output = ls_mneum-seqnr.


                      INSERT zhms_tb_docmn FROM ls_mneum.

*** Commit Banco de dados
                      IF sy-subrc IS INITIAL.
                        COMMIT WORK.
                      ELSE.
                        ROLLBACK WORK.
                      ENDIF.

                    ENDIF.

*** Muda Status da etapa
                    MOVE: wa_flwdoc_ax-natdc TO wa_flwdoc-natdc,
                          wa_flwdoc_ax-typed TO wa_flwdoc-typed,
                          lv_chave           TO wa_flwdoc-chave,
                          wa_flwdoc_ax-flowd TO wa_flwdoc-flowd,
                          sy-datum           TO wa_flwdoc-dtreg,
                          sy-uzeit           TO wa_flwdoc-hrreg,
                          sy-uname           TO wa_flwdoc-uname,
                         'W' TO wa_flwdoc-flwst.
                    MODIFY zhms_tb_flwdoc FROM wa_flwdoc.
                    CLEAR wa_flwdoc.

                    IF sy-subrc IS INITIAL.
                      COMMIT WORK.
                    ELSE.
                      ROLLBACK WORK.
                    ENDIF.

*** Altera status do documento
                    SELECT SINGLE * FROM zhms_tb_docst INTO wa_docstx
                    WHERE natdc EQ wa_flwdoc_ax-natdc
                    AND typed EQ wa_flwdoc_ax-typed
                    AND chave EQ lv_chave.

                    IF sy-subrc IS INITIAL.
                      UPDATE zhms_tb_docst
                      SET sthms = '2'
                      WHERE natdc EQ wa_flwdoc_ax-natdc
                         AND typed EQ wa_flwdoc_ax-typed
                         AND chave EQ lv_chave.

                      IF sy-subrc IS INITIAL.
                        COMMIT WORK.
                      ELSE.
                        ROLLBACK WORK.
                      ENDIF.
                    ENDIF.

*** Grava Log de sucesso para o estorno
                    PERFORM f_change_return TABLES lt_return USING lv_docnum.
                    PERFORM f_grava_log TABLES lt_return USING: ls_return
                                                         wa_flwdoc_ax-natdc
                                                         wa_flwdoc_ax-typed
                                                         ls_scen_flo-loctp
                                                         lv_chave.
                  ENDIF.
              ENDCASE.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

    ENDFORM.                    " F_ESTORNO

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_RETURN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_RETURN  text
*      -->P_LV_DOCNUM  text
*----------------------------------------------------------------------*
    FORM f_change_return  TABLES   p_lt_return USING la_docnum.

      DATA: ls_return TYPE bapiret2.

      REFRESH p_lt_return.
      MOVE: 'S' TO ls_return-type.
      CONCATENATE 'Nº' la_docnum 'foi estornado' INTO ls_return-message_v1 SEPARATED BY space.
      APPEND ls_return TO p_lt_return.
      CLEAR ls_return.

    ENDFORM.                    " F_CHANGE_RETURN

*&---------------------------------------------------------------------*
*&      Form  F_GRAVA_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
    FORM f_grava_log TABLES lt_return USING: ls_return TYPE bapiret2
                                             la_natdc
                                             la_typed
                                             la_loctp
                                             lv_chave.

      DATA: lt_logdoc TYPE STANDARD TABLE OF zhms_tb_logdoc,
            ls_logdoc LIKE LINE OF lt_logdoc.

      LOOP AT lt_return INTO ls_return.
        MOVE: la_natdc             TO ls_logdoc-natdc,
              la_typed             TO ls_logdoc-typed,
              la_loctp             TO ls_logdoc-loctp,
              lv_chave             TO ls_logdoc-chave,
              1                    TO ls_logdoc-seqnr,
              sy-datum             TO ls_logdoc-dtreg,
              sy-uzeit             TO ls_logdoc-hrreg,
              sy-uname             TO ls_logdoc-uname,
              ls_return-id         TO ls_logdoc-logid,
              ls_return-type       TO ls_logdoc-logty,
              ls_return-number     TO ls_logdoc-logno,
              ls_return-message    TO ls_logdoc-logv1,
              ls_return-message_v1 TO ls_logdoc-logv1,
              ls_return-message_v2 TO ls_logdoc-logv2.
        APPEND ls_logdoc TO lt_logdoc.
        CLEAR ls_logdoc.

      ENDLOOP.

      MODIFY zhms_tb_logdoc FROM TABLE lt_logdoc.

      IF sy-subrc IS INITIAL.
        COMMIT WORK.
      ELSE.
        ROLLBACK WORK.
      ENDIF.

    ENDFORM.                    " F_GRAVA_LOG

*&---------------------------------------------------------------------*
*&      Form  F_GET_SELECTED_FLOW
*&---------------------------------------------------------------------*
*       Identificar o item selecionado
*----------------------------------------------------------------------*
    FORM f_get_selected_flow  CHANGING p_index.
**    Variaveis locas
      DATA: node TYPE tv_nodekey,
            item TYPE tv_itmname.

**    Identificar selecionado
      CALL METHOD ob_flow->get_selected_item
        IMPORTING
          node_key          = node
          item_name         = item
        EXCEPTIONS
          failed            = 1
          cntl_system_error = 2
          no_item_selection = 3
          OTHERS            = 4.

**    Tratamento de erros
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

**    Retornar Selecionado
      CONDENSE node NO-GAPS.
      MOVE node TO p_index.

    ENDFORM.                    " F_GET_SELECTED_FLOW

*&---------------------------------------------------------------------*
*&      Form  HANDEL_HOTSPOT_SHOWXML
*&---------------------------------------------------------------------*
    FORM handel_hotspot_showxml  USING    p_e_row_id
                                          p_e_column_id.

**    Variáveis locais
      DATA: vl_error TYPE flag.

*      IF NOT vg_chave_sel IS INITIAL.
*        IF vg_chave EQ vg_chave_sel.
*          vl_error = 'X'.
*        ELSE.
*          CLEAR vl_error.
*        ENDIF.
*      ENDIF.
*
*
*      CHECK vl_error IS INITIAL.
*      CHECK NOT vg_chave IS INITIAL.
*      vg_chave_sel = vg_chave.

      IF vg_chave IS INITIAL.
        READ TABLE t_0100 INTO wa_0100 INDEX p_e_row_id.
        IF sy-subrc EQ 0.
          vg_chave = wa_0100-chave.
          SELECT SINGLE *
            FROM zhms_tb_cabdoc
            INTO wa_cabdoc
            WHERE chave = vg_chave.
        ENDIF.
      ENDIF.

      IF ob_cc_vis_itens IS NOT INITIAL.
        CALL METHOD ob_cc_vis_itens->free.
        CLEAR ob_cc_vis_itens.
      ENDIF.
      IF ob_xml_docs IS NOT INITIAL.
        CLEAR ob_xml_docs.
      ENDIF.

***   Carregando Estrutura de Campos
      PERFORM f_build_fieldcat.

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

*      IF NOT ob_xml_docs IS INITIAL.
*
*        CALL METHOD ob_xml_docs->free
*          EXCEPTIONS
*            cntl_error        = 1
*            cntl_system_error = 2
*            OTHERS            = 3.
*
*      ENDIF.

*      IF ob_xml_docs IS INITIAL.
***     Criando Objeto TREE para XML
      CREATE OBJECT ob_xml_docs
        EXPORTING
          parent                      = ob_cc_vis_itens
          node_selection_mode         = cl_gui_column_tree=>node_sel_mode_single
          item_selection              = 'X'
          no_html_header              = 'X'
          no_toolbar                  = ' '
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
*      ENDIF.

***   Setando valores do Header da TREE
      PERFORM f_build_hier_header.

      CLEAR wa_variant.
      MOVE  sy-repid TO wa_variant-report.

***   create emty tree-control
      REFRESH t_xmlview.

      CALL METHOD ob_xml_docs->set_table_for_first_display
        EXPORTING
          is_hierarchy_header = wa_hier_header
          is_variant          = wa_variant
        CHANGING
          it_outtab           = t_xmlview
          it_fieldcatalog     = t_fieldcat.

***   Criando Hierarquia da TREE do XML
      PERFORM f_create_hier.

      CALL METHOD cl_gui_cfw=>flush
        EXCEPTIONS
          cntl_system_error = 1
          cntl_error        = 2
          OTHERS            = 3.

      IF sy-subrc <> 0.
***     Erro Interno. Contatar Suporte.
        MESSAGE e000 WITH text-000.
      ENDIF.

      clear vg_chave.
    ENDFORM.                    " HANDEL_HOTSPOT_SHOWXML
*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
    FORM f_build_fieldcat .

      REFRESH t_fieldcat.
      CLEAR   wa_fieldcat.

***   Obtendo campos
      CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
        EXPORTING
          i_structure_name       = 'ZHMS_ES_XMLVIEW'
        CHANGING
          ct_fieldcat            = t_fieldcat
        EXCEPTIONS
          inconsistent_interface = 1
          program_error          = 2
          OTHERS                 = 3.

      IF sy-subrc EQ 0.
***     Alterando campos a serem exibidos
        LOOP AT t_fieldcat INTO wa_fieldcat.
          CASE wa_fieldcat-fieldname.
            WHEN 'CODLY' OR 'HIELY' OR 'XMLTG' OR 'DENOM' OR 'MNEUM' OR 'SEQNR'.
              wa_fieldcat-no_out = 'X'.
              wa_fieldcat-key    = ''.

            WHEN OTHERS.

          ENDCASE.

          MODIFY t_fieldcat FROM wa_fieldcat.
        ENDLOOP.
      ENDIF.
    ENDFORM.                    " F_BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  F_BUILD_HIER_HEADER
*&---------------------------------------------------------------------*
    FORM f_build_hier_header .
      CLEAR wa_hier_header.
      MOVE: 'Campo'  TO wa_hier_header-heading,
            text-h02 TO wa_hier_header-tooltip,
            100       TO wa_hier_header-width,
            ''       TO wa_hier_header-width_pix.
    ENDFORM.                    " F_BUILD_HIER_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_HIER
*&---------------------------------------------------------------------*
    FORM f_create_hier .

      DATA: l_last_key   TYPE lvc_nkey,
            l_parent_key TYPE lvc_nkey.

***   Construíndo tabela de saída
      PERFORM f_build_outtab.

***   Adicionando dados à TREE
      t_xmlview_aux[] = t_xmlview[].

***   Limpar Variáveis de chave
      CLEAR: l_last_key, l_parent_key.

      LOOP AT t_xmlview_aux INTO wa_xmlview.
***     Adicionando nós na árvore
        PERFORM f_add_no    USING wa_xmlview wa_xmlview-nodep
                         CHANGING l_last_key.
      ENDLOOP.

***   Atualizando valores no Objeto TREE criado
      CALL METHOD ob_xml_docs->frontend_update.

    ENDFORM.                    " F_CREATE_HIER

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_OUTTAB
*&---------------------------------------------------------------------*
    FORM f_build_outtab .

      TYPES: BEGIN OF ty_path,
               line TYPE zhms_de_codly,
             END OF ty_path,

             BEGIN OF ty_cnodes,
               codly TYPE zhms_de_codly,
               nodek TYPE lvc_nkey,
               found TYPE c,
             END OF ty_cnodes.

      DATA: t_split      TYPE TABLE OF string,
            t_path       TYPE TABLE OF ty_path,
            t_cnodes     TYPE TABLE OF ty_cnodes,
            wa_path      TYPE ty_path,
            wa_cnodes    TYPE ty_cnodes,
            vl_split     TYPE string,
            vl_count     TYPE i,
            vl_idxsplit  TYPE sy-tabix,
            vl_seqnr     TYPE zhms_de_seqnr,
            vl_path      TYPE string,
            vl_seqnr_new TYPE zhms_de_seqnr.

***   Lendo dados do documento
      PERFORM f_sel_xml_doc.

      LOOP AT t_evv_layt INTO wa_evv_layt.
        REPLACE 'NFEPROC/' WITH '' INTO wa_evv_layt-field.
        CONDENSE wa_evv_layt-field NO-GAPS.
        MODIFY t_evv_layt FROM wa_evv_layt INDEX sy-tabix.
      ENDLOOP.

      CLEAR vl_seqnr.

***   Loop nos dados encontrados para montar dados a serem exibidos
      LOOP AT t_repdoc INTO wa_repdoc.
        ADD 1 TO vl_count.

        CLEAR: wa_xmlview.
***     Dados Diretos
        wa_xmlview-xmltg = wa_repdoc-field.
        REPLACE 'NFEPROC/' WITH '' INTO wa_repdoc-field.
        CONDENSE wa_repdoc-field NO-GAPS.
        wa_xmlview-value = wa_repdoc-value.

***     Denominação
        CLEAR wa_evv_layt.
        READ TABLE t_evv_layt INTO wa_evv_layt WITH KEY field = wa_repdoc-field.

        IF sy-subrc IS INITIAL.
          CLEAR wa_evv_laytx.
          READ TABLE t_evv_laytx INTO wa_evv_laytx WITH KEY codly = wa_evv_layt-codly.

          IF sy-subrc EQ 0.
            wa_xmlview-denom = wa_evv_laytx-denof.
          ELSE.
*            BREAK-POINT.
          ENDIF.
        ELSE.
*          BREAK-POINT.
        ENDIF.

        MOVE vl_count TO wa_xmlview-nodek.

***     Split de TAG: Identificar Tag Meneumônico e Tags Pais.
        SPLIT wa_repdoc-field AT '/' INTO TABLE t_split.

***     Identifica quantidade de registros em SPLIT
        DESCRIBE TABLE t_split LINES vl_idxsplit.

        CLEAR vl_split.
        READ TABLE t_split INTO vl_split INDEX vl_idxsplit.

        IF sy-subrc EQ 0.
          wa_xmlview-mneum = vl_split.
          wa_xmlview-codly = vl_split.
        ENDIF.

***     Identifica Tag Pai.
        vl_idxsplit = vl_idxsplit - 1.

        IF vl_idxsplit GT 0.
          CLEAR vl_split.
          READ TABLE t_split INTO vl_split INDEX vl_idxsplit.

          IF sy-subrc EQ 0.
            wa_xmlview-hiely = vl_split.
          ENDIF.
        ENDIF.

***     Indice de Tag
        vl_seqnr = vl_seqnr + 10.
        wa_xmlview-seqnr = vl_seqnr.

        APPEND wa_xmlview TO t_xmlview.
      ENDLOOP.

      LOOP AT t_xmlview INTO wa_xmlview.
***     Identifica os pais possíveis
***     Explodir Tags
        SPLIT wa_xmlview-xmltg AT '/' INTO TABLE t_split.

***     Monta estrutura atual
        LOOP AT t_split INTO vl_split.
          CLEAR wa_path.
          wa_path-line = vl_split.
          APPEND wa_path TO t_path.
        ENDLOOP.

***     Adiciona Item Atual à lista de nós possíveis
        CLEAR wa_cnodes.
        wa_cnodes-codly = wa_xmlview-codly.
        wa_cnodes-nodek = wa_xmlview-nodek.
        APPEND wa_cnodes TO t_cnodes.

***     Limpa nós possíveis apenas com chaves conhecidas
***     Caso o pai encontrado não esteja presente na lista a Integridade do XML está comprometida
***     Para estes casos verificar Ordenação da tabela interna: t_xmlview ou do documento no Repositório
        LOOP AT t_cnodes INTO wa_cnodes.
          CLEAR: wa_cnodes-found,
                 wa_path.

          READ TABLE t_path INTO wa_path WITH KEY line = wa_cnodes-codly.

          IF sy-subrc IS INITIAL.
            wa_cnodes-found = 'X'.
            MODIFY t_cnodes FROM wa_cnodes.
          ENDIF.
        ENDLOOP.

        DELETE t_cnodes WHERE found IS INITIAL.

***     Identifica penúltimo nó (pai)
        CLEAR vl_idxsplit.
        DESCRIBE TABLE t_path LINES vl_idxsplit.

        vl_idxsplit = vl_idxsplit - 1.

        CHECK vl_idxsplit GT 0.

        CLEAR wa_path.
        READ TABLE t_path INTO wa_path INDEX vl_idxsplit.

        IF sy-subrc EQ 0.
***       Retona código do Pai
          CLEAR wa_cnodes.
          READ TABLE t_cnodes INTO wa_cnodes WITH KEY codly = wa_path-line.

          IF sy-subrc EQ 0.
            wa_xmlview-nodep = wa_cnodes-nodek.
***         Modifica tabela de layout
            MODIFY t_xmlview FROM wa_xmlview.
          ENDIF.
        ENDIF.
      ENDLOOP.

***   Remove Tags não identificadas (TODO: RETIRAR)
      DELETE t_xmlview WHERE nodep IS INITIAL
                         AND nodek NE '000000000001'
                         AND seqnr NE 10.
      READ TABLE t_xmlview INTO wa_xmlview INDEX 1.
      wa_xmlview-denom = vg_typed.
      MODIFY t_xmlview FROM wa_xmlview INDEX 1.
    ENDFORM.                    " F_BUILD_OUTTAB

*&---------------------------------------------------------------------*
*&      Form  F_ADD_NO
*&---------------------------------------------------------------------*
    FORM f_add_no  USING  p_wa_xmlview TYPE zhms_es_xmlview
                          p_relat_key
                CHANGING  p_node_key TYPE lvc_nkey.


***   Variáveis locais para controle de exibição da Árvore
      DATA: lt_item_layout TYPE lvc_t_layi,
            ls_item_layout TYPE lvc_s_layi,
            l_node_text    TYPE lvc_value.

***   Texto para exibição
      l_node_text =  p_wa_xmlview-denom.

***   Layout da Árvore
      ls_item_layout-fieldname = ob_xml_docs->c_hierarchy_column_name.
      APPEND ls_item_layout TO lt_item_layout.

***   Chamada do método que insere linhas na árvore
      CALL METHOD ob_xml_docs->add_node
        EXPORTING
          i_relat_node_key = p_relat_key
          i_relationship   = cl_gui_column_tree=>relat_last_child
          is_outtab_line   = p_wa_xmlview
          i_node_text      = l_node_text
          it_item_layout   = lt_item_layout
        IMPORTING
          e_new_node_key   = p_node_key.

    ENDFORM.                    " F_ADD_NO

*&---------------------------------------------------------------------*
*&      Form  F_SEL_XML_DOC
*&---------------------------------------------------------------------*
    FORM f_sel_xml_doc .

      DATA: v_versao TYPE zhms_tb_ev_vrs-versn.

      REFRESH: t_repdoc,
               t_evv_layt,
               t_evv_laytx.

      CLEAR: v_versao.

*** Seleção da versão
      SELECT SINGLE versn
        INTO v_versao
           FROM zhms_tb_ev_vrs
        WHERE
          natdc = wa_cabdoc-natdc AND
          typed = wa_cabdoc-typed AND
          event IN ('01','1')     AND
          ativo = 'X'.

***   Seleção da nota no repositório
      SELECT *
             FROM zhms_tb_repdoc
             INTO TABLE t_repdoc
             WHERE chave EQ vg_chave.

      IF sy-subrc EQ 0.
*        SORT t_repdoc BY chave.
***     Seleção do layout de documento da nota
*        SELECT *
*               FROM zhms_tb_evv_layt
*               INTO TABLE t_evv_layt
*               WHERE natdc EQ  '02'  AND "
*                     typed EQ  'NFE' AND "
*                     loctp EQ  ''    AND "
*                     event EQ  '1'  AND "
*                     versn EQ  '2.0' .   "

        SELECT *
             FROM zhms_tb_evv_layt
             INTO TABLE t_evv_layt
             WHERE natdc = wa_cabdoc-natdc AND
                   typed = wa_cabdoc-typed AND
                   loctp EQ  wa_cabdoc-loctp  AND
                   event IN ('01','1')     AND
                   versn EQ  v_versao.

        IF sy-subrc EQ 0.
*          SORT t_evv_layt BY natdc typed loctp event versn.

***       Busca textos do layout
          SELECT *
                 FROM zhms_tx_evv_layt
                 INTO TABLE t_evv_laytx
                 FOR ALL ENTRIES IN t_evv_layt
                 WHERE natdc EQ t_evv_layt-natdc     AND
                       typed EQ t_evv_layt-typed     AND
                       loctp EQ t_evv_layt-loctp     AND
                       event EQ t_evv_layt-event     AND
                       versn EQ t_evv_layt-versn     AND
                       codly EQ t_evv_layt-codly     AND
                       spras EQ sy-langu.

          IF sy-subrc EQ 0.
*            SORT t_evv_laytx BY natdc typed loctp event versn codly.
          ENDIF.
        ENDIF.
      ELSE.
***     TO DO...
      ENDIF.
    ENDFORM.                    " F_SEL_XML_DOC
