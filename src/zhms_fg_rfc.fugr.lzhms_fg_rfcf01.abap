*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_RFCF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  f_e_ENTRADA
*&---------------------------------------------------------------------*
*       Processamento para Mensagens de entrada
*----------------------------------------------------------------------*
form f_entrada.
*  Se for Serviço localizar o Loctp - Identif. do Município
  if v_extpd = 'NFSE'. "NFSE
    perform f_e_localiza_loctp.
  endif.

  if v_extpd = '55'.
    perform f_e_verificatiponfe.
  endif.


  if v_extpd = '57'.
    clear: v_debposterior.
    read table it_mssdata into wa_mssdata with key field = 'CTEPROC/CTE/INFCTE/INFCTENORM/INFDOC/INFNFE/CHAVE'.
    if sy-subrc = 0.
      v_chave = wa_mssdata-value.
    endif.
    if v_chave is initial.
      read table it_mssdata into wa_mssdata with key field = 'CTEPROC/CTE/INFCTE/INFCTECOMP/CHCTE'.
      if sy-subrc = 0.
        v_chave = wa_mssdata-value.
      endif.
    endif.
*    SELECT * FROM zhms_tb_docmn INTO TABLE it_docmn WHERE chave EQ wa_mssdata-value.
*    IF sy-subrc IS INITIAL.
    if not v_chave is initial.
      v_debposterior = 'X'.
      select single * from j_1bnfe_active into wa_j_1bnfe_active where
        regio eq wa_mssdata-value+0(2)
        and nfyear eq wa_mssdata-value+2(2)
        and stcd1 eq wa_mssdata-value+6(14)
        and model eq wa_mssdata-value+20(2)
        and serie eq wa_mssdata-value+22(3)
        and nfnum9 eq wa_mssdata-value+25(9)
        and docnum9 eq wa_mssdata-value+34(9)
        and cdv eq wa_mssdata-value+43(1).

      if sy-subrc is initial.
        select single * from j_1bnfdoc into wa_j1bnfdoc where
          docnum eq wa_j_1bnfe_active-docnum
          and direct eq '1'.
*          AND manual EQ 'X'.

        if sy-subrc is initial.
          v_debposterior = 'X'.
        else.
          v_debposterior = ''.
        endif.
      else.
        v_debposterior = ''.
      endif.
    else.
      v_debposterior = 'X'.
    endif.
  endif.

* Selecionar mensageria
  perform f_e_seleciona_mensageria.
** Filtro Mensageria
  perform f_e_filtra_mensageria.
* Verifica se houve erro crítico no processamento.
  if not v_critc is initial.
    perform f_e_grava_criticas.
    exit.
  endif.

** Seleção do evento da mensageria
  perform f_e_seleciona_evento.
** Filtro Evento
  perform f_e_filtra_evento.
* Verifica se houve erro crítico no processamento.
  if not v_critc is initial.
    perform f_e_grava_criticas.
    exit.
  endif.

** Seleção de Verões de Layouts para Padrão HomSoft
  perform f_seleciona_versao_padrao.
** Filtro de versões para Layout Padrão HomSoft
  perform f_filtra_versao_padrao.
*DDPT - Inicio da Inclusão.
** Valida se o XML contém caracter especial
  perform f_seleciona_caracter.
*DDPT - Fim da Inclusão
* Verifica se houve erro crítico no processamento.
  if not v_critc is initial.
    perform f_e_grava_criticas.
    exit.
  endif.

** Seleção de Verões de Layouts da mensageria
  perform f_seleciona_versoes_mensageria.
** Filtro de versões para Layout da mensageria
  perform f_filtra_versao_mensageria.
* Verifica se houve erro crítico no processamento.
  if not v_critc is initial.
    perform f_e_grava_criticas.
    exit.
  endif.

  perform f_e_seleciona_layouts.
* Verifica se houve erro crítico no processamento.
  if not v_critc is initial.
    perform f_e_grava_criticas.
    exit.
  endif.

** Ajustar layout encaminhado pela mensageria p/ layout default da aplicação
  perform f_e_transforma_padrao.
  if not v_critc is initial.
    perform f_e_grava_criticas.
    exit.
  endif.

** Seleciona Mapeamento de Dados das tabelas
  perform  f_e_seleciona_mapeamento.

endform.                    "f_e_entrada
*&---------------------------------------------------------------------*
*&      Form  f_e_SELECIONA_MENSAGERIA
*&---------------------------------------------------------------------*
*       Selecionar Mensageria Remetente/Destinatária da
*       mensagem
*----------------------------------------------------------------------*
form f_e_seleciona_mensageria .

* Check de chave
  check not v_mensg is initial.

* Seleção da Mensageria
  if v_extpd eq '57'.
    if v_debposterior = 'X'.
      select *
      into table it_messag
      from zhms_tb_messagin
     where
        typed eq 'CTE1'.
    else.
      select *
        into table it_messag
        from zhms_tb_messagin
       where
          mensg eq v_mensg and
          exnat eq v_exnat and
          extpd eq v_extpd
          and typed eq 'CTE'.
    endif.
  else.


    if v_importacao eq 'X'.
      select *
        into table it_messag
        from zhms_tb_messagin
       where
        typed eq 'NFE3'.
    endif.

    if v_subcontratacao eq 'X'.
      select *
        into table it_messag
        from zhms_tb_messagin
       where
        typed eq 'NFE1'.
    endif.

    if v_subcontratacao2 eq 'X'.
      select *
        into table it_messag
        from zhms_tb_messagin
       where
        typed eq 'NFE4'.
    endif.

    if v_subcontratacao3 eq 'X'.
      select *
        into table it_messag
        from zhms_tb_messagin
       where
        typed eq 'NFE5'.
    endif.

    if v_subcontratacao ne 'X' and v_importacao ne 'X' and v_subcontratacao2 ne 'X' and v_subcontratacao3 ne 'X'.
      select *
        into table it_messag
        from zhms_tb_messagin
       where
          mensg eq v_mensg and
          exnat eq v_exnat and
          extpd eq v_extpd and
          typed ne 'NFE3' and
          typed ne 'NFE1' and
          typed ne 'NFE4' and
          typed ne 'NFE5'.

    endif.
  endif.


***Renan Itokazo
***02.08.2018
***IF V_EXTPD = 'NFSE'.
***    DELETE IT_MESSAG WHERE LOCTP NE V_LOCTP.
***  ENDIF.

endform.                    " f_e_SELECIONA_MENSAGERIA
*&---------------------------------------------------------------------*
*&      Form  f_e_FILTRA_MENSAGERIA
*&---------------------------------------------------------------------*
*       Filtro de mensageria
*----------------------------------------------------------------------*
form f_e_filtra_mensageria.
*  Retira possíveis espaços antes e depois dos parametros recebidos
  condense:  v_exnat, v_extpd.

* Verifica se foi encontrado registro
  if it_messag[] is initial.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    wa_logunk-erro = 'Erro: Tipo/Natureza não encontrados p/ mensageria'.
    perform f_erro.
    exit.
  endif.

* Veririca se multiplos registros foram encontrados
  clear v_tabix.
  describe table it_messag lines v_tabix.

  if v_tabix gt 1.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    wa_logunk-erro = 'Erro: Conflito em Tipo/Natureza p/ mensageria = muitos registros'.
    perform f_erro.
    exit.
  endif.

* Preenche as variáveis com os valores encontrados
  read table it_messag into wa_messag index 1.
  if sy-subrc is initial.
    v_natdc = wa_messag-natdc.
    v_typed = wa_messag-typed.
    v_loctp = wa_messag-loctp.
  endif.
endform.                    " f_e_FILTRA_MENSAGERIA


*&---------------------------------------------------------------------*
*&      Form  f_e_SELECIONA_EVENTO
*&---------------------------------------------------------------------*
*       Seleciona Eventos de acordo com a mensageria
*----------------------------------------------------------------------*
form f_e_seleciona_evento .

* Check de chave
  check: not v_mensg is initial,
         not v_natdc is initial,
         not v_typed is initial.

* Seleção de evento
  select *
    into table it_msgeve
    from zhms_tb_msg_even
   where natdc  eq  v_natdc
     and typed  eq  v_typed
     and mensg  eq  v_mensg.

  if v_extpd = 'NFSE'.
    delete it_msgeve where loctp ne v_loctp.
  endif.


endform.                    " f_e_SELECIONA_EVENTO
*&---------------------------------------------------------------------*
*&      Form  f_e_FILTRA_EVENTO
*&---------------------------------------------------------------------*
*       Filtro de eventos
*----------------------------------------------------------------------*
form f_e_filtra_evento .

*  Retira possíveis espaços antes e depois dos parametros recebidos
  condense: v_exevt.

  delete it_msgeve
   where exevt ne v_exevt.

