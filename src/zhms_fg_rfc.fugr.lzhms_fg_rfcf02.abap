*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_RFCF02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_SAIDA
*&---------------------------------------------------------------------*
*       Processamento para Mensagens de saída
*----------------------------------------------------------------------*
FORM f_saida .

* Selecionar mensageria
  PERFORM f_s_seleciona_mensageria.
** Filtro Mensageria
  PERFORM f_s_filtra_mensageria.
* Verifica se houve erro crítico no processamento.
  IF NOT v_critc IS INITIAL.
    EXIT.
  ENDIF.

** Seleção do evento da mensageria
  PERFORM f_s_seleciona_evento.
** Filtro Evento
  PERFORM f_s_filtra_evento.
* Verifica se houve erro crítico no processamento.
  IF NOT v_critc IS INITIAL.
    EXIT.
  ENDIF.

** Seleção de Verões de Layouts para Padrão HomSoft
  PERFORM f_s_selec_versao_padrao.
** Filtro de versões para Layout Padrão HomSoft
  PERFORM f_s_filtra_versao_padrao.
* Verifica se houve erro crítico no processamento.
  IF NOT v_critc IS INITIAL.
    EXIT.
  ENDIF.

** Seleção de Verões de Layouts da mensageria
  PERFORM f_s_selec_versoes_mensageria.
** Filtro de versões para Layout da mensageria
  PERFORM f_s_filtra_versao_mensageria.
* Verifica se houve erro crítico no processamento.
  IF NOT v_critc IS INITIAL.
    EXIT.
  ENDIF.

  PERFORM f_s_seleciona_layouts.
* Verifica se houve erro crítico no processamento.
  IF NOT v_critc IS INITIAL.
    EXIT.
  ENDIF.

  PERFORM f_s_transforma_padrao_msg.
  IF NOT v_critc IS INITIAL.
    EXIT.
  ENDIF.

  PERFORM f_s_grava_banco_reposit.


ENDFORM.                    " F_SAIDA
*&---------------------------------------------------------------------*
*&      Form  F_S_FILTRA_MENSAGERIA
*&---------------------------------------------------------------------*
*       Filtro Mensageria
*----------------------------------------------------------------------*
FORM f_s_filtra_mensageria .

* Verifica se foi encontrado registro
  IF it_messag[] IS INITIAL.
    v_critc = 'X'.
*   Tratamento de Erro
    CLEAR wa_logunk.
    wa_logunk-erro  = 'Erro: Tipo/Natureza não encontrados p/ mensageria'.
    PERFORM f_s_erro.
    EXIT.
  ENDIF.

* Veririca se multiplos registros foram encontrados
  CLEAR v_tabix.
  DESCRIBE TABLE it_messag LINES v_tabix.

  IF v_tabix GT 1.
    v_critc = 'X'.
*   Tratamento de Erro
    CLEAR wa_logunk.
    wa_logunk-erro  = 'Erro: Conflito em Tipo/Natureza p/ mensageria = muitos registros'.
    PERFORM f_s_erro.
    EXIT.
  ENDIF.

* Preenche as variáveis com os valores encontrados
  READ TABLE it_messag INTO wa_messag INDEX 1.
  IF sy-subrc IS INITIAL.
    v_loctp = wa_messag-loctp.
    v_mensg = wa_messag-mensg.
    v_exnat = wa_messag-exnat.
    v_extpd = wa_messag-extpd.
  ENDIF.

ENDFORM.                    " F_S_FILTRA_MENSAGERIA
*&---------------------------------------------------------------------*
*&      Form  F_S_SELECIONA_MENSAGERIA
*&---------------------------------------------------------------------*
*       Seleciona a Mensageria
*----------------------------------------------------------------------*
FORM f_s_seleciona_mensageria .
* Ajuste de Chave
  MOVE: v_exnat TO v_natdc,
        v_extpd TO v_typed,
        v_exevt TO v_event.

* Check de chave
  CHECK: v_natdc IS NOT INITIAL,
         v_typed IS NOT INITIAL.

* Seleção da Mensageria
  SELECT *
    INTO TABLE it_messag
    FROM zhms_tb_messagin
   WHERE natdc EQ v_natdc
     AND typed EQ v_typed.

ENDFORM.                    " F_S_SELECIONA_MENSAGERIA
*&---------------------------------------------------------------------*
*&      Form  F_S_SELECIONA_EVENTO
*&---------------------------------------------------------------------*
*       Seleciona Evento
*----------------------------------------------------------------------*
FORM f_s_seleciona_evento .
* Ajuste de Chave
  MOVE: v_exevt TO v_event.

* Check de chave
  CHECK: v_mensg IS NOT INITIAL,
         v_natdc IS NOT INITIAL,
         v_typed IS NOT INITIAL.

* Seleção de evento
  SELECT *
    INTO TABLE it_msgeve
    FROM zhms_tb_msg_even
   WHERE natdc  EQ  v_natdc
     AND typed  EQ  v_typed
     AND loctp  EQ  v_loctp
     AND mensg  EQ  v_mensg.

ENDFORM.                    " F_S_SELECIONA_EVENTO
*&---------------------------------------------------------------------*
*&      Form  F_S_FILTRA_EVENTO
*&---------------------------------------------------------------------*
*       Filtra Evento
*----------------------------------------------------------------------*
FORM f_s_filtra_evento .
*  Retira possíveis espaços antes e depois dos parametros recebidos
  CONDENSE: v_event.

  DELETE it_msgeve
   WHERE event NE v_event.

* Verifica se foi encontrado registro
  IF it_msgeve[] IS INITIAL.
    v_critc = 'X'.
*   Tratamento de Erro
    CLEAR wa_logunk.
    wa_logunk-erro = 'Erro: Evento não encontrado p/ mensageria'.
    PERFORM f_s_erro.
  ENDIF.

* Veririca se multiplos registros foram encontrados
  CLEAR v_tabix.
  DESCRIBE TABLE it_msgeve LINES v_tabix.

  IF v_tabix GT 1.
    v_critc = 'X'.
*   Tratamento de Erro
    CLEAR wa_logunk.
    wa_logunk-erro  = 'Erro: Conflito em Evento p/ mensageria = muitos registros'.
    PERFORM f_s_erro.
  ENDIF.

* Preenche as variáveis com os valores encontrados
  READ TABLE it_msgeve INTO wa_msgeve INDEX 1.
  IF sy-subrc IS INITIAL.
    v_exevt = wa_msgeve-exevt.
  ENDIF.

ENDFORM.                    " F_S_FILTRA_EVENTO
*&---------------------------------------------------------------------*
*&      Form  F_S_SELEC_VERSOES_MENSAGERIA
*&---------------------------------------------------------------------*
*      Seleciona versões da Mensageria
*----------------------------------------------------------------------*
FORM f_s_selec_versoes_mensageria .

* Check de chave
  CHECK: v_mensg IS NOT INITIAL,
         v_natdc IS NOT INITIAL,
         v_typed IS NOT INITIAL,
         v_event IS NOT INITIAL.

* Seleção de versões
  SELECT *
    INTO TABLE it_msgevr
    FROM zhms_tb_msge_vrs
   WHERE natdc EQ v_natdc
     AND typed EQ v_typed
     AND loctp EQ v_loctp
     AND mensg EQ v_mensg
     AND event EQ v_event
     AND versn EQ v_versn.

ENDFORM.                    " F_S_SELEC_VERSOES_MENSAGERIA
*&---------------------------------------------------------------------*
*&      Form  F_S_FILTRA_VERSAO_MENSAGERIA
*&---------------------------------------------------------------------*
FORM f_s_filtra_versao_mensageria .

* Remover Inativos
  DELETE it_msgevr WHERE ativo IS INITIAL.

* Verifica se foi encontrado registro
  IF it_msgevr[] IS INITIAL.
    v_critc = 'X'.
*   Tratamento de Erro
    CLEAR wa_logunk.
    wa_logunk-erro  = 'Erro: Nenhuma versao de layout ativa encontrado p/ evento da mensageria'.
    PERFORM f_s_erro.
  ENDIF.

ENDFORM.                    " F_S_FILTRA_VERSAO_MENSAGERIA
*&---------------------------------------------------------------------*
*&      Form  F_S_SELEC_VERSAO_PADRAO
*&---------------------------------------------------------------------*
*      Seleciona Versão Padrão
*----------------------------------------------------------------------*
FORM f_s_selec_versao_padrao .

* Check de chave
  CHECK: v_natdc IS NOT INITIAL,
         v_typed IS NOT INITIAL,
         v_event IS NOT INITIAL.

* Seleção de versões
  SELECT *
    INTO TABLE it_ev_vrs
    FROM zhms_tb_ev_vrs
   WHERE natdc EQ v_natdc
     AND typed EQ v_typed
     AND loctp EQ v_loctp
     AND event EQ v_event.

ENDFORM.                    " F_S_SELEC_VERSAO_PADRAO
*&---------------------------------------------------------------------*
*&      Form  F_S_FILTRA_VERSAO_PADRAO
*&---------------------------------------------------------------------*
*       Seleciona Versão Padrão
*----------------------------------------------------------------------*
FORM f_s_filtra_versao_padrao .
* remover inativos
  DELETE it_ev_vrs WHERE ativo IS INITIAL.

