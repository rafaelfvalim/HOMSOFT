*&---------------------------------------------------------------------*
*&  Include           ZHMS_CONTROLE_180_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_SELECIONA_DADOS
*&---------------------------------------------------------------------*
FORM f_seleciona_dados.

* Monta tabela de dados da parte de cima do cockpit
  PERFORM f_monta_header.

* Monta catálogo de campos da parte de cima do cockpit
  PERFORM f_monta_fcat USING:
             'STATUS'        text-h01   space       space       space,
             'NF_ESCR'       text-h04   space       space       space,
             'BUKRS'         text-h14   space       space       space,
             'NFENUM'        text-h02   space       space       space,
             'NFENUM_ENT'    text-h15   space       space       space,
             'DT_EMI'        text-h03   space       space       space,
             'NF_ITM'        text-h05   space       space       space,
             'MATERIAL'      text-h06   space       space       space,
             'DESCRICAO'     text-h07   space       space       space,
             'QTD_NF'        text-h08   space       space       space,
             'QTD_DEV'       text-h09   space       space       space,
             'QTD_PEND'      text-h10   space       space       space,
             'QTD_ESTOQUE'   text-h11   space       space       space,
             'QTD_FORN'      text-h12   space       space       space,
             'DIAS'          text-h13   space       space       space.

ENDFORM.                    " F_SELECIONA_DADOS
*&---------------------------------------------------------------------*
*&      Form  F_MONTA_FCAT
*&---------------------------------------------------------------------*
FORM f_monta_fcat USING p_nome
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

ENDFORM.                    " F_MONTA_FCAT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.

  SET PF-STATUS 'STATUS_200'.
*  SET PF-STATUS 'CTL180'.
  SET TITLEBAR 'TITLE_200'.

* Instancia o objeto apenas uma vez
  IF go_grid IS INITIAL.

*    CREATE OBJECT go_event.

    CREATE OBJECT go_grid
      EXPORTING
        container_name              = 'ALVSAIDA'
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        OTHERS                      = 6.

    CREATE OBJECT go_alv
      EXPORTING
        i_parent          = go_grid
      EXCEPTIONS
        error_cntl_create = 1
        error_cntl_init   = 2
        error_cntl_link   = 3
        error_dp_create   = 4
        OTHERS            = 5.

    wa_layout1-cwidth_opt = 'X'.  "Otimizar tamanho das colunas
    wa_layout1-zebra      = 'X'.  "Zebra
    wa_layout1-info_fname = 'COLOR'.
*    wa_layout1-no_toolbar = abap_true.     "Sem a barra padrão do ALV
*    wa_layout1-no_rowmark = abap_true.     "Sem marcador de linhas
*    wa_layout1-stylefname = 'FIELD_STYLE'. "Campo que receberá estilo

*  MOVE: abap_false  TO  wa_layout-grid_title,
*        abap_true   TO  wa_layout-zebra     ,
*        abap_true   TO  wa_layout-numc_total,
*        c_celltab   TO  wa_layout-stylefname,
*        c_a         TO  wa_layout-sel_mode  .

    CALL METHOD go_alv->set_table_for_first_display
      EXPORTING
        i_save          = c_a
        is_layout       = wa_layout1
        is_variant      = wa_variant
      CHANGING
        it_outtab       = it_outtab[]
        it_fieldcatalog = it_fcat1[].

* Chama o método para o clique no número da NF
*    SET HANDLER go_event->hotspot_click FOR go_alv.

*    CALL METHOD go_alv->set_toolbar_interactive.

  ENDIF.

ENDMODULE.                 " STATUS_0200  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  CASE sy-ucomm.

    WHEN c_voltar.

      LEAVE TO SCREEN 0.

    WHEN c_sair.

      LEAVE PROGRAM.

*    WHEN c_nfcli OR c_nfforn.
*
*      PERFORM f_gera_nota.
*
*    WHEN c_stat.
*
*      CALL SCREEN 400 STARTING AT 12 3
*                      ENDING AT 40 8.
*
*    WHEN c_upda.
*
** Monta o campo EMPRESA
*      wa_seltab-selname = 'S_BUKRS'.
*      wa_seltab-sign    = s_bukrs-sign.
*      wa_seltab-option  = s_bukrs-option.
*
*      LOOP AT s_bukrs.
*        wa_seltab-low  = s_bukrs-low.
*        wa_seltab-high = s_bukrs-high.
*        APPEND wa_seltab TO it_seltab.
*      ENDLOOP.
*
** Monta o campo LOCAL DE NEGÓCIOS
*      wa_seltab-selname = 'S_BRANCH'.
*      wa_seltab-sign    = s_branch-sign.
*      wa_seltab-option  = s_branch-option.
*
*      LOOP AT s_branch.
*        wa_seltab-low  = s_branch-low.
*        wa_seltab-high = s_branch-high.
*        APPEND wa_seltab TO it_seltab.
*      ENDLOOP.
*
** Monta o campo Nº DO DOCUMENTO
*      wa_seltab-selname = 'S_DOCNR'.
*      wa_seltab-sign    = s_docnr-sign.
*      wa_seltab-option  = s_docnr-option.
*
*      LOOP AT s_docnr.
*        wa_seltab-low  = s_docnr-low.
*        wa_seltab-high = s_docnr-high.
*        APPEND wa_seltab TO it_seltab.
*      ENDLOOP.
*
** Monta o campo Nº DA CHAVE
*      wa_seltab-selname = 'S_CHAVE'.
*      wa_seltab-sign    = s_chave-sign.
*      wa_seltab-option  = s_chave-option.
*
*      LOOP AT s_chave.
*        wa_seltab-low  = s_chave-low.
*        wa_seltab-high = s_chave-high.
*        APPEND wa_seltab TO it_seltab.
*      ENDLOOP.
*
** Monta o campo ID PARCEIRO
*      wa_seltab-selname = 'S_PARID'.
*      wa_seltab-sign    = s_parid-sign.
*      wa_seltab-option  = s_parid-option.
*
*      LOOP AT s_parid.
*        wa_seltab-low  = s_parid-low.
*        wa_seltab-high = s_parid-high.
*        APPEND wa_seltab TO it_seltab.
*      ENDLOOP.
*
** Monta o campo DATA DE LANÇAMENTO
*      wa_seltab-selname = 'S_LNCDT'.
*      wa_seltab-sign    = s_lncdt-sign.
*      wa_seltab-option  = s_lncdt-option.
*
*      LOOP AT s_lncdt.
*        wa_seltab-low  = s_lncdt-low.
*        wa_seltab-high = s_lncdt-high.
*        APPEND wa_seltab TO it_seltab.
*      ENDLOOP.
*
*      SUBMIT zhms_180_dias_full
*        WITH SELECTION-TABLE it_seltab.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0200  INPUT

