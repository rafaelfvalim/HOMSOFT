REPORT ZHMS_GATE.

TABLES: J_1BNFDOC, J_1BNFLIN.

TYPES: BEGIN OF TY_SAIDA,
          CHECKBOX    TYPE C,
          NFENUM      TYPE J_1BNFDOC-NFENUM,
          DOCNUM      TYPE J_1BNFDOC-DOCNUM,
          NAME1       TYPE KNA1-NAME1,
          PARID       TYPE J_1BNFDOC-PARID,
          BUKRS       TYPE J_1BNFDOC-BUKRS,
          BRANCH      TYPE J_1BNFDOC-BRANCH,
          VSTEL       TYPE J_1BNFDOC-VSTEL,
          DOCDAT      TYPE J_1BNFDOC-DOCDAT,
          PSTDAT      TYPE J_1BNFDOC-PSTDAT,
          BRGEW       TYPE J_1BNFDOC-BRGEW,
          NTGEW       TYPE J_1BNFDOC-NTGEW,
          NFTOT       TYPE J_1BNFDOC-NFTOT,
          WAERK       TYPE J_1BNFDOC-WAERK,
          ANZPK       TYPE J_1BNFDOC-ANZPK,
          CELLTAB     TYPE LVC_T_STYL,
        END OF TY_SAIDA,

        BEGIN OF TY_VEICULO,
        PLACA_TOCO   TYPE	ZHOM_PL_TOCO,
        PLACA_CAR1   TYPE	ZHOM_PL_CAR1,
        PLACA_CAR2   TYPE	ZHOM_PL_CAR2,
        PLACA_CAR3   TYPE	ZHOM_PL_CAR3,
        TIPO_VEICULO TYPE	ZHOM_TP_VEIC,
        END OF TY_VEICULO,

        BEGIN OF TY_KNA1,
          KUNNR TYPE KNA1-KUNNR,
          NAME1 TYPE KNA1-NAME1,
        END OF TY_KNA1.

DATA: T_DOC TYPE TABLE OF J_1BNFDOC,
      T_LIN TYPE TABLE OF J_1BNFLIN,
      T_SAIDA TYPE TABLE OF TY_SAIDA,
      T_DOCMN TYPE TABLE OF  ZHMS_TB_DOCMN,
      T_LFA1 TYPE TABLE OF LFA1,
      W_DOC TYPE J_1BNFDOC,
      W_LIN TYPE J_1BNFLIN,
      W_SAIDA TYPE TY_SAIDA,
      T_KNA1 TYPE TABLE OF TY_KNA1,
      W_KNA1 TYPE TY_KNA1,
      T_CARGA TYPE TABLE OF ZHMS_GATE_PORTA,
      W_CARGA TYPE ZHMS_GATE_PORTA,
      T_CARGA_ITEM TYPE TABLE OF ZHMS_GATE_ITEM,
      W_CARGA_ITEM TYPE ZHMS_GATE_ITEM,
      WA_DOCMN TYPE ZHMS_TB_DOCMN,
      WA_LFA1 TYPE LFA1,
      wa_cabdoc type zhms_tb_cabdoc,
      wa_docconf TYPE zhms_tb_docconf.

CLASS LCL_EVENT_RECEIVER DEFINITION DEFERRED.  "for event handling

DATA: G_CONTAINER TYPE SCRFNAME VALUE 'CC_9000',
      G_GRID  TYPE REF TO CL_GUI_ALV_GRID,
      G_CUSTOM_CONTAINER TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      G_EVENT_RECEIVER TYPE REF TO LCL_EVENT_RECEIVER,
      GS_LAYOUT TYPE LVC_S_LAYO,
      GT_FIELDCAT TYPE LVC_T_FCAT.

DATA: VG_BUKRS       TYPE C LENGTH 10,
      VG_BUTXT       TYPE T001-BUTXT,
      VG_WERKS       TYPE T001W-WERKS VALUE 'HOMI',
      VG_NM_WERKS    TYPE T001W-NAME1,
      VG_DT_EMISS_D  TYPE SY-DATUM,
      VG_DT_EMISS_A  TYPE SY-DATUM,
      VG_DT_RECB_D   TYPE SY-DATUM,
      VG_DT_RECB_A   TYPE SY-DATUM,
      VG_CNPJ_EMISS  TYPE LFA1-STCD1,
      VG_STATUS(30)  TYPE C,
      VG_NFNUM       TYPE ZHOM_NFE_REC-NFENUM,
      VG_SERIE       TYPE J_1BNFDOC-SERIES,
      VG_CHAVE(44)   TYPE C,
      VG_EMPRESA     TYPE ZHOM_NFE_REC-EMPRESA,
      VG_FILIAL      TYPE ZHOM_NFE_REC-FILIAL,
      VG_CENTRO      TYPE ZHOM_NFE_REC-WERKS,
      VG_CTE(1)      TYPE C,
      VG_NFE(1)      TYPE C,
      VG_UCOMM       TYPE SY-UCOMM,
      VG_CONSULTA    TYPE C,
      VG_COD_TRANSP  TYPE ZHOM_TRANSPORTE-COD_TRANSP,
      VG_RG_MOTORST  TYPE ZHOM_TRANSPORTE-ID_MOTORISTA,
      VG_NM_MOTOR    TYPE ZHOM_TRANSPORTE-NAME1,
      VG_RG_AJUDANT  TYPE ZHOM_TRANSPORTE-RG_AJUDANTE,
      VG_NM_AJUD     TYPE ZHOM_TRANSPORTE-NAME2,
      VG_CNH         TYPE ZHOM_TRANSPORTE-NR_CNH,
      VG_VALID_CNH   TYPE ZHOM_TRANSPORTE-VALID_CNH,
      VG_CATEG_CNH   TYPE ZHOM_TRANSPORTE-CATEG_CNH,
      VG_STATUS_CNH(35) TYPE C,
      VG_ICONE_CNH(4) TYPE C,
      VG_TOCO        TYPE ZHOM_VEICULO-PLACA_TOCO,
      VG_PLACA1      TYPE ZHOM_VEICULO-PLACA_CAR1,
      VG_PLACA2      TYPE ZHOM_VEICULO-PLACA_CAR2,
      VG_PLACA3      TYPE ZHOM_VEICULO-PLACA_CAR3,
      VG_TP_VEIC     TYPE ZHOM_VEICULO-TIPO_VEICULO,
      VG_COD_RENAVAM TYPE ZHOM_VEICULO-COD_RENAVAM,
      VG_EXERCICIO   TYPE ZHOM_VEICULO-ANO_EXERCICIO,
      VG_VALIDADE    TYPE ZHOM_VEICULO-VALIDADE,
      VG_ESPECIE     TYPE ZHOM_VEICULO-ESPECIE,
      VG_TIPO        TYPE ZHOM_VEICULO-TIPO,
      VG_COR         TYPE ZHOM_VEICULO-COR,
      VG_CHASSI      TYPE ZHOM_VEICULO-CHASSI,
      VG_NR_DPVAT    TYPE ZHOM_VEICULO-NR_DPVAT,
      VG_VALID_DPVAT TYPE ZHOM_VEICULO-VALID_DPVAT,
      VG_TARA_TOTAL  TYPE ZHOM_VEICULO-TARA_TOTAL,
      VG_FAROL_NF(10) TYPE C,
      VG_ENTRADA      TYPE C,
      VG_SAIDA        TYPE C,
      VG_TRUCADO      TYPE C VALUE 'X',
      VG_CARRETA      TYPE C,
      VG_TREM         TYPE C,
      VG_TRITREM      TYPE C,
      VG_BITREM       TYPE C,
      VG_VAGAO        TYPE C,
      VG_NAVIO        TYPE C,
      VG_OUTROS       TYPE C,
      VG_PESO_IN      TYPE ZHOM_PESOS-PES_BRU_IN,
      VG_PESO_OUT     TYPE ZHOM_PESOS-PES_BRU_OUT,
      VG_VOLUME       TYPE ZHOM_PESOS-NR_VOLUME,
      VG_RESP         TYPE C,
      VG_MTART        TYPE MARA-MTART,
      VG_MATNR        TYPE MARA-MATNR,
      VG_MESS(3)      TYPE C,
      VG_OK           TYPE C,
      VG_INT          TYPE C,
      VG_FIRST(20)    TYPE C,
      VG_PESO_BRUTO_SAIDA TYPE J_1BNFDOC-BRGEW,
      VG_PESO_SAIDA   TYPE J_1BNFDOC-BRGEW,
      VG_PESO_DIF     TYPE J_1BNFDOC-BRGEW,
      VG_PERC         TYPE P DECIMALS 2,
      VG_NUM_CARGA    TYPE C LENGTH 10,
      VG_ICON         TYPE C LENGTH 4,
      VG_DIF_CB       TYPE P DECIMALS 2,
      VG_PESO_ENTRADA TYPE P DECIMALS 2,
      LV_CHAVE        type c LENGTH 44,
      VG_NNF          TYPE C LENGTH 9,
      VG_DHEMI        TYPE C LENGTH 100,
      VG_HORA         type C length 8,
      VL_DATA         TYPE SCAL-DATE,
      VG_NM_BRANCH    type c length 300,
      vg_conf_status  TYPE icon_d.

* Início - Patrícia - 19/10/16
DATA:  W_TRANSPORTE  TYPE ZHOM_TRANSPORTE,
       T_BDCDATA TYPE TABLE OF BDCDATA,
         W_VEICULO     TYPE ZHOM_VEICULO.

DATA: DOCKING TYPE REF TO CL_GUI_DOCKING_CONTAINER,
      PICTURE_CONTROL_1 TYPE REF TO CL_GUI_PICTURE,
      URL(256) TYPE C .

