*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_DATAENTRYO01 .
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*   Module  M_LOAD_HTML_DATAENTRY  OUTPUT
*----------------------------------------------------------------------*
*   Carregando Objeto HTML dos Documentos
*----------------------------------------------------------------------*
    MODULE M_LOAD_HTML_DATAENTRY OUTPUT.

      IF OB_CC_HTML_DATAENTRY IS INITIAL.
***     Criando objeto de container
        CREATE OBJECT OB_CC_HTML_DATAENTRY
          EXPORTING
            CONTAINER_NAME = 'CC_HTML_DATAENTRY'
          EXCEPTIONS
            OTHERS         = 1.

        IF SY-SUBRC NE 0.
***       Erro Interno. Contatar Suporte.
          MESSAGE E000 WITH TEXT-000.
          STOP.
        ENDIF.
      ENDIF.

      IF OB_HTML_DATAENTRY IS INITIAL.
        DATA: TL_DATASRC_DATAENTRY  TYPE TABLE OF ZHMS_ST_HTML_SRSCD,
              WAL_DATASRC_DATAENTRY TYPE ZHMS_ST_HTML_SRSCD.

***     Criando Objeto HTML - Índice com JavaScript
        CREATE OBJECT OB_HTML_DATAENTRY
          EXPORTING
            PARENT = OB_CC_HTML_DATAENTRY.

        IF SY-SUBRC NE 0.
***       Erro Interno. Contatar Suporte
          MESSAGE E000 WITH TEXT-000.
          STOP.
        ELSE.
***       Registrando Eventos do HTML Documentos
          PERFORM F_REG_EVENTS_DATAENTRY.

***       Carregando Bibliotecas JavaScript
          REFRESH T_WWWDATA.
          CLEAR WA_WWWDATA.

          SELECT * INTO TABLE T_WWWDATA
                   FROM WWWDATA
                   WHERE OBJID LIKE 'ZHMS%'
                     AND SRTF2 EQ 0.

          LOOP AT T_WWWDATA INTO WA_WWWDATA.
            PERFORM F_LOAD_IMAGES_DATAENTRY USING WA_WWWDATA-OBJID
                                            WA_WWWDATA-TEXT.
          ENDLOOP.

          REFRESH: T_SRSCD, T_SRSCD_EV.
          CLEAR:   WA_SRSCD.

***       Código para primeira execução
          LOOP AT T_DATASRC INTO WA_DATASRC.
            CLEAR WAL_DATASRC_DATAENTRY.
            WAL_DATASRC_DATAENTRY-LINSC = WA_DATASRC.
            APPEND WAL_DATASRC_DATAENTRY TO TL_DATASRC_DATAENTRY.
          ENDLOOP.

***       Obtendo Fonte HTML
          CALL FUNCTION 'ZHMS_FM_GET_HTML_DATAENTRY'
            TABLES
              SRSCD   = T_SRSCD
              DATASRC = TL_DATASRC_DATAENTRY
            EXCEPTIONS
              ERROR   = 1
              OTHERS  = 2.

          IF SY-SUBRC EQ 0  AND NOT T_SRSCD[] IS INITIAL.
            LOOP AT T_SRSCD INTO WA_SRSCD.
              APPEND WA_SRSCD TO T_SRSCD_EV.
            ENDLOOP.

            IF NOT T_SRSCD_EV IS INITIAL.
***           Preparando dados para Exibição do Índice
              CLEAR VG_URL.
              OB_HTML_DATAENTRY->LOAD_DATA( IMPORTING ASSIGNED_URL = VG_URL
                                       CHANGING  DATA_TABLE   = T_SRSCD_EV ).

***           Exibindo Índice
              OB_HTML_DATAENTRY->SHOW_URL( URL = VG_URL ).

            ELSE.
***           Erro Interno. Contatar Suporte.
              MESSAGE E000 WITH TEXT-000.
              STOP.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      CALL METHOD CL_GUI_CUSTOM_CONTAINER=>SET_FOCUS
        EXPORTING
          CONTROL           = OB_CC_HTML_DATAENTRY
        EXCEPTIONS
          CNTL_ERROR        = 1
          CNTL_SYSTEM_ERROR = 2
          OTHERS            = 3.
      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                   WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      IF SY-SUBRC <> 0.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                   WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

    ENDMODULE.                 " M_LOAD_HTML_DATAENTRY  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  M_STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       Definições para tela
