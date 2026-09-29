procedure func_Relatorio
lparameter xtipo,xObj

x__Proc = set('proce')
set proc to report.prg\L006101.prg addi
xOk=Ini_Semi_Acabado(xtipo,xObj)
set proce to &x__Proc

Return xOk
**-------------------------------------------------------------------------------------------------------------------------**