**&---------------------------------------------------------------------*
**&      Form  F_GERA_NOTA
**&---------------------------------------------------------------------*
*FORM f_gera_nota.
*
*  DATA: l_itmnum TYPE i.
*
*
** Verifica quais linhas foram selecionadas
*  CALL METHOD go_alv->check_changed_data.
*
*  REFRESH: it_h_bapi,
*           it_i_bapi,
*           it_i_bapi_tax,
*           it_notas.
*
*  LOOP AT it_outtab INTO wa_outtab WHERE mark EQ abap_true.
*
*    READ TABLE it_cabdoc INTO wa_cabdoc WITH KEY chave = wa_outtab-chave.
*
**----------------------------------------------------------------------*
** Dados de cabeçalho                                                   *
**----------------------------------------------------------------------*
*    wa_h_bapi-chave = wa_outtab-chave.
*
** Categoria da nota fiscal
*    wa_h_bapi-nftype = 'N1'.
*
** Tipo de documento (1 -> Nota fiscal)
*    wa_h_bapi-doctyp = '1'.
*
** Direção do movimento de mercadorias (2 -> Saída)
*    wa_h_bapi-direct = '2'.
*
** Data de lançamento
*    wa_h_bapi-pstdat = sy-datum.
*
** Data do documento (emissão)
*    wa_h_bapi-docdat = sy-datum.
*
** Empresa
*    wa_h_bapi-bukrs = wa_cabdoc-bukrs.
*
** Local de negócios
*    wa_h_bapi-branch = wa_cabdoc-branch.
*
** Nota manual
*    wa_h_bapi-manual = abap_true.
*
** NF-e
*    wa_h_bapi-nfe = abap_true.
*
** Moeda
*    wa_h_bapi-waerk = 'BRL'.
*
** Modelo (Nota fiscal - modelo 55)
*    wa_h_bapi-model = '55'.
*
** Série
*    wa_h_bapi-series = '1'.
*
*    CASE sy-ucomm.
*
*      WHEN c_nfcli.
*
** Tipo do parceiro (cliente)
*        wa_h_bapi-parvw = c_ag.
*
** Código do parceiro
*        wa_h_bapi-parid = wa_cabdoc-parid.
*        wa_h_bapi-parid = 'HOMI'.
*
*      WHEN c_nfforn.
*
** Tipo do parceiro (fornecedor)
*        wa_h_bapi-parvw = c_lf.
*
** Código do parceiro
*        wa_h_bapi-parid = '0025000083'.
*
*    ENDCASE.
*
*    CLEAR wa_docmn.
*
*    READ TABLE it_docmn INTO wa_docmn WITH KEY chave = wa_outtab-chave
*                                               mneum = 'NATOP'
*                                               BINARY SEARCH.
*
** Observações
*    wa_h_bapi-observat = wa_docmn-value.
*
**----------------------------------------------------------------------*
** Dados de item                                                        *
**----------------------------------------------------------------------*
*    wa_i_bapi-chave = wa_outtab-chave.
*
*    wa_i_bapi-dcitm = wa_outtab-nf_itm.
*
** Número do item
**    wa_i_bapi-itmnum = '10'.
*    l_itmnum = l_itmnum + 10.
*    wa_i_bapi-itmnum = l_itmnum.
*
** Material e grupo de mercadoria
*    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*      EXPORTING
*        input  = wa_outtab-material
*      IMPORTING
*        output = wa_i_bapi-matnr.
*
** Utilização de material
*    SELECT SINGLE mtuse
*      FROM mbew
*      INTO wa_i_bapi-matuse
*     WHERE matnr EQ wa_i_bapi-matnr
*       AND bwkey EQ 'HOMI'.
*
*    IF NOT sy-subrc IS INITIAL.
*
*      wa_i_bapi-matuse = 0.
*
*    ENDIF.
*
** Centro e área de avaliação (para rodar a BAPI é necessário ter os dois)
*    SELECT SINGLE bwkey werks
*      FROM t001w
*      INTO (wa_i_bapi-bwkey,wa_i_bapi-werks)
*     WHERE j_1bbranch EQ wa_cabdoc-branch.
*
** NCM
*    READ TABLE it_docmn INTO wa_docmn WITH KEY chave = wa_outtab-chave
*                                               mneum = 'XMLNCM'
*                                               dcitm = wa_outtab-nf_itm
*                                               BINARY SEARCH.
*
*    WRITE wa_docmn-value TO wa_i_bapi-nbm USING EDIT MASK '____.__.__'.
*
** Origem de material
*    wa_i_bapi-matorg = '0'.
*
** Quantidade
*    wa_i_bapi-menge = wa_outtab-qtd_estoque.
*
** Unidade de medida (UN -> ST)
*    wa_i_bapi-meins = 'ST'.
*
*    READ TABLE it_docmn INTO wa_docmn WITH KEY chave = wa_outtab-chave
*                                               mneum = 'XPROD'
*                                               dcitm = wa_outtab-nf_itm
*                                               BINARY SEARCH.
*
** Descrição do material
*    wa_i_bapi-maktx = wa_docmn-value.
*
** NFCI (preencher com caractere especial ALT+0160)
*    wa_i_bapi-nfci = ' '.
*
** Preço
*    READ TABLE it_docmn INTO wa_docmn WITH KEY chave = wa_outtab-chave
*                                               mneum = 'VUNCOM'
*                                               dcitm = wa_outtab-nf_itm
*                                               BINARY SEARCH.
*
** Valor unitário
*    wa_i_bapi-netpr = wa_docmn-value.
*
** Valor líquido
*    wa_i_bapi-netwr = wa_i_bapi-netpr * wa_i_bapi-menge.
*
** Categoria do item (item normal)
*    wa_i_bapi-itmtyp = '01'.
*
** CFOP
*    READ TABLE it_docmn INTO wa_docmn WITH KEY chave = wa_outtab-chave
*                                               mneum = 'CFOP'
*                                               dcitm = wa_outtab-nf_itm
*                                               BINARY SEARCH.
*
** Para saída -> CFOP deve iniciar com 5
*    REPLACE '1' WITH '5' INTO wa_docmn-value.
*
*    CALL FUNCTION 'CONVERSION_EXIT_CFOBR_INPUT'
*      EXPORTING
*        input  = wa_docmn-value
*      IMPORTING
*        output = wa_i_bapi-cfop_10.
*
** Direitos fiscais - ICMS
*    CLEAR wa_docmn.
*
*    READ TABLE it_docmn INTO wa_docmn WITH KEY chave = wa_outtab-chave
*                                               mneum = 'CSTICMS'
*                                               dcitm = wa_outtab-nf_itm
*                                               BINARY SEARCH.
*
*    SELECT SINGLE taxlaw
*      FROM j_1batl1 AS icms
*     INNER JOIN tvarvc AS tvarvc
*        ON icms~taxlaw EQ tvarvc~low
*      INTO wa_i_bapi-taxlw1
*     WHERE icms~taxsit EQ wa_docmn-value
*       AND tvarvc~name EQ 'ZHMS_J1B1N_ICMS'.
*
** Direitos fiscais - IPI
*    CLEAR wa_docmn.
*
*    READ TABLE it_docmn INTO wa_docmn WITH KEY chave = wa_outtab-chave
*                                               mneum = 'CSTIPI'
*                                               dcitm = wa_outtab-nf_itm
*                                               BINARY SEARCH.
*
*    SELECT SINGLE taxlaw
*      FROM j_1batl2 AS ipi
*     INNER JOIN tvarvc AS tvarvc
*        ON ipi~taxlaw EQ tvarvc~low
*      INTO wa_i_bapi-taxlw2
*     WHERE ipi~taxsitout EQ wa_docmn-value
*       AND tvarvc~name EQ 'ZHMS_J1B1N_IPI'.
*
** Direitos fiscais - COFINS
*    CLEAR wa_docmn.
*
*    READ TABLE it_docmn INTO wa_docmn WITH KEY chave = wa_outtab-chave
*                                               mneum = 'CSTCOFINS'
*                                               dcitm = wa_outtab-nf_itm
*                                               BINARY SEARCH.
*
*    SELECT SINGLE taxlaw
*      FROM j_1batl4a AS cofins
*     INNER JOIN tvarvc AS tvarvc
*        ON cofins~taxlaw EQ tvarvc~low
*      INTO wa_i_bapi-taxlw4
*     WHERE cofins~taxsitout EQ wa_docmn-value
*       AND tvarvc~name EQ 'ZHMS_J1B1N_COFINS'.
*
** Direitos fiscais - PIS
*    CLEAR wa_docmn.
*
*    READ TABLE it_docmn INTO wa_docmn WITH KEY chave = wa_outtab-chave
*                                               mneum = 'CSTPIS'
*                                               dcitm = wa_outtab-nf_itm
*                                               BINARY SEARCH.
*
*    SELECT SINGLE taxlaw
*      FROM j_1batl5 AS pis
*     INNER JOIN tvarvc AS tvarvc
*        ON pis~taxlaw EQ tvarvc~low
*      INTO wa_i_bapi-taxlw5
*     WHERE pis~taxsitout EQ wa_docmn-value
*       AND tvarvc~name EQ 'ZHMS_J1B1N_PIS'.
*
**----------------------------------------------------------------------*
** Dados da aba de impostos (ICMS)                                                        *
**----------------------------------------------------------------------*
*    wa_i_bapi_tax-chave = wa_outtab-chave.
*
*    wa_i_bapi_tax-dcitm = wa_outtab-nf_itm.
*
** Nº item
**    wa_i_bapi_tax-itmnum = '10'.              "RCP - 31/08/2018
*    wa_i_bapi_tax-itmnum = wa_i_bapi-itmnum.   "RCP - 31/08/2018
*
** Código do imposto
*    CASE wa_i_bapi-matuse.
*
*      WHEN '0' OR '3'.
*        wa_i_bapi_tax-taxtyp = 'ICM0'.
*
*      WHEN '1' OR '2'.
*        wa_i_bapi_tax-taxtyp = 'ICM1'.
*
*    ENDCASE.
*
** Montante
*    CLEAR wa_docmn.
*
*    READ TABLE it_docmn INTO wa_docmn WITH KEY chave = wa_outtab-chave
*                                               mneum = 'VPROD'
*                                               dcitm = wa_outtab-nf_itm
*                                               BINARY SEARCH.
*
*    wa_i_bapi_tax-base = wa_docmn-value.
*
** Outras bases
*    wa_i_bapi_tax-othbas = wa_docmn-value.
*
** Taxa de imposto
*    CLEAR wa_docmn.
*
*    READ TABLE it_docmn INTO wa_docmn WITH KEY chave = wa_outtab-chave
*                                               mneum = 'PICMS'
*                                               dcitm = wa_outtab-nf_itm
*                                               BINARY SEARCH.
*
*    wa_i_bapi_tax-rate = wa_docmn-value.
*
*    APPEND: wa_h_bapi     TO it_h_bapi,
*            wa_i_bapi     TO it_i_bapi,
*            wa_i_bapi_tax TO it_i_bapi_tax.
*
*    CLEAR wa_notas.
*
*    READ TABLE it_docmn INTO wa_docmn WITH KEY chave = wa_outtab-chave
*                                               mneum = 'NNF'
*                                               BINARY SEARCH.
*
*    wa_notas-chave      = wa_outtab-chave.
*    wa_notas-dcitm      = wa_outtab-nf_itm.
*    wa_notas-nf_entrada = wa_docmn-value.
*    wa_notas-bukrs      = wa_h_bapi-bukrs.
*    wa_notas-docdat     = wa_h_bapi-docdat.
*    wa_notas-cli_forn   = wa_h_bapi-parid.
*    wa_notas-material   = wa_i_bapi-matnr.
*    wa_notas-qtd_nf     = wa_i_bapi-menge.
*    wa_notas-werks      = wa_i_bapi-werks.
*    wa_notas-ncm        = wa_i_bapi-nbm.
*    wa_notas-cfop       = wa_i_bapi-cfop_10.
*    wa_notas-netpr      = wa_i_bapi-netpr.
*    wa_notas-icms       = wa_i_bapi_tax-taxtyp.
*    wa_notas-base       = wa_i_bapi_tax-base.
*    wa_notas-rate       = wa_i_bapi_tax-rate.
*
*    SELECT SINGLE name1
*      FROM lfa1
*      INTO wa_notas-descr_forn
*     WHERE lifnr EQ wa_h_bapi-parid.
*
*    APPEND wa_notas TO it_notas.
*
*    CLEAR: wa_notas,
*           wa_h_bapi,
*           wa_i_bapi,
*           wa_i_bapi_tax.
*
*  ENDLOOP.
*
** Chama tela de dados que serão inseridos na NF a ser criada
*  CALL SCREEN 300 STARTING AT 12 3
*                  ENDING AT 180 18.
*
*ENDFORM.                    " F_GERA_NOTA

