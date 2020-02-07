FUNCTION ZHMS_FM_ML81N_NEW.
*"----------------------------------------------------------------------
*"*"Interface local:
*"----------------------------------------------------------------------
*" RCP - Tradução EN/ES - 31/08/2018

* MONTA O BATCH-INPUT
  PERFORM z_batch-input.

* EXECUTA O BATCH-INPUT
  PERFORM z_call_transaction.

ENDFUNCTION.

*-----------------------------------------------------------------*
*Call Transaction.
*-----------------------------------------------------------------*

*TABELAS INTERNAS DO BATCH INPUT
* ESTRUTURA DO BDC
DATA: BEGIN OF t_bdc OCCURS 0.
        INCLUDE STRUCTURE bdcdata.
DATA: END OF t_bdc.

* ESTRTURA DE MENSAGENS DO SAP.
DATA: BEGIN OF t_message OCCURS 0.
        INCLUDE STRUCTURE bdcmsgcoll.
DATA: END OF t_message.


*VAriaveis Globais
DATA: v_msgno LIKE sy-msgno, "numero da messagem de erro
      v_mode  TYPE c value 'C' .



*-----------------------------------------------------------------*
*       Insere Linha na tabela BDC
*-----------------------------------------------------------------*
FORM z_gera_tela using  p_dynbegin type c
                        p_name type FNAM_____4
                        p_dynpro.
Clear t_bdc.
   if p_dynbegin ='X'.
        T_BDC-DYNBEGIN = p_dynbegin.
        T_BDC-PROGRAM  = P_NAME.
        T_BDC-DYNPRO   =  p_dynpro.
  else.
         T_BDC-FNAM    = P_NAME.
         MOVE P_DYNPRO TO T_BDC-FVAL.
  endif.
  APPEND T_BDC.
  CLEAR T_BDC.

endform. "z_gera_tela

*-----------------------------------------------------------------*
*&      Form  Z_BATCH-INPUT
*-----------------------------------------------------------------*

