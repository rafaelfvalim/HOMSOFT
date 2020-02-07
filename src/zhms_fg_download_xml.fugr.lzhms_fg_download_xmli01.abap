*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_DOWNLOAD_XMLI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  MOVE sy-ucomm TO ok_code.

  CASE ok_code.
    WHEN 'DOWN'.
      PERFORM f_download_xml.
      CLEAR ok_code.
    WHEN 'PESQ'.
      PERFORM f_pesquisa_evento.
      CLEAR ok_code.
    WHEN 'ENVIAR'.
      PERFORM f_enviar_mde.
      CLEAR ok_code.
    WHEN 'UPLOAD'.
      PERFORM upload_chaves.
      CLEAR ok_code.
    WHEN 'EXIBE'.
      PERFORM exibe_chaves.
      CLEAR ok_code.
    WHEN 'REFRESH'.
      PERFORM refresh.
      CLEAR ok_code.
    WHEN 'BT_HIS'.
      PERFORM busca_hist.
      CLEAR ok_code.
    WHEN 'CLEAR'.
      REFRESH:lt_doctos.

      CLEAR: vg_chave,
             vg_data_ate,
             vg_data_de.
    WHEN 'BACK'.
      CLEAR ok_code.
      LEAVE TO SCREEN 0.
  ENDCASE.


ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  M_USER_COMMAND_0100_EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_user_command_0100_exit INPUT.

  MOVE sy-ucomm TO ok_code.

  CASE ok_code.
    WHEN 'CANC'  OR  'EXIT'.
      LEAVE TO SCREEN 0.

    WHEN OTHERS.
  ENDCASE.

  CLEAR sy-ucomm.

ENDMODULE.                 " M_USER_COMMAND_0100_EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Form  F_DOWNLOAD_XML
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_download_xml .

*** Verifica Autorização usuario
  CALL FUNCTION 'ZHMS_FM_SECURITY'
    EXPORTING
      value         = 'DOWNLOAD_XML'
    EXCEPTIONS
      authorization = 1
      OTHERS        = 2.

  IF sy-subrc <> 0.
    MESSAGE e000(zhms_security). "   Usuário sem autorização
  ENDIF.


  CHECK vg_chave IS NOT INITIAL.

  REFRESH: lt_tb_evmn[], lt_cod_map[].
  CLEAR vg_tip_doc.

*** Resgata Tipo do documento
  IF vg_cte EQ abap_true.
    MOVE 'CTE' TO vg_tip_doc.
  ELSEIF vg_nfe EQ abap_true.
    MOVE 'NFE' TO vg_tip_doc.
  ELSEIF vg_nfes EQ abap_true.
    MOVE 'NFSE' TO vg_tip_doc.
  ENDIF.

*** Seleciona menssageria
  CLEAR  vg_mensg.
  SELECT SINGLE mensg FROM zhms_tb_messagin INTO vg_mensg WHERE natdc EQ '02'
                                                            AND typed EQ vg_tip_doc.

*** Seleciona Mneumonicos
  SELECT *
    FROM zhms_tb_mapconec
    INTO TABLE lt_cod_map
   WHERE natdc EQ '02'
     AND typed EQ vg_tip_doc
     AND event EQ '6'
     AND mensg EQ vg_mensg.

  IF sy-subrc IS INITIAL.
    READ TABLE lt_cod_map INTO ls_cod_map INDEX 1.
    PERFORM f_mapping_mneumonico.
    IF lt_mapeamento[] IS INITIAL.
      MESSAGE i007.
      EXIT.
    ENDIF.
    PERFORM f_monta_mneumonico_download.
    PERFORM f_call_conector_download.
  ENDIF.

ENDFORM.                    " F_DOWNLOAD_XML
*&---------------------------------------------------------------------*
*&      Form  F_PESQUISA_EVENTO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_pesquisa_evento .

*** Verifica Autorização usuario
  CALL FUNCTION 'ZHMS_FM_SECURITY'
    EXPORTING
      value         = 'PESQ_LOG_NOTA'
    EXCEPTIONS
      authorization = 1
      OTHERS        = 2.

  IF sy-subrc <> 0.
    MESSAGE e000(zhms_security). "   Usuário sem autorização
  ENDIF.

