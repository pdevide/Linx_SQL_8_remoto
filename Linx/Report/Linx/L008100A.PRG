******************************************************************************************************************************************************************************************
** Documentação das alterações realizadas no PRG. Deixe sempre a última alteração no começo
** do PRG, colocando a data, o nome e a alteração feita.
******************************************************************************************************************************************************************************************
** 10/07/2025 - DARIO SILVA - ENTERMODA-25603   - SPK 02.25 - #4# - Ajuste relatórios tela 008025
** 19/05/2025 - DARIO SILVA - ENTERMODA-22752   - 1.25.040  - #3# - Ajuste relatórios tela 008425
** 03/10/2024 - VALMIR SOARES - LINXERP-19616   - SPK 2.24 (9.0.0) - #2# - Tratamento para relatórios de classe
** 29/01/2013 - Szalontai - TP 3268407 - #1#
** Alteração na procedure fu_Hab_Page no momento em que as strings xSetCalc e xActPage são populadas. Quando o parametro global wcontrole era utilizado,
** estava sendo considerado as tres ultimas letras caso a tela fosse exclusiva, desta forma o objeto o_008125 não era encontrado. Foi fixado para pegar somente
** os seis caracteres referentes ao nome da tela.
******************************************************************************************************************************************************************************************

Procedure Func_Relatorio
	Lparameter xtipo,xObj

	Return ( Fx_Init_008100(xtipo,xObj) )
	*---------------------------------------------------------------------------------------------------------------------------------------------------*

Function Fx_Init_008100
	Lparameter xtipo,xObj

	If !Used('v_producao_os_01_tarefas')
		f_Msg(['Não há informações válidas para este report...',48,'<Aviso>'])
		Return .F.
	Endif

	If Not "L002006" $ Upper(Set("Procedure"))
		Set Proc To ..\Report.prg\L002006.prg Additive
	Endif

	Create Cursor cur_fotos (produto c(12), path_foto c(70),Foto g, colecao c(25), griffe c(25), desc_composicao c(100) )
	xInfoAn  = Iif(Used('v_producao_os_02_materiais'),f_Msg(['Deseja Obter Informações Analíticos?',36,'Dados de Origem Para Materiais'])=6,.T.)

	*-- #4#
	*-- #3#
	*-- #2#
	If xInfoAn
		If !Inlist(wcontrole, "LX008425", "LX008025")
			If !Used('v_producao_os_02_materiais')
				f_Msg(['Não há informações válidas para este report...',48,'<Aviso>'])
				Return .F.
			Endif
		Endif
	Else
		If !Used('v_producao_os_01_materiais')
			If !Inlist(wcontrole, "LX008425", "LX008025")
				f_Msg(['Não há informações válidas para este report...',48,'<Aviso>'])
				Return .F.
			Endif
		Endif
	Endif
	*-- #2#
	*-- #3#
	*-- #4#

	f_popula_filha('v_producao_os_01',Iif(xInfoAn,'v_producao_os_01_materiais','v_producao_os_02_materiais'),'vtmp_producao_os_01_materiais',,,'replace ordem_servico with v_producao_os_01.ordem_servico',,'fu_Hab_Page()',.T.)
	f_popula_filha('v_producao_os_01','v_producao_os_01_tarefas')

	If xInfoAn
		fu_Add_Mat_Faltantes()
	Endif

	Select Distinct produto From vtmp_producao_os_01_tarefas Into Cursor tmp_prod_lista
	Sele tmp_prod_lista
	Go Top
	Scan
		*f_select('select a.path_foto,b.griffe,c.desc_colecao as colecao from produtos_foto a,produtos b, colecoes c where a.produto=b.produto and c.colecao=b.colecao and a.produto=?tmp_prod_lista.produto','tmp_fotos',ALIAS())
		f_select('select path_foto from produtos_foto where produto=?tmp_prod_lista.produto','tmp_fotos',Alias())
		f_select('select a.griffe,b.desc_colecao from produtos a join colecoes b on a.colecao=b.colecao where a.produto=?tmp_prod_lista.produto','tmp_griffe_colecao',Alias())
		f_select('select b.desc_composicao from produtos a join materiais_composicao b on a.composicao=b.composicao where a.produto=?tmp_prod_lista.produto','tmp_composicao',Alias())
		Select cur_fotos
		Append Blank
		Replace produto         With tmp_prod_lista.produto,;
			path_foto       With tmp_fotos.path_foto,;
			colecao         With tmp_griffe_colecao.desc_colecao,;
			griffe          With tmp_griffe_colecao.griffe,;
			desc_composicao With tmp_composicao.desc_composicao
		xfoto = tmp_fotos.path_foto
		If !Isnull(xfoto) And File(xfoto)
			xFotoBmp = PxGDI_SaveImg_AsBMP(Alltrim(xfoto))
			Append General Foto From (xFotoBmp)
		Endif
		Sele tmp_prod_lista
	Endscan

	*--- Tabelas a copiar p / crystal
	xObj.CopyTables("vtmp_producao_os_01_tarefas")    && Filha 1
	xObj.CopyTables("vtmp_producao_os_01_materiais")  && Filha 2
	xObj.CopyTables("v_produtos_tamanho_00")          &&
	xObj.CopyTables("cur_fotos")

	Return .T.
	*---------------------------------------------------------------------------------------------------------------------------------------------------*