*----------------------------------------------------------------------*
    MODULE M_STATUS_0100 OUTPUT.

*      SET PF-STATUS '0100' .
*
*      SELECT SINGLE * FROM zhms_tb_show_lay INTO wa_show_lay WHERE ativo EQ 'X'.
*
*      IF wa_show_lay-tipo EQ 'NDD'.
*        SET TITLEBAR  '0101'.
*      ELSE.
*        SET TITLEBAR  '0100'.
*      ENDIF.

*      IF NOT wa_ekko-ebeln IS INITIAL.
*
*        SELECT SINGLE * FROM ekko INTO wa_ekko
*        WHERE ebeln EQ wa_ekko-ebeln.
*        IF sy-subrc EQ 0.
*
*
*          SELECT ebeln
*                 ebelp
*                 matnr
*                 txz01
**                 ktmng
*                 menge
*                 meins
*                 netwr
*                 netpr
*                 peinh
*                 bukrs
*                 werks
*                 lgort
*                 matkl
*            INTO TABLE t_item
*            FROM ekpo
*            WHERE ebeln EQ wa_ekko-ebeln.
*          IF sy-subrc EQ 0.
*            SORT t_item BY ebeln ebelp.
*          ENDIF.
*
*          CLEAR wa_lfa1.
*          SELECT SINGLE * FROM lfa1
*          INTO wa_lfa1
*          WHERE lifnr EQ wa_ekko-lifnr.
*
*        ENDIF.
*
*      ENDIF.
*

    ENDMODULE.                 " M_STATUS_0100  OUTPUT

*{   INSERT         DEVK900252                                        1
*&---------------------------------------------------------------------*
*&      Module  STATUS_0120  OUTPUT
*&---------------------------------------------------------------------*

    MODULE STATUS_0120 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.

      CHECK ITAB[] IS NOT INITIAL.

      IF OB_CC_PDF_DOCS IS INITIAL.
        CREATE OBJECT OB_CC_PDF_DOCS
          EXPORTING
            CONTAINER_NAME = 'CC_PDFDOC'
          EXCEPTIONS
            CNTL_ERROR     = 1
            OTHERS         = 2.

        IF SY-SUBRC NE 0.
***       Erro Interno. Contatar Suporte.
          MESSAGE E000 WITH TEXT-000.
          STOP.
        ENDIF.
      ENDIF.

      IF OB_PDF_DOCS IS INITIAL.
***     Criando Objeto de HTML para PDF
        CREATE OBJECT OB_PDF_DOCS
          EXPORTING
            PARENT             = OB_CC_PDF_DOCS
          EXCEPTIONS
            CNTL_ERROR         = 1
            CNTL_INSTALL_ERROR = 2
            OTHERS             = 3.

        IF SY-SUBRC NE 0.
***       Erro Interno. Contatar Suporte.
          MESSAGE E000 WITH TEXT-000.
          STOP.
        ENDIF.
      ELSE.
        CALL METHOD OB_PDF_DOCS->FREE.
        CLEAR OB_PDF_DOCS.

***     Criando Objeto de HTML para PDF
        CREATE OBJECT OB_PDF_DOCS
          EXPORTING
            PARENT             = OB_CC_PDF_DOCS
          EXCEPTIONS
            CNTL_ERROR         = 1
            CNTL_INSTALL_ERROR = 2
            OTHERS             = 3.

        IF SY-SUBRC NE 0.
***       Erro Interno. Contatar Suporte.
          MESSAGE E000 WITH TEXT-000.
          STOP.
        ENDIF.
      ENDIF.

*      clear vg_edurl.
*      vg_edurl = wa_cabdoc-EDURL.

      VG_EDURL = P_ENTR.
      IF NOT VG_EDURL IS INITIAL.
***     Exibindo documento de PDF
        CALL METHOD OB_PDF_DOCS->SHOW_URL
          EXPORTING
            URL                  = VG_EDURL
          EXCEPTIONS
            CNHT_ERROR_PARAMETER = 1
            OTHERS               = 2.

        IF SY-SUBRC NE 0.
***       Erro Interno. Contatar Suporte.
          MESSAGE E000 WITH TEXT-000.
          STOP.
        ENDIF.
      ENDIF.

*      CALL FUNCTION 'CC_CALL_TRANSACTION_NEW_TASK'
*        STARTING NEW TASK 'J1B1N'
*        DESTINATION 'NONE'
*        EXPORTING
*          transaction       = 'J1B1N'
*          skip_first_screen = 'X'.


    ENDMODULE.                 " STATUS_0120  OUTPUT

*}   INSERT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0130  OUTPUT
*&---------------------------------------------------------------------*

    MODULE STATUS_0130 OUTPUT.

      CALL TRANSACTION 'J1B1N'.

    ENDMODULE.                 " STATUS_0130  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TC_ITEM_GET_LINES  OUTPUT
