FUNCTION-POOL ZHMS_FG_DATAENTRY_AUX MESSAGE-ID ZHMS_MS_MONITOR.

*** ---------------------------------------------------------------- ***
*** Tabelas
*** ---------------------------------------------------------------- ***
TABLES: ZHMS_TB_DTENT_CB,
        ZHMS_TB_DTENT_IT.


DATA:       T_LOG               TYPE TABLE OF ZEMM_DADOS_LOG,
            WA_LOG              TYPE ZEMM_DADOS_LOG.
*** ---------------------------------------------------------------- ***
*** Constante
*** ---------------------------------------------------------------- ***
DATA: C_CONTAINER        TYPE SCRFNAME VALUE 'C_LOG',
      C_GRID             TYPE REF TO CL_GUI_ALV_GRID,
      C_CUSTOM_CONTAINER TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      VG_0150        TYPE SY-DYNNR  VALUE '0151',
      VG_0151_INDEX  TYPE SY-DYNNR  VALUE '0160',
      VG_0151_LOGO   TYPE SY-DYNNR  VALUE '0170',
      VG_0152_INDEX  TYPE SY-DYNNR  VALUE '0160',
      VG_0152_DETAIL TYPE SY-DYNNR  VALUE '0101'.

*** ---------------------------------------------------------------- ***
*** Classes Locais: HTML Script's
*** ---------------------------------------------------------------- ***
CLASS LCL_HTML_SCRIPT DEFINITION INHERITING FROM CL_GUI_HTML_VIEWER.
  PUBLIC SECTION.
***     Método Construtor
    METHODS CONSTRUCTOR
              IMPORTING
                VALUE(PARENT) TYPE REF TO CL_GUI_CONTAINER
              EXCEPTIONS
                CNTL_ERROR.

***     Executo de JavaScript por Demanda
    METHODS RUN_SCRIPT_ON_DEMAND
              IMPORTING
                VALUE(SCRIPT) TYPE STANDARD TABLE.

***     Gerador de Documentos
    METHODS LOAD_BDS_DOC
              IMPORTING
                VALUE(DOC_NAME)        TYPE C
                VALUE(DOC_LANGU)       TYPE C OPTIONAL
                VALUE(DOC_DESCRIPTION) TYPE C OPTIONAL
                VALUE(BDS_OBJECTKEY)   TYPE C
                !VALUE(BDS_CLASSNAME)  TYPE C DEFAULT 'SAPHTML'
                !VALUE(BDS_CLASSTYP)   TYPE C DEFAULT 'OT'
              EXPORTING
                VALUE(ASSIGNED_URL)    TYPE C.

***     Gerador de Ícones
    METHODS LOAD_BDS_ICON
              IMPORTING
                VALUE(ICON_NAME) TYPE ICONNAME
              EXPORTING
                VALUE(ASSIGNED_URL) TYPE C
                VALUE(FILE_NAME)    TYPE C.
ENDCLASS.                    "lcl_html_script DEFINITION

*----------------------------------------------------------------------*
*   CLASS lcl_html_script IMPLEMENTATION
*----------------------------------------------------------------------*
*   Implementação da Classe para Execução de JavaScript
*----------------------------------------------------------------------*
CLASS LCL_HTML_SCRIPT IMPLEMENTATION.
***   ---------------------------------------------------------------- *
***   Método Construtor
***   ---------------------------------------------------------------- *
  METHOD CONSTRUCTOR.
    CALL METHOD SUPER->CONSTRUCTOR
      EXPORTING
        PARENT   = PARENT
        SAPHTMLP = 'X'
        UIFLAG   = CL_GUI_HTML_VIEWER=>UIFLAG_NOIEMENU
      EXCEPTIONS
        OTHERS   = 1.

    IF SY-SUBRC NE 0.
      RAISE CNTL_ERROR.
    ENDIF.
  ENDMETHOD.                    "lcl_html_script

***   ---------------------------------------------------------------- *
***   Executor de JavaScript
***   ---------------------------------------------------------------- *
  METHOD RUN_SCRIPT_ON_DEMAND.
    CALL METHOD ME->SET_SCRIPT
      EXPORTING
        SCRIPT = SCRIPT.

    CALL METHOD ME->EXECUTE_SCRIPT.

  ENDMETHOD.                    "lcl_html_script

***   ---------------------------------------------------------------- *
***   Carregando Documento
***   ---------------------------------------------------------------- *
  METHOD LOAD_BDS_DOC.
    CALL METHOD ME->LOAD_BDS_OBJECT
      EXPORTING
        DOC_NAME        = DOC_NAME
        DOC_LANGU       = DOC_LANGU
        DOC_DESCRIPTION = DOC_DESCRIPTION
        BDS_CLASSNAME   = BDS_CLASSNAME
        BDS_OBJECTKEY   = BDS_OBJECTKEY
      IMPORTING
        ASSIGNED_URL    = ASSIGNED_URL
      EXCEPTIONS
        OTHERS          = 1.
  ENDMETHOD.                    "lcl_html_script

