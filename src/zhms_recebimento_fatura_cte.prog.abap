*&---------------------------------------------------------------------*
*& Report ZHMS_RECEBIMENTO_FATURA_CTE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zhms_recebimento_fatura_cte.

*** Variáveis
DATA: v_title      TYPE string,              "Título da Janela
      v_folder     TYPE string,              "Diretório selecionado
      v_lin        TYPE i,                   "Contador de registro
      vg_filecount TYPE i,
      vg_dircount  TYPE i,
      it_filetab   TYPE TABLE OF sdokpath,
      it_dirtable  TYPE TABLE OF sdokpath.

DATA: vfilename            TYPE localfile,
      lvfilename           TYPE string,
      gv_subrc             TYPE sy-subrc,
      gv_xml_string        TYPE xstring,
      gv_xml_xstring       TYPE xstring,
      gv_size              TYPE sytabix,
      gv_string            TYPE string,
      gv_string_total      TYPE string,
      gt_xml_data          TYPE TABLE OF smum_xmltb,
      gt_xml_data_aux      TYPE TABLE OF smum_xmltb,
      lt_msgdata           TYPE STANDARD TABLE OF zhms_es_msgdt,
      lt_msgatrb           TYPE STANDARD TABLE OF zhms_es_msgat,
      w_msgatrb            TYPE zhms_es_msgat,
      w_msgdata            TYPE zhms_es_msgdt,
      vhier                TYPE int1,
      lt_return            TYPE STANDARD TABLE OF zhms_es_return,
      wa_return            TYPE zhms_es_return,
      gt_xml_cte           TYPE TABLE OF smum_xmltb,
      gt_xml_fat           TYPE TABLE OF smum_xmltb,
      st_xml_xstring_total TYPE xstring,
      gt_xml_data_total    TYPE TABLE OF smum_xmltb,
      gwa_xml_data         TYPE smum_xmltb,
      gwa_xml_data_aux     TYPE smum_xmltb,
      gt_return            TYPE TABLE OF bapiret2,
      lt_doc_bin           TYPE TABLE OF sdokcntbin,
      gt_ret_biztalk       TYPE TABLE OF zhms_es_return,
      it_tb_fatura         TYPE STANDARD TABLE OF zhms_tb_fatura,
      wa_tb_fatura         TYPE zhms_tb_fatura,
      v_exnat              TYPE zhms_de_exnat,
      v_extpdc             TYPE zhms_de_extpd,
      v_extpdf             TYPE zhms_de_extpd,
      v_mensg              TYPE zhms_de_mensg,
      v_exevt              TYPE zhms_de_exevt,
      v_direc              TYPE zhms_de_direc,
      v_chave              TYPE zhms_de_chave,
      v_texto              TYPE zhms_de_texto,
      v_limpa              TYPE char01,
      v_critc              TYPE flag.

DATA  gcl_xml       TYPE REF TO cl_xml_document.

**Constantes

CONSTANTS: gc_exnat   TYPE zhms_de_exnat VALUE '02',
           gc_extpdc  TYPE zhms_de_extpd VALUE '57',
           gc_extpdf  TYPE zhms_de_extpd VALUE '60',
           gc_mensg   TYPE  zhms_de_mensg VALUE 'NEO',
           gc_exevt   TYPE  zhms_de_exevt VALUE '1003',
           gc_direc   TYPE  zhms_de_direc VALUE 'E',
           gc_cteproc TYPE  char07        VALUE 'cteProc'.

TYPES: BEGIN OF ty_lfa1,
         lifnr      TYPE lfa1-lifnr,  "cod.fornecedor SAP
         stcd1      TYPE lfa1-stcd1, "CNPJ fornecedor
         stcd3      TYPE lfa1-stcd3, "Inscrição Estadual
         stcd4      TYPE lfa1-stcd4, "Insc.Municipal
         name1      TYPE adrc-name1, "Nome do fornecedor
         street     TYPE adrc-street, "Logradouro
         house_num1 TYPE adrc-house_num1, "Numero
         house_num2 TYPE adrc-house_num2, "Complemento
         city2      TYPE adrc-city2, " Bairro
         post_code1 TYPE adrc-post_code1, "CEP
         city1      TYPE adrc-city1, "Cidade
         region     TYPE adrc-region, "Estado,
       END OF ty_lfa1.

TYPES: BEGIN OF ty_outtab,
         pathname TYPE sdokpath,
         check    TYPE xfeld,
       END OF ty_outtab.

TYPES: BEGIN OF ty_cabdoc,
         chave TYPE zhms_de_chave,
         typed TYPE zhms_de_typed,
       END OF  ty_cabdoc.

TYPES: BEGIN OF ty_chave,
         chave TYPE char44,
         lote  TYPE zhms_de_lote,
         cct   TYPE char10,
         nct   TYPE char10,
         ndoc  TYPE char10,
         demi  TYPE char10,
       END OF ty_chave,

       BEGIN OF ty_controle,
         seqnc TYPE i,
         hier  TYPE int1,
         field TYPE c LENGTH 255,
         value TYPE c LENGTH 255,
       END OF ty_controle.

DATA: it_outtab      TYPE TABLE OF ty_outtab,
      wa_outtab      TYPE ty_outtab,
      w_lfa1         TYPE ty_lfa1,
      it_chave       TYPE STANDARD TABLE OF ty_chave,
      wa_chave       TYPE ty_chave,
      wa_xml_data    TYPE smum_xmltb,
      lv_xml_str     TYPE string,
      lv_xml_xstr    TYPE xstring,
      c_chave        TYPE char44,
      t_controle     TYPE TABLE OF ty_controle,
      w_controle     TYPE ty_controle,
      w_controle_aux TYPE ty_controle.

FIELD-SYMBOLS: <outtab>      TYPE ty_outtab,
               <fs_controle> TYPE ty_controle,
               <fs_return>   TYPE zhms_es_return.
*** ALV
DATA: gr_table TYPE REF TO cl_salv_table.
***   CLASS lcl_event_handler DEFINITION
CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.

    METHODS: on_link_click FOR EVENT link_click
                  OF cl_salv_events_table
      IMPORTING row column.
ENDCLASS.
***     CLASS lcl_event_handler  IMPLEMENTATION
CLASS lcl_event_handler IMPLEMENTATION.

  METHOD on_link_click.
    FIELD-SYMBOLS: <ls_outtab> TYPE ty_outtab.
    READ TABLE it_outtab ASSIGNING <ls_outtab> INDEX row.
    IF sy-subrc IS INITIAL.
      IF <ls_outtab>-check IS INITIAL.
        <ls_outtab>-check = 'X'.
      ELSE.
        CLEAR <ls_outtab>-check.
      ENDIF.
    ENDIF.
    gr_table->refresh( ).
  ENDMETHOD.
