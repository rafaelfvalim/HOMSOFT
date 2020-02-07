*&---------------------------------------------------------------------*
*& Report  ZHMS_REPORT_180DIAS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZHMS_REPORT_180DIAS.


TYPES: BEGIN OF ty_docmn,
         mchave TYPE zhms_tb_docmn-chave,
         mcnpj TYPE zhms_tb_docmn-value,
         mnnf TYPE zhms_tb_docmn-value,
         mcprod TYPE zhms_tb_docmn-value,
         mqtde TYPE zhms_tb_docmn-value,
         mdhemi TYPE zhms_tb_docmn-value,
         mitem TYPE zhms_tb_docmn-dcitm,
         mcfop TYPE zhms_tb_docmn-value,
         mfarol type ICON_D,
         mhoje type D,
         mdatafor type D,
         mdias type I,
         mdocref type J_1BNFDOC-docref,
         mdataenvio type j_1bnfdoc-credat,
         mdocnum type j_1bnfdoc-docnum,
         mstatus type c length 30,
       END OF ty_docmn.


TABLES: ZHMS_TB_DOCMN,J_1BNFDOC.

DATA: T_DOCMN TYPE table of ty_docmn.
DATA: WA_DOCMN TYPE ty_docmn.

DATA: T_J1BNFDOC TYPE TABLE OF J_1BNFDOC.
DATA: WA_J1BNFDOC TYPE J_1BNFDOC.
DATA: V_ICON_GREEN  TYPE ICON-ID,
      V_ICON_YELLOW TYPE ICON-ID,
      V_ICON_RED    TYPE ICON-ID.


DATA: it_fieldcat  TYPE slis_t_fieldcat_alv,
      wa_fieldcat  TYPE slis_fieldcat_alv.

select-options s_nf for ZHMS_TB_DOCMN-VALUE.
select-options s_client for ZHMS_TB_DOCMN-VALUE.
select-options s_codmat for ZHMS_TB_DOCMN-VALUE.




START-OF-SELECTION.

  SELECT
    A~chave c~value b~value d~value E~VALUE  f~value d~dcitm g~value
    FROM
    ZHMS_TB_DOCMN AS A
    INNER JOIN ZHMS_TB_DOCMN AS B ON A~CHAVE = B~CHAVE AND B~MNEUM EQ 'NNF'
    INNER JOIN ZHMS_TB_DOCMN AS C ON A~CHAVE = C~CHAVE AND C~MNEUM EQ 'CNPJ'
    INNER JOIN ZHMS_TB_DOCMN AS D ON A~CHAVE = D~CHAVE AND D~MNEUM EQ 'CPROD'
    INNER JOIN ZHMS_TB_DOCMN AS E ON A~CHAVE = E~CHAVE AND E~MNEUM EQ 'QCOM'
    INNER JOIN ZHMS_TB_DOCMN AS F ON A~CHAVE = F~CHAVE AND F~MNEUM EQ 'DHEMI'
    INNER JOIN ZHMS_TB_DOCMN AS G ON A~CHAVE = G~CHAVE AND G~MNEUM EQ 'CFOP'
    INTO TABLE t_docmn
   WHERE
    a~MNEUM EQ 'CFOP' AND a~VALUE EQ '1915/AA'
    AND B~VALUE IN S_NF
    AND c~value in S_CLIENT
    and d~value in s_codmat.

  IF SY-SUBRC EQ 0.
    IF t_docmn IS NOT INITIAL.
      PERFORM F_SEL_DADOS.

      PERFORM F_MONTA_REPORT.
    ENDIF.

  endif.

