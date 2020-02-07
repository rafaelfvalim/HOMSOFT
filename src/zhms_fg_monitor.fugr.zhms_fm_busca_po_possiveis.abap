FUNCTION zhms_fm_busca_po_possiveis.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(CHAVE) TYPE  ZHMS_DE_CHAVE
*"  TABLES
*"      T_SHOW_PO STRUCTURE  ZHMS_ES_SHOW_POSS_PO
*"----------------------------------------------------------------------

  TYPES: BEGIN OF ty_cont,
           ebeln TYPE ekbe-ebeln,
           ebelp TYPE ekbe-ebelp,
*         VGABE TYPE EKBE-VGABE,
           migo  TYPE ekbe-menge,
           miro  TYPE ekbe-menge,
         END OF ty_cont.

  DATA: lv_lifnr TYPE lfa1-lifnr,
        lv_cnpj  TYPE lfa1-stcd1,
        lv_qtmn  TYPE n,
        lv_qtma  TYPE n.

  DATA: lt_ekko     TYPE STANDARD TABLE OF ekko,
        lt_ekpo     TYPE STANDARD TABLE OF ekpo,
        lt_item_xml TYPE STANDARD TABLE OF zhms_tb_itmdoc,
        lt_docmn    TYPE STANDARD TABLE OF zhms_tb_docmn,
        lt_ekbe     TYPE STANDARD TABLE OF ekbe,
        lt_cont     TYPE TABLE OF ty_cont.

  DATA: ls_docmn   LIKE LINE OF lt_docmn,
        ls_ekpo    LIKE LINE OF lt_ekpo,
        ls_show_po LIKE LINE OF t_show_po,
        ls_ekko    LIKE LINE OF lt_ekko,
        ls_ekbe    LIKE LINE OF lt_ekbe,
        ls_cont    LIKE LINE OF lt_cont.

  DATA: wa_cabdoc   TYPE zhms_tb_cabdoc.
*Ranges
  RANGEs: R_meins FOR ekpo-meins.



  lv_cnpj = chave+6(14).

*  SELECT SINGLE value
*    FROM zhms_tb_docmn
*    INTO lv_cnpj
*   WHERE mneum EQ 'CNPJ'
*     AND chave EQ chave.
*
*  IF sy-subrc NE 0.
*    SELECT SINGLE value
*      FROM zhms_tb_docmn
*      INTO lv_cnpj
*     WHERE mneum EQ 'EMITCNPJ'
*       AND chave EQ chave.
*  ENDIF.

  SELECT SINGLE * FROM zhms_tb_cabdoc INTO wa_cabdoc WHERE chave EQ chave.

  IF sy-subrc IS INITIAL.

    if wa_cabdoc-PARID is INITIAL.
*** Busca CNPJ do fornecedor
      IF wa_cabdoc-typed EQ 'NFE3'.
*        lv_lifnr = wa_cabdoc-parid.

      ELSEIF wa_cabdoc-typed EQ 'NFSE1'.
        SELECT SINGLE lifnr
          FROM lfa1
          INTO lv_lifnr
         WHERE stcd1 EQ chave+8(14).
      ELSE.
        SELECT SINGLE lifnr
          FROM lfa1
          INTO lv_lifnr
         WHERE stcd1 EQ lv_cnpj.
      ENDIF.
    else.
      lv_lifnr = wa_cabdoc-PARID.
    endif.
    IF not lv_lifnr IS INITIAL.

*** busca pedidos liberados para o fornecedor
      if wa_cabdoc-BUKRS is initial.
        SELECT *
        FROM ekko
        INTO TABLE lt_ekko
       WHERE lifnr EQ lv_lifnr
        and  ( procstat = '05' or procstat = '02' )
        and  ( bstyp = 'F' or bstyp = 'L' )
        and  loekz = ''.
      else.
        SELECT *
          FROM ekko
          INTO TABLE lt_ekko
         WHERE lifnr EQ lv_lifnr
*          and  ( procstat = '05' or procstat = '02' )
*          and  ( bstyp = 'F' or bstyp = 'L' )
          and  loekz = ''
          and bukrs = wa_cabdoc-BUKRS.

        DELETE lt_ekko where  ( procstat = '01' or procstat = '03' or procstat = '04' or procstat = '08' or procstat = '26' )
        and  ( bstyp = 'A' or bstyp = 'K' ).

      endif.
*         AND statu EQ '9'.
*          AND frgke EQ 'L'. "RRO 28/01/2019 Comentado HOMINE

      SELECT * FROM zhms_tb_docmn INTO table lt_docmn WHERE chave EQ chave
                                                        and MNEUM = 'ATUM'.

      if sy-subrc = 0.
        loop at lt_docmn into ls_docmn.
          R_meins-SIGN = 'I'.
          R_meins-OPTION = 'EQ'.
          R_Meins-LOW  = ls_docmn-VALUE.
          APPEND R_meins.
        endloop.
        delete adjacent duplicates from R_meins.
      endif.

      IF NOT lt_ekko[] IS INITIAL.
        if wa_cabdoc-typed EQ 'CTE'.
          if R_meins[] is initial.
