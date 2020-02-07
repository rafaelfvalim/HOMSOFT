*----------------------------------------------------------------------*
*                      H  o  m  S  o  f  t                             *
*          Gestão Eletrônica de Documentos e Processos                 *
*----------------------------------------------------------------------*
* Descrição: Monitor Central de Gerenciamento de Documentos            *
*            Módulo PBO                                                *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*   Module  M_STATUS_0100  OUTPUT
*----------------------------------------------------------------------*
*   Botões e Menus da Tela 0100
*----------------------------------------------------------------------*
    module m_status_0100 output.

      select single * from zhms_tb_show_lay into ls_show_lay where ativo eq 'X'.

      if vg_0100 eq '0110'.
        append: 'INDEX' to t_codes.
      endif.

      set pf-status '0100' excluding t_codes.

      if ls_show_lay-tipo eq 'NDD'.
        set titlebar  '0201'.
      else.
        set titlebar  '0100'.
      endif.
    endmodule.                 " M_STATUS_0100  OUTPUT

*----------------------------------------------------------------------*
*   Module  M_LOAD_HTML_INDEX  OUTPUT
*----------------------------------------------------------------------*
*   Carregando Objeto HTML do Índice
*----------------------------------------------------------------------*
    module m_load_html_index output.
      if ob_cc_html_index is initial.
***     Criando objeto de container
        create object ob_cc_html_index
          exporting
            container_name = 'CC_HTML_INDEX'
          exceptions
            others         = 1.

        if sy-subrc ne 0.
***       Erro Interno. Contatar Suporte.
          message e000 with text-000.
          stop.
        endif.
      endif.

      if ob_html_index is initial.
***     Criando Objeto HTML - Índice
        create object ob_html_index
          exporting
            parent             = ob_cc_html_index
          exceptions
            cntl_error         = 1
            cntl_install_error = 2
            dp_install_error   = 3
            dp_error           = 4
            others             = 5.

        if sy-subrc ne 0.
***       Erro Interno. Contatar Suporte
          message e000 with text-000.
          stop.
        else.
***       Selecionando dados do Índice
          perform f_sel_index_nfs.
***       Registrando Eventos do HTML Index
          perform f_reg_events_index.
***       Carregando Ícone Padrão
          perform f_load_images using 'S_RANEUT' 'S_RANEUT.GIF'.
***       Carregando Bibliotecas JavaScript
          perform f_load_images using 'ZHMS_JQUERY_MIN'     'JQUERY_MIN.JS'.
          perform f_load_images using 'ZHMS_JSCROLLPANE'    'JSCROLLPANE.JS'.
          perform f_load_images using 'ZHMS_MOUSEWHEEL'     'MOUSEWHEEL.JS'.
          perform f_load_images using 'ZHMS_JSCROLLPANECSS' 'JSCROLLPANECSS.CSS'.

          refresh t_srscd.
          clear   wa_srscd.

***       Obtendo Fonte HTML
          call function 'ZHMS_FM_GET_HTML_INDEX'
            tables
              index  = t_index
              srscd  = t_srscd
            exceptions
              error  = 1
              others = 2.

          if sy-subrc eq 0  and not t_srscd[] is initial.
            loop at t_srscd into wa_srscd.
              append wa_srscd to t_srscd_ev.
            endloop.

            if not t_srscd_ev is initial.
***           Preparando dados para Exibição do Índice
              clear vg_url.
              ob_html_index->load_data( importing assigned_url = vg_url
                                        changing  data_table   = t_srscd_ev ).

***           Exibindo Índice
              ob_html_index->show_url( url = vg_url ).
            else.
***           Erro Interno. Contatar Suporte.
              message e000 with text-000.
              stop.
            endif.
          endif.
        endif.
      endif.
    endmodule.                 " M_LOAD_HTML_INDEX  OUTPUT

*----------------------------------------------------------------------*
*   Module  M_LOAD_LOGO_HOMSOFT  OUTPUT
*----------------------------------------------------------------------*
*   Carregando Logotipo HomSoft
*----------------------------------------------------------------------*
    module m_load_logo_homsoft output.
      if ob_cc_logotipo is initial.

***     Criando Objeto de Container para Logo
        create object ob_cc_logotipo
          exporting
            container_name              = 'CC_LOGOTIPO'
          exceptions
            cntl_error                  = 1
            cntl_system_error           = 2
            create_error                = 3
            lifetime_error              = 4
            lifetime_dynpro_dynpro_link = 5
            others                      = 6.

        if sy-subrc ne 0.
***       Erro Interno. Contatar Suporte.
          message e000 with text-000.
          stop.
        endif.
      endif.

      if ob_logotipo is initial.
***     Criando Objeto de Picture Control
        create object ob_logotipo
          exporting
            parent = ob_cc_logotipo
          exceptions
            error  = 1
            others = 2.

        if sy-subrc ne 0.
***       Erro Interno. Contatar Suporte.
          message e000 with text-000.
          stop.
        else.
***       Setando Método de Exibição
          call method ob_logotipo->set_display_mode
            exporting
              display_mode = cl_gui_picture=>display_mode_normal_center
            exceptions
              error        = 1
              others       = 2.

          if sy-subrc ne 0.
***         Erro Interno. Contatar Suporte.
            message e000 with text-000.
            stop.
          endif.

          select single * from zhms_tb_show_lay into ls_show_lay where ativo eq 'X'.

          if ls_show_lay-tipo eq 'NDD'.
***       Carregando URL
            clear vg_url.
            call function 'DP_PUBLISH_WWW_URL'
              exporting
                objid    = 'ZHMS_NDD_LOGO2'
                lifetime = cndp_lifetime_transaction
              importing
                url      = vg_url
              exceptions
                others   = 1.
          else.
***       Carregando URL
            clear vg_url.
            call function 'DP_PUBLISH_WWW_URL'
              exporting
                objid    = 'ZHMS_LOGO'
                lifetime = cndp_lifetime_transaction
              importing
                url      = vg_url
              exceptions
                others   = 1.
          endif.

          if sy-subrc ne 0.
***         Erro Interno. Contatar Suporte.
            message e000 with text-000.
            stop.
          else.
***         Carregando Imagem na Tela
            call method ob_logotipo->load_picture_from_url_async
              exporting
                url    = vg_url
              exceptions
                error  = 1
                others = 2.

            if sy-subrc ne 0.
***           Erro Interno. Contatar Suporte.
              message e000 with text-000.
              stop.
            endif.
          endif.
        endif.
      endif.
    endmodule.                 " M_LOAD_LOGO_HOMSOFT  OUTPUT

*----------------------------------------------------------------------*
*   Module  M_LOAD_HTML_DOCS  OUTPUT
*----------------------------------------------------------------------*
*   Carregando Objeto HTML dos Documentos
*----------------------------------------------------------------------*
    module m_load_html_docs output.
      data vl_chave type zhms_de_chave.

      if ob_cc_html_docs is initial.
***     Criando objeto de container
        create object ob_cc_html_docs
          exporting
            container_name = 'CC_HTML_DOCS'
          exceptions
            others         = 1.

        if sy-subrc ne 0.
***       Erro Interno. Contatar Suporte.
          message e000 with text-000.
          stop.
        endif.
      endif.

      if ob_html_docs is initial.
        clear vg_screen_call.

***     Criando Objeto HTML - Índice com JavaScript
        create object ob_html_docs
          exporting
            parent = ob_cc_html_docs.

        if sy-subrc ne 0.
***       Erro Interno. Contatar Suporte
          message e000 with text-000.
          stop.
        else.
***       Registrando Eventos do HTML Documentos
          perform f_reg_events_docs.
***       Carregando Ícone Padrão
          perform f_load_images_docs using 'S_RANEUT' 'S_RANEUT.GIF'.

***       Carregando Bibliotecas JavaScript
          refresh t_wwwdata.
          clear wa_wwwdata.

          select * into table t_wwwdata
                   from wwwdata
                   where objid like 'ZHMS%'
                     and srtf2 eq 0.

          loop at t_wwwdata into wa_wwwdata.
            perform f_load_images_docs using wa_wwwdata-objid
                                             wa_wwwdata-text.
          endloop.

          refresh: t_srscd, t_srscd_ev.
          clear:   wa_srscd.

***       Obtendo Fonte HTML
          call function 'ZHMS_FM_GET_HTML_DOCS'
            tables
              param  = t_param
              docst  = t_docst
              docrf  = t_docrf_es
              srscd  = t_srscd
            exceptions
              error  = 1
              others = 2.

          if sy-subrc eq 0  and not t_srscd[] is initial.
            loop at t_srscd into wa_srscd.
              append wa_srscd to t_srscd_ev.
            endloop.

            if not t_srscd_ev is initial.
***           Preparando dados para Exibição do Índice
              clear vg_url.
              ob_html_docs->load_data( importing assigned_url = vg_url
                                       changing  data_table   = t_srscd_ev ).

***           Exibindo Índice
              ob_html_docs->show_url( url = vg_url ).
            else.
***           Erro Interno. Contatar Suporte.
              message e000 with text-000.
              stop.
            endif.
          endif.
        endif.
      else.
        check vg_screen_call eq 'X'.

        clear vg_screen_call.

        refresh: t_srscd, t_srscd_ev.
        clear:   wa_srscd.

***     Obtendo Fonte HTML
        call function 'ZHMS_FM_GET_HTML_DOCS'
          tables
            param  = t_param
            docst  = t_docst
            docrf  = t_docrf_es
            srscd  = t_srscd
          exceptions
            error  = 1
            others = 2.

        if sy-subrc eq 0  and not t_srscd[] is initial.
          loop at t_srscd into wa_srscd.
            append wa_srscd to t_srscd_ev.
          endloop.

          if not t_srscd_ev is initial.
***         Preparando dados para Exibição do Índice
            clear vg_url.
            ob_html_docs->load_data( importing assigned_url = vg_url
                                     changing  data_table   = t_srscd_ev ).

***         Exibindo Índice
            ob_html_docs->show_url( url = vg_url ).
          else.
***         Erro Interno. Contatar Suporte.
            message e000 with text-000.
            stop.
          endif.
        endif.
      endif.
    endmodule.                 " M_LOAD_HTML_DOCS  OUTPUT

*----------------------------------------------------------------------*
*   Module  M_LOAD_HTML_det  OUTPUT
*----------------------------------------------------------------------*
*   Carregando Objeto HTML dos Documentos
*----------------------------------------------------------------------*
    module m_load_html_det output.

      if ob_cc_html_det is initial.
***     Criando objeto de container
        create object ob_cc_html_det
          exporting
            container_name = 'CC_HTML_DET'
          exceptions
            others         = 1.

        if sy-subrc ne 0.
***       Erro Interno. Contatar Suporte.
          message e000 with text-000.
          stop.
        endif.
      endif.

      if ob_html_det is initial.
        data: tl_datasrc  type table of zhms_st_html_srscd,
              wal_datasrc type zhms_st_html_srscd.

***     Criando Objeto HTML - Índice com JavaScript
        create object ob_html_det
          exporting
            parent = ob_cc_html_det.

        if sy-subrc ne 0.
***       Erro Interno. Contatar Suporte
          message e000 with text-000.
          stop.
        else.
***       Registrando Eventos do HTML Documentos
          perform f_reg_events_det.

***       Carregando Bibliotecas JavaScript
          refresh t_wwwdata.
          clear wa_wwwdata.

          select * into table t_wwwdata
                   from wwwdata
                   where objid like 'ZHMS%'
                     and srtf2 eq 0.

          loop at t_wwwdata into wa_wwwdata.
            perform f_load_images_det using wa_wwwdata-objid
                                            wa_wwwdata-text.
          endloop.

          refresh: t_srscd, t_srscd_ev.
          clear:   wa_srscd.

***       Código para primeira execução
          perform f_show_document_det using 'X'.
          loop at t_datasrc into wa_datasrc.
            clear wal_datasrc.
            wal_datasrc-linsc = wa_datasrc.
            append wal_datasrc to tl_datasrc.
          endloop.


***       Obtendo Fonte HTML
          call function 'ZHMS_FM_GET_HTML_DET'
            tables
              srscd   = t_srscd
              datasrc = tl_datasrc
            exceptions
              error   = 1
              others  = 2.

          if sy-subrc eq 0  and not t_srscd[] is initial.
            loop at t_srscd into wa_srscd.
              append wa_srscd to t_srscd_ev.
            endloop.

            if not t_srscd_ev is initial.
***           Preparando dados para Exibição do Índice
              clear vg_url.
              ob_html_det->load_data( importing assigned_url = vg_url
                                       changing  data_table   = t_srscd_ev ).

***           Exibindo Índice
              ob_html_det->show_url( url = vg_url ).

            else.
***           Erro Interno. Contatar Suporte.
              message e000 with text-000.
              stop.
            endif.
          endif.
        endif.
*      ELSE.
*        CHECK vg_screen_call EQ 'X'.
*
*        CLEAR vg_screen_call.
*
*        REFRESH: t_srscd, t_srscd_ev.
*        CLEAR:   wa_srscd.
*
****     Obtendo Fonte HTML
*        CALL FUNCTION 'ZHMS_FM_GET_HLML_DET'
*          TABLES
*            srscd  = t_srscd
*          EXCEPTIONS
*            error  = 1
*            OTHERS = 2.
*
*        IF sy-subrc EQ 0  AND NOT t_srscd[] IS INITIAL.
*          LOOP AT t_srscd INTO wa_srscd.
*            APPEND wa_srscd TO t_srscd_ev.
*          ENDLOOP.
*
*          IF NOT t_srscd_ev IS INITIAL.
****         Preparando dados para Exibição do Índice
*            CLEAR vg_url.
*            ob_html_det->load_data( IMPORTING assigned_url = vg_url
*                                     CHANGING  data_table   = t_srscd_ev ).
*
****         Exibindo Índice
*            ob_html_det->show_url( url = vg_url ).
*
*          ELSE.
****         Erro Interno. Contatar Suporte.
*            MESSAGE e000 WITH text-000.
*            STOP.
*          ENDIF.
*        ENDIF.
      endif.

    endmodule.                 " M_LOAD_HTML_det  OUTPUT

*----------------------------------------------------------------------*
*  MODULE m_preenche_nota OUTPUT
*----------------------------------------------------------------------*
* Preenche dados da nota para primeira execução
*----------------------------------------------------------------------*
    module m_preenche_nota output.
***         Preenche dados
*      PERFORM f_show_document_det.
    endmodule.                    "m_preenche_nota OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       Logs para documentos
*----------------------------------------------------------------------*
    module m_status_0300 output.
      set pf-status '0300'.
      set titlebar  '0300'.
    endmodule.                 " STATUS_0300  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       Logs para documentos
*----------------------------------------------------------------------*
    module m_status_0200 output.
      set pf-status '0200'.
      set titlebar  '0200'.
    endmodule.                 " STATUS_0200  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0250  OUTPUT
*&---------------------------------------------------------------------*
*       Logs para documentos
*----------------------------------------------------------------------*
    module m_status_0250 output.
      set pf-status '0250'.
      set titlebar  '0250'.
    endmodule.                 " STATUS_0250  OUTPUT

*----------------------------------------------------------------------*
*  MODULE m_loadportarias OUTPUT
*----------------------------------------------------------------------*
* Carrega as portarias para o documento
*----------------------------------------------------------------------*
    module m_loadportarias output.
      if sy-ucomm ne 'PRT_SHOW'.
*     Carrega as portarias para o documento
        perform f_loadportarias.
      endif.

    endmodule.                    "m_loadportarias OUTPUT

*----------------------------------------------------------------------*
*   MODULE tc_logdoc_change_tc_attr OUTPUT
*----------------------------------------------------------------------*
*   Controlador de Índices TABLECONTROL
*----------------------------------------------------------------------*
    module tc_logdoc_change_tc_attr output.
      describe table t_logdoc_aux lines tc_logdoc-lines.
    endmodule.                    "TC_LOGDOC_CHANGE_TC_ATTR OUTPUT

*----------------------------------------------------------------------*
*  MODULE m_get_logs_doc OUTPUT
*----------------------------------------------------------------------*
*  Carregar dados de log para documento
*----------------------------------------------------------------------*
    module m_get_logs_doc output.
*     Limpar tabelas de logs
      refresh: t_logdoc, t_logdoc_aux.

*     Seleciona logs para documento
      if vg_flowd is initial.
        select *
                into table t_logdoc
                from zhms_tb_logdoc
               where natdc eq vg_natdc
                 and typed eq vg_typed
                 and loctp eq wa_cabdoc-loctp
                 and chave eq vg_chave.
      else.
        select *
              into table t_logdoc
              from zhms_tb_logdoc
             where natdc eq vg_natdc
               and typed eq vg_typed
               and loctp eq wa_cabdoc-loctp
               and chave eq vg_chave
               and flowd eq vg_flowd.
      endif.

*     Seleção por Data / Hora / Sequencia
      sort t_logdoc by dtreg descending
                       hrreg descending
                       seqnr descending.

*     Percorrer tabela de logs para tratamento
      loop at t_logdoc into wa_logdoc.
*       Mover dados para tabela de exibição
        move-corresponding wa_logdoc to wa_logdoc_aux.

*       Tratamento de Icones
        case wa_logdoc-logty.
          when 'E'.
            wa_logdoc_aux-icon = '@0A@'.
          when 'W'.
            wa_logdoc_aux-icon = '@09@'.
          when 'I'.
            wa_logdoc_aux-icon = '@08@'.
          when 'S'.
            wa_logdoc_aux-icon = '@01@'.
        endcase.
*       Seleciona o ID da mensagem
        if wa_logdoc-logid is initial.
          wa_logdoc-logid = 'ZHMS_MC_LOGDOC'.
        endif.
*       Busca log na classe de mensagem
        message id wa_logdoc-logid type wa_logdoc-logty number wa_logdoc-logno
                into wa_logdoc_aux-ltext
                with wa_logdoc-logv1 wa_logdoc-logv2 wa_logdoc-logv3 wa_logdoc-logv4.

*       Adiciona dados a tabela de exibição
        append wa_logdoc_aux to t_logdoc_aux.
      endloop.
    endmodule.                    "m_get_logs_doc OUTPUT

