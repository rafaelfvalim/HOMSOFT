FUNCTION zhms_cria_custo_frete.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  TABLES
*"      ZENTRADA STRUCTURE  ZENT_CUSTO_FRETE
*"      RETURN STRUCTURE  BAPIRETURN
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
* HomSoft - Criação de documento do custo de frete
*----------------------------------------------------------------------*

  DATA lv_lifnr        TYPE lfa1-lifnr.
  DATA lwa_tb_log      TYPE zhms_tb_log.
  DATA lti_custo_frete TYPE STANDARD TABLE OF zatuvr_custo_frete.
  DATA lwa_custo_frete TYPE zatuvr_custo_frete.
  DATA lv_erro         TYPE char01.

  REFRESH: ti_zentrada, ti_nfeative,
           ti_vbrp, ti_status, ti_fatura,
           ti_vfkp, ti_vfkn, ti_vttp, ti_vfkk,
           ti_bdcdata, ti_msgs,
           ti_return, return.

  CLEAR:   wa_zentrada, wa_j1bnfdoc, wa_j1bnflin, wa_nfeative,
           wa_vbrp, wa_vttp_vbrp, wa_status, wa_fatura,
           wa_vfkp, wa_vfkn, wa_vttp, wa_vfkk, wa_return,
           wa_bdcdata, wa_msgs, wa_refkey, wa_vbrp.

  IF v_cf IS NOT INITIAL.
    CLEAR: ti_return[] , return[].
    EXIT.
  ELSE.
    v_cf = abap_true.
    CLEAR return[].
  ENDIF.
  IF v_carregado EQ abap_true.
    EXIT.
  ENDIF.

  IF ti_zentrada_valid[] IS INITIAL OR
     ti_vttp_vbrp[]      IS INITIAL.

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
                                   '20'.
  ENDIF.


  IF ti_j1bnfdoc[] IS NOT INITIAL.
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

          IF sy-subrc IS NOT INITIAL.
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
              WHERE rebel = ti_vbrp-vgbel.              "#EC CI_NOFIELD

            IF sy-subrc IS INITIAL.
              SORT ti_vfkn BY rebel.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF ti_zentrada_valid[] IS NOT INITIAL AND ti_vttp_vbrp[] IS NOT INITIAL.
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
                  CLEAR wa_vfkp.
                  SELECT SINGLE
                    fknum fkpos rebel stfre stabr kzwi1 ebeln
                    FROM vfkp
                    INTO wa_vfkp
                   WHERE rebel = wa_vttp_vbrp-tknum.
                  IF sy-subrc NE 0. " Documento de transporte ainda não encontrado

                    "Criar Custo de frete
                    CLEAR v_fknum. " Limpa Doc. Custo de Frete
                    " Cria Doc. Custo de Frete
                    PERFORM pf_executa_vi01 USING    wa_vttp_vbrp-tknum
                                                     wa_zentrada_valid-nct
                                                     lv_erro.


                    "Após a execução da VI01, efetuar a busca novamente
                    CLEAR v_flag.
                    PERFORM pf_verifica_ok USING    v_fknum
                                           CHANGING v_flag.  "CHAR1

                    IF v_flag EQ 'S'.
                      "Modificar Custo de frete
                      PERFORM pf_executa_vi02 USING wa_zentrada_valid-nct
                                                    v_fknum.
                    ELSE.
                      "Erro ao Salvar Doc. Custo Frete
                      CLEAR v_mensagem. v_mensagem = TEXT-067.
                      PERFORM pf_atualiza_log  USING wa_zentrada_valid
                                                     wa_lfa1-lifnr
                                                     v_mensagem
                                                     '20'.
                    ENDIF.
                  ELSE. "Encontrou - Atualiza
                    "Inclui item custo de frete
*                    IF v_fknum IS INITIAL.
                      v_fknum = wa_vfkp-fknum.
*                    ENDIF.
                    IF v_fknum IS NOT INITIAL.
                      "Modificar Custo de frete
                      PERFORM pf_executa_vi02 USING wa_zentrada_valid-nct
                                                    v_fknum .
                    ENDIF.
                  ENDIF.
                ENDIF.
              ELSE.
                "Nº transporte não encontrado
                CLEAR v_mensagem. v_mensagem = TEXT-026.
                PERFORM pf_atualiza_log  USING wa_zentrada_valid
                                               wa_lfa1-lifnr
                                               v_mensagem
                                               '20'.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
*        enddat.
    ENDLOOP.
  ENDIF.

  SORT ti_return.
  DELETE ADJACENT DUPLICATES FROM ti_return.
  return[] = ti_return[].
  IF ti_tb_log[] IS NOT INITIAL.
    MODIFY zhms_tb_log FROM TABLE ti_tb_log.
    COMMIT WORK AND WAIT.
  ENDIF.

ENDFUNCTION.
