FUNCTION zhms_fm_get_html_recp .
*"----------------------------------------------------------------------
*"*"Interface local:
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
          '	margin: 0px;' TO srscd,
          '	overflow: hidden;' TO srscd,
          '	border: 0px solid;' TO srscd,
          '	background-color: #EAF0F6;' TO srscd,
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
          '	font-size: 20px;' TO srscd,
          '	color: #1100FF;' TO srscd,
          ' border: 0px solid;' TO srscd,
          '	background-color: #EAF0F6;' TO srscd,
          '}' TO srscd,

          '.dc_topico {' TO srscd,
          '	font-family: Verdana, Geneva, sans-serif;' TO srscd,
          '	font-size: 12px;' TO srscd,
          '	color: #06F;' TO srscd,
          ' border: 0px solid;' TO srscd,
          '	background-color: #EAF0F6;' TO srscd,
          '}' TO srscd,

          '.dc_topico_dest {' TO srscd,
          '	font-family: Verdana, Geneva, sans-serif;' TO srscd,
          '	font-size: 14px;' TO srscd,
          '	color: #06F;' TO srscd," #333;' TO srscd,
          ' border: 0px solid;' TO srscd,
          '	background-color: #EAF0F6;' TO srscd,
          '}' TO srscd,

          '.dc_value {' TO srscd,
          '	font-family: Verdana, Geneva, sans-serif;' TO srscd,
          '	font-size: 12px;' TO srscd,
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

          '.txt {' TO srscd,
          '	font-family: Verdana, Geneva, sans-serif;' TO srscd,
          '	font-size: 12px;' TO srscd,
          '	color: #666;' TO srscd,
          '	border: 0px solid;' TO srscd,
          '}' TO srscd,

          '.recebida{' TO srscd,
          '	font-family: "Lucida Sans Unicode", "Lucida Grande", sans-serif' TO srscd,
          '	font-size: 16px;' TO srscd,
          '	color: #990000;' TO srscd,
          '	border: 0px solid;' TO srscd,
          '	text-decoration:blink;' TO srscd,
          '}' TO srscd,

          '.obs_value {' TO srscd,
          '	font-family: Arial;' TO srscd,
          '	font-size: 13px;' TO srscd,
          '	color: #3600D9;' TO srscd,
          '	margin-left: 15px;' TO srscd,
          '}' TO srscd,

          '.disabled {' TO srscd,
          '	font-family: Verdana, Geneva, sans-serif;' TO srscd,
          '	font-size: 12px;' TO srscd,
          '	color: #3600D9;' TO srscd,
          '	border: 2px solid #DDD;' TO srscd,
          ' background: #EEE;' TO srscd,
          '}' TO srscd,

          '.txt_input {' TO srscd,
          '	font-family: Verdana, Geneva, sans-serif;' TO srscd,
          '	font-size: 12px;' TO srscd,
          '	color: #666;' TO srscd,
          '	border: 2px solid #DDD;' TO srscd,
          '}' TO srscd,

          '.erro_input {' TO srscd,
          '	font-family: Verdana, Geneva, sans-serif;' TO srscd,
          '	font-size: 12px;' TO srscd,
          '	color: #666;' TO srscd,
          '	border: 2px solid #FF0000;' TO srscd,
          '}' TO srscd,

          '.certo_input {' TO srscd,
          '	font-family: Verdana, Geneva, sans-serif;' TO srscd,
          '	font-size: 12px;' TO srscd,
          '	color: #666;' TO srscd,
          '	border: 2px solid #00D96D;' TO srscd,
          '}' TO srscd,

          '.hide{' TO srscd,
          'display: none;' TO srscd,
          'visibility: hidden;' TO srscd,
          '}' TO srscd,

          '.show{' TO srscd,
          'display: block;' TO srscd,
          'visibility: visible;' TO srscd,
          '}' TO srscd,

          '.btn_confirma {' TO srscd,
          '	font-family: Calibri;' TO srscd,
          '	font-size: 20px;' TO srscd,
          '	color: #FFF;' TO srscd,
          '	border: 1px solid #000000;' TO srscd,
          ' background: #008C00;' TO srscd,
          ' width: 180px;' TO srscd,
          'display: block;' TO srscd,
          'visibility: visible;' TO srscd,
          '}' TO srscd,

          '.btn_cancela{' TO srscd,
          '	font-family: Calibri;' TO srscd,
          '	font-size: 18px;' TO srscd,
          '	color: #FFF;' TO srscd,
          '	border: 1px solid #000000;' TO srscd,
          ' background: #FF0000;' TO srscd,
          ' width: 140px;' TO srscd,
          'display: block;' TO srscd,
          'visibility: visible;' TO srscd,
          '}' TO srscd,

