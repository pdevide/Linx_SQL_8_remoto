***/
* OBJETO DE ENTRADA DA TELA DE CLIENTES
* 28-04-2021
*
define class obj_entrada as custom
	procedure metodo_usuario
	lparam xmetodo, xobjeto ,xnome_obj
	DO CASE
		CASE UPPER(xmetodo) == 'USR_INIT'	
			


			WAIT WINDOW 'OBJ' timeout 2

			***
			* Modifica o cursor adapter de clientes - inclui coluna nova sem precisar alterar dentro do formulário
			*
			************************************************************************************************************
			strInitAlias = SELECT() &&ALIAS()	
			***
			*** Carrega cursor v_clientes_01 (CURSORV_CLIENTES_01)
			***
			carrega_ca_v_clientes_01 (thisformset)
			SELECT (strInitAlias)
			************************************************************************************************************

			STORE 0 TO lnTop, lnLeft	
			WITH thisformset.lx_FORM1.lx_pageframe1.page1.Lx_cabecalho_contato1.Lx_label3
				lnTop = .top - 2
				lnLeft = .parent.Cmb_STATUS_CONTATO.Left - 30
			ENDWITH
			WITH thisformset.lx_FORM1.lx_pageframe1.page1.Lx_cabecalho_contato1
				.AddObject("LABEL_ID_ORACLE","LABEL")
				.LABEL_ID_ORACLE.top = lnTop + 2
				.LABEL_ID_ORACLE.left = lnLeft - 50
				.LABEL_ID_ORACLE.Caption = "ID ORACLE"
				.LABEL_ID_ORACLE.BackStyle = 0
				.LABEL_ID_ORACLE.visible = .t.
				
				.AddObject("txt_Id_Oracle1","txt_Id_Oracle")
				.txt_Id_Oracle1.visible=.t.
*!*					.bt_lecodigo1.top = lnTop
*!*					.bt_lecodigo1.left = lnLeft
			ENDWITH
			thisformset.l_limpa()
			
		CASE UPPER(xmetodo) == 'USR_SAVE_BEFORE'

		CASE UPPER(xmetodo) == 'USR_REFRESH'
			IF NOT thisformset.pp_palma_edicao_cliente
				o_toolbar.Botao_inclui.Enabled=.f.
				o_toolbar.Botao_altera.Enabled = .f.
				o_toolbar.botao_exclui.Enabled = .f.
			ENDIF
					
		OTHERWISE
			RETURN .t.
	ENDCASE
	ENDPROC
ENDDEFINE

DEFINE CLASS txt_Id_Oracle as textbox

	Top=10
	left=266
	width=132
	height=22
	controlsource="v_clientes_01.EBS_ID_CLIENTE"
	readonly = .f.
	visible=.t.
	
*!*		PROCEDURE WHEN

*!*			RETURN .F.		
*!*			
*!*		ENDPROC

	PROCEDURE refresh
		** Inclusão/Alteração/Exclusão/Tela (L)impa/(P)esquisa Feita!
		this.enabled = INLIST(ThisFormSet.p_Tool_Status,"I","A","L")
	ENDPROC

ENDDEFINE

FUNCTION carrega_ca_v_clientes_01 
PARAMETERS oThisformset

	With oThisformset.dataenvironment
		if Type(".CURSORV_CLIENTES_01")="O"
			*AddNewObject(oThisformset.dataenvironment, "CURSORV_CLIENTES_01","ccursoradapter")
			
			SELECT V_CLIENTES_01
			oCursor = GETCURSORADAPTER("V_CLIENTES_01")
			** Instruções:
			**oCursor.AddBufferField("tabela.nome_da_coluna", "Tipo",  <atualizavel>, "caption", "tabela.nome_coluna")
			**
			oCursor.AddBufferField("cadastro_cli_for.ebs_id_cliente", "C(60)",.T.,"ebs_id_cliente","cadastro_cli_for.ebs_id_cliente")
			oCursor.confirmStructureChanges()
			
			.CURSORV_CLIENTES_01.DataSourceType ="ADO"
			
			***
			*** SelectCmd 
			***
*!*				TEXT TO  .CURSORV_CLIENTES_01.SelectCmd NOSHOW TEXTMERGE PRETEXT 7
*!*					SELECT cadastro_cli_for.indica_cprb, 
*!*					       cadastro_cli_for.cadastro_cno, 
*!*					       cadastro_cli_for.nome_clifor, 
*!*					       cadastro_cli_for.clifor, 
*!*					       cadastro_cli_for.razao_social, 
*!*					       cadastro_cli_for.cgc_cpf, 
*!*					       clientes_atacado.conta_contabil, 
*!*					       contas_plano.desc_conta, 
*!*					       cadastro_cli_for.pj_pf, 
*!*					       cadastro_cli_for.rg_ie, 
*!*					       cadastro_cli_for.cep, 
*!*					       cadastro_cli_for.endereco, 
*!*					       cadastro_cli_for.cidade, 
*!*					       cadastro_cli_for.bairro, 
*!*					       cadastro_cli_for.uf, 
*!*					       cadastro_cli_for.telefone1, 
*!*					       cadastro_cli_for.pais, 
*!*					       cadastro_cli_for.ddi, 
*!*					       cadastro_cli_for.telefone2, 
*!*					       cadastro_cli_for.fax, 
*!*					       cadastro_cli_for.ddd1, 
*!*					       cadastro_cli_for.ramal1, 
*!*					       cadastro_cli_for.ramal2, 
*!*					       cadastro_cli_for.ddd2, 
*!*					       cadastro_cli_for.cobranca_endereco, 
*!*					       cadastro_cli_for.cobranca_cidade, 
*!*					       cadastro_cli_for.cobranca_bairro, 
*!*					       cadastro_cli_for.dddfax, 
*!*					       cadastro_cli_for.cobranca_uf, 
*!*					       cadastro_cli_for.codigo_contato, 
*!*					       cadastro_cli_for.cobranca_cep, 
*!*					       cadastro_cli_for.cobranca_telefone, 
*!*					       cadastro_cli_for.entrega_endereco, 
*!*					       cadastro_cli_for.entrega_bairro, 
*!*					       cadastro_cli_for.entrega_cidade, 
*!*					       cadastro_cli_for.aceita_dias_fixo, 
*!*					       cadastro_cli_for.entrega_uf, 
*!*					       cadastro_cli_for.entrega_cep, 
*!*					       cadastro_cli_for.entrega_telefone, 
*!*					       cadastro_cli_for.cobranca_ddd, 
*!*					       cadastro_cli_for.contato, 
*!*					       cadastro_cli_for.cobranca_cgc, 
*!*					       cadastro_cli_for.cadastramento, 
*!*					       cadastro_cli_for.cobranca_ie, 
*!*					       cadastro_cli_for.aniversario, 
*!*					       cadastro_cli_for.indica_fornecedor, 
*!*					       cadastro_cli_for.indica_cliente, 
*!*					       cadastro_cli_for.ind_representante, 
*!*					       cadastro_cli_for.indica_filial, 
*!*					       cadastro_cli_for.entrega_ddd, 
*!*					       cadastro_cli_for.entrega_cgc, 
*!*					       clientes_atacado.clifor                  AS CLIFOR1, 
*!*					       clientes_atacado.cgc_cpf                 AS CGC_CPF1, 
*!*					       clientes_atacado.bloqueio_faturamento, 
*!*					       clientes_atacado.bloqueio_expedicao, 
*!*					       clientes_atacado.bloqueio_pedidos, 
*!*					       clientes_atacado.limite_credito, 
*!*					       clientes_atacado.sem_credito, 
*!*					       clientes_atacado.prioridade, 
*!*					       clientes_atacado.tipo, 
*!*					       clientes_atacado.frete_a_pagar, 
*!*					       clientes_atacado.conceito, 
*!*					       clientes_atacado.filial, 
*!*					       clientes_atacado.transportadora, 
*!*					       clientes_atacado.pontualidade, 
*!*					       clientes_atacado.matriz_cliente, 
*!*					       clientes_atacado.cliente_atacado, 
*!*					       cadastro_cli_for.entrega_ie, 
*!*					       clientes_atacado.regiao, 
*!*					       clientes_atacado.condicao_pgto, 
*!*					       cadastro_cli_for.banco, 
*!*					       cadastro_cli_for.cc_agencia, 
*!*					       cadastro_cli_for.cc_conta, 
*!*					       cadastro_cli_for.cc_nome_agencia, 
*!*					       cadastro_cli_for.ref_anterior, 
*!*					       clientes_atacado.numero_pedidos, 
*!*					       clientes_atacado.data_maior_pedido, 
*!*					       clientes_atacado.maior_pedido, 
*!*					       clientes_atacado.maior_saldo, 
*!*					       clientes_atacado.data_maior_saldo, 
*!*					       clientes_atacado.numero_atrasos, 
*!*					       clientes_atacado.maior_atraso, 
*!*					       clientes_atacado.pgtos_cartorio, 
*!*					       clientes_atacado.numero_devolucoes, 
*!*					       clientes_atacado.maior_devolucao, 
*!*					       clientes_atacado.numero_prorrogacoes, 
*!*					       clientes_atacado.maior_prorrogacao, 
*!*					       clientes_atacado.maior_qtde_dev, 
*!*					       clientes_atacado.data_maior_qtde_dev, 
*!*					       clientes_atacado.data_maior_devolucao, 
*!*					       clientes_atacado.maior_qtde_pedido, 
*!*					       clientes_atacado.data_maior_qtde_pedido, 
*!*					       clientes_atacado.desconto_faturamento, 
*!*					       cadastro_cli_for.carteira, 
*!*					       cadastro_cli_for.obs_de_faturamento, 
*!*					       clientes_atacado.obs, 
*!*					       cadastro_cli_for.email, 
*!*					       clientes_atacado.moeda, 
*!*					       clientes_atacado.inativo, 
*!*					       cadastro_cli_for.atualizacao_exportar, 
*!*					       cadastro_cli_for.data_exportacao, 
*!*					       cadastro_cli_for.status_envio, 
*!*					       cadastro_cli_for.inativo                 AS INATIVO1, 
*!*					       cadastro_cli_for.data_para_transferencia, 
*!*					       cadastro_cli_for.entrega_pais, 
*!*					       cadastro_cli_for.cobranca_pais, 
*!*					       bancos.nome_banco, 
*!*					       cadastro_cli_for.entrega_ddi, 
*!*					       cadastro_cli_for.cobranca_ddi, 
*!*					       clientes_atacado.cod_cliente, 
*!*					       clientes_atacado.data_para_transferencia AS DATA_PARA_TRANSFERENCIA1, 
*!*					       clientes_atacado.indica_franquia, 
*!*					       clientes_atacado.codigo_tab_preco, 
*!*					       clientes_atacado.fator_custo_franquia, 
*!*					       clientes_atacado.desconto_pedido_venda, 
*!*					       clientes_atacado.seguro_numero_contrato, 
*!*					       clientes_atacado.seguro_numero_cliente, 
*!*					       clientes_atacado.seguro_validade, 
*!*					       cadastro_cli_for.isento_ipi, 
*!*					       cadastro_cli_for.isento_icms, 
*!*					       cadastro_cli_for.meses_sem_vencimento, 
*!*					       cadastro_cli_for.data_fixa_pgto, 
*!*					       cadastro_cli_for.aceita_agrupar_fatura, 
*!*					       cadastro_cli_for.numero_vias_fatura, 
*!*					       cadastro_cli_for.report_fatura, 
*!*					       cadastro_cli_for.dias_antecipacao_pgto, 
*!*					       cadastro_cli_for.passweb, 
*!*					       cadastro_cli_for.vencimento_passweb, 
*!*					       clientes_atacado.aceita_juntar_ped, 
*!*					       cadastro_cli_for.possui_recargo, 
*!*					       clientes_atacado.expedicao_completo_pedido, 
*!*					       clientes_atacado.expedicao_completo_pack, 
*!*					       clientes_atacado.expedicao_completo_tamanhos, 
*!*					       clientes_atacado.expedicao_completo_cor, 
*!*					       clientes_atacado.expedicao_completo_coordenado, 
*!*					       clientes_atacado.expedicao_porcentagem_maior, 
*!*					       clientes_atacado.expedicao_porcentagem_minima, 
*!*					       clientes_atacado.expedicao_porcentagem_tipo, 
*!*					       clientes_atacado.expedicao_valor_maximo, 
*!*					       clientes_atacado.expedicao_completo_cartela, 
*!*					       clientes_atacado.expedicao_completo_faixas, 
*!*					       clientes_atacado.expedicao_porc_adequacao, 
*!*					       clientes_atacado.expedicao_qtde_adequacao, 
*!*					       clientes_atacado.expedicao_adequacao_cor, 
*!*					       clientes_atacado.expedicao_adequacao_tamanho, 
*!*					       cadastro_cli_for.agrupamento_itens, 
*!*					       clientes_atacado.indicador_venda, 
*!*					       cadastro_cli_for.id_excecao_grupo, 
*!*					       ctb_excecao_grupo.desc_excecao_grupo, 
*!*					       clientes_atacado.tipo_bloqueio, 
*!*					       cadastro_cli_for.indicador_fiscal_terceiro, 
*!*					       ctb_lx_indicador_fiscal_terceiro.descricao_fiscal_terceiro, 
*!*					       clientes_atacado.ctb_conta_contabil, 
*!*					       ctb_conta_plano.desc_conta               AS CTB_DESC_CONTA, 
*!*					       cadastro_cli_for.cod_clifor, 
*!*					       cadastro_cli_for.cobranca_razao_social, 
*!*					       cadastro_cli_for.entrega_razao_social, 
*!*					       contato.contato                          AS CONTATO1, 
*!*					       contato.cpf_cgc, 
*!*					       contato.pf_pj, 
*!*					       contato.status_contato, 
*!*					       contato.cadastramento                    AS CADASTRAMENTO_CONTATO, 
*!*					       contato.tipo_contato, 
*!*					       contato.subtipo_contato, 
*!*					       contato.categoria_contato, 
*!*					       contato.subcategoria_contato, 
*!*					       contato_tipo.desc_tipo_contato, 
*!*					       contato_subtipo.desc_subtipo_contato, 
*!*					       contato_categoria.desc_categoria_contato, 
*!*					       contato_subcategoria.desc_subcategoria_contato, 
*!*					       cadastro_cli_for.im, 
*!*					       cadastro_cli_for.im_entrega, 
*!*					       cadastro_cli_for.im_cobranca, 
*!*					       clientes_atacado.desconto_bruto_1, 
*!*					       clientes_atacado.desconto_bruto_2, 
*!*					       clientes_atacado.desconto_bruto_3, 
*!*					       clientes_atacado.desconto_bruto_4, 
*!*					       clientes_atacado.desconto_sobre_1, 
*!*					       clientes_atacado.desconto_sobre_2, 
*!*					       clientes_atacado.desconto_sobre_3, 
*!*					       clientes_atacado.desconto_sobre_4, 
*!*					       clientes_atacado.multi_desconto_acumular, 
*!*					       cadastro_cli_for.inscricao_suframa, 
*!*					       clientes_atacado.dt_primeira_venda, 
*!*					       clientes_atacado.dt_ultima_venda, 
*!*					       clientes_atacado.dt_penultima_venda, 
*!*					       clientes_atacado.dt_antepenultima_venda, 
*!*					       cadastro_cli_for.incl_auto_grp_econ, 
*!*					       cadastro_cli_for.numero, 
*!*					       cadastro_cli_for.complemento, 
*!*					       cadastro_cli_for.cobranca_numero, 
*!*					       cadastro_cli_for.cobranca_complemento, 
*!*					       cadastro_cli_for.entrega_numero, 
*!*					       cadastro_cli_for.entrega_complemento, 
*!*					       cadastro_cli_for.cod_municipio_ibge, 
*!*					       cadastro_cli_for.cod_municipio_ibge_cobranca, 
*!*					       cadastro_cli_for.cod_municipio_ibge_entrega, 
*!*					       cadastro_cli_for.email_nfe, 
*!*					       clientes_atacado.conteudo_xped_nfe, 
*!*					       cadastro_cli_for.tipo_tributacao, 
*!*					       cadastro_cli_for.ebs_id_cliente 
*!*					FROM   clientes_atacado 
*!*					       INNER JOIN cadastro_cli_for 
*!*						       ON clientes_atacado.cliente_atacado = 
*!*							  cadastro_cli_for.nome_clifor 
*!*					       LEFT JOIN contas_plano 
*!*						      ON clientes_atacado.conta_contabil = contas_plano.conta_contabil 
*!*					       LEFT JOIN ctb_conta_plano 
*!*						      ON clientes_atacado.ctb_conta_contabil = 
*!*							 ctb_conta_plano.conta_contabil 
*!*					       LEFT JOIN bancos 
*!*						      ON cadastro_cli_for.banco = bancos.banco 
*!*					       LEFT JOIN ctb_lx_indicador_fiscal_terceiro 
*!*						      ON cadastro_cli_for.indicador_fiscal_terceiro = 
*!*							 ctb_lx_indicador_fiscal_terceiro.indicador_fiscal_terceiro 
*!*					       LEFT JOIN ctb_excecao_grupo 
*!*						      ON cadastro_cli_for.id_excecao_grupo = 
*!*							 ctb_excecao_grupo.id_excecao_grupo 
*!*					       LEFT JOIN contato 
*!*						      ON contato.codigo_contato = cadastro_cli_for.codigo_contato 
*!*					       LEFT JOIN contato_tipo 
*!*						      ON contato.tipo_contato = contato_tipo.tipo_contato 
*!*					       LEFT JOIN contato_subtipo 
*!*						      ON contato.tipo_contato = contato_subtipo.tipo_contato 
*!*							 AND contato.subtipo_contato = contato_subtipo.subtipo_contato 
*!*					       LEFT JOIN contato_categoria 
*!*						      ON contato.categoria_contato = contato_categoria.categoria_contato 
*!*					       LEFT JOIN contato_subcategoria 
*!*						      ON contato.categoria_contato = 
*!*							 contato_subcategoria.categoria_contato 
*!*							 AND contato.subcategoria_contato = 
*!*							     contato_subcategoria.subcategoria_contato 
*!*				ENDTEXT