* Verifica se foi encontrado registro
  if it_msgeve[] is initial.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    wa_logunk-erro = 'Erro: Evento não encontrado p/ mensageria'.
    perform f_erro.
    exit.
  endif.

* Veririca se multiplos registros foram encontrados
  clear v_tabix.
  describe table it_msgeve lines v_tabix.

  if v_tabix gt 1.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    wa_logunk-erro = 'Erro: Conflito em Evento p/ mensageria = muitos registros'.
    perform f_erro.
    exit.
  endif.

* Preenche as variáveis com os valores encontrados
  read table it_msgeve into wa_msgeve index 1.
  if sy-subrc is initial.
    v_event = wa_msgeve-event.
  endif.

endform.                    " f_e_FILTRA_EVENTO
*&---------------------------------------------------------------------*
*&      Form  F_SELECIONA_VERSAO_PADRAO
*&---------------------------------------------------------------------*
*       Seleciona a Versão
*----------------------------------------------------------------------*
form f_seleciona_versao_padrao .

* Check de chave
  check: not v_natdc is initial,
         not v_typed is initial,
         not v_event is initial.

* Seleção de versões
  select *
    into table it_ev_vrs
    from zhms_tb_ev_vrs
   where natdc eq v_natdc
     and typed eq v_typed
     and event eq v_event.


  if v_extpd = 'NFSE'.
    delete  it_ev_vrs where loctp ne v_loctp.
  endif.


endform.                    " F_SELECIONA_VERSAO_PADRAO
*&---------------------------------------------------------------------*
*&      Form  F_E_SELECIONA_MAPEAMENTO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form f_e_seleciona_mapeamento .

  select * into table it_mapconec
    from zhms_tb_mapconec
  where
    natdc = v_natdc and
    typed = v_typed and
    mensg = v_mensg and
    event = v_event .

  if v_extpd = 'NFSE1'.
    delete  it_mapconec where loctp ne v_loctp.
  endif.

* Veririca se multiplos registros foram encontrados
  clear v_tabix.
  describe table it_mapconec lines v_tabix.
  if v_tabix gt 1.
*   Tratamento de Erro
    clear wa_logunk.
    wa_logunk-erro = 'Erro: Múltiplos Mapeamentos para o Conector encontrados no mesmo evento'.
    perform f_erro.
    perform f_e_grava_criticas.
    exit.
  endif.

  clear wa_mapconec.
  read table it_mapconec into wa_mapconec index 1.
  if sy-subrc eq 0.
    if wa_mapconec-rotin is initial.
*   Tratamento de Erro
      clear wa_logunk.
      wa_logunk-erro = 'Erro: Rotina não cadastrada para o Evento'.
      perform f_erro.
      perform f_e_grava_criticas.
      exit.
    else.
      perform (wa_mapconec-rotin) in program saplzhms_fg_rfc if found.
      if sy-subrc ne 0.
*   Tratamento de Erro
        clear wa_logunk.
        wa_logunk-erro = 'Erro: Rotina não encontrada para o Evento'.
        perform f_erro.
        perform f_e_grava_criticas.
        exit.
      endif.
    endif.
  else.
*   Tratamento de Erro
    clear wa_logunk.
    wa_logunk-erro = 'Erro: Mapeamento para as tabelas de Sistema não encontrado.'.
    perform f_erro.
    perform f_e_grava_criticas.
    exit.
  endif.

endform.                    " F_E_SELECIONA_MAPEAMENTO
*&---------------------------------------------------------------------*
*&      Form  F_FILTRA_VERSAO_PADRAO
*&---------------------------------------------------------------------*
*       Filtra a Versão
*----------------------------------------------------------------------*
form f_filtra_versao_padrao .
* remover inativos
  delete it_ev_vrs where ativo is initial.

* Verifica se foi encontrado registro
  if it_ev_vrs[] is initial.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    wa_logunk-erro = 'Erro: Nenhuma versao de layout padrão ativa encontrado p/ evento'.
    perform f_erro.
    exit.
  endif.

  read table it_ev_vrs into wa_ev_vrs index 1.
  if sy-subrc is initial.
    v_versn = wa_ev_vrs-versn.
  endif.

* Verifica se foi encontrado registro
  if v_versn is initial.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    wa_logunk-erro = 'Erro: Nenhuma versao de layout padrão ativa p/ evento atende os parâmetros'.
    perform f_erro.
    exit.
  endif.

endform.                    " F_FILTRA_VERSAO_PADRAO

*&---------------------------------------------------------------------*
*&      Form  f_SELECIONA_VERSOES
*&---------------------------------------------------------------------*
*       Seleção de versões de layouts para eventos da mensageria
*----------------------------------------------------------------------*
form f_seleciona_versoes_mensageria .

* Check de chave
  check: not v_mensg is initial,
         not v_natdc is initial,
         not v_typed is initial,
         not v_event is initial.

* Seleção de versões
  select *
    into table it_msgevr
    from zhms_tb_msge_vrs
   where natdc eq v_natdc
     and typed eq v_typed
     and mensg eq v_mensg
     and event eq v_event
     and versn eq v_versn.

  if v_extpd = 'NFSE'.
    delete it_msgevr where loctp ne v_loctp.
  endif.

endform.                    " f_SELECIONA_VERSOES

*&---------------------------------------------------------------------*
*&      Form  f_FILTRA_VERSAO
*&---------------------------------------------------------------------*
*       Filtra versões de layout para o evento da mensageria
*----------------------------------------------------------------------*
form f_filtra_versao_mensageria .
* Remover Inativos
  delete it_msgevr where ativo is initial.

* Verifica se foi encontrado registro
  if it_msgevr[] is initial.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    wa_logunk-erro = 'Erro: Nenhuma versao de layout ativa encontrado p/ evento da mensageria'.
    perform f_erro.
    exit.
  endif.

endform.                    " f_FILTRA_VERSAO

*&---------------------------------------------------------------------*
*&      Form  f_e_transforma_padrao
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form f_e_transforma_padrao .

  clear: v_chave,
         v_nnf,   "nfse
         v_serie,
         v_demi,
         v_cpf_cnpj.
  data: v_retorno type bapireturn.

  loop at  it_mssdata into wa_mssdata.
    clear: wa_evv_layt,
           wa_msgevlt.

    "Procura o field(tag) no layout do legado
    read table it_msgevlt into wa_msgevlt
    with key field = wa_mssdata-field.
    if sy-subrc eq 0.

      if v_typed = 'CTE' or v_typed = 'CTE1' .
        "Procura o código do field no layout padrão para achar o mneumônico
        "chave


        read table it_evv_layt into wa_evv_layt
        with key codly = wa_msgevlt-codly
                 mneum = c_chavecte.

        if sy-subrc eq 0.

          v_chave = wa_mssdata-value.
          exit.
        endif.
      elseif v_typed = 'NFSE1'.
        "Procura o código do field no layout padrão para achar o mneumônico
        "chave
        read table it_evv_layt into wa_evv_layt
        with key codly = wa_msgevlt-codly.
        if sy-subrc eq 0.
*          IF wa_evv_layt-mneum = c_nnf.
*            v_nnf = wa_mssdata-value.
**          ELSEIF wa_evv_layt-mneum = c_serie.
**            v_serie = wa_mssdata-value(1).
*          ELSEIF wa_evv_layt-mneum =  c_demi.
**            CONCATENATE wa_mssdata-value+2(2) wa_mssdata-value+5(2) INTO v_demi.
*            CONCATENATE wa_mssdata-VALUE+0(4) wa_mssdata-VALUE+2(2) wa_mssdata-VALUE+5(2) INTO V_DEMI.
*
**            CONCATENATE wa_mssdata-value+0(2) wa_mssdata-value+3(2) wa_mssdata-value+7(4) INTO v_demi.
*
*          ELSEIF wa_evv_layt-mneum =  c_cpf.
*            v_cpf_cnpj = wa_mssdata-value.
*          ELSEIF wa_evv_layt-mneum = c_cnpj.
*            v_cpf_cnpj = wa_mssdata-value.
*          ENDIF.
*
*          IF NOT v_nnf   IS INITIAL OR
*             NOT v_demi  IS INITIAL OR
*             NOT v_cpf_cnpj IS INITIAL.
** Patrícia
**            CONCATENATE v_nnf v_serie v_demi v_cpf_cnpj INTO v_chave.
*            CONCATENATE v_nnf v_demi v_cpf_cnpj INTO v_chave.
** Patricia
*          ENDIF.
          if wa_evv_layt-mneum = c_chave.
            v_chave = wa_mssdata-value.
          endif.
        endif.
      else.
        "Procura o código do field no layout padrão para achar o mneumônico
        "chave
        read table it_evv_layt into wa_evv_layt
        with key codly = wa_msgevlt-codly
                 mneum = c_chave .
        if sy-subrc eq 0.
          v_chave = wa_mssdata-value.
          exit.
        endif.
      endif.
    endif.
  endloop.

  "Senão vier a chave colocar no repositório de documentos não identificados.
  if v_chave is initial.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    wa_logunk-erro = 'Erro: Campo "Chave" do documento não identificado'.
    perform f_erro.
    exit.
  endif.

