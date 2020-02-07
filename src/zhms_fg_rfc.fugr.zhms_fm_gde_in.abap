FUNCTION ZHMS_FM_GDE_IN.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(XMLENTRADA) TYPE  STRING
*"     VALUE(EXNAT) TYPE  ZHMS_DE_EXNAT
*"     VALUE(EXTPD) TYPE  ZHMS_DE_EXTPD
*"     VALUE(MENSG) TYPE  ZHMS_DE_MENSG
*"     VALUE(EXEVT) TYPE  ZHMS_DE_EXEVT
*"     VALUE(DIREC) TYPE  ZHMS_DE_DIREC
*"----------------------------------------------------------------------

**Função para realizar a integração do Signature/GDE com o Homsoft
**Essa função irá realizar o XML como uma string e converter para uma internal table e enviar para a função ZHMS_FM_QUAZARIS_IN
**Renan Itokazo
**10/07/2018

  TYPES:
         BEGIN OF ty_controle,
          seqnc TYPE i,
          hier TYPE int1,
          field TYPE c LENGTH 255,
          value TYPE c LENGTH 255,
         END OF ty_controle.

  DATA: lt_msgdata TYPE STANDARD TABLE OF zhms_es_msgdt,
        wa_msgdata LIKE LINE OF lt_msgdata,
        lt_msgatrb TYPE STANDARD TABLE OF zhms_es_msgat,
        wa_msgatrb LIKE LINE OF lt_msgatrb,
        lt_return  TYPE STANDARD TABLE OF zhms_es_return.

  DATA: gt_xml_data   TYPE TABLE OF smum_xmltb.
  DATA: gt_return     TYPE TABLE OF bapiret2.
  DATA: gt_xml_data_aux   TYPE TABLE OF smum_xmltb.
  DATA: gwa_xml_data  TYPE smum_xmltb.
  DATA: gwa_xml_data_aux  TYPE smum_xmltb.
  DATA: gv_tabix      TYPE sytabix.
  DATA: t_msgdata TYPE TABLE OF zhms_es_msgdt,
        w_msgdata TYPE zhms_es_msgdt,
        t_msgatrb TYPE TABLE OF zhms_es_msgat,
        w_msgatrb TYPE zhms_es_msgat,
        t_controle TYPE TABLE OF ty_controle,
        w_controle TYPE ty_controle,
        w_controle_aux TYPE ty_controle.
  DATA: gv_xml_string TYPE xstring.
  DATA: gcl_xml       TYPE REF TO cl_xml_document.

  DATA: vcont          TYPE i,
        vtabix         TYPE sy-tabix,
        vhier          TYPE int1,
        vfilename      TYPE localfile,
        vant           TYPE c,
        vcname         TYPE c LENGTH 255,
        vcname_aux     TYPE c LENGTH 255.
  DATA: gv_subrc      TYPE sy-subrc.
  DATA: gv_size       TYPE sytabix.
  DATA: ld_buffer	TYPE XSTRING.


  DATA: a,
        ls_debug TYPE zhms_tb_debug.
  DO .
    SELECT SINGLE *
      FROM zhms_tb_debug
      INTO ls_debug
      WHERE debug EQ 'X'.
    IF sy-subrc IS NOT INITIAL.
      EXIT.
    ENDIF.
  ENDDO.


**Converter o XML recebeido para Xstring
  CALL FUNCTION 'SCMS_STRING_TO_XSTRING' "
    EXPORTING
      text = XMLENTRADA                    " string
*   mimetype = SPACE            " c
*   encoding =                  " abap_encoding
    IMPORTING
      buffer =   ld_buffer                 " xstring
    EXCEPTIONS
      FAILED = 1                  "
      .  "  SCMS_STRING_TO_XSTRING

* Converter o XML para uma internal table
  CALL FUNCTION 'SMUM_XML_PARSE'
    EXPORTING
      xml_input = ld_buffer
    TABLES
      xml_table = gt_xml_data
      return    = gt_return.


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


**Enviar o XML para a função ZHMS_FM_QUAZARIS_IN para realizar a integração com o HOMSOFT
  CALL FUNCTION 'ZHMS_FM_QUAZARIS_IN'
    EXPORTING
      exnat   = EXNAT
      extpd   = EXTPD
      mensg   = MENSG
      exevt   = EXEVT
      direc   = DIREC
    TABLES
      msgdata = lt_msgdata
      msgatrb = lt_msgatrb
      return  = lt_return.



ENDFUNCTION.