*!*				***
*!*				*** CursorSchema 
*!*				***
*!*				TEXT TO  .CURSORV_CLIENTES_01.CursorSchema NOSHOW TEXTMERGE PRETEXT 7
*!*					 INDICA_CPRB L, CADASTRO_CNO C(14),  NOME_CLIFOR C(25), CLIFOR C(6), RAZAO_SOCIAL C(90), CGC_CPF C(19), CONTA_CONTABIL C(20), 
*!*					 DESC_CONTA C(40), PJ_PF L, RG_IE C(19), CEP C(9), ENDERECO C(90), CIDADE C(35), BAIRRO C(25), UF C(2), TELEFONE1 C(10), PAIS C(35), 
*!*					 DDI C(5), TELEFONE2 C(10), FAX C(10), DDD1 C(5), RAMAL1 C(5), RAMAL2 C(5), DDD2 C(5), COBRANCA_ENDERECO C(90), 
*!*					 COBRANCA_CIDADE C(35), COBRANCA_BAIRRO C(25), DDDFAX C(5), COBRANCA_UF C(2), CODIGO_CONTATO C(8), COBRANCA_CEP C(9), 
*!*					 COBRANCA_TELEFONE C(10), ENTREGA_ENDERECO C(90), ENTREGA_BAIRRO C(25), ENTREGA_CIDADE C(35), ACEITA_DIAS_FIXO L, 
*!*					 ENTREGA_UF C(2), ENTREGA_CEP C(9), ENTREGA_TELEFONE C(10), COBRANCA_DDD C(5), CONTATO C(40), COBRANCA_CGC C(19), 
*!*					 CADASTRAMENTO D, COBRANCA_IE C(19), ANIVERSARIO D, INDICA_FORNECEDOR L, INDICA_CLIENTE L, IND_REPRESENTANTE L, 
*!*					 INDICA_FILIAL L, ENTREGA_DDD C(5), ENTREGA_CGC C(19), CLIFOR1 C(6), CGC_CPF1 C(19), BLOQUEIO_FATURAMENTO D, 
*!*					 BLOQUEIO_EXPEDICAO D, BLOQUEIO_PEDIDOS D, LIMITE_CREDITO N(16,2), SEM_CREDITO L, PRIORIDADE I, TIPO C(25), 
*!*					 FRETE_A_PAGAR I, CONCEITO C(25), FILIAL C(25), TRANSPORTADORA C(25), PONTUALIDADE C(25), MATRIZ_CLIENTE C(25), 
*!*					 CLIENTE_ATACADO C(25), ENTREGA_IE C(19), REGIAO C(25), CONDICAO_PGTO C(3), BANCO C(5), CC_AGENCIA C(20), CC_CONTA C(20), 
*!*					 CC_NOME_AGENCIA C(30), REF_ANTERIOR C(7), NUMERO_PEDIDOS I, DATA_MAIOR_PEDIDO D, MAIOR_PEDIDO N(16,2), 
*!*					 MAIOR_SALDO N(16,2), DATA_MAIOR_SALDO D, NUMERO_ATRASOS I, MAIOR_ATRASO I, PGTOS_CARTORIO I, NUMERO_DEVOLUCOES I, 
*!*					 MAIOR_DEVOLUCAO N(16,2), NUMERO_PRORROGACOES I, MAIOR_PRORROGACAO I, MAIOR_QTDE_DEV I, DATA_MAIOR_QTDE_DEV D, 
*!*					 DATA_MAIOR_DEVOLUCAO D, MAIOR_QTDE_PEDIDO I, DATA_MAIOR_QTDE_PEDIDO D, DESCONTO_FATURAMENTO N(10,5), 
*!*					 CARTEIRA C(25), OBS_DE_FATURAMENTO M, OBS M, EMAIL C(100), MOEDA C(6), INATIVO L, ATUALIZACAO_EXPORTAR D, 
*!*					 DATA_EXPORTACAO D, STATUS_ENVIO C(1), INATIVO1 L, DATA_PARA_TRANSFERENCIA D, ENTREGA_PAIS C(35), COBRANCA_PAIS C(35), 
*!*					 NOME_BANCO C(80), ENTREGA_DDI C(5), COBRANCA_DDI C(5), COD_CLIENTE C(6), DATA_PARA_TRANSFERENCIA1 D, INDICA_FRANQUIA I, 
*!*					 CODIGO_TAB_PRECO C(2), FATOR_CUSTO_FRANQUIA N(10,3), DESCONTO_PEDIDO_VENDA N(10,4), SEGURO_NUMERO_CONTRATO C(12), 
*!*					 SEGURO_NUMERO_CLIENTE C(8), SEGURO_VALIDADE D, ISENTO_IPI L, ISENTO_ICMS L, MESES_SEM_VENCIMENTO C(20), 
*!*					 DATA_FIXA_PGTO C(20), ACEITA_AGRUPAR_FATURA I, NUMERO_VIAS_FATURA I, REPORT_FATURA C(9), DIAS_ANTECIPACAO_PGTO I, 
*!*					 PASSWEB C(10), VENCIMENTO_PASSWEB D, ACEITA_JUNTAR_PED L, POSSUI_RECARGO I, EXPEDICAO_COMPLETO_PEDIDO L, 
*!*					 EXPEDICAO_COMPLETO_PACK L, EXPEDICAO_COMPLETO_TAMANHOS L, EXPEDICAO_COMPLETO_COR L, 
*!*					 EXPEDICAO_COMPLETO_COORDENADO L, EXPEDICAO_PORCENTAGEM_MAIOR I, EXPEDICAO_PORCENTAGEM_MINIMA I, 
*!*					 EXPEDICAO_PORCENTAGEM_TIPO I, EXPEDICAO_VALOR_MAXIMO N(16,2), EXPEDICAO_COMPLETO_CARTELA L, 
*!*					 EXPEDICAO_COMPLETO_FAIXAS L, EXPEDICAO_PORC_ADEQUACAO N(15,10), EXPEDICAO_QTDE_ADEQUACAO I, EXPEDICAO_ADEQUACAO_COR L,
*!*					 EXPEDICAO_ADEQUACAO_TAMANHO L, AGRUPAMENTO_ITENS I, INDICADOR_VENDA C(1), ID_EXCECAO_GRUPO I, DESC_EXCECAO_GRUPO C(40),
*!*					  TIPO_BLOQUEIO C(25), INDICADOR_FISCAL_TERCEIRO I, DESCRICAO_FISCAL_TERCEIRO C(40), CTB_CONTA_CONTABIL C(20), 
*!*					  CTB_DESC_CONTA C(40), COD_CLIFOR C(6), COBRANCA_RAZAO_SOCIAL C(90), ENTREGA_RAZAO_SOCIAL C(90), CONTATO1 C(90), 
*!*					  CPF_CGC C(19), PF_PJ I, STATUS_CONTATO C(2), CADASTRAMENTO_CONTATO D, TIPO_CONTATO C(4), SUBTIPO_CONTATO C(25), 
*!*					  CATEGORIA_CONTATO C(25), SUBCATEGORIA_CONTATO C(25), DESC_TIPO_CONTATO C(40), DESC_SUBTIPO_CONTATO C(40), 
*!*					  DESC_CATEGORIA_CONTATO C(40), DESC_SUBCATEGORIA_CONTATO C(40), IM C(14), IM_ENTREGA C(14), IM_COBRANCA C(14), 
*!*					  DESCONTO_BRUTO_1 N(10,2), DESCONTO_BRUTO_2 N(10,2), DESCONTO_BRUTO_3 N(10,2), DESCONTO_BRUTO_4 N(10,2), 
*!*					  DESCONTO_SOBRE_1 N(10,2), DESCONTO_SOBRE_2 N(10,2), DESCONTO_SOBRE_3 N(10,2), DESCONTO_SOBRE_4 N(10,2), 
*!*					  MULTI_DESCONTO_ACUMULAR L, INSCRICAO_SUFRAMA C(9),  DT_PRIMEIRA_VENDA D,  DT_ULTIMA_VENDA D,  DT_PENULTIMA_VENDA D,  
*!*					  DT_ANTEPENULTIMA_VENDA D, INCL_AUTO_GRP_ECON L, NUMERO C(10), COMPLEMENTO C(60), COBRANCA_NUMERO C(10), 
*!*					  COBRANCA_COMPLEMENTO C(60), ENTREGA_NUMERO C(10), ENTREGA_COMPLEMENTO C(60),COD_MUNICIPIO_IBGE C(10), 
*!*					  COD_MUNICIPIO_IBGE_COBRANCA C(10), COD_MUNICIPIO_IBGE_ENTREGA C(10), EMAIL_NFE C(100), CONTEUDO_XPED_NFE I, 
*!*					  TIPO_TRIBUTACAO C(25), EBS_ID_CLIENTE C(60)
*!*				ENDTEXT

