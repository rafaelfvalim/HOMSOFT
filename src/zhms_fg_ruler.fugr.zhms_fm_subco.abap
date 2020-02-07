FUNCTION zhms_fm_subco.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  TABLES
*"      RETURN STRUCTURE  BAPIRET2 OPTIONAL
*"----------------------------------------------------------------------


************************************************************************

***                         Tabelas internas                         ***

************************************************************************

  DATA: tl_logdoc   TYPE TABLE OF zhms_tb_logdoc,

        lt_docmn    TYPE STANDARD TABLE OF zhms_tb_docmn,

        lt_docmnx   TYPE STANDARD TABLE OF zhms_tb_docmn,

        lt_atrib    TYPE STANDARD TABLE OF zhms_tb_itmatr.



************************************************************************

***                            Work Areas                            ***

************************************************************************

  DATA: ls_docmn    LIKE LINE OF lt_docmn,

        ls_message  LIKE LINE OF lt_message,

        ls_docmnx   LIKE LINE OF lt_docmn,

        ls_cabdoc   TYPE zhms_tb_cabdoc,

        ls_return   LIKE LINE OF return,

        wl_logdoc   TYPE zhms_tb_logdoc,

        ls_atrib    LIKE LINE OF lt_atrib.



************************************************************************

***                             Variaveis                            ***

************************************************************************

  DATA: vg_data     TYPE char10,

        vg_demi     TYPE char10,

        vg_demix    TYPE char10,

        vg_datae    TYPE sy-datum,

        vg_po       TYPE ebeln,

        vg_nfe      TYPE char12,

        lv_lines    TYPE n,

        lv_cont     TYPE char2,

        lv_forn     TYPE char12,

        lv_cont_sub TYPE char2,

        lv_message  TYPE string,

        lv_expand   TYPE char17,

        vg_seqnr    TYPE zhms_de_seqnr,

        lv_take     TYPE char17,

        lv_plant    TYPE werks_d,

        lv_div      TYPE gsber.



  REFRESH:tl_logdoc,

          lt_docmn,

          lt_docmnx,

          lt_atrib,

          lt_bdcdata[].



  CLEAR:  ls_docmn,

          ls_message,

          ls_docmnx,

          ls_cabdoc,

          ls_return,

          wl_logdoc,

          ls_atrib,

          lt_bdcdata,

          vg_data,

          vg_demi,

          vg_demix,

          vg_datae,

          vg_po,

          vg_nfe,

          lv_lines,

          lv_cont,

          lv_forn,

          lv_cont_sub,

          lv_message,

          lv_expand,

          vg_seqnr,

          lv_take,

          lv_plant,

          lv_div.



************************************************************************

***                                 XML                             ***

************************************************************************

  SELECT SINGLE *

    FROM zhms_tb_cabdoc

    INTO wa_cabdoc

   WHERE chave EQ v_chave.



  SELECT SINGLE *

    FROM zhms_tb_itmatr

    INTO ls_atrib

   WHERE natdc = wa_cabdoc-natdc

     AND typed = wa_cabdoc-typed

     AND loctp = wa_cabdoc-loctp

     AND chave = wa_cabdoc-chave.



  CLEAR vg_po.

  IF sy-subrc IS INITIAL.

    MOVE ls_atrib-nrsrf TO vg_po.

  ENDIF.



  SELECT *

    FROM zhms_tb_docmn

    INTO TABLE lt_docmn

   WHERE chave = '35180900946478000109550010000339771000339776'.



************************************************************************

***                    Verifica se já foi criado                     ***

************************************************************************

*** Verifica se já foi criada J1B1N

  READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'MATDOC'.



  IF sy-subrc IS INITIAL.



    CONCATENATE 'Documento já foi criado:' ls_docmn-value INTO

