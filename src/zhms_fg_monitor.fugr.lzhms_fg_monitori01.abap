*----------------------------------------------------------------------*
*                      H  o  m  S  o  f  t                             *
*          Gestão Eletrônica de Documentos e Processos                 *
*----------------------------------------------------------------------*
* Descrição: Monitor Central de Gerenciamento de Documentos            *
*            Módulo PAI                                                *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*   Module  M_USER_COMMAND_0100  INPUT
*----------------------------------------------------------------------*
*   Eventos de Processamento da Tela 0100
*----------------------------------------------------------------------*
    MODULE m_user_command_0100 INPUT.

***   Gravando OKCODE
      MOVE sy-ucomm TO ok_code.

**    Tratamento tela de visualizações
      IF ok_code(4) EQ 'VIS_'.
        PERFORM f_trata_visualizacao_documento USING ok_code.
      ENDIF.

      CHECK ok_code(4) NE 'VIS_'.

**    Demais tratamentos
      CASE ok_code.
        WHEN 'INDEX'.
**    limpando okcode
          CLEAR sy-ucomm.
          IF vg_0100 EQ '0112'.
            CLEAR vg_0100.
            MOVE  '0113' TO vg_0100.
          ELSE.
            CLEAR vg_0100.
            MOVE  '0112' TO vg_0100.
          ENDIF.

        WHEN 'BACK'.
**       Destruir Arvore de fluxo
          IF NOT ob_cc_det_flow IS INITIAL.
            " destroy tree container (detroys contained tree control, too)
            CALL METHOD ob_cc_det_flow->free
              EXCEPTIONS
                cntl_system_error = 1
                cntl_error        = 2.
            IF sy-subrc <> 0.
              MESSAGE a000.
            ENDIF.
            CLEAR ob_cc_det_flow.
            CLEAR ob_flow.
          ENDIF.

**        Voltar
          LEAVE TO SCREEN 0.

        WHEN 'DOWNLOAD'.

*** Verifica Autorização usuario
          CALL FUNCTION 'ZHMS_FM_SECURITY'
            EXPORTING
              value         = 'EVENTO_ET'
            EXCEPTIONS
              authorization = 1
              OTHERS        = 2.

          IF sy-subrc <> 0.
            MESSAGE e000(zhms_security). "   Usuário sem autorização
          ENDIF.

          CALL TRANSACTION 'ZHMS_DOW_XML'.

        WHEN 'LOGS'.

*** Verifica Autorização usuario
          CALL FUNCTION 'ZHMS_FM_SECURITY'
            EXPORTING
              value         = 'PESQ_LOG_NOTA'
            EXCEPTIONS
              authorization = 1
              OTHERS        = 2.

          IF sy-subrc <> 0.
            MESSAGE e000(zhms_security). "   Usuário sem autorização
          ENDIF.

          CALL SCREEN '0603'.

        WHEN OTHERS.
          CALL METHOD cl_gui_cfw=>dispatch.

      ENDCASE.

**    Tratamento de códigos de dispatch
      IF NOT ok_code IS INITIAL.
        IF ok_code(1) EQ '%'.
**        Limpar variaveis
          CLEAR: ok_code, sy-ucomm.
        ENDIF.
      ENDIF.

***   Gravando OKCODE de Controle
      MOVE ok_code TO save_ok.
    ENDMODULE.                 " M_USER_COMMAND_0100  INPUT

*----------------------------------------------------------------------*
*   Module  M_USER_COMMAND_0100_EXIT  INPUT
*----------------------------------------------------------------------*
*   Eventos de Saída da Tela 0100
*----------------------------------------------------------------------*
    MODULE m_user_command_0100_exit INPUT.
***   Gravando OKCODE
      MOVE sy-ucomm TO ok_code.

      CASE ok_code.
        WHEN 'CANC'  OR  'EXIT'.
          LEAVE TO SCREEN 0.

        WHEN OTHERS.
      ENDCASE.

**    Limpando SY-UCOMM
      CLEAR sy-ucomm.
    ENDMODULE.                 " M_USER_COMMAND_0100_EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       Controles para tela de logs
*----------------------------------------------------------------------*
    MODULE m_user_command_0300 INPUT.
      CASE ok_code.
        WHEN 'CANC'.
          LEAVE TO SCREEN 0.
      ENDCASE.

      CLEAR ok_code.
    ENDMODULE.                 " USER_COMMAND_0300  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*       Controles para tela de logs
*----------------------------------------------------------------------*
    MODULE m_user_command_0500 INPUT.
      DATA: vl_erro TYPE flag.

      ok_code = sy-ucomm.

**  Tarefas comuns realizadas caso não seja o fechamento da janela
      IF ok_code NE 'CANC'.
**    Calculos realizados caso atribuição proporcional esteja marcada
        IF vg_atprp EQ 'X'.
          PERFORM f_atr_proporcional.
        ENDIF.
**     Completa a lista de atribuição com os dados automaticos
        PERFORM f_atr_completalista.
      ENDIF.


**    Tratamento de ok_code
      CASE ok_code.
        WHEN 'CANC'.
