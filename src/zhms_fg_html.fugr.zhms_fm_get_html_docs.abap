FUNCTION zhms_fm_get_html_docs .
*"----------------------------------------------------------------------
*"*"Interface local:
*"  TABLES
*"      PARAM STRUCTURE  ZHMS_ST_HTML_PARAM
*"      DOCST STRUCTURE  ZHMS_TB_DOCST
*"      DOCRF STRUCTURE  ZHMS_ES_DOCRF
*"      SRSCD STRUCTURE  ZHMS_ST_HTML_SRSCD OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
*" RCP - Tradução EN/ES - 30/08/2018

  DATA: v_txtln      TYPE  zhms_st_html_srscd-linsc,
        v_index      TYPE string,
        v_showstatus TYPE c,
        t_chave      TYPE TABLE OF zhms_st_html_param-chave WITH HEADER LINE.

* Cabeçalho / Meta Tags
  APPEND: '<html class="no-js" lang="en" style="height: 100%;">' TO srscd,
          '<head>' TO srscd.
  APPEND  '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />' TO srscd.

* Importação Bibliotecas Javascript
  APPEND:  '<script type="text/javascript" src="jquery.min"></script>' TO srscd,
           '<script type="text/javascript" src="mousewheel.js"></script>' TO srscd,
           '<script type="text/javascript" src="jscrollpane.js"></script>' TO srscd.

* Estilos CSS
  APPEND:  '<link type="text/css" href="jscrollpane.css" rel="stylesheet" media="all" />' TO srscd,
           '<link type="text/css" href="HOMSOFT.CSS" rel="stylesheet" media="all" />' TO srscd.

  APPEND: '<style>' TO srscd,
          'body{' TO srscd,
          'padding: 0px;' TO srscd,
          'margin: 0px;' TO srscd,
          'background-color: #EAF0F6;' TO srscd,
          '}' TO srscd,
          '.docnr_1{' TO srscd,
          'color: #666666;' TO srscd,
          'font-size: 17px;' TO srscd,
          '}' TO srscd,
          '.docnr_2{' TO srscd,
          'color: #666666;' TO srscd,
          'font-size: 17px;' TO srscd,
          '}' TO srscd,
          '.docnr_3{' TO srscd,
          'color: #666666;' TO srscd,
          'font-size: 17px;' TO srscd,
          '}' TO srscd,

          '.docnr_4{' TO srscd,
          'color: #B22D00;' TO srscd,
          'font-size: 17px;' TO srscd,
          '}' TO srscd,

          '.content-area{' TO srscd,
          'width:300px;' TO srscd,
*          'height:100%;' TO srscd,
*{ Ajuste da barra de rolagem #RVALIM #DE2K906234 28/10/2019
          'height:450px;' TO srscd,
          '}' TO srscd,
*}
          '.inpt1, .inpt2, .selecatual, .selec {' TO srscd,
          'height:70px;' TO srscd,
          '}' TO srscd,


          '</style>' TO srscd.

* Código Javascript gerado / dependente dos dados enviados à função
  APPEND: '<script language="javascript">' TO srscd,
           'var t_atrib_cod = [];' TO srscd,
           'var t_atrib_den = [];' TO srscd,
           'var t_divs = [];' TO srscd,
           'var t_show = [];' TO srscd,
           'var t_selec = [];' TO srscd,
           'var t_chaves = [];' TO srscd.

  v_index = 0.

* Conteúdo Dinâmico: Parametros de cada documento
  READ TABLE param INDEX 1.
  LOOP AT param WHERE chave EQ param-chave.

    CLEAR v_txtln.
    CONCATENATE 't_atrib_cod[' v_index ']' INTO v_txtln.
    CONDENSE v_txtln NO-GAPS.
    CONCATENATE v_txtln ' = "' param-tagdc '";' INTO v_txtln.
    APPEND v_txtln TO srscd.

    CLEAR v_txtln.
    CONCATENATE 't_atrib_den[' v_index ']' INTO v_txtln.
    CONDENSE v_txtln NO-GAPS.
    CONCATENATE v_txtln ' = "' param-denom '";' INTO v_txtln.
    APPEND v_txtln TO srscd.

    v_index = v_index + 1.
  ENDLOOP.

  CLEAR v_index.
  v_index = 0.

* Conteúdo Dinâmico: Arrays de documentos com dados para chamada de eventos SAP / HTML
  LOOP AT param WHERE tagdc = 'DOCNR'.

    CONDENSE v_index NO-GAPS.
    CLEAR v_txtln.
    CONCATENATE 't_divs[' v_index ']' INTO v_txtln.
    CONDENSE v_txtln NO-GAPS.
    CONDENSE v_index NO-GAPS.
    CONCATENATE v_txtln ' = "div' v_index '";' INTO v_txtln.
    APPEND v_txtln TO srscd.

    CLEAR v_txtln.
    CONCATENATE 't_show[' v_index ']' INTO v_txtln.
    CONDENSE v_txtln NO-GAPS.
    CONCATENATE v_txtln ' = true;' INTO v_txtln.
    APPEND v_txtln TO srscd.

    CLEAR v_txtln.
    CONCATENATE 't_selec[' v_index ']' INTO v_txtln.
    CONDENSE v_txtln NO-GAPS.
    CONCATENATE v_txtln ' = false;' INTO v_txtln.
    APPEND v_txtln TO srscd.

    CLEAR v_txtln.
    CONCATENATE 't_chaves[' v_index ']' INTO v_txtln.
    CONDENSE v_txtln NO-GAPS.
    CONCATENATE v_txtln ' = "' param-chave '";' INTO v_txtln.
    APPEND v_txtln TO srscd.

    CLEAR t_chave.
    t_chave = param-chave.
    APPEND t_chave.
    CONDENSE v_index NO-GAPS.

    v_index = v_index + 1.
  ENDLOOP.

