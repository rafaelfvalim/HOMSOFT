FUNCTION ZHMS_FM_BUSCA_PO_POSSIVEIS_DTE.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(STCD1) TYPE  ZHMS_TB_DTENT_CB-STCD1
*"  TABLES
*"      T_SHOW_PO STRUCTURE  ZHMS_ES_SHOW_POSS_PO
*"----------------------------------------------------------------------
*" RCP - Tradução EN/ES - 31/08/2018

  TYPES: BEGIN OF TY_CONT,
         EBELN TYPE EKBE-EBELN,
         EBELP TYPE EKBE-EBELP,
*         VGABE TYPE EKBE-VGABE,
         MIGO TYPE EKBE-MENGE,
         MIRO TYPE EKBE-MENGE,
        END OF TY_CONT.

  DATA: LV_LIFNR TYPE LFA1-LIFNR,
        LV_CNPJ  TYPE LFA1-STCD1,
        LV_QTMN  TYPE N,
        LV_QTMA  TYPE N.

  DATA: LT_EKKO     TYPE STANDARD TABLE OF EKKO,
        LT_EKPO     TYPE STANDARD TABLE OF EKPO,
        LT_ITEM_XML TYPE STANDARD TABLE OF ZHMS_TB_ITMDOC,
        LT_DOCMN    TYPE STANDARD TABLE OF ZHMS_TB_DOCMN,
        LT_EKBE     TYPE STANDARD TABLE OF EKBE,
        LT_CONT     TYPE TABLE OF TY_CONT.

  DATA: LS_DOCMN    LIKE LINE OF LT_DOCMN,
        LS_EKPO     LIKE LINE OF LT_EKPO,
        LS_SHOW_PO  LIKE LINE OF T_SHOW_PO,
        LS_EKKO     LIKE LINE OF LT_EKKO,
        LS_EKBE     LIKE LINE OF LT_EKBE,
        LS_CONT     LIKE LINE OF LT_CONT.


  IF NOT STCD1 IS INITIAL.
*** Busca CNPJ do fornecedor
    SELECT SINGLE LIFNR
      FROM LFA1
      INTO LV_LIFNR
     WHERE STCD1 EQ STCD1.

    IF SY-SUBRC IS INITIAL.

*** busca pedidos liberados para o fornecedor

      SELECT *
        FROM EKKO
        INTO TABLE LT_EKKO
       WHERE LIFNR EQ LV_LIFNR
         AND STATU EQ '9'.

      IF NOT LT_EKKO[] IS INITIAL.

*** Busca Items dos pedidos selecionados
        SELECT *
          FROM EKPO
          INTO TABLE LT_EKPO
          FOR ALL ENTRIES IN LT_EKKO
          WHERE EBELN EQ LT_EKKO-EBELN
            AND LOEKZ EQ ''.

        IF SY-SUBRC IS INITIAL.

*** Busca Historico de contabilização do pedido e item
          SELECT *
            FROM EKBE
            INTO TABLE LT_EKBE
            FOR ALL ENTRIES IN LT_EKPO
            WHERE EBELN EQ LT_EKPO-EBELN
              AND EBELP EQ LT_EKPO-EBELP.

          IF SY-SUBRC = 0.
            LOOP AT LT_EKBE INTO LS_EKBE.
              MOVE: LS_EKBE-EBELN TO LS_CONT-EBELN,
                    LS_EKBE-EBELP TO LS_CONT-EBELP.
              IF LS_EKBE-VGABE = '1'.
                IF LS_EKBE-SHKZG = 'H'.
                  LS_CONT-MIGO = LS_EKBE-MENGE * -1.
                ELSEIF LS_EKBE-SHKZG = 'S'.
                  LS_CONT-MIGO = LS_EKBE-MENGE.
                ENDIF.
              ELSEIF LS_EKBE-VGABE = '2'.
                IF LS_EKBE-SHKZG = 'H'.
                  LS_CONT-MIRO = LS_EKBE-MENGE * -1.
                ELSEIF LS_EKBE-SHKZG = 'S'.
                  LS_CONT-MIRO = LS_EKBE-MENGE.
                ENDIF.
              ENDIF.
              COLLECT LS_CONT INTO LT_CONT.
              CLEAR: LS_CONT.
            ENDLOOP.

            LOOP AT LT_EKPO INTO LS_EKPO.
              CLEAR LS_SHOW_PO.
              MOVE: LS_EKPO-EBELN TO LS_SHOW_PO-EBELN,
                    LS_EKPO-EBELP TO LS_SHOW_PO-EBELP,
                    LS_EKPO-MATNR TO LS_SHOW_PO-MATNR,
                    LS_EKPO-MENGE TO LS_SHOW_PO-MENGE.
              READ TABLE LT_CONT INTO LS_CONT WITH KEY EBELN = LS_EKPO-EBELN
                                                       EBELP = LS_EKPO-EBELP.




              IF SY-SUBRC = 0.
                IF LS_CONT-MIGO >= LS_CONT-MIRO.
                  LS_SHOW_PO-WEMNG = LS_SHOW_PO-MENGE - LS_CONT-MIGO.
                  LS_SHOW_PO-AMENG = LS_CONT-MIGO.
                ELSE.
                  LS_SHOW_PO-WEMNG = LS_SHOW_PO-MENGE - LS_CONT-MIRO.
                  LS_SHOW_PO-AMENG = LS_CONT-MIRO.
                ENDIF.
              ELSE.
                MOVE: LS_EKPO-MENGE TO LS_SHOW_PO-WEMNG.
              ENDIF.
              CHECK LS_SHOW_PO-WEMNG > 0.

              APPEND LS_SHOW_PO TO T_SHOW_PO.

            ENDLOOP.
          ENDIF.
        ENDIF.
      ENDIF.

    ENDIF.
  ELSE.
