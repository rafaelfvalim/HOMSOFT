FUNCTION f_zhms_ml81n_bapi .
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(ZEBELN) TYPE  EBELN
*"     REFERENCE(ZREF_DOC_NO) TYPE  XBLNR
*"     REFERENCE(ZEXT_NUMBER) TYPE  LBLNE
*"     REFERENCE(ZSHORT_TEXT) TYPE  TXZ01_ESSR
*"     REFERENCE(ZREL_CODE) TYPE  BAPIMMPARA-REL_CODE
*"  EXPORTING
*"     REFERENCE(MATERIALDOCUMENT) TYPE  BAPIESSR-SHEET_NO
*"     REFERENCE(MATDOCUMENTYEAR) TYPE  EKBE-LFGJA
*"  TABLES
*"      ZBAPI_RETURN_PO STRUCTURE  BAPIRET2
*"      ZBAPI_RETURN_FR STRUCTURE  BAPIRET2
*"      ZBAPI_SRV_RETURN STRUCTURE  BAPIRETURN1
*"      RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------

  CONSTANTS: c_e(01)  TYPE c VALUE 'E',
             c_k(01)  TYPE c VALUE 'K',
             c_u(01)  TYPE c VALUE 'U',
             c_x(01)  TYPE c VALUE 'X'.

** Bapi Declarations
  DATA: bapi_essr TYPE bapiessrc OCCURS 0  WITH HEADER LINE,
        bapi_eskn TYPE bapiesknc OCCURS 0  WITH HEADER LINE,
        bapi_esll TYPE bapiesllc OCCURS 0  WITH HEADER LINE,
        bapi_eskl TYPE bapiesklc OCCURS 0  WITH HEADER LINE.

  DATA: w_bapi_essr TYPE bapiessrc.

  DATA: BEGIN OF bapi_return OCCURS 0.
          INCLUDE STRUCTURE bapiret2.
  DATA: END OF bapi_return.

** Bapi PO Detail
  DATA: BEGIN OF wa_po_header OCCURS 1.
          INCLUDE STRUCTURE bapiekkol.
  DATA: END OF wa_po_header.

  DATA: po_items        TYPE bapiekpo OCCURS 0 WITH HEADER LINE,
        po_item_account TYPE bapiekkn OCCURS 0 WITH HEADER LINE,
        po_services     TYPE bapiesll OCCURS 0 WITH HEADER LINE.

  DATA: BEGIN OF bapi_return_po OCCURS 1.
          INCLUDE STRUCTURE bapiret2.
  DATA: END OF bapi_return_po.

** BAPI Release
  DATA: bapi_srv_return TYPE bapireturn1 OCCURS 1 WITH HEADER LINE.
  DATA: serial_no       TYPE bapiesknc-serial_no,
        line_no         TYPE bapiesllc-line_no.

