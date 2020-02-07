

*----------------------------------------------------------------------*
*   Form  f_mask_anomes
*----------------------------------------------------------------------*
*   Formatando Ano / Mês
*----------------------------------------------------------------------*
    FORM f_mask_anomes USING    p_param_in  TYPE sy-datum
                       CHANGING p_param_out TYPE char6.

      CONCATENATE p_param_in(2)
                  p_param_in+4(2)
             INTO p_param_out.

    ENDFORM.                    "f_mask_anomes

*----------------------------------------------------------------------*
*   Form  F_MASK_TAXJURCODE
*----------------------------------------------------------------------*
*   Obtendo Código IBGE
*----------------------------------------------------------------------*
    FORM f_mask_taxjurcode USING   p_param_in
                          CHANGING p_param_out.

      p_param_out = p_param_in+3.

    ENDFORM.                    "F_MASK_TAXJURCODE

*&---------------------------------------------------------------------*
*&      Form  f_converter_um
*&---------------------------------------------------------------------*
*       Rotina de conversão de unidades de MEDIDA
*----------------------------------------------------------------------*
    FORM f_converter_um USING p_itmatr STRUCTURE zhms_tb_itmatr
                     CHANGING p_param.
*     Rotina de conversão
      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
        EXPORTING
          input          = p_param
          language       = sy-langu
        IMPORTING
          output         = p_param
        EXCEPTIONS
          unit_not_found = 1
          OTHERS         = 2.

      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

    ENDFORM.                    "f_converter_um

*&---------------------------------------------------------------------*
*&      Form  f_only_numbers
*&---------------------------------------------------------------------*
*       Remove demais caracteres, deixando apenas números
*----------------------------------------------------------------------*
    FORM f_only_numbers USING p_itmatr STRUCTURE zhms_tb_itmatr
                     CHANGING p_param.

** Variáveis locais
      DATA: vl_len       TYPE i,
            vl_atual     TYPE i,
            vl_ant       TYPE i,
            vl_string    TYPE string,
            vl_resultado TYPE string.

** Transferir valor de entrada
      vl_string = p_param.

** Quantidade de caracteres da string
      vl_len = strlen( vl_string ).
      CLEAR vl_resultado.

** Percorrer a string
      DO vl_len TIMES.
        vl_atual = vl_atual + 1.
        vl_ant = vl_atual - 1.
**  Caso encontre número adiciona a variavel de retorno
        IF vl_string+vl_ant(1) CA '0123456789'.
          CONCATENATE vl_resultado vl_string+vl_ant(1) INTO vl_resultado.
        ENDIF.
      ENDDO.

**  Transfere para saída
      p_param = vl_resultado.

    ENDFORM.                    "f_only_numbers

*&---------------------------------------------------------------------*
*&      Form  f_calc_itemamount
*&---------------------------------------------------------------------*
*       Cálculo de Item Ammount para processamento de MIRO
*----------------------------------------------------------------------*
    FORM f_calc_itemamount USING p_itmatr STRUCTURE zhms_tb_itmatr
                         CHANGING p_param.

**    Valor Recebido - VPROD
**    Variáveis Internas
      DATA: vl_ammount TYPE bapiwrbtr.
      DATA: rg_mwskz   TYPE RANGE OF ekpo-mwskz.
      DATA: vl_taxcode TYPE ekpo-mwskz.
      FIELD-SYMBOLS: <fs_taxcode> LIKE LINE OF rg_mwskz.

      REFRESH rg_mwskz.
      UNASSIGN <fs_taxcode>.
      APPEND INITIAL LINE TO rg_mwskz ASSIGNING <fs_taxcode>.
      MOVE: 'I'    TO <fs_taxcode>-sign,
            'EQ'   TO <fs_taxcode>-option,
            'C0'   TO <fs_taxcode>-low.

      UNASSIGN <fs_taxcode>.
      APPEND INITIAL LINE TO rg_mwskz ASSIGNING <fs_taxcode>.
      MOVE: 'I'    TO <fs_taxcode>-sign,
            'EQ'   TO <fs_taxcode>-option,
            'C1'   TO <fs_taxcode>-low.

      UNASSIGN <fs_taxcode>.
      APPEND INITIAL LINE TO rg_mwskz ASSIGNING <fs_taxcode>.
      MOVE: 'I'    TO <fs_taxcode>-sign,
            'EQ'   TO <fs_taxcode>-option,
            'C2'   TO <fs_taxcode>-low.

      UNASSIGN <fs_taxcode>.
      APPEND INITIAL LINE TO rg_mwskz ASSIGNING <fs_taxcode>.
      MOVE: 'I'    TO <fs_taxcode>-sign,
            'EQ'   TO <fs_taxcode>-option,
            'C3'   TO <fs_taxcode>-low.

      TRANSLATE p_param USING ',.'.

