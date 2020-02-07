FUNCTION ZHMS_ENVIA_EMAILFATURA.
*"--------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(CHAVE) TYPE  ZHMS_DE_CHAVE OPTIONAL
*"     VALUE(USUARIO) TYPE  SY-UNAME OPTIONAL
*"     REFERENCE(NATDC) TYPE  ZHMS_DE_NATDC OPTIONAL
*"     REFERENCE(TYPED) TYPE  ZHMS_DE_TYPED OPTIONAL
*"     REFERENCE(ETAPA) TYPE  ZHMS_DE_FLOWD OPTIONAL
*"     REFERENCE(OTHERS) TYPE  FLAG OPTIONAL
*"     REFERENCE(TITULO) TYPE  STRING OPTIONAL
*"     REFERENCE(CORPO) TYPE  STRING OPTIONAL
*"--------------------------------------------------------------------
  DATA:IT_RECEIVERS       TYPE STANDARD TABLE OF  SOMLRECI1,
       WA_IT_RECEIVERS    LIKE LINE OF IT_RECEIVERS,
       IT_PACKING_LIST    TYPE STANDARD TABLE OF  SOPCKLSTI1,
       GD_DOC_DATA        TYPE SODOCCHGI1,
       WA_IT_PACKING_LIST LIKE LINE OF  IT_PACKING_LIST,
       PSUBJECT(90)       TYPE C,
       IT_MESSAGE         TYPE STANDARD TABLE OF SOLISTI1,
       WA_IT_MESSAGE      LIKE LINE OF IT_MESSAGE,
       C1(99)             TYPE C,
       C2(200)            TYPE C,
       NUM_LINES          TYPE I,
       LV_NOTAX           TYPE ZHMS_DE_MNEUM,
       LV_NOTA            TYPE CHAR10,
       LV_PARID           TYPE J_1BPARID,
       LV_NAME_TEXT       TYPE NAME1_GP,
       LV_DESC_ETAPA      TYPE STRING,
       LV_NAME_USER       TYPE STRING,
       LV_EMAIL           TYPE STRING.

  IF OTHERS IS INITIAL.
    IF LV_EMAIL IS INITIAL.
      CALL FUNCTION 'EFG_GEN_GET_USER_EMAIL'
        EXPORTING
          I_UNAME           = USUARIO
        IMPORTING
          E_EMAIL_ADDRESS   = LV_EMAIL
        EXCEPTIONS
          NOT_QUALIFIED     = 1
          USER_NOT_FOUND    = 2
          ADDRESS_NOT_FOUND = 3
          OTHERS            = 4.

      IF SY-SUBRC IS NOT INITIAL.
        EXIT.
      ENDIF.
    ENDIF.

*** Seleciona Mneumonico da Nota Fiscal
    SELECT SINGLE VALUE FROM ZHMS_TB_DOCMN INTO LV_NOTAX WHERE CHAVE EQ CHAVE
                                                           AND MNEUM EQ 'NCT'.

*** Completa numero de nota com zeros
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = LV_NOTAX
      IMPORTING
        OUTPUT = LV_NOTA.

*** Seleciona Fornecedor
    SELECT SINGLE PARID FROM ZHMS_TB_CABDOC INTO LV_PARID WHERE CHAVE EQ CHAVE.
*** Busca Nome texto fornecedor
    SELECT SINGLE NAME1 FROM LFA1 INTO LV_NAME_TEXT WHERE LIFNR EQ LV_PARID.
*** Busca Nome Usuario
    CALL FUNCTION 'CFX_API_USER_GETDETAIL'
      EXPORTING
        I_USER_ID  = USUARIO
      IMPORTING
        E_FULLNAME = LV_NAME_USER.

    MOVE LV_NAME_USER TO C2.

