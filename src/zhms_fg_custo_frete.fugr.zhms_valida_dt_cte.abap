FUNCTION zhms_valida_dt_cte.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  TABLES
*"      ZENTRADA_VALID STRUCTURE  ZENT_VALIDA_DT
*"      RETURN STRUCTURE  BAPIRETURN
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
* HomSoft - Validação do documento de transporte
*----------------------------------------------------------------------*

  CLEAR v_valor    .
  CLEAR v_idtitulo .
  CLEAR v_fatura   .
  CLEAR v_chave    .
  CLEAR v_demi     .
  CLEAR v_mensagem .

  REFRESH: ti_zentrada_valid, ti_j1bnfdoc, ti_fatura_val, ti_lfa1,
           ti_tb_log, ti_return, ti_docmn, ti_fatura_cte,
           ti_docmn_nfe, ti_j1bnflin_dt, ti_refkey, ti_vttp_vbrp,
           ti_tb_status.

  CLEAR:   wa_zentrada_valid, wa_j1bnfdoc, wa_fatura_val, wa_lfa1,
           wa_tb_log, wa_return, wa_docmn, wa_fatura_cte, wa_j1bnflin_dt,
           wa_refkey, wa_vttp_vbrp, wa_tb_status.

  IF v_dt IS NOT INITIAL.
    CLEAR: ti_return[] , return[].
    EXIT.
  ELSE.
    v_dt = abap_true.
    CLEAR return[].
  ENDIF.

*** Resgata dados da Fatura para validação das informações
  IF zentrada_valid[] IS INITIAL.
    CLEAR wa_zentrada_valid.
    ASSIGN ('(SAPLZHMS_FG_RULER)IT_DOCMN') TO <fs_tab_docmn>.
    IF <fs_tab_docmn> IS ASSIGNED.
      ti_docmn = <fs_tab_docmn>.
      READ TABLE ti_docmn ASSIGNING <fs_wa_docmn> WITH KEY mneum = 'NUMEROFAT'.
      IF sy-subrc EQ 0.

        wa_zentrada_valid-numerodocumento = <fs_wa_docmn>-value.
        READ TABLE ti_docmn ASSIGNING <fs_wa_docmn> WITH KEY mneum = 'IDTITULO'.
        IF sy-subrc EQ 0.

          wa_zentrada_valid-idtitulo = <fs_wa_docmn>-value.
          READ TABLE ti_docmn ASSIGNING <fs_wa_docmn> WITH KEY mneum = 'CNPJEMI'.

          IF sy-subrc EQ 0.
            wa_zentrada_valid-cpfcnpj = <fs_wa_docmn>-value.
            APPEND wa_zentrada_valid TO zentrada_valid.


            v_idtitulo  = wa_zentrada_valid-idtitulo.
            v_fatura    = wa_zentrada_valid-numerodocumento.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
              EXPORTING
                input  = v_idtitulo
              IMPORTING
                output = v_idtitulo.

            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
              EXPORTING
                input  = v_fatura
              IMPORTING
                output = v_fatura.
            CONCATENATE v_idtitulo v_fatura INTO v_chave.
            CLEAR wa_zentrada_valid.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  ti_zentrada_valid[] = zentrada_valid[].
  CLEAR zentrada_valid.


**** Valida de há entrada de fatura.
  IF ti_zentrada_valid[] IS INITIAL.
    " Não há dados para execução
    CLEAR v_mensagem. v_mensagem = TEXT-001.
    PERFORM pf_atualiza_log_2    USING wa_zentrada_valid
                                           wa_lfa1-lifnr
                                           v_mensagem
                                           '10'
                                           'I'.
  ELSE.
**** Valida Nível Fatura
    LOOP AT ti_zentrada_valid INTO wa_zentrada_valid.
      IF wa_zentrada_valid-numerodocumento IS INITIAL.
        "Há entrada sem Numero da Fatura
        CLEAR v_mensagem. v_mensagem = TEXT-002.
        PERFORM pf_atualiza_log  USING wa_zentrada_valid
                                       wa_lfa1-lifnr
                                       v_mensagem
                                       '10'.
      ENDIF.

      IF wa_zentrada_valid-cpfcnpj IS INITIAL.
        "Há entrada sem CNPJ
        CLEAR v_mensagem. v_mensagem = TEXT-003.
        PERFORM pf_atualiza_log  USING wa_zentrada_valid
                                       wa_lfa1-lifnr
                                       v_mensagem
                                       '10'.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF ti_return[] IS INITIAL.

