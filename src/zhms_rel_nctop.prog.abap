*&---------------------------------------------------------------------*
*& Include zhms_REL_NCTOP                                    PoolMóds.        zhms_REL_NCM
*&
*&---------------------------------------------------------------------*

program  zhms_rel_ncm.

types: begin of e_list_ncm,
          codigo       type i,
          check(1)     type c,
          icon         type icon_d,
          bukrs        type zhms_rel_ncm-bukrs,
          werks        type zhms_rel_ncm-werks,
          datum        type zhms_rel_ncm-datum,
          lifnr        type zhms_rel_ncm-lifnr,
          ebeln        type zhms_rel_ncm-ebeln,
          ebelp        type zhms_rel_ncm-ebelp,
          matnr        type zhms_rel_ncm-matnr,
          ncmatual     type zhms_rel_ncm-ncmatual,
          ncmforn      type zhms_rel_ncm-ncmforn,
          nfnum        type zhms_rel_ncm-nfnum,
       end of e_list_ncm.

data: t_ncm  type table of zhms_rel_ncm with header line,
      t_lncm type table of e_list_ncm   with header line.


data: txt_status(43) type c,
      icon_status    type icon_d,
      vg_codigo      type zhms_rel_ncm-codigo,
      vg_bukrs       type zhms_rel_ncm-bukrs,
      vg_werks       type zhms_rel_ncm-werks,
      vg_datum       type zhms_rel_ncm-datum,
      vg_lifnr       type zhms_rel_ncm-lifnr,
      vg_name1       type lfa1-name1,
      vg_ebeln       type zhms_rel_ncm-ebeln,
      vg_item        type zhms_rel_ncm-ebeln,
      vg_matnr       type zhms_rel_ncm-matnr,
      vg_ncmatual    type zhms_rel_ncm-ncmatual,
      vg_ncmforn     type zhms_rel_ncm-ncmforn,
      vg_nota        type zhms_rel_ncm-ebeln,
      ck_arqv        type zhms_rel_ncm-arquivada.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TC_LNCM' ITSELF
controls: tc_lncm type tableview using screen 0010.

*&SPWIZARD: LINES OF TABLECONTROL 'TC_LNCM'
data:     g_tc_lncm_lines  like sy-loopc.

data:     ok_code like sy-ucomm.


*****  Data items for text editor
type-pools dart1.

type-pools shlp.                       "search help

constants: textnoteline_length type i value 72.

data:
* reference to wrapper class of control
      textnote_editor type ref to cl_gui_textedit,
*     reference to custom container: necessary to bind TextEdit Control
      textnote_custom_container type ref to cl_gui_custom_container,
      textnote_repid like sy-repid,
      textnote_ok_code like sy-ucomm,  " return code from screen
      textnote_table(textnoteline_length) type c occurs 0,
      textnote_container(30) type c.   " string for the containers

data: textnote_itxw_note type standard table of txw_note
          with header line,
      textnote_edit_mode(1) type c.
* components for ALV grid in statistics
data:
      gt_seg_fieldcatalog type lvc_t_fcat, "Fieldcatalog
      gt_seg_sort         type lvc_t_sort, "Sortiertabelle
      gt_seg_selects type lvc_t_indx with header line.
*
class cl_gui_column_tree definition load.
data  g_seg_ok_code like sy-ucomm.      " belongs in top-include.
data  g_seg_tree  type ref to cl_gui_alv_tree_simple.
*DATA  g_header(1) TYPE c.
* create container for alv-tree
data: g_seg_tree_container_name(30) type c value 'SEGMENT_CONTAINER',
        g_seg_custom_container type ref to cl_gui_custom_container.

data gt_seg_select_outtab type lvc_index.

data:  begin of gt_seg_outtab occurs 0,
           appl    like txw_dirsg2-ddtext,
           ddtext  like  dd07v-ddtext,
           segtype like txw_dirsg2-segtype,
           segdata like txw_dirsg2-segdata,
           exp_struct like txw_dirsg2-exp_struct,
       end of gt_seg_outtab.

data : data_in like sy-datum,
       data_fn like sy-datum,
       "w_user  type zhms_user,
       s_bukrs type bukrs,
       s_werks type werks,
       s_matnr type matnr,
       ck_erro(1) type c,
       ck_pend(1) type c,
       ck_corr(1) type c,
       v_msg(1) type c.

types: begin of w_marc,
        matnr type marc-matnr,
        werks type marc-werks,
        steuc type marc-steuc,
       end of w_marc.

data: t_marc type table of w_marc with header line.
