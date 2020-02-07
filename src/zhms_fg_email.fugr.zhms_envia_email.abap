FUNCTION zhms_envia_email.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(CHAVE) TYPE  ZHMS_DE_CHAVE OPTIONAL
*"     VALUE(USUARIO) TYPE  SY-UNAME OPTIONAL
*"     REFERENCE(NATDC) TYPE  ZHMS_DE_NATDC OPTIONAL
*"     REFERENCE(TYPED) TYPE  ZHMS_DE_TYPED OPTIONAL
*"     REFERENCE(ETAPA) TYPE  ZHMS_DE_FLOWD OPTIONAL
*"     REFERENCE(OTHERS) TYPE  FLAG OPTIONAL
*"     REFERENCE(TITULO) TYPE  STRING OPTIONAL
*"     REFERENCE(CORPO) TYPE  STRING OPTIONAL
*"----------------------------------------------------------------------
*"RCP - Tradução EN/ES - 30/08/2018

  DATA:it_receivers       TYPE STANDARD TABLE OF  somlreci1,
       wa_it_receivers    LIKE LINE OF it_receivers,
       it_packing_list    TYPE STANDARD TABLE OF  sopcklsti1,
       gd_doc_data        TYPE sodocchgi1,
       wa_it_packing_list LIKE LINE OF  it_packing_list,
       psubject(90)       TYPE c,
       it_message         TYPE STANDARD TABLE OF solisti1,
       wa_it_message      LIKE LINE OF it_message,
       c1(99)             TYPE c,
       c2(200)            TYPE c,
       num_lines          TYPE i,
       lv_notax           TYPE zhms_de_mneum,
       lv_nota            TYPE char10,
       lv_parid           TYPE j_1bparid,
       lv_name_text       TYPE name1_gp,
       lv_desc_etapa      TYPE string,
       lv_name_user       TYPE string,
       lv_email           TYPE string.

  IF others IS INITIAL.

    IF lv_email IS INITIAL.
      CALL FUNCTION 'EFG_GEN_GET_USER_EMAIL'
        EXPORTING
          i_uname         = usuario
        IMPORTING
          e_email_address = lv_email.
    ENDIF.

*** Seleciona Mneumonico da Nota Fiscal
    SELECT SINGLE value FROM zhms_tb_docmn INTO lv_notax WHERE chave EQ chave
                                                           AND mneum EQ 'NNF'.

*** Completa numero de nota com zeros
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = lv_notax
      IMPORTING
        output = lv_nota.

*** Seleciona Fornecedor
    SELECT SINGLE parid FROM zhms_tb_cabdoc INTO lv_parid WHERE chave EQ chave.
*** Busca Nome texto fornecedor
    SELECT SINGLE name1 FROM lfa1 INTO lv_name_text WHERE lifnr EQ lv_parid.
*** Busca Nome Usuario
    CALL FUNCTION 'CFX_API_USER_GETDETAIL'
      EXPORTING
        i_user_id  = usuario
      IMPORTING
        e_fullname = lv_name_user.

    MOVE lv_name_user TO c2.

*** Busca Descrição etapa
    SELECT SINGLE denom FROM zhms_tx_scen_flo INTO lv_desc_etapa WHERE natdc  EQ natdc
                                                                   AND typed  EQ typed
                                                                   AND flowd  EQ etapa
                                                                   AND spras  EQ sy-langu.

    FREE wa_it_receivers.
    wa_it_receivers-receiver   = lv_email.
    wa_it_receivers-rec_type   = 'U'.
    wa_it_receivers-com_type   = 'INT'.
    wa_it_receivers-notif_del  = 'X'.
    wa_it_receivers-notif_ndel = 'X'.
    APPEND wa_it_receivers TO it_receivers .
    DESCRIBE TABLE it_receivers LINES num_lines.
    "&--- Check the Sender lv_email id or SAP User id is got or not.
    IF num_lines IS NOT INITIAL.
*&---------------------------------------------------------------------
* Add thetext to mail text table
*&----------------------------------------------------------------------
*&-- Subject of the mail -------------&*
      CONCATENATE 'Nota' lv_nota 'do fornecedor' lv_parid '- HomSoft'
      INTO psubject SEPARATED BY space.
*&--  body  of the mail ----------------&*
      CLEAR wa_it_message.
      c1 = 'Caro usuário'.
*    c2 =
      CONCATENATE c1 c2 ',' INTO
      wa_it_message-line SEPARATED BY space.
      APPEND wa_it_message TO it_message.
*** insert Blank Line *********************************************
      CLEAR wa_it_message.
      wa_it_message-line = '                               '.
      APPEND wa_it_message TO it_message.
