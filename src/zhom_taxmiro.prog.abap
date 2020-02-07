*----------------------------------------------------------------------*
*                           Homine Consulting                          *
*----------------------------------------------------------------------*
*        Projeto......: Recebimento de Documentos Eletrônicos          *
*----------------------------------------------------------------------*
* Descrição : Recebimento de NF-e                                      *
* Objetivo  : Ampliação para correção dos dados de NFe com base no XML *
* Programa  : ZHOM_TAXMIRO                                             *
* Autor(a)  : Rogério Homine                                           *
* Data      : 18.02.2019                                               *
* Versão    : 1.1.1                                                    *
* Observ    :                                                          *
*----------------------------------------------------------------------*
*                 Descrição das Modificações                           *
*----------------------------------------------------------------------*
* Nome             Data        Descrição                               *
* Rodrigo Freitas  18.02.2019  Versão Inicial                          *
*----------------------------------------------------------------------*
REPORT zhom_taxmiro.
TYPE-POOLS: mrm, mmcr.

TABLES: vf_kred.                      " View Kreditor

DATA: gn_nfobjn         LIKE j_1bnfdoc-docnum,
      gc_chave_acesso   TYPE zhms_tb_docmn-chave,
      wg_rbkpv          TYPE mrm_rbkpv,
      gc_change_flag(1) TYPE c,
      gc_tabix          TYPE sy-tabix,
      tg_bset           LIKE bset OCCURS 10 WITH HEADER LINE,
      tg_drseg          TYPE mmcr_tdrseg WITH HEADER LINE,
      wg_nfheader       TYPE j_1bnfdoc,
      wg_nfheader_new   TYPE j_1bnfdoc,
      gn_base_icms      TYPE j_1bnfstx-base,
      gn_base_icms_xml  TYPE j_1bnfstx-base,
      gn_predbc_icms    TYPE j_1bnfstx-rate,
      gn_predbcst_icmsst TYPE j_1bnfstx-rate,
      gn_base_icmsst    TYPE j_1bnfstx-base,
      gn_base_ipi       TYPE j_1bnfstx-base,
      gn_base_pis       TYPE j_1bnfstx-base, "CT-e
      gn_base_cof       TYPE j_1bnfstx-base, "CT-e
      gn_val_icms       TYPE j_1bnfstx-taxval,
      gn_val_icmsst     TYPE j_1bnfstx-taxval,
      gn_val_ipi        TYPE j_1bnfstx-taxval,
      gn_val_pis        TYPE j_1bnfstx-taxval, "CT-e
      gn_val_cof        TYPE j_1bnfstx-taxval, "CT-e
      tg_partner        TYPE TABLE OF j_1bnfnad,
      tg_litax          TYPE TABLE OF j_1bnfstx,
      tg_litax_new      TYPE TABLE OF j_1bnfstx,
      wg_litax_new      TYPE j_1bnfstx,
      tg_hdtext         TYPE TABLE OF j_1bnfftx,
      tg_rftext         TYPE TABLE OF j_1bnfref,
      tg_ot_partner     TYPE TABLE OF j_1bnfcpd,
      tg_ot_partner_new TYPE TABLE OF j_1bnfcpd.

DATA: BEGIN OF tg_lineitem OCCURS 50.   "NF line items changed in
        INCLUDE STRUCTURE j_1bnflin.   "NF system
DATA:   msegflag.
DATA: END OF tg_lineitem.

DATA: BEGIN OF tg_lineitem_new OCCURS 50.   "NF line items changed in
        INCLUDE STRUCTURE j_1bnflin.   "NF system
DATA:   msegflag.
DATA: END OF tg_lineitem_new.

FIELD-SYMBOLS: <fs_icms>  TYPE  any,
               <fs_ipi>   TYPE  any.

DATA: tg_docmn   TYPE TABLE OF zhms_tb_docmn.
DATA: wg_docmn   TYPE zhms_tb_docmn.
DATA: wg_docmn_x TYPE zhms_tb_docmn.
DATA: wg_docmn_rate TYPE zhms_tb_docmn.

*&---------------------------------------------------------------------*
*&      Form  F_ENHANCEMENT_MIRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_enhancement_miro TABLES p_t_drseg.

  FIELD-SYMBOLS <fs_chave> TYPE char44.

* Importa parâmetros da BAPI
  IMPORT e_rbkpv = wg_rbkpv t_bset = tg_bset FROM MEMORY ID 'ZCFG_ENH_MIRO'.
  tg_drseg[] = p_t_drseg[].

  FREE MEMORY ID 'ZCFG_ENH_MIRO'.

* Importa chave de acesso do monitor de entrada
  ASSIGN ('(SAPLZHMS_FG_RULER)V_CHAVE') TO <fs_chave>.
  IF <fs_chave> IS ASSIGNED.
    gc_chave_acesso = <fs_chave>.
  ELSE.
    ASSIGN ('(SAPLZHMS_FG_MONITOR)VG_CHAVE') TO <fs_chave>.
    gc_chave_acesso = <fs_chave>.
  ENDIF.

* Verifica se chave está preenchida
  IF NOT gc_chave_acesso IS INITIAL. "AND wg_rbkpv-j_1bnftype <> 'YW'.

    PERFORM f_seleciona_dados_miro.
    PERFORM f_seleciona_dados_xml.
    PERFORM f_modifica_dados_miro.
    PERFORM f_atualiza_dados_miro.

