*&---------------------------------------------------------------------*
*& Report  ZHMS_LIMPA_NFE
*&---------------------------------------------------------------------*
*& Executa os programas ZHMS_LIMPA_CHAVE e ZHMA_EXCLUI_CHAVE de forma
*& dinamica
*&---------------------------------------------------------------------*
* RCP - Tradução EN/ES - 13/08/2018
*&---------------------------------------------------------------------*
REPORT  zhms_limpa_nfe.

TABLES zhms_tb_hrvalid.
DATA  BEGIN OF itab_list OCCURS 0.
        INCLUDE STRUCTURE abaplist.
DATA  END OF itab_list.

DATA: BEGIN OF vlist OCCURS 0,
          line TYPE c LENGTH 255,
      END OF vlist.

DATA: t_docmn TYPE TABLE OF zhms_tb_docmn,
      w_docmn TYPE zhms_tb_docmn.


SELECTION-SCREEN BEGIN OF BLOCK b1.
SELECT-OPTIONS p_chave FOR zhms_tb_hrvalid-chave NO INTERVALS.
PARAMETER: p_limpa AS CHECKBOX DEFAULT 'X',
           p_exclui AS CHECKBOX DEFAULT ''.
SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.

*  SELECT *
*    FROM zhms_tb_docmn
*    INTO TABLE t_docmn
*    WHERE mneum = 'SERIE'
*      AND value = '37'.
*
*  IF sy-subrc EQ 0.
*    LOOP AT t_docmn INTO w_docmn.
*
**LOOP AT p_chave.
*      IF p_limpa IS NOT INITIAL.
** Executa Limpa Chave
*        SUBMIT zhms_limpa_chave WITH v_chave = w_docmn-chave
*                                EXPORTING LIST TO MEMORY
*                                AND RETURN.
*
*        CLEAR: itab_list, vlist,
*                itab_list[], vlist[].
*
*
*        CALL FUNCTION 'LIST_FROM_MEMORY'
*          TABLES
*            listobject = itab_list
*          EXCEPTIONS
*            not_found  = 4
*            OTHERS     = 8.
*
*        CALL FUNCTION 'LIST_TO_ASCI'
*          EXPORTING
*            list_index         = -1
*          TABLES
*            listasci           = vlist
*            listobject         = itab_list
*          EXCEPTIONS
*            empty_list         = 1
*            list_index_invalid = 2
*            OTHERS             = 3.
*
*        IF sy-subrc NE '0'.
*          WRITE:/ 'LIST_TO_ASCI error !! ', sy-subrc.
*        ELSE.
*          LOOP AT vlist.
*            WRITE:/ vlist-line.
*          ENDLOOP.
*        ENDIF.
*
*      ENDIF.
*
*      IF p_exclui IS NOT INITIAL.
** Executa Exclui Chave
*        SUBMIT zhms_exclui_chave WITH p_chave = w_docmn-chave
*                                EXPORTING LIST TO MEMORY
*                                AND RETURN.
*
*        CLEAR: itab_list, vlist,
*                itab_list[], vlist[].
*
*        CALL FUNCTION 'LIST_FROM_MEMORY'
*          TABLES
*            listobject = itab_list
*          EXCEPTIONS
*            not_found  = 4
*            OTHERS     = 8.
*
*        CALL FUNCTION 'LIST_TO_ASCI'
*          EXPORTING
*            list_index         = -1
*          TABLES
*            listasci           = vlist
*            listobject         = itab_list
*          EXCEPTIONS
*            empty_list         = 1
*            list_index_invalid = 2
*            OTHERS             = 3.
*
*        IF sy-subrc NE '0'.
*          WRITE:/ 'LIST_TO_ASCI error !! ', sy-subrc.
*        ELSE.
*          LOOP AT vlist.
*            WRITE:/ vlist-line.
*          ENDLOOP.
*
*        ENDIF.
*
*      ENDIF.
*
**  ENDLOOP.
*
*    ENDLOOP.
*  ENDIF.

  LOOP AT p_chave.
    IF p_limpa IS NOT INITIAL.
* Executa Limpa Chave
      SUBMIT zhms_limpa_chave WITH v_chave = p_chave-low
                              EXPORTING LIST TO MEMORY
                              AND RETURN.

      CLEAR: itab_list, vlist,
              itab_list[], vlist[].


      CALL FUNCTION 'LIST_FROM_MEMORY'
        TABLES
          listobject = itab_list
        EXCEPTIONS
          not_found  = 4
          OTHERS     = 8.

      CALL FUNCTION 'LIST_TO_ASCI'
        EXPORTING
          list_index         = -1
        TABLES
          listasci           = vlist
          listobject         = itab_list
        EXCEPTIONS
          empty_list         = 1
          list_index_invalid = 2
          OTHERS             = 3.

      IF sy-subrc NE '0'.
        WRITE:/ 'LIST_TO_ASCI error !! ', sy-subrc.
      ELSE.
        LOOP AT vlist.
          WRITE:/ vlist-line.
        ENDLOOP.
      ENDIF.

    ENDIF.

    IF p_exclui IS NOT INITIAL.
* Executa Exclui Chave
      SUBMIT zhms_exclui_chave WITH p_chave = p_chave-low
                              EXPORTING LIST TO MEMORY
                              AND RETURN.

      CLEAR: itab_list, vlist,
              itab_list[], vlist[].

      CALL FUNCTION 'LIST_FROM_MEMORY'
        TABLES
          listobject = itab_list
        EXCEPTIONS
          not_found  = 4
          OTHERS     = 8.

      CALL FUNCTION 'LIST_TO_ASCI'
        EXPORTING
          list_index         = -1
        TABLES
          listasci           = vlist
          listobject         = itab_list
        EXCEPTIONS
          empty_list         = 1
          list_index_invalid = 2
          OTHERS             = 3.

      IF sy-subrc NE '0'.
        WRITE:/ 'LIST_TO_ASCI error !! ', sy-subrc.
      ELSE.
        LOOP AT vlist.
          WRITE:/ vlist-line.
        ENDLOOP.

      ENDIF.

    ENDIF.

  ENDLOOP.
