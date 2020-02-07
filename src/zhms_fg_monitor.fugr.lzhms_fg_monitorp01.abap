*----------------------------------------------------------------------*
*                      H  o  m  S  o  f  t                             *
*          Gestão Eletrônica de Documentos e Processos                 *
*----------------------------------------------------------------------*
* Descrição: Monitor Central de Gerenciamento de Documentos            *
*            Classes (Monitor)                                         *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*   CLASS lcl_event_handler IMPLEMENTATION
*----------------------------------------------------------------------*
*   Implementação da Classe de Eventos do HTML
*----------------------------------------------------------------------*
    class lcl_event_handler implementation.
***   ---------------------------------------------------------------- *
***   Implementação da Classe de Eventos do HTML
***   ---------------------------------------------------------------- *
      method on_sapevent.
        data: v_postdata type string.
        clear v_postdata.

        if not action is initial.
          case action.
            when 'save'.
              clear v_postdata.
              read table postdata into v_postdata index 1.

              if sy-subrc eq 0.
***             Recupera documentos selecionados
                perform f_set_docs_lines using v_postdata.
***             Preenche dados
                perform f_show_document_det using ''.
              endif.

            when 'show_det'.
              clear vg_015o_det.
              move  '0151' to vg_015o_det.

            when 'show_xml'.
              clear vg_015o_det.
              move  '0152' to vg_015o_det.

            when 'show_pdf'.
              clear vg_015o_det.
              move  '0153' to vg_015o_det.

            when 'show_flow'.
              clear vg_015o_det.
              move  '0171' to vg_015o_det.

            when '01|NFE|'.
*              CALL TRANSACTION 'J1BNFE'.
              call transaction 'ZNFE'.
* Inicio  Chamada transaction J1B1N. Rafael Beretta
            when '01|NFE1|'.
*              CALL TRANSACTION 'J1BNFE'.
              call transaction 'J1B1N'.
* Fim Chamada transaction J1B1N. Rafael Beretta
            when '01|NFS|'.
*       *CALL TRANSACTION 'J1BNFE'.
              call transaction 'VA01'.
            when '03|NF180|'.
              call transaction 'ZHMS_180_DIAS'.


            when others.
***           Recupera índice selecionados
              perform f_set_index_line using action.

          endcase.
        endif.
      endmethod.                    "lcl_event_handler
    endclass.               "lcl_event_handler

*----------------------------------------------------------------------*
*   CLASS lcl_html_script IMPLEMENTATION
*----------------------------------------------------------------------*
*   Implementação da Classe para Execução de JavaScript
*----------------------------------------------------------------------*
    class lcl_html_script implementation.
***   ---------------------------------------------------------------- *
***   Método Construtor
***   ---------------------------------------------------------------- *
      method constructor.
        call method super->constructor
          exporting
            parent   = parent
            saphtmlp = 'X'
            uiflag   = cl_gui_html_viewer=>uiflag_noiemenu
          exceptions
            others   = 1.

        if sy-subrc ne 0.
          raise cntl_error.
        endif.
      endmethod.                    "lcl_html_script

***   ---------------------------------------------------------------- *
***   Executor de JavaScript
***   ---------------------------------------------------------------- *
      method run_script_on_demand.
        call method me->set_script
          exporting
            script = script.

        call method me->execute_script.

      endmethod.                    "lcl_html_script

***   ---------------------------------------------------------------- *
***   Carregando Documento
***   ---------------------------------------------------------------- *
      method load_bds_doc.
        call method me->load_bds_object
          exporting
            doc_name        = doc_name
            doc_langu       = doc_langu
            doc_description = doc_description
            bds_classname   = bds_classname
            bds_objectkey   = bds_objectkey
          importing
            assigned_url    = assigned_url
          exceptions
            others          = 1.
      endmethod.                    "lcl_html_script