* JavaScript
  APPEND: 'var v_selecionado;' TO srscd,
          'var v_selec_ref = "";' TO srscd,
          'var refid = "";' TO srscd,
          'var keyshift = "";' TO srscd,
          'var keycrtl = "";' TO srscd.

* Criar cores dos documentos
  APPEND: 'function cria_cores() {' TO srscd,
          '    var colors = [];' TO srscd,
          '    colors[0] = "inpt1";' TO srscd,
          '    colors[1] = "inpt2";' TO srscd,
          '    v_cor = 0;' TO srscd,
          '    for (var i = 0; i <= t_show.length - 1; i++) {' TO srscd,
          '        if (t_show[i] == true) {' TO srscd,
          '            document.getElementById(t_divs[i]).style.display = "block";' TO srscd,
          '            if (v_cor == 1) {' TO srscd,
          '                v_cor = 0;' TO srscd,
          '            } else {' TO srscd,
          '                v_cor = 1;' TO srscd,
          '            } if (t_selec[i] == false) {' TO srscd,
          '                document.getElementById(t_divs[i]).className = colors[v_cor];' TO srscd,
          '            } else {' TO srscd,
          '                document.getElementById(t_divs[i]).className = "selec";' TO srscd,
          '            } if (v_selecionado == i) {' TO srscd,
          '                if (t_selec[v_selecionado] == true) {' TO srscd,
          '                    document.getElementById(t_divs[i]).className = "selecatual";' TO srscd,
          '                } else {' TO srscd,
          '                    document.getElementById(t_divs[i]).className = "selec" + colors[v_cor];' TO srscd,
          '                }' TO srscd,
          '            }' TO srscd,
          '        } else {' TO srscd,
          '            document.getElementById(t_divs[i]).style.display = "none";' TO srscd,
          '        }' TO srscd,
          '    }' TO srscd,
          '    envia_selecao();' TO srscd,
          '}' TO srscd.

* Enviar seleção
  APPEND: 'function envia_selecao() {' TO srscd,
          '    var input = document.getElementById("lista");' TO srscd,
          '    input.value = "";' TO srscd,
          '    for (var x = 0; x <= t_selec.length - 1; x++) {' TO srscd,
          '        if (t_selec[x] == true) {' TO srscd,
          '            input.value += t_chaves[x] + "|";' TO srscd,
          '        }' TO srscd,
          '    }' TO srscd,
          '    if (keyshift != "X" && keycrtl != "X") document.formact.submit();' TO srscd,
          '}' TO srscd,
          'var v_ref = false;' TO srscd,
          'function seleciona_documento(id) {' TO srscd,
          '	if(v_ref == false){' TO srscd,
          '    ' TO srscd,
          '	if(v_selec_ref.length > 0){' TO srscd,
