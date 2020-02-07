*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_REPORTF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_LOAD_IMAGES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0110   text
*      -->P_0111   text
*----------------------------------------------------------------------*
FORM f_load_images  USING p_id
                             p_url.
***   ICON RATING NEUTRAL
  CALL METHOD ob_html_index->load_mime_object
    EXPORTING
      object_id            = p_id
      object_url           = p_url
    EXCEPTIONS
      object_not_found     = 1
      dp_invalid_parameter = 1
      dp_error_general     = 3
      OTHERS               = 4.

  IF sy-subrc NE 0.
***     Erro Interno. Contatar Suporte.
*    MESSAGE e000 WITH text-000.
  ENDIF.

ENDFORM.                    " F_LOAD_IMAGES
*&---------------------------------------------------------------------*
*&      Form  F_SEL_INDEX_NFS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_sel_index_nfs .

***   Selecionando Naturezas dos Documentos Cadastradas
  PERFORM f_sel_masterd_index.

  LOOP AT t_nature INTO wa_nature.
    CLEAR wa_index.
    MOVE:  '' TO wa_index-fathr,
           wa_nature-natdc TO wa_index-sonhr.

***     Lendo denominação da Natureza do Documento
    CLEAR wa_nature_t.
    READ TABLE t_nature_t INTO     wa_nature_t
                          WITH KEY natdc = wa_nature-natdc BINARY SEARCH.

    IF sy-subrc EQ 0.
      MOVE wa_nature_t-denom TO wa_index-denom.
    ENDIF.

***     Preparando Ícone
    CLEAR: vg_icon_id,
           vg_icon_url.

    MOVE wa_nature-icons TO vg_icon_id.
    CONCATENATE wa_nature-icons '.GIF'
           INTO vg_icon_url.
    MOVE vg_icon_url TO wa_index-iconh.

***     Carregando Ícone Padrão
    PERFORM f_load_images USING vg_icon_id
                                vg_icon_url.

    APPEND wa_index TO t_index.

    LOOP AT t_type INTO  wa_type
                   WHERE natdc EQ wa_nature-natdc.

      CLEAR wa_index.
      MOVE: wa_nature-natdc TO wa_index-fathr,
            wa_type-typed   TO wa_index-sonhr,
            wa_type-loctp   TO wa_index-loctp.

***       Lendo denominação do Tipo de Documento
      CLEAR wa_type_t.
      READ TABLE t_type_t INTO     wa_type_t
                          WITH KEY natdc = wa_type-natdc
                                   typed = wa_type-typed
                                   loctp = wa_type-loctp BINARY SEARCH.

      IF sy-subrc EQ 0.
        MOVE wa_type_t-denom TO wa_index-denom.
      ENDIF.

      APPEND wa_index TO t_index.
    ENDLOOP.
  ENDLOOP.

ENDFORM.                    " F_SEL_INDEX_NFS
*&---------------------------------------------------------------------*
*&      Form  F_SEL_MASTERD_INDEX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_sel_masterd_index .

  REFRESH: t_nature,
                t_nature_t.
  CLEAR:   wa_nature,
           wa_nature_t.

***   Lendo Nature do Documento
  SELECT * FROM zhms_tb_nature
           INTO TABLE t_nature.

  IF sy-subrc EQ 0.
    SORT t_nature BY natdc.

***     Selecionando Tipos de Documentos Cadastrados
    PERFORM f_sel_type_docs.

***     Lendo Denominação da Nature do Documento
    SELECT * FROM zhms_tx_nature
             INTO TABLE t_nature_t
             FOR ALL ENTRIES IN t_nature
             WHERE natdc EQ t_nature-natdc      AND
                   spras EQ sy-langu.

    IF sy-subrc EQ 0.
      SORT t_nature_t BY natdc.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_SEL_MASTERD_INDEX
*&---------------------------------------------------------------------*
*&      Form  F_SEL_TYPE_DOCS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_sel_type_docs .

  REFRESH: t_type,
                t_type_t.
  CLEAR:   wa_type,
           wa_type_t.

***   Lendo Nature do Documento
  SELECT * FROM zhms_tb_type
           INTO TABLE t_type
           FOR ALL ENTRIES IN t_nature
           WHERE natdc EQ t_nature-natdc.

  IF sy-subrc EQ 0.
    SORT   t_type BY ativo.
    DELETE t_type WHERE ativo NE 'X'.

    IF sy-subrc EQ 0.
      SORT t_type BY natdc typed loctp.

***       Lendo Denominação da Nature do Documento
      SELECT * FROM zhms_tx_type
               INTO TABLE t_type_t
               FOR ALL ENTRIES IN t_type
               WHERE natdc EQ t_type-natdc      AND
                     typed EQ t_type-typed      AND
                     loctp EQ t_type-loctp      AND
                     spras EQ sy-langu.

      IF sy-subrc EQ 0.
        SORT t_type_t BY natdc typed loctp.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_SEL_TYPE_DOCS
*&---------------------------------------------------------------------*
*&      Form  F_REG_EVENTS_INDEX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_reg_events_index .
***   Obtendo Eventos
  REFRESH t_events.
  CLEAR   wa_event.
  MOVE:   ob_html_index->m_id_sapevent TO wa_event-eventid,
          'X'                          TO wa_event-appl_event.
  APPEND  wa_event TO t_events.

***   Registrando Eventos
  CALL METHOD ob_html_index->set_registered_events
    EXPORTING
      events = t_events.

  IF ob_receiver IS INITIAL.
***     Criando objeto para Eventos HTML
    CREATE OBJECT ob_receiver.
***     Ativando gatilho de eventos
    SET HANDLER ob_receiver->on_sapevent FOR ob_html_index.
  ELSE.
***     Ativando gatilho de eventos
    SET HANDLER ob_receiver->on_sapevent FOR ob_html_index.
  ENDIF.
ENDFORM.                    " F_REG_EVENTS_INDEX
*&---------------------------------------------------------------------*
*&      Form  SELECT_OPT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_opt .
  REFRESH t_grpfld_s.
  CLEAR   t_grpfld_s.

  MOVE vg_action TO vg_actionx.
  TRANSLATE vg_actionx USING '| '.
  READ TABLE t_type INTO wa_type WITH KEY natdc = vg_actionx(2)
                                          typed = vg_actionx+3(4).

  IF sy-subrc IS INITIAL.
***   Lendo Tela de Seleção a ser montada
    SELECT *
           FROM zhms_tb_grpfld_s
           INTO TABLE t_grpfld_s
           WHERE codgf EQ '05'.

    IF sy-subrc EQ 0.
      SORT t_grpfld_s BY codgf seqnr tabss fldss.

***     Preparando tela de seleção dinâmica
      PERFORM f_prep_sel_dynn.
***     Chamando tela de seleção dinâmica
      PERFORM f_call_sel_dynn.

      IF NOT t_twhere[] IS INITIAL.
***       Selecionando dados dos Documentos
        PERFORM f_sel_docs_nfs.
      ENDIF.
    ELSE.
***     Tela de Seleção Inexistente. Contatar Suporte.
*    MESSAGE w001.
*    STOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " SELECT_OPT
*&---------------------------------------------------------------------*
*&      Form  F_PREP_SEL_DYNN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_prep_sel_dynn .
  TYPES: BEGIN OF ty_tbl_sc,
           tblnm TYPE tabname,
         END OF ty_tbl_sc.
  DATA: t_tbl_sc  TYPE STANDARD TABLE OF ty_tbl_sc,
        wa_tbl_sc TYPE ty_tbl_sc.

***   Verificando quais tabelas serão aceitas na Seleção
  LOOP AT t_grpfld_s INTO wa_grpfld_s.
    CLEAR  wa_tbl_sc.
    MOVE   wa_grpfld_s-tabss TO wa_tbl_sc-tblnm.
    APPEND wa_tbl_sc TO t_tbl_sc.
  ENDLOOP.

