*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_VALIDATEF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INICIALIZA_VARIAVEIS
*&---------------------------------------------------------------------*
*       Inicializar Variáveis internas
*----------------------------------------------------------------------*
FORM f_inicializa_variaveis  USING    p_vldcd
                                      p_cabdoc.
** limpa variaveis
  CLEAR:   v_vldcd, wa_cabdoc, wa_hrvalid, wa_hvalid.
  REFRESH: it_hrvalid, it_hvalid, it_stgrp.

** Valores recebidos pela função
  v_vldcd   = p_vldcd.
  wa_cabdoc = p_cabdoc.

** Seleciona os dados de cabeçalho da validação
  CLEAR wa_pkgvld.
  SELECT SINGLE *
    INTO wa_pkgvld
    FROM zhms_tb_pkgvld
   WHERE vldcd EQ v_vldcd.

** Caso tenha encontrado registro busca as regras
  IF sy-subrc IS INITIAL.
    REFRESH it_regvld.
    SELECT *
      INTO TABLE it_regvld
      FROM zhms_tb_regvld
     WHERE vldcd EQ v_vldcd.
  ENDIF.

** Seleciona os dados de documento
  IF NOT wa_cabdoc IS INITIAL.

** Repositório de Mneumonicos
    REFRESH it_docmn.
    SELECT *
      INTO TABLE it_docmn
      FROM zhms_tb_docmn
     WHERE chave EQ wa_cabdoc-chave.

** Dados de Item
    REFRESH it_itmdoc.
    SELECT *
      INTO TABLE it_itmdoc
      FROM zhms_tb_itmdoc
     WHERE natdc EQ wa_cabdoc-natdc
       AND typed EQ wa_cabdoc-typed
       AND loctp EQ wa_cabdoc-loctp
       AND chave EQ wa_cabdoc-chave.

** Dados de Atribuição
    REFRESH it_itmatr.
    IF NOT it_itmdoc[] IS INITIAL.
      SELECT *
        INTO TABLE it_itmatr
        FROM zhms_tb_itmatr
         FOR ALL ENTRIES IN it_itmdoc
       WHERE natdc EQ it_itmdoc-natdc
         AND typed EQ it_itmdoc-typed
         AND loctp EQ it_itmdoc-loctp
         AND chave EQ it_itmdoc-chave
         AND dcitm EQ it_itmdoc-dcitm.
    ENDIF.

** Dados de Status
    CLEAR wa_docst.
    SELECT SINGLE *
      INTO wa_docst
      FROM zhms_tb_docst
     WHERE natdc EQ wa_cabdoc-natdc
       AND typed EQ wa_cabdoc-typed
       AND loctp EQ wa_cabdoc-loctp
       AND chave EQ wa_cabdoc-chave.

  ENDIF.

** Inicia os dados da tabela de histórico
  CLEAR wa_hvalid.
  wa_hvalid-natdc = wa_cabdoc-natdc.
  wa_hvalid-typed = wa_cabdoc-typed.
  wa_hvalid-loctp = wa_cabdoc-loctp.
  wa_hvalid-chave = wa_cabdoc-chave.
  wa_hvalid-dtreg = sy-datum.
  wa_hvalid-hrreg = sy-uzeit.
  wa_hvalid-uname = sy-uname.
  wa_hvalid-vldcd = v_vldcd.
*wa_hvalid-VLDTY =

**** Inicio inclusão David Rosin Validação para CNPJ
*  IF wa_pkgvld-derot IS NOT INITIAL.
*    PERFORM (wa_pkgvld-derot) IN PROGRAM saplzhms_fg_validate IF FOUND.
*  ENDIF.

ENDFORM.                    " F_INICIALIZA_VARIAVEIS

*&---------------------------------------------------------------------*
*&      Form  F_REGISTRA_RESULTADOS
*&---------------------------------------------------------------------*
*     Trata resultados encontrados
*----------------------------------------------------------------------*
FORM f_registra_resultados USING p_reghist CHANGING p_vldty.

** Variáveis locais
  DATA: vl_seqnr TYPE zhms_de_seqnr.

** Identifica qual o resultado final da validação
  wa_hvalid-vldty = 'S'.

