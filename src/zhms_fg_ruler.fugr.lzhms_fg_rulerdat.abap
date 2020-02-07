*&---------------------------------------------------------------------*
*&  Include           LZHMS_FG_RULERDAT
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  f_scenario_01_nfe_01
*&---------------------------------------------------------------------*
*       Emissão NF-e Venda Normal
*----------------------------------------------------------------------*
    FORM f_scenario_01_nfe_01.
* Variáveis locais apenas para form.
      DATA: vl_nftype TYPE j_1bnfdoc-nftype,
            vl_docnum TYPE j_1bnfdoc-docnum.

* Seleção do dado transferido à função
      READ TABLE it_docum INTO wa_docum WITH KEY dctyp = 'DOCNUM'.
      CHECK sy-subrc IS INITIAL.

* Transferir valor de docnum para variável com categoria correspondente à tabela Standard
      MOVE wa_docum-dcnro TO vl_docnum.
      CLEAR vl_nftype.


* Seleção do tipo de documento da tabela.
      SELECT SINGLE nftype
        INTO vl_nftype
        FROM j_1bnfdoc
       WHERE docnum EQ vl_docnum.

* Verificação de dados recebidos
      IF vl_nftype EQ 'ZJ'.
        v_scena = wa_scenario-scena.
      ENDIF.

    ENDFORM.                    "f_scenario_01_nfe_01

*&---------------------------------------------------------------------*
*&      Form  f_scenario_02_cte_02
*&---------------------------------------------------------------------*
*       Entrada de CT-e Normal
*----------------------------------------------------------------------*
    FORM f_scenario_02_cte_01.

**    Identifica o que veio da chamada da função
      READ TABLE it_docum INTO wa_docum WITH KEY dctyp = 'CHAVE'.
      CONDENSE wa_docum-dcnro NO-GAPS.
      MOVE wa_docum-dcnro TO v_chave.

**    Seleciona dados de cabeçalho do documento
      SELECT SINGLE *
        INTO wa_cabdoc
        FROM zhms_tb_cabdoc
        WHERE chave EQ v_chave
          AND natdc EQ v_natdc
          AND typed EQ v_typed.

**    Seleciona dados de Item do documento
      IF NOT wa_cabdoc IS INITIAL.
        SELECT  *
          INTO TABLE it_itmdoc
          FROM zhms_tb_itmdoc
          WHERE natdc EQ wa_cabdoc-natdc
            AND typed EQ wa_cabdoc-typed
            AND chave EQ wa_cabdoc-chave.
      ENDIF.

    ENDFORM.                    "f_scenario_02_cte_01

*&---------------------------------------------------------------------*
*&      Form  f_scenario_02_nfe_01
*&---------------------------------------------------------------------*
*       Entrada Mercantil Normal
*----------------------------------------------------------------------*
    FORM f_scenario_02_nfe_01.

**    Identifica o que veio da chamada da função
      READ TABLE it_docum INTO wa_docum WITH KEY dctyp = 'CHAVE'.
      CONDENSE wa_docum-dcnro NO-GAPS.
      MOVE wa_docum-dcnro TO v_chave.

**    Seleciona dados de cabeçalho do documento
      SELECT SINGLE *
        INTO wa_cabdoc
        FROM zhms_tb_cabdoc
        WHERE chave EQ v_chave
          AND natdc EQ v_natdc
          AND typed EQ v_typed.

**    Seleciona dados de Item do documento
      IF NOT wa_cabdoc IS INITIAL.
        SELECT  *
          INTO TABLE it_itmdoc
          FROM zhms_tb_itmdoc
          WHERE natdc EQ wa_cabdoc-natdc
            AND typed EQ wa_cabdoc-typed
            AND chave EQ wa_cabdoc-chave.
      ENDIF.


    ENDFORM.                    "f_scenario_02_nfe_01
*&---------------------------------------------------------------------*
*&      Form  f_scenario_02_nfe_02
*&---------------------------------------------------------------------*
*       Entrada Mercantil Normal
*----------------------------------------------------------------------*
    FORM f_scenario_02_nfe_02.

      DATA: ls_1baon TYPE j_1baon,
                 ls_cfop  TYPE zhms_tb_cfop,
                 lv_cfop  TYPE char50,
                 lv_cfopf TYPE j_1bcfop,
                 lt_docmnx TYPE TABLE OF zhms_tb_docmn.

**    Identifica o que veio da chamada da função
      READ TABLE it_docum INTO wa_docum WITH KEY dctyp = 'NFE'.
      CONDENSE wa_docum-dcnro NO-GAPS.
      MOVE wa_docum-dcnro TO v_chave.

