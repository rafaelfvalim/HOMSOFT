*----------------------------------------------------------------------*
*                                                                      *
*           |--------------------------------------------|             *
*           |          H   O   M   I   N   E             |             *
*           |--------------------------------------------|             *
*                                                                      *
*----------------------------------------------------------------------*
* Transação:     -                                                     *
* Função:        ZHMS_FM_J1B1N_CTE                                     *
* Descrição:     J1B1N de CT-e para o Mercado Livre                    *
* Desenvolvedor: Renan Itokazo                                         *
* Data:          11/04/2019                                            *
*----------------------------------------------------------------------*
FUNCTION ZHMS_FM_J1B1N_CTE.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(CHAVE) TYPE  CHAR44
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
* Tabelas internas
*----------------------------------------------------------------------*
  DATA: it_docmn            TYPE TABLE OF zhms_tb_docmn,
        it_tvarvc           TYPE TABLE OF tvarvc,
        it_item             TYPE TABLE OF bapi_j_1bnflin,
        it_partner          TYPE TABLE OF bapi_j_1bnfcpd,
        it_tax              TYPE TABLE OF bapi_j_1bnfstx,
        it_return           TYPE TABLE OF bapiret2,
        it_logdoc           TYPE TABLE OF zhms_tb_logdoc,
        lt_partner          TYPE TABLE OF j_1bnfnad,
        lt_item             TYPE TABLE OF j_1bnflin,
        lt_item_add         TYPE TABLE OF j_1binlin,
        lt_item_tax         TYPE TABLE OF j_1bnfstx,
        lt_header_msg       TYPE TABLE OF j_1bnfftx,
        lt_refer_msg        TYPE TABLE OF j_1bnfref.

*----------------------------------------------------------------------*
* Work areas
*----------------------------------------------------------------------*
  DATA: wa_header           TYPE bapi_j_1bnfdoc,
        wa_item             TYPE bapi_j_1bnflin,
        wa_tax              TYPE bapi_j_1bnfstx,
        wa_partner          TYPE bapi_j_1bnfcpd,
        wa_docmn            TYPE zhms_tb_docmn,
        wa_tvarvc           TYPE tvarvc,
        wa_cabdoc           TYPE zhms_tb_cabdoc,
        wa_return           TYPE bapiret2,
        wa_logdoc           TYPE zhms_tb_logdoc,
        ls_header           TYPE j_1bnfdoc.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
  DATA: lv_cteverificaemit  TYPE c LENGTH 1,
        lv_tvarv_cnpj       TYPE c LENGTH 14,
        lv_tvarv_cst        TYPE c LENGTH 2,
        lv_tvarvval         TYPE RVARI_VAL_255,
        lv_tvarv_taxlaw     TYPE c LENGTH 10,
        lv_nct_xml          TYPE c LENGTH 9,
        lv_cst_xml          TYPE c LENGTH 2,
        lv_cfop_xml         TYPE c LENGTH 4,
        lv_cfop_de          TYPE c LENGTH 6,
        lv_cfop_para        TYPE c LENGTH 6,
        lv_uf               TYPE c LENGTH 2,
        lv_cmun             TYPE c LENGTH 10,
        lv_tomador          TYPE c LENGTH 1,
        lv_vbc_xml          TYPE c LENGTH 10,
        lv_vtprest_xml      TYPE c LENGTH 10,
        lv_picms_xml        TYPE c LENGTH 10,
        lv_vicms_xml        TYPE c LENGTH 10,
*        lv_docnum           TYPE bapi_j_1bnfdoc-docnum,
        lv_docnum           TYPE j_1bnfdoc-docnum,
        lv_seqnr            TYPE zhms_de_seqnr,
        lv_j1b1n_taxval     TYPE J_1BNETVAL,
        lf_ufini            TYPE c LENGTH 2,
        lv_uftoma           TYPE c LENGTH 2,
        lv_cod_sit          TYPE J_1B_STATUS_FISC_DOC,
        lv_ufini            TYPE c LENGTH 2.