ENDCLASS.
*** Tela de Seleção
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-b01.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-b02.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 4(16) TEXT-001. "Nr.ID Fiscal 1
PARAMETERS: p_stcd1 TYPE stcd1 OBLIGATORY.
SELECTION-SCREEN COMMENT 40(40) v_name1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 4(16) TEXT-002. "Nr.Fatura
PARAMETERS: p_fatura TYPE ztknum OBLIGATORY.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 4(16) TEXT-007. "Data da Emissão
PARAMETERS: p_dtemi TYPE sy-datum OBLIGATORY.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-b03.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 4(16) TEXT-003. "R$ Vl.Líquido
PARAMETERS p_vliq TYPE j_1bnfnet OBLIGATORY.
SELECTION-SCREEN COMMENT 50(16) TEXT-004. "R$ Vl.Bruto
PARAMETERS p_vbruto TYPE j_1blppbrt OBLIGATORY.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 4(16) TEXT-005. "Vencimento
PARAMETERS p_vecto TYPE sy-datum OBLIGATORY.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b3.
*Carga de arquivos CTE's
SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE TEXT-b04.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 4(20) TEXT-006. "Caminho do Diretório
PARAMETERS p_dir TYPE file_table-filename OBLIGATORY.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b4.

SELECTION-SCREEN END OF BLOCK b1.
*** AT-SELECTION-SCREEN

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_dir.
  PERFORM f_busca_arquivo CHANGING p_dir.

AT SELECTION-SCREEN ON p_stcd1.
  PERFORM f_consiste_stcd1.

* processamento
START-OF-SELECTION.
  CONDENSE p_fatura.
  PACK p_fatura TO p_fatura.
* seleciona dados do fornecedor
  PERFORM f_get_fornecedor.
* busca arquivos e pastas do diretório informado
  PERFORM f_get_files.
  it_outtab[] = it_filetab[].
  LOOP AT it_outtab INTO wa_outtab.
    wa_outtab-check = 'X'.
    MODIFY it_outtab FROM wa_outtab INDEX sy-tabix.
  ENDLOOP.
  PERFORM f_display_data.

* Consiste seleção de arquivos
  DELETE it_outtab WHERE check IS INITIAL.
  IF it_outtab[] IS INITIAL.
    MESSAGE TEXT-e01 TYPE 'I' DISPLAY LIKE 'E'. "Nenhum arquivo selecionado
    LEAVE LIST-PROCESSING.
  ENDIF.

* Monta string de Fatura.
  PERFORM f_monta_string_fatura.
*busca arquivos xlm cte's e monta um arquivo xml com a fatura
*e todos os CTE's.
  LOOP AT it_outtab ASSIGNING <outtab>.
    PERFORM f_busca_xml.
  ENDLOOP.
  CONCATENATE gv_string_total '</Conhecimentos>' '</FaturaTransportadora>' INTO gv_string_total.

  PERFORM f_gravar_xml_total.

  IF NOT st_xml_xstring_total IS INITIAL.

*    PERFORM f_trata_xml TABLES gt_ret_biztalk  " Retorno
*                               USING st_xml_xstring_total   " XML
*                                     gc_exnat         " Natureza do Documento
*                                     gc_extpdc        " Tipo de Doc. CT-e
*                                     gc_extpdf        " Tipo de Doc. Fatura
*                                     gc_mensg        " Mensageria - Default NEO
*                                     gc_exevt        " Evento     - Default 1003
*                                     gc_direc.       " Direção    - Default E (Entrada)
*
*    MESSAGE TEXT-015 TYPE 'I'. " RFC ZHMS_FM_QUAZARIS_FAT_BIZTALK foi executada, ver log seguinte
*      LOOP AT gt_ret_biztalk ASSIGNING <fs_return>.
*        WRITE / <fs_return>-retnr. WRITE <fs_return>-descr.
*      ENDLOOP.
*
*      ELSE.
*         MESSAGE TEXT-016 TYPE 'I'. " Arquivo não encontrato ou com problemas de leitura.
*        LEAVE LIST-PROCESSING.

*** Simula Chamada Via Biztalk
    CALL FUNCTION 'ZHMS_FM_QUAZARIS_FAT_BIZTALK'
      EXPORTING
        exnat        = gc_exnat           " Natureza do Documento
        extpd        = gc_extpdf          " Tipo de Doc. Fatura
        mensg        = gc_mensg          " Mensageria - Default NEO
        exevt        = gc_exevt          " Evento     - Default 1003
        direc        = gc_direc          " Direção    - Default E (Entrada)
        xmlstringbin = st_xml_xstring_total     " XML
      TABLES
        return       = gt_ret_biztalk.   " Retorno
  ELSE.
    MESSAGE TEXT-016 TYPE 'I'. " Arquivo não encontrato ou com problemas de leitura.
    LEAVE LIST-PROCESSING.
  ENDIF.
  IF gt_ret_biztalk IS INITIAL.
    MESSAGE TEXT-023 TYPE 'I'. " RFC ZHMS_FM_QUAZARIS_FAT_BIZTALK foi executada.
    LEAVE LIST-PROCESSING.
  ELSE.
    MESSAGE TEXT-015 TYPE 'I'. " RFC ZHMS_FM_QUAZARIS_FAT_BIZTALK foi executada, ver log seguinte
    LOOP AT gt_ret_biztalk ASSIGNING <fs_return>.
      WRITE / <fs_return>-retnr. WRITE <fs_return>-descr.
    ENDLOOP.
  ENDIF.

*
*  SUBMIT ZHMS_CARGA_FATURA
*     WITH p_entr EQ lvfilename.
**      EXPORTING LIST TO MEMORY AND RETURN.

END-OF-SELECTION.


*&---------------------------------------------------------------------*
*&      Form  F_BUSCA_ARQUIVO
*&---------------------------------------------------------------------*
FORM f_busca_arquivo  CHANGING p_file  TYPE file_table-filename.
  CLEAR: v_title, v_folder.

* Monta título da Janela:
* Msg: Selecione o diretório desejado e Clique no botão [OK]
  MOVE TEXT-010 TO v_title.

* Chamada da janela para busca de diretório
  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title         = v_title
      initial_folder       = 'C:/'
    CHANGING
      selected_folder      = v_folder
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.

* Se não executou abertura com sucesso
  IF sy-subrc NE 0.

*   Msg: Erro na busca do diretório.
    MESSAGE i836(sd) WITH TEXT-011.

* Retornando o diretório ao campo da tela de seleção
  ELSE.
    MOVE v_folder TO p_file.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_GET_FILES
*&---------------------------------------------------------------------*
FORM f_get_files .

  CALL FUNCTION 'TMP_GUI_DIRECTORY_LIST_FILES'
    EXPORTING
      directory  = p_dir  " Diretório
      filter     = '*.xml'  " Tipo de arquivo
    IMPORTING
      file_count = vg_filecount
      dir_count  = vg_dircount
    TABLES
      file_table = it_filetab  " Tabelas com os arquivos
      dir_table  = it_dirtable " Tabela com as pastas
    EXCEPTIONS
      cntl_error = 1
      OTHERS     = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_DATA