*-----------------------------------------------------------------*
*&      Form  Z_BATCH-INPUT
*-----------------------------------------------------------------*
FORM  Z_BATCH-INPUT.
*Monta tabela BDC

    PERFORM z_gera_tela USING:
      'X' 'SAPLMLSR' '0400',
      ' ' 'BDC_OKCODE' '=SELP',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0410SUB_HEADER',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0420SUB_ACCEPTANCE',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0450SUB_VALUES',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0430SUB_VENDOR',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0440SUB_ORIGIN',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0460SUB_HISTORY',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0330SUB_TEXT',
      ' ' 'BDC_SUBSCR' 'SAPLMLSP                                0400SERVICE',
      ' ' 'BDC_CURSOR' 'RM11P-NEW_ROW',
      ' ' 'RM11P-NEW_ROW' '10'.
    PERFORM z_gera_tela USING:
      'X' 'SAPLMLSR' '0340',
      ' ' 'BDC_CURSOR' 'RM11R-EBELP',
      ' ' 'BDC_OKCODE' '=ENTE',
      ' ' 'RM11R-EBELN' '4500018144',
      ' ' 'RM11R-EBELP' '10'.
    PERFORM z_gera_tela USING:
      'X' 'SAPLMLSR' '0400',
      ' ' 'BDC_OKCODE' '=NEU',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0410SUB_HEADER',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0420SUB_ACCEPTANCE',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0450SUB_VALUES',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0430SUB_VENDOR',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0440SUB_ORIGIN',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0460SUB_HISTORY',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0330SUB_TEXT',
      ' ' 'BDC_SUBSCR' 'SAPLMLSP                                0400SERVICE',
      ' ' 'BDC_CURSOR' 'RM11P-NEW_ROW',
      ' ' 'RM11P-NEW_ROW' '10'.
    PERFORM z_gera_tela USING:
      'X' 'SAPLMLSR' '0400',
      ' ' 'BDC_OKCODE' '/00',
      ' ' 'ESSR-TXZ01' 'TEXTO TESTE',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0410SUB_HEADER',
      ' ' 'ESSR-LBLNE' '1235-11',
      ' ' 'ESSR-LBLDT' '18.07.2018',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0420SUB_ACCEPTANCE',
      ' ' 'BDC_CURSOR' 'ESSR-XBLNR',
      ' ' 'ESSR-BLDAT' '18.07.2018',
      ' ' 'ESSR-BUDAT' '18.07.2018',
      ' ' 'ESSR-XBLNR' '1235-11',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0450SUB_VALUES',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0430SUB_VENDOR',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0440SUB_ORIGIN',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0460SUB_HISTORY',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0330SUB_TEXT',
      ' ' 'BDC_SUBSCR' 'SAPLMLSP                                0400SERVICE',
      ' ' 'RM11P-NEW_ROW' '10'.
    PERFORM z_gera_tela USING:
      'X' 'SAPLMLSR' '0400',
      ' ' 'BDC_CURSOR' 'ESSR-TXZ01',
      ' ' 'BDC_OKCODE' '=VOKO',
      ' ' 'ESSR-TXZ01' 'TEXTO TESTE',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0410SUB_HEADER',
      ' ' 'ESSR-LBLNE' '1235-11',
      ' ' 'ESSR-LBLDT' '18.07.2018',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0420SUB_ACCEPTANCE',
      ' ' 'ESSR-BLDAT' '18.07.2018',
      ' ' 'ESSR-BUDAT' '18.07.2018',
      ' ' 'ESSR-XBLNR' '1235-11',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0450SUB_VALUES',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0430SUB_VENDOR',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0440SUB_ORIGIN',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0460SUB_HISTORY',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0330SUB_TEXT',
      ' ' 'BDC_SUBSCR' 'SAPLMLSP                                0400SERVICE',
      ' ' 'RM11P-NEW_ROW' '10'.
    PERFORM z_gera_tela USING:
      'X' 'SAPLMLSP' '0500',
      ' ' 'BDC_CURSOR' 'RM11P-MUSTER_LV',
      ' ' 'BDC_OKCODE' '=OK',
      ' ' '*RM11P-BEST_SEL' 'X'.
    PERFORM z_gera_tela USING:
      'X' 'SAPLMLSP' '0201',
      ' ' 'BDC_OKCODE' '=GRPD',
      ' ' 'BDC_SUBSCR' 'SAPLMLSP                                0400SERVICE',
      ' ' 'BDC_CURSOR' 'ESLL-EXTROW(01)',
      ' ' 'RM11P-NEW_ROW' '10',
      ' ' 'RM11P-SELKZ(01)' 'X'.
    PERFORM z_gera_tela USING:
      'X' 'SAPLMLSK' '0200',
      ' ' 'BDC_CURSOR' 'RM11K-MKNTM(01)',
      ' ' 'BDC_OKCODE' '=UMOD',
      ' ' 'VRTKZ1' 'X'.
    PERFORM z_gera_tela USING:
      'X' 'SAPLMLSK' '0100',
      ' ' 'BDC_CURSOR' 'ESKN-SAKTO',
      ' ' 'BDC_OKCODE' '=ENTE',
      ' ' 'ESKN-SAKTO' '1000000026',
      ' ' 'BDC_SUBSCR' 'SAPLKACB                                0001KONTBLOCK',
      ' ' 'DKACB-FMORE' 'X'.
    PERFORM z_gera_tela USING:
      'X' 'SAPLKACB' '0002',
      ' ' 'BDC_CURSOR' 'COBL-GSBER',
      ' ' 'BDC_OKCODE' '=ENTE',
      ' ' 'COBL-GSBER' 'HOMI',
      ' ' 'COBL-KOSTL' '10000',
      ' ' 'COBL-PRCTR' 'HOMI_01',
      ' ' 'BDC_SUBSCR' 'SAPLKACB                                9999BLOCK1'.
    PERFORM z_gera_tela USING:
      'X' 'SAPLMLSR' '0400',
      ' ' 'BDC_CURSOR' 'ESSR-TXZ01',
      ' ' 'BDC_OKCODE' '=ACCP',
      ' ' 'ESSR-TXZ01' 'TEXTO TESTE',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0410SUB_HEADER',
      ' ' 'ESSR-LBLNE' '1235-11',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0420SUB_ACCEPTANCE',
      ' ' 'ESSR-BLDAT' '18.07.2018',
      ' ' 'ESSR-BUDAT' '18.07.2018',
      ' ' 'ESSR-XBLNR' '1235-11',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0450SUB_VALUES',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0430SUB_VENDOR',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0440SUB_ORIGIN',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0460SUB_HISTORY',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0330SUB_TEXT',
      ' ' 'BDC_SUBSCR' 'SAPLMLSP                                0400SERVICE',
      ' ' 'RM11P-NEW_ROW' '10'.
    PERFORM z_gera_tela USING:
      'X' 'SAPLMLSR' '0400',
      ' ' 'BDC_OKCODE' '=SAVE',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0410SUB_HEADER',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0420SUB_ACCEPTANCE',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0450SUB_VALUES',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0430SUB_VENDOR',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0440SUB_ORIGIN',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0460SUB_HISTORY',
      ' ' 'BDC_SUBSCR' 'SAPLMLSR                                0330SUB_TEXT',
      ' ' 'BDC_SUBSCR' 'SAPLMLSP                                0400SERVICE',
      ' ' 'BDC_CURSOR' 'RM11P-NEW_ROW',
      ' ' 'RM11P-NEW_ROW' '10'.
endform.  "Z_BATCH-INPUT

FORM z_call_transaction.

  CALL TRANSACTION 'ML81N'
  USING t_bdc
  MODE V_MODE
  MESSAGES  INTO T_MESSAGE.

endform. "z_call_transaction