***   ---------------------------------------------------------------- *
***   Carregando Ícones
***   ---------------------------------------------------------------- *
  METHOD LOAD_BDS_ICON.
    CALL METHOD ME->LOAD_BDS_SAP_ICON
      EXPORTING
        SAP_ICON     = ICON_NAME
      IMPORTING
        ASSIGNED_URL = ASSIGNED_URL
        FILE_NAME    = FILE_NAME
      EXCEPTIONS
        OTHERS       = 1.
  ENDMETHOD.                    "lcl_html_script
ENDCLASS.                    "lcl_html_script IMPLEMENTATION

*** ---------------------------------------------------------------- ***
*** Classes Locais: SAP Evento HTML
*** ---------------------------------------------------------------- ***
CLASS LCL_EVENT_HANDLER DEFINITION.
  PUBLIC SECTION.
    METHODS ON_SAPEVENT FOR EVENT SAPEVENT OF CL_GUI_HTML_VIEWER
                        IMPORTING ACTION
                                  FRAME
                                  GETDATA
                                  POSTDATA
                                  QUERY_TABLE.
ENDCLASS.               "LCL_EVENT_HANDLER


*----------------------------------------------------------------------*
*       CLASS lcl_event_handler IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS LCL_EVENT_HANDLER IMPLEMENTATION.
***   ---------------------------------------------------------------- *
***   Implementação da Classe de Eventos do HTML
***   ---------------------------------------------------------------- *
  METHOD ON_SAPEVENT.
    DATA: V_POSTDATA TYPE STRING.
    CLEAR V_POSTDATA.

    IF NOT ACTION IS INITIAL.
      CASE ACTION.
        WHEN OTHERS.
***           Recupera índice selecionados
          PERFORM F_SET_INDEX_LINE USING ACTION.
      ENDCASE.
    ENDIF.
  ENDMETHOD.                    "lcl_event_handler
ENDCLASS.               "lcl_event_handler
*----------------------------------------------------------------------*
*       CLASS lcl_hotspot_click DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS ZCL_EVENT_HANDLER DEFINITION.     " To handle events of first screen oops alv
  PUBLIC SECTION.
    METHODS:
    HANDLE_HOTSPOT_CLICK FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
                         IMPORTING E_ROW_ID E_COLUMN_ID,

*method used for double click
    HANDLE_DOUBLE_CLICK
        FOR EVENT DOUBLE_CLICK OF CL_GUI_ALV_GRID
            IMPORTING E_ROW E_COLUMN.

ENDCLASS.                    "Zcl_event_handler DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_hotspot_click IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS ZCL_EVENT_HANDLER IMPLEMENTATION.

  METHOD HANDLE_HOTSPOT_CLICK.

    IF E_COLUMN_ID = 'DOC_MIGO'.
      PERFORM Z_CALL_TRANSACTION USING E_ROW_ID.   " Subroutine to handle hotspot on customer number
    ENDIF.

    IF E_COLUMN_ID = 'DOC_MIRO'.
      PERFORM Z_CALL_TRANSACTION_2 USING E_ROW_ID.   " Subroutine to handle hotspot on customer number
    ENDIF.

  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK

  METHOD  HANDLE_DOUBLE_CLICK.


  ENDMETHOD.                    "handle_double_click

ENDCLASS.                    "ZCL_EVENT_HANDLER IMPLEMENTATION
DATA: OB_TIMER      TYPE REF TO CL_GUI_TIMER.
DATA EVENT_RECEIVER TYPE REF TO ZCL_EVENT_HANDLER.
*-----------------------------------------------*
* CLASS lcl_receiver DEFINITION
*-----------------------------------------------*
* Timer para atualização do monitor
*-----------------------------------------------*
CLASS LCL_RECEIVER DEFINITION.
  PUBLIC SECTION.
    METHODS:
    HANDLE_FINISHED FOR EVENT FINISHED OF CL_GUI_TIMER.

    METHODS :
        HANDEL_HOTSPOT_CLICK
          FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
          IMPORTING E_ROW_ID E_COLUMN_ID.

ENDCLASS.                    "lcl_receiver DEFINITION
DATA: OB_CC_XML_GRID   TYPE REF TO CL_GUI_ALV_GRID,
      OB_CC_COMP_GRID  TYPE REF TO CL_GUI_ALV_GRID.
