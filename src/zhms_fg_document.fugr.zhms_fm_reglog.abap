FUNCTION zhms_fm_reglog.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(CABDOC) TYPE  ZHMS_TB_CABDOC
*"     REFERENCE(FLOWD) TYPE  ZHMS_DE_FLOWD OPTIONAL
*"     REFERENCE(FLWST) TYPE  ZHMS_DE_FLWST
*"     REFERENCE(TPPRM) TYPE  ZHMS_DE_TPPRM OPTIONAL
*"  TABLES
*"      BAPIRET STRUCTURE  BAPIRET2 OPTIONAL
*"      LOGDOC STRUCTURE  ZHMS_TB_LOGDOC OPTIONAL
*"----------------------------------------------------------------------
* RCP - Tradução EN/ES - 15/08/2018

  DATA:   lt_scen    TYPE STANDARD TABLE OF zhms_tb_scen_flo,
          ls_scen    LIKE LINE OF lt_scen,
          ls_mail    TYPE zhms_tb_mail,
          lt_mail    TYPE STANDARD TABLE OF zhms_tb_mail,
          lv_control TYPE char1,
          lv_email   TYPE string.



  CLEAR: wa_flwdoc, wa_cabdoc.

**  Transferir para variaveis internas
  wa_cabdoc    = cabdoc.
  it_logdoc[]  = logdoc[].
  it_bapiret[] = bapiret[].

  IF flowd IS INITIAL.
**        Buscar etapa do fluxo
    SELECT SINGLE flowd
      INTO wa_flwdoc-flowd
      FROM zhms_tb_scen_flo
      WHERE natdc EQ wa_cabdoc-natdc
        AND typed EQ wa_cabdoc-typed
        AND loctp EQ wa_cabdoc-loctp
        AND scena EQ wa_cabdoc-scena
        AND tpprm EQ tpprm ."tipo de processamento
  ELSE.
    wa_flwdoc-flowd = flowd.
  ENDIF.

** Insere registro de etapa concluída no fluxo documento
  wa_flwdoc-natdc = wa_cabdoc-natdc.
  wa_flwdoc-typed = wa_cabdoc-typed.
  wa_flwdoc-loctp = wa_cabdoc-loctp.
  wa_flwdoc-chave = wa_cabdoc-chave.
  wa_flwdoc-dtreg = sy-datum.
  wa_flwdoc-hrreg = sy-uzeit.
  wa_flwdoc-uname = sy-uname.
  wa_flwdoc-flwst = flwst.


** remove anteriores.
  DELETE FROM zhms_tb_flwdoc
   WHERE natdc EQ wa_flwdoc-natdc
     AND typed EQ wa_flwdoc-typed
     AND loctp EQ wa_flwdoc-loctp
     AND chave EQ wa_flwdoc-chave
     AND flowd EQ wa_flwdoc-flowd.

  CLEAR lv_control.
  IF sy-subrc IS INITIAL.
    MOVE 'X' TO lv_control. "Duplicidade de email
  ENDIF.

  COMMIT WORK AND WAIT.

** insere na tabela de fluxo
  INSERT INTO zhms_tb_flwdoc VALUES wa_flwdoc.
  COMMIT WORK AND WAIT.

*  IF SY-SUBRC IS INITIAL AND LV_CONTROL IS INITIAL.
** Busca Proxima Etapa
  SELECT * FROM zhms_tb_scen_flo INTO TABLE lt_scen
                                WHERE natdc = wa_flwdoc-natdc
                                  AND typed = wa_flwdoc-typed
                                  AND scena = wa_cabdoc-scena
                                  AND flowd = flowd.

*RCP - 07/08/2018 - Início
*RCP - E-mail para Etapas Conferência, MIGO e MIRO
  PERFORM zf_verif_email_conf_migo_miro TABLES lt_scen
                                        USING  flowd
                                               wa_flwdoc-chave
                                               wa_flwdoc-natdc
                                               wa_flwdoc-typed
                                               wa_flwdoc-loctp
                                               wa_cabdoc-scena.
*RCP - 07/08/2018 - Fim


*** verifica se a etapa foi criada corretamente
  IF wa_flwdoc-flowd EQ '30' AND wa_flwdoc-flwst EQ 'W'.