*  ELSEIF wg_rbkpv-j_1bnftype EQ 'YW'.
*
*    PERFORM f_seleciona_dados_miro.
*    PERFORM f_seleciona_dados_xml_cte.
*    PERFORM f_modifica_dados_miro_cte.
*    PERFORM f_atualiza_dados_miro.
  ENDIF.

  LOOP AT tg_drseg.
    CLEAR tg_drseg-spgrp.
    MODIFY tg_drseg INDEX sy-tabix.
  ENDLOOP.

* Exporta parâmetros para BAPI
  EXPORT e_rbkpv = wg_rbkpv t_bset = tg_bset TO MEMORY ID 'ZCFG_ENH_MIRO'.
  p_t_drseg[] = tg_drseg[].

ENDFORM.                    "F_ENHANCEMENT_MIRO
*&---------------------------------------------------------------------*
*&      Form  F_SELECIONA_DADOS_MIRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_seleciona_dados_miro .

* Busca dados do parceiro
  CALL FUNCTION 'FI_VENDOR_DATA'
    EXPORTING
      i_bukrs       = wg_rbkpv-bukrs
      i_lifnr       = wg_rbkpv-lifnr
    IMPORTING
      e_kred        = vf_kred
    EXCEPTIONS
      error_message = 01
      OTHERS        = 02.

* Gera dados temporários de nota fiscal
  CALL FUNCTION 'J_1B_NF_INVOICE'
    EXPORTING
      i_rbkp  = wg_rbkpv
      i_lifnr = vf_kred-lifnr
      i_land1 = vf_kred-land1
      i_regio = vf_kred-regio
    IMPORTING
      e_rbkp  = wg_rbkpv
    TABLES
      t_rseg  = tg_drseg
      t_bset  = tg_bset.

* Importa número do objeto de nota fiscal
  GET PARAMETER ID 'J_1BNFE_OBJECT' FIELD gn_nfobjn.

* Importa dados de nota fiscal
  CALL FUNCTION 'J_1B_NF_OBJECT_READ'
    EXPORTING
      obj_number       = gn_nfobjn
    IMPORTING
      obj_header       = wg_nfheader
    TABLES
      obj_partner      = tg_partner
      obj_item         = tg_lineitem
      obj_item_tax     = tg_litax
*     obj_total_tax    = c_hdtax   "DB
      obj_header_msg   = tg_hdtext
      obj_refer_msg    = tg_rftext
      obj_ot_partner   = tg_ot_partner
    EXCEPTIONS
      object_not_found = 01.

ENDFORM.                    " F_SELECIONA_DADOS_MIRO
*&---------------------------------------------------------------------*
*&      Form  F_SELECIONA_DADOS_XML
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_seleciona_dados_xml .

  SELECT * FROM zhms_tb_docmn
     INTO TABLE tg_docmn WHERE chave EQ gc_chave_acesso.

**** Seleciona dados básicos do monitor de NF-e
***  CLEAR wg_alv_selection.
***  SELECT SINGLE *
***    FROM zcfget001
***    INTO wg_alv_selection
***   WHERE chave_nfe EQ gc_chave_acesso.
***
***  IF sy-subrc EQ 0.
***
**** Carrega dados de itens do XML
***    CLEAR: tg_nfe_alv_item, wg_nfe_alv_item.
***    SELECT *
***      FROM zcfget005
***      INTO TABLE tg_nfe_alv_item
***     WHERE  cfg_un        EQ wg_alv_selection-cfg_un      AND
***            cfg_num_nf    EQ wg_alv_selection-cfg_num_nf  AND
***            cfg_serie_nf  EQ wg_alv_selection-cfg_serie_nf.
***
**** Carrega dados de ICMS de itens do XML
***    CLEAR tg_dados_icm.
***    SELECT *
***      FROM zcfget006
***      INTO TABLE tg_dados_icm
***     WHERE cfg_un        EQ wg_alv_selection-cfg_un
***       AND cfg_num_nf    EQ wg_alv_selection-cfg_num_nf
***       AND cfg_serie_nf  EQ wg_alv_selection-cfg_serie_nf.
***
**** Carrega dados de IPI de itens do XML
***    CLEAR tg_dados_ipi.
***    SELECT *
***      FROM zcfget007
***      INTO TABLE tg_dados_ipi
***     WHERE cfg_un        EQ wg_alv_selection-cfg_un
***       AND cfg_num_nf    EQ wg_alv_selection-cfg_num_nf
***       AND cfg_serie_nf  EQ wg_alv_selection-cfg_serie_nf.
***
***  ENDIF.

ENDFORM.                    " F_SELECIONA_DADOS_XML
*&---------------------------------------------------------------------*
*&      Form  F_MODIFICA_DADOS_MIRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_modifica_dados_miro .

  DATA:
        lc_taxgrp       TYPE j_1baj-taxgrp,
        gf_base_icms    TYPE f,
        gf_predbc_icms  TYPE f,
        vl_message      TYPE string,
*        count       TYPE i,
        o_excp          TYPE REF TO cx_root,
        lc_base_total   TYPE f. "j_1bnfstx-base.

* Move dados atuais para tabelas temporárias
  wg_nfheader_new      = wg_nfheader.
  tg_lineitem_new[]    = tg_lineitem[].
  tg_litax_new[]       = tg_litax[].
  tg_ot_partner_new[]  = tg_ot_partner[].

* Loop em registros de impostos da nota no SAP
  LOOP AT tg_litax_new INTO wg_litax_new.

    gc_tabix = sy-tabix.

    CLEAR: gn_base_icms, gn_base_icmsst, gn_base_ipi,
           gn_val_icms,  gn_val_icmsst,  gn_val_ipi.
    CLEAR: wg_docmn, wg_docmn_x.

* Lê item da nota no SAP
    READ TABLE tg_lineitem_new WITH KEY itmnum = wg_litax_new-itmnum.