**        Fechar janela
          vg_0500 = '0501'.
          LEAVE TO SCREEN 0.

        WHEN 'ATR_GRAVAR'.
*Homine - Inicio da Inclusão - DD - Ajuste Atribuição
          IF t_itmatr_ax[] IS INITIAL.
**          Gravar alterações
            PERFORM f_atr_gravar_exc.
          ELSE.
*Homine - Fim da Inclusão - DD - Ajuste Atribuição
            CLEAR vl_erro.
**        Validar valores inseridos
            PERFORM f_atr_valida CHANGING vl_erro.

            IF vl_erro IS INITIAL.
**          Gravar alterações
              PERFORM f_atr_gravar.

            ENDIF.
*Homine - Inicio da Inclusão - DD - Ajuste Atribuição
          ENDIF.
*Homine - Fim da Inclusão - DD - Ajuste Atribuição
        WHEN 'DES_REF'.
**          Habilita / Desabilita
          CLEAR vg_tdsrf.

        WHEN 'INSR'.
**      Insere um item vazio
          CLEAR wa_itmatr_ax.
          APPEND wa_itmatr_ax TO t_itmatr_ax.

**     Completa a lista de atribuição com os dados automaticos
          PERFORM f_atr_completalista.

**    Calculos realizados caso atribuição proporcional esteja marcada
          IF vg_atprp EQ 'X'.
            PERFORM f_atr_proporcional.
          ENDIF.
        WHEN OTHERS.
          vg_handle = 'ATR'.
          CALL METHOD cl_gui_cfw=>dispatch.
      ENDCASE.

      CLEAR ok_code.
      sy-ucomm = ok_code.
    ENDMODULE.                 " USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0506  INPUT
*&---------------------------------------------------------------------*
*       Controles para tela de logs
*----------------------------------------------------------------------*
    MODULE m_user_command_0506 INPUT.
*      DATA: vl_erro TYPE flag.

      ok_code = sy-ucomm.

**  Tarefas comuns realizadas caso não seja o fechamento da janela
      IF ok_code NE 'CANC'.
**    Calculos realizados caso atribuição proporcional esteja marcada
        IF vg_atprp EQ 'X'.
          PERFORM f_atr_proporcional.
        ENDIF.
**     Completa a lista de atribuição com os dados automaticos
        PERFORM f_atr_completalista.
      ENDIF.


**    Tratamento de ok_code
      CASE ok_code.
        WHEN 'CANC'.
          REFRESH t_itmatr_ax.
          clear: t_itmatr_ax, vg_atprp.
**        Fechar janela
          LEAVE to screen 0500.

        WHEN 'ATR_GRAVAR'.
*Homine - Inicio da Inclusão - DD - Ajuste Atribuição
          IF t_itmatr_ax[] IS INITIAL.
**          Gravar alterações
            PERFORM f_atr_gravar_exc.
          ELSE.
*Homine - Fim da Inclusão - DD - Ajuste Atribuição
            CLEAR vl_erro.
**        Validar valores inseridos
            PERFORM f_atr_valida CHANGING vl_erro.

            IF vl_erro IS INITIAL.
**          Gravar alterações
              PERFORM f_atr_gravar.
            ENDIF.
*Homine - Inicio da Inclusão - DD - Ajuste Atribuição
          ENDIF.

*Homine - Fim da Inclusão - DD - Ajuste Atribuição
        WHEN 'DES_REF'.
**          Habilita / Desabilita
          CLEAR vg_tdsrf.

        WHEN 'INSR'.
**      Insere um item vazio
          CLEAR wa_itmatr_ax.
          APPEND wa_itmatr_ax TO t_itmatr_ax.

**     Completa a lista de atribuição com os dados automaticos
          PERFORM f_atr_completalista.

**    Calculos realizados caso atribuição proporcional esteja marcada
          IF vg_atprp EQ 'X'.
            PERFORM f_atr_proporcional.
          ENDIF.
        WHEN OTHERS.
          vg_handle = 'ATR'.
          CALL METHOD cl_gui_cfw=>dispatch.
      ENDCASE.

      CLEAR ok_code.
      sy-ucomm = ok_code.
    ENDMODULE.                 " USER_COMMAND_0506  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0600  INPUT
*&---------------------------------------------------------------------*
*       Controles para tela
*----------------------------------------------------------------------*
    MODULE m_user_command_0600 INPUT.
      ok_code = sy-ucomm.

      CASE ok_code.
        WHEN 'SEND'.
**        Envia evento de entidade tributária
          PERFORM f_send_eventet.

        WHEN OTHERS.

      ENDCASE.

    ENDMODULE.                    "m_user_command_0600 INPUT

*----------------------------------------------------------------------*
*   Module  USER_COMMAND_0200  INPUT
*----------------------------------------------------------------------*
*   Eventos de Processamento
*----------------------------------------------------------------------*
    MODULE m_user_command_0200  INPUT.
      ok_code = sy-ucomm.

      CASE ok_code.
        WHEN 'PRT_SHOW'.
