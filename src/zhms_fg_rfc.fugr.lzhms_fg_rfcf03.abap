*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_RFCF03 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  f_INICIALIZA_VARIAVEIS
*&---------------------------------------------------------------------*
*       Mover valores recebidos as variáveis internas
*----------------------------------------------------------------------*

FORM F_INICIALIZA_VARIAVEIS  TABLES P_MSGDATA STRUCTURE ZHMS_ES_MSGDT
                                    P_MSGATRB STRUCTURE ZHMS_ES_MSGAT
                             USING  P_DIREC
                                    P_MENSG
                                    P_EXNAT
                                    P_EXTPD
                                    P_EXEVT .

* Limpar variáveis do programa
  REFRESH: IT_MSSDATA,
           IT_MSSATRB,
           IT_EVV_LAYT,
           IT_MSGEVLT,
           IT_EVVL_ATR,
           IT_REPOTAG,
           IT_REPOTAGAT,
           IT_REPOMNEUM,
           IT_REPOMNEUMAT,
           IT_LOGUNK,
           IT_MSGUNK,
           IT_MSGUNKA,
           IT_MAPCONEC,
           IT_MAPDATAC,
*==============================================================================
*Renan Itokazo
*13.09.2018
*Alterado para corrigir a recepcao de lotes do HomIntegrator WebAPI(Itens)
           it_itmdoc.
*==============================================================================

  CLEAR: V_CRITC,
         V_NATDC,
         V_TYPED,
         V_EVENT,
         V_VERSN,
         V_VERSNLEG,
         V_CHAVE,
         V_LOTED,
         V_NRMSG,
         V_IMPORT,
         V_CNPJEMP,
         V_CHAVE.

  CLEAR: WA_MSSDATA,
         WA_MSSATRB,
         WA_EVV_LAYT,
         WA_MSGEVLT,
         WA_EVVL_ATR,
         WA_REPOTAG,
         WA_REPOTAGAT,
         WA_REPOMNEUM,
         WA_REPOMNEUMAT,
         WA_LOGUNK,
         WA_MSGUNK,
         WA_MSGUNKA,
         WA_MAPCONEC,
         WA_MAPDATAC,
         WA_HISTEVE.

  CLEAR: WA_LOGUNK,
         WA_MSGUNK.

  TRANSLATE P_EXNAT TO UPPER CASE.
  TRANSLATE P_EXTPD TO UPPER CASE.
  TRANSLATE P_EXEVT TO UPPER CASE.
  TRANSLATE P_MENSG TO UPPER CASE.

* Estrutura de XML
  IT_MSSDATA[] = P_MSGDATA[].

* Atributos de XML
  IT_MSSATRB[] = P_MSGATRB[].

* Denominadores Externos
  V_EXNAT = P_EXNAT.
  V_EXTPD = P_EXTPD.
  V_MENSG = P_MENSG.



*Renan Itokazo - 26.06.2018
*Cancelamento de CT-e


  IF V_CHAVE IS INITIAL.
    IF P_EXTPD EQ '55'.
      READ TABLE IT_MSSDATA INTO WA_MSSDATA WITH KEY FIELD = 'procEventoNFe/evento/infEvento/chNFe'.
    ELSEIF P_EXTPD EQ '57'.
      READ TABLE IT_MSSDATA INTO WA_MSSDATA WITH KEY FIELD = 'cteProc/protCTe/infProt/chCTe'.
    ENDIF.
    IF SY-SUBRC EQ 0.
      V_CHAVE = WA_MSSDATA-VALUE.
    ENDIF.
  ENDIF.



* Verifica se é um cancelamento
  IF P_EXTPD EQ '55'.
    READ TABLE IT_MSSDATA INTO WA_MSSDATA WITH KEY SEQNC = '35'.
  ELSEIF P_EXTPD EQ '57'.
    READ TABLE IT_MSSDATA INTO WA_MSSDATA WITH KEY SEQNC = '154'.
  ENDIF.
  IF SY-SUBRC EQ 0.
    SELECT SINGLE CSTAT
      FROM ZHMS_TB_STATUS_C
      INTO V_CSTAT
      WHERE CSTAT = WA_MSSDATA-VALUE.

    IF SY-SUBRC EQ 0.
      V_EXEVT = '1003XML'.
      PERFORM F_EDIT_STATUS.
    ELSE.
      V_EXEVT = P_EXEVT.
    ENDIF.

  ELSE.
    V_EXEVT = P_EXEVT.
  ENDIF.

  V_DIREC = P_DIREC.

  V_DATA = SY-DATUM.
  V_HORA = SY-UZEIT.

  "Busca o Número do Lote
  CALL FUNCTION 'ZHMS_FM_LOTE_DADOS'
    EXPORTING
      V_OBJETO = 'ZHMS_ON_LT'
    IMPORTING
      V_LOTE   = V_LOTED.

* Iguala as tags (recebidas e cadastradas) em Upper Case (maiúsculas)
  LOOP AT IT_MSSDATA INTO WA_MSSDATA.
    TRANSLATE WA_MSSDATA-FIELD TO UPPER CASE.
    CONDENSE WA_MSSDATA-FIELD.
    MODIFY IT_MSSDATA FROM WA_MSSDATA INDEX SY-TABIX.
  ENDLOOP.