**&---------------------------------------------------------------------*
**&      Form  F_DETALHES
**&---------------------------------------------------------------------*
*FORM f_detalhes USING p_row_id
*                      p_column_id.
*
*  READ TABLE it_outtab INTO wa_outtab INDEX p_row_id.
*
*  REFRESH: rg_nf_det,
*           it_detalhes,
*           it_det,
*           it_det_char.
*
** Seleciona as notas de saída
*  SELECT chave
*         seqnr
*         mneum
*         dcitm
*         value
*    FROM zhms_tb_docmn
*    INTO TABLE it_doc_det
*   WHERE chave EQ wa_outtab-chave
*     AND mneum IN (c_nfcli,c_nfforn)
*     AND dcitm EQ wa_outtab-nf_itm.
*
*  LOOP AT it_doc_det INTO wa_docmn.
*
*    wa_nf_det-sign   = c_sign.
*    wa_nf_det-option = c_option.
*    wa_nf_det-low    = wa_docmn-value.
*
*    APPEND wa_nf_det TO rg_nf_det.
*
*    CLEAR wa_nf_det.
*
*  ENDLOOP.
*
*  REFRESH it_doclin.
*
** Seleciona os dados das notas de saída
*  IF NOT rg_nf_det IS INITIAL.
*
*    SELECT h~docnum
*           h~nfenum
*           h~docdat
*           h~parvw
*           h~parid
*           i~matnr
*           i~menge
*           h~nfenum
*      INTO TABLE it_doclin
*      FROM j_1bnfdoc AS h
*     INNER JOIN j_1bnflin AS i
*        ON h~docnum EQ i~docnum
*     WHERE h~docnum IN rg_nf_det.
*
*  ENDIF.
*
*  LOOP AT it_doclin INTO wa_doclin.
*
*    wa_detalhes-nf_saida   = wa_doclin-nfenum.
*    wa_detalhes-docnum_sai = wa_doclin-docnum.
*    wa_detalhes-material   = wa_doclin-matnr.
*    wa_detalhes-qtd_nf_sai = wa_doclin-menge.
*    wa_detalhes-cli_forn   = wa_doclin-parid.
*
*    CONCATENATE wa_doclin-docdat+6(2)
*                wa_doclin-docdat+4(2)
*                wa_doclin-docdat(4)
*           INTO wa_detalhes-dt_emi_sai SEPARATED BY '.'.
*
** Se for cliente
*    IF wa_doclin-parvw EQ c_ag.
*
*      SELECT SINGLE name1
*        FROM kna1
*        INTO wa_detalhes-descr_forn
*       WHERE kunnr EQ wa_doclin-parid.
*
*      wa_detalhes-tp_nf = text-c01. " Envio à cliente
*
*      wa_detalhes-status_dias = c_na.
*
** Se for fornecedor
*    ELSEIF wa_doclin-parvw EQ c_lf.
*
*      SELECT SINGLE name1
*        FROM lfa1
*        INTO wa_detalhes-descr_forn
*       WHERE lifnr EQ wa_doclin-parid.
*
*      wa_detalhes-tp_nf = text-c02. " Envio à fornecedor
*
*      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*        EXPORTING
*          input  = wa_doclin-nfe_c
*        IMPORTING
*          output = wa_doclin-nfe_c.
*
** Seleciona nota de escrituração (se houver)
*      SELECT SINGLE chave
*                    seqnr
*                    mneum
*                    dcitm
*                    value
*        FROM zhms_tb_docmn
*        INTO wa_docmn
*       WHERE mneum EQ 'REFERENCE'
*         AND value EQ wa_doclin-nfe_c.
*
*      IF sy-subrc IS INITIAL.
*
*        SELECT SINGLE value
*          FROM zhms_tb_docmn
*          INTO wa_detalhes-nf_escr_dev
*         WHERE chave EQ wa_docmn-chave
*           AND mneum EQ 'NNF'.
*
** Quantidade devolvida pelo fornecedor
*        wa_detalhes-qtd_dev_forn = wa_detalhes-qtd_nf_sai.
*
*        SELECT SINGLE value
*          FROM zhms_tb_docmn
*          INTO wa_detalhes-doc_escr_dev
*         WHERE chave EQ wa_docmn-chave
*           AND mneum EQ 'MATDOC'.
*
*      ENDIF.
*
** Verifica quantidade devolvida e calcula dias
*      IF wa_detalhes-qtd_dev_forn LT wa_detalhes-qtd_nf_sai.
*
*        wa_detalhes-dias_forn = sy-datum - wa_doclin-docdat.
*
*      ELSE.
*
*        wa_detalhes-dias_forn = 0.
*
*      ENDIF.
*
** Atualiza status
*      IF wa_detalhes-dias_forn LE 100.
*
*        wa_detalhes-status_dias = c_100.
*
*      ELSEIF wa_detalhes-dias_forn GT 100 AND wa_detalhes-dias_forn LE 180.
*
*        wa_detalhes-status_dias = c_100_180.
*
*      ELSEIF wa_detalhes-dias_forn GT 180.
*
*        wa_detalhes-status_dias = c_180.
*
*      ENDIF.
*
*    ENDIF.
*
*    APPEND wa_detalhes TO it_detalhes.
*
** ALV tree -> se os valores não forem CHAR, fica com "sujeira" na linha da pasta
*    MOVE-CORRESPONDING wa_detalhes TO wa_det_char.
*
*    SHIFT: wa_det_char-nf_saida     LEFT DELETING LEADING c_zero,
*           wa_det_char-docnum_sai   LEFT DELETING LEADING c_zero,
*           wa_det_char-nf_escr_dev  LEFT DELETING LEADING c_zero,
*           wa_det_char-doc_escr_dev LEFT DELETING LEADING c_zero,
*           wa_det_char-material     LEFT DELETING LEADING c_zero.
*
*    APPEND wa_det_char TO it_det_char.
*
*    CLEAR wa_detalhes.
*
*  ENDLOOP.
*
** Instancia o objeto apenas uma vez
*  IF go_cont_tree IS INITIAL.
*
*    CREATE OBJECT go_cont_tree
*      EXPORTING
*        container_name              = 'ALVDETALHE'
*      EXCEPTIONS
*        cntl_error                  = 1
*        cntl_system_error           = 2
*        create_error                = 3
*        lifetime_error              = 4
*        lifetime_dynpro_dynpro_link = 5.
*
*    CREATE OBJECT go_tree
*      EXPORTING
*        parent                      = go_cont_tree
*        node_selection_mode         = cl_gui_column_tree=>node_sel_mode_single
*        item_selection              = abap_true
*        no_html_header              = abap_true
*        no_toolbar                  = abap_true
*      EXCEPTIONS
*        cntl_error                  = 1
*        cntl_system_error           = 2
*        create_error                = 3
*        lifetime_error              = 4
*        illegal_node_selection_mode = 5
*        failed                      = 6
*        illegal_column_name         = 7.
*
** Define o label do primeiro campo do tree
*    PERFORM f_header_tree CHANGING gv_header_tree.
*
** Monta catálogo de campos da área de detalhes
*    PERFORM f_fcat_det USING:
*            'DOCNUM_SAI'     text-g01   space       16    abap_true,
*            'NF_ESCR_DEV'    text-g02   space       20    space,
*            'DOC_ESCR_DEV'   text-g03   space       20    space,
*            'DT_EMI_SAI'     text-g04   space       22    space,
*            'MATERIAL'       text-g05   space       16    space,
*            'QTD_NF_SAI'     text-g06   space       20    space,
*            'CLI_FORN'       text-g07   space       24    space,
*            'DESCR_FORN'     text-g08   space       44    space,
*            'QTD_DEV_FORN'   text-g09   space       20    space,
*            'DIAS_FORN'      text-g10   space       18    space,
*            'STATUS_DIAS'    text-g11   abap_true   15    space.
*
** Cria tree -> tabela de dados deve ser passada vazia!
*    CALL METHOD go_tree->set_table_for_first_display
*      EXPORTING
*        is_hierarchy_header = gv_header_tree
*      CHANGING
*        it_outtab           = it_det
*        it_fieldcatalog     = it_fcat2.
*
** Busca os eventos disponíveis para ALV
*    CALL METHOD go_tree->get_registered_events
*      IMPORTING
*        events = it_evt
*      EXCEPTIONS
*        OTHERS = 0.
*
** Insere o evento de "hotspot" (link click)
*    wa_evt-eventid = cl_gui_column_tree=>eventid_link_click.
*    APPEND wa_evt TO it_evt.
*
** Registra o evento "hotspot" (link click)
*    CALL METHOD go_tree->set_registered_events
*      EXPORTING
*        events = it_evt
*      EXCEPTIONS
*        OTHERS = 0.
*
** Instancia o objeto para chamar a J1B3N
*    CREATE OBJECT go_event_tree.
*
** Chama o método para o clique no DOCNUM da NF
*    SET HANDLER go_event_tree->link_click FOR go_tree.
*
*  ELSE.
*
** Reinicia os nós para nova hierarquia
*    CALL METHOD go_tree->delete_all_nodes.
*
*  ENDIF.
*
** Cria os nós (pastas)
*  PERFORM f_cria_nos.
*
** Envia os dados da tabela interna para o tree
*  CALL METHOD go_tree->frontend_update.
*
*ENDFORM.                    " F_DETALHES

