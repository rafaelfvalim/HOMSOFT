*&---------------------------------------------------------------------*
*&  Include           ZHMS_GSWAPI_ROTINAS
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_DECODE_BASE64
*&      Transforma o XML/ZIP Base64 em um XSTRING
*&---------------------------------------------------------------------*

FORM F_DECODE_BASE64.
CALL FUNCTION 'SCMS_BASE64_DECODE_STR'
  EXPORTING
    INPUT          = lv_xml
   UNESCAPE       = 'X'
 IMPORTING
   OUTPUT         = lv_decoded
 EXCEPTIONS
   FAILED         = 1
   OTHERS         = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_UNZIP_TEXT
*&---------------------------------------------------------------------*
*       Descompactar string
*----------------------------------------------------------------------*

FORM F_UNZIP_TEXT .
  CREATE OBJECT lo_zip.

  CALL METHOD lo_zip->load
    EXPORTING
      zip             = lv_decoded
    EXCEPTIONS
      zip_parse_error = 1
      OTHERS          = 2.

LOOP AT lo_zip->files INTO ls_zip_file.
    CALL METHOD lo_zip->get
      EXPORTING
        name                    = ls_zip_file-name
      IMPORTING
        content                 = lv_xstring
      EXCEPTIONS
        zip_index_error         = 1
        zip_decompression_error = 2
        OTHERS                  = 3.

    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer          = lv_xstring
      IMPORTING
        output_length  = ls_zip_file-size
      TABLES
        binary_tab      = it_binary.

    CALL FUNCTION 'SCMS_BINARY_TO_STRING'
      EXPORTING
        input_length = ls_zip_file-size
      IMPORTING
        text_buffer  = lv_xmlconvertido
      TABLES
        binary_tab  = it_binary
      EXCEPTIONS
        failed      = 1
        OTHERS      = 2.
ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_TEST_READ_JSON_FILE
*&---------------------------------------------------------------------*
*       Testar o response do webservice da GSW manualmente através de um arquivo TXT
*----------------------------------------------------------------------*
FORM F_TEST_READ_JSON_FILE .
  CALL FUNCTION 'GUI_UPLOAD'
  EXPORTING
    FILENAME = 'C:\Users\Renan\Desktop\retornoGetCTE - Cópia.json'
    FILETYPE = 'ASC'
    HAS_FIELD_SEPARATOR = ''
  TABLES
    DATA_TAB = it_xmlrecebidos.



ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_DELETE_LASTCHARS
*&---------------------------------------------------------------------*
*       Remover os ultimos caracteres de cada string, deixando apenas o XML
*       EX: remover: => ","eventos":[]},{"ID_RFE":1679
*----------------------------------------------------------------------*
FORM F_DELETE_LASTCHARS .
  SPLIT lv_xml AT '"' INTO TABLE it_util.
  READ TABLE it_util INTO lv_xml INDEX 1.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_VERIFICA_EXISTE_XML
