procedure func_Relatorio
lparameter xtipo,xObj

xOk = .t.
if UPPER(xtipo)='PRE' or UPPER(xtipo)='IMP'
	x__Proc = set('proce')
	set proc to report.prg\L008100a.prg addi
	xOk=Fx_Init_008100(xtipo,xObj)
	set proce to &x__Proc
ENDIF

Return xOk
*---------------------------------------------------------------------------------------------------------------------------------------------------*