DATA: QUERY_TABLE LIKE W3QUERY OCCURS 1 WITH HEADER LINE,
      HTML_TABLE LIKE W3HTML OCCURS 1,
      RETURN_CODE LIKE  W3PARAM-RET_CODE,
      CONTENT_TYPE LIKE  W3PARAM-CONT_TYPE,
      CONTENT_LENGTH LIKE  W3PARAM-CONT_LEN,
      PIC_DATA LIKE W3MIME OCCURS 0,
      PIC_SIZE TYPE I.

DATA: WA_WHERE TYPE RSDS_TWHERE,
      WA_EXPR  TYPE RSDS_TEXPR,
      GV_SELID TYPE RSDYNSEL-SELID,
      GV_TITLE TYPE SY-TITLE,
      GV_ACTNUM TYPE SY-TFILL,
      IT_FIELDS TYPE TABLE OF RSDSFIELDS.

DATA: T_TEXPR TYPE RSDS_TEXPR,
      T_TABS TYPE TABLE OF RSDSTABS,
      WA_TABS TYPE RSDSTABS,
      T_FLDS TYPE TABLE OF RSDSFIELDS,
      WA_FLDS TYPE RSDSFIELDS.
* Início - Patrícia - 19/10/16

DATA: T_ZHOM_VEICULO TYPE TABLE OF TY_VEICULO,
      T_RET_TAB      TYPE TABLE OF DDSHRETVAL,
      WA_RET_TAB TYPE DDSHRETVAL.

*----------------------------------------------------------------------*
*       CLASS lcl_event_receiver DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS LCL_EVENT_RECEIVER DEFINITION.

  PUBLIC SECTION.
    METHODS: CATCH_DOUBLECLICK
             FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
             IMPORTING
                E_COLUMN
                ES_ROW_NO
                SENDER.
ENDCLASS.                    "lcl_event_receiver DEFINITION

*-----

CLASS LCL_EVENT_RECEIVER IMPLEMENTATION.

  METHOD CATCH_DOUBLECLICK.
    DATA: W_SAIDA TYPE TY_SAIDA,
          LS_CELLTAB TYPE LVC_S_STYL.
*--
* Function:
*  Switch between 'editable' and 'not editable' checkbox.
*--

* If the user clicked on another column there is
* nothing to do.
    IF E_COLUMN-FIELDNAME NE 'CHECKBOX'.
      EXIT.
    ENDIF.

    READ TABLE T_SAIDA INTO W_SAIDA INDEX ES_ROW_NO-ROW_ID.

* The loop is only needed if there are other columns that
* use checkboxes. At this point the loop could be
* replaced by a READ of the first line of CELLTAB.
    LOOP AT W_SAIDA-CELLTAB INTO LS_CELLTAB.
      IF LS_CELLTAB-FIELDNAME EQ 'CHECKBOX'.
* §B4.Switch the style to dis- or enable a cell for input
        IF LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
        ELSE.
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
        ENDIF.
        MODIFY W_SAIDA-CELLTAB FROM LS_CELLTAB.
      ENDIF.
    ENDLOOP.
    MODIFY T_SAIDA FROM W_SAIDA INDEX ES_ROW_NO-ROW_ID.

    CALL METHOD SENDER->REFRESH_TABLE_DISPLAY.
  ENDMETHOD.                    "catch_doubleclick
ENDCLASS.                    "lcl_event_receiver IMPLEMENTATION

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: S_BUKRS FOR J_1BNFDOC-BUKRS,
                S_BRANCH FOR J_1BNFDOC-BRANCH,
                S_DOCNUM FOR J_1BNFDOC-DOCNUM,
                S_PARID  FOR J_1BNFDOC-PARID,
                S_DOCDAT FOR J_1BNFDOC-DOCDAT.
SELECTION-SCREEN END OF BLOCK B1.
* Patricia

AT SELECTION-SCREEN OUTPUT.
  PERFORM F_LOGO.
* Patricia

START-OF-SELECTION.

  IF NOT PICTURE_CONTROL_1 IS INITIAL.

    CALL METHOD PICTURE_CONTROL_1->FREE
      EXCEPTIONS
        CNTL_ERROR        = 1
        CNTL_SYSTEM_ERROR = 2
        OTHERS            = 3.

    IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDIF.

  SELECT *
    FROM J_1BNFDOC
    INTO TABLE T_DOC
    WHERE BUKRS IN S_BUKRS
      AND BRANCH IN S_BRANCH
      AND DOCNUM IN S_DOCNUM
      AND PARID IN S_PARID
      AND DOCDAT IN S_DOCDAT.
  IF SY-SUBRC EQ 0.
    SELECT *
      FROM J_1BNFLIN
      INTO TABLE T_LIN
      FOR ALL ENTRIES IN T_DOC
      WHERE DOCNUM EQ T_DOC-DOCNUM.

    SELECT KUNNR NAME1
      FROM KNA1
      INTO TABLE T_KNA1
      FOR ALL ENTRIES IN T_DOC
      WHERE KUNNR = T_DOC-PARID.

    SELECT *
      FROM ZHMS_GATE_ITEM
      INTO TABLE T_CARGA_ITEM
      FOR ALL ENTRIES IN T_DOC
      WHERE DOCNUM = T_DOC-DOCNUM.
  ENDIF.


  IF T_DOC IS NOT INITIAL.
    CALL SCREEN 9000.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Module  STATUS_9000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_9000 OUTPUT.
  SET PF-STATUS 'MAIN100'.
  SET TITLEBAR 'MAIN100'.
  IF G_CUSTOM_CONTAINER IS INITIAL.
    PERFORM CREATE_AND_INIT_ALV.
  ELSE.
    CALL METHOD G_GRID->REFRESH_TABLE_DISPLAY.
  ENDIF.

ENDMODULE.                 " STATUS_9000  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  CREATE_AND_INIT_ALV
*&---------------------------------------------------------------------*
FORM CREATE_AND_INIT_ALV .
  DATA: LT_EXCLUDE TYPE UI_FUNCTIONS.

  CREATE OBJECT G_CUSTOM_CONTAINER
    EXPORTING
      CONTAINER_NAME = G_CONTAINER.
  CREATE OBJECT G_GRID
    EXPORTING
      I_PARENT = G_CUSTOM_CONTAINER.

  PERFORM BUILD_FIELDCAT CHANGING GT_FIELDCAT.

* Exclude all edit functions in this example since we do not need them:
  PERFORM EXCLUDE_TB_FUNCTIONS CHANGING LT_EXCLUDE.

  PERFORM BUILD_DATA.

*§ B3.Use the layout structure to aquaint additional field to ALV.

  GS_LAYOUT-STYLEFNAME = 'CELLTAB'.
  GS_LAYOUT-CWIDTH_OPT = 'X'.
  GS_LAYOUT-ZEBRA = 'X'.

  CALL METHOD G_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT
      IT_TOOLBAR_EXCLUDING = LT_EXCLUDE
    CHANGING
      IT_FIELDCATALOG      = GT_FIELDCAT
      IT_OUTTAB            = T_SAIDA.

  CREATE OBJECT G_EVENT_RECEIVER.
  SET HANDLER G_EVENT_RECEIVER->CATCH_DOUBLECLICK FOR G_GRID.

* Set editable cells to ready for input initially
  CALL METHOD G_GRID->SET_READY_FOR_INPUT
    EXPORTING
      I_READY_FOR_INPUT = 1.
ENDFORM.                    " CREATE_AND_INIT_ALV

*&---------------------------------------------------------------------*
*&      Form  EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_EXCLUDE  text
*----------------------------------------------------------------------*
FORM EXCLUDE_TB_FUNCTIONS CHANGING PT_EXCLUDE TYPE UI_FUNCTIONS.

  DATA LS_EXCLUDE TYPE UI_FUNC.

  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_CUT.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.


ENDFORM.                               " EXCLUDE_TB_FUNCTIONS

*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCAT
*&---------------------------------------------------------------------*
FORM BUILD_FIELDCAT  CHANGING PT_FIELDCAT TYPE LVC_T_FCAT.

  DATA LS_FCAT TYPE LVC_S_FCAT.

  CLEAR LS_FCAT.
*  ls_fcat-tabname     = 'T_SAIDA'.
  LS_FCAT-FIELDNAME = 'CHECKBOX'.
  LS_FCAT-CHECKBOX = 'X'.
  LS_FCAT-COLTEXT = 'Check'.
  LS_FCAT-TOOLTIP = 'Check'.
  LS_FCAT-SELTEXT = 'Check'.
  LS_FCAT-EDIT = 'X'.
  APPEND LS_FCAT TO PT_FIELDCAT.

  CLEAR LS_FCAT.
  LS_FCAT-TABNAME     = 'T_SAIDA'.
  LS_FCAT-FIELDNAME   = 'NFENUM'.
  LS_FCAT-COLTEXT = 'NFeNum'.
  LS_FCAT-TOOLTIP = 'NFeNum'.
  LS_FCAT-SELTEXT = 'NFeNum'.
*  ls_fcat-outputlen   = 15.
  APPEND LS_FCAT TO PT_FIELDCAT.

  CLEAR LS_FCAT.
  LS_FCAT-TABNAME     = 'T_SAIDA'.
  LS_FCAT-FIELDNAME   = 'DOCNUM'.
  LS_FCAT-COLTEXT = 'Num. Doc.'.
  LS_FCAT-TOOLTIP = 'Num. Doc.'.
  LS_FCAT-SELTEXT = 'Num. Doc.'.
