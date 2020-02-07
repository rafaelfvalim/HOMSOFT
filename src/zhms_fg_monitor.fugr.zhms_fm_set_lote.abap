FUNCTION zhms_fm_set_lote.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(PO) TYPE  ZHMS_DE_NRSRF
*"     VALUE(ITEM) TYPE  ZHMS_DE_ITSRF
*"  EXPORTING
*"     VALUE(LOTE) TYPE  CHAR14
*"----------------------------------------------------------------------

  CHECK po IS NOT INITIAL AND item IS NOT INITIAL.

  DATA: lv_item TYPE char4,
        lv_po   TYPE char15,
        len     TYPE i.

*** Trata numero do PO
  MOVE po TO lv_po.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = lv_po
    IMPORTING
      output = lote.

  CONDENSE lote NO-GAPS.

*** Trata Item
  MOVE item TO lv_item.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = lv_item
    IMPORTING
      output = lv_item.

  CONDENSE lv_item NO-GAPS.

  len = strlen( lv_item ).

  CASE len.
    WHEN 2.
      CONCATENATE lote '/' '0' lv_item(1) INTO lote.
    WHEN 3.
      CONCATENATE lote '/' lv_item+1(1) lv_item+2(1) INTO lote.
    WHEN 4.
      CONCATENATE lote '/' lv_item+1(2) lv_item+2(1) INTO lote.
  ENDCASE.


ENDFUNCTION.
