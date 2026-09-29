*/ Objetivo:  Recalculo Filhas - Relatorios do Romaneio (Valmir)

**: Primeiro Calculo / Rels. Sinteticos
**: Obs.: este calculo foi copiado do metodo da form e adaptado p/ o relatorio
procedure f_repopula_a  && Rquery/Calculo com armazenamento
	
	local x,xCampo,xVar,xVar_es,xVar_p,xEmb,xVar_e,xVar_r,xSal
	sele V_romaneios_produtos_00

	*--Repopula Tabelas
	=Requery('v_romaneios_produtos_00_Reservas')
	=Requery('v_romaneios_produtos_00_tot_estoque')
	=Requery('v_romaneios_produtos_00_tot_producao')

	*--Vai Para a View de Estoque
	Sele v_romaneios_produtos_00_tot_estoque
	
	Scan

		*--Vai Para a View Filha Para Pegar Totais de Reservas
		Sele v_romaneios_produtos_00_reservas
		Sum r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, r16, r17, r18, r19, r20, r21, r22, r23, r24 to ;
		    xr1,xr2,xr3,xr4,xr5,xr6,xr7,xr8,xr9,xr10,xr11,xr12,xr13,xr14,xr15,xr16,xr17,xr18,xr19,xr20,xr21,xr22,xr23,xr24 ;
		    For cor_produto = v_romaneios_produtos_00_tot_estoque.cor_produto
		Sum r25, r26, r27, r28, r29, r30, r31, r32, r33, r34, r35, r36, r37, r38, r39, r40, r41, r42, r43, r44, r45, r46, r47, r48 to ;
		    xr25,xr26,xr27,xr28,xr29,xr30,xr31,xr32,xr33,xr34,xr35,xr36,xr37,xr38,xr39,xr40,xr41,xr42,xr43,xr44,xr45,xr46,xr47,xr48 ;
		    For cor_produto = v_romaneios_produtos_00_tot_estoque.cor_produto
		*--Vai Vara a View de Totais e Estoque Para Armazenar Totais

		Sele v_romaneios_produtos_00_tot_estoque

		For x = 1 To wMaximo_Tamanhos
			xCampo = 'TR'+AllT(Str(x))
			xVar   = 'xr'+AllT(Str(x))
			Repla &xCampo With iif(isnull(&xVar),0,&xVar) , Total_r With Total_r + iif(isnull(&xVar),0,&xVar)
		Next


		*--Vai Para a View DE pRODUCAO Para Pegar Totais
		Sele v_romaneios_produtos_00_tot_producao
		Sum  p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20, p21, p22, p23, p24 to ;
		    xp1,xp2,xp3,xp4,xp5,xp6,xp7,xp8,xp9,xp10,xp11,xp12,xp13,xp14,xp15,xp16,xp17,xp18,xp19,xp20,xp21,xp22,xp23,xp24 ;
		    For cor_produto = v_romaneios_produtos_00_tot_estoque.cor_produto
		Sum  p25, p26, p27, p28, p29, p30, p31, p32, p33, p34, p35, p36, p37, p38, p39, p40, p41, p42, p43, p44, p45, p46, p47, p48 to ;
		    xp25,xp26,xp27,xp28,xp29,xp30,xp31,xp32,xp33,xp34,xp35,xp36,xp37,xp38,xp39,xp40,xp41,xp42,xp43,xp44,xp45,xp46,xp47,xp48 ;
		    For cor_produto = v_romaneios_produtos_00_tot_estoque.cor_produto

		*--Vai Para a View Filha Para Pegar Totais de Embalados
		Sele v_romaneios_produtos_00_embalados
		Sum  e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11, e12, e13, e14, e15, e16, e17, e18, e19, e20, e21, e22, e23, e24 to ;
		    xe1,xe2,xe3,xe4,xe5,xe6,xe7,xe8,xe9,xe10,xe11,xe12,xe13,xe14,xe15,xe16,xe17,xe18,xe19,xe20,xe21,xe22,xe23,xe24 ;
		    For cor_produto = v_romaneios_produtos_00_tot_estoque.cor_produto
		Sum e25, e26, e27, e28, e29, e30, e31, e32, e33, e34, e35, e36, e37, e38, e39, e40, e41, e42, e43, e44, e45, e46, e47, e48 to ;
		    xe25,xe26,xe27,xe28,xe29,xe30,xe31,xe32,xe33,xe34,xe35,xe36,xe37,xe38,xe39,xe40,xe41,xe42,xe43,xe44,xe45,xe46,xe47,xe48 ;
		    For cor_produto = v_romaneios_produtos_00_tot_estoque.cor_produto
		*--Vai Vara a View de Totais e Estoque Para Armazenar Totais
		Sele v_romaneios_produtos_00_tot_estoque

		For x = 1 To wMaximo_Tamanhos
			xVar_es= 'es'+AllT(Str(x))    &&Campo que Armazena Qtde de Estoque
  			xVar_p = 'xp'+AllT(Str(x))    &&Variavel que Armazena Qtde de Producao
			xEmb   = 'TE'+AllT(Str(x))
			xVar_e = 'xe'+AllT(Str(x))    &&Variavel que Armazena Qtde de Embalado
			xVar_r = 'tr'+AllT(Str(x))    &&Variavel que Armazena Qtde de Reservas
			xSal   = 'T'+AllT(Str(x))
			Repla &xEmb   With &xVar_e,;
			      Total_e With Total_e + &xVar,;
			      &xSal   With IIF(IsNull(&xVar_es),0,&xVar_es) + &xVar_p - &xVar_e - &xVar_r,;
			      Total_t With Total_t + (IIF(IsNull(&xVar_es),0,&xVar_es) + &xVar_p - &xVar_e - &xVar_r)
		Next

	EndScan


	Sele v_romaneios_produtos_00_tot_estoque
	go top
	stor 0 to x
	stor '' to xCampo,xVar
	
	
