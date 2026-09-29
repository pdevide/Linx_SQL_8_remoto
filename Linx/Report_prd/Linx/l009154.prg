*====================================================================================================================================================*
*== 30/06/2015 - Barbara Lima - TP 9129806 - #1# - Incluir "use in" no cursor Cur_Result3
*====================================================================================================================================================*
*== Funções para os Relatórios da Tela 009154 (Kardex + Modelo 3)
*== Custo Médio Linx (Valmir/Cestari/Douglas/Banin: Maio-2009)
*== Ajustes devido melhorias na tela (Valmir/Cestari: Abr-2011)
*====================================================================================================================================================*
FUNCTION Fx_009154_Init_Kardex
	LPARAMETERS pShowOpt_CM,pProcAgr
	PUBLIC xPor_MF 
	
	xPor_MF =.f.
	
	f_Wait('Aguarde...')
	
	SELECT Distinct data_anterior as data_cardex,data_fechamento,data_saldo,data_anterior,cod_custo_medio ;
	  FROM V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_PA WHERE data_saldo=data_fechamento INTO CURSOR Cur_Chk_Data_Saldo

	IF RECCOUNT('Cur_Chk_Data_Saldo')>1
		MESSAGEBOX('Recomendado Filtrar Apenas UM Custo Médio (mais rápido)',48,'Aviso')
		f_Wait()
		RETURN .f.
	ENDIF

	IF pShowOpt_CM
		f_Wait()
		System.ExecuteFormModal('LxOprel_009154_Filtros') && Retorna: OpRelCardex
	ELSE
		OpRelCardex = .f.
	ENDIF

	*--
		IF USED('vTMP_Estoque_Cardex') && Limpa antes
			SELECT vTMP_Estoque_Cardex
			USE 
		ENDIF

		IF USED('vTMP_Fechamento_Custo_Medio') && Limpa antes
			SELECT vTMP_Fechamento_Custo_Medio
			USE 
		ENDIF

	*--
		SELECT Cur_Chk_Data_Saldo
		p_TReg = ALLTRIM(STR(ABS(RecCount())))
		SCAN 	
			p_RAtu = ALLTRIM(STR(ABS(RECNO())))
			WAIT WINDOW 'Aguarde Processando Custo Médio: '+ALLTRIM(Cur_Chk_Data_Saldo.cod_custo_medio) +  ' (' + p_RAtu+'/'+p_TReg + ')' NOWAIT 

			IF OpRelCardex
				=Fx_Carga_Cardex_Por_CM()
			ELSE
				=Fx_Carga_Cardex(pProcAgr)
			ENDIF

		ENDSCAN 
		WAIT CLEAR

	*--
	
	f_Wait('Aguarde... (Gerando Cursores)')
	SELECT vTMP_Estoque_Cardex 
		REPLACE ALL op_ped_roman 			WITH '' FOR ISNULL(op_ped_roman)
		REPLACE ALL doc 					WITH '' FOR ISNULL(doc)
		REPLACE ALL item_composicao 		WITH '' FOR ISNULL(item_composicao)
		REPLACE ALL desc_item_composicao 	WITH '' FOR ISNULL(desc_item_composicao)
		REPLACE ALL valor_base_ipi 			WITH 0  FOR ISNULL(valor_base_ipi)
		REPLACE ALL data_anterior			WITH {} FOR ISNULL(data_anterior)
		REPLACE ALL desc_cor_produto		WITH '' FOR ISNULL(desc_cor_produto)
		REPLACE ALL cor_produto				WITH '_' FOR ISNULL(cor_produto)
		
		GO top
		
		&&##
		*!*			xPor_MF = por_matriz_fiscal
		*!*			IF pProcAgr
		*!*				xOrder = 'cod_custo_medio,matriz_contabil,' + IIF(xPor_MF,'','cod_matriz_fiscal,') + 'conta_contabil_estoque,produto,cor_produto,emissao,item_composicao'
		*!*			ELSE
		*!*				 xOrder = 'cod_custo_medio,matriz_contabil,' + IIF(xPor_MF,'','cod_matriz_fiscal,') + 'conta_contabil_estoque,produto,cor_produto,emissao,item_composicao'
		*!*			ENDIF

		xOrder = 'cod_custo_medio,matriz_contabil,cod_matriz_fiscal,conta_contabil_estoque,produto,cor_produto,emissao,item_composicao'
		&&##

		xFatorEnt = [IIF(!INLIST(item_composicao,'000','999') and fator_est_proprio>0 AND ES<>'-',1,iif(!INLIST(item_composicao,'000','999') and ES='-' and Mv_Tot>0,1,0))]
		xFatorSai = [IIF(!INLIST(item_composicao,'000','999') and fator_est_proprio<0 AND ES<>'-',1,iif(!INLIST(item_composicao,'000','999') and ES='-' and Mv_Tot<0,1,0))]

		SELECT cod_custo_medio,;
			   matriz_contabil,Razao_social_MC,cgc_cpf_MC,matriz_fiscal,por_matriz_fiscal,Razao_social_MF,cod_matriz_fiscal,cnpj_matriz_fiscal,;
			   filial,cod_filial,CGC_CPF,RG_IE,conta_contabil_estoque,desc_conta_estoque,;
			   produto,cor_produto,desc_produto,grupo_produto,subgrupo_produto,desc_cor_produto,Unidade,classif_fiscal, ;
			   emissao,doc,op_ped_roman,item_composicao,conta_contabil_movto,desc_item_composicao,compoe_custo_medio,;
			   data_saldo,data_cardex,data_anterior,Especie_Serie,Serie_NF,CFOP,ES,;
			   00000000000 as Qtde_Ant,;
			   000000000000000.00 as Valor_ant,;
			   000000000000000.00 as Media_ant,;
			   00000000000 as Qtde_Ant_ini,;
			   000000000000000.00 as Valor_ant_ini,;
			   00000000000 as Qtde_Atu_fim,;
			   000000000000000.00 as Valor_atu_fim,;
			   000000000000000.00 as Media_Atu_Fim,;
			   sum(NVL(ABS(Mv_Tot),00000000000)*&xFatorEnt) 				as qtde_ent,;
			   sum(NVL(ABS(Valor_Estoque),000000000000000.00)*&xFatorEnt) 	as valor_ent,;
			   000000000000000.00 as Media_ent,;
			   sum(NVL(ABS(Mv_Tot),00000000000)*&xFatorSai) 				as qtde_sai,;
			   sum(NVL(ABS(Valor_Estoque),000000000000000.00)*&xFatorSai) 	as valor_sai,;
			   000000000000000.00   		as Media_Sai,;
			   00000000000 					as qtde_atual,;
			   000000000000000.00 			as valor_atual,;
			   000000000000000.00 			as Media_atual,;
			   sum(qtde_saldo_pai)  		as qtde_saldo_pai,;
			   sum(valor_saldo_pai) 		as valor_saldo_pai,;
			   SUM(valor_imposto_agregar)	as valor_imposto_agregar,;
			   SUM(Mv_Tot)					as Qtde_Mov,;
			   SUM(IIF(valor_base_ipi>0,valor_base_ipi,valor)) as Valor_Mov ;
	 	  FROM vTMP_Estoque_Cardex ;
	 	  WHERE ES<>'A' ;
	 	  GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37 ;
		 ORDER BY &xOrder INTO CURSOR Cur_Result_Base readwrite


	SELECT Cur_Chk_Data_Saldo
	SCAN 	
		IF pProcAgr
			=Fx_Proc_CM_if_Agr()
		ELSE
			=Fx_Proc_CM_if()
		ENDIF
	ENDSCAN 



	*-- Ordem:
		SELECT Cur_Result_Base
		GO TOP 

		DO whil !EOF()
			xK = (Cod_custo_medio+IIF(xPor_MF,'',ALLTRIM(cod_matriz_fiscal))+produto+Cor_produto)
		
			xValor_Atual = Valor_Atual
			x1a_vez = .t.
			SCAN WHILE (Cod_custo_medio+IIF(xPor_MF,'',ALLTRIM(cod_matriz_fiscal))+produto+Cor_produto) == xK
				IF !x1a_vez
					REPLACE valor_ant WITH xValor_Atual 
				ENDIF
				
				REPLACE valor_sai 	WITH qtde_sai * IIF(qtde_ant=0,0,ROUND(valor_ant/qtde_ant,2))
				REPLACE Valor_Atual WITH (Valor_Ant+Valor_Ent-ABS(Valor_Sai))

				xValor_Atual = Valor_Atual
				x1a_vez = .f.
			ENDSCAN 
		ENDDO

	
	*-----------------------------------------------------------------------------------------------------------------------------------------------------*

	*--- Totais
	f_Wait('Aguarde... (Gerando Totais)')

	xFields = 'sum(Qtde_Ant_Ini) Qtde_Ant,sum(Valor_Ant_Ini) Valor_Ant,000000000000000.00 as Media_Ant,'+;
			  'sum(Qtde_Atu_Fim) Qtde_Atu_Fim,sum(Valor_Atu_Fim) Valor_Atu_Fim,000000000000000.00 as Media_Atu_Fim,'+;
		      'sum(Qtde_Ent) Qtde_Ent,sum(Valor_Ent) Valor_Ent,000000000000000.00 as Media_Ent,'+;
		      'sum(Qtde_Sai) Qtde_Sai,sum(Valor_Sai) Valor_Sai,000000000000000.00 as Media_Sai,'+;
		      'sum(qtde_saldo_pai) qtde_saldo_pai,sum(valor_saldo_pai) valor_saldo_pai,'+;
		      '00000000000 Qtde_Atual,000000000000000.00 Valor_Atual,000000000000.00 as Media_Atual'


	SELECT cod_custo_medio,matriz_contabil,&xFields 																	FROM Cur_Result_Base GROUP BY 1,2 				INTO CURSOR Cur_Result_Tot_MC 		ReadWrite
	SELECT cod_custo_medio,matriz_contabil,IIF(xPor_MF,'',matriz_fiscal) matriz_fiscal,&xFields 						FROM Cur_Result_Base GROUP BY 1,2,3 			INTO CURSOR Cur_Result_Tot_MF 		ReadWrite
	SELECT cod_custo_medio,matriz_contabil,IIF(xPor_MF,'',matriz_fiscal) matriz_fiscal,filial,&xFields 					FROM Cur_Result_Base GROUP BY 1,2,3,4 			INTO CURSOR Cur_Result_Tot_Fil 		ReadWrite

	IF pProcAgr
		SELECT cod_custo_medio,matriz_contabil,conta_contabil_estoque,&xFields 					 						FROM Cur_Result_Base GROUP BY 1,2,3 			INTO CURSOR Cur_Result_Tot_Conta 	ReadWrite
		SELECT cod_custo_medio,matriz_contabil,conta_contabil_estoque,produto,&xFields 			 						FROM Cur_Result_Base GROUP BY 1,2,3,4 			INTO CURSOR Cur_Result_Tot_Prod 	ReadWrite
		SELECT cod_custo_medio,matriz_contabil,conta_contabil_estoque,produto,cor_produto,&xFields 						FROM Cur_Result_Base GROUP BY 1,2,3,4,5 		INTO CURSOR Cur_Result_Tot_Cor 		ReadWrite
	ELSE
		SELECT cod_custo_medio,matriz_contabil,IIF(xPor_MF,'',matriz_fiscal) matriz_fiscal,IIF(xPor_MF,'',cod_matriz_fiscal) cod_matriz_fiscal,conta_contabil_estoque,&xFields 						FROM Cur_Result_Base GROUP BY 1,2,3,4,5 		INTO CURSOR Cur_Result_Tot_Conta 	ReadWrite
		SELECT cod_custo_medio,matriz_contabil,IIF(xPor_MF,'',matriz_fiscal) matriz_fiscal,IIF(xPor_MF,'',cod_matriz_fiscal) cod_matriz_fiscal,conta_contabil_estoque,produto,&xFields 				FROM Cur_Result_Base GROUP BY 1,2,3,4,5,6 		INTO CURSOR Cur_Result_Tot_Prod 	ReadWrite
		SELECT cod_custo_medio,matriz_contabil,IIF(xPor_MF,'',matriz_fiscal) matriz_fiscal,IIF(xPor_MF,'',cod_matriz_fiscal) cod_matriz_fiscal,conta_contabil_estoque,produto,cor_produto,&xFields 	FROM Cur_Result_Base GROUP BY 1,2,3,4,5,6,7 	INTO CURSOR Cur_Result_Tot_Cor 	ReadWrite
	ENDIF

	SELECT * FROM Cur_Result_Base WHERE !INLIST(item_composicao, '000', '199', '299', '399', '499', '899', '999') ORDER BY &xOrder INTO CURSOR Cur_Result READWRITE 

	*--- Calculos das Médias
	FOR k = 1 TO 7
		IF k=1
			SELECT Cur_Result
		ELSE
			DO case
			case k=2
				SELECT Cur_Result_Tot_MC 
			case k=3
				SELECT Cur_Result_Tot_MF 
			case k=4
				SELECT Cur_Result_Tot_Fil 
			case k=5
				SELECT Cur_Result_Tot_Conta 
			case k=6
				SELECT Cur_Result_Tot_Prod 
			case k=7
				SELECT Cur_Result_Tot_Cor 
			ENDCASE
			REPLACE ALL Qtde_Atual WITH (Qtde_Ant+Qtde_Ent-Qtde_Sai), Valor_Atual WITH (Valor_Ant+Valor_Ent-Valor_Sai)
		ENDIF
		
		REPLACE ALL Media_Ant WITH IIF(Qtde_Ant=0,0,ROUND(ABS(Valor_Ant)/ABS(Qtde_Ant),2)),;
					Media_Ent WITH IIF(Qtde_Ent=0,0,ROUND(ABS(Valor_Ent)/ABS(Qtde_Ent),2)),;
					Media_Sai WITH IIF(Qtde_Sai=0,0,ROUND(ABS(Valor_Sai)/ABS(Qtde_Sai),2)),;
					Media_Atual WITH IIF(Qtde_Atual=0,0,ROUND(ABS(Valor_Atual)/ABS(Qtde_Atual),2)),;
					Media_Atu_Fim WITH IIF(Qtde_Atu_fim=0,0,ROUND(ABS(Valor_atu_fim)/ABS(Qtde_Atu_fim),2))
	ENDFOR
	*-----------------------------------------------------------------------------------------------------------------------------------------------------*

	*--- Relation-Comum
	SELECT Cur_Result_Tot_MC 
		INDEX ON cod_custo_medio+matriz_contabil TAG iTCust
	SELECT Cur_Result_Tot_MF 
		INDEX ON cod_custo_medio+matriz_contabil+matriz_fiscal TAG iTFil
	SELECT Cur_Result_Tot_Fil 
		INDEX ON cod_custo_medio+matriz_contabil+matriz_fiscal+filial TAG iTProd

	SELECT Cur_Chk_Data_Saldo
		INDEX ON cod_custo_medio TAG iLstCM
	
	SELECT Cur_Result
		SET RELATION TO cod_custo_medio+matriz_contabil													INTO Cur_Result_Tot_MC 	
		SET RELATION TO cod_custo_medio+matriz_contabil+matriz_fiscal									INTO Cur_Result_Tot_MF 		ADDITIVE 
		SET RELATION TO cod_custo_medio+matriz_contabil+matriz_fiscal+filial							INTO Cur_Result_Tot_Fil 	ADDITIVE 
		SET RELATION TO cod_custo_medio																	INTO Cur_Chk_Data_Saldo		ADDITIVE 

	*--- Relation-Dif
	IF pProcAgr
		SELECT Cur_Result_Tot_Conta 
			INDEX ON cod_custo_medio+matriz_contabil+conta_contabil_estoque TAG iTConta
		SELECT Cur_Result_Tot_Prod 
			INDEX ON cod_custo_medio+matriz_contabil+conta_contabil_estoque+produto TAG iTRProd
		SELECT Cur_Result_Tot_Cor 
			INDEX ON cod_custo_medio+matriz_contabil+conta_contabil_estoque+produto+cor_produto TAG iTCor

		SELECT Cur_Result
			SET RELATION TO cod_custo_medio+matriz_contabil+conta_contabil_estoque						INTO Cur_Result_Tot_Conta 	ADDITIVE 
			SET RELATION TO cod_custo_medio+matriz_contabil+conta_contabil_estoque+produto 				INTO Cur_Result_Tot_Prod 	ADDITIVE 
			SET RELATION TO cod_custo_medio+matriz_contabil+conta_contabil_estoque+produto+cor_produto 	INTO Cur_Result_Tot_Cor 	ADDITIVE 
	ELSE

		SELECT Cur_Result_Tot_Conta 
			INDEX ON cod_custo_medio+matriz_contabil+IIF(xPor_MF,'',cod_matriz_fiscal)+conta_contabil_estoque TAG iTConta
		SELECT Cur_Result_Tot_Prod 
			INDEX ON cod_custo_medio+matriz_contabil+IIF(xPor_MF,'',cod_matriz_fiscal)+conta_contabil_estoque+produto TAG iTRProd
		SELECT Cur_Result_Tot_Cor 
			INDEX ON cod_custo_medio+matriz_contabil+IIF(xPor_MF,'',cod_matriz_fiscal)+conta_contabil_estoque+produto+cor_produto TAG iTCor

		SELECT Cur_Result
			SET RELATION TO cod_custo_medio+matriz_contabil+IIF(xPor_MF,'',cod_matriz_fiscal)+conta_contabil_estoque						INTO Cur_Result_Tot_Conta 	ADDITIVE 
			SET RELATION TO cod_custo_medio+matriz_contabil+IIF(xPor_MF,'',cod_matriz_fiscal)+conta_contabil_estoque+produto 				INTO Cur_Result_Tot_Prod 	ADDITIVE 
			SET RELATION TO cod_custo_medio+matriz_contabil+IIF(xPor_MF,'',cod_matriz_fiscal)+conta_contabil_estoque+produto+cor_produto 	INTO Cur_Result_Tot_Cor 	ADDITIVE 
	ENDIF
	
	f_wait()
	
	SELECT Cur_Result
	GO top

	IF EOF()
		MESSAGEBOX('Nenhum Item Fiscal Selecionado...',48,'Aviso')
	ENDIF
	
