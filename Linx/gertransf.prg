
*SET STEP ON 

TEXT TO x NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
select  produto_cores.DESC_COR_produto,   produtos.REFER_FABRICANTE,   produtos.DESC_PRODUTO, produtos.unidade, produtos.grade, produtos.PONTEIRO_PRECO_TAM, FATURAMENTO_PROD.produto, FATURAMENTO_PROD.cor_produto, PRODUTOS_PRECOS.PRECO1 as preco, sum(FATURAMENTO_PROD.qtde) as qtde , sum(FATURAMENTO_PROD.valor) as valor,
	SUM(F1) AS F1,SUM(F2) AS F2,SUM(F3) AS F3,SUM(F4) AS F4,SUM(F5) AS F5,
	SUM(F6) AS F6,SUM(F7) AS F7,SUM(F8) AS F8,SUM(F9) AS F9,SUM(F10) AS F10,
	SUM(F11) AS F11,SUM(F12) AS F12,SUM(F13) AS F13,SUM(F14) AS F14,SUM(F15) AS F15,
	SUM(F16) AS F16,SUM(F17) AS F17,SUM(F18) AS F18,SUM(F19) AS F19,SUM(F20) AS F20
	from FATURAMENTO_PROD   
		left join produtos 
			on FATURAMENTO_PROD.produto = produtos.produto
		left join produto_cores  produto_cores
		on FATURAMENTO_PROD.cor_produto = produto_cores.COR_produto
		and FATURAMENTO_PROD.produto = produto_cores.produto
		inner join PRODUTOS_PRECOS 
		on FATURAMENTO_PROD.produto = PRODUTOS_PRECOS.produto and PRODUTOS_PRECOS.CODIGO_TAB_PRECO= '00'

	where nF_SAIDA in ('0073399') 
	group by produto_cores.DESC_COR_produto, produtos.REFER_FABRICANTE, produtos.DESC_PRODUTO, produtos.unidade,produtos.grade, produtos.PONTEIRO_PRECO_TAM, FATURAMENTO_PROD.produto, FATURAMENTO_PROD.cor_produto, PRODUTOS_PRECOS.PRECO1
ENDTEXT

F_SELECT(x,'TMPPROD')


SELECT TMPPROD
SCAN
	SELECT V_estoque_prod_sai_00_produtos
	APPEND BLANK
	
	replace V_estoque_prod_sai_00_produtos.unidade with TMPPROD.unidade 

	replace V_estoque_prod_sai_00_produtos.unidade with TMPPROD.unidade 	
	replace V_estoque_prod_sai_00_produtos.DESC_PRODUTO with TMPPROD.DESC_PRODUTO
	replace V_estoque_prod_sai_00_produtos.DESC_COR_PRODUTO with TMPPROD.DESC_COR_produto 	
	replace V_estoque_prod_sai_00_produtos.Sortimento_cor with .F.
	replace V_estoque_prod_sai_00_produtos.Custo1 with TMPPROD.preco	
	replace V_estoque_prod_sai_00_produtos.valor with TMPPROD.preco	* TMPPROD.QTDE
	replace V_estoque_prod_sai_00_produtos.refer_fabricante with TMPPROD.refer_fabricante 
	
	replace V_estoque_prod_sai_00_produtos.varia_preco_tam with .f.
	replace V_estoque_prod_sai_00_produtos.ponteiro_preco_tam  with TMPPROD.ponteiro_preco_tam  
	
	
	replace V_estoque_prod_sai_00_produtos.grade with TMPPROD.GRADE 
	replace V_estoque_prod_sai_00_produtos.produto with  TMPPROD.produto 
	replace V_estoque_prod_sai_00_produtos.cor_produto with  TMPPROD.cor_produto
	
	replace V_estoque_prod_sai_00_produtos.qtde with  TMPPROD.QTDE
	replace V_estoque_prod_sai_00_produtos.sa_1 with  TMPPROD.F1 
	replace V_estoque_prod_sai_00_produtos.sa_2 with  TMPPROD.F2 
	replace V_estoque_prod_sai_00_produtos.sa_3 with  TMPPROD.F3 
	replace V_estoque_prod_sai_00_produtos.sa_4 with  TMPPROD.F4 
	replace V_estoque_prod_sai_00_produtos.sa_5 with  TMPPROD.F5 
	replace V_estoque_prod_sai_00_produtos.sa_6 with  TMPPROD.F6 
	replace V_estoque_prod_sai_00_produtos.sa_7 with  TMPPROD.F7 
	replace V_estoque_prod_sai_00_produtos.sa_8 with  TMPPROD.F8 
	replace V_estoque_prod_sai_00_produtos.sa_9 with  TMPPROD.F9 
	replace V_estoque_prod_sai_00_produtos.sa_10 with  TMPPROD.F10 
	
	replace V_estoque_prod_sai_00_produtos.sa_11 with  TMPPROD.F11 
	replace V_estoque_prod_sai_00_produtos.sa_12 with  TMPPROD.F12 
	replace V_estoque_prod_sai_00_produtos.sa_13 with  TMPPROD.F13 
	replace V_estoque_prod_sai_00_produtos.sa_14 with  TMPPROD.F14 
	replace V_estoque_prod_sai_00_produtos.sa_15 with  TMPPROD.F15 
	replace V_estoque_prod_sai_00_produtos.sa_16 with  TMPPROD.F16 
	replace V_estoque_prod_sai_00_produtos.sa_17 with  TMPPROD.F17 
	replace V_estoque_prod_sai_00_produtos.sa_18 with  TMPPROD.F18 
	replace V_estoque_prod_sai_00_produtos.sa_19 with  TMPPROD.F19 
	replace V_estoque_prod_sai_00_produtos.sa_20 with  TMPPROD.F20 
	


	SELECT TMPPROD
ENDSCAN