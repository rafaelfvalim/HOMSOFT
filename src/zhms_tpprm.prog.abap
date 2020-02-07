*&---------------------------------------------------------------------*
*& Report  ZHMS_TPPRM
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT zhms_tpprm.

UPDATE zhms_tb_scen_flo
   SET tpprm = '4'
 WHERE natdc = '02'
   AND typed = 'NFE'
   AND scena = '1'
   AND flowd = '10'
   AND metpr = 'M'.

IF sy-subrc IS INITIAL.
  COMMIT WORK.
ELSE.
  ROLLBACK WORK.
ENDIF.
