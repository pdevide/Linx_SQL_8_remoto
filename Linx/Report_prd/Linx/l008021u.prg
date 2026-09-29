procedure func_Relatorio
lparameter xtipo,xObj
** 21/11/2022 - Juliana Nascimento - PRODSHOP-16246 - #3# - Ajuste no consumo

if UPPER(xtipo)='PRE' or UPPER(xtipo)='IMP'

	If Not "L002006" $ UPPER(Set("Procedure"))
		Set Proc to ..\Report.prg\L002006.prg Additive
	EndIf 

	*--- Cores
	f_popula_filha('v_producao_ordem_01','v_producao_ordem_01_cores',,,'space(LEN(v_producao_ordem_01.grade)) as grade','replace grade with v_producao_ordem_01.grade')

	*--- Tarefas
	SELECT v_producao_ordem_01_tarefas
	=TABLEREVERT(.t.)
	f_popula_filha('v_producao_ordem_01','v_producao_ordem_01_tarefas',,,;
				   'space(LEN(v_producao_ordem_01.produto)) as produto',;
				   'replace produto with v_producao_ordem_01.produto')

	*--- Materiais
	xNFields =  'space(12) as produto,SPACE(25) as grade,space(40) as desc_uso_material,space(40) as parte_aplicado_material,0000000 as qtde_total,.f. as material_principal,.f. as consumo_p_tamanho,space(12) as ref_fabricante,'+;
				'000000000.00000 as c1 ,000000000.00000 as c2 ,000000000.00000 as c3 ,000000000.00000 as c4 ,000000000.00000 as c5 ,000000000.00000 as c6 ,000000000.00000 as c7 ,000000000.00000 as c8 ,000000000.00000 as c9 ,000000000.00000 as c10,'+;
				'000000000.00000 as c11,000000000.00000 as c12,000000000.00000 as c13,000000000.00000 as c14,000000000.00000 as c15,000000000.00000 as c16,000000000.00000 as c17,000000000.00000 as c18,000000000.00000 as c19,000000000.00000 as c20,'+;
				'000000000.00000 as c21,000000000.00000 as c22,000000000.00000 as c23,000000000.00000 as c24,000000000.00000 as c25,000000000.00000 as c26,000000000.00000 as c27,000000000.00000 as c28,000000000.00000 as c29,000000000.00000 as c30,'+;
				'000000000.00000 as c31,000000000.00000 as c32,000000000.00000 as c33,000000000.00000 as c34,000000000.00000 as c35,000000000.00000 as c36,000000000.00000 as c37,000000000.00000 as c38,000000000.00000 as c39,000000000.00000 as c40,'+;
				'000000000.00000 as c41,000000000.00000 as c42,000000000.00000 as c43,000000000.00000 as c44,000000000.00000 as c45,000000000.00000 as c46,000000000.00000 as c47,000000000.00000 as c48'
	f_popula_filha('v_producao_ordem_01','v_producao_ordem_01_materiais',,,xNFields,'replace produto with v_producao_ordem_01.produto,grade with v_producao_ordem_01.grade,qtde_total with v_producao_ordem_01.qtde_total',,'Lx_Recalc_Materiais()',.t.)

	sele vtmp_producao_ordem_01_materiais
	go top
	SCAN
		SELECT v_produtos_tamanho_00
		LOCATE FOR grade=vtmp_producao_ordem_01_materiais.grade

		SELECT DISTINCT cor_produto FROM vTMP_producao_ordem_01_cores ;
		 where ordem_producao=?vtmp_producao_ordem_01_materiais.ordem_producao and produto=?vtmp_producao_ordem_01_materiais.produto INTO CURSOR Cur_Lista_Cores_Prod_OP
		SELECT Cur_Lista_Cores_Prod_OP
		xStrCoresOp = ''
		SCAN
			xStrCoresOp = xStrCoresOp + IIF(EMPTY(xStrCoresOp),'',',') + "'" + ALLTRIM(cor_produto) + "'"
		ENDSCAN

		f_select("select a.*,b.ref_fabricante,c.cor_produto,c.cor_material,c.porcentagem_consumo "+;
				 "  from produtos_ficha a join materiais b on a.material=b.material "+;
		 		 "  join produtos_ficha_cor c on a.produto=c.produto and a.material=c.material and a.item=c.item "+;
		 		 " where a.produto=?vtmp_producao_ordem_01_materiais.produto "+;
		 		 "   and a.material=?vtmp_producao_ordem_01_materiais.material "+;
		 		 "   and c.cor_material=?vtmp_producao_ordem_01_materiais.cor_material "+;
		 		 "   and cor_produto in ("+xStrCoresOp+")","cur_FT")

		sele vtmp_producao_ordem_01_materiais
		replace desc_uso_material  		with NVL(cur_FT.desc_uso_material,''),;
				parte_aplicado_material with NVL(cur_FT.parte_aplicado_material,''),;  
				material_principal 		with NVL(cur_FT.material_principal,''),;
				consumo_p_tamanho  		with cur_FT.consumo_p_tamanho,;
				ref_fabricante     		with NVL(cur_FT.ref_fabricante,'')

		*/
		FOR k = 1 TO v_produtos_tamanho_00.numero_tamanhos 
			k_ = ALLTRIM(STR(k))
			IF !EMPTY(v_produtos_tamanho_00.tamanho_&k_)
				SELECT cur_FT
				xAc_Perc = 0
				SCAN
					Replace vtmp_producao_ordem_01_materiais.c&k_  with vtmp_producao_ordem_01_materiais.c&k_ + ;
							(cur_FT.c&k_ * (cur_FT.porcentagem_consumo * 0.01))
					xAc_Perc = xAc_Perc + cur_FT.porcentagem_consumo
					**#1#