**    Ler mneumonicos de impostos para subtrair
**    ICMS
      READ TABLE it_docmn INTO wa_docmn_rt WITH KEY mneum = 'ATVICMS'
                                                    atitm = p_itmatr-atitm.

**    Caso encontrado o valor, subtrair
      IF sy-subrc IS INITIAL.
        CLEAR vl_ammount .
        vl_ammount = wa_docmn_rt-value.
        p_param = p_param - vl_ammount.
        CONDENSE p_param NO-GAPS.
      ENDIF.

      CLEAR vl_taxcode.
      SELECT SINGLE mwskz
        FROM ekpo
        INTO vl_taxcode
        WHERE ebeln EQ p_itmatr-nrsrf.

      IF NOT vl_taxcode IN rg_mwskz.
        CLEAR wa_docmn_rt.
        READ TABLE it_docmn INTO wa_docmn_rt WITH KEY mneum = 'ATVCOFINS'
                                                      atitm = p_itmatr-atitm.

**    Caso encontrado o valor, subtrair
        IF sy-subrc IS INITIAL.
          CLEAR vl_ammount .
          vl_ammount = wa_docmn_rt-value.
          p_param = p_param - vl_ammount.
          CONDENSE p_param NO-GAPS.
        ENDIF.

        CLEAR wa_docmn_rt.
        READ TABLE it_docmn INTO wa_docmn_rt WITH KEY mneum = 'ATVPIS'
                                                      atitm = p_itmatr-atitm.

**    Caso encontrado o valor, subtrair
        IF sy-subrc IS INITIAL.
          CLEAR vl_ammount .
          vl_ammount = wa_docmn_rt-value.
          p_param = p_param - vl_ammount.
          CONDENSE p_param NO-GAPS.
        ENDIF.

        if p_itmatr-TYPED = 'NFSE1'.
          CLEAR wa_docmn_rt.
          READ TABLE it_docmn INTO wa_docmn_rt WITH KEY mneum = 'LIQUIDO'.

**    Caso encontrado o valor, subtrair
          IF sy-subrc IS INITIAL.
            CLEAR vl_ammount .
            vl_ammount = wa_docmn_rt-value.
            p_param = p_param - vl_ammount.
            CONDENSE p_param NO-GAPS.
          ENDIF.
        endif.
      ENDIF.

    ENDFORM.                    "f_calc_itemamount

*&---------------------------------------------------------------------*
*&      Form  f_calc_totimp
*&---------------------------------------------------------------------*
*       Cálculo do total de imposto para um item [TAXDATA]
*----------------------------------------------------------------------*
    FORM f_calc_totimp USING p_itmatr STRUCTURE zhms_tb_itmatr
                                       CHANGING p_param.

**    Variáveis Internas
      DATA: vl_ammount TYPE bapiwrbtr.

      CLEAR vl_ammount.
**    Ler mneumonicos de impostos para somar
**    ICMS
      READ TABLE it_docmn INTO wa_docmn_rt WITH KEY mneum = 'ATVICMS'
                                                    atitm = p_itmatr-atitm.

