*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_REPORTO01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module status_0100 output.
  set pf-status '0100'.

  select single * from zhms_tb_show_lay into ls_show_lay where ativo eq 'X'.

  if ls_show_lay-tipo eq 'NDD'.
    set titlebar  '0101'.
  else.
    set titlebar  '0100'.
  endif.


endmodule.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  MONTA_PORTAL  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module monta_portal output.

  call method cl_gui_cfw=>dispatch.

  if ob_cc_html_index is initial.
***     Criando objeto de container
    create object ob_cc_html_index
      exporting
        container_name = 'CC_HTML_INDEX'
      exceptions
        others         = 1.

    if sy-subrc ne 0.
***       Erro Interno. Contatar Suporte.
*      MESSAGE e000 WITH text-000.
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
*      MESSAGE e000 WITH text-000.
      stop.
    else.
***       Selecionando dados do Índice
      perform f_sel_index_nfs.
****       Registrando Eventos do HTML Index
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
*          MESSAGE e000 WITH text-000.
          stop.
        endif.
      endif.
    endif.
  endif.

endmodule.                 " MONTA_PORTAL  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module status_0200 output.
  set pf-status '0200'.

  case vg_action.
    when '02|NFE|'. " Recepção NF-e

      select single * from zhms_tb_show_lay into ls_show_lay where ativo eq 'X'.

      if ls_show_lay-tipo eq 'NDD'.
        set titlebar  '0201'.
      else.
        set titlebar  '0200'.
      endif.

    when '02|NFSE|'." Recepção NF de serviço

      select single * from zhms_tb_show_lay into ls_show_lay where ativo eq 'X'.

      if ls_show_lay-tipo eq 'NDD'.
        set titlebar  '0401'.
      else.
        set titlebar  '0400'.
      endif.

    when '01|NFS|'. " Emissão NF de serviço

    when '01|NFE|'. " Emissão NF-e

    when '02|CTE|'.
      select single * from zhms_tb_show_lay into ls_show_lay where ativo eq 'X'.

      if ls_show_lay-tipo eq 'NDD'.
        set titlebar  '0501'.
      else.
        set titlebar  '0500'.
      endif.
    when others.

  endcase.

endmodule.                 " STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  DETRMINE_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module detrmine_screen output.

  clear vg_screen.
  vg_action = '02|NFE|'.
  case vg_action.
    when '02|NFE|'. " Recepção NF-e
      move '0201' to vg_screen.
    when '02|NFSE|'." Recepção NF de serviço
      move '0400' to vg_screen.
    when '01|NFS|'. " Emissão NF de serviço

    when '01|NFE|'. " Emissão NF-e

    when '02|CTE|'.
      move '0201' to vg_screen.
    when others.
      move '0201' to vg_screen.
*MOVE '0300' TO vg_screen.
  endcase.

  if vg_screen is initial.
*MOVE '0300' TO vg_screen.
    move '0201' to vg_screen.
  endif.

  if vg_screen2 is initial.
    move '0300' to vg_screen2.
  endif.

endmodule.                 " DETRMINE_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0202  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module status_0202 output.
  data: event_receiver type ref to lcl_hotspot_click.

  refresh t_hvalid_fldc[].

  clear wa_hvalid_fldc.
  wa_hvalid_fldc-fieldname = 'ICONE'.
  wa_hvalid_fldc-reptext   = 'Status'.
  wa_hvalid_fldc-col_opt   = 'X'.
  append wa_hvalid_fldc to t_hvalid_fldc.
  clear wa_hvalid_fldc.

  wa_hvalid_fldc-fieldname = 'TIPO'.
  wa_hvalid_fldc-reptext   = 'Tipo'.
  wa_hvalid_fldc-col_opt   = 'X'.
  append wa_hvalid_fldc to t_hvalid_fldc.
  clear wa_hvalid_fldc.

  wa_hvalid_fldc-fieldname = 'DENOM'.
  wa_hvalid_fldc-reptext   = 'Descrição'.
  wa_hvalid_fldc-col_opt   = 'X'.
  append wa_hvalid_fldc to t_hvalid_fldc.
  clear wa_hvalid_fldc.

  wa_hvalid_fldc-fieldname = 'DOCNR'.
  wa_hvalid_fldc-reptext   = 'Nº Documento'.
  wa_hvalid_fldc-col_opt   = 'X'.
  append wa_hvalid_fldc to t_hvalid_fldc.
  clear wa_hvalid_fldc.

  wa_hvalid_fldc-fieldname = 'PARID'.
  wa_hvalid_fldc-reptext   = 'Nº Fornecedor'.
  wa_hvalid_fldc-col_opt   = 'X'.
  append wa_hvalid_fldc to t_hvalid_fldc.
  clear wa_hvalid_fldc.

