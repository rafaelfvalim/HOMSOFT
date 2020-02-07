*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_DATAENTRYF01 .
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*   Form  F_LOAD_IMAGES_DATAENTRY
*----------------------------------------------------------------------*
*   Carregando Imagens e Ícones - Documentos
*----------------------------------------------------------------------*
    FORM F_LOAD_IMAGES_DATAENTRY USING P_ID
                                  P_URL.
***   ICON RATING NEUTRAL
      CALL METHOD OB_HTML_DATAENTRY->LOAD_MIME_OBJECT
        EXPORTING
          OBJECT_ID            = P_ID
          OBJECT_URL           = P_URL
        EXCEPTIONS
          OBJECT_NOT_FOUND     = 1
          DP_INVALID_PARAMETER = 1
          DP_ERROR_GENERAL     = 3
          OTHERS               = 4.

      IF SY-SUBRC NE 0.
***     Erro Interno. Contatar Suporte.
        MESSAGE E000 WITH TEXT-000.
      ENDIF.
    ENDFORM.                    " F_LOAD_IMAGES_DATAENTRY
*----------------------------------------------------------------------*
*   Form  F_REG_EVENTS_det
*----------------------------------------------------------------------*
*   Registrando Eventos do HTML Documentos
*----------------------------------------------------------------------*
    FORM F_REG_EVENTS_DATAENTRY.
***   Obtendo Eventos
      REFRESH T_EVENTS.
      CLEAR   WA_EVENT.
      MOVE:   OB_HTML_DATAENTRY->M_ID_SAPEVENT TO WA_EVENT-EVENTID,
              'X'                         TO WA_EVENT-APPL_EVENT.
      APPEND  WA_EVENT TO T_EVENTS.

***   Registrando Eventos
      CALL METHOD OB_HTML_DATAENTRY->SET_REGISTERED_EVENTS
        EXPORTING
          EVENTS = T_EVENTS.

      IF OB_RECEIVER IS INITIAL.
***     Criando objeto para Eventos HTML
        CREATE OBJECT OB_RECEIVER.
***     Ativando gatilho de eventos
        SET HANDLER OB_RECEIVER->ON_SAPEVENT FOR OB_HTML_DATAENTRY.
      ELSE.
***     Ativando gatilho de eventos
        SET HANDLER OB_RECEIVER->ON_SAPEVENT FOR OB_HTML_DATAENTRY.
      ENDIF.
    ENDFORM.                    " F_REG_EVENTS_det
*&---------------------------------------------------------------------*
*&      Module  Z_PREENCHE_CAMPOS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*    MODULE z_preenche_campos OUTPUT.
*
**      DATA: vl_datum TYPE sy-datum.
**
**      WRITE sy-datum TO vl_datum.
*
**      wa_ekko-aedat = vl_datum.
*
*      wa_ekko-aedat = sy-datum.
*
*    ENDMODULE.                 " Z_PREENCHE_CAMPOS  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  Z_BUSCA_POS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    MODULE Z_BUSCA_POS INPUT.
      DATA: V_VALLIFNR(1) TYPE C,
            LV_ANSWER(1)  TYPE C.
      IF NOT ZHMS_TB_DTENT_CB-STCD1 IS INITIAL.

        SELECT SINGLE * FROM LFA1
        INTO WA_LFA1
        WHERE STCD1 EQ ZHMS_TB_DTENT_CB-STCD1.
        IF SY-SUBRC EQ 0.
          ZHMS_TB_DTENT_CB-PARTNER = WA_LFA1-LIFNR.
***       Busca pedidos liberados para o fornecedor
          IF NOT T_ITEM[] IS INITIAL.
            SELECT EBELN LIFNR
              INTO TABLE T_LIFNR
              FROM EKKO
              FOR ALL ENTRIES IN T_ITEM
              WHERE EBELN = T_ITEM-EBELN.

            IF SY-SUBRC = 0.
              CLEAR: V_VALLIFNR.
              LOOP AT T_LIFNR INTO WA_LIFNR.
                IF WA_LIFNR-LIFNR <> ZHMS_TB_DTENT_CB-PARTNER.
                  V_VALLIFNR = 'X'.
                ENDIF.
              ENDLOOP.
              IF NOT V_VALLIFNR IS INITIAL.
                CALL FUNCTION 'POPUP_TO_CONFIRM'
                  EXPORTING
                    TITLEBAR              = TEXT-Q01
                    TEXT_QUESTION         = TEXT-018
                    TEXT_BUTTON_1         = TEXT-Q03
                    ICON_BUTTON_1         = 'ICON_CHECKED'
                    TEXT_BUTTON_2         = TEXT-Q04
                    ICON_BUTTON_2         = 'ICON_INCOMPLETE'
                    DEFAULT_BUTTON        = '2'
                    DISPLAY_CANCEL_BUTTON = ' '
                  IMPORTING
                    ANSWER                = LV_ANSWER
                  EXCEPTIONS
                    TEXT_NOT_FOUND        = 1
                    OTHERS                = 2.

                CHECK LV_ANSWER EQ 1.
                REFRESH: T_ITEM.
                CLEAR: T_ITEM.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

      ENDIF.

    ENDMODULE.                 " Z_BUSCA_POS  INPUT
*&---------------------------------------------------------------------*
*&      Module  Z_BUSCA_PED  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    MODULE Z_BUSCA_PED INPUT.
      IF NOT ZHMS_TB_DTENT_CB-STCD1 IS INITIAL.

        SELECT SINGLE * FROM LFA1
        INTO WA_LFA1
        WHERE STCD1 EQ ZHMS_TB_DTENT_CB-STCD1.
        IF SY-SUBRC EQ 0.
          ZHMS_TB_DTENT_CB-PARTNER = WA_LFA1-LIFNR.
***       Busca pedidos liberados para o fornecedor
          REFRESH T_EKKO.
          SELECT EBELN LIFNR BUKRS AEDAT  FROM EKKO
          INTO TABLE T_EKKO
          WHERE LIFNR EQ ZHMS_TB_DTENT_CB-PARTNER
            AND STATU EQ '9'.
          IF SY-SUBRC EQ 0.
            SORT T_EKKO BY EBELN.
          ENDIF.

        ENDIF.

      ENDIF.
      REFRESH: T_SHOW_PO.
      CLEAR: T_SHOW_PO.
      CALL FUNCTION 'ZHMS_FM_BUSCA_PO_POSSIVEIS_DTE'
        EXPORTING
          STCD1     = ZHMS_TB_DTENT_CB-STCD1
        TABLES
          T_SHOW_PO = T_SHOW_PO.



      CALL SCREEN 0111 STARTING AT 30 1 .


**** Busca Items dos pedidos selecionados
*      IF NOT T_EKKO[] IS INITIAL.
*
*        REFRESH T_ITEM.
*        SELECT EBELN
*               EBELP
*               MATNR
*               TXZ01
*               MENGE
*               MEINS
*               NETWR
*               NETPR
*               PEINH
*               BUKRS
*               WERKS
*               MATKL
*         INTO TABLE T_ITEM
*         FROM EKPO
*        FOR ALL ENTRIES IN T_EKKO
*        WHERE EBELN EQ T_EKKO-EBELN
*          AND LOEKZ EQ ''
*          AND WEBRE EQ 'X'.
*        IF SY-SUBRC EQ 0.
*          SORT T_ITEM BY EBELN EBELP.
*        ENDIF.
*
*
*        IF NOT T_ITEM[] IS INITIAL.
***     Elimina pedidos que já foram consumidos totalmente
*          SELECT *
*          FROM EKET
*          INTO TABLE T_EKET
*          FOR ALL ENTRIES IN T_ITEM
*          WHERE EBELN EQ T_ITEM-EBELN
*            AND EBELP EQ T_ITEM-EBELP.
*          IF SY-SUBRC EQ 0.
*
*            LOOP AT T_EKET INTO WA_EKET.
*
*              CHECK WA_EKET-MENGE EQ WA_EKET-WEMNG.
*              DELETE: T_EKKO WHERE EBELN EQ WA_EKET-EBELN,
*                      T_ITEM WHERE EBELN EQ WA_EKET-EBELN.
*
*              CLEAR WA_EKET.
*            ENDLOOP.
*
*          ENDIF.
*
*        ENDIF.
*
*
*        REFRESH T_MATCHCODE.
*        LOOP AT T_ITEM INTO WA_ITEM.
*
*          CLEAR WA_EKET.
*          READ TABLE T_EKET INTO WA_EKET WITH KEY EBELN = WA_ITEM-EBELN
*                                                  EBELP = WA_ITEM-EBELP.
*          IF SY-SUBRC EQ 0.
*
*            WA_MATCHCODE-EBELN = WA_ITEM-EBELN.
*            WA_MATCHCODE-EBELP = WA_ITEM-EBELP.
*            WA_MATCHCODE-ETENR = WA_EKET-ETENR.
*            WA_MATCHCODE-MENGE = WA_EKET-MENGE.
*            WA_MATCHCODE-WEMNG = WA_EKET-WEMNG.
*            WA_MATCHCODE-WAMNG = ( WA_ITEM-MENGE - WA_EKET-WEMNG ).
*
*            APPEND WA_MATCHCODE TO T_MATCHCODE.
*            CLEAR WA_MATCHCODE.
*          ENDIF.
*
*          CLEAR WA_ITEM.
*        ENDLOOP.
*
*      ENDIF.
*
*      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
*  EXPORTING
**   DDIC_STRUCTURE         = 'EKKO'
*    RETFIELD               = 'EBELN'
**   PVALKEY                = ' '
**    DYNPPROG               = sy-repid
**    DYNPNR                 = sy-dynnr
**   DYNPROFIELD            = 'EBELN'
**   STEPL                  = 0
*    WINDOW_TITLE           = 'Exibição Pedidos'
**   VALUE                  = ' '
*    VALUE_ORG              = 'S'
**    MULTIPLE_CHOICE        = 'X'  "allows you select multiple entries from the popup
**   DISPLAY                = ' '
**   CALLBACK_PROGRAM       = ' '
**   CALLBACK_FORM          = ' '
**   MARK_TAB               =
** IMPORTING
**   USER_RESET             = ld_ret
*  TABLES
*    VALUE_TAB              = T_MATCHCODE
**    FIELD_TAB              = lt_field
*    RETURN_TAB             = T_RET_TAB
**   DYNPFLD_MAPPING        =
* EXCEPTIONS
*   PARAMETER_ERROR        = 1
*   NO_VALUES_FOUND        = 2
*   OTHERS                 = 3.
*
*      CLEAR WA_RET_TAB.
*      READ TABLE T_RET_TAB INTO WA_RET_TAB INDEX 1.
*      ZHMS_TB_DTENT_CB-EBELN = WA_RET_TAB-FIELDVAL.
*
    ENDMODULE.                 " Z_BUSCA_PED  INPUT
*&---------------------------------------------------------------------*
*&      Module  Z_BUSCA_ITENS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    MODULE Z_BUSCA_ITENS INPUT.

*      DATA: WL_EKKO TYPE EKKO,
*            WL_LFA1 TYPE LFA1.
*      CLEAR: V_PEDANT.
*      READ TABLE T_ITEM INDEX 1 INTO WA_ITEM.
*      V_PEDANT = WA_ITEM-EBELN.
*      IF NOT ZHMS_TB_DTENT_CB-EBELN IS INITIAL.
*
*        REFRESH T_ITEM.
*        SELECT EBELN
*               EBELP
*               MATNR
*               TXZ01
*               MENGE
*               MEINS
*               NETWR
*               NETPR
*               PEINH
*               BUKRS
*               WERKS
*               MATKL
*         INTO TABLE T_ITEM
*         FROM EKPO
*         WHERE EBELN EQ ZHMS_TB_DTENT_CB-EBELN
*           AND LOEKZ EQ ''
*           AND WEBRE EQ 'X'.
*        IF SY-SUBRC EQ 0.
*          SORT T_ITEM BY EBELN EBELP.
*        ENDIF.
*
*      ENDIF.
*
*      IF ZHMS_TB_DTENT_CB-STCD1 IS INITIAL.
*
*        SELECT SINGLE * FROM EKKO INTO WL_EKKO
*          WHERE EBELN EQ ZHMS_TB_DTENT_CB-EBELN.
*        IF SY-SUBRC EQ 0.
*
*          SELECT SINGLE * FROM LFA1 INTO WL_LFA1
*          WHERE LIFNR EQ ZHMS_TB_DTENT_CB-PARTNER.
*          IF SY-SUBRC EQ 0.
*            MOVE WL_LFA1-STCD1 TO ZHMS_TB_DTENT_CB-PARTNER.
*          ENDIF.
*        ENDIF.
*      ENDIF.
      IF NOT ZHMS_TB_DTENT_CB-STCD1 IS INITIAL.

        SELECT SINGLE * FROM LFA1
        INTO WA_LFA1
        WHERE STCD1 EQ ZHMS_TB_DTENT_CB-STCD1.
        IF SY-SUBRC EQ 0.
          ZHMS_TB_DTENT_CB-PARTNER = WA_LFA1-LIFNR.
