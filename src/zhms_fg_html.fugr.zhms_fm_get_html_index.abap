FUNCTION zhms_fm_get_html_index .
*"----------------------------------------------------------------------
*"*"Interface local:
*"  TABLES
*"      INDEX STRUCTURE  ZHMS_ST_HTML_INDEX OPTIONAL
*"      SRSCD STRUCTURE  ZHMS_ST_HTML_SRSCD OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------
*" RCP - Tradução EN/ES - 30/08/2018

  DATA: t_fathr TYPE TABLE OF zhms_st_html_index-fathr WITH HEADER LINE,
        v_txtln TYPE  zhms_st_html_srscd-linsc.

*Separação dos campos Pais (Natureza de Operação)
  LOOP AT index.
    IF t_fathr NE index-fathr.
      t_fathr = index-fathr.
      CHECK t_fathr IS NOT INITIAL.
      APPEND t_fathr.
    ENDIF.
  ENDLOOP.

*Inicio HTML
  APPEND: '<html class="no-js" lang="en">' TO srscd,
          '<head>' TO srscd,
          '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />' TO srscd.

*Importação Bibliotecas Javascript
  APPEND: '<script type="text/javascript" src="JQUERY_MIN.js"></script>' TO srscd.


*Scroll
  APPEND: '<!-- styles needed by jScrollPane -->' TO srscd,
          '<link type="text/css" href="JSCROLLPANECSS.CSS" rel="stylesheet" media="all" />' TO srscd,

          '<script type="text/javascript" src="JQUERY_MIN.JS"></script>' TO srscd,
          '<!-- the mousewheel plugin - optional to provide mousewheel support -->' TO srscd,
          '<script type="text/javascript" src="MOUSEWHEEL.JS"></script>' TO srscd,
          '<!-- the jScrollPane script -->' TO srscd,
          '<script type="text/javascript" src="JSCROLLPANE.JS"></script>' TO srscd,
          '<style type="text/css">' TO srscd,
          '.content-area {' TO srscd,
