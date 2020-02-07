*&---------------------------------------------------------------------*
*& Report  ZHMS_EXEC_CARGA
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zhms_exec_carga.

DATA: lv_filename TYPE string,
      lv_count    TYPE sy-tabix.

SELECTION-SCREEN BEGIN OF BLOCK b0 WITH FRAME TITLE text-001.
PARAMETERS:   parqv TYPE  rlgrap-filename OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b0.

INITIALIZATION.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR parqv.

START-OF-SELECTION.

  CLEAR lv_count.
  DO 43 TIMES.

    ADD 1 TO lv_count.

    CASE lv_count.
      WHEN '1'.

        CLEAR lv_filename.
        CONCATENATE parqv '\01 - ZHMS_CARGA_NATURE_TX.xlsx' INTO lv_filename.
        SUBMIT zhms_carga_nature_tx WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 01 - ZHMS_CARGA_NATURE_TX'.
        ENDIF.

      WHEN '2'.

        CLEAR lv_filename.
        CONCATENATE parqv '\02 - ZHMS_CARGA_NATURE.xlsx' INTO lv_filename.
        SUBMIT zhms_carga_nature WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 02 - ZHMS_CARGA_NATURE'.
        ENDIF.

      WHEN '3'.

        CLEAR lv_filename.
        CONCATENATE parqv '\03 - ZHMS_CARGA_TYPE_TX.xlsx' INTO lv_filename.
        SUBMIT zhms_carga_type_tx WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 03 - ZHMS_CARGA_TYPE_TX'.
        ENDIF.

      WHEN '4'.

        CLEAR lv_filename.
        CONCATENATE parqv '\04 - ZHMS_CARGA_TYPE.xlsx' INTO lv_filename.
        SUBMIT zhms_carga_type WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 04 - ZHMS_CARGA_TYPE'.
        ENDIF.

      WHEN '5'.

        CLEAR lv_filename.
        CONCATENATE parqv '\05 - ZHMS_CARGA_EVENTS_TX.xlsx' INTO lv_filename.
        SUBMIT zhms_carga_events_tx WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 05 - ZHMS_CARGA_EVENTS_TX'.
        ENDIF.

      WHEN '6'.

        CLEAR lv_filename.
        CONCATENATE parqv '\06 - ZHMS_CARGA_EVENTS.xlsx' INTO lv_filename.
        SUBMIT zhms_carga_events WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 06 - ZHMS_CARGA_EVENTS'.
        ENDIF.

      WHEN '7'.

        CLEAR lv_filename.
        CONCATENATE parqv '\07 - ZHMS_CARGA_EV_VRS.xlsx' INTO lv_filename.
        SUBMIT zhms_carga_ev_vrs WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 07 - ZHMS_CARGA_EV_VR'.
        ENDIF.

      WHEN '8'.

        CLEAR lv_filename.
        CONCATENATE parqv '\08 - ZHMS_CARGA_EVV_LAYT_TX.txt' INTO lv_filename.
        SUBMIT zhms_carga_evv_layt_tx WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 08 - ZHMS_CARGA_EVV_LAYT_TX'.
        ENDIF.

      WHEN '9'.

        CLEAR lv_filename.
        CONCATENATE parqv '\09 - ZHMS_CARGA_EVV_LAYT.txt' INTO lv_filename.
        SUBMIT zhms_carga_evv_layt WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 09 - ZHMS_CARGA_EVV_LAYT'.
        ENDIF.

      WHEN '10'.

        CLEAR lv_filename.
        CONCATENATE parqv '\10 - ZHMS_CARGA_MESSAGIN_TX.XLSX' INTO lv_filename.
        SUBMIT zhms_carga_messagin_tx WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 10 - ZHMS_CARGA_MESSAGIN_TX'.
        ENDIF.

      WHEN '11'.

        CLEAR lv_filename.
        CONCATENATE parqv '\11 - ZHMS_CARGA_MESSAGIN.XLSX' INTO lv_filename.
        SUBMIT zhms_carga_messagin WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 11 - ZHMS_CARGA_MESSAGIN'.
        ENDIF.

      WHEN '12'.

        CLEAR lv_filename.
        CONCATENATE parqv '\12 - ZHMS_CARGA_MSG_EVEN.XLSX' INTO lv_filename.
        SUBMIT zhms_carga_msg_even WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 12 - ZHMS_CARGA_MSG_EVEN'.
        ENDIF.

      WHEN '13'.

        CLEAR lv_filename.
        CONCATENATE parqv '\13 - ZHMS_CARGA_MAPPING_TX.txt' INTO lv_filename.
        SUBMIT zhms_carga_mapping_tx WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 13 - ZHMS_CARGA_MAPPING_TX'.
        ENDIF.

      WHEN '14'.

        CLEAR lv_filename.
        CONCATENATE parqv '\14 - ZHMS_CARGA_MAPPING.XLSX' INTO lv_filename.
        SUBMIT zhms_carga_mapping WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 14 - ZHMS_CARGA_MAPPING'.
        ENDIF.

      WHEN '15'.

        CLEAR lv_filename.
        CONCATENATE parqv '\15 - ZHMS_CARGA_MAPDATA.XLSX' INTO lv_filename.
        SUBMIT zhms_carga_mapdata WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 15 - ZHMS_CARGA_MAPDATA'.
        ENDIF.

      WHEN '16'.

        CLEAR lv_filename.
        CONCATENATE parqv '\16 - ZHMS_CARGA_MSGE_VRS.XLSX' INTO lv_filename.
        SUBMIT zhms_carga_msge_vrs WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 16 - ZHMS_CARGA_MSGE_VRS'.
        ENDIF.

      WHEN '17'.

        CLEAR lv_filename.
        CONCATENATE parqv '\17 - ZHMS_CARGA_TOOL.XLSX' INTO lv_filename.
        SUBMIT zhms_carga_tool WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 17 - ZHMS_CARGA_TOO'.
        ENDIF.

      WHEN '18'.

        CLEAR lv_filename.
        CONCATENATE parqv '\18 - ZHMS_CARGA_GATEMNEU_TX.XLSX' INTO lv_filename.
        SUBMIT zhms_carga_gatemneu_tx WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 18 - ZHMS_CARGA_GATEMNEU_TX'.
        ENDIF.

      WHEN '19'.

        CLEAR lv_filename.
        CONCATENATE parqv '\19 - ZHMS_CARGA_GATEMNEU.XLSX' INTO lv_filename.
        SUBMIT zhms_carga_gatemneu WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 19 - ZHMS_CARGA_GATEMNEU'.
        ENDIF.

      WHEN '20'.

        CLEAR lv_filename.
        CONCATENATE parqv '\20 - ZHMS_CARGA_GATE_TX.XLSX' INTO lv_filename.
        SUBMIT zhms_carga_gate_tx WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 20 - ZHMS_CARGA_GATE_TX'.
        ENDIF.

      WHEN '21'.

        CLEAR lv_filename.
        CONCATENATE parqv '\21 - ZHMS_CARGA_GATE.XLSX' INTO lv_filename.
        SUBMIT zhms_carga_gate WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 21 - ZHMS_CARGA_GATE'.
        ENDIF.

      WHEN '22'.

        CLEAR lv_filename.
        CONCATENATE parqv '\22 - ZHMS_CARGA_TX_REGVLD.XLSX' INTO lv_filename.
        SUBMIT zhms_carga_tx_regvld WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 22 - ZHMS_CARGA_TX_REGVLD'.
        ENDIF.

      WHEN '23'.

        CLEAR lv_filename.
        CONCATENATE parqv '\23 - ZHMS_CARGA_TX_PKGVLD.XLSX' INTO lv_filename.
        SUBMIT zhms_carga_tx_pkgvld WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 23 - ZHMS_CARGA_TX_PKGVLD'.
        ENDIF.

      WHEN '24'.

        CLEAR lv_filename.
        CONCATENATE parqv '\24 - ZHMS_CARGA_PKGVLD.XLSX' INTO lv_filename.
        SUBMIT zhms_carga_pkgvld WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 24 - ZHMS_CARGA_PKGVLD'.
        ENDIF.

      WHEN '25'.

        CLEAR lv_filename.
        CONCATENATE parqv '\25 - ZHMS_CARGA_GRPFLD_TX.XLSX' INTO lv_filename.
        SUBMIT zhms_carga_grpfld_tx WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 25 - ZHMS_CARGA_GRPFLD_TX'.
        ENDIF.

      WHEN '26'.

        CLEAR lv_filename.
        CONCATENATE parqv '\26 - ZHMS_CARGA_GRPFLD.XLSX' INTO lv_filename.
        SUBMIT zhms_carga_grpfld WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 26 - ZHMS_CARGA_GRPFLD'.
        ENDIF.

      WHEN '27'.

        CLEAR lv_filename.
        CONCATENATE parqv '\27 - ZHMS_CARGA_GRPFLD_S.XLSX' INTO lv_filename.
        SUBMIT zhms_carga_grpfld_s WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 27 - ZHMS_CARGA_GRPFLD_S'.
        ENDIF.

      WHEN '28'.

        CLEAR lv_filename.
        CONCATENATE parqv '\28 - ZHMS_CARGA_MSGEV_LT.txt' INTO lv_filename.
        SUBMIT zhms_carga_msgev_lt WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 28 - ZHMS_CARGA_MSGEV_LT'.
        ENDIF.

      WHEN '29'.

        CLEAR lv_filename.
        CONCATENATE parqv '\29 - ZHMS_CARGA_MSGEV_A.XLSX' INTO lv_filename.
        SUBMIT zhms_carga_msgev_a WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 29 - ZHMS_CARGA_MSGEV_A'.
        ENDIF.

      WHEN '30'.

        CLEAR lv_filename.
        CONCATENATE parqv '\30 - ZHMS_CARGA_EVVL_ATR.txt' INTO lv_filename.
        SUBMIT zhms_carga_evvl_atr WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 30 - ZHMS_CARGA_EVVL_ATR'.
        ENDIF.

      WHEN '31'.

        CLEAR lv_filename.
        CONCATENATE parqv '\31 - ZHMS_CARGA_MSGEVL_A.txt' INTO lv_filename.
        SUBMIT zhms_carga_msgevl_a WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 31 - ZHMS_CARGA_MSGEVL_A'.
        ENDIF.

      WHEN '32'.

        CLEAR lv_filename.
        CONCATENATE parqv '\32 - ZHMS_CARGA_MAPPCONE.txt' INTO lv_filename.
        SUBMIT zhms_carga_mappcone WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 32 - ZHMS_CARGA_MAPPCONE'.
        ENDIF.

      WHEN '33'.

        CLEAR lv_filename.
        CONCATENATE parqv '\33 - ZHMS_CARGA_MAPCONEC.txt' INTO lv_filename.
        SUBMIT zhms_carga_mapconec WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 33 - ZHMS_CARGA_MAPCONEC'.
        ENDIF.

      WHEN '34'.

        CLEAR lv_filename.
        CONCATENATE parqv '\34 - ZHMS_CARGA_MAPDATAC.txt' INTO lv_filename.
        SUBMIT zhms_carga_mapdatac WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 34 - ZHMS_CARGA_MAPDATAC'.
        ENDIF.

      WHEN '35'.

        CLEAR lv_filename.
        CONCATENATE parqv '\35 - ZHMS_CARGA_DCITM.txt' INTO lv_filename.
        SUBMIT zhms_carga_dcitm WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 35 - ZHMS_CARGA_DCITM'.
        ENDIF.

      WHEN '36'.

        CLEAR lv_filename.
        CONCATENATE parqv '\36 - ZHMS_CARGA_SCENARIO.txt' INTO lv_filename.
        SUBMIT zhms_carga_scenario WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 36 - ZHMS_CARGA_SCENARIO'.
        ENDIF.

      WHEN '37'.

        CLEAR lv_filename.
        CONCATENATE parqv '\37 - ZHMS_CARGA_SCEN_FLO.txt' INTO lv_filename.
        SUBMIT zhms_carga_scen_flo WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 37 - ZHMS_CARGA_SCEN_FLO'.
        ENDIF.

      WHEN '38'.

        CLEAR lv_filename.
        CONCATENATE parqv '\38 - ZHMS_CARGA_SCEN_FLO_TX.txt' INTO lv_filename.
        SUBMIT zhms_carga_scen_flo_tx WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 38 - ZHMS_CARGA_SCEN_FLO_TX'.
        ENDIF.

      WHEN '39'.

        CLEAR lv_filename.
        CONCATENATE parqv '\39 - ZHMS_CARGA_TX_SCENARIO.txt' INTO lv_filename.
        SUBMIT zhms_carga_tx_scenario WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 39 - ZHMS_CARGA_TX_SCENARIO'.
        ENDIF.

      WHEN '40'.

        CLEAR lv_filename.
        CONCATENATE parqv '\40 - ZHMS_CARGA_FILDCITM.txt' INTO lv_filename.
        SUBMIT zhms_carga_fildcitm WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 40 - ZHMS_CARGA_FILDCITM'.
        ENDIF.

      WHEN '41'.

        CLEAR lv_filename.
        CONCATENATE parqv '\41 - ZHMS_CARGA_MNEUATR.XLSX' INTO lv_filename.
        SUBMIT zhms_carga_mneuatr WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 41 - ZHMS_CARGA_MNEUATR'.
        ENDIF.

      WHEN '42'.

        CLEAR lv_filename.
        CONCATENATE parqv '\42 - ZHMS_CARGA_REGVLD.XLSX' INTO lv_filename.
        SUBMIT zhms_carga_regvld WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 42 - ZHMS_CARGA_REGVLD '.
        ENDIF.

      WHEN '43'.

        CLEAR lv_filename.
        CONCATENATE parqv '\43 - ZHMS_CARGA_MESSAGES.txt' INTO lv_filename.
        SUBMIT zhms_carga_messages WITH parqv EQ lv_filename EXPORTING LIST TO MEMORY AND RETURN.

        IF sy-subrc IS NOT INITIAL.
          WRITE / 'Erro ao executar o programa 43 - ZHMS_CARGA_MESSAGES '.
        ENDIF.

    ENDCASE.

  ENDDO.
