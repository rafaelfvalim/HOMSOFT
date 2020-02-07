*----------------------------------------------------------------------*
*                      H  o  m  S  o  f  t                             *
*          Gestão Eletrônica de Documentos e Processos                 *
*----------------------------------------------------------------------*
* Descrição: Monitor Central de Gerenciamento de Documentos            *
*            Sub-Rotinas (Validações)                                  *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*   Form  F_EXEC_VALIDACOES
*----------------------------------------------------------------------*
*   Re-executa regras de validação no documento
*----------------------------------------------------------------------*
    FORM f_exec_validacoes.
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



*----------------------------------------------------------------------*
*   Form  F_BUILD_FIELDCAT_GRID
*----------------------------------------------------------------------*
*   Carregando catálogo de campo (HVALID)
*----------------------------------------------------------------------*
    FORM f_build_fieldcat_hvalid.
      REFRESH t_hvalid_fldc.
      CLEAR:  t_hvalid_fldc, wa_hvalid_fldc.

***   Obtendo catálogo de campos
      CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
        EXPORTING
          i_structure_name = 'ZHMS_ES_HVALID'
        CHANGING
          ct_fieldcat      = t_hvalid_fldc.

      IF sy-subrc EQ 0.
        LOOP AT t_hvalid_fldc INTO wa_hvalid_fldc.
          CASE wa_hvalid_fldc-fieldname.
            WHEN 'ICON'.
              wa_fieldcat-no_out = 'X'.
              wa_fieldcat-key    = ''.
            WHEN OTHERS.
          ENDCASE.

          MODIFY t_hvalid_fldc FROM wa_hvalid_fldc.
        ENDLOOP.
        DELETE t_hvalid_fldc INDEX 1.

      ENDIF.
    ENDFORM.                    " F_BUILD_FIELDCAT_GRID


*&---------------------------------------------------------------------*
*&      Form  f_select_values_hvalid
*&---------------------------------------------------------------------*
*       Carregando a tabela de histórico
*----------------------------------------------------------------------*
    FORM f_select_values_hvalid.
**     Limpar tabelas
      REFRESH: t_hvalid_aux, t_hvalid.

      SELECT *
        FROM zhms_tb_hvalid
        INTO TABLE t_hvalid
       WHERE natdc EQ vg_natdc
         AND typed EQ vg_typed
         AND loctp EQ wa_cabdoc-loctp
         AND chave EQ vg_chave.

**    Percorrer registros encontrados
      LOOP AT t_hvalid INTO wa_hvalid.
*       Mover valores comuns
        MOVE-CORRESPONDING wa_hvalid TO wa_hvalid_aux.

*       Tratamento de Icones
        CASE wa_hvalid-vldty.
          WHEN 'E'.
            wa_hvalid_aux-icon = '@0A@'.
          WHEN 'W'.
            wa_hvalid_aux-icon = '@09@'.
          WHEN 'I'.
            wa_hvalid_aux-icon = '@08@'.
          WHEN 'S'.
            wa_hvalid_aux-icon = '@01@'.
        ENDCASE.

*	      Dados do Usuário que processou
        CALL FUNCTION 'BAPI_USER_GET_DETAIL'
          EXPORTING
            username = wa_hvalid-uname
          IMPORTING
            address  = wa_vld_usrad
          TABLES
            return   = t_bapireturn.

        MOVE wa_vld_usrad-fullname TO wa_hvalid_aux-utext.

*       Insere registro para exibição
        APPEND wa_hvalid_aux TO t_hvalid_aux.
      ENDLOOP.


    ENDFORM.                    "f_select_values_hvalid

*----------------------------------------------------------------------*
*   Form  f_create_hier_atr
*----------------------------------------------------------------------*
*   Criando Hierarquia da TREE do XML
*----------------------------------------------------------------------*
    FORM f_create_hier_itens_vld.
      DATA: vl_last_key   TYPE lvc_nkey,
            vl_text       TYPE string,
            vl_text2      TYPE string.

***   Construíndo tabela de saída
      PERFORM f_select_values_hvalid.

**   Percorre tabela de itens para montar
      REFRESH t_hvalid_aux2.
      t_hvalid_aux2[] = t_hvalid_aux[].
      LOOP AT t_hvalid_aux INTO wa_hvalid_aux.
