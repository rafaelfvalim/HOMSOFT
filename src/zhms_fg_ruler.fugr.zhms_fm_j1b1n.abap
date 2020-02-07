FUNCTION zhms_fm_j1b1n.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(CHAVE) TYPE  CHAR44
*"----------------------------------------------------------------------

*----------------------------------------------------------------------*
* Tables                                                               *
*----------------------------------------------------------------------*
  TABLES: zhms_tb_cabdoc.

*----------------------------------------------------------------------*
* Tabelas internas                                                     *
*----------------------------------------------------------------------*
  DATA: it_docmn     TYPE TABLE OF zhms_tb_docmn,
        it_docmn_aux TYPE TABLE OF zhms_tb_docmn,
        it_item      TYPE TABLE OF bapi_j_1bnflin,
        it_item_tax  TYPE TABLE OF bapi_j_1bnfstx,
        it_return    TYPE TABLE OF bapiret2,
        it_logdoc    TYPE TABLE OF zhms_tb_logdoc.

*----------------------------------------------------------------------*
* Work areas                                                           *
*----------------------------------------------------------------------*
  DATA: wa_docmn     TYPE zhms_tb_docmn,
        wa_docmn_aux TYPE zhms_tb_docmn,
        wa_header    TYPE bapi_j_1bnfdoc,
        wa_item      TYPE bapi_j_1bnflin,
        wa_item_tax  TYPE bapi_j_1bnfstx,
        wa_return    TYPE bapiret2,
        wa_logdoc    TYPE zhms_tb_logdoc,
        wa_cabdoc    TYPE zhms_tb_cabdoc.

**----------------------------------------------------------------------*
** Variáveis globais                                                    *
**----------------------------------------------------------------------*
*  DATA: gv_mensagem TYPE string,
*        gv_resposta TYPE c,
*        gv_parvw    TYPE lfa1-lifnr,
*        gv_itmnum   TYPE j_1bnflin-itmnum,
*        gv_docnum   TYPE bapi_j_1bnfdoc-docnum,
*        gv_flwst    TYPE zhms_de_flwst,
*        gv_seqnr    TYPE zhms_de_seqnr.

*----------------------------------------------------------------------*
* Constantes                                                           *
*----------------------------------------------------------------------*
  CONSTANTS: c_sucesso TYPE c VALUE 'S',
             c_erro    TYPE c VALUE 'E',
             c_info    TYPE c VALUE 'I'.

*----------------------------------------------------------------------*
*                                                                      *
*           P R O C E S S A M E N T O   P R I N C I P A L              *
*                                                                      *
*----------------------------------------------------------------------*

* Verifica se a chave de acesso existe
  SELECT SINGLE *
    FROM zhms_tb_cabdoc
   WHERE chave EQ chave.

* Chave de acesso não cadastrada
  IF NOT sy-subrc IS INITIAL.
    MESSAGE text-m03 TYPE c_info DISPLAY LIKE c_erro.
    EXIT.
  ENDIF.

  SELECT SINGLE *
    FROM zhms_tb_cabdoc INTO wa_cabdoc
   WHERE chave EQ chave.

* Busca tags do XML
  SELECT *
    FROM zhms_tb_docmn
    INTO TABLE it_docmn
   WHERE chave EQ chave.

  CHECK NOT it_docmn[] IS INITIAL.

* Verifica se a nota já foi escriturada
  READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'MATDOC'.

* Nota já foi escriturada
  IF sy-subrc IS INITIAL.
    CONCATENATE text-m02 wa_docmn-value INTO gv_mensagem SEPARATED BY space.
    MESSAGE gv_mensagem TYPE c_info DISPLAY LIKE c_erro.
    EXIT.
  ENDIF.

* Deseja continuar?
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = text-q01
      text_question         = text-q02
      text_button_1         = text-q03
      icon_button_1         = 'ICON_CHECKED'
      text_button_2         = text-q04
      icon_button_2         = 'ICON_INCOMPLETE'
      default_button        = '2'
      display_cancel_button = ' '
    IMPORTING
      answer                = gv_resposta
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.