ENDFUNC
*====================================================================================================================================================*



*====================================================================================================================================================*
FUNCTION Fx_Carga_Cardex
	LPARAMETERS pProcAgr

	*-- Cardex ( Processa Geral % para melhor performance )
	f_Wait('Aguarde... (Processando Cardex)')

	xDatai = Cur_Chk_Data_Saldo.DATA_CARDEX
	xDataf = Cur_Chk_Data_Saldo.DATA_SALDO
	xCodCM = ALLTRIM(Cur_Chk_Data_Saldo.cod_custo_medio)
	
	TEXT TO lcSelect TEXTMERGE NOSHOW PRETEXT 8
		  SELECT ?Cur_Chk_Data_Saldo.cod_custo_medio  AS cod_custo_medio,
				 Convert(datetime,?Cur_Chk_Data_Saldo.DATA_SALDO)  	   AS data_saldo,
				 Convert(datetime,?Cur_Chk_Data_Saldo.DATA_FECHAMENTO) AS data_fechamento,
				 Convert(datetime,?Cur_Chk_Data_Saldo.DATA_ANTERIOR)   AS data_anterior,
				 Convert(datetime,?Cur_Chk_Data_Saldo.data_cardex)	   AS data_cardex,
			     FILIAIS.MATRIZ as matriz_contabil,Cad_MC.Razao_social as Razao_social_MC,Cad_MC.cgc_cpf as cgc_cpf_MC,
			     Cad_MF.Razao_social as Razao_social_MF,
			     FILIAIS.COD_FILIAL,Cad_FL.RG_IE,Cad_FL.CGC_CPF,
			     PRODUTOS.DESC_PRODUTO,PRODUTOS.GRUPO_PRODUTO, PRODUTOS.SUBGRUPO_PRODUTO,
			     PRODUTO_CORES.DESC_COR_PRODUTO,CM_ITEM_COMPOSICAO.INDICA_ENTRADA_SAIDA AS ES,CM_ITEM_COMPOSICAO.fator_est_proprio,
				CARDEX.ITEM_COMPOSICAO, CM_ITEM_COMPOSICAO.DESC_ITEM_COMPOSICAO, CARDEX.DATA_MOV AS EMISSAO, CARDEX.DOC, CARDEX.SERIE_NF, CARDEX.ESPECIE_SERIE, CARDEX.PRODUTO, CARDEX.COR_PRODUTO, CARDEX.FILIAL, CARDEX.OP_PED_ROMAN, CM_ITEM_COMPOSICAO.COMPOE_CUSTO_MEDIO, 
				CARDEX.VALOR, CARDEX.VALOR_ENCARGO, CARDEX.VALOR_DESCONTO, CARDEX.VALOR_ENCARGO_IMPORTACAO, CARDEX.VALOR_IMPOSTO_DESTACAR, CARDEX.VALOR_IMPOSTO_AGREGAR, CARDEX.VALOR_FRETE, CARDEX.VALOR_SEGURO, CARDEX.VALOR_FRETE_TRANSPORTADORA, CARDEX.VALOR_DESPESAS, CARDEX.VALOR_LIQ, CARDEX.VALOR_PRODUCAO, 
				CARDEX.VALOR_ESTOQUE, CARDEX.VALOR_BASE_IPI, CARDEX.VALOR_IPI, CARDEX.CONTA_CONTABIL_ESTOQUE, CONTA_ESTOQUE.DESC_CONTA AS DESC_CONTA_ESTOQUE, CARDEX.CONTA_CONTABIL_MOVTO, CONTA_MOVTO.DESC_CONTA AS DESC_CONTA_MOVTO, CARDEX.RATEIO_FILIAL, CTB_FILIAL_RATEIO.DESC_RATEIO_FILIAL, CARDEX.RATEIO_CENTRO_CUSTO, CTB_CENTRO_CUSTO_RATEIO.DESC_RATEIO_CENTRO_CUSTO, CARDEX.FILIAL_ORIGINAL, 
				CARDEX.QTDE AS MV_TOT, CARDEX.CFOP, CARDEX.DESCRICAO_CFOP, CARDEX.UNIDADE, CARDEX.CLASSIF_FISCAL, CLASSIF_FISCAL.DESC_CLASSIFICACAO, CARDEX.MATRIZ_FISCAL, FILIAIS.CGC_CPF AS CNPJ_MATRIZ_FISCAL, FILIAIS.COD_FILIAL AS COD_MATRIZ_FISCAL 
		    FROM DBO.FX_CM_MONTA_CARDEX_PA('%','%', ?Cur_Lst_filial.filial, ?xDatai, ?xDataf, 0,?xCodCM) AS CARDEX 
		   INNER JOIN CM_ITEM_COMPOSICAO ON CARDEX.ITEM_COMPOSICAO = CM_ITEM_COMPOSICAO.ITEM_COMPOSICAO 
		    LEFT JOIN CTB_CONTA_PLANO AS CONTA_ESTOQUE ON CARDEX.CONTA_CONTABIL_ESTOQUE = CONTA_ESTOQUE.CONTA_CONTABIL 
		    LEFT JOIN CTB_CONTA_PLANO AS CONTA_MOVTO ON CARDEX.CONTA_CONTABIL_MOVTO = CONTA_MOVTO.CONTA_CONTABIL 
		    LEFT JOIN CTB_FILIAL_RATEIO ON CARDEX.RATEIO_FILIAL = CTB_FILIAL_RATEIO.RATEIO_FILIAL 
		    LEFT JOIN CTB_CENTRO_CUSTO_RATEIO ON CARDEX.RATEIO_CENTRO_CUSTO = CTB_CENTRO_CUSTO_RATEIO.RATEIO_CENTRO_CUSTO 
		   INNER JOIN CLASSIF_FISCAL ON CARDEX.CLASSIF_FISCAL = CLASSIF_FISCAL.CLASSIF_FISCAL 
		   INNER JOIN FILIAIS ON CARDEX.MATRIZ_FISCAL = FILIAIS.FILIAL 
			left join CADASTRO_CLI_FOR Cad_FL ON FILIAIS.FILIAL=Cad_FL.NOME_CLIFOR
			left join CADASTRO_CLI_FOR Cad_MC ON FILIAIS.MATRIZ=Cad_MC.NOME_CLIFOR
			left join CADASTRO_CLI_FOR Cad_MF ON FILIAIS.MATRIZ_FISCAL=Cad_MF.NOME_CLIFOR
			left join PRODUTOS ON CARDEX.PRODUTO=PRODUTOS.PRODUTO
			left join PRODUTO_CORES ON CARDEX.PRODUTO=PRODUTO_CORES.PRODUTO AND CARDEX.COR_PRODUTO=PRODUTO_CORES.COR_PRODUTO
		   Where CM_ITEM_COMPOSICAO.Indica_Entrada_Saida<>'A'
		  ORDER BY CARDEX.FILIAL_ORIGINAL
	ENDTEXT 


	SELECT V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_PA 
		LOCATE FOR ALLTRIM(cod_custo_medio)=xCodCM AND data_fechamento=xDataf 
		xPorCor = !f_Vazio(Cor_Produto) && Identifica que foi gerado por cor
		
	xSl_Cur = " a.*,b.filial_matriz_fiscal as por_matriz_fiscal, b.qtde_saldo AS qtde_saldo_pai,b.valor_saldo AS valor_saldo_pai,000000000000000.00 Custo_Recalculado "+;
			  "  FROM vTMP_Estoque_Cardex_Base a "+;
			  "  JOIN V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_PA b ON a.cod_custo_medio=b.cod_custo_medio AND a.filial=b.filial and b.data_fechamento=b.data_saldo"+;
			  "   AND a.produto=b.produto " + IIF(xPorCor," and a.cor_produto=b.cor_produto","")+;
			  IIF(TYPE('OpRelPorCta')='L' and OpRelPorCta," Where conta_contabil_estoque='" + OpRelCtaEst + "'","")

	SELECT distinct Filial FROM V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_PA INTO CURSOR Cur_Lst_filial
	
	SELECT Cur_Lst_filial
	COUNT TO xTreg
	xRatu = 0
	SCAN 
		xRatu = xRatu + 1
		f_prog_bar('Aguarde.. Processando Cardex '+ CHR(13)+ 'Filial: ' + ALLTRIM(STR(xRatu))+' de '+ALLTRIM(STR(xTreg)) + ' > ' + ALLTRIM(Cur_Lst_filial.Filial),xRatu,xTreg)
		f_select(lcSelect,'vTMP_Estoque_Cardex_Base',ALIAS())

		IF !USED('vTMP_Estoque_Cardex')
			SELECT &xSl_Cur into cursor vTMP_Estoque_Cardex Readwrite
		ELSE
			INSERT INTO vTMP_Estoque_Cardex SELECT &xSl_Cur
		ENDIF
	ENDSCAN

	=Fx_Carga_CM_IniFim()
	=Fx_Add_Itens_Sem_Mov_Kardex(pProcAgr,xPorCor)

	SELECT vTMP_Estoque_Cardex
	IF !xPorCor
		REPLACE ALL Cor_Produto WITH '' FOR ALLTRIM(cod_custo_medio) == xCodCM
	ENDIF
	
	INDEX ON cod_custo_medio+produto+cor_produto+filial+item_composicao TAG iCardex
	DO whil !EOF()
		xK = cod_custo_medio+produto+cor_produto+filial
		SKIP
		SCAN WHILE cod_custo_medio+produto+cor_produto+filial == xK
			REPLACE qtde_saldo_pai WITH 0, valor_saldo_pai WITH 0
		ENDSCAN
	ENDDO

	f_wait()

