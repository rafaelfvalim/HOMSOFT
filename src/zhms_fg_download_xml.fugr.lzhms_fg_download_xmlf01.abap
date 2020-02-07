*&---------------------------------------------------------------------*
*&  Include           LZHMS_FG_DOWNLOAD_XMLF01
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
 FORM user_ok_tc USING    p_tc_name TYPE dynfnam
                          p_table_name
                          p_mark_name
                 CHANGING p_ok      LIKE sy-ucomm.

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA: l_ok              TYPE sy-ucomm,
         l_offset          TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

*&SPWIZARD: Table control specific operations                          *
*&SPWIZARD: evaluate TC name and operations                            *
   SEARCH p_ok FOR p_tc_name.
   IF sy-subrc <> 0.
     EXIT.
   ENDIF.
   l_offset = strlen( p_tc_name ) + 1.
   l_ok = p_ok+l_offset.
*&SPWIZARD: execute general and TC specific operations                 *
   CASE l_ok.
     WHEN 'INSR'.                      "insert row
       PERFORM fcode_insert_row USING    p_tc_name
                                         p_table_name.
       CLEAR p_ok.

     WHEN 'DELE'.                      "delete row
       PERFORM fcode_delete_row USING    p_tc_name
                                         p_table_name
                                         p_mark_name.
       CLEAR p_ok.

     WHEN 'P--' OR                     "top of list
          'P-'  OR                     "previous page
          'P+'  OR                     "next page
          'P++'.                       "bottom of list
       PERFORM compute_scrolling_in_tc USING p_tc_name
                                             l_ok.
       CLEAR p_ok.
*     WHEN 'L--'.                       "total left
*       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
*
*     WHEN 'L-'.                        "column left
*       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
*
*     WHEN 'R+'.                        "column right
*       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
*
*     WHEN 'R++'.                       "total right
*       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
*
     WHEN 'MARK'.                      "mark all filled lines
       PERFORM fcode_tc_mark_lines USING p_tc_name
                                         p_table_name
                                         p_mark_name   .
       CLEAR p_ok.

     WHEN 'DMRK'.                      "demark all filled lines
       PERFORM fcode_tc_demark_lines USING p_tc_name
                                           p_table_name
                                           p_mark_name .
       CLEAR p_ok.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.

   ENDCASE.

 ENDFORM.                              " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
 FORM fcode_insert_row
               USING    p_tc_name           TYPE dynfnam
                        p_table_name             .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA l_lines_name       LIKE feld-name.
   DATA l_selline          LIKE sy-stepl.
   DATA l_lastline         TYPE i.
   DATA l_line             TYPE i.
   DATA l_table_name       LIKE feld-name.
   FIELD-SYMBOLS <tc>                 TYPE cxtab_control.
   FIELD-SYMBOLS <table>              TYPE STANDARD TABLE.
   FIELD-SYMBOLS <lines>              TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

   ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
   CONCATENATE p_table_name '[]' INTO l_table_name. "table body
   ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: get looplines of TableControl                              *
   CONCATENATE 'G_' p_tc_name '_LINES' INTO l_lines_name.
   ASSIGN (l_lines_name) TO <lines>.

*&SPWIZARD: get current line                                           *
   GET CURSOR LINE l_selline.
   IF sy-subrc <> 0.                   " append line to table
     l_selline = <tc>-lines + 1.
*&SPWIZARD: set top line                                               *
     IF l_selline > <lines>.
       <tc>-top_line = l_selline - <lines> + 1 .
     ELSE.
       <tc>-top_line = 1.
     ENDIF.
   ELSE.                               " insert line into table
     l_selline = <tc>-top_line + l_selline - 1.
     l_lastline = <tc>-top_line + <lines> - 1.
   ENDIF.
*&SPWIZARD: set new cursor line                                        *
   l_line = l_selline - <tc>-top_line + 1.

*&SPWIZARD: insert initial line                                        *
   INSERT INITIAL LINE INTO <table> INDEX l_selline.
   <tc>-lines = <tc>-lines + 1.
