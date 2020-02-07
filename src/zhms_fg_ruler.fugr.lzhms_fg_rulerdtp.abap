
*&---------------------------------------------------------------------*
*&  Include           LZHMS_FG_RULERDTP
*&---------------------------------------------------------------------*
** Top para rotinas dos mapeamentos.
*&---------------------------------------------------------------------*

*** ---------------------------------------------------------------- ***
*** Tabelas Internas
*** ---------------------------------------------------------------- ***
    DATA: it_nfnad     TYPE STANDARD TABLE OF bapi_j_1bnfnad,
          it_nfnad_ref TYPE STANDARD TABLE OF bapi_j_1bnfnad,
          it_nflin     TYPE STANDARD TABLE OF bapi_j_1bnflin,
          it_nflin_ref TYPE STANDARD TABLE OF bapi_j_1bnflin,
          it_nfstx     TYPE STANDARD TABLE OF bapi_j_1bnfstx,
          it_nfstx_ref TYPE STANDARD TABLE OF bapi_j_1bnfstx,
          it_nfftx     TYPE STANDARD TABLE OF bapi_j_1bnfftx,
          it_nfftx_ref TYPE STANDARD TABLE OF bapi_j_1bnfftx,
          it_nfref     TYPE STANDARD TABLE OF bapi_j_1bnfref,
          it_nfref_ref TYPE STANDARD TABLE OF bapi_j_1bnfref,
          it_nfcpd     TYPE STANDARD TABLE OF bapi_j_1bnfcpd,
          it_nfcpd_ref TYPE STANDARD TABLE OF bapi_j_1bnfcpd,
          it_retur     TYPE STANDARD TABLE OF bapiret2,
          it_retur_ref TYPE STANDARD TABLE OF bapiret2,

          it_dp_parvw  TYPE STANDARD TABLE OF zhms_tb_dp_parvw,

          it_t001w     TYPE STANDARD TABLE OF t001w,
          it_j1baj     TYPE STANDARD TABLE OF j_1baj,
          it_adr6      TYPE STANDARD TABLE OF adr6,
          it_cnae      TYPE STANDARD TABLE OF zhms_tb_cnae,

          it_nflin_tot TYPE STANDARD TABLE OF j_1bnflin,
          it_nfstx_tot TYPE STANDARD TABLE OF j_1bnfstx,
          it_inlin_tot TYPE STANDARD TABLE OF j_1binlin,
          it_intax_tot TYPE STANDARD TABLE OF j_1bintax,

          it_vend_bdet TYPE STANDARD TABLE OF bapivendor_06.

** f_mneum_entradanormal
    DATA:
          po1_return         TYPE STANDARD TABLE OF bapiret2 WITH HEADER LINE,
          poitem             TYPE STANDARD TABLE OF bapimepoitem WITH HEADER LINE,
          poaddrdelivery     TYPE STANDARD TABLE OF bapimepoaddrdelivery WITH HEADER LINE,
          poschedule         TYPE STANDARD TABLE OF bapimeposchedule WITH HEADER LINE,
          poaccount          TYPE STANDARD TABLE OF bapimepoaccount WITH HEADER LINE,
          pocondheader       TYPE STANDARD TABLE OF bapimepocondheader WITH HEADER LINE,
          pocond             TYPE STANDARD TABLE OF bapimepocond WITH HEADER LINE,
          polimits           TYPE STANDARD TABLE OF bapiesuhc WITH HEADER LINE,
          pocontractlimits   TYPE STANDARD TABLE OF bapiesucc WITH HEADER LINE,
          poservices         TYPE STANDARD TABLE OF bapiesllc WITH HEADER LINE,
          posrvaccessvalues  TYPE STANDARD TABLE OF bapiesklc WITH HEADER LINE,
          potextheader       TYPE STANDARD TABLE OF bapimepotextheader WITH HEADER LINE,
          potextitem         TYPE STANDARD TABLE OF bapimepotext WITH HEADER LINE,
          poexpimpitem       TYPE STANDARD TABLE OF bapieipo WITH HEADER LINE,
          pocomponents       TYPE STANDARD TABLE OF bapimepocomponent WITH HEADER LINE,
          poshippingexp      TYPE STANDARD TABLE OF bapimeposhippexp WITH HEADER LINE,
          pohistory          TYPE STANDARD TABLE OF bapiekbe WITH HEADER LINE,
          pohistory_totals   TYPE STANDARD TABLE OF bapiekbes WITH HEADER LINE,
          poconfirmation     TYPE STANDARD TABLE OF bapiekes WITH HEADER LINE,
          allversions        TYPE STANDARD TABLE OF bapimedcm_allversions WITH HEADER LINE,
          popartner          TYPE STANDARD TABLE OF bapiekkop WITH HEADER LINE,
          extensionout       TYPE STANDARD TABLE OF bapiparex WITH HEADER LINE,
          serialnumber       TYPE STANDARD TABLE OF bapimeposerialno WITH HEADER LINE,
          invplanheader      TYPE STANDARD TABLE OF bapi_invoice_plan_header WITH HEADER LINE,
          invplanitem        TYPE STANDARD TABLE OF bapi_invoice_plan_item WITH HEADER LINE,
          pohistory_ma       TYPE STANDARD TABLE OF bapiekbe_ma WITH HEADER LINE.