*------------------------------------------------*
* CLASS lcl_receiver IMPLEMENTATION
*------------------------------------------------*
CLASS LCL_RECEIVER IMPLEMENTATION.
  METHOD HANDLE_FINISHED.
***     Atualizar os status dos documentos
*        PERFORM f_refresh_docs_status.
    CALL METHOD OB_TIMER->RUN.
  ENDMETHOD.                    "handle_finished

*-----Logic to handle the HOTSPOT click
  METHOD HANDEL_HOTSPOT_CLICK.
*---To handel hotspot in the firstlist
    PERFORM HANDEL_HOTSPOT_CLICK USING E_ROW_ID E_COLUMN_ID.
    CALL METHOD OB_CC_XML_GRID->REFRESH_TABLE_DISPLAY.
    CALL METHOD OB_CC_COMP_GRID->REFRESH_TABLE_DISPLAY.

  ENDMETHOD.                    "HANDEL_HOTSPOT_CLICK
ENDCLASS.                    "lcl_receiver IMPLEMENTATION

*** ---------------------------------------------------------------- ***
*** Objetos
*** ---------------------------------------------------------------- ***
DATA: OB_CC_HTML_DATAENTRY   TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      OB_HTML_DATAENTRY      TYPE REF TO LCL_HTML_SCRIPT,
      OB_RECEIVER            TYPE REF TO LCL_EVENT_HANDLER,
      OB_CC_PDF_DOCS   TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      OB_PDF_DOCS      TYPE REF TO CL_GUI_HTML_VIEWER.

*** ---------------------------------------------------------------- ***
*** Objetos
*** ---------------------------------------------------------------- ***
DATA: OB_CC_LOGOTIPO   TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      OB_LOGOTIPO      TYPE REF TO CL_GUI_PICTURE,
      OB_CC_IMG_DOCS   TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      OB_IMG_DOCS      TYPE REF TO CL_GUI_PICTURE,
      OB_CC_HTML_INDEX TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      OB_HTML_INDEX    TYPE REF TO CL_GUI_HTML_VIEWER,
      OB_CC_HTML_DOCS  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      OB_HTML_DOCS     TYPE REF TO LCL_HTML_SCRIPT,
      OB_CC_HTML_DET   TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      OB_HTML_DET      TYPE REF TO LCL_HTML_SCRIPT,
      OB_CC_HTML_RCP   TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      OB_HTML_RCP      TYPE REF TO LCL_HTML_SCRIPT,
      OB_CC_XML_DOCS   TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      OB_XML_DOCS      TYPE REF TO CL_GUI_ALV_TREE,
      OB_CC_VIS_ITENS  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      OB_VIS_ITENS     TYPE REF TO CL_GUI_ALV_TREE,
      OB_CC_ATR_ITENS  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      OB_ATR_ITENS     TYPE REF TO CL_GUI_ALV_TREE,

      OB_VALID         TYPE REF TO CL_GUI_COLUMN_TREE,
      OB_CC_VALID      TYPE REF TO CL_GUI_CUSTOM_CONTAINER,

*** Inicio inclusão David Rosin 11/2014
      OB_TREE_VALID      TYPE REF TO CL_GUI_ALV_TREE,
      OB_CC_VALID_ITENS  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
*** Fim Inclusão David Rosin 11/2014

      OB_CC_TB_DOCS    TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      OB_TB_DOCS       TYPE REF TO CL_GUI_TOOLBAR,
      OB_MENU_DOCS     TYPE REF TO CL_CTMENU,
      OB_CC_TB_DET     TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      OB_TB_DET        TYPE REF TO CL_GUI_TOOLBAR,
      OB_MENU_DET      TYPE REF TO CL_CTMENU,

      OB_TIMER_EVENT   TYPE REF TO LCL_RECEIVER,
      OB_CC_VLD_HVALID TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      OB_HVALID        TYPE REF TO CL_GUI_ALV_TREE,
      OB_FLOW          TYPE REF TO CL_GUI_COLUMN_TREE,
      OB_HVALID_EVENT  TYPE REF TO LCL_RECEIVER,
      OB_REF_CONSUMER  TYPE REF TO CL_GUI_PROPS_CONSUMER,
      OB_DCEVT_OBS     TYPE REF TO CL_GUI_TEXTEDIT,
      OB_CC_DCEVT_OBS  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      OB_CC_DET_FLOW   TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      OB_CC_VLD_ITEM   TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      OB_CC_GRID       TYPE REF TO CL_GUI_ALV_GRID,
      OB_CC_VLD_HEAD   TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      OB_CC_GRID_HEAD  TYPE REF TO CL_GUI_ALV_GRID,
      OB_HT_OBJECT     TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET,
      OB_CC_HT         TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      OB_CC_HT_GRID    TYPE REF TO CL_GUI_ALV_GRID,
      OB_CC_PED        TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      OB_CC_PED_GRID   TYPE REF TO CL_GUI_ALV_GRID,
      OB_CC_XML        TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
      OB_CC_COMP       TYPE REF TO CL_GUI_CUSTOM_CONTAINER.