*** Icnicio David Rosin
          '.btn_consulta{' TO srscd,
          '	font-family: Calibri;' TO srscd,
          '	font-size: 18px;' TO srscd,
          '	color: #FFF;' TO srscd,
          '	border: 1px solid #000000;' TO srscd,
          ' background: #32CD32;' TO srscd,
          ' width: 140px;' TO srscd,
          'display: block;' TO srscd,
          'visibility: visible;' TO srscd,
          '}' TO srscd,
*** Fim David Rosin

          '</style>' TO srscd,


* Funçoes Javascript

          '<script language="javascript">' TO srscd,

          'function exibe_default(){' TO srscd,
         '  document.getElementById("default").className = "show";' TO srscd,
          '}' TO srscd,

          'function limpa_nota(){' TO srscd,
          'dc_numero.innerText='''';' TO srscd,
          'dc_dtdoct.innerText='''';' TO srscd,
          'dc_dtdocv.innerText='''';' TO srscd,
          'dc_partnt.innerText='''';' TO srscd,
          'dc_partnv.innerText='''';' TO srscd,
          'dc_bukrst.innerText='''';' TO srscd,
          'dc_bukrsv.innerText='''';' TO srscd,
          'dc_brancht.innerText='''';' TO srscd,
          'dc_branchv.innerText='''';' TO srscd,
          'recp_status.innerHTML='''';' TO srscd,
          '}' TO srscd,

          'function limpa_mneums(){' TO srscd,
**        Esconde Desc
          '  document.getElementById("mneumonicos").className = "hide";' TO srscd,
          '  document.getElementById("observacoes").className = "hide";' TO srscd,
          '  document.getElementById("default").className = "hide";' TO srscd,
**        Esconde Itens
          '  document.getElementById("mneumonico1_div").className = "hide";' TO srscd,
          '  document.getElementById("mneumonico2_div").className = "hide";' TO srscd,
          '  document.getElementById("mneumonico3_div").className = "hide";' TO srscd,
          '  document.getElementById("mneumonico4_div").className = "hide";' TO srscd,
          '  document.getElementById("mneumonico5_div").className = "hide";' TO srscd,
          '  document.getElementById("mneumonico6_div").className = "hide";' TO srscd,
          '  document.getElementById("mneumonico7_div").className = "hide";' TO srscd,
          '  document.getElementById("mneumonico8_div").className = "hide";' TO srscd,
          '  document.getElementById("mneumonico9_div").className = "hide";' TO srscd,
          '  document.getElementById("mneumonico10_div").className = "hide";' TO srscd,

**        Limpa mneumonicos
          '  document.getElementById("mneumonico1").value = "";'  TO srscd,
          '  document.getElementById("mneumonico2").value = "";'  TO srscd,
          '  document.getElementById("mneumonico3").value = "";'  TO srscd,
          '  document.getElementById("mneumonico4").value = "";'  TO srscd,
          '  document.getElementById("mneumonico5").value = "";'  TO srscd,
          '  document.getElementById("mneumonico6").value = "";'  TO srscd,
          '  document.getElementById("mneumonico7").value = "";'  TO srscd,
          '  document.getElementById("mneumonico8").value = "";'  TO srscd,
          '  document.getElementById("mneumonico9").value = "";'  TO srscd,
          '  document.getElementById("mneumonico10").value = "";' TO srscd,
          '  document.getElementById("obs").value = "";' TO srscd,

