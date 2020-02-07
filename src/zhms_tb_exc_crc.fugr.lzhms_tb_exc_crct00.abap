*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 12.07.2017 at 15:47:21
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZHMS_TB_EXC_CRC.................................*
DATA:  BEGIN OF STATUS_ZHMS_TB_EXC_CRC               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZHMS_TB_EXC_CRC               .
CONTROLS: TCTRL_ZHMS_TB_EXC_CRC
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZHMS_TB_EXC_CRC               .
TABLES: ZHMS_TB_EXC_CRC                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
