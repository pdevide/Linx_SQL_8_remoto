******************************************************************************************************************************************************************************************
** Documentação das alterações realizadas no PRG. Deixe sempre a última alteração no começo 
** do PRG, colocando a data, o nome e a alteração feita.
******************************************************************************************************************************************************************************************
** 19/05/2025 - DARIO SILVA - ENTERMODA-22752   - 1.25.040  - #3# - Ajuste relatórios tela 008425
** 03/10/2024 - VALMIR SOARES - LINXERP-19616   - SPK 2.24 (9.0.0) - #2# - Tratamento para relatórios de classe
** Alteração na procedure fu_Hab_Page no momento em que as strings xSetCalc e xActPage são populadas. Quando o parametro global wcontrole era utilizado,
** estava sendo considerado as tres ultimas letras caso a tela fosse exclusiva, desta forma o objeto o_008125 não era encontrado. Foi fixado para pegar somente
** os seis caracteres referentes ao nome da tela.
******************************************************************************************************************************************************************************************

procedure Func_Relatorio
lParameter xtipo,xObj

Return ( Fx_Init_008100(xtipo,xObj) )
*---------------------------------------------------------------------------------------------------------------------------------------------------*

FUNCTION Fx_Init_008100
lParameter xtipo,xObj


	IF !USED('v_producao_os_01_tarefas')
		f_Msg(['Não há informações válidas para este report...',48,'<Aviso>'])
		RETURN .f.
	ENDIF
	
		If Not "L002006" $ UPPER(Set("Procedure"))
			Set Proc to ..\Report.prg\L002006.prg Additive
		EndIf 

	CREATE CURSOR cur_fotos (produto c(12), path_foto c(70),Foto g, colecao c(25), griffe c(25), desc_composicao c(100) )
	xInfoAn  = IIF(USED('v_producao_os_02_materiais'),f_Msg(['Deseja Obter Informações Analíticos?',36,'Dados de Origem Para Materiais'])=6,.t.)

	*-- #3#
	*-- #2#
	If xInfoAn
		If !Used('v_producao_os_02_materiais')
			If wcontrole != "LX008425"
				f_Msg(['Não há informações válidas para este report...',48,'<Aviso>'])
				Return .F.
			Endif
		Endif
	Else
		If !Used('v_producao_os_01_materiais')
			If wcontrole != "LX008425"
				f_Msg(['Não há informações válidas para este report...',48,'<Aviso>'])
				Return .F.
			Endif
		Endif
	Endif
	*-- #2#
	*-- #3#
	
	f_popula_filha('v_producao_os_01',IIF(xInfoAn,'v_producao_os_01_materiais','v_producao_os_02_materiais'),'vtmp_producao_os_01_materiais',,,'replace ordem_servico with v_producao_os_01.ordem_servico',,'fu_Hab_Page()',.t.)
	f_popula_filha('v_producao_os_01','v_producao_os_01_tarefas')

	IF xInfoAn
		fu_Add_Mat_Faltantes()
	ENDIF
	
	SELECT DISTINCT produto FROM vtmp_producao_os_01_tarefas INTO CURSOR tmp_prod_lista
	sele tmp_prod_lista
	GO top
	SCAN
		*f_select('select a.path_foto,b.griffe,c.desc_colecao as colecao from produtos_foto a,produtos b, colecoes c where a.produto=b.produto and c.colecao=b.colecao and a.produto=?tmp_prod_lista.produto','tmp_fotos',ALIAS())
		f_select('select path_foto from produtos_foto where produto=?tmp_prod_lista.produto','tmp_fotos',ALIAS())
		f_select('select a.griffe,b.desc_colecao from produtos a join colecoes b on a.colecao=b.colecao where a.produto=?tmp_prod_lista.produto','tmp_griffe_colecao',ALIAS())
		f_select('select b.desc_composicao from produtos a join materiais_composicao b on a.composicao=b.composicao where a.produto=?tmp_prod_lista.produto','tmp_composicao',ALIAS())
		SELECT cur_fotos
		APPEND BLANK
		Replace produto         WITH tmp_prod_lista.produto,;
				path_foto       WITH tmp_fotos.path_foto,;
				colecao         WITH tmp_griffe_colecao.desc_colecao,;
				griffe          WITH tmp_griffe_colecao.griffe,;
				desc_composicao WITH tmp_composicao.desc_composicao
		xfoto = tmp_fotos.path_foto
		if !isnull(xfoto) and file(xfoto)
			xFotoBmp = PxGDI_SaveImg_AsBMP(ALLTRIM(xFoto))
			Append General foto from (xFotoBmp)
		endif
		sele tmp_prod_lista	
	ENDSCAN

	*--- Tabelas a copiar p / crystal
	xObj.CopyTables("vtmp_producao_os_01_tarefas")    && Filha 1
	xObj.CopyTables("vtmp_producao_os_01_materiais")  && Filha 2
	xObj.CopyTables("v_produtos_tamanho_00")          && 
	xObj.CopyTables("cur_fotos")

