*----------------------------------------------------------------------*
*                      H  o  m  S  o  f  t                             *
*          Gestão Eletrônica de Documentos e Processos                 *
*----------------------------------------------------------------------*
* Descrição: Monitor Central de Gerenciamento de Documentos            *
*            Sub-Rotinas (Conferência)                                 *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_LOADPORTARIAS
*&---------------------------------------------------------------------*
*       Busca os dados das portarias ja efetuadas
*----------------------------------------------------------------------*
FORM f_loadportarias .

**    Limpar Estruturas
  REFRESH: t_docrcbto, t_docrcbto_ax, t_datrcbto.
  CLEAR: wa_docrcbto, wa_docrcbto_ax, wa_datrcbto.

**    Seleção na tabela de portaria para o documento.
  SELECT *
    INTO TABLE t_docrcbto
    FROM zhms_tb_docrcbto
   WHERE natdc EQ wa_cabdoc-natdc
     AND typed EQ wa_cabdoc-typed
*     AND loctp EQ wa_cabdoc-loctp
     AND chave EQ wa_cabdoc-chave.

**   Percorre dados encontrados alimentando a tabela de saída
  LOOP AT t_docrcbto INTO wa_docrcbto.
**      Mover correspondentes
    MOVE-CORRESPONDING wa_docrcbto TO wa_docrcbto_ax.

**      Tratamento para ícone
    CASE wa_docrcbto-logty.
      WHEN 'E'.
        wa_docrcbto_ax-icon = '@0A@'.
      WHEN 'W'.
        wa_docrcbto_ax-icon = '@09@'.
      WHEN 'I'.
        wa_docrcbto_ax-icon = '@08@'.
      WHEN 'S'.
        wa_docrcbto_ax-icon = '@01@'.
    ENDCASE.

**      Insere na estrutura de exibição
    APPEND wa_docrcbto_ax TO t_docrcbto_ax.
  ENDLOOP.

**    Ordena para que o mais recente seja exibido primeiro
  SORT t_docrcbto_ax BY dtreg DESCENDING
                        hrreg DESCENDING.

**    Seleciona para exibição a última portaria caso nenhuma esteja selecionada
  CLEAR wa_docrcbto_ax.
  READ TABLE t_docrcbto_ax INTO wa_docrcbto_ax WITH KEY check = 'X'.

  IF NOT sy-subrc IS INITIAL.
    READ TABLE t_docrcbto_ax INTO wa_docrcbto_ax INDEX 1.
  ENDIF.

  IF sy-subrc IS INITIAL.
**  Seleciona os dados da portaria marcada
    CLEAR wa_docrcbto.
    READ TABLE t_docrcbto INTO wa_docrcbto WITH KEY seqnr = wa_docrcbto_ax-seqnr.

**  Buscar dados de portaria
    SELECT *
      INTO TABLE t_datrcbto
      FROM zhms_tb_datrcbto
     WHERE natdc EQ wa_docrcbto_ax-natdc
       AND typed EQ wa_docrcbto_ax-typed
       AND loctp EQ wa_docrcbto_ax-loctp
       AND chave EQ wa_docrcbto_ax-chave
       AND seqnr EQ wa_docrcbto_ax-seqnr.

  ENDIF.

ENDFORM.                    " F_LOADPORTARIAS
*&---------------------------------------------------------------------*
*&      Form  f_cancelaportaria
*&---------------------------------------------------------------------*
*       Tratamento para solicitação de cancelamento de portaria
*----------------------------------------------------------------------*
FORM f_cancelaportaria.

  DATA: vl_answer TYPE c,
        wl_logdoc TYPE zhms_tb_logdoc,
        tl_logdoc TYPE TABLE OF zhms_tb_logdoc.

  CLEAR vl_answer.

**    Confirmação de resposta
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = text-q01
      text_question         = text-q02
      text_button_1         = text-q03
      icon_button_1         = 'ICON_CHECKED'
      text_button_2         = text-q04
      icon_button_2         = 'ICON_INCOMPLETE'
      default_button        = '2'
      display_cancel_button = ' '
    IMPORTING
      answer                = vl_answer
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.

