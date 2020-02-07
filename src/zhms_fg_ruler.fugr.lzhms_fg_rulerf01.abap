

*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_RULERF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INICIALIZA_VARIAVEIS
*&---------------------------------------------------------------------*
*       Inicializar Variáveis internas
*----------------------------------------------------------------------*

FORM f_exec_inicializa_variaveis TABLES  t_msgdata
                                         t_msgatrb
                                  USING  p_natdc
                                         p_typed
                                         p_loctp
                                         p_event
                                         p_scena.

* Transferência do dados
  v_natdc = p_natdc.
  v_typed = p_typed.
  v_loctp = p_loctp.
  v_event = p_event.
  v_scena = p_scena.

* Limpar dados internos
  REFRESH it_performs.

* Checks de chave
*   Natureza de Documento
  IF v_natdc IS INITIAL.
    RAISE nature_not_informed.
  ENDIF.

*   Tipo de Documento
  IF v_typed IS INITIAL.
    RAISE document_type_not_informed.
  ENDIF.

*   Evento Documento
  IF v_event IS INITIAL
    AND v_scena IS INITIAL.
    RAISE event_scenery_not_informed.
  ENDIF.

* Estrutura de mensagem
  it_msgdata[] = t_msgdata[].

* Atributos de mensagem
  it_msgatrb[] = t_msgatrb[].

* Iguala as tags (recebidas e cadastradas) em Upper Case (maiúsculas)
  LOOP AT it_msgdata INTO wa_msgdata.
    TRANSLATE wa_msgdata-field TO UPPER CASE.
    CONDENSE wa_msgdata-field.
    MODIFY it_msgdata FROM wa_msgdata INDEX sy-tabix.
  ENDLOOP.

* Limpar código dinamico
  REFRESH it_scode.
ENDFORM.                    " F_INICIALIZA_VARIAVEIS

*&---------------------------------------------------------------------*
*&      Form  F_SELECIONA_EVENTOS
*&---------------------------------------------------------------------*
*       Buscar fluxo do evento
*----------------------------------------------------------------------*
FORM f_seleciona_fluxos .

* Check de chave
  CHECK: NOT v_natdc IS INITIAL,
         NOT v_typed IS INITIAL.

* Limpar variáveis
  REFRESH: it_evflow, it_scflow, it_flow.

  IF NOT v_event IS INITIAL.

* Seleção dos dados
    SELECT *
      INTO TABLE it_evflow
      FROM zhms_tb_ev_flow
     WHERE natdc EQ v_natdc
       AND typed EQ v_typed
       AND loctp EQ v_loctp
       AND event EQ v_event.

*  Transferencia para estrutura de fluxo
    LOOP AT it_evflow INTO wa_evflow.
      MOVE-CORRESPONDING wa_evflow TO wa_flow.
      APPEND wa_flow TO it_flow.
    ENDLOOP.

  ELSEIF NOT v_scena IS INITIAL.

* Seleção dos dados
    SELECT *
      INTO TABLE it_scflow
      FROM zhms_tb_scen_flo
     WHERE natdc EQ v_natdc
       AND typed EQ v_typed
       AND loctp EQ v_loctp
       AND scena EQ v_scena.

*  Transferencia para estrutura de fluxo
    LOOP AT it_scflow INTO wa_scflow.
      MOVE-CORRESPONDING wa_scflow TO wa_flow.
      APPEND wa_flow TO it_flow.
    ENDLOOP.

  ENDIF.
ENDFORM.                    " F_SELECIONA_EVENTOS
*&---------------------------------------------------------------------*
*&      Form  F_EXECUTA_FLUXOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_EXECUTA_FLUXOS .

* Variáveis locais.
  DATA: VL_STOP       TYPE FLAG,
        VL_START      TYPE FLAG,
        VL_VLDTY      TYPE ZHMS_DE_VLDTY,
        VL_VLDTY_MAIN TYPE ZHMS_DE_VLDTY,
        LS_ATRIB      TYPE ZHMS_TB_ITMATR,
        LV_USER       TYPE USER,
        VL_ATRI_AT    TYPE C.

* Limpar variáveis
  REFRESH: IT_FLWDOC, IT_SCEN_FLO[].

  IF ( V_TYPED EQ 'NFSE1' AND SY-TCODE EQ 'ZHMS_MONITOR' ) OR V_TYPED EQ 'NFET'.
**
**    CALL FUNCTION 'ZHMS_FM_OBTER_VALOR'
**      EXPORTING
**        p_campo  = space
**      IMPORTING
**        p_output = v_chave.
*
*    IMPORT v_chave  FROM MEMORY ID 'CHAVE_NFSE'.

    FIELD-SYMBOLS: <TB_CHAVE> TYPE ANY TABLE,
                   <FS_CHAVE> TYPE ANY.

    DATA: T_DOCTO  TYPE TABLE OF ZHMS_ES_DOCUM,
          WA_DOCTO TYPE ZHMS_ES_DOCUM.


    ASSIGN ('(SAPLZHMS_FG_RULER)IT_DOCUM[]') TO <TB_CHAVE>.
    IF SY-SUBRC EQ 0.

      LOOP AT <TB_CHAVE> ASSIGNING <FS_CHAVE>.

        MOVE-CORRESPONDING <FS_CHAVE> TO WA_DOCTO.

        V_CHAVE = WA_DOCTO-CHAVE.
        EXIT.

      ENDLOOP.

    ENDIF.

  ENDIF.
* Seleciona lista de etapas do documento
  SELECT *
    INTO TABLE IT_FLWDOC
    FROM ZHMS_TB_FLWDOC
    WHERE NATDC EQ V_NATDC
      AND TYPED EQ V_TYPED
      AND LOCTP EQ V_LOCTP
      AND CHAVE EQ V_CHAVE.

*** Seleciona etapas
  SELECT *
    FROM ZHMS_TB_SCEN_FLO
    INTO TABLE IT_SCEN_FLO
   WHERE NATDC EQ V_NATDC
     AND TYPED EQ V_TYPED.

*limpar variável
  CLEAR VL_STOP.

* Realiza Validação geral do documento.
  IF NOT WA_SCENARIO-VLDCD IS INITIAL.
    CALL FUNCTION 'ZHMS_FM_VALIDAR'
      EXPORTING
        VLDCD  = WA_SCENARIO-VLDCD
        CABDOC = WA_CABDOC
      IMPORTING
        VLDTY  = VL_VLDTY_MAIN.
  ENDIF.

  READ TABLE IT_SCENARIO INTO WA_SCENARIO WITH KEY SCENA = V_SCENA.

  SELECT SINGLE * FROM ZHMS_TB_ITMATR INTO LS_ATRIB WHERE CHAVE EQ
V_CHAVE.

  IF NOT SY-SUBRC IS INITIAL AND WA_SCENARIO-SCENA NE '3'.
    READ TABLE IT_FLOW INTO WA_FLOW INDEX 1.
    CALL FUNCTION 'ZHMS_FM_VALIDAR'
      EXPORTING
        VLDCD   = WA_FLOW-VLDCD
        CABDOC  = WA_CABDOC
        REGHIST = ' '
      IMPORTING
        VLDTY   = VL_VLDTY.
    CLEAR WA_FLOW.

    IF VL_VLDTY EQ 'E'.

    ENDIF.

    EXIT.
  ENDIF.

* Execução dos eventos cadastrados
  LOOP AT IT_FLOW INTO WA_FLOW.
*    Verifica comando de parada de processamento
    CHECK VL_STOP IS INITIAL.
    VL_START = 'X'.

*** Valida se usuario tem acesso a MIGO e a MIRO
    IF WA_FLOW-FUNCT EQ 'BAPI_GOODSMVT_CREATE'.
*Verifica Autorização usuario
      CALL FUNCTION 'ZHMS_FM_SECURITY'
        EXPORTING
          VALUE         = 'MIGO'
        EXCEPTIONS
          AUTHORIZATION = 1
          OTHERS        = 2.

      IF SY-SUBRC <> 0.
        MOVE 'X' TO VL_STOP.
        VL_START = ' '.
        MESSAGE I003(ZHMS_SECURITY). "   Usuário sem autorização
        CONTINUE.
      ENDIF.
    ENDIF.

    IF WA_FLOW-FUNCT EQ 'BAPI_INCOMINGINVOICE_CREATE'.
*Verifica Autorização usuario
      CALL FUNCTION 'ZHMS_FM_SECURITY'
        EXPORTING
          VALUE         = 'MIRO'
        EXCEPTIONS
          AUTHORIZATION = 1
          OTHERS        = 2.

      IF SY-SUBRC <> 0.
        MOVE 'X' TO VL_STOP.
        VL_START = ' '.
        MESSAGE I002(ZHMS_SECURITY). "   Usuário sem autorização
        CONTINUE.
      ENDIF.
    ENDIF.


*    Buscar etapa na lista de etapas do documento
    CLEAR WA_FLWDOC.
    READ TABLE IT_FLWDOC INTO WA_FLWDOC WITH KEY FLOWD = WA_FLOW-FLOWD.

*    IF sy-subrc IS INITIAL.
*    Verifica se a etapa é Manual e caso seja, verifica se foi concluída
    IF WA_FLOW-METPR EQ 'M' "Manual
     AND WA_FLWDOC-FLWST NE 'M'."Concluída Manualmente
*** Incio David Rosin 11/03/2014
      CLEAR WA_SCEN_FLO.
      READ TABLE IT_SCEN_FLO INTO WA_SCEN_FLO WITH KEY FLOWD =
WA_FLOW-FLOWD.
      IF SY-SUBRC IS INITIAL.
        ADD 1 TO SY-TABIX.
        READ TABLE IT_SCEN_FLO INTO WA_SCEN_FLO INDEX SY-TABIX.
** Verifica se a proxima etapa é manual ou automatica
        IF SY-SUBRC IS INITIAL AND WA_SCEN_FLO-METPR EQ 'M'.
          VL_STOP = 'X'.
          CLEAR VL_START.
        ENDIF.
      ENDIF.
    ENDIF.
*** Fim David Rosin 11/03/2014
*    ENDIF.


*    Realizar validação de etapa
**    Executa funções de validação
    IF NOT WA_FLOW-VLDCD IS INITIAL.
      CLEAR VL_VLDTY.
      CALL FUNCTION 'ZHMS_FM_VALIDAR'
        EXPORTING
          VLDCD   = WA_FLOW-VLDCD
          CABDOC  = WA_CABDOC
          REGHIST = ' '
        IMPORTING
          VLDTY   = VL_VLDTY.
    ENDIF.


*  Caso tenha encontrado erro interrompe o processamento
    IF VL_VLDTY EQ 'E'.
      VL_STOP = 'X'.
      CLEAR VL_START.
    ENDIF.

    IF WA_SCENARIO-SCENA NE '3'.
*** Verifica se todos os items á foram atribuidos
      IF WA_SCENARIO-SCENA NE '2'.
        PERFORM F_DISABLE_AUTOFLUXO CHANGING VL_STOP VL_START.
      ELSE.

        SELECT SINGLE USUARIO FROM ZHMS_TB_USER_RFC INTO LV_USER.

        IF SY-UNAME NE  LV_USER.
          PERFORM F_CHECK_ATRIB CHANGING VL_STOP VL_START.
        ENDIF.
      ENDIF.
    ELSE.
*** Verifica se é a primeira execução via QUAZARIS - Paralisa o process

      PERFORM F_AUTO_ATRIB CHANGING VL_STOP VL_START.


*** Verifica se a atribução está automatica pela carga quazaris
      SELECT SINGLE FLAG
        INTO VL_ATRI_AT
        FROM ZHMS_TB_ATRI_AT.
      IF SY-SUBRC EQ 0.
        IF VL_ATRI_AT EQ 'X'.
          PERFORM F_ATRIB_MANUAL CHANGING VL_STOP VL_START.
        ENDIF.
      ENDIF.
*** Verifica se o QM esta liberado
*      PERFORM f_check_qm CHANGING vl_stop vl_start.

    ENDIF.

    IF VL_VLDTY EQ 'E'.
      READ TABLE IT_SCEN_FLO INTO WA_SCEN_FLO WITH KEY NATDC = V_NATDC
                                                       TYPED = V_TYPED
                                                       FLOWD =
WA_FLOWX-FLOWD.
      IF NOT WA_SCEN_FLO-FUNCT IS INITIAL AND NOT
WA_SCEN_FLO-FUNCT_ESTORNO IS INITIAL.
        VL_STOP = 'X'.
        CLEAR VL_START.
        CONTINUE.
*** Vai chamar função para envio de email sobre o erro

      ENDIF.
    ENDIF.

*   Define se irá processar
    IF WA_FLOW-CODMP IS INITIAL. "Caso nao Tenha função de processamento
      CLEAR VL_START.
    ENDIF.

    IF NOT WA_FLOW-FUNCT IS INITIAL "Caso Tenha função de processamento
      AND WA_FLWDOC-FLWST EQ 'A'. "e não esteja processada
*automaticamente
      CLEAR VL_START.
    ENDIF.

    IF VL_VLDTY_MAIN EQ 'E' "Caso exista erro na validação principal
      AND WA_FLOW-TPPRM EQ 9. "E o tipo de ação da etapa seja
*processamento
      CLEAR VL_START.
    ENDIF.


    IF NOT VL_START IS INITIAL.

*    Gerar código para Mapeamento
      CALL FUNCTION 'ZHMS_FM_MAPPING'
        EXPORTING
          CODMP   = WA_FLOW-CODMP
          FUNCT   = WA_FLOW-FUNCT
          FLOWD   = WA_FLOW-FLOWD
        TABLES
          MSGDATA = IT_MSGDATA
          MSGATRB = IT_MSGATRB.

    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_EXECUTA_FLUXOS

*&---------------------------------------------------------------------*
*&      Form  F_TRATA_EXECUCOES
*&---------------------------------------------------------------------*
*       Geração do FORM principal dinâmico
*----------------------------------------------------------------------*
FORM f_trata_execucoes .
  CHECK NOT it_performs[] IS INITIAL.

* Inicializar código gerado
  REFRESH it_scode_main.
  CLEAR wa_scode.

  APPEND 'PROGRAM SUBPOOL REDUCED FUNCTIONALITY.' TO it_scode_main.
  APPEND 'data: vdf_err_flow type flag.' TO it_scode_main.

* Adiciona o códigos de variáveis já gerados
  SORT it_scode_vars.
  DELETE ADJACENT DUPLICATES FROM it_scode_vars.
  DELETE ADJACENT DUPLICATES FROM it_performs.
  LOOP AT it_scode_vars INTO wa_scode.
    APPEND wa_scode TO it_scode_main.
  ENDLOOP.


  SORT it_performs BY uniq_i ASCENDING.
* Form principal
  APPEND 'FORM f_executa_main.' TO it_scode_main.

  APPEND 'BREAK DTEIXEIRA.' TO it_scode_main.
  APPEND 'BREAK RHITOKAZ.' TO it_scode_main.
  APPEND 'BREAK ACLIMA.' TO it_scode_main.

* Adiciona execuções ao form principal
  LOOP AT it_performs INTO wa_performs.

    APPEND 'check vdf_err_flow is initial.' TO it_scode_main.

*   Execução
    CLEAR wa_scode.
    CONCATENATE '''' wa_performs-codmp '''' INTO wa_scode.
    CONDENSE wa_scode NO-GAPS.

    CONCATENATE 'PERFORM' wa_performs-srotine 'using' wa_scode '.' INTO wa_scode SEPARATED BY space.
    APPEND wa_scode TO it_scode_main.

