*&---------------------------------------------------------------------*
*&  Include           LZHMS_FG_MONITORF07
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*   Form  F_REG_EVENTS_ATR
*----------------------------------------------------------------------*
*   Registrando Eventos da tree Atribuição
*----------------------------------------------------------------------*
    form f_reg_events_atr.
* define the events which will be passed to the backend
      data: lt_events type cntl_simple_events,
            l_event   type cntl_simple_event.

* define the events which will be passed to the backend
      l_event-eventid = cl_gui_column_tree=>eventid_item_double_click.
      append l_event to lt_events.

      call method ob_atr_itens->set_registered_events
        exporting
          events                    = lt_events
        exceptions
          cntl_error                = 1
          cntl_system_error         = 2
          illegal_event_combination = 3.

* set Handler
      data: l_event_receiver type ref to lcl_tree_event_receiver.
      create object l_event_receiver.
      set handler l_event_receiver->handle_item_double_click for ob_atr_itens.

    endform.                    " F_REG_EVENTS_ATR

*----------------------------------------------------------------------*
*   Form  F_REG_EVENTS_VLD
*----------------------------------------------------------------------*
*   Registrando Eventos da tree Atribuição
*----------------------------------------------------------------------*
    form f_reg_events_vld.

* define the events which will be passed to the backend
      data: lt_events type cntl_simple_events,
            l_event   type cntl_simple_event.

* define the events which will be passed to the backend
      l_event-eventid = cl_gui_column_tree=>eventid_item_double_click.
      append l_event to lt_events.

      call method ob_hvalid->set_registered_events
        exporting
          events                    = lt_events
        exceptions
          cntl_error                = 1
          cntl_system_error         = 2
          illegal_event_combination = 3.

* set Handler
      data: l_vld_receiver type ref to lcl_vld_event_receiver.
      create object l_vld_receiver.
      set handler l_vld_receiver->handle_item_double_click for ob_hvalid.

    endform.                    " F_REG_EVENTS_ATR

*----------------------------------------------------------------------*
*   Form  f_create_hier_atr
*----------------------------------------------------------------------*
*   Criando Hierarquia da TREE do XML
*----------------------------------------------------------------------*
    form f_create_hier_itens_atr.
      data: vl_last_key   type lvc_nkey,
            vl_parent_key type lvc_nkey,
            vl_text       type string,
            vl_text2      type string,
            vl_node_exp   type lvc_t_nkey.

***   Construíndo tabela de saída
      perform f_build_outtab_itens_atr.

      if vg_typed eq 'CTE'.

        clear wa_docmn.
        select single * from zhms_tb_docmn into wa_docmn where chave eq vg_chave
                                                           and mneum eq 'VTPREST'.

        if sy-subrc is initial.
          move wa_docmn-value to wa_itensview-dcprc.
        endif.

      endif.


**   Percorre tabela de itens para montar
      loop at t_itmdoc_atr into wa_itmdoc.
**      Limpar variável de pai.
        clear vl_parent_key.

        clear wa_itensview.
        move-corresponding wa_itmdoc to wa_itensview.

        if vg_typed eq 'CTE'.

          clear wa_docmn.
          select single * from zhms_tb_docmn into wa_docmn where chave eq vg_chave
                                                             and mneum eq 'VTPREST'.

          if sy-subrc is initial.
            move wa_docmn-value to wa_itensview-dcprc.
          endif.


          wa_itensview-dcqtd = 1.
        endif.



        if vg_typed eq 'NFSE1'.
          select single * from zhms_tb_docmn into wa_docmn where chave eq vg_chave
                                                   and mneum eq 'VALORSERVICO'.

          if sy-subrc is initial.
            move wa_docmn-value to  wa_itensview-dcprc.
          endif.
          wa_itensview-dcqtd = 1.
        endif.

**      Adiciona item do documento

**      Ajusta nome de ítem
**      Zeros a esquerda
        perform f_remove_zeros using wa_itmdoc-dcitm
                            changing vl_text.
**      Remove espaços
        condense vl_text no-gaps.

**      Número Ítem + Descrição
        concatenate vl_text '.' wa_itmdoc-denom into vl_text separated by space.

        clear wa_docmn.
        if vg_typed eq 'NFSE1' or vg_typed eq 'CTE'.
          select single * from zhms_tb_docmn into wa_docmn where chave eq vg_chave
                                                             and mneum eq 'NATOP'.
          concatenate vl_text  wa_docmn-value into vl_text separated by space.
        endif.


**      Limpar variaveis
        clear vl_parent_key.

        perform f_add_no_itens_atr    using wa_itensview ''
                                            vl_text
                                   changing vl_parent_key.
**      Percorre atribuídos
        loop at t_itmatr_atr into wa_itmatr where dcitm eq wa_itmdoc-dcitm.
          clear vl_text.

**        Tratamento para Denominação: Tipo de Documento
          case wa_itmatr-tdsrf.
            when 1.
              move text-s01 to vl_text.
            when 2.
              move text-s02 to vl_text.
            when 3.
              move text-s03 to vl_text.
            when 4.
              move text-s04 to vl_text.
            when 5.
              move text-s05 to vl_text.
            when 6.
              move text-s06 to vl_text.
            when 7.
              move text-s07 to vl_text.
            when 8.
              move text-s08 to vl_text.
            when 9.
              move text-s09 to vl_text.
            when 10.
              move text-s10 to vl_text.
            when 11.
              move text-s11 to vl_text.
            when 12.
              move text-s12 to vl_text.
            when 13.
              move text-s13 to vl_text.
            when 14.
              move text-s14 to vl_text.
            when 15.
              move text-s15 to vl_text.
            when 16.
              move text-s16 to vl_text.
            when 17.
              move text-s17 to vl_text.
            when 18.
              move text-s18 to vl_text.
            when 19.
              move text-s19 to vl_text.
          endcase.

**      Zeros a esquerda
          move wa_itmatr-itsrf to vl_text2.

**      Remove espaços
          condense vl_text2 no-gaps.

**      Demais campos
          wa_itensview-atlot = wa_itmatr-atlot.
          wa_itensview-dcqtd = wa_itmatr-atqtd.
          wa_itensview-dcprc = wa_itmatr-atprc.

**      Número Atribuição + Tipo Documento + Numero Documento
          concatenate  vl_text ':' wa_itmatr-nrsrf '(' vl_text2 ')' into vl_text separated by space.

**        Adiciona filhos (documentos atribuídos) à arvore
          perform f_add_no_itens_atr    using wa_itensview vl_parent_key
                                              vl_text
                                     changing vl_last_key.
**        Insere nó para expandir
          append vl_parent_key to vl_node_exp.
        endloop.

      endloop.

**      Expandir todos os nós
      call method ob_atr_itens->expand_nodes
        exporting
          it_node_key = vl_node_exp.

***   Atualizando valores no Objeto TREE criado
      call method ob_atr_itens->frontend_update.

    endform.                    " f_create_hier_atr


*----------------------------------------------------------------------*
*   Form  f_add_no_itens_atr
*----------------------------------------------------------------------*
*   Adicionando nós na árvore
*----------------------------------------------------------------------*
    form f_add_no_itens_atr  using  p_wa_itmview type zhms_es_itmview
                                    p_relat_key
                                    p_text
                          changing  p_node_key type lvc_nkey.

***   Variáveis locais para controle de exibição da Árvore
      data: lt_item_layout type lvc_t_layi,
            ls_item_layout type lvc_s_layi,
            l_node_text    type lvc_value.

***   Texto para exibição
      l_node_text =  p_text.

***   Layout da Árvore
      ls_item_layout-fieldname = ob_vis_itens->c_hierarchy_column_name.
      append ls_item_layout to lt_item_layout.

***   Chamada do método que insere linhas na árvore
      call method ob_atr_itens->add_node
        exporting
          i_relat_node_key = p_relat_key
          i_relationship   = cl_gui_column_tree=>relat_last_child
          is_outtab_line   = p_wa_itmview
          i_node_text      = l_node_text
          it_item_layout   = lt_item_layout
        importing
          e_new_node_key   = p_node_key.

    endform.                    " f_add_no_itens_atr

*&---------------------------------------------------------------------*
*&      Form  f_show_atr
*&---------------------------------------------------------------------*
*       Exibe atribuição para ítem selecionado
*----------------------------------------------------------------------*
*      -->P_ITEMSEL  text
*----------------------------------------------------------------------*
    form f_show_atr using wa_itemsel structure zhms_es_itmview.
**    Identifica o item selecionado
      data: vl_value type zhms_tb_docmn-value.
      clear wa_itmdoc_ax.
      read table t_itmdoc into wa_itmdoc_ax with key dcitm = wa_itemsel-dcitm.
      if wa_itmdoc_ax-dcprc is initial.
        if wa_itmdoc_ax-typed = 'NFSE1'.
          clear: vl_value.
          select single value
            into vl_value
           from zhms_tb_docmn
            where chave = wa_itmdoc_ax-chave
              and mneum = 'ITEMVALTOT'.
          if sy-subrc = 0.
            move: vl_value to wa_itmdoc_ax-dcprc.
          endif.
        elseif wa_itmdoc_ax-typed = 'CTE'.
          clear: vl_value.
          select single value
            into vl_value
           from zhms_tb_docmn
            where chave = wa_itmdoc_ax-chave
              and mneum = 'VTPREST'.
          if sy-subrc = 0.
            move: vl_value to wa_itmdoc_ax-dcprc.
          endif.
        endif.
      endif.
*      vg_0500 = '502'.
      leave to screen 0506.
      call screen 0506 starting at 30 1.
**    Limpa dados anteriores
      refresh: t_itmatr_ax.

**    Recarrega a janela
*      LEAVE TO SCREEN 500.

    endform.                    "f_show_atr

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
    form user_ok_tc using    p_tc_name type dynfnam
                             p_table_name
                             p_mark_name
                    changing p_ok      like sy-ucomm.

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
      data: l_ok     type sy-ucomm,
            l_offset type i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

*&SPWIZARD: Table control specific operations                          *
*&SPWIZARD: evaluate TC name and operations                            *
      search p_ok for p_tc_name.
      if sy-subrc <> 0.
        exit.
      endif.
      l_offset = strlen( p_tc_name ) + 1.
      l_ok = p_ok+l_offset.
*&SPWIZARD: execute general and TC specific operations                 *
      case l_ok.
        when 'INSR'.                      "insert row
          perform fcode_insert_row using    p_tc_name
                                            p_table_name.
          clear p_ok.

        when 'DELE'.                      "delete row
          perform fcode_delete_row using    p_tc_name
                                            p_table_name
                                            p_mark_name.
          clear p_ok.

        when 'P--' or                     "top of list
             'P-'  or                     "previous page
             'P+'  or                     "next page
             'P++'.                       "bottom of list
          perform compute_scrolling_in_tc using p_tc_name
                                                l_ok.
          clear p_ok.
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
        when 'MARK'.                      "mark all filled lines
          perform fcode_tc_mark_lines using p_tc_name
                                            p_table_name
                                            p_mark_name   .
          clear p_ok.

        when 'DMRK'.                      "demark all filled lines
          perform fcode_tc_demark_lines using p_tc_name
                                              p_table_name
                                              p_mark_name .
          clear p_ok.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.

      endcase.

    endform.                              " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
    form fcode_insert_row
                  using    p_tc_name           type dynfnam
                           p_table_name             .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
      data l_lines_name       like feld-name.
      data l_selline          like sy-stepl.
      data l_lastline         type i.
      data l_line             type i.
      data l_table_name       like feld-name.
      field-symbols <tc>                 type cxtab_control.
      field-symbols <table>              type standard table.
      field-symbols <lines>              type i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

      assign (p_tc_name) to <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
      concatenate p_table_name '[]' into l_table_name. "table body
      assign (l_table_name) to <table>.                "not headerline

*&SPWIZARD: get looplines of TableControl                              *
      concatenate 'G_' p_tc_name '_LINES' into l_lines_name.
      assign (l_lines_name) to <lines>.

*&SPWIZARD: get current line                                           *
      get cursor line l_selline.
      if sy-subrc <> 0.                   " append line to table
        l_selline = <tc>-lines + 1.
*&SPWIZARD: set top line                                               *
        if l_selline > <lines>.
          <tc>-top_line = l_selline - <lines> + 1 .
        else.
          <tc>-top_line = 1.
        endif.
      else.                               " insert line into table
        l_selline = <tc>-top_line + l_selline - 1.
        l_lastline = <tc>-top_line + <lines> - 1.
      endif.
*&SPWIZARD: set new cursor line                                        *
      l_line = l_selline - <tc>-top_line + 1.

*&SPWIZARD: insert initial line                                        *
      insert initial line into <table> index l_selline.
      <tc>-lines = <tc>-lines + 1.
*&SPWIZARD: set cursor                                                 *
      set cursor line l_line.

    endform.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
    form fcode_delete_row
                  using    p_tc_name           type dynfnam
                           p_table_name
                           p_mark_name   .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
      data l_table_name       like feld-name.

      field-symbols <tc>         type cxtab_control.
      field-symbols <table>      type standard table.
      field-symbols <wa>.
      field-symbols <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

      assign (p_tc_name) to <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
      concatenate p_table_name '[]' into l_table_name. "table body
      assign (l_table_name) to <table>.                "not headerline

*&SPWIZARD: delete marked lines                                        *
      describe table <table> lines <tc>-lines.

      loop at <table> assigning <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
        assign component p_mark_name of structure <wa> to <mark_field>.

*        IF <mark_field> = 'X'.
*          DELETE t_ITMATR_AX INDEX syst-tabix.
*          IF sy-subrc = 0.
*            <tc>-lines = <tc>-lines - 1.
*          ENDIF.
*        ENDIF.

        if <mark_field> = 'X'.
          delete <table> index syst-tabix.
          if sy-subrc = 0.
            <tc>-lines = <tc>-lines - 1.
          endif.
        endif.
      endloop.
      clear: vg_atprp.
    endform.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*      -->P_OK       ok code
*----------------------------------------------------------------------*
    form compute_scrolling_in_tc using    p_tc_name
                                          p_ok.
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
      data l_tc_new_top_line     type i.
      data l_tc_name             like feld-name.
      data l_tc_lines_name       like feld-name.
      data l_tc_field_name       like feld-name.

      field-symbols <tc>         type cxtab_control.
      field-symbols <lines>      type i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

      assign (p_tc_name) to <tc>.
*&SPWIZARD: get looplines of TableControl                              *
      concatenate 'G_' p_tc_name '_LINES' into l_tc_lines_name.
      assign (l_tc_lines_name) to <lines>.


*&SPWIZARD: is no line filled?                                         *
      if <tc>-lines = 0.
*&SPWIZARD: yes, ...                                                   *
        l_tc_new_top_line = 1.
      else.
*&SPWIZARD: no, ...                                                    *
        call function 'SCROLLING_IN_TABLE'
          exporting
            entry_act      = <tc>-top_line
            entry_from     = 1
            entry_to       = <tc>-lines
            last_page_full = 'X'
            loops          = <lines>
            ok_code        = p_ok
            overlapping    = 'X'
          importing
            entry_new      = l_tc_new_top_line
          exceptions
*           NO_ENTRY_OR_PAGE_ACT  = 01
*           NO_ENTRY_TO    = 02
*           NO_OK_CODE_OR_PAGE_GO = 03
            others         = 0.
      endif.

*&SPWIZARD: get actual tc and column                                   *
      get cursor field l_tc_field_name
                 area  l_tc_name.

      if syst-subrc = 0.
        if l_tc_name = p_tc_name.