*          '   var anterior = v_selec_ref.split("@");' TO srscd,
*          '   var refantid = "ref_" + anterior[0] + "_" + anterior[1]; ' TO srscd,
*          '   document.getElementById(refantid).className = "docref_1";' TO srscd,
          '   document.getElementById(refid).className = "docref_1";' TO srscd,
          '	}' TO srscd,
          '	document.getElementById("div" + id).className = "selec";' TO srscd,
          '    if (keyshift != "X" && keycrtl != "X") {' TO srscd,
          '        for (var x = 0; x <= t_selec.length - 1; x++) {' TO srscd,
          '            t_selec[x] = false;' TO srscd,
          '        }' TO srscd,
          '        if (t_selec[id] == true) {' TO srscd,
          '            t_selec[id] = false;' TO srscd,
          '        } else {' TO srscd,
          '            t_selec[id] = true;' TO srscd,
          '        }' TO srscd,
          '    }' TO srscd,
          '    if (keyshift == "X") {' TO srscd,
          '        if (v_selecionado < id) {' TO srscd,
          '            for (var x = v_selecionado; x <= id; x++) {' TO srscd,
          '                t_selec[x] = true;' TO srscd,
          '            }' TO srscd,
          '        } else {' TO srscd,
          '            for (var x = v_selecionado; x >= id; x--) {' TO srscd,
          '                t_selec[x] = true;' TO srscd,
          '            }' TO srscd,
          '        }' TO srscd,
          '    }' TO srscd,
          '    if (keycrtl == "X") {' TO srscd,
          '        if (t_selec[id] == true) {' TO srscd,
          '            t_selec[id] = false;' TO srscd,
          '        } else {' TO srscd,
          '            t_selec[id] = true;' TO srscd,
          '        }' TO srscd,
          '    }' TO srscd,
          '    v_selecionado = id;' TO srscd,
          '    cria_cores();' TO srscd,
          '    $("#anchor_" + id).scrollToMe();' TO srscd,
          '	}else{' TO srscd,
          '   v_ref = false;' TO srscd,
          '	}' TO srscd,
          '}' TO srscd,
          'var tips_ativos = [];' TO srscd,
          'var tips_values = [];' TO srscd,
          '' TO srscd,
          'function busca_documento(texto) {' TO srscd,
          '    if (texto == "Filtrar...") {' TO srscd,
          '        texto = "";' TO srscd,
          '    }' TO srscd,
          '    if (texto.length > 0) {' TO srscd,
          '        for (var i = 0; i <= t_divs.length - 1; i++) {' TO srscd,
          '            var found = 0;' TO srscd,
          '            for (var x = 0; x <= t_atrib_cod.length - 1; x++) {' TO srscd,
          '                var campo = i + "_" + t_atrib_cod[x];' TO srscd,
          '                var valor = document.getElementById(campo).value;' TO srscd,
          '                valor = retira_acentos(valor);' TO srscd,
          '                var newtext = retira_acentos(texto);' TO srscd,
          '                if (valor.toUpperCase().indexOf(newtext.toUpperCase()) >= 0 && texto.length > 0) {' TO srscd,
          '                    found = 1;' TO srscd,
          '                }' TO srscd,
          '            }' TO srscd,
          '            if (found == 1) {' TO srscd,
          '                t_show[i] = true;' TO srscd,
          '            } else {' TO srscd,
          '                t_show[i] = false;' TO srscd,
          '            }' TO srscd,
          '        }' TO srscd,
          '    } else {' TO srscd,
          '        for (var i = 0; i <= t_divs.length - 1; i++) {' TO srscd,
          '            t_show[i] = true;' TO srscd,
          '        }' TO srscd,
          '    }' TO srscd,
          '    aplica_filtros();' TO srscd,
          '    tooltip_opcoes(texto);' TO srscd,
          '    cria_cores();' TO srscd,
          '    $.each($(''.content-area''), function () {' TO srscd,
          '        var api = $(this).data(''jsp'');' TO srscd,
          '        api.reinitialise();' TO srscd,
          '    });' TO srscd,
          '}' TO srscd,
          'function tooltip_opcoes(texto) {' TO srscd,
          '    var tip = "";' TO srscd,
          '    for (var i = 0; i <= t_atrib_den.length - 1; i++) {' TO srscd,
          '        if (tips_ativos[t_atrib_cod[i]] != true) {' TO srscd,
          '            tip += "<table cellpadding=\"1\" cellspacing=\"1\" width=\"100%\" height=\"19\">";' TO srscd,
          '            tip += "<tr>";' TO srscd,
          '            tip += " <td class=\"tip\" width=\"40%\">" + t_atrib_den[i] + "</td>";' TO srscd,
          '            tip += " <td class=\"tipvalue\" width=\"50%\"><strong>" + texto + "</strong></td>";' TO srscd,
          '            tip += " <td class=\"tip\" width=\"10%\"><strong>' TO srscd,
          '<span onClick=\"setFiltro(''" + t_atrib_cod[i] + "'', ''" + texto + "'', ''" + t_atrib_den[i] + "'');\">' TO srscd,
          '<img src=\"icfixtip.gif\" border=\"0\" style=\"cursor:pointer;\" alt=\"Fixar filtro\"/>' TO srscd,
          '</span></strong></td>";' TO srscd,
          '            tip += "</tr>";' TO srscd,
          '            tip += "</table>";' TO srscd,
          '        }' TO srscd,
          '    }' TO srscd,
          '    document.getElementById("tips").style.display = "block";' TO srscd,
          '    document.getElementById("tips").innerHTML = tip;' TO srscd,
          '    if (texto.length == 0) {' TO srscd,
          '        document.getElementById("tips").style.display = "none";' TO srscd,
          '        document.getElementById("tips").innerHTML = "";' TO srscd,
          '    }' TO srscd,
          '}' TO srscd,
          'function setFiltro(tag, valor, nome) {' TO srscd,
          '    var filtro = "<div id=\"tip_" + tag + "\">";' TO srscd,
          '    filtro += "<table cellpadding=\"1\" cellspacing=\"1\" width=\"100%\" >";' TO srscd,
          '    filtro += "<tr>";' TO srscd,
          '    filtro += " <td class=\"fxtip\" width=\"40%\">" + nome + "</td>";' TO srscd,
          '    filtro += " <td class=\"fxtipvalue\" width=\"50%\"><strong>" + valor + "</strong></td>";' TO srscd,
          '    filtro += " <td class=\"fxtip\" width=\"10%\"><strong>' TO srscd,
          '<span onClick=\"unsetFiltro(''tip_" + tag + "'', ''" + tag + "'');\">' TO srscd,
          '<img src=\"icnotip.gif\" border=\"0\" style=\"cursor:pointer;\" alt=\"Desfixar filtro\"/>' TO srscd,
          '</span></strong></td>";' TO srscd,
          '    filtro += "</tr>";' TO srscd,
          '    filtro += "</table></div>";' TO srscd,
          '    tips_ativos[tag] = true;' TO srscd,
          '    tips_values[tag] = valor;' TO srscd,
          '    document.getElementById("tips_fixo").style.display = "block";' TO srscd,
          '    document.getElementById("tips_fixo").innerHTML += filtro;' TO srscd,
          '    document.getElementById("bsc").value = "";' TO srscd,
          '    document.getElementById("bsc").focus();' TO srscd,
          '    document.getElementById("tips").style.display = "none";' TO srscd,
          '    aplica_filtros();' TO srscd,
          '}' TO srscd,
          'function aplica_filtros() {' TO srscd,
          '    var t_divslc = [];' TO srscd,
          '    for (var z = 0; z <= t_atrib_cod.length - 1; z++) {' TO srscd,
          '        if (tips_ativos[t_atrib_cod[z]] == true) {' TO srscd,
          '            for (var i = 0; i <= t_divs.length - 1; i++) {' TO srscd,
          '                var found = 0;' TO srscd,
          '                var campo = i + "_" + t_atrib_cod[z];' TO srscd,
          '                var valor = document.getElementById(campo).value;' TO srscd,
          '                valor = retira_acentos(valor);' TO srscd,
          '                if (valor.toUpperCase().indexOf(retira_acentos(tips_values[t_atrib_cod[z]]).toUpperCase()) >= 0) {' TO srscd,
          '                    found = 1;' TO srscd,
          '                }' TO srscd,
          '                if (found == 0) {' TO srscd,
          '                    t_show[i] = false;' TO srscd,
          '                }' TO srscd,
          '            }' TO srscd,
          '        }' TO srscd,
          '    }' TO srscd,
          '    cria_cores();' TO srscd,
          '}' TO srscd,
          'function unsetFiltro(tip, atrib) {' TO srscd,
          '    var div = document.getElementById(tip);' TO srscd,
          '    div.parentNode.removeChild(div);' TO srscd,
          '    tips_ativos[atrib] = false;' TO srscd,
          '    tips_values[atrib] = "";' TO srscd,
          '    var texto = document.getElementById("bsc").value;' TO srscd,
          '    busca_documento(texto);' TO srscd,
          '}' TO srscd,
          '$(document).keydown(function (e) {' TO srscd,
          '    if (e.keyCode == 16) keyshift = "X";' TO srscd,
          '    if (e.keyCode == 17) keycrtl = "X";' TO srscd,
          '});' TO srscd,
          '$(document).keyup(function (e) {' TO srscd,
          '    if (e.keyCode == 16) keyshift = "";' TO srscd,
          '    if (e.keyCode == 17) keycrtl = "";' TO srscd,
          '    if (keyshift != "X" && keycrtl != "X") document.formact.submit();' TO srscd,
          '});' TO srscd,
          'document.onkeyup = handleKeyboardAction;' TO srscd,
          '' TO srscd,
          'function handleKeyboardAction(e) {' TO srscd,
          '    var code;' TO srscd,
          '    if (!e) var e = window.event;' TO srscd,
          '    var targ;' TO srscd,
          '    if (e.target) targ = e.target;' TO srscd,
          '    else if (e.srcElement) targ = e.srcElement;' TO srscd,
          '    if (targ.nodeType == 3) targ = targ.parentNode;' TO srscd,
          '    tag = targ.tagName.toUpperCase();' TO srscd,
          '    if (tag == "INPUT") return;' TO srscd,
          '    if (tag == "SELECT") return;' TO srscd,
          '    if (e.keyCode) code = e.keyCode;' TO srscd,
          '    else if (e.which) code = e.which;' TO srscd,
          '    var character = String.fromCharCode(code);' TO srscd,
          '    if (code == 38) {' TO srscd,
          '        moveSelecao("UP");' TO srscd,
          '        return;' TO srscd,
          '    }' TO srscd,
          '    if (code == 39) {' TO srscd,
