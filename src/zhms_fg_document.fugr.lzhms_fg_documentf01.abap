*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_DOCUMENTF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_TRATA_ST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_trata_st USING wl_cabdoc STRUCTURE zhms_tb_cabdoc.

  DATA:  wa_hrvalid   TYPE zhms_tb_hrvalid,
           vg_flowd   TYPE zhms_de_flowd,
           ls_logdoc  TYPE zhms_tb_logdoc,
           lt_docmn   TYPE STANDARD TABLE OF zhms_tb_docmn,
           ls_docmn   LIKE LINE OF lt_docmn.

**    Limpar as variáveis
  CLEAR: wa_flwdoc, wa_scenflo, wa_flwdoc.
  REFRESH: it_flwdoc, t_scenflo, t_flwdoc.

**    Selecionar fluxo para este tipo de documento
  SELECT *
    INTO TABLE t_scenflo
    FROM zhms_tb_scen_flo
   WHERE natdc EQ wl_cabdoc-natdc
     AND typed EQ wl_cabdoc-typed
     AND loctp EQ wl_cabdoc-loctp
     AND scena EQ wl_cabdoc-scena.

**     Seleciona etapas do documento.
  IF NOT t_scenflo[] IS INITIAL.

    SELECT *
      INTO TABLE t_flwdoc
      FROM zhms_tb_flwdoc
      FOR ALL ENTRIES IN t_scenflo
    WHERE natdc EQ wl_cabdoc-natdc
      AND typed EQ wl_cabdoc-typed
      AND loctp EQ wl_cabdoc-loctp
      AND chave EQ wl_cabdoc-chave
      AND flowd EQ t_scenflo-flowd.

  ENDIF.

** executa validação
  CLEAR vg_vldcd.

  SELECT SINGLE vldcd
    INTO vg_vldcd
    FROM zhms_tb_scenario
   WHERE natdc EQ wl_cabdoc-natdc
     AND typed EQ wl_cabdoc-typed
     AND loctp EQ wl_cabdoc-loctp
     AND scena EQ wl_cabdoc-scena.

**    Executa funções de validação
  IF NOT vg_vldcd IS INITIAL.
    CLEAR vg_vldty.
    CALL FUNCTION 'ZHMS_FM_VALIDAR'
      EXPORTING
        vldcd   = vg_vldcd
        cabdoc  = wl_cabdoc
        reghist = ' '
      IMPORTING
        vldty   = vg_vldty.
  ENDIF.

*** Verifica se houve erro na Validação
  CLEAR: vg_sthms, wa_hrvalid.
  SELECT SINGLE * FROM zhms_tb_hrvalid INTO wa_hrvalid WHERE chave EQ wl_cabdoc-chave
                                                         AND ativo EQ 'X'.

  IF sy-subrc IS INITIAL.

*** Verifica se já foi realizado a MIRO
    SELECT SINGLE *
     FROM zhms_tb_docmn
     INTO ls_docmn
      WHERE chave EQ wl_cabdoc-chave
        AND mneum EQ 'INVDOCNO'.

    IF sy-subrc IS NOT INITIAL.
      CASE wa_hrvalid-vldty.
        WHEN 'E'.
          vg_sthms = 4.
      ENDCASE.
    ELSE.
      vg_sthms = 1.
    ENDIF.

  ELSE.
*** Verifica se houve algum erro nas etapas automaticas
*** Verifica se ainda falta etapas para a nota
    SORT t_flwdoc DESCENDING BY flowd.
    READ TABLE t_flwdoc INTO wa_flwdoc  WITH KEY chave = wl_cabdoc-chave.

    IF sy-subrc IS INITIAL.
      CLEAR vg_flowd.
      SELECT SINGLE MAX( flowd )
        INTO vg_flowd
        FROM zhms_tb_scen_flo
       WHERE natdc EQ wl_cabdoc-natdc
         AND typed EQ wl_cabdoc-typed
         AND scena EQ wl_cabdoc-scena.

