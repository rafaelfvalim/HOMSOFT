*&---------------------------------------------------------------------*
*& Report  ZHMS_REPORT_STATUS_PARC
*&
*&---------------------------------------------------------------------*
*& RCP - Tradução EN/ES - 13/08/2018
*&
*&---------------------------------------------------------------------*
REPORT  ZHMS_REPORT_STATUS_PARC.

*----------------------------------------------------------------------*
* TABELAS                                                              *
*----------------------------------------------------------------------*
TABLES: ZHMS_TB_SCEN_FLO,
        ZHMS_TB_FLWDOC.

*----------------------------------------------------------------------*
* TIPOS                                                                *
*----------------------------------------------------------------------*
TYPES: BEGIN OF TY_TABS.
        INCLUDE STRUCTURE RSDSTABS.
TYPES: END OF TY_TABS.

TYPES: BEGIN OF TY_FLDS.
        INCLUDE STRUCTURE RSDSFIELDS.
TYPES: END OF TY_FLDS.

*----------------------------------------------------------------------*
* Tabelas Internas                                                     *
*----------------------------------------------------------------------*
DATA: T_GRPFLD_S    TYPE STANDARD TABLE OF ZHMS_TB_GRPFLD_S,
      T_TWHERE      TYPE RSDS_TWHERE,
      T_TABS        TYPE TABLE OF TY_TABS,
      T_FLDS        TYPE TABLE OF TY_FLDS,
      T_TEXPR       TYPE RSDS_TEXPR,
      T_TYPE_T      TYPE STANDARD TABLE OF ZHMS_TX_TYPE,
      T_CABDOC      TYPE TABLE OF ZHMS_TB_CABDOC,
      T_FLWDOC      TYPE STANDARD TABLE OF ZHMS_TB_FLWDOC,
      T_FLDC        TYPE LVC_T_FCAT,
      T_STATUS      TYPE STANDARD TABLE OF ZHMS_ES_RP_STATUS,
      T_SORT        TYPE STANDARD TABLE OF LVC_S_SORT.

*----------------------------------------------------------------------*
* Estruturas Internas                                                  *
*----------------------------------------------------------------------*
DATA: WA_GRPFLD_S    TYPE ZHMS_TB_GRPFLD_S,
      WA_TWHERE      LIKE LINE OF T_TWHERE,
      WA_TABS        TYPE TY_TABS,
      WA_FLDS        TYPE TY_FLDS,
      WA_TYPE_T      TYPE ZHMS_TX_TYPE,
      WA_TYPE        TYPE ZHMS_TB_TYPE,
      WA_CABDOC      TYPE ZHMS_TB_CABDOC,
      WA_FLWDOC      TYPE ZHMS_TB_FLWDOC,
      WA_FLDC        TYPE LVC_S_FCAT,
      WA_STATUS      LIKE ZHMS_ES_RP_STATUS,
      WA_LAY         TYPE LVC_S_LAYO,
      WA_SORT        TYPE LVC_S_SORT.

*----------------------------------------------------------------------*
* Variaveis                                                            *
*----------------------------------------------------------------------*
DATA: VG_SELID      TYPE RSDYNSEL-SELID,
      VG_ACTNUM     TYPE SY-TFILL,
      VG_TITLE      TYPE SY-TITLE,
      V_ICON_GREEN  TYPE ICON-ID,
      V_ICON_YELLOW TYPE ICON-ID,
      V_ICON_RED    TYPE ICON-ID,
      OK_CODE       TYPE SY-UCOMM.


DATA: OB_CC_VLD_ITEM TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      OB_CC_GRID     TYPE REF TO CL_GUI_ALV_GRID.

*----------------------------------------------------------------------*
* Tela de Seleção                                                      *
*----------------------------------------------------------------------*
***   Lendo Tela de Seleção a ser montada
START-OF-SELECTION.
  SELECT *
         FROM ZHMS_TB_GRPFLD_S
         INTO TABLE T_GRPFLD_S
         WHERE CODGF EQ '05'.

  IF SY-SUBRC EQ 0.
    SORT T_GRPFLD_S BY CODGF SEQNR TABSS FLDSS.

