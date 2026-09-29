*-- Funções Para os Relatórios da tela: 040004
*---------------------------------------------------------------------------------------------------------------------------------------------------*

*-------  Selecionar Colunas
Function Obter_Colunas
	Param xncols
	f_select('select preco_tipo from preco_tipos','tmp_select',Alias())
	System.executeform("lxoprel_colunas", "tmp_select.preco_tipo", xncols)
Endfunc
*---------------------------------------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------------------------------------*
*-------  Custo Industrial ( pela media quando mais de um produto selecionado OU cor não selecionada na tela )
Function Processa_Industrial
	Parameters xAddOpExtra,xAddOpRotas,xFazMedia,xProcessaPreco

	xFiltZer = Iif(xProcessaPreco,f_Msg(['Índices de Preços:'+CHR(13)+'Deseja Filtrar Zerados?',36,'Industrial - Preços:'])=6,.F.)
	Local rMat,rValor,rCont
	xalias_ant=Alias()

	*--- Cursor Custo
	Select *,valor As media_valor, 00000000.0000000 As media_consumo_base, 00000000.0000000 As media_custo_a_vista_cor,;
		SPACE(8) tamanho_base, 0 As Ord, 0000 As Num_Cores_Com, 0000 As Num_Cores_Sem,;
		SPACE(50) Str_Cores_Prod_Com, Space(50) Str_Cores_Mat_Com, Space(50) Str_Cores_Prod_Tot, Space(50) Str_Cores_Mat_Tot ;
		From v_produtos_00_custo Into Cursor x_produtos_00_custo Where .F. Readwrite

	*--- Cursor Fatores Preço
	Select *,Space(12) As produto ;
		from v_preco_fatores_01 Into Cursor x_preco_fatores_01 Where .F. Readwrite

	Sele v_produtos_00
	Count To xtReg
	Store 0 To xrAtu
	Go Top
	Scan
		xrAtu = xrAtu + 1
		f_prog_bar('Processando...',xrAtu,xtReg)

		Select v_Produtos_00_Cores
		xRecno_Cor = Recno()

		*--------------------:: >>> Preço Custo
		Sele v_produtos_00_custo
		Tablerevert(.T.)
		=CursorSet('buffering',3)
		=Requery()

		Select v_Produtos_00_Ope_Extra
		=CursorSet('buffering',3)
		=Requery()
		*--

		o_040004.l_filhas_requery()

		Sele v_produtos_tamanho_00
		Locate For grade = v_produtos_00.grade
		If !Found()
			f_Msg(['Error de Talles!'])
			Retu .F.
		Endif

		If xtReg>1 && Mais de um produto pesquisado
			o_040004.l_desenhista_refresh
			xtam = (o_040004.lx_form1.lx_pageframe1.page1.tamanhos.DisplayValue)
			xcor = (o_040004.lx_form1.lx_pageframe1.page1.cmb_cor_produto.DisplayValue)
		Else
			xtam = (o_040004.lx_form1.lx_pageframe1.page1.tamanhos.DisplayValue)
			xcor = (o_040004.lx_form1.lx_pageframe1.page1.cmb_cor_produto.DisplayValue)
			o_040004.l_desenhista_refresh
			o_040004.lx_form1.lx_pageframe1.page1.tamanhos.Value = xtam
			o_040004.lx_form1.lx_pageframe1.page1.cmb_cor_produto.Value = xcor
		Endif
		o_040004.lx_form1.lx_pageframe1.page1.tamanhos.l_desenhista_recalculo

		For k = 1 To 48
			k_ = Allt(Str(k))

			*------------------------------------------
			*- 10/02/2012 - Szalontai
			*- Correção feita para atender a TP 1871804
			*- Foi colocado o operador == no lugar do =
			*------------------------------------------
			**if ALLTRIM(xtam) = ALLTRIM(v_produtos_tamanho_00.tamanho_&k_)

			If Alltrim(xtam) == Alltrim(v_produtos_tamanho_00.tamanho_&k_)
				Exit
			Endif
		Endfor
		xtam_base = Val(k_)

		If !o_040004.PP_BASE_CUSTO_TAMANHO
			xtamanho = v_produtos_tamanho_00.numero_tamanhos * Iif(v_produtos_tamanho_00.numero_quebras>0,v_produtos_tamanho_00.numero_quebras,1)
		Else
			xtamanho = Iif( v_produtos_00.tamanho_base <> 0, xtam_base, 1 )
		ENDIF
		
		xConsumo = 'v_produtos_00_custo.c' + Alltrim(Str(xtamanho))
		xnome_tamanho=Eval('v_produtos_tamanho_00.tamanho_'+Alltrim(Str(xtamanho)))
		

		If xtReg>1 && Mais que um só pela media
			o_040004.px_Cor_Selecionada = '<Todas>'
		Else
			Select v_Produtos_00_Cores
			Go xRecno_Cor
		Endif

		Sele v_produtos_00_custo
		Tablerevert(.T.)
		=CursorSet('buffering',3)

		o_040004.lx_calculo_custo()
		Sele v_produtos_00_custo
		Index On produto + Item + cor_produto + grupo + material + COR_MATERIAL Tag ipGroup For consumo_base>0  &&*#Diego Quaresma#
		If Eof()
			Wait Window 'Produto Sem Materiais:' + produto Nowait
			Loop
		Endif

		Sele v_produtos_00_custo
		Go Top
		*---

		xteste_cor=.F.
		xcor=cor_produto
		xcor_base=cor_produto
		Sum valor To xcusto_total Whil 	xcor=cor_produto
		xrec_fim=Iif(!Eof(),Recno(),0)

		Do Whil .Not. Eof()
			xcor=cor_produto
			Sum valor To xcusto_2 Whil xcor=cor_produto
			If xcusto_2#xcusto_total
				xteste_cor=.T.
			Endif
		Enddo
		If !xteste_cor And xrec_fim <> 0
			Dele For cor_produto # xcor_base
			Repl All DESC_COR_PRODUTO With 'Costos = '+Alltrim(DESC_COR_PRODUTO)
		Endif

		Sele v_produtos_00_custo
		xFilterCor=Iif(Empty(Filter()),'.t.',Filter())

		Go Top
		Scan

			*#Diego Quaresma#
			If consumo_base=0 &&OR &xConsumo=0 *#Diego Quaresma#
				Loop
			Endif

			Scatter Memvar

			*--- Numero de Cores
			Select Distinct cor_produto,material,Iif(consumo_base>0 And porcentagem_consumo>0,.T.,.F.) Com_Consumo ;
				From v_produtos_00_custo ;
				Where material=m.material And produto=m.produto And Item=m.item And Evaluate(xFilterCor) Into Cursor xCur_nCores

			Store 0 To xNCores_Com, xNCores_Sem

			Store '' To xStr_CoresProd_ComC,;
				xStr_CoresProd_SemC,;
				xStr_CoresMat_ComC,;
				xStr_CoresMat_SemC,;
				xStr_CoresProd_Tot,;
				xStr_CoresMat_Tot

			Select xCur_nCores
			Scan
				xStr_CoresProd_Tot = xStr_CoresProd_Tot + Iif(Empty(xStr_CoresProd_Tot),'','/') + Allt(cor_produto)
				xStr_CoresMat_Tot  = xStr_CoresMat_Tot  + Iif(Empty(xStr_CoresMat_Tot),'','/')  + Allt(COR_MATERIAL)
				*
				If Com_Consumo
					xStr_CoresProd_ComC = xStr_CoresProd_ComC + Iif(Empty(xStr_CoresProd_ComC),'','/') + Allt(cor_produto)
					xStr_CoresMat_ComC  = xStr_CoresMat_ComC  + Iif(Empty(xStr_CoresMat_ComC),'','/')  + Allt(COR_MATERIAL)
					xNCores_Com = xNCores_Com + 1
				Else
					xStr_CoresProd_SemC = xStr_CoresProd_SemC + Iif(Empty(xStr_CoresProd_SemC),'','/') + Allt(cor_produto)
					xStr_CoresMat_SemC  = xStr_CoresMat_SemC  + Iif(Empty(xStr_CoresMat_SemC),'','/')  + Allt(COR_MATERIAL)
					xNCores_Sem = xNCores_Sem + 1
				Endif
			Endscan
			xNCores_Tot = (xNCores_Com + xNCores_Sem)

			If o_040004.px_Cor_Selecionada = '<Todas>' && Pela Madia
				xFatorNC = Iif(xNCores_Tot=0,0,xNCores_Com/xNCores_Tot)
			Else
				xFatorNC = 1
			Endif
			*--

			Select x_produtos_00_custo
			Append Blank
			Gather Memvar

			Replace media_consumo_base 	    With Iif(xNCores_Com=0,0,consumo_base/xNCores_Com*xFatorNC),;
				media_custo_a_vista_cor With Iif(xNCores_Com=0,0,custo_a_vista_cor/xNCores_Com),;
				media_valor 	  		With Iif(xNCores_Com=0,0,(valor*xFatorNC)/xNCores_Com),;
				Num_Cores_Com 			With xNCores_Com,;
				Str_Cores_Prod_Com		With xStr_CoresProd_ComC,;
				Str_Cores_Mat_Com		With xStr_CoresMat_ComC,;
				Str_Cores_Prod_Tot		With xStr_CoresProd_Tot,;
				Str_Cores_Mat_Tot 		With xStr_CoresMat_Tot,;
				tamanho_base			With xtam,;
				Ord With 2

			Sele v_produtos_00_custo
		Endscan

		*--- Tratamento Operações Extras
		If xAddOpExtra
			f_select('select sequencia,operacao_extra,custo_operacao from PRODUTOS_OPE_EXTRA where custo_operacao<>0 and produto=?v_produtos_00.produto','tmp_oper_extra',Alias())
			Sele tmp_oper_extra
			Go Top
			Scan
				Sele x_produtos_00_custo
				Appe Blank
				Replace produto           		With v_produtos_00.produto,;
					grupo             		With 'Operações Extras',;
					material          		With Allt(Str(tmp_oper_extra.sequencia)),;
					desc_material     		With tmp_oper_extra.operacao_extra,;
					consumo_base      		With 1.00,;
					media_consumo_base  	With 1.00,;
					custo_a_vista_cor 		With tmp_oper_extra.custo_operacao,;
					valor             		With tmp_oper_extra.custo_operacao,;
					media_valor       		With tmp_oper_extra.custo_operacao,;
					media_custo_a_vista_cor With tmp_oper_extra.custo_operacao,;
					Num_Cores_Com 			With xNCores_Com,;
					Str_Cores_Prod_Com		With xStr_CoresProd_ComC,;
					Str_Cores_Mat_Com		With xStr_CoresMat_ComC,;
					Str_Cores_Prod_Tot		With xStr_CoresProd_Tot,;
					Str_Cores_Mat_Tot 		With xStr_CoresMat_Tot,;
					tamanho_base			With xtam,;
					Ord With 3

				Sele tmp_oper_extra
			Endscan
		Endif
		*--------------------::

		*--- Tratamento Operações - Rotas
		If xAddOpRotas

			f_select('select tabela_operacoes,descricao_tab_operacoes from wprodutos where produto=?v_produtos_00.produto','Cur_wProd',Alias())
			If f_vazio(Cur_wProd.tabela_operacoes)
				xGruOper = F_TRADUZ('ROTA NÃO CADASTRADA')
			Else
				xGruOper = Alltrim(Nvl(Cur_wProd.tabela_operacoes,''))+'-'+Alltrim(Nvl(Cur_wProd.descricao_tab_operacoes,''))
			Endif
			o_040004.lx_form1.lx_pageframe1.page2.Activate()

			If Type('o_040004.pp_formacao_preco_operacao') <> 'U' And Upper(Alltrim(o_040004.pp_formacao_preco_operacao)) == '1'
				Select v_produtos_tab_operacoes_00_operacoes
				Sele x_produtos_00_custo
				Appe Blank
				Replace produto           		With v_produtos_00.produto,;
					grupo             		With xGruOper,;
					material          		With Alltrim(Str(v_produtos_tab_operacoes_00_operacoes.sequencia)),;
					item 					With Right('0000'+Alltrim(Str(Abs(Recno()))),4),;
					desc_material     		With F_TRADUZ('Total de Custos - Operações'),;
					consumo_base      		With 1.00,;
					media_consumo_base  	With 1.00,;
					custo_a_vista_cor 		With o_040004.px_total_MO,;
					valor             		With o_040004.px_total_MO,;
					media_valor       		With o_040004.px_total_MO,;
					media_custo_a_vista_cor With o_040004.px_total_MO,;
					Num_Cores_Com 			With xNCores_Com,;
					Str_Cores_Prod_Com		With xStr_CoresProd_ComC,;
					Str_Cores_Mat_Com		With xStr_CoresMat_ComC,;
					Str_Cores_Prod_Tot		With xStr_CoresProd_Tot,;
					Str_Cores_Mat_Tot 		With xStr_CoresMat_Tot,;
					tamanho_base			With xtam,;
					Ord With 1

			Else
				Select v_produto_operacoes_00_rotas
				Scan
					If v_produto_operacoes_00_rotas.custo_sugerido<>0
						xDescFSR = 'F/S/R:'+Alltrim(fase_producao)+'/'+Alltrim(setor_producao)+'/'+Alltrim(recurso_produtivo) + '-' + ;
							ALLTRIM(desc_fase_producao)+'/'+Alltrim(desc_setor_producao)+'/'+Alltrim(desc_recurso)
						Sele x_produtos_00_custo
						Appe Blank
						Replace produto           		With v_produtos_00.produto,;
							grupo             		With xGruOper,;
							material          		With Alltrim(v_produto_operacoes_00_rotas.sequencia_produtiva),;
							item 					With Right('0000'+Alltrim(Str(Abs(Recno()))),4),;
							desc_material     		With xDescFSR,;
							consumo_base      		With 1.00,;
							media_consumo_base  	With 1.00,;
							custo_a_vista_cor 		With v_produto_operacoes_00_rotas.custo_sugerido,;
							valor             		With v_produto_operacoes_00_rotas.custo_sugerido,;
							media_valor       		With v_produto_operacoes_00_rotas.custo_sugerido,;
							media_custo_a_vista_cor With v_produto_operacoes_00_rotas.custo_sugerido,;
							Num_Cores_Com 			With xNCores_Com,;
							Str_Cores_Prod_Com		With xStr_CoresProd_ComC,;
							Str_Cores_Mat_Com		With xStr_CoresMat_ComC,;
							Str_Cores_Prod_Tot		With xStr_CoresProd_Tot,;
							Str_Cores_Mat_Tot 		With xStr_CoresMat_Tot,;
							Ord With 1
					Endif
				Endscan
			Endif
			*---

			Sele x_produtos_00_custo
			Locate For produto=v_produtos_00.produto And Ord=1
			If Eof()
				Append Blank
				Replace produto With v_produtos_00.produto, grupo With xGruOper, Ord With 1,tamanho_base With xtam,;
					Num_Cores_Com 			With xNCores_Com,;
					Str_Cores_Prod_Com		With xStr_CoresProd_ComC,;
					Str_Cores_Mat_Com		With xStr_CoresMat_ComC,;
					Str_Cores_Prod_Tot		With xStr_CoresProd_Tot,;
					Str_Cores_Mat_Tot 		With xStr_CoresMat_Tot
			Endif

			Go Top
		Endif
		*--------------------::


		*--------------------:: >>> Fatores
		If xProcessaPreco
			Sele v_preco_fatores_01
			Locate For sequencia='95' && (Atualização: Linx-4='99' e  Linx-5='95')

			xFiltZer_ok = (valor_calculo=0 Or Eof())
			Go Top

			If !(xFiltZer And xFiltZer_ok)
				Scan
					Scatter Memvar
					Sele x_preco_fatores_01
					Appe Blank
					Gather Memvar
					Repl produto With v_produtos_00.produto
					Sele v_preco_fatores_01
				Endscan
			Endif
		Endif
		*--------------------::

		Sele v_produtos_00
	Endscan

	f_wait()
