*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZHMS_FG_SECURITY
*   generation date: 18.11.2014 at 19:29:00
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZHMS_FG_SECURITY   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