*  ls_fcat-outputlen   = 15.
  APPEND LS_FCAT TO PT_FIELDCAT.

  CLEAR LS_FCAT.
  LS_FCAT-TABNAME     = 'T_SAIDA'.
  LS_FCAT-FIELDNAME   = 'NAME1'.
  LS_FCAT-COLTEXT = 'Nome Parceiro'.
  LS_FCAT-TOOLTIP = 'Nome Parceiro'.
  LS_FCAT-SELTEXT = 'Nome Parceiro'.
  LS_FCAT-REF_TABLE = 'KNA1'.
  LS_FCAT-REF_FIELD = 'NAME1'.
  LS_FCAT-LOWERCASE = 'X'.
*  ls_fcat-outputlen   = 15.
  APPEND LS_FCAT TO PT_FIELDCAT.

  CLEAR LS_FCAT.
  LS_FCAT-TABNAME     = 'T_SAIDA'.
  LS_FCAT-FIELDNAME   = 'PARID'.
  LS_FCAT-COLTEXT = 'ID Parc.'.
  LS_FCAT-TOOLTIP = 'ID Parc.'.
  LS_FCAT-SELTEXT = 'ID Parc.'.
*  ls_fcat-outputlen   = 15.
  APPEND LS_FCAT TO PT_FIELDCAT.

  CLEAR LS_FCAT.
  LS_FCAT-TABNAME     = 'T_SAIDA'.
  LS_FCAT-FIELDNAME   = 'BUKRS'.
  LS_FCAT-COLTEXT = 'Empresa'.
  LS_FCAT-TOOLTIP = 'Empresa'.
  LS_FCAT-SELTEXT = 'Empresa'.
*  ls_fcat-outputlen   = 15.
  APPEND LS_FCAT TO PT_FIELDCAT.

  CLEAR LS_FCAT.
  LS_FCAT-TABNAME     = 'T_SAIDA'.
  LS_FCAT-FIELDNAME   = 'BRANCH'.
  LS_FCAT-COLTEXT = 'Local Neg.'.
  LS_FCAT-TOOLTIP = 'Local Neg.'.
  LS_FCAT-SELTEXT = 'Local Neg.'.
*  ls_fcat-outputlen   = 15.
  APPEND LS_FCAT TO PT_FIELDCAT.

  CLEAR LS_FCAT.
  LS_FCAT-TABNAME     = 'T_SAIDA'.
  LS_FCAT-FIELDNAME   = 'VSTEL'.
  LS_FCAT-COLTEXT = 'Local Exp.'.
  LS_FCAT-TOOLTIP = 'Local Exp.'.
  LS_FCAT-SELTEXT = 'Local Exp.'.
*  ls_fcat-outputlen   = 15.
  APPEND LS_FCAT TO PT_FIELDCAT.

  CLEAR LS_FCAT.
  LS_FCAT-TABNAME     = 'T_SAIDA'.
  LS_FCAT-FIELDNAME   = 'DOCDAT'.
  LS_FCAT-COLTEXT = 'Dt. Process.'.
  LS_FCAT-TOOLTIP = 'Dt. Process.'.
  LS_FCAT-SELTEXT = 'Dt. Process.'.
*  ls_fcat-outputlen   = 15.
  APPEND LS_FCAT TO PT_FIELDCAT.

  CLEAR LS_FCAT.
  LS_FCAT-TABNAME     = 'T_SAIDA'.
  LS_FCAT-FIELDNAME   = 'PSTDAT'.
  LS_FCAT-COLTEXT = 'Dt Criação'.
  LS_FCAT-TOOLTIP = 'Dt Criação'.
  LS_FCAT-SELTEXT = 'Dt Criação'.
*  ls_fcat-outputlen   = 15.
  APPEND LS_FCAT TO PT_FIELDCAT.

  CLEAR LS_FCAT.
  LS_FCAT-TABNAME     = 'T_SAIDA'.
  LS_FCAT-FIELDNAME   = 'BRGEW'.
  LS_FCAT-COLTEXT = 'Peso Bruto'.
  LS_FCAT-TOOLTIP = 'Peso Bruto'.
  LS_FCAT-SELTEXT = 'Peso Bruto'.
*  ls_fcat-outputlen   = 15.
  APPEND LS_FCAT TO PT_FIELDCAT.

  CLEAR LS_FCAT.
  LS_FCAT-TABNAME     = 'T_SAIDA'.
  LS_FCAT-FIELDNAME   = 'NTGEW'.
  LS_FCAT-COLTEXT = 'Peso Líquido'.
  LS_FCAT-TOOLTIP = 'Peso Líquido'.
  LS_FCAT-SELTEXT = 'Peso Líquido'.
*  ls_fcat-outputlen   = 15.
  APPEND LS_FCAT TO PT_FIELDCAT.

  CLEAR LS_FCAT.
  LS_FCAT-TABNAME     = 'T_SAIDA'.
  LS_FCAT-FIELDNAME   = 'NFTOT'.
  LS_FCAT-COLTEXT = 'Total NF'.
  LS_FCAT-TOOLTIP = 'Total NF'.
  LS_FCAT-SELTEXT = 'Total NF'.
*  ls_fcat-outputlen   = 15.
  APPEND LS_FCAT TO PT_FIELDCAT.

  CLEAR LS_FCAT.
  LS_FCAT-TABNAME     = 'T_SAIDA'.
  LS_FCAT-FIELDNAME   = 'WAERK'.
  LS_FCAT-COLTEXT = 'Moeda'.
  LS_FCAT-TOOLTIP = 'Moeda'.
  LS_FCAT-SELTEXT = 'Moeda'.
*  ls_fcat-outputlen   = 15.
  APPEND LS_FCAT TO PT_FIELDCAT.

  CLEAR LS_FCAT.
  LS_FCAT-TABNAME     = 'T_SAIDA'.
  LS_FCAT-FIELDNAME   = 'ANZPK'.
  LS_FCAT-COLTEXT = 'Volume'.
  LS_FCAT-TOOLTIP = 'Volume'.
  LS_FCAT-SELTEXT = 'Volume'.
*  ls_fcat-outputlen   = 15.
  APPEND LS_FCAT TO PT_FIELDCAT.


ENDFORM.                    " BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_9000 INPUT.
  CASE SY-UCOMM.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'CARGA'.
      PERFORM ZF_CARGA.
* Patrícia
    WHEN 'REL_CARGA'.
      CALL TRANSACTION 'ZHMS_CARGA_REL'.
* Patrícia
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_9000  INPUT

*&---------------------------------------------------------------------*
*&      Form  BUILD_DATA
*&---------------------------------------------------------------------*
FORM BUILD_DATA .
  DATA: VL_TABIX TYPE SY-TABIX.

  LOOP AT T_DOC INTO W_DOC.
    VL_TABIX = SY-TABIX.
    READ TABLE T_CARGA_ITEM INTO W_CARGA_ITEM WITH KEY DOCNUM = W_DOC-DOCNUM.
    IF SY-SUBRC EQ 0.
      DELETE T_DOC INDEX VL_TABIX.
      CONTINUE.
    ENDIF.

    MOVE-CORRESPONDING: W_DOC TO W_SAIDA.

    READ TABLE T_KNA1 INTO W_KNA1 WITH KEY KUNNR = W_DOC-PARID.
    IF SY-SUBRC EQ 0.
      W_SAIDA-NAME1 = W_KNA1-NAME1.
    ENDIF.
    APPEND W_SAIDA TO T_SAIDA.
    CLEAR W_SAIDA.
  ENDLOOP.
ENDFORM.                    " BUILD_DATA

*&---------------------------------------------------------------------*
*&      Form  ZF_CARGA
*&---------------------------------------------------------------------*
FORM ZF_CARGA .
  DATA: L_VALID TYPE C.

  CLEAR L_VALID.
  CLEAR VG_PESO_BRUTO_SAIDA.

  CALL METHOD G_GRID->CHECK_CHANGED_DATA
    IMPORTING
      E_VALID = L_VALID.

  IF L_VALID EQ 'X'.
    LOOP AT T_SAIDA INTO W_SAIDA.
      IF W_SAIDA-CHECKBOX EQ 'X'.
        ADD W_SAIDA-BRGEW TO VG_PESO_BRUTO_SAIDA.
      ENDIF.
    ENDLOOP.
*Renan Itokazo
    CALL SCREEN 9003.
  ENDIF.
ENDFORM.                    " ZF_CARGA

*&---------------------------------------------------------------------*
*&      Module  STATUS_1000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_1000 OUTPUT.
  SET PF-STATUS 'MAIN9002'.
  SET TITLEBAR 'MAIN100'.

ENDMODULE.                 " STATUS_1000  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_1000 INPUT.
  CASE SY-UCOMM.
    WHEN 'EXIT'.
      CALL SCREEN 9000.
    WHEN 'FIMCARGA'.
      PERFORM ZF_CARGA_FINAL.
    WHEN 'CAD_TRANSP'.
      CALL TRANSACTION 'ZHMTRANSP'.
    WHEN 'CAD_VEIC'.
      CALL TRANSACTION 'ZHMVEIC'.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_1000  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECA_EMPRESA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECA_EMPRESA INPUT.
*  CHECK sy-ucomm NE 'EXIT' AND
*        sy-ucomm NE 'CANCEL' AND
*        sy-ucomm NE 'GOBACK'.

  IF VG_BUKRS NE SPACE.
    CLEAR VG_BUTXT.
    SELECT SINGLE BUTXT INTO VG_BUTXT
     FROM T001
      WHERE BUKRS EQ VG_BUKRS.

    IF SY-SUBRC NE 0.
      SET CURSOR FIELD 'VG_BUKRS'.
      MESSAGE S002(SY) WITH TEXT-M05.
      LEAVE TO SCREEN 9000.
    ENDIF.

  ELSE.
    MESSAGE S010(ZRECEB).
    LEAVE TO SCREEN 9000.
  ENDIF.
