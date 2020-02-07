FUNCTION-POOL zhms_fg_download_xml MESSAGE-ID zhms_download_xml.

TYPES: BEGIN OF ty_doctos,
      mark        TYPE mark,
      detal       TYPE icon,
      detalmde    TYPE icon,
      chave(44)   TYPE c,
      nfenum      TYPE j_1bnfnum9,
      serie       TYPE j_1bseries,
      dtemiss(4)  TYPE c,
      cnpjemiss   TYPE j_1bcgc,
      razao       TYPE name1_gp,
      END OF ty_doctos.

TYPES: BEGIN OF ty_arq,
      chave(44)     TYPE c,
      END OF ty_arq.

TYPES: BEGIN OF ty_hist_ev,
      tpeve    TYPE zhms_de_tpeve,
      nseqev   TYPE zhms_de_nseqev,
      lote     TYPE zhms_de_lote,
      xmotivo  TYPE zhms_de_xmoti,
      dthrreg  TYPE zhms_de_dheve,
      protoco  TYPE zhms_de_proto,
      dataenv  TYPE zhms_de_datae,
      horaenv  TYPE zhms_de_horae,
      usuario  TYPE uname,
 END OF ty_hist_ev.
*** Declaração de variaveis de tela
DATA: vg_chave TYPE zhms_de_chave.

*** Declarações de variaveis de sistema
DATA: ok_code      TYPE sy-ucomm,
      vg_cte       TYPE char1,
      vg_nfe       TYPE char1,
      vg_nfes      TYPE char1,
      vg_bukrs     TYPE bukrs,
      vg_brach     TYPE werks_d,
      vg_screen    TYPE char4,
      vg_screen2   TYPE char4,
      vg_screen3   TYPE char4,
      vg_cnpj      TYPE stcd1,
      vg_tip_doc   TYPE char5,
      vg_mensg     TYPE zhms_de_mensg,
      vg_lote_h    TYPE zhms_de_lote,
      vg_lote_s    TYPE zhms_de_lote,
      iv_timestamp TYPE timestamp,
      iv_timezone  TYPE ttzz-tzone,
      ev_date      TYPE dats,
      ev_time      TYPE tims,
      gv_rc        TYPE i,
      vg_file      TYPE rlgrap-filename,
      ev_utcdiff   TYPE tznutcdiff,
      ev_utcsign   TYPE tznutcsign,
      vl_erro      TYPE flag,
      vg_event     TYPE zhms_de_stent,
      vg_versao    TYPE zhms_de_versn,
      vg_data_de   TYPE dats,
      vg_data_ate  TYPE dats.


*** Declaração de tabelas internas
DATA: lt_tc_status TYPE STANDARD TABLE OF zhms_out_evento,
      lt_tb_evst   TYPE STANDARD TABLE OF zhms_tb_evst,
      ls_tb_evst   LIKE LINE OF lt_tb_evst,
      ls_tc_status LIKE LINE OF lt_tc_status,
      lt_mapeamento TYPE STANDARD TABLE OF zhms_tb_mapdatac,
      ls_mapeamento LIKE LINE OF lt_mapeamento,
      lt_eventos   TYPE STANDARD TABLE OF zhms_tb_nfeevt,
      ls_eventos   LIKE LINE OF lt_eventos,
      lt_branch    TYPE STANDARD TABLE OF j_1bbranch,
      t_hvalid_fldc TYPE lvc_t_fcat,
      ls_branch    LIKE LINE OF lt_branch,
      lt_cabeve    TYPE STANDARD TABLE OF zhms_tb_cabeve,
      ls_cabeve    LIKE LINE OF lt_cabeve,
      ls_sadr      TYPE sadr,
      lv_index     TYPE sy-tabix,
      lv_index_aux TYPE sy-tabix,
      lt_doctos    TYPE TABLE OF ty_doctos,
      lt_hist_evento TYPE STANDARD TABLE OF ty_hist_ev,
      lt_hist_eventox TYPE STANDARD TABLE OF zhms_tb_histev,
      ls_hist_evento LIKE LINE OF lt_hist_evento,
      ls_doctos    LIKE LINE OF lt_doctos,
      lt_filetable TYPE filetable,
      ls_filetable LIKE LINE OF lt_filetable,
      lt_arq       TYPE TABLE OF ty_arq,
      ls_arq       LIKE LINE OF lt_arq,
      vg_msg_text  TYPE char80.

** Variaveis locais
DATA: tl_itxw_note    TYPE STANDARD TABLE OF txw_note,
      wl_itxw_note    TYPE txw_note,
      tl_textnote(72) TYPE c OCCURS 0,
      vl_tam          TYPE i,
      vl_max          TYPE i,
      vl_txt          TYPE string.

DATA: lt_cod_map TYPE STANDARD TABLE OF zhms_tb_mapconec,
      ls_cod_map LIKE LINE OF lt_cod_map,
      lt_tb_evmn TYPE STANDARD TABLE OF zhms_tb_evmn,
      lt_datam   TYPE STANDARD TABLE OF zhms_es_msgdtm,
      ls_datam   LIKE LINE OF lt_datam,
      ls_datamx  LIKE LINE OF lt_datam,
      ls_tb_evmn LIKE LINE OF lt_tb_evmn,
      lt_atrbm   TYPE STANDARD TABLE OF zhms_es_msgatm,
      ls_atrbm   LIKE LINE OF lt_atrbm,
      ls_atrbmx   LIKE LINE OF lt_atrbm,
      ls_hist_eventox like LINE OF lt_hist_eventox ,
      wa_hvalid_fldc   TYPE lvc_s_fcat.

TYPES: BEGIN OF ty_select,
        line TYPE char80,
       END OF ty_select.

DATA: fieldcat    TYPE lvc_t_fcat,
      r_fieldcat  LIKE LINE OF fieldcat,
      d_reference TYPE REF TO data.

DATA: t_campos       TYPE TABLE OF ty_select WITH HEADER LINE,
      t_where        TYPE TABLE OF ty_select WITH HEADER LINE,
      lv_valor       TYPE zhms_de_value.

DATA: ob_dcevt_obs     TYPE REF TO cl_gui_textedit,
      ob_cc_dcevt_obs  TYPE REF TO cl_gui_custom_container,
      ob_cc_vis_item   TYPE REF TO cl_gui_custom_container,
      ob_cc_grid       TYPE REF TO cl_gui_alv_grid.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TC_001' ITSELF
CONTROLS: tc_001 TYPE TABLEVIEW USING SCREEN 0103.

*&SPWIZARD: LINES OF TABLECONTROL 'TC_001'
DATA:     g_tc_001_lines  LIKE sy-loopc.


*&SPWIZARD: DECLARATION OF TABLECONTROL 'TC_LOG_MDE' ITSELF
CONTROLS: tc_log_mde TYPE TABLEVIEW USING SCREEN 0100.

*&SPWIZARD: LINES OF TABLECONTROL 'TC_LOG_MDE'
DATA:     g_tc_log_mde_lines  LIKE sy-loopc.
DATA:     tr_data TYPE RANGE OF datum,
          ls_data LIKE LINE OF tr_data.

DATA: it_cabdoc TYPE STANDARD TABLE OF zhms_tb_cabdoc,
      ls_cabdoc LIKE LINE OF it_cabdoc.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TC_LOG_EV_MDE' ITSELF
CONTROLS: tc_log_ev_mde TYPE TABLEVIEW USING SCREEN 0103.

*&SPWIZARD: LINES OF TABLECONTROL 'TC_LOG_EV_MDE'
DATA:     g_tc_log_ev_mde_lines  LIKE sy-loopc.