*&---------------------------------------------------------------------*
FORM f_display_data .
  DATA: o_table      TYPE REF TO cl_salv_table,
        o_layout     TYPE REF TO cl_salv_layout,
        o_columns    TYPE REF TO cl_salv_columns_table,
        o_column     TYPE REF TO cl_salv_column,
        o_functions  TYPE REF TO cl_salv_functions,
        o_display    TYPE REF TO cl_salv_display_settings,
        o_events     TYPE REF TO cl_salv_events_table,
        o_selections TYPE REF TO cl_salv_selections.


  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = gr_table
                               CHANGING t_table = it_outtab ).
    CATCH cx_salv_msg.
  ENDTRY.

* Tool-bar standard
  o_functions = gr_table->get_functions( ).
  o_functions->set_all( abap_true ).

* select all
  o_selections = gr_table->get_selections( ).
  o_selections->set_selection_mode( if_salv_c_selection_mode=>row_column ).

* Inserir cabeçalho.
  o_display = gr_table->get_display_settings( ).
  o_display->set_list_header( TEXT-013 ). "Selecionar Arquivo de Fatura e CTE's

* Otimiza colunas.
  o_columns = gr_table->get_columns( ).
  o_columns->set_optimize( 'X' ).

*define a coluna
  o_columns = gr_table->get_columns( ).

  DATA: lo_column TYPE REF TO cl_salv_column_list.
  TRY.
      lo_column ?= o_columns->get_column( 'CHECK' ).
      lo_column->set_cell_type( if_salv_c_cell_type=>checkbox_hotspot ).
      lo_column->set_long_text( 'CHECKBOX' ).
      lo_column->set_output_length( 10 ).

    CATCH cx_salv_not_found.
  ENDTRY.

*** CHECKBOX Logic start
  DATA: lo_events TYPE REF TO cl_salv_events_table.
  lo_events = gr_table->get_event( ).
  DATA:  lo_event_handler TYPE REF TO lcl_event_handler.

  CREATE OBJECT lo_event_handler.
  SET HANDLER lo_event_handler->on_link_click FOR lo_events.

  gr_table->display( ).

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_BUSCA_XML
*&---------------------------------------------------------------------*
FORM f_busca_xml .

  CREATE OBJECT gcl_xml.
  CONCATENATE p_dir '\' <outtab>-pathname INTO vfilename.

** Tentar outro método de upload para que o pop up de segurança não apareça.
*** Upload XML File
  CALL METHOD gcl_xml->import_from_file
    EXPORTING
      filename = vfilename
    RECEIVING
      retcode  = gv_subrc.


  IF gv_subrc = 0.
    CLEAR gv_xml_xstring.
    CALL METHOD gcl_xml->render_2_xstring
      IMPORTING
        retcode = gv_subrc
        stream  = gv_xml_xstring
        size    = gv_size.

    IF gv_subrc = 0.

* convert xstring em string
      DATA s_cont        TYPE string.
      DATA lref_convt    TYPE REF TO cl_abap_conv_in_ce.
      DATA lv_string     TYPE string.


      lref_convt = cl_abap_conv_in_ce=>create( input = st_xml_xstring_total ).
      lref_convt->read( IMPORTING data = s_cont ).
      lref_convt->convert( EXPORTING input = gv_xml_xstring IMPORTING data  = gv_string ).

      REPLACE ALL OCCURRENCES OF '<' IN
        gv_string WITH '&lt;'
              REPLACEMENT COUNT  DATA(cnt)
              REPLACEMENT OFFSET DATA(off)
              REPLACEMENT LENGTH DATA(len).

      REPLACE ALL OCCURRENCES OF '>' IN
        gv_string WITH '&gt;'.

      CONCATENATE '<XML>' gv_string '</XML>' INTO gv_string.

      CONCATENATE gv_string_total gv_string INTO gv_string_total.
    ELSE.
      MESSAGE TEXT-e03 TYPE 'I'. " Arquivo não encontrato ou com problemas de leitura.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_GRAVAR_XML_TOTAL
*&---------------------------------------------------------------------*
FORM f_gravar_xml_total .

*  DATA: lt_doc_bin    TYPE TABLE OF sdokcntbin.
  DATA: output_length TYPE i.
*  DATA: lvfilename TYPE string.


  CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
    EXPORTING
      text   = gv_string_total
    IMPORTING
      buffer = st_xml_xstring_total
    EXCEPTIONS
      failed = 1
      OTHERS = 2.
*          .
*IF sy-subrc <> 0.
** Implement suitable error handling here
*ENDIF.


  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer        = st_xml_xstring_total
    IMPORTING
      output_length = output_length
    TABLES
      binary_tab    = lt_doc_bin.


*  CONCATENATE p_dir '\' 'FATURA' p_fatura '.xml' INTO lvfilename.
*
*  CALL METHOD cl_gui_frontend_services=>gui_download
*    EXPORTING
*      bin_filesize            = output_length
*      filename                = lvfilename
*      filetype                = 'BIN'
*    CHANGING
*      data_tab                = lt_doc_bin
*    EXCEPTIONS
*      file_write_error        = 1
*      no_batch                = 2
*      gui_refuse_filetransfer = 3
*      invalid_type            = 4
*      no_authority            = 5
*      unknown_error           = 6
*      header_not_allowed      = 7
*      separator_not_allowed   = 8
*      filesize_not_allowed    = 9
*      header_too_long         = 10
*      dp_error_create         = 11
*      dp_error_send           = 12
*      dp_error_write          = 13
*      unknown_dp_error        = 14
*      access_denied           = 15
*      dp_out_of_memory        = 16
*      disk_full               = 17
*      dp_timeout              = 18
*      file_not_found          = 19
*      dataprovider_exception  = 20
*      control_flush_error     = 21
*      not_supported_by_gui    = 22
*      error_no_gui            = 23
*      OTHERS                  = 24.
*
*  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
*         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    EXIT.
*  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_MONTA_STRING_FATURA
*&---------------------------------------------------------------------*
FORM f_monta_string_fatura .

  DATA: lv_string1 TYPE string,
        lv_string2 TYPE string,
        lv_string3 TYPE string,
        lv_string4 TYPE string,
        lv_string5 TYPE string,
        lv_string6 TYPE string,
        lv_string7 TYPE string,
        lv_string8 TYPE string.
  DATA: lv_data(10)  TYPE c,
        lv_valor(20) TYPE c.
  CLEAR: gv_string, gv_string_total.
  lv_string1 = '<?xml version="1.0" encoding="UTF-8"?><FaturaTransportadora>'.
  lv_string2 = '<IdTitulo>100259</IdTitulo><RazaoSocial>Demonstração</RazaoSocial><CnpjEmissor>27663293000658</CnpjEmissor>'.
  lv_string3 = '<SerieDocumento>MTZ</SerieDocumento><NumeroDocumento>59205</NumeroDocumento><Emissao>10/05/2019 00:00:00</Emissao>'.
  lv_string4 = '<ValorBruto>444,99</ValorBruto><ValorLiquido>333,99</ValorLiquido><Vencimento>31/05/2019 00:00:00</Vencimento>'.
  lv_string5 = '<TipoTitulo></TipoTitulo><Pessoa><Tipo>J</Tipo><Nome>BTL SOLUCOES LOG EIRELI</Nome><CpfCnpj>13733693000254</CpfCnpj>'.
  lv_string6 = '<InscricaoEstadual>146763373119</InscricaoEstadual><InscricaoMunicipal>9988444</InscricaoMunicipal>'.
  lv_string7 = '</Pessoa><Endereco><Logradouro>ROD ANHANGUERA</Logradouro><Numero>2400</Numero><Complemento>KM 24</Complemento>'.
  lv_string8 = '<Bairro>JD JARAGUA</Bairro><CEP>2168020</CEP><Cidade>SAO PAULO</Cidade><Estado>ZZ</Estado></Endereco><Conhecimentos>'.

  CONCATENATE lv_string1 lv_string2 lv_string3 lv_string4 lv_string5 lv_string6 lv_string7 lv_string8 INTO gv_string.