**        Limpa Obrigatoriedade
          '  document.getElementById("obr_1").value = "";' TO srscd,
          '  document.getElementById("obr_2").value = "";' TO srscd,
          '  document.getElementById("obr_3").value = "";' TO srscd,
          '  document.getElementById("obr_4").value = "";' TO srscd,
          '  document.getElementById("obr_5").value = "";' TO srscd,
          '  document.getElementById("obr_6").value = "";' TO srscd,
          '  document.getElementById("obr_7").value = "";' TO srscd,
          '  document.getElementById("obr_8").value = "";' TO srscd,
          '  document.getElementById("obr_9").value = "";' TO srscd,
          '  document.getElementById("obr_10").value = "";' TO srscd,

          '}' TO srscd,

          'function cancelar(){' TO srscd,
          '   document.cancel.submit();' TO srscd,
          '}' TO srscd,

*** Inicio Inclusão David Rosin
          'function consultar(){' TO srscd,
          '   document.consu.submit();' TO srscd,
          '}' TO srscd,
*** Fim Inclusão David Rosin

          'var intervalo = "";' TO srscd,
          'function start_timer(){' TO srscd,
          ' intervalo = window.setInterval(function() {' TO srscd,
          '   document.check.submit();' TO srscd,
          ' }, 5000);' TO srscd,
          '}' TO srscd,


          'function stop_timer(){' TO srscd,
*          'window.setTimeout(function() {' TO srscd,
          'clearInterval(intervalo);' TO srscd,
*          '}, 3000);' TO srscd,
          '}' TO srscd,

**        Insere Mneumonicos
          'function insere_mneum(descricao, mneumonico, obrigatorio, id){' TO srscd,
          '  document.getElementById("mneumonicos").className = "show";' TO srscd,

**        Exibir Campo
          '  var div = "mneumonico" + id + "_div";' TO srscd,
          '  document.getElementById(div).className = "show";' TO srscd,

**        Descrição
          '  var desc = "mn_" + id;' TO srscd,
          '  document.getElementById(desc).innerHTML = descricao;' TO srscd,

**        Obrigatoriedade
          '  var obr = "obr_" + id;' TO srscd,
          '  document.getElementById(obr).value = obrigatorio;' TO srscd,

          '}' TO srscd,

          'function verifica(){' TO srscd,
