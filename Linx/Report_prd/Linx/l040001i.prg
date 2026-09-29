procedure func_Relatorio
lparameter xtipo,xObj

x__Proc = set('proce')
set proc to ..\report.prg\L040001.prg addi
xOk=Ini_FT_Crystal(xtipo,xObj,10)
set proce to &x__Proc

Return xOk
**-------------------------------------------------------------------------------------------------------------------------**
