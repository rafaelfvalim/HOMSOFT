*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 13.12.2019 at 11:22:09
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZHMS_TB_IMPOSTO.................................*
DATA:  BEGIN OF STATUS_ZHMS_TB_IMPOSTO               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZHMS_TB_IMPOSTO               .
CONTROLS: TCTRL_ZHMS_TB_IMPOSTO
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZHMS_TB_IMPOSTO               .
TABLES: ZHMS_TB_IMPOSTO                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