*** ---------------------------------------------------------------- ***
*** Types
*** ---------------------------------------------------------------- ***
TYPES: HTML_DSO_LINE(250) TYPE C.
*** Tipos para Carregar arquivo Excel
TYPES TRUXS_T_TEXT_DATA(4096) TYPE C OCCURS 0.

TYPES: BEGIN OF TP_EXC,
        CAMPO1  TYPE STRING,
        CAMPO2  TYPE STRING,
        CAMPO3  TYPE STRING,
        CAMPO4  TYPE STRING,
        CAMPO5  TYPE STRING,
        CAMPO6  TYPE STRING,
        CAMPO7  TYPE STRING,
        CAMPO8  TYPE STRING,
        CAMPO9  TYPE STRING,
        CAMPO10 TYPE STRING,
  END OF TP_EXC.

TYPES: BEGIN OF TY_ITEM,
          EBELN TYPE ZHMS_TB_DTENT_IT-EBELN,
          EBELP TYPE ZHMS_TB_DTENT_IT-EBELP,
          MATNR TYPE ZHMS_TB_DTENT_IT-MATNR,
          TXZ01 TYPE ZHMS_TB_DTENT_IT-TXZ01,
          MENGE TYPE ZHMS_TB_DTENT_IT-MENGE,
          MEINS TYPE ZHMS_TB_DTENT_IT-MEINS,
          NETWR TYPE ZHMS_TB_DTENT_IT-NETWR,
          NETPR TYPE ZHMS_TB_DTENT_IT-NETPR,
          PEINH TYPE ZHMS_TB_DTENT_IT-PEINH,
          BUKRS TYPE ZHMS_TB_DTENT_IT-BUKRS,
          WERKS TYPE ZHMS_TB_DTENT_IT-WERKS,
          MATKL TYPE ZHMS_TB_DTENT_IT-MATKL,
          SEL   TYPE C,
       END OF TY_ITEM,

       BEGIN OF TY_LIFNR,
         EBELN TYPE EKKO-EBELN,
         LIFNR TYPE EKKO-LIFNR,
       END OF TY_LIFNR,

       BEGIN OF TY_EKKO,
       EBELN TYPE EKKO-EBELN,
       LIFNR TYPE EKKO-LIFNR,
       BUKRS TYPE EKKO-BUKRS,
       AEDAT TYPE EKKO-AEDAT,
       EKGRP TYPE EKKO-EKGRP,
       EKORG TYPE EKKO-EKORG,
       END OF TY_EKKO,

       BEGIN OF TY_LOG,
       DATA TYPE SY-DATUM,
       HORA TYPE SY-DATUM,
       USUARIO TYPE SY-UNAME,
       DOC_MIGO TYPE MKPF-MBLNR,
       DOC_MIRO TYPE MKPF-MBLNR,
       EST_MIGO TYPE MKPF-MBLNR,
       EST_MIRO TYPE MKPF-MBLNR,
       END OF TY_LOG,

      BEGIN OF TY_EKET,
      EBELN TYPE EKET-EBELN,
      EBELP TYPE EKET-EBELP,
      ETENR TYPE EKET-ETENR,
      MENGE TYPE EKET-MENGE,
      WEMNG TYPE EKET-WEMNG,
      WAMNG TYPE EKET-WAMNG,
      END OF TY_EKET,

     BEGIN OF TY_ALV_AUDI,
      ITEM        TYPE C LENGTH 5,
      DESC        TYPE C LENGTH 255,
      UNIDADE     TYPE C LENGTH 10,
      QTDE        TYPE C LENGTH 10,
      VPROD       TYPE C LENGTH 10,
      PICMS       TYPE C LENGTH 8,
      VICMS       TYPE C LENGTH 8,
      PIPI        TYPE C LENGTH 8,
      VIPI        TYPE C LENGTH 8,
      PPIS        TYPE C LENGTH 8,
      VPIS        TYPE C LENGTH 8,
      PCOFINS     TYPE C LENGTH 8,
      VCOFINS     TYPE C LENGTH 8,
           END OF TY_ALV_AUDI,

   BEGIN OF TY_ZTERM,
      ZTERM       TYPE EKKO-ZTERM,
   END OF TY_ZTERM,

       BEGIN OF TY_ALV_PED_XML,
      ITEM        TYPE C LENGTH 5,
      IMPO        TYPE C LENGTH 10,
      BASEPED     TYPE C LENGTH 8,
      VALOR       TYPE C LENGTH 10, "wemng,
      BASEXML     TYPE C LENGTH 8,
      VALOR2      TYPE C LENGTH 10, "wemng,
      FAROL       TYPE C,
      UNIT_PED    TYPE EKPO-NETWR,
      UNIT_XML    TYPE EKPO-NETWR,
           END OF TY_ALV_PED_XML.