TRY.
*----------------------------------------------------------------------*
* Busca todos os mneumonicos do XML
*----------------------------------------------------------------------*
  SELECT *
    FROM zhms_tb_docmn
    INTO TABLE it_docmn
   WHERE chave EQ chave.

  SELECT SINGLE *
    FROM zhms_tb_cabdoc
    INTO wa_cabdoc
  WHERE chave EQ chave.

  SELECT  *
    FROM TVARVC
    INTO TABLE it_tvarvc
  WHERE name LIKE 'ZHMS%'.


  CHECK NOT it_docmn[] IS INITIAL.
  CHECK NOT wa_cabdoc IS INITIAL.

  CLEAR: wa_docmn.
  READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'MATDOC'.

  CHECK wa_docmn-value IS INITIAL.


IF wa_cabdoc-typed EQ 'CTE'.

*----------------------------------------------------------------------*
* Verifica qual cod-sit devera ser utilizado                           *
*----------------------------------------------------------------------*
  CLEAR: wa_docmn.
  READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'TPCTE'.

  IF sy-subrc IS INITIAL.
    IF wa_docmn-value EQ '1'.
      lv_cod_sit = '06'.
    ELSE.
      lv_cod_sit = '00'.
    ENDIF.
  ENDIF.

*----------------------------------------------------------------------*
* Verifica se o XML é saída ou entrada                                 *
*----------------------------------------------------------------------*
  CLEAR: wa_docmn.
  READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'EMITCNPJ'.

  IF sy-subrc IS INITIAL.
    LOOP AT it_tvarvc INTO wa_tvarvc WHERE name EQ 'ZHMS_CNPJ_BUKRS_BRANCH'.
       lv_tvarv_cnpj = wa_tvarvc-low+0(14).
       IF lv_tvarv_cnpj EQ wa_docmn-value.
         lv_cteverificaemit = abap_true.
       ENDIF.
    ENDLOOP.
  ENDIF.

CLEAR: wa_tvarvc.
*----------------------------------------------------------------------*
* Dados de cabeçalho                                                   *
*----------------------------------------------------------------------*

  wa_header-doctyp = '4'.

  READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'DHEMI'.
  CONCATENATE wa_docmn-value(4) wa_docmn-value+5(2) wa_docmn-value+8(2) INTO wa_header-docdat.
  CLEAR: wa_docmn.

  wa_header-model = '57'.

  CLEAR: wa_docmn.
  READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'SERIE'.
  wa_header-series = wa_docmn-value.


  wa_header-manual = abap_true.
  wa_header-waerk = 'BRL'.
  wa_header-bukrs = wa_cabdoc-bukrs.
  wa_header-branch = wa_cabdoc-branch.
  wa_header-parxcpdk = abap_true.
  wa_header-nfe = abap_true.

  CLEAR: wa_docmn.
  READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'NCT'.

   CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
     EXPORTING
       INPUT         = wa_docmn-value
    IMPORTING
      OUTPUT        = lv_nct_xml.

  wa_header-nfenum = lv_nct_xml.

  CLEAR: wa_docmn.
  READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'NPROT'.
  wa_header-authcod = wa_docmn-value.

  wa_header-docstat = '1'.
  wa_header-xmlvers = '3.00'.
  wa_header-code = '100'.

  CLEAR: wa_docmn.
  READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'DHRECBTO'.
  CONCATENATE wa_docmn-value(4) wa_docmn-value+5(2) wa_docmn-value+8(2)  INTO wa_header-authdate.

  wa_docmn-value = wa_docmn-value+11(8).
  TRANSLATE wa_docmn-value USING ': '''.
  CONDENSE wa_docmn-value NO-GAPS.

  wa_header-authtime = wa_docmn-value.

  wa_header-cte_serv_taker = '4'.
  wa_header-indpag = '0'.
  wa_header-pstdat = sy-datum.

  CASE lv_cteverificaemit.
    WHEN abap_true.
      wa_header-nftype = 'CS'.
      wa_header-direct = '2'.
      wa_header-parvw = 'AG'.
      wa_header-partyp = 'C'.

      READ TABLE it_tvarvc INTO wa_tvarvc WITH KEY name  = 'ZHMS_PARID_EMIT'.
      wa_header-parid = wa_tvarvc-low.

    WHEN abap_false.
      wa_header-nftype = 'CT'.
      wa_header-direct = '1'.
      wa_header-parvw = 'LF'.
      wa_header-partyp = 'V'.

      READ TABLE it_tvarvc INTO wa_tvarvc WITH KEY name  = 'ZHMS_PARID_DEST'.
      wa_header-parid = wa_tvarvc-low.
  ENDCASE.

  wa_header-access_key = chave.

  CLEAR: wa_docmn.
  READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'UFINI'.
  lv_uf = wa_docmn-value.
