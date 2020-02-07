
*&---------------------------------------------------------------------*
*&  Include           LZHMS_FG_RULERDFM
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*   Form  F_EMITE_NFE
*----------------------------------------------------------------------*
*   Emissão de NF-e Mercantil
*----------------------------------------------------------------------*
*    FORM f_emite_nfe USING p_codmp.
*      DATA vl_subrc TYPE sy-subrc.
*
****   Selecionando dados a serem processados
*      PERFORM f_sel_emite_nfe CHANGING vl_subrc.
*
****   Carregando Valores do Grupo 01
**      PERFORM f_mapping_mn USING '01'
**                                 vg_acckey
**                                 p_codmp.
*
****   Lendo código CNAE para a Empresa / Filial
*      CLEAR wa_cnae.
*      READ TABLE it_cnae INTO wa_cnae
*                 WITH KEY bukrs  = wa_nfdoc-bukrs
*                          branch = wa_nfdoc-branch BINARY SEARCH.
*
****   Ponteiro para funções de Parceiros
*      LOOP AT it_nfnad INTO wa_nfnad WHERE docnum EQ wa_nfdoc-docnum.
****     Lendo Tipo de Parceiro de Negócio
*        CLEAR wa_dp_parvw.
*        READ TABLE it_dp_parvw INTO wa_dp_parvw
*                   WITH KEY parvw = wa_nfnad-parvw BINARY SEARCH.
*
*        IF sy-subrc EQ 0.
****       Lendo dados do Parceiros de Negócio
*          PERFORM f_read_parid USING wa_dp_parvw-pcxml.
*        ENDIF.
*
****     Carregando Valores do Grupo 02
**       PERFORM f_set_value USING '02'.
*
****     Ponteiro para Contas Contábeis dos Parceiros
*        LOOP AT it_nfcpd INTO wa_nfcpd WHERE docnum EQ wa_nfdoc-docnum  AND
*                                             parvw  EQ wa_nfnad-parvw.
****       Carregando Valores do Grupo 03
**         PERFORM f_set_value USING '03'.
*        ENDLOOP.
*      ENDLOOP.
*
****   Ponteiro para Itens do Documento
*      LOOP AT it_nflin INTO wa_nflin WHERE docnum EQ wa_nfdoc-docnum.
****     Lendo informações do Centro
*        CLEAR wa_t001w.
*        READ TABLE it_t001w INTO wa_t001w
*                            WITH KEY werks = wa_nflin-werks BINARY SEARCH.
*
*        IF sy-subrc EQ 0.
*        ENDIF.
*
****     Ponteiro para Impostos dos Itens do Documento
*        LOOP AT it_nfstx INTO wa_nfstx WHERE docnum EQ wa_nflin-docnum    AND
*                                             itmnum EQ wa_nflin-itmnum.
*        ENDLOOP.
*      ENDLOOP.
*
****   Ponteiro para Mensagens de Cabeçalho
*      LOOP AT it_nfftx INTO wa_nfftx WHERE docnum EQ wa_nfdoc-docnum.
*      ENDLOOP.
*
****   Ponteiro para Documentos Relacionados
*      LOOP AT it_nfref INTO wa_nfref WHERE docnum EQ wa_nfdoc-docnum.
*      ENDLOOP.
*    ENDFORM.                    "F_EMITE_NFE
*
**----------------------------------------------------------------------*
**   Form  F_SEL_EMITE_NFE
**----------------------------------------------------------------------*
**   Selecionando dados a serem processados
**----------------------------------------------------------------------*
*    FORM f_sel_emite_nfe CHANGING p_subrc.
*      DATA vl_docnum TYPE j_1bnfdoc-docnum.
*
****   Ler dados recebidos em busca do número da nota
*      CLEAR wa_docum.
*      READ TABLE it_docum INTO wa_docum WITH KEY dctyp = 'DOCNUM'.
*
*      IF wa_msgdata-value IS INITIAL.
*        MOVE '4' TO p_subrc.
*      ELSE.
****     Inicializando variáveis
*        PERFORM f_clear_all.
*
****     Selecionando informações do Documento Fiscal
*        CALL FUNCTION 'BAPI_J_1B_NF_GETDETAIL'
*          EXPORTING
*            docnum         = vl_docnum
*          IMPORTING
*            obj_header     = wa_nfdoc
*          TABLES
*            obj_partner    = it_nfnad
*            obj_item       = it_nflin
*            obj_item_tax   = it_nfstx
*            obj_header_msg = it_nfftx
*            obj_refer_msg  = it_nfref
*            obj_ot_partner = it_nfcpd
*            return         = it_retur.
*
*        IF it_retur[] IS INITIAL.
****       Erro ao ler o Documento
*          MESSAGE i001.
*          MOVE '4' TO p_subrc.
*        ELSE.
****       Selecionando Parceiros de Negócio
*          PERFORM f_sel_partners.
****       Lendo informações da Filial de Emissão
*          PERFORM f_sel_branch USING ''.
****       Obtendo informações Referenciadas
*          PERFORM f_sel_ref_nfe.
*
*
*
*
*
*
*
****       Obtendo Chave da NFe
*          PERFORM f_get_chave_nfe.
****       Lendo informações complementares da Nota
*          PERFORM f_sel_compl_nfs.
****       Lendo parametrizações
*          PERFORM f_sel_param.
****       Lendo informações dos Dados Mestres
*          PERFORM f_sel_masterd.
*
*          MOVE '0' TO p_subrc.
*        ENDIF.
*      ENDIF.
*    ENDFORM.                    " F_SEL_EMITE_NFE
*
**----------------------------------------------------------------------*
**   Form  F_CLEAR_ALL
**----------------------------------------------------------------------*
**   Inicializando variáveis
**----------------------------------------------------------------------*
*    FORM f_clear_all.
*    ENDFORM.                    " F_CLEAR_ALL
*
**----------------------------------------------------------------------*
**   Form  F_SEL_COMPL_NFS
**----------------------------------------------------------------------*
**   Lendo informações complementares da Nota
**----------------------------------------------------------------------*
*    FORM f_sel_compl_nfs.
*      IF NOT wa_nfdoc IS INITIAL.
****     Obtendo valores totais da Nota
*        CALL FUNCTION 'J_1B_NF_VALUE_DETERMINATION'
*          EXPORTING
*            nf_header     = wa_nfdoc
*          IMPORTING
*            ext_header    = wa_nfdoc_tot
*          TABLES
*            nf_item       = it_nflin_tot
*            nf_item_tax   = it_nfstx_tot
*            ext_item      = it_inlin_tot
*            ext_total_tax = it_intax_tot.
*
****     Lendo informações eletrônicas do documento
*        SELECT SINGLE *
*               FROM j_1bnfe_active
*               INTO wa_nfact
*               WHERE docnum EQ wa_nfdoc-docnum.
*      ENDIF.
*    ENDFORM.                    " F_SEL_COMPL_NFS
*
**----------------------------------------------------------------------*
**   Form  F_SEL_PARAM
**----------------------------------------------------------------------*
**   Lendo parametrizações
**----------------------------------------------------------------------*
*    FORM f_sel_param.
*      IF NOT it_nfstx[] IS INITIAL.
****     Lendo dados do Tipo de Imposto
*        SELECT *
*               FROM j_1baj
*               INTO TABLE it_j1baj
*               FOR ALL ENTRIES IN it_nfstx
*               WHERE taxtyp EQ it_nfstx-taxtyp.
*
*        IF sy-subrc EQ 0.
*          SORT it_j1baj BY taxtyp taxgrp.
*        ENDIF.
*      ENDIF.
*
*      IF NOT wa_nfdoc IS INITIAL.
****     Selecionando informações do Categoria de Nota Fiscal
*        CALL FUNCTION 'J_1BAA_READ'
*          EXPORTING
*            nota_fiscal_type     = wa_nfdoc-nftype
*          IMPORTING
*            e_j_1baa             = wa_j1baa
*          EXCEPTIONS
*            not_found            = 1
*            parameters_incorrect = 2
*            OTHERS               = 3.
*
*      ENDIF.
*
****   Lendo Indicadores de Condição de Pagamento
*      SELECT SINGLE *
*             FROM zhms_tb_condpagt
*             INTO wa_condpagt
*             WHERE zterm EQ wa_nfdoc-zterm.
*
*    ENDFORM.                    " F_SEL_PARAM
*
**----------------------------------------------------------------------*
**   Form  F_SEL_MASTERD
**----------------------------------------------------------------------*
**   Lendo informações dos Dados Mestres
**----------------------------------------------------------------------*
*    FORM f_sel_masterd.
*      CHECK NOT wa_nfdoc IS INITIAL.
*
*
*
*
*
**      IF NOT wa_custdeth-address IS INITIAL.
*****     Selecionando endereços de email
**        SELECT *
**               FROM adr6
**               INTO TABLE it_adr6
**               WHERE addrnumber EQ wa_custdeth-address.
**      ENDIF.
*
*      IF NOT it_nflin[] IS INITIAL.
****     Lendo informações do Centro
*        SELECT *
*               FROM t001w
*               INTO TABLE it_t001w
*               FOR ALL ENTRIES IN it_nflin
*               WHERE werks EQ it_nflin-werks.
*
*        IF sy-subrc EQ 0.
*          SORT it_t001w BY werks.
*        ENDIF.
*      ENDIF.
*
****   Lendo Local de Expedição por Centro
*      SELECT SINGLE *
*             FROM tvstz
*             INTO wa_tvstz
*             WHERE vstel EQ wa_nfdoc-vstel.
*
*      IF sy-subrc EQ 0.
****     Lendo detalhes do Local de Expedição
*        CALL FUNCTION 'J_1BREAD_PLANT_DATA'
*          EXPORTING
*            plant             = wa_tvstz-werks
*          IMPORTING
*            address           = wa_pl_addr
*            branch_data       = wa_pl_branc
*            cgc_number        = vg_pl_cnpj
*          EXCEPTIONS
*            plant_not_found   = 1
*            branch_not_found  = 2
*            address_not_found = 3
*            company_not_found = 4
*            OTHERS            = 5.
*      ENDIF.
*
****   Lendo códigos CNAE
*      SELECT *
*             FROM zhms_tb_cnae
*             INTO TABLE it_cnae
*             WHERE bukrs  EQ wa_nfdoc-bukrs      AND
*                   branch EQ wa_nfdoc-branch.
*
*      IF sy-subrc EQ 0.
*        SORT it_cnae BY bukrs branch.
*      ENDIF.
*    ENDFORM.                    " F_SEL_MASTERD
*
**----------------------------------------------------------------------*
**   Form  f_get_chave_nfe
**----------------------------------------------------------------------*
**   Obtendo Chave da NFe
**----------------------------------------------------------------------*
*    FORM f_get_chave_nfe.
*      DATA  wa_acckey TYPE j_1b_nfe_access_key.
*      CLEAR wa_acckey.
*
****   Obtendo Número da Chave da NFe
*      CALL FUNCTION 'J_1B_NFE_FILL_MONITOR_TABLE'
*        EXPORTING
*          i_doc          = wa_nfdoc
*          i_docnum       = wa_nfdoc-docnum
*          i_seriechecked = 'X'
*          i_partner      = wa_nfcpd
*        IMPORTING
*          e_acckey       = wa_acckey.
*
*      IF wa_acckey IS INITIAL.
*        CLEAR vg_acckey.
*        CONCATENATE wa_acckey-regio
*                    wa_acckey-nfyear
*                    wa_acckey-nfmonth
*                    wa_acckey-stcd1
*                    wa_acckey-model
*                    wa_acckey-serie
*                    wa_acckey-nfnum9
*                    wa_acckey-docnum9
*                    wa_acckey-cdv
*               INTO vg_acckey.
*      ENDIF.
*    ENDFORM.                    "f_get_chave_nfe
*
**----------------------------------------------------------------------*
**   Form  F_SEL_REF_NFE
**----------------------------------------------------------------------*
**   Obtendo informações Referenciadas
**----------------------------------------------------------------------*
*    FORM f_sel_ref_nfe.
*      IF NOT wa_nfdoc-docref IS INITIAL.
****     Selecionando informações do Documento Fiscal
*        CALL FUNCTION 'BAPI_J_1B_NF_GETDETAIL'
*          EXPORTING
*            docnum         = wa_nfdoc-docref
*          IMPORTING
*            obj_header     = wa_nfdoc_ref
*          TABLES
*            obj_partner    = it_nfnad_ref
*            obj_item       = it_nflin_ref
*            obj_item_tax   = it_nfstx_ref
*            obj_header_msg = it_nfftx_ref
*            obj_refer_msg  = it_nfref_ref
*            obj_ot_partner = it_nfcpd_ref
*            return         = it_retur_ref.
*      ENDIF.
*    ENDFORM.                    " F_SEL_REF_NFE
*
**----------------------------------------------------------------------*
**   Form  F_READ_PARID
**----------------------------------------------------------------------*
**   Lendo dados do Parceiros de Negócio
**----------------------------------------------------------------------*
*    FORM f_read_parid USING p_wa_dp_parvw_pcxml.
*
*    ENDFORM.                    " F_READ_PARID
*
**----------------------------------------------------------------------*
**   Form  F_SEL_PARTNERS
**----------------------------------------------------------------------*
**   Selecionando Parceiros de Negócio
**----------------------------------------------------------------------*
*    FORM f_sel_partners.
****   Lendo De-Para de Parceiros de Negócio
*      SELECT *
*             FROM zhms_tb_dp_parvw
*             INTO TABLE it_dp_parvw.
*
*      IF sy-subrc EQ 0.
*        SORT it_dp_parvw BY parvw.
*
*        LOOP AT it_nfnad INTO wa_nfnad.
*          CLEAR wa_dp_parvw.
*          READ TABLE it_dp_parvw INTO wa_dp_parvw
*                                 WITH KEY parvw = wa_nfnad-parvw
*                                 BINARY SEARCH.
*
*          IF sy-subrc EQ 0.
*            CASE wa_dp_parvw-pcxml.
*              WHEN 'D'.
****             Preenchendo Tabela de Destinatário
*                PERFORM f_fill_parc_tab USING 'D'.
*
*              WHEN 'R'.
****             Preenchendo Tabela de Retirada
*                PERFORM f_fill_parc_tab USING 'R'.
*
*              WHEN 'E'.
****             Preenchendo Tabela de Entrega
*                PERFORM f_fill_parc_tab USING 'E'.
*
*              WHEN 'T'.
****             Preenchendo Tabela de Transportadora
*                PERFORM f_fill_parc_tab USING 'T'.
*
*              WHEN OTHERS.
*            ENDCASE.
*          ENDIF.
*        ENDLOOP.
*      ELSE.
****     Parametrização dos Parceiros inexistente
*        MESSAGE i000.
*      ENDIF.
*    ENDFORM.                    " F_SEL_PARTNERS
*
**----------------------------------------------------------------------*
**   Form  F_FILL_PARC_TAB
**----------------------------------------------------------------------*
**   Preenchendo Tabela de Parceiros
**----------------------------------------------------------------------*
*    FORM f_fill_parc_tab USING p_type.
*      CASE wa_nfnad-partyp.
*        WHEN 'B'.
****       Carregando informações da Filial
*          PERFORM f_sel_branch USING p_type.
*
*        WHEN 'C'.
****       Carregando informações do Cliente
*          PERFORM f_sel_custumer USING p_type.
*
*        WHEN 'V'.
****       Carregando informações do Fornecedor
*          PERFORM f_sel_vendor USING p_type.
*
*        WHEN OTHERS.
*
*      ENDCASE.
*    ENDFORM.                    " F_FILL_PARC_TAB
*
**----------------------------------------------------------------------*
**   Form  F_SEL_BRANCH
**----------------------------------------------------------------------*
**   Carregando informações da Filial
**----------------------------------------------------------------------*
*    FORM f_sel_branch USING p_type.
*      CLEAR: vc_bran_addr, vc_bran_data, vc_bran_cnpj,
*             vc_bran_add1.
*
*      UNASSIGN: <bran_addr>, <bran_data>, <bran_cnpj>,
*                <bran_add1>.
*
*      IF p_type IS INITIAL.
*        MOVE: c_bran_addr TO vc_bran_addr,
*              c_bran_data TO vc_bran_data,
*              c_bran_cnpj TO vc_bran_cnpj,
*              c_bran_add1 TO vc_bran_add1.
*      ELSE.
*        CONCATENATE: c_bran_addr '_' p_type INTO vc_bran_addr,
*                     c_bran_data '_' p_type INTO vc_bran_data,
*                     c_bran_cnpj '_' p_type INTO vc_bran_cnpj,
*                     c_bran_add1 '_' p_type INTO vc_bran_add1.
*      ENDIF.
*
*      ASSIGN: (vc_bran_addr) TO <bran_addr>,
*              (vc_bran_data) TO <bran_data>,
*              (vc_bran_cnpj) TO <bran_cnpj>,
*              (vc_bran_add1) TO <bran_add1>.
*
****   Selecionando informações da Filial
*      CALL FUNCTION 'J_1BREAD_BRANCH_DATA'
*        EXPORTING
*          branch            = wa_nfdoc-branch
*          bukrs             = wa_nfdoc-bukrs
*        IMPORTING
*          address           = <bran_addr>
*          branch_data       = <bran_data>
*          cgc_number        = <bran_cnpj>
*          address1          = <bran_add1>
*        EXCEPTIONS
*          branch_not_found  = 1
*          address_not_found = 2
*          company_not_found = 3
*          OTHERS            = 4.
*
*      IF sy-subrc EQ 0.
*
*      ENDIF.
*    ENDFORM.                    " F_SEL_BRANCH
*
**----------------------------------------------------------------------*
**   Form  F_SEL_CUSTUMER
**----------------------------------------------------------------------*
**   Carregando informações do Cliente
**----------------------------------------------------------------------*
*    FORM f_sel_custumer USING p_type.
*      CLEAR: vc_cust_addr, vc_cust_deth, vc_cust_detc,
*             vc_cust_ret1, vc_cust_detb.
*
*      UNASSIGN: <cust_addr>, <cust_deth>, <cust_detc>,
*                <bapi_ret1>, <cust_detb>.
*
*      CONCATENATE: c_cust_addr p_type INTO vc_cust_addr,
*                   c_cust_detc p_type INTO vc_cust_detc,
*                   c_cust_ret1 p_type INTO vc_cust_ret1,
*                   c_cust_detb p_type INTO vc_cust_detb.
*
*      ASSIGN: (vc_cust_addr) TO <cust_addr>,
*              (vc_cust_deth) TO <cust_deth>,
*              (vc_cust_detc) TO <cust_detc>,
*              (vc_cust_ret1) TO <bapi_ret1>,
*              (vc_cust_detb) TO <cust_detb>.
*
****   Lendo informações do Cliente
*      CALL FUNCTION 'BAPI_CUSTOMER_GETDETAIL2'
*        EXPORTING
*          customerno            = wa_nfdoc-parid
*          companycode           = wa_nfdoc-bukrs
*        IMPORTING
*          customeraddress       = <cust_addr>
*          customergeneraldetail = <cust_deth>
*          customercompanydetail = <cust_detc>
*          return                = <bapi_ret1>
*        TABLES
*          customerbankdetail    = <cust_detb>.
*
**      IF NOT wa_custdeth-address IS INITIAL.
****     Selecionando endereços de email
**        SELECT *
**               FROM adr6
**               INTO TABLE it_adr6
**               WHERE addrnumber EQ wa_custdeth-address.
**      ENDIF.
*    ENDFORM.                    " F_SEL_CUSTUMER
*
**----------------------------------------------------------------------*
**   Form  F_SEL_VENDOR
**----------------------------------------------------------------------*
**   Carregando informações do Fornecedor
**----------------------------------------------------------------------*
*    FORM f_sel_vendor USING p_type.
*      CLEAR: vc_vend_gdet, vc_vend_cdet,
*             vc_vend_retr, vc_vend_bdet.
*
*      UNASSIGN: <vend_gdet>, <vend_cdet>,
*                <vend_retr>, <vend_bdet>.
*
*      CONCATENATE: c_vend_gdet p_type INTO vc_vend_gdet,
*                   c_vend_cdet p_type INTO vc_vend_cdet,
*                   c_vend_retr p_type INTO vc_vend_retr,
*                   c_vend_bdet p_type INTO vc_vend_bdet.
*
*      ASSIGN: (vc_vend_gdet) TO <vend_gdet>,
*              (vc_vend_cdet) TO <vend_cdet>,
*              (vc_vend_retr) TO <vend_retr>,
*              (vc_vend_bdet) TO <vend_bdet>.
*
****   Lendo informações do Fornecedor
*      CALL FUNCTION 'BAPI_VENDOR_GETDETAIL'
*        EXPORTING
*          vendorno      = wa_nfdoc-parid
*          companycode   = wa_nfdoc-bukrs
*        IMPORTING
*          generaldetail = <vend_gdet>
*          companydetail = <vend_cdet>
*          return        = <vend_retr>
*        TABLES
*          bankdetail    = <vend_bdet>.
*
*      IF sy-subrc EQ 0.
*
*      ENDIF.
*    ENDFORM.                    " F_SEL_VENDOR