***      Preparando tela de seleção dinâmica
    PERFORM F_PREP_SEL_DYNN.
***      Chamando tela de seleção dinâmica
    PERFORM F_CALL_SEL_DYNN.
***      Selecionando dados dos Documentos
    PERFORM F_SEL_DADOS.
***      Monta relatorio
    PERFORM F_MONTA_REPORT.

  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  F_PREP_SEL_DYNN
*&---------------------------------------------------------------------*
FORM F_PREP_SEL_DYNN .
  TYPES: BEGIN OF TY_TBL_SC,
           TBLNM TYPE TABNAME,
         END OF TY_TBL_SC.
  DATA: T_TBL_SC  TYPE STANDARD TABLE OF TY_TBL_SC,
        WA_TBL_SC TYPE TY_TBL_SC.

***   Verificando quais tabelas serão aceitas na Seleção
  LOOP AT T_GRPFLD_S INTO WA_GRPFLD_S.
    CLEAR  WA_TBL_SC.
    MOVE   WA_GRPFLD_S-TABSS TO WA_TBL_SC-TBLNM.
    APPEND WA_TBL_SC TO T_TBL_SC.
  ENDLOOP.

***   Eliminando tabelas duplicadas
  DELETE ADJACENT DUPLICATES FROM T_TBL_SC COMPARING ALL FIELDS.

  IF NOT T_TBL_SC[] IS INITIAL.
    REFRESH: T_TABS,
             T_FLDS.

***     Carregando Tabelas a serem consideradas
    LOOP AT T_TBL_SC INTO WA_TBL_SC.
      CLEAR WA_TABS.
      MOVE WA_TBL_SC-TBLNM TO WA_TABS-PRIM_TAB.
      APPEND WA_TABS TO T_TABS.
    ENDLOOP.

***     Carregando Campos a serem considerados
    LOOP AT T_GRPFLD_S INTO WA_GRPFLD_S.
      CLEAR WA_FLDS.
      MOVE: WA_GRPFLD_S-TABSS TO WA_FLDS-TABLENAME,
            WA_GRPFLD_S-FLDSS TO WA_FLDS-FIELDNAME,
            WA_GRPFLD_S-TYPEF TO WA_FLDS-TYPE.
      APPEND WA_FLDS TO T_FLDS.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_PREP_SEL_DYNN
*&---------------------------------------------------------------------*
*&      Form  F_CALL_SEL_DYNN
*&---------------------------------------------------------------------*
FORM F_CALL_SEL_DYNN .
  DATA: VL_TEXT TYPE SY-TITLE.

***   Inicializando Tela de Seleção
  CALL FUNCTION 'FREE_SELECTIONS_INIT'
    EXPORTING
      KIND                     = 'T'
      EXPRESSIONS              = T_TEXPR
    IMPORTING
      SELECTION_ID             = VG_SELID
      NUMBER_OF_ACTIVE_FIELDS  = VG_ACTNUM
    TABLES
      TABLES_TAB               = T_TABS
      FIELDS_TAB               = T_FLDS
    EXCEPTIONS
      FIELDS_INCOMPLETE        = 01
      FIELDS_NO_JOIN           = 02
      FIELD_NOT_FOUND          = 03
      NO_TABLES                = 04
      TABLE_NOT_FOUND          = 05
      EXPRESSION_NOT_SUPPORTED = 06
      INCORRECT_EXPRESSION     = 07
      ILLEGAL_KIND             = 08
      AREA_NOT_FOUND           = 09
      INCONSISTENT_AREA        = 10
      KIND_F_NO_FIELDS_LEFT    = 11
      KIND_F_NO_FIELDS         = 12
      TOO_MANY_FIELDS          = 13.

  IF SY-SUBRC EQ 0.