* substitui <NumeroDocumento>
  REPLACE FIRST OCCURRENCE OF '59205' IN
    gv_string WITH p_fatura
          REPLACEMENT COUNT  DATA(cnt)
          REPLACEMENT OFFSET DATA(off)
          REPLACEMENT LENGTH DATA(len).
* Substitui <Emissao>
*  WRITE: p_dtemi TO lv_data.
  CONCATENATE p_dtemi+6(2) '/' p_dtemi+4(2) '/' p_dtemi(4) INTO lv_data.
  REPLACE FIRST OCCURRENCE OF '10/05/2019' IN
    gv_string WITH lv_data.
* substitui <ValorBruto>
  lv_valor = p_vbruto.
  REPLACE '.' IN lv_valor WITH ','.
  REPLACE FIRST OCCURRENCE OF '444,99' IN
  gv_string WITH lv_valor.
* Substitui <ValorLiquido>
  lv_valor = p_vliq.
  REPLACE '.' IN lv_valor WITH ','.

  REPLACE FIRST OCCURRENCE OF '333,99' IN
    gv_string WITH lv_valor.
* Substitui <Vencimento>
*  WRITE: p_vecto TO lv_data.
  CONCATENATE p_vecto+6(2) '/' p_vecto+4(2) '/' p_vecto(4) INTO lv_data.
  REPLACE FIRST OCCURRENCE OF '31/05/2019' IN
    gv_string WITH lv_data.
* substitui campos da transportadora.
* substitui  <Nome>
  REPLACE FIRST OCCURRENCE OF 'BTL SOLUCOES LOG EIRELI' IN
    gv_string WITH w_lfa1-name1.
* substitui  <CpfCnpj>
  REPLACE FIRST OCCURRENCE OF '13733693000254' IN
    gv_string WITH w_lfa1-stcd1.
* substitui  <InscricaoEstadual>
  REPLACE FIRST OCCURRENCE OF '146763373119' IN
    gv_string WITH w_lfa1-stcd3.
* substitui  <InscricaoMunicipal>
  REPLACE FIRST OCCURRENCE OF '9988444' IN
    gv_string WITH w_lfa1-stcd4.
* substitui  <Logradouro>
  REPLACE FIRST OCCURRENCE OF 'ROD ANHANGUERA' IN
    gv_string WITH w_lfa1-street.
* substitui  <Numero>
  REPLACE FIRST OCCURRENCE OF '2400' IN
    gv_string WITH w_lfa1-house_num1.
* substitui  <Complemento>
  REPLACE FIRST OCCURRENCE OF 'KM 24' IN
    gv_string WITH w_lfa1-house_num2.
* substitui  <Bairro>
  REPLACE FIRST OCCURRENCE OF 'JD JARAGUA' IN
    gv_string WITH w_lfa1-city2.
* substitui  <CEP>
  REPLACE FIRST OCCURRENCE OF '2168020' IN
    gv_string WITH w_lfa1-post_code1.
* substitui  <Cidade>
  REPLACE FIRST OCCURRENCE OF 'SAO PAULO' IN
    gv_string WITH w_lfa1-city1.
* substitui  <Estado>
  REPLACE FIRST OCCURRENCE OF 'ZZ' IN
    gv_string WITH w_lfa1-region.

  MOVE gv_string TO gv_string_total.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_CONSISTE_STCD1
*&---------------------------------------------------------------------*
FORM f_consiste_stcd1 .

  SELECT name1 UP TO 1 ROWS                             "#EC CI_NOFIELD
         INTO v_name1 FROM lfa1
         WHERE stcd1 = p_stcd1.
  ENDSELECT.

  IF sy-subrc NE 0.
    MESSAGE TEXT-e04 TYPE 'I'. "Nr.ID Fiscal 1 não cadastrado
    LEAVE LIST-PROCESSING.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_GET_FORNECEDOR
*&---------------------------------------------------------------------*
FORM f_get_fornecedor .
* já consistido a existência.
  SELECT a~lifnr a~stcd1 a~stcd3 a~stcd4
         b~name1 b~street b~house_num1 b~house_num2 b~city2 b~post_code1
         b~city1 b~region
         INTO w_lfa1
  FROM lfa1 AS a
    INNER JOIN adrc AS b
    ON a~adrnr = b~addrnumber
    WHERE a~stcd1 = p_stcd1.
  ENDSELECT.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_TRATA_XML
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_RET_BIZTALK  text
*      -->P_LT_DOC_BIN  text
*      -->P_GC_EXNAT  text
*      -->P_GC_EXTPDC  text
*      -->P_GC_EXTPDF  text
*      -->P_GC_MENSG  text
*      -->P_GC_EXEVT  text
*      -->P_GC_DIREC  text
*----------------------------------------------------------------------*
FORM f_trata_xml TABLES p_ret         STRUCTURE zhms_es_return  " Retorno
                  USING p_xml_bin_str TYPE      xstring         " XML Binário
                        p_exnat       TYPE      zhms_de_exnat   " Natureza do Documento
                        p_extpdc      TYPE      zhms_de_extpd   " Tipo de Doc. CT-e
                        p_extpdf      TYPE      zhms_de_extpd   " Tipo de Doc. Fatura
                        p_mensg       TYPE      zhms_de_mensg   " Mensageria - Default NEO
                        p_exevt       TYPE      zhms_de_exevt   " Evento     - Default 1003
                        p_direc       TYPE      zhms_de_direc.  " Direção    - Default E (Entrada)

  DATA lv_grava     TYPE c.
  DATA lwa_return   TYPE zhms_es_return.
  DATA lv_moff      TYPE i.
  DATA lv_len       TYPE i.
  DATA lv_chave_cte TYPE char44.
  DATA lv_chave_fat TYPE char44.
  DATA lv_erro      TYPE char01.
  DATA lv_conta_chaves TYPE i.
  DATA lv_conta_tabela TYPE i.
  DATA lit_cabdoc TYPE STANDARD TABLE OF ty_cabdoc.

