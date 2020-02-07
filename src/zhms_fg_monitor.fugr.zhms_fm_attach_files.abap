FUNCTION zhms_fm_attach_files.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  TABLES
*"      DOCMN STRUCTURE  ZHMS_TB_DOCMN
*"----------------------------------------------------------------------
*" RCP - Tradução EN/ES - 31/08/2018

  DATA lo_attachment TYPE REF TO cl_gos_document_service.
  DATA ls_object     TYPE borident.
  DATA lp_attachment TYPE swo_typeid.
  DATA ls_attachment TYPE sibflporb.
  DATA lv_answer     TYPE c.
  DATA ls_docmn      TYPE zhms_tb_docmn.
  DATA lv_type       TYPE swo_typeid  VALUE 'BUS2017'.

  READ TABLE docmn INTO ls_docmn WITH KEY mneum = 'MATDOC'.

  IF sy-subrc IS INITIAL.

    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = text-q01
        text_question         = text-q15
        text_button_1         = text-q03
        icon_button_1         = 'ICON_CHECKED'
        text_button_2         = text-q04
        icon_button_2         = 'ICON_INCOMPLETE'
        default_button        = '2'
        display_cancel_button = ' '
      IMPORTING
        answer                = lv_answer
      EXCEPTIONS
        text_not_found        = 1
        OTHERS                = 2.

    CHECK lv_answer EQ 1.

    CONCATENATE ls_docmn-value sy-datum(4) INTO ls_object-objkey.
    ls_object-objtype = lv_type.

    CREATE OBJECT lo_attachment.
    CALL METHOD lo_attachment->create_attachment
      EXPORTING
        is_object     = ls_object
      IMPORTING
        ep_attachment = lp_attachment.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

  ENDIF.

ENDFUNCTION.
