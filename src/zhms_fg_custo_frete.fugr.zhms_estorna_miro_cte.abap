FUNCTION zhms_estorna_miro_cte.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  TABLES
*"      ZENTRADA_CTE STRUCTURE  ZENT_ESTORNA_MIRO_CTE
*"      RETURN STRUCTURE  BAPIRETURN
*"----------------------------------------------------------------------
*----------------------------------------------------------------------*
* HomSoft - Estorno do MIRO CTe
*----------------------------------------------------------------------*

*  REFRESH: ti_zentrada_cte, ti_j1bnfdoc, ti_j1bnflin, ti_nfeative,
*           ti_vbrp, ti_vttp_vbrp, ti_status, ti_fatura, ti_status,
*           ti_vfkp, ti_vfkn, ti_vttp, ti_vfkk, ti_return,
*           ti_return_erro, ti_bdcdata, ti_msgs.
*
*  CLEAR:   wa_zentrada_cte, wa_j1bnfdoc, wa_j1bnflin, wa_nfeative,
*           wa_vbrp, wa_vttp_vbrp, wa_status, wa_fatura, wa_status,
*           wa_vfkp, wa_vfkn, wa_vttp, wa_vfkk, wa_return,
*           wa_return_erro, wa_bdcdata, wa_msgs.
*
****" 10/08/2019 -->>
**  ti_zentrada_cte[] = zentrada_cte[].
*  ASSIGN ('(SAPLZHMS_FG_RULER)IT_DOCMN') TO <fs_tab_docmn>.
*  IF <fs_tab_docmn> IS ASSIGNED.
*    ti_docmn = <fs_tab_docmn>.
*    READ TABLE ti_docmn ASSIGNING <fs_wa_docmn> WITH KEY mneum = 'NUMEROFAT'.
*    IF sy-subrc EQ 0.
*      wa_zentrada-fatura = <fs_wa_docmn>-value.
*      READ TABLE ti_docmn ASSIGNING <fs_wa_docmn> WITH KEY mneum = 'CNPJEMI'.
*      IF sy-subrc EQ 0.
*        wa_zentrada-cnpj = <fs_wa_docmn>-value.
*        APPEND wa_zentrada TO ti_zentrada.
*      ENDIF.
*      CLEAR wa_zentrada.
*    ENDIF.
*  ENDIF.
****" 10/08/2019 <<--.
*
*  IF ti_zentrada_cte[] IS INITIAL.
*    "Não há dados para execução.
*    wa_return-message = TEXT-005.
*    APPEND wa_return TO ti_return.
*    CLEAR wa_return.
*    return[] = ti_return[].
*  ENDIF.
*
*  CHECK ti_return[] IS INITIAL.
*
*  LOOP AT ti_zentrada_cte INTO wa_zentrada_cte.
*
*    IF wa_zentrada_cte-nct IS INITIAL.
*      "Há entrada sem Numero do Cte
*      wa_return-message = TEXT-019.
*      APPEND wa_return TO ti_return.
*      CLEAR wa_return.
*    ENDIF.
*
*  ENDLOOP.
*
*  DELETE ADJACENT DUPLICATES FROM ti_return.
*
*  IF NOT ti_return[] IS INITIAL.
*    return[] = ti_return[].
*  ENDIF.
*
*  CHECK ti_return[]       IS INITIAL AND
*        ti_zentrada_cte[] IS NOT INITIAL.
*
*  "Com o número do Cte executado, buscar os campos BELNR e ZSTMI da
*  "tabela ZHMS_TB_STATUS onde ZCTET = Numero do Cte
*  SELECT *
*    FROM zhms_tb_status
*    INTO TABLE ti_status
*    FOR ALL ENTRIES IN ti_zentrada_cte
*    WHERE zctet = ti_zentrada_cte-nct.
*
*  IF NOT sy-subrc IS INITIAL.
*
*    "Nenhum Controle de status - Frete encontrado no Homsoft
*    wa_return-message = TEXT-029.
*    APPEND wa_return TO ti_return.
*    CLEAR wa_return.
*
*  ENDIF.
*
*  CHECK ti_return[] IS INITIAL.
*
*  LOOP AT ti_status INTO wa_status.
*
*    "Se ZSTMI <> “C”, exibir mensagem de erro: “Entrada de fatura
*    "ainda não realizada para CT-e: Numero do Cte” e encerrar processamento.
*    "Senão, continuar processamento.
*    IF wa_status-zstmi NE 'C'.
*
*      CONCATENATE TEXT-053 wa_status-zctet INTO wa_return-message
*                  SEPARATED BY space.
*      APPEND wa_return TO ti_return.
*      CLEAR wa_return.
*      return[] = ti_return[].
*
*      "encerrar processamento no 1o.CTe encontrado na situação incorreta
*      EXIT.
*
*    ENDIF.
*
*  ENDLOOP.
*
*  CHECK ti_return[] IS INITIAL.
*
*
****2.  Executar Batch-input para estorno da MIRO
*  PERFORM pf_estorna_miro_cte.
*
*
*  IF NOT ti_return[] IS INITIAL.
*
*    DELETE ADJACENT DUPLICATES FROM ti_return.
*
*  ENDIF.
*
*  IF NOT ti_return_erro[] IS INITIAL.
*
*    DELETE ADJACENT DUPLICATES FROM ti_return_erro.
*
*    CLEAR wa_return_erro.
*    LOOP AT ti_return_erro INTO wa_return_erro.
*
*      APPEND wa_return_erro TO ti_return.
*      CLEAR wa_return_erro.
*
*    ENDLOOP.
*
*  ENDIF.
*
*  return[] = ti_return[].


ENDFUNCTION.