*&SPWIZARD: et actual column                                           *
          set cursor field l_tc_field_name line 1.
        endif.
      endif.

*&SPWIZARD: set the new top line                                       *
      <tc>-top_line = l_tc_new_top_line.


    endform.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
    form fcode_tc_mark_lines using p_tc_name
                                   p_table_name
                                   p_mark_name.
*&SPWIZARD: EGIN OF LOCAL DATA-----------------------------------------*
      data l_table_name       like feld-name.

      field-symbols <tc>         type cxtab_control.
      field-symbols <table>      type standard table.
      field-symbols <wa>.
      field-symbols <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

      assign (p_tc_name) to <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
      concatenate p_table_name '[]' into l_table_name. "table body
      assign (l_table_name) to <table>.                "not headerline

*&SPWIZARD: mark all filled lines                                      *
      loop at <table> assigning <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
        assign component p_mark_name of structure <wa> to <mark_field>.

        <mark_field> = 'X'.
      endloop.
    endform.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
    form fcode_tc_demark_lines using p_tc_name
                                     p_table_name
                                     p_mark_name .
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
      data l_table_name       like feld-name.

      field-symbols <tc>         type cxtab_control.
      field-symbols <table>      type standard table.
      field-symbols <wa>.
      field-symbols <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

      assign (p_tc_name) to <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
      concatenate p_table_name '[]' into l_table_name. "table body
      assign (l_table_name) to <table>.                "not headerline

*&SPWIZARD: demark all filled lines                                    *
      loop at <table> assigning <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
        assign component p_mark_name of structure <wa> to <mark_field>.

        <mark_field> = space.
      endloop.
    endform.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  F_ATR_GRAVAR
*&---------------------------------------------------------------------*
*       Gravar Atribuição
*----------------------------------------------------------------------*
    form f_atr_gravar .
*****    Variáveis locais
***      DATA: vl_seqnr     TYPE zhms_de_seqnr,
****            vl_atitmproc TYPE i,
***            vl_atitm     TYPE zhms_de_atitm,
***            vl_last      TYPE flag,
***            lv_po        TYPE ebeln.
***
***      DATA: tl_docum     TYPE TABLE OF zhms_es_docum,
***            wl_docum     TYPE zhms_es_docum,
***            tl_itmatr    TYPE TABLE OF zhms_tb_itmatr,
***            wl_itmatr    TYPE zhms_tb_itmatr,
***            tl_logdoc    TYPE TABLE OF zhms_tb_logdoc,
***            wl_logdoc    TYPE zhms_tb_logdoc.
***      REFRESH: t_atrbuffer.
***
***      CLEAR: vl_seqnr.
*****    Seleciona o primeiro registro inserido
***      READ TABLE t_itmatr_ax INTO wa_itmatr_ax INDEX 1.
***
*****    Verifica se existe o primeiro registro. Caso não a tabela está vazia
***      CHECK sy-subrc IS INITIAL.
***
*****    Deleta outras ocorrencias antes de gravar
***      DELETE FROM zhms_tb_itmatr
***       WHERE natdc EQ wa_itmatr_ax-natdc
***         AND typed EQ wa_itmatr_ax-typed
***         AND loctp EQ wa_itmatr_ax-loctp
***         AND chave EQ wa_itmatr_ax-chave
***         AND dcitm EQ wa_itmatr_ax-dcitm.
*****    Garante a deleção
***      COMMIT WORK AND WAIT.
***
*****    Insere atribuição na tabela de atribuições.
***      LOOP AT t_itmatr_ax INTO wa_itmatr_ax.
***
***        IF wa_itmatr_ax-nrsrf IS NOT INITIAL.
***          CLEAR lv_po.
***          MOVE wa_itmatr_ax-nrsrf TO lv_po.
***          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
***            EXPORTING
***              input  = lv_po
***            IMPORTING
***              output = lv_po.
***          CLEAR wa_itmatr_ax-nrsrf.
***          MOVE lv_po TO wa_itmatr_ax-nrsrf.
***        ENDIF.
***
***        MOVE-CORRESPONDING wa_itmatr_ax TO wa_itmatr.
***
***        INSERT INTO zhms_tb_itmatr VALUES wa_itmatr.
***      ENDLOOP.
***
*****    Ajusta item de processamento
***      SELECT *
***        INTO TABLE tl_itmatr
***        FROM zhms_tb_itmatr
***       WHERE natdc EQ wa_itmatr_ax-natdc
***         AND typed EQ wa_itmatr_ax-typed
***         AND loctp EQ wa_itmatr_ax-loctp
***         AND chave EQ wa_itmatr_ax-chave.
***
*****    Ordenar
***      SORT tl_itmatr BY dcitm ASCENDING
***                        atitm ASCENDING.
***      CLEAR vl_atitm.
***
***      LOOP AT tl_itmatr INTO wl_itmatr.
***        vl_atitm = vl_atitm + 1.
*****      Atualizar tabela
***        UPDATE zhms_tb_itmatr
***           SET atitm = vl_atitm
***         WHERE natdc EQ wl_itmatr-natdc
***           AND typed EQ wl_itmatr-typed
***           AND loctp EQ wl_itmatr-loctp
***           AND chave EQ wl_itmatr-chave
***           AND dcitm EQ wl_itmatr-dcitm
***           AND seqnr EQ wl_itmatr-seqnr.
***
***        COMMIT WORK AND WAIT.
***
*****      Atualizar tabela interna
***        READ TABLE t_itmatr_ax
***              INTO wa_itmatr_ax
***          WITH KEY  natdc = wl_itmatr-natdc
***                    typed = wl_itmatr-typed
***                    loctp = wl_itmatr-loctp
***                    chave = wl_itmatr-chave
***                    dcitm = wl_itmatr-dcitm
***                    seqnr = wl_itmatr-seqnr.
***        IF sy-subrc IS INITIAL.
***
***          IF  wa_itmatr_ax-nrsrf IS NOT INITIAL.
***            CLEAR lv_po.
***            MOVE wa_itmatr_ax-nrsrf TO lv_po.
***            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
***              EXPORTING
***                input  = lv_po
***              IMPORTING
***                output = lv_po.
***            CLEAR wa_itmatr_ax-nrsrf.
***            MOVE lv_po TO wa_itmatr_ax-nrsrf.
***          ENDIF.
***
***          wa_itmatr_ax-atitm = vl_atitm.
***          MODIFY t_itmatr_ax FROM wa_itmatr_ax INDEX sy-tabix.
***        ENDIF.
***      ENDLOOP.
***
***
*****    Buscar mneumonicos a serem gerados
***      SELECT *
***        INTO TABLE t_mneuatr
***        FROM zhms_tb_mneuatr.
***
**** Apaga atribuição anterior
***      IF vg_just_ok IS INITIAL.
***        READ TABLE t_itmatr_ax INTO wa_itmatr_ax INDEX 1.
***        DELETE FROM zhms_tb_docmn
***         WHERE chave EQ wa_itmatr-chave
***           AND dcitm EQ wa_itmatr_ax-dcitm
***           AND ( mneum EQ 'ATQTD'
***              OR mneum EQ 'ATUM'
***              OR mneum EQ 'ATPED'
***              OR mneum EQ 'ATITMPED'
***              OR mneum EQ 'ATITMXML'
***              OR mneum EQ 'ATITMPROC'
****            OR mneum EQ 'XMLNCM'
***              OR mneum EQ 'ATVLR'
***              OR mneum EQ 'AEXTLOT'
***              OR mneum EQ 'DATAPROD'
***              OR mneum EQ 'DATAVENC'
***              OR mneum EQ 'ATTLOT' ).
***        COMMIT WORK AND WAIT.
***      ELSE.
****** Inicio Inclusão David Rosin
****** Limpa mneumonicos da tabela interna
***        DELETE t_docmn  WHERE chave EQ wa_itmatr-chave
***                 AND dcitm EQ wa_itmatr_ax-dcitm
***                 AND ( mneum EQ 'ATQTD'
***                    OR mneum EQ 'ATUM'
***                    OR mneum EQ 'ATPED'
***                    OR mneum EQ 'ATITMPED'
***                    OR mneum EQ 'ATITMXML'
***                    OR mneum EQ 'ATITMPROC'
***                    OR mneum EQ 'ATVLR'
***                    OR mneum EQ 'AEXTLOT'
***                    OR mneum EQ 'DATAPROD'
***                    OR mneum EQ 'DATAVENC'
***                    OR mneum EQ 'XMLNCM'
***                    OR mneum EQ 'ATTLOT' ).
****** Fim Inclusão David Rosin
***      ENDIF.
***
***      IF vg_just_ok IS INITIAL.
****** Inicio Inclusão David Rosin
****** Limpa mneumonicos da tabela interna
***        DELETE t_docmn  WHERE chave EQ wa_itmatr-chave
***                 AND dcitm EQ wa_itmatr_ax-dcitm
***                 AND ( mneum EQ 'ATQTD'
***                    OR mneum EQ 'ATUM'
***                    OR mneum EQ 'ATPED'
***                    OR mneum EQ 'ATITMPED'
***                    OR mneum EQ 'ATITMXML'
***                    OR mneum EQ 'ATITMPROC'
****              OR mneum EQ 'NCM'
***                    OR mneum EQ 'AEXTLOT'
***                    OR mneum EQ 'DATAPROD'
***                    OR mneum EQ 'DATAVENC'
***                    OR mneum EQ 'ATVLR'
***                    OR mneum EQ 'ATTLOT' ).
****** Fim Inclusão David Rosin
***      ELSE.
***        DELETE t_docmn  WHERE chave EQ wa_itmatr-chave
***                 AND dcitm EQ wa_itmatr_ax-dcitm
***                 AND ( mneum EQ 'ATQTD'
***                    OR mneum EQ 'ATUM'
***                    OR mneum EQ 'ATPED'
***                    OR mneum EQ 'ATITMPED'
***                    OR mneum EQ 'ATITMXML'
***                    OR mneum EQ 'ATITMPROC'
***                    OR mneum EQ 'XMLNCM'
***                    OR mneum EQ 'ATVLR'
***                    OR mneum EQ 'AEXTLOT'
***                    OR mneum EQ 'DATAPROD'
***                    OR mneum EQ 'DATAVENC'
***                    OR mneum EQ 'ATTLOT' ).
***      ENDIF.
***
*****    Gerar Mneumonicos com base na atribuição feita
***      PERFORM f_nextseq_mneum CHANGING vl_seqnr.
***
*****    Percorre Items
***      LOOP AT t_itmatr_ax INTO wa_itmatr_ax.
***
*****      Ponteiro ITMDOC
***        READ TABLE t_itmdoc INTO wa_itmdoc WITH KEY chave = wa_itmatr_ax-chave
***                                                    dcitm = wa_itmatr_ax-dcitm.
***
*****      definir Ultimo
***        CLEAR vl_last.
***        AT LAST.
***          vl_last = 'X'.
***        ENDAT.
***
**** Quantidade final
***        CLEAR wa_docmn.
***        vl_seqnr = vl_seqnr + 1.
***        wa_docmn-chave = wa_itmatr-chave.
***        wa_docmn-seqnr = vl_seqnr.
***        wa_docmn-mneum = 'ATQTD'.
***        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
***        wa_docmn-atitm = wa_itmatr_ax-atitm.
***        wa_docmn-value = wa_itmatr_ax-atqtd.
***        CONDENSE wa_docmn-value NO-GAPS.
***        APPEND wa_docmn TO t_docmn.
***
****Unidade final
***        CLEAR wa_docmn.
***        vl_seqnr = vl_seqnr + 1.
***        wa_docmn-chave = wa_itmatr-chave.
***        wa_docmn-seqnr = vl_seqnr.
***        wa_docmn-mneum = 'ATUM'.
***        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
***        wa_docmn-atitm = wa_itmatr_ax-atitm.
***        wa_docmn-value = wa_itmatr_ax-atunm.
***        CONDENSE wa_docmn-value NO-GAPS.
***        APPEND wa_docmn TO t_docmn.
***
***
*******        CASE wa_itmatr_ax-tdsrf.
*******          WHEN '1'. " Pedido de compra
***
****           Documento Referencia
***        CLEAR wa_docmn.
***        vl_seqnr = vl_seqnr + 1.
***        wa_docmn-chave = wa_itmatr-chave.
***        wa_docmn-seqnr = vl_seqnr.
***        wa_docmn-mneum = 'ATPED'.
***        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
***        wa_docmn-atitm = wa_itmatr_ax-atitm.
***
***        IF wa_itmatr_ax-nrsrf IS NOT INITIAL.
***          CLEAR lv_po.
***          MOVE wa_itmatr_ax-nrsrf TO lv_po.
***          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
***            EXPORTING
***              input  = lv_po
***            IMPORTING
***              output = lv_po.
***          CLEAR wa_itmatr_ax-nrsrf.
***          MOVE lv_po TO wa_itmatr_ax-nrsrf.
***        ENDIF.
***
***        wa_docmn-value = wa_itmatr_ax-nrsrf.
***        CONDENSE wa_docmn-value NO-GAPS.
***        APPEND wa_docmn TO t_docmn.
***
****           Item Documento referencia
***        CLEAR wa_docmn.
***        vl_seqnr = vl_seqnr + 1.
***        wa_docmn-chave = wa_itmatr-chave.
***        wa_docmn-seqnr = vl_seqnr.
***        wa_docmn-mneum = 'ATITMPED'.
***        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
***        wa_docmn-atitm = wa_itmatr_ax-atitm.
***        wa_docmn-value = wa_itmatr_ax-itsrf.
***        CONDENSE wa_docmn-value NO-GAPS.
***        APPEND wa_docmn TO t_docmn.
***
*******          WHEN OTHERS.
*******        ENDCASE.
***
***
***
****Item do XML
***        CLEAR wa_docmn.
***        vl_seqnr = vl_seqnr + 1.
***        wa_docmn-chave = wa_itmatr-chave.
***        wa_docmn-seqnr = vl_seqnr.
***        wa_docmn-mneum = 'ATITMXML'.
***        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
***        wa_docmn-atitm = wa_itmatr_ax-atitm.
***        wa_docmn-value = wa_itmatr_ax-dcitm.
***        CONDENSE wa_docmn-value NO-GAPS.
***        APPEND wa_docmn TO t_docmn.
***
***
****Item para processamento
***        CLEAR wa_docmn.
***        vl_seqnr       = vl_seqnr + 1.
***        wa_docmn-chave = wa_itmatr-chave.
***        wa_docmn-seqnr = vl_seqnr.
***        wa_docmn-mneum = 'ATITMPROC'.
***        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
***        wa_docmn-atitm = wa_itmatr_ax-atitm.
***        wa_docmn-value = wa_itmatr_ax-atitm.
***        CONDENSE wa_docmn-value NO-GAPS.
***        APPEND wa_docmn TO t_docmn.
***
***
****valor do item
***        CLEAR wa_docmn.
***        vl_seqnr = vl_seqnr + 1.
***        wa_docmn-chave = wa_itmatr-chave.
***        wa_docmn-seqnr = vl_seqnr.
***        wa_docmn-mneum = 'ATVLR'.
***        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
***        wa_docmn-atitm = wa_itmatr_ax-atitm.
***        wa_docmn-value = wa_itmatr_ax-atprc.
***        CONDENSE wa_docmn-value NO-GAPS.
***        APPEND wa_docmn TO t_docmn.
***
***        IF NOT wa_itmatr_ax-ncm IS INITIAL AND NOT vg_just_ok IS INITIAL..
**** Quantidade final
***          CLEAR wa_docmn.
***          vl_seqnr = vl_seqnr + 1.
***          wa_docmn-chave = wa_itmatr-chave.
***          wa_docmn-seqnr = vl_seqnr.
***          wa_docmn-mneum = 'XMLNCM'.
***          wa_docmn-dcitm = wa_itmatr_ax-dcitm.
***          wa_docmn-atitm = wa_itmatr_ax-atitm.
***          wa_docmn-value = wa_itmatr_ax-ncm.
***          CONDENSE wa_docmn-value NO-GAPS.
***          APPEND wa_docmn TO t_docmn.
***        ENDIF.
***
**** Lote
***        CLEAR wa_docmn.
***        vl_seqnr = vl_seqnr + 1.
***        wa_docmn-chave = wa_itmatr-chave.
***        wa_docmn-seqnr = vl_seqnr.
***        wa_docmn-mneum = 'ATTLOT'.
***        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
***        wa_docmn-atitm = wa_itmatr_ax-atitm.
***        wa_docmn-value = wa_itmatr_ax-atlot.
***        CONDENSE wa_docmn-value NO-GAPS.
***        APPEND wa_docmn TO t_docmn.
***
***        CLEAR wa_docmn.
***        vl_seqnr = vl_seqnr + 1.
***        wa_docmn-chave = wa_itmatr-chave.
***        wa_docmn-seqnr = vl_seqnr.
***        wa_docmn-mneum = 'AEXTLOT'.
***        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
***        wa_docmn-atitm = wa_itmatr_ax-atitm.
***        wa_docmn-value = wa_itmatr_ax-exlot.
***        CONDENSE wa_docmn-value NO-GAPS.
***        APPEND wa_docmn TO t_docmn.
***
***        CLEAR wa_docmn.
***        vl_seqnr = vl_seqnr + 1.
***        wa_docmn-chave = wa_itmatr-chave.
***        wa_docmn-seqnr = vl_seqnr.
***        wa_docmn-mneum = 'DATAPROD'.
***        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
***        wa_docmn-atitm = wa_itmatr_ax-atitm.
***        wa_docmn-value = wa_itmatr_ax-data_prod.
***        CONDENSE wa_docmn-value NO-GAPS.
***        APPEND wa_docmn TO t_docmn.
***
***        CLEAR wa_docmn.
***        vl_seqnr = vl_seqnr + 1.
***        wa_docmn-chave = wa_itmatr-chave.
***        wa_docmn-seqnr = vl_seqnr.
***        wa_docmn-mneum = 'DATAVENC'.
***        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
***        wa_docmn-atitm = wa_itmatr_ax-atitm.
***        wa_docmn-value = wa_itmatr_ax-data_venc.
***        CONDENSE wa_docmn-value NO-GAPS.
***        APPEND wa_docmn TO t_docmn.
***
*****      Percorre Mneumônicos de valores a serem gerados pela Atribuição
***        LOOP AT t_mneuatr INTO wa_mneuatr.
***
***
*****        Busca mneumonico de origem para geração do mneumonico de atribuição
***          READ TABLE t_docmn_rep INTO wa_docmn_ax WITH KEY mneum = wa_mneuatr-mnorg
***                                                       dcitm = wa_itmatr_ax-dcitm.
***
*****        Verifica se existe mneumonico de origem
***          CHECK sy-subrc IS INITIAL.
***
**** Apaga atribuição anterior
***          DELETE FROM zhms_tb_docmn
***           WHERE chave EQ wa_itmatr-chave
***             AND dcitm EQ wa_itmatr_ax-dcitm
***             AND mneum EQ wa_mneuatr-mndst.
***
***          COMMIT WORK AND WAIT.
***
*****        Transfere valores
***          CLEAR wa_docmn.
***          vl_seqnr = vl_seqnr + 1.
***          wa_docmn-chave = wa_itmatr-chave.
***          wa_docmn-seqnr = vl_seqnr.
***          wa_docmn-mneum = wa_mneuatr-mndst.
***          wa_docmn-dcitm = wa_itmatr_ax-dcitm.
***          wa_docmn-atitm = wa_itmatr_ax-atitm.
***
*****        Cálculos de proporção para distribuição
***          PERFORM f_calcula_proporcao USING wa_docmn_ax-value wa_itmdoc-dcqtd wa_itmatr_ax-atqtd vl_last wa_docmn-mneum
***                                   CHANGING wa_docmn-value.
***          CONDENSE wa_docmn-value NO-GAPS.
***          APPEND wa_docmn TO t_docmn.
***        ENDLOOP.
***
***      ENDLOOP.
***
*****     Corrige os zeros a esquera
***      LOOP AT t_docmn INTO wa_docmn.
***        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
***          EXPORTING
***            input  = wa_docmn-seqnr
***          IMPORTING
***            output = wa_docmn-seqnr.
***        MODIFY t_docmn FROM wa_docmn INDEX sy-tabix.
***      ENDLOOP.
***
*****    Insere/Modifica dados no repositorio de mneumonicos
****      INSERT zhms_tb_docmn FROM TABLE t_docmn.
***      MODIFY zhms_tb_docmn FROM TABLE t_docmn.
***      COMMIT WORK AND WAIT.
***
*****    Executa regras identificação de cenário
***      CLEAR wl_docum.
***      wl_docum-dctyp = 'CHAVE'.
***      wl_docum-dcnro = wa_cabdoc-chave.
***      APPEND wl_docum TO tl_docum.
***
****      CALL FUNCTION 'ZHMS_FM_TRACER'
****        EXPORTING
****          natdc                 = wa_cabdoc-natdc
****          typed                 = wa_cabdoc-typed
****          loctp                 = wa_cabdoc-loctp
****          just_ident            = 'X'
****        TABLES
****          docum                 = tl_docum
****        EXCEPTIONS
****          document_not_informed = 1
****          scenario_not_found    = 2
****          OTHERS                = 3.
***
***** Registra LOG
***      wl_logdoc-logty = 'S'.
***      wl_logdoc-logno = '500'.
***      APPEND wl_logdoc TO tl_logdoc.
***
***      CALL FUNCTION 'ZHMS_FM_REGLOG'
***        EXPORTING
***          cabdoc = wa_cabdoc
***          flwst  = 'M'
***          tpprm  = 4
***        TABLES
***          logdoc = tl_logdoc.
***
*****    Limpa as estruturas de atribução
***      CLEAR: wa_itmatr_ax.
***      REFRESH: t_itmatr_ax.
***
*****    Seta tela inicial
***      vg_0500 = '0501'.
***
*****    Exibe mensagem de sucesso
***      MESSAGE s052.

