*----------------------------------------------------------------------*
*                            H  O  M  I  N  E                          *
*                               Consulting                             *
*----------------------------------------------------------------------*
*              Relatório Status do fluxo do Documento                  *
*----------------------------------------------------------------------*
* RCP - Tradução EN/ES - 13/08/2018
*----------------------------------------------------------------------*
REPORT  ZHMS_REPORT_STATUS_TOT.

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

DATA: BEGIN OF T_STATUS01 OCCURS 0.     "with header line
        INCLUDE STRUCTURE ZHMS_ES_RP_STATUS01.
DATA: CELLTAB TYPE LVC_T_STYL.
DATA: END OF T_STATUS01.
*----------------------------------------------------------------------*
* Tabelas Internas                                                     *
*----------------------------------------------------------------------*
DATA: T_CABDOC      TYPE TABLE OF ZHMS_TB_CABDOC,
      T_GRPFLD_S    TYPE STANDARD TABLE OF ZHMS_TB_GRPFLD_S,
      T_TWHERE      TYPE RSDS_TWHERE,
      T_TABS        TYPE TABLE OF TY_TABS,
      T_FLDS        TYPE TABLE OF TY_FLDS,
      T_TEXPR       TYPE RSDS_TEXPR,
      T_TYPE_T      TYPE STANDARD TABLE OF ZHMS_TX_TYPE,
      T_FLWDOC      TYPE STANDARD TABLE OF ZHMS_TB_FLWDOC,
      T_STATUS      TYPE STANDARD TABLE OF ZHMS_ES_RP_STATUS,
      T_HVALID_FLDC TYPE LVC_T_FCAT,
      T_FLDC        TYPE LVC_T_FCAT,
      T_SORT        TYPE STANDARD TABLE OF LVC_S_SORT,

      T_LOGDOC     TYPE TABLE OF ZHMS_TB_LOGDOC.
*----------------------------------------------------------------------*
* Estruturas Internas                                                  *
*----------------------------------------------------------------------*
DATA: WA_GRPFLD_S    TYPE ZHMS_TB_GRPFLD_S,
      WA_TABS        TYPE TY_TABS,
      WA_FLDS        TYPE TY_FLDS,
      WA_TYPE_T      TYPE ZHMS_TX_TYPE,
      WA_TYPE        TYPE ZHMS_TB_TYPE,
      WA_FLWDOC      TYPE ZHMS_TB_FLWDOC,
      WA_CABDOC      TYPE ZHMS_TB_CABDOC,
      WA_STATUS01    LIKE LINE OF T_STATUS01,
      WA_TWHERE      LIKE LINE OF T_TWHERE,
      WA_HVALID_FLDC TYPE LVC_S_FCAT,
      WA_STATUS      LIKE ZHMS_ES_RP_STATUS,
      TY_LAY2        TYPE LVC_S_LAYO,
      WA_FLDC        TYPE LVC_S_FCAT,
      WA_LAY         TYPE LVC_S_LAYO,
      WA_SORT        TYPE LVC_S_SORT,

      WA_LOGDOC      TYPE ZHMS_TB_LOGDOC.

*----------------------------------------------------------------------*
* Variaveis                                                            *
*----------------------------------------------------------------------*
DATA: VG_SELID      TYPE RSDYNSEL-SELID,
      VG_ACTNUM     TYPE SY-TFILL,
      VG_TITLE      TYPE SY-TITLE,
      VG_FLOWD      TYPE ZHMS_DE_FLOWD,
      VG_ACTIONX    TYPE CHAR10,
      OK_CODE       TYPE SY-UCOMM,
      V_ICON_GREEN  TYPE ICON-ID,
      V_ICON_YELLOW TYPE ICON-ID,
      V_ICON_RED    TYPE ICON-ID,

      VG_FLOWDES    TYPE C LENGTH 50.



DATA: OB_CC_VLD_ITEM TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      OB_CC_VLD_parc TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      OB_CC_GRID     TYPE REF TO CL_GUI_ALV_GRID.


*local class to handle semantic checks
*CLASS LCL_EVENT_RECEIVER DEFINITION DEFERRED.

*&---------------------------------------------------------------------*
*&       Class LCL_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
CLASS LCL_HOTSPOT_CLICK DEFINITION.
  PUBLIC SECTION.
    METHODS:
    HANDLE_HOTSPOT_CLICK
    FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID IMPORTING E_ROW_ID.
ENDCLASS.               "LCL_HOTSPOT_CLICK