*      IF sy-subrc IS INITIAL AND wa_flwdoc-flowd < vg_flowd.
**        vg_sthms = 2.
*      ENDIF.

      IF wa_flwdoc-flowd < vg_flowd OR wa_flwdoc-flwst EQ 'E'.
*** Verifica se há erro
        SELECT SINGLE * FROM zhms_tb_logdoc INTO ls_logdoc WHERE chave EQ wl_cabdoc-chave
                                                             AND flowd EQ wa_flwdoc-flowd
                                                             AND logty EQ 'E'.

        IF sy-subrc IS INITIAL.
          vg_sthms = 4.
          SELECT SINGLE * FROM zhms_tb_logdoc INTO ls_logdoc WHERE chave EQ wl_cabdoc-chave
                                                               AND flowd EQ wa_flwdoc-flowd
                                                               AND logty EQ 'S'.
          IF sy-subrc IS INITIAL.
            vg_sthms = 2.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  CHECK vg_sthms IS INITIAL.

  CLEAR: vg_tabix, vg_erro, vg_lastindex.

*** Verifica se todas etapas foram concluidas
  SORT t_scenflo DESCENDING BY flowd.
  SORT t_flwdoc  DESCENDING BY flowd.
  READ TABLE t_scenflo INTO wa_scenflo INDEX 1.
  READ TABLE t_flwdoc  INTO wa_flwdoc INDEX 1.

  IF wa_scenflo IS NOT INITIAL AND wa_flwdoc IS NOT INITIAL.
    IF wa_flwdoc-flowd EQ wa_scenflo-flowd.
      vg_sthms = 1. "Done
      EXIT.
    ENDIF.
  ENDIF.

** Identifica Status do fluxo
  SORT t_scenflo ASCENDING BY flowd.
  LOOP AT t_scenflo INTO wa_scenflo.
    CHECK vg_erro IS INITIAL.
    vg_lastindex = sy-tabix.

**    Identifica qual o status no fluxo para a etapa
    CLEAR wa_flwdoc.
    READ TABLE t_flwdoc INTO wa_flwdoc WITH KEY flowd = wa_scenflo-flowd.
    IF sy-subrc IS INITIAL
      AND ( wa_flwdoc-flwst = 'A'
            OR wa_flwdoc-flwst = 'M' ). "Identifica como concluido
      vg_tabix = sy-tabix.
    ELSE.
      CLEAR wa_flwdoc. " Caso esse não tenha sido concluido seleciona o anterior
      vg_erro = 'X'.
      IF NOT vg_tabix IS INITIAL.
        READ TABLE t_flwdoc INTO wa_flwdoc INDEX vg_tabix.
      ENDIF.
    ENDIF.
  ENDLOOP.

** identifica se foi encontrado registro de parada
  IF NOT vg_erro IS INITIAL  " Encontrado erro
    AND vg_tabix IS INITIAL. " Não encontrado registro

**    Procura etapa inicial
    CLEAR wa_scenflo.
    READ TABLE t_scenflo INTO wa_scenflo INDEX 1.

**    Caso a etapa seja Manual
    IF wa_scenflo-metpr EQ 'M'.
      vg_sthms = 2. "Waiting

    ENDIF.
**    Caso a etapa seja Automatica
    IF wa_scenflo-metpr EQ 'A'.
      vg_sthms = 4. "Error
    ENDIF.

  ENDIF.
  CHECK vg_sthms IS INITIAL.

  CLEAR vg_sthms.
* Caso não tenha encontrado etapa parada ou por fazer o processo estará completo
  IF vg_erro IS INITIAL.
    vg_sthms = 2. "Done
  ENDIF.
  CHECK vg_sthms IS INITIAL.

*  Caso tenha parado identifica se houve erro
  CLEAR wa_flwdoc2.
  READ TABLE t_flwdoc INTO wa_flwdoc2 INDEX vg_lastindex.
  IF wa_flwdoc2-flwst EQ 'E'.
    vg_sthms = 4. "Error
  ENDIF.
  CHECK vg_sthms IS INITIAL.