***       Busca pedidos liberados para o fornecedor
          REFRESH T_EKKO.
          SELECT EBELN LIFNR BUKRS AEDAT  FROM EKKO
          INTO TABLE T_EKKO
          WHERE LIFNR EQ ZHMS_TB_DTENT_CB-PARTNER
            AND STATU EQ '9'.
          IF SY-SUBRC EQ 0.
            SORT T_EKKO BY EBELN.
          ENDIF.

        ENDIF.

      ENDIF.
      REFRESH: T_SHOW_PO.
      CLEAR: T_SHOW_PO.
      CALL FUNCTION 'ZHMS_FM_BUSCA_PO_POSSIVEIS_DTE'
        EXPORTING
          STCD1     = ZHMS_TB_DTENT_CB-STCD1
        TABLES
          T_SHOW_PO = T_SHOW_PO.

      CALL SCREEN 0111 STARTING AT 30 1.


    ENDMODULE.                 " Z_BUSCA_ITENS  INPUT
*&---------------------------------------------------------------------*
*&      Module  Z_MOVE_VALOR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    MODULE Z_MOVE_VALOR INPUT.

      V_VALORT = V_VALOR_TOTAL.

    ENDMODULE.                 " Z_MOVE_VALOR  INPUT
*&---------------------------------------------------------------------*
*&      Module  Z_ATUALIZA_PED  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    MODULE Z_ATUALIZA_PED INPUT.

*      IF ZHMS_TB_DTENT_CB-EBELN NE WA_ITEM-EBELN.
*      IF ZHMS_TB_DTENT_CB-EBELN NE V_PEDANT.
*        V_FLAG = 'X'.
*      ENDIF.



    ENDMODULE.                 " Z_ATUALIZA_PED  INPUT
*&---------------------------------------------------------------------*
*&      Form  Z_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
    FORM Z_HOTSPOT_CLICK .

    ENDFORM.                    " Z_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*&      Form  Z_CALL_TRANSACTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW_ID  text
*----------------------------------------------------------------------*
    FORM Z_CALL_TRANSACTION  USING P_ROW TYPE LVC_S_ROW.

      READ TABLE T_LOG INTO WA_LOG INDEX P_ROW-INDEX.

      SET PARAMETER ID: 'MBN' FIELD WA_LOG-DOC_MIGO,
                        'MJA' FIELD WA_LOG-ANO_MIGO.

      CALL TRANSACTION 'MB03'.


    ENDFORM.                    " Z_CALL_TRANSACTION
*&---------------------------------------------------------------------*
*&      Form  Z_CALL_TRANSACTION_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW_ID  text
*----------------------------------------------------------------------*
    FORM Z_CALL_TRANSACTION_2  USING P_ROW TYPE LVC_S_ROW.

      READ TABLE T_LOG INTO WA_LOG INDEX P_ROW-INDEX.

      SET PARAMETER ID: 'RBN' FIELD WA_LOG-DOC_MIRO,
                        'GJR' FIELD WA_LOG-ANO_MIRO.

      CALL TRANSACTION 'MIR4'.

    ENDFORM.                    " Z_CALL_TRANSACTION_2
*&---------------------------------------------------------------------*
*&      Module  STATUS_0102  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    MODULE STATUS_0102 OUTPUT.

      SET PF-STATUS 'PF-102'.
*  SET TITLEBAR 'xxx'.

    ENDMODULE.                 " STATUS_0102  OUTPUT

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
    FORM USER_OK_TC USING    P_TC_NAME TYPE DYNFNAM
                             P_TABLE_NAME
                             P_MARK_NAME
                    CHANGING P_OK      LIKE SY-UCOMM.

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
      DATA: L_OK              TYPE SY-UCOMM,
            L_OFFSET          TYPE I.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

*&SPWIZARD: Table control specific operations                          *
*&SPWIZARD: evaluate TC name and operations                            *
      SEARCH P_OK FOR P_TC_NAME.
      IF SY-SUBRC <> 0.
        EXIT.
      ENDIF.
      L_OFFSET = STRLEN( P_TC_NAME ) + 1.
      L_OK = P_OK+L_OFFSET.
*&SPWIZARD: execute general and TC specific operations                 *
      CASE L_OK.
        WHEN 'INSR'.                      "insert row
          PERFORM FCODE_INSERT_ROW USING    P_TC_NAME
                                            P_TABLE_NAME.
          CLEAR P_OK.

        WHEN 'DELE'.                      "delete row
          PERFORM FCODE_DELETE_ROW USING    P_TC_NAME
                                            P_TABLE_NAME
                                            P_MARK_NAME.
          CLEAR P_OK.

        WHEN 'P--' OR                     "top of list
             'P-'  OR                     "previous page
             'P+'  OR                     "next page
             'P++'.                       "bottom of list
          PERFORM COMPUTE_SCROLLING_IN_TC USING P_TC_NAME
                                                L_OK.
          CLEAR P_OK.
*     WHEN 'L--'.                       "total left
*       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
*
*     WHEN 'L-'.                        "column left
*       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
*
*     WHEN 'R+'.                        "column right
*       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
*
*     WHEN 'R++'.                       "total right
*       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
*
        WHEN 'MARK'.                      "mark all filled lines
          PERFORM FCODE_TC_MARK_LINES USING P_TC_NAME
                                            P_TABLE_NAME
                                            P_MARK_NAME   .
          CLEAR P_OK.

        WHEN 'DMRK'.                      "demark all filled lines
          PERFORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
                                              P_TABLE_NAME
                                              P_MARK_NAME .
          CLEAR P_OK.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.

      ENDCASE.

    ENDFORM.                              " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
    FORM FCODE_INSERT_ROW
                  USING    P_TC_NAME           TYPE DYNFNAM
                           P_TABLE_NAME             .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
      DATA L_LINES_NAME       LIKE FELD-NAME.
      DATA L_SELLINE          LIKE SY-STEPL.
      DATA L_LASTLINE         TYPE I.
      DATA L_LINE             TYPE I.
      DATA L_TABLE_NAME       LIKE FELD-NAME.
      FIELD-SYMBOLS <TC>                 TYPE CXTAB_CONTROL.
      FIELD-SYMBOLS <TABLE>              TYPE STANDARD TABLE.
      FIELD-SYMBOLS <LINES>              TYPE I.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

      ASSIGN (P_TC_NAME) TO <TC>.

*&SPWIZARD: get the table, which belongs to the tc                     *
      CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
      ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*&SPWIZARD: get looplines of TableControl                              *
      CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_LINES_NAME.
      ASSIGN (L_LINES_NAME) TO <LINES>.

*&SPWIZARD: get current line                                           *
      GET CURSOR LINE L_SELLINE.
      IF SY-SUBRC <> 0.                   " append line to table
        L_SELLINE = <TC>-LINES + 1.
*&SPWIZARD: set top line                                               *
        IF L_SELLINE > <LINES>.
          <TC>-TOP_LINE = L_SELLINE - <LINES> + 1 .
        ELSE.
          <TC>-TOP_LINE = 1.
        ENDIF.
      ELSE.                               " insert line into table
        L_SELLINE = <TC>-TOP_LINE + L_SELLINE - 1.
        L_LASTLINE = <TC>-TOP_LINE + <LINES> - 1.
      ENDIF.
*&SPWIZARD: set new cursor line                                        *
      L_LINE = L_SELLINE - <TC>-TOP_LINE + 1.

*&SPWIZARD: insert initial line                                        *
      INSERT INITIAL LINE INTO <TABLE> INDEX L_SELLINE.
      <TC>-LINES = <TC>-LINES + 1.
*&SPWIZARD: set cursor                                                 *
      SET CURSOR LINE L_LINE.

    ENDFORM.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
    FORM FCODE_DELETE_ROW
                  USING    P_TC_NAME           TYPE DYNFNAM
                           P_TABLE_NAME
                           P_MARK_NAME   .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
      DATA L_TABLE_NAME       LIKE FELD-NAME.

      FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
      FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
      FIELD-SYMBOLS <WA>.
      FIELD-SYMBOLS <MARK_FIELD>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

      ASSIGN (P_TC_NAME) TO <TC>.

*&SPWIZARD: get the table, which belongs to the tc                     *
      CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
      ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*&SPWIZARD: delete marked lines                                        *
      DESCRIBE TABLE <TABLE> LINES <TC>-LINES.

      LOOP AT <TABLE> ASSIGNING <WA>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
        ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

        IF <MARK_FIELD> = 'X'.
          DELETE <TABLE> INDEX SYST-TABIX.
          IF SY-SUBRC = 0.
            <TC>-LINES = <TC>-LINES - 1.
          ENDIF.
        ENDIF.
      ENDLOOP.

    ENDFORM.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*      -->P_OK       ok code
*----------------------------------------------------------------------*
    FORM COMPUTE_SCROLLING_IN_TC USING    P_TC_NAME
                                          P_OK.
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
      DATA L_TC_NEW_TOP_LINE     TYPE I.
      DATA L_TC_NAME             LIKE FELD-NAME.
      DATA L_TC_LINES_NAME       LIKE FELD-NAME.
      DATA L_TC_FIELD_NAME       LIKE FELD-NAME.

      FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
      FIELD-SYMBOLS <LINES>      TYPE I.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

      ASSIGN (P_TC_NAME) TO <TC>.
*&SPWIZARD: get looplines of TableControl                              *
      CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_TC_LINES_NAME.
      ASSIGN (L_TC_LINES_NAME) TO <LINES>.


*&SPWIZARD: is no line filled?                                         *
      IF <TC>-LINES = 0.
*&SPWIZARD: yes, ...                                                   *
        L_TC_NEW_TOP_LINE = 1.
      ELSE.
*&SPWIZARD: no, ...                                                    *
        CALL FUNCTION 'SCROLLING_IN_TABLE'
          EXPORTING
            ENTRY_ACT             = <TC>-TOP_LINE
            ENTRY_FROM            = 1
            ENTRY_TO              = <TC>-LINES
            LAST_PAGE_FULL        = 'X'
            LOOPS                 = <LINES>
            OK_CODE               = P_OK
            OVERLAPPING           = 'X'
          IMPORTING
            ENTRY_NEW             = L_TC_NEW_TOP_LINE
          EXCEPTIONS
*           NO_ENTRY_OR_PAGE_ACT  = 01
*           NO_ENTRY_TO           = 02
*           NO_OK_CODE_OR_PAGE_GO = 03
            OTHERS                = 0.
      ENDIF.

*&SPWIZARD: get actual tc and column                                   *
      GET CURSOR FIELD L_TC_FIELD_NAME
                 AREA  L_TC_NAME.

      IF SYST-SUBRC = 0.
        IF L_TC_NAME = P_TC_NAME.
*&SPWIZARD: et actual column                                           *
          SET CURSOR FIELD L_TC_FIELD_NAME LINE 1.
        ENDIF.
      ENDIF.

*&SPWIZARD: set the new top line                                       *
      <TC>-TOP_LINE = L_TC_NEW_TOP_LINE.


    ENDFORM.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
    FORM FCODE_TC_MARK_LINES USING P_TC_NAME
                                   P_TABLE_NAME
                                   P_MARK_NAME.
*&SPWIZARD: EGIN OF LOCAL DATA-----------------------------------------*
      DATA L_TABLE_NAME       LIKE FELD-NAME.

      FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
      FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
      FIELD-SYMBOLS <WA>.
      FIELD-SYMBOLS <MARK_FIELD>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

      ASSIGN (P_TC_NAME) TO <TC>.

*&SPWIZARD: get the table, which belongs to the tc                     *
      CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
      ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*&SPWIZARD: mark all filled lines                                      *
      LOOP AT <TABLE> ASSIGNING <WA>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
        ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

        <MARK_FIELD> = 'X'.
      ENDLOOP.
    ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
    FORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
                                     P_TABLE_NAME
                                     P_MARK_NAME .
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
      DATA L_TABLE_NAME       LIKE FELD-NAME.

      FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
      FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
      FIELD-SYMBOLS <WA>.
      FIELD-SYMBOLS <MARK_FIELD>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

      ASSIGN (P_TC_NAME) TO <TC>.

*&SPWIZARD: get the table, which belongs to the tc                     *
      CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
      ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline

