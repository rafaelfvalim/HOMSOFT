*----------------------------------------------------------------------*
*                                                                      *
*           |--------------------------------------------|             *
*           |          H   O   M   I   N   E             |             *
*           |--------------------------------------------|             *
*                                                                      *
*----------------------------------------------------------------------*
* Transação:     ZHMS_180_DIAS                                         *
* Programa:      ZHMS_180_DIAS_FULL                                    *
* Descrição:     Controle de estoque de 180 dias para sub-contratação  *
* Desenvolvedor: Rodolfo Caruzo                                        *
* Data:          08/03/2018                                            *
*----------------------------------------------------------------------*
* Roseli | Tradução EN e ES | 02/10/2018                               *
*----------------------------------------------------------------------*
REPORT zhms_180_dias_full.

*----------------------------------------------------------------------*
* Tables
*----------------------------------------------------------------------*
TABLES: zhms_tb_docmn,
        zhms_tb_cabdoc.

*----------------------------------------------------------------------*
* Estruturas
*----------------------------------------------------------------------*
TYPES: BEGIN OF ty_chave,
         chave TYPE zhms_tb_docmn-chave,
       END OF ty_chave,

       BEGIN OF ty_docmn,
         chave TYPE zhms_tb_docmn-chave,
         seqnr TYPE zhms_tb_docmn-seqnr,
         mneum TYPE zhms_tb_docmn-mneum,
         dcitm TYPE zhms_tb_docmn-dcitm,
         value TYPE zhms_tb_docmn-value,
       END OF ty_docmn,

       BEGIN OF ty_itens,
         chave TYPE zhms_tb_docmn-chave,
         dcitm TYPE zhms_tb_docmn-dcitm,
       END OF ty_itens,

       BEGIN OF ty_outtab,
         bukrs       TYPE t001-bukrs,
         nf_cli      TYPE zhms_tb_docmn-value,
         dt_emi      TYPE sy-datum,
         st_escr     TYPE char4,
         nf_escr     TYPE char15,
         nf_itm      TYPE char10,
         material    TYPE j_1bnflin-matnr,
         descricao   TYPE makt-maktx,
         qtd_nf      TYPE p DECIMALS 2,
         chave       TYPE zhms_tb_docmn-chave,
         dias        TYPE i,
         status      TYPE char4,
         qtd_pend    TYPE p DECIMALS 2,
         qtd_dev     TYPE p DECIMALS 2,
         qtd_estoque TYPE p DECIMALS 2,
         qtd_forn    TYPE p DECIMALS 2,
         mark        TYPE c,
         field_style TYPE lvc_t_styl,
       END OF ty_outtab,

       BEGIN OF ty_leg,
         icone TYPE char4,
         descr TYPE char80,
       END OF ty_leg,

       BEGIN OF ty_detalhes,
         tp_nf        TYPE char20,
         nf_saida     TYPE j_1bnfdoc-docnum,
         docnum_sai   TYPE char10,
         nf_escr_dev  TYPE char15,
         doc_escr_dev TYPE char15,
         dt_emi_sai   TYPE char10,
         material     TYPE j_1bnflin-matnr,
         qtd_nf_sai   TYPE p DECIMALS 2,
         cli_forn     TYPE lfa1-lifnr,
         descr_forn   TYPE lfa1-name1,
         qtd_dev_forn TYPE p DECIMALS 2,
         dias_forn    TYPE i,
         status_dias  TYPE char4,
       END OF ty_detalhes,

       BEGIN OF ty_det_char,
         tp_nf        TYPE string,
         nf_saida     TYPE string,
         docnum_sai   TYPE string,
         nf_escr_dev  TYPE string,
         doc_escr_dev TYPE string,
         dt_emi_sai   TYPE string,
         material     TYPE string,
         qtd_nf_sai   TYPE string,
         cli_forn     TYPE string,
         descr_forn   TYPE string,
         qtd_dev_forn TYPE string,
         dias_forn    TYPE string,
         status_dias  TYPE string,
       END OF ty_det_char,

       BEGIN OF ty_doclin,
         docnum    TYPE j_1bnfdoc-docnum,
         nfenum    TYPE j_1bnfdoc-nfenum,
         docdat    TYPE j_1bnfdoc-docdat,
         parvw     TYPE j_1bnfdoc-parvw,
         parid     TYPE j_1bnfdoc-parid,
         matnr     TYPE j_1bnflin-matnr,
         menge     TYPE j_1bnflin-menge,
         nfe_c     TYPE char200,
         nf_esc    TYPE char10,
         doc_esc   TYPE char10,
         menge_esc TYPE char20,
       END OF ty_doclin,

       BEGIN OF ty_notas,
         nf          TYPE char15,
         nf_entrada  TYPE char15,
         chave       TYPE zhms_tb_docmn-chave,
         dcitm       TYPE zhms_tb_docmn-dcitm,
         bukrs       TYPE t001-bukrs,
         docdat      TYPE j_1bnfdoc-docdat,
         cli_forn    TYPE lfa1-lifnr,
         descr_forn  TYPE lfa1-name1,
         material    TYPE j_1bnflin-matnr,
         qtd_nf      TYPE i,
         werks       TYPE j_1bnflin-werks,
         ncm         TYPE j_1bnflin-nbm,
         cfop        TYPE j_1bnflin-cfop,
         netpr       TYPE j_1bnflin-netpr,
         icms        TYPE char4,
         base        TYPE j_1bbase,
         rate        TYPE j_1btxrate,
         mensagem    TYPE string,
         cellcolor   TYPE lvc_t_scol,
         field_style TYPE lvc_t_styl,
       END OF ty_notas,

       BEGIN OF ty_seqnr,
         seqnr TYPE zhms_tb_docmn-seqnr,
       END OF ty_seqnr.

