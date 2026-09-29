Procedure Func_Relatorio
lparameter xtipo,xObj

if UPPER(xtipo)='PRE' or UPPER(xtipo)='IMP'
	=Ger_Tmp_Structure()
	=Ger_Tmp_Dados()
	=Ger_Tmp_Resumo()
	xObj.CopyTables("vtmp_producao_corte_00_encaixe")
	xObj.CopyTables("vtmp_producao_corte_00_grade")
	xObj.CopyTables("vtmp_producao_corte_00_enfesto")
	xObj.CopyTables("vtmp_producao_corte_00_peca")
	xObj.CopyTables("v_produtos_tamanho_00")
	xObj.CopyTables("vtmp_oc_resumo")
ENDIF
*--------------------------------------------------------------------------------------------------------------------*




*--------------------------------------------------------------------------------------------------------------------*
Procedure Ger_Tmp_Structure

*--- Tabelas Usadas na Tela
sele v_producao_corte_00
cursorset('buffering',3)

sele v_producao_corte_00_encaixe 
tablerevert(.t.)
cursorset('buffering',3)

sele v_producao_corte_00_grade
tablerevert(.t.)
cursorset('buffering',3)

sele v_producao_corte_00_enfesto
tablerevert(.t.)
cursorset('buffering',3)
cursorset('sendupdate',.f.)

sele v_producao_corte_00_peca
tablerevert(.t.)
cursorset('buffering',3)

*--- Geração dos Cursores RW Para o Report
Select * from v_producao_corte_00_encaixe INTO CURSOR vtmp_producao_corte_00_encaixe where .f. readwrite
Select * from v_producao_corte_00_grade   INTO CURSOR vtmp_producao_corte_00_grade   where .f. readwrite
Select *,produto as cortar_na_folha_produto,SPACE(20) as desc_enfesto FROM v_producao_corte_00_enfesto INTO CURSOR vtmp_producao_corte_00_enfesto WHERE .f. readwrite
Select *,SPACE(25) as ult_fornecedor,SPACE(12) as ult_nf_entrada,{} as ult_data_nf_entrada,0000000.00 as ult_valor,SPACE(25) as desc_material, SPACE(25) as desc_cor_material FROM v_producao_corte_00_peca INTO CURSOR vtmp_producao_corte_00_peca WHERE .f. readwrite
*--------------------------------------------------------------------------------------------------------------------*




*--------------------------------------------------------------------------------------------------------------------*
Procedure Ger_Tmp_Dados

sele v_producao_corte_00
count   to xTotReg
store 0 to xItmReg
go top
scan
	xItmReg = xItmReg + 1
	f_prog_bar('Aguarde...',xItmReg,xTotReg)

	sele v_producao_corte_00_encaixe 
	requery()
	scan
		RELEASE memvar
		scatter to memvar
		sele vtmp_producao_corte_00_encaixe
		appe blank
		gather from memvar

		sele v_producao_corte_00_grade
		requery()
		SCAN
			o_008037.Lx_form1.Lx_pageframe1.Page2.Lx_pageframe1.Page1.Lx_grid_filha1.afterrowcolchange
			RELEASE memvar
			scatter memvar
			sele vtmp_producao_corte_00_grade
			appe blank
			gather memvar

			sele v_producao_corte_00_enfesto
			requery()
			o_008037.Lx_form1.Lx_pageframe1.Page2.lx_grid_filha1.afterrowcolchange
			sele v_producao_corte_00_enfesto
			go top
			if eof()
				SELE vtmp_producao_corte_00_enfesto
				APPEND BLANK
				Replace ordem_corte  			WITH v_producao_corte_00_grade.ordem_corte,;
						encaixe      			WITH v_producao_corte_00_grade.encaixe,;
						desc_enfesto 			WITH IIF(v_producao_corte_00_encaixe.enfesto_normal_tubular_meia=1,'NORMAL',IIF(v_producao_corte_00_encaixe.enfesto_normal_tubular_meia=2,'TUBULAR','MEIA')) ,;
						produto      			WITH v_producao_corte_00_grade.produto,;
						cortar_na_folha_produto WITH v_producao_corte_00_grade.cortar_na_folha_produto
			else
				scan
					RELEASE memvar
					scatter to memvar
					sele vtmp_producao_corte_00_enfesto
					appe blank
					gather from memvar
					replace cortar_na_folha_produto WITH v_producao_corte_00_grade.cortar_na_folha_produto,;
						produto      			WITH v_producao_corte_00_grade.produto,;
						cortar_na_folha_produto WITH v_producao_corte_00_grade.cortar_na_folha_produto,;
							desc_enfesto 			WITH IIF(v_producao_corte_00_encaixe.enfesto_normal_tubular_meia=1,'NORMAL',IIF(v_producao_corte_00_encaixe.enfesto_normal_tubular_meia=2,'TUBULAR','MEIA'))

					sele v_producao_corte_00_peca
					requery()
					GO top
					scan
						RELEASE memvar
						scatter to memvar
						sele vtmp_producao_corte_00_peca
						appe blank
						gather from memvar
						Replace desc_material     WITH v_producao_corte_00_enfesto.desc_material,;
						 		desc_cor_material WITH v_producao_corte_00_enfesto.desc_cor_material

						f_select('select b.nome_clifor,b.nf_entrada,a.emissao,b.custo * ?v_producao_corte_00_peca.qtde_peca as valor, b.custo '+;
								 '  from entradas a, entradas_material b, entradas_mat_peca c '+;
								 ' where a.nf_entrada=b.nf_entrada and a.nf_entrada=c.nf_entrada '+;
								 '   and a.nome_clifor=b.nome_clifor and a.nome_clifor=c.nome_clifor and b.material=c.material and b.cor_material=c.cor_material '+;
								 '   and c.material=?v_producao_corte_00_peca.material and c.cor_material=?v_producao_corte_00_peca.cor_material and c.peca=?v_producao_corte_00_peca.peca and c.partida=?v_producao_corte_00_peca.partida ','cur_ult_entrada',ALIAS())

						IF !EMPTY(cur_ult_entrada.nome_clifor)
							SELE vtmp_producao_corte_00_peca
							replace ult_fornecedor      WITH cur_ult_entrada.nome_clifor,;
									ult_nf_entrada      WITH cur_ult_entrada.nf_entrada,;
									ult_data_nf_entrada WITH cur_ult_entrada.emissao,;
									ult_valor			WITH cur_ult_entrada.valor
						endif

					endscan
				endscan
			endif
			
		endscan
		
	endscan
