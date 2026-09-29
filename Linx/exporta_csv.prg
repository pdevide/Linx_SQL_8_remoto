SET SYSMENU TO default
SET DEFAULT TO c:\temp

TEXT TO cmdsql NOSHOW TEXTMERGE
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

		/*cm_estoque_pa.data_saldo, 
       CUSTO_MEDIO_ANTERIOR.data_saldo                            AS 
       DATA_ANTERIOR, 
       cm_estoque_pa.cod_custo_medio, 
       cm_fechamento_custo_medio.desc_custo_medio, 
       cm_estoque_pa.produto, 
       produtos.desc_produto, 
       cm_estoque_pa.cor_produto, 
       produto_cores.desc_cor_produto, 
       cm_estoque_pa.filial, 
       cm_estoque_pa.qtde_saldo, 
       cm_estoque_pa.custo_medio_unitario, 
       Isnull(CUSTO_MEDIO_ANTERIOR_ITENS.custo_medio_unitario, 0) AS 
       CUSTO_MEDIO_UNITARIO_ANTERIOR, 
       cm_estoque_pa.valor_saldo, 
       cm_estoque_pa.qtde_stk_proprio, 
       cm_estoque_pa.valor_stk_proprio, 
       cm_estoque_pa.qtde_stk_com_terc, 
       cm_estoque_pa.valor_stk_com_terc, 
       cm_estoque_pa.qtde_stk_de_terc, 
       cm_estoque_pa.valor_stk_de_terc, 
       cm_fechamento_custo_medio.empresa, 
       cm_fechamento_custo_medio.perc_ajuste, 
       produtos.grupo_produto, 
       produtos.material, 
       produtos.subgrupo_produto, 
       produtos.modelista, 
       produtos.tipo_produto, 
       produtos.modelagem, 
       produtos.cartela, 
       produtos.colecao, 
       produtos.periodo_pcp, 
       produtos.grade, 
       produtos.tabela_operacoes, 
       produtos.linha, 
       produtos.tabela_medidas, 
       produtos.griffe, 
       produtos.fabricante, 
       produtos.estilista, 
       produtos.refer_fabricante, 
       cm_fechamento_custo_medio.matriz_fiscal, 
       filiais.matriz                                             AS 
       FILIAL_MATRIZ_CONTABIL, 
       filiais.matriz_fiscal                                      AS 
       FILIAL_MATRIZ_FISCAL, 
       CONVERT(BIT, 0)                                            AS 
       UTILIZA_MATRIZ_FISCAL, 
       ( CASE 
           WHEN CUSTO_MEDIO_ANTERIOR.data_saldo IS NOT NULL THEN 
           Dateadd(day, 1, CUSTO_MEDIO_ANTERIOR.data_saldo) 
           ELSE NULL 
         END )                                                    AS DATA_CARDEX 
       , 
       cm_fechamento_custo_medio.data_saldo                       AS 
       DATA_FECHAMENTO */
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
WHERE  filiais.matriz IN ( 'MATRIZ' ) and cm_estoque_pa.COD_CUSTO_MEDIO = '202102'
ORDER  BY cm_estoque_pa.filial, 
          cm_estoque_pa.produto, 
          cm_estoque_pa.cor_produto, 
          cm_estoque_pa.data_saldo 
ENDTEXT
f_select(cmdsql,"vbaseprod")

arquivo_saida = "saida_"+DTOS(DATE())+".csv"
arquivo_cabec = "cabecalho_"+DTOS(DATE())+".txt"
arquivo_final = "relatorio_custo_medio_2021_Fev_"+DTOS(DATE())+".csv"

*lcCabec = [Codigo_barra;Produto;Cor_produto;Tamanho;Grade;Inativo;DESCRICAO]&&+CHR(13)+CHR(10)
lcCabec = ""
=AFIELDS(laColumns, "vbaseprod")
FOR itt = 1 TO ALEN(laColumns,1)
	lcCabec = lcCabec + laColumns[itt,1] + ";"
ENDFOR
lcCabec  = LEFT(lcCabec, LEN(lcCabec) -1)

STRTOFILE(lcCabec,arquivo_cabec)

WAIT WINDOW "Gerando arquivo..." nowait
SELECT vbaseprod

CREATE CURSOR saida_csv (texto C(162) null)
APPEND BLANK
replace texto WITH lcCabec

SELECT vbaseprod
COPY TO &arquivo_saida. DELIMITED WITH CHARACTER ";" WITH ""
SELECT saida_csv
APPEND FROM &arquivo_saida. TYPE sdf
SET DEFAULT TO c:\temp

GO top
COPY TO &arquivo_final. TYPE sdf
 
*!*	lcDosCommand = "geracsv "+arquivo_cabec+" "+arquivo_saida+" "+arquivo_final
*!*	RUN /N &lcDosCommand.
MESSAGEBOX("Arquivo gerado - c:\temp\"+arquivo_final, 64,"Aviso")