* Verifica o tipo de imposto do registro
    CLEAR lc_taxgrp.
    SELECT SINGLE taxgrp
      FROM j_1baj
      INTO lc_taxgrp
     WHERE taxtyp EQ wg_litax_new-taxtyp.

    READ TABLE tg_litax_new TRANSPORTING NO FIELDS WITH KEY taxtyp = 'IPI2'
                                                            itmnum = wg_litax_new-itmnum.
    IF sy-subrc EQ 0 AND wg_nfheader-nftype NE 'D5'
                     AND ( lc_taxgrp EQ 'COFI'
                        OR lc_taxgrp EQ 'PIS' )
                     AND ( tg_lineitem_new-matuse EQ '0'
                        OR tg_lineitem_new-matuse EQ '2'
                        OR tg_lineitem_new-matuse EQ '3' )
                     OR  wg_litax_new-taxtyp EQ 'ICM0'.
      CONTINUE.
    ENDIF.

    CASE lc_taxgrp.
      WHEN 'ICMS' OR 'ICST'.

        CLEAR: wg_docmn, wg_docmn_x, gn_predbc_icms.
        gn_predbc_icms = wg_litax_new-basered1.
        READ TABLE tg_docmn INTO wg_docmn WITH KEY mneum = 'ICMSVBC'
                                                   dcitm = tg_lineitem_new-refitm.
        IF sy-subrc IS NOT INITIAL.
          CLEAR wg_docmn.
          READ TABLE tg_docmn INTO wg_docmn WITH KEY mneum = 'VPROD'
                                                     dcitm = tg_lineitem_new-refitm.
          IF sy-subrc IS NOT INITIAL.
            CLEAR wg_docmn.
            READ TABLE tg_docmn INTO wg_docmn WITH KEY mneum = 'VTPREST'.

            READ TABLE tg_docmn INTO wg_docmn_x WITH KEY mneum = 'VICMS'.
          ENDIF.
        ENDIF.

        IF wg_docmn_x-value IS INITIAL.
          READ TABLE tg_docmn INTO wg_docmn_x WITH KEY mneum = 'VICMS'
                                                       dcitm = tg_lineitem_new-refitm.
        ENDIF.

        gn_base_icms = wg_docmn-value.
        gn_val_icms = wg_docmn_x-value.

        IF lc_taxgrp EQ 'ICMS'.

* Altera o valor do ICMS
          IF wg_litax_new-taxval NE gn_val_icms
          AND gn_val_icms IS NOT INITIAL.
            wg_litax_new-taxval = gn_val_icms.
          ENDIF.

* Altera a base do ICMS
          IF wg_litax_new-base NE gn_base_icms
          AND wg_litax_new-base IS NOT INITIAL
          AND gn_base_icms IS NOT INITIAL.
            wg_litax_new-base = gn_base_icms.
          ENDIF.

* Altera a outra base do ICMS
          IF wg_litax_new-othbas NE gn_base_icms
          AND wg_litax_new-othbas IS NOT INITIAL
          AND gn_base_icms IS NOT INITIAL.
            wg_litax_new-othbas = gn_base_icms.
          ENDIF.

* Verifica se existe percentual de redução de alíquota
          IF gn_predbc_icms IS INITIAL.

* Altera a base excuída do ICMS
            IF wg_litax_new-excbas NE gn_base_icms
            AND wg_litax_new-excbas IS NOT INITIAL
            AND gn_base_icms IS NOT INITIAL.
              wg_litax_new-excbas = gn_base_icms.
            ENDIF.

          ELSE.

            CLEAR: wg_docmn, gn_base_icms_xml, gn_base_icms.
            READ TABLE tg_docmn INTO wg_docmn WITH KEY mneum = 'VPROD'
                                                       dcitm = tg_lineitem_new-refitm.
            gn_base_icms = wg_docmn-value.

* Encontra Base total
            TRY.

                CLEAR: gf_base_icms, gf_predbc_icms, gn_base_icms_xml.
                IF wg_litax_new-base IS NOT INITIAL.
                  wg_litax_new-base = ( gn_base_icms * gn_predbc_icms ) / 100.
                  gn_base_icms_xml = wg_litax_new-base.
                ELSEIF wg_litax_new-othbas IS NOT INITIAL.
                  wg_litax_new-othbas = ( gn_base_icms * gn_predbc_icms ) / 100.
                  gn_base_icms_xml = wg_litax_new-othbas.
                ENDIF.

* Calcula base excuída
                IF wg_docmn-value GT gn_base_icms_xml.
                  IF wg_litax_new-excbas IS NOT INITIAL.
                    wg_litax_new-excbas = ( wg_docmn-value - gn_base_icms_xml ).
                  ELSEIF wg_litax_new-othbas IS NOT INITIAL.
                    wg_litax_new-othbas = ( wg_docmn-value - gn_base_icms_xml ).
                  ENDIF.
                ELSEIF wg_docmn-value LT gn_base_icms_xml.
                  IF wg_litax_new-excbas IS NOT INITIAL.
                    wg_litax_new-excbas = ( gn_base_icms_xml - wg_docmn-value ).
                  ELSEIF wg_litax_new-othbas IS NOT INITIAL.
                    wg_litax_new-othbas = ( gn_base_icms_xml - wg_docmn-value ).
                  ENDIF.
                ENDIF.

              CATCH cx_root INTO o_excp.
                CALL METHOD o_excp->if_message~get_text
                  RECEIVING
                    result = vl_message.
            ENDTRY.

          ENDIF.

        ELSE.

          CLEAR: wg_docmn, wg_docmn_x.
          READ TABLE tg_docmn INTO wg_docmn WITH KEY mneum = 'ICMSVBCST'
                                                     dcitm = tg_lineitem_new-refitm.

          READ TABLE tg_docmn INTO wg_docmn_x WITH KEY mneum = 'VICMSST'
                                                       dcitm = tg_lineitem_new-refitm.

          gn_base_icmsst = wg_docmn-value.
          gn_val_icmsst = wg_docmn_x-value.

