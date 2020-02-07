class ZCL_HMS_PARAMS definition
  public
  final
  create public .

public section.

  class-methods GET_VALUE
    importing
      value(PARAM) type RVARI_VNAM
    returning
      value(VALUE) type RVARI_VAL_255 .
protected section.
private section.
ENDCLASS.



CLASS ZCL_HMS_PARAMS IMPLEMENTATION.


  method get_value.
    select single value
      from zhms_tb_params
      into value
     where param = param .
  endmethod.
ENDCLASS.