**        Seleciona para exibição a portaria selecionada
          PERFORM f_showportaria.
        WHEN 'PRT_CANC'.
**        Tratamento para solicitação de cancelamento de portaria
          PERFORM f_cancelaportaria.

        WHEN OTHERS.

      ENDCASE.

    ENDMODULE.                    "m_USER_COMMAND_0200  INPUT
*----------------------------------------------------------------------*
*   Module  USER_COMMAND_0250  INPUT
*----------------------------------------------------------------------*
*   Eventos de Processamento para tela
*----------------------------------------------------------------------*
    MODULE m_user_command_0250  INPUT.
      ok_code = sy-ucomm.

      CASE ok_code.
        WHEN 'CONF_SHOW'.
**        Seleciona para exibição da conferencia selecionada
          PERFORM f_showconferencia.
        WHEN 'CONF_CANC'.
**        Cancela conferencia
          PERFORM f_cancelaconferencia.

        WHEN OTHERS.

      ENDCASE.

    ENDMODULE.                    "m_USER_COMMAND_0250  INPUT
*----------------------------------------------------------------------*
*   Module  EXIT_0200  INPUT
*----------------------------------------------------------------------*
*   Eventos de Processamento
*----------------------------------------------------------------------*

    MODULE m_exit_0200 INPUT.
      ok_code = sy-ucomm.

      CASE ok_code.
        WHEN 'CANC'.
          LEAVE TO SCREEN 0.
        WHEN OTHERS.

      ENDCASE.

      CLEAR ok_code.
      sy-ucomm = ok_code.
    ENDMODULE.                    "m_exit_0200 INPUT

*----------------------------------------------------------------------*
*   Module  EXIT_0250  INPUT
*----------------------------------------------------------------------*
*   Eventos de Processamento
*----------------------------------------------------------------------*

    MODULE m_exit_0250 INPUT.
      ok_code = sy-ucomm.

      CASE ok_code.
        WHEN 'CANC'.
          LEAVE TO SCREEN 0.
        WHEN OTHERS.

      ENDCASE.

      CLEAR ok_code.
      sy-ucomm = ok_code.
    ENDMODULE.                    "m_exit_0250 INPUT

*----------------------------------------------------------------------*
*   Module  EXIT_0600  INPUT
*----------------------------------------------------------------------*
*   Eventos de Processamento
*----------------------------------------------------------------------*
    MODULE m_exit_0600 INPUT.
      ok_code = sy-ucomm.

      CASE ok_code.
        WHEN 'CANC'.
          CLEAR: wa_dcevet.
**        Caso o objeto tenha sido criado
**        Retira dados da edição
          IF NOT ob_dcevt_obs IS INITIAL.
            CALL METHOD ob_dcevt_obs->free
              EXCEPTIONS
                OTHERS = 1.
            IF sy-subrc NE 0.
            ENDIF.
            FREE ob_dcevt_obs.
          ENDIF.

          IF NOT ob_cc_dcevt_obs IS INITIAL.
            CALL METHOD ob_cc_dcevt_obs->free
              EXCEPTIONS
                OTHERS = 1.
            IF sy-subrc <> 0.
            ENDIF.
            FREE ob_cc_dcevt_obs.
          ENDIF.

          CALL METHOD cl_gui_cfw=>flush
            EXCEPTIONS
              OTHERS = 1.
          IF sy-subrc NE 0.
          ENDIF.
          LEAVE TO SCREEN 0.
        WHEN OTHERS.

      ENDCASE.

      CLEAR ok_code.
      sy-ucomm = ok_code.
    ENDMODULE.                    "m_exit_0600 INPUT

*----------------------------------------------------------------------*
*   Module  USER_COMMAND_0400  INPUT
*----------------------------------------------------------------------*
*   Eventos de Processamento
*----------------------------------------------------------------------*
    MODULE m_user_command_0400 INPUT.
      CASE ok_code.
        WHEN 'CANC'.
          LEAVE TO SCREEN 0.
        WHEN 'VLD_EXHIST'.
          vg_vld_shwhst = 'X'.
        WHEN 'VLD_EXVLD'.
          vg_vld_shwdlt = 'X'.
        WHEN 'VLD_CLHIST'.
          CLEAR vg_vld_shwhst.
        WHEN 'VLD_CLVLD'.
          CLEAR vg_vld_shwdlt.
        WHEN 'VLD_VALIDA'.
          PERFORM f_exec_validacoes.
          CLEAR wa_hvalid_vw.
        WHEN OTHERS.
          vg_handle = 'VLD'.
          CALL METHOD cl_gui_cfw=>dispatch.

      ENDCASE.

      IF vg_vld_shwhst IS INITIAL
        AND vg_vld_shwdlt IS INITIAL.
        vg_0400 = 403.
      ENDIF.

      IF vg_vld_shwhst IS INITIAL
        AND NOT vg_vld_shwdlt IS INITIAL.
        vg_0400 = 401.
      ENDIF.

      IF NOT vg_vld_shwhst IS INITIAL
        AND vg_vld_shwdlt IS INITIAL.
        vg_0400 = 404.
      ENDIF.

      IF NOT vg_vld_shwhst IS INITIAL
        AND NOT vg_vld_shwdlt IS INITIAL.
        vg_0400 = 402.
      ENDIF.

      CLEAR ok_code.
    ENDMODULE.                 " USER_COMMAND_0300  INPUT

