**********************************************************
*        Ultimas alterações no Grupo Palma               *
**********************************************************
* Data :  27/05/2014 
* Autor:  Sandra Ono
*              a) Inclusão Automatica de Tabelas com preço  Default
*              b) Validar se campo dá mensagem de Campo Inativo
*              c) Alteração para corrigir erro da linx para não alterar o preço liquido dos produtos


***  03/08/2013: Paulo Devide 
*!*					** VALIDAÇÃO DA PROPRIEDADE DATA_ATIVACAO (00027)
*!*				llOk=zvalida_prop_data_ativacao() &&PAULO DEVIDE - 03-09-2013
***         Verifica se a Data informada na propriedade DATA_ATIVACAO é válida!"



* 24-05-2013: Paulo Devide
*!*					** PAULO DEVIDE -> 24-05-2013
*!*					llOk=zvalida_campos_produto()
** 1) valida campo Categoria "Campo [Categoria] é obrigatório..."
** 2) valida campo Subcategoria "Campo [Subcategoria] é obrigatório..."
** 3) valida tabela de preços preeenchida (campo Preco1)


*!*	* 20/05/2014: Sandra Ono   
*!*	* Validação se o Produto esta devidamente cadastrado na Tabela NCM  (obrigação para calculo de imposto nas lojas)


*1-Valida os campos 'ENDERECO/CEP/CIDADE/BAIRRO/PAIS/DDD1/TELEFONE1/CONTA_CONTABIL/' no cadastramento do fornecedor.
*Evita que o cadastro de fornecedor fique incompleto.
*	USR_INITarea
*	USR_ALTER_BEFORE  ->Return .f. Para o Metodo
*	USR_ALTER_AFTER
*	USR_INCLUDE_AFTER
*	USR_SEARCH_BEFORE ->Return .f. Para o Metodo
*	USR_SEARCH_AFTER
*	USR_CLEAN_AFTER
*	USR_REFRESH
*	USR_SAVE_BEFORE   ->Return .f. Para o Metodo
*	USR_SAVE_AFTER
*	USR_ITEN_DELETE_BEFORE ->Return .f. Para o Metodo
*	USR_ITEN_DELETE_AFTER
*	USR_ITEN_INCLUDE_BEFORE ->Return .f. Para o Metodo
*	USR_ITEN_INCLUDE_AFTER
*   USR_LOSTFOCUS
*	USR_CLICK
define class obj_entrada as custom
	*- Nome do metodo/função que os objetos linx vão chamar.
	procedure metodo_usuario

		lparam xmetodo, xobjeto ,xnome_obj
		**SET STEP ON

		****
		* Quando clica em incluir, a pagina do Código de Barras, fica Enabled = .F. (desabilitada)
		* Ao cancelar ou salvar, volta o status ao normal, ThisFormSet.p_Tool_Status diferente de 'I'
		* 
		* PAULO DEVIDE - 06/04/16
		*/		
		IF !(ThisFormSet.p_Tool_Status == 'I')
			**
			thisformset.lx_form1.lx_pageframe1.page3.Enabled=.T.
			**
		ENDIF
		
		TRY 
			IF !(ThisFormSet.p_Tool_Status == 'A')
				**o_002006.lx_FORM1.lx_PAGEFRAME1.pAGE1.pgDadosProdutos.pAGE2.lx_GRID_FILHA1.p_tool_grid.Visible=.T.
				ThisFormSet.lx_FORM1.lx_PAGEFRAME1.pAGE1.pgDadosProdutos.pAGE2.lx_GRID_FILHA1.p_tool_grid.Visible=.T.
				ThisFormSet.lx_FORM1.lx_PAGEFRAME1.pAGE1.pgDadosProdutos.pAGE2.lx_GRID_FILHA1.Enabled=.T.
				ThisFormSet.lx_FORM1.lx_PAGEFRAME1.pAGE1.pgDadosProdutos.pAGE2.lx_GRID_FILHA1.ReadOnly=.F.
				
			ENDIF
				
		CATCH TO oErro1
			IF oErro1.errorno<>1925
				MESSAGEBOX(oErro1.message,16,"Aviso")
			ENDIF

		ENDTRY

				

		do case
		
			case UPPER(xmetodo) == 'USR_SAVE_AFTER'
				*SET STEP ON
				IF USED("V_PRODUTOS_BARRA_APAGADOS")
					SELECT V_PRODUTOS_BARRA_APAGADOS 
					IF RECCOUNT()>0
						SELECT V_PRODUTOS_BARRA_APAGADOS 
						SCAN 						
							TEXT TO lcSQL NOSHOW TEXTMERGE PRETEXT 7
							INSERT INTO PRODUTOS_BARRA_APAGADOS  (CODIGO_BARRA,PRODUTO,COR_PRODUTO,TAMANHO,GRADE,DATA_OCORRENCIA,USUARIO)
							VALUES 
							 ('<<ALLTRIM(V_PRODUTOS_BARRA_APAGADOS.CODIGO_BARRA)>>',
							 '<<ALLTRIM(V_PRODUTOS_BARRA_APAGADOS.PRODUTO)>>',
							 '<<ALLTRIM(V_PRODUTOS_BARRA_APAGADOS.COR_PRODUTO)>>',
							 <<V_PRODUTOS_BARRA_APAGADOS.TAMANHO>>,
							 '<<ALLTRIM(V_PRODUTOS_BARRA_APAGADOS.GRADE)>>',
							 GETDATE(),
							 '<<ALLTRIM(V_PRODUTOS_BARRA_APAGADOS.USUARIO))>>')							
							ENDTEXT
							*MESSAGEBOX(lcSQL)
							F_EXECUTE(lcSQL)
							SELECT V_PRODUTOS_BARRA_APAGADOS 
						ENDSCAN
					ENDIF
				ENDIF
				
				TEXT TO cmdsql NOSHOW TEXTMERGE
					SELECT MAX(UNOUS_NIVEL) AS UNOUS_NIVEL
					FROM CAE_PRODUTOS_FATOR_P CP
					INNER JOIN PRODUTOS P
						ON P.GRIFFE = CP.GRIFFE 
						AND P.LINHA = CP.LINHA 
						AND P.GRUPO_PRODUTO = CP.GRUPO_PRODUTO
						AND P.SUBGRUPO_PRODUTO = CP.SUBGRUPO_PRODUTO
					WHERE P.PRODUTO = ?V_PRODUTOS_00.PRODUTO
				ENDTEXT

				f_select(cmdsql,"vUNOUS_NIVEL")
				IF UPPER(ALLTRIM(NVL(vUNOUS_NIVEL.UNOUS_NIVEL,"")))="FATOR_P"

					lcValorProp = "N/A"

					IF BETWEEN(V_PRODUTOS_00.FATOR_P,1,2)
						lcValorProp = "P1/P2"
					ENDIF

					IF BETWEEN(V_PRODUTOS_00.FATOR_P,3,4)
						lcValorProp = "P3/P4"
					ENDIF

					lcSQL = "UPDATE PROP_PRODUTOS SET VALOR_PROPRIEDADE =?lcValorProp WHERE PRODUTO = "+;
					"?V_PRODUTOS_00.PRODUTO AND PROPRIEDADE = '00107'"
					f_update(lcSQL)
					
				ENDIF
				
				
				******
				*// A validação abaixo é para a propriedade CGP_UNOUS_ALOCAR 
				*// para produtos nacionais, o DEFAULT é sim, para os importados NÂO
				*
				if inlist(cast(nvl(V_PRODUTOS_00.tribut_origem,"") as int), 1,2,6,7) 
					** 00108 V_PRODUTOS_00.PRODUTO --> atualiza propriedade para não (produto importado)
					IF ThisFormSet.p_Tool_Status = "I"
						lcSQL = "UPDATE PROP_PRODUTOS SET VALOR_PROPRIEDADE ='NÃO' WHERE PRODUTO = "+;
							"?V_PRODUTOS_00.PRODUTO AND PROPRIEDADE = '00108'"
						f_update(lcSQL)
					ENDIF
				ELSE && se for NACIONAL - O default é SIM
					IF ThisFormSet.p_Tool_Status = "I"
						lcSQL = "UPDATE PROP_PRODUTOS SET VALOR_PROPRIEDADE ='SIM' WHERE PRODUTO = "+;
							"?V_PRODUTOS_00.PRODUTO AND PROPRIEDADE = '00108'"
						f_update(lcSQL)
					ENDIF
				endif

					
			case UPPER(xmetodo) == 'USR_REFRESH'
					IF ThisFormSet.p_Tool_Status = "P" && modo pesquisa com dados na tela
						IF NOT thisformset.pp_palma_libera_bloq_produto
						
							TEXT TO lcSQL NOSHOW TEXTMERGE
								select pedido from COMPRAS_PRODUTO where produto = '<<ALLTRIM(V_PRODUTOS_00.PRODUTO)>>' and QTDE_ORIGINAL <> QTDE_ENTREGAR
							ENDTEXT
							F_SELECT(lcSQL,"tmpPedido01")

							IF RECCOUNT("tmpPedido01")>0 && existe pedido para este produto, não pode alterar as cores

								
								IF thisformset.pp_palma_bloq_botao_barcode=.T.
								
									WITH thisformset.lx_FORM1.lx_PAGEFRAME1.PAGE3 && Codigo de Barras
									
										llEnabled_Option = .opt_padrao.enabled
										llEnabled_spn_tam_pos = .spn_tam_pos.enabled
										llEnabled_botao1 = .botao1.enabled
										llEnabled_command1 = .command1.enabled
										llEnabled_ck_usa_cor = .ck_usa_cor.enabled
										llEnabled_ck_usa_tam = .ck_usa_tam.enabled
										
										.opt_padrao.enabled = .f.
										.spn_tam_pos.enabled = .f. 
										.botao1.enabled = .f.
										.command1.visible = .f.
										.ck_usa_cor.enabled = .f.
										.ck_usa_tam.enabled = .f.
										thisformset.lx_FORM1.lx_pageframe1.page3.lX_GRID_FILHA1.p_tool_grid.Visible = .f.
										thisformset.lx_FORM1.lx_pageframe1.page3.lX_GRID_FILHA1.Enabled = .f.
																		
									ENDWITH
														
							ELSE
								WITH thisformset.lx_FORM1.lx_PAGEFRAME1.PAGE3 && Codigo de Barras
								
									llEnabled_Option = .opt_padrao.enabled
									llEnabled_spn_tam_pos = .spn_tam_pos.enabled
									llEnabled_botao1 = .botao1.enabled
									llEnabled_command1 = .command1.enabled
									llEnabled_ck_usa_cor = .ck_usa_cor.enabled
									llEnabled_ck_usa_tam = .ck_usa_tam.enabled
									
									.opt_padrao.enabled = .t.
									.spn_tam_pos.enabled = .t. 
									.botao1.enabled = .t.
									.command1.visible = .t.
									.ck_usa_cor.enabled = .t.
									.ck_usa_tam.enabled = .t.

									thisformset.lx_FORM1.lx_pageframe1.page3.lX_GRID_FILHA1.p_tool_grid.Visible = .T.
									thisformset.lx_FORM1.lx_pageframe1.page3.lX_GRID_FILHA1.Enabled = .T.
																	
								ENDWITH

							ENDIF
							
						ENDIF && NOT thisformset.pp_palma_libera_bloq_produto --> paulo devide - 08-jun-2016
						
						
					ELSE
*!*							thisformset.lx_FORM1.lx_PAGEFRAME1.pAGE1.pgDadosProdutos.pAGE2.lx_GRID_FILHA1.ReadOnly=.f.
*!*							thisformset.lx_FORM1.lx_PAGEFRAME1.pAGE1.pgDadosProdutos.pAGE2.lx_GRID_FILHA1.p_tool_grid.Visible=.t.
*!*							thisformset.lx_FORM1.lx_PAGEFRAME1.pAGE1.pgDadosProdutos.pAGE2.lx_GRID_FILHA1.enabled = .t.
*!*							o_toolbar.Botao_filhas_inserir.Enabled= .T.
*!*							o_toolbar.botao_filhas_deletar.Enabled= .T.

					ENDIF
						
					
				ENDIF
				
				IF ThisFormSet.p_Tool_Status = "L"	
					WITH thisformset.lx_FORM1.lx_PAGEFRAME1.PAGE3 && Codigo de Barras
					
						llEnabled_Option = .opt_padrao.enabled
						llEnabled_spn_tam_pos = .spn_tam_pos.enabled
						llEnabled_botao1 = .botao1.enabled
						llEnabled_command1 = .command1.enabled
						llEnabled_ck_usa_cor = .ck_usa_cor.enabled
						llEnabled_ck_usa_tam = .ck_usa_tam.enabled
						
						.opt_padrao.enabled = .t.
						.spn_tam_pos.enabled = .t. 
						.botao1.enabled = .t.
						.command1.visible = .t.
						.ck_usa_cor.enabled = .t.
						.ck_usa_tam.enabled = .t.

														
					ENDWITH
				ENDIF
				
			case UPPER(xmetodo) == 'USR_INIT'
				****
				* Biblioteca com objetos da aba Importados 
				* PAULO DEVIDE - MAIO/18
				*\
				IF "CUPS01" $ SET( "ClassLib" )
					** Ok, Registry carregado
				ELSE
					SET CLASSLIB TO CUPS01.vcx ADDITIVE
				ENDIF
				**********************************\
				oCursor = GETCURSORADAPTER("V_PRODUTOS_00")
				** Instruções:
				**oCursor.AddBufferField("tabela.nome_da_coluna", "Tipo",  <atualizavel>, "caption", "tabela.nome_coluna")
				**
				oCursor.AddBufferField("PRODUTOS.ERP_CUPS_SEGMENTO","C(6)",.T.,"ERP_CUPS_SEGMENTO","PRODUTOS.ERP_CUPS_SEGMENTO")
				oCursor.AddBufferField("PRODUTOS.ERP_CUPS_STYLENUMBER","C(15)",.T.,"ERP_CUPS_STYLENUMBER","PRODUTOS.ERP_CUPS_STYLENUMBER")
				oCursor.AddBufferField("PRODUTOS.ERP_CUPS_EVENTO","C(6)",.T.,"ERP_CUPS_EVENTO","PRODUTOS.ERP_CUPS_EVENTO")
				oCursor.AddBufferField("PRODUTOS.ERP_CUPS_TEMA","C(6)",.T.,"ERP_CUPS_TEMA","PRODUTOS.ERP_CUPS_TEMA")
				oCursor.AddBufferField("PRODUTOS.ERP_CUPS_COMPRIMENTO","C(6)",.T.,"ERP_CUPS_COMPRIMENTO","PRODUTOS.ERP_CUPS_COMPRIMENTO")
				oCursor.AddBufferField("PRODUTOS.ERP_CUPS_CONTRUCAO","C(6)",.T.,"ERP_CUPS_CONTRUCAO","PRODUTOS.ERP_CUPS_CONTRUCAO")
				oCursor.AddBufferField("PRODUTOS.ERP_CUPS_COMPOSICAO","C(6)",.T.,"ERP_CUPS_COMPOSICAO","PRODUTOS.ERP_CUPS_COMPOSICAO")
				oCursor.AddBufferField("PRODUTOS.ERP_CUPS_FORRO","C(6)",.T.,"ERP_CUPS_FORRO","PRODUTOS.ERP_CUPS_FORRO")
				oCursor.AddBufferField("PRODUTOS.ERP_CUPS_PRODUTO","C(6)",.T.,"ERP_CUPS_PRODUTO","PRODUTOS.ERP_CUPS_PRODUTO")
				oCursor.AddBufferField("PRODUTOS.ERP_CUPS_SUPPLIER","C(6)",.T.,"ERP_CUPS_SUPPLIER","PRODUTOS.ERP_CUPS_SUPPLIER")
				oCursor.AddBufferField("PRODUTOS.ERP_CUPS_PRECO_CUSTO_ESTIMADO","N(12,2)",.T.,"ERP_CUPS_PRECO_CUSTO_ESTIMADO","PRODUTOS.ERP_CUPS_PRECO_CUSTO_ESTIMADO")
				oCursor.AddBufferField("PRODUTOS.ERP_CUPS_CODEBAR_REF","C(15)",.T.,"ERP_CUPS_CODEBAR_REF","PRODUTOS.ERP_CUPS_CODEBAR_REF")
				oCursor.AddBufferField("PRODUTOS.ERP_CUPS_CODEBAR_PB","C(15)",.T.,"ERP_CUPS_CODEBAR_PB","PRODUTOS.ERP_CUPS_CODEBAR_PB")
				oCursor.AddBufferField("PRODUTOS.ERP_CUPS_CODEBAR_CX","C(15)",.T.,"ERP_CUPS_CODEBAR_CX","PRODUTOS.ERP_CUPS_CODEBAR_CX")
				oCursor.AddBufferField("PRODUTOS.ERP_CUPS_CONJUNTO","L",.T.,"ERP_CUPS_CONJUNTO","PRODUTOS.ERP_CUPS_CONJUNTO")
				oCursor.AddBufferField("PRODUTOS.ERP_CUPS_COMPRIMENTO_BOTTOM","C(6)",.T.,"ERP_CUPS_COMPRIMENTO_BOTTOM","PRODUTOS.ERP_CUPS_COMPRIMENTO_BOTTOM")
				oCursor.AddBufferField("PRODUTOS.ERP_CUPS_COMPOSICAO_BOTTOM","C(6)",.T.,"ERP_CUPS_COMPOSICAO_BOTTOM","PRODUTOS.ERP_CUPS_COMPOSICAO_BOTTOM")
				oCursor.AddBufferField("PRODUTOS.ERP_CUPS_FORRO_BOTTOM","C(6)",.T.,"ERP_CUPS_FORRO_BOTTOM","PRODUTOS.ERP_CUPS_FORRO_BOTTOM")
				oCursor.AddBufferField("PRODUTOS.ERP_CUPS_SUBGRUPO_ATACADO","C(6)",.T.,"ERP_CUPS_SUBGRUPO_ATACADO","PRODUTOS.ERP_CUPS_SUBGRUPO_ATACADO")
				oCursor.AddBufferField("PRODUTOS.ERP_AREA_JEANS","L",.T.,"ERP_AREA_JEANS","PRODUTOS.ERP_AREA_JEANS")
				oCursor.AddBufferField("PRODUTOS.ERP_QTD_PACK","I",.T.,"ERP_QTD_PACK","PRODUTOS.ERP_QTD_PACK")
				oCursor.AddBufferField("PRODUTOS.ERP_LICENCIADO","L",.T.,"ERP_LICENCIADO","PRODUTOS.ERP_LICENCIADO")
				oCursor.AddBufferField("PRODUTOS.ERP_DESC_LICENCIADO","C(50)",.T.,"ERP_DESC_LICENCIADO","PRODUTOS.ERP_DESC_LICENCIADO")
				oCursor.AddBufferField("PRODUTOS.ERP_TEMA_LICENCIADO","C(50)",.T.,"ERP_TEMA_LICENCIADO","PRODUTOS.ERP_TEMA_LICENCIADO")
				oCursor.AddBufferField("PRODUTOS.ID_MODELAGEM","I",.T.,"ID_MODELAGEM","PRODUTOS.ID_MODELAGEM")
				oCursor.AddBufferField("PRODUTOS.ID_MODELAGEM2","I",.T.,"ID_MODELAGEM2","PRODUTOS.ID_MODELAGEM2")
				oCursor.AddBufferField("PRODUTOS.ERP_GRUPO_MERCADORIA","C(50)",.T.,"ERP_GRUPO_MERCADORIA","PRODUTOS.ERP_GRUPO_MERCADORIA")
				oCursor.AddBufferField("PRODUTOS.ERP_TIPO_ETIQUETA","C(6)",.T.,"ERP_TIPO_ETIQUETA","PRODUTOS.ERP_TIPO_ETIQUETA")
				oCursor.AddBufferField("PRODUTOS.ERP_DATA_ULTIMO_AGENDAMENTO","D",.T.,"ERP_DATA_ULTIMO_AGENDAMENTO","PRODUTOS.ERP_DATA_ULTIMO_AGENDAMENTO")
				oCursor.AddBufferField("PRODUTOS.ERP_MATERIA_PRIMA","C(6)",.T.,"ERP_MATERIA_PRIMA","PRODUTOS.ERP_MATERIA_PRIMA")
				** CAMPOS DA FICHA TECNICA
				oCursor.AddBufferField("PRODUTOS.ERP_FT_MARCA","C(6)",.T.,"ERP_FT_MARCA","PRODUTOS.ERP_FT_MARCA")
				oCursor.AddBufferField("PRODUTOS.ERP_FT_DESC_MARCA","C(70)",.T.,"ERP_FT_DESC_MARCA","PRODUTOS.ERP_FT_DESC_MARCA")
				oCursor.AddBufferField("PRODUTOS.ERP_FT_REPEAT","C(6)",.T.,"ERP_FT_REPEAT","PRODUTOS.ERP_FT_REPEAT")
				oCursor.AddBufferField("PRODUTOS.ERP_FT_DESC_REPEAT","C(70)",.T.,"ERP_FT_DESC_REPEAT","PRODUTOS.ERP_FT_DESC_REPEAT")
				oCursor.AddBufferField("PRODUTOS.ERP_FT_ESTRUTURA","C(6)",.T.,"ERP_FT_ESTRUTURA","PRODUTOS.ERP_FT_ESTRUTURA")
				oCursor.AddBufferField("PRODUTOS.ERP_FT_DESC_ESTRUTURA","C(70)",.T.,"ERP_FT_DESC_ESTRUTURA","PRODUTOS.ERP_FT_DESC_ESTRUTURA")
				oCursor.AddBufferField("PRODUTOS.ERP_FT_MATERIA_PRIMA","C(6)",.T.,"ERP_FT_MATERIA_PRIMA","PRODUTOS.ERP_FT_MATERIA_PRIMA")
				oCursor.AddBufferField("PRODUTOS.ERP_FT_DESC_MATERIA_PRIMA","C(70)",.T.,"ERP_FT_DESC_MATERIA_PRIMA","PRODUTOS.ERP_FT_DESC_MATERIA_PRIMA")
				oCursor.AddBufferField("PRODUTOS.ERP_FT_COMPOSICAO","C(6)",.T.,"ERP_FT_COMPOSICAO","PRODUTOS.ERP_FT_COMPOSICAO")
				oCursor.AddBufferField("PRODUTOS.ERP_FT_DESC_COMPOSICAO","C(70)",.T.,"ERP_FT_DESC_COMPOSICAO","PRODUTOS.ERP_FT_DESC_COMPOSICAO")
				oCursor.AddBufferField("PRODUTOS.ERP_FT_CATEGORIA","C(6)",.T.,"ERP_FT_CATEGORIA","PRODUTOS.ERP_FT_CATEGORIA")
				oCursor.AddBufferField("PRODUTOS.ERP_FT_DESC_CATEGORIA","C(70)",.T.,"ERP_FT_DESC_CATEGORIA","PRODUTOS.ERP_FT_DESC_CATEGORIA")
				oCursor.AddBufferField("PRODUTOS.ERP_FT_FIT","C(6)",.T.,"ERP_FT_FIT","PRODUTOS.ERP_FT_FIT")
				oCursor.AddBufferField("PRODUTOS.ERP_FT_DESC_FIT","C(70)",.T.,"ERP_FT_DESC_FIT","PRODUTOS.ERP_FT_DESC_FIT")
				oCursor.AddBufferField("PRODUTOS.ERP_FT_ESPECIFICACOES","C(6)",.T.,"ERP_FT_ESPECIFICACOES","PRODUTOS.ERP_FT_ESPECIFICACOES")
				oCursor.AddBufferField("PRODUTOS.ERP_FT_DESC_ESPECIFICACOES","C(70)",.T.,"ERP_FT_DESC_ESPECIFICACOES","PRODUTOS.ERP_FT_DESC_ESPECIFICACOES")
				oCursor.AddBufferField("PRODUTOS.ERP_FT_CLASSIFICACAO","C(6)",.T.,"ERP_FT_CLASSIFICACAO","PRODUTOS.ERP_FT_CLASSIFICACAO")
				oCursor.AddBufferField("PRODUTOS.ERP_FT_DESC_CLASSIFICACAO","C(70)",.T.,"ERP_FT_DESC_CLASSIFICACAO","PRODUTOS.ERP_FT_DESC_CLASSIFICACAO")
				oCursor.AddBufferField("PRODUTOS.ERP_FT_DESENHO","C(6)",.T.,"ERP_FT_DESENHO","PRODUTOS.ERP_FT_DESENHO")
				oCursor.AddBufferField("PRODUTOS.ERP_FT_DESC_DESENHO","C(70)",.T.,"ERP_FT_DESC_DESENHO","PRODUTOS.ERP_FT_DESC_DESENHO")
				oCursor.AddBufferField("PRODUTOS.ERP_FT_FATOR_F","C(6)",.T.,"ERP_FT_FATOR_F","PRODUTOS.ERP_FT_FATOR_F")
				oCursor.AddBufferField("PRODUTOS.ERP_FT_DESC_FATOR_F","C(70)",.T.,"ERP_FT_DESC_FATOR_F","PRODUTOS.ERP_FT_DESC_FATOR_F")
				oCursor.AddBufferField("PRODUTOS.ERP_FT_RISCO","C(6)",.T.,"ERP_FT_RISCO","PRODUTOS.ERP_FT_RISCO")
				oCursor.AddBufferField("PRODUTOS.ERP_FT_DESC_RISCO","C(70)",.T.,"ERP_FT_DESC_RISCO","PRODUTOS.ERP_FT_DESC_RISCO")
				** Campos e-commerce
				oCursor.AddBufferField("PRODUTOS.ERP_ECOMM_DESC_SEO","C(44)",.T.,"ERP_ECOMM_DESC_SEO","PRODUTOS.ERP_ECOMM_DESC_SEO")
				oCursor.AddBufferField("PRODUTOS.ERP_ECOMM_DESC_ATRIBUTOS","C(150)",.T.,"ERP_ECOMM_DESC_ATRIBUTOS","PRODUTOS.ERP_ECOMM_DESC_ATRIBUTOS")
				oCursor.AddBufferField("PRODUTOS.ERP_ECOMM_DESC_MARCA","C(50)",.T.,"ERP_ECOMM_DESC_MARCA","PRODUTOS.ERP_ECOMM_DESC_MARCA")
				oCursor.AddBufferField("PRODUTOS.ERP_ECOMM_COD_MARCA","C(6)",.T.,"ERP_ECOMM_COD_MARCA","PRODUTOS.ERP_ECOMM_COD_MARCA")
				** Campos da aba pedidos
				oCursor.AddBufferField("PRODUTOS.REQUERIDO_POR","C(25)",.T.,"REQUERIDO_POR","PRODUTOS.REQUERIDO_POR")
				oCursor.AddBufferField("PRODUTOS.TIPO_COMPRA","C(25)",.T.,"TIPO_COMPRA","PRODUTOS.TIPO_COMPRA")
				oCursor.AddBufferField("PRODUTOS.ERP_CAB_OPCAO","I",.T.,"ERP_CAB_OPCAO","PRODUTOS.ERP_CAB_OPCAO")
				oCursor.AddBufferField("PRODUTOS.ERP_CAB_COD_CABIDE","C(15)",.T.,"ERP_CAB_COD_CABIDE","PRODUTOS.ERP_CAB_COD_CABIDE")
				** esqueleto (lista suspensa)				
				oCursor.AddBufferField("PRODUTOS.ERP_COD_ESQUELETO","C(6)",.T.,"ERP_COD_ESQUELETO","PRODUTOS.ERP_COD_ESQUELETO")
                **
				oCursor.confirmStructureChanges()
				
				** Correção após atualização Service Pack 1.23.030 - ordem alfabetica para composição
				select V_MATERIAIS_COMPOSICAO_00
				INDEX on desc_composicao TAG IXDESC

				*mudar o estilo do combo de categoria
				thisformset.lx_form1.lx_pageframe1.page1.PgDadosProdutos.Page1.cmb_Categoria_produto.Style= 2



				
				F_SELECT("SELECT * FROM PRODUTOS_BARRA_APAGADOS  WHERE 1=0","VTEMP09")
				=AFIELDS(arrTab,"VTEMP09")
				IF USED("V_PRODUTOS_BARRA_APAGADOS") 	
					USE IN V_PRODUTOS_BARRA_APAGADOS
				ENDIF
	
				CREATE CURSOR V_PRODUTOS_BARRA_APAGADOS ;
					FROM ARRAY arrTab
				
				RELEASE ZZ_COMBO_LICENCIADOR, ZZ_COMBO_PERSONAGEM, ZZ_COMBO_MODELAGEM, ZZ_COMBO_GRUPO_MERCADORIA
				PRIVATE ZZ_COMBO_LICENCIADOR, ZZ_COMBO_PERSONAGEM, ZZ_COMBO_MODELAGEM, ZZ_COMBO_GRUPO_MERCADORIA
				PRIVATE ZZ_COMBO_ESQUELETO
				STORE "" TO ZZ_COMBO_LICENCIADOR, ZZ_COMBO_PERSONAGEM, ZZ_COMBO_MODELAGEM, ZZ_COMBO_GRUPO_MERCADORIA, ZZ_COMBO_ESQUELETO
				
				lcSQL = "select PARAMETRO, NOTA_PROGRAMADOR from parametros "
				lcSQL = lcSQL + "where parametro in ('ROWSOURCE_LICENCIADOR','ROWSOURCE_PERSONAGEM',"+;
								"'ROWSOURCE_MODELAGEM','ROWSOURCE_GRUPOMERCADORIA')"
				f_select(lcSQL, "v_param_combo01")
				
				SELECT v_param_combo01
				LOCATE FOR ALLTRIM(parametro) = 'ROWSOURCE_LICENCIADOR'
				ZZ_COMBO_LICENCIADOR = ALLTRIM(v_param_combo01.NOTA_PROGRAMADOR)

				LOCATE FOR ALLTRIM(parametro) = 'ROWSOURCE_PERSONAGEM'
				ZZ_COMBO_PERSONAGEM = ALLTRIM(v_param_combo01.NOTA_PROGRAMADOR)
				**ZZ_COMBO_PERSONAGEM = [F_SELECT("SELECT DESC_PERSONAGEM FROM CAEDU_PERSONAGEM WHERE DESC_LIC = ?V_PRODUTOS_00.Erp_desc_licenciado","V_CBOPRS01")] &&thisformset.pp_rowsource_personagem

				LOCATE FOR ALLTRIM(parametro) = 'ROWSOURCE_MODELAGEM'
				ZZ_COMBO_MODELAGEM = ALLTRIM(v_param_combo01.NOTA_PROGRAMADOR)

				LOCATE FOR ALLTRIM(parametro) = 'ROWSOURCE_GRUPOMERCADORIA'
				ZZ_COMBO_GRUPO_MERCADORIA = ALLTRIM(v_param_combo01.NOTA_PROGRAMADOR)
				
				
				ZZ_COMBO_ESQUELETO = [F_SELECT("SELECT DESCRICAO,CODIGO FROM CAEDU_LISTA_COMBO WHERE ID_DOMINIO = '026' ORDER BY DESCRICAO ASC","V_CBOESQUELETO")] && COMBO ESQUELETO
				*MESSAGEBOX(zz_combo_modelagem)
				
				**selector de paginas do pageframe

				thisformset.lx_form1.addobject("lblNavPages1", "Label")
				thisformset.lx_form1.lblNavPages1.visible=.t.
				thisformset.lx_form1.lblNavPages1.top=26
				thisformset.lx_form1.lblNavPages1.left=620
				thisformset.lx_form1.lblNavPages1.Autosize=.t.
				thisformset.lx_form1.lblNavPages1.Caption="Seleção"
				thisformset.lx_form1.lblNavPages1.BackStyle=0
					

				thisformset.lx_form1.addobject("cboNavPages","cboNavPages")
				thisformset.lx_form1.cboNavPages.Visible=.t.