*  { Solução ByPass de Menumonicos
  data(go_entrada_documento) = new zcl_hms_entrada_documento( ).
  data(vg_bypass) = zcl_hms_params=>get_value( 'BY_PASS_MNEUMONICO' ).
  if vg_bypass eq 'X'.
    case v_typed.
      when 'NFE'.
        v_retorno = go_entrada_documento->save_xml_nfe( chave = v_chave
                                                       t_msgdt = it_mssdata ).
        v_retorno = go_entrada_documento->save_xml_atr_nfe( chave = v_chave
                                                       t_msgat = it_mssatrb ).
      when 'CTE'.
        v_retorno = go_entrada_documento->save_xml_cte( chave = v_chave
                                                      t_msgdt = it_mssdata ).
        v_retorno = go_entrada_documento->save_xml_atr_cte( chave = v_chave
                                                      t_msgat = it_mssatrb ).
      when 'NFSE'.
        v_retorno = go_entrada_documento->save_xml_nfse( chave = v_chave
                                                   t_msgdt = it_mssdata ).
        v_retorno = go_entrada_documento->save_xml_atr_nfse( chave = v_chave
                                                      t_msgat = it_mssatrb ).
    endcase.
  endif.
  if v_retorno is not initial.
    v_critc = 'X'.
    clear wa_logunk.
    wa_logunk-erro = |Erro:{ v_retorno-message }{ v_retorno-message_v1 } |
                     && | { v_retorno-message_v2 }{ v_retorno-message_v3 }|
                     && | { v_retorno-message_v4 }|.
    perform f_erro.
    exit.
  endif.
*  }  Solução ByPass de Menumonicos

  "Gravação dos dados no repositório e no repositório de mneumônicos
  loop at  it_mssdata into wa_mssdata.
    clear: wa_evv_layt,
           wa_msgevlt,
           wa_repotag,
           wa_repotagat,
           wa_repomneum,
           wa_repomneumat.

    "Procura o field(tag) no layout do legado
    read table it_msgevlt into wa_msgevlt
    with key field = wa_mssdata-field.
    if sy-subrc eq 0.

      "Procura o código do field no layout padrão para achar o mneumônico
      read table it_evv_layt into wa_evv_layt
      with key codly = wa_msgevlt-codly.

      if sy-subrc eq 0.
        "1. Grava no repositório de tags
        wa_repotag-chave = v_chave.
        wa_repotag-direc = v_direc.
        wa_repotag-seqnc = wa_mssdata-seqnc.
        wa_repotag-dcitm = wa_mssdata-dcitm.
        wa_repotag-field = wa_mssdata-field.
        wa_repotag-value = wa_mssdata-value.
        wa_repotag-lote  = v_loted.
        wa_repotag-dtalt = v_data.
        wa_repotag-hralt = v_hora.
        append wa_repotag to it_repotag.

        "2. Grava na tabela repositório de Mneumônicos
        wa_repomneum-seqnr = wa_mssdata-seqnc.
        wa_repomneum-chave = v_chave.
        wa_repomneum-mneum = wa_evv_layt-mneum.
        wa_repomneum-dcitm = wa_mssdata-dcitm.

*** Inicio inclusão David Rosin 14/11/2014
        clear v_naograva.
        if wa_evv_layt-mneum = 'XPED'.

          call function 'NUMERIC_CHECK'
            exporting
              string_in = wa_mssdata-value
            importing
              htype     = v_tipo.

          if v_tipo ne 'NUMC'.
            v_naograva = 'X'.
          else.

            clear: ls_ekko, v_ebeln.
            move wa_mssdata-value to v_ebeln.
            call function 'CONVERSION_EXIT_ALPHA_INPUT'
              exporting
                input  = v_ebeln
              importing
                output = v_ebeln.

*** Verifica se o pedido de compra existe
            select single *
              from ekko
              into ls_ekko
             where ebeln eq v_ebeln.

            if sy-subrc is not initial.
              v_naograva = 'X'.
            endif.
          endif.

        elseif wa_evv_layt-mneum = 'DEMI'.

          v_data_xml  = wa_mssdata-value.
          condense v_data_xml  no-gaps.
          clear wa_mssdata-value.
          wa_mssdata-value = v_data_xml(10).

        elseif wa_evv_layt-mneum = 'DHEMI' and v_typed = 'CTE'.

          v_data_xml  = wa_mssdata-value.
          condense v_data_xml  no-gaps.
          clear wa_mssdata-value.
          wa_mssdata-value = v_data_xml(10).

        elseif wa_evv_layt-mneum = 'DHSAIENT'.

          v_data_xml  = wa_mssdata-value.
          condense v_data_xml  no-gaps.
          clear wa_mssdata-value.
          wa_mssdata-value = v_data_xml(10).

        elseif wa_evv_layt-mneum = 'DESTCNPJ' and v_typed = 'CTE'.

          read table it_mssdata into wa_mssdatax with key field =  'CTEPROC/CTE/INFCTE/IDE/TOMA3/TOMA'.

          if sy-subrc is initial.

            case wa_mssdatax-value.
              when '0'.
                read table it_mssdata into wa_mssdatax with key field =  'CTEPROC/CTE/INFCTE/REM/CNPJ'.

                if sy-subrc is initial.
                  wa_mssdata-value = wa_mssdatax-value.
                endif.
              when '1'.
                read table it_mssdata into wa_mssdatax with key field =  'CTEPROC/CTE/INFCTE/EXPED/CNPJ'.

                if sy-subrc is initial.
                  wa_mssdata-value = wa_mssdatax-value.
                endif.
              when '2'.
                read table it_mssdata into wa_mssdatax with key field =  'CTEPROC/CTE/INFCTE/RECEB/CNPJ'.

                if sy-subrc is initial.
                  wa_mssdata-value = wa_mssdatax-value.
                endif.
              when '3'.
                read table it_mssdata into wa_mssdatax with key field =  'CTEPROC/CTE/INFCTE/DEST/CNPJ'.

                if sy-subrc is initial.
                  wa_mssdata-value = wa_mssdatax-value.
                endif.
            endcase.
          else.
            read table it_mssdata into wa_mssdatax with key field =  'CTEPROC/CTE/INFCTE/IDE/TOMA4/TOMA'.
            if sy-subrc is initial.
              read table it_mssdata into wa_mssdatax with key field =  'CTEPROC/CTE/INFCTE/IDE/TOMA4/CNPJ'.

              if sy-subrc is initial.
                wa_mssdata-value = wa_mssdatax-value.
              endif.
            endif.
          endif.
        endif.
*** Fim Inclusão David Rosin 14/11/2014

        wa_repomneum-value = wa_mssdata-value.
        wa_repomneum-lote  = v_loted.
*{ By Pass Mneumonico
        if vg_bypass eq 'X'.
          v_naograva = 'X'.
        endif.
*} By Pass Mneumonico
        if  v_naograva is initial.
          append wa_repomneum to it_repomneum.
        endif.

        "Verifica se a tag têm atributos
        loop at it_mssatrb into wa_mssatrb
              where seqnc = wa_mssdata-seqnc.

          "3. Grava no repositório de atributos
          wa_repotagat-chave = v_chave.
          wa_repotagat-direc = v_direc.
          wa_repotagat-seqnc = wa_mssatrb-seqnc.
          wa_repotagat-dcitm = wa_mssdata-dcitm.
          wa_repotagat-field = wa_mssatrb-field.
          wa_repotagat-value = wa_mssatrb-value.
          wa_repotagat-lote  = v_loted.
*{ By Pass Mneumonico
          if vg_bypass ne 'X'.
            append wa_repotagat to it_repotagat.
          endif.
*} By Pass Mneumonico
          "Encontra o nome do Mneumônico para o atributo
          read table it_evvl_atr into wa_evvl_atr
          with key field = wa_mssatrb-field.
          if sy-subrc eq 0.
            if not wa_evvl_atr-mneum is initial.
              "4. Grava no repositório de Mneumônicos atributos
              "se o atributo tiver mneumônico
              wa_repomneumat-mneum = wa_evvl_atr-mneum.
              wa_repomneumat-seqnr = wa_mssatrb-seqnc.
              wa_repomneumat-chave = v_chave.
              wa_repomneumat-dcitm = wa_mssdata-dcitm.
              wa_repomneumat-value = wa_mssatrb-value.
              wa_repomneumat-lote  = v_loted.