**    Somente continuar processamento caso resposta SIM
  CHECK vl_answer EQ 1.

  UPDATE zhms_tb_docrcbto
     SET ativo = ''
         uscan = sy-uname
         dtcan = sy-datum
         hrcan = sy-uzeit
         logty = 'E'
   WHERE natdc EQ wa_docrcbto-natdc
     AND typed EQ wa_docrcbto-typed
     AND chave EQ wa_docrcbto-chave
     AND seqnr EQ wa_docrcbto-seqnr.

  COMMIT WORK AND WAIT .

** Registra LOG
  REFRESH tl_logdoc.
  wl_logdoc-logty = 'S'.
  wl_logdoc-logno = '201'.
  APPEND wl_logdoc TO tl_logdoc.

  CALL FUNCTION 'ZHMS_FM_REGLOG'
    EXPORTING
      cabdoc = wa_cabdoc
      flwst  = 'W'
      tpprm  = 1 "Portaria
    TABLES
      logdoc = tl_logdoc.

  IF sy-subrc IS INITIAL.
    MESSAGE i020.
  ENDIF.

ENDFORM.                    "f_cancelaportaria


*&---------------------------------------------------------------------*
*&      Form  f_cancelaconferencia
*&---------------------------------------------------------------------*
*       Cancela conferencia
*----------------------------------------------------------------------*
FORM f_cancelaconferencia.
  DATA: vl_answer TYPE c.
  DATA: wl_logdoc TYPE zhms_tb_logdoc,
        tl_logdoc TYPE TABLE OF zhms_tb_logdoc.
  CLEAR vl_answer.

**    Confirmação de resposta
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = text-q01
      text_question         = text-q08
      text_button_1         = text-q03
      icon_button_1         = 'ICON_CHECKED'
      text_button_2         = text-q04
      icon_button_2         = 'ICON_INCOMPLETE'
      default_button        = '2'
      display_cancel_button = ' '
    IMPORTING
      answer                = vl_answer
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.

**    Somente continuar processamento caso resposta SIM
  CHECK vl_answer EQ 1.

  UPDATE zhms_tb_docconf
     SET ativo = ''
         uscan = sy-uname
         dtcan = sy-datum
         hrcan = sy-uzeit
         logty = 'E'
   WHERE natdc EQ wa_docconf-natdc
     AND typed EQ wa_docconf-typed
     AND chave EQ wa_docconf-chave
     AND seqnr EQ wa_docconf-seqnr.

  COMMIT WORK AND WAIT .

** Registra log
  REFRESH tl_logdoc.
  wl_logdoc-logty = 'S'.
  wl_logdoc-logno = '251'.
  APPEND wl_logdoc TO tl_logdoc.

  CALL FUNCTION 'ZHMS_FM_REGLOG'
    EXPORTING
      cabdoc = wa_cabdoc
      flwst  = 'W'
      tpprm  = 2
    TABLES
      logdoc = tl_logdoc.

  IF sy-subrc IS INITIAL.
    MESSAGE i021.
  ENDIF.


ENDFORM.                    "f_cancelaconferencia

*&---------------------------------------------------------------------*
*&      Form  F_RCB_BUSCACHAVE
*&---------------------------------------------------------------------*
*       Busca o documento da base HomSoft
*----------------------------------------------------------------------*
FORM f_rcb_buscachave .

**    Verifica se já existe portaria para o documento
  CLEAR wa_docrcbto.
  REFRESH t_datrcbto.

  SELECT SINGLE *
    INTO wa_docrcbto
    FROM zhms_tb_docrcbto
   WHERE chave EQ wa_cabdoc-chave
     AND ativo EQ 'X'.

**    Portaria encontrada
  IF sy-subrc IS INITIAL.
**        Buscar dados de portaria
    SELECT *
      INTO TABLE t_datrcbto
      FROM zhms_tb_datrcbto
     WHERE chave EQ wa_cabdoc-chave.

  ENDIF.

ENDFORM.                    " F_RCB_BUSCACHAVE