*          '        alert("39");' TO srscd,
          '        openref(v_selecionado);' TO srscd,
          '        return;' TO srscd,
          '    }' TO srscd,
          '    if (code == 37) {' TO srscd,
*          '        alert("37");' TO srscd,
          '        closeref(v_selecionado);' TO srscd,
          '        return;' TO srscd,
          '    }' TO srscd,
          '    if (code == 40) {' TO srscd,
          '        moveSelecao("DOWN");' TO srscd,
          '        return;' TO srscd,
          '    }' TO srscd,
          '    if (code == 13) {' TO srscd,
          '        return;' TO srscd,
          '    }' TO srscd,
          '    if (code == 27) {' TO srscd,
          '        return;' TO srscd,
          '    }' TO srscd,
          '}' TO srscd,
          'function moveSelecao(direcao) {' TO srscd,
          '    var total = t_show.length - 1;' TO srscd,
          '    var total_visivel = 0;' TO srscd,
          '    var v_proximo = 0;' TO srscd,
          '    for (var i = 0; i <= t_show.length - 1; i++) {' TO srscd,
          '        if (t_show[i] == true) {' TO srscd,
          '            total_visivel++;' TO srscd,
          '        }' TO srscd,
          '    }' TO srscd,
          '    if (total_visivel > 0) {' TO srscd,
          '        if (v_selecionado >= 0) {' TO srscd,
          '            if (direcao == "DOWN") {' TO srscd,
          '                v_proximo = proximoAtivo(v_selecionado);' TO srscd,
          '                if (v_proximo == "false") {' TO srscd,
          '                    v_proximo = proximoAtivo(-1);' TO srscd,
          '                }' TO srscd,
          '            }' TO srscd,
          '            if (direcao == "UP") {' TO srscd,
          '                v_proximo = anteriorAtivo(v_selecionado);' TO srscd,
          '                if (v_proximo == "false") {' TO srscd,
          '                    var v_max = t_divs.length + 1;' TO srscd,
          '                    v_proximo = anteriorAtivo(v_max);' TO srscd,
          '                }' TO srscd,
          '            }' TO srscd,
          '        } else {' TO srscd,
          '            if (direcao == "DOWN") {' TO srscd,
          '                if (v_proximo == false) {' TO srscd,
          '                    v_proximo = proximoAtivo(-1);' TO srscd,
          '                }' TO srscd,
          '            }' TO srscd,
          '            if (direcao == "UP") {' TO srscd,
          '                if (v_proximo == false) {' TO srscd,
          '                    var v_max = t_divs.length + 1;' TO srscd,
          '                    v_proximo = anteriorAtivo(v_max);' TO srscd,
          '                }' TO srscd,
          '            }' TO srscd,
          '        }' TO srscd,
          '        seleciona_documento(v_proximo);' TO srscd,
          '    }' TO srscd,
          '}' TO srscd,
          'function proximoAtivo(inicial) {' TO srscd,
          '    var proximo = "false";' TO srscd,
          '    inicial++;' TO srscd,
          '    for (var i = inicial; i <= t_show.length - 1; i++) {' TO srscd,
          '        if (t_show[i] == true) {' TO srscd,
          '            proximo = i;' TO srscd,
          '            return proximo;' TO srscd,
          '        }' TO srscd,
          '    }' TO srscd,
          '    return proximo;' TO srscd,
          '}' TO srscd,
          'function anteriorAtivo(inicial) {' TO srscd,
          '    var proximo = "false";' TO srscd,
          '    inicial--;' TO srscd,
          '    for (var i = inicial; i >= 0; i--) {' TO srscd,
          '        if (t_show[i] == true) {' TO srscd,
          '            proximo = i;' TO srscd,
          '            return proximo;' TO srscd,
          '        }' TO srscd,
          '    }' TO srscd,
          '    return proximo;' TO srscd,
          '}' TO srscd,
          'function retira_acentos(palavra) {' TO srscd,
          '    com_acento = "áàãâäéèêëíìîïóòõôöúùûüçÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÖÔÚÙÛÜÇ";' TO srscd,
          '    sem_acento = "aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC";' TO srscd,
          '    nova = "";' TO srscd,
          '    for (i = 0; i < palavra.length; i++) {' TO srscd,
          '        if (com_acento.search(palavra.substr(i, 1)) >= 0) {' TO srscd,
          '            nova += sem_acento.substr(com_acento.search(palavra.substr(i, 1)), 1);' TO srscd,
          '        } else {' TO srscd,
          '            nova += palavra.substr(i, 1);' TO srscd,
          '        }' TO srscd,
          '    }' TO srscd,
          '    return nova;' TO srscd,
          '}' TO srscd,
          'function closeref(id){' TO srscd,
          '	v_ref = true;' TO srscd,
          '	var div_open = "ref_" + id + "_open";' TO srscd,
          '	var div_closed = "ref_" + id + "_closed";' TO srscd,
          '	document.getElementById(div_open).style.display = "none";' TO srscd,
          '	document.getElementById(div_closed).style.display = "block";' TO srscd,
          '}' TO srscd,
          'function openref(id){' TO srscd,
          '	v_ref = true;' TO srscd,
          '	var div_open = "ref_" + id + "_open";' TO srscd,
          '	var div_closed = "ref_" + id + "_closed";' TO srscd,
          '	document.getElementById(div_open).style.display = "block";' TO srscd,
          '	document.getElementById(div_closed).style.display = "none";' TO srscd,
          '}' TO srscd,
          '' TO srscd,
          'function seleciona_referenciado(id,ref){' TO srscd,
          '	v_ref = true;' TO srscd,
          '	v_selecionado = id;' TO srscd,
          '	' TO srscd,
          '	for (var x = 0; x <= t_selec.length - 1; x++) {' TO srscd,
          '   t_selec[x] = false;' TO srscd,
          '	}' TO srscd,
          '  cria_cores();' TO srscd,
          '	' TO srscd,
          '	if(v_selec_ref.length > 0){' TO srscd,