**    Caso encontrado o valor, somar
      IF sy-subrc IS INITIAL.
        vl_ammount = wa_docmn_rt-value.
        p_param = p_param + vl_ammount.
        CONDENSE p_param NO-GAPS.
      ENDIF.

**    Ler mneumonicos de impostos para somar
**    IPI
      READ TABLE it_docmn INTO wa_docmn_rt WITH KEY mneum = 'ATVIPI'
                                                    atitm = p_itmatr-atitm.

**    Caso encontrado o valor, somar
      IF sy-subrc IS INITIAL.
        vl_ammount = wa_docmn_rt-value.
        p_param = p_param + vl_ammount.
        CONDENSE p_param NO-GAPS.
      ENDIF.

      READ TABLE it_docmn INTO wa_docmn_rt WITH KEY mneum = 'ATVCOFINS'
                                                    atitm = p_itmatr-atitm.

**    Caso encontrado o valor, subtrair
      IF sy-subrc IS INITIAL.
        CLEAR vl_ammount .
        vl_ammount = wa_docmn_rt-value.
        p_param = p_param + vl_ammount.
        CONDENSE p_param NO-GAPS.
      ENDIF.

      READ TABLE it_docmn INTO wa_docmn_rt WITH KEY mneum = 'ATVPIS'
                                                    atitm = p_itmatr-atitm.

**    Caso encontrado o valor, subtrair
      IF sy-subrc IS INITIAL.
        CLEAR vl_ammount .
        vl_ammount = wa_docmn_rt-value.
        p_param = p_param + vl_ammount.
        CONDENSE p_param NO-GAPS.
      ENDIF.

    ENDFORM.                    "f_calc_totimp

*&---------------------------------------------------------------------*
*&      Form  f_exit_taxdata
*&---------------------------------------------------------------------*
*       Exit Pré BAPI - Tratamento dos itens da TAXDATA
*----------------------------------------------------------------------*
    FORM f_exit_taxdata TABLES p_taxdata STRUCTURE bapi_incinv_create_tax.

**    Variáveis Internas
      DATA: tl_tax_code	TYPE TABLE OF	mwskz,
            wl_tax_code	TYPE mwskz,
            tl_taxdata  TYPE TABLE OF bapi_incinv_create_tax,
            wl_taxdata  TYPE bapi_incinv_create_tax.

**    Percorrer dados recebidos e identificar os IVAS
      LOOP AT p_taxdata.
        CLEAR wl_tax_code.
        wl_tax_code = p_taxdata-tax_code.
        APPEND wl_tax_code TO tl_tax_code.
      ENDLOOP.

**    Retirar duplicados
      SORT tl_tax_code ASCENDING.
      DELETE ADJACENT DUPLICATES FROM tl_tax_code.

**    Percorrer encontrados
      LOOP AT tl_tax_code INTO wl_tax_code.
**      Identificar linhas iguais
        CLEAR wl_taxdata.
        LOOP AT p_taxdata WHERE tax_code EQ wl_tax_code.
**        Dados Fixos
          wl_taxdata-tax_code         = p_taxdata-tax_code.
          wl_taxdata-cond_type        = p_taxdata-cond_type.
          wl_taxdata-taxjurcode       = p_taxdata-taxjurcode.
          wl_taxdata-taxjurcode_deep  = p_taxdata-taxjurcode_deep.
          wl_taxdata-itemno_tax       = p_taxdata-itemno_tax.

**        Dados a serem somados
          wl_taxdata-tax_amount       = wl_taxdata-tax_amount + p_taxdata-tax_amount.
          wl_taxdata-tax_base_amount  = wl_taxdata-tax_base_amount + p_taxdata-tax_base_amount.

        ENDLOOP.
        APPEND wl_taxdata TO tl_taxdata.
      ENDLOOP.

**    Retira dados anteriores e insere os novos
      REFRESH p_taxdata.
      p_taxdata[] = tl_taxdata[].

    ENDFORM.                    "f_exit_taxdata

