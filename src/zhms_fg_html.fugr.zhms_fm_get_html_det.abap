FUNCTION zhms_fm_get_html_det .
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(NOBAR) TYPE  FLAG OPTIONAL
*"  TABLES
*"      SRSCD STRUCTURE  ZHMS_ST_HTML_SRSCD OPTIONAL
*"      DATASRC STRUCTURE  ZHMS_ST_HTML_SRSCD OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
*" RCP - Tradução EN/ES - 30/08/2018

*Inicio HTML
  APPEND: '<html class="no-js" lang="en">' TO srscd,
          '<head>' TO srscd,
          '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />' TO srscd,

**        Estilos do Documento
          '<style type="text/css">' TO srscd,
          'body {' TO srscd,
          ' margin: 0px;' TO srscd,
          '	overflow: hidden;' TO srscd,
          '	border: 0px solid;' TO srscd,
          ' background-color: #EAF0F6;' TO srscd,
          '}' TO srscd,
          '.dc_cenario {' TO srscd,
          '	font-family: Verdana, Geneva, sans-serif;' TO srscd,
          '	font-size: 18px;' TO srscd,
          '	color: #333;' TO srscd,
          ' border: 0px solid;' TO srscd,
          '	background-color: #EAF0F6;' TO srscd,
          '}' TO srscd,
          '.dc_numero{' TO srscd,
          '	font-family: Verdana, Geneva, sans-serif;' TO srscd,
          '	font-size: 18px;' TO srscd,
          '	color: #06C;' TO srscd,
          ' border: 0px solid;' TO srscd,
          '	background-color: #EAF0F6;' TO srscd,
          '}' TO srscd,
          '.dc_topico {' TO srscd,
          '	font-family: Verdana, Geneva, sans-serif;' TO srscd,
          '	font-size: 11px;' TO srscd,
          '	color: #06F;' TO srscd,
          ' border: 0px solid;' TO srscd,
          '	background-color: #EAF0F6;' TO srscd,
          '}' TO srscd,
          '.dc_value {' TO srscd,
          '	font-family: Verdana, Geneva, sans-serif;' TO srscd,
          '	font-size: 11px;' TO srscd,
          '	color: #333;' TO srscd,
          ' border: 0px solid;' TO srscd,
          '	background-color: #EAF0F6;' TO srscd,
          '}' TO srscd,
          '.dc_barr {' TO srscd,
          '	background-image: url(dc_barr.gif);' TO srscd,
          '	background-repeat: repeat-x;' TO srscd,
          '	margin-top: 5px;' TO srscd,
          '}' TO srscd,
          '.dc_imagem{' TO srscd,
          ' margin-top: 6px;' TO srscd,
          '}' TO srscd,
          '.dc_links {' TO srscd,
          '	width: 160;' TO srscd,
          '	height: 27;' TO srscd,
          '	border: 1px solid #999999;' TO srscd,
          '	background-color: #EAF0F6;' TO srscd,
          '}' TO srscd,
          '.dc_linkseparador{' TO srscd,
          '	font-family:Tahoma, Geneva, sans-serif;' TO srscd,
          '	color:#666;' TO srscd,
          '}' TO srscd,

          '.dc_topico_dest {' TO srscd,
          '	font-family: Verdana, Geneva, sans-serif;' TO srscd,
          '	font-size: 14px;' TO srscd,
          '	color: #06F;' TO srscd," #333;' TO srscd,
          ' border: 0px solid;' TO srscd,
          '	background-color: #EAF0F6;' TO srscd,
          '}' TO srscd,

          '.dc_ref {' TO srscd,
          '	font-family: Verdana, Geneva, sans-serif;' TO srscd,
          '	font-size: 9px;' TO srscd,
          '	color: #06F;' TO srscd,
          '}' TO srscd,
          '.dc_refnr{' TO srscd,
          '	font-family: Verdana, Geneva, sans-serif;' TO srscd,
          '	font-size: 9px;' TO srscd,
          '	color: #930;' TO srscd,
          '}' TO srscd,


          '</style>' TO srscd,

**        Função JavaScript para controle das imagens
          '<script language="javascript">' TO srscd,
          '' TO srscd,
          'function seleciona(alvo){' TO srscd,
          '	document.getElementById(''det'').src = "dc_det_norm.gif";' TO srscd,
          '	document.getElementById(''xml'').src = "dc_xml_norm.gif";' TO srscd,
          '	document.getElementById(''pdf'').src = "dc_pdf_norm.gif";' TO srscd,
          '	document.getElementById(''flow'').src = "dc_flow_norm.gif";' TO srscd,
          '	' TO srscd,
          '	document.getElementById(alvo).src = "dc_"+ alvo +"_sele.gif";' TO srscd,
          '}' TO srscd,
          '</script>' TO srscd,

          '</head>' TO srscd.

