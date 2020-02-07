FUNCTION-POOL zhms_fg_rfc.                  "MESSAGE-ID ..

*---------------------------------------*
*           Tabelas Internas            *
*---------------------------------------*
DATA:      it_msedata     TYPE TABLE OF zhms_es_msgdt,    " Entrada: Estrutura do Arquivo de Comunicação
           it_mseatrb     TYPE TABLE OF zhms_es_msgat,    " Entrada: Atributos de XML
           it_mssdata     TYPE TABLE OF zhms_es_msgdt,    " Saída:   Estrutura do Arquivo de Comunicação
           it_mssatrb     TYPE TABLE OF zhms_es_msgat,    " Saída:   Atributos de XML
           it_mssdatam    TYPE TABLE OF zhms_es_msgdtm,    " Saída:   Estrutura do Arquivo de Comunicação
           it_mssatrbm    TYPE TABLE OF zhms_es_msgatm,    " Saída:   Atributos de XML
           it_return      TYPE TABLE OF zhms_es_return,   " Retorno
           it_messag      TYPE TABLE OF zhms_tb_messagin, " Mensagerias / Legado
           it_msgeve      TYPE TABLE OF zhms_tb_msg_even, " Mensageria / Legado: Eventos
           it_msgevr      TYPE TABLE OF zhms_tb_msge_vrs, " Mensaria / Legado: Eventos: Versão do Layout
           it_atrint      TYPE TABLE OF zhms_es_atrint,   " Atributos - Interno com valores
           it_layint      TYPE TABLE OF zhms_es_layint,   " Layout Interno com valores
           it_msgevlt     TYPE TABLE OF zhms_tb_msgev_lt, " Mensageria / Legado: Eventos: Versão: Layout
           it_msgevl_a    TYPE TABLE OF zhms_tb_msgevl_a, " Mensageria / Legado: Eventos: Layout: Atributos
           it_docum       TYPE TABLE OF zhms_es_docum,    " Documento
           it_evv_layt    TYPE TABLE OF zhms_tb_evv_layt, " Eventos: Layout
           it_evvl_atr    TYPE TABLE OF zhms_tb_evvl_atr,
           it_ev_vrs      TYPE TABLE OF zhms_tb_ev_vrs,
           it_logunk      TYPE TABLE OF zhms_tb_logunk,
           it_msgunk      TYPE TABLE OF zhms_tb_msgunk,
           it_msgunka     TYPE TABLE OF zhms_tb_msgunka,
*DDPT - Inicio da Inclusão
           it_ev_CRC      type table of ZHMS_TB_EXC_CRC,
           it_mssdata_aux TYPE TABLE OF zhms_es_msgdt,    " Saída:   Estrutura do Arquivo de Comunicação
*DDPT - Fim da Inclusão

           "Tabelas para Mapeamentos
           it_mapcabdoc   TYPE TABLE OF zhms_tb_mapdatac,
           it_mapitmdoc   TYPE TABLE OF zhms_tb_mapdatac,
           it_mapdocst    TYPE TABLE OF zhms_tb_mapdatac,
           it_mapevst     TYPE TABLE OF zhms_tb_mapdatac,
           it_mapconec    TYPE TABLE OF zhms_tb_mapconec,
           it_mapdatac    TYPE TABLE OF zhms_tb_mapdatac,

           it_cabdoc      TYPE TABLE OF zhms_tb_cabdoc,
           it_itmdoc      TYPE TABLE OF zhms_tb_itmdoc,
           it_docmn       TYPE TABLE OF zhms_tb_docmn,    " Repositório de Documentos - Mneumônicos
           it_docmna      TYPE TABLE OF zhms_tb_docmna,   " Repositório de Documentos - Mneumônicos
           it_repdoc      TYPE TABLE OF zhms_tb_repdoc,   " Repositório de XML
           it_repdocat    TYPE TABLE OF zhms_tb_repdocat,
           it_dcitm       TYPE TABLE OF zhms_tb_dcitm,
           it_fildcitm    TYPE TABLE OF zhms_tb_fildcitm,

           "Tabelas Gerais - Repositorio de tags e de mneumônicos
           it_repotag     TYPE TABLE OF zhms_tb_repdoc,   "Repositório tag
           it_repotagat   TYPE TABLE OF zhms_tb_repdocat, "Repositório atributos
           it_repomneum   TYPE TABLE OF zhms_tb_docmn,    "Repositório Mneumônicos
           it_repomneumat TYPE TABLE OF zhms_tb_docmna,

           it_evmn        TYPE TABLE OF zhms_tb_evmn,
           it_evmna       TYPE TABLE OF zhms_tb_evmna,
           it_repcom      TYPE TABLE OF zhms_tb_repcom,
           it_repcoma     TYPE TABLE OF zhms_tb_repcoma.