*  IF wa_flwdoc-flwst EQ 'A'.
    REFRESH lt_mail.
    SELECT * FROM zhms_tb_mail INTO TABLE lt_mail
       WHERE natdc EQ wa_flwdoc-natdc
         AND typed EQ wa_flwdoc-typed
         AND flowd EQ flowd.

    IF lt_mail[] IS NOT INITIAL.
      LOOP AT lt_mail INTO ls_mail.

        IF ls_mail-ferias = 'X'.
          CLEAR lv_email.
          CALL FUNCTION 'EFG_GEN_GET_USER_EMAIL'
            EXPORTING
              i_uname           = ls_mail-userid
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
              i_uname           = ls_mail-uname
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
              chave   = wa_flwdoc-chave
              usuario = ls_mail-uname
              natdc   = wa_flwdoc-natdc
              typed   = wa_flwdoc-typed
              etapa   = flowd.

        ENDIF.

      ENDLOOP.
    ENDIF.
  ENDIF.
*ENDIF.

** percorre retorno da bapi para ajustar os logs
  LOOP AT it_bapiret INTO wa_bapiret.
    CLEAR wa_logdoc.

**  Dados de Log
    wa_logdoc-logid     = wa_bapiret-id.
    wa_logdoc-logty     = wa_bapiret-type.
    wa_logdoc-logno     = wa_bapiret-number.
    wa_logdoc-logv1     = wa_bapiret-message_v1.
    wa_logdoc-logv2     = wa_bapiret-message_v2.
    wa_logdoc-logv3     = wa_bapiret-message_v3.
    wa_logdoc-logv4     = wa_bapiret-message_v4.
    wa_logdoc-bapirow   = wa_bapiret-row.
    wa_logdoc-bapifield = wa_bapiret-field.
    wa_logdoc-bapiparam = wa_bapiret-parameter.

    APPEND wa_logdoc TO it_logdoc.

    IF wa_bapiret-type = 'E'.

      CLEAR vg_seqnr.
      SELECT SINGLE MAX( seqnr )
      INTO vg_seqnr
      FROM zhms_tb_hrvalid
      WHERE chave EQ wa_cabdoc-chave.

      ADD 1 TO vg_seqnr.

      CLEAR wa_hrvalid.
      wa_hrvalid-typed = wa_cabdoc-typed.
      wa_hrvalid-loctp = wa_cabdoc-loctp.
      wa_hrvalid-chave = wa_cabdoc-chave.
      wa_hrvalid-seqnr = vg_seqnr.
      wa_hrvalid-dtreg = sy-datum.
*wa_hRVALID-ATITM =
      wa_hrvalid-hrreg = sy-uzeit.
*wa_hRVALID-REGCD =
      wa_hrvalid-vldty = 'E'.
      wa_hrvalid-vldv1 = wa_bapiret-message_v1.
      wa_hrvalid-vldv2 = wa_bapiret-message_v2.
      wa_hrvalid-vldv3 = wa_bapiret-message_v3.
      wa_hrvalid-vldv4 = wa_bapiret-message_v4.
*wa_hRVALID-GRP   =
      wa_hrvalid-ativo = 'X'.

      MODIFY zhms_tb_hrvalid FROM wa_hrvalid.

      IF sy-subrc IS INITIAL.
        COMMIT WORK.
      ENDIF.

    ENDIF.

  ENDLOOP.

**  Percorre os dados de log para atualizar cabeçalho
  CLEAR vg_seqnr.
  LOOP AT it_logdoc INTO wa_logdoc.
    vg_seqnr = vg_seqnr + 1.
    wa_logdoc-natdc = wa_cabdoc-natdc.
    wa_logdoc-typed = wa_cabdoc-typed.
    wa_logdoc-loctp = wa_cabdoc-loctp.
    wa_logdoc-chave = wa_cabdoc-chave.
    wa_logdoc-flowd = wa_flwdoc-flowd.
    wa_logdoc-dtreg = sy-datum.
    wa_logdoc-hrreg = sy-uzeit.
    wa_logdoc-seqnr = vg_seqnr.
    wa_logdoc-uname = sy-uname.

    MODIFY it_logdoc FROM wa_logdoc INDEX sy-tabix.
  ENDLOOP.

** insere na tabela
  INSERT zhms_tb_logdoc FROM TABLE it_logdoc.
  COMMIT WORK AND WAIT.
*  LOOP AT it_logdoc INTO wa_logdoc.
*    INSERT INTO zhms_tb_logdoc VALUES wa_logdoc.
*    COMMIT WORK AND WAIT.
*  ENDLOOP.