*!*				***
*!*				*** UpdateNameList 
*!*				***

*!*				SET STEP ON 
*!*				VLC_UpdateNameList = ''
*!*				
*!*				TEXT TO VLC_UpdateNameList  NOSHOW TEXTMERGE PRETEXT 7
*!*					 INDICA_CPRB CADASTRO_CLI_FOR.INDICA_CPRB , CADASTRO_CNO CADASTRO_CLI_FOR.CADASTRO_CNO,  
*!*					 NOME_CLIFOR CADASTRO_CLI_FOR.NOME_CLIFOR, CLIFOR CADASTRO_CLI_FOR.CLIFOR, RAZAO_SOCIAL CADASTRO_CLI_FOR.RAZAO_SOCIAL, 
*!*					 CGC_CPF CADASTRO_CLI_FOR.CGC_CPF, CONTA_CONTABIL CLIENTES_ATACADO.CONTA_CONTABIL, PJ_PF CADASTRO_CLI_FOR.PJ_PF, 
*!*					 RG_IE CADASTRO_CLI_FOR.RG_IE, CEP CADASTRO_CLI_FOR.CEP, ENDERECO CADASTRO_CLI_FOR.ENDERECO, 
*!*					 CIDADE CADASTRO_CLI_FOR.CIDADE, BAIRRO CADASTRO_CLI_FOR.BAIRRO, UF CADASTRO_CLI_FOR.UF, 
*!*					 TELEFONE1 CADASTRO_CLI_FOR.TELEFONE1, PAIS CADASTRO_CLI_FOR.PAIS, DDI CADASTRO_CLI_FOR.DDI, 
*!*					 TELEFONE2 CADASTRO_CLI_FOR.TELEFONE2, FAX CADASTRO_CLI_FOR.FAX, DDD1 CADASTRO_CLI_FOR.DDD1, 
*!*					 RAMAL1 CADASTRO_CLI_FOR.RAMAL1, RAMAL2 CADASTRO_CLI_FOR.RAMAL2, DDD2 CADASTRO_CLI_FOR.DDD2, 
*!*					 COBRANCA_ENDERECO CADASTRO_CLI_FOR.COBRANCA_ENDERECO, COBRANCA_CIDADE CADASTRO_CLI_FOR.COBRANCA_CIDADE, 
*!*					 COBRANCA_BAIRRO CADASTRO_CLI_FOR.COBRANCA_BAIRRO, DDDFAX CADASTRO_CLI_FOR.DDDFAX, 
*!*					 COBRANCA_UF CADASTRO_CLI_FOR.COBRANCA_UF, CODIGO_CONTATO CADASTRO_CLI_FOR.CODIGO_CONTATO, 
*!*					 COBRANCA_CEP CADASTRO_CLI_FOR.COBRANCA_CEP, COBRANCA_TELEFONE CADASTRO_CLI_FOR.COBRANCA_TELEFONE, 
*!*					 ENTREGA_ENDERECO CADASTRO_CLI_FOR.ENTREGA_ENDERECO, ENTREGA_BAIRRO CADASTRO_CLI_FOR.ENTREGA_BAIRRO, 
*!*					 ENTREGA_CIDADE CADASTRO_CLI_FOR.ENTREGA_CIDADE, ACEITA_DIAS_FIXO CADASTRO_CLI_FOR.ACEITA_DIAS_FIXO, 
*!*					 ENTREGA_UF CADASTRO_CLI_FOR.ENTREGA_UF, ENTREGA_CEP CADASTRO_CLI_FOR.ENTREGA_CEP, 
*!*					 ENTREGA_TELEFONE CADASTRO_CLI_FOR.ENTREGA_TELEFONE, COBRANCA_DDD CADASTRO_CLI_FOR.COBRANCA_DDD, 
*!*					 CONTATO CADASTRO_CLI_FOR.CONTATO, COBRANCA_CGC CADASTRO_CLI_FOR.COBRANCA_CGC, 
*!*					 CADASTRAMENTO CADASTRO_CLI_FOR.CADASTRAMENTO, COBRANCA_IE CADASTRO_CLI_FOR.COBRANCA_IE, 
*!*					 ANIVERSARIO CADASTRO_CLI_FOR.ANIVERSARIO, INDICA_FORNECEDOR CADASTRO_CLI_FOR.INDICA_FORNECEDOR, 
*!*					 INDICA_CLIENTE CADASTRO_CLI_FOR.INDICA_CLIENTE, IND_REPRESENTANTE CADASTRO_CLI_FOR.IND_REPRESENTANTE, 
*!*					 INDICA_FILIAL CADASTRO_CLI_FOR.INDICA_FILIAL, ENTREGA_DDD CADASTRO_CLI_FOR.ENTREGA_DDD, 
*!*					 ENTREGA_CGC CADASTRO_CLI_FOR.ENTREGA_CGC, CLIFOR1 CLIENTES_ATACADO.CLIFOR, CGC_CPF1 CLIENTES_ATACADO.CGC_CPF, 
*!*					 BLOQUEIO_FATURAMENTO CLIENTES_ATACADO.BLOQUEIO_FATURAMENTO, BLOQUEIO_EXPEDICAO CLIENTES_ATACADO.BLOQUEIO_EXPEDICAO, 
*!*					 BLOQUEIO_PEDIDOS CLIENTES_ATACADO.BLOQUEIO_PEDIDOS, LIMITE_CREDITO CLIENTES_ATACADO.LIMITE_CREDITO, 
*!*					 SEM_CREDITO CLIENTES_ATACADO.SEM_CREDITO, PRIORIDADE CLIENTES_ATACADO.PRIORIDADE, TIPO CLIENTES_ATACADO.TIPO, FRETE_A_PAGAR CLIENTES_ATACADO.FRETE_A_PAGAR, CONCEITO CLIENTES_ATACADO.CONCEITO, FILIAL CLIENTES_ATACADO.FILIAL, TRANSPORTADORA CLIENTES_ATACADO.TRANSPORTADORA, PONTUALIDADE CLIENTES_ATACADO.PONTUALIDADE, MATRIZ_CLIENTE CLIENTES_ATACADO.MATRIZ_CLIENTE, CLIENTE_ATACADO CLIENTES_ATACADO.CLIENTE_ATACADO, ENTREGA_IE CADASTRO_CLI_FOR.ENTREGA_IE, REGIAO CLIENTES_ATACADO.REGIAO, CONDICAO_PGTO CLIENTES_ATACADO.CONDICAO_PGTO, BANCO CADASTRO_CLI_FOR.BANCO, CC_AGENCIA CADASTRO_CLI_FOR.CC_AGENCIA, CC_CONTA CADASTRO_CLI_FOR.CC_CONTA, CC_NOME_AGENCIA CADASTRO_CLI_FOR.CC_NOME_AGENCIA, REF_ANTERIOR CADASTRO_CLI_FOR.REF_ANTERIOR, NUMERO_PEDIDOS CLIENTES_ATACADO.NUMERO_PEDIDOS, DATA_MAIOR_PEDIDO CLIENTES_ATACADO.DATA_MAIOR_PEDIDO, MAIOR_PEDIDO CLIENTES_ATACADO.MAIOR_PEDIDO, MAIOR_SALDO CLIENTES_ATACADO.MAIOR_SALDO, 
*!*					DATA_MAIOR_SALDO CLIENTES_ATACADO.DATA_MAIOR_SALDO, NUMERO_ATRASOS CLIENTES_ATACADO.NUMERO_ATRASOS, 
*!*					MAIOR_ATRASO CLIENTES_ATACADO.MAIOR_ATRASO, PGTOS_CARTORIO CLIENTES_ATACADO.PGTOS_CARTORIO, 
*!*					NUMERO_DEVOLUCOES CLIENTES_ATACADO.NUMERO_DEVOLUCOES, MAIOR_DEVOLUCAO CLIENTES_ATACADO.MAIOR_DEVOLUCAO, 
*!*					NUMERO_PRORROGACOES CLIENTES_ATACADO.NUMERO_PRORROGACOES, MAIOR_PRORROGACAO CLIENTES_ATACADO.MAIOR_PRORROGACAO,
*!*					MAIOR_QTDE_DEV CLIENTES_ATACADO.MAIOR_QTDE_DEV, DATA_MAIOR_QTDE_DEV CLIENTES_ATACADO.DATA_MAIOR_QTDE_DEV, 
*!*					DATA_MAIOR_DEVOLUCAO CLIENTES_ATACADO.DATA_MAIOR_DEVOLUCAO, MAIOR_QTDE_PEDIDO CLIENTES_ATACADO.MAIOR_QTDE_PEDIDO, 
*!*					DATA_MAIOR_QTDE_PEDIDO CLIENTES_ATACADO.DATA_MAIOR_QTDE_PEDIDO, 
*!*					DESCONTO_FATURAMENTO CLIENTES_ATACADO.DESCONTO_FATURAMENTO, CARTEIRA CADASTRO_CLI_FOR.CARTEIRA, 
*!*					OBS_DE_FATURAMENTO CADASTRO_CLI_FOR.OBS_DE_FATURAMENTO, OBS CLIENTES_ATACADO.OBS, EMAIL CADASTRO_CLI_FOR.EMAIL, 
*!*					MOEDA CLIENTES_ATACADO.MOEDA, INATIVO CLIENTES_ATACADO.INATIVO, 
*!*					ATUALIZACAO_EXPORTAR CADASTRO_CLI_FOR.ATUALIZACAO_EXPORTAR, DATA_EXPORTACAO CADASTRO_CLI_FOR.DATA_EXPORTACAO, 
*!*					STATUS_ENVIO CADASTRO_CLI_FOR.STATUS_ENVIO, INATIVO1 CADASTRO_CLI_FOR.INATIVO, 
*!*					DATA_PARA_TRANSFERENCIA CADASTRO_CLI_FOR.DATA_PARA_TRANSFERENCIA, ENTREGA_PAIS CADASTRO_CLI_FOR.ENTREGA_PAIS, 
*!*					COBRANCA_PAIS CADASTRO_CLI_FOR.COBRANCA_PAIS, ENTREGA_DDI CADASTRO_CLI_FOR.ENTREGA_DDI, 
*!*					COBRANCA_DDI CADASTRO_CLI_FOR.COBRANCA_DDI, COD_CLIENTE CLIENTES_ATACADO.COD_CLIENTE, 
*!*					DATA_PARA_TRANSFERENCIA1 CLIENTES_ATACADO.DATA_PARA_TRANSFERENCIA, INDICA_FRANQUIA CLIENTES_ATACADO.INDICA_FRANQUIA, 
*!*					CODIGO_TAB_PRECO CLIENTES_ATACADO.CODIGO_TAB_PRECO, FATOR_CUSTO_FRANQUIA CLIENTES_ATACADO.FATOR_CUSTO_FRANQUIA, 
*!*					DESCONTO_PEDIDO_VENDA CLIENTES_ATACADO.DESCONTO_PEDIDO_VENDA, 
*!*					SEGURO_NUMERO_CONTRATO CLIENTES_ATACADO.SEGURO_NUMERO_CONTRATO, 
*!*					SEGURO_NUMERO_CLIENTE CLIENTES_ATACADO.SEGURO_NUMERO_CLIENTE, SEGURO_VALIDADE CLIENTES_ATACADO.SEGURO_VALIDADE, 
*!*					ISENTO_IPI CADASTRO_CLI_FOR.ISENTO_IPI, ISENTO_ICMS CADASTRO_CLI_FOR.ISENTO_ICMS, 
*!*					MESES_SEM_VENCIMENTO CADASTRO_CLI_FOR.MESES_SEM_VENCIMENTO, DATA_FIXA_PGTO CADASTRO_CLI_FOR.DATA_FIXA_PGTO, 
*!*					ACEITA_AGRUPAR_FATURA CADASTRO_CLI_FOR.ACEITA_AGRUPAR_FATURA, 
*!*					NUMERO_VIAS_FATURA CADASTRO_CLI_FOR.NUMERO_VIAS_FATURA, REPORT_FATURA CADASTRO_CLI_FOR.REPORT_FATURA, 
*!*					DIAS_ANTECIPACAO_PGTO CADASTRO_CLI_FOR.DIAS_ANTECIPACAO_PGTO, PASSWEB CADASTRO_CLI_FOR.PASSWEB, 
*!*					VENCIMENTO_PASSWEB CADASTRO_CLI_FOR.VENCIMENTO_PASSWEB, ACEITA_JUNTAR_PED CLIENTES_ATACADO.ACEITA_JUNTAR_PED, 
*!*					POSSUI_RECARGO CADASTRO_CLI_FOR.POSSUI_RECARGO, 
*!*					EXPEDICAO_COMPLETO_PEDIDO CLIENTES_ATACADO.EXPEDICAO_COMPLETO_PEDIDO, 
*!*					EXPEDICAO_COMPLETO_PACK CLIENTES_ATACADO.EXPEDICAO_COMPLETO_PACK, 
*!*					EXPEDICAO_COMPLETO_TAMANHOS CLIENTES_ATACADO.EXPEDICAO_COMPLETO_TAMANHOS, 
*!*					EXPEDICAO_COMPLETO_COR CLIENTES_ATACADO.EXPEDICAO_COMPLETO_COR, 
*!*					EXPEDICAO_COMPLETO_COORDENADO CLIENTES_ATACADO.EXPEDICAO_COMPLETO_COORDENADO, 
*!*					EXPEDICAO_PORCENTAGEM_MAIOR CLIENTES_ATACADO.EXPEDICAO_PORCENTAGEM_MAIOR, 
*!*					EXPEDICAO_PORCENTAGEM_MINIMA CLIENTES_ATACADO.EXPEDICAO_PORCENTAGEM_MINIMA, 
*!*					EXPEDICAO_PORCENTAGEM_TIPO CLIENTES_ATACADO.EXPEDICAO_PORCENTAGEM_TIPO, 
*!*					EXPEDICAO_VALOR_MAXIMO CLIENTES_ATACADO.EXPEDICAO_VALOR_MAXIMO, 
*!*					EXPEDICAO_COMPLETO_CARTELA CLIENTES_ATACADO.EXPEDICAO_COMPLETO_CARTELA, 
*!*					EXPEDICAO_COMPLETO_FAIXAS CLIENTES_ATACADO.EXPEDICAO_COMPLETO_FAIXAS, 
*!*					EXPEDICAO_PORC_ADEQUACAO CLIENTES_ATACADO.EXPEDICAO_PORC_ADEQUACAO, 
*!*					EXPEDICAO_QTDE_ADEQUACAO CLIENTES_ATACADO.EXPEDICAO_QTDE_ADEQUACAO, 
*!*					EXPEDICAO_ADEQUACAO_COR CLIENTES_ATACADO.EXPEDICAO_ADEQUACAO_COR, 
*!*					EXPEDICAO_ADEQUACAO_TAMANHO CLIENTES_ATACADO.EXPEDICAO_ADEQUACAO_TAMANHO, 
*!*					AGRUPAMENTO_ITENS CADASTRO_CLI_FOR.AGRUPAMENTO_ITENS, INDICADOR_VENDA CLIENTES_ATACADO.INDICADOR_VENDA, 
*!*					ID_EXCECAO_GRUPO CADASTRO_CLI_FOR.ID_EXCECAO_GRUPO, TIPO_BLOQUEIO CLIENTES_ATACADO.TIPO_BLOQUEIO, 
*!*					INDICADOR_FISCAL_TERCEIRO CADASTRO_CLI_FOR.INDICADOR_FISCAL_TERCEIRO, 
*!*					CTB_CONTA_CONTABIL CLIENTES_ATACADO.CTB_CONTA_CONTABIL, COD_CLIFOR CADASTRO_CLI_FOR.COD_CLIFOR, 
*!*					COBRANCA_RAZAO_SOCIAL CADASTRO_CLI_FOR.COBRANCA_RAZAO_SOCIAL, 
*!*					ENTREGA_RAZAO_SOCIAL CADASTRO_CLI_FOR.ENTREGA_RAZAO_SOCIAL, IM CADASTRO_CLI_FOR.IM, 
*!*					IM_ENTREGA CADASTRO_CLI_FOR.IM_ENTREGA, IM_COBRANCA CADASTRO_CLI_FOR.IM_COBRANCA, 
*!*					DESCONTO_BRUTO_1 CLIENTES_ATACADO.DESCONTO_BRUTO_1, DESCONTO_BRUTO_2 CLIENTES_ATACADO.DESCONTO_BRUTO_2, 
*!*					DESCONTO_BRUTO_3 CLIENTES_ATACADO.DESCONTO_BRUTO_3, DESCONTO_BRUTO_4 CLIENTES_ATACADO.DESCONTO_BRUTO_4, 
*!*					DESCONTO_SOBRE_1 CLIENTES_ATACADO.DESCONTO_SOBRE_1, DESCONTO_SOBRE_2 CLIENTES_ATACADO.DESCONTO_SOBRE_2, 
*!*					DESCONTO_SOBRE_3 CLIENTES_ATACADO.DESCONTO_SOBRE_3, DESCONTO_SOBRE_4 CLIENTES_ATACADO.DESCONTO_SOBRE_4, 
*!*					MULTI_DESCONTO_ACUMULAR CLIENTES_ATACADO.MULTI_DESCONTO_ACUMULAR, 
*!*					INSCRICAO_SUFRAMA CADASTRO_CLI_FOR.INSCRICAO_SUFRAMA, INCL_AUTO_GRP_ECON CADASTRO_CLI_FOR.INCL_AUTO_GRP_ECON, 
*!*					NUMERO CADASTRO_CLI_FOR.NUMERO, COMPLEMENTO CADASTRO_CLI_FOR.COMPLEMENTO, 
*!*					COBRANCA_NUMERO CADASTRO_CLI_FOR.COBRANCA_NUMERO, COBRANCA_COMPLEMENTO CADASTRO_CLI_FOR.COBRANCA_COMPLEMENTO, 
*!*					ENTREGA_NUMERO CADASTRO_CLI_FOR.ENTREGA_NUMERO, ENTREGA_COMPLEMENTO CADASTRO_CLI_FOR.ENTREGA_COMPLEMENTO, 
*!*					COD_MUNICIPIO_IBGE CADASTRO_CLI_FOR.COD_MUNICIPIO_IBGE, 
*!*					COD_MUNICIPIO_IBGE_COBRANCA CADASTRO_CLI_FOR.COD_MUNICIPIO_IBGE_COBRANCA, 
*!*					COD_MUNICIPIO_IBGE_ENTREGA CADASTRO_CLI_FOR.COD_MUNICIPIO_IBGE_ENTREGA, EMAIL_NFE CADASTRO_CLI_FOR.EMAIL_NFE, 
*!*					CONTEUDO_XPED_NFE CLIENTES_ATACADO.CONTEUDO_XPED_NFE, TIPO_TRIBUTACAO CADASTRO_CLI_FOR.TIPO_TRIBUTACAO, 
*!*					EBS_ID_CLIENTE CADASTRO_CLI_FOR.EBS_ID_CLIENTE
*!*				ENDTEXT

