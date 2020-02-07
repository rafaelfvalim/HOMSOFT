*&---------------------------------------------------------------------*
*& Report  ZNFE_PRINT_DANFE                                            *
*&---------------------------------------------------------------------*
*&  Print of DANFE by SmartForm                                        *
*&  Should be used together with Message Control (NAST)                *
*&  Basically, a copy of J_1BNFPR                                      *
*&---------------------------------------------------------------------*
*& RCP - Tradução EN/ES - 14/08/2018                                   *
*&---------------------------------------------------------------------*
report  znfe_print_danfe message-id 8b.

*======================================================================*
*  TABLES, INCLUDES, STRUCTURES, DATAS, ...                            *
*======================================================================*

*----------------------------------------------------------------------*
*  TABLES                                                              *
*----------------------------------------------------------------------*
* tables ---------------------------------------------------------------
tables: j_1bnfdoc,
        vbrk,                          " billing document header
        bkpf,
        kna1,
        lfa1,                          " financial document header
        j_1bnfe_active,
        j_1b_nfe_access_key.
*----------------------------------------------------------------------*
*  INCLUDES                                                            *
*----------------------------------------------------------------------*
* INCLUDE for General Table Descriptions for Print Programs ------------
include rvadtabl.
include znfe_j_1bnfpr_printinc.

*----------------------------------------------------------------------*
*  STRUCTURES                                                          *
*----------------------------------------------------------------------*
* Nota Fiscal header structure -----------------------------------------
data: begin of wk_header.
        include structure j_1bnfdoc.
data: end of wk_header.

* Nota Fiscal header structure - add. segment --------------------------
data: begin of wk_header_add.
        include structure j_1bindoc.
data: end of wk_header_add.

* Nota Fiscal partner structure ----------------------------------------
data: begin of wk_partner occurs 0.
        include structure j_1bnfnad.
data: end of wk_partner.

* Nota Fiscal item structure -------------------------------------------
data: begin of wk_item occurs 0.
        include structure j_1bnflin.
data: end of wk_item.

* Nota Fiscal item structure - add. segment ----------------------------
data: begin of wk_item_add occurs 0.
        include structure j_1binlin.
data: end of wk_item_add.

* Nota Fiscal item tax structure ---------------------------------------
data: begin of wk_item_tax occurs 0.
        include structure j_1bnfstx.
data: end of wk_item_tax.

* Nota Fiscal header message structure ---------------------------------
data: begin of wk_header_msg occurs 0.
        include structure j_1bnfftx.
data: end of wk_header_msg.

* Nota Fiscal reference to header message structure -------------------
data: begin of wk_refer_msg occurs 0.
        include structure j_1bnfref.
data: end of wk_refer_msg.

* Carrega a Work area para Contigencia ----------------------
data: begin of wk_danfe occurs 0.
        include structure j_1bnfe_active.
data: end of wk_danfe.


* auxiliar structure for vbrk key (used to update FI) ------------------
data: begin of key_vbrk,
        vbeln like vbrk-vbeln,
      end of key_vbrk.

data: my_destination like j_1binnad,
      my_issuer      like j_1binnad,
      my_carrier     like j_1binnad,
      my_items       like j_1bprnfli occurs 0 with header line.

data: fm_name        type rs38l_fnam.

data: begin of inter_total_table occurs 0,
        matorg    like j_1bprnfli-matorg,
        taxsit    like j_1bprnfli-taxsit,
        icmsrate  like j_1bprnfli-icmsrate,
        condensed type c,
        nfnett    like j_1bprnfli-nfnett,
      end of inter_total_table.

*---data for SmartForms---*
data: output_options type ssfcompop. " transfer printer to SM
data: control_parameters type ssfctrlop.

* Tabela para dados da fatura (SMARTFORMS).
data: w_danfe  type znfedanfe_header.

* Informações de contigencia
data:  v_contingkey(36) type c,
       v_nftot_char(14) type c,
       v_cpf(11)    type c,
       v_icmproprio type c,
       v_icmsub     type c,
       v_nfe        type string,
       v_nfe1       type string.
data: e_znfecontigekey type znfecontigekey.

* Busca informações do cliente (Mestre de clientes) ------------------
*DATA: BEGIN OF t_kna1,
*        regio LIKE kna1-regio,
*        stcd1 LIKE kna1-stcd1,
*        stcd2 LIKE kna1-stcd2,
*        txjdc LIKE kna1-txjdc,
*      END OF t_kna1.
*
** Busca informações do Fornecedor (Mestre de fornecedores ) ------------------
*DATA: BEGIN OF t_lfa1,
*        regio LIKE lfa1-regio,
*        stcd1 LIKE lfa1-stcd1,
*        stcd2 LIKE lfa1-stcd2,
*        txjdc LIKE lfa1-txjdc,
*      END OF t_lfa1.

*----------------------------------------------------------------------*
*  DATA AND CONSTANTS                                                 *
*----------------------------------------------------------------------*
data: wk_docnum     type j_1bnfdoc-docnum,
      retcode       type sy-subrc,
      xscreen,
      wk_xblnr      type bkpf-xblnr,
      subrc_upd_bi  type sy-subrc.
data: bi_subrc      type sy-subrc,
      fi_subrc      type sy-subrc.

class cl_exithandler definition load.

data: gs_nfeactive type        j_1bnfe_active,
      lr_badi      type ref to zif_ex_nfe.

*======================================================================*
*  PROGRAM                                                             *
*======================================================================*

*&---------------------------------------------------------------------*
*&       FORM ENTRY  (MAIN FORM)                                       *
*&---------------------------------------------------------------------*
*       Form for Message Control                                       *
*----------------------------------------------------------------------*
form entry using return_code us_screen.

  clear: retcode.
  xscreen = us_screen.

  data: v_sform type tdsfname.

  select single sform
         into v_sform
         from tnapr
         where kschl eq 'NF01'
           and kappl eq 'NF'
           and nacha eq '1'.

  if sy-subrc eq 0.
    if not v_sform is initial.
      tnapr-sform = v_sform.
      clear tnapr-funcname.
      clear tnapr-fonam.
    endif.
  endif.

  if lr_badi is initial.

    call method cl_exithandler=>get_instance
      EXPORTING
        exit_name                     = 'ZNFE'
      CHANGING
        instance                      = lr_badi
      EXCEPTIONS
        no_reference                  = 1
        no_interface_reference        = 2
        no_exit_interface             = 3
        class_not_implement_interface = 4
        single_exit_multiply_active   = 5
        cast_error                    = 6
        exit_not_existing             = 7
        data_incons_in_exit_managem   = 8
        others                        = 9.

    if sy-subrc <> 0.                                       "#EC NEEDED
    endif.

  endif.

  perform smart_sub_printing.

