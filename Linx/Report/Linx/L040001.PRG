*-- Objetivo: Funcões Para Ficha Técnica (Fox e Crystal)
*--         : Todas as Fichas
*===================================================================================================================================================*


*===================================================================================================================================================*
*== [ F u n ç õ e s   -   F T   F O X ]
	Function f_requery_Aviamentos
		Requery("v_produtos_00_cores")
		*-----------------------------------------------------------------
		*- 13/02/2012 - Alterado por Szalontai para atender a TP 1697256
		*-----------------------------------------------------------------
		f_chkmp(.t.)
	Return .t.

	*-----------------------------------------------------------------
	*- 13/02/2012 - Adicionado por Szalontai para atender a TP 1697256
	*-----------------------------------------------------------------
	Function f_requery_Aviamentos2
		Requery("v_produtos_00_cores")
		f_chkmp(.f.)
	Return .t.
	*--
	Procedure fx_popula_Medidas && Procedures usadas internamente nos reports
		Requery('v_produtos_tab_medidas_00_medidas')
		Requery('v_produtos_tab_medidas_00')
	Return .t.

	*--
	Procedure fx_repopula_ficha
		sele v_produtos_ficha_01
		=requery()
	Return .t.

	*--
	Procedure Fx_Popula_Fotos
		Sele V_produtos_00_fotos
		Requery()
	Return .t.

	*--
	Procedure f_chkMP
		*-----------------------------------------------------------------
		*- 13/02/2012 - Alterado por Szalontai para atender a TP 1697256
		*-----------------------------------------------------------------
		Param x_tipo
		
		*-----------------------------------------------------------------
		*- 13/02/2012 - Alterado por Szalontai para atender a TP 1697256
		*-----------------------------------------------------------------
		If Type("x_tipo") <> "L"
		   x_tipo = .t.
		Endif   
		xali = sele()
		Sele vtmp_produtos_ficha_01_cor
		xreco = recno()
		xproduto   = PRODUTO
		xmaterial  = MATERIAL
		xitem      = ITEM
		xcor_mat   = COR_MATERIAL
		xd_cor_mat = DESC_COR_MATERIAL

		Count to xcores whil PRODUTO = xproduto and MATERIAL = xmaterial and ITEM = xitem
		go xreco
		Count to xcorrec whil PRODUTO = xproduto and MATERIAL = xmaterial and ITEM = xitem and COR_MATERIAL = xcor_mat

		If xcorrec = xcores AND EMPTY(xl_cor) &&+
		   Skip -1
		   xmesma = iif( ! xpor_cor ,.T.,.F.)
		Else
		   xmesma = .F.
		   Go xreco
		Endi   
		*-----------------------------------------------------------------
		*- 13/02/2012 - Alterado por Szalontai para atender a TP 1697256
		*-----------------------------------------------------------------
		If !x_tipo
			xmesma = .F.
		   Go xreco
		EndIf 

		SELECT(xali)
	Return .t.

	*--
	Procedure fx_pega_pag
		IF TYPE('xpag')<>'N'
			xpag = 0
		ENDIF
		xpag = xpag + 1
	Return xpag

	*--
	Procedure fx_pega_cores
		Param x_tipo
		
		If Type("x_tipo") <> "C"
		   x_tipo = " "
		Endif   
		  
		xarea = SELE()
		If x_tipo <> "1"
			Sele vtmp_produtos_cores
			zap
			Append Blank
			Repl PRODUTO with v_produtos_00.PRODUTO
		Endif
		Sele v_produtos_00_cores
		=requery()

		Store "" To xcores_p
		if ! eof()
			xrecord = Recno()
			Store "" To xcores_p
		    xc = 0
			Scan
			    If x_tipo <> "1"
			        xc = xc + 1	    
			        If xc <= 48
				        xcampo = "COR_"+Allt(str(xc,2))
				        Sele vtmp_produtos_cores
				        Repl &xcampo with Allt(v_produtos_00_cores.COR_PRODUTO) + "-" + Allt(v_produtos_00_cores.DESC_COR_PRODUTO)
				    Endif
				endif
			    Sele v_produtos_00_cores
			    xcores_p = xcores_p + ALLTRIM(COR_PRODUTO) + " "
			EndS    
			xcores_p = Allt(xcores_p)
			Go xrecord
		endif

		SELECT (xarea)
	Retu .t.

	*--
	Function fx_pega_cores_mat
		xarea = sele()
		xreg  = recno()

		Sele vtmp_materiais_cores
		zap

		sele vtmp_produtos_ficha_01_cor
		go Top
		do whil !eof()
			xmat = MATERIAL
			xpro = PRODUTO
			xitem= ITEM
			xc = 0
			Sele vtmp_materiais_cores
			Append Blank
			Repl PRODUTO with xpro, MATERIAL with xmat, ITEM WITH xitem,;
			     DESC_MATERIAL with vtmp_produtos_ficha_01.DESC_MATERIAL,;
			     DESC_USO_MATERIAL with NVL(vtmp_produtos_ficha_01.DESC_USO_MATERIAL,'')

			Sele vtmp_produtos_ficha_01_cor
			Do Whil MATERIAL = xmat and ITEM = xitem and !eof()
			   xc = xc + 1
			   If xc <= 48
				   xcampo = "COR_"+Allt(Str(xc,2))
				   Sele vtmp_produtos_ficha_01_cor
				   If Porcentagem_consumo <> 0
				      Sele vtmp_materiais_cores
				      Repl &xcampo With Allt(vtmp_produtos_ficha_01_cor.COR_MATERIAL)+"-"+Allt(vtmp_produtos_ficha_01_cor.DESC_COR_MATERIAL)+iif(empty(vtmp_produtos_ficha_01_cor.refer_fabricante),'','('+Allt(vtmp_produtos_ficha_01_cor.refer_fabricante)+')')
				      Sele vtmp_produtos_ficha_01_cor
				   Else
				      Sele vtmp_materiais_cores
				      Repl &xcampo With Space(20)
				      Sele vtmp_produtos_ficha_01_cor
				   Endif      
			   Endif
			   Skip
			Enddo   

			Sele vtmp_materiais_cores
			xdelea = .F.
			xdeleb = .F.
			xmcor  = .F.
			xcorold = COR_1
			xcorstr = ""
			
			For i = 1 to 10
			    xcora = "COR_"+Allt(str(i,2))
			    xcorb = "vtmp_produtos_cores.COR_"+allt(str(i,2))
			    xcorc = "COR_"+Allt(Str(iif(i=1,1,i-1),2))
			    
			    If Empty(&xcora)
			       Loop
			    Else
		           
		           If xcorold = &xcora
		              xmcor = .T.
		           Else
		              xmcor = .F.
		           Endif
		         
		           If i > 1
		              If &xcora = &xcorc
		                 xdelea = .T.
		              Else
		                 xdelea = .F.
		                 exit
		              endif          
		           Else
		              xdelea = .F. 
		           Endif      
		             
			       If &xcora = &xcorb
			          xdeleb = .T.
			       Else
			          xdeleb = .F.
			       Endif
			       
			    Endif
			Next   
			
			If xmcor and xcolor
				* 	   Repl COR_1 with "MESMA COR DE MATERIAL (", COR_2 with allt(xcorold)+") P/ TODAS AS CORES PA", COR_3 with space(25), COR_4 with Space(25),;
				*	        COR_5 with Space(25), COR_6 with Space(25), COR_7 with Space(25), COR_8 with Space(25), COR_9 with Space(25), COR_10 with Space(25), COR_11 with Space(25),;
				*	        COR_12 with Space(25)
		    Else
		    	If (xdelea)  && .or. xdeleb)
		    	   DELE
		    	Endif	
			Endif    	
		 	
			Sele vtmp_produtos_ficha_01_cor   
		Enddo

		Sele vtmp_materiais_cores
		Go Top

		SELECT (xarea)
		if reccount() > 0
			go xreg
		endif
	RETURN .t.

