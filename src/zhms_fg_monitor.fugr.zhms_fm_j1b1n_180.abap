FUNCTION ZHMS_FM_J1B1N_180.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(WA_HEADER) TYPE  BAPI_J_1BNFDOC OPTIONAL
*"     VALUE(IT_ITEM) TYPE  BAPI_J_1BNFLIN OPTIONAL
*"     VALUE(IT_ITEM_TAX) TYPE  BAPI_J_1BNFSTX OPTIONAL
*"----------------------------------------------------------------------
*" RCP - Tradução EN/ES - 31/08/2018

*----------------------------------------------------------------------*
* Tables                                                               *
*----------------------------------------------------------------------*
  TABLES: zhms_tb_cabdoc.

*----------------------------------------------------------------------*
* Tabelas internas                                                     *
*----------------------------------------------------------------------*
  DATA: it_docmn     TYPE TABLE OF zhms_tb_docmn,
        it_docmn_aux TYPE TABLE OF zhms_tb_docmn,


        it_return    TYPE TABLE OF bapiret2,
        it_logdoc    TYPE TABLE OF zhms_tb_logdoc.

*----------------------------------------------------------------------*
* Work areas                                                           *
*----------------------------------------------------------------------*
  DATA: wa_docmn     TYPE zhms_tb_docmn,
        wa_docmn_aux TYPE zhms_tb_docmn,
        wa_item      TYPE bapi_j_1bnflin,
        wa_item_tax  TYPE bapi_j_1bnfstx,
        wa_return    TYPE bapiret2,
        wa_logdoc    TYPE zhms_tb_logdoc.

*----------------------------------------------------------------------*
* Variáveis globais                                                    *
*----------------------------------------------------------------------*
  DATA: gv_mensagem TYPE string,
        gv_resposta TYPE c,
        gv_parvw    TYPE lfa1-lifnr,
        gv_itmnum   TYPE j_1bnflin-itmnum,
        gv_docnum   TYPE bapi_j_1bnfdoc-docnum,
        gv_flwst    TYPE zhms_de_flwst,
        gv_seqnr    TYPE zhms_de_seqnr.

*----------------------------------------------------------------------*
* Constantes                                                           *
*----------------------------------------------------------------------*
  CONSTANTS: c_sucesso TYPE c VALUE 'S',
             c_erro    TYPE c VALUE 'E',
             c_info    TYPE c VALUE 'I'.

 SELECT *
    FROM zhms_tb_docmn
    INTO TABLE it_docmn.
*   WHERE chave EQ chave.

  CHECK NOT it_docmn[] IS INITIAL.

* Verifica se a nota já foi escriturada
  READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'MATDOC'.

* Nota já foi escriturada
  IF sy-subrc IS INITIAL.
    CONCATENATE text-m02 wa_docmn-value INTO gv_mensagem SEPARATED BY space.
    MESSAGE gv_mensagem TYPE c_info DISPLAY LIKE c_erro.
    EXIT.
  ENDIF.

* Categoria da nota fiscal
  wa_header-nftype = 'E1'.

* Tipo de documento (1 -> Nota fiscal)
  wa_header-doctyp = '1'.

* Direção do movimento de mercadorias (1 -> Entrada)
  wa_header-direct = '1'.

* Data de lançamento
  wa_header-pstdat = sy-datum.

* Empresa
  wa_header-bukrs = 'HOMI'.

* Local de negócios
  wa_header-branch = '0001'.

* Nota manual
  wa_header-manual = abap_true.

* Moeda
  wa_header-waerk = 'BRL'.

* Modelo (Nota fiscal - modelo 1/1A)
  wa_header-model = '01'.


ENDFUNCTION.