* main -----------------------------------------------------------------

* check retcode (return code) ------------------------------------------
  if retcode ne 0.
    return_code = 1.
  else.
    return_code = 0.
  endif.

endform.                               " ENTRY

*&---------------------------------------------------------------------*
*&      Form  NOTA_FISCAL_READ
*&---------------------------------------------------------------------*
*       Read the Nota Fiscal based in the key giving by Message        *
*       Control.                                                       *
*----------------------------------------------------------------------*
form nota_fiscal_read.

  move nast-objky to wk_docnum.

  call function 'J_1B_NF_DOCUMENT_READ'
    EXPORTING
      doc_number         = wk_docnum
    IMPORTING
      doc_header         = wk_header
    TABLES
      doc_partner        = wk_partner
      doc_item           = wk_item
      doc_item_tax       = wk_item_tax
      doc_header_msg     = wk_header_msg
      doc_refer_msg      = wk_refer_msg
    EXCEPTIONS
      document_not_found = 1
      docum_lock         = 2
      others             = 3.

* check the sy-subrc ---------------------------------------------------
  perform check_error.


  call function 'J_1B_NF_VALUE_DETERMINATION'
    EXPORTING
      nf_header   = wk_header
    IMPORTING
      ext_header  = wk_header_add
    TABLES
      nf_item     = wk_item
      nf_item_tax = wk_item_tax
      ext_item    = wk_item_add.

endform.                               " NOTA_FISCAL_READ
*&---------------------------------------------------------------------*
*&      Form  NOTA_FISCAL_NUMBER
*&---------------------------------------------------------------------*
*       Get the next Nota Fiscal number                                *
*----------------------------------------------------------------------*
form nota_fiscal_number.

  call function 'J_1B_NF_NUMBER_GET_NEXT'
    EXPORTING
      bukrs                         = wk_header-bukrs
      branch                        = wk_header-branch
      form                          = wk_header-form
      headerdata                    = wk_header
    IMPORTING
      nf_number                     = wk_header-nfnum
    EXCEPTIONS
      print_number_not_found        = 1
      interval_not_found            = 2
      number_range_not_internal     = 3
      object_not_found              = 4
      other_problems_with_numbering = 5
      others                        = 6.

  perform check_error.

endform.                               " NOTA_FISCAL_NUMBER

*&---------------------------------------------------------------------*
*&      Form  NOTA_FISCAL_UPDATE
*&---------------------------------------------------------------------*
*       Update NF date and number                                      *
*----------------------------------------------------------------------*
form nota_fiscal_update.

  wk_header-printd = 'X'.

  update j_1bnfdoc set printd = wk_header-printd
                       follow = wk_header-follow
                 where docnum = wk_header-docnum.

  if sy-subrc <> 0.
    retcode = sy-subrc.
    syst-msgid = '8B'.
    syst-msgno = '107'.
    syst-msgty = 'E'.
    syst-msgv1 = wk_header-docnum.
    perform protocol_update.
  endif.

endform.                               " NOTA_FISCAL_UPDATE
*&---------------------------------------------------------------------*
*&      Form  CHECK_ERROR
*&---------------------------------------------------------------------*
*       Check return code                                              *
*----------------------------------------------------------------------*
form check_error.

  if sy-subrc <> 0.
    retcode = sy-subrc.
    perform protocol_update.
  endif.

endform.                               " CHECK_ERROR
*&---------------------------------------------------------------------*
*&      Form  PROTOCOL_UPDATE
*&---------------------------------------------------------------------*
*       The messages are collected for the processing protocol.        *
*----------------------------------------------------------------------*
form protocol_update.

  check xscreen = space.
  call function 'NAST_PROTOCOL_UPDATE'
    EXPORTING
      msg_arbgb = syst-msgid
      msg_nr    = syst-msgno
      msg_ty    = syst-msgty
      msg_v1    = syst-msgv1
      msg_v2    = syst-msgv2
      msg_v3    = syst-msgv3
      msg_v4    = syst-msgv4
    EXCEPTIONS
      others    = 1.

endform.                               " PROTOCOL_UPDATE
*&---------------------------------------------------------------------*
*&      Form  FINANCIAL_DOC_UPDATE
*&---------------------------------------------------------------------*
*       Update the sales document and Financial document with the      *
*       Nota Fiscal number and the Nota Fiscal with the financial      *
*       document                                                       *
*----------------------------------------------------------------------*
form financial_doc_update.

  sort wk_item.
  read table wk_item index 1.

  call function 'J_1B_NF_NUMBER_CONDENSE'
    EXPORTING
      nf_number  = wk_header-nfnum
      series     = wk_header-series
      subseries  = wk_header-subser
      nf_number9 = wk_header-nfenum
    IMPORTING
      ref_number = wk_xblnr
    EXCEPTIONS
      others     = 1.

* get the type of the document and update the documents ----------------
  case wk_item-reftyp.

    when 'BI'.
      move wk_item-refkey to key_vbrk.
      perform read_bi_document.
      clear bkpf.
      if not vbrk is initial.          " if find VBRK (Billing document)
        perform get_fi_number.
      endif.
      if bkpf-belnr is initial.        " there is not FI document
        if not vbrk is initial.        " if find VBRK (Billing document)
          perform update_bi_document.
        endif.
      else.                            " there is FI document
        perform update_bi_document.
        if  subrc_upd_bi is initial.   " update in billing ok.
          perform update_fi_nf_document
                    using bkpf-bukrs bkpf-belnr bkpf-gjahr.
          perform update_bsid_nf_document
                  using bkpf-bukrs bkpf-belnr bkpf-gjahr.
        endif.
      endif.

    when others.  " for MD or <space> that means writer.
      wk_header-follow = 'X'.

  endcase.

