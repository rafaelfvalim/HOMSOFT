class ZHMSCL_180_UITLS definition
  public
  final
  create public .

public section.

  types:
    r_docnum TYPE RANGE OF j_1bnfdoc-docnum .
  types:
    BEGIN OF ty_j_1bnflin,
                         docnum TYPE j_1bnflin-docnum,
                         itmnum TYPE j_1bnflin-itmnum,
                         matnr  TYPE j_1bnflin-matnr,
                         maktx  TYPE j_1bnflin-maktx,
                         docref TYPE j_1bnflin-docref,
                         itmref TYPE j_1bnflin-itmref,
                         cfop   TYPE j_1bnflin-cfop,
                         menge  TYPE j_1bnflin-menge,
                         docsta TYPE j_1bnfedocstatus,
                       END OF ty_j_1bnflin .
  types:
    BEGIN OF ty_j_1bnfdoc,
                         docnum TYPE j_1bnfdoc-docnum,
                         docdat TYPE j_1bnfdoc-docdat,
                         pstdat TYPE j_1bnfdoc-pstdat,
                         docref TYPE j_1bnfdoc-docref,
                         nfenum TYPE j_1bnfdoc-nfenum,
                         docsta TYPE j_1bnfe_active-docsta,
                       END OF ty_j_1bnfdoc .
  types:
    it_status180 TYPE STANDARD TABLE OF zhms_tb_confg180 .
  types LST_SATUS type ZHMS_TB_CONFG180 .
  types:
    t_j1bnfdoc TYPE STANDARD TABLE OF ty_j_1bnfdoc .
  types:
    t_j1bnflin TYPE STANDARD TABLE OF ty_j_1bnflin .
  types:
    t_bnfdoc TYPE TABLE OF j_1bnfdoc .
  types:
    t_bnflin TYPE TABLE OF j_1bnflin .
  types:
    r_docdat TYPE RANGE OF j_1bnfdoc-docdat .
  types:
    r_pstdat TYPE RANGE OF j_1bnfdoc-pstdat .
  types:
    r_parid TYPE RANGE OF j_1bnfdoc-parid .
  types:
    r_nfenum TYPE RANGE OF j_1bnfdoc-nfenum .
  types:
    r_docref TYPE RANGE OF j_1bnfdoc-docref .
  types S_J1BNFLIN type J_1BNFLIN .

  constants ICO_NOTANOK type CHAR5 value '@B6@' ##NO_TEXT.
  constants ICO_DIASOK type CHAR5 value '@0V@' ##NO_TEXT.
  constants ICO_ESCROK type CHAR5 value '@B4@' ##NO_TEXT.

  class-methods GET_NOTAS_ENVIO
    importing
      !R_DOCNUM type R_DOCNUM optional
      !R_DOCDAT type R_DOCDAT optional
      !R_PSTDAT type R_PSTDAT optional
      !R_PARID type R_PARID optional
      !R_NFENUM type R_NFENUM optional
    exporting
      value(IT_LIN) type T_BNFLIN
      value(IT_DOC) type T_BNFDOC .
  class-methods GET_NOTAS_RET_CABECALHO
    importing
      value(IT_LIN) type T_BNFLIN
    exporting
      value(IT_LIN_RET) type T_BNFLIN
      value(IT_DOC_RET) type T_BNFDOC .
  class-methods GET_NOTAS_RET_ITEM
    importing
      value(IT_LIN) type T_BNFLIN
    exporting
      value(IT_LIN_RET) type T_BNFLIN
      value(IT_DOC_RET) type T_BNFDOC .
  class-methods FILL_INTERNAL_TABLES
    importing
      value(IT_DOC_IN) type T_BNFDOC optional
      value(IT_LIN_IN) type T_BNFLIN optional
    exporting
      value(IT_DOC_OUT) type T_J1BNFDOC
      value(IT_LIN_OUT) type T_J1BNFLIN .
  class-methods GET_SATUS_NOTA
    importing
      !MENGE type J_1BNETQTY
      !DOCREF type J_1BDOCREF
    returning
      value(ICON) type ZHMS_DE_ICON .
  class-methods CALCULA_DIAS_ATRASO
    importing
      !MENGE type J_1BNETQTY
      !MENGE_D type J_1BNETQTY
      !BEGDA type P0001-BEGDA
      !ENDDA type P0001-ENDDA
    returning
      value(DAYS) type I .
  class-methods GET_STATUS_DIAS_ATRASO
    importing
      !IT_STATUS type IT_STATUS180
      !DIAS type NUMC4
    returning
      value(STATUS_ID) type ZHMS_DE_ICON .
  class-methods GET_NOTAS_ENVIO_DEPARA
    changing
      !IT_DOC type T_BNFDOC
      !IT_LIN type T_BNFLIN .
  class-methods SELECT_RET_CAB_BY_FIELDS
    importing
      !DOCNUM type J_1BNFDOC-DOCNUM
      !MATNR type MATNR optional
      !MAKTX type MAKTX optional
      !ITMNUM type ITMNUM optional
      !IT_LIN type T_BNFLIN
    returning
      value(LS_LINS) type S_J1BNFLIN .
