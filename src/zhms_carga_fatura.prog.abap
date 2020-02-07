*----------------------------------------------------------------------*
* REPORT ZHMS_CARGA_FATURA
*----------------------------------------------------------------------*
* Descrição       : Carga Fatura
* Transação       : N/A
* Data de Criação : 30.07.2019
* Desenvolvedor   : Homine Consulting
* Solicitante     :
* N° Referencia   : CR-2383 - HomSoft projeto LE-TRA
*----------------------------------------------------------------------*

REPORT zhms_carga_fatura.

********************************************************************************
*** Tipos para Carregar arquivo Excel
********************************************************************************
TYPES truxs_t_text_data(4096) TYPE c OCCURS 0.

********************************************************************************
*** Tipos
********************************************************************************
TYPES: BEGIN OF tp_exc,
         mandt TYPE string,
         chave TYPE string,
         direc TYPE string,
         seqnc TYPE string,
         dcitm TYPE string,
         field TYPE string,
         value TYPE string,
         lote  TYPE string,
         dtalt TYPE string,
         hralt TYPE string,
       END OF tp_exc,

       BEGIN OF ty_controle,
         seqnc TYPE i,
         hier  TYPE int1,
         field TYPE c LENGTH 255,
         value TYPE c LENGTH 255,
       END OF ty_controle,

       BEGIN OF ty_chave,
         chave TYPE char44,
         lote  TYPE zhms_de_lote,
         cct   TYPE char10,
         nct   TYPE char10,
         ndoc  TYPE char10,
         demi  TYPE char10,
       END OF ty_chave,

       BEGIN OF ty_cabdoc,
         chave TYPE zhms_de_chave,
         typed TYPE zhms_de_typed,
       END OF  ty_cabdoc,

       BEGIN OF ty_splitxml,
         linha TYPE xstring,
       END OF  ty_splitxml.

********************************************************************************
*** Declarações Gerais
********************************************************************************
DATA it_splitxml     TYPE STANDARD TABLE OF ty_splitxml.
DATA it_tp_exc       TYPE STANDARD TABLE OF tp_exc.
DATA lt_repdocat     TYPE STANDARD TABLE OF zhms_tb_repdocat.
DATA lt_msgdata      TYPE STANDARD TABLE OF zhms_es_msgdt.
DATA lt_msgatrb      TYPE STANDARD TABLE OF zhms_es_msgat.
DATA lt_return       TYPE STANDARD TABLE OF zhms_es_return.
DATA it_tb_fatura    TYPE STANDARD TABLE OF zhms_tb_fatura.
DATA it_chave        TYPE STANDARD TABLE OF ty_chave.
DATA gt_xml_data     TYPE TABLE OF smum_xmltb.
DATA gt_xml_cte      TYPE TABLE OF smum_xmltb.
DATA gt_xml_fat      TYPE TABLE OF smum_xmltb.
DATA gt_xml_data_aux TYPE TABLE OF smum_xmltb.
DATA gt_return       TYPE TABLE OF bapiret2.
DATA gt_ret_biztalk  TYPE TABLE OF zhms_es_return.
DATA t_msgdata       TYPE TABLE OF zhms_es_msgdt.
DATA t_msgatrb       TYPE TABLE OF zhms_es_msgat.
DATA t_controle      TYPE TABLE OF ty_controle.
DATA gcl_xml         TYPE REF TO cl_xml_document.
DATA ls_repdocat     LIKE LINE OF lt_repdocat.
DATA wa_msgdata      LIKE LINE OF lt_msgdata.
DATA wa_msgatrb      LIKE LINE OF lt_msgatrb.
DATA wa_tp_exc       TYPE tp_exc.
DATA wa_splitxml     TYPE ty_splitxml.
DATA it_data_xls     TYPE truxs_t_text_data.
DATA gv_subrc        TYPE sy-subrc.
DATA gv_xml_string   TYPE xstring.
DATA gv_size         TYPE sytabix.
DATA gwa_xml_data    TYPE smum_xmltb.
DATA gwa_xml_data_aux TYPE smum_xmltb.
DATA gv_tabix         TYPE sytabix.
DATA w_msgdata        TYPE zhms_es_msgdt.
DATA w_msgatrb        TYPE zhms_es_msgat.
DATA w_controle       TYPE ty_controle.
DATA w_controle_aux   TYPE ty_controle.
DATA vcont            TYPE i.
DATA vtabix           TYPE sy-tabix.
DATA vhier            TYPE int1.
DATA vfilename        TYPE localfile.
DATA vant             TYPE c.
DATA vcname           TYPE c LENGTH 255.
DATA vcname_aux       TYPE c LENGTH 255.
DATA lv_xml_str       TYPE string.
DATA lv_xml_xstr      TYPE xstring.
DATA wa_xml_data      TYPE smum_xmltb.
DATA wa_tb_fatura     TYPE zhms_tb_fatura.
DATA wa_return        TYPE zhms_es_return.
DATA wa_docmn         TYPE zhms_tb_docmn.
DATA wa_chave         TYPE ty_chave.
DATA v_exnat          TYPE zhms_de_exnat.
DATA v_extpdc         TYPE zhms_de_extpd.
DATA v_extpdf         TYPE zhms_de_extpd.
DATA v_mensg          TYPE zhms_de_mensg.
DATA v_exevt          TYPE zhms_de_exevt.
DATA v_direc          TYPE zhms_de_direc.
DATA v_chave          TYPE zhms_de_chave.
DATA v_texto          TYPE zhms_de_texto.
DATA v_limpa          TYPE char01.
DATA v_critc          TYPE flag.