endform.                               " FINANCIAL_DOC_UPDATE

*&---------------------------------------------------------------------*
*&      Form  READ_BI_DOCUMENT
*&---------------------------------------------------------------------*
*       This form read the billing document                            *
*----------------------------------------------------------------------*
form read_bi_document.

  select single * from  vbrk
         where  vbeln       = key_vbrk-vbeln.

  if sy-subrc <> 0.
    clear vbrk.
  endif.

endform.                               " READ_BI_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  READ_FI_DOCUMENT
*&---------------------------------------------------------------------*
*       read the fi_document                                           *
*----------------------------------------------------------------------*
form read_fi_document using xbukrs xbelnr xgjahr.

  select single * from  bkpf
         where  bukrs       = xbukrs
         and    belnr       = xbelnr
         and    gjahr       = xgjahr.

  if sy-subrc <> 0.
    clear bkpf.
  endif.

endform.                               " READ_FI_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  UPDATE_BI_DOCUMENT
*&---------------------------------------------------------------------*
*       Update billing document                                        *
*----------------------------------------------------------------------*
form update_bi_document.

  if bi_subrc = 0.                     " billing not lock

    update vbrk set xblnr = wk_xblnr
                where  vbeln = key_vbrk-vbeln.

    perform check_error.

    subrc_upd_bi = sy-subrc.

    call function 'DEQUEUE_EVVBRKE'
      EXPORTING
        mandt  = sy-mandt
        vbeln  = key_vbrk-vbeln
      EXCEPTIONS
        others = 1.

  else.                                " billing lock

    subrc_upd_bi = sy-subrc.

  endif.

endform.                               " UPDATE_BI_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  UPDATE_FI_NF_DOCUMENT
*&---------------------------------------------------------------------*
*       Update financial and nota fiscal document                      *
*----------------------------------------------------------------------*
form update_fi_nf_document using xbukrs xbelnr xgjahr.

  if fi_subrc = 0.                     " billing not lock

    update bkpf set xblnr = wk_xblnr
                where  bukrs       = xbukrs
                and    belnr       = xbelnr
                and    gjahr       = xgjahr.

    perform check_error.

    wk_header-follow = 'X'.

  endif.

endform.                               " UPDATE_FI_NF_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  GET_FI_NUMBER
*&---------------------------------------------------------------------*
*       Read financial document via Billing document number            *
*----------------------------------------------------------------------*
form get_fi_number.

  select single * from  bkpf
         where  bukrs = vbrk-bukrs
         and    awtyp = 'VBRK'
         and    awkey = key_vbrk-vbeln.

  if sy-subrc <> 0.
    clear bkpf.
  endif.

endform.                               " GET_FI_NUMBER


*&---------------------------------------------------------------------*
*&      Form  UPDATE_BSID_NF_DOCUMENT
*&---------------------------------------------------------------------*
*  update table BSID with external Nota Fiscal number - KI3K050466
*  change 23.01.97
*  Change 28.06.2000:
*  update also BSIS if G/L account with line item display exists
*  Change 09.08.2000: if cust account already cleared
*    (e.g. credit card sales) update BSAD instead of BSID
*----------------------------------------------------------------------*
form update_bsid_nf_document using xbukrs xbelnr xgjahr.

  tables: bseg,
          bsid,
          bsis,
          bsad.

  select * from bseg where bukrs = xbukrs
                       and belnr = xbelnr
                       and gjahr = xgjahr
                       and ( koart = 'D' or koart = 'S' ).
    if sy-subrc = '0'.
      if bseg-koart = 'D'.
        if not bseg-augbl is initial.  " account cleared --> update BSAD
          update bsad set xblnr = wk_xblnr
                    where bukrs = bseg-bukrs
                      and kunnr = bseg-kunnr
                      and umsks = bseg-umsks
                      and umskz = bseg-umskz
                      and augdt = bseg-augdt
                      and augbl = bseg-augbl
                      and zuonr = bseg-zuonr
                      and gjahr = bseg-gjahr
                      and belnr = bseg-belnr
                      and buzei = bseg-buzei.

        else.   " open item --> update BSID
* Customer account --> update BSID
          update bsid set xblnr = wk_xblnr
                    where bukrs = bseg-bukrs
                      and kunnr = bseg-kunnr
                      and umsks = bseg-umsks
                      and umskz = bseg-umskz
                      and augdt = bseg-augdt
                      and augbl = bseg-augbl
                      and zuonr = bseg-zuonr
                      and gjahr = bseg-gjahr
                      and belnr = bseg-belnr
                      and buzei = bseg-buzei.
          if sy-subrc eq 0.
            call function 'OPEN_FI_PERFORM_00005010_P'
              EXPORTING
                i_chgtype     = 'U'
                i_origin      = 'J_1BNFPR UPDATE_BSID_NF_DOCUMENT'
                i_tabname     = 'BSID'
                i_where_bukrs = bseg-bukrs
                i_where_kunnr = bseg-kunnr
                i_where_umsks = bseg-umsks
                i_where_umskz = bseg-umskz
                i_where_augdt = bseg-augdt
                i_where_augbl = bseg-augbl
                i_where_zuonr = bseg-zuonr
                i_where_gjahr = bseg-gjahr
                i_where_belnr = bseg-belnr
                i_where_buzei = bseg-buzei
              EXCEPTIONS
                others        = 1.
            if sy-subrc ne 0.
              message id sy-msgid type 'A' number sy-msgno
                      with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            endif.
          else.
            perform check_error.                            " 793934
          endif. " BSID update ok
        endif. " Clearing status: BSID or BSAD
      endif.  " Debitor Accounts, Note 793934

* Always try to udate BSIS, regardless of account type (Note 793934)

*  G/L account --> try to update BSIS
      update bsis set xblnr = wk_xblnr
                where bukrs = bseg-bukrs
                  and gjahr = bseg-gjahr
                  and belnr = bseg-belnr
                  and buzei = bseg-buzei.
