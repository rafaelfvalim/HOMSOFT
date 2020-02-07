

FUNCTION-POOL zhms_fg_ruler MESSAGE-ID zhms_ms_ruler.


*---------------------------------------*
*           Tabelas Internas            *
*---------------------------------------*
DATA:    it_evflow        TYPE STANDARD TABLE OF zhms_tb_ev_flow,  " Eventos: Fluxos
         it_scflow        TYPE STANDARD TABLE OF zhms_tb_scen_flo, " Cenários de Negócio: Fluxos
         it_flow          TYPE STANDARD TABLE OF zhms_es_flow,     " Fluxo de processamento
         it_flwdoc        TYPE STANDARD TABLE OF zhms_tb_flwdoc,   " Etapas de fluxo para o documento
         it_msgdata       TYPE STANDARD TABLE OF zhms_es_msgdt,    " Entrada: Estrutura do Arquivo de Comunicação
         it_msgatrb       TYPE STANDARD TABLE OF zhms_es_msgat,    " Entrada: Atributos de XML
         it_mapdata       TYPE STANDARD TABLE OF zhms_tb_mapdata,  " Dados de Mapeamento
         it_mapdata_aux   TYPE STANDARD TABLE OF zhms_tb_mapdata,  " Dados de Mapeamento
         it_scen_flo      TYPE STANDARD TABLE OF  zhms_tb_scen_flo,
         gt_bdc  LIKE bdcdata    OCCURS 0 WITH HEADER LINE,
         lt_message LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE,
         t_msg TYPE TABLE OF bdcmsgcoll WITH HEADER LINE.

* it_return_exec TYPE STANDARD TABLE OF zhms_es_return, " Retorno
* it_return_mapp TYPE STANDARD TABLE OF zhms_es_return, " Retorno
* it_return_trac TYPE STANDARD TABLE OF zhms_es_return. " Retorno

DATA:    it_dokumentation      TYPE TABLE OF funct,
         it_exception_list     TYPE TABLE OF rsexc,
         it_export_parameter   TYPE TABLE OF rsexp,
         it_import_parameter   TYPE TABLE OF rsimp,
         it_changing_parameter TYPE TABLE OF rscha,
         it_tables_parameter   TYPE TABLE OF rstbl.

DATA:    it_dynvars TYPE STANDARD TABLE OF zhms_es_mapdynvars,
         it_dyntabs TYPE STANDARD TABLE OF zhms_es_mapdynvars.

DATA:    it_scode(120) OCCURS 0.
DATA:    it_scode_vars(120) OCCURS 0.
DATA:    it_scode_main(120) OCCURS 0.

DATA:    it_docum TYPE STANDARD TABLE OF zhms_es_docum.
DATA:    it_scenario TYPE STANDARD TABLE OF zhms_tb_scenario.

DATA:    it_docmn  TYPE TABLE OF zhms_tb_docmn,
         it_docmnx TYPE TABLE OF zhms_tb_docmn,
         ls_docmn LIKE LINE OF it_docmn,
         ls_docmn_2 LIKE LINE OF it_docmn.

TYPES: BEGIN OF ty_atrbuffer,
        field TYPE zhms_de_mneum,
        sumat TYPE zhms_de_usprc,
       END OF ty_atrbuffer.

DATA: t_atrbuffer   TYPE TABLE OF ty_atrbuffer,
      wa_atrbuffer   TYPE ty_atrbuffer.

TYPES: BEGIN OF ty_performs,
        uniq_i      TYPE i,
        srotine(120) TYPE c,
        codmp       TYPE zhms_de_codmp,
        flowd       TYPE zhms_de_flowd,
        funct       TYPE zhms_de_funct,
       END OF ty_performs.

TYPES: BEGIN OF ty_result,
        flowd     TYPE zhms_de_flowd,
        parameter TYPE parameter,
       END OF ty_result.

DATA: it_performs     TYPE TABLE OF ty_performs,
      it_performs_dyn TYPE TABLE OF ty_performs,
      it_tables       TYPE TABLE OF zhms_tb_mapdata-tbnam.

DATA: it_cabdoc TYPE TABLE OF zhms_tb_cabdoc,
      it_itmdoc TYPE TABLE OF zhms_tb_itmdoc,
      it_docmni TYPE STANDARD TABLE OF zhms_tb_docmn,
      it_itmatr TYPE TABLE OF zhms_tb_itmatr,
      it_itmatrx TYPE TABLE OF zhms_tb_itmatr,
      it_result TYPE TABLE OF ty_result,
      t_komv    TYPE STANDARD TABLE OF komv,
      t_1baj    TYPE STANDARD TABLE OF j_1baj,
      it_komk   TYPE STANDARD TABLE OF komk,
      it_komp       TYPE STANDARD TABLE OF komp,
      lt_bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE,
      t_tb_vld_tax TYPE STANDARD TABLE OF zhms_tb_vld_tax,
      ls_tb_vld_tax LIKE LINE OF t_tb_vld_tax.



