*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_RULERF02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_MAP_INICIALIZA_VARIAVEIS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_map_inicializa_variaveis TABLES  t_msgdata
                                        t_msgatrb
                                 USING  codmp
                                        funct
                                        flowd.

* Codigo de Mapeamento
  v_codmp = codmp.

* Função para mapeamento
  v_funct = funct.

* Etapa do fluxo
  v_flowd = flowd.
  CONDENSE v_flowd NO-GAPS.

* Verifica estrutura dos dados recebidos
  IF v_codmp IS INITIAL.
    RAISE mapping_not_found.
  ENDIF.

  REFRESH: it_dyntabs, it_dynvars.
  CLEAR: wa_dyntabs, wa_dynvars.


ENDFORM.                    " F_MAP_INICIALIZA_VARIAVEIS
*&---------------------------------------------------------------------*
*&      Form  F_SELECIONA_MAPEAMENTO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_seleciona_mapeamento .
* Check de chave
  CHECK: v_codmp IS NOT INITIAL.

* Limpeza de variáveis
  CLEAR: wa_mapping.
  REFRESH: it_mapdata_aux.

* Seleção de Mapeamento
  SELECT SINGLE *
    INTO wa_mapping
    FROM zhms_tb_mapping
   WHERE codmp EQ v_codmp.

* Verifica dados encontrados
  IF wa_mapping IS INITIAL.
    RAISE mapping_not_found.
  ENDIF.

*  CHECK v_critc IS INITIAL.
* Seleção dos dados de mapeamento
  SELECT *
    INTO TABLE it_mapdata_aux
    FROM zhms_tb_mapdata
   WHERE codmp EQ v_codmp.

* Verifica dados encontrados
  IF it_mapdata_aux[] IS INITIAL.
    RAISE mapping_data_not_found.
  ELSE.
*    REFRESH it_mapdata[].
    LOOP AT it_mapdata_aux INTO wa_mapdata.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = wa_mapdata-seqnr
        IMPORTING
          output = wa_mapdata-seqnr.

      APPEND wa_mapdata TO it_mapdata.
    ENDLOOP.
  ENDIF.

** ordena para que o mapeamento seja feito conforme sequencia cadastrada
  SORT it_mapdata BY codmp ASCENDING
                     seqnr ASCENDING.

ENDFORM.                    " F_SELECIONA_MAPEAMENTO

*---------------------------------------------------------------------*
*   Form  F_PREPARA_VARIAVEIS
*---------------------------------------------------------------------*
*    Prepara as variáveis dinamicas que serão utilizadas no mapeamento
*----------------------------------------------------------------------*
FORM f_prepara_variaveis .

  REFRESH: it_dokumentation,
           it_exception_list,
           it_export_parameter,
           it_import_parameter,
           it_changing_parameter,
           it_tables_parameter.

*Identifica qual processo será executado
* Função
  IF NOT v_funct IS INITIAL.
*   Recupera as informações sobre a função que será executada

    CALL FUNCTION 'FUNCTION_IMPORT_DOKU'
      EXPORTING
        funcname           = v_funct
      TABLES
        dokumentation      = it_dokumentation
        exception_list     = it_exception_list
        export_parameter   = it_export_parameter
        import_parameter   = it_import_parameter
        changing_parameter = it_changing_parameter
        tables_parameter   = it_tables_parameter
      EXCEPTIONS
        error_message      = 1
        function_not_found = 2
        invalid_name       = 3
        OTHERS             = 4.

    IF sy-subrc NE 0.
*     Implement suitable error handling here
    ENDIF.

* Adiciona os parametros de importação para criação
    LOOP AT it_import_parameter INTO wa_import_parameter.
      CLEAR wa_dynvars.
      wa_dynvars-field = wa_import_parameter-parameter.
      IF NOT wa_import_parameter-dbfield IS INITIAL.
        wa_dynvars-fldtp = wa_import_parameter-dbfield.
      ELSE.
        wa_dynvars-fldtp = wa_import_parameter-typ.
      ENDIF.
      APPEND wa_dynvars TO it_dynvars.
    ENDLOOP.

* Adiciona os parametros de exportação para criação
    LOOP AT it_export_parameter INTO wa_export_parameter.
      CLEAR wa_dynvars.
      wa_dynvars-field = wa_export_parameter-parameter.
      IF NOT wa_export_parameter-dbfield IS INITIAL.
        wa_dynvars-fldtp = wa_export_parameter-dbfield.
      ELSE.
        wa_dynvars-fldtp = wa_export_parameter-typ.
      ENDIF.
      APPEND wa_dynvars TO it_dynvars.

**    Registrar em tabela de resultados posterior registro de mneumonicos e documentos
      CLEAR: wa_result.
      wa_result-flowd     = v_flowd.
      wa_result-parameter = wa_export_parameter-parameter.
      APPEND wa_result TO it_result.

    ENDLOOP.

* Adiciona os parametros de modificação para criação
    LOOP AT it_changing_parameter INTO wa_changing_parameter.
      CLEAR wa_dynvars.
      wa_dynvars-field = wa_changing_parameter-parameter.
      IF NOT wa_changing_parameter-dbfield IS INITIAL.
        wa_dynvars-fldtp = wa_changing_parameter-dbfield.
      ELSE.
        wa_dynvars-fldtp = wa_changing_parameter-typ.
      ENDIF.
      APPEND wa_dynvars TO it_dynvars.
    ENDLOOP.

* Adiciona as tabelas para criação
    LOOP AT it_tables_parameter INTO wa_tables_parameter.
      CLEAR wa_dyntabs.
      wa_dyntabs-field = wa_tables_parameter-parameter.

      IF NOT wa_tables_parameter-dbstruct IS INITIAL.
        wa_dyntabs-fldtp = wa_tables_parameter-dbstruct.
      ELSE.
        wa_dyntabs-fldtp = wa_tables_parameter-typ.
      ENDIF.

      APPEND wa_dyntabs TO it_dyntabs.
    ENDLOOP.

  ENDIF.