** Se encontrou Warning
  READ TABLE it_hrvalid INTO wa_hrvalid WITH KEY vldty = 'W'.
  IF sy-subrc IS INITIAL.
    wa_hvalid-vldty = 'W'.
    p_vldty = 'W'.
  ENDIF.

** Se encontrou Erro
  READ TABLE it_hrvalid INTO wa_hrvalid WITH KEY vldty = 'E'.
  IF sy-subrc IS INITIAL.
    wa_hvalid-vldty = 'E'.
    p_vldty = 'E'.
  ENDIF.

** Ajusta Sequencia de logs
  LOOP AT it_hrvalid INTO wa_hrvalid.
    vl_seqnr = vl_seqnr + 1.
    wa_hrvalid-seqnr = vl_seqnr.

    CONDENSE wa_hrvalid-seqnr NO-GAPS.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = wa_hrvalid-seqnr
      IMPORTING
        output = wa_hrvalid-seqnr.


    MODIFY it_hrvalid FROM wa_hrvalid INDEX sy-tabix.
  ENDLOOP.

** caso seja validação de etapa não registrar no histórico
  IF NOT p_reghist IS INITIAL OR p_vldty EQ 'E'.
** Insere resultados na tabela de Histórico - Cabeçalho
*** verifica se ja existe esse erro
    SELECT SINGLE * FROM zhms_tb_hvalid INTO wa_hvalidx WHERE natdc EQ wa_hvalid-natdc
                                                          AND typed EQ wa_hvalid-typed
                                                          AND chave EQ wa_hvalid-chave
                                                          AND vldcd EQ wa_hvalid-vldcd
                                                          AND vldty EQ wa_hvalid-vldty.

    IF sy-subrc IS INITIAL.
      UPDATE zhms_tb_hvalid
      SET dtreg = sy-datum
          hrreg = sy-uzeit
          WHERE natdc EQ wa_hvalid-natdc
            AND typed EQ wa_hvalid-typed
            AND chave EQ wa_hvalid-chave
            AND vldcd EQ wa_hvalid-vldcd
            AND vldty EQ wa_hvalid-vldty.
      IF sy-subrc IS INITIAL.
        COMMIT WORK AND WAIT.
      ELSE.
        ROLLBACK WORK.
      ENDIF.
    ELSE.
      MODIFY zhms_tb_hvalid FROM wa_hvalid.
      IF sy-subrc IS INITIAL.
        COMMIT WORK AND WAIT.
      ELSE.
        ROLLBACK WORK.
      ENDIF.
    ENDIF.

*** Verifica se já existe o erro
    LOOP AT it_hrvalid INTO wa_hrvalid.
      SELECT SINGLE * FROM zhms_tb_hrvalid INTO wa_hrvalidx WHERE natdc EQ wa_hrvalid-natdc
                                                              AND typed EQ wa_hrvalid-typed
                                                              AND chave EQ wa_hrvalid-chave
                                                              AND atitm EQ wa_hrvalid-atitm
                                                              AND vldty EQ wa_hrvalid-vldty
                                                              AND vldv2 EQ wa_hrvalid-vldv2.

      IF sy-subrc IS INITIAL.
        UPDATE zhms_tb_hrvalid
        SET dtreg = sy-datum
            hrreg = sy-uzeit
            ativo = abap_true
            WHERE natdc EQ wa_hrvalid-natdc
              AND typed EQ wa_hrvalid-typed
              AND chave EQ wa_hrvalid-chave
              AND atitm EQ wa_hrvalid-atitm
              AND vldty EQ wa_hrvalid-vldty
              AND vldv2 EQ wa_hrvalid-vldv2.
        IF sy-subrc IS INITIAL.
          COMMIT WORK AND WAIT.
        ELSE.
          ROLLBACK WORK.
        ENDIF.
      ELSE.
        MODIFY zhms_tb_hrvalid FROM wa_hrvalid.
        IF sy-subrc IS INITIAL.
          COMMIT WORK AND WAIT.
        ELSE.
          ROLLBACK WORK.
        ENDIF.
      ENDIF.

    ENDLOOP.

  ENDIF.