ENDFUNC
*====================================================================================================================================================*



*====================================================================================================================================================*
FUNCTION Fx_Carga_Cardex_Por_CM
	xCodCM = ALLTRIM(Cur_Chk_Data_Saldo.cod_custo_medio)

	*-- Opção Somente Para Conferência
	TEXT TO xSel_Comp_CM TEXTMERGE NOSHOW PRETEXT 8
		SELECT Convert(datetime,?Cur_Chk_Data_Saldo.DATA_ANTERIOR) 	AS data_anterior,
			   Convert(datetime,?Cur_Chk_Data_Saldo.data_cardex)	AS data_cardex,
			   ?xCodCM	AS cod_custo_medio, 
				CM_ESTOQUE_PA_COMPOSICAO.ID_MOVIMENTO,
				CM_ESTOQUE_PA_COMPOSICAO.DATA_SALDO, CM_ESTOQUE_PA_COMPOSICAO.PRODUTO, CM_ESTOQUE_PA_COMPOSICAO.COR_PRODUTO, CM_ESTOQUE_PA_COMPOSICAO.FILIAL, CM_ITEM_COMPOSICAO.DESC_ITEM_COMPOSICAO, CM_ESTOQUE_PA_COMPOSICAO.ITEM_COMPOSICAO, CM_ESTOQUE_PA_COMPOSICAO.QTDE, 
				CM_ESTOQUE_PA_COMPOSICAO.VALOR,  null as valor_base_ipi,  
				CM_ITEM_COMPOSICAO.COMPOE_CUSTO_MEDIO, CTB_CONTA_PLANO.CONTA_CONTABIL, CTB_CONTA_PLANO.DESC_CONTA, CM_ESTOQUE_PA_COMPOSICAO.RATEIO_FILIAL, CTB_FILIAL_RATEIO.DESC_RATEIO_FILIAL, CM_ESTOQUE_PA_COMPOSICAO.RATEIO_CENTRO_CUSTO, CTB_CENTRO_CUSTO_RATEIO.DESC_RATEIO_CENTRO_CUSTO, 
				CTB_CONTA_PLANO_ESTOQUE.CONTA_CONTABIL AS CONTA_CONTABIL_ESTOQUE,CTB_CONTA_PLANO_ESTOQUE.DESC_CONTA AS desc_conta_estoque,
				CM_ITEM_COMPOSICAO.Indica_Entrada_Saida AS ES, CM_ITEM_COMPOSICAO.fator_est_proprio, CM_ESTOQUE_PA_COMPOSICAO.QTDE as Mv_Tot, CM_ESTOQUE_PA_COMPOSICAO.VALOR as Valor_Estoque,
			    FILIAIS.MATRIZ as matriz_contabil,Cad_MC.Razao_social as Razao_social_MC,Cad_MC.cgc_cpf as cgc_cpf_MC,Cad_MF.Razao_social as Razao_social_MF,
			    FILIAIS.COD_FILIAL,Cad_FL.RG_IE,Cad_FL.CGC_CPF,
			    FILIAIS.CGC_CPF AS CNPJ_MATRIZ_FISCAL, FILIAIS.COD_FILIAL as cod_matriz_fiscal,FILIAIS.MATRIZ_FISCAL,
				PRODUTOS.desc_produto,PRODUTOS.GRUPO_PRODUTO, PRODUTOS.SUBGRUPO_PRODUTO,
				PRODUTO_CORES.desc_cor_produto,PRODUTOS.unidade, PRODUTOS.classif_fiscal
		  FROM CM_ESTOQUE_PA_COMPOSICAO 
		 INNER JOIN FILIAIS ON CM_ESTOQUE_PA_COMPOSICAO.FILIAL = FILIAIS.FILIAL 
		 INNER JOIN CM_FECHAMENTO_CUSTO_MEDIO ON CM_ESTOQUE_PA_COMPOSICAO.COD_CUSTO_MEDIO = CM_FECHAMENTO_CUSTO_MEDIO.COD_CUSTO_MEDIO 
		 INNER JOIN PRODUTOS ON CM_ESTOQUE_PA_COMPOSICAO.PRODUTO = PRODUTOS.PRODUTO 
		  LEFT JOIN CTB_CONTA_PLANO AS CTB_CONTA_PLANO_ESTOQUE ON PRODUTOS.CONTA_CONTABIL = CTB_CONTA_PLANO_ESTOQUE.CONTA_CONTABIL 
		  LEFT JOIN CM_ITEM_COMPOSICAO ON CM_ITEM_COMPOSICAO.ITEM_COMPOSICAO = CM_ESTOQUE_PA_COMPOSICAO.ITEM_COMPOSICAO 
		  LEFT JOIN CTB_CONTA_PLANO ON CM_ESTOQUE_PA_COMPOSICAO.CONTA_CONTABIL = CTB_CONTA_PLANO.CONTA_CONTABIL 
		  LEFT JOIN CTB_FILIAL_RATEIO ON CM_ESTOQUE_PA_COMPOSICAO.RATEIO_FILIAL = CTB_FILIAL_RATEIO.RATEIO_FILIAL 
		  LEFT JOIN CTB_CENTRO_CUSTO_RATEIO ON CM_ESTOQUE_PA_COMPOSICAO.RATEIO_CENTRO_CUSTO = CTB_CENTRO_CUSTO_RATEIO.RATEIO_CENTRO_CUSTO 
		  left join PRODUTO_CORES ON CM_ESTOQUE_PA_COMPOSICAO.PRODUTO=PRODUTO_CORES.PRODUTO AND CM_ESTOQUE_PA_COMPOSICAO.COR_PRODUTO=PRODUTO_CORES.COR_PRODUTO
		  left join CADASTRO_CLI_FOR Cad_FL ON FILIAIS.FILIAL=Cad_FL.NOME_CLIFOR
		  left join CADASTRO_CLI_FOR Cad_MC ON FILIAIS.MATRIZ=Cad_MC.NOME_CLIFOR
		  left join CADASTRO_CLI_FOR Cad_MF ON FILIAIS.MATRIZ_FISCAL=Cad_MF.NOME_CLIFOR
		 WHERE CM_ESTOQUE_PA_COMPOSICAO.COD_CUSTO_MEDIO=?xCodCM
		 ORDER BY CM_ESTOQUE_PA_COMPOSICAO.DATA_SALDO, CM_ESTOQUE_PA_COMPOSICAO.ITEM_COMPOSICAO, CM_ESTOQUE_PA_COMPOSICAO.FILIAL, CM_ESTOQUE_PA_COMPOSICAO.PRODUTO, CM_ESTOQUE_PA_COMPOSICAO.COR_PRODUTO
	ENDTEXT 
	
	f_Wait('Aguarde... (Processando Kardex Pelo Custo Médio)')
		SELECT V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_PA
		LOCATE FOR ALLTRIM(cod_custo_medio)=xCodCM
		
	f_select(xSel_Comp_CM,'vTMP_Estoque_Cardex_Base',ALIAS())

	xSl_Cur = ' a.*,b.filial_matriz_fiscal as por_matriz_fiscal, a.Data_Saldo as Emissao,SPACE(1) as op_ped_roman,SPACE(1) as doc,'+;
			  '		 SPACE(1) as Especie_Serie,SPACE(1) as Serie_NF,SPACE(1) CFOP,'+;
			  '		 SPACE(1) as conta_contabil_movto,0 as valor_imposto_agregar,'+;
			  '	     b.qtde_saldo AS qtde_saldo_pai,b.valor_saldo AS valor_saldo_pai,000000000000000.00 Custo_Recalculado '+;
			  '  FROM vTMP_Estoque_Cardex_Base a '+;
			  '  JOIN V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_PA b ON a.cod_custo_medio=b.cod_custo_medio AND a.filial=b.filial '+;
			  '	  AND a.produto=b.produto and a.cor_produto=b.cor_produto and b.data_saldo = Cur_Chk_Data_Saldo.data_saldo '

	IF !USED('vTMP_Estoque_Cardex')
		SELECT &xSl_Cur into cursor vTMP_Estoque_Cardex Readwrite 
	ELSE
		INSERT INTO vTMP_Estoque_Cardex SELECT &xSl_Cur
	ENDIF

	=Fx_Carga_CM_IniFim()
	f_wait()
	