lv_ufini = wa_docmn-value.

  CLEAR: wa_docmn.
  READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'CMUNINI'.
  lv_cmun = wa_docmn-value.

  CONCATENATE lv_uf lv_cmun INTO wa_header-cte_strt_lct SEPARATED BY SPACE.

  CLEAR: wa_docmn.
  READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'UFFIM'.
  lv_uf = wa_docmn-value.


  CLEAR: wa_docmn.
  READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'CMUNFIM'.
  lv_cmun = wa_docmn-value.

  CONCATENATE lv_uf lv_cmun INTO wa_header-cte_end_lct SEPARATED BY SPACE.


*----------------------------------------------------------------------*
* Dados de item                                                        *
*----------------------------------------------------------------------*
  wa_item-matnr = 'CT-001'.
  wa_item-matkl = '017'.
  wa_item-maktx = 'SERVIÇO DE FRETE'.
  wa_item-nbm = 'ISS_7.01'.
  wa_item-matorg = '0'.
  wa_item-matuse = '1'.
  wa_item-menge = '1.0000'.

  CLEAR: wa_docmn.
  READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'VTPREST'.
  wa_item-netpr = wa_docmn-value.
  wa_item-netwr = wa_docmn-value.

  CLEAR: wa_docmn.
  READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'CST'.
  lv_cst_xml = wa_docmn-value.

  CLEAR: wa_docmn.
  READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'CFOP'.
  lv_cfop_xml = wa_docmn-value.

  wa_item-itmtyp = '01'.
  wa_item-meins = 'LE'.
  wa_item-itmnum = '000001'.

  CASE lv_cteverificaemit.
    WHEN abap_true.
      wa_item-taxsit = '0'.
      wa_item-taxlw1 = 'IC0'.
      wa_item-taxlw4 = 'C01'.
      wa_item-taxsi4 = '01'.
      wa_item-taxlw5 = 'P01'.
      wa_item-taxsi5 = '01'.
      CONCATENATE lv_cfop_xml 'AA' INTO wa_item-cfop_10.
    WHEN abap_false.
      LOOP AT it_tvarvc INTO wa_tvarvc WHERE name EQ 'ZHMS_TAXSIT'.
         lv_tvarv_cst = wa_tvarvc-low+0(2).
         IF lv_tvarv_cst EQ lv_cst_xml.
          SELECT SINGLE taxsit
             INTO wa_item-taxsit
              FROM j_1batl1
               WHERE taxsit = lv_tvarv_cst.
         ENDIF.
      ENDLOOP.

      LOOP AT it_tvarvc INTO wa_tvarvc WHERE name EQ 'ZHMS_TAXLW1'.
        SPLIT wa_tvarvc-low AT ';' INTO lv_tvarv_cst lv_tvarv_taxlaw.
        IF lv_tvarv_cst EQ lv_cst_xml.
          wa_item-taxlw1 = lv_tvarv_taxlaw.
        ENDIF.
      ENDLOOP.

      wa_item-taxlw4 = 'C50'.
      wa_item-taxsi4 = '50'.
      wa_item-taxlw5 = 'P50'.
      wa_item-taxsi5 = '50'.

      LOOP AT it_tvarvc INTO wa_tvarvc WHERE name EQ 'ZHMS_CFOP'.
        SPLIT wa_tvarvc-low AT ';' INTO lv_cfop_de lv_cfop_para.

        if lv_cfop_de EQ lv_cfop_xml.
          wa_item-cfop_10 = lv_cfop_para.
        endif.
      ENDLOOP.
  ENDCASE.

  APPEND wa_item TO it_item.