*!*				.CURSORV_CLIENTES_01.UpdateNameList = VLC_UpdateNameList

*!*				***
*!*				*** UpdatableFieldList 
*!*				***
*!*				TEXT TO  .CURSORV_CLIENTES_01.UpdatableFieldList NOSHOW TEXTMERGE PRETEXT 7
*!*					INDICA_CPRB, CADASTRO_CNO, NOME_CLIFOR, CLIFOR, RAZAO_SOCIAL, CGC_CPF, 
*!*					CONTA_CONTABIL, PJ_PF, RG_IE, CEP,ENDERECO, CIDADE, BAIRRO, UF, TELEFONE1, PAIS, 
*!*					DDI, TELEFONE2, FAX, DDD1,RAMAL1, RAMAL2, DDD2, COBRANCA_ENDERECO, 
*!*					COBRANCA_CIDADE, COBRANCA_BAIRRO, DDDFAX, COBRANCA_UF, CODIGO_CONTATO, 
*!*					COBRANCA_CEP,COBRANCA_TELEFONE, ENTREGA_ENDERECO, ENTREGA_BAIRRO, 
*!*					ENTREGA_CIDADE, ACEITA_DIAS_FIXO, ENTREGA_UF, ENTREGA_CEP, ENTREGA_TELEFONE, 
*!*					COBRANCA_DDD, CONTATO,COBRANCA_CGC, CADASTRAMENTO, COBRANCA_IE, ANIVERSARIO, 
*!*					INDICA_FORNECEDOR, INDICA_CLIENTE, IND_REPRESENTANTE, INDICA_FILIAL, 
*!*					ENTREGA_DDD, ENTREGA_CGC,CLIFOR1, CGC_CPF1, BLOQUEIO_FATURAMENTO, 
*!*					BLOQUEIO_EXPEDICAO, BLOQUEIO_PEDIDOS, LIMITE_CREDITO, SEM_CREDITO, PRIORIDADE, 
*!*					TIPO, FRETE_A_PAGAR,CONCEITO, FILIAL, TRANSPORTADORA, PONTUALIDADE, 
*!*					MATRIZ_CLIENTE, CLIENTE_ATACADO, ENTREGA_IE, REGIAO, CONDICAO_PGTO, 
*!*					BANCO,CC_AGENCIA, CC_CONTA, CC_NOME_AGENCIA, REF_ANTERIOR, NUMERO_PEDIDOS, 
*!*					DATA_MAIOR_PEDIDO, MAIOR_PEDIDO, MAIOR_SALDO, DATA_MAIOR_SALDO, 
*!*					NUMERO_ATRASOS,MAIOR_ATRASO, PGTOS_CARTORIO, NUMERO_DEVOLUCOES, MAIOR_DEVOLUCAO, 
*!*					NUMERO_PRORROGACOES, MAIOR_PRORROGACAO, MAIOR_QTDE_DEV, DATA_MAIOR_QTDE_DEV, 
*!*					DATA_MAIOR_DEVOLUCAO, MAIOR_QTDE_PEDIDO,DATA_MAIOR_QTDE_PEDIDO, 
*!*					DESCONTO_FATURAMENTO, CARTEIRA, OBS_DE_FATURAMENTO, OBS, EMAIL, MOEDA, INATIVO, 
*!*					ATUALIZACAO_EXPORTAR, DATA_EXPORTACAO,STATUS_ENVIO, INATIVO1, 
*!*					DATA_PARA_TRANSFERENCIA, ENTREGA_PAIS, COBRANCA_PAIS, ENTREGA_DDI, COBRANCA_DDI, 
*!*					COD_CLIENTE, DATA_PARA_TRANSFERENCIA1,INDICA_FRANQUIA, CODIGO_TAB_PRECO, 
*!*					FATOR_CUSTO_FRANQUIA, DESCONTO_PEDIDO_VENDA, SEGURO_NUMERO_CONTRATO, 
*!*					SEGURO_NUMERO_CLIENTE, SEGURO_VALIDADE, ISENTO_IPI, ISENTO_ICMS, 
*!*					MESES_SEM_VENCIMENTO, DATA_FIXA_PGTO, ACEITA_AGRUPAR_FATURA, 
*!*					NUMERO_VIAS_FATURA,REPORT_FATURA, DIAS_ANTECIPACAO_PGTO, 
*!*					PASSWEB,VENCIMENTO_PASSWEB, ACEITA_JUNTAR_PED, POSSUI_RECARGO, 
*!*					EXPEDICAO_COMPLETO_PEDIDO, EXPEDICAO_COMPLETO_PACK, 
*!*					EXPEDICAO_COMPLETO_TAMANHOS,EXPEDICAO_COMPLETO_COR, 
*!*					EXPEDICAO_COMPLETO_COORDENADO, EXPEDICAO_PORCENTAGEM_MAIOR, 
*!*					EXPEDICAO_PORCENTAGEM_MINIMA, EXPEDICAO_PORCENTAGEM_TIPO, 
*!*					EXPEDICAO_VALOR_MAXIMO, EXPEDICAO_COMPLETO_CARTELA, EXPEDICAO_COMPLETO_FAIXAS, 
*!*					EXPEDICAO_PORC_ADEQUACAO,EXPEDICAO_QTDE_ADEQUACAO,EXPEDICAO_ADEQUACAO_COR, 
*!*					EXPEDICAO_ADEQUACAO_TAMANHO, AGRUPAMENTO_ITENS, INDICADOR_VENDA, 
*!*					ID_EXCECAO_GRUPO, TIPO_BLOQUEIO, INDICADOR_FISCAL_TERCEIRO, CTB_CONTA_CONTABIL, 
*!*					COD_CLIFOR, COBRANCA_RAZAO_SOCIAL, ENTREGA_RAZAO_SOCIAL, IM, 
*!*					IM_ENTREGA,IM_COBRANCA,DESCONTO_BRUTO_1, DESCONTO_BRUTO_2, DESCONTO_BRUTO_3, 
*!*					DESCONTO_BRUTO_4, DESCONTO_SOBRE_1, DESCONTO_SOBRE_2, DESCONTO_SOBRE_3, 
*!*					DESCONTO_SOBRE_4,MULTI_DESCONTO_ACUMULAR, INSCRICAO_SUFRAMA, INCL_AUTO_GRP_ECON, 
*!*					NUMERO, COMPLEMENTO, COBRANCA_NUMERO, COBRANCA_COMPLEMENTO, ENTREGA_NUMERO, 
*!*					ENTREGA_COMPLEMENTO,COD_MUNICIPIO_IBGE, COD_MUNICIPIO_IBGE_COBRANCA, 
*!*					COD_MUNICIPIO_IBGE_ENTREGA, EMAIL_NFE, CONTEUDO_XPED_NFE, TIPO_TRIBUTACAO, 
*!*					EBS_ID_CLIENTE
*!*				ENDTEXT

