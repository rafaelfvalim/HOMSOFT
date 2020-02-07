*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_DATAENTRYI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  M_USER_COMMAND_EXIT  INPUT
*&---------------------------------------------------------------------*
*       Eventos de Saída da Tela
*----------------------------------------------------------------------*
    MODULE M_USER_COMMAND_EXIT INPUT.

***   Gravando OKCODE
      MOVE SY-UCOMM TO OK_CODE.

      CASE OK_CODE.
        WHEN 'BACK' OR 'CANC' OR 'EXIT'.
**       Destruir Arvore de fluxo
          IF NOT OB_CC_DET_FLOW IS INITIAL.
            " destroy tree container (detroys contained tree control, too)
            CALL METHOD OB_CC_DET_FLOW->FREE
              EXCEPTIONS
                CNTL_SYSTEM_ERROR = 1
                CNTL_ERROR        = 2.
            IF SY-SUBRC <> 0.
              MESSAGE A000.
            ENDIF.
            CLEAR OB_CC_DET_FLOW.
            CLEAR OB_FLOW.
          ENDIF.
          LEAVE TO SCREEN 0.


        WHEN OTHERS.
      ENDCASE.

**    Limpando SY-UCOMM
      CLEAR SY-UCOMM.


    ENDMODULE.                 " M_USER_COMMAND_EXIT  INPUT

*{   INSERT         DEVK900252                                        1
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0120  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    MODULE USER_COMMAND_0120 INPUT.

    ENDMODULE.                 " USER_COMMAND_0120  INPUT

*}   INSERT

*{   INSERT         DEVK900252                                        2
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    MODULE USER_COMMAND_0100 INPUT.
*
*      CALL FUNCTION 'WS_FILENAME_GET'
*        EXPORTING
*          def_filename     = p_entr
*          def_path         = 'C:_line'
*          mask             = '*.*,*.*.'
*          title            = 'Pesquisar Arquivo'
*        IMPORTING
*          filename         = p_entr
*        EXCEPTIONS
*          inv_winsys                    = 1
*          no_batch         = 2
*          selection_cancel = 3
*          selection_error  = 4
*          OTHERS           = 5.
*
*      REFRESH itab[].
*      IF p_entr IS NOT INITIAL.
*
*        MOVE p_entr TO filename.
*        CALL FUNCTION 'GUI_UPLOAD'
*          EXPORTING
*            filename   = filename
*            filetype   = 'BIN'
*          IMPORTING
*            filelength = length
*          TABLES
*            data_tab   = itab.
*
*      ENDIF.

    ENDMODULE.                 " USER_COMMAND_0100  INPUT

*}   INSERT
*&---------------------------------------------------------------------*
*&      Module  Z_PROCESS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    MODULE Z_PROCESS INPUT.

      WA_ITEM-NETWR = WA_ITEM-MENGE * WA_ITEM-NETPR.

      MODIFY T_ITEM FROM WA_ITEM INDEX TC_ITEM-CURRENT_LINE.

    ENDMODULE.                 " Z_PROCESS  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    MODULE USER_COMMAND_0101 INPUT.

*      DATA: WL_AUX  TYPE EKKO,
*            TL_ITEM TYPE TABLE OF TY_ITEM,
*            VL_TBX1 TYPE SY-TABIX,
*            VL_TBX2 TYPE SY-TABIX.
*
*      DESCRIBE TABLE T_ITEM[] LINES VL_TBX1.
*
*      TL_ITEM[] = T_ITEM[].
*      SORT TL_ITEM BY SEL.
*      DELETE TL_ITEM[] WHERE SEL EQ SPACE.
*
*      DESCRIBE TABLE TL_ITEM[] LINES VL_TBX2.
*
*      REFRESH: T_LOG, T_ACC, T_TAXDATA.
*
*      CASE SY-UCOMM.
*
*        WHEN 'EXEC_FLUXO'.
*          PERFORM F_EXECUTA_FLUXO.
*
*        WHEN 'SCANNER'.
*          PERFORM F_SCANNER.
*
*        WHEN 'GERAR_XML'.
*          CALL SCREEN 0102 STARTING AT 30 1.
*
*        WHEN 'ANALISE_PO'.
*          CALL SCREEN 0103.
*
*        WHEN 'SAVE'.
*          PERFORM F_SAVE.
*
*        WHEN 'SEL_PED'.
*          CLEAR SY-UCOMM.
*          PERFORM F_SELECIONA_ITEM.
*
*        WHEN 'ELIM_ITEM'.
*          PERFORM F_ELIMINA_ITEM.
*
*        WHEN 'SEL_ALL'.
*          PERFORM F_SELECIONA_TODOS.
*
*        WHEN 'SEL_DALL'.
*          PERFORM F_TIRA_SELECAO.
*
*        WHEN 'EST_MIGO'.
*          PERFORM F_EST_MIGO.
*
*        WHEN 'EST_MIRO'.
*          PERFORM F_EST_MIRO.
*
*        WHEN 'DRILL'.
*          break-point.
*          GET CURSOR FIELD fld. "OFFSET off VALUE val LENGTH len.
*
*      ENDCASE.


    ENDMODULE.                 " USER_COMMAND_0101  INPUT