***   Eliminando tabelas duplicadas
  DELETE ADJACENT DUPLICATES FROM t_tbl_sc COMPARING ALL FIELDS.

  IF NOT t_tbl_sc[] IS INITIAL.
    REFRESH: t_tabs,
             t_flds.

***     Carregando Tabelas a serem consideradas
    LOOP AT t_tbl_sc INTO wa_tbl_sc.
      CLEAR wa_tabs.
      MOVE wa_tbl_sc-tblnm TO wa_tabs-prim_tab.
      APPEND wa_tabs TO t_tabs.
    ENDLOOP.

***     Carregando Campos a serem considerados
    LOOP AT t_grpfld_s INTO wa_grpfld_s.
      CLEAR wa_flds.
      MOVE: wa_grpfld_s-tabss TO wa_flds-tablename,
            wa_grpfld_s-fldss TO wa_flds-fieldname,
            wa_grpfld_s-typef TO wa_flds-type.
      APPEND wa_flds TO t_flds.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_PREP_SEL_DYNN
*&---------------------------------------------------------------------*
*&      Form  F_CALL_SEL_DYNN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_call_sel_dynn .
  DATA: vl_text TYPE sy-title.

***   Inicializando Tela de Seleção
  CALL FUNCTION 'FREE_SELECTIONS_INIT'
    EXPORTING
      kind                     = 'T'
      expressions              = t_texpr
    IMPORTING
      selection_id             = vg_selid
      number_of_active_fields  = vg_actnum
    TABLES
      tables_tab               = t_tabs
      fields_tab               = t_flds
    EXCEPTIONS
      fields_incomplete        = 01
      fields_no_join           = 02
      field_not_found          = 03
      no_tables                = 04
      table_not_found          = 05
      expression_not_supported = 06
      incorrect_expression     = 07
      illegal_kind             = 08
      area_not_found           = 09
      inconsistent_area        = 10
      kind_f_no_fields_left    = 11
      kind_f_no_fields         = 12
      too_many_fields          = 13.

  IF sy-subrc EQ 0.
***     Carregando Condições da Tela de Seleção
    CALL FUNCTION 'FREE_SELECTIONS_WHERE_2_EX'
      EXPORTING
        where_clauses        = t_twhere
      IMPORTING
        expressions          = t_texpr
      EXCEPTIONS
        incorrect_expression = 1
        OTHERS               = 2.

    IF sy-subrc EQ 0.
      CLEAR wa_type_t.
      READ TABLE t_type_t INTO wa_type_t
                          WITH KEY natdc = wa_type-natdc
                                   typed = wa_type-typed
                                   loctp = wa_type-loctp.

      IF sy-subrc EQ 0.
        CLEAR vl_text.
        MOVE wa_type_t-denom TO vl_text.
      ENDIF.

***       Tela de Seleção
      CLEAR vg_title.
      MOVE text-001 TO vg_title.

***       Criando tela de seleção
      CALL FUNCTION 'FREE_SELECTIONS_DIALOG'
        EXPORTING
          selection_id            = vg_selid
          title                   = vg_title
          tree_visible            = ''
          as_window               = 'X'
          start_row               = '1'
          start_col               = '35'
          frame_text              = vl_text
          status                  = 1
        IMPORTING
          where_clauses           = t_twhere
          expressions             = t_texpr
          number_of_active_fields = vg_actnum
        TABLES
          fields_tab              = t_flds
        EXCEPTIONS
          internal_error          = 01
          no_action               = 02
          no_fields_selected      = 03
          no_tables_selected      = 04
          selid_not_found         = 05.

      IF sy-subrc NE 0  AND  sy-subrc NE 2.
***         Erro ao montar a Tela de Seleção. Contatar Suporte.
*        MESSAGE w002.
      ENDIF.
    ELSE.
***       Erro ao montar a Tela de Seleção. Contatar Suporte.
*      MESSAGE w002.
    ENDIF.
  ELSE.
****     Erro ao montar a Tela de Seleção. Contatar Suporte.
*    MESSAGE w002.
  ENDIF.
ENDFORM.                    " F_CALL_SEL_DYNN
*&---------------------------------------------------------------------*
*&      Form  F_SEL_DOCS_NFS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_sel_docs_nfs .

  TYPES: BEGIN OF ty_select,
           line TYPE char80,
         END OF ty_select.

  DATA: vl_index        TYPE sy-tabix,
        t_where         TYPE TABLE OF ty_select WITH HEADER LINE,
        ls_where        LIKE LINE OF t_where,
        ls_where_tab    TYPE rsdswhere,
        t_where_status  TYPE TABLE OF ty_select WITH HEADER LINE,
        ls_where_status LIKE LINE OF t_where.

  REFRESH: t_cabdoc, t_docst, t_docrf, t_cabdoc_ref,
           t_docrf_es, t_param, t_lfa1, t_kna1, t_status01.
  CLEAR:   wa_cabdoc, wa_docst, wa_docrf, wa_docrf_es,
           wa_param, wa_lfa1, wa_kna1.

** inicio alteração David Rosin 14/02/2014
  LOOP AT t_twhere INTO wa_twhere where TABLENAME = 'ZHMS_TB_DOCST'.
    LOOP AT wa_twhere-where_tab INTO ls_where_tab.
      MOVE ls_where_tab TO ls_where_status.
      APPEND ls_where_status TO t_where_status.
      CLEAR ls_where_status.
    ENDLOOP.

  ENDLOOP.
*** inicio alteração David Rosin 14/02/2014
  LOOP AT t_twhere INTO wa_twhere where TABLENAME = 'ZHMS_TB_CABDOC'.
    LOOP AT wa_twhere-where_tab INTO ls_where_tab.
      MOVE ls_where_tab TO ls_where.
      APPEND ls_where TO t_where.
      CLEAR ls_where.
    ENDLOOP.

  ENDLOOP.
  if not t_where_status[] is initial.
    SELECT *
     INTO TABLE t_docst
     FROM zhms_tb_docst
     WHERE (t_where_status).

    if not t_docst[] is initial.

      SELECT *
       INTO TABLE t_cabdoc
       FROM zhms_tb_cabdoc
       for all entries in t_docst
       WHERE (t_where)
         and chave = t_docst-chave.
    endif.
  else.
    if not t_where[] is initial.

      SELECT *
        INTO TABLE t_cabdoc
        FROM zhms_tb_cabdoc
        WHERE (t_where).
    endif.
  endif.

  IF t_cabdoc[] IS NOT INITIAL.
    SELECT *
      INTO TABLE t_lfa1
      FROM lfa1
       FOR ALL ENTRIES IN t_cabdoc
     WHERE lifnr EQ t_cabdoc-parid.

    SELECT *
      INTO TABLE t_kna1
      FROM kna1
       FOR ALL ENTRIES IN t_cabdoc
     WHERE kunnr EQ t_cabdoc-parid.

***     Status de Documento
    SELECT *
      INTO TABLE t_docst
      FROM zhms_tb_docst
       FOR ALL ENTRIES IN t_cabdoc
     WHERE natdc EQ t_cabdoc-natdc
       AND typed EQ t_cabdoc-typed
       AND chave EQ t_cabdoc-chave.

***     Documentos Referenciados
    SELECT *
      INTO TABLE t_docrf
      FROM zhms_tb_docrf
       FOR ALL ENTRIES IN t_cabdoc
     WHERE natdc EQ t_cabdoc-natdc
       AND typed EQ t_cabdoc-typed
       AND chave EQ t_cabdoc-chave.

    IF t_docrf[] IS NOT INITIAL.