*&---------------------------------------------------------------------*
*&      Form  f_conferevnf
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITMATR   text
*      -->P_PARAM    text
*----------------------------------------------------------------------*
    FORM f_conferevnf USING p_itmatr STRUCTURE zhms_tb_itmatr
                         CHANGING p_param.

*      IF p_param IS INITIAL.
*        p_param = '361185.56'.
*      ENDIF.

      TRANSLATE p_param USING ',.'.

    ENDFORM.                    "f_conferevnf
*&---------------------------------------------------------------------*
*&      Form  f_get_year
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITMATR   text
*      <--P_PARAM    text
*----------------------------------------------------------------------*
    FORM f_get_year USING p_itmatr STRUCTURE zhms_tb_itmatr
                         CHANGING p_param.

      p_param = sy-datum(4).

    ENDFORM.                    "f_get_year
*&---------------------------------------------------------------------*
*&      Form  f_set_bach
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITMATR   text
*      <--P_PARAM    text
*----------------------------------------------------------------------*
    FORM f_set_bach USING p_itmatr STRUCTURE zhms_tb_itmatr
                         CHANGING p_param.


      READ TABLE it_itmatr INTO wa_itmatr WITH KEY atitm = wa_docmn-atitm.

      IF sy-subrc IS INITIAL.
        p_param = wa_itmatr-atlot.
      ENDIF.

    ENDFORM.                    "f_set_bach
*&---------------------------------------------------------------------*
*&      Form  F_FLAG_TAX_IND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITMATR   text
*      <--P_PARAM    text
*----------------------------------------------------------------------*
    FORM f_flag_tax_ind USING p_itmatr STRUCTURE zhms_tb_itmatr
                     CHANGING p_param.
      p_param = 'X'.
    ENDFORM.                    "F_FLAG_TAX_IND
*&---------------------------------------------------------------------*
*&      Form  F_INSERT_SPACE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITMATR   text
*      <--P_PARAM    text
*----------------------------------------------------------------------*
    FORM f_insert_space USING p_itmatr STRUCTURE zhms_tb_itmatr
                     CHANGING p_param.
      DATA: vg_char TYPE char30.

      vg_char = p_param.
      CONDENSE vg_char NO-GAPS.
      CLEAR p_param.
      CONCATENATE vg_char(2) vg_char+2(28) INTO p_param SEPARATED BY space.

    ENDFORM.                    "F_INSERT_SPACE
*&---------------------------------------------------------------------*
*&      Form  f_set_bach
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITMATR   text
*      <--P_PARAM    text
*----------------------------------------------------------------------*
    FORM f_set_bach_forn USING p_itmatr STRUCTURE zhms_tb_itmatr
                         CHANGING p_param.


      READ TABLE it_itmatr INTO wa_itmatr WITH KEY atitm = wa_docmn-atitm.

      IF sy-subrc IS INITIAL.
        p_param = wa_itmatr-exlot.
      ENDIF.

    ENDFORM.                    "f_set_bach
*&---------------------------------------------------------------------*
*&      Form  f_set_dataprod
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITMATR   text
*      <--P_PARAM    text
*----------------------------------------------------------------------*
    FORM f_set_dataprod USING p_itmatr STRUCTURE zhms_tb_itmatr
                     CHANGING p_param.


      READ TABLE it_itmatr INTO wa_itmatr WITH KEY atitm = wa_docmn-atitm.

      IF sy-subrc IS INITIAL.
        p_param = wa_itmatr-data_prod.
      ENDIF.

** Variáveis locais
      DATA: vl_len       TYPE i,
            vl_atual     TYPE i,
            vl_ant       TYPE i,
            vl_string    TYPE string,
            vl_resultado TYPE string.

** Transferir valor de entrada
      vl_string = p_param.

** Quantidade de caracteres da string
      vl_len = strlen( vl_string ).
      CLEAR vl_resultado.