*{ By Pass Mneumonico
              if vg_bypass ne 'X'.
                append wa_repomneumat to it_repomneumat.
              endif.
*} By Pass Mneumonico
            endif.
          else.
            v_critc = 'X'.
*   Tratamento de Erro
            clear wa_logunk.
            v_seqnc = wa_mssatrb-seqnc.
            concatenate 'Erro: Atributo não possui mneumônico cadastrado no layout padrão. SEQNC: ' v_seqnc
            into wa_logunk-erro.
            perform f_erro.
          endif.
        endloop.
      else.
        v_critc = 'X'.
*   Tratamento de Erro
        clear wa_logunk.
        v_seqnc =  wa_mssdata-seqnc.
        concatenate 'Erro: Código do Field parametrizado para a tag do xml não foi encontrado no Layout Padrão. SEQNC: ' v_seqnc
       into wa_logunk-erro.
        perform f_erro.
      endif.
    else.
      v_critc = 'X'.
*   Tratamento de Erro
      clear wa_logunk.
      v_seqnc =  wa_mssdata-seqnc.
      concatenate 'Erro: Tag enviada pela Mensageria não parametrizada no Layout. SEQNC: ' v_seqnc
      into wa_logunk-erro.
      perform f_erro.
    endif.
  endloop.

endform.                    " F_QZIN_TRANSFORMA_PADRAO
*&---------------------------------------------------------------------*
*&      Form  F_E_INSERE_REGISTRO_CAB
*&---------------------------------------------------------------------*
*       Insere registro na tabela de cabeçalho do sistema
*----------------------------------------------------------------------*
form f_e_prepara_registro_cab .


  if not wa_mapdatac-retfo is initial.

    if v_typed eq 'NFSE1'.
      wa_repomneum-value = wa_repomneum-value(10).
      replace all occurrences of '/' in wa_repomneum-value with ''.
*      CONCATENATE wa_repomneum-value+5(2) wa_repomneum-value+8(2) wa_repomneum-value+0(4) INTO wa_repomneum-value.
*Renan Itokazo
*12.09.2018

*YYYY.MM.DD
*      CONCATENATE wa_repomneum-value+0(4) wa_repomneum-value+5(2) wa_repomneum-value+2(2) INTO wa_repomneum-value.
*      CONDENSE wa_repomneum-value NO-GAPS.
    else.
      replace all occurrences of '-' in wa_repomneum-value with ''.
      condense wa_repomneum-value no-gaps.
    endif.

  endif.


  if not wa_mapdatac-rotin is initial.
    assign component wa_mapdatac-tbfld of structure wa_cabdoc to <fs_field>.
    if sy-subrc eq 0.
      perform (wa_mapdatac-rotin) in program saplzhms_fg_rfc if found.
    endif.
  else.
    assign component wa_mapdatac-tbfld of structure wa_cabdoc to <fs_field>.
    if sy-subrc eq 0.
      <fs_field> = wa_repomneum-value.
    endif.

    if wa_repomneum-value is initial and not wa_mapdatac-obrig is initial .
      v_critc = 'X'.
*   Tratamento de Erro
      clear wa_logunk.
      concatenate 'Erro: Gravação Cabeçalho Documento. Mneumônico: '  wa_repomneum-mneum ' têm valor Nulo Sequência: '
      wa_repomneum-seqnr  into wa_logunk-erro.
      perform f_erro.
    endif.
  endif.

endform.                    "f_e_prepara_registro_cab
*&---------------------------------------------------------------------*
*&      Form  F_E_INSERE_REGISTRO_ITM
*&---------------------------------------------------------------------*
*       Insere registro na tabela de itens do sistema
*----------------------------------------------------------------------*
form f_e_prepara_registro_itm .

  if wa_itmdoc-dcitm ne wa_repomneum-dcitm and
    ( not wa_itmdoc-dcitm is initial ).
    wa_itmdoc-natdc = v_natdc.
    wa_itmdoc-chave = v_chave.
    wa_itmdoc-typed = v_typed.
    wa_itmdoc-loctp = v_loctp.
    wa_itmdoc-lote =  v_loted.

    append wa_itmdoc to it_itmdoc.
    clear wa_itmdoc.
  endif.

  if not wa_mapdatac-rotin is initial.
    assign component wa_mapdatac-tbfld of structure wa_itmdoc to <fs_field>.
    if sy-subrc eq 0.
      perform (wa_mapdatac-rotin) in program saplzhms_fg_rfc if found.
    endif.
  else.
    assign component wa_mapdatac-tbfld of structure wa_itmdoc to <fs_field>.
    if sy-subrc eq 0.
      wa_itmdoc-dcitm = wa_repomneum-dcitm.
      <fs_field> = wa_repomneum-value.
    endif.
  endif.
  if wa_repomneum-value is initial and not wa_mapdatac-obrig is initial.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    concatenate 'Erro: Gravação Item Documento - Mneumônico '  wa_repomneum-mneum ' têm valor Nulo Sequência: '
    wa_repomneum-seqnr into wa_logunk-erro.
    perform f_erro.
  endif.

endform.                    "f_e_prepara_registro_itm

*&---------------------------------------------------------------------*
*&      Form  f_e_encontra_empresa
*&---------------------------------------------------------------------*
*  Encontra a Empresa
*----------------------------------------------------------------------*
form f_e_encontra_empresa.
  data: lv_cgc_number like j_1bwfield-cgc_number,
        lv_cgccomp    like j_1bwfield-cgc_compan,
        lv_cgc        like j_1bwfield-cgc_branch.

  clear v_bukrs.

*  IF v_importacao IS INITIAL.
  v_cnpjemp = wa_repomneum-value.

  lv_cgccomp = v_cnpjemp+0(8).
  lv_cgc = v_cnpjemp+8(4).

  if not v_cnpjemp is initial.
    call function 'J_1BBUILD_CGC'
      exporting
        cgc_company = lv_cgccomp
        cgc_branch  = lv_cgc
      importing
        cgc_number  = lv_cgc_number.

*    SELECT SINGLE bukrs
*    INTO  <fs_field>
*    FROM j_1bbranch
*    WHERE
*      stcd1 = v_cnpjemp.

    select single bukrs
      from t001z
      into <fs_field>
      where paval eq lv_cgccomp.

* IF sy-subrc NE 0 AND NOT wa_mapdatac-obrig IS INITIAL .
    if lv_cgc_number ne v_cnpjemp and not wa_mapdatac-obrig is initial .
      v_critc = 'X'.
*Tratamento de Erro
      clear wa_logunk.
      concatenate 'Erro: Gravação Cabeçalho Documento. Valor do Mneumônico: '  wa_repomneum-mneum ' não encontrado em j_1bbranch. Sequência: '
      wa_repomneum-seqnr  into wa_logunk-erro.
      perform f_erro.
    endif.
  else.
    if not wa_mapdatac-obrig is initial .
      v_critc = 'X'.
*   Tratamento de Erro
      clear wa_logunk.
      concatenate 'Erro: Gravação Cabeçalho Documento. Mneumônico: '  wa_repomneum-mneum ' têm valor Nulo Sequência: '
      wa_repomneum-seqnr  into wa_logunk-erro.
      perform f_erro.
    endif.
  endif.
*  ELSE.
*
*  ENDIF.



endform.                    "f_e_encontra_empresa

*&---------------------------------------------------------------------*
*&      Form  F_E_ENCONTRA_EMPRESA_IMP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form f_e_encontra_empresa_imp.
  data: v_serie type c length 3.

  if wa_repomneum-value eq '3'.
    call function 'CONVERSION_EXIT_ALPHA_INPUT'
      exporting
        input  = wa_cabdoc-serie
      importing
        output = v_serie.




    select single bukrs
      from j_1bnfdoc
      into <fs_field>
    where nftype eq 'ZM' and
          direct eq 1 and
          nfenum eq wa_cabdoc-docnr and
          series eq v_serie and
          cgc eq '' and
          cnpj_bupla eq wa_repomneum-chave+6(14).

    if sy-subrc ne 0 and not wa_mapdatac-obrig is initial .
      v_critc = 'X'.
*  Tratamento de Erro
      clear wa_logunk.
      concatenate 'Erro: Gravação Cabeçalho Documento, nota de importação. Valor do Mneumônico: '  wa_repomneum-mneum ' não encontrado em j_1bbranch. Sequência: '
      wa_repomneum-seqnr  into wa_logunk-erro.
      perform f_erro.
    endif.

  endif.
endform.                    "F_E_ENCONTRA_EMPRESA_IMP

