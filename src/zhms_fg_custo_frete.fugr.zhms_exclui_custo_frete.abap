FUNCTION zhms_exclui_custo_frete.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  TABLES
*"      ZENTRADA STRUCTURE  ZENT_CUSTO_FRETE
*"      RETURN STRUCTURE  BAPIRETURN
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
* HomSoft - Excluir documento de custo de frete
*----------------------------------------------------------------------*
  REFRESH: ti_zentrada, ti_j1bnfdoc, ti_j1bnflin, ti_nfeative,
           ti_vbrp, ti_vttp_vbrp, ti_status, ti_fatura,
           ti_vfkp, ti_vfkn, ti_vttp, ti_vfkk, ti_return,
           ti_bdcdata, ti_msgs, ti_refkey. " " 06/08/2019

  CLEAR:   wa_zentrada, wa_j1bnfdoc, wa_j1bnflin, wa_nfeative,
           wa_vbrp, wa_vttp_vbrp, wa_status, wa_fatura,
           wa_vfkp, wa_vfkn, wa_vttp, wa_vfkk, wa_return,
           wa_bdcdata, wa_msgs, wa_refkey. " " 06/08/2019


***" 10/08/2019 -->>
*    ti_zentrada[] = zentrada[].
  ASSIGN ('(SAPLZHMS_FG_RULER)IT_DOCMN') TO <fs_tab_docmn>.
  IF <fs_tab_docmn> IS ASSIGNED.
    ti_docmn = <fs_tab_docmn>.
    READ TABLE ti_docmn ASSIGNING <fs_wa_docmn> WITH KEY mneum = 'NUMEROFAT'.
    IF sy-subrc EQ 0.
      wa_zentrada-fatura = <fs_wa_docmn>-value.
      READ TABLE ti_docmn ASSIGNING <fs_wa_docmn> WITH KEY mneum = 'CNPJEMI'.
      IF sy-subrc EQ 0.
        wa_zentrada-cnpj = <fs_wa_docmn>-value.
        APPEND wa_zentrada TO ti_zentrada.
      ENDIF.
      CLEAR wa_zentrada.
    ENDIF.
  ENDIF.
