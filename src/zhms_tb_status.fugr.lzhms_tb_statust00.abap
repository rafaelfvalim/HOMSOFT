*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 12.12.2019 at 16:30:54
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZHMS_TB_STATUS..................................*
DATA:  BEGIN OF STATUS_ZHMS_TB_STATUS                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZHMS_TB_STATUS                .
CONTROLS: TCTRL_ZHMS_TB_STATUS
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZHMS_TB_STATUS                .
TABLES: ZHMS_TB_STATUS                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
