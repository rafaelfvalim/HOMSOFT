class ZCL_HMS_ENTRADA_DOCUMENTO definition
  public
  final
  create public .

public section.

  types:
    begin of ty_msgdt,
        field type  zhms_de_field,
        seqnc type  zhms_de_seqnc,
        dcitm type  zhms_de_dcitm,
        value type  zhms_de_value,
      end of ty_msgdt .
  types:
    begin of ty_msgat,
        seqnc type  zhms_de_seqnc,
        field type  zhms_de_atrib,
        value type  zhms_de_value,
      end of ty_msgat .
  types:
    tt_msgdt type table of ty_msgdt .
  types:
    tt_msgat type table of ty_msgat .

  methods SAVE_XML_NFE
    importing
      value(T_MSGDT) type TT_MSGDT
      value(CHAVE) type ZHMS_DE_CHAVE
    returning
      value(RETORNO) type BAPIRETURN .
  methods SAVE_XML_CTE
    importing
      value(T_MSGDT) type TT_MSGDT
      value(CHAVE) type ZHMS_DE_CHAVE
    returning
      value(RETORNO) type BAPIRETURN .
  methods SAVE_XML_NFSE
    importing
      value(T_MSGDT) type TT_MSGDT
      value(CHAVE) type ZHMS_DE_CHAVE
    returning
      value(RETORNO) type BAPIRETURN .
  methods SAVE_XML_ATR_NFE
    importing
      !T_MSGAT type TT_MSGAT
      !CHAVE type ZHMS_DE_CHAVE
    returning
      value(RETORNO) type BAPIRETURN .
  methods SAVE_XML_ATR_CTE
    importing
      value(T_MSGAT) type TT_MSGAT
      value(CHAVE) type ZHMS_DE_CHAVE
    returning
      value(RETORNO) type BAPIRETURN .
  methods SAVE_XML_ATR_NFSE
    importing
      value(T_MSGAT) type TT_MSGAT
      value(CHAVE) type ZHMS_DE_CHAVE
    returning
      value(RETORNO) type BAPIRETURN .
protected section.
private section.

  data T_HEADER type THEAD .

  methods SAVE_XML
    importing
      value(T_MSGDT) type TT_MSGDT
      value(CHAVE) type ZHMS_DE_CHAVE
    returning
      value(RETORNO) type BAPIRETURN .
  methods READ_XML
    importing
      value(CHAVE) type ZHMS_DE_CHAVE
    exporting
      value(T_MSGDT) type TT_MSGDT
      value(RETORNO) type BAPIRETURN .
  methods SAVE_XML_ATR
    importing
      value(T_MSGAT) type TT_MSGAT
      value(CHAVE) type ZHMS_DE_CHAVE
    returning
      value(RETORNO) type BAPIRETURN .
ENDCLASS.