ENDMODULE.                 " CHECA_EMPRESA  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECA_CENTRO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECA_CENTRO INPUT.

  IF VG_WERKS NE SPACE.

    CLEAR VG_NM_WERKS.
    SELECT SINGLE NAME1 INTO VG_NM_WERKS
     FROM T001W
       WHERE WERKS EQ VG_WERKS.

    IF SY-SUBRC NE 0.
      MESSAGE S008(ZRECEB).
*      LEAVE TO SCREEN 9000.
    ENDIF.

  ENDIF.
ENDMODULE.                 " CHECA_CENTRO  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECA_PLACAS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECA_PLACAS INPUT.




*  IF vg_trucado = 'X'.
*    vg_peso_in = 10000.
*    vg_peso_out = 14000.
*
*
*
*  ELSEIF vg_carreta = 'X'.
*    vg_peso_in = 16000.
*    vg_peso_out = 20000.
*
*
*  ELSEIF vg_trem = 'X'.
*    vg_peso_in = 20000.
*    vg_peso_out = 35000.
*
*    SELECT placa_toco  placa_car1 placa_car2
*           placa_car3 tipo_veiculo FROM zhom_veiculo
*    INTO TABLE t_zhom_veiculo
*    WHERE tipo_veiculo EQ '01' OR
*          tipo_veiculo EQ '02' OR
*          tipo_veiculo EQ '03'.
*
*  ELSEIF vg_bitrem = 'X'.
*    vg_peso_in = 25000.
*    vg_peso_out = 40000.
*  ELSE.
*    vg_peso_in = 0.
*    vg_peso_out = 0.
*  ENDIF.
*  IF vg_peso_out IS NOT INITIAL.
*    IF vg_peso_bruto_saida > vg_peso_out.
*      MESSAGE text-004 TYPE 'S' DISPLAY LIKE 'E'.
*    ENDIF.
*  ENDIF.
*



**  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
**    EXPORTING
**      retfield        = 'STATUS'
**      value_org       = 'S'
**    TABLES
**      value_tab       = itab_combo
**    EXCEPTIONS
**      parameter_error = 1
**      no_values_found = 2
**      OTHERS          = 3.
**  IF sy-subrc <> 0.
**    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
**            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
**  ENDIF.


ENDMODULE.                 " CHECA_PLACAS  INPUT

*&---------------------------------------------------------------------*
*&      Form  ZF_CARGA_FINAL
*&---------------------------------------------------------------------*
FORM ZF_CARGA_FINAL .
  DATA: VG_FINAL TYPE P DECIMALS 2,
        VG_RESP TYPE C.

  IF VG_PESO_DIF > VG_DIF_CB.
    MESSAGE TEXT-002 TYPE 'S' DISPLAY LIKE 'E'.

    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TITLEBAR       = 'Status Carga'
        TEXT_QUESTION  = 'Deseja liberar Carga?'
        TEXT_BUTTON_1  = 'Sim'
        TEXT_BUTTON_2  = 'Não'
      IMPORTING
        ANSWER         = VG_RESP
      EXCEPTIONS
        TEXT_NOT_FOUND = 1
        OTHERS         = 2.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

    IF VG_RESP EQ '1'.
      "suuuuuuuuuuuuuuuuuuuuuuccessssososososo
      W_CARGA-NCARGA = VG_NUM_CARGA.
      W_CARGA-BUKRS = VG_BUKRS.
      W_CARGA-WERKS = VG_WERKS.
      IF VG_TRUCADO = 'X'.
        W_CARGA-TIPOVEIC = 'Trucado'.
      ELSEIF VG_CARRETA = 'X'.
        W_CARGA-TIPOVEIC = 'Carreta'.
      ELSEIF VG_TREM = 'X'.
        W_CARGA-TIPOVEIC = 'Trem'.
      ELSEIF VG_BITREM = 'X'.
        W_CARGA-TIPOVEIC = 'BiTrem'.
      ELSE.
        W_CARGA-TIPOVEIC = 'Outros'.
      ENDIF.
      W_CARGA-USERAPROV = SY-UNAME.
      W_CARGA-DATA = SY-DATUM.
      W_CARGA-PESOTARA = VG_PESO_IN.
      W_CARGA-PESOMAXIMO = VG_PESO_OUT.
      W_CARGA-PESOENTRADA = VG_PESO_ENTRADA.
      W_CARGA-PESOCARGA = VG_PESO_BRUTO_SAIDA.
      W_CARGA-PESOBALANCA = VG_PESO_SAIDA.
      W_CARGA-DIFPORTARIA = VG_PESO_DIF.
      W_CARGA-PERCTOL = VG_PERC.
      W_CARGA-DIFPERC = VG_DIF_CB.
      MODIFY ZHMS_GATE_PORTA FROM W_CARGA.
      CLEAR W_CARGA.

      LOOP AT T_SAIDA INTO W_SAIDA.
        IF W_SAIDA-CHECKBOX = 'X'.
          DELETE T_SAIDA.
          W_CARGA_ITEM-NCARGA = VG_NUM_CARGA.
          W_CARGA_ITEM-DOCNUM = W_SAIDA-DOCNUM.
          MODIFY ZHMS_GATE_ITEM FROM W_CARGA_ITEM.
          CLEAR W_CARGA_ITEM.
        ENDIF.
      ENDLOOP.
      COMMIT WORK.

      MESSAGE TEXT-003 TYPE 'S' DISPLAY LIKE 'S'.

      PERFORM ZF_CLEAR.
      CALL SCREEN 9000.
    ELSE.
      SET CURSOR FIELD 'VG_PESO_SAIDA'.
      EXIT.
    ENDIF.
  ELSE.
    "suuuuuuuuuuuuuuuuuuuuuuccessssososososo
    W_CARGA-NCARGA = VG_NUM_CARGA.
    W_CARGA-BUKRS = VG_BUKRS.
    W_CARGA-WERKS = VG_WERKS.
    IF VG_TRUCADO = 'X'.
      W_CARGA-TIPOVEIC = 'Trucado'.
    ELSEIF VG_CARRETA = 'X'.
      W_CARGA-TIPOVEIC = 'Carreta'.
    ELSEIF VG_TREM = 'X'.
      W_CARGA-TIPOVEIC = 'Trem'.
    ELSEIF VG_BITREM = 'X'.
      W_CARGA-TIPOVEIC = 'BiTrem'.
    ELSE.
      W_CARGA-TIPOVEIC = 'Outros'.
    ENDIF.
    W_CARGA-DATA = SY-DATUM.
    W_CARGA-PESOTARA = VG_PESO_IN.
    W_CARGA-PESOMAXIMO = VG_PESO_OUT.
    W_CARGA-PESOENTRADA = VG_PESO_ENTRADA.
    W_CARGA-PESOCARGA = VG_PESO_BRUTO_SAIDA.
    W_CARGA-PESOBALANCA = VG_PESO_SAIDA.
    W_CARGA-DIFPORTARIA = VG_PESO_DIF.
    W_CARGA-PERCTOL = VG_PERC.
    W_CARGA-DIFPERC = VG_DIF_CB.
    MODIFY ZHMS_GATE_PORTA FROM W_CARGA.
    CLEAR W_CARGA.

    LOOP AT T_SAIDA INTO W_SAIDA.
      IF W_SAIDA-CHECKBOX = 'X'.
        DELETE T_SAIDA.
        W_CARGA_ITEM-NCARGA = VG_NUM_CARGA.
        W_CARGA_ITEM-DOCNUM = W_SAIDA-DOCNUM.
        MODIFY ZHMS_GATE_ITEM FROM W_CARGA_ITEM.
        CLEAR W_CARGA_ITEM.
      ENDIF.
    ENDLOOP.

    COMMIT WORK.

    MESSAGE TEXT-003 TYPE 'S' DISPLAY LIKE 'S'.

    PERFORM ZF_CLEAR.
    LEAVE TO SCREEN 0.

  ENDIF.


ENDFORM.                    " ZF_CARGA_FINAL

*&---------------------------------------------------------------------*
*&      Module  CHECA_PERC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECA_PERC INPUT.
  DATA: VG_FINAL TYPE P DECIMALS 2.
  IF VG_PERC IS NOT INITIAL.
*    CLEAR vg_final.
* Calcula perc
    VG_DIF_CB = VG_PESO_BRUTO_SAIDA * ( VG_PERC / 100 ).
*
** Calc Diferença
*    vg_peso_dif = vg_peso_saida - vg_peso_bruto_saida.
*    IF vg_peso_dif < 0.
*      vg_peso_dif = vg_peso_dif * -1.
*    ENDIF.

    IF VG_PESO_DIF > VG_DIF_CB.
*      vg_dif_cb = vg_final.
      VG_ICON = '@0A@'.
    ELSE.
*      vg_dif_cb = vg_final.
      VG_ICON = '@08@'.
    ENDIF.
  ELSE.
    CLEAR: VG_DIF_CB, VG_ICON.
  ENDIF.
ENDMODULE.                 " CHECA_PERC  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHECA_SAIDA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECA_SAIDA INPUT.
*  DATA: vg_final TYPE p DECIMALS 2.
  CLEAR VG_FINAL.
  IF VG_PESO_SAIDA IS NOT INITIAL.
    VG_FINAL = VG_PESO_SAIDA - ( VG_PESO_BRUTO_SAIDA + VG_PESO_ENTRADA ).
    IF VG_FINAL < 0.
      VG_FINAL = VG_FINAL * -1.
    ENDIF.
    VG_PESO_DIF = VG_FINAL.
  ENDIF.

  IF VG_PESO_OUT IS NOT INITIAL.
    IF VG_PESO_BRUTO_SAIDA > VG_PESO_OUT.
      MESSAGE TEXT-004 TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.
  ENDIF.