* Sim
  CHECK gv_resposta EQ 1.

  CLEAR gv_resposta.

* Fornecedor ou cliente?
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar       = text-q01
      text_question  = text-q05
      text_button_1  = text-q06
      text_button_2  = text-q07
    IMPORTING
      answer         = gv_resposta
    EXCEPTIONS
      text_not_found = 1
      OTHERS         = 2.

  CHECK gv_resposta EQ '1' OR gv_resposta EQ '2'.

*----------------------------------------------------------------------*
* Dados de cabeçalho                                                   *
*----------------------------------------------------------------------*

  CALL SCREEN 450 STARTING AT 30 5
                  ENDING AT 90 12.

  CHECK ok_code EQ 'OK'.

* Categoria da nota fiscal
*  wa_header-nftype = 'E1'.
  wa_header-nftype = gv_450_ctg.

* Tipo de documento (1 -> Nota fiscal)
  wa_header-doctyp = '1'.

* Direção do movimento de mercadorias (1 -> Entrada)
  wa_header-direct = '1'.

* Data de lançamento
  wa_header-pstdat = sy-datum.

* Empresa
*  wa_header-bukrs = 'HOMI'.
  wa_header-bukrs = gv_450_buk.

* Local de negócios
*  wa_header-branch = '0001'.
  wa_header-branch = gv_450_loc.

* Nota manual
  wa_header-manual = abap_true.

* Moeda
  wa_header-waerk = 'BRL'.

* Modelo (Nota fiscal - modelo 1/1A)
  wa_header-model = '01'.

* Data do documento (emissão)
  CLEAR wa_docmn.

  READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'DHEMI'.

  CONCATENATE wa_docmn-value(4) wa_docmn-value+5(2) wa_docmn-value+8(2) INTO wa_header-docdat.

* Número da NF
  CLEAR wa_docmn.

  READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'NNF'.

  wa_header-nfnum = wa_docmn-value.

* Série
  CLEAR wa_docmn.

  READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'SERIE'.

  wa_header-series = wa_docmn-value.

* Tipo do parceiro
  CLEAR wa_docmn.

  READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'CNPJ'.

  CASE gv_resposta.

    WHEN '1'.

      SELECT SINGLE lifnr
        FROM lfa1
        INTO gv_parvw
       WHERE stcd1 EQ wa_docmn-value.

      wa_header-parvw = 'LF'.

    WHEN '2'.

      SELECT SINGLE kunnr
        FROM kna1
        INTO gv_parvw
       WHERE stcd1 EQ wa_docmn-value.

      wa_header-parvw = 'AG'.

  ENDCASE.

* Código do parceiro
  wa_header-parid = gv_parvw.

* Observações
  CLEAR wa_docmn.

  READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'NATOP'.

  wa_header-observat = wa_docmn-value.

* Dados NF-e
  wa_header-nfe = 'X'.
  wa_header-xmlvers = '4.00'.

  CLEAR wa_docmn.

  READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'NPROT'.

  wa_header-authcod = wa_docmn-value.

  wa_header-docstat = 1.
  wa_header-code = 0.

  CLEAR wa_docmn.

  READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'CHAVE'.

  wa_header-access_key = wa_docmn-value.
  wa_header-model = '55'.

*----------------------------------------------------------------------*
* Dados de item                                                        *
*----------------------------------------------------------------------*
  it_docmn_aux[] = it_docmn[].

  SORT it_docmn_aux ASCENDING BY dcitm .

  DELETE it_docmn_aux WHERE dcitm EQ '000000'.

  DELETE ADJACENT DUPLICATES FROM it_docmn_aux COMPARING dcitm.

  SORT it_docmn BY dcitm mneum.

  CLEAR: gv_itmnum, ok_code.

  LOOP AT it_docmn_aux INTO wa_docmn_aux.

    ADD 10 TO gv_itmnum.

    gv_470_item = gv_itmnum.

    CALL SCREEN 470 STARTING AT 30 5
                    ENDING AT 90 12.

    IF ok_code NE 'OK'.
      EXIT.
    ENDIF.

