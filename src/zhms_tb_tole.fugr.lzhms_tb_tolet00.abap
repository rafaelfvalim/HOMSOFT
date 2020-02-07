*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 13.12.2019 at 14:22:23
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZHMS_TB_TOLE....................................*
DATA:  BEGIN OF STATUS_ZHMS_TB_TOLE                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZHMS_TB_TOLE                  .
CONTROLS: TCTRL_ZHMS_TB_TOLE
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZHMS_TB_TOLE                  .
TABLES: ZHMS_TB_TOLE                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
