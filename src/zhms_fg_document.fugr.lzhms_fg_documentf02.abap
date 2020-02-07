*----------------------------------------------------------------------*
***INCLUDE LZHMS_FG_DOCUMENTF02 .
*----------------------------------------------------------------------*

*{   INSERT         DEVK900076                                        1
*&---------------------------------------------------------------------*
*&      Form  F_VERSAO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form F_VERSAO USING l_lv_valor .

*** Busca versão
   CLEAR l_lv_valor .
   SELECT SINGLE versn FROM zhms_tb_ev_vrs INTO l_lv_valor  WHERE natdc  EQ '02'
                                                              AND typed  EQ 'NFE'
                                                              AND event  EQ '2'
                                                              AND ativo  EQ 'X'.

endform.                    " F_VERSAO

*}   INSERT

*{   INSERT         DEVK900085                                        2

*}   INSERT
