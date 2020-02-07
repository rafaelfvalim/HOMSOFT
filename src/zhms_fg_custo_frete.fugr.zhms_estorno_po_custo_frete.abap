FUNCTION zhms_estorno_po_custo_frete.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  TABLES
*"      ZENTRADA STRUCTURE  ZENT_CUSTO_FRETE
*"      RETURN STRUCTURE  BAPIRETURN
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
* HomSoft - Estorno da PO através do documento de custo de frete
*----------------------------------------------------------------------*

  REFRESH: ti_zentrada, ti_j1bnfdoc, ti_j1bnflin, ti_nfeative,
           ti_vbrp, ti_vttp_vbrp, ti_status, ti_fatura,
           ti_vfkp, ti_vfkn, ti_vttp, ti_vfkk, ti_return,
           ti_return_erro, ti_bdcdata, ti_msgs.

  CLEAR:   wa_zentrada, wa_j1bnfdoc, wa_j1bnflin, wa_nfeative,
           wa_vbrp, wa_vttp_vbrp, wa_status, wa_fatura,
           wa_vfkp, wa_vfkn, wa_vttp, wa_vfkk, wa_return,
           wa_return_erro, wa_bdcdata, wa_msgs.

*** 1.  Obter dados de etapa do documento de custo de frete