FORM F_SEL_DADOS.

  SELECT SINGLE ID
    INTO V_ICON_GREEN
    FROM ICON
    WHERE NAME = 'ICON_GREEN_LIGHT'.

  SELECT SINGLE ID
   INTO V_ICON_YELLOW
   FROM ICON
   WHERE NAME = 'ICON_YELLOW_LIGHT'.

  SELECT SINGLE ID
    INTO V_ICON_RED
    FROM ICON
    WHERE NAME = 'ICON_RED_LIGHT'.

  data: days TYPE I.
  LOOP AT T_DOCMN INTO WA_DOCMN.
    clear days.

    WA_DOCMN-MHOJE = SY-DATUM.
    MODIFY T_DOCMN FROM WA_DOCMN TRANSPORTING MHOJE.

    CONCATENATE WA_DOCMN-mdhemi+0(4)  WA_DOCMN-mdhemi+5(2) WA_DOCMN-mdhemi+8(2) into WA_DOCMN-mdatafor.
    MODIFY T_DOCMN FROM WA_DOCMN TRANSPORTING mdatafor.

    CALL FUNCTION 'HR_99S_INTERVAL_BETWEEN_DATES'
      EXPORTING
        begda = WA_DOCMN-mdatafor
        endda = WA_DOCMN-MHOJE
      IMPORTING
        days  = days.

    wa_docmn-mdias = days.
    MODIFY T_DOCMN FROM WA_DOCMN TRANSPORTING mdias.

    SELECT SINGLE * FROM J_1BNFDOC INTO CORRESPONDING FIELDS OF WA_J1BNFDOC WHERE NFNUM EQ wa_docmn-mnnf .


      wa_docmn-mdocref = wa_j1bnfdoc-docref.
      wa_docmn-mdataenvio = wa_j1bnfdoc-credat.
      wa_docmn-mdocnum = wa_j1bnfdoc-docnum.

      if wa_docmn-mdocref is initial.
        wa_docmn-mstatus = 'Pendente'.
        else.
          wa_docmn-mstatus = 'Concluido'.
        endif.
      if days < 150.
      wa_docmn-mfarol = V_ICON_GREEN.
      elseif days > 150 and days < 180.
        wa_docmn-mfarol = V_ICON_YELLOW.
       else.
        wa_docmn-mfarol = V_ICON_RED.
      endif.
      modify t_docmn from wa_docmn transporting mdocref mdataenvio mdocnum mstatus mfarol.



  ENDLOOP.

ENDFORM.



FORM F_MONTA_REPORT.

  wa_fieldcat-fieldname = 'MFAROL'.
  wa_fieldcat-seltext_m = 'Farol'.
  APPEND wa_fieldcat TO it_fieldcat.

  wa_fieldcat-fieldname = 'MCNPJ'.
  wa_fieldcat-seltext_m = 'CNPJ Emissor'.
  APPEND wa_fieldcat TO it_fieldcat.


  wa_fieldcat-fieldname = 'MNNF'.
  wa_fieldcat-seltext_m = 'Número da NF'.
  APPEND wa_fieldcat TO it_fieldcat.

  wa_fieldcat-fieldname = 'MDATAFOR'.
  wa_fieldcat-seltext_m = 'Data Recebimento'.
  APPEND wa_fieldcat TO it_fieldcat.

  wa_fieldcat-fieldname = 'MITEM'.
  wa_fieldcat-seltext_m = 'Material'.
  APPEND wa_fieldcat TO it_fieldcat.

  wa_fieldcat-fieldname = 'MCPROD'.
  wa_fieldcat-seltext_m = 'Cód. Material'.
  APPEND wa_fieldcat TO it_fieldcat.

  wa_fieldcat-fieldname = 'MQTDE'.
  wa_fieldcat-seltext_m = 'Qtde.'.
  APPEND wa_fieldcat TO it_fieldcat.

  wa_fieldcat-fieldname = 'MCFOP'.
  wa_fieldcat-seltext_m = 'CFOP'.
  APPEND wa_fieldcat TO it_fieldcat.

  wa_fieldcat-fieldname = 'MDIAS'.
  wa_fieldcat-seltext_m = 'Dias'.
  APPEND wa_fieldcat TO it_fieldcat.

  wa_fieldcat-fieldname = 'MDOCREF'.
  wa_fieldcat-seltext_m = 'Doc. Ref.'.
  APPEND wa_fieldcat TO it_fieldcat.

  wa_fieldcat-fieldname = 'MDATAENVIO'.
  wa_fieldcat-seltext_m = 'Data Envio'.
  APPEND wa_fieldcat TO it_fieldcat.

  wa_fieldcat-fieldname = 'MDOCNUM'.
  wa_fieldcat-seltext_m = 'Doc. Num.'.
  APPEND wa_fieldcat TO it_fieldcat.

  wa_fieldcat-fieldname = 'MSTATUS'.
  wa_fieldcat-seltext_m = 'Status'.
  APPEND wa_fieldcat TO it_fieldcat.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      it_fieldcat   = it_fieldcat
    TABLES
      t_outtab      = T_DOCMN
    EXCEPTIONS
      program_error = 1
      OTHERS        = 2.
ENDFORM.



"  loop at t_docmn into wa_docmn.
"  write:  'Chave:' , wa_docmn-mchave.
" write:  'CNPJ:', wa_docmn-mcnpj.
" write:  'Número:' , wa_docmn-mnnf, wa_docmn-mxprod, wa_docmn-mitem, WA_DOCMN-MQTDE.


" endloop.
