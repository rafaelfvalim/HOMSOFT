*&---------------------------------------------------------------------*
*& Report  ZHMS_VALIDA_CONFIG
*&
*&---------------------------------------------------------------------*
*& RCP - Tradução EN/ES - 14/08/2018
*&---------------------------------------------------------------------*

REPORT  zhms_valida_config.

DATA: lv_count TYPE i.

CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_cf_email INTO lv_count WHERE tp_email NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_CF_EMAIL'.
ENDIF.

CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_cfop INTO lv_count WHERE cfop NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_CFOP'.
ENDIF.

CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_cnae INTO lv_count WHERE bukrs NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_CNAE'.
ENDIF.

CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_condpagt INTO lv_count WHERE zterm NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_CONDPAGT'.
ENDIF.

CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_consumo INTO lv_count WHERE cnpj NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_CONSUMO'.
ENDIF.

CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_dcitm INTO lv_count WHERE codmp NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_DCITM'.
ENDIF.

CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_dp_parvw INTO lv_count WHERE parvw NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_DP_PARVW'.
ENDIF.

CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_ev_flow INTO lv_count WHERE natdc NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_EV_FLOW'.
ENDIF.

CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_ev_vrs INTO lv_count WHERE natdc NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_EV_VRS'.
ENDIF.

CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_events INTO lv_count WHERE natdc NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_EVENTS'.
ENDIF.

CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_evv_layt INTO lv_count WHERE natdc NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_EVV_LAYT'.
ENDIF.

CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_evvl_atr INTO lv_count WHERE natdc NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_EVVL_ATR'.
ENDIF.

CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_fildcitm INTO lv_count WHERE codmp NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_FILDCITM'.
ENDIF.

CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_gate INTO lv_count WHERE gate NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_GATE'.
ENDIF.

CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_gatemneu INTO lv_count WHERE gate NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_GATEMNEU'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_gateobs INTO lv_count WHERE gate NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_GATEOBS'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_grpfld INTO lv_count WHERE codgf NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_GRPFLD'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_grpfld_s INTO lv_count WHERE codgf NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_GRPFLD_S'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_mail INTO lv_count WHERE natdc NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_MAIL'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_map_lay INTO lv_count WHERE natdc NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_MAP_LAY'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_map_layo INTO lv_count WHERE natdc NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_MAP_LAYO'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_mapconec INTO lv_count WHERE natdc NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_MAPCONEC'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_mapdata INTO lv_count WHERE codmp NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_MAPDATA'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_mapdatac INTO lv_count WHERE codmp NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_MAPDATAC'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_mappcone INTO lv_count WHERE codmp NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_MAPPCONE'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_mapping INTO lv_count WHERE codmp NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_MAPPING'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_messages INTO lv_count WHERE code NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_MESSAGES'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_messagin INTO lv_count WHERE natdc NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_MESSAGIN'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_mneuatr INTO lv_count WHERE mnorg NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_MNEUATR'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_msg_even INTO lv_count WHERE natdc NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_MSG_EVEN'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_msge_vrs INTO lv_count WHERE natdc NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_MSGE_VRS'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_msgev_lt INTO lv_count WHERE natdc NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_MSGEV_LT'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_msgev_mt INTO lv_count WHERE natdc NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_MSGEV_MT'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_msgevl_a INTO lv_count WHERE natdc NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_MSGEVL_A'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_msgevm_a INTO lv_count WHERE natdc NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_MSGEVM_A'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_nature INTO lv_count WHERE natdc NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_NATURE'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_nfeevt INTO lv_count WHERE natdc NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_NFEEVTL'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_pkgvld INTO lv_count WHERE vldcd NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_PKGVLD'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_regvld INTO lv_count WHERE vldcd NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_REGVLD'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_scen_flo INTO lv_count WHERE natdc NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_SCEN_FLO'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_scenario INTO lv_count WHERE natdc NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_SCENARIO'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_scenfloc INTO lv_count WHERE natdc NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_SCENFLOC'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_security INTO lv_count WHERE usuario NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_SECURITY'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_show_lay INTO lv_count WHERE tipo NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_SHOW_LAY'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_tconfig INTO lv_count WHERE tcode NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_TCONFIG'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_toolbar INTO lv_count WHERE natdc NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_TOOLBAR'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_tpamb INTO lv_count WHERE tpamb NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_TPAMB'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_type INTO lv_count WHERE natdc NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_TYPE'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_unit INTO lv_count WHERE unidadesap NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_UNIT'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_user_rfc INTO lv_count WHERE usuario NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_USER_RFC'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_vld_item INTO lv_count WHERE natdc NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_VLD_ITEM'.
ENDIF.
CLEAR lv_count.
SELECT COUNT( * ) FROM zhms_tb_vld_tax INTO lv_count WHERE tax_type NE ' '.

IF lv_count IS INITIAL.
  WRITE /'Falta parametrização na tabela ZHMS_TB_VLD_TAX'.
ENDIF.
