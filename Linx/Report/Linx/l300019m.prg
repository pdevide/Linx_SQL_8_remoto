procedure func_Relatorio
lparameter xtipo,xObj

if UPPER(xtipo)='PRE' or UPPER(xtipo)='IMP'
	*---- Substituir Tab.Pai (para copia)
	if reccount("v_loja_resumo_operacoes_02") = 0
		Requery("v_loja_resumo_operacoes_02")
	endif
	xObj.MainAlias =  'v_loja_resumo_operacoes_02'
endif

Return .t.
**-------------------------------------------------------------------------------------------------------------------------**
