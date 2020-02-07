*&---------------------------------------------------------------------*
*& Report  ZHMS_VALID_SEFAZ
*&
*&---------------------------------------------------------------------*
*& RCP - Tradução EN/ES - 14/08/2018
*&
*&---------------------------------------------------------------------*

REPORT  ZHMS_VALID_SEFAZ MESSAGE-ID z_g000.

TABLES: j_1bnfdoc.

DATA: i_doc       TYPE TABLE OF j_1bnfe_active,
      h_doc       LIKE LINE OF i_doc,
      i_ch_xmltab TYPE TABLE OF j_1bnfe_inbound,
      h_ch_xmltab LIKE LINE OF i_ch_xmltab.

* ALV
TYPE-POOLS: slis.

DATA : BEGIN OF i_estrutura OCCURS 0.
INCLUDE TYPE slis_fieldcat_main.
INCLUDE TYPE slis_fieldcat_alv_spec.
DATA : END OF i_estrutura.

DATA:
   h_sort_alv     TYPE slis_sortinfo_alv,        " header
   t_sort_alv     TYPE slis_t_sortinfo_alv,      " sem header
   t_listheader   TYPE slis_t_listheader,
   v_listheader   TYPE slis_listheader,          " Cabeçalho
   w_layout       TYPE slis_layout_alv,
   h_event_alv    TYPE slis_alv_event,           " header
   t_events       TYPE slis_t_event,
   h_set          TYPE lvc_s_glay,
   v_col          TYPE i.

*---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: s_docnum FOR j_1bnfdoc-docnum OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.

*---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_controle_z.
  PERFORM f_acessa_docnum.

  IF i_doc[] IS INITIAL.
    MESSAGE i000 WITH text-002.
  ELSE.
    PERFORM f_processa_docnum.
    PERFORM f_relatorio.
  ENDIF.

END-OF-SELECTION.
*&---------------------------------------------------------------------*
*&      Form  F_RELATORIO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_relatorio .

  PERFORM f_monta_sort.
  PERFORM f_monta_fieldcat.

  w_layout-zebra = 'X'.

  SORT i_ch_xmltab BY i_docnum.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = 'ZSDR0205'
      is_layout          = w_layout
      it_fieldcat        = i_estrutura[]
      it_sort            = t_sort_alv[]
      i_default          = 'X'
      i_save             = 'A'
    TABLES
      t_outtab           = i_ch_xmltab
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.

ENDFORM.                    " F_RELATORIO
*&---------------------------------------------------------------------*
*&      Form  F_MONTA_SORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_monta_sort .

  CLEAR t_sort_alv. REFRESH t_sort_alv.
  h_sort_alv-spos      = '01'.
  h_sort_alv-fieldname = 'I_DOCNUM'.
  h_sort_alv-tabname   = 'I_CH_XMLTAB'.
  h_sort_alv-up        = 'X'.
  APPEND h_sort_alv TO t_sort_alv.

ENDFORM.                    " F_MONTA_SORT
*&---------------------------------------------------------------------*
*&      Form  F_MONTA_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_monta_fieldcat .

  CLEAR: i_estrutura, v_col. REFRESH i_estrutura.
*
  ADD 1 TO v_col.
  CLEAR i_estrutura.
  i_estrutura-fieldname = 'I_DOCNUM'.
  i_estrutura-tabname   = 'I_CH_XMLTAB'.
  i_estrutura-col_pos   = v_col.
  i_estrutura-seltext_m = text-003.
  i_estrutura-outputlen = 13.
  i_estrutura-just      = 'C'.
  APPEND i_estrutura.
*
  ADD 1 TO v_col.
  CLEAR i_estrutura.
  i_estrutura-fieldname = 'I_NFNUM9'.
  i_estrutura-tabname   = 'I_CH_XMLTAB'.
  i_estrutura-col_pos   = v_col.
  i_estrutura-seltext_m = text-004.
  i_estrutura-outputlen = 8.
  i_estrutura-no_zero   = 'X'.
  i_estrutura-just      = 'C'.
  APPEND i_estrutura.
*
  ADD 1 TO v_col.
  CLEAR i_estrutura.
  i_estrutura-fieldname = 'E_ERROR'.
  i_estrutura-tabname   = 'I_CH_XMLTAB'.
  i_estrutura-col_pos   = v_col.
  i_estrutura-seltext_m = text-005.
  i_estrutura-outputlen = 5.
  i_estrutura-just      = 'C'.
  APPEND i_estrutura.

ENDFORM.                    " F_MONTA_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  F_ACESSA_DOCNUM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_acessa_docnum .

  REFRESH i_doc.
  SELECT *
    INTO TABLE i_doc
    FROM j_1bnfe_active
   WHERE docnum IN s_docnum.

ENDFORM.                    " F_ACESSA_DOCNUM
*&---------------------------------------------------------------------*
*&      Form  F_PROCESSA_DOCNUM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_processa_docnum .

  REFRESH i_ch_xmltab.

  LOOP AT i_doc INTO h_doc.
    CLEAR h_ch_xmltab.
    h_ch_xmltab-i_docnum   = h_doc-docnum.
    CONCATENATE '1' h_doc-regio h_doc-nfyear h_doc-nfmonth h_doc-stcd1
           INTO h_ch_xmltab-i_authcode.
    h_ch_xmltab-i_code     = '100'.
    h_ch_xmltab-i_regio    = h_doc-regio.
    h_ch_xmltab-i_nfyear   = h_doc-nfyear.
    h_ch_xmltab-i_nfmonth  = h_doc-nfmonth.
    h_ch_xmltab-i_stcd1    = h_doc-stcd1.
    h_ch_xmltab-i_model    = h_doc-model.
    h_ch_xmltab-i_serie    = h_doc-serie.
    h_ch_xmltab-i_nfnum9   = h_doc-nfnum9.
    h_ch_xmltab-i_docnum9  = h_doc-docnum9.
    h_ch_xmltab-i_cdv      = h_doc-cdv.
    h_ch_xmltab-i_msgtyp   = '1'.
    APPEND h_ch_xmltab TO i_ch_xmltab.
  ENDLOOP.

  CALL FUNCTION 'J_1B_NFE_XML_IN_TAB'
    TABLES
      ch_xmltab = i_ch_xmltab.

ENDFORM.                    " F_PROCESSA_DOCNUM
*&---------------------------------------------------------------------*
*&      Form  F_CONTROLE_Z
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_controle_z .

*  DATA h_zbctabctrabap TYPE zbctabctrabap.
*  h_zbctabctrabap-programa = sy-cprog.
*  h_zbctabctrabap-usuario  = sy-uname.
*  h_zbctabctrabap-data     = sy-datum.
*  h_zbctabctrabap-hora     = sy-uzeit.
*  h_zbctabctrabap-modulo   = 'SD'.
*  INSERT zbctabctrabap FROM h_zbctabctrabap.

ENDFORM.                    " F_CONTROLE_Z