ENDFORM.                    " F_REGISTRA_RESULTADOS

*&---------------------------------------------------------------------*
*&      Form  F_VALIDAR_GPR
*&---------------------------------------------------------------------*
**   Executa a validação de grupo
*----------------------------------------------------------------------*
FORM f_validar_gpr USING p_grpcd
                         p_itmatr.

* Variáveis locais
  DATA:  vl_stop TYPE flag.

* Início do grupo
  CLEAR wa_stgrp.
  wa_stgrp-grpcd = p_grpcd. "Código do grupo
  wa_stgrp-vldty = 'S'.     "Sucesso - Será alterado caso alguma regra não seja atendida

* Percorrer estrutura de Validação para grupo indicado
  LOOP AT it_regvld
     INTO wa_regvld
    WHERE grpcd EQ p_grpcd.

*   Tratamento de premissa de execução
    CLEAR vl_stop.
    PERFORM f_vld_predecessoras CHANGING vl_stop.
    CHECK vl_stop IS INITIAL.

*   Assign de valor de origem (valor identificado no FORM manual)
    PERFORM f_vld_origem_value USING p_itmatr.

*   Identificação Mneumônico
    PERFORM f_vld_setmneum USING p_itmatr.

*   Comparação cadastrada na tabela
    PERFORM f_vld_comparar USING p_itmatr.

  ENDLOOP.

* fim do grupo
  APPEND wa_stgrp TO it_stgrp.

ENDFORM.                    " F_VALIDAR_GPR

*&---------------------------------------------------------------------*
*&      Form  F_VLD_ORIGEM_VALUE
*&---------------------------------------------------------------------*
*       Assign de valor de origem
*----------------------------------------------------------------------*
FORM f_vld_origem_value  USING    p_itmatr STRUCTURE zhms_tb_itmatr.

*  Identificação do tipo de origem
  CASE wa_regvld-tpvar.
    WHEN 'VC'.
*     Assign de variável
      ASSIGN (wa_regvld-tbfld) TO <or_value>.

    WHEN 'WA'.
*     Assign de workarea
      ASSIGN: (wa_regvld-tbnam) TO <or_worka>.

*     Assign do campo da tabela
      ASSIGN COMPONENT wa_regvld-tbfld OF STRUCTURE <or_worka> TO <or_value>.

    WHEN OTHERS.
*     Valor Fixo
      IF NOT wa_regvld-vlfix IS INITIAL.
        ASSIGN COMPONENT 'VLFIX' OF STRUCTURE wa_regvld TO <or_value>.
      ENDIF.
  ENDCASE.

*     Execução de Rotina
  IF NOT wa_regvld-rotin IS INITIAL.

    IF <or_value> IS ASSIGNED.
      PERFORM (wa_regvld-rotin) IN PROGRAM saplzhms_fg_validate USING p_itmatr CHANGING <or_value> IF FOUND.
    ENDIF.

  ENDIF.

ENDFORM.                    " F_VLD_ORIGEM_VALUE

*&---------------------------------------------------------------------*
*&      Form  F_VLD_COMPARAR
*&---------------------------------------------------------------------*
*       Comparação cadastrada na tabela
*----------------------------------------------------------------------*
FORM f_vld_comparar  USING   p_itmatr STRUCTURE zhms_tb_itmatr.
**  Variáveis locais
  DATA: vl_error TYPE flag,
        vl_check TYPE flag,
        vl_tabix TYPE sy-tabix.

  CLEAR: vl_error, vl_check.
  IF <mn_value> IS ASSIGNED
    AND <or_value> IS ASSIGNED.