***     Status de Documento refenciado
      SELECT *
        INTO TABLE t_docst_new
        FROM zhms_tb_docst
         FOR ALL ENTRIES IN t_docrf
       WHERE natdc EQ t_docrf-ntdrf
         AND typed EQ t_docrf-tpdrf
         AND chave EQ t_docrf-chvrf.

      LOOP AT t_docst_new INTO wa_docst.
        APPEND wa_docst TO t_docst.
      ENDLOOP.

***       Dados de documento refenciado
      SELECT *
        INTO TABLE t_cabdoc_ref
        FROM zhms_tb_cabdoc
         FOR ALL ENTRIES IN t_docrf
        WHERE natdc EQ t_docrf-ntdrf
          AND typed EQ t_docrf-tpdrf
          AND chave EQ t_docrf-chvrf.

      LOOP AT t_docrf INTO wa_docrf.
        CLEAR wa_docrf_es.
        MOVE-CORRESPONDING wa_docrf TO wa_docrf_es.
        READ TABLE t_cabdoc_ref INTO wa_cabdoc WITH KEY chave = wa_docrf-chvrf.
        wa_docrf_es-dcnro = wa_cabdoc-docnr.
        APPEND wa_docrf_es TO t_docrf_es.
      ENDLOOP.
    ENDIF.
  ELSE.
*        TODO: Organizar Mensagem
    MESSAGE i002(sy) WITH 'Nenhum documento encontrado!'.

  ENDIF.

ENDFORM.                    " F_SEL_DOCS_NFS
*&---------------------------------------------------------------------*
*&      Form  F_GET_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_doc .
  DATA: v_tabix    TYPE sy-tabix,
        v_cfop     TYPE zhms_tb_docmn-value,
        v_cfop_aux TYPE zhms_tb_cfop-cfop,
        v_data     TYPE ZHMS_TB_LOGDOC-DTREG,
        v_hora     TYPE ZHMS_TB_LOGDOC-HRREG.

  SELECT SINGLE id
    INTO vg_icon_green
    FROM icon
    WHERE name = 'ICON_GREEN_LIGHT'.

  SELECT SINGLE id
   INTO vg_icon_yellow
   FROM icon
   WHERE name = 'ICON_YELLOW_LIGHT'.

  SELECT SINGLE id
    INTO vg_icon_red
    FROM icon
    WHERE name = 'ICON_RED_LIGHT'.

  CHECK NOT t_cabdoc[] IS INITIAL.

  SELECT *
    FROM zhms_tx_type
    INTO TABLE lt_typedomn.

  SELECT *
    FROM zhms_tb_flwdoc
    INTO TABLE lt_flwdoc
    FOR ALL ENTRIES IN t_cabdoc
   WHERE natdc EQ t_cabdoc-natdc
     AND typed EQ t_cabdoc-typed
     AND chave EQ t_cabdoc-chave.


  SELECT *
    FROM zhms_tb_docst
    INTO TABLE lt_docst
    FOR ALL ENTRIES IN t_cabdoc
   WHERE natdc EQ t_cabdoc-natdc
     AND typed EQ t_cabdoc-typed
     AND chave EQ t_cabdoc-chave.

  SELECT *
      FROM zhms_tb_scen_flo
      INTO TABLE lt_sen_flo
      FOR ALL ENTRIES IN t_cabdoc
     WHERE natdc EQ t_cabdoc-natdc
       AND typed EQ t_cabdoc-typed
       and ( FUNCT = 'F_ZHMS_ML81N_BAPI'
        or   Funct = 'BAPI_GOODSMVT_CREATE'
        or   funct = 'BAPI_INCOMINGINVOICE_CREATE' ).

  SELECT *
      FROM zhms_tb_docmn
      INTO TABLE lt_docmn1
      FOR ALL ENTRIES IN t_cabdoc
      WHERE chave EQ t_cabdoc-chave
         AND ( mneum EQ 'MATDOC'       " Migo
          OR   mneum EQ 'INVDOCNO' ).  " Miro

  SELECT *
      INTO TABLE lT_LOGDOC
      FROM ZHMS_TB_LOGDOC
      FOR ALL ENTRIES IN t_cabdoc
      WHERE natdc EQ t_cabdoc-natdc
        AND typed EQ t_cabdoc-typed
        AND CHAVE EQ t_cabdoc-CHAVE
        AND logty EQ 'E'.

  sort lT_LOGDOC ASCENDING BY DTREG HRREG.
  SORT lt_flwdoc DESCENDING BY flowd.

  CLEAR vg_flowd.
  LOOP AT t_cabdoc INTO wa_cabdoc.
    CLEAR vg_flowd.

    MOVE: wa_cabdoc-typed TO wa_status01-tipo.
    READ TABLE lt_typedomn INTO wa_typedomn WITH KEY typed = wa_cabdoc-typed.
    IF sy-subrc = 0.
      MOVE: wa_typedomn-denom TO wa_status01-denom.
      CLEAR: wa_typedomn.
    ENDIF.
*** Verifica se ainda falta etapas para a nota
    READ TABLE lt_flwdoc INTO wa_flwdoc  WITH KEY chave = wa_cabdoc-chave.

    IF sy-subrc IS INITIAL.

*** Busca maior etapa
      IF vg_flowd IS INITIAL.
        SELECT SINGLE MAX( flowd )
          INTO vg_flowd
          FROM zhms_tb_scen_flo
         WHERE natdc EQ wa_cabdoc-natdc
           AND typed EQ wa_cabdoc-typed
           AND scena EQ wa_cabdoc-scena.
      ENDIF.

      IF sy-subrc IS INITIAL.
        IF wa_flwdoc-flowd < vg_flowd.
          MOVE vg_icon_yellow TO wa_status01-icone.
        ELSEIF wa_flwdoc-flowd EQ vg_flowd.
          MOVE vg_icon_green TO wa_status01-icone.
          READ TABLE lt_sen_flo into wa_sen_flo WITH KEY natdc = wa_cabdoc-natdc
                                                         typed = wa_cabdoc-typed
                                                         MNDOC = 'MATDOC'.
          if sy-subrc = 0.
            if wa_sen_flo-FUNCT = 'BAPI_GOODSMVT_CREATE'.
              READ TABLE lt_docmn1 into wa_docmn1 WITH KEY mneum = 'MATDOC'
                                                           chave = wa_cabdoc-chave.
              if sy-subrc = 0.
                move: wa_docmn1-VALUE to wa_status01-MIGO.
              endif.
            else.
              READ TABLE lt_docmn1 into wa_docmn1 WITH KEY mneum = 'MATDOC'
                                                           chave = wa_cabdoc-chave.
              if sy-subrc = 0.
                move: wa_docmn1-VALUE to wa_status01-ML81N.
              endif.
            endif.
          endif.
          READ TABLE lt_docmn1 into wa_docmn1 WITH KEY mneum = 'INVDOCNO'
                                                       chave = wa_cabdoc-chave.
          if sy-subrc = 0.
            move: wa_docmn1-VALUE to wa_status01-MIRO.
          endif.
        endif.
      ELSE.
        MOVE vg_icon_yellow TO wa_status01-icone.
      ENDIF.


*** Move Etapa final
      SELECT flowd
              INTO TABLE t_flowd
              FROM zhms_tb_scen_flo
             WHERE natdc EQ wa_cabdoc-natdc
               AND typed EQ wa_cabdoc-typed
               AND scena EQ wa_cabdoc-scena.
      SORT t_flowd.
      CLEAR: v_tabix.
      READ TABLE t_flowd WITH KEY flowd = wa_flwdoc-flowd INTO wa_flowd.
      v_tabix = sy-tabix + 1.
      READ TABLE t_flowd INDEX v_tabix INTO wa_flowd.
      MOVE: wa_flowd-flowd       TO wa_status01-flowd_fn.

