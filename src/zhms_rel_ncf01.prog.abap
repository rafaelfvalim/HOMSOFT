*&---------------------------------------------------------------------*
*&  Include           zhom_REL_NCF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  seleciona_log
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form seleciona_log .
  clear: t_ncm, t_lncm.
  refresh: t_ncm, t_lncm.

  ranges: r_status for zhom_rel_ncm-status.

  r_status-option   = 'EQ'.
  r_status-sign     = 'I'.

  if ck_erro is not initial.
    r_status-low = 1.
    condense r_status-low no-gaps.
    append r_status.
  endif.

  if ck_pend is not initial.
    r_status-low = 2.
    condense r_status-low no-gaps.
    append r_status.
  endif.

  if ck_corr is not initial.
    r_status-low = 3.
    condense r_status-low no-gaps.
    append r_status.
  endif.

  if s_matnr is initial.
    select *
      into table t_ncm
      from zhom_rel_ncm
     where datum ge data_in  and  "data inicial
           datum le data_fn .
  else.
    call function 'CONVERSION_EXIT_ALPHA_INPUT'
      exporting
        input  = s_matnr
      importing
        output = s_matnr.

    select *
      into table t_ncm
      from zhom_rel_ncm
     where datum ge data_in  and  "data inicial
           datum le data_fn  and  "data final
           matnr eq s_matnr.
  endif.

  delete t_ncm where arquivada ne ck_arqv.

  perform atualiza_status.

  delete t_ncm where status not in r_status.

  if s_werks is not initial.
    delete t_ncm where werks ne s_werks.
  endif.

  if t_ncm[] is initial.
    message w002(sy) with 'Nenhuma nota encontrada'.
    call screen 0005.
  endif.

  loop at t_ncm.
    move-corresponding t_ncm to t_lncm.

    if t_ncm-status eq 1.
      t_lncm-icon = '@0A@'.
    elseif t_ncm-status eq 2.
      t_lncm-icon = '@09@'.
    elseif t_ncm-status eq 3.
      t_lncm-icon = '@08@'.
    endif.

    append t_lncm.
  endloop.

endform.                    " seleciona_log

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
  data: l_ok              type sy-ucomm,
        l_offset          type i.
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

    if <mark_field> = 'X'.
      delete <table> index syst-tabix.
      if sy-subrc = 0.
        <tc>-lines = <tc>-lines - 1.
      endif.
    endif.
  endloop.

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
              entry_act             = <tc>-top_line
              entry_from            = 1
              entry_to              = <tc>-lines
              last_page_full        = 'X'
              loops                 = <lines>
              ok_code               = p_ok
              overlapping           = 'X'
         importing
              entry_new             = l_tc_new_top_line
         exceptions
*              NO_ENTRY_OR_PAGE_ACT  = 01
*              NO_ENTRY_TO           = 02
*              NO_OK_CODE_OR_PAGE_GO = 03
              others                = 0.
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
*&      Form  preenche_detalhes
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form preenche_detalhes .
  read table t_lncm with key check = 'X'.

  if sy-subrc is initial.

    read table t_ncm with key codigo = t_lncm-codigo.

    if t_ncm-status eq 1.
      icon_status = '@0A@'.
      txt_status = 'Erro ao alterar o Pedido'.
    elseif t_ncm-status eq 2.
      icon_status = '@09@'.
      txt_status = 'Corrigida no pedido mas pendente no cadastro'.
    elseif t_ncm-status eq 3.
      icon_status = '@08@'.
      txt_status = 'NCM corrigida no cadastro'.
    endif.

    select single name1
      into vg_name1
      from lfa1
     where lifnr eq t_ncm-lifnr.

    vg_codigo     = t_ncm-codigo.
    vg_bukrs      = t_ncm-bukrs.
    vg_werks      = t_ncm-werks.
    vg_datum      = t_ncm-datum.
    vg_lifnr      = t_ncm-lifnr.
    vg_ebeln      = t_ncm-ebeln.
    vg_item       = t_ncm-ebelp.
    vg_matnr      = t_ncm-matnr.
    vg_ncmatual   = t_ncm-ncmatual.
    vg_ncmforn    = t_ncm-ncmforn.
    vg_nota       = t_ncm-nfnum.

    data v_text type string.
    v_text = t_ncm-observacoes.

    call method textnote_editor->set_textstream
      exporting
        text = v_text.

  endif.

  data: v_user type sy-uname.
  clear v_user.

  select single usuario
    into v_user
    from zhom_user
   where usuario eq sy-uname.

  if sy-subrc is initial.
    call method textnote_editor->set_readonly_mode
      exporting
        readonly_mode = 1.
  endif.