ENDFORM.                    " F_PREPARA_VARIAVEIS
*&---------------------------------------------------------------------*
*&      Form  F_TRATA_CODIGO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_trata_codigo.
  CLEAR wa_scode.

* Indicação de código gerado dinamicamente para SubPool

* Código Randomico para evitar repetições
  ADD 1 TO v_uniq_i.
  v_uniq_c = v_uniq_i.

*  Declaração da variáveis encontradas
*  Tabelas Internas
  LOOP AT it_dyntabs INTO wa_dyntabs.

*   Tabela
    CLEAR v_varname.
    CONCATENATE 'ITD' v_flowd '_' wa_dyntabs-field INTO v_varname.
    CONDENSE v_varname NO-GAPS.

    CLEAR wa_scode.
    CONCATENATE 'DATA' v_varname 'TYPE TABLE OF' wa_dyntabs-fldtp '.' INTO wa_scode SEPARATED BY space.
    APPEND wa_scode TO it_scode_vars.

*   Work Area para a tabela
    CLEAR wa_scode.
    CONCATENATE 'WAD' v_flowd '_' wa_dyntabs-field INTO wa_scode.
    CONDENSE wa_scode NO-GAPS.

    CONCATENATE 'DATA' wa_scode 'TYPE' wa_dyntabs-fldtp '.' INTO wa_scode SEPARATED BY space.
    APPEND wa_scode TO it_scode_vars.

  ENDLOOP.

* Variáveis e WorkAreas da função
  LOOP AT it_dynvars INTO wa_dynvars.

*   Variáveis
    CLEAR wa_scode.
    CONCATENATE 'VD' v_flowd '_' wa_dynvars-field INTO v_varname.
    CONDENSE v_varname NO-GAPS.

    CLEAR wa_scode.
    CONCATENATE 'DATA' v_varname 'TYPE' wa_dynvars-fldtp '.' INTO wa_scode SEPARATED BY space.
    APPEND wa_scode TO it_scode_vars.


  ENDLOOP.

* Inicio do FORM gerado
  CONCATENATE 'f_executa_mapeamento_' v_codmp '_' v_uniq_c INTO v_srotine.
  CONDENSE v_srotine NO-GAPS.

  CLEAR wa_performs.
  wa_performs-srotine = v_srotine.
  wa_performs-uniq_i  = v_uniq_i.
  wa_performs-codmp   = v_codmp.
  wa_performs-flowd   = v_flowd.
  wa_performs-funct   = v_funct.

  APPEND wa_performs TO it_performs.

* Código fonte do FORM
  CONCATENATE 'FORM' v_srotine ' USING p_codmp.' INTO wa_scode SEPARATED BY space.
  APPEND wa_scode TO it_scode.