*&SPWIZARD: INPUT MODUL FOR TC 'TC_ATR_PED'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
    MODULE TC_ATR_PED_MARK INPUT.
      DATA: G_TC_ATR_PED_WA2 LIKE LINE OF T_SHOW_PO.
      IF TC_ATR_PED-LINE_SEL_MODE = 1
      AND WA_SHOW_PO-MARK = 'X'.
        LOOP AT T_SHOW_PO INTO G_TC_ATR_PED_WA2
          WHERE MARK = 'X'.
          G_TC_ATR_PED_WA2-MARK = ''.
          MODIFY T_SHOW_PO
            FROM G_TC_ATR_PED_WA2
            TRANSPORTING MARK.
        ENDLOOP.
      ENDIF.
      MODIFY T_SHOW_PO
        FROM WA_SHOW_PO
        INDEX TC_ATR_PED-CURRENT_LINE
        TRANSPORTING MARK.
    ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'TC_ATR_PED'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
    MODULE TC_ATR_PED_USER_COMMAND INPUT.
      OK_CODE = SY-UCOMM.
      PERFORM USER_OK_TC USING    'TC_ATR_PED'
                                  'T_SHOW_PO'
                                  'MARK'
                         CHANGING OK_CODE.
      SY-UCOMM = OK_CODE.
    ENDMODULE.

*&SPWIZARD: INPUT MODUL FOR TC 'TC_ATR_ITEM'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
    MODULE TC_ATR_ITEM_MARK INPUT.
      DATA: G_TC_ATR_ITEM_WA2 LIKE LINE OF T_ITEM.
      IF TC_ATR_ITEM-LINE_SEL_MODE = 1
      AND WA_ITEM-SEL = 'X'.
        LOOP AT T_ITEM INTO G_TC_ATR_ITEM_WA2
          WHERE SEL = 'X'.
          G_TC_ATR_ITEM_WA2-SEL = ''.
          MODIFY T_ITEM
            FROM G_TC_ATR_ITEM_WA2
            TRANSPORTING SEL.
        ENDLOOP.
      ENDIF.
      MODIFY T_ITEM
        FROM WA_ITEM
        INDEX TC_ATR_ITEM-CURRENT_LINE
        TRANSPORTING SEL.
    ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'TC_ATR_ITEM'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
    MODULE TC_ATR_ITEM_USER_COMMAND INPUT.
      OK_CODE = SY-UCOMM.
      PERFORM USER_OK_TC USING    'TC_ATR_ITEM'
                                  'T_ITEM'
                                  'SEL'
                         CHANGING OK_CODE.
      SY-UCOMM = OK_CODE.
    ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0111  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    MODULE USER_COMMAND_0111 INPUT.
      CASE OK_CODE.
        WHEN 'CANC'.
          LEAVE TO SCREEN 0 .
        WHEN 'TRANSF'.
          PERFORM F_TRANSFERE_ITEM.
        WHEN 'BT_PESQ'.
          PERFORM F_SEL_PEDIDO.
      ENDCASE.
      CLEAR: OK_CODE, SY-UCOMM.
    ENDMODULE.                 " USER_COMMAND_0111  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0140  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    MODULE USER_COMMAND_0140 INPUT.
      CASE SY-UCOMM.

        WHEN 'CANCEL'.
          MOVE: '0151' TO VG_0150.
          LEAVE TO SCREEN 0.
        WHEN 'SEL_ITEN'.
          PERFORM F_SEL_ITEN.
        WHEN 'SEL_DR'.
          CLEAR: FLD_S, LIN_S.
          GET CURSOR FIELD FLD_S.
          GET CURSOR LINE LIN_S.
          IF FLD_S(8) = 'WA_SELEC' AND NOT LIN_S IS INITIAL.
            PERFORM F_SEL_ITEN_DRILL.
          ENDIF.
      ENDCASE.

    ENDMODULE.                 " USER_COMMAND_0140  INPUT

    MODULE TC_SELECT_MARK INPUT.
      DATA: G_TC_SELECT_WA2 LIKE LINE OF T_SELEC.
      IF TC_SELECT-LINE_SEL_MODE = 1
      AND WA_SELEC-SEL = 'X'.
        LOOP AT T_SELEC INTO G_TC_SELECT_WA2
          WHERE SEL = 'X'.
          G_TC_SELECT_WA2-SEL = ''.
          MODIFY T_SELEC
            FROM G_TC_SELECT_WA2
            TRANSPORTING SEL.
        ENDLOOP.
      ENDIF.
      MODIFY T_SELEC
        FROM WA_SELEC
        INDEX TC_SELECT-CURRENT_LINE
        TRANSPORTING SEL.
    ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  M_USER_COMMAND_0150_EXIT  INPUT
