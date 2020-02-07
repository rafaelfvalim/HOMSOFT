FUNCTION zhms_fm_ml81n.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  TABLES
*"      RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------
*** Chama numero do pedido de compras que foi atribuido
  SELECT * FROM zhms_tb_itmatr INTO TABLE lt_atribuicao WHERE chave EQ wa_cabdoc-chave.

  CHECK sy-subrc IS INITIAL.

  LOOP AT lt_atribuicao INTO ls_atribuicao.

*** Busca informações sobre o pedido de compras
    CLEAR: lv_ebeln, wa_po_header, po_items[], po_services[], bapi_return_po[].

    MOVE ls_atribuicao-nrsrf TO lv_ebeln.

    CALL FUNCTION 'BAPI_PO_GETDETAIL'
      EXPORTING
        purchaseorder    = lv_ebeln
        items            = 'X'
        services         = 'X'
      IMPORTING
        po_header        = wa_po_header
      TABLES
        po_items         = po_items
        po_item_services = po_services
        return           = bapi_return_po.

*** Items do pedido de compras
    LOOP AT po_items.
      bapi_essr-po_number   = po_items-po_number.
      bapi_essr-po_item     = po_items-po_item.
      bapi_essr-ref_doc_no  = lv_ebeln.
*    bapi_essr-short_text = essr-txz01.
      bapi_essr-acceptance  = abap_true.
      bapi_essr-doc_date    = wa_po_header-doc_date.
      bapi_essr-post_date   = po_items-price_date.
      IF po_items-acctasscat = 'U'.
        bapi_essr-accasscat = 'K'.
      ELSE.
        bapi_essr-accasscat = po_items-acctasscat.
      ENDIF.
      bapi_essr-pckg_no     = po_items-pckg_no.
      APPEND bapi_essr.
    ENDLOOP.

*** Soma linha do item de serviço
    line_no = 1.

*** Itens de serviço
    LOOP AT po_services.
      CLEAR bapi_esll.
      bapi_esll-pckg_no     = po_services-pckg_no.
      bapi_esll-line_no     = line_no.
      bapi_esll-ext_line    = po_services-ext_line.
      bapi_esll-outl_ind    = po_services-outl_ind.
      bapi_esll-subpckg_no  = po_services-subpckg_no.
      bapi_esll-service     = po_services-service.
      bapi_esll-base_uom    = po_services-base_uom.
      bapi_esll-uom_iso     = po_services-uom_iso.
      bapi_esll-price_unit  = po_services-price_unit.
      bapi_esll-from_line   = po_services-from_line.
      bapi_esll-to_line     = po_services-to_line.
      bapi_esll-short_text  = po_services-short_text.
      APPEND bapi_esll.
      line_no = line_no + 1.                                      "Outline
    ENDLOOP.

*** Quantidade de valores
    LOOP AT bapi_esll.
      IF bapi_esll-line_no  = '2'.
        bapi_esll-quantity  = 1.
        bapi_esll-gr_price  = 1.
        MODIFY bapi_esll INDEX sy-tabix TRANSPORTING quantity gr_price.
      ENDIF.
    ENDLOOP.

  ENDLOOP.

*** Chamada função cria FOLHA DE REGISTRO e MIGO
    CALL FUNCTION 'BAPI_ENTRYSHEET_CREATE'
      EXPORTING
        entrysheetheader            = bapi_essr
        testrun                     = ''
      IMPORTING
        entrysheet                  = g_entrysheet_no
      TABLES
        entrysheetaccountassignment = bapi_eskn
        entrysheetservices          = bapi_esll
        entrysheetsrvaccassvalues   = bapi_eskl
        return                      = bapi_return.

    READ TABLE bapi_return INTO ls_return WITH KEY type = 'E'.

    IF sy-subrc IS INITIAL.
*** Monta erro
      MOVE bapi_return[] TO return[].
      EXIT.

    ELSE.

      READ TABLE bapi_return INTO ls_return WITH KEY type = 'S'.

      IF sy-subrc IS INITIAL.
*** Monta sucesso
        MOVE bapi_return[] TO return[].

*** Grava folha de registro e migo
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
        CALL FUNCTION 'BUFFER_REFRESH_ALL' .

      ENDIF.
    ENDIF.

  ENDFUNCTION.
