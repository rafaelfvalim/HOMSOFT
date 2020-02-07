*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 18.11.2014 at 19:29:02
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZHMS_TB_SECURITY................................*
DATA:  BEGIN OF STATUS_ZHMS_TB_SECURITY              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZHMS_TB_SECURITY              .
CONTROLS: TCTRL_ZHMS_TB_SECURITY
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZHMS_TB_SECURITY              .
TABLES: ZHMS_TB_SECURITY               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