ENDFUNCTION.
*FUNCTION zhms_fm_reglog.
**"----------------------------------------------------------------------
**"*"Interface local:
**"  IMPORTING
**"     REFERENCE(CABDOC) TYPE  ZHMS_TB_CABDOC
**"     REFERENCE(FLOWD) TYPE  ZHMS_DE_FLOWD OPTIONAL
**"     REFERENCE(FLWST) TYPE  ZHMS_DE_FLWST
**"     REFERENCE(TPPRM) TYPE  ZHMS_DE_TPPRM OPTIONAL
**"  TABLES
**"      BAPIRET STRUCTURE  BAPIRET2 OPTIONAL
**"      LOGDOC STRUCTURE  ZHMS_TB_LOGDOC OPTIONAL
**"----------------------------------------------------------------------
*
*  DATA: lt_scen    TYPE STANDARD TABLE OF zhms_tb_scen_flo,
*          ls_scen    LIKE LINE OF lt_scen,
*          ls_mail    TYPE zhms_tb_mail,
*          lv_control TYPE char1.
*
*  CLEAR: wa_flwdoc, wa_cabdoc.
*
***  Transferir para variaveis internas
*  wa_cabdoc    = cabdoc.
*  it_logdoc[]  = logdoc[].
*  it_bapiret[] = bapiret[].
*
*  IF flowd IS INITIAL.
***        Buscar etapa do fluxo
*    SELECT SINGLE flowd
*      INTO wa_flwdoc-flowd
*      FROM zhms_tb_scen_flo
*      WHERE natdc EQ wa_cabdoc-natdc
*        AND typed EQ wa_cabdoc-typed
*        AND loctp EQ wa_cabdoc-loctp
*        AND scena EQ wa_cabdoc-scena
*        AND tpprm EQ tpprm ."tipo de processamento
*  ELSE.
*    wa_flwdoc-flowd = flowd.
*  ENDIF.
*
*** Insere registro de etapa concluída no fluxo documento
*  wa_flwdoc-natdc = wa_cabdoc-natdc.
*  wa_flwdoc-typed = wa_cabdoc-typed.
*  wa_flwdoc-loctp = wa_cabdoc-loctp.
*  wa_flwdoc-chave = wa_cabdoc-chave.
*  wa_flwdoc-dtreg = sy-datum.
*  wa_flwdoc-hrreg = sy-uzeit.
*  wa_flwdoc-uname = sy-uname.
*  wa_flwdoc-flwst = flwst.
*
*
*** remove anteriores.
*  DELETE FROM zhms_tb_flwdoc
*   WHERE natdc EQ wa_flwdoc-natdc
*     AND typed EQ wa_flwdoc-typed
*     AND loctp EQ wa_flwdoc-loctp
*     AND chave EQ wa_flwdoc-chave
*     AND flowd EQ wa_flwdoc-flowd.
*
*  CLEAR lv_control.
*  IF sy-subrc IS INITIAL.
*    MOVE 'X' TO lv_control. "Duplicidade de email
*  ENDIF.
*
*  COMMIT WORK AND WAIT.
*
*** insere na tabela de fluxo
*  INSERT INTO zhms_tb_flwdoc VALUES wa_flwdoc.
*  COMMIT WORK AND WAIT.
*
*  IF sy-subrc IS INITIAL AND lv_control IS INITIAL.
**** Busca Proxima Etapa
*    SELECT * FROM zhms_tb_scen_flo INTO TABLE lt_scen
*      WHERE natdc = wa_flwdoc-natdc
*        AND typed = wa_flwdoc-typed
*        AND scena = wa_cabdoc-scena.
*
*    IF sy-subrc IS INITIAL.
*      READ TABLE lt_scen INTO ls_scen WITH KEY flowd = wa_flwdoc-flowd
*BINARY SEARCH.
*
*      IF sy-subrc IS INITIAL.
*        DO 100 TIMES.
*          ADD 1 TO sy-tabix.
*          READ TABLE lt_scen INTO ls_scen INDEX sy-tabix.
*          IF ls_scen-metpr EQ 'M'.
*            EXIT.
*          ENDIF.
*        ENDDO.
*
*        IF sy-subrc IS INITIAL.
**** busca responsável
*          SELECT SINGLE * FROM zhms_tb_mail INTO ls_mail WHERE natdc EQ
*ls_scen-natdc
*                                                           AND typed EQ
*ls_scen-typed
*                                                           AND flowd EQ
*ls_scen-flowd
*                                                           AND scena EQ
*ls_scen-scena.
*          IF sy-subrc IS INITIAL.
**** Envia e-mail alertando responsável porxima etapa
*            CALL FUNCTION 'ZHMS_ENVIA_EMAIL'
*              EXPORTING
*                chave   = wa_flwdoc-chave
*                usuario = ls_mail-uname
*                natdc   = ls_scen-natdc
*                typed   = ls_scen-typed
*                etapa   = ls_scen-flowd.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*  ENDIF.
*
*** percorre retorno da bapi para ajustar os logs
*  LOOP AT it_bapiret INTO wa_bapiret.
*    CLEAR wa_logdoc.
*
***  Dados de Log
*    wa_logdoc-logid     = wa_bapiret-id.
*    wa_logdoc-logty     = wa_bapiret-type.
*    wa_logdoc-logno     = wa_bapiret-number.
*    wa_logdoc-logv1     = wa_bapiret-message_v1.
*    wa_logdoc-logv2     = wa_bapiret-message_v2.
*    wa_logdoc-logv3     = wa_bapiret-message_v3.
*    wa_logdoc-logv4     = wa_bapiret-message_v4.
*    wa_logdoc-bapirow   = wa_bapiret-row.
*    wa_logdoc-bapifield = wa_bapiret-field.
*    wa_logdoc-bapiparam = wa_bapiret-parameter.
*
*    APPEND wa_logdoc TO it_logdoc.
*
*    IF wa_bapiret-type = 'E'.
*
*      CLEAR vg_seqnr.
*      SELECT SINGLE MAX( seqnr )
*      INTO vg_seqnr
*      FROM zhms_tb_hrvalid
*      WHERE chave EQ wa_cabdoc-chave.
*
*      ADD 1 TO vg_seqnr.
*
*      CLEAR wa_hrvalid.
*      wa_hrvalid-typed = wa_cabdoc-typed.
*      wa_hrvalid-loctp = wa_cabdoc-loctp.
*      wa_hrvalid-chave = wa_cabdoc-chave.
*      wa_hrvalid-seqnr = vg_seqnr.
*      wa_hrvalid-dtreg = sy-datum.
**wa_hRVALID-ATITM =
*      wa_hrvalid-hrreg = sy-uzeit.
**wa_hRVALID-REGCD =
*      wa_hrvalid-vldty = 'E'.
*      wa_hrvalid-vldv1 = wa_bapiret-message_v1.
*      wa_hrvalid-vldv2 = wa_bapiret-message_v2.
*      wa_hrvalid-vldv3 = wa_bapiret-message_v3.
*      wa_hrvalid-vldv4 = wa_bapiret-message_v4.
**wa_hRVALID-GRP   =
*      wa_hrvalid-ativo = 'X'.
*
*      MODIFY zhms_tb_hrvalid FROM wa_hrvalid.
*
*      IF sy-subrc IS INITIAL.
*        COMMIT WORK.
*      ENDIF.
*
*    ENDIF.
*
*  ENDLOOP.
*
***  Percorre os dados de log para atualizar cabeçalho
*  CLEAR vg_seqnr.
*  LOOP AT it_logdoc INTO wa_logdoc.
*    vg_seqnr = vg_seqnr + 1.
*    wa_logdoc-natdc = wa_cabdoc-natdc.
*    wa_logdoc-typed = wa_cabdoc-typed.
*    wa_logdoc-loctp = wa_cabdoc-loctp.
*    wa_logdoc-chave = wa_cabdoc-chave.
*    wa_logdoc-flowd = wa_flwdoc-flowd.
*    wa_logdoc-dtreg = sy-datum.
*    wa_logdoc-hrreg = sy-uzeit.
*    wa_logdoc-seqnr = vg_seqnr.
*    wa_logdoc-uname = sy-uname.
*
*    MODIFY it_logdoc FROM wa_logdoc INDEX sy-tabix.
*  ENDLOOP.
*
*** insere na tabela
*  INSERT zhms_tb_logdoc FROM TABLE it_logdoc.
*  COMMIT WORK AND WAIT.
**  LOOP AT it_logdoc INTO wa_logdoc.
**    INSERT INTO zhms_tb_logdoc VALUES wa_logdoc.
**    COMMIT WORK AND WAIT.
**  ENDLOOP.
*
*ENDFUNCTION.
