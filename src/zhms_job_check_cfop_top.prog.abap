*&---------------------------------------------------------------------*
*&  Include           ZHMS_JOB_CHECK_CFOP_TOP
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Tables
*----------------------------------------------------------------------*
TABLES: zhms_tb_docmn,
        zhms_tb_cabdoc.

*----------------------------------------------------------------------*
* ESTRUTURAS
*----------------------------------------------------------------------*
TYPES: BEGIN OF ty_cfop_180.
        INCLUDE STRUCTURE zhms_tb_cfop180.
TYPES: END OF ty_cfop_180.

TYPES: BEGIN OF ty_j1bnfdoc,
         docnum       TYPE j_1bnfdoc-docnum, "Docnum
         nfenum       TYPE j_1bnfdoc-nfenum, "Nota fiscal
         docdat       TYPE j_1bnfdoc-docdat, "Data emissão
       END OF ty_j1bnfdoc,

       BEGIN OF ty_docmn,
         chave TYPE zhms_tb_docmn-chave,
         seqnr TYPE zhms_tb_docmn-seqnr,
         mneum TYPE zhms_tb_docmn-mneum,
         dcitm TYPE zhms_tb_docmn-dcitm,
         value TYPE zhms_tb_docmn-value,
       END OF ty_docmn,

       BEGIN OF ty_j1bnflin,
         docnum       TYPE j_1bnflin-docnum, "Docnum
         itmnum       TYPE j_1bnflin-itmnum, "Item
         matnr        TYPE j_1bnflin-matnr,  "Material
         maktx        TYPE j_1bnflin-maktx,  "Descrição material
         menge        TYPE j_1bnflin-menge,  "Quantidade NF-e
*         qnt_devolv   TYPE j_1bnflin-menge,  "Quantidade Devolvida
*         qnt_pendente TYPE j_1bnflin-menge,  "Quantidade Pendente
*         qnt_estoque  TYPE j_1bnflin-menge,  "Quantidade Estoque
*         qnt_fornec   TYPE j_1bnflin-menge,  "Quantidade Fornecedor
       END OF ty_j1bnflin,

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

       BEGIN OF ty_itens,
         chave TYPE zhms_tb_docmn-chave,
         dcitm TYPE zhms_tb_docmn-dcitm,
       END OF ty_itens,

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

       BEGIN OF ty_alv,
         status       TYPE icon-id,          "Status dias
         nfenum       TYPE j_1bnfdoc-nfenum, "Nota fiscal
         docdat       TYPE j_1bnfdoc-docdat, "Data emissão
         docnum       TYPE j_1bnflin-docnum, "Docnum
         itmnum       TYPE j_1bnflin-itmnum, "Item
         matnr        TYPE j_1bnflin-matnr,  "Material
         maktx        TYPE j_1bnflin-maktx,  "Descrição material
         menge        TYPE j_1bnflin-menge,  "Quantidade NF-e
         qnt_devolv   TYPE j_1bnflin-menge,  "Quantidade Devolvida
         qnt_pendente TYPE j_1bnflin-menge,  "Quantidade Pendente
         qnt_estoque  TYPE j_1bnflin-menge,  "Quantidade Estoque
         qnt_fornec   TYPE j_1bnflin-menge,  "Quantidade Fornecedor
         dias_est     TYPE i,                "Dias em Estoque
       END OF ty_alv.

*----------------------------------------------------------------------*
* Tabelas internas
*----------------------------------------------------------------------*
DATA: it_cfop_180   TYPE TABLE OF ty_cfop_180,
      it_fig_data   TYPE w3mime OCCURS 0,
      it_query      TYPE w3query OCCURS 1 WITH HEADER LINE,
      it_html       TYPE w3html OCCURS 1,
      it_evt        TYPE cntl_simple_events,
      it_docmn      TYPE TABLE OF ty_docmn,
      it_cabdoc     TYPE TABLE OF zhms_tb_cabdoc,
      it_doc_det    TYPE TABLE OF ty_docmn,
      it_itens      TYPE TABLE OF ty_itens,
      it_alv     TYPE TABLE OF ty_alv,
      it_outtab TYPE TABLE OF ty_outtab,
      it_outtab_aux TYPE TABLE OF ty_outtab,
*      it_leg        TYPE TABLE OF ty_leg,
*      it_detalhes   TYPE TABLE OF ty_detalhes,
*      it_det        TYPE TABLE OF ty_det_char,
*      it_det_char   TYPE TABLE OF ty_det_char,
*      it_notas      TYPE TABLE OF ty_notas,
*      it_notas_aux  TYPE TABLE OF ty_notas,
      it_fcat1      TYPE lvc_t_fcat,
*      it_fcat2      TYPE lvc_t_fcat,
*      it_fcat3      TYPE lvc_t_fcat,
*      it_fcat4      TYPE lvc_t_fcat,
*      it_seqnr      TYPE TABLE OF ty_seqnr,
*      it_h_bapi     TYPE TABLE OF ty_header_bapi,
*      it_item       TYPE TABLE OF bapi_j_1bnflin,
*      it_i_bapi     TYPE TABLE OF ty_item_bapi,
*      it_item_tax   TYPE TABLE OF bapi_j_1bnfstx,
*      it_i_bapi_tax TYPE TABLE OF ty_tax_bapi,
*      it_return     TYPE TABLE OF bapiret2,
      it_doclin     TYPE TABLE OF ty_doclin.