** Percorrer a string
      DO vl_len TIMES.
        vl_atual = vl_atual + 1.
        vl_ant = vl_atual - 1.
**  Caso encontre número adiciona a variavel de retorno
        IF vl_string+vl_ant(1) CA '0123456789'.
          CONCATENATE vl_resultado vl_string+vl_ant(1) INTO vl_resultado.
        ENDIF.
      ENDDO.

**  Transfere para saída
      p_param = vl_resultado.

    ENDFORM.                    "f_set_bach
*&---------------------------------------------------------------------*
*&      Form  f_set_data_venc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITMATR   text
*      <--P_PARAM    text
*----------------------------------------------------------------------*
    FORM f_set_data_venc USING p_itmatr STRUCTURE zhms_tb_itmatr
                     CHANGING p_param.


      READ TABLE it_itmatr INTO wa_itmatr WITH KEY atitm = wa_docmn-atitm.

      IF sy-subrc IS INITIAL.
        p_param = wa_itmatr-data_venc.
      ENDIF.

** Variáveis locais
      DATA: vl_len       TYPE i,
            vl_atual     TYPE i,
            vl_ant       TYPE i,
            vl_string    TYPE string,
            vl_resultado TYPE string.

** Transferir valor de entrada
      vl_string = p_param.

** Quantidade de caracteres da string
      vl_len = strlen( vl_string ).
      CLEAR vl_resultado.

** Percorrer a string
      DO vl_len TIMES.
        vl_atual = vl_atual + 1.
        vl_ant = vl_atual - 1.
**  Caso encontre número adiciona a variavel de retorno
        IF vl_string+vl_ant(1) CA '0123456789'.
          CONCATENATE vl_resultado vl_string+vl_ant(1) INTO vl_resultado.
        ENDIF.
      ENDDO.

**  Transfere para saída
      p_param = vl_resultado.

    ENDFORM.                    "f_set_bach
*&---------------------------------------------------------------------*
*&      Form  F_INSERT_TEXTO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITMATR   text
*      <--P_PARAM    text
*----------------------------------------------------------------------*
    FORM f_insert_texto USING p_itmatr STRUCTURE zhms_tb_itmatr
                     CHANGING p_param.

      DATA: lv_nnf TYPE char15.
      CLEAR: lv_nnf, p_param.

      READ TABLE it_docmn INTO wa_docmn_rt WITH KEY mneum = 'NNF'.

      IF sy-subrc IS INITIAL.
        MOVE wa_docmn_rt-value TO lv_nnf.
      ENDIF.

      READ TABLE it_docmn INTO wa_docmn_rt WITH KEY mneum = 'XNOME'.

      IF sy-subrc IS INITIAL.
        CONCATENATE 'VLR NF' lv_nnf wa_docmn_rt-value INTO p_param SEPARATED BY space.
      ENDIF.

    ENDFORM.                    "f_set_bach
*&---------------------------------------------------------------------*
*&      Form  F_INSERT_ZERO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITMATR   text
*      <--P_PARAM    text
*----------------------------------------------------------------------*
    FORM f_insert_zero USING p_itmatr STRUCTURE zhms_tb_itmatr
                     CHANGING p_param.

      CLEAR p_param.

    ENDFORM.                    "F_INSERT_ZERO
*&---------------------------------------------------------------------*
*&      Form  F_INSERT_YEAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ITMATR   text
*      <--P_PARAM    text
*----------------------------------------------------------------------*
    FORM f_insert_year USING p_itmatr STRUCTURE zhms_tb_itmatr
                     CHANGING p_param.

      CLEAR: p_param.

      READ TABLE it_docmn INTO wa_docmn_rt WITH KEY mneum = 'REFDOCYR'.

      IF sy-subrc IS INITIAL.
        MOVE wa_docmn_rt-value(04) TO p_param.
      ENDIF.

    ENDFORM.                    "F_INSERT_YEAR
