FUNCTION zhms_fm_mapping_rotina.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(ID_ROTINA) TYPE  ZHMS_DE_ROTIN OPTIONAL
*"----------------------------------------------------------------------

  CHECK id_rotina IS NOT INITIAL.

  CASE id_rotina.
    WHEN 'F_GET_CHAVE'.
      PERFORM f_get_chave.
    WHEN 'F_GET_VERSAO'.
      PERFORM f_get_versao.
    WHEN 'F_GET_AMBIENTE'.
      PERFORM f_get_ambiente.
    WHEN 'F_GET_CNPJ'.
      PERFORM f_get_cnpj.
  ENDCASE.


ENDFUNCTION.
