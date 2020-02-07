*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_REPORTI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  ok_code = sy-ucomm.

  CASE ok_code.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'LEAVE'.
      LEAVE TO SCREEN 0.
    WHEN 'CANCEL'.
      LEAVE TO SCREEN 0.
  ENDCASE.

  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  CLEAR ok_code.
  MOVE sy-ucomm TO ok_code.

  CASE ok_code.
    WHEN 'BACK'.
      CLEAR t_status01.
      LEAVE TO SCREEN 0.
    WHEN 'LEAVE'.
      LEAVE TO SCREEN 0.
    WHEN 'CANCEL'.
      LEAVE TO SCREEN 0.
    WHEN 'BT_STAT'.
      PERFORM select_opt.
      PERFORM f_get_doc.
      MOVE '0202' TO vg_screen2.
    WHEN 'BT_VLD'.
      PERFORM select_opt.
      PERFORM f_get_vld.
      MOVE '0203' TO vg_screen2.
    WHEN 'BT_HIST'.
      PERFORM select_opt.
      PERFORM f_get_hist.
      MOVE '0204' TO vg_screen2.
    WHEN 'BT_GRF'.
      PERFORM select_opt.
      PERFORM f_get_vld.
      MOVE '0205' TO vg_screen2.
    WHEN 'RNCM'.
      call transaction 'ZHMSNCM'.
  ENDCASE.

  CLEAR ok_code.

ENDMODULE.                 " USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0205  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0205 INPUT.

ENDMODULE.                 " USER_COMMAND_0205  INPUT
