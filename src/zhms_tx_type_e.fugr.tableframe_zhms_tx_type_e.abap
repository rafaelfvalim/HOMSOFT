*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZHMS_TX_TYPE_E
*   generation date: 18.10.2017 at 08:55:14
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZHMS_TX_TYPE_E     .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