**    Variáveis locais
      data: vl_seqnr type zhms_de_seqnr,
*            vl_atitmproc TYPE i,
            vl_atitm type zhms_de_atitm,
            vl_last  type flag,
            lv_po    type ebeln.

      data: tl_docum  type table of zhms_es_docum,
            wl_docum  type zhms_es_docum,
            tl_itmatr type table of zhms_tb_itmatr,
            wl_itmatr type zhms_tb_itmatr,
            tl_logdoc type table of zhms_tb_logdoc,
            wl_logdoc type zhms_tb_logdoc.
      refresh: t_atrbuffer.

      clear: vl_seqnr.
**    Seleciona o primeiro registro inserido
      read table t_itmatr_ax into wa_itmatr_ax index 1.

**    Verifica se existe o primeiro registro. Caso não a tabela está vazia
      check sy-subrc is initial.

**    Deleta outras ocorrencias antes de gravar
      delete from zhms_tb_itmatr
       where natdc eq wa_itmatr_ax-natdc
         and typed eq wa_itmatr_ax-typed
         and loctp eq wa_itmatr_ax-loctp
         and chave eq wa_itmatr_ax-chave
         and dcitm eq wa_itmatr_ax-dcitm.
**    Garante a deleção
      commit work and wait.

**    Insere atribuição na tabela de atribuições.
      loop at t_itmatr_ax into wa_itmatr_ax.

        if wa_itmatr_ax-nrsrf is not initial.
          clear lv_po.
          move wa_itmatr_ax-nrsrf to lv_po.
          call function 'CONVERSION_EXIT_ALPHA_INPUT'
            exporting
              input  = lv_po
            importing
              output = lv_po.
          clear wa_itmatr_ax-nrsrf.
          move lv_po to wa_itmatr_ax-nrsrf.
        endif.

        move-corresponding wa_itmatr_ax to wa_itmatr.

        insert into zhms_tb_itmatr values wa_itmatr.
      endloop.

**    Ajusta item de processamento
      select *
        into table tl_itmatr
        from zhms_tb_itmatr
       where natdc eq wa_itmatr_ax-natdc
         and typed eq wa_itmatr_ax-typed
         and loctp eq wa_itmatr_ax-loctp
         and chave eq wa_itmatr_ax-chave.

**    Ordenar
      sort tl_itmatr by dcitm ascending
                        atitm ascending.
      clear vl_atitm.

      loop at tl_itmatr into wl_itmatr.
        vl_atitm = vl_atitm + 1.
**      Atualizar tabela
        update zhms_tb_itmatr
           set atitm = vl_atitm
         where natdc eq wl_itmatr-natdc
           and typed eq wl_itmatr-typed
           and loctp eq wl_itmatr-loctp
           and chave eq wl_itmatr-chave
           and dcitm eq wl_itmatr-dcitm
           and seqnr eq wl_itmatr-seqnr.

        commit work and wait.

**      Atualizar tabela interna
        read table t_itmatr_ax
              into wa_itmatr_ax
          with key  natdc = wl_itmatr-natdc
                    typed = wl_itmatr-typed
                    loctp = wl_itmatr-loctp
                    chave = wl_itmatr-chave
                    dcitm = wl_itmatr-dcitm
                    seqnr = wl_itmatr-seqnr.
        if sy-subrc is initial.

          if  wa_itmatr_ax-nrsrf is not initial.
            clear lv_po.
            move wa_itmatr_ax-nrsrf to lv_po.
            call function 'CONVERSION_EXIT_ALPHA_INPUT'
              exporting
                input  = lv_po
              importing
                output = lv_po.
            clear wa_itmatr_ax-nrsrf.
            move lv_po to wa_itmatr_ax-nrsrf.
          endif.

          wa_itmatr_ax-atitm = vl_atitm.
          modify t_itmatr_ax from wa_itmatr_ax index sy-tabix.
        endif.
      endloop.


**    Buscar mneumonicos a serem gerados
      select *
        into table t_mneuatr
        from zhms_tb_mneuatr.

* Apaga atribuição anterior
      if vg_just_ok is initial.
        read table t_itmatr_ax into wa_itmatr_ax index 1.
        delete from zhms_tb_docmn
         where chave eq wa_itmatr-chave
           and dcitm eq wa_itmatr_ax-dcitm
           and ( mneum eq 'ATQTD'
              or mneum eq 'ATUM'
              or mneum eq 'ATPED'
              or mneum eq 'ATITMPED'
              or mneum eq 'ATITMXML'
              or mneum eq 'ATITMPROC'
*            OR mneum EQ 'XMLNCM'
              or mneum eq 'ATVLR'
              or mneum eq 'AEXTLOT'
              or mneum eq 'DATAPROD'
              or mneum eq 'DATAVENC'
              or mneum eq 'ATTLOT'
              or mneum eq 'ATITMXML'
              or mneum eq 'ATITMPED'
              or mneum eq 'ATQTDE'
              or mneum eq 'ATVCOFINS'
              or mneum eq 'ATVCOFINSS'
              or mneum eq 'ATCRICMSST'
              or mneum eq 'ATDESC'
              or mneum eq 'ATFRT'
              or mneum eq 'ATVICMS'
              or mneum eq 'ATVICMSST'
              or mneum eq 'ATICMSSDES'
              or mneum eq 'ATICMSSRET'
              or mneum eq 'ATVII'
              or mneum eq 'ATVIOF'
              or mneum eq 'ATVIPI'
              or mneum eq 'ATVISSQN'
              or mneum eq 'ATDESPAC'
              or mneum eq 'ATVPIS'
              or mneum eq 'ATVPISST'
              or mneum eq 'ATVLR'
              or mneum eq 'ATSEG'
              or mneum eq 'NCM'
              or mneum eq 'ATPED'
              or mneum eq 'MATDOC'
              or mneum eq 'FISCALYEAR'
              or mneum eq 'MATDOCYEA'
              or mneum = 'ACTIVITY'
              or mneum = 'ASSETNO'
              or mneum = 'BUDGPERIOD'
              or mneum = 'BUSAREA'
              or mneum = 'CMMTITEM'
              or mneum = 'CMMTITMLON'
              or mneum = 'COAREA'
              or mneum = 'COSTCENTER'
              or mneum = 'COSTCTR'
              or mneum = 'COSTOBJ'
              or mneum = 'CUSTOMER'
              or mneum = 'DELIVITEM'
              or mneum = 'DELIVNUMB'
              or mneum = 'DISTRPERC'
              or mneum = 'ENRYUOMISO'
              or mneum = 'FUNAREALON'
              or mneum = 'FUNCAREA'
              or mneum = 'FUND'
              or mneum = 'FUNDSCTR'
              or mneum = 'FUNDSRES'
              or mneum = 'GLACCOUNT'
              or mneum = 'GLACCT'
              or mneum = 'GRANTNBR'
              or mneum = 'GRRCPT'
              or mneum = 'MATDOCYEA'
              or mneum = 'MATERIAL'
              or mneum = 'MATLGROUP'
              or mneum = 'MATLUSAGE'
              or mneum = 'MATORIGIN'
              or mneum = 'MVTIND'
              or mneum = 'NBSLIPS'
              or mneum = 'NETPRICE'
              or mneum = 'NETWORK'
              or mneum = 'ORDERID'
              or mneum = 'ORDERNO'
              or mneum = 'PARTACCT'
              or mneum = 'PLANT'
              or mneum = 'PROFITCTR'
              or mneum = 'PROFSEGM'
              or mneum = 'PROFSEGMNO'
              or mneum = 'PROJEXT'
              or mneum = 'QUANTITY'
              or mneum = 'RECIND'
              or mneum = 'REFDATE'
              or mneum = 'RESITEM'
              or mneum = 'RLESTKEY'
              or mneum = 'ROUTINGNO'
              or mneum = 'SCHEDLINE'
              or mneum = 'SDDOC'
              or mneum = 'SDOCITEM'
              or mneum = 'SERIALNO'
              or mneum = 'STGELOC'
              or mneum = 'SUBNUMBER'
              or mneum = 'TAXCODE'
              or mneum = 'TAXJURCODE'
              or mneum = 'TOCOSTCTR'
              or mneum = 'TOORDER'
              or mneum = 'TOPROJECT'
              or mneum = 'VALTYPE'
              or mneum = 'VENDOR'
              or mneum = 'WBSELEM'
              or mneum = 'WBSELEME' ).
        commit work and wait.
      else.
