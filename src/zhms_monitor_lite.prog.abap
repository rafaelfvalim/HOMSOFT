*----------------------------------------------------------------------*
*                      H  o  m  S  o  f  t                             *
*          Gestão Eletrônica de Documentos e Processos                 *
*----------------------------------------------------------------------*
* Descrição: Monitor Central de Gerenciamento de Documentos            *
*            Grupo Funções Principal do Monitor                        *
*----------------------------------------------------------------------*
* RCP - Tradução EN/ES - 13/08/2018                                    *
*----------------------------------------------------------------------*
REPORT  zhms_monitor_lite MESSAGE-ID zhms_mc_monitor.

INCLUDE: zhms_monitor_lite_top.
INCLUDE: zhms_monitor_lite_f01.
INCLUDE: zhms_monitor_lite_pai.
INCLUDE: zhms_monitor_lite_pbo.

START-OF-SELECTION.

  SELECT *
    FROM zhms_tb_cabdoc
    INTO TABLE t_cabdoc
    WHERE bukrs   IN s_bukrs
      AND branch  IN s_branch
      AND docnr   IN s_docnr
      AND chave   IN s_chave
      AND parid   IN s_parid
      AND lncdt   IN s_lncdt.

  IF sy-subrc EQ 0.
    vg_natdc = '02'.
    vg_typed = 'NFE'.

    SELECT *
      INTO TABLE t_lfa1
      FROM lfa1
       FOR ALL ENTRIES IN t_cabdoc
     WHERE lifnr EQ t_cabdoc-parid.

    SELECT *
      INTO TABLE t_kna1
      FROM kna1
       FOR ALL ENTRIES IN t_cabdoc
     WHERE kunnr EQ t_cabdoc-parid.

***     Status de Documento
    SELECT *
      INTO TABLE t_docst
      FROM zhms_tb_docst
       FOR ALL ENTRIES IN t_cabdoc
     WHERE natdc EQ t_cabdoc-natdc
       AND typed EQ t_cabdoc-typed
       AND chave EQ t_cabdoc-chave.

* Verifica MIGO x MIRO externa
*    PERFORM zf_check_auto_ext.

***     Documentos Referenciados
    SELECT *
      INTO TABLE t_docrf
      FROM zhms_tb_docrf
       FOR ALL ENTRIES IN t_cabdoc
     WHERE natdc EQ t_cabdoc-natdc
       AND typed EQ t_cabdoc-typed
       AND chave EQ t_cabdoc-chave.

    IF t_docrf[] IS NOT INITIAL.

***     Status de Documento refenciado
      SELECT *
        INTO TABLE t_docst_new
        FROM zhms_tb_docst
         FOR ALL ENTRIES IN t_docrf
       WHERE natdc EQ t_docrf-ntdrf
         AND typed EQ t_docrf-tpdrf
         AND chave EQ t_docrf-chvrf.

      LOOP AT t_docst_new INTO wa_docst.
        APPEND wa_docst TO t_docst.
      ENDLOOP.

***       Dados de documento refenciado
      SELECT *
        INTO TABLE t_cabdoc_ref
        FROM zhms_tb_cabdoc
         FOR ALL ENTRIES IN t_docrf
        WHERE natdc EQ t_docrf-ntdrf
          AND typed EQ t_docrf-tpdrf
          AND chave EQ t_docrf-chvrf.

      LOOP AT t_docrf INTO wa_docrf.
        CLEAR wa_docrf_es.
        MOVE-CORRESPONDING wa_docrf TO wa_docrf_es.
        READ TABLE t_cabdoc_ref INTO wa_cabdoc WITH KEY chave = wa_docrf-chvrf.
        wa_docrf_es-dcnro = wa_cabdoc-docnr.
        APPEND wa_docrf_es TO t_docrf_es.
      ENDLOOP.
    ENDIF.

    CALL SCREEN 0100.
  ENDIF.
