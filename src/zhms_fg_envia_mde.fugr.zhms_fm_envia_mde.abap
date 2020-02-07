FUNCTION ZHMS_FM_ENVIA_MDE.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(CHAVE) TYPE  CHAR44
*"     REFERENCE(TPEVENTO) TYPE  CHAR6
*"     REFERENCE(TPAMB) TYPE  CHAR1
*"     REFERENCE(NSEQEVENTO) TYPE  CHAR1
*"     REFERENCE(DESCEVENTO) TYPE  CHAR70
*"     REFERENCE(XJUST) TYPE  CHAR255
*"     REFERENCE(DHEMI) TYPE  CHAR25
*"  TABLES
*"      RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------

*==========================================================================================
*
*Desenvolvedor: Renan Itokazo
*Função para receber os parâmetros, montar e enviar o MD-e
*21.09.2018
*
*==========================================================================================

*==========================================================================================
*Declaração de variáveis
*==========================================================================================
  DATA: lv_cUF         TYPE c length 2,
        lv_tpAmb       TYPE c length 1,
        lv_cnpj        TYPE c length 14,
        lv_chNFe       TYPE c length 44,
        lv_dhEvento    TYPE c length 25,
        lv_nSeqEvento  TYPE c length 1,
        lv_descEvento  TYPE c length 60,
        lv_xJust       TYPE c length 255,
        lv_Data        type c length 8,
        lv_hora        type c length 6,
        lv_timezone    TYPE c length 6,
        http_rc        TYPE sy-subrc,
        lo_http_client TYPE REF TO if_http_client,
        lv_payload     TYPE string,
        lv_payload_x   TYPE xstring,
        lv_response    TYPE string,
        ls_sadr        LIKE sadr,
        iv_timestamp   TYPE timestampl,
        iv_timezone    TYPE tznzone,
        ev_date        TYPE dats,
        ev_time        TYPE tims,
        ev_utcdiff     TYPE tznutcdiff,
        ev_utcsign     TYPE tznutcsign.

*==========================================================================================
*Constantes de valores para chamada do Web Api
*==========================================================================================
  CONSTANTS: c_UrlAPI   TYPE string VALUE 'http://35.162.196.221:8080/api/homintegrator/EnviaMDE',
             c_User     TYPE string VALUE 'homine',
             c_Password TYPE string VALUE 'homine2018'.


*==========================================================================================
*Setando as variáveis para os dados do MDE
*==========================================================================================
  lv_chNFe = CHAVE.
  lv_cUF = CHAVE+0(2).
  lv_tpAmb = TPAMB.
  lv_cnpj = CHAVE+6(14).
  lv_nSeqEvento = nSeqevento.
  lv_descEvento = descEvento.
  lv_xjust = xjust.
  lv_dhEvento = dhEmi.
  lv_Data = sy-datum.
  lv_hora = sy-uzeit.

  GET TIME STAMP FIELD iv_timestamp.

  IF NOT ls_sadr-tzone IS INITIAL.
    iv_timezone = ls_sadr-tzone.
  ELSE.
    iv_timezone = sy-zonlo.
  ENDIF.


  CONVERT TIME STAMP iv_timestamp TIME ZONE iv_timezone
  INTO DATE ev_date TIME ev_time.

  CALL FUNCTION 'TZON_GET_OFFSET'
    EXPORTING
      if_timezone      = iv_timezone
      if_local_date    = ev_date
      if_local_time    = ev_time
    IMPORTING
      ef_utcdiff       = ev_utcdiff
      ef_utcsign       = ev_utcsign
    EXCEPTIONS
      conversion_error = 1
      OTHERS           = 2.

  CONCATENATE ev_utcsign ev_utcdiff+0(2) ':' ev_utcdiff+2(2)  into lv_timezone.

  CONCATENATE lv_Data+0(4)'-' lv_Data+4(2) '-' lv_Data+6(2) 'T' lv_hora+0(2) ':' lv_hora+2(2) ':' lv_hora+4(2) lv_timezone INTO lv_dhevento.


*==========================================================================================
*Criando o Web API
*==========================================================================================
  cl_http_client=>create_by_url(
    EXPORTING
      url    = c_UrlAPI
    IMPORTING
      client = lo_http_client
    EXCEPTIONS
      argument_not_found = 1
      plugin_not_active = 2
      internal_error    = 3
      OTHERS            = 4 ).
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

*==========================================================================================
*Dados de autenticação
*==========================================================================================
  lo_http_client->authenticate(
      username = c_User
      password = c_Password
    ).

*==========================================================================================
*Monta o json que será enviado pelo api
*Exemplo: '{"cUF":"91","tpAmb":"2","CNPJ":"04897652000121","chNFe":"35180904897652000121550010000027401942025922","dhEvento":"2018-09-24T16:54:53-03:00","tpEvento":"210200","nSeqEvento":"1","DescEvento":"Confirmacao da Operacao","xJust":""}'.
*==========================================================================================
  CONCATENATE '{"cUF":"' lv_cUF '","tpAmb":"' lv_tpAmb '","CNPJ":"' lv_CNPJ '","chNFe":"' chave '","dhEvento":"' lv_dhEvento '","tpEvento":"' tpEvento '","nSeqEvento":"' lv_nSeqEvento '","DescEvento":"' lv_DescEvento '","xJust":"' lv_xJust '"}'  INTO
  lv_payload.


  CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
    EXPORTING
      text   = lv_payload
    IMPORTING
      buffer = lv_payload_x.


  lo_http_client->request->set_method( 'POST' ).
  lo_http_client->request->set_content_type( 'application/json' ).
  lo_http_client->request->set_data( lv_payload_x ).
  lo_http_client->send(
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state        = 2 ).

  lo_http_client->receive(
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state        = 2
      http_processing_failed    = 3 ).

  lo_http_client->response->get_status( IMPORTING code = http_rc ).


*==========================================================================================
*Caso o código de retorno seja diferente de 201(Código OK)
*==========================================================================================
  IF http_rc NE '201'.
    return-type = 'E'.
    return-message = 'erro teste'.
    append return.
  ENDIF.


ENDFUNCTION.