*&---------------------------------------------------------------------*
*&      Form  f_mneum_entradanormal
*&---------------------------------------------------------------------*
*       Mapeamento: 01 - Levanta Mneumonicos
*----------------------------------------------------------------------*
    FORM f_mneum_entradanormal USING p_codmp p_flowd.
**    Variaveis locais
      DATA: vl_ebeln TYPE ekbe-ebeln,
            vl_ebelp TYPE ekbe-ebelp.

***    Seleciona dados de cabeçalho do documento
*      SELECT SINGLE *
*        INTO wa_cabdoc
*        FROM zhms_tb_cabdoc
*        WHERE chave EQ v_chave
*          AND natdc EQ v_natdc
*          AND typed EQ v_typed.
*
***    Seleciona dados de Item do documento
*      IF NOT wa_cabdoc IS INITIAL.
*        SELECT  *
*          INTO TABLE it_itmdoc
*          FROM zhms_tb_itmdoc
*          WHERE natdc EQ wa_cabdoc-natdc
*            AND typed EQ wa_cabdoc-typed
*            AND chave EQ wa_cabdoc-chave.
*      ENDIF.
      break saoprocwrkfm.
**    Verifica se tabela de cabeçalho está vazia -
**    Identificada e preenchida nas rotinas de identificação do cenário
      CHECK NOT wa_cabdoc IS INITIAL.