********************************************************************************
*** Field-Symbols
********************************************************************************
FIELD-SYMBOLS: <fs_return> TYPE zhms_es_return.

********************************************************************************
*** Constants
********************************************************************************

CONSTANTS:
  gc_mensg   TYPE  zhms_de_mensg VALUE 'NEO',
  gc_exevt   TYPE  zhms_de_exevt VALUE '1003',
  gc_direc   TYPE  zhms_de_direc VALUE 'E',
  gc_cteproc TYPE  char07        VALUE 'cteProc'.
FIELD-SYMBOLS: <fs_controle> TYPE ty_controle.


********************************************************************************
*** Tela de Seleção
********************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK bloco01 WITH FRAME TITLE TEXT-001.
PARAMETERS: p_entr  LIKE rlgrap-filename OBLIGATORY,
            p_chave TYPE char44.

PARAMETERS: p_xml    RADIOBUTTON GROUP rad1 DEFAULT 'X',
            p_excel  RADIOBUTTON GROUP rad1,
            p_bztalk RADIOBUTTON GROUP rad1.

PARAMETERS: p_exnat  TYPE zhms_de_exnat DEFAULT '02',
            p_extpdc TYPE zhms_de_extpd DEFAULT '57',
            p_extpdf TYPE zhms_de_extpd DEFAULT '60',
            p_limpa  TYPE flag AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK bloco01.

********************************************************************************
*** AT-SELECTION-SCREEN
********************************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_entr.

  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_filename     = p_entr
      def_path         = 'C:_line'
      mask             = '*.*,*.*.'
      title            = 'Pesquisar Arquivo'
    IMPORTING
      filename         = p_entr
    EXCEPTIONS
      inv_winsys       = 1
      no_batch         = 2
      selection_cancel = 3
      selection_error  = 4
      OTHERS           = 5.

********************************************************************************
*** START-OF-SELECTION
********************************************************************************
START-OF-SELECTION .
  CLEAR v_critc.
  v_limpa = p_limpa.

*** Verifica se Nome do Arquivo está preenchido
  IF p_entr IS NOT INITIAL.
*** Verifica se é um arquivo excel
    IF p_excel EQ abap_true.
      PERFORM f_busca_excel.

      IF it_tp_exc IS INITIAL.
        MESSAGE TEXT-003 TYPE 'I'. " Arquivo não encontrato ou com problemas de leitura.
        LEAVE LIST-PROCESSING.
      ENDIF.