**  Tratamento para as opções cadastradas no operador
    CASE wa_regvld-opera.
      WHEN 'EQ'. " igual
        IF <mn_value> EQ <or_value>.
          vl_check = 'X'.
        ELSE.
          vl_error = 'X'.
        ENDIF.

      WHEN 'GT'. " maior
        IF <mn_value> GT <or_value>.
          vl_check = 'X'.
        ELSE.
          vl_error = 'X'.
        ENDIF.

      WHEN 'GE'. " Maior ou igual
        IF <mn_value> GE <or_value>.
          vl_check = 'X'.
        ELSE.
          vl_error = 'X'.
        ENDIF.

      WHEN 'LT'. " menor
        IF <mn_value> LT <or_value>.
          vl_check = 'X'.
        ELSE.
          vl_error = 'X'.
        ENDIF.

      WHEN 'LE'. " menor ou igual
        IF <mn_value> LE <or_value>.
          vl_check = 'X'.
        ELSE.
          vl_error = 'X'.
        ENDIF.

      WHEN 'NE'. " Diferente
        IF <mn_value> NE <or_value>.
          vl_check = 'X'.
        ELSE.
          vl_error = 'X'.
        ENDIF.

      WHEN OTHERS.

    ENDCASE.
  ELSE.
    vl_error = 'X'.
  ENDIF.
** Registra o resultado na tabela interna de histórico de regras
  CLEAR wa_hrvalid.

  wa_hrvalid-natdc = wa_cabdoc-natdc.
  wa_hrvalid-typed = wa_cabdoc-typed.
  wa_hrvalid-loctp = wa_cabdoc-loctp.
  wa_hrvalid-chave = wa_cabdoc-chave.
  wa_hrvalid-dtreg = wa_hvalid-dtreg.
  wa_hrvalid-hrreg = wa_hvalid-hrreg.
  wa_hrvalid-regcd = wa_regvld-regcd.
  wa_hrvalid-atitm = p_itmatr-atitm.

  IF <mn_value> IS ASSIGNED.
    wa_hrvalid-vldv1 = <mn_value>.
  ELSE.
    CLEAR wa_hrvalid-vldv1.
  ENDIF.

  IF <or_value> IS ASSIGNED.
    wa_hrvalid-vldv2 = <or_value>.
  ELSE.
    CLEAR wa_hrvalid-vldv2.
  ENDIF.

  IF NOT vl_check IS INITIAL.
    wa_hrvalid-vldty = 'S'.
  ELSE.
    wa_hrvalid-vldty = wa_regvld-criti.
  ENDIF.

  APPEND wa_hrvalid TO it_hrvalid.

**  Identifica a regra onde o grupo está
  IF NOT wa_regvld-grpcd IS INITIAL.
    CLEAR wa_hrvalid_ax.
    READ TABLE it_hrvalid INTO wa_hrvalid_ax WITH KEY regcd = wa_regvld-grpcd.
    IF sy-subrc IS INITIAL.
      vl_tabix = sy-tabix.
    ELSE.
      CLEAR vl_tabix.
    ENDIF.

**  Registra no grupo o resultado
    IF wa_stgrp-vldty EQ 'S' "Caso o Status atual seja Sucesso
      AND wa_hrvalid-vldty NE 'S'. "E o novo status não seja sucesso
      wa_stgrp-vldty = wa_hrvalid-vldty.
      wa_hrvalid_ax-vldty = wa_hrvalid-vldty.
    ENDIF.

    IF wa_stgrp-vldty EQ 'W' "Caso o Status atual seja Warning
    AND wa_hrvalid-vldty EQ 'E'. "E o novo status seja erro
      wa_stgrp-vldty = wa_hrvalid-vldty.
      wa_hrvalid_ax-vldty = wa_hrvalid-vldty.
    ENDIF.

**  Tratamento para registro do grupo
    IF NOT vl_tabix IS INITIAL.
      MODIFY it_hrvalid FROM wa_hrvalid_ax INDEX vl_tabix.
    ELSE.
      wa_hrvalid_ax-natdc = wa_cabdoc-natdc.
      wa_hrvalid_ax-typed = wa_cabdoc-typed.
      wa_hrvalid_ax-loctp = wa_cabdoc-loctp.
      wa_hrvalid_ax-chave = wa_cabdoc-chave.
      wa_hrvalid_ax-dtreg = wa_hvalid-dtreg.
      wa_hrvalid_ax-hrreg = wa_hvalid-hrreg.
      wa_hrvalid_ax-regcd = wa_regvld-grpcd.
      wa_hrvalid_ax-vldty = wa_hrvalid-vldty.
      APPEND wa_hrvalid_ax TO it_hrvalid.
    ENDIF.
  ENDIF.

  DATA: ls_vld_item TYPE zhms_tb_vld_item.