**    Busca dados de atribuição para o documento [STANDARD HOMSOFT]
      PERFORM f_atr_load TABLES it_itmatr
                          USING wa_cabdoc-chave.

**    Percorre a tabela de itens
      LOOP AT it_itmdoc INTO wa_itmdoc.

**      Percorre a lista de atribuições
        LOOP AT it_itmatr INTO wa_itmatr WHERE dcitm EQ wa_itmdoc-dcitm.
**         Limpa as tabelas internas
          CLEAR: poheader, poexpimpheader.

          REFRESH: po1_return, poitem, poaddrdelivery, poschedule, poaccount, pocondheader, pocond,
                   polimits, pocontractlimits, poservices, posrvaccessvalues, potextheader, potextitem,
                   poexpimpitem, pocomponents, poshippingexp, pohistory, pohistory_totals, poconfirmation,
                   allversions, popartner, extensionout, serialnumber, invplanheader, invplanitem, pohistory_ma.

**        Verifica se o tipo de documento é pedido
          CHECK wa_itmatr-tdsrf EQ 1.

**        Move o numero do pedido para variável com tipo compatível
          MOVE wa_itmatr-nrsrf TO vl_ebeln.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = vl_ebeln
            IMPORTING
              output = vl_ebeln.

**        Realiza chamada da BAPI
          CALL FUNCTION 'BAPI_PO_GETDETAIL1'
            EXPORTING
              purchaseorder      = vl_ebeln
              account_assignment = 'X'
              item_text          = 'X'
              header_text        = 'X'
              delivery_address   = 'X'
              version            = 'X'
              services           = 'X'
              serialnumbers      = 'X'
              invoiceplan        = 'X'
            IMPORTING
              poheader           = poheader
              poexpimpheader     = poexpimpheader
            TABLES
              return             = po1_return
              poitem             = poitem
              poaddrdelivery     = poaddrdelivery
              poschedule         = poschedule
              poaccount          = poaccount
              pocondheader       = pocondheader
              pocond             = pocond
              polimits           = polimits
              pocontractlimits   = pocontractlimits
              poservices         = poservices
              posrvaccessvalues  = posrvaccessvalues
              potextheader       = potextheader
              potextitem         = potextitem
              poexpimpitem       = poexpimpitem
              pocomponents       = pocomponents
              poshippingexp      = poshippingexp
              pohistory          = pohistory
              pohistory_totals   = pohistory_totals
              poconfirmation     = poconfirmation
              allversions        = allversions
              popartner          = popartner
              extensionout       = extensionout
              serialnumber       = serialnumber
              invplanheader      = invplanheader
              invplanitem        = invplanitem
              pohistory_ma       = pohistory_ma.

