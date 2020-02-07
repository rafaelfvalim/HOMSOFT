*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_GATEO01 .
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*   Module  M_LOAD_HTML_RCP  OUTPUT
*----------------------------------------------------------------------*
*   Carregando Objeto HTML dos Documentos
*----------------------------------------------------------------------*
    module m_load_html_rcp output.

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

**----------------------------------------------------------------------*
**  MODULE TS_RCB_INPUT_ACTIVE_TAB_SET OUTPUT
**----------------------------------------------------------------------*
**  Controles para subtelas de seleção do recebimento
**----------------------------------------------------------------------*
*    MODULE ts_rcb_input_active_tab_set OUTPUT.
*      ts_rcb_input-activetab = g_ts_rcb_input-pressed_tab.
*      CASE g_ts_rcb_input-pressed_tab.
*        WHEN c_ts_rcb_input-tab1.
*          g_ts_rcb_input-subscreen = '0501'.
*        WHEN c_ts_rcb_input-tab2.
*          g_ts_rcb_input-subscreen = '0502'.
*        WHEN OTHERS.
*
*      ENDCASE.
*    ENDMODULE.                    "TS_RCB_INPUT_ACTIVE_TAB_SET OUTPUT

*----------------------------------------------------------------------*
*  MODULE TC_prt_DOCRCBTO_CHANGE_TC_ATTR OUTPUT
*----------------------------------------------------------------------*
*   Lista de documentos recebidos
*----------------------------------------------------------------------*
    module tc_prt_docrcbto_change_tc_attr output.
      describe table t_docrcbto_ax lines tc_prt_docrcbto-lines.
    endmodule.                    "TC_prt_DOCRCBTO_CHANGE_TC_ATTR OUTPUT
*&---------------------------------------------------------------------*
*&      Module  M_STATUS_500  OUTPUT
*&---------------------------------------------------------------------*
*       Definições para tela 500
*----------------------------------------------------------------------*
    module m_status_500 output.
      set pf-status '0500' .

      select single * from zhms_tb_show_lay into wa_show_lay where ativo eq 'X'.

      if wa_show_lay-tipo eq 'NDD'.
        set titlebar  '0501'.
      else.
        set titlebar  '0500'.
      endif.
    endmodule.                 " M_STATUS_500  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  M_STATUS_400  OUTPUT
*&---------------------------------------------------------------------*
*       Definições para tela 500
*----------------------------------------------------------------------*
    module m_status_400 output.
      set pf-status '0400' .

      select single * from zhms_tb_show_lay into wa_show_lay where ativo eq 'X'.

      if wa_show_lay-tipo eq 'NDD'.
        set titlebar  '0401'.
      else.
        set titlebar  '0400'.
      endif.


    endmodule.                 " M_STATUS_500  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  M_LOAD_LIST  OUTPUT
*&---------------------------------------------------------------------*
*       Carrega o Histórico de portarias
*----------------------------------------------------------------------*
    module m_load_list output.
      perform f_load_list.
    endmodule.                 " M_LOAD_LIST  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  M_LOAD_LIST_CONF  OUTPUT
*&---------------------------------------------------------------------*
*       Carrega o Histórico de conferências
*----------------------------------------------------------------------*
    module m_load_list_conf output.
      perform f_load_list_conf.
    endmodule.                 " M_LOAD_LIST_CONF  OUTPUT

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
      if vg_msgimg is initial. "Nenhum documento Selecionado
        clear vl_objid.
        concatenate 'ZHMS_IC_NOSELECTION_' sy-langu
               into vl_objid.
      endif.

      if vg_msgimg eq 1. "Portaria Realizada com sucesso
        clear vl_objid.
        concatenate 'ZHMS_IC_PORTARIAOK_' sy-langu
               into vl_objid.
      endif.

      if vg_msgimg eq 3. "Portaria Realizada com sucesso
        clear vl_objid.
        concatenate 'ZHMS_IC_CONFOK_' sy-langu
               into vl_objid.
      endif.

      if vg_msgimg eq 2. "Erro!
        vl_objid = 'ZHMS_IC_ERRO'.
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
*  MODULE TS_RCB_METH_ACTIVE_TAB_SET OUTPUT
*----------------------------------------------------------------------*
* Controles para Tabstrip de seleção Portaria
*----------------------------------------------------------------------*
    module ts_rcb_meth_active_tab_set output.
      break rhitokaz.
      ts_rcb_meth-activetab = g_ts_rcb_meth-pressed_tab.
      case g_ts_rcb_meth-pressed_tab.
        when c_ts_rcb_meth-tab1.
          g_ts_rcb_meth-subscreen = '0505'.
        when c_ts_rcb_meth-tab2.
          g_ts_rcb_meth-subscreen = '0506'.
        when others.

      endcase.
    endmodule.                    "TS_RCB_METH_ACTIVE_TAB_SET OUTPUT