*&SPWIZARD: set cursor                                                 *
   SET CURSOR LINE l_line.

 ENDFORM.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
 FORM fcode_delete_row
               USING    p_tc_name           TYPE dynfnam
                        p_table_name
                        p_mark_name   .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA l_table_name       LIKE feld-name.

   FIELD-SYMBOLS <tc>         TYPE cxtab_control.
   FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
   FIELD-SYMBOLS <wa>.
   FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

   ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
   CONCATENATE p_table_name '[]' INTO l_table_name. "table body
   ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: delete marked lines                                        *
   DESCRIBE TABLE <table> LINES <tc>-lines.

   LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
     ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

     IF <mark_field> = 'X'.
       DELETE <table> INDEX syst-tabix.
       IF sy-subrc = 0.
         <tc>-lines = <tc>-lines - 1.
       ENDIF.
     ENDIF.
   ENDLOOP.

 ENDFORM.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*      -->P_OK       ok code
*----------------------------------------------------------------------*
 FORM compute_scrolling_in_tc USING    p_tc_name
                                       p_ok.
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA l_tc_new_top_line     TYPE i.
   DATA l_tc_name             LIKE feld-name.
   DATA l_tc_lines_name       LIKE feld-name.
   DATA l_tc_field_name       LIKE feld-name.

   FIELD-SYMBOLS <tc>         TYPE cxtab_control.
   FIELD-SYMBOLS <lines>      TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

   ASSIGN (p_tc_name) TO <tc>.
*&SPWIZARD: get looplines of TableControl                              *
   CONCATENATE 'G_' p_tc_name '_LINES' INTO l_tc_lines_name.
   ASSIGN (l_tc_lines_name) TO <lines>.


*&SPWIZARD: is no line filled?                                         *
   IF <tc>-lines = 0.
*&SPWIZARD: yes, ...                                                   *
     l_tc_new_top_line = 1.
   ELSE.
*&SPWIZARD: no, ...                                                    *
     CALL FUNCTION 'SCROLLING_IN_TABLE'
       EXPORTING
         entry_act             = <tc>-top_line
         entry_from            = 1
         entry_to              = <tc>-lines
         last_page_full        = 'X'
         loops                 = <lines>
         ok_code               = p_ok
         overlapping           = 'X'
       IMPORTING
         entry_new             = l_tc_new_top_line
       EXCEPTIONS
*        NO_ENTRY_OR_PAGE_ACT  = 01
*        NO_ENTRY_TO           = 02
*        NO_OK_CODE_OR_PAGE_GO = 03
         OTHERS                = 0.
   ENDIF.

*&SPWIZARD: get actual tc and column                                   *
   GET CURSOR FIELD l_tc_field_name
              AREA  l_tc_name.

   IF syst-subrc = 0.
     IF l_tc_name = p_tc_name.
*&SPWIZARD: et actual column                                           *
       SET CURSOR FIELD l_tc_field_name LINE 1.
     ENDIF.
   ENDIF.

*&SPWIZARD: set the new top line                                       *
   <tc>-top_line = l_tc_new_top_line.


 ENDFORM.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
 FORM fcode_tc_mark_lines USING p_tc_name
                                p_table_name
                                p_mark_name.
*&SPWIZARD: EGIN OF LOCAL DATA-----------------------------------------*
   DATA l_table_name       LIKE feld-name.

   FIELD-SYMBOLS <tc>         TYPE cxtab_control.
   FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
   FIELD-SYMBOLS <wa>.
   FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

   ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
   CONCATENATE p_table_name '[]' INTO l_table_name. "table body
   ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: mark all filled lines                                      *
   LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
     ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

     <mark_field> = 'X'.
   ENDLOOP.
 ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
 FORM fcode_tc_demark_lines USING p_tc_name
                                  p_table_name
                                  p_mark_name .
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
   DATA l_table_name       LIKE feld-name.

   FIELD-SYMBOLS <tc>         TYPE cxtab_control.
   FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
   FIELD-SYMBOLS <wa>.
   FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

   ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
   CONCATENATE p_table_name '[]' INTO l_table_name. "table body
   ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: demark all filled lines                                    *
   LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
     ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

     <mark_field> = space.
   ENDLOOP.
 ENDFORM.                                          "fcode_tc_mark_lines