*** Verifica CFOP pela NOTA
      SELECT * FROM zhms_tb_docmn INTO TABLE lt_docmnx WHERE chave EQ
      v_chave
      AND mneum EQ 'CFOP'
      AND value NE ' '.

      IF sy-subrc IS INITIAL.

        LOOP AT lt_docmnx INTO wa_docmn.

          CLEAR lv_cfop.
          MOVE wa_docmn-value TO lv_cfop.

          CONCATENATE lv_cfop '/' 'AA' INTO lv_cfop.
          CONDENSE lv_cfop NO-GAPS.

          IF lv_cfop(1) = '6'.
            lv_cfop(1) = '2'.
          ELSEIF lv_cfop(1) = '5'.
            lv_cfop(1) = '1'.
          ENDIF.

        ENDLOOP.

        CALL FUNCTION 'CONVERSION_EXIT_CFOBR_INPUT'
          EXPORTING
            input  = lv_cfop
          IMPORTING
            output = lv_cfopf.

        SELECT SINGLE *
         FROM zhms_tb_cfop
         INTO ls_cfop
        WHERE cfop EQ lv_cfopf.

        IF sy-subrc IS INITIAL.
          EXIT.
        ENDIF.
      ENDIF.
*** verifica se existe pedido no XML
      SELECT SINGLE *
        FROM zhms_tb_docmn
        INTO wa_docmn
       WHERE chave EQ v_chave
         AND mneum EQ 'XPED'
         AND value NE ' '.

      IF sy-subrc IS INITIAL.
        SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmn WHERE chave EQ
                                                                v_chave
                                                AND mneum EQ 'NITEMPED'.
        IF sy-subrc IS INITIAL.
          v_scena = wa_scenario-scena.
        ENDIF.
      ENDIF.

**    Seleciona dados de cabeçalho do documento
      SELECT SINGLE *
        INTO wa_cabdoc
        FROM zhms_tb_cabdoc
        WHERE chave EQ v_chave
          AND natdc EQ v_natdc
          AND typed EQ v_typed.

**    Seleciona dados de Item do documento
      IF NOT wa_cabdoc IS INITIAL.
        SELECT  *
          INTO TABLE it_itmdoc
          FROM zhms_tb_itmdoc
          WHERE natdc EQ wa_cabdoc-natdc
            AND typed EQ wa_cabdoc-typed
            AND chave EQ wa_cabdoc-chave.
      ENDIF.


      IF NOT v_scena IS INITIAL.
        EXIT.
      ENDIF.

    ENDFORM.                    "f_scenario_02_nfe_02
*---------------------------------------------------------------------*
*       FORM f_scenario_02_nfe_03                                     *
*---------------------------------------------------------------------*
*       Subcontrataão                                                 *
*---------------------------------------------------------------------*
    FORM f_scenario_02_nfe_03.

      DATA lt_docmn_sub TYPE STANDARD TABLE OF zhms_tb_docmn.
      REFRESH lt_docmn_sub.

**    Identifica o que veio da chamada da função
      READ TABLE it_docum INTO wa_docum WITH KEY dctyp = 'NFE'.
      CONDENSE wa_docum-dcnro NO-GAPS.
      MOVE wa_docum-dcnro TO v_chave.

*** verifica se existe pedido no XML
      SELECT *
        FROM zhms_tb_docmn
        INTO TABLE lt_docmn_sub
       WHERE chave EQ v_chave
         AND mneum EQ 'CFOP'
         AND value NE ' '.

*      SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmn WHERE chave EQ
*      v_chave
*      AND mneum EQ 'CFOP'
*      AND value NE ' '.
      IF sy-subrc IS INITIAL.
        LOOP AT lt_docmn_sub INTO wa_docmn.
          IF wa_docmn-value EQ '5124' OR wa_docmn-value EQ '6124'.
            v_scena = wa_scenario-scena.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.
**    Seleciona dados de cabeçalho do documento
      SELECT SINGLE *
        INTO wa_cabdoc
        FROM zhms_tb_cabdoc
        WHERE chave EQ v_chave
          AND natdc EQ v_natdc
          AND typed EQ v_typed.

**    Seleciona dados de Item do documento
      IF NOT wa_cabdoc IS INITIAL.
        SELECT  *
          INTO TABLE it_itmdoc
          FROM zhms_tb_itmdoc
          WHERE natdc EQ wa_cabdoc-natdc
            AND typed EQ wa_cabdoc-typed
            AND chave EQ wa_cabdoc-chave.
      ENDIF.


      IF NOT v_scena IS INITIAL.
        EXIT.
      ENDIF.
    ENDFORM.                    "f_scenario_02_nfe_03
*---------------------------------------------------------------------*
*       FORM f_scenario_02_nfe_04                                     *
*---------------------------------------------------------------------*
*       nota Fiscal Serviço - ML81N                                   *
*---------------------------------------------------------------------*
    FORM f_scenario_02_nfe_04.