*&---------------------------------------------------------------------*

    MODULE TC_ITEM_GET_LINES OUTPUT.



    ENDMODULE.                 " TC_ITEM_GET_LINES  OUTPUT

    MODULE TC_ITEM_CHANGE_TC_ATTR OUTPUT.
      DESCRIBE TABLE T_ITEM LINES TC_ITEM-LINES.
    ENDMODULE.                    "TC_ITEM_CHANGE_TC_ATTR OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0101  OUTPUT
*&---------------------------------------------------------------------*

    MODULE STATUS_0101 OUTPUT.
      LOOP AT SCREEN.
        IF SCREEN-NAME = 'T_DOC'.
          IF NOT ZHMS_TB_DTENT_CB-DOC_MIGO IS INITIAL OR
             NOT ZHMS_TB_DTENT_CB-DOC_MIRO IS INITIAL OR
             NOT ZHMS_TB_DTENT_CB-DOC_MIGO_EST IS INITIAL OR
             NOT ZHMS_TB_DTENT_CB-DOC_MIRO_EST IS INITIAL.
            SCREEN-INVISIBLE = 0.
            MODIFY SCREEN.
          ELSE.
            SCREEN-INVISIBLE = 1.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
        IF  SCREEN-NAME = 'ZHMS_TB_DTENT_CB-DOC_MIGO'.
          IF NOT ZHMS_TB_DTENT_CB-DOC_MIGO IS INITIAL.
            SCREEN-INVISIBLE = 0.
            MODIFY SCREEN.
          ELSE.
            SCREEN-INVISIBLE = 1.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
        IF  SCREEN-NAME = 'ZHMS_TB_DTENT_CB-DOC_MIGO_EST'.
          IF NOT ZHMS_TB_DTENT_CB-DOC_MIGO_EST IS INITIAL.
            SCREEN-INVISIBLE = 0.
            MODIFY SCREEN.
          ELSE.
            SCREEN-INVISIBLE = 1.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
        IF SCREEN-NAME = 'ZHMS_TB_DTENT_CB-DOC_MIRO'.
          IF NOT ZHMS_TB_DTENT_CB-DOC_MIRO IS INITIAL.
            SCREEN-INVISIBLE = 0.
            MODIFY SCREEN.
          ELSE.
            SCREEN-INVISIBLE = 1.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
        IF SCREEN-NAME = 'ZHMS_TB_DTENT_CB-DOC_MIRO_EST'.
          IF NOT ZHMS_TB_DTENT_CB-DOC_MIRO_EST IS INITIAL.
            SCREEN-INVISIBLE = 0.
            MODIFY SCREEN.
          ELSE.
            SCREEN-INVISIBLE = 1.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
        IF SCREEN-NAME = 'EST_MIGO'.
          IF NOT ZHMS_TB_DTENT_CB-DOC_MIGO IS INITIAL.
            SCREEN-INVISIBLE = 0.
            MODIFY SCREEN.
          ELSE.
            SCREEN-INVISIBLE = 1.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
        IF SCREEN-NAME = 'EST_MIRO'.
          IF NOT ZHMS_TB_DTENT_CB-DOC_MIRO IS INITIAL.
            SCREEN-INVISIBLE = 0.
            MODIFY SCREEN.
          ELSE.
            SCREEN-INVISIBLE = 1.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.

        IF VL_TYPED = '3TCON' AND ( NOT ZHMS_TB_DTENT_CB-DOC_MIGO IS INITIAL
                      AND   NOT ZHMS_TB_DTENT_CB-DOC_MIRO IS INITIAL ).
          CHECK SCREEN-GROUP1 = 'VIS'.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.
        IF NOT ZHMS_TB_DTENT_CB-DOC_MIGO IS INITIAL AND
           NOT ZHMS_TB_DTENT_CB-DOC_MIRO IS INITIAL.
          CHECK SCREEN-GROUP1 = 'VIS'.
          SCREEN-INPUT = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    ENDMODULE.                 " STATUS_0101  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  CREATE_AND_INIT_ALV
