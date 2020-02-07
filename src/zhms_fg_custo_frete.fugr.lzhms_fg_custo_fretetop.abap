FUNCTION-POOL zhms_fg_custo_frete.          "MESSAGE-ID ..

* INCLUDE LZHMS_FG_CUSTO_FRETED...           " Local class definition

*--------------------------------------------------*
*               Tipos                              *
*--------------------------------------------------*
TYPES: BEGIN OF ty_j1bnfdoc,
         docnum TYPE j_1bnfdoc-docnum,
         nfenum TYPE j_1bnfdoc-nfenum,
       END OF ty_j1bnfdoc,

       BEGIN OF ty_j1bnflin,
         docnum TYPE j_1bnflin-docnum,
         itmnum TYPE j_1bnflin-itmnum,
         cfop   TYPE j_1bnflin-cfop,
         refkey TYPE j_1bnflin-refkey,
         tknum  TYPE vttp-tknum,
         nct    TYPE znct,
       END OF ty_j1bnflin,

       BEGIN OF ty_nfeative,
         docnum  TYPE j_1bnfe_active-docnum,
         regio   TYPE j_1bnfe_active-regio,
         nfyear  TYPE j_1bnfe_active-nfyear,
         nfmonth TYPE j_1bnfe_active-nfmonth,
         stcd1   TYPE j_1bnfe_active-stcd1,
         model   TYPE j_1bnfe_active-model,
         serie   TYPE j_1bnfe_active-serie,
         nfnum9  TYPE j_1bnfe_active-nfnum9,
         docnum9 TYPE j_1bnfe_active-docnum9,
         cdv     TYPE j_1bnfe_active-cdv,
       END OF ty_nfeative,

       BEGIN OF ty_vbrp,
         vbeln TYPE vbrp-vbeln,
         posnr TYPE vbrp-posnr,
         vgbel TYPE vbrp-vgbel,
         vgpos TYPE vbrp-vgpos, " " 06/08/2019
       END OF ty_vbrp,

       BEGIN OF ty_vttp_vbrp,
         tknum TYPE vttp-tknum,
         tpnum TYPE vttp-tpnum,
         vbeln TYPE vbrp-vbeln,
       END OF ty_vttp_vbrp,

       BEGIN OF ty_fatura,
         chave           TYPE zhms_tb_fatura-chave,
         numerodocumento TYPE zhms_tb_fatura-numerodocumento,
         nct             TYPE zhms_tb_fatura-nct,
         ndoc            TYPE zhms_tb_fatura-ndoc,
         valorbruto      TYPE zhms_tb_fatura-valorbruto,
       END OF ty_fatura,

       BEGIN OF ty_vfkp,
         fknum TYPE vfkp-fknum,
         fkpos TYPE vfkp-fkpos,
         rebel TYPE vfkp-rebel,
         stfre TYPE vfkp-stfre,
         stabr TYPE vfkp-stabr,
         kzwi1 TYPE vfkp-kzwi1,
         ebeln TYPE vfkp-ebeln,
         postx TYPE vfkp-postx,
       END OF ty_vfkp,

       BEGIN OF ty_ekbe,
         ebeln TYPE ekbe-ebeln,
         ebelp type ekbe-ebelp,
         wrbtr TYPE ekbe-wrbtr,
         lfbnr TYPE ekbe-lfbnr,
         lfpos TYPE ekbe-lfpos,
       END OF ty_ekbe,


       BEGIN OF ty_vfkn,
         fknum TYPE vfkn-fknum,
         fkpos TYPE vfkn-fkpos,
         lfnkn TYPE vfkn-lfnkn,
         rebel TYPE vfkn-rebel,
         repos TYPE vfkn-repos,
       END OF ty_vfkn,

       BEGIN OF ty_vttp,
         tknum TYPE vttp-tknum,
         tpnum TYPE vttp-tpnum,
         vbeln TYPE vttp-vbeln,
       END OF ty_vttp,

       BEGIN OF ty_vfkk,
         fknum TYPE vfkk-fknum,
         stabr TYPE vfkk-stabr,
       END OF ty_vfkk,

***" 06/08/2019 -->>
*       BEGIN OF ty_refkey,
*         vbeln TYPE vbeln,
*       END OF ty_refkey,

       BEGIN OF ty_rseg,
         belnr TYPE belnr_d,
         gjahr TYPE gjahr,
         buzei TYPE rblgp,
         ebeln TYPE ebeln,
         ebelp TYPE ebelp,
         wrbtr TYPE wrbtr,
         mwskz TYPE mwskz,
         werks TYPE WERKS_D,
       END OF ty_rseg,

       BEGIN OF ty_rbkp,
         belnr  TYPE re_belnr,
         gjahr  TYPE gjahr,
         xblnr  TYPE xblnr1,
         lifnr  TYPE lifre,
         rmwwr  TYPE rmwwr,
         mwskz1	TYPE mwskz_mrm1,
       END OF ty_rbkp,
