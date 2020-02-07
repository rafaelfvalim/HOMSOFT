*&---------------------------------------------------------------------*
*&  Include           ZHMS_CONTROLE_180_TOP
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Tables
*----------------------------------------------------------------------*
TABLES: zhms_tb_docmn,
        zhms_tb_cabdoc,
        j_1bnfdoc.

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
         nfenum      TYPE j_1bnfdoc-nfenum, "Nota fiscal
         nfenum_ent  TYPE j_1bnfdoc-nfenum, "Nota fiscal
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
         color       TYPE char4,
       END OF ty_outtab,

       BEGIN OF ty_doclin,
         docnum    TYPE j_1bnfdoc-docnum,
         nfenum    TYPE j_1bnfdoc-nfenum,
         docdat    TYPE j_1bnfdoc-docdat,
         bukrs     TYPE j_1bnfdoc-bukrs,
         branch    TYPE j_1bnfdoc-branch,
         parvw     TYPE j_1bnfdoc-parvw,
         parid     TYPE j_1bnfdoc-parid,
         brgew     TYPE j_1bnfdoc-brgew,
         itmnum    TYPE j_1bnflin-itmnum,
         matnr     TYPE j_1bnflin-matnr,
         maktx     TYPE j_1bnflin-maktx,
         menge     TYPE j_1bnflin-menge,
         nfe_c     TYPE char200,
         nf_esc    TYPE char10,
         doc_esc   TYPE char10,
         menge_esc TYPE char20,
         value     TYPE zhms_tb_docmn-value,
       END OF ty_doclin,

       BEGIN OF ty_active,
         docnum    TYPE j_1bnfe_active-docnum,
         regio     TYPE j_1bnfe_active-regio,
         nfyear    TYPE j_1bnfe_active-nfmonth,
         nfmonth   TYPE j_1bnfe_active-nfmonth,
         stcd1     TYPE j_1bnfe_active-stcd1,
         model     TYPE j_1bnfe_active-model,
         serie     TYPE j_1bnfe_active-nfnum9,
         nfnum9    TYPE j_1bnfe_active-nfnum9,
         docnum9   TYPE j_1bnfe_active-docnum9,
         cdv       TYPE j_1bnfe_active-cdv,
         value     TYPE zhms_tb_docmn-value,
       END OF ty_active.

TYPES: BEGIN OF ty_cfop_180.
        INCLUDE STRUCTURE zhms_tb_cfop180.
TYPES: END OF ty_cfop_180.

*----------------------------------------------------------------------*
* Tabelas internas
*----------------------------------------------------------------------*
DATA: it_chave      TYPE TABLE OF ty_chave,
      it_docmn      TYPE TABLE OF ty_docmn,
      it_docmn_ref  TYPE TABLE OF ty_docmn,
      it_active     TYPE TABLE OF ty_active,
      it_cabdoc     TYPE TABLE OF zhms_tb_cabdoc,
      it_doc_det    TYPE TABLE OF ty_docmn,
      it_itens      TYPE TABLE OF ty_itens,
      it_outtab     TYPE TABLE OF ty_outtab,
      it_outtab_aux TYPE TABLE OF ty_outtab,
      it_fcat1      TYPE lvc_t_fcat,
      it_item       TYPE TABLE OF bapi_j_1bnflin,
      it_doclin     TYPE TABLE OF ty_doclin,
      it_doclin_aux TYPE TABLE OF ty_doclin,
      it_fig_data   TYPE w3mime OCCURS 0,
      it_query      TYPE w3query OCCURS 1 WITH HEADER LINE,
      it_html       TYPE w3html OCCURS 1,
      it_cfop_180   TYPE TABLE OF ty_cfop_180.

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
           c_stat    TYPE c LENGTH 4 VALUE 'STAT',
           c_upda    TYPE c LENGTH 4 VALUE 'UPD',
           c_ok      TYPE c LENGTH 2 VALUE 'OK',
           c_canc    TYPE c LENGTH 4 VALUE 'CANC',
           c_sair    TYPE c LENGTH 4 VALUE 'SAIR',
           c_voltar  TYPE c LENGTH 6 VALUE 'VOLTAR',
           c_filtrar TYPE c LENGTH 7 VALUE 'FILTRAR',
           c_a       TYPE c LENGTH 1 VALUE 'A',
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
      wa_active     TYPE ty_active,
      wa_chave      TYPE ty_chave,
      wa_itens      TYPE ty_itens,
      wa_cabdoc     TYPE zhms_tb_cabdoc,
      wa_outtab     TYPE ty_outtab,
      wa_layout1    TYPE lvc_s_layo,
*      wa_layout1    TYPE slis_layout_alv,
      wa_variant    TYPE disvariant,
      wa_layout4    TYPE lvc_s_layo,
      wa_fcat1      TYPE lvc_s_fcat,
      wa_header     TYPE bapi_j_1bnfdoc,
      wa_item       TYPE bapi_j_1bnflin,
      wa_item_tax   TYPE bapi_j_1bnfstx,
      wa_doclin     TYPE ty_doclin,
      wa_doclin_aux TYPE ty_doclin,
      wa_stylerow   TYPE lvc_s_styl,
      wa_cfop_180   TYPE ty_cfop_180.

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
      go_notas     TYPE REF TO cl_gui_custom_container,
      go_alv       TYPE REF TO cl_gui_alv_grid,
      go_cont_fig  TYPE REF TO cl_gui_docking_container,
      go_fig       TYPE REF TO cl_gui_picture.
