*-------------------------------------------------------------------*
*   HomSoft - Documentos Eletrônicos : Automator/Connector: Ruler   *
*-------------------------------------------------------------------*
* Descrição	: Identificador de cenário de projeto baseado em        *
*    rotinas descritas na central de Configuração                   *
*-------------------------------------------------------------------*
FUNCTION zhms_fm_tracer.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(NATDC) TYPE  ZHMS_DE_NATDC
*"     VALUE(TYPED) TYPE  ZHMS_DE_TYPED
*"     VALUE(LOCTP) TYPE  ZHMS_DE_LOCTP
*"     VALUE(JUST_IDENT) TYPE  FLAG OPTIONAL
*"  TABLES
*"      DOCUM STRUCTURE  ZHMS_ES_DOCUM
*"  EXCEPTIONS
*"      DOCUMENT_NOT_INFORMED
*"      SCENARIO_NOT_FOUND
*"----------------------------------------------------------------------

* Inicializar Variáveis internas
  PERFORM f_tracer_inicializa_variaveis TABLES docum
                                         USING natdc
                                               typed
                                               loctp.
* Buscar Cenários cadastrados
  PERFORM f_seleciona_cenarios.

* Executar rotinas de identificação para cada cenário
  PERFORM f_executa_rotinas.

* Agenda a execução do fluxo para background
  IF NOT just_ident IS INITIAL.
    PERFORM f_agenda_execucao.
  ENDIF.

* Paraliza execução caso seja apenas identificação
  CHECK just_ident IS INITIAL.

* Seleciona todos os mneumonicos do repositório para o documento
  PERFORM f_carrega_mneumonicos.

* Executa chamada da função de execução.
  PERFORM f_continua_fluxo.

ENDFUNCTION.
