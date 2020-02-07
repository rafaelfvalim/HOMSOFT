*----------------------------------------------------------------------*
*                      H  o  m  S  o  f  t                             *
*          Gestão Eletrônica de Documentos e Processos                 *
*----------------------------------------------------------------------*
* Descrição: Job para transferir documentos finalizados para historico *
*                                                                      *
* RCP - Tradução EN/ES - 13/08/2018                                     *
*----------------------------------------------------------------------*
REPORT  zhms_job_hist_docmn.

DATA: lt_docmn  TYPE STANDARD TABLE OF zhms_tb_docmn,
      lt_item   TYPE STANDARD TABLE OF bapi_incinv_detail_item,
      lt_return TYPE STANDARD TABLE OF bapiret2,
      ls_docmn  LIKE LINE OF lt_docmn,
      lv_lfmon  TYPE marv-lfmon,
      lv_mneu   TYPE zhms_tb_scen_flo-mndoc,
      ls_header TYPE bapi_incinv_detail_header,
      lv_docnum TYPE bapi_incinv_fld-inv_doc_no.

TYPES: BEGIN OF ty_hist,
     chave TYPE zhms_tb_docmn-chave,
       END OF ty_hist.

DATA: lt_hist TYPE STANDARD TABLE OF ty_hist,
      ls_hist LIKE LINE OF lt_hist.

PARAMETERS: p_bukrs TYPE bukrs.

START-OF-SELECTION.

*** Busca todos Mneumonicos
  SELECT * FROM zhms_tb_docmn INTO TABLE lt_docmn.

  CHECK lt_docmn[] IS NOT INITIAL.

*** Busca data vingente
  SELECT SINGLE lfmon  FROM marv INTO lv_lfmon WHERE bukrs EQ p_bukrs.

  IF sy-subrc IS INITIAL.
*** Busca Mneumonico MIRO
    SELECT SINGLE mndoc FROM zhms_tb_scen_flo INTO lv_mneu WHERE funct EQ 'BAPI_INCOMINGINVOICE_CREATE'.

    IF sy-subrc IS INITIAL.
*** Busca cada numero de miro existente na tabela zhms_tb_docmn e verifica data de vigência
      LOOP AT lt_docmn INTO ls_docmn WHERE mneum EQ lv_mneu.

*** Verifica Data vigencia da miro
        MOVE ls_docmn-value TO lv_docnum.
        CALL FUNCTION 'BAPI_INCOMINGINVOICE_GETDETAIL'
          EXPORTING
            invoicedocnumber = lv_docnum
            fiscalyear       = sy-datum(4)
          IMPORTING
            headerdata       = ls_header
          TABLES
            itemdata         = lt_item
            return           = lt_return.

        IF ls_header IS NOT INITIAL.
          IF ls_header-pstng_date+4(2) < lv_lfmon.
            MOVE ls_docmn-chave TO ls_hist-chave.
            APPEND ls_hist TO lt_hist.
          ENDIF.
        ENDIF.
*** Limpa Variaveis de controle
        CLEAR: lt_item[], lt_return[], ls_header, lv_docnum.
      ENDLOOP.
    ENDIF.
  ENDIF.

*** Deleta chaves adjacentes
  DELETE ADJACENT DUPLICATES FROM lt_hist COMPARING chave.

  CHECK lt_hist[] IS NOT INITIAL.

*** Transfere todos os registros com a chave gravada para historico
  REFRESH lt_docmn[].
  SELECT * FROM
    zhms_tb_docmn INTO TABLE lt_docmn
    FOR ALL ENTRIES IN lt_hist
    WHERE chave EQ lt_hist-chave.

  IF lt_docmn[] IS NOT INITIAL.
*** Transfere informações para a tabela de historico
    MODIFY zhms_tb_docmn FROM TABLE lt_docmn.

    IF sy-subrc IS INITIAL.
      COMMIT WORK.
    ELSE.
      ROLLBACK WORK.
    ENDIF.

*** Exclui registros da tabela principal de mneumonico
*    DELETE zhms_tb_docmn FROM TABLE lt_docmn.
*
*    IF sy-subrc IS INITIAL.
*      COMMIT WORK.
*    ELSE.
*      ROLLBACK WORK.
*    ENDIF.

  ENDIF.
