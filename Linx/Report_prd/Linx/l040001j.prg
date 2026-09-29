procedure func_Relatorio
lparameter xtipo,xObj

if UPPER(xtipo)='PRE' or UPPER(xtipo)='IMP'

	x__Proc = set('proce')
	set proc to report.prg\L040001.prg addi

	xTCores = ! ( f_msg(['Deseja Eliminar Cores Repetidas?',36,'Atenção!!!']) )=6

	=Gerar_Comb_Cores(xTCores)

	xObj.MainAlias =  'vtmp_produtos_ficha_01_cor' && Substituir Tab.Pai (para copia)
	set proce to &x__Proc
endif

Return .t.
**-------------------------------------------------------------------------------------------------------------------------**
