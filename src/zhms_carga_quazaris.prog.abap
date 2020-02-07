*&---------------------------------------------------------------------*
*& Report  ZHMS_CARGA_QUAZARIS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT  zhms_carga_quazaris.

*** Tipos para Carregar arquivo Excel
TYPES truxs_t_text_data(4096) TYPE c OCCURS 0.

TYPES: BEGIN OF tp_exc,
        mandt  TYPE string,
        chave  TYPE string,
        direc  TYPE string,
        seqnc  TYPE string,
        dcitm  TYPE string,
        field  TYPE string,
        value  TYPE string,
        lote   TYPE string,
        dtalt  TYPE string,
        hralt  TYPE string,
  END OF tp_exc.

DATA: it_tp_exc   TYPE STANDARD TABLE OF tp_exc.
DATA: wa_tp_exc   TYPE tp_exc.
DATA: it_data_xls TYPE truxs_t_text_data.


DATA: lt_repdocat TYPE STANDARD TABLE OF zhms_tb_repdocat,
      ls_repdocat LIKE LINE OF lt_repdocat.

DATA: lt_msgdata TYPE STANDARD TABLE OF zhms_es_msgdt,
      wa_msgdata LIKE LINE OF lt_msgdata,
      lt_msgatrb TYPE STANDARD TABLE OF zhms_es_msgat,
      wa_msgatrb LIKE LINE OF lt_msgatrb,
      lt_return  TYPE STANDARD TABLE OF zhms_es_return.

SELECTION-SCREEN BEGIN OF BLOCK bloco01 WITH FRAME TITLE text-001.
PARAMETERS: p_entr   LIKE rlgrap-filename OBLIGATORY,
            p_chave  TYPE char44.

PARAMETERS: p_xml RADIOBUTTON GROUP rad1 DEFAULT 'X',
            p_excel RADIOBUTTON GROUP rad1.

PARAMETERS: p_exnat TYPE zhms_de_exnat DEFAULT '02',
            p_extpd TYPE zhms_de_extpd DEFAULT '55'.

SELECTION-SCREEN END OF BLOCK bloco01.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_entr.

  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_filename     = p_entr
      def_path         = 'C:_line'
      mask             = '*.*,*.*.'
      title            = 'Pesquisar Arquivo'
    IMPORTING
      filename         = p_entr
    EXCEPTIONS
      inv_winsys       = 1
      no_batch         = 2
      selection_cancel = 3
      selection_error  = 4
      OTHERS           = 5.

START-OF-SELECTION .

  IF p_entr IS NOT INITIAL.
    IF p_excel EQ 'X'.
      PERFORM f_busca_excel.
    ELSEIF p_xml EQ 'X'.
      PERFORM f_busca_xml.
    ENDIF.

    IF lt_msgdata IS NOT INITIAL.
      CALL FUNCTION 'ZHMS_FM_QUAZARIS_IN'
        EXPORTING
          exnat   = p_exnat
          extpd   = p_extpd
          mensg   = 'SIGNA'
          exevt   = '1003'
          direc   = 'E'
        TABLES
          msgdata = lt_msgdata
          msgatrb = lt_msgatrb
          return  = lt_return.
    ENDIF.
  ENDIF.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  F_BUSCA_EXCEL
*&---------------------------------------------------------------------*
FORM f_busca_excel .

* Carrega tabela do excel em outra válida
  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
      i_tab_raw_data       = it_data_xls
      i_filename           = p_entr
    TABLES
      i_tab_converted_data = it_tp_exc
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.

  IF sy-subrc IS INITIAL AND it_tp_exc[] IS NOT INITIAL.

* Desconsiderar a primeira linha que é cabeçalho
    DELETE it_tp_exc[] INDEX 1.

    LOOP AT it_tp_exc INTO wa_tp_exc.

      MOVE: wa_tp_exc-field TO wa_msgdata-field,
            wa_tp_exc-seqnc TO wa_msgdata-seqnc,
            wa_tp_exc-dcitm TO wa_msgdata-dcitm,
            wa_tp_exc-value TO wa_msgdata-value.

      APPEND wa_msgdata TO lt_msgdata.
      CLEAR wa_msgdata.

    ENDLOOP.

    SELECT * FROM zhms_tb_repdocat INTO TABLE lt_repdocat WHERE chave EQ p_chave.
    IF sy-subrc EQ 0.

      LOOP AT lt_repdocat INTO ls_repdocat.
        MOVE: ls_repdocat-seqnc TO wa_msgatrb-seqnc,
              ls_repdocat-field TO wa_msgatrb-field,
              ls_repdocat-value TO wa_msgatrb-value.
        APPEND wa_msgatrb TO lt_msgatrb.
        CLEAR wa_msgatrb.
      ENDLOOP.

    ELSE.

      LOOP AT it_tp_exc INTO wa_tp_exc.

        MOVE: wa_tp_exc-seqnc TO wa_msgatrb-seqnc,
              wa_tp_exc-field TO wa_msgatrb-field,
              wa_tp_exc-value TO wa_msgatrb-value.

        APPEND wa_msgatrb TO lt_msgatrb.
        CLEAR wa_msgatrb.

      ENDLOOP.

    ENDIF.
  ENDIF.
