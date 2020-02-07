*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_GATEF01 .
*----------------------------------------------------------------------*

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
              'X'                         to wa_event-appl_event.
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

*&---------------------------------------------------------------------*
*&      Form  F_RCB_BUSCACHAVE
*&---------------------------------------------------------------------*
*       Busca o documento da base HomSoft
*----------------------------------------------------------------------*
    form f_rcb_buscachave .

      check not vg_prt_chave is initial.

      clear: wa_cabdoc, v_gate.

** Seleção da tabela de documentos
      select single *
        into wa_cabdoc
        from zhms_tb_cabdoc
       where chave eq vg_prt_chave.

***   Verifica se foi encontrada correspondencia

      if not sy-subrc is initial.
***       Nenhum documento encontrado
        clear: vg_prt_chave, vg_prt_chave_a, vg_msgimg.
        v_detdoc = '0504'.
        message e000 with text-001.

      endif.

**    Verifica se já existe portaria para o documento
      clear wa_docrcbto.
      refresh t_datrcbto.

      select single *
        into wa_docrcbto
        from zhms_tb_docrcbto
       where chave eq vg_prt_chave
         and ativo eq 'X'.

**    Portaria encontrada
      if sy-subrc is initial.
**        Buscar dados de portaria
        select *
          into table t_datrcbto
          from zhms_tb_datrcbto
         where chave eq vg_prt_chave.

      endif.

    endform.                    " F_RCB_BUSCACHAVE

*&---------------------------------------------------------------------*
*&      Form  F_CNF_BUSCACHAVE
*&---------------------------------------------------------------------*
*       Busca o documento da base HomSoft
*----------------------------------------------------------------------*
    form f_cnf_buscachave .

      check not vg_cnf_chave is initial.

      clear: wa_cabdoc, v_gate.

** Seleção da tabela de documentos
      select single *
        into wa_cabdoc
        from zhms_tb_cabdoc
       where chave eq vg_cnf_chave.

***   Verifica se foi encontrada correspondencia

      if not sy-subrc is initial.
***       Nenhum documento encontrado
        clear: vg_cnf_chave, vg_cnf_chave_a, vg_msgimg.
        v_detdoc = '0504'.
        message e000 with text-001.
      else.
**      Busca Itens do documento
        refresh t_itmdoc.
        select *
          into table t_itmdoc
          from zhms_tb_itmdoc
         where natdc eq wa_cabdoc-natdc
           and typed eq wa_cabdoc-typed
           and chave eq wa_cabdoc-chave.
      endif.

**    Verifica se já existe contagem para o documento
      clear wa_docconf.
      refresh t_datconf.

      select single *
        into wa_docconf
        from zhms_tb_docconf
       where chave eq vg_cnf_chave
         and ativo eq 'X'.

**    Contagem encontrada
      if sy-subrc is initial.
**        Buscar dados de portaria
        select *
          into table t_datconf
          from zhms_tb_datconf
         where chave eq vg_cnf_chave
           and seqnr eq wa_docconf-seqnr.
      endif.

    endform.                    " F_CNF_BUSCACHAVE

*&---------------------------------------------------------------------*
*&      Form  F_RCB_BUSCADOCNR
*&---------------------------------------------------------------------*
*       Busca o documento da base HomSoft
*----------------------------------------------------------------------*
    form f_rcb_buscadocnr .

      check not zhms_tb_cabdoc-docnr is initial.

      clear: wa_cabdoc, v_gate, c_flag.

** Seleção da tabela de documentos
      select single *
        into wa_cabdoc
        from zhms_tb_cabdoc
       where parid eq zhms_tb_cabdoc-parid
         and docnr eq zhms_tb_cabdoc-docnr.

***   Verifica se foi encontrada correspondencia

      if not sy-subrc is initial.
***       Nenhum documento encontrado
        clear: vg_cnf_chave, vg_cnf_chave_a, vg_msgimg.
        v_detdoc = '0504'.
        message e000 with text-001.
      else.
        vg_prt_chave   = wa_cabdoc-chave.
        vg_prt_chave_a = vg_prt_chave.
        c_flag = abap_true.
      endif.

**    Verifica se já existe portaria para o documento
      clear wa_docrcbto.
      refresh t_datrcbto.

      select single *
        into wa_docrcbto
        from zhms_tb_docrcbto
       where chave eq vg_prt_chave
         and ativo eq 'X'.

**    Portaria encontrada
      if sy-subrc is initial.
**        Buscar dados de portaria
        select *
          into table t_datrcbto
          from zhms_tb_datrcbto
         where chave eq vg_prt_chave.

      endif.

    endform.                    " F_RCB_BUSCADOCNR

*&---------------------------------------------------------------------*
*&      Form  F_CNF_BUSCADOCNR
*&---------------------------------------------------------------------*
*       Busca o documento da base HomSoft
*----------------------------------------------------------------------*
    form f_cnf_buscadocnr .

      check not zhms_tb_cabdoc-docnr is initial.

      clear: wa_cabdoc, v_gate.

** Seleção da tabela de documentos
      select single *
        into wa_cabdoc
        from zhms_tb_cabdoc
       where parid eq zhms_tb_cabdoc-parid
         and docnr eq zhms_tb_cabdoc-docnr.

***   Verifica se foi encontrada correspondencia

      if not sy-subrc is initial.
***       Nenhum documento encontrado
        clear: vg_cnf_chave, vg_cnf_chave_a, vg_msgimg.
        v_detdoc = '0504'.
        message e000 with text-001.
      else.
**      Busca Itens do documento
        select *
          into table t_itmdoc
          from zhms_tb_itmdoc
         where natdc eq wa_cabdoc-natdc
           and typed eq wa_cabdoc-typed
           and chave eq wa_cabdoc-chave.

**      Preencher dados padrão
        vg_cnf_chave  = wa_cabdoc-chave.
        vg_cnf_chave_a = vg_cnf_chave.
      endif.