*&---------------------------------------------------------------------*
*       {"RetornoIntegracao":{"Sucesso":t
*       Realiza um substring no json para verificar se o campo sucesso é t(true) or f(false)
*----------------------------------------------------------------------*
FORM F_VERIFICA_EXISTE_XML .
IF wa_xmlrecebidos+32(1) EQ 't'.
  lv_existexml = abap_true.
ELSE.
  lv_existexml = abap_false.
ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_TEST_CONSUMEAPI
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM F_TEST_CONSUMEAPI .

SELECT SINGLE * FROM ZHMS_TB_GSWCONN INTO WA_GSWCONN.

IF SY-SUBRC IS INITIAL.

cl_http_client=>create_by_url(
    EXPORTING url = wa_gswconn-url
    IMPORTING client = client_init
    ).

call method client_init->request->set_method
      exporting
        method = 'POST'.

  CALL METHOD client_init->request->set_cdata
    EXPORTING
      data   = 'grant_type=password&username=usrws_ml&password=Nkw0@1K#N98'
      offset = 0
      length = 58.

CALL METHOD client_init->send
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3
      http_invalid_timeout       = 4
      OTHERS                     = 5.
  IF sy-subrc <> 0.
    break ritokazo.
  ENDIF.

  CALL METHOD client_init->receive
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3
      OTHERS                     = 4.
  IF sy-subrc <> 0.
    break ritokazo.
  ENDIF.

  client_init->response->get_status( IMPORTING code = http_rc ).

  lv_response = client_init->response->get_cdata( ).
  client_init->close( ).


  cl_fdt_json=>json_to_data( EXPORTING  iv_json = lv_response
                                CHANGING   ca_data = it_json_res ).

  lv_json_token = IT_JSON_RES-ACCESS_TOKEN.



*GET
*================================================================================================================================
     TYPES: BEGIN OF ty_json_req,
              ID_INICIAL_RFE      TYPE i,
              RetEventos          TYPE string,
              Qtd_Por_Pagina      TYPE i,
              DataEmissaoInicial  TYPE string,
              DataEmissaoFinal    TYPE string,
              CNPJ                TYPE string,
              CHAVE               TYPE string,
            END OF ty_json_req.
     DATA: json_req TYPE ty_json_req.
     json_req-ID_INICIAL_RFE = 0.
*     json_req-RetEventos = 'false'.
     json_req-Qtd_Por_Pagina = 10.

     CLEAR: json_req-DataEmissaoInicial.

     DATA lr_json_serializer   TYPE REF TO cl_trex_json_serializer.

     CREATE OBJECT lr_json_serializer  EXPORTING  data = json_req.
     lr_json_serializer->serialize( ).

      lv_json_req = /ui2/cl_json=>serialize( data = json_req compress = abap_true pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

cl_http_client=>create_by_url(
    EXPORTING url = 'http://ml.gswapp.com/RFE_API/getNFE'
    IMPORTING client = client_init
    ).

call method client_init->request->set_method
      exporting
        method = 'POST'.

DATA: lv_requestToken TYPE string.

CONCATENATE 'Bearer' lv_json_token INTO lv_requestToken separated by space.
client_init->propertytype_logon_popup = client_init->co_disabled.
client_init->request->set_header_field(
      EXPORTING
        name  = 'Authorization'    " Name of the header field
        value = lv_requestToken   " HTTP header field value
    ).

  CALL METHOD client_init->request->set_cdata
    EXPORTING
      data   = lv_json_req
      offset = 0.

CALL METHOD client_init->send
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3
      http_invalid_timeout       = 4
      OTHERS                     = 5.
  IF sy-subrc <> 0.
    break ritokazo.
  ENDIF.

  CALL METHOD client_init->receive
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3
      OTHERS                     = 4.
  IF sy-subrc <> 0.
    break ritokazo.
  ENDIF.

  client_init->response->get_status( IMPORTING code = http_rc ).

  lv_response = client_init->response->get_cdata( ).
  client_init->close( ).

  cl_fdt_json=>json_to_data( EXPORTING  iv_json = lv_response
                                CHANGING   ca_data = it_json_res_xml ).

  lv_json_token = IT_JSON_RES_xml-MAX_ID_RFE.


LOOP AT it_json_res_xml-NOTA into wa_json_res_xml_nota.


CALL FUNCTION 'SCMS_BASE64_DECODE_STR'
  EXPORTING
    INPUT          = wa_json_res_xml_nota-xml
   UNESCAPE       = 'X'
 IMPORTING
   OUTPUT         = lv_decoded
 EXCEPTIONS
   FAILED         = 1
   OTHERS         = 2.


CREATE OBJECT lo_zip.

  CALL METHOD lo_zip->load
    EXPORTING
      zip             = lv_decoded
    EXCEPTIONS
      zip_parse_error = 1
      OTHERS          = 2.

LOOP AT lo_zip->files INTO ls_zip_file.
    CALL METHOD lo_zip->get
      EXPORTING
        name                    = ls_zip_file-name
      IMPORTING
        content                 = lv_xstring
      EXCEPTIONS
        zip_index_error         = 1
        zip_decompression_error = 2
        OTHERS                  = 3.

    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer          = lv_xstring
      IMPORTING
        output_length  = ls_zip_file-size
      TABLES
        binary_tab      = it_binary.

    CALL FUNCTION 'SCMS_BINARY_TO_STRING'
      EXPORTING
        input_length = ls_zip_file-size
      IMPORTING
        text_buffer  = lv_xmlconvertido
      TABLES
        binary_tab  = it_binary
      EXCEPTIONS
        failed      = 1
        OTHERS      = 2.

write: lv_xmlconvertido.
ENDLOOP.

ENDLOOP.

*================================================================================================================================

     break ritokazo.
ELSE.
*TODO: Implementar gravação de log de erro de configuração não encontrada
ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_TEST_READXML
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_TEST_READXML .
  CALL FUNCTION 'GUI_UPLOAD'
  EXPORTING
    FILENAME = 'C:\Users\Renan\Desktop\teste1.txt'
    FILETYPE = 'ASC'
    HAS_FIELD_SEPARATOR = ''
  TABLES
    DATA_TAB = it_xmlrecebidos.
ENDFORM.