*&SPWIZARD: demark all filled lines                                    *
      LOOP AT <TABLE> ASSIGNING <WA>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
        ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.

        <MARK_FIELD> = SPACE.
      ENDLOOP.
    ENDFORM.                                          "fcode_tc_mark_lines
*&---------------------------------------------------------------------*
*&      Form  F_TRANSFERE_ITEM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
    FORM F_TRANSFERE_ITEM .
      DATA: V_LINE TYPE I.
      READ TABLE T_SHOW_PO INTO WA_SHOW_PO WITH KEY MARK = 'X'.
      IF SY-SUBRC = 0.
        CLEAR: WA_SHOW_PO, WA_ZTERM, V_LINE.
        REFRESH: T_ZTERM.
        IF NOT T_ITEM[] IS INITIAL.
          LOOP AT T_ITEM INTO WA_ITEM.
            SELECT SINGLE ZTERM
                     INTO WA_ZTERM
                          FROM EKKO
                          WHERE EBELN EQ WA_ITEM-EBELN.
            COLLECT WA_ZTERM INTO T_ZTERM.
          ENDLOOP.
        ENDIF.
*Valição se a condição de pagamento é a mesma para todos os itens

        LOOP AT T_SHOW_PO INTO WA_SHOW_PO WHERE MARK = 'X'.
          SELECT SINGLE ZTERM
            INTO WA_ZTERM
                 FROM EKKO
                 WHERE EBELN EQ WA_SHOW_PO-EBELN.
          COLLECT WA_ZTERM INTO T_ZTERM.
        ENDLOOP.

        DESCRIBE TABLE T_ZTERM LINES V_LINE.
        IF V_LINE > 1.
          MESSAGE I000 WITH TEXT-006.
        ELSE.
          LOOP AT T_SHOW_PO INTO WA_SHOW_PO WHERE MARK = 'X'.

            READ TABLE T_ITEM INTO WA_ITEM WITH KEY EBELN = WA_SHOW_PO-EBELN
                                                    EBELP = WA_SHOW_PO-EBELP.
            IF SY-SUBRC <> 0.
              CLEAR WA_ITEM.
              SELECT SINGLE EBELN
                            EBELP
                            MATNR
                            TXZ01
                            MENGE
                            MEINS
                            NETWR
                            NETPR
                            PEINH
                            BUKRS
                            WERKS
                            MATKL
               INTO WA_ITEM
               FROM EKPO
               WHERE EBELN EQ WA_SHOW_PO-EBELN
                 AND EBELP EQ WA_SHOW_PO-EBELP.
              IF WA_ITEM-MENGE <> WA_SHOW_PO-WEMNG.
                WA_ITEM-MENGE = WA_SHOW_PO-WEMNG.
                WA_ITEM-NETWR = WA_SHOW_PO-WEMNG * WA_ITEM-NETPR.
                APPEND WA_ITEM TO T_ITEM.
              ELSE.
                APPEND WA_ITEM TO T_ITEM.
              ENDIF.
            ENDIF.
          ENDLOOP.
          IF ZHMS_TB_DTENT_CB-STCD1 IS INITIAL.
            IF NOT V_STCD1 IS INITIAL.
              ZHMS_TB_DTENT_CB-STCD1 = V_STCD1.
            ELSE.
              READ TABLE T_ITEM INTO WA_ITEM INDEX 1.
              IF SY-SUBRC = 0.
                SELECT SINGLE LIFNR
                          INTO V_LIFNR
                          FROM EKKO
                          WHERE EBELN = WA_ITEM-EBELN.

                IF NOT V_LIFNR IS INITIAL.
                  ZHMS_TB_DTENT_CB-PARTNER = V_LIFNR.
                  SELECT SINGLE STCD1
                  INTO V_STCD1
                    FROM LFA1
                    WHERE LIFNR = V_LIFNR.
                  ZHMS_TB_DTENT_CB-STCD1 = V_STCD1.
                ENDIF.
              ENDIF.
            ENDIF.
            IF NOT ZHMS_TB_DTENT_CB-STCD1 IS INITIAL.

              SELECT SINGLE * FROM LFA1
              INTO WA_LFA1
              WHERE STCD1 EQ ZHMS_TB_DTENT_CB-STCD1.
              IF SY-SUBRC EQ 0.
                ZHMS_TB_DTENT_CB-PARTNER = WA_LFA1-LIFNR.
***       Busca pedidos liberados para o fornecedor
                REFRESH T_EKKO.
                SELECT EBELN LIFNR BUKRS AEDAT  FROM EKKO
                INTO TABLE T_EKKO
                WHERE LIFNR EQ ZHMS_TB_DTENT_CB-PARTNER
                  AND STATU EQ '9'.
                IF SY-SUBRC EQ 0.
                  SORT T_EKKO BY EBELN.
                ENDIF.

              ENDIF.

            ENDIF.
          ENDIF.
          LEAVE TO SCREEN 0 .
        ENDIF.
      ELSE.
        MESSAGE I000 WITH TEXT-007.
      ENDIF.
    ENDFORM.                    " F_TRANSFERE_ITEM
*&---------------------------------------------------------------------*
*&      Form  F_SELECIONA_ITEM
*&---------------------------------------------------------------------*
    FORM F_SELECIONA_ITEM .
*      IF NOT ZHMS_TB_DTENT_CB-STCD1 IS INITIAL.
*
*        SELECT SINGLE * FROM LFA1
*        INTO WA_LFA1
*        WHERE STCD1 EQ ZHMS_TB_DTENT_CB-STCD1.
*        IF SY-SUBRC EQ 0.
*          ZHMS_TB_DTENT_CB-PARTNER = WA_LFA1-LIFNR.
****       Busca pedidos liberados para o fornecedor
*          REFRESH T_EKKO.
*          SELECT EBELN LIFNR BUKRS AEDAT  FROM EKKO
*          INTO TABLE T_EKKO
*          WHERE LIFNR EQ ZHMS_TB_DTENT_CB-PARTNER
*            AND STATU EQ '9'.
*          IF SY-SUBRC EQ 0.
*            SORT T_EKKO BY EBELN.
*          ENDIF.
*
*        ENDIF.
*
*      ENDIF.
*      REFRESH: T_SHOW_PO.
*      CLEAR: T_SHOW_PO.
*      CALL FUNCTION 'ZHMS_FM_BUSCA_PO_POSSIVEIS_DTE'
*        EXPORTING
*          STCD1     = ZHMS_TB_DTENT_CB-STCD1
**         EBELN     = ZHMS_TB_DTENT_CB-EBELN
*        TABLES
*          T_SHOW_PO = T_SHOW_PO.
      CLEAR: V_EBELN, T_SHOW_PO.
      REFRESH: T_SHOW_PO.
      CALL SCREEN 0111 STARTING AT 30 1 .
    ENDFORM.                    " F_SELECIONA_ITEM
*&---------------------------------------------------------------------*
*&      Form  F_ELIMINA_ITEM
*&---------------------------------------------------------------------*
    FORM F_ELIMINA_ITEM .
      DELETE T_ITEM WHERE SEL = 'X'.
    ENDFORM.                    " F_ELIMINA_ITEM
*&---------------------------------------------------------------------*
*&      Form  F_SELECIONA_TODOS
*&---------------------------------------------------------------------*
    FORM F_SELECIONA_TODOS .
      LOOP AT T_ITEM INTO WA_ITEM.
        WA_ITEM-SEL = 'X'.
        MODIFY T_ITEM FROM WA_ITEM.
      ENDLOOP.

    ENDFORM.                    " F_SELECIONA_TODOS
*&---------------------------------------------------------------------*
*&      Form  F_TIRA_SELECAO
*&---------------------------------------------------------------------*
    FORM F_TIRA_SELECAO .
      LOOP AT T_ITEM INTO WA_ITEM.
        CLEAR WA_ITEM-SEL.
        MODIFY T_ITEM FROM WA_ITEM.
      ENDLOOP.
    ENDFORM.                    " F_TIRA_SELECAO
*&---------------------------------------------------------------------*
*&      Form  F_CALL_SEL_DYNN
*&---------------------------------------------------------------------*
    FORM F_CALL_SEL_DYNN .
      DATA: VL_TEXT TYPE SY-TITLE.
      CLEAR: VL_RETORNO.

***   Inicializando Tela de Seleção
      CALL FUNCTION 'FREE_SELECTIONS_INIT'
        EXPORTING
          KIND                     = 'T'
          EXPRESSIONS              = T_TEXPR
        IMPORTING
          SELECTION_ID             = V_SELID
          NUMBER_OF_ACTIVE_FIELDS  = V_ACTNUM
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
****     Carregando Condições da Tela de Seleção
*        CALL FUNCTION 'FREE_SELECTIONS_WHERE_2_EX'
*          EXPORTING
*            where_clauses        = t_twhere
*          IMPORTING
*            expressions          = t_texpr
*          EXCEPTIONS
*            incorrect_expression = 1
*            OTHERS               = 2.
*
*        IF sy-subrc EQ 0.
*          CLEAR wa_type_t.
*          READ TABLE t_type_t INTO wa_type_t
*                              WITH KEY natdc = wa_type-natdc
*                                       typed = wa_type-typed
*                                       loctp = wa_type-loctp.
*
*          IF sy-subrc EQ 0.
*            CLEAR vl_text.
*            MOVE wa_type_t-denom TO vl_text.
*          ENDIF.

***       Tela de Seleção
        CLEAR V_TITLE.
        MOVE TEXT-001 TO V_TITLE.

***       Criando tela de seleção
        CALL FUNCTION 'FREE_SELECTIONS_DIALOG'
          EXPORTING
            SELECTION_ID            = V_SELID
            TITLE                   = V_TITLE
            TREE_VISIBLE            = ''
            AS_WINDOW               = 'X'
            START_ROW               = '1'
            START_COL               = '35'
            FRAME_TEXT              = VL_TEXT
            STATUS                  = 1
          IMPORTING
            WHERE_CLAUSES           = T_TWHERE
            EXPRESSIONS             = T_TEXPR
            NUMBER_OF_ACTIVE_FIELDS = V_ACTNUM
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
          MESSAGE W002.
        ELSEIF SY-SUBRC EQ 2.
          VL_RETORNO = 'X'.
        ENDIF.
*        ELSE.
****       Erro ao montar a Tela de Seleção. Contatar Suporte.
*          MESSAGE w002.
*        ENDIF.
      ELSE.
***     Erro ao montar a Tela de Seleção. Contatar Suporte.
        MESSAGE W002.
      ENDIF.
    ENDFORM.                    " F_CALL_SEL_DYNN
*&---------------------------------------------------------------------*
*&      Form  F_PREP_SEL_DYNN
*&---------------------------------------------------------------------*
    FORM F_PREP_SEL_DYNN .
      TYPES: BEGIN OF TY_TBL_SC,
              TBLNM TYPE TABNAME,
            END OF TY_TBL_SC.
      DATA: T_TBL_SC  TYPE STANDARD TABLE OF TY_TBL_SC,
            WA_TBL_SC TYPE TY_TBL_SC.

      REFRESH T_GRPFLD_S.
      CLEAR   T_GRPFLD_S.
      SELECT *
      FROM ZHMS_TB_GRPFLD_S
      INTO TABLE T_GRPFLD_S
      WHERE CODGF EQ '04'.
      SORT T_GRPFLD_S BY CODGF SEQNR TABSS FLDSS.

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
*&      Form  F_SEL_INDEX_NFS
*&---------------------------------------------------------------------*
    FORM F_SEL_INDEX_NFS .
***   Selecionando Naturezas dos Documentos Cadastradas
      PERFORM F_SEL_MASTERD_INDEX.

      LOOP AT T_NATURE INTO WA_NATURE.
        CLEAR WA_INDEX.
        MOVE:  '' TO WA_INDEX-FATHR,
               WA_NATURE-NATDC TO WA_INDEX-SONHR.

***     Lendo denominação da Natureza do Documento
        CLEAR WA_NATURE_T.
        READ TABLE T_NATURE_T INTO     WA_NATURE_T
                              WITH KEY NATDC = WA_NATURE-NATDC BINARY SEARCH.

        IF SY-SUBRC EQ 0.
          MOVE WA_NATURE_T-DENOM TO WA_INDEX-DENOM.
        ENDIF.

***     Preparando Ícone
        CLEAR: VG_ICON_ID,
               VG_ICON_URL.

        MOVE WA_NATURE-ICONS TO VG_ICON_ID.
        CONCATENATE WA_NATURE-ICONS '.GIF'
               INTO VG_ICON_URL.
        MOVE VG_ICON_URL TO WA_INDEX-ICONH.