*** Limpa parâmetros Globais
  CLEAR v_exnat  . " Natureza do Documento
  CLEAR v_extpdc . " Tipo de Doc. CT-e
  CLEAR v_extpdf . " Tipo de Doc. Fatura
  CLEAR v_mensg  . " Mensageria - Default NEO
  CLEAR v_exevt  . " Evento     - Default 1003

*** Alimenta Parâmetros Globais
  v_exnat  = p_exnat . " Natureza do Documento
  v_extpdc = p_extpdc. " Tipo de Doc. CT-e
  v_extpdf = p_extpdf. " Tipo de Doc. Fatura
  v_mensg  = p_mensg . " Mensageria - Default NEO
  v_exevt  = p_exevt . " Evento     - Default 1003
  v_direc  = p_direc . " Direção    - Default E (Entrada)

  v_limpa = abap_true.

  CALL FUNCTION 'SMUM_XML_PARSE'
    EXPORTING
      xml_input = p_xml_bin_str
    TABLES
      xml_table = gt_xml_data
      return    = gt_return.

  REFRESH it_chave.
  CLEAR: lv_grava, wa_chave.
*** Verifica se XML Contém Dados
*** Leitura da Chave fatura
  " BREAK roho.
  DATA lv_chave_valida TYPE char44.
  DATA lv_fatura TYPE char10.
  DATA lv_miro   TYPE char10.
  READ TABLE gt_xml_data INTO wa_xml_data WITH KEY cname = 'IdTitulo'.
  IF sy-subrc EQ 0.
    lv_chave_valida = wa_xml_data-cvalue.
    READ TABLE gt_xml_data INTO wa_xml_data WITH KEY cname = 'NumeroDocumento'.
    IF sy-subrc EQ 0.
      lv_fatura = wa_xml_data-cvalue.
      CONCATENATE lv_chave_valida wa_xml_data-cvalue INTO lv_chave_valida.
      SELECT SINGLE value FROM zhms_tb_docmn INTO lv_miro WHERE chave = lv_chave_valida
                                           AND mneum = 'INVDOCNO'.
      IF sy-subrc EQ 0.
        lwa_return-retnr = 'FAT'.
        CONCATENATE 'Fatura' lv_fatura 'já carregado, favor estornar Fluxo no ZHMS p/ Miro' lv_miro INTO lwa_return-descr SEPARATED BY space.
        APPEND lwa_return TO p_ret.
        CLEAR lwa_return.
      ENDIF.
    ENDIF.
  ENDIF.
  IF lv_miro IS INITIAL.
    IF gt_xml_data[] IS NOT INITIAL.

      CLEAR wa_xml_data.
**** Verifica se é um XML Fatura > para N CT-es
      READ TABLE gt_xml_data INTO wa_xml_data WITH KEY cname = 'FaturaTransportadora'.
      IF sy-subrc EQ 0. "Se for o arquivo de Fatura com XMLs

        REFRESH: gt_xml_cte, gt_return.
        CLEAR: wa_xml_data, lv_xml_str, lv_xml_xstr.

********************************************************************************
**** Bloco - CT-e
********************************************************************************

        LOOP AT gt_xml_data INTO wa_xml_data WHERE cname = 'XML'.
          CLEAR lv_chave_cte.
          CLEAR lv_chave_fat.
          CLEAR lv_erro.

*        IF wa_xml_data-cvalue(128) = '<CTe xmlns="http://www.portalfiscal.inf.br/cte"><infCte versao="3.00" Id="CTe35190700953655000184570010003809421002068873"><ide>'.
*          " " break roho.
*        ENDIF.

          CONCATENATE lv_xml_str wa_xml_data-cvalue INTO lv_xml_str.
          IF wa_xml_data-type EQ 'V'. "Indica que Terminou a montagem do XML

**** Leitura Chave CT-e
            "" Captura Chave Offset "Id="CTe" e alimenta tabela de Chaves,
            "" esta tabela será usada para log e estorno das gravações em caso de erros
            CLEAR lv_moff.
            FIND FIRST OCCURRENCE OF 'Id="CTe' IN lv_xml_str MATCH OFFSET lv_moff. "Procura tag 'Id="CTe' na string do XML
            IF lv_moff IS NOT INITIAL. "Caso encontre a Tag
              lv_moff = lv_moff + 7. "Lê posição de 'I' a 'e' do Texto 'Id="CTe'.
              lv_chave_cte = lv_xml_str+lv_moff(44). " Lê chave
              wa_chave-chave = lv_chave_cte.
              APPEND wa_chave TO it_chave.
              CLEAR wa_chave.
              IF v_limpa EQ abap_true.
                PERFORM estorna_individual USING lv_chave_cte.
              ENDIF.
            ENDIF.
            PERFORM f_convert_string_to_xstring  USING lv_xml_str
                                              CHANGING lv_xml_xstr.

            IF lv_xml_xstr IS NOT INITIAL.

*** Convert XML CT-e
              DO 2 TIMES. " Tenta carregar a CT-e 2 vezes (a Segunda ver é para tratar o xCampo, caso não carregue na primeira)
                REFRESH gt_xml_cte.
                REFRESH gt_return.
                CALL FUNCTION 'SMUM_XML_PARSE'
                  EXPORTING
                    xml_input = lv_xml_xstr
                  TABLES
                    xml_table = gt_xml_cte
                    return    = gt_return.

                IF gt_xml_cte IS INITIAL.
                  "" Tratamento atributo 'xCampo'
                  CLEAR lv_moff.
                  FIND FIRST OCCURRENCE OF 'xCampo' IN lv_xml_str MATCH OFFSET lv_moff.
                  IF lv_moff IS NOT INITIAL.
                    lv_len = strlen( lv_xml_str ).
                    lv_len = ( lv_moff - lv_len ) * -1.
                    CONCATENATE lv_xml_str(lv_moff)
                                lv_xml_str+lv_moff(lv_len)
                           INTO lv_xml_str SEPARATED BY space.

                    "" Tratamento atributo 'versaoModal'
                    CLEAR lv_moff.
                    FIND FIRST OCCURRENCE OF 'versaoModal' IN lv_xml_str MATCH OFFSET lv_moff.
                    IF lv_moff IS NOT INITIAL.
                      lv_len = strlen( lv_xml_str ).
                      lv_len = ( lv_moff - lv_len ) * -1.
                      CONCATENATE lv_xml_str(lv_moff)
                                  lv_xml_str+lv_moff(lv_len)
                             INTO lv_xml_str SEPARATED BY space.

                    ENDIF.

                    PERFORM f_convert_string_to_xstring  USING lv_xml_str
                                                      CHANGING lv_xml_xstr.
                    CONTINUE.
                  ENDIF.
                ELSE.
                  EXIT.
                ENDIF.
              ENDDO.