**&---------------------------------------------------------------------*
**&      Form  F_FCAT_DET
**&---------------------------------------------------------------------*
*FORM f_fcat_det USING p_nome
*                      p_texto
*                      p_icon
*                      p_len
*                      p_hotspot.
*
*  CLEAR wa_fcat2.
*
*  wa_fcat2-fieldname  = p_nome.
*  wa_fcat2-colddictxt = 'L'.
*  wa_fcat2-scrtext_l  = p_texto.
*  wa_fcat2-outputlen  = p_len.
*  wa_fcat2-icon       = p_icon.
*  wa_fcat2-hotspot    = p_hotspot.
*
*  APPEND wa_fcat2 TO it_fcat2.
*
*ENDFORM.                    " F_FCAT_DET
*
**&---------------------------------------------------------------------*
**       Form  F_HEADER_TREE
**&---------------------------------------------------------------------*
*FORM f_header_tree CHANGING p_hierarchy_header TYPE treev_hhdr.
*
*  p_hierarchy_header-heading = text-t01.
*  p_hierarchy_header-tooltip = text-t01.
*  p_hierarchy_header-width   = 30.
*
*ENDFORM.                    " F_HEADER_TREE
*
**&---------------------------------------------------------------------*
**&      Form  F_CRIA_NOS
**&---------------------------------------------------------------------*
*FORM f_cria_nos.
*
*  DATA: lv_no_atual    TYPE lvc_nkey,
*        lv_no_superior TYPE lvc_nkey,
*        lv_no_texto    TYPE lvc_value.
*
*  SORT it_det_char BY tp_nf.
*
*  CLEAR gv_tp_nf.
*
*  LOOP AT it_det_char INTO wa_det_char.
*
** Se o tipo da NF for diferente -> cria outro nó
*    IF wa_det_char-tp_nf NE gv_tp_nf.
*
*      CLEAR: lv_no_superior,
*             wa_det.
*
** Texto do nó (pasta)
*      lv_no_texto = wa_det_char-tp_nf.
*
*      CALL METHOD go_tree->add_node
*        EXPORTING
*          i_relat_node_key = lv_no_superior
*          i_relationship   = cl_gui_column_tree=>relat_last_child
*          is_outtab_line   = wa_det
*          i_node_text      = lv_no_texto
*        IMPORTING
*          e_new_node_key   = lv_no_atual.
*
*      lv_no_superior = lv_no_atual.
*
*    ENDIF.
*
*    wa_det = wa_det_char.
*
** Texto do nó (pasta)
*    lv_no_texto = wa_det_char-nf_saida.
*
*    CALL METHOD go_tree->add_node
*      EXPORTING
*        i_relat_node_key = lv_no_superior
*        i_relationship   = cl_gui_column_tree=>relat_last_child
*        is_outtab_line   = wa_det
*        i_node_text      = lv_no_texto
*      IMPORTING
*        e_new_node_key   = lv_no_atual.
*
*    gv_tp_nf = wa_det_char-tp_nf.
*
*  ENDLOOP.
*
*ENDFORM.                    " F_CRIA_NOS
*
**&---------------------------------------------------------------------*
**&      Form  F_MONTA_FCAT3
**&---------------------------------------------------------------------*
*FORM f_monta_fcat3 USING p_nome
*                         p_texto
*                         p_len.
*
*  CLEAR wa_fcat3.
*
*  wa_fcat3-fieldname = p_nome.
*  wa_fcat3-reptext   = p_texto.
*  wa_fcat3-outputlen = p_len.
*
*  APPEND wa_fcat3 TO it_fcat3.
*
*ENDFORM.                    " F_MONTA_FCAT3
*
**&---------------------------------------------------------------------*
**&      Form  F_MONTA_LEGENDA
**&---------------------------------------------------------------------*
*FORM f_monta_legenda  USING  p_icone
*                             p_descr.
*
*  CLEAR wa_leg.
*
*  wa_leg-icone = p_icone.
*  wa_leg-descr = p_descr.
*
*  APPEND wa_leg TO it_leg.
*
*ENDFORM.                    " F_MONTA_LEGENDA