***     Carregando Ícone Padrão
        PERFORM F_LOAD_IMAGES USING VG_ICON_ID
                                    VG_ICON_URL.

        APPEND WA_INDEX TO T_INDEX.

        LOOP AT T_TYPE INTO  WA_TYPE
                       WHERE NATDC EQ WA_NATURE-NATDC.

          CLEAR WA_INDEX.
          MOVE: WA_NATURE-NATDC TO WA_INDEX-FATHR,
                WA_TYPE-TYPED   TO WA_INDEX-SONHR,
                WA_TYPE-LOCTP   TO WA_INDEX-LOCTP.

***       Lendo denominação do Tipo de Documento
          CLEAR WA_TYPE_T.
          READ TABLE T_TYPE_T INTO     WA_TYPE_T
                              WITH KEY NATDC = WA_TYPE-NATDC
                                       TYPED = WA_TYPE-TYPED
                                       LOCTP = WA_TYPE-LOCTP BINARY SEARCH.

          IF SY-SUBRC EQ 0.
            MOVE WA_TYPE_T-DENOM TO WA_INDEX-DENOM.
          ENDIF.

          APPEND WA_INDEX TO T_INDEX.
        ENDLOOP.
      ENDLOOP.
    ENDFORM.                    " F_SEL_INDEX_NFS
*&---------------------------------------------------------------------*
*&      Form  F_LOAD_IMAGES
*&---------------------------------------------------------------------*
    FORM F_LOAD_IMAGES  USING    P_ID
                                 P_URL.
***   ICON RATING NEUTRAL
      CALL METHOD OB_HTML_INDEX->LOAD_MIME_OBJECT
        EXPORTING
          OBJECT_ID            = P_ID
          OBJECT_URL           = P_URL
        EXCEPTIONS
          OBJECT_NOT_FOUND     = 1
          DP_INVALID_PARAMETER = 1
          DP_ERROR_GENERAL     = 3
          OTHERS               = 4.

      IF SY-SUBRC NE 0.
***     Erro Interno. Contatar Suporte.
        MESSAGE E000 WITH TEXT-000.
      ENDIF.

    ENDFORM.                    " F_LOAD_IMAGES

*&---------------------------------------------------------------------*
*&      Form  HANDEL_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
    FORM HANDEL_HOTSPOT_CLICK  USING    P_E_ROW_ID
                                        P_E_COLUMN_ID.

      DATA: T_DYFLD TYPE STANDARD TABLE OF DYNPREAD,
            L_DYFLD TYPE DYNPREAD.

*      break rsantos.
      CLEAR: T_ALV_PED_AUX, T_ALV_COMP_AU.
* Comparações simples
      READ TABLE T_ALV_XML INTO WA_ALV_XML INDEX P_E_ROW_ID.
      IF SY-SUBRC EQ 0.
        LOOP AT T_ALV_COMP INTO WA_ALV_COMP WHERE ITEM = WA_ALV_XML-ITEM.
          APPEND WA_ALV_COMP TO T_ALV_COMP_AU.
        ENDLOOP.
      ENDIF.

* Comparações de impostos
      READ TABLE T_ALV_XML INTO WA_ALV_XML INDEX P_E_ROW_ID.
      IF SY-SUBRC EQ 0.
        LOOP AT T_ALV_PED INTO WA_ALV_PED WHERE ITEM = WA_ALV_XML-ITEM.
          APPEND WA_ALV_PED TO T_ALV_PED_AUX.
        ENDLOOP.
      ENDIF.


    ENDFORM.                    " HANDEL_HOTSPOT_CLICK
*----------------------------------------------------------------------*
*   Form  F_SEL_MASTERD_INDEX
*----------------------------------------------------------------------*
*   Selecionando Dados Mestres do Índice
*----------------------------------------------------------------------*
    FORM F_SEL_MASTERD_INDEX.
      REFRESH: T_NATURE,
               T_NATURE_T.
      CLEAR:   WA_NATURE,
               WA_NATURE_T.

***   Lendo Nature do Documento
      SELECT * FROM ZHMS_TB_NATURE_E
               INTO TABLE T_NATURE.

      IF SY-SUBRC EQ 0.
        SORT T_NATURE BY NATDC.

***     Selecionando Tipos de Documentos Cadastrados
        PERFORM F_SEL_TYPE_DOCS.

***     Lendo Denominação da Nature do Documento
        SELECT * FROM ZHMS_TX_NATURE_E
                 INTO TABLE T_NATURE_T
                 FOR ALL ENTRIES IN T_NATURE
                 WHERE NATDC EQ T_NATURE-NATDC      AND
                       SPRAS EQ SY-LANGU.

        IF SY-SUBRC EQ 0.
          SORT T_NATURE_T BY NATDC.
        ENDIF.
      ENDIF.
    ENDFORM.                    " F_SEL_MASTERD_INDEX*----------------------------------------------------------------------*
*   Form  F_SEL_TYPE_DOCS
*----------------------------------------------------------------------*
*   Selecionando Tipos de Documentos Cadastrados
*----------------------------------------------------------------------*
    FORM F_SEL_TYPE_DOCS.
      REFRESH: T_TYPE,
               T_TYPE_T.
      CLEAR:   WA_TYPE,
               WA_TYPE_T.

***   Lendo Nature do Documento
      SELECT * FROM ZHMS_TB_TYPE_E
               INTO TABLE T_TYPE
               FOR ALL ENTRIES IN T_NATURE
               WHERE NATDC EQ T_NATURE-NATDC.

      IF SY-SUBRC EQ 0.
        SORT   T_TYPE BY ATIVO.
        DELETE T_TYPE WHERE ATIVO NE 'X'.


        SORT T_TYPE BY NATDC TYPED LOCTP.

***       Lendo Denominação da Nature do Documento
        SELECT * FROM ZHMS_TX_TYPE_E
                 INTO TABLE T_TYPE_T
                 FOR ALL ENTRIES IN T_TYPE
                 WHERE NATDC EQ T_TYPE-NATDC      AND
                       TYPED EQ T_TYPE-TYPED      AND
                       LOCTP EQ T_TYPE-LOCTP      AND
                       SPRAS EQ SY-LANGU.

        IF SY-SUBRC EQ 0.
          SORT T_TYPE_T BY NATDC TYPED LOCTP.
        ENDIF.

      ENDIF.
    ENDFORM.                    " F_SEL_TYPE_DOCS
*----------------------------------------------------------------------*
*   Form  F_REG_EVENTS_INDEX
*----------------------------------------------------------------------*
*   Registrando Eventos do HTML Index
*----------------------------------------------------------------------*
    FORM F_REG_EVENTS_INDEX.
***   Obtendo Eventos
      REFRESH T_EVENTS.
      CLEAR   WA_EVENT.
      MOVE:   OB_HTML_INDEX->M_ID_SAPEVENT TO WA_EVENT-EVENTID,
              'X'                          TO WA_EVENT-APPL_EVENT.
      APPEND  WA_EVENT TO T_EVENTS.

***   Registrando Eventos
      CALL METHOD OB_HTML_INDEX->SET_REGISTERED_EVENTS
        EXPORTING
          EVENTS = T_EVENTS.

      IF OB_RECEIVER IS INITIAL.
***     Criando objeto para Eventos HTML
        CREATE OBJECT OB_RECEIVER.
***     Ativando gatilho de eventos
        SET HANDLER OB_RECEIVER->ON_SAPEVENT FOR OB_HTML_INDEX.
      ELSE.
***     Ativando gatilho de eventos
        SET HANDLER OB_RECEIVER->ON_SAPEVENT FOR OB_HTML_INDEX.
      ENDIF.
    ENDFORM.                    " F_REG_EVENTS_INDEX
*----------------------------------------------------------------------*
*   Form  F_SET_INDEX_LINE
*----------------------------------------------------------------------*
*   Recupera índice selecionados
*----------------------------------------------------------------------*
    FORM F_SET_INDEX_LINE USING P_ACTION.
      DATA: VL_NATDC TYPE ZHMS_TB_TYPE-NATDC,
            VL_LOCTP TYPE ZHMS_TB_TYPE-LOCTP.

      CLEAR: "VG_CHAVE,
             VG_NATDC,
             VG_TYPED,
             VG_EVENT,
             VG_VERSN,
             VG_QTSEL.

***   Obtendo linha selecionada
      SPLIT P_ACTION AT '|' INTO VL_NATDC
                                 VL_TYPED
                                 VL_LOCTP.

      IF SY-SUBRC EQ 0.
        SORT T_TYPE BY NATDC TYPED LOCTP.

***     Lendo linha selecionada
        CLEAR WA_TYPE.
        READ TABLE T_TYPE INTO     WA_TYPE
                          WITH KEY NATDC = VL_NATDC
                                   TYPED = VL_TYPED
                                   LOCTP = VL_LOCTP.

        IF SY-SUBRC EQ 0.
          IF VL_TYPED = '1TNV'.
            MOVE: '0101' TO VG_0150.
          ELSE.
            PERFORM F_PREP_SEL_DYNN.
            PERFORM F_CALL_SEL_DYNN.
            CALL SCREEN 0140 STARTING AT 30 1 .
          ENDIF.

        ENDIF.
      ENDIF.
    ENDFORM.                    " F_SET_INDEX_LINE
*&---------------------------------------------------------------------*
*&      Form  F_EXECUTA_FLUXO
*&---------------------------------------------------------------------*
    FORM F_EXECUTA_FLUXO .

      IF ZHMS_TB_DTENT_CB-VALOR IS INITIAL OR
         ZHMS_TB_DTENT_CB-DTDOC IS INITIAL OR
         ZHMS_TB_DTENT_CB-NFNUM IS INITIAL OR
         ZHMS_TB_DTENT_CB-STCD1 IS INITIAL.

        MESSAGE I000 WITH TEXT-008.
        EXIT.
      ELSE.

        SORT T_ITEM BY EBELN EBELP.

        CLEAR V_VLTOTPED.
        LOOP AT T_ITEM INTO WA_ITEM.
          V_VLTOTPED = V_VLTOTPED + WA_ITEM-NETWR.
        ENDLOOP.

        IF ZHMS_TB_DTENT_CB-VALOR <> V_VLTOTPED.
          MESSAGE I000 WITH TEXT-009 TEXT-010.
          EXIT.
        ELSE.

          VG_NOTA = ZHMS_TB_DTENT_CB-NFNUM.
          REPLACE ALL OCCURRENCES OF '-' IN VG_NOTA WITH ''.
          SHIFT VG_NOTA RIGHT DELETING TRAILING SPACE.
          TRANSLATE VG_NOTA USING ' 0'.
          CONCATENATE VG_NOTA
                      ZHMS_TB_DTENT_CB-DTDOC+6(2)
                      ZHMS_TB_DTENT_CB-DTDOC+4(2)
                      ZHMS_TB_DTENT_CB-DTDOC(4)
                      ZHMS_TB_DTENT_CB-STCD1 INTO VG_CHAVE.

          IF VL_TYPED <> '1TNV'.
            PERFORM F_GRAVA_DOCMN.

            PERFORM F_GRAVA_CABDOC.

            PERFORM F_GRAVA_ITMDOC.

            PERFORM F_GRAVA_ITMATR.

            PERFORM F_SAVE.
