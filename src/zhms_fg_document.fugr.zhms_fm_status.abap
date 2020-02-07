FUNCTION zhms_fm_status.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(CABDOC) TYPE  ZHMS_TB_CABDOC
*"----------------------------------------------------------------------
*& RCP - Tradução EN/ES - 15/08/2018                                   *

**  Limpar variável de status
  CLEAR vg_sthms.

**  Obter Status atual
  PERFORM f_trata_st USING cabdoc.

**  Atualiza status
  UPDATE zhms_tb_docst
     SET sthms = vg_sthms
   WHERE natdc EQ cabdoc-natdc
     AND typed EQ cabdoc-typed
     AND loctp EQ cabdoc-loctp
     AND chave EQ cabdoc-chave.
  COMMIT WORK AND WAIT.

ENDFUNCTION.
