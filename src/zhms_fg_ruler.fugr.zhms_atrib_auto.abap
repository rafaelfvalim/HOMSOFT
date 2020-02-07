FUNCTION zhms_atrib_auto.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  EXPORTING
*"     VALUE(VL_ERRO) TYPE  FLAG
*"----------------------------------------------------------------------

  CALL FUNCTION 'ZHMS_ATRIB_AUTO_IN'
    EXPORTING
      chave   = v_chave
      natdc   = v_natdc
      typed   = v_typed
    IMPORTING
      vl_erro = vl_erro.

ENDFUNCTION.