**      Executa fluxo
            REFRESH: T_DOCUM.
            CLEAR WA_DOCUM.
            WA_DOCUM-DCTYP = 'CHAVE'.
            WA_DOCUM-DCNRO = VG_CHAVE.
            WA_DOCUM-CHAVE = VG_CHAVE.
            APPEND WA_DOCUM TO T_DOCUM.

            CALL FUNCTION 'ZHMS_FM_TRACER'
              EXPORTING
                NATDC = '02'
                TYPED = 'NFET'
                LOCTP = ' '
              TABLES
                DOCUM = T_DOCUM.

            IF SY-SUBRC = 0.
              REFRESH: T_DOCMN.
              CLEAR: T_DOCMN.
              SELECT *
                INTO TABLE T_DOCMN
                FROM ZHMS_TB_DOCMN
                WHERE CHAVE = VG_CHAVE.

              CLEAR: WA_DOCMN.
              READ TABLE T_DOCMN INTO WA_DOCMN WITH KEY MNEUM = 'MATDOC'.
              IF SY-SUBRC = 0.
                ZHMS_TB_DTENT_CB-DOC_MIGO = WA_DOCMN-VALUE.
                CLEAR: ZHMS_TB_DTENT_CB-DOC_MIGO_EST,ZHMS_TB_DTENT_CB-YEAR_MIGO_EST.
              ELSE.
                MESSAGE I000 WITH TEXT-012.
              ENDIF.
              CLEAR: WA_DOCMN.
              READ TABLE T_DOCMN INTO WA_DOCMN WITH KEY MNEUM = 'MATDOCYEA'.
              IF SY-SUBRC = 0.
                ZHMS_TB_DTENT_CB-YEAR_MIGO = WA_DOCMN-VALUE.
              ENDIF.
              CLEAR: WA_DOCMN.
              READ TABLE T_DOCMN INTO WA_DOCMN WITH KEY MNEUM = 'INVDOCNO'.
              IF SY-SUBRC = 0.
                ZHMS_TB_DTENT_CB-DOC_MIRO = WA_DOCMN-VALUE.
                CLEAR: ZHMS_TB_DTENT_CB-DOC_MIRO_EST, ZHMS_TB_DTENT_CB-YEAR_MIRO_EST.
              ELSE.
                MESSAGE I000 WITH TEXT-013.
              ENDIF.
              CLEAR: WA_DOCMN.
              READ TABLE T_DOCMN INTO WA_DOCMN WITH KEY MNEUM = 'FISCALYEAR'.
              IF SY-SUBRC = 0.
                ZHMS_TB_DTENT_CB-YEAR_MIRO = WA_DOCMN-VALUE.
              ENDIF.
            ENDIF.

          ELSE.
            SELECT SINGLE * INTO WA_DTENT_CB FROM ZHMS_TB_DTENT_CB
              WHERE STCD1 = ZHMS_TB_DTENT_CB-STCD1
                AND NFNUM = ZHMS_TB_DTENT_CB-NFNUM
                AND DTDOC = ZHMS_TB_DTENT_CB-DTDOC.
            IF SY-SUBRC <> 0.
              CLEAR: WA_DOCMN_AUX, T_DOCMN_AUX, VL_NOTA, VL_SERIE, VL_NF_HMS.
              REFRESH: T_DOCMN_AUX.
              SPLIT ZHMS_TB_DTENT_CB-NFNUM AT '-' INTO VL_NOTA VL_SERIE.
              SELECT *
                INTO TABLE T_CHAVE_NF
                FROM ZHMS_TB_DOCMN
              WHERE MNEUM = 'NNF'
                AND VALUE = VL_NOTA.
** Alterado pois estava dando erro de duplicidade
** Renan Itokazo
              IF NOT t_chave_nf[] IS INITIAL.
              SELECT *
                INTO TABLE T_DOCMN_AUX
                FROM ZHMS_TB_DOCMN
                FOR ALL ENTRIES IN T_CHAVE_NF
              WHERE CHAVE = T_CHAVE_NF-CHAVE.
              ENDIF.

              LOOP AT T_DOCMN_AUX INTO WA_DOCMN_AUX WHERE MNEUM = 'SERIE'
                                                      AND VALUE = VL_SERIE.

                READ TABLE T_DOCMN_AUX INTO WA_DOCMN_AUX WITH KEY CHAVE = WA_DOCMN_AUX-CHAVE
                                                                  MNEUM = 'CNPJ'
                                                                  VALUE = ZHMS_TB_DTENT_CB-STCD1.
                IF SY-SUBRC = 0.
                  VL_NF_HMS = 'X'.
                ENDIF.
              ENDLOOP.

              IF VL_NF_HMS IS INITIAL.
                PERFORM F_GRAVA_DOCMN.

                PERFORM F_GRAVA_CABDOC.

                PERFORM F_GRAVA_ITMDOC.

                PERFORM F_GRAVA_ITMATR.

                PERFORM F_SAVE.
**      Executa fluxo
                REFRESH: T_DOCUM.
                CLEAR WA_DOCUM.
                WA_DOCUM-DCTYP = 'CHAVE'.
                WA_DOCUM-DCNRO = VG_CHAVE.
                WA_DOCUM-CHAVE = VG_CHAVE.
                APPEND WA_DOCUM TO T_DOCUM.

                CALL FUNCTION 'ZHMS_FM_TRACER'
                  EXPORTING
                    NATDC = '02'
                    TYPED = 'NFET'
                    LOCTP = ' '
                  TABLES
                    DOCUM = T_DOCUM.

                IF SY-SUBRC = 0.
                  REFRESH: T_DOCMN.
                  CLEAR: T_DOCMN.
                  SELECT *
                    INTO TABLE T_DOCMN
                    FROM ZHMS_TB_DOCMN
                    WHERE CHAVE = VG_CHAVE.

                  CLEAR: WA_DOCMN.
                  READ TABLE T_DOCMN INTO WA_DOCMN WITH KEY MNEUM = 'MATDOC'.
                  IF SY-SUBRC = 0.
                    ZHMS_TB_DTENT_CB-DOC_MIGO = WA_DOCMN-VALUE.
                    CLEAR: ZHMS_TB_DTENT_CB-DOC_MIGO_EST,ZHMS_TB_DTENT_CB-YEAR_MIGO_EST.
                  ELSE.
                    MESSAGE I000 WITH TEXT-012.
                    VL_TYPED = '2TPEN'.
                  ENDIF.
                  CLEAR: WA_DOCMN.
                  READ TABLE T_DOCMN INTO WA_DOCMN WITH KEY MNEUM = 'MATDOCYEA'.
                  IF SY-SUBRC = 0.
                    ZHMS_TB_DTENT_CB-YEAR_MIGO = WA_DOCMN-VALUE.
                  ENDIF.
                  CLEAR: WA_DOCMN.
                  READ TABLE T_DOCMN INTO WA_DOCMN WITH KEY MNEUM = 'INVDOCNO'.
                  IF SY-SUBRC = 0.
                    ZHMS_TB_DTENT_CB-DOC_MIRO = WA_DOCMN-VALUE.
                    CLEAR: ZHMS_TB_DTENT_CB-DOC_MIRO_EST, ZHMS_TB_DTENT_CB-YEAR_MIRO_EST.
                  ELSE.
                    MESSAGE I000 WITH TEXT-013.
                    VL_TYPED = '2TPEN'.
                  ENDIF.
                  CLEAR: WA_DOCMN.
                  READ TABLE T_DOCMN INTO WA_DOCMN WITH KEY MNEUM = 'FISCALYEAR'.
                  IF SY-SUBRC = 0.
                    ZHMS_TB_DTENT_CB-YEAR_MIRO = WA_DOCMN-VALUE.
                  ENDIF.
                ENDIF.
                IF NOT ZHMS_TB_DTENT_CB-DOC_MIGO IS INITIAL AND
                   NOT ZHMS_TB_DTENT_CB-DOC_MIRO IS INITIAL.
                  VL_TYPED = '3TCON'.
                ENDIF.

              ELSE.
                MESSAGE I000 WITH TEXT-011 TEXT-016.
                EXIT.
              ENDIF.
            ELSE.
              MESSAGE I000 WITH TEXT-011 TEXT-015.
              EXIT.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDFORM.                    " F_EXECUTA_FLUXO
*&---------------------------------------------------------------------*
*&      Form  F_SCANNER
*&---------------------------------------------------------------------*

    FORM F_SCANNER .
      CALL FUNCTION 'WS_FILENAME_GET'
        EXPORTING
          DEF_FILENAME     = P_ENTR
          DEF_PATH         = 'C:_line'
          MASK             = '*.*,*.*.'
          TITLE            = 'Pesquisar Arquivo'
        IMPORTING
          FILENAME         = P_ENTR
        EXCEPTIONS
          INV_WINSYS       = 1
          NO_BATCH         = 2
          SELECTION_CANCEL = 3
          SELECTION_ERROR  = 4
          OTHERS           = 5.

      REFRESH ITAB[].
      IF P_ENTR IS NOT INITIAL.

        MOVE P_ENTR TO FILENAME.
        CALL FUNCTION 'GUI_UPLOAD'
          EXPORTING
            FILENAME   = FILENAME
            FILETYPE   = 'BIN'
          IMPORTING
            FILELENGTH = LENGTH
          TABLES
            DATA_TAB   = ITAB.

      ENDIF.

    ENDFORM.                    " F_SCANNER
*&---------------------------------------------------------------------*
*&      Form  F_SAVE
*&---------------------------------------------------------------------*
    FORM F_SAVE .
      IF NOT ZHMS_TB_DTENT_CB-STCD1 IS INITIAL AND
         NOT ZHMS_TB_DTENT_CB-NFNUM IS INITIAL AND
         NOT ZHMS_TB_DTENT_CB-DTDOC IS INITIAL.
        CLEAR: VG_CHAVE.
        SELECT SINGLE * INTO WA_DTENT_CB FROM ZHMS_TB_DTENT_CB
        WHERE STCD1 = ZHMS_TB_DTENT_CB-STCD1
          AND NFNUM = ZHMS_TB_DTENT_CB-NFNUM
          AND DTDOC = ZHMS_TB_DTENT_CB-DTDOC.


        VG_NOTA = ZHMS_TB_DTENT_CB-NFNUM.
        REPLACE ALL OCCURRENCES OF '-' IN VG_NOTA WITH ''.
        SHIFT VG_NOTA RIGHT DELETING TRAILING SPACE.
        TRANSLATE VG_NOTA USING ' 0'.
        CONCATENATE VG_NOTA
                    ZHMS_TB_DTENT_CB-DTDOC+6(2)
                    ZHMS_TB_DTENT_CB-DTDOC+4(2)
                    ZHMS_TB_DTENT_CB-DTDOC(4)
                    ZHMS_TB_DTENT_CB-STCD1 INTO VG_CHAVE.
        ZHMS_TB_DTENT_CB-CHAVE = VG_CHAVE.
        CLEAR: WA_DOCMN.
        IF ZHMS_TB_DTENT_CB-SEQNR IS INITIAL.
          SELECT MAX( SEQNR )
           INTO V_SEQNR
            FROM ZHMS_TB_DTENT_CB.
          ZHMS_TB_DTENT_CB-SEQNR = V_SEQNR + 1.
          ZHMS_TB_DTENT_CB-DTCRIACAO = SY-DATUM.
          ZHMS_TB_DTENT_CB-UNAME     = SY-UNAME.
          INSERT INTO ZHMS_TB_DTENT_CB VALUES ZHMS_TB_DTENT_CB.

          LOOP AT T_ITEM INTO WA_ITEM.
            MOVE-CORRESPONDING: WA_ITEM TO WA_ITEM_AUX.
            WA_ITEM_AUX-SEQNR = ZHMS_TB_DTENT_CB-SEQNR.
            INSERT INTO ZHMS_TB_DTENT_IT VALUES WA_ITEM_AUX.
          ENDLOOP.
        ELSE.
          UPDATE ZHMS_TB_DTENT_CB FROM ZHMS_TB_DTENT_CB.
          LOOP AT T_ITEM INTO WA_ITEM.
            WA_ITEM_AUX-CHAVE = VG_CHAVE.
            MOVE-CORRESPONDING: WA_ITEM TO WA_ITEM_AUX.
            WA_ITEM_AUX-SEQNR = ZHMS_TB_DTENT_CB-SEQNR.
            SELECT SINGLE * INTO WA_ITEM_IT FROM ZHMS_TB_DTENT_IT WHERE SEQNR EQ WA_ITEM_AUX-SEQNR
                                                    AND EBELN EQ WA_ITEM_AUX-EBELN
                                                    AND EBELP EQ WA_ITEM_AUX-EBELP.
            IF SY-SUBRC = 0.
              UPDATE ZHMS_TB_DTENT_IT FROM WA_ITEM_AUX.
            ELSE.
              INSERT INTO ZHMS_TB_DTENT_IT VALUES WA_ITEM_AUX.
            ENDIF.
          ENDLOOP.

          LOOP AT T_ITEM_IT INTO WA_ITEM_IT.
            READ TABLE T_ITEM INTO WA_ITEM WITH KEY EBELN = WA_ITEM_IT-EBELN
                                                    EBELP = WA_ITEM_IT-EBELP.
            IF SY-SUBRC <> 0.
              DELETE FROM ZHMS_TB_DTENT_IT WHERE SEQNR EQ ZHMS_TB_DTENT_CB-SEQNR
                                             AND EBELN EQ WA_ITEM_IT-EBELN
                                             AND EBELP EQ WA_ITEM_IT-EBELP.
              COMMIT WORK.
            ENDIF.
          ENDLOOP.

        ENDIF.
      ENDIF.
    ENDFORM.                    " F_SAVE
*&---------------------------------------------------------------------*
*&      Form  F_SEL_ITEN
*&---------------------------------------------------------------------*
    FORM F_SEL_ITEN .
      READ TABLE T_SELEC INTO WA_SELEC WITH KEY SEL = 'X'.
      IF SY-SUBRC = 0.
