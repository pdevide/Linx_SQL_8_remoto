procedure func_Relatorio
lparameter xtipo,xObj

if UPPER(xtipo)='PRE' or UPPER(xtipo)='IMP'

	IF !USED('v_producao_os_01_tarefas')
		f_Msg(['Não há informações válidas para este report...',48,'<Aviso>'])
		RETURN .f.
	ENDIF
	
		If Not "L002006" $ UPPER(Set("Procedure"))
			Set Proc to ..\Report.prg\L002006.prg Additive
		EndIf 

	CREATE CURSOR cur_fotos (produto c(12), path_foto c(70),Foto g, colecao c(25), griffe c(25))
	f_popula_filha('v_producao_os_01','v_producao_os_01_tarefas')
	f_popula_filha('v_producao_os_01','v_producao_os_01_materiais')

	SELECT DISTINCT produto FROM vtmp_producao_os_01_tarefas INTO CURSOR tmp_prod_lista
	sele tmp_prod_lista
	GO top
	SCAN
		f_select('select a.path_foto,b.griffe,c.desc_colecao as colecao from produtos_foto a,produtos b, colecoes c where a.produto=b.produto and c.colecao=b.colecao and a.produto=?tmp_prod_lista.produto','tmp_fotos',ALIAS())		
		SELECT cur_fotos
		APPEND BLANK
		Replace produto   WITH tmp_prod_lista.produto,;
				path_foto WITH tmp_fotos.path_foto,;
				colecao   WITH tmp_fotos.colecao,;
				griffe    WITH tmp_fotos.griffe 
		xfoto = tmp_fotos.path_foto
		if !isnull(xfoto) and file(xfoto)
			xFotoBmp = PxGDI_SaveImg_AsBMP(ALLTRIM(xFoto))
			APPEND GENERAL Foto FROM (xFotoBmp)
		endif
		sele tmp_prod_lista	
	ENDSCAN

	*--- Tabelas a copiar p / crystal
	xObj.CopyTables("vtmp_producao_os_01_tarefas")    && Filha 1
	xObj.CopyTables("vtmp_producao_os_01_materiais")  && Filha 2
	xObj.CopyTables("v_produtos_tamanho_00")          && 
	xObj.CopyTables("cur_fotos")
ENDIF

Return .t.
*------------------------------------------------------------------------------------------------------------------------*