*----------------------------------------------------------------------*
*   Form  f_show_document_rcp
*----------------------------------------------------------------------*
*   Atualizar os status dos documentos
*----------------------------------------------------------------------*
FORM f_show_document_rcp.
  DATA: vl_name1   TYPE lfa1-name1,
        vl_dayw    TYPE scal-indicator,
        vl_langt   TYPE t246-langt,
        vl_ltx     TYPE t247-ltx,
        vl_mnr     TYPE t247-mnr,
        vl_sep(4)  TYPE c,
        vl_qtdmn   TYPE i,
        vl_data    TYPE string,
        vl_hora    TYPE string,
        vl_butxt   TYPE t001-butxt,
        vl_name    TYPE j_1bbranch-name.

  REFRESH: t_datasrc, t_gatemneu, t_gatemneux, t_gateobs.
  CLEAR: wa_gate, wa_gatemneu, wa_gatemneux, wa_gateobs.

  APPEND '  document.getElementById("dc_document").className = "hide";' TO t_datasrc.
  APPEND '  document.getElementById("dc_resumo").className = "show";' TO t_datasrc.
  APPEND 'recp_status_res.innerHTML=''&nbsp;'';' TO t_datasrc.

  IF wa_docrcbto-ativo EQ 'X'.
    IF wa_docrcbto-logty IS INITIAL.
      APPEND 'recp_status_res.innerHTML=''&nbsp;'';' TO t_datasrc.
    ELSEIF wa_docrcbto-logty EQ 'S'.
      APPEND 'recp_status_res.innerHTML=''<img id="dc_recp" src="port_ok.gif" />'';' TO t_datasrc.
    ELSEIF wa_docrcbto-logty EQ 'W'.
      APPEND 'recp_status_res.innerHTML=''<img id="dc_recp" src="port_cont.gif" />'';' TO t_datasrc.
    ENDIF.
  ELSEIF NOT wa_docrcbto IS INITIAL.
    APPEND 'recp_status_res.innerHTML=''<img id="dc_recp" src="port_canc.gif" />'';' TO t_datasrc.
  ENDIF.


  CLEAR v_gate.
*      TODO:SELECIONAR ZHMS_TB_SCENARIO BUSCANDO GATE.

  IF v_gate IS INITIAL.

    SELECT SINGLE *
      INTO wa_gate
      FROM zhms_tb_gate
     WHERE defau EQ 'X'.

    IF NOT sy-subrc IS INITIAL.
***       Erro Interno. Contatar Suporte.
      MESSAGE e000 WITH text-000.
    ELSE.
      v_gate = wa_gate-gate.
      IF NOT wa_gate IS INITIAL.
**          Seleção dos dados a serem recuperados
        SELECT *
          INTO TABLE t_gatemneu
          FROM zhms_tb_gatemneu
         WHERE gate EQ wa_gate-gate.

**          Seleção dos textos dos dados para a língua de logon
        SELECT *
          INTO TABLE t_gatemneux
          FROM zhms_tx_gatemneu
         WHERE gate  EQ wa_gate-gate
           AND spras EQ sy-langu.

**           Seleção das observações para a lingua de logon
        SELECT *
          INTO TABLE t_gateobs
          FROM zhms_tb_gateobs
         WHERE gate EQ wa_gate-gate
           AND spras EQ sy-langu.


      ENDIF.
    ENDIF.

  ENDIF.
**    Limpa exibição da tela
  APPEND 'limpa_mneums();' TO t_datasrc.
  CLEAR vl_qtdmn.

**    Insere os Mneumonicos
  LOOP AT t_gatemneu INTO wa_gatemneu.
    READ TABLE t_gatemneux INTO wa_gatemneux WITH KEY seqnr = wa_gatemneu-seqnr.

    CLEAR: wa_datasrc.
    CONCATENATE 'insere_mneum("' wa_gatemneux-denom '", "' wa_gatemneu-mneum '", "' wa_gatemneu-obrig '" , "' wa_gatemneu-seqnr '");' INTO wa_datasrc.
    APPEND wa_datasrc TO t_datasrc.
    ADD 1 TO vl_qtdmn.
  ENDLOOP.


**    Insere Observacoes
  SORT t_gateobs BY seqnr ASCENDING.
  CLEAR v_observ.

  LOOP AT t_gateobs INTO wa_gateobs.
    CONCATENATE v_observ '&nbsp;' wa_gateobs-obser INTO v_observ.
  ENDLOOP.
  IF NOT v_observ IS INITIAL.
    v_observ = v_observ+6.
  ENDIF.

  IF v_observ IS NOT INITIAL.
    CLEAR: wa_datasrc.
    CONCATENATE 'insere_obs("' v_observ '");' INTO wa_datasrc.
    APPEND wa_datasrc TO t_datasrc.
  ENDIF.

**    Exibe itens default
  APPEND ' exibe_default();' TO t_datasrc.
  APPEND '  document.getElementById("mneumonicos").className = "show";' TO t_datasrc.