* Update only possible for G/L accounts with line item display
*   --> Print NF even for update failure in bsis
      clear sy-subrc.
    endif. " Reading BSEG
  endselect.

* perform unlocking of the fi document only after the update of BSID,
* because this table must also be locked during update - the following
* call function was before in the form update_fi_nf_document.

  call function 'DEQUEUE_EFBKPF'
    EXPORTING
      bukrs  = xbukrs
      belnr  = xbelnr
      gjahr  = xgjahr
    EXCEPTIONS
      others = 1.

endform.                               " UPDATE_BSID_NF_DOCUMENT

*---------------------------------------------------------------------*
*       FORM ENQUEUE_BI_FI                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
form enqueue_bi_fi.

  clear bi_subrc.

* sort the wk_item to get the first item
  sort wk_item.
  read table wk_item index 1.

  check wk_item-reftyp = 'BI'.
  move wk_item-refkey to key_vbrk.

  perform read_bi_document.

  if not vbrk is initial.              "call via SD
    call function 'ENQUEUE_EVVBRKE'
      EXPORTING
        mandt          = sy-mandt
        vbeln          = key_vbrk-vbeln
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        others         = 3.

    bi_subrc = sy-subrc.
    perform check_error.
    if bi_subrc = 0.                   "BI document not locked
      clear bkpf.
      perform get_fi_number.
      if not bkpf-belnr is initial.
        call function 'ENQUEUE_EFBKPF'
          EXPORTING
            bukrs          = bkpf-bukrs
            belnr          = bkpf-belnr
            gjahr          = bkpf-gjahr
          EXCEPTIONS
            foreign_lock   = 1
            system_failure = 2
            others         = 3.

        fi_subrc = sy-subrc.
        perform check_error.
        if fi_subrc <> 0.     "FI lock not successful -> release BI lock
          call function 'DEQUEUE_EVVBRKE'
            EXPORTING
              mandt  = sy-mandt
              vbeln  = key_vbrk-vbeln
            EXCEPTIONS
              others = 1.
          perform check_error.
        endif.
      endif.
    endif.
  endif.

endform.                               " ENQUEUE_BI_FI
*&---------------------------------------------------------------------*
*&      Form  check_nf_canceled
*&---------------------------------------------------------------------*
*       allow print of NF only when NF is not canceled
*----------------------------------------------------------------------*
form check_nf_canceled.
  data: lv_dummy  type c.

  if not wk_header-cancel is initial and wk_header-nfnum is initial.
    sy-subrc = 1.
    message id '8B'
            type 'E'
            number '678'
            with wk_header-docnum
            into lv_dummy.

    perform check_error.
    if sy-batch is initial.                " corr. of note 442570
      message e678 with wk_header-docnum.
    endif.                                 " corr. of note 442570
  endif.
endform.                    " check_nf_canceled
*&---------------------------------------------------------------------*
*&      Form  check_nfe_authorized
*&---------------------------------------------------------------------*
form check_nfe_authorized.
  data: lv_dummy  type c,
        lv_subrc  type sy-subrc,
        obj_ref   type ref to if_ex_cl_nfe_print.

  clear gs_nfeactive.

* only NFes
  check wk_header-nfe = 'X'.

  select single * from j_1bnfe_active into gs_nfeactive
  where docnum = wk_header-docnum.

  if not sy-subrc is initial.
    message e012 with wk_header-docnum.
  endif.

  if gs_nfeactive-code is initial.

    commit work and wait.
    wait up to 30 seconds.

    select single * from j_1bnfe_active into gs_nfeactive
    where docnum = wk_header-docnum.

    if not sy-subrc is initial.
      message e012 with wk_header-docnum.
    endif.

  endif.

  j_1bnfe_active = gs_nfeactive.

* don't print NF-e when ...
* ... rejected docsta = 2
* ... denied   docsta = 3
* ... switches manual to contingency
  if gs_nfeactive-conting_s = 'X'
  or gs_nfeactive-docsta    = '2'
  or gs_nfeactive-docsta    = '3'.

    lv_subrc = 1.

  else.

*-- don´t print not authorized NFes

    if  wk_header-authcod is initial    "Nfe is not authorized
    and wk_header-conting is initial.   "and not in contingency
      lv_subrc = 1.
    endif.
  endif.

*-- BADI for reset subrc
*-- When subrc is 0 NFes can be printed without aauthorization code

  if obj_ref is initial.

    call method cl_exithandler=>get_instance       " #EC CI_BADI_GETINST
      exporting
        exit_name                     = 'CL_NFE_PRINT'
        null_instance_accepted        = seex_false
      changing
        instance                      = obj_ref
      exceptions
        no_reference                  = 1
        no_interface_reference        = 2
        no_exit_interface             = 3
        class_not_implement_interface = 4
        single_exit_multiply_active   = 5
        cast_error                    = 6
        exit_not_existing             = 7
        data_incons_in_exit_managem   = 8
        others                        = 9.

    if sy-subrc is initial.
*- nothing to do
    endif.

  endif.

  if obj_ref is bound.
    call method obj_ref->reset_subrc
      EXPORTING
        is_nfdoc = wk_header
      CHANGING
        ch_subrc = lv_subrc.
  endif.

  sy-subrc = lv_subrc.

  if sy-subrc is not initial.
    if gs_nfeactive-conting_s = 'X'.
      message id 'J1B_NFE'
              type 'E'
              number '040'
              with wk_header-docnum
              into lv_dummy.
    else.
      message id 'J1B_NFE'
              type 'E'
              number '039'
              with wk_header-docnum
              into lv_dummy.
    endif.
    if sy-batch is initial.
      perform check_error.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
  else.
    gs_nfeactive-printd = 'X'.
  endif.

endform.                    " check_nfe_authorized
*&---------------------------------------------------------------------*
*&      Form  active_update
*&---------------------------------------------------------------------*
form active_update .


  update j_1bnfe_active from gs_nfeactive.

  if sy-subrc <> 0.
    message a021(j1b_nfe) with gs_nfeactive-docnum.
  endif.