******* Assign your Text  below ****************  *********************
      CLEAR wa_it_message.
      CONCATENATE 'A etapa' etapa '-' '"'lv_desc_etapa'",' 'referente a nota'
      lv_nota 'do fornecedor' lv_parid '-' lv_name_text 'encontra-se pendente no HomSoft.' INTO  wa_it_message-line SEPARATED BY space.
      APPEND wa_it_message TO it_message.
*** insert Blank Line{} *********************************************
      CLEAR wa_it_message.
      wa_it_message-line = '                                        '.
      APPEND wa_it_message TO it_message.
******** Assign your Text  below *************************************
      CLEAR wa_it_message.
      wa_it_message-line = 'Aguardando sua tomada de ação.'.
      APPEND wa_it_message TO it_message.
      gd_doc_data-doc_size = 1.
*Populate the subject/generic message attributes
      gd_doc_data-obj_langu = sy-langu.
      gd_doc_data-obj_name = 'SAPRPT'.
      gd_doc_data-obj_descr = psubject.
      gd_doc_data-sensitivty = 'F'.
*Describe the body of the message
      CLEAR wa_it_packing_list.
      REFRESH it_packing_list.
      wa_it_packing_list-transf_bin = space.
      wa_it_packing_list-head_start = 1.
      wa_it_packing_list-head_num = 0.
      wa_it_packing_list-body_start = 1.
      DESCRIBE TABLE it_message LINES wa_it_packing_list-body_num.
      wa_it_packing_list-doc_type = 'RAW'.
      APPEND wa_it_packing_list TO it_packing_list.


    ENDIF.

  ELSE.

    IF lv_email IS INITIAL.
      CALL FUNCTION 'EFG_GEN_GET_USER_EMAIL'
        EXPORTING
          i_uname         = usuario
        IMPORTING
          e_email_address = lv_email.
    ENDIF.

    CALL FUNCTION 'CFX_API_USER_GETDETAIL'
      EXPORTING
        i_user_id  = usuario
      IMPORTING
        e_fullname = lv_name_user.

    FREE wa_it_receivers.
    wa_it_receivers-receiver   = lv_email.
    wa_it_receivers-rec_type   = 'U'.
    wa_it_receivers-com_type   = 'INT'.
    wa_it_receivers-notif_del  = 'X'.
    wa_it_receivers-notif_ndel = 'X'.
    APPEND wa_it_receivers TO it_receivers .
    DESCRIBE TABLE it_receivers LINES num_lines.

    IF num_lines IS NOT INITIAL.
      MOVE lv_name_user TO c2.
      MOVE titulo TO psubject.

      CLEAR wa_it_message.
      c1 = 'Caro usuário'.
      CONCATENATE c1 c2 ',' INTO
      wa_it_message-line SEPARATED BY space.
      APPEND wa_it_message TO it_message.

*** insert Blank Line *********************************************
      CLEAR wa_it_message.
      wa_it_message-line = '                               '.
      APPEND wa_it_message TO it_message.

      CLEAR wa_it_message.
      wa_it_message-line = corpo.
      APPEND wa_it_message TO it_message.

*Populate the subject/generic message attributes
      gd_doc_data-obj_langu = sy-langu.
      gd_doc_data-obj_name = 'SAPRPT'.
      gd_doc_data-obj_descr = psubject.
      gd_doc_data-sensitivty = 'F'.
*Describe the body of the message
      CLEAR wa_it_packing_list.
      REFRESH it_packing_list.
      wa_it_packing_list-transf_bin = space.
      wa_it_packing_list-head_start = 1.
      wa_it_packing_list-head_num = 0.
      wa_it_packing_list-body_start = 1.
      DESCRIBE TABLE it_message LINES wa_it_packing_list-body_num.
      wa_it_packing_list-doc_type = 'RAW'.
      APPEND wa_it_packing_list TO it_packing_list.
    ENDIF.
  ENDIF.

*&------ Call the Function Module to send the message to External and SAP Inbox
  CALL FUNCTION 'SO_NEW_DOCUMENT_ATT_SEND_API1'
    EXPORTING
      document_data              = gd_doc_data
      put_in_outbox              = 'X'
      commit_work                = 'X'
    TABLES
      packing_list               = it_packing_list
      contents_txt               = it_message
      receivers                  = it_receivers
    EXCEPTIONS
      too_many_receivers         = 1
      document_not_sent          = 2
      document_type_not_exist    = 3
      operation_no_authorization = 4
      parameter_error            = 5
      x_error                    = 6
      enqueue_error              = 7
      OTHERS                     = 8.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFUNCTION.
