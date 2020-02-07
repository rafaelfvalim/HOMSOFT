*----------------------------------------------------------------------*
***INCLUDE ZHMS_180_DIAS_FULL_ROTINAS .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_SELECIONA_DADOS
*&---------------------------------------------------------------------*
FORM F_SELECIONA_DADOS.

* Monta tabela de dados da parte de cima do cockpit
  PERFORM F_MONTA_HEADER.

* Monta catálogo de campos da parte de cima do cockpit
  PERFORM F_MONTA_FCAT USING:
*             'MARK'          TEXT-H01   ABAP_TRUE   ABAP_TRUE   SPACE,
             'ST_ESCR'       TEXT-H02   SPACE       SPACE       SPACE,
             'STATUS'        TEXT-H03   SPACE       SPACE       SPACE,
             'BUKRS'         TEXT-H04   SPACE       SPACE       SPACE,
             'NF_CLI'        TEXT-H05   SPACE       SPACE       space,
             'DT_EMI'        TEXT-H06   SPACE       SPACE       SPACE,
             'NF_ESCR'       TEXT-H07   SPACE       SPACE       SPACE,
             'NF_ITM'        TEXT-H08   SPACE       SPACE       SPACE,
             'MATERIAL'      TEXT-H09   SPACE       SPACE       SPACE,
             'DESCRICAO'     TEXT-H10   SPACE       SPACE       SPACE,
             'QTD_NF'        TEXT-H11   SPACE       SPACE       SPACE,
             'QTD_DEV'       TEXT-H12   SPACE       SPACE       SPACE,
             'QTD_PEND'      TEXT-H13   SPACE       SPACE       SPACE,
             'QTD_ESTOQUE'   TEXT-H14   SPACE       SPACE       SPACE,
             'QTD_FORN'      TEXT-H15   SPACE       SPACE       SPACE,
             'DIAS'          TEXT-H16   SPACE       SPACE       SPACE.

* Monta tabela de dados da legenda
  PERFORM F_MONTA_LEGENDA USING:
             C_ESC       TEXT-O01,
             C_N_ESC     TEXT-O02,
             C_100       TEXT-O03,
             C_100_180   TEXT-O04,
             C_180       TEXT-O05,
             C_DEVOL     TEXT-O06,
             C_NA        TEXT-O07.

* Monta catálogo de campos da legenda
  PERFORM F_MONTA_FCAT3 USING:
             'ICONE'   TEXT-L01   6,
             'DESCR'   TEXT-L02   27.

ENDFORM.                    " F_SELECIONA_DADOS

*&---------------------------------------------------------------------*
*&      Form  F_MONTA_FCAT
*&---------------------------------------------------------------------*
FORM F_MONTA_FCAT USING P_NOME
                        P_TEXTO
                        P_EDIT
                        P_CHECKBOX
                        P_HOTSPOT.

  CLEAR WA_FCAT1.

  WA_FCAT1-FIELDNAME = P_NOME.
  WA_FCAT1-REPTEXT   = P_TEXTO.
  WA_FCAT1-EDIT      = P_EDIT.
  WA_FCAT1-CHECKBOX  = P_CHECKBOX.
  WA_FCAT1-HOTSPOT   = P_HOTSPOT.

  APPEND WA_FCAT1 TO IT_FCAT1.

ENDFORM.                    " F_MONTA_FCAT

*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.
*Apresentação cliente
  DATA: TL_CODES       TYPE TABLE OF SY-UCOMM.

  APPEND: 'NFCLI' TO TL_CODES.
  APPEND: 'NFFORN' TO TL_CODES.
  SET PF-STATUS 'STATUS_200' EXCLUDING TL_CODES.
*Apresentação cliente
  SET TITLEBAR 'TITLE_200'.

* Instancia o objeto apenas uma vez
  IF GO_GRID IS INITIAL.

    CREATE OBJECT GO_EVENT.

    CREATE OBJECT GO_GRID
      EXPORTING
        CONTAINER_NAME              = 'ALVSAIDA'
      EXCEPTIONS
        CNTL_ERROR                  = 1
        CNTL_SYSTEM_ERROR           = 2
        CREATE_ERROR                = 3
        LIFETIME_ERROR              = 4
        LIFETIME_DYNPRO_DYNPRO_LINK = 5
        OTHERS                      = 6.

    CREATE OBJECT GO_ALV
      EXPORTING
        I_PARENT          = GO_GRID
      EXCEPTIONS
        ERROR_CNTL_CREATE = 1
        ERROR_CNTL_INIT   = 2
        ERROR_CNTL_LINK   = 3
        ERROR_DP_CREATE   = 4
        OTHERS            = 5.

    WA_LAYOUT1-CWIDTH_OPT = ABAP_TRUE.     " Otimizar tamanho das colunas
    WA_LAYOUT1-ZEBRA      = ABAP_TRUE.     " Zebra
    WA_LAYOUT1-NO_TOOLBAR = ABAP_TRUE.     " Sem a barra padrão do ALV
    WA_LAYOUT1-NO_ROWMARK = ABAP_TRUE.     " Sem marcador de linhas
    WA_LAYOUT1-STYLEFNAME = 'FIELD_STYLE'. " Campo que receberá estilo

    CALL METHOD GO_ALV->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_LAYOUT                     = WA_LAYOUT1
      CHANGING
        IT_OUTTAB                     = IT_OUTTAB[]
        IT_FIELDCATALOG               = IT_FCAT1[]
      EXCEPTIONS
        INVALID_PARAMETER_COMBINATION = 1
        PROGRAM_ERROR                 = 2
        TOO_MANY_LINES                = 3
        OTHERS                        = 4.

* Chama o método para o clique no número da NF
    SET HANDLER GO_EVENT->HOTSPOT_CLICK FOR GO_ALV.

  ENDIF.

* Instancia o objeto apenas uma vez
  IF GO_LEG IS INITIAL.

    CREATE OBJECT GO_LEG
      EXPORTING
        CONTAINER_NAME              = 'ALVLEGENDA'
      EXCEPTIONS
        CNTL_ERROR                  = 1
        CNTL_SYSTEM_ERROR           = 2
        CREATE_ERROR                = 3
        LIFETIME_ERROR              = 4
        LIFETIME_DYNPRO_DYNPRO_LINK = 5
        OTHERS                      = 6.

    CREATE OBJECT GO_ALV_LEG
      EXPORTING
        I_PARENT          = GO_LEG
      EXCEPTIONS
        ERROR_CNTL_CREATE = 1
        ERROR_CNTL_INIT   = 2
        ERROR_CNTL_LINK   = 3
        ERROR_DP_CREATE   = 4
        OTHERS            = 5.

    CLEAR WA_LAYOUT1.

    WA_LAYOUT1-ZEBRA      = ABAP_TRUE. " Zebra
    WA_LAYOUT1-NO_TOOLBAR = ABAP_TRUE. " Sem a barra padrão do ALV
    WA_LAYOUT1-NO_ROWMARK = ABAP_TRUE. " Sem marcador de linhas

    CALL METHOD GO_ALV_LEG->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_LAYOUT                     = WA_LAYOUT1
      CHANGING
        IT_OUTTAB                     = IT_LEG[]
        IT_FIELDCATALOG               = IT_FCAT3[]
      EXCEPTIONS
        INVALID_PARAMETER_COMBINATION = 1
        PROGRAM_ERROR                 = 2
        TOO_MANY_LINES                = 3
        OTHERS                        = 4.

  ENDIF.

ENDMODULE.                 " STATUS_0200  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0200 INPUT.

  CASE SY-UCOMM.

    WHEN C_VOLTAR.

      LEAVE TO SCREEN 0.

    WHEN C_SAIR.

      LEAVE PROGRAM.

    WHEN C_NFCLI OR C_NFFORN.

      PERFORM F_GERA_NOTA.

    WHEN C_STAT.

      CALL SCREEN 400 STARTING AT 12 3
                      ENDING AT 40 8.

    WHEN C_UPDA.

* Monta o campo EMPRESA
      WA_SELTAB-SELNAME = 'S_BUKRS'.
      WA_SELTAB-SIGN    = S_BUKRS-SIGN.
      WA_SELTAB-OPTION  = S_BUKRS-OPTION.

      LOOP AT S_BUKRS.
        WA_SELTAB-LOW  = S_BUKRS-LOW.
        WA_SELTAB-HIGH = S_BUKRS-HIGH.
        APPEND WA_SELTAB TO IT_SELTAB.
      ENDLOOP.

* Monta o campo LOCAL DE NEGÓCIOS
      WA_SELTAB-SELNAME = 'S_BRANCH'.
      WA_SELTAB-SIGN    = S_BRANCH-SIGN.
      WA_SELTAB-OPTION  = S_BRANCH-OPTION.

      LOOP AT S_BRANCH.
        WA_SELTAB-LOW  = S_BRANCH-LOW.
        WA_SELTAB-HIGH = S_BRANCH-HIGH.
        APPEND WA_SELTAB TO IT_SELTAB.
      ENDLOOP.