*Seleciona dados do cabeçalho
        SELECT SINGLE * FROM ZHMS_TB_DTENT_CB WHERE SEQNR EQ WA_SELEC-SEQNR.
        IF NOT ZHMS_TB_DTENT_CB-STCD1 IS INITIAL.

          SELECT SINGLE * FROM LFA1
          INTO WA_LFA1
          WHERE STCD1 EQ ZHMS_TB_DTENT_CB-STCD1.
          IF SY-SUBRC EQ 0.
            ZHMS_TB_DTENT_CB-PARTNER = WA_LFA1-LIFNR.
***       Busca pedidos liberados para o fornecedor
            REFRESH T_EKKO.
            SELECT EBELN LIFNR BUKRS AEDAT  FROM EKKO
            INTO TABLE T_EKKO
            WHERE LIFNR EQ ZHMS_TB_DTENT_CB-PARTNER
              AND STATU EQ '9'.
            IF SY-SUBRC EQ 0.
              SORT T_EKKO BY EBELN.
            ENDIF.

          ENDIF.

        ENDIF.
*Seleciona dados dos itens e monta tabela t_item da tela
        SELECT * INTO TABLE T_ITEM_IT FROM ZHMS_TB_DTENT_IT WHERE SEQNR EQ WA_SELEC-SEQNR.
        LOOP AT T_ITEM_IT INTO WA_ITEM_AUX.
          MOVE-CORRESPONDING WA_ITEM_AUX TO WA_ITEM.
          APPEND WA_ITEM TO T_ITEM.
        ENDLOOP.
        MOVE: '0101' TO VG_0150.
        LEAVE TO SCREEN 0.
      ELSE.
        MESSAGE E000 WITH TEXT-001.
      ENDIF.
    ENDFORM.                    " F_SEL_ITEN
*&---------------------------------------------------------------------*
*&      Form  F_EST_MIGO
*&---------------------------------------------------------------------*

    FORM F_EST_MIGO .
      DATA: LS_HEADRET        TYPE BAPI2017_GM_HEAD_RET,
            LT_RET_EST_MIGO   TYPE STANDARD TABLE OF BAPIRET2,
            LS_RET_EST_MIGO   TYPE BAPIRET2,
            LV_ANSWER         TYPE C,
            LS_SCEN_FLO       TYPE ZHMS_TB_SCEN_FLO.

      REFRESH: LT_RET_EST_MIGO.
      CLEAR: LT_RET_EST_MIGO, LS_RET_EST_MIGO.
*** Pop-up de confirmação do estorno
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          TITLEBAR              = TEXT-Q01
          TEXT_QUESTION         = TEXT-Q10
          TEXT_BUTTON_1         = TEXT-Q03
          ICON_BUTTON_1         = 'ICON_CHECKED'
          TEXT_BUTTON_2         = TEXT-Q04
          ICON_BUTTON_2         = 'ICON_INCOMPLETE'
          DEFAULT_BUTTON        = '2'
          DISPLAY_CANCEL_BUTTON = ' '
        IMPORTING
          ANSWER                = LV_ANSWER
        EXCEPTIONS
          TEXT_NOT_FOUND        = 1
          OTHERS                = 2.

      CHECK LV_ANSWER EQ 1.

      SELECT SINGLE * INTO LS_SCEN_FLO
        FROM ZHMS_TB_SCEN_FLO
         WHERE NATDC = '02'
           AND TYPED = 'NFET'
           AND SCENA = '10'
           AND FLOWD = '30'.

*** Verifica Autorização usuario
      CALL FUNCTION 'ZHMS_FM_SECURITY'
        EXPORTING
          VALUE         = 'ESTORNO_MIGO'
        EXCEPTIONS
          AUTHORIZATION = 1
          OTHERS        = 2.

      IF SY-SUBRC <> 0.
        MESSAGE E000(ZHMS_SECURITY). "
      ENDIF.


*** Executa extorno da MIGO
      CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
        EXPORTING
          MATERIALDOCUMENT = ZHMS_TB_DTENT_CB-DOC_MIGO
          MATDOCUMENTYEAR  = ZHMS_TB_DTENT_CB-YEAR_MIGO
        IMPORTING
          GOODSMVT_HEADRET = LS_HEADRET
        TABLES
          RETURN           = LT_RET_EST_MIGO.

*** Verifica caso ERRO
      READ TABLE LT_RET_EST_MIGO INTO LS_RET_EST_MIGO WITH KEY TYPE =
'E'.

      IF SY-SUBRC IS INITIAL.
*** Grava log de erro
*        PERFORM F_GRAVA_LOG TABLES LT_RETURN USING:
*                                   LS_RETURN
*                                   WA_FLWDOC_AX-NATDC
*                                   WA_FLWDOC_AX-TYPED
*                                   LS_SCEN_FLO-LOCTP
*                                   LV_CHAVE.

        MESSAGE LS_RET_EST_MIGO-MESSAGE TYPE 'I'.
        EXIT.
      ELSE.
*** Caso sucesso grava operação
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = 'X'.

*** Modifica Tabela ZHMS_TB_DOCMN
        IF NOT LS_HEADRET IS INITIAL.

          DELETE FROM ZHMS_TB_DOCMN WHERE CHAVE EQ ZHMS_TB_DTENT_CB-CHAVE
                                 AND MNEUM EQ LS_SCEN_FLO-MNDOC.

*** Commit banco de dados
          IF SY-SUBRC IS INITIAL.
            COMMIT WORK.
          ELSE.
            ROLLBACK WORK.
          ENDIF.

**** Muda Status da etapa
          MOVE: LS_SCEN_FLO-NATDC      TO WA_FLWDOC-NATDC,
                LS_SCEN_FLO-TYPED      TO WA_FLWDOC-TYPED,
                ZHMS_TB_DTENT_CB-CHAVE TO WA_FLWDOC-CHAVE,
                LS_SCEN_FLO-FLOWD      TO WA_FLWDOC-FLOWD,
                SY-DATUM               TO WA_FLWDOC-DTREG,
                SY-UZEIT               TO WA_FLWDOC-HRREG,
                SY-UNAME               TO WA_FLWDOC-UNAME,
                'W'                    TO WA_FLWDOC-FLWST.
          MODIFY ZHMS_TB_FLWDOC FROM WA_FLWDOC.
          CLEAR WA_FLWDOC.

          IF SY-SUBRC IS INITIAL.
            COMMIT WORK.
          ELSE.
            ROLLBACK WORK.
          ENDIF.

          CLEAR: ZHMS_TB_DTENT_CB-DOC_MIGO, ZHMS_TB_DTENT_CB-YEAR_MIGO.
          ZHMS_TB_DTENT_CB-DOC_MIGO_EST  = LS_HEADRET-MAT_DOC.
          ZHMS_TB_DTENT_CB-YEAR_MIGO_EST = LS_HEADRET-DOC_YEAR.
          PERFORM F_SAVE.
        ENDIF.
      ENDIF.
    ENDFORM.                    " F_EST_MIGO
*&---------------------------------------------------------------------*
*&      Form  F_GRAVA_DOCMN
*&---------------------------------------------------------------------*
*      Grava dados na tabela ZHMS_TB_DOCMN
*----------------------------------------------------------------------*
    FORM F_GRAVA_DOCMN .


      CLEAR: WA_DOCMN, T_DOCMN, WA_DOCMN_AUX, T_DOCMN_AUX.
      REFRESH: T_DOCMN, T_DOCMN_AUX.
*      SELECT *
*        INTO TABLE T_DOCMN_AUX
*        FROM ZHMS_TB_DOCMN
*      WHERE CHAVE = VG_CHAVE.
      IF NOT VG_CHAVE IS INITIAL.

        DELETE FROM ZHMS_TB_DOCMN WHERE CHAVE = VG_CHAVE.

      ENDIF.
*Grava dados do cabeçalho da Entrada Manual na tabela ZHMS_TB_DOCMN do HomSoft automatico
*Numero da NF
      CLEAR: WA_DOCMN.
      WA_DOCMN-CHAVE = VG_CHAVE.
      WA_DOCMN-SEQNR = '00001'.
      WA_DOCMN-MNEUM = 'NUMERO'.
      WA_DOCMN-DCITM = '000000'.
      WA_DOCMN-ATITM = '000000'.
      WA_DOCMN-VALUE = ZHMS_TB_DTENT_CB-NFNUM.
      CLEAR: WA_DOCMN_AUX.
*      READ TABLE T_DOCMN_AUX INTO WA_DOCMN_AUX WITH KEY CHAVE = WA_DOCMN-CHAVE
*                                                        SEQNR = WA_DOCMN-SEQNR
*                                                        MNEUM = WA_DOCMN-MNEUM.
*      IF SY-SUBRC = 0.
*        UPDATE ZHMS_TB_DOCMN FROM WA_DOCMN.
*      ELSE.
      INSERT INTO ZHMS_TB_DOCMN VALUES WA_DOCMN.
*      ENDIF.


*Data
      CLEAR: WA_DOCMN.
      WA_DOCMN-CHAVE = VG_CHAVE.
      WA_DOCMN-SEQNR = '00002'.
      WA_DOCMN-MNEUM = 'DATAEMISSAO'.
      WA_DOCMN-DCITM = '000000'.
      WA_DOCMN-ATITM = '000000'.
      WA_DOCMN-VALUE = ZHMS_TB_DTENT_CB-DTLANC.
      CLEAR: WA_DOCMN_AUX.
*      READ TABLE T_DOCMN_AUX INTO WA_DOCMN_AUX WITH KEY CHAVE = WA_DOCMN-CHAVE
*                                                        SEQNR = WA_DOCMN-SEQNR
*                                                        MNEUM = WA_DOCMN-MNEUM.
*      IF SY-SUBRC = 0.
*        UPDATE ZHMS_TB_DOCMN FROM WA_DOCMN.
*      ELSE.
      INSERT INTO ZHMS_TB_DOCMN VALUES WA_DOCMN.
*      ENDIF.


*Valor Total
      CLEAR: WA_DOCMN.
      WA_DOCMN-CHAVE = VG_CHAVE.
      WA_DOCMN-SEQNR = '00003'.
      WA_DOCMN-MNEUM = 'VALORSERVICO'.
      WA_DOCMN-DCITM = '000000'.
      WA_DOCMN-ATITM = '000000'.
      WA_DOCMN-VALUE = ZHMS_TB_DTENT_CB-VALOR.
*      CLEAR: WA_DOCMN_AUX.
*      READ TABLE T_DOCMN_AUX INTO WA_DOCMN_AUX WITH KEY CHAVE = WA_DOCMN-CHAVE
*                                                        SEQNR = WA_DOCMN-SEQNR
*                                                        MNEUM = WA_DOCMN-MNEUM.
*      IF SY-SUBRC = 0.
*        UPDATE ZHMS_TB_DOCMN FROM WA_DOCMN.
*      ELSE.
      INSERT INTO ZHMS_TB_DOCMN VALUES WA_DOCMN.
*      ENDIF.


*CNPJ
      CLEAR: WA_DOCMN.
      WA_DOCMN-CHAVE = VG_CHAVE.
      WA_DOCMN-SEQNR = '00004'.
      WA_DOCMN-MNEUM = 'VALORSERVICO'.
      WA_DOCMN-DCITM = '000000'.
      WA_DOCMN-ATITM = '000000'.
      WA_DOCMN-VALUE = ZHMS_TB_DTENT_CB-STCD1.
      CLEAR: WA_DOCMN_AUX.
*      READ TABLE T_DOCMN_AUX INTO WA_DOCMN_AUX WITH KEY CHAVE = WA_DOCMN-CHAVE
*                                                        SEQNR = WA_DOCMN-SEQNR
*                                                        MNEUM = WA_DOCMN-MNEUM.
*      IF SY-SUBRC = 0.
*        UPDATE ZHMS_TB_DOCMN FROM WA_DOCMN.
*      ELSE.
      INSERT INTO ZHMS_TB_DOCMN VALUES WA_DOCMN.
*      ENDIF.


      VG_ATITM = '000000'.
      VG_SEQNR = '00004'.
      CLEAR: VG_ATITMPROC.
      LOOP AT T_ITEM INTO WA_ITEM.

        ADD 1 TO VG_ATITM.
*Quantidade
        CLEAR: WA_DOCMN.
        ADD 1 TO VG_SEQNR.
        WA_DOCMN-CHAVE = VG_CHAVE.
        WA_DOCMN-SEQNR = VG_SEQNR.
        WA_DOCMN-MNEUM = 'ATQTD'.
        WA_DOCMN-DCITM = '000001'.
        WA_DOCMN-ATITM = VG_ATITM.
        WA_DOCMN-VALUE = WA_ITEM-MENGE.
        CLEAR: WA_DOCMN_AUX.