*Renan Itokazo
*15.01.2018
*Correção de lote de NFS-e
*------------------------------------------------
*      IF wa_cabdoc IS INITIAL.
*        SELECT SINGLE *
*          FROM zhms_tb_cabdoc
*          INTO wa_cabdoc WHERE chave EQ wa_docum-chave.
*      ENDIF.
*------------------------------------------------

      READ TABLE it_docum INTO wa_docum WITH KEY dctyp = 'NFE'.
      CONDENSE wa_docum-dcnro NO-GAPS.
      MOVE wa_docum-dcnro TO v_chave.

**    Identifica o que veio da chamada da função
      READ TABLE it_docum INTO wa_docum WITH KEY dctyp = 'NFSE1'.

      IF sy-subrc IS INITIAL.
        v_scena = wa_scenario-scena.
      ELSEIF wa_cabdoc-typed EQ 'NFSE1'.
        v_scena = wa_scenario-scena.
      ENDIF.


*      CONDENSE wa_docum-dcnro NO-GAPS.
*      MOVE wa_docum-dcnro TO v_chave.
*      MOVE wa_cabdoc-chave TO v_chave.

**    Seleciona dados de cabeçalho do documento
      SELECT SINGLE *
        INTO wa_cabdoc
        FROM zhms_tb_cabdoc
        WHERE chave EQ v_chave
          AND natdc EQ v_natdc
          AND typed EQ v_typed.

**    Seleciona dados de Item do documento
      IF NOT wa_cabdoc IS INITIAL.
        SELECT  *
          INTO TABLE it_itmdoc
          FROM zhms_tb_itmdoc
          WHERE natdc EQ wa_cabdoc-natdc
            AND typed EQ wa_cabdoc-typed
            AND chave EQ wa_cabdoc-chave.
      ENDIF.

      IF NOT v_scena IS INITIAL.
        EXIT.
      ENDIF.
    ENDFORM.                    "f_scenario_02_nfe_04
*---------------------------------------------------------------------*
*       FORM f_scenario_02_nfe_05                                     *
*---------------------------------------------------------------------*
*       Nota Fiscal J1B1N                                             *
*---------------------------------------------------------------------*
    FORM f_scenario_02_nfe_05.

      DATA: ls_1baon TYPE j_1baon,
            ls_cfop  TYPE zhms_tb_cfop,
            lv_cfop  TYPE char50,
            lv_cfopf TYPE j_1bcfop,
            lt_docmnx TYPE TABLE OF zhms_tb_docmn.

**    Identifica o que veio da chamada da função
      READ TABLE it_docum INTO wa_docum WITH KEY dctyp = 'NFE'.
      CONDENSE wa_docum-dcnro NO-GAPS.
      MOVE wa_docum-dcnro TO v_chave.

*** verifica se existe pedido no XML
      SELECT * FROM zhms_tb_docmn INTO TABLE lt_docmnx WHERE chave EQ
      v_chave
      AND mneum EQ 'CFOP'
      AND value NE ' '.

      IF sy-subrc IS INITIAL.

        LOOP AT lt_docmnx INTO wa_docmn.

          CLEAR lv_cfop.
          MOVE wa_docmn-value TO lv_cfop.

*** Caso tenha AA restira para evitar duplicidades
          TRANSLATE wa_docmn-value USING 'A '.

          CONCATENATE lv_cfop '/' 'AA' INTO lv_cfop.
          CONDENSE lv_cfop NO-GAPS.

          IF lv_cfop(1) = '6'.
            lv_cfop(1) = '2'.
          ELSEIF lv_cfop(1) = '5'.
            lv_cfop(1) = '1'.
          ENDIF.

*** Modifica Mneumonico CFOP
          wa_docmn-value = lv_cfop.
          MODIFY zhms_tb_docmn FROM wa_docmn.

          IF sy-subrc IS INITIAL.
            COMMIT WORK.
          ENDIF.
        ENDLOOP.

        CALL FUNCTION 'CONVERSION_EXIT_CFOBR_INPUT'
          EXPORTING
            input  = lv_cfop
          IMPORTING
            output = lv_cfopf.

        SELECT SINGLE *
         FROM zhms_tb_cfop
         INTO ls_cfop
        WHERE cfop EQ lv_cfopf.

        IF sy-subrc IS INITIAL.
          v_scena = wa_scenario-scena.
        ENDIF.
      ENDIF.

**    Seleciona dados de cabeçalho do documento
      SELECT SINGLE *
        INTO wa_cabdoc
        FROM zhms_tb_cabdoc
        WHERE chave EQ v_chave
          AND natdc EQ v_natdc
          AND typed EQ v_typed.

**    Seleciona dados de Item do documento
      IF NOT wa_cabdoc IS INITIAL.
        SELECT  *
          INTO TABLE it_itmdoc
          FROM zhms_tb_itmdoc
          WHERE natdc EQ wa_cabdoc-natdc
            AND typed EQ wa_cabdoc-typed
            AND chave EQ wa_cabdoc-chave.
      ENDIF.

    ENDFORM.                    "f_scenario_02_nfe_05