*Renan Itokazo
*15.01.2019
  wa_hvalid_fldc-fieldname = 'NAME1'.
  wa_hvalid_fldc-reptext   = 'Fornecedor'.
  wa_hvalid_fldc-col_opt   = 'X'.
  append wa_hvalid_fldc to t_hvalid_fldc.
  clear wa_hvalid_fldc.

  wa_hvalid_fldc-fieldname = 'FLOWD_AT'.
  wa_hvalid_fldc-reptext   = 'Etapa Atual'.
  wa_hvalid_fldc-col_opt   = 'X'.
  append wa_hvalid_fldc to t_hvalid_fldc.
  clear wa_hvalid_fldc.

  wa_hvalid_fldc-fieldname = 'DATA'.
  wa_hvalid_fldc-reptext   = 'Data ultima Modf.'.
  wa_hvalid_fldc-col_opt   = 'X'.
  append wa_hvalid_fldc to t_hvalid_fldc.
  clear wa_hvalid_fldc.

  wa_hvalid_fldc-fieldname = 'FLOWD_FN'.
  wa_hvalid_fldc-reptext   = 'Prox. Etapa'.
  wa_hvalid_fldc-col_opt   = 'X'.
  append wa_hvalid_fldc to t_hvalid_fldc.
  clear wa_hvalid_fldc.

  wa_hvalid_fldc-fieldname = 'MANUAL'.
  wa_hvalid_fldc-reptext   = 'Manual'.
  wa_hvalid_fldc-col_opt   = 'X'.
  append wa_hvalid_fldc to t_hvalid_fldc.
  clear wa_hvalid_fldc.

  wa_hvalid_fldc-fieldname = 'FORA'.
  wa_hvalid_fldc-reptext   = 'Proces. Fora HOMSOFT'.
  wa_hvalid_fldc-col_opt   = 'X'.
  append wa_hvalid_fldc to t_hvalid_fldc.
  clear wa_hvalid_fldc.

  wa_hvalid_fldc-fieldname = 'MIGO'.
  wa_hvalid_fldc-reptext   = 'Entrada Fisica - MIGO'.
  wa_hvalid_fldc-col_opt   = 'X'.
  wa_hvalid_fldc-hotspot   = 'X'.
  append wa_hvalid_fldc to t_hvalid_fldc.
  clear wa_hvalid_fldc.

  wa_hvalid_fldc-fieldname = 'MIRO'.
  wa_hvalid_fldc-reptext   = 'Entrada Fiscal - MIRO'.
  wa_hvalid_fldc-col_opt   = 'X'.
  wa_hvalid_fldc-hotspot   = 'X'.
  append wa_hvalid_fldc to t_hvalid_fldc.
  clear wa_hvalid_fldc.

  wa_hvalid_fldc-fieldname = 'ML81N'.
  wa_hvalid_fldc-reptext   = 'Entrada Serviço ML81N'.
  wa_hvalid_fldc-col_opt   = 'X'.
  wa_hvalid_fldc-hotspot   = 'X'.
  append wa_hvalid_fldc to t_hvalid_fldc.
  clear wa_hvalid_fldc.

  wa_hvalid_fldc-fieldname = 'TEXTO_ERRO'.
  wa_hvalid_fldc-reptext   = 'Log de Erro'.
  wa_hvalid_fldc-col_opt   = 'X'.
  append wa_hvalid_fldc to t_hvalid_fldc.
  clear wa_hvalid_fldc.