* Monta o campo Nº DO DOCUMENTO
      WA_SELTAB-SELNAME = 'S_DOCNR'.
      WA_SELTAB-SIGN    = S_DOCNR-SIGN.
      WA_SELTAB-OPTION  = S_DOCNR-OPTION.

      LOOP AT S_DOCNR.
        WA_SELTAB-LOW  = S_DOCNR-LOW.
        WA_SELTAB-HIGH = S_DOCNR-HIGH.
        APPEND WA_SELTAB TO IT_SELTAB.
      ENDLOOP.

* Monta o campo Nº DA CHAVE
      WA_SELTAB-SELNAME = 'S_CHAVE'.
      WA_SELTAB-SIGN    = S_CHAVE-SIGN.
      WA_SELTAB-OPTION  = S_CHAVE-OPTION.

      LOOP AT S_CHAVE.
        WA_SELTAB-LOW  = S_CHAVE-LOW.
        WA_SELTAB-HIGH = S_CHAVE-HIGH.
        APPEND WA_SELTAB TO IT_SELTAB.
      ENDLOOP.

* Monta o campo ID PARCEIRO
      WA_SELTAB-SELNAME = 'S_PARID'.
      WA_SELTAB-SIGN    = S_PARID-SIGN.
      WA_SELTAB-OPTION  = S_PARID-OPTION.

      LOOP AT S_PARID.
        WA_SELTAB-LOW  = S_PARID-LOW.
        WA_SELTAB-HIGH = S_PARID-HIGH.
        APPEND WA_SELTAB TO IT_SELTAB.
      ENDLOOP.

* Monta o campo DATA DE LANÇAMENTO
      WA_SELTAB-SELNAME = 'S_LNCDT'.
      WA_SELTAB-SIGN    = S_LNCDT-SIGN.
      WA_SELTAB-OPTION  = S_LNCDT-OPTION.

      LOOP AT S_LNCDT.
        WA_SELTAB-LOW  = S_LNCDT-LOW.
        WA_SELTAB-HIGH = S_LNCDT-HIGH.
        APPEND WA_SELTAB TO IT_SELTAB.
      ENDLOOP.

      SUBMIT ZHMS_180_DIAS_FULL
        WITH SELECTION-TABLE IT_SELTAB.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0200  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_GERA_NOTA
*&---------------------------------------------------------------------*
FORM F_GERA_NOTA.

  DATA: L_ITMNUM TYPE I.


* Verifica quais linhas foram selecionadas
  CALL METHOD GO_ALV->CHECK_CHANGED_DATA.

  REFRESH: IT_H_BAPI,
           IT_I_BAPI,
           IT_I_BAPI_TAX,
           IT_NOTAS.

  LOOP AT IT_OUTTAB INTO WA_OUTTAB WHERE MARK EQ ABAP_TRUE.

    READ TABLE IT_CABDOC INTO WA_CABDOC WITH KEY CHAVE = WA_OUTTAB-CHAVE.

*----------------------------------------------------------------------*
* Dados de cabeçalho                                                   *
*----------------------------------------------------------------------*
    WA_H_BAPI-CHAVE = WA_OUTTAB-CHAVE.

* Categoria da nota fiscal
    WA_H_BAPI-NFTYPE = 'N1'.

* Tipo de documento (1 -> Nota fiscal)
    WA_H_BAPI-DOCTYP = '1'.

* Direção do movimento de mercadorias (2 -> Saída)
    WA_H_BAPI-DIRECT = '2'.

* Data de lançamento
    WA_H_BAPI-PSTDAT = SY-DATUM.

* Data do documento (emissão)
    WA_H_BAPI-DOCDAT = SY-DATUM.

* Empresa
    WA_H_BAPI-BUKRS = WA_CABDOC-BUKRS.

* Local de negócios
    WA_H_BAPI-BRANCH = WA_CABDOC-BRANCH.

* Nota manual
    WA_H_BAPI-MANUAL = ABAP_TRUE.

* NF-e
    WA_H_BAPI-NFE = ABAP_TRUE.

* Moeda
    WA_H_BAPI-WAERK = 'BRL'.

* Modelo (Nota fiscal - modelo 55)
    WA_H_BAPI-MODEL = '55'.

* Série
    WA_H_BAPI-SERIES = '1'.

    CASE SY-UCOMM.

      WHEN C_NFCLI.

* Tipo do parceiro (cliente)
        WA_H_BAPI-PARVW = C_AG.

* Código do parceiro
        WA_H_BAPI-PARID = WA_CABDOC-PARID.
        WA_H_BAPI-PARID = 'HOMI'.

      WHEN C_NFFORN.

* Tipo do parceiro (fornecedor)
        WA_H_BAPI-PARVW = C_LF.

* Código do parceiro
        WA_H_BAPI-PARID = '0025000083'.

    ENDCASE.

    CLEAR WA_DOCMN.

    READ TABLE IT_DOCMN INTO WA_DOCMN WITH KEY CHAVE = WA_OUTTAB-CHAVE
                                               MNEUM = 'NATOP'
                                               BINARY SEARCH.

* Observações
    WA_H_BAPI-OBSERVAT = WA_DOCMN-VALUE.

*----------------------------------------------------------------------*
* Dados de item                                                        *
*----------------------------------------------------------------------*
    WA_I_BAPI-CHAVE = WA_OUTTAB-CHAVE.

    WA_I_BAPI-DCITM = WA_OUTTAB-NF_ITM.

* Número do item
*    wa_i_bapi-itmnum = '10'.
    L_ITMNUM = L_ITMNUM + 10.
    WA_I_BAPI-ITMNUM = L_ITMNUM.

* Material e grupo de mercadoria
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = WA_OUTTAB-MATERIAL
      IMPORTING
        OUTPUT = WA_I_BAPI-MATNR.

* Utilização de material
    SELECT SINGLE MTUSE
      FROM MBEW
      INTO WA_I_BAPI-MATUSE
     WHERE MATNR EQ WA_I_BAPI-MATNR
       AND BWKEY EQ 'HOMI'.

    IF NOT SY-SUBRC IS INITIAL.

      WA_I_BAPI-MATUSE = 0.

    ENDIF.

* Centro e área de avaliação (para rodar a BAPI é necessário ter os dois)
    SELECT SINGLE BWKEY WERKS
      FROM T001W
      INTO (WA_I_BAPI-BWKEY,WA_I_BAPI-WERKS)
     WHERE J_1BBRANCH EQ WA_CABDOC-BRANCH.

* NCM
    READ TABLE IT_DOCMN INTO WA_DOCMN WITH KEY CHAVE = WA_OUTTAB-CHAVE
                                               MNEUM = 'XMLNCM'
                                               DCITM = WA_OUTTAB-NF_ITM
                                               BINARY SEARCH.

    WRITE WA_DOCMN-VALUE TO WA_I_BAPI-NBM USING EDIT MASK '____.__.__'.

* Origem de material
    WA_I_BAPI-MATORG = '0'.

* Quantidade
    WA_I_BAPI-MENGE = WA_OUTTAB-QTD_ESTOQUE.

* Unidade de medida (UN -> ST)
    WA_I_BAPI-MEINS = 'ST'.

    READ TABLE IT_DOCMN INTO WA_DOCMN WITH KEY CHAVE = WA_OUTTAB-CHAVE
                                               MNEUM = 'XPROD'
                                               DCITM = WA_OUTTAB-NF_ITM
                                               BINARY SEARCH.

* Descrição do material
    WA_I_BAPI-MAKTX = WA_DOCMN-VALUE.

* NFCI (preencher com caractere especial ALT+0160)
    WA_I_BAPI-NFCI = ' '.

* Preço
    READ TABLE IT_DOCMN INTO WA_DOCMN WITH KEY CHAVE = WA_OUTTAB-CHAVE
                                               MNEUM = 'VUNCOM'
                                               DCITM = WA_OUTTAB-NF_ITM
                                               BINARY SEARCH.

* Valor unitário
    WA_I_BAPI-NETPR = WA_DOCMN-VALUE.

* Valor líquido
    WA_I_BAPI-NETWR = WA_I_BAPI-NETPR * WA_I_BAPI-MENGE.

* Categoria do item (item normal)
    WA_I_BAPI-ITMTYP = '01'.

* CFOP
    READ TABLE IT_DOCMN INTO WA_DOCMN WITH KEY CHAVE = WA_OUTTAB-CHAVE
                                               MNEUM = 'CFOP'
                                               DCITM = WA_OUTTAB-NF_ITM
                                               BINARY SEARCH.

* Para saída -> CFOP deve iniciar com 5
    REPLACE '1' WITH '5' INTO WA_DOCMN-VALUE.

    CALL FUNCTION 'CONVERSION_EXIT_CFOBR_INPUT'
      EXPORTING
        INPUT  = WA_DOCMN-VALUE
      IMPORTING
        OUTPUT = WA_I_BAPI-CFOP_10.