**        Move o item do pedido para variável com tipo compatível
          MOVE wa_itmatr-itsrf TO vl_ebelp.

**        Seta os ponteiros
          READ TABLE poitem            WITH KEY po_item = vl_ebelp.
          READ TABLE poaddrdelivery    WITH KEY po_item = vl_ebelp.
          READ TABLE poschedule        WITH KEY po_item = vl_ebelp.
          READ TABLE poaccount         WITH KEY po_item = vl_ebelp.
          READ TABLE potextheader      WITH KEY po_item = vl_ebelp.
          READ TABLE potextitem        WITH KEY po_item = vl_ebelp.
          READ TABLE poexpimpitem      WITH KEY po_item = vl_ebelp.
          READ TABLE pocomponents      WITH KEY po_item = vl_ebelp.
          READ TABLE poshippingexp     WITH KEY po_item = vl_ebelp.
          READ TABLE pohistory         WITH KEY po_item = vl_ebelp.
          READ TABLE pohistory_totals  WITH KEY po_item = vl_ebelp.
          READ TABLE poconfirmation    WITH KEY po_item = vl_ebelp.
          READ TABLE serialnumber      WITH KEY po_item = vl_ebelp.
          READ TABLE pohistory_ma      WITH KEY po_item = vl_ebelp.

**        Executa o mapeamento de item
          PERFORM f_mapping_mn USING '2'
                                     wa_cabdoc-chave
                                     p_codmp
                                     wa_itmatr.

        ENDLOOP.
      ENDLOOP.

**        Executa o mapeamento de cabeçalho
      CLEAR wa_itmatr.
      PERFORM f_mapping_mn USING '1'
                                 wa_cabdoc-chave
                                 p_codmp
                                 wa_itmatr.

    ENDFORM.                    "f_mneum_entradanormal

*&---------------------------------------------------------------------*
*&      Form  f_proc_entradafisica
*&---------------------------------------------------------------------*
*       Mapeamento: 02 - Entrada Fisica
*----------------------------------------------------------------------*
    FORM f_proc_entradafisica USING p_codmp p_flowd.


      DATA: wl_itmatr TYPE zhms_tb_itmatr,
*Homine - Inicio da Inclusão - DD - Partição de lote de subcontratação
            v_tabix  TYPE sy-tabix,
            v_seq    TYPE bapi2017_gm_item_create-line_id.
*Homine - Fim da Inclusão - DD - Partição de lote de subcontratação

*      IF it_docmn IS NOT INITIAL.
**        CLEAR it_docmn.
*        SELECT *
*          APPENDING TABLE it_docmn
*          FROM zhms_tb_docmn
*         WHERE chave EQ v_chave.
*      ENDIF.

***     Carregando Valores do Grupo 01
      PERFORM f_mapping USING '1'
                              p_codmp
                              wl_itmatr
                              p_flowd.

***    Busca dados de atribuição para o documento
      PERFORM f_atr_load TABLES it_itmatr
                          USING wa_cabdoc-chave.

      LOOP AT it_itmatr INTO wa_itmatr.
***     Carregando Valores do Grupo 02
        PERFORM f_mapping USING '2'
                                p_codmp
                               wa_itmatr
                                p_flowd.

        PERFORM f_append USING '2' p_codmp p_flowd.

      ENDLOOP.


*========================================================================
*Migo subcontratacao
*Renan Itokazo
*========================================================================
      IF  ( v_typed EQ 'NFE1' AND p_flowd EQ ' 30' ) OR v_typed EQ 'NFE5' OR v_typed EQ 'NFE'.

        REFRESH: ty_subcontratacao.

        CONCATENATE '(' v_protine ')ITD' p_flowd '_GOODSMVT_ITEM' INTO v_subcontratacao.
        CONDENSE v_subcontratacao  NO-GAPS.
        ASSIGN: (v_subcontratacao) TO <fst_subcontratacao>.

        IF v_typed EQ 'NFE'.
          LOOP AT <fst_subcontratacao> INTO wa_subcontratacao_bapi.
            wa_subcontratacao-seq = sy-tabix.
            wa_subcontratacao-chk_box = 'X'.

            SELECT SINGLE maktx FROM makt INTO wa_subcontratacao-nmaterial WHERE matnr EQ wa_subcontratacao_bapi-material AND spras EQ sy-langu.

            wa_subcontratacao-material = wa_subcontratacao_bapi-material.
            wa_subcontratacao-po_number = wa_subcontratacao_bapi-po_number.
            wa_subcontratacao-po_item =  wa_subcontratacao_bapi-po_item.
            APPEND wa_subcontratacao TO ty_subcontratacao.
          ENDLOOP.
        ELSE.
          READ TABLE <fst_subcontratacao> INTO wa_subcontratacao_bapi INDEX 1.

          vl_orderid = wa_subcontratacao_bapi-orderid.
          wa_subcontratacao-seq = '1'.
          wa_subcontratacao-chk_box = 'X'.

          SELECT SINGLE maktx FROM makt INTO wa_subcontratacao-nmaterial WHERE matnr EQ wa_subcontratacao_bapi-material AND spras EQ sy-langu.

          wa_subcontratacao-material = wa_subcontratacao_bapi-material.

          APPEND wa_subcontratacao TO ty_subcontratacao.

***Busca componentes
          SELECT SINGLE * FROM eket INTO wa_ekte WHERE ebeln EQ wa_subcontratacao_bapi-po_number.
          SELECT * FROM resb INTO TABLE it_resb WHERE rsnum EQ wa_ekte-rsnum.

          LOOP AT it_resb INTO wa_resb.
            CLEAR: wa_subcontratacao_bapi, wa_subcontratacao.
            SELECT SINGLE maktx FROM makt INTO wa_subcontratacao-nmaterial WHERE matnr EQ wa_resb-matnr AND spras EQ sy-langu.
            wa_subcontratacao_bapi-material = wa_resb-matnr.
            wa_subcontratacao_bapi-plant = wa_resb-werks.
            wa_subcontratacao_bapi-move_type = '543'.
            wa_subcontratacao_bapi-vendor = wa_resb-lifnr.
*            wa_subcontratacao_bapi-entry_qnt = wa_resb-bdmng.
            wa_subcontratacao_bapi-entry_uom = wa_resb-meins.
            wa_subcontratacao_bapi-po_number = wa_resb-ebeln.
            wa_subcontratacao_bapi-po_item = '10'.
            wa_subcontratacao_bapi-mvt_ind = 'B'.
            wa_subcontratacao_bapi-line_id = sy-tabix + 1.
            wa_subcontratacao_bapi-parent_id = 1.
            wa_subcontratacao_bapi-orderid = vl_orderid.

            wa_subcontratacao-seq = '-'.
            wa_subcontratacao-material = wa_resb-matnr.
            wa_subcontratacao-chk_box = 'X'.
            wa_subcontratacao_bapi-po_number = wa_resb-ebeln.
            wa_subcontratacao_bapi-po_item = '10'.


            APPEND wa_subcontratacao_bapi TO <fst_subcontratacao>.
            APPEND wa_subcontratacao TO ty_subcontratacao.
          ENDLOOP.
        ENDIF.



