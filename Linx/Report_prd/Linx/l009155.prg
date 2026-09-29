*== Funções para os Relatórios da Tela 009154 (Kardex + Modelo 3)
*== Custo Médio Linx (Valmir/Cestari/Douglas/Banin: Maio-2009)
*====================================================================================================================================================*
FUNCTION Fx_009155_Init_Kardex
	LPARAMETERS pShowOpt_CM,pProcAgr
	
	f_Wait('Aguarde...')
	
	SELECT Distinct data_cardex,data_saldo,cod_custo_medio FROM V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_MP INTO CURSOR Cur_Chk_Data_Saldo
	IF RECCOUNT('Cur_Chk_Data_Saldo')>1
		MESSAGEBOX('Favor Filtrar Apenas UM Custo Médio',48,'Aviso')
		f_Wait()
		RETURN .f.
	ENDIF

	IF pShowOpt_CM
		f_Wait()
		System.ExecuteFormModal('LxOprel_009154_Filtros') && Retorna: OpRelCardex
	ELSE
		OpRelCardex = .f.
	ENDIF
	
	IF OpRelCardex
		=Fx_Carga_Cardex_Por_CM()
	ELSE
		=Fx_Carga_Cardex(pProcAgr)
	ENDIF
	*--
	
	f_Wait('Aguarde... (Gerando Cursores)')
	SELECT vTMP_Estoque_Cardex 
		REPLACE ALL op_ped_roman 			WITH '' FOR ISNULL(op_ped_roman)
		REPLACE ALL doc 					WITH '' FOR ISNULL(doc)
		REPLACE ALL item_composicao 		WITH '' FOR ISNULL(item_composicao)
		REPLACE ALL desc_item_composicao 	WITH '' FOR ISNULL(desc_item_composicao)
		REPLACE ALL valor_base_ipi 			WITH 0  FOR ISNULL(valor_base_ipi)
		REPLACE ALL data_anterior			WITH {} FOR ISNULL(data_anterior)

		IF pProcAgr
			xOrder = 'cod_custo_medio,matriz_contabil,conta_contabil_estoque,material,cor_material,emissao,item_composicao'
		ELSE
			xOrder = 'cod_custo_medio,matriz_contabil,matriz_fiscal,filial,conta_contabil_estoque,material,cor_material,emissao,item_composicao'
		ENDIF

		xFatorEnt = [IIF(!INLIST(item_composicao,'000','999') and fator_est_proprio>0 AND ES<>'-',1,iif(ES='-' and Mv_Tot>0,1,0))]
		xFatorSai = [IIF(!INLIST(item_composicao,'000','999') and fator_est_proprio<0 AND ES<>'-',1,iif(ES='-' and Mv_Tot<0,1,0))]

		SELECT cod_custo_medio,;
			   matriz_contabil,Razao_social_MC,cgc_cpf_MC,matriz_fiscal,Razao_social_MF,cod_matriz_fiscal,cnpj_matriz_fiscal,;
			   filial,cod_filial,CGC_CPF,RG_IE,conta_contabil_estoque,desc_conta_estoque,;
			   material,cor_material,desc_material,grupo,subgrupo,desc_cor_material,Unidade,classif_fiscal, ;
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
	 	  GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36 ;
		 ORDER BY &xOrder INTO CURSOR Cur_Result readwrite

	IF pProcAgr
		=Fx_Proc_CM_if_Agr()
	ELSE
		=Fx_Proc_CM_if()
	ENDIF
	*-----------------------------------------------------------------------------------------------------------------------------------------------------*

	*--- Totais
	f_Wait('Aguarde... (Gerando Totais)')

	xFields = 'sum(Qtde_Ant_Ini) Qtde_Ant,sum(Valor_Ant_Ini) Valor_Ant,000000000000000.00 as Media_Ant,'+;
			  'sum(Qtde_Atu_Fim) Qtde_Atu_Fim,sum(Valor_Atu_Fim) Valor_Atu_Fim,000000000000000.00 as Media_Atu_Fim,'+;
		      'sum(Qtde_Ent) Qtde_Ent,sum(Valor_Ent) Valor_Ent,000000000000000.00 as Media_Ent,'+;
		      'sum(Qtde_Sai) Qtde_Sai,sum(Valor_Sai) Valor_Sai,000000000000000.00 as Media_Sai,'+;
		      'sum(qtde_saldo_pai) qtde_saldo_pai,sum(valor_saldo_pai) valor_saldo_pai,'+;
		      '00000000000 Qtde_Atual,000000000000000.00 Valor_Atual,000000000000.00 as Media_Atual'

	SELECT cod_custo_medio,matriz_contabil,&xFields 																	FROM Cur_Result GROUP BY 1,2 			INTO CURSOR Cur_Result_Tot_MC 		ReadWrite
	SELECT cod_custo_medio,matriz_contabil,matriz_fiscal,&xFields 														FROM Cur_Result GROUP BY 1,2,3 			INTO CURSOR Cur_Result_Tot_MF 		ReadWrite
	SELECT cod_custo_medio,matriz_contabil,matriz_fiscal,filial,&xFields 												FROM Cur_Result GROUP BY 1,2,3,4 		INTO CURSOR Cur_Result_Tot_Fil 		ReadWrite

	IF pProcAgr
		SELECT cod_custo_medio,matriz_contabil,conta_contabil_estoque,&xFields 					 						FROM Cur_Result GROUP BY 1,2,3 			INTO CURSOR Cur_Result_Tot_Conta 	ReadWrite
		SELECT cod_custo_medio,matriz_contabil,conta_contabil_estoque,material,&xFields 			 						FROM Cur_Result GROUP BY 1,2,3,4 		INTO CURSOR Cur_Result_Tot_Prod 	ReadWrite
		SELECT cod_custo_medio,matriz_contabil,conta_contabil_estoque,material,cor_material,&xFields 						FROM Cur_Result GROUP BY 1,2,3,4,5 		INTO CURSOR Cur_Result_Tot_Cor 		ReadWrite
	ELSE
		SELECT cod_custo_medio,matriz_contabil,matriz_fiscal,filial,conta_contabil_estoque,&xFields 					FROM Cur_Result GROUP BY 1,2,3,4,5 		INTO CURSOR Cur_Result_Tot_Conta 	ReadWrite
		SELECT cod_custo_medio,matriz_contabil,matriz_fiscal,filial,conta_contabil_estoque,material,&xFields 			FROM Cur_Result GROUP BY 1,2,3,4,5,6 	INTO CURSOR Cur_Result_Tot_Prod 	ReadWrite
		SELECT cod_custo_medio,matriz_contabil,matriz_fiscal,filial,conta_contabil_estoque,material,cor_material,&xFields FROM Cur_Result GROUP BY 1,2,3,4,5,6,7 	INTO CURSOR Cur_Result_Tot_Cor 	ReadWrite
	ENDIF
	
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

	SELECT Cur_Result
		SET RELATION TO cod_custo_medio+matriz_contabil													INTO Cur_Result_Tot_MC 		ADDITIVE 
		SET RELATION TO cod_custo_medio+matriz_contabil+matriz_fiscal									INTO Cur_Result_Tot_MF 		ADDITIVE 
		SET RELATION TO cod_custo_medio+matriz_contabil+matriz_fiscal+filial							INTO Cur_Result_Tot_Fil 	ADDITIVE 

	*--- Relation-Dif
	IF pProcAgr
		SELECT Cur_Result_Tot_Conta 
			INDEX ON cod_custo_medio+matriz_contabil+conta_contabil_estoque TAG iTConta
		SELECT Cur_Result_Tot_Prod 
			INDEX ON cod_custo_medio+matriz_contabil+conta_contabil_estoque+material TAG iTRProd
		SELECT Cur_Result_Tot_Cor 
			INDEX ON cod_custo_medio+matriz_contabil+conta_contabil_estoque+material+cor_material TAG iTCor

		SELECT Cur_Result
			SET RELATION TO cod_custo_medio+matriz_contabil+conta_contabil_estoque						INTO Cur_Result_Tot_Conta 	ADDITIVE 
			SET RELATION TO cod_custo_medio+matriz_contabil+conta_contabil_estoque+material 				INTO Cur_Result_Tot_Prod 	ADDITIVE 
			SET RELATION TO cod_custo_medio+matriz_contabil+conta_contabil_estoque+material+cor_material 	INTO Cur_Result_Tot_Cor 	ADDITIVE 
	ELSE
		SELECT Cur_Result_Tot_Conta 
			INDEX ON cod_custo_medio+matriz_contabil+matriz_fiscal+filial+conta_contabil_estoque TAG iTConta
		SELECT Cur_Result_Tot_Prod 
			INDEX ON cod_custo_medio+matriz_contabil+matriz_fiscal+filial+conta_contabil_estoque+material TAG iTRProd
		SELECT Cur_Result_Tot_Cor 
			INDEX ON cod_custo_medio+matriz_contabil+matriz_fiscal+filial+conta_contabil_estoque+material+cor_material TAG iTCor

		SELECT Cur_Result
			SET RELATION TO cod_custo_medio+matriz_contabil+matriz_fiscal+filial+conta_contabil_estoque						INTO Cur_Result_Tot_Conta ADDITIVE 
			SET RELATION TO cod_custo_medio+matriz_contabil+matriz_fiscal+filial+conta_contabil_estoque+material 			INTO Cur_Result_Tot_Prod ADDITIVE 
			SET RELATION TO cod_custo_medio+matriz_contabil+matriz_fiscal+filial+conta_contabil_estoque+material+cor_material INTO Cur_Result_Tot_Cor ADDITIVE 
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

	xDatai = V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_MP.DATA_CARDEX
	xDataf = V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_MP.DATA_SALDO
	xCodCM = ALLTRIM(V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_MP.cod_custo_medio)
	
	TEXT TO lcSelect TEXTMERGE NOSHOW PRETEXT 8
		  SELECT ?V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_MP.cod_custo_medio  AS cod_custo_medio,
				 Convert(datetime,?V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_MP.DATA_SALDO)  	  AS data_saldo,
				 Convert(datetime,?V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_MP.DATA_ANTERIOR)  AS data_anterior,
				 Convert(datetime,?V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_MP.data_cardex)	  AS data_cardex,
			     FILIAIS.MATRIZ as matriz_contabil,Cad_MC.Razao_social as Razao_social_MC,Cad_MC.cgc_cpf as cgc_cpf_MC,
			     Cad_MF.Razao_social as Razao_social_MF,
			     FILIAIS.COD_FILIAL,Cad_FL.RG_IE,Cad_FL.CGC_CPF,
			     MATERIAIS.DESC_MATERIAL,MATERIAIS.GRUPO, MATERIAIS.SUBGRUPO,
			     MATERIAIS_CORES.DESC_COR_MATERIAL,CM_ITEM_COMPOSICAO.INDICA_ENTRADA_SAIDA AS ES,CM_ITEM_COMPOSICAO.fator_est_proprio,
				CARDEX.ITEM_COMPOSICAO, CM_ITEM_COMPOSICAO.DESC_ITEM_COMPOSICAO, CARDEX.EMISSAO AS EMISSAO, CARDEX.DOC, CARDEX.SERIE_NF, CARDEX.ESPECIE_SERIE, CARDEX.MATERIAL, CARDEX.COR_MATERIAL, CARDEX.FILIAL, CARDEX.OP_PED_ROMAN, CM_ITEM_COMPOSICAO.COMPOE_CUSTO_MEDIO, 
				CARDEX.VALOR, CARDEX.VALOR_ENCARGO, CARDEX.VALOR_DESCONTO, CARDEX.VALOR_ENCARGO_IMPORTACAO, CARDEX.VALOR_IMPOSTO_DESTACAR, CARDEX.VALOR_IMPOSTO_AGREGAR, CARDEX.VALOR_FRETE, CARDEX.VALOR_SEGURO, CARDEX.VALOR_FRETE_TRANSPORTADORA, CARDEX.VALOR_DESPESAS, CARDEX.VALOR_LIQ, CARDEX.VALOR_PRODUCAO, 
				CARDEX.VALOR_ESTOQUE, CARDEX.VALOR_BASE_IPI, CARDEX.VALOR_IPI, CARDEX.CONTA_CONTABIL_ESTOQUE, CONTA_ESTOQUE.DESC_CONTA AS DESC_CONTA_ESTOQUE, CARDEX.CONTA_CONTABIL_MOVTO, CONTA_MOVTO.DESC_CONTA AS DESC_CONTA_MOVTO, CARDEX.RATEIO_FILIAL, CTB_FILIAL_RATEIO.DESC_RATEIO_FILIAL, CARDEX.RATEIO_CENTRO_CUSTO, CTB_CENTRO_CUSTO_RATEIO.DESC_RATEIO_CENTRO_CUSTO, CARDEX.FILIAL_ORIGINAL, 
				CARDEX.QTDE AS MV_TOT, CARDEX.CFOP, CARDEX.DESCRICAO_CFOP, CARDEX.UNIDADE, CARDEX.CLASSIF_FISCAL, CLASSIF_FISCAL.DESC_CLASSIFICACAO, CARDEX.MATRIZ_FISCAL, FILIAIS.CGC_CPF AS CNPJ_MATRIZ_FISCAL, FILIAIS.COD_FILIAL AS COD_MATRIZ_FISCAL 
		    FROM DBO.FX_CM_MONTA_CARDEX_MP('%','%', ?Cur_Lst_filial.filial, ?xDatai, ?xDataf, 0,?xCodCM) AS CARDEX 
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
			left join MATERIAIS ON CARDEX.MATERIAL=MATERIAIS.MATERIAL
			left join MATERIAIS_CORES ON CARDEX.MATERIAL=MATERIAIS_CORES.MATERIAL AND CARDEX.COR_MATERIAL=MATERIAIS_CORES.COR_MATERIAL
		   Where CM_ITEM_COMPOSICAO.Indica_Entrada_Saida<>'A'
		  ORDER BY CARDEX.FILIAL_ORIGINAL
	ENDTEXT 

	SELECT V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_MP 
		GO top
		xPorCor = !f_Vazio(Cor_material) && Identifica que foi gerado por cor
		
	xSl_Cur = " a.*,b.qtde_saldo AS qtde_saldo_pai,b.valor_saldo AS valor_saldo_pai,000000000000000.00 Custo_Recalculado "+;
			  "  FROM vTMP_Estoque_Cardex_Base a "+;
			  "  JOIN V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_MP b ON a.cod_custo_medio=b.cod_custo_medio AND a.filial=b.filial "+;
			  "   AND a.material=b.material " + IIF(xPorCor," and a.cor_material=b.cor_material","")+;
			  IIF(TYPE('OpRelPorCta')='L' and OpRelPorCta," Where conta_contabil_estoque='" + OpRelCtaEst + "'","")

	IF USED('vTMP_Estoque_Cardex')
		SELECT vTMP_Estoque_Cardex
		USE 
	ENDIF

	SELECT distinct Filial FROM v_fechamento_custo_medio_01_estoque_MP INTO CURSOR Cur_Lst_filial
	
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
	=Fx_Add_Itens_Sem_Mov_Kardex(pProcAgr)

	SELECT vTMP_Estoque_Cardex
	INDEX ON cod_custo_medio+material+cor_material+filial+item_composicao TAG iCardex
	DO whil !EOF()
		xK = cod_custo_medio+material+cor_material+filial
		SKIP
		SCAN WHILE cod_custo_medio+material+cor_material+filial == xK
			REPLACE qtde_saldo_pai WITH 0, valor_saldo_pai WITH 0
		ENDSCAN
	ENDDO

	f_wait()

