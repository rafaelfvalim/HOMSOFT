*----------------------------------------------------------------------*
*                      H  o  m  S  o  f  t                             *
*          Gestão Eletrônica de Documentos e Processos                 *
*----------------------------------------------------------------------*
* Descrição: Monitor Central de Gerenciamento de Documentos            *
*            Sub-Rotinas (Monitor)                                     *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*   Form  F_SEL_INDEX_NFS
*----------------------------------------------------------------------*
*   Selecionando dados do Índice
*----------------------------------------------------------------------*
    form f_sel_index_nfs.
***   Selecionando Naturezas dos Documentos Cadastradas
      perform f_sel_masterd_index.

      loop at t_nature into wa_nature.
        clear wa_index.
        move:  '' to wa_index-fathr,
               wa_nature-natdc to wa_index-sonhr.

***     Lendo denominação da Natureza do Documento
        clear wa_nature_t.
        read table t_nature_t into     wa_nature_t
                              with key natdc = wa_nature-natdc binary search.

        if sy-subrc eq 0.
          move wa_nature_t-denom to wa_index-denom.
        endif.

***     Preparando Ícone
        clear: vg_icon_id,
               vg_icon_url.

        move wa_nature-icons to vg_icon_id.
        concatenate wa_nature-icons '.GIF'
               into vg_icon_url.
        move vg_icon_url to wa_index-iconh.

***     Carregando Ícone Padrão
        perform f_load_images using vg_icon_id
                                    vg_icon_url.

        append wa_index to t_index.

        loop at t_type into  wa_type
                       where natdc eq wa_nature-natdc.

          clear wa_index.
          move: wa_nature-natdc to wa_index-fathr,
                wa_type-typed   to wa_index-sonhr,
                wa_type-loctp   to wa_index-loctp.

***       Lendo denominação do Tipo de Documento
          clear wa_type_t.
          read table t_type_t into     wa_type_t
                              with key natdc = wa_type-natdc
                                       typed = wa_type-typed
                                       loctp = wa_type-loctp binary search.

          if sy-subrc eq 0.
            move wa_type_t-denom to wa_index-denom.
          endif.

          append wa_index to t_index.
        endloop.
      endloop.
    endform.                    " F_SEL_INDEX_NFS

*----------------------------------------------------------------------*
*   Form  F_REG_EVENTS_INDEX
*----------------------------------------------------------------------*
*   Registrando Eventos do HTML Index
*----------------------------------------------------------------------*
    form f_reg_events_index.
***   Obtendo Eventos
      refresh t_events.
      clear   wa_event.
      move:   ob_html_index->m_id_sapevent to wa_event-eventid,
              'X'                          to wa_event-appl_event.
      append  wa_event to t_events.

***   Registrando Eventos
      call method ob_html_index->set_registered_events
        exporting
          events = t_events.

      if ob_receiver is initial.
***     Criando objeto para Eventos HTML
        create object ob_receiver.
***     Ativando gatilho de eventos
        set handler ob_receiver->on_sapevent for ob_html_index.
      else.
***     Ativando gatilho de eventos
        set handler ob_receiver->on_sapevent for ob_html_index.
      endif.
    endform.                    " F_REG_EVENTS_INDEX

*----------------------------------------------------------------------*
*   Form  F_REG_EVENTS_DOCS
*----------------------------------------------------------------------*
*   Registrando Eventos do HTML Documentos
*----------------------------------------------------------------------*
    form f_reg_events_docs.
***   Obtendo Eventos
      refresh t_events.
      clear   wa_event.
      move:   ob_html_docs->m_id_sapevent to wa_event-eventid,
              'X'                         to wa_event-appl_event.
      append  wa_event to t_events.

***   Registrando Eventos
      call method ob_html_docs->set_registered_events
        exporting
          events = t_events.

      if ob_receiver is initial.
***     Criando objeto para Eventos HTML
        create object ob_receiver.
***     Ativando gatilho de eventos
        set handler ob_receiver->on_sapevent for ob_html_docs.
      else.
***     Ativando gatilho de eventos
        set handler ob_receiver->on_sapevent for ob_html_docs.
      endif.
    endform.                    " F_REG_EVENTS_DOCS


*----------------------------------------------------------------------*
*   Form  F_REG_EVENTS_det
*----------------------------------------------------------------------*
*   Registrando Eventos do HTML Documentos
*----------------------------------------------------------------------*
    form f_reg_events_det.
***   Obtendo Eventos
      refresh t_events.
      clear   wa_event.
      move:   ob_html_det->m_id_sapevent to wa_event-eventid,
              'X'                        to wa_event-appl_event.
      append  wa_event to t_events.

***   Registrando Eventos
      call method ob_html_det->set_registered_events
        exporting
          events = t_events.

      if ob_receiver is initial.
***     Criando objeto para Eventos HTML
        create object ob_receiver.
***     Ativando gatilho de eventos
        set handler ob_receiver->on_sapevent for ob_html_det.
      else.
***     Ativando gatilho de eventos
        set handler ob_receiver->on_sapevent for ob_html_det.
      endif.
    endform.                    " F_REG_EVENTS_det

*----------------------------------------------------------------------*
*   Form  F_REG_EVENTS_det
*----------------------------------------------------------------------*
*   Registrando Eventos do HTML Documentos
*----------------------------------------------------------------------*
    form f_reg_events_rcp.
***   Obtendo Eventos
      refresh t_events.
      clear   wa_event.
      move:   ob_html_rcp->m_id_sapevent to wa_event-eventid,
              'X'                        to wa_event-appl_event.
      append  wa_event to t_events.

***   Registrando Eventos
      call method ob_html_rcp->set_registered_events
        exporting
          events = t_events.

      if ob_receiver is initial.
***     Criando objeto para Eventos HTML
        create object ob_receiver.
***     Ativando gatilho de eventos
        set handler ob_receiver->on_sapevent for ob_html_rcp.
      else.
***     Ativando gatilho de eventos
        set handler ob_receiver->on_sapevent for ob_html_rcp.
      endif.
    endform.                    " F_REG_EVENTS_det

*----------------------------------------------------------------------*
*   Form  F_SEL_MASTERD_INDEX
*----------------------------------------------------------------------*
*   Selecionando Dados Mestres do Índice
*----------------------------------------------------------------------*
    form f_sel_masterd_index.
      refresh: t_nature,
               t_nature_t.
      clear:   wa_nature,
               wa_nature_t.

***   Lendo Nature do Documento
      select * from zhms_tb_nature
               into table t_nature.

      if sy-subrc eq 0.
        sort t_nature by natdc.

***     Selecionando Tipos de Documentos Cadastrados
        perform f_sel_type_docs.

***     Lendo Denominação da Nature do Documento
        select * from zhms_tx_nature
                 into table t_nature_t
                 for all entries in t_nature
                 where natdc eq t_nature-natdc      and
                       spras eq sy-langu.

        if sy-subrc eq 0.
          sort t_nature_t by natdc.
        endif.
      endif.
    endform.                    " F_SEL_MASTERD_INDEX

*----------------------------------------------------------------------*
*   Form  F_SEL_TYPE_DOCS
*----------------------------------------------------------------------*
*   Selecionando Tipos de Documentos Cadastrados
*----------------------------------------------------------------------*
    form f_sel_type_docs.
      refresh: t_type,
               t_type_t.
      clear:   wa_type,
               wa_type_t.

***   Lendo Nature do Documento
      select * from zhms_tb_type
               into table t_type
               for all entries in t_nature
               where natdc eq t_nature-natdc.

      if sy-subrc eq 0.
        sort   t_type by ativo.
        delete t_type where ativo ne 'X'.

        if sy-subrc eq 0.
          sort t_type by natdc typed loctp.

***       Lendo Denominação da Nature do Documento
          select * from zhms_tx_type
                   into table t_type_t
                   for all entries in t_type
                   where natdc eq t_type-natdc      and
                         typed eq t_type-typed      and
                         loctp eq t_type-loctp      and
                         spras eq sy-langu.

          if sy-subrc eq 0.
            sort t_type_t by natdc typed loctp.
          endif.
        endif.
      endif.
    endform.                    " F_SEL_TYPE_DOCS

*----------------------------------------------------------------------*
*   Form  F_LOAD_IMAGES
*----------------------------------------------------------------------*
*   Carregando Imagens, Ícones e JavaScript
*----------------------------------------------------------------------*
    form f_load_images using p_id
                             p_url.
***   ICON RATING NEUTRAL
      call method ob_html_index->load_mime_object
        exporting
          object_id            = p_id
          object_url           = p_url
        exceptions
          object_not_found     = 1
          dp_invalid_parameter = 1
          dp_error_general     = 3
          others               = 4.

      if sy-subrc ne 0.
***     Erro Interno. Contatar Suporte.
        message e000 with text-000.
      endif.
    endform.                    " F_LOAD_IMAGES

*----------------------------------------------------------------------*
*   Form  F_LOAD_IMAGES_DOCS
*----------------------------------------------------------------------*
*   Carregando Imagens e Ícones - Documentos
*----------------------------------------------------------------------*
    form f_load_images_docs using p_id
                                  p_url.
***   ICON RATING NEUTRAL
      call method ob_html_docs->load_mime_object
        exporting
          object_id            = p_id
          object_url           = p_url
        exceptions
          object_not_found     = 1
          dp_invalid_parameter = 1
          dp_error_general     = 3
          others               = 4.

      if sy-subrc ne 0.
***     Erro Interno. Contatar Suporte.
        message e000 with text-000.
      endif.
    endform.                    " F_LOAD_IMAGES_DOCS


*----------------------------------------------------------------------*
*   Form  F_LOAD_IMAGES_det
*----------------------------------------------------------------------*
*   Carregando Imagens e Ícones - Documentos
*----------------------------------------------------------------------*
    form f_load_images_det using p_id
                                  p_url.
***   ICON RATING NEUTRAL
      call method ob_html_det->load_mime_object
        exporting
          object_id            = p_id
          object_url           = p_url
        exceptions
          object_not_found     = 1
          dp_invalid_parameter = 1
          dp_error_general     = 3
          others               = 4.

      if sy-subrc ne 0.
***     Erro Interno. Contatar Suporte.
        message e000 with text-000.
      endif.
    endform.                    " F_LOAD_IMAGES_det


*----------------------------------------------------------------------*
*   Form  F_LOAD_IMAGES_det
*----------------------------------------------------------------------*
*   Carregando Imagens e Ícones - Documentos
*----------------------------------------------------------------------*
    form f_load_images_rcp using p_id
                                  p_url.
***   ICON RATING NEUTRAL
      call method ob_html_rcp->load_mime_object
        exporting
          object_id            = p_id
          object_url           = p_url
        exceptions
          object_not_found     = 1
          dp_invalid_parameter = 1
          dp_error_general     = 3
          others               = 4.

      if sy-subrc ne 0.
***     Erro Interno. Contatar Suporte.
        message e000 with text-000.
      endif.
    endform.                    " F_LOAD_IMAGES_det

*----------------------------------------------------------------------*
*   Form  F_SET_INDEX_LINE
*----------------------------------------------------------------------*
*   Recupera índice selecionados
*----------------------------------------------------------------------*
    form f_set_index_line using p_action.
      data: vl_natdc type zhms_tb_type-natdc,
            vl_typed type zhms_tb_type-typed,
            vl_loctp type zhms_tb_type-loctp.

      clear: vg_chave,
             vg_natdc,
             vg_typed,
             vg_event,
             vg_versn,
             vg_qtsel.

***   Obtendo linha selecionada
      split p_action at '|' into vl_natdc
                                 vl_typed
                                 vl_loctp.

      if sy-subrc eq 0.
        sort t_type by natdc typed loctp.

***     Lendo linha selecionada
        clear wa_type.
        read table t_type into     wa_type
                          with key natdc = vl_natdc
                                   typed = vl_typed
                                   loctp = vl_loctp.

        if sy-subrc eq 0.
          move: vl_natdc to vg_natdc,
                vl_typed to vg_typed.

*** Detremina Emissão ou recepão
*          CASE p_action.
*            WHEN '02|NFE|'.

*** Limpa variaveis de sistema
          perform f_clear_sistem.

***       Determinando Tela de Seleção
          perform f_get_sel_screen.

          if not t_cabdoc[] is initial.
            refresh t_codes.
            clear   t_codes.

            append: 'BACKOFFICE' to t_codes,
                    'RECEB'      to t_codes.

***         Carregando Documentos selecionados
            clear vg_0100.
            move '0112' to vg_0100.
            clear vg_screen_call.
            move 'X' to vg_screen_call.

***         Limpando seleção
            move: '0160' to vg_0112_detail,
                  '0160' to vg_0113_detail.

          endif.
*            WHEN '01|NFE|'.
*            WHEN OTHERS.
*          ENDCASE.

        endif.
      endif.
    endform.                    " F_SET_INDEX_LINE

*----------------------------------------------------------------------*
*   Form  F_SEL_DOCS_NFS
*----------------------------------------------------------------------*
*   Selecionando dados dos Documentos
*----------------------------------------------------------------------*
    form f_sel_docs_nfs.

      types: begin of ty_select,
               line type char80,
             end of ty_select.

      data: vl_index        type sy-tabix,
            t_where         type table of ty_select with header line,
            t_where_status  type table of ty_select with header line,
            ls_where        like line of t_where,
            ls_where_tab    type rsdswhere,
            ls_where_status like line of t_where.

      refresh: t_cabdoc, t_docst, t_docrf, t_cabdoc_ref,
               t_docrf_es, t_param, t_lfa1, t_kna1.
      clear:   wa_cabdoc, wa_docst, wa_docrf, wa_docrf_es,
               wa_param, wa_lfa1, wa_kna1, wa_itmdoc, wa_itmdoc_ax.

      loop at t_twhere into wa_twhere where tablename = 'ZHMS_TB_DOCST'.
        loop at wa_twhere-where_tab into ls_where_tab.
          move ls_where_tab to ls_where_status.
          append ls_where_status to t_where_status.
          clear ls_where_status.
        endloop.
        concatenate 'AND ( NATDC EQ ''' vg_natdc '''' ')' into ls_where_status.
        append ls_where_status to t_where_status . clear ls_where_status.
        concatenate 'AND ( TYPED EQ ''' vg_typed '''' ')' into ls_where_status.
        append ls_where_status to t_where_status . clear ls_where_status.
      endloop.
*** inicio alteração David Rosin 14/02/2014
      loop at t_twhere into wa_twhere where tablename = 'ZHMS_TB_CABDOC'.
        loop at wa_twhere-where_tab into ls_where_tab.
          move ls_where_tab to ls_where.
          append ls_where to t_where.
          clear ls_where.
        endloop.
        concatenate 'AND ( NATDC EQ ''' vg_natdc '''' ')' into ls_where.
        append ls_where to t_where . clear ls_where.
        concatenate 'AND ( TYPED EQ ''' vg_typed '''' ')' into ls_where.
        append ls_where to t_where . clear ls_where.
      endloop.
      if not t_where_status[] is initial.
        select *
         into table t_docst
         from zhms_tb_docst
         where (t_where_status).

        if not t_docst[] is initial.

          select *
           into table t_cabdoc
           from zhms_tb_cabdoc
           for all entries in t_docst
           where (t_where)
             and chave = t_docst-chave.
        endif.
      else.
        if not t_where[] is initial.

          select *
            into table t_cabdoc
            from zhms_tb_cabdoc
            where (t_where).
        endif.
      endif.
*      SELECT * FROM zhms_tb_cabdoc
*               INTO TABLE t_cabdoc
*               WHERE natdc EQ vg_natdc      AND
*                     typed EQ vg_typed.

*** Fim Alteração David Rosin 14/02/2014

      if t_cabdoc[] is not initial.
        select *
          into table t_lfa1
          from lfa1
           for all entries in t_cabdoc
         where lifnr eq t_cabdoc-parid.

        select *
          into table t_kna1
          from kna1
           for all entries in t_cabdoc
         where kunnr eq t_cabdoc-parid.

***     Status de Documento
        select *
          into table t_docst
          from zhms_tb_docst
           for all entries in t_cabdoc
         where natdc eq t_cabdoc-natdc
           and typed eq t_cabdoc-typed
           and chave eq t_cabdoc-chave.

* Verifica MIGO x MIRO externa
*        IF sy-uname = 'RSANTOS' OR sy-uname = 'RAFAEL' OR sy-uname = 'VINICIUS'.
        perform zf_check_auto_ext.
*        ENDIF.

***     Documentos Referenciados
        select *
          into table t_docrf
          from zhms_tb_docrf
           for all entries in t_cabdoc
         where natdc eq t_cabdoc-natdc
           and typed eq t_cabdoc-typed
           and chave eq t_cabdoc-chave.

        if t_docrf[] is not initial.

***     Status de Documento refenciado
          select *
            into table t_docst_new
            from zhms_tb_docst
             for all entries in t_docrf
           where natdc eq t_docrf-ntdrf
             and typed eq t_docrf-tpdrf
             and chave eq t_docrf-chvrf.

          loop at t_docst_new into wa_docst.
            append wa_docst to t_docst.
          endloop.

***       Dados de documento refenciado
          select *
            into table t_cabdoc_ref
            from zhms_tb_cabdoc
             for all entries in t_docrf
            where natdc eq t_docrf-ntdrf
              and typed eq t_docrf-tpdrf
              and chave eq t_docrf-chvrf.

          loop at t_docrf into wa_docrf.
            clear wa_docrf_es.
            move-corresponding wa_docrf to wa_docrf_es.
            read table t_cabdoc_ref into wa_cabdoc with key chave = wa_docrf-chvrf.
            wa_docrf_es-dcnro = wa_cabdoc-docnr.
            append wa_docrf_es to t_docrf_es.
          endloop.
        endif.
      else.
*        TODO: Organizar Mensagem
        message e002(sy) with 'Nenhum documento encontrado!'.

      endif.

      sort t_cabdoc by chave.

      loop at t_cabdoc into wa_cabdoc.
        clear: wa_lfa1, wa_kna1.
        read table t_lfa1 into wa_lfa1 with key lifnr = wa_cabdoc-parid.
        read table t_kna1 into wa_kna1 with key kunnr = wa_cabdoc-parid.

***     Gravando Número da NFe
        clear wa_param.
        wa_param-chave = wa_cabdoc-chave.
        wa_param-grpdc = vl_index.
        wa_param-tagdc = 'DOCNR'.
        wa_param-denom = 'Nota Fiscal'.

* Patricia
        if vg_typed eq 'NFSE'.
          wa_param-value = wa_cabdoc-docnr.
        else.
* Patricia
          concatenate wa_cabdoc-docnr '-' wa_cabdoc-serie into wa_param-value.
        endif.

        append wa_param to t_param.

***     Gravando Data Lançamento
        clear wa_param.
        wa_param-chave = wa_cabdoc-chave.
        wa_param-grpdc = vl_index.
        wa_param-tagdc = 'DOCDT'.
        wa_param-denom = 'Data Lançamento'.

        write wa_cabdoc-lncdt to wa_param-value.
        append wa_param to t_param.

***     Gravando Fornecedor
        clear wa_param.
        wa_param-chave = wa_cabdoc-chave.
        wa_param-grpdc = vl_index.
        wa_param-tagdc = 'FORN'.
        wa_param-denom = 'Fornecedor'.

        if not wa_lfa1-name1 is initial.

* Inicio - Cancelamento / Migo x Miro externa
          read table t_docst into wa_docst with key chave = wa_cabdoc-chave.
          if sy-subrc eq 0.
            if wa_docst-sthms = 3 and wa_docst-strec = 9.
              concatenate wa_lfa1-name1 '/ NOTA CANCELADA' into wa_param-value.
            elseif wa_docst-sthms = 3 and wa_docst-strec ne 9.
              concatenate wa_lfa1-name1 '/ PROCES. FORA HOMSOFT' into wa_param-value.
            else.
              wa_param-value = wa_lfa1-name1.
            endif.
          else.
            wa_param-value = wa_lfa1-name1.
          endif.

        elseif not wa_kna1-name1 is initial.
          wa_param-value = wa_kna1-name1.
        endif.
        append wa_param to t_param.

        vl_index = vl_index + 1.
      endloop.
    endform.                    " F_SEL_DOCS_NFS

*----------------------------------------------------------------------*
*   Form  F_GET_SEL_SCREEN
*----------------------------------------------------------------------*
*   Determinando Tela de Seleção
*----------------------------------------------------------------------*
    form f_get_sel_screen.
      refresh t_grpfld_s.
      clear   t_grpfld_s.

***   Lendo Tela de Seleção a ser montada
      select *
             from zhms_tb_grpfld_s
             into table t_grpfld_s
             where codgf eq wa_type-codgf.

      if sy-subrc eq 0.
        sort t_grpfld_s by codgf seqnr tabss fldss.

***     Preparando tela de seleção dinâmica
        perform f_prep_sel_dynn.
***     Chamando tela de seleção dinâmica
        perform f_call_sel_dynn.

        if not t_twhere[] is initial.

**** Limpa variaveis de sistema
*          PERFORM f_clear_sistem.

***       Selecionando dados dos Documentos
          perform f_sel_docs_nfs.
        endif.
      else.
***     Tela de Seleção Inexistente. Contatar Suporte.
        message w001.
        stop.
      endif.
    endform.                    " F_GET_SEL_SCREEN

*----------------------------------------------------------------------*
*   Form  F_PREP_SEL_DYNN
*----------------------------------------------------------------------*
*   Preparando tela de seleção dinâmica
*----------------------------------------------------------------------*
    form f_prep_sel_dynn.
      types: begin of ty_tbl_sc,
               tblnm type tabname,
             end of ty_tbl_sc.
      data: t_tbl_sc  type standard table of ty_tbl_sc,
            wa_tbl_sc type ty_tbl_sc.

***   Verificando quais tabelas serão aceitas na Seleção
      loop at t_grpfld_s into wa_grpfld_s.
        clear  wa_tbl_sc.
        move   wa_grpfld_s-tabss to wa_tbl_sc-tblnm.
        append wa_tbl_sc to t_tbl_sc.
      endloop.

***   Eliminando tabelas duplicadas
      delete adjacent duplicates from t_tbl_sc comparing all fields.

      if not t_tbl_sc[] is initial.
        refresh: t_tabs,
                 t_flds.

***     Carregando Tabelas a serem consideradas
        loop at t_tbl_sc into wa_tbl_sc.
          clear wa_tabs.
          move wa_tbl_sc-tblnm to wa_tabs-prim_tab.
          append wa_tabs to t_tabs.
        endloop.

***     Carregando Campos a serem considerados
        loop at t_grpfld_s into wa_grpfld_s.
          clear wa_flds.
          move: wa_grpfld_s-tabss to wa_flds-tablename,
                wa_grpfld_s-fldss to wa_flds-fieldname,
                wa_grpfld_s-typef to wa_flds-type.
          append wa_flds to t_flds.
        endloop.
      endif.
    endform.                    " F_PREP_SEL_DYNN

*----------------------------------------------------------------------*
*   Form  F_CALL_SEL_DYNN
*----------------------------------------------------------------------*
*   Chamando tela de seleção dinâmica
*----------------------------------------------------------------------*
    form f_call_sel_dynn.
      data: vl_text type sy-title.

***   Inicializando Tela de Seleção
      call function 'FREE_SELECTIONS_INIT'
        exporting
          kind                     = 'T'
          expressions              = t_texpr
        importing
          selection_id             = vg_selid
          number_of_active_fields  = vg_actnum
        tables
          tables_tab               = t_tabs
          fields_tab               = t_flds
        exceptions
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

      if sy-subrc eq 0.
***     Carregando Condições da Tela de Seleção
        call function 'FREE_SELECTIONS_WHERE_2_EX'
          exporting
            where_clauses        = t_twhere
          importing
            expressions          = t_texpr
          exceptions
            incorrect_expression = 1
            others               = 2.

        if sy-subrc eq 0.
          clear wa_type_t.
          read table t_type_t into wa_type_t
                              with key natdc = wa_type-natdc
                                       typed = wa_type-typed
                                       loctp = wa_type-loctp.

          if sy-subrc eq 0.
            clear vl_text.
            move wa_type_t-denom to vl_text.
          endif.

***       Tela de Seleção
          clear vg_title.
          move text-001 to vg_title.

***       Criando tela de seleção
          call function 'FREE_SELECTIONS_DIALOG'
            exporting
              selection_id            = vg_selid
              title                   = vg_title
              tree_visible            = ''
              as_window               = 'X'
              start_row               = '1'
              start_col               = '35'
              frame_text              = vl_text
              status                  = 1
            importing
              where_clauses           = t_twhere
              expressions             = t_texpr
              number_of_active_fields = vg_actnum
            tables
              fields_tab              = t_flds
            exceptions
              internal_error          = 01
              no_action               = 02
              no_fields_selected      = 03
              no_tables_selected      = 04
              selid_not_found         = 05.

          if sy-subrc ne 0  and  sy-subrc ne 2.
***         Erro ao montar a Tela de Seleção. Contatar Suporte.
            message w002.
          endif.
        else.
***       Erro ao montar a Tela de Seleção. Contatar Suporte.
          message w002.
        endif.
      else.
***     Erro ao montar a Tela de Seleção. Contatar Suporte.
        message w002.
      endif.
    endform.                    " F_CALL_SEL_DYNN

*----------------------------------------------------------------------*
*   Form  f_refresh_docs_status
*----------------------------------------------------------------------*
*   Atualizar os status dos documentos
*----------------------------------------------------------------------*
    form f_refresh_docs_status.
      data: wl_cabdoc type zhms_tb_cabdoc.

      refresh: t_datasrc, t_docst_new.
      clear: wa_datasrc, wa_docst_new, wa_docst, wl_cabdoc.

      if t_cabdoc[] is not initial.

*** Sort pelos campos de chave
        sort t_cabdoc by natdc
                         typed
                         chave.
*** Status de Documento
        select *
          into table t_docst_new
          from zhms_tb_docst
           for all entries in t_cabdoc
         where natdc eq t_cabdoc-natdc
           and typed eq t_cabdoc-typed
           and chave eq t_cabdoc-chave.

*** Loop nos documentos
        loop at t_cabdoc into wl_cabdoc.
          v_index = sy-tabix.

**        Read: Status Novo e Status Antigo de Documento
          clear wa_docst_new.
          read table t_docst_new into wa_docst_new with key chave = wl_cabdoc-chave.
          if not sy-subrc is initial.
          endif.

          clear wa_docst.
          read table t_docst into wa_docst with key chave = wl_cabdoc-chave.
          if not sy-subrc is initial.
          endif.

**        Verifica se algum Status HomSoft sofreu alteração
          if wa_docst_new-sthms ne wa_docst-sthms.
**          Insere na tabela interna caso tenha sofrido alterações
            clear wa_datasrc.

            concatenate 'hms_' wl_cabdoc-chave '.innerHTML' into wa_datasrc.
            condense wa_datasrc no-gaps.

            clear vg_status.
            move wa_docst_new-sthms to vg_status.
            condense vg_status no-gaps.

            concatenate '<img src="hms_' vg_status '.gif"  title="HomSoft: ' vg_status '" border="0" />' into vg_status.

            concatenate  '''' vg_status ''';' into vg_status.

            concatenate wa_datasrc '=' vg_status into wa_datasrc separated by space.
            append wa_datasrc to t_datasrc.

            move: wa_docst_new-sthms to wa_docst-sthms.

          endif.

