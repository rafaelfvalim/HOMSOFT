*&---------------------------------------------------------------------*
*&  Include           ZHMS_JOB_CHECK_CFOP_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_CARREGA_IMAGEM
*&---------------------------------------------------------------------*
FORM f_carrega_imagem .

  DATA: lv_repid LIKE sy-repid.

  lv_repid = sy-repid.

  CREATE OBJECT go_fig
    EXPORTING
      parent = go_cont_fig.

  CHECK sy-subrc IS INITIAL.

* Adiciona borda
  CALL METHOD go_fig->set_3d_border
    EXPORTING
      border = 5.

* Modo de exibição -> stretch (esticado)
  CALL METHOD go_fig->set_display_mode
    EXPORTING
      display_mode = cl_gui_picture=>display_mode_stretch.

* Define o tamanho da imagem de acordo com as cordenadas de linha/coluna
  CALL METHOD go_fig->set_position
    EXPORTING
      height = 197
      left   = 1
      top    = 63
      width  = 948.

  IF gv_url IS INITIAL.

    REFRESH it_query.

    it_query-name  = '_OBJECT_ID'.

* Nome da figura carregada na transação SMW0
    it_query-value = 'ZLOGO3'.

    APPEND it_query.

    CALL FUNCTION 'WWW_GET_MIME_OBJECT'
      TABLES
        query_string        = it_query
        html                = it_html
        mime                = it_fig_data
      CHANGING
        return_code         = gv_return
        content_type        = gv_content
        content_length      = gv_cont_len
      EXCEPTIONS
        object_not_found    = 1
        parameter_not_found = 2
        OTHERS              = 3.

* Gera um endereço URL
    CALL FUNCTION 'DP_CREATE_URL'
      EXPORTING
        type     = 'image'
        subtype  = cndp_sap_tab_unknown
        size     = gv_fig_len
        lifetime = cndp_lifetime_transaction
      TABLES
        data     = it_fig_data
      CHANGING
        url      = gv_url
      EXCEPTIONS
        OTHERS   = 1.

  ENDIF.

* Exibe a figura pela URL gerada
  CALL METHOD go_fig->load_picture_from_url
    EXPORTING
      url = gv_url.

ENDFORM.                    " F_CARREGA_IMAGEM
*&---------------------------------------------------------------------*
*&      Form  F_INICIALIZACAO
*&---------------------------------------------------------------------*
*       Inicializando as Tabelas internas e variáveis
*----------------------------------------------------------------------*
FORM f_inicializacao .

  REFRESH:
  it_cfop_180, it_fig_data, it_query, it_html, it_evt, it_docmn,
  it_cabdoc, it_alv, it_fcat1.

  CLEAR:
  wa_cfop_180, wa_docmn, wa_cabdoc, wa_alv, wa_fcat1.

ENDFORM.                    " F_INICIALIZACAO
*&---------------------------------------------------------------------*
*&      Form  F_SELECIONA_DADOS
*&---------------------------------------------------------------------*
*       Seleção dos Dados a serem exibidos
*----------------------------------------------------------------------*
FORM f_seleciona_dados .

  SELECT * FROM zhms_tb_cfop180 INTO TABLE it_cfop_180.
  IF sy-subrc EQ 0.

    SELECT *
      FROM zhms_tb_cabdoc
     INTO TABLE it_cabdoc
     WHERE bukrs  IN s_bukrs
       AND branch IN s_branch
       AND docnr  IN s_docnr
       AND chave  IN s_chave
       AND parid  IN s_parid
       AND lncdt  IN s_lncdt.

    IF sy-subrc IS INITIAL.
      SELECT chave
             seqnr
             mneum
             dcitm
             value
        FROM zhms_tb_docmn
        INTO TABLE it_docmn
        FOR ALL ENTRIES IN it_cabdoc
       WHERE chave EQ it_cabdoc-chave.
    ENDIF.

*TYPES: BEGIN OF ty_j1bnfdoc,
*         docnum       TYPE j_1bnfdoc-docnum, "Docnum
*         nfenum       TYPE j_1bnfdoc-nfenum, "Nota fiscal
*         docdat       TYPE j_1bnfdoc-docdat, "Data emissão
*       END OF ty_j1bnfdoc,
*
*       BEGIN OF ty_j1bnflin,
*         docnum       TYPE j_1bnflin-docnum, "Docnum
*         itmtyp       TYPE j_1bnflin-itmtyp, "Item
*         matnr        TYPE j_1bnflin-matnr,  "Material
*         maktx        TYPE j_1bnflin-maktx,  "Descrição material
*         menge        TYPE j_1bnflin-menge,  "Quantidade NF-e