Return



procedure f_volta  && Volta a Tab. Pai
sele V_romaneios_produtos_00
Return
*---------------------------------------------------------------------------------------------------------------------------*



**: Segundo Calculo / Rel. Analitico por cliente
**: Obs.: este calculo foi copiado do metodo da form e adaptado p/ o relatorio
procedure f_repopu  && Rquery/Calculo com armazenamento
	
	local x,xCampo,xVar,xVar_es,xVar_p,xEmb,xVar_e,xVar_r,xSal
	sele V_romaneios_produtos_00

	*--Repopula Tabelas
	=Requery('v_romaneios_produtos_00_Reservas')
	=Requery('v_romaneios_produtos_00_tot_estoque')
	=Requery('v_romaneios_produtos_00_tot_producao')

	*--Vai Para a View de Estoque
	Sele v_romaneios_produtos_00_tot_estoque
	
	Scan

		*--Vai Para a View Filha Para Pegar Totais de Reservas
		Sele v_romaneios_produtos_00_reservas
		Sum r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, r16, r17, r18, r19, r20, r21, r22, r23, r24 to ;
		    xr1,xr2,xr3,xr4,xr5,xr6,xr7,xr8,xr9,xr10,xr11,xr12,xr13,xr14,xr15,xr16,xr17,xr18,xr19,xr20,xr21,xr22,xr23,xr24 ;
		    For cor_produto = v_romaneios_produtos_00_tot_estoque.cor_produto
		Sum r25, r26, r27, r28, r29, r30, r31, r32, r33, r34, r35, r36, r37, r38, r39, r40, r41, r42, r43, r44, r45, r46, r47, r48 to ;
		    xr25,xr26,xr27,xr28,xr29,xr30,xr31,xr32,xr33,xr34,xr35,xr36,xr37,xr38,xr39,xr40,xr41,xr42,xr43,xr44,xr45,xr46,xr47,xr48 ;
		    For cor_produto = v_romaneios_produtos_00_tot_estoque.cor_produto
		*--Vai Vara a View de Totais e Estoque Para Armazenar Totais

		Sele v_romaneios_produtos_00_tot_estoque

		For x = 1 To wMaximo_Tamanhos
			xCampo = 'TR'+AllT(Str(x))
			xVar   = 'xr'+AllT(Str(x))
			Repla &xCampo With iif(isnull(&xVar),0,&xVar) , Total_r With Total_r + iif(isnull(&xVar),0,&xVar)
		Next


		*--Vai Para a View DE pRODUCAO Para Pegar Totais
		Sele v_romaneios_produtos_00_tot_producao
		Sum  p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20, p21, p22, p23, p24,qtde_p to ;
		    xp1,xp2,xp3,xp4,xp5,xp6,xp7,xp8,xp9,xp10,xp11,xp12,xp13,xp14,xp15,xp16,xp17,xp18,xp19,xp20,xp21,xp22,xp23,xp24,xqtde_p ;
		    For cor_produto = v_romaneios_produtos_00_tot_estoque.cor_produto
		Sum  p25, p26, p27, p28, p29, p30, p31, p32, p33, p34, p35, p36, p37, p38, p39, p40, p41, p42, p43, p44, p45, p46, p47, p48 to ;
		    xp25,xp26,xp27,xp28,xp29,xp30,xp31,xp32,xp33,xp34,xp35,xp36,xp37,xp38,xp39,xp40,xp41,xp42,xp43,xp44,xp45,xp46,xp47,xp48 ;
		    For cor_produto = v_romaneios_produtos_00_tot_estoque.cor_produto

		*--Vai Para a View Filha Para Pegar Totais de Embalados
		Sele v_romaneios_produtos_00_embalados
		Sum  e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11, e12, e13, e14, e15, e16, e17, e18, e19, e20, e21, e22, e23, e24 to ;
		    xe1,xe2,xe3,xe4,xe5,xe6,xe7,xe8,xe9,xe10,xe11,xe12,xe13,xe14,xe15,xe16,xe17,xe18,xe19,xe20,xe21,xe22,xe23,xe24 ;
		    For cor_produto = v_romaneios_produtos_00_tot_estoque.cor_produto
		Sum e25, e26, e27, e28, e29, e30, e31, e32, e33, e34, e35, e36, e37, e38, e39, e40, e41, e42, e43, e44, e45, e46, e47, e48 to ;
		    xe25,xe26,xe27,xe28,xe29,xe30,xe31,xe32,xe33,xe34,xe35,xe36,xe37,xe38,xe39,xe40,xe41,xe42,xe43,xe44,xe45,xe46,xe47,xe48 ;
		    For cor_produto = v_romaneios_produtos_00_tot_estoque.cor_produto
		*--Vai Vara a View de Totais e Estoque Para Armazenar Totais
		Sele v_romaneios_produtos_00_tot_estoque

		For x = 1 To wMaximo_Tamanhos
			xVar_es= 'es'+AllT(Str(x))    &&Campo que Armazena Qtde de Estoque
  			xVar_p = 'xp'+AllT(Str(x))    &&Variavel que Armazena Qtde de Producao
			xEmb   = 'TE'+AllT(Str(x))
			xVar_e = 'xe'+AllT(Str(x))    &&Variavel que Armazena Qtde de Embalado
			xVar_r = 'tr'+AllT(Str(x))    &&Variavel que Armazena Qtde de Reservas
			xSal   = 'T'+AllT(Str(x))
			Repla &xEmb   With &xVar_e,;
			      Total_e With Total_e + &xVar,;
			      &xSal   With IIF(IsNull(&xVar_es),0,&xVar_es) + &xVar_p - &xVar_e - &xVar_r,;
			      Total_t With Total_t + (IIF(IsNull(&xVar_es),0,&xVar_es) + &xVar_p - &xVar_e - &xVar_r)
			      
		Next

		For k = 1 to 48    && Itens
			k_ = allt(str(k))

			xPcampo&k_ = xPcampo&k_ + ES&k_ 	 		  && Estoque
			xRcampo&k_ = xRcampo&k_ + ES&k_ 	 		  && Estoque
			xGCampo&k_ = xGCampo&k_ + ES&k_ 	 		  && Estoque

			xPcampop&k_ = xPcampop&k_ + xp&k_ 	 		  && Producao
			xRcampop&k_ = xRcampop&k_ + xp&k_ 	 		  && Producao
			xGCampop&k_ = xGCampop&k_ + xp&k_ 	 		  && Producao

			xPcampoe&k_ = xPcampoe&k_ + TE&k_ 	 		  && Embalado
			xRcampoe&k_ = xRcampoe&k_ + TE&k_ 	 		  && Embalado
			xGCampoe&k_ = xGCampoe&k_ + TE&k_ 	 		  && Embalado

			xPcampor&k_ = xPcampor&k_ + TR&k_ 	 		  && Romaneado
			xRcampor&k_ = xRcampor&k_ + TR&k_ 	 		  && Romaneado
			xGCampor&k_ = xGCampor&k_ + TR&k_ 	 		  && Romaneado

			xPcampos&k_ = xPcampos&k_ + T&k_ 	 		  && Saldo
			xRcampos&k_ = xRcampos&k_ + T&k_ 	 		  && Saldo
			xGCampos&k_ = xGCampos&k_ + T&k_ 	 		  && Saldo

		EndFor

		* Totais de cada Item
		xPcampoT = xPcampoT + estoque	 		  && Estoque
		xRcampoT = xRcampoT + estoque 	 		  && Estoque
		xGCampoT = xGcampoT + estoque 	 		  && Estoque

		xPcampopT = xPcampopT + xqtde_p			&& Producao
		xRcampopT = xRcampopT + xqtde_p			&& Producao
		xGCampopT = xGcampopT + xqtde_p			&& Producao

		xPcampoeT = xPcampoeT + total_e  && Embalado
		xRcampoeT = xRcampoeT + total_e  && Embalado
		xGCampoeT = xGcampoeT + total_e  && Embalado

		xPcamporT = xPcamporT + total_r  && Romaneado
		xRcamporT = xRcamporT + total_r  && Romaneado
		xGCamporT = xGcamporT + total_r  && Romaneado

		xPcamposT = xPcamposT + total_t  && Saldo
		xRcamposT = xRcamposT + total_t  && Saldo
		xGCamposT = xGcamposT + total_t  && Saldo

	EndScan


	Sele v_romaneios_produtos_00_tot_estoque
	go top

	Sele v_romaneios_produtos_00_reservas
	go top

	stor 0 to x
	stor '' to xCampo,xVar
	sele V_romaneios_produtos_00

