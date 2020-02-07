*-------------------------------------------------------------------*
*                       HomSoft - Validações                        *
*-------------------------------------------------------------------*
* Descrição	: Realiza as verificações definidas nas regras para     *
*    um documento                                                   *
*-------------------------------------------------------------------*
FUNCTION zhms_fm_validar.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(VLDCD) TYPE  ZHMS_DE_VLDCD
*"     REFERENCE(CABDOC) TYPE  ZHMS_TB_CABDOC
*"     REFERENCE(REGHIST) TYPE  FLAG DEFAULT 'X'
*"  EXPORTING
*"     REFERENCE(VLDTY) TYPE  ZHMS_DE_VLDTY
*"----------------------------------------------------------------------

* Inicializar Variáveis internas
  PERFORM f_inicializa_variaveis USING vldcd
                                       cabdoc.

* Executar Rotina de validação
  CHECK NOT wa_pkgvld-derot IS INITIAL.
  PERFORM (wa_pkgvld-derot) IN PROGRAM saplzhms_fg_validate IF FOUND.
  PERFORM (wa_pkgvld-derot) IN PROGRAM saplzhms_fg_ruler TABLES it_hrvalid IF FOUND.

* Trata resultados encontrados
  PERFORM f_registra_resultados USING reghist CHANGING vldty.

  IF vldty EQ 'E'.

    CLEAR: lv_usuario, lv_ebeln, lv_titulo,
           lv_nnf, lv_nnf, lv_serie, lv_corpo,
           lv_parid, ls_hrvalid, wa_cf_email.

    REFRESH: lt_hrvalid[].
*** Valida se deve ser enviado o e-mail
    SELECT SINGLE *
      FROM zhms_tb_cf_email
      INTO wa_cf_email
     WHERE tp_email EQ '03'
       AND ativo EQ 'X'.

    CHECK sy-subrc IS INITIAL.

    SELECT SINGLE docnr serie parid
    FROM zhms_tb_cabdoc
    INTO (lv_nnf, lv_serie, lv_parid)
    WHERE chave EQ cabdoc-chave.

    IF sy-subrc IS INITIAL.
      CLEAR lv_ebeln.
      SELECT SINGLE value INTO lv_ebeln
      FROM zhms_tb_docmn
      WHERE chave EQ cabdoc-chave
       AND mneum EQ 'XPED'.

*** Verifica se já foi atribuido o pedido
      IF NOT sy-subrc IS INITIAL.
        READ TABLE it_itmatr INTO wa_itmatr INDEX 1.
        IF sy-subrc IS INITIAL.
          MOVE wa_itmatr-nrsrf TO lv_ebeln.
        ENDIF.
      ENDIF.

      IF NOT lv_ebeln IS INITIAL.
        SELECT SINGLE ebeln ernam
        FROM ekko
        INTO (lv_ebeln, lv_usuario)
        WHERE ebeln EQ lv_ebeln.

        IF NOT lv_ebeln IS INITIAL AND NOT lv_usuario IS INITIAL.

          SELECT SINGLE *
            FROM zhms_tb_mail
            INTO wa_mail
            WHERE uname = lv_usuario.
          IF wa_mail-ferias = 'X'.
            lv_usuario = wa_mail-userid.
          ENDIF.
*** Monta Titulo e-mail
          CONCATENATE 'Nota' lv_nnf
                      'do fornecedor' lv_parid
                      '- HomSoft' INTO lv_titulo
          SEPARATED BY space.

*** Seleciona Erros
          SELECT *
            FROM zhms_tb_hrvalid
            INTO TABLE lt_hrvalid
            WHERE chave EQ cabdoc-chave
              AND ativo EQ 'X'.


          IF sy-subrc IS INITIAL.
            LOOP AT lt_hrvalid INTO ls_hrvalid.
              IF sy-tabix EQ '1'.
*** Monta Corpo Email
                CONCATENATE 'Foi identificado uma divergência entre a NF-e' lv_nnf '-' lv_serie 'e o pedido Nº' lv_ebeln 'de sua autoria, o mesmo encontra-se pendente no HomSoft aguardando sua tomada de ação. Erros:' INTO lv_corpo
               SEPARATED BY space.
              ENDIF.

              CONCATENATE lv_corpo ls_hrvalid-vldv2 INTO lv_corpo SEPARATED BY space.
            ENDLOOP.
          ENDIF.

* Envia Email ao usuario respnsável
          CALL FUNCTION 'ZHMS_ENVIA_EMAIL'
            EXPORTING
              usuario = lv_usuario
              OTHERS  = 'X'
              titulo  = lv_titulo
              corpo   = lv_corpo.
        ENDIF.
*        ENDIF.
      ENDIF.

    ENDIF.
  ENDIF.


ENDFUNCTION.