*      MOVE: vg_flowd        TO wa_status01-flowd_fn,
      MOVE: wa_flwdoc-flowd TO wa_status01-flowd_at.

    ELSE.
      MOVE vg_icon_yellow TO wa_status01-icone.
*      MOVE '10' TO wa_status01-flowd_at.
      MOVE '10' TO wa_status01-flowd_fn.
    ENDIF.

***Busca CFOP
    CLEAR: v_cfop,
           wa_status01-manual.
    SELECT SINGLE value
      FROM zhms_tb_docmn
      INTO v_cfop
      WHERE chave = wa_cabdoc-chave
        AND mneum = 'CFOP'.

    IF NOT v_cfop IS INITIAL.
      REPLACE ALL OCCURRENCES OF '/' IN v_cfop WITH ''.
      CLEAR:  v_cfop_aux.
      SELECT SINGLE cfop
        FROM zhms_tb_cfop
        INTO v_cfop_aux
        WHERE cfop = v_cfop.
      IF NOT v_cfop_aux IS INITIAL.
        wa_status01-manual = 'X'.
      ENDIF.
    ENDIF.

    CLEAR: wa_status01-fora.
    READ TABLE lt_docst INTO wa_docst  WITH KEY chave = wa_cabdoc-chave.
    IF sy-subrc = 0.
      IF wa_docst-sthms = '3'.
        wa_status01-fora = 'X'.
        MOVE vg_icon_yellow TO wa_status01-icone.
      ELSE.
        if  wa_docst-sthms = '1'.
          MOVE vg_icon_green TO wa_status01-icone.

          READ TABLE lt_sen_flo into wa_sen_flo WITH KEY natdc = wa_cabdoc-natdc
                                                         typed = wa_cabdoc-typed
                                                         MNDOC = 'MATDOC'.
          if sy-subrc = 0.
            if wa_sen_flo-FUNCT = 'BAPI_GOODSMVT_CREATE'.
              READ TABLE lt_docmn1 into wa_docmn1 WITH KEY mneum = 'MATDOC'
                                                           chave = wa_cabdoc-chave.
              if sy-subrc = 0.
                move: wa_docmn1-VALUE to wa_status01-MIGO.
              endif.
            else.
              READ TABLE lt_docmn1 into wa_docmn1 WITH KEY mneum = 'MATDOC'
                                                           chave = wa_cabdoc-chave.
              if sy-subrc = 0.
                move: wa_docmn1-VALUE to wa_status01-ML81N.
              endif.
            endif.
          endif.
          READ TABLE lt_docmn1 into wa_docmn1 WITH KEY mneum = 'INVDOCNO'
                                                       chave = wa_cabdoc-chave.
          if sy-subrc = 0.
            move: wa_docmn1-VALUE to wa_status01-MIRO.
          endif.

        endif.
        CLEAR: wa_status01-fora.
      ENDIF.
      IF wa_docst-sthms = 4.
        MOVE vg_icon_red TO wa_status01-icone.
      ENDIF.
    ENDIF.
    READ TABLE t_lfa1 INTO wa_lfa1  WITH KEY lifnr = wa_cabdoc-parid.



    MOVE: wa_cabdoc-docnr TO wa_status01-docnr,
          wa_cabdoc-parid TO wa_status01-parid,
          wa_flwdoc-dtreg TO wa_status01-data,
          wa_lfa1-name1   TO wa_status01-name1.

    IF wa_flwdoc-dtreg IS INITIAL.
      MOVE wa_cabdoc-lncdt TO wa_status01-data.
    ENDIF.
    if wa_status01-ICONE = vg_icon_red.
      clear: v_data, v_hora.
      LOOP at lT_LOGDOC into wa_logdoc where natdc = wa_cabdoc-natdc
                                         and typed = wa_cabdoc-typed
                                         and CHAVE = wa_cabdoc-CHAVE.
        if v_data is INITIAL and v_hora is INITIAL.
          v_data = wa_logdoc-DTREG.
          v_hora = wa_logdoc-HRREG.

          MESSAGE ID wa_logdoc-logid TYPE wa_logdoc-logty NUMBER wa_logdoc-logno
                  INTO wa_status01-TEXTO_ERRO
                  WITH wa_logdoc-logv1 wa_logdoc-logv2 wa_logdoc-logv3 wa_logdoc-logv4.
          APPEND wa_status01 TO t_status01.
        else.
          if v_data = wa_logdoc-DTREG and v_hora = wa_logdoc-HRREG.
            MESSAGE ID wa_logdoc-logid TYPE wa_logdoc-logty NUMBER wa_logdoc-logno
                    INTO wa_status01-TEXTO_ERRO
                    WITH wa_logdoc-logv1 wa_logdoc-logv2 wa_logdoc-logv3 wa_logdoc-logv4.
            APPEND wa_status01 TO t_status01.
          else.
            exit.
          endif.
        endif.
      endloop.
    else.
      APPEND wa_status01 TO t_status01.
    endif.
    CLEAR: wa_status01, wa_flwdoc.
  ENDLOOP.
  sort t_status01.
  DELETE ADJACENT DUPLICATES FROM t_status01 COMPARING ALL FIELDS.
ENDFORM.                    " F_GET_DOC
*&---------------------------------------------------------------------*
*&      Form  F_GET_VLD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_vld .

  CHECK NOT t_cabdoc[] IS INITIAL.

  SELECT *
    FROM zhms_tb_hrvalid
    INTO TABLE lt_hrvalid
    FOR ALL ENTRIES IN t_cabdoc
    WHERE natdc EQ t_cabdoc-natdc
      AND typed EQ t_cabdoc-typed
      AND chave EQ t_cabdoc-chave.

  SORT: lt_hrvalid,
        t_cabdoc ASCENDING BY chave.

  REFRESH lt_vld_out[].
  LOOP AT t_cabdoc INTO wa_cabdoc.

    CLEAR ls_hrvalid.
    READ TABLE lt_hrvalid INTO ls_hrvalid WITH KEY chave = wa_cabdoc-chave BINARY SEARCH.

    IF sy-subrc IS INITIAL.
      MOVE: ls_hrvalid-natdc TO ls_vld_out-natdc,
            ls_hrvalid-typed TO ls_vld_out-typed,
            ls_hrvalid-atitm TO ls_vld_out-atitm,
            ls_hrvalid-dtreg TO ls_vld_out-dtreg,
            ls_hrvalid-hrreg TO ls_vld_out-hrreg,
            ls_hrvalid-vldv2 TO ls_vld_out-vldv2,
            wa_cabdoc-docnr  TO ls_vld_out-docnr.
      APPEND ls_vld_out TO lt_vld_out.
      CLEAR ls_vld_out.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " F_GET_VLD