*** busca pedidos liberados para o fornecedor

    SELECT *
      FROM EKKO
      INTO TABLE LT_EKKO
     WHERE STATU EQ '9'.

    IF NOT LT_EKKO[] IS INITIAL.

*** Busca Items dos pedidos selecionados
      SELECT *
        FROM EKPO
        INTO TABLE LT_EKPO
        FOR ALL ENTRIES IN LT_EKKO
        WHERE EBELN EQ LT_EKKO-EBELN
          AND LOEKZ EQ ''.

      IF SY-SUBRC IS INITIAL.

*** Busca Historico de contabilização do pedido e item
        SELECT *
          FROM EKBE
          INTO TABLE LT_EKBE
          FOR ALL ENTRIES IN LT_EKPO
          WHERE EBELN EQ LT_EKPO-EBELN
            AND EBELP EQ LT_EKPO-EBELP.

        IF SY-SUBRC = 0.
          LOOP AT LT_EKBE INTO LS_EKBE.
            MOVE: LS_EKBE-EBELN TO LS_CONT-EBELN,
                  LS_EKBE-EBELP TO LS_CONT-EBELP.
            IF LS_EKBE-VGABE = '1'.
              IF LS_EKBE-SHKZG = 'H'.
                LS_CONT-MIGO = LS_EKBE-MENGE * -1.
              ELSEIF LS_EKBE-SHKZG = 'S'.
                LS_CONT-MIGO = LS_EKBE-MENGE.
              ENDIF.
            ELSEIF LS_EKBE-VGABE = '2'.
              IF LS_EKBE-SHKZG = 'H'.
                LS_CONT-MIRO = LS_EKBE-MENGE * -1.
              ELSEIF LS_EKBE-SHKZG = 'S'.
                LS_CONT-MIRO = LS_EKBE-MENGE.
              ENDIF.
            ENDIF.
            COLLECT LS_CONT INTO LT_CONT.
            CLEAR: LS_CONT.
          ENDLOOP.

          LOOP AT LT_EKPO INTO LS_EKPO.
            CLEAR LS_SHOW_PO.
            MOVE: LS_EKPO-EBELN TO LS_SHOW_PO-EBELN,
                  LS_EKPO-EBELP TO LS_SHOW_PO-EBELP,
                  LS_EKPO-MATNR TO LS_SHOW_PO-MATNR,
                  LS_EKPO-MENGE TO LS_SHOW_PO-MENGE.
            READ TABLE LT_CONT INTO LS_CONT WITH KEY EBELN = LS_EKPO-EBELN
                                                     EBELP = LS_EKPO-EBELP.




            IF SY-SUBRC = 0.
              IF LS_CONT-MIGO >= LS_CONT-MIRO.
                LS_SHOW_PO-WEMNG = LS_SHOW_PO-MENGE - LS_CONT-MIGO.
                LS_SHOW_PO-AMENG = LS_CONT-MIGO.
              ELSE.
                LS_SHOW_PO-WEMNG = LS_SHOW_PO-MENGE - LS_CONT-MIRO.
                LS_SHOW_PO-AMENG = LS_CONT-MIRO.
              ENDIF.
            ELSE.
              MOVE: LS_EKPO-MENGE TO LS_SHOW_PO-WEMNG.
            ENDIF.
            CHECK LS_SHOW_PO-WEMNG > 0.

            APPEND LS_SHOW_PO TO T_SHOW_PO.

          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
  SORT T_SHOW_PO BY EBELN EBELP.

ENDFUNCTION.