**        Obrigatoriedade de todos
          "1
          '  var erro = "";' TO srscd,

          '  var obr1 = document.getElementById("obr_1").value;' TO srscd,
          '  var cont1 = document.getElementById("mneumonico1").value;' TO srscd,
          '  if(obr1 == "X"){' TO srscd,
          '   if(cont1.length == 0 ){' TO srscd,
          '     document.getElementById("mneumonico1").className = "erro_input";' TO srscd,
          '     erro = "X";' TO srscd,
          '   }else{' TO srscd,
          '     document.getElementById("mneumonico1").className = "certo_input";' TO srscd,
          '  }}else{' TO srscd,
          '     document.getElementById("mneumonico1").className = "txt_input";' TO srscd,
          '  }' TO srscd,


          '  var obr2 = document.getElementById("obr_2").value;' TO srscd,
          '  var cont2 = document.getElementById("mneumonico2").value;' TO srscd,
          '  if(obr2 == "X"){' TO srscd,
          '   if(cont2.length == 0 ){' TO srscd,
          '     document.getElementById("mneumonico2").className = "erro_input";' TO srscd,
          '     erro = "X";' TO srscd,
          '   }else{' TO srscd,
          '     document.getElementById("mneumonico2").className = "certo_input";' TO srscd,
          '  }}else{' TO srscd,
          '     document.getElementById("mneumonico2").className = "txt_input";' TO srscd,
          '  }' TO srscd,

          '  var obr3 = document.getElementById("obr_3").value;' TO srscd,
          '  var cont3 = document.getElementById("mneumonico3").value;' TO srscd,
          '  if(obr3 == "X"){' TO srscd,
          '   if(cont3.length == 0 ){' TO srscd,
          '     document.getElementById("mneumonico3").className = "erro_input";' TO srscd,
          '     erro = "X";' TO srscd,
          '   }else{' TO srscd,
          '     document.getElementById("mneumonico3").className = "certo_input";' TO srscd,
          '  }}else{' TO srscd,
          '     document.getElementById("mneumonico3").className = "txt_input";' TO srscd,
          '  }' TO srscd,

          '  var obr4 = document.getElementById("obr_4").value;' TO srscd,
          '  var cont4 = document.getElementById("mneumonico4").value;' TO srscd,
          '  if(obr4 == "X"){' TO srscd,
          '   if(cont4.length == 0 ){' TO srscd,
          '     document.getElementById("mneumonico4").className = "erro_input";' TO srscd,
          '     erro = "X";' TO srscd,
          '   }else{' TO srscd,
          '     document.getElementById("mneumonico4").className = "certo_input";' TO srscd,
          '  }}else{' TO srscd,
          '     document.getElementById("mneumonico4").className = "txt_input";' TO srscd,
          '  }' TO srscd,

          '  var obr5 = document.getElementById("obr_5").value;' TO srscd,
          '  var cont5 = document.getElementById("mneumonico5").value;' TO srscd,
          '  if(obr5 == "X"){' TO srscd,
          '   if(cont5.length == 0 ){' TO srscd,
          '     document.getElementById("mneumonico5").className = "erro_input";' TO srscd,
          '     erro = "X";' TO srscd,
          '   }else{' TO srscd,
          '     document.getElementById("mneumonico5").className = "certo_input";' TO srscd,
          '  }}else{' TO srscd,
          '     document.getElementById("mneumonico5").className = "txt_input";' TO srscd,
          '  }' TO srscd,

          '  var obr6 = document.getElementById("obr_6").value;' TO srscd,
          '  var cont6 = document.getElementById("mneumonico6").value;' TO srscd,
          '  if(obr6 == "X"){' TO srscd,
          '   if(cont6.length == 0 ){' TO srscd,
          '     document.getElementById("mneumonico6").className = "erro_input";' TO srscd,
          '     erro = "X";' TO srscd,
          '   }else{' TO srscd,
          '     document.getElementById("mneumonico6").className = "certo_input";' TO srscd,
          '  }}else{' TO srscd,
          '     document.getElementById("mneumonico6").className = "txt_input";' TO srscd,
          '  }' TO srscd,

          '  var obr7 = document.getElementById("obr_7").value;' TO srscd,
          '  var cont7 = document.getElementById("mneumonico7").value;' TO srscd,
          '  if(obr7 == "X"){' TO srscd,
          '   if(cont7.length == 0 ){' TO srscd,
          '     document.getElementById("mneumonico7").className = "erro_input";' TO srscd,
          '     erro = "X";' TO srscd,
          '   }else{' TO srscd,
          '     document.getElementById("mneumonico7").className = "certo_input";' TO srscd,
          '  }}else{' TO srscd,
          '     document.getElementById("mneumonico7").className = "txt_input";' TO srscd,
          '  }' TO srscd,

          '  var obr8 = document.getElementById("obr_8").value;' TO srscd,
          '  var cont8 = document.getElementById("mneumonico8").value;' TO srscd,
          '  if(obr8 == "X"){' TO srscd,
          '   if(cont8.length == 0 ){' TO srscd,
          '     document.getElementById("mneumonico8").className = "erro_input";' TO srscd,
          '     erro = "X";' TO srscd,
          '   }else{' TO srscd,
          '     document.getElementById("mneumonico8").className = "certo_input";' TO srscd,
          '  }}else{' TO srscd,
          '     document.getElementById("mneumonico8").className = "txt_input";' TO srscd,
          '  }' TO srscd,

          '  var obr9 = document.getElementById("obr_9").value;' TO srscd,
          '  var cont9 = document.getElementById("mneumonico9").value;' TO srscd,
          '  if(obr9 == "X"){' TO srscd,
          '   if(cont9.length == 0 ){' TO srscd,
          '     document.getElementById("mneumonico9").className = "erro_input";' TO srscd,
          '     erro = "X";' TO srscd,
          '   }else{' TO srscd,
          '     document.getElementById("mneumonico9").className = "certo_input";' TO srscd,
          '  }}else{' TO srscd,
          '     document.getElementById("mneumonico9").className = "txt_input";' TO srscd,
          '  }' TO srscd,

          '  var obr10 = document.getElementById("obr_10").value;' TO srscd,
          '  var cont10 = document.getElementById("mneumonico10").value;' TO srscd,
          '  if(obr10 == "X"){' TO srscd,
          '   if(cont10.length == 0 ){' TO srscd,
          '     document.getElementById("mneumonico10").className = "erro_input";' TO srscd,
          '     erro = "X";' TO srscd,
          '   }else{' TO srscd,
          '     document.getElementById("mneumonico10").className = "certo_input";' TO srscd,
          '  }}else{' TO srscd,
          '     document.getElementById("mneumonico10").className = "txt_input";' TO srscd,
          '  }' TO srscd,

          '}' TO srscd,