TYPES: BEGIN OF TY_FLDS.
        INCLUDE STRUCTURE RSDSFIELDS.
TYPES: END OF TY_FLDS.

TYPES: BEGIN OF TY_SHOW.
        INCLUDE STRUCTURE ZHMS_ES_SHOW_POSS_PO.
TYPES: TXZ01 TYPE ZHMS_TB_DTENT_IT-TXZ01,
       MEINS TYPE ZHMS_TB_DTENT_IT-MEINS,
       NETWR TYPE ZHMS_TB_DTENT_IT-NETWR,
       NETPR TYPE ZHMS_TB_DTENT_IT-NETPR,
       PEINH TYPE ZHMS_TB_DTENT_IT-PEINH,
       BUKRS TYPE ZHMS_TB_DTENT_IT-BUKRS,
       WERKS TYPE ZHMS_TB_DTENT_IT-WERKS,
       MATKL TYPE ZHMS_TB_DTENT_IT-MATKL.
TYPES: END OF TY_SHOW.

TYPES: BEGIN OF TY_SELEC,
       SEQNR     TYPE ZHMS_TB_DTENT_CB-SEQNR,
       STCD1     TYPE ZHMS_TB_DTENT_CB-STCD1,
       DTDOC     TYPE ZHMS_TB_DTENT_CB-DTDOC,
       NFNUM     TYPE ZHMS_TB_DTENT_CB-NFNUM,
       DTCRIACAO TYPE ZHMS_TB_DTENT_CB-DTCRIACAO,
       SEL       TYPE C,
  END OF TY_SELEC.

TYPES: BEGIN OF  TY_KONV.
        INCLUDE STRUCTURE KONV.
TYPES: SEL TYPE C,
END OF TY_KONV.

TYPES: BEGIN OF TY_TABS.
        INCLUDE STRUCTURE RSDSTABS.
TYPES: END OF TY_TABS.

TYPES: BEGIN OF TY_LOGDOC,
           CHECK TYPE FLAG,
           ICON  TYPE ICON_D,
           LTEXT TYPE ZHMS_DE_LTEXT.
        INCLUDE STRUCTURE ZHMS_TB_LOGDOC.
TYPES: END OF TY_LOGDOC.

*** ---------------------------------------------------------------- ***
*** Tabelas Internas
*** ---------------------------------------------------------------- ***
DATA: BEGIN OF ITAB OCCURS 0,
FIELD(256),
END OF ITAB.