*  IF vg_chave IS NOT INITIAL.
**** Seleciona os eventos
*    PERFORM f_get_log_eventos.
*  ELSE.

  REFRESH tr_data[].
  CLEAR ls_data.
  IF vg_data_de IS NOT INITIAL AND vg_data_de IS INITIAL.

    MOVE: vg_data_de  TO ls_data-low,
          'I'         TO ls_data-sign,
          'EQ'        TO ls_data-option.
    APPEND ls_data TO tr_data.
  ELSEIF vg_data_de IS  INITIAL AND vg_data_de IS NOT INITIAL.

    MOVE: vg_data_ate TO ls_data-high,
    'I'         TO ls_data-sign,
    'EQ'        TO ls_data-option.
    APPEND ls_data TO tr_data.

  ELSEIF vg_data_de IS NOT INITIAL AND vg_data_de IS NOT INITIAL.

    MOVE: vg_data_de  TO ls_data-low,
          vg_data_ate TO ls_data-high,
          'I'         TO ls_data-sign,
          'BT'        TO ls_data-option.
    APPEND ls_data TO tr_data.

  ENDIF.

  REFRESH: lt_doctos[], it_cabdoc[].
*    IF tr_data[] IS INITIAL.
*      MESSAGE i012.
*      EXIT.
*    ELSE.

  IF vg_chave IS INITIAL.
    SELECT *
       FROM zhms_tb_cabdoc
      INTO TABLE it_cabdoc
      WHERE docdt IN tr_data
        AND typed EQ 'NFE'
        AND bukrs EQ vg_bukrs
        AND branch EQ ls_branch-branch.

  ELSE.
    SELECT *
       FROM zhms_tb_cabdoc
      INTO TABLE it_cabdoc
      WHERE docdt IN tr_data
        AND typed EQ 'NFE'
        AND bukrs EQ vg_bukrs
        AND branch EQ ls_branch-branch
        AND chave EQ vg_chave.

  ENDIF.

  IF sy-subrc IS INITIAL.
    LOOP AT it_cabdoc INTO ls_cabdoc.
      ls_doctos-detal-id  = '@10@'.
      ls_doctos-chave     = ls_cabdoc-chave.
      ls_doctos-nfenum    = ls_cabdoc-chave+25(9).
      ls_doctos-serie     = ls_cabdoc-chave+22(3).
      ls_doctos-dtemiss   = ls_cabdoc-chave+2(4).
      ls_doctos-cnpjemiss = ls_cabdoc-chave+6(14).

      SELECT SINGLE lifnr
        INTO ls_doctos-razao
        FROM lfa1
        WHERE stcd1 = ls_cabdoc-chave+6(14) OR
              stcd2 = ls_cabdoc-chave+6(14).

      IF ls_doctos-razao IS INITIAL.
        SELECT SINGLE kunnr
        INTO ls_doctos-razao
        FROM kna1
        WHERE stcd1 = ls_cabdoc-chave+6(14) OR
              stcd2 = ls_cabdoc-chave+6(14).

      ENDIF.
      APPEND ls_doctos TO lt_doctos.
      CLEAR ls_doctos.
    ENDLOOP.
  ELSE.
    MESSAGE i013.
    EXIT.
  ENDIF.

*    ENDIF.
*  ENDIF.


ENDFORM.                    " F_PESQUISA_EVENTO

*&SPWIZARD: INPUT MODULE FOR TC 'TC_001'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE tc_001_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TC_001'
                              'LT_TC_STATUS'
                              ' '
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.                    "TC_001_USER_COMMAND INPUT
*&---------------------------------------------------------------------*
*&      Module  M_LIST_EVENTS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_list_events INPUT.

**    Dados Locais
  TYPE-POOLS : vrm.
*      DATA: vl_idflw     TYPE  vrm_id VALUE 'VG_FLOWD'.
  DATA: vl_idflw     TYPE  vrm_id VALUE 'LS_EVENTOS-EVTET'.
  DATA: tl_opcoesflw TYPE vrm_values,
        wl_opcoesflw LIKE LINE OF tl_opcoesflw.

  REFRESH : tl_opcoesflw[],
            lt_eventos[].

  CLEAR ls_eventos.

**    Busca dados cadastrados
  SELECT *
    INTO TABLE lt_eventos
    FROM zhms_tb_nfeevt.
*       WHERE natdc EQ wa_cabdoc-natdc
*         AND typed EQ wa_cabdoc-typed.

**    Insere registros na tabela interna de lista
  LOOP AT lt_eventos INTO ls_eventos.
    CLEAR wl_opcoesflw.
    wl_opcoesflw-key  = ls_eventos-evtet.
    wl_opcoesflw-text = ls_eventos-denom.
    APPEND wl_opcoesflw TO tl_opcoesflw.
  ENDLOOP.

**    Insere registros da tabela interna na lista
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = vl_idflw
      values = tl_opcoesflw.

**    tratativa de erros
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDMODULE.                 " M_LIST_EVENTS  INPUT
*&---------------------------------------------------------------------*
*&      Module  M_LIST_BRANCH  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_list_branch INPUT.

**    Dados Locais
  TYPE-POOLS : vrm.
