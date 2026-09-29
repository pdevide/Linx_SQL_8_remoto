**-------------------------------------------------------------------------------------------------------------------------** 
*---- Requery com recalculo 
Procedure Requery_Extrato
xsele = alias()
requery('v_contas_plano_00_lancamentos')
O_010004.lx_form1.lx_pageframe1.page2.cm_RECALCULA.click()

sele v_contas_plano_00_lancamentos
set filter to
if o_010004.px_conciliado<>0
	set filter to iif(o_010004.px_conciliado=1,conciliado,!conciliado)
endif
go top

sele (xsele)
Return
**-------------------------------------------------------------------------------------------------------------------------** 



**-------------------------------------------------------------------------------------------------------------------------** 
*-----  Chamada da Form para pegar faixa de campos ( para uso no report )
Function Obter_Faixa_Campo
Parameters xView,xGru,xgIni,xgTam,xSub,xSgIni,xSgTam
do form lxoprel_faixa_campo with xView,xGru,xgIni,xgTam,xSub,xSgIni,xSgTam
Return .t.
**-------------------------------------------------------------------------------------------------------------------------** 
