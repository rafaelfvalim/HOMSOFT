*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZHMS_FG_MVIEWS
*   generation date: 25.09.2018 at 08:40:50
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZHMS_FG_MVIEWS     .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