**     Insere valores nos mneumonicos caso portaria existente
  LOOP AT t_datrcbto INTO wa_datrcbto.

**       Identifica Mneumônico na lista
    CLEAR wa_gatemneu.
    READ TABLE t_gatemneu INTO wa_gatemneu WITH KEY mneum = wa_datrcbto-mneum.

**       Insere valor
    CLEAR: wa_datasrc.
    CONCATENATE '  document.getElementById("mneumonico' wa_gatemneu-seqnr '").value = "' wa_datrcbto-value '";' INTO wa_datasrc.
    APPEND wa_datasrc TO t_datasrc.

  ENDLOOP.

**    Bloqueia os mneumonicos para edição
  LOOP AT t_gatemneu INTO wa_gatemneu.
    CLEAR: wa_datasrc.
    CONCATENATE '  document.getElementById("mneumonico' wa_gatemneu-seqnr '").disabled="disabled";' INTO wa_datasrc.
    APPEND wa_datasrc TO t_datasrc.

    CLEAR: wa_datasrc.
    CONCATENATE '  document.getElementById("mneumonico' wa_gatemneu-seqnr '").className="disabled";' INTO wa_datasrc.
    APPEND wa_datasrc TO t_datasrc.

  ENDLOOP.

**    Rotinas de botões
  APPEND ' stop_timer();' TO t_datasrc.
  APPEND ' document.getElementById("cancela").className = "hide";' TO t_datasrc.
  APPEND ' document.getElementById("confirma").className = "hide";' TO t_datasrc.
  APPEND ' document.getElementById("recebida_res").className = "recebida";' TO t_datasrc.

  IF NOT wa_docrcbto IS INITIAL.

    CONCATENATE wa_docrcbto-dtreg+6(2) '/' wa_docrcbto-dtreg+4(2) '/' wa_docrcbto-dtreg(4) INTO vl_data.
    CONCATENATE wa_docrcbto-hrreg(2) ':' wa_docrcbto-dtreg+2(2) INTO vl_hora.

    CLEAR: wa_datasrc.
    wa_datasrc = ' document.getElementById("recebida_res").innerHTML = "'.

    CONCATENATE wa_datasrc 'Recebida em ' vl_data  INTO wa_datasrc SEPARATED BY space.
    CONCATENATE wa_datasrc 'às' vl_hora INTO wa_datasrc SEPARATED BY space.
    CONCATENATE wa_datasrc 'por' wa_docrcbto-uname '";' INTO wa_datasrc SEPARATED BY space.

    APPEND wa_datasrc TO t_datasrc.

  ELSE.
    APPEND ' document.getElementById("recebida_res").innerHTML = "<div align=''right''>Documento ainda não recebido!</div>";' TO t_datasrc.

**    Limpa exibição da tela
    APPEND ' limpa_nota();' TO t_datasrc.
    APPEND ' limpa_mneums();' TO t_datasrc.

  ENDIF.

***   Caso exista algum comando a ser executado na página
  IF NOT t_datasrc[] IS INITIAL
    AND ob_html_rcp IS NOT INITIAL.
***       Chamada de empresa
    CALL METHOD ob_html_rcp->run_script_on_demand
      EXPORTING
        script = t_datasrc
      EXCEPTIONS
        OTHERS = 1.

  ENDIF.
ENDFORM.                    "f_show_document_rcp
*&---------------------------------------------------------------------*
*&      Form  F_SHOWPORTARIA
*&---------------------------------------------------------------------*
*       seleciona para exibição a portaria selecionada
*----------------------------------------------------------------------*
FORM f_showportaria .
**    Seleciona para exibição a portaria selecionada
  CLEAR wa_docrcbto_ax.
  READ TABLE t_docrcbto_ax INTO wa_docrcbto_ax WITH KEY check = 'X'.
  IF sy-subrc IS INITIAL.

**      Limpa dados
    REFRESH t_datrcbto.

**      Seleciona os dados da portaria marcada
    CLEAR wa_docrcbto.
    READ TABLE t_docrcbto INTO wa_docrcbto WITH KEY seqnr = wa_docrcbto_ax-seqnr.

**      Buscar dados de portaria
    SELECT *
      INTO TABLE t_datrcbto
      FROM zhms_tb_datrcbto
     WHERE natdc EQ wa_docrcbto_ax-natdc
       AND typed EQ wa_docrcbto_ax-typed
       AND loctp EQ wa_docrcbto_ax-loctp
       AND chave EQ wa_docrcbto_ax-chave
       AND seqnr EQ wa_docrcbto_ax-seqnr.

  ENDIF.