*---------------------------------------------------------------------*
*       FORM f_scenario_02_nfe_07                                     *
*---------------------------------------------------------------------*
*       Entrada Manual                                                *
*---------------------------------------------------------------------*
    FORM f_scenario_02_nfe_07.

      IF wa_cabdoc IS INITIAL.
        SELECT SINGLE *
          FROM zhms_tb_cabdoc
          INTO wa_cabdoc WHERE chave EQ wa_docum-chave.
      ENDIF.


**    Identifica o que veio da chamada da função
      READ TABLE it_docum INTO wa_docum WITH KEY dctyp = 'NFE3'.

      IF sy-subrc IS INITIAL.
        v_scena = wa_scenario-scena.
      ELSEIF wa_cabdoc-typed EQ 'NFE3'.
        v_scena = wa_scenario-scena.
      ENDIF.

      IF sy-tcode = 'ZHMS_DATAENTRY_AUX'.
        READ TABLE it_docum INTO wa_docum INDEX 1.
        v_chave = wa_docum-chave.
      ELSE.
*      CONDENSE wa_docum-dcnro NO-GAPS.
*      MOVE wa_docum-dcnro TO v_chave.
        MOVE wa_cabdoc-chave TO v_chave.
      ENDIF.
**    Seleciona dados de cabeçalho do documento
      SELECT SINGLE *
        INTO wa_cabdoc
        FROM zhms_tb_cabdoc
        WHERE chave EQ v_chave
          AND natdc EQ v_natdc
          AND typed EQ v_typed.

**    Seleciona dados de Item do documento
      IF NOT wa_cabdoc IS INITIAL.
        SELECT  *
          INTO TABLE it_itmdoc
          FROM zhms_tb_itmdoc
          WHERE natdc EQ wa_cabdoc-natdc
            AND typed EQ wa_cabdoc-typed
            AND chave EQ wa_cabdoc-chave.
      ENDIF.

      IF NOT v_scena IS INITIAL.
        EXIT.
      ENDIF.
    ENDFORM.                    "f_scenario_02_nfe_07
*&---------------------------------------------------------------------*
*&      Form  F_SCENARIO_01_CTE_01
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    FORM f_scenario_01_cte_01.

**    Identifica o que veio da chamada da função
      READ TABLE it_docum INTO wa_docum WITH KEY dctyp = 'CHAVE'.
      CONDENSE wa_docum-dcnro NO-GAPS.
      MOVE wa_docum-dcnro TO v_chave.

**    Seleciona dados de cabeçalho do documento
      SELECT SINGLE *
        INTO wa_cabdoc
        FROM zhms_tb_cabdoc
        WHERE chave EQ v_chave
          AND natdc EQ v_natdc
          AND typed EQ v_typed.

**    Seleciona dados de Item do documento
      IF NOT wa_cabdoc IS INITIAL.
        SELECT  *
          INTO TABLE it_itmdoc
          FROM zhms_tb_itmdoc
          WHERE natdc EQ wa_cabdoc-natdc
            AND typed EQ wa_cabdoc-typed
            AND chave EQ wa_cabdoc-chave.
      ENDIF.

      v_scena = wa_scenario-scena.

    ENDFORM.                    "F_SCENARIO_01_CTE_01
*&---------------------------------------------------------------------*
*&      Form  F_SCENARIO_02_NFE_03
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    FORM f_scenario_02_nfe_06.


**    Identifica o que veio da chamada da função
      READ TABLE it_docum INTO wa_docum WITH KEY dctyp = 'CHAVE'.
      CONDENSE wa_docum-dcnro NO-GAPS.
      MOVE wa_docum-dcnro TO v_chave.

**    Seleciona dados de cabeçalho do documento
      SELECT SINGLE *
        INTO wa_cabdoc
        FROM zhms_tb_cabdoc
        WHERE chave EQ v_chave
          AND natdc EQ v_natdc
          AND typed EQ v_typed.