***   ---------------------------------------------------------------- *
***   Carregando Ícones
***   ---------------------------------------------------------------- *
      method load_bds_icon.
        call method me->load_bds_sap_icon
          exporting
            sap_icon     = icon_name
          importing
            assigned_url = assigned_url
            file_name    = file_name
          exceptions
            others       = 1.
      endmethod.                    "lcl_html_script
    endclass.                    "lcl_html_script IMPLEMENTATION

*------------------------------------------------*
* CLASS lcl_receiver IMPLEMENTATION
*------------------------------------------------*
    class lcl_receiver implementation.
      method handle_finished.
***     Atualizar os status dos documentos
        perform f_refresh_docs_status.
        call method ob_timer->run.
      endmethod.                    "handle_finished

*-----Logic to handle the HOTSPOT click
      method handel_hotspot_click.
*---To handel hotspot in the firstlist
        perform handel_hotspot_click using e_row_id e_column_id.
        call method ob_cc_xml_grid->refresh_table_display.
        call method ob_cc_comp_grid->refresh_table_display.

      endmethod.                    "HANDEL_HOTSPOT_CLICK
    endclass.                    "lcl_receiver IMPLEMENTATION

*----------------------------------------------------------------------*
*   CLASS lcl_toolbar_events IMPLEMENTATION
*----------------------------------------------------------------------*
*   Implementando Classe da TOOLBAR
*----------------------------------------------------------------------*
    class cl_app_toolbar implementation.
***   Método para Botões da TOOLBAR da tela 0100
      method on_function_selected.

        data: lv_answer type c.

        case fcode.
          when 'REFRESH'.
***         Atualizando lista de documento
            perform f_sel_docs_nfs.
            clear vg_screen_call.
            move 'X' to vg_screen_call.

          when 'REFSTATUS'.
***         Atualizar os status dos documentos
            perform f_refresh_docs_status.

          when 'LOGS'.
*** Verifica Autorização usuario
            call function 'ZHMS_FM_SECURITY'
              exporting
                value         = 'LOG_PROCESSAMENT'
              exceptions
                authorization = 1
                others        = 2.

            if sy-subrc <> 0.
              message e000(zhms_security). "   Usuário sem autorização
            endif.

***         Limpar etapa
            clear vg_flowd.
***         Chamar Subtela
            call screen 300 starting at 30 1.

          when 'VALID'.
*** Verifica Autorização usuario
            call function 'ZHMS_FM_SECURITY'
              exporting
                value         = 'VALIDACAO'
              exceptions
                authorization = 1
                others        = 2.

            if sy-subrc <> 0.
              message e000(zhms_security). "   Usuário sem autorização
            endif.

***         Chamar Subtela
*            CALL SCREEN 400 STARTING AT 30 1.
            call screen 407.

          when 'FLOWEXE'.
            data: tl_docum type table of zhms_es_docum,
                  wl_docum type zhms_es_docum.

            select *
              from zhms_tb_hrvalid
              into table t_hrvalid
              where chave = wa_cabdoc-chave
                and ativo = 'X'
                and grp <> ''.

            if not t_hrvalid[] is initial.
              message i068(zhms_mc_monitor).
              refresh: t_hrvalid.
              clear: t_hrvalid.
            else.
*** Verifica Autorização usuario
              call function 'ZHMS_FM_SECURITY'
                exporting
                  value         = 'EXECUTAR_FLUXO'
                exceptions
                  authorization = 1
                  others        = 2.

              if sy-subrc <> 0.
                message e000(zhms_security). "   Usuário sem autorização
              endif.

**          Executa regras identificação de cenário
              refresh: tl_docum.
              clear wl_docum.
              wl_docum-dctyp = 'CHAVE'.
              wl_docum-dcnro = wa_cabdoc-chave.
              wl_docum-chave = wa_cabdoc-chave.
              append wl_docum to tl_docum.

              call function 'ZHMS_FM_TRACER'
                exporting
                  natdc                 = wa_cabdoc-natdc
                  typed                 = wa_cabdoc-typed
                  loctp                 = wa_cabdoc-loctp
                tables
                  docum                 = tl_docum
                exceptions
                  document_not_informed = 1
                  scenario_not_found    = 2
                  others                = 3.
            endif.
          when 'NFEEVT'.
