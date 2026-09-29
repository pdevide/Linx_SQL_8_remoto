**-------------------------------------------------------------------------------------------------------------------------**
procedure qtde
	lparam xx

	if xx
		xalias = sele( )
		sele v_romaneios_produtos_00_reservas
		set relation to
		sele v_romaneios_produtos_00_tot_estoque
		set order to
	endif	

	*--Repopula Estoque
	=Requery('v_romaneios_produtos_00_tot_estoque')

	*--Repopula Producao
	=Requery('v_romaneios_produtos_00_tot_producao')

	*--Vai Para a View de Estoque
	Sele v_romaneios_produtos_00_tot_estoque
	if xx
		index on produto+cor_produto tag ind1
	endif

	Scan
	**-romaneado-**

		*--Vai Para a View Filha Para Pegar Totais de Reservas
		Sele v_romaneios_produtos_00_reservas
		Sum r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, r16, r17, r18, r19, r20, r21, r22, r23, r24 to ;
	    	xr1,xr2,xr3,xr4,xr5,xr6,xr7,xr8,xr9,xr10,xr11,xr12,xr13,xr14,xr15,xr16,xr17,xr18,xr19,xr20,xr21,xr22,xr23,xr24 ;
		    For cor_produto = v_romaneios_produtos_00_tot_estoque.cor_produto
		Sum r25, r26, r27, r28, r29, r30, r31, r32, r33, r34, r35, r36, r37, r38, r39, r40, r41, r42, r43, r44, r45, r46, r47, r48 to ;
	    	xr25,xr26,xr27,xr28,xr29,xr30,xr31,xr32,xr33,xr34,xr35,xr36,xr37,xr38,xr39,xr40,xr41,xr42,xr43,xr44,xr45,xr46,xr47,xr48 ;
		    For cor_produto = v_romaneios_produtos_00_tot_estoque.cor_produto

		*--Vai para a View de Totais e Estoque Para Armazenar Totais
		Sele v_romaneios_produtos_00_tot_estoque
		For x = 1 To wMaximo_Tamanhos
			xCampo = 'TR'+AllT(Str(x))
			xVar   = 'xr'+AllT(Str(x))
			Repla &xCampo With &xVar, Total_r With Total_r + &xVar
		Next

	**-producao-**  
		if o_150003.lx_form1.Lx_pageframe1.Page4.ck_ordem_producao.value=1
			if !empty(v_romaneios_produtos_00.ordem_producao)
				**-com ordem de produção-**
				*--Vai Para a View DE pRODUCAO Para Pegar Totais
				Sele v_romaneios_produtos_00_tot_producao
				Sum  o1, o2, o3, o4, o5, o6, o7, o8, o9, o10, o11, o12, o13, o14, o15, o16, o17, o18, o19, o20, o21, o22, o23, o24 to ;
				    xp1,xp2,xp3,xp4,xp5,xp6,xp7,xp8,xp9,xp10,xp11,xp12,xp13,xp14,xp15,xp16,xp17,xp18,xp19,xp20,xp21,xp22,xp23,xp24 ;
			    	For cor_produto = v_romaneios_produtos_00_tot_estoque.cor_produto
				Sum  o25, o26, o27, o28, o29, o30, o31, o32, o33, o34, o35, o36, o37, o38, o39, o40, o41, o42, o43, o44, o45, o46, o47, o48 to ;
				    xp25,xp26,xp27,xp28,xp29,xp30,xp31,xp32,xp33,xp34,xp35,xp36,xp37,xp38,xp39,xp40,xp41,xp42,xp43,xp44,xp45,xp46,xp47,xp48 ;
				    For cor_produto = v_romaneios_produtos_00_tot_estoque.cor_produto
			else	
				**-sem ordem de produção-**
				if  sqlexec(wconeccao, "select sum(p1) p1, sum(p2) p2, sum(p3) p3, sum(p4) p4, sum(p5) p5, sum(p6) p6, sum(p7) p7,		"+;
						"sum(p8) p8, sum(p9) p9, sum(p10) p10, sum(p11) p11, sum(p12) p12, sum(p13) p13, sum(p14) p14, sum(p15) p15,	"+;
						"sum(p16) p16, sum(p17) p17, sum(p18) p18, sum(p19) p19, sum(p20) p20, sum(p21) p21, sum(p22) p22, sum(p23) p23,"+;
						"sum(p24) p24, sum(p25) p25, sum(p26) p26, sum(p27) p27, sum(p28) p28, sum(p29) p29, sum(p30) p30, sum(p31) p31,"+;
						"sum(p32) p32, sum(p33) p33, sum(p34) p34, sum(p35) p35, sum(p36) p36, sum(p37) p37, sum(p38) p38, sum(p39) p39,"+;
						"sum(p40) p40, sum(p41) p41, sum(p42) p42, sum(p43) p43, sum(p44) p44, sum(p45) p45, sum(p46) p46, sum(p47) p47,"+;
						"sum(p48) p48, sum(qtde_p)  qtde_p, produto, cor_produto from producao_ordem_cor where produto = 				"+;
						"?v_romaneios_produtos_00_tot_estoque.produto and cor_produto = ?v_romaneios_produtos_00_tot_estoque.cor_produto"+;
						" group by produto, cor_produto", 'cur_prod') < 0
					f_msg(['Problema ao Procurar Produção !!', 0+16, 'ERRO !!'])
					retu .f.
				endif
			endif
		endif

	**-embalado-**
		if o_150003.lx_form1.Lx_pageframe1.Page4.ck_estoque.value = 1 
			if sqlexec(wconeccao, "select produto, cor_produto, filial, sum(e1) e1, sum(e2) e2, sum(e3) e3, sum(e4) e4, sum(e5) e5, sum(e6) e6, "+;
					"sum(e7) e7, sum(e8) e8, sum(e9) e9, sum(e10) e10, sum(e11) e11, sum(e12) e12, sum(e13) e13, sum(e14) e14, sum(e15) e15, "+;
					"sum(e16) e16, sum(e17) e17, sum(e18) e18, sum(e19) e19, sum(e20) e20, sum(e21) e21, sum(e22) e22, sum(e23) e23, sum(e24) e24, "+;
					"sum(e25) e25, sum(e26) e26, sum(e27) e27, sum(e28) e28, sum(e29) e29, sum(e30) e30, sum(e31) e31, sum(e32) e32, sum(e33) e33, "+;
					"sum(e34) e34, sum(e35) e35, sum(e36) e36, sum(e37) e37, sum(e38) e38, sum(e39) e39, sum(e40) e40, sum(e41) e41, sum(e42) e42, "+;
					"sum(e43) e43, sum(e44) e44, sum(e45) e45, sum(e46) e46, sum(e47) e47, sum(e48) e48 from vendas_prod_embalado "+;
					"where produto = ?v_romaneios_produtos_00_tot_estoque.produto and cor_produto = ?v_romaneios_produtos_00_tot_estoque.cor_produto "+;
					"and filial = ?o_150003.px_filial group by produto, cor_produto, filial ", "cur_emb") < 0
				f_msg(['Problema ao Procurar Embalado !!!', 0+16, 'Erro !!!'])
				return .f.
			endif

	**-estoque-**
			if sqlexec(wconeccao, "select produto, filial, cor_produto, es1, es2, es3, es4, es5, es6, es7, es8, es9, es10, es11,es12, "+;
					"es13, es14, es15, es16, es17, es18, es19, es20, es21, es22, es23, es24, es25, es26, es27, es28, es29, es30,    "+;
					"es31, es32, es33, es34, es35, es36, es37, es38, es39, es40, es41, es42, es43, es44, es45, es46, es47, es48,	"+;
					"estoque from estoque_produtos where produto = ?v_romaneios_produtos_00_tot_estoque.produto and cor_produto = 	"+;
					"?v_romaneios_produtos_00_tot_estoque.cor_produto and filial = ?o_150003.px_filial ", 'cur_est') < 0
				f_msg(['Problema ao Procurar Estoque !!!', 0+16, 'Erro !!!'])
				retu .f.
			endif
		endif

		*--Vai Vara a View de Totais e Estoque Para Armazenar Totais
		Sele v_romaneios_produtos_00_tot_estoque
		For x = 1 To wMaximo_Tamanhos

				if o_150003.lx_form1.Lx_pageframe1.Page4.ck_ordem_producao.value=1 and !empty(v_romaneios_produtos_00.ordem_producao)
					**-com ordem
					xpro  = 'xp'+AllT(Str(x))			&&producao
				else
					**-sem ordem
					xpro  = 'cur_prod.p'+AllT(Str(x))	&&producao
				endif

				xemb  = 'cur_emb.e'+allt(str(x))	&&embalado	
				xest  = 'cur_est.es'+allt(str(x))	&&estoque total
				xest1 = 'te'+AllT(Str(x))			&&estoque disponivel
				xrom  = 'tr'+AllT(Str(x))			&&romaneado
				xSal  = 'T'+AllT(Str(x))			&&saldo
			
				do case
					case o_150003.lx_form1.Lx_pageframe1.Page4.ck_estoque.value=0 and o_150003.lx_form1.Lx_pageframe1.Page4.ck_ordem_producao.value=0
						replace &xest1 with 0 , total_e with  0,;
								&xsal with (0 - &xrom), total_t with total_t + (0 - &xrom)
					case o_150003.lx_form1.Lx_pageframe1.Page4.ck_estoque.value=1 and o_150003.lx_form1.Lx_pageframe1.Page4.ck_ordem_producao.value=1
						replace &xest1 with (&xest - &xemb + &xpro), total_e with total_e + (&xest - &xemb + &xpro),;
								&xsal with (&xest - &xemb + &xpro) - &xrom , total_t with total_t + ((&xest - &xemb + &xpro) - &xrom)
					case o_150003.lx_form1.Lx_pageframe1.Page4.ck_estoque.value=1
						replace &xest1 with (&xest - &xemb), total_e with total_e + (&xest - &xemb);
								&xsal with (&xest - &xemb) - &xrom , total_t with total_t + ((&xest - &xemb) - &xrom)
					case o_150003.lx_form1.Lx_pageframe1.Page4.ck_ordem_producao.value=1
						replace &xest1 with &xpro , total_e with total_e + &xpro ,;
								&xsal with (&xpro - &xrom), total_t with total_t + (&xpro - &xrom)

				endcase
			
		Next

	EndScan

	
	go top

	if xx
		sele v_romaneios_produtos_00_reservas
		set relation to produto+cor_produto into v_romaneios_produtos_00_tot_estoque
		go top
		sele (xalias)
	endif
	