lv_message SEPARATED BY space.



    MESSAGE i000(zhmsm_clas_msg) WITH lv_message.



    EXIT.

  ENDIF.



  IF NOT vg_po IS INITIAL.

    READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'NUMRPS'.



    IF sy-subrc IS INITIAL.

      CLEAR vg_nfe.

      MOVE ls_docmn-value TO vg_nfe.

      CONDENSE vg_nfe NO-GAPS.

    ELSE.

      READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'NNF'.

      CLEAR vg_nfe.

      MOVE ls_docmn-value TO vg_nfe.

      CONDENSE vg_nfe NO-GAPS.

    ENDIF.



    IF NOT vg_nfe IS INITIAL.

      READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'SERIE'.

      IF sy-subrc IS INITIAL.

        CONCATENATE vg_nfe '-' ls_docmn-value INTO vg_nfe.

      ENDIF.

    ENDIF.



  ENDIF.



  SELECT SINGLE value

    FROM zhms_tb_docmn

    INTO lv_plant

   WHERE chave EQ v_chave

     AND mneum EQ 'PLANT'.



  IF sy-subrc IS INITIAL.

    SELECT SINGLE gsber

    FROM t134g

    INTO lv_div

    WHERE werks = lv_plant.

  ENDIF.



  CHECK NOT vg_po IS INITIAL AND NOT vg_nfe IS INITIAL.



  WRITE sy-datum TO vg_data USING EDIT MASK '__.__.____'.



  CLEAR ls_docmn.

  READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'DEMI'.

  CLEAR: vg_demix, vg_demi, vg_datae.

  MOVE ls_docmn-value TO vg_datae.

  WRITE vg_datae TO vg_demix USING EDIT MASK '__.__.____'.

  CONDENSE vg_demi NO-GAPS.



  CLEAR ls_docmn.

  READ TABLE lt_docmn INTO ls_docmn WITH KEY mneum = 'CNPJ'.



  SELECT SINGLE kunnr

  FROM kna1

  INTO lv_forn WHERE stcd1 EQ ls_docmn-value.



  IF NOT sy-subrc IS INITIAL.

    SELECT SINGLE lifnr

      FROM lfa1

      INTO lv_forn WHERE stcd1 EQ ls_docmn-value.

  ENDIF.

************************************************************************

***                            Cabeçalho                             ***

************************************************************************

  PERFORM  zf_preenche_bdc USING:

      'X' 'SAPMM07M'                '0200',

      ' ' 'BDC_CURSOR'              'RM07M-WERKS',

      ' ' 'BDC_OKCODE'              '=SEKL',

      ' ' 'MKPF-BLDAT'              vg_demix,

      ' ' 'MKPF-BUDAT'              vg_data,

      ' ' 'RM07M-LFSNR'             vg_nfe,

      ' ' 'RM07M-BWARTWE'           '101',

      ' ' 'RM07M-EBELN'             vg_po,

      ' ' 'RM07M-WERKS'             lv_plant,

      ' ' 'XFULL'                   'X',

      ' ' 'RM07M-WVERS3'            'X'.



************************************************************************

***                      Inicio inclusão items                       ***

************************************************************************

  MOVE  lt_docmn[] TO  lt_docmnx[].



*** exclui Item Filho

  READ TABLE lt_docmnx INTO ls_docmnx WITH KEY value = '5902'.



  IF NOT sy-subrc IS INITIAL.

    READ TABLE lt_docmnx INTO ls_docmnx WITH KEY value = '6902'.

  ENDIF.



  IF sy-subrc IS INITIAL.

    DELETE  lt_docmnx WHERE dcitm EQ ls_docmnx-dcitm.

  ENDIF.



*** Esclui o que não for item

  DELETE  lt_docmnx WHERE dcitm EQ '000000'.

  DELETE ADJACENT DUPLICATES FROM lt_docmnx COMPARING dcitm.

  SORT lt_docmnx ASCENDING BY dcitm.

  CLEAR: lv_lines, lv_cont, lv_cont_sub.

  DESCRIBE TABLE lt_docmnx LINES lv_lines.

  DELETE ADJACENT DUPLICATES FROM lt_docmnx COMPARING dcitm.



*** Seleciona items atribuidos

  SELECT * FROM zhms_tb_itmatr INTO TABLE lt_atrib

  WHERE chave EQ wa_cabdoc-chave.



  LOOP AT lt_docmnx INTO ls_docmnx.

    ADD 1 TO lv_cont.



    READ TABLE lt_atrib INTO ls_atrib WITH KEY chave = ls_docmnx-chave

                                               dcitm = ls_docmnx-dcitm.



    PERFORM  zf_preenche_bdc USING:

        'X' 'SAPMM07M'              '0410',

        ' ' 'BDC_OKCODE'          '/00',

        ' ' 'MSEG-ERFMG'          ls_atrib-atqtd,

        ' ' 'MSEG-ERFME'           ls_atrib-atunm,

        ' ' 'MSEG-J_1BEXBASE'      ls_atrib-atprc,

        ' ' 'DKACB-FMORE'           'X'.



    PERFORM  zf_preenche_bdc USING:

        'X' 'SAPLKACB'              '0002',

        ' ' 'BDC_CURSOR'            'COBL-GSBER',

        ' ' 'BDC_OKCODE'            '=ENTE',

        ' ' 'COBL-GSBER'            lv_div .



  ENDLOOP.

************************************************************************

***                        Finaliza Documento                        ***