*** Inicio Inclusão David Rosin
*** Limpa mneumonicos da tabela interna
        delete t_docmn  where chave eq wa_itmatr-chave
                  and dcitm eq wa_itmatr_ax-dcitm
                  and ( mneum eq 'ATQTD'
                   or mneum eq 'ATUM'
                   or mneum eq 'ATPED'
                   or mneum eq 'ATITMPED'
                   or mneum eq 'ATITMXML'
                   or mneum eq 'ATITMPROC'
                   or mneum eq 'ATVLR'
                   or mneum eq 'AEXTLOT'
                   or mneum eq 'DATAPROD'
                   or mneum eq 'DATAVENC'
                   or mneum eq 'XMLNCM'
                   or mneum eq 'ATTLOT'
                   or mneum eq 'ATITMXML'
                   or mneum eq 'ATITMPED'
                   or mneum eq 'ATQTDE'
                   or mneum eq 'ATVCOFINS'
                   or mneum eq 'ATVCOFINSS'
                   or mneum eq 'ATCRICMSST'
                   or mneum eq 'ATDESC'
                   or mneum eq 'ATFRT'
                   or mneum eq 'ATVICMS'
                   or mneum eq 'ATVICMSST'
                   or mneum eq 'ATICMSSDES'
                   or mneum eq 'ATICMSSRET'
                   or mneum eq 'ATVII'
                   or mneum eq 'ATVIOF'
                   or mneum eq 'ATVIPI'
                   or mneum eq 'ATVISSQN'
                   or mneum eq 'ATDESPAC'
                   or mneum eq 'ATVPIS'
                   or mneum eq 'ATVPISST'
                   or mneum eq 'ATVLR'
                   or mneum eq 'ATSEG'
                   or mneum eq 'NCM'
                   or mneum eq 'ATPED'
                   or mneum eq 'MATDOC'
                   or mneum eq 'FISCALYEAR'
                   or mneum eq 'MATDOCYEA'
                   or mneum = 'ACTIVITY'
                   or mneum = 'ASSETNO'
                   or mneum = 'BUDGPERIOD'
                   or mneum = 'BUSAREA'
                   or mneum = 'CMMTITEM'
                   or mneum = 'CMMTITMLON'
                   or mneum = 'COAREA'
                   or mneum = 'COSTCENTER'
                   or mneum = 'COSTCTR'
                   or mneum = 'COSTOBJ'
                   or mneum = 'CUSTOMER'
                   or mneum = 'DELIVITEM'
                   or mneum = 'DELIVNUMB'
                   or mneum = 'DISTRPERC'
                   or mneum = 'ENRYUOMISO'
                   or mneum = 'FUNAREALON'
                   or mneum = 'FUNCAREA'
                   or mneum = 'FUND'
                   or mneum = 'FUNDSCTR'
                   or mneum = 'FUNDSRES'
                   or mneum = 'GLACCOUNT'
                   or mneum = 'GLACCT'
                   or mneum = 'GRANTNBR'
                   or mneum = 'GRRCPT'
                   or mneum = 'MATDOCYEA'
                   or mneum = 'MATERIAL'
                   or mneum = 'MATLGROUP'
                   or mneum = 'MATLUSAGE'
                   or mneum = 'MATORIGIN'
                   or mneum = 'MVTIND'
                   or mneum = 'NBSLIPS'
                   or mneum = 'NETPRICE'
                   or mneum = 'NETWORK'
                   or mneum = 'ORDERID'
                   or mneum = 'ORDERNO'
                   or mneum = 'PARTACCT'
                   or mneum = 'PLANT'
                   or mneum = 'PROFITCTR'
                   or mneum = 'PROFSEGM'
                   or mneum = 'PROFSEGMNO'
                   or mneum = 'PROJEXT'
                   or mneum = 'QUANTITY'
                   or mneum = 'RECIND'
                   or mneum = 'REFDATE'
                   or mneum = 'RESITEM'
                   or mneum = 'RLESTKEY'
                   or mneum = 'ROUTINGNO'
                   or mneum = 'SCHEDLINE'
                   or mneum = 'SDDOC'
                   or mneum = 'SDOCITEM'
                   or mneum = 'SERIALNO'
                   or mneum = 'STGELOC'
                   or mneum = 'SUBNUMBER'
                   or mneum = 'TAXCODE'
                   or mneum = 'TAXJURCODE'
                   or mneum = 'TOCOSTCTR'
                   or mneum = 'TOORDER'
                   or mneum = 'TOPROJECT'
                   or mneum = 'VALTYPE'
                   or mneum = 'VENDOR'
                   or mneum = 'WBSELEM'
                   or mneum = 'WBSELEME').
*** Fim Inclusão David Rosin
      endif.

      if vg_just_ok is initial.
*** Inicio Inclusão David Rosin
*** Limpa mneumonicos da tabela interna
        delete t_docmn  where chave eq wa_itmatr-chave
                    and dcitm eq wa_itmatr_ax-dcitm
                    and ( mneum eq 'ATQTD'
                     or mneum eq 'ATQTDE'
                     or mneum eq 'ATUM'
                     or mneum eq 'ATPED'
                     or mneum eq 'ATITMPED'
                     or mneum eq 'ATITMXML'
                     or mneum eq 'ATITMPROC'
*              OR mneum EQ 'NCM'
                     or mneum eq 'AEXTLOT'
                     or mneum eq 'DATAPROD'
                     or mneum eq 'DATAVENC'
                     or mneum eq 'ATVLR'
                     or mneum eq 'ATTLOT'
                     or mneum eq 'ATITMXML'
                     or mneum eq 'ATITMPED'
                     or mneum eq 'ATQTDE'
                     or mneum eq 'ATVCOFINS'
                     or mneum eq 'ATVCOFINSS'
                     or mneum eq 'ATCRICMSST'
                     or mneum eq 'ATDESC'
                     or mneum eq 'ATFRT'
                     or mneum eq 'ATVICMS'
                     or mneum eq 'ATVICMSST'
                     or mneum eq 'ATICMSSDES'
                     or mneum eq 'ATICMSSRET'
                     or mneum eq 'ATVII'
                     or mneum eq 'ATVIOF'
                     or mneum eq 'ATVIPI'
                     or mneum eq 'ATVISSQN'
                     or mneum eq 'ATDESPAC'
                     or mneum eq 'ATVPIS'
                     or mneum eq 'ATVPISST'
                     or mneum eq 'ATVLR'
                     or mneum eq 'ATSEG'
                     or mneum eq 'NCM'
                     or mneum eq 'ATPED'
                     or mneum eq 'MATDOC'
                     or mneum eq 'FISCALYEAR'
                     or mneum eq 'MATDOCYEA'
                     or mneum = 'ACTIVITY'
                     or mneum = 'ASSETNO'
                     or mneum = 'BUDGPERIOD'
                     or mneum = 'BUSAREA'
                     or mneum = 'CMMTITEM'
                     or mneum = 'CMMTITMLON'
                     or mneum = 'COAREA'
                     or mneum = 'COSTCENTER'
                     or mneum = 'COSTCTR'
                     or mneum = 'COSTOBJ'
                     or mneum = 'CUSTOMER'
                     or mneum = 'DELIVITEM'
                     or mneum = 'DELIVNUMB'
                     or mneum = 'DISTRPERC'
                     or mneum = 'ENRYUOMISO'
                     or mneum = 'FUNAREALON'
                     or mneum = 'FUNCAREA'
                     or mneum = 'FUND'
                     or mneum = 'FUNDSCTR'
                     or mneum = 'FUNDSRES'
                     or mneum = 'GLACCOUNT'
                     or mneum = 'GLACCT'
                     or mneum = 'GRANTNBR'
                     or mneum = 'GRRCPT'
                     or mneum = 'MATDOCYEA'
                     or mneum = 'MATERIAL'
                     or mneum = 'MATLGROUP'
                     or mneum = 'MATLUSAGE'
                     or mneum = 'MATORIGIN'
                     or mneum = 'MVTIND'
                     or mneum = 'NBSLIPS'
                     or mneum = 'NETPRICE'
                     or mneum = 'NETWORK'
                     or mneum = 'ORDERID'
                     or mneum = 'ORDERNO'
                     or mneum = 'PARTACCT'
                     or mneum = 'PLANT'
                     or mneum = 'PROFITCTR'
                     or mneum = 'PROFSEGM'
                     or mneum = 'PROFSEGMNO'
                     or mneum = 'PROJEXT'
                     or mneum = 'QUANTITY'
                     or mneum = 'RECIND'
                     or mneum = 'REFDATE'
                     or mneum = 'RESITEM'
                     or mneum = 'RLESTKEY'
                     or mneum = 'ROUTINGNO'
                     or mneum = 'SCHEDLINE'
                     or mneum = 'SDDOC'
                     or mneum = 'SDOCITEM'
                     or mneum = 'SERIALNO'
                     or mneum = 'STGELOC'
                     or mneum = 'SUBNUMBER'
                     or mneum = 'TAXCODE'
                     or mneum = 'TAXJURCODE'
                     or mneum = 'TOCOSTCTR'
                     or mneum = 'TOORDER'
                     or mneum = 'TOPROJECT'
                     or mneum = 'VALTYPE'
                     or mneum = 'VENDOR'
                     or mneum = 'WBSELEM'
                     or mneum = 'WBSELEME' ).
*** Fim Inclusão David Rosin
      else.
        delete t_docmn  where chave eq wa_itmatr-chave
                   and dcitm eq wa_itmatr_ax-dcitm
                   and ( mneum eq 'ATQTD'
                    or mneum eq 'ATUM'
                    or mneum eq 'ATPED'
                    or mneum eq 'ATITMPED'
                    or mneum eq 'ATITMXML'
                    or mneum eq 'ATITMPROC'
                    or mneum eq 'XMLNCM'
                    or mneum eq 'ATVLR'
                    or mneum eq 'AEXTLOT'
                    or mneum eq 'DATAPROD'
                    or mneum eq 'DATAVENC'
                    or mneum eq 'ATTLOT'
                    or mneum eq 'ATITMXML'
                    or mneum eq 'ATITMPED'
                    or mneum eq 'ATQTDE'
                    or mneum eq 'ATVCOFINS'
                    or mneum eq 'ATVCOFINSS'
                    or mneum eq 'ATCRICMSST'
                    or mneum eq 'ATDESC'
                    or mneum eq 'ATFRT'
                    or mneum eq 'ATVICMS'
                    or mneum eq 'ATVICMSST'
                    or mneum eq 'ATICMSSDES'
                    or mneum eq 'ATICMSSRET'
                    or mneum eq 'ATVII'
                    or mneum eq 'ATVIOF'
                    or mneum eq 'ATVIPI'
                    or mneum eq 'ATVISSQN'
                    or mneum eq 'ATDESPAC'
                    or mneum eq 'ATVPIS'
                    or mneum eq 'ATVPISST'
                    or mneum eq 'ATVLR'
                    or mneum eq 'ATSEG'
                    or mneum eq 'NCM'
                    or mneum eq 'ATPED'
                    or mneum eq 'MATDOC'
                    or mneum eq 'FISCALYEAR'
                    or mneum eq 'MATDOCYEA'
                    or mneum = 'ACTIVITY'
                    or mneum = 'ASSETNO'
                    or mneum = 'BUDGPERIOD'
                    or mneum = 'BUSAREA'
                    or mneum = 'CMMTITEM'
                    or mneum = 'CMMTITMLON'
                    or mneum = 'COAREA'
                    or mneum = 'COSTCENTER'
                    or mneum = 'COSTCTR'
                    or mneum = 'COSTOBJ'
                    or mneum = 'CUSTOMER'
                    or mneum = 'DELIVITEM'
                    or mneum = 'DELIVNUMB'
                    or mneum = 'DISTRPERC'
                    or mneum = 'ENRYUOMISO'
                    or mneum = 'FUNAREALON'
                    or mneum = 'FUNCAREA'
                    or mneum = 'FUND'
                    or mneum = 'FUNDSCTR'
                    or mneum = 'FUNDSRES'
                    or mneum = 'GLACCOUNT'
                    or mneum = 'GLACCT'
                    or mneum = 'GRANTNBR'
                    or mneum = 'GRRCPT'
                    or mneum = 'MATDOCYEA'
                    or mneum = 'MATERIAL'
                    or mneum = 'MATLGROUP'
                    or mneum = 'MATLUSAGE'
                    or mneum = 'MATORIGIN'
                    or mneum = 'MVTIND'
                    or mneum = 'NBSLIPS'
                    or mneum = 'NETPRICE'
                    or mneum = 'NETWORK'
                    or mneum = 'ORDERID'
                    or mneum = 'ORDERNO'
                    or mneum = 'PARTACCT'
                    or mneum = 'PLANT'
                    or mneum = 'PROFITCTR'
                    or mneum = 'PROFSEGM'
                    or mneum = 'PROFSEGMNO'
                    or mneum = 'PROJEXT'
                    or mneum = 'QUANTITY'
                    or mneum = 'RECIND'
                    or mneum = 'REFDATE'
                    or mneum = 'RESITEM'
                    or mneum = 'RLESTKEY'
                    or mneum = 'ROUTINGNO'
                    or mneum = 'SCHEDLINE'
                    or mneum = 'SDDOC'
                    or mneum = 'SDOCITEM'
                    or mneum = 'SERIALNO'
                    or mneum = 'STGELOC'
                    or mneum = 'SUBNUMBER'
                    or mneum = 'TAXCODE'
                    or mneum = 'TAXJURCODE'
                    or mneum = 'TOCOSTCTR'
                    or mneum = 'TOORDER'
                    or mneum = 'TOPROJECT'
                    or mneum = 'VALTYPE'
                    or mneum = 'VENDOR'
                    or mneum = 'WBSELEM'
                    or mneum = 'WBSELEME' ).
      endif.

**    Gerar Mneumonicos com base na atribuição feita
      perform f_nextseq_mneum changing vl_seqnr.

**    Percorre Items
      loop at t_itmatr_ax into wa_itmatr_ax.

**      Ponteiro ITMDOC
        read table t_itmdoc into wa_itmdoc with key chave = wa_itmatr_ax-chave
                                                    dcitm = wa_itmatr_ax-dcitm.

**      definir Ultimo
        clear vl_last.
        at last.
          vl_last = 'X'.
        endat.



* Quantidade final
        clear wa_docmn.
        vl_seqnr = vl_seqnr + 1.
        wa_docmn-chave = wa_itmatr-chave.
        wa_docmn-seqnr = vl_seqnr.
        wa_docmn-mneum = 'ATQTD'.
        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
        wa_docmn-atitm = wa_itmatr_ax-atitm.
        wa_docmn-value = wa_itmatr_ax-atqtd.
        condense wa_docmn-value no-gaps.
        append wa_docmn to t_docmn.

*Unidade final
        clear wa_docmn.
        vl_seqnr = vl_seqnr + 1.
        wa_docmn-chave = wa_itmatr-chave.
        wa_docmn-seqnr = vl_seqnr.
        wa_docmn-mneum = 'ATUM'.
        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
        wa_docmn-atitm = wa_itmatr_ax-atitm.
        wa_docmn-value = wa_itmatr_ax-atunm.
        condense wa_docmn-value no-gaps.
        append wa_docmn to t_docmn.

*
*        CASE WA_ITMATR_AX-TDSRF.
*          WHEN '1'. " Pedido de compra

*           Documento Referencia
        clear wa_docmn.
        vl_seqnr = vl_seqnr + 1.
        wa_docmn-chave = wa_itmatr-chave.
        wa_docmn-seqnr = vl_seqnr.
        wa_docmn-mneum = 'ATPED'.
        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
        wa_docmn-atitm = wa_itmatr_ax-atitm.

        if wa_itmatr_ax-nrsrf is not initial.
          clear lv_po.
          move wa_itmatr_ax-nrsrf to lv_po.
          call function 'CONVERSION_EXIT_ALPHA_INPUT'
            exporting
              input  = lv_po
            importing
              output = lv_po.
          clear wa_itmatr_ax-nrsrf.
          move lv_po to wa_itmatr_ax-nrsrf.
        endif.

        wa_docmn-value = wa_itmatr_ax-nrsrf.
        condense wa_docmn-value no-gaps.
        append wa_docmn to t_docmn.

