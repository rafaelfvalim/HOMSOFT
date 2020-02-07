*&---------------------------------------------------------------------*
*& Report ZHMS_RP_STATUS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zhms_rp_status.
* TABLES
TABLES: zhms_tb_status.

*---- Internal tables -----
DATA: t_alv TYPE STANDARD TABLE OF zhms_tb_status.
DATA: w_alv LIKE LINE OF t_alv.
* ---- SELECTION-SCREEN -----------
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01.
SELECT-OPTIONS: s_zctet FOR zhms_tb_status-zctet,
                s_zfatt FOR zhms_tb_status-zfatt,
                s_erdat FOR zhms_tb_status-erdat NO INTERVALS.

SELECTION-SCREEN END OF BLOCK b1.
*------------------------------------------------------------------------
*   class lcl_event_handler DEFINITION
*------------------------------------------------------------------------
CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    METHODS: on_double_click FOR EVENT double_click
                  OF cl_salv_events_table
      IMPORTING row column.
ENDCLASS.
*-------------------------------------------------------------------------
*  CLASS  lcl_event_handler  IMPLEMENTATION
*--------------------------------------------------------------------------
CLASS lcl_event_handler IMPLEMENTATION.
  METHOD on_double_click.
    PERFORM get_info_calltransaction USING row column.
*    DATA: row_c(4) TYPE c.
*    DATA: lr_selections TYPE REF TO cl_salv_selections.
*    row_c = row.
*    READ TABLE t_alv INDEX row_c INTO w_alv.
*    SET PARAMETER ID 'BES' FIELD w_alv-ebeln.
*    CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.

  ENDMETHOD.
ENDCLASS.


START-OF-SELECTION.
  PERFORM f_seleciona_dados.
  PERFORM f_exibir_alv.

END-OF-SELECTION.
*&---------------------------------------------------------------------*
*&      Form  F_SELECIONA_DADOS
*&---------------------------------------------------------------------*
FORM f_seleciona_dados .

  SELECT * FROM zhms_tb_status
           INTO TABLE t_alv
           WHERE zctet IN s_zctet AND
                 zfatt IN s_zfatt AND
  erdat IN s_erdat.

  IF sy-subrc IS NOT INITIAL.
* Não há dados nos parametros informados
    MESSAGE TEXT-001 TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
    RETURN.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_EXIBIR_ALV
*&---------------------------------------------------------------------*
FORM f_exibir_alv.
  DATA: o_table         TYPE REF TO cl_salv_table,
        o_layout        TYPE REF TO cl_salv_layout,
        o_columns       TYPE REF TO cl_salv_columns_table,
        o_column        TYPE REF TO cl_salv_column,
        o_functions     TYPE REF TO cl_salv_functions,
        o_display       TYPE REF TO cl_salv_display_settings,
        o_events        TYPE REF TO cl_salv_events_table,
        o_event_handler TYPE REF TO lcl_event_handler.


  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = o_table
                               CHANGING t_table = t_alv ).
    CATCH cx_salv_msg.
  ENDTRY.

* Set event handling double click
  o_events = o_table->get_event( ).
  CREATE OBJECT o_event_handler.
  SET HANDLER o_event_handler->on_double_click FOR o_events.
* Tool-bar standard
  o_functions = o_table->get_functions( ).
  o_functions->set_all( abap_true ).

* Inserir cabeçalho.
  o_display = o_table->get_display_settings( ).
  o_display->set_list_header( TEXT-002 ). "Controle de Status - Frete

* Otimiza colunas.
  o_columns = o_table->get_columns( ).
  o_columns->set_optimize( 'X' ).

*define a coluna
  o_columns = o_table->get_columns( ).
  TRY.
      o_column ?= o_columns->get_column( 'BELNR' ).
* define texto da coluna
      o_column->set_long_text( TEXT-003 ).   "Entrada Fatura-MIRO
      o_column->set_medium_text( TEXT-004 ). "Entr.Fatura-MIRO
      o_column->set_short_text( TEXT-005 ).  "Fat.MIRO

* Não exibir as colunas
      o_column ?= o_columns->get_column( columnname = 'MANDT' ).
      o_column->set_visible( value = if_salv_c_bool_sap=>false ).
      o_column ?= o_columns->get_column( columnname = 'NFENUM' ).
      o_column->set_visible( value = if_salv_c_bool_sap=>false ).
      o_column ?= o_columns->get_column( columnname = 'ZSTMI' ).
      o_column->set_visible( value = if_salv_c_bool_sap=>false ).
      o_column ?= o_columns->get_column( columnname = 'ZSTNF' ).
      o_column->set_visible( value = if_salv_c_bool_sap=>false ).
    CATCH cx_salv_not_found.
  ENDTRY.

  o_columns->set_column_position( columnname = 'ZFATT' position = 1 ).

  o_table->display( ).

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_INFO_CALLTRANSACTION
*&---------------------------------------------------------------------*
FORM get_info_calltransaction  USING  row TYPE salv_de_row
                                      column TYPE salv_de_column.

  DATA: row_c(4) TYPE c.
  DATA: lr_selections TYPE REF TO cl_salv_selections.
  row_c = row.
  READ TABLE t_alv INDEX row_c INTO w_alv.

  CASE column.
    WHEN 'EBELN' .
      if not w_alv-ebeln is initial.
      SET PARAMETER ID 'BES' FIELD w_alv-ebeln.
      CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
      endif.
    WHEN 'FKNUM'.
      if not w_alv-fknum is initial.
      SET PARAMETER ID 'FKK' FIELD w_alv-fknum.
      CALL TRANSACTION 'VI03' AND SKIP FIRST SCREEN.
      endif.
    WHEN 'TKNUM'.
      SET PARAMETER ID 'TNR' FIELD w_alv-tknum.
      CALL TRANSACTION 'VT03N' AND SKIP FIRST SCREEN.
    WHEN 'BELNR'.
      if not w_alv-belnr is initial.
      SET PARAMETER ID 'RBN' FIELD w_alv-BELNR.
      CALL TRANSACTION 'MIR4' AND SKIP FIRST SCREEN.
      endif.

    WHEN 'DOCNUM'.
      if not w_alv-docnum is initial.
      SET PARAMETER ID 'JEF' FIELD w_alv-docnum.
      CALL TRANSACTION 'J1B3N' AND SKIP FIRST SCREEN.
      endif.
    WHEN OTHERS.

  ENDCASE.
ENDFORM.