************************************************************************

  PERFORM  zf_preenche_bdc USING:

     'X' 'SAPMM07M'                 '0221',

     ' ' 'BDC_OKCODE'               '=BU'.



  CALL TRANSACTION 'MB01' USING gt_bdc

          UPDATE 'S'

          MODE 'A'

          MESSAGES INTO lt_message.





  REFRESH return.

  CLEAR ls_return.



*** grava log homsoft

** verifica Documento Criado

  READ TABLE lt_message INTO ls_message WITH KEY msgtyp = 'S'

                                                 msgid  = 'M7'

                                                 msgnr  = '060'.



  break homine.



  IF NOT sy-subrc IS INITIAL.



    LOOP AT lt_message INTO ls_message WHERE msgtyp = 'E'.

* Registra LOG Erro

      REFRESH tl_logdoc.

      wl_logdoc-logty = 'E'.

      wl_logdoc-logno = '701'.

      APPEND wl_logdoc TO tl_logdoc.



      ls_return-type       = ls_message-msgtyp.

      ls_return-id         = ls_message-msgid.

      ls_return-number     = ls_message-msgnr.

      ls_return-message    = text-e01.

      ls_return-message_v1 = ls_message-msgv1.

      ls_return-message_v2 = ls_message-msgv2.

      ls_return-message_v3 = ls_message-msgv3.

      ls_return-message_v4 = ls_message-msgv4.

      ls_return-system     = ls_message-fldname.

      APPEND ls_return TO return.

    ENDLOOP.



*** Caso operação cancelada

    LOOP AT lt_message INTO ls_message WHERE msgtyp = 'A'.

* Registra LOG Erro

      REFRESH tl_logdoc.

      wl_logdoc-logty = 'E'.

      wl_logdoc-logno = '701'.

      APPEND wl_logdoc TO tl_logdoc.



      ls_return-type       = ls_message-msgtyp.

      ls_return-id         = ls_message-msgid.

      ls_return-number     = ls_message-msgnr.

      ls_return-message    = text-e01.

      ls_return-message_v1 = ls_message-msgv1.

      ls_return-message_v2 = ls_message-msgv2.

      ls_return-message_v3 = ls_message-msgv3.

      ls_return-message_v4 = ls_message-msgv4.

      ls_return-system     = ls_message-fldname.

      APPEND ls_return TO return.

    ENDLOOP.



  ELSE.



* Registra LOG Sucesso

    REFRESH tl_logdoc.

    wl_logdoc-logty = 'S'.

    wl_logdoc-logno = '700'.

    wl_logdoc-logv1 = ls_message-msgv1.

    APPEND wl_logdoc TO tl_logdoc.



    ls_return-type       = ls_message-msgtyp.

    ls_return-id         = ls_message-msgid.

    ls_return-number     = ls_message-msgnr.

    ls_return-message    = text-s01.

    ls_return-message_v1 = ls_message-msgv1.

    ls_return-message_v2 = ls_message-msgv2.

    ls_return-message_v3 = ls_message-msgv3.

    ls_return-message_v4 = ls_message-msgv4.

    ls_return-system     = ls_message-fldname.

    APPEND ls_return TO return.



** insere Nº Documento gerado

    CLEAR: ls_docmn.

    SELECT SINGLE MAX( seqnr )

      INTO vg_seqnr

      FROM zhms_tb_docmn

     WHERE chave EQ v_chave.



    ADD 1 TO vg_seqnr.



    MOVE: wa_cabdoc-chave  TO ls_docmn-chave,

          'MATDOC'         TO ls_docmn-mneum,

          ls_message-msgv1 TO ls_docmn-value,

          vg_seqnr         TO ls_docmn-seqnr.



    MODIFY zhms_tb_docmn FROM ls_docmn.

    CLEAR ls_docmn.



    IF sy-subrc IS INITIAL.

      COMMIT WORK.

    ENDIF.



    ADD 1 TO vg_seqnr.

    MOVE: wa_cabdoc-chave  TO ls_docmn-chave,

          'MATDOCYEA'      TO ls_docmn-mneum,

          sy-datum(4)      TO ls_docmn-value,

          vg_seqnr         TO ls_docmn-seqnr.



    MODIFY zhms_tb_docmn FROM ls_docmn.

    CLEAR ls_docmn.



    IF sy-subrc IS INITIAL.

      COMMIT WORK.

    ENDIF.



  ENDIF.



  REFRESH it_docmn.

   SELECT *

     FROM zhms_tb_docmn

     INTO TABLE it_docmn

    WHERE chave EQ v_chave.

ENDFUNCTION.