*----------------------------------------------------------------------*
*  MODULE TS_CONF_METH_ACTIVE_TAB_SET OUTPUT
*----------------------------------------------------------------------*
* Controles Tabstrip seleção de documentos para conferencia
*----------------------------------------------------------------------*
    module ts_conf_meth_active_tab_set output.
      ts_conf_meth-activetab = g_ts_conf_meth-pressed_tab.
      case g_ts_conf_meth-pressed_tab.
        when c_ts_conf_meth-tab1.
          g_ts_conf_meth-subscreen = '0405'.
        when c_ts_conf_meth-tab2.
          g_ts_conf_meth-subscreen = '0406'.
        when others.

      endcase.
    endmodule.                    "TS_CONF_METH_ACTIVE_TAB_SET OUTPUT

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
            exporting
              nobar   = 'X'
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

      endif.

    endmodule.                 " M_LOAD_HTML_det  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  M_PREENCHE_CABECALHO  OUTPUT
*&---------------------------------------------------------------------*
*       Preencher dados de cabeçalho para edição de conferencia
*----------------------------------------------------------------------*
    module m_preenche_cabecalho output.
**    Limpa estrutura de cabeçalho
      clear wa_docconf.

**    Busca sequencia para a nota.
      select max( seqnr )
        into wa_docconf-seqnr
        from zhms_tb_docconf
       where natdc = wa_cabdoc-natdc
         and typed = wa_cabdoc-typed
         and chave = wa_cabdoc-chave.

      add 1 to wa_docconf-seqnr.

**    Insere dados nas variáveis
      wa_docconf-natdc = wa_cabdoc-natdc.
      wa_docconf-typed = wa_cabdoc-typed.
      wa_docconf-chave = wa_cabdoc-chave.
      wa_docconf-dtreg = sy-datum.
      wa_docconf-hrreg = sy-uzeit.
      wa_docconf-uname = sy-uname.
      wa_docconf-dcnro = wa_cabdoc-docnr.
      wa_docconf-parid = wa_cabdoc-parid.
      wa_docconf-ativo = 'X'.
      wa_docconf-logty = 'I'.


      case wa_docconf-logty.
        when 'E'.
          vg_conf_status = '@0A@'.
        when 'W'.
          vg_conf_status = '@09@'.
        when 'I'.
          vg_conf_status = '@08@'.
        when 'S'.
          vg_conf_status = '@01@'.
        when others.
          vg_conf_status = '@08@'.
      endcase.

    endmodule.                 " M_PREENCHE_CABECALHO  OUTPUT


*----------------------------------------------------------------------*
*  MODULE TC_CNF_DATCONF_CHANGE_TC_ATTR OUTPUT
*----------------------------------------------------------------------*
*  Table Control de conferencia
*----------------------------------------------------------------------*
    module tc_cnf_datconf_change_tc_attr output.
      describe table t_datconf_ax lines tc_cnf_datconf-lines.
    endmodule.                    "TC_CNF_DATCONF_CHANGE_TC_ATTR OUTPUT


*----------------------------------------------------------------------*
*  MODULE m_preenche_itens OUTPUT
*----------------------------------------------------------------------*
*  Popular dados para contagem
*----------------------------------------------------------------------*
    module m_preenche_itens output.

      if t_datconf_ax[] is not initial.
        exit.
      endif.

** Limpa tabela interna de contagem
      refresh t_datconf_ax.

** Percorre itens do documento
      loop at t_itmdoc into wa_itmdoc.
**      Mover dados de item para tabela de contagem
        clear wa_datconf_ax.
        move-corresponding wa_itmdoc to wa_datconf_ax.
**      Registrar na tabela de contagem
        append wa_datconf_ax to t_datconf_ax.
      endloop.

    endmodule.                    "m_preenche_itens OUTPUT

*----------------------------------------------------------------------*
*  MODULE m_preenche_itens_contados OUTPUT
*----------------------------------------------------------------------*
*  Popular dados para contagem
*----------------------------------------------------------------------*
    module m_preenche_itens_contados output.

      if t_datconf_ax[] is not initial.
        exit.
      endif.

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
*  MODULE TC_CNF_DOCCONF_CHANGE_TC_ATTR OUTPUT
*----------------------------------------------------------------------*
*  Table control para histórico de conferencias (401)
*----------------------------------------------------------------------*
    module tc_cnf_docconf_change_tc_attr output.
      describe table t_docconf_ax lines tc_cnf_docconf-lines.
    endmodule.                    "TC_CNF_DOCCONF_CHANGE_TC_ATTR OUTPUT


*----------------------------------------------------------------------*
*  MODULE TC_CNF_DOCCONF2_CHANGE_TC_ATTR OUTPUT
*----------------------------------------------------------------------*
*  Table control para histórico de conferencias (402)
*----------------------------------------------------------------------*
    module tc_cnf_docconf2_change_tc_attr output.
      describe table t_datconf_ax lines tc_cnf_docconf2-lines.
    endmodule.                    "TC_CNF_DOCCONF2_CHANGE_TC_ATTR OUTPUT

*{   INSERT         DEVK900123                                        1
*&---------------------------------------------------------------------*
*&      Module  STATUS_0110  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    module status_0110 output.

      get parameter id 'ZVG_CNF_CHAVE' field vg_cnf_chave.
      get parameter id 'ZVG_CNF_CHAVE' field vg_prt_chave.
      set parameter id 'ZVG_CNF_CHAVE' field space.

    endmodule.                 " STATUS_0110  OUTPUT

*}   INSERT
