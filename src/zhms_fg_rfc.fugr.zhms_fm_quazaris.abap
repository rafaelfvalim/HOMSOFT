FUNCTION zhms_fm_quazaris.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(EXNAT) TYPE  ZHMS_DE_EXNAT OPTIONAL
*"     REFERENCE(EXTPD) TYPE  ZHMS_DE_EXTPD OPTIONAL
*"     REFERENCE(MENSG) TYPE  ZHMS_DE_MENSG OPTIONAL
*"     REFERENCE(EXEVT) TYPE  ZHMS_DE_EXEVT OPTIONAL
*"     REFERENCE(DIREC) TYPE  ZHMS_DE_DIREC OPTIONAL
*"     REFERENCE(USUAR) TYPE  UNAME OPTIONAL
*"  EXPORTING
*"     REFERENCE(MSG_TEXT) TYPE  CHAR80
*"  TABLES
*"      MSGDATAM STRUCTURE  ZHMS_ES_MSGDTM OPTIONAL
*"      MSGATRBM STRUCTURE  ZHMS_ES_MSGATM OPTIONAL
*"      IT_TB_EVMN STRUCTURE  ZHMS_TB_EVMN OPTIONAL
*"----------------------------------------------------------------------

*  BREAK-POINT.

  PERFORM f_inicializa_variaveis_saida TABLES msgdatam
                                              msgatrbm
                                       USING exnat
                                             extpd
                                             mensg
                                             exevt
                                             direc
                                             usuar.

  IF direc = 'S'.
    PERFORM f_saida.

    IF v_critc IS INITIAL.

      CALL FUNCTION 'ZHMS_FM_QUAZARIS_OUT'
        DESTINATION 'ZHMS_QUAZARIS'
        EXPORTING
          exnat                 = v_exnat
          extpd                 = v_extpd
          mensg                 = v_mensg
          exevt                 = v_exevt
          direc                 = v_direc
        TABLES
          msgdata               = it_mssdata
          msgatrb               = it_mssatrb
          msgparm               = it_return
        EXCEPTIONS
          communication_failure = 1  MESSAGE msg_text
          system_failure        = 2  MESSAGE msg_text.
    ELSE.
      PERFORM f_s_grava_erros_banco.
    ENDIF.
  ENDIF.

*  v_exnat = '01'.
**  v_extpd = 'NFM2'.
*  v_extpd = 'PEVMD'.
**  v_mensg = '_FILE'.
*  v_mensg = 'SIGNA'.
*  v_exevt = 'EMITIR'.
*  v_direc = 'S'.
*
*
*  wa_msgdata-field = 'evento'.
*  wa_msgdata-seqnc = '1'.
*  wa_msgdata-value = ''.
*  APPEND wa_msgdata TO it_msgdata.
*
*  CLEAR wa_msgdata.
*  wa_msgdata-field = 'evento/infEvento'.
*  wa_msgdata-seqnc = '2'.
*  wa_msgdata-value = ''.
*  APPEND wa_msgdata TO it_msgdata.
*
*  CLEAR wa_msgdata.
*  wa_msgdata-field = 'evento/infEvento/cOrgao'.
*  wa_msgdata-seqnc = '3'.
*  wa_msgdata-value = '91'.
*  APPEND wa_msgdata TO it_msgdata.
*
*  CLEAR wa_msgdata.
*  wa_msgdata-field = 'evento/infEvento/tpAmb'.
*  wa_msgdata-seqnc = '4'.
*  wa_msgdata-value = '2'.
*  APPEND wa_msgdata TO it_msgdata.
*
*  CLEAR wa_msgdata.
*  wa_msgdata-field = 'evento/infEvento/CNPJ'.
*  wa_msgdata-seqnc = '5'.
*  wa_msgdata-value = '04897652000121'.
*  APPEND wa_msgdata TO it_msgdata.
*
*  CLEAR wa_msgdata.
*  wa_msgdata-field = 'evento/infEvento/chNFe'.
*  wa_msgdata-seqnc = '6'.
*  wa_msgdata-value = '35131104897652000121550910000012331000085235'.
*  APPEND wa_msgdata TO it_msgdata.
*
*  CLEAR wa_msgdata.
*  wa_msgdata-field = 'evento/infEvento/dhEvento'.
*  wa_msgdata-seqnc = '7'.
*  wa_msgdata-value = '2013-11-22T17:27:10-03:00'.
*  APPEND wa_msgdata TO it_msgdata.
*
*  CLEAR wa_msgdata.
*  wa_msgdata-field = 'evento/infEvento/tpEvento'.
*  wa_msgdata-seqnc = '8'.
*  wa_msgdata-value = '210200'.
*  APPEND wa_msgdata TO it_msgdata.
*
*  CLEAR wa_msgdata.
*  wa_msgdata-field = 'evento/infEvento/nSeqEvento'.
*  wa_msgdata-seqnc = '9'.
*  wa_msgdata-value = '1'.
*  APPEND wa_msgdata TO it_msgdata.
*
*  CLEAR wa_msgdata.
*  wa_msgdata-field = 'evento/infEvento/verEvento'.
*  wa_msgdata-seqnc = '10'.
*  wa_msgdata-value = '1.00'.
*  APPEND wa_msgdata TO it_msgdata.
*
*  CLEAR wa_msgdata.
*  wa_msgdata-field = 'evento/infEvento/detEvento'.
*  wa_msgdata-seqnc = '11'.
*  wa_msgdata-value = ''.
*  APPEND wa_msgdata TO it_msgdata.
*
*  CLEAR wa_msgdata.
*  wa_msgdata-field = 'evento/infEvento/detEvento/descEvento'.
*  wa_msgdata-seqnc = '12'.
*  wa_msgdata-value = 'Confirmacao da Operacao'.
*  APPEND wa_msgdata TO it_msgdata.
*
***********************************************************************
*
*  wa_msgatrb-seqnc = '1'.
*  wa_msgatrb-field = 'versao'.
*  wa_msgatrb-value = '1.00'.
*  APPEND wa_msgatrb TO it_msgatrb.
*
*  wa_msgatrb-seqnc = '2'.
*  wa_msgatrb-field = 'Id'.
*  wa_msgatrb-value = 'ID2102003513090489765200012155000000002034100008523701'.
*  APPEND wa_msgatrb TO it_msgatrb.
*
*  wa_msgatrb-seqnc = '11'.
*  wa_msgatrb-field = 'versao'.
*  wa_msgatrb-value = '1.00'.
*  APPEND wa_msgatrb TO it_msgatrb.




ENDFUNCTION.