*** ---------------------------------------------------------------- ***
*** Áreas de Trabalho
*** ---------------------------------------------------------------- ***
    DATA: wa_nfdoc      TYPE bapi_j_1bnfdoc,
          wa_nfnad      TYPE bapi_j_1bnfnad,
          wa_nfnad_ref  TYPE bapi_j_1bnfnad,
          wa_nflin      TYPE bapi_j_1bnflin,
          wa_nflin_ref  TYPE bapi_j_1bnflin,
          wa_nfstx      TYPE bapi_j_1bnfstx,
          wa_nfstx_ref  TYPE bapi_j_1bnfstx,
          wa_nfftx      TYPE bapi_j_1bnfftx,
          wa_nfftx_ref  TYPE bapi_j_1bnfftx,
          wa_nfref      TYPE bapi_j_1bnfref,
          wa_nfref_ref  TYPE bapi_j_1bnfref,
          wa_nfcpd      TYPE bapi_j_1bnfcpd,
          wa_nfcpd_ref  TYPE bapi_j_1bnfcpd,
          wa_retur      TYPE bapiret2,
          wa_retur_ref  TYPE bapiret2,

          wa_custaddr_d TYPE bapicustomer_04,
          wa_custdeth_d TYPE bapicustomer_kna1,
          wa_custdetc_d TYPE bapicustomer_05,
          wa_custdetb_d TYPE bapicustomer_02,
          wa_custaddr_r TYPE bapicustomer_04,
          wa_custdeth_r TYPE bapicustomer_kna1,
          wa_custdetc_r TYPE bapicustomer_05,
          wa_custdetb_r TYPE bapicustomer_02,
          wa_custaddr_e TYPE bapicustomer_04,
          wa_custdeth_e TYPE bapicustomer_kna1,
          wa_custdetc_e TYPE bapicustomer_05,
          wa_custdetb_e TYPE bapicustomer_02,
          wa_custaddr_t TYPE bapicustomer_04,
          wa_custdeth_t TYPE bapicustomer_kna1,
          wa_custdetc_t TYPE bapicustomer_05,
          wa_custdetb_t TYPE bapicustomer_02,

          wa_vendgdet_d TYPE bapivendor_04,
          wa_vendcdet_d TYPE bapivendor_05,
          wa_vendretr_d TYPE bapiret1,
          wa_vendgdet_r TYPE bapivendor_04,
          wa_vendcdet_r TYPE bapivendor_05,
          wa_vendretr_r TYPE bapiret1,
          wa_vendgdet_e TYPE bapivendor_04,
          wa_vendcdet_e TYPE bapivendor_05,
          wa_vendretr_e TYPE bapiret1,
          wa_vendgdet_t TYPE bapivendor_04,
          wa_vendcdet_t TYPE bapivendor_05,
          wa_vendretr_t TYPE bapiret1,

          wa_branaddr   TYPE sadr,
          wa_brandata   TYPE j_1bbranch,
          wa_branadd1   TYPE addr1_val,
          wa_branaddr_d TYPE sadr,
          wa_brandata_d TYPE j_1bbranch,
          wa_branadd1_d TYPE addr1_val,
          wa_branaddr_e TYPE sadr,
          wa_brandata_e TYPE j_1bbranch,
          wa_branadd1_e TYPE addr1_val,
          wa_branaddr_r TYPE sadr,
          wa_brandata_r TYPE j_1bbranch,
          wa_branadd1_r TYPE addr1_val,
          wa_branaddr_t TYPE sadr,
          wa_brandata_t TYPE j_1bbranch,
          wa_branadd1_t TYPE addr1_val,

          wa_dp_parvw   TYPE zhms_tb_dp_parvw,





          wa_nfdoc_ref  TYPE bapi_j_1bnfdoc,
          wa_nfact      TYPE j_1bnfe_active,
          wa_cnae       TYPE zhms_tb_cnae,
          wa_j1baa      TYPE j_1baa,
          wa_t001w      TYPE t001w,
          wa_adr6       TYPE adr6,
          wa_j1baj      TYPE j_1baj,
          wa_tvstz      TYPE tvstz,
          wa_nfdoc_tot  TYPE j_1bindoc,
          wa_nflin_tot  TYPE j_1bnflin,
          wa_nfstx_tot  TYPE j_1bnfstx,
          wa_inlin_tot  TYPE j_1binlin,
          wa_intax_tot  TYPE j_1bintax,
          wa_condpagt   TYPE zhms_tb_condpagt,
          wa_pl_addr    TYPE sadr,
          wa_pl_branc   TYPE j_1bbranch.

