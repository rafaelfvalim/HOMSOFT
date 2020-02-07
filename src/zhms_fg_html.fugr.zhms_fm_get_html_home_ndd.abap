FUNCTION ZHMS_FM_GET_HTML_HOME_NDD .
*"--------------------------------------------------------------------
*"*"Interface local:
*"  TABLES
*"      SRSCD STRUCTURE  ZHMS_ST_HTML_SRSCD OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"--------------------------------------------------------------------
*" RCP - Tradução EN/ES - 30/08/2018

*Inicio HTML
  APPEND: '<html class="no-js" lang="en">' TO srscd,
          '<head>' TO srscd,
          '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />' TO srscd.

*Estilos para página e links
  APPEND: '<style type="text/css">' TO srscd,

          'body {' TO srscd,
          ' margin:0px;' TO srscd,
          ' overflow:hidden;' TO srscd,
          ' border:0px solid;' TO srscd,
          ' background-color:#EAF0F6;' TO srscd,
          '}' TO srscd,

          '.monitor1 {' TO srscd,
          '	height: 100%;' TO srscd,
          '	background-image: url(link_monitor1.gif);' TO srscd,
          '	background-position: center bottom;' TO srscd,
          '	background-repeat: no-repeat;' TO srscd,
          '	cursor: pointer;' TO srscd,
*          ' height: expression(this.scrollHeight >= "500" ? "500" : "auto");' TO srscd,
*          '  max-height: 500px;' TO srscd,
          '}' TO srscd,
          '.monitor2 {' TO srscd,
          '	height: 100%;' TO srscd,
          '	background-image: url(link_monitor2.gif);' TO srscd,
          '	background-position: center bottom;' TO srscd,
          '	background-repeat: no-repeat;' TO srscd,
          '	cursor: pointer;' TO srscd,
*          'height: expression(this.scrollHeight >= "500" ? "500" : "auto");' TO srscd,
*          '  max-height: 500px;' TO srscd,
          '}' TO srscd,
          '.portaria1 {' TO srscd,
          '	height: 100%;' TO srscd,
          '	background-image: url(link_portaria1.gif);' TO srscd,
          '	background-position: center bottom;' TO srscd,
          '	background-repeat: no-repeat;' TO srscd,
          '	cursor: pointer;' TO srscd,
*          'height: expression(this.scrollHeight >= "500" ? "500" : "auto");' TO srscd,
*          '  max-height: 500px;' TO srscd,
          '}' TO srscd,
          '.portaria2 {' TO srscd,
          '	height: 100%;' TO srscd,
          '	background-image: url(link_portaria2.gif);' TO srscd,
          '	background-position: center bottom;' TO srscd,
          '	background-repeat: no-repeat;' TO srscd,
          '	cursor: pointer;' TO srscd,
*          'height: expression(this.scrollHeight >= "500" ? "500" : "auto");' TO srscd,
*          '  max-height: 500px;' TO srscd,
          '}' TO srscd,
          '.conferencia1 {' TO srscd,
          '	height: 100%;' TO srscd,
          '	background-image: url(link_conferencia1.gif);' TO srscd,
          '	background-position: center bottom;' TO srscd,
          '	background-repeat: no-repeat;' TO srscd,
          '	cursor: pointer;' TO srscd,
*          'height: expression(this.scrollHeight >= "500" ? "500" : "auto");' TO srscd,
*          '  max-height: 500px;' TO srscd,
          '}' TO srscd,
          '.conferencia2 {' TO srscd,
          '	height: 100%;' TO srscd,
          '	background-image: url(link_conferencia2.gif);' TO srscd,
          '	background-position: center bottom;' TO srscd,
          '	background-repeat: no-repeat;' TO srscd,
          '	cursor: pointer;' TO srscd,
*          'height: expression(this.scrollHeight >= "500" ? "500" : "auto");' TO srscd,
*          '  max-height: 500px;' TO srscd,
          '}' TO srscd,
          '.relatorios1 {' TO srscd,
          '	height: 100%;' TO srscd,
          '	background-image: url(link_relatorios1.gif);' TO srscd,
          '	background-position: center bottom;' TO srscd,
          '	background-repeat: no-repeat;' TO srscd,
          '	cursor: pointer;' TO srscd,
*          'height: expression(this.scrollHeight >= "500" ? "500" : "auto");' TO srscd,
*          '  max-height: 500px;' TO srscd,
          '}' TO srscd,
          '.relatorios2 {' TO srscd,
          '	height: 100%;' TO srscd,
          '	background-image: url(link_relatorios2.gif);' TO srscd,
          '	background-position: center bottom;' TO srscd,
          '	background-repeat: no-repeat;' TO srscd,
          '	cursor: pointer;' TO srscd,
*          'height: expression(this.scrollHeight >= "500" ? "500" : "auto");' TO srscd,
*          '  max-height: 500px;' TO srscd,
          '}' TO srscd,
          '.config1 {' TO srscd,
          '	height: 100%;' TO srscd,
          '	background-image: url(link_config1.gif);' TO srscd,
          '	background-position: center bottom;' TO srscd,
          '	background-repeat: no-repeat;' TO srscd,
          '	cursor: pointer;' TO srscd,