* Inicio Corpo HTML
  APPEND: '<body>' TO srscd,

**        Detalhes do Documento
          '<table cellpadding="0" cellspacing="1" border="0" width="100%">' TO srscd,
          '  <tr>' TO srscd.

**        Icone de status
          IF nobar IS INITIAL.
            APPEND: '    <td width="10" rowspan="5" valign="top"><div class="dc_imagem" style="display:none;"><img src="" border="0" id="img_status"/></div></td>' TO srscd.
          ELSE.
            APPEND: '    <td width="10" rowspan="5" align="right">&nbsp</td>' TO srscd.
          ENDIF.

  APPEND: '    <td colspan="2"><input type="text" class="dc_numero" id="dc_numero" align="left" readonly="readonly"/></td>' TO srscd,
          '    <td align="right"><div class="dc_ref" id="dc_reftxt"></div><span class="dc_refnr" id="dc_refvlr"></span></td>' TO srscd,
          '  </tr>' TO srscd,
*          '    <td width="120" colspan="2"><input type="text" readonly="readonly" class="dc_topico_dest" id="dc_partnt" size="70"></td>' TO srscd,
*          '  </tr>' TO srscd,
          '    <td width="120"><input type="text" readonly="readonly" id="dc_partnt" class="dc_topico" size="19"></td>' TO srscd,
          '    <td align="left"><input type="text" readonly="readonly" id="dc_partnv" class="dc_value" size="50"></td>' TO srscd,

          '  <tr>' TO srscd,
          '    <td width="120"><input type="text" readonly="readonly" id="dc_dtdoct" class="dc_topico" size="19"></td>' TO srscd,
          '    <td align="left"><input type="text" readonly="readonly" id="dc_dtdocv" class="dc_value" size="50"></td>' TO srscd,
          '  </tr>' TO srscd,
          '  <tr>' TO srscd,
          '    <td width="120"><input type="text" readonly="readonly" id="dc_bukrst" class="dc_topico" size="17"></td>' TO srscd,
          '    <td align="left"><input type="text" readonly="readonly" id="dc_bukrsv" class="dc_value" size="50"></td>' TO srscd,
          '  </tr>' TO srscd,
          '  <tr>' TO srscd,
          '    <td width="120"><input type="text" readonly="readonly" id="dc_brancht" class="dc_topico" size="17"></td>' TO srscd,
          '    <td align="left"><input type="text" readonly="readonly" id="dc_branchv" class="dc_value" size="50"></td>' TO srscd,
          '  </tr>' TO srscd,


          '</table>' TO srscd.

***        Barra de Icones
  IF nobar IS INITIAL.
    APPEND: '<div class="dc_barr" align="center">' TO srscd,
            '  <div class="dc_links">' TO srscd,
            '    <table cellpadding="1" cellspacing="1" width="100%">' TO srscd,
            '      <tr>' TO srscd,

            '        <td align="center" width="25%" valign="bottom"><a href="SAPEVENT:show_det" onClick="seleciona(''det'')" style="cursor:pointer"><img src="dc_det_sele.gif" id="det" border="0" alt="Detalhes"></a></td>' TO srscd,
            '        <td class="dc_linkseparador" valign="middle">|</td>' TO srscd,

            '        <td align="center" width="25%" valign="bottom"><a href="SAPEVENT:show_xml" onClick="seleciona(''xml'')" style="cursor:pointer"><img src="dc_xml_norm.gif" id="xml" border="0" alt="XML"></a></td>' TO srscd,
            '        <td class="dc_linkseparador" valign="middle">|</td>' TO srscd,

            '        <td align="center" width="25%" valign="bottom"><a href="SAPEVENT:show_pdf" onClick="seleciona(''pdf'')" style="cursor:pointer"><img src="dc_pdf_norm.gif" id="pdf" border="0" alt="PDF"></a></td>' TO srscd,
            '        <td class="dc_linkseparador" valign="middle">|</td>' TO srscd,

            '        <td align="center" width="25%" valign="bottom"><a href="SAPEVENT:show_flow" onClick="seleciona(''flow'')" style="cursor:pointer"><img src="dc_flow_norm.gif" id="flow" border="0" alt="Fluxo"></a></td>' TO srscd,

            '      </tr>' TO srscd,
            '    </table>' TO srscd,
            '  </div>' TO srscd,
            '</div>' TO srscd.
  ENDIF.
  IF NOT datasrc[] IS INITIAL.

    APPEND:   '<script language="javascript">' TO srscd.

    LOOP AT datasrc.
      APPEND:   datasrc TO srscd.
    ENDLOOP.

    APPEND:   '</script>' TO srscd.

  ENDIF.

* Fim HTML
  APPEND: '</body>' TO srscd,
          '</html>' TO srscd.


ENDFUNCTION.