* Iguala as tags (recebidas e cadastradas) em Upper Case (maiúsculas)
  LOOP AT  IT_MSSATRB INTO WA_MSSATRB.
    TRANSLATE WA_MSSATRB-FIELD TO UPPER CASE.
    CONDENSE WA_MSSATRB-FIELD.
    MODIFY  IT_MSSATRB FROM WA_MSSATRB INDEX SY-TABIX.
  ENDLOOP.

  IF IT_MSSDATA[] IS INITIAL.
    V_CRITC = 'X'.
*   Tratamento de Erro
    CLEAR WA_LOGUNK.
    WA_LOGUNK-ERRO = 'Erro: Estrutura de mapeamento não contém dados'.
    PERFORM F_ERRO.
  ENDIF.

  IF V_DIREC IS INITIAL.
    V_CRITC = 'X'.
*   Tratamento de Erro
    CLEAR WA_LOGUNK.
    WA_LOGUNK-ERRO =  'Erro: Direção não informada'.
    PERFORM F_ERRO.
  ENDIF.

ENDFORM.                    " f_INICIALIZA_VARIAVEIS
*&---------------------------------------------------------------------*
*&      Form  F_INICIALIZA_VARIAVEIS_SAIDA
*&---------------------------------------------------------------------*
FORM F_INICIALIZA_VARIAVEIS_SAIDA  TABLES P_MSGDATAM STRUCTURE ZHMS_ES_MSGDTM
                                          P_MSGATRBM STRUCTURE ZHMS_ES_MSGATM
                                   USING  P_EXNAT
                                          P_EXTPD
                                          P_MENSG
                                          P_EXEVT
                                          P_DIREC
                                          P_USUAR.

  REFRESH:  IT_MSSDATA,
            IT_MSSATRB,
            IT_EVV_LAYT,
            IT_MSGEVLT,
            IT_MSGEVL_A,
            IT_EVVL_ATR,
            IT_EVMN,
            IT_EVMNA,
            IT_REPCOM,
            IT_REPCOMA,
            IT_MSSDATAM,
            IT_MSSATRBM.

  CLEAR:    V_CRITC,
            V_NATDC,
            V_TYPED,
            V_EVENT,
            V_VERSN,
            V_VERSNLEG,
            V_CHAVE,
            V_LOTED,
            V_NRMSG,
            V_USUAR.
  CLEAR:
            WA_MSSDATA,
            WA_MSSATRB,
            WA_EVV_LAYT,
            WA_MSGEVLT,
            WA_MSGEVL_A,
            WA_EVVL_ATR,
            WA_EVMN,
            WA_EVMNA,
            WA_REPCOM,
            WA_REPCOMA,
            WA_HISTEVE.


  V_EXNAT = P_EXNAT.
  V_EXTPD = P_EXTPD.
  V_EXEVT = P_EXEVT.
  V_DIREC = P_DIREC.
  V_USUAR = P_USUAR.

  TRANSLATE V_EXNAT TO UPPER CASE.
  TRANSLATE V_EXTPD TO UPPER CASE.
  TRANSLATE V_EXEVT TO UPPER CASE.
  TRANSLATE V_DIREC TO UPPER CASE.

  V_DATA = SY-DATUM.
  V_HORA = SY-UZEIT.

  V_USUAR = P_USUAR.

* Estrutura de XML
  IT_MSSDATAM[] = P_MSGDATAM[].

* Atributos de XML
  IT_MSSATRBM[] = P_MSGATRBM[].

* Iguala as tags (recebidas e cadastradas) em Upper Case (maiúsculas)
  LOOP AT IT_MSSDATAM INTO WA_MSSDATAM.
    TRANSLATE WA_MSSDATAM-MNEUM TO UPPER CASE.
    CONDENSE WA_MSSDATAM-MNEUM.
    MODIFY IT_MSSDATAM FROM WA_MSSDATAM INDEX SY-TABIX.
  ENDLOOP.

* Iguala as tags (recebidas e cadastradas) em Upper Case (maiúsculas)
  LOOP AT IT_MSSATRBM INTO WA_MSSATRBM.
    TRANSLATE WA_MSSATRBM-MNEUM TO UPPER CASE.
    CONDENSE WA_MSSATRBM-MNEUM.
    MODIFY IT_MSSATRBM FROM WA_MSSATRBM INDEX SY-TABIX.
  ENDLOOP.

  "Busca o Número do Lote
  CALL FUNCTION 'ZHMS_FM_LOTE_DADOS'
    EXPORTING
      V_OBJETO = 'ZHMS_ON_LT'
    IMPORTING
      V_LOTE   = V_LOTED.

  IF IT_MSSDATAM[] IS INITIAL.
    V_CRITC = 'X'.
*   Tratamento de Erro
    CLEAR WA_LOGUNK.
    WA_LOGUNK-ERRO = 'Erro: Nenhum dado encontrado'.
    PERFORM F_S_ERRO.
  ENDIF.

ENDFORM.                    " F_INICIALIZA_VARIAVEIS_SAIDA
