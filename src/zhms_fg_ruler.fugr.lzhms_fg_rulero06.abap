
*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_RULERO06 .
*----------------------------------------------------------------------*


*{   INSERT         DE2K905923                                        1
*&---------------------------------------------------------------------*
*&      Module  ZTB_SUBCONTRATACAO_CHANGE_TC  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module ZTB_SUBCONTRATACAO_CHANGE_TC output.
  DESCRIBE TABLE ty_subcontratacao LINES ZTB_SUBCONTRATACAO-lines.
endmodule.                 " ZTB_SUBCONTRATACAO_CHANGE_TC  OUTPUT

*}   INSERT


module ZTB_SUBCONTRAT_ORDEM_CHANGE_TC output.
  DESCRIBE TABLE ty_subcontratacao LINES ZTB_SUBCONTRATACAO_ORDEM-lines.
endmodule.