*          'height: expression(this.scrollHeight >= "500" ? "500" : "auto");' TO srscd,
*          '  max-height: 500px;' TO srscd,
          '}' TO srscd,
          '.config2 {' TO srscd,
          '	height: 100%;' TO srscd,
          '	background-image: url(link_config2.gif);' TO srscd,
          '	background-position: center bottom;' TO srscd,
          '	background-repeat: no-repeat;' TO srscd,
          '	cursor: pointer;' TO srscd,
*          'height: expression(this.scrollHeight >= "500" ? "500" : "auto");' TO srscd,
*          '  max-height: 500px;' TO srscd,
          '}' TO srscd,

          '.dataentry1 {' TO srscd,
          '	height: 100%;' TO srscd,
          '	background-image: url(link_dataentry1.gif);' TO srscd,
          '	background-position: center bottom;' TO srscd,
          '	background-repeat: no-repeat;' TO srscd,
          '	cursor: pointer;' TO srscd,
*          'height: expression(this.scrollHeight >= "500" ? "500" : "auto");' TO srscd,
*          '  max-height: 500px;' TO srscd,
          '}' TO srscd,
          '.dataentry2 {' TO srscd,
          '	height: 100%;' TO srscd,
          '	background-image: url(link_dataentry2.gif);' TO srscd,
          '	background-position: center bottom;' TO srscd,
          '	background-repeat: no-repeat;' TO srscd,
          '	cursor: pointer;' TO srscd,
*          'height: expression(this.scrollHeight >= "500" ? "500" : "auto");' TO srscd,
*          '  max-height: 500px;' TO srscd,
          '}' TO srscd,



          '.txt_desc {' TO srscd,
          '	font-family: Tahoma, Geneva, sans-serif;' TO srscd,
          '	font-size: 70px;' TO srscd,
          '	color: #999;' TO srscd,
          '}' TO srscd,

          '#tudo {' TO srscd,
          '	position: relative;' TO srscd,
          '	}' TO srscd,

          '#rodape {' TO srscd,
          '	position: absolute;' TO srscd,
          '	bottom: 0;' TO srscd,


          '</style>' TO srscd.

** Funções JS
  APPEND: '<script language="javascript">' TO srscd,
          'function altera2(field){' TO srscd,
          '	var div = "link_" + field;' TO srscd,
          '	var newclass = field + "2";' TO srscd,
          '	' TO srscd,
          '	document.getElementById(div).className = newclass;' TO srscd,
          '	showtxt(field);' TO srscd,
          '}' TO srscd,
          'function altera1(field){' TO srscd,
          '	var div = "link_" + field;' TO srscd,
          '	var newclass = field + "1";' TO srscd,
          '	' TO srscd,
          '	document.getElementById(div).className = newclass;' TO srscd,
          '	document.getElementById("descricao").innerHTML = "<img src=''GSW Logo'' />";' TO srscd,
          '}' TO srscd,
          '' TO srscd,
          'function showtxt(field){' TO srscd,
          '	' TO srscd,
          '	var texto;' TO srscd,
          '	' TO srscd,
          '	if(field == "monitor") texto     = "Monitor";' TO srscd,
          '	if(field == "portaria") texto    = "Portaria";' TO srscd,
          '	if(field == "conferencia") texto = "Confer&ecirc;ncia";' TO srscd,
          '	if(field == "relatorios") texto  = "Relat&oacute;rios";' TO srscd,
          '	if(field == "config") texto  = "Configura&ccedil;&otilde;es";' TO srscd,
          '	if(field == "dataentry") texto  = "Entrada&nbsp;Manual";' TO srscd,
          '	' TO srscd,
          '  document.getElementById("descricao").innerHTML = texto;' TO srscd,
          '}' TO srscd,
          'function envia(field){' TO srscd,
          '	if(field == "monitor") document.form_monitor.submit();' TO srscd,
          '	if(field == "portaria") document.form_portaria.submit();' TO srscd,
          '	if(field == "conferencia") document.form_conferencia.submit();' TO srscd,
          '	if(field == "relatorios") document.form_relatorios.submit();' TO srscd,
          '	if(field == "config") document.form_config.submit();' TO srscd,
          '	if(field == "dataentry") document.form_dataentry.submit();' TO srscd,
          '}' TO srscd,
          '</script>' TO srscd.

  APPEND: '</head>' TO srscd.


