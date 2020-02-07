*&---------------------------------------------------------------------*
*&  Include           LZHMS_FG_VALIDATEDTP
*&---------------------------------------------------------------------*
    "f_valid_01 INICIO

    DATA: poheader       TYPE bapimepoheader,
          poexpimpheader TYPE bapieikp.

    DATA: po1_return         TYPE STANDARD TABLE OF bapiret2 WITH HEADER LINE,
          poitem             TYPE STANDARD TABLE OF bapimepoitem WITH HEADER LINE,
          poaddrdelivery     TYPE STANDARD TABLE OF bapimepoaddrdelivery WITH HEADER LINE,
          poschedule         TYPE STANDARD TABLE OF bapimeposchedule WITH HEADER LINE,
          poaccount          TYPE STANDARD TABLE OF bapimepoaccount WITH HEADER LINE,
          pocondheader       TYPE STANDARD TABLE OF bapimepocondheader WITH HEADER LINE,
          pocond             TYPE STANDARD TABLE OF bapimepocond WITH HEADER LINE,
          polimits           TYPE STANDARD TABLE OF bapiesuhc WITH HEADER LINE,
          pocontractlimits   TYPE STANDARD TABLE OF bapiesucc WITH HEADER LINE,
          poservices         TYPE STANDARD TABLE OF bapiesllc WITH HEADER LINE,
          posrvaccessvalues  TYPE STANDARD TABLE OF bapiesklc WITH HEADER LINE,
          potextheader       TYPE STANDARD TABLE OF bapimepotextheader WITH HEADER LINE,
          potextitem         TYPE STANDARD TABLE OF bapimepotext WITH HEADER LINE,
          poexpimpitem       TYPE STANDARD TABLE OF bapieipo WITH HEADER LINE,
          pocomponents       TYPE STANDARD TABLE OF bapimepocomponent WITH HEADER LINE,
          poshippingexp      TYPE STANDARD TABLE OF bapimeposhippexp WITH HEADER LINE,
          pohistory          TYPE STANDARD TABLE OF bapiekbe WITH HEADER LINE,
          pohistory_totals   TYPE STANDARD TABLE OF bapiekbes WITH HEADER LINE,
          poconfirmation     TYPE STANDARD TABLE OF bapiekes WITH HEADER LINE,
          allversions        TYPE STANDARD TABLE OF bapimedcm_allversions WITH HEADER LINE,
          popartner          TYPE STANDARD TABLE OF bapiekkop WITH HEADER LINE,
          extensionout       TYPE STANDARD TABLE OF bapiparex WITH HEADER LINE,
          serialnumber       TYPE STANDARD TABLE OF bapimeposerialno WITH HEADER LINE,
          invplanheader      TYPE STANDARD TABLE OF bapi_invoice_plan_header WITH HEADER LINE,
          invplanitem        TYPE STANDARD TABLE OF bapi_invoice_plan_item WITH HEADER LINE,
          pohistory_ma       TYPE STANDARD TABLE OF bapiekbe_ma WITH HEADER LINE.

    "f_valid_01 FIM