***     Carregando Condições da Tela de Seleção
    CALL FUNCTION 'FREE_SELECTIONS_WHERE_2_EX'
      EXPORTING
        WHERE_CLAUSES        = T_TWHERE
      IMPORTING
        EXPRESSIONS          = T_TEXPR
      EXCEPTIONS
        INCORRECT_EXPRESSION = 1
        OTHERS               = 2.

    IF SY-SUBRC EQ 0.
      CLEAR WA_TYPE_T.
      READ TABLE T_TYPE_T INTO WA_TYPE_T
                          WITH KEY NATDC = WA_TYPE-NATDC
                                   TYPED = WA_TYPE-TYPED
                                   LOCTP = WA_TYPE-LOCTP.

      IF SY-SUBRC EQ 0.
        CLEAR VL_TEXT.
        MOVE WA_TYPE_T-DENOM TO VL_TEXT.
      ENDIF.

***       Tela de Seleção
      CLEAR VG_TITLE.
      MOVE TEXT-001 TO VG_TITLE.

***       Criando tela de seleção
      CALL FUNCTION 'FREE_SELECTIONS_DIALOG'
        EXPORTING
          SELECTION_ID            = VG_SELID
          TITLE                   = VG_TITLE
          TREE_VISIBLE            = ''
          AS_WINDOW               = 'X'
          START_ROW               = '1'
          START_COL               = '35'
          FRAME_TEXT              = VL_TEXT
          STATUS                  = 1
        IMPORTING
          WHERE_CLAUSES           = T_TWHERE
          EXPRESSIONS             = T_TEXPR
          NUMBER_OF_ACTIVE_FIELDS = VG_ACTNUM
        TABLES
          FIELDS_TAB              = T_FLDS
        EXCEPTIONS
          INTERNAL_ERROR          = 01
          NO_ACTION               = 02
          NO_FIELDS_SELECTED      = 03
          NO_TABLES_SELECTED      = 04
          SELID_NOT_FOUND         = 05.

      IF SY-SUBRC NE 0  AND  SY-SUBRC NE 2.
***         Erro ao montar a Tela de Seleção. Contatar Suporte.
*        MESSAGE w002.
      ENDIF.
    ELSE.
***       Erro ao montar a Tela de Seleção. Contatar Suporte.
*      MESSAGE w002.
    ENDIF.
  ELSE.
****     Erro ao montar a Tela de Seleção. Contatar Suporte.
*    MESSAGE w002.
  ENDIF.
ENDFORM.                    " F_CALL_SEL_DYNN
*&---------------------------------------------------------------------*
*&      Form  F_SEL_DADOS
*&---------------------------------------------------------------------*
FORM F_SEL_DADOS .
  TYPES: BEGIN OF TY_SELECT,
   LINE TYPE CHAR80,
  END OF TY_SELECT.

  DATA: VL_INDEX TYPE SY-TABIX,
        T_WHERE  TYPE TABLE OF TY_SELECT WITH HEADER LINE,
        LS_WHERE LIKE LINE OF T_WHERE,
        LS_WHERE_TAB TYPE RSDSWHERE.

  SELECT SINGLE ID
    INTO V_ICON_GREEN
    FROM ICON
    WHERE NAME = 'ICON_GREEN_LIGHT'.

  SELECT SINGLE ID
   INTO V_ICON_YELLOW
   FROM ICON
   WHERE NAME = 'ICON_YELLOW_LIGHT'.

  SELECT SINGLE ID
    INTO V_ICON_RED
    FROM ICON
    WHERE NAME = 'ICON_RED_LIGHT'.

  IF T_TWHERE[] IS INITIAL.
    SELECT *
         INTO TABLE T_CABDOC
         FROM ZHMS_TB_CABDOC.