*----------------------------------------------------------------------*
* Dados do pareceiro                                                   *
*----------------------------------------------------------------------*
  wa_partner-land1 = 'BR'.

  CLEAR: wa_docmn.
  READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'TOMA'.
  lv_tomador = wa_docmn-value.

  wa_partner-xcpdk = abap_true.

  CASE lv_cteverificaemit.
    WHEN abap_true.
      wa_partner-parvw = 'AG'.

      CASE lv_tomador.
        WHEN '0'.
          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'REMXNOME'.
          wa_partner-name1 = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'REMECEP'.
          wa_partner-pstlz = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'REMEXMUN'.
          wa_partner-ort01 = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'REMEXLGR'.
          wa_partner-stras = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'REMCNPJ'.
          wa_partner-stcd1 = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'REMEUF'.
          wa_partner-regio = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'REMIE'.
          wa_partner-j_1bstains = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'REMEXBAIRR'.
          wa_partner-city2 = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'REMEXLGR'.
          wa_partner-street = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'REMECMUN'.
          lv_cmun = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'REMECMUN'.
          lv_cmun = wa_docmn-value.

          CONCATENATE wa_partner-regio lv_cmun INTO wa_partner-taxjurcode.

*          CLEAR: wa_docmn.
*          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'REMXNOME'.
*          wa_partner-name2 = wa_docmn-value.
        WHEN '1'.
          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'EXPEDXNOME'.
          wa_partner-name1 = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'EXPEDCEP'.
          wa_partner-pstlz = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'EXPEDXMUN'.
          wa_partner-ort01 = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'EXPEDXLGR'.
          wa_partner-stras = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'EXPEDCNPJ'.
          wa_partner-stcd1 = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'EXPEDUF'.
          wa_partner-regio = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'EXPEDIE'.
          wa_partner-j_1bstains = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'EXPEDXBAIRR'.
          wa_partner-city2 = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'EXPEDXLGR'.
          wa_partner-street = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'EXPEDCMUN'.
          lv_cmun = wa_docmn-value.

          CONCATENATE wa_partner-regio lv_cmun INTO wa_partner-taxjurcode.

*          CLEAR: wa_docmn.
*          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'EXPEDXNOME'.
*          wa_partner-name2 = wa_docmn-value.
        WHEN '2'.
          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'RECEBXNOME'.
          wa_partner-name1 = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'RECEBCEP'.
          wa_partner-pstlz = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'RECEBXMUN'.
          wa_partner-ort01 = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'RECEBXLGR'.
          wa_partner-stras = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'RECEBCNPJ'.
          wa_partner-stcd1 = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'RECEBUF'.
          wa_partner-regio = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'RECEBIE'.
          wa_partner-j_1bstains = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'RECEBXBAIRR'.
          wa_partner-city2 = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'RECEBXLGR'.
          wa_partner-street = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'RECEBCMUN'.
          lv_cmun = wa_docmn-value.

          CONCATENATE wa_partner-regio lv_cmun INTO wa_partner-taxjurcode.