* Verifica se foi encontrado registro
  IF it_ev_vrs[] IS INITIAL.
    v_critc = 'X'.
*   Tratamento de Erro
    CLEAR wa_logunk.
    wa_logunk-erro  = 'Erro: Nenhuma versão de layout padrão ativa encontrado p/ evento'.
    PERFORM f_s_erro.
  ENDIF.

  READ TABLE it_ev_vrs INTO wa_ev_vrs INDEX 1.
  IF sy-subrc IS INITIAL.
    v_versn = wa_ev_vrs-versn.
  ENDIF.

* Verifica se foi encontrado registro
  IF v_versn IS INITIAL.
    v_critc = 'X'.
*   Tratamento de Erro
    CLEAR wa_logunk.
    wa_logunk-erro  = 'Erro: Nenhuma versão de layout padrão ativa p/ evento atende os parametros'.
    PERFORM f_s_erro.
  ENDIF.

ENDFORM.                    " F_S_FILTRA_VERSAO_PADRAO

*&---------------------------------------------------------------------*
*&      Form  F_RECEPCAO_DOC
*&---------------------------------------------------------------------*
*      Recepção de DOC
*----------------------------------------------------------------------*
FORM f_recepcao_doc.

* Limpeza de variáveis
  REFRESH:  it_mapdatac.

  CLEAR: wa_cabdoc,
         wa_docmn,
         wa_docst,
         wa_itmdoc,
         wa_mapdatac,
         v_critc.

  UNASSIGN: <fs_field>.

* Sequenciar Itens


** Verifica se a chave do documento já existe nas tabelas de sistema
  PERFORM f_verifica_chave.
  IF v_critc EQ 'X'.
    PERFORM f_e_grava_criticas.
    EXIT.
  ENDIF.

* Seleção dos dados de mapeamento
  SELECT *
    INTO TABLE it_mapdatac
    FROM zhms_tb_mapdatac
    WHERE codmp EQ wa_mapconec-codmp.

** Valida mapeamento do cabeçalho
  READ TABLE it_mapdatac INTO wa_mapdatac
  WITH KEY  tipoi = '1'. "Cabeçalho do Documento
  IF sy-subrc NE 0.
    v_critc = 'X'.
*   Tratamento de Erro
    CLEAR wa_logunk.
    wa_logunk-erro = 'Erro: Dados do Mapeamento para cabeçalho de documento não encontrado.'.
    PERFORM f_erro.
  ELSE.
    PERFORM f_valid_map_cabec.
  ENDIF.

** Valida mapeamento do item
  READ TABLE it_mapdatac INTO wa_mapdatac
  WITH KEY  tipoi = '2'. "Item do Documento
  IF sy-subrc NE 0.
    v_critc = 'X'.
*   Tratamento de Erro
    CLEAR wa_logunk.
    wa_logunk-erro = 'Erro: Dados do Mapeamento para item de documento não encontrado.'.
    PERFORM f_erro.
  ELSE.
    PERFORM f_valid_map_item.
  ENDIF.

** Valida mapeamento do Status
  READ TABLE it_mapdatac INTO wa_mapdatac
  WITH KEY  tipoi = '3'. "Status do Documento
  IF sy-subrc NE 0.
    v_critc = 'X'.
*   Tratamento de Erro
    CLEAR wa_logunk.
    wa_logunk-erro = 'Erro: Dados do Mapeamento para Status de documento não encontrado.'.
    PERFORM f_erro.
  ELSE.
    PERFORM f_valid_map_status.
  ENDIF.
  "Grava erros das validações
  IF v_critc EQ 'X'.
    PERFORM f_e_grava_criticas.
    EXIT.
  ENDIF.

**Trata dados cabeçalho
  LOOP AT it_mapdatac INTO wa_mapdatac
          WHERE tipoi = '1'. " Tipo Cabeçalho
    LOOP AT it_repomneum INTO wa_repomneum
        WHERE mneum EQ wa_mapdatac-mneum.
      PERFORM f_e_prepara_registro_cab.
    ENDLOOP.
  ENDLOOP.

**Trata dados de itens
  IF v_typed EQ 'CTE' OR v_typed EQ 'CTE1'.
    CLEAR wa_itmdoc.
    LOOP AT it_repomneum INTO wa_repomneum.
      READ TABLE it_mapdatac INTO wa_mapdatac
                          WITH KEY tipoi = '2' "Tipo Item de Documento
                                   mneum = wa_repomneum-mneum.
      IF sy-subrc EQ 0.
        PERFORM zf_prepara_registro_itmoutros.
      ENDIF.

      IF v_typed EQ 'CTE'.
        IF wa_repomneum-mneum EQ 'VICMS'.
          wa_repomneum-dcitm = 1.
          MODIFY it_repomneum FROM wa_repomneum.
        ENDIF.
      ENDIF.
    ENDLOOP.
    IF NOT wa_itmdoc IS INITIAL.
      wa_itmdoc-dcitm = '1'.
      wa_itmdoc-natdc = v_natdc.
      wa_itmdoc-chave = v_chave.
      wa_itmdoc-typed = v_typed.
      wa_itmdoc-loctp = v_loctp.
      wa_itmdoc-lote =  v_loted.
***Renan Itokazo - 08.08.2018 - Quando for NFS-e gravar o valor sempre como 1.
*      IF v_typed EQ 'NFSE1'.
*        wa_itmdoc-dcqtd = 1.
*      ENDIF.

      APPEND wa_itmdoc TO it_itmdoc.
    ELSEIF it_itmdoc[] IS  INITIAL.
      wa_itmdoc-dcitm = '1'.
      wa_itmdoc-natdc = v_natdc.
      wa_itmdoc-chave = v_chave.
      wa_itmdoc-typed = v_typed.
      wa_itmdoc-loctp = v_loctp.
      wa_itmdoc-lote =  v_loted.
      wa_itmdoc-dcqtd = '1'.

      APPEND wa_itmdoc TO it_itmdoc.

    ENDIF.
  ELSEIF v_typed EQ 'NFSE1'.

    CLEAR wa_itmdoc.
    LOOP AT it_repomneum INTO wa_repomneum.
      READ TABLE it_mapdatac INTO wa_mapdatac
                          WITH KEY tipoi = '2' "Tipo Item de Documento
                                   mneum = wa_repomneum-mneum.
      IF sy-subrc EQ 0.
        PERFORM zf_prepara_registro_itmnfse1.
      ENDIF.

    ENDLOOP.
    IF NOT wa_itmdoc IS INITIAL.
      IF  wa_itmdoc-dcitm IS INITIAL.
        wa_itmdoc-dcitm = '1'.
      ENDIF.
      wa_itmdoc-natdc = v_natdc.
      wa_itmdoc-chave = v_chave.
      wa_itmdoc-typed = v_typed.
      wa_itmdoc-loctp = v_loctp.
      wa_itmdoc-lote =  v_loted.

      wa_itmdoc-dcqtd = 1.


      APPEND wa_itmdoc TO it_itmdoc.
    ENDIF.

  ELSE.

    PERFORM f_e_preenche_dcitm.
    IF  v_critc = 'X'.
      PERFORM f_e_grava_criticas.
      EXIT.
    ENDIF.

    SORT it_repomneum BY seqnr dcitm.

    CLEAR wa_itmdoc.
    LOOP AT it_repomneum INTO wa_repomneum
      WHERE dcitm GT 0.
      READ TABLE it_mapdatac INTO wa_mapdatac
                          WITH KEY tipoi = '2' "Tipo Item de Documento
                                   mneum = wa_repomneum-mneum.
      IF sy-subrc EQ 0.
        PERFORM f_e_prepara_registro_itm.
      ENDIF.
    ENDLOOP.
    IF NOT wa_itmdoc IS INITIAL.
      wa_itmdoc-natdc = v_natdc.
      wa_itmdoc-chave = v_chave.
      wa_itmdoc-typed = v_typed.
      wa_itmdoc-loctp = v_loctp.
      wa_itmdoc-lote =  v_loted.

      APPEND wa_itmdoc TO it_itmdoc.
    ENDIF.
  ENDIF.

**Trata dados de status
  LOOP AT it_mapdatac INTO wa_mapdatac
          WHERE tipoi = '3'. "Tipo Status de Docto
    LOOP AT it_repomneum INTO wa_repomneum
        WHERE mneum EQ wa_mapdatac-mneum.
      PERFORM f_e_prepara_registro_stdoc.
    ENDLOOP.
  ENDLOOP.
  "Grava os erros de dados
  IF v_critc EQ 'X'.
    PERFORM f_e_grava_criticas.
    EXIT.
  ENDIF.

  PERFORM f_e_grava_banco_tabdocs.
  "Grava os erros se ocorrer gravação no banco
  IF v_critc EQ 'X'.
    PERFORM f_e_grava_criticas.
  ENDIF.

ENDFORM.                    "F_RECEPCAO_NFE
*&---------------------------------------------------------------------*
*&      Form  f_retorno_evento_mde
*&---------------------------------------------------------------------*
*       Retorno do Evento MDE
*----------------------------------------------------------------------*
FORM f_retorno_evento_mde.
* Limpeza de variáveis
  REFRESH: it_mapdatac,
           it_evmn,
           it_evmna,
           it_repcoma,
           it_repcom.

  CLEAR: wa_mapdatac,
         wa_evst,
         wa_histeve,
         v_critc,
         v_tpeve,
         v_nseqev.

  UNASSIGN: <fs_field>.