*!*					thisformset.lx_form1.cboNavPages.width=38
*!*					thisformset.lx_form1.cboNavPages.top=26
*!*					thisformset.lx_form1.cboNavPages.left = 617
				
				

				
				** 20-jun-16 - checkbox area jeans
				thisformset.lx_FORM1.lx_pageframe1.page1.pgDadosProdutos.page1.addobject('chk_area_jeans1', 'chk_area_jeans')
				thisformset.lx_FORM1.lx_pageframe1.page1.pgDadosProdutos.page1.chk_area_jeans1.visible=.t.
				***
				* PROJETO CUPS - PAULO DEVIDE 01/ABR/15
				* (INICIO)
				*/
				thisformset.lx_form1.minbutton=.t.
				thisformset.lx_form1.maxbutton=.f.
				
*!*					Thisformset.lx_FORM1.lx_PAGEFRAME1.page1.pgDadosProdutos.Page1.ck_TIPO_PP.caption = "Área JEANS"
*!*					Thisformset.lx_FORM1.lx_PAGEFRAME1.page1.pgDadosProdutos.Page1.ck_TIPO_PP.FontBold = .t.


				** #caedu# - criar os botões de navegação do pageframe
				thisformset.lx_form1.lxCntButton.Cnt.AddObject("btopage13","btopage13")
				thisformset.lx_form1.lxCntButton.Cnt.btopage13.visible=.f.
				
				thisformset.lx_form1.lxCntButton.Cnt.AddObject("btopage14","btopage14")
				thisformset.lx_form1.lxCntButton.Cnt.btopage14.visible=.f.
				
				thisformset.lx_form1.lxCntButton.Cnt.AddObject("btopage15","btopage15")
				thisformset.lx_form1.lxCntButton.Cnt.btopage15.visible=.f.
				
				thisformset.lx_form1.lxCntButton.Cnt.AddObject("btopage16","btopage16")
				thisformset.lx_form1.lxCntButton.Cnt.btopage16.visible=.f.
				
				thisformset.lx_form1.lxCntButton.Cnt.AddObject("btopage17","btopage17")
				thisformset.lx_form1.lxCntButton.Cnt.btopage17.visible=.f.
				** #caedu# - FIM criar os botões de navegação do pageframe
				
				lcLastPage = "pgImportado"
				thisformset.lx_form1.lx_pageframe1.addobject(lcLastPage,"cPageImportado")
				WITH thisformset.lx_form1.lx_pageframe1.pgImportado
					.enabled=.t.
					.caption = "Importado"
					lnPgOrder = .pageorder
				ENDWITH
				
				
				Thisformset.lx_form1.lx_pageframe1.pgImportado.addobject('lblTitulo', 'label')
				Thisformset.lx_form1.lx_pageframe1.pgImportado.lblTitulo.Caption = "Importado"
				Thisformset.lx_form1.lx_pageframe1.pgImportado.lblTitulo.Top = 4
				Thisformset.lx_form1.lx_pageframe1.pgImportado.lblTitulo.Left = 550
				Thisformset.lx_form1.lx_pageframe1.pgImportado.lblTitulo.Fontname = "Courier New"
				Thisformset.lx_form1.lx_pageframe1.pgImportado.lblTitulo.FontSize = 16
				Thisformset.lx_form1.lx_pageframe1.pgImportado.lblTitulo.Fontbold = .t.
				Thisformset.lx_form1.lx_pageframe1.pgImportado.lblTitulo.Forecolor = RGB(0,0,255)				
				Thisformset.lx_form1.lx_pageframe1.pgImportado.lblTitulo.Autosize = .t.
				Thisformset.lx_form1.lx_pageframe1.pgImportado.lblTitulo.Visible = .t.		
				
						
				lnqtdpags = thisformset.lx_form1.lx_pageframe1.pagecount 
				
				thisformset.lx_form1.lx_pageframe1.activepage = lnPgOrder

				lnHeightForm = thisformset.lx_form1.Height
				thisformset.lx_form1.Height = lnHeightForm + 35
*!*					thisformset.lx_form1.lx_pageframe1.top = thisformset.lx_form1.lx_pageframe1.top + 30
				thisformset.lx_FORM1.lx_pageframe1.Height = thisformset.lx_FORM1.lx_pageframe1.Height + 40
				lnAlturaPanel = ThisFormset.Lx_form1.Lx_frame_3d1.height 