**        Adiciona histórico à arvore
        PERFORM f_add_no_itens_vld    USING wa_hvalid_aux ''
                                            vl_text
                                   CHANGING vl_last_key.

      ENDLOOP.

***   Atualizando valores no Objeto TREE criado
      CALL METHOD ob_hvalid->frontend_update.

    ENDFORM.                    " f_create_hier_atr


*----------------------------------------------------------------------*
*   Form  f_add_no_itens_vld
*----------------------------------------------------------------------*
*   Adicionando nós na árvore
*----------------------------------------------------------------------*
    FORM f_add_no_itens_vld  USING  p_wa_hvalid_aux STRUCTURE zhms_es_hvalid
                                    p_relat_key
                                    p_text
                          CHANGING  p_node_key TYPE lvc_nkey.

***   Variáveis locais para controle de exibição da Árvore
      DATA: lt_item_layout TYPE lvc_t_layi,
            ls_item_layout TYPE lvc_s_layi,
            l_node_text    TYPE lvc_value,
            l_node_layout  TYPE lvc_s_layn.

***   Icone
      CLEAR l_node_layout.
      l_node_layout-n_image   = p_wa_hvalid_aux-icon.
      l_node_layout-exp_image = p_wa_hvalid_aux-icon.

***   Texto para exibição
      CLEAR l_node_text.
      l_node_text =  p_text.

***   Layout da Árvore
      CLEAR ls_item_layout.
      ls_item_layout-fieldname = ob_vis_itens->c_hierarchy_column_name.
      ls_item_layout-style     = cl_gui_column_tree=>style_default.
      APPEND ls_item_layout TO lt_item_layout.

***   Chamada do método que insere linhas na árvore
      CALL METHOD ob_hvalid->add_node
        EXPORTING
          i_relat_node_key = p_relat_key
          i_relationship   = cl_gui_column_tree=>relat_last_child
          is_outtab_line   = p_wa_hvalid_aux
          is_node_layout   = l_node_layout
          i_node_text      = l_node_text
          it_item_layout   = lt_item_layout
        IMPORTING
          e_new_node_key   = p_node_key.

    ENDFORM.                    " f_add_no_itens_vld
*&---------------------------------------------------------------------*
*&      Form  F_VLD_SHOWHIST
*&---------------------------------------------------------------------*
*       Carregar dados de validação
*----------------------------------------------------------------------*
    FORM f_vld_selregs .
      DATA: vl_index TYPE sy-tabix.

**     Limpar Variáveis
      CLEAR: wa_hrvalid, wa_hvalid, wa_hvalid_aux.
      REFRESH: t_hrvalid, t_hvalid, t_hvalid_aux.

**    Seleciona mais recente caso nenhum tenha sido selecionado
      IF wa_hvalid_vw IS INITIAL.
**   Construíndo tabela de saída
        PERFORM f_select_values_hvalid.
        DESCRIBE TABLE t_hvalid_aux LINES vl_index.
        READ TABLE t_hvalid_aux INTO wa_hvalid_vw INDEX vl_index.
      ENDIF.

**     Seleção dos campos
      SELECT *
        FROM zhms_tb_hrvalid
        INTO TABLE t_hrvalid
       WHERE natdc EQ vg_natdc
         AND typed EQ vg_typed
         AND loctp EQ wa_cabdoc-loctp
         AND chave EQ vg_chave
         AND dtreg EQ wa_hvalid_vw-dtreg
         AND hrreg EQ wa_hvalid_vw-hrreg.

**     Regras de Validações
      REFRESH t_regvld.
      SELECT *
        FROM zhms_tb_regvld
        INTO TABLE t_regvld
       WHERE vldcd EQ wa_hvalid_vw-vldcd.

**     Regras de Validações
      REFRESH t_regvldx.
      SELECT *
        FROM zhms_tx_regvld
        INTO TABLE t_regvldx
         FOR ALL ENTRIES IN t_regvld
       WHERE vldcd EQ t_regvld-vldcd
         AND regcd EQ t_regvld-regcd
         AND spras EQ sy-langu.

**      Percorrer dados encontrados
      REFRESH t_hrvalid_aux.
*      LOOP AT t_hrvalid  INTO wa_hrvalid WHERE atitm NE '00000'.
      LOOP AT t_regvld INTO wa_regvld.
**  Ler tabela de textos
        READ TABLE t_regvldx INTO wa_regvldx WITH KEY vldcd = wa_regvld-vldcd
                                                      regcd = wa_regvld-regcd.