Procedure fu_Add_Mat_Faltantes

	*--- Adicionar materiais faltantes (30-11-2004:> provisório até Szalontai arrumar a funcao f_gera_cursor_ft)
	Select v_producao_os_01_materiais
	xFilter=Filter()
	Select v_producao_os_01
	Index On ordem_servico Tag iOS

	Select vtmp_producao_os_01_tarefas
	Go Top
	Scan
		f_select('select ?vTMP_producao_os_01_tarefas.ordem_servico ordem_servico,c.fase_producao,c.setor_producao,'+;
			'		 b.*,a.c1,c.desc_material,d.desc_cor_material '+;
			'  from Produtos_ficha a '+;
			'join Produtos_ficha_cor b on a.produto=b.produto and a.material=b.material and a.item=b.item '+;
			'  join materiais c on a.material=c.material '+;
			'  join materiais_cores d on a.material=d.material and b.cor_material=d.cor_material '+;
			' where a.produto=?vTMP_producao_os_01_tarefas.produto '+;
			'   and b.cor_produto=?vTMP_producao_os_01_tarefas.cor_produto '+;
			'   and reserva_material_op=0 and a.c1>0','cur_FT')

		Select cur_FT
		If !Empty(xFilter)
			Set Relation To ordem_servico Into v_producao_os_01
			Set Filter To &xFilter
		Endif
		Go Top

		Scan
			Select vTmp_producao_os_01_materiais

			Locate For ordem_servico=vtmp_producao_os_01_tarefas.ordem_servico ;
				AND produto=cur_FT.produto And cor_produto=cur_FT.cor_produto And material=cur_FT.material And cor_material=cur_FT.cor_material

			If Eof()
				Append Blank
				Replace produto 	   	  With cur_FT.produto,;
					cor_produto  	  With cur_FT.cor_produto,;
					material 	   	  With cur_FT.material,;
					cor_material 	  With cur_FT.cor_material,;
					item 			  With cur_FT.Item,;
					desc_material 	  With cur_FT.desc_material,;
					desc_cor_material With cur_FT.desc_cor_material,;
					qtde_necessaria   With vtmp_producao_os_01_tarefas.qtde_o * cur_FT.c1,;
					ordem_servico     With vtmp_producao_os_01_tarefas.ordem_servico,;
					ordem_producao 	  With vtmp_producao_os_01_tarefas.ordem_producao
			Endif

			Select cur_FT
		Endscan

		Select vtmp_producao_os_01_tarefas
	Endscan
	*---

Endproc
*---------------------------------------------------------------------------------------------------------------------------------------------------*

Procedure fu_Hab_Page

	*- #1# - xSetCalc = 'o_'+ALLTRIM(substr(wcontrole, 3, len(wcontrole)))+'.Px_Calc_Mat = .t.'
	xSetCalc = 'o_'+Alltrim(Substr(wcontrole, 3, 6))+'.Px_Calc_Mat = .t.'
	If Type(xSetCalc)='L'
		&xSetCalc
		*- #1# - xActPage = 'o_'+ALLTRIM(substr(wcontrole, 3, len(wcontrole)))+'.Lx_form1.Lx_pageframe1.Page6.activate()'
		xActPage = 'o_'+Alltrim(Substr(wcontrole, 3, 6))+'.Lx_form1.Lx_pageframe1.Page6.activate()'
		&xActPage
	Endif
Endproc
*---------------------------------------------------------------------------------------------------------------------------------------------------*