*        READ TABLE T_DOCMN_AUX INTO WA_DOCMN_AUX WITH KEY CHAVE = WA_DOCMN-CHAVE
*                                                          SEQNR = WA_DOCMN-SEQNR
*                                                          MNEUM = WA_DOCMN-MNEUM
*                                                          ATITM = WA_DOCMN-ATITM.
*        IF SY-SUBRC = 0.
*          UPDATE ZHMS_TB_DOCMN FROM WA_DOCMN.
*        ELSE.
        INSERT INTO ZHMS_TB_DOCMN VALUES WA_DOCMN.
*        ENDIF.


        CLEAR: WA_DOCMN.
        ADD 1 TO VG_SEQNR.
        WA_DOCMN-CHAVE = VG_CHAVE.
        WA_DOCMN-SEQNR = VG_SEQNR.
        WA_DOCMN-MNEUM = 'ATUM'.
        WA_DOCMN-DCITM = '000001'.
        WA_DOCMN-ATITM = VG_ATITM.
        WA_DOCMN-VALUE = WA_ITEM-MEINS.
        CLEAR: WA_DOCMN_AUX.
*        READ TABLE T_DOCMN_AUX INTO WA_DOCMN_AUX WITH KEY CHAVE = WA_DOCMN-CHAVE
*                                                          SEQNR = WA_DOCMN-SEQNR
*                                                          MNEUM = WA_DOCMN-MNEUM
*                                                          ATITM = WA_DOCMN-ATITM.
*        IF SY-SUBRC = 0.
*          UPDATE ZHMS_TB_DOCMN FROM WA_DOCMN.
*        ELSE.
        INSERT INTO ZHMS_TB_DOCMN VALUES WA_DOCMN.
*        ENDIF.

        CLEAR: WA_DOCMN.
        ADD 1 TO VG_SEQNR.
        WA_DOCMN-CHAVE = VG_CHAVE.
        WA_DOCMN-SEQNR = VG_SEQNR.
        WA_DOCMN-MNEUM = 'ATPED'.
        WA_DOCMN-DCITM = '000001'.
        WA_DOCMN-ATITM = VG_ATITM.
        WA_DOCMN-VALUE = WA_ITEM-EBELN.
        CLEAR: WA_DOCMN_AUX.
*        READ TABLE T_DOCMN_AUX INTO WA_DOCMN_AUX WITH KEY CHAVE = WA_DOCMN-CHAVE
*                                                          SEQNR = WA_DOCMN-SEQNR
*                                                          MNEUM = WA_DOCMN-MNEUM
*                                                          ATITM = WA_DOCMN-ATITM.
*        IF SY-SUBRC = 0.
*          UPDATE ZHMS_TB_DOCMN FROM WA_DOCMN.
*        ELSE.
        INSERT INTO ZHMS_TB_DOCMN VALUES WA_DOCMN.
*        ENDIF.

        CLEAR: WA_DOCMN.
        ADD 1 TO VG_SEQNR.
        WA_DOCMN-CHAVE = VG_CHAVE.
        WA_DOCMN-SEQNR = VG_SEQNR.
        WA_DOCMN-MNEUM = 'ATITMPED'.
        WA_DOCMN-DCITM = '000001'.
        WA_DOCMN-ATITM = VG_ATITM.
        WA_DOCMN-VALUE = WA_ITEM-EBELP.
        CLEAR: WA_DOCMN_AUX.
*        READ TABLE T_DOCMN_AUX INTO WA_DOCMN_AUX WITH KEY CHAVE = WA_DOCMN-CHAVE
*                                                          SEQNR = WA_DOCMN-SEQNR
*                                                          MNEUM = WA_DOCMN-MNEUM
*                                                          ATITM = WA_DOCMN-ATITM.
*        IF SY-SUBRC = 0.
*          UPDATE ZHMS_TB_DOCMN FROM WA_DOCMN.
*        ELSE.
        INSERT INTO ZHMS_TB_DOCMN VALUES WA_DOCMN.
*        ENDIF.

        CLEAR: WA_DOCMN.
        ADD 1 TO VG_SEQNR.
        ADD 1 TO VG_ATITMPROC.
        WA_DOCMN-CHAVE = VG_CHAVE.
        WA_DOCMN-SEQNR = VG_SEQNR.
        WA_DOCMN-MNEUM = 'ATITMPROC'.
        WA_DOCMN-DCITM = '000001'.
        WA_DOCMN-ATITM = VG_ATITM.
        WA_DOCMN-VALUE = VG_ATITMPROC.
        CLEAR: WA_DOCMN_AUX.
*        READ TABLE T_DOCMN_AUX INTO WA_DOCMN_AUX WITH KEY CHAVE = WA_DOCMN-CHAVE
*                                                          SEQNR = WA_DOCMN-SEQNR
*                                                          MNEUM = WA_DOCMN-MNEUM
*                                                          ATITM = WA_DOCMN-ATITM.
*        IF SY-SUBRC = 0.
*          UPDATE ZHMS_TB_DOCMN FROM WA_DOCMN.
*        ELSE.
        INSERT INTO ZHMS_TB_DOCMN VALUES WA_DOCMN.
*        ENDIF.


        CLEAR: WA_DOCMN.
        ADD 1 TO VG_SEQNR.
        WA_DOCMN-CHAVE = VG_CHAVE.
        WA_DOCMN-SEQNR = VG_SEQNR.
        WA_DOCMN-MNEUM = 'ATVLR'.
        WA_DOCMN-DCITM = '000001'.
        WA_DOCMN-ATITM = VG_ATITM.
        WA_DOCMN-VALUE = WA_ITEM-NETWR.
        CLEAR: WA_DOCMN_AUX.
*        READ TABLE T_DOCMN_AUX INTO WA_DOCMN_AUX WITH KEY CHAVE = WA_DOCMN-CHAVE
*                                                          SEQNR = WA_DOCMN-SEQNR
*                                                          MNEUM = WA_DOCMN-MNEUM
*                                                          ATITM = WA_DOCMN-ATITM.
*        IF SY-SUBRC = 0.
*          UPDATE ZHMS_TB_DOCMN FROM WA_DOCMN.
*        ELSE.
        INSERT INTO ZHMS_TB_DOCMN VALUES WA_DOCMN.
*        ENDIF.

        CLEAR: WA_DOCMN.
        ADD 1 TO VG_SEQNR.
        WA_DOCMN-CHAVE = VG_CHAVE.
        WA_DOCMN-SEQNR = VG_SEQNR.
        WA_DOCMN-MNEUM = 'ATTLOT'.
        WA_DOCMN-DCITM = '000001'.
        WA_DOCMN-ATITM = VG_ATITM.
        CONCATENATE WA_ITEM-EBELN '/' WA_ITEM-EBELP INTO WA_DOCMN-VALUE.
        CLEAR: WA_DOCMN_AUX.
*        READ TABLE T_DOCMN_AUX INTO WA_DOCMN_AUX WITH KEY CHAVE = WA_DOCMN-CHAVE
*                                                          SEQNR = WA_DOCMN-SEQNR
*                                                          MNEUM = WA_DOCMN-MNEUM
*                                                          ATITM = WA_DOCMN-ATITM.
*        IF SY-SUBRC = 0.
*          UPDATE ZHMS_TB_DOCMN FROM WA_DOCMN.
*        ELSE.
        INSERT INTO ZHMS_TB_DOCMN VALUES WA_DOCMN.
*        ENDIF.
      ENDLOOP.

    if not zhms_tb_dtent_cb-DOC_MIGO is INITIAL.
      CLEAR: WA_DOCMN.
        ADD 1 TO VG_SEQNR.
        WA_DOCMN-CHAVE = VG_CHAVE.
        WA_DOCMN-SEQNR = VG_SEQNR.
        WA_DOCMN-MNEUM = 'MATDOC'.
        WA_DOCMN-DCITM = '000000'.
        WA_DOCMN-ATITM = '000000'.
        WA_DOCMN-VALUE = zhms_tb_dtent_cb-DOC_MIGO.
        CLEAR: WA_DOCMN_AUX.

        INSERT INTO ZHMS_TB_DOCMN VALUES WA_DOCMN.

        CLEAR: WA_DOCMN.
        ADD 1 TO VG_SEQNR.
        WA_DOCMN-CHAVE = VG_CHAVE.
        WA_DOCMN-SEQNR = VG_SEQNR.
        WA_DOCMN-MNEUM = 'MATDOCYEA'.
        WA_DOCMN-DCITM = '000000'.
        WA_DOCMN-ATITM = '000000'.
        WA_DOCMN-VALUE = zhms_tb_dtent_cb-YEAR_MIGO.
        CLEAR: WA_DOCMN_AUX.

        INSERT INTO ZHMS_TB_DOCMN VALUES WA_DOCMN.
    endif.
    ENDFORM.                    " F_GRAVA_DOCMN
*&---------------------------------------------------------------------*
*&      Form  F_GRAVA_CABDOC
*&---------------------------------------------------------------------*
*   Grava dados na tabela ZHMS_TB_CABDOC
*----------------------------------------------------------------------*
    FORM F_GRAVA_CABDOC .
      CLEAR: WA_CABDOC.
      WA_CABDOC-CHAVE = VG_CHAVE.
      WA_CABDOC-NATDC = '02'.
      WA_CABDOC-TYPED = 'NFET'.

      READ TABLE T_ITEM INTO WA_ITEM INDEX 1.
      WA_CABDOC-BUKRS = WA_ITEM-BUKRS.
      WA_CABDOC-PARID = ZHMS_TB_DTENT_CB-PARTNER.
      WA_CABDOC-DOCNR = VG_NOTA.
      WA_CABDOC-DOCDT = ZHMS_TB_DTENT_CB-DTDOC.
      WA_CABDOC-LNCDT = ZHMS_TB_DTENT_CB-DTLANC.
      SELECT SINGLE SCENA
        INTO WA_CABDOC-SCENA
        FROM ZHMS_TB_SCENARIO
        WHERE NATDC = '02'
          AND TYPED = 'NFET'.
      INSERT INTO ZHMS_TB_CABDOC VALUES WA_CABDOC.
    ENDFORM.                    " F_GRAVA_CABDOC
*&---------------------------------------------------------------------*
*&      Form  F_GRAVA_ITMDOC
*&---------------------------------------------------------------------*
*       Grava dados a tabela ZHMS_TB_ITMDOC
*----------------------------------------------------------------------*
    FORM F_GRAVA_ITMDOC .

      CLEAR: WA_ITMDOC.
      WA_ITMDOC-CHAVE = VG_CHAVE.
      WA_ITMDOC-NATDC = '02'.
      WA_ITMDOC-TYPED = 'NFET'.
      WA_ITMDOC-DCITM = '1'.
      WA_ITMDOC-DCPRC = ZHMS_TB_DTENT_CB-VALOR.
      INSERT INTO ZHMS_TB_ITMDOC VALUES WA_ITMDOC.

    ENDFORM.                    " F_GRAVA_ITMDOC
*&---------------------------------------------------------------------*
*&      Form  F_GRAVA_ITMATR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    FORM F_GRAVA_ITMATR .
      CLEAR: VG_SEQNR.

      IF NOT VG_CHAVE IS INITIAL.

        DELETE FROM ZHMS_TB_ITMATR WHERE CHAVE = VG_CHAVE
                                    AND  NATDC = '02'
                                    AND  TYPED = 'NFET'.

      ENDIF.

      LOOP AT T_ITEM INTO WA_ITEM.
        ADD 1 TO VG_SEQNR.
        WA_ITMATR-CHAVE = VG_CHAVE.
        WA_ITMATR-NATDC = '02'.
        WA_ITMATR-TYPED = 'NFET'.
        WA_ITMATR-DCITM = '1'.
        WA_ITMATR-SEQNR = VG_SEQNR.
        WA_ITMATR-TDSRF = '1'.
        WA_ITMATR-NRSRF = WA_ITEM-EBELN.
        WA_ITMATR-ITSRF = WA_ITEM-EBELP.
        WA_ITMATR-ATQTD = WA_ITEM-MENGE.
        WA_ITMATR-ATUNM = 'H'.
        WA_ITMATR-ATPRC = WA_ITEM-NETPR.
        WA_ITMATR-ATLOT = WA_ITEM-EBELN.
        WA_ITMATR-ATITM = VG_SEQNR.
        INSERT INTO ZHMS_TB_ITMATR VALUES WA_ITMATR.
      ENDLOOP.

    ENDFORM.                    " F_GRAVA_ITMATR