ENDFUNC
*====================================================================================================================================================*



*====================================================================================================================================================*
FUNCTION Fx_Carga_Cardex_Por_CM

	*-- Opção Somente Para Conferência
	TEXT TO xSel_Comp_CM TEXTMERGE NOSHOW PRETEXT 8
		SELECT Convert(datetime,?V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_MP.DATA_ANTERIOR) 	AS data_anterior,
			   Convert(datetime,?V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_MP.data_cardex)	AS data_cardex,
			   ?V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_MP.cod_custo_medio 	AS cod_custo_medio, 
				CM_ESTOQUE_MP_COMPOSICAO.ID_MOVIMENTO,
				CM_ESTOQUE_MP_COMPOSICAO.DATA_SALDO, CM_ESTOQUE_MP_COMPOSICAO.MATERIAL, CM_ESTOQUE_MP_COMPOSICAO.COR_MATERIAL, CM_ESTOQUE_MP_COMPOSICAO.FILIAL, CM_ITEM_COMPOSICAO.DESC_ITEM_COMPOSICAO, CM_ESTOQUE_MP_COMPOSICAO.ITEM_COMPOSICAO, CM_ESTOQUE_MP_COMPOSICAO.QTDE, 
				CM_ESTOQUE_MP_COMPOSICAO.VALOR,  null as valor_base_ipi,  
				CM_ITEM_COMPOSICAO.COMPOE_CUSTO_MEDIO, CTB_CONTA_PLANO.CONTA_CONTABIL, CTB_CONTA_PLANO.DESC_CONTA, CM_ESTOQUE_MP_COMPOSICAO.RATEIO_FILIAL, CTB_FILIAL_RATEIO.DESC_RATEIO_FILIAL, CM_ESTOQUE_MP_COMPOSICAO.RATEIO_CENTRO_CUSTO, CTB_CENTRO_CUSTO_RATEIO.DESC_RATEIO_CENTRO_CUSTO, 
				CTB_CONTA_PLANO_ESTOQUE.CONTA_CONTABIL AS CONTA_CONTABIL_ESTOQUE,CTB_CONTA_PLANO_ESTOQUE.DESC_CONTA AS desc_conta_estoque,
				CM_ITEM_COMPOSICAO.Indica_Entrada_Saida AS ES, CM_ITEM_COMPOSICAO.fator_est_proprio, CM_ESTOQUE_MP_COMPOSICAO.QTDE as Mv_Tot, CM_ESTOQUE_MP_COMPOSICAO.VALOR as Valor_Estoque,
			    FILIAIS.MATRIZ as matriz_contabil,Cad_MC.Razao_social as Razao_social_MC,Cad_MC.cgc_cpf as cgc_cpf_MC,Cad_MF.Razao_social as Razao_social_MF,
			    FILIAIS.COD_FILIAL,Cad_FL.RG_IE,Cad_FL.CGC_CPF,
			    FILIAIS.CGC_CPF AS CNPJ_MATRIZ_FISCAL, FILIAIS.COD_FILIAL as cod_matriz_fiscal,FILIAIS.MATRIZ_FISCAL,
				MATERIAIS.DESC_MATERIAL,MATERIAIS.GRUPO, MATERIAIS.SUBGRUPO,
				MATERIAIS_CORES.DESC_COR_MATERIAL,MATERIAIS.UNID_ESTOQUE AS unidade, MATERIAIS.classif_fiscal
		  FROM CM_ESTOQUE_MP_COMPOSICAO 
		 INNER JOIN FILIAIS ON CM_ESTOQUE_MP_COMPOSICAO.FILIAL = FILIAIS.FILIAL 
		 INNER JOIN CM_FECHAMENTO_CUSTO_MEDIO ON CM_ESTOQUE_MP_COMPOSICAO.COD_CUSTO_MEDIO = CM_FECHAMENTO_CUSTO_MEDIO.COD_CUSTO_MEDIO 
		 INNER JOIN MATERIAIS ON CM_ESTOQUE_MP_COMPOSICAO.MATERIAL = MATERIAIS.MATERIAL 
		  LEFT JOIN CTB_CONTA_PLANO AS CTB_CONTA_PLANO_ESTOQUE ON MATERIAIS.CONTA_CONTABIL = CTB_CONTA_PLANO_ESTOQUE.CONTA_CONTABIL 
		  LEFT JOIN CM_ITEM_COMPOSICAO ON CM_ITEM_COMPOSICAO.ITEM_COMPOSICAO = CM_ESTOQUE_MP_COMPOSICAO.ITEM_COMPOSICAO 
		  LEFT JOIN CTB_CONTA_PLANO ON CM_ESTOQUE_MP_COMPOSICAO.CONTA_CONTABIL = CTB_CONTA_PLANO.CONTA_CONTABIL 
		  LEFT JOIN CTB_FILIAL_RATEIO ON CM_ESTOQUE_MP_COMPOSICAO.RATEIO_FILIAL = CTB_FILIAL_RATEIO.RATEIO_FILIAL 
		  LEFT JOIN CTB_CENTRO_CUSTO_RATEIO ON CM_ESTOQUE_MP_COMPOSICAO.RATEIO_CENTRO_CUSTO = CTB_CENTRO_CUSTO_RATEIO.RATEIO_CENTRO_CUSTO 
		  left join MATERIAIS_CORES ON CM_ESTOQUE_MP_COMPOSICAO.MATERIAL=MATERIAIS_CORES.MATERIAL AND CM_ESTOQUE_MP_COMPOSICAO.COR_MATERIAL=MATERIAIS_CORES.COR_MATERIAL
		  left join CADASTRO_CLI_FOR Cad_FL ON FILIAIS.FILIAL=Cad_FL.NOME_CLIFOR
		  left join CADASTRO_CLI_FOR Cad_MC ON FILIAIS.MATRIZ=Cad_MC.NOME_CLIFOR
		  left join CADASTRO_CLI_FOR Cad_MF ON FILIAIS.MATRIZ_FISCAL=Cad_MF.NOME_CLIFOR
		 WHERE CM_ESTOQUE_MP_COMPOSICAO.COD_CUSTO_MEDIO=?V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_MP.cod_custo_medio
		 ORDER BY CM_ESTOQUE_MP_COMPOSICAO.DATA_SALDO, CM_ESTOQUE_MP_COMPOSICAO.ITEM_COMPOSICAO, CM_ESTOQUE_MP_COMPOSICAO.FILIAL, CM_ESTOQUE_MP_COMPOSICAO.MATERIAL, CM_ESTOQUE_MP_COMPOSICAO.COR_MATERIAL
	ENDTEXT 
	
	f_Wait('Aguarde... (Processando Kardex Pelo Custo Médio)')
		SELECT V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_MP
		GO top
		f_select(xSel_Comp_CM,'vTMP_Estoque_Cardex_Base',ALIAS())

	xSl_Cur = ' a.*, a.Data_Saldo as Emissao,SPACE(1) as op_ped_roman,SPACE(1) as doc,'+;
			  '		 SPACE(1) as Especie_Serie,SPACE(1) as Serie_NF,SPACE(1) CFOP,'+;
			  '		 SPACE(1) as conta_contabil_movto,0 as valor_imposto_agregar,'+;
			  '	     b.qtde_saldo AS qtde_saldo_pai,b.valor_saldo AS valor_saldo_pai,000000000000000.00 Custo_Recalculado '+;
			  '  FROM vTMP_Estoque_Cardex_Base a '+;
			  '  JOIN V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_MP b ON a.cod_custo_medio=b.cod_custo_medio AND a.filial=b.filial '+;
			  '	  AND a.material=b.material and a.cor_material=b.cor_material'

	SELECT &xSl_Cur into cursor vTMP_Estoque_Cardex Readwrite 

	=Fx_Carga_CM_IniFim()
	f_wait()
