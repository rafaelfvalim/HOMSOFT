FUNCTION zhms_change_po_remessa_final.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(CHAVE) TYPE  ZHMS_DE_CHAVE OPTIONAL
*"----------------------------------------------------------------------

  DATA: lt_atrib    TYPE STANDARD TABLE OF zhms_tb_itmatr,
        lt_atribx   TYPE STANDARD TABLE OF zhms_tb_itmatr,
        ls_atrib    LIKE LINE OF lt_atrib,
        ls_atribx   LIKE LINE OF lt_atrib,
        lt_poitem   TYPE STANDARD TABLE OF bapimepoitem,
        ls_poitem   LIKE LINE OF lt_poitem,
        lt_return   TYPE STANDARD TABLE OF bapiret2,
        ls_return   LIKE LINE OF lt_return,
        lt_poitemx  TYPE STANDARD TABLE OF bapimepoitemx,
        ls_poitemx  LIKE LINE OF lt_poitemx,
        ls_ekko     TYPE ekko,
        ls_eket     TYPE eket,
        lv_pendente TYPE etmen,
        ls_cabdoc   TYPE zhms_tb_cabdoc,
        ls_docmnx   TYPE zhms_tb_docmn.

  DATA: lv_po      TYPE bapimepoheader-po_number.

  IF v_chave IS INITIAL.
    MOVE chave TO v_chave.
  ENDIF.

*** verifica se o processo é valido
  SELECT SINGLE * FROM zhms_tb_cabdoc INTO ls_cabdoc WHERE chave EQ v_chave.

  IF ls_cabdoc-typed EQ 'CTE'.
    EXIT.
  ELSE.
*** Verifica se existiu MIGO
    SELECT SINGLE * FROM zhms_tb_docmn INTO ls_docmnx WHERE chave EQ v_chave
                                                 AND mneum EQ 'MATDOC'.
    IF sy-subrc IS NOT INITIAL.
      EXIT.
    ENDIF.
  ENDIF.


*** Verifica o Pedido de compras
  REFRESH lt_atrib[].
  SELECT * FROM zhms_tb_itmatr INTO TABLE lt_atrib WHERE chave EQ v_chave.

  IF sy-subrc IS INITIAL.
    MOVE lt_atrib[] TO lt_atribx[].
    DELETE ADJACENT DUPLICATES FROM lt_atribx COMPARING nrsrf.
    LOOP AT lt_atribx INTO ls_atribx.
      LOOP AT lt_atrib INTO ls_atrib WHERE nrsrf EQ ls_atribx-nrsrf.

        CLEAR: ls_eket, lv_pendente.
        SELECT SINGLE * FROM eket INTO ls_eket WHERE ebeln EQ ls_atribx-nrsrf
                                                 AND ebelp EQ ls_atrib-itsrf.

*** Verifica se a quantidade do item doi totalmente consumida, caso não, o item não será flegado
        lv_pendente = ( ls_eket-menge - ls_eket-wemng ).
        IF lv_pendente IS INITIAL.

          ls_poitem-po_item     = ls_atrib-itsrf.
          ls_poitem-no_more_gr  = 'X'.
          APPEND ls_poitem TO lt_poitem.

          ls_poitemx-po_item    = ls_atrib-itsrf.
          ls_poitemx-no_more_gr = 'X'.
          APPEND ls_poitemx TO lt_poitemx.

        ELSE.

          CONTINUE.

        ENDIF.

      ENDLOOP.

      MOVE ls_atrib-nrsrf TO lv_po.
      CALL FUNCTION 'BAPI_PO_CHANGE'
        EXPORTING
          purchaseorder = lv_po
        TABLES
          return        = lt_return
          poitem        = lt_poitem
          poitemx       = lt_poitemx.

      READ TABLE lt_return INTO ls_return WITH KEY type = 'E'.

      IF sy-subrc IS INITIAL.

        MESSAGE ls_return-message TYPE 'E'.
        EXIT.

      ELSE.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

      ENDIF.

      REFRESH: lt_poitem, lt_poitemx, lt_return.
      CLEAR: ls_poitem, ls_poitemx, lv_po.

    ENDLOOP.
  ENDIF.

ENDFUNCTION.
