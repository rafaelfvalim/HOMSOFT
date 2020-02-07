REPORT ZHMS_EXLUI_CHAVE .

    DELETE FROM zhms_tb_docmn  WHERE chave NE ' '.

    IF sy-subrc IS INITIAL.
      COMMIT WORK.
      WRITE 'Registros eliminados com sucesso tabela zhms_tb_docmn '
COLOR COL_POSITIVE.
    ELSE.
      ROLLBACK WORK.
      WRITE 'Erro ao eliminar registros na tabelazhms_tb_docmn '
COLOR COL_NEGATIVE.
    ENDIF.

        DELETE FROM zhms_tb_docmn_hs  WHERE chave NE ' '.

    IF sy-subrc IS INITIAL.
      COMMIT WORK.
      WRITE 'Registros eliminados com sucesso tabela zhms_tb_docmn_hs '
COLOR COL_POSITIVE.
    ELSE.
      ROLLBACK WORK.
      WRITE 'Erro ao eliminar registros na tabelazhms_tb_docmn_hs '
COLOR COL_NEGATIVE.
    ENDIF.

    DELETE FROM zhms_tb_docmna  WHERE chave NE ' '.

    IF sy-subrc IS INITIAL.
      COMMIT WORK.
      WRITE 'Registros eliminados com sucesso tabela zhms_tb_docmna'
COLOR COL_POSITIVE.
    ELSE.
      ROLLBACK WORK.
      WRITE 'Erro ao eliminar registros na tabela zhms_tb_docmna '
COLOR COL_NEGATIVE.
    ENDIF.

    DELETE FROM zhms_tb_repdoc WHERE chave NE ' '.

    IF sy-subrc IS INITIAL.
      COMMIT WORK.
      WRITE 'Registros eliminados com sucesso tabela zhms_tb_repdoc'
COLOR COL_POSITIVE.
    ELSE.
      ROLLBACK WORK.
      WRITE 'Erro ao eliminar registros na tabela zhms_tb_repdoc '
COLOR COL_NEGATIVE.
    ENDIF.

    DELETE FROM zhms_tb_repdocat WHERE chave NE ' '.

    IF sy-subrc IS INITIAL.
      COMMIT WORK.
      WRITE 'Registros eliminados com sucesso tabela zhms_tb_repdocat'
COLOR COL_POSITIVE.
    ELSE.
      ROLLBACK WORK.
      WRITE 'Erro ao eliminar registros na tabela zhms_tb_repdocat '
COLOR COL_NEGATIVE.
    ENDIF.

    DELETE FROM zhms_tb_cabdoc WHERE chave NE ' '.

    IF sy-subrc IS INITIAL.
      WRITE 'Registros eliminados com sucesso tabela zhms_tb_cabdoc'
COLOR COL_POSITIVE.
      COMMIT WORK.
    ELSE.
      ROLLBACK WORK.
      WRITE 'Erro ao eliminar registros na tabela zhms_tb_cabdoc '
COLOR COL_NEGATIVE.
    ENDIF.

    DELETE FROM zhms_tb_itmdoc WHERE chave NE ' '.

    IF sy-subrc IS INITIAL.
      WRITE 'Registros eliminados com sucesso tabela zhms_tb_itmdoc'
COLOR COL_POSITIVE.
      COMMIT WORK.
    ELSE.
      ROLLBACK WORK.
      WRITE 'Erro ao eliminar registros na tabela zhms_tb_itmdoc '
COLOR COL_NEGATIVE.
    ENDIF.

    DELETE FROM zhms_tb_docst WHERE chave NE ' '.

    IF sy-subrc IS INITIAL.
      WRITE 'Registros eliminados com sucesso tabela zhms_tb_docst'
COLOR COL_POSITIVE.
      COMMIT WORK.
    ELSE.
      ROLLBACK WORK.
      WRITE 'Erro ao eliminar registros na tabela zhms_tb_itmdoc '
COLOR COL_NEGATIVE.
    ENDIF.


*** Limpa Eventos
  DELETE FROM zhms_tb_evmn WHERE chave NE ' '.

  IF sy-subrc IS INITIAL.
    WRITE 'Registros eliminados com sucesso tabela ZHMS_TB_EVMN'
COLOR COL_POSITIVE.
    COMMIT WORK.
  ELSE.
    ROLLBACK WORK.
    WRITE 'Erro ao eliminar registros na tabela ZHMS_TB_EVMN '     COLOR
 COL_NEGATIVE.
  ENDIF.

  DELETE FROM zhms_tb_evmna WHERE chave NE ' '.

  IF sy-subrc IS INITIAL.
    WRITE 'Registros eliminados com sucesso tabela ZHMS_TB_EVMNA'
COLOR COL_POSITIVE.
    COMMIT WORK.
  ELSE.
    ROLLBACK WORK.
    WRITE 'Erro ao eliminar registros na tabela ZHMS_TB_EVMNA'     COLOR
 COL_NEGATIVE.
  ENDIF.

  DELETE FROM zhms_tb_evst WHERE chave NE ' '.

  IF sy-subrc IS INITIAL.
    WRITE 'Registros eliminados com sucesso tabela ZHMS_TB_EVST'
COLOR COL_POSITIVE.
    COMMIT WORK.
  ELSE.
    ROLLBACK WORK.
    WRITE 'Erro ao eliminar registros na tabela ZHMS_TB_EVST'     COLOR
COL_NEGATIVE.
  ENDIF.

  DELETE FROM zhms_tb_repcom WHERE chave NE ' '.

  IF sy-subrc IS INITIAL.
    WRITE 'Registros eliminados com sucesso tabela ZHMS_TB_REPCOM'
COLOR COL_POSITIVE.
    COMMIT WORK.
  ELSE.
    ROLLBACK WORK.
    WRITE 'Erro ao eliminar registros na tabela ZHMS_TB_REPCOM'
COLOR COL_NEGATIVE.
  ENDIF.

  DELETE FROM zhms_tb_repcoma WHERE chave NE ' '.

  IF sy-subrc IS INITIAL.
    WRITE 'Registros eliminados com sucesso tabela ZHMS_TB_REPCOMA'
COLOR COL_POSITIVE.
    COMMIT WORK.
  ELSE.
    ROLLBACK WORK.
    WRITE 'Erro ao eliminar registros na tabela ZHMS_TB_REPCOMA'
COLOR COL_NEGATIVE.
  ENDIF.

  DELETE FROM zhms_tb_cabeve WHERE chave NE ' '.

  IF sy-subrc IS INITIAL.
    WRITE 'Registros eliminados com sucesso tabela ZHMS_TB_CABEVE'
COLOR COL_POSITIVE.
    COMMIT WORK.
  ELSE.
    ROLLBACK WORK.
    WRITE 'Erro ao eliminar registros na tabela ZHMS_TB_CABEVE'
COLOR COL_NEGATIVE.
endif.