**    Seleciona dados de Item do documento
      IF NOT wa_cabdoc IS INITIAL.
        SELECT  *
          INTO TABLE it_itmdoc
          FROM zhms_tb_itmdoc
          WHERE natdc EQ wa_cabdoc-natdc
            AND typed EQ wa_cabdoc-typed
            AND chave EQ wa_cabdoc-chave.
      ENDIF.

      DATA: ls_consumo TYPE zhms_tb_consumo,
            lt_docmnx  TYPE STANDARD TABLE OF zhms_tb_docmn,
            ls_docmnx  LIKE LINE OF lt_docmnx,
            lv_cnpj    TYPE zhms_de_cnpj,
            lv_ncm     TYPE zhms_de_ncm.

      SELECT *
        FROM zhms_tb_docmn
        INTO TABLE lt_docmnx
       WHERE chave EQ v_chave
         AND mneum EQ 'CNPJ'
          OR mneum EQ 'XMLNCM'.

      IF sy-subrc IS INITIAL.

        READ TABLE lt_docmnx INTO ls_docmnx WITH KEY mneum = 'CNPJ'.

        IF sy-subrc IS INITIAL.

          MOVE ls_docmnx-value TO lv_cnpj.

          READ TABLE lt_docmnx INTO ls_docmnx WITH KEY mneum = 'XMLNCM'.

          IF sy-subrc IS INITIAL.

            MOVE ls_docmnx TO lv_ncm.

            SELECT SINGLE *
              FROM zhms_tb_consumo
              INTO ls_consumo
             WHERE cnpj EQ lv_cnpj
               AND ncm  EQ lv_ncm.

            IF sy-subrc IS INITIAL.
              v_scena = wa_scenario-scena.
            ELSE.
              SELECT SINGLE *
                FROM zhms_tb_consumo
                INTO ls_consumo
               WHERE cnpj EQ lv_cnpj.

              IF sy-subrc IS INITIAL.
                v_scena = wa_scenario-scena.
              ENDIF.
            ENDIF.

          ENDIF.
        ENDIF.
      ENDIF.

    ENDFORM.                    "F_SCENARIO_02_NFE_03
*&---------------------------------------------------------------------*
*&      Form  f_entradanormal_atrauto
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
    FORM f_entradanormal_atrauto TABLES p_it_hrvalid STRUCTURE wa_hrvalid..

      DATA: po_number     TYPE bapimepoheader-po_number,
            ls_po_header  TYPE  bapimepoheader,
            lt_po_item    TYPE STANDARD TABLE OF bapimepoitem,
            lt_hist_total TYPE STANDARD TABLE OF bapiekbes,
            ls_hist_total LIKE LINE OF lt_hist_total,
            ls_po_item    LIKE LINE OF lt_po_item,
            lv_item       TYPE zhms_de_value,
            lv_qtd        TYPE zhms_de_value,
            lv_atqtde     TYPE zhms_de_value,
            lv_qtd_at     TYPE zhms_de_value,
            lv_icms       TYPE zhms_de_value,
            lv_ipi        TYPE zhms_de_value,
            lv_sqn        TYPE zhms_de_value,
            lv_pis        TYPE zhms_de_value,
            lv_cof        TYPE zhms_de_value,
            lv_sst        TYPE zhms_de_value,
            lv_calc       TYPE wemng,
            lv_calc2      TYPE wemng,
            lv_calc3      TYPE wemng,
            lv_calc4      TYPE wemng,
            lv_tot_kbetr  TYPE komv-kbetr,
            lv_cont_1baj  TYPE i,
            lv_div_ped    TYPE komv-kbetr,
            lv_div_xml    TYPE komv-kbetr,
            lv_div_ped_c  TYPE char20,
            lv_div_xml_c  TYPE char20,
            lv_dif        TYPE p DECIMALS 2 VALUE '0.10',
            lv_sub        TYPE komv-kbetr,
            lv_ebeln      TYPE ebeln.

*** Seleciona quis validações estão habilitadas
      REFRESH t_tb_vld_tax[].
      SELECT *
        FROM zhms_tb_vld_tax
        INTO TABLE t_tb_vld_tax
       WHERE tax_type NE ' '.

      SELECT *
        INTO TABLE it_mapdata_aux
        FROM zhms_tb_mapdata
       WHERE codmp EQ '01'.

* Verifica dados encontrados
      IF it_mapdata_aux[] IS INITIAL.
        RAISE mapping_data_not_found.
      ELSE.
        REFRESH it_mapdata[].
        LOOP AT it_mapdata_aux INTO wa_mapdata.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_mapdata-seqnr
            IMPORTING
              output = wa_mapdata-seqnr.

          APPEND wa_mapdata TO it_mapdata.
        ENDLOOP.
      ENDIF.
      PERFORM f_mneum_entradanormal IN PROGRAM saplzhms_fg_ruler USING '01' ' 20 ' IF FOUND.
      PERFORM f_atualiza_mn IN PROGRAM saplzhms_fg_ruler IF FOUND.

** Dados de Item
      REFRESH it_itmdoc.
      SELECT *
        INTO TABLE it_itmdoc
        FROM zhms_tb_itmdoc
       WHERE natdc EQ wa_cabdoc-natdc
         AND typed EQ wa_cabdoc-typed
         AND loctp EQ wa_cabdoc-loctp
         AND chave EQ wa_cabdoc-chave.


      LOOP AT it_itmdoc INTO wa_itmdoc.

        REFRESH lt_po_item[].
        CLEAR: wa_docmnx, wa_ekko, vg_message, ls_po_item.

