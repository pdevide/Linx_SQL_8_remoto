***
* OBJETO DE ENTRADA: TELA CONTAGEM FISICA DE PRODUTO ACABADO
* PAULO DEVIDE => 07-MAR-2018
*/
define class obj_entrada as custom

	procedure metodo_usuario

		lparam xmetodo, xobjeto ,xnome_obj

		**WAIT WINDOW xnome_obj + " - " + xmetodo TIMEOUT 1

		do case

			CASE UPPER(xmetodo) == 'USR_SEARCH_AFTER'


				*** método l_desenhista_procura() do form
				*** s1 a s48 = contagem
				*** q1 a a48 = diferenca

				**==============================================================================================================================================**
				**
				** implementado para trazer o preço de venda na coluna v_estoque_prod_contagem_00_itens.custo_reposicao4
				** chamado CAP: 149889
				** PAULO DEVIDE - 05/06/17
				**/
				IF !INLIST(V_ESTOQUE_PROD_CONTAGEM_00.FILIAL , 'CD EMBU',"CD IMPORTACAO")


					f_select("select a.produto, a.preco1  "+;
						"from produtos_precos a "+;
						"where a.codigo_tab_preco  "+;
						"in (select x.codigo_tab_preco from TABELAS_PRECO x where x.codigo_tab_preco in  "+;
						"(select valor_atual from PARAMETROS_LOJA , FILIAIS  "+;
						"where PARAMETROS_LOJA.CODIGO_FILIAL = FILIAIS.COD_FILIAL "+;
						"and filiais.FILIAL = ?V_ESTOQUE_PROD_CONTAGEM_00.FILIAL and PARAMETROS_LOJA.PARAMETRO = 'codigo_tab_preco')) ","caepreco")

				ELSE

					f_select("select a.produto, a.preco1  "+;
						"from produtos_precos a "+;
						"where a.codigo_tab_preco  = '01' ", "caepreco")

				ENDif

				UPDATE v_estoque_prod_contagem_00_itens ;
					SET v_estoque_prod_contagem_00_itens.custo_reposicao4 = caepreco.preco1 ;
					from v_estoque_prod_contagem_00_itens , caepreco ;
					WHERE v_estoque_prod_contagem_00_itens.produto = caepreco.produto
				**==============================================================================================================================================**

				If	ThisFormSet.Lx_form1.Lx_pageframe1.Page3.chkPreco.Value = 1 or ;
						ThisFormset.Lx_form1.Lx_pageframe1.Page3.chkCustoProduto.Value = 1 or ;
						ThisFormSet.lx_Form1.lx_PageFrame1.Page3.chkCustoMedio.Value = 1

					local 	strIncidencia as integer,;
						xTem_Produto_Zerado	as boolean,;
						xtem_custo_zerado as Boolean

					xTem_Produto_Zerado					= .F.
					xtem_custo_zerado					= .F.
					strIncidencia = thisformset.lx_form1.lx_pageframe1.page3.lx_optIncidencia.Value

					Sele v_estoque_prod_contagem_00_itens
					xTamanho	= Reccount()
					xConta 		= 1
					Scan
						*			Wait Window "Aguarde Processando Valorização do Produto "+AllT(Produto)+" - Cor "+AllT(Cor_Produto)+"  -  "+AllT(Str(xConta))+"/"+AllT(Str(xTamanho)) NoWait
						f_prog_bar('Aguarde, Processando Valorização de Produtos',xconta,xtamanho)
						xProduto      	=	Produto
						xCor_Produto	=	Cor_Produto
						xCod_Tab_Preco 	=	ThisFormSet.Px_Tabela_Preco
						*- Pega o preco do produto
						If ThisFormset.Lx_form1.Lx_pageframe1.Page3.chkCustoProduto.Value  = 1
							If Empty(v_estoque_prod_contagem_00_itens.Custo_reposicao1) and Empty(v_estoque_prod_contagem_00_itens.Custo_reposicao2) and Empty(v_estoque_prod_contagem_00_itens.Custo_reposicao3) and Empty(v_estoque_prod_contagem_00_itens.Custo_reposicao4)
								xtem_Custo_zerado = .T.
							EndIf
						Else
							If ThisFormSet.Lx_form1.Lx_pageframe1.Page3.chkPreco.Value = 1
								If ! Varia_Preco_Cor
									If f_Vazio(xCod_Tab_Preco)
										f_Select('SELECT produto, preco_reposicao_1 as preco1, preco_reposicao_2 as preco2, ' + ;
											'preco_reposicao_3 as preco3, preco_reposicao_4 as preco4 ' + ;
											'FROM PRODUTOS WHERE PRODUTO = ?xProduto', 'xSelecao')
									Else
										=F_Select("SELECT * FROM PRODUTOS_PRECOS WHERE CODIGO_TAB_PRECO =?XCOD_TAB_PRECO AND "+;
											"PRODUTO=?XPRODUTO","xSelecao")
									EndIf
									If Empty(xSelecao.Produto)
										xTem_Produto_Zerado	= .T.
									EndIf
								Else
									If f_Vazio(xCod_Tab_Preco)
										f_Select('SELECT produto, preco_reposicao_1 as preco1, preco_reposicao_2 as preco2, ' + ;
											'preco_reposicao_3 as preco3, preco_reposicao_4 as preco4 ' + ;
											'FROM PRODUTO_CORES WHERE PRODUTO = ?xProduto AND ' + ;
											'COR_PRODUTO = ?xCor_Produto', 'xSelecao')
									Else
										=F_Select("SELECT * FROM PRODUTOS_PRECO_COR WHERE CODIGO_TAB_PRECO =?XCOD_TAB_PRECO AND "+;
											"PRODUTO=?XPRODUTO AND COR_PRODUTO =?XCOR_PRODUTO ","xSelecao")
									EndIf
									If Empty(xSelecao.Produto)
										xTem_Produto_Zerado	= .T.
									EndIf
								EndIf
							EndIf
						Endif

						Sele V_Produtos_Tamanho_00
						IF wPrecos_Tamanho
							Locate for Grade = v_estoque_prod_contagem_00_itens.Grade
						EndIf

						Sele v_estoque_prod_contagem_00_itens
						xQtd_Total    	= 0
						xValor_Total 	= 0

						*- Calcula o valor do estoque
						If ThisFormset.Lx_form1.Lx_pageframe1.Page3.chkCustoProduto.Value = 1
							If Varia_Preco_Tam And wPrecos_Tamanho
								For xContador = 1 To wmaximo_tamanhos
									xPreco      	= " v_estoque_prod_contagem_00_itens.custo_reposicao"+AllT(Subs(Ponteiro_Preco_Tam,xContador,1))
									xQtde       	= iif(strIncidencia = 1,"S","Q")+AllT(Str(xContador,2))
									xQtd 			= &xQtde
									xPre		 	= &xPreco
									xQtd_Total  	= xQtd_Total + xQtd
									xValor_Total	= xValor_total + ( &xQtde * &xPreco )
								Next
							Else
								*!*					if strIncidencia = 1
								*!*						xQtd_Total			= 	s1+s2+s3+s4+s5+s6+s7+s8+s9+s10+;
								*!*												s11+s12+s13+s14+s15+s16+s17+s18+s19+s20+;
								*!*												s21+s22+s23+s24+s25+s26+s27+s28+s29+s30+;
								*!*												s31+s32+s33+s34+s35+s36+s37+s38+s39+s40+;
								*!*												s41+s42+s43+s44+s45+s46+s47+s48
								*!*					else
								*!*						xQtd_Total			= 	q1+s2+q3+q4+q5+q6+q7+q8+q9+q10+;
								*!*												q11+q12+q13+q14+q15+q16+q17+q18+q19+q20+;
								*!*												q21+q22+q23+q24+q25+q26+q27+q28+q29+q30+;
								*!*												q31+q32+q33+q34+q35+q36+q37+q38+q39+q40+;
								*!*												q41+q42+q43+q44+q45+q46+q47+q48
								*!*					endif

								xQtd_Total = iif(strIncidencia = 1,QTDE_CONTAGEM,diferenca_total)
								xValor_Total 		=  	xQtd_Total * v_estoque_prod_contagem_00_itens.custo_reposicao1
							EndIf
							Replace	Custo1_A_Valorizar 	With IIF(ISNULL(custo_reposicao1),0,custo_reposicao1)	,;
								Custo2_A_Valorizar 	With IIF(ISNULL(custo_reposicao2),0,custo_reposicao2),;
								Custo3_A_Valorizar 	With IIF(ISNULL(custo_reposicao3),0,custo_reposicao3)	,;
								Custo4_A_Valorizar 	With IIF(ISNULL(custo_reposicao4),0,custo_reposicao4)	,;
								VALOR_CONTAGEM_DIFERENCA With IIF(ISNULL(xValor_Total),0,xValor_Total)
						Else
							If ThisFormSet.Lx_form1.Lx_pageframe1.Page3.chkPreco.Value = 1
								If Varia_Preco_Tam And wPrecos_Tamanho
									For xContador = 1 To wmaximo_tamanhos
										xPreco      	= "xSelecao.Preco"+AllT(Subs(Ponteiro_Preco_Tam,xContador,1))
										xQtde       	=  iif(strIncidencia = 1,"S","Q")+AllT(Str(xContador,2))
										xQtd 			= &xQtde
										xPre		 	= &xPreco
										xQtd_Total  	= xQtd_Total + xQtd
										xValor_Total	= xValor_total + (( &xQtde * &xPreco )*thisFormSet.Px_Fator)
									Next
								Else
									*!*						if strIncidencia = 1
									*!*							xQtd_Total			= 	s1+s2+s3+s4+s5+s6+s7+s8+s9+s10+;
									*!*													s11+s12+s13+s14+s15+s16+s17+s18+s19+s20+;
									*!*													s21+s22+s23+s24+s25+s26+s27+s28+s29+s30+;
									*!*													s31+s32+s33+s34+s35+s36+s37+s38+s39+s40+;
									*!*													s41+s42+s43+s44+s45+s46+s47+s48
									*!*						else
									*!*							xQtd_Total			= 	q1+s2+q3+q4+q5+q6+q7+q8+q9+q10+;
									*!*													q11+q12+q13+q14+q15+q16+q17+q18+q19+q20+;
									*!*													q21+q22+q23+q24+q25+q26+q27+q28+q29+q30+;
									*!*													q31+q32+q33+q34+q35+q36+q37+q38+q39+q40+;
									*!*													q41+q42+q43+q44+q45+q46+q47+q48
									*!*						endif
									xQtd_Total = iif(strIncidencia = 1,QTDE_CONTAGEM,diferenca_total)
									xValor_Total 		=  	xQtd_Total * xSelecao.Preco1*thisFormSet.Px_Fator
								EndIf
								Replace	Custo1_A_Valorizar 	With IIF(ISNULL(custo_reposicao1),0,custo_reposicao1)	,;
									Custo2_A_Valorizar 	With IIF(ISNULL(custo_reposicao2),0,custo_reposicao2),;
									Custo3_A_Valorizar 	With IIF(ISNULL(custo_reposicao3),0,custo_reposicao3)	,;
									Custo4_A_Valorizar 	With IIF(ISNULL(custo_reposicao4),0,custo_reposicao4)	,;
									VALOR_CONTAGEM_DIFERENCA With IIF(ISNULL(xValor_Total),0,xValor_Total)
							Else
								*!*					if strIncidencia = 1
								*!*						xQtd_Total			= 	s1+s2+s3+s4+s5+s6+s7+s8+s9+s10+;
								*!*												s11+s12+s13+s14+s15+s16+s17+s18+s19+s20+;
								*!*												s21+s22+s23+s24+s25+s26+s27+s28+s29+s30+;
								*!*												s31+s32+s33+s34+s35+s36+s37+s38+s39+s40+;
								*!*												s41+s42+s43+s44+s45+s46+s47+s48
								*!*					else
								*!*						xQtd_Total			= 	q1+s2+q3+q4+q5+q6+q7+q8+q9+q10+;
								*!*												q11+q12+q13+q14+q15+q16+q17+q18+q19+q20+;
								*!*												q21+q22+q23+q24+q25+q26+q27+q28+q29+q30+;
								*!*												q31+q32+q33+q34+q35+q36+q37+q38+q39+q40+;
								*!*												q41+q42+q43+q44+q45+q46+q47+q48
								*!*					endif
								xQtd_Total = iif(strIncidencia = 1,QTDE_CONTAGEM,diferenca_total)
								xValor_Total 		=  	( xQtd_Total * CUSTO_MEDIO1 )
								Replace	Custo1_A_Valorizar 	With IIF(ISNULL(custo_reposicao1),0,custo_reposicao1)	,;
									Custo2_A_Valorizar 	With IIF(ISNULL(custo_reposicao2),0,custo_reposicao2),;
									Custo3_A_Valorizar 	With IIF(ISNULL(custo_reposicao3),0,custo_reposicao3)	,;
									Custo4_A_Valorizar 	With IIF(ISNULL(custo_reposicao4),0,custo_reposicao4)	,;
									VALOR_CONTAGEM_DIFERENCA With IIF(ISNULL(xValor_Total),0,xValor_Total)
							EndIf
						Endif
						xConta 	= 	xConta+1
						if isnull(xvalor_total)
							xvalor_total=0
						endif
						**			ThisFormSet.Px_Total_Valor_Estoque	=	ThisFormSet.Px_Total_Valor_Estoque+xValor_Total
					EndScan
					Go top
					If xTem_Produto_Zerado
						=F_msg(["Exitem Produtos Com Valores Zerados",16,"Atenção...!"])
					EndIf
				EndIf

			case UPPER(xmetodo) == 'USR_REFRESH'
				IF Thisformset.lx_form1.lx_pageframe1.Activepage = 1
					WITH  thisformset.lx_FORM1.lx_pageframe1.page1
						.lx_grid_filha1.anchor = 0
						lnHeightGrid =268 &&.lx_grid_filha1.Height  - 30
						.lx_grid_filha1.Height = lnHeightGrid
					ENDWITH
				ENDIF



			case UPPER(xmetodo) == 'USR_INIT'

				WAIT WINDOW NOWAIT "obj"
				strInitAlias = ALIAS()

				TRY
					ADDPROPERTY(Thisformset, "P_agendamento","")
				CATCH TO oErro1
					MESSAGEBOX(oErro1.message, 16, "Aviso")

				ENDTRY

				***
				*  Configuração novos campos alias: V_ESTOQUE_PROD_CONTAGEM_00
				*  Paulo Devide: 16/05/2018
				*
				SELECT V_ESTOQUE_PROD_CONTAGEM_00
				oCursor = GETCURSORADAPTER("V_ESTOQUE_PROD_CONTAGEM_00")
				oCursor.AddBufferField("ESTOQUE_PROD_CONTAGEM.APROVADO_POR","C(40)",.T.,"APROVADO_POR","ESTOQUE_PROD_CONTAGEM.APROVADO_POR")
				oCursor.AddBufferField("ESTOQUE_PROD_CONTAGEM.ID_ARQ_PDA_CONTAGEM","I",.T.,"ID_ARQ_PDA_CONTAGEM","ESTOQUE_PROD_CONTAGEM.ID_ARQ_PDA_CONTAGEM")
				oCursor.AddBufferField("ESTOQUE_PROD_CONTAGEM.ERP_ULTIMO_RESPONSAVEL","C(25)",.T.,"ERP_ULTIMO_RESPONSAVEL","ESTOQUE_PROD_CONTAGEM.ERP_ULTIMO_RESPONSAVEL")
				oCursor.confirmStructureChanges()
				*** Fim configuração alias: V_ESTOQUE_PROD_CONTAGEM_00

				***
				*  Configuração novos campos alias: V_ESTOQUE_PROD_CONTAGEM_00_ITENS
				*  Paulo Devide: 16/05/2018
				*
				SELECT V_ESTOQUE_PROD_CONTAGEM_00_ITENS
				oCursor = GETCURSORADAPTER("V_ESTOQUE_PROD_CONTAGEM_00_ITENS")
				oCursor.AddBufferField("PRODUTOS.LINHA","C(25)",.F.,"LINHA","PRODUTOS.LINHA")
				oCursor.AddBufferField("PRODUTOS.GRIFFE","C(25)",.F.,"GRIFFE","PRODUTOS.GRIFFE")
				oCursor.AddBufferField("ESTOQUE_PROD_CTG_ITENS.ERP_JUSTIFICATIVA","C(40)",.T.,"ERP_JUSTIFICATIVA","ESTOQUE_PROD_CTG_ITENS.ERP_JUSTIFICATIVA")
				oCursor.confirmStructureChanges()
				*** Fim configuração alias: V_ESTOQUE_PROD_CONTAGEM_00_ITENS

				thisformset.l_limpa()

				SELECT (strInitAlias)

				thisformset.lx_FORM1.Height = 596 &&546

				** Adiciona Page Caedu
				lnLastPage = Thisformset.lx_form1.lx_pageframe1.pagecount + 1
				lcLastPage = "pgCaedu"
				Thisformset.lx_form1.lx_pageframe1.addobject(lcLastPage,"cPageCaedu")
				WITH Thisformset.lx_form1.lx_pageframe1.pgCaedu
					.enabled=.t.
					.Caption="CAEDU"
					lnPageIndex = .pageorder

					TRY
						.addobject("Lx_grid_filha1","lx_grade_filha")
						.Lx_grid_filha1.visible = .t.
					CATCH TO oErro
						WAIT WINDOW oErro.message
					FINALLY

					ENDTRY


				ENDWITH

				WITH  thisformset.lx_FORM1.lx_pageframe1.page1
					*!*						****
					*!*						* REPOSICIONAMENTO DE OBJETOS NA TELA
					*!*						* PAULO DEVIDE => 08-MAR-18
					*!*						*/
					*!*						.parent.height = 510				&& altura do container page frame
					*!*						.label3.top = 79					&& label diferenças de contagem
					*!*						.Lx_grade48_1.top = 93			&& grade do produto
					*!*						.label1.top = 166				&& label produto
					*!*						.Lx_textbox_base1.top = 164	&& textbox produto
					*!*						.label2.top = 166				&& label cor
					*!*						.Lx_textbox_base2.top = 164	&& textbox cor
					*!*						.Shape2.top = 164				&& indicador contagem
					*!*						.label4.top = 168				&& label contagem
					*!*						.Shape1.top = 164				&& indicador saldo
					*!*						.label5.top = 168				&& label saldo
					*!*						.Lx_grid_filha1.top = 188		&& grid da page
					*!*						.Lx_grid_filha1.height = 270		 && altura da grid da page


					.addobject("lblFiltro1","lblFiltro")
					.lblFiltro1.visible = .t.

					.addobject("ed_filtro","edtfiltro")
					.ed_filtro.visible = .t.
					.ed_filtro.top = 402

					.addobject("btnFiltro1","btnFiltro")
					.btnFiltro1.visible = .t.

					.addobject("btnLimpar1","btnLimpar")
					.btnLimpar1.visible = .t.

					** Adiciona Linha, Griffe e Justificativa no Grid (3 novas colunas)
					lnTotCols = .lx_grid_filha1.ColumnCount
					.lx_grid_filha1.ColumnCount = lnTotCols + 3

					** preenche o header caption das colunas
					.lx_grid_filha1.columns(lnTotCols+1).Header1.Caption = "Linha"
					.lx_grid_filha1.columns(lnTotCols+2).Header1.Caption = "Griffe"
					.lx_grid_filha1.columns(lnTotCols+3).Header1.Caption = "Justificativa"

					** preenche o controlsource
					.lx_grid_filha1.columns(lnTotCols+1).controlsource = "v_estoque_prod_contagem_00_itens.Linha"
					.lx_grid_filha1.columns(lnTotCols+2).controlsource = "v_estoque_prod_contagem_00_itens.Griffe"
					.lx_grid_filha1.columns(lnTotCols+3).controlsource = "v_estoque_prod_contagem_00_itens.ERP_Justificativa"

					.lx_grid_filha1.columns(lnTotCols+1).visible = .t.
					.lx_grid_filha1.columns(lnTotCols+2).visible = .t.
					.lx_grid_filha1.columns(lnTotCols+3).visible = .t.

					.lx_grid_filha1.columns(lnTotCols+1).enabled = .t.
					.lx_grid_filha1.columns(lnTotCols+2).enabled = .t.
					.lx_grid_filha1.columns(lnTotCols+3).enabled = .t.

					** coluna Justificativa
					.lx_grid_filha1.columns(lnTotCols+3).ColumnOrder = 6
					.lx_grid_filha1.columns(lnTotCols+3).Width = 170

					.lx_grid_filha1.columns(lnTotCols+1).name = "col_Linha"
					.lx_grid_filha1.columns(lnTotCols+2).name = "col_Griffe"
					.lx_grid_filha1.columns(lnTotCols+3).name = "col_ERP_Justificativa"

					.lx_grid_filha1.col_ERP_Justificativa.Addobject("cmb_justificativa1","cmb_justificativa")
					.lx_grid_filha1.col_ERP_Justificativa.currentcontrol = "cmb_justificativa1"
					.lx_grid_filha1.col_ERP_Justificativa.cmb_justificativa1.visible=.t.

					.lx_grid_filha1.col_ERP_Justificativa.sparse=.f.

					.lx_grid_filha1.anchor = 0
					lnHeightGrid = .lx_grid_filha1.Height  - 30
					.lx_grid_filha1.Height = lnHeightGrid
					.parent.height = 550
				ENDWITH

				*** objetos page 'Complementos/Ajustes'
				WITH  thisformset.lx_FORM1.lx_pageframe1.page2
					.addobject("Lx_label6","Lx_label6")
					.Lx_label6.Visible = .T.
					.addobject("Lx_textbox_base1","Lx_textbox_base1")
					.Lx_textbox_base1.Visible = .T.
				ENDWITH

				*** objetos page 'Selecionar Itens'
				WITH  thisformset.lx_FORM1.lx_pageframe1.page3
					.addobject("lblInventario","lblInventario")
					.lblInventario.Visible = .T.
					.addobject("ck_ImportaSQL","ck_ImportaSQL")
					.ck_ImportaSQL.Visible = .T.
					.addobject("cboInventarioPDA","cboInventarioPDA")
					.cboInventarioPDA.Visible = .T.
					.addobject("btnInventarioPDA","btnInventarioPDA")
					.btnInventarioPDA.Visible = .T.

					*.addobject("Botao3","Botao3")
					*.Botao3.Visible = .T.
					*.addobject("Lx_textbox_base2","Lx_textbox_base2")
					*.Lx_textbox_base2.Visible = .T.
					*.addobject("Timer1","Timer1")

					** adiciona botão para adicionar contagem parcial **
					.addobject("btnImpContParcial","btnImpContParcial")
					.btnImpContParcial.Visible = .T.

					.ck_historico.Visible=.f.
					.ck_saldo_item_a_item.Visible=.f.


				ENDWITH

			case UPPER(xmetodo) == 'USR_SEARCH_AFTER'




			Case Upper(xmetodo) == 'USR_INCLUDE_BEFORE'



			case UPPER(xmetodo) == 'USR_ALTER_AFTER'


				IF ThisFormSet.p_Tool_Status == 'A'

					WAIT WINDOW 'ALTERACAO, '

				ENDIF


			case UPPER(xmetodo) == 'USR_ALTER_BEFORE'



			Case Upper(xmetodo) == 'USR_INCLUDE_AFTER'



			case UPPER(xmetodo) == 'USR_WHEN'
				** combobox continuo/descontinuo
				** demanda JIRA LC-285
				*!*					IF 'LX_COMBOBOX8' $ UPPER(xnome_obj)
				*!*
				*!*						IF  INLIST(ThisFormSet.p_tool_status,'I','A')
				*!*							ldUltimoAgendamento = NVL(V_PRODUTOS_00.ERP_DATA_ULTIMO_AGENDAMENTO,CTOD(""))
				*!*							IF EMPTY(ldUltimoAgendamento)
				*!*								WAIT WINDOW NOWAIT "Altera??o permitida!"
				*!*								RETURN .t.
				*!*							ELSE
				*!*								MESSAGEBOX("Altera??o n?o permitida neste campo"+CHR(13)+;
				*!*											"Data do ?ltimo agendamento = "+DTOC(ldUltimoAgendamento),;
				*!*											64,"Aviso")
				*!*								RETURN .f.
				*!*							ENDIF
				*!*						ENDIF
				*!*					ENDIF

			case UPPER(xmetodo) == 'USR_VALID'


				*** Sandra Ono - 27/05/2014 ****
				**** Altera??o para corrigir erro da linx para n?o alterar
				**** o pre?o liquido dos produtos

				*!*					IF 'TX_PRECO1'$UPPER(xnome_obj)
				*!*			    		IF  INLIST(ThisFormSet.p_tool_status,'I','A')
				*!*
				*!*	   	     	    		replace 	preco_liquido1 with 0, ;
				*!*		 					preco_liquido2 with 0, ;
				*!*							preco_liquido3 with 0, ;
				*!*							preco_liquido4 with 0  IN V_PRODUTOS_00_PRECOS

				*!*
				*!*
				*!*			    		ENDIF
				*!*					ENDIF

				IF  ThisFormSet.p_tool_status='I'

					IF "CMB_FILIAL" $ UPPER(xnome_obj)
						**WAIT WINDOW V_ESTOQUE_PROD_CONTAGEM_00.FILIAL
						TEXT TO cmdsql NOSHOW TEXTMERGE PRETEXT 7
							select GETDATE() AS DATA_HORA,FILIAL,EM_INVENTARIO,DT_ULTIMO_INVENTARIO,
							RESPONSAVEL_ULTIMO_INVENTARIO
							FROM FILIAIS
							WHERE FILIAL = ?V_ESTOQUE_PROD_CONTAGEM_00.FILIAL
						ENDTEXT
						f_select(cmdsql,"tmpVerificaStatusInventario")
						IF NVL(tmpVerificaStatusInventario.EM_INVENTARIO,.F.)=.F.
							MESSAGEBOX("Importação do arquivo de contagem da filial "+V_ESTOQUE_PROD_CONTAGEM_00.FILIAL+CHR(13)+;
								"não permitida, pois o processo não foi iniciado corretamente!"+CHR(13)+;
								"Caso tenha alguma dúvida procure assistência com Suporte de TI",16,"Aviso")
							thisformset.l_cancela()
							thisformset.l_limpa()

						ENDIF

					ENDIF
										
					**WAIT WINDOW UPPER(xnome_obj)
					IF "TX_EMISSAO" $ UPPER(xnome_obj)
						**WAIT WINDOW "passou aqui"
