procedure func_Relatorio
Param xtipo,xObj

xOk = .t.
if UPPER(xtipo)='PRE' or UPPER(xtipo)='IMP'
	xProc = SET('proce')
	SET PROCEDURE TO report.prg\l009100.prg addi
	xOk=lx_gerar_tabelas_dbf(xtipo,xObj)
	SET PROCEDURE TO &xProc
endif

Return (xOk)
*------------------------------------------------------------------------------------------------------------------------*