*----------------------------------------------------------------------*
*   Module  TS_DET_DOC_ACTIVE_TAB_GET  INPUT
*----------------------------------------------------------------------*
*   Controles para subtelas tabstrip de detalhes
*----------------------------------------------------------------------*
    MODULE ts_det_doc_active_tab_get INPUT.
      ok_code = sy-ucomm.
      CASE ok_code.
        WHEN c_ts_det_doc-tab1.
          g_ts_det_doc-pressed_tab = c_ts_det_doc-tab1.
        WHEN c_ts_det_doc-tab2.
          g_ts_det_doc-pressed_tab = c_ts_det_doc-tab2.
        WHEN c_ts_det_doc-tab3.
          g_ts_det_doc-pressed_tab = c_ts_det_doc-tab3.
        WHEN OTHERS.
      ENDCASE.
    ENDMODULE.                    "TS_DET_DOC_ACTIVE_TAB_GET INPUT

*----------------------------------------------------------------------*
*  MODULE tc_atr_itmatr_mark INPUT
*----------------------------------------------------------------------*
*   Controles para Table Control de Atribuição
*----------------------------------------------------------------------*
    MODULE tc_atr_itmatr_mark INPUT.
      DATA: g_tc_atr_itmatr_wa2 LIKE LINE OF t_itmatr_ax.
      IF tc_atr_itmatr-line_sel_mode = 1
      AND wa_itmatr_ax-check = 'X'.
        LOOP AT t_itmatr_ax INTO g_tc_atr_itmatr_wa2
          WHERE check = 'X'.
          g_tc_atr_itmatr_wa2-check = ''.
          MODIFY t_itmatr_ax
            FROM g_tc_atr_itmatr_wa2
            TRANSPORTING check.
        ENDLOOP.
      ENDIF.
      MODIFY t_itmatr_ax
        FROM wa_itmatr_ax
        INDEX tc_atr_itmatr-current_line
        TRANSPORTING check.

      MODIFY t_itmatr_ax
    FROM wa_itmatr_ax
    INDEX tc_atr_itmatr-current_line.

    ENDMODULE.                    "TC_ATR_ITMATR_MARK INPUT

*----------------------------------------------------------------------*
*  MODULE TC_ATR_ITMATR_MODIFY INPUT
*----------------------------------------------------------------------*
*   Controles para Table Control de Atribuição
*----------------------------------------------------------------------*
    MODULE tc_atr_itmatr_modify INPUT.
      DATA: wl_itmatr_ax     TYPE ty_itmatr.
      READ TABLE t_itmatr_ax INTO wl_itmatr_ax INDEX tc_atr_itmatr-current_line.
      IF sy-subrc IS INITIAL.

*** Monta numero do lote
        IF wl_itmatr_ax-atlot IS INITIAL.
          CALL FUNCTION 'ZHMS_FM_SET_LOTE'
            EXPORTING
              po   = wl_itmatr_ax-nrsrf
              item = wl_itmatr_ax-itsrf
            IMPORTING
              lote = wl_itmatr_ax-atlot.
        ENDIF.

        MODIFY t_itmatr_ax
          FROM wa_itmatr_ax
          INDEX tc_atr_itmatr-current_line.
      ELSE.
        APPEND wa_itmatr_ax TO t_itmatr_ax.
      ENDIF.

    ENDMODULE.                    "TC_ATR_ITMATR_MODIFY INPUT


*----------------------------------------------------------------------*
*  MODULE tc_atr_itmatr_user_command INPUT
*----------------------------------------------------------------------*
*   Controles para Table Control de Atribuição
*----------------------------------------------------------------------*
    MODULE tc_atr_itmatr_user_command INPUT.
      ok_code = sy-ucomm.
*Homine - Inicio da Inclusão - DD - Ajuste Atribuição
      vg_atr_exc = sy-ucomm.
      IF vg_atr_exc = 'TC_ATR_ITMATR_DELE' .
        LOOP AT t_itmatr_ax INTO wa_itmatr_ax.
          IF wa_itmatr_ax-check = 'X'.
            MOVE-CORRESPONDING: wa_itmatr_ax TO wa_itmatr_ex.
            APPEND wa_itmatr_ex TO t_itmatr_ex.
          ENDIF.
        ENDLOOP.
      ENDIF.
*Homine - Fim da Inclusão - DD - Ajuste Atribuição
      PERFORM user_ok_tc USING    'TC_ATR_ITMATR'
                                  'T_ITMATR_AX'
                                  'CHECK'
                         CHANGING ok_code.

      LOOP AT t_itmatr_ax INTO wa_itmatr_ax.
        MOVE sy-tabix TO v_index.