* Direitos fiscais - ICMS
    CLEAR WA_DOCMN.

    READ TABLE IT_DOCMN INTO WA_DOCMN WITH KEY CHAVE = WA_OUTTAB-CHAVE
                                               MNEUM = 'CSTICMS'
                                               DCITM = WA_OUTTAB-NF_ITM
                                               BINARY SEARCH.

    SELECT SINGLE TAXLAW
      FROM J_1BATL1 AS ICMS
     INNER JOIN TVARVC AS TVARVC
        ON ICMS~TAXLAW EQ TVARVC~LOW
      INTO WA_I_BAPI-TAXLW1
     WHERE ICMS~TAXSIT EQ WA_DOCMN-VALUE
       AND TVARVC~NAME EQ 'ZHMS_J1B1N_ICMS'.

* Direitos fiscais - IPI
    CLEAR WA_DOCMN.

    READ TABLE IT_DOCMN INTO WA_DOCMN WITH KEY CHAVE = WA_OUTTAB-CHAVE
                                               MNEUM = 'CSTIPI'
                                               DCITM = WA_OUTTAB-NF_ITM
                                               BINARY SEARCH.

    SELECT SINGLE TAXLAW
      FROM J_1BATL2 AS IPI
     INNER JOIN TVARVC AS TVARVC
        ON IPI~TAXLAW EQ TVARVC~LOW
      INTO WA_I_BAPI-TAXLW2
     WHERE IPI~TAXSITOUT EQ WA_DOCMN-VALUE
       AND TVARVC~NAME EQ 'ZHMS_J1B1N_IPI'.

* Direitos fiscais - COFINS
    CLEAR WA_DOCMN.

    READ TABLE IT_DOCMN INTO WA_DOCMN WITH KEY CHAVE = WA_OUTTAB-CHAVE
                                               MNEUM = 'CSTCOFINS'
                                               DCITM = WA_OUTTAB-NF_ITM
                                               BINARY SEARCH.

    SELECT SINGLE TAXLAW
      FROM J_1BATL4A AS COFINS
     INNER JOIN TVARVC AS TVARVC
        ON COFINS~TAXLAW EQ TVARVC~LOW
      INTO WA_I_BAPI-TAXLW4
     WHERE COFINS~TAXSITOUT EQ WA_DOCMN-VALUE
       AND TVARVC~NAME EQ 'ZHMS_J1B1N_COFINS'.

* Direitos fiscais - PIS
    CLEAR WA_DOCMN.

    READ TABLE IT_DOCMN INTO WA_DOCMN WITH KEY CHAVE = WA_OUTTAB-CHAVE
                                               MNEUM = 'CSTPIS'
                                               DCITM = WA_OUTTAB-NF_ITM
                                               BINARY SEARCH.

    SELECT SINGLE TAXLAW
      FROM J_1BATL5 AS PIS
     INNER JOIN TVARVC AS TVARVC
        ON PIS~TAXLAW EQ TVARVC~LOW
      INTO WA_I_BAPI-TAXLW5
     WHERE PIS~TAXSITOUT EQ WA_DOCMN-VALUE
       AND TVARVC~NAME EQ 'ZHMS_J1B1N_PIS'.

*----------------------------------------------------------------------*
* Dados da aba de impostos (ICMS)                                                        *
*----------------------------------------------------------------------*
    WA_I_BAPI_TAX-CHAVE = WA_OUTTAB-CHAVE.

    WA_I_BAPI_TAX-DCITM = WA_OUTTAB-NF_ITM.

* Nº item
*    wa_i_bapi_tax-itmnum = '10'.              "RCP - 31/08/2018
    WA_I_BAPI_TAX-ITMNUM = WA_I_BAPI-ITMNUM.   "RCP - 31/08/2018

* Código do imposto
    CASE WA_I_BAPI-MATUSE.

      WHEN '0' OR '3'.
        WA_I_BAPI_TAX-TAXTYP = 'ICM0'.

      WHEN '1' OR '2'.
        WA_I_BAPI_TAX-TAXTYP = 'ICM1'.

    ENDCASE.

* Montante
    CLEAR WA_DOCMN.

    READ TABLE IT_DOCMN INTO WA_DOCMN WITH KEY CHAVE = WA_OUTTAB-CHAVE
                                               MNEUM = 'VPROD'
                                               DCITM = WA_OUTTAB-NF_ITM
                                               BINARY SEARCH.

    WA_I_BAPI_TAX-BASE = WA_DOCMN-VALUE.

* Outras bases
    WA_I_BAPI_TAX-OTHBAS = WA_DOCMN-VALUE.

* Taxa de imposto
    CLEAR WA_DOCMN.

    READ TABLE IT_DOCMN INTO WA_DOCMN WITH KEY CHAVE = WA_OUTTAB-CHAVE
                                               MNEUM = 'PICMS'
                                               DCITM = WA_OUTTAB-NF_ITM
                                               BINARY SEARCH.

    WA_I_BAPI_TAX-RATE = WA_DOCMN-VALUE.

    APPEND: WA_H_BAPI     TO IT_H_BAPI,
            WA_I_BAPI     TO IT_I_BAPI,
            WA_I_BAPI_TAX TO IT_I_BAPI_TAX.

    CLEAR WA_NOTAS.

    READ TABLE IT_DOCMN INTO WA_DOCMN WITH KEY CHAVE = WA_OUTTAB-CHAVE
                                               MNEUM = 'NNF'
                                               BINARY SEARCH.

    WA_NOTAS-CHAVE      = WA_OUTTAB-CHAVE.
    WA_NOTAS-DCITM      = WA_OUTTAB-NF_ITM.
    WA_NOTAS-NF_ENTRADA = WA_DOCMN-VALUE.
    WA_NOTAS-BUKRS      = WA_H_BAPI-BUKRS.
    WA_NOTAS-DOCDAT     = WA_H_BAPI-DOCDAT.
    WA_NOTAS-CLI_FORN   = WA_H_BAPI-PARID.
    WA_NOTAS-MATERIAL   = WA_I_BAPI-MATNR.
    WA_NOTAS-QTD_NF     = WA_I_BAPI-MENGE.
    WA_NOTAS-WERKS      = WA_I_BAPI-WERKS.
    WA_NOTAS-NCM        = WA_I_BAPI-NBM.
    WA_NOTAS-CFOP       = WA_I_BAPI-CFOP_10.
    WA_NOTAS-NETPR      = WA_I_BAPI-NETPR.
    WA_NOTAS-ICMS       = WA_I_BAPI_TAX-TAXTYP.
    WA_NOTAS-BASE       = WA_I_BAPI_TAX-BASE.
    WA_NOTAS-RATE       = WA_I_BAPI_TAX-RATE.

    SELECT SINGLE NAME1
      FROM LFA1
      INTO WA_NOTAS-DESCR_FORN
     WHERE LIFNR EQ WA_H_BAPI-PARID.

    APPEND WA_NOTAS TO IT_NOTAS.

    CLEAR: WA_NOTAS,
           WA_H_BAPI,
           WA_I_BAPI,
           WA_I_BAPI_TAX.

  ENDLOOP.

* Chama tela de dados que serão inseridos na NF a ser criada
  CALL SCREEN 300 STARTING AT 12 3
                  ENDING AT 180 18.

ENDFORM.                    " F_GERA_NOTA

*&---------------------------------------------------------------------*
*&      Form  F_DETALHES
*&---------------------------------------------------------------------*
FORM F_DETALHES USING P_ROW_ID
                      P_COLUMN_ID.

  READ TABLE IT_OUTTAB INTO WA_OUTTAB INDEX P_ROW_ID.

  REFRESH: RG_NF_DET,
           IT_DETALHES,
           IT_DET,
           IT_DET_CHAR.

* Seleciona as notas de saída
  SELECT CHAVE
         SEQNR
         MNEUM
         DCITM
         VALUE
    FROM ZHMS_TB_DOCMN
    INTO TABLE IT_DOC_DET
   WHERE CHAVE EQ WA_OUTTAB-CHAVE
     AND MNEUM IN (C_NFCLI,C_NFFORN,c_NNF)
     AND DCITM EQ WA_OUTTAB-NF_ITM.

  LOOP AT IT_DOC_DET INTO WA_DOCMN.

    WA_NF_DET-SIGN   = C_SIGN.
    WA_NF_DET-OPTION = C_OPTION.
    WA_NF_DET-LOW    = WA_DOCMN-VALUE.

    APPEND WA_NF_DET TO RG_NF_DET.

    CLEAR WA_NF_DET.

  ENDLOOP.

  REFRESH IT_DOCLIN.

* Seleciona os dados das notas de saída
  IF NOT RG_NF_DET IS INITIAL.

    SELECT H~DOCNUM
           H~NFENUM
           H~DOCDAT
           H~PARVW
           H~PARID
           I~MATNR
           I~MENGE
           H~NFENUM
      INTO TABLE IT_DOCLIN
      FROM J_1BNFDOC AS H
     INNER JOIN J_1BNFLIN AS I
        ON H~DOCNUM EQ I~DOCNUM
     WHERE H~DOCNUM IN RG_NF_DET.

  ENDIF.

  LOOP AT IT_DOCLIN INTO WA_DOCLIN.

    WA_DETALHES-NF_SAIDA   = WA_DOCLIN-NFENUM.
    WA_DETALHES-DOCNUM_SAI = WA_DOCLIN-DOCNUM.
    WA_DETALHES-MATERIAL   = WA_DOCLIN-MATNR.
    WA_DETALHES-QTD_NF_SAI = WA_DOCLIN-MENGE.
    WA_DETALHES-CLI_FORN   = WA_DOCLIN-PARID.

    CONCATENATE WA_DOCLIN-DOCDAT+6(2)
                WA_DOCLIN-DOCDAT+4(2)
                WA_DOCLIN-DOCDAT(4)
           INTO WA_DETALHES-DT_EMI_SAI SEPARATED BY '.'.

