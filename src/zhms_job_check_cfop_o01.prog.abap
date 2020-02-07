*&---------------------------------------------------------------------*
*&  Include           ZHMS_JOB_CHECK_CFOP_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_2000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module STATUS_2000 output.

  SET PF-STATUS 'STATUS_2000'.
  SET TITLEBAR 'TITLE_2000'.

* Instancia o objeto apenas uma vez
*  IF go_grid IS INITIAL.
  IF go_grid IS BOUND.

*    CREATE OBJECT go_event.

    CREATE OBJECT go_grid
      EXPORTING
        container_name              = 'CONTAINER_2000'
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        OTHERS                      = 6.

    CREATE OBJECT go_alv
      EXPORTING
        i_parent          = go_grid
      EXCEPTIONS
        error_cntl_create = 1
        error_cntl_init   = 2
        error_cntl_link   = 3
        error_dp_create   = 4
        OTHERS            = 5.

    wa_layout1-cwidth_opt = abap_true.     " Otimizar tamanho das colunas
    wa_layout1-zebra      = abap_true.     " Zebra
    wa_layout1-no_toolbar = abap_true.     " Sem a barra padrão do ALV
    wa_layout1-no_rowmark = abap_true.     " Sem marcador de linhas
*    wa_layout1-stylefname = 'FIELD_STYLE'. " Campo que receberá estilo

    CALL METHOD go_alv->set_table_for_first_display
      EXPORTING
        is_layout                     = wa_layout1
      CHANGING
        it_outtab                     = it_outtab[] "it_ALV[]
        it_fieldcatalog               = it_fcat1[]
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4.

* Chama o método para o clique no número da NF
*    SET HANDLER go_event->hotspot_click FOR go_alv.

  ENDIF.

endmodule.                 " STATUS_2000  OUTPUT