ENDFUNC
*====================================================================================================================================================*



*====================================================================================================================================================*
FUNCTION Fx_Carga_CM_IniFim
	xCodCM = ALLTRIM(Cur_Chk_Data_Saldo.cod_custo_medio)

	SELECT V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_PA
	LOCATE FOR ALLTRIM(cod_custo_medio)=xCodCM

	xReprocessarCM = .t. 		
 	IF USED('vTMP_Fechamento_Custo_Medio_Base') AND ALLTRIM(Cur_Chk_Data_Saldo.cod_custo_medio)==ALLTRIM(vTMP_Fechamento_Custo_Medio_Base.cod_custo_medio)
			xReprocessarCM = .f. 		
 	ENDIF

 	IF xReprocessarCM 
		f_Wait('Aguarde... (Processando Custos: 000 e 999)')

		*-- Saldo Inicial: Item_Composicao=000 | Saldo Final: Item_Composicao=999
		TEXT TO xSel_Comp_CM TEXTMERGE NOSHOW PRETEXT 8
			SELECT Convert(datetime,?Cur_Chk_Data_Saldo.DATA_ANTERIOR)   AS data_anterior,
				   Convert(datetime,?Cur_Chk_Data_Saldo.data_cardex)	 AS data_cardex,
				   ?xCodCM AS cod_custo_medio, 
					CM_ESTOQUE_PA_COMPOSICAO.ID_MOVIMENTO,
					CM_ESTOQUE_PA_COMPOSICAO.DATA_SALDO, CM_ESTOQUE_PA_COMPOSICAO.PRODUTO, CM_ESTOQUE_PA_COMPOSICAO.COR_PRODUTO, 
					CM_ESTOQUE_PA_COMPOSICAO.FILIAL, CM_ITEM_COMPOSICAO.DESC_ITEM_COMPOSICAO, CM_ESTOQUE_PA_COMPOSICAO.ITEM_COMPOSICAO, 
					CM_ITEM_COMPOSICAO.Indica_Entrada_Saida, 
					CTB_CONTA_PLANO_ESTOQUE.CONTA_CONTABIL AS CONTA_CONTABIL_ESTOQUE,CTB_CONTA_PLANO_ESTOQUE.DESC_CONTA AS desc_conta_estoque,
					FILIAIS.MATRIZ AS matriz_contabil,Cad_MC.Razao_social as Razao_social_MC,Cad_MC.cgc_cpf as cgc_cpf_MC,
							Cad_MF.Razao_social as Razao_social_MF,Cad_MF.cgc_cpf as cgc_cpf_MF,
						    FILIAIS.COD_FILIAL,Cad_FL.RG_IE,Cad_FL.CGC_CPF,
						    FILIAIS.CGC_CPF AS CNPJ_MATRIZ_FISCAL, FILIAIS.COD_FILIAL as cod_matriz_fiscal,FILIAIS.MATRIZ_FISCAL,
					CM_ESTOQUE_PA_COMPOSICAO.QTDE, CM_ESTOQUE_PA_COMPOSICAO.VALOR,  CM_ITEM_COMPOSICAO.COMPOE_CUSTO_MEDIO, 
					CTB_CONTA_PLANO.CONTA_CONTABIL, CTB_CONTA_PLANO.DESC_CONTA, CM_ESTOQUE_PA_COMPOSICAO.RATEIO_FILIAL, 
					CTB_FILIAL_RATEIO.DESC_RATEIO_FILIAL, CM_ESTOQUE_PA_COMPOSICAO.RATEIO_CENTRO_CUSTO, 
					CTB_CENTRO_CUSTO_RATEIO.DESC_RATEIO_CENTRO_CUSTO,
					PRODUTOS.desc_produto,PRODUTOS.GRUPO_PRODUTO, PRODUTOS.SUBGRUPO_PRODUTO,
					PRODUTO_CORES.desc_cor_produto,PRODUTOS.Unidade,PRODUTOS.classif_fiscal
			  FROM CM_ESTOQUE_PA_COMPOSICAO 
			 INNER JOIN FILIAIS ON CM_ESTOQUE_PA_COMPOSICAO.FILIAL = FILIAIS.FILIAL 
			 INNER JOIN CM_FECHAMENTO_CUSTO_MEDIO ON CM_ESTOQUE_PA_COMPOSICAO.COD_CUSTO_MEDIO = CM_FECHAMENTO_CUSTO_MEDIO.COD_CUSTO_MEDIO 
			  LEFT OUTER JOIN CM_ITEM_COMPOSICAO ON CM_ITEM_COMPOSICAO.ITEM_COMPOSICAO = CM_ESTOQUE_PA_COMPOSICAO.ITEM_COMPOSICAO 
			  LEFT OUTER JOIN CTB_CONTA_PLANO ON CM_ESTOQUE_PA_COMPOSICAO.CONTA_CONTABIL = CTB_CONTA_PLANO.CONTA_CONTABIL 
			  LEFT JOIN CTB_FILIAL_RATEIO ON CM_ESTOQUE_PA_COMPOSICAO.RATEIO_FILIAL = CTB_FILIAL_RATEIO.RATEIO_FILIAL 
			  LEFT JOIN CTB_CENTRO_CUSTO_RATEIO ON CM_ESTOQUE_PA_COMPOSICAO.RATEIO_CENTRO_CUSTO = CTB_CENTRO_CUSTO_RATEIO.RATEIO_CENTRO_CUSTO 
			  left join CADASTRO_CLI_FOR Cad_FL ON FILIAIS.FILIAL=Cad_FL.NOME_CLIFOR
			  left join CADASTRO_CLI_FOR Cad_MC ON FILIAIS.MATRIZ=Cad_MC.NOME_CLIFOR
			  left join CADASTRO_CLI_FOR Cad_MF ON FILIAIS.MATRIZ_FISCAL=Cad_MF.NOME_CLIFOR
			  left join PRODUTOS ON CM_ESTOQUE_PA_COMPOSICAO.PRODUTO=PRODUTOS.PRODUTO 
			  left join PRODUTO_CORES ON CM_ESTOQUE_PA_COMPOSICAO.PRODUTO=PRODUTO_CORES.PRODUTO AND CM_ESTOQUE_PA_COMPOSICAO.COR_PRODUTO=PRODUTO_CORES.COR_PRODUTO
			  LEFT JOIN CTB_CONTA_PLANO AS CTB_CONTA_PLANO_ESTOQUE ON PRODUTOS.CONTA_CONTABIL = CTB_CONTA_PLANO_ESTOQUE.CONTA_CONTABIL 
			 WHERE CM_ESTOQUE_PA_COMPOSICAO.COD_CUSTO_MEDIO = ?xCodCM
			   and (CM_ESTOQUE_PA_COMPOSICAO.ITEM_COMPOSICAO='000' or CM_ESTOQUE_PA_COMPOSICAO.ITEM_COMPOSICAO='999') 
			ORDER BY CM_ESTOQUE_PA_COMPOSICAO.DATA_SALDO, CM_ESTOQUE_PA_COMPOSICAO.ITEM_COMPOSICAO, CM_ESTOQUE_PA_COMPOSICAO.FILIAL, CM_ESTOQUE_PA_COMPOSICAO.PRODUTO, CM_ESTOQUE_PA_COMPOSICAO.COR_PRODUTO
		ENDTEXT 

		SELECT V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_PA
		LOCATE FOR ALLTRIM(cod_custo_medio)=xCodCM
		
		f_select(xSel_Comp_CM,'vTMP_Fechamento_Custo_Medio_Base',ALIAS())
	ENDIF
	
	f_Wait('Aguarde... (Gerando Cursor: Custos)')

	xSl_Cur = ' a.* '+;
			  '  FROM vTMP_Fechamento_Custo_Medio_Base a '+;
			  '  JOIN V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_PA b ON a.cod_custo_medio=b.cod_custo_medio AND a.filial=b.filial '+;
			  '	  AND a.produto=b.produto and a.cor_produto=b.cor_produto and b.data_saldo=Cur_Chk_Data_Saldo.data_saldo'

	IF !USED('vTMP_Fechamento_Custo_Medio')
		SELECT &xSl_Cur into cursor vTMP_Fechamento_Custo_Medio Readwrite 
	ELSE
		INSERT INTO vTMP_Fechamento_Custo_Medio SELECT &xSl_Cur
	ENDIF
	
	f_wait()

