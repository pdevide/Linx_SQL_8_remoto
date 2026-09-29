TEXT TO  cmdsql NOSHOW TEXTMERGE

SELECT  FILIAIS.COD_FILIAL AS COD_FILIAL	
		,cm_estoque_pa.FILIAL AS FILIAL
		,cm_estoque_pa.DATA_SALDO AS DATA_SALDO
		,PRODUTOS.CONTA_CONTABIL	
		/*,DESC_CONTA	*/
		,cm_estoque_pa.PRODUTO AS CODIGO_MERCADORIA	
		,PRODUTOS.TRIBUT_ORIGEM AS ORIGEM	
		,cm_estoque_pa.COR_PRODUTO	AS COR_PRODUTO
		,DESC_PRODUTO	
		,PRODUTOS.CLASSIF_FISCAL	
		,UNIDADE	
		,cm_estoque_pa.QTDE_SALDO AS QTDE_SALDO	
		,cm_estoque_pa.CUSTO_MEDIO_UNITARIO	AS CUSTO_MEDIO_UNITARIO
		,cm_estoque_pa.VALOR_SALDO AS VALOR_SALDO


FROM   cm_estoque_pa 
       INNER JOIN cm_fechamento_custo_medio 
               ON cm_estoque_pa.cod_custo_medio = 
                  cm_fechamento_custo_medio.cod_custo_medio 
       INNER JOIN produtos 
               ON cm_estoque_pa.produto = produtos.produto 
       LEFT JOIN produto_cores 
              ON cm_estoque_pa.produto = produto_cores.produto 
                 AND cm_estoque_pa.cor_produto = produto_cores.cor_produto 
       LEFT JOIN cm_fechamento_custo_medio AS CUSTO_MEDIO_ANTERIOR 
              ON cm_fechamento_custo_medio.cod_custo_medio_anterior = 
                 CUSTO_MEDIO_ANTERIOR.cod_custo_medio 
       LEFT JOIN cm_estoque_pa AS CUSTO_MEDIO_ANTERIOR_ITENS 
              ON CUSTO_MEDIO_ANTERIOR_ITENS.cod_custo_medio = 
                           CUSTO_MEDIO_ANTERIOR.cod_custo_medio 
                 AND CUSTO_MEDIO_ANTERIOR_ITENS.produto = cm_estoque_pa.produto 
                 AND CUSTO_MEDIO_ANTERIOR_ITENS.cor_produto = 
                     cm_estoque_pa.cor_produto 
                 AND CUSTO_MEDIO_ANTERIOR_ITENS.filial = cm_estoque_pa.filial 
                 AND CUSTO_MEDIO_ANTERIOR_ITENS.data_saldo = 
                     CUSTO_MEDIO_ANTERIOR.data_saldo 
       LEFT JOIN filiais 
              ON cm_estoque_pa.filial = filiais.filial 
WHERE  filiais.matriz IN ( 'MATRIZ' ) and cm_estoque_pa.COD_CUSTO_MEDIO = '202101'
		AND 
		(EXISTS(SELECT 1 FROM ESTOQUE_PROD1_ENT B 
				INNER JOIN ESTOQUE_PROD_ENT A ON A.ROMANEIO_PRODUTO = B.ROMANEIO_PRODUTO AND A.FILIAL=B.FILIAL
				WHERE B.PRODUTO = CM_ESTOQUE_PA.produto AND A.EMISSAO BETWEEN '20210101' AND '20210131')
		OR
		EXISTS(SELECT 1 FROM LOJA_VENDA_PRODUTO B WHERE DATA_VENDA BETWEEN '20210101' AND '20210131' AND 
					B.PRODUTO = CM_ESTOQUE_PA.produto))


ORDER  BY cm_estoque_pa.filial, 
          cm_estoque_pa.produto, 
          cm_estoque_pa.cor_produto, 
          cm_estoque_pa.data_saldo 

ENDTEXT
f_select(cmdsql, "result1")

