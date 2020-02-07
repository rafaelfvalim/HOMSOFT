*-------------------------------------------------------------------*
*           HomSoft - Documentos Eletrônicos : Connector            *
*-------------------------------------------------------------------*
* Descrição	: RFC para conexão entre o sistema SAP e                *
*    o HomSoft: Quazaris                                            *
*-------------------------------------------------------------------*
FUNCTION zhms_fm_quazaris_in .
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(EXNAT) TYPE  ZHMS_DE_EXNAT
*"     VALUE(EXTPD) TYPE  ZHMS_DE_EXTPD
*"     VALUE(MENSG) TYPE  ZHMS_DE_MENSG
*"     VALUE(EXEVT) TYPE  ZHMS_DE_EXEVT
*"     VALUE(DIREC) TYPE  ZHMS_DE_DIREC
*"     VALUE(CHAVE) TYPE  ZHMS_DE_CHAVE OPTIONAL
*"     VALUE(LOGGER) TYPE  ZHMS_DE_TEXTO OPTIONAL
*"  TABLES
*"      MSGDATA STRUCTURE  ZHMS_ES_MSGDT
*"      MSGATRB STRUCTURE  ZHMS_ES_MSGAT
*"      RETURN STRUCTURE  ZHMS_ES_RETURN
*"----------------------------------------------------------------------
  DATA: a,
        ls_debug TYPE zhms_tb_debug.
  DO .
    SELECT SINGLE *
      FROM zhms_tb_debug
      INTO ls_debug
      WHERE debug EQ 'X'.
    IF sy-subrc IS NOT INITIAL.
      EXIT.
    ENDIF.
  ENDDO.

  PERFORM f_inicializa_variaveis TABLES msgdata
                                        msgatrb
                                  USING direc
                                        mensg
                                        exnat
                                        extpd
                                        exevt.

  IF NOT v_critc IS INITIAL.
    PERFORM f_e_grava_criticas.
    EXIT.
  ENDIF.

  IF direc = 'E'.

    PERFORM f_entrada.

    IF v_critc IS INITIAL.
      IF v_natdc EQ '02' AND                "Natureza Recepcao
        ( v_event = '1' OR v_event = '01'). "Evento Recepcao
        wa_docum-dcnro = v_chave.
        wa_docum-dctyp = v_typed.
* Patricia
        wa_docum-chave = v_chave.
* Patricia
        APPEND wa_docum TO it_docum.

* Chamada do Executor de Tarefas HomSoft - Nova task para não travar o Quazaris
        CALL FUNCTION 'ZHMS_FM_TRACER'
*    STARTING NEW TASK 'ZHMS_FM_TRACER'
          EXPORTING
            natdc                 = v_natdc
            typed                 = v_typed
            loctp                 = v_loctp
          TABLES
            docum                 = it_docum
          EXCEPTIONS
            document_not_informed = 1
            scenario_not_found    = 2
            OTHERS                = 3.

*** inicio inclusão David Rosin (Alerta Nova Nota no portal)
        PERFORM f_email_nova_nfe.
*-------------------
*Renan Itokazo
*21.09.2018
*Correção de entrada de lote XML
        REFRESH: it_docum.
        CLEAR: wa_docum, v_chave.
*-----------------
      ENDIF.
    ENDIF.
  ENDIF.
  CLEAR v_chave. "10/01/2019

ENDFUNCTION.