*** Busca Descrição etapa
    SELECT SINGLE DENOM FROM ZHMS_TX_SCEN_FLO INTO LV_DESC_ETAPA WHERE NATDC  EQ NATDC
                                                                   AND TYPED  EQ TYPED
                                                                   AND FLOWD  EQ ETAPA
                                                                   AND SPRAS  EQ SY-LANGU.

    FREE WA_IT_RECEIVERS.
    WA_IT_RECEIVERS-RECEIVER   = LV_EMAIL.
    WA_IT_RECEIVERS-REC_TYPE   = 'U'.
    WA_IT_RECEIVERS-COM_TYPE   = 'INT'.
    WA_IT_RECEIVERS-NOTIF_DEL  = 'X'.
    WA_IT_RECEIVERS-NOTIF_NDEL = 'X'.
    APPEND WA_IT_RECEIVERS TO IT_RECEIVERS .
    DESCRIBE TABLE IT_RECEIVERS LINES NUM_LINES.
    "&--- Check the Sender lv_email id or SAP User id is got or not.
    IF NUM_LINES IS NOT INITIAL.
*&---------------------------------------------------------------------
* Add thetext to mail text table
*&----------------------------------------------------------------------
*&-- Subject of the mail -------------&*
*      CONCATENATE 'Nota' LV_NOTA 'do fornecedor' LV_PARID '- HomSoft'
      CONCATENATE 'HomSoft - Erro no processamento Cte' '000111222'
      INTO PSUBJECT SEPARATED BY SPACE.
*&--  body  of the mail ----------------&*
      CLEAR WA_IT_MESSAGE.
      C1 = 'Caro usuário'.
*    c2 =
      CONCATENATE C1 C2 ',' INTO
      WA_IT_MESSAGE-LINE SEPARATED BY SPACE.
      APPEND WA_IT_MESSAGE TO IT_MESSAGE.
*** insert Blank Line *********************************************
      CLEAR WA_IT_MESSAGE.
      WA_IT_MESSAGE-LINE = '                               '.
      APPEND WA_IT_MESSAGE TO IT_MESSAGE.
******* Assign your Text  below ****************  *********************
      CLEAR WA_IT_MESSAGE.
      CONCATENATE 'Erro ao processar o CT-e:' '000111222'
      'Não foi encontrada no SAP documento de transporte para o Cte informado' INTO  WA_IT_MESSAGE-LINE SEPARATED BY SPACE.
      APPEND WA_IT_MESSAGE TO IT_MESSAGE.
*** insert Blank Line{} *********************************************
      CLEAR WA_IT_MESSAGE.
      WA_IT_MESSAGE-LINE = '                                        '.
      APPEND WA_IT_MESSAGE TO IT_MESSAGE.
******** Assign your Text  below *************************************
      CLEAR WA_IT_MESSAGE.
*      WA_IT_MESSAGE-LINE = 'Aguardando sua tomada de ação.'.
      WA_IT_MESSAGE-LINE   = 'Chave de acesso: 000000999999888887777766666555554444433332222'.
      APPEND WA_IT_MESSAGE TO IT_MESSAGE.
      GD_DOC_DATA-DOC_SIZE = 1.
*Populate the subject/generic message attributes
      GD_DOC_DATA-OBJ_LANGU  = SY-LANGU.
      GD_DOC_DATA-OBJ_NAME   = 'SAPRPT'.
      GD_DOC_DATA-OBJ_DESCR  = PSUBJECT.
      GD_DOC_DATA-SENSITIVTY = 'F'.
