** Ref.....: Produtos com variacao de preco por grade  (Valmir-20.02.98)
** Objetivo: desmembrar as quantidades para sair em linhas separadas
** Uso.....: Nos Relatorios de Pedido para cliente/ Licenciado/ etc. (i,j,k)

**------------------------------------------------------------------------------------------------------------------------**
Procedure Desmembrar
sele vtmp_vendas_00_produtos  && Crusor a ser desmembrado

**---- Obter o Numero de variacoes
xnum_var = 2  && se ha variacao, ja deve haver pelo menos "duas"
for q = 1 to wmaximo_tamanhos
	xvar = val(subs(ponteiro_preco_tam,q,1))
	if xvar > xnum_var
		xnum_var = xvar
	endif
endfor

**-- verifica precos 2 a 4: Precos zerados serao replaceados com Preco1
for k = 2 to xnum_var
	k_ = allt(str(k))
	if preco&k_ = 0
		replace preco&k_ with preco1
	endif
endfor

**--desmembra conforme a variacao da grade
scatter memvar && copia do registro original/tmp

for k = 1 to xnum_var             && Varre as "xnum_var" possibilidades (precos)
	k_ = allt(str(k))

	if k > 1  && replace apartir do segundo
		appe blank
		gather memvar
	endif
	replace preco1 with preco&k_  && o rel. usa sempre a coluna PRECO1
		
	**-- zera tamanhos fora do limite da variacao/grade
	xq_original = 0  && acumula quantidades (inicial)
	for t = 1 to wmaximo_tamanhos
		t_ = allt(str(t))
		if subs(ponteiro_preco_tam,t,1) # k_  && (k = preço correspondente)
			replace vo&t_ with 0
		endif
		xq_original = xq_original + vo&t_
	endfor
	replace qtde_original with xq_original, valor_original with xq_original * (preco&k_ - desconto_item)

endfor

sele v_vendas_00_produtos
**------------------------------------------------------------------------------------------------------------------------**