*         qnt_devolv   TYPE j_1bnflin-menge,  "Quantidade Devolvida
*         qnt_pendente TYPE j_1bnflin-menge,  "Quantidade Pendente
*         qnt_estoque  TYPE j_1bnflin-menge,  "Quantidade Estoque
*         qnt_fornec   TYPE j_1bnflin-menge,  "Quantidade Fornecedor
*       END OF ty_j1bnflin,

  ENDIF.

* Monta tabela de dados da parte de cima do cockpit
  PERFORM f_monta_header.

* Monta catálogo de campos da parte de cima do cockpit
  PERFORM f_monta_fcat USING:
        'MARK'          text-h01   abap_true   abap_true   space,
        'ST_ESCR'       text-h02   space       space       space,
        'STATUS'        text-h03   space       space       space,
        'BUKRS'         text-h04   space       space       space,
        'NF_CLI'        text-h05   space       space       abap_true,
        'DT_EMI'        text-h06   space       space       space,
        'NF_ESCR'       text-h07   space       space       space,
        'NF_ITM'        text-h08   space       space       space,
        'MATERIAL'      text-h09   space       space       space,
        'DESCRICAO'     text-h10   space       space       space,
        'QTD_NF'        text-h11   space       space       space,
        'QTD_DEV'       text-h12   space       space       space,
        'QTD_PEND'      text-h13   space       space       space,
        'QTD_ESTOQUE'   text-h14   space       space       space,
        'QTD_FORN'      text-h15   space       space       space,
        'DIAS'          text-h16   space       space       space.

** Monta tabela de dados da legenda
*  PERFORM f_monta_legenda USING:
*        c_esc       text-o01,
*        c_n_esc     text-o02,
*        c_100       text-o03,
*        c_100_180   text-o04,
*        c_180       text-o05,
*        c_devol     text-o06,
*        c_na        text-o07.

ENDFORM.                    " F_SELECIONA_DADOS
*&---------------------------------------------------------------------*
*&      Form  F_MONTA_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form F_MONTA_HEADER .

  SELECT *
    FROM zhms_tb_cabdoc
    INTO TABLE it_cabdoc
   WHERE bukrs IN s_bukrs
     AND branch IN s_branch
     AND docnr IN s_docnr
     AND chave IN s_chave
     AND parid IN s_parid
     AND lncdt IN s_lncdt.

  IF sy-subrc IS INITIAL.

    SELECT chave
           seqnr
           mneum
           dcitm
           value
      FROM zhms_tb_docmn
      INTO TABLE it_docmn
       FOR ALL ENTRIES IN it_cabdoc
     WHERE chave EQ it_cabdoc-chave.

** Seleciona somente CFOP 1949/AA
*    SELECT chave
*      FROM zhms_tb_docmn
*      INTO TABLE it_chave
*     WHERE mneum EQ 'CFOP'
*       AND value EQ '1949/AA'.
*
*    LOOP AT it_chave INTO wa_chave.
*
*      wa_filtro-sign   = c_sign.
*      wa_filtro-option = c_option.
*      wa_filtro-low    = wa_chave-chave.
*
*      APPEND wa_filtro TO rg_filtro.
*
*    ENDLOOP.
*
*    DELETE it_docmn WHERE chave NOT IN rg_filtro.

  ENDIF.

  LOOP AT it_docmn INTO wa_docmn.

    wa_itens-chave = wa_docmn-chave.
    wa_itens-dcitm = wa_docmn-dcitm.

    APPEND wa_itens TO it_itens.

  ENDLOOP.

  SORT it_itens.

  DELETE ADJACENT DUPLICATES FROM it_itens COMPARING ALL FIELDS.

  DELETE it_itens WHERE dcitm EQ '000000'.

  SORT it_docmn BY chave mneum dcitm.

  LOOP AT it_itens INTO wa_itens.