ENDMODULE.                 " CHECA_SAIDA  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHECA_ENTRADA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECA_ENTRADA INPUT.

*  IF vg_peso_entrada IS NOT INITIAL.
*    vg_peso_saida = vg_peso_entrada + vg_peso_bruto_saida.
*  ENDIF.
ENDMODULE.                 " CHECA_ENTRADA  INPUT

*&---------------------------------------------------------------------*
*&      Module  TRATA_NUM_CARGA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TRATA_NUM_CARGA OUTPUT.
  IF VG_NUM_CARGA IS INITIAL.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        NR_RANGE_NR             = '01'
        OBJECT                  = 'ZHMS_GATE'
      IMPORTING
        NUMBER                  = VG_NUM_CARGA
      EXCEPTIONS
        INTERVAL_NOT_FOUND      = 1
        NUMBER_RANGE_NOT_INTERN = 2
        OBJECT_NOT_FOUND        = 3
        QUANTITY_IS_0           = 4
        QUANTITY_IS_NOT_1       = 5
        INTERVAL_OVERFLOW       = 6
        BUFFER_OVERFLOW         = 7
        OTHERS                  = 8.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.
  ENDIF.
ENDMODULE.                 " TRATA_NUM_CARGA  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  CHECA_RADIOBUTTON  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CHECA_RADIOBUTTON OUTPUT.

*  IF vg_carreta   IS INITIAL
*  AND vg_trem     IS INITIAL
*  AND vg_tritrem  IS INITIAL
*  AND vg_bitrem   IS INITIAL
*  AND vg_vagao    IS INITIAL
*  AND vg_navio    IS INITIAL
*  AND vg_outros   IS INITIAL.
*    vg_trucado = 'X'.
* Início - Patrícia - 19/10/16
*  vg_peso_in = 10000.
*  vg_peso_out = 14000.
* Fim - Patrícia - 19/10/16
*  ENDIF.

  IF VG_FIRST IS INITIAL.
    VG_FIRST = 'VG_TRUCADO'.
    VG_TRUCADO = 'X'.
* Início - Patrícia - 19/10/16
    VG_PESO_IN = 10000.
    VG_PESO_OUT = 14000.
* Fim - Patrícia - 19/10/16
  ELSE.

    IF VG_CARRETA NE SPACE.

      IF VG_FIRST NE 'VG_CARRETA'.

        IF VG_FIRST EQ 'VG_TRUCADO'.
          CLEAR VG_TRUCADO.
        ENDIF.

        IF VG_FIRST EQ 'VG_TREM'.
          CLEAR VG_TREM.
        ENDIF.

        IF VG_FIRST EQ 'VG_BITREM'.
          CLEAR VG_BITREM.
        ENDIF.

        IF VG_FIRST EQ 'VG_TRITREM'.
          CLEAR VG_TRITREM.
        ENDIF.

        IF VG_FIRST EQ 'VG_VAGAO'.
          CLEAR VG_VAGAO.
        ENDIF.

        IF VG_FIRST EQ 'VG_NAVIO'.
          CLEAR VG_NAVIO.
        ENDIF.

        IF VG_FIRST EQ 'VG_OUTROS'.
          CLEAR VG_OUTROS.
        ENDIF.

        VG_FIRST = 'VG_CARRETA'.

      ENDIF.

    ENDIF.

    IF VG_TRUCADO NE SPACE.

      IF VG_FIRST NE 'VG_TRUCADO'.

        IF VG_FIRST EQ 'VG_CARRETA'.
          CLEAR VG_CARRETA.
        ENDIF.

        IF VG_FIRST EQ 'VG_TREM'.
          CLEAR VG_TREM.
        ENDIF.

        IF VG_FIRST EQ 'VG_BITREM'.
          CLEAR VG_BITREM.
        ENDIF.

        IF VG_FIRST EQ 'VG_TRITREM'.
          CLEAR VG_TRITREM.
        ENDIF.

        IF VG_FIRST EQ 'VG_VAGAO'.
          CLEAR VG_VAGAO.
        ENDIF.

        IF VG_FIRST EQ 'VG_NAVIO'.
          CLEAR VG_NAVIO.
        ENDIF.

        IF VG_FIRST EQ 'VG_OUTROS'.
          CLEAR VG_OUTROS.
        ENDIF.

        VG_FIRST = 'VG_TRUCADO'.

      ENDIF.

    ENDIF.

    IF VG_TREM NE SPACE.

      IF VG_FIRST NE 'VG_TREM'.

        IF VG_FIRST EQ 'VG_CARRETA'.
          CLEAR VG_CARRETA.
        ENDIF.

        IF VG_FIRST EQ 'VG_TRUCADO'.
          CLEAR VG_TRUCADO.
        ENDIF.

        IF VG_FIRST EQ 'VG_BITREM'.
          CLEAR VG_BITREM.
        ENDIF.

        IF VG_FIRST EQ 'VG_TRITREM'.
          CLEAR VG_TRITREM.
        ENDIF.

        IF VG_FIRST EQ 'VG_VAGAO'.
          CLEAR VG_VAGAO.
        ENDIF.

        IF VG_FIRST EQ 'VG_NAVIO'.
          CLEAR VG_NAVIO.
        ENDIF.

        IF VG_FIRST EQ 'VG_OUTROS'.
          CLEAR VG_OUTROS.
        ENDIF.

        VG_FIRST = 'VG_TREM'.

      ENDIF.

    ENDIF.


    IF VG_BITREM NE SPACE.

      IF VG_FIRST NE 'VG_BITREM'.

        IF VG_FIRST EQ 'VG_CARRETA'.
          CLEAR VG_CARRETA.
        ENDIF.

        IF VG_FIRST EQ 'VG_TRUCADO'.
          CLEAR VG_TRUCADO.
        ENDIF.

        IF VG_FIRST EQ 'VG_TREM'.
          CLEAR VG_TREM.
        ENDIF.

        IF VG_FIRST EQ 'VG_TRITREM'.
          CLEAR VG_TRITREM.
        ENDIF.

        IF VG_FIRST EQ 'VG_VAGAO'.
          CLEAR VG_VAGAO.
        ENDIF.

        IF VG_FIRST EQ 'VG_NAVIO'.
          CLEAR VG_NAVIO.
        ENDIF.

        IF VG_FIRST EQ 'VG_OUTROS'.
          CLEAR VG_OUTROS.
        ENDIF.

        VG_FIRST = 'VG_BITREM'.

      ENDIF.

    ENDIF.


    IF VG_TRITREM NE SPACE.

      IF VG_FIRST NE 'VG_TRITREM'.

        IF VG_FIRST EQ 'VG_CARRETA'.
          CLEAR VG_CARRETA.
        ENDIF.

        IF VG_FIRST EQ 'VG_TRUCADO'.
          CLEAR VG_TRUCADO.
        ENDIF.

        IF VG_FIRST EQ 'VG_TREM'.
          CLEAR VG_TREM.
        ENDIF.

        IF VG_FIRST EQ 'VG_BITREM'.
          CLEAR VG_BITREM.
        ENDIF.

        IF VG_FIRST EQ 'VG_VAGAO'.
          CLEAR VG_VAGAO.
        ENDIF.

        IF VG_FIRST EQ 'VG_NAVIO'.
          CLEAR VG_NAVIO.
        ENDIF.

        IF VG_FIRST EQ 'VG_OUTROS'.
          CLEAR VG_OUTROS.
        ENDIF.

        VG_FIRST = 'VG_TRITREM'.

      ENDIF.

    ENDIF.

    IF VG_VAGAO NE SPACE.

      IF VG_FIRST NE 'VG_VAGAO'.

        IF VG_FIRST EQ 'VG_CARRETA'.
          CLEAR VG_CARRETA.
        ENDIF.

        IF VG_FIRST EQ 'VG_TRUCADO'.
          CLEAR VG_TRUCADO.
        ENDIF.

        IF VG_FIRST EQ 'VG_TREM'.
          CLEAR VG_TREM.
        ENDIF.

        IF VG_FIRST EQ 'VG_TRITREM'.
          CLEAR VG_TRITREM.
        ENDIF.

        IF VG_FIRST EQ 'VG_BITREM'.
          CLEAR VG_BITREM.
        ENDIF.

        IF VG_FIRST EQ 'VG_NAVIO'.
          CLEAR VG_NAVIO.
        ENDIF.

        IF VG_FIRST EQ 'VG_OUTROS'.
          CLEAR VG_OUTROS.
        ENDIF.

        VG_FIRST = 'VG_VAGAO'.

      ENDIF.

    ENDIF.

    IF VG_NAVIO NE SPACE.

      IF VG_FIRST NE 'VG_VAGAO'.

        IF VG_FIRST EQ 'VG_CARRETA'.
          CLEAR VG_CARRETA.
        ENDIF.

        IF VG_FIRST EQ 'VG_TRUCADO'.
          CLEAR VG_TRUCADO.
        ENDIF.

        IF VG_FIRST EQ 'VG_TREM'.
          CLEAR VG_TREM.
        ENDIF.

        IF VG_FIRST EQ 'VG_TRITREM'.
          CLEAR VG_TRITREM.
        ENDIF.

        IF VG_FIRST EQ 'VG_BITREM'.
          CLEAR VG_BITREM.
        ENDIF.

        IF VG_FIRST EQ 'VG_VAGAO'.
          CLEAR VG_VAGAO.
        ENDIF.

        IF VG_FIRST EQ 'VG_OUTROS'.
          CLEAR VG_OUTROS.
        ENDIF.

        VG_FIRST = 'VG_NAVIO'.

      ENDIF.

    ENDIF.


    IF VG_OUTROS NE SPACE.

      IF VG_FIRST NE 'VG_OUTROS'.

        IF VG_FIRST EQ 'VG_CARRETA'.
          CLEAR VG_CARRETA.
        ENDIF.

        IF VG_FIRST EQ 'VG_TRUCADO'.
          CLEAR VG_TRUCADO.
        ENDIF.

        IF VG_FIRST EQ 'VG_TREM'.
          CLEAR VG_TREM.
        ENDIF.

        IF VG_FIRST EQ 'VG_TRITREM'.
          CLEAR VG_TRITREM.
        ENDIF.

        IF VG_FIRST EQ 'VG_BITREM'.
          CLEAR VG_BITREM.
        ENDIF.

        IF VG_FIRST EQ 'VG_VAGAO'.
          CLEAR VG_VAGAO.
        ENDIF.

        IF VG_FIRST EQ 'VG_NAVIO'.
          CLEAR VG_NAVIO.
        ENDIF.

        VG_FIRST = 'VG_OUTROS'.

      ENDIF.

    ENDIF.

  ENDIF.
  IF VG_ENTRADA IS INITIAL.
    VG_SAIDA = 'X'.
  ENDIF.
