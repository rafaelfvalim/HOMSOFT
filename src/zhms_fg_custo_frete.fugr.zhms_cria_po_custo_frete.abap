FUNCTION zhms_cria_po_custo_frete.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  TABLES
*"      ZENTRADA STRUCTURE  ZENT_CUSTO_FRETE
*"      RETURN STRUCTURE  BAPIRETURN
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
* HomSoft - Criação do PO através do documento de custo de frete
*----------------------------------------------------------------------*
  DATA lv_erro TYPE char01.
  REFRESH: ti_zentrada, ti_j1bnfdoc, ti_j1bnflin, ti_nfeative,
           ti_vbrp, ti_status, ti_fatura,
           ti_vfkp, ti_vfkn, ti_vttp, ti_vfkk, ti_return,
           ti_return_erro, ti_bdcdata, ti_msgs.

  CLEAR:   wa_zentrada, wa_j1bnfdoc, wa_j1bnflin, wa_nfeative,
           wa_vbrp, wa_vttp_vbrp, wa_status, wa_fatura,
           wa_vfkp, wa_vfkn, wa_vttp, wa_vfkk, wa_return,
           wa_return_erro, wa_bdcdata, wa_msgs, wa_refkey.

  IF v_po IS NOT INITIAL.
    CLEAR: ti_return[] , return[].
    EXIT.
  ELSE.
    v_po = abap_true.
    CLEAR return[].
  ENDIF.

  IF v_carregado EQ abap_true.
    EXIT.
  ENDIF.

  IF ti_zentrada_valid[] IS INITIAL.
    CALL FUNCTION 'ZHMS_VALIDA_DT_CTE'
      TABLES
        zentrada_valid = ti_zentrada_valid
        return         = ti_return.
  ENDIF.

  IF ti_zentrada_valid[] IS INITIAL.
    "Não há dados para execução.
    CLEAR v_mensagem. v_mensagem = TEXT-068.
    PERFORM pf_atualiza_log  USING wa_zentrada_valid
                                   wa_lfa1-lifnr
                                   v_mensagem
                                   '30'.
  ENDIF.


  IF ti_zentrada_valid[]  IS NOT INITIAL.
* Realizar a buscar abaixo para todas as NF-es do CT-e.
    SELECT docnum nfenum
      FROM j_1bnfdoc
      INTO TABLE ti_j1bnfdoc
      FOR ALL ENTRIES IN ti_zentrada_valid
      WHERE nfenum = ti_zentrada_valid-ndoc   "Numero do Nfe
        AND pstdat = ti_zentrada_valid-nemi.  "Data de emissão da Nfe

    IF ti_j1bnfdoc[] IS INITIAL.
      "Nenhuma Nota Fiscal encontrada no sistema
      CLEAR v_mensagem. v_mensagem = TEXT-069.
      PERFORM pf_atualiza_log  USING wa_zentrada_valid
                                     wa_lfa1-lifnr
                                     v_mensagem
                                     '30'.
    ENDIF.

    LOOP AT ti_zentrada_valid INTO wa_zentrada_valid.

      CLEAR wa_j1bnfdoc.
      READ TABLE ti_j1bnfdoc INTO wa_j1bnfdoc
                             WITH KEY nfenum = wa_zentrada_valid-ndoc.

      IF NOT sy-subrc IS INITIAL.
        "Nota Fiscal Numero do Nfe não encontrada no sistema
        CONCATENATE TEXT-070 wa_zentrada-ndoc TEXT-071
                    INTO wa_return-message SEPARATED BY space.
        APPEND wa_return TO ti_return.
        CLEAR wa_return.
      ENDIF.
    ENDLOOP.

    IF NOT ti_j1bnfdoc[] IS INITIAL.

      SELECT docnum itmnum cfop refkey
        FROM j_1bnflin
        INTO TABLE ti_j1bnflin
        FOR ALL ENTRIES IN ti_j1bnfdoc
        WHERE docnum = ti_j1bnfdoc-docnum.

      IF sy-subrc EQ 0.
        SELECT docnum itmnum cfop refkey
          FROM j_1bnflin
          INTO TABLE ti_j1bnflin
           FOR ALL ENTRIES IN ti_j1bnfdoc
         WHERE docnum = ti_j1bnfdoc-docnum.
        IF ti_j1bnflin[] IS NOT INITIAL.
          IF ti_refkey[] IS NOT INITIAL.

            SORT ti_refkey BY vbeln.

            IF ti_refkey IS NOT INITIAL.
              SELECT vbeln posnr vgbel vgpos
                FROM vbrp
                INTO TABLE ti_vbrp
                FOR ALL ENTRIES IN ti_refkey
                WHERE vbeln = ti_refkey-vbeln.

              IF NOT sy-subrc IS INITIAL.
                "Nenhum item do documento de faturamento encontrado
                CLEAR v_mensagem. v_mensagem = TEXT-021.
                PERFORM pf_atualiza_log  USING wa_zentrada_valid
                                               wa_lfa1-lifnr
                                               v_mensagem
                                               '20'.

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

                SORT ti_vbrp BY vgbel. " 06/08/2019 - Code inspector
                SELECT fknum fkpos lfnkn rebel
                  FROM vfkn
                  INTO TABLE ti_vfkn
                  FOR ALL ENTRIES IN ti_vbrp
                  WHERE rebel = ti_vbrp-vgbel.          "#EC CI_NOFIELD

                IF sy-subrc IS INITIAL.
                  SORT ti_vfkn BY rebel.
                  SELECT fknum fkpos rebel stfre stabr kzwi1 ebeln postx
                  FROM vfkp
                  INTO TABLE ti_vfkp
                  FOR ALL ENTRIES IN ti_vttp
                  WHERE rebel = ti_vttp-tknum.

                  IF sy-subrc IS INITIAL.
                    SORT ti_vfkp BY fknum fkpos.
                  ELSE.
                  ENDIF.
                ENDIF.

              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
        LOOP AT ti_zentrada_valid INTO wa_zentrada_valid.