TYPES: BEGIN OF ty_header_bapi,
         chave TYPE zhms_tb_docmn-chave,
         nf    TYPE char15.
        INCLUDE STRUCTURE bapi_j_1bnfdoc.
TYPES: END OF ty_header_bapi.

TYPES: BEGIN OF ty_item_bapi,
         chave TYPE zhms_tb_docmn-chave,
         dcitm TYPE zhms_tb_docmn-dcitm,
         nf    TYPE char15.
        INCLUDE STRUCTURE bapi_j_1bnflin.
TYPES: END OF ty_item_bapi.

TYPES: BEGIN OF ty_item,
        dcitm TYPE zhms_tb_docmn-dcitm.
        INCLUDE STRUCTURE bapi_j_1bnflin.
TYPES: END OF ty_item.

TYPES: BEGIN OF ty_tax_bapi,
         chave TYPE zhms_tb_docmn-chave,
         dcitm TYPE zhms_tb_docmn-dcitm,
         nf    TYPE char15.
        INCLUDE STRUCTURE bapi_j_1bnfstx.
TYPES: END OF ty_tax_bapi.

*----------------------------------------------------------------------*
* Tabelas internas
*----------------------------------------------------------------------*
DATA: it_chave      TYPE TABLE OF ty_chave,
      it_docmn      TYPE TABLE OF ty_docmn,
      it_cabdoc     TYPE TABLE OF zhms_tb_cabdoc,
      it_doc_det    TYPE TABLE OF ty_docmn,
      it_itens      TYPE TABLE OF ty_itens,
      it_outtab     TYPE TABLE OF ty_outtab,
      it_outtab_aux TYPE TABLE OF ty_outtab,
      it_leg        TYPE TABLE OF ty_leg,
      it_detalhes   TYPE TABLE OF ty_detalhes,
      it_det        TYPE TABLE OF ty_det_char,
      it_det_char   TYPE TABLE OF ty_det_char,
      it_notas      TYPE TABLE OF ty_notas,
      it_notas_aux  TYPE TABLE OF ty_notas,
      it_fcat1      TYPE lvc_t_fcat,
      it_fcat2      TYPE lvc_t_fcat,
      it_fcat3      TYPE lvc_t_fcat,
      it_fcat4      TYPE lvc_t_fcat,
      it_seqnr      TYPE TABLE OF ty_seqnr,
      it_h_bapi     TYPE TABLE OF ty_header_bapi,
      it_item       TYPE TABLE OF bapi_j_1bnflin,
      it_i_bapi     TYPE TABLE OF ty_item_bapi,
      it_item_tax   TYPE TABLE OF bapi_j_1bnfstx,
      it_i_bapi_tax TYPE TABLE OF ty_tax_bapi,
      it_return     TYPE TABLE OF bapiret2,
      it_doclin     TYPE TABLE OF ty_doclin,
      it_doclin_aux TYPE TABLE OF ty_doclin,
      it_sort       TYPE lvc_t_sort,
      it_fcode      TYPE TABLE OF sy-ucomm,
      it_seltab     TYPE TABLE OF rsparams,
      it_fig_data   TYPE w3mime OCCURS 0,
      it_query      TYPE w3query OCCURS 1 WITH HEADER LINE,
      it_html       TYPE w3html OCCURS 1,
      it_evt        TYPE cntl_simple_events.