* Número do item
    wa_item-itmnum = gv_itmnum.

* Material e grupo de mercadoria
*    READ TABLE it_docmn INTO wa_docmn WITH KEY dcitm = wa_docmn_aux-dcitm
*                                               mneum = 'CPROD'
*                                               BINARY SEARCH.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = gv_470_mat
      IMPORTING
        output = wa_item-matnr.

*   wa_item-matnr = gv_470_mat.

    SELECT SINGLE matkl
      FROM mara
      INTO wa_item-matkl
     WHERE matnr EQ wa_item-matnr.

    IF NOT sy-subrc IS INITIAL.

      wa_item-matuse = 0.

    ELSE.

* Utilização de material
      SELECT SINGLE mtuse
        FROM mbew
        INTO wa_item-matuse
       WHERE matnr EQ wa_item-matnr
*         AND bwkey EQ 'HOMI'.
         AND bwkey EQ gv_470_cen.

    ENDIF.

* Centro e área de avaliação (para rodar a BAPI é necessário ter os dois)
*    wa_item-bwkey = 'HOMI'.
    wa_item-bwkey = gv_470_cen.

*    wa_item-werks = 'HOMI'.
    wa_item-werks = gv_470_cen.

* NCM
    READ TABLE it_docmn INTO wa_docmn WITH KEY dcitm = wa_docmn_aux-dcitm
                                               mneum = 'XMLNCM'
                                               BINARY SEARCH.

    WRITE wa_docmn-value TO wa_item-nbm USING EDIT MASK '____.__.__'.

* Origem de material
    wa_item-matorg = '0'.

* Quantidade
    READ TABLE it_docmn INTO wa_docmn WITH KEY dcitm = wa_docmn_aux-dcitm
                                               mneum = 'QCOM'
                                               BINARY SEARCH.

    wa_item-menge = wa_docmn-value.

* Unidade de medida (UN -> ST)
    wa_item-meins = 'ST'.

* Preço
    READ TABLE it_docmn INTO wa_docmn WITH KEY dcitm = wa_docmn_aux-dcitm
                                               mneum = 'VUNCOM'
                                               BINARY SEARCH.

    wa_item-netpr = wa_docmn-value.

* Valor líquido
    wa_item-netwr = wa_item-netpr * wa_item-menge.

* Categoria do item (item normal)
    wa_item-itmtyp = '01'.

* CFOP
    READ TABLE it_docmn INTO wa_docmn WITH KEY dcitm = wa_docmn_aux-dcitm
                                               mneum = 'CFOP'
                                               BINARY SEARCH.

    IF wa_cabdoc-typed EQ 'NFE4'.
      CONCATENATE wa_docmn-value '/AA' INTO wa_docmn-value.

      CONDENSE wa_docmn-value NO-GAPS.

      IF wa_docmn-value(1) = '6'.
        wa_docmn-value(1) = '2'.
      ELSEIF wa_docmn-value(1) = '5'.
        wa_docmn-value(1) = '1'.
      ENDIF.

    ENDIF.






    CALL FUNCTION 'CONVERSION_EXIT_CFOBR_INPUT'
      EXPORTING
        input  = wa_docmn-value
      IMPORTING
        output = wa_item-cfop_10.