DATA: T_EVENTS            TYPE CNTL_SIMPLE_EVENTS,
      T_WWWDATA           TYPE TABLE OF WWWDATA,
      T_DATASRC           TYPE TABLE OF HTML_DSO_LINE INITIAL SIZE 20,
      T_SRSCD_EV          TYPE W3HTMLTAB,
      T_SRSCD             TYPE STANDARD TABLE OF ZHMS_ST_HTML_SRSCD,
      IT_TP_EXC           TYPE STANDARD TABLE OF TP_EXC,

      T_MATCHCODE         TYPE TABLE OF TY_EKET,
      T_ITEM_AUX          TYPE TABLE OF TY_ITEM,
      T_ITEM              TYPE TABLE OF TY_ITEM,
      T_EKET              TYPE TABLE OF EKET,
      T_LIFNR             TYPE TABLE OF TY_LIFNR,
      T_LFA1              TYPE TABLE OF LFA1,
      T_POHEADER          TYPE TABLE OF BAPIMEPOHEADER,
      T_POEXPIMPHEADER    TYPE TABLE OF BAPIEIKP,
      T_RETURN            TYPE TABLE OF BAPIRET2,
      T_RETURN_C          TYPE TABLE OF BAPIRET2,
      T_BAPI_RET          TYPE TABLE OF BAPIRET2,
      T_RET               TYPE TABLE OF BAPIRET2,
      T_POITEM            TYPE TABLE OF BAPIMEPOITEM,
      T_ITENS             TYPE TABLE OF BAPIEKPOC,
      T_SCH_ITENS         TYPE TABLE OF BAPIEKET,
      T_GOODSMVT_ITEM     TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
      T_MSGDATA           TYPE TABLE OF ZHMS_ES_MSGDT,
      T_MSGATRB           TYPE TABLE OF ZHMS_ES_MSGAT,
      T_ITEMDATA          TYPE TABLE OF BAPI_INCINV_DETAIL_ITEM,
      T_ITEMDATA_2        TYPE TABLE OF BAPI_INCINV_CREATE_ITEM,
      T_ACC               TYPE TABLE OF BAPI_INCINV_CREATE_ACCOUNT,
      T_TAXDATA           TYPE TABLE OF BAPI_INCINV_CREATE_TAX,
      T_ACCOUNT           TYPE TABLE OF BAPIMEPOACCOUNT,
      T_ITEM_PED          TYPE TABLE OF BAPIMEPOITEM,
      T_FIELDCAT          TYPE LVC_T_FCAT,
      T_EKKO              TYPE TABLE OF TY_EKKO,
      T_RET_TAB           TYPE TABLE OF DDSHRETVAL,
      T_MAPCONEC          TYPE TABLE OF ZHMS_TB_MAPCONEC,
      T_SHOW_PO           TYPE TABLE OF TY_SHOW,
      T_FLDS              TYPE TABLE OF TY_FLDS,
      T_GRPFLD_S          TYPE STANDARD TABLE OF ZHMS_TB_GRPFLD_S,
      T_TEXPR             TYPE RSDS_TEXPR,
      T_TABS              TYPE TABLE OF TY_TABS,
      T_TWHERE            TYPE RSDS_TWHERE,
      T_SELEC             TYPE TABLE OF TY_SELEC,
      LT_DYNPFIELDS       LIKE DYNPREAD OCCURS 5 WITH HEADER LINE,
      T_NATURE            TYPE STANDARD TABLE OF ZHMS_TB_NATURE,
      T_NATURE_T          TYPE STANDARD TABLE OF ZHMS_TX_NATURE,
      T_INDEX             TYPE STANDARD TABLE OF ZHMS_ST_HTML_INDEX,
      T_TYPE_T            TYPE STANDARD TABLE OF ZHMS_TX_TYPE,
      T_TYPE              TYPE STANDARD TABLE OF ZHMS_TB_TYPE,
      T_ALV_XML           TYPE TABLE OF TY_ALV_AUDI,
      T_ALV_PED           TYPE TABLE OF TY_ALV_PED_XML,
      T_ALV_PED_AUX       TYPE TABLE OF TY_ALV_PED_XML,
      T_ALV_COMP          TYPE TABLE OF TY_ALV_PED_XML,
      T_ALV_COMP_AU       TYPE TABLE OF TY_ALV_PED_XML,
      LS_SHOW_LAY         TYPE ZHMS_TB_SHOW_LAY,
      T_CODES             TYPE TABLE OF SY-UCOMM,
      T_ITEM_IT           TYPE TABLE OF ZHMS_TB_DTENT_IT,
      T_ZTERM             TYPE TABLE OF TY_ZTERM,
      T_DOCMN             TYPE TABLE OF ZHMS_TB_DOCMN,
      T_DOCMN_AUX         TYPE TABLE OF ZHMS_TB_DOCMN,
      T_CHAVE_NF          TYPE TABLE OF ZHMS_TB_DOCMN,
      T_DOCUM             TYPE TABLE OF ZHMS_ES_DOCUM,
      T_MAPPING           TYPE STANDARD TABLE OF ZHMS_TB_MAPDATA,
      T_LOGDOC            TYPE TABLE OF ZHMS_TB_LOGDOC,
      T_LOGDOC_AUX        TYPE TABLE OF TY_LOGDOC,
      T_SCENFLOX          TYPE TABLE OF ZHMS_TX_SCEN_FLO.