*!*						IF  xAc_Perc>=100
*!*							EXIT
*!*						ENDIF
					**#1#
				ENDSCAN
			ENDIF
		ENDFOR
		*/

	ENDSCAN

	*--- Obs do Produto
	SELECT DISTINCT produto,SPACE(250) as obs_produto from v_producao_ordem_01 INTO CURSOR cur_obs_produtos readwrite
	SELECT cur_obs_produtos
	GO top
	SCAN
		f_select('select obs from produtos where produto=?cur_obs_produtos.produto','cur_produtos',ALIAS())
		replace obs_produto WITH NVL(cur_produtos.obs,'')
	ENDSCAN
	*---
	
	*--- Fotos da Instrução de lavagem
	=Add_Fotos_Instr_Lavagem()
	xObj.CopyTables('cur_fotos_produto')

	xObj.CopyTables('v_produtos_tamanho_00')
	xObj.CopyTables('v_produtos_tamanho_00','v_produtos_tamanho_00_b')

	xObj.CopyTables('vtmp_producao_ordem_01_cores','v_producao_ordem_01_cores')
	xObj.CopyTables('vtmp_producao_ordem_01_tarefas')
	xObj.CopyTables('vtmp_producao_ordem_01_materiais')
	xObj.CopyTables('cur_obs_produtos')

	sele * from vtmp_producao_ordem_01_materiais into cursor vtmp_producao_ordem_01_materiais_consumo_tam where consumo_p_tamanho
	xObj.CopyTables('vtmp_producao_ordem_01_materiais_consumo_tam')
endif