* Altera o valor do ICMS
          IF wg_litax_new-taxval NE gn_val_icmsst
          AND gn_val_icmsst IS NOT INITIAL.
            wg_litax_new-taxval = gn_val_icmsst.
          ENDIF.

* Altera a base do ICMSST
          IF wg_litax_new-base NE gn_base_icmsst
          AND wg_litax_new-base IS NOT INITIAL
          AND gn_base_icmsst IS NOT INITIAL.
            wg_litax_new-base = gn_base_icmsst.
          ENDIF.

* Altera a outra base do ICMSST
          IF wg_litax_new-othbas NE gn_base_icmsst
          AND wg_litax_new-othbas IS NOT INITIAL
          AND gn_base_icmsst IS NOT INITIAL.
            wg_litax_new-othbas = gn_base_icmsst.
          ENDIF.

* Verifica se existe percentual de redução de alíquota
          IF gn_predbcst_icmsst IS INITIAL.

* Altera a base excluída do ICMSST
            IF wg_litax_new-excbas NE gn_base_icmsst
            AND wg_litax_new-excbas IS NOT INITIAL
            AND gn_base_icmsst IS NOT INITIAL.
              wg_litax_new-excbas = gn_base_icmsst.
            ENDIF.

          ELSE.

* Encontra Base total
            TRY.
*            lc_base_total = ( gn_base_icmsst  / gn_predbcst_icmsst ) * 100.
                CLEAR: gf_base_icms, gf_predbc_icms, lc_base_total.

                gf_base_icms    = gn_base_icmsst / 100.
                gf_predbc_icms  = gn_predbcst_icmsst / 100.

                lc_base_total   = ( gf_base_icms  / ( 100 - gf_predbc_icms ) ) * 100.

* Calcula base excuída
                wg_litax_new-excbas = ( lc_base_total - gf_base_icms ) * 100.

              CATCH cx_root INTO o_excp.
                CALL METHOD o_excp->if_message~get_text
                  RECEIVING
                    result = vl_message.
            ENDTRY.


          ENDIF.

        ENDIF.

      WHEN 'IPI'.

        CLEAR wg_docmn.
        READ TABLE tg_docmn INTO wg_docmn WITH KEY mneum = 'IPIVBC'
                                                   dcitm = tg_lineitem_new-refitm.
        IF wg_docmn-value IS INITIAL OR wg_docmn-value EQ '0.00'.
          CLEAR wg_docmn.
          READ TABLE tg_docmn INTO wg_docmn WITH KEY mneum = 'VPROD'
                                                     dcitm = tg_lineitem_new-refitm.
          IF sy-subrc IS NOT INITIAL.
            CLEAR wg_docmn.
            READ TABLE tg_docmn INTO wg_docmn WITH KEY mneum = 'VTPREST'.

            CLEAR wg_docmn_x.
            READ TABLE tg_docmn INTO wg_docmn_x WITH KEY mneum = 'VIPI'.
          ENDIF.
        ENDIF.

        IF wg_docmn_x-value IS INITIAL.
          CLEAR wg_docmn_x.
          READ TABLE tg_docmn INTO wg_docmn_x WITH KEY mneum = 'VIPI'
                                                      dcitm = tg_lineitem_new-refitm.
        ENDIF.

        gn_base_ipi = wg_docmn-value.
        gn_val_ipi = wg_docmn_x-value.

* Altera o valor do IPI
        IF wg_litax_new-taxval NE gn_val_ipi
        AND gn_val_ipi IS NOT INITIAL.
          wg_litax_new-taxval = gn_val_ipi.
        ENDIF.

* Altera a base do IPI
        IF wg_litax_new-base NE gn_base_ipi
        AND wg_litax_new-base IS NOT INITIAL
        AND gn_base_ipi IS NOT INITIAL.
          wg_litax_new-base = gn_base_ipi.
        ENDIF.

* Altera a base do IPI
        IF wg_litax_new-othbas NE gn_base_ipi
        AND wg_litax_new-othbas IS NOT INITIAL
        AND gn_base_ipi IS NOT INITIAL.
          wg_litax_new-othbas = gn_base_ipi.
        ENDIF.

* Altera a base do IPI
        IF wg_litax_new-excbas NE gn_base_ipi
        AND wg_litax_new-excbas IS NOT INITIAL
        AND gn_base_ipi IS NOT INITIAL.
          wg_litax_new-excbas = gn_base_ipi.
        ENDIF.

*COFI
      WHEN 'COFI'.

        CLEAR: wg_docmn.
        READ TABLE tg_docmn INTO wg_docmn WITH KEY mneum = 'VPROD'
                                                   dcitm = tg_lineitem_new-refitm.
        IF sy-subrc IS NOT INITIAL.
          CLEAR wg_docmn.
          READ TABLE tg_docmn INTO wg_docmn WITH KEY mneum = 'VTPREST'.

****Comentado 29/03/2019 a pedido da Gicele
**          CLEAR wg_docmn_x.
**          READ TABLE tg_docmn INTO wg_docmn_x WITH KEY mneum = 'VCOFINS'.
        ENDIF.