*** Verifica se o pedido existe
        SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_itmdoc-chave
                                                             AND mneum EQ 'XPED'
                                                             AND dcitm EQ wa_itmdoc-dcitm.

        MOVE wa_docmnx-value TO lv_ebeln.


        CHECK lv_ebeln IS NOT INITIAL.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_ebeln
          IMPORTING
            output = lv_ebeln.

        SELECT SINGLE * FROM ekko INTO wa_ekko WHERE ebeln EQ lv_ebeln.

        IF sy-subrc IS NOT INITIAL.

          SELECT SINGLE text grp INTO (vg_message, wa_hrvalid-grp) FROM zhms_tb_messages WHERE code EQ '200'.

          MOVE: wa_cabdoc-natdc  TO wa_hrvalid-natdc,
                wa_cabdoc-typed  TO wa_hrvalid-typed,
                wa_cabdoc-loctp  TO wa_hrvalid-loctp,
                wa_cabdoc-chave  TO wa_hrvalid-chave,
                '1'              TO wa_hrvalid-seqnr,
                sy-datum         TO wa_hrvalid-dtreg,
                sy-uzeit         TO wa_hrvalid-hrreg,
                wa_itmatr-atitm  TO wa_hrvalid-atitm,
                'E'              TO wa_hrvalid-vldty,
                '200'            TO wa_hrvalid-vldv1,
                vg_message       TO wa_hrvalid-vldv2,
                'X'              TO wa_hrvalid-ativo.
          APPEND wa_hrvalid TO p_it_hrvalid.
          CLEAR wa_hrvalid.

        ENDIF.


*** Busca Detalhes Pedido de compras
*** Inicio alteração david rosin 16/07/2015
*    MOVE wa_docmnx-value TO po_number.
        MOVE lv_ebeln TO po_number.
*** Fim alteração david rosin 16/07/2015

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = po_number
          IMPORTING
            output = po_number.

        CALL FUNCTION 'BAPI_PO_GETDETAIL1'
          EXPORTING
            purchaseorder    = po_number
          IMPORTING
            poheader         = ls_po_header
          TABLES
            poitem           = lt_po_item
            pohistory_totals = lt_hist_total.

****Verifica se o pedido não está liberado no sistema
        IF wa_ekko IS NOT INITIAL AND wa_ekko-frgke NE 'L' AND vg_message IS INITIAL.

          SELECT SINGLE text grp INTO (vg_message, wa_hrvalid-grp) FROM zhms_tb_messages WHERE code EQ '0006'.

          MOVE: wa_cabdoc-natdc  TO wa_hrvalid-natdc,
                wa_cabdoc-typed  TO wa_hrvalid-typed,
                wa_cabdoc-loctp  TO wa_hrvalid-loctp,
                wa_cabdoc-chave  TO wa_hrvalid-chave,
                '1'              TO wa_hrvalid-seqnr,
                sy-datum         TO wa_hrvalid-dtreg,
                sy-uzeit         TO wa_hrvalid-hrreg,
                wa_itmdoc-dcitm  TO wa_hrvalid-atitm,
                'E'              TO wa_hrvalid-vldty,
                '0006'           TO wa_hrvalid-vldv1,
                vg_message       TO wa_hrvalid-vldv2,
                'X'              TO wa_hrvalid-ativo.
          APPEND wa_hrvalid TO p_it_hrvalid.
          CLEAR wa_hrvalid.

        ENDIF.

*** Verifica pedido para fornecedor
        SELECT SINGLE * FROM ekko INTO wa_ekko WHERE ebeln EQ lv_ebeln
                                                 AND lifnr EQ ls_po_header-vendor.

        IF sy-subrc IS NOT INITIAL.

          SELECT SINGLE text grp INTO (vg_message, wa_hrvalid-grp) FROM zhms_tb_messages WHERE code EQ '0005'.

          MOVE: wa_cabdoc-natdc  TO wa_hrvalid-natdc,
                wa_cabdoc-typed  TO wa_hrvalid-typed,
                wa_cabdoc-loctp  TO wa_hrvalid-loctp,
                wa_cabdoc-chave  TO wa_hrvalid-chave,
                '1'              TO wa_hrvalid-seqnr,
                sy-datum         TO wa_hrvalid-dtreg,
                sy-uzeit         TO wa_hrvalid-hrreg,
                wa_itmatr-atitm  TO wa_hrvalid-atitm,
                'E'              TO wa_hrvalid-vldty,
                '0005'           TO wa_hrvalid-vldv1,
                vg_message       TO wa_hrvalid-vldv2,
                'X'              TO wa_hrvalid-ativo.
          APPEND wa_hrvalid TO p_it_hrvalid.
          CLEAR wa_hrvalid.
        ENDIF.

*** Verifica item atribuido do PO
        CLEAR: wa_docmnx, ls_po_item.
        SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_cabdoc-chave
                                                             AND mneum EQ 'ATITMPED' "'NITEMPED' RRO 10/01/2019
                                                             AND dcitm EQ wa_itmdoc-dcitm.