*&---------------------------------------------------------------------*
*&      Form  F_MAPPING_MNEUMONICO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM f_mapping_mneumonico .

   IF ls_cod_map-codmp IS NOT INITIAL.

     SELECT * FROM zhms_tb_mapdatac INTO TABLE lt_mapeamento WHERE codmp EQ ls_cod_map-codmp.

   ENDIF.

 ENDFORM.                    " F_MAPPING_MNEUMONICO
*&---------------------------------------------------------------------*
*&      Form  F_INSERT_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM f_insert_log.

     CLEAR: vg_lote_s.

*** Gera Lote Sefaz
   CALL FUNCTION 'ZHMS_FM_LOTE_DADOS'
     EXPORTING
       v_objeto = 'ZHMS_ON_LS'
     IMPORTING
       v_lote   = vg_lote_s.

   IF  vg_lote_s IS NOT INITIAL.
     MOVE: '02'             TO ls_cabeve-natdc,
           vg_tip_doc       TO ls_cabeve-typed,
           ls_eventos-evtet TO ls_cabeve-tpeve,
           vg_chave         TO ls_cabeve-chave,
           ls_eventos-evtet TO ls_cabeve-tpeve,
           '1'              TO ls_cabeve-nseqev.

     CONCATENATE 'ID' ls_cabeve-tpeve ls_cabeve-chave ls_cabeve-nseqev INTO ls_cabeve-ideve.
     CONDENSE ls_cabeve-ideve NO-GAPS.

*** Busca versão Layout
     SELECT SINGLE versn FROM zhms_tb_ev_vrs INTO ls_cabeve-versa WHERE natdc  EQ '02'
                                                                    AND typed  EQ vg_tip_doc
                                                                    AND event  EQ '4'
                                                                    AND ativo  EQ 'X'.

     MOVE:  vg_lote_s       TO ls_cabeve-idlot,
            ls_cabeve-versa TO ls_cabeve-verse,
            vg_chave(2)     TO ls_cabeve-corga.

*** Versão do ambiente
     SELECT SINGLE tpamb FROM zhms_tb_tpamb INTO ls_cabeve-tpamb WHERE tpamb IS NOT NULL.

*** CNPJ
     MOVE vg_cnpj TO ls_cabeve-cnpj.

*** Data e hora do evento
     PERFORM f_get_hora.

     READ TABLE lt_eventos INTO ls_eventos WITH KEY evtet = ls_eventos-evtet.
     IF sy-subrc EQ 0.
**** Descrição do envento
       CALL FUNCTION 'SCP_REPLACE_STRANGE_CHARS'
         EXPORTING
           intext  = ls_eventos-denom
         IMPORTING
           outtext = ls_cabeve-descev.
     ENDIF.
*** Justificativa
     PERFORM f_get_text_editor.

*** Usuario
     MOVE sy-uname TO ls_cabeve-usuario.

*** insere tavela de eventos
     MODIFY zhms_tb_cabeve FROM ls_cabeve.

     IF sy-subrc IS INITIAL.
       COMMIT WORK.
     ELSE.
       ROLLBACK WORK.
     ENDIF.

   ENDIF.

 ENDFORM.                    " F_INSERT_LOG