*---------------------------------------*
*              Work Areas               *
*---------------------------------------*
DATA:     " wa_msedata   TYPE zhms_es_msgdt,    " Entrada: Estrutura do Arquivo de Comunicação
         "  wa_mseatrb   TYPE zhms_es_msgat,    " Entrada: Atributos de XML
           wa_cf_email    TYPE zhms_tb_cf_email,
           wa_mssdata     TYPE zhms_es_msgdt,    " Saída:   Estrutura do Arquivo de Comunicação
           wa_mssdatax    TYPE zhms_es_msgdt,
           ls_ekko        TYPE ekko,
           wa_mssatrb     TYPE zhms_es_msgat,    " Saída:   Atributos de XML
           wa_mssdatam    TYPE zhms_es_msgdtm,    " Saída:   Estrutura do Arquivo de Comunicação
           wa_mssatrbm    TYPE zhms_es_msgatm,    " Saída:   Atributos de XML
           wa_return      TYPE zhms_es_return,   " Retorno de RFC
           wa_messag      TYPE zhms_tb_messagin, " Mensagerias / Legado
           wa_msgeve      TYPE zhms_tb_msg_even, " Mensageria / Legado: Eventos'
           wa_msgevr      TYPE zhms_tb_msge_vrs, " Mensaria / Legado: Eventos: Versão do Layout
           wa_atrint      TYPE zhms_es_atrint,   " Atributos - Interno com valores
           wa_layint      TYPE zhms_es_layint,   " Layout Interno com valores
           wa_msgevlt     TYPE zhms_tb_msgev_lt, " Mensageria / Legado: Eventos: Versão: Layout
           wa_msgevl_a    TYPE zhms_tb_msgevl_a, " Mensageria / Legado: Eventos: Layout: Atributos
           wa_docum       TYPE zhms_es_docum,    " Documento
           wa_evv_layt    TYPE zhms_tb_evv_layt, " Eventos: Layout
           wa_evv_laytx   TYPE zhms_tb_evv_layt, " Eventos: Layout
           wa_ev_vrs      TYPE zhms_tb_ev_vrs,
           wa_evvl_atr    TYPE zhms_tb_evvl_atr,
           wa_scenfloc    TYPE zhms_tb_scenfloc,
           wa_mappcone    TYPE zhms_tb_mappcone,
           wa_mapconec    TYPE zhms_tb_mapconec,
           wa_mapdatac    TYPE zhms_tb_mapdatac,
*DDPT - Inicio da Inclusão
           wa_ev_CRC      type ZHMS_TB_EXC_CRC,
           wa_mssdata_aux TYPE zhms_es_msgdt,    " Saída:   Estrutura do Arquivo de Comunicação
*DDPT - Fim da Inclusão

           "Work Area para Documentos
           wa_repdoc      TYPE zhms_tb_repdoc,   " Repositório de XML
           wa_repdocat    TYPE zhms_tb_repdocat,
           wa_docmn       TYPE zhms_tb_docmn,    " Repositório de Documentos - Mneumônicos
           wa_docmna      TYPE zhms_tb_docmna,
           wa_cabdoc      TYPE zhms_tb_cabdoc,   " Cabeçalhos de Documentos Eletrônicos
           wa_itmdoc      TYPE zhms_tb_itmdoc,
           wa_docst       TYPE zhms_tb_docst,
           wa_fildcitm    TYPE zhms_tb_fildcitm,
           wa_dcitm       TYPE zhms_tb_dcitm,

           wa_evmn        TYPE zhms_tb_evmn,    " Repositório de Documentos - Mneumônicos
           wa_evmna       TYPE zhms_tb_evmna,
           wa_cabeve      TYPE zhms_tb_cabeve,   " Cabeçalhos de Documentos Eletrônicos
           wa_evst        TYPE zhms_tb_evst,
           wa_repcom      TYPE zhms_tb_repcom,
           wa_repcoma     TYPE zhms_tb_repcoma,
           wa_histeve     TYPE zhms_tb_histev,

           "Work Area Gerais
           wa_repotag     TYPE zhms_tb_repdoc,
           wa_repotagat   TYPE zhms_tb_repdocat,
           wa_repomneum   TYPE zhms_tb_docmn,
           wa_repomneumat TYPE zhms_tb_docmna,

           wa_logunk      TYPE zhms_tb_logunk,
           wa_msgunk      TYPE zhms_tb_msgunk,
           wa_msgunka     TYPE zhms_tb_msgunka,
           wa_j_1bnfe_active  TYPE j_1bnfe_active,
           wa_j1bnfdoc    TYPE j_1bnfdoc.

