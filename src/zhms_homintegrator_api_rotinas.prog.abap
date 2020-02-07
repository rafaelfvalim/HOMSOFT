*&---------------------------------------------------------------------*
*&  Include           ZHMS_HOMINTEGRATOR_API_ROTINAS
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_ERRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_erro .
  ADD 1 TO v_nrmsg.
  wa_logunk-nrmsg = v_nrmsg.
  wa_logunk-lote  = v_loted.
  wa_logunk-exnat = v_exnat.
  wa_logunk-extpd = v_extpd.
  wa_logunk-mensg = v_mensg.
  wa_logunk-exevt = v_exevt.
  wa_logunk-direc = v_direc.
  wa_logunk-dtalt = sy-datum.
  wa_logunk-hralt = sy-uzeit.
  wa_logunk-event = ''.
  wa_logunk-natdc = ''.
  wa_logunk-typed = ''.
  APPEND wa_logunk TO it_logunk.
ENDFORM.                    " F_ERRO
*&---------------------------------------------------------------------*
*&      Form  F_E_GRAVA_CRITICAS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_e_grava_criticas .
  TRY .
      INSERT zhms_tb_logunk   FROM TABLE it_logunk.
    CATCH cx_root.
  ENDTRY.
ENDFORM.                    " F_E_GRAVA_CRITICAS
*&---------------------------------------------------------------------*
*&      Form  F_CHAMADA_WEBAPI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_chamada_webapi .
  CALL METHOD client_init->send
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3
      http_invalid_timeout       = 4
      OTHERS                     = 5.
  IF sy-subrc <> 0.
    CLEAR wa_logunk.
    wa_logunk-erro = 'Erro: Erro ao enviar a solicitação HTTP'.
    PERFORM f_erro.
    PERFORM f_e_grava_criticas.
    EXIT.
  ENDIF.

  CALL METHOD client_init->receive
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3
      OTHERS                     = 4.
  IF sy-subrc <> 0.
    CLEAR wa_logunk.
    wa_logunk-erro = 'Erro: Erro ao receber a solicitação HTTP'.
    PERFORM f_erro.
    PERFORM f_e_grava_criticas.
    EXIT.
  ENDIF.

  client_init->response->get_status( IMPORTING code = http_rc ).

  json = client_init->response->get_cdata( ).
  client_init->close( ).

  IF http_rc EQ '401'.
    CLEAR wa_logunk.
    wa_logunk-erro = 'Erro: Usuário ou senha inválidos'.
    PERFORM f_erro.
    PERFORM f_e_grava_criticas.
    EXIT.
  ENDIF.
ENDFORM.                    " F_CHAMADA_WEBAPI
*&---------------------------------------------------------------------*
*&      Form  F_CARREGA_XML
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_carrega_xml .

  len = strlen( json ).

*Verifica se retornou XML
  IF len > 10.
*Removendo os 2 primeiros e 2 últimos caracteres do json
    SHIFT json BY 2 PLACES.
    len = len - 3.
    json = json+0(len).

* Separando os XML e gravando em tabela interna
    SPLIT json AT 'ENDOFXML"' INTO TABLE it_texto.

    LOOP AT it_texto INTO json.
      IF NOT it_texto IS INITIAL.
        IF sy-tabix EQ 1.
          prefixo = json+0(3).
          SHIFT json BY 4 PLACES.
        ELSE.
          prefixo = json+2(3).
          SHIFT json BY 6 PLACES.
        ENDIF.


        IF prefixo EQ 'nfm'.
          v_exnat = '02'.
          v_extpd = '55'.
          v_mensg = 'SIGNA'.
          v_exevt = '1003'.
          v_direc = 'E'.
        ENDIF.

        IF prefixo EQ 'nfs'.
          v_exnat = 'recepcao'.
          v_extpd = 'nfse1'.
          v_mensg = 'SIGNA'.
          v_exevt = '1003'.
          v_direc = 'E'.
        ENDIF.

        IF prefixo EQ 'cte'.
          v_exnat = 'recepcao'.
          v_extpd = 'cte'.
          v_mensg = 'SIGNA'.
          v_exevt = '1003'.
          v_direc = 'E'.
        ENDIF.



        CLEAR ld_buffer.
        REPLACE ALL OCCURRENCES OF '\' IN json WITH ''.