* Rotina de mapeamento a ser executada
  IF NOT wa_mapping-derot IS INITIAL.
    CLEAR wa_scode.
    CONCATENATE 'PERFORM' wa_mapping-derot 'IN PROGRAM SAPLZHMS_FG_RULER USING p_codmp ''' v_flowd ''' IF FOUND.' INTO wa_scode SEPARATED BY space.
    APPEND wa_scode TO it_scode.
  ENDIF.

* Execução do fluxo mapeado.

  IF NOT v_funct IS INITIAL.

*    CLEAR wa_scode.
*    MOVE 'WAIT UP TO 30 SECONDS.' TO wa_scode.
*    APPEND wa_scode TO it_scode.


    CLEAR wa_scode.
    CONCATENATE 'CALL FUNCTION ''' v_funct '''' INTO wa_scode.
    APPEND wa_scode TO it_scode.

    IF NOT it_import_parameter[] IS INITIAL.
      APPEND 'EXPORTING' TO it_scode.
* Adiciona os parametros de importação para criação
      LOOP AT it_import_parameter INTO wa_import_parameter.

        wa_dynvars-field = wa_import_parameter-parameter.

        CLEAR wa_scode.
        CONCATENATE 'VD' v_flowd '_' wa_dynvars-field INTO v_varname.
        CONDENSE v_varname NO-GAPS.

        CLEAR wa_scode.
        CONCATENATE wa_dynvars-field '=' v_varname INTO wa_scode SEPARATED BY space.
        APPEND wa_scode TO it_scode.

      ENDLOOP.

    ENDIF.

* Adiciona os parametros de exportação para criação
    IF NOT it_export_parameter[] IS INITIAL.
      APPEND 'IMPORTING' TO it_scode.

      LOOP AT it_export_parameter INTO wa_export_parameter.

        wa_dynvars-field = wa_export_parameter-parameter.

        CLEAR wa_scode.
        CONCATENATE 'VD' v_flowd '_' wa_dynvars-field INTO v_varname.
        CONDENSE v_varname NO-GAPS.

        CLEAR wa_scode.
        CONCATENATE wa_dynvars-field '=' v_varname INTO wa_scode SEPARATED BY space.
        APPEND wa_scode TO it_scode.

      ENDLOOP.

    ENDIF.

* Adiciona os parametros de alteração para criação
    IF NOT it_changing_parameter[] IS INITIAL.
      APPEND 'CHANGING' TO it_scode.

      LOOP AT it_changing_parameter INTO wa_changing_parameter.

        wa_dynvars-field = wa_changing_parameter-parameter.

        CLEAR wa_scode.
        CONCATENATE 'VD' v_flowd '_' wa_dynvars-field INTO v_varname.
        CONDENSE v_varname NO-GAPS.

        CLEAR wa_scode.
        CONCATENATE wa_dynvars-field '=' v_varname INTO wa_scode SEPARATED BY space.
        APPEND wa_scode TO it_scode.

      ENDLOOP.

    ENDIF.

* Adiciona as tabelas para criação
    IF NOT it_tables_parameter[] IS INITIAL.
      APPEND 'TABLES' TO it_scode.

      LOOP AT it_tables_parameter INTO wa_tables_parameter.

        wa_dynvars-field = wa_export_parameter-parameter.

        CLEAR wa_scode.
        CONCATENATE 'ITD' v_flowd '_' wa_tables_parameter-parameter INTO v_varname.
        CONDENSE v_varname NO-GAPS.

        CLEAR wa_scode.
        CONCATENATE wa_tables_parameter-parameter '=' v_varname INTO wa_scode SEPARATED BY space.
        APPEND wa_scode TO it_scode.

      ENDLOOP.

    ENDIF.

    " Finalizar chamada de função
    APPEND '.' TO it_scode.

  ENDIF.

* Fim do FORM gerado
  APPEND 'ENDFORM.' TO it_scode.

ENDFORM.                    " F_TRATA_CODIGO

*&---------------------------------------------------------------------*
*&      Form  MAPPING
*&---------------------------------------------------------------------*
*   Realiza a transferencia de valores da estrutura mapeada
*   de acordo com o grupo indicado
*----------------------------------------------------------------------*
FORM f_mapping USING p_mpgrp
                     p_codmp
                     p_itmatr STRUCTURE zhms_tb_itmatr
                     p_flowd.

* Percorrer estrutura de Mapeamento para grupo indicado
  LOOP AT it_mapdata
     INTO wa_mapdata
    WHERE codmp EQ p_codmp
      AND mpgrp EQ p_mpgrp.

*   Assign para dados de origem (campo que é passado na função)
    PERFORM f_origem_field USING p_flowd.

*   Assign de valor de origem (valor identificado no FORM manual)
    PERFORM f_origem_value USING p_itmatr.

*   Transferir Valores
    PERFORM f_origem_transferir.

  ENDLOOP.

ENDFORM.                    " MAPPING

*&---------------------------------------------------------------------*
*&      Form  f_origem_field
*&---------------------------------------------------------------------*
*       Assign para dados de origem (campo que é passado na função)
*----------------------------------------------------------------------*
FORM f_origem_field USING p_flowd.

*  CONDENSE p_flowd NO-GAPS.

*  Identificação do tipo de destino
  CASE wa_mapdata-tpvar.
    WHEN 'IT'.
*       Assign para tabela interna
      CLEAR v_varname.
      CONCATENATE '(' v_protine ')ITD' p_flowd '_' wa_mapdata-tbnam INTO v_varname.
      CONDENSE v_varname NO-GAPS.

      ASSIGN: (v_varname) TO <or_table>.

*       Assign de workarea
      CLEAR v_varname.
      CONCATENATE '(' v_protine ')WAD' p_flowd '_' wa_mapdata-tbnam INTO v_varname.
      CONDENSE v_varname NO-GAPS.

      ASSIGN: (v_varname) TO <or_worka>.

*       Assign do campo da tabela
      ASSIGN COMPONENT wa_mapdata-tbfld OF STRUCTURE <or_worka> TO <or_field>.

    WHEN 'VC'.
*       Assign da variável
      CLEAR v_varname.
      CONCATENATE '(' v_protine ')VD' p_flowd '_' wa_mapdata-tbnam INTO v_varname.
      CONDENSE v_varname NO-GAPS.

      ASSIGN (wa_mapdata-tbfld) TO <or_field>.

    WHEN 'WA'.
*       Assign de workarea
      CLEAR v_varname.
      CONCATENATE '(' v_protine ')VD' p_flowd '_' wa_mapdata-tbnam INTO v_varname.
      CONDENSE v_varname NO-GAPS.

      ASSIGN: (v_varname) TO <or_worka>.

*       Assign do campo da tabela
      ASSIGN COMPONENT wa_mapdata-tbfld OF STRUCTURE <or_worka> TO <or_field>.

  ENDCASE.
ENDFORM.                    "f_origem_field

*&---------------------------------------------------------------------*
*&      Form  f_origem_value
*&---------------------------------------------------------------------*
*       Assign de valor de origem (valor identificado no FORM manual)
*----------------------------------------------------------------------*
FORM f_origem_value USING p_itmatr STRUCTURE zhms_tb_itmatr.

* Carrega Tabela de Mneumônicos
  IF p_itmatr IS INITIAL.
    READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = wa_mapdata-mneum.
  ELSEIF wa_mapdata-mneum(2) EQ 'AT'. "Tratamento de Atribuição - MNEUMONICO DERIVADO
    READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = wa_mapdata-mneum
                                               atitm = p_itmatr-atitm.
  ELSEIF wa_mapdata-mneum(2) NE 'AT'. "Tratamento de Atribuição - MNEUMONICO NAO DERIVADO
    READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = wa_mapdata-mneum
                                               dcitm = p_itmatr-dcitm
                                               atitm = p_itmatr-atitm.
    IF NOT sy-subrc IS INITIAL.
      READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = wa_mapdata-mneum
                                                 atitm = '00000'.
    ENDIF.
  ENDIF.

  IF sy-subrc IS INITIAL.
*     Assign do campo da tabela
    ASSIGN COMPONENT 'VALUE' OF STRUCTURE wa_docmn TO <or_value>.
*    Remove espaços em branco do campo string
    CONDENSE <or_value> NO-GAPS.
  ELSE.
    CLEAR v_auxiliar.
*     Assign do campo auxilixar
    ASSIGN v_auxiliar TO <or_value>.
*    Remove espaços em branco do campo string
    CONDENSE <or_value> NO-GAPS.
  ENDIF.

* Execução de Rotina
  IF NOT wa_mapdata-rotin IS INITIAL.
    IF <or_value> IS ASSIGNED.
      PERFORM (wa_mapdata-rotin) IN PROGRAM saplzhms_fg_ruler USING p_itmatr CHANGING <or_value> IF FOUND.
    ENDIF.
  ENDIF.

ENDFORM.                    "f_origem_value

*&---------------------------------------------------------------------*
*&      Form  f_mn_origem_value
*&---------------------------------------------------------------------*
*       Assign de valor de origem (valor identificado no FORM manual)
*----------------------------------------------------------------------*
FORM f_mn_origem_value USING p_itmatr STRUCTURE zhms_tb_itmatr.

*  Identificação do tipo de origem
  CASE wa_mapdata-tpvar.
    WHEN 'VC'.
*     Assign de variável
      ASSIGN (wa_mapdata-tbfld) TO <or_value>.

    WHEN 'WA'.
*     Assign de workarea
      ASSIGN: (wa_mapdata-tbnam) TO <or_worka>.

*     Assign do campo da tabela
      ASSIGN COMPONENT wa_mapdata-tbfld OF STRUCTURE <or_worka> TO <or_value>.

    WHEN OTHERS.
*     Valor Fixo
      IF NOT wa_mapdata-vlfix IS INITIAL.
        ASSIGN COMPONENT 'VLFIX' OF STRUCTURE wa_mapdata TO <or_value>.
      ENDIF.
  ENDCASE.

*     Execução de Rotina
  IF NOT wa_mapdata-rotin IS INITIAL.

    IF <or_field> IS ASSIGNED.
      ASSIGN <or_field> TO <or_value>.
    ENDIF.

    IF <or_value> IS ASSIGNED.
      PERFORM (wa_mapdata-rotin) IN PROGRAM saplzhms_fg_ruler USING p_itmatr CHANGING <or_value> IF FOUND.
    ENDIF.

  ENDIF.


ENDFORM.                    "f_mn_origem_value

*&---------------------------------------------------------------------*
*&      Form  F_ORIGEM_TRANSFERIR
*&---------------------------------------------------------------------*
*       Transferir Valores
*----------------------------------------------------------------------*
FORM f_origem_transferir .
*  Transferencia de valores

*  Identificação do tipo de origem
  CASE wa_mapdata-tpvar.

    WHEN 'VC'.
      IF <or_field> IS ASSIGNED
       AND <or_value> IS ASSIGNED.
        MOVE-CORRESPONDING <or_value> TO <or_field> .
      ENDIF.

    WHEN OTHERS.
      IF <or_field> IS ASSIGNED
       AND <or_value> IS ASSIGNED.
        MOVE <or_value> TO <or_field> .
      ENDIF.

  ENDCASE.

** Unassign de Field Symbols Usados
  IF <fs_item> IS ASSIGNED.
    UNASSIGN <fs_item>.
  ENDIF.
  IF <fs_worka> IS ASSIGNED.
    UNASSIGN <fs_worka>.
  ENDIF.
  IF <or_value> IS ASSIGNED.
    UNASSIGN <or_value>.
  ENDIF.
  IF <or_field> IS ASSIGNED.
    UNASSIGN <or_field>.
  ENDIF.
  IF <or_worka> IS ASSIGNED.
    UNASSIGN <or_worka>.
  ENDIF.

ENDFORM.                    " F_ORIGEM_TRANSFERIR

*&---------------------------------------------------------------------*
*&      Form  f_append
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_MPGRP    text
*----------------------------------------------------------------------*
FORM f_append USING p_mpgrp p_codmp p_flowd.

* Limpar vairáveis
  REFRESH it_tables.

* Percorrer estrutura de Mapeamento para grupo indicado em busca de tabelas
  LOOP AT it_mapdata
     INTO wa_mapdata
    WHERE codmp EQ p_codmp
      AND mpgrp EQ p_mpgrp.

    CLEAR wa_tables.
    wa_tables = wa_mapdata-tbnam.
    APPEND wa_tables TO it_tables.

  ENDLOOP.

* remover Tabelas duplicadas
  SORT it_tables ASCENDING.
  DELETE ADJACENT DUPLICATES FROM it_tables.

* Loop nas estruturas inserindo registros
  LOOP AT it_tables INTO wa_tables.

*   Assign para tabela interna
    CLEAR v_varname.
    CONCATENATE '(' v_protine ')ITD' p_flowd '_' wa_tables INTO v_varname.
    CONDENSE v_varname NO-GAPS.

    ASSIGN: (v_varname) TO <or_table>.

*   Assign de workarea
    CLEAR v_varname.
    CONCATENATE '(' v_protine ')WAD' p_flowd '_' wa_tables INTO v_varname.
    CONDENSE v_varname NO-GAPS.

    ASSIGN: (v_varname) TO <or_worka>.

*   Append
    IF <or_worka> IS ASSIGNED
      AND <or_worka> IS ASSIGNED.
      APPEND <or_worka> TO <or_table>.
    ENDIF.

*   Limpando FS
    IF <or_worka> IS ASSIGNED.
      UNASSIGN: <or_worka>.
    ENDIF.
    IF <or_table> IS ASSIGNED.
      UNASSIGN: <or_table>.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "f_append

*&---------------------------------------------------------------------*
*&      Form  f_mapping_mn
*&---------------------------------------------------------------------*
*       Mapeamento de Mneumônico
*----------------------------------------------------------------------*
FORM f_mapping_mn USING p_mpgrp
                        p_chave
                        p_codmp
                        p_itmatr STRUCTURE zhms_tb_itmatr.

* Variáveis locais
  DATA: vl_lastindex TYPE sy-tabix.

* Identifica o ultimo item da sequencia
  DESCRIBE TABLE it_docmn LINES vl_lastindex.
  IF vl_lastindex GT 0.
    READ TABLE it_docmn INTO wa_docmn INDEX vl_lastindex.
    v_seqmn = wa_docmn-seqnr.
  ELSE.
    v_seqmn = 0.
  ENDIF.

* Percorrer estrutura de Mapeamento para grupo indicado
  LOOP AT it_mapdata
     INTO wa_mapdata
    WHERE codmp EQ p_codmp
      AND mpgrp EQ p_mpgrp.

*   Assign de valor de origem (valor identificado no FORM manual)
    PERFORM f_mn_origem_value USING p_itmatr.

*   Assign de valor de Item (cadastrado na tabela de itens)
*    IF NOT wa_mapdata-mnitm IS INITIAL.
*      PERFORM f_mn_item using p_itmatr.
*    ENDIF.

*   Transferir Valores Para a tabela de Mneumônicos
    PERFORM f_mn_transferir USING p_chave
                                  wa_mapdata-mneum
                                  p_itmatr.

  ENDLOOP.

ENDFORM.                    "f_mapping

*&---------------------------------------------------------------------*
*&      Form  f_mn_item
*&---------------------------------------------------------------------*
*       Assign de valor de Item (cadastrado na tabela de itens)
*----------------------------------------------------------------------*
FORM f_mn_item.

* Assign de item
  ASSIGN: (wa_mapdata-tbnam) TO <fs_worka>.

* Assign do campo da tabela
  ASSIGN COMPONENT wa_mapdata-tbfld OF STRUCTURE <fs_worka> TO <fs_item>.

ENDFORM.                    "f_mn_item

*&---------------------------------------------------------------------*
*&      Form  f_mn_transferir
*&---------------------------------------------------------------------*
*       Transferir Valores Para a tabela de Mneumônicos
*----------------------------------------------------------------------*
FORM f_mn_transferir USING p_chave
                           p_mneum
                           p_itmatr STRUCTURE zhms_tb_itmatr.

* Identifica anteriores e exclui
  DELETE it_docmn
   WHERE chave = p_chave
     AND mneum = p_mneum
     AND dcitm = p_itmatr-dcitm
     AND atitm = p_itmatr-atitm.

*  Transferencia de valores
  CLEAR wa_docmn.

  ADD 1 TO v_seqmn.

  wa_docmn-seqnr = v_seqmn. "Sequencia
  wa_docmn-chave = p_chave. "Chave
  wa_docmn-mneum = p_mneum. "Mneumonico
  wa_docmn-dcitm = p_itmatr-dcitm. "item Documento
  wa_docmn-atitm = p_itmatr-atitm. "item Atribuido (Processamento)

* Sequencia
  CONDENSE wa_docmn-seqnr NO-GAPS.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = wa_docmn-seqnr
    IMPORTING
      output = wa_docmn-seqnr.


*  IF <fs_item> IS ASSIGNED. "Caso possua Item
*    wa_docmn-dcitm = <fs_item>. "Item
*  ENDIF.

  IF <or_value> IS ASSIGNED. "Caso valor encontrado
    MOVE <or_value> TO wa_docmn-value . "Valor
  ENDIF.

** Insere na estrutura
  APPEND wa_docmn TO it_docmn.

** Unassign de Field Symbols Usados
  IF <fs_item> IS ASSIGNED.
    UNASSIGN <fs_item>.
  ENDIF.
  IF <fs_worka> IS ASSIGNED.
    UNASSIGN <fs_worka>.
  ENDIF.
  IF <or_value> IS ASSIGNED.
    UNASSIGN <or_value>.
  ENDIF.
  IF <or_field> IS ASSIGNED.
    UNASSIGN <or_field>.
  ENDIF.
  IF <or_worka> IS ASSIGNED.
    UNASSIGN <or_worka>.
  ENDIF.

ENDFORM.                    "f_mn_transferir

*&---------------------------------------------------------------------*
*&      Form  f_atr_load
*&---------------------------------------------------------------------*
*       Busca os dados de atribuição para um documento
*----------------------------------------------------------------------*
FORM f_atr_load TABLES t_itmatr STRUCTURE zhms_tb_itmatr
                 USING p_chave.

**  Seleciona os dados de atribuição
  SELECT *
    INTO TABLE t_itmatr
    FROM zhms_tb_itmatr
   WHERE chave EQ p_chave.

ENDFORM.                    "f_atr_load

*&---------------------------------------------------------------------*
*&      Form  f_tratamento_pos
*&---------------------------------------------------------------------*
*       Tratamento pós para funções que precisarem
*----------------------------------------------------------------------*----------------------------------------------*
FORM f_tratamento_pos USING p_funct p_flowd p_codmp
                      CHANGING p_err_flow.

* Variáveis locais
  FIELD-SYMBOLS: <fst_return> TYPE STANDARD TABLE.
  DATA: wl_return TYPE bapiret2,
        vl_flwst  TYPE zhms_de_flwst.




* Verifica se foi executada função
  CHECK NOT p_funct IS INITIAL.

* Identifica se o processamento aconteceu

* Assign para tabela interna
  CLEAR v_varname.
  CONCATENATE '(' v_protine ')ITD' p_flowd '_RETURN' INTO v_varname.
  CONDENSE v_varname NO-GAPS.

  ASSIGN: (v_varname) TO <fst_return>.

* Caso encontrada a tabela de return na função
  IF <fst_return> IS ASSIGNED.
*   Percorre resultados encontrados
    LOOP AT <fst_return> INTO wl_return.
      IF wl_return-type EQ 'E'.
        p_err_flow = 'X'.
      ENDIF.
    ENDLOOP.
  ENDIF.
* Verifica se foi encontrado erro.
  IF NOT p_err_flow IS INITIAL.
**  RollBack para erros
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
**  Status da etapa: Erro
    vl_flwst = 'E'.

  ELSE.
**  Commit para acertos

    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.


    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
**  Status da etapa: Concluída automaticamente
    vl_flwst = 'A'.
    CALL FUNCTION 'BUFFER_REFRESH_ALL'.
**  Registra os resultados
    PERFORM f_registra_result USING p_flowd p_codmp.

  ENDIF.

  CHECK <fst_return> IS ASSIGNED.

* Registrar LOG
  CALL FUNCTION 'ZHMS_FM_REGLOG'
    EXPORTING
      cabdoc  = wa_cabdoc
      flowd   = p_flowd
      flwst   = vl_flwst
    TABLES
      bapiret = <fst_return>.


*** Modifica pedido de compras
  IF  p_funct EQ ' BAPI_INCOMINGINVOICE_CREATE'.
*    CALL FUNCTION 'ZHMS_CHANGE_PO_REMESSA_FINAL'
*      EXPORTING
*        chave = v_chave.

*CALL FUNCTION 'CHANGE_DOCUMENT'
*  TABLES
*    t_bkdf           =
*    t_bkpf           =
*    t_bsec           =
*    t_bsed           =
*    t_bseg           =
*    t_bset           =
**   T_BSEG_ADD       =
*          .

    .
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.



  ELSEIF p_funct EQ ' BAPI_GOODSMVT_CREATE'.



    CONCATENATE '(' v_protine ')VD' p_flowd '_MATERIALDOCUMENT' INTO v_materialdocument.
    CONCATENATE '(' v_protine ')VD' p_flowd '_MATDOCUMENTYEAR' INTO v_matdocumentyear.

    CONDENSE v_materialdocument NO-GAPS.
    CONDENSE v_matdocumentyear NO-GAPS.

    ASSIGN: (v_materialdocument) TO <fst_materialdocument>.
    ASSIGN: (v_matdocumentyear) TO <fst_matdocumentyear>.


*=======================================================================
*Cenario de subcontratacao imposto para migo
*Renan Itokazo
*=======================================================================
    IF v_typed EQ 'NFE1'.
      SELECT *
        FROM mseg
        INTO TABLE it_mseg
      WHERE mblnr
        EQ <fst_materialdocument>.

      IF sy-subrc IS INITIAL.
        LOOP AT it_mseg INTO wa_mseg.
          READ TABLE ty_subcontratacao INTO wa_subcontratacao INDEX sy-tabix.
          wa_mseg-j_1bexbase = wa_subcontratacao-imposto.
          wa_mseg-lsmng = wa_subcontratacao-quantidade.
          MODIFY it_mseg FROM wa_mseg.
        ENDLOOP.

        CALL FUNCTION 'MB_CHANGE_DOCUMENT'
          TABLES
            zmkpf = it_mkpf
            zmseg = it_mseg.
      ENDIF.
    ENDIF.
*=======================================================================

***RRO 28/01/2019 Comentado HOMINE
**    DATA: w_zmm_migo_cnpj TYPE zmm_migo_cnpj.
**
**    w_zmm_migo_cnpj-cnpj = wa_cabdoc-chave+6(14).
**
**
**    w_zmm_migo_cnpj-mjahr = <fst_matdocumentyear>.
**    w_zmm_migo_cnpj-mblnr = <fst_materialdocument>.
**
**    IF p_err_flow IS INITIAL.
**      CALL FUNCTION 'ZMM_MIGO_BADI_BR_SAVE' IN UPDATE TASK
**        EXPORTING
**          iw_zmm_migo_cnpj = w_zmm_migo_cnpj.
***    ENDLOOP.
**
**    ENDIF.

*DDPT - Inicio da Alteração - Comentado a mensagem para atribuir m documento a migo
    CALL FUNCTION 'ZHMS_FM_ATTACH_FILES'
      TABLES
        docmn = it_docmn.
*DDPT - Fim da Alteração
  ENDIF.

ENDFORM.                    "f_tratamento_pos

*&---------------------------------------------------------------------*
*&      Form  f_registra_result
*&---------------------------------------------------------------------*
**      Registra os resultados
*----------------------------------------------------------------------*
FORM f_registra_result USING p_flowd p_codmp.

** Variáveis locais
  DATA: vl_tbfld TYPE zhms_de_tbfld.
*} Inicio - Inclusao por RBO
** Variaveis Globais
  DATA: vg_key_belnr TYPE j_1bnfdoc-belnr.  "
  DATA: vl_docnum    TYPE j_1bnfdoc-docnum. "
  DATA: vl_cfop      TYPE j_1bnflin-cfop.   "
  DATA: vl_nbm       TYPE j_1bnflin-nbm.    "
  DATA: vl_matorg    TYPE j_1bnflin-matorg. "
  DATA: vl_taxsit    TYPE j_1bnflin-taxsit. "
  DATA: vl_taxsit2   TYPE j_1bnflin-taxsi2. "
  DATA: vl_taxlw1    TYPE j_1bnflin-taxlw1. "
  DATA: vl_taxlw2    TYPE j_1bnflin-taxlw2. "
  DATA: vl_seq       TYPE i.                "
**
  DATA:
    ld_obj_header	       TYPE bapi_j_1bnfdoc,
    it_obj_item	         TYPE STANDARD TABLE OF bapi_j_1bnflin,
    wa_obj_item	         LIKE LINE OF it_obj_item,
    it_obj_item_tax	     TYPE STANDARD TABLE OF bapi_j_1bnfstx,
    wa_obj_item_tax	     LIKE LINE OF it_obj_item_tax,
    it_obj_partner       TYPE STANDARD TABLE OF bapi_j_1bnfnad,
    wa_obj_partner       LIKE LINE OF it_obj_partner,
    it_obj_header_msg	   TYPE STANDARD TABLE OF bapi_j_1bnfftx,
    wa_obj_header_msg	   LIKE LINE OF it_obj_header_msg,
    it_obj_refer_msg     TYPE STANDARD TABLE OF bapi_j_1bnfref,
    wa_obj_refer_msg     LIKE LINE OF it_obj_refer_msg,
    it_obj_ot_partner	   TYPE STANDARD TABLE OF bapi_j_1bnfcpd,
    wa_obj_ot_partner	   LIKE LINE OF it_obj_ot_partner,
    it_return	           TYPE STANDARD TABLE OF bapiret2,
    wa_return	           LIKE LINE OF it_return,
    it_obj_import_di     TYPE STANDARD TABLE OF bapi_j_1bnfimport_di,
    wa_obj_import_di     LIKE LINE OF it_obj_import_di,
    it_obj_import_adi	   TYPE STANDARD TABLE OF bapi_j_1bnfimport_adi,
    wa_obj_import_adi	   LIKE LINE OF it_obj_import_adi,
    it_obj_trans_volumes TYPE STANDARD TABLE OF bapi_j_1bnftransvol,
    wa_obj_trans_volumes LIKE LINE OF it_obj_trans_volumes,
    it_obj_trailer_info	 TYPE STANDARD TABLE OF bapi_j_1bnftrailer,
    wa_obj_trailer_info	 LIKE LINE OF it_obj_trailer_info,
    it_obj_trade_notes   TYPE STANDARD TABLE OF bapi_j_1bnftradenotes,
    wa_obj_trade_notes   LIKE LINE OF it_obj_trade_notes,
    it_obj_add_info	     TYPE STANDARD TABLE OF bapi_j_1bnfadd_info,
    wa_obj_add_info	     LIKE LINE OF it_obj_add_info,
    it_obj_ref_proc	     TYPE STANDARD TABLE OF bapi_j_1bnfrefproc,
    wa_obj_ref_proc	     LIKE LINE OF it_obj_ref_proc,
    it_obj_sugar_suppl   TYPE STANDARD TABLE OF bapi_j_1bnfsugarsuppl,
    wa_obj_sugar_suppl   LIKE LINE OF it_obj_sugar_suppl,
    it_obj_sugar_deduc   TYPE STANDARD TABLE OF bapi_j_1bnfsugardeduc,
    wa_obj_sugar_deduc   LIKE LINE OF it_obj_sugar_deduc,
    it_obj_vehicle       TYPE STANDARD TABLE OF bapi_j_1bnfvehicle,
    wa_obj_vehicle       LIKE LINE OF it_obj_vehicle,
    it_obj_pharmaceut	   TYPE STANDARD TABLE OF bapi_j_1bnfpharmaceut,
    wa_obj_pharmaceut	   LIKE LINE OF it_obj_pharmaceut,
    it_obj_fuel	         TYPE STANDARD TABLE OF bapi_j_1bnffuel,
    wa_obj_fuel	         LIKE LINE OF it_obj_fuel,
    it_obj_header_text   TYPE STANDARD TABLE OF bapi_j_1bnftextheader,
    wa_obj_header_text   LIKE LINE OF it_obj_header_text,
    it_obj_item_text     TYPE STANDARD TABLE OF bapi_j_1bnftextitem,
    wa_obj_item_text     LIKE LINE OF it_obj_item_text.
  DATA wa_item_ret      TYPE ty_item_bapi.
  DATA ls_header        TYPE j_1bnfdoc.
  DATA lt_partner       TYPE TABLE OF j_1bnfnad.
  DATA lt_item          TYPE TABLE OF j_1bnflin.
  DATA wa_item          TYPE j_1bnflin.
  DATA lt_item_add      TYPE TABLE OF j_1binlin.
  DATA lt_item_tax      TYPE TABLE OF j_1bnfstx.
  DATA lt_header_msg    TYPE TABLE OF j_1bnfftx.
  DATA lt_refer_msg     TYPE TABLE OF j_1bnfref.
*{ Fim - Inclusao por RBO

** Percorre tabela de resultados esperados para a execução
  LOOP AT it_result INTO wa_result WHERE flowd EQ p_flowd.

** Identificar na tabela de mneumonicos
    vl_tbfld = wa_result-parameter.
    CLEAR wa_mapdata.
    LOOP AT  it_mapdata INTO wa_mapdata WHERE codmp = p_codmp
                                          AND tbfld = vl_tbfld.

*  Identificação do tipo de origem
      CASE wa_mapdata-tpvar.
        WHEN 'VC'.
          CLEAR v_varname.
          CONCATENATE '(' v_protine ')VD' p_flowd '_' wa_result-parameter INTO v_varname.
          CONDENSE v_varname NO-GAPS.
          ASSIGN (v_varname) TO <de_value>.
        WHEN OTHERS.
*     Valor Fixo
          IF NOT wa_mapdata-vlfix IS INITIAL.
            ASSIGN COMPONENT 'VLFIX' OF STRUCTURE wa_mapdata TO <de_value>.
          ENDIF.
      ENDCASE.

** Mover para tabela de mneumonicos
      CLEAR wa_docmn.
      ADD 1 TO v_seqmn.
      wa_docmn-seqnr = v_seqmn.          "Sequencia
      wa_docmn-chave = v_chave.          "Chave
      wa_docmn-mneum = wa_mapdata-mneum. "Mneumonico
      wa_docmn-value = <de_value>.       "Valor retornado
      APPEND wa_docmn TO it_docmn.
    ENDLOOP.
  ENDLOOP.

*} Inicio incl. Proc. envio popup p/o usuario decidir alteracoes fiscais (RBO)
  READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'INVDOCNO'.

  IF sy-subrc = 0.

***Renan Itokazo
***Corrigir refresh de tela
    CLEAR: vl_docnum.
    REFRESH: ty_item_bapi_bf, ty_item_bapi, lt_item.
***

    SELECT SINGLE docnum
      FROM j_1bnfdoc
      INTO vl_docnum
     WHERE belnr = wa_docmn-value.

** Chamada BAPI para leitura de dados complementares

* Busca dados da NF
    CALL FUNCTION 'J_1B_NF_DOCUMENT_READ'
      EXPORTING
        doc_number         = vl_docnum
      IMPORTING
        doc_header         = ls_header
      TABLES
        doc_partner        = lt_partner
        doc_item           = lt_item
        doc_item_tax       = lt_item_tax
        doc_header_msg     = lt_header_msg
        doc_refer_msg      = lt_refer_msg
      EXCEPTIONS                                            "#EC FB_RC
        document_not_found = 1
        docum_lock         = 2
        OTHERS             = 3.


    IF sy-subrc EQ 0.
      CLEAR vl_seq.
      "Preenchendo tabela para enviar para o usuario
      LOOP AT lt_item INTO wa_item.
        vl_seq = vl_seq + 1.
        ty_item_bapi-seq      = vl_seq.
        ty_item_bapi-cfop     = wa_item-cfop.
        ty_item_bapi-taxlw1   = wa_item-taxlw1.
        ty_item_bapi-taxlw2   = wa_item-taxlw2.
        ty_item_bapi-taxlw4   = wa_item-taxlw4.
        ty_item_bapi-taxlw5   = wa_item-taxlw5.
        ty_item_bapi-docnum   = vl_docnum.
        ty_item_bapi-itmnum   = wa_item-itmnum.
        ty_item_bapi-nbm      = wa_item-nbm.
        ty_item_bapi-matorg   = wa_item-matorg.
        APPEND ty_item_bapi.
      ENDLOOP.

*     Guarda o resultado do popup antes de mostrar ao usuario
      ty_item_bapi_bf[] = ty_item_bapi[].

*      CALL SCREEN 0400 STARTING AT 30 3.
    ENDIF.
  ENDIF.
*{ Fim incl. - Proc. envio popup p/o usuario decidir alteracoes fiscais (RBO)
ENDFORM.                    "f_registra_result
*&---------------------------------------------------------------------*
*&      Form  ZF_UPDATE_NF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM zf_update_nf .
* Declaracao tabelas internas de parametros
  DATA:
    it_doc_item	      TYPE STANDARD TABLE OF j_1bnflin,
    it_doc_partner    TYPE STANDARD TABLE OF j_1bnfnad,
    it_doc_item_tax	  TYPE STANDARD TABLE OF j_1bnfstx,
    it_doc_header_msg	TYPE STANDARD TABLE OF j_1bnfftx,
    it_return         TYPE STANDARD TABLE OF bapiret2,
    wa_return	        LIKE LINE OF it_return,
    ld_obj_header	    TYPE bapi_j_1bnfdoc,
    it_obj_item	      TYPE STANDARD TABLE OF bapi_j_1bnflin,
    wa_obj_item       LIKE LINE OF it_obj_item,
    it_obj_item_tax	  TYPE STANDARD TABLE OF bapi_j_1bnfstx,
    wa_obj_item_tax	  LIKE LINE OF it_obj_item_tax,
    it_doc_refer_msg  TYPE STANDARD TABLE OF j_1bnfref.

* Declaracao  Work areas
  DATA:
    ld_doc_number	    TYPE j_1bnfdoc-docnum,
    ld_doc_header	    TYPE j_1bnfdoc,
    wa_doc_header	    TYPE j_1bnfdoc,
    wa_doc_item	      LIKE LINE OF it_doc_item,
    wa_doc_item_tax	  LIKE LINE OF it_doc_item_tax,
    wa_doc_header_msg	LIKE LINE OF it_doc_header_msg,
    wa_doc_refer_msg  LIKE LINE OF it_doc_refer_msg.

  DATA: ls_header     TYPE j_1bnfdoc.
  DATA: ls_header_add TYPE j_1bindoc.

  DATA lt_partner    TYPE TABLE OF j_1bnfnad.
  DATA lt_item       TYPE TABLE OF j_1bnflin.
  DATA wa_item       TYPE j_1bnflin.
  DATA lt_item_add   TYPE TABLE OF j_1binlin.
  DATA lt_item_tax   TYPE TABLE OF j_1bnfstx.
  DATA lt_header_msg TYPE TABLE OF j_1bnfftx.
  DATA lt_refer_msg  TYPE TABLE OF j_1bnfref.
  DATA vl_index TYPE i.

* Verificar se o usuario alterou algum campo
  READ TABLE ty_item_bapi INTO wa_item_ret INDEX 1.
  ld_doc_header-docnum = wa_item_ret-docnum.
  ld_doc_number        = wa_item_ret-docnum.

  CALL FUNCTION 'J_1B_NF_DOCUMENT_READ'
    EXPORTING
      doc_number         = wa_item_ret-docnum
    IMPORTING
      doc_header         = ls_header
    TABLES
      doc_partner        = lt_partner
      doc_item           = lt_item
      doc_item_tax       = lt_item_tax
      doc_header_msg     = lt_header_msg
      doc_refer_msg      = lt_refer_msg
    EXCEPTIONS                                              "#EC FB_RC
      document_not_found = 1
      docum_lock         = 2
      OTHERS             = 3.
* Prepara estruturas para Alterar a NF

  LOOP AT lt_item INTO wa_item.
    vl_index = vl_index + 1.
    READ TABLE ty_item_bapi INTO wa_item_ret WITH KEY docnum = wa_item-docnum
                                                      itmnum = wa_item-itmnum.
    IF sy-subrc = 0.
      IF wa_item-matorg    NE wa_item_ret-matorg.
        wa_item-matorg    = wa_item_ret-matorg.
      ENDIF.

      IF wa_item-nbm    NE wa_item_ret-nbm.
        wa_item-nbm    = wa_item_ret-nbm.
      ENDIF.

      IF wa_item-cfop   NE wa_item_ret-cfop.
        wa_item-cfop   = wa_item_ret-cfop.
      ENDIF.

      IF wa_item-taxlw1 NE wa_item_ret-taxlw1.
        wa_item-taxlw1 = wa_item_ret-taxlw1.
      ENDIF.

      IF wa_item-taxlw2 NE wa_item_ret-taxlw2.
        wa_item-taxlw2 = wa_item_ret-taxlw2.
      ENDIF.

      IF wa_item-taxlw4 NE wa_item_ret-taxlw4.
        wa_item-taxlw4 = wa_item_ret-taxlw4.
      ENDIF.

      IF wa_item-taxlw5 NE wa_item_ret-taxlw5.
        wa_item-taxlw5 = wa_item_ret-taxlw5.
      ENDIF.

      MODIFY lt_item FROM wa_item INDEX vl_index.
      CLEAR wa_item.
      CLEAR wa_item_ret.
    ENDIF.
*  ENDIF.
  ENDLOOP.

* Executa a alteracao NF

* Chamada da BAPI para atualizar dados da NF
  CALL FUNCTION 'J_1B_NF_DOCUMENT_UPDATE'
    EXPORTING
      doc_number            = ld_doc_number
      doc_header            = ls_header
    TABLES
      doc_partner           = lt_partner
      doc_item              = lt_item
      doc_item_tax          = lt_item_tax
      doc_header_msg        = lt_header_msg
      doc_refer_msg         = lt_refer_msg
    EXCEPTIONS
      document_not_found    = 1
      update_problem        = 2
      doc_number_is_initial = 3.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

  IF sy-subrc EQ 0.
    "All OK
  ELSEIF sy-subrc EQ 1. "Exception
    "Add code for exception here
  ELSEIF sy-subrc EQ 2. "Exception
    "Add code for exception here
  ELSEIF sy-subrc EQ 3. "Exception
    "Add code for exception here
  ENDIF.

ENDFORM.                    " ZF_UPDATE_NF
" ZF_UPDATE_SUB