* Início - Patrícia - 19/10/16
*  vg_rg_motorst = '43.654.896'.
*  vg_nm_motor = 'JOSE GERALDO RAFAEL BERERAF'.
*  vg_categ_cnh = 'ABCD'.
*  vg_cnh = '092388494849'.
*  vg_valid_cnh = '20201231'.
*  vg_status_cnh = 'ATIVO'.
* Fim - Patrícia - 19/10/16
*VG_TOCO
*VG_PLACA1
*VG_PLACA2
ENDMODULE.                 " CHECA_RADIOBUTTON  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  ZF_CLEAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ZF_CLEAR .
  CLEAR: VG_BUKRS      ,
         VG_BUTXT      ,
         VG_WERKS      ,
         VG_NM_WERKS   ,
         VG_DT_EMISS_D ,
         VG_DT_EMISS_A ,
         VG_DT_RECB_D  ,
         VG_DT_RECB_A  ,
         VG_CNPJ_EMISS ,
         VG_STATUS(30) ,
         VG_NFNUM      ,
         VG_SERIE      ,
         VG_CHAVE(44)  ,
         VG_EMPRESA    ,
         VG_FILIAL     ,
         VG_CENTRO     ,
         VG_CTE(1)     ,
         VG_NFE(1)     ,
         VG_UCOMM      ,
         VG_CONSULTA   ,
         VG_COD_TRANSP ,
         VG_RG_MOTORST ,
         VG_NM_MOTOR   ,
         VG_RG_AJUDANT ,
         VG_NM_AJUD    ,
         VG_CNH        ,
         VG_VALID_CNH  ,
         VG_CATEG_CNH  ,
         VG_STATUS_CNH ,
         VG_ICONE_CNH  ,
         VG_TOCO       ,
         VG_PLACA1     ,
         VG_PLACA2     ,
         VG_PLACA3     ,
         VG_TP_VEIC    ,
         VG_COD_RENAVAM,
         VG_EXERCICIO  ,
         VG_VALIDADE   ,
         VG_ESPECIE    ,
         VG_TIPO       ,
         VG_COR        ,
         VG_CHASSI     ,
         VG_NR_DPVAT   ,
         VG_VALID_DPVAT,
         VG_TARA_TOTAL ,
         VG_FAROL_NF(10),
         VG_ENTRADA      ,
         VG_SAIDA        ,
         VG_TRUCADO      ,
         VG_CARRETA      ,
         VG_TREM         ,
         VG_TRITREM      ,
         VG_BITREM       ,
         VG_VAGAO        ,
         VG_NAVIO        ,
         VG_OUTROS       ,
         VG_PESO_IN      ,
         VG_PESO_OUT     ,
         VG_VOLUME       ,
         VG_RESP         ,
         VG_MTART        ,
         VG_MATNR        ,
         VG_MESS(3)      ,
         VG_OK           ,
         VG_INT          ,
         VG_FIRST(20)    ,
         VG_PESO_BRUTO_SAIDA,
         VG_PESO_SAIDA   ,
         VG_PESO_DIF     ,
         VG_PERC         ,
         VG_NUM_CARGA    ,
         VG_ICON         ,
         VG_DIF_CB       ,
         VG_PESO_ENTRADA.

ENDFORM.                    " ZF_CLEAR
*&---------------------------------------------------------------------*
*&      Module  SELECIONA_DADOS_TRANSPORTADOR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SELECIONA_DADOS_TRANSPORTADOR INPUT.

  IF VG_RG_MOTORST NE SPACE.

    CLEAR W_TRANSPORTE.
    SELECT SINGLE * INTO W_TRANSPORTE
     FROM ZHOM_TRANSPORTE
      WHERE ID_MOTORISTA EQ VG_RG_MOTORST.

    IF SY-SUBRC NE 0.

      CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
        EXPORTING
          DEFAULTOPTION  = 'Y'
          TEXTLINE1      = TEXT-M13
          TEXTLINE2      = TEXT-M14
          TITEL          = TEXT-M15
          START_COLUMN   = 25
          START_ROW      = 6
          CANCEL_DISPLAY = 'X'
        IMPORTING
          ANSWER         = VG_RESP.

      IF VG_RESP EQ 'J'. "Sim

        REFRESH T_BDCDATA.

        CALL TRANSACTION 'ZHMTRANSP'.
      ELSE.
        CLEAR VG_RG_MOTORST.
      ENDIF.

    ELSE.

*  Dados do Transportador
      VG_COD_TRANSP = W_TRANSPORTE-COD_TRANSP.
      VG_NM_MOTOR   = W_TRANSPORTE-NAME1.
      VG_RG_AJUDANT = W_TRANSPORTE-RG_AJUDANTE.
      VG_NM_AJUD    = W_TRANSPORTE-NAME2.
      VG_CNH        = W_TRANSPORTE-NR_CNH.
      VG_VALID_CNH  = W_TRANSPORTE-VALID_CNH.
      VG_CATEG_CNH  = W_TRANSPORTE-CATEG_CNH.

      IF SY-DATUM GT VG_VALID_CNH.
        VG_STATUS_CNH = 'C.N.H se encontra Expirada'.
        VG_ICONE_CNH  = '@1B@'.
      ELSEIF SY-DATUM EQ VG_VALID_CNH.
        VG_STATUS_CNH = 'C.N.H vencerá hoje - Favor Regularizar'.
        VG_ICONE_CNH  = '@1A@'.
      ELSE.
        VG_STATUS_CNH = 'C.N.H Regularizada'.
        VG_ICONE_CNH  = '@19@'.
      ENDIF.

    ENDIF.

  ELSE.
* Início - Patrícia - 20/10/16
*    CLEAR vg_mess.
*    vg_mess = '009'.
*    MESSAGE s009(zreceb).
**    LEAVE TO SCREEN 1000.
* Início - Patrícia - 20/10/16
  ENDIF.

ENDMODULE.                 " SELECIONA_DADOS_TRANSPORTADOR  INPUT
*&---------------------------------------------------------------------*
*&      Module  SELECIONA_DADOS_VEICULO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SELECIONA_DADOS_VEICULO INPUT.

* Somente efetua as consistências após o preenchimento dos dados do Transportador
  IF W_TRANSPORTE-ID_MOTORISTA IS INITIAL AND
     ( VG_TOCO NE SPACE OR VG_PLACA1 NE SPACE OR
       VG_PLACA2 NE SPACE OR VG_PLACA3 NE SPACE ).

    MESSAGE S009(ZRECEB) DISPLAY LIKE 'E'.
  ENDIF.

  CLEAR W_VEICULO.

*  IF vg_toco NE space OR
*     vg_placa1 NE space OR
*     vg_placa2 NE space OR
*     vg_placa3 NE space.

  IF NOT VG_TOCO IS INITIAL AND
     NOT VG_TRUCADO IS INITIAL.

    SELECT SINGLE * INTO W_VEICULO
    FROM ZHOM_VEICULO
    WHERE PLACA_TOCO EQ VG_TOCO.
  ELSE.
    CLEAR VG_TOCO.
  ENDIF.

  IF NOT VG_PLACA1 IS INITIAL AND
     ( NOT VG_CARRETA IS INITIAL OR
       NOT VG_TREM    IS INITIAL OR
       NOT VG_BITREM  IS INITIAL ).


    SELECT SINGLE * INTO W_VEICULO
    FROM ZHOM_VEICULO
    WHERE PLACA_CAR1 EQ VG_PLACA1.
  ELSE.


  ENDIF.

  IF NOT VG_PLACA2 IS INITIAL AND
    ( NOT VG_CARRETA IS INITIAL OR
       NOT VG_TREM    IS INITIAL OR
       NOT VG_BITREM  IS INITIAL ).


    SELECT SINGLE * INTO W_VEICULO
    FROM ZHOM_VEICULO
    WHERE PLACA_CAR2 EQ VG_PLACA2.

  ENDIF.

  IF NOT VG_PLACA3 IS INITIAL AND
    ( NOT VG_CARRETA IS INITIAL OR
       NOT VG_TREM    IS INITIAL OR
       NOT VG_BITREM  IS INITIAL ).


    SELECT SINGLE * INTO W_VEICULO
    FROM ZHOM_VEICULO
    WHERE PLACA_CAR3 EQ VG_PLACA3.

  ENDIF.

