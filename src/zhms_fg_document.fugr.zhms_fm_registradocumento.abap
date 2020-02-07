FUNCTION zhms_fm_registradocumento.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(DOCST) TYPE  ZHMS_TB_DOCST
*"     REFERENCE(CABDOC) TYPE  ZHMS_TB_CABDOC
*"----------------------------------------------------------------------
* RCP - Tradução EN/ES - 15/08/2018

  IF NOT docst IS INITIAL.
    INSERT INTO zhms_tb_docst VALUES docst.
  ENDIF.

  IF NOT cabdoc IS INITIAL.
    INSERT INTO zhms_tb_cabdoc VALUES cabdoc.
  ENDIF.

  COMMIT WORK AND WAIT.


ENDFUNCTION.