*          CLEAR: wa_docmn.
*          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'RECEBXNOME'.
*          wa_partner-name2 = wa_docmn-value.
        WHEN '3'.
          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'DESTXNOME'.
          wa_partner-name1 = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'DESTCEP'.
          wa_partner-pstlz = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'DESTXMUN'.
          wa_partner-ort01 = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'ENDERDEST'.
          wa_partner-stras = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'DESTCNPJ'.
          wa_partner-stcd1 = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'DESTUF'.
          wa_partner-regio = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'DESTIE'.
          wa_partner-j_1bstains = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'DESTXBAIRR'.
          wa_partner-city2 = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'ENDERDEST'.
          wa_partner-street = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'DESTCMUN'.
          lv_cmun = wa_docmn-value.

          CONCATENATE wa_partner-regio lv_cmun INTO wa_partner-taxjurcode.

*          CLEAR: wa_docmn.
*          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'DESTXNOME'.
*          wa_partner-name2 = wa_docmn-value.
        WHEN '4'.
          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'TOMA4XNOME'.
          wa_partner-name1 = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'TOMACEP'.
          wa_partner-pstlz = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'DESTXMUN'.
          wa_partner-ort01 = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'TOMA4XLGR'.
          wa_partner-stras = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'TOMA4CNPJ'.
          wa_partner-stcd1 = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'TOMAUF'.
          wa_partner-regio = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'TOMA4IE'.
          wa_partner-j_1bstains = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'TOMAXBAIRR'.
          wa_partner-city2 = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'TOMA4XLGR'.
          wa_partner-street = wa_docmn-value.

          CLEAR: wa_docmn.
          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'TOMACMUN'.
          lv_cmun = wa_docmn-value.

          CONCATENATE wa_partner-regio lv_cmun INTO wa_partner-taxjurcode.

*          CLEAR: wa_docmn.
*          READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'TOMA4XNOME'.
*          wa_partner-name2 = wa_docmn-value.
      ENDCASE.

    WHEN abap_false.
      wa_partner-parvw = 'LF'.

      CLEAR: wa_docmn.
      READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'EMITXNOME'.
      wa_partner-name1 = wa_docmn-value.

      CLEAR: wa_docmn.
      READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'EMITCEP'.
      wa_partner-pstlz = wa_docmn-value.

      CLEAR: wa_docmn.
      READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'REMEXMUN'.
      wa_partner-ort01 = wa_docmn-value.

      CLEAR: wa_docmn.
      READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'EMITXLGR'.
      wa_partner-stras = wa_docmn-value.

      CLEAR: wa_docmn.
      READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'EMITCNPJ'.
      wa_partner-stcd1 = wa_docmn-value.

      CLEAR: wa_docmn.
      READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'EMITUF'.
      wa_partner-regio = wa_docmn-value.

      CLEAR: wa_docmn.
      READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'EMITIE'.
      wa_partner-j_1bstains = wa_docmn-value.

      CLEAR: wa_docmn.
      READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'EMITXBAIRR'.
      wa_partner-city2 = wa_docmn-value.

      CLEAR: wa_docmn.
      READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'EMITXLGR'.
      wa_partner-street = wa_docmn-value.

      CLEAR: wa_docmn.
      READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'EMITCMUN'.
      lv_cmun = wa_docmn-value.

      CONCATENATE wa_partner-regio lv_cmun INTO wa_partner-taxjurcode.

*      CLEAR: wa_docmn.
*      READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'EMITXNOME'.
*      wa_partner-name2 = wa_docmn-value.
  ENDCASE.

  APPEND wa_partner TO it_partner.


*----------------------------------------------------------------------*
* Dados de taxas                                                       *
*----------------------------------------------------------------------*
  CLEAR: wa_docmn.
  READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'VBC'.
  IF sy-subrc IS INITIAL.
    lv_vbc_xml = wa_docmn-value.
  ENDIF.

  CLEAR: wa_docmn.
  READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'VTPREST'.
  IF sy-subrc IS INITIAL.
    lv_vtprest_xml = wa_docmn-value.
  ENDIF.

  CLEAR: wa_docmn.
  READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'PICMS'.
  IF sy-subrc IS INITIAL.
    lv_picms_xml = wa_docmn-value.
  ENDIF.

  CLEAR: wa_docmn.
  READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'VICMS'.
  IF sy-subrc IS INITIAL.
    lv_vicms_xml = wa_docmn-value.
  ENDIF.

  CASE lv_cteverificaemit.
    WHEN abap_true.
      wa_tax-itmnum = '000001'.
