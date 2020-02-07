REPORT zhms_limpa_chave .

*RCP - Tradução EN/ES - 13/08/2018

* teste david
PARAMETER v_chave TYPE zhms_de_chave.
CHECK NOT v_chave IS INITIAL.

DELETE FROM zhms_tb_hrvalid WHERE chave EQ v_chave.
*COMMIT WORK AND WAIT.

IF NOT  sy-subrc IS INITIAL.
  WRITE 'erro zhms_tb_hrvalid'.
ENDIF.

DELETE FROM zhms_tb_hvalid WHERE chave EQ v_chave.
*COMMIT WORK AND WAIT.

IF NOT sy-subrc IS  INITIAL.
  WRITE 'erro zhms_tb_hvalid'.
ENDIF.

DELETE FROM zhms_tb_flwdoc WHERE chave EQ v_chave.
*COMMIT WORK AND WAIT.
IF NOT sy-subrc IS  INITIAL.
  WRITE 'erro zhms_tb_flwdoc'.
ENDIF.

DELETE FROM zhms_tb_itmatr WHERE chave EQ v_chave.
*COMMIT WORK AND WAIT.
IF NOT sy-subrc IS  INITIAL.
  WRITE 'erro zhms_tb_itmatr'.
ENDIF.

DELETE FROM zhms_tb_logdoc WHERE chave EQ v_chave.
*COMMIT WORK AND WAIT.
IF NOT sy-subrc IS  INITIAL.
  WRITE 'erro zhms_tb_logdoc'.
ENDIF.

DELETE FROM zhms_tb_docconf WHERE chave EQ v_chave.
*COMMIT WORK AND WAIT.

IF NOT sy-subrc IS  INITIAL.
  WRITE 'erro zhms_tb_docconf'.
ENDIF.

DELETE FROM zhms_tb_datconf WHERE chave EQ v_chave.
*COMMIT WORK AND WAIT.

IF NOT sy-subrc IS INITIAL.
  WRITE 'erro zhms_tb_datconf'.
ENDIF.

DELETE FROM zhms_tb_docrcbto WHERE chave EQ v_chave.
*COMMIT WORK AND WAIT.

IF NOT sy-subrc IS  INITIAL.
  WRITE 'erro zhms_tb_docrcbto'.
ENDIF.

DELETE FROM zhms_tb_datrcbto WHERE chave EQ v_chave.
*COMMIT WORK AND WAIT.
IF NOT sy-subrc IS  INITIAL.
  WRITE 'erro zhms_tb_datrcbto'.
ENDIF.