endform.                    " active_update
*&--------------------------------------------------------------------*
*&      Form  smart_sub_printing
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
form smart_sub_printing.

  data:   tax_types like j_1baj occurs 30 with header line.

  call function 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = tnapr-sform
    IMPORTING
      fm_name            = fm_name
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2.

  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.

  refresh: my_items.

* read the Nota Fiscal
  perform nota_fiscal_read.            " read nota fiscal

* allow print of NF only when NF is not canceled
  perform check_nf_canceled.   " check nota fiscal canceled,442570

* number and update the Nota Fiscal
  check retcode is initial.

* The NFe to be printed must have an authorization code
  if wk_header-nfe = 'X'.

*   The NFe to be printed must have an authorization code
    perform check_nfe_authorized.
    check retcode is initial.

  endif.
* for NFe the DANFE is printed. Numbering has already taken place
* before sending teh XML document to SEFAZ.
* Billing document is updated for NFe with the 9 digit NFe number
  if wk_header-entrad = 'X' or  "update only entradas or outgoing NF
     wk_header-direct  = '2'.
    if wk_header-printd is initial and " not printed.
       wk_header-nfnum is initial  and " without NF number
       nast-nacha = '1'.               " sent to printer

      perform enqueue_bi_fi.
      check retcode is initial.
* get NF number only for "normal NFs" NFe has already the number
      if wk_header-nfe is initial.
        perform nota_fiscal_number.      " get the next number
      endif.

      if retcode is initial.
        perform financial_doc_update.    " update in database
        perform nota_fiscal_update.      " update in database
        if not gs_nfeactive is initial.
          perform active_update. "ON COMMIT.
        endif.
      endif.
    endif.
  endif.

  if retcode is initial.
  else.
    message a114 with '01' 'J_1BNFNUMB'.
  endif.

*----------------------------------------------------------------------*
*    read tax types into internal buffer table                         *
*----------------------------------------------------------------------*
  select * from j_1baj into table tax_types order by primary key.

  clear  w_danfe.
  clear: w_danfe-issuer,
         w_danfe-destination,
         w_danfe-carrier,
         w_danfe-nota_fiscal,
         w_danfe-others,
         w_danfe-nfe,
         w_danfe-observ1,
         w_danfe-observ2,
         w_danfe-item,
         w_danfe-invoice.

*----------------------------------------------------------------------*
*    fill header data into communication structure                     *
*----------------------------------------------------------------------*
  move-corresponding wk_header to w_danfe-nota_fiscal.

  select single *
         from j_1bnfe_active
         into w_danfe-nfe
         where docnum eq wk_header-docnum.

*---> determine CFOP length, extension and deafulttext from version
*---> table
  perform get_cfop_length_smart  using wk_header-bukrs
                                 wk_header-branch
                                 wk_header-pstdat
                        changing cfop_version     " BOI note 593218
                                 cfop_length
                                 extension_length
                                 defaulttext
                                 issuer_region.

  move cfop_length to w_danfe-nota_fiscal-cfop_len.
*... fill header CFOP .................................................*

  data: begin of wk_cfop occurs 0,
    key(6)           type c,
    char6(6)         type c,
    dupl_text_indic  type c,
    text(50)         type c.
  data: end of wk_cfop.
  data: help_cfop(6)    type c,
        default_cfop(6) type c,
        lv_tabix        type sytabix,
        v_cfop          type j_1bnflin-cfop.


  loop at wk_item.
    concatenate wk_item-cfop(3) '0' wk_item-cfop+4(2) into v_cfop.
    wk_item-cfop = v_cfop.
    write wk_item-cfop  to help_cfop.
    help_cfop = help_cfop(cfop_length).
    case extension_length.
      when 1.
        if ( wk_item-cfop+1(3) = '991' or wk_item-cfop+1(3) = '999' )
                                             and issuer_region = 'SP'.
          concatenate help_cfop '.' wk_item-cfop+3(1) into help_cfop.
        endif.
      when 2.
        if wk_item-cfop+1(2) = '99' and issuer_region = 'SC'.
          concatenate help_cfop '.' wk_item-cfop+3(2) into help_cfop.
        endif.
    endcase.

    read table wk_cfop with key key = help_cfop.
    lv_tabix = sy-tabix.
    if sy-subrc <> 0.  " new CFOP on this NF: append this CFOP to list
      wk_cfop-char6  =  wk_item-cfop.
      wk_cfop-key    =  help_cfop.

      select single * from j_1bagnt   where spras   = sy-langu
                                        and version = cfop_version
                                        and cfop    = wk_item-cfop.
      if sy-subrc = 0.
        wk_cfop-text = j_1bagnt-cfotxt.
        append wk_cfop.
      else.
        encoded_cfop = wk_item-cfop.
        if encoded_cfop(1) ca                    " BOI note 593218-470
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ[-<>=!?]'.
          write wk_item-cfop  to encoded_cfop.
          replace '/' in encoded_cfop with ' '.
          condense encoded_cfop no-gaps.
        else.
          perform encoding_cfop_smart changing encoded_cfop.
        endif.                                   " EOI note 593218-470
*PERFORM ENCODING_CFOP_SMART CHANGING ENCODED_CFOP." note 593218-470
        select single * from j_1bagnt where spras = nast-spras
                                          and version = cfop_version
                                          and cfop    = encoded_cfop.
        if sy-subrc = 0.
          wk_cfop-text = j_1bagnt-cfotxt.
          append wk_cfop.
        endif.
      endif.
    else. " CFOP already on list; however, could be rel. to other text
      if wk_cfop-char6 <> wk_item-cfop and
                                  wk_cfop-dupl_text_indic is initial.
        default_cfop      = wk_item-cfop.
        default_cfop+4(2) = defaulttext.
        select single * from j_1bagnt where spras   = nast-spras
                                        and version = cfop_version
                                        and cfop    = default_cfop.
        if sy-subrc = 0.
          wk_cfop-text = j_1bagnt-cfotxt.
          wk_cfop-dupl_text_indic = 'X'.
          modify wk_cfop index lv_tabix.
        else.
          encoded_cfop = default_cfop.
          perform encoding_cfop_smart changing encoded_cfop.
          select single * from j_1bagnt where spras = nast-spras
                                          and version = cfop_version
                                          and cfop    = encoded_cfop.
          if sy-subrc = 0.
            wk_cfop-text = j_1bagnt-cfotxt.
            wk_cfop-dupl_text_indic = 'X'.
            modify wk_cfop index lv_tabix.
          endif.
        endif.
      endif.
    endif.
  endloop.

  describe table wk_cfop lines cfop_lines.
  if cfop_lines > 1.
    sort wk_cfop.
    delete adjacent duplicates from wk_cfop comparing key.
    loop at wk_cfop.
      concatenate w_danfe-nota_fiscal-cfop_text
                  '/'
                  wk_cfop-key wk_cfop-text
                  into w_danfe-nota_fiscal-cfop_text.
      if w_danfe-nota_fiscal-cfop_text(1) eq '/'.
        shift w_danfe-nota_fiscal-cfop_text left by 1 places.
      endif.
    endloop.
  elseif cfop_lines = 1.      " NF with items that all have one CFOP
    move wk_cfop-key  to w_danfe-nota_fiscal-cfop.
    move wk_cfop-text to w_danfe-nota_fiscal-cfop_text.
  endif.                                             " BOI note 593218