*&---------------------------------------------------------------------*

    FORM CREATE_AND_INIT_ALV .

      DATA: T_EXCLUDE TYPE UI_FUNCTIONS.

      CREATE OBJECT C_CUSTOM_CONTAINER
        EXPORTING
          CONTAINER_NAME = C_CONTAINER.

      CREATE OBJECT C_GRID
        EXPORTING
          I_PARENT = C_CUSTOM_CONTAINER.

      PERFORM Z_BUILD_FIELDCAT CHANGING T_FIELDCAT.

      PERFORM Z_EXCLUDE_TB_FUNCTIONS CHANGING T_EXCLUDE.

      CALL METHOD C_GRID->SET_TABLE_FOR_FIRST_DISPLAY
        EXPORTING
          IS_LAYOUT            = WA_LAYOUT
          IT_TOOLBAR_EXCLUDING = T_EXCLUDE
        CHANGING
          IT_FIELDCATALOG      = T_FIELDCAT
          IT_OUTTAB            = T_LOG[].


      CREATE OBJECT EVENT_RECEIVER.

      SET HANDLER EVENT_RECEIVER->HANDLE_HOTSPOT_CLICK FOR C_GRID.
      SET HANDLER EVENT_RECEIVER->HANDLE_DOUBLE_CLICK FOR C_GRID.

    ENDFORM.                    " CREATE_AND_INIT_ALV
*&---------------------------------------------------------------------*
*&      Form  Z_BUILD_FIELDCAT
*&---------------------------------------------------------------------*

    FORM Z_BUILD_FIELDCAT  CHANGING P_T_FIELDCAT.

      DATA LS_FCAT TYPE LVC_S_FCAT.

      CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
        EXPORTING
          I_STRUCTURE_NAME = 'ZEMM_DADOS_LOG'
        CHANGING
          CT_FIELDCAT      = T_FIELDCAT.

      LOOP AT T_FIELDCAT INTO WA_FIELDCAT.

        CASE WA_FIELDCAT-FIELDNAME.

          WHEN 'DATA_LOG'.

            WA_FIELDCAT-COLTEXT = 'Data Log'.
            WA_FIELDCAT-TOOLTIP = 'Data Log'.
            WA_FIELDCAT-SELTEXT = 'Data Log'.

          WHEN 'HORA_LOG'.

            WA_FIELDCAT-COLTEXT = 'Hora Log'.
            WA_FIELDCAT-TOOLTIP = 'Hora Log'.
            WA_FIELDCAT-SELTEXT = 'Hora Log'.
          WHEN 'USUARIO'.

            WA_FIELDCAT-COLTEXT = 'Usuário'.
            WA_FIELDCAT-TOOLTIP = 'Usuário'.
            WA_FIELDCAT-SELTEXT = 'Usuário'.
          WHEN 'MSG'.

            WA_FIELDCAT-COLTEXT = 'Mensagem'.
            WA_FIELDCAT-TOOLTIP = 'Mensagem'.
            WA_FIELDCAT-SELTEXT = 'Mensagem'.

          WHEN 'DOC_MIGO'.
            WA_FIELDCAT-COLTEXT = 'Doc MIGO'.
            WA_FIELDCAT-TOOLTIP = 'Doc MIGO'.
            WA_FIELDCAT-SELTEXT = 'Doc MIGO'.

          WHEN 'DOC_MIRO'.

            WA_FIELDCAT-COLTEXT = 'Doc MIRO'.
            WA_FIELDCAT-TOOLTIP = 'Doc MIRO'.
            WA_FIELDCAT-SELTEXT = 'Doc MIRO'.
          WHEN 'EST_MIGO'.

            WA_FIELDCAT-COLTEXT = 'Est MIGO'.
            WA_FIELDCAT-TOOLTIP = 'Est MIGO'.
            WA_FIELDCAT-SELTEXT = 'Est MIGO'.
          WHEN 'EST_MIRO'.
            WA_FIELDCAT-COLTEXT = 'Est MIRO'.
            WA_FIELDCAT-TOOLTIP = 'Est MIRO'.
            WA_FIELDCAT-SELTEXT = 'Est MIRO'.

        ENDCASE.

        MODIFY T_FIELDCAT FROM WA_FIELDCAT INDEX SY-TABIX.

        CLEAR WA_FIELDCAT.
      ENDLOOP.


    ENDFORM.                 "z_build_fieldcat

