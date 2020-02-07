*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 13.12.2019 at 13:32:26
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZHMS_TB_BIZTALK.................................*
DATA:  BEGIN OF STATUS_ZHMS_TB_BIZTALK               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZHMS_TB_BIZTALK               .
CONTROLS: TCTRL_ZHMS_TB_BIZTALK
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZHMS_TB_BIZTALK               .
TABLES: ZHMS_TB_BIZTALK                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