*          '   var anterior = v_selec_ref.split("@");' TO srscd,
*          '   var refantid = "ref_" + anterior[0] + "_" + anterior[1]; ' TO srscd,
*          '   document.getElementById(refantid).className = "docref_1";' TO srscd,
          '   document.getElementById(refid).className = "docref_1";' TO srscd,
          '	}' TO srscd,
          '	' TO srscd,
          '  document.getElementById(t_divs[id]).className = "selec_ref";' TO srscd,
          '	refid = "ref_" + id + "_" + ref;' TO srscd,
          '  document.getElementById(refid).className = "selec_ref_itm";' TO srscd,
          '	v_selec_ref = t_chaves[id]+"@"+ref;' TO srscd,
          '' TO srscd,
*          '  cria_cores();' TO srscd,
          'var input = document.getElementById("lista");' TO srscd,
          '    input.value = v_selec_ref;' TO srscd,
          '    if (keyshift != "X" && keycrtl != "X") document.formact.submit();' TO srscd,
          '}' TO srscd,
          '' TO srscd,
          '$(document).ready(function () {' TO srscd,
          '    var pane = $(''.content-area'');' TO srscd,
          '    pane.jScrollPane({' TO srscd,
          '        horizontalGutter: 5,' TO srscd,
          '        verticalGutter: 5,' TO srscd,
          '        hijackInternalLinks: true,' TO srscd,
          '        animateScroll: true,' TO srscd,
          '        ''showArrows'': false' TO srscd,
          '    });' TO srscd,
          '    var api = pane.data(''jsp'');' TO srscd,
          '    jQuery.fn.extend({' TO srscd,
          '        scrollToMe: function () {' TO srscd,
          '            var y = document.getElementById("content-area");' TO srscd,
          '            var z = jQuery(y).offset().top;' TO srscd,
          '            var x = (v_selecionado * 60) - z;' TO srscd,
          '            api.scrollTo(parseInt(0), parseInt(x));' TO srscd,
          '            return false;' TO srscd,
          '        }' TO srscd,
          '    });' TO srscd,
          '    $(''.jspDrag'').hide();' TO srscd,
          '    $(''.jspScrollable'').mouseenter(function () {' TO srscd,
          '        $(''.jspDrag'').stop(true, true).fadeIn(''slow'');' TO srscd,
          '    });' TO srscd,
          '    $(''.jspScrollable'').mouseleave(function () {' TO srscd,
          '        $(''.jspDrag'').stop(true, true).fadeOut(''slow'');' TO srscd,
          '    });' TO srscd,
          '});' TO srscd,
          '$(document).ready(function () {' TO srscd,
          '    function cektkp_growtextarea(textarea) {' TO srscd,
          '        textarea.each(function (index) {' TO srscd,
          '            textarea = $(this);' TO srscd,
          '            textarea.css({' TO srscd,
          '                ''overflow'': ''hidden'',' TO srscd,
          '                ''word-wrap'': ''break-word''' TO srscd,
          '            });' TO srscd,
          '            var pos = textarea.position();' TO srscd,
          '            var growerid = ''textarea_grower_'' + index;' TO srscd,
          '            textarea.after(''<div style="position:absolute;z-index:-1000;visibility:hidden;top:'' + pos.top + '';height:'' + textarea.outerHeight() + ''" id="'' + growerid + ''"></div>'');' TO srscd,
          '            var growerdiv = $(''#'' + growerid);' TO srscd,
          '            growerdiv.css({' TO srscd,
          '                ''min-height'': ''20px'',' TO srscd,
          '                ''font-size'': textarea.css(''font-size''),' TO srscd,
          '                ''width'': textarea.width(),' TO srscd,
          '                ''word-wrap'': ''break-word''' TO srscd,
          '            });' TO srscd,
          '            growerdiv.html($(''<div/>'').text(textarea.val()).html().replace(/\n/g, "<br />."));' TO srscd,
          '            if (textarea.val() == '''') {' TO srscd,
          '                growerdiv.text(''.'');' TO srscd,
          '            }' TO srscd,
          '            textarea.height(growerdiv.height() + 10);' TO srscd,
          '            textarea.keyup(function () {' TO srscd,
          '                growerdiv.html($(''<div/>'').text($(this).val()).html().replace(/\n/g, "<br />."));' TO srscd,
          '                if ($(this).val() == '''') {' TO srscd,
          '                    growerdiv.text(''.'');' TO srscd,
          '                }' TO srscd,
          '                $(this).height(growerdiv.height() + 10);' TO srscd,
          '            });' TO srscd,
          '        });' TO srscd,
          '    }' TO srscd,
          '    cektkp_growtextarea($(''textarea.autogrow''));' TO srscd,
          '});' TO srscd,
          '' TO srscd,
          'document.onselectstart = new Function("return false");' TO srscd,
          '</script>' TO srscd.

  APPEND: '</head>' TO srscd.

