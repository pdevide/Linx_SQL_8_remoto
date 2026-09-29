**-------------------------------------------------------------------------------------------------------------------------**
** Verifica status de descontinuidade do Produto [ pelo campo status_venda_atual='2' ]
** (exclusivo da Ellus)
function f_descont_cor
parameters xorigem_produto

x_campo = &xorigem_produto

xsele = alias()
=f_select('select * from produto_cores where produto = ?x_campo','x_cores')
sele x_cores
go top

x_num_cores = 0     && Guarda numero de cores
x_num_desc  = 0     && Guarda numero de Descontinuados
scan 
	x_num_cores = x_num_cores  + 1
	if status_venda_atual='2'                     && <-- corrigido aqui em 19.01.98
		x_num_desc  = x_num_desc + 1
	endif
endscan


if x_num_desc = x_num_cores
	x_status = 'T'     && Descontinuado Total
else
	if x_num_desc > 0
		x_status = 'P'     && Descontinuado Parcial
	else
		x_status = ' '     && Descontinuado Vazio
	endif	
endif

sele (xsele)
Return (x_Status)






**-------------------------------------------------------------------------------------------------------------------------**
**--- Comando que substitui o requere em função dos calculos/filtros de vendas necessarios
Function Requery_080004_cores
xalias = alias()
xskip  = set('skip')
xrela  = set('rela')

o_080004.lx_form1.lx_pageframe1.page3.activate()
sele v_vendas_produto_02_cores
=cursorset('buffering',3)
inde on produto + cor_produto tag produto

sele (xalias)
set rela to &xrela
set skip to &xskip
Return




**-------------------------------------------------------------------------------------------------------------------------**
Function Requery_080004_clientes
sele v_vendas_produto_02_clientes
=requery()
o_080004.lx_form1.lx_pageframe1.page4.activate()
go top
sele v_vendas_produto_02
return
**-------------------------------------------------------------------------------------------------------------------------**