**&---------------------------------------------------------------------*
**&      Module  STATUS_0300  OUTPUT
**&---------------------------------------------------------------------*
*MODULE status_0300 OUTPUT.
*
*  SET PF-STATUS 'STATUS_300' EXCLUDING it_fcode.
*  SET TITLEBAR 'TITLE_300'.
*
*  CREATE OBJECT go_notas
*    EXPORTING
*      container_name              = 'ALVNOTAS'
*    EXCEPTIONS
*      cntl_error                  = 1
*      cntl_system_error           = 2
*      create_error                = 3
*      lifetime_error              = 4
*      lifetime_dynpro_dynpro_link = 5
*      OTHERS                      = 6.
*
*  IF go_alv_notas IS INITIAL.
*
*    CREATE OBJECT go_alv_notas
*      EXPORTING
*        i_parent          = go_notas
*      EXCEPTIONS
*        error_cntl_create = 1
*        error_cntl_init   = 2
*        error_cntl_link   = 3
*        error_dp_create   = 4
*        OTHERS            = 5.
*
*  ENDIF.
*
** Reinicia a tabela para cada nova seleção de NFs
*  REFRESH it_fcat4.
*
*  PERFORM f_monta_fcat4 USING:
*                  'NF'           text-n01   space,
*                  'NF_ENTRADA'   text-n02   space,
*                  'DCITM'        text-n03   space,
*                  'BUKRS'        text-n04   space,
*                  'DOCDAT'       text-n05   space,
*                  'CLI_FORN'     text-n06   space,
*                  'DESCR_FORN'   text-n07   space,
*                  'MATERIAL'     text-n08   space,
*                  'QTD_NF'       text-n09   abap_true,
*                  'WERKS'        text-n10   space,
*                  'NCM'          text-n11   space,
*                  'CFOP'         text-n12   space,
*                  'NETPR'        text-n13   space,
*                  'ICMS'         text-n14   space,
*                  'BASE'         text-n15   space,
*                  'RATE'         text-n16   space,
*                  'MENSAGEM'     text-n17   space.
*
*  wa_layout4-cwidth_opt = abap_true.     " Otimizar colunas
*  wa_layout4-zebra      = abap_true.     " Zebra
*  wa_layout4-no_toolbar = abap_true.     " Sem a barra padrão do ALV
*  wa_layout4-no_rowmark = abap_true.     " Sem marcador de linhas
*  wa_layout4-ctab_fname = 'CELLCOLOR'.   " Esquema de cores
*  wa_layout4-stylefname = 'FIELD_STYLE'. " Campo que receberá estilo
*
*  CALL METHOD go_alv_notas->set_table_for_first_display
*    EXPORTING
*      is_layout                     = wa_layout4
*    CHANGING
*      it_outtab                     = it_notas[]
*      it_fieldcatalog               = it_fcat4[]
*    EXCEPTIONS
*      invalid_parameter_combination = 1
*      program_error                 = 2
*      too_many_lines                = 3
*      OTHERS                        = 4.
*
*ENDMODULE.                 " STATUS_0300  OUTPUT
*
**&---------------------------------------------------------------------*
**&      Form  F_MONTA_FCAT4
**&---------------------------------------------------------------------*
*FORM f_monta_fcat4  USING  p_nome
*                           p_texto
*                           p_edit.
*
*  CLEAR wa_fcat4.
*
*  wa_fcat4-fieldname = p_nome.
*  wa_fcat4-reptext   = p_texto.
*  wa_fcat4-edit      = p_edit.
*  wa_fcat4-col_opt   = abap_true.
*
*  APPEND wa_fcat4 TO it_fcat4.
*
*ENDFORM.                    " F_MONTA_FCAT4
*
**&---------------------------------------------------------------------*
**&      Module  USER_COMMAND_0300  INPUT
**&---------------------------------------------------------------------*
*MODULE user_command_0300 INPUT.
*
*  REFRESH it_fcode.
*
*  CASE sy-ucomm.
*
*    WHEN c_ok.
*
*      PERFORM f_gera_notas.
*
*    WHEN c_canc.
*
*      LEAVE TO SCREEN 0.
*
*  ENDCASE.
*
*ENDMODULE.                 " USER_COMMAND_0300  INPUT
*
**&---------------------------------------------------------------------*
**&      Form  F_GERA_NOTAS
**&---------------------------------------------------------------------*
*FORM f_gera_notas .
*
*  DATA: lv_nf_itm TYPE char10.
*
*
*
*  CALL FUNCTION 'POPUP_TO_CONFIRM'
*    EXPORTING
*      titlebar              = text-q01
*      text_question         = text-q02
*      text_button_1         = text-b01
*      icon_button_1         = 'ICON_CHECKED'
*      text_button_2         = text-b02
*      icon_button_2         = 'ICON_INCOMPLETE'
*      default_button        = '1'
*      display_cancel_button = space
*    IMPORTING
*      answer                = gv_resp
*    EXCEPTIONS
*      text_not_found        = 1
*      OTHERS                = 2.
*
*  IF gv_resp EQ '1'.
*
** Envia para tabela auxiliar
*    it_notas_aux[] = it_notas[].
*
*    CALL METHOD go_alv_notas->check_changed_data.
*
*    CLEAR wa_header.
*
*    REFRESH: it_item, it_item_tax.
*
*    LOOP AT it_notas INTO wa_notas.
*
*      gv_tabix = sy-tabix.
*
*      READ TABLE it_notas_aux INTO wa_notas_aux INDEX gv_tabix.
*
*      IF wa_notas-qtd_nf GT wa_notas_aux-qtd_nf OR wa_notas-qtd_nf IS INITIAL.
*
*        CLEAR wa_notas-nf.
*
** Cor vermelho no campo do número da nota
*        wa_color-color-col = 6.
*        wa_color-color-int = 1.
*        wa_color-color-inv = 0.
*        wa_color-fname     = c_nf.
*
*        INSERT wa_color INTO TABLE wa_notas-cellcolor.
*
*        wa_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
*
*        APPEND wa_stylerow TO wa_notas-field_style.
*
*        wa_notas-mensagem = text-v01. " Quantidade não permitida
*
*        MODIFY it_notas FROM wa_notas INDEX gv_tabix.
*
*        CONTINUE.
*
*      ENDIF.
*
*      READ TABLE it_h_bapi INTO wa_h_bapi WITH KEY chave = wa_notas-chave.
*
*      MOVE-CORRESPONDING wa_h_bapi TO wa_header.
*
*      LOOP AT it_i_bapi INTO wa_i_bapi WHERE chave EQ wa_notas-chave
*                                         AND dcitm EQ wa_notas-dcitm.
*
*        MOVE-CORRESPONDING wa_i_bapi TO wa_item.
*
*        wa_item-menge = wa_notas-qtd_nf.
*
*        APPEND wa_item TO it_item.
*
*      ENDLOOP.
*
*      LOOP AT it_i_bapi_tax INTO wa_i_bapi_tax WHERE chave EQ wa_notas-chave
*                                                 AND dcitm EQ wa_notas-dcitm.
*
*        MOVE-CORRESPONDING wa_i_bapi_tax TO wa_item_tax.
*
*        APPEND wa_item_tax TO it_item_tax.
*
*      ENDLOOP.
*
*    ENDLOOP.   "RCP - 31/08/2018
*
** Cria a nota fiscal
*    CALL FUNCTION 'BAPI_J_1B_NF_CREATEFROMDATA'
*      EXPORTING
*        obj_header   = wa_header
*      IMPORTING
*        e_docnum     = gv_docnum
*      TABLES
*        obj_item     = it_item
*        obj_item_tax = it_item_tax
*        return       = it_return.
*
*    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
*
*    IF NOT gv_docnum IS INITIAL.
*
*      LOOP AT it_outtab INTO wa_outtab WHERE mark EQ abap_true.  "RCP - 31/08/2018
*
*        REFRESH: it_seqnr.   "RCP - 31/08/2018
*        SELECT seqnr
*          FROM zhms_tb_docmn
*          INTO TABLE it_seqnr
*         WHERE chave EQ wa_outtab-chave.
*
*        LOOP AT it_seqnr INTO wa_seqnr.
*
*          CONDENSE wa_seqnr-seqnr NO-GAPS.
*
*          gv_times = strlen( wa_seqnr-seqnr ).
*
*          gv_times = 5 - gv_times.
*
*          DO gv_times TIMES.
*
*            CONCATENATE '0' wa_seqnr-seqnr INTO wa_seqnr-seqnr.
*
*          ENDDO.
*
*          MODIFY it_seqnr FROM wa_seqnr INDEX sy-tabix.
*
*        ENDLOOP.
*
*        SORT it_seqnr DESCENDING.
*
*        READ TABLE it_seqnr INTO wa_seqnr INDEX 1.
*
*        gv_seqnr = wa_seqnr-seqnr + 1.
*
*        zhms_tb_docmn-chave = wa_outtab-chave.
*        zhms_tb_docmn-seqnr = gv_seqnr.
*
*
*        CLEAR lv_nf_itm.
*        CASE wa_header-parvw.
*
** Cliente (atualiza quantidade pendente e quantidade devolvida)
*          WHEN c_ag.
*            UNPACK wa_outtab-material TO wa_outtab-material.
*
*            lv_nf_itm = wa_outtab-nf_itm.
*            wa_outtab-nf_itm = wa_outtab-nf_itm * 10.
*            READ TABLE it_item INTO wa_item
*                               WITH KEY itmnum = wa_outtab-nf_itm
*                                        matnr = wa_outtab-material.  "RCP - 31/08/2018
*            IF sy-subrc IS INITIAL.  "RCP - 31/08/2018
*              zhms_tb_docmn-mneum = c_nfcli.
*              wa_outtab-qtd_pend = wa_outtab-qtd_pend - wa_item-menge.
*              wa_outtab-qtd_dev  = wa_outtab-qtd_dev  + wa_item-menge.
*            ENDIF.    "RCP - 31/08/2018
*            PACK wa_outtab-material TO wa_outtab-material.
*            CONDENSE wa_outtab-material.
*            wa_outtab-nf_itm = lv_nf_itm.
*
** Fornecedor (atualiza quantidade com fornecedor)
*          WHEN c_lf.
*            UNPACK wa_outtab-material TO wa_outtab-material.
*            lv_nf_itm = wa_outtab-nf_itm.
*            wa_outtab-nf_itm = wa_outtab-nf_itm * 10.
*            READ TABLE it_item INTO wa_item
*                               WITH KEY itmnum = wa_outtab-nf_itm
*                                        matnr = wa_outtab-material.  "RCP - 31/08/2018
*            IF sy-subrc IS INITIAL.  "RCP - 31/08/2018
*              zhms_tb_docmn-mneum = c_nfforn.
*              wa_outtab-qtd_forn  = wa_outtab-qtd_forn + wa_item-menge.
*            ENDIF.    "RCP - 31/08/2018
*            PACK wa_outtab-material TO wa_outtab-material.
*            CONDENSE wa_outtab-material.
*            wa_outtab-nf_itm = lv_nf_itm.
*
*        ENDCASE.
*
*        zhms_tb_docmn-dcitm = wa_outtab-nf_itm.
*
** Docnum da nota gerada
*        zhms_tb_docmn-value = gv_docnum.
*
** Atualiza quantidade em "estoque"
*        wa_outtab-qtd_estoque = wa_outtab-qtd_pend - wa_outtab-qtd_forn.
*
** Atualiza DOCMN com a nota gerada
*        INSERT zhms_tb_docmn FROM zhms_tb_docmn.
*
*        COMMIT WORK.
*
** Se a quantidade em estoque for totalmente consumida -> fecha o checkbox
*        IF wa_outtab-qtd_estoque IS INITIAL.
*
*          CLEAR wa_outtab-mark.
*
*          wa_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
*
*          APPEND wa_stylerow TO wa_outtab-field_style.
*
*        ENDIF.
*
** Se não há nenhuma quantidade pendente -> nota integralmente devolvida
*        IF wa_outtab-qtd_pend IS INITIAL.
*
*          wa_outtab-dias   = 0.
*
*          wa_outtab-status = c_devol.
*
*        ENDIF.
*
*        READ TABLE it_outtab WITH KEY nf_cli = wa_outtab-nf_cli
*                                      nf_itm = wa_outtab-nf_itm
*                                      TRANSPORTING NO FIELDS.
*
*        MODIFY it_outtab FROM wa_outtab INDEX sy-tabix.
*
**      ENDIF.  "RCP - 31/08/2018
*
**        LOOP AT it_notas INTO wa_notas.  "RCP - 31/08/2018
**          gv_tabix = sy-tabix.
**
**          wa_notas-nf = gv_docnum.
**
*** Cor verde no campo do número da nota
**          wa_color-color-col = 5.
**          wa_color-color-int = 1.
**          wa_color-color-inv = 0.
**          wa_color-fname     = c_nf.
**
**          INSERT wa_color INTO TABLE wa_notas-cellcolor.
**
*** Fecha o campo de quantidade para edição
**          wa_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
**
**          APPEND wa_stylerow TO wa_notas-field_style.
**
**          wa_notas-mensagem = text-v02. " Documento criado com sucesso
**
**          MODIFY it_notas FROM wa_notas INDEX gv_tabix.
**
**        ENDLOOP.  "RCP - 31/08/2018
*
*      ENDLOOP.  "RCP - 31/08/2018
*
*      LOOP AT it_notas INTO wa_notas.  "RCP - 31/08/2018
*        gv_tabix = sy-tabix.
*
*        wa_notas-nf = gv_docnum.
*
** Cor verde no campo do número da nota
*        wa_color-color-col = 5.
*        wa_color-color-int = 1.
*        wa_color-color-inv = 0.
*        wa_color-fname     = c_nf.
*
*        INSERT wa_color INTO TABLE wa_notas-cellcolor.
*
** Fecha o campo de quantidade para edição
*        wa_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
*
*        APPEND wa_stylerow TO wa_notas-field_style.
*
*        wa_notas-mensagem = text-v02. " Documento criado com sucesso
*
*        MODIFY it_notas FROM wa_notas INDEX gv_tabix.
*
*      ENDLOOP.  "RCP - 31/08/2018
*
*    ENDIF.  "RCP - 31/08/2018
*
** Atualiza o tree de detalhes
*    CALL METHOD go_alv_notas->refresh_table_display.
*
** Atualiza a parte de cima do cockpit
*    CALL METHOD go_alv->refresh_table_display.
*
** Desabilita o botão de gerar notas no "popup"
*    APPEND c_ok TO it_fcode.
*
*  ENDIF.
*
*ENDFORM.                    " F_GERA_NOTAS