Return .t.
*---------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------*
PROCEDURE Add_Fotos_Instr_Lavagem

	CREATE CURSOR cur_stru ( field_general g(4),field_memo m(4) )
	SELECT a.produto,SPACE(6) restricao_lavagem,;
		   b.field_general foto_produto , b.field_memo obs_foto_produto , SPACE(50) legenda_foto_produto , SPACE(100) path_foto_produto,;
		   b.field_general foto_lavagem1, b.field_memo obs_foto_lavagem1, SPACE(50) legenda_foto_lavagem1, SPACE(100) path_foto_lavagem1,;
		   b.field_general foto_lavagem2, b.field_memo obs_foto_lavagem2, SPACE(50) legenda_foto_lavagem2, SPACE(100) path_foto_lavagem2,;
		   b.field_general foto_lavagem3, b.field_memo obs_foto_lavagem3, SPACE(50) legenda_foto_lavagem3, SPACE(100) path_foto_lavagem3,;
		   b.field_general foto_lavagem4, b.field_memo obs_foto_lavagem4, SPACE(50) legenda_foto_lavagem4, SPACE(100) path_foto_lavagem4,;
		   b.field_general foto_lavagem5, b.field_memo obs_foto_lavagem5, SPACE(50) legenda_foto_lavagem5, SPACE(100) path_foto_lavagem5,;
		   b.field_general foto_lavagem6, b.field_memo obs_foto_lavagem6, SPACE(50) legenda_foto_lavagem6, SPACE(100) path_foto_lavagem6,;
		   b.field_general foto_lavagem7, b.field_memo obs_foto_lavagem7, SPACE(50) legenda_foto_lavagem7, SPACE(100) path_foto_lavagem7,;
		   b.field_general foto_lavagem8, b.field_memo obs_foto_lavagem8, SPACE(50) legenda_foto_lavagem8, SPACE(100) path_foto_lavagem8,;
		   b.field_general foto_lavagem9, b.field_memo obs_foto_lavagem9, SPACE(50) legenda_foto_lavagem9, SPACE(100) path_foto_lavagem9,;
		   b.field_general foto_lavagem10,b.field_memo obs_foto_lavagem10,SPACE(50) legenda_foto_lavagem10,SPACE(100) path_foto_lavagem10,;
		   b.field_general foto_lavagem11,b.field_memo obs_foto_lavagem11,SPACE(50) legenda_foto_lavagem11,SPACE(100) path_foto_lavagem11,;
		   b.field_general foto_lavagem12,b.field_memo obs_foto_lavagem12,SPACE(50) legenda_foto_lavagem12,SPACE(100) path_foto_lavagem12 ;
	  FROM v_producao_ordem_01 a LEFT join cur_stru b ON .t. INTO CURSOR cur_fotos_produto ReadWrite

	SELECT cur_fotos_produto
	GO top
	SCAN

		f_select('select numero_foto,obs,legenda,path_foto from produtos_foto where produto=?cur_fotos_produto.produto','cur_fotos',ALIAS())
		xFoto = cur_fotos.path_foto
		IF FILE(xFoto)
			xFotoBmp = PxGDI_SaveImg_AsBMP(ALLTRIM(xFoto))

			APPEND GENERAL foto_produto FROM (xFotoBmp)
			REPLACE obs_foto_produto 	 WITH NVL(cur_fotos.obs,''),;
					legenda_foto_produto WITH cur_fotos.legenda,;
					path_foto_produto 	 WITH cur_fotos.path_foto
		ENDIF
	
		f_select("Select b.produto,a.* from Materiais_tipo_lavagem_foto a join Produtos b "+;
		      	 "    on a.restricao_lavagem=b.restricao_lavagem where b.produto=?cur_fotos_produto.produto order by a.numero_foto",'cur_restr_lav')

		GO top
		xNum = 0
		SCAN WHILE xNum<=12
			xFoto = path_foto
			IF FILE(xFoto)

				xNum  = xNum+1
				IF xNum>12
					LOOP
				ENDIF
				xNum_ = ALLTRIM(STR(xNum))
				
				SELECT cur_fotos_produto
				xFotoBmp = PxGDI_SaveImg_AsBMP(ALLTRIM(xFoto))
				APPEND GENERAL Foto_lavagem&xNum_ FROM (xFotoBmp)
				REPLACE obs_foto_lavagem&xNum_ 	   with NVL(cur_restr_lav.obs,''),;
						legenda_foto_lavagem&xNum_ with cur_restr_lav.legenda_foto,;
						path_foto_lavagem&xNum_    with cur_restr_lav.path_foto

				SELECT cur_restr_lav
			ENDIF
		ENDSCAN

		SELECT cur_fotos_produto
	ENDSCAN

Return .t.
*---------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------*
PROCEDURE Lx_Recalc_Materiais

	o_008021.lx_form1.lx_pageframe1.page3.Activate()
	o_008021.lx_form1.lx_pageframe1.page3.lX_PAGEFRAME1.page1.botao2.Click()

Return .t.
*---------------------------------------------------------------------------------------------------------------------*