*** Verifica se é um arquivo XML
    ELSEIF p_xml EQ abap_true.
      PERFORM f_busca_xml.
      IF gv_xml_string IS NOT INITIAL.


        PERFORM f_trata_xml TABLES gt_ret_biztalk  " Retorno
                             USING gv_xml_string   " XML
                                   p_exnat         " Natureza do Documento
                                   p_extpdc        " Tipo de Doc. CT-e
                                   p_extpdf        " Tipo de Doc. Fatura
                                   gc_mensg        " Mensageria - Default NEO
                                   gc_exevt        " Evento     - Default 1003
                                   gc_direc.       " Direção    - Default E (Entrada)
      ELSE.
        MESSAGE TEXT-003 TYPE 'I'. " Arquivo não encontrato ou com problemas de leitura.
        LEAVE LIST-PROCESSING.
      ENDIF.
*** Verifica se é uma simulação Biztalk
    ELSEIF p_bztalk EQ abap_true.
      PERFORM f_busca_xml.

      IF gv_xml_string IS NOT INITIAL.
*** Simula Chamada Via Biztalk
        CALL FUNCTION 'ZHMS_FM_QUAZARIS_FAT_BIZTALK'
          EXPORTING
            exnat        = p_exnat           " Natureza do Documento
            extpd        = p_extpdf          " Tipo de Doc. Fatura
            mensg        = gc_mensg          " Mensageria - Default NEO
            exevt        = gc_exevt          " Evento     - Default 1003
            direc        = gc_direc          " Direção    - Default E (Entrada)
            xmlstringbin = gv_xml_string     " XML
          TABLES
            return       = gt_ret_biztalk.   " Retorno
      ELSE.
        MESSAGE TEXT-003 TYPE 'I'. " Arquivo não encontrato ou com problemas de leitura.
        LEAVE LIST-PROCESSING.
      ENDIF.
    ENDIF.
    IF gt_ret_biztalk IS INITIAL.
      MESSAGE TEXT-005 TYPE 'I'. " RFC ZHMS_FM_QUAZARIS_FAT_BIZTALK foi executada.
      LEAVE LIST-PROCESSING.
    ELSE.
      MESSAGE TEXT-004 TYPE 'I'. " RFC ZHMS_FM_QUAZARIS_FAT_BIZTALK foi executada, ver log seguinte
      LOOP AT gt_ret_biztalk ASSIGNING <fs_return>.
        WRITE / <fs_return>-retnr. WRITE <fs_return>-descr.
      ENDLOOP.
    ENDIF.

  ENDIF.

********************************************************************************
*** END-OF-SELECTION
********************************************************************************
END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  F_BUSCA_EXCEL
*&---------------------------------------------------------------------*
FORM f_busca_excel .

* Carrega tabela do excel em outra válida
  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
      i_tab_raw_data       = it_data_xls
      i_filename           = p_entr
    TABLES
      i_tab_converted_data = it_tp_exc
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.

  IF sy-subrc IS INITIAL AND it_tp_exc[] IS NOT INITIAL.

* Desconsiderar a primeira linha que é cabeçalho
    DELETE it_tp_exc[] INDEX 1.

    LOOP AT it_tp_exc INTO wa_tp_exc.

      MOVE: wa_tp_exc-field TO wa_msgdata-field,
            wa_tp_exc-seqnc TO wa_msgdata-seqnc,
            wa_tp_exc-dcitm TO wa_msgdata-dcitm,
            wa_tp_exc-value TO wa_msgdata-value.

      APPEND wa_msgdata TO lt_msgdata.
      CLEAR wa_msgdata.

    ENDLOOP.

    SELECT * FROM zhms_tb_repdocat INTO TABLE lt_repdocat WHERE chave EQ p_chave.
    IF sy-subrc EQ 0.

      LOOP AT lt_repdocat INTO ls_repdocat.
        MOVE: ls_repdocat-seqnc TO wa_msgatrb-seqnc,
              ls_repdocat-field TO wa_msgatrb-field,
              ls_repdocat-value TO wa_msgatrb-value.
        APPEND wa_msgatrb TO lt_msgatrb.
        CLEAR wa_msgatrb.
      ENDLOOP.

    ELSE.

      LOOP AT it_tp_exc INTO wa_tp_exc.

        MOVE: wa_tp_exc-seqnc TO wa_msgatrb-seqnc,
              wa_tp_exc-field TO wa_msgatrb-field,
              wa_tp_exc-value TO wa_msgatrb-value.

        APPEND wa_msgatrb TO lt_msgatrb.
        CLEAR wa_msgatrb.

      ENDLOOP.

    ENDIF.
  ENDIF.