**        IF wg_docmn_x-value IS INITIAL.
********
**          CLEAR wg_docmn_rate.
**          READ TABLE tg_docmn INTO wg_docmn_rate WITH KEY mneum = 'PCOFINS'
**                                                          dcitm = tg_lineitem_new-refitm.
**          IF wg_litax_new-rate EQ wg_docmn_rate-value.
**            CLEAR wg_docmn_x.
**            READ TABLE tg_docmn INTO wg_docmn_x WITH KEY mneum = 'VCOFINS'
**                                                        dcitm = tg_lineitem_new-refitm.
**          ENDIF.
**        ENDIF.

        gn_base_ipi = wg_docmn-value.
        gn_val_ipi = wg_docmn_x-value.

*** Altera o valor do COFINS
**        IF wg_litax_new-taxval NE gn_val_ipi
**        AND gn_val_ipi IS NOT INITIAL.
**          wg_litax_new-taxval = gn_val_ipi.
**        ENDIF.

* Altera a base do COFINS
        IF wg_litax_new-base NE gn_base_ipi
        AND wg_litax_new-base IS NOT INITIAL
        AND gn_base_ipi IS NOT INITIAL.
          wg_litax_new-base = gn_base_ipi.
        ENDIF.

* Altera a base do COFINS
        IF wg_litax_new-othbas NE gn_base_ipi
        AND wg_litax_new-othbas IS NOT INITIAL
        AND gn_base_ipi IS NOT INITIAL.
          wg_litax_new-othbas = gn_base_ipi.
        ENDIF.

* Altera a base do COFINS
        IF wg_litax_new-excbas NE gn_base_ipi
        AND wg_litax_new-excbas IS NOT INITIAL
        AND gn_base_ipi IS NOT INITIAL.
          wg_litax_new-excbas = gn_base_ipi.
        ENDIF.

*PIS
      WHEN 'PIS'.

        CLEAR: wg_docmn.
        READ TABLE tg_docmn INTO wg_docmn WITH KEY mneum = 'VPROD'
                                                   dcitm = tg_lineitem_new-refitm.
        IF sy-subrc IS NOT INITIAL.
          CLEAR wg_docmn.
          READ TABLE tg_docmn INTO wg_docmn WITH KEY mneum = 'VTPREST'.

**          READ TABLE tg_docmn INTO wg_docmn_x WITH KEY mneum = 'VPIS'.
        ENDIF.

**        IF wg_docmn_x-value IS INITIAL.
**
**          CLEAR wg_docmn_rate.
**          READ TABLE tg_docmn INTO wg_docmn_rate WITH KEY mneum = 'PPIS'
**                                                          dcitm = tg_lineitem_new-refitm.
**          IF wg_litax_new-rate EQ wg_docmn_rate-value.
**            CLEAR wg_docmn_x.
**            READ TABLE tg_docmn INTO wg_docmn_x WITH KEY mneum = 'VPIS'
**                                                        dcitm = tg_lineitem_new-refitm.
**          ENDIF.
**        ENDIF.

        gn_base_ipi = wg_docmn-value.
        gn_val_ipi = wg_docmn_x-value.

*** Altera o valor do PIS
**        IF wg_litax_new-taxval NE gn_val_ipi
**        AND gn_val_ipi IS NOT INITIAL.
**          wg_litax_new-taxval = gn_val_ipi.
**        ENDIF.

* Altera a base do PIS
        IF wg_litax_new-base NE gn_base_ipi
        AND wg_litax_new-base IS NOT INITIAL
        AND gn_base_ipi IS NOT INITIAL.
          wg_litax_new-base = gn_base_ipi.
        ENDIF.

* Altera a base do PIS
        IF wg_litax_new-othbas NE gn_base_ipi
        AND wg_litax_new-othbas IS NOT INITIAL
        AND gn_base_ipi IS NOT INITIAL.
          wg_litax_new-othbas = gn_base_ipi.
        ENDIF.

* Altera a base do PIS
        IF wg_litax_new-excbas NE gn_base_ipi
        AND wg_litax_new-excbas IS NOT INITIAL
        AND gn_base_ipi IS NOT INITIAL.
          wg_litax_new-excbas = gn_base_ipi.
        ENDIF.

*ICOP
      WHEN 'ICOP'.

      WHEN OTHERS.

        CLEAR: wg_docmn.
        READ TABLE tg_docmn INTO wg_docmn WITH KEY mneum = 'VPROD'
                                                   dcitm = tg_lineitem_new-refitm.
        IF sy-subrc IS NOT INITIAL.
          CLEAR wg_docmn.
          READ TABLE tg_docmn INTO wg_docmn WITH KEY mneum = 'VTPREST'.
        ENDIF.

        gn_base_ipi = wg_docmn-value.

* Altera a base
        IF wg_litax_new-base NE gn_base_ipi
        AND wg_litax_new-base IS NOT INITIAL
        AND gn_base_ipi IS NOT INITIAL.
          wg_litax_new-base = gn_base_ipi.
        ENDIF.

* Altera a outra base
        IF wg_litax_new-othbas NE gn_base_ipi
        AND wg_litax_new-othbas IS NOT INITIAL
        AND gn_base_ipi IS NOT INITIAL.
          wg_litax_new-othbas = gn_base_ipi.
        ENDIF.

    ENDCASE.

    MODIFY tg_litax_new FROM wg_litax_new INDEX gc_tabix.
    CLEAR: wg_litax_new, wg_docmn, wg_docmn_x.

  ENDLOOP.