*----------------------------------------------------------------------*
*    If you are on contingency, print barcode                          *
*----------------------------------------------------------------------*

  clear  v_contingkey.
  write: wk_header_add-nftot to v_nftot_char(14).

  replace '.' into v_nftot_char with ''.
  replace ',' into v_nftot_char with ''.
  condense v_nftot_char no-gaps.
  unpack v_nftot_char to v_nftot_char .


*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*    EXPORTING
*      input  = v_nftot_char
*    IMPORTING
*      output = v_nftot_char.


  if not gs_nfeactive-conting is initial.
* Adiciona dados de icms proprio e icms de substituicao para contigencia
*v_nftot_char
    e_znfecontigekey-icmsp = '2'.
    e_znfecontigekey-icmss = '2'.


    loop at wk_item.
      if wk_item-taxsit = '0' or wk_item-taxsit = '1' or wk_item-taxsit
  = '2' or wk_item-taxsit = '6' or wk_item-taxsit = '7'
            or wk_item-taxsit = '10' or wk_item-taxsit = '51' or
  wk_item-taxsit = 'B'.
        e_znfecontigekey-icmsp = '1'.
      endif.

      if  wk_item-taxsit = '1' or wk_item-taxsit = '3' or wk_item-taxsit
                = '6' or wk_item-taxsit = '7'.
        e_znfecontigekey-icmss = '1'.
      endif.

    endloop.



* Monta o número de contigencia
* Tipo de impressão (FS - Contingência com uso do Formulário de
* segurança) página 8 do manual de contingência
    e_znfecontigekey-tpemiss = '5'.

* Valor total da nota sem pontos, virgulas e com zeros a esquerda (14
*    posições)
    e_znfecontigekey-vtotal = v_nftot_char.

* Dia da data de emissão
    e_znfecontigekey-ddemiss = wk_header-docdat+6(2).

    move j_1bnfe_active to wk_danfe.

* Código da região e CNPJ do destinatário

* Se for cliente
    if wk_header-partyp = 'C'.

      select single *
        from kna1
        where kunnr = wk_header-parid.


      e_znfecontigekey-regio = kna1-txjcd+3(2).
      e_znfecontigekey-stcd1 = kna1-stcd1(14).
* Não Esquecer de colocar o campo stcd2 na estrutura
*      if e_znfecontigekey-stcd1 = '00000000000000'.
*        clear e_znfecontigekey-stcd1.
*      endif.
*      WRITE: kna1-stcd2 TO v_cpf.
*      REPLACE '.' INTO v_cpf WITH ''.
*      REPLACE '.' INTO v_cpf WITH ''.
*      REPLACE '-' INTO v_cpf WITH ''.
*
*      CONDENSE v_cpf NO-GAPS.
*
*      UNPACK v_cpf TO  e_znfecontigekey-stcd2 .

    endif.

* se for Fornecedor

    if wk_header-partyp = 'V' or
       wk_header-partyp = 'B'.

      select single *
        from lfa1
        where lifnr = wk_header-parid.

      e_znfecontigekey-regio = lfa1-txjcd+3(2).
      e_znfecontigekey-stcd1 = lfa1-stcd1(14).
*      if e_znfecontigekey-stcd1 = '00000000000000'.
*        clear e_znfecontigekey-stcd1.
*      endif.
*      WRITE: lfa1-stcd2 TO v_cpf.
*      REPLACE '.' INTO v_cpf WITH ''.
*      REPLACE '.' INTO v_cpf WITH ''.
*      REPLACE '-' INTO v_cpf WITH ''.
*
*      CONDENSE v_cpf NO-GAPS.
*
*      UNPACK v_cpf TO  e_znfecontigekey-stcd2 .

    endif.

* Se for cliente do exterior
*    IF j_1bprnfde-land1 <> 'BR'.
*
*      CLEAR:
*        e_znfecontigekey-regio,
*        e_znfecontigekey-stcd1.
*
*      e_znfecontigekey-regio = '99'.
*      e_znfecontigekey-stcd1 = '00000000000000'.
*    ENDIF.

* Gera digito verificador
    call function 'ZNFE_CREATE_CONTI_CHECK_DIGIT'
      CHANGING
        c_contingkey = e_znfecontigekey.

* Cria chave de contingencia
    concatenate e_znfecontigekey-regio
                e_znfecontigekey-tpemiss
                e_znfecontigekey-stcd1
*                e_znfecontigekey-stcd2
                e_znfecontigekey-vtotal
                e_znfecontigekey-icmsp
                e_znfecontigekey-icmss
                e_znfecontigekey-ddemiss
                e_znfecontigekey-cdv
                into v_contingkey.

* Apagar chave de contingência, caso não seja do tipo

    move 'DADOS NF-e' to v_nfe.

    if gs_nfeactive-conting = space.

      clear: v_contingkey,
             v_nfe.
    endif.
  endif.

