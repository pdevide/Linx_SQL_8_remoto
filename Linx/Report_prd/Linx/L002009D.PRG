procedure func_Relatorio
lparameter xtipo,xObj
if UPPER(xtipo)='PRE' or UPPER(xtipo)='IMP'

	xFilFase = ''
	IF ( MessageBox('Deseja Filtrar uma Fase?',36,'Atenção')=6 )
		System.ExecuteFormModal('lxoprel_fases')
		xFilFase = ALLTRIM(_opFase)
	ENDIF

	SELE v_produtos_tab_operacoes_00_operacoes
	o_002009.lx_calcula_tempos

	*--- Dados
	if MessageBox('Deseja Processar Operações?',36,'Atenção')=6
		f_popula_filha('v_produtos_tab_operacoes_00','v_produtos_tab_operacoes_00_operacoes',,,,,,'o_002009.lx_form1.lx_pageframe1.page4.activate()')
	else
		f_popula_filha('v_produtos_tab_operacoes_00','v_produtos_tab_operacoes_00_operacoes',,,,,,'o_002009.lx_form1.lx_pageframe1.page1.activate()')
	endif

	*--- Resumo
	SELECT DISTINCT tabela_operacoes,maquina,desc_maquina, SUM(tempo_cronometrado) AS tempo_cronometrado, SUM(tempo_calculado) AS tempo_calculado, SUM(porcentagem) AS porcentagem, SUM(operadoras) AS operadoras_maquina ;
	  FROM vtmp_produtos_tab_operacoes_00_operacoes WHERE IIF( EMPTY(xFilFase),.t.,fase_producao=xFilFase ) ;
	 GROUP BY tabela_operacoes,maquina,desc_maquina into cursor vtmp_produtos_tab_operacoes_00_resumo

	sele vtmp_produtos_tab_operacoes_00_operacoes
	index on tabela_operacoes + operacao tag iTbOper FOR IIF( EMPTY(xFilFase),.t.,fase_producao=xFilFase )

	IF !EMPTY(xFilFase) && Recalculo tempos
		sele v_produtos_tab_operacoes_00
		GO top
		SCAN
			SELECT SUM(tempo_cronometrado) AS tempo_cronometrado,;
				   SUM(tempo_cronometrado_2) AS tempo_cronometrado_2,;
				   SUM(tempo_cronometrado_3) AS tempo_cronometrado_3,;
		   	   	   SUM(tempo_cronometrado_4) AS tempo_cronometrado_4 ;
		   	  FROM vtmp_produtos_tab_operacoes_00_operacoes WHERE tabela_operacoes=?v_produtos_tab_operacoes_00.tabela_operacoes AND IIF( EMPTY(xFilFase),.t.,fase_producao=xFilFase ) ;
		   	  into cursor cur_calculos

			sele v_produtos_tab_operacoes_00
			Replace Tempo_Total      with cur_calculos.tempo_cronometrado, ;
			        Tempo_Total_2    With cur_calculos.tempo_cronometrado_2, ;
			        Tempo_Total_3    With cur_calculos.tempo_cronometrado_3, ;
			        Tempo_Total_4    With cur_calculos.tempo_cronometrado_4
		ENDSCAN
	endif

	*--- copiar
	xObj.CopyTables("v_produtos_tab_operacoes_00")
	xObj.CopyTables("vtmp_produtos_tab_operacoes_00_operacoes")
	xObj.CopyTables("vtmp_produtos_tab_operacoes_00_resumo")
ENDIF

Return .t.
*------------------------------------------------------------------------------------------------------------------------*