*DELETE FROM zhms_tb_docmn WHERE chave EQ v_chave
*              AND ( mneum EQ 'ATITMPED'
*              OR mneum EQ 'ATQTD'
*              OR mneum EQ 'ATUM'
*              OR mneum EQ 'ATPED'
*              OR mneum EQ 'ATITMXML'
*              OR mneum EQ 'ATITMPROC'
*              OR mneum EQ 'ATTLOT'
*              OR mneum EQ 'ATQTDE'
*              OR mneum EQ 'ATVCOFINS'
*              OR mneum EQ 'ATVICMS'
*              OR mneum EQ 'ATVIPI'
*              OR mneum EQ 'ATVPIS'
*              OR mneum EQ 'ATVLR'
*              OR mneum EQ 'ATQTD'
*              OR mneum EQ 'ATUM'
*              OR mneum EQ 'ATPED'
*              OR mneum EQ 'ATITMXML'
*              OR mneum EQ 'ATITMPROC'
*              OR mneum EQ 'ATTLOT'
*              OR mneum EQ 'ATQTDE'
*              OR mneum EQ 'ATVCOFINS'
*              OR mneum EQ 'ATVICMS'
*              OR mneum EQ 'ATVIPI'
*              OR mneum EQ 'ATVPIS'
*              OR mneum EQ 'ATVLR'
*              OR mneum EQ 'INVDOCNO'
*              OR mneum EQ 'FISCALYEAR'
*              OR mneum EQ 'MATDOC'
*              OR mneum EQ 'MATDOCYEA'
*              OR mneum EQ 'INVDOCNOES'
*              OR mneum EQ 'MATDOCEST'
*              OR mneum EQ 'MATDOCYEST'
*              OR MNEUM EQ 'ATUM'
*              OR MNEUM EQ 'ATPED'
*              OR MNEUM EQ 'ATITMPED'
*              OR MNEUM EQ 'ATITMXML'
*              OR MNEUM EQ 'ATITMPROC'
*              OR MNEUM EQ 'ATVLR'
*              OR MNEUM EQ 'AEXTLOT'
*              OR MNEUM EQ 'DATAPROD'
*              OR MNEUM EQ 'DATAVENC'
*              OR MNEUM EQ 'ATTLOT'
*              OR MNEUM EQ 'ATITMXML'
*              OR MNEUM EQ 'ATITMPED'
*              OR MNEUM EQ 'ATQTDE'
*              OR MNEUM EQ 'ATVCOFINS'
*              OR MNEUM EQ 'ATVCOFINSS'
*              OR MNEUM EQ 'ATCRICMSST'
*              OR MNEUM EQ 'ATDESC'
*              OR MNEUM EQ 'ATFRT'
*              OR MNEUM EQ 'ATVICMS'
*              OR MNEUM EQ 'ATVICMSST'
*              OR MNEUM EQ 'ATICMSSDES'
*              OR MNEUM EQ 'ATICMSSRET'
*              OR MNEUM EQ 'ATVII'
*              OR MNEUM EQ 'ATVIOF'
*              OR MNEUM EQ 'ATVIPI'
*              OR MNEUM EQ 'ATVISSQN'
*              OR MNEUM EQ 'ATDESPAC'
*              OR MNEUM EQ 'ATVPIS'
*              OR MNEUM EQ 'ATVPISST'
*              OR MNEUM EQ 'ATVLR'
*              OR MNEUM EQ 'ATSEG'
*              OR MNEUM EQ 'NCM'
*              OR MNEUM EQ 'ATPED'
*              OR MNEUM EQ 'MATDOC'
*              OR MNEUM EQ 'FISCALYEAR'
*              OR MNEUM EQ 'MATDOCYEA'
*              OR MNEUM = 'ACTIVITY'
*              OR MNEUM = 'ASSETNO'
*              OR MNEUM = 'BUDGPERIOD'
*              OR MNEUM = 'BUSAREA'
*              OR MNEUM = 'CMMTITEM'
*              OR MNEUM = 'CMMTITMLON'
*              OR MNEUM = 'COAREA'
*              OR MNEUM = 'COSTCENTER'
*              OR MNEUM = 'COSTCTR'
*              OR MNEUM = 'COSTOBJ'
*              OR MNEUM = 'CUSTOMER'
*              OR MNEUM = 'DELIVITEM'
*              OR MNEUM = 'DELIVNUMB'
*              OR MNEUM = 'DISTRPERC'
*              OR MNEUM = 'ENRYUOMISO'
*              OR MNEUM = 'FUNAREALON'
*              OR MNEUM = 'FUNCAREA'
*              OR MNEUM = 'FUND'
*              OR MNEUM = 'FUNDSCTR'
*              OR MNEUM = 'FUNDSRES'
*              OR MNEUM = 'GLACCOUNT'
*              OR MNEUM = 'GLACCT'
*              OR MNEUM = 'GRANTNBR'
*              OR MNEUM = 'GRRCPT'
*              OR MNEUM = 'MATDOCYEA'
*              OR MNEUM = 'MATERIAL'
*              OR MNEUM = 'MATLGROUP'
*              OR MNEUM = 'MATLUSAGE'
*              OR MNEUM = 'MATORIGIN'
*              OR MNEUM = 'MVTIND'
*              OR MNEUM = 'NBSLIPS'
*              OR MNEUM = 'NETPRICE'
*              OR MNEUM = 'NETWORK'
*              OR MNEUM = 'ORDERID'
*              OR MNEUM = 'ORDERNO'
*              OR MNEUM = 'PARTACCT'
*              OR MNEUM = 'PLANT'
*              OR MNEUM = 'PROFITCTR'
*              OR MNEUM = 'PROFSEGM'
*              OR MNEUM = 'PROFSEGMNO'
*              OR MNEUM = 'PROJEXT'
*              OR MNEUM = 'QUANTITY'
*              OR MNEUM = 'RECIND'
*              OR MNEUM = 'REFDATE'
*              OR MNEUM = 'RESITEM'
*              OR MNEUM = 'RLESTKEY'
*              OR MNEUM = 'ROUTINGNO'
*              OR MNEUM = 'SCHEDLINE'
*              OR MNEUM = 'SDDOC'
*              OR MNEUM = 'SDOCITEM'
*              OR MNEUM = 'SERIALNO'
*              OR MNEUM = 'STGELOC'
*              OR MNEUM = 'SUBNUMBER'
*              OR MNEUM = 'TAXCODE'
*              OR MNEUM = 'TAXJURCODE'
*              OR MNEUM = 'TOCOSTCTR'
*              OR MNEUM = 'TOORDER'
*              OR MNEUM = 'TOPROJECT'
*              OR MNEUM = 'VALTYPE'
*              OR MNEUM = 'VENDOR'
*              OR MNEUM = 'WBSELEM'
*              OR MNEUM = 'WBSELEME' ).

IF NOT sy-subrc IS  INITIAL.
  WRITE 'erro ao apagar ZHMS_TB_DOCMN'.
ENDIF.

UPDATE zhms_tb_docst SET sthms = 2
stent = 3
strec = 0
WHERE chave EQ v_chave.
*COMMIT WORK AND WAIT.

DELETE FROM zhms_tb_docmn_hs WHERE chave EQ v_chave.

IF sy-subrc IS INITIAL.
*  COMMIT WORK.
ENDIF.

WRITE 'registros apagados'.