*----------------------------------------------------------------------*
*    determine issuer and destination (only for test)                  *
*----------------------------------------------------------------------*
  if wk_header-direct = '1'   and
     wk_header-entrad = ' '.
    issuer-partner_type      = wk_header-partyp.
    issuer-partner_id        = wk_header-parid.
    issuer-partner_function  = wk_header-parvw.
    destination-partner_type = 'B'.
    destination-partner_id   = wk_header-bukrs.
    destination-partner_id+4 = wk_header-branch.
  else.
    issuer-partner_type          = 'B'.
    issuer-partner_id            = wk_header-bukrs.
    issuer-partner_id+4          = wk_header-branch.
    destination-partner_type     = wk_header-partyp.
    destination-partner_id       = wk_header-parid.
    destination-partner_function = wk_header-parvw.
  endif.

*----------------------------------------------------------------------*
*    read branch data (issuer)                                         *
*----------------------------------------------------------------------*

  clear j_1binnad.

  call function 'J_1B_NF_PARTNER_READ'
    EXPORTING
      partner_type           = issuer-partner_type
      partner_id             = issuer-partner_id
      partner_function       = issuer-partner_function
      doc_number             = wk_header-docnum
      obj_item               = wk_item
    IMPORTING
      parnad                 = j_1binnad
    EXCEPTIONS
      partner_not_found      = 1
      partner_type_not_found = 2
      others                 = 3.
  move-corresponding j_1binnad to w_danfe-issuer.

*... check the sy-subrc ...............................................*
  perform check_error.
  check retcode is initial.

*----------------------------------------------------------------------*
*    read destination data                                             *
*----------------------------------------------------------------------*

  clear j_1binnad.

  call function 'J_1B_NF_PARTNER_READ'
    EXPORTING
      partner_type           = destination-partner_type
      partner_id             = destination-partner_id
      partner_function       = destination-partner_function
      doc_number             = wk_header-docnum
      obj_item               = wk_item
    IMPORTING
      parnad                 = j_1binnad
    EXCEPTIONS
      partner_not_found      = 1
      partner_type_not_found = 2
      others                 = 3.
  move-corresponding j_1binnad to w_danfe-destination.

*----------------------------------------------------------------------*
*    read fatura data if the Nota Fiscal is a Nota Fiscal Fatura       *
*----------------------------------------------------------------------*

  data: v_loops type i,
        v_linha type i,
        v_index type i.

  clear v_linha.

  if wk_header-fatura = 'X'.

    if wk_header-zterm ne space.
      select *
             from t052
             where zterm = wk_header-zterm
             order by primary key.
        exit.
      endselect.

      if t052-ztagg > '00' and t052-ztagg lt wk_header-zfbdt+6(2).
        select *
               from t052
               where zterm =  wk_header-zterm
               and   ztagg ge wk_header-zfbdt+6(2)
               order by primary key.
          exit.
        endselect.
      endif.

      if t052-xsplt = 'X'.               "holdback/retainage

        select *
               from t052s
               into table int_t052s
               where zterm = wk_header-zterm
               order by primary key.

        describe table int_t052s lines t052slines.

        v_loops = t052slines mod 3.

        if t052slines > 3.
          t052slines = 3.  "max. number of holdbacks printed on NF
        endif.

        do v_loops times.

          add 1 to v_linha.

          do t052slines times varying rate  from j_1bprnffa-ratpz1
                                            next j_1bprnffa-ratpz2
                              varying text2 from j_1bprnffa-txt12
                                            next j_1bprnffa-txt22
                              varying text3 from j_1bprnffa-txt13
                                            next j_1bprnffa-txt23
                              varying text4 from j_1bprnffa-txt14
                                            next j_1bprnffa-txt24
                              varying text1 from j_1bprnffa-txt11
                                            next j_1bprnffa-txt21.

            v_index = sy-index + ( ( v_linha - 1 ) * 3 ).

            read table int_t052s index v_index.
            rate = int_t052s-ratpz.
            select single *
                   from t052
                   where zterm = int_t052s-ratzt
                   and   ztagg = '00'.
            call function 'FI_TEXT_ZTERM'
              EXPORTING
                i_t052  = t052
              TABLES
                t_ztext = ztext.
            loop at ztext.
              case sy-tabix.
                when 1.
                  text2 = ztext-text1.
                when 2.
                  text3 = ztext-text1.
                when 3.
                  text4 = ztext-text1.
                when 4.
                  text1 = ztext-text1.
              endcase.
            endloop.
          enddo.
          append j_1bprnffa to w_danfe-invoice.
        enddo.
      else.                              " t052-xsplt = ' '
        call function 'FI_TEXT_ZTERM'
          EXPORTING
            i_t052  = t052
          TABLES
            t_ztext = ztext.

        loop at ztext.
          case sy-tabix.
            when 1.
              j_1bprnffa-txt02 = ztext-text1.
            when 2.
              j_1bprnffa-txt03 = ztext-text1.
            when 3.
              j_1bprnffa-txt04 = ztext-text1.
            when 4.
              j_1bprnffa-txt01 = ztext-text1.
          endcase.
        endloop.
        append j_1bprnffa to w_danfe-invoice.
      endif.
    endif.
  endif.


*----------------------------------------------------------------------*
*    read carrier data                                                 *
*----------------------------------------------------------------------*

  if wk_header-doctyp ne '2'.          "no carrier for Complementars

    read table wk_partner with key docnum = wk_header-docnum
                                   parvw  = 'SP'.
    if sy-subrc = 0.

      clear j_1binnad.
      call function 'J_1B_NF_PARTNER_READ'
        EXPORTING
          partner_type           = wk_partner-partyp
          partner_id             = wk_partner-parid
          partner_function       = wk_partner-parvw
          doc_number             = wk_header-docnum
        IMPORTING
          parnad                 = j_1binnad
        EXCEPTIONS
          partner_not_found      = 1
          partner_type_not_found = 2
          others                 = 3.
      move-corresponding j_1binnad to w_danfe-carrier.
    endif.

  endif.          "no carrier for Complementars