***         Chamar Subtela
            call screen 600 starting at 30 1.

          when 'J1B1N'.

*** Verifica Autorização usuario
            call function 'ZHMS_FM_SECURITY'
              exporting
                value         = 'J1B1N'
              exceptions
                authorization = 1
                others        = 2.

            if sy-subrc <> 0.
              message e000(zhms_security). "   Usuário sem autorização
            endif.

            perform f_j1b1n.

            perform f_sel_docs_nfs.
            clear vg_screen_call.
            move 'X' to vg_screen_call.


          when 'CANC'.
            call function 'ZHMS_FAKE'
              exporting
                chave = vg_chave
                natdc = vg_natdc
                typed = vg_typed
                scena = '02'
                pfase = 'EMNE'.

          when 'INUT'.
            call function 'ZHMS_FAKE'
              exporting
                chave = vg_chave
                natdc = vg_natdc
                typed = vg_typed
                scena = '03'
                pfase = 'EMNE'.

          when 'ATRIB'.

*** Verifica Autorização usuario
            call function 'ZHMS_FM_SECURITY'
              exporting
                value         = 'ATRIBUICAO'
              exceptions
                authorization = 1
                others        = 2.

            if sy-subrc <> 0.
              message e000(zhms_security). "   Usuário sem autorização
            endif.

***         Chamar Subtela
            call screen 500 starting at 30 1.
*Renan Itokazo
*Aprovação de NFS-e
          when 'APROV'.

*** Verifica a última etapa do documento
            select max( flowd ) from zhms_tb_flwdoc into vg_flowd where chave eq vg_chave.

            if sy-subrc is initial.
              if vg_flowd eq '20'.

                refresh: t_itmatr_atr.
                clear: wa_itmatr.

*** Busca o item atribuido
                select * from zhms_tb_itmatr into table t_itmatr_atr where chave eq vg_chave.

                if sy-subrc is initial.
                  loop at t_itmatr_atr into wa_itmatr.
*                    vg_ebelp = wa_itmatr-dcitm * 10.
*** Busca e valida o usuário requisitante no item do pedido
                    select single afnam from ekpo into vg_afnam where ebeln eq wa_itmatr-nrsrf and ebelp eq wa_itmatr-itsrf.

                    if sy-uname eq vg_afnam.
*** Verifica Autorização usuario no homsoft
                      call function 'ZHMS_FM_SECURITY'
                        exporting
                          value         = 'APROVA_NFS'
                        exceptions
                          authorization = 1
                          others        = 2.

                      if sy-subrc <> 0.
                        message e000(zhms_security). "   Usuário sem autorização
                      endif.
                    else.
                      message e000(zhms_security). "   Usuário sem autorização
                    endif.
                  endloop.
                endif.


                wa_flwdoc-natdc = '02'.
                wa_flwdoc-typed = 'NFSE1'.
                wa_flwdoc-chave = vg_chave.
                wa_flwdoc-flowd = '30'.
                wa_flwdoc-dtreg = sy-datum.
                wa_flwdoc-hrreg = sy-uzeit.
                wa_flwdoc-uname = sy-uname.
                wa_flwdoc-flwst = 'M'.

                insert zhms_tb_flwdoc from wa_flwdoc.

                if sy-subrc is initial.
                  commit work.
                else.
                  rollback work.
                endif.

              endif.
            endif.




*** Inicio - Ricardo Rodrigues
* Alv para auditoria
          when 'AUDI'.
*            CALL SCREEN 0605 STARTING AT 30 1.
            call screen 0606 starting at 30 1.
*            CALL SCREEN 0607 STARTING AT 30 1.
*** Fim - Ricardo Rodrigues

          when 'PORT'.