*  CLEAR w_veiculo.
*  SELECT SINGLE * INTO w_veiculo
*   FROM zhom_veiculo
*    WHERE placa_toco EQ vg_toco   OR
*          placa_car1 EQ vg_placa1 OR
*          placa_car2 EQ vg_placa2 OR
*          placa_car3 EQ vg_placa3.

  IF SY-SUBRC NE 0.
    CLEAR VG_RESP.
    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
      EXPORTING
        DEFAULTOPTION  = 'Y'
        TEXTLINE1      = TEXT-M16
        TEXTLINE2      = TEXT-M14
        TITEL          = TEXT-M15
        START_COLUMN   = 25
        START_ROW      = 6
        CANCEL_DISPLAY = 'X'
      IMPORTING
        ANSWER         = VG_RESP.

    IF VG_RESP EQ 'J'. "Sim
*
*        REFRESH t_bdcdata.
*        PERFORM f_bdcdata_dynpro USING: 'X' 'SAPLZHOMC_NFE' '0016',
*                                        ' '  'BDC_OKCODE'   '=NEWL'.
*        PERFORM f_verifica_tipo_veiculo.
*        PERFORM f_bdcdata_dynpro USING: 'X' 'SAPLZHOMC_NFE' '0017',
*                                        ' ' 'ZHOM_VEICULO-PLACA_TOCO' vg_toco,
*                                        ' ' 'ZHOM_VEICULO-PLACA_CAR1' vg_placa1,
*                                        ' ' 'ZHOM_VEICULO-PLACA_CAR2' vg_placa2,
*                                        ' ' 'ZHOM_VEICULO-PLACA_CAR3' vg_placa3,
*                                        ' ' 'ZHOM_VEICULO-TIPO_VEICULO' vg_tp_veic.
*
*        CALL TRANSACTION 'ZHMVEIC'
*                USING t_bdcdata
*                MODE 'E'.

      CALL TRANSACTION 'ZHMVEIC'.
    ELSE.
      CLEAR: VG_TOCO,
             VG_PLACA1,
             VG_PLACA2,
             VG_PLACA3.

    ENDIF.

  ELSE.

*   vg_tp_veic          = w_veiculo-tipo_veiculo.
    VG_COD_RENAVAM      = W_VEICULO-COD_RENAVAM.
    VG_EXERCICIO        = W_VEICULO-ANO_EXERCICIO.
    VG_VALIDADE         = W_VEICULO-VALIDADE.
    VG_ESPECIE          = W_VEICULO-ESPECIE.
    VG_TIPO             = W_VEICULO-TIPO.
    VG_COR              = W_VEICULO-COR.
    VG_CHASSI           = W_VEICULO-CHASSI.
    VG_NR_DPVAT         = W_VEICULO-NR_DPVAT.
    VG_VALID_DPVAT      = W_VEICULO-VALID_DPVAT.
    VG_TARA_TOTAL       = W_VEICULO-TARA_TOTAL.

*    CASE w_veiculo-tipo_veiculo.
*      WHEN '01'.  "Trucado
*        vg_trucado = 'X'.
*        CLEAR: vg_carreta, vg_bitrem, vg_tritrem, vg_trem, vg_vagao, vg_navio, vg_outros.
*      WHEN '02'.  "Carreta
*        vg_carreta = 'X'.
*        CLEAR: vg_trucado, vg_bitrem, vg_tritrem, vg_trem, vg_vagao, vg_navio, vg_outros.
*      WHEN '03'.  "Bitrem
*        vg_bitrem = 'X'.
*        CLEAR: vg_trucado, vg_carreta, vg_tritrem, vg_trem, vg_vagao, vg_navio, vg_outros.
*      WHEN '04'.  "Tritrem
*        vg_tritrem = 'X'.
*        CLEAR: vg_trucado, vg_carreta, vg_bitrem, vg_trem, vg_vagao, vg_navio, vg_outros.
*      WHEN '05'.  "Trem
*        vg_trem = 'X'.
*        CLEAR: vg_trucado, vg_carreta, vg_bitrem, vg_tritrem, vg_vagao, vg_navio, vg_outros.
*      WHEN '06'.  "Vagão de Trem
*        vg_vagao = 'X'.
*        CLEAR: vg_trucado, vg_carreta, vg_bitrem, vg_tritrem, vg_trem, vg_navio, vg_outros.
*      WHEN '07'.  "Navio
*        vg_navio = 'X'.
*        CLEAR: vg_trucado, vg_carreta, vg_bitrem, vg_tritrem, vg_trem, vg_vagao, vg_outros.
*      WHEN '08'.  "Outros
*        CLEAR: vg_trucado, vg_carreta, vg_bitrem, vg_tritrem, vg_trem, vg_vagao, vg_navio.
*        vg_outros = 'X'.
*    ENDCASE.

  ENDIF.

*  ENDIF.

ENDMODULE.                 " SELECIONA_DADOS_VEICULO  INPUT
*&---------------------------------------------------------------------*
*&      Form  F_LOGO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LOGO .

  DATA: REPID LIKE SY-REPID.
  REPID = SY-REPID.

  IF PICTURE_CONTROL_1 IS INITIAL.

    CREATE OBJECT PICTURE_CONTROL_1
      EXPORTING
        PARENT = DOCKING.
    CHECK SY-SUBRC = 0.
    CALL METHOD PICTURE_CONTROL_1->SET_3D_BORDER
      EXPORTING
        BORDER = 0.
    CALL METHOD PICTURE_CONTROL_1->SET_DISPLAY_MODE
      EXPORTING
        DISPLAY_MODE = CL_GUI_PICTURE=>DISPLAY_MODE_STRETCH.

    CALL METHOD PICTURE_CONTROL_1->SET_POSITION
      EXPORTING
        HEIGHT = 150  "
        LEFT   = 400  "
        TOP    = 75
        WIDTH  = 600.

    IF URL IS INITIAL.

      REFRESH QUERY_TABLE.
      QUERY_TABLE-NAME  = '_OBJECT_ID'.

      QUERY_TABLE-VALUE = 'Z_LOGO_DOCA2'.
      APPEND QUERY_TABLE.

      CALL FUNCTION 'WWW_GET_MIME_OBJECT'
        TABLES
          QUERY_STRING        = QUERY_TABLE
          HTML                = HTML_TABLE
          MIME                = PIC_DATA
        CHANGING
          RETURN_CODE         = RETURN_CODE
          CONTENT_TYPE        = CONTENT_TYPE
          CONTENT_LENGTH      = CONTENT_LENGTH
        EXCEPTIONS
          OBJECT_NOT_FOUND    = 1
          PARAMETER_NOT_FOUND = 2
          OTHERS              = 3.
      IF SY-SUBRC <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      CALL FUNCTION 'DP_CREATE_URL'
        EXPORTING
          TYPE     = 'image'
          SUBTYPE  = CNDP_SAP_TAB_UNKNOWN
          SIZE     = PIC_SIZE
          LIFETIME = CNDP_LIFETIME_TRANSACTION
        TABLES
          DATA     = PIC_DATA
        CHANGING
          URL      = URL
        EXCEPTIONS
          OTHERS   = 1.

      CALL METHOD PICTURE_CONTROL_1->LOAD_PICTURE_FROM_URL
        EXPORTING
          URL = URL.

    ENDIF.

  ENDIF.

ENDFORM.                    " F_LOGO
*&---------------------------------------------------------------------*
*&      Module  EXIBE_PLACAS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F_EXIBE_PLACAS INPUT.

  CASE 'X'.

    WHEN VG_TRUCADO.

      REFRESH T_ZHOM_VEICULO.
      SELECT PLACA_TOCO PLACA_CAR1 PLACA_CAR2
             PLACA_CAR3 TIPO_VEICULO FROM ZHOM_VEICULO
      INTO TABLE T_ZHOM_VEICULO
      WHERE TIPO_VEICULO EQ '01'.
      IF SY-SUBRC EQ 0.

        CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
          EXPORTING
            RETFIELD        = 'PLACA_TOCO'
            VALUE_ORG       = 'S'
          TABLES
            VALUE_TAB       = T_ZHOM_VEICULO
            RETURN_TAB      = T_RET_TAB
          EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.
        IF SY-SUBRC <> 0.
          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ELSE.

          CLEAR WA_RET_TAB.
          READ TABLE T_RET_TAB INTO WA_RET_TAB INDEX 1.
          IF SY-SUBRC EQ 0.
            VG_TOCO = WA_RET_TAB-FIELDVAL.
          ENDIF.
        ENDIF.


      ENDIF.

  ENDCASE.

ENDMODULE.                 " EXIBE_PLACAS  INPUT
*&---------------------------------------------------------------------*
*&      Module  F_EXIBE_PL_CARRETA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F_EXIBE_PL_CARRETA INPUT.

  CASE 'X'.

    WHEN VG_CARRETA OR VG_TREM OR VG_BITREM.

      REFRESH T_ZHOM_VEICULO.
      SELECT PLACA_TOCO PLACA_CAR1 PLACA_CAR2
             PLACA_CAR3 TIPO_VEICULO
      FROM ZHOM_VEICULO
      INTO TABLE T_ZHOM_VEICULO
      WHERE TIPO_VEICULO EQ '02'.
      IF SY-SUBRC EQ 0.

        CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
          EXPORTING
            RETFIELD        = 'PLACA_CAR1'
            VALUE_ORG       = 'S'
          TABLES
            VALUE_TAB       = T_ZHOM_VEICULO
            RETURN_TAB      = T_RET_TAB
          EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.
        IF SY-SUBRC <> 0.
          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ELSE.

          CLEAR WA_RET_TAB.
          READ TABLE T_RET_TAB INTO WA_RET_TAB INDEX 1.
          IF SY-SUBRC EQ 0.
            VG_PLACA1 = WA_RET_TAB-FIELDVAL.
          ENDIF.

        ENDIF.


      ENDIF.

  ENDCASE.


