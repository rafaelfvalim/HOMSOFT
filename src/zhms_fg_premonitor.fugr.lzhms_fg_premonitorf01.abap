*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_PREMONITORF01 .
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*   Form  F_REG_EVENTS_home
*----------------------------------------------------------------------*
*   Registrando Eventos do HTML home
*----------------------------------------------------------------------*
    FORM f_reg_events_home.
***   Obtendo Eventos
      REFRESH t_events.
      CLEAR   wa_event.
      MOVE:   ob_html_home->m_id_sapevent TO wa_event-eventid,
              'X'                          TO wa_event-appl_event.
      APPEND  wa_event TO t_events.

***   Registrando Eventos
      CALL METHOD ob_html_home->set_registered_events
        EXPORTING
          events = t_events.

      IF ob_receiver IS INITIAL.
***     Criando objeto para Eventos HTML
        CREATE OBJECT ob_receiver.
***     Ativando gatilho de eventos
        SET HANDLER ob_receiver->on_sapevent FOR ob_html_home.
      ELSE.
***     Ativando gatilho de eventos
        SET HANDLER ob_receiver->on_sapevent FOR ob_html_home.
      ENDIF.
    ENDFORM.                    " F_REG_EVENTS_home

*----------------------------------------------------------------------*
*   Form  F_LOAD_IMAGES
*----------------------------------------------------------------------*
*   Carregando Imagens, Ícones e JavaScript
*----------------------------------------------------------------------*
    FORM f_load_images USING p_id
                             p_url.
***   ICON RATING NEUTRAL
      CALL METHOD ob_html_home->load_mime_object
        EXPORTING
          object_id            = p_id
          object_url           = p_url
        EXCEPTIONS
          object_not_found     = 1
          dp_invalid_parameter = 1
          dp_error_general     = 3
          OTHERS               = 4.

    ENDFORM.                    " F_LOAD_IMAGES
*&---------------------------------------------------------------------*
*&      Form  F_SHOWIMG
*&---------------------------------------------------------------------*
**            Exibe IMG de configuração
*----------------------------------------------------------------------*
    FORM f_showimg .


      CLEAR t_parameters.
      SELECT SINGLE *
        INTO wa_ttreet
        FROM ttreet
       WHERE spras EQ 'P'
         AND text_cap EQ 'MÓDULO DE CONFIGURAÇÕES HOMSOFT'.


      CLEAR t_parameters.
      t_parameters-name = 'control_enabled'.
      t_parameters-value = 'X'.
      APPEND t_parameters.

      CLEAR t_parameters.
      t_parameters-name = 'control_enabled_edit'.
      t_parameters-value = 'X'.
      APPEND t_parameters.

      CLEAR t_parameters.
      t_parameters-name = 'control_enabled_extension'.
      t_parameters-value = 'X'.
      APPEND t_parameters.

      CLEAR t_parameters.
      t_parameters-name = 'img_show_info'.
      t_parameters-value = 'X'.
      APPEND t_parameters.

      CLEAR t_parameters.
      t_parameters-name = 'mark_at_doubleclick'.
      t_parameters-value = 'X'.
      APPEND t_parameters.

      CLEAR t_parameters.
      t_parameters-name = 'tree_display'.
      t_parameters-value = 'FULLSCREEN_CONTROL'.
      APPEND t_parameters.

      CLEAR t_parameters.
      t_parameters-name = 'user_authority_check'.
      t_parameters-value = 'S_IMG_AUTHORITY_CHECK'.
      APPEND t_parameters.

      CLEAR t_parameters.
      t_parameters-name = 'user_change_exit_activity'.
      t_parameters-value = 'S_IMG_BEFORE_EXIT_TO_OBJECT'.
      APPEND t_parameters.

      CLEAR t_parameters.
      t_parameters-name = 'user_context_menue'.
      t_parameters-value = 'SPROJECT_CONTEXT_MENU'.
      APPEND t_parameters.

      CLEAR t_parameters.
      t_parameters-name = 'user_exit_1'.
      t_parameters-value = 'S_IMG_USER_EXIT_1'.
      APPEND t_parameters.

      CLEAR t_parameters.
      t_parameters-name = 'user_modify_display'.
      t_parameters-value = 'S_IMG_MODIFY_DISPLAY'.
      APPEND t_parameters.

      CLEAR t_parameters.
      t_parameters-name = 'user_node_change'.
      t_parameters-value = 'S_IMG_NODE_CHANGE'.
      APPEND t_parameters.

      CLEAR t_parameters.
      t_parameters-name = 'user_node_create'.
      t_parameters-value = 'S_IMG_NODE_CREATE'.
      APPEND t_parameters.

      CLEAR t_parameters.
      t_parameters-name = 'user_print_exit'.
      t_parameters-value = 'S_IMG_PRINT_EXIT'.
      APPEND t_parameters.

      CLEAR t_parameters.
      t_parameters-name = 'user_status'.
      t_parameters-value = 'S_IMG_SET_STATUS'.
      APPEND t_parameters.

      CLEAR t_parameters.
      t_parameters-name = 'user_use_only_treetype'.
      t_parameters-value = 'IMG'.
      APPEND t_parameters.

      CALL FUNCTION 'STREE_EXTERNAL_EDIT'
        EXPORTING
          structure_id    = wa_ttreet-id
          language        = sy-langu
          edit_structure  = 'X'
          activity        = 'D'
        TABLES
          user_parameters = t_parameters.
    ENDFORM.                    " F_SHOWIMG