*Describe the body of the message
      CLEAR WA_IT_PACKING_LIST.
      REFRESH IT_PACKING_LIST.
      WA_IT_PACKING_LIST-TRANSF_BIN = SPACE.
      WA_IT_PACKING_LIST-HEAD_START = 1.
      WA_IT_PACKING_LIST-HEAD_NUM   = 0.
      WA_IT_PACKING_LIST-BODY_START = 1.
      DESCRIBE TABLE IT_MESSAGE LINES WA_IT_PACKING_LIST-BODY_NUM.
      WA_IT_PACKING_LIST-DOC_TYPE   = 'RAW'.
      APPEND WA_IT_PACKING_LIST TO IT_PACKING_LIST.

    ENDIF.

  ELSE.

    IF LV_EMAIL IS INITIAL.
      CALL FUNCTION 'EFG_GEN_GET_USER_EMAIL'
        EXPORTING
          I_UNAME         = USUARIO
        IMPORTING
          E_EMAIL_ADDRESS = LV_EMAIL.
    ENDIF.

    CALL FUNCTION 'CFX_API_USER_GETDETAIL'
      EXPORTING
        I_USER_ID  = USUARIO
      IMPORTING
        E_FULLNAME = LV_NAME_USER.

    FREE WA_IT_RECEIVERS.
    WA_IT_RECEIVERS-RECEIVER   = LV_EMAIL.
    WA_IT_RECEIVERS-REC_TYPE   = 'U'.
    WA_IT_RECEIVERS-COM_TYPE   = 'INT'.
    WA_IT_RECEIVERS-NOTIF_DEL  = 'X'.
    WA_IT_RECEIVERS-NOTIF_NDEL = 'X'.
    APPEND WA_IT_RECEIVERS TO IT_RECEIVERS .
    DESCRIBE TABLE IT_RECEIVERS LINES NUM_LINES.

    IF NUM_LINES IS NOT INITIAL.
      MOVE LV_NAME_USER TO C2.
      MOVE TITULO TO PSUBJECT.

      CLEAR WA_IT_MESSAGE.
      C1 = 'Caro usuário'.
      CONCATENATE C1 C2 ',' INTO
      WA_IT_MESSAGE-LINE SEPARATED BY SPACE.
      APPEND WA_IT_MESSAGE TO IT_MESSAGE.

*** insert Blank Line *********************************************
      CLEAR WA_IT_MESSAGE.
      WA_IT_MESSAGE-LINE = '                               '.
      APPEND WA_IT_MESSAGE TO IT_MESSAGE.

      CLEAR WA_IT_MESSAGE.
      WA_IT_MESSAGE-LINE = CORPO.
      APPEND WA_IT_MESSAGE TO IT_MESSAGE.

*Populate the subject/generic message attributes
      GD_DOC_DATA-OBJ_LANGU  = SY-LANGU.
      GD_DOC_DATA-OBJ_NAME   = 'SAPRPT'.
      GD_DOC_DATA-OBJ_DESCR  = PSUBJECT.
      GD_DOC_DATA-SENSITIVTY = 'F'.
*Describe the body of the message
      CLEAR WA_IT_PACKING_LIST.
      REFRESH IT_PACKING_LIST.
      WA_IT_PACKING_LIST-TRANSF_BIN = SPACE.
      WA_IT_PACKING_LIST-HEAD_START = 1.
      WA_IT_PACKING_LIST-HEAD_NUM   = 0.
      WA_IT_PACKING_LIST-BODY_START = 1.
      DESCRIBE TABLE IT_MESSAGE LINES WA_IT_PACKING_LIST-BODY_NUM.
      WA_IT_PACKING_LIST-DOC_TYPE = 'RAW'.
      APPEND WA_IT_PACKING_LIST TO IT_PACKING_LIST.
    ENDIF.
  ENDIF.

*&------ Call the Function Module to send the message to External and SAP Inbox
  CALL FUNCTION 'SO_NEW_DOCUMENT_ATT_SEND_API1'
    EXPORTING
      DOCUMENT_DATA              = GD_DOC_DATA
      PUT_IN_OUTBOX              = 'X'
      COMMIT_WORK                = 'X'
    TABLES
      PACKING_LIST               = IT_PACKING_LIST
      CONTENTS_TXT               = IT_MESSAGE
      RECEIVERS                  = IT_RECEIVERS
    EXCEPTIONS
      TOO_MANY_RECEIVERS         = 1
      DOCUMENT_NOT_SENT          = 2
      DOCUMENT_TYPE_NOT_EXIST    = 3
      OPERATION_NO_AUTHORIZATION = 4
      PARAMETER_ERROR            = 5
      X_ERROR                    = 6
      ENQUEUE_ERROR              = 7
      OTHERS                     = 8.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFUNCTION.