*           Item Documento referencia
        clear wa_docmn.
        vl_seqnr = vl_seqnr + 1.
        wa_docmn-chave = wa_itmatr-chave.
        wa_docmn-seqnr = vl_seqnr.
        wa_docmn-mneum = 'ATITMPED'.
        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
        wa_docmn-atitm = wa_itmatr_ax-atitm.
        wa_docmn-value = wa_itmatr_ax-itsrf.
        condense wa_docmn-value no-gaps.
        append wa_docmn to t_docmn.

*          WHEN OTHERS.
*        ENDCASE.



*Item do XML
        clear wa_docmn.
        vl_seqnr = vl_seqnr + 1.
        wa_docmn-chave = wa_itmatr-chave.
        wa_docmn-seqnr = vl_seqnr.
        wa_docmn-mneum = 'ATITMXML'.
        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
        wa_docmn-atitm = wa_itmatr_ax-atitm.
        wa_docmn-value = wa_itmatr_ax-dcitm.
        condense wa_docmn-value no-gaps.
        append wa_docmn to t_docmn.


*Item para processamento
        clear wa_docmn.
        vl_seqnr       = vl_seqnr + 1.
        wa_docmn-chave = wa_itmatr-chave.
        wa_docmn-seqnr = vl_seqnr.
        wa_docmn-mneum = 'ATITMPROC'.
        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
        wa_docmn-atitm = wa_itmatr_ax-atitm.
        wa_docmn-value = wa_itmatr_ax-atitm.
        condense wa_docmn-value no-gaps.
        append wa_docmn to t_docmn.


*valor do item
        clear wa_docmn.
        vl_seqnr = vl_seqnr + 1.
        wa_docmn-chave = wa_itmatr-chave.
        wa_docmn-seqnr = vl_seqnr.
        wa_docmn-mneum = 'ATVLR'.
        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
        wa_docmn-atitm = wa_itmatr_ax-atitm.
        wa_docmn-value = wa_itmatr_ax-atprc.
        condense wa_docmn-value no-gaps.
        append wa_docmn to t_docmn.

        if not wa_itmatr_ax-ncm is initial and not vg_just_ok is initial..
* Quantidade final
          clear wa_docmn.
          vl_seqnr = vl_seqnr + 1.
          wa_docmn-chave = wa_itmatr-chave.
          wa_docmn-seqnr = vl_seqnr.
          wa_docmn-mneum = 'XMLNCM'.
          wa_docmn-dcitm = wa_itmatr_ax-dcitm.
          wa_docmn-atitm = wa_itmatr_ax-atitm.
          wa_docmn-value = wa_itmatr_ax-ncm.
          condense wa_docmn-value no-gaps.
          append wa_docmn to t_docmn.
        endif.

* Lote
        clear wa_docmn.
        vl_seqnr = vl_seqnr + 1.
        wa_docmn-chave = wa_itmatr-chave.
        wa_docmn-seqnr = vl_seqnr.
        wa_docmn-mneum = 'ATTLOT'.
        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
        wa_docmn-atitm = wa_itmatr_ax-atitm.
        wa_docmn-value = wa_itmatr_ax-atlot.
        condense wa_docmn-value no-gaps.
        append wa_docmn to t_docmn.

        clear wa_docmn.
        vl_seqnr = vl_seqnr + 1.
        wa_docmn-chave = wa_itmatr-chave.
        wa_docmn-seqnr = vl_seqnr.
        wa_docmn-mneum = 'AEXTLOT'.
        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
        wa_docmn-atitm = wa_itmatr_ax-atitm.
        wa_docmn-value = wa_itmatr_ax-exlot.
        condense wa_docmn-value no-gaps.
        append wa_docmn to t_docmn.

        clear wa_docmn.
        vl_seqnr = vl_seqnr + 1.
        wa_docmn-chave = wa_itmatr-chave.
        wa_docmn-seqnr = vl_seqnr.
        wa_docmn-mneum = 'DATAPROD'.
        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
        wa_docmn-atitm = wa_itmatr_ax-atitm.
        wa_docmn-value = wa_itmatr_ax-data_prod.
        condense wa_docmn-value no-gaps.
        append wa_docmn to t_docmn.

        clear wa_docmn.
        vl_seqnr = vl_seqnr + 1.
        wa_docmn-chave = wa_itmatr-chave.
        wa_docmn-seqnr = vl_seqnr.
        wa_docmn-mneum = 'DATAVENC'.
        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
        wa_docmn-atitm = wa_itmatr_ax-atitm.
        wa_docmn-value = wa_itmatr_ax-data_venc.
        condense wa_docmn-value no-gaps.
        append wa_docmn to t_docmn.

**      Percorre Mneumônicos de valores a serem gerados pela Atribuição
        loop at t_mneuatr into wa_mneuatr.


**        Busca mneumonico de origem para geração do mneumonico de atribuição
          read table t_docmn_rep into wa_docmn_ax with key mneum = wa_mneuatr-mnorg
                                                       dcitm = wa_itmatr_ax-dcitm.

**        Verifica se existe mneumonico de origem
          check sy-subrc is initial.

          if wa_docmn_ax-mneum eq 'NITEMPED'.
            if wa_docmn_ax-value ne wa_itmatr_ax-itsrf.
              continue.
            endif.
          endif.

* Apaga atribuição anterior
          delete from zhms_tb_docmn
           where chave eq wa_itmatr-chave
             and dcitm eq wa_itmatr_ax-dcitm
             and mneum eq wa_mneuatr-mndst.

          commit work and wait.

**        Transfere valores
          clear wa_docmn.
          vl_seqnr = vl_seqnr + 1.
          wa_docmn-chave = wa_itmatr-chave.
          wa_docmn-seqnr = vl_seqnr.
          wa_docmn-mneum = wa_mneuatr-mndst.
          wa_docmn-dcitm = wa_itmatr_ax-dcitm.
          wa_docmn-atitm = wa_itmatr_ax-atitm.

**        Cálculos de proporção para distribuição
          if wa_mneuatr-mnorg ne 'NITEMPED'.
            perform f_calcula_proporcao using wa_docmn_ax-value wa_itmdoc-dcqtd wa_itmatr_ax-atqtd vl_last wa_docmn-mneum
                                     changing wa_docmn-value.
          else.
            move wa_docmn_ax-value to wa_docmn-value.
          endif.
          if wa_mneuatr-mnorg eq 'NCM' or wa_mneuatr-mnorg eq 'XMLNCM'.
            move wa_docmn_ax-value to wa_docmn-value.
          endif.
          condense wa_docmn-value no-gaps.
          append wa_docmn to t_docmn.
        endloop.

      endloop.

      sort t_docmn ascending by mneum dcitm atitm seqnr.
      delete adjacent duplicates from t_docmn comparing mneum dcitm atitm.

**     Corrige os zeros a esquera
      loop at t_docmn into wa_docmn.
        call function 'CONVERSION_EXIT_ALPHA_INPUT'
          exporting
            input  = wa_docmn-seqnr
          importing
            output = wa_docmn-seqnr.
        modify t_docmn from wa_docmn index sy-tabix.
      endloop.

**    Insere/Modifica dados no repositorio de mneumonicos
*      INSERT zhms_tb_docmn FROM TABLE t_docmn.
      modify zhms_tb_docmn from table t_docmn.
      commit work and wait.

**    Executa regras identificação de cenário
      clear wl_docum.
      wl_docum-dctyp = 'CHAVE'.
      wl_docum-dcnro = wa_cabdoc-chave.
      append wl_docum to tl_docum.

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
      append wl_logdoc to tl_logdoc.

      call function 'ZHMS_FM_REGLOG'
        exporting
          cabdoc = wa_cabdoc
          flwst  = 'M'
          tpprm  = 4
        tables
          logdoc = tl_logdoc.

**    Limpa as estruturas de atribução
      clear: wa_itmatr_ax.
      refresh: t_itmatr_ax.

**    Seta tela inicial
      vg_0500 = '0501'.

**    Exibe mensagem de sucesso
      message s052.
      refresh t_itmatr_ax.
      clear: t_itmatr_ax, vg_atprp.
      leave to screen 0500.

    endform.                    " F_ATR_GRAVAR

*&---------------------------------------------------------------------*
*&      Form  F_ATR_VALIDAR
*&---------------------------------------------------------------------*
*       Validar atribuição
*----------------------------------------------------------------------*
    form f_atr_valida  changing p_vl_erro.
      data: vl_tot_atprc type zhms_de_atprc,
            vl_tot_atqtd type zhms_de_atqtd.

      data: wl_ekko   type ekko.
      data: vl_mwskz  type ekpo-mwskz. "RRO 04/02/2019
      data: vl_matorg type ekpo-j_1bmatorg. "RRO 05/02/2019

**    Verifica se foi inserido algum registro na tabela de atribuição
      if t_itmatr_ax is initial.
        p_vl_erro = 'X'.
      endif.

**    Verifica se algum erro foi encontrado
      check p_vl_erro is initial.

**    Identifica se os campos foram preenchidos
      if vg_tdsrf is initial.
        p_vl_erro = 'X'.
        message i053 .
      endif.

**    Verificação na estrutura
      loop at t_itmatr_ax into wa_itmatr_ax.
        "Verifica se o numero de documento sap de referencia foi informado
        if wa_itmatr_ax-nrsrf eq 0.
          check p_vl_erro is initial.
          p_vl_erro = 'X'.
          message i054 .
        endif.

        "Verifica se o numero de documento sap de referencia foi informado
        if wa_itmatr_ax-itsrf eq 0.
          check p_vl_erro is initial.
          p_vl_erro = 'X'.
          message i055 .
        endif.

*       Verifica se algum erro foi encontrado
        check p_vl_erro is initial.

        if vg_tdsrf eq 1. "Verifica se o pedido é válido
          clear wl_ekko.

          call function 'CONVERSION_EXIT_ALPHA_OUTPUT'
            exporting
              input  = wa_itmatr_ax-nrsrf
            importing
              output = wa_itmatr_ax-nrsrf.

          move wa_itmatr_ax-nrsrf to wl_ekko-ebeln.

          call function 'CONVERSION_EXIT_ALPHA_INPUT'
            exporting
              input  = wl_ekko-ebeln
            importing
              output = wl_ekko-ebeln.

***RRO 04/02/2019 -->>
**Verifica se tem IVA cadastrado para o PO
          clear: vl_mwskz, vl_matorg.
          select single mwskz j_1bmatorg
            into (vl_mwskz, vl_matorg)
            from ekpo
           where ebeln eq wl_ekko-ebeln
             and ebelp eq wa_itmatr_ax-itsrf.

          if vl_mwskz is initial.
            p_vl_erro = 'X'.
            message i068 with wl_ekko-ebeln.
            exit.
          endif.
***RRO 04/02/2019 <<--

***RRO 05/02/2019 -->>
***Valida Origem de Material entre XML e PO
          if t_docmn[] is not initial.
            clear wa_docmn.
            read table t_docmn into wa_docmn with key chave = wa_itmatr_ax-chave
                                                      mneum = 'ORIGICMS'
                                                      dcitm = wa_itmatr_ax-dcitm.
            if sy-subrc is initial.
              if wa_docmn-value ne vl_matorg.
                p_vl_erro = 'X'.
                message i069.
                exit.
              endif.
            endif.
          endif.
***RRO 05/02/2019 <<--

**        Busca na tabela
          select single *
            into wl_ekko
            from ekko
           where ebeln eq wl_ekko-ebeln.

**        Verifica se existe registro
          if not sy-subrc is initial.
            p_vl_erro = 'X'.
            message i056 with wl_ekko-ebeln.
          endif.

**        Verifica se algum erro foi encontrado
          check p_vl_erro is initial.
**        Verifica se o pedido é correspondente ao fornecedor do documento

***RRO 12/03/2019 -->>
          if wa_cabdoc-parid is initial.
            select single lifnr from lfa1
              into wa_cabdoc-parid
              where lifnr ne space
                and stcd1 eq wa_itmatr_ax-chave+6(14).
          endif.
***RRO 12/03/2019 <<--

          if wl_ekko-lifnr ne wa_cabdoc-parid.
            p_vl_erro = 'X'.
            message i057 with wl_ekko-lifnr wl_ekko-ebeln wa_cabdoc-parid.
          endif.

        endif.
*      ENDLOOP.

**    Verifica se algum erro foi encontrado
        check p_vl_erro is initial.
        check vg_typed ne 'CFE'.

**    Caso a atribuição proporcional esteja ativada não é necessário realizar contas
        if not vg_atprp eq 'X'.
*      IF NOT vg_atprp EQ 'X' AND vg_typed NE 'CFE'.
**      Limpa variaveis de totais para iniciar somas
          clear: vl_tot_atprc, vl_tot_atqtd.

          loop at t_itmatr_ax into wa_itmatr_ax.
**        Quantidades
            vl_tot_atqtd = vl_tot_atqtd + wa_itmatr_ax-atqtd.
**        Preço
            vl_tot_atprc = vl_tot_atprc + wa_itmatr_ax-atprc.
          endloop.

**      Verifica Quantidades
          if vl_tot_atqtd ne wa_itmdoc_ax-dcqtd.
**        Exibe mensagem  e registra o erro
            p_vl_erro = 'X'.
            message i050 with wa_itmdoc_ax-dcqtd vl_tot_atqtd.
          endif.

**      Verifica Valores
          if vl_tot_atprc ne wa_itmdoc_ax-dcprc.
**        Exibe mensagem  e registra o erro
            p_vl_erro = 'X'.
            message i051 with wa_itmdoc_ax-dcprc vl_tot_atprc.
          endif.
        endif.

        if sy-tcode = 'ZHMS_MONITOR'.
          read table t_show_po into wa_show_po with key ebeln = wa_itmatr_ax-nrsrf
                                                        ebelp = wa_itmatr_ax-itsrf.
          if sy-subrc <> 0 and p_vl_erro is initial.
            p_vl_erro = 'X'.
            message i068 with wl_ekko-ebeln.
          endif.
        endif.
      endloop.

*      Verifica se algum erro foi encontrado
      check p_vl_erro is initial.

**    Caso a atribuição proporcional esteja ativada não é necessário realizar contas
      if not vg_atprp eq 'X'.
*      Limpa variaveis de totais para iniciar somas
        clear: vl_tot_atprc, vl_tot_atqtd.

        loop at t_itmatr_ax into wa_itmatr_ax.
**        Quantidades
          vl_tot_atqtd = vl_tot_atqtd + wa_itmatr_ax-atqtd.
**        Preço
          vl_tot_atprc = vl_tot_atprc + wa_itmatr_ax-atprc.
        endloop.

        if wa_cabdoc-typed ne 'CTE'.
**      Verifica Quantidades
          if wa_cabdoc-typed ne 'NFSE1'.
            if vl_tot_atqtd ne wa_itmdoc_ax-dcqtd.
**        Exibe mensagem  e registra o erro
              p_vl_erro = 'X'.
              message i050 with wa_itmdoc_ax-dcqtd vl_tot_atqtd.
            endif.
          endif.

**      Verifica Valores
**      Renan Itokazo - 08.08.2018 | 21.11.2018
**      Não validar valores para NFSe e importação
          if wa_cabdoc-typed ne 'NFSE1' and wa_cabdoc-typed ne 'NFE3'.
            if vl_tot_atprc ne wa_itmdoc_ax-dcprc.