* create sort-table
  clear: wa_sort.
  wa_sort-spos = 1.
  wa_sort-fieldname = 'DOCNR'.
  wa_sort-up = 'X'.
  append wa_sort to t_sort.

  clear: wa_sort.
  wa_sort-spos = 2.
  wa_sort-fieldname = 'MIGO'.
  wa_sort-up = 'X'.
  append wa_sort to t_sort.

  clear: wa_sort.
  wa_sort-spos = 3.
  wa_sort-fieldname = 'MIRO'.
  wa_sort-up = 'X'.
  append wa_sort to t_sort.

  clear: wa_sort.
  wa_sort-spos = 4.
  wa_sort-fieldname = 'ML81N'.
  wa_sort-up = 'X'.
  append wa_sort to t_sort.

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
      it_outtab                     = t_status01[]
      it_fieldcatalog               = t_hvalid_fldc[]
      it_sort                       = t_sort
    exceptions
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      others                        = 4.

  create object event_receiver.
  set handler event_receiver->handle_hotspot_click for ob_cc_grid.

endmodule.                 " STATUS_0202  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0400  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module status_0400 output.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR '0400'.

endmodule.                 " STATUS_0400  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0203  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module status_0203 output.

  refresh t_hvalid_fldc[].

  clear wa_hvalid_fldc.
  wa_hvalid_fldc-fieldname = 'NATDC'.
  wa_hvalid_fldc-reptext   = 'Natureza Doc.'.
  wa_hvalid_fldc-col_opt   = 'X'.
  append wa_hvalid_fldc to t_hvalid_fldc.
  clear wa_hvalid_fldc.

  wa_hvalid_fldc-fieldname = 'TYPED'.
  wa_hvalid_fldc-reptext   = 'Tip. Documento'.
  wa_hvalid_fldc-col_opt   = 'X'.
  append wa_hvalid_fldc to t_hvalid_fldc.
  clear wa_hvalid_fldc.

  wa_hvalid_fldc-fieldname = 'DOCNR'.
  wa_hvalid_fldc-reptext   = 'N° Documento'.
  wa_hvalid_fldc-col_opt   = 'X'.
  append wa_hvalid_fldc to t_hvalid_fldc.
  clear wa_hvalid_fldc.

  wa_hvalid_fldc-fieldname = 'ATITM'.
  wa_hvalid_fldc-reptext   = 'Item'.
  wa_hvalid_fldc-col_opt   = 'X'.
  append wa_hvalid_fldc to t_hvalid_fldc.
  clear wa_hvalid_fldc.

  wa_hvalid_fldc-fieldname = 'DTREG'.
  wa_hvalid_fldc-reptext   = 'Data Registro'.
  wa_hvalid_fldc-col_opt   = 'X'.
  append wa_hvalid_fldc to t_hvalid_fldc.
  clear wa_hvalid_fldc.

  wa_hvalid_fldc-fieldname = 'HRREG'.
  wa_hvalid_fldc-reptext   = 'Hora do registro'.
  wa_hvalid_fldc-col_opt   = 'X'.
  append wa_hvalid_fldc to t_hvalid_fldc.
  clear wa_hvalid_fldc.


  wa_hvalid_fldc-fieldname = 'VLDV2'.
  wa_hvalid_fldc-reptext   = 'Descrição'.
  wa_hvalid_fldc-col_opt   = 'X'.
  append wa_hvalid_fldc to t_hvalid_fldc.
  clear wa_hvalid_fldc.

  if ob_cc_vld_item is not initial.
    call method ob_cc_vld_item->free.
  endif.

  create object ob_cc_vld_item
    exporting
      container_name = 'CC_REPORT_VLD001'.

  create object ob_cc_grid
    exporting
      i_parent = ob_cc_vld_item.

  call method ob_cc_grid->set_table_for_first_display
    changing
      it_outtab                     = lt_vld_out[]
      it_fieldcatalog               = t_hvalid_fldc[]
    exceptions
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      others                        = 4.


