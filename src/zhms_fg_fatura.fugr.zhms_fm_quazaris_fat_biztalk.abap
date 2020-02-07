*-------------------------------------------------------------------*
* HomSoft - Documentos Eletrônicos : Connector *
*-------------------------------------------------------------------*
* Descrição	: RFC para conexão entre o sistema SAP e *
* o HomSoft: Quazaris *
*-------------------------------------------------------------------*
* Global data declarations

FUNCTION zhms_fm_quazaris_fat_biztalk .
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(EXNAT) TYPE  ZHMS_DE_EXNAT
*"     VALUE(EXTPD) TYPE  ZHMS_DE_EXTPD
*"     VALUE(MENSG) TYPE  ZHMS_DE_MENSG
*"     VALUE(EXEVT) TYPE  ZHMS_DE_EXEVT
*"     VALUE(DIREC) TYPE  ZHMS_DE_DIREC
*"     VALUE(XMLSTRINGBIN) TYPE  XSTRING
*"  TABLES
*"      RETURN STRUCTURE  ZHMS_ES_RETURN OPTIONAL
*"----------------------------------------------------------------------

*** Declara tipo de Documento CT-e - 57
  DATA lv_extpdc      TYPE zhms_de_extpd VALUE '57'.
  DATA lti_log_biztalk TYPE STANDARD TABLE OF zhms_tb_biztalk.
  DATA lwa_log_biztalk TYPE  zhms_tb_biztalk.
  DATA lwa_return LIKE LINE OF return.

*** Verifica se XML String está preenchida
  IF xmlstringbin IS NOT INITIAL.

*** Executa rotina de gravação XML - Fatura e N CT-es
    PERFORM f_trata_xml IN PROGRAM zhms_carga_fatura
                            TABLES return             " Retorno
                             USING xmlstringbin       " XML
                                   exnat              " Natureza do Documento
                                   lv_extpdc          " Tipo de Doc. CT-e
                                   extpd              " Tipo de Doc. Fatura
                                   mensg              " Mensageria - Default NEO
                                   exevt              " Evento     - Default 1003
                                   direc              " Direção    - Default E (Entrada)
                                   IF FOUND.
    IF  return[] IS NOT INITIAL.
      lwa_log_biztalk-data  = sy-datum.
      GET TIME STAMP FIELD lwa_log_biztalk-hora.
      LOOP AT return INTO lwa_return.
        ADD 1 TO lwa_log_biztalk-seq.
        lwa_log_biztalk-retnr = lwa_return-retnr.
        lwa_log_biztalk-descr = lwa_return-descr.
        APPEND lwa_log_biztalk TO lti_log_biztalk.
      ENDLOOP.
      MODIFY zhms_tb_biztalk FROM TABLE lti_log_biztalk.
      IF sy-subrc EQ 0.
        COMMIT WORK.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFUNCTION.
