*&---------------------------------------------------------------------*
*& Report  ZHMS_FLAG_PO
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT ZHMS_FLAG_PO.


PARAMETERS: p_chave type zhms_de_chave.

CALL FUNCTION 'ZHMS_CHANGE_PO_REMESSA_FINAL'
 EXPORTING
   CHAVE         = p_chave.
