FUNCTION zhms_fm_consultaet.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(NATDC) TYPE  ZHMS_DE_NATDC
*"     VALUE(TYPED) TYPE  ZHMS_DE_TYPED
*"     VALUE(CHAVE) TYPE  ZHMS_DE_CHAVE
*"  EXPORTING
*"     VALUE(RETURN) LIKE  ZHMS_ES_RETURN STRUCTURE  ZHMS_ES_RETURN
*"----------------------------------------------------------------------
* RCP - Tradução EN/ES - 15/08/2018

*** Declaração de Variaveis
  DATA: lv_status TYPE zhms_de_retnr, " 1 = Aprovado 2 = retorno pendente 3 = Cancelado
        lv_exnat  TYPE zhms_de_exnat VALUE '02',
        lv_extpd  TYPE zhms_de_extpd VALUE 'NFE',
        lv_exevt  TYPE zhms_de_exevt VALUE '2',
        lv_direc  TYPE zhms_de_direc VALUE 'S',
        lv_text   TYPE char80,
        lv_st_at  TYPE zhms_de_stent,
        lv_mensg  TYPE zhms_tb_messagin-mensg,
        lv_index  TYPE sy-tabix.

*** Declaração de tabelas internas
  DATA: lt_msgdata  TYPE STANDARD TABLE OF zhms_es_msgdtm,
        ls_msgdata  LIKE LINE OF lt_msgdata,
        lt_msgatrb  TYPE STANDARD TABLE OF zhms_es_msgatm,
        ls_msgatrb  LIKE LINE OF lt_msgatrb,
        lt_mapdatac TYPE STANDARD TABLE OF zhms_tb_mapdatac,
        ls_mapdatac LIKE LINE OF lt_mapdatac,
        lt_return   TYPE STANDARD TABLE OF zhms_es_return,
        lv_codmp    TYPE zhms_de_codmp.

  DATA: fieldcat    TYPE lvc_t_fcat,
        r_fieldcat  LIKE LINE OF fieldcat,
        d_reference TYPE REF TO data,
        lv_campo    TYPE char80.

  TYPES: BEGIN OF ty_select,
          line TYPE char80,
         END OF ty_select.

  DATA: t_campos       TYPE TABLE OF ty_select WITH HEADER LINE,
        t_where        TYPE TABLE OF ty_select WITH HEADER LINE.

  CLEAR vg_chave.
  MOVE chave TO vg_chave.

*** Busca ´Menssageria
  SELECT SINGLE mensg FROM zhms_tb_messagin INTO lv_mensg WHERE natdc EQ lv_exnat
                                                            AND typed EQ lv_extpd.

  IF sy-subrc IS INITIAL.

*** Busca Código do mapeamento
    SELECT SINGLE codmp INTO lv_codmp FROM zhms_tb_mapconec WHERE natdc EQ lv_exnat
                                                              AND typed EQ lv_extpd
                                                              AND mensg EQ lv_mensg
                                                              AND event EQ lv_exevt.

    IF sy-subrc IS INITIAL.

*** Busca Mneumonicos do mapeamento
      SELECT * FROM zhms_tb_mapdatac INTO TABLE lt_mapdatac  WHERE codmp EQ lv_codmp .

      IF sy-subrc IS INITIAL.
        LOOP AT lt_mapdatac INTO ls_mapdatac.
          ADD 1 TO lv_index.
          CLEAR vg_valor.
*** Verifica se term atributo
          IF ls_mapdatac-eatrb IS NOT INITIAL.

*** Seleciona Atributo
            SELECT SINGLE value INTO vg_valor FROM zhms_tb_evvl_atr WHERE natdc EQ lv_exnat
                                                                      AND typed EQ lv_extpd
                                                                      AND event EQ lv_exevt.
            MOVE lv_index TO ls_msgatrb-seqnc.
            MOVE: ls_mapdatac-mneum   TO ls_msgatrb-mneum,
                  vg_valor            TO ls_msgatrb-value.
            APPEND ls_msgatrb TO lt_msgatrb.
            CLEAR ls_msgatrb.

          ELSE.

            IF ls_mapdatac-fixo IS NOT INITIAL.
              MOVE ls_mapdatac-fixo TO vg_valor.
            ELSE.
              IF ls_mapdatac-rotin IS INITIAL.
*** Monta nome da tabela
                r_fieldcat-fieldname = 'VALUE'.
                APPEND r_fieldcat TO fieldcat.

*** Monta clausula Where
                CONCATENATE 'MNEUM = ''' ls_mapdatac-mneum ''' AND' INTO t_where-line.
                APPEND t_where.
                CONCATENATE 'CHAVE = ''' vg_chave '''' INTO t_where-line.
                APPEND t_where.

*** Monta nome dos campos de seleção
                LOOP AT fieldcat INTO r_fieldcat  .
                  t_campos-line = r_fieldcat-fieldname.
                  APPEND t_campos.
                ENDLOOP.

*** Seleciona valor do campo
                CLEAR:  vg_valor, lv_campo.
                READ TABLE t_campos INTO lv_campo INDEX 1.
                IF lv_campo IS NOT INITIAL.
                  CLEAR vg_valor.
                  SELECT SINGLE (t_campos)
                   INTO vg_valor
                   FROM zhms_tb_docmn
                   WHERE (t_where).
                ENDIF.

                REFRESH: t_campos[], t_where[], fieldcat[].
                CLEAR r_fieldcat.
              ELSE.
                PERFORM (ls_mapdatac-rotin) IN PROGRAM saplzhms_fg_document.
              ENDIF.
            ENDIF.

            MOVE lv_index TO ls_msgdata-seqnc.
            MOVE: ls_mapdatac-mneum   TO ls_msgdata-mneum,
                  vg_valor            TO ls_msgdata-value.
            APPEND ls_msgdata TO lt_msgdata.
            CLEAR ls_msgdata.

          ENDIF.

        ENDLOOP.

        CHECK lt_msgdata[]  IS NOT INITIAL
            OR lt_msgatrb[]  IS NOT INITIAL
               AND lv_exnat   IS NOT INITIAL
                 AND lv_extpd  IS NOT INITIAL
                   AND lv_direc IS NOT INITIAL.

        CALL FUNCTION 'ZHMS_FM_QUAZARIS'
          EXPORTING
            exnat    = lv_exnat
            extpd    = lv_extpd
            exevt    = lv_exevt
            direc    = lv_direc
            usuar    = sy-uname
          TABLES
            msgdatam = lt_msgdata
            msgatrbm = lt_msgatrb.

      ENDIF.
    ENDIF.
  ENDIF.


  DO 60 TIMES.

    WAIT UP TO 1 SECONDS.

*** Verifica se ja existe status para esse documento
    SELECT SINGLE stent INTO lv_st_at FROM zhms_tb_docst WHERE chave EQ chave.

    IF sy-subrc IS INITIAL.
      CASE lv_st_at.
        WHEN 100. "Autorizada
          lv_status = 1.
        WHEN 101. "Cancelada
          lv_status = 3.
        WHEN 102. "Inutilizada
          lv_status = 3.
      ENDCASE.
      EXIT.
    ENDIF.
*** Caso não tenha status.

  ENDDO.

*** Caso status não econtrado
  IF lv_status IS INITIAL.
    lv_status = 2.
    return-retnr = lv_status.
  ENDIF.

  CASE lv_status.
    WHEN 1.
      return-descr = text-001.
    WHEN 2.
      return-descr = text-002.
    WHEN 3.
      return-descr = text-003.
  ENDCASE.

ENDFUNCTION.
