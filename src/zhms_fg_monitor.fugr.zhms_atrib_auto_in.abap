FUNCTION zhms_atrib_auto_in.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(CHAVE) TYPE  CHAR44
*"     VALUE(NATDC) TYPE  ZHMS_DE_NATDC
*"     VALUE(TYPED) TYPE  ZHMS_DE_TYPED
*"  EXPORTING
*"     VALUE(VL_ERRO) TYPE  FLAG
*"----------------------------------------------------------------------

  DATA: wa_mapping     TYPE zhms_tb_mapping,
          it_mapdata_aux TYPE STANDARD TABLE OF zhms_tb_mapdata,
          it_mapdata     TYPE STANDARD TABLE OF zhms_tb_mapdata,
          wa_mapdata     TYPE zhms_tb_mapdata.

  DATA: vl_atr_atprc TYPE zhms_de_atprc,
        vl_atr_atqtd TYPE zhms_de_atqtd,
        vl_pre_atprc TYPE zhms_de_atprc,
        vl_pre_atqtd TYPE zhms_de_atqtd,
        vl_qtd_atr   TYPE sy-tabix,
        vl_index     TYPE sy-tabix.

  DATA: vl_seqnr     TYPE zhms_de_seqnr,
        wl_ekpo      TYPE ekpo,
        tl_ekpo_res  TYPE TABLE OF ekpo,
        ls_ekpo_res  TYPE ekpo,
        tl_ekpo      TYPE TABLE OF ekpo.

  DATA: lv_pox TYPE ebeln,
        lv_itmx TYPE ebelp.

  REFRESH t_itmatr_ax[].
  vg_atprp = 'X'.

* Seleção de Mapeamento
  SELECT SINGLE *
    INTO wa_mapping
    FROM zhms_tb_mapping
   WHERE codmp EQ '17'.

* Seleção dos dados de mapeamento
  SELECT *
    INTO TABLE it_mapdata_aux
    FROM zhms_tb_mapdata
   WHERE codmp EQ '17'.

* Verifica dados encontrados
  IF it_mapdata_aux[] IS INITIAL.
    EXIT.
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

  SELECT * FROM zhms_tb_docmn INTO TABLE t_docmn WHERE chave EQ chave.
  SELECT * FROM zhms_tb_docmna INTO TABLE t_docmna WHERE chave EQ chave.


  MOVE t_docmn[] TO t_docmnxped[].
  LOOP AT t_docmn INTO wa_docmn WHERE mneum  = 'NITEMPED'.

    READ TABLE t_docmnxped INTO wa_docmnxped WITH KEY mneum  = 'XPED'
                                             dcitm  = wa_docmn-dcitm.

    IF sy-subrc IS INITIAL.
      MOVE wa_docmnxped-value TO wa_itmatr_ax-nrsrf.
      CLEAR wa_docmnxped.
    ENDIF.

    MOVE: wa_docmn-value TO wa_itmatr_ax-itsrf,
          wa_docmn-dcitm TO wa_itmatr_ax-dcitm.
    APPEND wa_itmatr_ax TO t_itmatr_ax.
    CLEAR wa_itmatr_ax.
  ENDLOOP.

*** Fim alteração david rosin 25.09.2014
  LOOP AT t_itmatr_ax INTO wa_itmatr_ax.
    MOVE sy-tabix TO v_index.

    SELECT SINGLE *
      FROM zhms_tb_itmdoc
      INTO wa_itmdoc_ax
     WHERE chave EQ chave
       AND dcitm EQ wa_itmatr_ax-dcitm.

    IF sy-subrc IS INITIAL.
      wa_itmatr_ax-atqtd = wa_itmdoc_ax-dcqtd.
      MODIFY t_itmatr_ax FROM wa_itmatr_ax INDEX v_index.
    ENDIF.

  ENDLOOP.

  DESCRIBE TABLE t_itmatr_ax LINES vg_tdsrf.
  SELECT SINGLE * FROM zhms_tb_cabdoc INTO wa_cabdoc WHERE chave EQ
chave.


  CLEAR vl_seqnr.

  vg_tdsrf = '1'.

**    Tratamento para tipos de documentos do SAP
  CASE vg_tdsrf.
    WHEN 01. " Pedido de Compras
**        Cria uma tabela interna para pedidos de compra
      REFRESH tl_ekpo.
      LOOP AT t_itmatr_ax INTO wa_itmatr_ax.
        vl_index = sy-tabix.
        CLEAR wl_ekpo.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = wa_itmatr_ax-nrsrf
          IMPORTING
            output = wa_itmatr_ax-nrsrf.

        MOVE wa_itmatr_ax-nrsrf TO wl_ekpo-ebeln.
        MOVE wa_itmatr_ax-itsrf TO wl_ekpo-ebelp.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = wl_ekpo-ebeln
          IMPORTING
            output = wl_ekpo-ebeln.

        APPEND wl_ekpo TO tl_ekpo.
        MODIFY t_itmatr_ax FROM wa_itmatr_ax INDEX vl_index.
      ENDLOOP.

