*"* components of interface ZIF_EX_NFE
interface ZIF_EX_NFE
  public .


  class-methods DEFINED_PRINTING
    importing
      !I_DOCNUM type J_1BDOCNUM
    exporting
      !E_RETORNO type SY-SUBRC .
  class-methods PRINTING
    importing
      !NF type J_1BPRNFHD
    changing
      !INVOICE type ZNFYINVOICE
      !TEXT type J_1BPRNFTX
      !CARRIER type J_1BINNAD
      !STATE_VEHICLE type REGIO
      !LICENSE_PLATE type TRAID .
  class-methods FILLING_DANFE
    changing
      !DANFE type ZNFEDANFE_HEADER .
endinterface.