*** Verifica Autorização usuario
            call function 'ZHMS_FM_SECURITY'
              exporting
                value         = 'PORTARIA'
              exceptions
                authorization = 1
                others        = 2.

            if sy-subrc <> 0.
              message e000(zhms_security). "   Usuário sem autorização
            endif.

*** Verifica qual opção de portaria "Realizar portaria ou consutar historico"
            call function 'POPUP_TO_DECIDE'
              exporting
*               DEFAULTOPTION     = '1'
                textline1         = 'Opções Portaria'
*               TEXTLINE2         = ' '
*               TEXTLINE3         = ' '
                text_option1      = text-q12
                text_option2      = text-q13
                icon_text_option1 = 'ICON_DISPLAY_TEXT'
                icon_text_option2 = 'ICON_CHECKED'
                titel             = text-q11
                start_column      = 67
                start_row         = 8
                cancel_display    = 'X'
              importing
                answer            = lv_answer.

            case lv_answer.
              when '1'.
***         Chamar Subtela
                call screen 200 starting at 30 1.
              when '2'.
                set parameter id 'ZVG_CNF_CHAVE' field vg_chave.
                call transaction 'ZHMS_GATE'.
            endcase.

          when 'CONF'.

*** Verifica Autorização usuario
            call function 'ZHMS_FM_SECURITY'
              exporting
                value         = 'CONFERENCIA'
              exceptions
                authorization = 1
                others        = 2.

            if sy-subrc <> 0.
              message e000(zhms_security). "   Usuário sem autorização
            endif.

            call function 'POPUP_TO_DECIDE'
              exporting
*               DEFAULTOPTION     = '1'
                textline1         = 'Opções Conferencia'
*               TEXTLINE2         = ' '
*               TEXTLINE3         = ' '
                text_option1      = text-q12
                text_option2      = text-q14
                icon_text_option1 = 'ICON_DISPLAY_TEXT'
                icon_text_option2 = 'ICON_CHECKED'
                titel             = text-q11
                start_column      = 67
                start_row         = 8
                cancel_display    = 'X'
              importing
                answer            = lv_answer.

            case lv_answer.
              when '1'.
***         Chamar Subtela
                call screen 250 starting at 30 1.
              when '2'.
                set parameter id 'ZVG_CNF_CHAVE' field vg_chave.
                call transaction 'ZHMS_GATE_CONF'.
            endcase.

          when 'HIST'.

*** Verifica Autorização usuario
*            CALL FUNCTION 'ZHMS_FM_SECURITY'
*              EXPORTING
*                value         = 'CONFERENCIA'
*              EXCEPTIONS
*                authorization = 1
*                OTHERS        = 2.
*
*            IF sy-subrc <> 0.
*              MESSAGE e000(zhms_security). "   Usuário sem autorização
*            ENDIF.

*** Chama Subtela para exibir histórico de eventos
            call screen 301 starting at 30 1.

          when 'J1B1N'.

          when 'DEBTPOST'.

*** Verifica Autorização usuario
            call function 'ZHMS_FM_SECURITY'
              exporting
                value         = 'MIRO'
              exceptions
                authorization = 1
                others        = 2.

            if sy-subrc <> 0.
              message e000(zhms_security). "   Usuário sem autorização
            endif.
***Declaracao de variaveis
            data: vg_data       type zhms_de_value,
                  vg_hora       type zhms_de_value,
                  vg_nprot      type zhms_de_value,
                  vg_referencia type zhms_de_value.
            data: it_docmn      type standard table of zhms_tb_docmn.
            data: wa_docmn      type zhms_tb_docmn.
***