*&-------------------------------------------------------------------
*& Form f_carrega_imagem
*&-------------------------------------------------------------------
FORM f_carrega_imagem.

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
        type     = 'IMAGE'
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

ENDFORM.                    "f_carrega_imagem

*&---------------------------------------------------------------------*
*&      Form  F_MONTA_HEADER
*&---------------------------------------------------------------------*
FORM f_monta_header .

  DATA: vl_controle.
  FIELD-SYMBOLS <fs_active> TYPE ty_active.
  FIELD-SYMBOLS <fs_outtab> TYPE ty_outtab.

  REFRESH it_docmn.
  REFRESH it_doclin.
  REFRESH it_cabdoc.
  REFRESH it_cfop_180.
  REFRESH it_docmn_ref.

  SELECT * FROM zhms_tb_cfop180 INTO TABLE it_cfop_180.
  IF it_cfop_180[] IS NOT INITIAL.

* Seleciona dados das notas de saída
    SELECT h~docnum
           h~nfenum
           h~docdat
           h~bukrs
           h~branch
           h~parvw
           h~parid
           h~brgew
           i~itmnum
           i~matnr
           i~maktx
           i~menge
      INTO TABLE it_doclin
      FROM j_1bnfdoc AS h
     INNER JOIN j_1bnflin AS i
        ON h~docnum EQ i~docnum
      FOR ALL ENTRIES IN it_cfop_180
     WHERE h~direct EQ '2'
       AND h~docdat IN s_lncdt
       AND h~model  EQ '55'
       AND h~docdat IN s_lncdt
       AND h~bukrs  IN s_bukrs
       AND h~branch IN s_branch
       AND h~nfenum IN s_docnr
       AND h~parid  IN s_parid
       AND i~cfop   EQ it_cfop_180-cfop.

    IF sy-subrc EQ 0.

      SELECT docnum regio nfyear nfmonth stcd1
             model  serie nfnum9 docnum9 cdv
        FROM j_1bnfe_active
        INTO TABLE it_active
        FOR ALL ENTRIES IN it_doclin
        WHERE docnum EQ it_doclin-docnum.

      UNASSIGN <fs_active>.
      LOOP AT it_active ASSIGNING <fs_active>.
        CONCATENATE <fs_active>-regio
                    <fs_active>-nfyear
                    <fs_active>-nfmonth
                    <fs_active>-stcd1
                    <fs_active>-model
                    <fs_active>-serie
                    <fs_active>-nfnum9
                    <fs_active>-docnum9
                    <fs_active>-cdv
               INTO <fs_active>-value.
      ENDLOOP.

      SELECT chave
             seqnr
             mneum
             dcitm
             value
        FROM zhms_tb_docmn
        INTO TABLE it_docmn_ref
         FOR ALL ENTRIES IN it_active
       WHERE mneum EQ 'REFNFE'
         AND value EQ it_active-value.

      IF sy-subrc EQ 0.

        SELECT chave
               seqnr
               mneum
               dcitm
               value
          FROM zhms_tb_docmn
          INTO TABLE it_docmn
           FOR ALL ENTRIES IN it_docmn_ref
         WHERE chave EQ it_docmn_ref-chave.

        SELECT *
          FROM zhms_tb_cabdoc
          INTO TABLE it_cabdoc
          FOR ALL ENTRIES IN it_docmn_ref
         WHERE chave EQ it_docmn_ref-chave.

      ENDIF.

    ELSE.

      MESSAGE s398(00) WITH 'CFOP não encontrado' DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.

    ENDIF.

  ENDIF.