* Inicio Corpo HTML
  APPEND: '<body>' TO srscd.


  APPEND: '<div id="tudo"><table cellpadding="0" cellspacing="0" border="0" width="100%" style="height: 65%;">' TO srscd,
          '  <tr>' TO srscd,
          '    <td align="center" valign="top"><div id="link_monitor" class="monitor1" onMouseOver="altera2(''monitor'');" onMouseOut="altera1(''monitor'')" onclick="envia(''monitor'');"></div></td>' TO srscd,
          '    <td align="center" valign="top"><div id="link_dataentry" class="dataentry1" onMouseOver="altera2(''dataentry'');" onMouseOut="altera1(''dataentry'')" onclick="envia(''dataentry'');"></div></td>' TO srscd,
          '    <td align="center" valign="top"><div id="link_portaria" class="portaria1" onMouseOver="altera2(''portaria'');" onMouseOut="altera1(''portaria'')" onclick="envia(''portaria'');"></div></td>' TO srscd,
          '    <td align="center" valign="top"><div id="link_conferencia" class="conferencia1" onMouseOver="altera2(''conferencia'');" onMouseOut="altera1(''conferencia'')" onclick="envia(''conferencia'');"></div></td>' TO srscd,
          '    <td align="center" valign="top"><div id="link_relatorios" class="relatorios1" onMouseOver="altera2(''relatorios'');" onMouseOut="altera1(''relatorios'')" onclick="envia(''relatorios'');"></div></td>' TO srscd,
          '    <td align="center" valign="top"><div id="link_config" class="config1" onMouseOver="altera2(''config'');" onMouseOut="altera1(''config'')" onclick="envia(''config'');"></div></td>' TO srscd,
          '  </tr>' TO srscd,
          '</table>' TO srscd,
          '<div><br /></div>' TO srscd.

  APPEND: '<div id="rodape" style="width:100%;">' TO srscd,
          '<div id="descricao" class="txt_desc" align="center"><img src="GSW Logo" /></div>' TO srscd,
          '</div>' TO srscd,
          '</div>' TO srscd.

** Formularios de evento
  APPEND: '<form name= "form_monitor" action="SAPEVENT:MONITOR" STYLE="margin: 0px; padding:0px;" method="POST"></form>' TO srscd.
  APPEND: '<form name= "form_portaria" action="SAPEVENT:PORTARIA" STYLE="margin: 0px; padding:0px;" method="POST"></form>' TO srscd.
  APPEND: '<form name= "form_conferencia" action="SAPEVENT:CONFERENCIA" STYLE="margin: 0px; padding:0px;" method="POST"></form>' TO srscd.
  APPEND: '<form name= "form_relatorios" action="SAPEVENT:RELATORIOS" STYLE="margin: 0px; padding:0px;" method="POST"></form>' TO srscd.
  APPEND: '<form name= "form_config" action="SAPEVENT:CONFIG" STYLE="margin: 0px; padding:0px;" method="POST"></form>' TO srscd.
  APPEND: '<form name= "form_dataentry" action="SAPEVENT:DATAENTRY" STYLE="margin: 0px; padding:0px;" method="POST"></form>' TO srscd.

* Fim HTML
  APPEND: '</body>' TO srscd,
          '</html>' TO srscd.


*  refresh srscd.
*
*  APPEND: '<html>' TO srscd,
*          '  <head>' TO srscd,
*          '    <!--Load the AJAX API-->' TO srscd,
*          '    <script type="text/javascript" src="https://www.google.com/jsapi"></script>' TO srscd,
*          '    <script type="text/javascript">' TO srscd,
*          '' TO srscd,
**          '      // Load the Visualization API and the piechart package.' TO srscd,
*          '      google.load(''visualization'', ''1.0'', {''packages'':[''corechart'']});' TO srscd,
*          '' TO srscd,
**          '      // Set a callback to run when the Google Visualization API is loaded.' TO srscd,
*          '      google.setOnLoadCallback(drawChart);' TO srscd,
*          '' TO srscd,
**          '      // Callback that creates and populates a data table,' TO srscd,
**          '      // instantiates the pie chart, passes in the data and' TO srscd,
**          '      // draws it.' TO srscd,
*          '      function drawChart() {' TO srscd,
*          '' TO srscd,
**          '        // Create the data table.' TO srscd,
*          '        var data = new google.visualization.DataTable();' TO srscd,
*          '        data.addColumn(''string'', ''Topping'');' TO srscd,
*          '        data.addColumn(''number'', ''Slices'');' TO srscd,
*          '        data.addRows([' TO srscd,
*          '          [''Mushrooms'', 3],' TO srscd,
*          '          [''Onions'', 1],' TO srscd,
*          '          [''Olives'', 1],' TO srscd,
*          '          [''Zucchini'', 1],' TO srscd,
*          '          [''Pepperoni'', 2]' TO srscd,
*          '        ]);' TO srscd,
*          '' TO srscd,
**          '        // Set chart options' TO srscd,
*          '        var options = {''title'':''How Much Pizza I Ate Last Night'',' TO srscd,
*          '                       ''width'':400,' TO srscd,
*          '                       ''height'':300};' TO srscd,
*          '' TO srscd,
**          '        // Instantiate and draw our chart, passing in some options.' TO srscd,
*          '        var chart = new google.visualization.PieChart(document.getElementById(''chart_div''));' TO srscd,
*          '        chart.draw(data, options);' TO srscd,
*          '      }' TO srscd,
*          '    </script>' TO srscd,
*          '  </head>' TO srscd,
*          '' TO srscd,
*          '  <body>' TO srscd,
*          '    <!--Div that will hold the pie chart-->' TO srscd,
*          '    <div id="chart_div"></div>' TO srscd,
*          '  </body>' TO srscd,
*          '</html>' TO srscd.

ENDFUNCTION.