*&---------------------------------------------------------------------*
*&      Form  F_E_ENCONTRA_FILIAL_IMP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form f_e_encontra_filial_imp.
  if wa_repomneum-value eq '3'.
    call function 'CONVERSION_EXIT_ALPHA_INPUT'
      exporting
        input  = wa_cabdoc-serie
      importing
        output = v_serie.


    select single branch
      from j_1bnfdoc
      into <fs_field>
    where nftype eq 'ZM' and
          direct eq 1 and
          nfenum eq wa_cabdoc-docnr and
          series eq v_serie and
          cgc eq '' and
          cnpj_bupla eq wa_repomneum-chave+6(14).

    if sy-subrc ne 0 and not wa_mapdatac-obrig is initial .
      v_critc = 'X'.
*  Tratamento de Erro
      clear wa_logunk.
      concatenate 'Erro: Gravação Cabeçalho Documento, nota de importação. Valor do Mneumônico: '  wa_repomneum-mneum ' não encontrado em j_1bbranch. Sequência: '
      wa_repomneum-seqnr  into wa_logunk-erro.
      perform f_erro.
    endif.
  endif.
endform.                    "F_E_ENCONTRA_FILIAL_IMP

*&---------------------------------------------------------------------*
*&      Form  F_E_ENCONTRA_PARCEIRO_IMP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form f_e_encontra_parceiro_imp.
  if wa_repomneum-value eq '3'.
    call function 'CONVERSION_EXIT_ALPHA_INPUT'
      exporting
        input  = wa_cabdoc-serie
      importing
        output = v_serie.

    select single parid
      from j_1bnfdoc
      into <fs_field>
    where nftype eq 'ZM' and
          direct eq 1 and
          nfenum eq wa_cabdoc-docnr and
          series eq v_serie and
          cgc eq '' and
          cnpj_bupla eq wa_repomneum-chave+6(14).

    if sy-subrc ne 0 and not wa_mapdatac-obrig is initial .
      v_critc = 'X'.
*  Tratamento de Erro
      clear wa_logunk.
      concatenate 'Erro: Gravação Cabeçalho Documento, nota de importação. Valor do Mneumônico: '  wa_repomneum-mneum ' não encontrado em j_1bbranch. Sequência: '
      wa_repomneum-seqnr  into wa_logunk-erro.
      perform f_erro.
    endif.
  endif.
endform.                    "F_E_ENCONTRA_PARCEIRO_IMP



*&---------------------------------------------------------------------*
*&      Form  f_e_encontra_empresa
*&---------------------------------------------------------------------*
*  Encontra a Empresa
*----------------------------------------------------------------------*
form f_e_encontra_filial.

  data: lv_cgc_number like j_1bwfield-cgc_number,
        lv_cgccomp    like j_1bwfield-cgc_compan,
        lv_cgc        like j_1bwfield-cgc_branch.

  if v_import is initial.
    v_cnpjemp = wa_repomneum-value.
  endif.


  if not wa_repomneum-value is initial.
    lv_cgccomp = v_cnpjemp+0(8).
    lv_cgc = v_cnpjemp+8(4).

    if not v_cnpjemp is initial.
      call function 'J_1BBUILD_CGC'
        exporting
          cgc_company = lv_cgccomp
          cgc_branch  = lv_cgc
        importing
          cgc_number  = lv_cgc_number.


      select single bukrs
        from t001z
        into <fs_field>
        where paval eq lv_cgccomp.

      select single branch
      into  <fs_field>
      from j_1bbranch
      where
        bukrs = <fs_field> and
        cgc_branch eq lv_cgc.

*    SELECT SINGLE bukrs
*      FROM t001z
*      INTO <fs_field>
*     WHERE paval EQ v_cnpjemp(8).
*
*    IF sy-subrc IS INITIAL.
*      SELECT SINGLE branch
*        INTO <fs_field>
*        FROM j_1bbranch
*       WHERE bukrs  EQ <fs_field>
*         AND branch EQ v_cnpjemp+8(4).
*    ENDIF.



      if lv_cgc_number ne v_cnpjemp and not wa_mapdatac-obrig is initial .
        v_critc = 'X'.
* Tratamento de Erro
        clear wa_logunk.
        concatenate 'Erro: Gravação Cabeçalho Documento. Valor do Mneumônico: '  wa_repomneum-mneum ' não encontrado em j_1bbranch. Sequência: '
        wa_repomneum-seqnr  into wa_logunk-erro.
        perform f_erro.
      endif.
    else.
      if not wa_mapdatac-obrig is initial .
        v_critc = 'X'.
*   Tratamento de Erro
        clear wa_logunk.
        concatenate 'Erro: Gravação Cabeçalho Documento. Mneumônico: '  wa_repomneum-mneum ' têm valor Nulo Sequência: '
        wa_repomneum-seqnr  into wa_logunk-erro.
        perform f_erro.
      endif.
    endif.
  endif.
endform.                    "f_e_encontra_empresa
*&---------------------------------------------------------------------*
*&      Form  f_e_encontra_parceiro
*&---------------------------------------------------------------------*
*  Encontra o parceiro de negócio
*----------------------------------------------------------------------*
form f_e_encontra_parceiro.

  if not wa_repomneum-value is initial.
    select single lifnr
    into <fs_field>
    from lfa1
    where stcd1 = wa_repomneum-value or
          stcd2 = wa_repomneum-value.

    if sy-subrc ne 0.
      select single kunnr
      into <fs_field>
      from kna1
      where stcd1 = wa_repomneum-value or
            stcd2 = wa_repomneum-value.
    endif.

    if not v_import is initial.
      v_cnpjemp = wa_repomneum-value.
    endif.

    if sy-subrc ne 0 and not wa_mapdatac-obrig is initial .
      v_critc = 'X'.
*   Tratamento de Erro
      clear wa_logunk.
      concatenate 'Erro: Gravação Cabeçalho Documento. Mneumônico: '  wa_repomneum-mneum ' têm valor Nulo Sequência: '
      wa_repomneum-seqnr  into wa_logunk-erro.
      perform f_erro.
    endif.
  else.
    if not wa_mapdatac-obrig is initial .
      v_critc = 'X'.
*   Tratamento de Erro
      clear wa_logunk.
      concatenate 'Erro: Gravação Cabeçalho Documento. Mneumônico: '  wa_repomneum-mneum ' têm valor Nulo Sequência: '
      wa_repomneum-seqnr  into wa_logunk-erro.
      perform f_erro.
    endif.
  endif.

endform.                    "f_e_encontra_parceiro
*&---------------------------------------------------------------------*
*&      Form  F_E_SELECIONA_LAYOUTS
*&---------------------------------------------------------------------*
form f_e_seleciona_layouts .

  " Encontra o Layout Padrão para tags
  select *
  from zhms_tb_evv_layt
  into table it_evv_layt
  where
     natdc = v_natdc and
     typed = v_typed and
     event = v_event and
     versn = v_versn.

  if v_extpd = 'NFSE'.
    delete it_evv_layt where loctp ne v_loctp.
  endif.

  if it_evv_layt[] is initial.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    wa_logunk-erro = 'Erro: Nenhum Layout HomSoft encontrado para os parâmetros'.
    perform f_erro.
    exit.
  endif.

  "Encontra o Layout padrão para atributos da tag
  select *
  into table it_evvl_atr
    from zhms_tb_evvl_atr
  where
      natdc = v_natdc and
      typed = v_typed and
      event = v_event and
      versn = v_versn.

  if v_extpd = 'NFSE'.
    delete it_evvl_atr where loctp ne v_loctp.
  endif.

  "Encontra o Layout para a Mensageria
  select *
  from zhms_tb_msgev_lt
  into table it_msgevlt
  where
      natdc = v_natdc and
      typed = v_typed and
      mensg = v_mensg and "Mensageria
      event = v_event and "Evento interno
      versn = v_versn.

  if v_extpd = 'NFSE'.
    delete it_msgevlt where loctp ne v_loctp.
  endif.

  if it_msgevlt[] is initial.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    wa_logunk-erro = 'Erro: Nenhum Layout Mensageria encontrado para os parâmetros'.
    perform f_erro.
    exit.
  endif.