ENDFUNC
*====================================================================================================================================================*



*====================================================================================================================================================*
FUNCTION Fx_Carga_CM_IniFim

	SELECT V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_MP
	GO top

	xReprocessarCM = .t. 		
 	IF USED('vTMP_Fechamento_Custo_Medio_Base') AND ALLTRIM(V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_MP.cod_custo_medio)==ALLTRIM(vTMP_Fechamento_Custo_Medio_Base.cod_custo_medio)
			xReprocessarCM = .f. 		
 	ENDIF

 	IF xReprocessarCM 
		f_Wait('Aguarde... (Processando Custos: 000 e 999)')

		*-- Saldo Inicial: Item_Composicao=000 | Saldo Final: Item_Composicao=999
		TEXT TO xSel_Comp_CM TEXTMERGE NOSHOW PRETEXT 8
			SELECT Convert(datetime,?V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_MP.DATA_ANTERIOR)   AS data_anterior,
				   Convert(datetime,?V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_MP.data_cardex)	 AS data_cardex,
				   ?V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_MP.cod_custo_medio AS cod_custo_medio, 
					CM_ESTOQUE_MP_COMPOSICAO.ID_MOVIMENTO,
					CM_ESTOQUE_MP_COMPOSICAO.DATA_SALDO, CM_ESTOQUE_MP_COMPOSICAO.MATERIAL, CM_ESTOQUE_MP_COMPOSICAO.COR_MATERIAL, 
					CM_ESTOQUE_MP_COMPOSICAO.FILIAL, CM_ITEM_COMPOSICAO.DESC_ITEM_COMPOSICAO, CM_ESTOQUE_MP_COMPOSICAO.ITEM_COMPOSICAO, 
					CM_ITEM_COMPOSICAO.Indica_Entrada_Saida, 
					CTB_CONTA_PLANO_ESTOQUE.CONTA_CONTABIL AS CONTA_CONTABIL_ESTOQUE,CTB_CONTA_PLANO_ESTOQUE.DESC_CONTA AS desc_conta_estoque,
					FILIAIS.MATRIZ AS matriz_contabil,Cad_MC.Razao_social as Razao_social_MC,Cad_MC.cgc_cpf as cgc_cpf_MC,
							Cad_MF.Razao_social as Razao_social_MF,Cad_MF.cgc_cpf as cgc_cpf_MF,
						    FILIAIS.COD_FILIAL,Cad_FL.RG_IE,Cad_FL.CGC_CPF,
						    FILIAIS.CGC_CPF AS CNPJ_MATRIZ_FISCAL, FILIAIS.COD_FILIAL as cod_matriz_fiscal,FILIAIS.MATRIZ_FISCAL,
					CM_ESTOQUE_MP_COMPOSICAO.QTDE, CM_ESTOQUE_MP_COMPOSICAO.VALOR,  CM_ITEM_COMPOSICAO.COMPOE_CUSTO_MEDIO, 
					CTB_CONTA_PLANO.CONTA_CONTABIL, CTB_CONTA_PLANO.DESC_CONTA, CM_ESTOQUE_MP_COMPOSICAO.RATEIO_FILIAL, 
					CTB_FILIAL_RATEIO.DESC_RATEIO_FILIAL, CM_ESTOQUE_MP_COMPOSICAO.RATEIO_CENTRO_CUSTO, 
					CTB_CENTRO_CUSTO_RATEIO.DESC_RATEIO_CENTRO_CUSTO,
					MATERIAIS.DESC_MATERIAL,MATERIAIS.GRUPO, MATERIAIS.SUBGRUPO,
					MATERIAIS_CORES.DESC_COR_MATERIAL,MATERIAIS.UNID_ESTOQUE AS Unidade,MATERIAIS.classif_fiscal
			  FROM CM_ESTOQUE_MP_COMPOSICAO 
			 INNER JOIN FILIAIS ON CM_ESTOQUE_MP_COMPOSICAO.FILIAL = FILIAIS.FILIAL 
			 INNER JOIN CM_FECHAMENTO_CUSTO_MEDIO ON CM_ESTOQUE_MP_COMPOSICAO.COD_CUSTO_MEDIO = CM_FECHAMENTO_CUSTO_MEDIO.COD_CUSTO_MEDIO 
			  LEFT OUTER JOIN CM_ITEM_COMPOSICAO ON CM_ITEM_COMPOSICAO.ITEM_COMPOSICAO = CM_ESTOQUE_MP_COMPOSICAO.ITEM_COMPOSICAO 
			  LEFT OUTER JOIN CTB_CONTA_PLANO ON CM_ESTOQUE_MP_COMPOSICAO.CONTA_CONTABIL = CTB_CONTA_PLANO.CONTA_CONTABIL 
			  LEFT JOIN CTB_FILIAL_RATEIO ON CM_ESTOQUE_MP_COMPOSICAO.RATEIO_FILIAL = CTB_FILIAL_RATEIO.RATEIO_FILIAL 
			  LEFT JOIN CTB_CENTRO_CUSTO_RATEIO ON CM_ESTOQUE_MP_COMPOSICAO.RATEIO_CENTRO_CUSTO = CTB_CENTRO_CUSTO_RATEIO.RATEIO_CENTRO_CUSTO 
			  left join CADASTRO_CLI_FOR Cad_FL ON FILIAIS.FILIAL=Cad_FL.NOME_CLIFOR
			  left join CADASTRO_CLI_FOR Cad_MC ON FILIAIS.MATRIZ=Cad_MC.NOME_CLIFOR
			  left join CADASTRO_CLI_FOR Cad_MF ON FILIAIS.MATRIZ_FISCAL=Cad_MF.NOME_CLIFOR
			  left join MATERIAIS ON CM_ESTOQUE_MP_COMPOSICAO.MATERIAL=MATERIAIS.MATERIAL 
			  left join MATERIAIS_CORES ON CM_ESTOQUE_MP_COMPOSICAO.MATERIAL=MATERIAIS_CORES.MATERIAL AND CM_ESTOQUE_MP_COMPOSICAO.COR_MATERIAL=MATERIAIS_CORES.COR_MATERIAL
			  LEFT JOIN CTB_CONTA_PLANO AS CTB_CONTA_PLANO_ESTOQUE ON MATERIAIS.CONTA_CONTABIL = CTB_CONTA_PLANO_ESTOQUE.CONTA_CONTABIL 
			 WHERE CM_ESTOQUE_MP_COMPOSICAO.COD_CUSTO_MEDIO = ?V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_MP.cod_custo_medio
			   and (CM_ESTOQUE_MP_COMPOSICAO.ITEM_COMPOSICAO='000' or CM_ESTOQUE_MP_COMPOSICAO.ITEM_COMPOSICAO='999') 
			ORDER BY CM_ESTOQUE_MP_COMPOSICAO.DATA_SALDO, CM_ESTOQUE_MP_COMPOSICAO.ITEM_COMPOSICAO, CM_ESTOQUE_MP_COMPOSICAO.FILIAL, CM_ESTOQUE_MP_COMPOSICAO.MATERIAL, CM_ESTOQUE_MP_COMPOSICAO.COR_MATERIAL
		ENDTEXT 

		SELECT V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_MP
		GO top
		f_select(xSel_Comp_CM,'vTMP_Fechamento_Custo_Medio_Base',ALIAS())
	ENDIF
	
	f_Wait('Aguarde... (Gerando Cursor: Custos)')

	xSl_Cur = ' a.* '+;
			  '  FROM vTMP_Fechamento_Custo_Medio_Base a '+;
			  '  JOIN V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_MP b ON a.cod_custo_medio=b.cod_custo_medio AND a.filial=b.filial '+;
			  '	  AND a.material=b.material and a.cor_material=b.cor_material'

	SELECT &xSl_Cur into cursor vTMP_Fechamento_Custo_Medio Readwrite 
	
	f_wait()