***" 06/08/2019 <<--

       BEGIN OF ty_fatura_val,
         fatura     TYPE zhms_tb_fatura-numerodocumento,
         valorbruto TYPE zhms_tb_fatura-valorbruto,
       END OF ty_fatura_val,

       BEGIN OF ty_lfa1,
         lifnr TYPE lfa1-lifnr,
         stcd1 TYPE lfa1-stcd1,
         stcd2 TYPE lfa1-stcd2,
       END OF ty_lfa1,

***" 10/08/2019 -->>
       BEGIN OF ty_fatura_cte,
         idtitulo        TYPE  zhms_tb_fatura-idtitulo,
         numerodocumento TYPE  zhms_tb_fatura-numerodocumento,
         chave           TYPE  zhms_tb_fatura-chave,
         chave_fat       TYPE  zhms_tb_fatura-chave_fat,
         razaosocial     TYPE  zhms_tb_fatura-razaosocial,
       END OF ty_fatura_cte,

       BEGIN OF ty_j1bnflin_dt,
         docnum TYPE j_1bdocnum,
         itmnum TYPE j_1bitmnum,
         refkey TYPE j_1brefkey,
         refitm TYPE j_1brefitm,
       END OF ty_j1bnflin_dt,

       BEGIN OF ty_refkey,
         refkey TYPE j_1brefkey,
         vbeln  TYPE vbeln,
       END OF ty_refkey,

       BEGIN OF ty_chave,
         regio   TYPE j_1bregio,
         nfyear  TYPE j_1byear,
         nfmonth TYPE j_1bmonth,
         stcd1   TYPE j_1bstcd1,
         model   TYPE j_1bmodel,
         serie   TYPE j_1bseries,
         nfnum9  TYPE j_1bnfnum9,
         docnum9 TYPE j_1bdocnum9,
         cdv     TYPE j_1bcheckdigit,
       END OF ty_chave,

       BEGIN OF ty_likp,
         vbeln TYPE vbeln_vl,
         btgew TYPE gsgew,
       END OF ty_likp.


*--------------------------------------------------*
*               Tabelas Internas                   *
*--------------------------------------------------*
DATA: ti_zentrada       TYPE TABLE OF zent_custo_frete,
      ti_zentrada2      TYPE TABLE OF zatuvr_custo_frete,
      ti_zentrada_miro  TYPE TABLE OF zent_executa_miro_cte,
      ti_zentrada_cte   TYPE TABLE OF zent_estorna_miro_cte,
      ti_zentrada_j1b1n TYPE TABLE OF zent_escritura_cte,
      ti_j1bnfdoc       TYPE TABLE OF ty_j1bnfdoc,
      ti_j1bnflin       TYPE TABLE OF ty_j1bnflin,
      ti_j1bnfdoc_aux   TYPE TABLE OF ty_j1bnfdoc,
      ti_j1bnflin_aux   TYPE TABLE OF ty_j1bnflin,
      ti_nfeative       TYPE TABLE OF ty_nfeative,
      ti_vbrp           TYPE TABLE OF ty_vbrp,
      ti_ekbe           TYPE TABLE OF ty_ekbe,
      ti_vbrp_aux       TYPE TABLE OF ty_vbrp,
      ti_vttp_vbrp      TYPE TABLE OF ty_vttp_vbrp,
      ti_status         TYPE TABLE OF zhms_tb_status,
      ti_fatura         TYPE TABLE OF ty_fatura,
      ti_vfkp           TYPE TABLE OF ty_vfkp,
      ti_vfkn           TYPE TABLE OF ty_vfkn,
      ti_vfkn_aux       TYPE table of ty_vfkn,
      ti_vttp           TYPE TABLE OF ty_vttp,
      ti_vfkk           TYPE TABLE OF ty_vfkk,
      ti_return         TYPE TABLE OF bapireturn,
      ti_return_erro    TYPE TABLE OF bapireturn,
      ti_return_suces   TYPE TABLE OF bapireturn,
      ti_bdcdata        TYPE STANDARD TABLE OF  bdcdata,
      ti_msgs           TYPE STANDARD TABLE OF  bdcmsgcoll,
      ti_refkey         TYPE STANDARD TABLE OF  ty_refkey, " " 06/08/2019
      ti_docmn          TYPE TABLE OF zhms_tb_docmn,
      ti_zentrada_valid TYPE TABLE OF zent_valida_dt,
      ti_lfa1           TYPE TABLE OF ty_lfa1,
      ti_tb_log         TYPE TABLE OF zhms_tb_log,
      ti_fatura_cte     TYPE TABLE OF ty_fatura_cte,
      ti_docmn_nfe      TYPE TABLE OF zhms_tb_docmn,
      ti_j1bnflin_dt    TYPE TABLE OF ty_j1bnflin_dt,
      ti_tb_status      TYPE TABLE OF zhms_tb_status,
      ti_fatura_val     TYPE TABLE OF ty_fatura_val,
      ti_tb_status_ax   TYPE TABLE OF zhms_tb_status.

