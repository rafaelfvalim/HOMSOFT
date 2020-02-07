*&---------------------------------------------------------------------*
*&  Include           ZHMS_REPORT_180_DIAS_TOP
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Declaração de tabelas transparentes
*&---------------------------------------------------------------------*
TABLES: j_1bnfdoc, essr, lfa1.

TYPE-POOLS slis.

*&-------------------------------------------------------------------*
* Definição de estruturas
*&-------------------------------------------------------------------*
*** ALV
TYPES: BEGIN OF ty_alv.
        INCLUDE STRUCTURE zhms_st_180dias.
TYPES: END OF ty_alv.

TYPES: BEGIN OF ty_lin_ret,
        docnum type J_1BDOCNUM,
        MATNR type MATNR,
        maktx type MAKTX,
       END OF ty_lin_ret.
*&-------------------------------------------------------------------*
* Definição de tabelas internas
*&-------------------------------------------------------------------*
DATA it_doc         TYPE TABLE OF j_1bnfdoc.
DATA it_doc_ret_cab TYPE TABLE OF j_1bnfdoc.
DATA it_doc_ret_itm TYPE TABLE OF j_1bnfdoc.
DATA it_lin         TYPE TABLE OF j_1bnflin.
DATA it_lin_ret_cab TYPE TABLE OF j_1bnflin.
DATA it_lin_ret_itm TYPE TABLE OF j_1bnflin.
DATA it_status      TYPE TABLE OF zhms_tb_confg180.
DATA it_alv         TYPE STANDARD TABLE OF zhms_st_180dias.
DATA t_docnum       TYPE STANDARD TABLE OF zhms_tb_doc180.
DATA t_cfop180      TYPE STANDARD TABLE OF zhms_tb_cfop180 WITH HEADER LINE.

*--------------------------------------------------------------------*
* Definição de variáveis
*--------------------------------------------------------------------*
DATA v_udate   TYPE cdhdr-udate.
DATA v_alv     TYPE REF TO cl_salv_table.
DATA v_func    TYPE REF TO cl_salv_functions.
DATA v_display TYPE REF TO cl_salv_display_settings.
DATA v_cols    TYPE REF TO cl_salv_columns_table.
DATA v_col     TYPE REF TO cl_salv_column_table.
*--------------------------------------------------------------------*
* Definição de constantes
*--------------------------------------------------------------------*
CONSTANTS c_e          TYPE c LENGTH 01 VALUE 'E'.
CONSTANTS c_entrysheet TYPE c LENGTH 10 VALUE 'ENTRYSHEET'.

*--------------------------------------------------------------------*
* Selection screen
*--------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
SELECTION-SCREEN: BEGIN OF BLOCK b2.

SELECT-OPTIONS s_docdat FOR j_1bnfdoc-docdat OBLIGATORY. "Dt Doc.
SELECT-OPTIONS s_pstdat FOR j_1bnfdoc-pstdat. "Dt Lanç.
SELECT-OPTIONS s_parid  FOR j_1bnfdoc-parid. "Cod. Parceiro
SELECT-OPTIONS s_nfenum FOR j_1bnfdoc-nfenum. "Nº NF-e
SELECTION-SCREEN SKIP 1.
PARAMETERS p_retur AS CHECKBOX.

SELECTION-SCREEN: END OF BLOCK b2.
SELECTION-SCREEN: END OF BLOCK b1.