*  Caso tenha parado identifica onde parou se é manual
  CLEAR wa_scenflo.
  READ TABLE t_scenflo INTO wa_scenflo INDEX vg_lastindex.
  IF wa_scenflo-metpr EQ 'M'
    AND vg_vldty NE 'E'.
    vg_sthms = 2. "Waiting

  ENDIF.
  IF wa_scenflo-metpr EQ 'M'
    AND vg_vldty EQ 'E'.
*    vg_sthms = 3. "Warning
    vg_sthms = 4. "Error
  ENDIF.
  CHECK vg_sthms IS INITIAL.

*  Caso tenha parado em processamento e a validacao deu erro
  CLEAR wa_scenflo.
  READ TABLE t_scenflo INTO wa_scenflo INDEX vg_lastindex.
  IF wa_scenflo-tpprm EQ 9
    AND vg_vldty EQ 'E'.
    vg_sthms = 4. "Error
  ENDIF.
  CHECK vg_sthms IS INITIAL.

*  DATA:  wa_hrvalid TYPE zhms_tb_hrvalid,
*         vg_flowd   TYPE zhms_de_flowd,
*         ls_logdoc  TYPE zhms_tb_logdoc.
*
***    Limpar as variáveis
*  CLEAR: wa_flwdoc, wa_scenflo, wa_flwdoc.
*  REFRESH: it_flwdoc, t_scenflo, t_flwdoc.
*
***    Selecionar fluxo para este tipo de documento
*  SELECT *
*    INTO TABLE t_scenflo
*    FROM zhms_tb_scen_flo
*   WHERE natdc EQ wl_cabdoc-natdc
*     AND typed EQ wl_cabdoc-typed
*     AND loctp EQ wl_cabdoc-loctp
*     AND scena EQ wl_cabdoc-scena.
*
***     Seleciona etapas do documento.
*  IF NOT t_scenflo[] IS INITIAL.
*
*    SELECT *
*      INTO TABLE t_flwdoc
*      FROM zhms_tb_flwdoc
*      FOR ALL ENTRIES IN t_scenflo
*    WHERE natdc EQ wl_cabdoc-natdc
*      AND typed EQ wl_cabdoc-typed
*      AND loctp EQ wl_cabdoc-loctp
*      AND chave EQ wl_cabdoc-chave
*      AND flowd EQ t_scenflo-flowd.
*
*  ENDIF.
*
*** executa validação
*  CLEAR vg_vldcd.
*
*  SELECT SINGLE vldcd
*    INTO vg_vldcd
*    FROM zhms_tb_scenario
*   WHERE natdc EQ wl_cabdoc-natdc
*     AND typed EQ wl_cabdoc-typed
*     AND loctp EQ wl_cabdoc-loctp
*     AND scena EQ wl_cabdoc-scena.
*
***    Executa funções de validação
*  IF NOT vg_vldcd IS INITIAL.
*    CLEAR vg_vldty.
*    CALL FUNCTION 'ZHMS_FM_VALIDAR'
*      EXPORTING
*        vldcd   = vg_vldcd
*        cabdoc  = wl_cabdoc
*        reghist = ' '
*      IMPORTING
*        vldty   = vg_vldty.
*  ENDIF.
*
**** Verifica se houve erro na Validação
*  CLEAR: vg_sthms, wa_hrvalid.
*  SELECT SINGLE * FROM zhms_tb_hrvalid INTO wa_hrvalid WHERE chave EQ wl_cabdoc-chave
*                                                         AND ativo EQ 'X'.
*
*  IF sy-subrc IS INITIAL.
*    CASE wa_hrvalid-vldty.
*      WHEN 'E'.
*        vg_sthms = 4.
*    ENDCASE.
*
*  ELSE.
**** Verifica se houve algum erro nas etapas automaticas
**** Verifica se ainda falta etapas para a nota
*    SORT t_flwdoc DESCENDING BY flowd.
*    READ TABLE t_flwdoc INTO wa_flwdoc  WITH KEY chave = wl_cabdoc-chave.
*
*    IF sy-subrc IS INITIAL.
*      CLEAR vg_flowd.
*      SELECT SINGLE MAX( flowd )
*        INTO vg_flowd
*        FROM zhms_tb_scen_flo
*       WHERE natdc EQ wl_cabdoc-natdc
*         AND typed EQ wl_cabdoc-typed
*         AND scena EQ wl_cabdoc-scena.
*
**      IF sy-subrc IS INITIAL AND wa_flwdoc-flowd < vg_flowd.
***        vg_sthms = 2.
**      ENDIF.
*
*      IF wa_flwdoc-flowd < vg_flowd.
**** Verifica se há erro
*        SELECT SINGLE * FROM zhms_tb_logdoc INTO ls_logdoc WHERE chave EQ wl_cabdoc-chave
*                                                             AND flowd EQ wa_flwdoc-flowd
*                                                             AND logty EQ 'E'.
*
*        IF sy-subrc IS INITIAL.
*          vg_sthms = 4.
*          SELECT SINGLE * FROM zhms_tb_logdoc INTO ls_logdoc WHERE chave EQ wl_cabdoc-chave
*                                                               AND flowd EQ wa_flwdoc-flowd
*                                                               AND logty EQ 'S'.
*          IF sy-subrc IS INITIAL.
*            vg_sthms = 2.
*          ENDIF.
*        ENDIF.
*
*      ELSEIF wa_flwdoc-flowd EQ vg_flowd."  AND wa_flwdoc-flwst IS INITIAL.
**** verifica se há erro
*        REFRESH lt_logdoc[].
*        SELECT * FROM zhms_tb_logdoc INTO TABLE lt_logdoc WHERE chave EQ wl_cabdoc-chave
*                                                             AND flowd EQ wa_flwdoc-flowd.
**                                                             AND logty EQ 'E'.
*        IF sy-subrc IS INITIAL.
*          SORT lt_logdoc DESCENDING BY dtreg.
*
*          READ TABLE lt_logdoc INTO ls_logdoc INDEX 1.
*
*          IF sy-subrc IS INITIAL.
*            DELETE lt_logdoc WHERE dtreg NE ls_logdoc-dtreg.
*            SORT lt_logdoc DESCENDING BY hrreg.
*          ENDIF.
*
*          READ TABLE lt_logdoc INTO ls_logdoc WITH KEY logty = 'E'.
*
*          IF sy-subrc IS INITIAL.
*            vg_sthms = 4.
*          ELSE.
**            SELECT SINGLE * FROM zhms_tb_logdoc INTO ls_logdoc WHERE chave EQ wl_cabdoc-chave
**                                         AND flowd EQ wa_flwdoc-flowd
**                                         AND logty EQ 'S'.
**            IF sy-subrc IS INITIAL.
*              vg_sthms = 2.
**            ENDIF.
*          ENDIF.
*        ELSE.
*          SELECT SINGLE * FROM zhms_tb_logdoc INTO ls_logdoc WHERE chave EQ wl_cabdoc-chave
*                                                     AND flowd EQ wa_flwdoc-flowd
*                                                     AND logty EQ 'S'.
*          IF sy-subrc IS INITIAL.
*            vg_sthms = 2.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*  ENDIF.
*
*  CHECK vg_sthms IS INITIAL.
*
*  CLEAR: vg_tabix, vg_erro, vg_lastindex.
*
**** Verifica se todas etapas foram concluidas
*  SORT t_scenflo DESCENDING BY flowd.
*  SORT t_flwdoc  DESCENDING BY flowd.
*  READ TABLE t_scenflo INTO wa_scenflo INDEX 1.
*  READ TABLE t_flwdoc  INTO wa_flwdoc INDEX 1.
*
*  IF wa_scenflo IS NOT INITIAL AND wa_flwdoc IS NOT INITIAL.
*    IF wa_flwdoc-flowd EQ wa_scenflo-flowd.
*      vg_sthms = 1. "Done
*      EXIT.
*    ENDIF.
*  ENDIF.
*
*** Identifica Status do fluxo
*  SORT t_scenflo ASCENDING BY flowd.
*  LOOP AT t_scenflo INTO wa_scenflo.
*    CHECK vg_erro IS INITIAL.
*    vg_lastindex = sy-tabix.
*
***    Identifica qual o status no fluxo para a etapa
*    CLEAR wa_flwdoc.
*    READ TABLE t_flwdoc INTO wa_flwdoc WITH KEY flowd = wa_scenflo-flowd.
*    IF sy-subrc IS INITIAL
*      AND ( wa_flwdoc-flwst = 'A'
*            OR wa_flwdoc-flwst = 'M' ). "Identifica como concluido
*      vg_tabix = sy-tabix.
*    ELSE.
*      CLEAR wa_flwdoc. " Caso esse não tenha sido concluido seleciona o anterior
*      vg_erro = 'X'.
*      IF NOT vg_tabix IS INITIAL.
*        READ TABLE t_flwdoc INTO wa_flwdoc INDEX vg_tabix.
*      ENDIF.
*    ENDIF.
*  ENDLOOP.
*
*** identifica se foi encontrado registro de parada
*  IF NOT vg_erro IS INITIAL  " Encontrado erro
*    AND vg_tabix IS INITIAL. " Não encontrado registro
*
***    Procura etapa inicial
*    CLEAR wa_scenflo.
*    READ TABLE t_scenflo INTO wa_scenflo INDEX 1.
*
***    Caso a etapa seja Manual
*    IF wa_scenflo-metpr EQ 'M'.
*      vg_sthms = 2. "Waiting
*
*    ENDIF.
***    Caso a etapa seja Automatica
*    IF wa_scenflo-metpr EQ 'A'.
*      vg_sthms = 4. "Error
*    ENDIF.
*
*  ENDIF.
*  CHECK vg_sthms IS INITIAL.
*
*  CLEAR vg_sthms.
** Caso não tenha encontrado etapa parada ou por fazer o processo estará completo
*  IF vg_erro IS INITIAL.
*    vg_sthms = 2. "Done
*  ENDIF.
*  CHECK vg_sthms IS INITIAL.
*
**  Caso tenha parado identifica se houve erro
*  CLEAR wa_flwdoc2.
*  READ TABLE t_flwdoc INTO wa_flwdoc2 INDEX vg_lastindex.
*  IF wa_flwdoc2-flwst EQ 'E'.
*    vg_sthms = 4. "Error
*  ENDIF.
*  CHECK vg_sthms IS INITIAL.
*
**  Caso tenha parado identifica onde parou se é manual
*  CLEAR wa_scenflo.
*  READ TABLE t_scenflo INTO wa_scenflo INDEX vg_lastindex.
*  IF wa_scenflo-metpr EQ 'M'
*    AND vg_vldty NE 'E'.
*    vg_sthms = 2. "Waiting
*
*  ENDIF.
*  IF wa_scenflo-metpr EQ 'M'
*    AND vg_vldty EQ 'E'.
**    vg_sthms = 3. "Warning
*    vg_sthms = 4. "Error
*  ENDIF.
*  CHECK vg_sthms IS INITIAL.
*
**  Caso tenha parado em processamento e a validacao deu erro
*  CLEAR wa_scenflo.
*  READ TABLE t_scenflo INTO wa_scenflo INDEX vg_lastindex.
*  IF wa_scenflo-tpprm EQ 9
*    AND vg_vldty EQ 'E'.
*    vg_sthms = 4. "Error
*  ENDIF.
*  CHECK vg_sthms IS INITIAL.
ENDFORM.                    " F_TRATA_ST
*&---------------------------------------------------------------------*
*&      Form  F_SEL_CHAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_sel_chave .
  MOVE vg_chave TO vg_valor.
ENDFORM.                    " F_SEL_CHAVE
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data .
  CONCATENATE sy-datum(4) '-' sy-datum+4(2) '-' sy-datum+6(2) INTO vg_valor.
*  WRITE sy-datum USING EDIT MASK '__-__-____' TO vg_valor.
ENDFORM.                    " F_GET_DATA
*&---------------------------------------------------------------------*
*&      Form  F_GET_HORA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_hora .
  WRITE sy-uzeit USING EDIT MASK '__:__:__' TO vg_valor.
ENDFORM.                    " F_GET_HORA