*----------------------------------------------------------------------*
* Constantes
*----------------------------------------------------------------------*
CONSTANTS: c_esc     TYPE c LENGTH 4 VALUE '@B4@',
           c_n_esc   TYPE c LENGTH 4 VALUE '@B6@',
           c_100     TYPE c LENGTH 4 VALUE '@08@',
           c_100_180 TYPE c LENGTH 4 VALUE '@09@',
           c_180     TYPE c LENGTH 4 VALUE '@0A@',
           c_devol   TYPE c LENGTH 4 VALUE '@01@',
           c_na      TYPE c LENGTH 4 VALUE '@BZ@',
           c_lf      TYPE c LENGTH 2 VALUE 'LF',
           c_ag      TYPE c LENGTH 2 VALUE 'AG',
           c_nfcli   TYPE c LENGTH 5 VALUE 'NFCLI',
           c_nfforn  TYPE c LENGTH 6 VALUE 'NFFORN',
           c_nnf     TYPE c LENGTH 3 VALUE 'NNF',
           c_stat    TYPE c LENGTH 4 VALUE 'STAT',
           c_upda    TYPE c LENGTH 4 VALUE 'UPD',
           c_ok      TYPE c LENGTH 2 VALUE 'OK',
           c_canc    TYPE c LENGTH 4 VALUE 'CANC',
           c_sair    TYPE c LENGTH 4 VALUE 'SAIR',
           c_voltar  TYPE c LENGTH 6 VALUE 'VOLTAR',
           c_filtrar TYPE c LENGTH 7 VALUE 'FILTRAR',
           c_sign    TYPE c LENGTH 1 VALUE 'I',
           c_option  TYPE c LENGTH 2 VALUE 'EQ',
           c_zero    TYPE c LENGTH 1 VALUE '0',
           c_nf      TYPE c LENGTH 2 VALUE 'NF'.

*----------------------------------------------------------------------*
* Intervalos
*----------------------------------------------------------------------*
DATA: rg_filtro TYPE RANGE OF zhms_tb_docmn-chave,
      rg_nf_det TYPE RANGE OF j_1bnfdoc-docnum.

*----------------------------------------------------------------------*
* Work areas
*----------------------------------------------------------------------*
DATA: wa_filtro     LIKE LINE OF rg_filtro,
      wa_nf_det     LIKE LINE OF rg_nf_det,
      wa_docmn      TYPE ty_docmn,
      wa_chave      TYPE ty_chave,
      wa_itens      TYPE ty_itens,
      wa_cabdoc     TYPE zhms_tb_cabdoc,
      wa_outtab     TYPE ty_outtab,
      wa_leg        TYPE ty_leg,
      wa_detalhes   TYPE ty_detalhes,
      wa_det_char   TYPE ty_det_char,
      wa_det        TYPE ty_det_char,
      wa_notas      TYPE ty_notas,
      wa_notas_aux  TYPE ty_notas,
      wa_layout1    TYPE lvc_s_layo,
      wa_layout4    TYPE lvc_s_layo,
      wa_fcat1      TYPE lvc_s_fcat,
      wa_seqnr      TYPE ty_seqnr,
      wa_fcat2      TYPE lvc_s_fcat,
      wa_fcat3      TYPE lvc_s_fcat,
      wa_fcat4      TYPE lvc_s_fcat,
      wa_h_bapi     TYPE ty_header_bapi,
      wa_header     TYPE bapi_j_1bnfdoc,
      wa_i_bapi     TYPE ty_item_bapi,
      wa_i_bapi_tax TYPE ty_tax_bapi,
      wa_item       TYPE bapi_j_1bnflin,
      wa_item_tax   TYPE bapi_j_1bnfstx,
      wa_doclin     TYPE ty_doclin,
      wa_stylerow   TYPE lvc_s_styl,
      wa_color      TYPE lvc_s_scol,
      wa_seltab     TYPE rsparams,
      wa_evt        TYPE cntl_simple_event.

