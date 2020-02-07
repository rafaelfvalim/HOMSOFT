*&---------------------------------------------------------------------*
*&  Include           ZHMS_REPORT_180_DIAS_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_SELECIONA_DADOS
*&---------------------------------------------------------------------*
*       Seleções nas tabelas
*----------------------------------------------------------------------*
FORM f_seleciona_dados .
  RANGES: r_cfops FOR zhms_tb_cfop180-cfop.
  REFRESH it_status.
  REFRESH t_docnum.

*** Monta range CFOP's permitidos
  SELECT * FROM zhms_tb_cfop180
     INTO TABLE t_cfop180.
  LOOP AT t_cfop180.
    r_cfops-sign = 'I'.
    r_cfops-option = 'EQ'.
    r_cfops-low = t_cfop180-cfop.
    APPEND r_cfops.
  ENDLOOP.

*** Seleciona status de alerta de dias
  SELECT * FROM zhms_tb_confg180
     INTO TABLE it_status.

  SELECT * FROM zhms_tb_doc180
     INTO TABLE t_docnum.

**** Busca notas de envio
  zhmscl_180_uitls=>get_notas_envio( EXPORTING r_docdat = s_docdat[]
                                               r_pstdat = s_pstdat[]
                                               r_parid  = s_parid[]
                                               r_nfenum = s_nfenum[]
                                     IMPORTING it_doc = it_doc
                                               it_lin = it_lin ).

**** Busca notas de envio contidas no de-para zhms_tb_doc180
*  zhmscl_180_uitls=>get_notas_envio_by_cfop( CHANGING it_doc = it_doc
*                                                      it_lin = it_lin ).

**** Deixa apenas cfops permitidos
  IF r_cfops IS NOT INITIAL.
    DELETE it_lin WHERE cfop NOT IN r_cfops.
  ENDIF.

  IF it_lin[] IS NOT INITIAL.
    SORT it_lin BY docnum itmnum.

*** Buscar dados de retorno - por cabeçalho
    zhmscl_180_uitls=>get_notas_ret_cabecalho( EXPORTING it_lin = it_lin[]
                                               IMPORTING it_doc_ret = it_doc_ret_cab[]
                                                         it_lin_ret = it_lin_ret_cab[] ).
*** Buscar dados de retorno - por item
    zhmscl_180_uitls=>get_notas_ret_item( EXPORTING it_lin = it_lin[]
                                          IMPORTING it_doc_ret = it_doc_ret_itm[]
                                                    it_lin_ret = it_lin_ret_itm[] ).
  ELSE.
    "Não foi encontrado nenhum registro.
    MESSAGE s398(00) WITH text-e01 DISPLAY LIKE c_e.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM. " F_SELECIONA_DADOS
*&---------------------------------------------------------------------*
*&      Form  F_TRATA_DADOS
*&---------------------------------------------------------------------*
*       Trata os dados para saída em ALV
*----------------------------------------------------------------------*
FORM f_trata_dados .
  FIELD-SYMBOLS: <fs_lin> TYPE j_1bnflin,
                 <fs_doc> TYPE j_1bnfdoc,
                 <fs_alv> TYPE ty_alv,
                 <fs_alv_aux> TYPE ty_alv,
                 <fs_lin_ret_cab> TYPE j_1bnflin,
                 <fs_doc_ret_cab> TYPE j_1bnfdoc,
                 <fs_lin_ret_itm> TYPE j_1bnflin,
                 <fs_doc_ret_itm> TYPE j_1bnfdoc.
  DATA:
                wa_lin         TYPE j_1bnflin,
                lv_is_cab      TYPE flag,
                lv_is_itm      TYPE flag,
                lv_last_mat    TYPE mara-matnr,
                it_alv_aux     TYPE TABLE OF ty_alv,
                wa_alv         TYPE  ty_alv,
                wa_alv_aux     TYPE  ty_alv.

  REFRESH: it_alv.
  CLEAR: lv_is_cab, lv_is_itm.
