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
	if status_venda_atual='2' 
		x_num_desc  = x_num_desc + 1
	endif
endscan

if x_num_desc = x_num_cores
	x_status = 'T'         && Descontinuado Total
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




**-------------------------------------------------------------------------------------------------------------------------**
** (exclusivo da Ellus)
Function f_fatsp_cor
param xorigem

public xfatsp, xfatcp
xsele = alias()
xsel1 = "Select sum(qtde_entregue) from vendas_produto,vendas,produtos "
xsel1 = xsel1 + "where vendas.pedido=vendas_produto.pedido and vendas_produto.produto = produtos.produto and "
xsel1 = xsel1 + "vendas.colecao=?o_008011.lx_form1.lx_pageframe1.page5.lx_pageframe1.page2.cmb_colecao.value and "
xsel1 = xsel1 + "vendas_produto.produto = ?v_produto_CORES_01.produto and "
xsel1 = xsel1 + "vendas_produto.cor_produto = ?v_produto_cores_01.cor_produto and "
xsel1 = xsel1 + "vendas.tipo='PRONTA ENTREGA' "

Store 0 to xfatsp, xfatcp
If !f_select(xsel1,"fatsp")
    f_msg(["Falha na pesquisa do Faturamento sem pedido!!!! Erro no Select"])
else
    xfatsp = iif(isnull(fatsp.exp),0,fatsp.exp)
Endif    

xfatcp = (v_produto_cores_01.vendas_entregue)
pfat_cp = pfat_cp + xfatcp
cfat_cp = cfat_cp + xfatcp
gfat_cp = gfat_cp + xfatcp
tfat_cp = tfat_cp + xfatcp
pfat_sp = pfat_sp + xfatsp
cfat_sp = cfat_sp + xfatsp
gfat_sp = gfat_sp + xfatsp
tfat_sp = tfat_sp + xfatsp
Sele (xsele)
retu (xfatsp)


Function zera_prod
Store 0 to pfat_cp, pfat_sp
Retu

Function zera_grupo
Store 0 To gfat_cp, gfat_sp
Retu

Function zera_cartela
Store 0 to cfat_cp, cfat_sp
retu

Function zera_total
Store 0 to tfat_cp, ffat_sp
Retu
** (fim dos exclusivo da Ellus)
**-------------------------------------------------------------------------------------------------------------------------**







**------------------------------------------------------------------------------------------------------------------------**
*: Linx...
*: tem função semelhante a um requery, porem funciona por filtro
Procedure Lx_Report_008011

xsele = sele()
=o_008011.lx_form1.lx_pageframe1.page3.activate()   && não tem requery
sele (xsele)

Return


**------------------------------------------------------------------------------------------- Obtem sub-total do Produto --**
Proc Obter_SUbTot_Prod()
xsele = sele()

Sele v_produtos_01_cor    
xrec = recno()  && guarda posicao do registro
xeof = eof()    && testar fim de arquivo

xprod = produto

xExp1 = 'VENDA SALDO'
xExp2 = 'VENDA ORIGI'
xExp3 = 'ESTOQUE'
xExp4 = 'COMPRAS'
xExp5 = 'CANCEL'
xExp6 = 'DEVOLU'
xExp7 = 'PRODU'
xExp8 = 'PROGRAMAR'
xExp9 = 'SOBRA'