*&---------------------------------------------------------------------*

    MODULE M_USER_COMMAND_0150_EXIT INPUT.
      DATA: L_ANSWER(1) TYPE C.
***   Gravando OKCODE
      MOVE SY-UCOMM TO OK_CODE.

      CASE OK_CODE.
        WHEN 'BACK' OR 'CANC' OR 'EXIT'.
          PERFORM F_SAVE.
          IF VG_ERRO IS INITIAL.
            LEAVE TO SCREEN 0.
          ELSE.
            CLEAR: VG_ERRO.
          ENDIF.
      ENDCASE.
**    Limpando SY-UCOMM
      CLEAR SY-UCOMM.
    ENDMODULE.                 " M_USER_COMMAND_0150_EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Form  F_SELECIONA_DADOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
    FORM F_SELECIONA_DADOS .
      TYPES: BEGIN OF TY_SELECT,
       LINE TYPE CHAR80,
      END OF TY_SELECT.

      DATA: VL_INDEX     TYPE SY-TABIX,
            T_WHERE      TYPE TABLE OF TY_SELECT WITH HEADER LINE,
            LS_WHERE     LIKE LINE OF T_WHERE,
            LS_WHERE_TAB TYPE RSDSWHERE.

      IF VL_RETORNO IS INITIAL.
        LOOP AT T_TWHERE INTO WA_TWHERE.
          LOOP AT WA_TWHERE-WHERE_TAB INTO LS_WHERE_TAB.
            MOVE LS_WHERE_TAB TO LS_WHERE.
            APPEND LS_WHERE TO T_WHERE.
            CLEAR LS_WHERE.
          ENDLOOP.
          IF VL_TYPED = '2TPEN'.
            CONCATENATE 'AND ( ( DOC_MIRO EQ ''' SPACE '''' ')' INTO LS_WHERE.
            APPEND LS_WHERE TO T_WHERE . CLEAR LS_WHERE.
            CONCATENATE 'OR ( DOC_MIGO EQ ''' SPACE '''' ') )' INTO LS_WHERE.
            APPEND LS_WHERE TO T_WHERE . CLEAR LS_WHERE.
          ELSEIF VL_TYPED = '3TCON'.
            CONCATENATE 'AND ( ( DOC_MIRO <> ''' SPACE '''' ')' INTO LS_WHERE.
            APPEND LS_WHERE TO T_WHERE . CLEAR LS_WHERE.
            CONCATENATE 'AND ( DOC_MIGO <> ''' SPACE '''' ') )' INTO LS_WHERE.
            APPEND LS_WHERE TO T_WHERE . CLEAR LS_WHERE.
          ENDIF.
        ENDLOOP.

        IF T_WHERE[] IS INITIAL.
          IF VL_TYPED = '2TPEN'.
            CONCATENATE '( ( DOC_MIRO EQ ''' SPACE '''' ')' INTO LS_WHERE.
            APPEND LS_WHERE TO T_WHERE . CLEAR LS_WHERE.
            CONCATENATE 'OR ( DOC_MIGO EQ ''' SPACE '''' ') )' INTO LS_WHERE.
            APPEND LS_WHERE TO T_WHERE . CLEAR LS_WHERE.
          ELSEIF VL_TYPED = '3TCON'.
            CONCATENATE '( ( DOC_MIRO <> ''' SPACE '''' ')' INTO LS_WHERE.
            APPEND LS_WHERE TO T_WHERE . CLEAR LS_WHERE.
            CONCATENATE 'AND ( DOC_MIGO <> ''' SPACE '''' ') )' INTO LS_WHERE.
            APPEND LS_WHERE TO T_WHERE . CLEAR LS_WHERE.
          ENDIF.


        ENDIF.

        SELECT SEQNR STCD1 DTDOC NFNUM DTCRIACAO
        INTO TABLE T_SELEC
        FROM ZHMS_TB_DTENT_CB
        WHERE (T_WHERE).

        IF T_SELEC[] IS INITIAL.
          MESSAGE I501(ZHOM_MONITOR_NFE).
          LEAVE TO SCREEN 0.
        ENDIF.
      ELSE.
        LEAVE TO SCREEN 0.
      ENDIF.
    ENDFORM.                    " F_SELECIONA_DADOS
*&---------------------------------------------------------------------*
*&      Module  INIT_SCREEN_0999  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    MODULE INIT_SCREEN_0999 OUTPUT.

      SET PF-STATUS 'STATUS_999'.

    ENDMODULE.                 " INIT_SCREEN_0999  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0999  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    MODULE USER_COMMAND_0999 INPUT.
      DATA: WL_AUX  TYPE EKKO,
           TL_ITEM TYPE TABLE OF TY_ITEM,
           VL_TBX1 TYPE SY-TABIX,
           VL_TBX2 TYPE SY-TABIX.

      VG_NOTA = ZHMS_TB_DTENT_CB-NFNUM.
      REPLACE ALL OCCURRENCES OF '-' IN VG_NOTA WITH ''.
      SHIFT VG_NOTA RIGHT DELETING TRAILING SPACE.
      TRANSLATE VG_NOTA USING ' 0'.
      CONCATENATE VG_NOTA
                  ZHMS_TB_DTENT_CB-DTDOC+6(2)
                  ZHMS_TB_DTENT_CB-DTDOC+4(2)
                  ZHMS_TB_DTENT_CB-DTDOC(4)
                  ZHMS_TB_DTENT_CB-STCD1 INTO VG_CHAVE_ANT.

      IF NOT VG_CHAVE IS INITIAL AND VG_CHAVE <> VG_CHAVE_ANT.
        CLEAR: ZHMS_TB_DTENT_CB-SEQNR.
        VL_TYPED = '1TNV'.
        VG_CHAVE = VG_CHAVE_ANT.
        ZHMS_TB_DTENT_CB-CHAVE = VG_CHAVE.
      ENDIF.
      DESCRIBE TABLE T_ITEM[] LINES VL_TBX1.

      TL_ITEM[] = T_ITEM[].
      SORT TL_ITEM BY SEL.
      DELETE TL_ITEM[] WHERE SEL EQ SPACE.

      DESCRIBE TABLE TL_ITEM[] LINES VL_TBX2.

      REFRESH: T_LOG, T_ACC, T_TAXDATA.

      CASE OK_CODE.

        WHEN 'EXEC_FLUXO'.
          PERFORM F_EXECUTA_FLUXO.

        WHEN 'SCANNER'.
          PERFORM F_SCANNER.

        WHEN 'GERAR_XML'.
          CALL SCREEN 0102 STARTING AT 30 1.

        WHEN 'ANALISE_PO'.
*          CALL SCREEN 0103.

        WHEN 'SAVE'.
          PERFORM F_SAVE.

        WHEN 'SEL_PED'.
          CLEAR SY-UCOMM.
          PERFORM F_SELECIONA_ITEM.

        WHEN 'ELIM_ITEM'.
          PERFORM F_ELIMINA_ITEM.

        WHEN 'SEL_ALL'.
          PERFORM F_SELECIONA_TODOS.

        WHEN 'SEL_DALL'.
          PERFORM F_TIRA_SELECAO.

        WHEN 'EST_MIGO'.
          PERFORM F_EST_MIGO.

        WHEN 'EST_MIRO'.
          PERFORM F_EST_MIRO.

        WHEN 'DRILL'.
          PERFORM F_DRILL_DOC.

        WHEN 'LOGS'.
          CALL SCREEN 300 STARTING AT 30 1.

      ENDCASE.
      CLEAR: OK_CODE.

    ENDMODULE.                 " USER_COMMAND_0999  INPUT