*      wa_tax-taxtyp = 'ICM1'.
      wa_tax-taxtyp = 'ICM3'.

      IF NOT lv_vbc_xml IS INITIAL.
        wa_tax-base = lv_vbc_xml.
      ELSE.
        wa_tax-base = lv_vtprest_xml.
      ENDIF.

      wa_tax-rate = lv_picms_xml.
      wa_tax-taxval = ( wa_tax-base * wa_tax-rate ) / 100.

      APPEND wa_tax TO it_tax.
      CLEAR: wa_tax.

      wa_tax-itmnum = '000001'.
      wa_tax-taxtyp = 'ICOF'.

      IF NOT lv_vbc_xml IS INITIAL.
        wa_tax-base = lv_vbc_xml.
      ELSE.
        wa_tax-base = lv_vtprest_xml.
      ENDIF.

      wa_tax-rate = '7.60'.
      wa_tax-taxval = ( wa_tax-base * wa_tax-rate ) / 100.

      APPEND wa_tax TO it_tax.
      CLEAR: wa_tax.

      wa_tax-itmnum = '000001'.
      wa_tax-taxtyp = 'IPIS'.

      IF NOT lv_vbc_xml IS INITIAL.
        wa_tax-base = lv_vbc_xml.
      ELSE.
        wa_tax-base = lv_vtprest_xml.
      ENDIF.

      wa_tax-rate = '1.65'.
      wa_tax-taxval = ( wa_tax-base * wa_tax-rate ) / 100.

      APPEND wa_tax TO it_tax.
      CLEAR: wa_tax.
    WHEN abap_false.

      CLEAR: wa_docmn.
      READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'TOMAUF'.
      lv_uftoma = wa_docmn-value.