*      WHERE NATDC EQ VG_ACTIONX(2)
*        AND TYPED EQ VG_ACTIONX+3(4).
  ELSE.
    LOOP AT T_TWHERE INTO WA_TWHERE.
      LOOP AT WA_TWHERE-WHERE_TAB INTO LS_WHERE_TAB.
        MOVE LS_WHERE_TAB TO LS_WHERE.
        APPEND LS_WHERE TO T_WHERE.
        CLEAR LS_WHERE.
      ENDLOOP.
*      CONCATENATE 'AND ( NATDC EQ ''' VG_ACTIONX(2) '''' ')' INTO LS_WHERE.
*      APPEND LS_WHERE TO T_WHERE . CLEAR LS_WHERE.
*      CONCATENATE 'AND ( TYPED EQ '''  VG_ACTIONX+3(4) '''' ')' INTO LS_WHERE.
*      APPEND LS_WHERE TO T_WHERE . CLEAR LS_WHERE.
    ENDLOOP.

    SELECT *
     INTO TABLE T_CABDOC
     FROM ZHMS_TB_CABDOC
     WHERE (T_WHERE).
  ENDIF.

  IF NOT T_CABDOC[] IS INITIAL.
    SELECT *
      FROM ZHMS_TB_FLWDOC
      INTO TABLE T_FLWDOC
      FOR ALL ENTRIES IN T_CABDOC
     WHERE NATDC EQ T_CABDOC-NATDC
       AND TYPED EQ T_CABDOC-TYPED
       AND CHAVE EQ T_CABDOC-CHAVE.

    LOOP AT T_CABDOC INTO WA_CABDOC.
*** Verifica se ainda falta etapas para a nota
      LOOP AT T_FLWDOC INTO WA_FLWDOC  WHERE CHAVE = WA_CABDOC-CHAVE.


        IF WA_FLWDOC-FLWST = 'W'.
          WA_STATUS-ICONE_AT = V_ICON_YELLOW.
        ELSEIF WA_FLWDOC-FLWST = 'E' OR WA_FLWDOC-FLWST = 'C'.
          WA_STATUS-ICONE_AT = V_ICON_RED.
        ELSEIF WA_FLWDOC-FLWST = 'M' OR WA_FLWDOC-FLWST = 'A'.
          WA_STATUS-ICONE_AT = V_ICON_GREEN.
        ENDIF.

        MOVE: WA_FLWDOC-FLOWD TO WA_STATUS-FLOWD_AT,
              WA_CABDOC-DOCNR TO WA_STATUS-DOCNR,
              WA_CABDOC-PARID TO WA_STATUS-PARID,
              WA_FLWDOC-DTREG TO WA_STATUS-DATA.
        IF WA_FLWDOC-DTREG IS INITIAL.
          MOVE WA_CABDOC-LNCDT TO WA_STATUS-DATA.
        ENDIF.
        APPEND WA_STATUS TO T_STATUS.
        CLEAR: WA_STATUS, WA_FLWDOC.
      ENDLOOP.
      IF SY-SUBRC <> 0.
        WA_STATUS-ICONE_AT = V_ICON_YELLOW.
        MOVE: '10'           TO WA_STATUS-FLOWD_AT,
             WA_CABDOC-DOCNR TO WA_STATUS-DOCNR,
             WA_CABDOC-PARID TO WA_STATUS-PARID,
             WA_FLWDOC-DTREG TO WA_STATUS-DATA.
        IF WA_FLWDOC-DTREG IS INITIAL.
          MOVE WA_CABDOC-LNCDT TO WA_STATUS-DATA.
        ENDIF.
        APPEND WA_STATUS TO T_STATUS.
        CLEAR: WA_STATUS, WA_FLWDOC.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_SEL_DADOS
*&---------------------------------------------------------------------*
*&      Form  F_MONTA_REPORT
*&---------------------------------------------------------------------*
FORM F_MONTA_REPORT .
  CALL SCREEN '0100'.
ENDFORM.                    " F_MONTA_REPORT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS '0100'.
*  SET TITLEBAR 'xxx'.

  PERFORM F_REPORT.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  OK_CODE = SY-UCOMM.

  CASE OK_CODE.
    WHEN 'EXIT'.
      LEAVE TO SCREEN 0.
  ENDCASE.

  CLEAR OK_CODE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Form  F_REPORT
*&---------------------------------------------------------------------*
FORM F_REPORT .

  PERFORM F_MONTA_ESTRUTURA.

  PERFORM F_CALL_REPORT.

ENDFORM.                    " F_REPORT
*&---------------------------------------------------------------------*
*&      Form  F_MONTA_ESTRUTURA
*&---------------------------------------------------------------------*
FORM F_MONTA_ESTRUTURA .
  REFRESH T_FLDC[].

  CLEAR WA_FLDC.
  WA_FLDC-FIELDNAME = 'DOCNR'.
  WA_FLDC-REPTEXT   = 'Nº Documento'.
  WA_FLDC-COL_OPT   = 'X'.
  APPEND WA_FLDC TO T_FLDC.

  CLEAR WA_FLDC.
  WA_FLDC-FIELDNAME = 'PARID'.
  WA_FLDC-REPTEXT   = 'Nº Fornecedor'.
  WA_FLDC-COL_OPT   = 'X'.
  APPEND WA_FLDC TO T_FLDC.

  CLEAR WA_FLDC.
  WA_FLDC-FIELDNAME = 'FLOWD_AT'.
  WA_FLDC-REPTEXT   = 'Etapa Atual'.
  WA_FLDC-COL_OPT   = 'X'.
  APPEND WA_FLDC TO T_FLDC.


  CLEAR WA_FLDC.
  WA_FLDC-FIELDNAME = 'ICONE_AT'.
  WA_FLDC-REPTEXT   = 'Status'.
  WA_FLDC-COL_OPT   = 'X'.
  APPEND WA_FLDC TO T_FLDC.

  CLEAR WA_FLDC.
  WA_FLDC-FIELDNAME = 'DATA'.
  WA_FLDC-REPTEXT   = 'Data ultima Modf.'.
  WA_FLDC-COL_OPT   = 'X'.
  APPEND WA_FLDC TO T_FLDC.

ENDFORM.                    " F_MONTA_ESTRUTURA
*&---------------------------------------------------------------------*
*&      Form  F_CALL_REPORT
*&---------------------------------------------------------------------*
FORM F_CALL_REPORT .
  IF OB_CC_VLD_ITEM IS NOT INITIAL.
    CALL METHOD OB_CC_VLD_ITEM->FREE.
  ENDIF.

  CREATE OBJECT OB_CC_VLD_ITEM
    EXPORTING
      CONTAINER_NAME = 'CL_GUI_ALV_GRID'.

  CREATE OBJECT OB_CC_GRID
    EXPORTING
      I_PARENT = OB_CC_VLD_ITEM.


  WA_LAY-STYLEFNAME = 'CELLTAB'.
  WA_LAY-CWIDTH_OPT = 'X'.
  WA_LAY-ZEBRA = 'X'.

  PERFORM F_SORT.

  CALL METHOD OB_CC_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT                     = WA_LAY
    CHANGING
      IT_OUTTAB                     = T_STATUS[]
      IT_FIELDCATALOG               = T_FLDC[]
      IT_SORT                       = T_SORT
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1
      PROGRAM_ERROR                 = 2
      TOO_MANY_LINES                = 3
      OTHERS                        = 4.

ENDFORM.                    " F_CALL_REPORT
*&---------------------------------------------------------------------*
*&      Form  F_SORT
*&---------------------------------------------------------------------*

FORM F_SORT .

* create sort-table
  WA_SORT-SPOS = 1.
  WA_SORT-FIELDNAME = 'DOCNR'.
  WA_SORT-UP = 'X'.
  APPEND WA_SORT TO T_SORT.

  WA_SORT-SPOS = 2.
  WA_SORT-FIELDNAME = 'PARID'.
  WA_SORT-UP = 'X'.
  APPEND WA_SORT TO T_SORT.
ENDFORM.                    " F_SORT