*----------------------------------------------------------------------*
*   Module  M_STATUS_0400  OUTPUT
*----------------------------------------------------------------------*
*   Botões e Menus da Tela 0400
*----------------------------------------------------------------------*
    module m_status_0400 output.
      set pf-status '0400'.
      set titlebar  '0400'.
    endmodule.                 " M_STATUS_0400  OUTPUT

*----------------------------------------------------------------------*
*   Module  M_STATUS_0500  OUTPUT
*----------------------------------------------------------------------*
*   Botões e Menus da Tela 0500
*----------------------------------------------------------------------*
    module m_status_0500 output.
      data: tl_codes       type table of sy-ucomm.

      set titlebar  '0500'.
      refresh tl_codes.

      if vg_0500 eq '0501'.
        append: 'ATR_GRAVAR' to tl_codes.
      endif.

      set pf-status '0500' excluding tl_codes.

    endmodule.                 " M_STATUS_0500  OUTPUT

*----------------------------------------------------------------------*
*   Module  M_SHOW_PDF_DOC  OUTPUT
*----------------------------------------------------------------------*
*   Exibindo PDF do Documento Selecionado
*----------------------------------------------------------------------*
    module m_show_pdf_doc output.
      check not vg_chave is initial.

      if ob_cc_pdf_docs is initial.
        create object ob_cc_pdf_docs
          exporting
            container_name = 'CC_PDFDOC'
          exceptions
            cntl_error     = 1
            others         = 2.

        if sy-subrc ne 0.
***       Erro Interno. Contatar Suporte.
          message e000 with text-000.
          stop.
        endif.
      endif.

      if ob_pdf_docs is initial.
***     Criando Objeto de HTML para PDF
        create object ob_pdf_docs
          exporting
            parent             = ob_cc_pdf_docs
          exceptions
            cntl_error         = 1
            cntl_install_error = 2
            others             = 3.

        if sy-subrc ne 0.
***       Erro Interno. Contatar Suporte.
          message e000 with text-000.
          stop.
        endif.
      else.
        call method ob_pdf_docs->free.
        clear ob_pdf_docs.

***     Criando Objeto de HTML para PDF
        create object ob_pdf_docs
          exporting
            parent             = ob_cc_pdf_docs
          exceptions
            cntl_error         = 1
            cntl_install_error = 2
            others             = 3.

        if sy-subrc ne 0.
***       Erro Interno. Contatar Suporte.
          message e000 with text-000.
          stop.
        endif.
      endif.

* Inicio - Ricardo Rodrigues -
* Danfe LOCAL
*      IF sy-uname = 'RSANTOS'.
      perform f_monta_danfe.
*      ELSE.
**      vg_edurl = lv_url.
*        vg_edurl = 'C:\Homsoft\PDF\DANFE.PDF'.
**      vg_edurl = 'Z:\HomSoft\PDF\DANFE.PDF'.
*        IF NOT vg_edurl IS INITIAL.
****     Exibindo documento de PDF
*          CALL METHOD ob_pdf_docs->show_url
*            EXPORTING
*              url                  = vg_edurl
**             in_place             = 'X'
*            EXCEPTIONS
*              cnht_error_parameter = 1
*              OTHERS               = 2.
*
*          IF sy-subrc NE 0.
****       Erro Interno. Contatar Suporte.
*            MESSAGE e000 WITH text-000.
*            STOP.
*          ENDIF.
*        ENDIF.
*      ENDIF.
* TESTE RICARDO


    endmodule.                 " M_SHOW_PDF_DOC  OUTPUT

*----------------------------------------------------------------------*
*   Module  M_SHOW_XML_DOCS  OUTPUT
*----------------------------------------------------------------------*
*   Exibindo XML do Documento
*----------------------------------------------------------------------*
    module m_show_xml_docs output.
**    Variáveis locais
      data: vl_error type flag.

      if not vg_chave_sel is initial.
        if vg_chave eq vg_chave_sel.
          vl_error = 'X'.
        else.
          clear vl_error.
        endif.
      endif.

      check vl_error is initial.
      check not vg_chave is initial.
      vg_chave_sel = vg_chave.

***   Carregando Estrutura de Campos
      perform f_build_fieldcat.

      if ob_cc_xml_docs is initial.
***     Criando Container para TREE do XML
        create object ob_cc_xml_docs
          exporting
            container_name              = 'CC_XML_DOCS'
          exceptions
            cntl_error                  = 1
            cntl_system_error           = 2
            create_error                = 3
            lifetime_error              = 4
            lifetime_dynpro_dynpro_link = 5.

        if sy-subrc ne 0.
***       Erro Interno. Contatar Suporte.
          message e000 with text-000.
          stop.
        endif.
      endif.

      if not ob_xml_docs is initial.

        call method ob_xml_docs->free
          exceptions
            cntl_error        = 1
            cntl_system_error = 2
            others            = 3.

      endif.

*      IF ob_xml_docs IS INITIAL.
***     Criando Objeto TREE para XML
      create object ob_xml_docs
        exporting
          parent                      = ob_cc_xml_docs
          node_selection_mode         = cl_gui_column_tree=>node_sel_mode_single
          item_selection              = 'X'
          no_html_header              = 'X'
          no_toolbar                  = ' '
        exceptions
          cntl_error                  = 1
          cntl_system_error           = 2
          create_error                = 3
          lifetime_error              = 4
          illegal_node_selection_mode = 5
          failed                      = 6
          illegal_column_name         = 7.

      if sy-subrc <> 0.
***       Erro Interno. Contatar Suporte.
        message e000 with text-000.
        stop.
      endif.
*      ENDIF.

***   Setando valores do Header da TREE
      perform f_build_hier_header.

      clear wa_variant.
      move  sy-repid to wa_variant-report.

***   create emty tree-control
      refresh t_xmlview.

      call method ob_xml_docs->set_table_for_first_display
        exporting
          is_hierarchy_header = wa_hier_header
          is_variant          = wa_variant
        changing
          it_outtab           = t_xmlview
          it_fieldcatalog     = t_fieldcat.
*      ELSE.
*
*        CALL METHOD ob_xml_docs->delete_all_nodes
*          EXCEPTIONS
*            failed            = 1
*            cntl_system_error = 2
*            OTHERS            = 3.
*        IF sy-subrc <> 0.
*          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*        ENDIF.
*
*      ENDIF.
***   Criando Hierarquia da TREE do XML
      perform f_create_hier.

      call method cl_gui_cfw=>flush
        exceptions
          cntl_system_error = 1
          cntl_error        = 2
          others            = 3.

      if sy-subrc <> 0.
***     Erro Interno. Contatar Suporte.
        message e000 with text-000.
      endif.
    endmodule.                 " M_SHOW_XML_DOCS  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  M_STATUS_0402  OUTPUT
*&---------------------------------------------------------------------*
*       Carregar dados de validação
*----------------------------------------------------------------------*
    module m_vld_showhist output.

**    Carregar dados de validação
      perform f_vld_selregs.

    endmodule.                 " M_STATUS_0402  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  M_STATUS_151  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    module m_status_151 output.
      if vg_chave is initial.
        clear wa_cabdoc.
      endif.
*vg_0151 = '0159'.
**    Conta documentos
      describe table t_chave lines vg_qtsel.

      if vg_qtsel eq 1.
**      Verifica se a tela atual pode ser modificada
        check vg_0151 eq '0160'.
**      Exibir tela com detalhes do documento
        vg_0151 = '0154'.
      else.
**      Exibir tela com nenhum ou mais de 1 documento selecionado
        vg_0151 = '0160'.
      endif.
    endmodule.                 " M_STATUS_151  OUTPUT

*----------------------------------------------------------------------*
*   Module  M_TOOLBAR_DOCS  OUTPUT
*----------------------------------------------------------------------*
*   Carregando TOOLBAR dos Documento
*----------------------------------------------------------------------*
    module m_toolbar_docs output.
      if ob_cc_tb_docs is initial.
***     Criando Objeto do Container da TOOLBAR
        create object ob_cc_tb_docs
          exporting
            container_name              = 'CC_TB_DOCS'
          exceptions
            cntl_error                  = 1
            cntl_system_error           = 2
            create_error                = 3
            lifetime_error              = 4
            lifetime_dynpro_dynpro_link = 5.

        if sy-subrc ne 0.
***       Erro Interno. Contatar Suporte.
          message a000 with text-000.
        endif.
      endif.

      if ob_tb_docs is initial.
***     Criando Objeto da TOOLBAR do Índice
        create object ob_tb_docs
          exporting
            parent = ob_cc_tb_docs.

        if sy-subrc ne 0.
***       Erro Interno. Contatar Suporte.
          message a000 with text-000.
        else.
***       Criando botões da TOOLBAR do Índice
          perform f_btns_tb_docs.
***       Registrando Eventos da TOOLBAR - Índice
          perform f_events_tb_docs.
        endif.
      else.
***     Excluíndo Botões para criação de novos
        call method ob_tb_docs->delete_all_buttons
          exceptions
            cntl_error = 1
            others     = 2.

        if sy-subrc eq 0.
***       Criando botões da TOOLBAR dos Documentos
          perform f_btns_tb_docs.
        endif.
      endif.
    endmodule.                 " M_TOOLBAR_DOCS  OUTPUT

*----------------------------------------------------------------------*
*   Module  M_TOOLBAR_DET  OUTPUT
*----------------------------------------------------------------------*
*   Carregando TOOLBAR do Detalhe
*----------------------------------------------------------------------*
    module m_toolbar_det output.
      if ob_cc_tb_det is initial.
***     Criando Objeto do Container da TOOLBAR
        create object ob_cc_tb_det
          exporting
            container_name              = 'CC_TB_DET'
          exceptions
            cntl_error                  = 1
            cntl_system_error           = 2
            create_error                = 3
            lifetime_error              = 4
            lifetime_dynpro_dynpro_link = 5.

        if sy-subrc ne 0.
***       Erro Interno. Contatar Suporte.
          message a000 with text-000.
        endif.
      endif.

      if ob_tb_det is initial.
***     Criando Objeto da TOOLBAR do Detalhe
        create object ob_tb_det
          exporting
            parent = ob_cc_tb_det.

        if sy-subrc ne 0.
***       Erro Interno. Contatar Suporte.
          message a000 with text-000.
        else.
***       Criando botões da TOOLBAR do Detalhe
          perform f_btns_tb_det.
***       Registrando Eventos da TOOLBAR - Índice
          perform f_events_tb_det.
        endif.
      else.
***     Excluíndo Botões para criação de novos
        call method ob_tb_det->delete_all_buttons
          exceptions
            cntl_error = 1
            others     = 2.

        if sy-subrc eq 0.
***       Criando botões da TOOLBAR dos Documentos
          perform f_btns_tb_det.
        endif.
      endif.
    endmodule.                 " M_TOOLBAR_DET  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  M_SHOW_DOCITENS  OUTPUT
*&---------------------------------------------------------------------*
*       Controles para ítens de documento
*----------------------------------------------------------------------*
    module m_show_docitens output.
      check not vg_chave is initial.

      if ob_vis_itens is not initial.
        call method ob_vis_itens->free.
        clear ob_vis_itens.
      endif.
      if ob_cc_vis_itens is not initial.
        call method ob_cc_vis_itens->free.
        clear ob_cc_vis_itens.
      endif.

***   Carregando Estrutura de Campos
      perform f_build_fieldcat_itens.

      if ob_cc_vis_itens is initial.
***     Criando Container para TREE do XML
        create object ob_cc_vis_itens
          exporting
            container_name              = 'CC_VIS_ITENS'
          exceptions
            cntl_error                  = 1
            cntl_system_error           = 2
            create_error                = 3
            lifetime_error              = 4
            lifetime_dynpro_dynpro_link = 5.

        if sy-subrc ne 0.
***       Erro Interno. Contatar Suporte.
          message e000 with text-000.
          stop.
        endif.
      endif.

**    Verifica existencia da tree
      if not ob_vis_itens is initial.
**      Caso exista, limpa os registros
        call method ob_vis_itens->delete_all_nodes
          exceptions
            failed            = 1
            cntl_system_error = 2
            others            = 3.
        if sy-subrc <> 0.
          message id sy-msgid type sy-msgty number sy-msgno
                     with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        endif.

      else.

***     Criando Objeto TREE para XML
        create object ob_vis_itens
          exporting
            parent                      = ob_cc_vis_itens
            node_selection_mode         = cl_gui_column_tree=>node_sel_mode_single
            item_selection              = 'X'
            no_html_header              = 'X'
            no_toolbar                  = 'X'
          exceptions
            cntl_error                  = 1
            cntl_system_error           = 2
            create_error                = 3
            lifetime_error              = 4
            illegal_node_selection_mode = 5
            failed                      = 6
            illegal_column_name         = 7.

        if sy-subrc <> 0.
***       Erro Interno. Contatar Suporte.
          message e000 with text-000.
          stop.
        endif.
      endif.

***   Setando valores do Header da TREE
      perform f_build_hier_header_itens.

      clear wa_variant.
      move  sy-repid to wa_variant-report.

***   create emty tree-control
      refresh t_itensview.

      call method ob_vis_itens->set_table_for_first_display
        exporting
          is_hierarchy_header = wa_hier_header
          is_variant          = wa_variant
        changing
          it_outtab           = t_itensview
          it_fieldcatalog     = t_fieldcatitm.

      refresh t_fieldcatitm.
      clear t_fieldcatitm.

***   Criando Hierarquia da TREE do XML
      perform f_create_hier_itens.

      call method cl_gui_cfw=>flush
        exceptions
          cntl_system_error = 1
          cntl_error        = 2
          others            = 3.

      if sy-subrc <> 0.
***     Erro Interno. Contatar Suporte.
        message e000 with text-000.
      endif.

      call method ob_vis_itens->column_optimize.

    endmodule.                 " M_SHOW_DOCITENS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  M_SHOW_ATRITENS  OUTPUT
*&---------------------------------------------------------------------*
*       Controles para ítens de documento - Atribuição
*----------------------------------------------------------------------*
    module m_show_atritens output.
      check not vg_chave is initial.

***   Carregando Estrutura de Campos
      perform f_build_fieldcat_itens.

      if ob_cc_atr_itens is initial.
***     Criando Container para TREE do XML
        create object ob_cc_atr_itens
          exporting
            container_name              = 'CC_ATR_ITENS'
          exceptions
            cntl_error                  = 1
            cntl_system_error           = 2
            create_error                = 3
            lifetime_error              = 4
            lifetime_dynpro_dynpro_link = 5.

        if sy-subrc ne 0.
***       Erro Interno. Contatar Suporte.
          message e000 with text-000.
          stop.
        endif.
      endif.

      if not ob_atr_itens is initial.

        call method ob_atr_itens->free
          exceptions
            cntl_error        = 1
            cntl_system_error = 2
            others            = 3.

      endif.

***     Criando Objeto TREE para XML
      create object ob_atr_itens
        exporting
          parent                      = ob_cc_atr_itens
          node_selection_mode         = cl_gui_column_tree=>node_sel_mode_single
          item_selection              = 'X'
          no_html_header              = 'X'
          no_toolbar                  = 'X'
        exceptions
          cntl_error                  = 1
          cntl_system_error           = 2
          create_error                = 3
          lifetime_error              = 4
          illegal_node_selection_mode = 5
          failed                      = 6
          illegal_column_name         = 7.

      if sy-subrc <> 0.
***       Erro Interno. Contatar Suporte.
        message e000 with text-000.
        stop.
      endif.

***   Setando valores do Header da TREE
      perform f_build_hier_header_itens.

      clear wa_variant.
      move  sy-repid to wa_variant-report.

***   create emty tree-control
      refresh t_itensview.

      call method ob_atr_itens->set_table_for_first_display
        exporting
          is_hierarchy_header = wa_hier_header
          is_variant          = wa_variant
        changing
          it_outtab           = t_itensview
          it_fieldcatalog     = t_fieldcatitm.

***   Criando Hierarquia da TREE do XML
      perform f_create_hier_itens_atr.

      call method cl_gui_cfw=>flush
        exceptions
          cntl_system_error = 1
          cntl_error        = 2
          others            = 3.

      if sy-subrc <> 0.
***     Erro Interno. Contatar Suporte.
        message e000 with text-000.
      endif.

      call method ob_atr_itens->column_optimize.

***   Registrando Eventos da Tree de Atribuição
      perform f_reg_events_atr.


    endmodule.                 " M_SHOW_ATRITENS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  m_show_vldhist  OUTPUT
*&---------------------------------------------------------------------*
*       Controles para Validação - Histórico
*----------------------------------------------------------------------*
    module m_show_vldhist output.
      check not vg_chave is initial.

***   Carregando catálogo de campo (HVALID)
      perform f_build_fieldcat_hvalid.

      if ob_cc_vld_hvalid is initial.
***     Criando Objeto de Container do ALV
        create object ob_cc_vld_hvalid
          exporting
            container_name              = 'CC_VLD_HVALID'
          exceptions
            cntl_error                  = 1
            cntl_system_error           = 2
            create_error                = 3
            lifetime_error              = 4
            lifetime_dynpro_dynpro_link = 5.

        if sy-subrc ne 0.
***       Erro Interno. Contatar Suporte.
          message e000 with text-000.
          stop.
        endif.
      endif.

      if not ob_hvalid     is initial.
        call method ob_hvalid->free
          exceptions
            cntl_error        = 1
            cntl_system_error = 2
            others            = 3.
      endif.

***     Criando Objeto TREE para XML
      create object ob_hvalid
        exporting
          parent                      = ob_cc_vld_hvalid
          node_selection_mode         = cl_gui_column_tree=>node_sel_mode_single
          item_selection              = 'X'
          no_html_header              = 'X'
          no_toolbar                  = 'X'
        exceptions
          cntl_error                  = 1
          cntl_system_error           = 2
          create_error                = 3
          lifetime_error              = 4
          illegal_node_selection_mode = 5
          failed                      = 6
          illegal_column_name         = 7.

      if sy-subrc <> 0.
***       Erro Interno. Contatar Suporte.
        message e000 with text-000.
        stop.
      endif.

***   Setando valores do Header da TREE
      perform f_build_hier_header_itens.

      clear wa_variant.
      move  sy-repid to wa_variant-report.