Return

*----------------------------------------------- Posicionamento dos ponteiros
procedure f_loca
x_sele = sele()

Sele v_romaneios_produtos_00_reservas
x__cor = cor_produto
Sele v_romaneios_produtos_00_tot_estoque
locate for cor_produto = x__cor
Sele v_romaneios_produtos_00_tot_producao
locate for cor_produto = x__cor
sele (x_sele)
Return



*-----------------------------------------------Zerar Tot Produto
proc f_zeraProd
For k = 1 to 48
	k_ = allt(str(k))
	stor 0 to xPcampo&k_,xPcampop&k_,xPcampoe&k_,xPcampor&k_,xPcampos&k_,xPcampoT,xPcampopT,xPcampoeT,xPcamporT,xPcamposT
EndFor
Return


*-----------------------------------------------Zerar Tot Tomaneio
proc f_zeraRoma
For k = 1 to 48
	k_ = allt(str(k))
	stor 0 to xRcampo&k_,xRcampop&k_,xRcampoe&k_,xRcampor&k_,xRcampos&k_,xRcampoT,xRcampopT,xRcampoeT,xRcamporT,xRcamposT
EndFor
Return



*-----------------------------------------------Zerar Geral no Inicio (porque na previa/print nao passa mais pelo init)
proc f_zeraInit

if x_Init

	For k = 1 to 48
		k_ = allt(str(k))
		stor 0 to xPcampo&k_ , xRcampo&k_ , xGCampo&k_  && Estoque
		stor 0 to xPcampop&k_, xRcampop&k_, xGCampop&k_	&& Producao
		stor 0 to xPcampoe&k_, xRcampoe&k_, xGCampoe&k_	&& Embalado
		stor 0 to xPcampor&k_, xRcampor&k_, xGCampor&k_	&& Romaneado
		stor 0 to xPcampos&k_, xRcampos&k_, xGCampos&k_	&& Saldo
	EndFor

	Stor 0 to xPcampoT,xPcampopT,xPcampoeT,xPcamporT,xPcamposT,;
			  xRcampoT,xRcampopT,xRcampoeT,xRcamporT,xRcamposT,;
			  xGcampoT,xGcampopT,xGcampoeT,xGcamporT,xGcamposT

	x_Init = .f.

EndIf


*-----------------------------------------------Habilita variavel para acesso a f_zeraInit
proc f_LigaZera
x_Init = .f.
Return
***

*-----------------------------------------------Zera Final 
proc f_ZeraGer
x_Init = .t.
=f_zeraInit()
Return