ENDFUNC
*====================================================================================================================================================*



*====================================================================================================================================================*
FUNCTION Fx_Processa_Modelo3_CM

	=Fx_009155_Init_Kardex(.f.)

	SELECT cod_custo_medio,data_saldo,data_cardex,data_anterior,;
		   matriz_fiscal,Razao_Social_MF,filial,cod_filial,cgc_cpf,rg_ie,;
		   material,desc_material,cor_material,desc_cor_material,unidade,classif_fiscal,doc,emissao,Conta_Contabil_movto,;
		   ABS(Qtde_Mov) as Qtde,  ABS(Valor_Mov) as valor,valor_imposto_agregar as IPI_Valor,;
		   qtde_ant_ini as Estoque_Inicial,;
		   qtde_atual as Estoque, Media_atual as Custo,;
		   Especie_Serie,Serie_NF,CFOP,ES,;
		   IIF(INLIST(ALLTRIM(item_composicao),'006','007','010'),1,IIF(INLIST(ALLTRIM(item_composicao),'008','009','303','304','402'),2,3)) as Codigo_Entrada_Saida,;
		   SPACE(1) Obs,000000000 as _Pagina ;
	  FROM Cur_Result ;
	 ORDER BY 1,2,4,6,10,12,17 ;
	  INTO CURSOR Cur_Result3 READWRITE 
	  
	SELECT Cur_Result3
	GO top
			
