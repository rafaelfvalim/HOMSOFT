
*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_RULERO01 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  SET PF-STATUS 'STATUS_0100'.


ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0300 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.
SET PF-STATUS 'STATUS_0100'.
ENDMODULE.                 " STATUS_0300  OUTPUT

*&SPWIZARD: OUTPUT MODULE FOR TC 'ZTB_MIRO3'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE ZTB_MIRO3_CHANGE_TC_ATTR OUTPUT.
  DESCRIBE TABLE TY_ITEM_BAPI LINES ZTB_MIRO3-lines.
ENDMODULE.
