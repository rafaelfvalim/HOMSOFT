*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_GATEO02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  CARREGADADOS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
DATA: T_DOC TYPE TABLE OF J_1BNFDOC,
      T_LIN TYPE TABLE OF J_1BNFLIN,

      T_DOCMN TYPE TABLE OF  ZHMS_TB_DOCMN,
      T_LFA1 TYPE TABLE OF LFA1,
      W_DOC TYPE J_1BNFDOC,
      W_LIN TYPE J_1BNFLIN,



      T_CARGA TYPE TABLE OF ZHMS_GATE_PORTA,
      W_CARGA TYPE ZHMS_GATE_PORTA,
      T_CARGA_ITEM TYPE TABLE OF ZHMS_GATE_ITEM,
      W_CARGA_ITEM TYPE ZHMS_GATE_ITEM,

      WA_LFA1 TYPE LFA1.



DATA: VG_BUKRS       TYPE C LENGTH 10,
      VG_BUTXT       TYPE T001-BUTXT,
      VG_WERKS       TYPE T001W-WERKS VALUE 'HOMI',
      VG_NM_WERKS    TYPE T001W-NAME1,
      VG_DT_EMISS_D  TYPE SY-DATUM,
      VG_DT_EMISS_A  TYPE SY-DATUM,
      VG_DT_RECB_D   TYPE SY-DATUM,
      VG_DT_RECB_A   TYPE SY-DATUM,
      VG_CNPJ_EMISS  TYPE LFA1-STCD1,
      VG_STATUS(30)  TYPE C,
      VG_NFNUM       TYPE ZHOM_NFE_REC-NFENUM,
      VG_SERIE       TYPE J_1BNFDOC-SERIES,
      VG_CHAVE(44)   TYPE C,
      VG_EMPRESA     TYPE ZHOM_NFE_REC-EMPRESA,
      VG_FILIAL      TYPE ZHOM_NFE_REC-FILIAL,
      VG_CENTRO      TYPE ZHOM_NFE_REC-WERKS,
      VG_CTE(1)      TYPE C,
      VG_NFE(1)      TYPE C,
      VG_UCOMM       TYPE SY-UCOMM,
      VG_CONSULTA    TYPE C,
      VG_COD_TRANSP  TYPE ZHOM_TRANSPORTE-COD_TRANSP,
      VG_RG_MOTORST  TYPE ZHOM_TRANSPORTE-ID_MOTORISTA,
      VG_NM_MOTOR    TYPE ZHOM_TRANSPORTE-NAME1,
      VG_RG_AJUDANT  TYPE ZHOM_TRANSPORTE-RG_AJUDANTE,
      VG_NM_AJUD     TYPE ZHOM_TRANSPORTE-NAME2,
      VG_CNH         TYPE ZHOM_TRANSPORTE-NR_CNH,
      VG_VALID_CNH   TYPE ZHOM_TRANSPORTE-VALID_CNH,
      VG_CATEG_CNH   TYPE ZHOM_TRANSPORTE-CATEG_CNH,
      VG_STATUS_CNH(35) TYPE C,
      VG_ICONE_CNH(4) TYPE C,
      VG_TOCO        TYPE ZHOM_VEICULO-PLACA_TOCO,
      VG_PLACA1      TYPE ZHOM_VEICULO-PLACA_CAR1,
      VG_PLACA2      TYPE ZHOM_VEICULO-PLACA_CAR2,
      VG_PLACA3      TYPE ZHOM_VEICULO-PLACA_CAR3,
      VG_TP_VEIC     TYPE ZHOM_VEICULO-TIPO_VEICULO,
      VG_COD_RENAVAM TYPE ZHOM_VEICULO-COD_RENAVAM,
      VG_EXERCICIO   TYPE ZHOM_VEICULO-ANO_EXERCICIO,
      VG_VALIDADE    TYPE ZHOM_VEICULO-VALIDADE,
      VG_ESPECIE     TYPE ZHOM_VEICULO-ESPECIE,
      VG_TIPO        TYPE ZHOM_VEICULO-TIPO,
      VG_COR         TYPE ZHOM_VEICULO-COR,
      VG_CHASSI      TYPE ZHOM_VEICULO-CHASSI,
      VG_NR_DPVAT    TYPE ZHOM_VEICULO-NR_DPVAT,
      VG_VALID_DPVAT TYPE ZHOM_VEICULO-VALID_DPVAT,
      VG_TARA_TOTAL  TYPE ZHOM_VEICULO-TARA_TOTAL,
      VG_FAROL_NF(10) TYPE C,
      VG_ENTRADA      TYPE C,
      VG_SAIDA        TYPE C,
      VG_TRUCADO      TYPE C VALUE 'X',
      VG_CARRETA      TYPE C,
      VG_TREM         TYPE C,
      VG_TRITREM      TYPE C,
      VG_BITREM       TYPE C,
      VG_VAGAO        TYPE C,
      VG_NAVIO        TYPE C,
      VG_OUTROS       TYPE C,
      VG_PESO_IN      TYPE ZHOM_PESOS-PES_BRU_IN,
      VG_PESO_OUT     TYPE ZHOM_PESOS-PES_BRU_OUT,
      VG_VOLUME       TYPE ZHOM_PESOS-NR_VOLUME,
      VG_RESP         TYPE C,
      VG_MTART        TYPE MARA-MTART,
      VG_MATNR        TYPE MARA-MATNR,
      VG_MESS(3)      TYPE C,
      VG_OK           TYPE C,
      VG_INT          TYPE C,
      VG_FIRST(20)    TYPE C,
      VG_PESO_BRUTO_SAIDA TYPE J_1BNFDOC-BRGEW,
      VG_PESO_SAIDA   TYPE J_1BNFDOC-BRGEW,
      VG_PESO_DIF     TYPE J_1BNFDOC-BRGEW,
      VG_PERC         TYPE P DECIMALS 2,
      VG_NUM_CARGA    TYPE C LENGTH 10,
      VG_ICON         TYPE C LENGTH 4,
      VG_DIF_CB       TYPE P DECIMALS 2,
      VG_PESO_ENTRADA TYPE P DECIMALS 2,
      LV_CHAVE        type c LENGTH 44,
      VG_NNF          TYPE C LENGTH 9,
      VG_DHEMI        TYPE C LENGTH 100,
      VG_HORA         type C length 8,
      VL_DATA         TYPE SCAL-DATE,
      VG_NM_BRANCH    type c length 300.