**         Observacoes
          'function insere_obs(texto){' TO srscd,
          '  document.getElementById("observacoes").className = "show";' TO srscd,
          '  document.getElementById("obs_value").innerHTML = primeiraLetraMaiuscula(texto);' TO srscd,
          '}'TO srscd,

**        Primeira letra maiúscula
          'function primeiraLetraMaiuscula(str){ ' TO srscd,
          ' str = str.toLowerCase(); ' TO srscd,
          ' str1 = str.substring(0,1); ' TO srscd,
          ' str = str.replace(str1, str1.toUpperCase()); ' TO srscd,
          ' return str'TO srscd,
          '}'TO srscd,


          '</script>' TO srscd,


          '</head>' TO srscd.

* Inicio Corpo HTML
  APPEND: '<body>' TO srscd,

          '<table cellpadding="0" cellspacing="1" border="0" width="100%" style="height: 100%;">' TO srscd,
          '  <tr>' TO srscd,
          '   <td valign="top">' TO srscd,
          '<div id="dc_document" class="show">' TO srscd,

**        Detalhes do Documento
          '<table cellpadding="0" cellspacing="1" border="0" width="100%">' TO srscd,
          '  <tr>' TO srscd,
*          '    <td colspan="2"><input type="text" class="dc_cenario" id="cenario" />&nbsp;<input type="text" class="dc_numero" id="dc_numero" /></td>' TO srscd,
          '    <td colspan="2"><input type="text" class="dc_numero" id="dc_numero" align="left" readonly="readonly"/><span id="recebida"></span></td>' TO srscd,
          '    <td align="right"><div class="dc_ref" id="dc_reftxt"></div><span class="dc_refnr" id="dc_refvlr"></span></td>' TO srscd,
          '    <td rowspan="6"><div id="recp_status"></div></td>' TO srscd,
          '  </tr>' TO srscd,
          '  <tr>' TO srscd,
*          '    <td width="120" colspan="2"><input type="text" readonly="readonly" class="dc_topico_dest" id="dc_partnt" size="70"></td>' TO srscd,
**          '    <td align="left"><input type="text" readonly="readonly" class="dc_value" id="dc_partnv"></td>' TO srscd,
          '    <td width="120"><input type="text" readonly="readonly" id="dc_partnt" class="dc_topico" size="19"></td>' TO srscd,
          '    <td align="left"><input type="text" readonly="readonly" id="dc_partnv" class="dc_value" size="50"></td>' TO srscd,

          '  </tr>' TO srscd,
          '  <tr>' TO srscd,
          '    <td width="120"><input type="text" readonly="readonly" id="dc_dtdoct" class="dc_topico" size="19"></td>' TO srscd,
          '    <td align="left"><input type="text" readonly="readonly" id="dc_dtdocv" class="dc_value" size="50"></td>' TO srscd,
          '  </tr>' TO srscd,