* Se for cliente
    IF WA_DOCLIN-PARVW EQ C_AG.

      SELECT SINGLE NAME1
        FROM KNA1
        INTO WA_DETALHES-DESCR_FORN
       WHERE KUNNR EQ WA_DOCLIN-PARID.

      WA_DETALHES-TP_NF = TEXT-C01. " Envio à cliente

      WA_DETALHES-STATUS_DIAS = C_NA.

* Se for fornecedor
    ELSEIF WA_DOCLIN-PARVW EQ C_LF.

      SELECT SINGLE NAME1
        FROM LFA1
        INTO WA_DETALHES-DESCR_FORN
       WHERE LIFNR EQ WA_DOCLIN-PARID.

      WA_DETALHES-TP_NF = TEXT-C02. " Envio à fornecedor

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = WA_DOCLIN-NFE_C
        IMPORTING
          OUTPUT = WA_DOCLIN-NFE_C.

* Seleciona nota de escrituração (se houver)
      SELECT SINGLE CHAVE
                    SEQNR
                    MNEUM
                    DCITM
                    VALUE
        FROM ZHMS_TB_DOCMN
        INTO WA_DOCMN
       WHERE MNEUM EQ 'REFERENCE'
         AND VALUE EQ WA_DOCLIN-NFE_C.

      IF SY-SUBRC IS INITIAL.

        SELECT SINGLE VALUE
          FROM ZHMS_TB_DOCMN
          INTO WA_DETALHES-NF_ESCR_DEV
         WHERE CHAVE EQ WA_DOCMN-CHAVE
           AND MNEUM EQ 'NNF'.

* Quantidade devolvida pelo fornecedor
        WA_DETALHES-QTD_DEV_FORN = WA_DETALHES-QTD_NF_SAI.

        SELECT SINGLE VALUE
          FROM ZHMS_TB_DOCMN
          INTO WA_DETALHES-DOC_ESCR_DEV
         WHERE CHAVE EQ WA_DOCMN-CHAVE
           AND MNEUM EQ 'MATDOC'.

      ENDIF.

* Verifica quantidade devolvida e calcula dias
      IF WA_DETALHES-QTD_DEV_FORN LT WA_DETALHES-QTD_NF_SAI.

        WA_DETALHES-DIAS_FORN = SY-DATUM - WA_DOCLIN-DOCDAT.

      ELSE.

        WA_DETALHES-DIAS_FORN = 0.

      ENDIF.

* Atualiza status
      IF WA_DETALHES-DIAS_FORN LE 100.

        WA_DETALHES-STATUS_DIAS = C_100.

      ELSEIF WA_DETALHES-DIAS_FORN GT 100 AND WA_DETALHES-DIAS_FORN LE 180.

        WA_DETALHES-STATUS_DIAS = C_100_180.

      ELSEIF WA_DETALHES-DIAS_FORN GT 180.

        WA_DETALHES-STATUS_DIAS = C_180.

      ENDIF.

    ENDIF.

    APPEND WA_DETALHES TO IT_DETALHES.

* ALV tree -> se os valores não forem CHAR, fica com "sujeira" na linha da pasta
    MOVE-CORRESPONDING WA_DETALHES TO WA_DET_CHAR.

    SHIFT: WA_DET_CHAR-NF_SAIDA     LEFT DELETING LEADING C_ZERO,
           WA_DET_CHAR-DOCNUM_SAI   LEFT DELETING LEADING C_ZERO,
           WA_DET_CHAR-NF_ESCR_DEV  LEFT DELETING LEADING C_ZERO,
           WA_DET_CHAR-DOC_ESCR_DEV LEFT DELETING LEADING C_ZERO,
           WA_DET_CHAR-MATERIAL     LEFT DELETING LEADING C_ZERO.

    APPEND WA_DET_CHAR TO IT_DET_CHAR.

    CLEAR WA_DETALHES.

  ENDLOOP.

* Instancia o objeto apenas uma vez
  IF GO_CONT_TREE IS INITIAL.

    CREATE OBJECT GO_CONT_TREE
      EXPORTING
        CONTAINER_NAME              = 'ALVDETALHE'
      EXCEPTIONS
        CNTL_ERROR                  = 1
        CNTL_SYSTEM_ERROR           = 2
        CREATE_ERROR                = 3
        LIFETIME_ERROR              = 4
        LIFETIME_DYNPRO_DYNPRO_LINK = 5.

    CREATE OBJECT GO_TREE
      EXPORTING
        PARENT                      = GO_CONT_TREE
        NODE_SELECTION_MODE         = CL_GUI_COLUMN_TREE=>NODE_SEL_MODE_SINGLE
        ITEM_SELECTION              = ABAP_TRUE
        NO_HTML_HEADER              = ABAP_TRUE
        NO_TOOLBAR                  = ABAP_TRUE
      EXCEPTIONS
        CNTL_ERROR                  = 1
        CNTL_SYSTEM_ERROR           = 2
        CREATE_ERROR                = 3
        LIFETIME_ERROR              = 4
        ILLEGAL_NODE_SELECTION_MODE = 5
        FAILED                      = 6
        ILLEGAL_COLUMN_NAME         = 7.

* Define o label do primeiro campo do tree
    PERFORM F_HEADER_TREE CHANGING GV_HEADER_TREE.

* Monta catálogo de campos da área de detalhes
    PERFORM F_FCAT_DET USING:
            'DOCNUM_SAI'     TEXT-G01   SPACE       16    ABAP_TRUE,
            'NF_ESCR_DEV'    TEXT-G02   SPACE       20    SPACE,
            'DOC_ESCR_DEV'   TEXT-G03   SPACE       20    SPACE,
            'DT_EMI_SAI'     TEXT-G04   SPACE       22    SPACE,
            'MATERIAL'       TEXT-G05   SPACE       16    SPACE,
            'QTD_NF_SAI'     TEXT-G06   SPACE       20    SPACE,
            'CLI_FORN'       TEXT-G07   SPACE       24    SPACE,
            'DESCR_FORN'     TEXT-G08   SPACE       44    SPACE,
            'QTD_DEV_FORN'   TEXT-G09   SPACE       20    SPACE,
            'DIAS_FORN'      TEXT-G10   SPACE       18    SPACE,
            'STATUS_DIAS'    TEXT-G11   ABAP_TRUE   15    SPACE.

* Cria tree -> tabela de dados deve ser passada vazia!
    CALL METHOD GO_TREE->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_HIERARCHY_HEADER = GV_HEADER_TREE
      CHANGING
        IT_OUTTAB           = IT_DET
        IT_FIELDCATALOG     = IT_FCAT2.

* Busca os eventos disponíveis para ALV
    CALL METHOD GO_TREE->GET_REGISTERED_EVENTS
      IMPORTING
        EVENTS = IT_EVT
      EXCEPTIONS
        OTHERS = 0.

* Insere o evento de "hotspot" (link click)
    WA_EVT-EVENTID = CL_GUI_COLUMN_TREE=>EVENTID_LINK_CLICK.
    APPEND WA_EVT TO IT_EVT.

* Registra o evento "hotspot" (link click)
    CALL METHOD GO_TREE->SET_REGISTERED_EVENTS
      EXPORTING
        EVENTS = IT_EVT
      EXCEPTIONS
        OTHERS = 0.

* Instancia o objeto para chamar a J1B3N
    CREATE OBJECT GO_EVENT_TREE.

* Chama o método para o clique no DOCNUM da NF
    SET HANDLER GO_EVENT_TREE->LINK_CLICK FOR GO_TREE.

  ELSE.

* Reinicia os nós para nova hierarquia
    CALL METHOD GO_TREE->DELETE_ALL_NODES.

  ENDIF.

* Cria os nós (pastas)
  PERFORM F_CRIA_NOS.

* Envia os dados da tabela interna para o tree
  CALL METHOD GO_TREE->FRONTEND_UPDATE.

ENDFORM.                    " F_DETALHES

*&---------------------------------------------------------------------*
*&      Form  F_FCAT_DET
*&---------------------------------------------------------------------*
FORM F_FCAT_DET USING P_NOME
                      P_TEXTO
                      P_ICON
                      P_LEN
                      P_HOTSPOT.

  CLEAR WA_FCAT2.

  WA_FCAT2-FIELDNAME  = P_NOME.
  WA_FCAT2-COLDDICTXT = 'L'.
  WA_FCAT2-SCRTEXT_L  = P_TEXTO.
  WA_FCAT2-OUTPUTLEN  = P_LEN.
  WA_FCAT2-ICON       = P_ICON.
  WA_FCAT2-HOTSPOT    = P_HOTSPOT.

  APPEND WA_FCAT2 TO IT_FCAT2.