endform.                    " F_E_SELECIONA_LAYOUTS
*&---------------------------------------------------------------------*
*&      Form  F_E_GRAVA_CRITICAS
*&---------------------------------------------------------------------*
form f_e_grava_criticas .

  loop at it_mssdata into wa_mssdata.
    wa_msgunk-lote  = v_loted.
    wa_msgunk-exnat = v_exnat.
    wa_msgunk-extpd = v_extpd.
    wa_msgunk-mensg = v_mensg.
    wa_msgunk-exevt = v_exevt.
    wa_msgunk-direc = v_direc.
    wa_msgunk-field = wa_mssdata-field.
    wa_msgunk-seqnc = wa_mssdata-seqnc.
    wa_msgunk-dcitm = wa_mssdata-dcitm.
    wa_msgunk-value = wa_mssdata-value.
    append wa_msgunk to it_msgunk.
  endloop.

  loop at it_mssatrb into wa_mssatrb.
    wa_msgunka-lote  = v_loted.
    wa_msgunka-exnat = v_exnat.
    wa_msgunka-extpd = v_extpd.
    wa_msgunka-mensg = v_mensg.
    wa_msgunka-exevt = v_exevt.
    wa_msgunka-direc = v_direc.
    wa_msgunka-field = wa_mssatrb-field.
    wa_msgunka-seqnc = wa_mssatrb-seqnc.
    wa_msgunka-value = wa_mssatrb-value.
    append wa_msgunka to it_msgunka.
  endloop.

  try .
      insert zhms_tb_msgunk   from table it_msgunk.
    catch cx_root.

  endtry.

  try .
      insert zhms_tb_msgunka  from table it_msgunka.
    catch cx_root.

  endtry.

  try .
      insert zhms_tb_logunk   from table it_logunk.
    catch cx_root.

  endtry.


  "Chave
  wa_histeve-natdc  =  v_natdc.
  wa_histeve-typed  =  v_typed.
  wa_histeve-event  =  v_event.
  wa_histeve-chave  =  v_chave.
  wa_histeve-tpeve  =  v_tpeve.
  wa_histeve-nseqev = v_nseqev.

  concatenate 'Erro no Retorno do Evento . Ver Log de Erros Nr. Lote: ' v_loted into
  wa_histeve-xmotivo.

  "Controle
  wa_histeve-lote    = v_loted.
  wa_histeve-dataenv = sy-datum.
  wa_histeve-horaenv = sy-uzeit.
  wa_histeve-usuario = 'QUAZARIS'.

  try .
      insert zhms_tb_histev from wa_histeve.
    catch cx_root.
      rollback work.
  endtry.

  commit work.

endform.                    " F_E_GRAVA_CRITICAS
*&---------------------------------------------------------------------*
*&      Form  F_ERRO
*&---------------------------------------------------------------------*
form f_erro .
*   Tratamento de Erro
  add 1 to v_nrmsg.
  wa_logunk-nrmsg = v_nrmsg.
  wa_logunk-lote  = v_loted.
  wa_logunk-exnat = v_exnat.
  wa_logunk-extpd = v_extpd.
  wa_logunk-mensg = v_mensg.
  wa_logunk-exevt = v_exevt.
  wa_logunk-direc = v_direc.
  wa_logunk-dtalt = v_data.
  wa_logunk-hralt = v_hora.
  wa_logunk-event = v_event.
  wa_logunk-natdc = v_natdc.
  wa_logunk-typed = v_typed.
  append wa_logunk to it_logunk.
endform.                    " F_ERRO
*&---------------------------------------------------------------------*
*&      Form  F_VALID_MAP_CABEC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form f_valid_map_cabec .

  read table it_mapdatac into wa_mapdatac with key  tipoi = '1'
                                                    tbfld = 'BUKRS'.
  if sy-subrc ne 0.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    wa_logunk-erro = 'Erro: Não encontrado parametrização de mneumônico para campo Obrigatório BUKRS.'.
    perform f_erro.
  else.
    if wa_mapdatac-rotin is initial.
      v_critc = 'X'.
*   Tratamento de Erro
      clear wa_logunk.
      wa_logunk-erro = 'Erro: Não encontrado parametrização de rotina para campo Obrigatório BUKRS.'.
      perform f_erro.
    endif.
  endif.

  read table it_mapdatac into wa_mapdatac with key tipoi = '1'
                                                   tbfld = 'BRANCH'.
  if sy-subrc ne 0.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    wa_logunk-erro = 'Erro: Não encontrado parametrização de mneumônico para campo Obrigatório BRANCH.'.
    perform f_erro.
  else.
    if wa_mapdatac-rotin is initial.
      v_critc = 'X'.
*   Tratamento de Erro
      clear wa_logunk.
      wa_logunk-erro = 'Erro: Não encontrado parametrização de rotina para campo Obrigatório BRANCH.'.
      perform f_erro.
    endif.
  endif.

  read table it_mapdatac into wa_mapdatac with key tipoi = '1'
                                                   tbfld = 'PARID'.
  if sy-subrc ne 0.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    wa_logunk-erro = 'Erro: Não encontrado parametrização de mneumônico para campo Obrigatório PARID.'.
    perform f_erro.
  else.
    if wa_mapdatac-rotin is initial.
      v_critc = 'X'.
*   Tratamento de Erro
      clear wa_logunk.
      wa_logunk-erro = 'Erro: Não encontrado parametrização de rotina para campo Obrigatório PARID.'.
      perform f_erro.
    endif.
  endif.

  read table it_mapdatac into wa_mapdatac with key tipoi = '1'
                                                   tbfld = 'DOCNR'.
  if sy-subrc ne 0.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    wa_logunk-erro = 'Erro: Não encontrado parametrização de mneumônico para campo Obrigatório DOCNR.'.
    perform f_erro.
  endif.

*  READ TABLE it_mapdatac  INTO wa_mapdatac WITH KEY tipoi = '1'
*                                                     tbfld = 'SERIE'.
*  IF sy-subrc NE 0.
*    v_critc = 'X'.
**   Tratamento de Erro
*    CLEAR wa_logunk.
*    wa_logunk-erro = 'Erro: Não encontrado parametrização de mneumônico para campo Obrigatório SERIE.'.
*    PERFORM f_erro.
*  ENDIF.

  read table it_mapdatac into wa_mapdatac with key tipoi = '1'
                                                   tbfld = 'DOCDT'.
  if sy-subrc ne 0.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    wa_logunk-erro = 'Erro: Não encontrado parametrização de mneumônico para campo Obrigatório DOCDT.'.
    perform f_erro.
  endif.

  "Verifica se é Importação
  loop at it_repomneum into wa_repomneum
                      where mneum = 'CFOP' and
                            value(1) = '3'.

    v_import = 'S'.
    exit.
  endloop.

endform.                    " F_VALID_MAP_CABEC
*&---------------------------------------------------------------------*
*&      Form  F_VALID_MAP_ITEM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form f_valid_map_item .

  read table  it_mapdatac into wa_mapdatac with key tipoi = '2'
                                                    tbfld = 'DENOM'.
  if sy-subrc ne 0.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    wa_logunk-erro = 'Erro: Não encontrado parametrização de mneumônico para campo Obrigatório DENOM - Item.'.
    perform f_erro.
  endif.

  read table  it_mapdatac into wa_mapdatac with key tipoi = '2'
                                                    tbfld = 'DCCMT'.
  if sy-subrc ne 0.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    wa_logunk-erro = 'Erro: Não encontrado parametrização de mneumônico para campo Obrigatório DCCMT - Item.'.
    perform f_erro.
  endif.

  read table  it_mapdatac into wa_mapdatac with key tipoi = '2'
                                                    tbfld = 'DCQTD'.
  if sy-subrc ne 0.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    wa_logunk-erro = 'Erro: Não encontrado parametrização de mneumônico para campo Obrigatório DCQTD - Item.'.
    perform f_erro.
  endif.

  read table  it_mapdatac into wa_mapdatac with key tipoi = '2'
                                                    tbfld = 'DCUNM'.
  if sy-subrc ne 0.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    wa_logunk-erro = 'Erro: Não encontrado parametrização de mneumônico para campo Obrigatório DCUMN - Item.'.
    perform f_erro.
  endif.

  read table  it_mapdatac into wa_mapdatac with key tipoi = '2'
                                                    tbfld = 'DCPRC'.
  if sy-subrc ne 0.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    wa_logunk-erro = 'Erro: Não encontrado parametrização de mneumônico para campo Obrigatório DCPRC - Item.'.
    perform f_erro.
  endif.

endform.                    " F_VALID_MAP_ITEM
*&---------------------------------------------------------------------*
*&      Form  F_VALID_MAP_STATUS
*&---------------------------------------------------------------------*
form f_valid_map_status .
  read table  it_mapdatac into wa_mapdatac with key tipoi = '3'
                                                    tbfld = 'STENT'.
  if sy-subrc ne 0.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    wa_logunk-erro = 'Erro: Não encontrado parametrização de mneumônico para campo Obrigatório STENT - DOCTO.'.
    perform f_erro.
  endif.

endform.                    " F_VALID_MAP_STATUS
*&---------------------------------------------------------------------*
*&      Form  F_VERIFICA_CHAVE
*&---------------------------------------------------------------------*