*--------------------------------------------------------------------*

  SORT it_docmn BY chave mneum dcitm.
  REFRESH it_doclin_aux.

  IF it_doclin[] IS NOT INITIAL.
    it_doclin_aux[] = it_doclin[].

    CLEAR: wa_doclin, wa_doclin_aux, vl_controle.
    LOOP AT it_doclin INTO wa_doclin.

* Dias
      wa_outtab-dias = sy-datum - wa_doclin-docdat.
      IF wa_outtab-dias LE 100.
        wa_outtab-status = c_100. "*Verde
      ELSEIF wa_outtab-dias GT 100 AND wa_outtab-dias LE 180.
        wa_outtab-status = c_100_180. "*Amarelo
      ELSE.
        wa_outtab-status = c_180. "*Vermelho
      ENDIF.

      CLEAR wa_doclin_aux.
      LOOP AT it_doclin_aux INTO wa_doclin_aux WHERE docnum = wa_doclin-docnum.

*        wa_outtab-status  = c_devol. "Status
        wa_outtab-bukrs   = wa_doclin-bukrs.  "Empresa
        wa_outtab-nf_escr = wa_doclin-docnum. "Num Documento SAP
        wa_outtab-nfenum  = wa_doclin-nfenum. "NF-e Saída
        wa_outtab-dt_emi  = wa_doclin-docdat. "Data de Emissão
        wa_outtab-qtd_nf   = wa_doclin-brgew.  "Quantidade da NF brgew

        wa_outtab-nf_itm    = wa_doclin_aux-itmnum. "Item
        wa_outtab-material  = wa_doclin_aux-matnr.  "Material
        wa_outtab-descricao = wa_doclin_aux-maktx.  "Descrição Mat.

        APPEND wa_outtab TO it_outtab.
        CLEAR: wa_doclin_aux, vl_controle.
      ENDLOOP.

      CLEAR wa_active.
      READ TABLE it_active INTO wa_active WITH KEY docnum = wa_doclin-docnum.