***   create emty tree-control
      refresh t_hvalid_vw.

      call method ob_hvalid->set_table_for_first_display
        exporting
          is_hierarchy_header = wa_hier_header
          is_variant          = wa_variant
        changing
          it_outtab           = t_hvalid_vw
          it_fieldcatalog     = t_hvalid_fldc.

***   Criando Hierarquia da TREE do XML
      perform f_create_hier_itens_vld.

      call method cl_gui_cfw=>flush
        exceptions
          cntl_system_error = 1
          cntl_error        = 2
          others            = 3.

      if sy-subrc <> 0.
***     Erro Interno. Contatar Suporte.
        message e000 with text-000.
      endif.

      call method ob_hvalid->column_optimize.

***   Registrando Eventos da Tree de Atribuição
      perform f_reg_events_vld.


    endmodule.                 " m_show_vldhist  OUTPUT


*----------------------------------------------------------------------*
*   Module  M_LOAD_LOGO_IMG_DOCS  OUTPUT
*----------------------------------------------------------------------*
*   Carregando Imagem Documentos
*----------------------------------------------------------------------*
    module m_load_logo_img_docs output.
      data vl_objid type w3objid.

      if ob_cc_img_docs is initial.
***     Criando Objeto de Container para Logo
        create object ob_cc_img_docs
          exporting
            container_name              = 'CC_IMG_DOCS'
          exceptions
            cntl_error                  = 1
            cntl_system_error           = 2
            create_error                = 3
            lifetime_error              = 4
            lifetime_dynpro_dynpro_link = 5
            others                      = 6.

        if sy-subrc ne 0.
***       Erro Interno. Contatar Suporte.
          message e000 with text-000.
          stop.
        endif.
      endif.

      if ob_img_docs is initial.
***     Criando Objeto de Picture Control
        create object ob_img_docs
          exporting
            parent = ob_cc_img_docs
          exceptions
            error  = 1
            others = 2.

        if sy-subrc ne 0.
***       Erro Interno. Contatar Suporte.
          message e000 with text-000.
          stop.
        else.
***       Setando Método de Exibição
          call method ob_img_docs->set_display_mode
            exporting
              display_mode = cl_gui_picture=>display_mode_normal_center
            exceptions
              error        = 1
              others       = 2.

          if sy-subrc ne 0.
***         Erro Interno. Contatar Suporte.
            message e000 with text-000.
            stop.
          endif.
        endif.
      endif.

      check ob_img_docs is not initial.

***   Preparando imagem a ser carregada
      if vg_qtsel is initial.
        clear vl_objid.
        concatenate 'ZHMS_IC_NOSELECTION_' sy-langu
               into vl_objid.
      elseif vg_qtsel gt 1.
        clear vl_objid.
        concatenate 'ZHMS_IC_OVERSELECTION_' sy-langu
               into vl_objid.
      endif.

***   Carregando URL
      clear vg_url.
      call function 'DP_PUBLISH_WWW_URL'
        exporting
          objid    = vl_objid
          lifetime = cndp_lifetime_transaction
        importing
          url      = vg_url
        exceptions
          others   = 1.

      if sy-subrc ne 0.
***     Erro Interno. Contatar Suporte.
        message e000 with text-000.
        stop.
      else.
***     Carregando Imagem na Tela
        call method ob_img_docs->load_picture_from_url_async
          exporting
            url    = vg_url
          exceptions
            error  = 1
            others = 2.

        if sy-subrc ne 0.
***       Erro Interno. Contatar Suporte.
          message e000 with text-000.
          stop.
        endif.
      endif.
    endmodule.                 " M_LOAD_LOGO_IMG_DOCS  OUTPUT

*----------------------------------------------------------------------*
*  MODULE m_load_flow_doc OUTPUT
*----------------------------------------------------------------------*
*   Carrega os dados de fluxos para o documento
*----------------------------------------------------------------------*
    module m_load_flow_doc output.
*   Carrega os dados de fluxos para o documento
      perform f_select_values_flow .
    endmodule.                    "m_load_flow_doc OUTPUT
*----------------------------------------------------------------------*
*   Module  ts_det_doc_active_tab_set  OUTPUT
*----------------------------------------------------------------------*
*   Controles para tabstrip de detalhes do documento
*----------------------------------------------------------------------*
    module ts_det_doc_active_tab_set output.
      ts_det_doc-activetab = g_ts_det_doc-pressed_tab.
      case g_ts_det_doc-pressed_tab.
        when c_ts_det_doc-tab1.
          g_ts_det_doc-subscreen = '0161'.
        when c_ts_det_doc-tab2.
          g_ts_det_doc-subscreen = '0162'.
        when c_ts_det_doc-tab3.
          g_ts_det_doc-subscreen = '0163'.
        when others.
      endcase.
    endmodule.                    "TS_DET_DOC_ACTIVE_TAB_SET OUTPUT

*----------------------------------------------------------------------*
*  MODULE TC_ATR_ITMATR_CHANGE_TC_ATTR OUTPUT
*----------------------------------------------------------------------*
*   Controles para Table Control de Atribuição
*----------------------------------------------------------------------*
    module tc_atr_itmatr_change_tc_attr output.
      describe table t_itmatr_ax lines tc_atr_itmatr-lines.
    endmodule.                    "TC_ATR_ITMATR_CHANGE_TC_ATTR OUTPUT

*&---------------------------------------------------------------------*
*&      Module  M_ATR_PROPORCIONAL  OUTPUT
*&---------------------------------------------------------------------*
*     Controle para campos de atribuição não proporcional
*----------------------------------------------------------------------*
    module m_atr_proporcional output.


      if vg_atprp eq 'X'.

        if t_itmatr_ax[] is initial.
          message 'Necessário inserir numero do Pedido para atribuição proporcional' type 'I'.
          clear vg_atprp.
          exit.
        endif.

      endif.

      select single value from zhms_tb_docmn into wa_docmn where chave eq wa_cabdoc-chave
                                                             and ( mneum eq 'MATDOC'
                                                              or   mneum eq 'INVDOCNO' ).

      if sy-subrc is initial.
        move abap_true to lv_block_atrib.
      else.
        clear lv_block_atrib.
      endif.

**    Percorrer a tela
      loop at screen.
*
*        IF wa_cabdoc-typed EQ 'NFSE1' AND screen-group2 EQ 'NFS'.
*****        IF screen-group2 EQ 'NFS'.
*****          screen-input = 0.
*****          MODIFY SCREEN.
*****        ENDIF.

**      Identificar campos que não são preenchidos em processamento proporcional
        if screen-group1 eq 'NPR'.
**        Veririfca se o processamento proporcional está selecionado
          if vg_atprp eq 'X'.
**          Desativa os campos
            screen-input = 0.
          else.
**          Ativa os campos
            screen-input = 1.
          endif.
          modify screen.
        endif.

        if screen-group1 eq 'JUS'.
          if vg_just_ok is not initial.
            screen-input = 1.
          else.
            screen-input = 0.
          endif.
          modify screen.
        endif.

        if  lv_block_atrib is not initial.
          if screen-group1 eq 'BLK'.
            if vg_just_ok is not initial.
              screen-input = 1.
            else.
              screen-input = 0.
            endif.
            modify screen.
          endif.
        endif.

      endloop.

    endmodule.                 " M_ATR_PROPORCIONAL  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  m_atr_buscaanteriores  OUTPUT
*&---------------------------------------------------------------------*
*     Buscar atribuições anteriores para edição
*----------------------------------------------------------------------*
    module m_atr_buscaanteriores output.


      check t_itmatr_ax is initial and vg_atr_exc <> 'TC_ATR_ITMATR_DELE' .

**    Percorre estrutura de mapeamento preenchida pela TREE
      loop at t_itmatr_atr into wa_itmatr where dcitm eq wa_itmdoc_ax-dcitm.
**      Move para estrutura de atribuição
        clear wa_itmatr_ax.

        move-corresponding wa_itmatr to wa_itmatr_ax.

*** Seleciona valores NCM
        if wa_itmatr_ax-ncm is initial.
          select single value
            from zhms_tb_docmn
            into wa_itmatr_ax-ncm
           where chave eq wa_itmatr-chave
             and dcitm eq wa_itmatr-dcitm
             and mneum eq 'XMLNCM'
             and atitm eq wa_itmatr-atitm.

          if sy-subrc is not initial." OR  wa_itmatr_ax-ncm IS INITIAL.

            read table t_docmn_rep into wa_docmn_rep
              with key dcitm = wa_itmatr-dcitm
                       mneum = 'XMLNCM'
                       atitm = wa_itmatr-atitm.

            if sy-subrc is initial.
              move wa_docmn_rep-value to wa_itmatr_ax-ncm.
            endif.
          endif.
        endif.

        append wa_itmatr_ax to t_itmatr_ax.

**      Preenche variaveis de seleção na tela
        vg_tdsrf = wa_itmatr_ax-tdsrf.
        vg_atprp = wa_itmatr_ax-atprp.

      endloop.
    endmodule. "m_atr_buscaanteriores

*&---------------------------------------------------------------------*
*&      Module  M_ATR_PROPORCIONAL  OUTPUT
*&---------------------------------------------------------------------*
*       Controle para seleção de tipo de documento
*----------------------------------------------------------------------*
    module m_atr_tipodocumento output.
**    Verifica se ja possui valor no campo
      if vg_tdsrf is initial.
**      Percorre a tela para encontrar o campo vg_tdsrf e o botão BTN_UNLOCK
        loop at screen.
**        Esconde o botão
          if screen-name eq 'BTN_UNLOCK'.
            screen-invisible = 1.
            modify screen.
          endif.
**        Habilita a edição do campo
          if screen-name eq 'VG_TDSRF'.
            screen-input = 1.
            modify screen.
          endif.
        endloop.
      else.
**      Percorre a tela para encontrar o campo vg_tdsrf e o botão BTN_UNLOCK
        loop at screen.
**        Exibe o botão
          if screen-name eq 'BTN_UNLOCK'.
            screen-invisible = 0.
            modify screen.
          endif.
**        Desabilita a edição do campo
          if screen-name eq 'VG_TDSRF'.
            screen-input = 0.
            modify screen.
          endif.
        endloop.
      endif.

      refresh t_show_po[].
      call function 'ZHMS_FM_BUSCA_PO_POSSIVEIS'
        exporting
          chave     = vg_chave
        tables
          t_show_po = t_show_po.

    endmodule.                    "m_atr_tipodocumento OUTPUT

*----------------------------------------------------------------------*
*  MODULE m_load_html_rcp OUTPUT
*----------------------------------------------------------------------*
*   Carregando Objeto HTML dos Documentos
*----------------------------------------------------------------------*
    module m_load_html_rcp output.

**    Exibe dados do documento no painel de detalhes - Codigos JS para HTML
      perform f_show_document_rcp.

      if ob_cc_html_rcp is initial.
***     Criando objeto de container
        create object ob_cc_html_rcp
          exporting
            container_name = 'CC_HTML_RCP'
          exceptions
            others         = 1.

        if sy-subrc ne 0.
***       Erro Interno. Contatar Suporte.
          message e000 with text-000.
          stop.
        endif.
      endif.

      if ob_html_rcp is initial.
        data: tl_datasrc_rcp  type table of zhms_st_html_srscd,
              wal_datasrc_rcp type zhms_st_html_srscd.

***     Criando Objeto HTML - Índice com JavaScript
        create object ob_html_rcp
          exporting
            parent = ob_cc_html_rcp.

        if sy-subrc ne 0.
***       Erro Interno. Contatar Suporte
          message e000 with text-000.
          stop.
        else.
***       Registrando Eventos do HTML Documentos
          perform f_reg_events_rcp.

***       Carregando Bibliotecas JavaScript
          refresh t_wwwdata.
          clear wa_wwwdata.

          select * into table t_wwwdata
                   from wwwdata
                   where objid like 'ZHMS%'
                     and srtf2 eq 0.

          loop at t_wwwdata into wa_wwwdata.
            perform f_load_images_rcp using wa_wwwdata-objid
                                            wa_wwwdata-text.
          endloop.

          refresh: t_srscd, t_srscd_ev.
          clear:   wa_srscd.

***       Código para primeira execução

          loop at t_datasrc into wa_datasrc.
            clear wal_datasrc_rcp.
            wal_datasrc_rcp-linsc = wa_datasrc.
            append wal_datasrc_rcp to tl_datasrc_rcp.
          endloop.

***       Obtendo Fonte HTML
          call function 'ZHMS_FM_GET_HTML_RECP'
            tables
              srscd   = t_srscd
              datasrc = tl_datasrc_rcp
            exceptions
              error   = 1
              others  = 2.

          if sy-subrc eq 0  and not t_srscd[] is initial.
            loop at t_srscd into wa_srscd.
              append wa_srscd to t_srscd_ev.
            endloop.

            if not t_srscd_ev is initial.
***           Preparando dados para Exibição do Índice
              clear vg_url.
              ob_html_rcp->load_data( importing assigned_url = vg_url
                                       changing  data_table   = t_srscd_ev ).

***           Exibindo Índice
              ob_html_rcp->show_url( url = vg_url ).

            else.
***           Erro Interno. Contatar Suporte.
              message e000 with text-000.
              stop.
            endif.
          endif.
        endif.
      endif.
      if wa_docrcbto is initial.

        call method cl_gui_custom_container=>set_focus
          exporting
            control           = ob_cc_html_rcp
          exceptions
            cntl_error        = 1
            cntl_system_error = 2
            others            = 3.
        if sy-subrc <> 0.
          message id sy-msgid type sy-msgty number sy-msgno
                     with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        endif.

        if sy-subrc <> 0.
          message id sy-msgid type sy-msgty number sy-msgno
                     with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        endif.
      endif.

    endmodule.                 " M_LOAD_HTML_RCP  OUTPUT


*----------------------------------------------------------------------*
*  MODULE tc_prt_docrcbto_change_tc_attr OUTPUT
*----------------------------------------------------------------------*
*  Table Control de portarias
*----------------------------------------------------------------------*
    module tc_prt_docrcbto_change_tc_attr output.
      describe table t_docrcbto_ax lines tc_prt_docrcbto-lines.
    endmodule.                    "TC_PRT_DOCRCBTO_CHANGE_TC_ATTR OUTPUT

*----------------------------------------------------------------------*
*  MODULE TC_CNF_DOCCONF_CHANGE_TC_ATTR OUTPUT
*----------------------------------------------------------------------*
*  Table control para histórico de conferencias
*----------------------------------------------------------------------*
    module tc_cnf_docconf_change_tc_attr output.
      describe table t_docconf_ax lines tc_cnf_docconf-lines.
    endmodule.                    "TC_CNF_DOCCONF_CHANGE_TC_ATTR OUTPUT

*&---------------------------------------------------------------------*
*&      Module  M_LOAD_LIST_CONF  OUTPUT
*&---------------------------------------------------------------------*
*       Carrega o Histórico de conferências
*----------------------------------------------------------------------*
    module m_load_list_conf output.
      if sy-ucomm ne 'CONF_SHOW'.
        perform f_load_list_conf.
      endif.
    endmodule.                 " M_LOAD_LIST_CONF  OUTPUT


*----------------------------------------------------------------------*
*  MODULE m_preenche_itens_contados OUTPUT
*----------------------------------------------------------------------*
*  Popular dados para contagem
*----------------------------------------------------------------------*
    module m_preenche_itens_contados output.
** Limpa tabela interna de contagem
      refresh t_datconf_ax.

** Percorre itens do documento
      loop at t_datconf into wa_datconf.

**      Mover dados de item para tabela de contagem
        clear wa_datconf_ax.
        read table t_itmdoc into wa_itmdoc with key dcitm = wa_datconf-dcitm.
        move-corresponding wa_itmdoc to wa_datconf_ax.

**      Mover dados de item da contagem para tabela de contagem
        move-corresponding wa_datconf to wa_datconf_ax.

**      Registrar na tabela de contagem
        append wa_datconf_ax to t_datconf_ax.
      endloop.

    endmodule.                    "m_preenche_itens_contados OUTPUT

*----------------------------------------------------------------------*
*  MODULE m_load_cancelamento OUTPUT
*----------------------------------------------------------------------*
*   Verifica se conferencia foi cancelada
*----------------------------------------------------------------------*
    module m_load_cancelamento output.

**    Percorre a tela escondendo / exibindo dados de cancelamento
      loop at screen.
        if screen-group1 eq 'CAN'.

          if not wa_docconf-ativo is initial.
            screen-invisible = 1.
            screen-active    = 0.
          else.
            screen-invisible = 0.
            screen-active    = 1.
          endif.

          modify screen.
        endif.
      endloop.

    endmodule.                    "m_load_cancelamento OUTPUT


*----------------------------------------------------------------------*
*  MODULE tc_cnf_datconf_change_tc_attr OUTPUT
*----------------------------------------------------------------------*
*  Table control para histórico de conferencias
*----------------------------------------------------------------------*
    module tc_cnf_datconf_change_tc_attr output.
      describe table t_datconf_ax lines tc_cnf_datconf-lines.
    endmodule.                    "TC_CNF_DATCONF_CHANGE_TC_ATTR OUTPUT

*&---------------------------------------------------------------------*
*&      Module  M_STATUS_0600  OUTPUT
*&---------------------------------------------------------------------*
*       Definições de tela
*----------------------------------------------------------------------*
    module m_status_0600 output.
      set pf-status '0600'.
      set titlebar  '0600'.
    endmodule.                 " M_STATUS_0600  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  M_TEXTEDITOR  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    module m_texteditor output.
      data: vl_textnote_repid like sy-repid.
*   create control container
      if ob_cc_dcevt_obs is initial.


        create object ob_cc_dcevt_obs
          exporting
            container_name              = 'CC_DCEVT_OBS'
          exceptions
            cntl_error                  = 1
            cntl_system_error           = 2
            create_error                = 3
            lifetime_error              = 4
            lifetime_dynpro_dynpro_link = 5.
      endif.

      if ob_dcevt_obs is initial.