ENDFORM.                    " F_FCAT_DET

*&---------------------------------------------------------------------*
*       Form  F_HEADER_TREE
*&---------------------------------------------------------------------*
FORM F_HEADER_TREE CHANGING P_HIERARCHY_HEADER TYPE TREEV_HHDR.

  P_HIERARCHY_HEADER-HEADING = TEXT-T01.
  P_HIERARCHY_HEADER-TOOLTIP = TEXT-T01.
  P_HIERARCHY_HEADER-WIDTH   = 30.

ENDFORM.                    " F_HEADER_TREE

*&---------------------------------------------------------------------*
*&      Form  F_CRIA_NOS
*&---------------------------------------------------------------------*
FORM F_CRIA_NOS.

  DATA: LV_NO_ATUAL    TYPE LVC_NKEY,
        LV_NO_SUPERIOR TYPE LVC_NKEY,
        LV_NO_TEXTO    TYPE LVC_VALUE.

  SORT IT_DET_CHAR BY TP_NF.

  CLEAR GV_TP_NF.

  LOOP AT IT_DET_CHAR INTO WA_DET_CHAR.

* Se o tipo da NF for diferente -> cria outro nó
    IF WA_DET_CHAR-TP_NF NE GV_TP_NF.

      CLEAR: LV_NO_SUPERIOR,
             WA_DET.

* Texto do nó (pasta)
      LV_NO_TEXTO = WA_DET_CHAR-TP_NF.

      CALL METHOD GO_TREE->ADD_NODE
        EXPORTING
          I_RELAT_NODE_KEY = LV_NO_SUPERIOR
          I_RELATIONSHIP   = CL_GUI_COLUMN_TREE=>RELAT_LAST_CHILD
          IS_OUTTAB_LINE   = WA_DET
          I_NODE_TEXT      = LV_NO_TEXTO
        IMPORTING
          E_NEW_NODE_KEY   = LV_NO_ATUAL.

      LV_NO_SUPERIOR = LV_NO_ATUAL.

    ENDIF.

    WA_DET = WA_DET_CHAR.

* Texto do nó (pasta)
    LV_NO_TEXTO = WA_DET_CHAR-NF_SAIDA.

    CALL METHOD GO_TREE->ADD_NODE
      EXPORTING
        I_RELAT_NODE_KEY = LV_NO_SUPERIOR
        I_RELATIONSHIP   = CL_GUI_COLUMN_TREE=>RELAT_LAST_CHILD
        IS_OUTTAB_LINE   = WA_DET
        I_NODE_TEXT      = LV_NO_TEXTO
      IMPORTING
        E_NEW_NODE_KEY   = LV_NO_ATUAL.

    GV_TP_NF = WA_DET_CHAR-TP_NF.

  ENDLOOP.

ENDFORM.                    " F_CRIA_NOS

*&---------------------------------------------------------------------*
*&      Form  F_MONTA_FCAT3
*&---------------------------------------------------------------------*
FORM F_MONTA_FCAT3 USING P_NOME
                         P_TEXTO
                         P_LEN.

  CLEAR WA_FCAT3.

  WA_FCAT3-FIELDNAME = P_NOME.
  WA_FCAT3-REPTEXT   = P_TEXTO.
  WA_FCAT3-OUTPUTLEN = P_LEN.

  APPEND WA_FCAT3 TO IT_FCAT3.

ENDFORM.                    " F_MONTA_FCAT3

*&---------------------------------------------------------------------*
*&      Form  F_MONTA_LEGENDA
*&---------------------------------------------------------------------*
FORM F_MONTA_LEGENDA  USING  P_ICONE
                             P_DESCR.

  CLEAR WA_LEG.

  WA_LEG-ICONE = P_ICONE.
  WA_LEG-DESCR = P_DESCR.

  APPEND WA_LEG TO IT_LEG.

ENDFORM.                    " F_MONTA_LEGENDA

*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0300 OUTPUT.

  SET PF-STATUS 'STATUS_300' EXCLUDING IT_FCODE.
  SET TITLEBAR 'TITLE_300'.

  CREATE OBJECT GO_NOTAS
    EXPORTING
      CONTAINER_NAME              = 'ALVNOTAS'
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5
      OTHERS                      = 6.

  IF GO_ALV_NOTAS IS INITIAL.

    CREATE OBJECT GO_ALV_NOTAS
      EXPORTING
        I_PARENT          = GO_NOTAS
      EXCEPTIONS
        ERROR_CNTL_CREATE = 1
        ERROR_CNTL_INIT   = 2
        ERROR_CNTL_LINK   = 3
        ERROR_DP_CREATE   = 4
        OTHERS            = 5.

  ENDIF.

* Reinicia a tabela para cada nova seleção de NFs
  REFRESH IT_FCAT4.

  PERFORM F_MONTA_FCAT4 USING:
                  'NF'           TEXT-N01   SPACE,
                  'NF_ENTRADA'   TEXT-N02   SPACE,
                  'DCITM'        TEXT-N03   SPACE,
                  'BUKRS'        TEXT-N04   SPACE,
                  'DOCDAT'       TEXT-N05   SPACE,
                  'CLI_FORN'     TEXT-N06   SPACE,
                  'DESCR_FORN'   TEXT-N07   SPACE,
                  'MATERIAL'     TEXT-N08   SPACE,
                  'QTD_NF'       TEXT-N09   ABAP_TRUE,
                  'WERKS'        TEXT-N10   SPACE,
                  'NCM'          TEXT-N11   SPACE,
                  'CFOP'         TEXT-N12   SPACE,
                  'NETPR'        TEXT-N13   SPACE,
                  'ICMS'         TEXT-N14   SPACE,
                  'BASE'         TEXT-N15   SPACE,
                  'RATE'         TEXT-N16   SPACE,
                  'MENSAGEM'     TEXT-N17   SPACE.

  WA_LAYOUT4-CWIDTH_OPT = ABAP_TRUE.     " Otimizar colunas
  WA_LAYOUT4-ZEBRA      = ABAP_TRUE.     " Zebra
  WA_LAYOUT4-NO_TOOLBAR = ABAP_TRUE.     " Sem a barra padrão do ALV
  WA_LAYOUT4-NO_ROWMARK = ABAP_TRUE.     " Sem marcador de linhas
  WA_LAYOUT4-CTAB_FNAME = 'CELLCOLOR'.   " Esquema de cores
  WA_LAYOUT4-STYLEFNAME = 'FIELD_STYLE'. " Campo que receberá estilo

  CALL METHOD GO_ALV_NOTAS->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT                     = WA_LAYOUT4
    CHANGING
      IT_OUTTAB                     = IT_NOTAS[]
      IT_FIELDCATALOG               = IT_FCAT4[]
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1
      PROGRAM_ERROR                 = 2
      TOO_MANY_LINES                = 3
      OTHERS                        = 4.

ENDMODULE.                 " STATUS_0300  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_MONTA_FCAT4
*&---------------------------------------------------------------------*
FORM F_MONTA_FCAT4  USING  P_NOME
                           P_TEXTO
                           P_EDIT.

  CLEAR WA_FCAT4.

  WA_FCAT4-FIELDNAME = P_NOME.
  WA_FCAT4-REPTEXT   = P_TEXTO.
  WA_FCAT4-EDIT      = P_EDIT.
  WA_FCAT4-COL_OPT   = ABAP_TRUE.

  APPEND WA_FCAT4 TO IT_FCAT4.

ENDFORM.                    " F_MONTA_FCAT4

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0300 INPUT.

  REFRESH IT_FCODE.

  CASE SY-UCOMM.

    WHEN C_OK.

      PERFORM F_GERA_NOTAS.

    WHEN C_CANC.

      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0300  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_GERA_NOTAS
*&---------------------------------------------------------------------*
FORM F_GERA_NOTAS .

  DATA: LV_NF_ITM TYPE CHAR10.



  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-Q01
      TEXT_QUESTION         = TEXT-Q02
      TEXT_BUTTON_1         = TEXT-B01
      ICON_BUTTON_1         = 'ICON_CHECKED'
      TEXT_BUTTON_2         = TEXT-B02
      ICON_BUTTON_2         = 'ICON_INCOMPLETE'
      DEFAULT_BUTTON        = '1'
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = GV_RESP
    EXCEPTIONS
      TEXT_NOT_FOUND        = 1
      OTHERS                = 2.

  IF GV_RESP EQ '1'.

* Envia para tabela auxiliar
    IT_NOTAS_AUX[] = IT_NOTAS[].

    CALL METHOD GO_ALV_NOTAS->CHECK_CHANGED_DATA.

    CLEAR WA_HEADER.

    REFRESH: IT_ITEM, IT_ITEM_TAX.

    LOOP AT IT_NOTAS INTO WA_NOTAS.

      GV_TABIX = SY-TABIX.

      READ TABLE IT_NOTAS_AUX INTO WA_NOTAS_AUX INDEX GV_TABIX.

      IF WA_NOTAS-QTD_NF GT WA_NOTAS_AUX-QTD_NF OR WA_NOTAS-QTD_NF IS INITIAL.

        CLEAR WA_NOTAS-NF.

