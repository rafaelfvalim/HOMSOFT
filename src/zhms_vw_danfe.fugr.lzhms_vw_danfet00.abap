*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 05.10.2018 at 06:44:47 by user DEVELOPER1
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZHMS_VW_DANFE...................................*
TABLES: ZHMS_VW_DANFE, *ZHMS_VW_DANFE. "view work areas
CONTROLS: TCTRL_ZHMS_VW_DANFE
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZHMS_VW_DANFE. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZHMS_VW_DANFE.
* Table for entries selected to show on screen
DATA: BEGIN OF ZHMS_VW_DANFE_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZHMS_VW_DANFE.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZHMS_VW_DANFE_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZHMS_VW_DANFE_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZHMS_VW_DANFE.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZHMS_VW_DANFE_TOTAL.

*.........table declarations:.................................*
TABLES: ZHMS_TB_DANFE                  .
