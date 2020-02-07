FUNCTION zhms_fm_obter_valor.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(P_CAMPO) TYPE  ZHMS_DE_CHAVE OPTIONAL
*"     REFERENCE(P_INPUT) TYPE  C OPTIONAL
*"  EXPORTING
*"     VALUE(P_OUTPUT) TYPE  ZHMS_DE_CHAVE
*"----------------------------------------------------------------------
  DATA: vl_chave TYPE zhms_de_chave.


  IF p_input EQ 'X'.

    vl_chave = p_campo.

  ELSE.

    p_output = vl_chave.

  ENDIF.


ENDFUNCTION.