*      DATA: vl_idflw     TYPE  vrm_id VALUE 'VG_FLOWD'.
  DATA: vl_idflw2    TYPE  vrm_id VALUE 'LS_BRANCH-BRANCH'.

  REFRESH : tl_opcoesflw[].

**    Busca dados cadastrados
  SELECT *
    INTO TABLE lt_branch
    FROM j_1bbranch
    WHERE bukrs EQ vg_bukrs.

**    Insere registros na tabela interna de lista
  LOOP AT lt_branch INTO ls_branch.
    CLEAR wl_opcoesflw.
    wl_opcoesflw-key  = ls_branch-branch.
    wl_opcoesflw-text = ls_branch-name.
    APPEND wl_opcoesflw TO tl_opcoesflw.
  ENDLOOP.

**    Insere registros da tabela interna na lista
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = vl_idflw2
      values = tl_opcoesflw.

**    tratativa de erros
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDMODULE.                 " M_LIST_BRANCH  INPUT
*&---------------------------------------------------------------------*
*&      Form  F_ENVIAR_MDE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_enviar_mde .
*** Verifica Autorização usuario
  CALL FUNCTION 'ZHMS_FM_SECURITY'
    EXPORTING
      value         = 'ENVIO_MDE'
    EXCEPTIONS
      authorization = 1
      OTHERS        = 2.

  IF sy-subrc <> 0.
    MESSAGE e000(zhms_security). "   Usuário sem autorização
  ENDIF.


  IF vg_bukrs IS INITIAL.
    MESSAGE i000.
    EXIT.
  ELSE.
    SELECT SINGLE bukrs INTO vg_bukrs FROM j_1bbranch WHERE bukrs EQ vg_bukrs.
    IF sy-subrc IS NOT INITIAL.
      MESSAGE i003.
      EXIT.
    ENDIF.
  ENDIF.

  IF ls_branch-branch IS INITIAL.
    MESSAGE i001.
    EXIT.
  ENDIF.

  IF ls_eventos-evtet IS INITIAL.
    MESSAGE i002.
    EXIT.
  ENDIF.


  IF lt_doctos[] IS NOT INITIAL.
    LOOP AT lt_doctos INTO ls_doctos WHERE mark EQ 'X'.
      MOVE ls_doctos-chave TO ls_arq-chave.
      APPEND ls_arq TO lt_arq.
    ENDLOOP.
  ENDIF.



  IF vg_chave IS INITIAL AND lt_arq[] IS INITIAL.
    MESSAGE i004.
    EXIT.
  ENDIF.

  CLEAR: vl_erro, vl_tam, vg_tip_doc.
  PERFORM f_get_text_editor.

  vl_max = 255.

  vl_tam = strlen( ls_cabeve-xjust ).
**  verifica obrigatoriedade
  IF ls_eventos-cpobs NE 1 AND ls_eventos-evtet EQ '210240'.
    IF vl_tam < 15.
      MESSAGE i005.
      vl_erro = 'X'.
      EXIT.
    ENDIF.

    IF vl_tam GT vl_max.
      MESSAGE i006 WITH vl_max.
      vl_erro = 'X'.
      EXIT.
    ENDIF.
  ENDIF.

  CHECK vl_erro IS INITIAL.

*** Busca CNPJ
  CLEAR vg_cnpj.
  SELECT SINGLE stcd1 INTO vg_cnpj FROM j_1bbranch WHERE bukrs EQ vg_bukrs
                                                     AND branch EQ ls_branch-branch.

  IF sy-subrc IS INITIAL.

    READ TABLE lt_eventos INTO ls_eventos WITH KEY evtet = ls_eventos-evtet.

*    IF vg_cte EQ abap_true.
*      MOVE 'CTE' TO vg_tip_doc.
*    ELSEIF vg_nfe EQ abap_true.
    MOVE 'NFE' TO vg_tip_doc.
*    ELSEIF vg_nfes EQ abap_true.
*      MOVE 'NFSE' TO vg_tip_doc.
*    ENDIF.

