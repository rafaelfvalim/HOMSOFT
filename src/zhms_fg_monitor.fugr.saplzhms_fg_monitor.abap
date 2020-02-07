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
    INCLUDE: lzhms_fg_monitortop,             " Declarações Globais
             lzhms_fg_monitoruxx.             " Function Modules

************************************************************************
*   User-defined Include-files                                         *
************************************************************************
    INCLUDE: lzhms_fg_monitor001,           " Módulo PBO
             lzhms_fg_monitori01,           " Módulo PAI

             lzhms_fg_monitorp01,           " Classes (Monitor)
             lzhms_fg_monitorf01,           " Sub-Rotinas (Monitor)

             lzhms_fg_monitorp02,           " Classes (Atribuição)
             lzhms_fg_monitorf02,           " Sub-Rotinas (Atribuição)

             lzhms_fg_monitorp03,           " Classes (Validações)
             lzhms_fg_monitorf03,           " Sub-Rotinas (Validações)

             lzhms_fg_monitorp05,           " Classes (Conferência)
             lzhms_fg_monitorf05,           " Sub-Rotinas (Conferência)

             lzhms_fg_monitorp06,           " Classes (LOG's)
             lzhms_fg_monitorf06,           " Sub-Rotinas (LOG's)

             lzhms_fg_monitorp07,           " Classes (Atribuições)
             lzhms_fg_monitorf07.           " Sub-Rotinas (Atribuições)

*INCLUDE LZHMS_FG_MONITORP04.

INCLUDE LZHMS_FG_MONITORF04.

*&SPWizard: Include inserted by SP Wizard. DO NOT CHANGE THIS LINE!
INCLUDE LZHMS_FG_MONITORO01 .
*{   INSERT         DEVK900059                                        1
*
INCLUDE LZHMS_FG_MONITORP04.
*}   INSERT
*{   INSERT         EU1K9A0ZAB                                        2
*
INCLUDE lzhms_fg_monitoro02.
*}   INSERT
*{   INSERT         EU1K9A0ZAB                                        3
*
INCLUDE lzhms_fg_monitori02.
*}   INSERT

*RCP - 06/08/2018 - Início
*Novo include referente a envio de e-mail para a Etapa de Portaria
INCLUDE LZHMS_FG_MONITORF08.
*RCP - 06/08/2018 - Fim