* Cor vermelho no campo do número da nota
        WA_COLOR-COLOR-COL = 6.
        WA_COLOR-COLOR-INT = 1.
        WA_COLOR-COLOR-INV = 0.
        WA_COLOR-FNAME     = C_NF.

        INSERT WA_COLOR INTO TABLE WA_NOTAS-CELLCOLOR.

        WA_STYLEROW-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

        APPEND WA_STYLEROW TO WA_NOTAS-FIELD_STYLE.

        WA_NOTAS-MENSAGEM = TEXT-V01. " Quantidade não permitida

        MODIFY IT_NOTAS FROM WA_NOTAS INDEX GV_TABIX.

        CONTINUE.

      ENDIF.

      READ TABLE IT_H_BAPI INTO WA_H_BAPI WITH KEY CHAVE = WA_NOTAS-CHAVE.

      MOVE-CORRESPONDING WA_H_BAPI TO WA_HEADER.

      LOOP AT IT_I_BAPI INTO WA_I_BAPI WHERE CHAVE EQ WA_NOTAS-CHAVE
                                         AND DCITM EQ WA_NOTAS-DCITM.

        MOVE-CORRESPONDING WA_I_BAPI TO WA_ITEM.

        WA_ITEM-MENGE = WA_NOTAS-QTD_NF.

        APPEND WA_ITEM TO IT_ITEM.

      ENDLOOP.

      LOOP AT IT_I_BAPI_TAX INTO WA_I_BAPI_TAX WHERE CHAVE EQ WA_NOTAS-CHAVE
                                                 AND DCITM EQ WA_NOTAS-DCITM.

        MOVE-CORRESPONDING WA_I_BAPI_TAX TO WA_ITEM_TAX.

        APPEND WA_ITEM_TAX TO IT_ITEM_TAX.

      ENDLOOP.

    ENDLOOP.   "RCP - 31/08/2018

* Cria a nota fiscal
    CALL FUNCTION 'BAPI_J_1B_NF_CREATEFROMDATA'
      EXPORTING
        OBJ_HEADER   = WA_HEADER
      IMPORTING
        E_DOCNUM     = GV_DOCNUM
      TABLES
        OBJ_ITEM     = IT_ITEM
        OBJ_ITEM_TAX = IT_ITEM_TAX
        RETURN       = IT_RETURN.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

    IF NOT GV_DOCNUM IS INITIAL.

      LOOP AT IT_OUTTAB INTO WA_OUTTAB WHERE MARK EQ ABAP_TRUE.  "RCP - 31/08/2018

        REFRESH: IT_SEQNR.   "RCP - 31/08/2018
        SELECT SEQNR
          FROM ZHMS_TB_DOCMN
          INTO TABLE IT_SEQNR
         WHERE CHAVE EQ WA_OUTTAB-CHAVE.

        LOOP AT IT_SEQNR INTO WA_SEQNR.

          CONDENSE WA_SEQNR-SEQNR NO-GAPS.

          GV_TIMES = STRLEN( WA_SEQNR-SEQNR ).

          GV_TIMES = 5 - GV_TIMES.

          DO GV_TIMES TIMES.

            CONCATENATE '0' WA_SEQNR-SEQNR INTO WA_SEQNR-SEQNR.

          ENDDO.

          MODIFY IT_SEQNR FROM WA_SEQNR INDEX SY-TABIX.

        ENDLOOP.

        SORT IT_SEQNR DESCENDING.

        READ TABLE IT_SEQNR INTO WA_SEQNR INDEX 1.

        GV_SEQNR = WA_SEQNR-SEQNR + 1.

        ZHMS_TB_DOCMN-CHAVE = WA_OUTTAB-CHAVE.
        ZHMS_TB_DOCMN-SEQNR = GV_SEQNR.


        CLEAR LV_NF_ITM.
        CASE WA_HEADER-PARVW.

* Cliente (atualiza quantidade pendente e quantidade devolvida)
          WHEN C_AG.
            UNPACK WA_OUTTAB-MATERIAL TO WA_OUTTAB-MATERIAL.

            LV_NF_ITM = WA_OUTTAB-NF_ITM.
            WA_OUTTAB-NF_ITM = WA_OUTTAB-NF_ITM * 10.
            READ TABLE IT_ITEM INTO WA_ITEM
                               WITH KEY ITMNUM = WA_OUTTAB-NF_ITM
                                        MATNR = WA_OUTTAB-MATERIAL.  "RCP - 31/08/2018
            IF SY-SUBRC IS INITIAL.  "RCP - 31/08/2018
              ZHMS_TB_DOCMN-MNEUM = C_NFCLI.
              WA_OUTTAB-QTD_PEND = WA_OUTTAB-QTD_PEND - WA_ITEM-MENGE.
              WA_OUTTAB-QTD_DEV  = WA_OUTTAB-QTD_DEV  + WA_ITEM-MENGE.
            ENDIF.    "RCP - 31/08/2018
            PACK WA_OUTTAB-MATERIAL TO WA_OUTTAB-MATERIAL.
            CONDENSE WA_OUTTAB-MATERIAL.
            WA_OUTTAB-NF_ITM = LV_NF_ITM.

* Fornecedor (atualiza quantidade com fornecedor)
          WHEN C_LF.
            UNPACK WA_OUTTAB-MATERIAL TO WA_OUTTAB-MATERIAL.
            LV_NF_ITM = WA_OUTTAB-NF_ITM.
            WA_OUTTAB-NF_ITM = WA_OUTTAB-NF_ITM * 10.
            READ TABLE IT_ITEM INTO WA_ITEM
                               WITH KEY ITMNUM = WA_OUTTAB-NF_ITM
                                        MATNR = WA_OUTTAB-MATERIAL.  "RCP - 31/08/2018
            IF SY-SUBRC IS INITIAL.  "RCP - 31/08/2018
              ZHMS_TB_DOCMN-MNEUM = C_NFFORN.
              WA_OUTTAB-QTD_FORN  = WA_OUTTAB-QTD_FORN + WA_ITEM-MENGE.
            ENDIF.    "RCP - 31/08/2018
            PACK WA_OUTTAB-MATERIAL TO WA_OUTTAB-MATERIAL.
            CONDENSE WA_OUTTAB-MATERIAL.
            WA_OUTTAB-NF_ITM = LV_NF_ITM.

        ENDCASE.

        ZHMS_TB_DOCMN-DCITM = WA_OUTTAB-NF_ITM.

* Docnum da nota gerada
        ZHMS_TB_DOCMN-VALUE = GV_DOCNUM.

* Atualiza quantidade em "estoque"
        WA_OUTTAB-QTD_ESTOQUE = WA_OUTTAB-QTD_PEND - WA_OUTTAB-QTD_FORN.

* Atualiza DOCMN com a nota gerada
        INSERT ZHMS_TB_DOCMN FROM ZHMS_TB_DOCMN.

        COMMIT WORK.

* Se a quantidade em estoque for totalmente consumida -> fecha o checkbox
        IF WA_OUTTAB-QTD_ESTOQUE IS INITIAL.

          CLEAR WA_OUTTAB-MARK.

          WA_STYLEROW-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

          APPEND WA_STYLEROW TO WA_OUTTAB-FIELD_STYLE.

        ENDIF.

* Se não há nenhuma quantidade pendente -> nota integralmente devolvida
        IF WA_OUTTAB-QTD_PEND IS INITIAL.

          WA_OUTTAB-DIAS   = 0.

          WA_OUTTAB-STATUS = C_DEVOL.

        ENDIF.

        READ TABLE IT_OUTTAB WITH KEY NF_CLI = WA_OUTTAB-NF_CLI
                                      NF_ITM = WA_OUTTAB-NF_ITM
                                      TRANSPORTING NO FIELDS.

        MODIFY IT_OUTTAB FROM WA_OUTTAB INDEX SY-TABIX.

*      ENDIF.  "RCP - 31/08/2018

*        LOOP AT it_notas INTO wa_notas.  "RCP - 31/08/2018
*          gv_tabix = sy-tabix.
*
*          wa_notas-nf = gv_docnum.
*
** Cor verde no campo do número da nota
*          wa_color-color-col = 5.
*          wa_color-color-int = 1.
*          wa_color-color-inv = 0.
*          wa_color-fname     = c_nf.
*
*          INSERT wa_color INTO TABLE wa_notas-cellcolor.
*
** Fecha o campo de quantidade para edição
*          wa_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
*
*          APPEND wa_stylerow TO wa_notas-field_style.
*
*          wa_notas-mensagem = text-v02. " Documento criado com sucesso
*
*          MODIFY it_notas FROM wa_notas INDEX gv_tabix.
*
*        ENDLOOP.  "RCP - 31/08/2018

      ENDLOOP.  "RCP - 31/08/2018

      LOOP AT IT_NOTAS INTO WA_NOTAS.  "RCP - 31/08/2018
        GV_TABIX = SY-TABIX.

        WA_NOTAS-NF = GV_DOCNUM.