********************************************************************************
**** Grava - XML CT-e
********************************************************************************
              IF gt_xml_cte IS NOT INITIAL.
                PERFORM f_quazaris_carga TABLES gt_xml_cte
                                                p_ret
                                          USING 'CTE'
                                                lv_chave_cte
                                                lv_erro.
                IF lv_erro EQ abap_true.
                  PERFORM estorna_documentos.
                  EXIT.
                ENDIF.
              ELSE.
                lwa_return-retnr = 'CTE'.
                CONCATENATE TEXT-008 lv_chave_cte INTO lwa_return-descr.
                APPEND lwa_return TO p_ret.
                CLEAR lwa_return.
                PERFORM estorna_documentos.
                EXIT.
              ENDIF.

              CLEAR lv_xml_str.
              CLEAR lv_xml_xstr.
              CLEAR wa_xml_data.
              REFRESH gt_xml_cte.
            ENDIF.
          ENDIF.
        ENDLOOP.

********************************************************************************
**** Bloco - Fatura - Valida Gravação de CT-es
********************************************************************************
        COMMIT WORK AND WAIT.
        " Verifica se tabela de Mnemônicos foi atualizada para todas as CT-es
        " da Fatura. Se sim, grava Cabeçalho Fatura e Lê XML Fatura
        IF it_chave IS NOT INITIAL.
          CLEAR lv_conta_chaves.
          CLEAR lv_conta_tabela.
          CLEAR lit_cabdoc     .



          SORT it_chave BY chave.
          SELECT chave typed FROM zhms_tb_cabdoc
                             INTO TABLE lit_cabdoc
               FOR ALL ENTRIES IN it_chave
                            WHERE chave EQ it_chave-chave
                              AND typed EQ 'CTE'.

          DESCRIBE TABLE it_chave   LINES lv_conta_chaves.
          DESCRIBE TABLE lit_cabdoc LINES lv_conta_tabela.
          IF lv_conta_tabela = lv_conta_chaves.
            lv_grava = abap_true.
          ENDIF.
        ENDIF.

********************************************************************************
**** Grava Tabela Fatura e Documento Tipo FAT nas tabelas HomSoft
********************************************************************************
        IF lv_grava EQ abap_true.
*** Lê XML Fatura
          CLEAR lv_xml_str.
          gt_xml_fat = gt_xml_data.
          " Remove TAGs irrelevantes para XML Fatura
          DELETE gt_xml_fat WHERE cname EQ 'XML'.
          DELETE gt_xml_fat WHERE cname EQ 'Conhecimentos'.
          DELETE gt_xml_fat WHERE type  EQ '+'.

          IF gt_xml_data IS NOT INITIAL.


*** Leitura da Chave fatura
            READ TABLE gt_xml_data INTO wa_xml_data WITH KEY cname = 'IdTitulo'.
            IF sy-subrc EQ 0.
              lv_chave_fat = wa_xml_data-cvalue.
              READ TABLE gt_xml_data INTO wa_xml_data WITH KEY cname = 'NumeroDocumento'.
              IF sy-subrc EQ 0.
                CONCATENATE lv_chave_fat wa_xml_data-cvalue INTO lv_chave_fat.
*              wa_chave-chave = lv_chave_fat.
*              APPEND wa_chave TO it_chave.
*              CLEAR wa_chave.
                IF v_limpa EQ abap_true.
                  PERFORM estorna_individual USING lv_chave_fat.
                ENDIF.
              ENDIF.
            ENDIF.

*** Grava Fatura na tabela zhms_tb_fatura
            PERFORM f_grava_fatura USING lv_chave_fat.
*** Grava XML Fatura nas Tabelas Homsoft

            PERFORM f_quazaris_carga TABLES gt_xml_fat
                                            p_ret
                                     USING 'FAT'
                                            lv_chave_fat
                                            lv_erro.
            IF lv_erro EQ abap_true.
              PERFORM estorna_documentos.
            ELSE.
              COMMIT WORK AND WAIT.
            ENDIF.
          ELSE.
            " XML Não carregado devido a erro na Fatura
            lwa_return-retnr = 'FAT'.
            lwa_return-descr = TEXT-022.
            APPEND lwa_return TO p_ret.
            CLEAR lwa_return.
            PERFORM estorna_documentos.
          ENDIF.
        ELSE.
          " XML Não carregado devido a erro na Fatura
          lwa_return-retnr = 'CTE'.
          lwa_return-descr = TEXT-012.
          APPEND lwa_return TO p_ret.
          CLEAR lwa_return.
          PERFORM estorna_documentos.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM. " F_TRATA_XML
*&---------------------------------------------------------------------*
*&      Form  ESTORNA_DOCUMENTOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM estorna_documentos .

  LOOP AT it_chave INTO wa_chave.
    IF wa_chave-chave IS NOT INITIAL.
* Executa Limpa Chave
      SUBMIT zhms_limpa_chave WITH v_chave = wa_chave-chave
                              EXPORTING LIST TO MEMORY
                              AND RETURN.

* Executa Exclui Chave
      SUBMIT zhms_exclui_chave WITH p_chave = wa_chave-chave
                              EXPORTING LIST TO MEMORY
                              AND RETURN.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ESTORNA_INDIVIDUAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_CHAVE_CTE  text
*----------------------------------------------------------------------*
FORM estorna_individual  USING    c_chave.  "p_lv_chave_cte.

  IF c_chave IS NOT INITIAL.
* Executa Limpa Chave
    SUBMIT zhms_limpa_chave WITH v_chave = c_chave
                            EXPORTING LIST TO MEMORY
                            AND RETURN.

* Executa Exclui Chave
    SUBMIT zhms_exclui_chave WITH p_chave = c_chave
                            EXPORTING LIST TO MEMORY
                            AND RETURN.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_CONVERT_STRING_TO_XSTRING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_XML_STR  text