retu


**-------------------------------------------------------------------------------------------------------------------------**
procedure f_volta  && Volta a Tab. Pai
	sele V_romaneios_produtos_00
Return

procedure x_select
	lparam xtot
	if ! xtot
		retu
	endif
	xalias = sele( )

	select sum(tr1) tr1, sum(tr2) tr2, sum(tr3) tr3, sum(tr4) tr4, sum(tr5) tr5, sum(tr6) tr6, sum(tr7) tr7, sum(tr8) tr8,;
	    sum(tr9) tr9, sum(tr10) tr10, sum(tr11) tr11, sum(tr12) tr12, sum(tr13) tr13, sum(tr14) tr14, sum(tr15) tr15,;
	    sum(tr16) tr16, sum(tr17) tr17, sum(tr18) tr18, sum(tr19) tr19, sum(tr20) tr20,	sum(tr21) tr21, sum(tr22) tr22,;
	    sum(tr23) tr23, sum(tr24) tr24, sum(tr25) tr25, sum(tr26) tr26, sum(tr27) tr27,	sum(tr28) tr28, sum(tr29) tr29,; 
	    sum(tr30) tr30, sum(tr31) tr31, sum(tr32) tr32, sum(tr33) tr33, sum(tr34) tr34, sum(tr35) tr35, sum(tr36) tr36,; 
	    sum(tr37) tr37, sum(tr38) tr38, sum(tr39) tr39, sum(tr40) tr40,	sum(tr41) tr41, sum(tr42) tr42, sum(tr43) tr43,;
	    sum(tr44) tr44, sum(tr45) tr45, sum(tr46) tr46, sum(tr47) tr47, sum(tr48) tr48, sum(total_r) total_r ;
	    from v_romaneios_produtos_00_tot_estoque into cursor xcursor1

	select sum(te1) te1, sum(te2) te2, sum(te3) te3, sum(te4) te4, sum(te5) te5, sum(te6) te6, sum(te7) te7, sum(te8) te8,;
	    sum(te9) te9, sum(te10) te10, sum(te11) te11, sum(te12) te12, sum(te13) te13, sum(te14) te14, sum(te15) te15,;
	    sum(te16) te16, sum(te17) te17, sum(te18) te18, sum(te19) te19, sum(te20) te20, sum(te21) te21, sum(te22) te22,;
	    sum(te23) te23, sum(te24) te24, sum(te25) te25, sum(te26) te26, sum(te27) te27, sum(te28) te28, sum(te29) te29,;
	    sum(te30) te30, sum(te31) te31, sum(te32) te32, sum(te33) te33, sum(te34) te34, sum(te35) te35, sum(te36) te36,;
	    sum(te37) te37, sum(te38) te38, sum(te39) te39, sum(te40) te40, sum(te41) te41, sum(te42) te42, sum(te43) te43,;
	    sum(te44) te44, sum(te45) te45, sum(te46) te46, sum(te47) te47, sum(te48) te48, sum(total_e) total_e ;
	    from v_romaneios_produtos_00_tot_estoque into cursor xcursor2

	select sum(t1) t1, sum(t2) t2, sum(t3) t3, sum(t4) t4, sum(t5) t5, sum(t6) t6, sum(t7) t7, sum(t8) t8, sum(t9) t9,;
	    sum(t10) t10, sum(t11) t11, sum(t12) t12, sum(t13) t13, sum(t14) t14, sum(t15) t15, sum(t16) t16, sum(t17) t17,;
	    sum(t18) t18, sum(t19) t19, sum(t20) t20, sum(t21) t21, sum(t22) t22, sum(t23) t23, sum(t24) t24, sum(t25) t25,;
	    sum(t26) t26, sum(t27) t27, sum(t28) t28, sum(t29) t29, sum(t30) t30, sum(t31) t31, sum(t32) t32, sum(t33) t33,;
	    sum(t34) t34, sum(t35) t35, sum(t36) t36, sum(t37) t37, sum(t38) t38, sum(t39) t39, sum(t40) t40, sum(t41) t41,;
	    sum(t42) t42, sum(t43) t43, sum(t44) t44, sum(t45) t45, sum(t46) t46, sum(t47) t47, sum(t48) t48, sum(total_t) total_t;
	    from v_romaneios_produtos_00_tot_estoque into cursor xcursor3

		for x = 1 to 48
			xtr = 'xcursor1.tr'+alltrim(str(x))
			xte = 'xcursor2.te'+alltrim(str(x))
			xt  = 'xcursor3.t'+alltrim(str(x))
			o_150003.px_array1[1,x]  = o_150003.px_array1[1,x]+&xtr
			o_150003.px_array1[2,x]  = o_150003.px_array1[2,x]+&xte
			o_150003.px_array1[3,x]  = o_150003.px_array1[3,x]+&xt
			o_150003.px_array1[1,49] = o_150003.px_array1[1,49]+&xtr
			o_150003.px_array1[2,49] = o_150003.px_array1[2,49]+&xte
			o_150003.px_array1[3,49] = o_150003.px_array1[3,49]+&xt

		next			
	sele (xalias)