*        CALL SCREEN 0500 STARTING AT 30 3.
**
**        LOOP AT ty_subcontratacao.
**          MOVE: sy-tabix TO wa_subcontratacao_aux-line.
**          MOVE-CORRESPONDING: ty_subcontratacao TO wa_subcontratacao_aux.
**          APPEND wa_subcontratacao_aux TO ti_subcontratacao_aux.
**        ENDLOOP.
**        LOOP AT <fst_subcontratacao> INTO wa_subcontratacao_bapi.
**
**          READ TABLE ty_subcontratacao INTO wa_subcontratacao WITH KEY material = wa_subcontratacao_bapi-material
**                                                                       po_number = wa_subcontratacao_bapi-po_number
**                                                                       po_item   = wa_subcontratacao_bapi-po_item.
**Homine - Inicio da Inclusão - DD - Partição de lote de subcontratação
**          v_tabix = sy-tabix.
**Homine - Fim da Inclusão - DD - Partição de lote de subcontratação
**          wa_subcontratacao_bapi-batch = wa_subcontratacao-lote.
**          IF wa_subcontratacao-quantidade IS NOT INITIAL.
**            wa_subcontratacao_bapi-entry_qnt = wa_subcontratacao-quantidade.
**          ENDIF.
**          wa_subcontratacao_bapi-gr_rcpt = wa_subcontratacao-recebedor.
**
**          MODIFY <fst_subcontratacao> FROM wa_subcontratacao_bapi.
**Homine - Inicio da Inclusão - DD - Partição de lote de subcontratação
**
**          DELETE ti_subcontratacao_aux WHERE line = v_tabix.
**Homine - Inicio da Inclusão - DD - Partição de lote de subcontratação
**          IF wa_subcontratacao-chk_box NE 'X'.
**            DELETE table <fst_subcontratacao> with table key ('material') = wa_subcontratacao-material.
**          ENDIF.
**        ENDLOOP.
**        v_seq = wa_subcontratacao_bapi-line_id.
**        IF NOT ti_subcontratacao_aux[] IS INITIAL.
**          LOOP AT <fst_subcontratacao> INTO wa_subcontratacao_bapi.
**
**            READ TABLE ti_subcontratacao_aux INTO wa_subcontratacao_aux WITH KEY material = wa_subcontratacao_bapi-material.
**            IF sy-subrc = 0.
**              wa_subcontratacao_bapi-batch = wa_subcontratacao_aux-lote.
**              wa_subcontratacao_bapi-entry_qnt = wa_subcontratacao_aux-quantidade.
**              wa_subcontratacao_bapi-gr_rcpt = wa_subcontratacao_aux-recebedor.
**              wa_subcontratacao_bapi-line_id = v_seq + 1.
**
**              APPEND wa_subcontratacao_bapi TO <fst_subcontratacao>.
**              v_seq = v_seq + 1.
**              DELETE ti_subcontratacao_aux WHERE line = v_seq.
**            ENDIF.
**Homine - Inicio da Inclusão - DD - Partição de lote de subcontratação
**          ENDLOOP.
**        ENDIF.
*Homine - Inicio da Inclusão - DD - Partição de lote de subcontratação

*Homine - Fim da Inclusão - DD - Partição de lote de subcontratação
*        LOOP AT ty_subcontratacao INTO wa_subcontratacao.
*          IF wa_subcontratacao-chk_box NE 'X'.
**            DELETE TABLE <fst_subcontratacao> WITH TABLE KEY ('material') = wa_subcontratacao-material.
*
**            READ TABLE <fst_subcontratacao> into <wa_subcontratacao2> WITH KEY ('material') = wa_subcontratacao-material.
*            DELETE <fst_subcontratacao> INDEX SY-TABIX.
*          ENDIF.
*        ENDLOOP.

*        DATA: vl_count TYPE i.
*        LOOP AT ty_subcontratacao INTO wa_subcontratacao.
*          IF wa_subcontratacao-chk_box NE 'X'.
*            DELETE <fst_subcontratacao> INDEX sy-tabix - vl_count.
*            vl_count = vl_count + 1.
*          ENDIF.
*        ENDLOOP.


      ENDIF.


      IF ( v_typed EQ 'NFE1' AND p_flowd EQ ' 40'  ) OR v_typed EQ 'NFE4'.
        REFRESH: ty_subcontratacao.
        CLEAR: vg_nrordem.

        CONCATENATE '(' v_protine ')ITD' p_flowd '_GOODSMVT_ITEM' INTO v_subcontratacao.
        CONDENSE v_subcontratacao  NO-GAPS.
        ASSIGN: (v_subcontratacao) TO <fst_subcontratacao>.

        LOOP AT <fst_subcontratacao> INTO wa_subcontratacao_bapi.
          wa_subcontratacao-seq = sy-tabix.
          wa_subcontratacao-material = wa_subcontratacao_bapi-material.
          SELECT SINGLE maktx FROM makt INTO wa_subcontratacao-nmaterial WHERE matnr EQ wa_subcontratacao_bapi-material AND spras EQ sy-langu.

          APPEND wa_subcontratacao TO ty_subcontratacao.

        ENDLOOP.

*        CALL SCREEN 0600 STARTING AT 30 3.

        LOOP AT <fst_subcontratacao> INTO wa_subcontratacao_bapi.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = vg_nrordem
            IMPORTING
              output = vg_nrordem.


          wa_subcontratacao_bapi-orderid = vg_nrordem.
          READ TABLE ty_subcontratacao INTO wa_subcontratacao WITH KEY material = wa_subcontratacao_bapi-material.
          wa_subcontratacao_bapi-mvt_ind = 'F'.
          wa_subcontratacao_bapi-batch = wa_subcontratacao-lote.
          wa_subcontratacao_bapi-profit_segm_no = ''.
          wa_subcontratacao_bapi-po_number = ''.
          wa_subcontratacao_bapi-po_item = ''.
          wa_subcontratacao_bapi-gr_rcpt = wa_subcontratacao-recebedor.
          wa_subcontratacao_bapi-stge_loc = wa_subcontratacao-deposito.
          MODIFY <fst_subcontratacao> FROM wa_subcontratacao_bapi.
        ENDLOOP.
      ENDIF.



*Verifica Autorização usuario
      CALL FUNCTION 'ZHMS_FM_SECURITY'
        EXPORTING
          value         = 'MIGO'
        EXCEPTIONS
          authorization = 1
          OTHERS        = 2.

      IF sy-subrc <> 0.
        MODIFY zhms_tb_docmn FROM TABLE it_docmn.
        IF sy-subrc IS INITIAL.
          COMMIT WORK.
        ENDIF.
        MESSAGE e002(zhms_security). "   Usuário sem autorização
      ENDIF.



    ENDFORM.                    "f_proc_entradafisica




*&---------------------------------------------------------------------*
*&      Form  f_proc_entradafiscal
*&---------------------------------------------------------------------*
*       Mapeamento: 04 - Entrada Fiscal
*----------------------------------------------------------------------*
    FORM f_proc_entradafiscal USING p_codmp p_flowd.

      IF v_typed EQ 'CTE'.
        READ TABLE it_docmn INTO wa_docmn WITH KEY mneum = 'INVDOCNO'.
        IF sy-subrc IS NOT INITIAL.
* Patricia
          DATA: wa_j_1bnfdoc TYPE j_1bnfdoc,
               vl_value TYPE zhms_tb_docmn-value,
               vl_resp  TYPE c.

          FIELD-SYMBOLS: <fs_bktxt> TYPE any.

          IF vg_bktxt IS INITIAL.


            SELECT SINGLE * FROM zhms_tb_docmn INTO ls_docmn WHERE chave = v_chave
                                                               AND mneum = 'INFNFECHAV'.
            IF sy-subrc NE 0.

              SELECT SINGLE * FROM zhms_tb_docmn INTO ls_docmn WHERE chave = v_chave
                                                              AND mneum = 'INFNFNDOC'.
              IF sy-subrc EQ 0.
                vg_bktxt = ls_docmn-value.
              ENDIF.

            ELSE.
              MOVE ls_docmn-value+29(5) TO vg_bktxt.
            ENDIF.


            CLEAR ls_docmn_2.
            SELECT SINGLE * FROM zhms_tb_docmn INTO ls_docmn_2 WHERE chave = v_chave
                                                                 AND mneum = 'REMCNPJ'.