**    Verifica se já existe portaria para o documento
      clear wa_docconf.
      refresh t_datconf.

      select single *
        into wa_docconf
        from zhms_tb_docconf
       where chave eq vg_cnf_chave
         and ativo eq 'X'.

**    Portaria encontrada
      if sy-subrc is initial.
**        Buscar dados de portaria
        select *
          into table t_datconf
          from zhms_tb_datconf
         where chave eq vg_cnf_chave.

      endif.

    endform.                    " F_CNF_BUSCADOCNR

*----------------------------------------------------------------------*
*   Form  f_show_document_rcp
*----------------------------------------------------------------------*
*   Atualizar os status dos documentos
*----------------------------------------------------------------------*
    form f_show_document_rcp.
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
            vl_name   type j_1bbranch-name,
            lv_stent  type zhms_de_stent.

      refresh: t_datasrc, t_gatemneu, t_gatemneux, t_gateobs.

      clear: wa_datasrc.
      concatenate 'dc_numero.innerText=''' wa_cabdoc-docnr '-' wa_cabdoc-serie ''';' into wa_datasrc.
      append wa_datasrc to t_datasrc.

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
      concatenate 'dc_partnt.innerText=''' '(' wa_cabdoc-parid ')' vl_name1 ''';' into wa_datasrc.
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

*** Inicio Alteração David Rosin
      if vg_time is initial.
        if wa_docrcbto-logty is initial.

          update zhms_tb_docst
             set stent = 1
                 strec = 1
           where natdc eq wa_cabdoc-natdc
             and typed eq wa_cabdoc-typed
             and loctp eq wa_cabdoc-loctp
             and chave eq wa_cabdoc-chave.
          commit work and wait.

          append 'recp_status.innerHTML=''<img id="dc_recp" src="port_checking.gif" />'';' to t_datasrc.
*      ELSEIF wa_docrcbto-logty EQ 'S'.
*        APPEND 'recp_status.innerHTML=''<img id="dc_recp" src="port_ok.gif" />'';' TO t_datasrc.
*      ELSEIF wa_docrcbto-logty EQ 'W'.
*        APPEND 'recp_status.innerHTML=''<img id="dc_recp" src="port_cont.gif" />'';' TO t_datasrc.
        else.

          select single stent into lv_stent from  zhms_tb_docst where natdc eq wa_cabdoc-natdc
                                                                  and typed eq wa_cabdoc-typed
                                                                  and loctp eq wa_cabdoc-loctp
                                                                  and chave eq wa_cabdoc-chave.
          if sy-subrc is initial.
            case lv_stent.
              when 100.
                append 'recp_status.innerHTML=''<img id="dc_recp" src="port_ok.gif" />'';' to t_datasrc.
              when 101.
                append 'recp_status.innerHTML=''<img id="dc_recp" src="PORT_ERROR.GIF" />'';' to t_datasrc.
              when 102.
                append 'recp_status.innerHTML=''<img id="dc_recp" src="PORT_ERROR.GIF" />'';' to t_datasrc.
              when others.
                append 'recp_status.innerHTML=''<img id="dc_recp" src="port_cont.gif" />'';' to t_datasrc.
            endcase.
          endif.
        endif.
      else.
        append 'recp_status.innerHTML=''<img id="dc_recp" src="port_checking.gif" />'';' to t_datasrc.
      endif.
*** Fim alteração David Rosin
*      TODO:SELECIONAR ZHMS_TB_SCENARIO BUSCANDO GATE.

      if v_gate is initial.

        select single *
          into wa_gate
          from zhms_tb_gate
         where defau eq 'X'.

        if not sy-subrc is initial.
***       Erro Interno. Contatar Suporte.
          message e000 with text-000.
        else.
          v_gate = wa_gate-gate.
          if not wa_gate is initial.
**          Seleção dos dados a serem recuperados
            select *
              into table t_gatemneu
              from zhms_tb_gatemneu
             where gate eq wa_gate-gate.

**          Seleção dos textos dos dados para a língua de logon
            select *
              into table t_gatemneux
              from zhms_tx_gatemneu
             where gate  eq wa_gate-gate
               and spras eq sy-langu.

**           Seleção das observações para a lingua de logon
            select *
              into table t_gateobs
              from zhms_tb_gateobs
             where gate eq wa_gate-gate
               and spras eq sy-langu.


          endif.
        endif.

      endif.
**    Limpa exibição da tela
      append 'limpa_mneums();' to t_datasrc.
      clear vl_qtdmn.

**    Insere os Mneumonicos
      loop at t_gatemneu into wa_gatemneu.
        read table t_gatemneux into wa_gatemneux with key seqnr = wa_gatemneu-seqnr.

        clear: wa_datasrc.
        concatenate 'insere_mneum("' wa_gatemneux-denom '", "' wa_gatemneu-mneum '", "' wa_gatemneu-obrig '" , "' wa_gatemneu-seqnr '");' into wa_datasrc.
        append wa_datasrc to t_datasrc.
        add 1 to vl_qtdmn.

        clear: wa_datasrc.
        concatenate '  document.getElementById("mneumonico' wa_gatemneu-seqnr '").disabled=false;' into wa_datasrc.
        append wa_datasrc to t_datasrc.

        clear: wa_datasrc.
        concatenate '  document.getElementById("mneumonico' wa_gatemneu-seqnr '").className="txt_input";' into wa_datasrc.
        append wa_datasrc to t_datasrc.

      endloop.

**    Exibe itens default
      append ' exibe_default();' to t_datasrc.

**    Move foco
      if wa_docrcbto is initial.
        append ' start_timer();' to t_datasrc.
        if vl_qtdmn gt 0.
          append ' document.getElementById("mneumonico1").focus();' to t_datasrc.
        else.
          append ' document.getElementById("confirma").focus();' to t_datasrc.
        endif.
      endif.

**    Insere Observacoes
      sort t_gateobs by seqnr ascending.
      clear v_observ.

      loop at t_gateobs into wa_gateobs.
        concatenate v_observ '&nbsp;' wa_gateobs-obser into v_observ.
      endloop.
      if not v_observ is initial.
        v_observ = v_observ+6.
      endif.

      if v_observ is not initial.
        clear: wa_datasrc.
        concatenate 'insere_obs("' v_observ '");' into wa_datasrc.
        append wa_datasrc to t_datasrc.
      endif.

**     Insere valores nos mneumonicos caso portaria existente
      loop at t_datrcbto into wa_datrcbto.

**       Identifica Mneumônico na lista
        clear wa_gatemneu.
        read table t_gatemneu into wa_gatemneu with key mneum = wa_datrcbto-mneum.

**       Insere valor
        clear: wa_datasrc.
        concatenate '  document.getElementById("mneumonico' wa_gatemneu-seqnr '").value = "' wa_datrcbto-value '";' into wa_datasrc.
        append wa_datasrc to t_datasrc.

        clear: wa_datasrc.
        concatenate '  document.getElementById("mneumonico' wa_gatemneu-seqnr '").disabled="disabled";' into wa_datasrc.
        append wa_datasrc to t_datasrc.

        clear: wa_datasrc.
        concatenate '  document.getElementById("mneumonico' wa_gatemneu-seqnr '").className="disabled";' into wa_datasrc.
        append wa_datasrc to t_datasrc.
      endloop.

***   Desliga o contador e trata botões e mensagens
      if not wa_docrcbto is initial.
        append ' stop_timer();' to t_datasrc.
        append ' document.getElementById("cancela").className = "btn_cancela";' to t_datasrc.
*** inicio Inclusão David Rosin
        append ' document.getElementById("consulta").className = "btn_consulta";' to t_datasrc.
*** Fim inclusão David Rosin
        append ' document.getElementById("confirma").className = "hide";' to t_datasrc.
        append ' document.getElementById("recebida").className = "recebida";' to t_datasrc.



        concatenate wa_docrcbto-dtreg+6(2) '/' wa_docrcbto-dtreg+4(2) '/' wa_docrcbto-dtreg(4) into vl_data.
        concatenate wa_docrcbto-hrreg(2) ':' wa_docrcbto-dtreg+2(2) into vl_hora.

        clear: wa_datasrc.
        wa_datasrc = ' document.getElementById("recebida").innerHTML = "'.

        concatenate wa_datasrc 'Recebida em ' vl_data  into wa_datasrc separated by space.
        concatenate wa_datasrc 'às' vl_hora into wa_datasrc separated by space.
        concatenate wa_datasrc 'por' wa_docrcbto-uname '";' into wa_datasrc separated by space.

        append wa_datasrc to t_datasrc.
      else.
        append ' document.getElementById("cancela").className = "hide";' to t_datasrc.
        append ' document.getElementById("consulta").className = "hide";' to t_datasrc.
        append ' document.getElementById("confirma").className = "btn_confirma";' to t_datasrc.
        append ' document.getElementById("recebida").className = "hide";' to t_datasrc.
      endif.


***   Caso exista algum comando a ser executado na página
      if not t_datasrc[] is initial
        and ob_html_rcp is not initial.
***       Chamada de empresa
        call method ob_html_rcp->run_script_on_demand
          exporting
            script = t_datasrc
          exceptions
            others = 1.

      endif.
    endform.                    "f_show_document_rcp
*&---------------------------------------------------------------------*
*&      Form  F_VALIDAPORTARIA
*&---------------------------------------------------------------------*
*       Receber dados do HTML e verificar se estão corretos
*----------------------------------------------------------------------*
    form f_validaportaria tables p_postdata type cnht_post_data_tab.
      data: tl_split  type table of string,
            vl_erro   type c,
            vl_split  type string,
            vl_split1 type string,
            vl_split2 type string.

      clear vl_erro.

**    tratamento dos dados recebidos
      read table p_postdata into vl_split index 1.
      split vl_split at '&' into table tl_split.

      refresh t_datrcbto.

      loop at tl_split into vl_split.
*        separar valor de parametro
        split vl_split at '=' into vl_split1 vl_split2.
        vl_split1 = vl_split1+10.

*        buscar mneumonico
        clear wa_gatemneu.
        read table t_gatemneu into wa_gatemneu with key seqnr = vl_split1.
        check sy-subrc is initial.

*       Verificar se obrigatoriedade foi atendida
        if not wa_gatemneu-obrig is initial.
          if vl_split2 is initial.
            vl_erro = 'X'.
          endif.
        endif.

        if vl_erro is initial.
          clear wa_datrcbto.
          wa_datrcbto-mneum = wa_gatemneu-mneum.
          wa_datrcbto-value = vl_split2.
          append wa_datrcbto to t_datrcbto.
        endif.

      endloop.
**    Verifica se houve algum erro durante as validações de obrigatoriedade
      check vl_erro is initial.

*** Verifica Autorização usuario
      call function 'ZHMS_FM_SECURITY'
        exporting
          value         = 'CONFIRMA_PORTARI'
        exceptions
          authorization = 1
          others        = 2.

      if sy-subrc <> 0.
        message e000(zhms_security). "   Usuário sem autorização
      endif.

**    Insere a portaria
      perform f_registraportaria.

    endform.                    " F_VALIDAPORTARIA

*&---------------------------------------------------------------------*
*&      Form  F_REGISTRAPORTARIA
*&---------------------------------------------------------------------*
*       Insere a portaria
*----------------------------------------------------------------------*
    form f_registraportaria .
      data: tl_logdoc type table of zhms_tb_logdoc,
            tl_docum  type table of zhms_es_docum,
            wl_logdoc type zhms_tb_logdoc,
            wl_docum  type zhms_es_docum.

**    Variáveis locais
      data: vl_seqnr type zhms_de_seqnr.

**    Transferir dados para estrutura de portaria
      clear wa_docrcbto.
      wa_docrcbto-natdc = wa_cabdoc-natdc. " Natureza Documento
      wa_docrcbto-typed = wa_cabdoc-typed. " Tipo de Documento
*      wa_docrcbto-loctp = wa_cabdoc-loctp. " Localidade
      wa_docrcbto-chave = wa_cabdoc-chave. " Chave do Documento
      wa_docrcbto-dtreg = sy-datum.        " Data do log
      wa_docrcbto-hrreg = sy-uzeit.        " Horário do Log
      wa_docrcbto-uname = sy-uname.        " Nome do usuário
      wa_docrcbto-dcnro = wa_cabdoc-docnr. " Número de Documento
      wa_docrcbto-parid = wa_cabdoc-parid. " Identificação do parceiro (cliente, fornecedor, loc.negócio)
      wa_docrcbto-ativo = 'X'.             " Ativar
      wa_docrcbto-logty = 'S'.             " Tipo de mensagem

**    Gerar Código - Buscar Ultima Sequencia
      select max( seqnr )
        into wa_docrcbto-seqnr
        from zhms_tb_docrcbto
       where natdc eq wa_cabdoc-natdc
         and typed eq wa_cabdoc-typed
         and chave eq wa_cabdoc-chave.

**    Adiciona 1 ao ultimo
      add 1 to wa_docrcbto-seqnr.

**    Insere Portaria
      insert into zhms_tb_docrcbto values wa_docrcbto.
      commit work and wait.

**    Exibe mensagem de erro ou acerto
      if sy-subrc is initial.
        vg_msgimg = 1.
        v_detdoc = '0504'.
      else.
        vg_msgimg = 2.
        v_detdoc = '0504'.
      endif.

      check sy-subrc is initial.

**    Gerar Mneumonicos com base na portaria - ultima sequencia

      select max( seqnr )
        into vl_seqnr
        from zhms_tb_docmn
       where chave eq wa_docrcbto-chave.

*** Caso não encontre busca na tabela de historico
      if sy-subrc is not initial.
        select max( seqnr )
          into vl_seqnr
          from zhms_tb_docmn_hs
         where chave eq wa_docrcbto-chave.
      endif.

**    Insere Mneumonicos
      loop at t_datrcbto into wa_datrcbto.

**      Dados de Cabeçalho
        wa_datrcbto-natdc = wa_docrcbto-natdc.
        wa_datrcbto-typed = wa_docrcbto-typed.
        wa_datrcbto-chave = wa_docrcbto-chave.
        wa_datrcbto-seqnr = wa_docrcbto-seqnr.

**    Insere Mneumonicos
        insert into zhms_tb_datrcbto values wa_datrcbto.
        commit work and wait.

**    Repositório de mneumonicos
*       Remove possíveis Antigos
        delete from zhms_tb_docmn
         where chave eq wa_docrcbto-chave
           and mneum eq wa_datrcbto-mneum.

        commit work and wait.

*       Insere novos
        clear wa_docmn.
        vl_seqnr = vl_seqnr + 1.
        wa_docmn-chave = wa_docrcbto-chave.
        wa_docmn-seqnr = vl_seqnr.
        wa_docmn-mneum = wa_datrcbto-mneum.
*       wa_docmn-DCITM =
        wa_docmn-value = wa_datrcbto-value.

        call function 'CONVERSION_EXIT_ALPHA_INPUT'
          exporting
            input  = wa_docmn-seqnr
          importing
            output = wa_docmn-seqnr.

        insert into zhms_tb_docmn values wa_docmn.
        commit work and wait.

      endloop.

**    Executa regras identificação de cenário
      refresh: tl_docum.
      clear wl_docum.
      wl_docum-dctyp = 'CHAVE'.
      wl_docum-dcnro = wa_cabdoc-chave.
      append wl_docum to tl_docum.

      call function 'ZHMS_FM_TRACER'
        exporting
          natdc                 = wa_cabdoc-natdc
          typed                 = wa_cabdoc-typed
          loctp                 = wa_cabdoc-loctp
          just_ident            = 'X'
        tables
          docum                 = tl_docum
        exceptions
          document_not_informed = 1
          scenario_not_found    = 2
          others                = 3.

** Registra LOG
      refresh tl_logdoc.
      wl_logdoc-logty = 'S'.
      wl_logdoc-logno = '200'.
      append wl_logdoc to tl_logdoc.

      call function 'ZHMS_FM_REGLOG'
        exporting
          cabdoc = wa_cabdoc
          flwst  = 'M'
          tpprm  = 1
        tables
          logdoc = tl_logdoc.

      update zhms_tb_docst
         set strec = 2
             stent = vg_stent
       where natdc eq wa_cabdoc-natdc
         and typed eq wa_cabdoc-typed
         and loctp eq wa_cabdoc-loctp
         and chave eq wa_cabdoc-chave.
      commit work and wait.

**    Limpar entradas
      clear: vg_prt_chave, vg_prt_chave_a.

    endform.                    " F _REGISTRAPORTARIA

*&---------------------------------------------------------------------*
*&      Form  f_cancelaportaria
*&---------------------------------------------------------------------*
*       Tratamento para solicitação de cancelamento de portaria
*----------------------------------------------------------------------*
    form f_cancelaportaria.
      data: vl_answer type c.
      data: wl_logdoc type zhms_tb_logdoc,
            tl_logdoc type table of zhms_tb_logdoc.

*** Verifica Autorização usuario
      call function 'ZHMS_FM_SECURITY'
        exporting
          value         = 'CANCELAR_PORTARI'
        exceptions
          authorization = 1
          others        = 2.

      if sy-subrc <> 0.
        message e000(zhms_security). "   Usuário sem autorização
      endif.

      clear vl_answer.

**    Confirmação de resposta
      call function 'POPUP_TO_CONFIRM'
        exporting
          titlebar              = text-q01
          text_question         = text-q02
          text_button_1         = text-q03
          icon_button_1         = 'ICON_CHECKED'
          text_button_2         = text-q04
          icon_button_2         = 'ICON_INCOMPLETE'
          default_button        = '2'
          display_cancel_button = ' '
        importing
          answer                = vl_answer
        exceptions
          text_not_found        = 1
          others                = 2.

**    Somente continuar processamento caso resposta SIM
      check vl_answer eq 1.

      update zhms_tb_docrcbto
         set ativo = ''
             uscan = sy-uname
             dtcan = sy-datum
             hrcan = sy-uzeit
             logty = 'E'
       where natdc eq wa_docrcbto-natdc
         and typed eq wa_docrcbto-typed
         and chave eq wa_docrcbto-chave
         and seqnr eq wa_docrcbto-seqnr.

      commit work and wait .

** Registra LOG


      refresh tl_logdoc.
      wl_logdoc-logty = 'S'.
      wl_logdoc-logno = '201'.
      append wl_logdoc to tl_logdoc.

      call function 'ZHMS_FM_REGLOG'
        exporting
          cabdoc = wa_cabdoc
          flwst  = 'C'
          tpprm  = 1
        tables
          logdoc = tl_logdoc.


      clear vl_answer.

**    Confirmação de resposta
      call function 'POPUP_TO_CONFIRM'
        exporting
          titlebar              = text-q01
          text_question         = text-q06
          text_button_1         = text-q03
          icon_button_1         = 'ICON_CHECKED'
          text_button_2         = text-q04
          icon_button_2         = 'ICON_INCOMPLETE'
          default_button        = '1'
          display_cancel_button = ' '
        importing
          answer                = vl_answer
        exceptions
          text_not_found        = 1
          others                = 2.

**   tratamento para respostas
      if vl_answer ne 1.
**        Mostrar tela inicial
        clear: vg_msgimg, vg_prt_chave_a, vg_prt_chave.
        v_detdoc = '0504'.
      else.
**      Encaminhar para nova portaria
        clear vg_prt_chave_a.
        ok_code = 'RCB_CHAVE'.
        perform f_trata_acoes.
      endif.


    endform.                    "f_cancelaportaria

*&---------------------------------------------------------------------*
*&      Form  F_LOAD_LIST
*&---------------------------------------------------------------------*
*       Busca os dados das portarias ja efetuadas
*----------------------------------------------------------------------*
    form f_load_list .

**    Limpar Estruturas
      refresh: t_docrcbto, t_docrcbto_ax.
**    Seleção na tabela de portaria por usuário / Dia.
      select *
        into table t_docrcbto
        from zhms_tb_docrcbto
       where uname eq sy-uname
         and dtreg eq sy-datum.

**   Percorre dados encontrados alimentando a tabela de saída
      loop at t_docrcbto into wa_docrcbto.
**      Mover correspondentes
        move-corresponding wa_docrcbto to wa_docrcbto_ax.

**      Tratamento para ícone
        case wa_docrcbto-logty.
          when 'E'.
            wa_docrcbto_ax-icon = '@0A@'.
          when 'W'.
            wa_docrcbto_ax-icon = '@09@'.
          when 'I'.
            wa_docrcbto_ax-icon = '@08@'.
          when 'S'.
            wa_docrcbto_ax-icon = '@01@'.
        endcase.

**      Insere na estrutura de exibição
        append wa_docrcbto_ax to t_docrcbto_ax.
      endloop.

**    Ordena para que o mais recente seja exibido primeiro
      sort t_docrcbto_ax by dtreg descending
                            hrreg descending.

    endform.                    " F_LOAD_LIST

*&---------------------------------------------------------------------*
*&      Form  F_LOAD_LIST_CONF
*&---------------------------------------------------------------------*
*       Busca os dados das conferencias ja efetuadas
*----------------------------------------------------------------------*
    form f_load_list_conf .
**    Limpar Estruturas
      refresh: t_docconf, t_docconf_ax.
**    Seleção na tabela de portaria por usuário / Dia.
      select *
        into table t_docconf
        from zhms_tb_docconf
       where uname eq sy-uname
         and dtreg eq sy-datum.

**   Percorre dados encontrados alimentando a tabela de saída
      loop at t_docconf into wa_docconf.
**      Mover correspondentes
        move-corresponding wa_docconf to wa_docconf_ax.

**      Tratamento para ícone
        case wa_docconf-logty.
          when 'E'.
            wa_docconf_ax-icon = '@0A@'.
          when 'W'.
            wa_docconf_ax-icon = '@09@'.
          when 'I'.
            wa_docconf_ax-icon = '@08@'.
          when 'S'.
            wa_docconf_ax-icon = '@01@'.
        endcase.

**      Insere na estrutura de exibição
        append wa_docconf_ax to t_docconf_ax.
      endloop.

**    Ordena para que o mais recente seja exibido primeiro
      sort t_docconf_ax by dtreg descending
                           hrreg descending.
    endform.                    "f_load_list_conf


    data: info         like rfcsi,
* Results of RFC_SYSTEM_INFO function
          msg(80)      value space,
* Exception handling
          ret_subrc    like sy-subrc,
* SY-SUBRC handling
          semaphore(1) type c value space.
* Flag for receiving asynchronous results

*&---------------------------------------------------------------------*
*&      Form  f_atualizastatus
*&---------------------------------------------------------------------*
*       Atualiza status do documento na tela
*----------------------------------------------------------------------*
    form f_atualizastatus using receive.

      clear vg_stent.

      receive results from function 'ZHMS_FM_CONSULTAET'
                      importing  return = wa_return
                      exceptions communication_failure = 1 message msg
                                 system_failure        = 2 message msg.

      ret_subrc = sy-subrc. "Setn RET_SUBRC
      set user-command 'OKCD'. "Set OK_CODE .

      refresh: t_datasrc.

      if wa_return-retnr = 1.
        append 'recp_status.innerHTML=''<img id="dc_recp" src="port_ok.gif" />'';' to t_datasrc.
        vg_stent = 3. "Aprovada
      elseif wa_return-retnr = 2.
        append 'recp_status.innerHTML=''<img id="dc_recp" src="port_cont.gif" />'';' to t_datasrc.
        vg_stent = 3. "Contingencia
      elseif wa_return-retnr = 3.
        append 'recp_status.innerHTML=''<img id="dc_recp" src="PORT_ERROR.GIF" />'';' to t_datasrc.
        vg_stent = 4. "Cancelada
      endif.

      append 'stop_timer();' to t_datasrc.

*      CLEAR: wa_datasrc.
*      CONCATENATE 'atualiza_submit("' wa_return-retnr '");' INTO wa_datasrc.
*      APPEND wa_datasrc TO t_datasrc.


    endform.                    "f_atualizastatus
*&---------------------------------------------------------------------*
*&      Form  F_CONSULTAET
*&---------------------------------------------------------------------*
*       Busca status do documento na Entidade Tributária
*----------------------------------------------------------------------*
    form f_consultaet .

      call function 'ZHMS_FM_CONSULTAET'
        starting new task 'ZHMS_TASK_CONSULTAET'
        performing f_atualizastatus on end of task
        exporting
          natdc                 = wa_cabdoc-natdc
          typed                 = wa_cabdoc-typed
          chave                 = wa_cabdoc-chave
        exceptions
          communication_failure = 1 message msg
          system_failure        = 2 message msg.

    endform.                    " F_CONSULTAET

*&---------------------------------------------------------------------*
*&      Form  f_executeHTML_timer
*&---------------------------------------------------------------------*
*       Executa código fonte no HTML a cada intervalo
*----------------------------------------------------------------------*
    form f_executehtml_timer.
***   caso exista algum comando a ser executado na página
      if not t_datasrc[] is initial
        and ob_html_rcp is not initial.
***       Chamada de empresa
        call method ob_html_rcp->run_script_on_demand
          exporting
            script = t_datasrc
          exceptions
            others = 1.

        refresh t_datasrc[].

      endif.
    endform.                    "f_executeHTML_timer
*&---------------------------------------------------------------------*
*&      Form  F_TRATA_ACOES
*&---------------------------------------------------------------------*
*       Trata ações de tela e usuário do módulo de portaria
*----------------------------------------------------------------------*
    form f_trata_acoes .
      check ok_code ne 'BACK'
         or ok_code ne 'CANC'
         or ok_code ne 'EXIT'.

**    Tratamentos para entrada via leitor de codigo de barras
      if ok_code is initial
        and not vg_prt_chave is initial
        and vg_prt_chave ne vg_prt_chave_a.
        vg_prt_chave_a = vg_prt_chave.
        ok_code = 'RCB_CHAVE'.
**   Begin of change - c_flag - MZAGATO - DE2K906251 - 15/10/2019.
      elseif vg_prt_chave eq vg_prt_chave_a and c_flag is initial.
**   End of change - MZAGATO - DE2K906251 - 15/10/2019.
        if zhms_tb_cabdoc-docnr is initial.
          clear ok_code.
        else.
          ok_code = 'RCB_DOCNR'.
        endif.
      endif.


**    Buscar nota
      case ok_code.
        when 'RCB_CHAVE'.
**        Limpa estruturas
          clear wa_docrcbto.
          refresh t_datrcbto.

**        Pela Chave
          perform f_rcb_buscachave.

**        Confere resultados - Portaria não realizada
          if wa_docrcbto is initial.
**        dispara busca na entidade tributária
            perform f_consultaet.
          endif.

**        Exibe dados do documento no painel de detalhes
          perform f_show_document_rcp.

**        Seta subscreen para detalhes em HTML  (503)
          v_detdoc = '0503'.

        when 'RCB_DOCNR'.
**        Limpa estruturas
          clear wa_docrcbto.
          refresh t_datrcbto.

**        Pelo número
          perform f_rcb_buscadocnr.

**        Confere resultados - Portaria não realizada
          if wa_docrcbto is initial.
**        dispara busca na entidade tributária
            perform f_consultaet.
          endif.

**        Exibe dados do documento no painel de detalhes
          perform f_show_document_rcp.

**        Seta subscreen para detalhes em HTML  (503)
          v_detdoc = '0503'.

        when 'BACK'.
          leave to screen 0.

        when others.
          call method cl_gui_cfw=>dispatch.
      endcase.

    endform.                    " F_TRATA_ACOES

*&---------------------------------------------------------------------*
*&      Form  F_TRATA_ACOES_CONF
*&---------------------------------------------------------------------*
*       Trata ações de tela e usuário para conferencia
*----------------------------------------------------------------------*
    form f_trata_acoes_conf .

      if ok_code is initial.
        move sy-ucomm to ok_code.
      endif.

      check ok_code ne 'BACK'
         or ok_code ne 'CANC'
         or ok_code ne 'EXIT'.

**    Tratamentos para entrada via leitor de codigo de barras
      if ok_code is initial
        and not vg_cnf_chave is initial
        and vg_cnf_chave ne vg_cnf_chave_a.
        vg_cnf_chave_a = vg_cnf_chave.
        ok_code = 'CNF_CHAVE'.
      elseif vg_cnf_chave eq vg_cnf_chave_a
        and ok_code ne 'CNF_OK'.
        if zhms_tb_cabdoc-docnr is initial.
          clear ok_code.
        else.
          ok_code = 'CNF_DOCNR'.
        endif.
      endif.


**    Buscar nota
      case ok_code.
        when 'CNF_CHAVE'.
**        Limpa estruturas
          clear wa_docconf.
          refresh t_datconf.

**        Pela Chave
          perform f_cnf_buscachave.

**        Exibe dados do documento no painel de detalhes
          perform f_show_document_det using ''.

**        Seta subscreen para detalhes em HTML  (403)
          v_detdoc = '0403'.
          if wa_docconf is initial.
            v_conf = '0401'.
          else.
            v_conf = '0402'.
          endif.


        when 'CNF_DOCNR'.
**        Limpa estruturas
          clear wa_docconf.
          refresh t_datconf.

**        Pelo número
          perform f_cnf_buscadocnr.

**        Exibe dados do documento no painel de detalhes
          perform f_show_document_det using ''.

**        Seta subscreen para detalhes em HTML  (403)
          v_detdoc = '0403'.
          if wa_docconf is initial.
            v_conf = '0401'.
          else.
            v_conf = '0402'.
          endif.

        when 'BACK'.
          leave to screen 0.
        when 'CNF_OK'.
**        Confirma cadastro de contagem.
          perform f_registraconferencia.
        when 'CNF_CANC'.
**        Cancela conferencia
          perform f_cancelaconferencia.
        when others.
          call method cl_gui_cfw=>dispatch.
      endcase.

    endform.                    " F_TRATA_ACOES_CONF

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
              'X'                         to wa_event-appl_event.
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

      clear: wa_datasrc.
      concatenate 'dc_numero.innerText=''' wa_cabdoc-docnr '-' wa_cabdoc-serie ''';' into wa_datasrc.
      append wa_datasrc to t_datasrc.

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
      concatenate 'dc_partnt.innerText=''' '(' wa_cabdoc-parid ')' vl_name1 ''';' into wa_datasrc.
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


      clear: wa_datasrc.
      concatenate 'dc_reftxt.innerHTML=''' '' ''';' into wa_datasrc.
      append wa_datasrc to t_datasrc.

      clear: wa_datasrc.
      concatenate 'dc_refvlr.innerHTML=''' '' ''';' into wa_datasrc.
      append wa_datasrc to t_datasrc.


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

*&---------------------------------------------------------------------*
*&      Form  F_REGISTRACONFERENCIA
*&---------------------------------------------------------------------*
*       Registrar conferência para documento
*----------------------------------------------------------------------*
    form f_registraconferencia .
      data: vl_erro    type flag,
            vl_dif_qte type flag.
      data: vl_answer type c.
      data: tl_logdoc   type table of zhms_tb_logdoc,
            tl_docum    type table of zhms_es_docum,
            wl_logdoc   type zhms_tb_logdoc,
            wl_docum    type zhms_es_docum,
            vl_messagem type char120,
            vl_flwst    type zhms_de_flwst value 'M'.

      clear: vl_erro.

*** Verifica Autorização usuario
      call function 'ZHMS_FM_SECURITY'
        exporting
          value         = 'CONF_CONFERENCIA'
        exceptions
          authorization = 1
          others        = 2.

      if sy-subrc <> 0.
        message e000(zhms_security). "   Usuário sem autorização
      endif.

**  Percorre dados digitados
      refresh t_datconf.

      loop at t_datconf_ax into wa_datconf_ax.
**      Limpar estrutura
        clear wa_datconf.

        if wa_datconf_ax-cfqtd is initial
          or wa_datconf_ax-cfqtd eq 0.
          vl_erro = 'X'.
          vl_messagem = text-q07.
        endif.

**      Verifica se as quantidades estão de acordo com o documento
        if wa_datconf_ax-cfqtd ne wa_datconf_ax-dcqtd.
          vl_erro = 'X'.
          vl_messagem = text-q10.
        endif.
**      Ler dados de item
        read table t_itmdoc into wa_itmdoc with key dcitm = wa_datconf_ax-dcitm.

**      Mover dados correspondentes da tabela de ítens
        move-corresponding wa_itmdoc to wa_datconf.

**      Mover dados correspondentes da tabela de edição
        move-corresponding wa_datconf_ax to wa_datconf.

**      Sequência
        wa_datconf-seqnr = wa_docconf-seqnr.

        append wa_datconf to t_datconf.
      endloop.

**   Verificar se existe quantidade zerada
      if not vl_erro is initial.

        clear vl_answer.
**    Confirmação de resposta
        call function 'POPUP_TO_CONFIRM'
          exporting
            titlebar              = text-q01
            text_question         = vl_messagem
            text_button_1         = text-q03
            icon_button_1         = 'ICON_CHECKED'
            text_button_2         = text-q04
            icon_button_2         = 'ICON_INCOMPLETE'
            default_button        = '2'
            display_cancel_button = ' '
          importing
            answer                = vl_answer
          exceptions
            text_not_found        = 1
            others                = 2.
      endif.

**   verifica se foi encontrada incosistência
      refresh tl_logdoc.
      if  vl_erro is not initial.
        check vl_answer eq 1.
        wl_logdoc-logty = 'E'.
        wl_logdoc-logno = '252'.
        vl_flwst = 'E'.
        wa_docconf-logty = 'W'.
        update zhms_tb_docst set sthms = '4'
          where chave = wa_cabdoc-chave.
      else.
        wl_logdoc-logty = 'S'.
        wl_logdoc-logno = '250'.
        vl_flwst = 'M'.
      endif.

      append wl_logdoc to tl_logdoc.
**    Insere dados de items.
      loop at t_datconf into wa_datconf.
        insert into zhms_tb_datconf values wa_datconf.
        commit work and wait.
      endloop.

**    Insere dados de cabeçalho
      insert into zhms_tb_docconf values wa_docconf.
      commit work and wait.

**    Executa regras identificação de cenário
      if vl_erro is initial.
        refresh: tl_docum.
        clear wl_docum.
        wl_docum-dctyp = 'CHAVE'.
        wl_docum-dcnro = wa_cabdoc-chave.
        append wl_docum to tl_docum.

        call function 'ZHMS_FM_TRACER'
          exporting
            natdc                 = wa_cabdoc-natdc
            typed                 = wa_cabdoc-typed
            loctp                 = wa_cabdoc-loctp
            just_ident            = 'X'
          tables
            docum                 = tl_docum
          exceptions
            document_not_informed = 1
            scenario_not_found    = 2
            others                = 3.
      endif.
** Registra LOG
      call function 'ZHMS_FM_REGLOG'
        exporting
          cabdoc = wa_cabdoc
          flwst  = vl_flwst
          tpprm  = 2
        tables
          logdoc = tl_logdoc.

**    Exibe mensagem de erro ou acerto
      if sy-subrc is initial.
        vg_msgimg = 3.
        v_detdoc = '0504'.
      else.
        vg_msgimg = 2.
        v_detdoc = '0504'.
      endif.

    endform.                    " F_REGISTRACONFERENCIA


*&---------------------------------------------------------------------*
*&      Form  f_cancelaconferencia
*&---------------------------------------------------------------------*
*       Cancela conferencia
*----------------------------------------------------------------------*
    form f_cancelaconferencia.
      data: vl_answer type c.
      data: wl_logdoc type zhms_tb_logdoc,
            tl_logdoc type table of zhms_tb_logdoc.

*** Verifica Autorização usuario
      call function 'ZHMS_FM_SECURITY'
        exporting
          value         = 'CANC_CONFERENCIA'
        exceptions
          authorization = 1
          others        = 2.

      if sy-subrc <> 0.
        message e000(zhms_security). "   Usuário sem autorização
      endif.

      clear vl_answer.

**    Confirmação de resposta
      call function 'POPUP_TO_CONFIRM'
        exporting
          titlebar              = text-q01
          text_question         = text-q08
          text_button_1         = text-q03
          icon_button_1         = 'ICON_CHECKED'
          text_button_2         = text-q04
          icon_button_2         = 'ICON_INCOMPLETE'
          default_button        = '2'
          display_cancel_button = ' '
        importing
          answer                = vl_answer
        exceptions
          text_not_found        = 1
          others                = 2.

**    Somente continuar processamento caso resposta SIM
      check vl_answer eq 1.

      update zhms_tb_docconf
         set ativo = ''
             uscan = sy-uname
             dtcan = sy-datum
             hrcan = sy-uzeit
             logty = 'E'
       where natdc eq wa_docconf-natdc
         and typed eq wa_docconf-typed
         and chave eq wa_docconf-chave
         and seqnr eq wa_docconf-seqnr.

      commit work and wait .

** Registra log

      refresh tl_logdoc.
      clear wl_logdoc.
      wl_logdoc-logty = 'S'.
      wl_logdoc-logno = '251'.
      append wl_logdoc to tl_logdoc.

      call function 'ZHMS_FM_REGLOG'
        exporting
          cabdoc = wa_cabdoc
          flwst  = 'C'
          tpprm  = 2
        tables
          logdoc = tl_logdoc.


      clear wa_flwdoc.
**        Buscar etapa do fluxo
      select single flowd
        into wa_flwdoc-flowd
        from zhms_tb_scen_flo
        where natdc eq wa_cabdoc-natdc
          and typed eq wa_cabdoc-typed
          and loctp eq wa_cabdoc-loctp
          and scena eq wa_cabdoc-scena
          and tpprm eq 2 ."conferencia

**      Insere registro de etapa concluída no fluxo documento
      wa_flwdoc-natdc = wa_cabdoc-natdc.
      wa_flwdoc-typed = wa_cabdoc-typed.
      wa_flwdoc-loctp = wa_cabdoc-loctp.
      wa_flwdoc-chave = wa_cabdoc-chave.
      wa_flwdoc-dtreg = sy-datum.
      wa_flwdoc-hrreg = sy-uzeit.
      wa_flwdoc-uname = sy-uname.
      wa_flwdoc-flwst = 'C'. "Cancelada

**      remove anteriores.
      delete from zhms_tb_flwdoc
       where natdc eq wa_flwdoc-natdc
         and typed eq wa_flwdoc-typed
         and loctp eq wa_flwdoc-loctp
         and chave eq wa_flwdoc-chave
         and flowd eq wa_flwdoc-flowd.
      commit work and wait.

      insert into zhms_tb_flwdoc values wa_flwdoc.
      commit work and wait.


      clear vl_answer.

**    Confirmação de resposta
      call function 'POPUP_TO_CONFIRM'
        exporting
          titlebar              = text-q01
          text_question         = text-q09
          text_button_1         = text-q03
          icon_button_1         = 'ICON_CHECKED'
          text_button_2         = text-q04
          icon_button_2         = 'ICON_INCOMPLETE'
          default_button        = '1'
          display_cancel_button = ' '
        importing
          answer                = vl_answer
        exceptions
          text_not_found        = 1
          others                = 2.

**   tratamento para respostas
      if vl_answer ne 1.
**        Mostrar tela inicial
        clear: vg_msgimg, vg_cnf_chave_a, vg_cnf_chave.
        v_detdoc = '0504'.
      else.
**      Encaminhar para nova portaria
        clear vg_prt_chave_a.
        ok_code = 'CNF_CHAVE'.
        perform f_trata_acoes_conf.
      endif.

    endform.                    "f_cancelaconferencia
*&---------------------------------------------------------------------*
*&      Form  F_CONSULTA_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
    form f_consulta_status .

      data: ls_return type zhms_es_return.

*** Verifica Autorização usuario
      call function 'ZHMS_FM_SECURITY'
        exporting
          value         = 'NOVA_CONSULTA'
        exceptions
          authorization = 1
          others        = 2.

      if sy-subrc <> 0.
        message e000(zhms_security). "   Usuário sem autorização
      endif.

      refresh t_datrcbto.

      move abap_true to vg_time.
      perform f_show_document_rcp.
      clear vg_time.

**        Seta subscreen para detalhes em HTML  (503)
      v_detdoc = '0503'.

      call function 'ZHMS_FM_CONSULTAET'
        starting new task 'ZHMS_TASK_CONSULTAET_TIME'
        exporting
          natdc                 = wa_cabdoc-natdc
          typed                 = wa_cabdoc-typed
          chave                 = wa_cabdoc-chave
        exceptions
          communication_failure = 1 message msg
          system_failure        = 2 message msg.

    endform.                    " F_CONSULTA_STATUS