* Seleção dos dados de mapeamento para tabela de Eventos
  SELECT *
  INTO TABLE it_mapdatac
  FROM zhms_tb_mapdatac
  WHERE codmp EQ wa_mapconec-codmp.

  PERFORM f_verifica_chave_evento_mde.
  IF  v_critc = 'X'.
    PERFORM f_e_grava_criticas.
  ENDIF.

**trata dados cabeçalho do evento
  LOOP AT it_mapdatac INTO wa_mapdatac
    WHERE tipoi = '4'.
    LOOP AT it_repomneum INTO wa_repomneum
      WHERE mneum EQ wa_mapdatac-mneum.
      PERFORM f_e_prepara_registro_cabev.
    ENDLOOP.
  ENDLOOP.

**trata dados histórico do evento
  LOOP AT it_mapdatac INTO wa_mapdatac
    WHERE tipoi = '6'.
    LOOP AT it_repomneum INTO wa_repomneum
      WHERE mneum EQ wa_mapdatac-mneum.
      PERFORM f_e_prepara_registro_histev.
    ENDLOOP.
  ENDLOOP.

  "Ajusta as chaves
  LOOP AT it_repomneum INTO wa_repomneum.
    CLEAR wa_evmn.
    MOVE-CORRESPONDING wa_repomneum TO wa_evmn.
    wa_evmn-natdc   = v_natdc.
    wa_evmn-typed   = v_typed.
    wa_evmn-direc   = v_direc.
    wa_evmn-chave   = v_chave.
    wa_evmn-tpeve   = v_tpeve.
    CONDENSE v_nseqev NO-GAPS.
    wa_evmn-nseqev  = v_nseqev.
    wa_evmn-lote    = v_loted.
    wa_evmn-dtalt   = v_data.
    wa_evmn-hralt   = v_hora.
    wa_evmn-usuario   = 'QUAZARIS'.
    APPEND wa_evmn TO it_evmn.
  ENDLOOP.

  LOOP AT it_repomneumat INTO wa_repomneumat.
    CLEAR wa_evmna.
    MOVE-CORRESPONDING wa_repomneumat TO wa_evmna.
    wa_evmna-natdc   = v_natdc.
    wa_evmna-typed   = v_typed.
    wa_evmna-direc   = v_direc.
    wa_evmna-chave   = v_chave.
    wa_evmna-tpeve   = v_tpeve.
    CONDENSE v_nseqev NO-GAPS.
    wa_evmna-nseqev  = v_nseqev.
    wa_evmna-lote    = v_loted.
    APPEND wa_evmna TO it_evmna.
  ENDLOOP.

  LOOP AT it_repotag INTO wa_repotag.
    CLEAR wa_repcom.
    MOVE-CORRESPONDING wa_repotag TO wa_repcom.
    wa_repcom-natdc = v_natdc.
    wa_repcom-typed = v_typed.
    wa_repcom-event = v_event.
    wa_repcom-direc = v_direc.
    wa_repcom-chave = v_chave.
    wa_repcom-lote  = v_loted.
    wa_repcom-dtalt = v_data.
    wa_repcom-hralt = v_hora.
    APPEND wa_repcom TO it_repcom.
  ENDLOOP.

  LOOP AT it_repotagat INTO wa_repotagat.
    CLEAR wa_repcoma.
    MOVE-CORRESPONDING wa_repotagat TO wa_repcoma.
    wa_repcoma-natdc = v_natdc.
    wa_repcoma-typed = v_typed.
    wa_repcoma-event = v_event.
    wa_repcoma-direc = v_direc.
    wa_repcoma-chave = v_chave.
    wa_repcoma-lote  = v_loted.
    APPEND wa_repcoma TO it_repcoma.
  ENDLOOP.

  PERFORM f_e_grava_banco_eve.
  IF v_critc EQ 'X'.
    PERFORM f_e_grava_criticas.
  ENDIF.

ENDFORM.                    "f_retorno_evento_mde
*&---------------------------------------------------------------------*
*&      Form  F_E_PREPARA_REGISTRO_STEV
*&---------------------------------------------------------------------*
FORM f_e_prepara_registro_stev .
  ASSIGN COMPONENT wa_mapdatac-tbfld OF STRUCTURE wa_evst TO <fs_field>.
  IF sy-subrc EQ 0.
    <fs_field> = wa_repomneum-value.
  ENDIF.
ENDFORM.                    " F_E_PREPARA_REGISTRO_STEV

*&---------------------------------------------------------------------*
*&      Form  F_RETORNO_CONSULTA_DOC
*&---------------------------------------------------------------------*
FORM f_retorno_consulta_doc.
* Limpeza de variáveis
  REFRESH: it_mapdatac,
           it_evmn,
           it_evmna,
           it_repcoma,
           it_repcom.

  CLEAR: wa_mapdatac,
         wa_docst,
         wa_evmn,
         wa_evmna,
         v_critc.

  UNASSIGN: <fs_field>.

* Seleção dos dados de mapeamento para tabela de Eventos
  SELECT *
  INTO TABLE it_mapdatac
  FROM zhms_tb_mapdatac
  WHERE codmp EQ wa_mapconec-codmp.

  v_tpeve  = v_event.
  v_nseqev = '1'.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = v_tpeve
    IMPORTING
      output = v_tpeve.

**Trata dados cabeçalho do evento consulta
  LOOP AT it_mapdatac INTO wa_mapdatac
    WHERE tipoi = '3'.
    LOOP AT it_repomneum INTO wa_repomneum
        WHERE mneum EQ wa_mapdatac-mneum.
      PERFORM f_e_prepara_registro_stdoc.
    ENDLOOP.
  ENDLOOP.

**Trata dados
  LOOP AT it_mapdatac INTO wa_mapdatac WHERE
       tipoi = '6'.
    LOOP AT it_repomneum INTO wa_repomneum
        WHERE mneum EQ wa_mapdatac-mneum.
      PERFORM f_e_prepara_registro_histev.
    ENDLOOP.
  ENDLOOP.

  "Ajusta as chaves para repositórios de evento
  LOOP AT it_repomneum INTO wa_repomneum.
    MOVE-CORRESPONDING wa_repomneum TO wa_evmn.
    wa_evmn-natdc   = v_natdc.
    wa_evmn-typed   = v_typed.
    wa_evmn-direc   = v_direc.
    wa_evmn-chave   = v_chave.
    wa_evmn-tpeve   = v_tpeve.
    wa_evmn-nseqev  = v_nseqev.
    wa_evmn-lote    = v_loted.
    wa_evmn-dtalt   = v_data.
    wa_evmn-hralt   = v_hora.
    wa_evmn-usuario   = 'QUAZARIS'.
    APPEND wa_evmn TO it_evmn.
  ENDLOOP.

  LOOP AT it_repomneumat INTO wa_repomneumat.
    MOVE-CORRESPONDING wa_repomneumat TO wa_evmna.
    wa_evmna-natdc   = v_natdc.
    wa_evmna-typed   = v_typed.
    wa_evmna-direc   = v_direc.
    wa_evmna-chave   = v_chave.
    wa_evmna-tpeve   = v_tpeve.
    wa_evmna-nseqev  = v_nseqev.
    wa_evmna-lote    = v_loted.
    APPEND wa_evmna TO it_evmna.
  ENDLOOP.

  LOOP AT it_repotag INTO wa_repotag.
    CLEAR wa_repcom.
    MOVE-CORRESPONDING wa_repotag TO wa_repcom.
    wa_repcom-natdc = v_natdc.
    wa_repcom-typed = v_typed.
    wa_repcom-event = v_event.
    wa_repcom-direc = v_direc.
    wa_repcom-chave = v_chave.
    wa_repcom-lote  = v_loted.
    wa_repcom-dtalt = v_data.
    wa_repcom-hralt = v_hora.
    APPEND wa_repcom TO it_repcom.
  ENDLOOP.

  LOOP AT it_repotagat INTO wa_repotagat.
    CLEAR wa_repcoma.
    MOVE-CORRESPONDING wa_repotagat TO wa_repcoma.
    wa_repcoma-natdc = v_natdc.
    wa_repcoma-typed = v_typed.
    wa_repcoma-event = v_event.
    wa_repcoma-direc = v_direc.
    wa_repcoma-chave = v_chave.
    wa_repcoma-lote  = v_loted.
    APPEND wa_repcoma TO it_repcoma.
  ENDLOOP.

  PERFORM f_e_grava_banco_consdocto.
  IF v_critc = 'X'.
    PERFORM f_e_grava_criticas.
    EXIT.
  ENDIF.

  "Verifica se veio o Tipo de Evento MDE
  READ TABLE it_repomneum INTO wa_repomneum WITH KEY
                                            mneum = c_tpevemde.
  IF sy-subrc EQ 0.
    "Verifica se veio o retorno de MDE
    SELECT * INTO TABLE it_mapconec
      FROM zhms_tb_mapconec
    WHERE
      natdc = v_natdc AND
      typed = v_typed AND
      loctp = v_loctp AND
      mensg = v_mensg AND
      event = '5'. "Retorno do MDE

    CLEAR wa_mapconec.
    READ TABLE it_mapconec INTO wa_mapconec INDEX 1.

    PERFORM f_retorno_mde_consulta_doc.
    IF v_critc = 'X'.
      PERFORM f_e_grava_criticas.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.                    "F_RETORNO_CONSULTA_NFE