***Ler os dados do XML
            select * from zhms_tb_docmn into table it_docmn where chave eq vg_chave.

            read table it_docmn into wa_docmn with key mneum = 'NPROT'.
            vg_nprot = wa_docmn-value.

            clear: wa_docmn.
            read table it_docmn into wa_docmn with key mneum = 'DHRECBTO'.
            concatenate wa_docmn-value+8(2) wa_docmn-value+5(2) wa_docmn-value+0(4) into vg_data separated by '.'.
            vg_hora = wa_docmn-value+11(8).

            clear: wa_docmn.
            read table it_docmn into wa_docmn with key mneum = 'NCT'.
            vg_referencia = wa_docmn-value.

            clear: wa_docmn.
            read table it_docmn into wa_docmn with key mneum = 'SERIE'.
            concatenate vg_referencia wa_docmn-value into vg_referencia separated by '-'.
***

            perform z_gera_tela using:
              'X' 'SAPLMR1M' '6000',
              ' ' 'BDC_CURSOR' 'RM08M-VORGANG',
              ' ' 'BDC_OKCODE' 'DUMMY',
              ' ' 'RM08M-VORGANG' '3',
              ' ' 'BDC_SUBSCR' 'SAPLMR1M                                6005HEADER_AND_ITEMS',
              ' ' 'BDC_SUBSCR' 'SAPLFDCB                                0010HEADER_SCREEN',
              ' ' 'INVFO-BLDAT' vg_data,
              ' ' 'INVFO-BUDAT' vg_data,
              ' ' 'BDC_SUBSCR' 'SAPLF0KI                                0100SUBBAS01',
              ' ' 'BDC_SUBSCR' 'SAPLFMFG_PPA_INV_EXT                    5001SUBBAS02',
              ' ' 'BDC_SUBSCR' 'SAPM_WRF_PREPAY_SCREENS                 0100SUBBAS03',
              ' ' 'BDC_SUBSCR' 'SAPLFPIA_SCR_FI_MM                      0100SUBBAS04',
              ' ' 'BDC_SUBSCR' 'SAPLSEXM                                0200SUBBAS05',
              ' ' 'BDC_SUBSCR' 'SAPLMRM_INVOICE_CHANGE                  0100SUBBAS06',
              ' ' 'BDC_SUBSCR' 'SAPLSEXM                                0200FMFG',
              ' ' 'INVFO-XBLNR' vg_referencia,
              ' ' 'BDC_SUBSCR' 'SAPLF0KI                                0100SUBBAS01',
              ' ' 'BDC_SUBSCR' 'SAPLFMFG_PPA_INV_EXT                    5001SUBBAS02',
              ' ' 'BDC_SUBSCR' 'SAPM_WRF_PREPAY_SCREENS                 0100SUBBAS03',
              ' ' 'BDC_SUBSCR' 'SAPLFPIA_SCR_FI_MM                      0100SUBBAS04',
              ' ' 'BDC_SUBSCR' 'SAPLSEXM                                0200SUBBAS05',
              ' ' 'BDC_SUBSCR' 'SAPLMRM_INVOICE_CHANGE                  0100SUBBAS06',
              ' ' 'BDC_SUBSCR' 'SAPLSEXM                                0200FMFG',
              ' ' 'BDC_SUBSCR' 'SAPLMR1M                                6530VENDOR_DATA',
              ' ' 'BDC_SUBSCR' 'SAPLMR1M                                6010ITEMS',
              ' ' 'BDC_SUBSCR' 'SAPLMR1M                                6020TABS',
              ' ' 'RM08M-REFERENZBELEGTYP' '1',
              ' ' 'BDC_SUBSCR' 'SAPLMR1M                                6211REFERENZBELEG',
              ' ' 'BDC_SUBSCR' 'SAPLMR1M                                6310ITEM',
              ' ' 'RM08M-ITEM_LIST_VERSION' '7_6310'.

            perform z_gera_tela using:
              'X' 'SAPLSPO4' '0300',
              ' ' 'BDC_CURSOR' 'SVALD-VALUE(04)',
              ' ' 'BDC_OKCODE' '=FURT',
              ' ' 'SVALD-VALUE(01)' vg_nprot,
              ' ' 'SVALD-VALUE(02)' vg_data,
              ' ' 'SVALD-VALUE(03)' vg_hora,
              ' ' 'SVALD-VALUE(04)' vg_chave.
            perform z_gera_tela using:
              'X' 'SAPLJ1BB2' '2000',
              ' ' 'BDC_OKCODE' '/ECANC'.
            perform z_gera_tela using:
              'X' 'SAPLSPO1' '0200',
              ' ' 'BDC_OKCODE' '=NO'.
            perform z_gera_tela using:
              'X' 'SAPLJ1BB2' '2000',
              ' ' 'BDC_OKCODE' '/ECANC',
              ' ' 'BDC_OKCODE' '=YES'.

            call transaction 'MIRO'
            using t_bdc
            mode 'A'
            messages  into t_message.

            read table t_message into wa_message with key msgtyp = 'S' msgnr = '075'.

            if sy-subrc is initial.
              clear: wa_flwdoc.
              wa_flwdoc-chave = vg_chave.
              wa_flwdoc-natdc = '02'.
              wa_flwdoc-typed = 'CTE1'.
              wa_flwdoc-flowd = '10'.
              wa_flwdoc-dtreg = sy-datum.
              wa_flwdoc-hrreg = sy-uzeit.
              wa_flwdoc-uname = sy-uname.
              wa_flwdoc-flwst = 'M'.

              delete from zhms_tb_flwdoc where chave eq vg_chave.
              insert into zhms_tb_flwdoc values wa_flwdoc.

              if sy-subrc is initial.
                commit work.
                clear wa_docmn.

                select single max( seqnr )
                  into vg_seqnr
                  from zhms_tb_docmn
                 where chave eq vg_chave.

                add 1 to vg_seqnr.

                move: vg_chave to wa_docmn-chave,
                      'MATDOC'             to wa_docmn-mneum,
                      wa_message-msgv1 to wa_docmn-value,
                      vg_seqnr             to wa_docmn-seqnr.