*            IF sy-subrc EQ 0.
*
*              ASSIGN vg_bktxt TO <fs_bktxt>.
*              IF sy-subrc EQ 0.
*                CONCATENATE '%' <fs_bktxt> '%' INTO vl_value.
*              ENDIF.
*
*              CLEAR wa_j_1bnfdoc.
*              SELECT COUNT(*) FROM j_1bnfdoc
*              WHERE cgc = ls_docmn_2-value
*                AND nfenum LIKE vl_value.
*              IF sy-dbcnt EQ 0.
*
** Documento não encontrado. Deseja atribuir manualmente?
*                CALL FUNCTION 'POPUP_TO_CONFIRM'
*                  EXPORTING
*                    text_question         = text-m01
*                    text_button_1         = 'Sim'
*                    text_button_2         = 'Não'
*                    display_cancel_button = 'X'
*                  IMPORTING
*                    answer                = vl_resp
*                  EXCEPTIONS
*                    text_not_found        = 1
*                    OTHERS                = 2.
*                IF sy-subrc <> 0.
** Implement suitable error handling here
*                ELSE.
**                 Sim
*                  IF vl_resp EQ '1'.
*                    CALL SCREEN 0100 STARTING AT 30 3.
*                  ELSE.
*                    EXIT.
*                  ENDIF.
*                ENDIF.
*
*              ENDIF.
*
*            ENDIF.

          ENDIF.





* Patricia

        ENDIF.
*DDPT - Inicio da Alteração
*     ENDIF.
      ELSE.
*** Verifica se é importação e abre o Pop-up para inserção de valores manuais
*        READ TABLE IT_DOCMN INTO WA_DOCMN WITH KEY MNEUM = 'IDDEST'.
*        IF SY-SUBRC IS INITIAL AND WA_DOCMN-VALUE EQ '3'.




*        IF vg_first EQ 1.
* Início - Patrícia - 17771 - 12/05/17
        CLEAR: vg_ref_doc_no, vg_header_txt, vg_alloc_nmbr, vg_paymt_ref, vg_item_text.
* Fim - Patrícia - 17771 - 12/05/17
*** Pré carrega os campos com valores numero da nota + serie
        READ TABLE it_docmn INTO ls_docmn WITH KEY mneum = 'NNF'.

        IF sy-subrc IS INITIAL.
          vg_ref_doc_no = ls_docmn-value.
          CONDENSE vg_ref_doc_no NO-GAPS.
        ENDIF.

        IF vg_ref_doc_no NE vg_ref_docaux AND NOT vg_ref_doc_no IS INITIAL.
*** Pré carrega os campos com valores VL.REF.NF. (Numero nota) (Nome fornecedor)
          READ TABLE it_docmn INTO ls_docmn WITH KEY mneum = 'XNOME'.

          IF sy-subrc IS INITIAL.
* Início - Patrícia - 17536 - 10/03/17
            CLEAR: vg_header_txt, vg_paymt_ref, vg_item_text.
* Fim - Patrícia - 17536 - 10/03/17
            CONCATENATE 'VL.REF.NF.' vg_ref_doc_no ls_docmn-value INTO vg_header_txt SEPARATED BY space.
            MOVE: vg_header_txt TO vg_paymt_ref,
                  vg_header_txt TO vg_item_text.
          ENDIF.

*** Pré carrega os campos com valores numero do PO
* Início - Patrícia - 17771 - 12/05/17
          CLEAR vg_alloc_nmbr.
* Fim - Patrícia - 17771 - 12/05/17
          READ TABLE it_docmn INTO ls_docmn WITH KEY mneum = 'ATPED'.

          IF sy-subrc IS INITIAL.
            MOVE ls_docmn-value TO vg_alloc_nmbr.
            CONDENSE vg_alloc_nmbr NO-GAPS.
          ENDIF.

          vg_ref_docaux =  vg_ref_doc_no.

*} inicio alt. by RBO em 22/10/18
*          CALL SCREEN 0300 STARTING AT 30 3.
*} inicio alt. by RBO em 22/10/18

*        ELSEIF vg_first EQ 3.
** Início - Patrícia - 17771 - 12/05/17
*          CLEAR vg_ref_doc_no.
** Fim - Patrícia - 17771 - 12/05/17
**** Pré carrega os campos com valores numero da nota + serie
*          READ TABLE it_docmn INTO ls_docmn WITH KEY mneum = 'NNF'.
*
*          IF sy-subrc IS INITIAL.
*            vg_ref_doc_no = ls_docmn-value.
*            CONDENSE vg_ref_doc_no NO-GAPS.
*          ENDIF.
*
**** Pré carrega os campos com valores VL.REF.NF. (Numero nota) (Nome fornecedor)
*          READ TABLE it_docmn INTO ls_docmn WITH KEY mneum = 'XNOME'.
*
*          IF sy-subrc IS INITIAL.
** Início - Patrícia - 17536 - 10/03/17
*            CLEAR: vg_header_txt, vg_paymt_ref, vg_item_text.
** Fim - Patrícia - 17536 - 10/03/17
*            CONCATENATE 'VL.REF.NF.' vg_ref_doc_no ls_docmn-value INTO vg_header_txt SEPARATED BY space.
*            MOVE: vg_header_txt TO vg_paymt_ref,
*                  vg_header_txt TO vg_item_text.
*          ENDIF.
*
** Início - Patrícia - 17771 - 12/05/17
*          CLEAR vg_alloc_nmbr.
** Fim - Patrícia - 17771 - 12/05/17
**** Pré carrega os campos com valores numero do PO
*          READ TABLE it_docmn INTO ls_docmn WITH KEY mneum = 'ATPED'.
*
*          IF sy-subrc IS INITIAL.
*            MOVE ls_docmn-value TO vg_alloc_nmbr.
*            CONDENSE vg_alloc_nmbr NO-GAPS.
*          ENDIF.
*          CALL SCREEN 0300 STARTING AT 30 3.
*DDPT - Fim da Alteração
        ENDIF.

*        ENDIF.
      ENDIF.







***   Variáveis locais
      DATA: wl_itmatr TYPE zhms_tb_itmatr.
      FIELD-SYMBOLS: <lc_table> TYPE STANDARD TABLE.

***     Carregando Valores do Grupo 01
      PERFORM f_mapping USING '1'
                              p_codmp
                              wl_itmatr
                              p_flowd.

***    Busca dados de atribuição para o documento
      PERFORM f_atr_load TABLES it_itmatr
                          USING wa_cabdoc-chave.

      SORT it_itmatr ASCENDING BY atitm.

      LOOP AT it_itmatr INTO wa_itmatr.
***     Carregando Valores do Grupo 02
        PERFORM f_mapping USING '2'
                                p_codmp
                                wa_itmatr
                                p_flowd.

        PERFORM f_append USING '2' p_codmp p_flowd.
      ENDLOOP.


**  Chamadas de EXITS para ajustes dos campos

** TAXDATA - Condensa em apenas 1 linha para cada IVA
*   Assign para tabela interna

      CLEAR v_varname.
      CONCATENATE '(' v_protine ')ITD' p_flowd '_TAXDATA' INTO v_varname.
      CONDENSE v_varname NO-GAPS.
      ASSIGN: (v_varname) TO <lc_table>.

      IF <lc_table> IS ASSIGNED.
        PERFORM f_exit_taxdata TABLES <lc_table>.
      ENDIF.

*Verifica Autorização usuario
      CALL FUNCTION 'ZHMS_FM_SECURITY'
        EXPORTING
          value         = 'MIRO'
        EXCEPTIONS
          authorization = 1
          OTHERS        = 2.

      IF sy-subrc <> 0.
        MODIFY zhms_tb_docmn FROM TABLE it_docmn.
        IF sy-subrc IS INITIAL.
          COMMIT WORK.
        ENDIF.
        MESSAGE e002(zhms_security). "   Usuário sem autorização
      ENDIF.


*Pat

      FIELD-SYMBOLS: <tb_account> TYPE ANY TABLE,
                     <fs_account> TYPE STANDARD TABLE,
                     <tb_item>    TYPE ANY TABLE,
                     <fs_item> TYPE any,
                     <fs_acc>  TYPE any.


      DATA: t_item TYPE TABLE OF bapiekpo,
*            t_acc TYPE TABLE OF bapiekkn,
            t_acc TYPE TABLE OF bapimepoaccount,
            t_acc2  TYPE TABLE OF bapi_incinv_create_account,
            wa_item TYPE bapiekpo,
