
*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_RULERI02 .
*----------------------------------------------------------------------*

*{   INSERT         DE2K905816                                        1
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0400 INPUT.
  ok_code = sy-ucomm.

  CASE ok_code.
    WHEN 'OK'.
      PERFORM zf_update_nf.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0400  INPUT

*}   INSERT
*&SPWIZARD: INPUT MODULE FOR TC 'ZTB_MIRO3'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE ztb_miro4_modify INPUT.
  MODIFY ty_item_bapi
    INDEX ztb_miro3-current_line.

ENDMODULE.                    "ZTB_MIRO4_MODIFY INPUT