**        Verifica se algum Status Entidade sofreu alteração
          if wa_docst_new-stent ne wa_docst-stent.
**          Insere na tabela interna caso tenha sofrido alterações
            clear wa_datasrc.

            concatenate 'ent_' wl_cabdoc-chave '.innerHTML' into wa_datasrc.
            condense wa_datasrc no-gaps.

            clear vg_status.
            move wa_docst_new-stent to vg_status.
            condense vg_status no-gaps.

            concatenate '<img src="et_' vg_status '.gif"  title="Entidade Tributária: ' vg_status '" border="0" />' into vg_status.

            concatenate  '''' vg_status ''';' into vg_status.

            concatenate wa_datasrc '=' vg_status into wa_datasrc separated by space.
            append wa_datasrc to t_datasrc.

            move: wa_docst_new-sthms to wa_docst-sthms.

          endif.

**        Verifica se algum Status Recebimento sofreu alteração
          if wa_docst_new-strec ne wa_docst-strec.
**          Insere na tabela interna caso tenha sofrido alterações
            clear wa_datasrc.

            concatenate 'rcp_' wl_cabdoc-chave '.innerHTML' into wa_datasrc.
            condense wa_datasrc no-gaps.

            clear vg_status.
            move wa_docst_new-strec to vg_status.
            condense vg_status no-gaps.

            concatenate '<img src="rcp_' vg_status '.gif"  title="Recepção: ' vg_status '" border="0" />' into vg_status.

            concatenate  '''' vg_status ''';' into vg_status.

            concatenate wa_datasrc '=' vg_status into wa_datasrc separated by space.
            append wa_datasrc to t_datasrc.

            move: wa_docst_new-sthms to wa_docst-sthms.

          endif.

*** Atualiza os status dentro da tabela principal
          modify t_docst from wa_docst index v_index.

        endloop.

* Caso exista algum comando a ser executado na página
        if not t_datasrc[] is initial. "AND sy-uname EQ 'JUNPSAMP'.

          try .
*        Chamada de empresa
              call method ob_html_docs->run_script_on_demand
                exporting
                  script = t_datasrc
                exceptions
                  others = 1.
            catch  cx_root into  l_ex_ref.

          endtry.

        endif.
      endif.
    endform.                    "f_refresh_docs_status

*----------------------------------------------------------------------*
*   Form  f_show_document_det
*----------------------------------------------------------------------*
*   Atualizar os status dos documentos
*----------------------------------------------------------------------*
    form f_show_document_det using p_first.
      data: vl_name1  type lfa1-name1,
            vl_dayw   type scal-indicator,
            vl_langt  type t246-langt,
            vl_ltx    type t247-ltx,
            vl_mnr    type t247-mnr,
            vl_sep(4) type c,
            vl_qtdmn  type i,
            vl_data   type string,
            vl_hora   type string,
            vl_butxt  type t001-butxt,
            vl_name   type j_1bbranch-name.

      refresh: t_datasrc.

*      CLEAR: wa_datasrc.
*      CONCATENATE 'cenario.innerText=''' 'Entrada Normal' ''';' INTO wa_datasrc.
*      APPEND wa_datasrc TO t_datasrc.
**
      read table t_docst into wa_docst with key chave = vg_chave.

      clear: wa_datasrc.

      if wa_cabdoc-natdc eq '01'. " Caso Emissão
        " Status Principal - Status Entidade
        wa_datasrc = wa_docst-stent.
        condense wa_datasrc no-gaps.
        concatenate 'img_status.src=''et_' wa_datasrc '.gif'';' into wa_datasrc.
      else. " Caso Recepção
        " Status Principal - Status HomSoft
        wa_datasrc = wa_docst-sthms.
        condense wa_datasrc no-gaps.
        concatenate 'img_status.src=''hms_' wa_datasrc '.gif'';' into wa_datasrc.
      endif.


      condense wa_datasrc no-gaps.
      append wa_datasrc to t_datasrc.

* Patricia
      if vg_typed eq 'NFSE'.

        vg_docnr = wa_cabdoc-docnr.

        call function 'CONVERSION_EXIT_ALPHA_OUTPUT'
          exporting
            input  = vg_docnr
          importing
            output = vg_docnr.

        clear: wa_datasrc.
        concatenate 'dc_numero.innerText=''' vg_docnr ''';' into wa_datasrc.
        append wa_datasrc to t_datasrc.
      else.

        clear: wa_datasrc.
        concatenate 'dc_numero.innerText=''' wa_cabdoc-docnr '-' wa_cabdoc-serie ''';' into wa_datasrc.
        append wa_datasrc to t_datasrc.
      endif.

* Patricia

      call function 'DATE_COMPUTE_DAY'
        exporting
          date = wa_cabdoc-docdt
        importing
          day  = vl_dayw.

      select single langt
        into vl_langt
        from t246
       where wotnr eq vl_dayw
         and sprsl eq sy-langu.

      vl_mnr = wa_cabdoc-docdt+4(2).
      select single ltx
        into vl_ltx
        from t247
       where spras eq sy-langu
         and mnr   eq vl_mnr.

**    Texto de nome da empresa
      select single butxt into vl_butxt
        from t001
       where bukrs eq wa_cabdoc-bukrs.


**    Texto de nome de parceiro
      select single name1
        into vl_name1
        from lfa1
       where lifnr eq wa_cabdoc-parid.

      select single name
        into vl_name
        from j_1bbranch
       where bukrs  eq wa_cabdoc-bukrs
         and branch eq wa_cabdoc-branch.

      clear: wa_datasrc.
      concatenate 'dc_dtdoct.innerText=''' 'Data do Documento' ''';' into wa_datasrc.
      append wa_datasrc to t_datasrc.

      vl_sep = 'de'.

      clear: wa_datasrc.

      concatenate  vl_langt ',' wa_cabdoc-docdt+6 vl_sep vl_ltx vl_sep wa_cabdoc-docdt(4) into wa_datasrc separated by space.
      concatenate 'dc_dtdocv.innerText=''' wa_datasrc ''';' into wa_datasrc.
      append wa_datasrc to t_datasrc.

      clear: wa_datasrc.
      concatenate 'dc_partnt.innerText=''' 'Fornecedor nro:' ''';' into wa_datasrc.
      append wa_datasrc to t_datasrc.


      clear: wa_datasrc.
      concatenate 'dc_partnv.innerText=''' '(' wa_cabdoc-parid ')' vl_name1 ''';' into wa_datasrc.
      append wa_datasrc to t_datasrc.

      clear: wa_datasrc.
      concatenate 'dc_bukrst.innerText=''' 'Empresa' ''';' into wa_datasrc.
      append wa_datasrc to t_datasrc.

      clear: wa_datasrc.
      concatenate 'dc_bukrsv.innerText=''(' wa_cabdoc-bukrs ')' vl_butxt ''';' into wa_datasrc separated by space.
      append wa_datasrc to t_datasrc.

      clear: wa_datasrc.
      concatenate 'dc_brancht.innerText=''' 'Filial' ''';' into wa_datasrc.
      append wa_datasrc to t_datasrc.

      clear: wa_datasrc.
      concatenate 'dc_branchv.innerText=''(' wa_cabdoc-branch ')' vl_name ''';' into wa_datasrc separated by space.
      append wa_datasrc to t_datasrc.



      if not vg_chave_main is initial.
        clear vl_name1.

