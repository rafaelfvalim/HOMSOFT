FUNCTION zhms_escritura_cte.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  TABLES
*"      ZENTRADA_J1B1N STRUCTURE  ZENT_ESCRITURA_CTE
*"      RETURN STRUCTURE  BAPIRETURN
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
* HomSoft - Criação da MIRO CTe
*----------------------------------------------------------------------*

  REFRESH: ti_zentrada_j1b1n, ti_j1bnfdoc, ti_j1bnflin, ti_nfeative,
           ti_vbrp, ti_status, ti_fatura,
           ti_vfkp, ti_vfkn, ti_vttp, ti_vfkk, ti_return,
           ti_return_erro, ti_bdcdata, ti_msgs.

  CLEAR:   wa_zentrada_j1b1n, wa_j1bnfdoc, wa_j1bnflin, wa_nfeative,
           wa_vbrp, wa_vttp_vbrp, wa_status, wa_fatura,
           wa_vfkp, wa_vfkn, wa_vttp, wa_vfkk, wa_return,
           wa_return_erro, wa_bdcdata, wa_msgs, wa_refkey.

  IF v_nf IS NOT INITIAL.
    CLEAR: ti_return[] , return[].
    EXIT.
  ELSE.
    v_nf = abap_true.
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
                                   '50'.
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
                                     '50'.
    ENDIF.

    LOOP AT ti_zentrada_valid INTO wa_zentrada_valid.

      CLEAR wa_j1bnfdoc.
      READ TABLE ti_j1bnfdoc INTO wa_j1bnfdoc
                             WITH KEY nfenum = wa_zentrada_valid-ndoc.
      IF NOT sy-subrc IS INITIAL.
        "Nota Fiscal Numero do Nfe não encontrada no sistema
        CLEAR v_mensagem.
        CONCATENATE TEXT-070 wa_zentrada-ndoc TEXT-071
                    INTO v_mensagem SEPARATED BY space.
        PERFORM pf_atualiza_log  USING wa_zentrada_valid
                                       wa_lfa1-lifnr
                                       v_mensagem
                                       '50'.
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
                                               '50'.

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
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
**      "Nenhuma item da nota fiscal encontrado
        CLEAR v_mensagem. v_mensagem = TEXT-072.
        PERFORM pf_atualiza_log  USING wa_zentrada_valid
                                       wa_lfa1-lifnr
                                       v_mensagem
                                       '50'.

      ENDIF.
    ENDIF.
  ENDIF.

" Executa validações
  LOOP AT ti_zentrada_valid INTO wa_zentrada_valid.

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
                  IF wa_vfkp-stabr NE 'C'.
                    CLEAR wa_return.CLEAR v_mensagem.
                    CONCATENATE TEXT-039 TEXT-048 wa_vfkn-fknum
                                INTO v_mensagem SEPARATED BY space.
                    PERFORM pf_atualiza_log  USING wa_zentrada_valid
                                                   wa_lfa1-lifnr
                                                   v_mensagem
                                                   '50'.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF v_inv_doc_no IS NOT INITIAL.
    DATA lv_erro    TYPE      char02.
    PERFORM pf_estrutura_bapi USING v_inv_doc_no
                            CHANGING lv_erro
                                     wa_lfa1-lifnr.
    IF lv_erro IS INITIAL.
      READ TABLE ti_return TRANSPORTING NO FIELDS WITH KEY type = 'E'.
      IF sy-subrc EQ 0.
        CLEAR v_mensagem. v_mensagem = TEXT-063.
        PERFORM pf_atualiza_log_2    USING wa_zentrada_valid
                                               wa_lfa1-lifnr
                                               v_mensagem
                                               '50'
                                               'I'.
      ENDIF.
    ENDIF.
  ELSE.
    CLEAR v_mensagem. v_mensagem = TEXT-077.
    PERFORM pf_atualiza_log  USING wa_zentrada_valid
                                   wa_lfa1-lifnr
                                   v_mensagem
                                   '50'.
  ENDIF.

  "Atualiza Status
  READ TABLE ti_return TRANSPORTING NO FIELDS WITH KEY type = 'E'.
  IF sy-subrc NE 0.
    DATA lwa_docst TYPE zhms_tb_docst.
    DATA lwa_hrvalid TYPE zhms_tb_hrvalid.
    SELECT  SINGLE
            mandt
            natdc
            typed
            loctp
            chave
            sthms
            stent
            strec
            lote
            dtalt
            hralt
      FROM zhms_tb_docst
      INTO lwa_docst
     WHERE natdc = '02'
       AND typed = 'FAT'
       AND chave = v_chave.
    IF sy-subrc EQ 0.
      lwa_hrvalid-natdc = '02'.
      lwa_hrvalid-typed = 'FAT'.
      lwa_hrvalid-chave = v_chave.
      lwa_hrvalid-seqnr = '00001'.
      lwa_hrvalid-dtreg = sy-datum.
      lwa_hrvalid-ativo = abap_true.
      MODIFY zhms_tb_hrvalid FROM lwa_hrvalid.
      COMMIT WORK AND WAIT.

      lwa_docst-sthms = '1'.
      MODIFY zhms_tb_docst FROM lwa_docst.
      COMMIT WORK AND WAIT.
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