*===============================================
*Subcontracao
*Renan Itokazo
*===============================================
TYPES: BEGIN OF ty_subcontratacao,
        chk_box   TYPE c,
        seq       TYPE string,
        lote      TYPE string,
        material  TYPE string,
        imposto   TYPE p length 10 decimals 2,
        nmaterial TYPE string,
        quantidade  TYPE p length 10 decimals 3,
        recebedor TYPE string,
        deposito  TYPE string,
        marc      type flag,
        po_number type BAPI2017_GM_ITEM_CREATE-po_number,
        po_item   type BAPI2017_GM_ITEM_CREATE-po_item.
TYPES: END OF ty_subcontratacao.

TYPES: BEGIN OF ty_subcontratacao_aux,
        line      type i,
        seq       TYPE string,
        lote      TYPE string,
        material  TYPE string,
        imposto   TYPE p length 10 decimals 2,
        nmaterial TYPE string,
        quantidade  TYPE p length 10 decimals 3,
        recebedor TYPE string,
        deposito  TYPE string,
        po_number type BAPI2017_GM_ITEM_CREATE-po_number,
        po_item   type BAPI2017_GM_ITEM_CREATE-po_item.
TYPES: END OF ty_subcontratacao_aux.
CONTROLS : ztb_subcontratacao       TYPE TABLEVIEW USING SCREEN 0500,
           ztb_subcontratacao_ordem TYPE TABLEVIEW USING SCREEN 0600.

DATA: ty_subcontratacao       TYPE STANDARD TABLE OF ty_subcontratacao WITH HEADER LINE,
      ti_subcontratacao_aux   TYPE STANDARD TABLE OF ty_subcontratacao_aux WITH HEADER LINE,
      v_materialdocument      TYPE string,
      v_matdocumentyear       TYPE string,
      v_subcontratacao        TYPE string,
      it_mkpf                 TYPE TABLE OF mkpf,
      it_mseg                 TYPE TABLE OF mseg,
      it_resb                 TYPE STANDARD TABLE OF resb,
      wa_mseg                 TYPE mseg,
      wa_subcontratacao       TYPE ty_subcontratacao,
      wa_subcontratacao_aux   TYPE ty_subcontratacao_aux,
      wa_subcontratacao_bapi  TYPE bapi2017_gm_item_create,
      wa_ekte                 TYPE eket,
      wa_resb                 TYPE resb,
      vl_orderid              TYPE string,
      vg_nrordem              TYPE AUFNR.


FIELD-SYMBOLS: <fst_materialdocument>  TYPE bapi2017_gm_head_ret-mat_doc,
               <fst_matdocumentyear>   TYPE bapi2017_gm_head_ret-doc_year,
               <fst_subcontratacao>    TYPE STANDARD TABLE,
               <fst_ty_subcontratacao> TYPE STANDARD TABLE,
               <wa_subcontratacao2>    LIKE <fst_subcontratacao>.


*} Inicio incl. popup MIRO
*=========================================
*Pop-up Miro
*=========================================
TYPES: BEGIN OF ty_item_bapi,
       seq     TYPE i,
       docnum  TYPE j_1bnflin-docnum,
       itmnum  TYPE j_1bnflin-itmnum,
       cfop    TYPE j_1bnflin-cfop,
       nbm     TYPE j_1bnflin-nbm,
       taxlw1  TYPE j_1bnflin-taxlw1,
       taxlw2  TYPE j_1bnflin-taxlw1,
       taxlw4  TYPE j_1bnflin-taxlw4,
       taxlw5  TYPE j_1bnflin-taxlw5,
       matorg  TYPE j_1bnflin-matorg.
TYPES: END OF ty_item_bapi.

CONTROLS : ztb_miro TYPE TABLEVIEW USING SCREEN 0400.



DATA:
  wa_i_bapi        TYPE ty_item_bapi,
  it_i_bapi        TYPE TABLE OF ty_item_bapi,
  wa_docmny        TYPE zhms_tb_docmn,
  ty_item_bapi     TYPE STANDARD TABLE OF ty_item_bapi  WITH HEADER LINE,
  wa_item_ret      TYPE ty_item_bapi,
  wa_item_bf       TYPE ty_item_bapi,
  ty_item_bapi_bf  TYPE STANDARD TABLE OF ty_item_bapi  WITH HEADER LINE,
  ty_item_bapi_upd TYPE STANDARD TABLE OF ty_item_bapi  WITH HEADER LINE,
  wa_item_upd      TYPE ty_item_bapi.