**** Seleciona todas as CT-es da Fatura.
    SELECT idtitulo
           numerodocumento
           chave
           chave_fat
           razaosocial
      FROM zhms_tb_fatura INTO TABLE ti_fatura_cte
      FOR ALL ENTRIES IN ti_zentrada_valid
                   WHERE idtitulo        = ti_zentrada_valid-idtitulo
                     AND numerodocumento = ti_zentrada_valid-numerodocumento
                     AND chave_fat       = v_chave.

    IF sy-subrc EQ 0.
*** Seleciona Dados Mneumônicos CT-es da Fatura
      CLEAR ti_docmn.

      SELECT mandt chave seqnr mneum dcitm atitm value lote
        FROM zhms_tb_docmn
         INTO TABLE ti_docmn
          FOR ALL ENTRIES IN ti_fatura_cte
        WHERE chave EQ ti_fatura_cte-chave
          AND ( mneum EQ 'NCT'        OR        " Número CT-e
                mneum EQ 'CCT'        OR
                mneum EQ 'NDOC'       OR        " Tag Nf-e - para Minuta
                mneum EQ 'INFNFECHAV' OR  " Tag Nf-e - para CT-e Autorizada - com CTEPROC
                mneum EQ 'CHAVE'      OR
                mneum EQ 'DEMI'       OR
                mneum EQ 'NPROT'      OR
                mneum EQ 'DHRECBTO'   OR
                mneum EQ 'TPEMIS'     OR
                mneum EQ 'CCT'        OR
                mneum EQ 'CDV'        OR
                mneum EQ 'VTPREST'    OR
                mneum EQ 'EMITCNPJ'   OR
                mneum EQ 'REMEUF'     OR
                mneum EQ 'DESTUF'     OR
                mneum EQ 'DESTCPAIS'  OR
                mneum EQ 'SERIE'      OR
                mneum EQ 'DHEMI' ).         " Data de Emissão - para Minuta

      IF sy-subrc EQ 0.
        " Monta tabela entrada por Fatura x N CT-es com os dados lidos os mneumônicos
        CLEAR ti_zentrada_valid.
        CLEAR wa_zentrada_valid_aux.
        " roho.
        READ TABLE zentrada_valid INTO wa_zentrada_valid_aux INDEX 1.
        LOOP AT ti_fatura_cte INTO wa_fatura_cte.
          " Verifica se há Número de CT-e
          READ TABLE ti_docmn INTO wa_docmn WITH KEY mneum = 'NCT'.
*          READ TABLE ti_docmn INTO wa_docmn WITH KEY mneum = 'CCT'.
          IF sy-subrc EQ 0.

            LOOP AT ti_docmn INTO wa_docmn  WHERE   chave EQ wa_fatura_cte-chave " Leitura chave CT-e
                                             AND  ( mneum EQ 'NDOC'       OR " Tag Nf-e - para Minuta
                                                    mneum EQ 'INFNFECHAV' OR " Tag Nf-e - para CT-e Autorizada - com CTEPROC
                                                    mneum EQ 'CHAVE').       "
              DATA: lv_tabix TYPE i.
              lv_tabix = sy-tabix. "Lê indice para futura leitura do DEMI

              wa_zentrada_valid-idtitulo          = wa_fatura_cte-idtitulo.          " Id Título
              wa_zentrada_valid-numerodocumento   = wa_fatura_cte-numerodocumento.   " Fatura
              wa_zentrada_valid-cpfcnpj           = wa_zentrada_valid_aux-cpfcnpj.   " CNPJ Transportadora
              wa_zentrada_valid-chave_cte         = wa_fatura_cte-chave.             " Chave CT-e
              CASE wa_docmn-mneum.
                WHEN 'NDOC'.
                  wa_zentrada_valid-ndoc          = wa_docmn-value.                  " Nota fiscal - Modelo CT-e Minuta
                WHEN 'INFNFECHAV'.
                  wa_zentrada_valid-ndoc          = wa_docmn-value+25(9).            " Nota fiscal - Modelo CT-e Normal (Offset)
                WHEN 'CHAVE'.
                  wa_zentrada_valid-ndoc          = wa_docmn-value+25(9).            " Nota fiscal - Modelo CT-e Normal (Offset)
              ENDCASE.

