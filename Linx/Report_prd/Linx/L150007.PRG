*/ Objetivo:  Recalculo Filhas - Relatorios do Romaneio (Valmir)

**: Primeiro Calculo / Rels. Sinteticos
**: Obs.: este calculo foi copiado do metodo da form e adaptado p/ o relatorio
procedure f_repopula_a  && Requery/Calculo com armazenamento
	
Local xQtde_R, xQtde_Te, xQtde_E
xalias = sele( )

Store 0 to xQtde_R, xQtde_Te, xQtde_E
*--Repopula Romaneio
Wait Window f_traduz('Repopulando Romaneios !!!') NoWait
=Requery('V_Romaneios_Reservas_00')
Sele v_romaneios_reservas_00

Scan
	**-producao-**  
	if o_150007.lx_form1.check_producao.value = 1 
		if  sqlexec(wconeccao, "select sum(p1) p1, sum(p2) p2, sum(p3) p3, sum(p4) p4, sum(p5) p5, sum(p6) p6, sum(p7) p7,		"+;
				"sum(p8) p8, sum(p9) p9, sum(p10) p10, sum(p11) p11, sum(p12) p12, sum(p13) p13, sum(p14) p14, sum(p15) p15,	"+;
				"sum(p16) p16, sum(p17) p17, sum(p18) p18, sum(p19) p19, sum(p20) p20, sum(p21) p21, sum(p22) p22, sum(p23) p23,"+;
				"sum(p24) p24, sum(p25) p25, sum(p26) p26, sum(p27) p27, sum(p28) p28, sum(p29) p29, sum(p30) p30, sum(p31) p31,"+;
				"sum(p32) p32, sum(p33) p33, sum(p34) p34, sum(p35) p35, sum(p36) p36, sum(p37) p37, sum(p38) p38, sum(p39) p39,"+;
				"sum(p40) p40, sum(p41) p41, sum(p42) p42, sum(p43) p43, sum(p44) p44, sum(p45) p45, sum(p46) p46, sum(p47) p47,"+;
				"sum(p48) p48, sum(qtde_p)  qtde_p, produto, cor_produto from producao_ordem_cor where produto = 				"+;
				"?v_romaneios_reservas_00.produto and cor_produto = ?v_romaneios_reservas_00.cor_produto"+;
				" group by produto, cor_produto", 'cur_prod') < 0
			f_msg(['Problema ao Procurar Produção !!', 0+16, 'ERRO !!'])
			retu .f.
		endif
	endif

	if o_150007.lx_form1.check_estoque.value = 1 
		**-embalado-**
		if sqlexec(wconeccao, "select produto, filial, cor_produto, e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11,e12, "+;
				"e13, e14, e15, e16, e17, e18, e19, e20, e21, e22, e23, e24, e25, e26, e27, e28, e29, e30,    "+;
				"e31, e32, e33, e34, e35, e36, e37, e38, e39, e40, e41, e42, e43, e44, e45, e46, e47, e48,	"+;
				"qtde_embalada from vendas_prod_embalado where produto = ?v_romaneios_reservas_00.produto and cor_produto = 	"+;
				"?v_romaneios_reservas_00.cor_produto and filial = ?o_150007.px_filial ", 'cur_emb') < 0
			f_msg(['Problema ao Procurar Embalado !!!', 0+16, 'Erro !!!'])
			retu .f.
		endif

		**-estoque-**
		if sqlexec(wconeccao, "select produto, filial, cor_produto, es1, es2, es3, es4, es5, es6, es7, es8, es9, es10, es11,es12, "+;
				"es13, es14, es15, es16, es17, es18, es19, es20, es21, es22, es23, es24, es25, es26, es27, es28, es29, es30,    "+;
				"es31, es32, es33, es34, es35, es36, es37, es38, es39, es40, es41, es42, es43, es44, es45, es46, es47, es48,	"+;
				"estoque from estoque_produtos where produto = ?v_romaneios_reservas_00.produto and cor_produto = 	"+;
				"?v_romaneios_reservas_00.cor_produto and filial = ?o_150007.px_filial ", 'cur_est') < 0
			f_msg(['Problema ao Procurar Estoque !!!', 0+16, 'Erro !!!'])
			retu .f.
		endif
	endif

	*--Vai Vara a View de Totais e Estoque Para Armazenar Totais
	Sele v_romaneios_reservas_00
	Store 0 to xQtde_R, xQtde_Te, xQtde_E

	For x = 1 To wMaximo_Tamanhos
		xEst   = 'Cur_Est.Es'+allt(str(x))	     &&estoque total
		xEmb  = 'Cur_Emb.E'+AllT(Str(x))		 &&embalado
		xPro   = 'Cur_Prod.P'+AllT(Str(x))	     &&Produto
		xTe     = 'Te'+allt(str(x))   			 &&Campo do Estoque
		xE       = 'E'+AllT(str(x))	             &&Campo de Embalado	
		xR       = 'R'+AllT(str(x))	             &&Campo de Romaneado	
		do case
			case o_150007.lx_form1.check_estoque.value = 0 and o_150007.lx_form1.check_producao.value =0
				replace &xTe with 0 , &xE with (0 - &xR)
			case o_150007.lx_form1.check_estoque.value = 1 and o_150007.lx_form1.check_producao.value =1
				replace &xTe with (&xest - &xemb + &xpro), &xE with  (&xest - &xemb + &xpro) - &xR
			case o_150007.Lx_form1.check_estoque.value = 1
				replace &xTe with (&xest - &xemb), &xE with  (&xest - &xemb ) - &xR
			case o_150007.lx_form1.check_producao.value = 1
				replace &xTe with (&xpro), &xE with  (&xpro) - &xR
		endcase
			
		xQtde_Te = xQtde_Te+&xTe
		xQtde_E   = xQtde_E  +&xE
	EndFor
	Replace qtde_te with xQtde_te,qtde_e with xqtde_e

EndScan
Go Top
*---------------------------------------------------------------------------------------------------------------------------*