ENDFORM.                    " F_MODIFICA_DADOS_MIRO
*&---------------------------------------------------------------------*
*&      Form  F_ATUALIZA_DADOS_MIRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_atualiza_dados_miro .

  CALL FUNCTION 'J_1B_NF_IV_COMPARE_TABLES'
    EXPORTING
      i_header        = wg_nfheader
      i_xheader       = wg_nfheader_new
      i_objnum        = gn_nfobjn
    IMPORTING
      e_header        = wg_nfheader
      e_flag          = gc_change_flag
    TABLES
      i_itm           = tg_lineitem
      e_itm           = tg_lineitem_new
      i_tax           = tg_litax
      e_tax           = tg_litax_new
    EXCEPTIONS
      different_items = 1.

*-    - Update actuel object into buffer ----------------------------------*
  CALL FUNCTION 'J_1B_NF_OBJECT_UPDATE'
    EXPORTING
      obj_number       = gn_nfobjn
      obj_header       = wg_nfheader
    TABLES
      obj_partner      = tg_partner
      obj_item         = tg_lineitem_new
      obj_item_tax     = tg_litax_new
      obj_header_msg   = tg_hdtext
      obj_refer_msg    = tg_rftext                          ">> 1258062
*     obj_ot_partner   = ot_partner
      obj_ot_partner   = tg_ot_partner_new                  "<< 1258062
    EXCEPTIONS
      object_not_found = 01.

ENDFORM.                    " F_ATUALIZA_DADOS_MIRO
*&---------------------------------------------------------------------*
*&      Form  F_BUSCA_ICM_XML
*&---------------------------------------------------------------------*
FORM f_busca_icm_xml .

  DATA lc_fs_nome(40)  TYPE c.
  DATA tl_x031l        TYPE TABLE OF x031l.
  DATA wl_x031l        TYPE x031l.

* Carrega o nome dos campos da tabela
*  CLEAR tl_x031l.
  CLEAR: tl_x031l, gn_base_icms, gn_val_icms, gn_predbc_icms,
         gn_base_icmsst, gn_val_icms, gn_predbcst_icmsst.

  PERFORM f_buscar_campos_tab  TABLES tl_x031l USING 'ZHMS_TB_DOCMN'  .

  LOOP AT tl_x031l INTO wl_x031l.

* Checa qual o campo verificado e carrega seu conteúdo
    CONCATENATE 'WG_DADOS_ICM' wl_x031l-fieldname
           INTO lc_fs_nome
           SEPARATED BY '-'.

    UNASSIGN <fs_icms>.
    ASSIGN (lc_fs_nome) TO <fs_icms>.

    IF NOT <fs_icms>  IS INITIAL.

      IF wl_x031l-fieldname     CP  '*_VBC'.
        gn_base_icms = gn_base_icms + <fs_icms>.
      ELSEIF wl_x031l-fieldname CP  '*_VICMS'.
        gn_val_icms = gn_val_icms + <fs_icms>.
      ELSEIF wl_x031l-fieldname CP  '*_PREDBC'.
        gn_predbc_icms = gn_predbc_icms + <fs_icms>.
      ELSEIF wl_x031l-fieldname CP  '*_VBCST'.
        gn_base_icmsst = gn_base_icmsst + <fs_icms>.
      ELSEIF wl_x031l-fieldname CP  '*_VICMSST'.
        gn_val_icms = gn_val_icmsst + <fs_icms>.
      ELSEIF wl_x031l-fieldname CP  '*_PREDBCST'.
        gn_predbcst_icmsst = gn_predbcst_icmsst + <fs_icms>.
      ENDIF.

    ENDIF.

  ENDLOOP.

ENDFORM.                    " F_BUSCA_ICM_XML
*&---------------------------------------------------------------------*
*&      Form  F_BUSCA_IPI_XML
*&---------------------------------------------------------------------*
FORM f_busca_ipi_xml .

  DATA: lc_fs_nome(40)  TYPE c,
        tl_x031l        TYPE TABLE OF x031l,
        wl_x031l        TYPE x031l.

* Carrega o nome dos campos da tabela
  CLEAR: tl_x031l, gn_base_ipi, gn_val_ipi.
  PERFORM f_buscar_campos_tab  TABLES tl_x031l USING 'ZHMS_TB_DOCMN' .

  LOOP AT tl_x031l INTO wl_x031l.

* Checa qual o campo verificado e carrega seu conteúdo
    CONCATENATE 'WG_DADOS_IPI' wl_x031l-fieldname
           INTO lc_fs_nome
           SEPARATED BY '-'.

    UNASSIGN <fs_ipi>.
    ASSIGN (lc_fs_nome) TO <fs_ipi>.

    IF NOT <fs_ipi>  IS INITIAL.

      IF wl_x031l-fieldname CP  '*_VBC'.
*       gn_base_ipi = gn_base_ipi + <fs_icms>.
        gn_base_ipi = gn_base_ipi + <fs_ipi>.
      ELSEIF wl_x031l-fieldname CP  '*_VIPI'.
*       gn_val_ipi = gn_val_ipi + <fs_icms>.
        gn_val_ipi = gn_val_ipi + <fs_ipi>.
      ENDIF.

    ENDIF.

  ENDLOOP.

ENDFORM.                    " F_BUSCA_IPI_XML
*&---------------------------------------------------------------------*
*&      Form  f_buscar_campos_tab
*&---------------------------------------------------------------------*
FORM f_buscar_campos_tab  TABLES  p_tl_x031l
                          USING   p_tabname  TYPE dd02l-tabname.

  CALL FUNCTION 'DD_GET_NAMETAB'
    EXPORTING
      tabname   = p_tabname
    TABLES
      x031l_tab = p_tl_x031l
    EXCEPTIONS
      not_found = 1
      no_fields = 2
      OTHERS    = 3.

