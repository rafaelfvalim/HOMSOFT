REPORT  zhms_edit_status.

*RCP - Tradução EN/ES - 13/08/2018

TABLES: j_1bnfdoc.

DATA: t_doc       TYPE TABLE OF j_1bnfdoc,
      t_doc_aux   TYPE TABLE OF j_1bnfdoc,
      t_doc_aux2  TYPE TABLE OF j_1bnfdoc,
      t_docmn     TYPE TABLE OF zhms_tb_docmn,
      t_docmn_aux TYPE TABLE OF zhms_tb_docmn,
      t_cabdoc    TYPE TABLE OF zhms_tb_cabdoc.

DATA: w_doc       TYPE j_1bnfdoc,
      w_doc_aux   TYPE j_1bnfdoc,
      w_docst     TYPE zhms_tb_docst,
      w_docmn     TYPE zhms_tb_docmn,
      w_docmn_aux TYPE zhms_tb_docmn,
      w_cabdoc    TYPE zhms_tb_cabdoc.

DATA: vl_docnum   TYPE c LENGTH 10.


SELECT-OPTIONS: s_pstdat FOR j_1bnfdoc-pstdat,
                s_docnum FOR j_1bnfdoc-docnum.

AT SELECTION-SCREEN OUTPUT.
  CLEAR s_pstdat.
  s_pstdat-sign = 'I'.
  s_pstdat-option = 'BT'.
  s_pstdat-low = sy-datum - 1.
  s_pstdat-high = sy-datum.
  APPEND s_pstdat.

START-OF-SELECTION.

  break rsantos.

  SELECT *
    FROM j_1bnfdoc
    INTO TABLE t_doc
    WHERE docnum IN s_docnum
      AND pstdat IN s_pstdat
      AND ( nftype EQ 'E1' OR nftype EQ 'A1')
      AND manual EQ 'X'.

  IF sy-subrc EQ 0.

    SORT t_doc BY nfnum.
    t_doc_aux2 = t_doc.
    DELETE ADJACENT DUPLICATES FROM t_doc COMPARING nfnum.

    LOOP AT t_doc INTO w_doc.

      t_doc_aux = t_doc_aux2.
      DELETE t_doc_aux WHERE nfnum NE w_doc-nfnum.

      SORT t_doc_aux BY docnum DESCENDING.
      LOOP AT t_doc_aux INTO w_doc_aux.

* Nota estornada (livre para novo lançamento)
        IF w_doc_aux-nftype EQ 'A1'.

          IF w_doc_aux-nfenum IS NOT INITIAL.
            vl_docnum  = w_doc_aux-nfenum.
          ELSE.
            vl_docnum  = w_doc_aux-nfnum.
          ENDIF.
          PACK vl_docnum TO vl_docnum.
          CONDENSE vl_docnum NO-GAPS.

          SELECT *
            FROM zhms_tb_docmn
            INTO TABLE t_docmn
            WHERE mneum = 'NNF'
              AND value = vl_docnum.
          IF sy-subrc EQ 0.
            SELECT *
              FROM zhms_tb_docmn
              INTO TABLE t_docmn_aux
              FOR ALL ENTRIES IN t_docmn
              WHERE chave = t_docmn-chave.
            IF sy-subrc EQ 0.
              READ TABLE t_docmn_aux INTO w_docmn_aux WITH KEY mneum = 'CNPJ'
                                                               value = w_doc_aux-cgc.
              IF sy-subrc EQ 0.
                SELECT SINGLE *
                  FROM zhms_tb_docst
                  INTO w_docst
                  WHERE chave = w_docmn_aux-chave.
                IF sy-subrc EQ 0.
                  w_docst-sthms = 2.
                  w_docst-dtalt = sy-datum.
                  w_docst-hralt = sy-uzeit.
                  MODIFY zhms_tb_docst FROM w_docst.
                  EXIT.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.

        ELSEIF w_doc_aux-nftype EQ 'E1'.

* Nota Lançada (Altera status HomSoft)
          IF w_doc_aux-nfenum IS NOT INITIAL.
            vl_docnum  = w_doc_aux-nfenum.
          ELSE.
            vl_docnum  = w_doc_aux-nfnum.
          ENDIF.
          PACK vl_docnum TO vl_docnum.
          CONDENSE vl_docnum NO-GAPS.

          SELECT *
            FROM zhms_tb_docmn
            INTO TABLE t_docmn
            WHERE mneum = 'NNF'
              AND value = vl_docnum.
          IF sy-subrc EQ 0.
            SELECT *
              FROM zhms_tb_docmn
              INTO TABLE t_docmn_aux
              FOR ALL ENTRIES IN t_docmn
              WHERE chave = t_docmn-chave.
            IF sy-subrc EQ 0.

* O lançamento foi feito atraves do HOMSOFT
              READ TABLE t_docmn_aux INTO w_docmn_aux WITH KEY mneum = 'MATDOC'.
              IF sy-subrc EQ 0.
                IF w_docmn_aux-value IS NOT INITIAL.
                  EXIT.
                ENDIF.
              ENDIF.

              READ TABLE t_docmn_aux INTO w_docmn_aux WITH KEY mneum = 'CNPJ'
                                                               value = w_doc_aux-cgc.
              IF sy-subrc EQ 0.
                SELECT SINGLE *
                  FROM zhms_tb_docst
                  INTO w_docst
                  WHERE chave = w_docmn_aux-chave.
                IF sy-subrc EQ 0.
                  w_docst-sthms = 3.
                  w_docst-dtalt = sy-datum.
                  w_docst-hralt = sy-uzeit.
                  MODIFY zhms_tb_docst FROM w_docst.
                  EXIT.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.

    ENDLOOP.
  ENDIF.