*&---------------------------------------------------------------------*
*&      Form  F_GET_HIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_hist .

  DATA: lt_docmn  TYPE STANDARD TABLE OF zhms_tb_docmn,
        lt_docmnx TYPE STANDARD TABLE OF zhms_tb_docmn,
        ls_docmnx LIKE LINE OF lt_docmn,
        ls_docmn  LIKE LINE OF lt_docmn.

  REFRESH t_hist_out[].

  SELECT *
    FROM zhms_tb_docmn
    INTO TABLE lt_docmn
    FOR ALL ENTRIES IN t_cabdoc
    WHERE chave EQ t_cabdoc-chave
       AND ( mneum EQ 'NNF'        " Numero Nota
        OR   mneum EQ 'ATITMPED'   " Item atribuido
        OR   mneum EQ 'ATPED'      " Pedido
        OR   mneum EQ 'MATDOC'     " Migo
        OR   mneum EQ 'INVDOCNO'   " Miro
        OR   mneum EQ 'MATDOCEST'  " Estorno Migo
        OR   mneum EQ 'REASON').   " Estorno Miro

  IF sy-subrc IS INITIAL.
    MOVE lt_docmn[] TO lt_docmnx[].
    DELETE ADJACENT DUPLICATES FROM lt_docmnx COMPARING chave atitm.
    LOOP AT lt_docmnx INTO ls_docmnx.
      LOOP AT lt_docmn INTO ls_docmn WHERE chave EQ ls_docmnx-chave
                                       AND atitm EQ ls_docmnx-atitm.

        CASE ls_docmn-mneum.
          WHEN 'ATPED'.
            MOVE ls_docmn-value TO wa_hist_out-ebeln.
          WHEN 'ATITMPED'.
            MOVE ls_docmn-value TO wa_hist_out-atitm.
          WHEN 'NNF'.
            MOVE ls_docmn-value TO wa_hist_out-docnr.
        ENDCASE.

        READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'MATDOC'
                                                   chave = ls_docmnx-chave
                                                   atitm = ls_docmnx-atitm.

        IF sy-subrc IS INITIAL.
          CONCATENATE wa_hist_out-docum ',' ls_docmn-value INTO wa_hist_out-docum SEPARATED BY space.
        ENDIF.

        READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'INVDOCNO'
                                                   chave = ls_docmnx-chave
                                                   atitm = ls_docmnx-atitm.

        IF sy-subrc IS INITIAL.
          CONCATENATE wa_hist_out-docum ',' ls_docmn-value INTO wa_hist_out-docum SEPARATED BY space.
        ENDIF.

        READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'MATDOCEST'
                                                   chave = ls_docmnx-chave
                                                   atitm = ls_docmnx-atitm.

        IF sy-subrc IS INITIAL.
          CONCATENATE wa_hist_out-docum ',' ls_docmn-value INTO wa_hist_out-docum SEPARATED BY space.
        ENDIF.

        READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'REASON'
                                                   chave = ls_docmnx-chave
                                                   atitm = ls_docmnx-atitm.

        IF sy-subrc IS INITIAL.
          CONCATENATE wa_hist_out-docum ',' ls_docmn-value INTO wa_hist_out-docum SEPARATED BY space.
        ENDIF.

        MOVE ls_docmn-dcitm TO wa_hist_out-dcitm.

      ENDLOOP.

      APPEND wa_hist_out TO t_hist_out.
      CLEAR wa_hist_out.

    ENDLOOP.
  ENDIF.

ENDFORM.                    " F_GET_HIST
*&---------------------------------------------------------------------*
*&      Form  CREATE_XML_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_IXML_DATA_DOC  text
*----------------------------------------------------------------------*
FORM create_xml_data  USING    p_ixml_doc TYPE REF TO if_ixml_document..
  DATA: l_simplechartdata TYPE REF TO if_ixml_element,
        l_categories      TYPE REF TO if_ixml_element,
        l_series          TYPE REF TO if_ixml_element,
        l_element         TYPE REF TO if_ixml_element,
        l_encoding        TYPE REF TO if_ixml_encoding,
        l_value           TYPE string.
  p_ixml_doc = g_ixml->create_document( ).
* Set encoding to UTF-8
  l_encoding = g_ixml->create_encoding(
                byte_order = if_ixml_encoding=>co_little_endian
                character_set = 'utf-8' ).
  p_ixml_doc->set_encoding( l_encoding ).
* Populate Chart Data
  l_simplechartdata = p_ixml_doc->create_simple_element(
               name = 'SimpleChartData' parent = p_ixml_doc ).
* Populate X-Axis Values i.e. Categories and Series
  l_categories = p_ixml_doc->create_simple_element(
            name = 'Categories' parent = l_simplechartdata ).
* Here you can populate the category labels. First you need
* to create all the labels and only then you can populate
* values for these labels.
  MOVE t_cabdoc[] TO lt_cabdocx[].
  SORT lt_cabdocx ASCENDING BY parid.
  DELETE ADJACENT DUPLICATES FROM lt_cabdocx COMPARING parid.
  DELETE lt_cabdocx WHERE parid IS INITIAL.
  LOOP AT lt_cabdocx INTO ls_cabdoc.
    l_element = p_ixml_doc->create_simple_element(
                name = 'C' parent = l_categories ).
*    CONCATENATE wa_sflight-carrid wa_sflight-connid INTO l_value.
    MOVE ls_cabdoc-parid TO l_value.
* Populate the category value which you want to display here.
* This will appear in the X-axis.
    l_element->if_ixml_node~set_value( l_value ).
    CLEAR l_value.
  ENDLOOP.
* Create an element for Series and then populate it's values.
  l_series = p_ixml_doc->create_simple_element(
            name = 'Series' parent = l_simplechartdata ).
* You can set your own label for X-Axis here e.g. Airline
*  l_series->set_attribute( name = 'label' value = 'Price' ).
  LOOP AT lt_cabdocx INTO ls_cabdocx.
    l_element = p_ixml_doc->create_simple_element(
                name = 'S' parent = l_series ).
* Populate the Value for each category you want to display from
* your internal table.
    LOOP AT t_cabdoc INTO ls_cabdoc WHERE parid EQ ls_cabdocx-parid.
      l_value =  l_value + 1.
      l_element->if_ixml_node~set_value( l_value ).
    ENDLOOP.
    CLEAR l_value.

  ENDLOOP.
* Similarly you can have number of Categories and values for each category
* based on your requirement
*  l_series = p_ixml_doc->create_simple_element(
*            name = 'Series' parent = l_simplechartdata ).
*  l_series->set_attribute( name = 'label' value = 'Max Capacity' ).
*  LOOP AT g_t_sflight INTO wa_sflight.
*    l_element = p_ixml_doc->create_simple_element(
*              name = 'S' parent = l_series ).
** Populate value for another category here.
*    l_value = wa_sflight-seatsmax.
*    l_element->if_ixml_node~set_value( l_value ).
*    CLEAR l_value.
*  ENDLOOP.
ENDFORM.                    " CREATE_XML_DATA
*&---------------------------------------------------------------------*
*&      Form  CREATE_CUSTOMIZING_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_IXML_CUSTOM_DOC  text
*----------------------------------------------------------------------*
FORM create_customizing_data  USING    p_ixml_doc TYPE REF TO if_ixml_document.
  DATA: l_root           TYPE REF TO if_ixml_element,
        l_globalsettings TYPE REF TO if_ixml_element,
        l_default        TYPE REF TO if_ixml_element,
        l_elements       TYPE REF TO if_ixml_element,
        l_chartelements  TYPE REF TO if_ixml_element,
        l_title          TYPE REF TO if_ixml_element,
        l_element        TYPE REF TO if_ixml_element,
        l_encoding       TYPE REF TO if_ixml_encoding.
  p_ixml_doc = g_ixml->create_document( ).
  l_encoding = g_ixml->create_encoding(
    byte_order = if_ixml_encoding=>co_little_endian
    character_set = 'utf-8' ).
  p_ixml_doc->set_encoding( l_encoding ).
  l_root = p_ixml_doc->create_simple_element(
            name = 'SAPChartCustomizing' parent = p_ixml_doc ).
  l_root->set_attribute( name = 'version' value = '1.1' ).
  l_globalsettings = p_ixml_doc->create_simple_element(
            name = 'GlobalSettings' parent = l_root ).
  l_element = p_ixml_doc->create_simple_element(
              name = 'FileType' parent = l_globalsettings ).
  l_element->if_ixml_node~set_value( 'PNG' ).
* Here you can give the Chart Type i.e. 2D, 3D etc
  l_element = p_ixml_doc->create_simple_element(
            name = 'Dimension' parent = l_globalsettings ).
* For 2 Dimensional Graph write - PseudoTwo
* For 2 Dimensional Graph write - PseudoThree
  l_element->if_ixml_node~set_value( 'PseudoThree' ).
