FUNCTION-POOL zhms_fg_document.             "MESSAGE-ID ..

* INCLUDE LZHMS_FG_DOCUMENTD...              " Local class definition


DATA: it_logdoc   TYPE TABLE OF zhms_tb_logdoc,
      it_bapiret  TYPE TABLE OF bapiret2,
      it_flwdoc      TYPE TABLE OF zhms_tb_flwdoc,
      t_scenflo     TYPE TABLE OF zhms_tb_scen_flo,
      t_flwdoc      TYPE TABLE OF zhms_tb_flwdoc,
      lt_logdoc   TYPE STANDARD TABLE Of zhms_tb_logdoc.


DATA:
      wa_flwdoc    TYPE zhms_tb_flwdoc,
      wa_flwdoc2   TYPE zhms_tb_flwdoc,
      wa_cabdoc    TYPE zhms_tb_cabdoc,
      wa_logdoc    TYPE zhms_tb_logdoc,
      wa_bapiret   TYPE bapiret2,
      wa_flwdoc_ax TYPE zhms_es_flwdoc,
      wa_scenflo   TYPE zhms_tb_scen_flo,
      wa_cf_email  type zhms_tb_cf_email,
      wa_hrvalid   type zhms_tb_hrvalid.



DATA: vg_seqnr TYPE zhms_de_seqnr,
      vg_vldcd TYPE zhms_de_vldcd,
      vg_vldty TYPE zhms_de_vldty,
      vg_tabix TYPE sy-tabix,
      vg_lastindex TYPE sy-tabix,
      vg_found TYPE flag,
      vg_erro  TYPE flag,
      vg_sthms TYPE zhms_de_sthms,
      vg_chave TYPE zhms_de_chave,
      vg_valor TYPE zhms_de_value.


  TYPES: BEGIN OF ty_flwdoc.
          INCLUDE TYPE zhms_tb_flwdoc.
  TYPES: END OF ty_flwdoc.