ENDFORM. " F_BUSCA_EXCEL
*&---------------------------------------------------------------------*
*&      Form  F_BUSCA_XML
*&---------------------------------------------------------------------*
FORM f_busca_xml .

  CREATE OBJECT gcl_xml.

  vfilename = p_entr.

*** Upload XML File
  CALL METHOD gcl_xml->import_from_file
    EXPORTING
      filename = vfilename
    RECEIVING
      retcode  = gv_subrc.

  IF gv_subrc = 0.
    CALL METHOD gcl_xml->render_2_xstring
      IMPORTING
        retcode = gv_subrc
        stream  = gv_xml_string
        size    = gv_size.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_BUSCA_XML
*&---------------------------------------------------------------------*
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




  DATA: lv_xml           TYPE string,
        lv_xml_xstr      TYPE xstring,
        it_xml_table     TYPE TABLE OF string,
        wa_xml_table     TYPE string,
        it_xml_table_xst TYPE TABLE OF xstring,
        wa_xml_table_xst TYPE xstring,
        v_qtd(524287)    TYPE i.

  CALL FUNCTION 'ECATT_CONV_XSTRING_TO_STRING'
    EXPORTING
      im_xstring  = p_xml_bin_str  "<--- aqui o xml xtring que esta vindo
      im_encoding = 'UTF-8'
    IMPORTING
      ex_string   = lv_xml.

  SPLIT  lv_xml AT '<XML>' INTO TABLE it_xml_table."<--cuidado aqui para não perder a tag <xml>
  DELETE it_xml_table INDEX 1.

  LOOP AT it_xml_table ASSIGNING FIELD-SYMBOL(<fs_xml>).
    v_qtd = strlen( <fs_xml> ).
    v_qtd = v_qtd - 6.
    <fs_xml> = <fs_xml>(v_qtd).
    REPLACE ALL OCCURRENCES OF '&lt;' IN <fs_xml> WITH '<'.
    REPLACE ALL OCCURRENCES OF '&gt;' IN <fs_xml> WITH '>'.
    REPLACE ALL OCCURRENCES OF '&quot;' IN <fs_xml> WITH '"'.
    APPEND INITIAL LINE TO it_xml_table_xst ASSIGNING FIELD-SYMBOL(<fs_xtring>). "<--retorno com xstring em 2 linhas

    CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
      EXPORTING
        text   = <fs_xml>
      IMPORTING
        buffer = <fs_xtring>
      EXCEPTIONS
        failed = 1
        OTHERS = 2.

    IF sy-subrc <> 0.
* Implement suitable error handling here

    ENDIF.


  ENDLOOP.


  REFRESH it_chave.
  CLEAR: lv_grava, wa_chave.
*** Verifica se XML Contém Dados
*** Leitura da Chave fatura
  " BREAK roho.
  DATA lv_chave_valida TYPE char44.
  DATA lv_fatura TYPE char10.
  DATA lv_miro   TYPE char10.
  DATA vl_cnpj   TYPE zhms_tb_cnpjsn-cnpj.
  READ TABLE gt_xml_data INTO wa_xml_data WITH KEY cname = 'CpfCnpj'.
  IF sy-subrc = 0.
    CLEAR: vl_cnpj.
    SELECT SINGLE cnpj
      INTO vl_cnpj
      FROM zhms_tb_cnpjsn
      WHERE cnpj = wa_xml_data-cvalue.
    IF sy-subrc = 0.
      MESSAGE TEXT-014 TYPE 'I'. " XML Simples Nacional não pode ser carregado.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.

  CHECK vl_cnpj IS  INITIAL.

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
        DATA: v_contcte(1000) TYPE i.
        CLEAR: v_contcte.
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
              v_contcte = v_contcte + 1.

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