*--------------------------------------------------------------------*
        IF sy-subrc IS NOT INITIAL.
          CLEAR wa_docmnx.
          SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_cabdoc-chave
                                                               AND mneum EQ 'NITEMPED'
                                                               AND dcitm EQ wa_itmdoc-dcitm.
        ENDIF.
*--------------------------------------------------------------------*
        IF sy-subrc IS INITIAL.
          READ TABLE lt_po_item INTO ls_po_item WITH KEY po_item = wa_docmnx-value BINARY SEARCH.

          IF sy-subrc IS NOT INITIAL.

            SELECT SINGLE text grp INTO (vg_message, wa_hrvalid-grp)  FROM zhms_tb_messages WHERE code EQ '0007'.

            MOVE: wa_cabdoc-natdc  TO wa_hrvalid-natdc,
                  wa_cabdoc-typed  TO wa_hrvalid-typed,
                  wa_cabdoc-loctp  TO wa_hrvalid-loctp,
                  wa_cabdoc-chave  TO wa_hrvalid-chave,
                  '1'              TO wa_hrvalid-seqnr,
                  sy-datum         TO wa_hrvalid-dtreg,
                  sy-uzeit         TO wa_hrvalid-hrreg,
                  wa_itmatr-atitm  TO wa_hrvalid-atitm,
                  'E'              TO wa_hrvalid-vldty,
                  '0007'           TO wa_hrvalid-vldv1,
                  vg_message       TO wa_hrvalid-vldv2,
                  'X'              TO wa_hrvalid-ativo.
            APPEND wa_hrvalid TO p_it_hrvalid.
            CLEAR wa_hrvalid.

          ENDIF.
        ENDIF.

*** Verifica se o item do pedido esta bloqueado
        CLEAR: wa_docmnx, ls_po_item.
        SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_cabdoc-chave
                                                             AND mneum EQ 'ATITMPED' "'NITEMPED' RRO 10/01/2019
                                                             AND dcitm EQ wa_itmdoc-dcitm.
*--------------------------------------------------------------------*
        IF sy-subrc IS NOT INITIAL.
          CLEAR wa_docmnx.
          SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_cabdoc-chave
                                                               AND mneum EQ 'NITEMPED'
                                                               AND dcitm EQ wa_itmdoc-dcitm.
        ENDIF.
*--------------------------------------------------------------------*
        IF sy-subrc IS INITIAL.
          READ TABLE lt_po_item INTO ls_po_item WITH KEY po_item = wa_docmnx-value BINARY SEARCH.

          IF sy-subrc IS INITIAL AND ls_po_item-delete_ind IS NOT INITIAL.
            SELECT SINGLE text grp INTO (vg_message, wa_hrvalid-grp) FROM zhms_tb_messages WHERE code EQ '0008'.

            MOVE: wa_cabdoc-natdc  TO wa_hrvalid-natdc,
                  wa_cabdoc-typed  TO wa_hrvalid-typed,
                  wa_cabdoc-loctp  TO wa_hrvalid-loctp,
                  wa_cabdoc-chave  TO wa_hrvalid-chave,
                  '1'              TO wa_hrvalid-seqnr,
                  sy-datum         TO wa_hrvalid-dtreg,
                  sy-uzeit         TO wa_hrvalid-hrreg,
                  wa_itmatr-atitm  TO wa_hrvalid-atitm,
                  'E'              TO wa_hrvalid-vldty,
                  '0008'           TO wa_hrvalid-vldv1,
                  vg_message       TO wa_hrvalid-vldv2,
                  'X'              TO wa_hrvalid-ativo.
            APPEND wa_hrvalid TO p_it_hrvalid.
            CLEAR wa_hrvalid.

          ENDIF.
        ENDIF.


***Valida NCM
        CLEAR: wa_docmnx, ls_po_item.
        SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_cabdoc-chave
                                                             AND mneum EQ 'ATITMPED' "'NITEMPED' 10/01/2019
                                                             AND dcitm EQ wa_itmdoc-dcitm.
*--------------------------------------------------------------------*
        IF sy-subrc IS NOT INITIAL.
          CLEAR: wa_docmnx, ls_po_item.
          SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_cabdoc-chave
                                                               AND mneum EQ 'NITEMPED'
                                                               AND dcitm EQ wa_itmdoc-dcitm.
        ENDIF.