**        Exibe mensagem  e registra o erro
              p_vl_erro = 'X'.
              message i051 with wa_itmdoc_ax-dcprc vl_tot_atprc.
            endif.
          endif.
        endif.
      endif.

    endform.                    " F_ATR_VALIDAR

*&---------------------------------------------------------------------*
*&      Form  f_atr_proporcional
*&---------------------------------------------------------------------*
*       Calculos realizados caso atribuição proporcional esteja marcada
*----------------------------------------------------------------------*
    form f_atr_proporcional.
**    Verifica se ja foi digitado algum valor
      check not t_itmatr_ax[] is initial.
**    Realiza contas para atribuição proporcional
      data: vl_atr_atprc type zhms_de_atprc,
            vl_atr_atqtd type zhms_de_atqtd,
            vl_pre_atprc type zhms_de_atprc,
            vl_pre_atqtd type zhms_de_atqtd,
            vl_qtd_atr   type sy-tabix,
            vl_index     type sy-tabix.

*      IF T_DOCMN[] IS INITIAL.
      read table t_itmatr_ax into wa_itmatr_ax index 1.

      select *
        from zhms_tb_docmn
        into table t_docmn
*          WHERE CHAVE EQ WA_ITMATR_AX-CHAVE.
        where chave eq wa_cabdoc-chave.
*      ENDIF.

**    Inicio da conta: Identificar valor sem conversões
      "Quantidade de Linhas do split
      describe table t_itmatr_ax lines vl_qtd_atr.

**    Verifica se a atribuição é simples (1 linha) ou split (várias linhas)
      if vl_qtd_atr eq 1.
**      Modifica o valor da primeira linha
        read table t_itmatr_ax into wa_itmatr_ax index 1.
        wa_itmatr_ax-atprc = wa_itmdoc_ax-dcprc.
        if wa_itmatr_ax-atqtd is initial.
          wa_itmatr_ax-atqtd = wa_itmdoc_ax-dcqtd.
        endif.


        read table t_docmn into wa_docmn with key chave = wa_itmatr_ax-chave
                                                  dcitm = wa_itmatr_ax-dcitm
                                                  mneum = 'VUNCOM'.

        if sy-subrc is initial.
          read table t_docmn into wa_docmnx with key mneum = 'IDDEST'.
          if sy-subrc is initial and wa_docmnx-value eq '3'.

            call function 'CONVERSION_EXIT_ALPHA_OUTPUT'
              exporting
                input  = wa_itmatr_ax-nrsrf
              importing
                output = wa_itmatr_ax-nrsrf.

            select single netwr from ekpo into wa_itmatr_ax-atprc where ebeln = wa_itmatr_ax-nrsrf
                                                                    and ebelp = wa_itmatr_ax-itsrf.
          else.

            call function 'CONVERSION_EXIT_ALPHA_OUTPUT'
              exporting
                input  = wa_itmatr_ax-nrsrf
              importing
                output = wa_itmatr_ax-nrsrf.

            wa_itmatr_ax-atprc = wa_itmatr_ax-atqtd * wa_docmn-value.
          endif.

        endif.

        clear wa_docmn.
        read table t_docmn into wa_docmn with key chave = wa_itmatr_ax-chave
                                                  mneum = 'VTPREST'.
        if sy-subrc is initial.
          wa_itmatr_ax-atqtd = 1.
          wa_itmatr_ax-atprc = wa_docmn-value.
        endif.


        modify t_itmatr_ax from wa_itmatr_ax index 1.

      endif.

      check vl_qtd_atr gt 1.

**    Limpa as variáveis
      clear: vl_atr_atqtd, vl_atr_atprc.

      "Divisão do total pela quantidade de linhas
*      vl_pre_atprc = wa_itmdoc_ax-dcprc / vl_qtd_atr. "Valor
      if wa_itmdoc_ax-dcqtd is initial.
        vl_pre_atqtd = wa_itmdoc_ax-dcqtd / vl_qtd_atr. "Quantidades
      endif.

**    Percorre estrutura de atribuição
      loop at t_itmatr_ax into wa_itmatr_ax.
**      Manter o valor do indice em variável
        vl_index = sy-tabix.

**      Os itens terão os valores arredondados para baixo (exceto o ultimo)
**      Arrendodamento para baixo
        call function 'ROUND'
          exporting
            decimals      = 2
            input         = vl_pre_atprc
            sign          = '-'
          importing
            output        = wa_itmatr_ax-atprc
          exceptions
            input_invalid = 1
            overflow      = 2
            type_invalid  = 3
            others        = 4.

**      Quantidade encontrada
        if wa_itmatr_ax-atqtd is initial.
          wa_itmatr_ax-atqtd = vl_pre_atqtd.
        endif.

**      Mantem valores já distribuídos
        vl_atr_atqtd = vl_atr_atqtd + wa_itmatr_ax-atqtd.
        vl_atr_atprc = vl_atr_atprc + wa_itmatr_ax-atprc.

        read table t_docmn into wa_docmn with key chave = wa_itmatr_ax-chave
                                                  dcitm = wa_itmatr_ax-dcitm
                                                  mneum = 'VUNCOM'.

        if sy-subrc is initial.
          wa_itmatr_ax-atprc = wa_itmatr_ax-atqtd * wa_docmn-value.
        endif.

        call function 'CONVERSION_EXIT_ALPHA_OUTPUT'
          exporting
            input  = wa_itmatr_ax-nrsrf
          importing
            output = wa_itmatr_ax-nrsrf.

**      Insere os resultados na estrutura de atribução
        modify t_itmatr_ax from wa_itmatr_ax index vl_index.
      endloop.


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


    endform.                    "f_atr_proporcional

*&---------------------------------------------------------------------*
*&      Form  f_atr_completalista
*&---------------------------------------------------------------------*
*       Completa a lista de atribuição para exibição
*----------------------------------------------------------------------*
    form f_atr_completalista.

      data: vl_index    type sy-tabix,
            vl_seqnr    type zhms_de_seqnr,
            wl_ekpo     type ekpo,
            tl_ekpo_res type table of ekpo,
            tl_ekpo     type table of ekpo,
            vl_dcprc    type zhms_tb_itmdoc-dcprc.

      clear vl_seqnr.

      loop at t_itmatr_ax into wa_itmatr_ax .
        wa_itmatr_ax-chave = vg_chave.
        modify t_itmatr_ax from wa_itmatr_ax index sy-tabix.
      endloop.

**    Tratamento para tipos de documentos do SAP
      case vg_tdsrf.
        when 01. " Pedido de Compras
**        Cria uma tabela interna para pedidos de compra
          refresh tl_ekpo.
          loop at t_itmatr_ax into wa_itmatr_ax.
            vl_index = sy-tabix.
            clear wl_ekpo.

            call function 'CONVERSION_EXIT_ALPHA_OUTPUT'
              exporting
                input  = wa_itmatr_ax-nrsrf
              importing
                output = wa_itmatr_ax-nrsrf.

            move wa_itmatr_ax-nrsrf to wl_ekpo-ebeln.
            move wa_itmatr_ax-itsrf to wl_ekpo-ebelp.

            append wl_ekpo to tl_ekpo.
            modify t_itmatr_ax from wa_itmatr_ax index vl_index.
          endloop.

**        Seleciona dados na EKPO
          if tl_ekpo[] is not initial.
            refresh tl_ekpo_res[].
            select *
              into table tl_ekpo_res
              from ekpo
               for all entries in tl_ekpo
             where ebeln eq tl_ekpo-ebeln
               and ebelp eq tl_ekpo-ebelp.
          endif.

        when others.
      endcase.

**    Percorre estrutura de atribuição
      loop at t_itmatr_ax into wa_itmatr_ax.

        vl_dcprc = wa_itmdoc_ax-dcprc.

        select single *
          from zhms_tb_itmdoc
          into wa_itmdoc_ax
         where chave eq wa_itmatr_ax-chave
           and dcitm eq wa_itmatr_ax-dcitm.

        wa_itmdoc_ax-dcprc = vl_dcprc.

**      Manter o valor do indice em variável
        vl_index = sy-tabix.

**      Sequência numérica: Chave única
        add 1 to vl_seqnr.
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
        clear wl_ekpo.
        call function 'CONVERSION_EXIT_ALPHA_OUTPUT'
          exporting
            input  = wa_itmatr_ax-nrsrf
          importing
            output = wa_itmatr_ax-nrsrf.

        move wa_itmatr_ax-nrsrf to wl_ekpo-ebeln.
        move wa_itmatr_ax-itsrf to wl_ekpo-ebelp.

        read table tl_ekpo_res
              into wl_ekpo
          with key ebelp = wl_ekpo-ebelp
                   ebeln = wl_ekpo-ebeln.
        if sy-subrc is initial.
          wa_itmatr_ax-atmat = wl_ekpo-matnr.
          wa_itmatr_ax-atunm = wl_ekpo-meins.
        else.

          if wl_ekpo-ebelp is not initial and wl_ekpo-ebeln is not initial.

            call function 'CONVERSION_EXIT_ALPHA_INPUT'
              exporting
                input  = wl_ekpo-ebeln
              importing
                output = wl_ekpo-ebeln.

            call function 'CONVERSION_EXIT_ALPHA_INPUT'
              exporting
                input  = wl_ekpo-ebelp
              importing
                output = wl_ekpo-ebelp.

            select single matnr meins
              from ekpo
              into (wa_itmatr_ax-atmat, wa_itmatr_ax-atunm)
              where ebeln = wl_ekpo-ebeln
                and ebelp = wl_ekpo-ebelp.

          endif.
        endif.

**      Insere os resultados na estrutura de atribução
        modify t_itmatr_ax from wa_itmatr_ax index vl_index.

      endloop.
    endform.                    "f_atr_completalista
*&---------------------------------------------------------------------*
*&      Form  F_NEXTSEQ_MNEUM
*&---------------------------------------------------------------------*
*       recupera próximo seqnr para mneumonicos
*----------------------------------------------------------------------*
    form f_nextseq_mneum  changing p_vl_seqnr.
**    Variáveis locais
      data: tl_seqnr type table of zhms_de_seqnr,
            wl_seqnr type zhms_de_seqnr.

**    Seleção das sequencias
      select seqnr
        into table tl_seqnr
        from zhms_tb_docmn
       where chave eq wa_cabdoc-chave.

      if sy-subrc is not initial.
**    Seleção das sequencias
        select seqnr
          into table tl_seqnr
          from zhms_tb_docmn_hs
         where chave eq wa_cabdoc-chave.
      endif.

**    Identifica a ultima
      sort tl_seqnr descending.
      read table tl_seqnr into wl_seqnr index 1.

      p_vl_seqnr = wl_seqnr.

    endform.                    " F_NEXTSEQ_MNEUM

*&---------------------------------------------------------------------*
*&      Form  f_calcula_proporcao
*&---------------------------------------------------------------------*
*       Efetua os cálculos de proporção
*----------------------------------------------------------------------*
    form f_calcula_proporcao using p_antvlr p_antqtd p_newqtd p_last p_field
                          changing p_newvlr.
*    Variáveis Locais
      data: vl_indexbuff type sy-tabix,
            vl_newvlr    type zhms_de_usprc.

*    Busca dados ja atribuidos (soma)
      clear wa_atrbuffer.
      read table t_atrbuffer into wa_atrbuffer with key field = p_field.
      vl_indexbuff = sy-tabix.

*    Caso não seja o ultimo realiza a conta via regra de 3
      if p_last is initial.
        vl_newvlr = ( p_newqtd * p_antvlr ) / p_antqtd.
        move vl_newvlr to p_newvlr.

      else.
*    Caso seja o último realiza a conta via subtração do valor total
        vl_newvlr = p_antvlr - wa_atrbuffer-sumat.
        move vl_newvlr to p_newvlr.

      endif.

*     Mantem total armazenado
      if not vl_indexbuff is initial.
        wa_atrbuffer-sumat = wa_atrbuffer-sumat + vl_newvlr.
        modify t_atrbuffer from wa_atrbuffer index vl_indexbuff.
      else.
        wa_atrbuffer-field = p_field.
        wa_atrbuffer-sumat = vl_newvlr.
        append wa_atrbuffer to t_atrbuffer.
      endif.

    endform.                    "f_calcula_proporcao
*&---------------------------------------------------------------------*
*&      Form  F_ATR_AUTO_GRAVAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
    form f_atr_auto_gravar .
**    Variáveis locais
      data: vl_seqnr type zhms_de_seqnr,
*            vl_atitmproc TYPE i,
            vl_atitm type zhms_de_atitm,
            vl_last  type flag.

      data: tl_docum  type table of zhms_es_docum,
            wl_docum  type zhms_es_docum,
            tl_itmatr type table of zhms_tb_itmatr,
            wl_itmatr type zhms_tb_itmatr,
            tl_logdoc type table of zhms_tb_logdoc,
            wl_logdoc type zhms_tb_logdoc.
      refresh: t_atrbuffer.

      clear: vl_seqnr.
**    Seleciona o primeiro registro inserido
      read table t_itmatr_ax into wa_itmatr_ax index 1.

**    Verifica se existe o primeiro registro. Caso não a tabela está
*  vazia
      check sy-subrc is initial.

**    Deleta outras ocorrencias antes de gravar
      delete from zhms_tb_itmatr
       where natdc eq wa_itmatr_ax-natdc
         and typed eq wa_itmatr_ax-typed
         and loctp eq wa_itmatr_ax-loctp
         and chave eq wa_itmatr_ax-chave
         and dcitm eq wa_itmatr_ax-dcitm.
**    Garante a deleção
      commit work and wait.

**    Insere atribuição na tabela de atribuições.
      loop at t_itmatr_ax into wa_itmatr_ax.
        move-corresponding wa_itmatr_ax to wa_itmatr.

        insert into zhms_tb_itmatr values wa_itmatr.
      endloop.

**    Ajusta item de processamento
      select *
        into table tl_itmatr
        from zhms_tb_itmatr
       where natdc eq wa_itmatr_ax-natdc
         and typed eq wa_itmatr_ax-typed
         and loctp eq wa_itmatr_ax-loctp
         and chave eq wa_itmatr_ax-chave.

**    Ordenar
      sort tl_itmatr by dcitm ascending
                        atitm ascending.
      clear vl_atitm.

      loop at tl_itmatr into wl_itmatr.
        vl_atitm = vl_atitm + 1.
**      Atualizar tabela
        update zhms_tb_itmatr
           set atitm = vl_atitm
         where natdc eq wl_itmatr-natdc
           and typed eq wl_itmatr-typed
           and loctp eq wl_itmatr-loctp
           and chave eq wl_itmatr-chave
           and dcitm eq wl_itmatr-dcitm
           and seqnr eq wl_itmatr-seqnr.

        commit work and wait.

**      Atualizar tabela interna
        read table t_itmatr_ax
              into wa_itmatr_ax
          with key  natdc = wl_itmatr-natdc
                    typed = wl_itmatr-typed
                    loctp = wl_itmatr-loctp
                    chave = wl_itmatr-chave
                    dcitm = wl_itmatr-dcitm
                    seqnr = wl_itmatr-seqnr.
        if sy-subrc is initial.
          wa_itmatr_ax-atitm = vl_atitm.
          modify t_itmatr_ax from wa_itmatr_ax index sy-tabix.
        endif.
      endloop.


**    Buscar mneumonicos a serem gerados
      select *
        into table t_mneuatr
        from zhms_tb_mneuatr.

