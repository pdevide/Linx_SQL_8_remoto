procedure func_Relatorio
lparameter xtipo,xObj

if UPPER(xtipo)='PRE' or UPPER(xtipo)='IMP'
	*---- Substituir Tab.Pai (para copia)
		if reccount("v_loja_resumo_operacoes_03") = 0
		Requery("v_loja_resumo_operacoes_03")
	endif
	xObj.MainAlias =  'v_loja_resumo_operacoes_03'
endif

Return .t.
**-------------------------------------------------------------------------------------------------------------------------**
