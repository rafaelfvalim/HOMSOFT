*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 13.12.2019 at 13:09:15
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZHMS_TB_IVAS_VLD................................*
DATA:  BEGIN OF STATUS_ZHMS_TB_IVAS_VLD              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZHMS_TB_IVAS_VLD              .
CONTROLS: TCTRL_ZHMS_TB_IVAS_VLD
            TYPE TABLEVIEW USING SCREEN '0002'.
*...processing: ZHMS_TB_MAIL....................................*
DATA:  BEGIN OF STATUS_ZHMS_TB_MAIL                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZHMS_TB_MAIL                  .
CONTROLS: TCTRL_ZHMS_TB_MAIL
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZHMS_TB_IVAS_VLD              .
TABLES: *ZHMS_TB_MAIL                  .
TABLES: ZHMS_TB_IVAS_VLD               .
TABLES: ZHMS_TB_MAIL                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
