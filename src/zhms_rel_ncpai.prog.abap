*&---------------------------------------------------------------------*
*&  Include           ZHOM_REL_NCPAI
*&---------------------------------------------------------------------*

*&SPWIZARD: INPUT MODUL FOR TC 'TC_LNCM'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
module tc_lncm_mark input.
  data: g_tc_lncm_wa2 like line of t_lncm.
  if tc_lncm-line_sel_mode = 1
  and t_lncm-check = 'X'.
    loop at t_lncm into g_tc_lncm_wa2
      where check = 'X'.
      g_tc_lncm_wa2-check = ''.
      modify t_lncm
        from g_tc_lncm_wa2
        transporting check.
    endloop.
  endif.
  modify t_lncm
    index tc_lncm-current_line
    transporting check.
endmodule.                    "TC_LNCM_MARK INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TC_LNCM'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
module tc_lncm_user_command input.
  ok_code = sy-ucomm.
  perform user_ok_tc using    'TC_LNCM'
                              'T_LNCM'
                              'CHECK'
                     changing ok_code.
  sy-ucomm = ok_code.
endmodule.                    "TC_LNCM_USER_COMMAND INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0010  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_0010 input.

  if sy-ucomm = 'CANC'.
    leave to screen 0.
  endif.

  case sy-ucomm.
    when 'SHOW'.
      perform preenche_detalhes.
    when 'SAVE'.
      perform salvar_obs.
    when 'GOBACK'.
      perform back_program.
    when 'CANC'.
      perform back_program.
    when 'ARQV'.
      perform arquivar.
    when 'EXPORT'.
      perform download_xls.
  endcase.

  if sy-ucomm is initial.
    perform preenche_detalhes.
  endif.

endmodule.                 " USER_COMMAND_0010  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_TEXTEDIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_textedit input.
*  CASE textnote_ok_code.
*
*    WHEN 'BACK'.
*      PERFORM back_program.
*
*    WHEN 'CONT'.
**   retrieve table from control
*
*      PERFORM back_program.
*
*    WHEN 'EXIT'.
*      PERFORM back_program.
*
*    WHEN 'BREAK'.
*      PERFORM back_program.
*
*    WHEN 'CANC'.
*      PERFORM back_program.
*
*  ENDCASE.

  clear textnote_ok_code.

endmodule.                 " USER_COMMAND_TEXTEDIT  INPUT

*---------------------------------------------------------------------*
*  MODULE elog_user_command_0101 INPUT
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
module elog_user_command_0101 input.
  data wa_txw_dir2 type dart1_dir2.
  data: returncode(1) type c,
        nrecords type n.

  case g_seg_ok_code.

    when 'EXIT' or 'BACK' or 'CANC' or 'INFO'.
      perform exit_program using g_seg_ok_code.

    when 'DISP' or 'DETL'.
      leave to list-processing.
      clear gt_seg_select_outtab.
      call method g_seg_tree->get_selected_item
        importing
          e_index_outtab = gt_seg_select_outtab.
      if gt_seg_select_outtab is initial.
        call method g_seg_tree->get_selected_nodes
          changing
            ct_index_outtab = gt_seg_selects[].
        read table gt_seg_selects index 1.
        gt_seg_select_outtab = gt_seg_selects.
      endif.

      read table gt_seg_outtab index gt_seg_select_outtab.
    when others.
      call method cl_gui_cfw=>dispatch.

  endcase.
  clear g_seg_ok_code.

endmodule.                             " ELOG_USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*&      Form  EXIT_PROGRAM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form exit_program using p_ok_code.
  case p_ok_code.
    when 'EXIT' or 'CANC'.
      call method g_seg_tree->free.
      leave program.
    when 'BACK'.
*      REFRESH gt_SEG_fieldcatalog[].
*      REFRESH gt_SEG_sort[].
*      REFRESH gt_seg_outtab[].

      call method g_seg_tree->free.
      call method g_seg_custom_container->free.
      clear g_seg_tree.
      set screen 0.
      leave screen.
  endcase.
endform.                               " EXIT_PROGRAM
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0005  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_0005 input.

  if sy-ucomm = 'CANC'.
    leave to screen 0.
  endif.

  case sy-ucomm.
    when 'INIC'.
      if ck_erro is initial
       and ck_corr is initial
       and ck_pend is initial.
        set screen 05.
        message w002(sy) with 'Selecionar um status de log'.
        exit.
      else.
*        IF s_bukrs IS INITIAL
*        OR s_werks IS INITIAL.
*          MESSAGE w002(sy) WITH 'Inserir Empresa e Centro.'.
*        ELSE.
        call screen 0010.
*        ENDIF.

      endif.

    when 'ATEB'.
      set screen 0005.
      perform data changing data_fn.
      set parameter id 'DATA_FN' field data_fn.
      exit.
    when 'DEB'.
      set screen 0005.
      perform data changing data_in.
      set parameter id 'DATA_IN' field data_in.
      exit.
  endcase.
  if sy-ucomm ne 'GOBACK'.
    if ck_erro is initial
    and ck_corr is initial
    and ck_pend is initial.
      set screen 0005.

      message w002(sy) with 'Selecionar um status de log'.
      exit.
    elseif sy-ucomm is initial.
      if s_bukrs is initial
      or s_werks is initial.
        message w002(sy) with 'Inserir Empresa e Centro.'.
      else.
        call screen 0010.
      endif.
    endif.
  endif.


endmodule.                 " USER_COMMAND_0005  INPUT
*---------------------------------------------------------------------*
*  MODULE control_command INPUT
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
module control_command input.
  case sy-ucomm.
    when 'GOBACK'.
      if sy-dynnr = 0005.
*        leave to transaction 'YCOCK'.
        leave program.
      else.
        call screen 0005.
      endif.
    when 'CANCEL'.
      if sy-dynnr = 0005.
*        leave to transaction 'YCOCK'.
        leave program.
      else.
        call screen 0005.
      endif.
    when 'CANC'.
      if sy-dynnr = 0005.
*        leave to transaction 'YCOCK'.
        leave program.
      else.
        call screen 0005.
      endif.
    when 'EXIT'.
      if sy-dynnr = 0005.
*        leave to transaction 'YCOCK'.
        leave program.
      else.
        call screen 0005.
      endif.
  endcase.
endmodule.                    "control_command INPUT