ENDFUNC
*====================================================================================================================================================*



*====================================================================================================================================================*
FUNCTION Fx_Processa_Modelo3_CM_Exc

	=Fx_009154_Init_Kardex(.f.)

USE IN SELECT ("Cur_Result3") && #1#
	SELECT cod_custo_medio,data_saldo,data_cardex,data_anterior,;
		   matriz_fiscal,Razao_Social_MF,filial,cod_filial,cgc_cpf,rg_ie,;
		   produto,desc_produto,cor_produto,desc_cor_produto,unidade,classif_fiscal,doc,emissao,Conta_Contabil_movto,;
		   ABS(Qtde_Mov) as Qtde,  ABS(Valor_Mov) as valor,valor_imposto_agregar as IPI_Valor,;
		   qtde_ant_ini as Estoque_Inicial,;
		   qtde_atual as Estoque, Media_atual as Custo,;
		   Especie_Serie,Serie_NF,CFOP,ES,;
		   IIF(INLIST(ALLTRIM(item_composicao),'006','007','010'),1,IIF(INLIST(ALLTRIM(item_composicao),'008','009','303','304','402'),2,3)) as Codigo_Entrada_Saida,;
		   SPACE(1) Obs,000000000 as _Pagina ;
	  FROM Cur_Result_Base WHERE qtde_atual>=0 ;
	 ORDER BY 1,2,4,6,10,12,17 ;
	  INTO CURSOR Cur_Result3 READWRITE 
	  
	SELECT Cur_Result3
	GO top
