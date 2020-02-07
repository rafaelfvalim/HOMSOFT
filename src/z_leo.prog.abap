*&---------------------------------------------------------------------*
*& Report  Z_LEO
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  Z_LEO.
DATA: ITXLS     TYPE STANDARD TABLE OF KCDE_CELLS,
      WAXLS     TYPE KCDE_CELLS.


DATA: LT_EVENTS TYPE STANDARD TABLE OF J_1BT604FV,
      LS_EVENTS LIKE LINE OF LT_EVENTS,
      LT_T604F TYPE STANDARD TABLE OF T604F,
      LS_T604F LIKE LINE OF LT_T604F,
      LT_T604N TYPE STANDARD TABLE OF T604N,
      LS_T604N LIKE LINE OF LT_T604N.

*TABELAS INTERNAS DO BATCH INPUT
* ESTRUTURA DO BDC
DATA: BEGIN OF T_BDC OCCURS 0.
        INCLUDE STRUCTURE BDCDATA.
DATA: END OF T_BDC.

* ESTRTURA DE MENSAGENS DO SAP.
DATA: BEGIN OF T_MESSAGE OCCURS 0.
        INCLUDE STRUCTURE BDCMSGCOLL.
DATA: END OF T_MESSAGE.


*VAriaveis Globais
DATA: V_MSGNO LIKE SY-MSGNO, "numero da messagem de erro
      V_MODE  TYPE C VALUE 'A' .

SELECTION-SCREEN BEGIN OF BLOCK B0 WITH FRAME TITLE TEXT-001.
PARAMETERS:   PARQV TYPE  RLGRAP-FILENAME OBLIGATORY.
SELECTION-SCREEN END OF BLOCK B0.

INITIALIZATION.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR PARQV.
  DATA: ITFILE  TYPE STANDARD TABLE OF OCS_F_INFO,
        WAFILE  TYPE OCS_F_INFO.

  CLEAR: PARQV, ITFILE[], WAFILE.

  CALL FUNCTION 'OCS_FILENAME_GET'
    EXPORTING
      PI_DEF_FILENAME  = ' '
      PI_DEF_PATH      = 'C:\'
      PI_MASK          = ',*.xls,*.xlsx'
      PI_MODE          = 'O'
      PI_TITLE         = TEXT-H03
    TABLES
      PT_FILEINFO      = ITFILE
    EXCEPTIONS
      INV_WINSYS       = 1
      NO_BATCH         = 2
      SELECTION_CANCEL = 3
      SELECTION_ERROR  = 4
      GENERAL_ERROR    = 5
      OTHERS           = 6.

  IF SY-SUBRC = 0.
    READ TABLE ITFILE INTO WAFILE INDEX 1.
    IF SY-SUBRC = 0.
      CONCATENATE WAFILE-FILE_PATH WAFILE-FILE_NAME INTO PARQV.
    ENDIF.
  ENDIF.

START-OF-SELECTION.
  PERFORM CARREGA_ARQUIVO.
  PERFORM INSERT_TABLE.
* MONTA O BATCH-INPUT
*  PERFORM Z_BATCH-INPUT.

* EXECUTA O BATCH-INPUT
*  PERFORM Z_CALL_TRANSACTION.
  PERFORM GRAVA_DADOS.
*&---------------------------------------------------------------------*
*&      Form  CARREGA_ARQUIVO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CARREGA_ARQUIVO .

  REFRESH ITXLS[].
  CALL FUNCTION 'KCD_EXCEL_OLE_TO_INT_CONVERT'
    EXPORTING
      FILENAME                = PARQV
      I_BEGIN_COL             = '1'
      I_BEGIN_ROW             = '1'
      I_END_COL               = '100'
      I_END_ROW               = '25000'
    TABLES
      INTERN                  = ITXLS
    EXCEPTIONS
      INCONSISTENT_PARAMETERS = 1
      UPLOAD_OLE              = 2
      OTHERS                  = 3.

  IF SY-SUBRC IS NOT INITIAL.
    MESSAGE 'Erro ao carregar arquivo' TYPE 'I'.
    EXIT.
  ENDIF.

ENDFORM.                    " CARREGA_ARQUIVO
*&---------------------------------------------------------------------*
*&      Form  INSERT_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_TABLE .

  LOOP AT ITXLS INTO WAXLS.

    CASE WAXLS-COL.
      WHEN '1'.
        MOVE WAXLS-VALUE TO LS_EVENTS-LAND1.
      WHEN '2'.
        MOVE WAXLS-VALUE TO LS_EVENTS-STEUC.
      WHEN '3'.
        MOVE WAXLS-VALUE TO LS_EVENTS-TEXT1.
        APPEND LS_EVENTS TO LT_EVENTS.
        CLEAR LS_EVENTS .
    ENDCASE.

  ENDLOOP.