*** Inicio inclusão David Rosin

  REFRESH: it_itmdoc[], it_itmatr[].

  MOVE: wa_itmdoc-natdc TO ls_vld_item-natdc,
        wa_itmdoc-typed TO ls_vld_item-typed,
        wa_itmdoc-chave TO ls_vld_item-chave,
        wa_itmdoc-dcitm TO ls_vld_item-atitm.

  SELECT *
    FROM zhms_tb_itmdoc
    INTO TABLE it_itmdoc
   WHERE natdc EQ ls_vld_item-natdc     AND
         typed EQ ls_vld_item-typed     AND
         chave EQ ls_vld_item-chave.

  SELECT *
    FROM zhms_tb_itmatr
    INTO TABLE it_itmatr
     FOR ALL ENTRIES IN it_itmdoc
   WHERE natdc EQ it_itmdoc-natdc     AND
         typed EQ it_itmdoc-typed     AND
         loctp EQ it_itmdoc-loctp     AND
         chave EQ it_itmdoc-chave.

  IF sy-subrc IS INITIAL.

    CLEAR wa_itmatr.
    READ TABLE it_itmatr INTO wa_itmatr WITH KEY dcitm = wa_itmdoc-dcitm.

    IF sy-subrc IS INITIAL.
      MOVE wa_itmatr-atmat TO ls_vld_item-matnr.
    ENDIF.

  ENDIF.

  CASE vl_error.
    WHEN space.
      MOVE 'S' TO ls_vld_item-vldty.
    WHEN abap_true.
      MOVE 'E' TO ls_vld_item-vldty.
    WHEN OTHERS.
  ENDCASE.

  MODIFY zhms_tb_vld_item FROM ls_vld_item.

  IF sy-subrc IS INITIAL.
    COMMIT WORK.
  ELSE.
    ROLLBACK WORK.
  ENDIF.
*** Fim inclusão David Rosin

ENDFORM.                    " F_VLD_COMPARAR

*&---------------------------------------------------------------------*
*&      Form  F_VLD_SETMNEUM
*&---------------------------------------------------------------------*
*       Identificação Mneumônico
*----------------------------------------------------------------------*
FORM f_vld_setmneum  USING  p_itmatr STRUCTURE zhms_tb_itmatr.

* Carrega Tabela de Mneumônicos
  IF p_itmatr IS INITIAL.
    READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = wa_regvld-mneum.
  ELSEIF wa_regvld-mneum(2) EQ 'AT'. "Tratamento de Atribuição - MNEUMONICO DERIVADO
    READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = wa_regvld-mneum
                                               atitm = p_itmatr-atitm.
  ELSEIF wa_regvld-mneum(2) NE 'AT'. "Tratamento de Atribuição - MNEUMONICO NAO DERIVADO
    READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = wa_regvld-mneum
                                               dcitm = p_itmatr-dcitm.
    IF NOT sy-subrc IS INITIAL.
      READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = wa_regvld-mneum
                                                 atitm = '00000'.
    ENDIF.
  ENDIF.

  IF sy-subrc IS INITIAL.
*     Assign do campo da tabela
    ASSIGN COMPONENT 'VALUE' OF STRUCTURE wa_docmn TO <mn_value>.
*    Remove espaços em branco do campo string
    IF <mn_value> IS ASSIGNED.
      CONDENSE <mn_value> NO-GAPS.
    ENDIF.

  ENDIF.

* Execução de Rotina
  IF NOT wa_regvld-rotin IS INITIAL.
    IF <mn_value> IS ASSIGNED.
      PERFORM (wa_regvld-rotin) IN PROGRAM saplzhms_fg_ruler USING p_itmatr CHANGING <mn_value> IF FOUND.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_VLD_SETMNEUM
*&---------------------------------------------------------------------*
*&      Form  F_VLD_PREDECESSORAS
*&---------------------------------------------------------------------*
*   Tratamento de premissa de execução
*----------------------------------------------------------------------*
FORM f_vld_predecessoras CHANGING p_stop.
** variáveis locais
  DATA: tl_predec TYPE TABLE OF string,
        wl_predec TYPE string.