*&---------------------------------------------------------------------*
*&      Form  F_DATAEMISSAO_NFSE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
    FORM f_dataemissao_nfse USING p_itmatr STRUCTURE zhms_tb_itmatr
                                      CHANGING p_value.

      MOVE wa_cabdoc-chave+0(10) TO p_value.


    ENDFORM.                    " F_DATAEMISSAO_NFSE
*&---------------------------------------------------------------------*
*&      Form  f_j1bnftype_nfse
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
    FORM f_j1bnftype_nfse USING p_itmatr STRUCTURE zhms_tb_itmatr
                                      CHANGING p_value.
      p_value = 'E1'.
    ENDFORM.                    " f_j1bnftype_nfse
*&---------------------------------------------------------------------*
*&      Form  f_calctaxind_nfse
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
    FORM f_calctaxind_nfse USING p_itmatr STRUCTURE zhms_tb_itmatr
                                      CHANGING p_value.
      p_value = 'X'.
    ENDFORM.                    " f_calctaxind_nfse
*&---------------------------------------------------------------------*
*&      Form  F_NFSE_WITHT
*&---------------------------------------------------------------------*
*      -->P_ITMATR   text
*      <--P_PARAM    text
*----------------------------------------------------------------------*
    FORM f_nfse_witht USING p_itmatr STRUCTURE zhms_tb_itmatr
                   CHANGING p_param.

      DATA: vl_bukrs  TYPE bukrs.
      DATA: vl_subjct TYPE wt_subjct.

      CLEAR: vl_bukrs, p_param, wa_docmn_rt, vl_subjct.
      READ TABLE it_docmn INTO wa_docmn_rt WITH KEY mneum = 'COMPCODE'.
      vl_bukrs = wa_docmn_rt-value.

      CLEAR: wa_docmn_rt.
      READ TABLE it_docmn INTO wa_docmn_rt WITH KEY mneum = 'VENDOR'.
      IF sy-subrc IS INITIAL.
        SELECT SINGLE witht wt_subjct
          FROM lfbw INTO (p_param, vl_subjct)
         WHERE lifnr EQ wa_docmn_rt-value
           AND bukrs EQ vl_bukrs.
        IF vl_subjct IS INITIAL.
          CLEAR p_param.
        ENDIF.

      ENDIF.

    ENDFORM.                    "F_NFSE_WITHT
*&---------------------------------------------------------------------*
*&      Form  F_NFSE_WITHTCD
*&---------------------------------------------------------------------*
*      -->P_ITMATR   text
*      <--P_PARAM    text
*----------------------------------------------------------------------*
    FORM f_nfse_withtcd USING p_itmatr STRUCTURE zhms_tb_itmatr
                     CHANGING p_param.

      DATA: vl_bukrs  TYPE bukrs.
      DATA: vl_subjct TYPE wt_subjct.

      CLEAR: vl_bukrs, p_param, wa_docmn_rt, vl_subjct.
      READ TABLE it_docmn INTO wa_docmn_rt WITH KEY mneum = 'COMPCODE'.
      vl_bukrs = wa_docmn_rt-value.

      CLEAR: wa_docmn_rt.
      READ TABLE it_docmn INTO wa_docmn_rt WITH KEY mneum = 'VENDOR'.
      IF sy-subrc IS INITIAL.
        SELECT SINGLE wt_subjct wt_withcd
          FROM lfbw INTO (vl_subjct, p_param)
         WHERE lifnr EQ wa_docmn_rt-value
           AND bukrs EQ vl_bukrs.
        IF vl_subjct IS INITIAL.
          CLEAR p_param.
        ENDIF.
      ENDIF.

    ENDFORM.                    "F_NFSE_WITHTCD