*&---------------------------------------------------------------------*
*&      Form  F_E_PREPARA_REGISTRO_STDOC
*&---------------------------------------------------------------------*
FORM f_e_prepara_registro_stdoc .
  DATA lr_cxroot TYPE REF TO cx_root.
  TRY.
      ASSIGN COMPONENT wa_mapdatac-tbfld OF STRUCTURE wa_docst TO <fs_field>.
      IF sy-subrc EQ 0.
        <fs_field> = wa_repomneum-value.
      ENDIF.
    CATCH cx_sy_conversion_overflow INTO lr_cxroot.
  ENDTRY.

ENDFORM.                    "f_e_prepara_registro_stdoc
*&---------------------------------------------------------------------*
*&      Form  F_S_ERRO
*&---------------------------------------------------------------------*

FORM f_s_erro .

  ADD 1 TO v_nrmsg.
  wa_logunk-nrmsg = v_nrmsg.
  wa_logunk-lote  = v_loted.
  wa_logunk-exnat = v_natdc.
  wa_logunk-extpd = v_typed.
  wa_logunk-mensg = v_mensg.
  wa_logunk-exevt = v_exevt.
  wa_logunk-dtalt = v_data.
  wa_logunk-hralt = v_hora.
  wa_logunk-usuar = v_usuar.
  wa_logunk-event = v_event.
  wa_logunk-natdc = v_natdc.
  wa_logunk-typed = v_typed.
  APPEND wa_logunk TO it_logunk.

ENDFORM.                    " F_S_ERRO
*&---------------------------------------------------------------------*
*&      Form  F_S_SELECIONA_LAYOUTS
*&---------------------------------------------------------------------*
FORM f_s_seleciona_layouts .

  " Encontra o Layout Padrão para tags
  SELECT *
  FROM zhms_tb_evv_layt
  INTO TABLE it_evv_layt
  WHERE
     natdc = v_natdc AND
     typed = v_typed AND
     event = v_event AND
     versn = v_versn.
  IF sy-subrc NE 0.
    v_critc = 'X'.
*   Tratamento de Erro
    CLEAR wa_logunk.
    wa_logunk-erro  =  'Erro: Nenhum Layout HomSoft encontrado para os parâmetros'.
    PERFORM f_s_erro.
    EXIT.
  ENDIF.

  SELECT *
  FROM zhms_tb_evvl_atr
  INTO TABLE it_evvl_atr
  WHERE
     natdc = v_natdc AND
     typed = v_typed AND
     event = v_event AND
     versn = v_versn.

  "Encontra o Layout para a Mensageria
  SELECT *
  FROM zhms_tb_msgev_lt
  INTO TABLE it_msgevlt
  WHERE
      natdc = v_natdc AND
      typed = v_typed AND
      mensg = v_mensg AND "Mensageria
      event = v_event AND "Evento interno
      versn = v_versn.
  IF sy-subrc NE 0.
    v_critc = 'X'.
*   Tratamento de Erro
    CLEAR wa_logunk.
    wa_logunk-erro  =  'Erro: Nenhum Layout Mensageria encontrado para os parâmetros'.
    PERFORM f_s_erro.
    EXIT.
  ENDIF.

  SELECT *
  INTO TABLE it_msgevl_a
    FROM zhms_tb_msgevl_a
  WHERE
      natdc = v_natdc AND
      typed = v_typed AND
      event = v_event AND
      loctp = v_loctp AND
      mensg = v_mensg AND "Mensageria
      versn = v_versn.

ENDFORM.                    " F_S_SELECIONA_LAYOUTS
*&---------------------------------------------------------------------*
*&      Form  F_S_TRANSFORMA_PADRAO_MSG
*&---------------------------------------------------------------------*
FORM f_s_transforma_padrao_msg .
  CLEAR: v_chave,
         v_tpeve,
         v_nseqev,
         v_seqnr.


  IF v_mensg = 'SIGNA'.
    v_extpd = v_exevt.
  ENDIF.

  "Verifica chave do documento
  PERFORM f_s_valida_chave_docto.
  IF NOT v_critc IS INITIAL.
    EXIT.
  ENDIF.

  "Verifica se têm a chave de TPEVE e SEQEVE quando for Evento
  IF v_event = '4'.
    PERFORM f_s_valida_chaves_evento_mde.
    IF NOT v_critc IS INITIAL.
      EXIT.
    ENDIF.
  ELSEIF v_event = '2' OR v_event = '6'.  "Consulta e Download
    v_tpeve  = v_event.
    v_nseqev = '1'.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = v_tpeve
      IMPORTING
        output = v_tpeve.
  ENDIF.

  SORT it_mssdatam BY seqnc dcitm.
  SORT it_evv_layt BY codly.
  SORT it_msgevlt  BY codly.

  "Layout Padrão para a Natureza/Tipo/Evento
  LOOP AT it_evv_layt INTO wa_evv_layt.
    CLEAR:  wa_mssdatam,
            wa_mssdata,
            wa_mssatrb,
            wa_mssatrbm.

    "Layout Mensageria para a Natureza/Tipo/Evento - TAGS
    READ TABLE  it_msgevlt INTO wa_msgevlt
                             WITH KEY
                                      codly = wa_evv_layt-codly.
    IF sy-subrc EQ 0.
      "Verifica a tabela de tags enviada
      READ TABLE it_mssdatam INTO wa_mssdatam
                             WITH KEY
                                    mneum = wa_evv_layt-mneum.
      IF sy-subrc EQ 0.
        wa_mssdata-field = wa_msgevlt-field.
        wa_mssdata-dcitm = wa_mssdatam-dcitm.
        wa_mssdata-value = wa_mssdatam-value.
      ELSE.
        wa_mssdata-field = wa_msgevlt-field.
      ENDIF.
      "Sequência
      v_seqnr = v_seqnr + 1.
      CONDENSE v_seqnr NO-GAPS.
      wa_mssdata-seqnc = v_seqnr.

      APPEND wa_mssdata TO it_mssdata.

      "Grava no repositório de tags e de mneumônicos
      IF v_event = '2' OR   v_event = '4' OR v_event = '6'.
        PERFORM f_s_reposit_eventos.
      ENDIF.

      "Verifica se têm atributos para a tag no layout padrão
      READ TABLE  it_evvl_atr INTO wa_evvl_atr
      WITH KEY    codly = wa_evv_layt-codly.
      IF sy-subrc EQ 0.
        "Verifica se tem Atributos para a tag na mensageria
        READ TABLE it_msgevl_a INTO wa_msgevl_a
                               WITH KEY
                                       codly = wa_evv_layt-codly.
        IF sy-subrc EQ 0.
          CLEAR wa_mssatrb.
          wa_mssatrb-seqnc = v_seqnr.
          wa_mssatrb-field = wa_msgevl_a-field.
          "Lê o valor do Atributo
          READ TABLE it_mssatrbm INTO wa_mssatrbm
                                 WITH KEY
                                      mneum = wa_evvl_atr-mneum.
          IF sy-subrc EQ 0.
            wa_mssatrb-value = wa_mssatrbm-value.
          ELSE.
            wa_mssatrb-value = wa_msgevl_a-value.
          ENDIF.
          APPEND wa_mssatrb TO it_mssatrb.

          IF v_event = '2' OR   v_event = '4' OR v_event = '6'.
            PERFORM f_s_reposit_eventosat.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " F_S_TRANSFORMA_PADRAO_MSG
*&---------------------------------------------------------------------*
*&      Form  F_S_GRAVA_SAIDA_REPOSIT
*&---------------------------------------------------------------------*
FORM f_s_grava_banco_reposit .

  "Valida se as tabelas principais estão populadas
  IF it_repcom[] IS INITIAL OR it_evmn[] IS INITIAL.
    v_critc = 'X'.
*   Tratamento de Erro
    CLEAR wa_logunk.
    wa_logunk-erro =  'Erro: Tabelas de repositório não possuem registros.' .
    PERFORM f_s_erro.
    EXIT.
  ENDIF.

  TRY .
      INSERT zhms_tb_repcom FROM TABLE it_repcom.
    CATCH cx_root.
*  IF sy-subrc NE 0.
      ROLLBACK WORK.
      v_critc = 'X'.
*   Tratamento de Erro
      CLEAR wa_logunk.
      wa_logunk-erro =  'Erro: na Gravação dos registros na tabela zhms_tb_repcom.' .
      PERFORM f_s_erro.
      EXIT.
*  ENDIF.
  ENDTRY.

  TRY .
      INSERT zhms_tb_repcoma FROM TABLE it_repcoma.
    CATCH cx_root.
*  IF sy-subrc NE 0.
      ROLLBACK WORK.
      v_critc = 'X'.
*   Tratamento de Erro
      CLEAR wa_logunk.
      wa_logunk-erro =  'Erro: na Gravação dos registros na tabela zhms_tb_repcoma.' .
      PERFORM f_s_erro.
      EXIT.