* Atualiza DOCMN com o número da nota gerada
                modify zhms_tb_docmn from wa_docmn.


                if sy-subrc is initial.
                  commit work.

                  update zhms_tb_docst
                  set sthms = '1'
                  where chave eq vg_chave.

                  if sy-subrc is initial.
                    commit work.
                  endif.
                endif.


              endif.

              perform f_refresh_docs_status.
            else.
              read table t_message into wa_message with key msgtyp = 'S' msgnr = '060'.

              if sy-subrc is initial.
                clear: wa_flwdoc.
                wa_flwdoc-chave = vg_chave.
                wa_flwdoc-natdc = '02'.
                wa_flwdoc-typed = 'CTE1'.
                wa_flwdoc-flowd = '10'.
                wa_flwdoc-dtreg = sy-datum.
                wa_flwdoc-hrreg = sy-uzeit.
                wa_flwdoc-uname = sy-uname.
                wa_flwdoc-flwst = 'M'.

                delete from zhms_tb_flwdoc where chave eq vg_chave.
                insert into zhms_tb_flwdoc values wa_flwdoc.

                if sy-subrc is initial.
                  commit work.
                  clear wa_docmn.

                  select single max( seqnr )
                    into vg_seqnr
                    from zhms_tb_docmn
                   where chave eq vg_chave.

                  add 1 to vg_seqnr.

                  move: vg_chave to wa_docmn-chave,
                        'MATDOC'             to wa_docmn-mneum,
                        wa_message-msgv1 to wa_docmn-value,
                        vg_seqnr             to wa_docmn-seqnr.

* Atualiza DOCMN com o número da nota gerada
                  modify zhms_tb_docmn from wa_docmn.


                  if sy-subrc is initial.
                    commit work.

                    update zhms_tb_docst
                    set sthms = '1'
                    where chave eq vg_chave.

                    if sy-subrc is initial.
                      commit work.
                    endif.
                  endif.


                endif.

                perform f_refresh_docs_status.
              endif.


            endif.
          when others.

        endcase.
      endmethod.                    "on_function_selected
    endclass.                    "lcl_toolbar_events IMPLEMENTATION