*!*				***
*!*				*** Tables
*!*				***
*!*				 .CURSORV_CLIENTES_01.Tables = "CADASTRO_CLI_FOR,CLIENTES_ATACADO"

*!*				***
*!*				*** KeyFieldList
*!*				***
*!*				 .CURSORV_CLIENTES_01.KeyFieldList= "NOME_CLIFOR, CLIENTE_ATACADO"

*!*				***
*!*				*** QueryList
*!*				***
*!*				TEXT TO  .CURSORV_CLIENTES_01.QueryList NOSHOW TEXTMERGE PRETEXT 7
*!*					INDICA_CPRB CADASTRO_CLI_FOR.INDICA_CPRB , CADASTRO_CNO 
*!*					CADASTRO_CLI_FOR.CADASTRO_CNO , NOME_CLIFOR CADASTRO_CLI_FOR.NOME_CLIFOR, CLIFOR 
*!*					CADASTRO_CLI_FOR.CLIFOR, RAZAO_SOCIAL CADASTRO_CLI_FOR.RAZAO_SOCIAL, CGC_CPF 
*!*					CADASTRO_CLI_FOR.CGC_CPF, CONTA_CONTABIL CLIENTES_ATACADO.CONTA_CONTABIL, 
*!*					DESC_CONTA CONTAS_PLANO.DESC_CONTA,PJ_PF CADASTRO_CLI_FOR.PJ_PF, RG_IE 
*!*					CADASTRO_CLI_FOR.RG_IE, CEP CADASTRO_CLI_FOR.CEP,ENDERECO 
*!*					CADASTRO_CLI_FOR.ENDERECO, CIDADE CADASTRO_CLI_FOR.CIDADE, BAIRRO 
*!*					CADASTRO_CLI_FOR.BAIRRO, UF CADASTRO_CLI_FOR.UF, TELEFONE1 
*!*					CADASTRO_CLI_FOR.TELEFONE1, PAIS CADASTRO_CLI_FOR.PAIS, DDI 
*!*					CADASTRO_CLI_FOR.DDI,TELEFONE2 CADASTRO_CLI_FOR.TELEFONE2, FAX 
*!*					CADASTRO_CLI_FOR.FAX, DDD1 CADASTRO_CLI_FOR.DDD1,RAMAL1 CADASTRO_CLI_FOR.RAMAL1, 
*!*					RAMAL2 CADASTRO_CLI_FOR.RAMAL2, DDD2 CADASTRO_CLI_FOR.DDD2, COBRANCA_ENDERECO 
*!*					CADASTRO_CLI_FOR.COBRANCA_ENDERECO, COBRANCA_CIDADE 
*!*					CADASTRO_CLI_FOR.COBRANCA_CIDADE, COBRANCA_BAIRRO 
*!*					CADASTRO_CLI_FOR.COBRANCA_BAIRRO,DDDFAX CADASTRO_CLI_FOR.DDDFAX, COBRANCA_UF 
*!*					CADASTRO_CLI_FOR.COBRANCA_UF, CODIGO_CONTATO CADASTRO_CLI_FOR.CODIGO_CONTATO, 
*!*					COBRANCA_CEP CADASTRO_CLI_FOR.COBRANCA_CEP,COBRANCA_TELEFONE 
*!*					CADASTRO_CLI_FOR.COBRANCA_TELEFONE, ENTREGA_ENDERECO 
*!*					CADASTRO_CLI_FOR.ENTREGA_ENDERECO, ENTREGA_BAIRRO 
*!*					CADASTRO_CLI_FOR.ENTREGA_BAIRRO, ENTREGA_CIDADE 
*!*					CADASTRO_CLI_FOR.ENTREGA_CIDADE,ACEITA_DIAS_FIXO 
*!*					CADASTRO_CLI_FOR.ACEITA_DIAS_FIXO, ENTREGA_UF CADASTRO_CLI_FOR.ENTREGA_UF, 
*!*					ENTREGA_CEP CADASTRO_CLI_FOR.ENTREGA_CEP, ENTREGA_TELEFONE 
*!*					CADASTRO_CLI_FOR.ENTREGA_TELEFONE, COBRANCA_DDD 
*!*					CADASTRO_CLI_FOR.COBRANCA_DDD,CONTATO CADASTRO_CLI_FOR.CONTATO,COBRANCA_CGC 
*!*					CADASTRO_CLI_FOR.COBRANCA_CGC, CADASTRAMENTO CADASTRO_CLI_FOR.CADASTRAMENTO, 
*!*					COBRANCA_IE CADASTRO_CLI_FOR.COBRANCA_IE, ANIVERSARIO 
*!*					CADASTRO_CLI_FOR.ANIVERSARIO, INDICA_FORNECEDOR 
*!*					CADASTRO_CLI_FOR.INDICA_FORNECEDOR,INDICA_CLIENTE 
*!*					CADASTRO_CLI_FOR.INDICA_CLIENTE, IND_REPRESENTANTE 
*!*					CADASTRO_CLI_FOR.IND_REPRESENTANTE, INDICA_FILIAL 
*!*					CADASTRO_CLI_FOR.INDICA_FILIAL, ENTREGA_DDD CADASTRO_CLI_FOR.ENTREGA_DDD, 
*!*					ENTREGA_CGC CADASTRO_CLI_FOR.ENTREGA_CGC,CLIFOR1 CLIENTES_ATACADO.CLIFOR, 
*!*					CGC_CPF1 CLIENTES_ATACADO.CGC_CPF, BLOQUEIO_FATURAMENTO 
*!*					CLIENTES_ATACADO.BLOQUEIO_FATURAMENTO, BLOQUEIO_EXPEDICAO 
*!*					CLIENTES_ATACADO.BLOQUEIO_EXPEDICAO, BLOQUEIO_PEDIDOS 
*!*					CLIENTES_ATACADO.BLOQUEIO_PEDIDOS,LIMITE_CREDITO 
*!*					CLIENTES_ATACADO.LIMITE_CREDITO, SEM_CREDITO CLIENTES_ATACADO.SEM_CREDITO, 
*!*					PRIORIDADE CLIENTES_ATACADO.PRIORIDADE, TIPO CLIENTES_ATACADO.TIPO, 
*!*					FRETE_A_PAGAR CLIENTES_ATACADO.FRETE_A_PAGAR,CONCEITO CLIENTES_ATACADO.CONCEITO, 
*!*					FILIAL CLIENTES_ATACADO.FILIAL, TRANSPORTADORA CLIENTES_ATACADO.TRANSPORTADORA, 
*!*					PONTUALIDADE CLIENTES_ATACADO.PONTUALIDADE, MATRIZ_CLIENTE 
*!*					CLIENTES_ATACADO.MATRIZ_CLIENTE,CLIENTE_ATACADO 
*!*					CLIENTES_ATACADO.CLIENTE_ATACADO, ENTREGA_IE CADASTRO_CLI_FOR.ENTREGA_IE, REGIAO 
*!*					CLIENTES_ATACADO.REGIAO, CONDICAO_PGTO CLIENTES_ATACADO.CONDICAO_PGTO, BANCO 
*!*					CADASTRO_CLI_FOR.BANCO,CC_AGENCIA CADASTRO_CLI_FOR.CC_AGENCIA, CC_CONTA 
*!*					CADASTRO_CLI_FOR.CC_CONTA, CC_NOME_AGENCIA CADASTRO_CLI_FOR.CC_NOME_AGENCIA, 
*!*					REF_ANTERIOR CADASTRO_CLI_FOR.REF_ANTERIOR, NUMERO_PEDIDOS 
*!*					CLIENTES_ATACADO.NUMERO_PEDIDOS,DATA_MAIOR_PEDIDO 
*!*					CLIENTES_ATACADO.DATA_MAIOR_PEDIDO, MAIOR_PEDIDO CLIENTES_ATACADO.MAIOR_PEDIDO, 
*!*					MAIOR_SALDO CLIENTES_ATACADO.MAIOR_SALDO, DATA_MAIOR_SALDO 
*!*					CLIENTES_ATACADO.DATA_MAIOR_SALDO, NUMERO_ATRASOS 
*!*					CLIENTES_ATACADO.NUMERO_ATRASOS,MAIOR_ATRASO CLIENTES_ATACADO.MAIOR_ATRASO, 
*!*					PGTOS_CARTORIO CLIENTES_ATACADO.PGTOS_CARTORIO, NUMERO_DEVOLUCOES 
*!*					CLIENTES_ATACADO.NUMERO_DEVOLUCOES, MAIOR_DEVOLUCAO 
*!*					CLIENTES_ATACADO.MAIOR_DEVOLUCAO,NUMERO_PRORROGACOES 
*!*					CLIENTES_ATACADO.NUMERO_PRORROGACOES, MAIOR_PRORROGACAO 
*!*					CLIENTES_ATACADO.MAIOR_PRORROGACAO, MAIOR_QTDE_DEV 
*!*					CLIENTES_ATACADO.MAIOR_QTDE_DEV, DATA_MAIOR_QTDE_DEV 
*!*					CLIENTES_ATACADO.DATA_MAIOR_QTDE_DEV,DATA_MAIOR_DEVOLUCAO 
*!*					CLIENTES_ATACADO.DATA_MAIOR_DEVOLUCAO, MAIOR_QTDE_PEDIDO 
*!*					CLIENTES_ATACADO.MAIOR_QTDE_PEDIDO,DATA_MAIOR_QTDE_PEDIDO 
*!*					CLIENTES_ATACADO.DATA_MAIOR_QTDE_PEDIDO, DESCONTO_FATURAMENTO 
*!*					CLIENTES_ATACADO.DESCONTO_FATURAMENTO, CARTEIRA CADASTRO_CLI_FOR.CARTEIRA, 
*!*					OBS_DE_FATURAMENTO CADASTRO_CLI_FOR.OBS_DE_FATURAMENTO, OBS 
*!*					CLIENTES_ATACADO.OBS,EMAIL CADASTRO_CLI_FOR.EMAIL, MOEDA CLIENTES_ATACADO.MOEDA, 
*!*					INATIVO CLIENTES_ATACADO.INATIVO, ATUALIZACAO_EXPORTAR 
*!*					CADASTRO_CLI_FOR.ATUALIZACAO_EXPORTAR, DATA_EXPORTACAO 
*!*					CADASTRO_CLI_FOR.DATA_EXPORTACAO,STATUS_ENVIO CADASTRO_CLI_FOR.STATUS_ENVIO, 
*!*					INATIVO1 CADASTRO_CLI_FOR.INATIVO, DATA_PARA_TRANSFERENCIA 
*!*					CADASTRO_CLI_FOR.DATA_PARA_TRANSFERENCIA, ENTREGA_PAIS 
*!*					CADASTRO_CLI_FOR.ENTREGA_PAIS, COBRANCA_PAIS 
*!*					CADASTRO_CLI_FOR.COBRANCA_PAIS,NOME_BANCO BANCOS.NOME_BANCO, ENTREGA_DDI 
*!*					CADASTRO_CLI_FOR.ENTREGA_DDI, COBRANCA_DDI CADASTRO_CLI_FOR.COBRANCA_DDI, 
*!*					COD_CLIENTE CLIENTES_ATACADO.COD_CLIENTE, DATA_PARA_TRANSFERENCIA1 
*!*					CLIENTES_ATACADO.DATA_PARA_TRANSFERENCIA,INDICA_FRANQUIA 
*!*					CLIENTES_ATACADO.INDICA_FRANQUIA, CODIGO_TAB_PRECO 
*!*					CLIENTES_ATACADO.CODIGO_TAB_PRECO, FATOR_CUSTO_FRANQUIA 
*!*					CLIENTES_ATACADO.FATOR_CUSTO_FRANQUIA, DESCONTO_PEDIDO_VENDA 
*!*					CLIENTES_ATACADO.DESCONTO_PEDIDO_VENDA,SEGURO_NUMERO_CONTRATO 
*!*					CLIENTES_ATACADO.SEGURO_NUMERO_CONTRATO, SEGURO_NUMERO_CLIENTE 
*!*					CLIENTES_ATACADO.SEGURO_NUMERO_CLIENTE, SEGURO_VALIDADE 
*!*					CLIENTES_ATACADO.SEGURO_VALIDADE, ISENTO_IPI 
*!*					CADASTRO_CLI_FOR.ISENTO_IPI,ISENTO_ICMS CADASTRO_CLI_FOR.ISENTO_ICMS, 
*!*					MESES_SEM_VENCIMENTO CADASTRO_CLI_FOR.MESES_SEM_VENCIMENTO, DATA_FIXA_PGTO 
*!*					CADASTRO_CLI_FOR.DATA_FIXA_PGTO, ACEITA_AGRUPAR_FATURA 
*!*					CADASTRO_CLI_FOR.ACEITA_AGRUPAR_FATURA,NUMERO_VIAS_FATURA 
*!*					CADASTRO_CLI_FOR.NUMERO_VIAS_FATURA, REPORT_FATURA 
*!*					CADASTRO_CLI_FOR.REPORT_FATURA, DIAS_ANTECIPACAO_PGTO 
*!*					CADASTRO_CLI_FOR.DIAS_ANTECIPACAO_PGTO, PASSWEB 
*!*					CADASTRO_CLI_FOR.PASSWEB,VENCIMENTO_PASSWEB CADASTRO_CLI_FOR.VENCIMENTO_PASSWEB, 
*!*					ACEITA_JUNTAR_PED CLIENTES_ATACADO.ACEITA_JUNTAR_PED, POSSUI_RECARGO 
*!*					CADASTRO_CLI_FOR.POSSUI_RECARGO, EXPEDICAO_COMPLETO_PEDIDO 
*!*					CLIENTES_ATACADO.EXPEDICAO_COMPLETO_PEDIDO, EXPEDICAO_COMPLETO_PACK 
*!*					CLIENTES_ATACADO.EXPEDICAO_COMPLETO_PACK,EXPEDICAO_COMPLETO_TAMANHOS 
*!*					CLIENTES_ATACADO.EXPEDICAO_COMPLETO_TAMANHOS,EXPEDICAO_COMPLETO_COR 
*!*					CLIENTES_ATACADO.EXPEDICAO_COMPLETO_COR, EXPEDICAO_COMPLETO_COORDENADO 
*!*					CLIENTES_ATACADO.EXPEDICAO_COMPLETO_COORDENADO, EXPEDICAO_PORCENTAGEM_MAIOR 
*!*					CLIENTES_ATACADO.EXPEDICAO_PORCENTAGEM_MAIOR,EXPEDICAO_PORCENTAGEM_MINIMA 
*!*					CLIENTES_ATACADO.EXPEDICAO_PORCENTAGEM_MINIMA, EXPEDICAO_PORCENTAGEM_TIPO 
*!*					CLIENTES_ATACADO.EXPEDICAO_PORCENTAGEM_TIPO, EXPEDICAO_VALOR_MAXIMO 
*!*					CLIENTES_ATACADO.EXPEDICAO_VALOR_MAXIMO,EXPEDICAO_COMPLETO_CARTELA 
*!*					CLIENTES_ATACADO.EXPEDICAO_COMPLETO_CARTELA, EXPEDICAO_COMPLETO_FAIXAS 
*!*					CLIENTES_ATACADO.EXPEDICAO_COMPLETO_FAIXAS, EXPEDICAO_PORC_ADEQUACAO 
*!*					CLIENTES_ATACADO.EXPEDICAO_PORC_ADEQUACAO,EXPEDICAO_QTDE_ADEQUACAO 
*!*					CLIENTES_ATACADO.EXPEDICAO_QTDE_ADEQUACAO,EXPEDICAO_ADEQUACAO_COR 
*!*					CLIENTES_ATACADO.EXPEDICAO_ADEQUACAO_COR, EXPEDICAO_ADEQUACAO_TAMANHO 
*!*					CLIENTES_ATACADO.EXPEDICAO_ADEQUACAO_TAMANHO, AGRUPAMENTO_ITENS 
*!*					CADASTRO_CLI_FOR.AGRUPAMENTO_ITENS, INDICADOR_VENDA 
*!*					CLIENTES_ATACADO.INDICADOR_VENDA,ID_EXCECAO_GRUPO 
*!*					CADASTRO_CLI_FOR.ID_EXCECAO_GRUPO, DESC_EXCECAO_GRUPO 
*!*					CTB_EXCECAO_GRUPO.DESC_EXCECAO_GRUPO, TIPO_BLOQUEIO 
*!*					CLIENTES_ATACADO.TIPO_BLOQUEIO, INDICADOR_FISCAL_TERCEIRO 
*!*					CADASTRO_CLI_FOR.INDICADOR_FISCAL_TERCEIRO,DESCRICAO_FISCAL_TERCEIRO 
*!*					CTB_LX_INDICADOR_FISCAL_TERCEIRO.DESCRICAO_FISCAL_TERCEIRO, CTB_CONTA_CONTABIL 
*!*					CLIENTES_ATACADO.CTB_CONTA_CONTABIL,CTB_DESC_CONTA CTB_CONTA_PLANO.DESC_CONTA, 
*!*					COD_CLIFOR CADASTRO_CLI_FOR.COD_CLIFOR, COBRANCA_RAZAO_SOCIAL 
*!*					CADASTRO_CLI_FOR.COBRANCA_RAZAO_SOCIAL, ENTREGA_RAZAO_SOCIAL 
*!*					CADASTRO_CLI_FOR.ENTREGA_RAZAO_SOCIAL, CONTATO1 CONTATO.CONTATO,CPF_CGC 
*!*					CONTATO.CPF_CGC, PF_PJ CONTATO.PF_PJ, STATUS_CONTATO CONTATO.STATUS_CONTATO, 
*!*					CADASTRAMENTO_CONTATO CONTATO.CADASTRAMENTO, TIPO_CONTATO 
*!*					CONTATO.TIPO_CONTATO,SUBTIPO_CONTATO CONTATO.SUBTIPO_CONTATO, CATEGORIA_CONTATO 
*!*					CONTATO.CATEGORIA_CONTATO, SUBCATEGORIA_CONTATO CONTATO.SUBCATEGORIA_CONTATO, 
*!*					DESC_TIPO_CONTATO CONTATO_TIPO.DESC_TIPO_CONTATO, DESC_SUBTIPO_CONTATO 
*!*					CONTATO_SUBTIPO.DESC_SUBTIPO_CONTATO,DESC_CATEGORIA_CONTATO 
*!*					CONTATO_CATEGORIA.DESC_CATEGORIA_CONTATO, DESC_SUBCATEGORIA_CONTATO 
*!*					CONTATO_SUBCATEGORIA.DESC_SUBCATEGORIA_CONTATO, IM CADASTRO_CLI_FOR.IM, 
*!*					IM_ENTREGA CADASTRO_CLI_FOR.IM_ENTREGA, IM_COBRANCA 
*!*					CADASTRO_CLI_FOR.IM_COBRANCA,DESCONTO_BRUTO_1 CLIENTES_ATACADO.DESCONTO_BRUTO_1, 
*!*					DESCONTO_BRUTO_2 CLIENTES_ATACADO.DESCONTO_BRUTO_2, DESCONTO_BRUTO_3 
*!*					CLIENTES_ATACADO.DESCONTO_BRUTO_3, DESCONTO_BRUTO_4 
*!*					CLIENTES_ATACADO.DESCONTO_BRUTO_4,DESCONTO_SOBRE_1 
*!*					CLIENTES_ATACADO.DESCONTO_SOBRE_1, DESCONTO_SOBRE_2 
*!*					CLIENTES_ATACADO.DESCONTO_SOBRE_2, DESCONTO_SOBRE_3 
*!*					CLIENTES_ATACADO.DESCONTO_SOBRE_3, DESCONTO_SOBRE_4 
*!*					CLIENTES_ATACADO.DESCONTO_SOBRE_4,MULTI_DESCONTO_ACUMULAR 
*!*					CLIENTES_ATACADO.MULTI_DESCONTO_ACUMULAR, INSCRICAO_SUFRAMA 
*!*					CADASTRO_CLI_FOR.INSCRICAO_SUFRAMA, CLIENTES_ATACADO.DT_PRIMEIRA_VENDA,  
*!*					CLIENTES_ATACADO.DT_ULTIMA_VENDA,  CLIENTES_ATACADO.DT_PENULTIMA_VENDA,  
*!*					CLIENTES_ATACADO.DT_ANTEPENULTIMA_VENDA,INCL_AUTO_GRP_ECON 
*!*					CADASTRO_CLI_FOR.INCL_AUTO_GRP_ECON,NUMERO CADASTRO_CLI_FOR.NUMERO, COMPLEMENTO 
*!*					CADASTRO_CLI_FOR.COMPLEMENTO, COBRANCA_NUMERO CADASTRO_CLI_FOR.COBRANCA_NUMERO, 
*!*					COBRANCA_COMPLEMENTO CADASTRO_CLI_FOR.COBRANCA_COMPLEMENTO, ENTREGA_NUMERO 
*!*					CADASTRO_CLI_FOR.ENTREGA_NUMERO, ENTREGA_COMPLEMENTO 
*!*					CADASTRO_CLI_FOR.ENTREGA_COMPLEMENTO,COD_MUNICIPIO_IBGE 
*!*					CADASTRO_CLI_FOR.COD_MUNICIPIO_IBGE, COD_MUNICIPIO_IBGE_COBRANCA 
*!*					CADASTRO_CLI_FOR.COD_MUNICIPIO_IBGE_COBRANCA, COD_MUNICIPIO_IBGE_ENTREGA 
*!*					CADASTRO_CLI_FOR.COD_MUNICIPIO_IBGE_ENTREGA,EMAIL_NFE 
*!*					CADASTRO_CLI_FOR.EMAIL_NFE, CONTEUDO_XPED_NFE 
*!*					CLIENTES_ATACADO.CONTEUDO_XPED_NFE, TIPO_TRIBUTACAO 
*!*					CADASTRO_CLI_FOR.TIPO_TRIBUTACAO,EBS_ID_CLIENTE CADASTRO_CLI_FOR.EBS_ID_CLIENTE
*!*				ENDTEXT