*      <--P_LV_XML_XSTR  text
*----------------------------------------------------------------------*
FORM f_convert_string_to_xstring USING p_in TYPE string
                              CHANGING  p_out TYPE xstring.

  DATA lv_converter   TYPE REF TO cl_abap_conv_out_ce.
  DATA lv_conv_length TYPE i.

  lv_converter = cl_abap_conv_out_ce=>create( ).

  CALL METHOD lv_converter->write
    EXPORTING
      data = p_in
    IMPORTING
      len  = lv_conv_length.

  p_out = lv_converter->get_buffer( ).



ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_GRAVA_FATURA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_CHAVE_FAT  text
*----------------------------------------------------------------------*
FORM f_grava_fatura USING p_chave_fat TYPE char44.

  REFRESH it_tb_fatura.
  CLEAR wa_chave.

  LOOP AT it_chave INTO wa_chave.

    IF sy-subrc EQ 0.
      wa_tb_fatura-chave = wa_chave-chave.
    ENDIF.

    CLEAR wa_xml_data.
    READ TABLE gt_xml_data INTO wa_xml_data WITH KEY cname = 'IdTitulo'.
    wa_tb_fatura-idtitulo = wa_xml_data-cvalue.

    CLEAR wa_xml_data.
    READ TABLE gt_xml_data INTO wa_xml_data WITH KEY cname = 'RazaoSocial'.
    wa_tb_fatura-razaosocial = wa_xml_data-cvalue.

    CLEAR wa_xml_data.
    READ TABLE gt_xml_data INTO wa_xml_data WITH KEY cname = 'CnpjEmissor'.
    wa_tb_fatura-cnpjemissor = wa_xml_data-cvalue.

    CLEAR wa_xml_data.
    READ TABLE gt_xml_data INTO wa_xml_data WITH KEY cname = 'SerieDocumento'.
    wa_tb_fatura-seriedocumento = wa_xml_data-cvalue.

    CLEAR wa_xml_data.
    READ TABLE gt_xml_data INTO wa_xml_data WITH KEY cname = 'NumeroDocumento'.
    wa_tb_fatura-numerodocumento = wa_xml_data-cvalue.

    CLEAR wa_xml_data.
    READ TABLE gt_xml_data INTO wa_xml_data WITH KEY cname = 'Emissao'.
    wa_tb_fatura-emissao = wa_xml_data-cvalue.

    CLEAR wa_xml_data.
    READ TABLE gt_xml_data INTO wa_xml_data WITH KEY cname = 'ValorBruto'.
    wa_tb_fatura-valorbruto = wa_xml_data-cvalue.

    CLEAR wa_xml_data.
    READ TABLE gt_xml_data INTO wa_xml_data WITH KEY cname = 'ValorLiquido'.
    wa_tb_fatura-valorliquido = wa_xml_data-cvalue.

    CLEAR wa_xml_data.
    READ TABLE gt_xml_data INTO wa_xml_data WITH KEY cname = 'Vencimento'.
    wa_tb_fatura-vencimento = wa_xml_data-cvalue.

    CLEAR wa_xml_data.
    READ TABLE gt_xml_data INTO wa_xml_data WITH KEY cname = 'TipoTitulo'.
    wa_tb_fatura-tipotitulo = wa_xml_data-cvalue.

    CLEAR wa_xml_data.
    READ TABLE gt_xml_data INTO wa_xml_data WITH KEY cname = 'Tipo'.
    wa_tb_fatura-tipopessoa = wa_xml_data-cvalue.

    CLEAR wa_xml_data.
    READ TABLE gt_xml_data INTO wa_xml_data WITH KEY cname = 'Nome'.
    wa_tb_fatura-nome = wa_xml_data-cvalue.

    CLEAR wa_xml_data.
    READ TABLE gt_xml_data INTO wa_xml_data WITH KEY cname = 'CpfCnpj'.
    wa_tb_fatura-cpfcnpj = wa_xml_data-cvalue.

    CLEAR wa_xml_data.
    READ TABLE gt_xml_data INTO wa_xml_data WITH KEY cname = 'InscricaoEstadual'.
    wa_tb_fatura-inscricaoestadual = wa_xml_data-cvalue.

    CLEAR wa_xml_data.
    READ TABLE gt_xml_data INTO wa_xml_data WITH KEY cname = 'InscricaoMunicipal'.
    wa_tb_fatura-inscricaomunicipal = wa_xml_data-cvalue.

    CLEAR wa_xml_data.
    READ TABLE gt_xml_data INTO wa_xml_data WITH KEY cname = 'Logradouro'.
    wa_tb_fatura-logradouro = wa_xml_data-cvalue.

    CLEAR wa_xml_data.
    READ TABLE gt_xml_data INTO wa_xml_data WITH KEY cname = 'Numero'.
    wa_tb_fatura-numero = wa_xml_data-cvalue.

    CLEAR wa_xml_data.
    READ TABLE gt_xml_data INTO wa_xml_data WITH KEY cname = 'Complemento'.
    wa_tb_fatura-complemento = wa_xml_data-cvalue.

    CLEAR wa_xml_data.
    READ TABLE gt_xml_data INTO wa_xml_data WITH KEY cname = 'Bairro'.
    wa_tb_fatura-bairro = wa_xml_data-cvalue.

    CLEAR wa_xml_data.
    READ TABLE gt_xml_data INTO wa_xml_data WITH KEY cname = 'CEP'.
    wa_tb_fatura-cep = wa_xml_data-cvalue.

    CLEAR wa_xml_data.
    READ TABLE gt_xml_data INTO wa_xml_data WITH KEY cname = 'Cidade'.
    wa_tb_fatura-cidade = wa_xml_data-cvalue.

    CLEAR wa_xml_data.
    READ TABLE gt_xml_data INTO wa_xml_data WITH KEY cname = 'Estado'.
    wa_tb_fatura-estado = wa_xml_data-cvalue.

    wa_tb_fatura-cct       = wa_chave-cct.
    wa_tb_fatura-nct       = wa_chave-nct.
    wa_tb_fatura-ndoc      = wa_chave-ndoc.
    wa_tb_fatura-demi      = wa_chave-demi.
    wa_tb_fatura-chave_fat = p_chave_fat.
    APPEND wa_tb_fatura TO it_tb_fatura.
    CLEAR: wa_tb_fatura, wa_chave.

  ENDLOOP.

  IF it_tb_fatura[] IS NOT INITIAL.
    TRY .
        MODIFY zhms_tb_fatura  FROM TABLE it_tb_fatura.
        IF sy-subrc EQ 0.
          COMMIT WORK.
        ENDIF.
      CATCH cx_root.
        ROLLBACK WORK.
    ENDTRY.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_QUAZARIS_CARGA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_XML_CTE  text
*      -->P_P_RET  text
*      -->P_1887   text
*      -->P_LV_CHAVE_CTE  text
*      -->P_LV_ERRO  text
*----------------------------------------------------------------------*
FORM f_quazaris_carga TABLES p_tb_xml TYPE zhms_tt_smum_xmltb
                             p_ret    STRUCTURE zhms_es_return  " Retorno
                       USING p_tpdoc  TYPE char03 " CT-e ou FAT
                             p_chave  TYPE char44
                             p_erro.

  REFRESH gt_xml_data_aux.
  REFRESH lt_msgdata.
  REFRESH lt_msgatrb.
  REFRESH lt_return.
  REFRESH t_controle.

  DATA lwa_data_aux LIKE LINE OF gt_xml_data_aux.
  DATA lv_lines TYPE i.