Return .t.
*---------------------------------------------------------------------------------------------------------------------------------------------------*

PROCEDURE fu_Add_Mat_Faltantes

	*--- Adicionar materiais faltantes (30-11-2004:> provisório até Szalontai arrumar a funcao f_gera_cursor_ft)
	SELECT v_producao_os_01_materiais
	xFilter=FILTER()
	SELECT v_producao_os_01
	INDEX ON ordem_servico TAG iOS
	
		SELECT vTMP_producao_os_01_tarefas
		GO top
		SCAN
			f_select('select ?vTMP_producao_os_01_tarefas.ordem_servico ordem_servico,c.fase_producao,c.setor_producao,'+;
					 '		 b.*,a.c1,c.desc_material,d.desc_cor_material '+;
					 '  from Produtos_ficha a '+;
					 'join Produtos_ficha_cor b on a.produto=b.produto and a.material=b.material and a.item=b.item '+;
					 '  join materiais c on a.material=c.material '+;
					 '  join materiais_cores d on a.material=d.material and b.cor_material=d.cor_material '+;
					 ' where a.produto=?vTMP_producao_os_01_tarefas.produto '+;
					 '   and b.cor_produto=?vTMP_producao_os_01_tarefas.cor_produto '+;
					 '   and reserva_material_op=0 and a.c1>0','cur_FT')
	 		
	 		SELECT cur_FT
			IF !EMPTY(xFilter)
				SET RELATION TO ordem_servico INTO v_producao_os_01
				SET FILTER TO &xFilter
			ENDIF
			GO top

			SCAN
				SELECT vTmp_producao_os_01_materiais

				LOCATE FOR ordem_Servico=vTMP_producao_os_01_tarefas.ordem_Servico ;
				   AND produto=cur_FT.produto AND cor_produto=cur_FT.cor_produto AND material=cur_FT.material AND cor_material=cur_FT.cor_material
	
				IF EOF()
					APPEND BLANK
					REPLACE produto 	   	  WITH cur_FT.produto,;
							cor_produto  	  WITH cur_FT.cor_produto,;
							material 	   	  WITH cur_FT.material,;
							cor_material 	  WITH cur_FT.cor_material,;
							item 			  WITH cur_FT.item,;
							desc_material 	  WITH cur_FT.desc_material,;
							desc_cor_material WITH cur_FT.desc_cor_material,;
							qtde_necessaria   WITH vTMP_producao_os_01_tarefas.qtde_o * cur_FT.c1,;
							ordem_servico     WITH vTMP_producao_os_01_tarefas.ordem_servico,;
							ordem_producao 	  WITH vTMP_producao_os_01_tarefas.ordem_producao
				ENDIF

		 		SELECT cur_FT
			ENDSCAN

			SELECT vTMP_producao_os_01_tarefas
		ENDSCAN
	*---

ENDPROC
*---------------------------------------------------------------------------------------------------------------------------------------------------*

PROCEDURE fu_Hab_Page

*- #1# - xSetCalc = 'o_'+ALLTRIM(substr(wcontrole, 3, len(wcontrole)))+'.Px_Calc_Mat = .t.' 
	xSetCalc = 'o_'+ALLTRIM(substr(wcontrole, 3, 6))+'.Px_Calc_Mat = .t.'
	IF TYPE(xSetCalc)='L'
		&xSetCalc
*- #1# - xActPage = 'o_'+ALLTRIM(substr(wcontrole, 3, len(wcontrole)))+'.Lx_form1.Lx_pageframe1.Page6.activate()'
		xActPage = 'o_'+ALLTRIM(substr(wcontrole, 3, 6))+'.Lx_form1.Lx_pageframe1.Page6.activate()'
		&xActPage
	ENDIF
ENDPROC
*---------------------------------------------------------------------------------------------------------------------------------------------------*
