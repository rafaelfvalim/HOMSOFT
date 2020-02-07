
*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_RULERI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  ok_code = sy-ucomm.

  CASE ok_code.
    WHEN 'OK'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0300 INPUT.
  ok_code = sy-ucomm.

  CASE ok_code.
    WHEN 'OK'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0300  INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'ZTB_MIRO3'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE ZTB_MIRO3_MODIFY INPUT.
  MODIFY TY_ITEM_BAPI
    INDEX ZTB_MIRO3-CURRENT_LINE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  ZTB_SUBCONTRATACAO_MODIFY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module ZTB_SUBCONTRATACAO_MODIFY input.
  MODIFY TY_SUBCONTRATACAO
    INDEX ZTB_SUBCONTRATACAO-CURRENT_LINE.
endmodule.                 " ZTB_SUBCONTRATACAO_MODIFY  INPUT


module ZTB_SUBCONTRAT_ORDEM_MODIFY input.
  MODIFY TY_SUBCONTRATACAO
    INDEX ZTB_SUBCONTRATACAO_ORDEM-CURRENT_LINE.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  ZTB_SUBCONTRATACAO_MARC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ztb_subcontratacao_marc INPUT.
  DATA: tc_subcontratacao LIKE LINE OF ty_subcontratacao.

  IF ztb_subcontratacao-line_sel_mode = 1
  AND ty_subcontratacao-marc = 'X'.
    LOOP AT ty_subcontratacao.
      CLEAR: ty_subcontratacao-marc.
      MODIFY ty_subcontratacao INDEX sy-tabix.
    ENDLOOP.
    READ TABLE ty_subcontratacao INDEX ztb_subcontratacao-current_line.
    IF sy-subrc = 0.
      ty_subcontratacao-marc = 'X'.
      MODIFY ty_subcontratacao INDEX ztb_subcontratacao-current_line.
    ENDIF.
  ENDIF.

ENDMODULE.                 " ZTB_SUBCONTRATACAO_MARC  INPUT