* Início do corpo HTML
  APPEND: '<body style="height: 100%;">' TO srscd,

* Estrutura de envio de dados p/ SAP
   '<form name= "formact" action="SAPEVENT:save" STYLE="margin: 0px; padding:0px;" method="POST">' TO srscd,
   '<input type="hidden" id="lista" name="lista" />' TO srscd,
   '</form>' TO srscd,

* Tabela HTML - Corpo do documento
   '<table cellpadding="1" cellspacing="1" border="0" style="height: 100%; width:310px;"><tr><td height="20">' TO srscd,

* Busca
   '<div class="Buscar">' TO srscd,
   '<div class="bg_busca">' TO srscd,
   '<input type="text" onKeyUp="busca_documento(this.value)" name="bsc" id="bsc" class="busca"/></div>' TO srscd,
   '<div id="tips_fixo" class="tips"></div>' TO srscd,
   '<div id="tips" class="tips"></div>' TO srscd,
   '</div>' TO srscd,

* Divisão entre Busca/Documentos
   '</td></tr><tr><td>' TO srscd.

* Div: Area com overflow / scrool
  APPEND '<div class="content-area" id="content-area" >' TO srscd.
  CLEAR v_index.
  v_index = 0.
  LOOP AT t_chave.
    CONDENSE v_index NO-GAPS.

