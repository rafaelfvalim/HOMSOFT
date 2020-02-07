*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 13.12.2019 at 13:52:40
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZHMS_TB_CNPJSN..................................*
DATA:  BEGIN OF STATUS_ZHMS_TB_CNPJSN                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZHMS_TB_CNPJSN                .
CONTROLS: TCTRL_ZHMS_TB_CNPJSN
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZHMS_TB_CNPJSN                .
TABLES: ZHMS_TB_CNPJSN                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
