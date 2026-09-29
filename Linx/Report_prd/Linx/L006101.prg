Procedure Ini_Semi_Acabado
lParameters xtipo, xObj

if UPPER(xtipo)='PRE' or UPPER(xtipo)='IMP'
	=Ini_tabelas_tmp()
	xObj.CopyTables("vtmp_estoque_sai_mat_00_materiais")
	xObj.CopyTables("vtmp_estoque_sai_mat_00_pecas")
	xObj.CopyTables("vtmp_estoque_sai_mat_00_of_mat")
	xObj.CopyTables("vtmp_materiais_processo_tratamento")
endif

sele v_estoque_sai_mat_00
go top
Return .t.
*---------------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------------*
Procedure Ini_tabelas_tmp && Popula Tabelas ( motivo: existe replaces na tela )

sele v_estoque_sai_mat_00_pecas
=tablerevert(.t.)
set filt to
f_popula_filha('v_estoque_sai_mat_00','v_estoque_sai_mat_00_pecas')

sele v_estoque_sai_mat_00_of_mat
=tablerevert(.t.)
set filt to
f_popula_filha('v_estoque_sai_mat_00','v_estoque_sai_mat_00_of_mat',,,,,,'o_006101.Lx_form1.Lx_pageframe1.Page6.activate()')

sele v_estoque_sai_mat_00_materiais
=tablerevert(.t.)
set filt to

**f_popula_filha('v_estoque_sai_mat_00','v_estoque_sai_mat_00_materiais',,,'space(8) as op_link','replace op_link with iif(isnull(ordem_producao),transf_ordem_producao,ordem_producao)',,'o_006101.Lx_form1.Lx_pageframe1.Page2.activate()')
  f_popula_filha('v_estoque_sai_mat_00','v_estoque_sai_mat_00_materiais',,,,,,'o_006101.Lx_form1.Lx_pageframe1.Page2.activate()')


*--LINXERP-20108
	TEXT to xSelSql NOSHOW 
		SELECT a.SEQUENCIA_PRODUTIVA, a.TRATAMENTO, b.DESC_TRATAMENTO, a.MAQUINA, c.DESC_MAQUINA, a.CUSTO_SERVICO_PREVISTO, a.CUSTO_MATERIAL_TERCEIRO_PREVISTO, a.PROCESSO_PRODUTIVO
		  FROM MATERIAIS_PROCESSO_TRATAMENTO a 
		 INNER JOIN MATERIAIS_TRATAMENTO     b ON a.TRATAMENTO=b.TRATAMENTO 
		 INNER JOIN MATERIAIS_MAQUINA        c ON a.MAQUINA=c.MAQUINA
		 WHERE a.PROCESSO_PRODUTIVO=?CurLst_pp.processo_produtivo  
	ENDTEXT 

	IF USED('vtmp_materiais_processo_tratamento')
		SELECT vtmp_materiais_processo_tratamento
		USE 
	ENDIF

	SELECT distinct processo_produtivo FROM vTmp_estoque_sai_mat_00_of_mat INTO CURSOR CurLst_pp 
	SELECT CurLst_pp 
	SCAN
		f_select(xSelSql,'CurTmp_MPT')
		IF USED('vtmp_materiais_processo_tratamento')
			INSERT INTO vtmp_materiais_processo_tratamento SELECT * FROM CurTmp_MPT
		ELSE 
			select * from CurTmp_MPT into cursor vtmp_materiais_processo_tratamento READWRITE
		ENDIF
	ENDSCAN
*--LINXERP-20108


Return .t.
*---------------------------------------------------------------------------------------------------------------------------*
