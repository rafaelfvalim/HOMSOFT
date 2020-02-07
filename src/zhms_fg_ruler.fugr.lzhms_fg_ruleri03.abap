
*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_RULERI03 .
*----------------------------------------------------------------------*


*{   INSERT         DE2K905862                                        1
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0500 INPUT.
  ok_code = sy-ucomm.
  CASE ok_code.
    WHEN 'OK'.
      LEAVE TO SCREEN 0.
*Homine - Inicio da inclusão - DD - Partição de lote subcontratação
    WHEN 'EXPAND'.
      LOOP AT ty_subcontratacao INTO wa_subcontratacao WHERE marc = 'X'.
        CLEAR: wa_subcontratacao-lote,
               wa_subcontratacao-quantidade,
               wa_subcontratacao-marc.
        APPEND wa_subcontratacao TO ty_subcontratacao.
      ENDLOOP.
*Homine - Fim da inclusão - DD - Partição de lote subcontratação
  ENDCASE.

clear: ok_code, sy-ucomm.
ENDMODULE.                 " USER_COMMAND_0500  INPUT


*}   INSERT
