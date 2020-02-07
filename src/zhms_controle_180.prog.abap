*----------------------------------------------------------------------*
*                                                                      *
*           |--------------------------------------------|             *
*           |          H   O   M   I   N   E             |             *
*           |--------------------------------------------|             *
*                                                                      *
*----------------------------------------------------------------------*
* Transação:     ZHMS_XXXXXXXX                                         *
* Programa:      ZHMS_CONTROLE_180                                     *
* Descrição:     Controle de estoque de 180 dias                       *
* Desenvolvedor: Rodolfo Caruzo                                        *
* Data:          08/03/2018                                            *
*----------------------------------------------------------------------*
* Roseli | Tradução EN e ES | 02/10/2018                               *
*----------------------------------------------------------------------*
REPORT zhms_controle_180.

INCLUDE zhms_controle_180_top. "Declaração dos dados

*----------------------------------------------------------------------*
* TELA DE SELEÇÃO
*----------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK a01 WITH FRAME TITLE text-001.
SELECT-OPTIONS: s_bukrs  FOR zhms_tb_cabdoc-bukrs,
                s_branch FOR zhms_tb_cabdoc-branch,
                s_docnr  FOR zhms_tb_cabdoc-docnr,
                s_chave  FOR zhms_tb_cabdoc-chave,
                s_parid  FOR zhms_tb_cabdoc-parid,
                s_lncdt  FOR j_1bnfdoc-docdat.
*                s_lncdt  FOR zhms_tb_cabdoc-DTALT.
*                s_lncdt  FOR zhms_tb_cabdoc-lncdt.
SELECTION-SCREEN: END OF BLOCK a01.

* Carrega imagem na tela de seleção
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
*----------------------------------------------------------------------*
*  PERFORM f_carrega_imagem.

  INCLUDE zhms_controle_180_f01. "Rotinas

START-OF-SELECTION.
* Libera o container da imagem
*  CALL METHOD go_fig->free( ).
*  CLEAR: go_fig, gv_url.

  PERFORM f_seleciona_dados.

* Chama a tela principal do cockpit
  CALL SCREEN 200.