endmodule.                 " STATUS_0203  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0204  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module status_0204 output.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.

  refresh t_hvalid_fldc[].

  clear wa_hvalid_fldc.
  wa_hvalid_fldc-fieldname = 'NATDC'.
  wa_hvalid_fldc-reptext   = 'Natureza Doc.'.
  wa_hvalid_fldc-col_opt   = 'X'.
  append wa_hvalid_fldc to t_hvalid_fldc.
  clear wa_hvalid_fldc.

  wa_hvalid_fldc-fieldname = 'TYPED'.
  wa_hvalid_fldc-reptext   = 'Tip. Documento'.
  wa_hvalid_fldc-col_opt   = 'X'.
  append wa_hvalid_fldc to t_hvalid_fldc.
  clear wa_hvalid_fldc.

  wa_hvalid_fldc-fieldname = 'DOCNR'.
  wa_hvalid_fldc-reptext   = 'N° Documento'.
  wa_hvalid_fldc-col_opt   = 'X'.
  append wa_hvalid_fldc to t_hvalid_fldc.
  clear wa_hvalid_fldc.

  wa_hvalid_fldc-fieldname = 'ATITM'.
  wa_hvalid_fldc-reptext   = 'Item'.
  wa_hvalid_fldc-col_opt   = 'X'.
  append wa_hvalid_fldc to t_hvalid_fldc.
  clear wa_hvalid_fldc.

  wa_hvalid_fldc-fieldname = 'DTREG'.
  wa_hvalid_fldc-reptext   = 'Data Registro'.
  wa_hvalid_fldc-col_opt   = 'X'.
  append wa_hvalid_fldc to t_hvalid_fldc.
  clear wa_hvalid_fldc.

  wa_hvalid_fldc-fieldname = 'HRREG'.
  wa_hvalid_fldc-reptext   = 'Hora do registro'.
  wa_hvalid_fldc-col_opt   = 'X'.
  append wa_hvalid_fldc to t_hvalid_fldc.
  clear wa_hvalid_fldc.


  wa_hvalid_fldc-fieldname = 'VLDV2'.
  wa_hvalid_fldc-reptext   = 'Descrição'.
  wa_hvalid_fldc-col_opt   = 'X'.
  append wa_hvalid_fldc to t_hvalid_fldc.
  clear wa_hvalid_fldc.

  if ob_cc_vld_item is not initial.
    call method ob_cc_vld_item->free.
  endif.

  create object ob_cc_vld_item
    exporting
      container_name = 'CC_REPORT_HIST'.

  create object ob_cc_grid
    exporting
      i_parent = ob_cc_vld_item.

  call method ob_cc_grid->set_table_for_first_display
    changing
      it_outtab                     = lt_vld_out[]
      it_fieldcatalog               = t_hvalid_fldc[]
    exceptions
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      others                        = 4.

endmodule.                 " STATUS_0204  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0205  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module status_0205 output.

  data: l_ixml_data_doc   type ref to if_ixml_document,
        l_ixml_custom_doc type ref to if_ixml_document,
        l_ostream         type ref to if_ixml_ostream,
        l_xstr            type xstring.

  data: l_ixml_data_doc_vld   type ref to if_ixml_document,
        l_ixml_custom_doc_vld type ref to if_ixml_document,
        l_ostream_vld         type ref to if_ixml_ostream,
        l_xstr_vld            type xstring.

  data: l_ixml_data_doc_erro   type ref to if_ixml_document,
        l_ixml_custom_doc_erro type ref to if_ixml_document,
        l_ostream_erro         type ref to if_ixml_ostream,
        l_xstr_erro            type xstring.

** Get Data to be displayed on the Chart
  if t_cabdoc[] is initial.
    refresh t_cabdoc[].
    select * from zhms_tb_cabdoc into table t_cabdoc.
  endif.
  if g_graph_container is not initial.
    clear g_graph_container.
  endif.
* create global objects
  g_ixml = cl_ixml=>create( ).
  g_ixml_sf = g_ixml->create_stream_factory( ).

*  SET PF-STATUS '100'.
* For initial display of graph data.
  if g_graph_container is initial.
* Create the object for container.
    create object g_graph_container
      exporting
        container_name = 'GRAPH_CONTAINER'.
* Bind the container to the object.
    create object g_ce_viewer
      exporting
        parent = g_graph_container.