*&---------------------------------------------------------------------*
*&      Form  F_NFSE_SPLITKEY
*&---------------------------------------------------------------------*
*      -->P_ITMATR   text
*      <--P_PARAM    text
*----------------------------------------------------------------------*
    FORM f_nfse_splitkey USING p_itmatr STRUCTURE zhms_tb_itmatr
                      CHANGING p_param.

      DATA: vl_bukrs  TYPE bukrs.
      DATA: vl_subjct TYPE wt_subjct.

      CLEAR: vl_bukrs, p_param, wa_docmn_rt, vl_subjct.
      READ TABLE it_docmn INTO wa_docmn_rt WITH KEY mneum = 'COMPCODE'.
      vl_bukrs = wa_docmn_rt-value.

      CLEAR: wa_docmn_rt.
      READ TABLE it_docmn INTO wa_docmn_rt WITH KEY mneum = 'VENDOR'.
      IF sy-subrc IS INITIAL.
        SELECT SINGLE wt_withcd wt_subjct
          FROM lfbw INTO (vl_subjct, p_param)
         WHERE lifnr EQ wa_docmn_rt-value
           AND bukrs EQ vl_bukrs.
        IF vl_subjct IS NOT INITIAL.
          p_param = '000001'.
        ELSE.
          CLEAR p_param.
        ENDIF.
      ENDIF.


    ENDFORM.                    "F_NFSE_SPLITKEY
*&---------------------------------------------------------------------*
*&      Form  f_converte_qtd
*&---------------------------------------------------------------------*
*       Cálculo para Conversão de Unidade de Medidas
*----------------------------------------------------------------------*
    FORM f_converte_qtd USING p_itmatr STRUCTURE zhms_tb_itmatr
                     CHANGING p_param.

**    Valor Recebido - VPROD
      DATA it_unit   TYPE TABLE OF zhms_tb_unit.
      DATA wa_unit   TYPE zhms_tb_unit.
      DATA wa_marm   TYPE marm.
      DATA vl_nitem  TYPE ebelp.
      DATA vl_meinh       TYPE marm-meinh.
      DATA vl_meinh_xml   TYPE marm-meinh.
      DATA lv_umxml       TYPE mara-meins.
      DATA lv_um_po       TYPE mara-meins.
      DATA lv_menge       TYPE ekpo-menge.
      DATA lv_menge_retur TYPE ekpo-menge.

***Busca o numero do pedido
      CLEAR: wa_docmn_rt, vl_meinh_xml, vl_nitem, v_error, wa_marm, vl_meinh, v_matnr.
      READ TABLE it_docmn INTO wa_docmn_rt WITH KEY mneum = 'ATPED'
                                                    atitm = p_itmatr-atitm
                                                    dcitm = p_itmatr-dcitm.
      IF sy-subrc IS INITIAL.
        vl_nitem = p_itmatr-itsrf.

*** Busca o valor na ekpo
        SELECT SINGLE * FROM ekpo INTO wa_ekpo
                                 WHERE ebeln EQ wa_docmn_rt-value
                                   AND ebelp EQ vl_nitem.

        IF sy-subrc EQ 0.

          CLEAR wa_docmn_rt.
          READ TABLE it_docmn INTO wa_docmn_rt WITH KEY mneum = 'UCOM'
*          READ TABLE it_docmn INTO wa_docmn_rt WITH KEY mneum = 'UTRIB'
*                                                        atitm = p_itmatr-atitm
                                                        dcitm = p_itmatr-dcitm.
          vl_meinh_xml = wa_docmn_rt-value.
          PERFORM f_converter_um USING p_itmatr
                              CHANGING vl_meinh_xml.

*          IF wa_docmn_rt-value NE wa_ekpo-meins
*            AND wa_docmn_rt-value IS NOT INITIAL
          IF vl_meinh_xml NE wa_ekpo-meins
            AND vl_meinh_xml IS NOT INITIAL
            AND wa_ekpo-meins IS NOT INITIAL.