*---------------------------------------*
*               Variáveis               *
*---------------------------------------*
DATA:      v_critc          TYPE zhmat_de_errcrt,   " Erro Crítico
           v_direc          TYPE zhms_de_direc,     " Direção de documento
           v_mensg          TYPE zhms_de_mensg,     " Mensageria
           v_natdc          TYPE zhms_de_natdc,     " Natureza Documento
           v_typed          TYPE zhms_de_typed,     " Tipo de Documento
           v_loctp          TYPE zhms_de_loctp,     " Localidade
           v_event          TYPE zhms_de_event,     " Evento Documento
           v_versn          TYPE zhms_de_versn,     " Versão
           v_tabix          TYPE sy-tabix,          " Contador de indices para tabela
           v_exnat          TYPE zhms_de_exnat,     " Denominador Externo: Natureza do documento
           v_extpd          TYPE zhms_de_extpd,     " Denominação Externa: Tipo de Documento
           v_exevt          TYPE zhms_de_exevt,     " Denominador Externo: Evento
           v_versnleg       TYPE zhms_de_versn,
           v_seqnr          TYPE zhms_de_seqnr,
           v_dcitm          TYPE zhms_de_dcitm,
           v_chave(44)      TYPE c,
           v_naograva(1)    TYPE c,
           v_tipo           LIKE dd01v-datatype,
           v_ebeln          TYPE ekko-ebeln,
           v_tpeve          TYPE zhms_de_tpeve,
           v_nseqev         TYPE zhms_de_nseqev,
           v_data           TYPE dats,
           v_data_xml       TYPE char30,
           v_datacte(10)    TYPE c,
           v_hora           TYPE tims,
           v_loted          TYPE zhms_de_lote,
           v_chaverec(44)   TYPE c,
           v_nrmsg          TYPE zhms_de_nrmsg,
           v_seqnc(5)       TYPE c,
           v_usuar          TYPE uname,
           v_import(1)      TYPE c,
           v_cnpjemp        TYPE stcd1,
           v_nnf(9)         TYPE c,
           v_cstat          TYPE c LENGTH 5,
           v_serie          TYPE j_1bseries,
           v_demi(10)       TYPE c,
           v_cpf_cnpj(14)   TYPE c,
           v_bukrs          TYPE bukrs,
           v_Importacao     TYPE c,
           v_subcontratacao TYPE c,
*Subcontratação para 2 NFe (CFOP 5902)
           v_subcontratacao2 TYPE c,
*Subcontratação para 2 NFe (CFOP 5124)
           v_subcontratacao3 TYPE c,
           v_comparacfop   TYPE c length 4,
           v_debposterior   TYPE c.

DATA: lt_email   TYPE STANDARD TABLE OF zhms_tb_mail,
      ls_email    TYPE zhms_tb_mail,
      ls_cabdoc   TYPE zhms_tb_cabdoc,
      lv_ebeln   TYPE ebeln,
      lv_email   TYPE char255,
      lv_cnpj    TYPE stcd1,
      lv_adrnr   TYPE adrnr,
      lv_nnf     TYPE char20,
                 lv_find          TYPE char1.


*---------------------------------------*
*            Field Symbols              *
*---------------------------------------*

FIELD-SYMBOLS:  <fs_field>   TYPE any.

*---------------------------------------*
*            Constants                  *
*---------------------------------------*
"Mneumônicos chaves
CONSTANTS: c_chave      TYPE c LENGTH 5 VALUE 'CHAVE',
           c_chavecte   TYPE c LENGTH 8 VALUE 'CHAVECTE',
           c_tpevemde   TYPE c LENGTH 8 VALUE 'TPEVEMDE',
           c_nseqevmde  TYPE c LENGTH 9 VALUE 'NSEQEVMDE',
           c_tpevecce   TYPE c LENGTH 8 VALUE 'TPEVECCE',
           c_nseqecce   TYPE c LENGTH 9 VALUE 'NSEQEVCCE',
           c_chavenfse1 TYPE c LENGTH 6 VALUE 'CHNFSE',
           "NFSE - chave
*           c_nnf       TYPE c LENGTH 3 VALUE 'NNF',
           c_nnf        TYPE c LENGTH 8 VALUE 'NUMERO',
*           c_serie     TYPE c LENGTH 5 VALUE 'SERIE',
           c_serie      TYPE c LENGTH 10 VALUE 'CODVERIF',
*           c_demi      TYPE c LENGTH 4 VALUE 'DEMI',
           c_demi       TYPE c LENGTH 12 VALUE 'DATAEMISSAO',
           c_cpf        TYPE c LENGTH 16 VALUE 'CPF',
           c_cnpj       TYPE c LENGTH 16 VALUE 'CNPJ'.
*           c_cnpj       TYPE c LENGTH 16 VALUE 'IDENTIFICACAORPS'.
