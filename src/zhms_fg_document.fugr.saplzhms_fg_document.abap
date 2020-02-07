*******************************************************************
*   System-defined Include-files.                                 *
*******************************************************************

  INCLUDE LZHMS_FG_DOCUMENTTOP.              " Global Data
  INCLUDE LZHMS_FG_DOCUMENTUXX.              " Function Modules

*******************************************************************
*   User-defined Include-files (if necessary).                    *
*******************************************************************
* INCLUDE LZHMS_FG_DOCUMENTF...              " Subroutines
* INCLUDE LZHMS_FG_DOCUMENTO...              " PBO-Modules
* INCLUDE LZHMS_FG_DOCUMENTI...              " PAI-Modules
* INCLUDE LZHMS_FG_DOCUMENTE...              " Events
* INCLUDE LZHMS_FG_DOCUMENTP...              " Local class implement.

INCLUDE LZHMS_FG_DOCUMENTF01.
*{   INSERT         DEVK900076                                        1
*
INCLUDE LZHMS_FG_DOCUMENTF02.
*}   INSERT

*RCP - 06/08/2018 - Início
*Novo include referente a envio de e-mail para as Etapas Conferência, MIGO e MIRO
INCLUDE LZHMS_FG_DOCUMENTF03.
*RCP - 06/08/2018 - Fim
