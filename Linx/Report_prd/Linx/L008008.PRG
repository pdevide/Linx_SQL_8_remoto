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



**------------------------------------------------------------------------------------------------------------**
** Obs.: Esta funcao foi copiada da form, na versao 3 do visual fox era chamado direto do                     **
** relatorio - > exemplo:  NA QUEBRA TINHA ESTE COMANDO -> o_008008.lx_form1.lx_pageframe1.page3.activate(),  **
** porem com o fox 5.0, passou a nao funcionar, porisso, esta proce lx_report como um prg se faz necessario.  **
** em meados de jul/ago/97, com a versao 5.0a do fox, percebemos que isso tinha sido resolvido, entao         **
** voltamos a velha forma, estava tudo ok, porem em alguns clientes comecou a aparecer o velho problemas,     **
** resultado: AINDA NAO FUNCIONA QUANDO EXECUTAVEL (EXE), no ambiente de desenvolvimento da linx              **
** funcionava ok, com APP tambem ok, porem com EXE ainda nao funciona, portanto voltamos a velha forma,       **
** quem sabe na proxima versao do fox!!!                                        ... [  by Valmir  ]           **
**------------------------------------------------------------------------------------------------------------** 

procedure lx_report_008008
	local xcor_sortida,xvenda_sort,xcor,xsort,xaux,xaux1,xalias
	xalias = alias()
	
	sele v_produtos_01_cor