*----------------------------------------------------------------------*
*       CLASS lcl_hotspot_click IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS LCL_HOTSPOT_CLICK IMPLEMENTATION.
  METHOD HANDLE_HOTSPOT_CLICK.
    clear: WA_STATUS, t_status.
    refresh: t_STATUS.
    READ TABLE T_STATUS01 INTO WA_STATUS01 INDEX E_ROW_ID.

    IF SY-SUBRC IS INITIAL .
      LOOP AT T_CABDOC INTO WA_CABDOC where DOCNR  = WA_STATUS01-DOCNR
                                        and BUKRS  = WA_STATUS01-BUKRS
                                        and BRANCH = WA_STATUS01-BRANCH
                                        and PARID  = WA_STATUS01-PARID.
*** Verifica se ainda falta etapas para a nota
        LOOP AT T_FLWDOC INTO WA_FLWDOC  WHERE CHAVE = WA_CABDOC-CHAVE.
          DATA: lv_teste TYPE C length 350.
          LOOP AT T_LOGDOC INTO WA_LOGDOC WHERE CHAVE = WA_FLWDOC-CHAVE AND FLOWD = WA_FLWDOC-FLOWD.
            Data: gc_msgid type sy-msgid.

            IF WA_LOGDOC-LOGID EQ ''.
              gc_msgid = 'ZHMS_MC_LOGDOC'.
            ELSE.
              gc_msgid = WA_LOGDOC-LOGID.
            ENDIF.

            MESSAGE ID gc_msgid TYPE 'I' NUMBER wa_logdoc-logno WITH wa_logdoc-LOGV1 into lv_teste.

            MOVE lv_teste TO WA_STATUS-FLOWD_DES.
          ENDLOOP.


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
      if not T_STATUS[] is initial.
        sort t_STATUS by FLOWD_AT.
        call screen '0200' starting at 1 1.

      endif.
    ENDIF.

  ENDMETHOD.                    "handle_hotspot_click
ENDCLASS.               "LCL_HOTSPOT_CLICK

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

    SELECT *
  FROM ZHMS_TB_LOGDOC
  INTO TABLE T_LOGDOC
  FOR ALL ENTRIES IN T_FLWDOC
 WHERE CHAVE EQ T_FLWDOC-CHAVE
   AND FLOWD EQ T_FLWDOC-FLOWD.

    SORT T_FLWDOC DESCENDING BY FLOWD.

    CLEAR VG_FLOWD.
    LOOP AT T_CABDOC INTO WA_CABDOC.
      CLEAR VG_FLOWD.
      CLEAR VG_FLOWDES.

*** Verifica se ainda falta etapas para a nota
      READ TABLE T_FLWDOC INTO WA_FLWDOC  WITH KEY CHAVE = WA_CABDOC-CHAVE.


      IF SY-SUBRC IS INITIAL.

*** Busca maior etapa
        IF VG_FLOWD IS INITIAL.
          SELECT SINGLE MAX( FLOWD )
            INTO VG_FLOWD
            FROM ZHMS_TB_SCEN_FLO
           WHERE NATDC EQ WA_CABDOC-NATDC
             AND TYPED EQ WA_CABDOC-TYPED
             AND SCENA EQ WA_CABDOC-SCENA.
        ENDIF.

        IF SY-SUBRC IS INITIAL.
          IF WA_FLWDOC-FLWST = 'W'.
            WA_STATUS01-ICONE = V_ICON_YELLOW.
          ELSEIF WA_FLWDOC-FLWST = 'E' OR WA_FLWDOC-FLWST = 'C'.
            WA_STATUS01-ICONE = V_ICON_RED.
          ELSEIF WA_FLWDOC-FLWST = 'M' OR WA_FLWDOC-FLWST = 'A'.
            WA_STATUS01-ICONE = V_ICON_GREEN.
          ENDIF.
*          IF WA_FLWDOC-FLOWD < VG_FLOWD.
*            MOVE '@09@' TO WA_STATUS01-ICONE.
*          ELSEIF WA_FLWDOC-FLOWD EQ VG_FLOWD.
*            MOVE '@08@' TO WA_STATUS01-ICONE.
*          ENDIF.

        ELSE.
          MOVE '@09@' TO WA_STATUS01-ICONE.
        ENDIF.

