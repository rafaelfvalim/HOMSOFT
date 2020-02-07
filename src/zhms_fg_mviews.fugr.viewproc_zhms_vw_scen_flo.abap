*---------------------------------------------------------------------*
*    program for:   VIEWPROC_ZHMS_VW_SCEN_FLO
*   generation date: 06.02.2014 at 16:13:05 by user DAVID
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION VIEWPROC_ZHMS_VW_SCEN_FLO     .
*"----------------------------------------------------------------------
*"*"Interface global:
*"  IMPORTING
*"     VALUE(FCODE) DEFAULT 'RDED'
*"     VALUE(VIEW_ACTION) DEFAULT 'S'
*"     VALUE(VIEW_NAME) LIKE  DD02V-TABNAME
*"     VALUE(CORR_NUMBER) LIKE  E070-TRKORR DEFAULT ' '
*"  EXPORTING
*"     VALUE(LAST_ACT_ENTRY)
*"     VALUE(UCOMM)
*"     VALUE(UPDATE_REQUIRED)
*"  TABLES
*"      CORR_KEYTAB STRUCTURE  E071K
*"      DBA_SELLIST STRUCTURE  VIMSELLIST
*"      DPL_SELLIST STRUCTURE  VIMSELLIST
*"      EXCL_CUA_FUNCT STRUCTURE  VIMEXCLFUN
*"      EXTRACT
*"      TOTAL
*"      X_HEADER STRUCTURE  VIMDESC
*"      X_NAMTAB STRUCTURE  VIMNAMTAB
*"  EXCEPTIONS
*"      NO_VALUE_FOR_SUBSET_IDENT
*"      MISSING_CORR_NUMBER
*"      SAVING_CORRECTION_FAILED
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
* Initialization: set field-symbols etc.                               *
*----------------------------------------------------------------------*
   IF LAST_VIEW_INFO NE VIEW_NAME.
ASSIGN ZHMS_VW_SCEN_FLO TO <TABLE1>.
ASSIGN *ZHMS_VW_SCEN_FLO TO <INITIAL>.
ASSIGN STATUS_ZHMS_VW_SCEN_FLO TO <STATUS>.
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
PERFORM GET_DATA_ZHMS_VW_SCEN_FLO.
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
PERFORM DB_UPD_ZHMS_VW_SCEN_FLO.
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
MOVE STATUS_ZHMS_VW_SCEN_FLO-UPD_FLAG TO UPDATE_REQUIRED.
ENDFUNCTION.
