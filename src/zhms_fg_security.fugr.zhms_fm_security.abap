FUNCTION zhms_fm_security.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(VALUE) TYPE  CHAR30
*"  EXCEPTIONS
*"      AUTHORIZATION
*"----------------------------------------------------------------------

  TYPES: BEGIN OF ty_select,
          line TYPE char80,
         END OF ty_select.

  DATA: ls_tb_security TYPE zhms_tb_security,
        fieldcat       TYPE lvc_t_fcat,
        r_fieldcat     LIKE LINE OF fieldcat,
        d_reference    TYPE REF TO data,
        t_campos       TYPE TABLE OF ty_select WITH HEADER LINE,
        t_where        TYPE TABLE OF ty_select WITH HEADER LINE,
        block          TYPE char1.

  r_fieldcat-fieldname = value.
  r_fieldcat-ref_table = 'ZHMS_TB_SECURITY'.
  APPEND r_fieldcat TO fieldcat.

  CONCATENATE 'USUARIO = ''' sy-uname '''' '' INTO t_where-line.
  APPEND t_where.

  LOOP AT fieldcat INTO r_fieldcat  .
    t_campos-line = r_fieldcat-fieldname.
    APPEND t_campos.
  ENDLOOP.


  SELECT SINGLE (t_campos)
   INTO block
   FROM zhms_tb_security
   WHERE (t_where).

  IF block IS INITIAL.
    RAISE authorization.
  ENDIF.

ENDFUNCTION.