ENDMODULE.                 " F_EXIBE_PL_CARRETA  INPUT
*&---------------------------------------------------------------------*
*&      Module  F_EXIBE_PL_CARRETA2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F_EXIBE_PL_CARRETA2 INPUT.

  CASE 'X'.

    WHEN VG_CARRETA OR VG_TREM OR VG_BITREM.

      REFRESH T_ZHOM_VEICULO.
      SELECT PLACA_TOCO PLACA_CAR1 PLACA_CAR2
             PLACA_CAR3 TIPO_VEICULO
      FROM ZHOM_VEICULO
      INTO TABLE T_ZHOM_VEICULO
      WHERE TIPO_VEICULO EQ '02' OR
            TIPO_VEICULO EQ '03'.
      IF SY-SUBRC EQ 0.

        CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
          EXPORTING
            RETFIELD        = 'PLACA_CAR2'
            VALUE_ORG       = 'S'
          TABLES
            VALUE_TAB       = T_ZHOM_VEICULO
            RETURN_TAB      = T_RET_TAB
          EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.
        IF SY-SUBRC <> 0.
          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ELSE.

          CLEAR WA_RET_TAB.
          READ TABLE T_RET_TAB INTO WA_RET_TAB INDEX 1.
          IF SY-SUBRC EQ 0.
            VG_PLACA2 = WA_RET_TAB-FIELDVAL.
          ENDIF.

        ENDIF.


      ENDIF.

  ENDCASE.

ENDMODULE.                 " F_EXIBE_PL_CARRETA2  INPUT
*&---------------------------------------------------------------------*
*&      Module  F_EXIBE_PL_CARRETA3  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F_EXIBE_PL_CARRETA3 INPUT.

  CASE 'X'.

    WHEN VG_CARRETA OR
         VG_TREM    OR
         VG_BITREM  OR
         VG_TRITREM.


      REFRESH T_ZHOM_VEICULO.
      SELECT PLACA_TOCO PLACA_CAR1 PLACA_CAR2
             PLACA_CAR3 TIPO_VEICULO
      FROM ZHOM_VEICULO
      INTO TABLE T_ZHOM_VEICULO
      WHERE TIPO_VEICULO EQ '02' OR
            TIPO_VEICULO EQ '03'.
      IF SY-SUBRC EQ 0.

        CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
          EXPORTING
            RETFIELD        = 'PLACA_CAR3'
            VALUE_ORG       = 'S'
          TABLES
            VALUE_TAB       = T_ZHOM_VEICULO
            RETURN_TAB      = T_RET_TAB
          EXCEPTIONS
            PARAMETER_ERROR = 1
            NO_VALUES_FOUND = 2
            OTHERS          = 3.
        IF SY-SUBRC <> 0.
          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ELSE.

          CLEAR WA_RET_TAB.
          READ TABLE T_RET_TAB INTO WA_RET_TAB INDEX 1.
          IF SY-SUBRC EQ 0.
            VG_PLACA3 = WA_RET_TAB-FIELDVAL.
          ENDIF.

        ENDIF.


      ENDIF.

  ENDCASE.

ENDMODULE.                 " F_EXIBE_PL_CARRETA3  INPUT
*&---------------------------------------------------------------------*
*&      Module  F_VALIDA_TRUC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F_VALIDA_TRUC INPUT.


  IF VG_TRUCADO = 'X'.

    VG_PESO_IN = 10000.
    VG_PESO_OUT = 14000.

    CLEAR: VG_CARRETA,
           VG_TREM,
           VG_TRITREM,
           VG_BITREM,
           VG_VAGAO,
           VG_NAVIO,
           VG_OUTROS.

    CLEAR: VG_PLACA1, VG_PLACA2, VG_PLACA3.

  ENDIF.

ENDMODULE.                 " F_VALIDA_TRUC  INPUT
*&---------------------------------------------------------------------*
*&      Module  F_VALIDA_CAR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F_VALIDA_CAR INPUT.


  IF VG_CARRETA = 'X'.

    VG_PESO_IN = 16000.
    VG_PESO_OUT = 20000.

    CLEAR:    VG_TRUCADO,
              VG_TREM,
              VG_TRITREM,
              VG_BITREM,
              VG_VAGAO,
              VG_NAVIO,
              VG_OUTROS.

    CLEAR: VG_TOCO, VG_PLACA2, VG_PLACA3.

  ENDIF.

ENDMODULE.                 " F_VALIDA_CAR  INPUT
*&---------------------------------------------------------------------*
*&      Module  F_VALIDA_BIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F_VALIDA_BIT INPUT.

  IF VG_BITREM = 'X'.

    VG_PESO_IN = 25000.
    VG_PESO_OUT = 40000.

    CLEAR:  VG_TRUCADO,
            VG_CARRETA,
            VG_TREM,
            VG_TRITREM,
            VG_VAGAO,
            VG_NAVIO,
            VG_OUTROS.

  ENDIF.

ENDMODULE.                 " F_VALIDA_BIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  F_VALIDA_TREM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F_VALIDA_TREM INPUT.


  IF VG_TREM = 'X'.

    VG_PESO_IN = 20000.
    VG_PESO_OUT = 35000.

    CLEAR: VG_TRUCADO,
           VG_CARRETA,
           VG_BITREM,
           VG_TRITREM,
           VG_VAGAO,
           VG_NAVIO,
           VG_OUTROS.

  ENDIF.

ENDMODULE.                 " F_VALIDA_TREM  INPUT
*&---------------------------------------------------------------------*
*&      Module  CARREGADADOS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE CARREGADADOS OUTPUT.
DATA: vl_dayw    TYPE scal-indicator,
      vl_langt   TYPE t246-langt,
      vl_mnr     TYPE t247-mnr,
      vl_ltx     TYPE t247-ltx.

    LV_CHAVE = '35180504897652000121550010000023991666433473'.

*SELECT * FROM ZHMS_TB_DOCMN INTO TABLE T_DOCMN WHERE CHAVE = LV_CHAVE.

*break rhitokaz.
*Número da NF-e
SELECT SINGLE VALUE FROM ZHMS_TB_DOCMN INTO vg_nnf WHERE MNEUM EQ 'NNF' AND CHAVE = LV_CHAVE.

*Data de Emissão
SELECT SINGLE VALUE FROM ZHMS_TB_DOCMN INTO vg_dhemi WHERE MNEUM EQ 'DHEMI' AND CHAVE = LV_CHAVE.
CONCATENATE vg_dhemi+0(4)  vg_dhemi+8(2) vg_dhemi+5(2) into vl_data.
vg_hora = vg_dhemi+11(8).


  CALL FUNCTION 'DATE_COMPUTE_DAY'
        EXPORTING
          date = vl_data
        IMPORTING
          day  = vl_dayw.

      SELECT SINGLE langt
        INTO vl_langt
        FROM t246
       WHERE wotnr EQ vl_dayw
         AND sprsl EQ sy-langu.

      vl_mnr =  vl_data+4(2).
      SELECT SINGLE ltx
        INTO vl_ltx
        FROM t247
       WHERE spras EQ sy-langu
         AND mnr   EQ vl_mnr.

      CONCATENATE  vl_langt ',' vl_data+6 ' de ' vl_ltx vl_data(4) INTO vg_dhemi SEPARATED BY space.

*Fornecedor
SELECT SINGLE VALUE FROM ZHMS_TB_DOCMN INTO VG_BUTXT WHERE MNEUM EQ 'CNPJDEST' AND CHAVE = LV_CHAVE.
SELECT * FROM LFA1 INTO TABLE T_LFA1 WHERE STCD1 EQ VG_BUTXT.
loop at t_lfa1 into wa_lfa1.
CONCATENATE '(' WA_LFA1-LIFNR ')' WA_LFA1-NAME1 INTO VG_BUTXT.
endloop.



SELECT SINGLE *
        INTO wa_cabdoc
        FROM zhms_tb_cabdoc
       WHERE chave EQ lv_chave.



        SELECT SINGLE butxt INTO VG_NM_WERKS
        FROM t001
       WHERE bukrs EQ wa_cabdoc-bukrs.

          concatenate '(' wa_cabdoc-bukrs ')' vg_nm_werks into vg_nm_werks.


      SELECT SINGLE name
        INTO VG_NM_BRANCH
        FROM j_1bbranch
       WHERE bukrs  EQ wa_cabdoc-bukrs
         AND branch EQ wa_cabdoc-branch.


      SELECT MAX( seqnr )
        INTO wa_docconf-seqnr
        FROM zhms_tb_docconf
       WHERE natdc = wa_cabdoc-natdc
         AND typed = wa_cabdoc-typed
         AND chave = wa_cabdoc-chave.



      ADD 1 TO wa_docconf-seqnr.

**    Insere dados nas variáveis
      wa_docconf-natdc = wa_cabdoc-natdc.
      wa_docconf-typed = wa_cabdoc-typed.
      wa_docconf-chave = wa_cabdoc-chave.
      wa_docconf-dtreg = sy-datum.
      wa_docconf-hrreg = sy-uzeit.
      wa_docconf-uname = sy-uname.
      wa_docconf-dcnro = wa_cabdoc-docnr.
      wa_docconf-parid = wa_cabdoc-parid.
      wa_docconf-ativo = 'X'.
      wa_docconf-logty = 'I'.


      CASE wa_docconf-logty.
        WHEN 'E'.
          vg_conf_status = '@0A@'.
        WHEN 'W'.
          vg_conf_status = '@09@'.
        WHEN 'I'.
          vg_conf_status = '@08@'.
        WHEN 'S'.
          vg_conf_status = '@01@'.
        WHEN OTHERS.
          vg_conf_status = '@08@'.
      ENDCASE.
ENDMODULE.                 " CARREGADADOS  OUTPUT