ENDFUNC
*====================================================================================================================================================*



*====================================================================================================================================================*
FUNCTION Fx_Proc_CM_if

	SELECT V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_MP 
		GO top
		xPorCor = !f_Vazio(Cor_material) && Identifica que foi gerado por cor
		xDt_Sld = DTOS(V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_MP.Data_Saldo)
		
	xFieldsAF = 'cod_custo_medio,DTOS(data_saldo) data_saldo,filial,material,cor_material,Qtde,Valor'
		SELECT &xFieldsAF FROM vTMP_Fechamento_custo_medio WHERE Item_Composicao=='000' INTO CURSOR Cur_Saldo_Ant 
		SELECT &xFieldsAF FROM vTMP_Fechamento_custo_medio WHERE Item_Composicao=='999' INTO CURSOR Cur_Saldo_Fim 

	SELECT Cur_Saldo_Ant 
		INDEX on ALLTRIM(cod_custo_medio)+data_saldo+ALLTRIM(filial)+ALLTRIM(material)+ALLTRIM(cor_material) TAG iAnt

	SELECT Cur_Saldo_Fim 
		INDEX on ALLTRIM(cod_custo_medio)+data_saldo+ALLTRIM(filial)+ALLTRIM(material)+ALLTRIM(cor_material) TAG iSai
			   	   
	*--- Atualiza Saldos
	SELECT Cur_Result
	COUNT TO xTReg
	xRatu = 0

	GO top
	DO whil !EOF()
		xSeek = ALLTRIM(cod_custo_medio)+xDt_Sld+ALLTRIM(filial)+ALLTRIM(material)+ALLTRIM(cor_material)

		SELECT Cur_Saldo_Ant 
			SEEK xSeek
		SELECT Cur_Saldo_Fim
			SEEK xSeek
		
		xSAnt_iQ = Cur_Saldo_Ant.Qtde
		xSAnt_iV = Cur_Saldo_Ant.Valor
		*---
		
		SELECT Cur_Result
			REPLACE Qtde_Ant_Ini WITH xSAnt_iQ ,Valor_ant_Ini WITH xSAnt_iV,;
					Qtde_Atu_fim WITH Cur_Saldo_Fim.Qtde ,Valor_Atu_Fim WITH Cur_Saldo_Fim.Valor

		xK = (Cod_custo_medio+Filial+material+Cor_material)
		SCAN WHILE (Cod_custo_medio+Filial+material+Cor_material) = xK 
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