**  Ler Resultado
        READ TABLE t_hrvalid INTO wa_hrvalid WITH KEY regcd = wa_regvld-regcd.

        CLEAR wa_hrvalid_aux.
**       Mover correspondentes para tabela de visualização
        MOVE-CORRESPONDING wa_hrvalid TO wa_hrvalid_aux.

*       Tratamento de Icones
        CASE wa_hrvalid-vldty.
          WHEN 'E'.
            wa_hrvalid_aux-icon = '@0A@'.
          WHEN 'W'.
            wa_hrvalid_aux-icon = '@09@'.
          WHEN 'I'.
            wa_hrvalid_aux-icon = '@08@'.
          WHEN 'S'.
            wa_hrvalid_aux-icon = '@01@'.
          WHEN OTHERS.
            wa_hrvalid_aux-icon = '@BZ@'.
        ENDCASE.

*       Busca texto na tabela de configuração
        wa_hrvalid_aux-ltext = wa_regvldx-ltext.

*       Move se é grupo
        wa_hrvalid_aux-isgrp = wa_regvld-isgrp.
        wa_hrvalid_aux-grpcd = wa_regvld-grpcd.
        wa_hrvalid_aux-regcd = wa_regvld-regcd.

        APPEND wa_hrvalid_aux TO t_hrvalid_aux.

      ENDLOOP.
*      ENDLOOP.

**      Percorrer dados encontrados
*      LOOP AT t_hrvalid INTO wa_hrvalid.
*        CLEAR wa_hrvalid_aux.
***       Mover correspondentes para tabela de visualização
*        MOVE-CORRESPONDING wa_hrvalid TO wa_hrvalid_aux.
*
**       Tratamento de Icones
*        CASE wa_hrvalid-vldty.
*          WHEN 'E'.
*            wa_hrvalid_aux-icon = '@0A@'.
*          WHEN 'W'.
*            wa_hrvalid_aux-icon = '@09@'.
*          WHEN 'I'.
*            wa_hrvalid_aux-icon = '@08@'.
*          WHEN 'S'.
*            wa_hrvalid_aux-icon = '@01@'.
*        ENDCASE.
*
**       Busca texto na tabela de configuração
*        CLEAR wa_regvldx.
*        READ TABLE t_regvldx INTO wa_regvldx WITH KEY regcd = wa_hrvalid-regcd.
*        IF sy-subrc IS INITIAL.
*          wa_hrvalid_aux-ltext = wa_regvldx-ltext.
*        ENDIF.
*
*        APPEND wa_hrvalid_aux TO t_hrvalid_aux.
*      ENDLOOP.
    ENDFORM.                    " F_VLD_SHOWHIST
*&---------------------------------------------------------------------*
*&      Form  F_SHOW_VLD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    FORM f_show_vld  USING    p_ls_outtab_vld STRUCTURE zhms_es_hvalid.

**    Identifica o item selecionado
      CLEAR wa_hvalid_vw.
      READ TABLE t_hvalid_aux2
             INTO wa_hvalid_vw
        WITH KEY dtreg = p_ls_outtab_vld-dtreg
                 hrreg = p_ls_outtab_vld-hrreg.

**    Recarrega a janela
      LEAVE TO SCREEN 400.

    ENDFORM.                    " F_SHOW_VLD


*&---------------------------------------------------------------------*
*&      Form  F_CREATE_HIER_ITENS_VALID
*&---------------------------------------------------------------------*
***   Criando Hierarquia da TREE do XML
*----------------------------------------------------------------------*
    FORM f_create_hier_itens_valid  TABLES nodes_exp
                                     USING node_table TYPE treev_ntab
                                           item_table TYPE item_table_type.

**   variaveis locais
      DATA: node          TYPE treev_node,
            item          TYPE mtreeitm,
            vl_code       TYPE tv_nodekey,
            vl_text       TYPE string.

*      Adiciona primeiro nó a arvore
      CLEAR node.
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
      vl_text = text-f03.
      CLEAR item.
      item-node_key = c_nodekey-root.
      item-item_name = 'Regras'.
      item-class = cl_gui_column_tree=>item_class_text.
      item-text = vl_text.
      APPEND item TO item_table.

**   Percorre tabela de itens para montar
      LOOP AT t_hrvalid_aux INTO wa_hrvalid_aux.

        vl_code = sy-tabix.