*      at new NCT. " Verificar se será necessário desconsiderar as duplicidades de CTE por nota fiscal
          READ TABLE ti_j1bnfdoc INTO wa_j1bnfdoc WITH KEY nfenum = wa_zentrada_valid-ndoc. " Nota
          IF sy-subrc EQ 0.
            READ TABLE ti_j1bnflin INTO wa_j1bnflin WITH KEY docnum = wa_j1bnfdoc-docnum. " Referência Doc origem
            IF sy-subrc EQ 0.
              READ TABLE ti_refkey INTO wa_refkey WITH KEY refkey = wa_j1bnflin-refkey. " Referência Doc origem
              IF sy-subrc EQ 0.
                READ TABLE ti_vttp_vbrp INTO wa_vttp_vbrp WITH KEY vbeln = wa_refkey-vbeln. "Fatura x Remessa
                IF sy-subrc EQ 0.
                  READ TABLE ti_vbrp INTO wa_vbrp WITH KEY vbeln = wa_vttp_vbrp-vbeln.
                  IF sy-subrc EQ 0 .
                    READ TABLE ti_vfkn INTO wa_vfkn WITH KEY rebel = wa_vbrp-vgbel.
                    IF sy-subrc EQ 0.
                      READ TABLE ti_vfkp INTO wa_vfkp
                                         WITH KEY fknum = wa_vfkn-fknum
                                                  fkpos = wa_vfkn-fkpos.
                      IF sy-subrc EQ 0.
                        "Se STABR = “C”, exibir a mensagem “Pedido de compras já gerado.”
                        "e encerrar processamento.
                        IF wa_vfkp-stabr = 'C'.
                          PERFORM pf_atualiza_status  USING wa_zentrada_valid
                              wa_vttp_vbrp-tknum
                              wa_lfa1-lifnr
                              '30'.
                          CONTINUE.
                        ENDIF.

                        "Se KZWI1 = “0”, exibir a mensagem “Custo de frete sem valor.
                        "Impossível transferir.” e encerrar processamento.
                        IF wa_vfkp-kzwi1 > '0'.
*                        IF wa_vfkp-kzwi1 = '0'.
*                          CLEAR v_mensagem. v_mensagem = TEXT-037.
*                          PERFORM pf_atualiza_log  USING wa_zentrada_valid
*                                                         wa_lfa1-lifnr
*                                                         v_mensagem
*                                                         '30'.
**                        ENDIF.
*                        ELSE.
                          PERFORM pf_cria_po USING wa_vfkp-fknum
                                                   wa_vfkp-fkpos.
                        ENDIF.
                      ENDIF.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
*          enddat
        ENDLOOP.
      ELSE.
**      "Nenhuma item da nota fiscal encontrado
        CLEAR v_mensagem. v_mensagem = TEXT-072.
        PERFORM pf_atualiza_log  USING wa_zentrada_valid
                                       wa_lfa1-lifnr
                                       v_mensagem
                                       '30'.

      ENDIF.
    ENDIF.
  ENDIF.

  SORT ti_return.
  DELETE ADJACENT DUPLICATES FROM ti_return.
  return[] = ti_return[].
  IF ti_tb_log[] IS NOT INITIAL.
    MODIFY zhms_tb_log FROM TABLE ti_tb_log.
    COMMIT WORK AND WAIT.
  ENDIF.


ENDFUNCTION.