* Here you can give the chart type
  l_element = p_ixml_doc->create_simple_element(
              name = 'ChartType' parent = l_globalsettings ).
* For Bar Char write - Columns
* For Pie Chart write - Pie etc
*  l_element->if_ixml_node~set_value( 'Speedometer' ).
  l_element->if_ixml_node~set_value( 'Columns' ).
  l_element = p_ixml_doc->create_simple_element(
            name = 'FontFamily' parent = l_default ).
  l_element->if_ixml_node~set_value( 'Arial' ).
  l_elements = p_ixml_doc->create_simple_element(
            name = 'Elements' parent = l_root ).
  l_chartelements = p_ixml_doc->create_simple_element(
            name = 'ChartElements' parent = l_elements ).
  l_title = p_ixml_doc->create_simple_element(
            name = 'Title' parent = l_chartelements ).
* Give the desired caption for the chart here
  l_element = p_ixml_doc->create_simple_element( name = 'Caption' parent = l_title ).
  l_element->if_ixml_node~set_value( 'Quantidade de Notas recebidas por fornecedor' ).
ENDFORM.                    " CREATE_CUSTOMIZING_DATA
*&---------------------------------------------------------------------*
*&      Form  CREATE_XML_DATA_VLD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_IXML_DATA_DOC_VLD  text
*----------------------------------------------------------------------*
FORM create_xml_data_vld  USING    p_ixml_doc TYPE REF TO if_ixml_document.
  DATA: l_simplechartdata TYPE REF TO if_ixml_element,
        l_categories      TYPE REF TO if_ixml_element,
        l_series          TYPE REF TO if_ixml_element,
        l_element         TYPE REF TO if_ixml_element,
        l_encoding        TYPE REF TO if_ixml_encoding,
        l_value           TYPE string.
  p_ixml_doc = g_ixml->create_document( ).
* Set encoding to UTF-8
  l_encoding = g_ixml->create_encoding(
                byte_order = if_ixml_encoding=>co_little_endian
                character_set = 'utf-8' ).
  p_ixml_doc->set_encoding( l_encoding ).
* Populate Chart Data
  l_simplechartdata = p_ixml_doc->create_simple_element(
               name = 'SimpleChartData' parent = p_ixml_doc ).
* Populate X-Axis Values i.e. Categories and Series
  l_categories = p_ixml_doc->create_simple_element(
            name = 'Categories' parent = l_simplechartdata ).
* Here you can populate the category labels. First you need
* to create all the labels and only then you can populate
* values for these labels.
  MOVE t_cabdoc[] TO lt_cabdocx[].
  SORT lt_cabdocx ASCENDING BY parid.
  DELETE ADJACENT DUPLICATES FROM lt_cabdocx COMPARING parid.
  DELETE lt_cabdocx WHERE parid IS INITIAL.
  LOOP AT lt_cabdocx INTO ls_cabdoc.
    l_element = p_ixml_doc->create_simple_element(
                name = 'C' parent = l_categories ).
*    CONCATENATE wa_sflight-carrid wa_sflight-connid INTO l_value.
    MOVE ls_cabdoc-parid TO l_value.
* Populate the category value which you want to display here.
* This will appear in the X-axis.
    l_element->if_ixml_node~set_value( l_value ).
    CLEAR l_value.
  ENDLOOP.
* Create an element for Series and then populate it's values.
  l_series = p_ixml_doc->create_simple_element(
            name = 'Series' parent = l_simplechartdata ).
* You can set your own label for X-Axis here e.g. Airline
*  l_series->set_attribute( name = 'label' value = 'Price' ).
  LOOP AT lt_cabdocx INTO ls_cabdocx.
    l_element = p_ixml_doc->create_simple_element(
                name = 'S' parent = l_series ).
* Populate the Value for each category you want to display from
* your internal table.
    LOOP AT t_cabdoc INTO ls_cabdoc WHERE parid EQ ls_cabdocx-parid.
      LOOP AT lt_hrvalid INTO ls_hrvalid WHERE chave EQ ls_cabdoc-chave.
        l_value =  l_value + 1.
        l_element->if_ixml_node~set_value( l_value ).
      ENDLOOP.
    ENDLOOP.
    CLEAR l_value.

  ENDLOOP.
ENDFORM.                    " CREATE_XML_DATA_VLD
*&---------------------------------------------------------------------*
*&      Form  CREATE_CUSTOMIZING_DATA_VLD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_IXML_CUSTOM_DOC_VLD  text
*----------------------------------------------------------------------*
FORM create_customizing_data_vld  USING    p_ixml_doc TYPE REF TO if_ixml_document.
  DATA: l_root           TYPE REF TO if_ixml_element,
        l_globalsettings TYPE REF TO if_ixml_element,
        l_default        TYPE REF TO if_ixml_element,
        l_elements       TYPE REF TO if_ixml_element,
        l_chartelements  TYPE REF TO if_ixml_element,
        l_title          TYPE REF TO if_ixml_element,
        l_element        TYPE REF TO if_ixml_element,
        l_encoding       TYPE REF TO if_ixml_encoding.
  p_ixml_doc = g_ixml->create_document( ).
  l_encoding = g_ixml->create_encoding(
    byte_order = if_ixml_encoding=>co_little_endian
    character_set = 'utf-8' ).
  p_ixml_doc->set_encoding( l_encoding ).
  l_root = p_ixml_doc->create_simple_element(
            name = 'SAPChartCustomizing' parent = p_ixml_doc ).
  l_root->set_attribute( name = 'version' value = '1.1' ).
  l_globalsettings = p_ixml_doc->create_simple_element(
            name = 'GlobalSettings' parent = l_root ).
  l_element = p_ixml_doc->create_simple_element(
              name = 'FileType' parent = l_globalsettings ).
  l_element->if_ixml_node~set_value( 'PNG' ).
* Here you can give the Chart Type i.e. 2D, 3D etc
  l_element = p_ixml_doc->create_simple_element(
            name = 'Dimension' parent = l_globalsettings ).
* For 2 Dimensional Graph write - PseudoTwo
* For 2 Dimensional Graph write - PseudoThree
  l_element->if_ixml_node~set_value( 'PseudoThree' ).
* Here you can give the chart type
  l_element = p_ixml_doc->create_simple_element(
              name = 'ChartType' parent = l_globalsettings ).
* For Bar Char write - Columns
* For Pie Chart write - Pie etc
*  l_element->if_ixml_node~set_value( 'Speedometer' ).
  l_element->if_ixml_node~set_value( 'Columns' ).
  l_element = p_ixml_doc->create_simple_element(
            name = 'FontFamily' parent = l_default ).
  l_element->if_ixml_node~set_value( 'Arial' ).
  l_elements = p_ixml_doc->create_simple_element(
            name = 'Elements' parent = l_root ).
  l_chartelements = p_ixml_doc->create_simple_element(
            name = 'ChartElements' parent = l_elements ).
  l_title = p_ixml_doc->create_simple_element(
            name = 'Title' parent = l_chartelements ).
* Give the desired caption for the chart here
  l_element = p_ixml_doc->create_simple_element( name = 'Caption' parent = l_title ).
  l_element->if_ixml_node~set_value( 'Demonstrativo de erro por fornecedor' ).

ENDFORM.                    " CREATE_CUSTOMIZING_DATA_VLD
*&---------------------------------------------------------------------*
*&      Form  CREATE_XML_DATA_ERRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_IXML_DATA_DOC_ERRO  text
*----------------------------------------------------------------------*
FORM create_xml_data_erro  USING  p_ixml_doc TYPE REF TO if_ixml_document.
  DATA: l_simplechartdata TYPE REF TO if_ixml_element,
        l_categories      TYPE REF TO if_ixml_element,
        l_series          TYPE REF TO if_ixml_element,
        l_element         TYPE REF TO if_ixml_element,
        l_encoding        TYPE REF TO if_ixml_encoding,
        l_value           TYPE string,
        lt_message        TYPE STANDARD TABLE OF zhms_tb_messages,
        ls_message        LIKE LINE OF lt_message.
  p_ixml_doc = g_ixml->create_document( ).