* Direitos fiscais - ICMS
    CLEAR wa_docmn.

    READ TABLE it_docmn INTO wa_docmn WITH KEY dcitm = wa_docmn_aux-dcitm
                                               mneum = 'CSTICMS'
                                               BINARY SEARCH.

    IF sy-subrc EQ 0.

      SELECT SINGLE taxlaw
        FROM j_1batl1 AS icms
       INNER JOIN tvarvc AS tvarvc
          ON icms~taxlaw EQ tvarvc~low
        INTO wa_item-taxlw1
       WHERE icms~taxsit EQ wa_docmn-value
         AND tvarvc~name EQ 'ZHMS_J1B1N_ICMS'.

      IF sy-subrc NE 0.
        wa_docmn-value = '0'.

        SELECT SINGLE taxlaw
          FROM j_1batl1 AS icms
         INNER JOIN tvarvc AS tvarvc
            ON icms~taxlaw EQ tvarvc~low
          INTO wa_item-taxlw1
         WHERE icms~taxsit EQ wa_docmn-value
           AND tvarvc~name EQ 'ZHMS_J1B1N_ICMS'.
      ENDIF.

    ELSE.

      wa_docmn-value = '0'.

      SELECT SINGLE taxlaw
        FROM j_1batl1 AS icms
       INNER JOIN tvarvc AS tvarvc
          ON icms~taxlaw EQ tvarvc~low
        INTO wa_item-taxlw1
       WHERE icms~taxsit EQ wa_docmn-value
         AND tvarvc~name EQ 'ZHMS_J1B1N_ICMS'.

    ENDIF.

* Direitos fiscais - IPI
    CLEAR wa_docmn.

    READ TABLE it_docmn INTO wa_docmn WITH KEY dcitm = wa_docmn_aux-dcitm
                                               mneum = 'CSTIPI'
                                               BINARY SEARCH.

    IF sy-subrc EQ 0.

      SELECT SINGLE taxlaw
        FROM j_1batl2 AS ipi
       INNER JOIN tvarvc AS tvarvc
          ON ipi~taxlaw EQ tvarvc~low
        INTO wa_item-taxlw2
       WHERE ipi~taxsitout EQ wa_docmn-value
         AND tvarvc~name EQ 'ZHMS_J1B1N_IPI'.

      IF sy-subrc NE 0.
        wa_docmn-value = '0'.

        SELECT SINGLE taxlaw
          FROM j_1batl2 AS ipi
         INNER JOIN tvarvc AS tvarvc
            ON ipi~taxlaw EQ tvarvc~low
          INTO wa_item-taxlw2
         WHERE ipi~taxsitout EQ wa_docmn-value
           AND tvarvc~name EQ 'ZHMS_J1B1N_IPI'.
      ENDIF.

    ELSE.

      wa_docmn-value = '0'.

      SELECT SINGLE taxlaw
        FROM j_1batl2 AS ipi
       INNER JOIN tvarvc AS tvarvc
          ON ipi~taxlaw EQ tvarvc~low
        INTO wa_item-taxlw2
       WHERE ipi~taxsitout EQ wa_docmn-value
         AND tvarvc~name EQ 'ZHMS_J1B1N_IPI'.


    ENDIF.

* Direitos fiscais - COFINS
    CLEAR wa_docmn.

    READ TABLE it_docmn INTO wa_docmn WITH KEY dcitm = wa_docmn_aux-dcitm
                                               mneum = 'CSTCOFINS'
                                               BINARY SEARCH.

    SELECT SINGLE taxlaw
      FROM j_1batl4a AS cofins
     INNER JOIN tvarvc AS tvarvc
        ON cofins~taxlaw EQ tvarvc~low
      INTO wa_item-taxlw4
     WHERE cofins~taxsit EQ wa_docmn-value
       AND tvarvc~name EQ 'ZHMS_J1B1N_COFINS'.

* Direitos fiscais - PIS
    CLEAR wa_docmn.

    READ TABLE it_docmn INTO wa_docmn WITH KEY dcitm = wa_docmn_aux-dcitm
                                               mneum = 'CSTPIS'
                                               BINARY SEARCH.

    SELECT SINGLE taxlaw
      FROM j_1batl5 AS pis
     INNER JOIN tvarvc AS tvarvc
        ON pis~taxlaw EQ tvarvc~low
      INTO wa_item-taxlw5
     WHERE pis~taxsit EQ wa_docmn-value
       AND tvarvc~name EQ 'ZHMS_J1B1N_PIS'.