ENDFUNC
*====================================================================================================================================================*



*====================================================================================================================================================*
FUNCTION Fx_Proc_CM_if

	xCodCM = ALLTRIM(Cur_Chk_Data_Saldo.cod_custo_medio)

	SELECT V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_PA 
	LOCATE FOR ALLTRIM(cod_custo_medio)=xCodCM  AND data_saldo == Cur_Chk_Data_Saldo.data_saldo

		xPorCor = !f_Vazio(Cor_Produto) && Identifica que foi gerado por cor
		xDt_Sld = ALLTRIM(DTOS(Cur_Chk_Data_Saldo.Data_Saldo))

	xFieldsAF = "cod_custo_medio,matriz_contabil,IIF(xPor_MF,'',cod_matriz_fiscal) cod_matriz_fiscal,produto,cor_produto,SUM(Qtde) Qtde,SUM(Valor) Valor"
		SELECT &xFieldsAF FROM vTMP_Fechamento_custo_medio GROUP BY 1,2,3,4,5 WHERE cod_custo_medio=xCodCM AND Item_Composicao=='000' INTO CURSOR Cur_Saldo_Ant 
		SELECT &xFieldsAF FROM vTMP_Fechamento_custo_medio GROUP BY 1,2,3,4,5 WHERE cod_custo_medio=xCodCM AND Item_Composicao=='999' INTO CURSOR Cur_Saldo_Fim 

	SELECT Cur_Saldo_Ant 
		IF xPor_MF
			INDEX on ALLTRIM(cod_custo_medio)+ALLTRIM(produto)+ALLTRIM(cor_produto) TAG iAnt
		ELSE
			INDEX on ALLTRIM(cod_custo_medio)+ALLTRIM(cod_matriz_fiscal)+ALLTRIM(produto)+ALLTRIM(cor_produto) TAG iAnt
		ENDIF
		
	SELECT Cur_Saldo_Fim 
		IF xPor_MF
			INDEX on ALLTRIM(cod_custo_medio)+ALLTRIM(produto)+ALLTRIM(cor_produto) TAG iSai
		ELSE
			INDEX on ALLTRIM(cod_custo_medio)+ALLTRIM(cod_matriz_fiscal)+ALLTRIM(produto)+ALLTRIM(cor_produto) TAG iSai
		ENDIF
		
			   	   
	*--- Atualiza Saldos
	SELECT Cur_Result_Base
		SET FILTER TO cod_custo_medio=xCodCM 
		COUNT TO xTReg
		xRatu = 0

	GO top
	DO whil !EOF()
		xSeek = ALLTRIM(cod_custo_medio)+IIF(xPor_MF,'',ALLTRIM(cod_matriz_fiscal))+ALLTRIM(produto)+ALLTRIM(cor_produto)

		SELECT Cur_Saldo_Ant 
			SEEK xSeek
		SELECT Cur_Saldo_Fim
			SEEK xSeek
		
		xSAnt_iQ = Cur_Saldo_Ant.Qtde
		xSAnt_iV = Cur_Saldo_Ant.Valor
		*---
		
		SELECT Cur_Result_Base
			REPLACE Qtde_Ant_Ini WITH xSAnt_iQ ,Valor_ant_Ini WITH xSAnt_iV,;
					Qtde_Atu_fim WITH Cur_Saldo_Fim.Qtde ,Valor_Atu_Fim WITH Cur_Saldo_Fim.Valor

		xK = (Cod_custo_medio+IIF(xPor_MF,'',ALLTRIM(cod_matriz_fiscal))+produto+Cor_produto)
		SCAN WHILE (Cod_custo_medio+IIF(xPor_MF,'',ALLTRIM(cod_matriz_fiscal))+produto+Cor_produto) == xK 
			xRatu = xRatu + 1
			f_prog_bar('Aguarde: Calculo do Saldo Anterior...',xRatu,xTReg)

			REPLACE Qtde_Ant  WITH xSAnt_iQ,;
					Valor_Ant WITH xSAnt_iV

			REPLACE Qtde_Atual  WITH (Qtde_Ant+Qtde_Ent-ABS(Qtde_Sai))
			REPLACE Valor_Atual WITH (Valor_Ant+Valor_Ent-ABS(Valor_Sai)) && Saida vem com sinal negativo
			
			xSAnt_iQ = Qtde_Atual
			xSAnt_iV = Valor_Atual
		ENDSCAN

	ENDDO

	SELECT Cur_Result_Base
		SET FILTER TO