*          '  <tr>' TO srscd,
*          '    <td width="120"><input type="text" readonly="readonly" id="dc_dtlnct" class="dc_topico" size="17"></td>' TO srscd,
*          '    <td align="left"><input type="text" readonly="readonly" id="dc_dtlncv" class="dc_value" size="17"></td>' TO srscd,
*          '  </tr>' TO srscd,
          '  <tr>' TO srscd,
          '    <td width="120"><input type="text" readonly="readonly" id="dc_bukrst" class="dc_topico" size="17"></td>' TO srscd,
          '    <td align="left"><input type="text" readonly="readonly" id="dc_bukrsv" class="dc_value" size="50"></td>' TO srscd,
          '  </tr>' TO srscd,
          '  <tr>' TO srscd,
          '    <td width="120"><input type="text" readonly="readonly" id="dc_brancht" class="dc_topico" size="17"></td>' TO srscd,
          '    <td align="left"><input type="text" readonly="readonly" id="dc_branchv" class="dc_value" size="50"></td>' TO srscd,
          '  </tr>' TO srscd,

          '</table>' TO srscd,
          '</div>' TO srscd,
          '<div id="dc_resumo" class="hide">' TO srscd,
          '<span id="recebida_res"></span>' TO srscd,
          '<div id="recp_status_res" style="position:absolute; right:10px"></div>' TO srscd,
          '</div>' TO srscd,
          '   </td>' TO srscd,
          '  </tr>' TO srscd,
          '  <tr>' TO srscd,
          '   <td>' TO srscd.

  APPEND :  '<form name="formact" action="SAPEVENT:portaria" STYLE="margin: 0px; padding:0px;" method="POST" onsubmit="verifica();">' TO srscd,

            '<div id="mneumonicos" class="hide">' TO srscd,
            '<p>' TO srscd,
            '<div class="txt" id="txt_nesc"><b>&raquo;</b> Para este documento é necessário informar:</div>' TO srscd,

**          Espaço para Mneumonico 1
            '<div id="mneumonico1_div" class="hide">' TO srscd,
            '	   <table cellpadding="2" cellspacing="0" border="0" width="100%">' TO srscd,
            '  	 <tr>' TO srscd,
            '     <td width="8">&nbsp;</td>' TO srscd,
            '     <td class="txt" width="150"><div id="mn_1"></div><input type="hidden" value="" id="obr_1" /></td>' TO srscd,
            '     <td><input type="text" id="mneumonico1" name="mneumonico1" class="txt_input" /></td>' TO srscd,
            '    </tr>' TO srscd,
            '	   </table>' TO srscd,
            '</div>' TO srscd,

**          Espaço para Mneumonico 2
            '<div id="mneumonico2_div" class="hide">' TO srscd,
            '	   <table cellpadding="2" cellspacing="0" border="0" width="100%">' TO srscd,
            '  	 <tr>' TO srscd,
            '     <td width="8">&nbsp;</td>' TO srscd,
            '     <td class="txt" width="150"><div id="mn_2"></div><input type="hidden" value="" id="obr_2" /></td>' TO srscd,
            '     <td><input type="text" id="mneumonico2" name="mneumonico2" class="txt_input" /></td>' TO srscd,
            '    </tr>' TO srscd,
            '	   </table>' TO srscd,
            '</div>' TO srscd,

**          Espaço para Mneumonico 3
            '<div id="mneumonico3_div" class="hide">' TO srscd,
            '	   <table cellpadding="2" cellspacing="0" border="0" width="100%">' TO srscd,
            '  	 <tr>' TO srscd,
            '     <td width="8">&nbsp;</td>' TO srscd,
            '     <td class="txt" width="150"><div id="mn_3"></div><input type="hidden" value="" id="obr_3" /></td>' TO srscd,
            '     <td><input type="text" id="mneumonico3" name="mneumonico3" class="txt_input" /></td>' TO srscd,
            '    </tr>' TO srscd,
            '	   </table>' TO srscd,
            '</div>' TO srscd,

**          Espaço para Mneumonico 4
            '<div id="mneumonico4_div" class="hide">' TO srscd,
            '	   <table cellpadding="2" cellspacing="0" border="0" width="100%">' TO srscd,
            '  	 <tr>' TO srscd,
            '     <td width="8">&nbsp;</td>' TO srscd,
            '     <td class="txt" width="150"><div id="mn_4"></div><input type="hidden" value="" id="obr_4" /></td>' TO srscd,
            '     <td><input type="text" id="mneumonico4" name="mneumonico4" class="txt_input" /></td>' TO srscd,
            '    </tr>' TO srscd,
            '	   </table>' TO srscd,
            '</div>' TO srscd,

