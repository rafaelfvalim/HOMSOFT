FUNCTION-POOL zhms_fg_validate.             "MESSAGE-ID ..

* INCLUDE LZHMS_FG_VALIDATED...              " Local class definition

TYPE-POOLS: abap.


TYPES: BEGIN OF ty_stgrp,
        grpcd TYPE zhms_de_grpcd,
        vldty TYPE zhms_de_vldty,
       END OF ty_stgrp.


DATA: lv_usuario TYPE sy-uname,
      lv_ebeln   TYPE ebeln,
      lv_titulo  TYPE string,
      lv_nnf     TYPE char10,
      lv_serie   TYPE char3,
      lv_corpo   TYPE string,
      lv_parid   TYPE char10,
      lt_hrvalid TYPE STANDARD TABLE OF zhms_tb_hrvalid,
      ls_hrvalid LIKE LINE OF lt_hrvalid,
      wa_cf_email TYPE zhms_tb_cf_email,
      wa_mail     type zhms_tb_mail.

DATA: v_vldcd    TYPE zhms_de_vldcd,
      vg_lifnr   TYPE lifnr,
      vg_message TYPE string.

DATA: it_regvld  TYPE TABLE OF zhms_tb_regvld,
      it_docmn   TYPE TABLE OF zhms_tb_docmn,
      it_itmdoc  TYPE TABLE OF zhms_tb_itmdoc,
      it_itmatr  TYPE TABLE OF zhms_tb_itmatr,
      it_hrvalid TYPE TABLE OF zhms_tb_hrvalid,
      it_hvalid  TYPE TABLE OF zhms_tb_hvalid,
      it_stgrp   TYPE TABLE OF ty_stgrp.

DATA: wa_pkgvld      TYPE zhms_tb_pkgvld,
      wa_regvld      TYPE zhms_tb_regvld,
      wa_docmn       TYPE zhms_tb_docmn,
      wa_docmnx      TYPE zhms_tb_docmn,
      wa_docst       TYPE zhms_tb_docst,
      wa_cabdoc      TYPE zhms_tb_cabdoc,
      wa_itmdoc      TYPE zhms_tb_itmdoc,
      wa_itmatr      TYPE zhms_tb_itmatr,
      wa_hvalid      TYPE zhms_tb_hvalid,
      wa_hvalidx     TYPE zhms_tb_hvalid,
      wa_hrvalid     TYPE zhms_tb_hrvalid,
      wa_hrvalidx    TYPE zhms_tb_hrvalid,
      wa_hrvalid_ax  TYPE zhms_tb_hrvalid,
      wa_stgrp       TYPE ty_stgrp,
      wa_lfb1        TYPE lfb1,
      wa_ekko        TYPE ekko.

FIELD-SYMBOLS: <or_table> TYPE STANDARD TABLE,
               <or_worka> TYPE ANY,
               <or_value> TYPE ANY,
               <mn_value> TYPE ANY.