*== fim(FT-Fox) 
*===================================================================================================================================================*



*===================================================================================================================================================*
*== F u n ç õ e s   -   F T   C r y s t a l
	Procedure Ini_FT_Crystal
	lParameters xtipo, xObj,xMaxCores

		if UPPER(xtipo)='PRE' or UPPER(xtipo)='IMP' or UPPER(xtipo)='EXP'

			If Not "L002006" $ UPPER(Set("Procedure"))
				Set Proc to ..\Report.prg\L002006.prg Additive
			EndIf 

			store .t. to xi_materiais,xi_cores,xcolor,xi_medidas,xi_fotos,xi_operacoes,xi_extras,xi_botao
			store .f. to xRevenda
			System.ExecuteForm("lxoprel_FT","v_produtos_ficha_01.PRODUTO")

			if !(xi_materiais or xi_cores or xi_medidas or xi_fotos or xi_operacoes or xi_extras) OR (TYPE('xi_botao')='C' and xi_botao='CANCEL')
				Return .f.
			endif
			xi_todas_cores = xcolor

			*--- Filtro Revenda
			sele v_produtos_00
			IF xRevenda
				Index on produto tag iProd
			ELSE
				Index on produto tag iProd for !Revenda
			ENDIF
			
			if eof()
				=f_msg(['Nenhum produto (Não Revenda) Selecionado...',48])
				index on produto tag iProd
				Return .f.
			endif
			
			f_popula_filha('v_produtos_00','v_Produtos_Tab_Operacoes_00_Operacoes',,,;
						   'space(25) linha_industrial,space(25) tolerancia,space(LEN(v_produtos_00.grade)) grade, space(LEN(v_produtos_00.produto)) produto',;
						   'replace linha_industrial with v_produtos_TAB_operacoes_00.linha_industrial, tolerancia with v_produtos_TAB_operacoes_00.tolerancia,grade with v_produtos_00.grade, produto with v_produtos_00.produto',,;
						   'o_040001.lx_operacoes()')

			f_popula_filha('v_produtos_00','v_Produto_Operacoes_00_Rotas',,,;
						   'space(LEN(v_produtos_00.grade)) grade, space(LEN(v_produtos_00.produto)) produto',;
						   'replace grade with v_produtos_00.grade, produto with v_produtos_00.produto')

			f_popula_filha('v_produtos_00','v_produtos_00_ope_extra')
			f_popula_filha('v_produtos_00','v_produtos_ficha_01',,,'space(LEN(v_produtos_00.grade)) grade','replace grade with v_produtos_00.grade',,,.t. )			

			*-- Pegar Maior Custo da cor do material (quando varia por cor)
			SELECT vTmp_produtos_ficha_01
			SCAN
				f_select('select varia_custo_cor from materiais where material=?vTmp_produtos_ficha_01.material','Cur_Chk_VCC',ALIAS())
				f_select('select largura from materiais where material=?vTmp_produtos_ficha_01.material','tmp_largura',ALIAS())
				IF Cur_Chk_VCC.varia_custo_cor
					f_select('select MAX(custo_reposicao) maior_custo_reposicao from materiais_cores where material=?vTmp_produtos_ficha_01.material','Cur_Custo_CoresMat',ALIAS())
					REPLACE custo_reposicao WITH NVL(Cur_Custo_CoresMat.maior_custo_reposicao,0)
				ENDIF
				SELECT vTmp_produtos_ficha_01
				replace largura_material WITH NVL(tmp_largura.largura,'')
			ENDSCAN

			IF TYPE('xi_obs')='U'
				PUBLIC xi_obs
				xi_obs = .t.
			ENDIF

			CREATE CURSOR CurImprimeObs ( ImprimeObs c(1) )
			SELECT CurImprimeObs
			APPEND BLANK
			replace ImprimeObs WITH IIF(xi_Obs,'1','2')
			
			=Gerar_Comb_Cores(xi_todas_cores)
			=General_Fotos_Prod(xi_fotos)
			=General_Fotos_Medidas(xi_medidas)
			
			*--- alimenta formulas do rel. do crystal ( 1 a 5 = reservado p/ parâmetros padrões )
			xObj.SetFormulaCrystal('xi_materiais'  ,iif(xi_materiais,'1','0'))
			xObj.SetFormulaCrystal('xi_cores'      ,iif(xi_cores,'1','0'))
			xObj.SetFormulaCrystal('xi_todas_cores',iif(xi_todas_cores,'1','0'))
			xObj.SetFormulaCrystal('xi_medidas'    ,iif(xi_medidas,'1','0'))
			xObj.SetFormulaCrystal('xi_fotos'      ,iif(xi_fotos,'1','0'))
			xObj.SetFormulaCrystal('xi_operacoes'  ,iif(xi_operacoes,'1','0'))
			xObj.SetFormulaCrystal('xi_extras'     ,iif(xi_extras,'1','0'))

			*--- filhas / sub
			xObj.CopyTables("vtmp_produtos_ficha_01")
			xObj.CopyTables("tmpFT_Fotos_Produtos")
			xObj.CopyTables("tmpFT_Fotos_Medidas")
			xObj.CopyTables("tmpFT_Medidas")
			xObj.CopyTables("tmpFT_Medidas_Tam")
			xObj.CopyTables("vtmp_produtos_ficha_01_cor")
			xObj.CopyTables("vtmp_Produtos_Tab_Operacoes_00_Operacoes")
			xObj.CopyTables("vTmp_Produto_Operacoes_00_Rotas")
			xObj.CopyTables("vtmp_produtos_00_ope_extra")
			xObj.CopyTables("v_produtos_tamanho_00")
			xObj.CopyTables("v_colecoes_00")
			xObj.CopyTables("CurImprimeObs")

			*--- Desc tamanho base
			sele v_produtos_00
			go top
			scan
				sele v_produtos_tamanho_00 
				locate for grade = v_produtos_00.grade
				sele v_produtos_00
				xTBase = 'v_produtos_tamanho_00.tamanho_' + IIF(BETWEEN(tamanho_base,1,48),allt(str(tamanho_base)),'1')
				Replace desc_tamanho_base with &xTBase
			endscan
			go top

			*!*		*--- Imprimir Report de Cores a parte caso numero de cores seja maior que limite suportado no obj subreport cores.
			*!*		if xi_cores
			*!*			select produto,count(distinct cor_produto) as ncores from vtmp_produtos_ficha_01_cor group by 1 order by 2 desc into cursor cur_color
			*!*			if cur_color.ncores > xMaxCores
			*!*				*--- Pai
			*!*				xObj.CopyTables(xObj.MainAlias)

			*!*				*--- Imprime >> Principal
			*!*				xi_cores = .f.
			*!*				xObj.SetFormulaCrystal('xi_cores',iif(xi_cores,'1','0'))
			*!*				xObj.PrintCrystalReport(xTipo)
			*!*							
			*!*				*--- Imprime >> Cores a Parte
			*!*				xRelCores = wdir_exe+'\report\linx\l040001jr ficha técnica - todas as cores.rpt'
			*!*				if file(xRelCores)
			*!*					wait wind 'Pressione <qualquer tecla> para visualizar cores...'
			*!*					xObj.LoadEnvCrystal(xRelCores)
			*!*					 xObj.PrintCrystalReport(xTipo)
			*!*				endif
			*!*							
			*!*				Return .f.
			*!*			endif
			*!*		endif

			SELECT v_produtos_00
			Index on produto tag iProd

		ENDIF
	Return .t.

	*--
	Procedure General_Fotos_Prod  && Produtos
		Param xpFotos
		Create cursor tmpFT_Fotos_Produtos (produto c(12),legenda c(50), Foto g, obs c(254), obs2 c(254), obs3 c(254), obs4 c(254) ) && Não pode usar nocptrans em campo chave (produto)

		if xpFotos
			sele v_produtos_00
			xRegTotal = reccount()
			xRegAtual = 0
			go top
			scan
				xRegAtual = xRegAtual + 1
				cMessage = string.translate("Processando fotos do Produto : {0}", alltrim(v_produtos_00.produto))
				Messagebox.ShowProgress(cMessage, xRegTotal, , .t.)
				sele v_produtos_00_fotos
				requery()

				SCAN 
					xfoto = ALLTRIM(v_produtos_00_fotos.path_foto)
					IF !isnull(xfoto) and file(xfoto)
						sele tmpFT_Fotos_Produtos
						appe blank

						xObs = NVL(ALLTRIM(v_produtos_00_fotos.obs),'')
							xObs1 = SUBSTR(xObs,001,254)
							xObs2 = SUBSTR(xObs,255,254)
							xObs3 = SUBSTR(xObs,509,254)
							xObs4 = SUBSTR(xObs,763,254)
						
						replace produto with v_produtos_00.produto, legenda with v_produtos_00_fotos.legenda,;
								obs WITH xObs1,obs2 WITH xObs2,obs3 WITH xObs3,obs4 WITH xObs4

						xfoto_copy = PxGDI_SaveImg_AsBMP(xfoto)
						TRY
							append general foto from '&xfoto_copy'
						CATCH
							WAIT WINDOW 'Imagem Inválida....'+CHR(13)+xfoto TIMEOUT 5
						ENDTRY
					ENDIF
				ENDSCAN 

				sele v_produtos_00
			ENDSCAN
			Messagebox.ShowProgress()
		endif

	Return .t.


	*--
	Procedure General_Fotos_Medidas && Medidas
		Param xpMedidas

	*/	Create cursor tmpFT_Fotos_Medidas (tabela_medidas c(25) nocptrans,Foto_Dianteiro g,Foto_Traseiro g) 
		Create cursor tmpFT_Fotos_Medidas (tabela_medidas c(25),Foto_Dianteiro g,Foto_Traseiro g,Path_Foto_Dianteiro c(120),Path_Foto_Traseiro c(120))  && Não pode usar nocptrans em campo chave (tabela_medidas)
		
		sele tmpFT_Fotos_Medidas
		index on tabela_medidas tag iTbMdFt

		f_select('select *, space(25) as grade from produtos_medidas WHERE 1=2','tmp_')
		sele tmp_
		=afields(xcampos)
		Create cursor tmpFT_Medidas from array xcampos

		f_select('select * from produtos_tamanhos WHERE 1=2','tmp_')
		sele tmp_
		=afields(xcampos)
		Create cursor tmpFT_Medidas_Tam from array xcampos
		sele tmpft_medidas
		index on tabela_medidas tag iTbMd


		if xpMedidas
			sele v_produtos_00
			xRegTotal = reccount()
			xRegAtual = 0
			go top
			scan
				xRegAtual = xRegAtual + 1
	*			f_prog_bar('Processado Fotos/Medidas do Produto: '+v_produtos_00.produto,xRegAtual,xRegTotal,.t.)
				cMessage = string.translate("Processando fotos/medidas do Produto : {0} ", alltrim(v_produtos_00.produto))
				Messagebox.ShowProgress(cMessage, xRegTotal,,.t.)

				if !f_vazio(v_produtos_00.tabela_medidas)
					f_select('select foto_dianteiro,foto_traseiro from produtos_tab_medidas where tabela_medidas=?v_produtos_00.tabela_medidas','tmp_medidas',alias())
					stor '' to xFotoD,xFotoT
					if !isnull(tmp_medidas.foto_dianteiro) and file(tmp_medidas.foto_dianteiro)
						xFotoD = PxGDI_SaveImg_AsBMP(ALLTRIM(tmp_medidas.foto_dianteiro))
					endif
					if !isnull(tmp_medidas.foto_traseiro) and file(tmp_medidas.foto_traseiro)
						xFotoT = PxGDI_SaveImg_AsBMP(ALLTRIM(tmp_medidas.foto_traseiro))
					endif

					if !empty(xFotoD) or !empty(xFotoT)
						sele tmpFT_Fotos_Medidas
						seek v_produtos_00.tabela_medidas
						if eof()
							appe blank
							Replace tabela_medidas with NVL(v_produtos_00.tabela_medidas,'')
							if !empty(xFotoD)
								TRY
									APPEND general Foto_Dianteiro from '&xFotoD'
									REPLACE Path_Foto_Dianteiro with xFotoD
								CATCH
									WAIT WINDOW 'Imagem Inválida....'+CHR(13)+xfoto TIMEOUT 5
								ENDTRY 
							endif
							if !empty(xFotoT)
								TRY
									APPEND general Foto_Traseiro from '&xFotoT'
									REPLACE Path_Foto_Traseiro with xFotoT
								CATCH
									WAIT WINDOW 'Imagem Inválida....'+CHR(13)+xfoto TIMEOUT 5
								ENDTRY 
							endif
						endif
					endif
				endif

				*--- Dados da tab. de medidas (em dbf)
				f_select('select * from produtos_medidas WHERE TABELA_MEDIDAS=?v_produtos_00.tabela_medidas','tmp_medidas')
				sele tmp_medidas
				go top
				scan
					scatter to xmemvar
					sele tmpFT_Medidas
					locate for tabela_medidas=v_produtos_00.tabela_medidas and medida=tmp_medidas.medida
					if eof()
						appe blank
						gather from xmemvar
						replace grade with v_produtos_00.grade
						sele tmp_medidas
					endif
				endscan

				*-- Key:
				SELECT tmpFT_Fotos_Medidas
				LOCATE FOR tabela_medidas==v_produtos_00.tabela_medidas				
				IF EOF()
					APPEND BLANK 
					REPLACE tabela_medidas WITH NVL(v_produtos_00.tabela_medidas,'')	
				ENDIF

				*--- tamanhos p/medidas
				sele tmpFT_Medidas_Tam
				locate for grade == v_produtos_00.grade
				if eof()
					f_select('select * from produtos_tamanhos WHERE grade=?v_produtos_00.grade','tmp_grade')
					sele tmp_grade
					scatter to xmemvar
					sele tmpFT_Medidas_Tam
					appe blank
					gather from xmemvar
				endif
				
				sele v_produtos_00
			endscan
			Messagebox.ShowProgress()
		ENDIF
		
	RETURN .t.

	*--
	Procedure Gerar_Comb_Cores && Combinação de Cores
		Param pxTCores

		f_popula_filha('v_produtos_00','v_produtos_ficha_01_cor',,,;
					   'space(LEN(v_produtos_00.grade)) grade, space(40) as desc_produto,space(40) as desc_uso_material,space(40) as parte_aplicado_material',;
					   'replace grade with v_produtos_00.grade, desc_produto with v_produtos_00.desc_produto')

		IF !USED('vtmp_produtos_ficha_01')
			f_popula_filha('v_produtos_00','v_produtos_ficha_01',,,'space(LEN(v_produtos_00.grade)) grade','replace grade with v_produtos_00.grade',,,.t. )
		endif

		*---- Elimina Cores Repetidas
		select produto,material,count(distinct cor_material) as num_dist_cores from vtmp_produtos_ficha_01_cor group by produto,material into cursor tmp_count_cores
		sele tmp_count_cores
		set filt to num_dist_cores=1
		go top

		if !eof() and !pxTCores
			scan
				sele vtmp_produtos_ficha_01_cor
				dele all for produto=tmp_count_cores.produto and material=tmp_count_cores.material
				sele tmp_count_cores
			endscan
		endif

		*---- Atualiza Campos (descrição)
		sele vtmp_produtos_ficha_01_cor
		go top
		scan
			f_select('select desc_cor_produto from produto_cores where produto=?vtmp_produtos_ficha_01_cor.produto and cor_produto=?vtmp_produtos_ficha_01_cor.cor_produto','tmp_cor_prod',alias())

			sele vtmp_produtos_ficha_01
			LOCATE FOR produto=vtmp_produtos_ficha_01_cor.produto AND material=vtmp_produtos_ficha_01_cor.material AND item=vtmp_produtos_ficha_01_cor.item

			sele vtmp_produtos_ficha_01_cor
			Replace desc_cor_produto  		WITH NVL(tmp_cor_prod.desc_cor_produto,''),;
					desc_uso_material 		WITH NVL(vtmp_produtos_ficha_01.desc_uso_material,''),;
					parte_aplicado_material WITH NVL(vtmp_produtos_ficha_01.parte_aplicado_material,'')
		endscan

	Return .t.
	*--------------------------------------------------------------------------------------------------------------------*

*== fim(FT-Crystal) 
*===================================================================================================================================================*
