PROCEDURE Func_Relatorio
lparameter xtipo,R

	if !(UPPER(xtipo)='PRE' or UPPER(xtipo)='IMP' or UPPER(xtipo)='IPA')
		Retu .t.
	endif

	local xsele
	xsele = sele()

	Public x__proc
	x__proc  = set('proc')
	Set proc to ..\report.prg\L002006.prg addi
	=Set_Porta(xtipo)

	set proc to &x__proc
	sele (xsele)

Return .f.
