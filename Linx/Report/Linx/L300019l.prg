procedure func_Relatorio
lparameter xtipo,xObj

if UPPER(xtipo)='PRE' or UPPER(xtipo)='IMP'
	*---- Substituir Tab.Pai (para copia)
	xObj.MainAlias =  'v_loja_resumo_operacao_01'
endif

Return .t.
**-------------------------------------------------------------------------------------------------------------------------**
