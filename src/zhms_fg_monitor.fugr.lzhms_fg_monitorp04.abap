*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_MONITORP04 .
*----------------------------------------------------------------------*
*{   INSERT         DEVK900059                                        1
*&---------------------------------------------------------------------*
*&       Class (Implementation)  LCL_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*        Text
*----------------------------------------------------------------------*
CLASS lcl_hotspot_click IMPLEMENTATION.
  METHOD handle_hotspot_click.

    break rsantos.

    READ TABLE t_chave INTO wa_chave INDEX 1.

    IF sy-subrc IS INITIAL .

      READ TABLE t_out_vld_i INTO wa_out_vld_i INDEX e_row_id.

      IF sy-subrc IS INITIAL.
*      READ TABLE t_itmatr INTO wa_itmatr WITH KEY atitm = wa_out_vld_i-atitm.
        READ TABLE lt_itmatr INTO wa_itmatr WITH KEY atitm = wa_out_vld_i-atitm.

        IF sy-subrc IS INITIAL.
          SET PARAMETER ID 'BES' FIELD wa_itmatr-nrsrf.
          CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.

        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.                    "handle_hotspot_click
ENDCLASS.               "LCL_HOTSPOT_CLICK
*}   INSERT
