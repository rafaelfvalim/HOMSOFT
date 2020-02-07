*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 28.01.2020 at 09:47:40
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZHMS_TB_PARAMS..................................*
DATA:  BEGIN OF STATUS_ZHMS_TB_PARAMS                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZHMS_TB_PARAMS                .
CONTROLS: TCTRL_ZHMS_TB_PARAMS
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZHMS_TB_PARAMS                .
TABLES: ZHMS_TB_PARAMS                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