**  Identifica predecessoras
  SPLIT wa_regvld-prede AT ',' INTO TABLE tl_predec.

**  Percorre lista de predecessoras
  LOOP AT tl_predec INTO wl_predec.
**  Procura a regra na tabela de histórico
    CLEAR wa_hrvalid_ax.
    READ TABLE it_hrvalid INTO wa_hrvalid_ax WITH KEY regcd = wa_regvld-grpcd.
**  Caso encontre verifica se não está errada
    IF sy-subrc IS INITIAL.
**    Se estiver pára o processamento
      IF wa_hrvalid_ax-vldty EQ 'E'.
        p_stop = 'X'.
      ENDIF.
    ELSE.
**    Caso não encontre pára o processamento
      p_stop = 'X'.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " F_VLD_PREDECESSORAS
*&---------------------------------------------------------------------*
*&      Form  f_valida_cnpj
*&---------------------------------------------------------------------*
*  Verifica se o CNPJ existe
*----------------------------------------------------------------------*
FORM f_valida_cnpj.

  CLEAR: wa_docmnx , vg_lifnr, wa_lfb1, vg_message, wa_hrvalid.

*** Seleciona CNPJ
  SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx WHERE chave EQ wa_cabdoc-chave
                                                      AND mneum EQ 'CNPJ'.

  IF sy-subrc IS INITIAL.

*** Verifica se existe Fornecedor para esse CNPJ
    SELECT SINGLE lifnr FROM lfa1 INTO vg_lifnr WHERE stcd1 EQ wa_docmnx-value.

    IF sy-subrc IS INITIAL.
*** Verifica se existe empresa
      SELECT SINGLE * FROM lfb1 INTO wa_lfb1 WHERE lifnr EQ vg_lifnr
                                               AND bukrs EQ wa_cabdoc-bukrs.
      IF sy-subrc IS INITIAL.
*** Verifica se o fornecedor não esta bloqueado
        SELECT SINGLE * FROM lfb1 INTO wa_lfb1 WHERE lifnr EQ vg_lifnr
                                                 AND bukrs EQ wa_cabdoc-bukrs
                                                 AND sperr NE '0'.
        IF sy-subrc IS NOT INITIAL.
*          MESSAGE e002(zhms_vld) WITH wa_cabdoc-bukrs INTO vg_message.
        ENDIF.
      ELSE.
*        MESSAGE e001(zhms_vld) WITH wa_cabdoc-bukrs INTO vg_message.
      ENDIF.
    ELSE.
*      MESSAGE e000(zhms_vld) INTO vg_message.
    ENDIF.
  ENDIF.

  IF vg_message IS NOT INITIAL. " Armazena Log de validações

    CLEAR wa_hrvalid.
    MOVE:  wa_cabdoc-natdc TO wa_hrvalid-natdc,
           wa_cabdoc-typed TO wa_hrvalid-typed,
           wa_cabdoc-loctp TO wa_hrvalid-loctp,
           wa_cabdoc-chave TO wa_hrvalid-chave,
           '1'             TO wa_hrvalid-seqnr,
           sy-datum        TO wa_hrvalid-dtreg,
           sy-uzeit        TO wa_hrvalid-hrreg,
           'E'             TO wa_hrvalid-vldty,
           'CNPJ'          TO wa_hrvalid-vldv1,
           vg_message      TO wa_hrvalid-vldv2,
           'X'             TO wa_hrvalid-ativo.
    MODIFY zhms_tb_hrvalid FROM wa_hrvalid.

  ELSE.

    SELECT SINGLE *
      FROM zhms_tb_hrvalid
      INTO wa_hrvalid
     WHERE chave EQ wa_cabdoc-chave
       AND vldv1 EQ 'CNPJ'
       AND ativo EQ 'X'.

    IF sy-subrc IS INITIAL.
      UPDATE zhms_tb_hrvalid
      SET ativo = ' '
      WHERE chave EQ wa_cabdoc-chave
        AND vldv1 EQ 'CNPJ'.
    ENDIF.

  ENDIF.

ENDFORM.                    "f_valida_cnpj