**** Lê chave de acesso para encontrar a data de emissão quando é uma CT-e normal
              IF wa_docmn-mneum EQ 'INFNFECHAV' OR wa_docmn-mneum  EQ'CHAVE'.
                DATA: lv_docnum TYPE j_1bnfdoc-docnum.
                wa_chave = wa_docmn-value.
                SELECT SINGLE docnum INTO lv_docnum
                                     FROM j_1bnfe_active
                                    WHERE regio   EQ wa_chave-regio
                                      AND nfyear  EQ wa_chave-nfyear
                                      AND nfmonth EQ wa_chave-nfmonth
                                      AND stcd1   EQ wa_chave-stcd1
                                      AND model   EQ wa_chave-model
                                      AND serie   EQ wa_chave-serie
                                      AND nfnum9  EQ wa_chave-nfnum9
                                      AND docnum9 EQ wa_chave-docnum9
                                      AND cdv     EQ wa_chave-cdv.
                IF sy-subrc EQ 0.
                  SELECT SINGLE pstdat FROM
                             j_1bnfdoc INTO
               wa_zentrada_valid-nemi WHERE docnum EQ lv_docnum.
                ELSE.
                  "Há entrada(s) sem Número do Cte
                  " NF "Numero do Nfe" não encontrada no sistema
                  CONCATENATE TEXT-012
                  wa_chave-nfnum9 TEXT-013 INTO v_mensagem SEPARATED BY space.
                  PERFORM pf_atualiza_log  USING wa_zentrada_valid
                                                 wa_lfa1-lifnr
                                                 v_mensagem
                                                 '10'.
                  EXIT.
                ENDIF.
              ENDIF.
              CLEAR v_demi.
              LOOP AT ti_docmn INTO wa_docmn FROM lv_tabix " Atenção, leitura indexada, não remover o sy-tabix
                                            WHERE chave EQ wa_fatura_cte-chave
                                              AND mneum EQ 'DEMI' . " " Lê a partir do index acima para
                " Ler a data de emissão correspondente a Nota correta.
                v_demi = wa_docmn-value.
                TRANSLATE v_demi USING '- '.
                CONDENSE v_demi NO-GAPS.
                wa_zentrada_valid-nemi = v_demi. " Nota emissão
                EXIT.
              ENDLOOP.

              READ TABLE ti_docmn INTO wa_docmn WITH KEY chave = wa_fatura_cte-chave
                                                         mneum = 'NCT'.
*                                                         mneum = 'CCT'.
              IF sy-subrc EQ 0.
                wa_zentrada_valid-nct = wa_docmn-value.
                CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                  EXPORTING
                    input  = wa_zentrada_valid-ndoc
                  IMPORTING
                    output = wa_zentrada_valid-ndoc.
                APPEND wa_zentrada_valid TO ti_zentrada_valid. " Insere/Append tabela por nota fiscal
                CLEAR wa_zentrada_valid.
              ENDIF.
            ENDLOOP.

          ELSE.
            "Há entrada(s) sem Número do Cte
            CLEAR v_mensagem. v_mensagem = TEXT-005.
            PERFORM pf_atualiza_log  USING wa_zentrada_valid
                                           wa_lfa1-lifnr
                                           v_mensagem
                                           '10'.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.

  IF ti_return[]         IS INITIAL AND
     ti_zentrada_valid[] IS NOT INITIAL.

    "Realizar a busca abaixo da NF-e do CT-e
    IF ti_zentrada_valid IS NOT INITIAL.
      SELECT docnum nfenum
        FROM j_1bnfdoc
        INTO TABLE ti_j1bnfdoc
        FOR ALL ENTRIES IN ti_zentrada_valid
        WHERE nfenum = ti_zentrada_valid-ndoc "Numero do Nfe
          AND direct = '2'.