*   create calls constructor, which initializes, creats and links
*   TextEdit Control
        create object ob_dcevt_obs
          exporting
            parent                     = ob_cc_dcevt_obs
            wordwrap_mode              = cl_gui_textedit=>wordwrap_at_fixed_position
            wordwrap_position          = 72
            wordwrap_to_linebreak_mode = cl_gui_textedit=>true.

      endif.

      call method ob_cc_dcevt_obs->link
        exporting
          repid     = vl_textnote_repid
          container = 'CC_DCEVT_OBS'.

*    show toolbar and statusbar on this screen
      call method ob_dcevt_obs->set_toolbar_mode
        exporting
          toolbar_mode = ob_dcevt_obs->true.

      call method ob_dcevt_obs->set_statusbar_mode
        exporting
          statusbar_mode = ob_dcevt_obs->true.

* finally flush
      call method cl_gui_cfw=>flush
        exceptions
          others = 1.

    endmodule.                 " M_TEXTEDITOR  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  M_SEL_EVENT  OUTPUT
*&---------------------------------------------------------------------*
*       Idenficação do evento
*----------------------------------------------------------------------*
    module m_sel_event output.
**    Verifica se foi selecionado algum valor
      if wa_dcevet-evtet is initial.
        vg_0600 = '0602'.
      endif.
      check not wa_dcevet-evtet is initial.

**    Seleciona tipo de evento com ET
      read table t_nfeevt into wa_nfeevt with key evtet = wa_dcevet-evtet.

**    Identifica necessidade de justificativa
      if wa_nfeevt-cpobs ne 0.
        vg_0600 = '0601'.
      else.
        vg_0600 = '0602'.
      endif.

    endmodule.                 " M_SEL_EVENT  OUTPUT

*----------------------------------------------------------------------*
*  MODULE TC_FLWDOC_CHANGE_TC_ATTR OUTPUT
*----------------------------------------------------------------------*
*   Table control de etapas de fluxo do documento
*----------------------------------------------------------------------*
    module tc_flwdoc_change_tc_attr output.
      describe table t_flwdoc_ax lines tc_flwdoc-lines.
    endmodule.                    "TC_FLWDOC_CHANGE_TC_ATTR OUTPUT

*&---------------------------------------------------------------------*
*&      Module  M_STATUS_0171  OUTPUT
*&---------------------------------------------------------------------*
*       Criação do ALV com fluxo do documento
*----------------------------------------------------------------------*
*    MODULE m_status_0171 OUTPUT.
**     Objeto inicial: Custom Control na tela
*
****   Carregando catálogo de campo (flow)
*      PERFORM f_build_fieldcat_flow.
*
*      IF ob_cc_det_flow IS INITIAL.
****     Criando Objeto de Container do ALV
*        CREATE OBJECT ob_cc_det_flow
*          EXPORTING
*            container_name              = 'CC_DET_FLOW'
*          EXCEPTIONS
*            cntl_error                  = 1
*            cntl_system_error           = 2
*            create_error                = 3
*            lifetime_error              = 4
*            lifetime_dynpro_dynpro_link = 5.
*
*        IF sy-subrc NE 0.
****       Erro Interno. Contatar Suporte.
*          MESSAGE e000 WITH text-000.
*          STOP.
*        ENDIF.
*      ENDIF.
*
*      IF NOT ob_flow     IS INITIAL.
*        CALL METHOD ob_flow->free
*          EXCEPTIONS
*            cntl_error        = 1
*            cntl_system_error = 2
*            OTHERS            = 3.
*      ENDIF.
*
****     Criando Objeto TREE para XML
*      CREATE OBJECT ob_flow
*        EXPORTING
*          parent                      = ob_cc_det_flow
*          node_selection_mode         = cl_gui_column_tree=>node_sel_mode_single
*          item_selection              = 'X'
*          no_html_header              = 'X'
*          no_toolbar                  = 'X'
*        EXCEPTIONS
*          cntl_error                  = 1
*          cntl_system_error           = 2
*          create_error                = 3
*          lifetime_error              = 4
*          illegal_node_selection_mode = 5
*          failed                      = 6
*          illegal_column_name         = 7.
*
*      IF sy-subrc <> 0.
****       Erro Interno. Contatar Suporte.
*        MESSAGE e000 WITH text-000.
*        STOP.
*      ENDIF.
*
****   Setando valores do Header da TREE
*      PERFORM f_build_hier_header_itens.
*
*      CLEAR wa_variant.
*      MOVE  sy-repid TO wa_variant-report.
*
****   create emty tree-control
*      REFRESH t_flwdoc_ax.
*
*      CALL METHOD ob_flow->set_table_for_first_display
*        EXPORTING
*          is_hierarchy_header = wa_hier_header
*          is_variant          = wa_variant
*        CHANGING
*          it_outtab           = t_flwdoc_ax
*          it_fieldcatalog     = t_flow_fldc.
*
****   Criando Hierarquia da TREE do XML
*      PERFORM f_create_hier_itens_flow.
*
*      CALL METHOD cl_gui_cfw=>flush
*        EXCEPTIONS
*          cntl_system_error = 1
*          cntl_error        = 2
*          OTHERS            = 3.
*
*      IF sy-subrc <> 0.
****     Erro Interno. Contatar Suporte.
*        MESSAGE e000 WITH text-000.
*      ENDIF.
*
*      CALL METHOD ob_flow->column_optimize.
*
****   Registrando Eventos da Tree de Atribuição
*      PERFORM f_reg_events_flow.
*
*    ENDMODULE.                 " M_STATUS_0171  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  M_STATUS_0171  OUTPUT
*&---------------------------------------------------------------------*
*       Criação do ALV com fluxo do documento
*----------------------------------------------------------------------*
    module m_status_0171 output.

**    Variáveis Locais
      data: tl_nodetable type treev_ntab,
            tl_itemtable type item_table_type.

      if ob_cc_det_flow is initial.
***     Criando Objeto de Container do ALV
        create object ob_cc_det_flow
          exporting
            container_name              = 'CC_DET_FLOW'
          exceptions
            cntl_error                  = 1
            cntl_system_error           = 2
            create_error                = 3
            lifetime_error              = 4
            lifetime_dynpro_dynpro_link = 5.

        if sy-subrc ne 0.
***       Erro Interno. Contatar Suporte.
          message e000 with text-000.
          stop.
        endif.
      endif.

**    Objeto de TREE para FLOW
      if ob_flow is initial.
***   Setando valores do Header da TREE
        perform f_build_hier_header_itens.

        create object ob_flow
          exporting
            parent                      = ob_cc_det_flow
            node_selection_mode         = cl_gui_column_tree=>node_sel_mode_single
            item_selection              = 'X'
            hierarchy_column_name       = 'Etapas'
            hierarchy_header            = wa_hier_header
          exceptions
            cntl_system_error           = 1
            create_error                = 2
            failed                      = 3
            illegal_node_selection_mode = 4
            illegal_column_name         = 5
            lifetime_error              = 6.
        if sy-subrc <> 0.
          message a000.
        endif.

***   Carregando catálogo de campo (flow)
        perform f_build_fieldcat_flow.

***   Registrando Eventos da Tree de Atribuição
        perform f_reg_events_flow.

      endif.

**    Limpar itens da tabela
      call method ob_flow->delete_all_nodes
        exceptions
          failed            = 1
          cntl_system_error = 2
          others            = 3.

**    Criar nós
      refresh: tl_nodetable, tl_itemtable.

***   Criando Hierarquia da TREE do XML
      perform f_create_hier_itens_flow using tl_nodetable tl_itemtable.

*RCP - 06/08/2018 - Início
*Novo include referente a envio de e-mail para a Etaps Portaria
*      IF sy-ucomm EQ '%_GC 133 1'.
      if wa_nature-icons eq 'S_B_ARRI'.
        perform zf_verif_email_portaria tables t_flwdoc t_scenflo.
      endif.
*RCP - 06/08/2018 - Fim

**    Adicionar os nós criados
      call method ob_flow->add_nodes_and_items
        exporting
          node_table                     = tl_nodetable
          item_table                     = tl_itemtable
          item_table_structure_name      = 'MTREEITM'
        exceptions
          failed                         = 1
          cntl_system_error              = 3
          error_in_tables                = 4
          dp_error                       = 5
          table_structure_name_not_found = 6.
      if sy-subrc <> 0.
        message a000.
      endif.

**    Expandir os nós
      call method ob_flow->expand_root_nodes
        exceptions
          failed              = 1
          illegal_level_count = 2
          cntl_system_error   = 3
          others              = 4.

**    Ajustar largura
      call method ob_flow->hierarchy_header_adjust_width
        exceptions
          others = 1.

    endmodule.                 " M_STATUS_0171  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  M_SET_PANEL_DET  OUTPUT
*&---------------------------------------------------------------------*
*       tratamento para painel de detalhes
*----------------------------------------------------------------------*
    module m_set_panel_det output.
**    Caso setado, remove a tela 151 direcionando diretamente para 171
*** Incio Inclusão David Rosin 11/03/2014
      read table t_nature into wa_nature with key natdc = wa_type-natdc.
*** Fim Inclusão David Rosin 11/03/2014
      if wa_nature-detsc eq 2
        and vg_015o_det eq '0151'.
        vg_015o_det = '0159'.
      elseif wa_nature-detsc eq 1.
        vg_015o_det = '0151'.
      endif.
    endmodule.                 " M_SET_PANEL_DET  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  M_TREE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    module m_vld_tree output.

*    Variáveis Locais
      data: tl_nodetable_vld type treev_ntab,
            ls_nodetable_vld like line of tl_nodetable_vld,
            tl_itemtable_vld type item_table_type,
            ls_itemtable_vld like line of tl_itemtable_vld,
            tl_nodesexp      type treev_nks,
            l_node_text      type lvc_value,
            lv_node_key      type lvc_nkey.

      data: lt_item_layout type lvc_t_layi,
            ls_item_layout type lvc_s_layi.

      if ob_cc_valid is initial.
**     Criando Objeto de Container do ALV
        create object ob_cc_valid
          exporting
            container_name              = 'CC_VALID'
          exceptions
            cntl_error                  = 1
            cntl_system_error           = 2
            create_error                = 3
            lifetime_error              = 4
            lifetime_dynpro_dynpro_link = 5.

        if sy-subrc ne 0.
**       Erro Interno. Contatar Suporte.
          message e000 with text-000.
          stop.
        endif.
      endif.

*    Objeto de TREE para VALID
      if ob_valid is initial.
**   Setando valores do Header da TREE
        perform f_build_hier_header_itens.

        create object ob_valid
          exporting
            parent                      = ob_cc_valid
            node_selection_mode         = cl_gui_column_tree=>node_sel_mode_single
            item_selection              = 'X'
            hierarchy_column_name       = 'Regras'
            hierarchy_header            = wa_hier_header
          exceptions
            cntl_system_error           = 1
            create_error                = 2
            failed                      = 3
            illegal_node_selection_mode = 4
            illegal_column_name         = 5
            lifetime_error              = 6.
        if sy-subrc <> 0.
          message a000.
        endif.

** Inclusão David Rosin teste
        perform f_reg_events_valid.
** Fim inclusão David Rosin teste

      endif.

*    Limpar itens da tabela
      call method ob_valid->delete_all_nodes
        exceptions
          failed            = 1
          cntl_system_error = 2
          others            = 3.

**   Criando Hierarquia da TREE
      refresh: tl_nodetable_vld, tl_itemtable_vld, tl_nodesexp.
      perform f_create_hier_itens_valid tables tl_nodesexp using tl_nodetable_vld tl_itemtable_vld.
      perform f_monta_nos_item tables tl_nodesexp using tl_nodetable_vld tl_itemtable_vld.

*    Adicionar os nós criados
      call method ob_valid->add_nodes_and_items
        exporting
          node_table                     = tl_nodetable_vld
          item_table                     = tl_itemtable_vld
          item_table_structure_name      = 'MTREEITM'
        exceptions
          failed                         = 1
          cntl_system_error              = 3
          error_in_tables                = 4
          dp_error                       = 5
          table_structure_name_not_found = 6.
      if sy-subrc <> 0.
        message a000.
      endif.

*    Expandir os nós
      call method ob_valid->expand_root_nodes
        exceptions
          failed              = 1
          illegal_level_count = 2
          cntl_system_error   = 3
          others              = 4.

      call method ob_valid->expand_nodes
        exporting
          node_key_table          = tl_nodesexp
        exceptions
          failed                  = 1
          cntl_system_error       = 2
          error_in_node_key_table = 3
          dp_error                = 4
          others                  = 5.


*    Ajustar largura
      call method ob_valid->hierarchy_header_adjust_width
        exceptions
          others = 1.

    endmodule.                 " M_TREE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  M_DOCLIST_STATUS  OUTPUT
*&---------------------------------------------------------------------*
*   Atualização contínua de Lista (Status)
*----------------------------------------------------------------------*
    module m_doclist_status output.
*     Atualizar os status dos documentos
      perform f_refresh_docs_status.

***       Timer para refresh de status de documentos no monitor
*         PERFORM f_timer_refresh_docs.



    endmodule.                 " M_DOCLIST_STATUS  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  F_HABILITA_BOTAO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
    form f_habilita_botao .

      data: ls_scen_flo type zhms_tb_scen_flo,
            lt_mneum    type standard table of zhms_tb_docmn,
            ls_mneum    like line of lt_mneum,
            lt_mapping  type standard table of zhms_tb_mapdata,
            ls_mapping  like line of lt_mapping.

      read table t_chave into wa_chave index 1.

      clear: wa_cabdoc, vg_funct.
      select single * from zhms_tb_cabdoc into wa_cabdoc where chave eq wa_chave.

      if sy-subrc is initial.

        select single * from zhms_tb_scen_flo into ls_scen_flo where natdc eq wa_flwdoc_ax-natdc
                                                                           and typed eq wa_flwdoc_ax-typed
                                                                           and scena eq wa_cabdoc-scena
                                                                           and flowd eq wa_flwdoc_ax-flowd.

        if sy-subrc is initial and ls_scen_flo-funct_estorno is not initial.

*** Busca todos mneumonicos por chave
          select * from zhms_tb_docmn into table lt_mneum where chave eq wa_chave.

          if sy-subrc is not initial.
            select * from zhms_tb_docmn_hs into table lt_mneum where chave eq wa_chave.
          endif.

*** Busca mapeamento para esse cenario
          select * from zhms_tb_mapdata into table lt_mapping where codmp eq ls_scen_flo-codmp_estorno.

*** Busca numero da miro ou migo ou J1B1N ou ML81N(Folha Serviço)
          sort lt_mneum descending by seqnr.
          read table lt_mneum into ls_mneum with key mneum = ls_scen_flo-mndoc.

          if sy-subrc is initial.
            move ls_scen_flo-funct_estorno to vg_funct.
          endif.

        endif.

      endif.

    endform.                    " F_HABILITA_BOTAO
*&---------------------------------------------------------------------*
*&      Module  STATUS_0110  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    module status_0110 output.

*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.

      types:
        begin of ty_grp,
          grp type zhms_de_grp,
        end of ty_grp.

      data: event_receiver type ref to lcl_hotspot_click,
            e_object       type ref to cl_alv_event_toolbar_set,
            ls_cabdoc      type zhms_tb_cabdoc,
            lt_itmatr      type standard table of zhms_tb_itmatr,
            ls_itmatr      like line of lt_itmatr,
            lt_grp         type standard table of ty_grp,
            ls_grp         like line of lt_grp.

      refresh: t_out_vld_i[], t_hvalid_fldc[].

      clear wa_hvalid_fldc.
      wa_hvalid_fldc-fieldname = 'ICON'.
      wa_hvalid_fldc-reptext   = 'Status'.
      wa_hvalid_fldc-col_opt   = 'X'.
      append wa_hvalid_fldc to t_hvalid_fldc.
      clear wa_hvalid_fldc.

      wa_hvalid_fldc-fieldname = 'ATITM'.
      wa_hvalid_fldc-reptext   = 'Nº Item Atribuição'.
      wa_hvalid_fldc-col_opt   = 'X'.
      append wa_hvalid_fldc to t_hvalid_fldc.
      clear wa_hvalid_fldc.

      wa_hvalid_fldc-fieldname = 'DCITM'.
      wa_hvalid_fldc-reptext   = 'Nº Item NF-e'.
      wa_hvalid_fldc-col_opt   = 'X'.
      append wa_hvalid_fldc to t_hvalid_fldc.
      clear wa_hvalid_fldc.

      wa_hvalid_fldc-fieldname = 'LTEXT'.
      wa_hvalid_fldc-reptext   = 'Descrição erro'.
      wa_hvalid_fldc-hotspot   = 'X'.
*      wa_hvalid_fldc-col_opt   = 'X'.
      wa_hvalid_fldc-outputlen = '200'.
      append wa_hvalid_fldc to t_hvalid_fldc.
      clear wa_hvalid_fldc.

      read table t_chave into wa_chave index 1.

      if sy-subrc is initial .

*** Seleciona Niveis de prioridade
        select distinct grp from zhms_tb_messages into table lt_grp where grp is not null.

        if sy-subrc is initial.
          loop at lt_grp into ls_grp.
            select * from zhms_tb_hrvalid into table t_hrvalid where chave eq wa_chave
                                                                 and vldty eq 'E'
                                                                 and atitm ne '00000'
                                                                 and grp   eq ls_grp-grp
                                                                 and ativo eq 'X'.
            if sy-subrc is initial.
              exit.
            endif.
          endloop.

          refresh  t_es_vld_i[].
          if sy-subrc is initial.

            select * from zhms_tb_itmatr into table lt_itmatr where chave eq wa_chave.

            loop at t_hrvalid into wa_hrvalid.

              read table lt_itmatr into ls_itmatr with key atitm = wa_hrvalid-atitm binary search.

              if sy-subrc is initial.
                move: ls_itmatr-dcitm to wa_out_vld_i-dcitm.
              else.
                clear wa_out_vld_i-dcitm.
              endif.

              move: '@0A@' to wa_out_vld_i-icon,
                    wa_hrvalid-atitm to wa_out_vld_i-atitm,
                    wa_hrvalid-vldv2 to wa_out_vld_i-ltext.
              append wa_out_vld_i to t_out_vld_i.
              clear wa_out_vld_i.
            endloop.
          endif.
        endif.
      endif.