* Empresa
    READ TABLE it_cabdoc INTO wa_cabdoc WITH KEY chave = wa_itens-chave.

    wa_outtab-bukrs = wa_cabdoc-bukrs.
    wa_outtab-chave = wa_itens-chave.

    CLEAR wa_docmn.

    READ TABLE it_docmn INTO wa_docmn WITH KEY chave = wa_itens-chave
                                               mneum = 'NNF'
                                               BINARY SEARCH.

* Nota do cliente
    wa_outtab-nf_cli = wa_docmn-value.

    CLEAR wa_docmn.

    READ TABLE it_docmn INTO wa_docmn WITH KEY chave = wa_itens-chave
                                               mneum = 'DHEMI'
                                               BINARY SEARCH.

* Data de emissão
    CONCATENATE wa_docmn-value(4) wa_docmn-value+5(2) wa_docmn-value+8(2)
           INTO wa_outtab-dt_emi.

    CLEAR wa_docmn.

    READ TABLE it_docmn INTO wa_docmn WITH KEY chave = wa_itens-chave
                                               mneum = 'MATDOC'
                                               BINARY SEARCH.

    IF sy-subrc IS INITIAL.

* Nota escriturada
      wa_outtab-st_escr = c_esc.
      wa_outtab-nf_escr = wa_docmn-value.

    ELSE.

* Nota não escriturada
      wa_outtab-st_escr = c_n_esc.

    ENDIF.

    wa_outtab-nf_itm = wa_itens-dcitm.

    CLEAR wa_docmn.

    READ TABLE it_docmn INTO wa_docmn WITH KEY chave = wa_itens-chave
                                               mneum = 'CPROD'
                                               dcitm = wa_itens-dcitm
                                               BINARY SEARCH.

* Material
    wa_outtab-material = wa_docmn-value.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = wa_docmn-value
      IMPORTING
        output = gv_matnr.

* Descrição
    SELECT SINGLE maktx
      FROM makt
      INTO wa_outtab-descricao
     WHERE matnr EQ gv_matnr.

    CLEAR wa_docmn.

    READ TABLE it_docmn INTO wa_docmn WITH KEY chave = wa_itens-chave
                                               mneum = 'QCOM'
                                               dcitm = wa_itens-dcitm
                                               BINARY SEARCH.

* Quantidade da NF
    wa_outtab-qtd_nf = wa_docmn-value.

* Seleciona todas as notas enviadas para cliente ou fornecedor (saída)
    SELECT chave
           seqnr
           mneum
           dcitm
           value
      FROM zhms_tb_docmn
      INTO TABLE it_doc_det
     WHERE chave EQ wa_itens-chave
       AND mneum IN (c_nfcli,c_nfforn)
       AND dcitm EQ wa_itens-dcitm.

    REFRESH rg_nf_det.

    LOOP AT it_doc_det INTO wa_docmn.

      wa_nf_det-sign   = c_sign.
      wa_nf_det-option = c_option.
      wa_nf_det-low    = wa_docmn-value.

      APPEND wa_nf_det TO rg_nf_det.

      CLEAR wa_nf_det.

    ENDLOOP.

    REFRESH it_doclin.

    IF NOT rg_nf_det[] IS INITIAL.

* Seleciona dados das notas de saída
      SELECT h~docnum
             h~nfenum
             h~docdat
             h~parvw
             h~parid
             i~matnr
             i~menge
             h~nfenum
        INTO TABLE it_doclin
        FROM j_1bnfdoc AS h
       INNER JOIN j_1bnflin AS i
          ON h~docnum EQ i~docnum
       WHERE h~docnum IN rg_nf_det.

    ENDIF.

* Inicia a quantidade total da nota
    gv_menge = wa_outtab-qtd_nf.

    CLEAR gv_forn.

    LOOP AT it_doclin INTO wa_doclin.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = wa_doclin-nfe_c
        IMPORTING
          output = wa_doclin-nfe_c.

* Seleciona a nota de escrituração no caso de nota para fornecedor (entrada)
      SELECT SINGLE chave
                    seqnr
                    mneum
                    dcitm
                    value
        FROM zhms_tb_docmn
        INTO wa_docmn
       WHERE mneum EQ 'REFERENCE'
         AND value EQ wa_doclin-nfe_c.

      IF sy-subrc IS INITIAL.

* Número da nota de escrituração
        SELECT SINGLE value
          FROM zhms_tb_docmn
          INTO wa_doclin-nf_esc
         WHERE chave EQ wa_docmn-chave
           AND mneum EQ 'NNF'.