*--------------------------------------------------------------------*
            SELECT SINGLE * FROM zhms_tb_unit
                            INTO wa_unit
                           WHERE unidadexml EQ vl_meinh_xml.
            IF sy-subrc EQ 0.
              vl_meinh = wa_unit-unidadesap.

              PERFORM f_converter_um USING p_itmatr
                                  CHANGING vl_meinh.

              SELECT SINGLE * FROM marm
                              INTO wa_marm
                             WHERE matnr EQ wa_ekpo-matnr
                               AND meinh EQ vl_meinh.

            ELSE.
              vl_meinh = wa_docmn_rt-value.

              PERFORM f_converter_um USING p_itmatr
                                  CHANGING vl_meinh.

              SELECT SINGLE * FROM marm
                              INTO wa_marm
                             WHERE matnr EQ wa_ekpo-matnr
                               AND meinh EQ vl_meinh.

              IF sy-subrc IS NOT INITIAL.
                v_error = 'F'.
                v_matnr = wa_ekpo-matnr.
                EXIT.
              ENDIF.
            ENDIF.
*--------------------------------------------------------------------*
*            PERFORM f_converter_um USING p_itmatr
*                                CHANGING vl_meinh.
*
*            SELECT SINGLE * FROM marm
*                            INTO wa_marm
*                           WHERE matnr EQ wa_ekpo-matnr
*                             AND meinh EQ vl_meinh.

            IF wa_marm IS NOT INITIAL.

              CLEAR: wa_docmn_rt, lv_umxml, lv_um_po, lv_menge.
              READ TABLE it_docmn INTO wa_docmn_rt WITH KEY mneum = 'QCOM'
*              READ TABLE it_docmn INTO wa_docmn_rt WITH KEY mneum = 'QTRIB'
*                                                              atitm = p_itmatr-atitm
                                                            dcitm = p_itmatr-dcitm.
              TRY .

                  lv_umxml   = vl_meinh.
                  lv_um_po   = wa_ekpo-meins.
                  lv_menge   = wa_docmn_rt-value.

                  CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
                    EXPORTING
                      i_matnr              = wa_ekpo-matnr
                      i_in_me              = lv_umxml
                      i_out_me             = lv_um_po
                      i_menge              = lv_menge
                    IMPORTING
                      e_menge              = lv_menge_retur
                    EXCEPTIONS
                      error_in_application = 1
                      error                = 2
                      OTHERS               = 3.

                  IF sy-subrc <> 0.
                    v_error = 'F'.
                    v_matnr = wa_ekpo-matnr.
                  ELSE.
                    p_param = lv_menge_retur.
                  ENDIF.

                CATCH cx_root.
              ENDTRY.

            ELSE. "Caso não ache na MARM

              SELECT SINGLE * FROM zhms_tb_unit
                              INTO wa_unit
                             WHERE unidadexml EQ wa_docmn_rt-value.

              IF wa_unit IS NOT INITIAL.

                PERFORM f_converter_um USING p_itmatr
                                    CHANGING wa_unit-unidadesap.

                IF wa_unit-unidadesap NE wa_ekpo-meins.

                  CLEAR wa_docmn_rt.
*                  READ TABLE it_docmn INTO wa_docmn_rt WITH KEY mneum = 'QTRIB'
                  READ TABLE it_docmn INTO wa_docmn_rt WITH KEY mneum = 'QCOM'
*                                                              atitm = p_itmatr-atitm
                                                                dcitm = p_itmatr-dcitm.
                  TRY .
                      CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
                        EXPORTING
                          i_matnr              = wa_ekpo-matnr
                          i_in_me              = wa_unit-unidadesap
                          i_out_me             = wa_ekpo-meins
                          i_menge              = wa_docmn_rt-value
                        IMPORTING
                          e_menge              = p_param
                        EXCEPTIONS
                          error_in_application = 1
                          error                = 2
                          OTHERS               = 3.

                      IF sy-subrc <> 0.
                        v_error = 'F'.
                        v_matnr = wa_ekpo-matnr.
                      ENDIF.

                    CATCH cx_root.
                  ENDTRY.

                ENDIF.
              ELSE.
                v_error = 'S'. "Erro no 'S'elect
              ENDIF.

            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

    ENDFORM.                    "f_converte_qtd