*{ Fim incl. popup miro

TYPES: BEGIN OF ty_mde,
        cuf(2)         TYPE c,
        tpamb(1)       TYPE c,
        cnpj(14)       TYPE c,
        chnfe(44)      TYPE c,
        dhevento(25)   TYPE c,
        tpevento(6)    TYPE c,
        nseqevento(1)  TYPE c,
        descevento(60) TYPE c,
        xjust(255)     TYPE c,
       END OF ty_mde.

*---------------------------------------*
*              Work Areas               *
*---------------------------------------*

DATA:
  wa_evflow   TYPE zhms_tb_ev_flow,  " Eventos: Fluxos
  wa_scflow   TYPE zhms_tb_scen_flo, " Cenários de Negócio: Fluxos
  wa_flow     TYPE zhms_es_flow,     " Fluxo de processamento
  wa_flowx    TYPE zhms_es_flow,     " Fluxo de processamento
  wa_flwdoc   TYPE zhms_tb_flwdoc,   " Etapas de fluxo para o documento
  wa_msgdata  TYPE zhms_es_msgdt,    " Entrada: Estrutura do Arquivo de Comunicação
  wa_msgatrb  TYPE zhms_es_msgat,    " Entrada: Atributos de XML
  wa_mapping  TYPE zhms_tb_mapping,  " Mapeamentos
  wa_mapdata  TYPE zhms_tb_mapdata,  " Dados de Mapeamento
  wa_return   TYPE zhms_es_return,   " Retorno de RFC
  wa_komk     LIKE LINE OF it_komk,
  wa_komp     LIKE LINE OF it_komp,
  wa_docmni   LIKE LINE OF it_docmni,
  wa_scen_flo LIKE LINE OF it_scen_flo.

DATA:
  wa_dokumentation      TYPE funct,
  wa_exception_list     TYPE rsexc,
  wa_export_parameter   TYPE rsexp,
  wa_import_parameter   TYPE rsimp,
  wa_changing_parameter TYPE rscha,
  wa_tables_parameter   TYPE rstbl,
  wa_mde                TYPE ty_mde.

DATA:
  wa_dynvars            TYPE zhms_es_mapdynvars,
  wa_dyntabs            TYPE zhms_es_mapdynvars,
  wa_scode(120)         TYPE c,
  wa_scodex(120)        TYPE c.

DATA:
  wa_docum              TYPE zhms_es_docum.
DATA:
  wa_scenario           TYPE zhms_tb_scenario.

DATA:
  wa_docmn              TYPE zhms_tb_docmn,
  wa_docmnx             TYPE zhms_tb_docmn,
  wa_docmn_rt           TYPE zhms_tb_docmn,
  wa_performs           TYPE ty_performs,
  wa_cabdoc             TYPE zhms_tb_cabdoc,
  wa_itmdoc             TYPE zhms_tb_itmdoc,
  wa_itmatr             TYPE zhms_tb_itmatr,
  wa_lfb1               TYPE lfb1,
  wa_ekko               TYPE ekko,
  wa_hrvalid            TYPE zhms_tb_hrvalid,
  wa_itmdocx            TYPE zhms_tb_itmdoc,
  wa_tables             TYPE zhms_tb_mapdata-tbnam,
  wa_result             TYPE ty_result,
  wa_komv               LIKE LINE OF t_komv,
  wa_head               TYPE komk,
  wa_item               TYPE komp,
  wa_1baj               TYPE j_1baj.

*---------------------------------------*
*               Variáveis               *
*---------------------------------------*

DATA:
  v_critc       TYPE zhmat_de_errcrt,   " Erro Crítico
  v_natdc       TYPE zhms_de_natdc,     " Natureza Documento
  v_typed       TYPE zhms_de_typed,     " Tipo de Documento
  v_loctp       TYPE zhms_de_loctp,     " Localidade
  v_chave       TYPE zhms_de_chave,     " Chave do documento
  v_event       TYPE zhms_de_event,     " Evento Documento
  v_codmp       TYPE zhms_de_codmp,     " Código de Mapeamento
  v_scena       TYPE zhms_de_scena,     " Cenário de Negócio
  v_funct       TYPE zhms_de_funct, " Função a ser executada
  v_flowd       TYPE zhms_de_flowd,     " Etapa do fluxo
  v_call        TYPE zhms_de_code, " Código de chamada de Cenário / Evento
  vg_message    TYPE string,
  vg_char8      TYPE char8,
  vg_index      TYPE sy-tabix,
  vg_netdt      TYPE netdt,
  vg_schzw_bseg TYPE schzw_bseg,
  vg_bktxt      TYPE bktxt.

DATA:
  v_srotine(80) TYPE c,
  v_uniq_i      TYPE i,
  v_uniq_c(3)   TYPE c,
  v_protine     TYPE progname VALUE 'SAPLZHMS_FG_RULER',
  v_varname     TYPE string,
  v_fsname      TYPE string,
  v_seqmn       TYPE i,
  v_err_flow    TYPE flag,
  v_auxiliar    TYPE string,
  vg_ncm_xml    TYPE char8,
  vg_ncm_mne    TYPE char8,
  ok_code       TYPE sy-ucomm,
  vg_ref_doc_no TYPE xblnr,
*DDPT - Inicio da Inclusão
  vg_ref_docaux TYPE xblnr,
*DDPT - Fim da Inclusão
  vg_header_txt TYPE bktxt,
  vg_alloc_nmbr TYPE dzuonr,
  vg_paymt_ref  TYPE kidno,
  vg_item_text  TYPE sgtxt,
  vg_first      TYPE n,
  vg_matnr      TYPE matnr,
  vg_lote       TYPE zhms_de_atlot,
  vg_newcharg   TYPE mcha-charg,
  lv_orig_xml   TYPE j_1bmatorg,
  lv_orig_ped   TYPE j_1bmatorg,
  lv_receb_merc TYPE zhms_de_value,
  gv_460_vldi   TYPE p DECIMALS 4.


*---------------------------------------*
*            Field-Symbols              *
*---------------------------------------*

FIELD-SYMBOLS: <fs_var> TYPE any,
               <fs_tab> TYPE ANY TABLE.


FIELD-SYMBOLS: <or_table> TYPE STANDARD TABLE,
               <or_worka> TYPE any,
               <or_field> TYPE any,
               <de_worka> TYPE any,
               <de_field> TYPE any,
               <fs_worka> TYPE any,
               <fs_item>  TYPE any,
               <or_value> TYPE any,
               <de_value> TYPE any.

*** Declaração de tabelas
DATA: bapi_essr LIKE bapiessrc OCCURS 1
                WITH HEADER LINE.
DATA: bapi_eskn LIKE bapiesknc OCCURS 1
                WITH HEADER LINE.
DATA: bapi_esll LIKE bapiesllc OCCURS 1
                WITH HEADER LINE.
DATA: bapi_eskl LIKE bapiesklc OCCURS 1
                WITH HEADER LINE.
DATA: BEGIN OF bapi_return OCCURS 1.
        INCLUDE STRUCTURE bapiret2.
DATA: END OF bapi_return.

DATA: BEGIN OF wa_po_header OCCURS 1.
        INCLUDE STRUCTURE bapiekkol. "BAPIMEPOHEADER.
DATA: END OF wa_po_header.

DATA:
  po_items TYPE bapiekpo OCCURS 0 WITH HEADER LINE,
  po_services TYPE bapiesll OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF bapi_return_po OCCURS 1.
        INCLUDE STRUCTURE bapiret2. "bapireturn.
DATA: END OF bapi_return_po.

DATA: lt_atribuicao TYPE STANDARD TABLE OF zhms_tb_itmatr.

*** Declaração de workareas
DATA: ls_return      LIKE LINE OF bapi_return,
      ls_atribuicao LIKE LINE OF lt_atribuicao.

*** Declaração de variaveis
DATA: g_entrysheet_no TYPE bapiessr-sheet_no,
      lv_ebeln        TYPE bapiekko-po_number,
      line_no         LIKE bapiesllc-line_no.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'ZTB_MIRO3' ITSELF
CONTROLS: ztb_miro3 TYPE TABLEVIEW USING SCREEN 0400.
*----------------------------------------------------------------------*
* Variáveis globais                                                    *
*----------------------------------------------------------------------*
DATA: gv_mensagem TYPE string,
      gv_resposta TYPE c,
      gv_parvw    TYPE lfa1-lifnr,
      gv_itmnum   TYPE j_1bnflin-itmnum,
      gv_docnum   TYPE bapi_j_1bnfdoc-docnum,
      gv_flwst    TYPE zhms_de_flwst,
      gv_seqnr    TYPE zhms_de_seqnr,
      gv_470_item TYPE c LENGTH 10,
      gv_470_mat  TYPE mara-matnr,
      gv_470_cen  TYPE t001w-werks,
      gv_450_ctg  TYPE j_1bnfdoc-nftype,
      gv_450_buk  TYPE j_1bnfdoc-bukrs,
      gv_450_loc  TYPE j_1bnfdoc-branch.

data: it_tvarv TYPE STANDARD TABLE OF tvarvc,
      wa_tvarv TYPE tvarvc,
      v_error  TYPE c,
      v_matnr  TYPE matnr,
      wa_ekpo TYPE ekpo.