* Aba de impostos (ICMS) - Nº item
    wa_item_tax-itmnum = gv_itmnum.

* Código do imposto
    CASE wa_item-matuse.

      WHEN '0' OR '3'.
        wa_item_tax-taxtyp = 'ICM0'.

      WHEN '1' OR '2'.
        wa_item_tax-taxtyp = 'ICM1'.

    ENDCASE.

* Montante
    CLEAR wa_docmn.

    READ TABLE it_docmn INTO wa_docmn WITH KEY dcitm = wa_docmn_aux-dcitm
                                               mneum = 'VPROD'
                                               BINARY SEARCH.

    wa_item_tax-base = wa_docmn-value.

* Outras bases
    wa_item_tax-othbas = wa_docmn-value.

* Taxa de imposto
    CLEAR wa_docmn.

    READ TABLE it_docmn INTO wa_docmn WITH KEY dcitm = wa_docmn_aux-dcitm
                                               mneum = 'PICMS'
                                               BINARY SEARCH.

    wa_item_tax-rate = wa_docmn-value.

    APPEND: wa_item TO it_item,
            wa_item_tax TO it_item_tax.

    CLEAR: wa_item, wa_item_tax.

  ENDLOOP.

  CHECK ok_code NE 'NOK'.

* Cria a nota fiscal
  CALL FUNCTION 'BAPI_J_1B_NF_CREATEFROMDATA'
    EXPORTING
      obj_header   = wa_header
    IMPORTING
      e_docnum     = gv_docnum
    TABLES
      obj_item     = it_item
      obj_item_tax = it_item_tax
      return       = it_return.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

  READ TABLE it_return INTO wa_return WITH KEY type   = c_sucesso
                                               id     = '8B'
                                               number = '161'.

* Grava log de erro
  IF NOT sy-subrc IS INITIAL.

    REFRESH it_logdoc.
    wa_logdoc-logty = c_erro.
    wa_logdoc-logno = wa_return-number.
    APPEND wa_logdoc TO it_logdoc.

    gv_flwst = c_erro.

  ELSE.

* Grava log de sucesso
    REFRESH it_logdoc.
    wa_logdoc-logty = c_sucesso.
    wa_logdoc-logno = wa_return-number.
    wa_logdoc-logv1 = wa_return-message_v1.
    APPEND wa_logdoc TO it_logdoc.

* Verifica o número do documento gerado
    CLEAR wa_docmn.

    SELECT SINGLE MAX( seqnr )
      INTO gv_seqnr
      FROM zhms_tb_docmn
     WHERE chave EQ zhms_tb_cabdoc-chave.

    ADD 1 TO gv_seqnr.

    MOVE: zhms_tb_cabdoc-chave TO wa_docmn-chave,
          'MATDOC'             TO wa_docmn-mneum,
          wa_return-message_v1 TO wa_docmn-value,
          gv_seqnr             TO wa_docmn-seqnr.

* Atualiza DOCMN com o número da nota gerada
    MODIFY zhms_tb_docmn FROM wa_docmn.

    IF sy-subrc IS INITIAL.
      COMMIT WORK.
    ENDIF.

    gv_flwst = 'M'.

  ENDIF.


* Atualiza CABDOC
  IF wa_cabdoc-typed NE 'NFE4'.
    CALL FUNCTION 'ZHMS_FM_REGLOG'
      EXPORTING
        cabdoc = zhms_tb_cabdoc
        flowd  = '10'
        flwst  = gv_flwst
      TABLES
        logdoc = it_logdoc.
  ELSE.
    CALL FUNCTION 'ZHMS_FM_REGLOG'
      EXPORTING
        cabdoc = zhms_tb_cabdoc
        flowd  = '40'
        flwst  = gv_flwst
      TABLES
        logdoc = it_logdoc.
  ENDIF.


  CALL FUNCTION 'ZHMS_FM_STATUS'
    EXPORTING
      cabdoc = zhms_tb_cabdoc.

ENDFUNCTION.