** f_mneum_entradanormal
    DATA: poheader       TYPE bapimepoheader,
          poexpimpheader TYPE bapieikp.
*** ---------------------------------------------------------------- ***
*** Variáveis
*** ---------------------------------------------------------------- ***
    DATA: vc_cust_addr(14) TYPE c,
          vc_cust_deth(14) TYPE c,
          vc_cust_detc(14) TYPE c,
          vc_cust_ret1(14) TYPE c,
          vc_cust_detb(14) TYPE c,

          vc_vend_gdet(14) TYPE c,
          vc_vend_cdet(14) TYPE c,
          vc_vend_retr(14) TYPE c,
          vc_vend_bdet(14) TYPE c,

          vc_bran_addr(13) TYPE c,
          vc_bran_data(13) TYPE c,
          vc_bran_cnpj(13) TYPE c,
          vc_bran_add1(13) TYPE c,

          vg_bran_cnpj     TYPE j_1bwfield-cgc_number,
          vg_bran_cnpj_d   TYPE j_1bwfield-cgc_number,
          vg_bran_cnpj_e   TYPE j_1bwfield-cgc_number,
          vg_bran_cnpj_r   TYPE j_1bwfield-cgc_number,
          vg_bran_cnpj_t   TYPE j_1bwfield-cgc_number,



          vg_pl_cnpj       TYPE j_1bwfield-cgc_number,
          vg_acckey(44)    TYPE c.

*** ---------------------------------------------------------------- ***
*** Constantes
*** ---------------------------------------------------------------- ***
    CONSTANTS: c_cust_addr(13) TYPE c VALUE 'WA_CUST_ADDR_',
               c_cust_deth(13) TYPE c VALUE 'WA_CUST_DETH_',
               c_cust_detc(13) TYPE c VALUE 'WA_CUST_DETC_',
               c_cust_ret1(13) TYPE c VALUE 'WA_CUST_RET1_',
               c_cust_detb(13) TYPE c VALUE 'IT_CUST_DETB_',

               c_vend_gdet(13) TYPE c VALUE 'WA_VEND_GDET_',
               c_vend_cdet(13) TYPE c VALUE 'WA_VEND_CDET_',
               c_vend_retr(13) TYPE c VALUE 'WA_VEND_RETR_',
               c_vend_bdet(13) TYPE c VALUE 'IT_VEND_BDET_',

               c_bran_addr(12) TYPE c VALUE 'WA_BRAN_ADDR',
               c_bran_data(12) TYPE c VALUE 'WA_BRAN_DATA',
               c_bran_cnpj(12) TYPE c VALUE 'VG_BRAN_CNPJ',
               c_bran_add1(12) TYPE c VALUE 'WA_BRAN_ADD1'.

*** ---------------------------------------------------------------- ***
*** Ponteiros
*** ---------------------------------------------------------------- ***
    FIELD-SYMBOLS: <cust_addr> TYPE any,
                   <cust_deth> TYPE any,
                   <cust_detc> TYPE any,
                   <bapi_ret1> TYPE any,
                   <cust_detb> TYPE STANDARD TABLE,

                   <vend_gdet> TYPE any,
                   <vend_cdet> TYPE any,
                   <vend_retr> TYPE any,
                   <vend_bdet> TYPE STANDARD TABLE,

                   <bran_addr> TYPE any,
                   <bran_data> TYPE any,
                   <bran_cnpj> TYPE any,
                   <bran_add1> TYPE STANDARD TABLE.




*                   ***********************************************
    DATA: j_1bnfdoc TYPE TABLE OF j_1bnfdoc WITH HEADER LINE,
          j_1bnfnad TYPE TABLE OF j_1bnfnad WITH HEADER LINE,
          j_1bnflin TYPE TABLE OF j_1bnflin WITH HEADER LINE,
          j_1bnfstx TYPE TABLE OF j_1bnfstx WITH HEADER LINE,
          j_1bnfftx TYPE TABLE OF j_1bnfftx WITH HEADER LINE,
          j_1bnfref TYPE TABLE OF j_1bnfref WITH HEADER LINE,
          j_1bnfcpd TYPE TABLE OF j_1bnfcpd WITH HEADER LINE.
*
*    TABLES: j_1bnfdoc,
*            j_1bnfnad,
*            j_1bnflin,
*            j_1bnfstx,
*            j_1bnfftx,
*            j_1bnfref,
*            j_1bnfcpd.

    DATA: BEGIN OF wk_item_add OCCURS 0.
            INCLUDE STRUCTURE j_1binlin.
    DATA: END OF wk_item_add.

    DATA: BEGIN OF wk_header_add.
            INCLUDE STRUCTURE j_1bindoc.
    DATA: END OF wk_header_add.