*&---------------------------------------------------------------------*
*&      Form  Z_EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
    FORM Z_EXCLUDE_TB_FUNCTIONS CHANGING PT_EXCLUDE TYPE UI_FUNCTIONS.

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


    ENDFORM.                    " Z_EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
*&      Module  STATUS_0103  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    MODULE STATUS_0103 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.



    ENDMODULE.                 " STATUS_0103  OUTPUT


    MODULE TC_ATR_PED_CHANGE_TC_ATTR OUTPUT.
      DESCRIBE TABLE T_SHOW_PO LINES TC_ATR_PED-LINES.
    ENDMODULE.

    MODULE TC_ATR_ITEM_CHANGE_TC_ATTR OUTPUT.

      DESCRIBE TABLE T_ITEM LINES TC_ATR_ITEM-LINES.
    ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0111  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    MODULE STATUS_0111 OUTPUT.
*  SET TITLEBAR 'xxx'.
      SET PF-STATUS '0111' .

    ENDMODULE.                 " STATUS_0111  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0140  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    MODULE STATUS_0140 OUTPUT.
      SET PF-STATUS '0140'.
*  SET TITLEBAR 'xxx'.


    ENDMODULE.                 " STATUS_0140  OUTPUT

    MODULE TC_SELECT_CHANGE_TC_ATTR OUTPUT.

      REFRESH: T_SELEC.
      PERFORM F_SELECIONA_DADOS.

      DESCRIBE TABLE T_SELEC LINES TC_SELECT-LINES.
    ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    MODULE STATUS_0100 OUTPUT.
      SET PF-STATUS '1100'.

    ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  M_STATUS_0500  OUTPUT
*&---------------------------------------------------------------------*

    MODULE M_STATUS_0500 OUTPUT.
      REFRESH: T_LOGDOC, T_CODES.
      SELECT *
          INTO TABLE T_LOGDOC
          FROM ZHMS_TB_LOGDOC
         WHERE NATDC EQ '02'
           AND TYPED EQ 'NFET'