*----------------------------------------------------------------------*
*    read reference NF                                                 *
*----------------------------------------------------------------------*
  if w_danfe-nota_fiscal-docref <> space.
    select single * from j_1bnfdoc into *j_1bnfdoc
             where docnum = w_danfe-nota_fiscal-docref.
    w_danfe-nota_fiscal-nf_docref = *j_1bnfdoc-nfnum.
    w_danfe-nota_fiscal-nf_serref = *j_1bnfdoc-series.
    w_danfe-nota_fiscal-nf_subref = *j_1bnfdoc-subser.
    w_danfe-nota_fiscal-nf_datref = *j_1bnfdoc-docdat.
  endif.

*----------------------------------------------------------------------*
*    get information about form                                        *
*----------------------------------------------------------------------*

  data: print_conf type j_1bb2.

  call function 'J_1BNF_GET_PRINT_CONF'
    EXPORTING
      headerdata = wk_header
    IMPORTING
      print_conf = print_conf
    EXCEPTIONS
      error      = 1
      others     = 2.

  perform check_error.
  check retcode is initial.

*----------------------------------------------------------------------*
*    write texts to TEXTS window                                       *
*----------------------------------------------------------------------*

  data: w_line type tline.

  istart = print_conf-totlih.                       " note note 743361

  loop at wk_header_msg.
    w_line-tdline = wk_header_msg-message.
    if sy-index lt istart.
      if sy-index eq 1.
        w_danfe-observ1 = wk_header_msg-message.
      else.
        concatenate w_danfe-observ1
                    cl_abap_char_utilities=>cr_lf
                    wk_header_msg-message
                    into w_danfe-observ1.
      endif.
      append w_line to w_danfe-text1.
    else.
      if sy-index eq istart.
        w_danfe-observ2 = wk_header_msg-message.
      else.
        concatenate w_danfe-observ2
                    cl_abap_char_utilities=>cr_lf
                    wk_header_msg-message
                    into w_danfe-observ2.
      endif.
      append w_line to w_danfe-text2.
    endif.
  endloop.

*... fill items ......................................................*


  loop at wk_item.


    read table wk_item_add with key docnum = wk_item-docnum
                              itmnum = wk_item-itmnum.
    if wk_item-netdis < 0.
      wk_item-netdis = wk_item-netdis * -1.
    endif.

    move wk_item-netdis to wk_header_add-nfdis.

    clear j_1bprnfli.
    move-corresponding wk_item to j_1bprnfli.
    move-corresponding wk_item_add to j_1bprnfli.

*... fill text reference ..............................................*

    loop at wk_refer_msg where itmnum = wk_item-itmnum.
      replace '  ' with wk_refer_msg-seqnum into j_1bprnfli-text_ref.
      replace ' '  with ','                 into j_1bprnfli-text_ref.
    endloop.
    replace ', ' with '  ' into j_1bprnfli-text_ref.

    append j_1bprnfli to w_danfe-item.

  endloop.

  check retcode is initial.

  move-corresponding wk_header_add to w_danfe-nota_fiscal.

  if not lr_badi is initial.
    call method lr_badi->filling_danfe
      CHANGING
        danfe = w_danfe.
  endif.

  perform call_smartform.

endform.                        "smart_sub_printing

*&---------------------------------------------------------------------
*&      Form  GET_CFOP_LENGTH_SMART
*&---------------------------------------------------------------------
*       text
*----------------------------------------------------------------------
form get_cfop_length_smart using    p_bukrs
                                    p_branch
                                    p_pstdat
                           changing p_version         " note 593218
                                    p_clength
                                    p_elength
                                    p_text
                                    p_region.         " note 593218

  data: lv_adress   type addr1_val.

  call function 'J_1BREAD_BRANCH_DATA'
    EXPORTING
      bukrs             = p_bukrs
      branch            = p_branch
    IMPORTING
      address1          = lv_adress
    EXCEPTIONS
      branch_not_found  = 1
      address_not_found = 2
      company_not_found = 3
      others            = 4.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

  p_region = lv_adress-region.                   " note 593218

  call function 'J_1B_CFOP_GET_VERSION'
    EXPORTING
      region            = lv_adress-region
      date              = p_pstdat
    IMPORTING
      version           = p_version        " note 593218
      extension         = p_elength
      cfoplength        = p_clength
      txtdef            = p_text
    EXCEPTIONS
      date_missing      = 1
      version_not_found = 2
      others            = 3.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

endform.                             " GET_CFOP_LENGTH_SMART

*&---------------------------------------------------------------------
*&      Form  ENCODING_CFOP_SMART
*&---------------------------------------------------------------------
*       encode the CFOP
*      51234   =>  51234
*      5123A   =>  5123A
*      512345  =>  512345
*      51234A  =>  51234A
*      5123B4  =>  5123B4
*      5123BA  =>  5123BA
*----------------------------------------------------------------------
form encoding_cfop_smart  changing p_cfop.

  data: len(1) type n,
        helpstring(60) type c,
        d type i.

  helpstring =
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ[-<>=!?]'.

  len = strlen( p_cfop ).
  if len = 6.
    case p_cfop(1).
      when 1. d = 0.
      when 2. d = 1.
      when 3. d = 2.
      when 5. d = 3.
      when 6. d = 4.
      when 7. d = 5.
    endcase.
    d = d * 10 + p_cfop+1(1).
    shift helpstring by d places.
    move helpstring(1) to p_cfop(1).
    p_cfop+1(4) = p_cfop+2(4).
    clear p_cfop+5(1).
  endif.

endform.                    " ENCODING_CFOP_SMART
*&--------------------------------------------------------------------*
*&      Form  call_smartform
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
form call_smartform.

  data: lv_subject type tdtitle.

  output_options-tdimmed       = nast-dimme.
  output_options-tddest        = nast-ldest.
  control_parameters-no_dialog = 'X'.

  call function fm_name
    EXPORTING
      control_parameters = control_parameters
      output_options     = output_options
      user_settings      = ''
      nota_fiscal        = w_danfe
      v_contingkey       = v_contingkey
      v_nfe              = v_nfe
      v_nfe1             = v_nfe1
    EXCEPTIONS
      formatting_error   = 1
      internal_error     = 2
      send_error         = 3
      user_canceled      = 4
      others             = 5.

  if sy-subrc <> 0.
  endif.

endform.                    "call_smartform