*** ---------------------------------------------------------------- ***
*** Work Areas
*** ---------------------------------------------------------------- ***
DATA: WA_EVENT            TYPE CNTL_SIMPLE_EVENT,
      WA_WWWDATA          TYPE WWWDATA,
      WA_DATASRC          TYPE HTML_DSO_LINE,
      WA_SRSCD            TYPE ZHMS_ST_HTML_SRSCD,
      WA_SHOW_LAY         TYPE ZHMS_TB_SHOW_LAY,
      WA_TP_EXC           TYPE TP_EXC,
      WA_ITEM             TYPE TY_ITEM,
      WA_LIFNR            TYPE TY_LIFNR,
      WA_LFA1             TYPE LFA1,
      WA_MATCHCODE        TYPE TY_EKET,
      WA_HEADER           TYPE BAPIEKKOC,
      WA_HEADERDATA       TYPE BAPI_INCINV_DETAIL_HEADER,
      WA_HEADERDATA_2	    TYPE BAPI_INCINV_CREATE_HEADER,
      WA_EKET             TYPE EKET,
      WA_BAPI_RET         TYPE BAPIRET2,
      WA_ACC              TYPE BAPI_INCINV_CREATE_ACCOUNT,
      WA_ITEMDATA         TYPE BAPI_INCINV_CREATE_ITEM,
      WA_TAXDATA          TYPE BAPI_INCINV_CREATE_TAX,
      WA_DOC              TYPE BAPI2017_GM_HEAD_01,
      WA_DOC2             TYPE BAPI2017_GM_CODE,
      WA_ACCOUNT          TYPE BAPIMEPOACCOUNT,
      WA_ITEM_PED         TYPE  BAPIMEPOITEM,
      WA_FIELDCAT         TYPE LVC_S_FCAT,
      WA_LAYOUT           TYPE LVC_S_LAYO,
      WA_EKKO             TYPE TY_EKKO,
      WA_RET_TAB          TYPE DDSHRETVAL,
      WA_GOODSMVT_HEADER  TYPE BAPI2017_GM_HEAD_01,
      WA_GOODSMVT_ITEM    TYPE BAPI2017_GM_ITEM_CREATE,
      WA_GM_CODE          TYPE BAPI2017_GM_CODE,
      WA_KONV             TYPE ZESD_KONV,
      WA_DADOS_XML        TYPE ZESD_DADOS_XML_TOM,
      WA_CABDOC           TYPE ZHMS_TB_CABDOC,
      WA_REPDOC           TYPE ZHMS_TB_REPDOC,
      WA_DOCMN            TYPE ZHMS_TB_DOCMN,
      WA_DOCMN_AUX        TYPE ZHMS_TB_DOCMN,
      WA_DOCST            TYPE ZHMS_TB_DOCST,
      WA_REPDOCAT         TYPE ZHMS_TB_REPDOCAT,
      WA_DOCMNA           TYPE ZHMS_TB_DOCMNA,
      WA_MAPCONEC         TYPE ZHMS_TB_MAPCONEC,
      WA_SHOW_PO          TYPE TY_SHOW,
      WA_FLDS             TYPE TY_FLDS,
      WA_TABS             TYPE TY_TABS,
      WA_SELEC            TYPE TY_SELEC,
      WA_NATURE           TYPE ZHMS_TB_NATURE,
      WA_NATURE_T         TYPE ZHMS_TX_NATURE,
      WA_INDEX            TYPE ZHMS_ST_HTML_INDEX,
      WA_TYPE             TYPE ZHMS_TB_TYPE,
      WA_TYPE_T           TYPE ZHMS_TX_TYPE,
      WA_ALV_XML          TYPE TY_ALV_AUDI,
      WA_ALV_PED          TYPE TY_ALV_PED_XML,
      WA_ALV_COMP         TYPE TY_ALV_PED_XML,
      WA_TWHERE           LIKE LINE OF T_TWHERE,
      WA_ITEM_AUX         TYPE ZHMS_TB_DTENT_IT,
      WA_ITEM_IT          TYPE ZHMS_TB_DTENT_IT,
      WA_ZTERM            TYPE TY_ZTERM,
      WA_ITMDOC           TYPE ZHMS_TB_ITMDOC,
      WA_ITMATR           TYPE ZHMS_TB_ITMATR,
      WA_DOCUM            TYPE ZHMS_ES_DOCUM,
      WA_MAPPING          TYPE ZHMS_TB_MAPDATA,
      WA_DTENT_CB         TYPE ZHMS_TB_DTENT_CB,
      WA_FLWDOC           TYPE ZHMS_TB_FLWDOC,
      WA_LOGDOC           TYPE ZHMS_TB_LOGDOC,
      WA_LOGDOC_AUX       TYPE TY_LOGDOC,
      WA_SCENFLOX         TYPE ZHMS_TX_SCEN_FLO,
      WA_GRPFLD_S         TYPE ZHMS_TB_GRPFLD_S.