*                 AND loctp EQ wa_type-loctp
           AND CHAVE EQ ZHMS_TB_DTENT_CB-CHAVE.
      IF SY-SUBRC <> 0.
        APPEND: 'LOGS' TO T_CODES.
      ENDIF.
      IF VG_0150 = '0101'.

        IF VL_TYPED EQ '3TCON' AND ( NOT ZHMS_TB_DTENT_CB-DOC_MIGO IS INITIAL
                               AND   NOT ZHMS_TB_DTENT_CB-DOC_MIRO IS INITIAL ) .
          APPEND: 'ANALISE_PO' TO T_CODES,
                  'EXEC_FLUXO' TO T_CODES,
                  'GERAR_XML'  TO T_CODES,
                  'SCANNER'    TO T_CODES,
                  'SAVE'       TO T_CODES.
        ELSE.
          APPEND: 'ANALISE_PO' TO T_CODES,
                  'GERAR_XML'  TO T_CODES,
                  'SAVE'       TO T_CODES.
        ENDIF.
        IF NOT ZHMS_TB_DTENT_CB-DOC_MIGO IS INITIAL AND
           NOT ZHMS_TB_DTENT_CB-DOC_MIRO IS INITIAL.
          APPEND: 'ANALISE_PO' TO T_CODES,
                  'EXEC_FLUXO' TO T_CODES,
                  'GERAR_XML'  TO T_CODES,
                  'SCANNER'    TO T_CODES,
                  'SAVE'       TO T_CODES.
        ENDIF.

        SET PF-STATUS '0100' EXCLUDING T_CODES.

        SET TITLEBAR  '0100'.
        ZHMS_TB_DTENT_CB-DTLANC = SY-DATUM.

        IF C_CUSTOM_CONTAINER IS INITIAL.
          PERFORM CREATE_AND_INIT_ALV.
        ELSE.
          CALL METHOD C_GRID->REFRESH_TABLE_DISPLAY.
        ENDIF.
      ELSE.
        SET PF-STATUS '0150'.
      ENDIF.

    ENDMODULE.                 " M_STATUS_0500  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  M_LOAD_HTML_INDEX  OUTPUT
*&---------------------------------------------------------------------*
    MODULE M_LOAD_HTML_INDEX OUTPUT.
      IF OB_CC_HTML_INDEX IS INITIAL.
***     Criando objeto de container
        CREATE OBJECT OB_CC_HTML_INDEX
          EXPORTING
            CONTAINER_NAME = 'CC_HTML_INDEX'
          EXCEPTIONS
            OTHERS         = 1.

        IF SY-SUBRC NE 0.
***       Erro Interno. Contatar Suporte.
          MESSAGE E000 WITH TEXT-000.
          STOP.
        ENDIF.
      ENDIF.

      IF OB_HTML_INDEX IS INITIAL.
***     Criando Objeto HTML - Índice
        CREATE OBJECT OB_HTML_INDEX
          EXPORTING
            PARENT             = OB_CC_HTML_INDEX
          EXCEPTIONS
            CNTL_ERROR         = 1
            CNTL_INSTALL_ERROR = 2
            DP_INSTALL_ERROR   = 3
            DP_ERROR           = 4
            OTHERS             = 5.

        IF SY-SUBRC NE 0.
***       Erro Interno. Contatar Suporte
          MESSAGE E000 WITH TEXT-000.
          STOP.
        ELSE.
***       Selecionando dados do Índice
          PERFORM F_SEL_INDEX_NFS.
***       Registrando Eventos do HTML Index
          PERFORM F_REG_EVENTS_INDEX.
***       Carregando Ícone Padrão
          PERFORM F_LOAD_IMAGES USING 'S_RANEUT' 'S_RANEUT.GIF'.
***       Carregando Bibliotecas JavaScript
          PERFORM F_LOAD_IMAGES USING 'ZHMS_JQUERY_MIN'     'JQUERY_MIN.JS'.
          PERFORM F_LOAD_IMAGES USING 'ZHMS_JSCROLLPANE'    'JSCROLLPANE.JS'.
          PERFORM F_LOAD_IMAGES USING 'ZHMS_MOUSEWHEEL'     'MOUSEWHEEL.JS'.
          PERFORM F_LOAD_IMAGES USING 'ZHMS_JSCROLLPANECSS' 'JSCROLLPANECSS.CSS'.

          REFRESH T_SRSCD.
          CLEAR   WA_SRSCD.

***       Obtendo Fonte HTML
          CALL FUNCTION 'ZHMS_FM_GET_HTML_INDEX'
            TABLES
              INDEX  = T_INDEX
              SRSCD  = T_SRSCD
            EXCEPTIONS
              ERROR  = 1
              OTHERS = 2.

          IF SY-SUBRC EQ 0  AND NOT T_SRSCD[] IS INITIAL.
            LOOP AT T_SRSCD INTO WA_SRSCD.
              APPEND WA_SRSCD TO T_SRSCD_EV.
            ENDLOOP.

            IF NOT T_SRSCD_EV IS INITIAL.