ENDFUNC
*====================================================================================================================================================*




*====================================================================================================================================================*
FUNCTION Fx_Proc_CM_if_Agr
	xCodCM = ALLTRIM(Cur_Chk_Data_Saldo.cod_custo_medio)


	SELECT V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_PA 
		LOCATE FOR ALLTRIM(cod_custo_medio)=xCodCM AND data_saldo == Cur_Chk_Data_Saldo.data_saldo
		xCodCM = ALLTRIM(Cur_Chk_Data_Saldo.cod_custo_medio)

		xPorCor = !f_Vazio(Cor_Produto) && Identifica que foi gerado por cor
		xDt_Sld = ALLTRIM(DTOS(Cur_Chk_Data_Saldo.Data_Saldo))

	xFieldsAF = "cod_custo_medio,matriz_contabil,IIF(xPor_MF,'',cod_matriz_fiscal) cod_matriz_fiscal,produto,cor_produto,SUM(Qtde) Qtde,SUM(Valor) Valor"
		SELECT &xFieldsAF FROM vTMP_Fechamento_custo_medio GROUP BY 1,2,3,4,5 WHERE cod_custo_medio=xCodCM AND Item_Composicao=='000' INTO CURSOR Cur_Saldo_Ant 
		SELECT &xFieldsAF FROM vTMP_Fechamento_custo_medio GROUP BY 1,2,3,4,5 WHERE cod_custo_medio=xCodCM AND Item_Composicao=='999' INTO CURSOR Cur_Saldo_Fim 


	SELECT Cur_Saldo_Ant 
		IF xPor_MF
			INDEX on ALLTRIM(cod_custo_medio)+ALLTRIM(produto)+ALLTRIM(cor_produto) TAG iAnt
		ELSE
			INDEX on ALLTRIM(cod_custo_medio)+ALLTRIM(cod_matriz_fiscal)+ALLTRIM(produto)+ALLTRIM(cor_produto) TAG iAnt
		ENDIF

	SELECT Cur_Saldo_Fim 
		IF xPor_MF
			INDEX on ALLTRIM(cod_custo_medio)+ALLTRIM(produto)+ALLTRIM(cor_produto) TAG iSai
		ELSE
			INDEX on ALLTRIM(cod_custo_medio)+ALLTRIM(cod_matriz_fiscal)+ALLTRIM(produto)+ALLTRIM(cor_produto) TAG iSai
		ENDIF

			   	   
	*--- Atualiza Saldos
	SELECT Cur_Result_Base
		SET FILTER TO cod_custo_medio=xCodCM 
		COUNT TO xTReg
		xRatu = 0

	GO top
	DO whil !EOF()
		xSeek = ALLTRIM(cod_custo_medio)+IIF(xPor_MF,'',ALLTRIM(cod_matriz_fiscal))+ALLTRIM(produto)+ALLTRIM(cor_produto)

		SELECT Cur_Saldo_Ant 
			SEEK xSeek
		SELECT Cur_Saldo_Fim
			SEEK xSeek
		
		xSAnt_iQ = Cur_Saldo_Ant.Qtde
		xSAnt_iV = Cur_Saldo_Ant.Valor
		*---
		
		SELECT Cur_Result_Base
			REPLACE Qtde_Ant_Ini WITH xSAnt_iQ ,Valor_ant_Ini WITH xSAnt_iV,;
					Qtde_Atu_fim WITH Cur_Saldo_Fim.Qtde ,Valor_Atu_Fim WITH Cur_Saldo_Fim.Valor

		xK = (Cod_custo_medio+IIF(xPor_MF,'',ALLTRIM(cod_matriz_fiscal))+produto+Cor_produto)
		SCAN WHILE (Cod_custo_medio+IIF(xPor_MF,'',ALLTRIM(cod_matriz_fiscal))+produto+Cor_produto) == xK 
			xRatu = xRatu + 1
			f_prog_bar('Aguarde: Calculo do Saldo Anterior...',xRatu,xTReg)

			REPLACE Qtde_Ant  WITH xSAnt_iQ,;
					Valor_Ant WITH xSAnt_iV

			REPLACE Qtde_Atual  WITH (Qtde_Ant+Qtde_Ent-ABS(Qtde_Sai))
			REPLACE Valor_Atual WITH (Valor_Ant+Valor_Ent-ABS(Valor_Sai)) && Saida vem com sinal negativo
			
			xSAnt_iQ = Qtde_Atual
			xSAnt_iV = Valor_Atual
		ENDSCAN

	ENDDO

	SELECT Cur_Result_Base
		SET FILTER TO