MODULE CARREGADADOS OUTPUT.
DATA: vl_dayw    TYPE scal-indicator,
      vl_langt   TYPE t246-langt,
      vl_mnr     TYPE t247-mnr,
      vl_ltx     TYPE t247-ltx.

*LV_CHAVE = '35180504897652000121550010000023991666433473'.
LV_CHAVE = vg_cnf_chave.

*SELECT * FROM ZHMS_TB_DOCMN INTO TABLE T_DOCMN WHERE CHAVE = LV_CHAVE.


*Número da NF-e
SELECT SINGLE VALUE FROM ZHMS_TB_DOCMN INTO vg_nnf WHERE MNEUM EQ 'NNF' AND CHAVE = LV_CHAVE.

*Data de Emissão
SELECT SINGLE VALUE FROM ZHMS_TB_DOCMN INTO vg_dhemi WHERE MNEUM EQ 'DHEMI' AND CHAVE = LV_CHAVE.
CONCATENATE vg_dhemi+0(4)  vg_dhemi+8(2) vg_dhemi+5(2) into vl_data.
vg_hora = vg_dhemi+11(8).


  CALL FUNCTION 'DATE_COMPUTE_DAY'
        EXPORTING
          date = vl_data
        IMPORTING
          day  = vl_dayw.

      SELECT SINGLE langt
        INTO vl_langt
        FROM t246
       WHERE wotnr EQ vl_dayw
         AND sprsl EQ sy-langu.

      vl_mnr =  vl_data+4(2).
      SELECT SINGLE ltx
        INTO vl_ltx
        FROM t247
       WHERE spras EQ sy-langu
         AND mnr   EQ vl_mnr.

      CONCATENATE  vl_langt ',' vl_data+6 ' de ' vl_ltx vl_data(4) INTO vg_dhemi SEPARATED BY space.

*Fornecedor
SELECT SINGLE VALUE FROM ZHMS_TB_DOCMN INTO VG_BUTXT WHERE MNEUM EQ 'CNPJDEST' AND CHAVE = LV_CHAVE.
SELECT * FROM LFA1 INTO TABLE T_LFA1 WHERE STCD1 EQ VG_BUTXT.
loop at t_lfa1 into wa_lfa1.
CONCATENATE '(' WA_LFA1-LIFNR ')' WA_LFA1-NAME1 INTO VG_BUTXT.
endloop.



SELECT SINGLE *
        INTO wa_cabdoc
        FROM zhms_tb_cabdoc
       WHERE chave EQ lv_chave.



        SELECT SINGLE butxt INTO VG_NM_WERKS
        FROM t001
       WHERE bukrs EQ wa_cabdoc-bukrs.

          concatenate '(' wa_cabdoc-bukrs ')' vg_nm_werks into vg_nm_werks.


      SELECT SINGLE name
        INTO VG_NM_BRANCH
        FROM j_1bbranch
       WHERE bukrs  EQ wa_cabdoc-bukrs
         AND branch EQ wa_cabdoc-branch.


      SELECT MAX( seqnr )
        INTO wa_docconf-seqnr
        FROM zhms_tb_docconf
       WHERE natdc = wa_cabdoc-natdc
         AND typed = wa_cabdoc-typed
         AND chave = wa_cabdoc-chave.



      ADD 1 TO wa_docconf-seqnr.

**    Insere dados nas variáveis
      wa_docconf-natdc = wa_cabdoc-natdc.
      wa_docconf-typed = wa_cabdoc-typed.
      wa_docconf-chave = wa_cabdoc-chave.
      wa_docconf-dtreg = sy-datum.
      wa_docconf-hrreg = sy-uzeit.
      wa_docconf-uname = sy-uname.
      wa_docconf-dcnro = wa_cabdoc-docnr.
      wa_docconf-parid = wa_cabdoc-parid.
      wa_docconf-ativo = 'X'.
      wa_docconf-logty = 'I'.


      CASE wa_docconf-logty.
        WHEN 'E'.
          vg_conf_status = '@0A@'.
        WHEN 'W'.
          vg_conf_status = '@09@'.
        WHEN 'I'.
          vg_conf_status = '@08@'.
        WHEN 'S'.
          vg_conf_status = '@01@'.
        WHEN OTHERS.
          vg_conf_status = '@08@'.
      ENDCASE.
ENDMODULE.                 " CARREGADADOS  OUTPUT