ENDFORM.                    " f_buscar_campos_tab
*&---------------------------------------------------------------------*
*&      Form  F_SELECIONA_DADOS_XML_CTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_seleciona_dados_xml_cte .

*  SELECT SINGLE *
*    FROM zcfget013
*    INTO wg_cte_selection
*    WHERE chave_cte = gc_chave_acesso.

ENDFORM.                    " F_SELECIONA_DADOS_XML_CTE
*&---------------------------------------------------------------------*
*&      Form  F_MODIFICA_DADOS_MIRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_modifica_dados_miro_cte.

  DATA:
        lc_taxgrp       TYPE j_1baj-taxgrp,
        gf_base_icms    TYPE f,
        gf_predbc_icms  TYPE f,
        vl_message      TYPE string,
*        count       TYPE i,
        o_excp          TYPE REF TO cx_root,
        lc_base_total   TYPE f. "j_1bnfstx-base.

* Move dados atuais para tabelas temporárias
  wg_nfheader_new      = wg_nfheader.
  tg_lineitem_new[]    = tg_lineitem[].
  tg_litax_new[]       = tg_litax[].
  tg_ot_partner_new[]  = tg_ot_partner[].

*  LOOP AT tg_lineitem_new.
*
*    gc_tabix = sy-tabix.
*
*    CLEAR wg_nfe_alv_item.
*    READ TABLE tg_nfe_alv_item INTO wg_nfe_alv_item INDEX sy-tabix.
*
*    tg_lineitem_new-nbm = wg_nfe_alv_item-det_ncm.
*
*    MODIFY tg_lineitem_new INDEX gc_tabix.
*
*  ENDLOOP.

* Loop em registros de impostos da nota no SAP
  LOOP AT tg_litax_new INTO wg_litax_new.

    gc_tabix = sy-tabix.

    CLEAR: gn_base_icms, gn_base_icmsst, gn_base_ipi,
           gn_val_icms,  gn_val_icmsst,  gn_val_ipi.

* Lê item da nota no SAP
    READ TABLE tg_lineitem_new WITH KEY itmnum = wg_litax_new-itmnum.

* Lê ICMS do item da nota no XML
*    READ TABLE tg_dados_icm INTO wg_dados_icm INDEX tg_lineitem_new-refitm.

* Lê IPI do item da nota no XML
*    READ TABLE tg_dados_ipi INTO wg_dados_ipi INDEX tg_lineitem_new-refitm.

* Verifica o tipo de imposto do registro
    CLEAR lc_taxgrp.
    SELECT SINGLE taxgrp
      FROM j_1baj
      INTO lc_taxgrp
     WHERE taxtyp EQ wg_litax_new-taxtyp.

    CASE lc_taxgrp.
      WHEN 'ICMS' OR 'ICST'.

* Buscar dados do ICMS
*        PERFORM f_busca_icm_xml.

*        CHECK gn_predbc_icms IS INITIAL AND
*              gn_predbcst_icmsst IS INITIAL.
*
        IF lc_taxgrp EQ 'ICMS'.
*          gn_val_icms  = wg_cte_selection-icms_vicms.
*          gn_base_icms = wg_cte_selection-icms_vbc.

* Altera o valor do ICMS
          IF wg_litax_new-taxval NE gn_val_icms
          AND gn_val_icms IS NOT INITIAL.
            wg_litax_new-taxval = gn_val_icms.
          ENDIF.

* Altera a base do ICMS
          IF wg_litax_new-base NE gn_base_icms
          AND wg_litax_new-base IS NOT INITIAL
          AND gn_base_icms IS NOT INITIAL.
            wg_litax_new-base = gn_base_icms.
          ENDIF.

* Altera a outra base do ICMS
*          IF wg_litax_new-othbas NE gn_base_icms
*          AND wg_litax_new-othbas IS NOT INITIAL
*          AND gn_base_icms IS NOT INITIAL.
*            wg_litax_new-othbas = gn_base_icms.
*          ENDIF.
*
** Verifica se existe percentual de redução de alíquota
*          IF gn_predbc_icms IS INITIAL.
*
** Altera a base excuída do ICMS
*            IF wg_litax_new-excbas NE gn_base_icms
*            AND wg_litax_new-excbas IS NOT INITIAL
*            AND gn_base_icms IS NOT INITIAL.
*              wg_litax_new-excbas = gn_base_icms.
*            ENDIF.

*          ELSE.

** Encontra Base total
*            TRY.
*
*                CLEAR: gf_base_icms, gf_predbc_icms, lc_base_total.
*
*                gf_base_icms    = gn_base_icms / 100.
*                gf_predbc_icms  = gn_predbc_icms / 100.
*
*                lc_base_total = ( gf_base_icms  / ( 100 - gf_predbc_icms ) ) * 100.
*
** Calcula base excuída
*                wg_litax_new-excbas = ( lc_base_total - gf_base_icms ) * 100.
*
*              CATCH cx_root INTO o_excp.
*                CALL METHOD o_excp->if_message~get_text
*                  RECEIVING
*                    result = vl_message.
*            ENDTRY.
*
*          ENDIF.