*                IF gt_xml_cte IS INITIAL.
*                  "" Tratamento atributo 'xCampo'
*                  CLEAR lv_moff.
*                  FIND FIRST OCCURRENCE OF 'xCampo' IN lv_xml_str MATCH OFFSET lv_moff.
*                  IF lv_moff IS NOT INITIAL.
*                    lv_len = strlen( lv_xml_str ).
*                    lv_len = ( lv_moff - lv_len ) * -1.
*                    CONCATENATE lv_xml_str(lv_moff)
*                                lv_xml_str+lv_moff(lv_len)
*                           INTO lv_xml_str SEPARATED BY space.
*
*                    "" Tratamento atributo 'versaoModal'
*                    CLEAR lv_moff.
*                    FIND FIRST OCCURRENCE OF 'versaoModal' IN lv_xml_str MATCH OFFSET lv_moff.
*                    IF lv_moff IS NOT INITIAL.
*                      lv_len = strlen( lv_xml_str ).
*                      lv_len = ( lv_moff - lv_len ) * -1.
*                      CONCATENATE lv_xml_str(lv_moff)
*                                  lv_xml_str+lv_moff(lv_len)
*                             INTO lv_xml_str SEPARATED BY space.
*
*                    ENDIF.
*
*                    PERFORM f_convert_string_to_xstring  USING lv_xml_str
*                                                      CHANGING lv_xml_xstr.
*                    CONTINUE.
*                  ENDIF.
*                ELSE.
*                  EXIT.
*                ENDIF.
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
                READ TABLE it_xml_table_xst INTO wa_xml_table_xst INDEX v_contcte.
                REFRESH gt_xml_cte.
                REFRESH gt_return.

                CALL FUNCTION 'SMUM_XML_PARSE'
                  EXPORTING
                    xml_input = wa_xml_table_xst
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
                ENDIF.

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
            lwa_return-descr = TEXT-013.
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
*&      Form  F_CONVERT_STRING_TO_XSTRING
*&---------------------------------------------------------------------*
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

ENDFORM. " F_CONVERT_STRING_TO_XSTRING
*&---------------------------------------------------------------------*
*&      Form  F_QUAZARIS_CARGA
*&---------------------------------------------------------------------*
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
          CONCATENATE TEXT-006 p_chave INTO wa_return-descr.
          APPEND wa_return TO p_ret.
          p_erro = abap_true.
        ELSE.
          APPEND LINES OF lt_return TO p_ret.
          wa_return-retnr = p_tpdoc.
          CONCATENATE TEXT-010 p_chave INTO wa_return-descr.
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
          CONCATENATE TEXT-007 p_chave INTO wa_return-descr.
          APPEND wa_return TO p_ret.
          p_erro = abap_true.
        ELSE.
          APPEND LINES OF lt_return TO p_ret.
          wa_return-retnr = p_tpdoc.
          CONCATENATE TEXT-011 p_chave INTO wa_return-descr.
          APPEND wa_return TO p_ret.
          CLEAR wa_return-descr.
          wa_return-descr = TEXT-015.
          APPEND wa_return TO p_ret.
        ENDIF.
    ENDCASE.

    REFRESH gt_xml_data_aux.
    REFRESH lt_msgdata.
    REFRESH lt_return.
  ENDIF.
***RRO 10/04/2019 <<--
*--------------------------------------------------------------------*

ENDFORM. " F_QUAZARIS_CARGA
*&---------------------------------------------------------------------*
*&      Form  F_GRAVA_FATURA
*&---------------------------------------------------------------------*
*       text
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

ENDFORM. " F_GRAVA_FATURA
*&---------------------------------------------------------------------*
*&      Form  ESTORNA_DOCUMENTOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_CHAVE  text
*----------------------------------------------------------------------*
FORM estorna_documentos.


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

FORM estorna_individual USING p_chave.

  IF p_chave IS NOT INITIAL.
* Executa Limpa Chave
    SUBMIT zhms_limpa_chave WITH v_chave = p_chave
                            EXPORTING LIST TO MEMORY
                            AND RETURN.

* Executa Exclui Chave
    SUBMIT zhms_exclui_chave WITH p_chave = p_chave
                            EXPORTING LIST TO MEMORY
                            AND RETURN.

  ENDIF.
ENDFORM.
