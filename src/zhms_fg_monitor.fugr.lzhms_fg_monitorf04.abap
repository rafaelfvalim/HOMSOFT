*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_MONITORF04 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_SEND_EVENTET
*&---------------------------------------------------------------------*
**      Envia evento de entidade tributária
*----------------------------------------------------------------------*
FORM f_send_eventet .

** Variaveis locais
  DATA: tl_itxw_note    TYPE STANDARD TABLE OF txw_note,
        wl_itxw_note    TYPE txw_note,
        tl_textnote(72) TYPE c OCCURS 0,
        vl_tam          TYPE i,
        vl_erro         TYPE flag,
        vl_txt          TYPE string.

** Limpar dados iniciais
  CLEAR: vl_erro.

  IF wa_nfeevt-cpobs NE 0.

** Recupera o texto digitado no editor
    CALL METHOD ob_dcevt_obs->get_text_as_r3table
      IMPORTING
        table = tl_textnote.

** Percorrer dados e inserir na variavel de observações
    tl_itxw_note[] = tl_textnote[].

    LOOP AT tl_itxw_note INTO wl_itxw_note.
      CONCATENATE vl_txt wl_itxw_note-line INTO vl_txt.
    ENDLOOP.

    vl_tam = strlen( vl_txt ).
**  verifica obrigatoriedade
    IF wa_nfeevt-cpobs NE 1.
      IF vl_tam < 15.
        MESSAGE i060.
        vl_erro = 'X'.
        EXIT.
      ENDIF.

      IF vl_tam > wa_nfeevt-lmobs.
        MESSAGE i061 WITH wa_nfeevt-lmobs.
        vl_erro = 'X'.
        EXIT.
      ENDIF.
    ENDIF.


    CHECK vl_erro IS INITIAL.

**  verifica se existe valor
    CHECK vl_tam NE 0.
    IF vl_tam < 255.
      wa_dcevet-obsc1 = vl_txt(vl_tam).
    ELSE.
      wa_dcevet-obsc1 = vl_txt(255).
    ENDIF.

    IF vl_tam > 255.
      wa_dcevet-obsc2 = vl_txt+255(255).
    ENDIF.
    IF vl_tam > 510.
      wa_dcevet-obsc3 = vl_txt+510(255).
    ENDIF.
    IF vl_tam > 765.
      wa_dcevet-obsc4 = vl_txt+765.
    ENDIF.

  ENDIF.

** Busca proximo codigo em sequencia
  SELECT MAX( seqnr )
    INTO wa_dcevet-seqnr
    FROM zhms_tb_dcevet
   WHERE natdc = wa_cabdoc-natdc
     AND typed = wa_cabdoc-typed
*     AND loctp = wa_cabdoc-loctp
     AND chave = wa_cabdoc-chave.
  wa_dcevet-seqnr = wa_dcevet-seqnr + 1.


**  Transfere os dados para a WorkArea
  wa_dcevet-natdc = wa_cabdoc-natdc.
  wa_dcevet-typed = wa_cabdoc-typed.
*  wa_dcevet-loctp = wa_cabdoc-loctp.
  wa_dcevet-chave = wa_cabdoc-chave.
  wa_dcevet-dtreg = sy-datum.
  wa_dcevet-hrreg = sy-uzeit.
  wa_dcevet-uname = sy-uname.
  wa_dcevet-logty = 'W'.

** Insere valores na tabela
  INSERT INTO zhms_tb_dcevet VALUES wa_dcevet.
  COMMIT WORK AND WAIT.

  IF sy-subrc IS INITIAL.
    MESSAGE s062 .
  ENDIF.

  CLEAR wa_dcevet.

ENDFORM.                    " F_SEND_EVENTET