*!*					ThisFormset.Lx_form1.Lx_frame_3d1.height = lnAlturaPanel + 35
				
				IF "CUPS01" $ SET( "ClassLib" )
					** Ok, Registry carregado
				ELSE
					SET CLASSLIB TO CUPS01.vcx ADDITIVE
				ENDIF
				
				** CLASSE DE COMPONENTES - PAULO DEVIDE
				IF "CONTROLES" $ SET( "ClassLib" )
					** Ok, Registry carregado
				ELSE
					SET CLASSLIB TO CONTROLES.vcx ADDITIVE
				ENDIF
				
				**objCups = CREATEOBJECT("funcoes_cups")
				
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('lbl_evento', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('cbo_evento1', 'cbo_evento')
				WITH thisformset.lx_FORM1.lx_pageframe1.pgImportado.cbo_evento1
					.top = 20
					.left = 90
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_EVENTO"
					.visible = .t.
					.parent.lbl_evento.caption = "Evento"
					.parent.lbl_evento.top = 25
					.parent.lbl_evento.left = 10
					.parent.lbl_evento.visible = .t.
				ENDWITH

				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('lbl_tema', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('cbo_tema1', 'cbo_tema')
				WITH thisformset.lx_FORM1.lx_pageframe1.pgImportado.cbo_tema1
					.top = 50
					.left = 90
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_TEMA"
					.visible = .t.
					.parent.lbl_tema.caption = "Tema"
					.parent.lbl_tema.top = 55
					.parent.lbl_tema.left = 10
					.parent.lbl_tema.visible = .t.
				ENDWITH				

*!*					thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('lbl_umv', 'rotulo')
*!*					thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('txt_umv1', 'txt_umv')
*!*					WITH thisformset.lx_FORM1.lx_pageframe1.pgImportado.txt_umv1
*!*						.top = 80
*!*						.left = 90
*!*						.visible = .t.
*!*						.parent.lbl_umv.caption = "UMV"
*!*						.parent.lbl_umv.top = 85
*!*						.parent.lbl_umv.left = 10
*!*						.parent.lbl_umv.visible = .t.
*!*					ENDWITH				

				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('lbl_comprimento', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('cbo_comprimento1', 'cbo_comprimento')
				WITH thisformset.lx_FORM1.lx_pageframe1.pgImportado.cbo_comprimento1
					.top = 110 - 30
					.left = 90
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_COMPRIMENTO"
					.visible = .t.
					.parent.lbl_comprimento.caption = "Comprimento"
					.parent.lbl_comprimento.top = 115 - 30
					.parent.lbl_comprimento.left = 10
					.parent.lbl_comprimento.visible = .t.
				ENDWITH				

				****
				* TRATAMENTO PARA CONJUNTO BOTTOM
				* PAULO DEVIDE - 05-08-2015
				*/
				
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('chk_conjunto1', 'chk_conjunto')
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.chk_conjunto1.visible=.t.
				
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('cntBottom1', 'Container')
				WITH thisformset.lx_FORM1.lx_pageframe1.pgImportado.cntBottom1
					.top = 106
					.left = 305
					.height = 100
					.width = 290
					.backstyle = 0
					.visible = .t.
				ENDWITH
				
				***
				* CAMPO COMPRIMENTO BOTTOM
				*/
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.cntBottom1.addobject('lbl_comprimento_bottom', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.cntBottom1.addobject('cbo_comprimento_bottom1', 'cbo_comprimento')
				WITH thisformset.lx_FORM1.lx_pageframe1.pgImportado.cntBottom1.cbo_comprimento_bottom1
					.top = 6
					.left = 82
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_COMPRIMENTO_BOTTOM"
					.visible = .t.
					.parent.lbl_comprimento_bottom.caption = "Comprimento"
					.parent.lbl_comprimento_bottom.top = 6
					.parent.lbl_comprimento_bottom.left = 4
					.parent.lbl_comprimento_bottom.visible = .t.
				ENDWITH				

				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('lbl_construcao', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('cbo_construcao1', 'cbo_construcao')
				WITH thisformset.lx_FORM1.lx_pageframe1.pgImportado.cbo_construcao1
					.top = 140 -30
					.left = 90
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_CONTRUCAO"
					.visible = .t.
					.parent.lbl_construcao.caption = "Construção"
					.parent.lbl_construcao.top = 145 - 30 
					.parent.lbl_construcao.left = 10
					.parent.lbl_construcao.visible = .t.
				ENDWITH				

				***
				* CAMPO COMPOSIÇÃO BOTTOM
				*/
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.cntBottom1.addobject('lbl_composicao_bottom', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.cntBottom1.addobject('cbo_composicao_bottom1', 'cbo_composicao')
				WITH thisformset.lx_FORM1.lx_pageframe1.pgImportado.cntBottom1.cbo_composicao_bottom1
					.top = 36
					.left = 82
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_COMPOSICAO_BOTTOM"
					.visible = .t.
					.parent.lbl_composicao_bottom.caption = "Composição"
					.parent.lbl_composicao_bottom.top = 36
					.parent.lbl_composicao_bottom.left = 4
					.parent.lbl_composicao_bottom.visible = .t.
				ENDWITH				
				
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('lbl_composicao', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('cbo_composicao1', 'cbo_composicao')
				WITH thisformset.lx_FORM1.lx_pageframe1.pgImportado.cbo_composicao1
					.top = 170 -30
					.left = 90
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_COMPOSICAO"
					.visible = .t.
					.parent.lbl_composicao.caption = "Composição"
					.parent.lbl_composicao.top = 175 - 30
					.parent.lbl_composicao.left = 10
					.parent.lbl_composicao.visible = .t.
				ENDWITH				
				
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('lbl_forro', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('cbo_forro1', 'cbo_forro')
				WITH thisformset.lx_FORM1.lx_pageframe1.pgImportado.cbo_forro1
					.top = 200 -30
					.left = 90
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_FORRO"
					.visible = .t.
					.parent.lbl_forro.caption = "Forro"
					.parent.lbl_forro.top = 205 - 30
					.parent.lbl_forro.left = 10
					.parent.lbl_forro.visible = .t.
				ENDWITH				

				***
				* CAMPO FORRO BOTTOM
				*/
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.cntBottom1.addobject('lbl_forro_bottom', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.cntBottom1.addobject('cbo_forro_bottom1', 'cbo_forro')
				WITH thisformset.lx_FORM1.lx_pageframe1.pgImportado.cntBottom1.cbo_forro_bottom1
					.top = 66
					.left = 82
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_FORRO_BOTTOM"
					.visible = .t.
					.parent.lbl_forro_bottom.caption = "Forro"
					.parent.lbl_forro_bottom.top = 66
					.parent.lbl_forro_bottom.left = 4
					.parent.lbl_forro_bottom.visible = .t.
				ENDWITH				

				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('lbl_produto', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('cbo_produto1', 'cbo_produto')
				WITH thisformset.lx_FORM1.lx_pageframe1.pgImportado.cbo_produto1
					.top = 230 -30
					.left = 90
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_PRODUTO"
					.visible = .t.
					.parent.lbl_produto.caption = "Produto"
					.parent.lbl_produto.top = 235 - 30
					.parent.lbl_produto.left = 10
					.parent.lbl_produto.visible = .t.
				ENDWITH				

				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('lbl_supplier', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('lbl_subgrupo_atc', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('cbo_subgrupo_atc1', 'cbo_subgrupo_atc')
				WITH thisformset.lx_FORM1.lx_pageframe1.pgImportado.cbo_subgrupo_atc1
					.top = 260 
					.left = 90
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_SUBGRUPO_ATACADO"
					.visible = .t.
					.parent.lbl_subgrupo_atc.caption = "Subgrupo ATC."
					.parent.lbl_subgrupo_atc.top = 265
					.parent.lbl_subgrupo_atc.left = 10
					.parent.lbl_subgrupo_atc.visible = .t.
				ENDWITH					

				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('tv_supplier1', "fk_picklist")
				WITH thisformset.lx_FORM1.lx_pageframe1.pgImportado.tv_supplier1
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_SUPPLIER"
					*.Height = 21
					.Left = 90
					.Top = 230
					*.Width = 120
					.Name = "tv_Supplier"
					.descricao = "FORNECEDOR"
					.lista_campos = "FORNECEDOR,CLIFOR"
					.tabela_valida="FORNECEDORES"
					.ImgPesquisa.Stretch = 2
					.ImgPesquisa.picture = LOCFILE("lupa.gif","GIF","Localizar")
					
					.visible = .t.
					.parent.lbl_supplier.caption = "Supplier"
					.parent.lbl_supplier.top = 265 - 30
					.parent.lbl_supplier.left = 10
					.parent.lbl_supplier.visible = .t.
				ENDWITH	

				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('lbl_preco_custo_estimado1', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.addobject('txt_preco_custo_estimado1', 'txt_preco_custo_estimado')
				WITH thisformset.lx_FORM1.lx_pageframe1.pgImportado.txt_preco_custo_estimado1
					.top = 290 -30
					.left = 90
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_PRECO_CUSTO_ESTIMADO"
					.visible = .F.
					.parent.lbl_preco_custo_estimado1.caption = "Prç Custo Est"
					.parent.lbl_preco_custo_estimado1.top = 295 - 30
					.parent.lbl_preco_custo_estimado1.left = 10
					.parent.lbl_preco_custo_estimado1.visible = .F.
				ENDWITH					

				thisformset.lx_FORM1.lx_pageframe1.page1.pgDadosProdutos.page1.addobject('lbl_segmento', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.page1.pgDadosProdutos.page1.addobject('cbo_segmento1', 'cbo_segmento')
				WITH thisformset.lx_FORM1.lx_pageframe1.page1.pgDadosProdutos.page1.cbo_segmento1
					.top = 425
					.left = 103
					.width = 100
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_SEGMENTO"
					.visible = .t.
					.parent.lbl_segmento.caption = "Segmentação"
					.parent.lbl_segmento.top = 425
					.parent.lbl_segmento.left = 20
					.parent.lbl_segmento.visible = .t.
				ENDWITH				

*!*	#caedu# - este objeto foi desativado pela linx no service pack 01.23
*!*					thisformset.lx_FORM1.lx_pageframe1.page1.pgDadosProdutos.page1.Shape8.Height = ;
*!*						thisformset.lx_FORM1.lx_pageframe1.page1.pgDadosProdutos.page1.Shape8.Height + 25
					
				thisformset.lx_FORM1.lx_pageframe1.page1.pgDadosProdutos.page1.addobject('lbl_stylenumber', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.page1.pgDadosProdutos.page1.addobject('txt_stylenumber1', 'txt_stylenumber_edit')
				WITH thisformset.lx_FORM1.lx_pageframe1.page1.pgDadosProdutos.page1.txt_stylenumber1
					.top = 425
					.left = 300
					.controlsource = "V_PRODUTOS_00.ERP_CUPS_STYLENUMBER"
					.visible = .t.
					.parent.lbl_stylenumber.caption = "Style Number"
					.parent.lbl_stylenumber.top = 425
					.parent.lbl_stylenumber.left = 220
					.parent.lbl_stylenumber.visible = .t.
				ENDWITH				
				


				thisformset.lx_FORM1.lx_pageframe1.page1.pgDadosProdutos.page1.addobject('lbl_qtdPack', 'rotulo')
				thisformset.lx_FORM1.lx_pageframe1.page1.pgDadosProdutos.page1.addobject('spnQtdPack1', 'spnQtdPack')
				WITH thisformset.lx_FORM1.lx_pageframe1.page1.pgDadosProdutos.page1.spnQtdPack1
					.top = 425
					.left = 541
					.controlsource = "V_PRODUTOS_00.ERP_QTD_PACK"
					.enabled = .t.
					.readonly = .f.
					.visible = .t.
					.parent.lbl_qtdPack.caption = "Qtd. Pack"
					.parent.lbl_qtdPack.top = 425
					.parent.lbl_qtdPack.left = 484
					.parent.lbl_qtdPack.visible = .t.
				ENDWITH				
				
				thisformset.lx_form1.lx_pageframe1.page3.lx_grid_filha1.height = 271
*** COMENTADO EM 28-06-2023 				
*!*					WITH thisformset.lx_form1.lx_pageframe1.page3.cmd_ExportaCBar
*!*						.Top = 119
*!*						.Width = 125
*!*						.Height = 27
*!*						.left = 589-4
*!*					ENDWITH
				
				IF .f. &&desabilita códigos de barra do ATACADO VMULTI
					thisformset.lx_form1.lx_pageframe1.page3.addobject('shape1', 'shape')
					thisformset.lx_form1.lx_pageframe1.page3.addobject('label_atacado1', 'label')
					
					WITH thisformset.lx_form1.lx_pageframe1.page3.shape1
						.top = 08
						.style = 3
						.width = 160
						.height = 108
						.left = 555
						.visible = .t.
					ENDWITH
					thisformset.lx_form1.lx_pageframe1.page3.label_atacado1.top = 03
					thisformset.lx_form1.lx_pageframe1.page3.label_atacado1.left = 565
					thisformset.lx_form1.lx_pageframe1.page3.label_atacado1.caption = " Atacado " 
					thisformset.lx_form1.lx_pageframe1.page3.label_atacado1.autosize = .t.
					thisformset.lx_form1.lx_pageframe1.page3.label_atacado1.visible = .t.


					thisformset.lx_FORM1.lx_pageframe1.page3.addobject('lbl_codebar_ref', 'rotulo')
					thisformset.lx_FORM1.lx_pageframe1.page3.addobject('txt_codebar_ref1', 'txt_codebar_ref')
					WITH thisformset.lx_FORM1.lx_pageframe1.page3.txt_codebar_ref1
						.top = 28-9
						.left = 584
						.controlsource = "V_PRODUTOS_00.ERP_CUPS_CODEBAR_REF"
						.visible = .t.
						.parent.lbl_codebar_ref.caption = "Ref"
						.parent.lbl_codebar_ref.top = 31-9
						.parent.lbl_codebar_ref.left = 562
						.parent.lbl_codebar_ref.visible = .t.
					ENDWITH				
									
					thisformset.lx_FORM1.lx_pageframe1.page3.addobject('lbl_codebar_pb', 'rotulo')
					thisformset.lx_FORM1.lx_pageframe1.page3.addobject('txt_codebar_pb1', 'txt_codebar_pb')
					WITH thisformset.lx_FORM1.lx_pageframe1.page3.txt_codebar_pb1
						.top = 58-9
						.left = 584
						.controlsource = "V_PRODUTOS_00.ERP_CUPS_CODEBAR_PB"
						.visible = .t.
						.parent.lbl_codebar_pb.caption = "PB"
						.parent.lbl_codebar_pb.top = 61-9
						.parent.lbl_codebar_pb.left = 562
						.parent.lbl_codebar_pb.visible = .t.
					ENDWITH				

					thisformset.lx_FORM1.lx_pageframe1.page3.addobject('lbl_codebar_cx', 'rotulo')
					thisformset.lx_FORM1.lx_pageframe1.page3.addobject('txt_codebar_cx1', 'txt_codebar_cx')
					WITH thisformset.lx_FORM1.lx_pageframe1.page3.txt_codebar_cx1
						.top = 88-5
						.left = 584
						.controlsource = "V_PRODUTOS_00.ERP_CUPS_CODEBAR_CX"
						.visible = .t.
						.parent.lbl_codebar_cx.caption = "CX"
						.parent.lbl_codebar_cx.top = 91-9
						.parent.lbl_codebar_cx.left = 562
						.parent.lbl_codebar_cx.visible = .t.
					ENDWITH				
				ENDIF &&DESABILITA CODIGOS DE BARRA DO ATACADO VMULTI
				


				thisformset.lx_form1.lx_pageframe1.activepage = 1
				*\
				* PROJETO CUPS - PAULO DEVIDE 01/ABR/15
				* (FINAL)
				****				


				*thisformset.lx_form1.addobject('bt_copia', 'bt_estfilial')
				thisformset.lx_FORM1.lx_pageframe1.page5.addobject('bt_copia', 'bt_estfilial')
				thisformset.lx_FORM1.lx_pageframe1.page5.addobject('bt_copia2', 'btdefprice')  && Sandra Ono - 27/05/2014 
				
				****
				* Exporta cursor de codigo de barras para o Excel
				* Paulo Devide -> 11/05/2016
				* o_002006.lx_FORM1.lx_PAGEFRAME1.pAGE3
				*/				
						
				thisformset.lx_FORM1.lx_PAGEFRAME1.pAGE3.addobject('bt_report1', 'bt_report')
				WITH thisformset.lx_FORM1.lx_PAGEFRAME1.pAGE3.bt_report1
					.height = 27
					.fontname = 'Arial'
					.Caption = 'Relatório Excel'
					.Left = 453
					.Top = 2
					.Width = 95
					.Visible = .T.
					.Enabled = .T.
					.anchor = 0
					.p_manter_baixo = .f.
					.p_manter_cima = .f.
					.p_manter_direita = .f.
					.p_manter_esquerda = .f.
					.p_muda_size = .f.
				ENDWITH

				** Adiciona Page Pedido
				lnLastPage = Thisformset.lx_form1.lx_pageframe1.pagecount + 1
				lcLastPage = "pgPedido"
				Thisformset.lx_form1.lx_pageframe1.addobject(lcLastPage,"cPagePedido") 
				WITH Thisformset.lx_form1.lx_pageframe1.pgPedido
					.enabled=.t.
					lnPageIndex = .pageorder
				ENDWITH

				Thisformset.lx_form1.lx_pageframe1.pgPedido.addobject('lblTitulo', 'label')
				Thisformset.lx_form1.lx_pageframe1.pgPedido.lblTitulo.Caption = "Pedido"
				Thisformset.lx_form1.lx_pageframe1.pgPedido.lblTitulo.Top = 4
				Thisformset.lx_form1.lx_pageframe1.pgPedido.lblTitulo.left = 550
				Thisformset.lx_form1.lx_pageframe1.pgPedido.lblTitulo.Fontname = "Courier New"
				Thisformset.lx_form1.lx_pageframe1.pgPedido.lblTitulo.FontSize = 16
				Thisformset.lx_form1.lx_pageframe1.pgPedido.lblTitulo.Fontbold = .t.
				Thisformset.lx_form1.lx_pageframe1.pgPedido.lblTitulo.Forecolor = RGB(0,0,255)				
				Thisformset.lx_form1.lx_pageframe1.pgPedido.lblTitulo.Autosize = .t.
				Thisformset.lx_form1.lx_pageframe1.pgPedido.lblTitulo.Visible = .t.	

*!*					REQUERIDO_POR
*!*					TIPO_COMPRA
*!*					ERP_CAB_OPCAO
*!*					ERP_CAB_COD_CABIDE
				**zzz
				thisformset.lx_form1.lx_pageframe1.pgPedido.addobject("lbl_requerido_por","label")
				thisformset.lx_form1.lx_pageframe1.pgPedido.lbl_requerido_por.Caption = "Requerido Por"
				thisformset.lx_form1.lx_pageframe1.pgPedido.lbl_requerido_por.Autosize = .t.
				thisformset.lx_form1.lx_pageframe1.pgPedido.lbl_requerido_por.top = 30
				thisformset.lx_form1.lx_pageframe1.pgPedido.lbl_requerido_por.left = 20
				thisformset.lx_form1.lx_pageframe1.pgPedido.lbl_requerido_por.visible = .t.
				**
				thisformset.lx_form1.lx_pageframe1.pgPedido.addobject("lbl_tipo_compra","label")
				thisformset.lx_form1.lx_pageframe1.pgPedido.lbl_tipo_compra.Caption = "Tipo de Compra"
				thisformset.lx_form1.lx_pageframe1.pgPedido.lbl_tipo_compra.Autosize = .t.
				thisformset.lx_form1.lx_pageframe1.pgPedido.lbl_tipo_compra.top = 60
				thisformset.lx_form1.lx_pageframe1.pgPedido.lbl_tipo_compra.left = 20
				thisformset.lx_form1.lx_pageframe1.pgPedido.lbl_tipo_compra.visible = .t.
				**
				thisformset.lx_form1.lx_pageframe1.pgPedido.addobject("lbl_erp_cab_opcao","label")
				thisformset.lx_form1.lx_pageframe1.pgPedido.lbl_erp_cab_opcao.Caption = "Opção Cabide /Alarme"
				thisformset.lx_form1.lx_pageframe1.pgPedido.lbl_erp_cab_opcao.Autosize = .t.
				thisformset.lx_form1.lx_pageframe1.pgPedido.lbl_erp_cab_opcao.top = 90
				thisformset.lx_form1.lx_pageframe1.pgPedido.lbl_erp_cab_opcao.left = 20
				thisformset.lx_form1.lx_pageframe1.pgPedido.lbl_erp_cab_opcao.visible = .t.
				**
				thisformset.lx_form1.lx_pageframe1.pgPedido.addobject("lbl_erp_cab_cod_cabide","label")
				thisformset.lx_form1.lx_pageframe1.pgPedido.lbl_erp_cab_cod_cabide.Caption = "Código Cabide"
				thisformset.lx_form1.lx_pageframe1.pgPedido.lbl_erp_cab_cod_cabide.Autosize = .t.
				thisformset.lx_form1.lx_pageframe1.pgPedido.lbl_erp_cab_cod_cabide.top = 120
				thisformset.lx_form1.lx_pageframe1.pgPedido.lbl_erp_cab_cod_cabide.left = 20
				thisformset.lx_form1.lx_pageframe1.pgPedido.lbl_erp_cab_cod_cabide.visible = .t.
				**

				thisformset.lx_form1.lx_pageframe1.pgPedido.addobject("txtREQUERIDO_POR","txtREQUERIDO_POR")
				thisformset.lx_form1.lx_pageframe1.pgPedido.txtREQUERIDO_POR.Visible = .t.

				thisformset.lx_form1.lx_pageframe1.pgPedido.addobject("txtTIPO_COMPRA","txtTIPO_COMPRA")
				thisformset.lx_form1.lx_pageframe1.pgPedido.txtTIPO_COMPRA.Visible = .t.
				
				thisformset.lx_form1.lx_pageframe1.pgPedido.addobject("optCabilog","optCabilog")
				thisformset.lx_form1.lx_pageframe1.pgPedido.optCabilog.Visible = .t.

				thisformset.lx_form1.lx_pageframe1.pgPedido.addobject("txtERP_CAB_COD_CABIDE","txtERP_CAB_COD_CABIDE")
				thisformset.lx_form1.lx_pageframe1.pgPedido.txtERP_CAB_COD_CABIDE.Visible = .t.
				
				** Adiciona Page Outros
				lnLastPage = Thisformset.lx_form1.lx_pageframe1.pagecount + 1
				lcLastPage = "pgOutros"
				Thisformset.lx_form1.lx_pageframe1.addobject(lcLastPage,"cPageOutros") 
				WITH Thisformset.lx_form1.lx_pageframe1.pgOutros
					.enabled=.t.
					lnPageIndex = .pageorder
				ENDWITH
				
				Thisformset.lx_form1.lx_pageframe1.pgOutros.addobject('lblTitulo', 'label')
				Thisformset.lx_form1.lx_pageframe1.pgOutros.lblTitulo.Caption = "Outros"
				Thisformset.lx_form1.lx_pageframe1.pgOutros.lblTitulo.Top = 4
				Thisformset.lx_form1.lx_pageframe1.pgOutros.lblTitulo.left = 550
				Thisformset.lx_form1.lx_pageframe1.pgOutros.lblTitulo.Fontname = "Courier New"
				Thisformset.lx_form1.lx_pageframe1.pgOutros.lblTitulo.FontSize = 16
				Thisformset.lx_form1.lx_pageframe1.pgOutros.lblTitulo.Fontbold = .t.
				Thisformset.lx_form1.lx_pageframe1.pgOutros.lblTitulo.Forecolor = RGB(0,0,255)				
				Thisformset.lx_form1.lx_pageframe1.pgOutros.lblTitulo.Autosize = .t.
				Thisformset.lx_form1.lx_pageframe1.pgOutros.lblTitulo.Visible = .t.					

				Thisformset.lx_form1.lx_pageframe1.pgOutros.addobject('chk_licenciado1', 'chk_licenciado')
				Thisformset.lx_form1.lx_pageframe1.pgOutros.chk_licenciado1.visible=.t.

				Thisformset.lx_form1.lx_pageframe1.pgOutros.addobject('lblErp_desc_licenciado1', 'lblErp_desc_licenciado')
				Thisformset.lx_form1.lx_pageframe1.pgOutros.lblErp_desc_licenciado1.visible=.t.

				Thisformset.lx_form1.lx_pageframe1.pgOutros.addobject('lblErp_tema_licenciado1', 'lblErp_tema_licenciado')
				Thisformset.lx_form1.lx_pageframe1.pgOutros.lblErp_tema_licenciado1.visible=.t.

*!*					Thisformset.lx_form1.lx_pageframe1.pgOutros.addobject('txtErp_desc_licenciado1', 'txtErp_desc_licenciado')
*!*					Thisformset.lx_form1.lx_pageframe1.pgOutros.txtErp_desc_licenciado1.visible=.t.
				
				Thisformset.lx_form1.lx_pageframe1.pgOutros.addobject('cboLicenciador1', 'cboLicenciador')
				Thisformset.lx_form1.lx_pageframe1.pgOutros.cboLicenciador1.visible=.t.
				
*!*					
*!*					Thisformset.lx_form1.lx_pageframe1.pgOutros.addobject('txtErp_tema_licenciado1', 'txtErp_tema_licenciado')
*!*					Thisformset.lx_form1.lx_pageframe1.pgOutros.txtErp_tema_licenciado1.visible=.t.
				
				Thisformset.lx_form1.lx_pageframe1.pgOutros.addobject('cboPersonagem1', 'cboPersonagem')
				Thisformset.lx_form1.lx_pageframe1.pgOutros.cboPersonagem1.visible=.t.

				Thisformset.lx_form1.lx_pageframe1.pgOutros.addobject('lblModelagem1', 'lblModelagem')
				Thisformset.lx_form1.lx_pageframe1.pgOutros.lblModelagem1.caption = "Modelagem 1"
				Thisformset.lx_form1.lx_pageframe1.pgOutros.lblModelagem1.visible=.t.

				Thisformset.lx_form1.lx_pageframe1.pgOutros.addobject('cboModelagem1', 'cboModelagem')
				Thisformset.lx_form1.lx_pageframe1.pgOutros.cboModelagem1.visible=.t.

				Thisformset.lx_form1.lx_pageframe1.pgOutros.addobject('lblModelagem2', 'lblModelagem')
				Thisformset.lx_form1.lx_pageframe1.pgOutros.lblModelagem2.visible=.t.
				Thisformset.lx_form1.lx_pageframe1.pgOutros.lblModelagem2.Top = 135
				Thisformset.lx_form1.lx_pageframe1.pgOutros.lblModelagem2.caption = "Modelagem 2"
				
				Thisformset.lx_form1.lx_pageframe1.pgOutros.addobject('cboModelagem21', 'cboModelagem2')
				Thisformset.lx_form1.lx_pageframe1.pgOutros.cboModelagem21.visible=.t.

				Thisformset.lx_form1.lx_pageframe1.pgOutros.addobject('lblGrupo1', 'lblModelagem')
				Thisformset.lx_form1.lx_pageframe1.pgOutros.lblGrupo1.caption = "Grupo Mercadoria"
				Thisformset.lx_form1.lx_pageframe1.pgOutros.lblGrupo1.Top = 195
				Thisformset.lx_form1.lx_pageframe1.pgOutros.lblGrupo1.visible=.t.

				Thisformset.lx_form1.lx_pageframe1.pgOutros.addobject('cboGrupoMercadoria1', 'cboGrupoMercadoria')
				Thisformset.lx_form1.lx_pageframe1.pgOutros.cboGrupoMercadoria1.visible=.t.

				Thisformset.lx_form1.lx_pageframe1.pgOutros.addobject('lblTipoEtq1', 'lblModelagem')
				Thisformset.lx_form1.lx_pageframe1.pgOutros.lblTipoEtq1.caption = "Tipo Etiqueta"
				Thisformset.lx_form1.lx_pageframe1.pgOutros.lblTipoEtq1.Top = 225
				Thisformset.lx_form1.lx_pageframe1.pgOutros.lblTipoEtq1.visible=.t.

				Thisformset.lx_form1.lx_pageframe1.pgOutros.addobject('cboTipoetq1', 'cboTipoetq')
				Thisformset.lx_form1.lx_pageframe1.pgOutros.cboTipoetq1.visible=.t.

				Thisformset.lx_form1.lx_pageframe1.pgOutros.addobject('lblMatPrima', 'lblModelagem')
				Thisformset.lx_form1.lx_pageframe1.pgOutros.lblMatPrima.caption = "Matéria Prima"
				Thisformset.lx_form1.lx_pageframe1.pgOutros.lblMatPrima.Top = 255
				Thisformset.lx_form1.lx_pageframe1.pgOutros.lblMatPrima.visible=.t.

				Thisformset.lx_form1.lx_pageframe1.pgOutros.addobject('cboMateriaPrima', 'cboMateriaPrima')
				Thisformset.lx_form1.lx_pageframe1.pgOutros.cboMateriaPrima.visible=.t.				

				** Adiciona Page e-commerce
				lnLastPage = Thisformset.lx_form1.lx_pageframe1.pagecount + 1
				lcLastPage = "pgEcomm"
				Thisformset.lx_form1.lx_pageframe1.addobject(lcLastPage,"cpgEcomm") 
				WITH Thisformset.lx_form1.lx_pageframe1.pgEcomm
					.enabled=.t.
					lnPageIndex = .pageorder
				ENDWITH
				
				Thisformset.lx_form1.lx_pageframe1.pgEcomm.addobject('lblTitulo', 'label')
				Thisformset.lx_form1.lx_pageframe1.pgEcomm.lblTitulo.Caption = "E-commerce"
				Thisformset.lx_form1.lx_pageframe1.pgEcomm.lblTitulo.Top = 4
				Thisformset.lx_form1.lx_pageframe1.pgEcomm.lblTitulo.left = 540
				Thisformset.lx_form1.lx_pageframe1.pgEcomm.lblTitulo.Fontname = "Courier New"
				Thisformset.lx_form1.lx_pageframe1.pgEcomm.lblTitulo.FontSize = 16
				Thisformset.lx_form1.lx_pageframe1.pgEcomm.lblTitulo.Fontbold = .t.
				Thisformset.lx_form1.lx_pageframe1.pgEcomm.lblTitulo.Forecolor = RGB(0,0,255)				
				Thisformset.lx_form1.lx_pageframe1.pgEcomm.lblTitulo.Autosize = .t.
				Thisformset.lx_form1.lx_pageframe1.pgEcomm.lblTitulo.Visible = .t.	
								
				** Descrição SEO (44 caracteres)
				thisformset.lx_form1.lx_pageframe1.pgEcomm.addobject("lbl_ecomm_seo","label")
				thisformset.lx_form1.lx_pageframe1.pgEcomm.lbl_ecomm_seo.Caption = "Descrição SEO"
				thisformset.lx_form1.lx_pageframe1.pgEcomm.lbl_ecomm_seo.Autosize = .t.
				thisformset.lx_form1.lx_pageframe1.pgEcomm.lbl_ecomm_seo.top = 30
				thisformset.lx_form1.lx_pageframe1.pgEcomm.lbl_ecomm_seo.left = 10
				thisformset.lx_form1.lx_pageframe1.pgEcomm.lbl_ecomm_seo.visible = .t.
				
				thisformset.lx_form1.lx_pageframe1.pgEcomm.addobject("txtErp_ecomm_desc_seo","txtErp_ecomm_desc_seo")
				thisformset.lx_form1.lx_pageframe1.pgEcomm.txtErp_ecomm_desc_seo.Visible = .t.
				
				** Descrição Atributos de Produto (150 caracteres)
				thisformset.lx_form1.lx_pageframe1.pgEcomm.addobject("lbl_ecomm_atrib","label")
				thisformset.lx_form1.lx_pageframe1.pgEcomm.lbl_ecomm_atrib.Caption = "Descrição Atributos"
				thisformset.lx_form1.lx_pageframe1.pgEcomm.lbl_ecomm_atrib.Autosize = .t.
				thisformset.lx_form1.lx_pageframe1.pgEcomm.lbl_ecomm_atrib.top = 60
				thisformset.lx_form1.lx_pageframe1.pgEcomm.lbl_ecomm_atrib.left = 10
				thisformset.lx_form1.lx_pageframe1.pgEcomm.lbl_ecomm_atrib.visible = .t.

				thisformset.lx_form1.lx_pageframe1.pgEcomm.addobject("edt_ecomm_atributos","edt_ecomm_atributos")
				thisformset.lx_form1.lx_pageframe1.pgEcomm.edt_ecomm_atributos.top = 60
				thisformset.lx_form1.lx_pageframe1.pgEcomm.edt_ecomm_atributos.left = 150
				thisformset.lx_form1.lx_pageframe1.pgEcomm.edt_ecomm_atributos.height = 75
				thisformset.lx_form1.lx_pageframe1.pgEcomm.edt_ecomm_atributos.width = 200
				thisformset.lx_form1.lx_pageframe1.pgEcomm.edt_ecomm_atributos.Visible = .t.

				** Marca (Lista suspensa)
				thisformset.lx_form1.lx_pageframe1.pgEcomm.addobject("lbl_ecomm_marca","label")
				thisformset.lx_form1.lx_pageframe1.pgEcomm.lbl_ecomm_marca.Caption = "Marca"
				thisformset.lx_form1.lx_pageframe1.pgEcomm.lbl_ecomm_marca.Autosize = .t.
				thisformset.lx_form1.lx_pageframe1.pgEcomm.lbl_ecomm_marca.top = 30
				thisformset.lx_form1.lx_pageframe1.pgEcomm.lbl_ecomm_marca.left = 430
				thisformset.lx_form1.lx_pageframe1.pgEcomm.lbl_ecomm_marca.visible = .t.
				
				thisformset.lx_form1.lx_pageframe1.pgEcomm.addobject("tv_ecomm_marca","tv_ecomm_marca")
				thisformset.lx_form1.lx_pageframe1.pgEcomm.tv_ecomm_marca.Visible = .t.
				
				** Adiciona Page Ficha Tecnica
				lnLastPage = Thisformset.lx_form1.lx_pageframe1.pagecount + 1
				lcLastPage = "pgFichaTec"
				Thisformset.lx_form1.lx_pageframe1.addobject(lcLastPage,"cpgFichaTec") 
				WITH Thisformset.lx_form1.lx_pageframe1.pgFichaTec
					.enabled=.t.
					lnPageIndex = .pageorder
				ENDWITH
				*truta
				Thisformset.lx_form1.lx_pageframe1.pgFichaTec.addobject('lblTitulo', 'label')
				Thisformset.lx_form1.lx_pageframe1.pgFichaTec.lblTitulo.Caption = "Ficha Técnica"
				Thisformset.lx_form1.lx_pageframe1.pgFichaTec.lblTitulo.Top = 4
				Thisformset.lx_form1.lx_pageframe1.pgFichaTec.lblTitulo.left = 510
				Thisformset.lx_form1.lx_pageframe1.pgFichaTec.lblTitulo.Fontname = "Courier New"
				Thisformset.lx_form1.lx_pageframe1.pgFichaTec.lblTitulo.FontSize = 16
				Thisformset.lx_form1.lx_pageframe1.pgFichaTec.lblTitulo.Fontbold = .t.
				Thisformset.lx_form1.lx_pageframe1.pgFichaTec.lblTitulo.Forecolor = RGB(0,0,255)				
				Thisformset.lx_form1.lx_pageframe1.pgFichaTec.lblTitulo.Autosize = .t.
				Thisformset.lx_form1.lx_pageframe1.pgFichaTec.lblTitulo.Visible = .t.

				**
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.addobject("lbl_ft_marca","label")
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_marca.Caption = "Marca"
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_marca.Autosize = .t.
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_marca.top = 30
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_marca.left = 10
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_marca.visible = .t.
				**
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.addobject("tv_ft_marca","tv_ft_marca")
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.tv_ft_marca.Visible = .t.

				**
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.addobject("lbl_ft_repeat","label")
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_repeat.Caption = "Repeat"
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_repeat.Autosize = .t.
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_repeat.top = 60
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_repeat.left = 10
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_repeat.visible = .t.
				**
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.addobject("tv_ft_repeat","tv_ft_repeat")
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.tv_ft_repeat.Visible = .t.
				
				**
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.addobject("lbl_ft_estrutura","label")
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_estrutura.Caption = "Estrutura"
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_estrutura.Autosize = .t.
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_estrutura.top = 90
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_estrutura.left = 10
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_estrutura.visible = .t.
				**
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.addobject("tv_ft_estrutura","tv_ft_estrutura")
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.tv_ft_estrutura.Visible = .t.
				
				**
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.addobject("lbl_ft_materia_prima","label")
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_materia_prima.Caption = "Matéria Prima"
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_materia_prima.Autosize = .t.
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_materia_prima.top = 120
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_materia_prima.left = 10
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_materia_prima.visible = .t.
				**
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.addobject("tv_ft_materia_prima","tv_ft_materia_prima")
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.tv_ft_materia_prima.Visible = .t.
				
				**
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.addobject("lbl_ft_composicao","label")
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_composicao.Caption = "Composição"
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_composicao.Autosize = .t.
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_composicao.top = 150
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_composicao.left = 10
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_composicao.visible = .t.
				**
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.addobject("tv_ft_composicao","tv_ft_composicao")
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.tv_ft_composicao.Visible = .t.
				
				**
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.addobject("lbl_ft_categoria","label")
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_categoria.Caption = "Categoria"
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_categoria.Autosize = .t.
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_categoria.top = 180
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_categoria.left = 10
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_categoria.visible = .t.
				**
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.addobject("tv_ft_categoria","tv_ft_categoria")
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.tv_ft_categoria.Visible = .t.
				
				**
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.addobject("lbl_ft_fit","label")
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_fit.Caption = "FIT"
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_fit.Autosize = .t.
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_fit.top = 210
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_fit.left = 10
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_fit.visible = .t.
				**
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.addobject("tv_ft_fit","tv_ft_fit")
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.tv_ft_fit.Visible = .t.
				
				**
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.addobject("lbl_ft_especificacoes","label")
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_especificacoes.Caption = "Especificações"
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_especificacoes.Autosize = .t.
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_especificacoes.top = 240
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_especificacoes.left = 10
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_especificacoes.visible = .t.
				**
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.addobject("tv_ft_especificacoes","tv_ft_especificacoes")
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.tv_ft_especificacoes.Visible = .t.
				
				**
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.addobject("lbl_ft_classificacao","label")
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_classificacao.Caption = "Classificação"
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_classificacao.Autosize = .t.
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_classificacao.top = 270
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_classificacao.left = 10
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_classificacao.visible = .t.
				**
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.addobject("tv_ft_classificacao","tv_ft_classificacao")
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.tv_ft_classificacao.Visible = .t.
				
				**
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.addobject("lbl_ft_desenho","label")
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_desenho.Caption = "Desenho"
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_desenho.Autosize = .t.
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_desenho.top = 300
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_desenho.left = 10
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_desenho.visible = .t.
				**
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.addobject("tv_ft_desenho","tv_ft_desenho")
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.tv_ft_desenho.Visible = .t.
				
				**
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.addobject("lbl_ft_fator_f","label")
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_fator_f.Caption = "Fator F"
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_fator_f.Autosize = .t.
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_fator_f.top = 330
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_fator_f.left = 10
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_fator_f.visible = .t.
				**
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.addobject("tv_ft_fator_f","tv_ft_fator_f")
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.tv_ft_fator_f.Visible = .t.
				
				**
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.addobject("lbl_ft_risco","label")
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_risco.Caption = "Risco"
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_risco.Autosize = .t.
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_risco.top = 360
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_risco.left = 10
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.lbl_ft_risco.visible = .t.
				**
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.addobject("tv_ft_risco","tv_ft_risco")
				thisformset.lx_form1.lx_pageframe1.pgFichaTec.tv_ft_risco.Visible = .t.
				
				** ESQUELETO 
				thisformset.lx_FORM1.lx_pageframe1.page1.pgDadosProdutos.page1.addobject('lbl_esqueleto', 'lbl_esqueleto')
				thisformset.lx_FORM1.lx_pageframe1.page1.pgDadosProdutos.page1.addobject('cboEsqueleto', 'cboEsqueleto')
				WITH thisformset.lx_FORM1.lx_pageframe1.page1.pgDadosProdutos.page1.cboEsqueleto
					.top = 394
					.left = 88
					.width = 250
					.controlsource = "V_PRODUTOS_00.ERP_COD_ESQUELETO"
					.visible = .t.
					.parent.lbl_esqueleto.caption = "ESQUELETO"
					.parent.lbl_esqueleto.top = 394
					.parent.lbl_esqueleto.left = 10
					.parent.lbl_esqueleto.visible = .t.
				ENDWITH	
				
				****
				* PAGE6 (PACKS)
				* ADICIONA OBJETOS E REORGANIZA OS OBJETOS EXISTENTES
				*\
				
				WITH Thisformset.lx_form1.lx_pageframe1.page6.LX_GRID_FILHA1
					.top = 204
					.width = 716
					.rowHeight = 16
					.height = 252
				ENDWITH
				
				
				
				Thisformset.l_limpa()

	case UPPER(xmetodo) == 'USR_SEARCH_AFTER'
	
*!*		      
*!*			Text TO  thisformset.dataenvironment.Cursorv_produtos_tamanho_00.SelectCmd TextMerge NoShow
*!*			SELECT PRODUTOS_TAMANHOS.GRADE, PRODUTOS_TAMANHOS.NUMERO_QUEBRAS, PRODUTOS_TAMANHOS.NUMERO_TAMANHOS, PRODUTOS_TAMANHOS.TAMANHOS_DIGITADOS, PRODUTOS_TAMANHOS.QUEBRA_1, PRODUTOS_TAMANHOS.QUEBRA_2, PRODUTOS_TAMANHOS.QUEBRA_3, PRODUTOS_TAMANHOS.QUEBRA_4,
*!*			 PRODUTOS_TAMANHOS.QUEBRA_5, PRODUTOS_TAMANHOS.TAMANHO_1, PRODUTOS_TAMANHOS.TAMANHO_2, PRODUTOS_TAMANHOS.TAMANHO_3, PRODUTOS_TAMANHOS.TAMANHO_4, PRODUTOS_TAMANHOS.TAMANHO_5, PRODUTOS_TAMANHOS.TAMANHO_6, PRODUTOS_TAMANHOS.TAMANHO_7,
*!*			 PRODUTOS_TAMANHOS.TAMANHO_8, PRODUTOS_TAMANHOS.TAMANHO_9, PRODUTOS_TAMANHOS.TAMANHO_10, PRODUTOS_TAMANHOS.TAMANHO_11, PRODUTOS_TAMANHOS.TAMANHO_12, PRODUTOS_TAMANHOS.TAMANHO_13, PRODUTOS_TAMANHOS.TAMANHO_14, PRODUTOS_TAMANHOS.TAMANHO_15,
*!*			 PRODUTOS_TAMANHOS.TAMANHO_16, PRODUTOS_TAMANHOS.TAMANHO_17, PRODUTOS_TAMANHOS.TAMANHO_18, PRODUTOS_TAMANHOS.TAMANHO_19, PRODUTOS_TAMANHOS.TAMANHO_20, PRODUTOS_TAMANHOS.TAMANHO_21, PRODUTOS_TAMANHOS.TAMANHO_22, PRODUTOS_TAMANHOS.TAMANHO_23,
*!*			 PRODUTOS_TAMANHOS.TAMANHO_24, PRODUTOS_TAMANHOS.TAMANHO_25, PRODUTOS_TAMANHOS.TAMANHO_26, PRODUTOS_TAMANHOS.TAMANHO_27, PRODUTOS_TAMANHOS.TAMANHO_28, PRODUTOS_TAMANHOS.TAMANHO_29, PRODUTOS_TAMANHOS.TAMANHO_30, PRODUTOS_TAMANHOS.TAMANHO_31,
*!*			 PRODUTOS_TAMANHOS.TAMANHO_32, PRODUTOS_TAMANHOS.TAMANHO_33, PRODUTOS_TAMANHOS.TAMANHO_34, PRODUTOS_TAMANHOS.TAMANHO_35, PRODUTOS_TAMANHOS.TAMANHO_36, PRODUTOS_TAMANHOS.TAMANHO_37, PRODUTOS_TAMANHOS.TAMANHO_38, PRODUTOS_TAMANHOS.TAMANHO_39,
*!*			 PRODUTOS_TAMANHOS.TAMANHO_40, PRODUTOS_TAMANHOS.TAMANHO_41, PRODUTOS_TAMANHOS.TAMANHO_42, PRODUTOS_TAMANHOS.TAMANHO_43, PRODUTOS_TAMANHOS.TAMANHO_44, PRODUTOS_TAMANHOS.TAMANHO_45, PRODUTOS_TAMANHOS.TAMANHO_46, PRODUTOS_TAMANHOS.TAMANHO_47,
*!*			 PRODUTOS_TAMANHOS.TAMANHO_48, PRODUTOS_TAMANHOS.DATA_PARA_TRANSFERENCIA,
*!*			 PRODUTOS_TAMANHOS.GRADE_BASE FROM PRODUTOS_TAMANHOS 
*!*			EndText			
*!*			
*!*		    thisformset.dataenvironment.Cursorv_produtos_tamanho_00.Query()
								
				
	Case Upper(xmetodo) == 'USR_INCLUDE_BEFORE'
	
*!*			
*!*			Text TO  thisformset.dataenvironment.Cursorv_produtos_tamanho_00.SelectCmd TextMerge NoShow
*!*			SELECT PRODUTOS_TAMANHOS.GRADE, PRODUTOS_TAMANHOS.NUMERO_QUEBRAS, PRODUTOS_TAMANHOS.NUMERO_TAMANHOS, PRODUTOS_TAMANHOS.TAMANHOS_DIGITADOS, PRODUTOS_TAMANHOS.QUEBRA_1, PRODUTOS_TAMANHOS.QUEBRA_2, PRODUTOS_TAMANHOS.QUEBRA_3, PRODUTOS_TAMANHOS.QUEBRA_4,
*!*			 PRODUTOS_TAMANHOS.QUEBRA_5, PRODUTOS_TAMANHOS.TAMANHO_1, PRODUTOS_TAMANHOS.TAMANHO_2, PRODUTOS_TAMANHOS.TAMANHO_3, PRODUTOS_TAMANHOS.TAMANHO_4, PRODUTOS_TAMANHOS.TAMANHO_5, PRODUTOS_TAMANHOS.TAMANHO_6, PRODUTOS_TAMANHOS.TAMANHO_7,
*!*			 PRODUTOS_TAMANHOS.TAMANHO_8, PRODUTOS_TAMANHOS.TAMANHO_9, PRODUTOS_TAMANHOS.TAMANHO_10, PRODUTOS_TAMANHOS.TAMANHO_11, PRODUTOS_TAMANHOS.TAMANHO_12, PRODUTOS_TAMANHOS.TAMANHO_13, PRODUTOS_TAMANHOS.TAMANHO_14, PRODUTOS_TAMANHOS.TAMANHO_15,
*!*			 PRODUTOS_TAMANHOS.TAMANHO_16, PRODUTOS_TAMANHOS.TAMANHO_17, PRODUTOS_TAMANHOS.TAMANHO_18, PRODUTOS_TAMANHOS.TAMANHO_19, PRODUTOS_TAMANHOS.TAMANHO_20, PRODUTOS_TAMANHOS.TAMANHO_21, PRODUTOS_TAMANHOS.TAMANHO_22, PRODUTOS_TAMANHOS.TAMANHO_23,
*!*			 PRODUTOS_TAMANHOS.TAMANHO_24, PRODUTOS_TAMANHOS.TAMANHO_25, PRODUTOS_TAMANHOS.TAMANHO_26, PRODUTOS_TAMANHOS.TAMANHO_27, PRODUTOS_TAMANHOS.TAMANHO_28, PRODUTOS_TAMANHOS.TAMANHO_29, PRODUTOS_TAMANHOS.TAMANHO_30, PRODUTOS_TAMANHOS.TAMANHO_31,
*!*			 PRODUTOS_TAMANHOS.TAMANHO_32, PRODUTOS_TAMANHOS.TAMANHO_33, PRODUTOS_TAMANHOS.TAMANHO_34, PRODUTOS_TAMANHOS.TAMANHO_35, PRODUTOS_TAMANHOS.TAMANHO_36, PRODUTOS_TAMANHOS.TAMANHO_37, PRODUTOS_TAMANHOS.TAMANHO_38, PRODUTOS_TAMANHOS.TAMANHO_39,
*!*			 PRODUTOS_TAMANHOS.TAMANHO_40, PRODUTOS_TAMANHOS.TAMANHO_41, PRODUTOS_TAMANHOS.TAMANHO_42, PRODUTOS_TAMANHOS.TAMANHO_43, PRODUTOS_TAMANHOS.TAMANHO_44, PRODUTOS_TAMANHOS.TAMANHO_45, PRODUTOS_TAMANHOS.TAMANHO_46, PRODUTOS_TAMANHOS.TAMANHO_47,
*!*			 PRODUTOS_TAMANHOS.TAMANHO_48, PRODUTOS_TAMANHOS.DATA_PARA_TRANSFERENCIA,
*!*			 PRODUTOS_TAMANHOS.GRADE_BASE FROM PRODUTOS_TAMANHOS 
*!*			EndText			
*!*			
*!*		    thisformset.dataenvironment.Cursorv_produtos_tamanho_00.Query()
*!*						


			case UPPER(xmetodo) == 'USR_ALTER_AFTER'


				IF ThisFormSet.p_Tool_Status == 'A'

					WAIT WINDOW 'ALTERACAO, '
					
					** apaga os dados do cursor temporario para popular se excluirem os codigos de barra
					** Paulo Devide --> 18-abr-18
					IF USED("V_PRODUTOS_BARRA_APAGADOS")
						strAlias1 = ALIAS()
						SELECT V_PRODUTOS_BARRA_APAGADOS 
						SET SAFETY OFF
						ZAP
						SELECT (strAlias1)
					ENDIF
					 

					thisformset.lx_FORM1.lx_pageframe1.page5.bt_copia2.enabled = .f.
					thisformset.lx_FORM1.lx_pageframe1.page5.bt_copia2.visible = .f.


					thisformset.lx_FORM1.lx_pageframe1.page5.bt_copia.enabled = .t.
					thisformset.lx_FORM1.lx_pageframe1.page5.bt_copia.visible = .t.
					
					SELECT SUM(preco1) as tot FROM V_PRODUTOS_00_PRECOS INTO CURSOR xvalida

					IF xvalida.tot > 0
						thisformset.lx_FORM1.lx_pageframe1.page5.lX_GRID_FILHA1.ReadOnly = .t.
						thisformset.lx_FORM1.lx_pageframe1.page5.lX_GRID_FILHA1.p_tool_grid.Visible = .f.
					ELSE
						thisformset.lx_FORM1.lx_pageframe1.page5.lX_GRID_FILHA1.ReadOnly = .f.
					endif


					IF NOT thisformset.pp_palma_libera_bloq_produto
						***
						* PAULO DEVIDE
						* SE TIVER PEDIDO COM O PRODUTO, NAO DEIXAR ALTERAR CORES
						*/
						TEXT TO lcSQL NOSHOW TEXTMERGE
							select pedido from COMPRAS_PRODUTO where produto = '<<ALLTRIM(V_PRODUTOS_00.PRODUTO)>>' and QTDE_ORIGINAL <> QTDE_ENTREGAR
						ENDTEXT
						F_SELECT(lcSQL,"tmpPedido01")

						IF RECCOUNT("tmpPedido01")>0 && existe pedido para este produto, não pode alterar as cores

							thisformset.lx_FORM1.lx_PAGEFRAME1.pAGE1.pgDadosProdutos.pAGE2.lx_GRID_FILHA1.ReadOnly=.t.
							thisformset.lx_FORM1.lx_PAGEFRAME1.pAGE1.pgDadosProdutos.pAGE2.lx_GRID_FILHA1.p_tool_grid.Visible=.f.
							thisformset.lx_FORM1.lx_PAGEFRAME1.pAGE1.pgDadosProdutos.pAGE2.lx_GRID_FILHA1.enabled = .f.

							o_toolbar.Botao_filhas_inserir.Enabled= .F.
							o_toolbar.botao_filhas_deletar.Enabled= .F.
							
							IF thisformset.pp_palma_bloq_botao_barcode=.T.
							
								WITH thisformset.lx_FORM1.lx_PAGEFRAME1.PAGE3 && Codigo de Barras
								
									llEnabled_Option = .opt_padrao.enabled
									llEnabled_spn_tam_pos = .spn_tam_pos.enabled
									llEnabled_botao1 = .botao1.enabled
									llEnabled_command1 = .command1.enabled
									llEnabled_ck_usa_cor = .ck_usa_cor.enabled
									llEnabled_ck_usa_tam = .ck_usa_tam.enabled
									
									.opt_padrao.enabled = .f.
									.spn_tam_pos.enabled = .f. 
									.botao1.enabled = .f.
									.command1.enabled = .f.
									.ck_usa_cor.enabled = .f.
									.ck_usa_tam.enabled = .f.

																	
								ENDWITH
														
							ENDIF
							
						ELSE
							thisformset.lx_FORM1.lx_PAGEFRAME1.pAGE1.pgDadosProdutos.pAGE2.lx_GRID_FILHA1.ReadOnly=.f.
							thisformset.lx_FORM1.lx_PAGEFRAME1.pAGE1.pgDadosProdutos.pAGE2.lx_GRID_FILHA1.p_tool_grid.Visible=.t.
							thisformset.lx_FORM1.lx_PAGEFRAME1.pAGE1.pgDadosProdutos.pAGE2.lx_GRID_FILHA1.enabled = .t.
							o_toolbar.Botao_filhas_inserir.Enabled= .T.
							o_toolbar.botao_filhas_deletar.Enabled= .T.

						ENDIF
						
					ENDIF && NOT thisformset.pp_palma_libera_bloq_produto --> paulo devide - 08-jun-16
					


				ENDIF
				
			case UPPER(xmetodo) == 'USR_ALTER_BEFORE'
				xlibera = 0
				
*!*				
*!*					Text TO  thisformset.dataenvironment.Cursorv_produtos_tamanho_00.SelectCmd TextMerge NoShow
*!*					SELECT PRODUTOS_TAMANHOS.GRADE, PRODUTOS_TAMANHOS.NUMERO_QUEBRAS, PRODUTOS_TAMANHOS.NUMERO_TAMANHOS, PRODUTOS_TAMANHOS.TAMANHOS_DIGITADOS, PRODUTOS_TAMANHOS.QUEBRA_1, PRODUTOS_TAMANHOS.QUEBRA_2, PRODUTOS_TAMANHOS.QUEBRA_3, PRODUTOS_TAMANHOS.QUEBRA_4,
*!*					 PRODUTOS_TAMANHOS.QUEBRA_5, PRODUTOS_TAMANHOS.TAMANHO_1, PRODUTOS_TAMANHOS.TAMANHO_2, PRODUTOS_TAMANHOS.TAMANHO_3, PRODUTOS_TAMANHOS.TAMANHO_4, PRODUTOS_TAMANHOS.TAMANHO_5, PRODUTOS_TAMANHOS.TAMANHO_6, PRODUTOS_TAMANHOS.TAMANHO_7,
*!*					 PRODUTOS_TAMANHOS.TAMANHO_8, PRODUTOS_TAMANHOS.TAMANHO_9, PRODUTOS_TAMANHOS.TAMANHO_10, PRODUTOS_TAMANHOS.TAMANHO_11, PRODUTOS_TAMANHOS.TAMANHO_12, PRODUTOS_TAMANHOS.TAMANHO_13, PRODUTOS_TAMANHOS.TAMANHO_14, PRODUTOS_TAMANHOS.TAMANHO_15,
*!*					 PRODUTOS_TAMANHOS.TAMANHO_16, PRODUTOS_TAMANHOS.TAMANHO_17, PRODUTOS_TAMANHOS.TAMANHO_18, PRODUTOS_TAMANHOS.TAMANHO_19, PRODUTOS_TAMANHOS.TAMANHO_20, PRODUTOS_TAMANHOS.TAMANHO_21, PRODUTOS_TAMANHOS.TAMANHO_22, PRODUTOS_TAMANHOS.TAMANHO_23,
*!*					 PRODUTOS_TAMANHOS.TAMANHO_24, PRODUTOS_TAMANHOS.TAMANHO_25, PRODUTOS_TAMANHOS.TAMANHO_26, PRODUTOS_TAMANHOS.TAMANHO_27, PRODUTOS_TAMANHOS.TAMANHO_28, PRODUTOS_TAMANHOS.TAMANHO_29, PRODUTOS_TAMANHOS.TAMANHO_30, PRODUTOS_TAMANHOS.TAMANHO_31,
*!*					 PRODUTOS_TAMANHOS.TAMANHO_32, PRODUTOS_TAMANHOS.TAMANHO_33, PRODUTOS_TAMANHOS.TAMANHO_34, PRODUTOS_TAMANHOS.TAMANHO_35, PRODUTOS_TAMANHOS.TAMANHO_36, PRODUTOS_TAMANHOS.TAMANHO_37, PRODUTOS_TAMANHOS.TAMANHO_38, PRODUTOS_TAMANHOS.TAMANHO_39,
*!*					 PRODUTOS_TAMANHOS.TAMANHO_40, PRODUTOS_TAMANHOS.TAMANHO_41, PRODUTOS_TAMANHOS.TAMANHO_42, PRODUTOS_TAMANHOS.TAMANHO_43, PRODUTOS_TAMANHOS.TAMANHO_44, PRODUTOS_TAMANHOS.TAMANHO_45, PRODUTOS_TAMANHOS.TAMANHO_46, PRODUTOS_TAMANHOS.TAMANHO_47,
*!*					 PRODUTOS_TAMANHOS.TAMANHO_48, PRODUTOS_TAMANHOS.DATA_PARA_TRANSFERENCIA,
*!*					 PRODUTOS_TAMANHOS.GRADE_BASE FROM PRODUTOS_TAMANHOS 
*!*					EndText			
*!*					
*!*				    thisformset.dataenvironment.Cursorv_produtos_tamanho_00.Query()				

				
				
			Case Upper(xmetodo) == 'USR_INCLUDE_AFTER'
	
	
				IF ThisFormSet.p_Tool_Status == 'I'
					****
					* Quando clica em incluir, a pagina do Código de Barras, fica Enabled = .F. (desabilitada)
					* Ao cancelar ou salvar, volta o status ao normal, ThisFormSet.p_Tool_Status diferente de 'I'
					* 
					* PAULO DEVIDE - 06/04/16
					*/		
				
					**
					thisformset.lx_form1.lx_pageframe1.page3.Enabled=.F.
					**

					*****WAIT WINDOW 'inclusão de botão com preço default'
					*** Sandra Ono - 27/05/2014 ****

					thisformset.lx_FORM1.lx_pageframe1.page5.bt_copia2.enabled = .t.
					thisformset.lx_FORM1.lx_pageframe1.page5.bt_copia2.visible = .t.
					
					SELECT SUM(preco1) as tot FROM V_PRODUTOS_00_PRECOS INTO CURSOR xvalida

					IF xvalida.tot > 0
						thisformset.lx_FORM1.lx_pageframe1.page5.lX_GRID_FILHA1.ReadOnly = .t.
						thisformset.lx_FORM1.lx_pageframe1.page5.lX_GRID_FILHA1.p_tool_grid.Visible = .f.
					ELSE
						thisformset.lx_FORM1.lx_pageframe1.page5.lX_GRID_FILHA1.ReadOnly = .f.
					endif

					***
					* VALORES DEFAULT - INCLUSÃO
					* PROJETO CUPS - PAULO DEVIDE
					*/
					
					thisformset.lx_FORM1.lx_pageframe1.page1.pgDadosProdutos.page1.cbo_segmento1.VALUE = '000155' && VAREJO
					thisformset.lx_FORM1.lx_pageframe1.page1.pgDadosProdutos.page1.cbo_segmento1.valid()


					** JIRA SIS-557 -> DEIXAR FLAG ENVIA_VAREJO_INTERNET MARCADO COMO DEFAULT
					thisformset.LX_FORM1.LX_pageframe1.Page1.PgDadosProdutos.Page4.LX_checkbox3.VALUE = .T.
					**
				ENDIF	


	   		case UPPER(xmetodo) == 'USR_WHEN'			
				** combobox continuo/descontinuo 
				** demanda JIRA LC-285
				IF 'LX_COMBOBOX8' $ UPPER(xnome_obj) 
					
					IF  INLIST(ThisFormSet.p_tool_status,'I','A')
						ldUltimoAgendamento = NVL(V_PRODUTOS_00.ERP_DATA_ULTIMO_AGENDAMENTO,CTOD(""))
						IF EMPTY(ldUltimoAgendamento)
							WAIT WINDOW NOWAIT "Alteração permitida!"
							RETURN .t.
						ELSE
							MESSAGEBOX("Alteração não permitida neste campo"+CHR(13)+;
										"Data do último agendamento = "+DTOC(ldUltimoAgendamento),;
										64,"Aviso")
							RETURN .f.
						ENDIF
					ENDIF
				ENDIF

				***
				* CUSTOMIZAÇÃO ANGELA(FISCAL)
				* PRODUTO DEVE SER LIBERADO PELO FISCAL
				*/
				IF 'CMB_STATUS_PRODUTO' $ UPPER(xnome_obj) 
					
					IF  INLIST(ThisFormSet.p_tool_status,'I','A')
						
						IF ThisFormSet.pp_cgp_acesso_equipe_fiscal = .T. && parametro configurado por usuário (default .F.)
							RETURN .t.
						ELSE
							IF ALLTRIM(V_PRODUTOS_00.GRIFFE)="ACESSORIOS"
								MESSAGEBOX("Alteração não permitida neste campo"+CHR(13)+;
											"Somente a Equipe do Fiscal pode alterar", +;
											64,"Aviso")
								RETURN .f.
							ENDIF
							RETURN .T.			
						ENDIF

					ENDIF
				ENDIF		
					
	   		case UPPER(xmetodo) == 'USR_VALID'			
				***
				* CUSTOMIZAÇÃO ANGELA(FISCAL)
				* PRODUTO DEVE SER LIBERADO PELO FISCAL
				*/
				IF 'TVGRIFFE'$UPPER(xnome_obj)
			    		
			    		IF  INLIST(ThisFormSet.p_tool_status,'I','A')
			    			*WAIT WINDOW ALLTRIM(V_PRODUTOS_00.GRIFFE) 
						IF ALLTRIM(V_PRODUTOS_00.GRIFFE) = "ACESSORIOS"
							IF EMPTY(NVL(V_PRODUTOS_00.STATUS_PRODUTO,"")) OR ;
								(ThisFormSet.p_tool_status="I" AND V_PRODUTOS_00.STATUS_PRODUTO="01")
								REPLACE V_PRODUTOS_00.STATUS_PRODUTO WITH "03" 		
								ThisFormSet.LX_FORM1.LX_pageframe1.Page1.PgDadosProdutos.Page1.CMB_STATUS_PRODUTO.VALUE	="03"
								ThisFormSet.LX_FORM1.LX_pageframe1.Page1.PgDadosProdutos.Page1.CMB_STATUS_PRODUTO.REFRESH				
							ENDIF
							
							***
							* Modo alteração, mudou griffe para ACESSORIOS
							*/
							lcOldValue=OLDVAL("GRIFFE", "V_PRODUTOS_00")
							IF (ThisFormSet.p_tool_status="A" AND ALLTRIM(V_PRODUTOS_00.GRIFFE) = "ACESSORIOS" AND lcOldValue<>"ACESSORIOS")
								REPLACE V_PRODUTOS_00.STATUS_PRODUTO WITH "03" 		
								ThisFormSet.LX_FORM1.LX_pageframe1.Page1.PgDadosProdutos.Page1.CMB_STATUS_PRODUTO.VALUE	="03"
								ThisFormSet.LX_FORM1.LX_pageframe1.Page1.PgDadosProdutos.Page1.CMB_STATUS_PRODUTO.REFRESH				
							ENDIF

						ELSE && SE NÃO FOR ACESSORIOS - STATUS = LIBERADO
							REPLACE V_PRODUTOS_00.STATUS_PRODUTO WITH "01" 		
							ThisFormSet.LX_FORM1.LX_pageframe1.Page1.PgDadosProdutos.Page1.CMB_STATUS_PRODUTO.VALUE	="01"
							ThisFormSet.LX_FORM1.LX_pageframe1.Page1.PgDadosProdutos.Page1.CMB_STATUS_PRODUTO.REFRESH				
						ENDIF
			    		ENDIF
			    		
		    		ENDIF
			
				*** Sandra Ono - 27/05/2014 ****
				**** Alteração para corrigir erro da linx para não alterar 
				**** o preço liquido dos produtos
				 
				IF 'TX_PRECO1'$UPPER(xnome_obj)
		    		IF  INLIST(ThisFormSet.p_tool_status,'I','A')
		    		
   	     	    		replace 	preco_liquido1 with 0, ;
	 					preco_liquido2 with 0, ;
						preco_liquido3 with 0, ;
						preco_liquido4 with 0  IN V_PRODUTOS_00_PRECOS

		    		
				    		
		    		ENDIF
				ENDIF    		
				

										

			CASE UPPER(xmetodo) == 'USR_SAVE_BEFORE'

				** Mensagem de alerta de ERP_CUPS_STYLENUMBER em duplicidade para produtos KOMPORT
				 IF INLIST(ThisFormSet.p_Tool_Status, 'I', 'A')
				 	TEXT TO cmdsql1 NOSHOW TEXTMERGE PRETEXT 7
						SELECT COUNT(*) AS QTY 
						FROM PRODUTOS 
						WHERE FABRICANTE = 'KOMPORT' 
							AND ERP_CUPS_STYLENUMBER = ?V_PRODUTOS_00.ERP_CUPS_STYLENUMBER AND PRODUTO <> ?V_PRODUTOS_00.produto    
				 	ENDTEXT
					f_select(cmdsql1, "tmpAlert1")
					IF tmpAlert1.qty >= 1
						IF MESSAGEBOX("Atenção esse STYLE NUMBER foi usado em outros produtos já! Deseja corrigir?" ,292,"Aviso")=6
							RETURN .f.
						ENDIF
					ENDIF
						
				 ENDIF

				 *** verifica produtos_precos se esta cadastrada na Inclusão  	
				 IF ThisFormSet.p_Tool_Status == 'I'
				 
				 	IF RECCOUNT("V_PRODUTOS_00_PRECOS")<1
				 		MESSAGEBOX("Atenção você está incluíndo o produto sem cadastrar a Tabela de Preços!"+CHR(13)+;
				 					"Favor incluir os preços antes de salvar o Produto!", 16,"Aviso")
				 		thisformset.lx_FORM1.lx_pageframe1.activepage = 5			
				 		RETURN .f.
				 	ENDIF
				 	
				 	IF RECCOUNT("V_PRODUTOS_00_PACKS_PERMITIDOS")<1
				 		MESSAGEBOX("Atenção você está incluíndo o produto sem cadastrar a configuração do PACK!"+CHR(13)+;
				 					"Favor configurar o PACK antes de salvar o Produto!", 16,"Aviso")
				 		thisformset.lx_FORM1.lx_pageframe1.activepage = 6			
				 		RETURN .f.
				 	ENDIF
				 	
				 	
				 ENDIF

				** VALIDAÇÃO DA PROPRIEDADE DATA_ATIVACAO (00027)
				IF USED("CURPROPPRODUTOS")
					llOk=zvalida_prop_data_ativacao() &&PAULO DEVIDE - 03-09-2013
					IF NOT llOk
						RETURN .f.
					ENDIF
				Endif	
				
				** PAULO DEVIDE -> 24-05-2013
				** alterado em 15/04/2015 
				** inclusão de regras de validação para page do Atacado - PROJETO CUPS
				llOk=zvalida_campos_produto()
				IF NOT llOk
					RETURN .f.
				ENDIF
				** FIMI: 24-05-2013		
				** FIM : 15-04-2015		
					

				** Sandra Ono -> 24-05-2013   	
				 lc_NCM = ALLTRIM(V_PRODUTOS_00.CLASSIF_FISCAL)    
				   	
				 lc_sql =  " Select NCM_NBS from TMP_TABELA_ALIQUOTA_IMPOSTO_ITEM  ALIQ where NCM_NBS =  ?lc_NCM"
					
				 IF USED("tmp_NCM")
					  USE IN tmp_NCM
				 ENDIF

				 f_select(lc_sql,"tmp_NCM")			   	
				   	
				 IF RECCOUNT("tmp_NCM") = 0
				   	
				   	   =MESSAGEBOX("O NCM (Classificação Fiscal) não foi encontrado na tabela Aliquota de Impostos das lojas. Verifique ! ",16,"Atenção")
				   	   
				   	   RETURN .F.
				 ENDIF
				 
				 
				
			otherwise
				return .t.
		endcase
	endproc
enddefine

***
* botão para exportar código de barras para excel
* 11/05/2016
*/
DEFINE CLASS bt_report as botao
	caption = 'Relatório Excel'
	*autosize = .T.
	WORDWRAP = .t.
	WIDTH = 192
	top = 3
	left = 502
	HEIGHT =  27
	enabled = .F.
	visible  = .t.
	backcolor =  RGB(64,128,128)

	PROCEDURE click
		LOCAL llRet
		llRet = MESSAGEBOX("Deseja Exportar Relatório de Código de Barras para o Excel?",292,"Aviso")=6
		
		IF llRet
			f_wait("Exportando dados para o Excel...")
			LOCAL lcArquivo as String
			lcArquivo = SYS(2023)+"\Produtos_Codigo_Barras_"+STUFF(STUFF(DTOS(DATE()),5,0,'-'),8,0,'-')+SYS(2015)+".xlsx"
			
			zExporta_Excel("V_PRODUTOS_00_BARRA")
			
			f_wait()	
		ENDIF
		

	ENDPROC
	
	PROCEDURE refresh
		** Inclusão/Alteração/Exclusão/Tela (L)impa/(P)esquisa Feita!
		this.enabled = !INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L") 
	ENDPROC
	
ENDDEFINE

DEFINE CLASS spnQtdPack as spinner
	WIDTH = 62
	top = 425
	left = 520
	HEIGHT =  24
	enabled = .F.
	visible  = .t.


	PROCEDURE when
		RETURN V_PRODUTOS_00.sortimento_tamanho
	ENDPROC
	
	PROCEDURE valid
		

	ENDPROC
	
*!*		PROCEDURE refresh
*!*			** Inclusão/Alteração/Exclusão/Tela (L)impa/(P)esquisa Feita!
*!*			this.enabled = !INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L") 
*!*		ENDPROC
	
ENDDEFINE


***
* Função para exportar cursor para Excel
* 11/05/2016
*/
FUNCTION zExporta_Excel
PARAMETERS lcCursor
** Formata cursor no excel
lcOldPoint = SET("Point")
lcOldSeparator = SET("Separator")

SET SEPARATOR TO "."
SET POINT TO ","

LOCAL oExcel as Object
LOCAL lnVez as Integer
oExcel = CREATEOBJECT("Excel.application")
FOR lnVez=1 TO 1 && lcCursor1, lcCursor2, lcCursor3 (3 abas)

	WITH oExcel

		IF lnVez=1
			.Application.ErrorCheckingOptions.BackgroundChecking = .f.
			.SheetsInNewWorkbook = 1 &&4 && quantas sheets vai criar dentro do workbook = 1
			.workbooks.Add
			.Sheets(1).Name = lcCursor
		ENDIF

		lcTab = icase(lnVez=1,lcCursor,lnVez=2,lcCursor2,lcCursor3)
		
		SELECT (lcTab)
		.Sheets(lnVez).Select
		
		.visible = .f.
		
		** formata as celulas no excel, conforme se tipo no cursor
		lcColsDateFormat = ""
		lcColsNumeric = ""
		
		lnFields = AFIELDS(laFields,lcTab)
		FOR lnCount=1 TO ALEN(laFields,1)
			
			.Cells(1,lnCount).Select
			lcAdress = SUBSTR(.ActiveCell.Address,2,ATC("$",.ActiveCell.Address,2)-2)
			.Columns(lcAdress+":"+lcAdress).Select
			
			DO CASE
				CASE INLIST(laFields[lnCount,2],'C','M','V') && caracter
					.Selection.NumberFormat = "@" && formata a celula para TEXTO
					
				CASE laFields[lnCount,2] = 'Y' && moeda
					.Selection.NumberFormat = "_(* #,##0.00_);_(* (#,##0.00);_(* ""-""??_);_(@_)"
					
				CASE laFields[lnCount,2] = 'D' && Date
				    .Selection.NumberFormat = "@" &&"m/d/yyyy"
					lcColsDateFormat = 	lcColsDateFormat + lcAdress + ";D," 

				CASE laFields[lnCount,2] = 'T' && Datetime
			    	.Selection.NumberFormat = "@" &&"d/m/yy h:mm;@"
					lcColsDateFormat = 	lcColsDateFormat + lcAdress + ";T," 
			    	
				CASE laFields[lnCount,2] = 'B' && Double (Numeric)
					 lcMascara = "#,##0." + PADL(0,laFields[lnCount,4],'0')
					 .Selection.NumberFormat = lcMascara

				CASE laFields[lnCount,2] = 'F' && Float (Numeric)
					 lcMascara = "#,##0." + PADL(0,laFields[lnCount,4],'0')
					 .Selection.NumberFormat = lcMascara

				CASE laFields[lnCount,2] = 'I' && Inteiro
					.Selection.NumberFormat = "#,##0"
					
				CASE laFields[lnCount,2] = 'L' && Logico (Verdadeiro/Falso)
					.Selection.NumberFormat = "General"

				CASE laFields[lnCount,2] = 'N' && Numeric
					 lcMascara = "#,##0." + PADL(0,laFields[lnCount,4],'0')
					 .Selection.NumberFormat = lcMascara
					  	
				OTHERWISE
					.Selection.NumberFormat = "General"
			ENDCASE

			IF INLIST(laFields[lnCount,2],"B","F","I","N") && ALINHAMENTO A DIREITA DA CELULA numericos
			
			    With .Selection
			        .HorizontalAlignment = -4152
			        .VerticalAlignment = -4107
			        .WrapText = .F.
			        .Orientation = 0
			        .AddIndent = .F.
			        .IndentLevel = 0
			        .ShrinkToFit = .F.
			        .ReadingOrder = -5002
			        .MergeCells = .F.
			    Endwith		
			    
			    lcColsNumeric = lcColsNumeric + lcAdress + "," 
			    
			ENDIF
					
			.cells(1,lnCount).Select
			.Selection.NumberFormat = "@" && Formata a célula de cabeçalho (nome da coluna) como texto
		    With .Selection.Interior
		        .Pattern = 1
		        .PatternColorIndex = -4105
		        .Color = 65535
		        .TintAndShade = 0
		        .PatternTintAndShade = 0
		    EndWith
		    .Selection.Font.Bold = .t.

			.cells(1,lnCount).value = PROPER(laFields[lnCount,1])
			
			
		ENDFOR

		SELECT (lcTab)
		lcArqtmp = "curtmp"+SYS(2015)+".txt"
		lcArqtmp = SYS(2023)+"\"+lcArqtmp
		COPY TO (lcArqtmp) DELIMITED WITH tab
		
		lcStrArq = FILETOSTR(lcArqtmp)
		_cliptext = lcStrArq
		
		.cells(2,1).select
		.ActiveSheet.Paste

		.Cells.Select
	    .Cells.EntireColumn.AutoFit
	    
	    .Cells(1,1).select
		.Application.WindowState = -4137    	
		
		DELETE FILE (lcArqtmp)
		_cliptext = ""

		** Formatação de campo Date e Datetime
		IF NOT EMPTY(lcColsDateFormat)
			lcColsDateFormat = LEFT(lcColsDateFormat,LEN(lcColsDateFormat)-1) && tira a ultima virgula
			lnCols = GETWORDCOUNT(lcColsDateFormat,",")
			FOR lnCount=1 TO lnCols 
				lcInfoColuna = GETWORDNUM(lcColsDateFormat,lnCount,",")
				lcColuna = GETWORDNUM(lcInfoColuna,1,";")
				lcTipoColuna = GETWORDNUM(lcInfoColuna,2,";")
				.Columns(lcColuna+":"+lcColuna).Select		

				DO CASE
					CASE lcTipoColuna = "D"			
						.Selection.NumberFormat = "m/d/yyyy"
					CASE lcTipoColuna = "T"			
						.Selection.NumberFormat = "d/m/yy h:mm;@"
				ENDCASE
				
			ENDFOR
		ENDIF
		
		** Tratamento das colunas numéricas
		IF NOT EMPTY(lcColsNumeric)
			lcColsNumeric = LEFT(lcColsNumeric ,LEN(lcColsNumeric)-1) && tira a ultima virgula
			lnCols = GETWORDCOUNT(lcColsNumeric,",")
			FOR lnCount=1 TO lnCols 
				lcColuna = GETWORDNUM(lcColsNumeric,lnCount,",")
				
				lnLinhaI = 2
				lnLinhaF = RECCOUNT(lcTab)+1

				FOR lnLinhaI = 2 TO lnLinhaF 
					lnCelula = .RANGE(lcColuna+ALLTRIM(TRANSFORM(lnLinhaI))).VALUE 
	  				.RANGE(lcColuna+ALLTRIM(TRANSFORM(lnLinhaI))).VALUE = val(ALLTRIM(TRANSFORM(lnCelula)))
				ENDFOR
							
			ENDFOR
		ENDIF
		

		lnLinhaI = 2
		lnLinhaF = RECCOUNT(lcTab)+1

		FOR lnLinhaI = 2 TO lnLinhaF 
		
			lcCelula = .RANGE("A"+ALLTRIM(TRANSFORM(lnLinhaI))).VALUE 
			IF lcCelula = "P" && parcela - pinta a linha de cinza
			    .RANGE("A"+ALLTRIM(TRANSFORM(lnLinhaI))).select
			    .Application.Goto("R"+ALLTRIM(TRANSFORM(lnLinhaI))+"C1:R"+ALLTRIM(TRANSFORM(lnLinhaI))+"C102")
			    With .Selection.Interior
			        .Pattern = 1
			        .PatternColorIndex = -4105
			        .Color = 15395562
			        .TintAndShade = 0
			        .PatternTintAndShade = 0
			    Endwith
			ENDIF
			
		ENDFOR
		
		.cells(1,1).select	

	    .Range("A1").Select
	    .Selection.AutoFilter
	    .Range("A2").Select
	    .ActiveWindow.FreezePanes = .t.

	ENDWITH
	
ENDFOR


oExcel.visible = .t.

SET SEPARATOR TO &lcOldSeparator.
SET POINT TO &lcOldPoint.
RELEASE oExcel

RETURN
ENDFUNC


****
* PAULO DEVIDE - 04/08/2015
* override da classe pai (original)
* modificação de métodos originais da .vcx
*/
DEFINE CLASS txt_stylenumber_edit as txt_stylenumber
	top = 60
	left = 290
	controlsource = "V_PRODUTOS_00.ERP_CUPS_STYLENUMBER"

	visible = .t.
	
	PROCEDURE when
		IF INLIST(ThisFormSet.p_Tool_Status,"I","A")

			IF ALLTRIM(cbo_segmento1.descricao)=="VAREJO"
				IF EMPTY(NVL(this.Value,''))
					RETURN .t.
				
				ELSE
				
					** Regra do Danilo
					** WAIT WINDOW "Style Number não pode mais ser alterado." &&"Não é necessário o preenchimento deste campo para o segmento VAREJO"
					*** Danilo precisa alterar la no VMulti				
					
					WAIT WINDOW "OK!" nowait
					RETURN .T.
					**RETURN .f.					
					
				ENDIF
				

			ELSE
				IF INLIST(ThisFormSet.p_tool_status,'A')
					IF !EMPTY(NVL(this.Value,''))
*!*							WAIT WINDOW "Style Number não pode mais ser alterado."
*!*							RETURN .f.
						WAIT WINDOW "OK!" nowait
						RETURN .T.
					ENDIF
				ENDIF
			ENDIF
			
		ENDIF


		RETURN .T.
	ENDPROC

	PROCEDURE valid
		IF INLIST(ThisFormSet.p_Tool_Status,"I","A")

			IF !(ALLTRIM(cbo_segmento1.descricao)=="VAREJO") && Atacado ou Atacado/Varejo
				
				llOk = .t.
				lcMsgErr = ""
				
				TEXT TO lcSQL NOSHOW TEXTMERGE
					SELECT * FROM produtos 
					WHERE ERP_CUPS_STYLENUMBER='<<ALLTRIM(this.value)>>' 
				ENDTEXT
				
				f_select(lcSQL,"tmp_valida_StyleNumber")
				
				IF ThisFormSet.p_Tool_Status = "I" && inclusão
					** Não deveria existir, pois produto esta em modo inclusão
					** e produto não foi incluido no banco
					IF RECCOUNT("tmp_valida_StyleNumber")>0
						lcMsgErr = "(I)-Style Number já tem um PRODUTO associado" + CHR(13) + ;
									"PRODUTO = "+ALLTRIM(tmp_valida_StyleNumber.PRODUTO)
						llOk = .f.
					ENDIF
				ENDIF
				
				IF ThisFormSet.p_Tool_Status = "A" && alteração
					** Não deveria existir, pois produto esta em modo inclusão
					** e produto não foi incluido no banco
					IF RECCOUNT("tmp_valida_StyleNumber")>0
						SELECT tmp_valida_StyleNumber
						SCAN 			
							IF !(ALLTRIM(tmp_valida_StyleNumber.PRODUTO) == ALLTRIM(V_PRODUTOS_00.PRODUTO))
								lcMsgErr = "(A)-Style Number já tem um PRODUTO associado" + CHR(13) + ;
											"PRODUTO = "+ALLTRIM(tmp_valida_StyleNumber.PRODUTO)
								llOk = .f.
								EXIT
							ENDIF
						ENDSCAN
					ENDIF
				ENDIF
				
				IF llOk=.f. && erro - exibir mensagem e retornar
					MESSAGEBOX(lcMsgErr, 16,"AVISO")
					RETURN .f.
				ENDIF
				
			ENDIF
			
		ENDIF
		RETURN .t.
	
	ENDPROC

	PROCEDURE refresh
		** Inclusão/Alteração/Exclusão/Tela (L)impa/(P)esquisa Feita!
		this.enabled = INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L")	
	ENDPROC
	
	PROCEDURE m_valida
		RETURN .t.
	ENDPROC
	
			
ENDDEFINE

** 21-jan-26 esqueleto
DEFINE CLASS lbl_esqueleto as label

	caption = 'ESQUELETO'
	autosize = .T.
	WIDTH = 100
	top = 394
	left = 10
	HEIGHT =  27
	visible  = .t.
	**backcolor =  RGB(64,128,128)
		
ENDDEFINE
** 21-jan-26 esqueleto

** 21-jan-26 esqueleto 
DEFINE CLASS cboEsqueleto as lx_ComboBox
	Height = 21
	Left = 88
	Top = 394
	Width = 280
	BoundColumn = 2
	RowSourceType = 3
	RowSource = ZZ_COMBO_ESQUELETO
	ControlSource = "V_PRODUTOS_00.ERP_COD_ESQUELETO"
	BoundTo = .T.
	Style = 2
	Name = "cboEsqueleto"	
	
*!*		PROCEDURE valid
*!*			WAIT WINDOW this.Value
*!*		ENDPROC
	
ENDDEFINE
** 21-jan-26 esqueleto

** 20-jun-16 checkbox area jeans
DEFINE CLASS chk_area_jeans as checkbox
	caption = 'Área Jeans?'
	autosize = .T.
	WIDTH = 192
	top = 391
	left = 428 &&498
	HEIGHT =  27
	enabled = .t.
	controlsource = "V_PRODUTOS_00.ERP_AREA_JEANS"
	visible  = .t.
	**backcolor =  RGB(64,128,128)

	PROCEDURE refresh
		** Inclusão/Alteração/Exclusão/Tela (L)impa/(P)esquisa Feita!
		this.enabled = INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L")	
	ENDPROC
		
ENDDEFINE
** 20-jun-16 checkbox area jeans


***
* CHECKBOX PARA SELECIONAR SE É CONJUNTO OU NÃO
*/
DEFINE CLASS chk_conjunto as checkbox
	caption = 'Conjunto?'
	autosize = .T.
	WIDTH = 192
	top = 86
	left = 305
	HEIGHT =  27
	enabled = .t.
	controlsource = "V_PRODUTOS_00.ERP_CUPS_CONJUNTO"
	visible  = .t.
	**backcolor =  RGB(64,128,128)

	PROCEDURE click
		IF INLIST(ThisFormSet.p_Tool_Status,"I","A")	
			IF V_PRODUTOS_00.ERP_CUPS_CONJUNTO	
			
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.cntBottom1.Enabled = .t.
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.cntBottom1.refresh
				
			ELSE

				thisformset.lx_FORM1.lx_pageframe1.pgImportado.cntBottom1.Enabled = .f.
				replace V_PRODUTOS_00.ERP_CUPS_COMPRIMENTO_BOTTOM WITH NULL
				replace V_PRODUTOS_00.ERP_CUPS_COMPOSICAO_BOTTOM WITH NULL
				replace V_PRODUTOS_00.ERP_CUPS_FORRO_BOTTOM WITH NULL
				thisformset.lx_FORM1.lx_pageframe1.pgImportado.cntBottom1.refresh

			ENDIF
		ENDIF
	ENDPROC

	PROCEDURE refresh
		** Inclusão/Alteração/Exclusão/Tela (L)impa/(P)esquisa Feita!
		this.enabled = INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L")	
	ENDPROC
		
ENDDEFINE
				
				
DEFINE CLASS btdefprice as botao
	caption = 'Definir Preço Default'
	*autosize = .T.
	WORDWRAP = .t.
	WIDTH = 192
	top = 3
	left = 502
	HEIGHT =  27
	enabled = .F.
	visible  = .t.
	backcolor =  RGB(64,128,128)

	PROCEDURE click


	
		thisformset.lx_FORM1.lx_pageframe1.page5.lX_GRID_FILHA1.ReadOnly = .f.
		
		IF ThisFormSet.p_Tool_Status == 'I'

			inppass3 = rbInputBox3( "Valor Default", "Preço Default para Tabelas", "", , , "!", , "")
			inppass3 = ALLTRIM(inppass3 )
			
		Endif	
		

	ENDPROC
	
ENDDEFINE		
		



DEFINE CLASS bt_estfilial as botao
	caption = 'Liberar Alteração de Preço'
	*autosize = .T.
	WORDWRAP = .t.
	WIDTH = 192
	top = 3
	left = 502
	HEIGHT =  27
	enabled = .F.
	visible  = .t.
	backcolor =  RGB(64,128,128)

	PROCEDURE click

*!*			LOCAL inppass
*!*			*	Password (masked)
*!*			inppass = rbInputBox( "Digite a Senha", "Senha para alteração de Pedido de Compra", "", , , "!", , "*")
*!*			inppass = ALLTRIM(UPPER(inppass ))


*!*			f_select("Select valor_atual from parametros where parametro = 'CAE_SENHA_COMPRAS' ","LISTAUT"	)

*!*			SELECT LISTAUT
*!*			CAEWHERE = LISTAUT.VALOR_ATUAL
*!*			xaut = 0

*!*			IF INLIST(inppass  , &CAEWHERE  )
*!*				xaut = xaut  +1
*!*			endif



*!*			IF xaut > 0
*!*				thisformset.lx_FORM1.lx_pageframe1.page5.lX_GRID_FILHA1.ReadOnly = .f.
*!*				thisformset.lx_FORM1.lx_pageframe1.page5.lX_GRID_FILHA1.p_tool_grid.Visible = .T.
*!*				xlibera = 1
*!*				RETURN .t.
*!*			ELSE
*!*				MESSAGEBOX("Senha incorreta ou não autorizada")
*!*				RETURN .f.
*!*			endif

	IF .f.
		inppass = rbInputBox( "Digite a Senha", "Senha para alteração de Pedido de Compra", "", , , "!", , "*")
		inppass = ALLTRIM(inppass )
		
		
		f_select("Select valor_atual from parametros where parametro = 'P_USER_APROVA_ALT_COMPRA' ","LISTAUT"	)
		SELECT LISTAUT
		CAEWHERE = LISTAUT.VALOR_ATUAL
		
		SET STEP ON 
		
		f_select("Select PASSW from USERS where USUARIO IN " + CAEWHERE +" ","LISTAUT2"	)
		xaut = 0
		
		SELECT listaut2
		SCAN
		
			caecomp =  F_ds_cr(ALLTRIM(LISTAUT2.passw))
			
			IF UPPER(inppass)  = UPPER(caecomp)
				xaut = xaut  +1
			endif 	
			
			SELECT listaut2
		endscan 
	ENDIF && endif do if .f.

	IF ZVALIDA_SENHA2("TABPRECO","Informe a Senha para liberar atualização de preços...")
		xaut = 1
	ELSE
		xaut = 0
	ENDIF
	
	
	IF xaut > 0
	
		thisformset.lx_FORM1.lx_pageframe1.page5.lX_GRID_FILHA1.ReadOnly = .f.
		
		IF ThisFormSet.p_Tool_Status == 'I'

			inppass3 = rbInputBox3( "Valor Default", "Preço Default para Tabelas", "", , , "!", , "")
			inppass3 = ALLTRIM(inppass3 )
			
		Endif	
		
		
		RETURN .t.
	ELSE
		MESSAGEBOX("Senha incorreta ou não autorizada")
		RETURN .f.
	endif	

	ENDPROC
ENDDEFINE

FUNCTION zvalida_prop_data_ativacao
	LOCAL llRet as Boolean, lcMsg as String
	LOCAL zold_area as Integer, zdd as Date, zddano_ant as Integer, zddano_pos as Integer

	zold_area=select()

	llRet = .t.
	lcMsg = ""
	
	IF !USED("CURPROPPRODUTOS")
		select (zold_area)
		return llRet && não obrigatório
	Endif
	
	select CURPROPPRODUTOS
	locate for propriedade='00027'

	if !found() 
		select (zold_area)
		return llRet && não obrigatório
	endif

	if empty(CURPROPPRODUTOS.valor_propriedade)
		select (zold_area)
		return llRet && não obrigatório
	endif

	zdd=CAST(CURPROPPRODUTOS.valor_propriedade as Date)
	zddano_ant = YEAR(DATE())-1
	zddano_pos = YEAR(DATE())+1


	IF EMPTY(zdd)

		select (zold_area)
		llRet = .f.
	ELSE
		IF !BETWEEN(YEAR(zdd),zddano_ant,zddano_pos)

			select (zold_area)
			llRet = .f.

		ENDIF
	ENDIF

	IF !llRet
		lcMsg = "Data informada na propriedade DATA_ATIVACAO é inválida!"
		MESSAGEBOX(lcMsg, 16,"Aviso")	
		RETURN llRet
	ENDIF

	RETURN llRet && .t.	
	
ENDFUNC



** PAULO DEVIDE -> 24-05-2013
FUNCTION zvalida_campos_produto
	LOCAL llRet as Boolean, lcMsg as String, lcTabelas as String

	LOCAL lnOldSelect as Integer
	lnOldSelect = SELECT()
	
	llRet = .t.
	lcMsg = ""
	lcTabelas = ""
	
	****
	* PAULO DEVIDE - 06/ABR/16
	* VALIDAÇÃO DOS CAMPOS FABRICANTE E REFERENCIA DO FABRICANTE
	*/
	IF NVL(v_produtos_00.revenda,.f.)=.t.
		IF EMPTY(NVL(v_produtos_00.FABRICANTE,''))
			llRet = .f.
			lcMsg = lcMsg + CHR(13) + "Campo [FABRICANTE] é obrigatório para REVENDA..."
		ENDIF
		IF EMPTY(NVL(v_produtos_00.REFER_FABRICANTE,''))
			llRet = .f.
			lcMsg = lcMsg + CHR(13) + "Campo [REFERÊNCIA FABRICANTE] é obrigatório para REVENDA..."
		ENDIF 
	ENDIF
	IF ISNULL(v_produtos_00.ID_MODELAGEM)
		llRet = .f.
		lcMsg = lcMsg + CHR(13) + "Campo [MODELAGEM] é obrigatório..."
	ENDIF
	
	** 0) valida campo ERP_MATERIA_PRIMA
	IF EMPTY(NVL(v_produtos_00.ERP_MATERIA_PRIMA,''))
		llRet = .f.
		lcMsg = lcMsg + CHR(13) + "Campo [MATERIA PRIMA] da Aba [Outros] é obrigatório..."
	ENDIF
		
	** 0) valida campo ERP_GRUPO_MERCADORIA 
	IF EMPTY(NVL(v_produtos_00.ERP_GRUPO_MERCADORIA,''))
		llRet = .f.
		lcMsg = lcMsg + CHR(13) + "Campo [GRUPO DE MERCADORIA] da Aba [Outros] é obrigatório..."
	ENDIF
		
	** 1) valida campo Categoria
	IF EMPTY(NVL(v_produtos_00.cod_categoria,''))
		llRet = .f.
		lcMsg = lcMsg + CHR(13) + "Campo [Categoria] é obrigatório..."
	ENDIF
	
	** 2) valida campo Subcategoria
	IF EMPTY(NVL(v_produtos_00.cod_subcategoria,''))
		llRet = .f.
		lcMsg = lcMsg + CHR(13) + "Campo [Subcategoria] é obrigatório..."
	ENDIF

	** 3) valida tabela de preços preeenchida (campo Preco1)
	SELECT v_produtos_00_precos
	SCAN 	
		IF NOT INLIST(ALLTRIM(v_produtos_00_precos.codigo_tab_preco),'02','05','37','CM','85')
		
			IF EMPTY(NVL(v_produtos_00_precos.Preco1,0))
				lcTabelas = lcTabelas + ALLTRIM(v_produtos_00_precos.codigo_tab_preco) +","			
			ENDIF
			
		ENDIF
		
	ENDSCAN
	GO top

	IF NOT EMPTY(lcTabelas)
		lcTabelas = LEFT(lcTabelas,LEN(lcTabelas)-1)
		lcMsg = lcMsg + CHR(13) + "Obrigatório informar preço nas tabela(s) "+lcTabelas+"..."
	ENDIF
	


 	IF  INLIST(o_002006.p_tool_status,'I')
  	
	    		
		IF	o_002006.lx_Form1.lx_PageFrame1.Page3.opt_Padrao.Value  !=  o_002006.pp_tipo_codigo_barra       
		    	lcMsg = lcMsg + CHR(13) + "O Código de Barras deve ser o padrão [OPÇÃO: "+ALLTRIM(PADR(INT(o_002006.pp_tipo_codigo_barra),2,' ' ))+"]"
	    ENDIF
	    
		    		
	endif			    		

	***
	* VALIDAÇÕES PROJETO CUPS - INICIO 15-ABR-2015
	*/
	
	****
	* obrigatório informar campo UNIDADE
	*/				
	IF EMPTY(NVL(v_produtos_00.UNIDADE,''))
		llRet = .f.
    	lcMsg = lcMsg + CHR(13) + "Obrigatório informar campo UNIDADE"
	ENDIF				
	
	IF EMPTY(NVL(v_produtos_00.tribut_origem,""))	
		llRet = .f.
    	lcMsg = lcMsg + CHR(13) + "Obrigatório informar campo ORIGEM"
	ENDIF



	IF !EMPTY(NVL(v_produtos_00.ERP_CUPS_SEGMENTO,''))
	
		IF INLIST(v_produtos_00.ERP_CUPS_SEGMENTO,'000156','000157') && ATACADO ou VAREJO/ATACADO
 
			IF RECCOUNT("V_PRODUTOS_00_CORES_MAT")>o_002006.PP_QTD_CORES_ATACADO
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Quantidade máxima de cores para segmento Atacado é "+ALLTRIM(TRANSFORM(o_002006.PP_QTD_CORES_ATACADO,"99"))
				**ELSE
				**WAIT WINDOW "OK - quantidade de cores adequada para o segmento"
			ENDIF
			
		ENDIF
		
		DO CASE
		CASE v_produtos_00.ERP_CUPS_SEGMENTO = '000155'	&& SOMENTE VAREJO
		
			IF ALLTRIM(v_produtos_00.tribut_origem) = '1'

				IF !ZAUTORIZA_PRODUTO()
					IF v_produtos_00.ENVIA_LOJA_ATACADO=.F.
						llRet = .f.
				    	lcMsg = lcMsg + CHR(13) + "Flag ENVIA_LOJA_ATACADO deve ser marcado para SEGMENTO VAREJO, pois origem é ESTRANGEIRA"
					ENDIF	
					
					****
					* obrigatório informar STYLE NUMBER para produtos de origem estrangeira, vai ter contrato {10-09-2015}
					*/				
					IF EMPTY(NVL(v_produtos_00.ERP_CUPS_STYLENUMBER,''))
						llRet = .f.
				    	lcMsg = lcMsg + CHR(13) + "Obrigatório informar campo STYLENUMBER para SEGMENTO ATACADO"
					ENDIF	
					
					****
					* obrigatório informar campo PESO
					*/				
					IF EMPTY(NVL(v_produtos_00.PESO,0))
						llRet = .f.
				    	lcMsg = lcMsg + CHR(13) + "Obrigatório informar campo PESO"
					ENDIF					
				ENDIF
												
			
			ELSE
			
				IF v_produtos_00.ENVIA_LOJA_ATACADO=.T.
					llRet = .f.
			    	lcMsg = lcMsg + CHR(13) + "Flag ENVIA_LOJA_ATACADO não pode ser marcado para SEGMENTO VAREJO"
				ENDIF		
				
			ENDIF
			
			IF v_produtos_00.ENVIA_LOJA_VAREJO=.F.
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Flag ENVIA_LOJA_VAREJO deve ser marcado para SEGMENTO VAREJO"
			ENDIF		
		
		CASE v_produtos_00.ERP_CUPS_SEGMENTO = '000156'	&& SOMENTE ATACADO
		
			IF v_produtos_00.ENVIA_LOJA_VAREJO=.T.
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Flag ENVIA_LOJA_VAREJO não pode ser marcado para SEGMENTO ATACADO"
			ENDIF		
			
			IF v_produtos_00.ENVIA_LOJA_ATACADO=.F.
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Flag ENVIA_LOJA_ATACADO deve ser marcado para SEGMENTO ATACADO"
			ENDIF		
		
			IF EMPTY(NVL(v_produtos_00.ERP_CUPS_STYLENUMBER,''))
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Obrigatório informar campo STYLENUMBER para SEGMENTO ATACADO"
			ENDIF

			****
			* obrigatório informar campo PESO
			*/				
			IF EMPTY(NVL(v_produtos_00.PESO,0))
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Obrigatório informar campo PESO"
			ENDIF				
			
		CASE INLIST(v_produtos_00.ERP_CUPS_SEGMENTO,'000156','000157')	&& ATACADO/VAREJO - AMBOS
		
			IF v_produtos_00.ENVIA_LOJA_VAREJO=.F.
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Flag ENVIA_LOJA_VAREJO deve ser marcado para SEGMENTO ATACADO/VAREJO"
			ENDIF		
			
			IF v_produtos_00.ENVIA_LOJA_ATACADO=.F.
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Flag ENVIA_LOJA_ATACADO deve ser marcado para SEGMENTO ATACADO/VAREJO"
			ENDIF		

			IF EMPTY(NVL(v_produtos_00.ERP_CUPS_STYLENUMBER,''))
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Obrigatório informar campo STYLENUMBER para SEGMENTO ATACADO"
			ENDIF
			
			****
			* obrigatório informar campo PESO
			*/				
			IF EMPTY(NVL(v_produtos_00.PESO,0))
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Obrigatório informar campo PESO"
			ENDIF				
			

		ENDCASE

		
	ELSE
	
		llRet = .f.
    	lcMsg = lcMsg + CHR(13) + "Obrigatório informar o campo SEGMENTAÇÃO..."
	
	ENDIF
	
	
	*** 
	* CAMPOS DA ABA IMPORTADO que são obrigatórios para Integrar com o Sistema IMPORT SYS
	*/
	IF llRet AND ALLTRIM(v_produtos_00.tribut_origem) = '1' 
		
		lcMsg = ""
		IF !ZAUTORIZA_PRODUTO()
			** PESO
			IF EMPTY(NVL(v_produtos_00.PESO,0))
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Obrigatório informar campo PESO"
			ENDIF		
			
			** STYLE NUMBER
			IF EMPTY(NVL(v_produtos_00.ERP_CUPS_STYLENUMBER,''))
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Obrigatório informar campo STYLENUMBER para SEGMENTO ATACADO"
			ENDIF	

			DIMENSION laDominio0[5,2]
			laDominio0[1,1]="PRODUTO"
			laDominio0[2,1]="CONSTRUCAO"
			laDominio0[3,1]="COMPRIMENTO"
			laDominio0[4,1]="FORRO"
			laDominio0[5,1]="COMPOSICAO"
			
			laDominio0[1,2]=NVL(v_produtos_00.ERP_CUPS_PRODUTO,"")
			laDominio0[2,2]=NVL(v_produtos_00.ERP_CUPS_CONTRUCAO,"")
			laDominio0[3,2]=NVL(v_produtos_00.ERP_CUPS_COMPRIMENTO,"")
			laDominio0[4,2]=NVL(v_produtos_00.ERP_CUPS_FORRO,"")
			laDominio0[5,2]=NVL(v_produtos_00.ERP_CUPS_COMPOSICAO,"")
			
			FOR iqq=1 TO 5
				IF EMPTY(laDominio0[iqq,2])
					llRet = .f.
					lcMsg = lcMsg + CHR(13) + "Obrigatório preencher o campo "+PROPER(laDominio0[iqq,1])+" na aba Importado" + CHR(13)
				ENDIF
			ENDFOR		
			
			** GRIFFE
			tcGriffe = ALLTRIM(NVL(v_produtos_00.GRIFFE,""))
			F_SELECT("select * from produtos_griffes where griffe = '"+tcGriffe+"'","tmpGriffe01")
			
			IF RECCOUNT("tmpGriffe01")=0
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Valor do campo GRIFFE não localizado"
			ENDIF	
			
			
			** LINHA
			tcLinha = ALLTRIM(NVL(v_produtos_00.LINHA,""))
			F_SELECT("select * from produtos_linhas where linha = '"+tcLinha+"'","tmpLinha01")
			
			IF RECCOUNT("tmpLinha01")=0
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Valor do campo LINHA não localizado"
			ENDIF	
			
			** GRADE
			tcGrade = ALLTRIM(NVL(v_produtos_00.GRADE,""))
			F_SELECT("select * from produtos_tamanhos where grade = '"+tcGrade+"'","tmpGrade01")
			
			IF RECCOUNT("tmpGrade01")=0
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Grade não localizada. Obrigatório selecionar um Tamanho/Grade"
			ENDIF	
			
			** SUPPLIER
			tcSupplier = ALLTRIM(NVL(v_produtos_00.ERP_CUPS_SUPPLIER,""))
			F_SELECT("select * from fornecedores where clifor = '"+tcSupplier+"'","tmpSupplier01")
			
			IF RECCOUNT("tmpSupplier01")=0
				llRet = .f.
		    	lcMsg = lcMsg + CHR(13) + "Fabricante/Supplier não localizado."
			ENDIF	
		ENDIF
						
	ENDIF
	
	
	
	*** 
	* Se estiver tudo OK, verifica se foram preenchidos as Descrições para uso na DI para produtos importados
	*/
	
	IF llRet AND ALLTRIM(v_produtos_00.tribut_origem) = '1'
		lcMsg = ""
		IF !ZAUTORIZA_PRODUTO()
			DIMENSION laDominio1[7,2]
			laDominio1[1,1]="GRIFFE"
			laDominio1[2,1]="LINHA"
			laDominio1[3,1]="PRODUTO"
			laDominio1[4,1]="CONSTRUCAO"
			laDominio1[5,1]="COMPRIMENTO"
			laDominio1[6,1]="FORRO"
			laDominio1[7,1]="COMPOSICAO"
			*
			laDominio1[1,2]=NVL(v_produtos_00.GRIFFE,"")
			laDominio1[2,2]=NVL(v_produtos_00.LINHA,"")
			laDominio1[3,2]=NVL(v_produtos_00.ERP_CUPS_PRODUTO,"")
			laDominio1[4,2]=NVL(v_produtos_00.ERP_CUPS_CONTRUCAO,"")
			laDominio1[5,2]=NVL(v_produtos_00.ERP_CUPS_COMPRIMENTO,"")
			laDominio1[6,2]=NVL(v_produtos_00.ERP_CUPS_FORRO,"")
			laDominio1[7,2]=NVL(v_produtos_00.ERP_CUPS_COMPOSICAO,"")
			
			FOR iqq=1 TO 7
				IF !zverifica_descricao_importado(laDominio1[iqq,1],laDominio1[iqq,2])
					llRet = .f.
					lcMsg = lcMsg + CHR(13) + "Obrigatório preencher o campo Descrição de Importado para "+laDominio1[iqq,1]+" = "+laDominio1[iqq,2] + CHR(13)
				ENDIF
			ENDFOR
		ENDIF
		
	ENDIF
	
	*\
	* VALIDAÇÕES PROJETO CUPS - FINAL 15-ABR-2015
	***

	
	 		
	SELECT (lnOldSelect)
	
	IF NOT EMPTY(lcMsg)
		MESSAGEBOX(lcMsg, 16,"Aviso")
	ELSE
		*** GERAÇÃO DO CÓDIGO DE BARRAS DO ATACADO
		*** SE ESTIVER COM O CAMPO ERP_CUPS_SEGMENTO VAZIO - GERA CODIGO DE BARRAS
		*** REGRA PARA GERAR O CÓDIGO
		* SEGMENTO SER ATACADO OU ATACADO/VAREJO
		* ORIGEM DO PRODUTO = 1 - ESTRANGEIRA
		*/
		IF INLIST(v_produtos_00.ERP_CUPS_SEGMENTO,'000156','000157') OR ALLTRIM(v_produtos_00.tribut_origem) = '1'
			IF EMPTY(NVL(v_produtos_00.ERP_CUPS_CODEBAR_REF,''))
				IF "CUPS01" $ SET( "ClassLib" )
					** Ok, Registry carregado
				ELSE
					SET CLASSLIB TO CUPS01.vcx ADDITIVE
				ENDIF

				objCups = CREATEOBJECT("funcoes_cups")
				objCups.sequencial_codebar_ref = F_SEQUENCIAIS("PRODUTOS.ERP_CUPS_CODEBAR_REF", .t.)
				llRet = objCups.calcula_dv_ean13()
				
				IF !llRet
					MESSAGEBOX(objCups.err_message,16,"Aviso")
				ELSE
					lcCodebar_ref = objCups.codebar_ref_dv
					REPLACE v_produtos_00.ERP_CUPS_CODEBAR_REF WITH lcCodebar_ref
					REPLACE v_produtos_00.ERP_CUPS_CODEBAR_PB  WITH "1"+lcCodebar_ref
					REPLACE v_produtos_00.ERP_CUPS_CODEBAR_CX  WITH "9"+lcCodebar_ref
				ENDIF
			ENDIF
			
		ENDIF

	ENDIF
		
	RETURN llRet
ENDFUNC
** FIM: 24-05-2013

FUNCTION zverifica_descricao_importado
	PARAMETERS tcDominio, tcValor
	LOCAL llOk as Boolean, lnArea as Integer, lcSQL as String
	lnArea = SELECT()
	llOk = .t.

	lcSQL = ""
	
	DO CASE
	CASE tcDominio = "GRIFFE"
		lcSQL = "SELECT ERP_CUPS_DESCRICAO_IMPORTACAO FROM PRODUTOS_GRIFFES WHERE GRIFFE = '"+ALLTRIM(tcValor)+"'"
	CASE tcDominio = "LINHA"
		lcSQL = "SELECT ERP_CUPS_DESCRICAO_IMPORTACAO FROM PRODUTOS_LINHAS WHERE LINHA = '"+ALLTRIM(tcValor)+"'"
	CASE INLIST(tcDominio,"PRODUTO","CONSTRUCAO","COMPRIMENTO","FORRO","COMPOSICAO")
		lcSQL = "SELECT ERP_CUPS_DESCRICAO_IMPORTACAO FROM CAEDU_LISTA_COMBO WHERE codigo = '"+ALLTRIM(tcValor)+"' and desc_dominio='"+tcDominio+"'"

	ENDCASE
	
	IF EMPTY(lcSQL)
		llOk = .f.
	ELSE
		f_select(lcSQL,"tmpDescImportado")
		
		** Se estiver vazio ou nulo, retorna False 
		IF EMPTY(NVL(tmpDescImportado.ERP_CUPS_DESCRICAO_IMPORTACAO,""))
			llOk = .f.
		ENDIF
		 
	ENDIF
	
	
	SELECT (lnArea)
	
	RETURN llOk
ENDFUNC


FUNCTION rbInputBox
	lparameters tcPrompt, tcTitle, txDefaultValue, tnLeft, tnTop, ;
		tcFormat, tcInputMask, tcPasswordChar
	private pcReturnValue
	pcReturnValue = txDefaultValue
	local oInputBox
	oInputBox = CreateObject("rbInputBox", tcPrompt, tcTitle, ;
		txDefaultValue, tnLeft, tnTop, ;
		tcFormat, tcInputMask, tcPasswordChar)
	oInputBox.Show()
	RETURN pcReturnValue


	**************************************************
	*-- Class:        rbinputbox
	*-- ParentClass:  form
	*-- BaseClass:    form
	*-- Time Stamp:   01/29/03 01:03:14 PM
	*
DEFINE CLASS rbinputbox AS form


	Height = 113
	Width = 318
	DoCreate = .T.
	AutoCenter = .T.
	Caption = "Input Box"
	ControlBox = .F.
	WindowType = 1
	Name = "frmInputBox"

	*-- empty value to return if Cancel is chosen; data type depends on data type of txValueIn
	xemptyvalue = .F.

	*-- the default value (if any)
	xdefaultvalue = .F.

	*-- the return value
	xreturnvalue = .F.


	ADD OBJECT lblinputbox AS label WITH ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Alignment = 1, ;
		Caption = "Enter the value", ;
		Height = 20, ;
		Left = 6, ;
		Top = 26, ;
		Width = 190, ;
		TabIndex = 1, ;
		Name = "lblInputBox"


	ADD OBJECT txtinputbox AS textbox WITH ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Century = 1, ;
		Height = 24, ;
		Left = 202, ;
		SelectOnEntry = .T., ;
		TabIndex = 2, ;
		Top = 22, ;
		Width = 110, ;
		Name = "txtInputBox"


	ADD OBJECT cmdok AS commandbutton WITH ;
		Top = 72, ;
		Left = 84, ;
		Height = 24, ;
		Width = 72, ;
		Caption = "OK", ;
		Default = .T., ;
		TabIndex = 3, ;
		Name = "cmdOK"


	ADD OBJECT cmdcancel AS commandbutton WITH ;
		Top = 72, ;
		Left = 172, ;
		Height = 24, ;
		Width = 72, ;
		Cancel = .T., ;
		Caption = "Cancel", ;
		TabIndex = 4, ;
		Name = "cmdCancel"


	PROCEDURE Unload
		with thisform
			if type(".xReturnValue") = "C"
				.xReturnValue = RTRIM( .xReturnValue)
			endif
			pcReturnValue = .xReturnValue
		endwith
	ENDPROC


	PROCEDURE Init
		lparameters tcPrompt, tcTitle, txDefaultValue, tnLeft, tnTop, ;
			tcFormat, tcInputMask, tcPasswordChar
		if type("tcPrompt") <> "C"
			tcPrompt = "Enter the value"
		endif
		if type("tcTitle") <> "C"
			tcTitle = "Input Box"
		endif
		if !( type("txDefaultValue") $ "CDNY")
			*	Valid input data types are C, D, N, and Y
			txDefaultValue = ""	&& default to character data type
		endif
		if type("tcFormat") <> "C"
			tcFormat = ""
		endif
		if type("tcInputMask") <> "C"
			tcInputMask = ""
		endif
		if type("tcPasswordChar") <> "C"
			tcPasswordChar = ""
		endif
		if len( alltrim( tcPasswordChar)) > 1
			tcPasswordChar = left( tcPasswordChar, 1)
		endif
		local llAutoCenter
		if pcount() < 5	&& Top and Left parameters were not passed
			tnLeft = 0
			tnTop = 0
		else	&& Top and left parameters were passed but may not be numeric
			if type("tnTop") = "N" and type("tnLeft") = "N"		&& both are numeric
				llAutoCenter = .F.
			else	&& one or both is not numeric, so AutoCenter the form
				tnLeft = 0
				tnTop = 0
				llAutoCenter = .T.
			endif
		endif

		with thisform
			.lblInputBox.caption = ALLTRIM( tcPrompt)
			.caption = ALLTRIM( tcTitle)
			.xDefaultValue = txDefaultValue
			.xReturnValue = .xDefaultValue
			.txtInputBox.value = .xDefaultValue
			.txtInputBox.format = ALLTRIM( tcFormat)
			.txtInputBox.InputMask = ALLTRIM( tcInputMask)
			.txtInputBox.PasswordChar = tcPasswordChar
			.Top = tnTop
			.Left = tnLeft
			.AutoCenter = llAutoCenter		&& Set AutoCenter last so it overrides Top and Left if .T.

			do case
				case type("txDefaultValue") = "D"
					.xEmptyValue = {}
				case type("txDefaultValue") = "N"
					.xEmptyValue = 0
				case type("txDefaultValue") = "Y"
					.xEmptyValue = $0
				otherwise
					.xEmptyValue = ""
			endcase
		endwith
	ENDPROC


	PROCEDURE cmdok.Click
		with thisform
			.xReturnValue = .txtInputBox.value
			.release()
		endwith
	ENDPROC


	PROCEDURE cmdcancel.Click
		*
		*	If Cancel was chosen, return the empty value of the correct data type.
		*
		with thisform
			.xReturnValue = .xEmptyValue
			.release()
		endwith
	ENDPROC


ENDDEFINE



*******************************	
*  Sandra Ono  -  27/05/2014
*******************************
FUNCTION rbInputBox3
	lparameters tcPrompt, tcTitle, txDefaultValue, tnLeft, tnTop, ;
		tcFormat, tcInputMask, tcPasswordChar
	private pcReturnValue
	pcReturnValue = txDefaultValue
	local oInputBox
	oInputBox = CreateObject("rbInputBox3", tcPrompt, tcTitle, ;
		txDefaultValue, tnLeft, tnTop, ;
		tcFormat, tcInputMask, tcPasswordChar)
	oInputBox.Show()
	RETURN pcReturnValue


	**************************************************
	*-- Class:        rbinputbox3
	*-- ParentClass:  form
	*-- BaseClass:    form
	*-- Time Stamp:   01/29/03 01:03:14 PM
	*   Sandra Ono  -  27/05/2014
	*
	**************************************************

DEFINE CLASS cPageImportado as Page

	PROCEDURE Activate
		thisform.refresh
	ENDPROC
	
ENDDEFINE

	
DEFINE CLASS rbinputbox3 AS form


	Height = 113
	Width = 318
	DoCreate = .T.
	AutoCenter = .T.
	Caption = "Input Box"
	ControlBox = .F.
	WindowType = 1
	Name = "frmInputBox"

	*-- empty value to return if Cancel is chosen; data type depends on data type of txValueIn
	xemptyvalue = .F.

	*-- the default value (if any)
	xdefaultvalue = .F.

	*-- the return value
	xreturnvalue = .F.


	ADD OBJECT lblinputbox AS label WITH ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Alignment = 1, ;
		Caption = "Enter the value", ;
		Height = 20, ;
		Left = 6, ;
		Top = 26, ;
		Width = 190, ;
		TabIndex = 1, ;
		Name = "lblInputBox"


	ADD OBJECT txtinputbox AS textbox WITH ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Century = 1, ;
		Height = 24, ;
		Left = 202, ;
		SelectOnEntry = .T., ;
		TabIndex = 2, ;
		Top = 22, ;
		Width = 110, ;
		Name = "txtInputBox"
		value = 000000.00


	ADD OBJECT cmdok AS commandbutton WITH ;
		Top = 72, ;
		Left = 84, ;
		Height = 24, ;
		Width = 72, ;
		Caption = "OK", ;
		Default = .T., ;
		TabIndex = 3, ;
		Name = "cmdOK"


	ADD OBJECT cmdcancel AS commandbutton WITH ;
		Top = 72, ;
		Left = 172, ;
		Height = 24, ;
		Width = 72, ;
		Cancel = .T., ;
		Caption = "Cancel", ;
		TabIndex = 4, ;
		Name = "cmdCancel"


	PROCEDURE Unload
		with thisform
			if type(".xReturnValue") = "C"
				.xReturnValue = RTRIM( .xReturnValue)
			endif
			pcReturnValue = .xReturnValue
		endwith
	ENDPROC


	PROCEDURE Init
		lparameters tcPrompt, tcTitle, txDefaultValue, tnLeft, tnTop, ;
			tcFormat, tcInputMask, tcPasswordChar
		if type("tcPrompt") <> "C"
			tcPrompt = "Enter the value"
		endif
		if type("tcTitle") <> "C"
			tcTitle = "Input Box"
		endif
		if !( type("txDefaultValue") $ "CDNY")
			*	Valid input data types are C, D, N, and Y
			txDefaultValue = ""	&& default to character data type
		endif
		if type("tcFormat") <> "C"
			tcFormat = ""
		endif
		if type("tcInputMask") <> "C"
			tcInputMask = ""
		endif
		if type("tcPasswordChar") <> "C"
			tcPasswordChar = ""
		endif
		if len( alltrim( tcPasswordChar)) > 1
			tcPasswordChar = left( tcPasswordChar, 1)
		endif
		local llAutoCenter
		if pcount() < 5	&& Top and Left parameters were not passed
			tnLeft = 0
			tnTop = 0
		else	&& Top and left parameters were passed but may not be numeric
			if type("tnTop") = "N" and type("tnLeft") = "N"		&& both are numeric
				llAutoCenter = .F.
			else	&& one or both is not numeric, so AutoCenter the form
				tnLeft = 0
				tnTop = 0
				llAutoCenter = .T.
			endif
		endif

		with thisform
			.lblInputBox.caption = ALLTRIM( tcPrompt)
			.caption = ALLTRIM( tcTitle)
			.xDefaultValue = txDefaultValue
			.xReturnValue = .xDefaultValue
			.txtInputBox.value = .xDefaultValue
			.txtInputBox.format = ALLTRIM( tcFormat)
			.txtInputBox.InputMask = ALLTRIM( tcInputMask)
			.txtInputBox.PasswordChar = tcPasswordChar
			.Top = tnTop
			.Left = tnLeft
			.AutoCenter = llAutoCenter		&& Set AutoCenter last so it overrides Top and Left if .T.

			do case
				case type("txDefaultValue") = "D"
					.xEmptyValue = {}
				case type("txDefaultValue") = "N"
					.xEmptyValue = 0.00
				case type("txDefaultValue") = "Y"
					.xEmptyValue = $0
				otherwise
					.xEmptyValue = ""
			endcase
		endwith
	ENDPROC


	PROCEDURE cmdok.Click
		with thisform
*!*		SET STEP ON 	
			.xReturnValue = .txtInputBox.value
			
*!*				TEXT TO lc_sql noshow
*!*					select distinct tab.CODIGO_TAB_PRECO, tab.tabela
*!*						from
*!*							TABELAS_PRECO tab
*!*						where tab.INATIVO  = 0
*!*					ORDER BY 1			
*!*	            ENDTEXT
*!*	             
*!*	            f_select(lc_sql,"x_tabPreco" ) 
*!*				
			
*****************>>>> ÉÉÉÉÉÉÉÉÉ DONA FOCA!!! QUE PREZEPADA HEIN! 						
*!*				TEXT TO lc_sql noshow
*!*					select distinct tab.CODIGO_TAB_PRECO, tab.tabela,  prd.PRODUTO, prd.PRECO1, prd.PRECO2,prd.PRECO3,prd.PRECO4, prd.ULT_ATUALIZACAO
*!*						from
*!*							PRODUTOS_PRECOS prd 
*!*					     LEFT JOIN TABELAS_PRECO tab
*!*					         ON PRD.CODIGO_TAB_PRECO = TAB.CODIGO_TAB_PRECO 
*!*								where prd.PRODUTO in
*!*								 ( select top 1 PRODUTO from PRODUTOS where DATA_CADASTRAMENTO  >= DATEADD(DAY,-1, GETDATE() ) )
*!*								and tab.INATIVO  = 0
*!*					ORDER BY 1			
*!*	            ENDTEXT

			*** CORREÇÃO DA QUERY -> PAULO DEVIDE -> 22-07-2015	
			*** CORREÇÃO DA QUERY -> PAULO DEVIDE -> 24-09-2018  (inclusão da tabela 85 na lista de exceção)
			TEXT TO lc_sql  NOSHOW TEXTMERGE
				select 
				   CODIGO_TAB_PRECO, tabela,  null as PRODUTO, cast(0 as numeric(14,2)) as PRECO1,  
				   	cast(0 as numeric(14,2)) as PRECO2, cast(0 as numeric(14,2)) as PRECO3, cast(0 as numeric(14,2)) as PRECO4, 
				   	getdate() as ULT_ATUALIZACAO
				from 
				  TABELAS_PRECO
				where
				  CODIGO_TAB_PRECO not in ('AT','37','04','CM','CL','VA') AND INATIVO=0
			ENDTEXT
             
            f_select(lc_sql,"Preco_x" ) 
           
           IF RECCOUNT('Preco_x') < 1
*!*						TEXT TO lc_sql noshow
*!*							select distinct tab.CODIGO_TAB_PRECO, tab.tabela,  prd.PRODUTO, prd.PRECO1, prd.PRECO2,prd.PRECO3,prd.PRECO4, prd.ULT_ATUALIZACAO
*!*								from
*!*									PRODUTOS_PRECOS prd 
*!*							     LEFT JOIN TABELAS_PRECO tab
*!*							         ON PRD.CODIGO_TAB_PRECO = TAB.CODIGO_TAB_PRECO 
*!*										where prd.PRODUTO = '51020859'
*!*										and tab.INATIVO  = 0
*!*							ORDER BY 1			
*!*			            ENDTEXT
			*** CORREÇÃO DA QUERY -> PAULO DEVIDE -> 24-09-2018  (inclusão da tabela 85 na lista de exceção)	
			TEXT TO lc_sql  NOSHOW TEXTMERGE
				select 
				   CODIGO_TAB_PRECO, tabela,  null as PRODUTO, cast(0 as numeric(14,2)) as PRECO1,  
				   	cast(0 as numeric(14,2)) as PRECO2, cast(0 as numeric(14,2)) as PRECO3, cast(0 as numeric(14,2)) as PRECO4, 
				   	getdate() as ULT_ATUALIZACAO
				from 
				  TABELAS_PRECO
				where
				  CODIGO_TAB_PRECO not in ('AT','37','04','CM','CL','VA') AND INATIVO=0
			ENDTEXT
					             
		            f_select(lc_sql,"Preco_x" )            
           
           
           
           ENDIF
           
            
                     
            lnValor = VAL(.xReturnValue) 
            
            
            
            SELECT Preco_x
            SCAN
            
                 IF !INLIST(Preco_x.codigo_tab_preco,"00","02","37" ,"CM","85")
                 
                    SELECT V_PRODUTOS_00_PRECOS
                    LOCATE FOR ALLTRIM(produto) = ALLTRIM(V_PRODUTOS_00.PRODUTO) and;
                              ALLTRIM(CODIGO_TAB_PRECO) = ALLTRIM(Preco_x.codigo_tab_preco)
                    
                    IF !FOUND()
                    
			            insert into V_PRODUTOS_00_PRECOS( CODIGO_TAB_PRECO, TABELA, PRODUTO, PRECO1, PRECO2,PRECO3,PRECO4, ULT_ATUALIZACAO, STATUS, INATIVO )  values;
			            (Preco_x.CODIGO_TAB_PRECO, Preco_x.TABELA, V_PRODUTOS_00.PRODUTO, lnValor ,0,0,0, DATETIME(), 'A', .F.)
			            
*!*				            SELECT x_tabPreco
*!*				            LOCATE FOR ALLTRIM(CODIGO_TAB_PRECO) =  ALLTRIM(Preco_x.CODIGO_TAB_PRECO)
*!*				            IF FOUND()
*!*				               replace tabela WITH x_tabPreco.tabela in V_PRODUTOS_00_PRECOS
*!*				            ENDIF
			            
			            
			            
		            ENDIF
		            
		         ELSE
		         
                    SELECT V_PRODUTOS_00_PRECOS
                    LOCATE FOR ALLTRIM(produto) = ALLTRIM(V_PRODUTOS_00.PRODUTO) and;
                              ALLTRIM(CODIGO_TAB_PRECO) = ALLTRIM(Preco_x.codigo_tab_preco)
                    
                    IF !FOUND()
			            insert into V_PRODUTOS_00_PRECOS( CODIGO_TAB_PRECO, TABELA, PRODUTO, PRECO1, PRECO2,PRECO3,PRECO4, ULT_ATUALIZACAO, STATUS, INATIVO )  values;
			            (Preco_x.CODIGO_TAB_PRECO, Preco_x.TABELA, V_PRODUTOS_00.PRODUTO, 0.00 ,0,0,0, DATETIME(), 'A', .F.)
		            ENDIF
		         	
		            
		         Endif   
		         
		         SELECT Preco_x
            Endscan          
									
			SELECT V_PRODUTOS_00_PRECOS 
			****replace ALL preco1 WITH VAL(.xReturnValue) FOR !INLIST(codigo_tab_preco,"00","02","37" ,"CM","05")
			GO TOP
			
			o_002006.lx_FORM1.lx_pageframe1.page5.lX_GRID_FILHA1.REFRESH()
			
			
			.release()
		endwith
	ENDPROC


	PROCEDURE cmdcancel.Click
		*
		*	If Cancel was chosen, return the empty value of the correct data type.
		*
		with thisform
		
			.xReturnValue = .xEmptyValue
			
			.release()
		endwith
	ENDPROC


ENDDEFINE
*
*-- EndDefine: btn_exp
**************************************************

FUNCTION ZAUTORIZA_PRODUTO
	lnArea = SELECT()
	SELECT * FROM CURPROPPRODUTOS WITH (BUFFERING=.T.) ;
		WHERE ALLTRIM(PROPRIEDADE) = "00078" ;
		INTO CURSOR tmp_autoriza
	llRet = UPPER(ALLTRIM(NVL(tmp_autoriza.valor_propriedade,"")))=="SIM"		
	SELECT (lnArea)
	IF llRet
		WAIT WINDOW NOWAIT "Autorização para Transferência Atacado foi liberada!"
	ENDIF
	
	RETURN llRet
ENDFUNC


FUNCTION ZVALIDA_SENHA2(tcCargo, tcMensagem) 
	IF PCOUNT()<2
		tcMensagem=""
	ENDIF
	
*!*		IF UPPER(ALLTRIM(SYS(0))) = "NOTE-JUNIOR # ROBERTO"
*!*			MESSAGEBOX(tcMensagem+CHR(13)+"Senha para NOTE-JUNIOR # ROBERTO está Ok!",64,"Aviso")
*!*			RETURN .t.
*!*		ENDIF
	
	PUBLIC frmLoginWindows
	PUBLIC gcLogin, gcPwd, llOk_ad
	
	llOk_ad = .f.
	gcLogin = ""
	gcPwd = ""
	
	IF EMPTY(NVL(tcMensagem,""))
		tcMensagem = "..."
	ENDIF
	
	frmLoginWindows = CreateObject ("TformLoginWindows2")
	frmLoginWindows.Caption = frmLoginWindows.Caption + "["+tcCargo+"]"
	frmLoginWindows.lblMensagem.Caption = SUBSTR(ALLTRIM(tcMensagem),1,250)	
	frmLoginWindows.show(1)						

	IF llOk_ad
		
		lcUsuario = "CCP\"+ALLTRIM(UPPER(gcLogin))
		
		IF UPPER(tcCargo)="DIRETOR"
			TEXT TO lcsql NOSHOW TEXTMERGE
				  SELECT par.usuario FROM  PARAMETROS_USERS par
			    	  WHERE parametro like 'PALMA_DIRETOR_CPA_ENT'
			 		     	  and usuario = ?lcUsuario
			ENDTEXT

			If Used("x_Diretor")
				Use In x_Diretor
			Endif

			f_select(lcsql,"x_Diretor")
			
			If Reccount("x_Diretor") = 0
				Messagebox("Usuario sem permissão de [diretor] p/ liberar alteração!",16,"Avisos")
				Return .F.
			ELSE
				WAIT WINDOW "Validado!" TIMEOUT 1	
			ENDIF
		ENDIF
		
		IF UPPER(tcCargo)="GERENTE"
			TEXT TO lcsql NOSHOW TEXTMERGE
				  SELECT par.usuario FROM  PARAMETROS_USERS par
			    	  WHERE parametro like 'PALMA_GERENTE_CPA_ENT'
			 		     	  and usuario = ?lcUsuario
			ENDTEXT

			If Used("x_Gerente")
				Use In x_Gerente
			Endif

			f_select(lcsql,"x_Gerente")
			
			If Reccount("x_Gerente") = 0
				Messagebox("Usuario sem permissão de [GERENTE] p/ liberar alteração!",16,"Avisos")
				Return .F.
			ELSE
				WAIT WINDOW "Validado!" TIMEOUT 1	
			ENDIF
		ENDIF

		IF UPPER(tcCargo)="TABPRECO"
			TEXT TO lcsql NOSHOW TEXTMERGE
				  SELECT par.usuario, par.VALOR_ATUAL_USER FROM  PARAMETROS_USERS par
			    	  WHERE parametro like 'PALMA_LIBERA_TABPRECO'
			 		     	  and usuario = ?lcUsuario
			ENDTEXT

			If Used("x_Tabpreco")
				Use In x_Tabpreco
			Endif

			f_select(lcsql,"x_Tabpreco")
			
			If Reccount("x_Tabpreco") = 0
				Messagebox("Usuario sem permissão para liberar esta alteração!",16,"Avisos")
				Return .F.
			ELSE
				blnAcesso = CAST(x_Tabpreco.valor_atual_user as L)

				IF blnAcesso
					WAIT WINDOW "Validado!" TIMEOUT 1	
				ELSE
					Messagebox("Usuario sem permissão para liberar esta alteração!",16,"Avisos")
					RETURN .F.
				ENDIF
						
			ENDIF
		ENDIF

		RETURN .T.
	ELSE
		RETURN .f.
	ENDIF

		
	
ENDFUNC


DEFINE CLASS TformLoginWindows2 As Form

	Width = 350
	Height = 380
	AutoCenter = .T.
	Windowtype = 1
	AlwaysOnTop = .t.
	Caption = "Login e Senha da Rede Windows - "

	gcLogin = ""
	gcPwd = ""

	ADD OBJECT lblLogin as Label WITH;
		Width=200, Height=25, Left=20, Top=35, Caption = "Login"
	
	ADD OBJECT lblSenha as Label WITH;
		Width=200, Height=25, Left=20, Top=65, Caption = "Password"

	ADD OBJECT txtLogin as Textbox WITH;
		Width=200, Height=25, Left=100, Top=30, controlsource = "gcLogin"
	
	ADD OBJECT txtSenha as Textbox WITH;
		Width=200, Height=25, Left=100, Top=60, controlsource = "gcPwd", Passwordchar = "*"

	ADD OBJECT cmd1 As CommandButton WITH;
		Width=60, Height=25, Left=218, Top=350, ;
		Caption="Cancel" 
		
	ADD OBJECT cmd2 As CommandButton WITH;
		Width=60, Height=25, Left=284, Top=350, ;
		Caption="Ok", Default=.T.

	ADD OBJECT lblMensagem as Label WITH;
		Width=300, Height=200, Left=10, Top=90, Caption = "", Autosize = .f., Wordwrap = .T.

	PROCEDURE init
		=CAPSLOCK(.F.)
		WAIT WINDOW "CAPSLOCK is off" TIMEOUT 0.5		
	ENDPROC
	
	PROCEDURE cmd1.Click
		ThisForm.Release
	ENDPROC

	PROCEDURE cmd2.Click
		llOk_ad = zvalida_login2(gcLogin, gcPwd)
		IF llOk_ad
			MESSAGEBOX("Login Autenticado com sucesso!",64,"Aviso")
		ELSE
			MESSAGEBOX("Falha na Autenticação do Login!",64,"Aviso")
		ENDIF
		
		ThisForm.Release
	ENDPROC
	
ENDDEFINE

***
* PAULO DEVIDE - 12-NOV-2014
* OBJETIVO: VALIDA CONTRA O Active Directory (AD) do Windows, se o Login e a Senha
* 			informado pelo usuário está correto.
*/
FUNCTION zvalida_login2
***********************
PARAMETERS tcLogin, tcPwd
DSODomaine = GetObject("LDAP:")
STRUSER=ALLTRIM(tcLogin)
STRCLAVE=ALLTRIM(tcPwd)
STRDOMAIN="CCP"
ADS_SECURE_AUTHENTICATION=1

TRY 

	DSOContainer = DSODomaine.OpenDSObject("LDAP://"+STRDOMAIN,STRUSER,STRCLAVE,ADS_SECURE_AUTHENTICATION)
	llOk = .t.

	
CATCH TO err
	*MESSAGEBOX(err.message,16,"Aviso")
	llOk = .f.
	
	
ENDTRY

RETURN llOk
ENDFUNC

** Page de objetos de Pedido de Compras
DEFINE CLASS cPagePedido as Page

	caption = "Pedido"
	PROCEDURE Activate
*!*			this.cboPersonagem1.requery() 
*!*			this.cboModelagem1.requery()
*!*			this.cboModelagem21.requery()
*!*			this.cboGrupoMercadoria1.requery() 

		thisform.refresh
	ENDPROC
	
ENDDEFINE

** Page de objetos de Importação
DEFINE CLASS cPageOutros as Page

	caption = "Outros"
	PROCEDURE Activate
		this.cboPersonagem1.requery() 
		this.cboModelagem1.requery()
		this.cboModelagem21.requery()
		this.cboGrupoMercadoria1.requery() 

		thisform.refresh
	ENDPROC
	
ENDDEFINE

** Page de objetos de Ficha Tecnica
DEFINE CLASS cpgFichaTec as Page

	caption = "Ficha Técnica"
	PROCEDURE Activate
*!*			this.cboPersonagem1.requery() 
*!*			this.cboModelagem1.requery()
*!*			this.cboModelagem21.requery()
*!*			this.cboGrupoMercadoria1.requery() 

		thisform.refresh
	ENDPROC
	
ENDDEFINE


** Page de objetos E-commerce
DEFINE CLASS cpgEcomm as Page

	caption = "E-commerce"
	PROCEDURE Activate
*!*			this.cboPersonagem1.requery() 
*!*			this.cboModelagem1.requery()
*!*			this.cboModelagem21.requery()
*!*			this.cboGrupoMercadoria1.requery() 

		thisform.refresh
	ENDPROC
	
ENDDEFINE

DEFINE CLASS lblErp_desc_licenciado AS Label
	Autosize = .t.
	Left = 20
	Top = 45
	Caption = "Licenciador"
	Name = "lblErp_desc_licenciado1"
	BackStyle= 0
ENDDEFINE

** CAMPO PARA INFORMAR TOTAL QTDE A DISTRIBUIR DO PEDIDO
DEFINE CLASS txtErp_desc_licenciado AS lx_textbox_base
	Height = 21
	Left = 90
	Top = 45
	Width = 240
	ReadOnly = .F.
	Name = "txtErp_desc_licenciado1"
	ControlSource = "V_PRODUTOS_00.Erp_desc_licenciado"
	*p_tipo_dado = "EDITA"

	PROCEDURE when
		IF this.Parent.chk_licenciado1.value = .F.
			WAIT WINDOW NOWAIT "Marque a opção Licenciado para editar este campo..."
			RETURN .F. 
		ENDIF
	ENDPROC
ENDDEFINE

DEFINE CLASS lblErp_tema_licenciado AS Label
	Autosize = .t.
	Left = 20
	Top = 75
	Caption = "Personagem"
	Name = "lblErp_tema_licenciado1"
	BackStyle= 0
ENDDEFINE

DEFINE CLASS lblModelagem AS Label
	Autosize = .t.
	Left = 20
	Top = 105
	Caption = "Modelagem"
	Name = "lblModelagem"
	BackStyle= 0
ENDDEFINE

** CAMPO PARA INFORMAR TOTAL QTDE A DISTRIBUIR DO PEDIDO
DEFINE CLASS txtErp_tema_licenciado AS lx_textbox_base
	Height = 21
	Left = 90
	Top = 75
	Width = 240
	ReadOnly = .F.
	Name = "txtErp_tema_licenciado1"
	ControlSource = "V_PRODUTOS_00.Erp_tema_licenciado"
	*p_tipo_dado = "EDITA"

	PROCEDURE when
		IF this.Parent.chk_licenciado1.value = .F.
			WAIT WINDOW NOWAIT "Marque a opção Licenciado para editar este campo..."
			RETURN .F. 
		ENDIF
		
	ENDPROC
ENDDEFINE

** 08-nov-16 checkbox licenciado
DEFINE CLASS chk_licenciado as checkbox
	caption = 'Licenciado'
	autosize = .T.
	WIDTH = 192
	top = 15
	left = 20
	HEIGHT =  27
	enabled = .t.
	controlsource = "V_PRODUTOS_00.ERP_LICENCIADO"
	visible  = .t.
	backstyle = 0
	**backcolor =  RGB(64,128,128)

	PROCEDURE refresh
		** Inclusão/Alteração/Exclusão/Tela (L)impa/(P)esquisa Feita!
		this.enabled = INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L")	
	ENDPROC

	PROCEDURE valid
		IF !NVL(V_PRODUTOS_00.ERP_LICENCIADO,.f.)
			
			replace V_PRODUTOS_00.Erp_desc_licenciado WITH ""
			replace V_PRODUTOS_00.ERP_TEMA_LICENCIADO WITH ""
			this.Parent.refresh
			
		ENDIF
		
	ENDPROC
			
ENDDEFINE
** 08-nov-16 checkbox licenciado

** 12-jan-17 - mudou para combobox
DEFINE CLASS cboLicenciador as lx_ComboBox
	Height = 21
	Left = 130
	Top = 45
	Width = 240
	BoundColumn = 1
	RowSourceType = 3
	RowSource = ZZ_COMBO_LICENCIADOR &&[F_SELECT("SELECT DESC_LIC FROM CAEDU_LICENCIADOR ORDER BY DESC_LIC","V_CBOLIC01")]
	ControlSource = "V_PRODUTOS_00.Erp_desc_licenciado"
	BoundTo = .T.
	Style = 2
	Name = "cboLicenciador"	
	
	PROCEDURE when
		IF !NVL(V_PRODUTOS_00.ERP_LICENCIADO,.f.)
			WAIT WINDOW "Marque o check Licenciado "+CHR(13)+"para selecionar uma opção!" TIMEOUT 3
			RETURN .f.
		ENDIF
		RETURN .t.
	ENDPROC
	
	PROCEDURE valid
		this.Parent.cboPersonagem1.requery()
	ENDPROC
	
ENDDEFINE

**
DEFINE CLASS cboPersonagem as lx_ComboBox
	Height = 21
	Left = 130
	Top = 75
	Width = 240
	BoundColumn = 1
	RowSourceType = 3
	RowSource = ZZ_COMBO_PERSONAGEM &&[F_SELECT("SELECT DESC_PERSONAGEM FROM CAEDU_PERSONAGEM WHERE DESC_LIC = ?V_PRODUTOS_00.Erp_desc_licenciado","V_CBOPRS01")]
	ControlSource = "V_PRODUTOS_00.ERP_TEMA_LICENCIADO"
	BoundTo = .T.
	Style = 2
	Name = "cboPersonagem"	

	PROCEDURE when
		IF !NVL(V_PRODUTOS_00.ERP_LICENCIADO,.f.)
			WAIT WINDOW "Marque o check Licenciado "+CHR(13)+"para selecionar uma opção!" TIMEOUT 3
			RETURN .f.
		ENDIF
		RETURN .t.
	ENDPROC

ENDDEFINE

DEFINE CLASS cboModelagem as lx_ComboBox
	Height = 21
	Left = 130
	Top = 105
	Width = 240
	BoundColumn = 2
	RowSourceType = 3
	RowSource = ZZ_COMBO_MODELAGEM 
	ControlSource = "V_PRODUTOS_00.ID_MODELAGEM"
	BoundTo = .T.
	Style = 2
	Name = "cboModelagem"	
	
*!*		PROCEDURE valid
*!*			WAIT WINDOW this.Value
*!*		ENDPROC
	
ENDDEFINE

DEFINE CLASS cboModelagem2 as lx_ComboBox
	Height = 21
	Left = 130
	Top = 135
	Width = 240
	BoundColumn = 2
	RowSourceType = 3
	RowSource = ZZ_COMBO_MODELAGEM 
	ControlSource = "V_PRODUTOS_00.ID_MODELAGEM2"
	BoundTo = .T.
	Style = 2
	Name = "cboModelagem2"	
	
*!*		PROCEDURE valid
*!*			WAIT WINDOW this.Value
*!*		ENDPROC
	
ENDDEFINE

DEFINE CLASS cboGrupoMercadoria as lx_ComboBox
	Height = 21
	Left = 130
	Top = 195
	Width = 280
	BoundColumn = 1
	RowSourceType = 3
	RowSource = ZZ_COMBO_GRUPO_MERCADORIA
	ControlSource = "V_PRODUTOS_00.ERP_GRUPO_MERCADORIA"
	BoundTo = .T.
	Style = 2
	Name = "cboGrupoMercadoria"	
	
*!*		PROCEDURE valid
*!*			WAIT WINDOW this.Value
*!*		ENDPROC
	
ENDDEFINE


DEFINE CLASS cboTipoetq as lx_ComboBox
	Height = 21
	Left = 130
	Top = 225
	Width = 280
	columnwidths = "240,70"
	BoundColumn = 2
	RowSourceType = 3
	RowSource = [F_SELECT("SELECT descricao,CODIGO FROM CAEDU_LISTA_COMBO where id_dominio='015' ORDER BY descricao","CBO_TIPOETQ")]
	ControlSource = "V_PRODUTOS_00.ERP_TIPO_ETIQUETA"
	BoundTo = .T.
	Style = 2
	specialeffect = 1
	Name = "cboTipoetq"	

	procedure refresh
		** Inclusão/Alteração/Exclusão/Tela (L)impa/(P)esquisa Feita!
		this.enabled = INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L")
	endproc	
	
	procedure rightclick
		this.requery()
	endproc	
	
*!*		PROCEDURE valid
*!*			WAIT WINDOW this.Value
*!*		ENDPROC
	
ENDDEFINE

DEFINE CLASS cboMateriaPrima as lx_ComboBox
	Height = 21
	Left = 130
	Top = 255
	Width = 280
	columnwidths = "240,70"
	BoundColumn = 2
	RowSourceType = 3
	RowSource = [F_SELECT("SELECT descricao,CODIGO FROM CAEDU_LISTA_COMBO where id_dominio='020' ORDER BY descricao","CBO_MATPRIMA")]
	ControlSource = "V_PRODUTOS_00.ERP_MATERIA_PRIMA"
	BoundTo = .T.
	Style = 2
	specialeffect = 1
	Name = "cboMateriaPrima"	

	procedure refresh
		** Inclusão/Alteração/Exclusão/Tela (L)impa/(P)esquisa Feita!
		this.enabled = INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L")
	endproc	
	
	procedure rightclick
		this.requery()
	endproc	
	
*!*		PROCEDURE valid
*!*			WAIT WINDOW this.Value
*!*		ENDPROC
	
ENDDEFINE

DEFINE CLASS tv_ecomm_marca as lx_textbox_valida
	*lx_textbox_valida
	top = 30
	left = 480
	width = 180
	ControlSource = "v_Produtos_00.ERP_ECOMM_DESC_MARCA"
	Name = "tv_ecomm_marca"
	NullDisplay = "..."
	p_tipo_dado = "EDITA"
	p_valida_coluna = "DESCRICAO"
	p_valida_coluna_tabela = "CAEDU_LISTA_COMBO"
	p_valida_colunas_incluir = "CODIGO"
	p_valida_replace = "ERP_ECOMM_COD_MARCA With Tabela_Validacao.CODIGO"
	p_valida_replace_em_limpa = .t.
	p_valida_where = " AND CAEDU_LISTA_COMBO.id_dominio = '024' "
ENDDEFINE

DEFINE CLASS tv_ft_marca as lx_textbox_valida
	*lx_textbox_valida
	top = 30
	left = 100
	width = 180
	ControlSource = "v_Produtos_00.ERP_FT_DESC_MARCA"
	Name = "tv_ft_marca"
	NullDisplay = "..."
	p_tipo_dado = "EDITA"
	p_valida_coluna = "DESCRICAO"
	p_valida_coluna_tabela = "CGP_FICHA_TECNICA_ITENS"
	p_valida_colunas_incluir = "CODIGO"
	p_valida_replace = "ERP_FT_MARCA With Tabela_Validacao.CODIGO"
	p_valida_replace_em_limpa = .t.
	p_valida_where = " AND CGP_FICHA_TECNICA_ITENS.CODIGO_FT = '0001' "
ENDDEFINE

DEFINE CLASS tv_ft_repeat as lx_textbox_valida
	*lx_textbox_valida
	top = 60
	left = 100
	width = 180
	ControlSource = "v_Produtos_00.ERP_FT_DESC_REPEAT"
	Name = "tv_ft_repeat"
	NullDisplay = "..."
	p_tipo_dado = "EDITA"
	p_valida_coluna = "DESCRICAO"
	p_valida_coluna_tabela = "CGP_FICHA_TECNICA_ITENS"
	p_valida_colunas_incluir = "CODIGO"
	p_valida_replace = "ERP_FT_REPEAT With Tabela_Validacao.CODIGO"
	p_valida_replace_em_limpa = .t.
	p_valida_where = " AND CGP_FICHA_TECNICA_ITENS.CODIGO_FT = '0002' "
ENDDEFINE

DEFINE CLASS tv_ft_estrutura as lx_textbox_valida
	*lx_textbox_valida
	top = 90
	left = 100
	width = 180
	ControlSource = "v_Produtos_00.ERP_FT_DESC_ESTRUTURA"
	Name = "tv_ft_estrutura"
	NullDisplay = "..."
	p_tipo_dado = "EDITA"
	p_valida_coluna = "DESCRICAO"
	p_valida_coluna_tabela = "CGP_FICHA_TECNICA_ITENS"
	p_valida_colunas_incluir = "CODIGO"
	p_valida_replace = "ERP_FT_ESTRUTURA With Tabela_Validacao.CODIGO"
	p_valida_replace_em_limpa = .t.
	p_valida_where = " AND CGP_FICHA_TECNICA_ITENS.CODIGO_FT = '0003' "
ENDDEFINE

DEFINE CLASS tv_ft_materia_prima as lx_textbox_valida
	*lx_textbox_valida
	top = 120
	left = 100
	width = 180
	ControlSource = "v_Produtos_00.ERP_FT_DESC_MATERIA_PRIMA"
	Name = "tv_ft_materia_prima"
	NullDisplay = "..."
	p_tipo_dado = "EDITA"
	p_valida_coluna = "DESCRICAO"
	p_valida_coluna_tabela = "CGP_FICHA_TECNICA_ITENS"
	p_valida_colunas_incluir = "CODIGO"
	p_valida_replace = "ERP_FT_MATERIA_PRIMA With Tabela_Validacao.CODIGO"
	p_valida_replace_em_limpa = .t.
	p_valida_where = " AND CGP_FICHA_TECNICA_ITENS.CODIGO_FT = '0004' "
ENDDEFINE

DEFINE CLASS tv_ft_composicao as lx_textbox_valida
	*lx_textbox_valida
	top = 150
	left = 100
	width = 180
	ControlSource = "v_Produtos_00.ERP_FT_DESC_COMPOSICAO"
	Name = "tv_ft_composicao"
	NullDisplay = "..."
	p_tipo_dado = "EDITA"
	p_valida_coluna = "DESCRICAO"
	p_valida_coluna_tabela = "CGP_FICHA_TECNICA_ITENS"
	p_valida_colunas_incluir = "CODIGO"
	p_valida_replace = "ERP_FT_COMPOSICAO With Tabela_Validacao.CODIGO"
	p_valida_replace_em_limpa = .t.
	p_valida_where = " AND CGP_FICHA_TECNICA_ITENS.CODIGO_FT = '0005' "
ENDDEFINE

DEFINE CLASS tv_ft_categoria as lx_textbox_valida
	*lx_textbox_valida
	top = 180
	left = 100
	width = 180
	ControlSource = "v_Produtos_00.ERP_FT_DESC_CATEGORIA"
	Name = "tv_ft_categoria"
	NullDisplay = "..."
	p_tipo_dado = "EDITA"
	p_valida_coluna = "DESCRICAO"
	p_valida_coluna_tabela = "CGP_FICHA_TECNICA_ITENS"
	p_valida_colunas_incluir = "CODIGO"
	p_valida_replace = "ERP_FT_CATEGORIA With Tabela_Validacao.CODIGO"
	p_valida_replace_em_limpa = .t.
	p_valida_where = " AND CGP_FICHA_TECNICA_ITENS.CODIGO_FT = '0006' "
ENDDEFINE

DEFINE CLASS tv_ft_fit as lx_textbox_valida
	*lx_textbox_valida
	top = 210
	left = 100
	width = 180
	ControlSource = "v_Produtos_00.ERP_FT_DESC_FIT"
	Name = "tv_ft_fit"
	NullDisplay = "..."
	p_tipo_dado = "EDITA"
	p_valida_coluna = "DESCRICAO"
	p_valida_coluna_tabela = "CGP_FICHA_TECNICA_ITENS"
	p_valida_colunas_incluir = "CODIGO"
	p_valida_replace = "ERP_FT_FIT With Tabela_Validacao.CODIGO"
	p_valida_replace_em_limpa = .t.
	p_valida_where = " AND CGP_FICHA_TECNICA_ITENS.CODIGO_FT = '0007' "
ENDDEFINE

DEFINE CLASS tv_ft_especificacoes as lx_textbox_valida
	*lx_textbox_valida
	top = 240
	left = 100
	width = 180
	ControlSource = "v_Produtos_00.ERP_FT_DESC_ESPECIFICACOES"
	Name = "tv_ft_especificacoes"
	NullDisplay = "..."
	p_tipo_dado = "EDITA"
	p_valida_coluna = "DESCRICAO"
	p_valida_coluna_tabela = "CGP_FICHA_TECNICA_ITENS"
	p_valida_colunas_incluir = "CODIGO"
	p_valida_replace = "ERP_FT_ESPECIFICACOES With Tabela_Validacao.CODIGO"
	p_valida_replace_em_limpa = .t.
	p_valida_where = " AND CGP_FICHA_TECNICA_ITENS.CODIGO_FT = '0008' "
ENDDEFINE

DEFINE CLASS tv_ft_classificacao as lx_textbox_valida
	*lx_textbox_valida
	top = 270
	left = 100
	width = 180
	ControlSource = "v_Produtos_00.ERP_FT_DESC_CLASSIFICACAO"
	Name = "tv_ft_classificacao"
	NullDisplay = "..."
	p_tipo_dado = "EDITA"
	p_valida_coluna = "DESCRICAO"
	p_valida_coluna_tabela = "CGP_FICHA_TECNICA_ITENS"
	p_valida_colunas_incluir = "CODIGO"
	p_valida_replace = "ERP_FT_CLASSIFICACAO With Tabela_Validacao.CODIGO"
	p_valida_replace_em_limpa = .t.
	p_valida_where = " AND CGP_FICHA_TECNICA_ITENS.CODIGO_FT = '0009' "
ENDDEFINE

DEFINE CLASS tv_ft_desenho as lx_textbox_valida
	*lx_textbox_valida
	top = 300
	left = 100
	width = 180
	ControlSource = "v_Produtos_00.ERP_FT_DESC_DESENHO"
	Name = "tv_ft_desenho"
	NullDisplay = "..."
	p_tipo_dado = "EDITA"
	p_valida_coluna = "DESCRICAO"
	p_valida_coluna_tabela = "CGP_FICHA_TECNICA_ITENS"
	p_valida_colunas_incluir = "CODIGO"
	p_valida_replace = "ERP_FT_DESENHO With Tabela_Validacao.CODIGO"
	p_valida_replace_em_limpa = .t.
	p_valida_where = " AND CGP_FICHA_TECNICA_ITENS.CODIGO_FT = '0010' "
ENDDEFINE

DEFINE CLASS tv_ft_fator_f as lx_textbox_valida
	*lx_textbox_valida
	top = 330
	left = 100
	width = 180
	ControlSource = "v_Produtos_00.ERP_FT_DESC_FATOR_F"
	Name = "tv_ft_fator_f"
	NullDisplay = "..."
	p_tipo_dado = "EDITA"
	p_valida_coluna = "DESCRICAO"
	p_valida_coluna_tabela = "CGP_FICHA_TECNICA_ITENS"
	p_valida_colunas_incluir = "CODIGO"
	p_valida_replace = "ERP_FT_FATOR_F With Tabela_Validacao.CODIGO"
	p_valida_replace_em_limpa = .t.
	p_valida_where = " AND CGP_FICHA_TECNICA_ITENS.CODIGO_FT = '0011' "
ENDDEFINE

DEFINE CLASS tv_ft_risco as lx_textbox_valida
	*lx_textbox_valida
	top = 360
	left = 100
	width = 180
	ControlSource = "v_Produtos_00.ERP_FT_DESC_RISCO"
	Name = "tv_ft_risco"
	NullDisplay = "..."
	p_tipo_dado = "EDITA"
	p_valida_coluna = "DESCRICAO"
	p_valida_coluna_tabela = "CGP_FICHA_TECNICA_ITENS"
	p_valida_colunas_incluir = "CODIGO"
	p_valida_replace = "ERP_FT_RISCO With Tabela_Validacao.CODIGO"
	p_valida_replace_em_limpa = .t.
	p_valida_where = " AND CGP_FICHA_TECNICA_ITENS.CODIGO_FT = '0012' "
ENDDEFINE

DEFINE CLASS edt_ecomm_atributos as lx_editbox

	top = 60
	left = 150
	height = 375
	width = 510
	Name = "edt_ecomm_atributos"
	ControlSource = "V_PRODUTOS_00.ERP_ECOMM_DESC_ATRIBUTOS"
	p_tipo_dado = "EDITA"
		
ENDDEFINE

DEFINE CLASS txtErp_ecomm_desc_seo AS lx_textbox_base
	Height = 21
	Left = 150
	Top = 30
	Width = 250
	ReadOnly = .F.
	Name = "txtErp_ecomm_desc_seo"
	ControlSource = "V_PRODUTOS_00.ERP_ECOMM_DESC_SEO"
	p_tipo_dado = "EDITA"

*!*		PROCEDURE when
*!*			IF this.Parent.chk_licenciado1.value = .F.
*!*				WAIT WINDOW NOWAIT "Marque a opção Licenciado para editar este campo..."
*!*				RETURN .F. 
*!*			ENDIF
*!*			
*!*		ENDPROC
ENDDEFINE

*** CRIAÇÃO DE OBJETOS DA ABA PEDIDO
*!*	REQUERIDO_POR
*!*	TIPO_COMPRA
*!*	ERP_CAB_OPCAO
*!*	ERP_CAB_COD_CABIDE


DEFINE CLASS txtREQUERIDO_POR AS lx_textbox_base
	Height = 21
	Left = 170
	Top = 25
	Width = 250
	ReadOnly = .F.
	Name = "txtREQUERIDO_POR"
	ControlSource = "V_PRODUTOS_00.REQUERIDO_POR"
	ENABLED = .F.

	p_tipo_dado = "MOSTRA"

	PROCEDURE when
		RETURN .F.		
	ENDPROC
ENDDEFINE

DEFINE CLASS txtTIPO_COMPRA AS lx_textbox_base
	Height = 21
	Left = 170
	Top = 55
	Width = 250
	ReadOnly = .F.
	Name = "txtTIPO_COMPRA"
	ControlSource = "V_PRODUTOS_00.TIPO_COMPRA"
	ENABLED = .F.
	p_tipo_dado = "MOSTRA"

	PROCEDURE when
		RETURN .F.		
	ENDPROC
ENDDEFINE

DEFINE CLASS txtERP_CAB_COD_CABIDE AS lx_textbox_base
	Height = 21
	Left = 170
	Top = 115
	Width = 250
	ReadOnly = .F.
	Name = "txtERP_CAB_COD_CABIDE"
	ControlSource = "V_PRODUTOS_00.ERP_CAB_COD_CABIDE"
	ENABLED = .F.
	p_tipo_dado = "MOSTRA"

	PROCEDURE when
		RETURN .F.		
	ENDPROC
ENDDEFINE

DEFINE CLASS optCabilog as OptionGroup
	TOP = 82
	BUTTONCOUNT = 4
	OPTION1.CAPTION = "Nenhum"
	OPTION2.CAPTION = "Só Encabidado"
	OPTION3.CAPTION = "Só Alarme"
	OPTION4.CAPTION = "Encabidado + Alarme"
	OPTION1.AUTOSIZE = .T.
	OPTION2.AUTOSIZE = .T.
	OPTION3.AUTOSIZE = .T.
	OPTION4.AUTOSIZE = .T.
	LEFT = 170
	WIDTH = 432
	HEIGHT = 30
	OPTION1.TOP = 5
	OPTION2.TOP = 5
	OPTION3.TOP = 5
	OPTION4.TOP = 5

	OPTION1.LEFT = 4
	OPTION2.LEFT = 93
	OPTION3.LEFT = 203
	OPTION4.LEFT = 281

	BACKSTYLE = 0
	OPTION1.BACKSTYLE = 0
	OPTION2.BACKSTYLE = 0
	OPTION3.BACKSTYLE = 0
	OPTION4.BACKSTYLE = 0
	
	CONTROLSOURCE = "V_PRODUTOS_00.ERP_CAB_OPCAO"
	ENABLED = .F.
	
ENDDEFINE

*** #caedu# - criar os botões de navegação das páginas de 13 a 17
DEFINE CLASS btoPage13 as botao && page importado

	autosize = .f.
	Caption = "Importado"
	colorscheme = 8
	colorsource = 4
	enabled = .t.
	Height = 36
	Name = "BtoPage13"
	SpecialEffect = 1
	Tag = "13"
	Themes = .f.
	Top = 2
	Left = 928
	Width = 38
	
	
	PROCEDURE click
		WAIT WINDOW "Importado" nowait
		ThisForm.Lx_pageframe1.ActivePage = 13
		ThisFormSet.LxSetPages('R')
	ENDPROC 
	
	PROCEDURE keypress
		LPARAMETERS nKeyCode, nShiftAltCtrl

		*--#65#
		Thisformset.lxnavegaseta(nKeyCode, nShiftAltCtrl)
		*--#65#
	ENDPROC 
ENDDEFINE 

DEFINE CLASS btoPage14 as botao && page pedido

	autosize = .f.
	Caption = "Pedido"
	colorscheme = 8
	colorsource = 4
	enabled = .t.
	Height = 36
	Name = "BtoPage14"
	SpecialEffect = 1
	Tag = "14"
	Themes = .f.
	Top = 2
	Left = 965
	Width = 38
	
	PROCEDURE click
		WAIT WINDOW "Pedido" nowait
		ThisForm.Lx_pageframe1.ActivePage = 14
		ThisFormSet.LxSetPages('R')
	ENDPROC 
	
	PROCEDURE keypress
		LPARAMETERS nKeyCode, nShiftAltCtrl

		*--#65#
		Thisformset.lxnavegaseta(nKeyCode, nShiftAltCtrl)
		*--#65#
	ENDPROC 
ENDDEFINE 


DEFINE CLASS btoPage15 as botao && page outros

	autosize = .f.
	Caption = "Outros"
	colorscheme = 8
	colorsource = 4
	enabled = .t.
	Height = 36
	Name = "BtoPage15"
	SpecialEffect = 1
	Tag = "15"
	Themes = .f.
	Top = 2
	Left = 1002
	Width = 38
	
	PROCEDURE click
		WAIT WINDOW "Outros" nowait
		ThisForm.Lx_pageframe1.ActivePage = 15
		ThisFormSet.LxSetPages('R')
	ENDPROC 
	
	PROCEDURE keypress
		LPARAMETERS nKeyCode, nShiftAltCtrl

		*--#65#
		Thisformset.lxnavegaseta(nKeyCode, nShiftAltCtrl)
		*--#65#
	ENDPROC 
ENDDEFINE 

DEFINE CLASS btoPage16 as botao && page Ecomm

	autosize = .f.
	Caption = "Ecomm"
	colorscheme = 8
	colorsource = 4
	enabled = .t.
	Height = 36
	Name = "BtoPage16"
	SpecialEffect = 1
	Tag = "16"
	Themes = .f.
	Top = 2
	Left = 1039
	Width = 38
	
	PROCEDURE click
		WAIT WINDOW "Ecomm" nowait
		ThisForm.Lx_pageframe1.ActivePage = 16
		ThisFormSet.LxSetPages('R')
	ENDPROC 
	
	PROCEDURE keypress
		LPARAMETERS nKeyCode, nShiftAltCtrl

		*--#65#
		Thisformset.lxnavegaseta(nKeyCode, nShiftAltCtrl)
		*--#65#
	ENDPROC 
ENDDEFINE 

DEFINE CLASS btoPage17 as botao && page Ficha Tecnica

	autosize = .f.
	Caption = "Ficha Tec"
	colorscheme = 8
	colorsource = 4
	enabled = .t.
	Height = 36
	Name = "BtoPage17"
	SpecialEffect = 1
	Tag = "17"
	Themes = .f.
	Top = 2
	Left = 1076
	Width = 38
	
	PROCEDURE click
		WAIT WINDOW "Ficha Tec" nowait
		ThisForm.Lx_pageframe1.ActivePage = 17
		ThisFormSet.LxSetPages('R')
	ENDPROC 
	
	PROCEDURE keypress
		LPARAMETERS nKeyCode, nShiftAltCtrl

		*--#65#
		Thisformset.lxnavegaseta(nKeyCode, nShiftAltCtrl)
		*--#65#
	ENDPROC 
ENDDEFINE 

DEFINE CLASS cboNavPages as ComboBox
	Visible=.t.
	width=38
	top=26
	left = 670
	style=2
	
	
	PROCEDURE init
	
		DIMENSION laItemsNavPage[17]
		laItemsNavPage[1]="Produtos (Principal)"
		laItemsNavPage[2]="Controle de Custos"
		laItemsNavPage[3]="Código de Barras"
		laItemsNavPage[4]="Foto"
		laItemsNavPage[5]="Tabelas de Preços"
		laItemsNavPage[6]="Packs"
		laItemsNavPage[7]="Kit /Montagem /Segunda Qualidade"
		laItemsNavPage[8]="MRP"
		laItemsNavPage[9]="Status Log /Fluxo"
		laItemsNavPage[10]="Formas de Pagamento"
		laItemsNavPage[11]="SKU´s"
		laItemsNavPage[12]="Propriedades"
		laItemsNavPage[13]="Importados"
		laItemsNavPage[14]="Pedidos (uMode)"
		laItemsNavPage[15]="Outros"
		laItemsNavPage[16]="E-commerce"
		laItemsNavPage[17]="Ficha Técnica"
		
		FOR ix=1 TO 17
			this.AddItem(TRANSFORM(ix,"99")+ " - " + laItemsNavPage[ix])
		ENDFOR 
	ENDPROC 
	PROCEDURE valid
		thisformset.lx_form1.lx_pageframe1.activepage = this.ListIndex
		
		IF this.ListIndex < 9
			ThisFormSet.LxSetPages('L')
		ELSE
			ThisFormSet.LxSetPages('R')
		ENDIF
		
	ENDPROC 
ENDDEFINE 