***           Preparando dados para Exibição do Índice
              CLEAR VG_URL.
              OB_HTML_INDEX->LOAD_DATA( IMPORTING ASSIGNED_URL = VG_URL
                                        CHANGING  DATA_TABLE   = T_SRSCD_EV ).

***           Exibindo Índice
              OB_HTML_INDEX->SHOW_URL( URL = VG_URL ).
            ELSE.
***           Erro Interno. Contatar Suporte.
              MESSAGE E000 WITH TEXT-000.
              STOP.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDMODULE.                 " M_LOAD_HTML_INDEX  OUTPUT
*----------------------------------------------------------------------*
*   Module  M_LOAD_LOGO_HOMSOFT  OUTPUT
*----------------------------------------------------------------------*
*   Carregando Logotipo HomSoft
*----------------------------------------------------------------------*
    MODULE M_LOAD_LOGO_HOMSOFT OUTPUT.
      IF OB_CC_LOGOTIPO IS INITIAL.

***     Criando Objeto de Container para Logo
        CREATE OBJECT OB_CC_LOGOTIPO
          EXPORTING
            CONTAINER_NAME              = 'CC_LOGOTIPO'
          EXCEPTIONS
            CNTL_ERROR                  = 1
            CNTL_SYSTEM_ERROR           = 2
            CREATE_ERROR                = 3
            LIFETIME_ERROR              = 4
            LIFETIME_DYNPRO_DYNPRO_LINK = 5
            OTHERS                      = 6.

        IF SY-SUBRC NE 0.
***       Erro Interno. Contatar Suporte.
          MESSAGE E000 WITH TEXT-000.
          STOP.
        ENDIF.
      ENDIF.

      IF OB_LOGOTIPO IS INITIAL.
***     Criando Objeto de Picture Control
        CREATE OBJECT OB_LOGOTIPO
          EXPORTING
            PARENT = OB_CC_LOGOTIPO
          EXCEPTIONS
            ERROR  = 1
            OTHERS = 2.

        IF SY-SUBRC NE 0.
***       Erro Interno. Contatar Suporte.
          MESSAGE E000 WITH TEXT-000.
          STOP.
        ELSE.
***       Setando Método de Exibição
          CALL METHOD OB_LOGOTIPO->SET_DISPLAY_MODE
            EXPORTING
              DISPLAY_MODE = CL_GUI_PICTURE=>DISPLAY_MODE_NORMAL_CENTER
            EXCEPTIONS
              ERROR        = 1
              OTHERS       = 2.

          IF SY-SUBRC NE 0.
***         Erro Interno. Contatar Suporte.
            MESSAGE E000 WITH TEXT-000.
            STOP.
          ENDIF.

          SELECT SINGLE * FROM ZHMS_TB_SHOW_LAY INTO LS_SHOW_LAY WHERE ATIVO EQ 'X'.

          IF LS_SHOW_LAY-TIPO EQ 'NDD'.
***       Carregando URL
            CLEAR VG_URL.
            CALL FUNCTION 'DP_PUBLISH_WWW_URL'
              EXPORTING
                OBJID    = 'ZHMS_NDD_LOGO2'
                LIFETIME = CNDP_LIFETIME_TRANSACTION
              IMPORTING
                URL      = VG_URL
              EXCEPTIONS
                OTHERS   = 1.
          ELSE.
***       Carregando URL
            CLEAR VG_URL.
            CALL FUNCTION 'DP_PUBLISH_WWW_URL'
              EXPORTING
                OBJID    = 'ZHMS_LOGO'
                LIFETIME = CNDP_LIFETIME_TRANSACTION
              IMPORTING
                URL      = VG_URL
              EXCEPTIONS
                OTHERS   = 1.
          ENDIF.

          IF SY-SUBRC NE 0.
***         Erro Interno. Contatar Suporte.
            MESSAGE E000 WITH TEXT-000.
            STOP.
          ELSE.
***         Carregando Imagem na Tela
            CALL METHOD OB_LOGOTIPO->LOAD_PICTURE_FROM_URL_ASYNC
              EXPORTING
                URL    = VG_URL
              EXCEPTIONS
                ERROR  = 1
                OTHERS = 2.

            IF SY-SUBRC NE 0.