* Cor verde no campo do número da nota
        WA_COLOR-COLOR-COL = 5.
        WA_COLOR-COLOR-INT = 1.
        WA_COLOR-COLOR-INV = 0.
        WA_COLOR-FNAME     = C_NF.

        INSERT WA_COLOR INTO TABLE WA_NOTAS-CELLCOLOR.

* Fecha o campo de quantidade para edição
        WA_STYLEROW-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

        APPEND WA_STYLEROW TO WA_NOTAS-FIELD_STYLE.

        WA_NOTAS-MENSAGEM = TEXT-V02. " Documento criado com sucesso

        MODIFY IT_NOTAS FROM WA_NOTAS INDEX GV_TABIX.

      ENDLOOP.  "RCP - 31/08/2018

    ENDIF.  "RCP - 31/08/2018

* Atualiza o tree de detalhes
    CALL METHOD GO_ALV_NOTAS->REFRESH_TABLE_DISPLAY.

* Atualiza a parte de cima do cockpit
    CALL METHOD GO_ALV->REFRESH_TABLE_DISPLAY.

* Desabilita o botão de gerar notas no "popup"
    APPEND C_OK TO IT_FCODE.

  ENDIF.

ENDFORM.                    " F_GERA_NOTAS

*&-------------------------------------------------------------------
*& Form f_carrega_imagem
*&-------------------------------------------------------------------
FORM F_CARREGA_IMAGEM.

  DATA: LV_REPID LIKE SY-REPID.

  LV_REPID = SY-REPID.

  CREATE OBJECT GO_FIG
    EXPORTING
      PARENT = GO_CONT_FIG.

  CHECK SY-SUBRC IS INITIAL.

* Adiciona borda
  CALL METHOD GO_FIG->SET_3D_BORDER
    EXPORTING
      BORDER = 5.

* Modo de exibição -> stretch (esticado)
  CALL METHOD GO_FIG->SET_DISPLAY_MODE
    EXPORTING
      DISPLAY_MODE = CL_GUI_PICTURE=>DISPLAY_MODE_STRETCH.

* Define o tamanho da imagem de acordo com as cordenadas de linha/coluna
  CALL METHOD GO_FIG->SET_POSITION
    EXPORTING
      HEIGHT = 197
      LEFT   = 1
      TOP    = 63
      WIDTH  = 948.

  IF GV_URL IS INITIAL.

    REFRESH IT_QUERY.

    IT_QUERY-NAME  = '_OBJECT_ID'.

* Nome da figura carregada na transação SMW0
    IT_QUERY-VALUE = 'ZLOGO3'.

    APPEND IT_QUERY.

    CALL FUNCTION 'WWW_GET_MIME_OBJECT'
      TABLES
        QUERY_STRING        = IT_QUERY
        HTML                = IT_HTML
        MIME                = IT_FIG_DATA
      CHANGING
        RETURN_CODE         = GV_RETURN
        CONTENT_TYPE        = GV_CONTENT
        CONTENT_LENGTH      = GV_CONT_LEN
      EXCEPTIONS
        OBJECT_NOT_FOUND    = 1
        PARAMETER_NOT_FOUND = 2
        OTHERS              = 3.

* Gera um endereço URL
    CALL FUNCTION 'DP_CREATE_URL'
      EXPORTING
        TYPE     = 'image'
        SUBTYPE  = CNDP_SAP_TAB_UNKNOWN
        SIZE     = GV_FIG_LEN
        LIFETIME = CNDP_LIFETIME_TRANSACTION
      TABLES
        DATA     = IT_FIG_DATA
      CHANGING
        URL      = GV_URL
      EXCEPTIONS
        OTHERS   = 1.

  ENDIF.

* Exibe a figura pela URL gerada
  CALL METHOD GO_FIG->LOAD_PICTURE_FROM_URL
    EXPORTING
      URL = GV_URL.

ENDFORM.                    "f_carrega_imagem

*&---------------------------------------------------------------------*
*&      Form  F_MONTA_HEADER
*&---------------------------------------------------------------------*
FORM F_MONTA_HEADER .

  SELECT *
    FROM ZHMS_TB_CABDOC
    INTO TABLE IT_CABDOC
   WHERE BUKRS IN S_BUKRS
     AND BRANCH IN S_BRANCH
     AND DOCNR IN S_DOCNR
     AND CHAVE IN S_CHAVE
     AND PARID IN S_PARID
     AND LNCDT IN S_LNCDT.

  IF SY-SUBRC IS INITIAL.

    SELECT CHAVE
           SEQNR
           MNEUM
           DCITM
           VALUE
      FROM ZHMS_TB_DOCMN
      INTO TABLE IT_DOCMN
       FOR ALL ENTRIES IN IT_CABDOC
     WHERE CHAVE EQ IT_CABDOC-CHAVE.

* Seleciona somente CFOP 1949/AA
    SELECT CHAVE
      FROM ZHMS_TB_DOCMN
      INTO TABLE IT_CHAVE
     WHERE MNEUM EQ 'CFOP'
       AND VALUE EQ '1949/AA'.

    LOOP AT IT_CHAVE INTO WA_CHAVE.

      WA_FILTRO-SIGN   = C_SIGN.
      WA_FILTRO-OPTION = C_OPTION.
      WA_FILTRO-LOW    = WA_CHAVE-CHAVE.

      APPEND WA_FILTRO TO RG_FILTRO.

    ENDLOOP.

    DELETE IT_DOCMN WHERE CHAVE NOT IN RG_FILTRO.

  ENDIF.

  LOOP AT IT_DOCMN INTO WA_DOCMN.

    WA_ITENS-CHAVE = WA_DOCMN-CHAVE.
    WA_ITENS-DCITM = WA_DOCMN-DCITM.

    APPEND WA_ITENS TO IT_ITENS.

  ENDLOOP.

  SORT IT_ITENS.

  DELETE ADJACENT DUPLICATES FROM IT_ITENS COMPARING ALL FIELDS.

  DELETE IT_ITENS WHERE DCITM EQ '000000'.

  SORT IT_DOCMN BY CHAVE MNEUM DCITM.

  LOOP AT IT_ITENS INTO WA_ITENS.

* Empresa
    READ TABLE IT_CABDOC INTO WA_CABDOC WITH KEY CHAVE = WA_ITENS-CHAVE.

    WA_OUTTAB-BUKRS = WA_CABDOC-BUKRS.

    WA_OUTTAB-CHAVE = WA_ITENS-CHAVE.

    CLEAR WA_DOCMN.

    READ TABLE IT_DOCMN INTO WA_DOCMN WITH KEY CHAVE = WA_ITENS-CHAVE
                                               MNEUM = 'NNF'
                                               BINARY SEARCH.

* Nota do cliente
    WA_OUTTAB-NF_CLI = WA_DOCMN-VALUE.

    CLEAR WA_DOCMN.

    READ TABLE IT_DOCMN INTO WA_DOCMN WITH KEY CHAVE = WA_ITENS-CHAVE
                                               MNEUM = 'DHEMI'
                                               BINARY SEARCH.

* Data de emissão
    CONCATENATE WA_DOCMN-VALUE(4) WA_DOCMN-VALUE+5(2) WA_DOCMN-VALUE+8(2)
           INTO WA_OUTTAB-DT_EMI.

    CLEAR WA_DOCMN.

    READ TABLE IT_DOCMN INTO WA_DOCMN WITH KEY CHAVE = WA_ITENS-CHAVE
                                               MNEUM = 'MATDOC'
                                               BINARY SEARCH.

    IF SY-SUBRC IS INITIAL.

* Nota escriturada
      WA_OUTTAB-ST_ESCR = C_ESC.
      WA_OUTTAB-NF_ESCR = WA_DOCMN-VALUE.

    ELSE.

* Nota não escriturada
      WA_OUTTAB-ST_ESCR = C_N_ESC.

    ENDIF.

    WA_OUTTAB-NF_ITM = WA_ITENS-DCITM.

    CLEAR WA_DOCMN.

    READ TABLE IT_DOCMN INTO WA_DOCMN WITH KEY CHAVE = WA_ITENS-CHAVE
                                               MNEUM = 'CPROD'
                                               DCITM = WA_ITENS-DCITM
                                               BINARY SEARCH.

* Material
    WA_OUTTAB-MATERIAL = WA_DOCMN-VALUE.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = WA_DOCMN-VALUE
      IMPORTING
        OUTPUT = GV_MATNR.

* Descrição
    SELECT SINGLE MAKTX
      FROM MAKT
      INTO WA_OUTTAB-DESCRICAO
     WHERE MATNR EQ GV_MATNR.

    CLEAR WA_DOCMN.

    READ TABLE IT_DOCMN INTO WA_DOCMN WITH KEY CHAVE = WA_ITENS-CHAVE
                                               MNEUM = 'QCOM'
                                               DCITM = WA_ITENS-DCITM
                                               BINARY SEARCH.

* Quantidade da NF
    WA_OUTTAB-QTD_NF = WA_DOCMN-VALUE.

