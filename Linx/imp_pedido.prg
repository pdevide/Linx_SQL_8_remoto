**
** tira um pack do pedido original e cria um outro com o pack retirado
** E-COMMERCE 2021

CREATE CURSOR pedidos (PEDIDO C(12), QTDE INT)
APPEND FROM C:\TEMP\arq_pedidos.txt DELIMITED WITH CHARACTER ";"

SELECT *, SPACE(12) AS PEDIDO2, CAST(0 AS INT) AS QTDE2, ;
CAST(0 AS INT) AS QTDE_ORIGINAL, CAST(0 AS INT) AS QTDE_ENTREGAR, ;
CAST(0 AS INT) AS DIFERENCA ;
FROM PEDIDOS WHERE PEDIDO NOT LIKE "%V" ;
INTO CURSOR PEDIDOS2 READWRITE

SELECT PEDIDOS2
SCAN  
	TEXT TO CSQL NOSHOW TEXTMERGE
		SELECT PEDIDO, TOT_QTDE_ORIGINAL, TOT_QTDE_ENTREGAR 
		FROM COMPRAS WHERE PEDIDO = ?pedidos2.PEDIDO
	ENDTEXT
	F_SELECT(CSQL,"V_PEDIDOS")
	
	SELECT pedidos
	LOCATE FOR ALLTRIM(PEDIDO) == ALLTRIM(PEDIDOS2.PEDIDO)+"V"
	IF FOUND()
		SELECT PEDIDOS2
		REPLACE PEDIDO2 WITH PEDIDOS.PEDIDO
		REPLACE QTDE2 WITH PEDIDOS.QTDE
	ENDIF
	SELECT PEDIDOS2
	REPLACE QTDE_ORIGINAL WITH V_PEDIDOS.TOT_QTDE_ORIGINAL
	REPLACE QTDE_ENTREGAR WITH V_PEDIDOS.TOT_QTDE_ENTREGAR 
	REPLACE DIFERENCA WITH IIF(V_PEDIDOS.TOT_QTDE_ORIGINAL>0,V_PEDIDOS.TOT_QTDE_ORIGINAL - PEDIDOS2.QTDE,0)
ENDSCAN