ENDFORM.                    " F_BUSCA_EXCEL

*&---------------------------------------------------------------------*
*&      Form  F_BUSCA_XML
*&---------------------------------------------------------------------*
FORM f_busca_xml .

*&---------------------------------------------------------------------*
*&      Data Types
*&---------------------------------------------------------------------*
  TYPES:
         BEGIN OF ty_controle,
          seqnc TYPE i,
          hier TYPE int1,
          field TYPE c LENGTH 255,
          value TYPE c LENGTH 255,
         END OF ty_controle.

*&---------------------------------------------------------------------*
*&      Data Declaration
*&---------------------------------------------------------------------*
  DATA: gcl_xml       TYPE REF TO cl_xml_document.
  DATA: gv_subrc      TYPE sy-subrc.
  DATA: gv_xml_string TYPE xstring.
  DATA: gv_size       TYPE sytabix.
  DATA: gt_xml_data   TYPE TABLE OF smum_xmltb.
  DATA: gt_xml_data_aux   TYPE TABLE OF smum_xmltb.
  DATA: gwa_xml_data  TYPE smum_xmltb.
  DATA: gwa_xml_data_aux  TYPE smum_xmltb.
  DATA: gt_return     TYPE TABLE OF bapiret2.
  DATA: gv_tabix      TYPE sytabix.
  DATA: t_msgdata TYPE TABLE OF zhms_es_msgdt,
        w_msgdata TYPE zhms_es_msgdt,
        t_msgatrb TYPE TABLE OF zhms_es_msgat,
        w_msgatrb TYPE zhms_es_msgat,
        t_controle TYPE TABLE OF ty_controle,
        w_controle TYPE ty_controle,
        w_controle_aux TYPE ty_controle.

  DATA: vcont          TYPE i,
        vtabix         TYPE sy-tabix,
        vhier          TYPE int1,
        vfilename      TYPE localfile,
        vant           TYPE c,
        vcname         TYPE c LENGTH 255,
        vcname_aux     TYPE c LENGTH 255.

  CREATE OBJECT gcl_xml.

  vfilename = p_entr.

*Upload XML File
  CALL METHOD gcl_xml->import_from_file
    EXPORTING
      filename = vfilename
    RECEIVING
      retcode  = gv_subrc.

  IF gv_subrc = 0.
    CALL METHOD gcl_xml->render_2_xstring
      IMPORTING
        retcode = gv_subrc
        stream  = gv_xml_string
        size    = gv_size.
    IF gv_subrc = 0.
* Convert XML to internal table
      CALL FUNCTION 'SMUM_XML_PARSE'
        EXPORTING
          xml_input = gv_xml_string
        TABLES
          xml_table = gt_xml_data
          return    = gt_return.
    ENDIF.
  ENDIF.


  DELETE gt_xml_data WHERE type = '+'.
  gt_xml_data_aux = gt_xml_data.

  LOOP AT gt_xml_data_aux INTO gwa_xml_data.
    ADD 1 TO w_controle-seqnc.
    IF gwa_xml_data-type = 'A'.
      w_msgatrb-seqnc = sy-tabix.
      w_msgatrb-seqnc = w_msgatrb-seqnc - 1.
      w_msgatrb-field = gwa_xml_data-cname.
      w_msgatrb-value = gwa_xml_data-cvalue.
*      APPEND w_msgatrb TO t_msgatrb.
      APPEND w_msgatrb TO lt_msgatrb.
      DELETE gt_xml_data_aux INDEX sy-tabix.
      CONTINUE.
    ENDIF.
  ENDLOOP.

  CLEAR w_controle-seqnc.
  SORT gt_xml_data_aux BY hier DESCENDING.
  LOOP AT gt_xml_data INTO gwa_xml_data.
    ADD 1 TO w_controle-seqnc.
    IF gwa_xml_data-type = 'A'.
      DELETE gt_xml_data INDEX sy-tabix.
      CONTINUE.
    ENDIF.

    w_controle-seqnc = w_controle-seqnc.
    w_controle-hier = gwa_xml_data-hier.
    w_controle-field = gwa_xml_data-cname.
    IF gwa_xml_data-hier > 1.
      SORT t_controle BY seqnc DESCENDING.
      vhier = gwa_xml_data-hier - 1.
      READ TABLE t_controle INTO w_controle_aux WITH KEY hier = vhier.
      IF sy-subrc EQ 0.
        CONCATENATE w_controle_aux-field '/' gwa_xml_data-cname INTO w_controle-field.
        w_controle-value = gwa_xml_data-cvalue.
      ENDIF.
    ENDIF.
    APPEND w_controle TO t_controle.
  ENDLOOP.

  SORT t_controle BY seqnc.
  LOOP AT t_controle INTO w_controle.
    w_controle-seqnc = sy-tabix.
    MOVE-CORRESPONDING w_controle TO w_msgdata.
    APPEND w_msgdata TO lt_msgdata.
  ENDLOOP.

ENDFORM.                    " F_BUSCA_XML