*---------------------------------------------------------------------------
*** Macro - Monta dados do envio
*---------------------------------------------------------------------------
  DEFINE monta_colunas_envio.
    UNASSIGN <fs_doc>.
    READ TABLE it_doc ASSIGNING <fs_doc>
      WITH KEY docnum = <fs_lin>-docnum.
     IF sy-subrc EQ 0.
      "DOC TO ALV
      <fs_alv>-docnum = <fs_doc>-docnum. "Nº Documento
      <fs_alv>-nfenum = <fs_doc>-nfenum. "Nº NF-e
      <fs_alv>-docdat = <fs_doc>-docdat. "Dt. Documento
      "LIN TO ALV
      <fs_alv>-matnr  = <fs_lin>-matnr. "Nº Material
      <fs_alv>-itmnum = <fs_lin>-itmnum."Nº Item
      <fs_alv>-maktx  = <fs_lin>-maktx. "Descrição Mat.
      <fs_alv>-menge  = <fs_lin>-menge. "Quantidade
     ELSE.
       CONTINUE.
     ENDIF.
  END-OF-DEFINITION.

  LOOP AT it_lin ASSIGNING <fs_lin>.
*---------------------------------------------------------------------------
*** Monta dados do envio/retorno das notas por item.
*---------------------------------------------------------------------------
    CLEAR: lv_is_itm, lv_is_cab.
    UNASSIGN <fs_alv>.
    LOOP AT it_lin_ret_itm ASSIGNING <fs_lin_ret_itm> WHERE docref = <fs_lin>-docnum
                                                        AND itmref = <fs_lin>-itmnum.
      lv_is_itm = 'X'.
      APPEND INITIAL LINE TO it_alv ASSIGNING <fs_alv>.
      "Macro de montagem do envio
      monta_colunas_envio.

      <fs_alv>-docref = <fs_lin_ret_itm>-docnum."Doc. Referência
      <fs_alv>-itmref = <fs_lin_ret_itm>-itmref."Item Referência
      <fs_alv>-menge_d = <fs_lin_ret_itm>-menge."Qtde Devolvida
      <fs_alv>-menge_pend = <fs_lin>-menge - <fs_lin_ret_itm>-menge ."Qtde Pendente

      READ TABLE it_doc_ret_itm ASSIGNING <fs_doc_ret_itm>
                                 WITH KEY docnum = <fs_lin_ret_itm>-docnum.
      IF sy-subrc EQ 0.
        <fs_alv>-nfenum_d = <fs_doc_ret_itm>-nfenum."Nº NF-e Devolução
        <fs_alv>-docdat_d = <fs_doc_ret_itm>-docdat."Dt. Doc. Devolução
        <fs_alv>-dias = zhmscl_180_uitls=>calcula_dias_atraso( menge = <fs_alv>-menge
                                                               menge_d = <fs_alv>-menge_d
                                                               begda = sy-datum
                                                               endda = <fs_doc_ret_itm>-docdat ). "Dias de atraso

        <fs_alv>-status_id = zhmscl_180_uitls=>get_status_dias_atraso( it_status = it_status
                                                                       dias = <fs_alv>-dias )."Icone do status
      ENDIF.

      <fs_alv>-notadev = zhmscl_180_uitls=>get_satus_nota( menge = <fs_alv>-menge_pend
                                                           docref = <fs_alv>-docref )."Satus da nota
    ENDLOOP.
