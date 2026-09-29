procedure func_Relatorio
lparameter xtipo,xObj

	if UPPER(xtipo)='PRE' or UPPER(xtipo)='IMP'

		If Not "L002006" $ UPPER(Set("Procedure"))
			Set Proc to ..\Report.prg\L002006.prg Additive
		EndIf 

		f_popula_filha('v_produtos_modelo_01','v_produtos_modelo_01_tecidos')
		f_popula_filha('v_produtos_modelo_01','v_produtos_modelo_01_materiais')
		f_popula_filha('v_produtos_modelo_01','v_produtos_modelo_01_subconjunto')
		f_popula_filha('v_produtos_modelo_01','v_produtos_modelo_01_produtos')
		=Gerar_Tabs_Auxs()

		xObj.CopyTables('v_produtos_tamanho_00')
		xObj.CopyTables('vtmp_produtos_modelo_01_tecidos')
		xObj.CopyTables('vtmp_produtos_modelo_01_materiais')
		xObj.CopyTables('vtmp_produtos_modelo_01_subconjunto')
		xObj.CopyTables('vtmp_produtos_modelo_01_produtos')
		xObj.CopyTables('vtmp_fotos_modelagem')
		xObj.CopyTables('vtmp_tb_medidas')
		xObj.CopyTables('vtmp_tb_medidas_itens')
		
	endif

Return .t.
*-------------------------------------------------------------------------------------------------------------------*



*-------------------------------------------------------------------------------------------------------------------*
Procedure Gerar_Tabs_Auxs
Param xpFotos

	Create cursor vtmp_fotos_modelagem (modelagem c(10),foto_dianteiro g,foto_traseiro g)

	xSelMed_p = 'select * from produtos_tab_medidas where tabela_medidas=?v_produtos_modelo_01.tabela_medidas'
	xSelMed_f = 'select * from produtos_medidas where tabela_medidas=?v_produtos_modelo_01.tabela_medidas'

	f_select(xSelMed_p,'cur_medidas_p')
	sele a.*, b.foto_dianteiro as img_foto_dianteiro, b.foto_traseiro as img_foto_traseiro from cur_medidas_p a, vtmp_fotos_modelagem b where .f. into cursor vtmp_tb_medidas readwrite

	f_select(xSelMed_f,'cur_medidas_f')
	sele * from cur_medidas_f where .f. into cursor vtmp_tb_medidas_itens readwrite

	sele v_produtos_modelo_01
	xRegTotal = reccount()
	xRegAtual = 0
	go top
	scan
		xRegAtual = xRegAtual + 1
	*	f_prog_bar('Processando Fotos da Modelagem '+v_produtos_modelo_01.modelagem,xRegAtual,xRegTotal,.t.)
		cMessage = string.translate("Processando fotos da Modelagem : {0}", alltrim(v_produtos_modelo_01.modelagem))
		Messagebox.ShowProgress(cMessage, xRegTotal, , .t.)

		*--- fotos Modelagem
		xfoto_dianteiro = v_produtos_modelo_01.foto_dianteiro
		xfoto_traseiro  = v_produtos_modelo_01.foto_traseiro
		sele vtmp_fotos_modelagem
		appe blank
		replace modelagem with v_produtos_modelo_01.modelagem

		if !isnull(xfoto_dianteiro) and file(xfoto_dianteiro)
			xFotoBmp = PxGDI_SaveImg_AsBMP(ALLTRIM(xfoto_dianteiro))
			append general foto_dianteiro from (xFotoBmp)
		endif 	
		if !isnull(xfoto_traseiro) and file(xfoto_traseiro)
			xFotoBmp = PxGDI_SaveImg_AsBMP(ALLTRIM(xfoto_traseiro))
			append general foto_traseiro from (xFotoBmp)
		endif 	

		*--- Medidas
		f_select(xSelMed_p,'cur_medidas_p')
		sele cur_medidas_p
		scatter TO xmemvar_p
		xfoto_med_dianteiro = cur_medidas_p.foto_dianteiro
		xfoto_med_traseiro  = cur_medidas_p.foto_traseiro


		*- pai
		sele vtmp_tb_medidas
		APPEND blank
		GATHER FROM xmemvar_p
		if !isnull(xfoto_med_dianteiro) and file(xfoto_med_dianteiro)
			xFotoBmp = PxGDI_SaveImg_AsBMP(ALLTRIM(xfoto_med_dianteiro))
			append general img_foto_dianteiro from (xFotoBmp)
		endif 	
		if !isnull(xfoto_med_traseiro) and file(xfoto_med_traseiro)
			xFotoBmp = PxGDI_SaveImg_AsBMP(ALLTRIM(xfoto_med_traseiro))
			append general img_foto_traseiro from (xFotoBmp)
		endif 	
		
		*-filha
		f_select(xSelMed_f,'cur_medidas_f')
		sele cur_medidas_f
		go top
		scan
			scatter TO xmemvar_f
			sele vtmp_tb_medidas_itens
			appe blank
			gather FROM xmemvar_f
			sele cur_medidas_f
		endscan

		sele v_produtos_modelo_01
	endscan

	Messagebox.ShowProgress()
	sele v_produtos_modelo_01
	go top

Return .t.
*-------------------------------------------------------------------------------------------------------------------*





	*!*	*-------------------------------------------------------------------------------------------------------------------*
	*!*	Procedure General_Fotos_Modelagem 
	*!*	Param xpFotos
	*!*	Create cursor vtmp_fotos_modelagem (modelagem c(10),foto_dianteiro g,foto_traseiro g)

	*!*	sele v_produtos_modelo_01
	*!*	xRegTotal = reccount()
	*!*	xRegAtual = 0
	*!*	go top
	*!*	scan
	*!*		xRegAtual = xRegAtual + 1
	*!*		f_prog_bar('Processando Fotos da Modelagem '+v_produtos_modelo_01.modelagem,xRegAtual,xRegTotal,.t.)
	*!*		xfoto_dianteiro = v_produtos_modelo_01.foto_dianteiro
	*!*		xfoto_traseiro  = v_produtos_modelo_01.foto_traseiro

	*!*		sele vtmp_fotos_modelagem
	*!*		appe blank
	*!*		replace modelagem with v_produtos_modelo_01.modelagem

	*!*		if !isnull(xfoto_dianteiro) and file(xfoto_dianteiro)
	*!*			append general foto_dianteiro from '&xfoto_dianteiro'
	*!*		endif 	
	*!*		if !isnull(xfoto_traseiro) and file(xfoto_traseiro)
	*!*			append general foto_traseiro from '&xfoto_traseiro'
	*!*		endif 	

	*!*		sele v_produtos_modelo_01
	*!*	endscan

	*!*	sele v_produtos_modelo_01
	*!*	go top
	*!*	*-------------------------------------------------------------------------------------------------------------------*