*** Seleciona menssageria
    CLEAR  vg_mensg.
    SELECT SINGLE mensg FROM zhms_tb_messagin INTO vg_mensg WHERE natdc EQ '02'
                                                              AND typed EQ vg_tip_doc.

    SELECT *
      FROM zhms_tb_mapconec
      INTO TABLE lt_cod_map
     WHERE natdc EQ '02'
       AND typed EQ vg_tip_doc
       AND event EQ '4'
       AND mensg EQ vg_mensg.

    IF sy-subrc IS INITIAL.
      READ TABLE lt_cod_map INTO ls_cod_map INDEX 1.
      PERFORM f_mapping_mneumonico.
      IF lt_mapeamento[] IS INITIAL.
        MESSAGE i007.
        EXIT.
      ENDIF.
      IF lt_arq[] IS NOT INITIAL.
        LOOP AT lt_arq INTO ls_arq.
          CLEAR: r_fieldcat, ls_cabeve.
          REFRESH: t_where[], fieldcat[], t_campos[], lt_datam[], lt_atrbm[].
          MOVE ls_arq-chave TO vg_chave.
          PERFORM f_insert_log.
          PERFORM f_popula_tb_evmn.
          PERFORM f_call_conector.
        ENDLOOP.
      ELSE.
        PERFORM f_insert_log.
        PERFORM f_popula_tb_evmn.
        PERFORM f_call_conector.
      ENDIF.

    ENDIF.

  ENDIF.

  CLEAR vg_chave.
  REFRESH lt_arq[].

ENDFORM.                    " F_ENVIAR_MDE
*&---------------------------------------------------------------------*
*&      Form  UPLOAD_CHAVES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM upload_chaves .

  REFRESH: lt_arq[].
  REFRESH lt_filetable[].
  CLEAR: ls_filetable, vg_file.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = 'Caminho do Arquivo'
      default_extension       = '.txt'
    CHANGING
      file_table              = lt_filetable
      rc                      = gv_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ELSE.
    READ TABLE lt_filetable INTO ls_filetable INDEX 1.
    vg_file = ls_filetable-filename.
  ENDIF.

  IF NOT vg_file IS INITIAL.

    CALL FUNCTION 'WS_UPLOAD'
    EXPORTING
         filename                  = vg_file " COLOCAR O NOME DA VARIAVEL IRA CONTER O NOME DO ARQUIVO
         filetype                  = 'ASC' " TIPO DE ARQUIVO
* IMPORTING
        TABLES
         data_tab                  = lt_arq " NOME DA TABELA INTERNA QUE IRA RECEBER IRA RECEBER OS DADOS
       EXCEPTIONS
         conversion_error          = 1
         file_open_error           = 2
         file_read_error           = 3
         invalid_type              = 4
         no_batch                  = 5
         unknown_error             = 6
         invalid_table_width       = 7
         gui_refuse_filetransfer   = 8
         customer_error            = 9
         no_authority              = 10
         OTHERS                    = 11.
    IF sy-subrc EQ 0.
      CALL SCREEN 105 STARTING AT 30 1.
    ENDIF.

  ENDIF.
ENDFORM.                    " UPLOAD_CHAVES
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0105  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0105 INPUT.

  MOVE sy-ucomm TO ok_code.

  CASE ok_code.
    WHEN 'OK'.
      LEAVE TO SCREEN 0.
    WHEN 'CANCELAR'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0105  INPUT

*&SPWIZARD: INPUT MODUL FOR TC 'TC_LOG_MDE'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MARK TABLE
MODULE tc_log_mde_mark INPUT.
  DATA: g_tc_log_mde_wa2 LIKE LINE OF lt_doctos.
  IF tc_log_mde-line_sel_mode = 1
  AND ls_doctos-mark = 'X'.
    LOOP AT lt_doctos INTO g_tc_log_mde_wa2
      WHERE mark = 'X'.
      g_tc_log_mde_wa2-mark = ''.
      MODIFY lt_doctos
        FROM g_tc_log_mde_wa2
        TRANSPORTING mark.
    ENDLOOP.
  ENDIF.
  MODIFY lt_doctos
    FROM ls_doctos
    INDEX tc_log_mde-current_line
    TRANSPORTING mark.
ENDMODULE.                    "TC_LOG_MDE_MARK INPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TC_LOG_MDE'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE tc_log_mde_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TC_LOG_MDE'
                              'LT_DOCTOS'
                              'MARK'
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.                    "TC_LOG_MDE_USER_COMMAND INPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0103  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0103 OUTPUT.
  SET PF-STATUS '0103'.
*  SET TITLEBAR '0103'.

ENDMODULE.                 " STATUS_0103  OUTPUT

*&SPWIZARD: INPUT MODULE FOR TC 'TC_LOG_EV_MDE'. DO NOT CHANGE THIS LINE
*&SPWIZARD: PROCESS USER COMMAND
MODULE tc_log_ev_mde_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TC_LOG_EV_MDE'
                              'LT_HIST_EVENTO'
                              ' '
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.                    "TC_LOG_EV_MDE_USER_COMMAND INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0103  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0103 INPUT.

  MOVE sy-ucomm TO ok_code.

  CASE ok_code.
    WHEN 'OK'.
      LEAVE TO SCREEN 0.
    WHEN 'CANCELAR'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.

  CLEAR ok_code.
ENDMODULE.                 " USER_COMMAND_0103  INPUT
