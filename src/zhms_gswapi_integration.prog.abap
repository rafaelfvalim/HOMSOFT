*&---------------------------------------------------------------------*
*& Report  ZHMS_GSWAPI_INTEGRATION
*&
*&---------------------------------------------------------------------*
*&
*& Homine Consulting
*& Programa de teste para realizar a integração com a GSW Keeper
*& Desenvolvedor: Renan Itokazo
*& 28/02/2019
*&
*&---------------------------------------------------------------------*
REPORT ZHMS_GSWAPI_INTEGRATION.

*=======================================================================
*Declaração de variáveis
*=======================================================================
DATA: lv_string             TYPE xstring,
      lv_text64             TYPE string,
      lv_decoded            TYPE xstring,
      lv_xstring            TYPE xstring,
      lv_xmlconvertido      TYPE string,
      lv_xml                TYPE string,
      lv_len                TYPE i,
      lv_existexml          TYPE abap_bool,
      lv_response           TYPE string,
      lv_json_token         TYPE string,
      lv_json_req           TYPE string,
      lo_zip                TYPE REF TO cl_abap_zip,
      lt_zip_file           TYPE cl_abap_zip=>t_files,
      ls_zip_file           TYPE LINE OF cl_abap_zip=>t_files,
      it_binary             TYPE TABLE OF x255,
      it_xmls               TYPE TABLE OF string,
      it_util               TYPE TABLE OF string,
      lr_json_deserializer  TYPE REF TO cl_trex_json_deserializer,
      wa_gswconn            TYPE zhms_tb_gswconn,
      client_init           TYPE REF TO if_http_client,
      json_token            TYPE string,
      http_rc               TYPE sy-subrc.
  TYPES: BEGIN OF ty_json_res,
           access_token   TYPE string,
*           expires_in     TYPE string,
*           token_type     TYPE string,
         END OF ty_json_res.
  DATA: it_json_res TYPE ty_json_res.

  TYPES: BEGIN OF ty_json_res_xml_nota,
    ID_RFE type string,
    XML type string,
  END OF ty_json_res_xml_nota.

  types: it_json_res_xml_nota TYPE STANDARD TABLE OF ty_json_res_xml_nota WITH DEFAULT KEY.

TYPES: BEGIN OF ty_json_res_retorno,
  Sucesso TYPE string,
END OF ty_json_res_retorno.

  TYPES: BEGIN OF ty_json_res_xml,
    MAX_ID_RFE TYPE string,
    ULT_ID_PAG_RFE TYPE string,
    NOTA TYPE it_json_res_xml_nota,
    RetornoIntegracao TYPE ty_json_res_retorno,
  END OF ty_json_res_xml.

DATA: wa_json_res_xml_nota TYPE ty_json_res_xml_nota.

  DATA: it_json_res_xml TYPE ty_json_res_xml.



*Variáveis para testes com arquivo json
DATA: it_xmlrecebidos  TYPE STANDARD TABLE OF string,
      wa_xmlrecebidos  LIKE LINE OF it_xmlrecebidos.
*=======================================================================

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

SELECTION-SCREEN BEGIN OF BLOCK b1.
  PARAMETER: p_tipo TYPE string.
SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.

IF p_tipo IS NOT INITIAL.

PERFORM F_TEST_CONSUMEAPI.
PERFORM F_TEST_READXML.
*WRITE p_tipo.

*
*PERFORM F_TEST_READ_JSON_FILE.
*
*READ TABLE it_xmlrecebidos INTO wa_xmlrecebidos INDEX 1.
*
*PERFORM F_VERIFICA_EXISTE_XML.
*
*IF lv_existexml EQ abap_true.
*  SPLIT wa_xmlrecebidos AT ',"XML":"' INTO TABLE it_xmls.
*  DELETE it_xmls INDEX 1.
*
*  LOOP AT it_xmls INTO lv_xml.
*    PERFORM F_DELETE_LASTCHARS.
*    PERFORM F_DECODE_BASE64.
*    PERFORM F_UNZIP_TEXT.
*
*    REFRESH it_util.
*  ENDLOOP.
*ENDIF.


ELSE.
*TODO: Log
ENDIF.
INCLUDE ZHMS_GSWAPI_ROTINAS.