**        Seleciona dados na EKPO
      IF NOT tl_ekpo[] IS INITIAL.
        SELECT *
          INTO TABLE tl_ekpo_res
          FROM ekpo
           FOR ALL ENTRIES IN tl_ekpo
         WHERE ebeln EQ tl_ekpo-ebeln
           AND ebelp EQ tl_ekpo-ebelp.
      ENDIF.

    WHEN OTHERS.
  ENDCASE.

**    Percorre estrutura de atribuição
  LOOP AT t_itmatr_ax INTO wa_itmatr_ax.

    SELECT SINGLE * FROM zhms_tb_itmdoc INTO wa_itmdoc_ax WHERE chave EQ
               chave
                                                            AND dcitm EQ
               wa_itmatr_ax-dcitm.

**      Manter o valor do indice em variável
    vl_index = sy-tabix.

**      Sequência numérica: Chave única
    if vl_seqnr is initial.
      ADD 1 TO vl_seqnr.
    endif.
    wa_itmatr_ax-seqnr = vl_seqnr.

*** Inicio Alteração David Rosin 25.09.2014
    CLEAR: lv_pox, lv_itmx.
    MOVE: wa_itmatr_ax-nrsrf TO lv_pox,
          wa_itmatr_ax-itsrf TO lv_itmx.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = lv_pox
      IMPORTING
        output = lv_pox.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = lv_itmx
      IMPORTING
        output = lv_itmx.

    READ TABLE tl_ekpo_res
          INTO ls_ekpo_res WITH KEY ebeln = lv_pox
                                    ebelp = lv_itmx.

    IF sy-subrc IS INITIAL.
**      Unidade de Medida
wa_itmatr_ax-atunm = ls_ekpo_res-meins.
*      wa_itmatr_ax-atunm = wa_itmdoc_ax-dcunm.
    ENDIF.

***      Unidade de Medida
*    wa_itmatr_ax-atunm = wa_itmdoc_ax-dcunm.

**      Processamento Proporcional
    wa_itmatr_ax-atprp = vg_atprp.

**      Tipo de documento SAP de referencia
    wa_itmatr_ax-tdsrf = vg_tdsrf.

**      Campos provenientes da tabela de itens.
    wa_itmatr_ax-natdc = wa_itmdoc_ax-natdc.
    wa_itmatr_ax-typed = wa_itmdoc_ax-typed.
    wa_itmatr_ax-loctp = wa_itmdoc_ax-loctp.
    wa_itmatr_ax-chave = wa_itmdoc_ax-chave.
    wa_itmatr_ax-dcitm = wa_itmdoc_ax-dcitm.

**      Seleção de material atribuído no pedido
    CLEAR wl_ekpo.
*    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*      EXPORTING
*        input  = wa_itmatr_ax-nrsrf
*      IMPORTING
*        output = wa_itmatr_ax-nrsrf.

    MOVE wa_itmatr_ax-nrsrf TO wl_ekpo-ebeln.
    MOVE wa_itmatr_ax-itsrf TO wl_ekpo-ebelp.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = wl_ekpo-ebeln
      IMPORTING
        output = wl_ekpo-ebeln.

    READ TABLE tl_ekpo_res
          INTO wl_ekpo
      WITH KEY ebelp = wl_ekpo-ebelp
               ebeln = wl_ekpo-ebeln.
*    IF sy-subrc IS INITIAL.
*      wa_itmatr_ax-atprc = wl_ekpo-netwr."wl_ekpo-brtwr.
*      wa_itmatr_ax-atmat = wl_ekpo-matnr.

      wa_itmatr_ax-atprc = wa_itmdoc_ax-dcprc."wl_ekpo-brtwr.
      wa_itmatr_ax-atmat = wl_ekpo-matnr.



*    ENDIF.

*** Monta numero do lote
    IF wa_itmatr_ax-atlot IS INITIAL.
      CALL FUNCTION 'ZHMS_FM_SET_LOTE'
        EXPORTING
          po   = wa_itmatr_ax-nrsrf
          item = wa_itmatr_ax-itsrf
        IMPORTING
          lote = wa_itmatr_ax-atlot.
    ENDIF.

    wa_itmatr_ax-nrsrf = lv_pox.

**      Insere os resultados na estrutura de atribução
    MODIFY t_itmatr_ax FROM wa_itmatr_ax INDEX vl_index.

  ENDLOOP.

*  PERFORM f_atr_completalista.
  PERFORM f_atr_valida CHANGING vl_erro.

  IF vl_erro IS INITIAL.
** Gravar alterações
    PERFORM f_atr_auto_gravar.
  ENDIF.

ENDFUNCTION.