*  ENDIF.
  ENDTRY.

  DELETE FROM zhms_tb_evmn
  WHERE
    natdc = v_natdc AND
    typed = v_typed AND
    direc = v_direc AND
    chave = v_chave AND
    tpeve = v_tpeve AND
    nseqev = v_nseqev.

  TRY .
      INSERT zhms_tb_evmn FROM TABLE it_evmn.
    CATCH cx_root.
*  IF sy-subrc NE 0.
      ROLLBACK WORK.
      v_critc = 'X'.
*   Tratamento de Erro
      CLEAR wa_logunk.
      wa_logunk-erro =  'Erro: na Gravação dos registros na tabela zhms_tb_evmn.' .
      PERFORM f_s_erro.
      EXIT.
*  ENDIF.
  ENDTRY.

  DELETE FROM zhms_tb_evmna
  WHERE
  natdc = v_natdc AND
  typed = v_typed AND
  direc = v_direc AND
  chave = v_chave AND
  tpeve = v_tpeve AND
  nseqev = v_nseqev.

  TRY .
      INSERT zhms_tb_evmna FROM TABLE it_evmna.
    CATCH cx_root.
*  IF sy-subrc NE 0.
      ROLLBACK WORK.
      v_critc = 'X'.
*   Tratamento de Erro
      CLEAR wa_logunk.
      wa_logunk-erro =  'Erro: na Gravação dos registros na tabela zhms_tb_evmna.' .
      PERFORM f_s_erro.
      EXIT.
*  ENDIF.
  ENDTRY.

  IF v_event = '4'.
    UPDATE zhms_tb_cabeve
      SET
        lote = v_loted
    WHERE
        natdc  =  v_natdc AND
        typed  =  v_typed AND
        chave  =  v_chave AND
        tpeve  =  v_tpeve AND
        nseqev =  v_nseqev.

    IF sy-subrc NE 0.
      ROLLBACK WORK.
      v_critc = 'X'.
****   Tratamento de Erro
      CLEAR wa_logunk.
      wa_logunk-erro =  'Erro: na Atualização do lote na tabela zhms_tb_cabev.' .
      PERFORM f_s_erro.
      EXIT.
    ENDIF.
  ENDIF.

  "Tabela de Histórico
  wa_histeve-natdc = v_natdc.
  wa_histeve-typed = v_typed.
  wa_histeve-event = v_event.
  wa_histeve-chave = v_chave.
  wa_histeve-tpeve = v_tpeve.
  wa_histeve-nseqev = v_nseqev.
  wa_histeve-lote = v_loted.
  wa_histeve-dataenv = sy-datum.
  wa_histeve-horaenv = sy-uzeit.
  wa_histeve-usuario = v_usuar.

  TRY .
      INSERT zhms_tb_histev FROM wa_histeve.
    CATCH cx_root.
*  IF sy-subrc NE 0.
      ROLLBACK WORK.
      v_critc = 'X'.
*   Tratamento de Erro
      CLEAR wa_logunk.
      wa_logunk-erro =  'Erro: na Gravação do histórico tabela zhms_tb_histev.' .
      PERFORM f_s_erro.
      EXIT.
*  ENDIF.
  ENDTRY.

  IF v_critc IS INITIAL.
    COMMIT WORK.
  ENDIF.

ENDFORM.                    " F_S_GRAVA_SAIDA_REPOSIT
*&---------------------------------------------------------------------*
*&      Form  F_S_REPOSIT_DOCTOS
*&---------------------------------------------------------------------*
FORM f_s_reposit_doctos .

ENDFORM.                    " F_S_REPOSIT_DOCTOS
*&---------------------------------------------------------------------*
*&      Form  F_S_REPOSIT_EVENTOS
*&---------------------------------------------------------------------*
FORM f_s_reposit_eventos .

  CLEAR: wa_evmn,
         wa_repcom.

  wa_evmn-natdc  = v_natdc.
  wa_evmn-typed  = v_typed.
  wa_evmn-direc  = v_direc.
  wa_evmn-chave  = v_chave.
  wa_evmn-tpeve  = v_tpeve.
  wa_evmn-nseqev = v_nseqev.
  wa_evmn-lote   = v_loted.
  wa_evmn-seqnr  = v_seqnr.
  wa_evmn-mneum  = wa_evv_layt-mneum.
  wa_evmn-value  = wa_mssdatam-value.
  wa_evmn-dtalt  = v_data.
  wa_evmn-hralt  = v_hora.
  wa_evmn-usuario  = v_usuar.
  APPEND wa_evmn TO it_evmn.

  wa_repcom-natdc = v_natdc.
  wa_repcom-typed = v_typed.
  wa_repcom-event = v_event.
  wa_repcom-direc = v_direc.
  wa_repcom-chave = v_chave.
  wa_repcom-lote  = v_loted.
  wa_repcom-seqnc = v_seqnr.
  wa_repcom-field = wa_msgevlt-field .
  wa_repcom-value = wa_mssdatam-value.
  wa_repcom-dtalt = v_data.
  wa_repcom-hralt = v_hora.
  APPEND wa_repcom TO it_repcom.

ENDFORM.                    " F_S_REPOSIT_EVENTOS
*&---------------------------------------------------------------------*
*&      Form  F_S_REPOSIT_DOCTOSAT
*&---------------------------------------------------------------------*
FORM f_s_reposit_doctosat .

ENDFORM.                    " F_S_REPOSIT_DOCTOSAT
*&---------------------------------------------------------------------*
*&      Form  F_S_REPOSIT_EVENTOSAT
*&---------------------------------------------------------------------*
FORM f_s_reposit_eventosat .
  CLEAR: wa_evmna,
         wa_repcoma.

  wa_evmna-natdc  = v_natdc.
  wa_evmna-typed  = v_typed.
  wa_evmna-direc  = v_direc.
  wa_evmna-chave  = v_chave.
  wa_evmna-tpeve  = v_tpeve.
  wa_evmna-nseqev = v_nseqev.
  wa_evmna-lote   = v_loted.
  wa_evmna-seqnr  = v_seqnr.
  wa_evmna-mneum  = wa_evvl_atr-mneum.
  wa_evmna-value  = wa_mssatrb-value.
  APPEND wa_evmna TO it_evmna.

  wa_repcoma-natdc = v_natdc.
  wa_repcoma-typed = v_typed.
  wa_repcoma-event = v_event.
  wa_repcoma-direc = v_direc.
  wa_repcoma-chave = v_chave.
  wa_repcoma-lote  = v_loted.
  wa_repcoma-seqnc = v_seqnr.
  wa_repcoma-field = wa_msgevl_a-field .
  wa_repcoma-value = wa_mssatrb-value.
  APPEND wa_repcoma TO it_repcoma.

ENDFORM.                    " F_S_REPOSIT_EVENTOSAT
*&---------------------------------------------------------------------*
*&      Form  F_S_GRAVA_ERROS_BANCO
*&---------------------------------------------------------------------*
FORM f_s_grava_erros_banco .

  TRY .
      INSERT zhms_tb_logunk FROM TABLE it_logunk.
    CATCH cx_root.

  ENDTRY.

  "Tabela de Histórico
  wa_histeve-natdc = v_natdc.
  wa_histeve-typed = v_typed.
  wa_histeve-event = v_event.
  wa_histeve-chave = v_chave.
  wa_histeve-tpeve = v_tpeve.
  wa_histeve-nseqev = v_nseqev.
  wa_histeve-lote = v_loted.
  wa_histeve-dataenv = sy-datum.
  wa_histeve-horaenv = sy-uzeit.
  wa_histeve-usuario = v_usuar.

  CONCATENATE 'Não enviado para o Quazaris. Ver Log de Erros Nr. Lote: ' v_loted INTO
  wa_histeve-xmotivo.

  TRY .
      INSERT zhms_tb_histev FROM wa_histeve.
    CATCH cx_root.

  ENDTRY.


ENDFORM.                    " F_S_GRAVA_ERROS_BANCO
*&---------------------------------------------------------------------*
*&      Form  F_S_VALIDA_CHAVES_EVENTO
*&---------------------------------------------------------------------*

FORM f_s_valida_chaves_evento_mde .

  READ TABLE it_mssdatam INTO wa_mssdatam
                    WITH KEY mneum = c_tpevemde.
  IF sy-subrc NE 0.
    v_critc = 'X'.
*   Tratamento de Erro
    CLEAR wa_logunk.
    wa_logunk-erro  =  'Erro: Tipo de Evento não informado.'.
    PERFORM f_s_erro.
    EXIT.
  ELSE.
    v_tpeve = wa_mssdatam-value.
  ENDIF.

  READ TABLE it_mssdatam INTO wa_mssdatam
                     WITH KEY mneum = c_nseqevmde.
  IF sy-subrc NE 0.
    v_critc = 'X'.
*   Tratamento de Erro
    CLEAR wa_logunk.
    wa_logunk-erro  =  'Erro: Sequência do Evento não informada.'.
    PERFORM f_s_erro.
    EXIT.
  ELSE.
    v_nseqev = wa_mssdatam-value.
  ENDIF.

