*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_GATEI01 .
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*  MODULE TC_prt_DOCRCBTO_MARK INPUT
*----------------------------------------------------------------------*
*  Lista de documentos recebidos
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
    ENDMODULE.                    "TC_prt_DOCRCBTO_MARK INPUT
**----------------------------------------------------------------------*
**  MODULE TS_RCB_INPUT_ACTIVE_TAB_GET INPUT
**----------------------------------------------------------------------*
**  Controles para subtelas de seleção do recebimento
**----------------------------------------------------------------------*
*    MODULE ts_rcb_input_active_tab_get INPUT.
*      ok_code = sy-ucomm.
*      CASE ok_code.
*        WHEN c_ts_rcb_input-tab1.
*          g_ts_rcb_input-pressed_tab = c_ts_rcb_input-tab1.
*        WHEN c_ts_rcb_input-tab2.
*          g_ts_rcb_input-pressed_tab = c_ts_rcb_input-tab2.
*        WHEN OTHERS.
*
*      ENDCASE.
*    ENDMODULE.                    "TS_RCB_INPUT_ACTIVE_TAB_GET INPUT

*&---------------------------------------------------------------------*
*&      Module  M_USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*       Tratamento para ações da tela de recepção
*----------------------------------------------------------------------*
    MODULE m_user_command_0500 INPUT.
      ok_code = sy-ucomm.

      PERFORM f_trata_acoes.

      CLEAR ok_code.
    ENDMODULE.                 " M_USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*&      Module  M_USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*       Tratamento para ações da tela de conferencia
*----------------------------------------------------------------------*
    MODULE m_user_command_0400 INPUT.
      ok_code = sy-ucomm.

      PERFORM f_trata_acoes_conf.

      CLEAR ok_code.
    ENDMODULE.                 " M_USER_COMMAND_0400  INPUT


*&---------------------------------------------------------------------*
*&      Module  M_USER_COMMAND_0500_EXIT  INPUT
*&---------------------------------------------------------------------*
*       Eventos de Saída da Tela 0500
*----------------------------------------------------------------------*
    MODULE m_user_command_exit INPUT.
***   Gravando OKCODE
      MOVE sy-ucomm TO ok_code.

      CASE ok_code.
        WHEN 'BACK'.
          LEAVE TO SCREEN 0.

        WHEN 'CANC'  OR  'EXIT'.
          LEAVE TO SCREEN 0.

        WHEN OTHERS.
      ENDCASE.

**    Limpando SY-UCOMM
      CLEAR sy-ucomm.
    ENDMODULE.                 " M_USER_COMMAND_0500_EXIT  INPUT

*----------------------------------------------------------------------*
*  MODULE ts_rcb_meth_active_tab_get INPUT
*----------------------------------------------------------------------*
*  Tabstrip de seleção de documento para conferencia
*----------------------------------------------------------------------*
    MODULE ts_rcb_meth_active_tab_get INPUT.
      ok_code = sy-ucomm.
      CASE ok_code.
        WHEN c_ts_rcb_meth-tab1.
          g_ts_rcb_meth-pressed_tab = c_ts_rcb_meth-tab1.
        WHEN c_ts_rcb_meth-tab2.
          g_ts_rcb_meth-pressed_tab = c_ts_rcb_meth-tab2.
        WHEN OTHERS.

      ENDCASE.
    ENDMODULE.                    "TS_RCB_METH_ACTIVE_TAB_GET INPUT


*----------------------------------------------------------------------*
*  MODULE TS_CONF_METH_ACTIVE_TAB_GET INPUT
*----------------------------------------------------------------------*
*  Tabstrip de seleção de documento para conferencia
*----------------------------------------------------------------------*
    MODULE ts_conf_meth_active_tab_get INPUT.
      ok_code = sy-ucomm.
      CASE ok_code.
        WHEN c_ts_conf_meth-tab1.
          g_ts_conf_meth-pressed_tab = c_ts_conf_meth-tab1.
        WHEN c_ts_conf_meth-tab2.
          g_ts_conf_meth-pressed_tab = c_ts_conf_meth-tab2.
        WHEN OTHERS.

      ENDCASE.
    ENDMODULE.                    "TS_CONF_METH_ACTIVE_TAB_GET INPUT


*----------------------------------------------------------------------*
*  MODULE TC_CNF_DATCONF_MODIFY INPUT
*----------------------------------------------------------------------*
*  Table Control de conferencia
*----------------------------------------------------------------------*
    MODULE tc_cnf_datconf_modify INPUT.
      MODIFY t_datconf_ax
        FROM wa_datconf_ax
        INDEX tc_cnf_datconf-current_line.
    ENDMODULE.                    "TC_CNF_DATCONF_MODIFY INPUT


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