**      Busca nome do fornecedor / cliente
        select single name1
          into vl_name1
          from lfa1
         where lifnr eq wa_cabdoc_main-parid.

        if not sy-subrc is initial.
          select single name1
            into vl_name1
            from kna1
           where kunnr eq wa_cabdoc_main-parid.
        endif.

        clear: wa_datasrc.
        concatenate 'dc_reftxt.innerHTML=''' 'Referência à <b>' wa_cabdoc_main-docnr '-' wa_cabdoc_main-serie '</b>' ''';' into wa_datasrc.
        append wa_datasrc to t_datasrc.

        clear: wa_datasrc.
        concatenate 'dc_refvlr.innerHTML='''  '<em>' vl_name1 '</em>'  ''';' into wa_datasrc.
        append wa_datasrc to t_datasrc.

      else.

        clear: wa_datasrc.
        concatenate 'dc_reftxt.innerHTML=''' '' ''';' into wa_datasrc.
        append wa_datasrc to t_datasrc.

        clear: wa_datasrc.
        concatenate 'dc_refvlr.innerHTML=''' '' ''';' into wa_datasrc.
        append wa_datasrc to t_datasrc.

      endif.

***   Caso exista algum comando a ser executado na página
      if not t_datasrc[] is initial
        and ob_html_det is not initial
        and p_first is initial.
***       Chamada de empresa
        call method ob_html_det->run_script_on_demand
          exporting
            script = t_datasrc
          exceptions
            others = 1.

      endif.
    endform.                    "f_show_document_det
*----------------------------------------------------------------------*
*   Form  F_TIMER_REFRESH_DOCS
*----------------------------------------------------------------------*
*   Timer para refresh de status de documentos no monitor
*----------------------------------------------------------------------*
    form f_timer_refresh_docs.
      if ob_timer is initial.
***     Criando objeto de Timer
        create object ob_timer
          exceptions
            error  = 1
            others = 2.

        if sy-subrc eq 0.
***       Criando Objeto Event Timer
          create object ob_timer_event.

          if sy-subrc eq 0.
            set handler ob_timer_event->handle_finished for ob_timer.
*            SET HANDLER ob_timer_wl_event->handle_finished FOR ob_timer.
          endif.
        endif.
      endif.

*      ob_timer->interval = c_interval.
      ob_timer->interval = 1.

***   Ativando Timer
      call method ob_timer->run
        exceptions
          error  = 1
          others = 2.

      if sy-subrc ne 0.
***     Error
      endif.
    endform.                    " F_TIMER_REFRESH_DOCS

*----------------------------------------------------------------------*
*   Form  f_set_docs_lines
*----------------------------------------------------------------------*
*   Recupera documentos selecionados
*----------------------------------------------------------------------*
    form f_set_docs_lines using p_postdata.
      data: vl_chave type zhms_tb_cabdoc-chave.

      clear: vg_chave,
             vg_chave_main,
             vg_event,
             vg_versn.

**    Retira "lista=" proveniente do HTML
      p_postdata = p_postdata+6.

**    Identifica documento principal
      refresh t_chave.
      split p_postdata at '@' into table t_chave.
**    Verifica se existe principal

      clear vg_qtsel.
      describe table t_chave lines vg_qtsel.
**    Registra dados encontrados

      if vg_qtsel gt 1.
**      Chave do documento principal
        read table t_chave into vl_chave index 1.
        vg_chave_main = vl_chave.

**      Chave do documento referenciado (selecionado)
        read table t_chave into vl_chave index 2.
        p_postdata = vl_chave.
      endif.

**    Divide a lista para identificação de quantos documentos foram selecionados
      refresh t_chave.
      split p_postdata at '|' into table t_chave.

**    Conta documentos
      clear vg_qtsel.
      describe table t_chave lines vg_qtsel.

      if vg_qtsel eq 1.
        clear vl_chave.
        read table t_chave into vl_chave index 1.

        if sy-subrc eq 0.
          clear vg_chave.
          move: vl_chave to vg_chave.

          clear wa_cabdoc.
          read table t_cabdoc into wa_cabdoc with key chave = vg_chave.

**        Mneumonicos do documento
          clear wa_docmn.
          perform f_refresh_docmn.

**        Documento Referenciado
          if sy-subrc ne 0.
            read table t_cabdoc_ref into wa_cabdoc with key chave = vg_chave.
            read table t_cabdoc into wa_cabdoc_main with key chave = vg_chave_main.
          endif.


          if sy-subrc eq 0.
            move: wa_cabdoc-edurl to vg_edurl,
                  '01'            to vg_event,
                  '2.0'           to vg_versn,
                  '0150'          to vg_0112_detail,
                  '0150'          to vg_0113_detail.
          endif.
        endif.
      elseif vg_qtsel ne 1.
        move: '0160' to vg_0112_detail,
              '0160' to vg_0113_detail.
      endif.

    endform.                    "f_set_docs_lines


*----------------------------------------------------------------------*
*   Form  F_BUILD_FIELDCAT
*----------------------------------------------------------------------*
*   Carregando Estrutura de Campos
*----------------------------------------------------------------------*
    form f_build_fieldcat.
      refresh t_fieldcat.
      clear   wa_fieldcat.

***   Obtendo campos
      call function 'LVC_FIELDCATALOG_MERGE'
        exporting
          i_structure_name       = 'ZHMS_ES_XMLVIEW'
        changing
          ct_fieldcat            = t_fieldcat
        exceptions
          inconsistent_interface = 1
          program_error          = 2
          others                 = 3.

      if sy-subrc eq 0.
***     Alterando campos a serem exibidos
        loop at t_fieldcat into wa_fieldcat.
          case wa_fieldcat-fieldname.
            when 'CODLY' or 'HIELY' or 'XMLTG' or 'DENOM' or 'MNEUM' or 'SEQNR'.
              wa_fieldcat-no_out = 'X'.
              wa_fieldcat-key    = ''.

            when others.

          endcase.

          modify t_fieldcat from wa_fieldcat.
        endloop.
      endif.
    endform.                               " F_BUILD_FIELDCAT

*----------------------------------------------------------------------*
*   Form  f_build_hier_header
*----------------------------------------------------------------------*
*   Setando valores do Header da TREE
*----------------------------------------------------------------------*
    form f_build_hier_header.
      clear wa_hier_header.
      move: 'Campo'  to wa_hier_header-heading,
            text-h02 to wa_hier_header-tooltip,
            100       to wa_hier_header-width,
            ''       to wa_hier_header-width_pix.
    endform.                               " build_hierarchy_header

*----------------------------------------------------------------------*
*   Form  f_create_hier
*----------------------------------------------------------------------*
*   Criando Hierarquia da TREE do XML
*----------------------------------------------------------------------*
    form f_create_hier.
      data: l_last_key   type lvc_nkey,
            l_parent_key type lvc_nkey.

***   Construíndo tabela de saída
      perform f_build_outtab.

***   Adicionando dados à TREE
      t_xmlview_aux[] = t_xmlview[].

***   Limpar Variáveis de chave
      clear: l_last_key, l_parent_key.

      loop at t_xmlview_aux into wa_xmlview.
***     Adicionando nós na árvore
        perform f_add_no    using wa_xmlview wa_xmlview-nodep
                         changing l_last_key.
      endloop.

***   Atualizando valores no Objeto TREE criado
      call method ob_xml_docs->frontend_update.
    endform.                    " f_create_hier


*----------------------------------------------------------------------*
*   Form  f_build_outtab
*----------------------------------------------------------------------*
*   Construíndo tabela de saída
*----------------------------------------------------------------------*
    form f_build_outtab.
      types: begin of ty_path,
               line type zhms_de_codly,
             end of ty_path,

             begin of ty_cnodes,
               codly type zhms_de_codly,
               nodek type lvc_nkey,
               found type c,
             end of ty_cnodes.

      data: t_split      type table of string,
            t_path       type table of ty_path,
            t_cnodes     type table of ty_cnodes,
            wa_path      type ty_path,
            wa_cnodes    type ty_cnodes,
            vl_split     type string,
            vl_count     type i,
            vl_idxsplit  type sy-tabix,
            vl_seqnr     type zhms_de_seqnr,
            vl_path      type string,
            vl_seqnr_new type zhms_de_seqnr.

***   Lendo dados do documento
      perform f_sel_xml_doc.

      loop at t_evv_layt into wa_evv_layt.
        replace 'NFEPROC/' with '' into wa_evv_layt-field.
        condense wa_evv_layt-field no-gaps.
        modify t_evv_layt from wa_evv_layt index sy-tabix.
      endloop.

      clear vl_seqnr.

***   Loop nos dados encontrados para montar dados a serem exibidos
      loop at t_repdoc into wa_repdoc.
        add 1 to vl_count.

        clear: wa_xmlview.
***     Dados Diretos
        wa_xmlview-xmltg = wa_repdoc-field.
        replace 'NFEPROC/' with '' into wa_repdoc-field.
        condense wa_repdoc-field no-gaps.
        wa_xmlview-value = wa_repdoc-value.

***     Denominação
        clear wa_evv_layt.
        read table t_evv_layt into wa_evv_layt with key field = wa_repdoc-field.

        if sy-subrc is initial.
          clear wa_evv_laytx.
          read table t_evv_laytx into wa_evv_laytx with key codly = wa_evv_layt-codly.

          if sy-subrc eq 0.
            wa_xmlview-denom = wa_evv_laytx-denof.
          else.
*            BREAK-POINT.
          endif.
        else.
*          BREAK-POINT.
        endif.

        move vl_count to wa_xmlview-nodek.

***     Split de TAG: Identificar Tag Meneumônico e Tags Pais.
        split wa_repdoc-field at '/' into table t_split.

***     Identifica quantidade de registros em SPLIT
        describe table t_split lines vl_idxsplit.

        clear vl_split.
        read table t_split into vl_split index vl_idxsplit.

        if sy-subrc eq 0.
          wa_xmlview-mneum = vl_split.
          wa_xmlview-codly = vl_split.
        endif.

***     Identifica Tag Pai.
        vl_idxsplit = vl_idxsplit - 1.

        if vl_idxsplit gt 0.
          clear vl_split.
          read table t_split into vl_split index vl_idxsplit.

          if sy-subrc eq 0.
            wa_xmlview-hiely = vl_split.
          endif.
        endif.

***     Indice de Tag
        vl_seqnr = vl_seqnr + 10.
        wa_xmlview-seqnr = vl_seqnr.

        append wa_xmlview to t_xmlview.
      endloop.

      loop at t_xmlview into wa_xmlview.
***     Identifica os pais possíveis
***     Explodir Tags
        split wa_xmlview-xmltg at '/' into table t_split.

***     Monta estrutura atual
        loop at t_split into vl_split.
          clear wa_path.
          wa_path-line = vl_split.
          append wa_path to t_path.
        endloop.

***     Adiciona Item Atual à lista de nós possíveis
        clear wa_cnodes.
        wa_cnodes-codly = wa_xmlview-codly.
        wa_cnodes-nodek = wa_xmlview-nodek.
        append wa_cnodes to t_cnodes.

***     Limpa nós possíveis apenas com chaves conhecidas
***     Caso o pai encontrado não esteja presente na lista a Integridade do XML está comprometida
***     Para estes casos verificar Ordenação da tabela interna: t_xmlview ou do documento no Repositório
        loop at t_cnodes into wa_cnodes.
          clear: wa_cnodes-found,
                 wa_path.

          read table t_path into wa_path with key line = wa_cnodes-codly.

          if sy-subrc is initial.
            wa_cnodes-found = 'X'.
            modify t_cnodes from wa_cnodes.
          endif.
        endloop.

        delete t_cnodes where found is initial.

***     Identifica penúltimo nó (pai)
        clear vl_idxsplit.
        describe table t_path lines vl_idxsplit.

        vl_idxsplit = vl_idxsplit - 1.

        check vl_idxsplit gt 0.

        clear wa_path.
        read table t_path into wa_path index vl_idxsplit.

        if sy-subrc eq 0.
***       Retona código do Pai
          clear wa_cnodes.
          read table t_cnodes into wa_cnodes with key codly = wa_path-line.

          if sy-subrc eq 0.
            wa_xmlview-nodep = wa_cnodes-nodek.
***         Modifica tabela de layout
            modify t_xmlview from wa_xmlview.
          endif.
        endif.
      endloop.

***   Remove Tags não identificadas (TODO: RETIRAR)
      delete t_xmlview where nodep is initial
                         and nodek ne '000000000001'
                         and seqnr ne 10.
      read table t_xmlview into wa_xmlview index 1.
      wa_xmlview-denom = vg_typed.
      modify t_xmlview from wa_xmlview index 1.

    endform.                               " f_build_outtab

*----------------------------------------------------------------------*
*   Form  f_add_no
*----------------------------------------------------------------------*
*   Adicionando nós na árvore
*----------------------------------------------------------------------*
    form f_add_no  using  p_wa_xmlview type zhms_es_xmlview
                          p_relat_key
                changing  p_node_key type lvc_nkey.

***   Variáveis locais para controle de exibição da Árvore
      data: lt_item_layout type lvc_t_layi,
            ls_item_layout type lvc_s_layi,
            l_node_text    type lvc_value.

***   Texto para exibição
      l_node_text =  p_wa_xmlview-denom.

***   Layout da Árvore
      ls_item_layout-fieldname = ob_xml_docs->c_hierarchy_column_name.
      append ls_item_layout to lt_item_layout.

***   Chamada do método que insere linhas na árvore
      call method ob_xml_docs->add_node
        exporting
          i_relat_node_key = p_relat_key
          i_relationship   = cl_gui_column_tree=>relat_last_child
          is_outtab_line   = p_wa_xmlview
          i_node_text      = l_node_text
          it_item_layout   = lt_item_layout
        importing
          e_new_node_key   = p_node_key.

    endform.                    " F_ADD_NO

*----------------------------------------------------------------------*
*   Form  F_SEL_XML_DOC
*----------------------------------------------------------------------*
*   Lendo dados do documento
*----------------------------------------------------------------------*
    form f_sel_xml_doc.
      data: v_versao type zhms_tb_ev_vrs-versn.

      refresh: t_repdoc,
               t_evv_layt,
               t_evv_laytx.

      clear: v_versao.

*** Seleção da versão
      select single versn
        into v_versao
           from zhms_tb_ev_vrs
        where
          natdc = wa_cabdoc-natdc and
          typed = wa_cabdoc-typed and
          event in ('01','1')     and
          ativo = 'X'.

***   Seleção da nota no repositório
      select *
             from zhms_tb_repdoc
             into table t_repdoc
             where chave eq vg_chave.

      if sy-subrc eq 0.
*        SORT t_repdoc BY chave.
***     Seleção do layout de documento da nota
*        SELECT *
*               FROM zhms_tb_evv_layt
*               INTO TABLE t_evv_layt
*               WHERE natdc EQ  '02'  AND "
*                     typed EQ  'NFE' AND "
*                     loctp EQ  ''    AND "
*                     event EQ  '1'  AND "
*                     versn EQ  '2.0' .   "

        select *
             from zhms_tb_evv_layt
             into table t_evv_layt
             where natdc = wa_cabdoc-natdc and
                   typed = wa_cabdoc-typed and
                   loctp eq  wa_cabdoc-loctp  and
                   event in ('01','1')     and
                   versn eq  v_versao.

        if sy-subrc eq 0.
*          SORT t_evv_layt BY natdc typed loctp event versn.

***       Busca textos do layout
          select *
                 from zhms_tx_evv_layt
                 into table t_evv_laytx
                 for all entries in t_evv_layt
                 where natdc eq t_evv_layt-natdc     and
                       typed eq t_evv_layt-typed     and
                       loctp eq t_evv_layt-loctp     and
                       event eq t_evv_layt-event     and
                       versn eq t_evv_layt-versn     and
                       codly eq t_evv_layt-codly     and
                       spras eq sy-langu.

          if sy-subrc eq 0.
*            SORT t_evv_laytx BY natdc typed loctp event versn codly.
          endif.
        endif.
      else.
***     TO DO...
      endif.
    endform.                    " F_SEL_XML_DOC

*----------------------------------------------------------------------*
*   Form  F_BTNS_TB_DOCS
*----------------------------------------------------------------------*
*   Criando botões da TOOLBAR dos Documentos
*----------------------------------------------------------------------*
    form f_btns_tb_docs.
*      DATA vl_index TYPE sy-tabix.
      data: vl_fcode type zhms_tb_toolbar-fcode,
            vl_flag  type flag.

      refresh: t_toolbar, t_btnmnu, t_buttons.
      clear:   wa_toolbar, wa_btnmnu, wa_buttons.

***   Lendo Lista de Relatórios a serem criados no Menu
      select *
             from zhms_tb_toolbar
             into table t_toolbar
             where natdc eq vg_natdc      and
                   typed eq vg_typed      and
                   scren eq 'DOCS'        and
                   spras eq sy-langu.     " RCP - 25/09/2018



      if sy-subrc eq 0.
        sort t_toolbar by natdc typed fcode.

        create object ob_menu_docs.
        t_toolbar_aux[] = t_toolbar[].

        loop at t_toolbar
           into wa_toolbar
          where pcode is initial.

          vl_fcode = wa_toolbar-fcode.
          condense vl_fcode no-gaps.

          read table t_toolbar_aux into wa_toolbar_aux with key pcode = wa_toolbar-bcode.

          if sy-subrc is initial.
            perform f_create_buttons_tool using vl_fcode
                                                wa_toolbar-icon
                                                wa_toolbar-text
                                                wa_toolbar-text
                                                '1'.
          else.
            perform f_create_buttons_tool using vl_fcode
                                    wa_toolbar-icon
                                    wa_toolbar-text
                                    ''
                                    '0'.
          endif.
        endloop.
***     Adicionando botões na TOOLBAR
        call method ob_tb_docs->add_button_group
          exporting
            data_table = t_buttons.

        loop at t_toolbar
           into wa_toolbar
          where pcode is initial.

          read table t_toolbar_aux into wa_toolbar_aux with key pcode = wa_toolbar-bcode.
          if sy-subrc is initial.

            loop at t_toolbar
               into wa_toolbar
              where pcode eq wa_toolbar-bcode.

              call method ob_menu_docs->add_function
                exporting
                  fcode = wa_toolbar-fcode
                  text  = wa_toolbar-text.

            endloop.

            move:   vl_fcode     to wa_btnmnu-function,
                    ob_menu_docs to wa_btnmnu-ctmenu.
            append  wa_btnmnu    to t_btnmnu.

            call method ob_tb_docs->assign_static_ctxmenu_table
              exporting
                table_ctxmenu = t_btnmnu.
          endif.

        endloop.


      endif.
    endform.                    " F_BTNS_TB_DOCS

*----------------------------------------------------------------------*
*   Form  F_BTNS_TB_DET
*----------------------------------------------------------------------*
*   Criando botões da TOOLBAR do Detalhe
*----------------------------------------------------------------------*
    form f_btns_tb_det.

      data: vl_fcode type zhms_tb_toolbar-fcode,
            vl_flag  type flag.

      refresh: t_toolbar, t_btnmnu, t_buttons.
      clear:   wa_toolbar, wa_btnmnu, wa_buttons.

      read table t_cabdoc into wa_cabdoc with key chave = vg_chave.

***   Lendo Lista de Relatórios a serem criados no Menu
      select *
             from zhms_tb_toolbar
             into table t_toolbar
             where natdc eq vg_natdc      and
                   typed eq vg_typed      and
                   scren eq 'DET'         and
                   spras eq sy-langu.     " RCP - 25/09/2018

      if sy-subrc eq 0.

*** Inicio David Rosin
        perform f_filtra_cenario.
*** Fim David Rosin

        sort t_toolbar by natdc typed fcode.

        create object ob_menu_det.
        t_toolbar_aux[] = t_toolbar[].

        loop at t_toolbar
           into wa_toolbar
          where pcode is initial.

          vl_fcode = wa_toolbar-fcode.
          condense vl_fcode no-gaps.

          read table t_toolbar_aux into wa_toolbar_aux with key bcode = wa_toolbar-bcode.

          if sy-subrc is initial.
            perform f_create_buttons_tool using vl_fcode
                                                wa_toolbar-icon
                                                wa_toolbar-text
                                                wa_toolbar-text
                                                '1'.
          else.
            perform f_create_buttons_tool using vl_fcode
                                    wa_toolbar-icon
                                    wa_toolbar-text
                                    wa_toolbar-text
*                                    ''
                                    '0'.
          endif.
        endloop.
***     Adicionando botões na TOOLBAR
        call method ob_tb_det->add_button_group
          exporting
            data_table = t_buttons.

        loop at t_toolbar
           into wa_toolbar
          where pcode is initial.

          read table t_toolbar_aux into wa_toolbar_aux with key pcode = wa_toolbar-bcode.
          if sy-subrc is initial.

            loop at t_toolbar
               into wa_toolbar
              where pcode eq wa_toolbar-bcode.

              call method ob_menu_det->add_function
                exporting
                  fcode = wa_toolbar-fcode
                  text  = wa_toolbar-text.

            endloop.

            move:   vl_fcode     to wa_btnmnu-function,
                    ob_menu_det to wa_btnmnu-ctmenu.
            append  wa_btnmnu    to t_btnmnu.

            call method ob_tb_det->assign_static_ctxmenu_table
              exporting
                table_ctxmenu = t_btnmnu.
          endif.

        endloop.


      endif.

    endform.                    " F_BTNS_TB_DET

*----------------------------------------------------------------------*
*   Form  F_EVENTS_TB_DOCS
*----------------------------------------------------------------------*
*   Registrando Eventos da TOOLBAR - Documentos
*----------------------------------------------------------------------*
    form f_events_tb_docs.
      refresh t_evt_docs.

      clear wa_evt_docs.
      move: cl_gui_toolbar=>m_id_function_selected to wa_evt_docs-eventid,
            'X'                                    to wa_evt_docs-appl_event.
      append wa_evt_docs to t_evt_docs.

      call method ob_tb_docs->set_registered_events
        exporting
          events = t_evt_docs.

      set handler cl_app_toolbar=>on_function_selected for ob_tb_docs.
    endform.                    " F_EVENTS_TB_DOCS

*----------------------------------------------------------------------*
*   Form  F_EVENTS_TB_DET
*----------------------------------------------------------------------*
*   Registrando Eventos da TOOLBAR - Detalhe
*----------------------------------------------------------------------*
    form f_events_tb_det.
      refresh t_evt_det.

      clear wa_evt_det.
      move: cl_gui_toolbar=>m_id_function_selected to wa_evt_det-eventid,
            'X'                                    to wa_evt_det-appl_event.
      append wa_evt_det to t_evt_det.

      call method ob_tb_det->set_registered_events
        exporting
          events = t_evt_det.

      set handler cl_app_toolbar=>on_function_selected for ob_tb_det.
    endform.                    " F_EVENTS_TB_DET

*----------------------------------------------------------------------*
*   Form  F_CREATE_BUTTONS_DOCS
*----------------------------------------------------------------------*
*   Criando Botões na TOOLBAR
*----------------------------------------------------------------------*
    form f_create_buttons_tool using p_function
                                     p_icon
                                     p_quickinfo
                                     p_text
                                     p_btype.
***   Criando Botão
      clear  wa_buttons.
      move:  p_function  to wa_buttons-function,
             p_icon      to wa_buttons-icon,
             p_quickinfo to wa_buttons-quickinfo,
             p_text      to wa_buttons-text,
             p_btype     to wa_buttons-butn_type.
      append wa_buttons  to t_buttons.
    endform.                    " F_CREATE_BUTTONS_DOCS


*&---------------------------------------------------------------------*
*&      Form  f_trata_visualizacao_documento
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->V_OKCODE   text
*----------------------------------------------------------------------*
    form f_trata_visualizacao_documento using v_okcode.

**    Identifica ação
      case v_okcode.
        when 'VIS_EXHEAD'.
          vg_vis_shwhead = 'X'.
        when 'VIS_EXITEM'.
          vg_vis_shwitem = 'X'.
        when 'VIS_CLHEAD'.
          clear vg_vis_shwhead. "vg_vld_shwhst.
        when 'VIS_CLITEM'.
          clear vg_vis_shwitem.
      endcase.

**    Seleciona tela conforme seleção
      if  vg_vis_shwhead is initial
        and vg_vis_shwitem is initial.
        vg_0151 = 157.
      endif.

      if vg_vis_shwhead is initial
        and not vg_vis_shwitem is initial.
        vg_0151 = 156.
      endif.

      if not vg_vis_shwhead is initial
        and vg_vis_shwitem is initial.
        vg_0151 = 155.
      endif.

      if not vg_vis_shwhead is initial
        and not vg_vis_shwitem is initial.
        vg_0151 = 154.
      endif.


    endform.                    "f_trata_visualizacao_documento

*----------------------------------------------------------------------*
*   Form  F_BUILD_FIELDCAT
*----------------------------------------------------------------------*
*   Carregando Estrutura de Campos
*----------------------------------------------------------------------*
    form f_build_fieldcat_itens.
      refresh t_fieldcatitm.
      clear   wa_fieldcat.

***   Obtendo campos
      call function 'LVC_FIELDCATALOG_MERGE'
        exporting
          i_structure_name       = 'ZHMS_ES_ITMVIEW'
        changing
          ct_fieldcat            = t_fieldcatitm
        exceptions
          inconsistent_interface = 1
          program_error          = 2
          others                 = 3.

      if sy-subrc eq 0.
***     Alterando campos a serem exibidos
        loop at t_fieldcatitm into wa_fieldcat.
          case wa_fieldcat-fieldname.
            when 'SEQNR' or 'DENOM' or 'DCITM' or 'TDSRF' or 'NRSRF' or 'ATPRP'.
              wa_fieldcat-no_out = 'X'.
              wa_fieldcat-key    = ''.

            when 'DCCMT'.
              wa_fieldcat-outputlen = 15.
            when 'DCQTD'.
              wa_fieldcat-outputlen = 15.
            when 'DCUNM'.
              wa_fieldcat-outputlen = 10.
            when 'DCPRC'.
              wa_fieldcat-outputlen = 17.
            when 'ATLOT'.
              wa_fieldcat-outputlen = 15.

            when others.

          endcase.

          modify t_fieldcatitm from wa_fieldcat.
        endloop.
      endif.
    endform.                               " F_BUILD_FIELDCAT

*----------------------------------------------------------------------*
*   Form  f_build_hier_header
*----------------------------------------------------------------------*
*   Setando valores do Header da TREE
*----------------------------------------------------------------------*
    form f_build_hier_header_itens.
      clear wa_hier_header.
      move: 'Item'   to wa_hier_header-heading,
            text-h02 to wa_hier_header-tooltip,
            20       to wa_hier_header-width.
    endform.                               " build_hierarchy_header

*----------------------------------------------------------------------*
*   Form  f_create_hier
*----------------------------------------------------------------------*
*   Criando Hierarquia da TREE do XML
*----------------------------------------------------------------------*
    form f_create_hier_itens.
      data: vl_last_key   type lvc_nkey,
            vl_parent_key type lvc_nkey,
            vl_text       type string,
            vl_text2      type string,
            vl_node_exp   type lvc_t_nkey,
            vl_value_tc   type zhms_tb_docmn-value.


***   Construíndo tabela de saída
      perform f_build_outtab_itens.

**   Percorre tabela de itens para montar
      loop at t_itmdoc into wa_itmdoc.
**      Limpar variável de pai.
        clear vl_parent_key.


        if wa_itmdoc-dcprc is initial.
          if wa_itmdoc-typed = 'NFSE1'.
            clear: vl_value_tc.
            select single value
              into vl_value_tc
             from zhms_tb_docmn
              where chave = wa_itmdoc-chave
                and mneum = 'ITEMVALTOT'.
            if sy-subrc = 0.
              move: vl_value_tc to wa_itmdoc-dcprc.
            endif.
          elseif wa_itmdoc-typed = 'CTE'.
            clear: vl_value_tc.
            select single value
              into vl_value_tc
             from zhms_tb_docmn
              where chave = wa_itmdoc-chave
                and mneum = 'VTPREST'.
            if sy-subrc = 0.
              move: vl_value_tc to wa_itmdoc-dcprc.
            endif.
          endif.
        endif.
        clear wa_itensview.
        move-corresponding wa_itmdoc to wa_itensview.



**      Adiciona item do documento

**      Ajusta nome de ítem
**      Zeros a esquerda
        perform f_remove_zeros using wa_itmdoc-dcitm
                            changing vl_text.
**      Remove espaços
        condense vl_text no-gaps.


        clear wa_docmn.

        if vg_typed eq 'NFSE1'.
*          SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmn WHERE chave EQ vg_chave
*                                                   AND mneum EQ 'VALORSERVICO'.
*
*          IF sy-subrc IS INITIAL.
*            MOVE wa_docmn-value TO  wa_itensview-dcprc.
*          ENDIF.
        endif.


        if vg_typed eq 'CTE'.
          select single * from zhms_tb_docmn into wa_docmn where chave eq vg_chave
                                                   and mneum eq 'NATOP'.

          concatenate vl_text '.' wa_docmn-value into vl_text separated by space.

          clear: wa_docmn.



          select single * from zhms_tb_docmn into wa_docmn where chave eq vg_chave
                                                             and mneum eq 'VTPREST'.

          if sy-subrc is initial.
            move wa_docmn-value to  wa_itensview-dcprc.
          endif.

          wa_itensview-dcqtd = 1.
        else.
**      número ítem + descrição
          concatenate vl_text '.' wa_itmdoc-denom into vl_text separated by space.
        endif.


        perform f_add_no_itens    using wa_itensview ''
                                        vl_text
                               changing vl_parent_key.
**      Percorre atribuídos
        loop at t_itmatr into wa_itmatr where dcitm = wa_itmdoc-dcitm.
          clear vl_text.

**        Tratamento para Denominação: Tipo de Documento
          case wa_itmatr-tdsrf.
            when 1.
              move text-s01 to vl_text.
            when 2.
              move text-s02 to vl_text.
            when 3.
              move text-s03 to vl_text.
            when 4.
              move text-s04 to vl_text.
            when 5.
              move text-s05 to vl_text.
            when 6.
              move text-s06 to vl_text.
            when 7.
              move text-s07 to vl_text.
            when 8.
              move text-s08 to vl_text.
            when 9.
              move text-s09 to vl_text.
            when 10.
              move text-s10 to vl_text.
            when 11.
              move text-s11 to vl_text.
            when 12.
              move text-s12 to vl_text.
            when 13.
              move text-s13 to vl_text.
            when 14.
              move text-s14 to vl_text.
            when 15.
              move text-s15 to vl_text.
            when 16.
              move text-s16 to vl_text.
            when 17.
              move text-s17 to vl_text.
            when 18.
              move text-s18 to vl_text.
            when 19.
              move text-s19 to vl_text.
          endcase.

**      Zeros a esquerda
          move wa_itmatr-itsrf to vl_text2.

**      Remove espaços
          condense vl_text2 no-gaps.

**      Número Atribuição + Tipo Documento + Numero Documento
          concatenate  vl_text ':' wa_itmatr-nrsrf '(' vl_text2 ')' into vl_text separated by space.

**      Demais campos
          wa_itensview-atlot = wa_itmatr-atlot.

**        Adiciona filhos (documentos atribuídos) à arvore
          perform f_add_no_itens    using wa_itensview vl_parent_key
                                          vl_text
                                 changing vl_last_key.

**        Insere nó para expandir
          append vl_parent_key to vl_node_exp.

        endloop.

      endloop.

**      Expandir todos os nós
      call method ob_vis_itens->expand_nodes
        exporting
          it_node_key = vl_node_exp.

***   Atualizando valores no Objeto TREE criado
      call method ob_vis_itens->frontend_update.

    endform.                    " f_create_hier

*&---------------------------------------------------------------------*
*&      Form  f_build_outtab_itens
*&---------------------------------------------------------------------*
*       Tratamentos para exibição de ítens
*----------------------------------------------------------------------*
    form f_build_outtab_itens.
**    limpa variáveis
      refresh: t_itmdoc, t_itmatr, t_itensview.

**    Seleciona Itens
      select *
        from zhms_tb_itmdoc
        into table t_itmdoc
       where natdc eq vg_natdc     and
             typed eq vg_typed     and
             loctp eq wa_cabdoc-loctp    and
             chave eq wa_cabdoc-chave.

**    Seleciona Atribuições
      if not t_itmdoc[] is initial.
        select *
          from zhms_tb_itmatr
          into table t_itmatr
           for all entries in t_itmdoc
         where natdc eq t_itmdoc-natdc     and
               typed eq t_itmdoc-typed     and
               loctp eq t_itmdoc-loctp     and
               chave eq t_itmdoc-chave.
      endif.
**   Ordena Tabelas
      sort t_itmdoc by dcitm ascending.
      sort t_itmatr by dcitm ascending
                       seqnr ascending.

    endform.                    "f_build_outtab_itens

*&---------------------------------------------------------------------*
*&      Form  f_build_outtab_itens_atr
*&---------------------------------------------------------------------*
*       Tratamentos para exibição de ítens
*----------------------------------------------------------------------*
    form f_build_outtab_itens_atr.

**    Seleciona Itens
*      IF vg_typed NE 'NFE1'.
      select *
        from zhms_tb_itmdoc
        into table t_itmdoc_atr
       where natdc eq vg_natdc     and
             typed eq vg_typed     and
             loctp eq wa_cabdoc-loctp    and
             chave eq vg_chave.
*      ELSE.
*        SELECT *
*          FROM zhms_tb_itmdoc
*          INTO TABLE t_itmdoc_atr
*          UP TO 1 ROWS
*         WHERE natdc EQ vg_natdc     AND
*               typed EQ vg_typed     AND
*               loctp EQ wa_cabdoc-loctp    AND
*               chave EQ vg_chave.
*
*      ENDIF.


**    Seleciona Atribuições
      if not t_itmdoc_atr[] is initial.
        select *
          from zhms_tb_itmatr
          into table t_itmatr_atr
           for all entries in t_itmdoc_atr
         where natdc eq t_itmdoc_atr-natdc     and
               typed eq t_itmdoc_atr-typed     and
               loctp eq t_itmdoc_atr-loctp     and
               chave eq t_itmdoc_atr-chave.
      endif.

**   Ordena Tabelas
      sort t_itmdoc_atr by dcitm ascending.
      sort t_itmatr_atr by dcitm ascending
                           seqnr ascending.

    endform.                    "f_build_outtab_itens_atr


*----------------------------------------------------------------------*
*   Form  f_add_no_itens
*----------------------------------------------------------------------*
*   Adicionando nós na árvore
*----------------------------------------------------------------------*
    form f_add_no_itens  using  p_wa_itmview type zhms_es_itmview
                                p_relat_key
                                p_text
                      changing  p_node_key type lvc_nkey.

***   Variáveis locais para controle de exibição da Árvore
      data: lt_item_layout type lvc_t_layi,
            ls_item_layout type lvc_s_layi,
            l_node_text    type lvc_value.

***   Texto para exibição
      l_node_text =  p_text.

***   Layout da Árvore
      ls_item_layout-fieldname = ob_vis_itens->c_hierarchy_column_name.
      append ls_item_layout to lt_item_layout.

***   Chamada do método que insere linhas na árvore
      call method ob_vis_itens->add_node
        exporting
          i_relat_node_key = p_relat_key
          i_relationship   = cl_gui_column_tree=>relat_last_child
          is_outtab_line   = p_wa_itmview
          i_node_text      = l_node_text
          it_item_layout   = lt_item_layout
        importing
          e_new_node_key   = p_node_key.

    endform.                    " F_ADD_NO

*&---------------------------------------------------------------------*
*&      Form  f_remove_zeros
*&---------------------------------------------------------------------*
*       Remoção de zeros genérica
*----------------------------------------------------------------------*
    form f_remove_zeros using p_input
                     changing p_output.

      call function 'CONVERSION_EXIT_ALPHA_OUTPUT'
        exporting
          input  = p_input
        importing
          output = p_output.

    endform.                    "f_remove_zeros
*&---------------------------------------------------------------------*
*&      Form  F_BUILD_FIELDCAT_FLOW
*&---------------------------------------------------------------------*
*   Carregando catálogo de campo (FLOW)
*----------------------------------------------------------------------*
    form f_build_fieldcat_flow.
      data: vl_name type tv_itmname,
            vl_text type tv_heading.

      refresh t_flow_fldc.
      clear:  t_flow_fldc, wa_flow_fldc.

***   Obtendo catálogo de campos
      call function 'LVC_FIELDCATALOG_MERGE'
        exporting
          i_structure_name = 'ZHMS_ES_FLWDOC'
        changing
          ct_fieldcat      = t_flow_fldc.

      if sy-subrc eq 0.
        loop at t_flow_fldc into wa_flow_fldc.
          case wa_flow_fldc-fieldname.
            when 'SELEC'
              or 'MANDT'
              or 'NATDC'
              or 'TYPED'
              or 'LOCTP'
              or 'CHAVE'
              or 'FLWST'
              or 'DENOM'
              or 'ICON'.
              wa_flow_fldc-no_out = 'X'.
              wa_flow_fldc-key    = ''.

            when others.
              clear: vl_name, vl_text.

              vl_name = wa_flow_fldc-fieldname.
              vl_text = wa_flow_fldc-reptext.

              call method ob_flow->add_column
                exporting
                  name                         = vl_name
                  width                        = 21
                  header_text                  = vl_text
                exceptions
                  column_exists                = 1
                  illegal_column_name          = 2
                  too_many_columns             = 3
                  illegal_alignment            = 4
                  different_column_types       = 5
                  cntl_system_error            = 6
                  failed                       = 7
                  predecessor_column_not_found = 8.
              if sy-subrc <> 0.
                message a000.
              endif.

          endcase.

          modify t_flow_fldc from wa_flow_fldc.
        endloop.
      endif.
    endform.                    " F_BUILD_FIELDCAT_GRID
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_HIER_ITENS_FLOW
*&---------------------------------------------------------------------*
*       Montar lista de etapas
*----------------------------------------------------------------------*
    form f_create_hier_itens_flow using node_table type treev_ntab
                                        item_table type item_table_type.

**   variaveis locais
      data: node    type treev_node,
            item    type mtreeitm,
            vl_code type tv_nodekey,
            vl_text type string.

*      Adiciona primeiro nó a arvore
      node-node_key = c_nodekey-root.
      clear node-relatkey.
      clear node-relatship.
      clear node-n_image.
      clear node-exp_image.
      clear node-expander.
      node-hidden = ' '.
      node-disabled = ' '.
      node-isfolder = 'X'.
      append node to node_table.

**    Adicionar Itens nas colunas
      vl_text = text-f02.
      clear item.
      item-node_key = c_nodekey-root.
      item-item_name = 'Etapas'.
      item-class = cl_gui_column_tree=>item_class_text.
      item-text = vl_text.
      append item to item_table.

***   Construíndo tabela de saída
      perform f_select_values_flow.
      clear vl_code.
**   Percorre tabela de itens para montar
      t_flwdoc_ax2[] = t_flwdoc_ax[].
      loop at t_flwdoc_ax2 into wa_flwdoc_ax.
        vl_code = vl_code + 1.
**        Adiciona histórico à arvore
        concatenate wa_flwdoc_ax-flowd ' - ' wa_flwdoc_ax-denom into vl_text separated by space.

        node-node_key = vl_code.
        node-relatkey = c_nodekey-root.
        node-relatship = cl_gui_column_tree=>relat_last_child.
        node-isfolder = ' '.
        node-exp_image = wa_flwdoc_ax-icon.
        node-n_image   = wa_flwdoc_ax-icon.
        append node to node_table.

**      Etapa / Descrição
        clear item.
        item-node_key = vl_code.
        item-item_name = 'Etapas'.
        item-class = cl_gui_column_tree=>item_class_text.
        item-text = vl_text.
        item-ignoreimag = 'X'.
        append item to item_table.

**      Logs

        clear item.
        item-node_key = vl_code.
        item-item_name = 'FLOWD'.
        item-class = cl_gui_column_tree=>item_class_button.
        item-text = ''.
        item-t_image = '@DH@'.
*        item-ignoreimag = 'X'.
        append item to item_table.

**** Inicio inclusão David Rosin 06/02/2014
        perform f_habilita_botao.
        if vg_funct is not initial.
          clear item.
          item-node_key = vl_code.
          item-item_name = 'ESTOR'.
          item-class = cl_gui_column_tree=>item_class_button.
          item-text = ''.
          item-t_image = '@2W@'.
*        item-ignoreimag = 'X'.
          append item to item_table.
        endif.
**** Fim Inclusão David Rosin 06/02/2014

**      Data do log
        clear item.
        item-node_key = vl_code.
        item-item_name = 'DTREG'.
        item-class = cl_gui_column_tree=>item_class_text.
        item-ignoreimag = 'X'.

        concatenate wa_flwdoc_ax-dtreg+6(2) '.' wa_flwdoc_ax-dtreg+4(2) '.' wa_flwdoc_ax-dtreg(4) into item-text.
        append item to item_table.

**      Hora do Log
        clear item.
        item-node_key = vl_code.
        item-item_name = 'HRREG'.
        item-class = cl_gui_column_tree=>item_class_text.
        item-ignoreimag = 'X'.
        item-text = wa_flwdoc_ax-hrreg.
        concatenate wa_flwdoc_ax-hrreg(2) ':' wa_flwdoc_ax-hrreg+2(2) ':' wa_flwdoc_ax-hrreg+4 into item-text.
        append item to item_table.

**      Usuario
        clear item.
        item-node_key = vl_code.
        item-item_name = 'UNAME'.
        item-class = cl_gui_column_tree=>item_class_text.
        item-ignoreimag = 'X'.
        item-text = wa_flwdoc_ax-uname.
        append item to item_table.

**      Número do Documento
        clear item.
        item-node_key = vl_code.
        item-item_name = 'NRDCG'.
        item-class = cl_gui_column_tree=>item_class_link.
        item-ignoreimag = 'X'.
        item-text = wa_flwdoc_ax-nrdcg.
        append item to item_table.

**      Ano do Documento
        clear item.
        item-node_key = vl_code.
        item-item_name = 'YRDCG'.
        item-class = cl_gui_column_tree=>item_class_link.
        item-ignoreimag = 'X'.
        item-text = wa_flwdoc_ax-yrdcg.
        append item to item_table.
      endloop.

    endform.                    " F_CREATE_HIER_ITENS_FLOW
*&---------------------------------------------------------------------*
*&      Form  F_SELECT_VALUES_FLOW
*&---------------------------------------------------------------------*
*   Carrega os dados de fluxos para o documento
*----------------------------------------------------------------------*
    form f_select_values_flow .

**    Icone Local
      data: vl_icon    type icon_d value '@03@',
            lt_mapping type standard table of zhms_tb_mapdata,
            ls_mapping like line of lt_mapping.

**    Limpar as variáveis
      clear: wa_flwdoc_ax, wa_flwdoc, wa_scenflox.
      refresh: t_flwdoc_ax, t_flwdoc, t_scenflox.

**    Mneumonicos do documento
      clear wa_docmn.
      perform f_refresh_docmn.

**    Selecionar fluxo para este tipo de documento
      select *
        into table t_scenflo
        from zhms_tb_scen_flo
       where natdc eq wa_cabdoc-natdc
         and typed eq wa_cabdoc-typed
         and loctp eq wa_cabdoc-loctp
         and scena eq wa_cabdoc-scena.

**     Seleciona etapas do documento.
      if not t_scenflo[] is initial.

        select *
          into table t_flwdoc
          from zhms_tb_flwdoc
          for all entries in t_scenflo
        where natdc eq wa_cabdoc-natdc
          and typed eq wa_cabdoc-typed
          and loctp eq wa_cabdoc-loctp
          and chave eq wa_cabdoc-chave
          and flowd eq t_scenflo-flowd.

        select *
          into table t_scenflox
          from zhms_tx_scen_flo
           for all entries in t_scenflo
          where natdc	eq t_scenflo-natdc
            and typed	eq t_scenflo-typed
            and loctp eq t_scenflo-loctp
            and scena	eq t_scenflo-scena
            and flowd eq t_scenflo-flowd
            and spras	eq sy-langu.

      endif.

** Percorre dados encontrados movendo para estrutura de exibição
      loop at t_scenflo into wa_scenflo.

        read table t_scenflox into wa_scenflox with key natdc = wa_scenflo-natdc
                                                        typed = wa_scenflo-typed
                                                        loctp = wa_scenflo-loctp
                                                        scena = wa_scenflo-scena
                                                        flowd = wa_scenflo-flowd.

        clear wa_flwdoc_ax.

**      Move etapa do fluxo
        move-corresponding wa_scenflox to wa_flwdoc_ax.

**      Recupera status da etapa
        clear wa_flwdoc.

**      Move dados do registro caso encontre
        read table t_flwdoc into wa_flwdoc with key flowd = wa_scenflox-flowd.
        if sy-subrc is initial.
          move-corresponding wa_flwdoc to wa_flwdoc_ax.
        endif.

**      Tratativa para Icones
        case wa_flwdoc-flwst.
          when 'M'. "Concluído Manualmente
            wa_flwdoc_ax-icon = '@3J@'.
          when 'A'. "Concluído Automaticamente
            wa_flwdoc_ax-icon = '@01@'.

          when 'W'. "Aguardando
            wa_flwdoc_ax-icon = vl_icon.
            vl_icon = '@5F@'.
          when 'E'. "Erro
            wa_flwdoc_ax-icon = '@1D@'.
            vl_icon = '@5F@'.
          when 'C'. "Cancelada
            wa_flwdoc_ax-icon = '@02@'.
            vl_icon = '@5F@'.
          when others. "Outros
            wa_flwdoc_ax-icon = vl_icon.
            vl_icon = '@5F@'.
        endcase.

** Valores processados
** Documento
        clear wa_docmn.
        read table t_docmn_rep into wa_docmn with key mneum = wa_scenflo-mndoc.
        if sy-subrc is initial.
          wa_flwdoc_ax-nrdcg = wa_docmn-value.
        endif.

*** Inicio Alteração David Rosin 10/02/2014 altera passagem de ano para numero do estorno
** Ano

*** Busca Mneumonico de estorno
        if wa_scenflo-funct_estorno is not initial.

          select * from zhms_tb_mapdata into table lt_mapping where codmp eq wa_scenflo-codmp_estorno.

          read table lt_mapping into ls_mapping index 1.

          if sy-subrc is initial.
            clear wa_docmn.
            read table t_docmn_rep into wa_docmn with key mneum = wa_scenflo-mndoc.

            if sy-subrc is initial.
*              READ TABLE t_docmn_rep INTO wa_docmn WITH KEY mneum = wa_scenflo-mndoc.
*              IF sy-subrc IS INITIAL.
*                wa_flwdoc_ax-yrdcg = wa_docmn-value.
*              ENDIF.
              clear wa_flwdoc_ax-yrdcg.
            else.
              read table t_docmn_rep into wa_docmn with key mneum = ls_mapping-mneum.
              if sy-subrc is initial.
                wa_flwdoc_ax-yrdcg = wa_docmn-value.
              endif.
            endif.


          endif.
        endif.
*** Fim Alteração David Rosin 10/02/2014 altera passagem de ano para numero do estorno

**      Insere na tabela
        append wa_flwdoc_ax to t_flwdoc_ax.
      endloop.
    endform.                    " F_SELECT_VALUES_FLOW

*----------------------------------------------------------------------*
*   Form  F_REG_EVENTS_FLOW
*----------------------------------------------------------------------*
*   Registrando Eventos da tree Atribuição
*----------------------------------------------------------------------*
    form f_reg_events_flow.

*     Variáveis locais
      data: wl_event      type cntl_simple_event,
            tl_events     type cntl_simple_events,
            g_application type ref to lcl_application.

      " node double click
      wl_event-eventid = cl_gui_column_tree=>eventid_node_double_click.
      wl_event-appl_event = 'X'. " process PAI if event occurs
      append wl_event to tl_events.

      " item double click
      wl_event-eventid = cl_gui_column_tree=>eventid_item_double_click.
      wl_event-appl_event = 'X'.
      append wl_event to tl_events.

      " link click
      wl_event-eventid = cl_gui_column_tree=>eventid_link_click.
      wl_event-appl_event = 'X'.
      append wl_event to tl_events.

      " button click
      wl_event-eventid = cl_gui_column_tree=>eventid_button_click.
      wl_event-appl_event = 'X'.
      append wl_event to tl_events.

      call method ob_flow->set_registered_events
        exporting
          events                    = tl_events
        exceptions
          cntl_error                = 1
          cntl_system_error         = 2
          illegal_event_combination = 3.
      if sy-subrc <> 0.
        message a000.
      endif.

* assign event handlers in the application class to each desired event
      create object g_application.

      set handler g_application->handle_link_click for ob_flow.
      set handler g_application->handle_button_click for ob_flow.

    endform.                    " F_REG_EVENTS_ATR
*&---------------------------------------------------------------------*
*&      Form  F_REFRESH_DOCMN
*&---------------------------------------------------------------------*
*       Atualiza dados de mneumonico para o documento
*----------------------------------------------------------------------*\\
    form f_refresh_docmn .
**    Limpar tabela interna
      refresh t_docmn_rep.

**    Selecionar dados
      select *
        into table t_docmn_rep
        from zhms_tb_docmn
       where chave eq vg_chave.

      if sy-subrc is not initial.
**    Selecionar dados
        select *
          into table t_docmn_rep
          from zhms_tb_docmn_hs
         where chave eq vg_chave.
      endif.

    endform.                    " F_REFRESH_DOCMN

*&---------------------------------------------------------------------*
*&      Form  F_GET_SELECTED_FLOW
*&---------------------------------------------------------------------*
*       Identificar o item selecionado
*----------------------------------------------------------------------*
    form f_get_selected_flow  changing p_index.
**    Variaveis locas
      data: node type tv_nodekey,
            item type tv_itmname.

**    Identificar selecionado
      call method ob_flow->get_selected_item
        importing
          node_key          = node
          item_name         = item
        exceptions
          failed            = 1
          cntl_system_error = 2
          no_item_selection = 3
          others            = 4.

**    Tratamento de erros
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
                   with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.

**    Retornar Selecionado
      condense node no-gaps.
      move node to p_index.

    endform.                    " F_GET_SELECTED_FLOW
*&---------------------------------------------------------------------*
*&      Form  F_ESTORNO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
    form f_estorno using vl_index.

*** Declaração de Tabelas
      data: lt_mneum   type standard table of zhms_tb_docmn,
            lt_mneumx  type standard table of zhms_tb_docmn,
            lt_mapping type standard table of zhms_tb_mapdata,
            lt_return  type standard table of bapiret2.

*** Declaração de WorkAreas
      data: ls_mapping  like line of lt_mapping,
            ls_return   like line of lt_return,
            ls_mneum    like line of lt_mneum,
            ls_headret  type bapi2017_gm_head_ret,
            ls_scen_flo type zhms_tb_scen_flo.

*** Declaração de Variaveis
      data: lv_docnum type mblnr,
            lv_year   type mjahr,
            lv_index  type sy-tabix,
            lv_lblni  type lblni,
            lv_answer type c,
            lv_chave  type zhms_de_chave,
            lv_reason type stgrd,
            vl_seqnr  type zhms_de_seqnr,
            lv_mneum  type zhms_de_mneum.

*** Pop-up de confirmação do estorno
      call function 'POPUP_TO_CONFIRM'
        exporting
          titlebar              = text-q01
          text_question         = text-q10
          text_button_1         = text-q03
          icon_button_1         = 'ICON_CHECKED'
          text_button_2         = text-q04
          icon_button_2         = 'ICON_INCOMPLETE'
          default_button        = '2'
          display_cancel_button = ' '
        importing
          answer                = lv_answer
        exceptions
          text_not_found        = 1
          others                = 2.

      check lv_answer eq 1.

      if sy-subrc is initial.

        read table t_flwdoc_ax into wa_flwdoc_ax index vl_index.

        clear: vg_codmp, vg_funct, lv_chave.
        select single * from zhms_tb_scen_flo into ls_scen_flo where
    natdc eq wa_flwdoc_ax-natdc

    and typed eq wa_flwdoc_ax-typed

    and flowd eq wa_flwdoc_ax-flowd

    and scena eq wa_cabdoc-scena.

*and SCENA eq wa_cabdoc-SCENA.

        if sy-subrc is initial.

          read table t_chave into lv_chave index 1.

          check not lv_chave is initial.

*** Busca todos mneumonicos por chave
          select * from zhms_tb_docmn into table lt_mneum where chave eq
    lv_chave.

          if not sy-subrc is initial.
            select * from zhms_tb_docmn_hs into table lt_mneum where
    chave eq lv_chave.
          endif.

*** Busca mapeamento para esse cenario
          select * from zhms_tb_mapdata into table lt_mapping where
    codmp eq ls_scen_flo-codmp_estorno.

          if not lt_mapping[] is initial.
            clear lv_index.

*** Busca numero da miro ou migo
            sort lt_mneum descending by seqnr.
            read table lt_mneum into ls_mneum with key mneum = ls_scen_flo-mndoc.

            if sy-subrc is initial.
*          break homine.
              case ls_scen_flo-funct_estorno.

* RCP - 27/09/2018 - Início
                when 'ZHMS_ESTORNO_ML81N'.

                  " Verifica Autorização usuario
                  call function 'ZHMS_FM_SECURITY'
                    exporting
                      value         = 'ESTORNO_MIGO'  "ML81N
                    exceptions
                      authorization = 1
                      others        = 2.

                  if sy-subrc <> 0.
                    message e000(zhms_security). "
                  endif.

                  clear lv_lblni.
                  move: ls_mneum-value to lv_lblni.

                  " Excluir a Folha de Serviço
                  call function 'ZHMS_ESTORNO_ML81N'
                    exporting
                      lblni  = lv_lblni
                    tables
                      return = lt_return.

                  " Verifica caso ERRO
                  read table lt_return into ls_return
                                       with key type = 'E'.

                  if sy-subrc is initial.
                    " Grava log de erro
                    perform f_grava_log tables lt_return using:
                                               ls_return
                                               wa_flwdoc_ax-natdc
                                               wa_flwdoc_ax-typed
                                               ls_scen_flo-loctp
                                               lv_chave.

                    message ls_return-message type 'I'.
                    exit.

                  else.

                    " Caso sucesso grava operação
                    call function 'BAPI_TRANSACTION_COMMIT'
                      exporting
                        wait = 'X'.

                    " Modifica Tabela ZHMS_TB_DOCMN
                    delete from zhms_tb_docmn where chave eq lv_chave
                                                and mneum eq ls_scen_flo-mndoc.

                    " Commit banco de dados
                    if sy-subrc is initial.
                      commit work.
                    else.
                      rollback work.
                    endif.

                    " Insere Numero do documento de estorno
                    refresh lt_mneumx[].
                    clear ls_mneum.

                    loop at lt_mapping into ls_mapping.
                      move sy-tabix to lv_index.
                      move: lv_chave         to ls_mneum-chave,
                            ls_mapping-mneum to ls_mneum-mneum.

                      case lv_index.
                        when 1.
                          move lv_lblni to ls_mneum-value.
                      endcase.

                      " Busca ultimo numero de chave
                      select max( seqnr )
                        into vl_seqnr
                        from zhms_tb_docmn
                       where chave eq lv_chave.

                      select single mneum
                        from zhms_tb_docmn
                        into lv_mneum
                        where chave eq lv_chave
                          and mneum eq ls_mapping-mneum .

                      if not sy-subrc is initial.
                        add 1 to vl_seqnr.
                        move vl_seqnr to ls_mneum-seqnr.

                        condense ls_mneum-seqnr no-gaps.
                        call function 'CONVERSION_EXIT_ALPHA_OUTPUT'
                          exporting
                            input  = ls_mneum-seqnr
                          importing
                            output = ls_mneum-seqnr.

                        insert zhms_tb_docmn  from ls_mneum.

                      endif.

                      " Commit Banco de dados
                      if sy-subrc is initial.
                        commit work.
                      else.
                        rollback work.
                      endif.

                    endloop.

                    " Muda Status da etapa
                    move: wa_flwdoc_ax-natdc to wa_flwdoc-natdc,
                          wa_flwdoc_ax-typed to wa_flwdoc-typed,
                          lv_chave           to wa_flwdoc-chave,
                          wa_flwdoc_ax-flowd to wa_flwdoc-flowd,
                          sy-datum           to wa_flwdoc-dtreg,
                          sy-uzeit           to wa_flwdoc-hrreg,
                          sy-uname           to wa_flwdoc-uname,
                          'W'                to wa_flwdoc-flwst.
                    modify zhms_tb_flwdoc from wa_flwdoc.
                    clear wa_flwdoc.

                    if sy-subrc is initial.
                      commit work.
                    else.
                      rollback work.
                    endif.

                    " Altera status do documento
                    select single *
                      from zhms_tb_docst
                      into wa_docstx
                      where natdc eq wa_flwdoc_ax-natdc
                        and typed eq wa_flwdoc_ax-typed
                        and chave eq lv_chave.

                    if sy-subrc is initial.
                      update zhms_tb_docst
                      set sthms = '2'
                      where natdc eq wa_flwdoc_ax-natdc
                        and typed eq wa_flwdoc_ax-typed
                        and chave eq lv_chave.

                      if sy-subrc is initial.
                        commit work.
                      else.
                        rollback work.
                      endif.
                    endif.

*** Grava Log de sucesso para o estorno
                    perform f_change_return tables lt_return using  lv_docnum.
                    perform f_grava_log     tables lt_return using: ls_return
                                                                    wa_flwdoc_ax-natdc
                                                                    wa_flwdoc_ax-typed
                                                                    ls_scen_flo-loctp
                                                                    lv_chave.

                  endif.
* RCP - 27/09/2018 - Fim


                when 'BAPI_GOODSMVT_CANCEL'.

*** Verifica Autorização usuario
                  call function 'ZHMS_FM_SECURITY'
                    exporting
                      value         = 'ESTORNO_MIGO'
                    exceptions
                      authorization = 1
                      others        = 2.

                  if sy-subrc <> 0.
                    message e000(zhms_security). "
                  endif.

                  move: ls_mneum-value to lv_docnum,
                        sy-datum(4) to lv_year.

*** Executa extorno da MIGO
                  call function 'BAPI_GOODSMVT_CANCEL'
                    exporting
                      materialdocument = lv_docnum
                      matdocumentyear  = lv_year
                    importing
                      goodsmvt_headret = ls_headret
                    tables
                      return           = lt_return.

*** Verifica caso ERRO
                  read table lt_return into ls_return with key type =
    'E'.

                  if sy-subrc is initial.
*** Grava log de erro
                    perform f_grava_log tables lt_return using:
                                               ls_return
                                               wa_flwdoc_ax-natdc
                                               wa_flwdoc_ax-typed
                                               ls_scen_flo-loctp
                                               lv_chave.

                    message ls_return-message type 'I'.
                    exit.

                  else.

*** Caso sucesso grava operação
                    call function 'BAPI_TRANSACTION_COMMIT'
                      exporting
                        wait = 'X'.

*** Modifica Tabela ZHMS_TB_DOCMN
                    if not ls_headret is initial.

                      delete from zhms_tb_docmn where chave eq lv_chave
                                             and mneum eq ls_scen_flo-mndoc.

*** Commit banco de dados
                      if sy-subrc is initial.
                        commit work.
                      else.
                        rollback work.
                      endif.

*** Insere Numero do documento de estorno
                      refresh lt_mneumx[].
                      clear ls_mneum.

                      loop at lt_mapping into ls_mapping.
                        move sy-tabix to lv_index.
                        move: lv_chave         to ls_mneum-chave,
                              ls_mapping-mneum to ls_mneum-mneum.

                        case lv_index.
                          when 1.
                            move ls_headret-mat_doc to ls_mneum-value.
                          when 2.
                            move ls_headret-doc_year to ls_mneum-value.
                        endcase.

*** Busca ultimo numero de chave
                        select max( seqnr )
                          into vl_seqnr
                          from zhms_tb_docmn
                         where chave eq lv_chave.

                        select single mneum
                                  from zhms_tb_docmn
                                  into lv_mneum
                                  where chave eq lv_chave
                                  and mneum eq ls_mapping-mneum .

                        if not sy-subrc is initial.
                          add 1 to vl_seqnr.
                          move vl_seqnr to ls_mneum-seqnr.

                          condense ls_mneum-seqnr no-gaps.
                          call function 'CONVERSION_EXIT_ALPHA_OUTPUT'
                            exporting
                              input  = ls_mneum-seqnr
                            importing
                              output = ls_mneum-seqnr.
*
*                      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*                           EXPORTING
*                                input  = ls_mneum-seqnr
*                           IMPORTING
*                                output = ls_mneum-seqnr.

                          insert zhms_tb_docmn  from ls_mneum.

                        endif.

*** Commit Banco de dados
                        if sy-subrc is initial.
                          commit work.
                        else.
                          rollback work.
                        endif.


                      endloop.

**** Muda Status da etapa
                      move: wa_flwdoc_ax-natdc to wa_flwdoc-natdc,
                            wa_flwdoc_ax-typed to wa_flwdoc-typed,
                            lv_chave           to wa_flwdoc-chave,
                            wa_flwdoc_ax-flowd to wa_flwdoc-flowd,
                            sy-datum           to wa_flwdoc-dtreg,
                            sy-uzeit           to wa_flwdoc-hrreg,
                            sy-uname           to wa_flwdoc-uname,
                            'W' to wa_flwdoc-flwst.
                      modify zhms_tb_flwdoc from wa_flwdoc.
                      clear wa_flwdoc.

                      if sy-subrc is initial.
                        commit work.
                      else.
                        rollback work.
                      endif.

*** Altera status do documento
                      select single * from zhms_tb_docst into wa_docstx
    where natdc eq wa_flwdoc_ax-natdc

    and typed eq wa_flwdoc_ax-typed

    and chave eq lv_chave.

                      if sy-subrc is initial.
                        update zhms_tb_docst
                        set sthms = '2'
                        where natdc eq wa_flwdoc_ax-natdc
                           and typed eq wa_flwdoc_ax-typed
                           and chave eq lv_chave.

                        if sy-subrc is initial.
                          commit work.
                        else.
                          rollback work.
                        endif.
                      endif.

*** Grava Log de sucesso para o estorno
                      perform f_change_return tables lt_return using
    lv_docnum.
                      perform f_grava_log tables lt_return using:
    ls_return

    wa_flwdoc_ax-natdc

    wa_flwdoc_ax-typed

    ls_scen_flo-loctp

    lv_chave.

                    endif.
                  endif.

                when 'BAPI_INCOMINGINVOICE_CANCEL'.
*** Verifica Autorização usuario
                  call function 'ZHMS_FM_SECURITY'
                    exporting
                      value         = 'ESTORNO_MIRO'
                    exceptions
                      authorization = 1
                      others        = 2.

                  if sy-subrc <> 0.
                    message e000(zhms_security).
                  endif.

                  move: ls_mneum-value to lv_docnum,
                        sy-datum(4)    to lv_year.

                  read table lt_mapping into ls_mapping with key tbfld =
    'REASONREVERSAL'.

                  if sy-subrc is initial.
                    move ls_mapping-vlfix to lv_reason.
                  endif.
*} Homine - Ini. Modif. - RBO(31/05/19 - Refresh Tela Ticket.24.222
*                  CLEAR ls_headret.
                  clear: ls_headret, t_mess, ls_return-message, ls_mess.
                  refresh: t_mess.

*                  CALL FUNCTION 'BAPI_INCOMINGINVOICE_CANCEL'
*                    EXPORTING
*                      invoicedocnumber          = lv_docnum
*                      fiscalyear                = lv_year
*                      reasonreversal            = lv_reason
*                    IMPORTING
*                      invoicedocnumber_reversal = ls_headret-mat_doc
*                      fiscalyear_reversal       = ls_headret-doc_year
*                    TABLES
*                      return                    = lt_return.
                  refresh t_bdc1[].
                  perform z_gera_batch using:
                        'X' 'SAPLMR1M' '0300',
                        ' ' 'BDC_OKCODE' '=CANC',
                        ' ' 'BDC_CURSOR' 'UF05A-STGRD',
                        ' ' 'RBKPV-BELNR' lv_docnum,
                        ' ' 'RBKPV-GJAHR' lv_year,
                        ' ' 'UF05A-STGRD' lv_reason.

                  call transaction 'MR8M'
                  using t_bdc1
                  mode v_mode_batch
                  messages  into t_mess.

**** Verifica caso ERRO
*                  READ TABLE lt_return INTO ls_return WITH KEY type = 'E'.
*** Verifica caso ERRO
                  read table t_mess into ls_mess with key  msgtyp = 'E'.
                  if sy-subrc is initial.
*** Grava Log de Erro
                    data: v_text type string.

                    perform f_grava_batch tables t_mess using:
                                                 ls_mess
                                                 wa_flwdoc_ax-natdc
                                                 wa_flwdoc_ax-typed
                                                 ls_scen_flo-loctp
                                                 lv_chave.

                    call function 'MESSAGE_PREPARE'
                      exporting
                        language               = sy-langu
                        msg_id                 = ls_mess-msgid
                        msg_no                 = ls_mess-msgnr
                        msg_var1               = ls_mess-msgv1(50)
                        msg_var2               = ls_mess-msgv2(50)
                        msg_var3               = ls_mess-msgv3(50)
                        msg_var4               = ls_mess-msgv4(50)
                      importing
                        msg_text               = ls_return-message
                      exceptions
                        function_not_completed = 1
                        message_not_found      = 2
                        others                 = 3.

                    message ls_return-message type 'I'.
                    exit.

                  else.

*** Caso sucesso grava operação
*                    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*                      EXPORTING
*                        wait = 'X'.

*** Modifica Tabela ZHMS_TB_DOCMN
*                    IF NOT ls_headret IS INITIAL.
                    read table t_mess into ls_mess index 1.
                    delete from zhms_tb_docmn where chave eq lv_chave
                                        and mneum eq ls_scen_flo-mndoc.

*** Commit banco de dados
                    if sy-subrc is initial.
                      commit work.
                    else.
                      rollback work.
                    endif.

*** Insere Numero do documento de estorno
                    refresh lt_mneumx[].
                    clear ls_mneum.

                    loop at lt_mapping into ls_mapping.
                      move sy-tabix to lv_index.
                      move: lv_chave         to ls_mneum-chave,
                            ls_mapping-mneum to ls_mneum-mneum.

                      case lv_index.
                        when 1.
*** Armazena numero do estorno
                          move ls_mess-msgv1 to ls_mneum-value.
                        when 2.
*** Armazena ano do estorno
                          move sy-datum(4) to ls_mneum-value.
                        when 3.
*** Armazena ano do estorno
                          move ls_mess-msgv1 to ls_mneum-value.
                        when others.
                      endcase.

*** Busca ultimo numero de chave
                      select max( seqnr )
                        into vl_seqnr
                        from zhms_tb_docmn
                       where chave eq lv_chave.

                      select single mneum
                               from zhms_tb_docmn
                               into lv_mneum
                               where chave eq lv_chave
                                 and mneum eq ls_mapping-mneum .

                      if not sy-subrc is initial.
                        add 1 to vl_seqnr.
                        move vl_seqnr to ls_mneum-seqnr.

                        condense ls_mneum-seqnr no-gaps.
                        call function 'CONVERSION_EXIT_ALPHA_OUTPUT'
                          exporting
                            input  = ls_mneum-seqnr
                          importing
                            output = ls_mneum-seqnr.

*                          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*                            EXPORTING
*                              input  = ls_mneum-seqnr
*                            IMPORTING
*                              output = ls_mneum-seqnr.

                        insert zhms_tb_docmn from ls_mneum.
                      endif.

*** Commit Banco de dados
                      if sy-subrc is initial.
                        commit work.
                      else.
                        rollback work.
                      endif.

                    endloop.


*** Muda Status da etapa
                    move: wa_flwdoc_ax-natdc to wa_flwdoc-natdc,
                          wa_flwdoc_ax-typed to wa_flwdoc-typed,
                          lv_chave           to wa_flwdoc-chave,
                          wa_flwdoc_ax-flowd to wa_flwdoc-flowd,
                          sy-datum           to wa_flwdoc-dtreg,
                          sy-uzeit           to wa_flwdoc-hrreg,
                          sy-uname           to wa_flwdoc-uname,
                         'W' to wa_flwdoc-flwst.
                    modify zhms_tb_flwdoc from wa_flwdoc.
                    clear wa_flwdoc.

                    if sy-subrc is initial.
                      commit work.
                    else.
                      rollback work.
                    endif.
*** Volta etapa 50
                    clear vg_line.
                    describe table t_scenflo lines vg_line.
                    read table t_scenflo into wa_scenflo index vg_line.
                    clear wa_flwdoc.
                    move: wa_flwdoc_ax-natdc to wa_flwdoc-natdc,
                          wa_flwdoc_ax-typed to wa_flwdoc-typed,
                          lv_chave           to wa_flwdoc-chave,
                          wa_scenflo-flowd   to wa_flwdoc-flowd,
                          sy-datum           to wa_flwdoc-dtreg,
                          sy-uzeit           to wa_flwdoc-hrreg,
                          sy-uname           to wa_flwdoc-uname,
                          'W' to wa_flwdoc-flwst.
                    modify zhms_tb_flwdoc from wa_flwdoc.
                    clear wa_flwdoc.

                    if sy-subrc is initial.
                      commit work.
                    else.
                      rollback work.
                    endif.

*** Altera status do documento
                    select single * from zhms_tb_docst
                      into wa_docstx
                     where natdc eq wa_flwdoc_ax-natdc
                       and typed eq wa_flwdoc_ax-typed
                       and chave eq lv_chave.

                    if sy-subrc is initial.
                      update zhms_tb_docst
                      set sthms = '2'
                      where natdc eq wa_flwdoc_ax-natdc
                         and typed eq wa_flwdoc_ax-typed
                         and chave eq lv_chave.

                      if sy-subrc is initial.
                        commit work.
                      else.
                        rollback work.
                      endif.
                    endif.

*** Grava Log de sucesso para o estorno
                    perform f_change_return tables lt_return
                                             using lv_docnum.
                    perform f_grava_log tables lt_return
                                         using:ls_return
                                               wa_flwdoc_ax-natdc
                                               wa_flwdoc_ax-typed
                                               ls_scen_flo-loctp
                                               lv_chave.

*                    ENDIF.
                  endif.
*{ Homine - Fim. Modif. - RBO(31/05/19 - Refresh Tela Ticket.24.222
*                  IF sy-subrc IS INITIAL.
**** Grava Log de Erro
*                    PERFORM f_grava_log TABLES lt_return USING:
*                                               ls_return
*                                               wa_flwdoc_ax-natdc
*                                               wa_flwdoc_ax-typed
*                                               ls_scen_flo-loctp
*                                               lv_chave.
*
*                    MESSAGE ls_return-message TYPE 'I'.
*                    EXIT.
*
*                  ELSE.
*
**** Caso sucesso grava operação
*                    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*                      EXPORTING
*                        wait = 'X'.
*
**** Modifica Tabela ZHMS_TB_DOCMN
*                    IF NOT ls_headret IS INITIAL.
*
*                      DELETE FROM zhms_tb_docmn WHERE chave EQ lv_chave
*                                          AND mneum EQ ls_scen_flo-mndoc.
*
**** Commit banco de dados
*                      IF sy-subrc IS INITIAL.
*                        COMMIT WORK.
*                      ELSE.
*                        ROLLBACK WORK.
*                      ENDIF.
*
**** Insere Numero do documento de estorno
*                      REFRESH lt_mneumx[].
*                      CLEAR ls_mneum.
*
*                      LOOP AT lt_mapping INTO ls_mapping.
*                        MOVE sy-tabix TO lv_index.
*
*                        MOVE: lv_chave         TO ls_mneum-chave,
*                              ls_mapping-mneum TO ls_mneum-mneum.
*
*                        CASE lv_index.
*                          WHEN 1.
**** Armazena numero do estorno
*                            MOVE ls_headret-mat_doc TO ls_mneum-value.
*                          WHEN 2.
**** Armazena ano do estorno
*                            MOVE ls_headret-doc_year TO ls_mneum-value.
*                          WHEN 3.
**** Armazena ano do estorno
*                            MOVE ls_headret-mat_doc TO ls_mneum-value.
*
*                          WHEN OTHERS.
*                        ENDCASE.
*
**** Busca ultimo numero de chave
*                        SELECT MAX( seqnr )
*                          INTO vl_seqnr
*                          FROM zhms_tb_docmn
*                         WHERE chave EQ lv_chave.
*
*                        SELECT SINGLE mneum
*                                  FROM zhms_tb_docmn
*                                  INTO lv_mneum
*                                  WHERE chave EQ lv_chave
*                                  AND mneum EQ ls_mapping-mneum .
*
*                        IF NOT sy-subrc IS INITIAL.
*                          ADD 1 TO vl_seqnr.
*                          MOVE vl_seqnr TO ls_mneum-seqnr.
*
*                          CONDENSE ls_mneum-seqnr NO-GAPS.
*                          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*                            EXPORTING
*                              input  = ls_mneum-seqnr
*                            IMPORTING
*                              output = ls_mneum-seqnr.
*
**                          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
**                            EXPORTING
**                              input  = ls_mneum-seqnr
**                            IMPORTING
**                              output = ls_mneum-seqnr.
*
*
*                          INSERT zhms_tb_docmn FROM ls_mneum.
*                        ENDIF.
*
**** Commit Banco de dados
*                        IF sy-subrc IS INITIAL.
*                          COMMIT WORK.
*                        ELSE.
*                          ROLLBACK WORK.
*                        ENDIF.
*
*                      ENDLOOP.
*
*
**** Muda Status da etapa
*                      MOVE: wa_flwdoc_ax-natdc TO wa_flwdoc-natdc,
*                            wa_flwdoc_ax-typed TO wa_flwdoc-typed,
*                            lv_chave           TO wa_flwdoc-chave,
*                            wa_flwdoc_ax-flowd TO wa_flwdoc-flowd,
*                            sy-datum           TO wa_flwdoc-dtreg,
*                            sy-uzeit           TO wa_flwdoc-hrreg,
*                            sy-uname           TO wa_flwdoc-uname,
*                           'W' TO wa_flwdoc-flwst.
*                      MODIFY zhms_tb_flwdoc FROM wa_flwdoc.
*                      CLEAR wa_flwdoc.
*
*                      IF sy-subrc IS INITIAL.
*                        COMMIT WORK.
*                      ELSE.
*                        ROLLBACK WORK.
*                      ENDIF.
*
*
**** Volta etapa 50
*                      CLEAR vg_line.
*                      DESCRIBE TABLE t_scenflo LINES vg_line.
*                      READ TABLE t_scenflo INTO wa_scenflo INDEX vg_line.
*                      CLEAR wa_flwdoc.
*                      MOVE: wa_flwdoc_ax-natdc TO wa_flwdoc-natdc,
*                            wa_flwdoc_ax-typed TO wa_flwdoc-typed,
*                            lv_chave           TO wa_flwdoc-chave,
*                            wa_scenflo-flowd   TO wa_flwdoc-flowd,
*                            sy-datum           TO wa_flwdoc-dtreg,
*                            sy-uzeit           TO wa_flwdoc-hrreg,
*                            sy-uname           TO wa_flwdoc-uname,
*                            'W' TO wa_flwdoc-flwst.
*                      MODIFY zhms_tb_flwdoc FROM wa_flwdoc.
*                      CLEAR wa_flwdoc.
*
*                      IF sy-subrc IS INITIAL.
*                        COMMIT WORK.
*                      ELSE.
*                        ROLLBACK WORK.
*                      ENDIF.
*
**** Altera status do documento
*                      SELECT SINGLE * FROM zhms_tb_docst INTO wa_docstx
*    WHERE natdc EQ wa_flwdoc_ax-natdc
*
*    AND typed EQ wa_flwdoc_ax-typed
*
*    AND chave EQ lv_chave.
*
*                      IF sy-subrc IS INITIAL.
*                        UPDATE zhms_tb_docst
*                        SET sthms = '2'
*                        WHERE natdc EQ wa_flwdoc_ax-natdc
*                           AND typed EQ wa_flwdoc_ax-typed
*                           AND chave EQ lv_chave.
*
*                        IF sy-subrc IS INITIAL.
*                          COMMIT WORK.
*                        ELSE.
*                          ROLLBACK WORK.
*                        ENDIF.
*                      ENDIF.
*
**** Grava Log de sucesso para o estorno
*                      PERFORM f_change_return TABLES lt_return USING
*    lv_docnum.
*                      PERFORM f_grava_log TABLES lt_return USING:
*    ls_return
*
*    wa_flwdoc_ax-natdc
*
*    wa_flwdoc_ax-typed
*
*    ls_scen_flo-loctp
*
*    lv_chave.
*
*                    ENDIF.
*                  ENDIF.

                when 'ZHMS_ESTORNO_J1B1N'.

*              break homine.
                  call function 'ZHMS_ESTORNO_J1B1N'
                    exporting
                      chave     = lv_chave
                    tables
                      lt_return = lt_return.


*** Verifica caso ERRO
                  read table lt_return into ls_return with key type = 'E'.

                  if  sy-subrc is initial.

*** Grava Log de Erro
                    perform f_grava_log tables lt_return using:
                                               ls_return
                                               wa_flwdoc_ax-natdc
                                               wa_flwdoc_ax-typed
                                               ls_scen_flo-loctp
                                               lv_chave.


                  else.

*** verifica documento criado
                    read table lt_return into ls_return with key type = 'S'
                                                                id   = '8B'
                                                           number   = '191'.

*** Insere Numero do documento de estorno
*                REFRESH lt_mneumx[].
                    clear ls_mneum.

                    delete from zhms_tb_docmn where chave eq lv_chave
                                                and mneum eq 'MATDOC'.

                    if sy-subrc is initial.
                      commit work.
                    endif.

                    move: lv_chave         to ls_mneum-chave,
                          'MATDOCEST'      to ls_mneum-mneum.

*** Armazena ano do estorno
                    move ls_return-message_v2 to ls_mneum-value.


*** Busca ultimo numero de chave
                    select max( seqnr )
                      into vl_seqnr
                      from zhms_tb_docmn
                     where chave eq lv_chave.

                    if sy-subrc is initial.
                      add 1 to vl_seqnr.
                      move vl_seqnr to ls_mneum-seqnr.

                      condense ls_mneum-seqnr no-gaps.
                      call function 'CONVERSION_EXIT_ALPHA_INPUT'
                        exporting
                          input  = ls_mneum-seqnr
                        importing
                          output = ls_mneum-seqnr.


                      insert zhms_tb_docmn from ls_mneum.

*** Commit Banco de dados
                      if sy-subrc is initial.
                        commit work.
                      else.
                        rollback work.
                      endif.

                    endif.

*** Muda Status da etapa
                    move: wa_flwdoc_ax-natdc to wa_flwdoc-natdc,
                          wa_flwdoc_ax-typed to wa_flwdoc-typed,
                          lv_chave           to wa_flwdoc-chave,
                          wa_flwdoc_ax-flowd to wa_flwdoc-flowd,
                          sy-datum           to wa_flwdoc-dtreg,
                          sy-uzeit           to wa_flwdoc-hrreg,
                          sy-uname           to wa_flwdoc-uname,
                         'W' to wa_flwdoc-flwst.
                    modify zhms_tb_flwdoc from wa_flwdoc.
                    clear wa_flwdoc.

                    if sy-subrc is initial.
                      commit work.
                    else.
                      rollback work.
                    endif.

*** Altera status do documento
                    select single * from zhms_tb_docst into wa_docstx
                    where natdc eq wa_flwdoc_ax-natdc
                    and typed eq wa_flwdoc_ax-typed
                    and chave eq lv_chave.

                    if sy-subrc is initial.
                      update zhms_tb_docst
                      set sthms = '2'
                      where natdc eq wa_flwdoc_ax-natdc
                         and typed eq wa_flwdoc_ax-typed
                         and chave eq lv_chave.

                      if sy-subrc is initial.
                        commit work.
                      else.
                        rollback work.
                      endif.
                    endif.

*** Grava Log de sucesso para o estorno
                    perform f_change_return tables lt_return using lv_docnum.
                    perform f_grava_log tables lt_return using: ls_return
                                                         wa_flwdoc_ax-natdc
                                                         wa_flwdoc_ax-typed
                                                         ls_scen_flo-loctp
                                                         lv_chave.

                  endif.



              endcase.
            endif.
          endif.
        endif.
      endif.
    endform.                    " F_ESTORNO

*&---------------------------------------------------------------------*
*&      Form  F_GRAVA_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
    form f_grava_log tables lt_return using: ls_return type bapiret2
                                             la_natdc
                                             la_typed
                                             la_loctp
                                             lv_chave.

      data: lt_logdoc type standard table of zhms_tb_logdoc,
            ls_logdoc like line of lt_logdoc.

      loop at lt_return into ls_return.
        move: la_natdc             to ls_logdoc-natdc,
              la_typed             to ls_logdoc-typed,
              la_loctp             to ls_logdoc-loctp,
              lv_chave             to ls_logdoc-chave,
              1                    to ls_logdoc-seqnr,
              sy-datum             to ls_logdoc-dtreg,
              sy-uzeit             to ls_logdoc-hrreg,
              sy-uname             to ls_logdoc-uname,
              ls_return-id         to ls_logdoc-logid,
              ls_return-type       to ls_logdoc-logty,
              ls_return-number     to ls_logdoc-logno,
              ls_return-message    to ls_logdoc-logv1,
              ls_return-message_v1 to ls_logdoc-logv1,
              ls_return-message_v2 to ls_logdoc-logv2.
        append ls_logdoc to lt_logdoc.
        clear ls_logdoc.

      endloop.

      modify zhms_tb_logdoc from table lt_logdoc.

      if sy-subrc is initial.
        commit work.
      else.
        rollback work.
      endif.

    endform.                    " F_GRAVA_LOG
*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_RETURN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_RETURN  text
*----------------------------------------------------------------------*
    form f_change_return  tables   p_lt_return using la_docnum.

      data: ls_return type bapiret2.

      refresh p_lt_return.
      move: 'S' to ls_return-type.
      concatenate 'Nº' la_docnum 'foi estornado' into ls_return-message_v1 separated by space.
      append ls_return to p_lt_return.
      clear ls_return.

    endform.                    " F_CHANGE_RETURN
*&---------------------------------------------------------------------*
*&      Form  F_VLD_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
    form f_vld_fieldcat .

      refresh t_fieldcatvld.
      clear   wa_fieldcatvld.


***   Obtendo campos
      call function 'LVC_FIELDCATALOG_MERGE'
        exporting
          i_structure_name       = 'ZHMS_VLD_ITEMS'
        changing
          ct_fieldcat            = t_fieldcatvld
        exceptions
          inconsistent_interface = 1
          program_error          = 2
          others                 = 3.

      if sy-subrc is initial.
        loop at t_fieldcatvld into wa_fieldcatvld.
          move 'X' to wa_fieldcatvld-hotspot.
          modify t_fieldcatvld from wa_fieldcatvld index sy-tabix.
        endloop.
      endif.

    endform.                    " F_VLD_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_HIER_VLD_ITENS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
    form f_create_hier_vld_itens .

      data: lt_item_layout type lvc_t_layi,
            ls_item_layout type lvc_s_layi,
            l_node_text    type lvc_value,
            vl_parent_key  type lvc_nkey,
            vl_node_exp    type lvc_t_nkey,
            vl_relat_nod   type lvc_nkey.

*** Monta primeira linha Principal Arvore
      l_node_text = 'Teste'.

      ls_item_layout-fieldname = ob_tree_valid->c_hierarchy_column_name.
      append ls_item_layout to lt_item_layout.

***   Chamada do método que insere linhas na árvore
      call method ob_tree_valid->add_node
        exporting
          i_relat_node_key = vl_relat_nod
          i_relationship   = cl_gui_column_tree=>relat_last_child
          is_outtab_line   = wa_itensview_vld
          i_node_text      = l_node_text
          it_item_layout   = lt_item_layout
        importing
          e_new_node_key   = vl_parent_key.

      loop at t_hrvalid_aux into wa_hrvalid_aux.

        clear wa_itensview_vld.
        move wa_hrvalid_aux to wa_itensview_vld.

      endloop.

    endform.                    " F_CREATE_HIER_VLD_ITENS
*&---------------------------------------------------------------------*
*&      Form  F_REG_EVENTS_VALID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
    form f_reg_events_valid .

*     Variáveis locais
      data: wl_event      type cntl_simple_event,
            tl_events     type cntl_simple_events,
            g_application type ref to lcl_application.

      " node double click
      wl_event-eventid = cl_gui_column_tree=>eventid_node_double_click.
      wl_event-appl_event = 'X'. " process PAI if event occurs
      append wl_event to tl_events.

      " item double click
      wl_event-eventid = cl_gui_column_tree=>eventid_item_double_click.
      wl_event-appl_event = 'X'.
      append wl_event to tl_events.

      " link click
      wl_event-eventid = cl_gui_column_tree=>eventid_link_click.
      wl_event-appl_event = 'X'.
      append wl_event to tl_events.

      " button click
      wl_event-eventid = cl_gui_column_tree=>eventid_button_click.
      wl_event-appl_event = 'X'.
      append wl_event to tl_events.

      call method ob_valid->set_registered_events
        exporting
          events                    = tl_events
        exceptions
          cntl_error                = 1
          cntl_system_error         = 2
          illegal_event_combination = 3.
      if sy-subrc <> 0.
        message a000.
      endif.

* assign event handlers in the application class to each desired event
      create object g_application.

      set handler g_application->handle_link_click for ob_valid.
*      SET HANDLER g_application->handle_button_click FOR ob_valid.

    endform.                    " F_REG_EVENTS_VALID
*&---------------------------------------------------------------------*
*&      Form  F_J1B1N
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
    form f_j1b1n .

      data: vl_function type fieldname.
      clear vl_function.

      check not wa_cabdoc-chave is initial.

      select single funct
        from zhms_tb_scen_flo
        into vl_function
        where natdc eq '02'
          and typed eq 'NFE'
          and scena eq '4'
          and flowd eq '10'.

      if vl_function is initial.
        message s398(00) with 'Falta configurar chamada da Função' display like 'E'.
        leave list-processing.
      else.

*      CALL FUNCTION 'ZHMS_FM_J1B1N'
        call function vl_function
          exporting
            chave = wa_cabdoc-chave.

        perform f_refresh_docs_status.

      endif.

    endform.                    " F_J1B1N
*&---------------------------------------------------------------------*
*&      Form  F_FILTRA_CENARIO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
    form f_filtra_cenario .

      if wa_cabdoc-typed ne 'NFE4'.
        if wa_cabdoc-scena = '4'.                                " J1B1N

          delete t_toolbar  where fcode ne 'SHOW_DET'
                              and fcode ne 'HOW_FLOW'
                              and fcode ne 'LOGS'
                              and fcode ne 'J1B1N'
                              and fcode ne 'SHOW_XML'.
*                            AND fcode NE 'VALID'.
        else.
          delete t_toolbar  where fcode eq 'J1B1N'.
        endif.
      endif.

      read table t_docst into wa_docst with key natdc = vg_natdc
                                                typed = vg_typed
                                                chave = vg_chave.
      if sy-subrc eq 0.
        if wa_docst-sthms = 3.
          clear t_toolbar.
        endif.
      endif.

*** verifica se é nota de importação
      read table t_docmn_rep into wa_docmn_rep with key mneum = 'IDDEST'.

      if sy-subrc is initial and wa_docmn_rep-value ne '3'.
        delete t_toolbar  where fcode eq 'DEBTPOST'.
      endif.

    endform.                    " F_FILTRA_CENARIO
*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_SISTEM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
    form f_clear_sistem .

*      IF sy-uname EQ 'JUNPSAMP'.
*
*        CLEAR: node,
*               item,
*               wl_itxw_note,
*               wa_docmn_rep,
*               wa_impostos,
*               ls_mapping,
*               wa_j1b1n_tax,
*               wa_param,
*               wa_lfa1,
*               wa_docmnxped,
*               wa_docmna,
*               ls_mapdata,
*               wa_kna1,
*               wa_docst,
*               wa_flds,
*               wa_tabs,
*               wa_docst_new,
*               wa_docrf,
*               wa_grpfld_s,
*               wa_cabdoc,
*               wa_cabdoc_main,
*               wa_datasrc,
*               wa_wwwdata,
*               wa_repdoc,
*               wa_xmlview,
*               wa_xmlview_aux,
*               wa_itmdoc_ax,
*               wa_itmatr,
*               wa_itmatr_ax,
*               wa_logdoc_aux,
*               wa_logdoc,
*               wa_hvalid_aux,
*               wa_hvalid_vw,
*               wa_hrvalid_aux,
*               wa_hrvalid_aux2,
*               wa_itensview_vld,
*               wa_just,
*               wa_hrvalid,
*               wa_hvalid,
*               wa_lt_vld_hvalid,
*               wa_hvalid_fldc,
*               wa_flow_fldc,
*               wa_vld_fldc,
*               wa_fieldcat,
*               wa_fieldcatvld,
*               wa_hier_header,
*               wa_variant,
*               wa_vld_usrad,
*               wa_bapireturn,
*               wa_bapireturn,
*               wa_evv_laytx,
*               wa_evv_layt,
*               wa_btnmnu,
*               wa_buttons,
*               wa_toolbar,
*               wa_toolbar_aux,
*               wa_hvalid_new,
*               wa_gate,
*               wa_gatemneu,
*               wa_gatemneux,
*               wa_gateobs,
*               wa_docrcbto_ax,
*               wa_docconf_ax,
*               wa_docrcbto,
*               wa_datrcbto,
*               wa_docconf,
*               wa_datconf,
*               wa_datconf_ax,
*               wa_return,
*               wa_dcevet,
*               wa_nfeevt,
*               wa_regvld,
*               wa_regvldx,
*               wa_flwdoc,
*               wa_flwdoc_ax,
*               wa_scenflox,
*               wa_scenflo,
*               wa_docmn,
*               wa_docmn_ax,
*               wa_atrbuffer,
*               wa_mneuatr,
*               wa_chave,
*               wa_vld_item,
*               wa_twhere,
*               wa_vld_itemx,
*               wa_es_vld_h,
*               wa_es_vld_i,
*               wa_out_vld_i,
*               wa_logunk,
*               wa_logunkaux,
*               wa_logparam,
*               wa_logdetal,
*               wa_ht_field,
*               wa_ht_histo,
*               wa_ht_out,
*               wa_tx_events,
*               wa_docstx,
*               wa_show_po,
*               wa_1bdylin,
*               ob_cc_img_docs,
*               ob_img_docs,
*               ob_cc_html_docs,
*               ob_html_docs,
*               ob_cc_html_det,
*               ob_html_det,
*               ob_cc_html_rcp,
*               ob_html_rcp,
*               ob_cc_pdf_docs,
*               ob_pdf_docs,
*               ob_cc_xml_docs,
*               ob_xml_docs,
*               ob_cc_vis_itens,
*               ob_vis_itens,
*               ob_cc_atr_itens,
*               ob_atr_itens,
*               ob_valid,
*               ob_cc_valid,
*               ob_tree_valid,
*               ob_cc_valid_itens,
*               ob_cc_tb_docs,
*               ob_tb_docs,
*               ob_menu_docs,
*               ob_cc_tb_det,
*               ob_tb_det,
*               ob_menu_det,
*               ob_timer,
*               ob_timer_event,
*               ob_cc_vld_hvalid,
*               ob_hvalid,
*               ob_flow,
*               ob_hvalid_event,
*               ob_ref_consumer,
*               ob_dcevt_obs,
*               ob_cc_dcevt_obs,
*               ob_cc_det_flow,
*               ob_cc_vld_item,
*               ob_cc_grid,
*               ob_ht_object,
*               ob_cc_ht,
*               ob_cc_ht_grid,
*               save_ok,
*               vg_selid,
*               vg_actnum,
*               vg_title,
*               v_index,
*               vg_status,
*               vg_qtsel,
*               vg_chave,
*               vg_chave_sel,
*               vg_chave_main,
*               vg_loctp,
*               vg_event,
*               vg_versn,
*               vg_vld_shwhst,
*               vg_edurl,
*               vg_screen_call,
*               vg_metric,
*               vg_tdsrf,
*               vg_atprp,
*               vg_handle,
*               v_gate,
*               v_observ,
*               vg_flowd,
*               vg_funct,
*               vg_codmp,
*               vg_nfenum,
*               v_line,
*               vg_estorno,
*               vg_just_ok,
*               wa_evt_docs,
*               wa_evt_det,
*               l_ex_ref,
*               tc_logdoc,
*               TS_DET_DOC,
*               TC_ATR_ITMATR,
*               G_TC_ATR_ITMATR_LINES,
*               TC_PRT_DOCRCBTO,
*               TC_CNF_DOCCONF,
*               TC_CNF_DATCONF,
*               TC_FLWDOC,
*               G_TC_LOGSCONEC_LINES,
*               G_TC_ERROSLOG_LINES,
*               G_TC_ERROSLOGC_LINES,
*               G_TC_ERROSLOGCO_LINES,
*               G_TC_ERROSLOGCODE_LINES,
*               G_TC_ERROSLOGDET_LINES,
*               G_TC_SHOW_PO_LINES,
*               VL_CHAVE,
*               WAL_DATASRC,
*               VL_ERROR,
*               VL_OBJID,
*               WAL_DATASRC_RCP,
*               VL_TEXTNOTE_REPID,
*               LS_NODETABLE_VLD,
*               LS_ITEMTABLE_VLD,
*               L_NODE_TEXT,
*               LV_NODE_KEY,
*               LS_ITEM_LAYOUT,
*               EVENT_RECEIVER,
*               E_OBJECT,
*               LS_CABDOC,
*               LS_ITMATR,
*               LS_GRP,
*               VL_ERRO,
*               G_TC_ATR_ITMATR_WA2,
*               WL_ITMATR_AX,
*               G_TC_PRT_DOCRCBTO_WA2,
*               G_TC_CNF_DOCCONF_WA2,
*               WL_OPCOESFLW,
*               WL_OPCOES,
*               G_TC_SHOW_PO_WA2.
*
*
*        REFRESH: t_html_index,
*                 t_param,
*                 t_lfa1,
*                 t_kna1,
*                 t_docst,
*                 t_docst_new,
*                 t_docrf,
*                 t_docrf_es,
*                 t_grpfld_s,
*                 t_cabdoc,
*                 t_cabdoc_ref,
*                 t_codes,
*                 t_tabs,
*                 t_flds,
*                 t_datasrc,
*                 t_wwwdata,
*                 t_repdoc,
*                 t_xmlview,
*                 t_xmlview_aux,
*                 t_itensview,
*                 t_itensvld,
*                 t_itmdoc,
*                 t_itmatr,
*                 t_itmdoc_atr,
*                 t_itmatr_atr,
*                 t_itmatr_ax,
*                 t_node_tree,
*                 t_item_tree,
*                 tl_textnote,
*                 t_texpr,
*                 t_twhere,
*                 t_logdoc_aux,
*                 t_logdoc,
*                 t_hvalid_aux,
*                 t_hvalid_aux2,
*                 t_hvalid_vw,
*                 t_hrvalid_aux,
*                 t_hrvalid,
*                 t_hvalid,
*                 t_regvld,
*                 t_regvldx,
*                 t_sort_hvalid,
*                 t_hvalid_fldc,
*                 t_flow_fldc,
*                 t_vld_fldc,
*                 t_fieldcat,
*                 t_fieldcatitm,
*                 t_fieldcatvld,
*                 t_bapireturn,
*                 t_evv_laytx,
*                 t_evv_layt,
*                 t_btnmnu,
*                 t_buttons,
*                 t_toolbar,
*                 t_toolbar_aux,
*                 t_chave,
*                 t_gatemneu,
*                 t_gatemneux,
*                 t_gateobs,
*                 t_docrcbto_ax,
*                 t_docconf_ax,
*                 t_docrcbto,
*                 t_datrcbto,
*                 t_docconf,
*                 t_datconf,
*                 t_datconf_ax,
*                 t_dcevet,
*                 t_nfeevt,
*                 t_flwdoc,
*                 t_flwdoc_ax,
*                 t_flwdoc_ax2,
*                 t_scenflox,
*                 t_scenflo,
*                 t_docmn,
*                 t_docmnxped,
*                 t_docmna,
*                 t_docmn_rep,
*                 t_docmn_ax,
*                 t_atrbuffer,
*                 t_mneuatr,
*                 t_vld_item,
*                 t_vld_itemx,
*                 t_es_vld_h,
*                 t_es_vld_i,
*                 t_out_vld_i,
*                 t_logunk,
*                 t_msgunk,
*                 t_logparam,
*                 t_logdetal,
*                 t_ht_field,
*                 t_ht_histo,
*                 t_ht_out,
*                 t_tx_events,
*                 t_show_po,
*                 gt_bdc,
*                 t_impostos,
*                 t_j1b1n_tax,
*                 lt_mapdata,
*                 tl_itxw_note,
*                 t_evt_docs,
*                 t_evt_det,
*                 TL_DATASRC,
*                 TL_CODES,
*                 TL_DATASRC_RCP,
*                 TL_NODETABLE,
*                 TL_ITEMTABLE,
*                 TL_NODETABLE_VLD,
*                 TL_ITEMTABLE_VLD,
*                 TL_NODESEXP,
*                 LT_ITEM_LAYOUT,
*                 LT_GRP,
*                 TL_OPCOESFLW,
*                 TL_OPCOES.

*      ENDIF.

    endform.                    " F_CLEAR_SISTEM

*&---------------------------------------------------------------------*
*&      Form  ZF_CHECK_AUTO_EXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
    form zf_check_auto_ext .
      types: begin of ty_ekbe,
               ebeln type ekbe-ebeln,
               ebelp type ekbe-ebelp,
               zekkn type ekbe-zekkn,
               vgabe type ekbe-vgabe,
               gjahr type ekbe-gjahr,
               belnr type ekbe-belnr,
               buzei type ekbe-buzei,
               bewtp type ekbe-bewtp,
               bwart type ekbe-bwart,
*        ernam type ekbe-ernam,
             end of ty_ekbe,
*Homine - Inicio da Inclusão - DD
             begin of ty_ekko,
               ebeln type ekko-ebeln,
               lifnr type ekko-lifnr,
             end of ty_ekko.
*Homine - Fim da Inclusão - DD

      data: t_docmn       type table of zhms_tb_docmn,
            w_docmn       type zhms_tb_docmn,
            t_ekbe        type table of ty_ekbe,
            w_ekbe        type ty_ekbe,
*Homine - Inicio da Inclusão - DD
            t_ekko        type table of ty_ekko,
            w_ekko        type ty_ekko,
*Homine - Fim da Inclusão - DD
            vl_xblnr      type ekbe-xblnr,
            vl_tabix      type sy-tabix,
            w_flwdoc_aux  type zhms_tb_flwdoc,
            vl_migo       type c length 10,
            vl_miro       type c length 10,
            vl_lifnr      type lfa1-lifnr,
            vl_lifnr_ekko type lfa1-lifnr,
            vl_cnpj       type lfa1-stcd1,
            vl_docnum_ent type j_1bnfdoc-docnum,
            vl_serie      type j_1bnfdoc-series,
            vl_nfnum      type j_1bnfdoc-nfenum,
            vl_docnum     type j_1bnfdoc-docnum.


* Verifica se documento tem o MATDOC (MIRO) feita. Caso tenha, não
* faz verificação na EKBE em busca em MIRO externa
**    Limpar as variáveis
      clear: wa_scenflo.
      refresh: t_scenflo.

**    Selecionar fluxo para este tipo de documento
      select *
        into table t_scenflo
        from zhms_tb_scen_flo
        for all entries in t_cabdoc
       where natdc eq t_cabdoc-natdc
         and typed eq t_cabdoc-typed
         and loctp eq t_cabdoc-loctp
         and scena eq t_cabdoc-scena.

      select *
        from zhms_tb_docmn
        into table t_docmn
        for all entries in t_cabdoc
        where chave = t_cabdoc-chave.

      if sy-subrc eq 0.
        delete t_docmn
          where mneum ne 'NNF'
            and mneum ne 'NUMERO'
            and mneum ne 'NCT'
            and mneum ne 'SERIE'
            and mneum ne 'MATDOC'
            and mneum ne 'INVDOCNO'
            and mneum ne 'CNPJ'
            and mneum ne 'EMITCNPJ'.

        loop at t_docmn into w_docmn.

          read table t_docmn into w_docmn with key chave = w_docmn-chave
                                                   mneum = 'NNF'.
          if sy-subrc eq 0.
            vl_xblnr = w_docmn-value.
            condense vl_xblnr no-gaps.
            vl_nfnum = vl_xblnr.
            call function 'CONVERSION_EXIT_ALPHA_INPUT'
              exporting
                input  = vl_nfnum
              importing
                output = vl_nfnum.
            vl_xblnr = vl_nfnum.


          else.
            read table t_docmn into w_docmn with key chave = w_docmn-chave
                                          mneum = 'NUMERO'.
            if sy-subrc eq 0.
              vl_xblnr = w_docmn-value.
              condense vl_xblnr no-gaps.
              vl_nfnum = vl_xblnr.
              call function 'CONVERSION_EXIT_ALPHA_INPUT'
                exporting
                  input  = vl_nfnum
                importing
                  output = vl_nfnum.
              vl_xblnr = vl_nfnum.
            else.
              read table t_docmn into w_docmn with key chave = w_docmn-chave
                                          mneum = 'NCT'.
              if sy-subrc eq 0.
                vl_xblnr = w_docmn-value.
                condense vl_xblnr no-gaps.
                vl_nfnum = vl_xblnr.
                call function 'CONVERSION_EXIT_ALPHA_INPUT'
                  exporting
                    input  = vl_nfnum
                  importing
                    output = vl_nfnum.
                vl_xblnr = vl_nfnum.
              endif.
            endif.
          endif.

          read table t_docmn into w_docmn with key chave = w_docmn-chave
                                                   mneum = 'SERIE'.
          if sy-subrc eq 0.
*Homine - Inicio da Inclusão - DD
            if not w_docmn-value is initial.
*Homine - Fim da Inclusão - DD

              condense vl_xblnr no-gaps.
              vl_serie = w_docmn-value.
              condense vl_serie no-gaps.
              call function 'CONVERSION_EXIT_ALPHA_INPUT'
                exporting
                  input  = vl_serie
                importing
                  output = vl_serie.
              concatenate vl_xblnr '-' vl_serie into vl_xblnr.
            endif.
          endif.

          read table t_docmn into w_docmn with key chave = w_docmn-chave
                                                   mneum = 'CNPJ'.
          if sy-subrc eq 0.
            vl_cnpj = w_docmn-value.
            condense vl_cnpj no-gaps.
          endif.
          read table t_cabdoc into wa_cabdoc with key chave = w_docmn-chave.
          read table t_scenflo into wa_scenflo with key natdc = wa_cabdoc-natdc
                                                        typed = wa_cabdoc-typed
                                                        loctp = wa_cabdoc-loctp
                                                        scena = wa_cabdoc-scena.
          if wa_scenflo-funct eq 'ZHMS_FM_J1B1N'.
            clear: vl_lifnr.
            select single lifnr
              from lfa1
              into vl_lifnr
              where stcd1 = vl_cnpj.

            select single docnum
              into vl_docnum_ent
              from j_1bnfdoc
              where direct = '1'
                and series = vl_serie
                and nfnum = vl_nfnum
                and parid = vl_lifnr.
            if sy-subrc = 0.

              read table t_docst into wa_docst with key natdc = wa_cabdoc-natdc
                                                       typed = wa_cabdoc-typed
                                                       chave = wa_cabdoc-chave.
              if sy-subrc eq 0.
                vl_tabix = sy-tabix.

* Verifica se não é uma nota de cancelamento
                if wa_docst-sthms = 3 and wa_docst-strec = 9.
                  exit.
                endif.
                if wa_docst-sthms <> 1 and wa_docst-sthms <> 4.
                  wa_docst-sthms = 3.
                  wa_docst-dtalt = sy-datum.
                  wa_docst-hralt = sy-uzeit.
                  modify t_docst from wa_docst index vl_tabix.
                  modify zhms_tb_docst from wa_docst.
                endif.
              endif.
            else.


            endif.

          else.
            select ebeln ebelp zekkn vgabe gjahr belnr buzei bewtp bwart "ernam
              from ekbe
              into table t_ekbe
              where xblnr = vl_xblnr
                and bewtp = 'E'
              order by belnr descending.
            if sy-subrc eq 0.
              read table t_ekbe into w_ekbe index 1.

              select single lifnr
                from ekko
                into vl_lifnr
                where ebeln = w_ekbe-ebeln.
              if sy-subrc eq 0.
                select single lifnr
                  from lfa1
                  into vl_lifnr_ekko
                  where stcd1 = vl_cnpj.
                if sy-subrc eq 0.
                  if vl_lifnr_ekko ne vl_lifnr.
*                    EXIT.
                    select ebeln ebelp zekkn vgabe gjahr belnr buzei bewtp bwart "ernam
                                 from ekbe
                                 into table t_ekbe
                                 where xblnr = vl_xblnr
                                   and bewtp = 'Q'
                                 order by belnr descending.
                    if sy-subrc eq 0.
*                READ TABLE t_ekbe INTO w_ekbe INDEX 1.
*
*                SELECT SINGLE lifnr
*                  FROM ekko
*                  INTO vl_lifnr
*                  WHERE ebeln = w_ekbe-ebeln.
*                IF sy-subrc EQ 0.
                      select single lifnr
                        from lfa1
                        into vl_lifnr_ekko
                        where stcd1 = vl_cnpj.

*                  IF sy-subrc EQ 0.
**                    IF vl_lifnr_ekko NE vl_lifnr.
**                      EXIT.
**                    ENDIF.
*                  ENDIF.
*                ENDIF.

                      select ebeln lifnr
                       from ekko
                       into table t_ekko
                       for all entries in t_ekbe
                       where ebeln = t_ekbe-ebeln.
                      clear: v_lifnr_cont.
                      loop at t_ekko into w_ekko.
                        if vl_lifnr_ekko = w_ekko-lifnr.
                          v_lifnr_cont = 'X'.
                        endif.
                      endloop.
                      if v_lifnr_cont = 'X' .
                        read table t_cabdoc into wa_cabdoc with key chave = w_docmn-chave.
                        select single *
                          into wa_scenflo
                          from zhms_tb_scen_flo
                         where natdc eq wa_cabdoc-natdc
                           and typed eq wa_cabdoc-typed
                           and loctp eq wa_cabdoc-loctp
                           and scena eq wa_cabdoc-scena
                           and funct eq 'BAPI_INCOMINGINVOICE_CREATE'.
                        if sy-subrc = 0.



                          read table t_cabdoc into wa_cabdoc with key chave = w_docmn-chave.
                          if sy-subrc eq 0.
                            read table t_docst into wa_docst with key natdc = wa_cabdoc-natdc
                                                                      typed = wa_cabdoc-typed
                                                                      chave = wa_cabdoc-chave.
                            if sy-subrc eq 0.
                              if wa_docst-sthms ne 3.
                                vl_tabix = sy-tabix.
                                wa_docst-sthms = 3.
                                wa_docst-dtalt = sy-datum.
                                wa_docst-hralt = sy-uzeit.
                                modify t_docst from wa_docst index vl_tabix.
                                modify zhms_tb_docst from wa_docst.
                              endif.
                            endif.
                          endif.
                        endif.
                      endif.
                    endif.
                  else.
                    read table t_cabdoc into wa_cabdoc with key chave = w_docmn-chave.
                    select single *
                      into wa_scenflo
                      from zhms_tb_scen_flo
                     where natdc eq wa_cabdoc-natdc
                       and typed eq wa_cabdoc-typed
                       and loctp eq wa_cabdoc-loctp
                       and scena eq wa_cabdoc-scena
                       and funct eq 'BAPI_GOODSMVT_CREATE'.
                    if sy-subrc = 0.


                      clear w_flwdoc_aux.
                      select single *
                        from zhms_tb_flwdoc
                        into w_flwdoc_aux
                        where chave = w_docmn-chave
                          and flowd = wa_scenflo-flowd.

*-------------------------------------------------------------------------
*Alterado por Renan Itokazo
*04.09.2018
                      if sy-subrc eq 0.
*-------------------------------------------------------------------------

* MIGO feita por fora
                        if w_ekbe-bwart = '101' and w_flwdoc_aux-uname ne 'HomSoft'.
*            IF w_ekbe-bwart = '101' AND ( w_flwdoc_aux-uname ne w_ekbe-ernam ). "Copia ambiente PRIMETALS

                          read table t_cabdoc into wa_cabdoc with key chave = w_docmn-chave.
                          if sy-subrc eq 0.
                            read table t_docst into wa_docst with key natdc = wa_cabdoc-natdc
                                                                      typed = wa_cabdoc-typed
                                                                      chave = wa_cabdoc-chave.
                            if sy-subrc eq 0.
                              if wa_docst-sthms ne 3.
                                vl_tabix = sy-tabix.
                                wa_docst-sthms = 3.
                                wa_docst-dtalt = sy-datum.
                                wa_docst-hralt = sy-uzeit.
                                modify t_docst from wa_docst index vl_tabix.
                                modify zhms_tb_docst from wa_docst.
                              endif.
                            endif.
                          endif.

                        else.

                          clear vl_migo.
                          read table t_docmn into w_docmn with key chave = w_docmn-chave
                                                                   mneum = 'MATDOC'.
                          if sy-subrc eq 0.
                            vl_migo = w_docmn-value.
                          endif.

                          clear vl_miro.
                          read table t_docmn into w_docmn with key chave = w_docmn-chave
                                                                   mneum = 'INVDOCNO'.
                          if sy-subrc eq 0.
                            vl_miro = w_docmn-value.
                          endif.


                          read table t_cabdoc into wa_cabdoc with key chave = w_docmn-chave.
                          if sy-subrc eq 0.
                            read table t_docst into wa_docst with key natdc = wa_cabdoc-natdc
                                                                     typed = wa_cabdoc-typed
                                                                     chave = wa_cabdoc-chave.
                            if sy-subrc eq 0.
                              vl_tabix = sy-tabix.

* Verifica se não é uma nota de cancelamento
                              if wa_docst-sthms = 3 and wa_docst-strec = 9.
                                exit.
                              endif.
*Verifica se ja não é uma nota com erro
                              if wa_docst-sthms = 4.
                                exit.
                              endif.

                              if vl_migo is not initial and vl_miro is not initial.
                                wa_docst-sthms = 1.
                              else.
                                wa_docst-sthms = 2.
                              endif.

                              wa_docst-dtalt = sy-datum.
                              wa_docst-hralt = sy-uzeit.
                              modify t_docst from wa_docst index vl_tabix.
                              modify zhms_tb_docst from wa_docst.
                            endif.
                          endif.
                        endif.
                      endif.
                    endif.


                  endif.
                endif.
              endif.

*              READ TABLE t_cabdoc INTO wa_cabdoc WITH KEY chave = w_docmn-chave.
*              SELECT SINGLE *
*                INTO wa_scenflo
*                FROM zhms_tb_scen_flo
*               WHERE natdc EQ wa_cabdoc-natdc
*                 AND typed EQ wa_cabdoc-typed
*                 AND loctp EQ wa_cabdoc-loctp
*                 AND scena EQ wa_cabdoc-scena
*                 AND funct EQ 'BAPI_GOODSMVT_CREATE'.
*              IF sy-subrc = 0.
*
*
*                CLEAR w_flwdoc_aux.
*                SELECT SINGLE *
*                  FROM zhms_tb_flwdoc
*                  INTO w_flwdoc_aux
*                  WHERE chave = w_docmn-chave
*                    AND flowd = wa_scenflo-flowd.
*
**-------------------------------------------------------------------------
**Alterado por Renan Itokazo
**04.09.2018
*                IF sy-subrc EQ 0.
**-------------------------------------------------------------------------
*
** MIGO feita por fora
*                  IF w_ekbe-bwart = '101' AND w_flwdoc_aux-uname NE 'HomSoft'.
**            IF w_ekbe-bwart = '101' AND ( w_flwdoc_aux-uname ne w_ekbe-ernam ). "Copia ambiente PRIMETALS
*
*                    READ TABLE t_cabdoc INTO wa_cabdoc WITH KEY chave = w_docmn-chave.
*                    IF sy-subrc EQ 0.
*                      READ TABLE t_docst INTO wa_docst WITH KEY natdc = wa_cabdoc-natdc
*                                                                typed = wa_cabdoc-typed
*                                                                chave = wa_cabdoc-chave.
*                      IF sy-subrc EQ 0.
*                        IF wa_docst-sthms NE 3.
*                          vl_tabix = sy-tabix.
*                          wa_docst-sthms = 3.
*                          wa_docst-dtalt = sy-datum.
*                          wa_docst-hralt = sy-uzeit.
*                          MODIFY t_docst FROM wa_docst INDEX vl_tabix.
*                          MODIFY zhms_tb_docst FROM wa_docst.
*                        ENDIF.
*                      ENDIF.
*                    ENDIF.
*
*                  ELSE.
*
*                    CLEAR vl_migo.
*                    READ TABLE t_docmn INTO w_docmn WITH KEY chave = w_docmn-chave
*                                                             mneum = 'MATDOC'.
*                    IF sy-subrc EQ 0.
*                      vl_migo = w_docmn-value.
*                    ENDIF.
*
*                    CLEAR vl_miro.
*                    READ TABLE t_docmn INTO w_docmn WITH KEY chave = w_docmn-chave
*                                                             mneum = 'INVDOCNO'.
*                    IF sy-subrc EQ 0.
*                      vl_miro = w_docmn-value.
*                    ENDIF.
*
*
*                    READ TABLE t_cabdoc INTO wa_cabdoc WITH KEY chave = w_docmn-chave.
*                    IF sy-subrc EQ 0.
*                      READ TABLE t_docst INTO wa_docst WITH KEY natdc = wa_cabdoc-natdc
*                                                               typed = wa_cabdoc-typed
*                                                               chave = wa_cabdoc-chave.
*                      IF sy-subrc EQ 0.
*                        vl_tabix = sy-tabix.
*
** Verifica se não é uma nota de cancelamento
*                        IF wa_docst-sthms = 3 AND wa_docst-strec = 9.
*                          EXIT.
*                        ENDIF.
*
*                        IF vl_migo IS NOT INITIAL AND vl_miro IS NOT INITIAL.
*                          wa_docst-sthms = 1.
*                        ELSE.
*                          wa_docst-sthms = 2.
*                        ENDIF.
*
*                        wa_docst-dtalt = sy-datum.
*                        wa_docst-hralt = sy-uzeit.
*                        MODIFY t_docst FROM wa_docst INDEX vl_tabix.
*                        MODIFY zhms_tb_docst FROM wa_docst.
*                      ENDIF.
*                    ENDIF.
*                  ENDIF.
*                ENDIF.
*              ENDIF.
*Homine - Inicio da Inclusão - DD
            else.
              select ebeln ebelp zekkn vgabe gjahr belnr buzei bewtp bwart "ernam
                           from ekbe
                           into table t_ekbe
                           where xblnr = vl_xblnr
                             and bewtp = 'Q'
                           order by belnr descending.
              if sy-subrc eq 0.
*                READ TABLE t_ekbe INTO w_ekbe INDEX 1.
*
*                SELECT SINGLE lifnr
*                  FROM ekko
*                  INTO vl_lifnr
*                  WHERE ebeln = w_ekbe-ebeln.
*                IF sy-subrc EQ 0.
                select single lifnr
                  from lfa1
                  into vl_lifnr_ekko
                  where stcd1 = vl_cnpj.

*                  IF sy-subrc EQ 0.
**                    IF vl_lifnr_ekko NE vl_lifnr.
**                      EXIT.
**                    ENDIF.
*                  ENDIF.
*                ENDIF.

                select ebeln lifnr
                 from ekko
                 into table t_ekko
                 for all entries in t_ekbe
                 where ebeln = t_ekbe-ebeln.
                clear: v_lifnr_cont.
                loop at t_ekko into w_ekko.
                  if vl_lifnr_ekko = w_ekko-lifnr.
                    v_lifnr_cont = 'X'.
                  endif.
                endloop.
                if v_lifnr_cont = 'X' .
                  read table t_cabdoc into wa_cabdoc with key chave = w_docmn-chave.
                  select single *
                    into wa_scenflo
                    from zhms_tb_scen_flo
                   where natdc eq wa_cabdoc-natdc
                     and typed eq wa_cabdoc-typed
                     and loctp eq wa_cabdoc-loctp
                     and scena eq wa_cabdoc-scena
                     and funct eq 'BAPI_INCOMINGINVOICE_CREATE'.
                  if sy-subrc = 0.



                    read table t_cabdoc into wa_cabdoc with key chave = w_docmn-chave.
                    if sy-subrc eq 0.
                      read table t_docst into wa_docst with key natdc = wa_cabdoc-natdc
                                                                typed = wa_cabdoc-typed
                                                                chave = wa_cabdoc-chave.
                      if sy-subrc eq 0.
                        if wa_docst-sthms ne 3.
                          vl_tabix = sy-tabix.
                          wa_docst-sthms = 3.
                          wa_docst-dtalt = sy-datum.
                          wa_docst-hralt = sy-uzeit.
                          modify t_docst from wa_docst index vl_tabix.
                          modify zhms_tb_docst from wa_docst.
                        endif.
                      endif.
                    endif.
                  endif.
                endif.
              else.
                if vl_cnpj is initial.
                  read table t_docmn into w_docmn with key chave = w_docmn-chave
                                                    mneum = 'EMITCNPJ'.
                  if sy-subrc eq 0.
                    vl_cnpj = w_docmn-value.
                    condense vl_cnpj no-gaps.
                  endif.
                endif.
                select single lifnr
                                  from lfa1
                                  into vl_lifnr_ekko
                                  where stcd1 = vl_cnpj.

                select single docnum
                  into vl_docnum
                  from j_1bnfdoc
                  where nfenum = vl_nfnum
                    and series = vl_serie
                    and parid = vl_lifnr_ekko.
                if sy-subrc = 0.
                  read table t_cabdoc into wa_cabdoc with key chave = w_docmn-chave.
                  select single *
                    into wa_scenflo
                    from zhms_tb_scen_flo
                   where natdc eq wa_cabdoc-natdc
                     and typed eq wa_cabdoc-typed
                     and loctp eq wa_cabdoc-loctp
                     and scena eq wa_cabdoc-scena
                     and funct eq 'BAPI_INCOMINGINVOICE_CREATE'.
                  if sy-subrc = 0.



                    read table t_cabdoc into wa_cabdoc with key chave = w_docmn-chave.
                    if sy-subrc eq 0.
                      read table t_docst into wa_docst with key natdc = wa_cabdoc-natdc
                                                                typed = wa_cabdoc-typed
                                                                chave = wa_cabdoc-chave.
                      if sy-subrc eq 0.
                        if wa_docst-sthms ne 3.
                          vl_tabix = sy-tabix.
                          wa_docst-sthms = 3.
                          wa_docst-dtalt = sy-datum.
                          wa_docst-hralt = sy-uzeit.
                          modify t_docst from wa_docst index vl_tabix.
                          modify zhms_tb_docst from wa_docst.
                        endif.
                      endif.
                    endif.
                  endif.
                endif.
              endif.
            endif.
*Homine - Fim da Inclusão - DD
          endif.
        endloop.

      endif.


    endform.                    " ZF_CHECK_AUTO_EXT

*&---------------------------------------------------------------------*
*&      Form  F_MONTA_DANFE
*&---------------------------------------------------------------------*
    form f_monta_danfe .

      data: lt_pdf     type table of tline,
            ls_pdf     like line of lt_pdf,
            lv_url     type char255,
            pdf_fsize  type  i,
            lv_content type xstring,
            lt_data    type standard table of x255.
      field-symbols <fs_x> type x.
      data : l_job_output_info type ssfcrescl.
      data : ls_control_param  type ssfctrlop.

      data : g_html_container type ref to cl_gui_custom_container,
             g_html_control   type ref to cl_gui_html_viewer.
      data   it_tsp01 type table of tsp01.

*      DATA: it_docmn_danfe TYPE TABLE OF zhms_tb_docmn,
*            wa_docmn_danfe TYPE zhms_tb_docmn,
*            wa_cfop        TYPE j_1bagnt.

      data: fm_name        type rs38l_fnam.
      data: lv_subject type tdtitle.

*---data for SmartForms---*
      data: output_options type ssfcompop. " transfer printer to SM
      data: control_parameters type ssfctrlop.

* Tabela para dados da fatura (SMARTFORMS).
      data: w_danfe       type znfedanfe_header,
            w_issuer      type j_1bprnfis,
            w_destination type j_1bprnfde,
            w_carrier     type j_1binnad,
            w_nota_fiscal type j_1bprnfhd,
            w_nfe         type j_1bnfe_active,
            w_j_1bprnfli  type j_1bprnfli,
            w_item        type znfyitem,
            t_item        type table of znfyitem,
            w_invoice     type j_1bprnffa,
            t_invoice     type table of znfyinvoice,
            w_text        type tline,
            w_other       type znfedanfe_others.

* Informações de contigencia
      data: v_contingkey(36) type c,
            v_nfe            type string,
            v_nfe1           type string,
            v_aux            type c length 255,
            v_dcitm          type n length 6.

*      break rsantos.

      if wa_cabdoc-typed = 'CTE'.

        clear: it_docmn_danfe, wa_docmn_danfe.

        select *
          from zhms_tb_docmn
          into table it_docmn_danfe
          where chave = vg_chave.

        if sy-subrc eq 0.

* ISSUER ( EMITENTE )
          perform f_read using 'XNOME'                 changing w_issuer-name1.
* Endereço
          perform f_read using 'XLGR'                  changing w_issuer-stras.
          perform f_read using 'NRO'                   changing v_aux.
          concatenate w_issuer-stras  v_aux into w_issuer-stras.
          clear v_aux.

          perform f_read using 'XLGR'                  changing w_issuer-street.
          perform f_read using 'NRO'                   changing w_issuer-house_num1.
          perform f_read using 'CEP'                   changing w_issuer-pstlz.

* Bairro
          perform f_read using 'XMUN'                  changing w_issuer-ort01.

          perform f_read using 'XBAIRRO'               changing w_issuer-ort02.
* Estado
          perform f_read using 'UF'                    changing w_issuer-regio.
* CNPJ
          perform f_read using 'CNPJ'                  changing w_issuer-cgc.
* IE
          perform f_read using 'IE'                    changing w_issuer-stains.
          perform f_read using 'IE'                    changing w_issuer-munins.
          perform f_read using 'IEST'                  changing w_issuer-state_insc.

* Recebe o valor
          w_danfe-issuer = w_issuer.

* DESTINATARIO
* Nome empresa
          perform f_read using 'XNOMEDEST'             changing w_destination-name1.
* Endereço
          perform f_read using 'XLGRDEST'              changing w_destination-stras.
          perform f_read using 'NRODEST'               changing v_aux.
          concatenate w_destination-stras  v_aux into w_destination-stras.
          clear v_aux.

          perform f_read using 'XLGRDEST'              changing w_destination-street.
          perform f_read using 'NRODEST'               changing w_destination-house_num1.
          perform f_read using 'CEPDEST'               changing w_destination-pstlz.

* Bairro
          perform f_read using 'XMUNDEST'              changing w_destination-ort01.

          perform f_read using 'XBAIRRODES'            changing w_destination-ort02.
* Estado
          perform f_read using 'UFDEST'                changing w_destination-regio.
* CNPJ
          perform f_read using 'CNPJDEST'              changing w_destination-cgc.
* IE
          perform f_read using 'IEDEST'                changing w_destination-stains.
          perform f_read using 'IEDEST'                changing w_destination-munins.

* Recebe o valor
          w_danfe-destination = w_destination.

* Transportador
          perform f_read using 'XNOMETRANS'            changing w_carrier-name1.
          perform f_read using 'CNPJTRANS'             changing w_carrier-cgc.
          perform f_read using 'XENDER'                changing w_carrier-stras.
          perform f_read using 'XMUNTRANS'             changing w_carrier-ort01.
          perform f_read using 'UFTRANS'               changing w_carrier-regio.
          perform f_read using 'IETRANS'               changing w_carrier-stains.
          perform f_read using 'QVOL'                  changing w_nota_fiscal-anzpk.
          perform f_read using 'MARCA'                 changing w_other-brand_vol.
          perform f_read using 'ESP'                   changing w_nota_fiscal-shpunt.
* Recebe o valor
          w_danfe-carrier = w_carrier.
          w_danfe-others  = w_other.

* DADOS NOTA FISCAL
          perform f_read using 'DHSAIENT'              changing v_aux.
          translate v_aux using '- '. condense v_aux no-gaps.
          w_nota_fiscal-docdat = v_aux.
          w_nota_fiscal-pstdat = v_aux.
          w_nota_fiscal-credat = v_aux.
          clear v_aux.

          perform f_read using 'DHEMI'                 changing v_aux.
          translate v_aux+11(8) using '- '. condense v_aux no-gaps.
          w_nota_fiscal-cretim = v_aux.
          clear v_aux.

          perform f_read using 'NATOP'                 changing w_nota_fiscal-cfop_text.
          w_danfe-nota_fiscal = w_nota_fiscal.
          perform f_read using 'ICMSTOTVBC'            changing w_nota_fiscal-icmsbase.
          perform f_read using 'VICMSTOT'              changing w_nota_fiscal-icmsval.
          perform f_read using 'VPRODTOT'              changing w_nota_fiscal-nfnett.
          perform f_read using 'ICMSVBRST'             changing w_nota_fiscal-icstbase.
          perform f_read using 'VICMSST'               changing w_nota_fiscal-icstval.
          perform f_read using 'VNF'                   changing w_nota_fiscal-nftot.
          perform f_read using 'VPRODTOT'              changing w_nota_fiscal-nfnet.
          perform f_read using 'VIPITOT'               changing w_nota_fiscal-ipival.
          perform f_read using 'PESOB'                 changing w_nota_fiscal-brgew.
          perform f_read using 'PESOL'                 changing w_nota_fiscal-ntgew.
          perform f_read using 'NNF'                   changing w_nota_fiscal-nfenum.
          perform f_read using 'VFRETETOT'             changing w_nota_fiscal-nffre.
          perform f_read using 'VSEGTOT'               changing w_nota_fiscal-nfins.
          perform f_read using 'VDESCTOT'              changing w_nota_fiscal-nfdis.
          perform f_read using 'VIPITOT'               changing w_nota_fiscal-ipival.


          w_nota_fiscal-nfe = 'X'.

* Recebe o valor
          w_danfe-nota_fiscal = w_nota_fiscal.


* Dados NFE
* Chave de acesso
          perform f_read using 'CHAVE'                 changing v_aux.
          w_nfe-regio = v_aux(2).
          w_nfe-nfyear = v_aux+2(2).
          w_nfe-nfmonth = v_aux+4(2).
          w_nfe-stcd1 = v_aux+6(14).
          w_nfe-model = v_aux+20(2).
          w_nfe-serie = v_aux+22(3).
          w_nfe-nfnum9 = v_aux+25(9).
          w_nfe-docnum9 = v_aux+34(9).
          w_nfe-cdv = v_aux+43(1).
          clear v_aux.
          w_nota_fiscal-series = w_nfe-serie.
          perform f_read using 'SERIES'                changing w_nota_fiscal-series.
          perform f_read using 'NPROT'                 changing   w_nfe-authcod.
          perform f_read using 'DHRECBTO'              changing   v_aux.
          translate v_aux(10) using '- '. condense v_aux no-gaps.
          w_nfe-authdate = v_aux.
          translate v_aux+11(8) using ': '. condense v_aux no-gaps.
          w_nfe-authtime = v_aux.
          clear v_aux.

* Receve o valor
          w_danfe-nfe = w_nfe.

* ITENS
          add 1 to v_dcitm.
          loop at it_docmn_danfe into wa_docmn_danfe where dcitm = v_dcitm.
            w_j_1bprnfli-itmnum = v_dcitm * 10.

* CONTROLE DE ITENS
            read table it_docmn_danfe into wa_docmn_danfe with key mneum = 'CPROD'
                                                       dcitm = v_dcitm.
            if sy-subrc ne 0.
              continue.
            endif.

            perform f_read_item using v_dcitm 'CPROD'  changing w_j_1bprnfli-matnr.
            perform f_read_item using v_dcitm 'XPROD'  changing w_j_1bprnfli-maktx.
            perform f_read_item using v_dcitm 'XMLNCM' changing w_j_1bprnfli-nbm.
            perform f_read_item using v_dcitm 'CFOP'   changing v_aux.
            w_j_1bprnfli-cfop = v_aux(7).
            translate w_j_1bprnfli-cfop using '/ '. condense w_j_1bprnfli-cfop no-gaps.
            clear v_aux.

            perform f_read_item using v_dcitm 'UCOM'   changing w_j_1bprnfli-nfunt.
            call function 'CONVERSION_EXIT_CUNIT_INPUT'
              exporting
                input          = w_j_1bprnfli-nfunt
                language       = sy-langu
              importing
                output         = w_j_1bprnfli-nfunt
              exceptions
                unit_not_found = 1
                others         = 2.
            if sy-subrc <> 0.
            endif.
            w_j_1bprnfli-meins = w_j_1bprnfli-nfunt.

*    PERFORM f_read_item USING v_dcitm 'UCOM' CHANGING w_j_1bprnfli-meins.
            perform f_read_item using v_dcitm 'QCOM'   changing w_j_1bprnfli-menge.
            perform f_read_item using v_dcitm 'QCOM'   changing w_j_1bprnfli-nfqty.
            perform f_read_item using v_dcitm 'VUNCOM' changing w_j_1bprnfli-netpr.
            perform f_read_item using v_dcitm 'VPROD'  changing w_j_1bprnfli-netwr.
            perform f_read_item using v_dcitm 'VUNCOM' changing w_j_1bprnfli-nfpri.
            perform f_read_item using v_dcitm 'VPROD'  changing w_j_1bprnfli-nfnet.
            perform f_read_item using v_dcitm 'PICMS'  changing w_j_1bprnfli-icmsrate.
            perform f_read_item using v_dcitm 'VICMS'  changing w_j_1bprnfli-icmsval.
            perform f_read_item using v_dcitm 'VIPI'   changing w_j_1bprnfli-ipival.
            perform f_read_item using v_dcitm 'PIPI'   changing w_j_1bprnfli-ipirate.

            add 1 to v_dcitm.
            append w_j_1bprnfli to w_danfe-item.
            clear w_j_1bprnfli.
          endloop.

* INVOICE
*  w_invoice-txt02 = 'teste texto'.

          append w_invoice to w_danfe-invoice.
          .
        endif.

* TEXT
        perform f_read using 'INFADIC'                  changing v_aux.
        w_text = v_aux(132).
        append w_text to w_danfe-text1.
        clear w_text.
        if v_aux+132(68) is not initial.
          w_text = v_aux+132(68).
          append w_text to w_danfe-text1.
          clear w_text.
        endif.

        call function 'SSF_FUNCTION_MODULE_NAME'
          exporting
            formname           = 'Z_NFDANFE_PORTRAIT_SAP_CTE'
          importing
            fm_name            = fm_name
          exceptions
            no_form            = 1
            no_function_module = 2.





*      break rsantos.
*      ls_control_param-getotf = 'X'.
*      ls_control_param-no_dialog = 'X'.

*output_options-tdimmed       = nast-dimme.
*output_options-tddest        = nast-ldest.

        control_parameters-no_dialog  = 'X'.
        control_parameters-getotf     = 'X'.
        control_parameters-device     = 'PRINTER'.

        output_options-tddest         = 'LOCL'.
        output_options-tdnoprint      = 'X'.

        call function fm_name
          exporting
            control_parameters = control_parameters
            output_options     = output_options
            user_settings      = ''
            nota_fiscal        = w_danfe
            v_contingkey       = v_contingkey
            v_nfe              = v_nfe
            v_nfe1             = v_nfe1
          importing
            job_output_info    = l_job_output_info
          exceptions
            formatting_error   = 1
            internal_error     = 2
            send_error         = 3
            user_canceled      = 4
            others             = 5.

        if sy-subrc <> 0.
        endif.

        call function 'CONVERT_OTF'
          exporting
            format                = 'PDF'
          importing
            bin_filesize          = pdf_fsize
          tables
            otf                   = l_job_output_info-otfdata
            lines                 = lt_pdf
          exceptions
            err_max_linewidth     = 1
            err_format            = 2
            err_conv_not_possible = 3
            others                = 4.

* convert pdf to xstring string
        loop at lt_pdf into ls_pdf.
          assign ls_pdf to <fs_x> casting.
          concatenate lv_content <fs_x> into lv_content in byte mode.
        endloop.

* Convert xstring to binary table to pass to the LOAD_DATA method
        call function 'SCMS_XSTRING_TO_BINARY'
          exporting
            buffer     = lv_content
          tables
            binary_tab = lt_data.

* Load the HTML
        call method ob_pdf_docs->load_data(
          exporting
            type                 = 'application'
            subtype              = 'pdf'
          importing
            assigned_url         = lv_url
          changing
            data_table           = lt_data
          exceptions
            dp_invalid_parameter = 1
            dp_error_general     = 2
            cntl_error           = 3
            others               = 4 ).






      else.
        clear: it_docmn_danfe, wa_docmn_danfe.

        select *
          from zhms_tb_docmn
          into table it_docmn_danfe
          where chave = vg_chave.

        if sy-subrc eq 0.

* ISSUER ( EMITENTE )
          perform f_read using 'XNOME'                 changing w_issuer-name1.
* Endereço
          perform f_read using 'XLGR'                  changing w_issuer-stras.
          perform f_read using 'NRO'                   changing v_aux.
          concatenate w_issuer-stras  v_aux into w_issuer-stras.
          clear v_aux.

          perform f_read using 'XLGR'                  changing w_issuer-street.
          perform f_read using 'NRO'                   changing w_issuer-house_num1.
          perform f_read using 'CEP'                   changing w_issuer-pstlz.

* Bairro
          perform f_read using 'XMUN'                  changing w_issuer-ort01.

          perform f_read using 'XBAIRRO'               changing w_issuer-ort02.
* Estado
          perform f_read using 'UF'                    changing w_issuer-regio.
* CNPJ
          perform f_read using 'CNPJ'                  changing w_issuer-cgc.
* IE
          perform f_read using 'IE'                    changing w_issuer-stains.
          perform f_read using 'IE'                    changing w_issuer-munins.
          perform f_read using 'IEST'                  changing w_issuer-state_insc.

* Recebe o valor
          w_danfe-issuer = w_issuer.

* DESTINATARIO
* Nome empresa
          perform f_read using 'XNOMEDEST'             changing w_destination-name1.
* Endereço
          perform f_read using 'XLGRDEST'              changing w_destination-stras.
          perform f_read using 'NRODEST'               changing v_aux.
          concatenate w_destination-stras  v_aux into w_destination-stras.
          clear v_aux.

          perform f_read using 'XLGRDEST'              changing w_destination-street.
          perform f_read using 'NRODEST'               changing w_destination-house_num1.
          perform f_read using 'CEPDEST'               changing w_destination-pstlz.

* Bairro
          perform f_read using 'XMUNDEST'              changing w_destination-ort01.

          perform f_read using 'XBAIRRODES'            changing w_destination-ort02.
* Estado
          perform f_read using 'UFDEST'                changing w_destination-regio.
* CNPJ
          perform f_read using 'CNPJDEST'              changing w_destination-cgc.
* IE
          perform f_read using 'IEDEST'                changing w_destination-stains.
          perform f_read using 'IEDEST'                changing w_destination-munins.

* Recebe o valor
          w_danfe-destination = w_destination.

* Transportador
          perform f_read using 'XNOMETRANS'            changing w_carrier-name1.
          perform f_read using 'CNPJTRANS'             changing w_carrier-cgc.
          perform f_read using 'XENDER'                changing w_carrier-stras.
          perform f_read using 'XMUNTRANS'             changing w_carrier-ort01.
          perform f_read using 'UFTRANS'               changing w_carrier-regio.
          perform f_read using 'IETRANS'               changing w_carrier-stains.
          perform f_read using 'QVOL'                  changing w_nota_fiscal-anzpk.
          perform f_read using 'MARCA'                 changing w_other-brand_vol.
          perform f_read using 'ESP'                   changing w_nota_fiscal-shpunt.
* Recebe o valor
          w_danfe-carrier = w_carrier.
          w_danfe-others  = w_other.

* DADOS NOTA FISCAL
          perform f_read using 'DHSAIENT'              changing v_aux.
          translate v_aux using '- '. condense v_aux no-gaps.
          w_nota_fiscal-docdat = v_aux.
          w_nota_fiscal-pstdat = v_aux.
          w_nota_fiscal-credat = v_aux.
          clear v_aux.

          perform f_read using 'DHEMI'                 changing v_aux.
          translate v_aux+11(8) using '- '. condense v_aux no-gaps.
          w_nota_fiscal-cretim = v_aux.
          clear v_aux.

          perform f_read using 'NATOP'                 changing w_nota_fiscal-cfop_text.
          w_danfe-nota_fiscal = w_nota_fiscal.
          perform f_read using 'ICMSTOTVBC'            changing w_nota_fiscal-icmsbase.
          perform f_read using 'VICMSTOT'              changing w_nota_fiscal-icmsval.
          perform f_read using 'VPRODTOT'              changing w_nota_fiscal-nfnett.
          perform f_read using 'ICMSVBRST'             changing w_nota_fiscal-icstbase.
          perform f_read using 'VICMSST'               changing w_nota_fiscal-icstval.
          perform f_read using 'VNF'                   changing w_nota_fiscal-nftot.
          perform f_read using 'VPRODTOT'              changing w_nota_fiscal-nfnet.
          perform f_read using 'VIPITOT'               changing w_nota_fiscal-ipival.
          perform f_read using 'PESOB'                 changing w_nota_fiscal-brgew.
          perform f_read using 'PESOL'                 changing w_nota_fiscal-ntgew.
          perform f_read using 'NNF'                   changing w_nota_fiscal-nfenum.
          perform f_read using 'VFRETETOT'             changing w_nota_fiscal-nffre.
          perform f_read using 'VSEGTOT'               changing w_nota_fiscal-nfins.
          perform f_read using 'VDESCTOT'              changing w_nota_fiscal-nfdis.
          perform f_read using 'VIPITOT'               changing w_nota_fiscal-ipival.


          w_nota_fiscal-nfe = 'X'.

* Recebe o valor
          w_danfe-nota_fiscal = w_nota_fiscal.


* Dados NFE
* Chave de acesso
          perform f_read using 'CHAVE'                 changing v_aux.
          w_nfe-regio = v_aux(2).
          w_nfe-nfyear = v_aux+2(2).
          w_nfe-nfmonth = v_aux+4(2).
          w_nfe-stcd1 = v_aux+6(14).
          w_nfe-model = v_aux+20(2).
          w_nfe-serie = v_aux+22(3).
          w_nfe-nfnum9 = v_aux+25(9).
          w_nfe-docnum9 = v_aux+34(9).
          w_nfe-cdv = v_aux+43(1).
          clear v_aux.
          w_nota_fiscal-series = w_nfe-serie.
          perform f_read using 'SERIES'                changing w_nota_fiscal-series.
          perform f_read using 'NPROT'                 changing   w_nfe-authcod.
          perform f_read using 'DHRECBTO'              changing   v_aux.
          translate v_aux(10) using '- '. condense v_aux no-gaps.
          w_nfe-authdate = v_aux.
          translate v_aux+11(8) using ': '. condense v_aux no-gaps.
          w_nfe-authtime = v_aux.
          clear v_aux.

* Receve o valor
          w_danfe-nfe = w_nfe.

* ITENS
          add 1 to v_dcitm.
          loop at it_docmn_danfe into wa_docmn_danfe where dcitm = v_dcitm.
            w_j_1bprnfli-itmnum = v_dcitm * 10.

* CONTROLE DE ITENS
            read table it_docmn_danfe into wa_docmn_danfe with key mneum = 'CPROD'
                                                       dcitm = v_dcitm.
            if sy-subrc ne 0.
              continue.
            endif.

            perform f_read_item using v_dcitm 'CPROD'  changing w_j_1bprnfli-matnr.
            perform f_read_item using v_dcitm 'XPROD'  changing w_j_1bprnfli-maktx.
            perform f_read_item using v_dcitm 'XMLNCM' changing w_j_1bprnfli-nbm.
            perform f_read_item using v_dcitm 'CFOP'   changing v_aux.
            w_j_1bprnfli-cfop = v_aux(7).
            translate w_j_1bprnfli-cfop using '/ '. condense w_j_1bprnfli-cfop no-gaps.
            clear v_aux.

            perform f_read_item using v_dcitm 'UCOM'   changing w_j_1bprnfli-nfunt.
            call function 'CONVERSION_EXIT_CUNIT_INPUT'
              exporting
                input          = w_j_1bprnfli-nfunt
                language       = sy-langu
              importing
                output         = w_j_1bprnfli-nfunt
              exceptions
                unit_not_found = 1
                others         = 2.
            if sy-subrc <> 0.
            endif.
            w_j_1bprnfli-meins = w_j_1bprnfli-nfunt.

*    PERFORM f_read_item USING v_dcitm 'UCOM' CHANGING w_j_1bprnfli-meins.
            perform f_read_item using v_dcitm 'QCOM'   changing w_j_1bprnfli-menge.
            perform f_read_item using v_dcitm 'QCOM'   changing w_j_1bprnfli-nfqty.
            perform f_read_item using v_dcitm 'VUNCOM' changing w_j_1bprnfli-netpr.
            perform f_read_item using v_dcitm 'VPROD'  changing w_j_1bprnfli-netwr.
            perform f_read_item using v_dcitm 'VUNCOM' changing w_j_1bprnfli-nfpri.
            perform f_read_item using v_dcitm 'VPROD'  changing w_j_1bprnfli-nfnet.
            perform f_read_item using v_dcitm 'PICMS'  changing w_j_1bprnfli-icmsrate.
            perform f_read_item using v_dcitm 'VICMS'  changing w_j_1bprnfli-icmsval.
            perform f_read_item using v_dcitm 'VIPI'   changing w_j_1bprnfli-ipival.
            perform f_read_item using v_dcitm 'PIPI'   changing w_j_1bprnfli-ipirate.

            add 1 to v_dcitm.
            append w_j_1bprnfli to w_danfe-item.
            clear w_j_1bprnfli.
          endloop.

* INVOICE
*  w_invoice-txt02 = 'teste texto'.

          append w_invoice to w_danfe-invoice.
          .
        endif.

* TEXT
        perform f_read using 'INFADIC'                  changing v_aux.
        w_text = v_aux(132).
        append w_text to w_danfe-text1.
        clear w_text.
        if v_aux+132(68) is not initial.
          w_text = v_aux+132(68).
          append w_text to w_danfe-text1.
          clear w_text.
        endif.

        call function 'SSF_FUNCTION_MODULE_NAME'
          exporting
            formname           = 'Z_NFDANFE_PORTRAIT_SAP'
          importing
            fm_name            = fm_name
          exceptions
            no_form            = 1
            no_function_module = 2.





*      break rsantos.
*      ls_control_param-getotf = 'X'.
*      ls_control_param-no_dialog = 'X'.

*output_options-tdimmed       = nast-dimme.
*output_options-tddest        = nast-ldest.

        control_parameters-no_dialog  = 'X'.
        control_parameters-getotf     = 'X'.
        control_parameters-device     = 'PRINTER'.

        output_options-tddest         = 'LOCL'.
        output_options-tdnoprint      = 'X'.

        call function fm_name
          exporting
            control_parameters = control_parameters
            output_options     = output_options
            user_settings      = ''
            nota_fiscal        = w_danfe
            v_contingkey       = v_contingkey
            v_nfe              = v_nfe
            v_nfe1             = v_nfe1
          importing
            job_output_info    = l_job_output_info
          exceptions
            formatting_error   = 1
            internal_error     = 2
            send_error         = 3
            user_canceled      = 4
            others             = 5.

        if sy-subrc <> 0.
        endif.

        call function 'CONVERT_OTF'
          exporting
            format                = 'PDF'
          importing
            bin_filesize          = pdf_fsize
          tables
            otf                   = l_job_output_info-otfdata
            lines                 = lt_pdf
          exceptions
            err_max_linewidth     = 1
            err_format            = 2
            err_conv_not_possible = 3
            others                = 4.

* convert pdf to xstring string
        loop at lt_pdf into ls_pdf.
          assign ls_pdf to <fs_x> casting.
          concatenate lv_content <fs_x> into lv_content in byte mode.
        endloop.

* Convert xstring to binary table to pass to the LOAD_DATA method
        call function 'SCMS_XSTRING_TO_BINARY'
          exporting
            buffer     = lv_content
          tables
            binary_tab = lt_data.

* Load the HTML
        call method ob_pdf_docs->load_data(
          exporting
            type                 = 'application'
            subtype              = 'pdf'
          importing
            assigned_url         = lv_url
          changing
            data_table           = lt_data
          exceptions
            dp_invalid_parameter = 1
            dp_error_general     = 2
            cntl_error           = 3
            others               = 4 ).
      endif.

** Rodolfo Caruzo - 03/04/2018 - Início
*      READ TABLE it_docmn_danfe WITH KEY mneum = 'CODVERIF'
*                                TRANSPORTING NO FIELDS.
*
*      IF sy-subrc IS INITIAL.
*
*        READ TABLE it_docmn_danfe INTO wa_docmn_danfe WITH KEY mneum = 'NUMERO'.
*
*        SELECT SINGLE diretorio
*          FROM zhms_tb_danfe
*          INTO vg_diretorio
*         WHERE tipo EQ 'NFSE'.
*
*      ELSE.
*
*        READ TABLE it_docmn_danfe INTO wa_docmn_danfe WITH KEY mneum = 'NNF'.
*
*        SELECT SINGLE diretorio
*          FROM zhms_tb_danfe
*          INTO vg_diretorio
*         WHERE tipo EQ 'NFE'.
*
*      ENDIF.
*
*      CONCATENATE vg_diretorio wa_docmn_danfe-value '.pdf' INTO vg_diretorio.
*
*      CONCATENATE 'C:\temp\' wa_docmn_danfe-value '.pdf' INTO vg_dir_temp.
*
*      CALL FUNCTION 'ARCHIVFILE_SERVER_TO_CLIENT'
*        EXPORTING
*          path       = vg_diretorio
*          targetpath = vg_dir_temp
*        EXCEPTIONS
*          error_file = 1
*          OTHERS     = 2.
*
*      vg_edurl = vg_dir_temp.
** Rodolfo Caruzo - 03/04/2018 - Fim

      vg_edurl = lv_url.
      if not vg_edurl is initial.
***     Exibindo documento de PDF
        call method ob_pdf_docs->show_url
          exporting
            url                  = vg_edurl
*           in_place             = 'X'
          exceptions
            cnht_error_parameter = 1
            others               = 2.

        if sy-subrc ne 0.
***       Erro Interno. Contatar Suporte.
          message e000 with text-000.
          stop.
        endif.
      endif.

    endform.                    " F_MONTA_DANFE

*&---------------------------------------------------------------------*
*&      Form  F_READ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_XNOME  text
*      <--P_W_ISSUER_NAME1  text
*----------------------------------------------------------------------*
    form f_read  using    p_xnome
                 changing p_w_issuer_name1.

      read table it_docmn_danfe into wa_docmn_danfe with key mneum = p_xnome.
      if sy-subrc eq 0.
        p_w_issuer_name1 = wa_docmn_danfe-value.
      endif.
    endform.                    " F_READ

*&---------------------------------------------------------------------*
*&      Form  F_READ_ITEM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_DCITM  text
*      -->P_0348   text
*      <--P_W_J_1BPRNFLI_MATNR  text
*----------------------------------------------------------------------*
    form f_read_item  using    p_v_dcitm
                         value(p_0348)
                      changing p_w_j_1bprnfli_matnr.
      read table it_docmn_danfe into wa_docmn_danfe with key mneum = p_0348
                                                 dcitm = p_v_dcitm.
      if sy-subrc eq 0.
        p_w_j_1bprnfli_matnr = wa_docmn_danfe-value.
      endif.
    endform.                    " F_READ_ITEM

*&---------------------------------------------------------------------*
*&      Form  HANDEL_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
    form handel_hotspot_click  using    p_e_row_id
                                        p_e_column_id.

      data: t_dyfld type standard table of dynpread,
            l_dyfld type dynpread.

*      break rsantos.
      clear: t_alv_ped_aux, t_alv_comp_au.
      if p_e_column_id = 'IMPO'.
        read table t_alv_xml into wa_alv_xml index p_e_row_id.
        if sy-subrc eq 0.
          read table t_docmn_rep into wa_docmn_rep with key atitm = wa_alv_xml-item
                                                            mneum = 'ATPED'.
          if sy-subrc eq 0.

            set parameter id 'BES' field wa_docmn_rep-value.
            call transaction 'ME23N' and skip first screen.

          endif.
        endif.
      else.
* Comparações simples
        read table t_alv_xml into wa_alv_xml index p_e_row_id.
        if sy-subrc eq 0.
          loop at t_alv_comp into wa_alv_comp where item = wa_alv_xml-item.
            append wa_alv_comp to t_alv_comp_au.
          endloop.
        endif.

* Comparações de impostos
        read table t_alv_xml into wa_alv_xml index p_e_row_id.
        if sy-subrc eq 0.
          loop at t_alv_ped into wa_alv_ped where item = wa_alv_xml-item.
            append wa_alv_ped to t_alv_ped_aux.
          endloop.
        endif.
      endif.

    endform.                    " HANDEL_HOTSPOT_CLICK
*-----------------------------------------------------------------*
*       Insere Linha na tabela BDC
*-----------------------------------------------------------------*
    form z_gera_batch using  p_dynbegin type c
                            p_name type fnam_____4
                            p_dynpro.
      clear t_bdc1.
      if p_dynbegin ='X'.
        t_bdc1-dynbegin = p_dynbegin.
        t_bdc1-program  = p_name.
        t_bdc1-dynpro   =  p_dynpro.
      else.
        t_bdc1-fnam    = p_name.
        move p_dynpro to t_bdc1-fval.
      endif.
      append t_bdc1.
      clear t_bdc1.

    endform. "z_gera_tela
*&---------------------------------------------------------------------*
*&      Form  F_GRAVA_BATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
    form f_grava_batch tables lt_mess   using: ls_mess type bdcmsgcoll
                                               la_natdc
                                               la_typed
                                               la_loctp
                                               lv_chave.

      data: lt_logdoc type standard table of zhms_tb_logdoc,
            ls_logdoc like line of lt_logdoc.

      loop at lt_mess into ls_mess.
        move: la_natdc             to ls_logdoc-natdc,
              la_typed             to ls_logdoc-typed,
              la_loctp             to ls_logdoc-loctp,
              lv_chave             to ls_logdoc-chave,
              1                    to ls_logdoc-seqnr,
              sy-datum             to ls_logdoc-dtreg,
              sy-uzeit             to ls_logdoc-hrreg,
              sy-uname             to ls_logdoc-uname,
              ls_mess-msgid        to ls_logdoc-logid,
              ls_mess-msgtyp       to ls_logdoc-logty,
              ls_mess-msgnr        to ls_logdoc-logno,
              ls_mess-msgv1        to ls_logdoc-logv1,
              ls_mess-msgv2        to ls_logdoc-logv1,
              ls_mess-msgv3        to ls_logdoc-logv2.
        append ls_logdoc to lt_logdoc.
        clear ls_logdoc.

      endloop.

      modify zhms_tb_logdoc from table lt_logdoc.

      if sy-subrc is initial.
        commit work.
      else.
        rollback work.
      endif.

    endform.                    " F_GRAVA_BATCH
