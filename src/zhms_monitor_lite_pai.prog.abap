*&---------------------------------------------------------------------*
*&  Include           ZHMS_MONITOR_LITE_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  DATA: l_valid TYPE c,
        vl_sthms TYPE zhms_tb_docst-sthms.
  DATA: tl_docum  TYPE TABLE OF zhms_es_docum,
        wl_docum  TYPE zhms_es_docum.


  CALL METHOD ob_cc_0100_grid->check_changed_data
    IMPORTING
      e_valid = l_valid.

*  break rsantos.

  CASE sy-ucomm.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'ATRIB'.
      PERFORM f_valida_check.
      PERFORM f_valida_2_linhas.

      IF vg_check_flag = 'X'.
        CLEAR vg_check_flag.
        EXIT.
      ENDIF.
*** Verifica Autorização usuario
      CALL FUNCTION 'ZHMS_FM_SECURITY'
        EXPORTING
          value         = 'ATRIBUICAO'
        EXCEPTIONS
          authorization = 1
          OTHERS        = 2.

      IF sy-subrc <> 0.
        MESSAGE e000(zhms_security). "   Usuário sem autorização
      ENDIF.

      READ TABLE t_0100 INTO wa_0100 WITH KEY checkbox = 'X'.
      IF sy-subrc EQ 0.
        vg_chave = wa_0100-chave.
      ENDIF.
***         Chamar Subtela
      CALL SCREEN 500 STARTING AT 30 1.

    WHEN 'AUDIT'.
      PERFORM f_valida_check.
      PERFORM f_valida_2_linhas.
      IF vg_check_flag = 'X'.
        CLEAR vg_check_flag.
        EXIT.
      ENDIF.

      CALL SCREEN 0606 STARTING AT 30 1.

    WHEN 'CONF'.
      PERFORM f_valida_check.
      PERFORM f_valida_2_linhas.
      IF vg_check_flag = 'X'.
        CLEAR vg_check_flag.
        EXIT.
      ENDIF.

    WHEN 'DEBTPOST'.
      PERFORM f_valida_check.
      PERFORM f_valida_2_linhas.
      IF vg_check_flag = 'X'.
        CLEAR vg_check_flag.
        EXIT.
      ENDIF.

    WHEN 'FLOWEXE'.

      PERFORM f_valida_check.
      IF vg_check_flag = 'X'.
        CLEAR vg_check_flag.
        EXIT.
      ENDIF.

*** Verifica Autorização usuario
      CALL FUNCTION 'ZHMS_FM_SECURITY'
        EXPORTING
          value         = 'EXECUTAR_FLUXO'
        EXCEPTIONS
          authorization = 1
          OTHERS        = 2.

      IF sy-subrc <> 0.
        MESSAGE e000(zhms_security). " Usuário sem autorização
      ENDIF.

**          Executa regras identificação de cenário
      REFRESH: tl_docum.
      CLEAR wl_docum.
      wl_docum-dctyp = 'CHAVE'.
      wl_docum-dcnro = wa_cabdoc-chave.
      APPEND wl_docum TO tl_docum.

      CALL FUNCTION 'ZHMS_FM_TRACER'
        EXPORTING
          natdc                 = wa_cabdoc-natdc
          typed                 = wa_cabdoc-typed
          loctp                 = wa_cabdoc-loctp
        TABLES
          docum                 = tl_docum
        EXCEPTIONS
          document_not_informed = 1
          scenario_not_found    = 2
          OTHERS                = 3.

* Verifica se nota mudou o stauts
      CLEAR vl_sthms.

      SELECT SINGLE sthms
        FROM zhms_tb_docst
        INTO vl_sthms
        WHERE natdc = wa_cabdoc-natdc
          AND typed = wa_cabdoc-typed
          AND loctp = wa_cabdoc-loctp
          AND chave = wa_cabdoc-chave.
      IF sy-subrc EQ 0.
        READ TABLE t_docst INTO wa_docst WITH KEY natdc = wa_cabdoc-natdc
                                                  typed = wa_cabdoc-typed
                                                  loctp = wa_cabdoc-loctp
                                                  chave = wa_cabdoc-chave.
        IF sy-subrc EQ 0.
          IF wa_docst-sthms <> vl_sthms.
            IF vl_sthms = 1.
              READ TABLE t_0100 INTO wa_0100 WITH KEY chave = wa_cabdoc-chave.
              IF sy-subrc EQ 0.
                wa_0100-sthms = '@0V@'.
                MODIFY t_0100 FROM wa_0100 INDEX sy-tabix.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN 'HIST'.
      PERFORM f_valida_check.
      PERFORM f_valida_2_linhas.
      IF vg_check_flag = 'X'.
        CLEAR vg_check_flag.
        EXIT.
      ENDIF.

      CALL SCREEN 0301 STARTING AT 30 1.
    WHEN 'J1B1N'.
      PERFORM f_valida_check.
      PERFORM f_valida_2_linhas.

      IF vg_check_flag = 'X'.
        CLEAR vg_check_flag.
        EXIT.
      ENDIF.

    WHEN 'LOGS'.
      PERFORM f_valida_check.
      PERFORM f_valida_2_linhas.

      IF vg_check_flag = 'X'.
        CLEAR vg_check_flag.
        EXIT.
      ENDIF.