*----------------------------------------------------------------------*
* Variáveis globais
*----------------------------------------------------------------------*
DATA: gv_docnum      TYPE bapi_j_1bnfdoc-docnum,
      gv_seqnr       TYPE zhms_tb_docmn-seqnr,
      gv_tp_nf       TYPE char20,
      gv_menge       TYPE j_1bnflin-menge,
      gv_forn        TYPE j_1bnflin-menge,
      gv_tabix       TYPE sy-tabix,
      gv_resp        TYPE c,
      gv_url         TYPE char256,
      gv_fig_len     TYPE i,
      gv_times       TYPE i,
      gv_return      TYPE w3param-ret_code,
      gv_content     TYPE w3param-cont_type,
      gv_cont_len    TYPE w3param-cont_len,
      gv_matnr       TYPE mara-matnr,
      gv_header_tree TYPE treev_hhdr,
      gv_check_1     TYPE c,
      gv_check_2     TYPE c,
      gv_check_3     TYPE c,
      gv_check_4     TYPE c,
      gv_check_5     TYPE c,
      gv_check_6     TYPE c,
      gv_nota        TYPE j_1bnfdoc-docnum.

*----------------------------------------------------------------------*
* Objetos
*----------------------------------------------------------------------*
DATA: go_grid      TYPE REF TO cl_gui_custom_container,
      go_leg       TYPE REF TO cl_gui_custom_container,
      go_notas     TYPE REF TO cl_gui_custom_container,
      go_alv       TYPE REF TO cl_gui_alv_grid,
      go_alv_leg   TYPE REF TO cl_gui_alv_grid,
      go_alv_notas TYPE REF TO cl_gui_alv_grid,
      go_tree      TYPE REF TO cl_gui_alv_tree,
      go_cont_fig  TYPE REF TO cl_gui_docking_container,
      go_fig       TYPE REF TO cl_gui_picture,
      go_cont_tree TYPE REF TO cl_gui_custom_container.

*----------------------------------------------------------------------*
* TELA DE SELEÇÃO
*----------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK a01 WITH FRAME TITLE text-001.
SELECT-OPTIONS: s_bukrs  FOR zhms_tb_cabdoc-bukrs,
                s_branch FOR zhms_tb_cabdoc-branch,
                s_docnr  FOR zhms_tb_cabdoc-docnr,
                s_chave  FOR zhms_tb_cabdoc-chave,
                s_parid  FOR zhms_tb_cabdoc-parid,
                s_lncdt  FOR zhms_tb_cabdoc-lncdt.
SELECTION-SCREEN: END OF BLOCK a01.

* Carrega imagem na tela de seleção
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_carrega_imagem.

START-OF-SELECTION.

* Libera o container da imagem
  CALL METHOD go_fig->free.

  PERFORM f_seleciona_dados.

* Chama a tela principal do cockpit
  CALL SCREEN 200.

*----------------------------------------------------------------------*
*       CLASS LCL_EVENT_RECEIVER DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_event_receiver DEFINITION .

  PUBLIC SECTION.

    METHODS: hotspot_click FOR EVENT hotspot_click OF cl_gui_alv_grid
      IMPORTING e_row_id
                e_column_id.

ENDCLASS .                    "LCL_EVENT_RECEIVER DEFINITION

*----------------------------------------------------------------------*
*       CLASS LCL_EVENT_RECEIVER IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_event_receiver IMPLEMENTATION.

  METHOD hotspot_click.

    PERFORM f_detalhes USING e_row_id e_column_id.

  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK

ENDCLASS.                    "LCL_EVENT_RECEIVER IMPLEMENTATION

DATA go_event TYPE REF TO lcl_event_receiver.

*----------------------------------------------------------------------*
*       CLASS LCL_EVENT_LINK DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_event_link DEFINITION .

  PUBLIC SECTION.

    METHODS: link_click FOR EVENT link_click OF cl_gui_alv_tree
      IMPORTING fieldname
                node_key.

ENDCLASS .                    "LCL_EVENT_LINK DEFINITION

*----------------------------------------------------------------------*
*       CLASS LCL_EVENT_LINK IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_event_link IMPLEMENTATION.

  METHOD link_click.

    READ TABLE it_det INTO wa_det INDEX node_key.

    MOVE wa_det-docnum_sai TO gv_nota.

    SET PARAMETER ID 'JEF' FIELD gv_nota.

    CALL TRANSACTION 'J1B3N' AND SKIP FIRST SCREEN.

  ENDMETHOD.                    "HANDLE_LINK_CLICK

ENDCLASS.                    "LCL_EVENT_LINK IMPLEMENTATION

DATA go_event_tree TYPE REF TO lcl_event_link.

INCLUDE zhms_180_dias_full_rotinas.