form f_verifica_chave .

  clear v_chaverec.

  select single chave into v_chaverec
  from zhms_tb_repdoc
  where
        chave = v_chave.

  if not v_chaverec is initial.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    concatenate 'Erro: O Documento: ' v_chave ' já existe na tabela zhms_tb_repdoc ' into wa_logunk-erro.
    perform f_erro.
  endif.

  select single chave into v_chaverec
  from zhms_tb_repdocat
  where
        chave = v_chave.
  if not v_chaverec is initial.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    concatenate 'Erro: O Documento: ' v_chave ' já existe na tabela zhms_tb_repdocat ' into wa_logunk-erro.
    perform f_erro.
  endif.

  select single chave into v_chaverec
  from zhms_tb_docmn
  where
       chave = v_chave.

  if not v_chaverec is initial.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    concatenate 'Erro: O Documento: ' v_chave ' já existe na tabela zhms_tb_docmn ' into wa_logunk-erro.
    perform f_erro.
  endif.

  select single chave into v_chaverec
  from zhms_tb_docmna
  where
       chave = v_chave.
  if not v_chaverec is initial.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    concatenate 'Erro: O Documento: ' v_chave ' já existe na tabela zhms_tb_docmna ' into wa_logunk-erro.
    perform f_erro.
  endif.

  select single chave into v_chaverec
  from zhms_tb_cabdoc
  where
    chave = v_chave.
  if not v_chaverec is initial.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    concatenate 'Erro: O Documento: ' v_chave ' já existe na tabela zhms_tb_cabdoc ' into wa_logunk-erro.
    perform f_erro.
  endif.

  select single chave into v_chaverec
  from zhms_tb_itmdoc
  where
   chave = v_chave.
  if not v_chaverec is initial.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    concatenate 'Erro: O Documento: ' v_chave ' já existe na tabela zhms_tb_itmdoc ' into wa_logunk-erro.
    perform f_erro.
  endif.

  select single chave into v_chaverec
  from zhms_tb_docst
  where
  chave = v_chave.
  if not v_chaverec is initial.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    concatenate 'Erro: O Documento: ' v_chave ' já existe na tabela zhms_tb_docst ' into wa_logunk-erro.
    perform f_erro.
  endif.

  select single chave into v_chaverec
  from zhms_tb_docmn_hs
  where
    chave = v_chave.
  if not v_chaverec is initial.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    concatenate 'Erro: O Documento: ' v_chave ' já existe na tabela zhms_tb_docmn_hs ' into wa_logunk-erro.
    perform f_erro.
  endif.

endform.                    " F_VERIFICA_CHAVE
*&---------------------------------------------------------------------*
*&      Form  F_VERIFICA_CHAVE_EVENTO
*&---------------------------------------------------------------------*
form f_verifica_chave_evento_mde .

  clear wa_repomneum.

  read table it_repomneum into wa_repomneum with key
                                            mneum = c_tpevemde.
  if sy-subrc eq 0.
    v_tpeve = wa_repomneum-value.
  else.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    concatenate 'Erro: Não encontrado Mneumônico :' c_tpevemde ' para o campo chave tpeve entre os dados recepcionados.' into
    wa_logunk-erro.
    perform f_erro.
  endif.


  clear wa_repomneum.

  read table it_repomneum into wa_repomneum with key
                                            mneum = c_nseqevmde.
  if sy-subrc eq 0.
    v_nseqev = wa_repomneum-value.
  else.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    concatenate 'Erro: Não encontrado Mneumônico :' c_nseqevmde ' para o campo chave seqev entre os dados recepcionados.' into
    wa_logunk-erro.
    perform f_erro.
  endif.

  condense v_tpeve  no-gaps.
  condense v_nseqev no-gaps.

  if v_tpeve is initial.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    wa_logunk-erro = 'Erro: Valor Nulo para campo chave TPEVE não permitido.'.
    perform f_erro.
  endif.

  if v_nseqev is initial.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    wa_logunk-erro = 'Erro: Valor Nulo para campo chave NSEQEV não permitido.'.
    perform f_erro.
  endif.


endform.                    " F_VERIFICA_CHAVE_EVENTO
*&---------------------------------------------------------------------*
*&      Form  F_RETORNO_MDE_CONSULTA_DOC
*&---------------------------------------------------------------------*
form f_retorno_mde_consulta_doc .
  clear:    wa_evst ,
            v_chaverec,
            v_critc,
            wa_histeve.

  unassign: <fs_field>.

  "Verifica se tem chave para atualizar o registro
  read table it_repomneum into wa_repomneum with key
                                                mneum = c_tpevemde. "Precisa criar um mneumonico diferenciado?
  if sy-subrc eq 0.
    wa_evst-tpeve = wa_repomneum-value.
  else.
    exit.
  endif.

  read table it_repomneum into wa_repomneum with key
                                                mneum = c_nseqevmde.
  if sy-subrc eq 0.
    wa_evst-nseqev = wa_repomneum-value.
  else.
    exit.
  endif.

  condense wa_evst-tpeve  no-gaps.
  condense wa_evst-nseqev no-gaps.

  if not wa_evst-tpeve is initial and not wa_evst-nseqev is initial .
**Trata dados
    loop at it_mapdatac into wa_mapdatac
         where tipoi = '5'.
      loop at it_repomneum into wa_repomneum
          where mneum eq wa_mapdatac-mneum.
        perform f_e_prepara_registro_stev.
      endloop.
    endloop.

**trata dados cabeçalho do evento
    loop at it_mapdatac into wa_mapdatac
      where tipoi = '6'.
      loop at it_repomneum into wa_repomneum
        where mneum eq wa_mapdatac-mneum.
        perform f_e_prepara_registro_histev.
      endloop.
    endloop.

    "Verifica se o Evento foi Emitido pela Empresa
    select single chave into v_chaverec
      from zhms_tb_cabeve
      where
          natdc  = v_natdc       and
          typed  = v_typed       and
          chave  = v_chave       and
          tpeve  = wa_evst-tpeve and
          nseqev = wa_evst-nseqev.

    if sy-subrc eq 0.
      "Chave tabela
      wa_evst-natdc = v_natdc.
      wa_evst-typed = v_typed.
      wa_evst-chave = v_chave.

      "Campos de controle
      wa_evst-lote  = v_loted.
      wa_evst-dtalt = sy-datum.
      wa_evst-hralt = sy-uzeit.

      modify zhms_tb_evst from wa_evst.
      if sy-subrc ne 0.
        rollback work.
        v_critc = 'X'.
        " Tratamento de Erro
        clear wa_logunk.
        wa_logunk-erro = 'Erro inesperado ao atualizar status tabela ZHMS_TB_EVST'.
        perform f_erro.
      endif.

      "Chave
      wa_histeve-natdc  =  v_natdc.
      wa_histeve-typed  =  v_typed.
      wa_histeve-event  =  v_event.
      wa_histeve-chave  =  v_chave.
      wa_histeve-tpeve  =  wa_evst-tpeve.
      wa_histeve-nseqev =  wa_evst-nseqev.

      "Controle
      wa_histeve-lote    = v_loted.
      wa_histeve-dataenv = sy-datum.
      wa_histeve-horaenv = sy-uzeit.
      wa_histeve-usuario = 'QUAZARIS'.

      try .
          insert zhms_tb_histev from wa_histeve.
        catch cx_root.
*      IF sy-subrc NE 0.
          rollback work.
          v_critc = 'X'.
          " Tratamento de Erro
          clear wa_logunk.
          wa_logunk-erro = 'Erro inesperado ao atualizar status tabela ZHMS_TB_HISTEV'.
          perform f_erro.
*      ENDIF.
      endtry.

    endif.
  endif.

endform.                    " P_RETORNO_MDE_CONSULTA_NFE
*&---------------------------------------------------------------------*
*&      Form  F_TRATA_DATA_CTE
*&---------------------------------------------------------------------*
form f_trata_data_cte.

  v_datacte = wa_repomneum-value(10).

  replace all occurrences of '-' in v_datacte with ''.
  condense v_datacte no-gaps.

  <fs_field> =  v_datacte.

  if v_datacte is initial and not wa_mapdatac-obrig is initial .
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    concatenate 'Erro: Gravação Cabeçalho do Documento. Mneumônico: '  wa_repomneum-mneum ' têm valor Nulo Sequência: '
    wa_repomneum-seqnr  into wa_logunk-erro.
    perform f_erro.
  endif.

endform.                    "F_TRATA_DATA_CTE
*&---------------------------------------------------------------------*
*&      Form  F_TRATA_CODMAT_CTE
*&---------------------------------------------------------------------*
form f_trata_codmat_cte.

  if wa_repomneum-value is initial.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    concatenate 'Erro: Gravação do Item do Documento. Mneumônico: '  wa_repomneum-mneum ' têm valor Nulo Sequência: '
    wa_repomneum-seqnr  into wa_logunk-erro.
    perform f_erro.
  else.
    <fs_field> = wa_repomneum-value(50).
  endif.