*          AND pstdat = ti_zentrada_valid-nemi.  "Data de emissão da Nfe
    ENDIF.

    "Se não encontrar nenhuma linha, enviar o e-mail com a mensagem
    IF sy-subrc NE 0.
      "Nenhuma NF encontrada para validar com o DT.
      CLEAR v_mensagem. v_mensagem = TEXT-007.
      PERFORM pf_atualiza_log  USING wa_zentrada_valid
                                     wa_lfa1-lifnr
                                     v_mensagem
                                     '10'.
    ELSE.   " Se encontrou na j_1bnfdoc

      SELECT lifnr stcd1 stcd2
        FROM lfa1
        INTO TABLE ti_lfa1
        FOR ALL ENTRIES IN ti_zentrada_valid
        WHERE stcd1 = ti_zentrada_valid-cpfcnpj.        "#EC CI_NOFIELD

      IF sy-subrc EQ 0.

        " Caso tenha encontrado DOCNUM, efetuar a seguinte busca:
        IF ti_j1bnfdoc IS NOT INITIAL.
          SORT ti_j1bnfdoc BY docnum.
          SELECT docnum itmnum refkey refitm
            FROM j_1bnflin
            INTO TABLE ti_j1bnflin_dt
             FOR ALL ENTRIES IN ti_j1bnfdoc
           WHERE docnum EQ ti_j1bnfdoc-docnum.
        ENDIF.
        IF sy-subrc EQ 0.
          LOOP AT ti_j1bnflin_dt INTO wa_j1bnflin_dt.
            wa_refkey-refkey = wa_j1bnflin_dt-refkey.
            wa_refkey-vbeln  = wa_j1bnflin_dt-refkey(10).
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
          IF sy-subrc NE 0.

            "Nenhum Doc. de transporte não encontrado
            CLEAR v_mensagem. v_mensagem = TEXT-010.
            PERFORM pf_atualiza_log  USING wa_zentrada_valid
                                           wa_lfa1-lifnr
                                           v_mensagem
                                           '10'.
          ELSE.
            " Valida linha a linha
            LOOP AT ti_zentrada_valid INTO wa_zentrada_valid.
              LOOP AT ti_lfa1 INTO wa_lfa1 WHERE ( stcd1 EQ wa_zentrada_valid-cpfcnpj
                                              OR   stcd2 EQ wa_zentrada_valid-cpfcnpj ).
              ENDLOOP.
              IF sy-subrc EQ 0.
                READ TABLE ti_j1bnfdoc INTO wa_j1bnfdoc WITH KEY nfenum = wa_zentrada_valid-ndoc. "Checa se há Nota fiscal
                IF sy-subrc EQ 0.
                  READ TABLE ti_j1bnflin_dt INTO wa_j1bnflin_dt WITH KEY docnum = wa_j1bnfdoc-docnum.
                  IF sy-subrc EQ 0.
                    READ TABLE ti_refkey INTO wa_refkey WITH KEY refkey = wa_j1bnflin_dt-refkey.
                    IF sy-subrc EQ 0.
                      READ TABLE ti_vttp_vbrp INTO wa_vttp_vbrp WITH KEY vbeln = wa_refkey-vbeln.
                      IF sy-subrc EQ 0.
                        "Insere / Atualiza ZHMS_TB_STATUS
                        PERFORM pf_atualiza_status  USING wa_zentrada_valid
                                                          wa_vttp_vbrp-tknum
                                                          wa_lfa1-lifnr
                                                          '10'.
                      ELSE.
                        " Doc. de transporte não encontrado para NF "Número da NF"
                        CLEAR v_mensagem.
                        CONCATENATE TEXT-014
                        wa_zentrada_valid-ndoc INTO v_mensagem SEPARATED BY space.
                        PERFORM pf_atualiza_log  USING wa_zentrada_valid
                                                       wa_lfa1-lifnr
                                                       v_mensagem
                                                       '10'.
                      ENDIF.
                    ENDIF.
                  ENDIF.

                ELSE.
                  " NF "Numero do Nfe" não encontrada no sistema
                  CONCATENATE TEXT-012
                  wa_zentrada_valid-ndoc TEXT-013 INTO v_mensagem SEPARATED BY space.
                  PERFORM pf_atualiza_log  USING wa_zentrada_valid
                                                 wa_lfa1-lifnr
                                                 v_mensagem
                                                 '10'.
                  CLEAR wa_return.
                ENDIF.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ELSE.
        CLEAR v_mensagem. v_mensagem = TEXT-011.
        PERFORM pf_atualiza_log  USING wa_zentrada_valid
                                       wa_lfa1-lifnr
                                       v_mensagem
                                       '10'.
      ENDIF.
    ENDIF.

  ENDIF.

  SORT ti_return.
  DELETE ADJACENT DUPLICATES FROM ti_return.
  IF NOT ti_return[] IS INITIAL.
    return[] = ti_return[].
  ELSE.

    CLEAR v_mensagem. v_mensagem = TEXT-065.
    PERFORM pf_atualiza_log_2    USING wa_zentrada_valid
                                           wa_lfa1-lifnr
                                           v_mensagem
                                           '10'
                                           'I'.
    return[] = ti_return[].
  ENDIF.

  IF ti_tb_log[] IS NOT INITIAL.
    MODIFY zhms_tb_log FROM TABLE ti_tb_log.
    COMMIT WORK AND WAIT.
  ENDIF.

ENDFUNCTION.
