*----------------------------------------------------------------------*
*                                                                      *
*            |------------------------------------------|              *
*            |          H   O   M   I   N   E           |              *
*            |------------------------------------------|              *
*                                                                      *
*----------------------------------------------------------------------*
* Transação:     zhms_180_dias                                         *
* Programa:      zhms_report_180_dias                                  *
* Descrição:     Controle de estoque de 180 dias para sub-contratação  *
* Desenvolvedor: RDR                                                   *
* Data:          10.12.2019                                            *
*----------------------------------------------------------------------*

REPORT  zhms_report_180_dias NO STANDARD PAGE HEADING.

INCLUDE zhms_report_180_dias_top. "Declarações dados Globais
INCLUDE zhms_report_180_dias_f01. "Rotinas Gerais


*--------------------------------------------------------------------*
* Evento START-OF-SELECTION
*--------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_seleciona_dados. "Seleção em todas as tabelas
  PERFORM f_trata_dados.     "Trata os dados para Saída em ALV
  PERFORM f_exibe_alv.       "Impressão do Relatório ALV