*---------------------------------------------------------------------------
*** Monta dados de envio de notas sem retorno
*---------------------------------------------------------------------------
    UNASSIGN: <fs_doc_ret_cab>,
              <fs_lin_ret_itm>,
              <fs_doc>.
    READ TABLE it_lin_ret_itm ASSIGNING <fs_lin_ret_itm> WITH KEY docref = <fs_lin>-docnum
                                                                  itmref = <fs_lin>-itmnum.
    IF sy-subrc EQ 0.
      lv_is_itm = 'X'.
    ENDIF.

    LOOP AT it_doc_ret_cab ASSIGNING <fs_doc_ret_cab> WHERE docref = <fs_lin>-docnum.
      CLEAR wa_lin.
      wa_lin = zhmscl_180_uitls=>select_ret_cab_by_fields( docnum = <fs_doc_ret_cab>-docnum
                                                           it_lin = it_lin_ret_cab
                                                           matnr = <fs_lin>-matnr
                                                           maktx = <fs_lin>-maktx ).
      IF wa_lin IS INITIAL.
        CONTINUE.
      ELSE.
        lv_is_cab = 'X'.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF lv_is_cab IS INITIAL AND lv_is_itm IS INITIAL.
      APPEND INITIAL LINE TO it_alv ASSIGNING <fs_alv>.
      "Macro de montagem do envio
      monta_colunas_envio.

      <fs_alv>-menge_pend = <fs_lin>-menge. "Qtde Pendente
      "Satus da nota devolvida
      <fs_alv>-notadev = zhmscl_180_uitls=>get_satus_nota( menge = <fs_alv>-menge_pend
                                                           docref = <fs_alv>-docref ).
      "Dias de atraso
      <fs_alv>-dias = zhmscl_180_uitls=>calcula_dias_atraso( menge = <fs_alv>-menge
                                                             menge_d = <fs_alv>-menge_d
                                                             begda = sy-datum
                                                             endda = <fs_alv>-docdat ).
      "Icone do status
      <fs_alv>-status_id = zhmscl_180_uitls=>get_status_dias_atraso( it_status = it_status
                                                                     dias = <fs_alv>-dias ).
    ENDIF.
  ENDLOOP.
*---------------------------------------------------------------------------
*** Monta dados de envio/retorno das notas por cabeçalho
*---------------------------------------------------------------------------
  UNASSIGN: <fs_doc_ret_cab>,
            <fs_lin_ret_cab>,
            <fs_lin>.
  LOOP AT it_doc_ret_cab ASSIGNING <fs_doc_ret_cab>.
    LOOP AT it_lin_ret_cab ASSIGNING <fs_lin_ret_cab>
                               WHERE docnum = <fs_doc_ret_cab>-docnum.
      CLEAR wa_lin.

      "Seleciona estrutura baseado em matr maktx itmnum
      wa_lin = zhmscl_180_uitls=>select_ret_cab_by_fields( docnum = <fs_doc_ret_cab>-docref
                                                           it_lin = it_lin
                                                           matnr = <fs_lin_ret_cab>-matnr
                                                           maktx = <fs_lin_ret_cab>-maktx ).
      IF wa_lin IS INITIAL.
        CONTINUE.
      ELSE.
        ASSIGN wa_lin TO <fs_lin>.
      ENDIF.

      APPEND INITIAL LINE TO it_alv ASSIGNING <fs_alv>.
      monta_colunas_envio.
      <fs_alv>-itmref = <fs_lin_ret_cab>-itmref."Item Referência
      <fs_alv>-menge_d = <fs_lin_ret_cab>-menge."Qtde Devolvida
      <fs_alv>-docref = <fs_doc_ret_cab>-docnum."Doc. Referência
      <fs_alv>-nfenum_d = <fs_doc_ret_cab>-nfenum."Nº NF-e Devolução
      <fs_alv>-docdat_d = <fs_doc_ret_cab>-docdat."Dt. Doc. Devolução
      <fs_alv>-menge_pend = <fs_lin>-menge - <fs_lin_ret_cab>-menge. "Qtde Pendente

      "Satus da nota devolvida
      <fs_alv>-notadev = zhmscl_180_uitls=>get_satus_nota( menge = <fs_alv>-menge_pend
                                                           docref = <fs_alv>-docref ).
      "Dias de atraso
      <fs_alv>-dias = zhmscl_180_uitls=>calcula_dias_atraso( menge = <fs_alv>-menge
                                                             menge_d = <fs_alv>-menge_d
                                                             begda = sy-datum
                                                             endda = <fs_alv>-docdat ).
      "Icone do status
      <fs_alv>-status_id = zhmscl_180_uitls=>get_status_dias_atraso( it_status = it_status
                                                                    dias = <fs_alv>-dias ).
    ENDLOOP.
  ENDLOOP.
