FUNCTION ZHMS_FM_GET_HTML_DATAENTRY .
*"----------------------------------------------------------------------
*"*"Interface local:
*"  TABLES
*"      SRSCD STRUCTURE  ZHMS_ST_HTML_SRSCD OPTIONAL
*"      DATASRC STRUCTURE  ZHMS_ST_HTML_SRSCD OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
*" RCP - Tradução EN/ES - 30/08/2018

* Constante de Código - Quantidade de Mneumonicos gerados
data: vl_qtdmn type i value 1000.

*Inicio HTML
  APPEND: '<html class="no-js" lang="en">' TO srscd,
          '<head>' TO srscd,
          '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />' TO srscd,
          '<title>Documento sem título</title>' TO srscd,
          '<style type="text/css">' TO srscd,
          'body {' TO srscd,
          ' margin: 0px;' TO srscd,
          '	overflow: hidden;' TO srscd,
          '	border: 0px solid;' TO srscd,
          ' background-color: #EAF0F6;' TO srscd,
          ' font-family: Arial, Helvetica, sans-serif;' TO srscd,
          ' font-size: 12px;' TO srscd,
          ' color: #666;' TO srscd,
          '}' TO srscd,

          'td {' TO srscd,
          ' font-family: Arial, Helvetica, sans-serif;' TO srscd,
          ' font-size: 12px;' TO srscd,
          ' color: #666;' TO srscd,
          '}' TO srscd,

          '.group {' TO srscd,
          'border: 1px solid #9EB0C2;' TO srscd,
          'padding: 2px;' TO srscd,
          'background-color: #DFEAF5;' TO srscd,
          '}' TO srscd,

          '.subgroup {' TO srscd,
          'border: 1px solid #FFF;' TO srscd,
          'margin: 10px;' TO srscd,
*          'margin-left: 10px;' TO srscd,
*          'margin-right: 10px;' TO srscd,
          'padding: 2px;' TO srscd,
          '}' TO srscd,

          '.group_title {' TO srscd,
          'border: 1px solid #9EB0C2;' TO srscd,
          'padding-left: 8px;' TO srscd,
          'background-color: #C4D7EB;' TO srscd,
          '}' TO srscd,

          '.subgroup_title {' TO srscd,
*          'border: 1px solid #FFF;' TO srscd,
*          'padding-left: 8px;' TO srscd,
*          'margin-left: 10px;' TO srscd,
*          'margin-right: 10px;' TO srscd,
          'background-color: #CEDDEC;' TO srscd,
          '}' TO srscd,

          '</style>' TO srscd,
          '</head>' TO srscd,
          '<body>' TO srscd,
          '<div class="group_title">Dados de Cabeçalho</div>' TO srscd,
          '<div class="group">' TO srscd,
          '<table cellpadding="1" cellspacing="3" border="0" width="99%">' TO srscd,
          '<tr>' TO srscd,
          '<td width="150">Valor Total</td>' TO srscd,
          '<td><input class="field" name="vlrtotal"/></td>' TO srscd,
          '</tr>' TO srscd,
          '<tr>' TO srscd,
          '<td width="150">Valor Total Imposto</td>' TO srscd,
          '<td><input class="field" name="vlrtotal"/></td>' TO srscd,
          '</tr>' TO srscd,
          '</table>' TO srscd,
          '</div>' TO srscd,
          '<br />' TO srscd,
          '<br />' TO srscd,
          '<div class="group_title">Dados de Item</div>' TO srscd,
          '<div class="group">' TO srscd,
          '<table cellpadding="1" cellspacing="1" border="0"  width="95%">' TO srscd,
          '<tr>' TO srscd,
          '<td>Número do Item</td>' TO srscd,
          '<td>Código</td>' TO srscd,
          '<td>Documento Referenciado</td>' TO srscd,
          '<td>Quantidade</td>' TO srscd,
          '<td>Valor Unitário</td>' TO srscd,
          '<td align="center"><span style="cursor:pointer; font-size:16px;"><b>+</b></span></td>' TO srscd,
          '</tr>' TO srscd,
          '<tr>' TO srscd,
          '<td><input class="field" name="vlrtotal"/></td>' TO srscd,
          '<td><input class="field" name="vlrtotal"/></td>' TO srscd,
          '<td><input class="field" name="vlrtotal"/></td>' TO srscd,
          '<td><input class="field" name="vlrtotal"/></td>' TO srscd,
          '<td><input class="field" name="vlrtotal"/></td>' TO srscd,
          '<td align="center"><span style="cursor:pointer; font-size:16px;">-</span></td>' TO srscd,
          '</tr>' TO srscd,
          '</table>' TO srscd,
          '<div class="subgroup">' TO srscd,
          '<div class="subgroup_title">Dados de Imposto do Item</div>' TO srscd,
          '<table cellpadding="0" cellspacing="0" border="0"  width="95%">' TO srscd,
          '<tr>' TO srscd,
          '<td width="170">Código do Imposto</td>' TO srscd,
          '<td>Valor do Imposto</td>' TO srscd,
          '<td align="center"><span style="cursor:pointer; font-size:16px;"><b>+</b></span></td>' TO srscd,
          '</tr>' TO srscd,
          '<tr>' TO srscd,
          '<td width="170"><input class="field" name="vlrtotal"/></td>' TO srscd,
          '<td><input class="field" name="vlrtotal"/></td>' TO srscd,
          '<td align="center"><span style="cursor:pointer; font-size:16px;">-</span></td>' TO srscd,
          '</tr>' TO srscd,
          '</table>' TO srscd,
          '</div>' TO srscd,
          '</div>' TO srscd,
          '</body>' TO srscd,
          '</html>' TO srscd.



ENDFUNCTION.