*!*				***
*!*				*** CaptionList
*!*				***
*!*				TEXT TO  .CURSORV_CLIENTES_01.CaptionList NOSHOW TEXTMERGE PRETEXT 7
*!*					NOME_CLIFOR Nome Clifor, CLIFOR Clifor, RAZAO_SOCIAL Razao Social, CGC_CPF Cgc 
*!*					Cpf, CONTA_CONTABIL Conta Contabil, DESC_CONTA Desc Conta, PJ_PF Pj Pf, RG_IE Rg 
*!*					Ie, CEP Cep, ENDERECO Endereco, CIDADE Cidade, BAIRRO Bairro, UF Uf, TELEFONE1 
*!*					Telefone1,PAIS Pais, DDI Ddi, TELEFONE2 Telefone2, FAX Fax, DDD1 Ddd1, RAMAL1 
*!*					Ramal1, RAMAL2 Ramal2, DDD2 Ddd2, COBRANCA_ENDERECO Cobranca Endereco, 
*!*					COBRANCA_CIDADE Cobranca Cidade, COBRANCA_BAIRRO Cobranca Bairro, DDDFAX Dddfax, 
*!*					COBRANCA_UF Cobranca Uf,CODIGO_CONTATO Codigo Contato, COBRANCA_CEP Cobranca 
*!*					Cep, COBRANCA_TELEFONE Cobranca Telefone, ENTREGA_ENDERECO Entrega Endereco, 
*!*					ENTREGA_BAIRRO Entrega Bairro, ENTREGA_CIDADE Entrega Cidade, ACEITA_DIAS_FIXO 
*!*					Aceita Dias Fixo, ENTREGA_UF Entrega Uf,ENTREGA_CEP Entrega Cep, 
*!*					ENTREGA_TELEFONE Entrega Telefone, COBRANCA_DDD Cobranca Ddd, CONTATO Contato, 
*!*					COBRANCA_CGC Cobranca Cgc, CADASTRAMENTO Cadastramento, COBRANCA_IE Cobranca Ie, 
*!*					ANIVERSARIO Aniversario, INDICA_FORNECEDOR Indica Fornecedor,INDICA_CLIENTE 
*!*					Indica Cliente, IND_REPRESENTANTE Ind Representante, INDICA_FILIAL Indica 
*!*					Filial, ENTREGA_DDD Entrega Ddd, ENTREGA_CGC Entrega Cgc, CLIFOR1 Clifor1, 
*!*					CGC_CPF1 Cgc Cpf1, BLOQUEIO_FATURAMENTO Bloqueio Faturamento,BLOQUEIO_EXPEDICAO 
*!*					Bloqueio Expedicao, BLOQUEIO_PEDIDOS Bloqueio Pedidos, LIMITE_CREDITO Limite 
*!*					Credito, SEM_CREDITO Sem Credito, PRIORIDADE Prioridade, TIPO Tipo, 
*!*					FRETE_A_PAGAR Frete A Pagar, CONCEITO Conceito, FILIAL Filial,TRANSPORTADORA 
*!*					Transportadora, PONTUALIDADE Pontualidade, MATRIZ_CLIENTE Matriz Cliente, 
*!*					CLIENTE_ATACADO Cliente Atacado, ENTREGA_IE Entrega Ie, REGIAO Regiao, 
*!*					CONDICAO_PGTO Condicao Pgto, BANCO Banco, CC_AGENCIA Cc Agencia, CC_CONTA Cc 
*!*					Conta,CC_NOME_AGENCIA Cc Nome Agencia, REF_ANTERIOR Ref Anterior, NUMERO_PEDIDOS 
*!*					Numero Pedidos, DATA_MAIOR_PEDIDO Data Maior Pedido, MAIOR_PEDIDO Maior Pedido, 
*!*					MAIOR_SALDO Maior Saldo, DATA_MAIOR_SALDO Data Maior Saldo, NUMERO_ATRASOS 
*!*					Numero Atrasos,MAIOR_ATRASO Maior Atraso, PGTOS_CARTORIO Pgtos Cartorio, 
*!*					NUMERO_DEVOLUCOES Numero Devolucoes, MAIOR_DEVOLUCAO Maior Devolucao, 
*!*					NUMERO_PRORROGACOES Numero Prorrogacoes, MAIOR_PRORROGACAO Maior Prorrogacao, 
*!*					MAIOR_QTDE_DEV Maior Qtde Dev,DATA_MAIOR_QTDE_DEV Data Maior Qtde Dev, 
*!*					DATA_MAIOR_DEVOLUCAO Data Maior Devolucao, MAIOR_QTDE_PEDIDO Maior Qtde Pedido, 
*!*					DATA_MAIOR_QTDE_PEDIDO Data Maior Qtde Pedido, DESCONTO_FATURAMENTO Desconto 
*!*					Faturamento, CARTEIRA Carteira,OBS_DE_FATURAMENTO Obs De Faturamento, OBS Obs, 
*!*					EMAIL Email, MOEDA Moeda, INATIVO Inativo, ATUALIZACAO_EXPORTAR Atualizacao 
*!*					Exportar, DATA_EXPORTACAO Data Exportacao, STATUS_ENVIO Status Envio, INATIVO1 
*!*					Inativo1,DATA_PARA_TRANSFERENCIA Data Para Transferencia, ENTREGA_PAIS Entrega 
*!*					Pais, COBRANCA_PAIS Cobranca Pais, NOME_BANCO Nome Banco, ENTREGA_DDI Entrega 
*!*					Ddi, COBRANCA_DDI Cobranca Ddi, COD_CLIENTE Cod Cliente,DATA_PARA_TRANSFERENCIA1 
*!*					Data Para Transferencia1, INDICA_FRANQUIA Indica Franquia, CODIGO_TAB_PRECO 
*!*					Codigo Tab Preco, FATOR_CUSTO_FRANQUIA Fator Custo Franquia, 
*!*					DESCONTO_PEDIDO_VENDA Desconto Pedido Venda,SEGURO_NUMERO_CONTRATO Seguro Numero 
*!*					Contrato, SEGURO_NUMERO_CLIENTE Seguro Numero Cliente, SEGURO_VALIDADE Seguro 
*!*					Validade, ISENTO_IPI Isento Ipi, ISENTO_ICMS Isento Icms, MAIOR_VALOR_FATURADO 
*!*					Maior Valor Faturado,MESES_SEM_VENCIMENTO Meses Sem Vencimento, DATA_FIXA_PGTO 
*!*					Data Fixa Pgto, ACEITA_AGRUPAR_FATURA Aceita Agrupar Fatura, NUMERO_VIAS_FATURA 
*!*					Numero Vias Fatura, REPORT_FATURA Report Fatura,DIAS_ANTECIPACAO_PGTO Dias 
*!*					Antecipacao Pgto, PASSWEB Passweb, VENCIMENTO_PASSWEB Vencimento Passweb, 
*!*					ACEITA_JUNTAR_PED Aceita Juntar Ped, POSSUI_RECARGO Possui Recargo, 
*!*					EXPEDICAO_COMPLETO_PEDIDO Expedicao Completo Pedido, EXPEDICAO_COMPLETO_PACK 
*!*					Expedicao Completo Pack, EXPEDICAO_COMPLETO_TAMANHOS Expedicao Completo 
*!*					Tamanhos,EXPEDICAO_COMPLETO_COR Expedicao Completo Cor, 
*!*					EXPEDICAO_COMPLETO_COORDENADO Expedicao Completo Coordenado, 
*!*					EXPEDICAO_PORCENTAGEM_MAIOR Expedicao Porcentagem Maior, 
*!*					EXPEDICAO_PORCENTAGEM_MINIMA Expedicao Porcentagem 
*!*					Minima,EXPEDICAO_PORCENTAGEM_TIPO Expedicao Porcentagem Tipo, 
*!*					EXPEDICAO_VALOR_MAXIMO Expedicao Valor Maximo, EXPEDICAO_COMPLETO_CARTELA 
*!*					Expedicao Completo Cartela, EXPEDICAO_COMPLETO_FAIXAS Expedicao Completo 
*!*					Faixas,EXPEDICAO_PORC_ADEQUACAO Expedicao Porc Adequacao, 
*!*					EXPEDICAO_QTDE_ADEQUACAO Expedicao Qtde Adequacao, EXPEDICAO_ADEQUACAO_COR 
*!*					Expedicao Adequacao Cor, EXPEDICAO_ADEQUACAO_TAMANHO Expedicao Adequacao 
*!*					Tamanho, AGRUPAMENTO_ITENS Agrupamento Itens,INDICADOR_VENDA Indicador Venda, 
*!*					ID_EXCECAO_GRUPO Id Excecao Grupo, DESC_EXCECAO_GRUPO Desc Excecao Grupo, 
*!*					TIPO_BLOQUEIO Tipo Bloqueio, INDICADOR_FISCAL_TERCEIRO Indicador Fiscal 
*!*					Terceiro, DESCRICAO_FISCAL_TERCEIRO Descricao Fiscal Terceiro,CTB_CONTA_CONTABIL 
*!*					Ctb Conta Contabil, CTB_DESC_CONTA Ctb Desc Conta, COD_CLIFOR Cod Clifor, 
*!*					COBRANCA_RAZAO_SOCIAL Cobranca Razao Social, ENTREGA_RAZAO_SOCIAL Entrega Razao 
*!*					Social, CONTATO1 Contato1, CPF_CGC Cpf Cgc, PF_PJ Pf Pj,STATUS_CONTATO Status 
*!*					Contato, CADASTRAMENTO_CONTATO Cadastramento Contato, TIPO_CONTATO Tipo Contato, 
*!*					SUBTIPO_CONTATO Subtipo Contato, CATEGORIA_CONTATO Categoria Contato, 
*!*					SUBCATEGORIA_CONTATO Subcategoria Contato,DESC_TIPO_CONTATO Desc Tipo Contato, 
*!*					DESC_SUBTIPO_CONTATO Desc Subtipo Contato, DESC_CATEGORIA_CONTATO Desc Categoria 
*!*					Contato, DESC_SUBCATEGORIA_CONTATO Desc Subcategoria Contato, IM Im, IM_ENTREGA 
*!*					Im Entrega, IM_COBRANCA Im Cobranca,DESCONTO_BRUTO_1 Desconto Bruto 1, 
*!*					DESCONTO_BRUTO_2 Desconto Bruto 2, DESCONTO_BRUTO_3 Desconto Bruto 3, 
*!*					DESCONTO_BRUTO_4 Desconto Bruto 4, DESCONTO_SOBRE_1 Desconto Sobre 1, 
*!*					DESCONTO_SOBRE_2 Desconto Sobre 2, DESCONTO_SOBRE_3 Desconto Sobre 
*!*					3,DESCONTO_SOBRE_4 Desconto Sobre 4,MULTI_DESCONTO_ACUMULAR Multi Desconto 
*!*					Acumular, INSCRICAO_SUFRAMA Inscricao Suframa, INCL_AUTO_GRP_ECON Incl. 
*!*					Automativa Grupo Econômico,NUMERO NUMERO, COMPLEMENTO COMPLEMENTO, 
*!*					COBRANCA_NUMERO COBRANCA NUMERO, COBRANCA_COMPLEMENTO COBRANCA COMPLEMENTO, 
*!*					ENTREGA_NUMERO ENTREGA NUMERO, ENTREGA_COMPLEMENTO ENTREGA COMPLEMENTO,COD 
*!*					MUNICIPIO IBGE CADASTRO_CLI_FOR.COD_MUNICIPIO_IBGE, COD MUNICIPIO IBGE COBRANCA 
*!*					CADASTRO_CLI_FOR.COD_MUNICIPIO_IBGE_COBRANCA, COD MUNICIPIO IBGE ENTREGA 
*!*					CADASTRO_CLI_FOR.COD_MUNICIPIO_IBGE_ENTREGA,EMAIL NFE 
*!*					CADASTRO_CLI_FOR.EMAIL_NFE, CONTEUDO XPED NFE 
*!*					CLIENTES_ATACADO.CONTEUDO_XPED_NFE, TIPO TRIBUTACAO 
*!*					CADASTRO_CLI_FOR.TIPO_TRIBUTACAO, EBS_ID_CLIENTE ID ORACLE
*!*				ENDTEXT