*---------------------------------------------------------------------------
*** Ajusta quantidade pendente VS entregas de um mesmo docnum
*---------------------------------------------------------------------------
  SORT it_alv BY matnr.
  DATA: lv_meng_pend TYPE i,
        lv_meng_dev  TYPE i,
        lv_meng_total TYPE i,
        lv_idx TYPE sy-tabix.
  it_alv_aux[] = it_alv[].
"Seta a flag de sucesso nos itens ja devolvidos
  LOOP AT it_alv ASSIGNING <fs_alv> WHERE docref IS NOT INITIAL.
    CLEAR: lv_meng_pend, lv_meng_dev.
    LOOP AT it_alv_aux ASSIGNING <fs_alv_aux> WHERE docnum EQ <fs_alv>-docnum
                                                AND nfenum EQ <fs_alv>-nfenum
                                                AND matnr  EQ <fs_alv>-matnr
                                                AND maktx  EQ <fs_alv>-maktx
                                                AND itmnum EQ <fs_alv>-itmnum.
      IF <fs_alv_aux>-menge_d IS NOT INITIAL.
         ADD <fs_alv_aux>-menge_pend TO lv_meng_pend.
         ADD <fs_alv_aux>-menge_d to lv_meng_dev.
      ENDIF.
    ENDLOOP.
    IF <fs_alv>-menge_pend EQ '0'.
      CONTINUE.
    ENDIF.
    IF lv_meng_dev >= <fs_alv>-menge.
      "Satus da nota devolvida
      <fs_alv>-notadev = zhmscl_180_uitls=>ico_escrok.
    ENDIF.
  ENDLOOP.
  "Faz o arremate limpando os demais dados
  wa_alv_aux-menge_pend = 0.
  MODIFY it_alv FROM wa_alv_aux
        TRANSPORTING menge_pend
                     dias
                     status_id
               WHERE notadev = zhmscl_180_uitls=>ico_escrok.

  "Ajusta quantidades pendentes de forma agrupada por item
  "dos itens que não foram concluidos.
  CLEAR: lv_meng_pend,lv_idx, it_alv_aux[].
  UNASSIGN: <fs_alv>, <fs_alv_aux>.

  it_alv_aux[] = it_alv[].
  SORT it_alv_aux BY matnr ASCENDING
                    docref ASCENDING.
  SORT it_alv BY matnr ASCENDING
                 docref ASCENDING.

  LOOP AT it_alv ASSIGNING <fs_alv> WHERE docref IS NOT INITIAL.
    CLEAR: lv_meng_pend, lv_idx.
    lv_meng_total = <fs_alv>-menge.

    LOOP AT it_alv_aux ASSIGNING <fs_alv_aux> WHERE docnum EQ <fs_alv>-docnum
                                                AND nfenum EQ <fs_alv>-nfenum
                                                AND matnr  EQ <fs_alv>-matnr
                                                AND maktx  EQ <fs_alv>-maktx
                                                AND itmnum EQ <fs_alv>-itmnum.
      lv_idx = sy-tabix.
      IF <fs_alv_aux>-notadev NE zhmscl_180_uitls=>ico_escrok
                             AND <fs_alv_aux>-menge_d IS NOT INITIAL.

        <fs_alv_aux>-menge_pend  = lv_meng_total - <fs_alv_aux>-menge_d.
        lv_meng_total = lv_meng_total - <fs_alv_aux>-menge_d.
        MODIFY it_alv INDEX lv_idx
                       FROM <fs_alv_aux>
               TRANSPORTING menge_pend.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  IF p_retur EQ 'X'.
    DELETE it_alv WHERE docref IS NOT INITIAL.
  ENDIF.

  SORT it_alv BY DOCNUM DESCENDING.