SELECT PEDIDOS2
SCAN 
	cPedido = ALLTRIM(pedidos2.pedido)
	cPedidoV = ALLTRIM(pedidos2.pedido)+"V"

	TEXT TO CSQL NOSHOW TEXTMERGE
		SELECT * FROM CAEDU_COMPRAS_PRODUTOS_PACKS WHERE PEDIDO = '<<cPedido>>'  
	ENDTEXT
	f_select(CSQL,"v_pack")

	SELECT v_pack

	
	SCAN
		TEXT TO csql NOSHOW TEXTMERGE
			UPDATE compras_produto SET 
			qtde_original = (qtde_original - ?v_pack.qtde), 
			qtde_entregar = (qtde_entregar - ?v_pack.qtde),
			VALOR_ORIGINAL = (qtde_original - ?v_pack.qtde)*CUSTO1, 
			VALOR_ENTREGAR=(qtde_entregar - ?v_pack.qtde)*CUSTO1, 
			ERP_VERBAS_EMPENHO=(qtde_original - ?v_pack.qtde)*CUSTO1,
			CO1=CO1 - ?v_pack.Q1, CO2=CO2 - ?v_pack.Q2, CO3=CO3 - ?v_pack.Q3, 
			CO4=CO4 - ?v_pack.Q4, CO5=CO5 - ?v_pack.Q5, CO6=CO6 - ?v_pack.Q6, 
			CO7=CO7 - ?v_pack.Q7, CO8=CO8 - ?v_pack.Q8, CO9=CO9 - ?v_pack.Q9, 
			CO10=CO10 - ?v_pack.Q10, CO11=CO11 - ?v_pack.Q11, CO12=CO12 - ?v_pack.Q12, 
			CO13=CO13 - ?v_pack.Q13, CO14=CO14 - ?v_pack.Q14, CO15=CO15 - ?v_pack.Q15, 
			CO16=CO16 - ?v_pack.Q16,
			CE1=CE1 - ?v_pack.Q1, CE2=CE2 - ?v_pack.Q2, CE3=CE3 - ?v_pack.Q3, CE4=CE4 - ?v_pack.Q4, 
			CE5=CE5 - ?v_pack.Q5, CE6=CE6 - ?v_pack.Q6, CE7=CE7 - ?v_pack.Q7, CE8=CE8 - ?v_pack.Q8, 
			CE9=CE9 - ?v_pack.Q9, CE10=CE10 - ?v_pack.Q10, CE11=CE11 - ?v_pack.Q11, CE12=CE12 - ?v_pack.Q12, 
			CE13=CE13 - ?v_pack.Q13, CE14=CE14 - ?v_pack.Q14, CE15=CE15 - ?v_pack.Q15, CE16=CE16 - ?v_pack.Q16
			where pedido = ?cPedido and produto = ?v_pack.produto
		ENDTEXT
		F_EXECUTE(csql)
	ENDSCAN

	TEXT TO csql NOSHOW TEXTMERGE
		UPDATE C SET TOT_QTDE_ORIGINAL = CP.QTDE_ORIGINAL, TOT_QTDE_ENTREGAR = CP.QTDE_ENTREGAR, 
		TOT_VALOR_ORIGINAL = CP.VALOR_ORIGINAL, TOT_VALOR_ENTREGAR = CP.VALOR_ENTREGAR, PEDIDO_FORNECEDOR = 'E-COMMERCE 2021'
		FROM COMPRAS C 
		INNER JOIN (
		SELECT PEDIDO, SUM(QTDE_ORIGINAL) AS QTDE_ORIGINAL, SUM(QTDE_ENTREGAR) AS QTDE_ENTREGAR, 
		SUM(VALOR_ORIGINAL) AS VALOR_ORIGINAL, SUM(VALOR_ORIGINAL) AS VALOR_ENTREGAR 
		FROM COMPRAS_PRODUTO WHERE PEDIDO = ?cPedido
		GROUP BY PEDIDO
		) AS CP ON CP.PEDIDO = C.PEDIDO
		WHERE C.PEDIDO = ?cPedido
	ENDTEXT
	F_EXECUTE(csql)

	** Inclui pedido de E-commerce
	TEXT TO csql NOSHOW TEXTMERGE
		INSERT INTO compras 
		(pedido, fornecedor, PEDIDO_FORNECEDOR, filial_a_entregar, filial_cobranca, filial_a_faturar, 
		condicao_pgto, transportadora, moeda, cod_transacao, emissao, cadastramento,  
		aprovado_por, desconto, encargo, valor_ipi, frete_a_pagar, tot_qtde_original,  
		tot_qtde_entregar, tot_valor_original, tot_valor_entregar, ctrl_mult_entregas, 
		tabela_filha, entrega_aceitavel, obs, requerido_por, tipo_compra, programacao, 
		status_aprovacao, data_aprovacao, origem_da_compra, status_compra, pedido_venda,  
		comprimento_de_rolos, tot_valor_despesa, marca_volumes, aprovador_por, 
		rateio_centro_custo, rateio_filial, 
		data_faturamento_relativo, natureza_entrada, natureza, id_assinatura_documento, 
		data_para_transferencia, pedido_compra_origem, caedu_data_entrega_original, 
		lx_status_compra, quantidade_agendamento, quantidade_cancelamento, 
		caedu_data_otb, status_cq, motivo_cq, erp_conferencia_packs, erp_cab_cod_cabide, 
		erp_cab_cd_entrega, erp_cab_encabidado, erp_cab_status, erp_cab_localizacao, 
		erp_cab_qtdpecas, erp_cab_tipo_pedido, erp_cab_data_envio, erp_follow_up_margem, 
		objeto_id, erp_cups_tipo_pedido, erp_cups_segmento, erp_cups_data_acordada, 
		erp_cups_peca_mostruario, erp_cups_embarque_atual, erp_cups_embarque_real, 
		erp_cups_contrato, erp_cups_chegada_porto, erp_cups_chegada_cd, 
		erp_cups_processo_ccf_cca, erp_cups_embarque_liberado, erp_cups_seq_produto, 
		erp_cups_incoterm, erp_cups_id_contrato, erp_imp_num_fatura, 
		erp_imp_cod_processo, erp_imp_tipo_importacao, erp_percent_verbas, 
		bloq_embarque, erp_ebs_ctrl_pagto_parcela, erp_ebs_vlr_siscomex, 
		erp_ebs_vlr_custo_fob_di, erp_ebs_vlr_taxa_di, erp_ebs_vlr_taxa_bl, 
		erp_importado, erp_moeda, erp_total_qtd_distrib, erp_percent_distrib,  
		erp_total_caixas_original, erp_pack_resto, ctb_tipo_operacao, 
		desc_tipo_operacao, gerar_wf, chave_processo_se, erp_distribuicao, erp_manual, 	erp_liberado_cq, erp_faturado, erp_cab_opcao, erp_cab_cod_bolacha) 

		select '<<cPedidoV>>' as pedido, fornecedor, 'E-COMMERCE 2021' as PEDIDO_FORNECEDOR, filial_a_entregar, filial_cobranca, filial_a_faturar, 
		condicao_pgto, transportadora, moeda, cod_transacao, emissao, cadastramento,  
		aprovado_por, desconto, encargo, valor_ipi, frete_a_pagar, tot_qtde_original,  
		tot_qtde_entregar, tot_valor_original, tot_valor_entregar, ctrl_mult_entregas, 
		tabela_filha, entrega_aceitavel, obs, requerido_por, tipo_compra, programacao, 
		status_aprovacao, data_aprovacao, origem_da_compra, status_compra, pedido_venda,  
		comprimento_de_rolos, tot_valor_despesa, marca_volumes, aprovador_por, 
		rateio_centro_custo, rateio_filial, 
		data_faturamento_relativo, natureza_entrada, natureza, id_assinatura_documento, 
		data_para_transferencia, pedido_compra_origem, caedu_data_entrega_original, 
		lx_status_compra, quantidade_agendamento, quantidade_cancelamento, 
		caedu_data_otb, status_cq, motivo_cq, erp_conferencia_packs, erp_cab_cod_cabide, 
		erp_cab_cd_entrega, erp_cab_encabidado, erp_cab_status, erp_cab_localizacao, 
		erp_cab_qtdpecas, erp_cab_tipo_pedido, erp_cab_data_envio, erp_follow_up_margem, 
		objeto_id, erp_cups_tipo_pedido, erp_cups_segmento, erp_cups_data_acordada, 
		erp_cups_peca_mostruario, erp_cups_embarque_atual, erp_cups_embarque_real, 
		erp_cups_contrato, erp_cups_chegada_porto, erp_cups_chegada_cd, 
		erp_cups_processo_ccf_cca, erp_cups_embarque_liberado, erp_cups_seq_produto, 
		erp_cups_incoterm, erp_cups_id_contrato, erp_imp_num_fatura, 
		erp_imp_cod_processo, erp_imp_tipo_importacao, erp_percent_verbas, 
		bloq_embarque, erp_ebs_ctrl_pagto_parcela, erp_ebs_vlr_siscomex, 
		erp_ebs_vlr_custo_fob_di, erp_ebs_vlr_taxa_di, erp_ebs_vlr_taxa_bl, 
		erp_importado, erp_moeda, erp_total_qtd_distrib, erp_percent_distrib,  
		erp_total_caixas_original, erp_pack_resto, ctb_tipo_operacao, 
		desc_tipo_operacao, gerar_wf, chave_processo_se, erp_distribuicao, erp_manual, 
		erp_liberado_cq, erp_faturado, erp_cab_opcao, erp_cab_cod_bolacha
		from compras
		where pedido = ?cPedido
	ENDTEXT
	F_EXECUTE(csql)
	
	** insere tabela caedu_compras_produtos_packs
	SELECT v_pack
	SCAN 	
		TEXT TO csql NOSHOW TEXTMERGE
			INSERT INTO caedu_compras_produtos_packs (pedido, produto, cor_produto, 
			desc_cor_produto, qtde, q1, q2, q3, q4, q5, q6, q7, q8, q9, q10, q11, q12, q13, 
			q14, q15, q16, q17, q18, q19, q20, q21, q22, q23, q24, q25, q26, q27, q28, q29, 
			q30, q31, q32, q33, q34, q35, q36, q37, q38, q39, q40, q41, q42, q43, q44, q45, 
			q46, q47, q48) 
			select '<<cPedidoV>>' as pedido, produto, cor_produto, 
			desc_cor_produto, qtde, q1, q2, q3, q4, q5, q6, q7, q8, q9, q10, q11, q12, q13, 
			q14, q15, q16, q17, q18, q19, q20, q21, q22, q23, q24, q25, q26, q27, q28, q29, 
			q30, q31, q32, q33, q34, q35, q36, q37, q38, q39, q40, q41, q42, q43, q44, q45, 
			q46, q47, q48
			from caedu_compras_produtos_packs 
			where pedido = ?cPedido and produto = ?v_pack.produto
		ENDTEXT
		F_EXECUTE(csql)
		
		TEXT TO csql NOSHOW TEXTMERGE
			INSERT INTO compras_produto 
			(produto, pedido, entrega, cor_produto, limite_entrega, requisicao, custo1, 
			custo2, custo3, custo4, custo_moeda1, custo_moeda2, custo_moeda3, custo_moeda4, 
			qtde_original, qtde_cancelada, qtde_entregue, qtde_entregar, valor_original, 
			valor_entregue, valor_entregar, desconto_item, ipi, packs, co1, co2, co3, co4,  
			co5, co6, co7, co8, co9, co10, co11, co12, co13, co14, co15, co16, co17, co18, 
			co19, co20, co21, co22, co23, co24, co25, co26, co27, co28, co29, co30, co31, 
			co32, co33, co34, co35, co36, co37, co38, co39, co40, co41, co42, co43, co44, 
			co45, co46, co47, co48, ce1, ce2, ce3, ce4, ce5, ce6, ce7, ce8, ce9, ce10, ce11, 
			ce12, ce13, ce14, ce15, ce16, ce17, ce18, ce19, ce20, ce21, ce22, ce23, ce24, 
			ce25, ce26, ce27, ce28, ce29, ce30, ce31, ce32, ce33, ce34, ce35, ce36, ce37, 
			ce38, ce39, ce40, ce41, ce42, ce43, ce44, ce45, ce46, ce47, ce48, 
			entregue_moeda_padrao, chegada_prevista, obs_item,  
			data_confirmacao, data_para_transferencia, qtde_compra_rateio, 
			valor_compra_rateio, cod_alocacao, multiplicador_alocacao, 
			quantidade_agendamento, quantidade_cancelamento, erp_cups_packs_por_caixa, 
			erp_cups_custo_fob, erp_perc_margem, erp_cups_sequencia, 
			erp_cups_custo_fob_minimo, qtde, erp_verbas_empenho, erp_verbas_data_empenho, 
			erp_verbas_empenho_ano_mes, erp_verbas_status_pr, data_acerto_consignacao, 
			erp_conjunto, erp_cor_produto2) 

			select produto, '<<cPedidoV>>' as pedido, entrega, cor_produto, limite_entrega, requisicao, custo1, 
			custo2, custo3, custo4, custo_moeda1, custo_moeda2, custo_moeda3, custo_moeda4, 
			?v_pack.qtde as qtde_original, qtde_cancelada, qtde_entregue, ?v_pack.qtde as qtde_entregar, (?v_pack.qtde * custo1) as valor_original, 
			valor_entregue, (?v_pack.qtde * custo1) as valor_entregar, desconto_item, ipi, packs, ?v_pack.Q1 as CO1, ?v_pack.Q2 as CO2, ?v_pack.Q3 as CO3, 
			?v_pack.Q4 as CO4, ?v_pack.Q5 as CO5, ?v_pack.Q6 as CO6, ?v_pack.Q7 as CO7, ?v_pack.Q8 as CO8, ?v_pack.Q9 as CO9, ?v_pack.Q10 as CO10, 
			?v_pack.Q11 as CO11, ?v_pack.Q12 as CO12, ?v_pack.Q13 as CO13, ?v_pack.Q14 as CO14, ?v_pack.Q15 as CO15, ?v_pack.Q16 as CO16, 
			?v_pack.Q17 as CO17, ?v_pack.Q18 as CO18, ?v_pack.Q19 as CO19, ?v_pack.Q20 as CO20, ?v_pack.Q21 as CO21, ?v_pack.Q22 as CO22, 
			?v_pack.Q23 as CO23, ?v_pack.Q24 as CO24, ?v_pack.Q25 as CO25, ?v_pack.Q26 as CO26, ?v_pack.Q27 as CO27, ?v_pack.Q28 as CO28, 
			?v_pack.Q29 as CO29, ?v_pack.Q30 as CO30, ?v_pack.Q31 as CO31, ?v_pack.Q32 as CO32, ?v_pack.Q33 as CO33, ?v_pack.Q34 as CO34, 
			?v_pack.Q35 as CO35, ?v_pack.Q36 as CO36, ?v_pack.Q37 as CO37, ?v_pack.Q38 as CO38, ?v_pack.Q39 as CO39, ?v_pack.Q40 as CO40, 
			?v_pack.Q41 as CO41, ?v_pack.Q42 as CO42, ?v_pack.Q43 as CO43, ?v_pack.Q44 as CO44, ?v_pack.Q45 as CO45, ?v_pack.Q46 as CO46, 
			?v_pack.Q47 as CO47, ?v_pack.Q48 as CO48, ?v_pack.Q1 as CE1, ?v_pack.Q2 as CE2, ?v_pack.Q3 as CE3, ?v_pack.Q4 as CE4, 
			?v_pack.Q5 as CE5, ?v_pack.Q6 as CE6, ?v_pack.Q7 as CE7, ?v_pack.Q8 as CE8, ?v_pack.Q9 as CE9, ?v_pack.Q10 as CE10, 
			?v_pack.Q11 as CE11, ?v_pack.Q12 as CE12, ?v_pack.Q13 as CE13, ?v_pack.Q14 as CE14, ?v_pack.Q15 as CE15, ?v_pack.Q16 as CE16, 
			?v_pack.Q17 as CE17, ?v_pack.Q18 as CE18, ?v_pack.Q19 as CE19, ?v_pack.Q20 as CE20, ?v_pack.Q21 as CE21, ?v_pack.Q22 as CE22, 
			?v_pack.Q23 as CE23, ?v_pack.Q24 as CE24, ?v_pack.Q25 as CE25, ?v_pack.Q26 as CE26, ?v_pack.Q27 as CE27, ?v_pack.Q28 as CE28, 
			?v_pack.Q29 as CE29, ?v_pack.Q30 as CE30, ?v_pack.Q31 as CE31, ?v_pack.Q32 as CE32, ?v_pack.Q33 as CE33, ?v_pack.Q34 as CE34, 
			?v_pack.Q35 as CE35, ?v_pack.Q36 as CE36, ?v_pack.Q37 as CE37, ?v_pack.Q38 as CE38, ?v_pack.Q39 as CE39, ?v_pack.Q40 as CE40, 
			?v_pack.Q41 as CE41, ?v_pack.Q42 as CE42, ?v_pack.Q43 as CE43, ?v_pack.Q44 as CE44, ?v_pack.Q45 as CE45, ?v_pack.Q46 as CE46, 
			?v_pack.Q47 as CE47, ?v_pack.Q48 as CE48,
			entregue_moeda_padrao, chegada_prevista, obs_item,  
			data_confirmacao, data_para_transferencia, qtde_compra_rateio, 
			valor_compra_rateio, cod_alocacao, multiplicador_alocacao, 
			quantidade_agendamento, quantidade_cancelamento, erp_cups_packs_por_caixa, 
			erp_cups_custo_fob, erp_perc_margem, erp_cups_sequencia, 
			erp_cups_custo_fob_minimo, qtde, erp_verbas_empenho, erp_verbas_data_empenho, 
			erp_verbas_empenho_ano_mes, erp_verbas_status_pr, data_acerto_consignacao, 
			erp_conjunto, erp_cor_produto2
			from compras_produto 
			where pedido = ?cPedido and produto = ?v_pack.produto

		ENDTEXT
		f_execute(csql)
				
		SELECT v_pack
	ENDSCAN

	TEXT TO csql NOSHOW TEXTMERGE
		UPDATE C SET TOT_QTDE_ORIGINAL = CP.QTDE_ORIGINAL, TOT_QTDE_ENTREGAR = CP.QTDE_ENTREGAR, 
		TOT_VALOR_ORIGINAL = CP.VALOR_ORIGINAL, TOT_VALOR_ENTREGAR = CP.VALOR_ENTREGAR
		FROM COMPRAS C 
		INNER JOIN (
		SELECT PEDIDO, SUM(QTDE_ORIGINAL) AS QTDE_ORIGINAL, SUM(QTDE_ENTREGAR) AS QTDE_ENTREGAR, 
		SUM(VALOR_ORIGINAL) AS VALOR_ORIGINAL, SUM(VALOR_ORIGINAL) AS VALOR_ENTREGAR 
		FROM COMPRAS_PRODUTO WHERE PEDIDO = ?cPedidoV
		GROUP BY PEDIDO
		) AS CP ON CP.PEDIDO = C.PEDIDO
		WHERE C.PEDIDO = ?cPedidoV
	ENDTEXT
	F_EXECUTE(csql)
	
	** insere tabela caedu_compras_produtos_packs_total
	TEXT TO csql NOSHOW TEXTMERGE
		INSERT INTO caedu_compras_produtos_packs_total (pedido, produto, 
		qtde, q1, q2, q3, q4, q5, q6, q7, q8, q9, q10, q11, q12, q13, 
		q14, q15, q16, q17, q18, q19, q20, q21, q22, q23, q24, q25, q26, q27, q28, q29, 
		q30, q31, q32, q33, q34, q35, q36, q37, q38, q39, q40, q41, q42, q43, q44, q45, 
		q46, q47, q48) 
		select '<<cPedidoV>>' as pedido, produto, 
		qtde, q1, q2, q3, q4, q5, q6, q7, q8, q9, q10, q11, q12, q13, 
		q14, q15, q16, q17, q18, q19, q20, q21, q22, q23, q24, q25, q26, q27, q28, q29, 
		q30, q31, q32, q33, q34, q35, q36, q37, q38, q39, q40, q41, q42, q43, q44, q45, 
		q46, q47, q48 from caedu_compras_produtos_packs_total 
		where pedido = ?cPedido 
	ENDTEXT
	F_EXECUTE(csql)
	
	TEXT TO csql NOSHOW TEXTMERGE
		INSERT INTO PROP_COMPRAS (PROPRIEDADE,PEDIDO,ITEM_PROPRIEDADE,VALOR_PROPRIEDADE,DATA_PARA_TRANSFERENCIA) 
		select PROPRIEDADE, '<<cPedidoV>>' as PEDIDO,ITEM_PROPRIEDADE,VALOR_PROPRIEDADE,getdate() as DATA_PARA_TRANSFERENCIA
		from PROP_COMPRAS
		where PEDIDO = ?cPedido
	ENDTEXT
	F_EXECUTE(csql)


	SELECT PEDIDOS2 
ENDSCAN