** Busca Numero da nota e serie
      select single * from zhms_tb_cabdoc into ls_cabdoc where chave eq  wa_chave.

      if sy-subrc is initial.
        concatenate ls_cabdoc-docnr '-' ls_cabdoc-serie into vg_nfenum.
      endif.
      if ob_cc_vld_item is not initial.
        call method ob_cc_vld_item->free.
      endif.

      create object ob_cc_vld_item
        exporting
          container_name = 'CL_GUI_ALV_GRID'.

      create object ob_cc_grid
        exporting
          i_parent = ob_cc_vld_item.

      call method ob_cc_grid->set_table_for_first_display
        changing
          it_outtab                     = t_out_vld_i[]
          it_fieldcatalog               = t_hvalid_fldc[]
        exceptions
          invalid_parameter_combination = 1
          program_error                 = 2
          too_many_lines                = 3
          others                        = 4.
      create object event_receiver.
      set handler event_receiver->handle_hotspot_click for ob_cc_grid.
      create object e_object.


    endmodule.                 " STATUS_0110  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0604  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    module status_0604 output.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.

    endmodule.                 " STATUS_0604  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0603  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    module status_0603 output.
      set pf-status '0603'.
*  SET TITLEBAR 'xxx'.


      if wa_logparam-datade is initial.
        wa_logparam-datade = sy-datum.
      endif.



    endmodule.                 " STATUS_0603  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0301  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    module status_0301 output.

      set pf-status '0301'.
      set titlebar  '0301'.

      refresh t_ht_field[].

*** Natureza Documento
      clear wa_hvalid_fldc.
      wa_ht_field-fieldname = 'NATDC'.
      wa_ht_field-reptext   = 'Natureza Doc.'.
      wa_ht_field-col_opt   = 'X'.
      append wa_ht_field to t_ht_field.
      clear wa_ht_field.

*** Tipo Documento
      clear wa_hvalid_fldc.
      wa_ht_field-fieldname = 'TYPED'.
      wa_ht_field-reptext   = 'Tipo Doc.'.
      wa_ht_field-col_opt   = 'X'.
      append wa_ht_field to t_ht_field.
      clear wa_ht_field.

*** Evento
      clear wa_hvalid_fldc.
      wa_ht_field-fieldname = 'EVENT'.
      wa_ht_field-reptext   = 'Evento'.
      wa_ht_field-col_opt   = 'X'.
      append wa_ht_field to t_ht_field.
      clear wa_ht_field.

*** Tipo do evento entidade tributária
      clear wa_hvalid_fldc.
      wa_ht_field-fieldname = 'TPEVE'.
      wa_ht_field-reptext   = 'Tipo do evento'.
      wa_ht_field-col_opt   = 'X'.
      append wa_ht_field to t_ht_field.
      clear wa_ht_field.

*** Nº Sequencia
      clear wa_hvalid_fldc.
      wa_ht_field-fieldname = 'NSEQEV'.
      wa_ht_field-reptext   = 'Nº Seq.Evento'.
      wa_ht_field-col_opt   = 'X'.
      append wa_ht_field to t_ht_field.
      clear wa_ht_field.

*** Nº Lote
      clear wa_hvalid_fldc.
      wa_ht_field-fieldname = 'LOTE'.
      wa_ht_field-reptext   = 'Nº Lote'.
      wa_ht_field-col_opt   = 'X'.
      append wa_ht_field to t_ht_field.
      clear wa_ht_field.

*** Xmotivo
      clear wa_hvalid_fldc.
      wa_ht_field-fieldname = 'XMOTIVO'.
      wa_ht_field-reptext   = 'Texto Histórico'.
      wa_ht_field-col_opt   = 'X'.
      append wa_ht_field to t_ht_field.
      clear wa_ht_field.

*** Data e Hora do registro
      clear wa_hvalid_fldc.
      wa_ht_field-fieldname = 'DTHRREG'.
      wa_ht_field-reptext   = 'Data e Hora gravação do registro'.
      wa_ht_field-col_opt   = 'X'.
      append wa_ht_field to t_ht_field.
      clear wa_ht_field.

*** Nº Protocolo
      clear wa_hvalid_fldc.
      wa_ht_field-fieldname = 'PROTOCO'.
      wa_ht_field-reptext   = 'Nº Protocolo'.
      wa_ht_field-col_opt   = 'X'.
      append wa_ht_field to t_ht_field.
      clear wa_ht_field.

*** Data envio
      clear wa_hvalid_fldc.
      wa_ht_field-fieldname = 'DATAENV'.
      wa_ht_field-reptext   = 'Data envio do evento'.
      wa_ht_field-col_opt   = 'X'.
      append wa_ht_field to t_ht_field.
      clear wa_ht_field.

*** Hora envio
      clear wa_hvalid_fldc.
      wa_ht_field-fieldname = 'HORAENV'.
      wa_ht_field-reptext   = 'Hora envio do evento'.
      wa_ht_field-col_opt   = 'X'.
      append wa_ht_field to t_ht_field.
      clear wa_ht_field.

*** Usuário
      clear wa_hvalid_fldc.
      wa_ht_field-fieldname = 'USUARIO'.
      wa_ht_field-reptext   = 'Usuario Responsável'.
      wa_ht_field-col_opt   = 'X'.
      append wa_ht_field to t_ht_field.
      clear wa_ht_field.

      read table t_chave into wa_chave index 1.

      if sy-subrc is initial .

        refresh t_ht_out[].
        clear wa_ht_out.
        select * from zhms_tb_histev into table t_ht_histo where chave eq wa_chave.

        if sy-subrc is initial.
          loop at t_ht_histo into wa_ht_histo.

            select single denom
              from zhms_tx_events
              into wa_ht_out-event
             where natdc eq wa_cabdoc-natdc
               and typed eq wa_cabdoc-typed.

            if sy-subrc is initial.
              case wa_ht_histo-natdc .
                when '01'.
                  move 'Emissão de Documentos' to wa_ht_out-natdc.
                when '02'.
                  move 'Recepção de Documentos' to wa_ht_out-natdc.
                when others.
              endcase.
            endif.

            move: wa_ht_histo-typed   to wa_ht_out-typed,
                  wa_ht_histo-tpeve   to wa_ht_out-tpeve,
                  wa_ht_histo-nseqev  to wa_ht_out-nseqev,
                  wa_ht_histo-lote    to wa_ht_out-lote,
                  wa_ht_histo-xmotivo to wa_ht_out-xmotivo,
                  wa_ht_histo-dthrreg to wa_ht_out-dthrreg,
                  wa_ht_histo-protoco to wa_ht_out-protoco,
                  wa_ht_histo-dataenv to wa_ht_out-dataenv,
                  wa_ht_histo-horaenv to wa_ht_out-horaenv,
                  wa_ht_histo-usuario to wa_ht_out-usuario.
            append wa_ht_out to t_ht_out.
            clear wa_ht_out.
          endloop.
        endif.

      endif.

      if ob_cc_ht is not initial.
        call method ob_cc_ht->free.
      endif.

      create object ob_cc_ht
        exporting
          container_name = 'CC_HIST_ETAPA'.

      create object ob_cc_ht_grid
        exporting
          i_parent = ob_cc_ht.

      call method ob_cc_ht_grid->set_table_for_first_display
        changing
          it_outtab                     = t_ht_out[]
          it_fieldcatalog               = t_ht_field[]
        exceptions
          invalid_parameter_combination = 1
          program_error                 = 2
          too_many_lines                = 3
          others                        = 4.


    endmodule.                 " STATUS_0301  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  ZF_PREENCHE_BDC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0504   text
*      -->P_0505   text
*      -->P_0506   text
*----------------------------------------------------------------------*
    form zf_preenche_bdc  using    value(p_tela)
                                   value(p_name)
                                   value(p_value).

      clear gt_bdc.

      if p_tela = 'X'.
        gt_bdc-program   =  p_name.
        gt_bdc-dynpro    =  p_value.
        gt_bdc-dynbegin  =  p_tela.
      else.
        gt_bdc-fnam      =  p_name.
        gt_bdc-fval      =  p_value.
      endif.
      append gt_bdc.


    endform.                    " ZF_PREENCHE_BDC
*&---------------------------------------------------------------------*
*&      Module  STATUS_0605  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    module status_0605 output.
      set pf-status '0605'.
      set titlebar '0605'.
    endmodule.                 " STATUS_0605  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  M_CALC_AUDI  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    module m_calc_audi output.
      data: po_number     type bapimepoheader-po_number,
            ls_po_header  type  bapimepoheader,
            lt_po_item    type standard table of bapimepoitem,
            lt_hist_total type standard table of bapiekbes,
            ls_hist_total like line of lt_hist_total,
            ls_po_item    like line of lt_po_item,
            lv_item       type zhms_de_value,
            lv_qtd        type zhms_de_value,
            lv_atqtde     type zhms_de_value,
            lv_qtd_at     type zhms_de_value,
            lv_icms       type zhms_de_value,
            lv_ipi        type zhms_de_value,
            lv_sqn        type zhms_de_value,
            lv_pis        type zhms_de_value,
            lv_cof        type zhms_de_value,
            lv_sst        type zhms_de_value,
            lv_calc       type wemng,
            lv_calc2      type wemng,
            lv_calc3      type wemng,
            lv_calc4      type wemng,
            lv_tot_kbetr  type komv-kbetr,
            lv_cont_1baj  type i,
            lv_div_ped    type komv-kbetr,
            lv_div_xml    type komv-kbetr,
            lv_div_ped_c  type char20,
            lv_div_xml_c  type char20,
            lv_dif        type p decimals 2 value '0.10',
            lv_sub        type komv-kbetr,
            lv_ebeln      type ebeln,
            lv_baseped    type p decimals 2,
            vg_ncm_xml    type char8,
            vg_ncm_mne    type char8,
            lv_val_unit   type p decimals 2,
            vl_lands      type ekko-lands,
            vl_kalsm      type t005-kalsm,
            vl_text1      type t007s-text1.

      data: wa_ekko       type ekko,
            vg_message    type string,
            it_docmni     type table of zhms_tb_docmn,
            wa_docmni     type zhms_tb_docmn,
            t_tb_vld_tax  type table of zhms_tb_vld_tax,
            ls_tb_vld_tax like line of t_tb_vld_tax,
            t_komv        type standard table of komv,
            t_1baj        type standard table of j_1baj,
            it_komk       type standard table of komk,
            it_komp       type standard table of komp,
            it_docmnx     type table of zhms_tb_docmn,

            wa_komk       like line of it_komk,
            wa_komp       like line of it_komp,
            wa_komv       like line of t_komv,
            wa_1baj       type j_1baj.

      clear: t_alv_ped, t_alv_xml, t_alv_comp.

*      break rsantos.

*** Seleciona quis validações estão habilitadas
      refresh t_tb_vld_tax[].
      select *
        from zhms_tb_vld_tax
        into table t_tb_vld_tax
       where tax_type ne ' '.

      loop at t_itmatr into wa_itmatr.

        refresh lt_po_item[].
        clear: wa_docmnx, wa_ekko, vg_message, ls_po_item, wa_alv_xml.

**** Verifica se o pedido existe
        select single * from zhms_tb_docmn into wa_docmnx  where chave eq wa_itmatr-chave
                                                             and mneum eq 'ATPED'
                                                             and atitm eq wa_itmatr-atitm.
        if sy-subrc is initial.
          move wa_docmnx-value to lv_ebeln.
        else.
          move wa_itmatr-nrsrf to lv_ebeln.
        endif.

        check lv_ebeln is not initial.

        call function 'CONVERSION_EXIT_ALPHA_INPUT'
          exporting
            input  = lv_ebeln
          importing
            output = lv_ebeln.

*** Busca Detalhes Pedido de compras
*** Inicio alteração david rosin 16/07/2015
*    MOVE wa_docmnx-value TO po_number.
        move lv_ebeln to po_number.
*** Fim alteração david rosin 16/07/2015

        call function 'CONVERSION_EXIT_ALPHA_INPUT'
          exporting
            input  = po_number
          importing
            output = po_number.

        call function 'BAPI_PO_GETDETAIL1'
          exporting
            purchaseorder    = po_number
          importing
            poheader         = ls_po_header
          tables
            poitem           = lt_po_item
            pohistory_totals = lt_hist_total.

        if wa_itmatr-typed = 'NFSE1'.
          select single * from zhms_tb_docmn into wa_docmnx  where chave eq wa_itmatr-chave
                                                               and mneum eq 'ITEMDESCRICAO'.
          if sy-subrc eq 0.
            wa_alv_xml-item = wa_itmatr-atitm.
            wa_alv_xml-desc = wa_docmnx-value.
          endif.

        else.
          select single * from zhms_tb_docmn into wa_docmnx  where chave eq wa_itmatr-chave
                                                               and mneum eq 'XPROD'
                                                               and dcitm eq wa_itmatr-atitm.
          if sy-subrc eq 0.
            wa_alv_xml-item = wa_itmatr-atitm.
            wa_alv_xml-desc = wa_docmnx-value.
          endif.
        endif.

        select single * from zhms_tb_docmn into wa_docmnx  where chave eq wa_itmatr-chave
                                                             and mneum eq 'UCOM'
                                                             and dcitm eq wa_itmatr-atitm.
        if sy-subrc eq 0.
          wa_alv_xml-item = wa_itmatr-atitm.
          wa_alv_xml-unidade = wa_docmnx-value.
        endif.

        if wa_itmatr-typed <> 'NFSE1'.
          select single * from zhms_tb_docmn into wa_docmnx  where chave eq wa_itmatr-chave
                                                               and mneum eq 'QCOM'
                                                               and dcitm eq wa_itmatr-atitm.
          if sy-subrc eq 0.
            wa_alv_xml-item = wa_itmatr-atitm.
            wa_alv_xml-qtde = wa_docmnx-value.
          endif.
        else.
          wa_alv_xml-item = wa_itmatr-atitm.
          wa_alv_xml-qtde = wa_itmatr-atqtd.

        endif.

        select single * from zhms_tb_docmn into wa_docmnx  where chave eq wa_itmatr-chave
                                                             and mneum eq 'VPROD'
                                                             and dcitm eq wa_itmatr-atitm.
        if sy-subrc eq 0.
          wa_alv_xml-item = wa_itmatr-atitm.
          wa_alv_xml-vprod = wa_docmnx-value.
        endif.

        select single * from zhms_tb_docmn into wa_docmnx  where chave eq wa_itmatr-chave
                                                             and mneum eq 'PICMS'
                                                             and dcitm eq wa_itmatr-atitm.
        if sy-subrc eq 0.
          wa_alv_xml-item = wa_itmatr-atitm.
          wa_alv_xml-picms = wa_docmnx-value.
        endif.

        select single * from zhms_tb_docmn into wa_docmnx  where chave eq wa_itmatr-chave
                                                             and mneum eq 'VICMS'
                                                             and dcitm eq wa_itmatr-atitm.
        if sy-subrc eq 0.
          wa_alv_xml-item = wa_itmatr-atitm.
          wa_alv_xml-vicms = wa_docmnx-value.
        endif.

        select single * from zhms_tb_docmn into wa_docmnx  where chave eq wa_itmatr-chave
                                                             and mneum eq 'PIPI'
                                                             and dcitm eq wa_itmatr-atitm.
        if sy-subrc eq 0.
          wa_alv_xml-item = wa_itmatr-atitm.
          wa_alv_xml-pipi = wa_docmnx-value.
        endif.

        select single * from zhms_tb_docmn into wa_docmnx  where chave eq wa_itmatr-chave
                                                             and mneum eq 'VIPI'
                                                             and dcitm eq wa_itmatr-atitm.
        if sy-subrc eq 0.
          wa_alv_xml-item = wa_itmatr-atitm.
          wa_alv_xml-vipi = wa_docmnx-value.
        endif.

        select single * from zhms_tb_docmn into wa_docmnx  where chave eq wa_itmatr-chave
                                                             and mneum eq 'PPIS'
                                                             and dcitm eq wa_itmatr-atitm.
        if sy-subrc eq 0.
          wa_alv_xml-item = wa_itmatr-atitm.
          wa_alv_xml-ppis = wa_docmnx-value.
        endif.

        select single * from zhms_tb_docmn into wa_docmnx  where chave eq wa_itmatr-chave
                                                             and mneum eq 'VPIS'
                                                             and dcitm eq wa_itmatr-atitm.
        if sy-subrc eq 0.
          wa_alv_xml-item = wa_itmatr-atitm.
          wa_alv_xml-vpis = wa_docmnx-value.
        endif.

        select single * from zhms_tb_docmn into wa_docmnx  where chave eq wa_itmatr-chave
                                                             and mneum eq 'PCOFINS'
                                                             and dcitm eq wa_itmatr-atitm.
        if sy-subrc eq 0.
          wa_alv_xml-item = wa_itmatr-atitm.
          wa_alv_xml-pcofins = wa_docmnx-value.
        endif.

        select single * from zhms_tb_docmn into wa_docmnx  where chave eq wa_itmatr-chave
                                                             and mneum eq 'VCOFINS'
                                                             and dcitm eq wa_itmatr-atitm.
        if sy-subrc eq 0.
          wa_alv_xml-item = wa_itmatr-atitm.
          wa_alv_xml-vcofins = wa_docmnx-value.
        endif.
        append wa_alv_xml to t_alv_xml.
*        CLEAR wa_alv_xml.

* Tela pequena da esquerda - comparações diretas
* Valorer unitarios
*        SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_itmatr-chave
*                                                             AND mneum EQ 'ICMSVBC'
*                                                             AND dcitm EQ wa_itmatr-atitm.
*        IF sy-subrc EQ 0.
*          lv_val_unit = wa_docmnx-value.
*
*          SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_itmatr-chave
*                                                               AND mneum EQ 'VICMS'
*                                                               AND dcitm EQ wa_itmatr-atitm.
*          IF sy-subrc EQ 0.
*            lv_val_unit = lv_val_unit - wa_docmnx-value.
*          ENDIF.
*
*          wa_alv_comp-valor2 = lv_val_unit.
*        ENDIF.