ENDFORM.                    " F_TRATA_DADOS
*&---------------------------------------------------------------------*
*&      Form  F_EXIBE_ALV
*&---------------------------------------------------------------------*
*       Exibe o ALV
*----------------------------------------------------------------------*
FORM f_exibe_alv .

  DATA: vl_backgr TYPE flag.

  IF it_alv[] IS INITIAL.
    "Não foi encontrado nenhum registro.
    MESSAGE s398(00) WITH text-e01 DISPLAY LIKE c_e.
    LEAVE LIST-PROCESSING.
  ELSE.
    SORT it_alv ASCENDING.
    DELETE ADJACENT DUPLICATES FROM it_alv COMPARING ALL FIELDS.
  ENDIF.

  IF sy-batch IS NOT INITIAL.
    vl_backgr = abap_true.
  ENDIF.

  TRY.
      CALL METHOD cl_salv_table=>factory
        EXPORTING
          list_display = vl_backgr
        IMPORTING
          r_salv_table = v_alv
        CHANGING
          t_table      = it_alv.

    CATCH cx_salv_msg .
  ENDTRY.

  "Ajusta as colunas automaticamente
  v_cols = v_alv->get_columns( ).
  v_cols->set_optimize( abap_true ).

*** Botões do ALV
  v_func = v_alv->get_functions( ).
  v_func->set_all( abap_true ).

  PERFORM f_ajusta_colunas.

*** Exibe o ALV
  v_alv->display( ).

ENDFORM.                    " F_EXIBE_ALV
*&---------------------------------------------------------------------*
*&      Form  F_AJUSTA_COLUNAS
*&---------------------------------------------------------------------*
*       Ajusta colunas do ALV
*----------------------------------------------------------------------*
FORM f_ajusta_colunas .

  TRY.
      v_cols = v_alv->get_columns( ).
      v_col ?= v_cols->get_column( 'NOTADEV' ).

      v_col->set_long_text( 'Nota Devolvida' ).
      v_col->set_medium_text( 'Nota Devolvida' ).
      v_col->set_short_text( 'Nota Dev.' ).
*--------------------------------------------------------------------*
      v_cols = v_alv->get_columns( ).
      v_col ?= v_cols->get_column( 'STATUS_ID' ).

      v_col->set_long_text( 'Status Dias' ).
      v_col->set_medium_text( 'Status Dias' ).
      v_col->set_short_text( 'Stat. Dias' ).
*--------------------------------------------------------------------*
      v_cols = v_alv->get_columns( ).
      v_col ?= v_cols->get_column( 'NFENUM' ).

      v_col->set_long_text( 'Nº NF-e' ).
      v_col->set_medium_text( 'Nº NF-e' ).
      v_col->set_short_text( 'Nº NF-e' ).
*--------------------------------------------------------------------*
      v_cols = v_alv->get_columns( ).
      v_col ?= v_cols->get_column( 'NFENUM_D' ).

      v_col->set_long_text( 'NF-e Devolução' ).
      v_col->set_medium_text( 'NF-e Devolução' ).
      v_col->set_short_text( 'NF-e Devol' ).
*--------------------------------------------------------------------*
      v_cols = v_alv->get_columns( ).
      v_col ?= v_cols->get_column( 'MENGE_D' ).

      v_col->set_long_text( 'Qtd Devolvida' ).
      v_col->set_medium_text( 'Qtd Devolvida' ).
      v_col->set_short_text( 'Qtd. Devol' ).
*--------------------------------------------------------------------*
      v_cols = v_alv->get_columns( ).
      v_col ?= v_cols->get_column( 'MENGE_PEND' ).

      v_col->set_long_text( 'Qtd Pendente' ).
      v_col->set_medium_text( 'Qtd Pendente' ).
      v_col->set_short_text( 'Qtd Penden' ).
*--------------------------------------------------------------------*
      v_cols = v_alv->get_columns( ).
      v_col ?= v_cols->get_column( 'DIAS' ).

      v_col->set_long_text( 'Dias' ).
      v_col->set_medium_text( 'Dias' ).
      v_col->set_short_text( 'Dias' ).
*--------------------------------------------------------------------*

    CATCH cx_salv_not_found.
  ENDTRY.

ENDFORM.                    " F_AJUSTA_COLUNAS