*            wa_acc TYPE bapiekkn,
            wa_acc TYPE bapimepoaccount,
            v_dacon TYPE string,
            wa_acc2  TYPE bapi_incinv_create_account,
            wa_mat  TYPE zhms_tb_itmatr.


      UNASSIGN: <tb_account>,  <fs_acc>.
*     Rotina interna que tem os dados contábeis
      ASSIGN ('(SAPLZHMS_FG_RULER)POACCOUNT[]') TO <tb_account>.
      IF sy-subrc EQ 0.

        LOOP AT <tb_account> ASSIGNING <fs_acc>.

          MOVE-CORRESPONDING <fs_acc> TO wa_acc.
          APPEND wa_acc  TO t_acc.
        ENDLOOP.
      ENDIF.


      UNASSIGN: <tb_item>, <fs_item>.
*     Rotina iterna com os itens
      ASSIGN ('(SAPLZHMS_FG_RULER)POITEM[]') TO <tb_item>.
      IF sy-subrc EQ 0.

        LOOP AT <tb_item> ASSIGNING <fs_item>.

          MOVE-CORRESPONDING <fs_item> TO wa_item.
          APPEND wa_item  TO t_item.
        ENDLOOP.

      ENDIF.

*     Rotina Externa que deve receber as linhas
      CONCATENATE '(' v_protine ')' 'ITD60_ACCOUNTINGDATA[]' INTO v_dacon.
      ASSIGN (v_dacon) TO <fs_account>.
      IF sy-subrc EQ 0.
*
        IF <fs_account>[] IS INITIAL.

          LOOP AT t_item INTO wa_item.

            IF NOT wa_item-part_inv IS INITIAL.

              CLEAR wa_acc.
              READ TABLE t_acc INTO wa_acc WITH KEY po_item = wa_item-po_item.
              IF sy-subrc EQ 0.

                LOOP AT t_acc INTO wa_acc FROM sy-tabix.

                  IF wa_acc-po_item NE wa_item-po_item.
                    EXIT.
                  ELSE.

                    CLEAR wa_acc2.
                    MOVE-CORRESPONDING wa_acc TO wa_acc2.

                    wa_acc2-invoice_doc_item = wa_acc2-invoice_doc_item +  1.

                    CLEAR wa_mat.
                    READ TABLE it_itmatr INTO wa_mat WITH KEY itsrf = wa_item-po_item.
                    IF sy-subrc EQ 0.
                      wa_acc2-item_amount      = wa_mat-atprc.
                      wa_acc2-quantity         = wa_mat-atqtd.
                      wa_acc2-po_unit          = wa_mat-atunm.
                      wa_acc2-po_pr_uom        = wa_mat-atunm.
                      wa_acc2-po_pr_qnt        = wa_mat-atqtd.
                    ENDIF.

*                    wa_acc2-serial_no        =  wa_acc-serial_no.
*                    wa_acc2-gl_account       = wa_acc-g_l_acct.
*                    wa_acc2-costcenter       = wa_acc-cost_ctr.

                    IF <fs_acc> IS ASSIGNED.
                      UNASSIGN <fs_acc>.
                      ASSIGN wa_acc2 TO <fs_acc>.
                      IF sy-subrc EQ 0.

                        MOVE-CORRESPONDING wa_acc2 TO <fs_acc>.
                        APPEND wa_acc2  TO <fs_account>.
                        CLEAR wa_acc2.

                      ENDIF.

                    ENDIF.

                  ENDIF.

                ENDLOOP.

                CLEAR wa_acc2-invoice_doc_item.
              ENDIF.

            ENDIF.

            CLEAR wa_item.
          ENDLOOP.

        ENDIF.

      ENDIF.
* Pat
      IF v_typed EQ 'NFE3'.
        CLEAR:  gv_460_vldi.
*        CALL SCREEN 0460 STARTING AT 30 3.

        FIELD-SYMBOLS: <fst_importacao> TYPE bapi_incinv_create_header,
                       <fst_importacao_item> TYPE STANDARD TABLE.

        DATA: v_importacao TYPE string,
              v_importacao_item TYPE string.

        DATA: wa_importacao TYPE bapi_incinv_create_header,
              wa_importacao_item TYPE bapi_incinv_create_item.


        CONCATENATE '(' v_protine ')VD' p_flowd '_HEADERDATA' INTO v_importacao.
        CONCATENATE '(' v_protine ')ITD' p_flowd '_ITEMDATA' INTO v_importacao_item.

        CONDENSE v_importacao  NO-GAPS.
        CONDENSE v_importacao_item  NO-GAPS.

        ASSIGN: (v_importacao) TO <fst_importacao>.
        ASSIGN: (v_importacao_item) TO <fst_importacao_item>.

        <fst_importacao>-gross_amount = gv_460_vldi.

        READ TABLE <fst_importacao_item> INTO wa_importacao_item INDEX 1.
        wa_importacao_item-item_amount = gv_460_vldi.

        MODIFY <fst_importacao_item> FROM wa_importacao_item INDEX 1.

      ENDIF.


    ENDFORM.                    "f_proc_entradafiscal

*&---------------------------------------------------------------------*
*&      Form  f_map_generico
*&---------------------------------------------------------------------*
*       Mapeamento genérico
*----------------------------------------------------------------------*
    FORM f_map_generico USING p_codmp p_flowd.
      DATA: wl_itmatr TYPE zhms_tb_itmatr.
***     Carregando Valores do Grupo 01
      PERFORM f_mapping USING '1'
                              p_codmp
                              wl_itmatr
                              p_flowd.
    ENDFORM.                   "f_map_generico

*&---------------------------------------------------------------------*
*&      Form  f_mn_generico
*&---------------------------------------------------------------------*
*       Mapeamento genérico
*----------------------------------------------------------------------*
    FORM f_mn_generico USING p_codmp p_flowd.
**    Variáveis Locais
      DATA: wl_itmatr TYPE zhms_tb_itmatr.
      CLEAR wl_itmatr.

**    Mapeia mneumonicos para grupo 1
      PERFORM f_mapping_mn USING '1'
                                 wa_cabdoc-chave
                                 p_codmp
                                 wl_itmatr.


    ENDFORM.                   "f_mn_generico

*&---------------------------------------------------------------------*
*&      Form  f_emissao_nfe
*&---------------------------------------------------------------------*
*       05. Emissão de Nota Fiscal Venda Normal
*----------------------------------------------------------------------*
    FORM f_emissao_nfe USING p_codmp p_flowd.
*   Selecionando dados a serem processados
      PERFORM f_sel_emite_nfe CHANGING vg_acckey.

**      Chama mapeamento
***     Carregando Valores do Grupo 01
      CLEAR wa_itmatr.
      PERFORM f_mapping_mn USING '1'
                                 vg_acckey
                                 p_codmp
                                 wa_itmatr.

***      Percorre os itens de documento
      LOOP AT j_1bnflin.
**      Chama mapeamento
***     Carregando Valores do Grupo 01
        PERFORM f_mapping_mn USING '2'
                                   vg_acckey
                                   p_codmp
                                   wa_itmatr.

      ENDLOOP.

    ENDFORM.                    "f_emissao_nfe

*----------------------------------------------------------------------*
*   Form  F_SEL_EMITE_NFE
*----------------------------------------------------------------------*
*   Selecionando dados a serem processados
*----------------------------------------------------------------------*
    FORM f_sel_emite_nfe CHANGING p_acckey.
      DATA vl_docnum TYPE j_1bnfdoc-docnum.

***   Ler dados recebidos em busca do número da nota
      CLEAR wa_docum.
      READ TABLE it_docum INTO wa_docum WITH KEY dctyp = 'DOCNUM'.
      MOVE wa_docum-dcnro TO vl_docnum.
      MOVE wa_docum-dcnro TO p_acckey.

      CALL FUNCTION 'J_1B_NF_DOCUMENT_READ'
        EXPORTING
          doc_number         = vl_docnum
        IMPORTING
          doc_header         = j_1bnfdoc
        TABLES
          doc_partner        = j_1bnfnad
          doc_item           = j_1bnflin
          doc_item_tax       = j_1bnfstx
          doc_header_msg     = j_1bnfftx
          doc_refer_msg      = j_1bnfref
        EXCEPTIONS
          document_not_found = 1
          docum_lock         = 2
          OTHERS             = 3.

      CALL FUNCTION 'J_1B_NF_VALUE_DETERMINATION'
        EXPORTING
          nf_header   = j_1bnfdoc
        IMPORTING
          ext_header  = wk_header_add
        TABLES
          nf_item     = j_1bnflin
          nf_item_tax = j_1bnfstx
          ext_item    = wk_item_add.


    ENDFORM.                    "f_sel_emite_nfe


