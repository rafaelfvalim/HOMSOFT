*&---------------------------------------------------------------------*
*& Report  ZHMS_MSF_JOB_GETXML
*&
*&---------------------------------------------------------------------*
*& Homine - HomSoft - Job dispara metodo GETXML - Mastersaf
*& David Rosin - 09/04/2014
*&---------------------------------------------------------------------*
* RCP - Tradução EN/ES - 13/08/2018
*&---------------------------------------------------------------------*
REPORT  zhms_msf_job_getxml.

*** Declaração
DATA: lt_msf_xml   TYPE STANDARD TABLE OF zhms_tb_msf_xml,
      lt_datam     TYPE STANDARD TABLE OF zhms_es_msgdtm,
      ls_msf_xml   LIKE LINE OF lt_msf_xml,
      ls_datam     LIKE LINE OF lt_datam,
      ls_tb_events TYPE zhms_tb_events.


*** Seleciona todos os registros que ainda não foram recepcionados
REFRESH lt_msf_xml[].
SELECT * FROM zhms_tb_msf_xml INTO TABLE lt_msf_xml WHERE recebido EQ abap_false.

CHECK sy-subrc IS INITIAL.

CLEAR ls_msf_xml.
LOOP AT lt_msf_xml INTO ls_msf_xml.

*** Busca Evento de acordo com o tipo do documento
   CLEAR ls_tb_events.
  SELECT SINGLE *
    FROM zhms_tb_events
    INTO ls_tb_events
   WHERE natdc EQ '02'
     AND typed EQ ls_msf_xml-tipo_doc.

  IF sy-subrc IS INITIAL.

*** Carrega Menumonicos
    REFRESH lt_datam[].
    CLEAR ls_datam.

*** Dispara o metodo GETXML Mastersaf
    CALL FUNCTION 'ZHMS_FM_QUAZARIS'
      EXPORTING
        exnat    = '2'
        mensg    = 'MASTERSAF'
        exevt    = ls_tb_events-event
        direc    = ls_tb_events-direc
        usuar    = sy-uname
      TABLES
        msgdatam = lt_datam.

*** Atualiza data e hora do envio da solicitação de download do XML para Mastersaf
    UPDATE zhms_tb_msf_xml
      SET: data_env = sy-datum
           hora_env = sy-uzeit
     WHERE chave EQ ls_msf_xml-chave.

    IF sy-subrc IS INITIAL.
      COMMIT WORK.
    ELSE.
      ROLLBACK WORK.
    ENDIF.

    CLEAR ls_msf_xml.

  ENDIF.

ENDLOOP.