* Set encoding to UTF-8
  l_encoding = g_ixml->create_encoding(
                byte_order = if_ixml_encoding=>co_little_endian
                character_set = 'utf-8' ).
  p_ixml_doc->set_encoding( l_encoding ).
* Populate Chart Data
  l_simplechartdata = p_ixml_doc->create_simple_element(
               name = 'SimpleChartData' parent = p_ixml_doc ).
* Populate X-Axis Values i.e. Categories and Series
  l_categories = p_ixml_doc->create_simple_element(
            name = 'Categories' parent = l_simplechartdata ).
* Here you can populate the category labels. First you need
* to create all the labels and only then you can populate
* values for these labels.
  SELECT * FROM zhms_tb_messages INTO TABLE lt_message.
*  MOVE t_cabdoc[] TO lt_cabdocx[].
*  SORT lt_cabdocx ASCENDING BY parid.
*  DELETE ADJACENT DUPLICATES FROM lt_cabdocx COMPARING parid.
*  DELETE lt_cabdocx WHERE parid IS INITIAL.
  LOOP AT lt_message INTO ls_message.
    l_element = p_ixml_doc->create_simple_element(
                name = 'C' parent = l_categories ).

    CASE ls_message-code.
      WHEN '0001'.
        MOVE 'Forn.' TO l_value.
      WHEN '0002'.
        MOVE 'Forn.' TO l_value.
      WHEN '0003'.
        MOVE 'Forn.' TO l_value.
      WHEN '0004'.
        MOVE  'PO'   TO l_value.
      WHEN '0005'.
        MOVE  'PO'   TO l_value.
      WHEN '0006'.
        MOVE  'PO'   TO l_value.
      WHEN '0007'.
        MOVE  'Item' TO l_value.
      WHEN '0008'.
        MOVE  'item' TO l_value.
      WHEN '0009'.
        MOVE  'NCM'  TO l_value.
      WHEN '0010'.
        MOVE  'Qtd.' TO l_value.
      WHEN '0011'.
        MOVE  'ICMS' TO l_value.
      WHEN '0012'.
        MOVE  'IPI'  TO l_value.
      WHEN '0013'.
        MOVE  'PIS'  TO l_value.
      WHEN '0014'.
        MOVE  'COFI' TO l_value.
      WHEN '0015'.
        MOVE  'ISS'  TO l_value.
      WHEN '0016'.
        MOVE  'ICMS' TO l_value.
      WHEN OTHERS.
    ENDCASE.
* Populate the category value which you want to display here.
* This will appear in the X-axis.
    l_element->if_ixml_node~set_value( l_value ).
    CLEAR l_value.
  ENDLOOP.
* Create an element for Series and then populate it's values.
  l_series = p_ixml_doc->create_simple_element(
            name = 'Series' parent = l_simplechartdata ).
* You can set your own label for X-Axis here e.g. Airline
*  l_series->set_attribute( name = 'label' value = 'Price' ).
*  LOOP AT lt_cabdocx INTO ls_cabdocx.
*    l_element = p_ixml_doc->create_simple_element(
*                name = 'S' parent = l_series ).
** Populate the Value for each category you want to display from
* your internal table.
  LOOP AT lt_message INTO ls_message.
    l_element = p_ixml_doc->create_simple_element(
                name = 'S' parent = l_series ).
    LOOP AT lt_hrvalid INTO ls_hrvalid WHERE vldv1 EQ ls_message-code.

      CASE ls_hrvalid-vldv1.
        WHEN '0001'.
          l_value =  l_value + 1.
        WHEN '0002'.
          l_value =  l_value + 1.
        WHEN '0003'.
          l_value =  l_value + 1.
        WHEN '0004'.
          l_value =  l_value + 1.
        WHEN '0005'.
          l_value =  l_value + 1.
        WHEN '0006'.
          l_value =  l_value + 1.
        WHEN '0007'.
          l_value =  l_value + 1.
        WHEN '0008'.
          l_value =  l_value + 1.
        WHEN '0009'.
          l_value =  l_value + 1.
        WHEN '0010'.
          l_value =  l_value + 1.
        WHEN '0011'.
          l_value =  l_value + 1.
        WHEN '0012'.
          l_value =  l_value + 1.
        WHEN '0013'.
          l_value =  l_value + 1.
        WHEN '0014'.
          l_value =  l_value + 1.
        WHEN '0015'.
          l_value =  l_value + 1.
        WHEN '0016'.
          l_value =  l_value + 1.
        WHEN OTHERS.
      ENDCASE.

    ENDLOOP.

    l_element->if_ixml_node~set_value( l_value ).
    CLEAR l_value.
  ENDLOOP.

ENDFORM.                    " CREATE_XML_DATA_ERRO
*&---------------------------------------------------------------------*
*&      Form  CREATE_CUSTOMIZING_DATA_ERRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_IXML_CUSTOM_DOC_ERRO  text
*----------------------------------------------------------------------*
FORM create_customizing_data_erro  USING p_ixml_doc TYPE REF TO if_ixml_document.
  DATA: l_root           TYPE REF TO if_ixml_element,
        l_globalsettings TYPE REF TO if_ixml_element,
        l_default        TYPE REF TO if_ixml_element,
        l_elements       TYPE REF TO if_ixml_element,
        l_chartelements  TYPE REF TO if_ixml_element,
        l_title          TYPE REF TO if_ixml_element,
        l_element        TYPE REF TO if_ixml_element,
        l_encoding       TYPE REF TO if_ixml_encoding.

  p_ixml_doc = g_ixml->create_document( ).
  l_encoding = g_ixml->create_encoding(
    byte_order = if_ixml_encoding=>co_little_endian
    character_set = 'utf-8' ).
  p_ixml_doc->set_encoding( l_encoding ).
  l_root = p_ixml_doc->create_simple_element(
            name = 'SAPChartCustomizing' parent = p_ixml_doc ).
  l_root->set_attribute( name = 'version' value = '1.1' ).
  l_globalsettings = p_ixml_doc->create_simple_element(
            name = 'GlobalSettings' parent = l_root ).
  l_element = p_ixml_doc->create_simple_element(
              name = 'FileType' parent = l_globalsettings ).
  l_element->if_ixml_node~set_value( 'PNG' ).
* Here you can give the Chart Type i.e. 2D, 3D etc
  l_element = p_ixml_doc->create_simple_element(
            name = 'Dimension' parent = l_globalsettings ).
* For 2 Dimensional Graph write - PseudoTwo
* For 2 Dimensional Graph write - PseudoThree
  l_element->if_ixml_node~set_value( 'PseudoTwo' ).
* Here you can give the chart type
  l_element = p_ixml_doc->create_simple_element(
              name = 'ChartType' parent = l_globalsettings ).
* For Bar Char write - Columns
* For Pie Chart write - Pie etc
*  l_element->if_ixml_node~set_value( 'Speedometer' ).
  l_element->if_ixml_node~set_value( 'Columns' ).
  l_element = p_ixml_doc->create_simple_element(
            name = 'FontFamily' parent = l_default ).
  l_element->if_ixml_node~set_value( 'Arial' ).
  l_elements = p_ixml_doc->create_simple_element(
            name = 'Elements' parent = l_root ).
  l_chartelements = p_ixml_doc->create_simple_element(
            name = 'ChartElements' parent = l_elements ).
  l_title = p_ixml_doc->create_simple_element(
            name = 'Title' parent = l_chartelements ).
* Give the desired caption for the chart here
  l_element = p_ixml_doc->create_simple_element( name = 'Caption' parent = l_title ).
  l_element->if_ixml_node~set_value( 'Demonstrativo por tipo de erro' ).