endform.                    " preenche_detalhes
*&---------------------------------------------------------------------*
*&      Form  BACK_PROGRAM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form back_program.
*     Destroy Control.
  if not textnote_editor is initial.
    call method textnote_editor->free
      exceptions
        others = 1.
    if sy-subrc ne 0.
*         add your handling
    endif.
*       free ABAP object also
    free textnote_editor.
  endif.

*     destroy container
  if not textnote_custom_container is initial.
    call method textnote_custom_container->free
      exceptions
        others = 1.
    if sy-subrc <> 0.
*         add your handling
    endif.
*       free ABAP object also
    free textnote_custom_container.
  endif.

  call method cl_gui_cfw=>flush
    exceptions
      others = 1.
  if sy-subrc ne 0.
*         add your handling
  endif.

  leave to screen 0.

endform.                               " BACK_PROGRAM
*&---------------------------------------------------------------------*
*&      Form  salvar_obs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form salvar_obs .
  data: v_txt type string.
  clear v_txt .
  call method textnote_editor->get_text_as_r3table
    importing
      table = textnote_table.
  textnote_itxw_note[] = textnote_table[].

  loop at textnote_itxw_note.
    concatenate v_txt textnote_itxw_note-line into v_txt.
  endloop.

  move v_txt to t_ncm-observacoes.

  update zhom_rel_ncm
     set observacoes = t_ncm-observacoes
   where codigo = vg_codigo.

  commit work.

  perform seleciona_log.

endform.                    " salvar_obs

*&---------------------------------------------------------------------*
*&      Form  data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_DATA_FN  text
*----------------------------------------------------------------------*
form data  changing data.

  call function 'F4_DATE'
    importing
      select_date                  = data
    exceptions
      calendar_buffer_not_loadable = 1
      date_after_range             = 2
      date_before_range            = 3
      date_invalid                 = 4
      factory_calendar_not_found   = 5
      holiday_calendar_not_found   = 6
      parameter_conflict           = 7
      others                       = 8.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.


endform.                    " DATA

*&--------------------------------------------------------------------*
*&      Form  atualiza_status
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
form atualiza_status.

  data: ln type sy-tabix.

  if t_ncm[] is not initial.
    select matnr werks steuc
      into table t_marc
      from marc
       for all entries in t_ncm
     where matnr eq t_ncm-matnr
       and werks eq t_ncm-werks.
  endif.


  loop at t_marc.
    loop at t_ncm where matnr = t_marc-matnr
                    and werks = t_marc-werks.
      ln = sy-tabix.
      if t_marc-steuc = t_ncm-ncmforn.
        t_ncm-status = 3.
      else.
        if t_ncm-status ne 1.
          t_ncm-status = 2.
        endif.
      endif.

      update zhom_rel_ncm
         set status = t_ncm-status
       where codigo = t_ncm-codigo.

      commit work.

      modify t_ncm index ln.
    endloop.
  endloop.
endform.                    "atualiza_status
*&---------------------------------------------------------------------*
*&      Form  arquivar
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form arquivar .

  data: v_txt type string.
  clear v_txt .
  call method textnote_editor->get_text_as_r3table
    importing
      table = textnote_table.
  textnote_itxw_note[] = textnote_table[].

  loop at textnote_itxw_note.
    concatenate v_txt textnote_itxw_note-line into v_txt.
  endloop.

  move v_txt to t_ncm-observacoes.

  if t_ncm-observacoes is not initial.
    update zhom_rel_ncm
       set arquivada = 'X'
           observacoes = t_ncm-observacoes
     where codigo = vg_codigo.

    commit work.

    message i002(sy) with 'Arquivada com sucesso!'.

    perform limpa.
  else.
    message w002(sy) with 'O campo OBSERVAÇÕES deve ser preenchido'.
  endif.

endform.                    " arquivar