***           Erro Interno. Contatar Suporte.
              MESSAGE E000 WITH TEXT-000.
              STOP.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDMODULE.                 " M_LOAD_LOGO_HOMSOFT  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       Logs para documentos
*----------------------------------------------------------------------*
    MODULE M_STATUS_0300 OUTPUT.
      SET PF-STATUS '0300'.
      SET TITLEBAR  '0300'.
    ENDMODULE.
*----------------------------------------------------------------------*
*  MODULE m_get_logs_doc OUTPUT
*----------------------------------------------------------------------*
*  Carregar dados de log para documento
*----------------------------------------------------------------------*
    MODULE M_GET_LOGS_DOC OUTPUT.
*     Limpar tabelas de logs
      REFRESH: T_LOGDOC, T_LOGDOC_AUX.

*     Seleciona logs para documento
      IF VG_FLOWD IS INITIAL.
        SELECT *
                INTO TABLE T_LOGDOC
                FROM ZHMS_TB_LOGDOC
               WHERE NATDC EQ '02'
                 AND TYPED EQ 'NFET'
*                 AND loctp EQ wa_type-loctp
                 AND CHAVE EQ ZHMS_TB_DTENT_CB-CHAVE.
      ELSE.
        SELECT *
              INTO TABLE T_LOGDOC
              FROM ZHMS_TB_LOGDOC
             WHERE NATDC EQ '02'
               AND TYPED EQ 'NFET'
*               AND loctp EQ wa_type-loctp
               AND CHAVE EQ ZHMS_TB_DTENT_CB-CHAVE
               AND FLOWD EQ VG_FLOWD.
      ENDIF.

*     Seleção por Data / Hora / Sequencia
      SORT T_LOGDOC BY DTREG DESCENDING
                       HRREG DESCENDING
                       SEQNR DESCENDING.

*     Percorrer tabela de logs para tratamento
      LOOP AT T_LOGDOC INTO WA_LOGDOC.
*       Mover dados para tabela de exibição
        MOVE-CORRESPONDING WA_LOGDOC TO WA_LOGDOC_AUX.

*       Tratamento de Icones
        CASE WA_LOGDOC-LOGTY.
          WHEN 'E'.
            WA_LOGDOC_AUX-ICON = '@0A@'.
          WHEN 'W'.
            WA_LOGDOC_AUX-ICON = '@09@'.
          WHEN 'I'.
            WA_LOGDOC_AUX-ICON = '@08@'.
          WHEN 'S'.
            WA_LOGDOC_AUX-ICON = '@01@'.
        ENDCASE.
*       Seleciona o ID da mensagem
        IF WA_LOGDOC-LOGID IS INITIAL.
          WA_LOGDOC-LOGID = 'ZHMS_MC_LOGDOC'.
        ENDIF.
*       Busca log na classe de mensagem
        MESSAGE ID WA_LOGDOC-LOGID TYPE WA_LOGDOC-LOGTY NUMBER WA_LOGDOC-LOGNO
                INTO WA_LOGDOC_AUX-LTEXT
                WITH WA_LOGDOC-LOGV1 WA_LOGDOC-LOGV2 WA_LOGDOC-LOGV3 WA_LOGDOC-LOGV4.

*       Adiciona dados a tabela de exibição
        APPEND WA_LOGDOC_AUX TO T_LOGDOC_AUX.
      ENDLOOP.
    ENDMODULE.                    "m_get_logs_doc OUTPUT
*----------------------------------------------------------------------*
*   MODULE tc_logdoc_change_tc_attr OUTPUT
*----------------------------------------------------------------------*
*   Controlador de Índices TABLECONTROL
*----------------------------------------------------------------------*
    MODULE TC_LOGDOC_CHANGE_TC_ATTR OUTPUT.
      DESCRIBE TABLE T_LOGDOC_AUX LINES TC_LOGDOC-LINES.
    ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  TC_ATR_PED_GET_LINES  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TC_ATR_PED_GET_LINES OUTPUT.
g_tc_ATR_PED_lines = sy-loopc.
ENDMODULE.                 " TC_ATR_PED_GET_LINES  OUTPUT