*!*				***
*!*				*** DefaultsValuesList
*!*				***
*!*				TEXT TO  .CURSORV_CLIENTES_01.DefaultsValuesList NOSHOW TEXTMERGE PRETEXT 7
*!*					
*!*				ENDTEXT

*!*				***
*!*				*** FTableList
*!*				***
*!*				TEXT TO  .CURSORV_CLIENTES_01.FTableList NOSHOW TEXTMERGE PRETEXT 7
*!*					
*!*				ENDTEXT

*!*				***
*!*				*** Alias (NÃO PRECISA DESTA INSTRUÇÃO EM CURSORES JÁ CRIADOS)
*!*				***
*!*				***.CURSORV_CLIENTES_01.Alias = "v_clientes_01"

*!*				***
*!*				*** ParentCursor
*!*				***
*!*				 .CURSORV_CLIENTES_01.ParentCursor = ""
*!*				***
*!*				*** BufferModeOverride
*!*				***
*!*				.CURSORV_CLIENTES_01.BufferModeOverride	=3
*!*				***
*!*				*** NoDataOnLoad
*!*				***
*!*				.CURSORV_CLIENTES_01.NoDataOnLoad		=.T.
*!*				***
*!*				*** IsUpdateCursor
*!*				***
*!*				.CURSORV_CLIENTES_01.IsUpdateCursor		=.T.
*!*				***
*!*				*** IsMaster
*!*				***
*!*				.CURSORV_CLIENTES_01.IsMaster		        =.T.
*!*				***
*!*				*** UpdateType
*!*				***
*!*				.CURSORV_CLIENTES_01.UpdateType			=1
*!*				***
*!*				*** WhereType
*!*				***
*!*				.CURSORV_CLIENTES_01.WhereType			=1
*!*				***
*!*				*** FetchMemo
*!*				***
*!*				.CURSORV_CLIENTES_01.FetchMemo			=.T.
*!*				***
*!*				*** SendUpdates
*!*				***
*!*				.CURSORV_CLIENTES_01.SendUpdates		=.F.
*!*				***
*!*				*** UseMemoSize
*!*				***
*!*				.CURSORV_CLIENTES_01.UseMemoSize		=255
*!*				***
*!*				*** FetchSize
*!*				***
*!*				.CURSORV_CLIENTES_01.FetchSize			=-1
*!*				***
*!*				*** MaxRecords
*!*				***
*!*				.CURSORV_CLIENTES_01.MaxRecords			=-1
*!*				***
*!*				*** Prepared
*!*				***
*!*				.CURSORV_CLIENTES_01.Prepared			=.F.
*!*				***
*!*				*** CompareMemo
*!*				***
*!*				.CURSORV_CLIENTES_01.CompareMemo		=.F.
*!*				***
*!*				*** BatchUpdateCount
*!*				***
*!*				.CURSORV_CLIENTES_01.BatchUpdateCount	=1
*!*				***
*!*				*** OpenCursor()
*!*				***
				.CURSORV_CLIENTES_01.OpenCursor()
		EndIf

	ENDWITH

ENDFUNC && fim FUNCTION carrega_ca_v_clientes_01 
