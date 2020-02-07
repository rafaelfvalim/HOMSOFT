*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_MONITORF08 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  ZF_VERIF_EMAIL_PORTARIA
*&---------------------------------------------------------------------*
*       Verificará se há Evento de Portaria.
*       Caso positivo, será enviado e-mail para o responsável para que
*       o processo seja executado.
*----------------------------------------------------------------------*
*      -->P_T_FLWDOC  text
*      -->P_T_SCENFLO text
*----------------------------------------------------------------------*
FORM zf_verif_EMAIL_portaria  TABLES   p_t_flwdoc p_t_scenflo.

  DATA: lt_flwdoc  TYPE TABLE OF zhms_tb_flwdoc,
        lw_flwdoc  TYPE zhms_tb_flwdoc,
        lw_scenflo TYPE zhms_tb_scen_flo,
        lt_mail    TYPE STANDARD TABLE OF zhms_tb_mail,
        lw_mail    TYPE zhms_tb_mail,
        lv_email   TYPE string,
        lv_control TYPE char1,
        lv_linhas  TYPE i.


  lt_flwdoc[] = p_t_flwdoc[].

  DESCRIBE TABLE lt_flwdoc LINES lv_linhas.
  IF lv_linhas NE 0.

    CLEAR lw_flwdoc.
    READ TABLE lt_flwdoc INTO lw_flwdoc INDEX lv_linhas.
    IF sy-subrc IS INITIAL.

      CLEAR lw_scenflo.
      READ TABLE t_scenflo INTO lw_scenflo
                           WITH KEY natdc = lw_flwdoc-natdc
                                    typed = lw_flwdoc-typed
                                    loctp = lw_flwdoc-loctp
                                    flowd = lw_flwdoc-flowd.

*** Enviará email alertando as próximas etapas, pois já houve a Atribuição e
*** Levantamento automático de dados
      IF sy-subrc IS INITIAL AND lw_scenflo-tpprm = '0' AND
                                 lw_scenflo-funct IS INITIAL. " Levantamento automático de dados

        CLEAR lw_scenflo.
        LOOP AT t_scenflo INTO lw_scenflo WHERE natdc = lw_flwdoc-natdc
                                            AND typed = lw_flwdoc-typed
                                            AND loctp = lw_flwdoc-loctp.

          IF lw_scenflo-tpprm = '1'.    " Recebimento: Portaria

            REFRESH lt_mail.
            SELECT * FROM zhms_tb_mail
               INTO TABLE lt_mail
               WHERE natdc EQ lw_flwdoc-natdc
                 AND typed EQ lw_flwdoc-typed
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
                      chave   = lw_flwdoc-chave
                      usuario = lw_mail-uname
                      natdc   = lw_flwdoc-natdc
                      typed   = lw_flwdoc-typed
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

ENDFORM.                    " ZF_VERIF_EMAIL_PORTARIA
*&---------------------------------------------------------------------*
*&      Form  ZF_VERIF_EMAIL_CONF_MIGO_MIRO
*&---------------------------------------------------------------------*
*       Verificará se há Eventos de Conferência, MIGO e MIRO
*       Caso positivo, será enviado e-mail para o responsável para que
*       o processo seja executado.
*----------------------------------------------------------------------*
FORM ZF_VERIF_EMAIL_CONF_MIGO_MIRO .




ENDFORM.                    " ZF_VERIF_EMAIL_CONF_MIGO_MIRO