***" 10/08/2019 <<--

  IF ti_zentrada[] IS INITIAL.
    "Não há dados para execução.
    wa_return-message = TEXT-005.
    APPEND wa_return TO ti_return.
    CLEAR wa_return.
    return[] = ti_return[].
  ENDIF.

  CHECK ti_return[] IS INITIAL.

  LOOP AT ti_zentrada INTO wa_zentrada.

    IF wa_zentrada-ndoc IS INITIAL OR wa_zentrada-nemi IS INITIAL.
      "Há entrada sem Numero da Nfe ou data de emissão da Nfe
      wa_return-message = TEXT-010.
      APPEND wa_return TO ti_return.
      CLEAR wa_return.
    ENDIF.

    IF wa_zentrada-nct IS INITIAL.
      "Há entrada sem Numero do Cte
      wa_return-message = TEXT-019.
      APPEND wa_return TO ti_return.
      CLEAR wa_return.
    ENDIF.

  ENDLOOP.

  DELETE ADJACENT DUPLICATES FROM ti_return.

  IF NOT ti_return[] IS INITIAL.
    return[] = ti_return[].
  ENDIF.

  CHECK ti_return[]   IS INITIAL AND
        ti_zentrada[] IS NOT INITIAL.

  "Realizar a buscar abaixo para todas as NF-es do CT-e
  SELECT docnum nfenum                "docnum = Numero do CTe
    FROM j_1bnfdoc
    INTO TABLE ti_j1bnfdoc
    FOR ALL ENTRIES IN ti_zentrada
    WHERE nfenum = ti_zentrada-ndoc   "Numero do Nfe
      AND pstdat = ti_zentrada-nemi.  "Data de emissão da Nfe

  IF ti_j1bnfdoc[] IS INITIAL.
    "Nenhuma Nota Fiscal encontrada no sistema
    wa_return-message = TEXT-001.
    APPEND wa_return TO ti_return.
    CLEAR wa_return.

    return[] = ti_return[].
  ENDIF.

  CHECK ti_return[] IS INITIAL.

  SORT ti_j1bnfdoc  BY nfenum.
  SORT ti_zentrada  BY ndoc.

  "Se algum DOCNUM não for encontrado, exibir mensagem de erro:
  "“Nota Fiscal Numero do Nfe não encontrada no sistema” e encerrar processamento.
  LOOP AT ti_zentrada INTO wa_zentrada.

    CLEAR wa_j1bnfdoc.
    READ TABLE ti_j1bnfdoc INTO wa_j1bnfdoc
                           WITH KEY nfenum = wa_zentrada-ndoc
                           BINARY SEARCH.
    IF NOT sy-subrc IS INITIAL.

      CONCATENATE TEXT-011 wa_zentrada-ndoc TEXT-012
                  INTO wa_return-message SEPARATED BY space.
      APPEND wa_return TO ti_return.
      CLEAR wa_return.

    ENDIF.

  ENDLOOP.

  IF NOT ti_return[] IS INITIAL.
    return[] = ti_return[].
  ENDIF.

  CHECK ti_return[] IS INITIAL.

  IF NOT ti_j1bnfdoc[] IS INITIAL.

    SELECT docnum itmnum cfop refkey
      FROM j_1bnflin
      INTO TABLE ti_j1bnflin
      FOR ALL ENTRIES IN ti_j1bnfdoc
      WHERE docnum = ti_j1bnfdoc-docnum.

    IF NOT sy-subrc IS INITIAL.
      "Nenhuma item da nota fiscal encontrado
      wa_return-message = TEXT-004.
      APPEND wa_return TO ti_return.
      CLEAR wa_return.

      return[] = ti_return[].
    ENDIF.

  ENDIF.

  CHECK ti_return[]   IS INITIAL AND
        ti_j1bnflin[] IS NOT INITIAL.

***" 06/08/2019 -->>
  LOOP AT ti_j1bnflin INTO wa_j1bnflin.
    wa_refkey = wa_j1bnflin-refkey(10).
    APPEND  wa_refkey TO ti_refkey.
    CLEAR wa_refkey.
  ENDLOOP.
  SORT ti_refkey BY vbeln.

  SELECT a~tknum a~tpnum b~vbeln
    FROM vttp AS a
    INNER JOIN vbrp AS b
    ON a~vbeln = b~vgbel
    INTO TABLE ti_vttp_vbrp
    FOR ALL ENTRIES IN ti_refkey
    WHERE b~vbeln = ti_refkey-vbeln.

  SORT ti_vttp_vbrp.
  DELETE ADJACENT DUPLICATES FROM ti_vttp_vbrp COMPARING ALL FIELDS.
***" 06/08/2019 <<--

  IF ti_vttp_vbrp[] IS INITIAL.
    "Nenhum Documento de transporte encontrado para a(s) NF(s)
    wa_return-message = TEXT-006.
    APPEND wa_return TO ti_return.
    CLEAR wa_return.

    return[] = ti_return[].
  ENDIF.

  CHECK ti_return[] IS INITIAL.

  SORT ti_vttp_vbrp BY vbeln.  "VBELN é da VBRP

  "Se algum TKNUM não for encontrado, exibir mensagem de
  "erro: “Documento de transporte não gerado para a NF Numero do Nfe”
  "e encerrar processamento.
  LOOP AT ti_j1bnflin INTO wa_j1bnflin.

    CLEAR v_tabix.
    v_tabix = sy-tabix.

    CLEAR wa_vttp_vbrp.
    "J_1BNFLIN-REFKEY = VBRP-VBELN
    READ TABLE ti_vttp_vbrp INTO wa_vttp_vbrp
                            WITH KEY vbeln = wa_j1bnflin-refkey(10)
                            BINARY SEARCH.
    IF NOT sy-subrc IS INITIAL.
      "Documento de transporte não gerado para a NF xxxx
      CONCATENATE TEXT-014 wa_j1bnflin-docnum INTO wa_return-message
                  SEPARATED BY space.
      APPEND wa_return TO ti_return.
      CLEAR wa_return.
    ENDIF.

  ENDLOOP.

  IF NOT ti_return[] IS INITIAL.
    return[] = ti_return[].
  ENDIF.

  CHECK ti_return[] IS INITIAL.