endform.                    "F_TRATA_CODMAT_CTE
*&---------------------------------------------------------------------*
*&      Form  F_E_LOCALIZA_LOCTP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_e_localiza_loctp .

  read table it_mssdata into wa_mssdata
      with key field = 'CONSULTARNFSERPSRESPOSTA/COMPNFSE/NFSE/INFNFSE/PRESTADORSERVICO/ENDERECO/CIDADE'.
  if sy-subrc eq 0.
    v_loctp = wa_mssdata-value.
  endif.

* Verifica se foi encontrado a localidade
  if v_loctp is initial.
    v_critc = 'X'.
*   Tratamento de Erro
    clear wa_logunk.
    wa_logunk-erro = 'Erro: Localidade não Encontrada no XML para NFSE'.
    perform f_erro.
    exit.
  endif.


endform.                    " F_E_LOCALIZA_LOCTP

*&---------------------------------------------------------------------*
*&      Form  F_E_VERIFICATIPONFE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form f_e_verificatiponfe.

  clear: v_importacao,v_subcontratacao,v_subcontratacao2, v_subcontratacao3.
*Verifica se é uma nota de importação
  read table it_mssdata into wa_mssdata with key field = 'NFEPROC/NFE/INFNFE/IDE/IDDEST'.
  if wa_mssdata-value = 3.
    v_importacao = 'X'.
  endif.

*Verifica se é uma nota de subcontratação

  data: v_sub_count   type i.
  loop at it_mssdata into wa_mssdata where field eq 'NFEPROC/NFE/INFNFE/DET/PROD/CFOP'.
*    v_sub_count = v_sub_count + 1.
*
*    IF wa_mssdata-value = '5902' OR wa_mssdata-value = '6902'.
*      IF v_sub_count EQ 1.
*        v_comparacfop = wa_mssdata-value.
*        v_subcontratacao2 = 'X'.
*      ELSE.
*        IF v_comparacfop NE wa_mssdata-value.
*          v_subcontratacao2 = ''.
*          v_subcontratacao = 'X'.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*
*    IF wa_mssdata-value = '5124' OR wa_mssdata-value = '6124'.
*      IF v_sub_count EQ 1.
*        v_comparacfop = wa_mssdata-value.
*        v_subcontratacao3 = 'X'.
*      ELSE.
*        IF v_comparacfop NE wa_mssdata-value.
*          v_subcontratacao3 = ''.
*          v_subcontratacao = 'X'.
*        ENDIF.
*      ENDIF.
*    ENDIF.
    if wa_mssdata-value = '5124' or wa_mssdata-value = '6124'.
      v_subcontratacao = 'X'.
    endif.

  endloop.




*  READ TABLE it_mssdata INTO wa_mssdata WITH KEY field = 'NFEPROC/NFE/INFNFE/DET/PROD/CFOP'.
*  IF wa_mssdata-value = '5902' OR wa_mssdata-value = '6902' OR wa_mssdata-value = '5124' OR wa_mssdata-value = '6124'.
*    v_subcontratacao = 'X'.
*  ENDIF.


endform.                    "F_E_VERIFICATIPONFE

*&---------------------------------------------------------------------*
*&      Form  F_EMAIL_NOVA_NFE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_email_nova_nfe .

  check not v_chave is initial.

*** Verifica se chave existe
  select single *
    from zhms_tb_cabdoc
    into ls_cabdoc
   where chave eq v_chave.

  check sy-subrc is initial.

  refresh: lt_email[].
  clear: lt_email, ls_email,
         lv_ebeln, lv_email,
         lv_cnpj, lv_adrnr,
         lv_nnf.

*** Valida se deve ser enviado o e-mail
  select single *
    from zhms_tb_cf_email
    into wa_cf_email
   where tp_email eq '02'
     and ativo eq 'X'.

  check sy-subrc is initial.

*** verifica cenários aquem deve ter a TAG XPED
  if ls_cabdoc-typed ne 'NFSE'
      and ls_cabdoc-natdc eq '02'
        and ( ls_cabdoc-scena eq '1'
         or ls_cabdoc-scena eq '3' ).

*** verifica TAG XPED e envia e-mail
    select *
      from zhms_tb_docmn
      into table it_docmn
     where chave eq v_chave
       and ( mneum eq 'XPED'
          or mneum eq 'CNPJ'
          or mneum eq 'NNF' ).

    if sy-subrc is initial.
*** separa numero nota fiscal / email e cnpj do fornecedor
      read table  it_docmn into wa_docmn with key mneum = 'NNF'.

      if sy-subrc is initial.

        move wa_docmn-value to lv_nnf.
        condense lv_nnf no-gaps.

        read table  it_docmn into wa_docmn with key mneum = 'CNPJ'.

        if sy-subrc is initial.

          move wa_docmn-value to lv_cnpj.
          condense lv_cnpj no-gaps.

          select single adrnr
            from lfa1
            into lv_adrnr
           where stcd1 eq lv_cnpj.

          if  sy-subrc is initial.
*** Busca Email
            select single smtp_addr
              from adr6
              into lv_email
             where addrnumber eq lv_adrnr.

            condense lv_email no-gaps.

            if not sy-subrc is initial.
              exit.
            endif.
          else.
            exit.
          endif.
        else.
          exit.
        endif.
      else.
        exit.
      endif.
    else.
      exit.
    endif.

    if not lv_cnpj is initial and
    not lv_email is initial and
    not lv_nnf is initial.

      read table  it_docmn into wa_docmn with key mneum = 'XPED'.

      if sy-subrc eq 0.

        read table it_docmn into wa_docmn with key mneum = 'NITEMPED'.
        if sy-subrc ne 0.
          perform f_email_erro.
        endif.
      else.
        perform f_email_erro.
      endif.
    endif.
  endif.

endform.                    " F_EMAIL_NOVA_NFE

*&---------------------------------------------------------------------*
*&      Form  f_email_erro
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form f_email_erro.
  call function 'ZHMS_ENVIA_EMAIL_FORN'
    exporting
      email = lv_email
      nnf   = lv_nnf
      cnpj  = lv_cnpj.

*** busca responsável
  select *
  from zhms_tb_mail
  into table lt_email where natdc eq v_natdc
                       and typed eq v_typed
                       and flowd eq '10'.
  if sy-subrc eq 0.
    loop at lt_email into ls_email.
      if ls_email-ferias = 'X'.
        ls_email-uname = ls_email-userid.
      endif.
      call function 'EFG_GEN_GET_USER_EMAIL'
        exporting
          i_uname           = ls_email-uname
        importing
          e_email_address   = lv_email
        exceptions
          not_qualified     = 1
          user_not_found    = 2
          address_not_found = 3
          others            = 4.
*            lv_email = ls_email-uname.

      call function 'ZHMS_ENVIA_EMAIL_XPED'
        exporting
          email = lv_email
          nnf   = lv_nnf
          cnpj  = lv_cnpj.
    endloop.
  endif.

endform.                    "f_email_erro

*&---------------------------------------------------------------------*
*&      Form  F_EDIT_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form f_edit_status .
  select single *
    from zhms_tb_docst
    into wa_docst
    where chave = v_chave.
  if sy-subrc eq 0.
    wa_docst-sthms = 3.
    wa_docst-strec = 9.
    modify zhms_tb_docst from wa_docst.
    if sy-subrc eq 0.
      commit work.
    endif.
  endif.
endform.                    " F_EDIT_STATUS
*&---------------------------------------------------------------------*
*&      Form  F_SELECIONA_CARACTER
*&---------------------------------------------------------------------*
*       Valida e retira caracter especial
*----------------------------------------------------------------------*
form f_seleciona_caracter .

* Check de chave
  check: not v_natdc is initial,
         not v_typed is initial,
         not v_event is initial,
         not v_versn is initial.

* Seleção de versões
  select *
    into table it_ev_crc
    from zhms_tb_exc_crc
   where natdc eq v_natdc
     and typed eq v_typed
     and event eq v_event
     and versn eq v_versn.

  if not it_ev_crc[] is initial.

    read table it_mssdata into wa_mssdata index 1.
    if sy-subrc = 0.
      read table it_ev_crc into wa_ev_crc with key caract = wa_mssdata-field(3).
      if sy-subrc = 0.
        move: it_mssdata[] to it_mssdata_aux[].
        refresh: it_mssdata.
        clear: wa_mssdata, wa_mssdata_aux.
        loop at it_mssdata_aux into wa_mssdata_aux.
          move-corresponding: wa_mssdata_aux to wa_mssdata.
          wa_mssdata-field =  wa_mssdata_aux-field+3(252).
          append wa_mssdata to it_mssdata.
        endloop.
      endif.
    endif.
  endif.
endform.                    " F_SELECIONA_CARACTER