*** Monta numero do lote
        IF wa_itmatr_ax-atlot IS INITIAL.
          CALL FUNCTION 'ZHMS_FM_SET_LOTE'
            EXPORTING
              po   = wa_itmatr_ax-nrsrf
              item = wa_itmatr_ax-itsrf
            IMPORTING
              lote = wa_itmatr_ax-atlot.
        ENDIF.
        MODIFY t_itmatr_ax FROM wa_itmatr_ax INDEX v_index.

      ENDLOOP.

      CASE ok_code.
        WHEN 'BT_CR'.
          READ TABLE  t_itmatr_ax INTO wa_itmatr_ax WITH KEY check = 'X'.
          IF sy-subrc IS INITIAL.
***         Chamar Subtela
            CALL SCREEN 504 STARTING AT 30 1.
          ELSE.
            MESSAGE i067.
          ENDIF.
        WHEN OTHERS.
      ENDCASE.

      sy-ucomm = ok_code.

    ENDMODULE.                    "TC_ATR_ITMATR_USER_COMMAND INPUT

*----------------------------------------------------------------------*
*  MODULE TC_CNF_DOCRCBTO_MARK INPUT
*----------------------------------------------------------------------*
* Table control para histórico de portarias
*----------------------------------------------------------------------*
    MODULE tc_prt_docrcbto_mark INPUT.
      DATA: g_tc_prt_docrcbto_wa2 LIKE LINE OF t_docrcbto_ax.
      IF tc_prt_docrcbto-line_sel_mode = 1
      AND wa_docrcbto_ax-check = 'X'.
        LOOP AT t_docrcbto_ax INTO g_tc_prt_docrcbto_wa2
          WHERE check = 'X'.
          g_tc_prt_docrcbto_wa2-check = ''.
          MODIFY t_docrcbto_ax
            FROM g_tc_prt_docrcbto_wa2
            TRANSPORTING check.
        ENDLOOP.
      ENDIF.
      MODIFY t_docrcbto_ax
        FROM wa_docrcbto_ax
        INDEX tc_prt_docrcbto-current_line
        TRANSPORTING check.
    ENDMODULE.                    "TC_PRT_DOCRCBTO_MARK INPUT

*----------------------------------------------------------------------*
*  MODULE TC_CNF_DOCCONF_MARK INPUT
*----------------------------------------------------------------------*
* Table control para histórico de conferencias
*----------------------------------------------------------------------*
    MODULE tc_cnf_docconf_mark INPUT.
      DATA: g_tc_cnf_docconf_wa2 LIKE LINE OF t_docconf_ax.
      IF tc_cnf_docconf-line_sel_mode = 1
      AND wa_docconf_ax-check = 'X'.
        LOOP AT t_docconf_ax INTO g_tc_cnf_docconf_wa2
          WHERE check = 'X'.
          g_tc_cnf_docconf_wa2-check = ''.
          MODIFY t_docconf_ax
            FROM g_tc_cnf_docconf_wa2
            TRANSPORTING check.
        ENDLOOP.
      ENDIF.
      MODIFY t_docconf_ax
        FROM wa_docconf_ax
        INDEX tc_cnf_docconf-current_line
        TRANSPORTING check.
    ENDMODULE.                    "TC_CNF_DOCCONF_MARK INPUT

*&---------------------------------------------------------------------*
*&      Module m_list_events  INPUT
*&---------------------------------------------------------------------*
*       Dados personalizados para lista de opções de eventos ET
*----------------------------------------------------------------------*
    MODULE m_list_events INPUT.

**    Dados Locais
      TYPE-POOLS : vrm.
*      DATA: vl_idflw     TYPE  vrm_id VALUE 'VG_FLOWD'.
      DATA: vl_idflw     TYPE  vrm_id VALUE 'WA_DCEVET-EVTET'.
      DATA: tl_opcoesflw TYPE vrm_values,
            wl_opcoesflw LIKE LINE OF tl_opcoesflw.

      REFRESH : tl_opcoesflw[].

**    Busca dados cadastrados
      SELECT *
        INTO TABLE t_nfeevt
        FROM zhms_tb_nfeevt
       WHERE natdc EQ wa_cabdoc-natdc
         AND typed EQ wa_cabdoc-typed.

**    Insere registros na tabela interna de lista
      LOOP AT t_nfeevt INTO wa_nfeevt.
        CLEAR wl_opcoesflw.
        wl_opcoesflw-key  = wa_nfeevt-evtet.
        wl_opcoesflw-text = wa_nfeevt-denom.
        APPEND wl_opcoesflw TO tl_opcoesflw.
      ENDLOOP.

**    Insere registros da tabela interna na lista
      CALL FUNCTION 'VRM_SET_VALUES'
        EXPORTING
          id     = vl_idflw
          values = tl_opcoesflw.

**    tratativa de erros
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    ENDMODULE.                    "m_list_events INPUT

*&---------------------------------------------------------------------*
*&      Module  M_LIST_FLOWD  INPUT
*&---------------------------------------------------------------------*
*       Dados personalizados para lista de etapas
*----------------------------------------------------------------------*
    MODULE m_list_flowd INPUT.