ENDFUNC
*====================================================================================================================================================*



*====================================================================================================================================================*
FUNCTION Fx_Proc_CM_if_Agr

	SELECT V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_MP 
		GO top
		xPorCor = !f_Vazio(Cor_material) && Identifica que foi gerado por cor
		xDt_Sld = DTOS(V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_MP.Data_Saldo)

	xFieldsAF = 'cod_custo_medio,DTOS(data_saldo) data_saldo,material,cor_material,SUM(Qtde) Qtde,SUM(Valor) Valor'
		SELECT &xFieldsAF FROM vTMP_Fechamento_custo_medio GROUP BY 1,2,3,4 WHERE Item_Composicao=='000' INTO CURSOR Cur_Saldo_Ant 
		SELECT &xFieldsAF FROM vTMP_Fechamento_custo_medio GROUP BY 1,2,3,4 WHERE Item_Composicao=='999' INTO CURSOR Cur_Saldo_Fim 

	SELECT Cur_Saldo_Ant 
		INDEX on ALLTRIM(cod_custo_medio)+data_saldo+ALLTRIM(material)+ALLTRIM(cor_material) TAG iAnt

	SELECT Cur_Saldo_Fim 
		INDEX on ALLTRIM(cod_custo_medio)+data_saldo+ALLTRIM(material)+ALLTRIM(cor_material) TAG iSai
			   	   
	*--- Atualiza Saldos
	SELECT Cur_Result
	COUNT TO xTReg
	xRatu = 0

	GO top
	DO whil !EOF()
		xSeek = ALLTRIM(cod_custo_medio)+xDt_Sld+ALLTRIM(material)+ALLTRIM(cor_material)

		SELECT Cur_Saldo_Ant 
			SEEK xSeek
		SELECT Cur_Saldo_Fim
			SEEK xSeek
		
		xSAnt_iQ = Cur_Saldo_Ant.Qtde
		xSAnt_iV = Cur_Saldo_Ant.Valor
		*---
		
		SELECT Cur_Result
			REPLACE Qtde_Ant_Ini WITH xSAnt_iQ ,Valor_ant_Ini WITH xSAnt_iV,;
					Qtde_Atu_fim WITH Cur_Saldo_Fim.Qtde ,Valor_Atu_Fim WITH Cur_Saldo_Fim.Valor

		xK = (Cod_custo_medio+material+Cor_material)
		SCAN WHILE (Cod_custo_medio+material+Cor_material) = xK 
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