Endfunc
*---------------------------------------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------------------------------------*
*------- M a r k - U p s
Function  Processa_MarkUps
	Parameters xVerDetMk

	**------tmp - preparacao
	Select produto,sequencia,Space(50) Item,fator,;
		valor_calculo As val1,valor_calculo As val2,valor_calculo As val3,valor_calculo As val4,valor_calculo As val5,;
		valor_calculo As val6,valor_calculo As val7,valor_calculo As val8,valor_calculo As val9,valor_calculo As val10,;
		valor_calculo As val11,valor_calculo As val12,valor_calculo As val13,valor_calculo As val14,valor_calculo As val15,;
		valor_calculo As val16,valor_calculo As val17,valor_calculo As val18 ;
		FROM x_preco_fatores_01 Where .F. Into Cursor Tmp_Precos Readwrite

	*--- cabeçalho do markap
	Create Cursor tmp_mk_cab (mk1 c(20),mk2 c(20),mk3 c(20),mk4 c(20),mk5 c(20),mk6 c(20),mk7 c(20),mk8 c(20),mk9 c(20),mk10 c(20),mk11 c(20),mk12 c(20),mk13 c(20),mk14 c(20),mk15 c(20),mk16 c(20),mk17 c(20),mk18 c(20) )
	Sele tmp_mk_cab
	Appe Blank

	Sele Tmp_Precos
	Index On produto+sequencia+Item+Transf(fator,'9999.9999') Tag iTmp

	Sele x_preco_fatores_01
	xselecao = ''
	For k = 1 To 18
		If Type('oprel(k)')='C'
			xselecao = xselecao + ';' + Allt(oprel(k))
			Replace All grupo_subtotal With Right('000'+Allt(Str(k)),3) For Allt(preco_tipo)=Allt(oprel(k)) && ordem da selecao
		Endif
	Endfor

	Inde On produto + grupo_subtotal + preco_tipo + sequencia Tag test
	Set Filter To Allt(preco_tipo) $ xselecao And !('INDUSTRIAL' $ Upper(desc_fator_custos))

	Go Top
	Do Whil !Eof()
		xCol  = 0
		xprod = produto
		Do Whil produto=xprod

			xtipo = preco_tipo
			xCol  = xCol+1
			If xCol>18
				Scan Whil produto=xprod
				Endscan
				Exit
			Endif

			k_    = Allt(Str(xCol))
			Sele tmp_mk_cab
			Replace mk&k_ With Allt(xtipo)

			Sele x_preco_fatores_01
			Scan Whil produto=xprod And preco_tipo=xtipo
				Sele Tmp_Precos
				xDescItem = Allt(x_preco_fatores_01.sequencia)+'-'+;
					allt(x_preco_fatores_01.desc_fator_custos)+;
					IIF(Empty(x_preco_fatores_01.tipo_fator),'','('+Alltrim(x_preco_fatores_01.tipo_fator)+')')
				xFator    = x_preco_fatores_01.fator
				xSeq	  = x_preco_fatores_01.sequencia

				Seek xprod + xSeq + xDescItem
				If Eof()
					Appe Blank
					Replace produto With xprod, sequencia With xSeq, Item With xDescItem, fator With xFator
				Endif

				Replace Val&k_ With Iif(Between(Val(Left(Item,2)),95,98),x_preco_fatores_01.valor_calculo,x_preco_fatores_01.fator)
				Sele x_preco_fatores_01
			Endscan

		Enddo
	Enddo


	*------- Resumir para uso no lay-out
	*--- cursor para totais
	Create Cursor tmp_rodape (produto c(12),detalhe m(4),;
		soma1 N(10,4),soma2 N(10,4),soma3 N(10,4),soma4 N(10,4),soma5 N(10,4),soma6 N(10,4),soma7 N(10,4),soma8 N(10,4),soma9 N(10,4),;
		soma10 N(10,4),soma11 N(10,4),soma12 N(10,4),soma13 N(10,4),soma14 N(10,4),soma15 N(10,4),soma16 N(10,4),soma17 N(10,4),soma18 N(10,4),;
		fin1 N(10,4),fin2 N(10,4),fin3 N(10,4),fin4 N(10,4),fin5 N(10,4),fin6 N(10,4),fin7 N(10,4),fin8 N(10,4),fin9 N(10,4),;
		fin10 N(10,4),fin11 N(10,4),fin12 N(10,4),fin13 N(10,4),fin14 N(10,4),fin15 N(10,4),fin16 N(10,4),fin17 N(10,4),fin18 N(10,4),;
		fat1 N(10,4),fat2 N(10,4),fat3 N(10,4),fat4 N(10,4),fat5 N(10,4),fat6 N(10,4),fat7 N(10,4),fat8 N(10,4),fat9 N(10,4),;
		fat10 N(10,4),fat11 N(10,4),fat12 N(10,4),fat13 N(10,4),fat14 N(10,4),fat15 N(10,4),fat16 N(10,4),fat17 N(10,4),fat18 N(10,4))

	Sele Tmp_Precos
	Index On produto Tag iProd

	Do Whil ! Eof()
		xprod = produto

		Select Max(Left(Item,2)) As max_IT From Tmp_Precos Where produto=xprod Into Cursor tmp_precos_ult_it
		xMaxIT = tmp_precos_ult_it.max_IT

		Stor '' To xLine,xValores
		Stor 0 To xsoma_tot1,xsoma_tot2,xsoma_tot3,xsoma_tot4,xsoma_tot5,xsoma_tot6,xsoma_tot7,xsoma_tot8,xsoma_tot9,xsoma_tot10,xsoma_tot11,xsoma_tot12,xsoma_tot13,xsoma_tot14,xsoma_tot15,xsoma_tot16,xsoma_tot17,xsoma_tot18
		Stor 0 To xsoma_fat1,xsoma_fat2,xsoma_fat3,xsoma_fat4,xsoma_fat5,xsoma_fat6,xsoma_fat7,xsoma_fat8,xsoma_fat9,xsoma_fat10,xsoma_fat11,xsoma_fat12,xsoma_fat13,xsoma_fat14,xsoma_fat15,xsoma_fat16,xsoma_fat17,xsoma_fat18

		Sele Tmp_Precos
		Scan Whil produto=xprod

			If (val1+val2+val3+val4+val5+val6+val7+val8+val9+val10+val11+val12+val13+val14+val15+val16+val17+val18) <> 0
				Do Case
					Case xMaxIT $ Item
						xsoma_tot1 = xsoma_tot1 + val1
						xsoma_tot2 = xsoma_tot2 + val2
						xsoma_tot3 = xsoma_tot3 + val3
						xsoma_tot4 = xsoma_tot4 + val4
						xsoma_tot5 = xsoma_tot5 + val5
						xsoma_tot6 = xsoma_tot6 + val6
						xsoma_tot7 = xsoma_tot7 + val7
						xsoma_tot8 = xsoma_tot8 + val8
						xsoma_tot9 = xsoma_tot9 + val9
						xsoma_tot10= xsoma_tot10+ val10
						xsoma_tot11= xsoma_tot11+ val11
						xsoma_tot12= xsoma_tot12+ val12
						xsoma_tot13= xsoma_tot13+ val13
						xsoma_tot14= xsoma_tot14+ val14
						xsoma_tot15= xsoma_tot15+ val15
						xsoma_tot16= xsoma_tot16+ val16
						xsoma_tot17= xsoma_tot17+ val17
						xsoma_tot18= xsoma_tot18+ val18
					Other
						If xVerDetMk
							xvl = ''
							xvl = xvl + Iif(Empty(val1),Space(9),Transf(val1,'99999.999'))
							xvl = xvl + Iif(Empty(val2),Space(9),Transf(val2,'99999.999'))
							xvl = xvl + Iif(Empty(val3),Space(9),Transf(val3,'99999.999'))
							xvl = xvl + Iif(Empty(val4),Space(9),Transf(val4,'99999.999'))
							xvl = xvl + Iif(Empty(val5),Space(9),Transf(val5,'99999.999'))
							xvl = xvl + Iif(Empty(val6),Space(9),Transf(val6,'99999.999'))
							xvl = xvl + Iif(Empty(val7),Space(9),Transf(val7,'99999.999'))
							xvl = xvl + Iif(Empty(val8),Space(9),Transf(val8,'99999.999'))
							xvl = xvl + Iif(Empty(val9),Space(9),Transf(val9,'99999.999'))
							xvl = xvl + Iif(Empty(val10),Space(9),Transf(val10,'99999.999'))
							xvl = xvl + Iif(Empty(val11),Space(9),Transf(val11,'99999.999'))
							xvl = xvl + Iif(Empty(val12),Space(9),Transf(val12,'99999.999'))
							xvl = xvl + Iif(Empty(val13),Space(9),Transf(val13,'99999.999'))
							xvl = xvl + Iif(Empty(val14),Space(9),Transf(val14,'99999.999'))
							xvl = xvl + Iif(Empty(val15),Space(9),Transf(val15,'99999.999'))
							xvl = xvl + Iif(Empty(val16),Space(9),Transf(val16,'99999.999'))
							xvl = xvl + Iif(Empty(val17),Space(9),Transf(val17,'99999.999'))
							xvl = xvl + Iif(Empty(val18),Space(9),Transf(val18,'99999.999'))
							xLine = xLine  + Left(Item,16) + ' ' + xvl + Chr(13)
						Endif

						*--- soma fatores (sem financeiro)
						xsoma_fat1 = xsoma_fat1 + val1
						xsoma_fat2 = xsoma_fat2 + val2
						xsoma_fat3 = xsoma_fat3 + val3
						xsoma_fat4 = xsoma_fat4 + val4
						xsoma_fat5 = xsoma_fat5 + val5
						xsoma_fat6 = xsoma_fat6 + val6
						xsoma_fat7 = xsoma_fat7 + val7
						xsoma_fat8 = xsoma_fat8 + val8
						xsoma_fat9 = xsoma_fat9 + val9
						xsoma_fat10= xsoma_fat10+ val10
						xsoma_fat11= xsoma_fat11+ val11
						xsoma_fat12= xsoma_fat12+ val12
						xsoma_fat13= xsoma_fat13+ val13
						xsoma_fat14= xsoma_fat14+ val14
						xsoma_fat15= xsoma_fat15+ val15
						xsoma_fat16= xsoma_fat16+ val16
						xsoma_fat17= xsoma_fat17+ val17
						xsoma_fat18= xsoma_fat18+ val18
				Endcase
			Endif
		Endscan

		*--- Gravar resultados
		Sele tmp_rodape
		Appe Blank
		Replace produto With xprod, detalhe With xLine,;
			soma1  With xsoma_tot1 ,soma2  With xsoma_tot2 ,soma3  With xsoma_tot3,	soma4  With xsoma_tot4 ,soma5  With xsoma_tot5,	soma6  With xsoma_tot6 ,soma7  With xsoma_tot7 , soma8 With xsoma_tot8, soma9  With xsoma_tot9,;
			soma10 With xsoma_tot10,soma11 With xsoma_tot11,soma12 With xsoma_tot12,soma13 With xsoma_tot13,soma14 With xsoma_tot14,soma15 With xsoma_tot15,soma16 With xsoma_tot16,soma17 With xsoma_tot17,soma18 With xsoma_tot18

		Replace fat1  With xsoma_fat1,fat2   With xsoma_fat2, fat3  With xsoma_fat3, fat4  With xsoma_fat4, fat5  With xsoma_fat5, fat6  With xsoma_fat6, fat7  With xsoma_fat7 ,fat8  With xsoma_fat8, fat9 With xsoma_fat9,;
			fat10 With xsoma_fat10,fat11 With xsoma_fat11,fat12 With xsoma_fat12,fat13 With xsoma_fat13,fat14 With xsoma_fat14,fat15 With xsoma_fat15,fat16 With xsoma_fat16,fat17 With xsoma_fat17,fat18 With xsoma_fat18

		Sele Tmp_Precos
	Enddo

	Sele tmp_rodape
	Go Top
Endfunc
*---------------------------------------------------------------------------------------------------------------------------------------------------*
