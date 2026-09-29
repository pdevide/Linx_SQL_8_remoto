procedure func_Relatorio
lparameter xtipo,xObj

if UPPER(xtipo)='PRE' or UPPER(xtipo)='IMP'
	*---- Substituir Tab.Pai (para copia)
	xObj.MainAlias =  'v_producao_recurso_creditos_01_data_recurso'
endif

Return .t.
**-------------------------------------------------------------------------------------------------------------------------**