*** Move Etapa final
        MOVE: VG_FLOWD         TO WA_STATUS01-FLOWD_FN,
              WA_FLWDOC-FLOWD  TO WA_STATUS01-FLOWD_AT.

      ELSE.
        MOVE '@09@' TO WA_STATUS01-ICONE.
        MOVE '10'   TO WA_STATUS01-FLOWD_AT.
        MOVE '20'   TO WA_STATUS01-FLOWD_FN.
      ENDIF.




      MOVE: WA_CABDOC-DOCNR  TO WA_STATUS01-DOCNR,
            WA_CABDOC-PARID  TO WA_STATUS01-PARID,
            WA_FLWDOC-DTREG  TO WA_STATUS01-DATA,
            WA_CABDOC-BUKRS  TO WA_STATUS01-BUKRS,
            WA_CABDOC-BRANCH TO WA_STATUS01-BRANCH,
            WA_CABDOC-TYPED TO WA_STATUS01-TYPED.

      IF WA_FLWDOC-DTREG IS INITIAL.
        MOVE WA_CABDOC-LNCDT TO WA_STATUS01-DATA.
      ENDIF.
      APPEND WA_STATUS01 TO T_STATUS01.
      CLEAR: WA_STATUS01, WA_FLWDOC.
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
*&      Form  F_MONTA_ESTRUTURA
*&---------------------------------------------------------------------*
FORM F_MONTA_ESTRUTURA .
  REFRESH T_HVALID_FLDC[].


  CLEAR WA_HVALID_FLDC.
  WA_HVALID_FLDC-FIELDNAME = 'ICONE'.
  WA_HVALID_FLDC-REPTEXT   = 'Status'.
  WA_HVALID_FLDC-COL_OPT   = 'X'.
  WA_HVALID_FLDC-JUST      = 'R'.
  APPEND WA_HVALID_FLDC TO T_HVALID_FLDC.


  CLEAR WA_HVALID_FLDC.
  WA_HVALID_FLDC-FIELDNAME = 'TYPED'.
  WA_HVALID_FLDC-REPTEXT   = 'Tipo'.
  WA_HVALID_FLDC-COL_OPT   = 'X'.
  WA_HVALID_FLDC-JUST      = 'R'.
  APPEND WA_HVALID_FLDC TO T_HVALID_FLDC.

  CLEAR WA_HVALID_FLDC.
  WA_HVALID_FLDC-FIELDNAME = 'DOCNR'.
  WA_HVALID_FLDC-REPTEXT   = 'Nº Documento'.
  WA_HVALID_FLDC-COL_OPT   = 'X'.
  WA_HVALID_FLDC-HOTSPOT   = 'X'.
  WA_HVALID_FLDC-JUST      = 'R'.
  APPEND WA_HVALID_FLDC TO T_HVALID_FLDC.

  CLEAR WA_HVALID_FLDC.
  WA_HVALID_FLDC-FIELDNAME = 'BUKRS'.
  WA_HVALID_FLDC-REPTEXT   = 'Empresa'.
  WA_HVALID_FLDC-COL_OPT   = 'X'.
  WA_HVALID_FLDC-JUST      = 'R'.
  APPEND WA_HVALID_FLDC TO T_HVALID_FLDC.

  CLEAR WA_HVALID_FLDC.
  WA_HVALID_FLDC-FIELDNAME = 'BRANCH'.
  WA_HVALID_FLDC-REPTEXT   = 'Filial'.
  WA_HVALID_FLDC-COL_OPT   = 'X'.
  WA_HVALID_FLDC-JUST      = 'R'.
  APPEND WA_HVALID_FLDC TO T_HVALID_FLDC.

  CLEAR WA_HVALID_FLDC.
  WA_HVALID_FLDC-FIELDNAME = 'PARID'.
  WA_HVALID_FLDC-REPTEXT   = 'Nº Fornecedor'.
  WA_HVALID_FLDC-COL_OPT   = 'X'.
  WA_HVALID_FLDC-JUST      = 'R'.
  APPEND WA_HVALID_FLDC TO T_HVALID_FLDC.

  CLEAR WA_HVALID_FLDC.
  WA_HVALID_FLDC-FIELDNAME = 'FLOWD_AT'.
  WA_HVALID_FLDC-REPTEXT   = 'Etapa Atual'.
  WA_HVALID_FLDC-COL_OPT   = 'X'.
  WA_HVALID_FLDC-JUST      = 'R'.
  APPEND WA_HVALID_FLDC TO T_HVALID_FLDC.

  CLEAR WA_HVALID_FLDC.
  WA_HVALID_FLDC-FIELDNAME = 'DATA'.
  WA_HVALID_FLDC-REPTEXT   = 'Data ultima Modf.'.
  WA_HVALID_FLDC-COL_OPT   = 'X'.
  WA_HVALID_FLDC-JUST      = 'R'.
  APPEND WA_HVALID_FLDC TO T_HVALID_FLDC.

  CLEAR WA_HVALID_FLDC.
  WA_HVALID_FLDC-FIELDNAME = 'FLOWD_FN'.
  WA_HVALID_FLDC-REPTEXT   = 'Prox. Etapa'.
  WA_HVALID_FLDC-COL_OPT   = 'X'.
  WA_HVALID_FLDC-JUST      = 'R'.
  APPEND WA_HVALID_FLDC TO T_HVALID_FLDC.



