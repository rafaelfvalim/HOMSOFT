FUNCTION zhms_create_attachment_migo.
*"----------------------------------------------------------------------
*"*"Interface local:
*"----------------------------------------------------------------------

  DATA lo_attachment TYPE REF TO cl_gos_document_service.
  DATA ls_object     TYPE borident.
  DATA lp_attachment TYPE swo_typeid.
  DATA ls_attachment TYPE sibflporb.

*  IF v_chave IS INITIAL.
*    MOVE chave TO v_chave.
*  ENDIF.

  ls_object-objkey  = '50000005632014'.
  ls_object-objtype = 'BUS2017'.

  CREATE OBJECT lo_attachment.
  CALL METHOD lo_attachment->create_attachment
    EXPORTING
      is_object     = ls_object
    IMPORTING
      ep_attachment = lp_attachment.

  IF lp_attachment IS INITIAL.
*    MESSAGE s042(sgos_msg).
  ELSEIF ls_object-objkey IS INITIAL AND
     NOT lp_attachment IS INITIAL.
*    ls_attachment-instid = lp_attachment.
*    ls_attachment-typeid = 'MESSAGE'.
*    ls_attachment-catid = 'BO'.
*    APPEND ls_attachment TO gt_attachments.
  ELSE.
*    MESSAGE s043(sgos_msg).
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
  ENDIF.

ENDFUNCTION.
