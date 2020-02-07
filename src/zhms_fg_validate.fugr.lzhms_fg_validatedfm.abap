*&---------------------------------------------------------------------*
*&  Include           LZHMS_FG_VALIDATEDFM
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  f_valid_01
*&---------------------------------------------------------------------*
FORM f_valid_01.
**    Variaveis locais
  DATA: vl_ebeln TYPE ekbe-ebeln,
        vl_ebelp TYPE ekbe-ebelp.

**    Verifica se tabela de cabeçalho está vazia
  CHECK NOT wa_cabdoc IS INITIAL.

**    Percorre a tabela de itens
  LOOP AT it_itmdoc INTO wa_itmdoc.

**      Percorre a lista de atribuições
    LOOP AT it_itmatr INTO wa_itmatr WHERE dcitm EQ wa_itmdoc-dcitm.
**         Limpa as tabelas internas
      CLEAR: poheader, poexpimpheader.

      REFRESH: po1_return, poitem, poaddrdelivery, poschedule, poaccount, pocondheader, pocond,
               polimits, pocontractlimits, poservices, posrvaccessvalues, potextheader, potextitem,
               poexpimpitem, pocomponents, poshippingexp, pohistory, pohistory_totals, poconfirmation,
               allversions, popartner, extensionout, serialnumber, invplanheader, invplanitem, pohistory_ma.

**        Verifica se o tipo de documento é pedido
      CHECK wa_itmatr-tdsrf EQ 1.

**        Move o numero do pedido para variável com tipo compatível
      MOVE wa_itmatr-nrsrf TO vl_ebeln.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = vl_ebeln
        IMPORTING
          output = vl_ebeln.

**        Realiza chamada da BAPI
      CALL FUNCTION 'BAPI_PO_GETDETAIL1'
        EXPORTING
          purchaseorder      = vl_ebeln
          account_assignment = 'X'
          item_text          = 'X'
          header_text        = 'X'
          delivery_address   = 'X'
          version            = 'X'
          services           = 'X'
          serialnumbers      = 'X'
          invoiceplan        = 'X'
        IMPORTING
          poheader           = poheader
          poexpimpheader     = poexpimpheader
        TABLES
          return             = po1_return
          poitem             = poitem
          poaddrdelivery     = poaddrdelivery
          poschedule         = poschedule
          poaccount          = poaccount
          pocondheader       = pocondheader
          pocond             = pocond
          polimits           = polimits
          pocontractlimits   = pocontractlimits
          poservices         = poservices
          posrvaccessvalues  = posrvaccessvalues
          potextheader       = potextheader
          potextitem         = potextitem
          poexpimpitem       = poexpimpitem
          pocomponents       = pocomponents
          poshippingexp      = poshippingexp
          pohistory          = pohistory
          pohistory_totals   = pohistory_totals
          poconfirmation     = poconfirmation
          allversions        = allversions
          popartner          = popartner
          extensionout       = extensionout
          serialnumber       = serialnumber
          invplanheader      = invplanheader
          invplanitem        = invplanitem
          pohistory_ma       = pohistory_ma.

**        Move o item do pedido para variável com tipo compatível
      MOVE wa_itmatr-itsrf TO vl_ebelp.

**        Seta os ponteiros
      READ TABLE poitem            WITH KEY po_item = vl_ebelp.
      READ TABLE poaddrdelivery    WITH KEY po_item = vl_ebelp.
      READ TABLE poschedule        WITH KEY po_item = vl_ebelp.
      READ TABLE poaccount         WITH KEY po_item = vl_ebelp.
      READ TABLE potextheader      WITH KEY po_item = vl_ebelp.
      READ TABLE potextitem        WITH KEY po_item = vl_ebelp.
      READ TABLE poexpimpitem      WITH KEY po_item = vl_ebelp.
      READ TABLE pocomponents      WITH KEY po_item = vl_ebelp.
      READ TABLE poshippingexp     WITH KEY po_item = vl_ebelp.
      READ TABLE pohistory         WITH KEY po_item = vl_ebelp.
      READ TABLE pohistory_totals  WITH KEY po_item = vl_ebelp.
      READ TABLE poconfirmation    WITH KEY po_item = vl_ebelp.
      READ TABLE serialnumber      WITH KEY po_item = vl_ebelp.
      READ TABLE pohistory_ma      WITH KEY po_item = vl_ebelp.

**    Executa a validação do item
      PERFORM f_validar_gpr USING '30'
                                 wa_itmatr.

    ENDLOOP.
  ENDLOOP.

**   Executa a validação de cabeçalho
  CLEAR wa_itmatr.
  PERFORM f_validar_gpr USING '10'
                             wa_itmatr.
ENDFORM.                                                    "f_valid_01