* Apaga atribuição anterior
      read table t_itmatr_ax into wa_itmatr_ax index 1.
      delete from zhms_tb_docmn
       where chave eq wa_itmatr-chave
         and dcitm eq wa_itmatr_ax-dcitm
         and ( mneum eq 'ATQTD'
            or mneum eq 'ATUM'
            or mneum eq 'ATPED'
            or mneum eq 'ATITMPED'
            or mneum eq 'ATITMXML'
            or mneum eq 'ATITMPROC'
            or mneum eq 'ATVLR' ).
      commit work and wait.

*** Inicio Inclusão David Rosin
*** Limpa mneumonicos da tabela interna
      delete t_docmn  where chave eq wa_itmatr-chave
               and dcitm eq wa_itmatr_ax-dcitm
               and ( mneum eq 'ATQTD'
                  or mneum eq 'ATUM'
                  or mneum eq 'ATPED'
                  or mneum eq 'ATITMPED'
                  or mneum eq 'ATITMXML'
                  or mneum eq 'ATITMPROC'
                  or mneum eq 'ATVLR' ).
*** Fim Inclusão David Rosin

**    Gerar Mneumonicos com base na atribuição feita
      perform f_nextseq_mneum changing vl_seqnr.

**    Percorre Items
      loop at t_itmatr_ax into wa_itmatr_ax.

**      Ponteiro ITMDOC
        read table t_itmdoc into wa_itmdoc with key chave =
    wa_itmatr_ax-chave
                                                    dcitm =
    wa_itmatr_ax-dcitm.

**      definir Ultimo
        clear vl_last.
        at last.
          vl_last = 'X'.
        endat.

* Quantidade final
        clear wa_docmn.
        vl_seqnr = vl_seqnr + 1.
        wa_docmn-chave = wa_itmatr-chave.
        wa_docmn-seqnr = vl_seqnr.
        wa_docmn-mneum = 'ATQTD'.
        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
        wa_docmn-atitm = wa_itmatr_ax-atitm.
        wa_docmn-value = wa_itmatr_ax-atqtd.
        condense wa_docmn-value no-gaps.
        append wa_docmn to t_docmn.

*Unidade final
        clear wa_docmn.
        vl_seqnr = vl_seqnr + 1.
        wa_docmn-chave = wa_itmatr-chave.
        wa_docmn-seqnr = vl_seqnr.
        wa_docmn-mneum = 'ATUM'.
        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
        wa_docmn-atitm = wa_itmatr_ax-atitm.
        wa_docmn-value = wa_itmatr_ax-atunm.
        condense wa_docmn-value no-gaps.
        append wa_docmn to t_docmn.

***
***        CASE wa_itmatr_ax-tdsrf.
***          WHEN '1'. " Pedido de compra

*           Documento Referencia
        clear wa_docmn.
        vl_seqnr = vl_seqnr + 1.
        wa_docmn-chave = wa_itmatr-chave.
        wa_docmn-seqnr = vl_seqnr.
        wa_docmn-mneum = 'ATPED'.
        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
        wa_docmn-atitm = wa_itmatr_ax-atitm.
        wa_docmn-value = wa_itmatr_ax-nrsrf.
        condense wa_docmn-value no-gaps.
        append wa_docmn to t_docmn.

*           Item Documento referencia
        clear wa_docmn.
        vl_seqnr = vl_seqnr + 1.
        wa_docmn-chave = wa_itmatr-chave.
        wa_docmn-seqnr = vl_seqnr.
        wa_docmn-mneum = 'ATITMPED'.
        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
        wa_docmn-atitm = wa_itmatr_ax-atitm.
        wa_docmn-value = wa_itmatr_ax-itsrf.
        condense wa_docmn-value no-gaps.
        append wa_docmn to t_docmn.

***          WHEN OTHERS.
***        ENDCASE.



*Item do XML
        clear wa_docmn.
        vl_seqnr = vl_seqnr + 1.
        wa_docmn-chave = wa_itmatr-chave.
        wa_docmn-seqnr = vl_seqnr.
        wa_docmn-mneum = 'ATITMXML'.
        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
        wa_docmn-atitm = wa_itmatr_ax-atitm.
        wa_docmn-value = wa_itmatr_ax-dcitm.
        condense wa_docmn-value no-gaps.
        append wa_docmn to t_docmn.


*Item para processamento
        clear wa_docmn.
        vl_seqnr       = vl_seqnr + 1.
        wa_docmn-chave = wa_itmatr-chave.
        wa_docmn-seqnr = vl_seqnr.
        wa_docmn-mneum = 'ATITMPROC'.
        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
        wa_docmn-atitm = wa_itmatr_ax-atitm.
        wa_docmn-value = wa_itmatr_ax-atitm.
        condense wa_docmn-value no-gaps.
        append wa_docmn to t_docmn.


*valor do item
        clear wa_docmn.
        vl_seqnr = vl_seqnr + 1.
        wa_docmn-chave = wa_itmatr-chave.
        wa_docmn-seqnr = vl_seqnr.
        wa_docmn-mneum = 'ATVLR'.
        wa_docmn-dcitm = wa_itmatr_ax-dcitm.
        wa_docmn-atitm = wa_itmatr_ax-atitm.
        wa_docmn-value = wa_itmatr_ax-atprc.
        condense wa_docmn-value no-gaps.
        append wa_docmn to t_docmn.

**      Percorre Mneumônicos de valores a serem gerados pela Atribuição
        loop at t_mneuatr into wa_mneuatr.


**        Busca mneumonico de origem para geração do mneumonico de
*      atribuição
          read table t_docmn_rep into wa_docmn_ax with key mneum =
    wa_mneuatr-mnorg
                                    dcitm = wa_itmatr_ax-dcitm.

**        Verifica se existe mneumonico de origem
          check sy-subrc is initial.

* Apaga atribuição anterior
          delete from zhms_tb_docmn
           where chave eq wa_itmatr-chave
             and dcitm eq wa_itmatr_ax-dcitm
             and mneum eq wa_mneuatr-mndst.

          commit work and wait.

**        Transfere valores
          clear wa_docmn.
          vl_seqnr = vl_seqnr + 1.
          wa_docmn-chave = wa_itmatr-chave.
          wa_docmn-seqnr = vl_seqnr.
          wa_docmn-mneum = wa_mneuatr-mndst.
          wa_docmn-dcitm = wa_itmatr_ax-dcitm.
          wa_docmn-atitm = wa_itmatr_ax-atitm.

**        Cálculos de proporção para distribuição
          perform f_calcula_proporcao using wa_docmn_ax-value
    wa_itmdoc-dcqtd wa_itmatr_ax-atqtd vl_last wa_docmn-mneum
                                   changing wa_docmn-value.
          condense wa_docmn-value no-gaps.
          append wa_docmn to t_docmn.
        endloop.

      endloop.

**     Corrige os zeros a esquera
      loop at t_docmn into wa_docmn.
        call function 'CONVERSION_EXIT_ALPHA_INPUT'
          exporting
            input  = wa_docmn-seqnr
          importing
            output = wa_docmn-seqnr.
        modify t_docmn from wa_docmn index sy-tabix.
      endloop.

**    Insere/Modifica dados no repositorio de mneumonicos
*      INSERT zhms_tb_docmn FROM TABLE t_docmn.
      modify zhms_tb_docmn from table t_docmn.
      commit work and wait.

**    Executa regras identificação de cenário
      clear wl_docum.
      wl_docum-dctyp = 'CHAVE'.
      wl_docum-dcnro = wa_cabdoc-chave.
      append wl_docum to tl_docum.


** Registra LOG
      wl_logdoc-logty = 'S'.
      wl_logdoc-logno = '500'.
      append wl_logdoc to tl_logdoc.

      call function 'ZHMS_FM_REGLOG'
        exporting
          cabdoc = wa_cabdoc
          flwst  = 'M'
          tpprm  = 4
        tables
          logdoc = tl_logdoc.

**    Limpa as estruturas de atribução
      clear: wa_itmatr_ax.
      refresh: t_itmatr_ax.

**    Seta tela inicial
      vg_0500 = '0501'.

**    Exibe mensagem de sucesso
      message s052.


    endform.                    " F_ATR_AUTO_GRAVAR
*&---------------------------------------------------------------------*
*&      Form  F_GRAVA_JUSTIFICATIVA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
    form f_grava_justificativa.

      check not ob_dcevt_obs is initial.

** Recupera o texto digitado no editor
      call method ob_dcevt_obs->get_text_as_r3table
        importing
          table = tl_textnote.

      clear vg_just_ok.
      if not tl_textnote[] is initial.

** Percorrer dados e inserir na variavel de observações
        tl_itxw_note[] = tl_textnote[].
        clear wa_just.
        loop at tl_itxw_note into wl_itxw_note.
          concatenate wa_just-just wl_itxw_note-line into wa_just-just
    separated by space.
        endloop.
        loop at t_itmatr_ax into wa_itmatr_ax where check eq 'X'.
          wa_just-chave = vg_chave.
          wa_just-item = wa_itmatr_ax-dcitm.
          wa_just-atitm = wa_itmatr_ax-atitm.

          modify zhms_tb_justific from wa_just.

          move 'X' to vg_just_ok.
        endloop.
      else.
        message e065.
      endif.

    endform.                    " F_GRAVA_JUSTIFICATIVA
*&---------------------------------------------------------------------*
*&      Form  F_ATR_GRAVAR_EXC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*Homine - Inicio da Inclusão - DD - Ajuste Atribuição
    form f_atr_gravar_exc .

**    Variáveis locais
      data: vl_seqnr type zhms_de_seqnr,
*            vl_atitmproc TYPE i,
            vl_atitm type zhms_de_atitm,
            vl_last  type flag,
            lv_po    type ebeln.

      data: tl_docum  type table of zhms_es_docum,
            wl_docum  type zhms_es_docum,
            tl_itmatr type table of zhms_tb_itmatr,
            wl_itmatr type zhms_tb_itmatr,
            tl_logdoc type table of zhms_tb_logdoc,
            wl_logdoc type zhms_tb_logdoc.
      refresh: t_atrbuffer.

      clear: vl_seqnr.
      loop at t_itmatr_ex into wa_itmatr_ex.
**    Deleta outras ocorrencias antes de gravar
        delete from zhms_tb_itmatr
         where natdc eq wa_itmatr_ex-natdc
           and typed eq wa_itmatr_ex-typed
           and loctp eq wa_itmatr_ex-loctp
           and chave eq wa_itmatr_ex-chave
           and dcitm eq wa_itmatr_ex-dcitm.
**    Garante a deleção
        commit work and wait.

        delete from zhms_tb_flwdoc
         where natdc eq wa_itmatr_ex-natdc
           and typed eq wa_itmatr_ex-typed
           and loctp eq wa_itmatr_ex-loctp
           and chave eq wa_itmatr_ex-chave.
**    Garante a deleção
        commit work and wait.
      endloop.

**    Buscar mneumonicos a serem gerados
      select *
        into table t_mneuatr
        from zhms_tb_mneuatr.

* Apaga atribuição anterior
      if vg_just_ok is initial.
        read table t_itmatr_ex into wa_itmatr_ex index 1.
        delete from zhms_tb_docmn
         where chave eq wa_itmatr-chave
           and dcitm eq wa_itmatr_ax-dcitm
           and ( mneum eq 'ATQTD'
              or mneum eq 'ATUM'
              or mneum eq 'ATPED'
              or mneum eq 'ATITMPED'
              or mneum eq 'ATITMXML'
              or mneum eq 'ATITMPROC'
*            OR mneum EQ 'XMLNCM'
              or mneum eq 'ATVLR'
              or mneum eq 'AEXTLOT'
              or mneum eq 'DATAPROD'
              or mneum eq 'DATAVENC'
              or mneum eq 'ATTLOT'
              or mneum eq 'ATITMXML'
              or mneum eq 'ATITMPED'
              or mneum eq 'ATQTDE'
              or mneum eq 'ATVCOFINS'
              or mneum eq 'ATVCOFINSS'
              or mneum eq 'ATCRICMSST'
              or mneum eq 'ATDESC'
              or mneum eq 'ATFRT'
              or mneum eq 'ATVICMS'
              or mneum eq 'ATVICMSST'
              or mneum eq 'ATICMSSDES'
              or mneum eq 'ATICMSSRET'
              or mneum eq 'ATVII'
              or mneum eq 'ATVIOF'
              or mneum eq 'ATVIPI'
              or mneum eq 'ATVISSQN'
              or mneum eq 'ATDESPAC'
              or mneum eq 'ATVPIS'
              or mneum eq 'ATVPISST'
              or mneum eq 'ATVLR'
              or mneum eq 'ATSEG'
              or mneum eq 'NCM'
              or mneum eq 'ATPED'
              or mneum eq 'MATDOC'
              or mneum eq 'FISCALYEAR'
              or mneum eq 'MATDOCYEA'
              or mneum = 'ACTIVITY'
              or mneum = 'ASSETNO'
              or mneum = 'BUDGPERIOD'
              or mneum = 'BUSAREA'
              or mneum = 'CMMTITEM'
              or mneum = 'CMMTITMLON'
              or mneum = 'COAREA'
              or mneum = 'COSTCENTER'
              or mneum = 'COSTCTR'
              or mneum = 'COSTOBJ'
              or mneum = 'CUSTOMER'
              or mneum = 'DELIVITEM'
              or mneum = 'DELIVNUMB'
              or mneum = 'DISTRPERC'
              or mneum = 'ENRYUOMISO'
              or mneum = 'FUNAREALON'
              or mneum = 'FUNCAREA'
              or mneum = 'FUND'
              or mneum = 'FUNDSCTR'
              or mneum = 'FUNDSRES'
              or mneum = 'GLACCOUNT'
              or mneum = 'GLACCT'
              or mneum = 'GRANTNBR'
              or mneum = 'GRRCPT'
              or mneum = 'MATDOCYEA'
              or mneum = 'MATERIAL'
              or mneum = 'MATLGROUP'
              or mneum = 'MATLUSAGE'
              or mneum = 'MATORIGIN'
              or mneum = 'MVTIND'
              or mneum = 'NBSLIPS'
              or mneum = 'NETPRICE'
              or mneum = 'NETWORK'
              or mneum = 'ORDERID'
              or mneum = 'ORDERNO'
              or mneum = 'PARTACCT'
              or mneum = 'PLANT'
              or mneum = 'PROFITCTR'
              or mneum = 'PROFSEGM'
              or mneum = 'PROFSEGMNO'
              or mneum = 'PROJEXT'
              or mneum = 'QUANTITY'
              or mneum = 'RECIND'
              or mneum = 'REFDATE'
              or mneum = 'RESITEM'
              or mneum = 'RLESTKEY'
              or mneum = 'ROUTINGNO'
              or mneum = 'SCHEDLINE'
              or mneum = 'SDDOC'
              or mneum = 'SDOCITEM'
              or mneum = 'SERIALNO'
              or mneum = 'STGELOC'
              or mneum = 'SUBNUMBER'
              or mneum = 'TAXCODE'
              or mneum = 'TAXJURCODE'
              or mneum = 'TOCOSTCTR'
              or mneum = 'TOORDER'
              or mneum = 'TOPROJECT'
              or mneum = 'VALTYPE'
              or mneum = 'VENDOR'
              or mneum = 'WBSELEM'
              or mneum = 'WBSELEME' ).
        commit work and wait.
      else.