protected section.
private section.

  class-methods REMOVE_CANCEL_ITEMS
    changing
      !IT_LIN_IN type T_BNFLIN .
ENDCLASS.



CLASS ZHMSCL_180_UITLS IMPLEMENTATION.


METHOD calcula_dias_atraso.

  CHECK menge <> menge_d.

  CALL FUNCTION 'HR_99S_INTERVAL_BETWEEN_DATES'
    EXPORTING
      begda = begda
      endda = endda
    IMPORTING
      days  = days.
ENDMETHOD.


METHOD FILL_INTERNAL_TABLES.
  DATA: wa_doc TYPE j_1bnfdoc,
        wa_lin TYPE j_1bnflin.

  FIELD-SYMBOLS: <fs_doc_out> TYPE ty_j_1bnfdoc,
                 <fs_lin_out> TYPE ty_j_1bnflin.

  LOOP AT it_doc_in INTO wa_doc.
    APPEND INITIAL LINE TO it_doc_out ASSIGNING <fs_doc_out>.
    MOVE-CORRESPONDING wa_doc TO <fs_doc_out>.
  ENDLOOP.

  LOOP AT it_lin_in INTO wa_lin.
    APPEND INITIAL LINE TO it_lin_out ASSIGNING <fs_lin_out>.
    MOVE-CORRESPONDING wa_lin TO <fs_lin_out>.
  ENDLOOP.

ENDMETHOD.


METHOD get_notas_envio.
    DATA: condition   TYPE string,
          t_active    TYPE TABLE OF j_1bnfe_active,
          wa_active   TYPE j_1bnfe_active,
          r_active    TYPE RANGE OF j_1bnfe_active-docnum,
          wr_active   LIKE LINE OF r_active,
          t_deparadoc TYPE TABLE OF zhms_tb_doc180.
    "Seleciona notas
    SELECT *
      FROM j_1bnfdoc
      INTO TABLE it_doc
     WHERE docdat IN r_docdat
       AND pstdat IN r_pstdat
       AND parid  IN r_parid
       AND nfenum IN r_nfenum
       AND docnum IN r_docnum
       AND cod_sit NE '2'
       AND cancel NE 'X'.
    SORT it_doc.
    IF it_doc[] IS NOT INITIAL.
      "Filtra por documentos aprovados
      SELECT *
        FROM j_1bnfe_active
        INTO TABLE t_active
     FOR ALL ENTRIES IN it_doc
       WHERE docnum = it_doc-docnum
         AND docsta IN ('2', '3', '' ).
      LOOP AT t_active INTO wa_active.
        wr_active-sign = 'I'.
        wr_active-option = 'EQ'.
        wr_active-low = wa_active-docnum.
        APPEND wr_active TO r_active.
      ENDLOOP.
      IF r_active IS NOT INITIAL.
        DELETE it_doc WHERE docnum IN r_active.
      ENDIF.
      "Selciona itens da lin
      SELECT *
        FROM j_1bnflin
        INTO TABLE it_lin
         FOR ALL ENTRIES IN it_doc
       WHERE docnum EQ it_doc-docnum.
    ENDIF.

  ENDMETHOD.                    "get_doc_lin


METHOD GET_NOTAS_ENVIO_DEPARA.
  DATA: t_docnum TYPE TABLE OF zhms_tb_doc180.

  SELECT * FROM zhms_tb_doc180
     INTO TABLE t_docnum.


  IF t_docnum[] IS NOT INITIAL.

    SELECT *
      FROM j_1bnfdoc
      APPENDING TABLE it_doc
      FOR ALL ENTRIES IN t_docnum
      WHERE docnum EQ t_docnum-docnum_ret
        AND cod_sit NE '02'.

    SELECT *
      FROM j_1bnflin
      APPENDING TABLE it_lin
      FOR ALL ENTRIES IN t_docnum
      WHERE docnum EQ t_docnum-docnum_ret.

  ENDIF.



ENDMETHOD.


