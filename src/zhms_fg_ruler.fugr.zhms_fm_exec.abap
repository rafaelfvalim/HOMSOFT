*-------------------------------------------------------------------*
*   HomSoft - Documentos Eletrônicos : Automator/Connector: Ruler   *
*-------------------------------------------------------------------*
* Descrição	: RFC para conexão entre o sistema SAP e                *
*    o HomSoft: Quazaris                                            *
*-------------------------------------------------------------------*
FUNCTION zhms_fm_exec .
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(NATDC) TYPE  ZHMS_DE_NATDC
*"     REFERENCE(TYPED) TYPE  ZHMS_DE_TYPED
*"     REFERENCE(LOCTP) TYPE  ZHMS_DE_LOCTP
*"     REFERENCE(EVENT) TYPE  ZHMS_DE_EVENT OPTIONAL
*"     REFERENCE(SCENA) TYPE  ZHMS_DE_SCENA OPTIONAL
*"  TABLES
*"      MSGDATA STRUCTURE  ZHMS_ES_MSGDT OPTIONAL
*"      MSGATRB STRUCTURE  ZHMS_ES_MSGAT OPTIONAL
*"  EXCEPTIONS
*"      NATURE_NOT_INFORMED
*"      DOCUMENT_TYPE_NOT_INFORMED
*"      EVENT_SCENERY_NOT_INFORMED
*"----------------------------------------------------------------------

* Inicializar Variáveis internas
  PERFORM f_exec_inicializa_variaveis TABLES  msgdata
                                              msgatrb
                                       USING  natdc
                                              typed
                                              loctp
                                              event
                                              scena.

* Buscar fluxo do fluxos
  PERFORM f_seleciona_fluxos.

* Buscar fluxo do evento
  PERFORM f_executa_fluxos.

* Geração do FORM principal dinâmico
  PERFORM f_trata_execucoes.

  IF NOT v_protine IS INITIAL
     AND v_protine NE 'SAPLZHMS_FG_RULER'.
* Execução do código dinâmico
    PERFORM f_executa_main IN PROGRAM (v_protine).

* Atualizar Mneumônicos de documento com base nos dados mapeados
    PERFORM f_atualiza_mn.

  ENDIF.

* Atualizar Status do documento
  PERFORM f_atualiza_st.

* Chamada de execução adjacente
  PERFORM f_executa_chamada.

ENDFUNCTION.