retu

**-------------------------------------------------------------------------------------------------------------------------**
procedure zera
	store 0 to o_150003.px_array1
retu


**-------------------------------------------------------------------------------------------------------------------------**
procedure falso
	lparam xx
	if xx
		xtot = .t.
	else
		xtot = .f.
	endif
return


**-------------------------------------------------------------------------------------------------------------------------**
Procedure Requery_Reservas_9
Para xid_modo

Requery('v_romaneios_produtos_00_reservas')

if x_visualiza = 6

	xalias = alias()
	sele v_romaneios_produtos_00_reservas
	=cursorset('buffering',3)
	x_ordem = o_150003.lx_form1.lx_pageframe1.page5.lx_optiongroup1.value

	do case
		case x_ordem  = 1
			set order to tag1
		case x_ordem  = 2
			set order to tag2
		case x_ordem  = 3
			set order to tag3
		case x_ordem  = 4
			set order to tag4
		case x_ordem  = 5
			set order to tag5
		case x_ordem  = 6
			set order to tag6
		case x_ordem  = 7
			set order to tag7
		case x_ordem  = 8
			set order to tag8		
	endcase
	
	if x_ordem <> 3 and x_ordem <> 4
		go top
		o_150003.lx_prepara_dados()
		o_150003.lx_obter_indice()
		o_150003.lx_ordem()
	endif
	
	sele v_romaneios_produtos_00_reservas
	=cursorset('buffering',3)
	if xid_modo = 0
		xord_tag = 'romaneio+produto+' + sys(14,x_ordem)
		index on &xord_tag to Romane
	else
		set order to Romane
		go top
	endif
	
	sele &xalias
endif
**-------------------------------------------------------------------------------------------------------------------------**