ENDFUNC
*====================================================================================================================================================*



*====================================================================================================================================================*
FUNCTION Fx_Add_Itens_Sem_Mov_Kardex
LPARAMETERS pProcAgr

*-- Adicionar Itens que Não Tem Kardex, porém com CM
	f_wait('Adicionando Itens CM (Sem Movimentação no Kardex)')
	xWhereCta =  IIF(TYPE('OpRelPorCta')='L' and OpRelPorCta,"conta_contabil_estoque='" + OpRelCtaEst + "'","1=1")
	
	IF pProcAgr
		xFields_Sel = "Distinct a.cod_custo_medio,a.data_anterior,a.data_saldo,a.data_cardex,NVL(a.data_anterior,{}) as Emissao,'  >' as item_composicao,'(Sem Movimentação)' as desc_item_composicao,"+;
					  "a.conta_contabil_estoque,a.desc_conta_estoque,"+;
					  "a.matriz_contabil,a.Razao_social_MC,a.cgc_cpf_MC,"+;
					  "space(1) as matriz_fiscal,space(1) as Razao_social_MF,space(1) as cod_matriz_fiscal,space(1) as cnpj_matriz_fiscal,"+;
					  "space(1) as filial,space(1) as cod_filial,space(1) as CGC_CPF,space(1) as RG_IE,"+;
					  "a.material,a.cor_material,a.desc_material,a.grupo,a.subgrupo,a.desc_cor_material,a.Unidade,a.classif_fiscal"
						   
		xFields_Ins = "cod_custo_medio,data_anterior,data_saldo,data_cardex,Emissao,item_composicao,desc_item_composicao,"+;
					  "conta_contabil_estoque,desc_conta_estoque,"+;
					  "matriz_contabil,Razao_social_MC,cgc_cpf_MC,"+;
					  "matriz_fiscal,Razao_social_MF,cod_matriz_fiscal,cnpj_matriz_fiscal,"+;
					  "filial,cod_filial,CGC_CPF,RG_IE,"+;
					  "material,cor_material,desc_material,grupo,subgrupo,desc_cor_material,Unidade,classif_fiscal"

			INSERT INTO vTMP_Estoque_Cardex (&xFields_Ins) ;
				SELECT &xFields_Sel FROM vTMP_Fechamento_custo_medio a;
				  JOIN V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_MP b ;
				    ON a.cod_custo_medio=b.cod_custo_medio AND a.material=b.material AND a.cor_material=b.cor_material AND a.filial=b.filial ;
				 WHERE a.cod_custo_medio+a.matriz_contabil+a.material+a.cor_material ;
				   	   not in (Select Distinct cod_custo_medio+matriz_contabil+material+cor_material from vTMP_Estoque_Cardex WHERE &xWhereCta)
	ELSE
		xFields_Sel = "Distinct a.cod_custo_medio,a.data_anterior,a.data_saldo,a.data_cardex,NVL(a.data_anterior,{}) as Emissao,'  >' as item_composicao,'(Sem Movimentação)' as desc_item_composicao,"+;
					  "a.conta_contabil_estoque,a.desc_conta_estoque,"+;
					  "a.matriz_contabil,a.Razao_social_MC,a.cgc_cpf_MC,"+;
					  "a.matriz_fiscal,a.Razao_social_MF,a.cod_matriz_fiscal,a.cnpj_matriz_fiscal,"+;
					  "a.filial,a.cod_filial,a.CGC_CPF,a.RG_IE,"+;
					  "a.material,a.cor_material,a.desc_material,a.grupo,a.subgrupo,a.desc_cor_material,a.Unidade,a.classif_fiscal"
						   
		xFields_Ins = "cod_custo_medio,data_anterior,data_saldo,data_cardex,Emissao,item_composicao,desc_item_composicao,"+;
					  "conta_contabil_estoque,desc_conta_estoque,"+;
					  "matriz_contabil,Razao_social_MC,cgc_cpf_MC,"+;
					  "matriz_fiscal,Razao_social_MF,cod_matriz_fiscal,cnpj_matriz_fiscal,"+;
					  "filial,cod_filial,CGC_CPF,RG_IE,"+;
					  "material,cor_material,desc_material,grupo,subgrupo,desc_cor_material,Unidade,classif_fiscal"

			INSERT INTO vTMP_Estoque_Cardex (&xFields_Ins) ;
				SELECT &xFields_Sel FROM vTMP_Fechamento_custo_medio a;
				  JOIN V_FECHAMENTO_CUSTO_MEDIO_01_ESTOQUE_MP b ;
				    ON a.cod_custo_medio=b.cod_custo_medio AND a.material=b.material AND a.cor_material=b.cor_material AND a.filial=b.filial ;
				 WHERE a.cod_custo_medio+a.matriz_contabil+a.matriz_fiscal+a.filial+a.material+a.cor_material ;
				   	   not in (Select Distinct cod_custo_medio+matriz_contabil+matriz_fiscal+filial+material+cor_material From vTMP_Estoque_Cardex WHERE &xWhereCta)
	ENDIF
	
	f_wait()

ENDFUNC
*====================================================================================================================================================*