**          Espaço para Mneumonico 5
            '<div id="mneumonico5_div" class="hide">' TO srscd,
            '	   <table cellpadding="2" cellspacing="0" border="0" width="100%">' TO srscd,
            '  	 <tr>' TO srscd,
            '     <td width="8">&nbsp;</td>' TO srscd,
            '     <td class="txt" width="150"><div id="mn_5"></div><input type="hidden" value="" id="obr_5" /></td>' TO srscd,
            '     <td><input type="text" id="mneumonico5" name="mneumonico5" class="txt_input" /></td>' TO srscd,
            '    </tr>' TO srscd,
            '	   </table>' TO srscd,
            '</div>' TO srscd,

**          Espaço para Mneumonico 6
            '<div id="mneumonico6_div" class="hide">' TO srscd,
            '	   <table cellpadding="2" cellspacing="0" border="0" width="100%">' TO srscd,
            '  	 <tr>' TO srscd,
            '     <td width="8">&nbsp;</td>' TO srscd,
            '     <td class="txt" width="150"><div id="mn_6"></div><input type="hidden" value="" id="obr_6" /></td>' TO srscd,
            '     <td><input type="text" id="mneumonico6" name="mneumonico6" class="txt_input" /></td>' TO srscd,
            '    </tr>' TO srscd,
            '	   </table>' TO srscd,
            '</div>' TO srscd,

**          Espaço para Mneumonico 7
            '<div id="mneumonico7_div" class="hide">' TO srscd,
            '	   <table cellpadding="2" cellspacing="0" border="0" width="100%">' TO srscd,
            '  	 <tr>' TO srscd,
            '     <td width="8">&nbsp;</td>' TO srscd,
            '     <td class="txt" width="150"><div id="mn_7"></div><input type="hidden" value="" id="obr_7" /></td>' TO srscd,
            '     <td><input type="text" id="mneumonico7" name="mneumonico7" class="txt_input" /></td>' TO srscd,
            '    </tr>' TO srscd,
            '	   </table>' TO srscd,
            '</div>' TO srscd,

**          Espaço para Mneumonico 8
            '<div id="mneumonico8_div" class="hide">' TO srscd,
            '	   <table cellpadding="2" cellspacing="0" border="0" width="100%">' TO srscd,
            '  	 <tr>' TO srscd,
            '     <td width="8">&nbsp;</td>' TO srscd,
            '     <td class="txt" width="150"><div id="mn_8"></div><input type="hidden" value="" id="obr_8" /></td>' TO srscd,
            '     <td><input type="text" id="mneumonico8" name="mneumonico8" class="txt_input" /></td>' TO srscd,
            '    </tr>' TO srscd,
            '	   </table>' TO srscd,
            '</div>' TO srscd,

**          Espaço para Mneumonico 9
            '<div id="mneumonico9_div" class="hide">' TO srscd,
            '	   <table cellpadding="2" cellspacing="0" border="0" width="100%">' TO srscd,
            '  	 <tr>' TO srscd,
            '     <td width="8">&nbsp;</td>' TO srscd,
            '     <td class="txt" width="150"><div id="mn_9"></div><input type="hidden" value="" id="obr_9" /></td>' TO srscd,
            '     <td><input type="text" id="mneumonico9" name="mneumonico9" class="txt_input" /></td>' TO srscd,
            '    </tr>' TO srscd,
            '	   </table>' TO srscd,
            '</div>' TO srscd,