ENDFORM.                    " F_MONTA_ESTRUTURA
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS '0100'.
  SET TITLEBAR '0100'.
  DATA: EVENT_RECEIVER TYPE REF TO LCL_HOTSPOT_CLICK.
  PERFORM F_MONTA_ESTRUTURA.

  IF OB_CC_VLD_ITEM IS NOT INITIAL.
    CALL METHOD OB_CC_VLD_ITEM->FREE.
  ENDIF.

  CREATE OBJECT OB_CC_VLD_ITEM
    EXPORTING
      CONTAINER_NAME = 'CL_GUI_ALV_GRID'.

  CREATE OBJECT OB_CC_GRID
    EXPORTING
      I_PARENT = OB_CC_VLD_ITEM.

  TY_LAY2-STYLEFNAME = 'CELLTAB'.
  TY_LAY2-CWIDTH_OPT = 'X'.
  TY_LAY2-ZEBRA = 'X'.

  CALL METHOD OB_CC_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT                     = TY_LAY2
    CHANGING
      IT_OUTTAB                     = T_STATUS01[]
      IT_FIELDCATALOG               = T_HVALID_FLDC[]
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1
      PROGRAM_ERROR                 = 2
      TOO_MANY_LINES                = 3
      OTHERS                        = 4.

  CREATE OBJECT EVENT_RECEIVER.
  SET HANDLER EVENT_RECEIVER->HANDLE_HOTSPOT_CLICK FOR OB_CC_GRID.
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
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.
  SET PF-STATUS '0100'.
  SET TITLEBAR '0100'.

  PERFORM F_REPORT.

ENDMODULE.                 " STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  F_REPORT
*&---------------------------------------------------------------------*
FORM F_REPORT .

  PERFORM F_MONTA_ESTRUTURA_200.

  PERFORM F_CALL_REPORT.

ENDFORM.                    " F_REPORT
*&---------------------------------------------------------------------*
*&      Form  F_MONTA_ESTRUTURA_200
*&---------------------------------------------------------------------*
FORM F_MONTA_ESTRUTURA_200 .
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

  CLEAR WA_FLDC.
  WA_FLDC-FIELDNAME = 'FLOWD_DES'.
  WA_FLDC-REPTEXT   = 'Mensagem'.
  WA_FLDC-COL_OPT   = 'X'.
  APPEND WA_FLDC TO T_FLDC.
ENDFORM.                    " F_MONTA_ESTRUTURA_200
*&---------------------------------------------------------------------*
*&      Form  F_CALL_REPORT
*&---------------------------------------------------------------------*
FORM F_CALL_REPORT .
  IF OB_CC_VLD_parc IS NOT INITIAL.
    CALL METHOD OB_CC_VLD_parc->FREE.
  ENDIF.

  CREATE OBJECT OB_CC_VLD_parc
    EXPORTING
      CONTAINER_NAME = 'CL_GUI_ALV_GRID_2'.

  CREATE OBJECT OB_CC_GRID
    EXPORTING
      I_PARENT = OB_CC_VLD_parc.


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
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.
  OK_CODE = SY-UCOMM.

  CASE OK_CODE.
    WHEN 'EXIT'.
      LEAVE TO SCREEN 0.
    WHEN 'DETAILS'.
      " SUBMIT ZHMS_MONITOR_LITE.

      DATA wa_bdcdata type bdcdata.
      DATA t_bdcdata type table of bdcdata.

      clear WA_BDCDATA.
      WA_BDCDATA-PROGRAM = 'ZHMS_MONITOR_LITE'.
      WA_BDCDATA-DYNPRO = '1000'.
      WA_BDCDATA-DYNBEGIN = 'X'.
      APPEND wa_bdcdata TO t_bdcdata.

      CLEAR wa_bdcdata.
      wa_bdcdata-fnam  = 'S_DOCNR-LOW'.
      wa_bdcdata-fval   = '1908'.
      APPEND WA_BDCDATA TO T_BDCDATA.
      CLEAR WA_BDCDATA.

      wa_bdcdata-fnam  = 'BDC_OKCODE'.
      wa_bdcdata-fval   = 'ONLI'.
      APPEND WA_BDCDATA TO T_BDCDATA.



      CLEAR WA_BDCDATA.

      CALL TRANSACTION 'ZHMSLITE' USING T_BDCDATA.
  ENDCASE.

  CLEAR OK_CODE.
ENDMODULE.                 " USER_COMMAND_0200  INPUT
