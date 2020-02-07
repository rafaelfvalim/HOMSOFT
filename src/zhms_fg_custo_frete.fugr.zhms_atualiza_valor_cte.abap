FUNCTION zhms_atualiza_valor_cte.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  TABLES
*"      ZENTRADA2 STRUCTURE  ZATUVR_CUSTO_FRETE
*"      RETURN STRUCTURE  BAPIRETURN
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
* HomSoft - Adiciona o valor ao item do documento de custo de frete
*----------------------------------------------------------------------*
****
****  DATA lv_erro TYPE char01. " " 04/08/2019
****
****  REFRESH: ti_zentrada2, ti_j1bnfdoc, ti_j1bnflin, ti_nfeative,
****           ti_vbrp, ti_vttp_vbrp, ti_status, ti_fatura,
****           ti_vfkp, ti_vfkn, ti_vttp, ti_vfkk, ti_return,
****           ti_bdcdata, ti_msgs, ti_refkey. " " 06/08/2019
****
****  CLEAR:   wa_zentrada2, wa_j1bnfdoc, wa_j1bnflin, wa_nfeative,
****           wa_vbrp, wa_vttp_vbrp, wa_status, wa_fatura,
****           wa_vfkp, wa_vfkn, wa_vttp, wa_vfkk, wa_return,
****           wa_bdcdata, wa_msgs, wa_refkey. " " 06/08/2019
****
****
****  ti_zentrada2[] = zentrada2[].
****
****  IF ti_zentrada2[] IS INITIAL.
****    wa_return-message = TEXT-005. "Não há dados para execução.
****    APPEND wa_return TO ti_return.
****    CLEAR wa_return.
****    return[] = ti_return[].
****  ENDIF.
****
****  CHECK ti_return[] IS INITIAL.
****
****  LOOP AT ti_zentrada2 INTO wa_zentrada2.
****
****    IF wa_zentrada2-ndoc IS INITIAL. " AND wa_zentrada2-nemi IS INITIAL.
****      "Há entrada sem Numero da Nfe ou data de emissão da Nfe
****      wa_return-message = TEXT-010.
****      APPEND wa_return TO ti_return.
****      CLEAR wa_return.
****    ENDIF.
****
****    IF wa_zentrada2-nct IS INITIAL.
****      wa_return-message = TEXT-019. "Há entrada sem Numero do Cte
****      APPEND wa_return TO ti_return.
****      CLEAR wa_return.
****    ENDIF.
****
****    IF wa_zentrada2-vtprest IS INITIAL.
****      wa_return-message = TEXT-025. "Há entrada sem Valor do Cte
****      APPEND wa_return TO ti_return.
****      CLEAR wa_return.
****    ENDIF.
****
****  ENDLOOP.
****
****  DELETE ADJACENT DUPLICATES FROM ti_return.
****
****  IF NOT ti_return[] IS INITIAL.
****    return[] = ti_return[].
****  ENDIF.
****
****  CHECK ti_return[]   IS INITIAL AND
****        ti_zentrada2[] IS NOT INITIAL.
****
****  "Realizar a buscar abaixo para todas as NF-es do CT-e.
****  SELECT docnum nfenum                "Numero do CTe
****    FROM j_1bnfdoc
****    INTO TABLE ti_j1bnfdoc
****    FOR ALL ENTRIES IN ti_zentrada2
****    WHERE nfenum = ti_zentrada2-ndoc   "Numero do Nfe
****      AND pstdat = ti_zentrada2-nemi.  "Data de emissão da Nfe
****
****  IF ti_j1bnfdoc[] IS INITIAL.
****    "Nenhuma Nota Fiscal encontrada no sistema
****    wa_return-message = TEXT-001.
****    APPEND wa_return TO ti_return.
****    CLEAR wa_return.
****
****    return[] = ti_return[].
****  ENDIF.
****
****  CHECK ti_return[] IS INITIAL.
****
****  SORT ti_j1bnfdoc  BY nfenum.
****  SORT ti_zentrada2 BY ndoc.
****
****  "Se algum DOCNUM não for encontrado, exibir mensagem de erro:
****  "“Nota Fiscal Numero do Nfe não encontrada no sistema” e encerrar processamento.
****  LOOP AT ti_zentrada2 INTO wa_zentrada2.
****
****    CLEAR wa_j1bnfdoc.
****    READ TABLE ti_j1bnfdoc INTO wa_j1bnfdoc
****                           WITH KEY nfenum = wa_zentrada2-ndoc
****                           BINARY SEARCH.
****    IF NOT sy-subrc IS INITIAL.
****
****      CONCATENATE TEXT-011 wa_zentrada2-ndoc TEXT-012
****                  INTO wa_return-message SEPARATED BY space.
****      APPEND wa_return TO ti_return.
****      CLEAR wa_return.
****
****    ENDIF.
****
****  ENDLOOP.
****
****  IF NOT ti_return[] IS INITIAL.
****    return[] = ti_return[].
****  ENDIF.
****
****  CHECK ti_return[] IS INITIAL.
****
****  IF NOT ti_j1bnfdoc[] IS INITIAL.
****
****    SELECT docnum itmnum cfop refkey
****      FROM j_1bnflin
****      INTO TABLE ti_j1bnflin
****      FOR ALL ENTRIES IN ti_j1bnfdoc
****      WHERE docnum = ti_j1bnfdoc-docnum.
****
****    IF ti_j1bnflin[] IS INITIAL.
****      "Nenhum item da nota fiscal encontrado
****      wa_return-message = TEXT-004.
****      APPEND wa_return TO ti_return.
****      CLEAR wa_return.
****
****      return[] = ti_return[].
****    ENDIF.
****
****    CHECK ti_return[] IS INITIAL.
****
*******" 06/08/2019 -->>
****
****    LOOP AT ti_j1bnflin INTO wa_j1bnflin.
****      wa_refkey = wa_j1bnflin-refkey(10).
****      APPEND  wa_refkey TO ti_refkey.
****      CLEAR wa_refkey.
****    ENDLOOP.
****    SORT ti_refkey BY vbeln.
****
****    IF ti_refkey IS NOT INITIAL.
****      SELECT vbeln posnr vgbel vgpos
****        FROM vbrp
****        INTO TABLE ti_vbrp
****        FOR ALL ENTRIES IN ti_refkey
****        WHERE vbeln = ti_refkey-vbeln.
****    ENDIF.
*******" 06/08/2019 <<--
****
****    IF NOT sy-subrc IS INITIAL.
****      "Nenhum item do documento de faturamento encontrado
****      wa_return-message = TEXT-021.
****      APPEND wa_return TO ti_return.
****      CLEAR wa_return.
****
****      return[] = ti_return[].
****    ELSE.
****
****      SORT ti_vbrp BY vgbel.
****
****      SELECT tknum tpnum vbeln
****       FROM vttp
****       INTO TABLE ti_vttp
****       FOR ALL ENTRIES IN ti_vbrp
****       WHERE vbeln = ti_vbrp-vgbel.
****
****      IF sy-subrc IS INITIAL.
****        SORT ti_vttp BY vbeln.
****      ENDIF.
****
****      SORT ti_vbrp BY vgbel. " " 06/08/2019 - Code inspector
****      SELECT fknum fkpos lfnkn rebel
****        FROM vfkn
****        INTO TABLE ti_vfkn
****        FOR ALL ENTRIES IN ti_vbrp
****        WHERE rebel = ti_vbrp-vgbel.                                                                                                                         "#EC CI_NOFIELD
****
****      IF sy-subrc IS INITIAL.
****        SORT ti_vfkn BY rebel.
****      ENDIF.
****
****    ENDIF.
****
****    CHECK ti_return[] IS INITIAL.
****
****    LOOP AT ti_vbrp INTO wa_vbrp.
****
****      CLEAR wa_j1bnflin.
****      READ TABLE ti_j1bnflin INTO wa_j1bnflin
****                             WITH KEY refkey(10) = wa_vbrp-vbeln.
****      IF sy-subrc IS INITIAL.
****
********* BUSCAR NA J_1BNFE_ACTIVE e MONTAR A CHAVE DE ACESSO.
********* E COM ESTA CHAVE, BUSCAR NA DOCMN COM O MNEUMONICO DO XML REFERENTE AO VALOR
****        REFRESH: ti_nfeative.
****        SELECT docnum regio nfyear nfmonth stcd1
****               model serie nfnum9 docnum9 cdv
****          FROM j_1bnfe_active
****          INTO TABLE ti_nfeative
****          WHERE docnum = wa_j1bnflin-docnum.
****
****        IF sy-subrc IS INITIAL.
****
****          CLEAR: wa_nfeative, v_ch_acesso.
****          READ TABLE ti_nfeative INTO wa_nfeative INDEX 1.
****
****          CONCATENATE wa_nfeative-regio
****                      wa_nfeative-nfyear
****                      wa_nfeative-nfmonth
****                      wa_nfeative-stcd1
****                      wa_nfeative-model
****                      wa_nfeative-serie
****                      wa_nfeative-nfnum9
****                      wa_nfeative-docnum9
****                      wa_nfeative-cdv INTO v_ch_acesso.
****
****        ENDIF.
****
****
****      ENDIF.
****
****      CLEAR wa_vfkn.
****      READ TABLE ti_vfkn INTO wa_vfkn
****                         WITH KEY rebel = wa_vbrp-vgbel
****                         BINARY SEARCH.
****
****      "Se algum FKNUM não for encontrado, executar a VI01
****      IF NOT sy-subrc IS INITIAL.
****
****        "Buscar o TKNUM
****        CLEAR wa_vttp.
****        READ TABLE ti_vttp INTO wa_vttp
****                           WITH KEY vbeln = wa_vbrp-vgbel
****                           BINARY SEARCH.
****        IF NOT sy-subrc IS INITIAL.
****          "Nº transporte não encontrado
****          wa_return-message = TEXT-026.
****          APPEND wa_return TO ti_return.
****          CLEAR wa_return.
****          EXIT.
****        ELSE.
****
****          "Criar documento de custo de frete
****          PERFORM pf_executa_vi01 USING    wa_vttp-tknum
****                                  CHANGING v_nct
****                                           lv_erro. " " 04/08/2019
****
****          "Após a execução da VI01, efetuar a busca novamente
****          PERFORM pf_verifica_ok USING    v_fknum
****                                 CHANGING v_flag.  "CHAR1
****
****          "Batch-input para adicionar o valor ao item do
****          "documento de custo de frete.
*****          PERFORM pf_executa_vi02 USING v_nct.
****
****        ENDIF.
****
****      ELSE. "Encontrou o FKNUM (Docto Custo Frete)
****
****        "Buscar o TKNUM
****        CLEAR wa_vttp.
****        READ TABLE ti_vttp INTO wa_vttp
****                           WITH KEY vbeln = wa_vbrp-vgbel
****                           BINARY SEARCH.
****
****        IF NOT sy-subrc IS INITIAL.
****          "Nº transporte não encontrado
****          wa_return-message = TEXT-026.
****          APPEND wa_return TO ti_return.
****          CLEAR wa_return.
****          EXIT.
****        ELSE.
****
*****Se o FKNUM encontrado para todos os DOCNUM não for igual, exibir mensagem de erro:
*****“Dados do CTe Numero do Cte estão diferentes dos dados de documento de custo de frete.
*****Processamento impossível.” e encerrar processamento.
*****Senão, continuar processamento.
****
****          "Verificar se FKNUM existe na ZHMS_TB_STATUS
****          REFRESH: ti_status.
****          SELECT *
****            FROM zhms_tb_status
****            INTO TABLE ti_status
****            WHERE tknum = wa_vttp-tknum.
****
****          IF sy-subrc IS INITIAL.
****
****            LOOP AT ti_status INTO wa_status.
****
****              IF wa_status-fknum NE wa_vfkn-fknum.
****
****                CONCATENATE TEXT-016 wa_vttp-tknum TEXT-017
****                            INTO wa_return-message SEPARATED BY space.
****                APPEND wa_return TO ti_return.
****                CLEAR wa_return.
****              ENDIF.
****
****            ENDLOOP.
****
****          ELSE.
****
****            "Nenhum Controle de status - Frete encontrado no Homsoft
****            wa_return-message = TEXT-029.
****            APPEND wa_return TO ti_return.
****            CLEAR wa_return.
****
****          ENDIF.
****
****          CHECK ti_return[] IS INITIAL.
****
****          CLEAR wa_status.
****          READ TABLE ti_status INTO wa_status INDEX 1.
****
****          "Batch-input para adicionar o valor ao item do
****          "documento de custo de frete.
****          PERFORM pf_executa_vi02 USING wa_status-zctet.
****
****        ENDIF.
****
****      ENDIF.
****
****    ENDLOOP.
****
****    IF NOT ti_return[] IS INITIAL.
****      DELETE ADJACENT DUPLICATES FROM ti_return.
****      return[] = ti_return[].
****    ELSE.
******* Mensagem sucesso
****      CLEAR wa_return.
****      "Valor do documento de custo de frete: xxxxx  atualizado com sucesso
****      CONCATENATE TEXT-032 wa_vfkn-fknum TEXT-033 INTO wa_return-message
****                  SEPARATED BY space.
****      APPEND wa_return TO ti_return.
****      CLEAR wa_return.
****    ENDIF.
****
****  ENDIF.

ENDFUNCTION.
