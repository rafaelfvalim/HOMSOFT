*---------------------------------------------------------------------*
*    program for:   VIEWPROC_ZHMS_VW_EVV_LAYT
*   generation date: 31.05.2013 at 17:20:08 by user RAFAEL
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION VIEWPROC_ZHMS_VW_EVV_LAYT     .
*----------------------------------------------------------------------*
* Initialization: set field-symbols etc.                               *
*----------------------------------------------------------------------*
   IF LAST_VIEW_INFO NE VIEW_NAME.
ASSIGN ZHMS_VW_EVV_LAYT TO <TABLE1>.
ASSIGN *ZHMS_VW_EVV_LAYT TO <INITIAL>.
ASSIGN STATUS_ZHMS_VW_EVV_LAYT TO <STATUS>.
     PERFORM INITIALISIEREN.
   ENDIF.
   PERFORM JUSTIFY_ACTION_MODE.
   MOVE: VIEW_ACTION TO MAINT_MODE,
         CORR_NUMBER TO CORR_NBR.

*----------------------------------------------------------------------*
* Get data from database                                               *
*----------------------------------------------------------------------*
  IF FCODE EQ READ OR FCODE EQ READ_AND_EDIT.
    PERFORM PREPARE_READ_REQUEST.
    IF X_HEADER-FRM_RP_GET NE SPACE.
            PERFORM (X_HEADER-FRM_RP_GET) IN PROGRAM.
    ELSE.
PERFORM GET_DATA_ZHMS_VW_EVV_LAYT.
    ENDIF.
    IF FCODE EQ READ_AND_EDIT. FCODE = EDIT. ENDIF.
  ENDIF.

  CASE FCODE.
    WHEN  EDIT.                          " Edit read data
      PERFORM CALL_DYNPRO.
      PERFORM CHECK_UPD.
*....................................................................*

    WHEN SAVE.                           " Write data into database
      PERFORM PREPARE_SAVING.
      IF <STATUS>-UPD_FLAG NE SPACE.
        IF X_HEADER-FRM_RP_UPD NE SPACE.
          PERFORM (X_HEADER-FRM_RP_UPD) IN PROGRAM.
        ELSE.
          IF SY-SUBRC EQ 0.
PERFORM DB_UPD_ZHMS_VW_EVV_LAYT.
          ENDIF.
        ENDIF.
        PERFORM AFTER_SAVING.
      ENDIF.
*....................................................................*

    WHEN RESET_LIST.     " Refresh all marked entries of EXTRACT from db
      PERFORM RESET_ENTRIES USING LIST_BILD.
*....................................................................*

    WHEN RESET_ENTRY.               " Refresh single entry from database
      PERFORM RESET_ENTRIES USING DETAIL_BILD.
*.......................................................................
  ENDCASE.
MOVE STATUS_ZHMS_VW_EVV_LAYT-UPD_FLAG TO UPDATE_REQUIRED.
ENDFUNCTION.