* Create XML data using data in internal table.
    perform create_xml_data using l_ixml_data_doc.
    l_ostream = g_ixml_sf->create_ostream_xstring( l_xstr ).
* Render Chart Data
    call method l_ixml_data_doc->render
      exporting
        ostream = l_ostream.
    g_ce_viewer->set_data( xdata = l_xstr ).
    clear l_xstr.
* Create the customizing data for the chart
    perform create_customizing_data using l_ixml_custom_doc.
    l_ostream = g_ixml_sf->create_ostream_xstring( l_xstr ).
* Render Customizing Data
    call method l_ixml_custom_doc->render
      exporting
        ostream = l_ostream.
    g_ce_viewer->set_customizing( xdata = l_xstr ).

********************** RELATÓRIO DE QTD ERROS **********************************
    if g_graph_container_vld is not initial.
      clear g_graph_container_vld.
    endif.
* create global objects
    g_ixml_vld = cl_ixml=>create( ).
    g_ixml_sf_vld = g_ixml_vld->create_stream_factory( ).

*  SET PF-STATUS '100'.
* For initial display of graph data.
    if g_graph_container_vld is initial.
* Create the object for container.
      create object g_graph_container_vld
        exporting
          container_name = 'GRAPH_CONTAINER_VLD'.
* Bind the container to the object.
      create object g_ce_viewer_vld
        exporting
          parent = g_graph_container_vld.
* Create XML data using data in internal table.
      perform create_xml_data_vld using l_ixml_data_doc_vld.
      l_ostream_vld = g_ixml_sf_vld->create_ostream_xstring( l_xstr_vld ).
* Render Chart Data
      call method l_ixml_data_doc_vld->render
        exporting
          ostream = l_ostream_vld.
      g_ce_viewer_vld->set_data( xdata = l_xstr_vld ).
      clear l_xstr_vld.
* Create the customizing data for the chart
      perform create_customizing_data_vld using l_ixml_custom_doc_vld.
      l_ostream_vld = g_ixml_sf_vld->create_ostream_xstring( l_xstr_vld ).
* Render Customizing Data
      call method l_ixml_custom_doc_vld->render
        exporting
          ostream = l_ostream_vld.
      g_ce_viewer_vld->set_customizing( xdata = l_xstr_vld ).


    endif.

********************** RELATÓRIO POR ERROS **********************************

    if g_graph_container_erro is not initial.
      clear g_graph_container_erro.
    endif.
* create global objects
    g_ixml_erro = cl_ixml=>create( ).
    g_ixml_sf_erro = g_ixml_erro->create_stream_factory( ).

*  SET PF-STATUS '100'.
* For initial display of graph data.
    if g_graph_container_erro is initial.
* Create the object for container.
      create object g_graph_container_erro
        exporting
          container_name = 'GRAPH_CONTAINER_ERRO'.
* Bind the container to the object.
      create object g_ce_viewer_erro
        exporting
          parent = g_graph_container_erro.
* Create XML data using data in internal table.
      perform create_xml_data_erro using l_ixml_data_doc_erro.
      l_ostream_erro = g_ixml_sf_erro->create_ostream_xstring( l_xstr_erro ).
* Render Chart Data
      call method l_ixml_data_doc_erro->render
        exporting
          ostream = l_ostream_erro.
      g_ce_viewer_erro->set_data( xdata = l_xstr_erro ).
      clear l_xstr_erro.
* Create the customizing data for the chart
      perform create_customizing_data_erro using l_ixml_custom_doc_erro.
      l_ostream_erro = g_ixml_sf_erro->create_ostream_xstring( l_xstr_erro ).
* Render Customizing Data
      call method l_ixml_custom_doc_erro->render
        exporting
          ostream = l_ostream_erro.
      g_ce_viewer_erro->set_customizing( xdata = l_xstr_erro ).

    endif.

*RCP - 01/08/2018 - Início
    perform zf_gerar_novo_grafico.
*RCP - 01/08/2018 - Fim

  endif.
* Render the Graph Object.
  call method g_ce_viewer->render.
  call method g_ce_viewer_vld->render.
  call method g_ce_viewer_erro->render.

endmodule.                 " STATUS_0205  OUTPUT
