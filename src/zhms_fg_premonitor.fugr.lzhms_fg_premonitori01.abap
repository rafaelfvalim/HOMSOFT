*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_PREMONITORI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  M_USER_COMMAND_0100_EXIT  INPUT
*&---------------------------------------------------------------------*
*       Eventos de Saída da Tela 0100
*----------------------------------------------------------------------*
MODULE m_user_command_0100_exit INPUT.
  CASE sy-ucomm.
    WHEN 'CANC'  OR  'EXIT'.
      LEAVE TO SCREEN 0.
*      LEAVE PROGRAM.

    WHEN OTHERS.
  ENDCASE.
ENDMODULE.                 " M_USER_COMMAND_0100_EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  M_USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*   Eventos de Processamento da Tela 0100
*----------------------------------------------------------------------*
MODULE m_user_command_0100 INPUT.

  CASE sy-ucomm.
    WHEN OTHERS.
      CALL METHOD cl_gui_cfw=>dispatch.
  ENDCASE.

  CLEAR sy-ucomm.
ENDMODULE.                 " M_USER_COMMAND_0100  INPUT