**----------------------------------------------------------------------*
**   Declarações Globais da Classe
**----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       CLASS LCL_APPLICATION IMPLEMENTATION
*----------------------------------------------------------------------*
    class lcl_application implementation.

      method  handle_link_click.
**      Variáveis Locais
        data: vl_index    type sy-tabix,
              vl_chave    type zhms_tb_cabdoc-chave,
              vl_tipo_doc type zhms_de_tdsrf,
              ls_doclink  type zhms_tip_doclink.
        clear: vl_index, v_index.

*** Inicio inclusão David Rosin 13/02/2014
        if sy-repid eq 'SAPLZHMS_FG_MONITOR' and sy-dynnr eq '0400'.

          move: node_key to vl_index,
                node_key to v_index.
          read table t_hrvalid_aux into wa_hrvalid_aux index vl_index.

          if sy-subrc is initial and wa_hrvalid_aux-vldv1 is not initial and wa_hrvalid_aux-atitm is initial and wa_hrvalid_aux-vldty ne 'E'.

            select single tdsrf into vl_tipo_doc from zhms_tb_itmatr where natdc eq wa_hrvalid_aux-natdc
                                                                       and typed eq wa_hrvalid_aux-typed
                                                                       and chave eq wa_hrvalid_aux-chave.
            if sy-subrc is initial and vl_tipo_doc is not initial.
              select single * from zhms_tip_doclink into ls_doclink where cod_doc eq vl_tipo_doc.

              if sy-subrc is initial.
                set parameter id ls_doclink-param_id_doc field wa_hrvalid_aux-vldv1.
                call transaction  ls_doclink-tcode and skip first screen.
              endif.
            endif.

          else.
*** Abre tela para exibir o numero do item contendo o erro
            call screen 407." STARTING AT 30 1.
          endif.
*** Fim Inclusão David Rosin 13/02/2014
        else.
**      Identificar o item selecionado
          perform f_get_selected_flow changing vl_index.
          read table t_scenflo into wa_scenflo index vl_index.

**      Prepara chamada de transação para exibir o documento
**       Documento
          clear wa_docmn.
          read table t_docmn_rep into wa_docmn with key mneum = wa_scenflo-mndoc.
          if sy-subrc is initial.

            set parameter id wa_scenflo-tpadc field wa_docmn-value.
          else.
*** Caso numero de migo não seja encontrado seignifico que a busca é pelo numero de estorno
            if wa_scenflo-tcode eq 'MIR4'.
              read table t_docmn_rep into wa_docmn with key mneum = 'REASON'.
            else.
              read table t_docmn_rep into wa_docmn with key mneum = 'MATDOCEST'.
            endif.

            set parameter id wa_scenflo-tpadc field wa_docmn-value.
          endif.

**       Ano
          clear wa_docmn.
          read table t_docmn_rep into wa_docmn with key mneum = wa_scenflo-mnyea.
          if sy-subrc is initial.
            set parameter id wa_scenflo-tpaye field wa_docmn-value.
          endif.

          if vg_estorno is initial.
            call transaction  wa_scenflo-tcode and skip first screen.
          endif.

        endif.
      endmethod.                    "HANDLE_LINK_CLICK

      method  handle_button_click.
****    Variáveis Locais
        data: vl_index type sy-tabix.
        clear vl_index.

****    Identificar o item selecionado
        perform f_get_selected_flow changing vl_index.

***     Limpar etapa
        clear wa_flwdoc.
        read table t_flwdoc into wa_flwdoc index vl_index.
        clear vg_flowd.
        vg_flowd = wa_flwdoc-flowd.
        condense vg_flowd no-gaps.

        case item_name.
          when 'ESTOR'.
            perform f_estorno using vl_index.
          when others.
***     Chamar Subtela
            call screen 300 starting at 30 1.
        endcase.

      endmethod.                    "HANDLE_BUTTON_CLICK


    endclass.                    "LCL_APPLICATION IMPLEMENTATION