**    Dados Locais
      TYPE-POOLS : vrm.
      DATA: vl_id     TYPE  vrm_id VALUE 'VG_FLOWD'.
      DATA: tl_opcoes TYPE vrm_values,
            wl_opcoes LIKE LINE OF tl_opcoes.

      REFRESH : tl_opcoes[].

**    Busca dados cadastrados

**    Limpar as variáveis
      CLEAR: wa_scenflox.
      REFRESH: t_scenflox.

**    Selecionar fluxo para este tipo de documento
      SELECT *
        INTO TABLE t_scenflox
        FROM zhms_tx_scen_flo
        WHERE natdc	EQ wa_cabdoc-natdc
          AND typed	EQ wa_cabdoc-typed
          AND loctp  EQ wa_cabdoc-loctp
          AND scena	EQ wa_cabdoc-scena
          AND spras	EQ sy-langu.

**    Insere registros na tabela interna de lista
      LOOP AT t_scenflox INTO wa_scenflox.
        CLEAR wl_opcoes.
        wl_opcoes-key  = wa_scenflox-flowd.
        wl_opcoes-text = wa_scenflox-denom.
        APPEND wl_opcoes TO tl_opcoes.
      ENDLOOP.

**    Insere registros da tabela interna na lista
      CALL FUNCTION 'VRM_SET_VALUES'
        EXPORTING
          id     = vl_id
          values = tl_opcoes.

**    tratativa de erros
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    ENDMODULE.                 " M_LIST_FLOWD  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0407  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    MODULE user_command_0407 INPUT.

      MOVE sy-ucomm TO ok_code.

      CASE ok_code.
        WHEN 'CANC'.
          LEAVE TO SCREEN 0.
        WHEN 'BACK'.
          LEAVE TO SCREEN 0.
        WHEN 'VLD_VALIDA'.
          PERFORM f_exec_validacoes.
          CLEAR wa_hvalid_vw.
      ENDCASE.

    ENDMODULE.                 " USER_COMMAND_0407  INPUT

*&SPWIZARD: INPUT MODULE FOR TS 'TAB_01'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GETS ACTIVE TAB
    MODULE tab_01_active_tab_get INPUT.
      ok_code = sy-ucomm.
      CASE ok_code.
        WHEN c_tab_01-tab1.
          g_tab_01-pressed_tab = c_tab_01-tab1.
        WHEN c_tab_01-tab2.
          g_tab_01-pressed_tab = c_tab_01-tab2.
        WHEN OTHERS.
*&SPWIZARD:      DO NOTHING
      ENDCASE.
    ENDMODULE.                    "TAB_01_ACTIVE_TAB_GET INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0110  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    MODULE user_command_0110 INPUT.



    ENDMODULE.                 " USER_COMMAND_0110  INPUT

*&SPWIZARD: INPUT MODULE FOR TS 'TABSTRIPLOGS'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GETS ACTIVE TAB
    MODULE tabstriplogs_active_tab_get INPUT.
      ok_code = sy-ucomm.
      CASE ok_code.
        WHEN c_tabstriplogs-tab1.
          g_tabstriplogs-pressed_tab = c_tabstriplogs-tab1.
        WHEN c_tabstriplogs-tab2.
          g_tabstriplogs-pressed_tab = c_tabstriplogs-tab2.
        WHEN OTHERS.
*&SPWIZARD:      DO NOTHING
      ENDCASE.
    ENDMODULE.                    "TABSTRIPLOGS_ACTIVE_TAB_GET INPUT
*&---------------------------------------------------------------------*
*&      Module  M_USER_COMMAND_0603_EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    MODULE m_user_command_0603_exit INPUT.

      MOVE sy-ucomm TO ok_code.

      CASE ok_code.
        WHEN 'EXIT'.
          LEAVE PROGRAM.
        WHEN OTHERS.
      ENDCASE.

      CLEAR  sy-ucomm.

    ENDMODULE.                 " M_USER_COMMAND_0603_EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Form  CARREGA_LOGS_CONECTOR