*IVA do Pedido
        clear wa_alv_comp.
        select single * from zhms_tb_docmn into wa_docmnx  where chave eq wa_cabdoc-chave
                                                                     and mneum eq 'ATITMPED'
                                                                     and atitm eq wa_itmatr-atitm.
        if sy-subrc is initial.
          read table lt_po_item into ls_po_item with key po_item = wa_docmnx-value binary search.

          if sy-subrc eq 0.
            clear: vl_lands, vl_text1, vl_kalsm.
            select single lands
            into vl_lands
            from ekko
            where ebeln =  lv_ebeln.

            if not vl_lands is initial.
              select single kalsm
                into vl_kalsm
                from t005
                where land1 = vl_lands.
              if not vl_kalsm is initial.
                select single text1
               into vl_text1
                  from t007s
               where kalsm = vl_kalsm
                 and mwskz = ls_po_item-tax_code
                 and spras = sy-langu.
                if not vl_text1 is initial.
                  concatenate ls_po_item-tax_code '-' vl_text1 into wa_alv_comp-valor separated by space.
                else.
                  wa_alv_comp-valor = ls_po_item-tax_code.
                endif.
              else.
                wa_alv_comp-valor = ls_po_item-tax_code.
              endif.
            else.
              wa_alv_comp-valor = ls_po_item-tax_code.
            endif.
            condense wa_alv_comp-valor.
          endif.

          wa_alv_comp-item = wa_itmatr-atitm.
          wa_alv_comp-farol = 0.
          wa_alv_comp-impo = 'IVA do Pedido'.
          append wa_alv_comp to t_alv_comp.
          clear wa_alv_comp.
        endif.
* Valorer unitarios
        if wa_itmatr-typed <> 'NFSE1'.
          select single * from zhms_tb_docmn into wa_docmnx  where chave eq wa_itmatr-chave
                                                               and mneum eq 'ATVLR'
                                                               and dcitm eq wa_itmatr-atitm.
          if sy-subrc eq 0.
            lv_val_unit = wa_docmnx-value.
            wa_alv_comp-valor2 = lv_val_unit.
            condense wa_alv_comp-valor2.
          endif.
        else.
          select single * from zhms_tb_docmn into wa_docmnx  where chave eq wa_itmatr-chave
                                                               and mneum eq 'VALORSERVICO'.
          if sy-subrc eq 0.
            lv_val_unit = wa_docmnx-value.
            wa_alv_comp-valor2 = lv_val_unit.
            condense wa_alv_comp-valor2.
          endif.

        endif.
        clear wa_docmnx.
        select single * from zhms_tb_docmn into wa_docmnx  where chave eq wa_cabdoc-chave
                                                             and mneum eq 'ATITMPED'
                                                             and atitm eq wa_itmatr-atitm.
        if sy-subrc is initial.
          read table lt_po_item into ls_po_item with key po_item = wa_docmnx-value binary search.

          if sy-subrc eq 0.
            lv_val_unit = ls_po_item-net_price.
            wa_alv_comp-valor = lv_val_unit.
            condense wa_alv_comp-valor.
          endif.
        endif.

        wa_alv_comp-item = wa_itmatr-atitm.
        if wa_alv_comp-valor ne wa_alv_comp-valor2.
          wa_alv_comp-farol = 1.
        else.
          wa_alv_comp-farol = 3.
        endif.
        if wa_itmatr-typed <> 'NFSE1'.
          wa_alv_comp-impo = 'Val. Unit.'.
        else.
          wa_alv_comp-impo = 'Valor'.
        endif.
        append wa_alv_comp to t_alv_comp.
        clear wa_alv_comp.
        if wa_itmatr-typed <> 'NFSE1'.
* Unidade de Medida
          select single * from zhms_tb_docmn into wa_docmnx  where chave eq wa_itmatr-chave
                                                               and mneum eq 'UCOM'
                                                               and dcitm eq wa_itmatr-atitm.
          if sy-subrc eq 0.
            wa_alv_comp-valor2 = wa_docmnx-value.
          endif.
        endif.
        clear wa_docmnx.
        select single * from zhms_tb_docmn into wa_docmnx  where chave eq wa_cabdoc-chave
                                                             and mneum eq 'ATITMPED'
                                                             and atitm eq wa_itmatr-atitm.
        if sy-subrc is initial.
          read table lt_po_item into ls_po_item with key po_item = wa_docmnx-value binary search.

          if sy-subrc eq 0.
            call function 'CONVERSION_EXIT_CUNIT_OUTPUT'
              exporting
                input          = ls_po_item-po_unit
                language       = sy-langu
              importing
*               LONG_TEXT      =
                output         = ls_po_item-po_unit
*               SHORT_TEXT     =
              exceptions
                unit_not_found = 1
                others         = 2.
            if sy-subrc <> 0.
* Implement suitable error handling here
            endif.
            wa_alv_comp-valor = ls_po_item-po_unit.
          endif.
        endif.
        if wa_itmatr-typed <> 'NFSE1'.
          wa_alv_comp-item = wa_itmatr-atitm.
          if wa_alv_comp-valor ne wa_alv_comp-valor2.
            wa_alv_comp-farol = 1.
          else.
            wa_alv_comp-farol = 3.
          endif.
          wa_alv_comp-impo = 'Un. Medida'.
          append wa_alv_comp to t_alv_comp.
          clear wa_alv_comp.
        endif.
        if wa_itmatr-typed <> 'NFSE1'.
** Valida NCM
          clear wa_docmnx.
          clear: vg_ncm_xml, vg_ncm_mne.
          select single * from zhms_tb_docmn into wa_docmnx  where chave eq wa_cabdoc-chave
                                                               and mneum eq 'XMLNCM'
                                                               and dcitm eq wa_itmatr-atitm.

          if sy-subrc eq 0.
            translate wa_docmnx-value using '. '.
            condense wa_docmnx-value no-gaps.
            move: wa_docmnx-value to vg_ncm_xml.
          endif.
        endif.
        clear wa_docmnx.
        select single * from zhms_tb_docmn into wa_docmnx  where chave eq wa_cabdoc-chave
                                                             and mneum eq 'ATITMPED'
                                                             and atitm eq wa_itmatr-atitm.
        if sy-subrc eq 0.
          read table lt_po_item into ls_po_item with key po_item = wa_docmnx-value binary search.

          translate ls_po_item-bras_nbm using '. '. condense ls_po_item-bras_nbm no-gaps.
          vg_ncm_mne = ls_po_item-bras_nbm.
          if wa_itmatr-typed <> 'NFSE1'.
            read table t_tb_vld_tax into ls_tb_vld_tax with key tax_type = 'NCM'.

            wa_alv_comp-item = wa_itmatr-atitm.
            wa_alv_comp-impo = 'NCM'.
            wa_alv_comp-valor = vg_ncm_mne.
            wa_alv_comp-valor2 = vg_ncm_xml.
            if vg_ncm_mne ne vg_ncm_xml.
              wa_alv_comp-farol = 1.
            else.
              wa_alv_comp-farol = 3.
            endif.
            append wa_alv_comp to t_alv_comp.
            clear wa_alv_comp.
          endif.
        endif.


*        REFRESH it_docmni[].
*        SELECT * FROM zhms_tb_docmn INTO TABLE it_docmni  WHERE chave EQ wa_cabdoc-chave
*                                                            AND mneum EQ 'NCM'
*                                                            AND dcitm EQ wa_docmnx-dcitm.
*
*        LOOP AT it_docmni INTO wa_docmni.
*
*          TRANSLATE wa_docmni-value USING '. '.
*          TRANSLATE wa_docmnx-value USING '. '.
*          CONDENSE wa_docmni-value NO-GAPS.
*          CONDENSE wa_docmnx-value NO-GAPS.
*
*          CLEAR: vg_ncm_xml, vg_ncm_mne.
*          MOVE: wa_docmni-value TO vg_ncm_mne,
*                wa_docmnx-value TO vg_ncm_xml.
*
*          READ TABLE t_tb_vld_tax INTO ls_tb_vld_tax WITH KEY tax_type = 'NCM'.
*
*          wa_alv_comp-item = wa_itmatr-atitm.
*          wa_alv_comp-impo = 'NCM'.
*          wa_alv_comp-valor = vg_ncm_mne.
*          wa_alv_comp-valor2 = vg_ncm_xml.
*          IF vg_ncm_mne NE vg_ncm_xml.
*            wa_alv_comp-farol = 1.
*          ELSE.
*            wa_alv_comp-farol = 3.
*          ENDIF.
*          APPEND wa_alv_comp TO t_alv_comp.
*          CLEAR wa_alv_comp.
*
*          IF vg_ncm_mne NE vg_ncm_xml AND ls_tb_vld_tax-ativo IS NOT INITIAL.
*
*          ENDIF.
*        ENDLOOP.

*** Validação das condições do pedido de compra
        refresh: t_komv[], it_komk[], it_komp[].
        clear: wa_komk, wa_komp.
*        PERFORM f_preenche_t_komk.

        refresh it_docmnx.
        select * from zhms_tb_docmn into table it_docmnx  where chave eq wa_cabdoc-chave and
                                                               ( atitm eq wa_itmatr-atitm or
                                                                atitm eq '00000' ).

        if sy-subrc is initial and it_docmnx[] is not initial.

          move: sy-mandt to wa_komk-mandt.
          clear wa_docmn.
          read table it_docmnx  into wa_docmn with key mneum = 'VATCNTRY'.

          if sy-subrc is initial.
            move wa_docmn-value to wa_komk-aland.
          endif.

          clear wa_docmn.
          read table it_docmnx  into wa_docmn with key mneum = 'COMPCODE'.

          if sy-subrc is initial.
            move wa_docmn-value to wa_komk-bukrs.
          endif.

          clear wa_docmn.
          read table it_docmnx  into wa_docmn with key mneum = 'CURRENCY'.

          if sy-subrc is initial.
            move wa_docmn-value to wa_komk-waerk.
          endif.

          clear wa_docmn.
          read table it_docmnx  into wa_docmn with key mneum = 'DIFFINV'.

          if sy-subrc is initial.
            move wa_docmn-value to wa_komk-lifnr.
          endif.

          move 'TX'     to wa_komk-kappl.
          move 'TAXBRA' to wa_komk-kalsm.

          clear wa_docmn.
          read table it_docmnx  into wa_docmn with key mneum = 'CREATEDATE'.

          if sy-subrc is initial.
            move wa_docmn-value to wa_komk-prsdt.
          endif.
          if wa_cabdoc-typed = 'NFSE1'.
            clear wa_docmn.
            read table it_docmnx  into wa_docmn with key mneum = 'PSTNGDATE'.

            if sy-subrc is initial.
              move wa_docmn-value to wa_komk-prsdt.
            endif.

          endif.
          clear wa_docmn.
          read table it_docmnx  into wa_docmn with key mneum = 'TAXJURCODE'.

          if sy-subrc is initial.
            move wa_docmn-value to wa_komk-txjcd.
          endif.

          clear wa_docmn.
          read table it_docmnx  into wa_docmn with key mneum = 'PURCHORG'.

          if sy-subrc is initial.
            move wa_docmn-value to wa_komk-ekorg.
          endif.

          clear wa_docmn.
          read table it_docmnx into wa_docmn with key mneum = 'COAREA'.

          if sy-subrc is initial.
            move wa_docmn-value to wa_komk-kokrs.
          endif.

          clear wa_docmn.
          read table it_docmnx  into wa_docmn with key mneum = 'COSTCENTER'.

          if sy-subrc is initial.
            move wa_docmn-value to wa_komk-kostl.
          endif.

          clear wa_docmn.
          read table it_docmnx  into wa_docmn with key mneum = 'TAXCODE'.

          if sy-subrc is initial.
            move wa_docmn-value to wa_komk-mwskz.
          endif.

          append wa_komk to it_komk.

        endif.

*        PERFORM f_preenche_t_komp.

        refresh it_docmnx[].
        select * from zhms_tb_docmn into table it_docmnx  where chave eq wa_cabdoc-chave and
                                                                ( atitm eq wa_itmatr-atitm or
                                                                  atitm eq '00000' ).


        if sy-subrc is initial and it_docmnx[] is not initial.

          clear wa_docmn.
          read table it_docmnx into wa_docmn with key mneum = 'ATITMPED'.

          if sy-subrc is initial.
            move wa_docmn-value to wa_komp-kposn.
          endif.

          clear wa_docmn.
          read table it_docmnx into wa_docmn with key mneum = 'MATERIAL'.

          if sy-subrc is initial.
            move wa_docmn-value to wa_komp-matnr.
          endif.

          clear wa_docmn.
          read table it_docmnx into wa_docmn with key mneum = 'PLANT'.

          if sy-subrc is initial.
            move wa_docmn-value to wa_komp-werks.
          endif.

          clear wa_docmn.
          read table it_docmnx into wa_docmn with key mneum = 'TAXJURCODE'.

          if sy-subrc is initial.
            move: wa_docmn-value(2) to wa_komp-wkreg,
                  wa_docmn-value(2) to wa_komp-txreg_sf,
                  wa_docmn-value(2) to wa_komp-txreg_st,
                  wa_docmn-value    to wa_komp-loc_pr,
                  wa_docmn-value    to wa_komp-loc_se,
                  wa_docmn-value    to wa_komp-loc_sr.
          endif.

          clear wa_docmn.
          read table it_docmnx into wa_docmn with key mneum = 'MATLGROUP'.

          if sy-subrc is initial.
            move wa_docmn-value to wa_komp-matkl.
          endif.

          clear wa_docmn.
          read table it_docmnx into wa_docmn with key mneum = 'ENRYUOMISO'.

          if sy-subrc is initial.
            move: wa_docmn-value to wa_komp-meins,
                  wa_docmn-value to wa_komp-vrkme.
          endif.

          clear wa_docmn.
          read table it_docmnx into wa_docmn with key mneum = 'ATQTDE'.

          if sy-subrc is initial.
            move: wa_docmn-value to wa_komp-mglme,
                  wa_docmn-value to wa_komp-mgame.
          endif.

          clear wa_docmn.
          read table it_docmnx into wa_docmn with key mneum = 'NETPRICE'.

          if sy-subrc is initial.
            move wa_docmn-value to wa_komp-wrbtr.
          endif.

          clear wa_docmn.
          read table it_docmnx into wa_docmn with key mneum = 'TAXCODE'.

          if sy-subrc is initial.
            move wa_docmn-value to wa_komp-mwskz.
          endif.

          clear wa_docmn.
          read table it_docmnx into wa_docmn with key mneum = 'ATPED'.

          if sy-subrc is initial.
            move wa_docmn-value to wa_komp-evrtn.
          endif.

          clear wa_docmn.
          read table it_docmnx into wa_docmn with key mneum = 'ATITMPED'.

          if sy-subrc is initial.
            move wa_docmn-value to wa_komp-evrtp.
          endif.

          select single mtart from mara into wa_komp-mtart where matnr eq wa_komp-matnr.

          clear wa_docmn.
          read table it_docmnx into wa_docmn with key mneum = 'MATLUSAGE'.

          if sy-subrc is initial.
            move: wa_docmn-value to wa_komp-mtuse,
                  wa_docmn-value to wa_komp-mtuse_marc.
          endif.

          clear wa_docmn.
          read table it_docmnx into wa_docmn with key mneum = 'MATORIGIN'.

          if sy-subrc is initial.
            move wa_docmn-value to wa_komp-mtorg.
          endif.

          clear wa_docmn.
          read table it_docmnx into wa_docmn with key mneum = 'NCM'.

          if sy-subrc is initial.
            condense wa_docmn-value no-gaps.
            move wa_docmn-value to wa_komp-steuc.
          endif.

          data: lv_po        type bapiekko-po_number,
                lt_items_aux type standard table of bapiekpo,
                ls_items_aux like line of lt_items_aux.

          refresh: lt_items_aux[].
          clear: ls_items_aux, lv_po.

          move wa_komp-evrtn to lv_po.
*** Busca  valor liquido sem impostos
          call function 'BAPI_PO_GETDETAIL'
            exporting
              purchaseorder = lv_po
              items         = 'X'
            tables
              po_items      = lt_items_aux.

          call function 'CONVERSION_EXIT_ALPHA_INPUT'
            exporting
              input  = wa_komp-evrtp
            importing
              output = wa_komp-evrtp.

          read table lt_items_aux into ls_items_aux with key po_item = wa_komp-evrtp.

          if sy-subrc is initial.


            if wa_cabdoc-typed = 'NFSE1'.
              wa_komp-mwskz = ls_items_aux-tax_code.
              wa_komk-mwskz = ls_items_aux-tax_code.
            endif.
            move: ls_items_aux-net_value to wa_komp-netwr,
                  ls_items_aux-net_value to wa_komp-wrbtr.

            move ls_items_aux-eff_value to wa_komp-kzwi1.
          endif.

          append wa_komp to it_komp.

        endif.

        call function 'PRICING'
          exporting
            calculation_type = 'B'
            comm_head_i      = wa_komk
            comm_item_i      = wa_komp
          tables
            tkomv            = t_komv.

        if t_komv[] is not initial.

          select *
            from j_1baj
            into table t_1baj
            for all entries in t_komv
           where taxtyp = t_komv-kschl
             and taxgrp = 'ICMS'.

          clear lv_tot_kbetr.
          loop at t_1baj into wa_1baj.
            loop at t_komv into wa_komv where kschl eq wa_1baj-taxtyp.
              lv_tot_kbetr = lv_tot_kbetr + wa_komv-kawrt.
            endloop.
          endloop.

          clear lv_qtd .
          select single value from zhms_tb_docmn into lv_qtd  where chave eq wa_cabdoc-chave
                                                                and mneum eq 'QUANTITY'
                                                                and atitm eq wa_itmatr-atitm.
          if lv_qtd > 0.
*** Valor unitário do ICMS no Pedido
            try .
                lv_div_ped = lv_tot_kbetr / lv_qtd.
              catch cx_sy_zerodivide.
            endtry.