endscan
*--------------------------------------------------------------------------------------------------------------------*



*--------------------------------------------------------------------------------------------------------------------*
Procedure Ger_Tmp_Resumo

*--- Cursor Resumo
SELECT  ordem_corte,;
		0000000.00 as total_pecas_corte,;
		0000000.00 as valor_nf,;
		0000000.00 as qtde,;
		0000000.00 as total_folhas,;
		0000000.00 as pecas_folhas,;
		0000000.00 as largura_folhas,;
		0000000.00 as comprimento ;
		from v_producao_corte_00 INTO CURSOR vtmp_oc_resumo WHERE .f. readwrite

*--- Calc Totais
SELECT ordem_corte,sum(numero_folhas) as numero_folhas, sum(qtde_material) as qtde_material,sum(qtde_saldo) as qtde_saldo ;
  FROM vtmp_producao_corte_00_enfesto ;
 GROUP BY ordem_corte ;
  INTO CURSOR cur_enfesto_total

*--- Pecas (1)
Select ordem_corte, sum(ult_valor) ult_valor,sum(largura)/count(*) as largura from vtmp_producao_corte_00_peca ;
group by ordem_corte into cursor cur_peca_total1

*--- Pecas (2)
Select Distinct ordem_corte,peca,qtde_peca,numero_folhas,ult_valor FROM vtmp_producao_corte_00_peca ORDER BY  ordem_corte,peca,qtde_peca,numero_folhas,ult_valor  INTO CURSOR cur_dist_pecas
Select ordem_corte, sum(qtde_peca) qtde_peca,sum(numero_folhas) numero_folhas,sum(ult_valor) as ult_valor from cur_dist_pecas group by ordem_corte into cursor cur_peca_total2


SELE cur_enfesto_total
go top
scan
	SELECT vtmp_oc_resumo
	APPEND BLANK
	Replace total_pecas_corte WITH cur_enfesto_total.qtde_saldo,;
			valor_nf          WITH cur_peca_total2.ult_valor,;
			qtde              WITH cur_peca_total2.qtde_peca,;
			total_folhas      WITH cur_peca_total2.numero_folhas,;
			pecas_folhas      WITH iif(cur_peca_total2.numero_folhas=0,0,cur_enfesto_total.qtde_saldo / cur_peca_total2.numero_folhas),;
			largura_folhas    WITH cur_peca_total1.largura,;
			comprimento       WITH iif(isnull(vtmp_producao_corte_00_encaixe.comprimento),0,vtmp_producao_corte_00_encaixe.comprimento)

EndScan
*--------------------------------------------------------------------------------------------------------------------*
















*!*	*--- Calc Totais
*!*	SELECT ordem_corte,encaixe,produto,cortar_na_folha_produto,sum(numero_folhas) as numero_folhas, ;
*!*		   sum(qtde_material) as qtde_material,sum(qtde_saldo) as qtde_saldo ;
*!*	  FROM vtmp_producao_corte_00_enfesto ;
*!*	 GROUP BY ordem_corte,encaixe,produto,cortar_na_folha_produto ;
*!*	  INTO CURSOR vtmp_producao_corte_00_enfesto_total

*!*	sele distinct ordem_corte,encaixe,produto, sum(ult_valor) ult_valor from vtmp_producao_corte_00_peca group by ordem_corte,encaixe,produto into cursor cur_resumo1
*!*	sele cur_resumo1
*!*	index on ordem_corte+encaixe+produto tag iResumo1

*!*	sele distinct ordem_corte,encaixe,produto, sum(largura)/count(*) as largura from vtmp_producao_corte_00_peca group by ordem_corte,encaixe,produto into cursor cur_resumo2
*!*	sele cur_resumo2
*!*	index on ordem_corte+encaixe+produto tag iResumo2

*!*	SELE vtmp_producao_corte_00_enfesto_total
*!*	index on ordem_corte+encaixe+produto+cortar_na_folha_produto tag iEnTotal

*!*	sele vtmp_producao_corte_00_enfesto && Pai
*!*	set relation to ordem_corte+encaixe+produto+cortar_na_folha_produto into vtmp_producao_corte_00_enfesto_total additive
*!*	set relation to ordem_corte+encaixe+produto into cur_enfesto additive
*!*	set relation to ordem_corte+encaixe+produto into cur_resumo1 additive
*!*	set relation to ordem_corte+encaixe+produto into cur_resumo2 additive
*!*	GO top
*!*	*-------------------------------------------------------------------------------------------------------------------*