*** Inicio Inclusão David Rosin
*** Limpa mneumonicos da tabela interna
        delete t_docmn  where chave eq wa_itmatr-chave
                  and dcitm eq wa_itmatr_ax-dcitm
                  and ( mneum eq 'ATQTD'
                   or mneum eq 'ATUM'
                   or mneum eq 'ATPED'
                   or mneum eq 'ATITMPED'
                   or mneum eq 'ATITMXML'
                   or mneum eq 'ATITMPROC'
                   or mneum eq 'ATVLR'
                   or mneum eq 'AEXTLOT'
                   or mneum eq 'DATAPROD'
                   or mneum eq 'DATAVENC'
                   or mneum eq 'XMLNCM'
                   or mneum eq 'ATTLOT'
                   or mneum eq 'ATITMXML'
                   or mneum eq 'ATITMPED'
                   or mneum eq 'ATQTDE'
                   or mneum eq 'ATVCOFINS'
                   or mneum eq 'ATVCOFINSS'
                   or mneum eq 'ATCRICMSST'
                   or mneum eq 'ATDESC'
                   or mneum eq 'ATFRT'
                   or mneum eq 'ATVICMS'
                   or mneum eq 'ATVICMSST'
                   or mneum eq 'ATICMSSDES'
                   or mneum eq 'ATICMSSRET'
                   or mneum eq 'ATVII'
                   or mneum eq 'ATVIOF'
                   or mneum eq 'ATVIPI'
                   or mneum eq 'ATVISSQN'
                   or mneum eq 'ATDESPAC'
                   or mneum eq 'ATVPIS'
                   or mneum eq 'ATVPISST'
                   or mneum eq 'ATVLR'
                   or mneum eq 'ATSEG'
                   or mneum eq 'NCM'
                   or mneum eq 'ATPED'
                   or mneum eq 'MATDOC'
                   or mneum eq 'FISCALYEAR'
                   or mneum eq 'MATDOCYEA'
                   or mneum = 'ACTIVITY'
                   or mneum = 'ASSETNO'
                   or mneum = 'BUDGPERIOD'
                   or mneum = 'BUSAREA'
                   or mneum = 'CMMTITEM'
                   or mneum = 'CMMTITMLON'
                   or mneum = 'COAREA'
                   or mneum = 'COSTCENTER'
                   or mneum = 'COSTCTR'
                   or mneum = 'COSTOBJ'
                   or mneum = 'CUSTOMER'
                   or mneum = 'DELIVITEM'
                   or mneum = 'DELIVNUMB'
                   or mneum = 'DISTRPERC'
                   or mneum = 'ENRYUOMISO'
                   or mneum = 'FUNAREALON'
                   or mneum = 'FUNCAREA'
                   or mneum = 'FUND'
                   or mneum = 'FUNDSCTR'
                   or mneum = 'FUNDSRES'
                   or mneum = 'GLACCOUNT'
                   or mneum = 'GLACCT'
                   or mneum = 'GRANTNBR'
                   or mneum = 'GRRCPT'
                   or mneum = 'MATDOCYEA'
                   or mneum = 'MATERIAL'
                   or mneum = 'MATLGROUP'
                   or mneum = 'MATLUSAGE'
                   or mneum = 'MATORIGIN'
                   or mneum = 'MVTIND'
                   or mneum = 'NBSLIPS'
                   or mneum = 'NETPRICE'
                   or mneum = 'NETWORK'
                   or mneum = 'ORDERID'
                   or mneum = 'ORDERNO'
                   or mneum = 'PARTACCT'
                   or mneum = 'PLANT'
                   or mneum = 'PROFITCTR'
                   or mneum = 'PROFSEGM'
                   or mneum = 'PROFSEGMNO'
                   or mneum = 'PROJEXT'
                   or mneum = 'QUANTITY'
                   or mneum = 'RECIND'
                   or mneum = 'REFDATE'
                   or mneum = 'RESITEM'
                   or mneum = 'RLESTKEY'
                   or mneum = 'ROUTINGNO'
                   or mneum = 'SCHEDLINE'
                   or mneum = 'SDDOC'
                   or mneum = 'SDOCITEM'
                   or mneum = 'SERIALNO'
                   or mneum = 'STGELOC'
                   or mneum = 'SUBNUMBER'
                   or mneum = 'TAXCODE'
                   or mneum = 'TAXJURCODE'
                   or mneum = 'TOCOSTCTR'
                   or mneum = 'TOORDER'
                   or mneum = 'TOPROJECT'
                   or mneum = 'VALTYPE'
                   or mneum = 'VENDOR'
                   or mneum = 'WBSELEM'
                   or mneum = 'WBSELEME').
*** Fim Inclusão David Rosin
      endif.

      if vg_just_ok is initial.
*** Inicio Inclusão David Rosin
*** Limpa mneumonicos da tabela interna
        delete t_docmn  where chave eq wa_itmatr-chave
                    and dcitm eq wa_itmatr_ex-dcitm
                    and ( mneum eq 'ATQTD'
                     or mneum eq 'ATQTDE'
                     or mneum eq 'ATUM'
                     or mneum eq 'ATPED'
                     or mneum eq 'ATITMPED'
                     or mneum eq 'ATITMXML'
                     or mneum eq 'ATITMPROC'
*              OR mneum EQ 'NCM'
                     or mneum eq 'AEXTLOT'
                     or mneum eq 'DATAPROD'
                     or mneum eq 'DATAVENC'
                     or mneum eq 'ATVLR'
                     or mneum eq 'ATTLOT'
                     or mneum eq 'ATITMXML'
                     or mneum eq 'ATITMPED'
                     or mneum eq 'ATQTDE'
                     or mneum eq 'ATVCOFINS'
                     or mneum eq 'ATVCOFINSS'
                     or mneum eq 'ATCRICMSST'
                     or mneum eq 'ATDESC'
                     or mneum eq 'ATFRT'
                     or mneum eq 'ATVICMS'
                     or mneum eq 'ATVICMSST'
                     or mneum eq 'ATICMSSDES'
                     or mneum eq 'ATICMSSRET'
                     or mneum eq 'ATVII'
                     or mneum eq 'ATVIOF'
                     or mneum eq 'ATVIPI'
                     or mneum eq 'ATVISSQN'
                     or mneum eq 'ATDESPAC'
                     or mneum eq 'ATVPIS'
                     or mneum eq 'ATVPISST'
                     or mneum eq 'ATVLR'
                     or mneum eq 'ATSEG'
                     or mneum eq 'NCM'
                     or mneum eq 'ATPED'
                     or mneum eq 'MATDOC'
                     or mneum eq 'FISCALYEAR'
                     or mneum eq 'MATDOCYEA'
                     or mneum = 'ACTIVITY'
                     or mneum = 'ASSETNO'
                     or mneum = 'BUDGPERIOD'
                     or mneum = 'BUSAREA'
                     or mneum = 'CMMTITEM'
                     or mneum = 'CMMTITMLON'
                     or mneum = 'COAREA'
                     or mneum = 'COSTCENTER'
                     or mneum = 'COSTCTR'
                     or mneum = 'COSTOBJ'
                     or mneum = 'CUSTOMER'
                     or mneum = 'DELIVITEM'
                     or mneum = 'DELIVNUMB'
                     or mneum = 'DISTRPERC'
                     or mneum = 'ENRYUOMISO'
                     or mneum = 'FUNAREALON'
                     or mneum = 'FUNCAREA'
                     or mneum = 'FUND'
                     or mneum = 'FUNDSCTR'
                     or mneum = 'FUNDSRES'
                     or mneum = 'GLACCOUNT'
                     or mneum = 'GLACCT'
                     or mneum = 'GRANTNBR'
                     or mneum = 'GRRCPT'
                     or mneum = 'MATDOCYEA'
                     or mneum = 'MATERIAL'
                     or mneum = 'MATLGROUP'
                     or mneum = 'MATLUSAGE'
                     or mneum = 'MATORIGIN'
                     or mneum = 'MVTIND'
                     or mneum = 'NBSLIPS'
                     or mneum = 'NETPRICE'
                     or mneum = 'NETWORK'
                     or mneum = 'ORDERID'
                     or mneum = 'ORDERNO'
                     or mneum = 'PARTACCT'
                     or mneum = 'PLANT'
                     or mneum = 'PROFITCTR'
                     or mneum = 'PROFSEGM'
                     or mneum = 'PROFSEGMNO'
                     or mneum = 'PROJEXT'
                     or mneum = 'QUANTITY'
                     or mneum = 'RECIND'
                     or mneum = 'REFDATE'
                     or mneum = 'RESITEM'
                     or mneum = 'RLESTKEY'
                     or mneum = 'ROUTINGNO'
                     or mneum = 'SCHEDLINE'
                     or mneum = 'SDDOC'
                     or mneum = 'SDOCITEM'
                     or mneum = 'SERIALNO'
                     or mneum = 'STGELOC'
                     or mneum = 'SUBNUMBER'
                     or mneum = 'TAXCODE'
                     or mneum = 'TAXJURCODE'
                     or mneum = 'TOCOSTCTR'
                     or mneum = 'TOORDER'
                     or mneum = 'TOPROJECT'
                     or mneum = 'VALTYPE'
                     or mneum = 'VENDOR'
                     or mneum = 'WBSELEM'
                     or mneum = 'WBSELEME' ).
*** Fim Inclusão David Rosin
      else.
        delete t_docmn  where chave eq wa_itmatr-chave
                   and dcitm eq wa_itmatr_ex-dcitm
                   and ( mneum eq 'ATQTD'
                    or mneum eq 'ATUM'
                    or mneum eq 'ATPED'
                    or mneum eq 'ATITMPED'
                    or mneum eq 'ATITMXML'
                    or mneum eq 'ATITMPROC'
                    or mneum eq 'XMLNCM'
                    or mneum eq 'ATVLR'
                    or mneum eq 'AEXTLOT'
                    or mneum eq 'DATAPROD'
                    or mneum eq 'DATAVENC'
                    or mneum eq 'ATTLOT'
                    or mneum eq 'ATITMXML'
                    or mneum eq 'ATITMPED'
                    or mneum eq 'ATQTDE'
                    or mneum eq 'ATVCOFINS'
                    or mneum eq 'ATVCOFINSS'
                    or mneum eq 'ATCRICMSST'
                    or mneum eq 'ATDESC'
                    or mneum eq 'ATFRT'
                    or mneum eq 'ATVICMS'
                    or mneum eq 'ATVICMSST'
                    or mneum eq 'ATICMSSDES'
                    or mneum eq 'ATICMSSRET'
                    or mneum eq 'ATVII'
                    or mneum eq 'ATVIOF'
                    or mneum eq 'ATVIPI'
                    or mneum eq 'ATVISSQN'
                    or mneum eq 'ATDESPAC'
                    or mneum eq 'ATVPIS'
                    or mneum eq 'ATVPISST'
                    or mneum eq 'ATVLR'
                    or mneum eq 'ATSEG'
                    or mneum eq 'NCM'
                    or mneum eq 'ATPED'
                    or mneum eq 'MATDOC'
                    or mneum eq 'FISCALYEAR'
                    or mneum eq 'MATDOCYEA'
                    or mneum = 'ACTIVITY'
                    or mneum = 'ASSETNO'
                    or mneum = 'BUDGPERIOD'
                    or mneum = 'BUSAREA'
                    or mneum = 'CMMTITEM'
                    or mneum = 'CMMTITMLON'
                    or mneum = 'COAREA'
                    or mneum = 'COSTCENTER'
                    or mneum = 'COSTCTR'
                    or mneum = 'COSTOBJ'
                    or mneum = 'CUSTOMER'
                    or mneum = 'DELIVITEM'
                    or mneum = 'DELIVNUMB'
                    or mneum = 'DISTRPERC'
                    or mneum = 'ENRYUOMISO'
                    or mneum = 'FUNAREALON'
                    or mneum = 'FUNCAREA'
                    or mneum = 'FUND'
                    or mneum = 'FUNDSCTR'
                    or mneum = 'FUNDSRES'
                    or mneum = 'GLACCOUNT'
                    or mneum = 'GLACCT'
                    or mneum = 'GRANTNBR'
                    or mneum = 'GRRCPT'
                    or mneum = 'MATDOCYEA'
                    or mneum = 'MATERIAL'
                    or mneum = 'MATLGROUP'
                    or mneum = 'MATLUSAGE'
                    or mneum = 'MATORIGIN'
                    or mneum = 'MVTIND'
                    or mneum = 'NBSLIPS'
                    or mneum = 'NETPRICE'
                    or mneum = 'NETWORK'
                    or mneum = 'ORDERID'
                    or mneum = 'ORDERNO'
                    or mneum = 'PARTACCT'
                    or mneum = 'PLANT'
                    or mneum = 'PROFITCTR'
                    or mneum = 'PROFSEGM'
                    or mneum = 'PROFSEGMNO'
                    or mneum = 'PROJEXT'
                    or mneum = 'QUANTITY'
                    or mneum = 'RECIND'
                    or mneum = 'REFDATE'
                    or mneum = 'RESITEM'
                    or mneum = 'RLESTKEY'
                    or mneum = 'ROUTINGNO'
                    or mneum = 'SCHEDLINE'
                    or mneum = 'SDDOC'
                    or mneum = 'SDOCITEM'
                    or mneum = 'SERIALNO'
                    or mneum = 'STGELOC'
                    or mneum = 'SUBNUMBER'
                    or mneum = 'TAXCODE'
                    or mneum = 'TAXJURCODE'
                    or mneum = 'TOCOSTCTR'
                    or mneum = 'TOORDER'
                    or mneum = 'TOPROJECT'
                    or mneum = 'VALTYPE'
                    or mneum = 'VENDOR'
                    or mneum = 'WBSELEM'
                    or mneum = 'WBSELEME' ).
      endif.


      sort t_docmn ascending by mneum dcitm atitm seqnr.
      delete adjacent duplicates from t_docmn comparing mneum dcitm atitm.

**     Corrige os zeros a esquera
      loop at t_docmn into wa_docmn.
        call function 'CONVERSION_EXIT_ALPHA_INPUT'
          exporting
            input  = wa_docmn-seqnr
          importing
            output = wa_docmn-seqnr.
        modify t_docmn from wa_docmn index sy-tabix.
      endloop.

**    Insere/Modifica dados no repositorio de mneumonicos
*      INSERT zhms_tb_docmn FROM TABLE t_docmn.
      modify zhms_tb_docmn from table t_docmn.
      commit work and wait.

**    Executa regras identificação de cenário
      clear wl_docum.
      wl_docum-dctyp = 'CHAVE'.
      wl_docum-dcnro = wa_cabdoc-chave.
      append wl_docum to tl_docum.

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
*      wl_logdoc-logty = 'S'.
*      wl_logdoc-logno = '500'.
*      APPEND wl_logdoc TO tl_logdoc.
*
*      CALL FUNCTION 'ZHMS_FM_REGLOG'
*        EXPORTING
*          cabdoc = wa_cabdoc
*          flwst  = 'M'
*          tpprm  = 4
*        TABLES
*          logdoc = tl_logdoc.

**    Limpa as estruturas de atribução
      clear: wa_itmatr_ax, wa_itmatr_ex.
      refresh: t_itmatr_ax, t_itmatr_ex.

**    Seta tela inicial
      vg_0500 = '0501'.

**    Exibe mensagem de sucesso
      message s052.
      refresh t_itmatr_ax.
      clear: t_itmatr_ax, vg_atprp.
      leave to screen 0500.

    endform.                    " F_ATR_GRAVAR_EXC
*Homine - Fim da Inclusão - DD - Ajuste Atribuição