*** Valor unitário do ICMS no XML
            clear lv_icms.
            select single value from zhms_tb_docmn into lv_icms where chave eq wa_cabdoc-chave
                                                                  and mneum eq 'ATVICMS'
                                                                  and atitm eq wa_itmatr-atitm.

            clear lv_qtd_at .
            select single value from zhms_tb_docmn into lv_qtd_at where chave eq wa_cabdoc-chave
                                                                    and mneum eq 'ATQTDE'
                                                                    and atitm eq wa_itmatr-atitm.

            if sy-subrc is initial.
              try .
                  lv_div_xml = lv_icms / lv_qtd_at.
                catch cx_sy_zerodivide.
              endtry.

* Alv de Auditoria
              wa_alv_ped-item = wa_itmatr-atitm.
              wa_alv_ped-impo = 'ICMS'.
              wa_alv_ped-valor = lv_div_ped.
              wa_alv_ped-valor2 = lv_div_xml.
              if lv_div_ped ne lv_div_xml.
                wa_alv_ped-farol = 2.
              else.
                wa_alv_ped-farol = 3.
              endif.

* Base de calculo
              read table t_komv into wa_komv with key kschl = 'BIC0'.
              if sy-subrc eq 0.
                lv_baseped = wa_komv-kbetr / 10.
                wa_alv_ped-baseped = lv_baseped.
                wa_alv_ped-basexml = wa_alv_xml-picms.
              endif.

              append wa_alv_ped to t_alv_ped.
              clear wa_alv_ped.


*** Validar se o Valor unitário do ICMS no Pedido <> Valor unitário do ICMS no XML.
              read table t_tb_vld_tax into ls_tb_vld_tax with key tax_type = 'ICMS'.

              if lv_div_ped ne lv_div_xml and ls_tb_vld_tax-ativo is not initial.

              endif.
            endif.
          endif.
        else.
          clear lv_qtd .
          select single value from zhms_tb_docmn into lv_qtd  where chave eq wa_cabdoc-chave
                                                                and mneum eq 'QCOM'
                                                                and atitm eq wa_itmatr-atitm.
          if lv_qtd > 0.
*** Valor unitário do ICMS no Pedido
            try .
                lv_div_ped = lv_tot_kbetr / lv_qtd.
              catch cx_sy_zerodivide.
            endtry.

*** Valor unitário do ICMS no XML
            clear lv_icms.
            select single value from zhms_tb_docmn into lv_icms where chave eq wa_cabdoc-chave
                                                                  and mneum eq 'ATVICMS'
                                                                  and atitm eq wa_itmatr-atitm.

            clear lv_qtd_at .
            select single value from zhms_tb_docmn into lv_qtd_at where chave eq wa_cabdoc-chave
                                                                    and mneum eq 'ATQTDE'
                                                                    and atitm eq wa_itmatr-atitm.

            if sy-subrc is initial.
              try .
                  lv_div_xml = lv_icms / lv_qtd_at.
                catch cx_sy_zerodivide.
              endtry.

* Alv de Auditoria
              wa_alv_ped-item = wa_itmatr-atitm.
              wa_alv_ped-impo = 'ICMS'.
              wa_alv_ped-valor = lv_div_ped.
              wa_alv_ped-valor2 = lv_div_xml.
              if lv_div_ped ne lv_div_xml.
                wa_alv_ped-farol = 2.
              else.
                wa_alv_ped-farol = 3.
              endif.

* Base de calculo
              read table t_komv into wa_komv with key kschl = 'BIC0'.
              if sy-subrc eq 0.
                lv_baseped = wa_komv-kbetr / 10.
                wa_alv_ped-baseped = lv_baseped.
                wa_alv_ped-basexml = wa_alv_xml-picms.
              endif.

              append wa_alv_ped to t_alv_ped.
              clear wa_alv_ped.


*** Validar se o Valor unitário do ICMS no Pedido <> Valor unitário do ICMS no XML.
              read table t_tb_vld_tax into ls_tb_vld_tax with key tax_type = 'ICMS'.

              if lv_div_ped ne lv_div_xml and ls_tb_vld_tax-ativo is not initial.

              endif.
            endif.

          endif.
        endif.


*** Valor do IPI do XML difere do pedido de compra
        refresh t_1baj[].
        select *
          from j_1baj
          into table t_1baj
          for all entries in t_komv
         where taxtyp = t_komv-kschl
           and taxgrp = 'IPI'.

        clear lv_tot_kbetr .
        loop at t_1baj into wa_1baj.
          loop at t_komv into wa_komv where kschl eq wa_1baj-taxtyp.
            lv_tot_kbetr = lv_tot_kbetr + wa_komv-kawrt.
          endloop.
        endloop.

*** Valor unitário do IPI no Pedido
        clear lv_div_ped .
        try .
            lv_div_ped = lv_tot_kbetr / lv_qtd.
          catch cx_sy_zerodivide.
        endtry.

*** Valor unitário do IPI no XML
        clear lv_ipi.
        select single value from zhms_tb_docmn into lv_ipi  where chave eq wa_cabdoc-chave
                                                              and mneum eq 'ATVIPI'
                                                              and atitm eq wa_itmatr-atitm.

        if sy-subrc is initial.
          clear lv_div_xml.
          try .
              lv_div_xml = lv_ipi / lv_qtd_at.
            catch  cx_sy_zerodivide.
          endtry.

* Alv de Auditoria
          wa_alv_ped-item = wa_itmatr-atitm.
          wa_alv_ped-impo = 'IPI'.
          wa_alv_ped-valor = lv_div_ped.
          wa_alv_ped-valor2 = lv_div_xml.
          if lv_div_ped ne lv_div_xml.
            wa_alv_ped-farol = 1.
          else.
            wa_alv_ped-farol = 3.
          endif.

* Base de calculo
          read table t_komv into wa_komv with key kschl = 'BIP0'.
          if sy-subrc eq 0.
            lv_baseped = wa_komv-kbetr / 10.
            wa_alv_ped-baseped = lv_baseped.
            wa_alv_ped-basexml = wa_alv_xml-pipi.
          endif.

          append wa_alv_ped to t_alv_ped.
          clear wa_alv_ped.

          read table t_tb_vld_tax into ls_tb_vld_tax with key tax_type = 'IPI'.

          if lv_div_ped ne lv_div_xml and ls_tb_vld_tax-ativo is not initial.

          endif.
        endif.
*
*** Valor do PIS do XML difere do pedido de compra
        refresh t_1baj[].
        select *
          from j_1baj
          into table t_1baj
          for all entries in t_komv
         where taxtyp = t_komv-kschl
           and taxgrp = 'PIS'.

        clear: lv_cont_1baj, lv_tot_kbetr .
        loop at t_1baj into wa_1baj.
          loop at t_komv into wa_komv where kschl eq wa_1baj-taxtyp.
            lv_tot_kbetr = lv_tot_kbetr + wa_komv-kawrt.
            if wa_komv-kawrt is not initial.
              add 1 to lv_cont_1baj.
            endif.
          endloop.
        endloop.

*** Valor unitário do PIS no Pedido
        clear lv_div_ped .
        try .
            lv_div_ped = lv_tot_kbetr / lv_cont_1baj.
            lv_div_ped = lv_div_ped / lv_qtd.
          catch  cx_sy_zerodivide.
        endtry.

*** Valor unitário do PIS no XML
        clear lv_pis.
        select single value from zhms_tb_docmn into lv_pis  where chave eq wa_cabdoc-chave
                                                              and mneum eq 'ATVPIS'
                                                              and atitm eq wa_itmatr-atitm.

        if sy-subrc is initial.
          clear lv_div_xml.
          try .
              lv_div_xml = lv_pis / lv_qtd_at.
            catch cx_sy_zerodivide.
          endtry.

* Alv de Auditoria
          wa_alv_ped-item = wa_itmatr-atitm.
          wa_alv_ped-impo = 'PIS'.
          wa_alv_ped-valor = lv_div_ped.
          wa_alv_ped-valor2 = lv_div_xml.
          if lv_div_ped ne lv_div_xml.
            wa_alv_ped-farol = 1.
          else.
            wa_alv_ped-farol = 3.
          endif.

* Base de calculo
          read table t_komv into wa_komv with key kschl = 'BPI1'.
          if sy-subrc eq 0.
            lv_baseped = wa_komv-kbetr / 10.
            wa_alv_ped-baseped = lv_baseped.
            wa_alv_ped-basexml = wa_alv_xml-ppis.
          endif.

          append wa_alv_ped to t_alv_ped.
          clear wa_alv_ped.

          read table t_tb_vld_tax into ls_tb_vld_tax with key tax_type = 'PIS'.

          if lv_div_ped ne lv_div_xml and ls_tb_vld_tax-ativo is not initial.

          endif.
        endif.

*** Valor do Cofins do XML difere do pedido de compra
        refresh t_1baj[].
        select *
          from j_1baj
          into table t_1baj
          for all entries in t_komv
         where taxtyp = t_komv-kschl
           and taxgrp = 'COFI'.

        clear lv_tot_kbetr .
*          IF sy-subrc IS INITIAL.
        clear lv_cont_1baj.
        loop at t_1baj into wa_1baj.
          loop at t_komv into wa_komv where kschl eq wa_1baj-taxtyp.
            lv_tot_kbetr = lv_tot_kbetr + wa_komv-kawrt.
            if wa_komv-kawrt is not initial.
              add 1 to lv_cont_1baj.
            endif.
          endloop.
        endloop.

*** Valor unitário do COFINS no Pedido
        clear lv_div_ped .
        try .
            lv_div_ped = lv_tot_kbetr / lv_cont_1baj.
            lv_div_ped = lv_div_ped / lv_qtd_at.
          catch  cx_sy_zerodivide.
        endtry.

*** Valor unitário do COFINS no XML
        clear lv_cof.
        select single value from zhms_tb_docmn into lv_cof where chave eq wa_cabdoc-chave
                                                             and mneum eq 'ATVCOFINS'
                                                             and atitm eq wa_itmatr-atitm.

        if sy-subrc is initial.
          clear lv_div_xml.
          try .
              lv_div_xml = lv_cof / lv_qtd_at.
            catch  cx_sy_zerodivide.
          endtry.

* Alv de Auditoria
          wa_alv_ped-item = wa_itmatr-atitm.
          wa_alv_ped-impo = 'COFINS'.
          wa_alv_ped-valor = lv_div_ped.
          wa_alv_ped-valor2 = lv_div_xml.
          if lv_div_ped ne lv_div_xml.
            wa_alv_ped-farol = 1.
          else.
            wa_alv_ped-farol = 3.
          endif.

* Base de calculo
          read table t_komv into wa_komv with key kschl = 'BCO1'.
          if sy-subrc eq 0.
            lv_baseped = wa_komv-kbetr / 10.
            wa_alv_ped-baseped = lv_baseped.
            wa_alv_ped-basexml = wa_alv_xml-pcofins.
          endif.

          append wa_alv_ped to t_alv_ped.
          clear wa_alv_ped.

          read table t_tb_vld_tax into ls_tb_vld_tax with key tax_type = 'COFINS'.

          if lv_div_ped ne lv_div_xml and ls_tb_vld_tax-ativo is not initial.

          endif.
        endif.

*** Valor do ISS do XML difere do pedido de compra
        refresh t_1baj[].
        select *
          from j_1baj
          into table t_1baj
          for all entries in t_komv
         where taxtyp = t_komv-kschl
           and taxgrp = 'ISS'.

        clear lv_tot_kbetr .
*          IF sy-subrc IS INITIAL.
        loop at t_1baj into wa_1baj.
          loop at t_komv into wa_komv where kschl eq wa_1baj-taxtyp.
            lv_tot_kbetr = lv_tot_kbetr + wa_komv-kawrt.
          endloop.
        endloop.

*** Valor unitário do ISS no Pedido
        clear lv_div_ped .
        try .
            lv_div_ped = lv_tot_kbetr / lv_qtd.
          catch cx_sy_zerodivide.
        endtry.

*** Valor unitário do ISS no XML
        clear lv_sqn.
        select single value from zhms_tb_docmn into lv_sqn where chave eq wa_cabdoc-chave
                                                             and mneum eq 'ATVISSQN'
                                                             and atitm eq wa_itmatr-atitm.

        if sy-subrc is initial.
          clear lv_div_xml.
          lv_div_xml = lv_sqn / lv_qtd_at.

* Alv de Auditoria
          wa_alv_ped-item = wa_itmatr-atitm.
          wa_alv_ped-impo = 'ISS'.
          wa_alv_ped-valor = lv_div_ped.
          wa_alv_ped-valor2 = lv_div_xml.
          if lv_div_ped ne lv_div_xml.
            wa_alv_ped-farol = 1.
          else.
            wa_alv_ped-farol = 3.
          endif.

          append wa_alv_ped to t_alv_ped.
          clear wa_alv_ped.

          read table t_tb_vld_tax into ls_tb_vld_tax with key tax_type = 'ISS'.

          if lv_div_ped ne lv_div_xml and ls_tb_vld_tax-ativo is not initial.

          endif.
        endif.

*** Valor do ICMSST do XML difere do pedido de compra
        refresh t_1baj[].
        select *
          from j_1baj
          into table t_1baj
          for all entries in t_komv
         where taxtyp = t_komv-kschl
           and taxgrp = 'ICST'.

        clear lv_tot_kbetr .
        loop at t_1baj into wa_1baj.
          loop at t_komv into wa_komv where kschl eq wa_1baj-taxtyp.
            lv_tot_kbetr = lv_tot_kbetr + wa_komv-kawrt.
          endloop.
        endloop.

*** Valor unitário do ICST no Pedido
        clear lv_div_ped .
        try .
            lv_div_ped = lv_tot_kbetr / lv_qtd.
          catch cx_sy_zerodivide .
        endtry.

*** Valor unitário do ICST no XML
        clear lv_sst.
        select single value from zhms_tb_docmn into lv_sst  where chave eq wa_cabdoc-chave
                                                              and mneum eq 'ATVICMSST'
                                                              and atitm eq wa_itmatr-atitm.

        if sy-subrc is initial.
          clear lv_div_xml.
          try .
              lv_div_xml = lv_sst / lv_qtd_at.
            catch cx_sy_zerodivide.
          endtry.

* Alv de Auditoria
          wa_alv_ped-item = wa_itmatr-atitm.
          wa_alv_ped-impo = 'ICST'.
          wa_alv_ped-valor = lv_div_ped.
          wa_alv_ped-valor2 = lv_div_xml.
          if lv_div_ped ne lv_div_xml.
            wa_alv_ped-farol = 1.
          else.
            wa_alv_ped-farol = 3.
          endif.
          append wa_alv_ped to t_alv_ped.
          clear wa_alv_ped.


          read table t_tb_vld_tax into ls_tb_vld_tax with key tax_type = 'ICMSST'.

          if lv_div_ped ne lv_div_xml and ls_tb_vld_tax-ativo is not initial.

          endif.
        endif.
*      ENDIF.

        if wa_cabdoc-typed = 'NFSE1'.

*PIS
          clear lv_tot_kbetr.
          loop at t_komv into wa_komv where kschl eq 'BW12'.
            lv_tot_kbetr = lv_tot_kbetr + wa_komv-kwert.
          endloop.
          if lv_tot_kbetr < 0.
            lv_tot_kbetr = lv_tot_kbetr * -1.
          endif.

          clear lv_cof.
          select single value from zhms_tb_docmn into lv_cof where chave eq wa_cabdoc-chave
                                                               and mneum eq 'PIS'.

          if sy-subrc is initial.

            wa_alv_ped-item = wa_itmatr-atitm.
            wa_alv_ped-impo = 'PIS'.
            wa_alv_ped-valor = lv_tot_kbetr.
            wa_alv_ped-valor2 = lv_cof.
            if lv_tot_kbetr ne lv_cof.
              wa_alv_ped-farol = 1.
            else.
              wa_alv_ped-farol = 3.
            endif.

            append wa_alv_ped to t_alv_ped.
            clear wa_alv_ped.

          endif.

*COFINS
          clear lv_tot_kbetr.
          loop at t_komv into wa_komv where kschl eq 'BW22'.
            lv_tot_kbetr = lv_tot_kbetr + wa_komv-kwert.
          endloop.
          if lv_tot_kbetr < 0.
            lv_tot_kbetr = lv_tot_kbetr * -1.
          endif.

          clear lv_cof.
          select single value from zhms_tb_docmn into lv_cof where chave eq wa_cabdoc-chave
                                                               and mneum eq 'COFINS'.

          if sy-subrc is initial.

            wa_alv_ped-item = wa_itmatr-atitm.
            wa_alv_ped-impo = 'COFINS'.
            wa_alv_ped-valor = lv_tot_kbetr.
            wa_alv_ped-valor2 = lv_cof.
            if lv_tot_kbetr ne lv_cof.
              wa_alv_ped-farol = 1.
            else.
              wa_alv_ped-farol = 3.
            endif.

            append wa_alv_ped to t_alv_ped.
            clear wa_alv_ped.

          endif.

*IR
          clear lv_tot_kbetr.
          loop at t_komv into wa_komv where kschl eq 'BW42'.
            lv_tot_kbetr = lv_tot_kbetr + wa_komv-kwert.
          endloop.
          if lv_tot_kbetr < 0.
            lv_tot_kbetr = lv_tot_kbetr * -1.
          endif.

          clear lv_cof.
          select single value from zhms_tb_docmn into lv_cof where chave eq wa_cabdoc-chave
                                                               and mneum eq 'IR'.

          if sy-subrc is initial.

            wa_alv_ped-item = wa_itmatr-atitm.
            wa_alv_ped-impo = 'IR'.
            wa_alv_ped-valor = lv_tot_kbetr.
            wa_alv_ped-valor2 = lv_cof.
            if lv_tot_kbetr ne lv_cof.
              wa_alv_ped-farol = 1.
            else.
              wa_alv_ped-farol = 3.
            endif.

            append wa_alv_ped to t_alv_ped.
            clear wa_alv_ped.

          endif.