*&---------------------------------------------------------------------*
*&      Form  F_GET_HORA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM f_get_hora .

   CALL FUNCTION 'J_1B_BRANCH_READ'
     EXPORTING
       branch            = ls_branch-branch
       company           = vg_bukrs
     IMPORTING
       address           = ls_sadr
     EXCEPTIONS
       branch_not_found  = 1
       address_not_found = 2
       company_not_found = 3
       OTHERS            = 4.

   IF sy-subrc IS INITIAL.

     GET TIME STAMP FIELD iv_timestamp.

     " Determine time zone
     IF NOT ls_sadr-tzone IS INITIAL.
       iv_timezone = ls_sadr-tzone.
     ELSE.
       iv_timezone = sy-zonlo.
     ENDIF.

     CONVERT TIME STAMP iv_timestamp TIME ZONE iv_timezone
        INTO DATE ev_date TIME ev_time.

     CALL FUNCTION 'TZON_GET_OFFSET'
       EXPORTING
         if_timezone      = iv_timezone
         if_local_date    = ev_date
         if_local_time    = ev_time
       IMPORTING
         ef_utcdiff       = ev_utcdiff
         ef_utcsign       = ev_utcsign
       EXCEPTIONS
         conversion_error = 1
         OTHERS           = 2.

     IF sy-subrc <> 0. "Se der erro na conversão - utilizar código antigo com UTC Fixo
       CONCATENATE sy-datum(4) '-' sy-datum+4(2) '-' sy-datum+6 'T'
       INTO ls_cabeve-dheve.
       CONCATENATE ls_cabeve-dheve sy-uzeit(2) ':' sy-datum+2(2) ':' sy-datum+6
       INTO ls_cabeve-dheve.
       CONCATENATE ls_cabeve-dheve '-03:00' INTO ls_cabeve-dheve.
     ELSE.
       CONCATENATE ev_date(4) '-' ev_date+4(2) '-' ev_date+6 'T'
       INTO ls_cabeve-dheve.
       CONCATENATE ls_cabeve-dheve ev_time(2) ':' ev_time+2(2) ':' ev_time+4
       INTO ls_cabeve-dheve.
       CONCATENATE ls_cabeve-dheve ev_utcsign ev_utcdiff(2) ':00'  INTO ls_cabeve-dheve.
     ENDIF.
   ENDIF.


 ENDFORM.                    " F_GET_HORA
*&---------------------------------------------------------------------*
*&      Form  F_GET_TEXT_EDITOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM f_get_text_editor .

   CHECK ob_dcevt_obs IS NOT INITIAL.

** Recupera o texto digitado no editor
   CALL METHOD ob_dcevt_obs->get_text_as_r3table
     IMPORTING
       table = tl_textnote.

** Percorrer dados e inserir na variavel de observações
   tl_itxw_note[] = tl_textnote[].

   CLEAR ls_cabeve-xjust.
   LOOP AT tl_itxw_note INTO wl_itxw_note.
     CONCATENATE ls_cabeve-xjust wl_itxw_note-line INTO ls_cabeve-xjust.
   ENDLOOP.

 ENDFORM.                    " F_GET_TEXT_EDITOR
*&---------------------------------------------------------------------*
*&      Form  F_POPULA_TB_EVMN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM f_popula_tb_evmn .

   DATA: lv_campo TYPE char80.

   CLEAR lv_index.
   LOOP AT lt_mapeamento INTO ls_mapeamento.
     MOVE sy-tabix TO lv_index.

*     IF  ls_mapeamento-tbfld IS NOT INITIAL.

     IF ls_mapeamento-rotin IS INITIAL.
*** Monta nome da tabela
       r_fieldcat-fieldname = ls_mapeamento-tbfld.
       r_fieldcat-ref_field = ls_mapeamento-tbfld.
       r_fieldcat-ref_table = 'ZHMS_TB_CABEVE'.
       APPEND r_fieldcat TO fieldcat.