ENDFUNC
*====================================================================================================================================================*



*====================================================================================================================================================*
FUNCTION Fx_Add_Itens_Sem_Mov_Kardex
LPARAMETERS pProcAgr,xPorCor

*-- Adicionar Itens que Não Tem Kardex, porém com CM
	f_wait('Adicionando Itens CM (Sem Movimentação no Kardex)')
	xWhereCta =  IIF(TYPE('OpRelPorCta')='L' and OpRelPorCta,"conta_contabil_estoque='" + OpRelCtaEst + "'","1=1")
	
	IF pProcAgr
		xFields_Sel = "Distinct a.cod_custo_medio,a.data_anterior,a.data_saldo,a.data_cardex,NVL(a.data_anterior,{}) as Emissao,'  >' as item_composicao,'(Sem Movimentação)' as desc_item_composicao,"+;
					  "a.conta_contabil_estoque,a.desc_conta_estoque,"+;
					  "a.matriz_contabil,a.Razao_social_MC,a.cgc_cpf_MC,"+;
					  "space(1) as matriz_fiscal,space(1) as Razao_social_MF,space(1) as cod_matriz_fiscal,space(1) as cnpj_matriz_fiscal,"+;
					  "space(1) as filial,space(1) as cod_filial,space(1) as CGC_CPF,space(1) as RG_IE,"+;
					  "a.produto,a.cor_produto,a.desc_produto,a.grupo_produto,a.subgrupo_produto,a.desc_cor_produto,a.Unidade,a.classif_fiscal"
						   
		xFields_Ins = "cod_custo_medio,data_anterior,data_saldo,data_cardex,Emissao,item_composicao,desc_item_composicao,"+;
					  "conta_contabil_estoque,desc_conta_estoque,"+;
					  "matriz_contabil,Razao_social_MC,cgc_cpf_MC,"+;
					  "matriz_fiscal,Razao_social_MF,cod_matriz_fiscal,cnpj_matriz_fiscal,"+;
					  "filial,cod_filial,CGC_CPF,RG_IE,"+;
					  "produto,cor_produto,desc_produto,grupo_produto,subgrupo_produto,desc_cor_produto,Unidade,classif_fiscal"

		IF xPorCor
			INSERT INTO vTMP_Estoque_Cardex (&xFields_Ins) ;
				SELECT &xFields_Sel FROM vTMP_Fechamento_custo_medio a;
				  JOIN V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_PA b ;
				    ON a.cod_custo_medio=b.cod_custo_medio AND a.produto=b.Produto AND a.cor_produto=b.cor_produto AND a.filial=b.filial ;
				 WHERE a.cod_custo_medio+a.matriz_contabil+a.produto+a.cor_produto ;
				   	   not in (Select Distinct cod_custo_medio+matriz_contabil+produto+cor_produto from vTMP_Estoque_Cardex WHERE &xWhereCta)
		ELSE
			INSERT INTO vTMP_Estoque_Cardex (&xFields_Ins) ;
				SELECT &xFields_Sel FROM vTMP_Fechamento_custo_medio a;
				  JOIN V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_PA b ;
				    ON a.cod_custo_medio=b.cod_custo_medio AND a.produto=b.Produto AND a.cor_produto=b.cor_produto AND a.filial=b.filial ;
				 WHERE a.cod_custo_medio+a.matriz_contabil+a.produto ;
				   	   not in (Select Distinct cod_custo_medio+matriz_contabil+produto from vTMP_Estoque_Cardex WHERE &xWhereCta)
		ENDIF
		

	ELSE


		xFields_Sel = "Distinct a.cod_custo_medio,a.data_anterior,a.data_saldo,a.data_cardex,NVL(a.data_anterior,{}) as Emissao,'  >' as item_composicao,'(Sem Movimentação)' as desc_item_composicao,"+;
					  "a.conta_contabil_estoque,a.desc_conta_estoque,"+;
					  "a.matriz_contabil,a.Razao_social_MC,a.cgc_cpf_MC,"+;
					  "a.matriz_fiscal,a.Razao_social_MF,a.cod_matriz_fiscal,a.cnpj_matriz_fiscal,"+;
					  "a.filial,a.cod_filial,a.CGC_CPF,a.RG_IE,"+;
					  "a.produto,a.cor_produto,a.desc_produto,a.grupo_produto,a.subgrupo_produto,a.desc_cor_produto,a.Unidade,a.classif_fiscal"
						   
		xFields_Ins = "cod_custo_medio,data_anterior,data_saldo,data_cardex,Emissao,item_composicao,desc_item_composicao,"+;
					  "conta_contabil_estoque,desc_conta_estoque,"+;
					  "matriz_contabil,Razao_social_MC,cgc_cpf_MC,"+;
					  "matriz_fiscal,Razao_social_MF,cod_matriz_fiscal,cnpj_matriz_fiscal,"+;
					  "filial,cod_filial,CGC_CPF,RG_IE,"+;
					  "produto,cor_produto,desc_produto,grupo_produto,subgrupo_produto,desc_cor_produto,Unidade,classif_fiscal"

		IF xPorCor
			INSERT INTO vTMP_Estoque_Cardex (&xFields_Ins) ;
				SELECT &xFields_Sel FROM vTMP_Fechamento_custo_medio a;
				  JOIN V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_PA b ;
				    ON a.cod_custo_medio=b.cod_custo_medio AND a.produto=b.Produto AND a.cor_produto=b.cor_produto AND a.filial=b.filial ;
				 WHERE a.cod_custo_medio+a.matriz_contabil+a.matriz_fiscal+a.filial+a.produto+a.cor_produto+DTOS(a.data_saldo) ;
				   	   not in (Select Distinct cod_custo_medio+matriz_contabil+matriz_fiscal+filial+produto+cor_produto+DTOS(data_saldo) From vTMP_Estoque_Cardex WHERE &xWhereCta)
		ELSE
			INSERT INTO vTMP_Estoque_Cardex (&xFields_Ins) ;
				SELECT &xFields_Sel FROM vTMP_Fechamento_custo_medio a;
				  JOIN V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_PA b ;
				    ON a.cod_custo_medio=b.cod_custo_medio AND a.produto=b.Produto AND a.cor_produto=b.cor_produto AND a.filial=b.filial ;
				 WHERE a.cod_custo_medio+a.matriz_contabil+a.matriz_fiscal+a.filial+a.produto+DTOS(a.data_saldo) ;
				   	   not in (Select Distinct cod_custo_medio+matriz_contabil+matriz_fiscal+filial+produto+DTOS(data_saldo) From vTMP_Estoque_Cardex WHERE &xWhereCta)
		ENDIF 


	ENDIF
	
	f_wait()

ENDFUNC
*====================================================================================================================================================*