ENDFORM.                    " INSERT_TABLE
*-----------------------------------------------------------------*
*&      Form  Z_BATCH-INPUT
*-----------------------------------------------------------------*
FORM  Z_BATCH-INPUT.
*Monta tabela BDC
  DATA: V_REG(1) TYPE C.

  PERFORM Z_GERA_TELA USING:
    'X' 'SAPMSVMA' '0100',
    ' ' 'BDC_CURSOR' 'VIEWNAME',
    ' ' 'BDC_OKCODE' '=UPD',
    ' ' 'VIEWNAME' 'J_1BT604FV',
    ' ' 'VIMDYNFLDS-LTD_DTA_NO' 'X'.
  LOOP AT LT_EVENTS INTO LS_EVENTS.
    PERFORM Z_GERA_TELA USING:
      'X' 'SAPLJ1BV' '0100',
      ' ' 'BDC_CURSOR' 'J_1BT604FV-TEXT1(01)',
      ' ' 'BDC_OKCODE' '=NEWL'.
    PERFORM Z_GERA_TELA USING:
      'X' 'SAPLJ1BV' '0101',
      ' ' 'BDC_CURSOR' 'J_1BT604FV-TEXT1',
      ' ' 'BDC_OKCODE' '=SAVE',
      ' ' 'J_1BT604FV-LAND1' LS_EVENTS-LAND1,
      ' ' 'J_1BT604FV-STEUC' LS_EVENTS-STEUC ,
      ' ' 'J_1BT604FV-TEXT1' LS_EVENTS-TEXT1.
    IF V_REG IS INITIAL.
      PERFORM Z_GERA_TELA USING:
        'X' 'SAPLJ1BV' '0101',
        ' ' 'BDC_CURSOR' 'J_1BT604FV-TEXT1',
        ' ' 'BDC_OKCODE' '=UEBE',
        ' ' 'J_1BT604FV-TEXT1' LS_EVENTS-TEXT1.
      V_REG = 'X'.
    ENDIF.
    PERFORM Z_GERA_TELA USING:
      'X' 'SAPLJ1BV' '0101',
      ' ' 'BDC_CURSOR' 'J_1BT604FV-TEXT1',
      ' ' 'BDC_OKCODE' '=UEBE',
      ' ' 'J_1BT604FV-TEXT1' LS_EVENTS-TEXT1.
*    PERFORM z_gera_tela USING:
*      'X' 'SAPLJ1BV' '0100',
*      ' ' 'BDC_CURSOR' 'J_1BT604FV-TEXT1(01)',
*      ' ' 'BDC_OKCODE' '=NEWL'.
*    PERFORM z_gera_tela USING:
*      'X' 'SAPLJ1BV' '0101',
*      ' ' 'BDC_CURSOR' 'J_1BT604FV-TEXT1',
*      ' ' 'BDC_OKCODE' '=SAVE',
*      ' ' 'J_1BT604FV-LAND1' 'br',
*      ' ' 'J_1BT604FV-STEUC' '33',
*      ' ' 'J_1BT604FV-TEXT1' 'dd'.
*    PERFORM z_gera_tela USING:
*      'X' 'SAPLJ1BV' '0101',
*      ' ' 'BDC_CURSOR' 'J_1BT604FV-TEXT1',
*      ' ' 'BDC_OKCODE' '=UEBE',
*      ' ' 'J_1BT604FV-TEXT1' 'dd'.
  ENDLOOP.
  PERFORM Z_GERA_TELA USING:
    'X' 'SAPLJ1BV' '0100',
    ' ' 'BDC_OKCODE' '/EABR',
    ' ' 'BDC_CURSOR' 'J_1BT604FV-TEXT1(01)'.
  PERFORM Z_GERA_TELA USING:
    'X' 'SAPMSVMA' '0100',
    ' ' 'BDC_OKCODE' '/EBACK',
    ' ' 'BDC_CURSOR' 'VIEWNAME'.
ENDFORM.  "Z_BATCH-INPUT


*-----------------------------------------------------------------*
*       Insere Linha na tabela BDC
*-----------------------------------------------------------------*
FORM Z_GERA_TELA USING  P_DYNBEGIN TYPE C
                        P_NAME TYPE FNAM_____4
                        P_DYNPRO.
  CLEAR T_BDC.
  IF P_DYNBEGIN ='X'.
    T_BDC-DYNBEGIN = P_DYNBEGIN.
    T_BDC-PROGRAM  = P_NAME.
    T_BDC-DYNPRO   =  P_DYNPRO.
  ELSE.
    T_BDC-FNAM    = P_NAME.
    MOVE P_DYNPRO TO T_BDC-FVAL.
  ENDIF.
  APPEND T_BDC.
  CLEAR T_BDC.

ENDFORM. "z_gera_tela


*-----------------------------------------------------------------*
*Call Transaction.
*-----------------------------------------------------------------*
FORM Z_CALL_TRANSACTION.

  CALL TRANSACTION 'SM30'
  USING T_BDC
  MODE V_MODE
  MESSAGES  INTO T_MESSAGE.

ENDFORM. "z_call_transaction
*&---------------------------------------------------------------------*
*&      Form  GRAVA_DADOS
*&---------------------------------------------------------------------*
FORM GRAVA_DADOS .

  LOOP AT LT_EVENTS INTO LS_EVENTS.
    MOVE-CORRESPONDING: LS_EVENTS TO LS_T604F.
    MOVE-CORRESPONDING: LS_EVENTS TO LS_T604N.
    LS_T604N-SPRAS = 'P'.
   INSERT INTO T604F VALUES LS_T604F.
*    delete from T604F.
    IF SY-SUBRC = 0.
      COMMIT WORK.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
       INSERT INTO T604N VALUES LS_T604N.
*    delete from T604N.
    IF SY-SUBRC = 0.
      COMMIT WORK.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " GRAVA_DADOS