ENDFORM.                    " F_S_VALIDA_CHAVES_EVENTO
*&---------------------------------------------------------------------*
*&      Form  F_S_VALIDA_CHAVE_DOCTO
*&---------------------------------------------------------------------*
FORM f_s_valida_chave_docto .

  IF v_typed = 'CTE'.
    "Chave da CTe
    READ TABLE it_mssdatam INTO wa_mssdatam
                          WITH KEY mneum = c_chavecte.
  ELSE.
    "Chave da NFe
    READ TABLE it_mssdatam INTO wa_mssdatam
                          WITH KEY mneum = c_chave.
  ENDIF.

  IF sy-subrc NE 0.
    v_critc = 'X'.
*   Tratamento de Erro
    CLEAR wa_logunk.
    wa_logunk-erro  =  'Erro: Chave de Acesso não informada.'.
    PERFORM f_s_erro.
  ELSE.
    v_chave = wa_mssdatam-value.
  ENDIF.

ENDFORM.                    " F_S_VALIDA_CHAVE_DOCTO
*&---------------------------------------------------------------------*
*&      Form  F_E_GRAVA_BANCO_TABDOCS
*&---------------------------------------------------------------------*
FORM f_e_grava_banco_tabdocs .

  TRY .
      INSERT zhms_tb_repdoc FROM TABLE it_repotag.
    CATCH cx_root.
*  IF sy-subrc NE 0.
      ROLLBACK WORK.
      v_critc = 'X'.
*   Tratamento de Erro
      CLEAR wa_logunk.
      wa_logunk-erro = 'Erro inesperado na Gravação do Repositório de tags zhms_tb_repdoc'.
      PERFORM f_erro.
      EXIT.
*  ENDIF.
  ENDTRY.

  IF NOT it_repotagat[] IS INITIAL.
    TRY .
        INSERT zhms_tb_repdocat FROM TABLE it_repotagat.
      CATCH cx_root.
*    IF sy-subrc NE 0.
        ROLLBACK WORK.
        v_critc = 'X'.
*   Tratamento de Erro
        CLEAR wa_logunk.
        wa_logunk-erro = 'Erro inesperado na Gravação do Repositório de tags zhms_tb_repdocat'.
        PERFORM f_erro.
        EXIT.
*    ENDIF.
    ENDTRY.

  ENDIF.

  TRY .
      INSERT zhms_tb_docmn FROM TABLE it_repomneum.
    CATCH cx_root.
*  IF sy-subrc NE 0.
      ROLLBACK WORK.
      v_critc = 'X'.
*   Tratamento de Erro
      CLEAR wa_logunk.
      wa_logunk-erro = 'Erro inesperado na Gravação do Repositório de mneumônicos zhms_tb_docmn'.
      PERFORM f_erro.
      EXIT.
*  ENDIF.
  ENDTRY.

  IF NOT it_repomneumat[] IS INITIAL.
    TRY .
        INSERT zhms_tb_docmna FROM TABLE it_repomneumat.
      CATCH cx_root.
*    IF sy-subrc NE 0.
        ROLLBACK WORK.
        v_critc = 'X'.
*   Tratamento de Erro
        CLEAR wa_logunk.
        wa_logunk-erro = 'Erro inesperado na Gravação do Repositório de mneumônicos zhms_tb_docmna'.
        PERFORM f_erro.
        EXIT.
*    ENDIF.
    ENDTRY.
  ENDIF.

  "PK Tabela
  wa_cabdoc-chave = v_chave.
  wa_cabdoc-natdc = v_natdc.
  wa_cabdoc-typed = v_typed.
  wa_cabdoc-loctp = v_loctp.
  "Controle origem
  wa_cabdoc-lote  = v_loted.
  wa_cabdoc-dtalt = sy-datum.
  wa_cabdoc-hralt = sy-uzeit.
  wa_cabdoc-lncdt = sy-datum.

  TRY .
      INSERT zhms_tb_cabdoc FROM wa_cabdoc.
    CATCH cx_root.
*  IF sy-subrc NE 0.
      ROLLBACK WORK.
      v_critc = 'X'.
*   Tratamento de Erro
      CLEAR wa_logunk.
      wa_logunk-erro = 'Erro inesperado na Gravação do Cabeçalho de Documentos - zhms_tb_cabdoc'.
      PERFORM f_erro.
      EXIT.
*  ENDIF.
  ENDTRY.

  TRY .
      INSERT zhms_tb_itmdoc FROM TABLE it_itmdoc.
    CATCH cx_root.
*  IF sy-subrc NE 0.
      ROLLBACK WORK.
      v_critc = 'X'.
*   Tratamento de Erro
      CLEAR wa_logunk.
      wa_logunk-erro = 'Erro inesperado na Gravação dos Itens de Documentos - zhms_tb_itmdoc'.
      PERFORM f_erro.
      EXIT.
*  ENDIF.
  ENDTRY.

  "PK Tabela
  wa_docst-chave = v_chave.
  wa_docst-natdc = v_natdc.
  wa_docst-typed = v_typed.
  wa_docst-loctp = v_loctp.
  "Controle origem
  wa_docst-lote  = v_loted.
  wa_docst-dtalt = sy-datum.
  wa_docst-hralt = sy-uzeit.
  "Status HomSoft
  wa_docst-sthms = '2'.

  MODIFY zhms_tb_docst FROM wa_docst.
  IF sy-subrc NE 0.
    ROLLBACK WORK.
    v_critc = 'X'.
*   Tratamento de Erro
    CLEAR wa_logunk.
    wa_logunk-erro = 'Erro inesperado na Gravação dos Itens de Documentos - zhms_tb_docst'.
    PERFORM f_erro.
    EXIT.
  ENDIF.

*  "Chave
*  wa_histeve-natdc  =  v_natdc.
*  wa_histeve-typed  =  v_typed.
*  wa_histeve-event  =  v_event.
*  wa_histeve-chave  =  v_chave.
*  wa_histeve-tpeve  =  v_tpeve.
*  wa_histeve-nseqev =  v_nseqev.
*
*  "Controle
*  wa_histeve-lote    = v_loted.
*  wa_histeve-dataenv = sy-datum.
*  wa_histeve-horaenv = sy-uzeit.
*  wa_histeve-usuario = 'QUAZARIS'.
*
*  INSERT zhms_tb_histev FROM wa_histeve.
*  IF sy-subrc NE 0.
*    v_critc = 'X'.
*    ROLLBACK WORK.
**   Tratamento de Erro
*    CLEAR wa_logunk.
*    wa_logunk-erro = 'Erro inesperado ao inserir registro na tabela zhms_tb_histeve'.
*    PERFORM f_erro.
*  ENDIF.

  IF v_critc IS INITIAL.
    COMMIT WORK.
  ENDIF.

ENDFORM.                    " F_E_GRAVA_BANCO_TABDOCS
*&---------------------------------------------------------------------*
*&      Form  F_GRAVA_BANCO_RECEVE
*&---------------------------------------------------------------------*

FORM f_e_grava_banco_eve .
  DELETE FROM zhms_tb_evmn
     WHERE
     natdc = v_natdc AND
     typed = v_typed AND
     direc = v_direc AND
     chave = v_chave AND
     tpeve = v_tpeve AND
     nseqev = v_nseqev.

  TRY .
      INSERT zhms_tb_evmn FROM TABLE it_evmn.
    CATCH cx_root.
*  IF sy-subrc NE 0.
      v_critc = 'X'.
      ROLLBACK WORK.
*   Tratamento de Erro
      CLEAR wa_logunk.
      wa_logunk-erro = 'Erro inesperado ao inserir registro na tabela zhms_tb_evmn'.
      PERFORM f_erro.
      EXIT.
*  ENDIF.
  ENDTRY.

  DELETE FROM zhms_tb_evmna
    WHERE
    natdc = v_natdc AND
    typed = v_typed AND
    direc = v_direc AND
    chave = v_chave AND
    tpeve = v_tpeve AND
    nseqev = v_nseqev.

  IF NOT it_evmna[] IS INITIAL.
    TRY .
        INSERT zhms_tb_evmna FROM TABLE it_evmna.
      CATCH cx_root.
*    IF sy-subrc NE 0.
        v_critc = 'X'.
        ROLLBACK WORK.
*   Tratamento de Erro
        CLEAR wa_logunk.
        wa_logunk-erro = 'Erro inesperado ao inserir registro na tabela zhms_tb_evmna'.
        PERFORM f_erro.
        EXIT.
*    ENDIF.
    ENDTRY.

  ENDIF.

  TRY .
      INSERT zhms_tb_repcom FROM TABLE it_repcom.
    CATCH cx_root.
*  IF sy-subrc NE 0.
      v_critc = 'X'.
      ROLLBACK WORK.
*   Tratamento de Erro
      CLEAR wa_logunk.
      wa_logunk-erro = 'Erro inesperado ao inserir registro na tabela zhms_tb_repcom'.
      PERFORM f_erro.
      EXIT.
*  ENDIF.
  ENDTRY.

  IF NOT it_repcoma[] IS INITIAL.
    TRY .
        INSERT zhms_tb_repcoma FROM TABLE it_repcoma.
      CATCH cx_root.
*    IF sy-subrc NE 0.
        v_critc = 'X'.
        ROLLBACK WORK.
