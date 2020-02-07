*----------------------------------------------------------------------*
*           |--------------------------------------------|             *
*           |          H   O   M   I   N   E             |             *
*           |--------------------------------------------|             *
*                       H  o  m  S  o  f  t                            *
*----------------------------------------------------------------------*
* Transação:     ZHMS_XXXXXXXXX                                        *
* Programa:      ZHMS_JOB_CHECK_CFOP                                   *
* Descrição:     Job para Controle de CFOPs dos 180 Dias               *
* Desenvolvedor: Rogério Ozório                                        *
* Data:          29/10/2018                                            *
*----------------------------------------------------------------------*
*                                                                      *
*----------------------------------------------------------------------*

REPORT  zhms_job_check_cfop.

INCLUDE zhms_job_check_cfop_top. "Declarações dados Globais no Programa
INCLUDE zhms_job_check_cfop_f01. "Rotinas Gerais no Programa
INCLUDE zhms_job_check_cfop_o01. "PBO das telas do Programa
INCLUDE zhms_job_check_cfop_i01. "PAI das telas do Programa

*&---------------------------------------------------------------------*
START-OF-SELECTION.
*&---------------------------------------------------------------------*
* Libera o container da imagem
  CALL METHOD go_fig->free.

  PERFORM:
    f_inicializacao,
    f_seleciona_dados. "Seleciona os dados

* Chama a tela principal do cockpit
  CALL SCREEN 2000.