CLASS ZCL_HMS_ENTRADA_DOCUMENTO IMPLEMENTATION.


  method read_xml.
    data: lt_file type table of tline,
          lv_line TYPE TABLE OF string.

    t_header-tdobject = 'ZHMSNFXML'.
    t_header-tdname = chave.
    t_header-tdid = 'NFE1'.
    t_header-tdspras = 'P'.

    call function 'READ_TEXT'
      exporting
        client                  = sy-mandt
        id                      = t_header-tdid
        language                = t_header-tdspras
        name                    = t_header-tdname
        object                  = t_header-tdobject
      tables
        lines                   = lt_file
      exceptions
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        others                  = 8.
    if sy-subrc <> 0.
      retorno-log_msg_no = sy-msgno.
      retorno-type = sy-msgty.
      retorno-message_v1 = sy-msgv1.
      retorno-message_v2 = sy-msgv2 .
      retorno-message_v3 = sy-msgv3.
      retorno-message_v4 = sy-msgv4.
      retorno-message_v4 = sy-msgv4.
    endif.

    loop at lt_file assigning field-symbol(<fs_line>).
      clear lv_line.
      append initial line to t_msgdt assigning field-symbol(<fs_data>).
      split  <fs_line>-tdline at ';' into table lv_line.
      data(lines) = lines( lv_line ).
      do lines times.
        case sy-index.
          when 1.
            <fs_data>-field = lv_line[ 1 ].
          when 2.
            <fs_data>-seqnc = lv_line[ 2 ].
          when 3.
            <fs_data>-dcitm = lv_line[ 3 ].
          when 4.
            <fs_data>-value = lv_line[ 4 ].
        endcase.
      enddo.
    endloop.

  endmethod.


  method SAVE_XML.
    data: lt_file type table of tline.

    loop at t_msgdt assigning field-symbol(<fs_dt>).

      append initial line to lt_file assigning field-symbol(<fs_line>).
      <fs_line>-tdformat = '*'.
      <fs_line>-tdline = |{ <fs_dt>-field };{ <fs_dt>-seqnc };|
                      && |{ <fs_dt>-dcitm };{ <fs_dt>-value }|.
    endloop.

    call function 'SAVE_TEXT'
      exporting
        client          = sy-mandt
        header          = t_header
        savemode_direct = 'X'
      tables
        lines           = lt_file
      exceptions
        id              = 1
        language        = 2
        name            = 3
        object          = 4
        others          = 5.
    if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      retorno-log_msg_no = sy-msgno.
      retorno-type = sy-msgty.
      retorno-message_v1 = sy-msgv1.
      retorno-message_v2 = sy-msgv2 .
      retorno-message_v3 = sy-msgv3.
      retorno-message_v4 = sy-msgv4.
      retorno-message_v4 = sy-msgv4.
    endif.


  endmethod.


  method save_xml_atr.
    data: lt_file type table of tline.

    loop at t_msgat assigning field-symbol(<fs_dt>).

      append initial line to lt_file assigning field-symbol(<fs_line>).
      <fs_line>-tdformat = '*'.
      <fs_line>-tdline = |{ <fs_dt>-field };{ <fs_dt>-seqnc };|
                      && |{ <fs_dt>-value }|.
    endloop.

    call function 'SAVE_TEXT'
      exporting
        client          = sy-mandt
        header          = t_header
        savemode_direct = 'X'
      tables
        lines           = lt_file
      exceptions
        id              = 1
        language        = 2
        name            = 3
        object          = 4
        others          = 5.
    if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      retorno-log_msg_no = sy-msgno.
      retorno-type = sy-msgty.
      retorno-message_v1 = sy-msgv1.
      retorno-message_v2 = sy-msgv2 .
      retorno-message_v3 = sy-msgv3.
      retorno-message_v4 = sy-msgv4.
      retorno-message_v4 = sy-msgv4.
    endif.


  endmethod.


  method SAVE_XML_ATR_CTE.

    clear t_header.
    t_header-tdobject = 'ZHMSNFXML'.
    t_header-tdname = chave.
    t_header-tdid = 'CTEA'.
    t_header-tdspras = 'P'.

    retorno = save_xml_atr( t_msgat = t_msgat chave = chave ).
  endmethod.


  method save_xml_atr_nfe.

    clear t_header.
    t_header-tdobject = 'ZHMSNFXML'.
    t_header-tdname = chave.
    t_header-tdid = 'NFEA'.
    t_header-tdspras = 'P'.

    retorno = save_xml_atr( t_msgat = t_msgat chave = chave ).

  endmethod.


  method save_xml_atr_nfse.

    clear t_header.
    t_header-tdobject = 'ZHMSNFXML'.
    t_header-tdname = chave.
    t_header-tdid = 'NFSA'.
    t_header-tdspras = 'P'.

    retorno = save_xml_atr( t_msgat = t_msgat chave = chave ).
  endmethod.


  method save_xml_cte.

    t_header-tdobject = 'ZHMSNFXML'.
    t_header-tdname = chave.
    t_header-tdid = 'CTE1'.
    t_header-tdspras = 'P'.

    retorno = save_xml( t_msgdt = t_msgdt chave = chave ).
  endmethod.


  method SAVE_XML_NFE.

    t_header-tdobject = 'ZHMSNFXML'.
    t_header-tdname = chave.
    t_header-tdid = 'NFE1'.
    t_header-tdspras = 'P'.

   retorno = save_xml( t_msgdt = t_msgdt chave = chave ).
  endmethod.


  method save_xml_nfse.
    CLEAR t_header.
    t_header-tdobject = 'ZHMSNFXML'.
    t_header-tdname = chave.
    t_header-tdid = 'NFS1'.
    t_header-tdspras = 'P'.

    retorno = save_xml( t_msgdt = t_msgdt chave = chave ).
  endmethod.
ENDCLASS.