ENDFORM.                    " CREATE_CUSTOMIZING_DATA_ERRO
*&---------------------------------------------------------------------*
*&      Form  ZF_GERAR_NOVO_GRAFICO
*&---------------------------------------------------------------------*
*       Novos Gráficos
*----------------------------------------------------------------------*
FORM zf_gerar_novo_grafico .

*  DATA: BEGIN OF data OCCURS 1,
*            p TYPE p,
*          END OF data.
*  DATA: v_c(80) TYPE c.
**--- Optionen-Tabelle -------------------------------------------------*
*  DATA: BEGIN OF opts OCCURS 1,
*           c(80) TYPE c,
*        END OF opts.
*
*  DATA: BEGIN OF tdim1 OCCURS 1,
*           c(80) TYPE c,
*        END OF tdim1.
*
*  DATA: BEGIN OF tdim2 OCCURS 1,
*           c(80) TYPE c,
*        END OF tdim2.
*
*  DATA: BEGIN OF tdim3 OCCURS 1,
*           c(80) TYPE c,
*        END OF tdim3.
*
*  REFRESH opts.
*
**--- Erstes Bild: Auswaehlen ------------------------------------------*
*  WRITE 'FIFRST = PU' TO opts-c. APPEND opts.
**--- 2D-Graphiktyp: Perspektivische Balken ----------------------------*
*  WRITE 'P2TYPE = TD' TO opts-c. APPEND opts.
**--- Art der Faerbung: gleichmaessig ----------------------------------*
*  WRITE 'P3CTYP = PL' TO opts-c. APPEND opts.
*
***--- Dimension 1
***** Teste (será modificado/analisado) - Início
*  MOVE 'A Processar'                   TO tdim1. APPEND tdim1.
*  MOVE 'Pendente por Compras'          TO tdim1. APPEND tdim1.
*  MOVE 'Processados'                   TO tdim1. APPEND tdim1.
*  MOVE 'Estornados'                    TO tdim1. APPEND tdim1.
*  MOVE 'Cancelados'                    TO tdim1. APPEND tdim1.
*  MOVE 'Processamento Manual'          TO tdim1. APPEND tdim1.
*  MOVE 'Notas não aprovadas na SEFAZ'  TO tdim1. APPEND tdim1.
*  MOVE 'Notas Processadas Manualmente' TO tdim1. APPEND tdim1.
***** Teste (será modificado/analisado) - Fim
*
***--- Dimension 2
*  DATA t_mes TYPE TABLE OF string WITH HEADER LINE.
*
*  t_mes = 'JAN'. APPEND t_mes.
*  t_mes = 'FEV'. APPEND t_mes.
*  t_mes = 'MAR'. APPEND t_mes.
*  t_mes = 'ABR'. APPEND t_mes.
*  t_mes = 'MAI'. APPEND t_mes.
*  t_mes = 'JUN'. APPEND t_mes.
*  t_mes = 'JUL'. APPEND t_mes.
*  t_mes = 'AGO'. APPEND t_mes.
*  t_mes = 'SET'. APPEND t_mes.
*  t_mes = 'OUT'. APPEND t_mes.
*  t_mes = 'NOV'. APPEND t_mes.
*  t_mes = 'DEZ'. APPEND t_mes.
*
*  SORT t_cabdoc BY DOCDT ASCENDING.
*  LOOP AT t_cabdoc INTO wa_cabdoc.
*
*    READ TABLE t_mes INDEX wa_cabdoc-DOCDT+4(2).
*
*    CONCATENATE t_mes '-' wa_cabdoc-DOCDT(4) INTO v_c.
*    wa_cabdoc-mes = v_c.
*    MODIFY t_dados FROM wa_cabdoc.
*
*    READ TABLE tdim2 WITH KEY c = v_c.
*    CHECK sy-subrc IS NOT INITIAL.
*
*    MOVE v_c TO tdim2.
*    APPEND tdim2.
*
*  ENDLOOP.
*
*
***--- Dimension 3
*  REFRESH tdim3.
*
*  LOOP AT t_cabdoc INTO wa_cabdoc.
*    CONDENSE wa_cabdoc-bukrs NO-GAPS.
*    READ TABLE tdim3 WITH KEY c = wa_cabdoc-bukrs.
*    CHECK sy-subrc IS NOT INITIAL.
*
*    MOVE wa_cabdoc-bukrs TO tdim3.
*    APPEND tdim3.
*
*  ENDLOOP.
*  DELETE ADJACENT DUPLICATES FROM tdim3.
*
*  ====> parei aqui
*  LOOP AT tdim3.
*
*    LOOP AT tdim2.
*
*      LOOP AT tdim1.
*
**        READ TABLE t_recstatus WITH KEY nome = tdim1.
*        READ TABLE t_cabdoc INTO wa_cabdoc WITH KEY status = tdim1-codigo
*                                                    mes    = tdim2
*                                                    bukrs  = tdim3.
*        IF sy-subrc IS INITIAL.
*          LOOP AT t_dados INTO w_dados WHERE status = t_recstatus-codigo
*                                         AND mes    = tdim2
*                                         AND bukrs  = tdim3.
*            data-p = data-p + w_dados-qtde.
*          ENDLOOP.
*          APPEND data.
*        ELSE.
*          data-p = 0.
*          APPEND data.
*        ENDIF.
*
*
*      ENDLOOP.
*    ENDLOOP.
*
*  ENDLOOP.
*
*
*  DATA: ln TYPE sy-tabix.
*  LOOP AT tdim3.
*    ln = sy-tabix.
*
*
*    READ TABLE t_permiss WITH KEY bukrs = tdim3.
*
*    CONCATENATE '(' t_permiss-bukrs ')' t_permiss-butxt INTO tdim3 SEPARATED BY space.
*
*    MODIFY tdim3 INDEX ln.
*
*  ENDLOOP.
*
*  CALL FUNCTION 'GRAPH_MATRIX'
*    EXPORTING
*      titl  = 'Gráficos MIGOxMIRO'
*      valt  = 'Notas'
*      dim1  = 'Status'
*      dim2  = 'Data'
*      dim3  = 'Fornecedor'
*    TABLES
*      data  = data
*      tdim1 = tdim1
*      tdim2 = tdim2
*      tdim3 = tdim3
*      opts  = opts.
*

ENDFORM.                    " ZF_GERAR_NOVO_GRAFICO
*&---------------------------------------------------------------------*
*&      Form  G_GET_LOGS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_logs .

  REFRESH: it_logunk, it_fieldcat.
  SELECT * FROM zhms_tb_logunk INTO TABLE it_logunk.

  SORT it_logunk DESCENDING.

  wa_fieldcat-fieldname  = 'LOTE'.
  wa_fieldcat-seltext_m  = 'Lote'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR: wa_fieldcat.
  wa_fieldcat-fieldname  = 'ERRO'.
  wa_fieldcat-seltext_m  = 'Descricao'.
  wa_fieldcat-outputlen = '100'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR: wa_fieldcat.
  wa_fieldcat-fieldname  = 'DTALT'.
  wa_fieldcat-seltext_m  = 'Data'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR: wa_fieldcat.
  wa_fieldcat-fieldname  = 'HRALT'.
  wa_fieldcat-seltext_m  = 'Hora'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR: wa_fieldcat.
  wa_fieldcat-fieldname  = 'TYPED'.
  wa_fieldcat-seltext_m  = 'Tipo'.
  APPEND wa_fieldcat TO it_fieldcat.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      it_fieldcat   = it_fieldcat
    TABLES
      t_outtab      = it_logunk
    EXCEPTIONS
      program_error = 1
      OTHERS        = 2.
ENDFORM.                    " G_GET_LOGS