*&---------------------------------------------------------------------*
*&      Form  F_EST_MIRO
*&---------------------------------------------------------------------*
    FORM F_EST_MIRO .

      DATA: LS_HEADRET        TYPE BAPI2017_GM_HEAD_RET,
            LT_RET_EST_MIRO   TYPE STANDARD TABLE OF BAPIRET2,
            LS_RET_EST_MIRO   TYPE BAPIRET2,
            LV_ANSWER         TYPE C,
            LV_REASON         TYPE STGRD,
            LS_SCEN_FLO       TYPE ZHMS_TB_SCEN_FLO.

      REFRESH: LT_RET_EST_MIRO.
      CLEAR: LT_RET_EST_MIRO, LS_RET_EST_MIRO.
*** Pop-up de confirmação do estorno
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          TITLEBAR              = TEXT-Q01
          TEXT_QUESTION         = TEXT-Q10
          TEXT_BUTTON_1         = TEXT-Q03
          ICON_BUTTON_1         = 'ICON_CHECKED'
          TEXT_BUTTON_2         = TEXT-Q04
          ICON_BUTTON_2         = 'ICON_INCOMPLETE'
          DEFAULT_BUTTON        = '2'
          DISPLAY_CANCEL_BUTTON = ' '
        IMPORTING
          ANSWER                = LV_ANSWER
        EXCEPTIONS
          TEXT_NOT_FOUND        = 1
          OTHERS                = 2.

      CHECK LV_ANSWER EQ 1.

*** Verifica Autorização usuario
      CALL FUNCTION 'ZHMS_FM_SECURITY'
        EXPORTING
          VALUE         = 'ESTORNO_MIRO'
        EXCEPTIONS
          AUTHORIZATION = 1
          OTHERS        = 2.

      IF SY-SUBRC <> 0.
        MESSAGE E000(ZHMS_SECURITY). "
      ENDIF.

      SELECT SINGLE * INTO LS_SCEN_FLO
       FROM ZHMS_TB_SCEN_FLO
        WHERE NATDC = '02'
          AND TYPED = 'NFET'
          AND SCENA = '10'
          AND FLOWD = '40'.
      IF SY-SUBRC = 0.
*** Busca mapeamento para esse cenario
        SELECT SINGLE VLFIX INTO LV_REASON FROM ZHMS_TB_MAPDATA
          WHERE CODMP EQ LS_SCEN_FLO-CODMP_ESTORNO
            AND TBFLD = 'REASONREVERSAL'.
      ENDIF.


*** Executa extorno da MIRO
      CALL FUNCTION 'BAPI_INCOMINGINVOICE_CANCEL'
        EXPORTING
          INVOICEDOCNUMBER          = ZHMS_TB_DTENT_CB-DOC_MIRO
          FISCALYEAR                = ZHMS_TB_DTENT_CB-YEAR_MIRO
          REASONREVERSAL            = LV_REASON
        IMPORTING
          INVOICEDOCNUMBER_REVERSAL = LS_HEADRET-MAT_DOC
          FISCALYEAR_REVERSAL       = LS_HEADRET-DOC_YEAR
        TABLES
          RETURN                    = LT_RET_EST_MIRO.


*** Verifica caso ERRO
      READ TABLE LT_RET_EST_MIRO INTO LS_RET_EST_MIRO WITH KEY TYPE =
'E'.

      IF SY-SUBRC IS INITIAL.
*** Grava log de erro
*        PERFORM F_GRAVA_LOG TABLES LT_RETURN USING:
*                                   LS_RETURN
*                                   WA_FLWDOC_AX-NATDC
*                                   WA_FLWDOC_AX-TYPED
*                                   LS_SCEN_FLO-LOCTP
*                                   LV_CHAVE.



        MESSAGE LS_RET_EST_MIRO-MESSAGE TYPE 'I'.
        EXIT.
      ELSE.
*** Caso sucesso grava operação
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = 'X'.

*** Modifica Tabela ZHMS_TB_DOCMN
        IF NOT LS_HEADRET IS INITIAL.

          DELETE FROM ZHMS_TB_DOCMN WHERE CHAVE EQ ZHMS_TB_DTENT_CB-CHAVE
                              AND MNEUM EQ LS_SCEN_FLO-MNDOC.
*** Commit banco de dados
          IF SY-SUBRC IS INITIAL.
            COMMIT WORK.
          ELSE.
            ROLLBACK WORK.
          ENDIF.
        ENDIF.
*** Muda Status da etapa
        MOVE: LS_SCEN_FLO-NATDC      TO WA_FLWDOC-NATDC,
              LS_SCEN_FLO-TYPED      TO WA_FLWDOC-TYPED,
              ZHMS_TB_DTENT_CB-CHAVE TO WA_FLWDOC-CHAVE,
              LS_SCEN_FLO-FLOWD      TO WA_FLWDOC-FLOWD,
              SY-DATUM               TO WA_FLWDOC-DTREG,
              SY-UZEIT               TO WA_FLWDOC-HRREG,
              SY-UNAME               TO WA_FLWDOC-UNAME,
              'W'                    TO WA_FLWDOC-FLWST.
        MODIFY ZHMS_TB_FLWDOC FROM WA_FLWDOC.

        IF SY-SUBRC IS INITIAL.
          COMMIT WORK.
        ELSE.
          ROLLBACK WORK.
        ENDIF.
        CLEAR: ZHMS_TB_DTENT_CB-DOC_MIRO, ZHMS_TB_DTENT_CB-YEAR_MIRO.
        ZHMS_TB_DTENT_CB-DOC_MIRO_EST  = LS_HEADRET-MAT_DOC.
        ZHMS_TB_DTENT_CB-YEAR_MIRO_EST = LS_HEADRET-DOC_YEAR.
        PERFORM F_SAVE.
      ENDIF.


    ENDFORM.                    " F_EST_MIRO
*&---------------------------------------------------------------------*
*&      Form  F_DRILL_DOC
*&---------------------------------------------------------------------*
    FORM F_DRILL_DOC .
      CLEAR: FLD, LIN.
      GET CURSOR FIELD FLD.
      GET CURSOR LINE LIN.
      IF FLD = 'ZHMS_TB_DTENT_CB-DOC_MIGO'.
        IF NOT ZHMS_TB_DTENT_CB-DOC_MIGO IS INITIAL.
          SET PARAMETER ID: 'MBN' FIELD ZHMS_TB_DTENT_CB-DOC_MIGO,
                            'MJA' FIELD ZHMS_TB_DTENT_CB-YEAR_MIGO.

          CALL TRANSACTION 'MB03' AND SKIP FIRST SCREEN.
        ENDIF.
      ELSEIF FLD = 'ZHMS_TB_DTENT_CB-DOC_MIGO_EST'.
        IF NOT ZHMS_TB_DTENT_CB-DOC_MIGO_EST IS INITIAL.
          SET PARAMETER ID: 'MBN' FIELD ZHMS_TB_DTENT_CB-DOC_MIGO_EST,
                            'MJA' FIELD ZHMS_TB_DTENT_CB-YEAR_MIGO_EST.

          CALL TRANSACTION 'MB03' AND SKIP FIRST SCREEN.
        ENDIF.
      ELSEIF FLD = 'ZHMS_TB_DTENT_CB-DOC_MIRO'.
        IF NOT ZHMS_TB_DTENT_CB-DOC_MIRO IS INITIAL.
          SET PARAMETER ID: 'RBN' FIELD ZHMS_TB_DTENT_CB-DOC_MIRO,
                            'GJR' FIELD ZHMS_TB_DTENT_CB-YEAR_MIRO.

          CALL TRANSACTION 'MIR4' AND SKIP FIRST SCREEN.
        ENDIF.
      ELSEIF FLD = 'ZHMS_TB_DTENT_CB-DOC_MIRO_EST'.
        IF NOT ZHMS_TB_DTENT_CB-DOC_MIRO_EST IS INITIAL.
          SET PARAMETER ID: 'RBN' FIELD ZHMS_TB_DTENT_CB-DOC_MIRO_EST,
                            'GJR' FIELD ZHMS_TB_DTENT_CB-YEAR_MIRO_EST.

          CALL TRANSACTION 'MIR4' AND SKIP FIRST SCREEN.
        ENDIF.

      ELSEIF FLD = 'WA_ITEM-EBELN'.
        READ TABLE T_ITEM INTO WA_ITEM INDEX LIN.
        IF SY-SUBRC = 0.
          SET PARAMETER ID 'BES' FIELD WA_ITEM-EBELN..

          CALL TRANSACTION 'ME23N'.
        ENDIF.
      ENDIF.
    ENDFORM.                    " F_DRILL_DOC
*&---------------------------------------------------------------------*
*&      Form  F_SEL_ITEN_DRILL
*&---------------------------------------------------------------------*
    FORM F_SEL_ITEN_DRILL .
      READ TABLE T_SELEC INTO WA_SELEC INDEX LIN_S.
      IF SY-SUBRC = 0.
*Seleciona dados do cabeçalho
        SELECT SINGLE * FROM ZHMS_TB_DTENT_CB WHERE SEQNR EQ WA_SELEC-SEQNR.
        IF NOT ZHMS_TB_DTENT_CB-STCD1 IS INITIAL.

          SELECT SINGLE * FROM LFA1
          INTO WA_LFA1
          WHERE STCD1 EQ ZHMS_TB_DTENT_CB-STCD1.
          IF SY-SUBRC EQ 0.
            ZHMS_TB_DTENT_CB-PARTNER = WA_LFA1-LIFNR.
***       Busca pedidos liberados para o fornecedor
            REFRESH T_EKKO.
            SELECT EBELN LIFNR BUKRS AEDAT  FROM EKKO
            INTO TABLE T_EKKO
            WHERE LIFNR EQ ZHMS_TB_DTENT_CB-PARTNER
              AND STATU EQ '9'.
            IF SY-SUBRC EQ 0.
              SORT T_EKKO BY EBELN.
            ENDIF.

          ENDIF.

        ENDIF.
*Seleciona dados dos itens e monta tabela t_item da tela
        SELECT * INTO TABLE T_ITEM_IT FROM ZHMS_TB_DTENT_IT WHERE SEQNR EQ WA_SELEC-SEQNR.
        LOOP AT T_ITEM_IT INTO WA_ITEM_AUX.
          MOVE-CORRESPONDING WA_ITEM_AUX TO WA_ITEM.
          APPEND WA_ITEM TO T_ITEM.
        ENDLOOP.
        MOVE: '0101' TO VG_0150.
        LEAVE TO SCREEN 0.
      ENDIF.

    ENDFORM.                    " F_SEL_ITEN_DRILL
*&---------------------------------------------------------------------*
*&      Form  F_SEL_PEDIDO
*&---------------------------------------------------------------------*
    FORM F_SEL_PEDIDO .

      IF NOT ZHMS_TB_DTENT_CB-STCD1 IS INITIAL.
        REFRESH: T_SHOW_PO.
        CLEAR: T_SHOW_PO.
        CALL FUNCTION 'ZHMS_FM_BUSCA_PO_POSSIVEIS_DTE'
          EXPORTING
            STCD1     = ZHMS_TB_DTENT_CB-STCD1
*           EBELN     = ZHMS_TB_DTENT_CB-EBELN
          TABLES
            T_SHOW_PO = T_SHOW_PO.

        IF NOT V_EBELN IS INITIAL.
          DELETE T_SHOW_PO WHERE EBELN <> V_EBELN.
        ENDIF.
      ELSE.
        IF NOT V_EBELN IS INITIAL.
          SELECT SINGLE LIFNR
            INTO V_LIFNR
            FROM EKKO
            WHERE EBELN = V_EBELN.

          IF NOT V_LIFNR IS INITIAL.
            SELECT SINGLE STCD1
            INTO V_STCD1
              FROM LFA1
              WHERE LIFNR = V_LIFNR.

            IF NOT V_STCD1 IS INITIAL.
              REFRESH: T_SHOW_PO.
              CLEAR: T_SHOW_PO.
              CALL FUNCTION 'ZHMS_FM_BUSCA_PO_POSSIVEIS_DTE'
                EXPORTING
                  STCD1     = V_STCD1
*                 EBELN     = ZHMS_TB_DTENT_CB-EBELN
                TABLES
                  T_SHOW_PO = T_SHOW_PO.

              IF NOT V_EBELN IS INITIAL.
                DELETE T_SHOW_PO WHERE EBELN <> V_EBELN.
              ENDIF.
            ENDIF.
          ENDIF.
        ELSE.
          CALL FUNCTION 'ZHMS_FM_BUSCA_PO_POSSIVEIS_DTE'
            EXPORTING
              STCD1     = V_STCD1
*             EBELN     = ZHMS_TB_DTENT_CB-EBELN
            TABLES
              T_SHOW_PO = T_SHOW_PO.

        ENDIF.
      ENDIF.
      IF T_SHOW_PO[] IS INITIAL.
        MESSAGE I000 WITH TEXT-017.
      ENDIF.
    ENDFORM.                    " F_SEL_PEDIDO