*----------------------------------------------------------------------*
* Se uma das regras abaixo for verdadeira o taxtyp será ICM2           *
* 1 - CFOP for igual a 5932 ou 6932                                    *
* 2 - TAG UFINI for diferente da tag TOMAUF(tomador4) e tag TOMAUF esteja preenchida*
* 3 - TAG CST for diferente de '00' e '20'                             *
*----------------------------------------------------------------------*
      IF ( lv_cfop_xml EQ '5932' OR lv_cfop_xml EQ '6932' ) OR ( lv_ufini NE lv_uftoma AND lv_uftoma IS NOT INITIAL ) OR ( lv_cst_xml NE '00' AND lv_cst_xml NE '20') .
        wa_tax-itmnum = '000001'.
        wa_tax-taxtyp = 'ICM2'.
        IF NOT lv_vbc_xml IS INITIAL.
           wa_tax-othbas = lv_vbc_xml.
        ELSE.
           wa_tax-othbas = lv_vtprest_xml.
        ENDIF.

        APPEND wa_tax TO it_tax.
        CLEAR: wa_tax.

        wa_tax-itmnum = '000001'.
        wa_tax-taxtyp = 'ICOF'.

        IF NOT lv_vbc_xml IS INITIAL.
          wa_tax-base = lv_vbc_xml.
        ELSE.
          wa_tax-base = lv_vtprest_xml.
        ENDIF.

        wa_tax-rate = '7.60'.
        wa_tax-taxval = ( wa_tax-base * wa_tax-rate ) / 100.

        APPEND wa_tax TO it_tax.
        CLEAR: wa_tax.

        wa_tax-itmnum = '000001'.
        wa_tax-taxtyp = 'IPIS'.

        IF NOT lv_vbc_xml IS INITIAL.
          wa_tax-base = lv_vbc_xml.
        ELSE.
          wa_tax-base = lv_vtprest_xml.
        ENDIF.

        wa_tax-rate = '1.65'.
        wa_tax-taxval = ( wa_tax-base * wa_tax-rate ) / 100.

        APPEND wa_tax TO it_tax.
        CLEAR: wa_tax.
      ELSE.
        wa_tax-itmnum = '000001'.
        wa_tax-taxtyp = 'ICM1'.

        IF lv_vbc_xml > 0.
          wa_tax-base = lv_vbc_xml.
          wa_tax-rate = lv_picms_xml.
          wa_tax-taxval = lv_vicms_xml.
        ELSE.
          wa_tax-othbas = lv_vtprest_xml.
        ENDIF.

        APPEND wa_tax TO it_tax.
        CLEAR: wa_tax.

        wa_tax-itmnum = '000001'.
        wa_tax-taxtyp = 'ICOF'.
        IF NOT lv_vbc_xml IS INITIAL.
          wa_tax-base = lv_vbc_xml.
        ELSE.
          wa_tax-base = lv_vtprest_xml.
        ENDIF.

        wa_tax-rate = '7.60'.
        wa_tax-taxval = ( wa_tax-base * wa_tax-rate ) / 100.

        APPEND wa_tax TO it_tax.
        CLEAR: wa_tax.

        wa_tax-itmnum = '000001'.
        wa_tax-taxtyp = 'IPIS'.

        IF NOT lv_vbc_xml IS INITIAL.
          wa_tax-base = lv_vbc_xml.
        ELSE.
          wa_tax-base = lv_vtprest_xml.
        ENDIF.

        wa_tax-rate = '1.65'.
        wa_tax-taxval = ( wa_tax-base * wa_tax-rate ) / 100.

        APPEND wa_tax TO it_tax.
        CLEAR: wa_tax.

      ENDIF.
  ENDCASE.

  LOOP AT it_tax INTO wa_tax.
    lv_j1b1n_taxval = lv_j1b1n_taxval + wa_tax-taxval.
  ENDLOOP.

  CLEAR: wa_item.
  READ TABLE it_item INTO wa_item INDEX 1.

*----------------------------------------------------------------------*
* Se uma das regras abaixo for verdadeira o TAXLW1 será IC9            *
* 1 - CFOP for igual a 5932 ou 6932                                    *
* 2 - TAG UFINI for diferente da tag TOMAUF(tomador4) e tag TOMAUF esteja preenchida*
* 3 - Ser um CT-e de entrada                                           *
*----------------------------------------------------------------------*
  IF ( lv_cfop_xml EQ '5932' OR lv_cfop_xml EQ '6932' ) OR ( lv_ufini NE lv_uftoma AND lv_uftoma IS NOT INITIAL )  AND lv_cteverificaemit EQ abap_false.
    wa_item-taxlw1 = 'IC9'.
  ENDIF.

  wa_item-netwr = wa_item-netwr - lv_j1b1n_taxval.
  wa_item-netpr = wa_item-netpr - lv_j1b1n_taxval.

  MODIFY it_item FROM wa_item INDEX 1.

*----------------------------------------------------------------------*
* Chamada da BAPI                                                      *
*----------------------------------------------------------------------*
  CALL FUNCTION 'BAPI_J_1B_NF_CREATEFROMDATA'
    EXPORTING
      OBJ_HEADER              = wa_header
   IMPORTING
     E_DOCNUM                = lv_docnum
    TABLES
      OBJ_OT_PARTNER          = it_partner
      OBJ_ITEM                = it_item
      OBJ_ITEM_TAX            = it_tax
      RETURN                  = it_return
            .

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

  READ TABLE it_return INTO wa_return WITH KEY type   = 'S'
                                               id     = '8B'
                                               number = '161'.

  IF NOT sy-subrc IS INITIAL.