*!*							IF DTOS(V_ESTOQUE_PROD_CONTAGEM_00.emissao) < DTOS(tmpVerificaStatusInventario.DT_ULTIMO_INVENTARIO)
*!*								MESSAGEBOX("Opa, a data que você informou ai é menor do que a data "+;
*!*											"que iniciou o inventário ("+DTOC(TTOD(tmpVerificaStatusInventario.DT_ULTIMO_INVENTARIO))+")",;
*!*											16,"Aviso")
*!*								RETURN .f.
*!*							ENDIF
*!*							xnqtddias=VAL(DTOS(V_ESTOQUE_PROD_CONTAGEM_00.emissao)) - VAL(DTOS(tmpVerificaStatusInventario.DT_ULTIMO_INVENTARIO)) 
*!*							IF xnqtddias > 1
*!*								MESSAGEBOX("Opa, a data que você informou ai é superior "+TRANSFORM(xnqtddias)+;
*!*											" dias a data que iniciou o inventário ("+DTOC(TTOD(tmpVerificaStatusInventario.DT_ULTIMO_INVENTARIO))+")",;
*!*											16,"Aviso")
*!*								RETURN .f.
*!*							ENDIF
*!*							IF DTOS(V_ESTOQUE_PROD_CONTAGEM_00.emissao) > DTOS(wdata)
*!*								MESSAGEBOX("Opa, a data que você informou é maior do que a data do Sistema ("+DTOC(wdata)+")",16,"Aviso")
*!*								RETURN .f.							
*!*							ENDIF
						IF CAST(V_ESTOQUE_PROD_CONTAGEM_00.emissao as D) < CAST(tmpVerificaStatusInventario.DT_ULTIMO_INVENTARIO as D)
							MESSAGEBOX("Opa, a data que você informou ai é menor do que a data "+;
										"que iniciou o inventário ("+DTOC(TTOD(tmpVerificaStatusInventario.DT_ULTIMO_INVENTARIO))+")",;
										16,"Aviso")
							RETURN .f.
						ENDIF
						xnqtddias=CAST(V_ESTOQUE_PROD_CONTAGEM_00.emissao as D) - CAST(tmpVerificaStatusInventario.DT_ULTIMO_INVENTARIO as D) 
						IF xnqtddias > 1
							MESSAGEBOX("Opa, a data que você informou ai é superior "+TRANSFORM(xnqtddias)+;
										" dias a data que iniciou o inventário ("+DTOC(TTOD(tmpVerificaStatusInventario.DT_ULTIMO_INVENTARIO))+")",;
										16,"Aviso")
							RETURN .f.
						ENDIF
						IF CAST(V_ESTOQUE_PROD_CONTAGEM_00.emissao as D) > CAST(wdata as D)
							MESSAGEBOX("Opa, a data que você informou é maior do que a data do Sistema ("+DTOC(wdata)+")",16,"Aviso")
							RETURN .f.							
						ENDIF						
					ENDIF


				ENDIF


			CASE UPPER(xmetodo) == 'USR_SAVE_BEFORE'
			
						IF NOT USED("tmpVerificaStatusInventario")
							TEXT TO cmdsql NOSHOW TEXTMERGE PRETEXT 7
								select GETDATE() AS DATA_HORA,FILIAL,EM_INVENTARIO,DT_ULTIMO_INVENTARIO,
								RESPONSAVEL_ULTIMO_INVENTARIO
								FROM FILIAIS
								WHERE FILIAL = ?V_ESTOQUE_PROD_CONTAGEM_00.FILIAL
							ENDTEXT
							f_select(cmdsql,"tmpVerificaStatusInventario")
						ENDIF 
						
						IF CAST(V_ESTOQUE_PROD_CONTAGEM_00.emissao as D) < CAST(tmpVerificaStatusInventario.DT_ULTIMO_INVENTARIO as D)
							MESSAGEBOX("Opa, a data que você informou ai é menor do que a data "+;
										"que iniciou o inventário ("+DTOC(TTOD(tmpVerificaStatusInventario.DT_ULTIMO_INVENTARIO))+")",;
										16,"Aviso")
							RETURN .f.
						ENDIF
						xnqtddias=CAST(V_ESTOQUE_PROD_CONTAGEM_00.emissao as D) - CAST(tmpVerificaStatusInventario.DT_ULTIMO_INVENTARIO as D) 
						IF xnqtddias > 1
							MESSAGEBOX("Opa, a data que você informou ai é superior "+TRANSFORM(xnqtddias)+;
										" dias a data que iniciou o inventário ("+DTOC(TTOD(tmpVerificaStatusInventario.DT_ULTIMO_INVENTARIO))+")",;
										16,"Aviso")
							RETURN .f.
						ENDIF
						IF CAST(V_ESTOQUE_PROD_CONTAGEM_00.emissao as D) > CAST(wdata as D)
							MESSAGEBOX("Opa, a data que você informou é maior do que a data do Sistema ("+DTOC(wdata)+")",16,"Aviso")
							RETURN .f.							
						ENDIF
						
			otherwise
				return .t.
		endcase
	endproc