*&---------------------------------------------------------------------*
*&      Form  F_TESTE_MNEUMONICOS
*&---------------------------------------------------------------------*
*       Teste - Mneumonicos
*----------------------------------------------------------------------*
    FORM f_teste_mneumonicos USING p_codmp p_flowd.

      DATA: vl_docnum TYPE j_1bnfdoc-docnum,
            wl_nfdoc TYPE j_1bnfdoc.

***   Ler dados recebidos em busca do número da nota
      CLEAR wa_docum.
      READ TABLE it_docum INTO wa_docum WITH KEY dctyp = 'DOCNUM'.

      IF NOT wa_docum-dcnro IS INITIAL.
**      Número de documento recebido
        MOVE wa_docum-dcnro TO vl_docnum.

**      Busca dados
        SELECT SINGLE *
          INTO wl_nfdoc
          FROM j_1bnfdoc
         WHERE docnum EQ vl_docnum.

        MOVE-CORRESPONDING wl_nfdoc TO wa_nfdoc.

***       Obtendo Chave da NFe
*        PERFORM f_get_chave_nfe.
        IF vg_acckey IS INITIAL.
          vg_acckey = wa_nfdoc-docnum.
        ENDIF.

**      Chama mapeamento
***     Carregando Valores do Grupo 01
        CLEAR wa_itmatr.
        PERFORM f_mapping_mn USING '1'
                                   vg_acckey
                                   p_codmp
                                   wa_itmatr.
      ENDIF.

    ENDFORM.                    "F_TESTE_MNEUMONICOS

*&---------------------------------------------------------------------*
*&      Form  F_TESTE_REGISTRA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
    FORM f_teste_registra USING p_codmp p_flowd.
      DATA: wl_itmatr TYPE zhms_tb_itmatr.
***     Carregando Valores do Grupo 01
      PERFORM f_mapping USING '1'
                              p_codmp
                              wl_itmatr
                              p_flowd.

    ENDFORM.                    "F_TESTE_REGISTRA

*&---------------------------------------------------------------------*
*&      Form  f_zhms_ml81n_bapi
*&---------------------------------------------------------------------*
*       Mapeamento: 22
*----------------------------------------------------------------------*
    FORM f_zhms_ml81n_bapi USING p_codmp p_flowd.

      DATA: lv_ebeln    TYPE ebeln,
            lv_numero   TYPE xblnr,
            lv_rel_code TYPE t16fc-frgco,
            lw_docmn    TYPE zhms_tb_docmn,
            lw_itmatnr  TYPE zhms_tb_itmatr.


      CLEAR: lv_ebeln, lv_numero, lv_rel_code.

      CLEAR lw_itmatnr.
      READ TABLE it_itmatr INTO lw_itmatnr INDEX 1.

      " Move o numero do pedido para variável com tipo compatível
      MOVE lw_itmatnr-nrsrf TO lv_ebeln.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = lv_ebeln
        IMPORTING
          output = lv_ebeln.

      CLEAR lw_docmn.
      READ TABLE it_docmn INTO lw_docmn WITH KEY mneum = 'NUMERO'.
      IF sy-subrc IS INITIAL.
        lv_numero = lw_docmn-value.
      ENDIF.


      SELECT SINGLE frgco
        FROM t16fd
        INTO lv_rel_code
        WHERE frggr = '03'
          AND frgct = 'Aceite'
          AND spras = 'PT'.

*      vd30_zebeln = lv_ebeln.

***   Carregando Valores do Grupo 01
* Percorrer estrutura de Mapeamento para grupo indicado
      LOOP AT it_mapdata
         INTO wa_mapdata
        WHERE codmp EQ p_codmp
          AND mpgrp EQ '1'.

        " Assign para dados de origem (campo que é passado na função)
        " Assign da variável
        CLEAR v_varname.
        CONCATENATE '(' v_protine ')VD' p_flowd '_' wa_mapdata-tbfld INTO v_varname.
        CONDENSE v_varname NO-GAPS.

        ASSIGN: (v_varname) TO <or_field>.

        " Transferir Valores
        IF <or_field> IS ASSIGNED.

          CASE wa_mapdata-tbfld.

            WHEN 'ZEBELN'.
              ASSIGN: ('LV_EBELN') TO <or_value>.

            WHEN 'ZREF_DOC_NO' OR 'ZEXT_NUMBER'.
              ASSIGN: ('LV_NUMERO') TO <or_value>.

            WHEN 'ZREL_CODE'.
              ASSIGN: ('LV_REL_CODE') TO <or_value>.

            WHEN 'ZSHORTTEXT'.


          ENDCASE.

          IF <or_field> IS ASSIGNED AND <or_value> IS ASSIGNED.
            MOVE <or_value> TO <or_field> .
          ENDIF.

        ENDIF.

      ENDLOOP.


    ENDFORM.                    "F_ZHMS_ML81N_BAPI



*&---------------------------------------------------------------------*
*&      Form  f_mneum_entradanormal
*&---------------------------------------------------------------------*
*       Mapeamento: 09
*----------------------------------------------------------------------*
    FORM f_zhms_mde USING p_codmp p_flowd.
      DATA: lw_docmn    TYPE zhms_tb_docmn,
            lw_itmatnr  TYPE zhms_tb_itmatr,

           lv_chave         TYPE char44,
           lv_tpevento      TYPE char100,
           lv_tpamb         TYPE char1,
           lv_nseqevento    TYPE char1,
           lv_descevento(60) TYPE c,
           lv_xjust         TYPE char255,
           lv_dhemi         TYPE char25.

      CLEAR lv_chave.
      CLEAR lw_itmatnr.
      READ TABLE it_itmatr INTO lw_itmatnr INDEX 1.


      " Move o numero do pedido para variável com tipo compatível
      MOVE lw_itmatnr-chave TO lv_chave.

      READ TABLE it_docmn INTO lw_docmn WITH KEY chave = lv_chave mneum = 'DHEMI'.

      MOVE lw_docmn-value TO lv_dhemi.

      MOVE lw_itmatnr-chave TO wa_mde-chnfe.



      LOOP AT it_mapdata
         INTO wa_mapdata
        WHERE codmp EQ p_codmp
          AND mpgrp EQ '1'.

        " Assign para dados de origem (campo que é passado na função)
        " Assign da variável
        CLEAR v_varname.
        CONCATENATE '(' v_protine ')VD' p_flowd '_' wa_mapdata-tbfld INTO v_varname.
        CONDENSE v_varname NO-GAPS.

        ASSIGN: (v_varname) TO <or_field>.

        " Transferir Valores
        IF <or_field> IS ASSIGNED.

          CASE wa_mapdata-tbfld.
            WHEN 'TPAMB'.
              lv_tpamb = wa_mapdata-vlfix.
              ASSIGN: ('LV_TPAMB') TO <or_value>.
            WHEN 'NSEQEVENTO'.
              lv_nseqevento = wa_mapdata-vlfix.
              ASSIGN: ('LV_NSEQEVENTO') TO <or_value>.
            WHEN 'DESCEVENTO'.
              lv_descevento = wa_mapdata-vlfix.
              ASSIGN: ('LV_DESCEVENTO') TO <or_value>.
            WHEN 'XJUST'.
              lv_xjust = wa_mapdata-vlfix.
              ASSIGN: ('LV_XJUST') TO <or_value>.
            WHEN 'CHAVE'.
              ASSIGN: ('LV_CHAVE') TO <or_value>.
            WHEN 'DHEMI'.
              ASSIGN: ('LV_DHEMI') TO <or_value>.
            WHEN 'TPEVENTO'.
              lv_tpevento = wa_mapdata-vlfix.
              ASSIGN: ('LV_TPEVENTO') TO <or_value>.
          ENDCASE.

          IF <or_field> IS ASSIGNED AND <or_value> IS ASSIGNED.
            MOVE <or_value> TO <or_field> .
          ENDIF.

        ENDIF.


      ENDLOOP.

    ENDFORM.                    "f_zhms_mde