*** Verifica se documento de custo de frete existe

  "Com o TKNUM encontrado, realizar a busca abaixo:
  IF NOT ti_vttp_vbrp[] IS INITIAL.
    SORT ti_vttp_vbrp BY tknum. " " 06/08/2019 - Code inspector
    SELECT fknum fkpos rebel stfre stabr kzwi1 ebeln postx
      FROM vfkp
      INTO TABLE ti_vfkp
      FOR ALL ENTRIES IN ti_vttp_vbrp
      WHERE rebel = ti_vttp_vbrp-tknum.

    IF sy-subrc IS INITIAL.

*2.	Checar status do documento de custos de frete
      SORT ti_vfkp BY fknum. " " 06/08/2019
      SELECT fknum stabr
        FROM vfkk
        INTO TABLE ti_vfkk
        FOR ALL ENTRIES IN ti_vfkp
        WHERE fknum = ti_vfkp-fknum.

      IF NOT sy-subrc IS INITIAL.
        "Nenhum Custos de frete encontrado
        wa_return-message = TEXT-022.
        APPEND wa_return TO ti_return.
        CLEAR wa_return.

        return[] = ti_return[].
      ENDIF.

    ELSE.
      "Nenhum Custos de frete encontrado
      wa_return-message = TEXT-022.
      APPEND wa_return TO ti_return.
      CLEAR wa_return.

      return[] = ti_return[].
    ENDIF.

  ENDIF.

  CHECK ti_return[] IS INITIAL.

  SORT ti_vfkp      BY rebel.
  SORT ti_vfkk      BY fknum.
  SORT ti_vttp_vbrp BY tknum.

  LOOP AT ti_vttp_vbrp INTO wa_vttp_vbrp.

    CLEAR wa_vfkp.
    READ TABLE ti_vfkp INTO wa_vfkp
                       WITH KEY rebel = wa_vttp_vbrp-tknum
                       BINARY SEARCH.

    IF sy-subrc IS INITIAL. "Nº custos de frete existe

      CLEAR wa_vfkk.
      READ TABLE ti_vfkk INTO wa_vfkk
                         WITH KEY fknum = wa_vfkp-fknum
                         BINARY SEARCH.

      IF sy-subrc IS INITIAL.

*Se STABR <> “A”, exibir a mensagem “Documento de custos de transportes FKNUM já possui item transferido.” e encerrar processamento.
        IF wa_vfkk-stabr NE 'A'.

          "Documento de custos de transportes FKNUM já possui item transferido.
          CONCATENATE TEXT-023 wa_vfkk-fknum TEXT-024
                      INTO wa_return-message SEPARATED BY space.
          APPEND wa_return TO ti_return.
          CLEAR wa_return.

        ELSE.

          "Executa Exclusão do Custo de Frete,
          "Caso positivo, atualiza tabela ZHMS_TB_STATUS
          PERFORM pf_delete USING wa_vfkp-fknum.

        ENDIF.

      ELSE.

        "Documento de custos de transportes FKNUM não encontrado no sistema
        CONCATENATE TEXT-023 wa_vfkp-fknum TEXT-028
                    INTO wa_return-message SEPARATED BY space.
        APPEND wa_return TO ti_return.
        CLEAR wa_return.

      ENDIF.

    ELSE.

      "Documento de custo de frete não existente para transporte TKNUM
      CONCATENATE TEXT-027 wa_vttp_vbrp-tknum
                  INTO wa_return-message SEPARATED BY space.
      APPEND wa_return TO ti_return.
      CLEAR wa_return.

    ENDIF.

  ENDLOOP.

  IF NOT ti_return[] IS INITIAL.
    return[] = ti_return[].
  ENDIF.


ENDFUNCTION.