*	set filter to 
	
	if !o_008008.px_original_vendas 
	
		XSELECT = " SELECT '1- Venda Saldo(+) ',VENDAS_PRODUTO.PRODUTO,cor_produto,;
		SUM_qtde=SUM(qtde_entregar) ,;
		SUM_vE1 =SUM(ve1 )  ,SUM_vE2 =SUM(ve2)  ,;
		SUM_vE3 =SUM(ve3 )  ,SUM_vE4 =SUM(ve4)  ,"+";
		SUM_vE5 =SUM(ve5 )  ,SUM_vE6 =SUM(ve6)  ,;
		SUM_vE7 =SUM(ve7 )  ,SUM_vE8 =SUM(ve8)  ,"+";
		SUM_vE9 =SUM(ve9 )  ,SUM_vE10=SUM(ve10) ,;
		SUM_vE11=SUM(ve11) ,SUM_vE12=SUM(ve12)  ,;
		SUM_vE13=SUM(ve13) ,SUM_vE14=SUM(ve14)  ,;
		SUM_vE15=SUM(ve15) ,SUM_vE16=SUM(ve16)  ,"+";
		SUM_vE17=SUM(ve17) ,SUM_vE18=SUM(ve18)  ,;
		SUM_vE19=SUM(ve19) ,SUM_vE20=SUM(ve20)  ,;
		SUM_vE21=SUM(ve21) ,SUM_vE22=SUM(ve22)  ,;
		SUM_vE23=SUM(ve23) ,SUM_vE24=SUM(ve24)  ,"+";
		SUM_vE25=SUM(ve25) ,SUM_vE26=SUM(ve26)  ,;
		SUM_vE27=SUM(ve27) ,SUM_vE28=SUM(ve28)  ,;
		SUM_vE29=SUM(ve29) ,SUM_vE30=SUM(ve30)  ,"

		XSELECT=XSELECT+ ; 
		"SUM_vE31=SUM(ve31) ,SUM_vE32=SUM(ve32) ,;
		SUM_vE33=SUM(ve33) ,SUM_vE34=SUM(ve34) ,;
		SUM_vE35=SUM(ve35) ,SUM_vE36=SUM(ve36) ,;
		SUM_vE37=SUM(ve37) ,SUM_vE38=SUM(ve38) ,;
		SUM_vE39=SUM(ve39) ,SUM_vE40=SUM(ve40) ,"+";
		SUM_vE41=SUM(ve41) ,SUM_vE42=SUM(ve42) ,;
		SUM_vE43=SUM(ve43) ,SUM_vE44=SUM(ve44) ,;
		SUM_vE45=SUM(ve45) ,SUM_vE46=SUM(ve46) ,;
		SUM_vE47=SUM(ve47) ,SUM_vE48=SUM(ve48) ;
		FROM VENDAS Vendas,vendas_produto Vendas_produto,PRODUTOS produtos"+;
		" WHERE vendas.pedido=vendas_produto.pedido and vendas_produto.produto=produtos.produto "+;
		" and vendas_produto.produto = ?v_produtos_01.produto"

		if !f_vazio(O_008008.px_filtro_vendas)
			xselect = xselect + ' and ' + O_008008.px_filtro_vendas
		endif 
		 
		XSELECT=XSELECT+ ; 
		' group by VENDAS_PRODUTO.PRODUTO,VENDAS_PRODUTO.cor_produto'
	
	else

		XSELECT = " SELECT '1- Venda Orig.(+)',VENDAS_PRODUTO.PRODUTO,cor_produto,;
		SUM_qtde=SUM(qtde_original) ,;
		SUM_vE1 =SUM(vo1 )  ,SUM_vE2 =SUM(vo2)  ,;
		SUM_vE3 =SUM(vo3 )  ,SUM_vE4 =SUM(vo4)  ,"+";
		SUM_vE5 =SUM(vo5 )  ,SUM_vE6 =SUM(vo6)  ,;
		SUM_vE7 =SUM(vo7 )  ,SUM_vE8 =SUM(vo8)  ,"+";
		SUM_vE9 =SUM(vo9 )  ,SUM_vE10=SUM(vo10) ,;
		SUM_vE11=SUM(vo11) ,SUM_vE12=SUM(vo12)  ,;
		SUM_vE13=SUM(vo13) ,SUM_vE14=SUM(vo14)  ,;
		SUM_vE15=SUM(vo15) ,SUM_vE16=SUM(vo16)  ,"+";
		SUM_vE17=SUM(vo17) ,SUM_vE18=SUM(vo18)  ,;
		SUM_vE19=SUM(vo19) ,SUM_vE20=SUM(vo20)  ,;
		SUM_vE21=SUM(vo21) ,SUM_vE22=SUM(vo22)  ,;
		SUM_vE23=SUM(vo23) ,SUM_vE24=SUM(vo24)  ,"+";
		SUM_vE25=SUM(vo25) ,SUM_vE26=SUM(vo26)  ,;
		SUM_vE27=SUM(vo27) ,SUM_vE28=SUM(vo28)  ,;
		SUM_vE29=SUM(vo29) ,SUM_vE30=SUM(vo30)  ,"

		XSELECT=XSELECT+ ; 
		"SUM_vE31=SUM(vo31) ,SUM_vE32=SUM(vo32) ,;
		SUM_vE33=SUM(vo33) ,SUM_vE34=SUM(vo34) ,;
		SUM_vE35=SUM(vo35) ,SUM_vE36=SUM(vo36) ,;
		SUM_vE37=SUM(vo37) ,SUM_vE38=SUM(vo38) ,;
		SUM_vE39=SUM(vo39) ,SUM_vE40=SUM(vo40) ,"+";
		SUM_vE41=SUM(vo41) ,SUM_vE42=SUM(vo42) ,;
		SUM_vE43=SUM(vo43) ,SUM_vE44=SUM(vo44) ,;
		SUM_vE45=SUM(vo45) ,SUM_vE46=SUM(vo46) ,;
		SUM_vE47=SUM(vo47) ,SUM_vE48=SUM(vo48) ;
		FROM VENDAS Vendas,vendas_produto Vendas_produto,PRODUTOS produtos"+;
		" WHERE vendas.pedido=vendas_produto.pedido and vendas_produto.produto=produtos.produto "+;
		" and vendas_produto.produto = ?v_produtos_01.produto"

		if !f_vazio(O_008008.px_filtro_vendas)
			xselect = xselect + ' and ' + O_008008.px_filtro_vendas
		endif 
		 
		XSELECT=XSELECT+ ; 
		' group by VENDAS_PRODUTO.PRODUTO,VENDAS_PRODUTO.cor_produto'
	
	endif

	if !o_008008.px_original_vendas 

		XSELECT=XSELECT+ ; 
		" union ALL ; 
		SELECT '2-Estoque (-)',Estoque_produtos.PRODUTO,COR_PRODUTO,SUM_qtde  =SUM(estoque) ,"+"; 
		SUM_vE1 =SUM(es1 )  ,SUM_vE2 =SUM(es2)  ,SUM_vE3 =SUM(es3 )  ,SUM_vE4 =SUM(es4) ,"+";
		SUM_vE5 =SUM(es5 )  ,SUM_vE6 =SUM(es6)  ,SUM_vE7 =SUM(es7 )  ,SUM_vE8 =SUM(es8) ,;
		SUM_vE9 =SUM(es9 )  ,SUM_vE10=SUM(es10) ,SUM_vE11=SUM(es11) ,SUM_vE12=SUM(es12) ,;
		SUM_vE13=SUM(es13) ,SUM_vE14=SUM(es14) ,SUM_vE15=SUM(es15) ,SUM_vE16=SUM(es16)  ,"+";
		SUM_vE17=SUM(es17) ,SUM_vE18=SUM(es18) ,SUM_vE19=SUM(es19) ,SUM_vE20=SUM(es20)  ,;
		SUM_vE21=SUM(es21) ,SUM_vE22=SUM(es22) ,SUM_vE23=SUM(es23) ,SUM_vE24=SUM(es24)  ,;
		SUM_vE25=SUM(es25) ,SUM_vE26=SUM(es26) ,SUM_vE27=SUM(es27) ,SUM_vE28=SUM(es28)  ,"+";
		SUM_vE29=SUM(es29) ,SUM_vE30=SUM(es30) ,SUM_vE31=SUM(es31) ,SUM_vE32=SUM(es32)  ,;
		SUM_vE33=SUM(es33) ,SUM_vE34=SUM(es34) ,SUM_vE35=SUM(es35) ,SUM_vE36=SUM(es36)  ,;
		SUM_vE37=SUM(es37) ,SUM_vE38=SUM(es38) ,SUM_vE39=SUM(es39) ,SUM_vE40=SUM(es40)  ,"+";
		SUM_vE41=SUM(es41) ,SUM_vE42=SUM(es42) ,SUM_vE43=SUM(es43) ,SUM_vE44=SUM(es44)  ,;
		SUM_vE45=SUM(es45) ,SUM_vE46=SUM(es46) ,SUM_vE47=SUM(es47) ,SUM_vE48=SUM(es48)  "+";
		 FROM PRODUTOS produtos,estoque_produtos estoque_produtos WHERE "+;
		" produtos.produto=estoque_produtos.produto and estoque_produtos.produto = ?v_produtos_01.produto"

		if !f_vazio(O_008008.px_clausula_where)
			xselect = xselect +  ' and ' + O_008008.px_clausula_where
		endif

		if !f_vazio(O_008008.px_filial_filtro_estoque)
			xselect = xselect + " and filial ='"+O_008008.px_filial_filtro_estoque+"'"			
		endif

		xselect=xselect+" GROUP BY estoque_produtos.PRODUTO,estoque_produtos.COR_PRODUTO "
	
	endif

	*if v_produtos_01.revenda    && SE PRODUTO FOR REVENDA, cONSIDERAR cOMPRAS , SENAO CONSIDERAR PRODUCAO

	XSELECT=XSELECT+ " union  ALL ; 
	SELECT '3-Compras(-)',COMPRAS_PRODUTO.PRODUTO,COMPRAS_PRODUTO.COR_PRODUTO,SUM_qtde=SUM(Qtde_ENTREGAR) ,"+";
	SUM_vE1 =SUM(ce1 )  ,SUM_vE2 =SUM(ce2)  ,SUM_vE3 =SUM(ce3 )  ,SUM_vE4 =SUM(ce4) , ; 
	SUM_vE5 =SUM(ce5 )  ,SUM_vE6 =SUM(ce6)  ,SUM_vE7 =SUM(ce7 )  ,SUM_vE8 =SUM(ce8) , ; 
	SUM_vE9 =SUM(ce9 )  ,SUM_vE10=SUM(ce10) ,SUM_vE11=SUM(ce11) ,SUM_vE12=SUM(ce12) ,"+" ; 
	SUM_vE13=SUM(ce13) ,SUM_vE14=SUM(ce14) ,SUM_vE15=SUM(ce15) ,SUM_vE16=SUM(ce16)  , ; 
	SUM_vE17=SUM(ce17) ,SUM_vE18=SUM(ce18) ,SUM_vE19=SUM(ce19) ,SUM_vE20=SUM(ce20)  , ; 
	SUM_vE21=SUM(ce21) ,SUM_vE22=SUM(ce22) ,SUM_vE23=SUM(ce23) ,SUM_vE24=SUM(ce24)  ,"+" ; 
	SUM_vE25=SUM(ce25) ,SUM_vE26=SUM(ce26) ,SUM_vE27=SUM(ce27) ,SUM_vE28=SUM(ce28)  , ; 
	SUM_vE29=SUM(ce29) ,SUM_vE30=SUM(ce30) ,SUM_vE31=SUM(ce31) ,SUM_vE32=SUM(ce32)  , ; 
	SUM_vE33=SUM(ce33) ,SUM_vE34=SUM(ce34) ,SUM_vE35=SUM(ce35) ,SUM_vE36=SUM(ce36)  ,"+" ; 
	SUM_vE37=SUM(ce37) ,SUM_vE38=SUM(ce38) ,SUM_vE39=SUM(ce39) ,SUM_vE40=SUM(ce40)  , ; 
	SUM_vE41=SUM(ce41) ,SUM_vE42=SUM(ce42) ,SUM_vE43=SUM(ce43) ,SUM_vE44=SUM(ce44)  ,"+" ; 
	SUM_vE45=SUM(ce45) ,SUM_vE46=SUM(ce46) ,SUM_vE47=SUM(ce47) ,SUM_vE48=SUM(ce48)  " + ; 
	" FROM compras_produto compras_produto,PRODUTOS produtos"+;
	+iif(!EMPTY(O_008008.Lx_form1.Lx_pageframe1.Page1.Lx_faixa_COMPRAS.CMB_DATA.VALUE)," ,compras compras", "");
	+" WHERE compras_produto.produto=produtos.produto and compras_produto.produto = ?v_produtos_01.produto "
		 
	IF !EMPTY(O_008008.Lx_form1.Lx_pageframe1.Page1.Lx_faixa_COMPRAS.CMB_DATA.VALUE)
		XSELECT=XSELECT+ ' AND ' +O_008008.Lx_form1.Lx_pageframe1.Page1.Lx_faixa_COMPRAS.P_FAIXA_DATAS +;
		        " AND COMPRAS.PEDIDO=COMPRAS_PRODUTO.PEDIDO "
	ENDIF

	if !f_vazio(O_008008.px_clausula_where)
		xselect = xselect +  ' and ' + O_008008.px_clausula_where
	endif
	 
	XSELECT=XSELECT+ " GROUP BY COMPRAS_PRODUTO.PRODUTO,COMPRAS_PRODUTO.COR_PRODUTO"

	*else

	if !o_008008.px_original_vendas 

		XSELECT=XSELECT+ " union  ALL ; 
		SELECT '3-Produção(-)',PRODUCAO_ORDEM_COR.PRODUTO,PRODUCAO_ORDEM_COR.COR_PRODUTO,SUM_qtde=SUM(Qtde_p) ,"+";
		SUM_vE1 =SUM(p1 )  ,SUM_vE2 =SUM(p2)  ,SUM_vE3 =SUM(p3 )  ,SUM_vE4 =SUM(p4) , ; 
		SUM_vE5 =SUM(p5 )  ,SUM_vE6 =SUM(p6)  ,SUM_vE7 =SUM(p7 )  ,SUM_vE8 =SUM(p8) , ; 
		SUM_vE9 =SUM(p9 )  ,SUM_vE10=SUM(p10) ,SUM_vE11=SUM(p11) ,SUM_vE12=SUM(p12) ,"+" ; 
		SUM_vE13=SUM(p13) ,SUM_vE14=SUM(p14) ,SUM_vE15=SUM(p15) ,SUM_vE16=SUM(p16)  , ; 
		SUM_vE17=SUM(p17) ,SUM_vE18=SUM(p18) ,SUM_vE19=SUM(p19) ,SUM_vE20=SUM(p20)  , ; 
		SUM_vE21=SUM(p21) ,SUM_vE22=SUM(p22) ,SUM_vE23=SUM(p23) ,SUM_vE24=SUM(p24)  ,"+" ; 
		SUM_vE25=SUM(p25) ,SUM_vE26=SUM(p26) ,SUM_vE27=SUM(p27) ,SUM_vE28=SUM(p28)  , ; 
		SUM_vE29=SUM(p29) ,SUM_vE30=SUM(p30) ,SUM_vE31=SUM(p31) ,SUM_vE32=SUM(p32)  , ; 
		SUM_vE33=SUM(p33) ,SUM_vE34=SUM(p34) ,SUM_vE35=SUM(p35) ,SUM_vE36=SUM(p36)  ,"+" ; 
		SUM_vE37=SUM(p37) ,SUM_vE38=SUM(p38) ,SUM_vE39=SUM(p39) ,SUM_vE40=SUM(p40)  , ; 
		SUM_vE41=SUM(p41) ,SUM_vE42=SUM(p42) ,SUM_vE43=SUM(p43) ,SUM_vE44=SUM(p44)  ,"+" ; 
		SUM_vE45=SUM(p45) ,SUM_vE46=SUM(p46) ,SUM_vE47=SUM(p47) ,SUM_vE48=SUM(p48)  " + ; 
		" FROM producao_ordem_cor producao_ordem_cor,PRODUTOS produtos"+;
		+iif(!EMPTY(O_008008.Lx_form1.Lx_pageframe1.Page1.Lx_faixa_PRODUCAO.CMB_DATA.VALUE)," ,Producao_Ordem Producao_Ordem", "");
		+" WHERE producao_ordem_cor.produto=produtos.produto and producao_ordem_cor.produto = ?v_produtos_01.produto "
		 
		IF !EMPTY(O_008008.Lx_form1.Lx_pageframe1.Page1.Lx_faixa_PRODUCAO.CMB_DATA.VALUE)
			XSELECT=XSELECT+ ' AND ' +O_008008.Lx_form1.Lx_pageframe1.Page1.Lx_faixa_PRODUCAO.P_FAIXA_DATAS +;
			        " AND PRODUCAO_ORDEM.ORDEM_PRODUCAO=PRODUCAO_ORDEM_COR.ORDEM_PRODUCAO"
		ENDIF

		if !f_vazio(O_008008.px_clausula_where)
			xselect = xselect +  ' and ' + O_008008.px_clausula_where
		endif
		 
		XSELECT=XSELECT+ " GROUP BY PRODUCAO_ORDEM_COR.PRODUTO,PRODUCAO_ORDEM_COR.COR_PRODUTO"
	
	else

		XSELECT=XSELECT+ " union  ALL ; 
		SELECT '3-Produção(-)',PRODUCAO_ORDEM_COR.PRODUTO,PRODUCAO_ORDEM_COR.COR_PRODUTO,SUM_qtde=SUM(Qtde_o) ,"+";
		SUM_vE1 =SUM(o1 )  ,SUM_vE2 =SUM(o2)  ,SUM_vE3 =SUM(o3 )  ,SUM_vE4 =SUM(o4) , ; 
		SUM_vE5 =SUM(o5 )  ,SUM_vE6 =SUM(o6)  ,SUM_vE7 =SUM(o7 )  ,SUM_vE8 =SUM(o8) , ; 
		SUM_vE9 =SUM(o9 )  ,SUM_vE10=SUM(o10) ,SUM_vE11=SUM(o11) ,SUM_vE12=SUM(o12) ,"+" ; 
		SUM_vE13=SUM(o13) ,SUM_vE14=SUM(o14) ,SUM_vE15=SUM(o15) ,SUM_vE16=SUM(o16)  , ; 
		SUM_vE17=SUM(o17) ,SUM_vE18=SUM(o18) ,SUM_vE19=SUM(o19) ,SUM_vE20=SUM(o20)  , ; 
		SUM_vE21=SUM(o21) ,SUM_vE22=SUM(o22) ,SUM_vE23=SUM(o23) ,SUM_vE24=SUM(o24)  ,"+" ; 
		SUM_vE25=SUM(o25) ,SUM_vE26=SUM(o26) ,SUM_vE27=SUM(o27) ,SUM_vE28=SUM(o28)  , ; 
		SUM_vE29=SUM(o29) ,SUM_vE30=SUM(o30) ,SUM_vE31=SUM(o31) ,SUM_vE32=SUM(o32)  , ; 
		SUM_vE33=SUM(o33) ,SUM_vE34=SUM(o34) ,SUM_vE35=SUM(o35) ,SUM_vE36=SUM(o36)  ,"+" ; 
		SUM_vE37=SUM(o37) ,SUM_vE38=SUM(o38) ,SUM_vE39=SUM(o39) ,SUM_vE40=SUM(o40)  , ; 
		SUM_vE41=SUM(o41) ,SUM_vE42=SUM(o42) ,SUM_vE43=SUM(o43) ,SUM_vE44=SUM(o44)  ,"+" ; 
		SUM_vE45=SUM(o45) ,SUM_vE46=SUM(o46) ,SUM_vE47=SUM(o47) ,SUM_vE48=SUM(o48)  " + ; 
		" FROM producao_ordem_cor producao_ordem_cor,PRODUTOS produtos"+;
		+iif(!EMPTY(O_008008.Lx_form1.Lx_pageframe1.Page1.Lx_faixa_PRODUCAO.CMB_DATA.VALUE)," ,Producao_Ordem Producao_Ordem", "");
		+" WHERE producao_ordem_cor.produto=produtos.produto and producao_ordem_cor.produto = ?v_produtos_01.produto "
		 
		IF !EMPTY(O_008008.Lx_form1.Lx_pageframe1.Page1.Lx_faixa_PRODUCAO.CMB_DATA.VALUE)
			XSELECT=XSELECT+ ' AND ' +O_008008.Lx_form1.Lx_pageframe1.Page1.Lx_faixa_PRODUCAO.P_FAIXA_DATAS +;
			        " AND PRODUCAO_ORDEM.ORDEM_PRODUCAO=PRODUCAO_ORDEM_COR.ORDEM_PRODUCAO"
		ENDIF

		if !f_vazio(O_008008.px_clausula_where)
			xselect = xselect +  ' and ' + O_008008.px_clausula_where
		endif
		 
		XSELECT=XSELECT+ " GROUP BY PRODUCAO_ORDEM_COR.PRODUTO,PRODUCAO_ORDEM_COR.COR_PRODUTO"
	
	endif
	
	if o_008008.px_original_vendas 
		
		store '' to xsumcanc,xsumdevol
		
		for xt=1 to 48
			xstr=alltrim(str(xt))
			xsumcanc = xsumcanc  + 'sum_ve'+xstr+' = sum(Vendas_Canc_Prod.vo'+xstr+'),' 	
			xsumdevol= xsumdevol + 'sum_ve'+xstr+' = sum(Entradas_Pro_Devol.f'+xstr+'),' 	
		endfor
		
		xsumcanc=left(xsumcanc,len(xsumcanc)-1)
		xsumdevol=left(xsumdevol,len(xsumdevol)-1)
		

		xSelectCanc = "Select '4-Cancel.(-)',Vendas_Canc_Prod.PRODUTO,"+;
		"Vendas_Canc_Prod.COR_PRODUTO,SUM_qtde=SUM(Vendas_Canc_Prod.qtde_cancelada),"+;
		xsumcanc+' from Vendas_Canc_Prod '

		do case 

			case  o_008008.px_filtro_vendas_tratamento = 0 && Sem tabela VENDAS e sem FILTRO               
				xSelectCanc = xSelectCanc + ;	                
			         '  WHERE  Vendas_Canc_Prod.produto     = ?v_produtos_01.produto ' +;
			   	     '  GROUP BY Vendas_Canc_Prod.PRODUTO,Vendas_Canc_Prod.COR_PRODUTO '
			case  o_008008.px_filtro_vendas_tratamento = 1 && Sem tabela VENDAS e com FILTRO
				xSelectCanc = xSelectCanc + ;	                
		   		     '  , PRODUTOS produtos , vendas_produto '               +;
			         '  WHERE  Vendas_Canc_Prod.produto = ?v_produtos_01.produto ' +;
			         ' AND Vendas_Canc_Prod.produto = vendas_produto.produto '+;
			         ' AND Vendas_Canc_Prod.cor_produto = vendas_produto.cor_produto '+;
			         ' AND Vendas_Canc_Prod.entrega = vendas_produto.entrega '+;
			         ' AND Vendas_Canc_Prod.produto = PRODUTOS.produto '+;
			         ' AND Vendas_Canc_Prod.pedido = vendas_produto.pedido AND ' +;
			         +  o_008008.px_filtro_vendas + ;
			   	     '  GROUP BY Vendas_Canc_Prod.PRODUTO,Vendas_Canc_Prod.COR_PRODUTO '
			case  o_008008.px_filtro_vendas_tratamento = 2 && Com tabela VENDAS e com FILTRO              
				xSelectCanc = xSelectCanc + ;	                
		   		     '  , PRODUTOS produtos , vendas,vendas_produto '+;
			         '  WHERE  Vendas_Canc_Prod.produto = ?v_produtos_01.produto ' +;
			         ' AND Vendas_Canc_Prod.produto = vendas_produto.produto '+;
			         ' AND Vendas_Canc_Prod.cor_produto = vendas_produto.cor_produto '+;
			         ' AND Vendas_Canc_Prod.entrega = vendas_produto.entrega '+;
			         ' AND Vendas_Canc_Prod.produto = PRODUTOS.produto AND '+;
			         ' vendas.pedido = vendas_produto.pedido ' +;
			         ' AND Vendas_Canc_Prod.pedido = vendas_produto.pedido AND ' +;
			         + o_008008.px_filtro_vendas +;
			   	     '  GROUP BY Vendas_Canc_Prod.PRODUTO,Vendas_Canc_Prod.COR_PRODUTO '
		endcase	   	    
		
		xSelectDevol = "Select '5-Devolução(-)',Entradas_Pro_Devol.PRODUTO,"+;
		"Entradas_Pro_Devol.COR_PRODUTO,SUM_qtde=SUM(Entradas_Pro_Devol.qtde),"+;
		xsumdevol+' from Entradas_Pro_Devol  '
		
		do case 

			case  o_008008.px_filtro_vendas_tratamento = 0 && Sem tabela VENDAS e sem FILTRO               
				xSelectDevol = xSelectDevol + ;	                
			         '  WHERE Entradas_Pro_Devol.produto = ?v_produtos_01.produto ' +;
			   	     '  GROUP BY Entradas_Pro_Devol.PRODUTO,Entradas_Pro_Devol.COR_PRODUTO '
			case  o_008008.px_filtro_vendas_tratamento = 1 && Sem tabela VENDAS e com FILTRO
				xSelectDevol = xSelectDevol + ;	                
		   		     '  , PRODUTOS produtos , Faturamento_Prod , vendas_produto '               +;
			         '  WHERE  Entradas_Pro_Devol.produto = ?v_produtos_01.produto and '  +  o_008008.px_filtro_vendas + ;
	  			     ' AND Entradas_pro_devol.NF_SAIDA = Faturamento_prod.NF_SAIDA '+;
					 'AND Entradas_pro_devol.PRODUTO = Faturamento_prod.PRODUTO '+;
					 'AND Entradas_pro_devol.COR_PRODUTO = Faturamento_prod.COR_PRODUTO '+;
					 'AND Entradas_pro_devol.FILIAL = Faturamento_prod.FILIAL '+;
					 'AND Entradas_pro_devol.SERIE_NF = Faturamento_prod.SERIE_NF '+;
					 'AND Entradas_pro_devol.ITEM = Faturamento_prod.ITEM '+;
					 'AND Faturamento_prod.PEDIDO = Vendas_produto.PEDIDO '+;
					 'AND Faturamento_prod.PEDIDO_PRODUTO = Vendas_produto.PRODUTO '+;
					 'AND Faturamento_prod.ENTREGA = Vendas_produto.ENTREGA '+;
					 'AND Faturamento_prod.PEDIDO_COR = Vendas_produto.COR_PRODUTO '+;
			   	     '  GROUP BY Entradas_Pro_Devol.PRODUTO,Entradas_Pro_Devol.COR_PRODUTO '
			case  o_008008.px_filtro_vendas_tratamento = 2 && Com tabela VENDAS e com FILTRO              
				xSelectDevol = xSelectDevol + ;	                
		   		     '  , PRODUTOS produtos , faturamento_Prod , vendas, vendas_produto '+;
			         '  WHERE  Entradas_Pro_Devol.produto = ?v_produtos_01.produto and ' +;
	                 ' vendas.pedido = vendas_produto.pedido and ' + o_008008.px_filtro_vendas +;
	  			     ' AND Entradas_pro_devol.NF_SAIDA = Faturamento_prod.NF_SAIDA '+;
					 'AND Entradas_pro_devol.PRODUTO = Faturamento_prod.PRODUTO '+;
					 'AND Entradas_pro_devol.COR_PRODUTO = Faturamento_prod.COR_PRODUTO '+;
					 'AND Entradas_pro_devol.FILIAL = Faturamento_prod.FILIAL '+;
					 'AND Entradas_pro_devol.SERIE_NF = Faturamento_prod.SERIE_NF '+;
					 'AND Entradas_pro_devol.ITEM = Faturamento_prod.ITEM '+;
					 'AND Faturamento_prod.PEDIDO = Vendas_produto.PEDIDO '+;
					 'AND Faturamento_prod.PEDIDO_PRODUTO = Vendas_produto.PRODUTO '+;
					 'AND Faturamento_prod.ENTREGA = Vendas_produto.ENTREGA '+;
					 'AND Faturamento_prod.PEDIDO_COR = Vendas_produto.COR_PRODUTO '+;
			   	     '  GROUP BY Entradas_Pro_Devol.PRODUTO,Entradas_Pro_Devol.COR_PRODUTO '
		endcase	 

		xselect = xselect + ' UNION ALL ' + xselectCanc + ' UNION ALL ' + xselectDevol  	    
		
	endif
		
	IF SQLEXEC(WCONECCAO,xselect,'TEMPORARIO') < 1
		=MESSAGEBOX(MESSAGE())
	ENDIF
	Sele Temporario
	xArq = Dbf()
	Sele v_produtos_01_cor
	zap
	Appe From (xArq)
	  

	Sele v_produtos_01_cores
	=Requery()
	
	sele v_produtos_01_cor
	go top
	
	********************* Distribuindo Sortimento por Cor **********************
	xcSelect = 	"Select cor_produto,sortimento_cor,cor_sortida " +;
				"from produto_cores where produto = ?v_produtos_01.produto"
				
	if ! f_select(xcSelect,"Sortimento")  && Obter tabela com o sortimento por cores p/ o produto
		=Messagebox(message())
		return
	endif
	
	loca for cor_sortida  && Verificar se existe sortimento
	
	if found()			  && Existe Sortimento
		xcor_sortida = cor_produto
		sele v_produtos_01_cor
		loca for cor_produto = xcor_sortida .and. exp='1'       && Verificar se existe venda na cor sortida
		if found()        && Existe Venda na cor Sortida
			xaux 		= f_tam()                            
			xaux1 		= f_tam()                            			
			xvenda_sort = f_tam()                               && Carregando qtdes da venda na cor sortida
			xvenda_sort.carga('sum_ve#')
			
			sele Sortimento             && Varrendo tabela de sortimentos
			scan for !cor_sortida       && Somente tratar as cores que não são a cor sortida. Porcentagem de cores so interessam nas cores nao sortidas
				xcor = cor_produto
				xsort= sortimento_cor
				sele v_produtos_01_cor
				loca for cor_produto = xcor .and. exp='1'       && Procura por venda nesta cor
				if !found()                                     && Se nao encontrar , incluir
					appe blank
					repl exp with '1- Venda Saldo(+)',produto with v_produtos_01.produto,;
					cor_produto with xcor
				endif
				xaux.carga('sum_ve#')				            && Carga da venda na cor (se houver,pode ter sido incluida agora)   
				xaux1.calcula(xvenda_sort,xsort/100,'*')        && Calculo da parte sortida que lhe cabe
				xaux1.binario(xaux1,0,'round')					&& Arredondamento
				xaux1.calcula(xaux1,xaux,'+')                   && Somando os dois valores
				xaux1.descarga('sum_ve#','sum_qtde')			&& Descarregando qtdes, inclusive no total da linha
			endscan

			sele v_produtos_01_cor
			dele for cor_produto = xcor_sortida
		endif
	endif
	****************************************************************************
	
	sele v_produtos_01_cor
	go top
	
	STOR 0 TO XVAL1,XVAL2,XVAL3,XVAL4,XVAL5,XVAL6,XVAL7,XVAL8,XVAL9,XVAL10, ; 
		XVAL11,XVAL12,XVAL13,XVAL14,XVAL15,XVAL16,XVAL17,XVAL18,XVAL19,XVAL20
	STOR 0 TO XVAL21,XVAL22,XVAL23,XVAL24,XVAL25,XVAL26,XVAL27,XVAL28,XVAL29,XVAL30, ; 
		XVAL31,XVAL32,XVAL33,XVAL34,XVAL35,XVAL36,XVAL37,XVAL38,XVAL39,XVAL40,; 
		XVAL41,XVAL42,XVAL43,XVAL44,XVAL45,XVAL46,XVAL47,XVAL48
	SCAN
		xcor=cor_produto
		SCAN WHIL xcor=cor_produto
		     FOR XI=1 TO WMAXIMO_TAMANHOS
				XCONT=ALLTRIM(STR(XI))
				if EXP='2' and SUM_VE&XCONT<0
					repl sum_qtde with sum_qtde - SUM_VE&XCONT
					repl EXP with '2#Estoque <0 !' , SUM_VE&XCONT with 0
				endif
				XVAL&XCONT = XVAL&XCONT + IIF(EXP='1', SUM_VE&XCONT , - SUM_VE&XCONT ) 
			 ENDFOR
		ENDSCAN	
		appe blank
		repl cor_PRODUTO with xcor,produto with v_produtos_01.produto, exp with '6- A Programar'
		FOR XI=1 TO WMAXIMO_TAMANHOS
			XCONT=ALLTRIM(STR(XI))
			REPL SUM_VE&XCONT  WITH IIF(XVAL&XCONT>0,XVAL&XCONT,0), SUM_QTDE WITH IIF(XVAL&XCONT>0,XVAL&XCONT,0) + SUM_QTDE
		ENDFOR
		IF SUM_QTDE=0
			DELE
		ENDIF			
		appe blank
		repl cor_PRODUTO with xcor,produto with v_produtos_01.produto, exp with '7- Sobra'
		FOR XI=1 TO WMAXIMO_TAMANHOS
			XCONT=ALLTRIM(STR(XI))
			REPL SUM_VE&XCONT  WITH IIF(XVAL&XCONT<0,-XVAL&XCONT,0), SUM_QTDE WITH IIF(XVAL&XCONT< 0,-XVAL&XCONT,0) + SUM_QTDE
		ENDFOR
		IF SUM_QTDE=0
			DELE
		ENDIF		
		STOR 0 TO XVAL1,XVAL2,XVAL3,XVAL4,XVAL5,XVAL6,XVAL7,XVAL8,XVAL9,XVAL10, ; 
			XVAL11,XVAL12,XVAL13,XVAL14,XVAL15,XVAL16,XVAL17,XVAL18,XVAL19,XVAL20
		STOR 0 TO XVAL21,XVAL22,XVAL23,XVAL24,XVAL25,XVAL26,XVAL27,XVAL28,XVAL29,XVAL30, ; 
			XVAL31,XVAL32,XVAL33,XVAL34,XVAL35,XVAL36,XVAL37,XVAL38,XVAL39,XVAL40,; 
			XVAL41,XVAL42,XVAL43,XVAL44,XVAL45,XVAL46,XVAL47,XVAL48
	
	ENDSCAN 
	
	do case
		case _oprel = 1
*			set filter to 
		case _oprel = 2
*			set filter to exp = '6' .or. exp = '7'
			dele all for !(exp = '6' .or. exp = '7')
		case _oprel = 3
*			set filter to exp = '6'		
			dele all for !(exp = '6')
		case _oprel = 4						
*			set filter to exp = '7'		
			dele all for !(exp = '7')
	endcase
	
	GO TOP

	if !empty(xalias)
		select &xalias
	endif

**------------------------------------------------------------------------------------------------------------** 

procedure lxoprel
do form \linx_sql\linx\form\desenv\lxoprel