enddefine

******************************************************************************************************************************
*** objetos da tela
******************************************************************************************************************************
DEFINE CLASS lblFiltro AS Label

	Autosize = .t.
	Left = 421
	Top = 380
	Caption = "Filtro (Produto + cor entre aspas delimitados por virgula) "
	Name = "lblFiltro1"
	BackStyle= 0
	FontName="Tahoma"
	FontSize=8

	PROCEDURE RightClick
		This.Parent.Lx_grid_filha1.Refresh()
	ENDPROC

ENDDEFINE

DEFINE CLASS edtfiltro as EditBox
	Height = 56
	Left = 421
	ReadOnly = .F.
	Enabled = .T.
	Top = 402
	Width = 398
	Name = "ed_filtro"
	Value = ""
	Visible = .t.
ENDDEFINE

DEFINE CLASS btnImpContParcial as botao
	Caption = "Importar Contagem Parcial"
	Height = 41
	Left = 663
	Enabled = .T.
	Top = 319
	Width = 151
	Name = "btnImpContParcial"
	Visible = .t.

	PROCEDURE click

		xarquivo1=upper(alltr(this.parent.tx_arquivo.value))
		if !file(xarquivo1)
			F_msg(['Arquivo Inexistente !',16,'Atenção'])
			retu .f.
		ENDIF

		Create Cursor tmpProdutos ( PRODUTO C(12), COR_PRODUTO C(10))

		CREATE CURSOR TMP_ITENS_CONTAGEM (CODIGO_BARRA C(25), CONTAGEM INT, PRODUTO C(12), COR_PRODUTO C(10), TAMANHO I)
		APPEND FROM &xarquivo1. DELIMITED WITH CHARACTER ";"
		**WAIT WINDOW V_ESTOQUE_PROD_CONTAGEM_00.TIPO
		*SET STEP ON
		f_wait("Aguarde processando arquivo de contagem...")
		F_SELECT("SELECT * FROM PRODUTOS_BARRA ORDER BY PRODUTO, COR_PRODUTO, TAMANHO","V_PROD_BARRA")

		*!*			SELECT V_PROD_BARRA
		*!*			INDEX ON ALLTRIM(CODIGO_BARRA) TAG IND_X1
		*!*			SET ORDER TO TAG IND_X1

		UPDATE A SET  PRODUTO = B.PRODUTO, COR_PRODUTO = B.COR_PRODUTO, TAMANHO = B.TAMANHO ;
			FROM TMP_ITENS_CONTAGEM A ;
			INNER JOIN V_PROD_BARRA B ON B.CODIGO_BARRA = A.CODIGO_BARRA

		SELECT TMP_ITENS_CONTAGEM
		GO top

		INSERT INTO tmpProdutos ;
			SELECT DISTINCT PRODUTO, COR_PRODUTO ;
			FROM V_PROD_BARRA ;
			WHERE CODIGO_BARRA IN (SELECT CODIGO_BARRA FROM TMP_ITENS_CONTAGEM )

		TEXT TO cmdsql NOSHOW TEXTMERGE PRETEXT 7
			SELECT	PRODUTOS.PRODUTO,PRODUTOS.DESC_PRODUTO,PRODUTOS.GRADE,
						 			PRODUTOS.UNIDADE,PRODUTOS.PESO,PRODUTOS.REVENDA,PRODUTOS.REFER_FABRICANTE,
						 			PRODUTO_CORES.COR_PRODUTO,PRODUTO_CORES.DESC_COR_PRODUTO,PRODUTO_CORES.COR_SORTIDA
			FROM PRODUTOS
			INNER JOIN PRODUTO_CORES
				ON PRODUTO_CORES.PRODUTO = PRODUTOS.PRODUTO
			INNER JOIN ESTOQUE_PRODUTOS
			ON	ESTOQUE_PRODUTOS.PRODUTO=PRODUTOS.PRODUTO
			AND	ESTOQUE_PRODUTOS.COR_PRODUTO=PRODUTO_CORES.COR_PRODUTO
			WHERE	ESTOQUE_PRODUTOS.FILIAL= '<<V_ESTOQUE_PROD_CONTAGEM_00.FILIAL>>'
		ENDTEXT
		F_SELECT(cmdsql,"V_STK_FILIAL")

		Insert Into v_Estoque_Prod_Contagem_00_Itens ( PRODUTO, COR_PRODUTO, NOME_CONTAGEM, DESC_COR_PRODUTO, DESC_PRODUTO, GRADE, UNIDADE, PESO, ;
			REFER_FABRICANTE, REVENDA, COR_SORTIDA ) ;
			Select a.produto, a.cor_produto, V_ESTOQUE_PROD_CONTAGEM_00.NOME_CONTAGEM, a.desc_cor_produto, a.desc_produto, a.grade, a.unidade, a.peso, ;
			a.refer_fabricante, a.revenda, a.cor_sortida ;
			from V_STK_FILIAL A ;
			INNER JOIN tmpProdutos B ON B.PRODUTO = A.PRODUTO AND B.COR_PRODUTO = A.COR_PRODUTO

		f_wait("Aguarde calculando saldo dos produtos...")
		** CALCULA O SALDO DO ESTOQUE E PREENCHE O GRID
		THIS.Parent.BOTAO1.CLICK()

		SELECT TMP_ITENS_CONTAGEM
		SCAN

			SELECT v_Estoque_Prod_Contagem_00_Itens
			LOCATE FOR PRODUTO = TMP_ITENS_CONTAGEM.PRODUTO AND COR_PRODUTO = TMP_ITENS_CONTAGEM.COR_PRODUTO
			IF FOUND()
				lcTamanho = ALLTRIM(CAST(TMP_ITENS_CONTAGEM.tamanho as C(2)))
				REPLACE Q&lcTamanho. WITH NVL(Q&lcTamanho.,0) + TMP_ITENS_CONTAGEM.contagem
			ENDIF

			SELECT TMP_ITENS_CONTAGEM
		ENDSCAN
		SELECT v_Estoque_Prod_Contagem_00_Itens

		UPDATE v_Estoque_Prod_Contagem_00_Itens ;
			SET qtde_contagem = (q1+ q2+ q3+ q4+ q5+ q6+ q7+ q8+ q9+ q10+ q11+ q12+ q13+ q14+ q15+ q16),;
			diferenca_total = (q1+ q2+ q3+ q4+ q5+ q6+ q7+ q8+ q9+ q10+ q11+ q12+ q13+ q14+ q15+ q16) - saldo_contagem

		WAIT WINDOW NOWAIT "Produtos da contagem foram adicionados com sucesso..."
		f_wait()

	ENDPROC

	PROCEDURE refresh

	ENDPROC

	PROCEDURE when
		if ! thisformset.p_tool_status$'AI'
			WAIT WINDOW 'Somente em Inclusão e Alteração !' nowait
			RETURN  .f.
		endif
		IF V_ESTOQUE_PROD_CONTAGEM_00.TIPO <> "P"
			MESSAGEBOX("Este botão só pode ser clicado para Tipo de Inventário Parcial",16,"Aviso")
			RETURN .f.
		ENDIF
		RETURN .t.
	ENDPROC