**Converter o XML recebeido para Xstring
        CALL FUNCTION 'SCMS_STRING_TO_XSTRING' "
          EXPORTING
            text = json                    " string
*   mimetype = SPACE            " c
*   encoding =                  " abap_encoding
          IMPORTING
            buffer =   ld_buffer                 " xstring
          EXCEPTIONS
            failed = 1                  "
            .  "  SCMS_STRING_TO_XSTRING

* Converter o XML para uma internal table
        CALL FUNCTION 'SMUM_XML_PARSE'
          EXPORTING
            xml_input = ld_buffer
          TABLES
            xml_table = it_xml_data
            return    = it_return.

        DELETE it_xml_data WHERE type = '+'.
        it_xml_data_aux = it_xml_data.

        LOOP AT it_xml_data_aux INTO wa_xml_data.
          ADD 1 TO wa_controle-seqnc.
          IF wa_xml_data-type = 'A'.
            wa_msgatrb-seqnc = sy-tabix.
            wa_msgatrb-seqnc = wa_msgatrb-seqnc - 1.
            wa_msgatrb-field = wa_xml_data-cname.
            wa_msgatrb-value = wa_xml_data-cvalue.
            APPEND wa_msgatrb TO it_msgatrb.
            DELETE it_xml_data_aux INDEX sy-tabix.
            CONTINUE.
          ENDIF.
        ENDLOOP.



        CLEAR wa_controle-seqnc.
        SORT it_xml_data_aux BY hier DESCENDING.
        LOOP AT it_xml_data INTO wa_xml_data.
          ADD 1 TO wa_controle-seqnc.
          IF wa_xml_data-type = 'A'.
            DELETE it_xml_data INDEX sy-tabix.
            CONTINUE.
          ENDIF.

          wa_controle-seqnc = wa_controle-seqnc.
          wa_controle-hier = wa_xml_data-hier.
          wa_controle-field = wa_xml_data-cname.
          IF wa_xml_data-hier > 1.
            SORT it_controle BY seqnc DESCENDING.
            vhier = wa_xml_data-hier - 1.
            READ TABLE it_controle INTO wa_controle_aux WITH KEY hier = vhier.
            IF sy-subrc EQ 0.
              CONCATENATE wa_controle_aux-field '/' wa_xml_data-cname INTO wa_controle-field.
              wa_controle-value = wa_xml_data-cvalue.
            ENDIF.
          ENDIF.
          APPEND wa_controle TO it_controle.
        ENDLOOP.

        SORT it_controle BY seqnc.
        LOOP AT it_controle INTO wa_controle.
          v_count = sy-tabix.
          wa_controle-seqnc = v_count.
          MOVE-CORRESPONDING wa_controle TO wa_msgdata.
          APPEND wa_msgdata TO it_msgdata.
        ENDLOOP.

        IF prefixo EQ 'nfs'.
          wa_msgdata-seqnc = v_count + 1.
          wa_msgdata-field = 'RFE_NFSE/CSTAT'.
          wa_msgdata-value = '100'.
          APPEND wa_msgdata TO it_msgdata.
*          ADD 1 TO wa_controle-seqnc.
*          wa_msgatrb-seqnc = wa_msgatrb-seqnc - 1.
*          wa_msgatrb-field = 'RFE_NFSE/CSTAT'.
*          wa_msgatrb-value = '100'.
*          APPEND wa_msgatrb TO it_msgatrb.
        ENDIF.


      ENDIF.

**Enviar o XML para a função ZHMS_FM_QUAZARIS_IN para realizar a integração com o HOMSOFT
      CALL FUNCTION 'ZHMS_FM_QUAZARIS_IN'
        EXPORTING
          exnat   = v_exnat
          extpd   = v_extpd
          mensg   = v_mensg
          exevt   = v_exevt
          direc   = v_direc
        TABLES
          msgdata = it_msgdata
          msgatrb = it_msgatrb
          return  = it_return_qzr.

*write:/ json.

      CLEAR: it_msgdata,it_msgatrb,it_return_qzr,ld_buffer,json,it_xml_data,it_xml_data_aux,it_controle.

    ENDLOOP.
    break ritokazo.
  ENDIF.
ENDFORM.                    " F_CARREGA_XML