*** Monta clausula Where
       t_where-line = 'NATDC = ''02'' AND'.
       APPEND t_where.
       CONCATENATE 'TYPED = ''' vg_tip_doc '''' ' AND' INTO t_where-line.
       APPEND t_where.
       CONCATENATE 'TPEVE = ''' ls_eventos-evtet '''' ' AND' INTO t_where-line.
       APPEND t_where.
       CONCATENATE 'CHAVE = ''' vg_chave '''' ' AND' INTO t_where-line.
       APPEND t_where.
       t_where-line = 'NSEQEV = ''1'' AND' .
       APPEND t_where.
       CONCATENATE 'DHEVE = ''' ls_cabeve-dheve '''' INTO t_where-line.
       APPEND t_where.

*** Monta nome dos campos de seleção
       LOOP AT fieldcat INTO r_fieldcat  .
         t_campos-line = r_fieldcat-fieldname.
         APPEND t_campos.
       ENDLOOP.

*** Seleciona valor do campo
       CLEAR:  lv_valor, lv_campo.
       READ TABLE t_campos INTO lv_campo INDEX 1.
       IF lv_campo IS NOT INITIAL.
         CLEAR lv_valor.
         SELECT SINGLE (t_campos)
          INTO lv_valor
          FROM zhms_tb_cabeve
          WHERE (t_where).
       ENDIF.
     ELSE.
       PERFORM (ls_mapeamento-rotin) IN PROGRAM saplzhms_fg_download_xml IF FOUND.
     ENDIF.

     REFRESH: t_campos[], t_where[], fieldcat[].
     CLEAR r_fieldcat.

     IF ls_mapeamento-eatrb IS INITIAL.
       MOVE lv_index TO ls_datam-seqnc.
       MOVE: ls_mapeamento-mneum TO ls_datam-mneum,
             lv_valor            TO ls_datam-value.
       APPEND ls_datam TO lt_datam.
       CLEAR ls_datam.
     ELSE.
       MOVE lv_index TO ls_atrbm-seqnc.
       MOVE: ls_mapeamento-mneum TO ls_atrbm-mneum,
             lv_valor            TO ls_atrbm-value.
       APPEND ls_atrbm TO lt_atrbm.
       CLEAR ls_atrbm.
     ENDIF.


*     ELSE.

*       PERFORM (ls_mapeamento-rotin) IN PROGRAM saplzhms_fg_download_xml IF FOUND.
*
*       MOVE lv_index TO ls_atrbm-seqnc.
*       MOVE: ls_mapeamento-mneum TO ls_atrbm-mneum,
*             lv_valor            TO ls_atrbm-value.
*       APPEND ls_atrbm TO lt_atrbm.
*       CLEAR ls_atrbm.

*     ENDIF.

   ENDLOOP.

*   IF ls_datamx IS NOT INITIAL.
*     DELETE lt_atrbm WHERE mneum EQ ls_datamx-mneum.
*     READ TABLE lt_atrbm WITH KEY mneum = ls_datamx-mneum TRANSPORTING NO FIELDS.
*     IF sy-subrc IS INITIAL.
*       MODIFY lt_datam FROM ls_datamx INDEX sy-tabix.
*     ENDIF.
**
*   ENDIF.
*   READ TABLE lt_datam INTO ls_datam WITH KEY seqnc = lv_index_aux.
*   IF sy-subrc IS INITIAL.
*     MODIFY lt_datam FROM ls_datamx INDEX sy-tabix.
*   ENDIF.


   CLEAR: ls_tb_evmn, ls_datam.

*** insere tavela de eventos
   MODIFY zhms_tb_cabeve FROM ls_cabeve.

   IF sy-subrc IS INITIAL.
     COMMIT WORK.
   ELSE.
     ROLLBACK WORK.
   ENDIF.

 ENDFORM.                    " F_POPULA_TB_EVMN
*&---------------------------------------------------------------------*
*&      Form  F_CALL_CONECTOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM f_call_conector .

   DATA lv_extpd TYPE zhms_de_extpd.

   MOVE vg_tip_doc TO lv_extpd.
   CLEAR vg_msg_text.

   CALL FUNCTION 'ZHMS_FM_QUAZARIS'
     EXPORTING
       exnat    = '02'
       extpd    = lv_extpd
       exevt    = '4'
       direc    = 'S'
       usuar    = sy-uname
     IMPORTING
       msg_text = vg_msg_text
     TABLES
       msgdatam = lt_datam
       msgatrbm = lt_atrbm.

   REFRESH: lt_datam[], lt_atrbm[].

   IF vg_msg_text IS NOT INITIAL.
     MESSAGE vg_msg_text TYPE 'I'.
     EXIT.
   ELSE.
     MESSAGE s009.
*   Solicitação Realizada
   ENDIF.

 ENDFORM.                    " F_CALL_CONECTOR
*&---------------------------------------------------------------------*
*&      Form  F_CALL_CONECTOR_DOWNLOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM f_call_conector_download .

   DATA lv_extpd TYPE zhms_de_extpd.

   MOVE vg_tip_doc TO lv_extpd.
   CLEAR vg_msg_text.

   CALL FUNCTION 'ZHMS_FM_QUAZARIS'
     EXPORTING
       exnat    = '02'
       extpd    = lv_extpd
       exevt    = '4'
       direc    = 'S'
       usuar    = sy-uname
     IMPORTING
       msg_text = vg_msg_text
     TABLES
       msgdatam = lt_datam
       msgatrbm = lt_atrbm.

   REFRESH: lt_datam[], lt_atrbm[].

   IF vg_msg_text IS NOT INITIAL.
     MESSAGE vg_msg_text TYPE 'I'.
     EXIT.
   ENDIF.


 ENDFORM.                    " F_CALL_CONECTOR_DOWNLOAD
*&---------------------------------------------------------------------*
*&      Form  F_MONTA_MNEUMONICO_DOWNLOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM f_monta_mneumonico_download .

*** Gera Lote Homeinfo
   CLEAR  vg_lote_h.
   CALL FUNCTION 'ZHMS_FM_LOTE_DADOS'
     EXPORTING
       v_objeto = 'ZHMS_ON_LT'
     IMPORTING
       v_lote   = vg_lote_h.

*** Busca versão
   CLEAR vg_versao.
   SELECT SINGLE versn FROM zhms_tb_ev_vrs INTO vg_versao WHERE natdc  EQ '02'
                                                            AND typed  EQ vg_tip_doc
                                                            AND event  EQ '6'
                                                            AND ativo  EQ 'X'.

   REFRESH: lt_datam[], lt_atrbm[].
   CLEAR: ls_atrbm, lv_index, ls_datam.

   LOOP AT lt_mapeamento INTO ls_mapeamento.
     MOVE sy-tabix TO lv_index.

     IF ls_mapeamento-eatrb IS INITIAL AND ls_mapeamento-tbfld IS NOT INITIAL.

       IF ls_mapeamento-fixo IS NOT INITIAL.
         MOVE ls_mapeamento-fixo  TO lv_valor.
       ELSE.
         CALL FUNCTION 'ZHMS_FM_MAPPING_ROTINA'
           EXPORTING
             id_rotina = ls_mapeamento-rotin.
       ENDIF.

       MOVE lv_index TO ls_datam-seqnc.
       MOVE: ls_mapeamento-mneum TO ls_datam-mneum,
             lv_valor            TO ls_datam-value.
       APPEND ls_datam TO lt_datam.
       CLEAR ls_datam.

     ELSE.

       IF ls_mapeamento-fixo IS NOT INITIAL.
         MOVE ls_mapeamento-fixo  TO lv_valor.
       ELSE.
         CALL FUNCTION 'ZHMS_FM_MAPPING_ROTINA'
           EXPORTING
             id_rotina = ls_mapeamento-rotin.
       ENDIF.

       MOVE lv_index TO ls_atrbm-seqnc.
       MOVE: ls_mapeamento-mneum TO ls_atrbm-mneum,
             lv_valor            TO ls_atrbm-value.
       APPEND ls_atrbm TO lt_atrbm.
       CLEAR ls_atrbm.

     ENDIF.
   ENDLOOP.

 ENDFORM.                    " F_MONTA_MNEUMONICO_DOWNLOAD
*&---------------------------------------------------------------------*
*&      Form  F_GET_LOG_EVENTOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM f_get_log_eventos .

   CHECK vg_chave IS NOT INITIAL.

   SELECT a~tpeve a~descev a~xjust
          b~dtalt b~hralt a~usuario
          b~sthms
     FROM zhms_tb_cabeve AS a
     INNER JOIN zhms_tb_evst AS b
     ON a~chave EQ b~chave
     INTO TABLE lt_tc_status
     WHERE a~chave EQ vg_chave.

   IF lt_tc_status[] IS INITIAL.
     MESSAGE w008.
   ENDIF.

 ENDFORM.                    " F_GET_LOG_EVENTOS
*&---------------------------------------------------------------------*
*&      Form  F_GET_CHAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
 FORM f_get_chave.
   MOVE vg_chave TO lv_valor.
 ENDFORM.                    "F_GET_CHAVE
*&---------------------------------------------------------------------*
*&      Form  F_GET_VERSAO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM f_get_versao .
*** Busca versão
   SELECT SINGLE versn FROM zhms_tb_ev_vrs INTO lv_valor WHERE natdc EQ '02'
                                                                  AND typed  EQ vg_tip_doc
                                                                  AND event  EQ '6'
                                                                  AND ativo  EQ 'X'.
 ENDFORM.                    " F_GET_VERSAO
*&---------------------------------------------------------------------*
*&      Form  F_GET_AMBIENTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM f_get_ambiente .

   SELECT SINGLE tpamb FROM zhms_tb_tpamb INTO lv_valor WHERE tpamb IS NOT NULL.

 ENDFORM.                    " F_GET_AMBIENTE
*&---------------------------------------------------------------------*
*&      Form  F_GET_CNPJ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM f_get_cnpj .

   CLEAR vg_cnpj.
   SELECT SINGLE stcd1 INTO vg_cnpj FROM j_1bbranch WHERE bukrs  EQ vg_bukrs
                                                      AND branch EQ ls_branch-branch.

   IF sy-subrc IS INITIAL.
     MOVE vg_cnpj TO lv_valor.
   ENDIF.

 ENDFORM.                    " F_GET_CNPJ
*&---------------------------------------------------------------------*
*&      Form  F_VERS_LAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM f_vers_lay.

   CLEAR lv_valor.
   MOVE ls_cabeve-versa TO lv_valor.

 ENDFORM.                    " F_VERS_LAY
*&---------------------------------------------------------------------*
*&      Form  F_VERS_EVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM f_vers_eve.

   CLEAR lv_valor.
   SELECT SINGLE value INTO lv_valor FROM zhms_tb_evvl_atr WHERE mneum EQ ls_mapeamento-mneum.

*** Versão do evento
   MOVE: lv_valor TO ls_cabeve-vereve,
         lv_valor TO ls_datamx-value.

 ENDFORM.                    " F_VERS_EVE
*&---------------------------------------------------------------------*
*&      Form  F_VERS_EVEX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM f_vers_evex.

   MOVE: lv_index            TO ls_datamx-seqnc,
         lv_index            TO lv_index_aux,
         ls_mapeamento-mneum TO ls_datamx-mneum.

 ENDFORM.                    " F_VERS_EVEX
*&---------------------------------------------------------------------*
*&      Form  EXIBE_CHAVES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM exibe_chaves .
   IF lt_arq[] IS NOT INITIAL.
     CALL SCREEN 105 STARTING AT 30 1.
   ELSE.
     PERFORM upload_chaves.
   ENDIF.
 ENDFORM.                    " EXIBE_CHAVES
*&---------------------------------------------------------------------*
*&      Form  REFRESH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM refresh .
   REFRESH lt_arq[].
*   MESSAGE i011.
   EXIT.
 ENDFORM.                    " REFRESH
*&---------------------------------------------------------------------*
*&      Form  BUSCA_HIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
 FORM busca_hist .
     DATA: l_row       TYPE i,
         l_field(20) TYPE c,
         wa_doctos LIKE LINE OF lt_doctos .

   GET CURSOR LINE l_row.
   l_row = tc_log_mde-top_line + l_row - 1.
   READ TABLE lt_doctos INDEX l_row INTO wa_doctos.

   CHECK wa_doctos-chave IS NOT INITIAL.

   REFRESH lt_hist_evento[].
   SELECT tpeve   nseqev  lote
          xmotivo dthrreg protoco
          dataenv horaenv usuario
     FROM zhms_tb_histev
     INTO TABLE lt_hist_evento
    WHERE ( event EQ '4' OR event EQ '5' ) AND
          chave EQ  wa_doctos-chave.

   SORT lt_hist_evento BY dataenv horaenv.

   CLEAR sy-ucomm.

   IF lt_hist_evento[] IS NOT INITIAL.
     CLEAR ok_code.
     CALL SCREEN 0103 STARTING AT 20  1.
   ELSE.
     CLEAR ok_code.
     MESSAGE i014.
   ENDIF.

 ENDFORM.                    " BUSCA_HIST
