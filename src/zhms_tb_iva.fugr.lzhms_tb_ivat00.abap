*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 13.12.2019 at 13:23:35
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZHMS_TB_IVA.....................................*
DATA:  BEGIN OF STATUS_ZHMS_TB_IVA                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZHMS_TB_IVA                   .
CONTROLS: TCTRL_ZHMS_TB_IVA
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZHMS_TB_IVA                   .
TABLES: ZHMS_TB_IVA                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