***Campos das NFs de Entrada
      CLEAR wa_docmn.
      LOOP AT it_docmn_ref INTO wa_docmn WHERE value = wa_active-value.

        CLEAR: wa_cabdoc.
        READ TABLE it_cabdoc INTO wa_cabdoc WITH KEY chave = wa_docmn-chave
                                                     parid = wa_doclin-parid.

        IF sy-subrc EQ 0.
          READ TABLE it_docmn INTO wa_docmn WITH KEY chave = wa_cabdoc-chave
                                                     mneum = 'MATDOC'.
          IF sy-subrc EQ 0.
            CLEAR wa_docmn.
            READ TABLE it_docmn INTO wa_docmn WITH KEY chave = wa_cabdoc-chave
                                                       mneum = 'QCOM'.
            IF sy-subrc EQ 0.
***"Quantidade devolvida
              wa_outtab-qtd_dev = wa_docmn-value.
***"Quantidade pendente
              wa_outtab-qtd_pend = wa_outtab-qtd_nf - wa_docmn-value.
            ENDIF.
          ENDIF.
        ENDIF.

        wa_outtab-nfenum_ent = wa_cabdoc-docnr. "Num NFE de Entrada

        APPEND wa_outtab TO it_outtab.
        CLEAR: wa_docmn.

      ENDLOOP.

      wa_outtab-qtd_forn = gv_forn.  "Quantidade com fornecedor

* Quantidade em "estoque"
      IF wa_outtab-st_escr NE c_n_esc.
        wa_outtab-qtd_estoque = wa_outtab-qtd_pend - wa_outtab-qtd_forn.
      ELSE.
        wa_outtab-qtd_estoque = 0.
      ENDIF.

*****      IF wa_outtab-qtd_pend IS INITIAL.
****** Dias
*****        wa_outtab-dias   = 0.
****** Nota com quantidade integralmente devolvida
*****        wa_outtab-status = c_devol.
*****
*****      ELSE.

******      ENDIF.

*      APPEND wa_outtab TO it_outtab.

      CLEAR wa_outtab.
    ENDLOOP.
  ENDIF.

  SORT it_outtab. " BY bukrs nf_escr nfenum.
  DELETE ADJACENT DUPLICATES FROM it_outtab COMPARING ALL FIELDS.

*  IF it_outtab[] IS NOT INITIAL.
*    REFRESH it_outtab_aux.
*    it_outtab_aux[] = it_outtab[].
*    LOOP AT it_outtab_aux INTO wa_outtab.
*      IF vl_controle EQ 'X'.
*        LOOP AT it_outtab ASSIGNING <fs_outtab> WHERE nfenum EQ wa_outtab-nfenum.
*          <fs_outtab>-color = 'C110'.
*        ENDLOOP.
*        CLEAR vl_controle.
*      ELSE.
*        LOOP AT it_outtab ASSIGNING <fs_outtab> WHERE nfenum EQ wa_outtab-nfenum.
*          <fs_outtab>-color = '  '.
*        ENDLOOP.
*        vl_controle = 'X'.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.
*
*  SORT it_outtab BY bukrs nf_escr nfenum.
*  DELETE ADJACENT DUPLICATES FROM it_outtab COMPARING ALL FIELDS.

ENDFORM.                    " F_MONTA_HEADER
*
**&---------------------------------------------------------------------*
**&      Module  STATUS_0400  OUTPUT
**&---------------------------------------------------------------------*
*MODULE status_0400 OUTPUT.
*
*  SET PF-STATUS 'STATUS_400'.
*  SET TITLEBAR 'TITLE_400'.
*
*  gv_check_1 = abap_true.
*  gv_check_2 = abap_true.
*  gv_check_3 = abap_true.
*  gv_check_4 = abap_true.
*  gv_check_5 = abap_true.
*  gv_check_6 = abap_true.
*
*ENDMODULE.                 " STATUS_0400  OUTPUT
*
**&---------------------------------------------------------------------*
**&      Module  USER_COMMAND_0400  INPUT
**&---------------------------------------------------------------------*
*MODULE user_command_0400 INPUT.
*
*  CASE sy-ucomm.
*
*    WHEN c_filtrar.
*
*      REFRESH it_outtab.
*
*      IF NOT gv_check_1 IS INITIAL.
*
*        LOOP AT it_outtab_aux INTO wa_outtab WHERE st_escr EQ c_esc.
*          APPEND wa_outtab TO it_outtab.
*        ENDLOOP.
*
*      ENDIF.
*
*      IF NOT gv_check_2 IS INITIAL.
*
*        LOOP AT it_outtab_aux INTO wa_outtab WHERE st_escr EQ c_n_esc.
*          APPEND wa_outtab TO it_outtab.
*        ENDLOOP.
*
*      ENDIF.
*
*      IF NOT gv_check_3 IS INITIAL.
*
*        LOOP AT it_outtab_aux INTO wa_outtab WHERE status EQ c_100.
*          APPEND wa_outtab TO it_outtab.
*        ENDLOOP.
*
*      ENDIF.
*
*      IF NOT gv_check_4 IS INITIAL.
*
*        LOOP AT it_outtab_aux INTO wa_outtab WHERE status EQ c_100_180.
*          APPEND wa_outtab TO it_outtab.
*        ENDLOOP.
*
*      ENDIF.
*
*      IF NOT gv_check_5 IS INITIAL.
*
*        LOOP AT it_outtab_aux INTO wa_outtab WHERE status EQ c_180.
*          APPEND wa_outtab TO it_outtab.
*        ENDLOOP.
*
*      ENDIF.
*
*      IF NOT gv_check_6 IS INITIAL.
*
*        LOOP AT it_outtab_aux INTO wa_outtab WHERE status EQ c_devol.
*          APPEND wa_outtab TO it_outtab.
*        ENDLOOP.
*
*      ENDIF.
*
*      SORT it_outtab.
*
*      DELETE ADJACENT DUPLICATES FROM it_outtab COMPARING ALL FIELDS.
*
*      CALL METHOD go_alv->refresh_table_display.
*
*      LEAVE TO SCREEN 0.
*
*    WHEN c_canc.
*
*      LEAVE TO SCREEN 0.
*
*  ENDCASE.
*
*ENDMODULE.                 " USER_COMMAND_0400  INPUT
