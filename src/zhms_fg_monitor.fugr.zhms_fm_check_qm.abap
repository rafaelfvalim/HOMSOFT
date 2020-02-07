FUNCTION zhms_fm_check_qm.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  TABLES
*"      RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------
*  DATA: lt_itmatr  TYPE STANDARD TABLE OF zhms_tb_itmatr,
*        ls_itmatr  LIKE LINE OF lt_itmatr,
**        lt_po_bp   TYPE STANDARD TABLE OF bapi2017_gm_purch_doc_ra,
**        ls_po_bp   LIKE LINE OF lt_po_bp,
*        lv_po      TYPE bapiekko-po_number,
*        lt_po_item TYPE STANDARD TABLE OF bapiekpo,
*        lt_header  TYPE STANDARD TABLE OF bapi2017_gm_head_02,
*        lt_item_qm TYPE STANDARD TABLE OF bapi2017_gm_item_show,
*        ls_item_qm LIKE LINE OF lt_item_qm,
*        ls_po_item LIKE LINE OF  lt_po_item,
*        lt_return  TYPE STANDARD TABLE OF bapiret2,
*        ls_return  TYPE bapiret2,
*        lv_itm_txt TYPE char15.
*
*  break junpsamp.
*
*  IF wa_docmn-chave IS NOT INITIAL.
*
*    SELECT * FROM zhms_tb_itmatr INTO TABLE lt_itmatr WHERE chave = vg_chave.
*
*    LOOP AT lt_itmatr INTO ls_itmatr.
*
*      IF ls_itmatr-nrsrf NE lv_po.
*
*        REFRESH lt_po_item[].
*        MOVE ls_itmatr-nrsrf TO lv_po.
*        CALL FUNCTION 'BAPI_PO_GETDETAIL'
*          EXPORTING
*            purchaseorder = lv_po
*            items         = 'X'
*          TABLES
*            po_items      = lt_po_item.
*
*
*        READ TABLE lt_po_item INTO ls_po_item WITH KEY qual_insp = 'X'.
*
*        IF sy-subrc IS INITIAL. " Verifica se este material tem regra para controde de qualidade
*
**          MOVE: 'I'                  TO ls_po_bp-sign,
**                'EQ'                 TO ls_po_bp-option,
**                ls_po_item-po_number TO ls_po_bp-low.
**          APPEND ls_po_bp TO lt_po_bp. CLEAR ls_po_bp.
*
*        ELSE.
*
*          ls_return-type = 'S'.
*          ls_return-message_v1 = 'Concluido'.
*          APPEND ls_return TO return.
*
*        ENDIF.
*      ENDIF.
*
*    ENDLOOP.
*
*
**    IF lt_po_bp[] IS INITIAL.
**      EXIT.
**    ELSE.
**
***      DELETE ADJACENT DUPLICATES FROM lt_po_bp COMPARING ALL FIELDS.
***      CALL FUNCTION 'BAPI_GOODSMVT_GETITEMS'
***        TABLES
***          purch_doc_ra    = lt_po_bp
***          goodsmvt_header = lt_header
***          goodsmvt_items  = lt_item_qm
***          return          = lt_return.
**
**      LOOP AT lt_itmatr INTO ls_itmatr.
**
**        READ TABLE lt_item_qm INTO ls_item_qm WITH KEY po_number  = ls_itmatr-nrsrf
**                                                       po_item    = ls_itmatr-itsrf
**                                                       move_type  = '321'
**                                                       x_auto_cre = ' '.
**
**        IF sy-subrc IS NOT INITIAL.
**          CLEAR lv_itm_txt.
**          MOVE ls_itmatr-itsrf TO lv_itm_txt.
**          CONCATENATE 'O Item:' lv_itm_txt
**                      'referente ao pedido de compras:' ls_itmatr-nrsrf
**                      'ainda encontra-se bloqueado por QM' INTO
**                       ls_return-message_v1 SEPARATED BY space.
**          APPEND ls_return TO return.CLEAR ls_return.
**          EXIT.
**        ENDIF.
**
**      ENDLOOP.
**
**      IF return[] IS INITIAL.
**        ls_return-type = 'S'.
**        ls_return-message_v1 = 'Documento liberado por QM'.
**        APPEND ls_return TO return.
**      ENDIF.
**
**    ENDIF.
*  ENDIF.

ENDFUNCTION.