*&--------------------------------------------------------------------*
*&      Form  limpa
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
form limpa.

  clear: vg_codigo, vg_bukrs, vg_werks, vg_datum, vg_lifnr,
         vg_ebeln, vg_item, vg_matnr, vg_ncmatual, vg_ncmforn,
         vg_nota, vg_codigo, icon_status, txt_status, vg_name1.

  data v_text type string.
  clear v_text.
  call method textnote_editor->set_textstream
    exporting
      text = v_text.

  perform seleciona_log .

endform.                    "limpa

*&--------------------------------------------------------------------*
*&      Form  download_xls
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
form download_xls.

  data: ld_filename type string,
        ld_path     type string,
        ld_fullpath type string,
        ld_result   type i,
        gd_file     type c,
        p_file      type rlgrap-filename.

  data : begin of tg_head occurs 0,
           filed1(20) type c,                     " Header Data
        end of tg_head.

  data: begin of tg_ncm occurs 0,
            codigo(10)   type c,
            bukrs(4)   type c,
            werks(4)   type c,
            datum(10)	 type c,
            lifnr(10)	 type c,
            nfnum(9)   type c,
            ebeln(10)	 type c,
            ebelp(5)   type c,
            matnr(18)	 type c,
            ncmatual(16) type c,
            ncmforn(16)	 type c,
            status(1)	 type c,
            arquivad(1)	 type c,
            observa(255) type c,


        end of tg_ncm.

  loop at t_ncm.
    move: t_ncm-codigo to tg_ncm-codigo,
     t_ncm-bukrs to tg_ncm-bukrs,
     t_ncm-werks to tg_ncm-werks,
     t_ncm-datum to tg_ncm-datum,
     t_ncm-lifnr to tg_ncm-lifnr,
     t_ncm-ebeln to tg_ncm-ebeln,
     t_ncm-ebelp to tg_ncm-ebelp,
     t_ncm-matnr to tg_ncm-matnr,
     t_ncm-ncmatual to tg_ncm-ncmatual,
     t_ncm-ncmforn to tg_ncm-ncmforn,
     t_ncm-status to tg_ncm-status ,
     t_ncm-observacoes to tg_ncm-observa,
     t_ncm-nfnum to tg_ncm-nfnum,
     t_ncm-arquivada to tg_ncm-arquivad.
    append tg_ncm.
  endloop.

  tg_head-filed1 = 'Codigo'.
  append tg_head.

  tg_head-filed1 = 'Empresa'.
  append tg_head.

  tg_head-filed1 = 'Centro'.
  append tg_head.

  tg_head-filed1 = 'Data'.
  append tg_head.

  tg_head-filed1 = 'Fornecedor'.
  append tg_head.

  tg_head-filed1 = 'NF-e'.
  append tg_head.

  tg_head-filed1 = 'Pedido'.
  append tg_head.

  tg_head-filed1 = 'Item'.
  append tg_head.

  tg_head-filed1 = 'Material'.
  append tg_head.

  tg_head-filed1 = 'NCM Pedido'.
  append tg_head.

  tg_head-filed1 = 'NCM Fornecedor'.
  append tg_head.

  tg_head-filed1 = 'Status'.
  append tg_head.

  tg_head-filed1 = 'Arquivada'.
  append tg_head.

  tg_head-filed1 = 'Observações'.
  append tg_head.

* Display save dialog window
  check tg_ncm[] is not initial.

  call method cl_gui_frontend_services=>file_save_dialog
    exporting
      default_extension = '.XLS'
      default_file_name = 'Relatório de NCM.xls'
      initial_directory = 'c:\temp\'
    changing
      filename          = ld_filename
      path              = ld_path
      fullpath          = ld_fullpath
      user_action       = ld_result.

  p_file  = ld_fullpath.
  check p_file is not initial.

  call function 'MS_EXCEL_OLE_STANDARD_DAT'
    exporting
      file_name                 = p_file "Nome do arquivo
    tables
      data_tab                  = tg_ncm  "Tabela de dados
      fieldnames                = tg_head  "Tabela de cabeçalhos
    exceptions
      file_not_exist            = 1
      filename_expected         = 2
      communication_error       = 3
      ole_object_method_error   = 4
      ole_object_property_error = 5
      invalid_filename          = 6
      invalid_pivot_fields      = 7
      download_problem          = 8
      others                    = 9.

  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
    with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.



endform.                    "download_xls
