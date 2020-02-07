*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 13.12.2019 at 11:05:10
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZHMS_TB_EMAILFAT................................*
DATA:  BEGIN OF STATUS_ZHMS_TB_EMAILFAT              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZHMS_TB_EMAILFAT              .
CONTROLS: TCTRL_ZHMS_TB_EMAILFAT
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZHMS_TB_EMAILFAT              .
TABLES: ZHMS_TB_EMAILFAT               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