For k = 8 to 9
	k_ = allt(str(k))
	public p&k_.sum_qtde,p&k_.sum_ve1,p&k_.sum_ve2,p&k_.sum_ve3,p&k_.sum_ve4,p&k_.sum_ve5,p&k_.sum_ve6,p&k_.sum_ve7,p&k_.sum_ve8,p&k_.sum_ve9,p&k_.sum_ve10,p&k_.sum_ve11,p&k_.sum_ve12,p&k_.sum_ve13,p&k_.sum_ve14,p&k_.sum_ve15,p&k_.sum_ve16,p&k_.sum_ve17,p&k_.sum_ve18,p&k_.sum_ve19,p&k_.sum_ve20,p&k_.sum_ve21,p&k_.sum_ve22,p&k_.sum_ve23,p&k_.sum_ve24,p&k_.sum_ve25
	public p&k_.sum_ve26,p&k_.sum_ve27,p&k_.sum_ve28,p&k_.sum_ve29,p&k_.sum_ve30,p&k_.sum_ve31,p&k_.sum_ve32,p&k_.sum_ve33,p&k_.sum_ve34,p&k_.sum_ve35,p&k_.sum_ve36,p&k_.sum_ve37,p&k_.sum_ve38,p&k_.sum_ve39,p&k_.sum_ve40,p&k_.sum_ve41,p&k_.sum_ve42,p&k_.sum_ve43,p&k_.sum_ve44,p&k_.sum_ve45,p&k_.sum_ve46,p&k_.sum_ve47,p&k_.sum_ve48

	**--zera as variaveis
	stor 0 to p&k_.sum_qtde,p&k_.sum_ve1,p&k_.sum_ve2,p&k_.sum_ve3,p&k_.sum_ve4,p&k_.sum_ve5,p&k_.sum_ve6,p&k_.sum_ve7,p&k_.sum_ve8,p&k_.sum_ve9,p&k_.sum_ve10,p&k_.sum_ve11,p&k_.sum_ve12,p&k_.sum_ve13,p&k_.sum_ve14,p&k_.sum_ve15,p&k_.sum_ve16,p&k_.sum_ve17,p&k_.sum_ve18,p&k_.sum_ve19,p&k_.sum_ve20,p&k_.sum_ve21,p&k_.sum_ve22,p&k_.sum_ve23,p&k_.sum_ve24,p&k_.sum_ve25
	stor 0 to p&k_.sum_ve26,p&k_.sum_ve27,p&k_.sum_ve28,p&k_.sum_ve29,p&k_.sum_ve30,p&k_.sum_ve31,p&k_.sum_ve32,p&k_.sum_ve33,p&k_.sum_ve34,p&k_.sum_ve35,p&k_.sum_ve36,p&k_.sum_ve37,p&k_.sum_ve38,p&k_.sum_ve39,p&k_.sum_ve40,p&k_.sum_ve41,p&k_.sum_ve42,p&k_.sum_ve43,p&k_.sum_ve44,p&k_.sum_ve45,p&k_.sum_ve46,p&k_.sum_ve47,p&k_.sum_ve48

	sum sum_qtde,sum_ve1,sum_ve2,sum_ve3,sum_ve4,sum_ve5,sum_ve6,sum_ve7,sum_ve8,sum_ve9,sum_ve10,sum_ve11,sum_ve12,sum_ve13,sum_ve14,sum_ve15,sum_ve16,sum_ve17,sum_ve18,sum_ve19,sum_ve20,sum_ve21,sum_ve22,sum_ve23,sum_ve24,sum_ve25  to p&k_.sum_qtde,p&k_.sum_ve1,p&k_.sum_ve2,p&k_.sum_ve3,p&k_.sum_ve4,p&k_.sum_ve5,p&k_.sum_ve6,p&k_.sum_ve7,p&k_.sum_ve8,p&k_.sum_ve9,p&k_.sum_ve10,p&k_.sum_ve11,p&k_.sum_ve12,p&k_.sum_ve13,p&k_.sum_ve14,p&k_.sum_ve15,p&k_.sum_ve16,p&k_.sum_ve17,p&k_.sum_ve18,p&k_.sum_ve19,p&k_.sum_ve20,p&k_.sum_ve21,p&k_.sum_ve22,p&k_.sum_ve23,p&k_.sum_ve24,p&k_.sum_ve25 for xExp&k_ $  Upper(exp) .and. produto == xprod
	sum sum_ve26,sum_ve27,sum_ve28,sum_ve29,sum_ve30,sum_ve31,sum_ve32,sum_ve33,sum_ve34,sum_ve35,sum_ve36,sum_ve37,sum_ve38,sum_ve39,sum_ve40,sum_ve41,sum_ve42,sum_ve43,sum_ve44,sum_ve45,sum_ve46,sum_ve47,sum_ve48 to p&k_.sum_ve26,p&k_.sum_ve27,p&k_.sum_ve28,p&k_.sum_ve29,p&k_.sum_ve30,p&k_.sum_ve31,p&k_.sum_ve32,p&k_.sum_ve33,p&k_.sum_ve34,p&k_.sum_ve35,p&k_.sum_ve36,p&k_.sum_ve37,p&k_.sum_ve38,p&k_.sum_ve39,p&k_.sum_ve40,p&k_.sum_ve41,p&k_.sum_ve42,p&k_.sum_ve43,p&k_.sum_ve44,p&k_.sum_ve45,p&k_.sum_ve46,p&k_.sum_ve47,p&k_.sum_ve48 for xExp&k_ $  Upper(exp) .and. produto == xprod

	*-- zero casas decimais
	FOR j=1 TO 48
		j_ = allt(str(j))
		p&k_.sum_ve&j_ = INT(p&k_.sum_ve&j_)
	ENDFOR
	p&k_.sum_qtde = INT(p&k_.sum_qtde)

EndFor

if xeof
	go bottom
	skip
else
	go xrec
endif

sele (xsele)
**------------------------------------------------------------------------------------------------------------------------**