***         Limpar etapa
      CLEAR vg_flowd.
***         Chamar Subtela
      CALL SCREEN 300 STARTING AT 30 1.

    WHEN 'PORT'.
      PERFORM f_valida_check.
      PERFORM f_valida_2_linhas.

      IF vg_check_flag = 'X'.
        CLEAR vg_check_flag.
        EXIT.
      ENDIF.

    WHEN 'VALID'.
      PERFORM f_valida_check.
      PERFORM f_valida_2_linhas.

      IF vg_check_flag = 'X'.
        CLEAR vg_check_flag.
        EXIT.
      ENDIF.

      CALL SCREEN 0407.
    WHEN OTHERS.
      EXIT.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_VALIDA_CHECK
*&---------------------------------------------------------------------*
FORM f_valida_check .
  READ TABLE t_0100 INTO wa_0100 WITH KEY checkbox = 'X'.
  IF sy-subrc NE 0.
    MESSAGE s000(zhms_mc_monitor) WITH text-010 DISPLAY LIKE 'E'.
    vg_check_flag = 'X'.
  ENDIF.
ENDFORM.                    " F_VALIDA_CHECK

*&---------------------------------------------------------------------*
*&      Module  M_USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*       text
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
      CLEAR vl_erro.
**        Validar valores inseridos
      PERFORM f_atr_valida CHANGING vl_erro.

      IF vl_erro IS INITIAL.
**          Gravar alterações
        PERFORM f_atr_gravar.
      ENDIF.

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
ENDMODULE.                 " M_USER_COMMAND_0500  INPUT

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

*----------------------------------------------------------------------*
*  MODULE tc_atr_itmatr_user_command INPUT
*----------------------------------------------------------------------*
*   Controles para Table Control de Atribuição
*----------------------------------------------------------------------*
MODULE tc_atr_itmatr_user_command INPUT.
  ok_code = sy-ucomm.
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
*&---------------------------------------------------------------------*
*&      Module  TC_SHOW_PO_USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_show_po_user_command INPUT.

  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TC_SHOW_PO'
                              'T_SHOW_PO'
                              'MARK'
                     CHANGING ok_code.
  sy-ucomm = ok_code.

ENDMODULE.                 " TC_SHOW_PO_USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0503  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0503 INPUT.

  IF sy-ucomm EQ 'TRANSF'.

    READ TABLE t_show_po INTO wa_show_po WITH KEY mark = 'X'.

    IF sy-subrc IS INITIAL.
      MOVE: wa_show_po-ebeln TO wa_itmatr_ax-nrsrf,
            wa_show_po-ebelp TO wa_itmatr_ax-itsrf.
      APPEND wa_itmatr_ax TO t_itmatr_ax.
    ENDIF.

  ENDIF.

ENDMODULE.                 " USER_COMMAND_0503  INPUT

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
*&---------------------------------------------------------------------*
*&      Module  TAB_01_ACTIVE_TAB_GET  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
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
ENDMODULE.                 " TAB_01_ACTIVE_TAB_GET  INPUT
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
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0110  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0110 INPUT.

ENDMODULE.                 " USER_COMMAND_0110  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_VALIDA_2_LINHAS
*&---------------------------------------------------------------------*
FORM f_valida_2_linhas .
  DATA: vl_lin TYPE i.
  t_0100_aux = t_0100.
  DELETE t_0100_aux WHERE checkbox NE 'X'.
  DESCRIBE TABLE t_0100_aux LINES vl_lin.
  IF vl_lin >= 2.
    MESSAGE s000(zhms_mc_monitor) WITH text-011 DISPLAY LIKE 'E'.
    vg_check_flag = 'X'.
  ENDIF.

ENDFORM.                    " F_VALIDA_2_LINHAS
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
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0606  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0606 INPUT.
  IF sy-ucomm = 'CANC'.
*        BREAK rsantos.
    CLEAR: t_alv_ped_aux, t_alv_comp_au, t_alv_ped, t_alv_xml.
    LEAVE TO SCREEN 0.
  ENDIF.
ENDMODULE.                 " USER_COMMAND_0606  INPUT
*&---------------------------------------------------------------------*
*&      Module  M_USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_user_command_0300 INPUT.
  CASE ok_code.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.

  CLEAR ok_code.
ENDMODULE.                 " M_USER_COMMAND_0300  INPUT
