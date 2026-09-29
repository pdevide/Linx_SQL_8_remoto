procedure func_Relatorio
lparameter xtipo,xObj

if UPPER(xtipo)='PRE' or UPPER(xtipo)='IMP'

	f_popula_filha('v_users_00','v_users_00_modulos')
	f_popula_filha('v_users_00','v_users_00_transacoes')
	f_popula_filha('v_users_00','v_users_00_cubos')
	f_popula_filha('v_users_00','v_users_00_parametros')
	f_popula_filha('v_users_00','v_users_00_parametros_empresa')
	
	xObj.CopyTables('vTmp_users_00_modulos','v_users_00_modulos')
	xObj.CopyTables('vTmp_users_00_transacoes','v_users_00_transacoes')
	xObj.CopyTables('vTmp_users_00_cubos','v_users_00_cubos')
	xObj.CopyTables('vTmp_users_00_parametros','v_users_00_parametros')
	xObj.CopyTables('vTmp_users_00_parametros_empresa','v_users_00_parametros_empresa')

endif

Return .t.