*** Busca Items dos pedidos selecionados
            SELECT *
              FROM ekpo
              INTO TABLE lt_ekpo
              FOR ALL ENTRIES IN lt_ekko
              WHERE ebeln EQ lt_ekko-ebeln
                AND loekz EQ ''
                and elikz eq ' '
                and erekz eq ''
                and wepos eq ''
                and repos eq 'X'.
          else.
*** Busca Items dos pedidos selecionados
            SELECT *
              FROM ekpo
              INTO TABLE lt_ekpo
              FOR ALL ENTRIES IN lt_ekko
              WHERE ebeln EQ lt_ekko-ebeln
                AND loekz EQ ''
                and elikz eq ' '
                and erekz eq ''
                and wepos eq ''
                and repos eq 'X'
                and meins in R_meins.
          endif.
        else.
          if R_meins[] is initial.
*** Busca Items dos pedidos selecionados
            SELECT *
              FROM ekpo
              INTO TABLE lt_ekpo
              FOR ALL ENTRIES IN lt_ekko
              WHERE ebeln EQ lt_ekko-ebeln
                AND loekz EQ ''
                and elikz eq ' '
                and erekz eq ''
                and wepos eq 'X'
                and repos eq 'X'.
          else.
*** Busca Items dos pedidos selecionados
            SELECT *
              FROM ekpo
              INTO TABLE lt_ekpo
              FOR ALL ENTRIES IN lt_ekko
              WHERE ebeln EQ lt_ekko-ebeln
                AND loekz EQ ''
                and elikz eq ' '
                and erekz eq ''
                and wepos eq 'X'
                and repos eq 'X'
                and meins in R_meins.
          endif.

        endif.
        IF not lt_ekpo[] IS INITIAL.

*** Busca Historico de contabilização do pedido e item
          SELECT *
            FROM ekbe
            INTO TABLE lt_ekbe
            FOR ALL ENTRIES IN lt_ekpo
            WHERE ebeln EQ lt_ekpo-ebeln
              AND ebelp EQ lt_ekpo-ebelp.

          IF sy-subrc = 0.
            LOOP AT lt_ekbe INTO ls_ekbe.
              MOVE: ls_ekbe-ebeln TO ls_cont-ebeln,
                    ls_ekbe-ebelp TO ls_cont-ebelp.
              IF ls_ekbe-vgabe = '1'.
                IF ls_ekbe-shkzg = 'H'.
                  ls_cont-migo = ls_ekbe-menge * -1.
                ELSEIF ls_ekbe-shkzg = 'S'.
                  ls_cont-migo = ls_ekbe-menge.
                ENDIF.
              ELSEIF ls_ekbe-vgabe = '2'.
                IF ls_ekbe-shkzg = 'H'.
                  ls_cont-miro = ls_ekbe-menge * -1.
                ELSEIF ls_ekbe-shkzg = 'S'.
                  ls_cont-miro = ls_ekbe-menge.
                ENDIF.
              ENDIF.
              COLLECT ls_cont INTO lt_cont.
              CLEAR: ls_cont.
            ENDLOOP.

            LOOP AT lt_ekpo INTO ls_ekpo.
              CLEAR ls_show_po.
              MOVE: ls_ekpo-ebeln TO ls_show_po-ebeln,
                    ls_ekpo-ebelp TO ls_show_po-ebelp,
                    ls_ekpo-matnr TO ls_show_po-matnr,
                    ls_ekpo-menge TO ls_show_po-menge.

              SELECT SINGLE  maktx FROM MAKT INTO ls_show_po-MATKX WHERE matnr EQ ls_ekpo-matnr.

              IF sy-subrc IS NOT INITIAL.
                MOVE ls_ekpo-txz01 TO ls_show_po-MATKX.
              ENDIF.

              READ TABLE lt_cont INTO ls_cont WITH KEY ebeln = ls_ekpo-ebeln
                                                       ebelp = ls_ekpo-ebelp.

              IF sy-subrc = 0.
                IF ls_cont-migo >= ls_cont-miro.
                  ls_show_po-wemng = ls_show_po-menge - ls_cont-migo.
                  ls_show_po-ameng = ls_cont-migo.
                ELSE.
                  ls_show_po-wemng = ls_show_po-menge - ls_cont-miro.
                  ls_show_po-ameng = ls_cont-miro.
                ENDIF.
              ELSE.
                MOVE: ls_ekpo-menge TO ls_show_po-wemng.
              ENDIF.
              CHECK ls_show_po-wemng > 0.

              APPEND ls_show_po TO t_show_po.

            ENDLOOP.
          ELSE.
            LOOP AT lt_ekpo INTO ls_ekpo.
              CLEAR ls_show_po.
              MOVE: ls_ekpo-ebeln TO ls_show_po-ebeln,
                    ls_ekpo-ebelp TO ls_show_po-ebelp,
                    ls_ekpo-matnr TO ls_show_po-matnr,
                    ls_ekpo-menge TO ls_show_po-menge,
                    ls_ekpo-menge TO ls_show_po-wemng.

              APPEND ls_show_po TO t_show_po.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
  SORT t_show_po BY ebeln ebelp.
ENDFUNCTION.
