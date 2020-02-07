*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_MONITORO02.
*----------------------------------------------------------------------*

*{   INSERT         EU1K9A0ZAB                                        1
*&---------------------------------------------------------------------*
*&      Module  STATUS_0503  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0503 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.

  REFRESH t_show_po[].
  CALL FUNCTION 'ZHMS_FM_BUSCA_PO_POSSIVEIS'
    EXPORTING
      chave     = vg_chave
    TABLES
      t_show_po = t_show_po.

ENDMODULE.                 " STATUS_0503  OUTPUT

*}   INSERT