***" 10/08/2019 -->>
*  ti_zentrada[] = zentrada[].
  " " " """"".
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

* Realizar a buscar abaixo para todas as NF-es do CT-e.

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
      "Nota Fiscal Numero do Nfe não encontrada no sistema
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

  CHECK ti_return[] IS INITIAL.

***" 06/08/2019 -->>

  LOOP AT ti_j1bnflin INTO wa_j1bnflin.
    wa_refkey = wa_j1bnflin-refkey(10).
    APPEND  wa_refkey TO ti_refkey.
    CLEAR wa_refkey.
  ENDLOOP.
  SORT ti_refkey BY vbeln.

  IF ti_refkey IS NOT INITIAL.
    SELECT vbeln posnr vgbel vgpos
      FROM vbrp
      INTO TABLE ti_vbrp
      FOR ALL ENTRIES IN ti_refkey
      WHERE vbeln = ti_refkey-vbeln.
  ENDIF.
***" 06/08/2019 <<--

  IF NOT sy-subrc IS INITIAL.
    "Nenhum item do documento de faturamento encontrado
    wa_return-message = TEXT-021.
    APPEND wa_return TO ti_return.
    CLEAR wa_return.

    return[] = ti_return[].
  ELSE.

    SORT ti_vbrp BY vgbel.

    SELECT tknum tpnum vbeln
     FROM vttp
     INTO TABLE ti_vttp
     FOR ALL ENTRIES IN ti_vbrp
     WHERE vbeln = ti_vbrp-vgbel.

    IF sy-subrc IS INITIAL.
      SORT ti_vttp BY vbeln.
    ENDIF.

    SORT ti_vbrp BY vgbel. " " 06/08/2019 - Code inspector
    SELECT fknum fkpos lfnkn rebel
      FROM vfkn
      INTO TABLE ti_vfkn
      FOR ALL ENTRIES IN ti_vbrp
      WHERE rebel = ti_vbrp-vgbel.                                                                                                                                       "#EC CI_NOFIELD

    IF sy-subrc IS INITIAL.
      SORT ti_vfkn BY rebel.
    ENDIF.

    "Com o TKNUM encontrado, realizar a busca abaixo:
    IF NOT ti_vttp[] IS INITIAL.

      SELECT fknum fkpos rebel stfre stabr kzwi1 ebeln postx
        FROM vfkp
        INTO TABLE ti_vfkp
        FOR ALL ENTRIES IN ti_vttp
        WHERE rebel = ti_vttp-tknum.

      IF sy-subrc IS INITIAL.
        SORT ti_vfkp BY fknum fkpos.
      ELSE.
        "Nenhum Nº custos de frete encontrado
        wa_return-message = TEXT-021.
        APPEND wa_return TO ti_return.
        CLEAR wa_return.

        return[] = ti_return[].
      ENDIF.

    ENDIF.

  ENDIF.

  CHECK ti_return[] IS INITIAL.

  LOOP AT ti_vbrp INTO wa_vbrp.

    CLEAR wa_vfkn.
    READ TABLE ti_vfkn INTO wa_vfkn
                       WITH KEY rebel = wa_vbrp-vgbel
                       BINARY SEARCH.

    IF NOT sy-subrc IS INITIAL.

      "Buscar o TKNUM
      CLEAR wa_vttp.
      READ TABLE ti_vttp INTO wa_vttp
                         WITH KEY vbeln = wa_vbrp-vgbel
                         BINARY SEARCH.

      IF NOT sy-subrc IS INITIAL.
        "Nº transporte não encontrado
        wa_return-message = TEXT-026.
        APPEND wa_return TO ti_return.
        CLEAR wa_return.
        EXIT.
      ENDIF.

    ELSE. "Encontrou o FKNUM (Docto Custo Frete)

      "Buscar o TKNUM
      CLEAR wa_vttp.
      READ TABLE ti_vttp INTO wa_vttp
                         WITH KEY vbeln = wa_vbrp-vgbel
                         BINARY SEARCH.

      IF NOT sy-subrc IS INITIAL.
        "Nº transporte não encontrado
        wa_return-message = TEXT-026.
        APPEND wa_return TO ti_return.
        CLEAR wa_return.
        EXIT.
      ELSE.

*Se o FKNUM encontrado para todos os DOCNUM não for igual, exibir mensagem de erro:
*“Dados do CTe Numero do Cte estão diferentes dos dados de documento de custo de frete.
*Processamento impossível.” e encerrar processamento.
*Senão, continuar processamento.

        "Verificar se FKNUM existe na ZHMS_TB_STATUS
        REFRESH: ti_status.
        SELECT *
          FROM zhms_tb_status
          INTO TABLE ti_status
          WHERE tknum = wa_vttp-tknum.

        IF sy-subrc IS INITIAL.

          LOOP AT ti_status INTO wa_status.

            IF wa_status-fknum NE wa_vfkn-fknum.

              "Dados do CTe Numero do Cte estão diferentes dos dados de documento de custo de frete.
              "Processamento impossível.
              CONCATENATE TEXT-016 wa_vttp-tknum TEXT-017
                          INTO wa_return-message SEPARATED BY space.
              APPEND wa_return TO ti_return.
              CLEAR wa_return.
            ENDIF.

          ENDLOOP.

        ELSE.

          "Nenhum Controle de status - Frete encontrado no Homsoft
          wa_return-message = TEXT-029.
          APPEND wa_return TO ti_return.
          CLEAR wa_return.

        ENDIF.

        CHECK ti_return[] IS INITIAL.

*** 2.  Checar status do documento de custos de frete

        "Com o FKNUM e FKPOS encontrados, buscar o valor de STABR na tabela VFKP.
        CLEAR wa_vfkp.
        READ TABLE ti_vfkp INTO wa_vfkp
                           WITH KEY fknum = wa_vfkn-fknum
                                    fkpos = wa_vfkn-fkpos
                           BINARY SEARCH.

        IF NOT sy-subrc IS INITIAL.
          CLEAR wa_return.
          "Nº custos de frete + Item xxxxx xxxx não encontrado no sistema
          CONCATENATE TEXT-035 wa_vfkn-fknum '-' wa_vfkn-fkpos
                      TEXT-028 INTO wa_return-message
                      SEPARATED BY space.
          APPEND wa_return TO ti_return.
          CLEAR wa_return.
        ENDIF.

        CHECK ti_return[] IS INITIAL.

        "Se STABR <> “A”, exibir a mensagem “Pedido de compras ainda
        "Se STABR <> “C”, exibir a mensagem “Pedido de compras ainda (revisado pelo funcional)
        "não foi gerado\.” e encerrar processamento.
        IF wa_vfkp-stabr NE 'C'.
          CLEAR wa_return.
          wa_return-message = TEXT-039.
          APPEND wa_return TO ti_return.
          CLEAR wa_return.
        ENDIF.

        CHECK ti_return[] IS INITIAL.

***3.	Executar Batch-input para o estorno do pedido de compras
        PERFORM pf_estorna_po USING wa_vfkp-fknum
                                    wa_vfkp-fkpos.


      ENDIF.
    ENDIF.
  ENDLOOP.

  IF NOT ti_return[] IS INITIAL.

    DELETE ADJACENT DUPLICATES FROM ti_return.

  ELSE.
*** Mensagem sucesso
    CLEAR wa_return.
    "Estorno da PO com sucesso.
    wa_return-message = TEXT-040.
    APPEND wa_return TO ti_return.
    CLEAR wa_return.

  ENDIF.

  IF NOT ti_return_erro[] IS INITIAL.

    DELETE ADJACENT DUPLICATES FROM ti_return_erro.

    CLEAR wa_return_erro.
    LOOP AT ti_return_erro INTO wa_return_erro.

      APPEND wa_return_erro TO ti_return.
      CLEAR wa_return_erro.

    ENDLOOP.

  ENDIF.

  return[] = ti_return[].

ENDFUNCTION.