*   Tabela com Status de Documentos
    READ TABLE docst WITH KEY chave = t_chave.

*   Ancora HTML
    CLEAR v_txtln.
    CONCATENATE '<div id="anchor_' v_index '" ></div>' INTO v_txtln.
    APPEND v_txtln TO srscd.

*   DIV: Documento
    CLEAR v_txtln.
    CONCATENATE '<div onClick="seleciona_documento(''' v_index ''')" id="div' v_index '" style="margin-top:1px; ">' INTO v_txtln.
    APPEND v_txtln TO srscd.

*   Input Hidden: Atributos de documentos p/ busca
    LOOP AT param WHERE chave EQ t_chave.
      CLEAR v_txtln.
      CONDENSE param-tagdc NO-GAPS.
      CONCATENATE '<input type="hidden" id="' v_index '_' param-tagdc '" value="' param-value '" style:"visibility:hidden;  display:none;"/>' INTO v_txtln.
      APPEND v_txtln TO srscd.
    ENDLOOP.

*   Table: Documento
    APPEND: '<table cellpadding="1" cellspacing="1" width="280px" border="0">' TO srscd,
            '  <tr>' TO srscd.

*   Status HomSoft
    CLEAR v_txtln.
    v_txtln =  docst-sthms.
    CONDENSE v_txtln NO-GAPS.
    CONCATENATE '    <td valign="top" align="left" width="15"><div id="hms_' t_chave '"><img src="hms_' v_txtln '.gif"  title="HomSoft: ' v_txtln '" border="0" /></div>' INTO v_txtln.
    APPEND v_txtln TO srscd.

    READ TABLE param WITH KEY chave = t_chave
                              tagdc = 'DOCNR'.
*   Número de Nota
    CLEAR v_txtln.
    v_txtln =  docst-sthms.
    CONDENSE v_txtln NO-GAPS.
    CONCATENATE  '<td class="docnr_' v_txtln '" id="docnr_' t_chave '">' param-value '</td>' INTO v_txtln.
    APPEND v_txtln TO srscd.

*   Data do documento
    READ TABLE param WITH KEY chave = t_chave
                              tagdc = 'DOCDT'.
    CLEAR v_txtln.
    CONCATENATE  '<td class="docdt" colspan="2" valign="bottom" align="right">' param-value '</td>' INTO v_txtln.
    APPEND v_txtln TO srscd.

    APPEND:  '  </tr>' TO srscd.

*   Parametros
    CLEAR v_showstatus.
    LOOP AT param WHERE chave EQ t_chave
                    AND tagdc NE 'DOCDT'
                    AND tagdc NE 'DOCNR'.

*     Identificação da primeira linha para inserção dos status
      IF v_showstatus IS INITIAL.
        v_showstatus = 'X'.
        APPEND: '<tr>' TO srscd,
                '<td align="left" colspan="2" style="cursor:default"  width="210px">' TO srscd,
                  param-value TO srscd,
                '</td>' TO srscd.

*   Status Entidade Tributária
        CLEAR v_txtln.
        v_txtln =  docst-stent.
        CONDENSE v_txtln NO-GAPS.
        CONCATENATE '<td><div id="ent_' t_chave '" ><img src="et_' v_txtln '.gif" title="Entidade Tributária: ' v_txtln '" border="0" /></div>' INTO v_txtln.
        APPEND v_txtln TO srscd.

*   Status Recebimento
        IF  docst-strec NE 5.
          CLEAR v_txtln.
          v_txtln =  docst-strec.
          CONDENSE v_txtln NO-GAPS.
          CONCATENATE '<td><div id="rcp_' t_chave '" ><img src="rcp_' v_txtln '.gif" title="Recepção: ' v_txtln '" border="0" /></div>' INTO v_txtln.
          APPEND v_txtln TO srscd.
        ELSE.
          APPEND '<td>&nbsp;'  TO srscd.
        ENDIF.

        APPEND: '</tr>' TO srscd.

      ELSE.
*       Linhas apenas de atributo
        APPEND: '<tr>' TO srscd,
                '<td align="left" colspan="4" style="cursor:default">' TO srscd,
                  param-value TO srscd,
                '</td>' TO srscd,
                '</tr>' TO srscd.

      ENDIF.

    ENDLOOP.

    APPEND:  '  </tr>' TO srscd,
             '</table>' TO srscd.


*   Documentos referenciados
    READ TABLE docrf WITH KEY chave = t_chave.
    IF sy-subrc IS INITIAL.
*   Fechado
      CLEAR v_txtln.
      CONCATENATE '<div id="ref_' v_index '_closed" style="cursor:pointer">' INTO v_txtln.
      APPEND v_txtln TO srscd.

      CLEAR v_txtln.
      CONCATENATE '  <table cellpadding="1" cellspacing="1" border="0" width="280px" onClick="openref(''' v_index ''');">' INTO v_txtln.
      APPEND v_txtln TO srscd.

      APPEND: '    <tr>' TO srscd,
              '      <td width="20" align="right">&nbsp;<img src="docref_closed.gif" title="Documentos Referenciados - Exibir" border="0"/>&nbsp;</td>' TO srscd,
              '      <td class="docref">[Documentos Referenciados]</td>' TO srscd,
              '    </tr>' TO srscd,
              '  </table>' TO srscd,
              '</div>' TO srscd.

*   Aberto

      CLEAR v_txtln.
      CONCATENATE '<div id="ref_' v_index '_open" style="display:none;">' INTO v_txtln.
      APPEND v_txtln TO srscd.

      APPEND: '  <table cellpadding="1" cellspacing="1" border="0" width="280px">' TO srscd,
              '    <tr>' TO srscd,
              '      <td width="20" align="right" height="10" style="cursor:pointer">' TO srscd.

      CLEAR v_txtln.
      CONCATENATE '       &nbsp;<img src="docref_open.gif" title="Documentos Referenciados - Esconder" border="0"  onClick="closeref(''' v_index ''');"/>&nbsp;</td>' INTO v_txtln.
      APPEND v_txtln TO srscd.

      CLEAR v_txtln.
      CONCATENATE '      <td class="docref" onClick="closeref(''' v_index ''');" style="cursor:pointer">[Documentos Referenciados]</td>' INTO v_txtln.
      APPEND v_txtln TO srscd.

      APPEND: '    </tr>' TO srscd.

      LOOP AT docrf WHERE chave EQ t_chave.

        APPEND: '    <tr>' TO srscd,
                '      <td width="20" height="10">&nbsp;</td>' TO srscd.

        CLEAR v_txtln.
        v_txtln = docrf-dcnro.
        CONCATENATE  '      <td class="docref_1" id="ref_' v_index '_' docrf-chvrf '" onClick="seleciona_referenciado(''' v_index ''',''' docrf-chvrf ''')" style="cursor:default"><strong>' docrf-tpdrf '</strong>&nbsp;' v_txtln '</td>' INTO v_txtln.
        APPEND v_txtln TO srscd.

        APPEND:'    </tr>' TO srscd.

      ENDLOOP.

      APPEND: '  </table>' TO srscd,
              '</div>' TO srscd.

    ENDIF.

*   Fim de DIV para documento
    APPEND '</div>' TO srscd.

    v_index = v_index + 1.
  ENDLOOP.

  APPEND '<script language="javascript">' TO srscd.
  APPEND 'cria_cores();' TO srscd.

  APPEND '$(window).resize(function(){' TO srscd.
  APPEND '$.each( $(''.content-area''), function(){' TO srscd.
  APPEND 'var api = $(this).data(''jsp'');' TO srscd.
  APPEND 'api.reinitialise();' TO srscd.
  APPEND '});' TO srscd.
  APPEND '});' TO srscd.

  APPEND 'function add_placeholder (id, placeholder)' TO srscd.
  APPEND '{' TO srscd.
  APPEND 'var el = document.getElementById(id);' TO srscd.
  APPEND 'el.placeholder = placeholder;' TO srscd.
  APPEND 'el.onfocus = function ()' TO srscd.
  APPEND '{' TO srscd.
  APPEND 'if(this.value == this.placeholder)' TO srscd.
  APPEND '{' TO srscd.
  APPEND 'this.value = "";' TO srscd.
  APPEND 'el.style.cssText  = "";' TO srscd.
  APPEND '}' TO srscd.
  APPEND '};' TO srscd.
  APPEND 'el.onblur = function ()' TO srscd.
  APPEND '{' TO srscd.
  APPEND 'if(this.value.length == 0)' TO srscd.
  APPEND '{' TO srscd.
  APPEND 'this.value = this.placeholder;' TO srscd.
  APPEND 'el.style.cssText = "color:#99AEC5;";' TO srscd.
  APPEND '}' TO srscd.
  APPEND '};' TO srscd.
  APPEND 'el.onblur();' TO srscd.
  APPEND '}' TO srscd.

  APPEND 'add_placeholder("bsc", "Filtrar...");' TO srscd.

  APPEND '</script>' TO srscd.


* fim do corpo de Página / Table / HTML
  APPEND:
  '</td></tr></table>' TO srscd,
          '</body>' TO srscd,
          '</html>' TO srscd.

ENDFUNCTION.