*----------------------------------------------------------------------*
* Gravar log de erro                                                   *
*----------------------------------------------------------------------*
    REFRESH it_logdoc.

    LOOP AT it_return INTO wa_return.
      wa_logdoc-logty = 'E'.
      wa_logdoc-logno = wa_return-number.
      wa_logdoc-logv1 = wa_return-message.
      APPEND wa_logdoc TO it_logdoc.
      CLEAR: wa_logdoc.
    ENDLOOP.

    CALL FUNCTION 'ZHMS_FM_REGLOG'
      EXPORTING
        cabdoc = wa_cabdoc
        flowd  = '10'
        flwst  = 'E'
      TABLES
        logdoc = it_logdoc.

  CALL FUNCTION 'ZHMS_FM_STATUS'
    EXPORTING
      cabdoc = wa_cabdoc.

  ELSE.
*----------------------------------------------------------------------*
* Gravar Log                                                           *
*----------------------------------------------------------------------*
    REFRESH it_logdoc.
    wa_logdoc-logty = 'S'.
    wa_logdoc-logno = wa_return-number.
    wa_logdoc-logv1 = wa_return-message.
    APPEND wa_logdoc TO it_logdoc.

    CLEAR wa_docmn.
*----------------------------------------------------------------------*
* Gravar mneumonico com o docnum                                       *
*----------------------------------------------------------------------*
    SELECT SINGLE MAX( seqnr )
      INTO lv_seqnr
      FROM zhms_tb_docmn
     WHERE chave EQ chave.

    ADD 1 TO lv_seqnr.

    MOVE: chave                TO wa_docmn-chave,
          'MATDOC'             TO wa_docmn-mneum,
          wa_return-message_v1 TO wa_docmn-value,
          lv_seqnr             TO wa_docmn-seqnr.

    MODIFY zhms_tb_docmn FROM wa_docmn.

    IF sy-subrc IS INITIAL.
      COMMIT WORK.
    ENDIF.
*----------------------------------------------------------------------*
* Registrar etapa 10 como realizada                                    *
*----------------------------------------------------------------------*
    CALL FUNCTION 'ZHMS_FM_REGLOG'
      EXPORTING
        cabdoc = wa_cabdoc
        flowd  = '10'
        flwst  = 'A'
      TABLES
        logdoc = it_logdoc.

  CALL FUNCTION 'ZHMS_FM_STATUS'
    EXPORTING
      cabdoc = wa_cabdoc.


*----------------------------------------------------------------------*
* Excluir todos os mneumonicos do XML exceto o docnum                  *
*----------------------------------------------------------------------*
  CALL FUNCTION 'ZHMS_FM_EXCLUIMNEUM'
    EXPORTING
      CHAVE         = chave.


  CALL FUNCTION 'ZHMS_FM_UPDATE_CODSIT'
    EXPORTING
      docnum = lv_docnum
      lv_cod_sit = lv_cod_sit
     TABLES
       it_partner = it_partner
      .
  ENDIF.
ENDIF.
*----------------------------------------------------------------------*
* Gravar log de erro se ocorrer                                        *
*----------------------------------------------------------------------*
CATCH cx_root.
   REFRESH it_logdoc.

    LOOP AT it_return INTO wa_return.
      wa_logdoc-logty = 'E'.
      wa_logdoc-logno = wa_return-number.
      wa_logdoc-logv1 = wa_return-message.
      APPEND wa_logdoc TO it_logdoc.
      CLEAR: wa_logdoc.
    ENDLOOP.

    CALL FUNCTION 'ZHMS_FM_REGLOG'
      EXPORTING
        cabdoc = wa_cabdoc
        flowd  = '10'
        flwst  = 'E'
      TABLES
        logdoc = it_logdoc.

  CALL FUNCTION 'ZHMS_FM_STATUS'
    EXPORTING
      cabdoc = wa_cabdoc.
ENDTRY.
ENDFUNCTION.