**          Espaço para Mneumonico 10
            '<div id="mneumonico10_div" class="hide">' TO srscd,
            '	   <table cellpadding="2" cellspacing="0" border="0" width="100%">' TO srscd,
            '  	 <tr>' TO srscd,
            '     <td width="8">&nbsp;</td>' TO srscd,
            '     <td class="txt" width="150"><div id="mn_10"></div><input type="hidden" value="" id="obr_10" /></td>' TO srscd,
            '     <td><input type="text" id="mneumonico10" name="mneumonico10" class="txt_input" /></td>' TO srscd,
            '    </tr>' TO srscd,
            '	   </table>' TO srscd,
            '</div>' TO srscd,

            '</div>' TO srscd,
            '</p>' TO srscd,

            '   </td>' TO srscd,
            '  </tr>' TO srscd,
            '  <tr>' TO srscd,
            '   <td>' TO srscd,

            '<div id="observacoes" class="hide">' TO srscd,
            '<p>' TO srscd,
            '<div class="txt" id="txt_obs"><b>&raquo;</b> Observações para este tipo de documento:</div>' TO srscd,
            '<div id="obs_value" class="obs_value" ></div>' TO srscd,
            '</p>' TO srscd,
            '</div>' TO srscd,

           '   </td>' TO srscd,
            '  </tr>' TO srscd,
            '  <tr>' TO srscd,
            '   <td>' TO srscd,

            '<div id="default" class="hide">' TO srscd,
            '<p>' TO srscd,
            '<div class="txt" id="txt_newobs"><b>&raquo;</b> Deseja acrescentar alguma observação?</div>' TO srscd,

            '<center>' TO srscd,
            '<textarea cols="90" rows="3" id="obs" class="txt" style="border: 1px solid #999; overflow: auto;"></textarea>' TO srscd,
            '</center>' TO srscd,
            '</p>' TO srscd,

            '   </td>' TO srscd,
            '  </tr>' TO srscd,
            '  <tr>' TO srscd,
            '   <td>' TO srscd,

            '<p>' TO srscd,
            '<center>' TO srscd,
            '  <input id="confirma" type="submit" value="Confirmar Entrada"  /> ' TO srscd,
            '  <input id="cancela" type="button" value="Cancelar Portaria"  onclick="cancelar()"/> ' TO srscd,
            '</center>' TO srscd,
            '</p>' TO srscd,
            '</div>' TO srscd,

*** Incio AInclusão David Rosin Inserção botão nova consulta
            '<div>' TO srscd,
            '<p>' TO srscd,
            '<center>' TO srscd,
            '  <input id="consulta" type="button" value="Nova Consulta" onclick="consultar()"/> ' TO srscd,
            '</center>' TO srscd,
            '</p>' TO srscd,
            '</div>' TO srscd,
*** Fim AInclusão David Rosin

            '</form>' TO srscd.

  APPEND :  '<form name="check" action="SAPEVENT:check" STYLE="margin: 0px; padding:0px;" method="POST">' TO srscd,
            '</form>' TO srscd.

  APPEND :  '<form name="cancel" action="SAPEVENT:cancel" STYLE="margin: 0px; padding:0px;" method="POST">' TO srscd,
            '</form>' TO srscd.

*** Inicio inclusão David Rosin
  APPEND :  '<form name="consu" action="SAPEVENT:consu" STYLE="margin: 0px; padding:0px;" method="POST">' TO srscd,
            '</form>' TO srscd.
*** Fim inclusão David Rosin

  IF NOT datasrc[] IS INITIAL.

    APPEND:   '<script language="javascript">' TO srscd.

    LOOP AT datasrc.
      APPEND:   datasrc TO srscd.
    ENDLOOP.

    APPEND:   '</script>' TO srscd.

  ENDIF.
  APPEND: '   </td>' TO srscd,
          '  </tr>' TO srscd,
          ' </table>' TO srscd.
* Fim HTML
  APPEND: '</body>' TO srscd,
          '</html>' TO srscd.


*  APPEND: '<html class="no-js" lang="en">' TO srscd.
*  APPEND: '<body>' TO srscd.
*  APPEND: '<form  action="SAPEVENT:portaria">' TO srscd.
*  DATA: v_text TYPE string,
*        v_valor TYPE c.
*
*  DO 5 TIMES.
*    CONCATENATE '<input type="text" name="x' v_valor '_" />' INTO v_text.
*    APPEND v_text TO srscd.
*    v_valor = v_valor + 1.
*  ENDDO.
*
*  APPEND: '<input type="submit" />' TO srscd.
*
*  APPEND: '</form>' TO srscd.
*
*  APPEND: '</body>' TO srscd,
*          '</html>' TO srscd.

ENDFUNCTION.