** Nº folha registro de serviços que será gerada
  DATA: g_entrysheet_no TYPE bapiessr-sheet_no.

  DATA: wl_line_no      TYPE bapiesllc-line_no,
        wl_tabix        TYPE sy-tabix.


  REFRESH: po_items, po_services,
           bapi_essr, bapi_eskn, bapi_esll, bapi_eskl,
           zbapi_return_po, zbapi_return_fr, zbapi_srv_return,
           bapi_return_po,  bapi_return, bapi_srv_return.

  CLEAR:   wa_po_header, w_bapi_essr, g_entrysheet_no.


  CALL FUNCTION 'BAPI_PO_GETDETAIL'
    EXPORTING
      purchaseorder              = zebeln
      items                      = c_x
      services                   = c_x
    IMPORTING
      po_header                  = wa_po_header
    TABLES
      po_items                   = po_items
      po_item_account_assignment = po_item_account
      po_item_services           = po_services
      return                     = bapi_return_po.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'.

  " Atualização tabelas de saídas da função
  LOOP AT bapi_return_po WHERE type = c_e.
    zbapi_return_po[]  = bapi_return_po[].
    zbapi_return_fr[]  = bapi_return[].
    zbapi_srv_return[] = bapi_srv_return[].

    return[] = bapi_return_po[].

    LEAVE.
  ENDLOOP.

  " Entry sheet header
  LOOP AT po_items.
    bapi_essr-po_number    = po_items-po_number.
    bapi_essr-po_item      = po_items-po_item.
    bapi_essr-ref_doc_no   = zref_doc_no.     "(Invoice No)
    bapi_essr-ext_number   = zext_number.
    bapi_essr-short_text   = zshort_text.
    bapi_essr-acceptance   = c_x.
    bapi_essr-doc_date     = wa_po_header-doc_date.
    bapi_essr-post_date    = po_items-price_date.

    IF po_items-acctasscat = c_u.
      bapi_essr-accasscat = c_k.
    ELSE.
      bapi_essr-accasscat = po_items-acctasscat.
    ENDIF.
    bapi_essr-pckg_no = po_items-pckg_no.
    APPEND bapi_essr.
    CLEAR bapi_essr.
  ENDLOOP.

  READ TABLE bapi_essr INDEX 1.
  IF sy-subrc IS INITIAL.
    w_bapi_essr-po_number   = bapi_essr-po_number  .
    w_bapi_essr-po_item     = bapi_essr-po_item    .
    w_bapi_essr-ref_doc_no  = bapi_essr-ref_doc_no .
    w_bapi_essr-ext_number  = bapi_essr-ext_number .
    w_bapi_essr-short_text  = bapi_essr-short_text .
    w_bapi_essr-acceptance  = bapi_essr-acceptance .
    w_bapi_essr-doc_date    = bapi_essr-doc_date   .
    w_bapi_essr-post_date   = bapi_essr-post_date  .
    w_bapi_essr-accasscat   = bapi_essr-accasscat  .
    w_bapi_essr-pckg_no     = bapi_essr-pckg_no    .
  ENDIF.

  LOOP AT po_item_account.
    bapi_eskn-serial_no  = po_item_account-serial_no.
    bapi_eskn-gl_account = po_item_account-g_l_acct.
    bapi_eskn-bus_area   = po_item_account-bus_area  .
    bapi_eskn-costcenter = po_item_account-cost_ctr.
    bapi_eskn-sd_doc     = po_item_account-sd_doc    .
    bapi_eskn-itm_number = po_item_account-sdoc_item.
    bapi_eskn-asset_no   = po_item_account-asset_no  .
    bapi_eskn-sub_number = po_item_account-sub_number.
    bapi_eskn-order      = po_item_account-order_no     .
    bapi_eskn-co_area    = po_item_account-co_area   .
    bapi_eskn-to_costctr = po_item_account-to_costctr.
    bapi_eskn-to_order   = po_item_account-to_order  .
    bapi_eskn-to_project = po_item_account-to_project.
    bapi_eskn-cost_obj   = po_item_account-cost_obj  .
    bapi_eskn-prof_seg   = po_item_account-prof_segm .
    bapi_eskn-profit_ctr = po_item_account-profit_ctr.
    bapi_eskn-wbs_elem   = po_item_account-wbs_elem_e  .
    bapi_eskn-network    = po_item_account-network   .
    bapi_eskn-routing_no = po_item_account-routing_no.
    bapi_eskn-rl_est_key = po_item_account-rl_est_key.
    bapi_eskn-counter    = po_item_account-counter   .
    bapi_eskn-part_acct  = po_item_account-part_acct .
    bapi_eskn-cmmt_item  = po_item_account-cmmt_item .
    bapi_eskn-rec_ind    = po_item_account-rec_ind   .
    bapi_eskn-funds_ctr  = po_item_account-funds_ctr .
    bapi_eskn-fund       = po_item_account-fund      .
    bapi_eskn-func_area  = po_item_account-func_area .
    bapi_eskn-grant_nbr  = po_item_account-grant_nbr .
    bapi_eskn-cmmt_item_long = po_item_account-cmmt_item_long.
    bapi_eskn-func_area_long = po_item_account-func_area_long.
    bapi_eskn-activity   = po_item_account-activity.
    APPEND bapi_eskn.
  ENDLOOP.

  " Services items
  line_no = 1.
  LOOP AT po_services.
    bapi_esll-pckg_no    = po_services-pckg_no.
    bapi_esll-line_no    = line_no.
    bapi_esll-ext_line   = po_services-ext_line.
    bapi_esll-outl_ind   = po_services-outl_ind.
    bapi_esll-subpckg_no = po_services-subpckg_no.
    bapi_esll-service    = po_services-service.
    bapi_esll-base_uom   = po_services-base_uom.
    bapi_esll-uom_iso    = po_services-uom_iso.
    bapi_esll-price_unit = po_services-price_unit.
    bapi_esll-from_line  = po_services-from_line.
    bapi_esll-to_line    = po_services-to_line.
    bapi_esll-short_text = po_services-short_text.
    APPEND bapi_esll.
    CLEAR bapi_esll.
    line_no = line_no + 1.
  ENDLOOP.

** Details of Quantity & NetValue.
  wl_line_no = 2.
  LOOP AT bapi_esll.

    IF bapi_esll-line_no = wl_line_no.
      wl_tabix = sy-tabix.

      LOOP AT po_items.
        bapi_esll-quantity = po_items-quantity.
        bapi_esll-gr_price = po_items-gros_value.
        MODIFY bapi_esll INDEX wl_tabix TRANSPORTING quantity gr_price.
      ENDLOOP.

      wl_line_no = wl_line_no + 2.
    ENDIF.

  ENDLOOP.

** Criar Folha de Registro
  CALL FUNCTION 'BAPI_ENTRYSHEET_CREATE'
    EXPORTING
      entrysheetheader            = w_bapi_essr
      testrun                     = ''
    IMPORTING
      entrysheet                  = g_entrysheet_no
    TABLES
      entrysheetaccountassignment = bapi_eskn
      entrysheetservices          = bapi_esll
      entrysheetsrvaccassvalues   = bapi_eskl
      return                      = bapi_return.


  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'.

** Release/Aceite using BAPI.
  CALL FUNCTION 'BAPI_ENTRYSHEET_RELEASE'
    EXPORTING
      entrysheet = g_entrysheet_no
      rel_code   = zrel_code   " 'AA'  "T16FC-FRGCO
    TABLES
      return     = bapi_srv_return
    EXCEPTIONS
      OTHERS     = 0.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'.

* Número da folha de Serviço criada e ano
  materialdocument = g_entrysheet_no.
  matdocumentyear  = sy-datum(04).

  " Atualização tabelas de saídas da função
  zbapi_return_fr[]  = bapi_return[].

  LOOP AT bapi_return WHERE type = c_e.
    return[] = bapi_return[].
  ENDLOOP.

  WAIT UP TO 3 SECONDS.
  COMMIT WORK AND WAIT.

ENDFUNCTION.
