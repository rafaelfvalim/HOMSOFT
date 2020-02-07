*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_DATAENTRYI02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0102  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0102 INPUT.


  CASE SY-UCOMM.

    WHEN 'BACK' OR 'CANC' OR 'EXIT'.

      SET SCREEN 0.

    WHEN 'CNC'.

      SET SCREEN 0.

    WHEN 'GRV'.


      CONCATENATE V_NUM_DOC V_DATA_DOC WA_DADOS_XML-CNPJ INTO V_CHAVE.

      EXPORT V_CHAVE TO MEMORY ID 'CHAVE_NFSE'.

*      PERFORM f_grava_tabelas.

  ENDCASE.


ENDMODULE.                 " USER_COMMAND_0102  INPUT
*&---------------------------------------------------------------------*
*&      Form  F_GRAVA_TABELAS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_GRAVA_TABELAS .


  WA_CABDOC-CHAVE = V_CHAVE.
  WA_CABDOC-NATDC = '02'.
  WA_CABDOC-TYPED = 'NFSE'.

  SELECT BUKRS BRANCH
  INTO (WA_CABDOC-BUKRS, WA_CABDOC-BRANCH ) UP TO 1 ROWS
  FROM J_1BBRANCH
  WHERE  STCD1 = WA_DADOS_XML-CNPJ.
  ENDSELECT.

  WA_CABDOC-DOCNR = V_NUM_DOC.
  WA_CABDOC-DOCDT = V_DATA_DOC.
  WA_CABDOC-DTALT = SY-DATUM.
  WA_CABDOC-HRALT = SY-UZEIT.


  INSERT ZHMS_TB_CABDOC FROM WA_CABDOC.

*
**wa_repdoc-CHAVE = vg_chave.
**wa_repdoc-DIREC
**wa_repdoc-SEQNC
**wa_repdoc-DCITM
**wa_repdoc-FIELD
**wa_repdoc-VALUE
**wa_repdoc-LOTE
*      wa_repdoc-dtalt = sy-datum.
*      wa_repdoc-hralt = sy-uzeit.
*
*      INSERT zhms_tb_repdoc FROM wa_repdoc.
*
*
**wa_docmn-CHAVE = vg_chave.
**wa_docmn-DIREC
**wa_docmn-SEQNC
**wa_docmn-DCITM
**wa_docmn-FIELD
**wa_docmn-VALUE
**wa_docmn-LOTE
**wa_docmn
*
*      INSERT zhms_tb_docmn FROM wa_docmn.
*
*
*      wa_docst-natdc = '02'.
*      wa_docst-typed = 'NFSE'.
*      wa_docst-chave = vg_chave.
**wa_docst-STHMS
**wa_docst-STENT
**wa_docst-STREC
**wa_docst-LOTE
*      wa_docst-dtalt = sy-datum.
*      wa_docst-hralt = sy-uzeit.
*
*      INSERT zhms_tb_docst FROM wa_docst.
*
*
*
**INSERT zhms_tb_itmdoc FROM TABLE it_itmdoc.
*      wa_repdocat-chave = vg_chave.
**wa_repdocat-DIREC
**wa_repdocat-SEQNC
**wa_repdocat-DCITM
**wa_repdocat-FIELD
**wa_repdocat-VALUE
**wa_repdocat-LOTE
*
*      INSERT zhms_tb_repdocat FROM wa_repdocat.
*
*
*      wa_docmna-chave = vg_chave.
**wa_docmna-SEQNR
**wa_docmna-MNEUM
**wa_docmna-DCITM
**wa_docmna-ATITM
**wa_docmna-VALUE
**wa_docmna-LOTE
*
*      INSERT zhms_tb_docmna FROM wa_docmna.

ENDFORM.                    " F_GRAVA_TABELAS
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       Controles para tela de logs
*----------------------------------------------------------------------*
MODULE M_USER_COMMAND_0300 INPUT.
  CASE OK_CODE.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.

  CLEAR OK_CODE.
ENDMODULE.                 " USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*&      Module  M_LIST_FLOWD  INPUT
*&---------------------------------------------------------------------*
*       Dados personalizados para lista de etapas
*----------------------------------------------------------------------*
MODULE M_LIST_FLOWD INPUT.

**    Dados Locais
  TYPE-POOLS : VRM.
  DATA: VL_ID     TYPE  VRM_ID VALUE 'VG_FLOWD'.
  DATA: TL_OPCOES TYPE VRM_VALUES,
        WL_OPCOES LIKE LINE OF TL_OPCOES.

  REFRESH : TL_OPCOES[].

**    Busca dados cadastrados

**    Limpar as variáveis
  CLEAR: WA_SCENFLOX.
  REFRESH: T_SCENFLOX.

**    Selecionar fluxo para este tipo de documento
  SELECT *
    INTO TABLE T_SCENFLOX
    FROM ZHMS_TX_SCEN_FLO
    WHERE NATDC	EQ '02'
      AND TYPED	EQ 'NFET'
*          AND loctp EQ wa_type-loctp
      AND SCENA  EQ '10'
      AND ( FLOWD EQ '30' OR FLOWD EQ '40' )
      AND SPRAS	EQ SY-LANGU.

**    Insere registros na tabela interna de lista
  LOOP AT T_SCENFLOX INTO WA_SCENFLOX.
    CLEAR WL_OPCOES.
    WL_OPCOES-KEY  = WA_SCENFLOX-FLOWD.
    WL_OPCOES-TEXT = WA_SCENFLOX-DENOM.
    APPEND WL_OPCOES TO TL_OPCOES.
  ENDLOOP.

**    Insere registros da tabela interna na lista
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      ID     = VL_ID
      VALUES = TL_OPCOES.

**    tratativa de erros
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
    WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDMODULE.                 " M_LIST_FLOWD  INPUT