*CSLL
          clear lv_tot_kbetr.
          loop at t_komv into wa_komv where kschl eq 'BW32'.
            lv_tot_kbetr = lv_tot_kbetr + wa_komv-kwert.
          endloop.
          if lv_tot_kbetr < 0.
            lv_tot_kbetr = lv_tot_kbetr * -1.
          endif.

          clear lv_cof.
          select single value from zhms_tb_docmn into lv_cof where chave eq wa_cabdoc-chave
                                                               and mneum eq 'CSLL'.

          if sy-subrc is initial.

            wa_alv_ped-item = wa_itmatr-atitm.
            wa_alv_ped-impo = 'CSLL'.
            wa_alv_ped-valor = lv_tot_kbetr.
            wa_alv_ped-valor2 = lv_cof.
            if lv_tot_kbetr ne lv_cof.
              wa_alv_ped-farol = 1.
            else.
              wa_alv_ped-farol = 3.
            endif.

            append wa_alv_ped to t_alv_ped.
            clear wa_alv_ped.

          endif.

*ISS
          clear lv_tot_kbetr.
          loop at t_komv into wa_komv where kschl eq 'BX51'.
            lv_tot_kbetr = lv_tot_kbetr + wa_komv-kwert.
          endloop.
          if lv_tot_kbetr < 0.
            lv_tot_kbetr = lv_tot_kbetr * -1.
          endif.

          clear lv_cof.
          select single value from zhms_tb_docmn into lv_cof where chave eq wa_cabdoc-chave
                                                               and mneum eq 'LIQUIDO'.

          if sy-subrc is initial.

            wa_alv_ped-item = wa_itmatr-atitm.
            wa_alv_ped-impo = 'ISS'.
            wa_alv_ped-valor = lv_tot_kbetr.
            wa_alv_ped-valor2 = lv_cof.
            if lv_tot_kbetr ne lv_cof.
              wa_alv_ped-farol = 1.
            else.
              wa_alv_ped-farol = 3.
            endif.

            append wa_alv_ped to t_alv_ped.
            clear wa_alv_ped.

          endif.

        endif.
      endloop.

      loop at t_alv_ped assigning field-symbol(<fs_alv_ped>).
        condense <fs_alv_ped>-valor no-gaps.
        condense <fs_alv_ped>-valor2 no-gaps.
        condense <fs_alv_ped>-basexml no-gaps.
        condense <fs_alv_ped>-baseped no-gaps.

        if <fs_alv_ped>-valor eq '0.00'
          and <fs_alv_ped>-valor2 eq '0.00'.
          clear: <fs_alv_ped>-baseped,
                 <fs_alv_ped>-basexml,
                 <fs_alv_ped>-farol .
        endif.

      endloop.


    endmodule.                 " M_CALC_AUDI  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  M_ALV  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    module m_alv output.
*      REFRESH t_ht_field[].
*      DATA: it_exclude TYPE ui_functions.
*
**** Natureza Documento
*      CLEAR wa_hvalid_fldc.
*      wa_ht_field-fieldname = 'ITEM'.
*      wa_ht_field-reptext   = 'Item'.
*      wa_ht_field-col_opt   = 'X'.
*      APPEND wa_ht_field TO t_ht_field.
*      CLEAR wa_ht_field.
*
**** Tipo Documento
*      CLEAR wa_hvalid_fldc.
*      wa_ht_field-fieldname = 'IMPO'.
*      wa_ht_field-reptext   = 'Imposto'.
*      wa_ht_field-col_opt   = 'X'.
*      APPEND wa_ht_field TO t_ht_field.
*      CLEAR wa_ht_field.
*
**** Evento
*      CLEAR wa_hvalid_fldc.
*      wa_ht_field-fieldname = 'VALOR'.
*      wa_ht_field-reptext   = 'Valor Imposto'.
*      wa_ht_field-col_opt   = 'X'.
*      APPEND wa_ht_field TO t_ht_field.
*      CLEAR wa_ht_field.
*
*      PERFORM zf_exclude.
*
*** CC para o alv do XML
*      IF ob_cc_ht IS NOT INITIAL.
*        CALL METHOD ob_cc_ht->free.
*      ENDIF.
*
*      CREATE OBJECT ob_cc_ht
*        EXPORTING
*          container_name = 'CC_XML'.
*
*      CREATE OBJECT ob_cc_ht_grid
*        EXPORTING
*          i_parent = ob_cc_ht.
*
*      CALL METHOD ob_cc_ht_grid->set_table_for_first_display
*        EXPORTING
*          it_toolbar_excluding          = it_exclude
*        CHANGING
*          it_outtab                     = t_alv_xml[]
*          it_fieldcatalog               = t_ht_field[]
*        EXCEPTIONS
*          invalid_parameter_combination = 1
*          program_error                 = 2
*          too_many_lines                = 3
*          OTHERS                        = 4.
*
*** CC para o alv do PEDIDO
*      IF ob_cc_ht IS NOT INITIAL.
*        CALL METHOD ob_cc_ht->free.
*      ENDIF.
*
*      CREATE OBJECT ob_cc_ht
*        EXPORTING
*          container_name = 'CC_PEDIDO'.
*
*      CREATE OBJECT ob_cc_ht_grid
*        EXPORTING
*          i_parent = ob_cc_ht.
*
*      CALL METHOD ob_cc_ht_grid->set_table_for_first_display
*        EXPORTING
*          it_toolbar_excluding          = it_exclude
*        CHANGING
*          it_outtab                     = t_alv_ped[]
*          it_fieldcatalog               = t_ht_field[]
*        EXCEPTIONS
*          invalid_parameter_combination = 1
*          program_error                 = 2
*          too_many_lines                = 3
*          OTHERS                        = 4.
    endmodule.                 " M_ALV  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  M_ALV_AUDITORIA  OUTPUT
*&---------------------------------------------------------------------*
    module m_alv_auditoria_0606 output.
      data: it_exclude type ui_functions.

*      break rsantos.

      refresh t_ht_field[].
      refresh t_ht_field2[].
*      DATA: it_exclude TYPE ui_functions.
      data: lcl_event_receiver type ref to lcl_receiver,
            wa_layout_comp     type lvc_s_layo,
            wa_layout_ped      type lvc_s_layo,
            g_lights_name      type lvc_cifnm value 'FAROL'.


      clear wa_hvalid_fldc.
      wa_ht_field-fieldname = 'ITEM'.
      wa_ht_field-reptext   = 'Item'.
      wa_ht_field-col_opt   = 'X'.
      wa_ht_field-hotspot   = 'X'.
      append wa_ht_field to t_ht_field.
      clear wa_ht_field.

      clear wa_hvalid_fldc.
      wa_ht_field-fieldname = 'DESC'.
      wa_ht_field-reptext   = 'Desc. Item'.
      wa_ht_field-col_opt   = 'X'.
      wa_ht_field-hotspot   = 'X'.
      append wa_ht_field to t_ht_field.
      clear wa_ht_field.

*      CLEAR wa_hvalid_fldc.
*      wa_ht_field-fieldname = 'UNIDADE'.
*      wa_ht_field-reptext   = 'Unidade'.
*      wa_ht_field-col_opt   = 'X'.
*      wa_ht_field-hotspot   = 'X'.
*      APPEND wa_ht_field TO t_ht_field.
*      CLEAR wa_ht_field.

      clear wa_hvalid_fldc.
      wa_ht_field-fieldname = 'QTDE'.
      wa_ht_field-reptext   = 'Quantidade'.
      wa_ht_field-col_opt   = 'X'.
      wa_ht_field-hotspot   = 'X'.
      append wa_ht_field to t_ht_field.
      clear wa_ht_field.

*      CLEAR wa_hvalid_fldc.
*      wa_ht_field-fieldname = 'VPROD'.
*      wa_ht_field-reptext   = 'Val. Prod.'.
*      wa_ht_field-col_opt   = 'X'.
*      wa_ht_field-hotspot   = 'X'.
*      APPEND wa_ht_field TO t_ht_field.
*      CLEAR wa_ht_field.

*      CLEAR wa_hvalid_fldc.
*      wa_ht_field-fieldname = 'PICMS'.
*      wa_ht_field-reptext   = 'Aliq. ICMS'.
*      wa_ht_field-col_opt   = 'X'.
*      wa_ht_field-hotspot   = 'X'.
*      APPEND wa_ht_field TO t_ht_field.
*      CLEAR wa_ht_field.
*
*      CLEAR wa_hvalid_fldc.
*      wa_ht_field-fieldname = 'VICMS'.
*      wa_ht_field-reptext   = 'Val. ICMS'.
*      wa_ht_field-col_opt   = 'X'.
*      wa_ht_field-hotspot   = 'X'.
*      APPEND wa_ht_field TO t_ht_field.
*      CLEAR wa_ht_field.
*
*      CLEAR wa_hvalid_fldc.
*      wa_ht_field-fieldname = 'PIPI'.
*      wa_ht_field-reptext   = 'Aliq. IPI'.
*      wa_ht_field-col_opt   = 'X'.
*      wa_ht_field-hotspot   = 'X'.
*      APPEND wa_ht_field TO t_ht_field.
*      CLEAR wa_ht_field.
*
*      CLEAR wa_hvalid_fldc.
*      wa_ht_field-fieldname = 'VIPI'.
*      wa_ht_field-reptext   = 'Val. IPI'.
*      wa_ht_field-col_opt   = 'X'.
*      wa_ht_field-hotspot   = 'X'.
*      APPEND wa_ht_field TO t_ht_field.
*      CLEAR wa_ht_field.
*
*      CLEAR wa_hvalid_fldc.
*      wa_ht_field-fieldname = 'PPIS'.
*      wa_ht_field-reptext   = 'Aliq. PIS'.
*      wa_ht_field-col_opt   = 'X'.
*      wa_ht_field-hotspot   = 'X'.
*      APPEND wa_ht_field TO t_ht_field.
*      CLEAR wa_ht_field.
*
*      CLEAR wa_hvalid_fldc.
*      wa_ht_field-fieldname = 'VPIS'.
*      wa_ht_field-reptext   = 'Val. PIS'.
*      wa_ht_field-col_opt   = 'X'.
*      wa_ht_field-hotspot   = 'X'.
*      APPEND wa_ht_field TO t_ht_field.
*      CLEAR wa_ht_field.
*
*      CLEAR wa_hvalid_fldc.
*      wa_ht_field-fieldname = 'PCOFINS'.
*      wa_ht_field-reptext   = 'Aliq. COFINS'.
*      wa_ht_field-col_opt   = 'X'.
*      wa_ht_field-hotspot   = 'X'.
*      APPEND wa_ht_field TO t_ht_field.
*      CLEAR wa_ht_field.
*
*      CLEAR wa_hvalid_fldc.
*      wa_ht_field-fieldname = 'VCOFINS'.
*      wa_ht_field-reptext   = 'Val. COFINS'.
*      wa_ht_field-col_opt   = 'X'.
*      wa_ht_field-hotspot   = 'X'.
*      APPEND wa_ht_field TO t_ht_field.
*      CLEAR wa_ht_field.

* ALV 2
      clear wa_hvalid_fldc.
      wa_ht_field-fieldname = 'IMPO'.
      wa_ht_field-reptext   = 'Imposto'.
      wa_ht_field-col_opt   = 'X'.
      append wa_ht_field to t_ht_field2.
      clear wa_ht_field.

      clear wa_hvalid_fldc.
      wa_ht_field-fieldname = 'BASEPED'.
      wa_ht_field-reptext   = 'Base Ped.'.
      wa_ht_field-col_opt   = 'X'.
      append wa_ht_field to t_ht_field2.
      clear wa_ht_field.

      clear wa_hvalid_fldc.
      wa_ht_field-fieldname = 'VALOR'.
      wa_ht_field-reptext   = 'Valor Pedido'.
      wa_ht_field-col_opt   = 'X'.
      append wa_ht_field to t_ht_field2.
      clear wa_ht_field.

      clear wa_hvalid_fldc.
      wa_ht_field-fieldname = 'BASEXML'.
      wa_ht_field-reptext   = 'Base XML'.
      wa_ht_field-col_opt   = 'X'.
      append wa_ht_field to t_ht_field2.
      clear wa_ht_field.

      clear wa_hvalid_fldc.
      wa_ht_field-fieldname = 'VALOR2'.
      wa_ht_field-reptext   = 'Valor XML'.
      wa_ht_field-col_opt   = 'X'.
      append wa_ht_field to t_ht_field2.
      clear wa_ht_field.

      clear wa_hvalid_fldc.
      wa_ht_field-fieldname = 'FAROL'.
      wa_ht_field-reptext   = 'Diferença'.
      wa_ht_field-col_opt   = 'X'.
      append wa_ht_field to t_ht_field2.
      clear wa_ht_field.

* ALV 3 - Comparações simples (valor unit, ncm...)
      clear t_ht_field3.
      clear wa_hvalid_fldc.
      wa_ht_field-fieldname = 'IMPO'.
      wa_ht_field-reptext   = 'Tipo do Dado'.
      wa_ht_field-col_opt   = 'X'.
      wa_ht_field-hotspot   = 'X'.
      append wa_ht_field to t_ht_field3.
      clear wa_ht_field.

      clear wa_hvalid_fldc.
      wa_ht_field-fieldname = 'VALOR'.
      wa_ht_field-reptext   = 'Valor analisado do P.O.'.
      wa_ht_field-col_opt   = 'X'.
      append wa_ht_field to t_ht_field3.
      clear wa_ht_field.

      clear wa_hvalid_fldc.
      wa_ht_field-fieldname = 'VALOR2'.
      wa_ht_field-reptext   = 'Valor analisado do XML'.
      wa_ht_field-col_opt   = 'X'.
      append wa_ht_field to t_ht_field3.
      clear wa_ht_field.

* Remove Botoes
      perform zf_exclude.

** CC para o alv do XML
      if ob_cc_ped is not initial.
        call method ob_cc_ped->free.
      endif.

      create object ob_cc_ped
        exporting
          container_name = 'CC_ITEM'.

      create object ob_cc_ped_grid
        exporting
          i_parent = ob_cc_ped.

      wa_layout_ped-zebra = 'X'.

      call method ob_cc_ped_grid->set_table_for_first_display
        exporting
          it_toolbar_excluding          = it_exclude
          is_layout                     = wa_layout_ped
        changing
          it_outtab                     = t_alv_xml[]
          it_fieldcatalog               = t_ht_field[]
        exceptions
          invalid_parameter_combination = 1
          program_error                 = 2
          too_many_lines                = 3
          others                        = 4.

      create object lcl_event_receiver.
      set handler lcl_event_receiver->handel_hotspot_click for ob_cc_ped_grid.

** CC para o alv do PEDIDO
      if ob_cc_xml is not initial.
        call method ob_cc_xml->free.
      endif.

      create object ob_cc_xml
        exporting
          container_name = 'CC_ITEM_DETALHE '.

      create object ob_cc_xml_grid
        exporting
          i_parent = ob_cc_xml.

      wa_layout_comp-excp_fname = g_lights_name.
      wa_layout_comp-zebra      = 'X'.

      call method ob_cc_xml_grid->set_table_for_first_display
        exporting
          it_toolbar_excluding          = it_exclude
          is_layout                     = wa_layout_comp
        changing
          it_outtab                     = t_alv_ped_aux[]
          it_fieldcatalog               = t_ht_field2[]
        exceptions
          invalid_parameter_combination = 1
          program_error                 = 2
          too_many_lines                = 3
          others                        = 4.

** CC para o alv do XML
      if ob_cc_comp is not initial.
        call method ob_cc_comp->free.
      endif.

      create object ob_cc_comp
        exporting
          container_name = 'CC_COMP'.

      create object ob_cc_comp_grid
        exporting
          i_parent = ob_cc_comp.

      wa_layout_comp-excp_fname = g_lights_name.
      wa_layout_comp-zebra      = 'X'.

      call method ob_cc_comp_grid->set_table_for_first_display
        exporting
          it_toolbar_excluding          = it_exclude
          is_layout                     = wa_layout_comp
        changing
          it_outtab                     = t_alv_comp_au[]
          it_fieldcatalog               = t_ht_field3[]
        exceptions
          invalid_parameter_combination = 1
          program_error                 = 2
          too_many_lines                = 3
          others                        = 4.
      create object lcl_event_receiver.
      set handler lcl_event_receiver->handel_hotspot_click for ob_cc_comp_grid.
    endmodule.                 " M_ALV_AUDITORIA  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  ZF_EXCLUDE
*&---------------------------------------------------------------------*
    form zf_exclude .

      data ls_exclude type ui_func.

      clear it_exclude.

      ls_exclude = cl_gui_alv_grid=>mc_fc_auf. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_average. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_back_classic. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_call_abc. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_call_chain. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_call_crbatch. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_call_crweb. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_call_lineitems. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_call_master_data. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_call_more. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_call_report. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_call_xint. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_call_xxl. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_check. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_col_invisible. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_col_optimize. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_count. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_current_variant. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_data_save. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_delete_filter. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_deselect_all. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_detail. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_excl_all. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_expcrdata. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_expcrdesig. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_expcrtempl. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_expmdb. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_extend. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_f4. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_filter. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_find. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_fix_columns. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_graph. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_help. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_html. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_info. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_load_variant. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_loc_move_row. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_maintain_variant. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_maximum. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_minimum. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_pc_file. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_print. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_print_back. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_print_prev. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_refresh. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_reprep. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_save_variant. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_select_all. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_send. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_separator. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_sort. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_sort_asc. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_sort_dsc. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_subtot. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_sum. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_to_office. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_to_rep_tree. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_unfix_columns. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_url_copy_to_clipboard. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_variant_admin. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_views. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_view_crystal. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_view_excel. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_view_grid. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_view_lotus. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row. append ls_exclude to it_exclude.
      ls_exclude = cl_gui_alv_grid=>mc_fc_auf. append ls_exclude to it_exclude.

    endform.                    " ZF_EXCLUDE
*&---------------------------------------------------------------------*
*&      Module  M_STATUS_0506  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    module m_status_0506 output.

      set pf-status '0500'.
      set titlebar '0500'.


    endmodule.
*&---------------------------------------------------------------------*
*&      Module  M_STATUS_0607  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    module m_status_0607 output.
*        DATA: tl_codes       TYPE TABLE OF sy-ucomm.
*
*      SET TITLEBAR  '0500'.
*      REFRESH tl_codes.
*
*      IF vg_0500 EQ '0501'.
*        APPEND: 'ATR_GRAVAR' TO tl_codes.
*      ENDIF.
*
*      SET PF-STATUS '0500' EXCLUDING tl_codes.
    endmodule.