*   Tratamento de Erro
        CLEAR wa_logunk.
        wa_logunk-erro = 'Erro inesperado ao inserir registro na tabela zhms_tb_repcoma'.
        PERFORM f_erro.
*    ENDIF.
    ENDTRY.

  ENDIF.

  "Chave
  wa_histeve-natdc  =  v_natdc.
  wa_histeve-typed  =  v_typed.
  wa_histeve-event  =  v_event.
  wa_histeve-chave  =  v_chave.
  wa_histeve-tpeve  =  v_tpeve.
  wa_histeve-nseqev = v_nseqev.

  "Controle
  wa_histeve-lote    = v_loted.
  wa_histeve-dataenv = sy-datum.
  wa_histeve-horaenv = sy-uzeit.
  wa_histeve-usuario = 'QUAZARIS'.

  TRY .
      INSERT zhms_tb_histev FROM wa_histeve.
    CATCH cx_root.
*  IF sy-subrc NE 0.
      v_critc = 'X'.
      ROLLBACK WORK.
*   Tratamento de Erro
      CLEAR wa_logunk.
      wa_logunk-erro = 'Erro inesperado ao inserir registro na tabela zhms_tb_histeve'.
      PERFORM f_erro.
*  ENDIF.
  ENDTRY.

  IF v_critc IS INITIAL.
    COMMIT WORK.
  ENDIF.


ENDFORM.                    " F_GRAVA_BANCO_RECEVE
*&---------------------------------------------------------------------*
*&      Form  F_E_GRAVA_BANCO_CONSDOCTO
*&---------------------------------------------------------------------*
FORM f_e_grava_banco_consdocto .

  DELETE FROM zhms_tb_evmn
    WHERE
    natdc = v_natdc AND
    typed = v_typed AND
    direc = v_direc AND
    chave = v_chave AND
    tpeve = v_tpeve AND
    nseqev = v_nseqev.

  TRY .
      INSERT zhms_tb_evmn FROM TABLE it_evmn.
    CATCH cx_root.
*  IF sy-subrc NE 0.
      ROLLBACK WORK.
      v_critc = 'X'.
*   Tratamento de Erro
      CLEAR wa_logunk.
      wa_logunk-erro = 'Erro inesperado ao inserir registro na tabela ZHMS_TB_EVMN'.
      PERFORM f_erro.
      EXIT.
*  ENDIF.
  ENDTRY.

  DELETE FROM zhms_tb_evmna
   WHERE
   natdc = v_natdc AND
   typed = v_typed AND
   direc = v_direc AND
   chave = v_chave AND
   tpeve = v_tpeve AND
   nseqev = v_nseqev.

  IF NOT it_evmna[] IS INITIAL.
    TRY .
        INSERT zhms_tb_evmna FROM TABLE it_evmna.
      CATCH cx_root.
*    IF sy-subrc NE 0.
        ROLLBACK WORK.
        v_critc = 'X'.
*   Tratamento de Erro
        CLEAR wa_logunk.
        wa_logunk-erro = 'Erro inesperado ao inserir registro na tabela ZHMS_TB_EVMNA'.
        PERFORM f_erro.
        EXIT.
*    ENDIF.
    ENDTRY.

  ENDIF.

  TRY .
      INSERT zhms_tb_repcom FROM TABLE it_repcom.
    CATCH cx_root.
*  IF sy-subrc NE 0.
      ROLLBACK WORK.
      v_critc = 'X'.
*   Tratamento de Erro
      CLEAR wa_logunk.
      wa_logunk-erro = 'Erro inesperado ao inserir registro na tabela ZHMS_TB_REPCOM'.
      PERFORM f_erro.
      EXIT.
*  ENDIF.
  ENDTRY.

  IF NOT it_repcoma[] IS INITIAL.
    TRY .
        INSERT zhms_tb_repcoma FROM TABLE it_repcoma.
      CATCH cx_root.
        IF sy-subrc NE 0.
          ROLLBACK WORK.
          v_critc = 'X'.
*   Tratamento de Erro
          CLEAR wa_logunk.
          wa_logunk-erro = 'Erro inesperado ao inserir registro na tabela ZHMS_TB_REPCOMA'.
          PERFORM f_erro.
          EXIT.
        ENDIF.
    ENDTRY.
  ENDIF.

  "Chave tabela
  wa_docst-natdc = v_natdc.
  wa_docst-typed = v_typed.
  wa_docst-loctp = v_loctp.
  wa_docst-chave = v_chave.

  "Campos de controle
  wa_docst-lote  = v_loted.
  wa_docst-dtalt = sy-datum.
  wa_docst-hralt = sy-uzeit.

  MODIFY zhms_tb_docst FROM wa_docst.
  IF sy-subrc NE 0.
    v_critc = 'X'.
    ROLLBACK WORK.
*   Tratamento de Erro
    CLEAR wa_logunk.
    wa_logunk-erro = 'Erro inesperado ao atualizar status tabela ZHMS_TB_DOCST'.
    PERFORM f_erro.
    EXIT.
  ENDIF.

  "Chave
  wa_histeve-natdc  =  v_natdc.
  wa_histeve-typed  =  v_typed.
  wa_histeve-event  =  v_event.
  wa_histeve-chave  =  v_chave.
  wa_histeve-tpeve  =  v_tpeve.
  wa_histeve-nseqev =  v_nseqev.

  "Controle
  wa_histeve-lote    = v_loted.
  wa_histeve-dataenv = sy-datum.
  wa_histeve-horaenv = sy-uzeit.
  wa_histeve-usuario = 'QUAZARIS'.

  TRY .
      INSERT zhms_tb_histev FROM wa_histeve.
    CATCH cx_root.
*  IF sy-subrc NE 0.
      v_critc = 'X'.
      ROLLBACK WORK.
*   Tratamento de Erro
      CLEAR wa_logunk.
      wa_logunk-erro = 'Erro inesperado ao inserir registro na tabela zhms_tb_histeve'.
      PERFORM f_erro.
*  ENDIF.
  ENDTRY.

  IF v_critc IS INITIAL.
    COMMIT WORK.
  ENDIF.

ENDFORM.                    " F_E_GRAVA_BANCO_CONSDOCTO
*&---------------------------------------------------------------------*
*&      Form  F_E_PREENCHE_DCITM
*&---------------------------------------------------------------------*

FORM f_e_preenche_dcitm .

  CLEAR: v_dcitm,
         v_seqnr.

  SELECT SINGLE * INTO wa_fildcitm
  FROM zhms_tb_fildcitm
  WHERE
        codmp EQ wa_mapconec-codmp. "Igual ao Código de mapeamento do Layout no conector
  IF sy-subrc EQ 0.

    SELECT * INTO TABLE it_dcitm
    FROM zhms_tb_dcitm
    WHERE codmp EQ wa_fildcitm-codmp.
  ELSE.
    v_critc = 'X'.
*   Tratamento de Erro
    CLEAR wa_logunk.
    wa_logunk-erro = 'Erro: Parametrização para popular DCITM não encontrada.'.
    PERFORM f_erro.
    EXIT.
  ENDIF.

  SORT it_repomneum BY seqnr.
  "Preenche DCITM - Tabela Repositório de Mneumônicos
  LOOP AT it_repomneum INTO wa_repomneum.




    "Verifica se o Mneumônico é pai
    IF wa_fildcitm-mneumpai   = wa_repomneum-mneum.
      IF wa_fildcitm-mneumval = wa_repomneum-mneum.
        v_dcitm = wa_repomneum-value.
      ELSE.
        "Procura dentre os mneumônicos de atributo do pai
        READ TABLE it_repomneumat INTO wa_repomneumat
                                  WITH KEY
                                        mneum = wa_fildcitm-mneumval
                                        seqnr = wa_repomneum-seqnr.
        IF sy-subrc EQ 0.
          v_dcitm = wa_repomneumat-value.
        ENDIF.
      ENDIF.
      v_seqnr = wa_repomneum-seqnr.
    ENDIF.

    "Verifica se é filho para receber o DCITM
    READ TABLE it_dcitm INTO wa_dcitm
                   WITH KEY
                     mneumfil = wa_repomneum-mneum.
    IF sy-subrc EQ 0.
      "Verifica se a sequencia é maior que a do Pai
      IF wa_repomneum-seqnr GT v_seqnr.
        wa_repomneum-dcitm = v_dcitm.
        MODIFY it_repomneum FROM wa_repomneum.
      ENDIF.
    ENDIF.

  ENDLOOP.

  "Preenche DCITM - Tabela Repositório de Mneumônicos Atributos
  LOOP AT it_repomneumat INTO wa_repomneumat.

    READ TABLE it_repomneum INTO wa_repomneum
                            WITH KEY
                                  seqnr = wa_repomneumat-seqnr.
    IF sy-subrc EQ 0.
      IF NOT wa_repomneum-dcitm IS INITIAL.
        wa_repomneumat-dcitm = wa_repomneum-dcitm.
        MODIFY it_repomneumat FROM wa_repomneumat.
      ENDIF.
    ENDIF.

  ENDLOOP.

  "Verifica se o campo dcitm foi populado
*  READ TABLE it_repomneum INTO wa_repomneum
*                           WITH KEY dcitm = 1.

  CLEAR lv_find .
  LOOP AT it_repomneum INTO  wa_repomneum.
    IF NOT wa_repomneum-dcitm IS INITIAL.
      lv_find = 'X'.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF sy-subrc NE 0.
    v_critc = 'X'.