* Quantidade devolvida pelo fornecedor
        SELECT SINGLE value
          FROM zhms_tb_docmn
          INTO wa_doclin-menge_esc
         WHERE chave EQ wa_docmn-chave
           AND mneum EQ 'QCOM'.

* Docnum da nota de escrituração
        SELECT SINGLE value
          FROM zhms_tb_docmn
          INTO wa_doclin-doc_esc
         WHERE chave EQ wa_docmn-chave
           AND mneum EQ 'MATDOC'.

      ENDIF.

* Caso seja cliente -> subtrai do total
      IF wa_doclin-parvw EQ c_ag.

        gv_menge = gv_menge - wa_doclin-menge.

* Caso seja fornecedor -> acumula a quantidade e subtrai o que foi devolvido
      ELSEIF wa_doclin-parvw EQ c_lf.

        gv_forn = gv_forn + wa_doclin-menge - wa_doclin-menge_esc.

      ENDIF.

    ENDLOOP.

* Quantidade pendente
    wa_outtab-qtd_pend = gv_menge.


* Quantidade com fornecedor
    wa_outtab-qtd_forn = gv_forn.

*} Inicio Alteracao 001 Homine (RIT) 03/07/18
***> ALTERADO PARA NÃO CALCULAR QUANDO A NOTA NÃO ESTIVER ESCRITURADA
    IF wa_outtab-st_escr NE c_n_esc.
* Quantidade em "estoque"
      wa_outtab-qtd_estoque = wa_outtab-qtd_pend - wa_outtab-qtd_forn.
    ELSE.
      wa_outtab-qtd_estoque = 0.
    ENDIF.
*{ Fim Alteracao 001 Homine (RIT) 03/07/18

* Quantidade devolvida
    wa_outtab-qtd_dev = wa_outtab-qtd_nf - wa_outtab-qtd_pend.

    IF wa_outtab-qtd_pend IS INITIAL.

* Dias
      wa_outtab-dias   = 0.

* Nota com quantidade integralmente devolvida
      wa_outtab-status = c_devol.

    ELSE.

* Dias
      wa_outtab-dias = sy-datum - wa_outtab-dt_emi.

* Verde
      IF wa_outtab-dias LE 100.

        wa_outtab-status = c_100.

* Amarelo
      ELSEIF wa_outtab-dias GT 100 AND wa_outtab-dias LE 180.

        wa_outtab-status = c_100_180.

* Vermelho
      ELSE.

        wa_outtab-status = c_180.

      ENDIF.

    ENDIF.

* Se NF = não escriturada ou quant. pendente = 0 ou quant. em estoque = 0
    IF wa_outtab-st_escr EQ c_n_esc OR
       wa_outtab-qtd_pend IS INITIAL OR
       wa_outtab-qtd_estoque IS INITIAL.

* Fecha o campo de seleção de NF (flag)
      wa_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.

      APPEND wa_stylerow TO wa_outtab-field_style.

    ENDIF.

    APPEND wa_outtab TO it_outtab.

    CLEAR wa_outtab.

  ENDLOOP.

  it_outtab_aux[] = it_outtab[].
endform.                    " F_MONTA_HEADER
*&---------------------------------------------------------------------*
*&      Form  F_MONTA_FCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form F_MONTA_FCAT  using p_nome
                         p_texto
                         p_edit
                         p_checkbox
                         p_hotspot.

  CLEAR wa_fcat1.

  wa_fcat1-fieldname = p_nome.
  wa_fcat1-reptext   = p_texto.
  wa_fcat1-edit      = p_edit.
  wa_fcat1-checkbox  = p_checkbox.
  wa_fcat1-hotspot   = p_hotspot.

  APPEND wa_fcat1 TO it_fcat1.

endform.                    " F_MONTA_FCAT
*&---------------------------------------------------------------------*
*&      Form  F_MONTA_LEGENDA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_C_ESC  text
*      -->P_TEXT_O01  text
*----------------------------------------------------------------------*
*form F_MONTA_LEGENDA  using p_icone
*                            p_descr.
*
*  CLEAR wa_leg.
*
*  wa_leg-icone = p_icone.
*  wa_leg-descr = p_descr.
*
*  APPEND wa_leg TO it_leg.
*
*endform.                    " F_MONTA_LEGENDA