**      Verifica se é uma regra ou um grupo de Regras
        IF NOT wa_hrvalid_aux-isgrp IS INITIAL.
**        Caso Grupo, insere uma pasta
          APPEND vl_code TO nodes_exp.

          CLEAR node.
          node-node_key = vl_code.
          node-relatkey = c_nodekey-root.
          node-relatship = cl_gui_column_tree=>relat_first_child.
          node-isfolder = 'X'.
          node-exp_image = wa_hrvalid_aux-icon.
          node-n_image   = wa_hrvalid_aux-icon.
          APPEND node TO node_table.

**      Etapa / Descrição
          CLEAR: item, vl_text.
          vl_text = wa_hrvalid_aux-ltext.
          item-node_key = vl_code.
          item-item_name = 'Regras'.
          item-class = cl_gui_column_tree=>item_class_text.
          item-text = vl_text.
          item-ignoreimag = 'X'.
          APPEND item TO item_table.

        ELSE.

          CLEAR node.

**        Identifica Pais
          READ TABLE t_hrvalid_aux INTO wa_hrvalid_aux2 WITH KEY regcd = wa_hrvalid_aux-grpcd.
          IF sy-subrc IS INITIAL.
            node-relatkey = sy-tabix.
          ELSE.
            node-relatkey = c_nodekey-root.
          ENDIF.

          node-node_key = vl_code.
          node-relatship = cl_gui_column_tree=>relat_last_child.
          node-isfolder = ' '.
          node-exp_image = wa_hrvalid_aux-icon.
          node-n_image   = wa_hrvalid_aux-icon.
          APPEND node TO node_table.

**      Etapa / Descrição
          CLEAR: item, vl_text.
          vl_text = wa_hrvalid_aux-ltext.

          IF  wa_hrvalid_aux-vldty EQ 'E'.
            REPLACE '&1' WITH wa_hrvalid_aux-vldv1 INTO vl_text.
            REPLACE '&2' WITH wa_hrvalid_aux-vldv2 INTO vl_text.
            REPLACE '&3' WITH wa_hrvalid_aux-vldv3 INTO vl_text.
            REPLACE '&4' WITH wa_hrvalid_aux-vldv4 INTO vl_text.
          ELSE.
            TRANSLATE vl_text USING '/ '.
            TRANSLATE vl_text USING '& '.
            TRANSLATE vl_text USING '1 '.
            TRANSLATE vl_text USING '2 '.
            TRANSLATE vl_text USING '3 '.
            TRANSLATE vl_text USING '4 '.
          ENDIF.

**         Remover espaços de string
          CLEAR sy-subrc.
          WHILE sy-subrc IS INITIAL.
            REPLACE '  ' WITH ' ' INTO vl_text.
          ENDWHILE.


          item-node_key = vl_code.
          item-item_name = 'Regras'.
*** Inicio Alteração David Rosin 12/02/2014
          item-class = cl_gui_column_tree=>item_class_link. "cl_gui_column_tree=>item_class_text.
*** Inicio Alteração David Rosin 12/02/2014
          item-text = vl_text.
          item-ignoreimag = 'X'.
          APPEND item TO item_table.
        ENDIF.

      ENDLOOP.

    ENDFORM.                    " F_CREATE_HIER_ITENS_VALID
*&---------------------------------------------------------------------*
*&      Form  F_MONTA_NOS_ITEM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TL_NODESEXP  text
*      -->P_TL_NODETABLE_VLD  text
*      -->P_TL_ITEMTABLE_VLD  text
*----------------------------------------------------------------------*
    FORM f_monta_nos_item  TABLES nodes_exp
                            USING node_table TYPE treev_ntab
                                  item_table TYPE item_table_type.

      DATA: lt_vld_item TYPE STANDARD TABLE OF zhms_tb_vld_item,
            ls_vld_item LIKE LINE OF lt_vld_item.

      SELECT * FROM zhms_tb_vld_item INTO TABLE lt_vld_item WHERE natdc EQ wa_docst-natdc
                                                              AND typed EQ wa_docst-typed
                                                              AND chave EQ wa_docst-chave.

      IF sy-subrc IS INITIAL.
        LOOP AT lt_vld_item INTO ls_vld_item.

        ENDLOOP.
      ENDIF.

    ENDFORM.                    " F_MONTA_NOS_ITEM