*   Tratamento de Erro
    CLEAR wa_logunk.
    wa_logunk-erro = 'Erro: O campo DCITM não foi populado.'.
    PERFORM f_erro.
    EXIT.
  ENDIF.

ENDFORM.                    " F_E_PREENCHE_DCITM
*&---------------------------------------------------------------------*
*&      Form  F_E_PREPARA_REGISTRO_ITMCTE
*&---------------------------------------------------------------------*
*FORM f_e_prepara_registro_itmoutros .
*
*  IF NOT wa_mapdatac-rotin IS INITIAL.
*    ASSIGN COMPONENT wa_mapdatac-tbfld OF STRUCTURE wa_itmdoc TO <fs_field>.
*    IF sy-subrc EQ 0.
*      PERFORM (wa_mapdatac-rotin) IN PROGRAM saplzhms_fg_rfc IF FOUND.
*    ENDIF.
*  ELSE.
*    ASSIGN COMPONENT wa_mapdatac-tbfld OF STRUCTURE wa_itmdoc TO <fs_field>.
*    IF sy-subrc EQ 0.
*      <fs_field> = wa_repomneum-value.
*    ENDIF.
*  ENDIF.
*
*  IF wa_repomneum-value IS INITIAL AND NOT wa_mapdatac-obrig IS INITIAL.
*    v_critc = 'X'.
**   Tratamento de Erro
*    CLEAR wa_logunk.
*    CONCATENATE 'Erro: Gravação Item Documento - Mneumônico '  wa_repomneum-mneum ' têm valor Nulo Sequência: '
*    wa_repomneum-seqnr INTO wa_logunk-erro.
*    PERFORM f_erro.
*  ENDIF.
*
*ENDFORM.                    " F_E_PREPARA_REGISTRO_ITMCTE
*&---------------------------------------------------------------------*
*&      Form  F_E_PREPARA_REGISTRO_HISTEV
*&---------------------------------------------------------------------*

FORM f_e_prepara_registro_histev .
  ASSIGN COMPONENT wa_mapdatac-tbfld OF STRUCTURE wa_histeve TO <fs_field>.
  IF sy-subrc EQ 0.
    <fs_field> = wa_repomneum-value.
  ENDIF.
ENDFORM.                    " F_E_PREPARA_REGISTRO_HISTEV
*&---------------------------------------------------------------------*
*&      Form  F_E_PREPARA_REGISTRO_CABEV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_e_prepara_registro_cabev .

  IF wa_repomneum-value = '89'.
    UPDATE zhms_tb_cabeve
    SET
       cstat = '3'
    WHERE
        natdc  = v_natdc AND
        typed  = v_typed AND
        chave  = v_chave AND
        tpeve  = v_tpeve AND
        nseqev = v_nseqev.
  ELSE.
    UPDATE zhms_tb_cabeve
    SET
      cstat = '2'
    WHERE
      natdc  = v_natdc AND
      typed  = v_typed AND
      chave  = v_chave AND
      tpeve  = v_tpeve AND
      nseqev = v_nseqev.
  ENDIF.

ENDFORM.                    " F_E_PREPARA_REGISTRO_CABEV
*&---------------------------------------------------------------------*
*&      Form  F_E_PREPARA_REGISTRO_ITMOUTROS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_e_prepara_registro_itmoutros .

  IF NOT wa_mapdatac-rotin IS INITIAL.
    ASSIGN COMPONENT wa_mapdatac-tbfld OF STRUCTURE wa_itmdoc TO <fs_field>.
    IF sy-subrc EQ 0.
      PERFORM (wa_mapdatac-rotin) IN PROGRAM saplzhms_fg_rfc IF FOUND.
    ENDIF.
  ELSE.
    ASSIGN COMPONENT wa_mapdatac-tbfld OF STRUCTURE wa_itmdoc TO <fs_field>.
    IF sy-subrc EQ 0.
      <fs_field> = wa_repomneum-value.
    ENDIF.
  ENDIF.

  IF wa_repomneum-value IS INITIAL AND NOT wa_mapdatac-obrig IS INITIAL.
    v_critc = 'X'.
*   Tratamento de Erro
    CLEAR wa_logunk.
    CONCATENATE 'Erro: Gravação Item Documento - Mneumônico '  wa_repomneum-mneum ' têm valor Nulo Sequência: '
    wa_repomneum-seqnr INTO wa_logunk-erro.
    PERFORM f_erro.
  ENDIF.

ENDFORM.                    " F_E_PREPARA_REGISTRO_ITMOUTROS
*&---------------------------------------------------------------------*
*&      Form  ZF_PREPARA_REGISTRO_ITMOUTROS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM zf_prepara_registro_itmoutros .

  IF NOT wa_mapdatac-rotin IS INITIAL.
    ASSIGN COMPONENT wa_mapdatac-tbfld OF STRUCTURE wa_itmdoc TO <fs_field>.
    IF sy-subrc EQ 0.
      PERFORM (wa_mapdatac-rotin) IN PROGRAM saplzhms_fg_rfc IF FOUND.
    ENDIF.
  ELSE.
    ASSIGN COMPONENT wa_mapdatac-tbfld OF STRUCTURE wa_itmdoc TO <fs_field>.
    IF sy-subrc EQ 0.
      <fs_field> = wa_repomneum-value.
    ENDIF.
  ENDIF.

  IF wa_repomneum-value IS INITIAL AND NOT wa_mapdatac-obrig IS INITIAL.
    v_critc = 'X'.
*   Tratamento de Erro
    CLEAR wa_logunk.
    CONCATENATE 'Erro: Gravação Item Documento - Mneumônico '  wa_repomneum-mneum ' têm valor Nulo Sequência: '
    wa_repomneum-seqnr INTO wa_logunk-erro.
    PERFORM f_erro.
  ENDIF.


ENDFORM.                    " ZF_PREPARA_REGISTRO_ITMOUTROS

*&---------------------------------------------------------------------*
*&      Form  f_receb_canc
*&---------------------------------------------------------------------*
FORM f_receb_canc.


  CLEAR v_chaverec.

  SELECT SINGLE chave INTO v_chaverec
  FROM zhms_tb_repdoc
  WHERE
        chave = v_chave.

  IF NOT v_chaverec IS INITIAL.
    v_critc = 'X'.
*   Tratamento de Erro
    CLEAR wa_logunk.
    CONCATENATE 'Erro: O Documento: ' v_chave ' já existe na tabela zhms_tb_repdoc ' INTO wa_logunk-erro.
    PERFORM f_erro.

* Altera o status para cancelamento
    READ TABLE it_mssdata INTO wa_mssdata WITH KEY seqnc = '35'.
    IF sy-subrc EQ 0.
      CLEAR v_cstat.
      SELECT SINGLE cstat
        FROM zhms_tb_status_c
        INTO v_cstat
        WHERE cstat = wa_mssdata-value.
      IF sy-subrc EQ 0.
        PERFORM f_edit_status.
      ENDIF.
    ENDIF.

  ENDIF.
ENDFORM.                    "f_receb_canc
*&---------------------------------------------------------------------*
*&      Form  ZF_PREPARA_REGISTRO_ITMNFSE1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM zf_prepara_registro_itmnfse1 .
  IF wa_itmdoc-dcitm NE wa_repomneum-dcitm AND
     ( NOT wa_itmdoc-dcitm IS INITIAL ) AND
    ( NOT wa_itmdoc-denom IS INITIAL ) and
    wa_mapdatac-mneum <> 'ITEMVALTOT'.
    wa_itmdoc-natdc = v_natdc.
    wa_itmdoc-chave = v_chave.
    wa_itmdoc-typed = v_typed.
    wa_itmdoc-loctp = v_loctp.
    wa_itmdoc-lote =  v_loted.
    wa_itmdoc-dcqtd = 1.

    APPEND wa_itmdoc TO it_itmdoc.
    CLEAR wa_itmdoc.
  ENDIF.
  IF NOT wa_mapdatac-rotin IS INITIAL.
    ASSIGN COMPONENT wa_mapdatac-tbfld OF STRUCTURE wa_itmdoc TO <fs_field>.
    IF sy-subrc EQ 0.
      PERFORM (wa_mapdatac-rotin) IN PROGRAM saplzhms_fg_rfc IF FOUND.
    ENDIF.
  ELSE.
    ASSIGN COMPONENT wa_mapdatac-tbfld OF STRUCTURE wa_itmdoc TO <fs_field>.
    IF sy-subrc EQ 0.
      <fs_field> = wa_repomneum-value.
    ENDIF.
  ENDIF.

  IF wa_repomneum-value IS INITIAL AND NOT wa_mapdatac-obrig IS INITIAL.
    v_critc = 'X'.
*   Tratamento de Erro
    CLEAR wa_logunk.
    CONCATENATE 'Erro: Gravação Item Documento - Mneumônico '  wa_repomneum-mneum ' têm valor Nulo Sequência: '
    wa_repomneum-seqnr INTO wa_logunk-erro.
    PERFORM f_erro.
  ENDIF.
ENDFORM.                    " ZF_PREPARA_REGISTRO_ITMNFSE1
