*----------------------------------------------------------------------*
*                      H  o  m  S  o  f  t                             *
*          Gestão Eletrônica de Documentos e Processos                 *
*----------------------------------------------------------------------*
* Descrição: Monitor Central de Gerenciamento de Documentos            *
*            Grupo Funções Principal do Monitor                        *
*----------------------------------------------------------------------*

************************************************************************
*   System-defined Include-files.                                      *
************************************************************************
    INCLUDE: LZHMS_FG_MONITOR_SAPTOP,             " Declarações Globais
             LZHMS_FG_MONITOR_SAPUXX.             " Function Modules

************************************************************************
*   User-defined Include-files                                         *
************************************************************************
INCLUDE LZHMS_FG_MONITOR_SAP001.
*    INCLUDE: lzhms_fg_monitor001,           " Módulo PBO
INCLUDE LZHMS_FG_MONITOR_SAPI01.
*             lzhms_fg_monitori01,           " Módulo PAI

INCLUDE LZHMS_FG_MONITOR_SAPP01.
*             lzhms_fg_monitorp01,           " Classes (Monitor)
INCLUDE LZHMS_FG_MONITOR_SAPF01.
*             lzhms_fg_monitorf01,           " Sub-Rotinas (Monitor)

INCLUDE LZHMS_FG_MONITOR_SAPP02.
*             lzhms_fg_monitorp02,           " Classes (Atribuição)
INCLUDE LZHMS_FG_MONITOR_SAPF02.
*             lzhms_fg_monitorf02,           " Sub-Rotinas (Atribuição)

INCLUDE LZHMS_FG_MONITOR_SAPP03.
*             lzhms_fg_monitorp03,           " Classes (Validações)
INCLUDE LZHMS_FG_MONITOR_SAPF03.
*             lzhms_fg_monitorf03,           " Sub-Rotinas (Validações)

INCLUDE LZHMS_FG_MONITOR_SAPP05.
*             lzhms_fg_monitorp05,           " Classes (Conferência)
INCLUDE LZHMS_FG_MONITOR_SAPF05.
*             lzhms_fg_monitorf05,           " Sub-Rotinas (Conferência)

INCLUDE LZHMS_FG_MONITOR_SAPP06.
*             lzhms_fg_monitorp06,           " Classes (LOG's)
INCLUDE LZHMS_FG_MONITOR_SAPF06.
*             lzhms_fg_monitorf06,           " Sub-Rotinas (LOG's)

INCLUDE LZHMS_FG_MONITOR_SAPP07.
*             lzhms_fg_monitorp07,           " Classes (Atribuições)
INCLUDE LZHMS_FG_MONITOR_SAPF07.
*             lzhms_fg_monitorf07.           " Sub-Rotinas (Atribuições)

*INCLUDE LZHMS_FG_MONITORP04.

INCLUDE LZHMS_FG_MONITOR_SAPF04.
*INCLUDE LZHMS_FG_MONITORF04.

*&SPWizard: Include inserted by SP Wizard. DO NOT CHANGE THIS LINE!
INCLUDE LZHMS_FG_MONITOR_SAPO01.
*INCLUDE LZHMS_FG_MONITORO01 .
*{   INSERT         DEVK900059                                        1
*
INCLUDE LZHMS_FG_MONITOR_SAPP04.
*INCLUDE LZHMS_FG_MONITORP04.
*}   INSERT
*{   INSERT         EU1K9A0ZAB                                        2
*
INCLUDE LZHMS_FG_MONITOR_SAPO02.
*INCLUDE lzhms_fg_monitoro02.
*}   INSERT
*{   INSERT         EU1K9A0ZAB                                        3
*
INCLUDE LZHMS_FG_MONITOR_SAPI02.
*INCLUDE lzhms_fg_monitori02.
*}   INSERT

*RCP - 06/08/2018 - Início
*Novo include referente a envio de e-mail para a Etapa de Portaria
INCLUDE LZHMS_FG_MONITOR_SAPF08.
*INCLUDE LZHMS_FG_MONITORF08.
*RCP - 06/08/2018 - Fim