*** ---------------------------------------------------------------- ***
*** Variaveis
*** ---------------------------------------------------------------- ***
DATA: VG_URL              TYPE CNDP_URL,
      OK_CODE             TYPE SY-UCOMM,
      P_ENTR              TYPE RLGRAP-FILENAME,
      FILENAME            TYPE STRING,
      LENGTH              LIKE SY-TABIX,
      LENGTHN             LIKE SY-TABIX,
      V_EBELN             TYPE EKKO-EBELN,
      V_PEDIDO            TYPE BAPIMEPOHEADER,
      V_VALOR_TOTAL       TYPE EKPO-NETWR,
      V_VLTOTPED          TYPE EKPO-NETWR,
      V_FRETE             TYPE EKPO-NETWR,
      V_FLAG              TYPE C,
      V_SEGUROS           TYPE EKPO-NETWR,
      V_DESP              TYPE EKPO-NETWR,
      V_REDUCAO           TYPE EKPO-NETWR,
      V_EXE_ICMS          TYPE EKPO-NETWR,
      V_VALOR             TYPE EKPO-NETWR,
      V_VALORT            TYPE EKPO-NETWR,
      V_DATA_PAGTO        TYPE EKKO-AEDAT,
      V_MOVTO             TYPE MSEG-BWART VALUE '101',
      V_PO                TYPE BAPIEKKOC-PO_NUMBER,
      V_WAIT              TYPE BAPITA-WAIT,
      V_MATERIALDOCUMENT  TYPE  BAPI2017_GM_HEAD_RET-MAT_DOC,
      V_MSG               TYPE CHAR255,
      V_MATDOCUMENTYEAR   TYPE  BAPI2017_GM_HEAD_RET-DOC_YEAR,
      V_INVOICEDOCNUMBER  TYPE  BAPI_INCINV_FLD-INV_DOC_NO,
      V_FISCALYEAR        TYPE  BAPI_INCINV_FLD-FISC_YEAR,
      V_NUM_DOC           TYPE J_1BNFDOC-NFENUM,
      V_CHAVE             TYPE ZHMS_DE_CHAVE,
      V_DATA_DOC          TYPE EKKO-AEDAT,
      V_SEQNR             TYPE ZHMS_TB_DTENT_CB-SEQNR,
      V_PEDANT            TYPE EKKO-EBELN,
      V_SELID             TYPE RSDYNSEL-SELID,
      V_ACTNUM            TYPE SY-TFILL,
      V_TITLE             TYPE SY-TITLE,
      VG_EDURL(2048)      TYPE C,
      VG_ICON_ID          TYPE CNDP_URL,
      VG_ICON_URL         TYPE CNDP_URL,
      VG_STATUS           TYPE STRING,
      VG_QTSEL            TYPE SY-TABIX,
      VG_CHAVE_SEL        TYPE ZHMS_DE_CHAVE,
      VG_CHAVE_MAIN       TYPE ZHMS_DE_CHAVE,
      VG_NATDC            TYPE ZHMS_DE_NATDC,
      VG_TYPED            TYPE ZHMS_DE_TYPED,
      VG_LOCTP            TYPE ZHMS_DE_LOCTP,
      VG_EVENT            TYPE ZHMS_DE_EVENT,
      VG_VERSN            TYPE ZHMS_DE_VERSN,
      VG_VLD_SHWHST       TYPE FLAG,
      VL_TYPED            TYPE ZHMS_TB_TYPE-TYPED,
      VL_RETORNO(1)       TYPE C,
      VG_CHAVE            TYPE ZHMS_TB_DOCMN-CHAVE,
      VG_CHAVE_ANT        TYPE ZHMS_TB_DOCMN-CHAVE,
      VG_NOTA(9)          TYPE C,
      VG_SEQNR            TYPE ZHMS_TB_DOCMN-SEQNR,
      VG_ATITM            TYPE ZHMS_TB_DOCMN-ATITM,
      VG_ATITMPROC(5)     TYPE C,
      VG_ERRO(1)          TYPE C,
      INPUT_OUTPUT(20)    TYPE C,
      FLD(50)             TYPE C,
      FLD_S(50)           TYPE C,
      OFF                 TYPE I,
      VAL(40)             TYPE C,
      LIN                 TYPE I,
      LIN_S                TYPE I,
      LEN                 TYPE I,
      VG_FLOWD            TYPE ZHMS_DE_FLOWD,
      V_LIFNR             TYPE EKKO-LIFNR,
      V_STCD1             TYPE LFA1-STCD1.

DATA: VL_NOTA      TYPE ZHMS_TB_DOCMN-VALUE,
      VL_SERIE     TYPE ZHMS_TB_DOCMN-VALUE,
      VL_NF_HMS(1) TYPE C.
*** ---------------------------------------------------------------- ***
*** Declaração de Tela
*** ---------------------------------------------------------------- ***

CONTROLS: TC_ITEM     TYPE TABLEVIEW USING SCREEN 0101,
          TC_COND     TYPE TABLEVIEW USING SCREEN 0103,
          TC_ATR_PED  TYPE TABLEVIEW USING SCREEN 0111,
          TC_SELECT   TYPE TABLEVIEW USING SCREEN 0140,
          TC_ATR_ITEM TYPE TABLEVIEW USING SCREEN 0111,
          TC_LOGDOC   TYPE TABLEVIEW USING SCREEN 0300.


DATA:     G_TC_ATR_ITEM_LINES LIKE SY-LOOPC,
          G_TC_ATR_PED_LINES  LIKE SY-LOOPC.