* Seleciona todas as notas enviadas para cliente ou fornecedor (saída)
    SELECT CHAVE
           SEQNR
           MNEUM
           DCITM
           VALUE
      FROM ZHMS_TB_DOCMN
      INTO TABLE IT_DOC_DET
     WHERE CHAVE EQ WA_ITENS-CHAVE
       AND MNEUM IN (C_NFCLI,C_NFFORN)
       AND DCITM EQ WA_ITENS-DCITM.

    REFRESH RG_NF_DET.

    LOOP AT IT_DOC_DET INTO WA_DOCMN.

      WA_NF_DET-SIGN   = C_SIGN.
      WA_NF_DET-OPTION = C_OPTION.
      WA_NF_DET-LOW    = WA_DOCMN-VALUE.

      APPEND WA_NF_DET TO RG_NF_DET.

      CLEAR WA_NF_DET.

    ENDLOOP.

    REFRESH IT_DOCLIN.

    IF NOT RG_NF_DET[] IS INITIAL.

* Seleciona dados das notas de saída
      SELECT H~DOCNUM
             H~NFENUM
             H~DOCDAT
             H~PARVW
             H~PARID
             I~MATNR
             I~MENGE
             H~NFENUM
        INTO TABLE IT_DOCLIN
        FROM J_1BNFDOC AS H
       INNER JOIN J_1BNFLIN AS I
          ON H~DOCNUM EQ I~DOCNUM
       WHERE H~DOCNUM IN RG_NF_DET.

    ENDIF.

* Inicia a quantidade total da nota
    GV_MENGE = WA_OUTTAB-QTD_NF.

    CLEAR GV_FORN.

    LOOP AT IT_DOCLIN INTO WA_DOCLIN.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = WA_DOCLIN-NFE_C
        IMPORTING
          OUTPUT = WA_DOCLIN-NFE_C.

* Seleciona a nota de escrituração no caso de nota para fornecedor (entrada)
      SELECT SINGLE CHAVE
                    SEQNR
                    MNEUM
                    DCITM
                    VALUE
        FROM ZHMS_TB_DOCMN
        INTO WA_DOCMN
       WHERE MNEUM EQ 'REFERENCE'
         AND VALUE EQ WA_DOCLIN-NFE_C.

      IF SY-SUBRC IS INITIAL.

* Número da nota de escrituração
        SELECT SINGLE VALUE
          FROM ZHMS_TB_DOCMN
          INTO WA_DOCLIN-NF_ESC
         WHERE CHAVE EQ WA_DOCMN-CHAVE
           AND MNEUM EQ 'NNF'.

* Quantidade devolvida pelo fornecedor
        SELECT SINGLE VALUE
          FROM ZHMS_TB_DOCMN
          INTO WA_DOCLIN-MENGE_ESC
         WHERE CHAVE EQ WA_DOCMN-CHAVE
           AND MNEUM EQ 'QCOM'.

* Docnum da nota de escrituração
        SELECT SINGLE VALUE
          FROM ZHMS_TB_DOCMN
          INTO WA_DOCLIN-DOC_ESC
         WHERE CHAVE EQ WA_DOCMN-CHAVE
           AND MNEUM EQ 'MATDOC'.

      ENDIF.

* Caso seja cliente -> subtrai do total
      IF WA_DOCLIN-PARVW EQ C_AG.

        GV_MENGE = GV_MENGE - WA_DOCLIN-MENGE.

* Caso seja fornecedor -> acumula a quantidade e subtrai o que foi devolvido
      ELSEIF WA_DOCLIN-PARVW EQ C_LF.

        GV_FORN = GV_FORN + WA_DOCLIN-MENGE - WA_DOCLIN-MENGE_ESC.

      ENDIF.

    ENDLOOP.

* Quantidade pendente
    WA_OUTTAB-QTD_PEND = GV_MENGE.


* Quantidade com fornecedor
    WA_OUTTAB-QTD_FORN = GV_FORN.

*} Inicio Alteracao 001 Homine (RIT) 03/07/18
***> ALTERADO PARA NÃO CALCULAR QUANDO A NOTA NÃO ESTIVER ESCRITURADA
    IF WA_OUTTAB-ST_ESCR NE C_N_ESC.
* Quantidade em "estoque"
      WA_OUTTAB-QTD_ESTOQUE = WA_OUTTAB-QTD_PEND - WA_OUTTAB-QTD_FORN.
    ELSE.
      WA_OUTTAB-QTD_ESTOQUE = 0.
    ENDIF.
*{ Fim Alteracao 001 Homine (RIT) 03/07/18

* Quantidade devolvida
    WA_OUTTAB-QTD_DEV = WA_OUTTAB-QTD_NF - WA_OUTTAB-QTD_PEND.

    IF WA_OUTTAB-QTD_PEND IS INITIAL.

* Dias
      WA_OUTTAB-DIAS   = 0.

* Nota com quantidade integralmente devolvida
      WA_OUTTAB-STATUS = C_DEVOL.

    ELSE.

* Dias
      WA_OUTTAB-DIAS = SY-DATUM - WA_OUTTAB-DT_EMI.

* Verde
      IF WA_OUTTAB-DIAS LE 100.

        WA_OUTTAB-STATUS = C_100.

* Amarelo
      ELSEIF WA_OUTTAB-DIAS GT 100 AND WA_OUTTAB-DIAS LE 180.

        WA_OUTTAB-STATUS = C_100_180.

* Vermelho
      ELSE.

        WA_OUTTAB-STATUS = C_180.

      ENDIF.

    ENDIF.

* Se NF = não escriturada ou quant. pendente = 0 ou quant. em estoque = 0
    IF WA_OUTTAB-ST_ESCR EQ C_N_ESC OR
       WA_OUTTAB-QTD_PEND IS INITIAL OR
       WA_OUTTAB-QTD_ESTOQUE IS INITIAL.

* Fecha o campo de seleção de NF (flag)
      WA_STYLEROW-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.

      APPEND WA_STYLEROW TO WA_OUTTAB-FIELD_STYLE.

    ENDIF.

    APPEND WA_OUTTAB TO IT_OUTTAB.

    CLEAR WA_OUTTAB.

  ENDLOOP.

  IT_OUTTAB_AUX[] = IT_OUTTAB[].

ENDFORM.                    " F_MONTA_HEADER

*&---------------------------------------------------------------------*
*&      Module  STATUS_0400  OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0400 OUTPUT.

  SET PF-STATUS 'STATUS_400'.
  SET TITLEBAR 'TITLE_400'.

  GV_CHECK_1 = ABAP_TRUE.
  GV_CHECK_2 = ABAP_TRUE.
  GV_CHECK_3 = ABAP_TRUE.
  GV_CHECK_4 = ABAP_TRUE.
  GV_CHECK_5 = ABAP_TRUE.
  GV_CHECK_6 = ABAP_TRUE.

ENDMODULE.                 " STATUS_0400  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0400 INPUT.

  CASE SY-UCOMM.

    WHEN C_FILTRAR.

      REFRESH IT_OUTTAB.

      IF NOT GV_CHECK_1 IS INITIAL.

        LOOP AT IT_OUTTAB_AUX INTO WA_OUTTAB WHERE ST_ESCR EQ C_ESC.
          APPEND WA_OUTTAB TO IT_OUTTAB.
        ENDLOOP.

      ENDIF.

      IF NOT GV_CHECK_2 IS INITIAL.

        LOOP AT IT_OUTTAB_AUX INTO WA_OUTTAB WHERE ST_ESCR EQ C_N_ESC.
          APPEND WA_OUTTAB TO IT_OUTTAB.
        ENDLOOP.

      ENDIF.

      IF NOT GV_CHECK_3 IS INITIAL.

        LOOP AT IT_OUTTAB_AUX INTO WA_OUTTAB WHERE STATUS EQ C_100.
          APPEND WA_OUTTAB TO IT_OUTTAB.
        ENDLOOP.

      ENDIF.

      IF NOT GV_CHECK_4 IS INITIAL.

        LOOP AT IT_OUTTAB_AUX INTO WA_OUTTAB WHERE STATUS EQ C_100_180.
          APPEND WA_OUTTAB TO IT_OUTTAB.
        ENDLOOP.

      ENDIF.

      IF NOT GV_CHECK_5 IS INITIAL.

        LOOP AT IT_OUTTAB_AUX INTO WA_OUTTAB WHERE STATUS EQ C_180.
          APPEND WA_OUTTAB TO IT_OUTTAB.
        ENDLOOP.

      ENDIF.

      IF NOT GV_CHECK_6 IS INITIAL.

        LOOP AT IT_OUTTAB_AUX INTO WA_OUTTAB WHERE STATUS EQ C_DEVOL.
          APPEND WA_OUTTAB TO IT_OUTTAB.
        ENDLOOP.

      ENDIF.

      SORT IT_OUTTAB.

      DELETE ADJACENT DUPLICATES FROM IT_OUTTAB COMPARING ALL FIELDS.

      CALL METHOD GO_ALV->REFRESH_TABLE_DISPLAY.

      LEAVE TO SCREEN 0.

    WHEN C_CANC.

      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0400  INPUT
