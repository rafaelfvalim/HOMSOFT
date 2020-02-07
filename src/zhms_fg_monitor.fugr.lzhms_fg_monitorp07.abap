*&---------------------------------------------------------------------*
*&       Class (Implementation)  lcl_tree_event_receiver
*&---------------------------------------------------------------------*
*        Handle para tree de atribuição
*----------------------------------------------------------------------*
CLASS lcl_tree_event_receiver IMPLEMENTATION.

  METHOD handle_item_double_click.

*    define local data
      DATA: ls_outtab_atr              TYPE zhms_es_itmview.

*    Call this method to get the values of the selected tree line
      CALL METHOD ob_atr_itens->get_outtab_line
        EXPORTING
          i_node_key     = node_key
        IMPORTING
          e_outtab_line  = ls_outtab_atr
        EXCEPTIONS
          node_not_found = 1
          OTHERS         = 2.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

*  * Chamada para exibição
      PERFORM f_show_atr USING ls_outtab_atr.

  ENDMETHOD.                    "handle_item_double_click

ENDCLASS.               "lcl_tree_event_receiver