*&---------------------------------------------------------------------*
    FORM carrega_logs_conector .

      TYPES: BEGIN OF ty_select,
         line TYPE char80,
      END OF ty_select.

      DATA:  t_where      TYPE TABLE OF ty_select WITH HEADER LINE,
             ls_where     LIKE LINE OF t_where,
             ls_where_tab TYPE rsdswhere.

      REFRESH: t_logunk,
               t_where.

      CLEAR : ls_where.

      IF NOT wa_logparam-dataate IS INITIAL.
        CONCATENATE '  DTALT GE ''' wa_logparam-datade  ''''  INTO ls_where RESPECTING BLANKS.
        APPEND ls_where TO t_where . CLEAR ls_where.
        CONCATENATE '   AND DTALT LE ''' wa_logparam-dataate  ''''  INTO ls_where RESPECTING BLANKS .
        APPEND ls_where TO t_where . CLEAR ls_where.
      ELSEIF  NOT wa_logparam-datade IS INITIAL.
        CONCATENATE ' DTALT EQ ''' wa_logparam-datade  ''''  INTO ls_where RESPECTING BLANKS.
        APPEND ls_where TO t_where . CLEAR ls_where.
      ENDIF.

      IF NOT wa_logparam-lote IS INITIAL AND NOT t_where[] IS INITIAL.
        CONCATENATE ' AND LOTE EQ ''' wa_logparam-lote ''''  INTO ls_where RESPECTING BLANKS.
        APPEND ls_where TO t_where . CLEAR ls_where.
      ELSEIF NOT wa_logparam-lote IS INITIAL.
        CONCATENATE ' LOTE EQ ''' wa_logparam-lote ''''  INTO ls_where RESPECTING BLANKS.
        APPEND ls_where TO t_where . CLEAR ls_where.
      ENDIF.

      IF NOT t_where[] IS INITIAL.
        SELECT * FROM zhms_tx_events
        INTO TABLE t_tx_events
         WHERE spras = sy-langu.

        SELECT * FROM zhms_tb_logunk
        INTO CORRESPONDING FIELDS OF TABLE t_logunk
        WHERE (t_where).

        SORT t_logunk BY lote nrmsg.

        LOOP AT t_logunk INTO wa_logunk.
          wa_logunk-detal = '@10@'.
          READ TABLE t_tx_events INTO wa_tx_events
          WITH KEY
              natdc = wa_logunk-natdc
              typed = wa_logunk-typed
              event = wa_logunk-event.
          IF sy-subrc EQ 0 .
            wa_logunk-descr = wa_tx_events-denom.
          ENDIF.
          MODIFY t_logunk FROM wa_logunk.
        ENDLOOP.
      ELSE.
        MESSAGE i064.
      ENDIF.

    ENDFORM.                    " CARREGA_LOGS_CONECTOR
*&---------------------------------------------------------------------*
*&      Module  M_USER_COMMAND_0603  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    MODULE m_user_command_0603 INPUT.
*      ok_code = sy-ucomm.

      CASE ok_code.
        WHEN 'PESQ'.
          PERFORM carrega_logs_conector.
          CLEAR ok_code.
        WHEN 'BACK' .
          LEAVE TO SCREEN 0.
        WHEN 'TC_ERROSLOGCO_P-' OR 'TC_ERROSLOGCO_P--' OR 'TC_ERROSLOGCO_P+' OR 'TC_ERROSLOGCO_P++'.

          PERFORM user_ok_tc USING    'TC_ERROSLOGCO'
                                      'T_LOGUNK'
                                      ' '
                             CHANGING ok_code.
          sy-ucomm = ok_code.
        WHEN 'DET' .
          PERFORM  carrega_logs_detalhe.
          CALL SCREEN 0604 STARTING AT 30  1.
      ENDCASE.

    ENDMODULE.                 " M_USER_COMMAND_0603  INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TC_ERROSLOGCO'. DO NOT CHANGE THIS LINE
*&SPWIZARD: PROCESS USER COMMAND
    MODULE tc_erroslogco_user_command INPUT.
      ok_code = sy-ucomm.
      PERFORM user_ok_tc USING    'TC_ERROSLOGCO'
                                  'T_LOGUNK'
                                  ' '
                         CHANGING ok_code.
      sy-ucomm = ok_code.
    ENDMODULE.                    "TC_ERROSLOGCO_USER_COMMAND INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TC_ERROSLOGDET'. DO NOT CHANGE THIS LIN
*&SPWIZARD: PROCESS USER COMMAND
    MODULE tc_erroslogdet_user_command INPUT.
      ok_code = sy-ucomm.
      PERFORM user_ok_tc USING    'TC_ERROSLOGDET'
                                  'T_LOGDETAL'
                                  ' '
                         CHANGING ok_code.
      sy-ucomm = ok_code.
    ENDMODULE.                    "TC_ERROSLOGDET_USER_COMMAND INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0604  INPUT
*&---------------------------------------------------------------------*
    MODULE user_command_0604 INPUT.
      ok_code = sy-ucomm.

      CASE ok_code.
        WHEN 'EXIT'.
          LEAVE TO SCREEN 0.
      ENDCASE.

    ENDMODULE.                 " USER_COMMAND_0604  INPUT
*&---------------------------------------------------------------------*
*&      Form  CARREGA_LOGS_DETALHE
*&---------------------------------------------------------------------*
    FORM carrega_logs_detalhe .
      DATA: l_row TYPE i,
      l_field(20) TYPE c.

      REFRESH: t_logdetal.

      GET CURSOR LINE l_row.
      l_row = tc_erroslogco-top_line + l_row - 1.
      READ TABLE t_logunk INDEX l_row INTO wa_logunkaux.


      SELECT * FROM zhms_tb_msgunka
          INTO CORRESPONDING FIELDS OF TABLE t_logdetal
      WHERE
        lote = wa_logunkaux-lote.

      LOOP AT t_logdetal INTO wa_logdetal.
        wa_logdetal-tipo = 'ATR'.
        MODIFY t_logdetal FROM wa_logdetal.
      ENDLOOP.

      SELECT * FROM zhms_tb_msgunk
      APPENDING CORRESPONDING FIELDS OF TABLE t_logdetal
      WHERE
          lote = wa_logunkaux-lote.

      SORT t_logdetal BY seqnc tipo.

    ENDFORM.                    " CARREGA_LOGS_DETALHE
*&---------------------------------------------------------------------*
*&      Module  TC_ERROSLOGCO_MARK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    MODULE tc_erroslogco_mark INPUT.

      READ TABLE t_logunk INDEX tc_erroslogco-current_line
      INTO wa_logunkaux.

    ENDMODULE.                 " TC_ERROSLOGCO_MARK  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0301  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    MODULE user_command_0301 INPUT.

      ok_code = sy-ucomm.

      CASE ok_code.
        WHEN 'BACK'.
          LEAVE TO SCREEN 0.
        WHEN 'LEAVE'.
          LEAVE TO SCREEN 0.
        WHEN 'CANCEL'.
          LEAVE TO SCREEN 0.
      ENDCASE.

    ENDMODULE.                 " USER_COMMAND_0301  INPUT
*&---------------------------------------------------------------------*
*&      Module  M_EXIT_0301  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    MODULE m_exit_0301 INPUT.

      ok_code = sy-ucomm.

      CASE ok_code.
        WHEN 'CANCELAR'.
          LEAVE TO SCREEN 0.
        WHEN OTHERS.
          LEAVE TO SCREEN 0.
      ENDCASE.

      CLEAR ok_code.
      sy-ucomm = ok_code.

    ENDMODULE.                 " M_EXIT_0301  INPUT

*&SPWIZARD: INPUT MODUL FOR TC 'TC_SHOW_PO'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
    MODULE tc_show_po_mark INPUT.
      DATA: g_tc_show_po_wa2 LIKE LINE OF t_show_po.
      IF tc_show_po-line_sel_mode = 1
      AND wa_show_po-mark = 'X'.
        LOOP AT t_show_po INTO g_tc_show_po_wa2
          WHERE mark = 'X'.
          g_tc_show_po_wa2-mark = ''.
          MODIFY t_show_po
            FROM g_tc_show_po_wa2
            TRANSPORTING mark.
        ENDLOOP.
      ENDIF.
      MODIFY t_show_po
        FROM wa_show_po
        INDEX tc_show_po-current_line
        TRANSPORTING mark.
    ENDMODULE.                    "TC_SHOW_PO_MARK INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TC_SHOW_PO'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
    MODULE tc_show_po_user_command INPUT.
      ok_code = sy-ucomm.
      PERFORM user_ok_tc USING    'TC_SHOW_PO'
                                  'T_SHOW_PO'
                                  'MARK'
                         CHANGING ok_code.
      sy-ucomm = ok_code.
    ENDMODULE.                    "TC_SHOW_PO_USER_COMMAND INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0700  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    MODULE user_command_0700 INPUT.

    ENDMODULE.                 " USER_COMMAND_0700  INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TC_J1B1N_IMP'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
    MODULE tc_j1b1n_imp_modify INPUT.
      MODIFY t_impostos
        FROM wa_impostos
        INDEX tc_j1b1n_imp-current_line.
    ENDMODULE.                    "TC_J1B1N_IMP_MODIFY INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0504  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    MODULE user_command_0504 INPUT.

      CLEAR vg_just_ok.
      CASE sy-ucomm.
        WHEN 'GRAVAR'.

          PERFORM f_grava_justificativa.
          LEAVE TO SCREEN 0.

        WHEN 'CANCELAR'.

          LEAVE TO SCREEN 0.

        WHEN OTHERS.
      ENDCASE.

    ENDMODULE.                 " USER_COMMAND_0504  INPUT
*&---------------------------------------------------------------------*
*&      Module  ZF_ATUALIZA_NCM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    MODULE zf_atualiza_ncm INPUT.

      IF NOT vg_just_ok IS INITIAL.

        IF tc_atr_itmatr-line_sel_mode = 1.
          LOOP AT t_itmatr_ax INTO g_tc_atr_itmatr_wa2
            WHERE check = 'X'.
            g_tc_atr_itmatr_wa2-check = ''.
            MODIFY t_itmatr_ax
              FROM g_tc_atr_itmatr_wa2
              TRANSPORTING check.
          ENDLOOP.
        ENDIF.
        MODIFY t_itmatr_ax
          FROM wa_itmatr_ax
          INDEX tc_atr_itmatr-current_line
          TRANSPORTING check.

        MODIFY t_itmatr_ax
      FROM wa_itmatr_ax
      INDEX tc_atr_itmatr-current_line.
      ENDIF.

    ENDMODULE.                 " ZF_ATUALIZA_NCM  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0605  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    MODULE user_command_0605 INPUT.

      IF sy-ucomm = 'CANC'.
*        BREAK rsantos.
        CLEAR: t_alv_ped_aux, t_alv_comp_au, t_alv_ped, t_alv_xml.
        LEAVE TO SCREEN 0.
      ENDIF.
    ENDMODULE.                 " USER_COMMAND_0605  INPUT
