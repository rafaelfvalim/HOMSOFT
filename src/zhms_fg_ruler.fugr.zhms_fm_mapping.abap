*-------------------------------------------------------------------*
*   HomSoft - Documentos Eletrônicos : Automator/Connector: Ruler   *
*-------------------------------------------------------------------*
* Descrição	: RFC para conexão entre o sistema SAP e                *
*    o HomSoft: Quazaris                                            *
*-------------------------------------------------------------------*
FUNCTION zhms_fm_mapping .
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(CODMP) TYPE  ZHMS_DE_CODMP
*"     REFERENCE(FUNCT) TYPE  ZHMS_DE_FUNCT OPTIONAL
*"     REFERENCE(FLOWD) TYPE  ZHMS_DE_FLOWD
*"  TABLES
*"      MSGDATA STRUCTURE  ZHMS_ES_MSGDT OPTIONAL
*"      MSGATRB STRUCTURE  ZHMS_ES_MSGAT OPTIONAL
*"      DOCUM STRUCTURE  ZHMS_ES_DOCUM OPTIONAL
*"  EXCEPTIONS
*"      MAPPING_NOT_FOUND
*"----------------------------------------------------------------------

* Inicializar Variáveis internas
  PERFORM f_map_inicializa_variaveis TABLES  msgdata
                                             msgatrb
                                      USING  codmp
                                             funct
                                             flowd.

* Selecionar parametros de mapeamento
  PERFORM f_seleciona_mapeamento.

* Prepara as variáveis dinamicas que serão utilizadas no mapeamento
  PERFORM f_prepara_variaveis.

* Criação do código dinânimico para a execução do mapeamento
  PERFORM f_trata_codigo.


ENDFUNCTION.
