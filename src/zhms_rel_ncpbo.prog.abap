*&---------------------------------------------------------------------*
*&  Include           ZHOM_REL_NCPBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0010  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module status_0010 output.

  perform seleciona_log.


endmodule.                 " STATUS_0010  OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_LNCM'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
module tc_lncm_change_tc_attr output.
  describe table t_lncm lines tc_lncm-lines.
endmodule.                    "TC_LNCM_CHANGE_TC_ATTR OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC_LNCM'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GET LINES OF TABLECONTROL
module tc_lncm_get_lines output.
  g_tc_lncm_lines = sy-loopc.
endmodule.                    "TC_LNCM_GET_LINES OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_TEXTEDIT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module status_textedit output.
  if textnote_editor is initial.

*   set status
    set pf-status 'TEXTEDIT'.
    if not textnote_edit_mode is initial.
      set titlebar 'TEXTEDIT'.
    else.
      set titlebar 'TEXTDISP'.
    endif.

*   create control container
    create object textnote_custom_container
        exporting
            container_name = 'TEXTEDITOR1'
        exceptions
            cntl_error = 1
            cntl_system_error = 2
            create_error = 3
            lifetime_error = 4
            lifetime_dynpro_dynpro_link = 5.
    if sy-subrc ne 0.
*      add your handling
    endif.
    textnote_container = 'TEXTEDITOR1'.

*   create calls constructor, which initializes, creats and links
*   TextEdit Control
    create object textnote_editor
          exporting
           parent = textnote_custom_container
           wordwrap_mode =
*               cl_gui_textedit=>wordwrap_off
              cl_gui_textedit=>wordwrap_at_fixed_position
*              cl_gui_textedit=>WORDWRAP_AT_WINDOWBORDER
           wordwrap_position = textnoteline_length
           wordwrap_to_linebreak_mode = cl_gui_textedit=>true.

  endif.

  call method textnote_custom_container->link
    exporting
      repid     = textnote_repid
      container = textnote_container.

*           show toolbar and statusbar on this screen
  call method textnote_editor->set_toolbar_mode
    exporting
      toolbar_mode = textnote_editor->true.

  call method textnote_editor->set_statusbar_mode
    exporting
      statusbar_mode = textnote_editor->true.

* Set edit mode
*  IF textnote_edit_mode IS INITIAL.
*    CALL METHOD textnote_editor->set_readonly_mode
*      EXPORTING
*        readonly_mode = 1.
*  ENDIF.

*   send table to control
*  textnote_table[] = textnote_itxw_note[].
*  CALL METHOD textnote_editor->set_text_as_r3table
*    EXPORTING
*      table = textnote_table.

* finally flush
  call method cl_gui_cfw=>flush
    exceptions
      others = 1.
  if sy-subrc ne 0.

  endif.

  data: v_user type sy-uname.
  clear v_user.

  select single usuario
    into v_user
    from zhom_user
   where usuario eq sy-uname.

  if sy-subrc is initial
  or ck_arqv eq 'X'.
    call method textnote_editor->set_readonly_mode
      exporting
        readonly_mode = 1.

    loop at screen.
      if screen-name eq 'BTN_ARQUIV'.
        screen-invisible = 1.
        modify screen.
      endif.
    endloop.
  endif.

endmodule.                 " STATUS_TEXTEDIT  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0005  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module status_0005 output.
  set pf-status '0005'.
  set titlebar '0005'.

  data : ano(4) type n.


  if data_in is initial.
    concatenate  sy-datum(6) '01' into data_in.
    data_fn = data_in.

    if data_fn+4(2) = 12.
      data_fn+4(4) = '0101'.
      ano = data_fn(4).
      ano = ano + 1.
      data_fn(4) = ano.
    else.
      data_fn+6(2) = '01'.
      data_fn+4(2) = data_fn+4(2) + 1.
      data_fn = data_fn - 1.
    endif.

  endif.

  "select single * into w_user
   "from zhom_user
    "where usuario eq sy-uname.

  "if w_user-centro is not initial.

    "select single bukrs
     " into s_bukrs
    "from t001k
    "where bwkey = w_user-centro.
  "endif.


endmodule.                 " STATUS_0005  OUTPUT
