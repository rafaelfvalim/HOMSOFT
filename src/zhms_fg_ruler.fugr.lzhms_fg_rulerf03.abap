

*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_RULERF03 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_TRACER_INICIALIZA_VARIAVEIS
*&---------------------------------------------------------------------*
*       Inicializar Variávies internas
*----------------------------------------------------------------------*
FORM f_tracer_inicializa_variaveis  TABLES  p_docum
                                     USING  p_natdc
                                            p_typed
                                            p_loctp.

* Transferência do dados
  v_natdc = p_natdc.
  v_typed = p_typed.
  v_loctp	= p_loctp.

* Dados de Documento
  it_docum[] = p_docum[].

* Verificação de dados recebidos
  IF it_docum[] IS INITIAL.
    RAISE document_not_informed.
  ENDIF.

* Tratativa para tabela de documentos
  LOOP AT it_docum INTO wa_docum.

**  Remover zeros
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = wa_docum-dcnro
      IMPORTING
        output = wa_docum-dcnro.

**  Limpar espaços
    CONDENSE wa_docum-dcnro NO-GAPS.
    MODIFY it_docum FROM wa_docum INDEX sy-tabix.

  ENDLOOP.

ENDFORM.                    " F_TRACER_INICIALIZA_VARIAVEIS

*&---------------------------------------------------------------------*
*&      Form  F_SELECIONA_CENARIOS
*&---------------------------------------------------------------------*
*       Seleciona todos os cenários cadastrados
*----------------------------------------------------------------------*
FORM f_seleciona_cenarios .

* Seleção
  SELECT *
    INTO TABLE it_scenario
    FROM zhms_tb_scenario
   WHERE natdc EQ v_natdc
     AND typed EQ v_typed
     AND loctp EQ v_loctp.

* Verificação dos dados encontrados
  IF it_scenario[] IS INITIAL.
    RAISE scenario_not_found.
  ENDIF.

ENDFORM.                    " F_SELECIONA_CENARIOS

*&---------------------------------------------------------------------*
*&      Form  F_EXECUTA_ROTINAS
*&---------------------------------------------------------------------*
*       Executa rotinas de identificação dos cenários
*----------------------------------------------------------------------*
FORM f_executa_rotinas .

*  DO.
*    IF sy-subrc EQ '14'.
*      EXIT.
*    ENDIF.
*  ENDDO.

* Limpar variável Código de Cenário
  CLEAR v_scena.
*----------------------------------------------------------
*Renan Itokazo
*18.09.2018
*Alterado para corrigir o lote de XML vindo do HomIntegrator
*CLEAR: wa_docmn,
*       IT_DOCUM,
*       v_chave.
*----------------------------------------------------------

* Percorre os cenários encontrados executando as rotinas de identificação.
  LOOP AT it_scenario INTO wa_scenario.
    IF v_scena IS INITIAL.
      PERFORM (wa_scenario-rotin) IN PROGRAM saplzhms_fg_ruler IF FOUND.
      IF v_scena IS NOT INITIAL.
        EXIT.
      ENDIF.
    ENDIF.
  ENDLOOP.

* Verifica se nenhuma rotina identificou o cenário.
  IF v_scena IS INITIAL.
*   Busca cenário Default caso nenhum cenário tenha atendido.
    READ TABLE it_scenario INTO wa_scenario WITH KEY defau = 'X'.
    IF sy-subrc IS INITIAL.
      v_scena = wa_scenario-scena.
    ENDIF.
  ENDIF.

* Verifica se algum cenário foi atribuido.
  IF v_scena IS INITIAL.
    RAISE scenario_not_found.
  ELSE.
*   Verifica chave atribuida
*    CHECK NOT v_chave IS INITIAL.
    IF v_chave IS INITIAL.
     READ TABLE it_docum INTO wa_docum WITH KEY dctyp = 'CHAVE'.
      CONDENSE wa_docum-dcnro NO-GAPS.
      MOVE wa_docum-dcnro TO v_chave.

      IF NOT v_chave IS INITIAL.
*   Atualiza o cenário encontrado
        UPDATE zhms_tb_cabdoc
           SET scena = v_scena
         WHERE natdc EQ v_natdc
           AND typed EQ v_typed
           AND loctp EQ v_loctp
           AND chave EQ v_chave.
      ENDIF.
    ELSE.
*   Atualiza o cenário encontrado
      UPDATE zhms_tb_cabdoc
         SET scena = v_scena
       WHERE natdc EQ v_natdc
         AND typed EQ v_typed
         AND loctp EQ v_loctp
         AND chave EQ v_chave.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_EXECUTA_ROTINAS

*&---------------------------------------------------------------------*
*&      Form  f_carrega_mneumonicos
*&---------------------------------------------------------------------*
*     Seleciona todos os mneumonicos do repositório para o documento
*----------------------------------------------------------------------*
FORM f_carrega_mneumonicos.

*  Busca da tabela de repositório
  SELECT *
    INTO TABLE it_docmn
    FROM zhms_tb_docmn
   WHERE chave EQ v_chave.

*  Ajusta sequencia
  LOOP AT it_docmn INTO wa_docmn.
    CONDENSE wa_docmn-seqnr NO-GAPS.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = wa_docmn-seqnr
      IMPORTING
        output = wa_docmn-seqnr.

    MODIFY it_docmn FROM wa_docmn INDEX sy-tabix.

  ENDLOOP.

ENDFORM.                    "f_carrega_mneumonicos

*&---------------------------------------------------------------------*
*&      Form  F_CONTINUA_FLUXO
*&---------------------------------------------------------------------*
*       Executa chamada da função de execução.
*----------------------------------------------------------------------*
FORM f_continua_fluxo .

  CALL FUNCTION 'ZHMS_FM_EXEC'
    EXPORTING
      natdc                      = v_natdc
      typed                      = v_typed
      loctp                      = v_loctp
*     EVENT                      =
      scena                      = v_scena
    EXCEPTIONS
      nature_not_informed        = 1
      document_type_not_informed = 2
      event_scenery_not_informed = 3
      OTHERS                     = 4.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.                    " F_CONTINUA_FLUXO

*&---------------------------------------------------------------------*
*&      Form  F_AGENDA_EXECUCAO
*&---------------------------------------------------------------------*
*       Agenda a execução do fluxo para background
*----------------------------------------------------------------------*
FORM f_agenda_execucao .

** Chamada da função em uma nova task
  CALL FUNCTION 'ZHMS_FM_TRACER'
*    STARTING NEW TASK 'ZHMS_FM_TRACER_BG'
    EXPORTING
      natdc = v_natdc
      typed = v_typed
      loctp = v_loctp
    TABLES
      docum = it_docum.

ENDFORM.                    " F_AGENDA_EXECUCAO
*&---------------------------------------------------------------------*
*&      Form  ZF_PREENCHE_BDC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0056   text
*      -->P_0057   text
*      -->P_0058   text
*----------------------------------------------------------------------*
FORM zf_preenche_bdc USING p_tela
                           p_name
                           p_value.

  CLEAR gt_bdc.

  IF p_tela = 'X'.
    gt_bdc-program   =  p_name.
    gt_bdc-dynpro    =  p_value.
    gt_bdc-dynbegin  =  p_tela.
  ELSE.
    gt_bdc-fnam      =  p_name.
    gt_bdc-fval      =  p_value.
  ENDIF.
  APPEND gt_bdc.


ENDFORM.                    " ZF_PREENCHE_BDC
