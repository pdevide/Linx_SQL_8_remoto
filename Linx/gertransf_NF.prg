
SET STEP ON 

TEXT TO x NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
select  produtos.REFER_FABRICANTE,   produtos.DESC_PRODUTO, produtos.unidade, produtos.grade, produtos.PONTEIRO_PRECO_TAM, FATURAMENTO_PROD.produto, PRODUTOS_PRECOS.PRECO1 as preco, sum(FATURAMENTO_PROD.qtde) as qtde , sum(FATURAMENTO_PROD.valor) as valor,
	SUM(F1) AS F1,SUM(F2) AS F2,SUM(F3) AS F3,SUM(F4) AS F4,SUM(F5) AS F5,
	SUM(F6) AS F6,SUM(F7) AS F7,SUM(F8) AS F8,SUM(F9) AS F9,SUM(F10) AS F10,
	SUM(F11) AS F11,SUM(F12) AS F12,SUM(F13) AS F13,SUM(F14) AS F14,SUM(F15) AS F15,
	SUM(F16) AS F16,SUM(F17) AS F17,SUM(F18) AS F18,SUM(F19) AS F19,SUM(F20) AS F20
	from FATURAMENTO_PROD   
		left join produtos 
			on FATURAMENTO_PROD.produto = produtos.produto
		inner join PRODUTOS_PRECOS 
		on FATURAMENTO_PROD.produto = PRODUTOS_PRECOS.produto and PRODUTOS_PRECOS.CODIGO_TAB_PRECO= '02'

	where nF_SAIDA in ('0073499') 
	group by produtos.REFER_FABRICANTE, produtos.DESC_PRODUTO, produtos.unidade,produtos.grade, produtos.PONTEIRO_PRECO_TAM, FATURAMENTO_PROD.produto, PRODUTOS_PRECOS.PRECO1
ENDTEXT

F_SELECT(x,'TMPPROD')


x = 0
y=''
*0001

SELECT TMPPROD
SCAN

	x=x+1
	y= RIGHT('00000'+alltrim(STR(x)),4)



	SELECT V_faturamento_05_item 
	APPEND BLANK
	
	replace V_faturamento_05_item.codigo_ITEM		 	with  	TMPPROD.produto 
	
	o_100102.lx_FORM1.lx_pageframe1.page3.lX_GRID_FILHA1.COL_TX_CODIGO_ITEM.Tx_CODIGO_ITEM.l_desenhista_recalculo()
	
	SELECT V_faturamento_05_item 
	replace V_faturamento_05_item.qtde_ITEM		 	with  TMPPROD.QTDE
	o_100102.lx_FORM1.lx_pageframe1.page3.lX_GRID_FILHA1.coL_TX_QTDE_ITEM.tx_QTDE_ITEM.l_desenhista_recalculo()
	
	
	SELECT V_faturamento_05_item 
	replace V_faturamento_05_item.preco_unitario      with TMPPROD.preco	
	
	
	replace V_faturamento_05_item.valor_item       	with TMPPROD.preco	* TMPPROD.QTDE
	o_100102.lx_FORM1.lx_pageframe1.page3.lX_GRID_FILHA1.col_tx_PRECO_UNITARIO.tx_PRECO_UNITARIO.l_desenhista_recalculo()

	SELECT V_faturamento_05_item 
	
	replace Item_impressao WITH y
	replace cod_tabela_filha 	 	with  	'R'

	replace sub_Item_tamanho 	WITH 0
	replace DESCRICAO_ITEM 		with TMPPROD.DESC_PRODUTO
	
	replace gerar_imposto 		with .t.
	replace nao_soma_valor 		with .f.
	replace possui_subs_tributaria 		with .f.
	replace nao_fatura 		with .f.
	replace faixa 		with '1'
	



	*replace TRIBUT_ICMS		 	with  	TMPPROD.produto 
	*replace TRIBUT_ORIGEM		 	with  	TMPPROD.produto 
	*replace classif_fiscal		 	with  	TMPPROD.produto 
	*replace conta_contabil		 	with  	TMPPROD.produto 
	
	*replace porcentagem_item_rateio		 	with  	TMPPROD.produto 
	*replace codigo_fiscal_operacao		 	with  	TMPPROD.produto 
	
	replace peso		 	with  	0
	replace desconto_item		 	with  	0
	*replace codigo_fiscal_operacao		 	with  	TMPPROD.produto 

	
	*replace codigo_ITEM		 	with  	TMPPROD.unidade 
	
	



	SELECT TMPPROD
ENDSCAN