ENDFORM.                    " F_SHOWPORTARIA

*&---------------------------------------------------------------------*
*&      Form  F_SHOWCONFERENCIA
*&---------------------------------------------------------------------*
*       seleciona para exibição da conferencia selecionada
*----------------------------------------------------------------------*
FORM f_showconferencia .
**    Seleciona para exibição a portaria selecionada
  CLEAR wa_docconf_ax.
  READ TABLE t_docconf_ax INTO wa_docconf_ax WITH KEY check = 'X'.
  IF sy-subrc IS INITIAL.

**      Limpa dados
    REFRESH t_datconf.

**      Seleciona os dados da portaria marcada
    CLEAR wa_docconf.
    READ TABLE t_docconf INTO wa_docconf WITH KEY seqnr = wa_docconf_ax-seqnr.

**      Buscar dados de portaria
    SELECT *
      INTO TABLE t_datconf
      FROM zhms_tb_datconf
     WHERE natdc EQ wa_docconf_ax-natdc
       AND typed EQ wa_docconf_ax-typed
       AND loctp EQ wa_docconf_ax-loctp
       AND chave EQ wa_docconf_ax-chave
       AND seqnr EQ wa_docconf_ax-seqnr.

  ENDIF.
ENDFORM.                    " F_SHOWCONFERENCIA


*&---------------------------------------------------------------------*
*&      Form  F_LOAD_LIST_CONF
*&---------------------------------------------------------------------*
*       Busca os dados das conferencias ja efetuadas
*----------------------------------------------------------------------*
FORM f_load_list_conf .

**    Limpar Estruturas
  REFRESH: t_docconf, t_docconf_ax, t_datconf.
  CLEAR: wa_docconf, wa_docconf_ax, wa_datconf.

**    Seleção na tabela de portaria por usuário / Dia.
  SELECT *
    INTO TABLE t_docconf
    FROM zhms_tb_docconf
   WHERE natdc EQ wa_cabdoc-natdc
     AND typed EQ wa_cabdoc-typed
*         AND loctp EQ wa_cabdoc-loctp
     AND chave EQ wa_cabdoc-chave.

**   Percorre dados encontrados alimentando a tabela de saída
  LOOP AT t_docconf INTO wa_docconf.
**      Mover correspondentes
    MOVE-CORRESPONDING wa_docconf TO wa_docconf_ax.

**      Tratamento para ícone
    CASE wa_docconf-logty.
      WHEN 'E'.
        wa_docconf_ax-icon = '@0A@'.
      WHEN 'W'.
        wa_docconf_ax-icon = '@09@'.
      WHEN 'I'.
        wa_docconf_ax-icon = '@08@'.
      WHEN 'S'.
        wa_docconf_ax-icon = '@01@'.
    ENDCASE.

**      Insere na estrutura de exibição
    APPEND wa_docconf_ax TO t_docconf_ax.
  ENDLOOP.

**    Ordena para que o mais recente seja exibido primeiro
  SORT t_docconf_ax BY dtreg DESCENDING
                       hrreg DESCENDING.

**    Seleciona para exibição a última portaria caso nenhuma esteja selecionada
  CLEAR wa_docconf_ax.
  READ TABLE t_docconf_ax INTO wa_docconf_ax WITH KEY check = 'X'.

  IF NOT sy-subrc IS INITIAL.
    READ TABLE t_docconf_ax INTO wa_docconf_ax INDEX 1.
  ENDIF.

  IF sy-subrc IS INITIAL.
**  Seleciona os dados da portaria marcada
    CLEAR wa_docconf.
    READ TABLE t_docconf INTO wa_docconf WITH KEY seqnr = wa_docconf_ax-seqnr.

**  Buscar dados de portaria
    SELECT *
      INTO TABLE t_datconf
      FROM zhms_tb_datconf
     WHERE natdc EQ wa_docconf_ax-natdc
       AND typed EQ wa_docconf_ax-typed
       AND loctp EQ wa_docconf_ax-loctp
       AND chave EQ wa_docconf_ax-chave
       AND seqnr EQ wa_docconf_ax-seqnr.

  ENDIF.
ENDFORM.                    "f_load_list_conf
