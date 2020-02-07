FUNCTION zhms_envia_email_forn.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(EMAIL) TYPE  CHAR255 OPTIONAL
*"     VALUE(NNF) TYPE  CHAR20 OPTIONAL
*"     VALUE(CNPJ) TYPE  STCD1 OPTIONAL
*"----------------------------------------------------------------------
*"RCP - Tradução EN/ES - 30/08/2018

  DATA: it_receivers       TYPE STANDARD TABLE OF  somlreci1,
        wa_it_receivers    LIKE LINE OF it_receivers,
        it_packing_list    TYPE STANDARD TABLE OF  sopcklsti1,
        gd_doc_data        TYPE sodocchgi1,
        wa_it_packing_list LIKE LINE OF  it_packing_list,
        psubject(90)       TYPE c,
        it_message         TYPE STANDARD TABLE OF solisti1,
        wa_it_message      LIKE LINE OF it_message,
        num_lines          TYPE i,
        lv_notax           TYPE zhms_de_mneum,
        lv_nota            TYPE char10,
        lv_parid           TYPE j_1bparid,
        lv_name_text       TYPE name1_gp,
        c1(99)             TYPE c,
        c2(200)            TYPE c,
        lv_desc_etapa      TYPE char255,
        lv_name_user       TYPE char255,
        lt_return          TYPE STANDARD TABLE OF bapiret2.

*** Move numero da nota fiscal
  MOVE nnf TO lv_nota.

*** busca dados do parceiro
  SELECT SINGLE name1 INTO c2 FROM lfa1 WHERE stcd1 = cnpj.

  FREE wa_it_receivers.
  wa_it_receivers-receiver   = email.
  wa_it_receivers-rec_type   = 'U'.
  wa_it_receivers-com_type   = 'INT'.
  wa_it_receivers-notif_del  = 'X'.
  wa_it_receivers-notif_ndel = 'X'.
  APPEND wa_it_receivers TO it_receivers .
  DESCRIBE TABLE it_receivers LINES num_lines.
  "&--- Check the Sender lv_email id or SAP User id is got or not.
  IF NOT num_lines IS INITIAL.
*&---------------------------------------------------------------------
* Add thetext to mail text table
*&----------------------------------------------------------------------
*&-- Subject of the mail -------------&*
MOVE:'Recepção automática de documentos eletrônicos - HomSoft' TO
psubject.
*&--  body  of the mail ----------------&*
    CLEAR wa_it_message.
    c1 = 'Caro fornecedor'.

    CONCATENATE c1 c2 ',' INTO
    wa_it_message-line SEPARATED BY space.
    APPEND wa_it_message TO it_message.
*** insert Blank Line *********************************************
    CLEAR wa_it_message.
    wa_it_message-line = '                               '.
    APPEND wa_it_message TO it_message.
******* Assign your Text  below ****************  *********************
    CLEAR wa_it_message.
  CONCATENATE 'Foi Recepcionado em nosso sitema a nota fiscal:' lv_nota 'que não contém no XML(ou estão com valores errados) as TAGS XPED(Númerodo Pedido de compras) e NITEM(Item do pedido de compras).'INTO
wa_it_message-line SEPARATED BY space.
    APPEND wa_it_message TO it_message.
*** insert Blank Line{} *********************************************
    CLEAR wa_it_message.
    wa_it_message-line = '                                        '.
    APPEND wa_it_message TO it_message.
******** Assign your Text  below *************************************
    CLEAR wa_it_message.
wa_it_message-line = 'Para maiores informações favor entrar em contato com o comprador responsável.'.
    APPEND wa_it_message TO it_message.
*** insert Blank Line{} *********************************************
    CLEAR wa_it_message.
    wa_it_message-line = '                                        '.
    APPEND wa_it_message TO it_message.
    gd_doc_data-doc_size = 1.
*** insert Blank Line{} *********************************************
    CLEAR wa_it_message.
    wa_it_message-line = '                                        '.
    APPEND wa_it_message TO it_message.
*** insert Blank Line{} *********************************************
    CLEAR wa_it_message.
    wa_it_message-line = '                                        '.
    APPEND wa_it_message TO it_message.
*** insert Blank Line{} *********************************************
    CLEAR wa_it_message.
    wa_it_message-line = '                                        '.
    APPEND wa_it_message TO it_message.
*** insert Blank Line{} *********************************************
    CLEAR wa_it_message.
    wa_it_message-line = '                                        '.
    APPEND wa_it_message TO it_message.
*** insert rodapé{} *********************************************
    CLEAR wa_it_message.
    wa_it_message-line = 'Não é necessário'.
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

*&------ Call the Function Module to send the message to External and
*  sap inbox
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

ENDFUNCTION.
