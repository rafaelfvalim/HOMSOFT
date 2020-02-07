*&---------------------------------------------------------------------*
*&      Form  ZF_VERIF_EMAIL_CONF_MIGO_MIRO
*&---------------------------------------------------------------------*
*       Verificará se há as Etapas de Conferência, MIGO e MIRO.
*       Caso positivo, serão enviados os respectivos e-mail´s para os
*       responsáveis para que o processo seja executado.
*----------------------------------------------------------------------*
*      -->P_LT_SCEN  text
*----------------------------------------------------------------------*
FORM zf_verif_email_conf_migo_miro
                        TABLES   p_lt_scen STRUCTURE zhms_tb_scen_flo
                        USING    p_flowd
                                 p_wa_flwdoc_chave
                                 p_wa_flwdoc_natdc
                                 p_wa_flwdoc_typed
                                 p_wa_flwdoc_loctp
                                 p_wa_cabdoc_scena.


  DATA: lt_flwdoc  TYPE TABLE OF zhms_tb_flwdoc,
        lw_flwdoc  TYPE zhms_tb_flwdoc,
        lw_scenflo TYPE zhms_tb_scen_flo,
        lt_scenflo TYPE STANDARD TABLE OF zhms_tb_scen_flo,
        lt_mail    TYPE STANDARD TABLE OF zhms_tb_mail,
        lw_mail    TYPE zhms_tb_mail,
        lv_email   TYPE string,
        lv_linhas  TYPE i.


** Selecionar fluxo para este tipo de documento
  REFRESH: lt_scenflo.
  SELECT *
    INTO TABLE lt_scenflo
    FROM zhms_tb_scen_flo
   WHERE natdc EQ p_wa_flwdoc_natdc
     AND typed EQ p_wa_flwdoc_typed
     AND loctp EQ p_wa_flwdoc_loctp
     AND scena EQ p_wa_cabdoc_scena.

** Seleciona etapas do documento.
  IF NOT lt_scenflo[] IS INITIAL.

    SELECT *
      INTO TABLE lt_flwdoc
      FROM zhms_tb_flwdoc
      FOR ALL ENTRIES IN lt_scenflo
    WHERE natdc EQ p_wa_flwdoc_natdc
      AND typed EQ p_wa_flwdoc_typed
      AND loctp EQ p_wa_flwdoc_loctp
      AND chave EQ p_wa_flwdoc_chave
      AND flowd EQ lt_scenflo-flowd.

  ENDIF.

  DESCRIBE TABLE lt_flwdoc LINES lv_linhas.
  IF lv_linhas NE 0.

    CLEAR lw_flwdoc.
    READ TABLE lt_flwdoc INTO lw_flwdoc INDEX lv_linhas.
    IF sy-subrc IS INITIAL.

      CLEAR lw_scenflo.
      READ TABLE lt_scenflo INTO lw_scenflo
                           WITH KEY natdc = lw_flwdoc-natdc
                                    typed = lw_flwdoc-typed
                                    loctp = lw_flwdoc-loctp
                                    flowd = lw_flwdoc-flowd.

*** Enviará email alertando as próximas etapas: Conferência, MIGO e MIRO,
*** pois já foi executado a Etapa Portaria
      IF sy-subrc IS INITIAL AND lw_scenflo-tpprm = '1'.  " Portaria

        CLEAR lw_scenflo.
        LOOP AT t_scenflo INTO lw_scenflo WHERE natdc = p_wa_flwdoc_natdc
                                            AND typed = p_wa_flwdoc_typed
                                            AND loctp = p_wa_flwdoc_loctp.

          IF lw_scenflo-flowd > lw_flwdoc-flowd AND lw_scenflo-tpprm NE '1'.

            REFRESH lt_mail.
            SELECT * FROM zhms_tb_mail
               INTO TABLE lt_mail
               WHERE natdc EQ p_wa_flwdoc_natdc
                 AND typed EQ p_wa_flwdoc_typed
                 AND flowd EQ lw_scenflo-flowd.

            IF lt_mail[] IS NOT INITIAL.

              LOOP AT lt_mail INTO lw_mail.

                IF lw_mail-ferias = 'X'.
                  CLEAR lv_email.
                  CALL FUNCTION 'EFG_GEN_GET_USER_EMAIL'
                    EXPORTING
                      i_uname           = lw_mail-userid
                    IMPORTING
                      e_email_address   = lv_email
                    EXCEPTIONS
                      not_qualified     = 1
                      user_not_found    = 2
                      address_not_found = 3
                      OTHERS            = 4.
                ELSE.
                  CLEAR lv_email.
                  CALL FUNCTION 'EFG_GEN_GET_USER_EMAIL'
                    EXPORTING
                      i_uname           = lw_mail-uname
                    IMPORTING
                      e_email_address   = lv_email
                    EXCEPTIONS
                      not_qualified     = 1
                      user_not_found    = 2
                      address_not_found = 3
                      OTHERS            = 4.
                ENDIF.

                IF sy-subrc IS INITIAL AND lv_email IS NOT INITIAL.

                  CALL FUNCTION 'ZHMS_ENVIA_EMAIL'
                    EXPORTING
                      chave   = p_wa_flwdoc_chave
                      usuario = lw_mail-uname
                      natdc   = p_wa_flwdoc_natdc
                      typed   = p_wa_flwdoc_typed
                      etapa   = lw_scenflo-flowd.

                ENDIF.

              ENDLOOP.

              IF lt_mail[] IS NOT INITIAL.
                EXIT.   " Saída imediata, pois o e-mail já foi enviado.
              ENDIF.

            ENDIF.
          ENDIF.

        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " ZF_VERIF_EMAIL_CONF_MIGO_MIRO