*    Commit / Rollback
    CLEAR wa_scode.
    CONCATENATE '''' wa_performs-flowd '''' INTO wa_scode.
    CONDENSE wa_scode NO-GAPS.

    CONCATENATE 'PERFORM f_tratamento_pos IN PROGRAM SAPLZHMS_FG_RULER using '''wa_performs-funct '''' wa_scode INTO wa_scode SEPARATED BY space.
    APPEND wa_scode TO it_scode_main.

    CLEAR wa_scode.
    CONCATENATE '''' wa_performs-codmp '''' INTO wa_scode.
    CONDENSE wa_scode NO-GAPS.
    APPEND wa_scode TO it_scode_main.

    APPEND 'CHANGING vdf_err_flow.' TO it_scode_main.

*   Marcar como executado
    CLEAR wa_scode.
    CONCATENATE '''' wa_performs-flowd '''' INTO wa_scode.
    CONDENSE wa_scode NO-GAPS.

    CONCATENATE 'PERFORM f_set_processado IN PROGRAM SAPLZHMS_FG_RULER using' wa_scode '  vdf_err_flow .' INTO wa_scode SEPARATED BY space.
    APPEND wa_scode TO it_scode_main.

  ENDLOOP.

* Finaliza form principal
  APPEND 'ENDFORM.' TO it_scode_main.

* Adiciona o código já gerado
  LOOP AT it_scode INTO wa_scode.
    APPEND wa_scode TO it_scode_main.
  ENDLOOP.

* Gerar a subrotina no programa dynamico
  GENERATE SUBROUTINE POOL it_scode_main NAME v_protine.

ENDFORM.                    " F_TRATA_EXECUCOES

*&---------------------------------------------------------------------*
*&      Form  f_executa_chamada
*&---------------------------------------------------------------------*
*       Chamada de execução adjacente
*----------------------------------------------------------------------*
FORM f_executa_chamada.
  DATA: vl_index TYPE sy-tabix.

***  Obter a última linha de processamento
  DESCRIBE TABLE it_flow LINES vl_index.
  CLEAR wa_flow.
  READ TABLE it_flow INTO wa_flow INDEX vl_index.

***  Verificar se existe chamada
  IF NOT wa_flow-event_c IS INITIAL
     OR NOT wa_flow-scena_c IS INITIAL.

*** Chamada
    CALL FUNCTION 'ZHMS_FM_EXEC'
      EXPORTING
        natdc                      = v_natdc
        typed                      = v_typed
        loctp                      = v_loctp
        event                      = wa_flow-event_c
        scena                      = wa_flow-scena_c
      EXCEPTIONS
        nature_not_informed        = 1
        document_type_not_informed = 2
        event_scenery_not_informed = 3
        OTHERS                     = 4.

  ENDIF.


ENDFORM.                    "f_executa_chamada

*&---------------------------------------------------------------------*
*&      Form  f_atualiza_mn
*&---------------------------------------------------------------------*
*       Atualizar Mneumônicos de documento com base nos dados mapeados
*----------------------------------------------------------------------*
FORM f_atualiza_mn.

  DATA: ls_scen_flo TYPE zhms_tb_scen_flo,
        lt_mapping  TYPE STANDARD TABLE OF zhms_tb_mapdata,
        ls_mapping  LIKE LINE OF lt_mapping.

**  Apaga Mneumonicos antigos
  CHECK NOT v_chave IS INITIAL.

*** Inicio Alteração David Rosin
  DELETE it_docmn WHERE chave NE v_chave.
*** Fim Alteração David Rosin

  LOOP AT it_docmn INTO wa_docmn.
    DELETE FROM zhms_tb_docmn
     WHERE chave EQ v_chave
       AND mneum EQ wa_docmn-mneum
       AND dcitm EQ wa_docmn-dcitm
       AND atitm EQ wa_docmn-atitm.
  ENDLOOP.

  COMMIT WORK AND WAIT.

  IF sy-subrc IS INITIAL.
    LOOP AT it_scflow INTO wa_scflow WHERE funct_estorno IS NOT INITIAL.
      SELECT * FROM zhms_tb_mapdata APPENDING TABLE lt_mapping WHERE codmp EQ wa_scflow-codmp_estorno.
    ENDLOOP.
  ENDIF.

** Insere novos mneumomicos
  LOOP AT it_docmn INTO wa_docmn.

    READ TABLE lt_mapping INTO ls_mapping WITH KEY mneum =  wa_docmn-mneum.

    IF sy-subrc IS INITIAL.
      IF wa_docmn-mneum EQ ls_mapping-mneum.
        CONTINUE.
      ENDIF.
    ENDIF.

*** Fim alteração David Rosin
    INSERT INTO zhms_tb_docmn VALUES wa_docmn.

    IF sy-subrc IS INITIAL.
      COMMIT WORK AND WAIT.
    ELSE.
      ROLLBACK WORK.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "f_atualiza_mn

*&---------------------------------------------------------------------*
*&      Form  f_atualiza_st
*&---------------------------------------------------------------------*
*       Atualizar Status do documento
*----------------------------------------------------------------------*
FORM f_atualiza_st.

* Atualizar Status do documento
  CALL FUNCTION 'ZHMS_FM_STATUS'
    EXPORTING
      cabdoc = wa_cabdoc.

ENDFORM.                    "f_atualiza_st

*&---------------------------------------------------------------------*
*&      Form  f_set_processado
*&---------------------------------------------------------------------*
*       Marca a etapa como processada
*----------------------------------------------------------------------*
FORM f_set_processado USING p_flowd p_err_flow .

* Check se a etapa teve algum erro
  CHECK p_err_flow IS INITIAL.

  DATA: wl_flwdoc TYPE zhms_tb_flwdoc.

**  limpa possíveis registros antigos para a etapa
  DELETE FROM zhms_tb_flwdoc
  WHERE natdc EQ v_natdc
    AND typed EQ v_typed
    AND loctp EQ v_loctp
    AND chave EQ v_chave
    AND flowd EQ p_flowd.
  COMMIT WORK AND WAIT.

**  Reune informacoes
  wl_flwdoc-natdc = v_natdc.
  wl_flwdoc-typed = v_typed.
  wl_flwdoc-loctp = v_loctp.
  wl_flwdoc-chave = v_chave.
  wl_flwdoc-flowd = p_flowd.
  wl_flwdoc-dtreg = sy-datum.
  wl_flwdoc-hrreg = sy-uzeit.
  wl_flwdoc-uname = 'HomSoft'.
  wl_flwdoc-flwst = 'A'.

** Insere registro
  INSERT INTO zhms_tb_flwdoc VALUES wl_flwdoc.
  COMMIT WORK AND WAIT.

*** Caso etapa 10 já tenha sido concluida
  IF p_flowd > '10'.
    SELECT SINGLE * FROM zhms_tb_flwdoc INTO wl_flwdoc WHERE chave EQ wl_flwdoc-chave
                                                        AND flowd EQ '10'.

    IF sy-subrc IS NOT INITIAL.
      wl_flwdoc-natdc = v_natdc.
      wl_flwdoc-typed = v_typed.
      wl_flwdoc-loctp = v_loctp.
      wl_flwdoc-chave = v_chave.
      wl_flwdoc-flowd = '10'.
      wl_flwdoc-dtreg = sy-datum.
      wl_flwdoc-hrreg = sy-uzeit.
      wl_flwdoc-uname = sy-uname.
      wl_flwdoc-flwst = 'M'.

** Insere registro
      INSERT INTO zhms_tb_flwdoc VALUES wl_flwdoc.
      COMMIT WORK AND WAIT.

    ENDIF.

  ENDIF.

ENDFORM.                    "f_set_processado
*&---------------------------------------------------------------------*
*&      Form  f_entradanormal_atr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_entradanormal_atr TABLES p_it_hrvalid STRUCTURE wa_hrvalid.
 DATA: po_number     TYPE bapimepoheader-po_number,
        po_number2    TYPE bapiekko-po_number,
        ls_po_header  TYPE  bapimepoheader,
        ls_po_header2 TYPE  bapiekkol,
        lt_po_item    TYPE STANDARD TABLE OF bapimepoitem,
        lt_po_item2   TYPE STANDARD TABLE OF bapiekpo,
        lt_hist_total TYPE STANDARD TABLE OF bapiekbes,
        ls_hist_total LIKE LINE OF lt_hist_total,
        ls_po_item    LIKE LINE OF lt_po_item,
        ls_po_item2   LIKE LINE OF lt_po_item2,
        lv_item       TYPE zhms_de_value,
        lv_qtd        TYPE zhms_de_value,
        lv_qtrib      TYPE zhms_de_value,
        lv_po_cons    TYPE wemng,
        lv_atqtde     TYPE zhms_de_value,
        lv_qtd_at     TYPE zhms_de_value,
        lv_vprod      TYPE zhms_de_value,
        lv_cofins     TYPE zhms_de_value,
        lv_icms       TYPE zhms_de_value,
        lv_ipi        TYPE zhms_de_value,
        lv_sqn        TYPE zhms_de_value,
        lv_pis        TYPE zhms_de_value,
        lv_cof        TYPE zhms_de_value,
        lv_qcom       TYPE zhms_de_value,
        lv_vuncom     TYPE zhms_de_value,
        lv_sst        TYPE zhms_de_value,
        lv_totxml     TYPE zhms_de_value,
        lv_calc       TYPE wemng,
        lv_calc2      TYPE wemng,
        lv_calc3      TYPE wemng,
        lv_calc4      TYPE wemng,
        lv_tot_kbetr  TYPE komv-kbetr,
        lv_cont_1baj  TYPE i,
        lv_div_ped    TYPE komv-kbetr,
        lv_div_xml    TYPE komv-kbetr,
        lv_div_ped_c  TYPE char20,
        lv_div_xml_c  TYPE char20,
        lv_div_item   TYPE char6,
        lv_dif        TYPE p DECIMALS 2 VALUE '0.10',
        lv_sub        TYPE komv-kbetr,
        lv_ebeln      TYPE ebeln,
        lv_netpr      TYPE ekpo-netpr,
        lv_peinh      TYPE ekpo-peinh,

        lv_totalpo    TYPE konv-kwert,
        lv_result     TYPE konv-kwert,
        lv_difere     TYPE konv-kwert,
        lv_qcom_kwert TYPE konv-kwert,
        lv_ucom_kwert  TYPE konv-kwert,
        lv_qtrib_kwert TYPE konv-kwert,
        lv_basb        TYPE konv-kwert,
        lv_icm0        TYPE konv-kwert,
        lv_icm1        TYPE konv-kwert,
        lv_icm2        TYPE konv-kwert,
        lv_ipis        TYPE konv-kwert,
        lv_icof        TYPE konv-kwert,
        lv_icon        TYPE konv-kwert,
        lv_ipsn        TYPE konv-kwert,
        lv_vlr_unit    TYPE konv-kwert.

  DATA lv_param TYPE konv-kwert.
  DATA lv_matnr TYPE matnr.
  DATA lv_error TYPE c.

*** Seleciona quis validações estão habilitadas
  REFRESH t_tb_vld_tax[].
  SELECT *
    FROM zhms_tb_vld_tax
    INTO TABLE t_tb_vld_tax
   WHERE tax_type NE ' '.

  SELECT *
    INTO TABLE it_mapdata_aux
    FROM zhms_tb_mapdata
   WHERE codmp EQ '01'.

***RRO 21/02/2019 -->>
***Parametrização p. definir se usa PIS/COF. do XML ou não.
  REFRESH it_tvarv[].
  SELECT * FROM tvarvc INTO TABLE it_tvarv WHERE name EQ 'Z_HOMSOFT'.
***RRO 21/02/2019 <<--

* Verifica dados encontrados
  IF it_mapdata_aux[] IS INITIAL.
    RAISE mapping_data_not_found.
  ELSE.
    REFRESH it_mapdata[].
    LOOP AT it_mapdata_aux INTO wa_mapdata.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = wa_mapdata-seqnr
        IMPORTING
          output = wa_mapdata-seqnr.

      APPEND wa_mapdata TO it_mapdata.
    ENDLOOP.
  ENDIF.
  PERFORM f_mneum_entradanormal IN PROGRAM saplzhms_fg_ruler USING '01' ' 20 ' IF FOUND.
  PERFORM f_atualiza_mn IN PROGRAM saplzhms_fg_ruler IF FOUND.

** Dados de Item
  REFRESH it_itmdoc.
  SELECT *
    INTO TABLE it_itmdoc
    FROM zhms_tb_itmdoc
   WHERE natdc EQ wa_cabdoc-natdc
     AND typed EQ wa_cabdoc-typed
     AND loctp EQ wa_cabdoc-loctp
     AND chave EQ wa_cabdoc-chave.

** Dados de Atribuição
  REFRESH it_itmatr.
  IF NOT it_itmdoc[] IS INITIAL.
    SELECT *
      INTO TABLE it_itmatr
      FROM zhms_tb_itmatr
       FOR ALL ENTRIES IN it_itmdoc
     WHERE natdc EQ it_itmdoc-natdc
       AND typed EQ it_itmdoc-typed
       AND loctp EQ it_itmdoc-loctp
       AND chave EQ it_itmdoc-chave
       AND dcitm EQ it_itmdoc-dcitm.
  ENDIF.

  break saoprocwrkfm.

  LOOP AT it_itmatr INTO wa_itmatr.

    REFRESH lt_po_item[].
    CLEAR: wa_docmnx, wa_ekko, vg_message, ls_po_item.

*** Verifica se o pedido existe
***    SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_itmatr-chave
***                                                         AND mneum EQ 'ATPED'
***                                                         AND atitm EQ wa_itmatr-atitm.
***    IF sy-subrc IS INITIAL.
***
***      MOVE wa_docmnx-value TO lv_ebeln.
    MOVE wa_itmatr-nrsrf TO lv_ebeln.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = lv_ebeln
      IMPORTING
        output = lv_ebeln.

    SELECT SINGLE * FROM ekko INTO wa_ekko WHERE ebeln EQ lv_ebeln.

    IF sy-subrc IS NOT INITIAL.
      SELECT SINGLE text grp INTO (vg_message, wa_hrvalid-grp)
                             FROM zhms_tb_messages WHERE code EQ '0004'.

      MOVE: wa_cabdoc-natdc  TO wa_hrvalid-natdc,
            wa_cabdoc-typed  TO wa_hrvalid-typed,
            wa_cabdoc-loctp  TO wa_hrvalid-loctp,
            wa_cabdoc-chave  TO wa_hrvalid-chave,
            '1'              TO wa_hrvalid-seqnr,
            sy-datum         TO wa_hrvalid-dtreg,
            sy-uzeit         TO wa_hrvalid-hrreg,
            wa_itmatr-atitm  TO wa_hrvalid-atitm,
            'E'              TO wa_hrvalid-vldty,
            '0004'            TO wa_hrvalid-vldv1,
            vg_message       TO wa_hrvalid-vldv2,
            'X'              TO wa_hrvalid-ativo.
      APPEND wa_hrvalid TO p_it_hrvalid.
      CLEAR wa_hrvalid.
    ENDIF.
***    ENDIF.

*** Busca Detalhes Pedido de compras
*    MOVE wa_docmnx-value TO po_number.
*    MOVE wa_docmnx-value TO po_number2.
    MOVE wa_itmatr-nrsrf TO po_number.
    MOVE wa_itmatr-nrsrf TO po_number2.

*** Programa de Remessa
    IF wa_ekko-bstyp EQ 'L'.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = po_number2
        IMPORTING
          output = po_number2.

      CALL FUNCTION 'BAPI_PO_GETDETAIL'
        EXPORTING
          purchaseorder = po_number2
        IMPORTING
          po_header     = ls_po_header2
        TABLES
          po_items      = lt_po_item2.

*** Verifica pedido para fornecedor
      SELECT SINGLE * FROM ekko INTO wa_ekko WHERE ebeln EQ lv_ebeln
                                               AND lifnr EQ ls_po_header2-vendor.

      IF sy-subrc IS NOT INITIAL.
        SELECT SINGLE text grp INTO (vg_message, wa_hrvalid-grp)
                               FROM zhms_tb_messages WHERE code EQ '0005'.

        MOVE: wa_cabdoc-natdc  TO wa_hrvalid-natdc,
              wa_cabdoc-typed  TO wa_hrvalid-typed,
              wa_cabdoc-loctp  TO wa_hrvalid-loctp,
              wa_cabdoc-chave  TO wa_hrvalid-chave,
              '1'              TO wa_hrvalid-seqnr,
              sy-datum         TO wa_hrvalid-dtreg,
              sy-uzeit         TO wa_hrvalid-hrreg,
              wa_itmatr-atitm  TO wa_hrvalid-atitm,
              'E'              TO wa_hrvalid-vldty,
              '0005'           TO wa_hrvalid-vldv1,
              vg_message       TO wa_hrvalid-vldv2,
              'X'              TO wa_hrvalid-ativo.
        APPEND wa_hrvalid TO p_it_hrvalid.
        CLEAR wa_hrvalid.
      ENDIF.

*** Verifica item atribuido do PO
      CLEAR wa_docmnx.
      SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_cabdoc-chave
                                                           AND mneum EQ 'ATITMPED'
                                                           AND atitm EQ wa_itmatr-atitm.
*---RRO 14/10/2019>>--------------------------------------------------*
      IF sy-subrc IS NOT INITIAL.
        CLEAR wa_docmnx.
        SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_cabdoc-chave
                                                             AND mneum EQ 'NITEMPED'
                                                             AND dcitm EQ wa_itmdoc-dcitm.
      ENDIF.
*---RRO 14/10/2019<<-------------------------------------------------*
      IF sy-subrc IS INITIAL.
        READ TABLE lt_po_item2 INTO ls_po_item2 WITH KEY po_item = wa_docmnx-value BINARY SEARCH.

        IF sy-subrc IS NOT INITIAL.

          SELECT SINGLE text grp INTO (vg_message, wa_hrvalid-grp)  FROM zhms_tb_messages WHERE code EQ '0007'.

          MOVE: wa_cabdoc-natdc  TO wa_hrvalid-natdc,
                wa_cabdoc-typed  TO wa_hrvalid-typed,
                wa_cabdoc-loctp  TO wa_hrvalid-loctp,
                wa_cabdoc-chave  TO wa_hrvalid-chave,
                '1'              TO wa_hrvalid-seqnr,
                sy-datum         TO wa_hrvalid-dtreg,
                sy-uzeit         TO wa_hrvalid-hrreg,
                wa_itmatr-atitm  TO wa_hrvalid-atitm,
                'E'              TO wa_hrvalid-vldty,
                '0007'           TO wa_hrvalid-vldv1,
                vg_message       TO wa_hrvalid-vldv2,
                'X'              TO wa_hrvalid-ativo.
          APPEND wa_hrvalid TO p_it_hrvalid.
          CLEAR wa_hrvalid.

        ENDIF.
      ENDIF.

*** Verifica se o item do pedido esta bloqueado
      CLEAR wa_docmnx.
      SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_cabdoc-chave
                                                           AND mneum EQ 'ATITMPED'
                                                           AND atitm EQ wa_itmatr-atitm.
*---RRO 14/10/2019>>-------------------------------------------------*
      IF sy-subrc IS NOT INITIAL.
        CLEAR wa_docmnx.
        SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_cabdoc-chave
                                                             AND mneum EQ 'NITEMPED'
                                                             AND dcitm EQ wa_itmdoc-dcitm.
      ENDIF.
*---RRO 14/10/2019<<-------------------------------------------------*
      IF sy-subrc IS INITIAL.
        READ TABLE lt_po_item2 INTO ls_po_item2 WITH KEY po_item = wa_docmnx-value BINARY SEARCH.

        IF sy-subrc IS INITIAL AND ls_po_item2-delete_ind IS NOT INITIAL.
          SELECT SINGLE text grp INTO (vg_message, wa_hrvalid-grp) FROM zhms_tb_messages WHERE code EQ '0008'.

          MOVE: wa_cabdoc-natdc  TO wa_hrvalid-natdc,
                wa_cabdoc-typed  TO wa_hrvalid-typed,
                wa_cabdoc-loctp  TO wa_hrvalid-loctp,
                wa_cabdoc-chave  TO wa_hrvalid-chave,
                '1'              TO wa_hrvalid-seqnr,
                sy-datum         TO wa_hrvalid-dtreg,
                sy-uzeit         TO wa_hrvalid-hrreg,
                wa_itmatr-atitm  TO wa_hrvalid-atitm,
                'E'              TO wa_hrvalid-vldty,
                '0008'           TO wa_hrvalid-vldv1,
                vg_message       TO wa_hrvalid-vldv2,
                'X'              TO wa_hrvalid-ativo.
          APPEND wa_hrvalid TO p_it_hrvalid.
          CLEAR wa_hrvalid.

        ENDIF.
      ENDIF.

***RRO Valida valores unitários 20/02/2019 -->>
      CLEAR: lv_netpr, lv_peinh.
      SELECT SINGLE netpr peinh
               FROM ekpo INTO (lv_netpr, lv_peinh)
              WHERE ebeln EQ wa_ekko-ebeln
                AND ebelp EQ wa_docmnx-value.

      IF sy-subrc EQ 0.

        TRY .
            lv_netpr = lv_netpr / lv_peinh.
          CATCH cx_sy_zerodivide.
        ENDTRY.

*** Valor do VPROD por ITEM no XML
        CLEAR lv_vprod.
        SELECT SINGLE value FROM zhms_tb_docmn INTO lv_vprod WHERE chave EQ wa_cabdoc-chave
                                                               AND mneum EQ 'VPROD'
                                                               AND dcitm EQ wa_itmatr-dcitm.

*** Valor do ICMS por ITEM no XML
        CLEAR lv_icms.
        SELECT SINGLE value FROM zhms_tb_docmn INTO lv_icms WHERE chave EQ wa_cabdoc-chave
                                                              AND mneum EQ 'VICMS'
                                                              AND dcitm EQ wa_itmatr-dcitm.

*** Valor do IPI por ITEM no XML
        CLEAR lv_ipi.
        SELECT SINGLE value FROM zhms_tb_docmn INTO lv_ipi WHERE chave EQ wa_cabdoc-chave
                                                             AND mneum EQ 'VIPI'
                                                             AND dcitm EQ wa_itmatr-dcitm.

        CLEAR: wa_tvarv, lv_pis, lv_cofins.
        READ TABLE it_tvarv INTO wa_tvarv WITH KEY low = 'ATIVO'.
        IF wa_tvarv-high EQ abap_true.

          TRY .
              CLEAR wa_tvarv.
              READ TABLE it_tvarv INTO wa_tvarv WITH KEY low = 'PIS'.
              lv_pis = ( lv_vprod * wa_tvarv-high ) / 100.
              CONDENSE lv_pis NO-GAPS.

              CLEAR wa_tvarv.
              READ TABLE it_tvarv INTO wa_tvarv WITH KEY low = 'COFINS'.
              lv_cofins = ( lv_vprod * wa_tvarv-high ) / 100.
              CONDENSE lv_cofins NO-GAPS.
            CATCH cx_root.
          ENDTRY.

        ELSE.

*** Valor do PIS por ITEM no XML
          CLEAR lv_pis.
          SELECT SINGLE value FROM zhms_tb_docmn INTO lv_pis WHERE chave EQ wa_cabdoc-chave
                                                               AND mneum EQ 'VPIS'
                                                               AND dcitm EQ wa_itmatr-dcitm.

*** Valor do COFINS por ITEM no XML
          CLEAR lv_cofins.
          SELECT SINGLE value FROM zhms_tb_docmn INTO lv_cofins WHERE chave EQ wa_cabdoc-chave
                                                                  AND mneum EQ 'VCOFINS'
                                                                  AND dcitm EQ wa_itmatr-dcitm.
        ENDIF.

        TRY .
            lv_result = lv_icms + lv_ipi + lv_pis + lv_cofins.
            lv_result = lv_vprod - lv_result.
          CATCH cx_root.
        ENDTRY.

*** Valor do COFINS por ITEM no XML
        CLEAR: lv_qtrib, lv_difere, lv_qtrib_kwert.
*        SELECT SINGLE value FROM zhms_tb_docmn INTO lv_qtrib WHERE chave EQ wa_cabdoc-chave
*                                                               AND mneum EQ 'QTRIB'
*                                                               AND dcitm EQ wa_itmatr-dcitm.
*
*        IF lv_qtrib GT '0.00'.

        PERFORM f_converte_qtd USING wa_itmatr
                            CHANGING lv_qtrib_kwert.

        IF lv_qtrib_kwert GT '0.00'.
*          lv_qtrib_kwert = lv_qtrib.
          TRY .
              lv_vlr_unit = lv_result / lv_qtrib_kwert.

              IF lv_vlr_unit GT lv_netpr.
                lv_difere = lv_vlr_unit - lv_netpr.
              ELSEIF lv_vlr_unit LT lv_netpr.
                lv_difere = lv_netpr - lv_vlr_unit.
              ENDIF.
            CATCH cx_root.
          ENDTRY.
        ENDIF.

        IF lv_difere GT '0.10'.
          SELECT SINGLE text grp INTO (vg_message, wa_hrvalid-grp) FROM zhms_tb_messages
                                                                  WHERE code EQ '0018'.
          CLEAR: lv_div_ped_c, lv_div_xml_c, lv_div_item.
          MOVE wa_itmatr-itsrf TO lv_div_item.
          MOVE lv_vlr_unit TO lv_div_xml_c.
          MOVE lv_netpr TO lv_div_ped_c.

          CONDENSE: lv_div_ped_c NO-GAPS.
          CONDENSE: lv_div_xml_c NO-GAPS.
          CONDENSE: lv_div_item  NO-GAPS.

          REPLACE '&1' IN vg_message WITH lv_div_ped_c.
          REPLACE '&2' IN vg_message WITH lv_div_item.
          REPLACE '&3' IN vg_message WITH lv_div_xml_c.

          MOVE: wa_cabdoc-natdc  TO wa_hrvalid-natdc,
                wa_cabdoc-typed  TO wa_hrvalid-typed,
                wa_cabdoc-loctp  TO wa_hrvalid-loctp,
                wa_cabdoc-chave  TO wa_hrvalid-chave,
                '1'              TO wa_hrvalid-seqnr,
                sy-datum         TO wa_hrvalid-dtreg,
                sy-uzeit         TO wa_hrvalid-hrreg,
                wa_itmatr-atitm  TO wa_hrvalid-atitm,
                'E'              TO wa_hrvalid-vldty,
                '0018'           TO wa_hrvalid-vldv1,
                vg_message       TO wa_hrvalid-vldv2,
                'X'              TO wa_hrvalid-ativo.
******          APPEND wa_hrvalid TO p_it_hrvalid.
          CLEAR wa_hrvalid.
        ENDIF.
      ENDIF.
***RRO Valida valores unitários 20/02/2019 <<--

*** Pedido normal
    ELSE.
      po_number = wa_itmatr-nrsrf.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = po_number
        IMPORTING
          output = po_number.

      CALL FUNCTION 'BAPI_PO_GETDETAIL1'
        EXPORTING
          purchaseorder    = po_number
        IMPORTING
          poheader         = ls_po_header
        TABLES
          poitem           = lt_po_item
          pohistory_totals = lt_hist_total.

***Verifica se o pedido não está liberado no sistema
*      IF wa_ekko IS NOT INITIAL AND wa_ekko-frgke NE '1' AND vg_message IS INITIAL. "RRO 24/01/19
      IF wa_ekko IS NOT INITIAL AND wa_ekko-frgke EQ 'B' AND vg_message IS INITIAL.

        SELECT SINGLE text grp FROM zhms_tb_messages INTO (vg_message, wa_hrvalid-grp)
                                                     WHERE code EQ '0006'.

        MOVE: wa_cabdoc-natdc  TO wa_hrvalid-natdc,
              wa_cabdoc-typed  TO wa_hrvalid-typed,
              wa_cabdoc-loctp  TO wa_hrvalid-loctp,
              wa_cabdoc-chave  TO wa_hrvalid-chave,
              '1'              TO wa_hrvalid-seqnr,
              sy-datum         TO wa_hrvalid-dtreg,
              sy-uzeit         TO wa_hrvalid-hrreg,
              wa_itmatr-atitm  TO wa_hrvalid-atitm,
              'E'              TO wa_hrvalid-vldty,
              '0006'           TO wa_hrvalid-vldv1,
              vg_message       TO wa_hrvalid-vldv2,
              'X'              TO wa_hrvalid-ativo.
        APPEND wa_hrvalid TO p_it_hrvalid.
        CLEAR wa_hrvalid.

      ENDIF.

*** Verifica pedido para fornecedor
      SELECT SINGLE * FROM ekko INTO wa_ekko WHERE ebeln EQ lv_ebeln
                                               AND lifnr EQ ls_po_header-vendor.

      IF sy-subrc IS NOT INITIAL.
        SELECT SINGLE text grp INTO (vg_message, wa_hrvalid-grp)
                               FROM zhms_tb_messages WHERE code EQ '0005'.

        MOVE: wa_cabdoc-natdc  TO wa_hrvalid-natdc,
              wa_cabdoc-typed  TO wa_hrvalid-typed,
              wa_cabdoc-loctp  TO wa_hrvalid-loctp,
              wa_cabdoc-chave  TO wa_hrvalid-chave,
              '1'              TO wa_hrvalid-seqnr,
              sy-datum         TO wa_hrvalid-dtreg,
              sy-uzeit         TO wa_hrvalid-hrreg,
              wa_itmatr-atitm  TO wa_hrvalid-atitm,
              'E'              TO wa_hrvalid-vldty,
              '0005'           TO wa_hrvalid-vldv1,
              vg_message       TO wa_hrvalid-vldv2,
              'X'              TO wa_hrvalid-ativo.
        APPEND wa_hrvalid TO p_it_hrvalid.
        CLEAR wa_hrvalid.
      ENDIF.

*** Verifica item atribuido do PO
      CLEAR wa_docmnx.
      SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_cabdoc-chave
                                                           AND mneum EQ 'ATITMPED'
                                                           AND atitm EQ wa_itmatr-atitm.
      IF sy-subrc IS INITIAL.
        READ TABLE lt_po_item INTO ls_po_item WITH KEY po_item = wa_docmnx-value BINARY SEARCH.

        IF sy-subrc IS NOT INITIAL.

          SELECT SINGLE text grp INTO (vg_message, wa_hrvalid-grp)
                                 FROM zhms_tb_messages WHERE code EQ '0007'.

          MOVE: wa_cabdoc-natdc  TO wa_hrvalid-natdc,
                wa_cabdoc-typed  TO wa_hrvalid-typed,
                wa_cabdoc-loctp  TO wa_hrvalid-loctp,
                wa_cabdoc-chave  TO wa_hrvalid-chave,
                '1'              TO wa_hrvalid-seqnr,
                sy-datum         TO wa_hrvalid-dtreg,
                sy-uzeit         TO wa_hrvalid-hrreg,
                wa_itmatr-atitm  TO wa_hrvalid-atitm,
                'E'              TO wa_hrvalid-vldty,
                '0007'           TO wa_hrvalid-vldv1,
                vg_message       TO wa_hrvalid-vldv2,
                'X'              TO wa_hrvalid-ativo.
          APPEND wa_hrvalid TO p_it_hrvalid.
          CLEAR wa_hrvalid.

        ENDIF.
      ENDIF.

*** Verifica se o item do pedido esta bloqueado
      CLEAR wa_docmnx.
      SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_cabdoc-chave
                                                           AND mneum EQ 'ATITMPED'
                                                           AND atitm EQ wa_itmatr-atitm.
      IF sy-subrc IS INITIAL.
        READ TABLE lt_po_item INTO ls_po_item WITH KEY po_item = wa_docmnx-value BINARY SEARCH.

        IF sy-subrc IS INITIAL AND ls_po_item-delete_ind IS NOT INITIAL.
          SELECT SINGLE text grp INTO (vg_message, wa_hrvalid-grp) FROM zhms_tb_messages WHERE code EQ '0008'.

          MOVE: wa_cabdoc-natdc  TO wa_hrvalid-natdc,
                wa_cabdoc-typed  TO wa_hrvalid-typed,
                wa_cabdoc-loctp  TO wa_hrvalid-loctp,
                wa_cabdoc-chave  TO wa_hrvalid-chave,
                '1'              TO wa_hrvalid-seqnr,
                sy-datum         TO wa_hrvalid-dtreg,
                sy-uzeit         TO wa_hrvalid-hrreg,
                wa_itmatr-atitm  TO wa_hrvalid-atitm,
                'E'              TO wa_hrvalid-vldty,
                '0008'           TO wa_hrvalid-vldv1,
                vg_message       TO wa_hrvalid-vldv2,
                'X'              TO wa_hrvalid-ativo.
          APPEND wa_hrvalid TO p_it_hrvalid.
          CLEAR wa_hrvalid.

        ENDIF.
      ENDIF.
    ENDIF.


*** Validacao do total da NF-e
*    CLEAR lv_totxml.
*    CLEAR: lv_totalpo.
*    SELECT SINGLE value FROM zhms_tb_docmn INTO lv_totxml  WHERE chave EQ wa_cabdoc-chave
*                                                          AND mneum EQ 'VNF'.
*
*    DATA: it_ekpo TYPE TABLE OF ekpo,
*          wa_ekpo TYPE ekpo.
*
*    SELECT * FROM ekpo INTO TABLE it_ekpo WHERE ebeln EQ po_number.
*
*    LOOP AT it_ekpo INTO wa_ekpo.
*      lv_totalpo = lv_totalpo + ( wa_ekpo-netwr * wa_ekpo-menge ).
*    ENDLOOP.
*
*    IF lv_totxml > lv_totalpo.
*      SELECT SINGLE text grp INTO (vg_message, wa_hrvalid-grp) FROM zhms_tb_messages WHERE code EQ '0017'.
*
*      MOVE: wa_cabdoc-natdc  TO wa_hrvalid-natdc,
*            wa_cabdoc-typed  TO wa_hrvalid-typed,
*            wa_cabdoc-loctp  TO wa_hrvalid-loctp,
*            wa_cabdoc-chave  TO wa_hrvalid-chave,
*            '1'              TO wa_hrvalid-seqnr,
*            sy-datum         TO wa_hrvalid-dtreg,
*            sy-uzeit         TO wa_hrvalid-hrreg,
*            wa_itmatr-atitm  TO wa_hrvalid-atitm,
*            'E'              TO wa_hrvalid-vldty,
*            '0017'           TO wa_hrvalid-vldv1,
*            vg_message       TO wa_hrvalid-vldv2,
*            'X'              TO wa_hrvalid-ativo.
*      APPEND wa_hrvalid TO p_it_hrvalid.
*      CLEAR wa_hrvalid.
*    ENDIF.


*** Valida NCM
**---RRO 14/10/2019>>-------------------------------------------------*
*    CLEAR: wa_docmnx, ls_po_item.
*    SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_cabdoc-chave
*                                                         AND mneum EQ 'ATITMPED'
*                                                         AND dcitm EQ wa_itmdoc-dcitm.
*
*    IF sy-subrc IS NOT INITIAL.
*      CLEAR: wa_docmnx, ls_po_item.
*      SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_cabdoc-chave
*                                                           AND mneum EQ 'NITEMPED'
*                                                           AND dcitm EQ wa_itmdoc-dcitm.
*    ENDIF.
**---RRO 14/10/2019<<-------------------------------------------------*

    CLEAR wa_docmnx.
    SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_cabdoc-chave
                                                         AND mneum EQ 'XMLNCM'
                                                         AND dcitm EQ wa_itmatr-atitm.

    REFRESH it_docmni[].
    SELECT * FROM zhms_tb_docmn INTO TABLE it_docmni  WHERE chave EQ wa_cabdoc-chave
                                                        AND mneum EQ 'NCM'
                                                        AND dcitm EQ wa_docmnx-dcitm.

    LOOP AT it_docmni INTO wa_docmni.

      TRANSLATE wa_docmni-value USING '. '.
      TRANSLATE wa_docmnx-value USING '. '.
      CONDENSE wa_docmni-value NO-GAPS.
      CONDENSE wa_docmnx-value NO-GAPS.

      CLEAR: vg_ncm_xml, vg_ncm_mne.
      MOVE: wa_docmni-value TO vg_ncm_mne,
            wa_docmnx-value TO vg_ncm_xml.

      READ TABLE t_tb_vld_tax INTO ls_tb_vld_tax WITH KEY tax_type = 'NCM'.

      IF vg_ncm_mne NE vg_ncm_xml AND ls_tb_vld_tax-ativo IS NOT INITIAL.
        SELECT SINGLE text grp INTO (vg_message, wa_hrvalid-grp)
                               FROM zhms_tb_messages WHERE code EQ '0009'.

        MOVE  wa_docmni-atitm  TO wa_itmatr-atitm.
        MOVE: wa_cabdoc-natdc  TO wa_hrvalid-natdc,
              wa_cabdoc-typed  TO wa_hrvalid-typed,
              wa_cabdoc-loctp  TO wa_hrvalid-loctp,
              wa_cabdoc-chave  TO wa_hrvalid-chave,
              '1'              TO wa_hrvalid-seqnr,
              sy-datum         TO wa_hrvalid-dtreg,
              sy-uzeit         TO wa_hrvalid-hrreg,
              wa_itmatr-atitm  TO wa_hrvalid-atitm,
              'E'              TO wa_hrvalid-vldty,
              '0009'           TO wa_hrvalid-vldv1,
              vg_message       TO wa_hrvalid-vldv2,
              'X'              TO wa_hrvalid-ativo.
        APPEND wa_hrvalid TO p_it_hrvalid.
        CLEAR wa_hrvalid.

      ENDIF.
    ENDLOOP.

*Renan Itokazo
*17.01.2019
*** Valida quantidade excedida
    CLEAR wa_docmnx.
    SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_cabdoc-chave
                                                         AND mneum EQ 'ATITMPED'
                                                         AND dcitm EQ wa_itmatr-dcitm
                                                         AND atitm EQ wa_itmatr-atitm.
    IF sy-subrc IS INITIAL.
      CLEAR: lv_qtd, lv_atqtde.
      SELECT SINGLE value FROM zhms_tb_docmn INTO lv_qtd WHERE chave EQ wa_cabdoc-chave
*                                                           AND mneum EQ 'QUANTITY'
                                                           AND mneum EQ 'QCOM'
                                                           AND dcitm EQ wa_itmatr-dcitm.
*                                                           AND atitm EQ wa_itmatr-atitm.

      SELECT SINGLE value FROM zhms_tb_docmn INTO lv_atqtde WHERE chave EQ wa_cabdoc-chave
                                                              AND mneum EQ 'ATQTDE'
                                                              AND dcitm EQ wa_itmatr-dcitm
                                                              AND atitm EQ wa_itmatr-atitm.
      IF sy-subrc IS INITIAL.

        CLEAR ls_po_item.
        READ TABLE lt_po_item INTO ls_po_item WITH KEY po_item  = wa_docmnx-value BINARY SEARCH.

        IF sy-subrc IS INITIAL.
          CLEAR: lv_calc, lv_calc2, lv_calc3, lv_calc4, ls_hist_total.
          READ TABLE  lt_hist_total INTO ls_hist_total WITH KEY po_item = wa_docmnx-value.
          IF sy-subrc IS INITIAL.
*            lv_calc = ( ls_hist_total-deliv_qty + lv_qtd * ( ls_po_item-over_dlv_tol / 100 ) ).
            lv_calc  = ls_po_item-over_dlv_tol / 100.
            lv_calc2 = ls_hist_total-deliv_qty + lv_qtd.
            lv_calc3 = lv_calc + lv_calc2.
            lv_calc4 = lv_calc3 - ls_hist_total-deliv_qty.

            IF lv_calc4 < lv_atqtde.
              IF ls_po_item-unlimited_dlv IS INITIAL.
                SELECT SINGLE text grp INTO (vg_message, wa_hrvalid-grp)
                                       FROM zhms_tb_messages WHERE code EQ '0010'.

                MOVE: wa_cabdoc-natdc  TO wa_hrvalid-natdc,
                      wa_cabdoc-typed  TO wa_hrvalid-typed,
                      wa_cabdoc-loctp  TO wa_hrvalid-loctp,
                      wa_cabdoc-chave  TO wa_hrvalid-chave,
                      '1'              TO wa_hrvalid-seqnr,
                      sy-datum         TO wa_hrvalid-dtreg,
                      sy-uzeit         TO wa_hrvalid-hrreg,
                      wa_itmatr-atitm  TO wa_hrvalid-atitm,
                      'E'              TO wa_hrvalid-vldty,
                      '0010'           TO wa_hrvalid-vldv1,
                      vg_message       TO wa_hrvalid-vldv2,
                      'X'              TO wa_hrvalid-ativo.
                APPEND wa_hrvalid TO p_it_hrvalid.
                CLEAR wa_hrvalid.

              ENDIF.
            ENDIF.

          ELSEIF lt_hist_total[] IS INITIAL.

            TRY .
                lv_calc  = (  ( ls_po_item-over_dlv_tol / 100 )
                                * ls_po_item-quantity ) + ls_po_item-quantity.
              CATCH cx_root.
            ENDTRY.

            IF lv_calc < lv_qtd.
              IF ls_po_item-unlimited_dlv IS INITIAL.
                SELECT SINGLE text grp INTO (vg_message, wa_hrvalid-grp)
                                       FROM zhms_tb_messages WHERE code EQ '0010'.

                MOVE: wa_cabdoc-natdc  TO wa_hrvalid-natdc,
                      wa_cabdoc-typed  TO wa_hrvalid-typed,
                      wa_cabdoc-loctp  TO wa_hrvalid-loctp,
                      wa_cabdoc-chave  TO wa_hrvalid-chave,
                      '1'              TO wa_hrvalid-seqnr,
                      sy-datum         TO wa_hrvalid-dtreg,
                      sy-uzeit         TO wa_hrvalid-hrreg,
                      wa_itmatr-atitm  TO wa_hrvalid-atitm,
                      'E'              TO wa_hrvalid-vldty,
                      '0010'           TO wa_hrvalid-vldv1,
                      vg_message       TO wa_hrvalid-vldv2,
                      'X'              TO wa_hrvalid-ativo.
                APPEND wa_hrvalid TO p_it_hrvalid.
                CLEAR wa_hrvalid.

              ENDIF.
            ENDIF.

          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

*    SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_cabdoc-chave
*                                                         AND mneum EQ 'ATITMPED'
*                                                         AND atitm EQ wa_itmatr-atitm.
*    IF sy-subrc IS INITIAL.
*      SELECT SINGLE value FROM zhms_tb_docmn INTO lv_qtd  WHERE chave EQ wa_cabdoc-chave
*                                                            AND mneum EQ 'QUANTITY'
*                                                            AND atitm EQ wa_itmatr-atitm.
*
*      SELECT SINGLE value FROM zhms_tb_docmn INTO lv_qtrib  WHERE chave EQ wa_cabdoc-chave
*                                                            AND mneum EQ 'QTRIB'
*                                                            AND dcitm EQ wa_itmatr-dcitm.
*
*      SELECT SINGLE wemng FROM eket INTO lv_po_cons  WHERE ebeln EQ lv_ebeln.
*
*      SELECT SINGLE value FROM zhms_tb_docmn INTO lv_atqtde  WHERE chave EQ wa_cabdoc-chave
*                                                    AND mneum EQ 'ATQTDE'
*                                                    AND atitm EQ wa_itmatr-atitm.
*
*      lv_calc = lv_qtd - lv_po_cons.
*
*      IF lv_qtrib > lv_calc.
*        SELECT SINGLE text grp INTO (vg_message, wa_hrvalid-grp) FROM zhms_tb_messages WHERE code EQ '0010'.
*
*        MOVE: wa_cabdoc-natdc  TO wa_hrvalid-natdc,
*              wa_cabdoc-typed  TO wa_hrvalid-typed,
*              wa_cabdoc-loctp  TO wa_hrvalid-loctp,
*              wa_cabdoc-chave  TO wa_hrvalid-chave,
*              '1'              TO wa_hrvalid-seqnr,
*              sy-datum         TO wa_hrvalid-dtreg,
*              sy-uzeit         TO wa_hrvalid-hrreg,
*              wa_itmatr-atitm  TO wa_hrvalid-atitm,
*              'E'              TO wa_hrvalid-vldty,
*              '0010'           TO wa_hrvalid-vldv1,
*              vg_message       TO wa_hrvalid-vldv2,
*              'X'              TO wa_hrvalid-ativo.
*        APPEND wa_hrvalid TO p_it_hrvalid.
*        CLEAR wa_hrvalid.
*      ENDIF.
*      ELSE.
*        IF sy-subrc IS INITIAL.
*
*          READ TABLE lt_po_item INTO ls_po_item WITH KEY po_item  = wa_docmnx-value BINARY SEARCH.
*
*          IF sy-subrc IS INITIAL.
*            READ TABLE  lt_hist_total INTO ls_hist_total WITH KEY po_item = wa_docmnx-value.
*
*            IF sy-subrc IS INITIAL.
*              CLEAR: lv_calc, lv_calc2, lv_calc3, lv_calc4.
*              lv_calc = ( ls_hist_total-deliv_qty + lv_qtd * ( ls_po_item-over_dlv_tol / 100 ) ).
*              lv_calc  = ls_po_item-over_dlv_tol / 100.
*              lv_calc2 = ls_hist_total-deliv_qty + lv_qtd.
*              lv_calc3 = lv_calc + lv_calc2.
*              lv_calc4 = lv_calc3 - ls_hist_total-deliv_qty.
*
*              IF lv_calc4 < lv_atqtde.
*                IF ls_po_item-unlimited_dlv IS INITIAL.
*                  SELECT SINGLE text grp INTO (vg_message, wa_hrvalid-grp) FROM zhms_tb_messages WHERE code EQ '0010'.
*
*                  MOVE: wa_cabdoc-natdc  TO wa_hrvalid-natdc,
*                        wa_cabdoc-typed  TO wa_hrvalid-typed,
*                        wa_cabdoc-loctp  TO wa_hrvalid-loctp,
*                        wa_cabdoc-chave  TO wa_hrvalid-chave,
*                        '1'              TO wa_hrvalid-seqnr,
*                        sy-datum         TO wa_hrvalid-dtreg,
*                        sy-uzeit         TO wa_hrvalid-hrreg,
*                        wa_itmatr-atitm  TO wa_hrvalid-atitm,
*                        'E'              TO wa_hrvalid-vldty,
*                        '0010'           TO wa_hrvalid-vldv1,
*                        vg_message       TO wa_hrvalid-vldv2,
*                        'X'              TO wa_hrvalid-ativo.
*                  APPEND wa_hrvalid TO p_it_hrvalid.
*                  CLEAR wa_hrvalid.
*
*                ENDIF.
*              ENDIF.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*    ENDIF.

*** Validação das condições do pedido de compra
    REFRESH: t_komv[], it_komk[], it_komp[].
    CLEAR: wa_komk, wa_komp.
    PERFORM f_preenche_t_komk.
    PERFORM f_preenche_t_komp.

    CALL FUNCTION 'PRICING'
      EXPORTING
        calculation_type = 'B'
        comm_head_i      = wa_komk
        comm_item_i      = wa_komp
      TABLES
        tkomv            = t_komv.

    IF t_komv[] IS NOT INITIAL.
**********Verifica conversão da Unidade de Medida
********      PERFORM f_converte_qtd USING wa_itmatr
********                          CHANGING lv_param.
********
********      IF v_error EQ 'S'. "Erro na Seleção da Unidade de Medida
********
********        SELECT SINGLE text grp INTO (vg_message, wa_hrvalid-grp) FROM zhms_tb_messages
********                                                                WHERE code EQ '0019'.
********        CLEAR: lv_div_ped_c.
********        MOVE 'ZHMS_UM' TO lv_div_ped_c.
********        CONDENSE: lv_div_ped_c NO-GAPS.
********
********        REPLACE '&1' IN vg_message WITH lv_div_ped_c.
********
********        PERFORM f_mensagem_erro TABLES p_it_hrvalid
********                                 USING vg_message
********                                       '1'        "wa_hrvalid-seqnr
********                                       'E'        "wa_hrvalid-vldty
********                                       '0019'     "wa_hrvalid-vldv1 (Nº mensagem)
********                                       abap_true. "wa_hrvalid-ativo
********
********      ELSEIF v_error EQ 'F'. "Erro na Função de Conversão
********
********        SELECT SINGLE text grp INTO (vg_message, wa_hrvalid-grp) FROM zhms_tb_messages
********                                                                WHERE code EQ '0020'.
********        CLEAR: lv_div_ped_c.
********        MOVE v_matnr TO lv_div_ped_c.
********        CONDENSE: lv_div_ped_c NO-GAPS.
********
********        REPLACE '&1' IN vg_message WITH lv_div_ped_c.
********
********        PERFORM f_mensagem_erro TABLES p_it_hrvalid
********                                 USING vg_message
********                                       '1'        "wa_hrvalid-seqnr
********                                       'E'        "wa_hrvalid-vldty
********                                       '0020'     "wa_hrvalid-vldv1 (Nº mensagem)
********                                       abap_true. "wa_hrvalid-ativo
********      ENDIF.
*--------------------------------------------------------------------*

***RRO 08/02/2019 -->>
      IF wa_ekko-bstyp NE 'L'.
*** Valor do Item do PEDIDO difere do Item do XML
        IF lv_param IS INITIAL.
          CLEAR lv_qcom.
          SELECT SINGLE value FROM zhms_tb_docmn INTO lv_qcom WHERE chave EQ wa_cabdoc-chave
                                                                AND mneum EQ 'QCOM'
                                                                AND dcitm EQ wa_itmatr-dcitm.
          lv_qcom_kwert = lv_qcom.

        ELSE.
          lv_qcom_kwert = lv_param.
        ENDIF.

        TRY .
            CLEAR: lv_totalpo, wa_komv.
            READ TABLE t_komv INTO wa_komv WITH KEY kposn = wa_itmatr-itsrf
                                                    kschl = 'BASB'.
            lv_basb = ( wa_komv-kwert / ls_po_item-quantity ) * lv_qcom_kwert.

            CLEAR wa_komv.
            READ TABLE t_komv INTO wa_komv WITH KEY kposn = wa_itmatr-itsrf
                                                    kschl = 'ICM0'.
            lv_icm0 = ( wa_komv-kwert / ls_po_item-quantity ) * lv_qcom_kwert.

            CLEAR wa_komv.
            READ TABLE t_komv INTO wa_komv WITH KEY kposn = wa_itmatr-itsrf
                                                    kschl = 'ICM1'.
            lv_icm1 = ( wa_komv-kwert / ls_po_item-quantity ) * lv_qcom_kwert.

            CLEAR wa_komv.
            READ TABLE t_komv INTO wa_komv WITH KEY kposn = wa_itmatr-itsrf
                                                    kschl = 'ICM2'.
            lv_icm2 = ( wa_komv-kwert / ls_po_item-quantity ) * lv_qcom_kwert.

            CLEAR wa_komv.
            READ TABLE t_komv INTO wa_komv WITH KEY kposn = wa_itmatr-itsrf
                                                    kschl = 'IPIS'.
            lv_ipis = ( wa_komv-kwert / ls_po_item-quantity ) * lv_qcom_kwert.

            CLEAR wa_komv.
            READ TABLE t_komv INTO wa_komv WITH KEY kposn = wa_itmatr-itsrf
                                                    kschl = 'ICOF'.
            lv_icof = ( wa_komv-kwert / ls_po_item-quantity ) * lv_qcom_kwert.

            CLEAR wa_komv.
            READ TABLE t_komv INTO wa_komv WITH KEY kposn = wa_itmatr-itsrf
                                                    kschl = 'ICON'.
            lv_icon = ( wa_komv-kwert / ls_po_item-quantity ) * lv_qcom_kwert.

            CLEAR wa_komv.
            READ TABLE t_komv INTO wa_komv WITH KEY kposn = wa_itmatr-itsrf
                                                    kschl = 'IPSN'.
            lv_ipsn = ( wa_komv-kwert / ls_po_item-quantity ) * lv_qcom_kwert.

            lv_totalpo = lv_basb + lv_icm0 + lv_icm1 + lv_icm2 +
                         lv_ipis + lv_icof + lv_icon + lv_ipsn.
          CATCH cx_root.
        ENDTRY.

        IF lv_totalpo GT '0.00'.
*** Valor do ICMSVBC por ITEM no XML
          CLEAR lv_qcom.
          SELECT SINGLE value FROM zhms_tb_docmn INTO lv_qcom WHERE chave EQ wa_cabdoc-chave
                                                                AND mneum EQ 'QCOM'
                                                                AND dcitm EQ wa_itmatr-dcitm.
          IF lv_qcom GT '0.00'.
            TRY .
                lv_result = lv_totalpo / lv_qcom_kwert.
              CATCH cx_root.
            ENDTRY.

            CLEAR: lv_vuncom, lv_difere.
            SELECT SINGLE value FROM zhms_tb_docmn INTO lv_vuncom WHERE chave EQ wa_cabdoc-chave
                                                                    AND mneum EQ 'VUNCOM'
                                                                    AND dcitm EQ wa_itmatr-dcitm.
            IF lv_vuncom GT '0.00'.
              lv_ucom_kwert = lv_vuncom.
              TRY .
                  IF lv_result GT lv_ucom_kwert.
                    lv_difere = lv_result - lv_ucom_kwert.
                  ELSEIF lv_result LT lv_ucom_kwert.
                    lv_difere = lv_ucom_kwert - lv_result.
                  ENDIF.
                CATCH cx_root.
              ENDTRY.
            ENDIF.

            IF lv_difere GT '0.10'.
              SELECT SINGLE text grp INTO (vg_message, wa_hrvalid-grp) FROM zhms_tb_messages
                                                                      WHERE code EQ '0018'.
              CLEAR: lv_div_ped_c, lv_div_xml_c, lv_div_item.
              MOVE wa_itmatr-itsrf TO lv_div_item.
              MOVE lv_ucom_kwert TO lv_div_xml_c.
              MOVE lv_result TO lv_div_ped_c.

              CONDENSE: lv_div_ped_c NO-GAPS.
              CONDENSE: lv_div_xml_c NO-GAPS.
              CONDENSE: lv_div_item NO-GAPS.

              REPLACE '&1' IN vg_message WITH lv_div_ped_c.
              REPLACE '&2' IN vg_message WITH lv_div_item.
              REPLACE '&3' IN vg_message WITH lv_div_xml_c.

**********              PERFORM f_mensagem_erro TABLES p_it_hrvalid
**********                                       USING vg_message
**********                                             '1'        "wa_hrvalid-seqnr
**********                                             'E'        "wa_hrvalid-vldty
**********                                             '0018'     "wa_hrvalid-vldv1 (Nº mensagem)
**********                                             abap_true. "wa_hrvalid-ativo

            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
*--------------------------------------------------------------------*
***RRO 08/02/2019 <<--

      SELECT *
        FROM j_1baj
        INTO TABLE t_1baj
        FOR ALL ENTRIES IN t_komv
       WHERE taxtyp = t_komv-kschl
         AND taxgrp = 'ICMS'.

      CLEAR lv_tot_kbetr.
      LOOP AT t_1baj INTO wa_1baj.
        LOOP AT t_komv INTO wa_komv WHERE kschl EQ wa_1baj-taxtyp.
          lv_tot_kbetr = lv_tot_kbetr + wa_komv-kawrt.
        ENDLOOP.
      ENDLOOP.

      CLEAR lv_qtd .
      SELECT SINGLE value FROM zhms_tb_docmn INTO lv_qtd  WHERE chave EQ wa_cabdoc-chave
                                                            AND mneum EQ 'QUANTITY'
                                                            AND atitm EQ wa_itmatr-atitm.
      IF sy-subrc IS INITIAL.
*** Valor unitário do ICMS no Pedido
        TRY .
            lv_div_ped = lv_tot_kbetr / lv_qtd.
*            lv_div_ped = lv_tot_kbetr.
          CATCH cx_sy_zerodivide.
        ENDTRY.

*** Valor unitário do ICMS no XML
        CLEAR lv_icms.
        SELECT SINGLE value FROM zhms_tb_docmn INTO lv_icms WHERE chave EQ wa_cabdoc-chave
                                                              AND mneum EQ 'ATVICMS'
                                                              AND atitm EQ wa_itmatr-atitm.

        CLEAR lv_qtd_at .
        SELECT SINGLE value FROM zhms_tb_docmn INTO lv_qtd_at WHERE chave EQ wa_cabdoc-chave
                                                                AND mneum EQ 'ATQTDE'
                                                                AND atitm EQ wa_itmatr-atitm.

        IF sy-subrc IS INITIAL.
          TRY .
              lv_div_xml = lv_icms / lv_qtd_at.
            CATCH cx_sy_zerodivide.
          ENDTRY.

*          CHECK wa_cabdoc-typed NE 'NFE1'. "Rogerio 17/12/2018
*          CHECK wa_cabdoc-typed NE 'NFE3'. "Rogerio 19/12/2018
*** Validar se o Valor unitário do ICMS no Pedido <> Valor unitário do ICMS no XML.
          READ TABLE t_tb_vld_tax INTO ls_tb_vld_tax WITH KEY tax_type = 'ICMS'.

          IF lv_div_ped NE lv_div_xml AND ls_tb_vld_tax-ativo IS NOT INITIAL.
            CLEAR lv_sub.
            lv_sub = lv_div_ped - lv_div_xml.
            IF lv_sub < 0.
              lv_sub = lv_sub * -1.
            ENDIF.
            IF lv_sub > lv_dif.

              SELECT SINGLE text grp INTO (vg_message, wa_hrvalid-grp) FROM zhms_tb_messages WHERE code EQ '0011'.
              CLEAR: lv_div_ped_c, lv_div_xml_c.
              MOVE: lv_div_ped TO lv_div_ped_c,
                    lv_div_xml TO lv_div_xml_c.
              CONDENSE: lv_div_xml_c, lv_div_ped_c NO-GAPS.
              REPLACE '&1' IN vg_message WITH lv_div_xml_c.
              REPLACE '&2' IN vg_message WITH lv_div_ped_c.

              MOVE: wa_cabdoc-natdc  TO wa_hrvalid-natdc,
                    wa_cabdoc-typed  TO wa_hrvalid-typed,
                    wa_cabdoc-loctp  TO wa_hrvalid-loctp,
                    wa_cabdoc-chave  TO wa_hrvalid-chave,
                    '1'              TO wa_hrvalid-seqnr,
                    sy-datum         TO wa_hrvalid-dtreg,
                    sy-uzeit         TO wa_hrvalid-hrreg,
                    wa_itmatr-atitm  TO wa_hrvalid-atitm,
                    'E'              TO wa_hrvalid-vldty,
                    '0011'       TO wa_hrvalid-vldv1,
                    vg_message       TO wa_hrvalid-vldv2,
                    'X'              TO wa_hrvalid-ativo.
              APPEND wa_hrvalid TO p_it_hrvalid.
              CLEAR wa_hrvalid.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

*** Valor do IPI do XML difere do pedido de compra
      REFRESH t_1baj[].
      SELECT *
        FROM j_1baj
        INTO TABLE t_1baj
        FOR ALL ENTRIES IN t_komv
       WHERE taxtyp = t_komv-kschl
         AND taxgrp = 'IPI'.

      CLEAR lv_tot_kbetr .
*          IF sy-subrc IS INITIAL.
      LOOP AT t_1baj INTO wa_1baj.
        LOOP AT t_komv INTO wa_komv WHERE kschl EQ wa_1baj-taxtyp.
          lv_tot_kbetr = lv_tot_kbetr + wa_komv-kawrt.
        ENDLOOP.
      ENDLOOP.

*** Valor unitário do IPI no Pedido
      CLEAR lv_div_ped .
      TRY .
          lv_div_ped = lv_tot_kbetr / lv_qtd.
*          lv_div_ped = lv_tot_kbetr.
        CATCH cx_sy_zerodivide.
      ENDTRY.

*** Valor unitário do IPI no XML
      CLEAR lv_ipi.
      SELECT SINGLE value FROM zhms_tb_docmn INTO lv_ipi  WHERE chave EQ wa_cabdoc-chave
                                                            AND mneum EQ 'ATVIPI'
                                                            AND atitm EQ wa_itmatr-atitm.

      IF sy-subrc IS INITIAL.
        CLEAR lv_div_xml.
        TRY .
            lv_div_xml = lv_ipi / lv_qtd_at.
          CATCH  cx_sy_zerodivide.
        ENDTRY.

        READ TABLE t_tb_vld_tax INTO ls_tb_vld_tax WITH KEY tax_type = 'IPI'.

        IF lv_div_ped NE lv_div_xml AND ls_tb_vld_tax-ativo IS NOT INITIAL.
          CLEAR lv_sub.
          lv_sub = lv_div_ped - lv_div_xml.
          IF lv_sub < 0.
            lv_sub = lv_sub * -1.
          ENDIF.
          IF lv_sub > lv_dif.

            SELECT SINGLE text grp INTO (vg_message, wa_hrvalid-grp) FROM zhms_tb_messages WHERE code EQ '0012'.
            CLEAR: lv_div_ped_c, lv_div_xml_c.
            MOVE: lv_div_ped TO lv_div_ped_c,
                  lv_div_xml TO lv_div_xml_c.
            CONDENSE: lv_div_xml_c, lv_div_ped_c NO-GAPS.
            REPLACE '&1' IN vg_message WITH lv_div_xml_c.
            REPLACE '&2' IN vg_message WITH lv_div_ped_c.

            MOVE: wa_cabdoc-natdc  TO wa_hrvalid-natdc,
                  wa_cabdoc-typed  TO wa_hrvalid-typed,
                  wa_cabdoc-loctp  TO wa_hrvalid-loctp,
                  wa_cabdoc-chave  TO wa_hrvalid-chave,
                  '1'              TO wa_hrvalid-seqnr,
                  sy-datum         TO wa_hrvalid-dtreg,
                  sy-uzeit         TO wa_hrvalid-hrreg,
                  wa_itmatr-atitm  TO wa_hrvalid-atitm,
                  'E'              TO wa_hrvalid-vldty,
                  '0012'           TO wa_hrvalid-vldv1,
                  vg_message       TO wa_hrvalid-vldv2,
                  'X'              TO wa_hrvalid-ativo.
            APPEND wa_hrvalid TO p_it_hrvalid.
            CLEAR wa_hrvalid.
          ENDIF.
        ENDIF.
      ENDIF.
*
*** Valor do PIS do XML difere do pedido de compra
      REFRESH t_1baj[].
      SELECT *
        FROM j_1baj
        INTO TABLE t_1baj
        FOR ALL ENTRIES IN t_komv
       WHERE taxtyp = t_komv-kschl
         AND taxgrp = 'PIS'.

      CLEAR: lv_cont_1baj, lv_tot_kbetr .
*          IF sy-subrc IS INITIAL.
      LOOP AT t_1baj INTO wa_1baj.
        LOOP AT t_komv INTO wa_komv WHERE kschl EQ wa_1baj-taxtyp.
          lv_tot_kbetr = lv_tot_kbetr + wa_komv-kawrt.
          IF wa_komv-kawrt IS NOT INITIAL.
            ADD 1 TO lv_cont_1baj.
          ENDIF.
        ENDLOOP.
      ENDLOOP.

*** Valor unitário do PIS no Pedido
      CLEAR lv_div_ped .
      TRY .
          lv_div_ped = lv_tot_kbetr / lv_cont_1baj.
          lv_div_ped = lv_div_ped / lv_qtd.
*          lv_div_ped = lv_tot_kbetr.
        CATCH  cx_sy_zerodivide.
      ENDTRY.

*** Valor unitário do PIS no XML
      CLEAR lv_pis.
      SELECT SINGLE value FROM zhms_tb_docmn INTO lv_pis  WHERE chave EQ wa_cabdoc-chave
                                                            AND mneum EQ 'ATVPIS'
                                                            AND atitm EQ wa_itmatr-atitm.

      IF sy-subrc IS INITIAL.
        CLEAR lv_div_xml.
        TRY .
            lv_div_xml = lv_pis / lv_qtd_at.
          CATCH cx_sy_zerodivide.
        ENDTRY.

        READ TABLE t_tb_vld_tax INTO ls_tb_vld_tax WITH KEY tax_type = 'PIS'.

        IF lv_div_ped NE lv_div_xml AND ls_tb_vld_tax-ativo IS NOT INITIAL.
          CLEAR lv_sub.
          lv_sub = lv_div_ped - lv_div_xml.
          IF lv_sub < 0.
            lv_sub = lv_sub * -1.
          ENDIF.
          IF lv_sub > lv_dif.
            SELECT SINGLE text grp INTO (vg_message, wa_hrvalid-grp) FROM zhms_tb_messages WHERE code EQ '0013'.
            CLEAR: lv_div_ped_c, lv_div_xml_c.
            MOVE: lv_div_ped TO lv_div_ped_c,
                  lv_div_xml TO lv_div_xml_c.
            CONDENSE: lv_div_xml_c, lv_div_ped_c NO-GAPS.
            REPLACE '&1' IN vg_message WITH lv_div_xml_c.
            REPLACE '&2' IN vg_message WITH lv_div_ped_c.

            MOVE: wa_cabdoc-natdc  TO wa_hrvalid-natdc,
                  wa_cabdoc-typed  TO wa_hrvalid-typed,
                  wa_cabdoc-loctp  TO wa_hrvalid-loctp,
                  wa_cabdoc-chave  TO wa_hrvalid-chave,
                  '1'              TO wa_hrvalid-seqnr,
                  sy-datum         TO wa_hrvalid-dtreg,
                  sy-uzeit         TO wa_hrvalid-hrreg,
                  wa_itmatr-atitm  TO wa_hrvalid-atitm,
                  'E'              TO wa_hrvalid-vldty,
                  '0013'           TO wa_hrvalid-vldv1,
                  vg_message       TO wa_hrvalid-vldv2,
                  'X'              TO wa_hrvalid-ativo.
            APPEND wa_hrvalid TO p_it_hrvalid.
            CLEAR wa_hrvalid.
          ENDIF.
        ENDIF.
      ENDIF.

*** Valor do Cofins do XML difere do pedido de compra
      REFRESH t_1baj[].
      SELECT *
        FROM j_1baj
        INTO TABLE t_1baj
        FOR ALL ENTRIES IN t_komv
       WHERE taxtyp = t_komv-kschl
         AND taxgrp = 'COFI'.

      CLEAR lv_tot_kbetr .
*          IF sy-subrc IS INITIAL.
      CLEAR lv_cont_1baj.
      LOOP AT t_1baj INTO wa_1baj.
        LOOP AT t_komv INTO wa_komv WHERE kschl EQ wa_1baj-taxtyp.
          lv_tot_kbetr = lv_tot_kbetr + wa_komv-kawrt.
          IF wa_komv-kawrt IS NOT INITIAL.
            ADD 1 TO lv_cont_1baj.
          ENDIF.
        ENDLOOP.
      ENDLOOP.

*** Valor unitário do COFINS no Pedido
      CLEAR lv_div_ped .
      TRY .
*          lv_div_ped = lv_tot_kbetr * lv_qtd.
          lv_div_ped = lv_tot_kbetr / lv_cont_1baj.
          lv_div_ped = lv_div_ped / lv_qtd_at.
        CATCH  cx_sy_zerodivide.
      ENDTRY.

*** Valor unitário do COFINS no XML
      CLEAR lv_cof.
      SELECT SINGLE value FROM zhms_tb_docmn INTO lv_cof WHERE chave EQ wa_cabdoc-chave
                                                           AND mneum EQ 'ATVCOFINS'
                                                           AND atitm EQ wa_itmatr-atitm.

      IF sy-subrc IS INITIAL.
        CLEAR lv_div_xml.
        TRY .
            lv_div_xml = lv_cof / lv_qtd_at.
          CATCH  cx_sy_zerodivide.
        ENDTRY.

        READ TABLE t_tb_vld_tax INTO ls_tb_vld_tax WITH KEY tax_type = 'COFINS'.

        IF lv_div_ped NE lv_div_xml AND ls_tb_vld_tax-ativo IS NOT INITIAL.
          CLEAR lv_sub.
          lv_sub = lv_div_ped - lv_div_xml.
          IF lv_sub < 0.
            lv_sub = lv_sub * -1.
          ENDIF.
          IF lv_sub > lv_dif.
            SELECT SINGLE text grp INTO (vg_message, wa_hrvalid-grp) FROM zhms_tb_messages WHERE code EQ '0014'.
            CLEAR: lv_div_ped_c, lv_div_xml_c.
            MOVE: lv_div_ped TO lv_div_ped_c,
                  lv_div_xml TO lv_div_xml_c.
            CONDENSE: lv_div_xml_c, lv_div_ped_c NO-GAPS.
            REPLACE '&1' IN vg_message WITH lv_div_xml_c.
            REPLACE '&2' IN vg_message WITH lv_div_ped_c.

            MOVE: wa_cabdoc-natdc  TO wa_hrvalid-natdc,
                  wa_cabdoc-typed  TO wa_hrvalid-typed,
                  wa_cabdoc-loctp  TO wa_hrvalid-loctp,
                  wa_cabdoc-chave  TO wa_hrvalid-chave,
                  '1'              TO wa_hrvalid-seqnr,
                  sy-datum         TO wa_hrvalid-dtreg,
                  sy-uzeit         TO wa_hrvalid-hrreg,
                  wa_itmatr-atitm  TO wa_hrvalid-atitm,
                  'E'              TO wa_hrvalid-vldty,
                  '0014'           TO wa_hrvalid-vldv1,
                  vg_message       TO wa_hrvalid-vldv2,
                  'X'              TO wa_hrvalid-ativo.
            APPEND wa_hrvalid TO p_it_hrvalid.
            CLEAR wa_hrvalid.
          ENDIF.
        ENDIF.
      ENDIF.

*** Valor do ISS do XML difere do pedido de compra
      REFRESH t_1baj[].
      SELECT *
        FROM j_1baj
        INTO TABLE t_1baj
        FOR ALL ENTRIES IN t_komv
       WHERE taxtyp = t_komv-kschl
         AND taxgrp = 'ISS'.

      CLEAR lv_tot_kbetr .
*          IF sy-subrc IS INITIAL.
      LOOP AT t_1baj INTO wa_1baj.
        LOOP AT t_komv INTO wa_komv WHERE kschl EQ wa_1baj-taxtyp.
          lv_tot_kbetr = lv_tot_kbetr + wa_komv-kawrt.
        ENDLOOP.
      ENDLOOP.

*** Valor unitário do ISS no Pedido
      CLEAR lv_div_ped .
      TRY .
          lv_div_ped = lv_tot_kbetr / lv_qtd.
        CATCH cx_sy_zerodivide.
      ENDTRY.

*** Valor unitário do ISS no XML
      CLEAR lv_sqn.
      SELECT SINGLE value FROM zhms_tb_docmn INTO lv_sqn WHERE chave EQ wa_cabdoc-chave
                                                           AND mneum EQ 'ATVISSQN'
                                                           AND atitm EQ wa_itmatr-atitm.
      IF sy-subrc IS INITIAL.
        CLEAR lv_div_xml.
        lv_div_xml = lv_sqn / lv_qtd_at.

        READ TABLE t_tb_vld_tax INTO ls_tb_vld_tax WITH KEY tax_type = 'ISS'.

        IF lv_div_ped NE lv_div_xml AND ls_tb_vld_tax-ativo IS NOT INITIAL.
          CLEAR lv_sub.
          lv_sub = lv_div_ped - lv_div_xml.
          IF lv_sub < 0.
            lv_sub = lv_sub * -1.
          ENDIF.
          IF lv_sub > lv_dif.
            SELECT SINGLE text grp INTO (vg_message, wa_hrvalid-grp) FROM zhms_tb_messages WHERE code EQ '0015'.
            CLEAR: lv_div_ped_c, lv_div_xml_c.
            MOVE: lv_div_ped TO lv_div_ped_c,
                  lv_div_xml TO lv_div_xml_c.
            CONDENSE: lv_div_xml_c, lv_div_ped_c NO-GAPS.
            REPLACE '&1' IN vg_message WITH lv_div_xml_c.
            REPLACE '&2' IN vg_message WITH lv_div_ped_c.

            MOVE: wa_cabdoc-natdc  TO wa_hrvalid-natdc,
                  wa_cabdoc-typed  TO wa_hrvalid-typed,
                  wa_cabdoc-loctp  TO wa_hrvalid-loctp,
                  wa_cabdoc-chave  TO wa_hrvalid-chave,
                  '1'              TO wa_hrvalid-seqnr,
                  sy-datum         TO wa_hrvalid-dtreg,
                  sy-uzeit         TO wa_hrvalid-hrreg,
                  wa_itmatr-atitm  TO wa_hrvalid-atitm,
                  'E'              TO wa_hrvalid-vldty,
                  '0015'           TO wa_hrvalid-vldv1,
                  vg_message       TO wa_hrvalid-vldv2,
                  'X'              TO wa_hrvalid-ativo.
            APPEND wa_hrvalid TO p_it_hrvalid.
            CLEAR wa_hrvalid.
          ENDIF.
        ENDIF.
      ENDIF.

*** Valor do ICMSST do XML difere do pedido de compra
      REFRESH t_1baj[].
      SELECT *
        FROM j_1baj
        INTO TABLE t_1baj
        FOR ALL ENTRIES IN t_komv
       WHERE taxtyp = t_komv-kschl
         AND taxgrp = 'ICST'.

      CLEAR lv_tot_kbetr .
*          IF sy-subrc IS INITIAL.
      LOOP AT t_1baj INTO wa_1baj.
        LOOP AT t_komv INTO wa_komv WHERE kschl EQ wa_1baj-taxtyp.
          lv_tot_kbetr = lv_tot_kbetr + wa_komv-kawrt.
        ENDLOOP.
      ENDLOOP.

*** Valor unitário do ICST no Pedido
      CLEAR lv_div_ped .
      TRY .
          lv_div_ped = lv_tot_kbetr / lv_qtd.
        CATCH cx_sy_zerodivide .
      ENDTRY.
*** Valor unitário do ICST no XML
      CLEAR lv_sst.
      SELECT SINGLE value FROM zhms_tb_docmn INTO lv_sst  WHERE chave EQ wa_cabdoc-chave
                                                            AND mneum EQ 'ATVICMSST'
                                                            AND atitm EQ wa_itmatr-atitm.

      IF sy-subrc IS INITIAL.
        CLEAR lv_div_xml.
        TRY .
            lv_div_xml = lv_sst / lv_qtd_at.
          CATCH cx_sy_zerodivide.
        ENDTRY.

        READ TABLE t_tb_vld_tax INTO ls_tb_vld_tax WITH KEY tax_type = 'ICMSST'.

        IF lv_div_ped NE lv_div_xml AND ls_tb_vld_tax-ativo IS NOT INITIAL.
          CLEAR lv_sub.
          lv_sub = lv_div_ped - lv_div_xml.
          IF lv_sub < 0.
            lv_sub = lv_sub * -1.
          ENDIF.
          IF lv_sub > lv_dif.
            SELECT SINGLE text grp INTO (vg_message, wa_hrvalid-grp) FROM zhms_tb_messages WHERE code EQ '0016'.
            CLEAR: lv_div_ped_c, lv_div_xml_c.
            MOVE: lv_div_ped TO lv_div_ped_c,
                  lv_div_xml TO lv_div_xml_c.
            CONDENSE: lv_div_xml_c, lv_div_ped_c NO-GAPS.
            REPLACE '&1' IN vg_message WITH lv_div_xml_c.
            REPLACE '&2' IN vg_message WITH lv_div_ped_c.

            MOVE: wa_cabdoc-natdc  TO wa_hrvalid-natdc,
                  wa_cabdoc-typed  TO wa_hrvalid-typed,
                  wa_cabdoc-loctp  TO wa_hrvalid-loctp,
                  wa_cabdoc-chave  TO wa_hrvalid-chave,
                  '1'              TO wa_hrvalid-seqnr,
                  sy-datum         TO wa_hrvalid-dtreg,
                  sy-uzeit         TO wa_hrvalid-hrreg,
                  wa_itmatr-atitm  TO wa_hrvalid-atitm,
                  'E'              TO wa_hrvalid-vldty,
                  '0016'           TO wa_hrvalid-vldv1,
                  vg_message       TO wa_hrvalid-vldv2,
                  'X'              TO wa_hrvalid-ativo.
            APPEND wa_hrvalid TO p_it_hrvalid.
            CLEAR wa_hrvalid.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.



    IF vg_message IS NOT INITIAL. " Armazena Log de validações

*** Verifica se mensagens ainda são necessarias
      DATA  lt_hrvalid TYPE STANDARD TABLE OF zhms_tb_hrvalid .
      SELECT * FROM zhms_tb_hrvalid INTO TABLE lt_hrvalid WHERE chave EQ  wa_cabdoc-chave
                                                            AND ativo EQ abap_true.

      IF sy-subrc IS INITIAL.
        LOOP AT  lt_hrvalid INTO wa_hrvalid.

          READ TABLE  p_it_hrvalid INTO wa_hrvalid WITH KEY natdc = wa_hrvalid-natdc
                                                            typed = wa_hrvalid-typed
                                                            chave = wa_hrvalid-chave
                                                            atitm = wa_hrvalid-atitm
                                                            dtreg = wa_hrvalid-dtreg
                                                            vldv1 = wa_hrvalid-vldv1
                                                            grp   = wa_hrvalid-grp.

          IF sy-subrc IS NOT INITIAL.

            UPDATE zhms_tb_hrvalid
            SET ativo = ' '
            WHERE natdc = wa_hrvalid-natdc
              AND typed = wa_hrvalid-typed
              AND chave = wa_hrvalid-chave
              AND atitm = wa_hrvalid-atitm
              AND dtreg = wa_hrvalid-dtreg
              AND vldv1 = wa_hrvalid-vldv1
              AND grp   = wa_hrvalid-grp.

            IF sy-subrc IS INITIAL.
              COMMIT WORK.
            ELSE.
              ROLLBACK WORK.
            ENDIF.
          ENDIF.

        ENDLOOP.
      ENDIF.
    ELSE.

      UPDATE zhms_tb_hrvalid
         SET ativo = ' '
         WHERE chave = wa_docmn-chave
           AND atitm = wa_itmatr-atitm.

      IF sy-subrc IS INITIAL.
        COMMIT WORK.
      ELSE.
        ROLLBACK WORK.
      ENDIF.
    ENDIF.
  ENDLOOP.



ENDFORM.                    "f_entradanormal_atr
*&---------------------------------------------------------------------*
*&      Form  F_PREENCHE_T_KOMV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_preenche_t_komk.

  REFRESH it_docmnx.
  SELECT * FROM zhms_tb_docmn INTO TABLE it_docmnx  WHERE chave EQ wa_cabdoc-chave AND
                                                         ( atitm EQ wa_itmatr-atitm OR
                                                          atitm EQ '00000' ).
*                                                           mneum EQ 'VATCNTRY'   OR
*                                                          mneum EQ 'COMPCODE'   OR
*                                                          mneum EQ 'CURRENCY'   OR
*                                                          mneum EQ 'DIFFINV'    OR
*                                                          mneum EQ 'TX'         OR
*                                                          mneum EQ 'TAXBRA'     OR
*                                                          mneum EQ 'CREATEDATE' OR
*                                                          mneum EQ 'TAXJURCODE' OR
*                                                          mneum EQ 'PURCHORG'   OR
*                                                          mneum EQ 'COAREA'     OR
*                                                          mneum EQ 'COSTCENTER' OR
*                                                          mneum EQ 'TAXCODE'    OR
*                                                          atitm EQ wa_itmatr-atitm.

  IF sy-subrc IS INITIAL AND it_docmnx[] IS NOT INITIAL.

    MOVE: sy-mandt TO wa_komk-mandt.
    CLEAR wa_docmn.
    READ TABLE it_docmnx  INTO wa_docmn WITH KEY mneum = 'VATCNTRY' chave = wa_cabdoc-chave.

    IF sy-subrc IS INITIAL.
      MOVE wa_docmn-value TO wa_komk-aland.
    ENDIF.

    CLEAR wa_docmn.
    READ TABLE it_docmnx  INTO wa_docmn WITH KEY mneum = 'COMPCODE' chave = wa_cabdoc-chave.

    IF sy-subrc IS INITIAL.
      MOVE wa_docmn-value TO wa_komk-bukrs.
    ENDIF.

    CLEAR wa_docmn.
    READ TABLE it_docmnx  INTO wa_docmn WITH KEY mneum = 'CURRENCY' chave = wa_cabdoc-chave.

    IF sy-subrc IS INITIAL.
      MOVE wa_docmn-value TO wa_komk-waerk.
    ENDIF.

    CLEAR wa_docmn.
    READ TABLE it_docmnx  INTO wa_docmn WITH KEY mneum = 'DIFFINV' chave = wa_cabdoc-chave.

    IF sy-subrc IS INITIAL.
      MOVE wa_docmn-value TO wa_komk-lifnr.
    ENDIF.

    MOVE 'TX'     TO wa_komk-kappl.
    MOVE 'TAXBRA' TO wa_komk-kalsm.

    CLEAR wa_docmn.
    READ TABLE it_docmnx  INTO wa_docmn WITH KEY mneum = 'CREATEDATE' chave = wa_cabdoc-chave.

    IF sy-subrc IS INITIAL.
      MOVE wa_docmn-value TO wa_komk-prsdt.
    ENDIF.

    CLEAR wa_docmn.
    READ TABLE it_docmnx  INTO wa_docmn WITH KEY mneum = 'TAXJURCODE' chave = wa_cabdoc-chave.

    IF sy-subrc IS INITIAL.
      MOVE wa_docmn-value TO wa_komk-txjcd.
    ENDIF.

    CLEAR wa_docmn.
    READ TABLE it_docmnx  INTO wa_docmn WITH KEY mneum = 'PURCHORG' chave = wa_cabdoc-chave.

    IF sy-subrc IS INITIAL.
      MOVE wa_docmn-value TO wa_komk-ekorg.
    ENDIF.

    CLEAR wa_docmn.
    READ TABLE it_docmnx INTO wa_docmn WITH KEY mneum = 'COAREA' chave = wa_cabdoc-chave.

    IF sy-subrc IS INITIAL.
      MOVE wa_docmn-value TO wa_komk-kokrs.
    ENDIF.

    CLEAR wa_docmn.
    READ TABLE it_docmnx  INTO wa_docmn WITH KEY mneum = 'COSTCENTER' chave = wa_cabdoc-chave.

    IF sy-subrc IS INITIAL.
      MOVE wa_docmn-value TO wa_komk-kostl.
    ENDIF.

    CLEAR wa_docmn.
    READ TABLE it_docmnx  INTO wa_docmn WITH KEY mneum = 'TAXCODE' chave = wa_cabdoc-chave.

    IF sy-subrc IS INITIAL.
      MOVE wa_docmn-value TO wa_komk-mwskz.
    ENDIF.

    APPEND wa_komk TO it_komk.

  ENDIF.

ENDFORM.                    " F_PREENCHE_T_KOMV
*&---------------------------------------------------------------------*
*&      Form  F_PREENCHE_T_KOMP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_preenche_t_komp.

  REFRESH it_docmnx[].
  SELECT * FROM zhms_tb_docmn INTO TABLE it_docmnx  WHERE chave EQ wa_cabdoc-chave AND
                                                          ( atitm EQ wa_itmatr-atitm OR
                                                            atitm EQ '00000' ).
*                                                         mneum EQ 'ATITMPED'   OR
*                                                         mneum EQ 'MATERIAL'   OR
*                                                         mneum EQ 'PLANT'      OR
*                                                         mneum EQ 'TAXJURCODE' OR
*                                                         mneum EQ 'MATLGROUP'  OR
*                                                         mneum EQ 'ENRYUOMISO' OR
*                                                         mneum EQ 'ATQTDE'     OR
*                                                         mneum EQ 'NETPRICE'   OR
*                                                         mneum EQ 'TAXCODE'    OR
*                                                         mneum EQ 'ATPED'      OR
*                                                         mneum EQ 'ATITMPED'   OR
*                                                         mneum EQ 'MATLUSAGE'  OR
*                                                         mneum EQ 'MATORIGIN'  OR
*                                                         mneum EQ 'NCM'.


  IF sy-subrc IS INITIAL AND it_docmnx[] IS NOT INITIAL.

    CLEAR wa_docmn.
    READ TABLE it_docmnx INTO wa_docmn WITH KEY mneum = 'ATITMPED'
                                                dcitm = wa_itmatr-dcitm.

    IF sy-subrc IS INITIAL.
      MOVE wa_docmn-value TO wa_komp-kposn.
    ENDIF.

    CLEAR wa_docmn.
    READ TABLE it_docmnx INTO wa_docmn WITH KEY mneum = 'MATERIAL'
                                                dcitm = wa_itmatr-dcitm.

    IF sy-subrc IS INITIAL.
      MOVE wa_docmn-value TO wa_komp-matnr.
    ENDIF.

    CLEAR wa_docmn.
    READ TABLE it_docmnx INTO wa_docmn WITH KEY mneum = 'PLANT'
                                                dcitm = wa_itmatr-dcitm.

    IF sy-subrc IS INITIAL.
      MOVE wa_docmn-value TO wa_komp-werks.
    ENDIF.

    CLEAR wa_docmn.
    READ TABLE it_docmnx INTO wa_docmn WITH KEY mneum = 'TAXJURCODE'
                                                dcitm = wa_itmatr-dcitm.

    IF sy-subrc IS INITIAL.
      MOVE: wa_docmn-value(2) TO wa_komp-wkreg,
*            wa_docmn-value(2) TO wa_komp-txreg_sf,
            wa_docmn-value(2) TO wa_komp-txreg_st,
*            wa_docmn-value    TO wa_komp-loc_pr,
            wa_docmn-value    TO wa_komp-loc_se,
            wa_docmn-value    TO wa_komp-loc_sr.
    ENDIF.

***14/12 Rogério -->>
    CLEAR wa_docmn.
    READ TABLE it_docmnx INTO wa_docmn WITH KEY mneum = 'UF'.
    IF sy-subrc IS INITIAL.
      MOVE wa_docmn-value TO wa_komp-txreg_sf.
    ENDIF.

    CLEAR wa_docmn.
    READ TABLE it_docmnx INTO wa_docmn WITH KEY mneum = 'CMUN'.
    IF sy-subrc IS INITIAL.
      CONCATENATE wa_komp-txreg_sf wa_docmn-value
             INTO wa_komp-loc_pr SEPARATED BY space.
    ENDIF.
***14/12 Rogério <<--

    CLEAR wa_docmn.
    READ TABLE it_docmnx INTO wa_docmn WITH KEY mneum = 'MATLGROUP'
                                                dcitm = wa_itmatr-dcitm.
    IF sy-subrc IS INITIAL.
      MOVE wa_docmn-value TO wa_komp-matkl.
    ENDIF.

    CLEAR wa_docmn.
    READ TABLE it_docmnx INTO wa_docmn WITH KEY mneum = 'ENRYUOMISO'
                                                dcitm = wa_itmatr-dcitm.

    IF sy-subrc IS INITIAL.
      MOVE: wa_docmn-value TO wa_komp-meins,
            wa_docmn-value TO wa_komp-vrkme.
    ENDIF.

    CLEAR wa_docmn.
    READ TABLE it_docmnx INTO wa_docmn WITH KEY mneum = 'ATQTDE'
                                                dcitm = wa_itmatr-dcitm.

    IF sy-subrc IS INITIAL.
      MOVE: wa_docmn-value TO wa_komp-mglme,
            wa_docmn-value TO wa_komp-mgame.
    ENDIF.

***Ajuste Pricing 14/12 Rogério -->>
    CLEAR wa_docmn.
    READ TABLE it_docmnx INTO wa_docmn WITH KEY mneum = 'VICMS'.
    IF sy-subrc IS INITIAL.
      MOVE wa_docmn-value TO wa_komp-mwsbp.
    ENDIF.

    CLEAR wa_docmn.
    READ TABLE it_docmnx INTO wa_docmn WITH KEY mneum = 'ICMSVBC'.
    IF sy-subrc IS INITIAL.
      MOVE wa_docmn-value TO wa_komp-kzwi1.
    ENDIF.
*** <<--

    CLEAR wa_docmn.
    READ TABLE it_docmnx INTO wa_docmn WITH KEY mneum = 'NETPRICE'
                                                dcitm = wa_itmatr-dcitm.

    IF sy-subrc IS INITIAL.
      MOVE wa_docmn-value TO wa_komp-wrbtr.
    ENDIF.

    CLEAR wa_docmn.
    READ TABLE it_docmnx INTO wa_docmn WITH KEY mneum = 'TAXCODE'
                                                dcitm = wa_itmatr-dcitm.

    IF sy-subrc IS INITIAL.
      MOVE wa_docmn-value TO wa_komp-mwskz.
    ENDIF.

    CLEAR wa_docmn.
    READ TABLE it_docmnx INTO wa_docmn WITH KEY mneum = 'ATPED'
                                                dcitm = wa_itmatr-dcitm.
    IF sy-subrc IS INITIAL.
      MOVE wa_docmn-value TO wa_komp-evrtn.
    ENDIF.

***24/12 Rogério-->>
    CLEAR wa_docmn.
    SELECT SINGLE aedat FROM ekpo INTO wa_komp-kursk_dat
            WHERE ebeln EQ wa_komp-evrtn.
***24/12 Rogério<<--

    CLEAR wa_docmn.
    READ TABLE it_docmnx INTO wa_docmn WITH KEY mneum = 'ATITMPED'
                                                dcitm = wa_itmatr-dcitm.
    IF sy-subrc IS INITIAL.
      MOVE wa_docmn-value TO wa_komp-evrtp.
    ENDIF.

    SELECT SINGLE mtart FROM mara INTO wa_komp-mtart
            WHERE matnr EQ wa_komp-matnr.

    CLEAR wa_docmn.
    READ TABLE it_docmnx INTO wa_docmn WITH KEY mneum = 'MATLUSAGE'
                                                dcitm = wa_itmatr-dcitm.
    IF sy-subrc IS INITIAL.
      MOVE: wa_docmn-value TO wa_komp-mtuse,
            wa_docmn-value TO wa_komp-mtuse_marc.
    ENDIF.

    CLEAR wa_docmn.
    READ TABLE it_docmnx INTO wa_docmn WITH KEY mneum = 'MATORIGIN'
                                                dcitm = wa_itmatr-dcitm.
    IF sy-subrc IS INITIAL.
      MOVE wa_docmn-value TO wa_komp-mtorg.
    ENDIF.

    wa_komp-kpein  = '1'.
    wa_komp-geaend = 'X'.
    wa_komp-fxmsg  = '805'.
    wa_komp-prsok  = 'X'.
    wa_komp-krech  = 'B'.

    CLEAR wa_docmn.
    READ TABLE it_docmnx INTO wa_docmn WITH KEY mneum = 'NCM'
                                                dcitm = wa_itmatr-dcitm.

    IF sy-subrc IS INITIAL.
*      TRANSLATE wa_docmn-value USING '. '.
      CONDENSE wa_docmn-value NO-GAPS.
      MOVE wa_docmn-value TO wa_komp-steuc.
*      CLEAR vg_char8.
*      MOVE wa_docmn-value TO vg_char8.
*      MOVE vg_char8 TO wa_komp-steuc.
    ENDIF.

    DATA: lv_po        TYPE bapiekko-po_number,
          lt_items_aux TYPE STANDARD TABLE OF bapiekpo,
          ls_items_aux LIKE LINE OF lt_items_aux.

    REFRESH: lt_items_aux[].
    CLEAR: ls_items_aux, lv_po.

    MOVE wa_komp-evrtn TO lv_po.
*** Busca  valor liquido sem impostos
    CALL FUNCTION 'BAPI_PO_GETDETAIL'
      EXPORTING
        purchaseorder = lv_po
        items         = 'X'
      TABLES
        po_items      = lt_items_aux.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = wa_komp-evrtp
      IMPORTING
        output = wa_komp-evrtp.

    READ TABLE lt_items_aux INTO ls_items_aux WITH KEY po_item = wa_komp-evrtp.

    IF sy-subrc IS INITIAL.
      MOVE: ls_items_aux-net_value TO wa_komp-netwr,
            ls_items_aux-net_value TO wa_komp-wrbtr.

*      MOVE ls_items_aux-eff_value TO wa_komp-kzwi1.

      wa_komp-mglme = ls_items_aux-quantity.
      wa_komp-mgame = ls_items_aux-quantity.
      wa_komp-vrkme = ls_items_aux-orderpr_un.
      wa_komp-netpr = ls_items_aux-net_price.
    ENDIF.

    APPEND wa_komp TO it_komp.

  ENDIF.

ENDFORM.                    " F_PREENCHE_T_KOMP
*&---------------------------------------------------------------------*
*&      Form  F_BDC_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0161   text
*      -->P_0162   text
*      -->P_0163   text
*----------------------------------------------------------------------*
FORM f_bdc_field USING p_tela
                            p_name
                            p_value.

  CLEAR lt_bdcdata.

  IF p_tela = 'X'.
    lt_bdcdata-program   =  p_name.
    lt_bdcdata-dynpro    =  p_value.
    lt_bdcdata-dynbegin  =  p_tela.
  ELSE.
    lt_bdcdata-fnam      =  p_name.
    lt_bdcdata-fval      =  p_value.
  ENDIF.
  APPEND lt_bdcdata.


ENDFORM.                    " F_BDC_FIELD
*&---------------------------------------------------------------------*
*&      Form  F_DISABLE_AUTOFLUXO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_VL_STOP  text
*      <--P_VL_START  text
*----------------------------------------------------------------------*
FORM f_disable_autofluxo CHANGING vl_stop vl_start.

  DATA: lv_line1 TYPE i,
        lv_line  TYPE i.

  CHECK wa_cabdoc-natdc = '02'
    AND wa_cabdoc-typed = 'NFE'.

  SELECT * FROM zhms_tb_itmatr INTO TABLE it_itmatr WHERE chave EQ v_chave.

  CLEAR: lv_line, lv_line1.
  DESCRIBE TABLE it_itmdoc LINES lv_line.
  DESCRIBE TABLE it_itmatr LINES lv_line1.



  IF lv_line > lv_line1 AND wa_flow-metpr EQ 'A'.
    vl_stop = 'X'.
    CLEAR vl_start.
  ENDIF.
ENDFORM.                    " F_DISABLE_AUTOFLUXO
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_ATRIB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_VL_STOP  text
*      <--P_VL_START  text
*----------------------------------------------------------------------*
FORM f_check_atrib  CHANGING p_vl_stop
                             p_vl_start.

  DATA: lv_line1 TYPE i,
          lv_line  TYPE i.

  CHECK wa_cabdoc-natdc = '02'
    AND wa_cabdoc-typed = 'NFE'.

  CLEAR: lv_line, lv_line1.
  DESCRIBE TABLE it_itmdoc LINES lv_line.
  DESCRIBE TABLE it_itmatr LINES lv_line1.

  IF lv_line > lv_line1 AND wa_flow-metpr EQ 'A'.
    p_vl_stop = 'X'.
    CLEAR p_vl_start.
  ENDIF.


ENDFORM.                    " F_CHECK_ATRIB
*&---------------------------------------------------------------------*
*&      Form  F_AUTO_ATRIB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_VL_STOP  text
*      <--P_VL_START  text
*----------------------------------------------------------------------*
FORM f_auto_atrib  CHANGING vl_stop vl_start.

  DATA: lv_user TYPE user.

  SELECT SINGLE usuario FROM zhms_tb_user_rfc INTO lv_user.

  IF sy-uname EQ lv_user.
    IF wa_flow-flowd EQ '20'.
      vl_stop = 'X'.
      CLEAR vl_start.
    ENDIF.
  ENDIF.


ENDFORM.                    " F_AUTO_ATRIB
*---------------------------------------------------------------------*
*       FORM F_GET_DIV                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_div USING p_itmatr STRUCTURE zhms_tb_itmatr
            CHANGING p_value.

  DATA: lv_plant TYPE werks_d,
        ls_docmn LIKE LINE OF it_docmn.


  IF NOT v_chave IS INITIAL.

    SELECT SINGLE value
      FROM zhms_tb_docmn
      INTO lv_plant
     WHERE chave EQ v_chave
       AND mneum EQ 'PLANT'.

    IF sy-subrc IS INITIAL.
      SELECT SINGLE gsber
      FROM t134g
      INTO p_value
      WHERE werks = lv_plant.
    ELSE.

      READ TABLE it_docmn INTO ls_docmn WITH KEY chave = v_chave
                                                 mneum = 'PLANT'.

      IF sy-subrc IS INITIAL.
        MOVE ls_docmn-value TO lv_plant.
        SELECT SINGLE gsber
        FROM t134g
        INTO p_value
        WHERE werks = lv_plant.
      ENDIF.

    ENDIF.

  ENDIF.

ENDFORM. "F_GET_DIV
*---------------------------------------------------------------------*
*       FORM f_monta_serie                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_ITMATR                                                      *
*  -->  P_VALUE                                                       *
*---------------------------------------------------------------------*
FORM f_monta_serie USING p_itmatr STRUCTURE zhms_tb_itmatr
                                  CHANGING p_value.
*Homine - Inicio da Inclusão - DD- 24328
*  DATA: lv_nnf TYPE zhms_de_value,
*        lv_serie TYPE zhms_de_value.
  DATA: lv_nnf TYPE j_1bnfnum9,
        lv_serie TYPE j_1bseries.
*Homine - fim da Inclusão - DD- 24328
  SELECT SINGLE value
    FROM zhms_tb_docmn
    INTO lv_nnf
   WHERE chave EQ wa_cabdoc-chave
     AND mneum EQ 'NNF'.
*Homine - Inicio da Inclusão - DD- 24328
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = lv_nnf
    IMPORTING
      output = lv_nnf.
*Homine - fim da Inclusão - DD- 24328
  SELECT SINGLE value
    FROM zhms_tb_docmn
    INTO lv_serie
   WHERE chave EQ wa_cabdoc-chave
     AND mneum EQ 'SERIE'.
*Homine - Inicio da Inclusão - DD- 24328
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = lv_serie
    IMPORTING
      output = lv_serie.
*Homine - fim da Inclusão - DD- 24328
  CONCATENATE lv_nnf '-' lv_serie INTO p_value.
  CONDENSE p_value NO-GAPS.

ENDFORM.                    "f_monta_serie
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_QM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_VL_STOP  text
*      <--P_VL_START  text
*----------------------------------------------------------------------*
FORM f_check_qm  CHANGING vl_stop vl_start.

*  data: lv_status TYPE char1.
*  CALL FUNCTION 'ZHMS_FM_CHECK_QM'
*    IMPORTING
*      status = lv_status.
*
*
*  CASE lv_status.
*    WHEN 'B'.
*      CLEAR: vl_start.
*      MOVE abap_true TO vl_stop.
*    WHEN 'L'.
*      CLEAR vl_stop.
*      MOVE abap_true TO vl_start.
*    WHEN OTHERS.
*  ENDCASE.


ENDFORM.                    " F_CHECK_QM
*&---------------------------------------------------------------------*
*&      Form  f_monta_serie_CTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITMATR   text
*      <--P_VALUE    text
*----------------------------------------------------------------------*
FORM f_monta_serie_cte USING p_itmatr STRUCTURE zhms_tb_itmatr
                                  CHANGING p_value.
*Homine - Inicio da Inclusão - DD- 24328
*  DATA: lv_nnf TYPE zhms_de_value,
*        lv_serie TYPE zhms_de_value.
  DATA: lv_nnf TYPE j_1bnfnum9,
        lv_serie TYPE j_1bseries.
*Homine - fim da Inclusão - DD- 24328

  SELECT SINGLE value
    FROM zhms_tb_docmn
    INTO lv_nnf
   WHERE chave EQ wa_cabdoc-chave
     AND mneum EQ 'NCT'.
*Homine - Inicio da Inclusão - DD- 24328
*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*    EXPORTING
*      input  = lv_nnf
*    IMPORTING
*      output = lv_nnf.
*Homine - fim da Inclusão - DD- 24328
  SELECT SINGLE value
    FROM zhms_tb_docmn
    INTO lv_serie
   WHERE chave EQ wa_cabdoc-chave
     AND mneum EQ 'SERIE'.
*Homine - Inicio da Inclusão - DD- 24328
*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*    EXPORTING
*      input  = lv_serie
*    IMPORTING
*      output = lv_serie.
*Homine - fim da Inclusão - DD- 24328
  CONCATENATE lv_nnf '-' lv_serie INTO p_value.
  CONDENSE p_value NO-GAPS.


ENDFORM.                    "f_monta_serie
*&---------------------------------------------------------------------*
*&      Form  F_BLINEDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_blinedate USING p_itmatr STRUCTURE zhms_tb_itmatr
                                  CHANGING p_value.

  p_value = vg_netdt.
  CONDENSE p_value NO-GAPS.

ENDFORM.                    "F_BLINEDATE
*&---------------------------------------------------------------------*
*&      Form  f_form_pgto
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITMATR   text
*      <--P_VALUE    text
*----------------------------------------------------------------------*
FORM f_form_pgto USING p_itmatr STRUCTURE zhms_tb_itmatr
                                  CHANGING p_value.

  p_value = vg_schzw_bseg.
  CONDENSE p_value NO-GAPS.

ENDFORM.                    "F_BLINEDATE
*&---------------------------------------------------------------------*
*&      Form  f_cab_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITMATR   text
*      <--P_VALUE    text
*----------------------------------------------------------------------*
FORM f_cab_text USING p_itmatr STRUCTURE zhms_tb_itmatr
                                  CHANGING p_value.

*DDPT - Inicio
*** Verifica se é importação e abre o Pop-up para inserção de valores manuais
*  READ TABLE IT_DOCMN INTO WA_DOCMN WITH KEY MNEUM = 'IDDEST'.
*  IF SY-SUBRC IS INITIAL AND WA_DOCMN-VALUE EQ '3'.
  p_value = vg_header_txt.
  IF vg_first = 2.
    CLEAR vg_header_txt.
  ENDIF.

*  ELSE.
*    P_VALUE = VG_BKTXT.
*    CONDENSE P_VALUE NO-GAPS.
*  ENDIF.
*DDPT - Fim
ENDFORM.                    "f_cab_text
*&---------------------------------------------------------------------*
*&      Form  F_BUSPLACE_001
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITMATR   text
*      <--P_VALUE    text
*----------------------------------------------------------------------*
FORM f_busplace_001 USING p_itmatr STRUCTURE zhms_tb_itmatr
                                  CHANGING p_value.

  p_value = '0001'.

ENDFORM.                    "F_BUSPLACE_001
*&---------------------------------------------------------------------*
*&      Form  F_BUSPLACE_7202
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITMATR   text
*      <--P_VALUE    text
*----------------------------------------------------------------------*
FORM f_busplace_7202 USING p_itmatr STRUCTURE zhms_tb_itmatr
                                  CHANGING p_value.

  p_value = '7202'.

ENDFORM.                    "F_BUSPLACE_7202
*&---------------------------------------------------------------------*
*&      Form  f_j1bnftype
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITMATR   text
*      <--P_VALUE    text
*----------------------------------------------------------------------*
FORM f_j1bnftype USING p_itmatr STRUCTURE zhms_tb_itmatr
                                  CHANGING p_value.

  p_value = 'E1'.
*P_VALUE = '55'.

ENDFORM.                    "F_BUSPLACE_7202
*&---------------------------------------------------------------------*
*&      Form  F_J1BNFTYPE_E1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITMATR   text
*      <--P_VALUE    text
*----------------------------------------------------------------------*
FORM f_j1bnftype_e1 USING p_itmatr STRUCTURE zhms_tb_itmatr
                                  CHANGING p_value.

  IF v_typed NE 'NFE3'.
    p_value = 'ZC'.
  ENDIF.
* P_VALUE = '55'.

ENDFORM.                    "F_J1BNFTYPE_E1


*&---------------------------------------------------------------------*
*&      Form  F_J1BNFTYPE_CTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITMATR   text
*      -->P_VALUE    text
*----------------------------------------------------------------------*
FORM f_j1bnftype_cte USING p_itmatr STRUCTURE zhms_tb_itmatr
                                      CHANGING p_value.
  p_value = '55'.
ENDFORM.                    "F_J1BNFTYPE_CTE

*&---------------------------------------------------------------------*
*&      Form  F_REF_DOC_IT_CTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITMATR   text
*      -->P_VALUE    text
*----------------------------------------------------------------------*
FORM f_ref_doc_it_cte USING p_itmatr STRUCTURE zhms_tb_itmatr
                                      CHANGING p_value.
  p_value = 1.
  IF v_typed = 'CTE'.
    CLEAR: p_value.
  ENDIF.
ENDFORM.                    "F_REF_DOC_IT_CTE

*DDPT - Inicio
*&---------------------------------------------------------------------*
*&      Form  f_ALLOC_NMBR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITMATR   text
*      -->P_VALUE    text
*----------------------------------------------------------------------*
FORM f_alloc_nmbr USING p_itmatr STRUCTURE zhms_tb_itmatr
                                  CHANGING p_value.

**** Verifica se é importação e abre o Pop-up para inserção de valores manuais
*  READ TABLE IT_DOCMN INTO WA_DOCMN WITH KEY MNEUM = 'IDDEST'.
*  IF SY-SUBRC IS INITIAL AND WA_DOCMN-VALUE EQ '3'.
  p_value = vg_alloc_nmbr.
  IF vg_first EQ 2.
    CLEAR vg_alloc_nmbr.
  ENDIF.

*  ELSE.
*    READ TABLE IT_DOCMN INTO WA_DOCMN WITH KEY MNEUM = 'ALLOCNMBR'.
*    IF SY-SUBRC IS INITIAL.
*      P_VALUE = WA_DOCMN-VALUE.
*    ENDIF.
*  ENDIF.

ENDFORM.                    "f_ALLOC_NMBR
*&---------------------------------------------------------------------*
*&      Form  f_PAYMT_REF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITMATR   text
*      -->P_VALUE    text
*----------------------------------------------------------------------*
FORM f_paymt_ref USING p_itmatr STRUCTURE zhms_tb_itmatr
                                  CHANGING p_value.

*** VERIFICA SE É IMPORTAÇÃO E ABRE O POP-UP PARA INSERÇÃO DE VALORES MANUAIS
*  READ TABLE IT_DOCMN INTO WA_DOCMN WITH KEY MNEUM = 'IDDEST'.
*  IF SY-SUBRC IS INITIAL AND WA_DOCMN-VALUE EQ '3'.
  p_value = vg_paymt_ref.
  IF vg_first EQ 2.
    CLEAR vg_paymt_ref.
  ENDIF.

*  ELSE.
*    READ TABLE IT_DOCMN INTO WA_DOCMN WITH KEY MNEUM = 'PAYMTREF'.
*    IF SY-SUBRC IS INITIAL.
*      P_VALUE = WA_DOCMN-VALUE.
*    ENDIF.
*  ENDIF.

ENDFORM.                    "F_PAYMT_REF
*&---------------------------------------------------------------------*
*&      Form  f_ITEM_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITMATR   text
*      -->P_VALUE    text
*----------------------------------------------------------------------*
FORM f_item_text USING p_itmatr STRUCTURE zhms_tb_itmatr
                                  CHANGING p_value.

*** VERIFICA SE É IMPORTAÇÃO E ABRE O POP-UP PARA INSERÇÃO DE VALORES MANUAIS
*  READ TABLE IT_DOCMN INTO WA_DOCMN WITH KEY MNEUM = 'IDDEST'.
*  IF SY-SUBRC IS INITIAL AND WA_DOCMN-VALUE EQ '3'.
  p_value = vg_item_text.
  IF vg_first EQ 2.
    CLEAR vg_item_text.
  ENDIF.
*  ELSE.
*    READ TABLE IT_DOCMN INTO WA_DOCMN WITH KEY MNEUM = 'ITEMTEXT'.
*    IF SY-SUBRC IS INITIAL.
*      P_VALUE = WA_DOCMN-VALUE.
*    ENDIF.
*  ENDIF.

ENDFORM.                    "f_ITEM_TEXT

*DDPT - Fim
*&---------------------------------------------------------------------*
*&      Form  F_ATRIB_MANUAL
*&---------------------------------------------------------------------*
FORM f_atrib_manual  CHANGING p_vl_stop
                              p_vl_start.

**    Realiza contas para atribuição proporcional
  DATA: vl_atr_atprc TYPE zhms_de_atprc,
        vl_atr_atqtd TYPE zhms_de_atqtd,
        vl_pre_atprc TYPE zhms_de_atprc,
        vl_pre_atqtd TYPE zhms_de_atqtd,
        vl_qtd_atr   TYPE sy-tabix,
        vl_index     TYPE sy-tabix,
        wa_atr       TYPE zhms_tb_itmatr,
        vl_itm       TYPE n LENGTH 6,
        vl_last      TYPE flag.
  DATA: vl_seqnr     TYPE zhms_de_seqnr,
        lv_po        TYPE ebeln,
        t_mneuatr    TYPE TABLE OF zhms_tb_mneuatr,
        wa_mneuatr   TYPE zhms_tb_mneuatr.
  DATA: it_docmn_aux TYPE TABLE OF zhms_tb_docmn,
        wa_docmn_aux TYPE zhms_tb_docmn.


**    Buscar mneumonicos a serem gerados
  SELECT *
    INTO TABLE t_mneuatr
    FROM zhms_tb_mneuatr.

*** limpa mneumonicos da tabela interna
  DELETE it_docmn  WHERE chave EQ wa_atr-chave
            AND dcitm EQ wa_atr-dcitm
            AND ( mneum EQ 'ATQTD'
             OR mneum EQ 'ATUM'
             OR mneum EQ 'ATPED'
             OR mneum EQ 'ATITMPED'
             OR mneum EQ 'ATITMXML'
             OR mneum EQ 'ATITMPROC'
             OR mneum EQ 'ATVLR'
             OR mneum EQ 'AEXTLOT'
             OR mneum EQ 'DATAPROD'
             OR mneum EQ 'DATAVENC'
             OR mneum EQ 'XMLNCM'
             OR mneum EQ 'ATTLOT'
             OR mneum EQ 'ATITMXML'
             OR mneum EQ 'ATITMPED'
             OR mneum EQ 'ATQTDE'
             OR mneum EQ 'ATVCOFINS'
             OR mneum EQ 'ATVCOFINSS'
             OR mneum EQ 'ATCRICMSST'
             OR mneum EQ 'ATDESC'
             OR mneum EQ 'ATFRT'
             OR mneum EQ 'ATVICMS'
             OR mneum EQ 'ATVICMSST'
             OR mneum EQ 'ATICMSSDES'
             OR mneum EQ 'ATICMSSRET'
             OR mneum EQ 'ATVII'
             OR mneum EQ 'ATVIOF'
             OR mneum EQ 'ATVIPI'
             OR mneum EQ 'ATVISSQN'
             OR mneum EQ 'ATDESPAC'
             OR mneum EQ 'ATVPIS'
             OR mneum EQ 'ATVPISST'
             OR mneum EQ 'ATVLR'
             OR mneum EQ 'ATSEG'
             OR mneum EQ 'NCM'
             OR mneum EQ 'ATPED'
             OR mneum EQ 'MATDOC'
             OR mneum EQ 'FISCALYEAR'
             OR mneum EQ 'MATDOCYEA'
             OR mneum = 'ACTIVITY'
             OR mneum = 'ASSETNO'
             OR mneum = 'BUDGPERIOD'
             OR mneum = 'BUSAREA'
             OR mneum = 'CMMTITEM'
             OR mneum = 'CMMTITMLON'
             OR mneum = 'COAREA'
             OR mneum = 'COSTCENTER'
             OR mneum = 'COSTCTR'
             OR mneum = 'COSTOBJ'
             OR mneum = 'CUSTOMER'
             OR mneum = 'DELIVITEM'
             OR mneum = 'DELIVNUMB'
             OR mneum = 'DISTRPERC'
             OR mneum = 'ENRYUOMISO'
             OR mneum = 'FUNAREALON'
             OR mneum = 'FUNCAREA'
             OR mneum = 'FUND'
             OR mneum = 'FUNDSCTR'
             OR mneum = 'FUNDSRES'
             OR mneum = 'GLACCOUNT'
             OR mneum = 'GLACCT'
             OR mneum = 'GRANTNBR'
             OR mneum = 'GRRCPT'
             OR mneum = 'MATDOCYEA'
             OR mneum = 'MATERIAL'
             OR mneum = 'MATLGROUP'
             OR mneum = 'MATLUSAGE'
             OR mneum = 'MATORIGIN'
             OR mneum = 'MVTIND'
             OR mneum = 'NBSLIPS'
             OR mneum = 'NETPRICE'
             OR mneum = 'NETWORK'
             OR mneum = 'ORDERID'
             OR mneum = 'ORDERNO'
             OR mneum = 'PARTACCT'
             OR mneum = 'PLANT'
             OR mneum = 'PROFITCTR'
             OR mneum = 'PROFSEGM'
             OR mneum = 'PROFSEGMNO'
             OR mneum = 'PROJEXT'
             OR mneum = 'QUANTITY'
             OR mneum = 'RECIND'
             OR mneum = 'REFDATE'
             OR mneum = 'RESITEM'
             OR mneum = 'RLESTKEY'
             OR mneum = 'ROUTINGNO'
             OR mneum = 'SCHEDLINE'
             OR mneum = 'SDDOC'
             OR mneum = 'SDOCITEM'
             OR mneum = 'SERIALNO'
             OR mneum = 'STGELOC'
             OR mneum = 'SUBNUMBER'
             OR mneum = 'TAXCODE'
             OR mneum = 'TAXJURCODE'
             OR mneum = 'TOCOSTCTR'
             OR mneum = 'TOORDER'
             OR mneum = 'TOPROJECT'
             OR mneum = 'VALTYPE'
             OR mneum = 'VENDOR'
             OR mneum = 'WBSELEM'
             OR mneum = 'WBSELEME' ).

  it_docmn_aux = it_docmn.

  LOOP AT it_docmn INTO wa_docmn WHERE mneum = 'XPED'.

**    Definir Ultimo
    CLEAR vl_last.
    AT LAST.
      vl_last = 'X'.
    ENDAT.

    ADD 1 TO vl_itm.
    READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'XPED'
                                               dcitm = vl_itm.
    IF sy-subrc EQ 0.
      wa_atr-nrsrf = wa_docmn-value.
    ENDIF.

    wa_atr-natdc = '02'.
    wa_atr-typed = 'NFE'.
    wa_atr-seqnr = 1.
    wa_atr-chave = wa_docmn-chave.
    wa_atr-dcitm = wa_docmn-dcitm.
    wa_atr-atitm = wa_docmn-dcitm.
    wa_atr-tdsrf = 1.

    READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'NITEMPED'
                                               dcitm = vl_itm.
    IF sy-subrc EQ 0.
      wa_atr-itsrf = wa_docmn-value.
    ENDIF.

    READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'CPROD'
                                              dcitm = vl_itm.
    IF sy-subrc EQ 0.
*      SELECT SINGLE matnr
*        INTO wa_atr-atmat
*        FROM ekpo
*        WHERE ebeln = wa_atr-nrsrf
*          AND ebelp = wa_atr-itsrf.
*      IF sy-subrc NE 0.
      wa_atr-atmat = wa_docmn-value.
*      ENDIF.
    ENDIF.


    READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'QCOM'
                                              dcitm = vl_itm.
    IF sy-subrc EQ 0.
      wa_atr-atqtd = wa_docmn-value.
    ENDIF.

    READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'UCOM'
                                              dcitm = vl_itm.
    IF sy-subrc EQ 0.
      SELECT SINGLE meins
        FROM ekpo
        INTO wa_atr-atunm
        WHERE ebeln = wa_atr-nrsrf
          AND ebelp = wa_atr-itsrf.
      IF sy-subrc NE 0.
        wa_atr-atunm = wa_docmn-value.
      ENDIF.
    ENDIF.

    READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'VUNCOM'
    dcitm = vl_itm.
    IF sy-subrc EQ 0.
      wa_atr-atprc = wa_atr-atqtd *  wa_docmn-value.
    ENDIF.

    wa_atr-atprp = 'X'.

    MODIFY zhms_tb_itmatr FROM wa_atr.
*    CLEAR wa_atr.

**    Gerar Mneumonicos com base na atribuição feita
    IF vl_seqnr IS INITIAL.
      PERFORM f_nextseq_mneum CHANGING vl_seqnr.
    ENDIF.

* Cria MNEUM referente a atribuição automatica
* Quantidade final
    CLEAR wa_docmn.
    vl_seqnr = vl_seqnr + 1.
    wa_docmn-chave = wa_atr-chave.
    wa_docmn-seqnr = vl_seqnr.
    wa_docmn-mneum = 'ATQTD'.
    wa_docmn-dcitm = wa_atr-dcitm.
    wa_docmn-atitm = wa_atr-atitm.
    wa_docmn-value = wa_atr-atqtd.
    CONDENSE wa_docmn-value NO-GAPS.
    APPEND wa_docmn TO it_docmn.

*Unidade final
    CLEAR wa_docmn.
    vl_seqnr = vl_seqnr + 1.
    wa_docmn-chave = wa_atr-chave.
    wa_docmn-seqnr = vl_seqnr.
    wa_docmn-mneum = 'ATUM'.
    wa_docmn-dcitm = wa_atr-dcitm.
    wa_docmn-atitm = wa_atr-atitm.
    wa_docmn-value = wa_atr-atunm.
    CONDENSE wa_docmn-value NO-GAPS.
    APPEND wa_docmn TO it_docmn.

*           Documento Referencia
    CLEAR wa_docmn.
    vl_seqnr = vl_seqnr + 1.
    wa_docmn-chave = wa_atr-chave.
    wa_docmn-seqnr = vl_seqnr.
    wa_docmn-mneum = 'ATPED'.
    wa_docmn-dcitm = wa_atr-dcitm.
    wa_docmn-atitm = wa_atr-atitm.

    IF wa_atr-nrsrf IS NOT INITIAL.
      CLEAR lv_po.
      MOVE wa_atr-nrsrf TO lv_po.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = lv_po
        IMPORTING
          output = lv_po.
      CLEAR wa_atr-nrsrf.
      MOVE lv_po TO wa_atr-nrsrf.
    ENDIF.

    wa_docmn-value = wa_atr-nrsrf.
    CONDENSE wa_docmn-value NO-GAPS.
    APPEND wa_docmn TO it_docmn.

*           Item Documento referencia
    CLEAR wa_docmn.
    vl_seqnr = vl_seqnr + 1.
    wa_docmn-chave = wa_atr-chave.
    wa_docmn-seqnr = vl_seqnr.
    wa_docmn-mneum = 'ATITMPED'.
    wa_docmn-dcitm = wa_atr-dcitm.
    wa_docmn-atitm = wa_atr-atitm.
    wa_docmn-value = wa_atr-itsrf.
    CONDENSE wa_docmn-value NO-GAPS.
    APPEND wa_docmn TO it_docmn.

*          WHEN OTHERS.
*        ENDCASE.



*Item do XML
    CLEAR wa_docmn.
    vl_seqnr = vl_seqnr + 1.
    wa_docmn-chave = wa_atr-chave.
    wa_docmn-seqnr = vl_seqnr.
    wa_docmn-mneum = 'ATITMXML'.
    wa_docmn-dcitm = wa_atr-dcitm.
    wa_docmn-atitm = wa_atr-atitm.
    wa_docmn-value = wa_atr-dcitm.
    CONDENSE wa_docmn-value NO-GAPS.
    APPEND wa_docmn TO it_docmn.


*Item para processamento
    CLEAR wa_docmn.
    vl_seqnr       = vl_seqnr + 1.
    wa_docmn-chave = wa_atr-chave.
    wa_docmn-seqnr = vl_seqnr.
    wa_docmn-mneum = 'ATITMPROC'.
    wa_docmn-dcitm = wa_atr-dcitm.
    wa_docmn-atitm = wa_atr-atitm.
    wa_docmn-value = wa_atr-atitm.
    CONDENSE wa_docmn-value NO-GAPS.
    APPEND wa_docmn TO it_docmn.


*valor do item
    CLEAR wa_docmn.
    vl_seqnr = vl_seqnr + 1.
    wa_docmn-chave = wa_atr-chave.
    wa_docmn-seqnr = vl_seqnr.
    wa_docmn-mneum = 'ATVLR'.
    wa_docmn-dcitm = wa_atr-dcitm.
    wa_docmn-atitm = wa_atr-atitm.
    wa_docmn-value = wa_atr-atprc.
    CONDENSE wa_docmn-value NO-GAPS.
    APPEND wa_docmn TO it_docmn.

* Lote
    CLEAR wa_docmn.
    vl_seqnr = vl_seqnr + 1.
    wa_docmn-chave = wa_atr-chave.
    wa_docmn-seqnr = vl_seqnr.
    wa_docmn-mneum = 'ATTLOT'.
    wa_docmn-dcitm = wa_atr-dcitm.
    wa_docmn-atitm = wa_atr-atitm.
    wa_docmn-value = wa_atr-atlot.
    CONDENSE wa_docmn-value NO-GAPS.
    APPEND wa_docmn TO it_docmn.

    CLEAR wa_docmn.
    vl_seqnr = vl_seqnr + 1.
    wa_docmn-chave = wa_atr-chave.
    wa_docmn-seqnr = vl_seqnr.
    wa_docmn-mneum = 'AEXTLOT'.
    wa_docmn-dcitm = wa_atr-dcitm.
    wa_docmn-atitm = wa_atr-atitm.
    wa_docmn-value = wa_atr-exlot.
    CONDENSE wa_docmn-value NO-GAPS.
    APPEND wa_docmn TO it_docmn.

    CLEAR wa_docmn.
    vl_seqnr = vl_seqnr + 1.
    wa_docmn-chave = wa_atr-chave.
    wa_docmn-seqnr = vl_seqnr.
    wa_docmn-mneum = 'DATAPROD'.
    wa_docmn-dcitm = wa_atr-dcitm.
    wa_docmn-atitm = wa_atr-atitm.
    wa_docmn-value = wa_atr-data_prod.
    CONDENSE wa_docmn-value NO-GAPS.
    APPEND wa_docmn TO it_docmn.

    CLEAR wa_docmn.
    vl_seqnr = vl_seqnr + 1.
    wa_docmn-chave = wa_atr-chave.
    wa_docmn-seqnr = vl_seqnr.
    wa_docmn-mneum = 'DATAVENC'.
    wa_docmn-dcitm = wa_atr-dcitm.
    wa_docmn-atitm = wa_atr-atitm.
    wa_docmn-value = wa_atr-data_venc.
    CONDENSE wa_docmn-value NO-GAPS.
    APPEND wa_docmn TO it_docmn.


**      Percorre Mneumônicos de valores a serem gerados pela Atribuição
    LOOP AT t_mneuatr INTO wa_mneuatr.


**        Busca mneumonico de origem para geração do mneumonico de atribuição
      READ TABLE it_docmn_aux INTO wa_docmn_aux WITH KEY mneum = wa_mneuatr-mnorg
                                                        dcitm =  wa_atr-dcitm.

**        Verifica se existe mneumonico de origem
      CHECK sy-subrc IS INITIAL.

      IF wa_docmn_aux-mneum EQ 'NITEMPED'.
        IF wa_docmn_aux-value NE wa_atr-itsrf.
          CONTINUE.
        ENDIF.
      ENDIF.

* Apaga atribuição anterior
      DELETE FROM zhms_tb_docmn
       WHERE chave EQ wa_atr-chave
         AND dcitm EQ wa_atr-dcitm
         AND mneum EQ wa_mneuatr-mndst.

      COMMIT WORK AND WAIT.

**        Transfere valores
      CLEAR wa_docmn.
      vl_seqnr = vl_seqnr + 1.
      wa_docmn-chave = wa_atr-chave.
      wa_docmn-seqnr = vl_seqnr.
      wa_docmn-mneum = wa_mneuatr-mndst.
      wa_docmn-dcitm = wa_atr-dcitm.
      wa_docmn-atitm = wa_atr-atitm.

      READ TABLE it_itmdoc INTO wa_itmdoc WITH KEY chave = wa_atr-chave
                                                   dcitm = wa_atr-dcitm.

**        Cálculos de proporção para distribuição
      IF wa_mneuatr-mnorg NE 'NITEMPED'.
        PERFORM f_calcula_proporcao USING wa_docmn_aux-value wa_itmdoc-dcqtd wa_atr-atqtd vl_last wa_docmn-mneum
                                 CHANGING wa_docmn-value.
        IF wa_mneuatr-mnorg EQ 'XPED'.
          CLEAR wa_docmn-value.
          MOVE wa_atr-nrsrf TO wa_docmn-value.
        ENDIF.
      ELSE.
        MOVE wa_docmn_aux-value TO wa_docmn-value.
      ENDIF.
      CONDENSE wa_docmn-value NO-GAPS.
      APPEND wa_docmn TO it_docmn.
    ENDLOOP.

  ENDLOOP.

**    Insere/Modifica dados no repositorio de mneumonicos
*      INSERT zhms_tb_docmn FROM TABLE t_docmn.
  MODIFY zhms_tb_docmn FROM TABLE it_docmn.
  COMMIT WORK AND WAIT.

  CLEAR p_vl_stop.
  p_vl_start = 'X'.
ENDFORM.                    " F_ATRIB_MANUAL

*&---------------------------------------------------------------------*
*&      Form  f_calcula_proporcao
*&---------------------------------------------------------------------*
*       Efetua os cálculos de proporção
*----------------------------------------------------------------------*
FORM f_calcula_proporcao USING p_antvlr p_antqtd p_newqtd p_last p_field
                      CHANGING p_newvlr.
*    Variáveis Locais
  DATA: vl_indexbuff TYPE sy-tabix,
        vl_newvlr    TYPE zhms_de_usprc.

*    Busca dados ja atribuidos (soma)
  CLEAR wa_atrbuffer.
  READ TABLE t_atrbuffer INTO wa_atrbuffer WITH KEY field = p_field.
  vl_indexbuff = sy-tabix.

*    Caso não seja o ultimo realiza a conta via regra de 3
  IF p_last IS INITIAL.
    vl_newvlr = ( p_newqtd * p_antvlr ) / p_antqtd.
    MOVE vl_newvlr TO p_newvlr.

  ELSE.
*    Caso seja o último realiza a conta via subtração do valor total
    vl_newvlr = p_antvlr - wa_atrbuffer-sumat.
    MOVE vl_newvlr TO p_newvlr.

  ENDIF.

*     Mantem total armazenado
  IF NOT vl_indexbuff IS INITIAL.
    wa_atrbuffer-sumat = wa_atrbuffer-sumat + vl_newvlr.
    MODIFY t_atrbuffer FROM wa_atrbuffer INDEX vl_indexbuff.
  ELSE.
    wa_atrbuffer-field = p_field.
    wa_atrbuffer-sumat = vl_newvlr.
    APPEND wa_atrbuffer TO t_atrbuffer.
  ENDIF.

ENDFORM.                    "f_calcula_proporcao

*&---------------------------------------------------------------------*
*&      Form  F_NEXTSEQ_MNEUM
*&---------------------------------------------------------------------*
*       recupera próximo seqnr para mneumonicos
*----------------------------------------------------------------------*
FORM f_nextseq_mneum  CHANGING p_vl_seqnr.
**    Variáveis locais
  DATA: tl_seqnr TYPE TABLE OF zhms_de_seqnr,
        wl_seqnr TYPE zhms_de_seqnr.

**    Seleção das sequencias
  SELECT seqnr
    INTO TABLE tl_seqnr
    FROM zhms_tb_docmn
   WHERE chave EQ wa_cabdoc-chave.

  IF sy-subrc IS NOT INITIAL.
**    Seleção das sequencias
    SELECT seqnr
      INTO TABLE tl_seqnr
      FROM zhms_tb_docmn_hs
     WHERE chave EQ wa_cabdoc-chave.
  ENDIF.

**    Identifica a ultima
  SORT tl_seqnr DESCENDING.
  READ TABLE tl_seqnr INTO wl_seqnr INDEX 1.

  p_vl_seqnr = wl_seqnr.

ENDFORM.                    " F_NEXTSEQ_MNEUM

*&---------------------------------------------------------------------*
*&      Form  F_VER_GR_GI_SLIP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITMATR   text
*      -->P_VALUE    text
*----------------------------------------------------------------------*
FORM f_ver_gr_gi_slip USING p_itmatr STRUCTURE zhms_tb_itmatr
                                  CHANGING p_value.

  p_value = '1'.

ENDFORM.                    "F_VER_GR_GI_SLIP
*&---------------------------------------------------------------------*
*&      Form  F_VER_GR_GI_SLIPX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITMATR   text
*      -->P_VALUE    text
*----------------------------------------------------------------------*
FORM f_ver_gr_gi_slipx USING p_itmatr STRUCTURE zhms_tb_itmatr
                                  CHANGING p_value.

  p_value = 'X'.

ENDFORM.                    "F_VER_GR_GI_SLIP
*&---------------------------------------------------------------------*
*&      Form  F_MENSAGEM_ERRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_mensagem_erro TABLES p_it_hrvalid STRUCTURE wa_hrvalid
                      USING p_vg_message
                            p_seqnr    "wa_hrvalid-seqnr
                            p_vldty    "wa_hrvalid-vldty
                            p_vldv1    "wa_hrvalid-vldv1 (Nº mensagem)
                            p_ativo.   "wa_hrvalid-ativo

  MOVE: wa_cabdoc-natdc  TO wa_hrvalid-natdc,
        wa_cabdoc-typed  TO wa_hrvalid-typed,
        wa_cabdoc-loctp  TO wa_hrvalid-loctp,
        wa_cabdoc-chave  TO wa_hrvalid-chave,
        p_seqnr          TO wa_hrvalid-seqnr,
        sy-datum         TO wa_hrvalid-dtreg,
        sy-uzeit         TO wa_hrvalid-hrreg,
        wa_itmatr-atitm  TO wa_hrvalid-atitm,
        p_vldty          TO wa_hrvalid-vldty,
        p_vldv1          TO wa_hrvalid-vldv1,
        p_vg_message     TO wa_hrvalid-vldv2,
        p_ativo          TO wa_hrvalid-ativo.
  APPEND wa_hrvalid TO p_it_hrvalid.
  CLEAR wa_hrvalid.

ENDFORM.                    " F_MENSAGEM_ERRO
