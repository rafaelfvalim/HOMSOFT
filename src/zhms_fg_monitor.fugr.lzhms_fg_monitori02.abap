*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_MONITORI02.
*----------------------------------------------------------------------*

*{   INSERT         EU1K9A0ZAB                                        1
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0503  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0503 INPUT.

  IF sy-ucomm EQ 'TRANSF'.

    READ TABLE t_show_po INTO wa_show_po WITH KEY mark = 'X'.

    IF sy-subrc IS INITIAL.
      MOVE: wa_show_po-ebeln TO wa_itmatr_ax-nrsrf,
            wa_show_po-ebelp TO wa_itmatr_ax-itsrf.
      APPEND wa_itmatr_ax TO t_itmatr_ax.
    ENDIF.

  ENDIF.

ENDMODULE.                 " USER_COMMAND_0503  INPUT

*}   INSERT