*      it_doclin_aux TYPE TABLE OF ty_doclin,
*      it_sort       TYPE lvc_t_sort,
*      it_fcode      TYPE TABLE OF sy-ucomm,
*      it_seltab     TYPE TABLE OF rsparams,

*----------------------------------------------------------------------*
* INTERVALOS
*----------------------------------------------------------------------*
DATA: rg_filtro TYPE RANGE OF zhms_tb_docmn-chave,
      rg_nf_det TYPE RANGE OF j_1bnfdoc-docnum.

*----------------------------------------------------------------------*
* Work areas
*----------------------------------------------------------------------*
DATA: wa_cfop_180   TYPE ty_cfop_180,
*      wa_filtro     LIKE LINE OF rg_filtro,
      wa_nf_det     LIKE LINE OF rg_nf_det,
      wa_docmn      TYPE ty_docmn,
*      wa_chave      TYPE ty_chave,
      wa_itens      TYPE ty_itens,
      wa_cabdoc     TYPE zhms_tb_cabdoc,
      wa_alv     TYPE ty_alv,
      wa_outtab TYPE  ty_outtab,
*      wa_leg        TYPE ty_leg,
*      wa_detalhes   TYPE ty_detalhes,
*      wa_det_char   TYPE ty_det_char,
*      wa_det        TYPE ty_det_char,
*      wa_notas      TYPE ty_notas,
*      wa_notas_aux  TYPE ty_notas,
      wa_layout1    TYPE lvc_s_layo,
*      wa_layout4    TYPE lvc_s_layo,
      wa_fcat1      TYPE lvc_s_fcat,
*      wa_seqnr      TYPE ty_seqnr,
*      wa_fcat2      TYPE lvc_s_fcat,
*      wa_fcat3      TYPE lvc_s_fcat,
*      wa_fcat4      TYPE lvc_s_fcat,
*      wa_h_bapi     TYPE ty_header_bapi,
*      wa_header     TYPE bapi_j_1bnfdoc,
*      wa_i_bapi     TYPE ty_item_bapi,
*      wa_i_bapi_tax TYPE ty_tax_bapi,
*      wa_item       TYPE bapi_j_1bnflin,
*      wa_item_tax   TYPE bapi_j_1bnfstx,
      wa_doclin     TYPE ty_doclin,
      wa_stylerow   TYPE lvc_s_styl.
*      wa_color      TYPE lvc_s_scol,
*      wa_seltab     TYPE rsparams,
*      wa_evt        TYPE cntl_simple_event.

*----------------------------------------------------------------------*
* CONSTANTES
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
     c_stat    TYPE c LENGTH 4 VALUE 'STAT',
     c_upda    TYPE c LENGTH 4 VALUE 'UPD',
     c_ok      TYPE c LENGTH 2 VALUE 'OK',
     c_canc    TYPE c LENGTH 4 VALUE 'CANC',
     c_sair    TYPE c LENGTH 4 VALUE 'SAIR',
     c_voltar  TYPE c LENGTH 6 VALUE 'VOLTAR',
*     c_filtrar TYPE c LENGTH 7 VALUE 'FILTRAR',
     c_sign    TYPE c LENGTH 1 VALUE 'I',
     c_option  TYPE c LENGTH 2 VALUE 'EQ',
     c_zero    TYPE c LENGTH 1 VALUE '0',
     c_nf      TYPE c LENGTH 2 VALUE 'NF'.

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
* OBJETOS
*----------------------------------------------------------------------*
DATA: go_grid      TYPE REF TO cl_gui_custom_container,
*      go_leg       TYPE REF TO cl_gui_custom_container,
*      go_notas     TYPE REF TO cl_gui_custom_container,
      go_alv       TYPE REF TO cl_gui_alv_grid,
*      go_alv_leg   TYPE REF TO cl_gui_alv_grid,
*      go_alv_notas TYPE REF TO cl_gui_alv_grid,
*      go_tree      TYPE REF TO cl_gui_alv_tree,
      go_cont_fig  TYPE REF TO cl_gui_docking_container,
      go_fig       TYPE REF TO cl_gui_picture.
*      go_cont_tree TYPE REF TO cl_gui_custom_container.

*----------------------------------------------------------------------*
* TELA DE SELEÇÃO
*----------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK b01 WITH FRAME TITLE text-001.
SELECT-OPTIONS: s_bukrs  FOR zhms_tb_cabdoc-bukrs,
                s_branch FOR zhms_tb_cabdoc-branch,
                s_docnr  FOR zhms_tb_cabdoc-docnr,
                s_chave  FOR zhms_tb_cabdoc-chave,
                s_parid  FOR zhms_tb_cabdoc-parid,
                s_lncdt  FOR zhms_tb_cabdoc-lncdt.
SELECTION-SCREEN: END OF BLOCK b01.

* Carrega imagem na tela de seleção
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_carrega_imagem.