*--------------------------------------------------------------------*
        READ TABLE lt_po_item INTO ls_po_item WITH KEY po_item = wa_docmnx-value BINARY SEARCH.
        CLEAR: wa_docmnx.
        SELECT SINGLE * FROM zhms_tb_docmn INTO wa_docmnx  WHERE chave EQ wa_cabdoc-chave
                                                             AND mneum EQ 'XMLNCM'
                                                             AND dcitm EQ wa_itmdoc-dcitm.

        TRANSLATE ls_po_item-bras_nbm USING '. '.
        TRANSLATE wa_docmnx-value USING '. '.
        CONDENSE ls_po_item-bras_nbm NO-GAPS.
        CONDENSE wa_docmnx-value NO-GAPS.

        CLEAR: vg_ncm_xml, vg_ncm_mne.
        MOVE: ls_po_item-bras_nbm TO vg_ncm_mne,
              wa_docmnx-value TO vg_ncm_xml.

        READ TABLE t_tb_vld_tax INTO ls_tb_vld_tax WITH KEY tax_type = 'NCM'.

        IF ls_po_item-bras_nbm NE vg_ncm_xml AND ls_tb_vld_tax-ativo IS NOT INITIAL.
          SELECT SINGLE text grp INTO (vg_message, wa_hrvalid-grp) FROM zhms_tb_messages WHERE code EQ '0009'.

          MOVE  wa_docmni-atitm  TO wa_itmatr-atitm.
          MOVE: wa_cabdoc-natdc  TO wa_hrvalid-natdc,
                wa_cabdoc-typed  TO wa_hrvalid-typed,
                wa_cabdoc-loctp  TO wa_hrvalid-loctp,
                wa_cabdoc-chave  TO wa_hrvalid-chave,
                '1'              TO wa_hrvalid-seqnr,
                sy-datum         TO wa_hrvalid-dtreg,
                sy-uzeit         TO wa_hrvalid-hrreg,
                wa_itmatr-atitm  TO wa_hrvalid-atitm,
                'E'              TO wa_hrvalid-vldty,
                '0009'           TO wa_hrvalid-vldv1,
                vg_message       TO wa_hrvalid-vldv2,
                'X'              TO wa_hrvalid-ativo.
          APPEND wa_hrvalid TO p_it_hrvalid.
          CLEAR wa_hrvalid.

        ENDIF.




        IF vg_message IS NOT INITIAL. " Armazena Log de validações

*** Verifica se mensagens ainda s]ao necessarias
          DATA  lt_hrvalid TYPE STANDARD TABLE OF zhms_tb_hrvalid .
          SELECT * FROM zhms_tb_hrvalid INTO TABLE lt_hrvalid WHERE chave EQ  wa_cabdoc-chave
                                                                AND ativo EQ abap_true.

          IF sy-subrc IS INITIAL.
            LOOP AT  lt_hrvalid INTO wa_hrvalid.

              READ TABLE  p_it_hrvalid INTO wa_hrvalid WITH KEY natdc = wa_hrvalid-natdc
                                                                typed = wa_hrvalid-typed
                                                                chave = wa_hrvalid-chave
                                                                atitm = wa_hrvalid-atitm
                                                                dtreg = wa_hrvalid-dtreg
                                                                vldv1 = wa_hrvalid-vldv1
                                                                grp   = wa_hrvalid-grp.

              IF sy-subrc IS NOT INITIAL.

                UPDATE zhms_tb_hrvalid
                SET ativo = ' '
                WHERE natdc = wa_hrvalid-natdc
                  AND typed = wa_hrvalid-typed
                  AND chave = wa_hrvalid-chave
                  AND atitm = wa_hrvalid-atitm
                  AND dtreg = wa_hrvalid-dtreg
                  AND vldv1 = wa_hrvalid-vldv1
                  AND grp   = wa_hrvalid-grp.

                IF sy-subrc IS INITIAL.
                  COMMIT WORK.
                ELSE.
                  ROLLBACK WORK.
                ENDIF.

              ENDIF.

            ENDLOOP.
          ENDIF.
        ELSE.

*--------------------------------------------------------------------*
          IF p_it_hrvalid[] IS INITIAL.
            REFRESH lt_hrvalid.
            SELECT * FROM zhms_tb_hrvalid INTO TABLE lt_hrvalid WHERE chave EQ wa_cabdoc-chave
                                                                  AND ativo EQ abap_true.
            CLEAR wa_hrvalid.
            LOOP AT lt_hrvalid INTO wa_hrvalid.

              UPDATE zhms_tb_hrvalid
                 SET ativo = ' '
*             WHERE chave = wa_docmn-chave
*               AND atitm = wa_itmdoc-dcitm.
                  WHERE natdc = wa_hrvalid-natdc
                    AND typed = wa_hrvalid-typed
                    AND chave = wa_hrvalid-chave
                    AND atitm = wa_hrvalid-atitm
                    AND dtreg = wa_hrvalid-dtreg
                    AND vldv1 = wa_hrvalid-vldv1
                    AND grp   = wa_hrvalid-grp.

              CLEAR wa_hrvalid.
            ENDLOOP.

            IF sy-subrc IS INITIAL.
              COMMIT WORK.
            ELSE.
              ROLLBACK WORK.
            ENDIF.
          ENDIF.
        ENDIF.

      ENDLOOP.
    ENDFORM.                    " f_entradanormal_atrauto