*        ELSE.
*
** Altera o valor do ICMS
*          IF wg_litax_new-taxval NE gn_val_icmsst
*          AND gn_val_icmsst IS NOT INITIAL.
*            wg_litax_new-taxval = gn_val_icmsst.
*          ENDIF.
*
** Altera a base do ICMSST
*          IF wg_litax_new-base NE gn_base_icmsst
*          AND wg_litax_new-base IS NOT INITIAL
*          AND gn_base_icmsst IS NOT INITIAL.
*            wg_litax_new-base = gn_base_icmsst.
*          ENDIF.
*
** Altera a outra base do ICMSST
*          IF wg_litax_new-othbas NE gn_base_icmsst
*          AND wg_litax_new-othbas IS NOT INITIAL
*          AND gn_base_icmsst IS NOT INITIAL.
*            wg_litax_new-othbas = gn_base_icmsst.
*          ENDIF.
*
** Verifica se existe percentual de redução de alíquota
*          IF gn_predbcst_icmsst IS INITIAL.
*
** Altera a base excluída do ICMSST
*            IF wg_litax_new-excbas NE gn_base_icmsst
*            AND wg_litax_new-excbas IS NOT INITIAL
*            AND gn_base_icmsst IS NOT INITIAL.
*              wg_litax_new-excbas = gn_base_icmsst.
*            ENDIF.
*
*          ELSE.
*
** Encontra Base total
*            TRY.
**            lc_base_total = ( gn_base_icmsst  / gn_predbcst_icmsst ) * 100.
*                CLEAR: gf_base_icms, gf_predbc_icms, lc_base_total.
*
*                gf_base_icms    = gn_base_icmsst / 100.
*                gf_predbc_icms  = gn_predbcst_icmsst / 100.
*
*                lc_base_total   = ( gf_base_icms  / ( 100 - gf_predbc_icms ) ) * 100.
*
** Calcula base excuída
*                wg_litax_new-excbas = ( lc_base_total - gf_base_icms ) * 100.
*
*              CATCH cx_root INTO o_excp.
*                CALL METHOD o_excp->if_message~get_text
*                  RECEIVING
*                    result = vl_message.
*            ENDTRY.
*
*
*          ENDIF.

        ENDIF.

      WHEN 'IPI'.

* Buscar dados do IPI
*        PERFORM f_busca_ipi_xml.
****        gn_base_ipi = wg_cte_selection-icms_vbc.

* Altera o valor do IPI
        IF wg_litax_new-taxval NE gn_val_ipi
        AND gn_val_ipi IS NOT INITIAL.
          wg_litax_new-taxval = gn_val_ipi.
        ENDIF.

* Altera a base do IPI
        IF wg_litax_new-base NE gn_base_ipi
        AND wg_litax_new-base IS NOT INITIAL
        AND gn_base_ipi IS NOT INITIAL.
          wg_litax_new-base = gn_base_ipi.
        ENDIF.

* Altera a base do IPI
        IF wg_litax_new-othbas NE gn_base_ipi
        AND wg_litax_new-othbas IS NOT INITIAL
        AND gn_base_ipi IS NOT INITIAL.
          wg_litax_new-othbas = gn_base_ipi.
        ENDIF.

* Altera a base do IPI
        IF wg_litax_new-excbas NE gn_base_ipi
        AND wg_litax_new-excbas IS NOT INITIAL
        AND gn_base_ipi IS NOT INITIAL.
          wg_litax_new-excbas = gn_base_ipi.
        ENDIF.


      WHEN 'COFI'.

* Buscar dados do COFINS
*        PERFORM f_busca_ipi_xml.
***        gn_base_cof = wg_cte_selection-icms_vbc.

* Altera o valor do COFINS
        IF wg_litax_new-taxval NE gn_val_cof
        AND gn_val_cof IS NOT INITIAL.
          wg_litax_new-taxval = gn_val_cof.
        ENDIF.

* Altera a base do COFINS
        IF wg_litax_new-base NE gn_base_cof
        AND wg_litax_new-base IS NOT INITIAL
        AND gn_base_cof IS NOT INITIAL.
          wg_litax_new-base = gn_base_cof.
        ENDIF.

* Altera a base do COFINS
        IF wg_litax_new-othbas NE gn_base_cof
        AND wg_litax_new-othbas IS NOT INITIAL
        AND gn_base_cof IS NOT INITIAL.
          wg_litax_new-othbas = gn_base_cof.
        ENDIF.

* Altera a base do COFINS
        IF wg_litax_new-excbas NE gn_base_ipi
        AND wg_litax_new-excbas IS NOT INITIAL
        AND gn_base_ipi IS NOT INITIAL.
          wg_litax_new-excbas = gn_base_cof.
        ENDIF.


      WHEN 'PIS'.

* Buscar dados do PIS
*        PERFORM f_busca_ipi_xml.
**        gn_base_pis = wg_cte_selection-icms_vbc.

* Altera o valor do IPI
        IF wg_litax_new-taxval NE gn_val_pis
        AND gn_val_pis IS NOT INITIAL.
          wg_litax_new-taxval = gn_val_pis.
        ENDIF.

* Altera a base do PIS
        IF wg_litax_new-base NE gn_base_pis
        AND wg_litax_new-base IS NOT INITIAL
        AND gn_base_pis IS NOT INITIAL.
          wg_litax_new-base = gn_base_pis.
        ENDIF.

* Altera a base do PIS
        IF wg_litax_new-othbas NE gn_base_pis
        AND wg_litax_new-othbas IS NOT INITIAL
        AND gn_base_pis IS NOT INITIAL.
          wg_litax_new-othbas = gn_base_pis.
        ENDIF.

* Altera a base do PIS
        IF wg_litax_new-excbas NE gn_base_pis
        AND wg_litax_new-excbas IS NOT INITIAL
        AND gn_base_pis IS NOT INITIAL.
          wg_litax_new-excbas = gn_base_pis.
        ENDIF.

    ENDCASE.

    MODIFY tg_litax_new FROM wg_litax_new INDEX gc_tabix.

  ENDLOOP.


ENDFORM.                    " F_MODIFICA_DADOS_MIRO_CTE