********************************************************************************
**** Leitura CT-es
********************************************************************************
  DELETE p_tb_xml WHERE type = '+'.

  gt_xml_data_aux = p_tb_xml[].

********************************************************************************
**** Leitura CT-es - Carrega HomSoft: Atributos da Mensagem
********************************************************************************
  LOOP AT gt_xml_data_aux INTO gwa_xml_data.
    ADD 1 TO w_controle-seqnc.
    IF gwa_xml_data-type = 'A'.
      w_msgatrb-seqnc = sy-tabix.
      w_msgatrb-seqnc = w_msgatrb-seqnc - 1.
      w_msgatrb-field = gwa_xml_data-cname.
      w_msgatrb-value = gwa_xml_data-cvalue.
      APPEND w_msgatrb TO lt_msgatrb.
      DELETE gt_xml_data_aux INDEX sy-tabix.
      CONTINUE.
    ENDIF.
  ENDLOOP.

  CLEAR w_controle-seqnc.
  SORT gt_xml_data_aux BY hier DESCENDING.

********************************************************************************
**** Leitura CT-es - HomSoft: Estrutura do Arquivo de Comunicação
********************************************************************************
  LOOP AT p_tb_xml INTO gwa_xml_data.
    ADD 1 TO w_controle-seqnc.
    IF gwa_xml_data-type = 'A'.
      DELETE p_tb_xml INDEX sy-tabix.
      CONTINUE.
    ENDIF.

    " Converte valores líquidos
    IF p_tpdoc EQ 'FAT' AND ( gwa_xml_data-cname EQ 'ValorBruto' OR gwa_xml_data-cname EQ 'ValorLiquido' ).
      TRANSLATE  gwa_xml_data-cvalue USING ',.'.
    ENDIF.

    w_controle-seqnc = w_controle-seqnc.
    w_controle-hier = gwa_xml_data-hier.
    w_controle-field = gwa_xml_data-cname.

    IF gwa_xml_data-hier > 1.
      SORT t_controle BY seqnc DESCENDING.
      vhier = gwa_xml_data-hier - 1.
      READ TABLE t_controle INTO w_controle_aux WITH KEY hier = vhier.
      IF sy-subrc EQ 0.
        CONCATENATE w_controle_aux-field '/' gwa_xml_data-cname
               INTO w_controle-field.
        w_controle-value = gwa_xml_data-cvalue.
      ENDIF.
    ENDIF.
    APPEND w_controle TO t_controle.
  ENDLOOP.

  SORT t_controle BY seqnc.

********************************************************************************
*** Haverá dois tipos de CT-e : CT-e Minuta/Intramunicipal e CT-e Normal
*** para a Minuta/Intramunicipal não há a TAG <cteProc>
*** A tratativa abaixo é para considerar estes dois tipos de cenário,
*** removendo a TAG <cteProc> quando necessário
********************************************************************************
  DATA: lv_tabix TYPE sy-subrc.
  LOOP AT t_controle ASSIGNING <fs_controle>.
    lv_tabix = sy-tabix.
    <fs_controle>-seqnc = lv_tabix.
    MOVE-CORRESPONDING <fs_controle> TO w_msgdata.
    IF w_msgdata-field(7) EQ gc_cteproc. " Verifica se possui cteProc/
      w_msgdata-field(8) = space.        " Remove cteProc/
      CONDENSE w_msgdata-field.
      " Ignorar a primeira linha caso seja o layout com TAG <cteProc>,
      " para tag não ficar vazia no primeiro nível
      IF lv_tabix EQ 1.
        CONTINUE.
      ELSE.
        " Diminui um nível na hierarquia, pois a primeira linha foi ignorada
        w_msgdata-seqnc = w_msgdata-seqnc - 1.
      ENDIF.
    ENDIF.
    APPEND w_msgdata TO lt_msgdata.
    CLEAR w_msgdata.
  ENDLOOP.

*--------------------------------------------------------------------*
***RRO 10/04/2019 -->>

  IF lt_msgdata IS NOT INITIAL.
    CASE p_tpdoc. " CT-e ou FAT
      WHEN 'CTE'.
        CLEAR lt_return.
        CLEAR v_critc.
        CALL FUNCTION 'ZHMS_FM_QUAZARIS_FATURA'
          EXPORTING
            exnat   = v_exnat
            extpd   = v_extpdc " Default 57 - CT-e
            mensg   = v_mensg
            exevt   = v_exevt
            direc   = v_direc
          IMPORTING
            p_critc = v_critc
          TABLES
            msgdata = lt_msgdata
            msgatrb = lt_msgatrb
            return  = lt_return.

        IF v_critc IS NOT INITIAL.
          wa_return-retnr = p_tpdoc.
          CONCATENATE TEXT-017 p_chave INTO wa_return-descr.
          APPEND wa_return TO p_ret.
          p_erro = abap_true.
        ELSE.
          APPEND LINES OF lt_return TO p_ret.
          wa_return-retnr = p_tpdoc.
          CONCATENATE TEXT-018 p_chave INTO wa_return-descr.
          APPEND wa_return TO p_ret.
        ENDIF.
      WHEN 'FAT'.
        CLEAR lt_return.
        CLEAR v_critc.
        CALL FUNCTION 'ZHMS_FM_QUAZARIS_FATURA'
          EXPORTING
            exnat   = v_exnat
            extpd   = v_extpdf " Default 60 - FAT
            mensg   = v_mensg
            exevt   = v_exevt
            direc   = v_direc
          IMPORTING
            p_critc = v_critc
          TABLES
            msgdata = lt_msgdata
            msgatrb = lt_msgatrb
            return  = lt_return.
        IF v_critc IS NOT INITIAL.
          wa_return-retnr = p_tpdoc.
          CONCATENATE TEXT-019 p_chave INTO wa_return-descr.
          APPEND wa_return TO p_ret.
          p_erro = abap_true.
        ELSE.
          APPEND LINES OF lt_return TO p_ret.
          wa_return-retnr = p_tpdoc.
          CONCATENATE TEXT-020 p_chave INTO wa_return-descr.
          APPEND wa_return TO p_ret.
          CLEAR wa_return-descr.
          wa_return-descr = TEXT-021.
          APPEND wa_return TO p_ret.
        ENDIF.
    ENDCASE.

    REFRESH gt_xml_data_aux.
    REFRESH lt_msgdata.
    REFRESH lt_return.
  ENDIF.
***RRO 10/04/2019 <<--
*--------------------------------------------------------------------*
ENDFORM.