*          'height: 300px;' TO srscd,
          '}' TO srscd,
          '/*scrollpane custom CSS*/' TO srscd,
          '.jspVerticalBar {' TO srscd,
          'width: 8px;' TO srscd,
          'background: transparent;' TO srscd,
          'right: 10px;' TO srscd,
          '}' TO srscd,
          '.jspHorizontalBar {' TO srscd,
          'bottom: 5px;' TO srscd,
          'width: 100%;' TO srscd,
          'height: 8px;' TO srscd,
          'background: transparent;' TO srscd,
          '}' TO srscd,
          '.jspTrack {' TO srscd,
          'background: transparent;' TO srscd,
          '}' TO srscd,
          '.jspDrag {' TO srscd,
          'background:#666;' TO srscd,
          '-webkit-border-radius: 4px;' TO srscd,
          '-moz-border-radius: 4px;' TO srscd,
          'border-radius: 4px;' TO srscd,
          '}' TO srscd,
          '.jspHorizontalBar .jspTrack,  .jspHorizontalBar .jspDrag {' TO srscd,
          'float: left;' TO srscd,
          'height: 100%;' TO srscd,
          '}' TO srscd,
          '.jspCorner {' TO srscd,
          'display: none' TO srscd,
          '}' TO srscd,
          '</style>' TO srscd,

          '<script>' TO srscd,
          '$(document).ready(function(){' TO srscd,
          '$(''.content-area'').jScrollPane({' TO srscd,
          'horizontalGutter:5,' TO srscd,
          'verticalGutter:5,' TO srscd,
          '''showArrows'': false' TO srscd,
          '});' TO srscd,
          '$(''.jspDrag'').hide();' TO srscd,
          '$(''.jspScrollable'').mouseenter(function(){' TO srscd,
          '$(''.jspDrag'').stop(true, true).fadeIn(''slow'');' TO srscd,
          '});' TO srscd,
          '$(''.jspScrollable'').mouseleave(function(){' TO srscd,
          '$(''.jspDrag'').stop(true, true).fadeOut(''slow'');' TO srscd,
          '});' TO srscd,
          '});' TO srscd,
          '</script>' TO srscd,
          '<script>' TO srscd,
          '$(document).ready(function(){' TO srscd,
          'function cektkp_growtextarea(textarea){' TO srscd,
          'textarea.each(function(index){' TO srscd,
          'textarea = $(this);' TO srscd,
          'textarea.css({''overflow'':''hidden'',''word-wrap'':''break-word''});' TO srscd,
          'var pos = textarea.position();' TO srscd,
          'var growerid = ''textarea_grower_''+index;' TO srscd,
          'textarea.after(''<div style="position:absolute;z-index:-1000;visibility:hidden;top:''' TO srscd,
          '+pos.top+'';height:''+textarea.outerHeight()+''" id="''+growerid+''"></div>'');' TO srscd,
          'var growerdiv = $(''#''+growerid);' TO srscd,
          'growerdiv.css({''min-height'':''20px'',''font-size'':textarea.css(''font-size''),' TO srscd,
          '''width'':textarea.width(),''word-wrap'':''break-word''});' TO srscd,
          'growerdiv.html($(''<div/>'').text(textarea.val()).html().replace(/\n/g, "<br />."));' TO srscd,
          'if(textarea.val() == ''''){' TO srscd,
          'growerdiv.text(''.'');' TO srscd,
          '}' TO srscd,
          'textarea.height(growerdiv.height()+10);' TO srscd,
          'textarea.keyup(function(){' TO srscd,
          'growerdiv.html($(''<div/>'').text($(this).val()).html().replace(/\n/g, "<br />."));' TO srscd,
          'if($(this).val() == ''''){' TO srscd,
          'growerdiv.text(''.'');' TO srscd,
          '}' TO srscd,
          '$(this).height(growerdiv.height()+10);' TO srscd,
          '});' TO srscd,
          '});' TO srscd,
          '}' TO srscd,
          'cektkp_growtextarea($(''textarea.autogrow''));' TO srscd,
          '});' TO srscd,
          '</script>' TO srscd.

*Códigos oriundos à pagina
  APPEND: '<script type="text/javascript">' TO srscd,
          '$(document).ready(function(){' TO srscd,
          '$(".conteudoMenu").hide();' TO srscd,
          '$(".itemMenu").click(function(){' TO srscd,
          '$(this).next(".conteudoMenu").slideToggle(300);' TO srscd,
          '});' TO srscd,
          '$(".itemMenu").click();' TO srscd,
          '}) ' TO srscd,
          '</script>' TO srscd.

*estilos CSS para o documento
  APPEND: '<style type="text/css">' TO srscd,
          'body{' TO srscd,
          'font-family: Arial, Helvetica, sans-serif;' TO srscd,
          'margin:0px;' TO srscd,
          'overflow:hidden;' TO srscd,
          'border:0px solid;' TO srscd,
          'background-color:#EAF0F6;' TO srscd,

          '}' TO srscd,
          '.item{' TO srscd,
          'display:block;' TO srscd,
          'color:#444;' TO srscd,
          'text-decoration:none;' TO srscd,
          'font-size:12px;' TO srscd,
          'padding:3px;' TO srscd,
          'padding-left:25px;' TO srscd,
          '}' TO srscd,
          '.item:HOVER{' TO srscd,
          'background-color:#D3DDE6;' TO srscd,
          '}' TO srscd,
          '.itemMenu{' TO srscd,
          'display:block;' TO srscd,
          'padding:3px;' TO srscd,
          'cursor:default;' TO srscd,
          'color:#000;' TO srscd,
          'text-decoration:none;' TO srscd,
          'font-size:15px;' TO srscd,
          '}' TO srscd,
          '.itemMenu:HOVER{' TO srscd,
          'background-color:#AFC8D9;' TO srscd,
          '}' TO srscd,

          'ul#menuGeral {' TO srscd,
          'margin:0px;' TO srscd,
          'padding:0px;' TO srscd,
          'font-family:Arial, Helvetica, sans-serif;' TO srscd,
          'list-style:none;' TO srscd,
          '}' TO srscd,
          '.itemSelect{' TO srscd,
          'display:block;' TO srscd,
          'color:#444;' TO srscd,
          'text-decoration:none;' TO srscd,
          'font-size:12px;' TO srscd,
          'padding:3px;' TO srscd,
          'padding-left:25px;' TO srscd,
          'background-color:#F9DB88;' TO srscd,
          '}' TO srscd,
          '</style>' TO srscd.

* Scripts de ativação
  APPEND: '<script type="text/javascript">' TO srscd,
          'var selection;' TO srscd,
          '   function seleciona(div){' TO srscd,
          '     if(selection){' TO srscd,
          '       selection.className = "item";' TO srscd,
          '     }     ' TO srscd,
          '     div.className = "itemSelect";' TO srscd,
          '     selection = div;' TO srscd,
          '   }' TO srscd,
          '   function sai(){' TO srscd,
          '     alert("sai")' TO srscd,
          '   }' TO srscd,
          '</script>' TO srscd,
          '</head>' TO srscd.

* Inicio Corpo HTML
  APPEND: '<body>' TO srscd,
          '<div class="content-area" style="width:300px">' TO srscd,
          '<ul id="menuGeral">' TO srscd.

* Percorrendo Naturezas de documento
  LOOP AT t_fathr.

    READ TABLE index WITH KEY fathr = ''
                              sonhr = t_fathr.
*   Nomeação de Natureza
    CLEAR v_txtln.
    CONCATENATE  '<li><a href="javascript:void(0);" class="itemMenu" style="cursor:default;"><img src="' index-iconh '" border="0" style="margin-right:3px">' index-denom '</a>' INTO v_txtln.
    APPEND v_txtln TO srscd.
*   Nomeação de Itens
    APPEND '<div class="conteudoMenu">' TO srscd.

    LOOP AT index WHERE fathr EQ t_fathr.
      CLEAR v_txtln.
      CONCATENATE  '<a href=SAPEVENT:'t_fathr'|'index-sonhr'|'index-loctp' class="item" onclick="seleciona(this)"><img src="S_RANEUT.GIF" border="0">' index-denom '</a>' INTO v_txtln.
      APPEND v_txtln TO srscd.
    ENDLOOP.

    APPEND '</div>' TO srscd.
    APPEND '</li>' TO srscd.

  ENDLOOP.

* Fechando Conteúdos
  APPEND: '</ul>' TO srscd,
          '</div>' TO srscd.

* Fim HTML
  APPEND: '</body>' TO srscd,
          '</html>' TO srscd.

ENDFUNCTION.
