*----------------------------------------------------------------------*
*                      H  o  m  S  o  f  t                             *
*          Gestão Eletrônica de Documentos e Processos                 *
*----------------------------------------------------------------------*
* Descrição: Monitor Central de Gerenciamento de Documentos            *
*            Classes (Validações)                                      *
*----------------------------------------------------------------------*


CLASS lcl_vld_event_receiver IMPLEMENTATION.

  METHOD handle_item_double_click.

*    define local data
    DATA: ls_outtab_vld              TYPE zhms_es_hvalid.

*    Call this method to get the values of the selected tree line
    CALL METHOD ob_hvalid->get_outtab_line
      EXPORTING
        i_node_key     = node_key
      IMPORTING
        e_outtab_line  = ls_outtab_vld
      EXCEPTIONS
        node_not_found = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

**   chamada para exibição
    PERFORM f_show_vld USING ls_outtab_vld.

  ENDMETHOD.                    "handle_vld_double_click

ENDCLASS.               "lcl_tree_event_receiver