METHOD get_notas_ret_cabecalho.
    CHECK it_lin[] IS NOT INITIAL.

    SELECT *
      FROM j_1bnfdoc
      INTO TABLE it_doc_ret
       FOR ALL ENTRIES IN it_lin
     WHERE docref EQ it_lin-docnum
       AND cancel NE 'X'
       AND cod_sit NE '02'.
    IF it_doc_ret[] IS NOT INITIAL.
      SELECT *
        FROM j_1bnflin
        INTO TABLE it_lin_ret
         FOR ALL ENTRIES IN it_doc_ret
       WHERE docnum EQ it_doc_ret-docnum.
      IF it_lin_ret IS NOT INITIAL.
        zhmscl_180_uitls=>remove_cancel_items( CHANGING it_lin_in = it_lin_ret ).
      ENDIF.
    ENDIF.

  ENDMETHOD.                    "GET_REF_DOC_LIN


METHOD get_notas_ret_item.
    DATA: r_docnum TYPE RANGE OF j_1bnfdoc-docnum ,
          wa_rdocnum TYPE LINE OF  r_docnum,
          wa_lin_ret TYPE LINE OF t_bnflin.

    CLEAR r_docnum[].

    CHECK it_lin[] IS NOT INITIAL.
    SELECT *
      FROM j_1bnflin
      INTO TABLE it_lin_ret
       FOR ALL ENTRIES IN it_lin
     WHERE docref EQ it_lin-docnum.
*** Filtra os documentos cancelados j_1bnfdoc-cancel = 'X'
    zhmscl_180_uitls=>remove_cancel_items( CHANGING it_lin_in = it_lin_ret ).
    IF it_lin_ret IS NOT INITIAL.
      SELECT *
        FROM j_1bnfdoc
        INTO TABLE it_doc_ret
        FOR ALL ENTRIES IN it_lin_ret
       WHERE docnum EQ it_lin_ret-docnum.
    ENDIF.

  ENDMETHOD.                    "GET_REF_DOC_LIN


METHOD get_satus_nota.
  IF docref IS INITIAL.
    icon = ico_notanok ."Status Nota Devolvida
    RETURN.
  ENDIF.
  IF  menge IS INITIAL.
    icon = ico_escrok ."Status Nota Devolvida
    RETURN.
  ENDIF.
  icon = ico_notanok ."Status Nota Devolvida

ENDMETHOD.


METHOD get_status_dias_atraso.
  DATA: wa_status TYPE lst_satus,
        lv_count TYPE i.

  LOOP AT it_status INTO wa_status.
    IF dias > wa_status-dias_fim.
      status_id = wa_status-id.
    ENDIF.
    IF dias BETWEEN wa_status-dias_ini AND wa_status-dias_fim.
      status_id = wa_status-id.
    ENDIF.
  ENDLOOP.

ENDMETHOD.


METHOD remove_cancel_items.
  DATA: r_docnum TYPE RANGE OF j_1bnfdoc-docnum ,
        wa_rdocnum TYPE LINE OF  r_docnum,
        it_doc TYPE TABLE OF j_1bnfdoc,
        wa_doc TYPE j_1bnfdoc.
* cod_sit = 2 documento cancelado
* cancel = X documento estornado
* nftype = V1 nota de cancelamento
  SELECT *
       FROM j_1bnfdoc
       INTO TABLE it_doc
        FOR ALL ENTRIES IN it_lin_in
      WHERE docnum EQ it_lin_in-docnum
        AND ( cancel EQ 'X' OR  cod_sit EQ '2' OR nftype EQ 'V1' ).
  LOOP AT it_doc INTO wa_doc.
    CLEAR wa_rdocnum.
    wa_rdocnum-sign = 'I'.
    wa_rdocnum-option = 'EQ'.
    wa_rdocnum-low = wa_doc-docnum.
    APPEND wa_rdocnum TO r_docnum.
  ENDLOOP.
  IF r_docnum IS NOT INITIAL.
    DELETE it_lin_in WHERE docnum IN r_docnum.
  ENDIF.

ENDMETHOD.


METHOD select_ret_cab_by_fields.

  READ TABLE it_lin INTO ls_lins WITH KEY docnum = docnum matnr = matnr.
  IF sy-subrc EQ 0 AND matnr IS NOT INITIAL .
    RETURN.
  ENDIF.

  READ TABLE it_lin INTO ls_lins WITH KEY docnum = docnum maktx = maktx.
  IF sy-subrc EQ 0 AND maktx IS NOT INITIAL .
    RETURN.
  ENDIF.

  READ TABLE it_lin INTO ls_lins WITH KEY docnum = docnum itmnum = itmnum.
  IF sy-subrc EQ 0 AND itmnum IS NOT INITIAL.
    RETURN.
  ENDIF.

ENDMETHOD.
ENDCLASS.
