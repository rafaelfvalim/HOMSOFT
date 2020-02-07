*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_PREMONITORO01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  M_LOAD_HOME_HTML  OUTPUT
*&---------------------------------------------------------------------*
*       Carregando a tela inicial HomSoft
*----------------------------------------------------------------------*
MODULE m_load_home_html OUTPUT.
  IF ob_cc_home IS INITIAL.
***     Criando objeto de container
    CREATE OBJECT ob_cc_home
      EXPORTING
        container_name = 'CC_HOME'
      EXCEPTIONS
        others         = 1.

  ENDIF.

  IF ob_html_home IS INITIAL.

***     Criando Objeto HTML - Índice
    CREATE OBJECT ob_html_home
      EXPORTING
        parent             = ob_cc_home
      EXCEPTIONS
        cntl_error         = 1
        cntl_install_error = 2
        dp_install_error   = 3
        dp_error           = 4
        OTHERS             = 5.

    IF sy-subrc EQ 0.
***       Registrando Eventos do HTML home
      PERFORM f_reg_events_home.
***       Carregando Ícone Padrão
      REFRESH t_wwwdata.
      CLEAR wa_wwwdata.

      SELECT * INTO TABLE t_wwwdata
               FROM wwwdata
               WHERE objid LIKE 'ZHMS%'
                 AND srtf2 EQ 0.

      LOOP AT t_wwwdata INTO wa_wwwdata.
        PERFORM f_load_images USING wa_wwwdata-objid
                                    wa_wwwdata-text.
      ENDLOOP.

      REFRESH t_srscd.
      CLEAR   wa_srscd.

      IF sy-tcode EQ 'ZNDD'.
        CALL FUNCTION 'ZHMS_FM_GET_HTML_HOME_NDD'
          TABLES
            srscd  = t_srscd
          EXCEPTIONS
            error  = 1
            OTHERS = 2.

      ELSE.
***       obtendo fonte html
        CALL FUNCTION 'ZHMS_FM_GET_HTML_HOME'
          TABLES
            srscd  = t_srscd
          EXCEPTIONS
            error  = 1
            OTHERS = 2.
      ENDIF.


      IF sy-subrc EQ 0  AND NOT t_srscd[] IS INITIAL.
        LOOP AT t_srscd INTO wa_srscd.
          APPEND wa_srscd TO t_srscd_ev.
        ENDLOOP.

        IF NOT t_srscd_ev IS INITIAL.
***           Preparando dados para Exibição do Índice
          CLEAR vg_url.
          ob_html_home->load_data( IMPORTING assigned_url = vg_url
                                    CHANGING  data_table   = t_srscd_ev ).
***           Exibindo Índice
          ob_html_home->show_url( url = vg_url ).
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDMODULE.                 " M_LOAD_HOME_HTML  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  M_STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       Controles de Tela
*----------------------------------------------------------------------*
MODULE m_status_0100 OUTPUT.
  SET PF-STATUS '0100'.

  IF sy-tcode EQ 'ZNDD'.
    SET TITLEBAR  '0200'.
  ELSE.
    SET TITLEBAR  '0100'.
  ENDIF.

ENDMODULE.                 " M_STATUS_0100  OUTPUT