***" 10/08/2019 -->>
*--------------------------------------------------*
*                  Field-Symbols                   *
*--------------------------------------------------*
FIELD-SYMBOLS <fs_tab_docmn> TYPE ANY TABLE. "zhsms_tb_docmn.
FIELD-SYMBOLS <fs_wa_docmn>  TYPE zhms_tb_docmn.

***" 10/08/2019 <<--

*--------------------------------------------------*
*                  Work Areas                      *
*--------------------------------------------------*
DATA: wa_zentrada           TYPE zent_custo_frete,
      wa_zentrada2          TYPE zatuvr_custo_frete,
      wa_zentrada_miro      TYPE zent_executa_miro_cte,
      wa_zentrada_cte       TYPE zent_estorna_miro_cte,
      wa_zentrada_j1b1n     TYPE zent_escritura_cte,
      wa_j1bnfdoc           TYPE ty_j1bnfdoc,
      wa_j1bnflin_dt        TYPE ty_j1bnflin_dt,
      wa_nfeative           TYPE ty_nfeative,
      wa_vbrp               TYPE ty_vbrp,
      wa_vttp_vbrp          TYPE ty_vttp_vbrp,
      wa_status             TYPE zhms_tb_status,
      wa_fatura             TYPE ty_fatura,
      wa_vfkp               TYPE ty_vfkp,
      wa_vfkn               TYPE ty_vfkn,
      wa_vfkn_aux           TYPE ty_vfkn,
      wa_vttp               TYPE ty_vttp,
      wa_vfkk               TYPE ty_vfkk,
      wa_return             TYPE bapireturn,
      wa_return_erro        TYPE bapireturn,
      wa_return_suces       TYPE bapireturn,
      wa_bdcdata            TYPE bdcdata,
      wa_msgs               TYPE bdcmsgcoll,
      wa_refkey             TYPE ty_refkey, " " 06/08/2019
      wa_zentrada_valid     TYPE zent_valida_dt,
      wa_zentrada_valid_aux TYPE zent_valida_dt,
      wa_fatura_val         TYPE ty_fatura_val,
      wa_lfa1               TYPE ty_lfa1,
      wa_tb_log             TYPE zhms_tb_log,
      wa_zentrada_dt        TYPE zent_valida_dt,
      wa_docmn              TYPE zhms_tb_docmn,
      wa_fatura_cte         TYPE ty_fatura_cte,
      wa_j1bnflin           TYPE ty_j1bnflin,
      wa_tb_status          TYPE zhms_tb_status,
      wa_chave              TYPE ty_chave,
      wa_ekbe               TYPE ty_ekbe.

*--------------------------------------------------*
*                   Variáveis                      *
*--------------------------------------------------*
DATA: v_tabix      TYPE sy-tabix,
      v_ch_acesso  TYPE zhms_de_chave,
      v_fknum      TYPE vfkp-fknum,
      v_nct        TYPE znct,
      v_flag       TYPE char1,
      v_inv_doc_no TYPE bapi_incinv_fld-inv_doc_no,
      v_fisc_year  TYPE bapi_incinv_fld-fisc_year,
      v_valor      TYPE zhms_tb_fatura-valorbruto,
      v_idtitulo   TYPE char10,
      v_fatura     TYPE char10,
      v_chave      TYPE char44,
      v_demi       TYPE char10,
      v_mensagem   TYPE char50,
      v_dt         TYPE char01,
      v_cf         TYPE char01,
      v_po         TYPE char01,
      v_mi         TYPE char01,
      v_nf         TYPE char01,
      v_docnum     TYPE j_1bdocnum,
      v_cte_esct   TYPE char10,
      v_pedido     TYPE ebeln,
      v_kposn      TYPE vfkn-fkpos,
      v_carregado  TYPE char01.
