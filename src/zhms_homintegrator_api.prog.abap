*&---------------------------------------------------------------------*
*& Report  ZHMS_HOMINTEGRATOR_API
*&
*&---------------------------------------------------------------------*
*&
*& 21/08/2018
*& Desenvolvedor: Renan Itokazo
*& Programa responsável por buscar os XML no Web API HomIntegrator Cloud
*&
*&---------------------------------------------------------------------*

REPORT  ZHMS_HOMINTEGRATOR_API.

*----------------------------------------------------------------------*
* Estruturas
*----------------------------------------------------------------------*
TYPES:
       BEGIN OF ty_controle,
        seqnc TYPE i,
        hier TYPE int1,
        field TYPE c LENGTH 255,
        value TYPE c LENGTH 255,
       END OF ty_controle.

*----------------------------------------------------------------------*
* Tabelas Internas
*----------------------------------------------------------------------*
DATA: it_texto         TYPE TABLE OF string,
      it_xml_data      TYPE TABLE OF smum_xmltb,
      it_return        TYPE TABLE OF bapiret2,
      it_xml_data_aux  TYPE TABLE OF smum_xmltb,
      it_controle      TYPE TABLE OF ty_controle,
      it_msgatrb       TYPE STANDARD TABLE OF zhms_es_msgat,
      it_msgdata       TYPE STANDARD TABLE OF zhms_es_msgdt,
      it_return_qzr    TYPE STANDARD TABLE OF zhms_es_return,
      it_logunk        TYPE TABLE OF zhms_tb_logunk.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
DATA: client_init      TYPE REF TO if_http_client,
      json             TYPE string,
      l_username       TYPE string,
      l_password       TYPE string,
      http_rc          TYPE sy-subrc,
      len              TYPE i,
      V_EXNAT          TYPE ZHMS_DE_EXNAT,
      V_EXTPD          TYPE ZHMS_DE_EXTPD,
      V_MENSG          TYPE ZHMS_DE_MENSG,
      V_EXEVT          TYPE ZHMS_DE_EXEVT,
      V_DIREC          TYPE ZHMS_DE_DIREC,
      Prefixo          TYPE c length 3,
      ld_buffer	       TYPE XSTRING,
      vhier            TYPE int1,
      v_critc          TYPE zhmat_de_errcrt,
      v_nrmsg          TYPE zhms_de_nrmsg,
      v_loted          TYPE zhms_de_lote,
      v_count          TYPE i.

*----------------------------------------------------------------------*
* Work Areas
*----------------------------------------------------------------------*
DATA: wa_xml_data     TYPE smum_xmltb,
      wa_xml_data_aux TYPE smum_xmltb,
      wa_logunk       TYPE zhms_tb_logunk,
      wa_controle     TYPE ty_controle,
      wa_controle_aux TYPE ty_controle,
      wa_msgatrb      TYPE zhms_es_msgat,
      wa_msgdata      TYPE zhms_es_msgdt.


*----------------------------------------------------------------------*
* Dados do Web API
*----------------------------------------------------------------------*
cl_http_client=>create_by_url(
*EXPORTING url = 'http://35.162.196.221/api/HomIntegrator/GetDocuments'
*} Inicio Alt. IP Comunic. Homintegrator By RBO com solic. Vina
*    EXPORTING url = 'http://23.96.82.36/api/HomIntegrator/GetDocuments'
*    EXPORTING url = 'http://177.54.148.148/api/HomIntegrator/GetDocuments'
      EXPORTING url = 'http://homintegratorwebapi.gswapp.com/api/HomIntegrator/GetDocuments'
*{ Fim Alt. IP Comunic. Homintegrator By RBO com solic. Vina
    IMPORTING client = client_init
    ).

*----------------------------------------------------------------------*
* Autenticação do Web API
*----------------------------------------------------------------------*
client_init->propertytype_logon_popup = client_init->co_disabled.
l_username = 'homine'.
l_password = 'homine2018'.
CALL METHOD client_init->authenticate
  EXPORTING
    username = l_username
    password = l_password.

*----------------------------------------------------------------------*
* Chamada do Web API
*----------------------------------------------------------------------*
PERFORM F_CHAMADA_WEBAPI.
PERFORM F_CARREGA_XML.

INCLUDE ZHMS_HOMINTEGRATOR_API_ROTINAS.