ENDDEFINE

DEFINE CLASS btnFiltro as Botao
	Caption = "Aplicar"
	Height = 19
	Left = 701
	Enabled = .T.
	Top = 380
	Width = 59
	Name = "btnFiltro"
	Value = ""
	Visible = .t.

	PROCEDURE click
		SELECT v_estoque_prod_contagem_00_itens
		SET FILTER TO
		GO top

		IF USED("vfiltrotemp")
			SELECT vfiltrotemp
			USE
		ENDIF

		CREATE CURSOR vfiltrotemp (;
			filtro c(17) NULL )

		SET SAFETY OFF
		ZAP
		INDEX ON ALLTRIM(FILTRO) TAG XFILTRO1
		SET ORDER TO TAG XFILTRO1

		lcFiltro = ALLTRIM(thisformset.lx_FORM1.lx_pageframe1.Page1.ed_filtro.Value)
		nLinha1 = GETWORDCOUNT(lcFiltro,",")
		FOR ixx=1 TO nLinha1
			lcCampo = GETWORDNUM(lcFiltro,ixx,",")
			lcCampo = ALLTRIM(STRTRAN(STRTRAN(STRTRAN(STRTRAN(lcCampo,"'",""),["],""),'[',""),']',""))
			lcCampo = STRTRAN(STRTRAN(STRTRAN(lcCampo,CHR(9),""),CHR(13),""),CHR(10),"")
			INSERT INTO vfiltrotemp VALUES ( lcCampo )
		ENDFOR

		IF RECCOUNT("vfiltrotemp")>0

			SELECT v_estoque_prod_contagem_00_itens


			SET FILTER TO INDEXSEEK(ALLTRIM( ALLTRIM(v_estoque_prod_contagem_00_itens.produto)+;
				ALLTRIM(v_estoque_prod_contagem_00_itens.cor_produto) ) ,;
				.F.,;
				"VFILTROTEMP",;
				"XFILTRO1")
			GO top

			thisformset.LX_FORM1.LX_PAGEFRAME1.PAGE1.Refresh

		ELSE
			SELECT v_estoque_prod_contagem_00_itens
			SET FILTER TO
			GO top
		ENDIF
	ENDPROC && PROCEDURE click

ENDDEFINE

DEFINE CLASS btnLimpar as Botao
	Caption = "Limpar"
	Height = 19
	Left = 761
	Enabled = .T.
	Top = 380
	Width = 59
	Name = "btnLimpar"
	Value = ""
	Visible = .t.

	PROCEDURE click
		SELECT v_estoque_prod_contagem_00_itens
		SET FILTER TO
		GO top

		IF USED("vfiltrotemp")
			SELECT vfiltrotemp
			USE
		ENDIF

		CREATE CURSOR vfiltrotemp (;
			filtro c(17) NULL )

		SET SAFETY OFF
		ZAP
		INDEX ON ALLTRIM(FILTRO) TAG XFILTRO1
		SET ORDER TO TAG XFILTRO1

		thisformset.lx_FORM1.lx_pageframe1.Page1.ed_filtro.Value = ""
		thisformset.LX_FORM1.LX_PAGEFRAME1.PAGE1.Refresh
	ENDPROC && PROCEDURE click

ENDDEFINE


DEFINE CLASS cmb_justificativa as ComboBox
	rowsourcetype = 3 && SQL Statement
	rowsource = [f_execute('select justificativa from caedu_justificativas_inventario','vtmp_justificativa')]
	boundcolumn = 1
	boundto = .f.
	controlsource="v_estoque_prod_contagem_00_itens.erp_justificativa"
	style=2 && dropdown list
	name = "cmb_justificativa"
	columncount=1
	columnwidths = "260"
	width=174
ENDDEFINE


DEFINE CLASS cPageCaedu as Page

	PROCEDURE Activate
		thisform.refresh

		TRY
			this.removeobject("Lx_grid_filha1")
			this.addobject("Lx_grid_filha1","lx_grade_filha")
			this.Lx_grid_filha1.visible = .t.
			SELECT v_estoque_prod_contagem_00_itens
			GO top
			WITH this.Lx_grid_filha1
				.autofit
				.setfocus
			ENDWITH

		CATCH TO oErro
			WAIT WINDOW oErro.message
		FINALLY

		ENDTRY


	ENDPROC

ENDDEFINE

DEFINE CLASS lx_grade_filha as lx_grid_filha
	ColumnCount = -1
	ColumnCount = 25
	Height = 348
	Left = 8
	Panel = 1
	RecordSource = "v_estoque_prod_contagem_00_itens"
	ScrollBars = 3
	Top = 14
	Width = 813
	Name = "Lx_grid_filha1"
	Visible = .T.
	HighlightBackColor = RGB(253,230,181)
	HighlightForeColor = RGB(0,0,0)
	HighLightRow = .T.
	HighlightStyle = 0

	Anchor = 15

	Column1.ColumnOrder = 1
	Column1.ControlSource = "V_ESTOQUE_PROD_CONTAGEM_00_ITENS.PRODUTO"
	Column1.Width = 85
	Column1.Sparse = .T.
	Column1.ForeColor = RGB(0,0,0)
	Column1.BackColor = RGB(255,255,255)
	Column1.Name = "col_tx_PRODUTO"
	Column2.ColumnOrder = 9
	Column2.ControlSource = "V_ESTOQUE_PROD_CONTAGEM_00_ITENS.DESC_PRODUTO"
	Column2.Width = 199
	Column2.Sparse = .F.
	Column2.Name = "col_tx_DESC_PRODUTO"
	Column3.ColumnOrder = 11
	Column3.ControlSource = "V_ESTOQUE_PROD_CONTAGEM_00_ITENS.UNIDADE"
	Column3.Width = 57
	Column3.Sparse = .F.
	Column3.Name = "col_tx_UNIDADE"
	Column4.ColumnOrder = 12
	Column4.ControlSource = "V_ESTOQUE_PROD_CONTAGEM_00_ITENS.PESO"
	Column4.Width = 53
	Column4.Sparse = .F.
	Column4.Name = "col_tx_PESO"
	Column5.ColumnOrder = 2
	Column5.ControlSource = "V_ESTOQUE_PROD_CONTAGEM_00_ITENS.COR_PRODUTO"
	Column5.Width = 42
	Column5.Sparse = .T.
	Column5.DynamicBackColor = ""
	Column5.Name = "col_tx_COR_PRODUTO"
	Column6.ColumnOrder = 10
	Column6.ControlSource = "V_ESTOQUE_PROD_CONTAGEM_00_ITENS.DESC_COR_PRODUTO"
	Column6.Width = 122
	Column6.Sparse = .F.
	Column6.Name = "col_tx_DESC_COR_PRODUTO"
	Column7.ColumnOrder = 13
	Column7.ControlSource = "V_ESTOQUE_PROD_CONTAGEM_00_ITENS.REFER_FABRICANTE"
	Column7.Width = 101
	Column7.Sparse = .F.
	Column7.Name = "col_tx_REFER_FABRICANTE"
	Column8.ColumnOrder = 14
	Column8.ControlSource = "V_ESTOQUE_PROD_CONTAGEM_00_ITENS.REVENDA"
	Column8.Width = 59
	Column8.Sparse = .F.
	Column8.Name = "col_tx_REVENDA"
	Column9.ColumnOrder = 15
	Column9.ControlSource = "V_ESTOQUE_PROD_CONTAGEM_00_ITENS.COR_SORTIDA"
	Column9.Width = 72
	Column9.Sparse = .F.
	Column9.Name = "col_tx_COR_SORTIDA"
	Column10.ColumnOrder = 3
	Column10.ControlSource = "V_ESTOQUE_PROD_CONTAGEM_00_ITENS.QTDE_CONTAGEM"
	Column10.Width = 56
	Column10.ReadOnly = .T.
	Column10.Sparse = .T.
	Column10.DynamicBackColor = "iif(diferenca_total # 0, RGB(192,192,192), RGB(255,255,255))"
	Column10.DynamicForeColor = "iif(diferenca_total # 0, RGB(255,0,0),RGB(0,0,0))"
	Column10.Name = "col_tx_QTDE_CONTAGEM"
	Column11.ColumnOrder = 4
	Column11.ControlSource = "V_ESTOQUE_PROD_CONTAGEM_00_ITENS.SALDO_CONTAGEM"
	Column11.Width = 59
	Column11.ReadOnly = .T.
	Column11.Sparse = .T.
	Column11.DynamicBackColor = "iif(diferenca_total # 0, RGB(128,128,128), RGB(255,255,255))"
	Column11.DynamicForeColor = "iif(diferenca_total # 0, RGB(255,255,0),RGB(0,0,0))"
	Column11.BackColor = RGB(255,255,255)
	Column11.Name = "col_tx_SALDO_CONTAGEM"
	Column12.ColumnOrder = 7
	Column12.ControlSource = "V_ESTOQUE_PROD_CONTAGEM_00_ITENS.Q43"
	Column12.Width = 32
	Column12.Sparse = .F.
	Column12.DynamicForeColor = ""
	Column12.Name = "col_tx_Q43"
	Column13.ColumnOrder = 8
	Column13.ControlSource = "V_ESTOQUE_PROD_CONTAGEM_00_ITENS.S1"
	Column13.Width = 32
	Column13.ReadOnly = .T.
	Column13.Sparse = .F.
	Column13.DynamicBackColor = ""
	Column13.DynamicForeColor = "iif(v_estoque_prod_contagem_00_itens.diferenca_total # 0,RGB(255,255,0), RGB(0,0,0))"
	Column13.BackColor = RGB(255,255,255)
	Column13.Name = "col_tx_S1"
	Column14.ColumnOrder = 5
	Column14.ControlSource = "v_estoque_prod_contagem_00_itens.diferenca_total"
	Column14.Width = 58
	Column14.ReadOnly = .T.
	Column14.DynamicBackColor = "iif(diferenca_total # 0, RGB(128,128,128), RGB(255,255,255))"
	Column14.DynamicForeColor = "iif(v_estoque_prod_contagem_00_itens.diferenca_total # 0,RGB(0,255,255), RGB(0,0,0))"
	Column14.ForeColor = RGB(0,0,0)
	Column14.BackColor = RGB(255,255,255)
	Column14.Name = "Column108"
	Column15.FontName = "Tahoma"
	Column15.FontSize = 8
	Column15.ColumnOrder = 6
	Column15.ControlSource = "V_estoque_prod_contagem_00_itens.VALOR_CONTAGEM_DIFERENCA"
	Column15.Width = 112
	Column15.Sparse = .F.
	Column15.Name = "COL_TX_VALOR_CONTAGEM_DIFERENCA"
	Column16.FontName = "Tahoma"
	Column16.FontSize = 8
	Column16.ColumnOrder = 19
	Column16.ControlSource = "V_estoque_prod_contagem_00_itens.CUSTO4_A_VALORIZAR"
	Column16.Width = 112
	Column16.Sparse = .F.
	Column16.Name = "COL_TX_CUSTO4_A_VALORIZAR"
	Column17.FontName = "Tahoma"
	Column17.FontSize = 8
	Column17.ColumnOrder = 18
	Column17.ControlSource = "V_estoque_prod_contagem_00_itens.CUSTO3_A_VALORIZAR"
	Column17.Width = 112
	Column17.Sparse = .F.
	Column17.Name = "COL_TX_CUSTO3_A_VALORIZAR"
	Column18.FontName = "Tahoma"
	Column18.FontSize = 8
	Column18.ColumnOrder = 17
	Column18.ControlSource = "V_estoque_prod_contagem_00_itens.CUSTO2_A_VALORIZAR"
	Column18.Width = 112
	Column18.Sparse = .F.
	Column18.Name = "COL_TX_CUSTO2_A_VALORIZAR"
	Column19.FontName = "Tahoma"
	Column19.FontSize = 8
	Column19.ColumnOrder = 16
	Column19.ControlSource = "V_estoque_prod_contagem_00_itens.CUSTO1_A_VALORIZAR"
	Column19.Width = 112
	Column19.Sparse = .F.
	Column19.Name = "COL_TX_CUSTO1_A_VALORIZAR"
	Column20.FontName = "Tahoma"
	Column20.FontSize = 8
	Column20.ColumnOrder = 20
	Column20.ControlSource = "V_estoque_prod_contagem_00_itens.GRUPO_PRODUTO"
	Column20.Width = 175
	Column20.Sparse = .F.
	Column20.Name = "COL_TX_GRUPO_PRODUTO"
	Column21.FontName = "Tahoma"
	Column21.FontSize = 8
	Column21.ColumnOrder = 21
	Column21.ControlSource = "V_estoque_prod_contagem_00_itens.SUBGRUPO_PRODUTO"
	Column21.Width = 175
	Column21.Sparse = .F.
	Column21.Name = "COL_TX_SUBGRUPO_PRODUTO"
	Column22.FontName = "Tahoma"
	Column22.FontSize = 8
	Column22.ColumnOrder = 22
	Column22.ControlSource = "V_estoque_prod_contagem_00_itens.CUSTO_REPOSICAO1"
	Column22.Width = 135
	Column22.Sparse = .F.
	Column22.Name = "COL_TX_CUSTO_REPOSICAO1"
	Column23.FontName = "Tahoma"
	Column23.FontSize = 8
	Column23.ColumnOrder = 23
	Column23.ControlSource = "V_estoque_prod_contagem_00_itens.CUSTO_REPOSICAO4"
	Column23.Width = 112
	Column23.Sparse = .F.
	Column23.Name = "COL_TX_CUSTO_REPOSICAO4"
	Column24.FontName = "Tahoma"
	Column24.FontSize = 8
	Column24.ColumnOrder = 24
	Column24.ControlSource = "V_estoque_prod_contagem_00_itens.LINHA"
	Column24.Width = 210
	Column24.Sparse = .F.
	Column24.Name = "COL_TX_LINHA"
	Column25.FontName = "Tahoma"
	Column25.FontSize = 8
	Column25.ColumnOrder = 25
	Column25.ControlSource = "V_estoque_prod_contagem_00_itens.GRIFFE"
	Column25.Width = 210
	Column25.Sparse = .F.
	Column25.Name = "COL_TX_GRIFFE"


	PROCEDURE init

		*** Configura as colunas do Grid
		** Passa objeto thisformset
		*DODEFAULT()
		ConfigGrid(this.Parent.Parent.Parent.Parent)

	ENDPROC

	PROCEDURE AfterRowColChange
		LPARAMETERS nColIndex
		WITH this
			.col_tx_Q43.Lx_grade48_1.l_grade()
			.col_tx_s1.Lx_grade48_1.l_grade()
			.autofit
		ENDWITH

		*!*	This.parent.Lx_grade48_1.l_grade()
		*!*	This.Parent.Lx_textbox_base1.refresh()
		*!*	This.Parent.Lx_textbox_base2.refresh()
		*!*	This.parent.Lx_grade48_1.refresh()
	ENDPROC



ENDDEFINE

PROCEDURE ConfigGrid
	PARAMETERS oFormSet
	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_produto.ADDOBJECT("h_tx_produto","header")
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_produto.h_tx_produto
		.FontName = "Tahoma"
		.FontSize = 8
		.Alignment = 2
		.Name = "H_tx_PRODUTO"
		.Caption = "Produto"
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_produto.addobject("lx_textbox_valida1","lx_textbox_valida")
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_produto.lx_textbox_valida1
		*.ControlSource = "V_ESTOQUE_PROD_CONTAGEM_00_ITENS.PRODUTO"
		.Height = 17
		.Left = 3
		.Top = 25
		.Width = 87
		.ForeColor = RGB(0,0,0)
		.BackColor = RGB(255,255,255)
		.p_tipo_dado = "EDITA"
		.p_valida_coluna = "PRODUTO"
		.p_valida_coluna_tabela = "PRODUTOS"
		.Name = "Lx_textbox_valida1"
		.Parent.CurrentControl = "Lx_textbox_valida1"
		.Visible = .T.
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_desc_produto.AddObject("h_tx_desc_produto","header")
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_desc_produto.h_tx_desc_produto
		.FontName = "Tahoma"
		.FontSize = 8
		.Alignment = 2
		.Caption = "Desc Produto"
		.Name = "H_tx_DESC_PRODUTO"
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_desc_produto.AddObject("tx_desc_produto","lx_textbox_base")
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_desc_produto.tx_desc_produto
		.Format = "!"
		.Name = "tx_DESC_PRODUTO"
		.Parent.CurrentControl = "tx_DESC_PRODUTO"
		.Visible = .T.
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_unidade.AddObject("h_tx_unidade","header")
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_unidade.h_tx_unidade
		.FontName = "Tahoma"
		.FontSize = 8
		.Alignment = 2
		.Caption = "Unidade"
		.Name = "H_tx_UNIDADE"
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_unidade.AddObject("tx_unidade","lx_textbox_base")
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_unidade.tx_unidade
		.Format = "!"
		.Name = "tx_UNIDADE"
		.Parent.CurrentControl = "tx_UNIDADE"
		.Visible = .T.
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_peso.AddObject("h_tx_peso","header")
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_peso.h_tx_peso
		.FontName = "Tahoma"
		.FontSize = 8
		.Alignment = 2
		.Caption = "Peso"
		.Name = "H_tx_PESO"
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_peso.AddObject("tx_peso","lx_textbox_base")
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_peso.tx_peso
		.Alignment = 1
		.InputMask = "999.999"
		.Name = "tx_PESO"
		.Parent.CurrentControl = "tx_PESO"
		.Visible = .T.
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_cor_produto.AddObject("h_tx_cor_produto","header")
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_cor_produto.h_tx_cor_produto
		.FontName = "Tahoma"
		.FontSize = 8
		.Alignment = 2
		.Caption = "Cor"
		.Name = "H_tx_COR_PRODUTO"
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_cor_produto.AddObject("lx_textbox_valida1","lx_textbox_valida")
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_cor_produto.lx_textbox_valida1
		*.ControlSource = "V_ESTOQUE_PROD_CONTAGEM_00_ITENS.COR_PRODUTO"
		.Height = 15
		.Left = 1
		.Top = 22
		.Width = 74
		.p_valida_where = "AND produto = ?V_ESTOQUE_prod_CONTAGEM_00_ITENS.produto"
		.p_tabela_source = "V_ESTOQUE_PROD_CONTAGEM_00_ITENS"
		.p_tipo_dado = "EDITA"
		.p_valida_coluna = "COR_PRODUTO"
		.p_valida_coluna_tabela = "PRODUTO_CORES"
		.Name = "Lx_textbox_valida1"
		.Parent.CurrentControl = "Lx_textbox_valida1"
		.Visible = .T.
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_desc_cor_produto.AddObject("h_tx_desc_cor_produto","header")
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_desc_cor_produto.h_tx_desc_cor_produto
		.FontName = "Tahoma"
		.FontSize = 8
		.Alignment = 2
		.Caption = "Desc Cor Produto"
		.Name = "H_tx_DESC_COR_PRODUTO"
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_desc_cor_produto.AddObject("tx_desc_cor_produto","lx_textbox_base")
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_desc_cor_produto.tx_desc_cor_produto
		.Format = "!"
		.Name = "tx_DESC_COR_PRODUTO"
		.Parent.CurrentControl = "tx_DESC_COR_PRODUTO"
		.Visible = .T.
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_refer_fabricante.AddObject("h_tx_refer_fabricante","header")
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_refer_fabricante.h_tx_refer_fabricante
		.FontName = "Tahoma"
		.FontSize = 8
		.Alignment = 2
		.Caption = "Refer Fabricante"
		.Name = "H_tx_REFER_FABRICANTE"
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_refer_fabricante.AddObject("tx_refer_fabricante","lx_textbox_base")
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_refer_fabricante.tx_refer_fabricante
		.Format = "!"
		.Name = "tx_REFER_FABRICANTE"
		.Parent.CurrentControl = "tx_REFER_FABRICANTE"
		.Visible = .T.
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_revenda.AddObject("h_tx_revenda","header")
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_revenda.h_tx_revenda
		.FontName = "Tahoma"
		.FontSize = 8
		.Alignment = 2
		.Caption = "Revenda"
		.Name = "H_tx_REVENDA"
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_revenda.AddObject("tx_revenda","lx_textbox_base")
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_revenda.tx_revenda
		.Name = "tx_REVENDA"
		.Parent.CurrentControl = "tx_REVENDA"
		.Visible = .T.
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_cor_sortida.AddObject("h_tx_cor_sortida","header")
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_cor_sortida.h_tx_cor_sortida
		.FontName = "Tahoma"
		.FontSize = 8
		.Alignment = 2
		.Caption = "Cor Sortida"
		.Name = "H_tx_COR_SORTIDA"
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_cor_sortida.AddObject("tx_cor_sortida","lx_textbox_base")
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_cor_sortida.tx_cor_sortida
		.Name = "tx_COR_SORTIDA"
		.Parent.CurrentControl = "tx_COR_SORTIDA"
		.Visible = .T.
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_qtde_contagem.AddObject("h_tx_qtde_contagem","header")
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_qtde_contagem.h_tx_qtde_contagem
		.FontName = "Tahoma"
		.FontSize = 8
		.Alignment = 2
		.Caption = "Qtde Ctg"
		.Name = "H_tx_QTDE_CONTAGEM"
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_qtde_contagem.AddObject("tx_qtde_contagem","lx_textbox_base" )
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_qtde_contagem.tx_qtde_contagem
		*ControlSource = "V_ESTOQUE_PROD_CONTAGEM_00_ITENS.QTDE_CONTAGEM"
		.ReadOnly = .T.
		.BackColor = RGB(255,255,255)
		.p_tipo_dado = "mostra"
		.Name = "tx_QTDE_CONTAGEM"
		.Parent.CurrentControl = "tx_QTDE_CONTAGEM"
		.Visible = .T.
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_saldo_contagem.AddObject("h_tx_saldo_contagem","header" )
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_saldo_contagem.h_tx_saldo_contagem
		.FontName = "Tahoma"
		.FontSize = 8
		.Alignment = 2
		.Caption = "Saldo"
		.Name = "H_tx_SALDO_CONTAGEM"
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_saldo_contagem.AddObject("tx_saldo_contagem","lx_textbox_base" )
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_saldo_contagem.tx_saldo_contagem
		.ReadOnly = .T.
		.BackColor = RGB(255,255,255)
		.p_tipo_dado = "mostra"
		.Name = "tx_SALDO_CONTAGEM"
		.Parent.CurrentControl = "tx_SALDO_CONTAGEM"
		.Visible = .T.
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_q43.AddObject("h_tx_q43","header" )
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_q43.h_tx_q43
		.FontName = "Tahoma"
		.FontSize = 8
		.Alignment = 2
		.Caption = "Q43"
		.ForeColor = RGB(255,0,0)
		.Name = "H_tx_Q43"
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_q43.AddObject("lx_grade48_1","lx_grade48_1" )
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_q43.lx_grade48_1
		.Top = 28
		.Left = 10
		.p_view = "V_ESTOQUE_PROD_CONTAGEM_00_ITENS"
		.p_view_campo = "q"
		.p_campo_total = "QTDE_CONTAGEM"
		.Name = "Lx_grade48_1"
		.Parent.CurrentControl = "Lx_grade48_1"
		.Visible = .T.
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_s1.AddObject("h_tx_s1","header" )
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_s1.h_tx_s1
		.FontName = "Tahoma"
		.FontSize = 8
		.Alignment = 2
		.Caption = "S1"
		.ForeColor = RGB(255,255,0)
		.Name = "H_tx_S1"
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_s1.AddObject("lx_grade48_1","lx_grade48_2" )
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_s1.lx_grade48_1
		.Top = 30
		.Left = 23
		.p_view = "V_ESTOQUE_PROD_CONTAGEM_00_ITENS"
		.p_view_campo = "s"
		.p_campo_total = "saldo_contagem"
		.p_tipo_dado = "mostra"
		.Name = "Lx_grade48_1"
		.Parent.CurrentControl = "Lx_grade48_1"
		.Visible = .T.
	ENDWITH

	*oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.column108.AddObject("header1","header" )
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.column108.header1
		.FontName = "Tahoma"
		.FontSize = 8
		.Alignment = 2
		.Caption = "Diferença"
		.Name = "Header1"
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.column108.AddObject("lx_textbox_base1","lx_textbox_base" )
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.column108.lx_textbox_base1
		.Left = 32
		.Top = 23
		.ForeColor = RGB(0,0,0)
		.BackColor = RGB(255,255,255)
		.p_tipo_dado = "mostra"
		.Name = "Lx_textbox_base1"
		.Parent.CurrentControl = "Lx_textbox_base1"
		.Visible = .T.
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_valor_contagem_diferenca.AddObject("h_tx_valor_contagem_diferenca","header" )
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_valor_contagem_diferenca.h_tx_valor_contagem_diferenca
		.FontName = "Tahoma"
		.FontSize = 8
		.Alignment = 2
		.Caption = "Valor da contagem"
		.Name = "H_TX_VALOR_CONTAGEM_DIFERENCA"
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_valor_contagem_diferenca.AddObject("tx_valor_contagem_diferenca","lx_textbox_base" )
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_valor_contagem_diferenca.tx_valor_contagem_diferenca
		.Name = "TX_VALOR_CONTAGEM_DIFERENCA"
		.Parent.CurrentControl = "tx_VALOR_CONTAGEM_DIFERENCA"
		.Visible = .T.
	ENDWITH


	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_custo4_a_valorizar.AddObject("h_tx_custo4_a_valorizar","header" )
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_custo4_a_valorizar.h_tx_custo4_a_valorizar
		.FontName = "Tahoma"
		.FontSize = 8
		.Alignment = 2
		.Caption = "Custo4 A Valorizar"
		.Name = "H_TX_CUSTO4_A_VALORIZAR"
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_custo4_a_valorizar.AddObject("tx_custo4_a_valorizar","lx_textbox_base" )
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_custo4_a_valorizar.tx_custo4_a_valorizar
		Name = "tx_CUSTO4_A_VALORIZAR"
		.Parent.CurrentControl = "tx_CUSTO4_A_VALORIZAR"
		.Visible = .T.
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_custo3_a_valorizar.AddObject("h_tx_custo3_a_valorizar","header" )
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_custo3_a_valorizar.h_tx_custo3_a_valorizar
		.FontName = "Tahoma"
		.FontSize = 8
		.Alignment = 2
		.Caption = "Custo3 A Valorizar"
		.Name = "H_TX_CUSTO3_A_VALORIZAR"
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_custo3_a_valorizar.AddObject("tx_custo3_a_valorizar","lx_textbox_base" )
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_custo3_a_valorizar.tx_custo3_a_valorizar
		.Name = "tx_CUSTO3_A_VALORIZAR"
		.Parent.CurrentControl = "tx_CUSTO3_A_VALORIZAR"
		.Visible = .T.
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_custo2_a_valorizar.AddObject("h_tx_custo2_a_valorizar","header" )
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_custo2_a_valorizar.h_tx_custo2_a_valorizar
		.FontName = "Tahoma"
		.FontSize = 8
		.Alignment = 2
		.Caption = "Custo2 A Valorizar"
		.Name = "H_TX_CUSTO2_A_VALORIZAR"
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_custo2_a_valorizar.AddObject("tx_custo2_a_valorizar","lx_textbox_base" )
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_custo2_a_valorizar.tx_custo2_a_valorizar
		.Name = "tx_CUSTO2_A_VALORIZAR"
		.Parent.CurrentControl = "tx_CUSTO2_A_VALORIZAR"
		.Visible = .T.
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_custo1_a_valorizar.AddObject("h_tx_custo1_a_valorizar","header" )
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_custo1_a_valorizar.h_tx_custo1_a_valorizar
		.FontName = "Tahoma"
		.FontSize = 8
		.Alignment = 2
		.Caption = "Custo1 A Valorizar"
		.Name = "H_TX_CUSTO1_A_VALORIZAR"
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_custo1_a_valorizar.AddObject("tx_custo1_a_valorizar","lx_textbox_base" )
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_custo1_a_valorizar.tx_custo1_a_valorizar
		.Name = "tx_CUSTO1_A_VALORIZAR"
		.Parent.CurrentControl = "tx_CUSTO1_A_VALORIZAR"
		.Visible = .T.
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_grupo_produto.AddObject("h_tx_grupo_produto","header" )
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_grupo_produto.h_tx_grupo_produto
		.FontName = "Tahoma"
		.FontSize = 8
		.Alignment = 2
		.Caption = "Grupo Produto"
		.Name = "H_TX_GRUPO_PRODUTO"
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_grupo_produto.AddObject("tx_grupo_produto","lx_textbox_base" )
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_grupo_produto.tx_grupo_produto
		.Name = "TX_GRUPO_PRODUTO"
		.Parent.CurrentControl = "tx_GRUPO_PRODUTO"
		.Visible = .T.
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_subgrupo_produto.AddObject("h_tx_subgrupo_produto","header" )
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_subgrupo_produto.h_tx_subgrupo_produto
		.FontName = "Tahoma"
		.FontSize = 8
		.Alignment = 2
		.Caption = "Subgrupo Produto"
		.Name = "H_TX_SUBGRUPO_PRODUTO"
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_subgrupo_produto.AddObject("tx_subgrupo_produto","lx_textbox_base" )
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_subgrupo_produto.tx_subgrupo_produto
		.Name = "TX_SUBGRUPO_PRODUTO"
		.Parent.CurrentControl = "tx_SUBGRUPO_PRODUTO"
		.Visible = .T.
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_custo_reposicao1.AddObject("h_tx_custo_reposicao1","header" )
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_custo_reposicao1.h_tx_custo_reposicao1
		.FontName = "Tahoma"
		.FontSize = 8
		.Alignment = 2
		.Caption = "Custo Reposicao1"
		.Name = "H_TX_CUSTO_REPOSICAO1"
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_custo_reposicao1.AddObject("tx_custo_reposicao1","lx_textbox_base" )
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_custo_reposicao1.tx_custo_reposicao1
		.Name = "tx_CUSTO_REPOSICAO1"
		.Parent.CurrentControl = "tx_CUSTO_REPOSICAO1"
		.Visible = .T.
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_custo_reposicao4.AddObject("h_tx_custo_reposicao4","header" )
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_custo_reposicao4.h_tx_custo_reposicao4
		.FontName = "Tahoma"
		.FontSize = 8
		.Alignment = 2
		.Caption = "Custo Reposicao4"
		.Name = "H_TX_CUSTO_REPOSICAO4"
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_custo_reposicao4.AddObject("tx_custo_reposicao4","lx_textbox_base" )
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_custo_reposicao4.tx_custo_reposicao4
		*ControlSource = "V_estoque_prod_contagem_00_itens.CUSTO_REPOSICAO4"
		.Name = "tx_CUSTO_REPOSICAO4"
		.Parent.CurrentControl = "tx_CUSTO_REPOSICAO4"
		.Visible = .T.
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_linha.AddObject("h_tx_linha","header" )
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_linha.h_tx_linha
		.FontName = "Tahoma"
		.FontSize = 8
		.Alignment = 2
		.Caption = "Linha"
		.Name = "H_TX_LINHA"
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_linha.AddObject("tx_linha","lx_textbox_base" )
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_linha.tx_linha
		.Name = "TX_LINHA"
		.Parent.CurrentControl = "tx_LINHA"
		.Visible = .T.
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_griffe.AddObject("h_tx_griffe","header" )
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_griffe.h_tx_griffe
		.FontName = "Tahoma"
		.FontSize = 8
		.Alignment = 2
		.Caption = "Griffe"
		.Name = "H_TX_GRIFFE"
	ENDWITH

	oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_griffe.AddObject("tx_griffe","lx_textbox_base" )
	WITH oFormSet.lx_form1.lx_pageframe1.pgCaedu.lx_grid_filha1.col_tx_griffe.tx_griffe
		.Name = "TX_GRIFFE"
		.Parent.CurrentControl = "tx_GRIFFE"
		.Visible = .T.
	ENDWITH

ENDPROC

DEFINE CLASS lx_grade48_1 as lx_grade48_
	p_view = "V_ESTOQUE_PROD_CONTAGEM_00_ITENS"
	p_view_campo = "q"
	p_campo_total = "QTDE_CONTAGEM"
	name = "Lx_grade48_1"

	PROCEDURE l_desenhista_recalculo
		lparam xparam
		sele v_estoque_prod_contagem_00_itens
		XQTDE_TOTAL 	=	q1  + q2  + q3  + q4  + q5  + q6  + q7  + q8  + q9  + q10 + ;
			q11 + q12 + q13 + q14 + q15 + q16 + q17 + q18 + q19 + q20 + ;
			q21 + q22 + q23 + q24 + q25 + q26 + q27 + q28 + q29 + q30 + ;
			q31 + q32 + q33 + q34 + q35 + q36 + q37 + q38 + q39 + q40 + ;
			q41 + q42 + q43 + q44 + q45 + q46 + q47 + q48


		repl qtde_contagem with xqtde_total

		xSaldos = f_tam()
		xQuant	= f_tam()
		xDifer	= f_tam()

		sele v_estoque_prod_contagem_00_itens
		xSaldos.Set(0)
		xQuant.Set(0)
		xDifer.Set(0)

		xSaldos.carga('S#')
		xQuant.Carga('Q#')

		xDifer.Calcula(xQuant,xSaldos,'-')			&& Diferença das grades
		*/*				|		'============> Saldos do Estoque ...
		*/*				'====================> Quantidade Contada...
		xDifer.Descarga('D#','Diferenca_Total')
		This.Parent.Parent.Parent.refresh()
	ENDPROC

ENDDEFINE

DEFINE CLASS lx_grade48_2 as lx_grade48_
	p_view = "V_ESTOQUE_PROD_CONTAGEM_00_ITENS"
	p_view_campo = "s"
	p_campo_total = "saldo_contagem"
	p_tipo_dado = "mostra"
	name = "Lx_grade48_2"

	***         usa o default
	*!*		PROCEDURE l_desenhista_recalculo
	*!*			lparam xparam
	*!*			sele v_estoque_prod_contagem_00_itens
	*!*			XQTDE_TOTAL 	=	q1  + q2  + q3  + q4  + q5  + q6  + q7  + q8  + q9  + q10 + ;
	*!*								q11 + q12 + q13 + q14 + q15 + q16 + q17 + q18 + q19 + q20 + ;
	*!*								q21 + q22 + q23 + q24 + q25 + q26 + q27 + q28 + q29 + q30 + ;
	*!*								q31 + q32 + q33 + q34 + q35 + q36 + q37 + q38 + q39 + q40 + ;
	*!*								q41 + q42 + q43 + q44 + q45 + q46 + q47 + q48


	*!*			repl qtde_contagem with xqtde_total

	*!*			xSaldos = f_tam()
	*!*			xQuant	= f_tam()
	*!*			xDifer	= f_tam()

	*!*			sele v_estoque_prod_contagem_00_itens
	*!*			xSaldos.Set(0)
	*!*			xQuant.Set(0)
	*!*			xDifer.Set(0)

	*!*			xSaldos.carga('S#')
	*!*			xQuant.Carga('Q#')

	*!*			xDifer.Calcula(xQuant,xSaldos,'-')			&& Diferença das grades
	*!*			*/*				|		'============> Saldos do Estoque ...
	*!*			*/*				'====================> Quantidade Contada...
	*!*			xDifer.Descarga('D#','Diferenca_Total')
	*!*			This.Parent.Parent.Parent.refresh()
	*!*		ENDPROC

ENDDEFINE


DEFINE CLASS Lx_label6 as Label

	Caption = "Ajustado por"
	Autosize = .t.
	FontBold = .f.
	Height = 15
	Left = 638
	Name = "Lx_label6"
	Top = 6
	Width = 68

ENDDEFINE

DEFINE CLASS  Lx_textbox_base1 as Lx_textbox_base

	ControlSource = "v_estoque_prod_contagem_00.aprovado_por"
	FontBold = .f.
	Height = 22
	Left = 634
	ReadOnly = .t.
	Name = "Lx_textbox_base1"
	Top = 19
	Width = 177
	p_tipo_dado = "Mostra"

ENDDEFINE



DEFINE CLASS lblInventario as Label
	top = 403
	left = 17
	Height = 15
	Width = 104
	AutoSize = .t.
	Caption = "Selecionar Inventário"
	Name = "lblInventario"
ENDDEFINE

DEFINE CLASS ck_ImportaSQL as Lx_checkbox
	top = 403
	left = 139
	Height = 15
	Width = 105
	AutoSize = .t.
	Caption = "Importar pelo SQL"
	Name = "ck_ImportaSQL"
	Alignment = 0
	SpecialEffect = 0
	Style=0
	p_muda_size = .f.
	p_tipo_dado = "MOSTRA"

	PROCEDURE refresh
		this.Enabled = thisformset.p_tool_status $ 'IA'
	ENDPROC

	PROCEDURE valid
		this.Parent.cboInventarioPDA.Refresh()
		this.Parent.btnInventarioPDA.Refresh()
		this.Parent.tx_arquivo.Refresh()
		this.Parent.botao2.Refresh()
		this.Parent.botAO_TRAZ_CONTAGEM.Refresh()
	ENDPROC

ENDDEFINE

DEFINE CLASS cboInventarioPDA as Lx_combobox
	top = 421
	left = 15
	Height = 20
	Width = 237
	ColumnCount = 2
	BoundTo = .t.
	BoundColumn = 2
	ColumnWidths = "280,70"
	ControlSource = "v_estoque_prod_contagem_00.id_arq_pda_contagem"
	RowSourceType= 3
	RowSource = [F_SELECT("select nome_inventario,id_inventario from PDA_TB_ARQUIVO_CONTAGEM group by id_inventario, nome_inventario ORDER BY ID_INVENTARIO DESC","CBO_INVENT01")]
	Name = "cboInventarioPDA"

	PROCEDURE refresh
		this.Enabled = thisformset.p_tool_status $ 'IA' and this.Parent.ck_importaSQL.Value = 1
	ENDPROC

ENDDEFINE

DEFINE CLASS btnInventarioPDA as Botao
	top = 445
	left = 15
	Height = 22
	Width = 149
	Caption = "Importar Contagem (SQL)"
	Name = "btnInventarioPDA"

	PROCEDURE when
		if ! thisformset.p_tool_status$'AI'
			WAIT WINDOW 'Somente em Inclusão e Alteração !' nowait
			retu .f.
		endif
	ENDPROC

	***     ROTINA ANTIGA - MODIFICADA EM SET/21
	*!*		PROCEDURE click
	*!*			local xalias_ant
	*!*			xalias_ant=Alias()

	*!*			if ! thisformset.p_tool_status$'AI' or V_ESTOQUE_PROD_CONTAGEM_00.ESTOQUE_AJUSTADO
	*!*				wait window 'Estoque já Ajustado !' nowait
	*!*				retu .f.
	*!*			endif

	*!*			sele v_estoque_prod_contagem_00_itens
	*!*			set order to  PRODCOR

	*!*			**thisformset.lx_importa_contagem_sql()
	*!*			lx_importa_contagem_sql()

	*!*			Sele &xalias_ant
	*!*		ENDPROC
	PROCEDURE click
		IF !NVL(V_ESTOQUE_PROD_CONTAGEM_00.ESTOQUE_AJUSTADO,.f.)

			IF !(thisformset.p_tool_status $ 'AI')
				thisformset.l_altera()
			ENDIF

			lImportaSQl = (this.Parent.ck_importaSQL.Value = 1)
			xcontagem = 6

			**Passo1: Incluir Itens
			This.Parent.Botao_inclusao.Click()

			if ! thisformset.p_tool_status$'AI' or recc('v_estoque_prod_contagem_00_itens')=0
				Wait Window 'Impossivel Processar Saldo do estoque, Faltam Itens ou não esta editando !'
				retu .f.
			endif

			**Passo2: Trazer saldos na data
			This.Parent.Botao1.Click()


			**Passo 3: Importar contagem
			If xcontagem = 6
				IF lImportaSQl
					*!*						IF ! this.Parent.btnInventarioPDA.Click()
					*!*							Wait window 'Erro na importação dos dados , cancelando.... '
					*!*							Return .f.
					*!*						ENDIF
					local xalias_ant
					xalias_ant=Alias()

					if ! thisformset.p_tool_status$'AI' or V_ESTOQUE_PROD_CONTAGEM_00.ESTOQUE_AJUSTADO
						wait window 'Estoque já Ajustado !' nowait
						retu .f.
					endif

					sele v_estoque_prod_contagem_00_itens
					set order to  PRODCOR

					**thisformset.lx_importa_contagem_sql()
					lx_importa_contagem_sql()

					Sele &xalias_ant

				ELSE
					If ! This.Parent.Botao_traz_contagem.Click()
						Wait window 'Erro na importação do arquivo , cancelando.... '
						Return .f.
					ENDIF
				ENDIF
			Endif

			*thisformset.l_salva()
			thisformset.p_agendamento = ''

		ENDIF
	ENDPROC


	PROCEDURE refresh
		this.Enabled = thisformset.p_tool_status $ 'IA' and this.Parent.ck_importaSQL.Value = 1
	ENDPROC


ENDDEFINE

PROCEDURE lx_importa_contagem_sql
	**
	nOldSele = SELECT()
	lImportaOK       = .T.
	cMsgErro         = ""
	cCRLF            = ( Chr(13) + Chr(10) )
	cArquivoContagem = ALLTRIM(o_005015.Lx_form1.Lx_pageframe1.Page3.cboInventarioPDA.DisplayValue)

	Select curArquivoImportacao
	Locate For Alltrim(NOME_ARQUIVO) == Alltrim(cArquivoContagem)

	If Found() AND F_Msg(["Arquivo de contagem já importado pelo menos uma vez. Continua assim mesmo ?", 4 + 32, "Atenção"]) == 7

		Select(nOldSele)
		Return .F.

	EndIf

	tcId_PDA = o_005015.Lx_form1.Lx_pageframe1.Page3.cboInventarioPDA.Value

	*!*		TEXT TO cSQL NOSHOW TEXTMERGE PRETEXT 7
	*!*		SELECT
	*!*			A.ID_INVENTARIO,
	*!*			A.SEQUENCIA,
	*!*			A.CODIGO_BARRA,
	*!*			A.CONTAGEM as QTDE_CONTAGEM,
	*!*			B.PRODUTO,
	*!*			B.COR_PRODUTO,
	*!*			B.TAMANHO
	*!*		FROM
	*!*			CAEDU_PDA_INVENTARIO_ITENS A
	*!*		INNER JOIN
	*!*			PRODUTOS_BARRA B
	*!*				ON B.CODIGO_BARRA = A.CODIGO_BARRA
	*!*		WHERE A.ID_INVENTARIO = <<tcId_PDA>>
	*!*		ORDER BY A.SEQUENCIA
	*!*		ENDTEXT
	TEXT TO cSQL NOSHOW TEXTMERGE
		SELECT
			A.ID_INVENTARIO,
			ROW_NUMBER() OVER(ORDER BY a.CODIGO_BARRA ASC) AS SEQUENCIA,
			A.CODIGO_BARRA,
			A.QUANTIDADE as QTDE_CONTAGEM,
			B.PRODUTO,
			B.COR_PRODUTO,
			B.TAMANHO
		FROM
			PDA_TB_ARQUIVO_CONTAGEM A
		INNER JOIN
			PRODUTOS_BARRA B
				ON B.CODIGO_BARRA = A.CODIGO_BARRA
		WHERE A.ID_INVENTARIO = <<tcId_PDA>>
		ORDER BY 2
	ENDTEXT

	F_SELECT(cSQL,"vCAEDU_PDA_INVENTARIO_ITENS")

	IF RECCOUNT("vCAEDU_PDA_INVENTARIO_ITENS") = 0
		MESSAGEBOX("Não há dados para importar para este inventário selecionado.",64,"Aviso")
		RETURN
	ENDIF

	If Used("curImportacaoContagem")
		USE in curImportacaoContagem
	EndIf

	Create Cursor curImportacaoContagem ( PRODUTO C(12), COR_PRODUTO C(10), TAMANHO C(4), QTDE_CONTAGEM I )
	SELECT curImportacaoContagem
	APPEND FROM DBF("vCAEDU_PDA_INVENTARIO_ITENS")
	GO TOP
	*!*		SET STEP ON
	*!*		WAIT WINDOW "VEJA"
	Messagebox.ShowProgress("Aguarde, fazendo importação do arquivo selecionado !")

	Select curImportacaoContagem
	Scan

		Select v_Estoque_Prod_Contagem_00_Itens
		** SYS(14) INDEX EXPRESSION RTRIM(PRODUTO) + RTRIM(COR_PRODUTO)
		Seek RTRIM(curImportacaoContagem.PRODUTO) + RTRIM(curImportacaoContagem.COR_PRODUTO)

		**LOCATE FOR PRODUTO = curImportacaoContagem.PRODUTO AND COR_PRODUTO = curImportacaoContagem.COR_PRODUTO
		F_WAIT("Atualizando produto "+ ALLTRIM(curImportacaoContagem.PRODUTO))
		cTamanho = Alltrim(curImportacaoContagem.TAMANHO)

		Replace QTDE_CONTAGEM   With ( QTDE_CONTAGEM + curImportacaoContagem.QTDE_CONTAGEM ), ;
			DIFERENCA_TOTAL With ( QTDE_CONTAGEM - SALDO_CONTAGEM ), ;
			Q&cTamanho      With ( Q&cTamanho + curImportacaoContagem.QTDE_CONTAGEM ), ;
			D&cTamanho      With ( Q&cTamanho - s&cTamanho )

		Select curImportacaoContagem

	EndScan
	f_wait()

	Select curArquivoImportacao
	Append Blank

	Replace NOME_ARQUIVO With cArquivoContagem

	Messagebox.ShowProgress()

	If Used("curImportacaoContagem")
		USE in curImportacaoContagem
	EndIf

	Select(nOldSele)
	Return .T.

ENDPROC

DEFINE CLASS Botao3 as Botao
	top = 441
	left = 653
	Height = 22
	Width = 101
	Caption = "Agendar"
	Name = "Botao3"
	Forecolor = RGB(128,0,0)

	PROCEDURE click
		SELECT V_ESTOQUE_PROD_CONTAGEM_00
		IF EMPTY(ALLTRIM(NVL(V_ESTOQUE_PROD_CONTAGEM_00.NOME_CONTAGEM,'')))
			MESSAGEBOX('Preencha o nome da contagem',16,'Atencao')
			RETURN .f.
		ENDIF

		SELECT curpropestoqueprodcontagem
		SCAN
			IF curpropestoqueprodcontagem.propriedade_requerida AND EMPTY(ALLTRIM(NVL(curpropestoqueprodcontagem.valor_propriedade,'')))
				MESSAGEBOX('Preencha a propriedade'+ALLTRIM(curpropestoqueprodcontagem.desc_propriedade),16,'Atencao')
				RETURN .f.
			ENDIF
		ENDSCAN

		lImportaSQl = (this.Parent.ck_importaSQL.Value = 1)

		IF lImportaSQl
			If Empty(This.Parent.cboInventarioPDA.Value)
				F_msg(['Selecione o inventario a ser importado !!', 16, 'Atenção !'])
				Return .f.
			Endif
		ELSE
			If Empty(This.Parent.tx_arquivo.Value)
				F_msg(['Selecione o Arquivo de contagem !!', 16, 'Atenção !'])
				Return .f.
			Endif
		ENDIF

		IF EMPTY(ALLTRIM(NVL(thisformset.p_agendamento,'')))
			MESSAGEBOX('Preencha o horario de agendamento',16,'Atencao')
			RETURN .f.
		ENDIF

		IF MESSAGEBOX('O processo irá iniciar as '+ALLTRIM(thisformset.p_agendamento)+'...'+CHR(13)+CHR(10)+'Deixe a tela aberta para o processo rodar automaticamente!'+;
				CHR(13)+CHR(10)+'Deseja continuar?',36,'Agendamento') = 6
			this.Parent.timer1.Enabled = .t.
		ENDIF
	ENDPROC

ENDDEFINE

DEFINE CLASS Lx_textbox_base2 as Lx_textbox_base
	Alignment = 2
	ControlSource = "ThisFormSet.P_agendamento"
	Height = 22
	InputMask = "99:99"
	Left = 668
	Name = "Lx_textbox_base2"
	Top = 417
	Width = 72
	p_tipo_dado = "CHAVE"
ENDDEFINE

DEFINE CLASS timer1 as Timer
	Enabled = .f.
	Height = 23
	Interval = 20000
	Left = 787
	Name = "Timer1"
	Top = 441
	Width = 23

	PROCEDURE Timer
		Local xcontagem
		xhora = SUBSTR(TIME(),1,5)
		IF ALLTRIM(xhora) = ALLTRIM(thisformset.p_agendamento) AND !NVL(V_ESTOQUE_PROD_CONTAGEM_00.ESTOQUE_AJUSTADO,.f.)
			this.Enabled = .f.
			IF !(thisformset.p_tool_status $ 'AI')
				thisformset.l_altera()
			ENDIF

			lImportaSQl = (this.Parent.ck_importaSQL.Value = 1)
			xcontagem = 6

			**Passo1: Incluir Itens
			This.Parent.Botao_inclusao.Click()

			if ! thisformset.p_tool_status$'AI' or recc('v_estoque_prod_contagem_00_itens')=0
				Wait Window 'Impossivel Processar Saldo do estoque, Faltam Itens ou não esta editando !'
				retu .f.
			endif

			**Passo2: Trazer saldos na data
			This.Parent.Botao1.Click()


			**Passo 3: Importar contagem
			If xcontagem = 6
				IF lImportaSQl
					IF ! this.Parent.btnInventarioPDA.Click()
						Wait window 'Erro na importação dos dados , cancelando.... '
						Return .f.
					ENDIF
				ELSE
					If ! This.Parent.Botao_traz_contagem.Click()
						Wait window 'Erro na importação do arquivo , cancelando.... '
						Return .f.
					ENDIF
				ENDIF
			Endif

			thisformset.l_salva()
			thisformset.p_agendamento = ''
		ENDIF
	ENDPROC
ENDDEFINE

