*-- HISTORICO DE ALTERAÇÕES 
** 20/05/2016 - CARLOS ALBERTO - ID 1937    - #2# - 01.16.010 - REVISÃO NA TOTALIZAÇÃO DO VALOR CONTÁBIL.
** 24/02/2016 - CARLOS ALBERTO - ID 1937    - #1# - 01.16.010 - ALTERAÇÃO NA SELEÇÃO DE DADOS PARA TOTALIZAÇÃO DO VALOR CONTABIL, INCLUIDA A SITUAÇÃO TRIBUTÁRIA PARA DIFERENCIAR OS ITENS.
*-------------------------------------------------------------------------------

PROCEDURE Fx_Report_Begin

	Public xrel_data_ini,xrel_data_fim,xrel_cent,xrel_pagini,xQb_Desc,xSubQb_Desc
	Local lcNF As String

	xrel_data_ini=o_012005.lx_form1.lx_pageframe1.page2.lx_faixa_data1.data_inicial.Value
	xrel_data_fim=o_012005.lx_form1.lx_pageframe1.page2.lx_faixa_data1.data_final.Value

	xrel_pagini=0
	If Messagebox('Deseja Alterar a Sequência de Numeração da Página Inicial?',4+32+256,'Atenção')=6
		xrel_pagini = Val(Inputbox('Página Inicial','Contabilidade'))
		xrel_pagini = Iif(xrel_pagini>0,xrel_pagini-1,0)
	Endif

	*** Trabalhar com a data no formato dd/mm/aaaa
	xrel_cent=Set('century')
	Set Century On

	DECLARE xQb_Desc(4)
		xQb_Desc(1) = 'Registro de Saidas'
		xQb_Desc(2) = 'Totais do Periodo'
		xQb_Desc(3) = 'Resumo das Operações e Prestações por Codigo Fiscal de Operação'
		xQb_Desc(4) = 'Demonstrativo Por Estado de Destino da Mercadoria ou da Prestação de Serviço'

	DECLARE xSubQb_Desc(6)
		xSubQb_Desc(1) = '1. Saida Para o Estado'
		xSubQb_Desc(2) = 'Sub Total'
		xSubQb_Desc(3) = '2. Saida para Fora do Estado'
		xSubQb_Desc(4) = 'Sub Total'
		xSubQb_Desc(5) = '3. Saida para o Exterior'
		xSubQb_Desc(6) = 'Sub Total'

ENDPROC 
*---------------------------------------------------------------------------------------------------------------------------------------------------*


*---------------------------------------------------------------------------------------------------------------------------------------------------*
PROCEDURE Fx_Report_Qb_Detail
LPARAMETERS pImposto

	*-- Selecionando Empresas
	f_select('select * from empresa','tmp_empresa')
	sele tmp_empresa
	index on empresa tag iEmpresa

	xWhere = IIF(pImposto=1,'id_imposto=1','1=1')
	Select *,base_imposto  as dif_ipi,;
			Right('00'+Alltrim(Str(Month(emissao))),2) + '/' + Alltrim(Str(Year(emissao))) As mes, .F. As _NF,;
		    1 as Qb, 0 as SubQb, SPACE(40) as Desc_SubQb ;
	  From v_lf_registro_saida_01_filtro WHERE &xWhere into Cursor cur_lf_registro_saida_01_filtro Readwrite

	*---Legenda Obs
	Sele cur_lf_registro_saida_01_filtro
		Replace All empresa 				With '' For Isnull(empresa)
		Replace All matriz_fiscal   		With '' For Isnull(matriz_fiscal)
		Replace All emissao 				With {} For Isnull(emissao)
		Replace All nf_saida 				With '' For Isnull(nf_saida)
		Replace All nf_saida_final 			With '' For Isnull(nf_saida_final)
		Replace All especie 				With '' For Isnull(especie)
		Replace All serie_nf 				With '' For Isnull(serie_nf)
		replace All serie_nf_oficial		WITH '' FOR ISNULL(serie_nf_oficial)
		Replace All cod_clifor 				With '' For Isnull(cod_clifor)
		Replace All uf 						With '' For Isnull(uf)
		Replace All conta_contabil		  	With '' For Isnull(conta_contabil)
		Replace All codigo_fiscal_operacao	With '' For Isnull(codigo_fiscal_operacao)
		REPLACE All Obs WITH '' FOR isnull(OBS)

		*!*			IF pImposto=1 && P2a: não sair NADA de IPI, e nada de outras obs Exceção: CFOP=5929 
		*!*				REPLACE All Obs WITH '' FOR codigo_fiscal_operacao<>'5929' AND ALLTRIM(Obs)<>'CANCELADA'			
		*!*			ELSE && só mostrar obs ref. IPI
		*!*				REPLACE All Obs WITH '' FOR 'IPI' $ UPPER(OBS)
		*!*				REPLACE All Obs WITH '' FOR 'VALOR CONTÁBIL' $ UPPER(OBS)

		*!*				*-- Dif IPI (Distinct): (que tb aparece no campo OBS)
		*!*				SELECT Distinct empresa,matriz_fiscal,nf_SAIDA,serie_nf,;
		*!*					   (valor_contabil-(base_imposto+valor_imposto_isento+valor_imposto_outros)) as dif_ipi ;
		*!*				  FROM cur_lf_registro_saida_01_filtro ;
		*!*				 WHERE (valor_contabil-(base_imposto+valor_imposto_isento+valor_imposto_outros))<>0 ;
		*!*				   AND IMPOSTO='IPI' AND (valor_imposto+valor_imposto_isento)=0 INTO CURSOR Cur_Distinct_Dif_Ipi

		*!*				SELECT Cur_Distinct_Dif_Ipi
		*!*				SCAN
		*!*					SELECT cur_lf_registro_saida_01_filtro
		*!*					LOCATE FOR empresa=Cur_Distinct_Dif_Ipi.empresa AND matriz_fiscal=Cur_Distinct_Dif_Ipi.matriz_fiscal AND nf_saida=Cur_Distinct_Dif_Ipi.nf_saida AND serie_nf=Cur_Distinct_Dif_Ipi.serie_nf
		*!*					IF !EOF()
		*!*						REPLACE dif_ipi WITH Cur_Distinct_Dif_Ipi.dif_ipi
		*!*					endif
		*!*				ENDSCAN
		*!*				*--

		*!*				Sele cur_lf_registro_saida_01_filtro
		*!*				REPLACE obs with 'IPI:' + ALLTRIM(TRANSFORM(dif_ipi,'9999 999 999.99')) FOR dif_ipi<>0 AND id_imposto=2
		*!*			ENDIF

	Sele cur_lf_registro_saida_01_filtro
		xIndex = "str(empresa,4)+matriz_fiscal+STR(Qb)+STR(SubQb)+dtos(emissao)+nf_saida+especie+serie_nf+iif(ISNULL(cod_clifor),'',cod_clifor)+uf+conta_contabil+codigo_fiscal_operacao+STR(id_imposto)"
		Index On &xIndex Tag iSai01

	*--
	STORE '' TO lcNF,lcImp  
	Scan
		If Alltrim(lcNF) # (Alltrim(cur_lf_registro_saida_01_filtro.especie) + ;
				Alltrim(cur_lf_registro_saida_01_filtro.serie_nf) + ;
				Alltrim(cur_lf_registro_saida_01_filtro.nf_saida) + ;
				Alltrim(cur_lf_registro_saida_01_filtro.NF_Saida_Final) + ;
				Padl(Day(cur_lf_registro_saida_01_filtro.emissao), 2, "0") + ;
				Alltrim(cur_lf_registro_saida_01_filtro.uf)) OR ALLTRIM(imposto)==lcImp 

			Replace _NF With .T.

			lcNF = Alltrim(cur_lf_registro_saida_01_filtro.especie) + ;
				   Alltrim(cur_lf_registro_saida_01_filtro.serie_nf) + ;
				   Alltrim(cur_lf_registro_saida_01_filtro.nf_saida) + ;
				   Alltrim(cur_lf_registro_saida_01_filtro.NF_Saida_Final) + ;
				   Padl(Day(cur_lf_registro_saida_01_filtro.emissao), 2, "0") + ;
				   Alltrim(cur_lf_registro_saida_01_filtro.uf)
			lcImp = ALLTRIM(imposto)	
		Endif
	Endscan
	Go Top
	*--

ENDFUNC 
*---------------------------------------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------------------------------------*
PROCEDURE Fx_Report_Quebras
LPARAMETERS xTpQb

	DO case
	CASE xTpQb=2 && Totais

		*===
		SELECT empresa,matriz_fiscal,razao_social_matriz_fiscal,rg_ie_matriz_fiscal,cgc_cpf_matriz_fiscal,mes,id_imposto,imposto,;
			   Sum(base_imposto) base_imposto,Sum(valor_imposto) valor_imposto,SUM(dif_ipi) dif_ipi,;
			   sum(valor_imposto_isento) As valor_imposto_isento,Sum(valor_imposto_outros) As valor_imposto_outros ;
		  FROM cur_lf_registro_saida_01_filtro WHERE Qb=1 GROUP BY 1,2,3,4,5,6,7,8 INTO CURSOR Cur_Tot_Impostos_Agr READWRITE 
	
		SELECT Cur_Tot_Impostos_Agr
		GO TOP 
		DO whil !EOF()
			xempresa = empresa
			xMatriz  = matriz_fiscal
			xmes	 = mes

			*--- total distinct para valor contabil #1#	#2# SITUACAO_TRIBUTARIA, 
			Select Distinct empresa,matriz_fiscal,nf_saida,serie_nf, cod_clifor, codigo_fiscal_operacao, mes, valor_contabil ;
			  From cur_lf_registro_saida_01_filtro ;
			 WHERE Qb=1 and empresa=?xempresa And matriz_fiscal=?xMatriz And mes=?xmes AND (id_imposto = 1 OR id_imposto = 36) ;
			  Into Cursor cur_vl_contabil_distinct

			Select Sum(valor_contabil) valor_contabil From cur_vl_contabil_distinct Into Cursor cur_vl_contabil_sum

			SELECT Cur_Tot_Impostos_Agr
			xCount = 0
			SCAN WHILE empresa=xempresa and matriz_fiscal=xMatriz AND mes=xmes
				xCount = xCount+1

				*==
				FOR kk=1 TO 3 && 1=Total para o Detalhe/2=Total para resumo por CFOP/3=Total para resumo por UF
					xSubQb = 9
					IF kk=1
						xxTpQb = xTpQb
						xxSubQb_Desc = ''
					ELSE
						xxTpQb = IIF(kk=2,3,4)
						xxSubQb_Desc = 'T o t a l :'
					ENDIF
					
					SELECT cur_lf_registro_saida_01_filtro 
					append blank
							
					REPLACE empresa 					WITH xempresa,;
							matriz_fiscal 				WITH xMatriz, ;
							razao_social_matriz_fiscal 	WITH Cur_Tot_Impostos_Agr.razao_social_matriz_fiscal,;
							rg_ie_matriz_fiscal			WITH Cur_Tot_Impostos_Agr.rg_ie_matriz_fiscal,;
							cgc_cpf_matriz_fiscal		WITH Cur_Tot_Impostos_Agr.cgc_cpf_matriz_fiscal,;
							mes 						WITH xmes,;
							Qb with xxTpQb, SubQb with xSubQb, Desc_SubQb with xxSubQb_Desc,;
							id_imposto				with Cur_Tot_Impostos_Agr.id_imposto,;
							imposto     			with Cur_Tot_Impostos_Agr.imposto,;
							base_imposto			with Cur_Tot_Impostos_Agr.base_imposto,;
							valor_imposto			with Cur_Tot_Impostos_Agr.valor_imposto,;
							valor_imposto_isento	with Cur_Tot_Impostos_Agr.valor_imposto_isento,;
							valor_imposto_outros 	with Cur_Tot_Impostos_Agr.valor_imposto_outros 
							IF Cur_Tot_Impostos_Agr.dif_ipi<>0 AND id_imposto=2 AND kk<>3
								REPLACE obs with 'IPI:' + ALLTRIM(TRANSFORM(Cur_Tot_Impostos_Agr.dif_ipi,'9999 999 999.99'))
							ENDIF
		
					IF xCount=1
						replace valor_contabil WITH cur_vl_contabil_sum.valor_contabil
					ENDIF
				ENDFOR
				*==

			ENDSCAN
		ENDDO
		*===

	CASE xTpQb=3 && Por CFOP
		
		*===
		FOR kk = 5 TO 7 && 1=No estado/2=Fora do estado/3=Exterior/

			*-- Detalhe:
			DO CASE
			CASE kk=5
				xSubQb = 1
			CASE kk=6
				xSubQb = 3
			OTHERWISE
				xSubQb = 5
			ENDCASE 
	
			SELECT empresa,matriz_fiscal,razao_social_matriz_fiscal,rg_ie_matriz_fiscal,cgc_cpf_matriz_fiscal,mes,codigo_fiscal_operacao,id_imposto,imposto,;
				   Sum(base_imposto) base_imposto,Sum(valor_imposto) valor_imposto,SUM(dif_ipi) dif_ipi,;
				   sum(valor_imposto_isento) As valor_imposto_isento,Sum(valor_imposto_outros) As valor_imposto_outros ;
			  FROM cur_lf_registro_saida_01_filtro WHERE Qb=1 AND VAL(LEFT(codigo_fiscal_operacao,1))=kk ;
			 GROUP BY 1,2,3,4,5,6,7,8,9 INTO CURSOR Cur_Tot_Impostos_Agr READWRITE 
		
			SELECT Cur_Tot_Impostos_Agr
			GO TOP 
			DO whil !EOF()
				xempresa = empresa
				xMatriz  = matriz_fiscal
				xmes	 = mes
				xCFOP	 = codigo_fiscal_operacao

				*--- total distinct para valor contabil #1#	#2# SITUACAO_TRIBUTARIA, 
				Select Distinct empresa,matriz_fiscal,nf_saida,serie_nf, cod_clifor, codigo_fiscal_operacao, mes, valor_contabil ;
				  From cur_lf_registro_saida_01_filtro ;
				 WHERE Qb=1 and empresa=?xempresa And matriz_fiscal=?xMatriz And mes=?xmes AND codigo_fiscal_operacao=xCFOP AND (id_imposto = 1 OR id_imposto = 36) ;
				  Into Cursor cur_vl_contabil_distinct

				Select Sum(valor_contabil) valor_contabil From cur_vl_contabil_distinct Into Cursor cur_vl_contabil_sum

				SELECT Cur_Tot_Impostos_Agr
				xCount = 0
				SCAN WHILE empresa=xempresa and matriz_fiscal=xMatriz AND mes=xmes  AND codigo_fiscal_operacao=xCFOP
					xCount = xCount+1
					SELECT cur_lf_registro_saida_01_filtro 
					append blank
							
					REPLACE empresa 					with xempresa,;
							matriz_fiscal 				with xMatriz,;
							razao_social_matriz_fiscal 	WITH Cur_Tot_Impostos_Agr.razao_social_matriz_fiscal,;
							rg_ie_matriz_fiscal			WITH Cur_Tot_Impostos_Agr.rg_ie_matriz_fiscal,;
							cgc_cpf_matriz_fiscal		WITH Cur_Tot_Impostos_Agr.cgc_cpf_matriz_fiscal,;
							mes 						WITH xmes,;
							codigo_fiscal_operacao 		WITH xCFOP,;
							Qb with xTpQb, SubQb with xSubQb, Desc_SubQb with xSubQb_Desc(xSubQb),;
							id_imposto				with Cur_Tot_Impostos_Agr.id_imposto,;
							imposto     			with Cur_Tot_Impostos_Agr.imposto,;
							base_imposto			with Cur_Tot_Impostos_Agr.base_imposto,;
							valor_imposto			with Cur_Tot_Impostos_Agr.valor_imposto,;
							valor_imposto_isento	with Cur_Tot_Impostos_Agr.valor_imposto_isento,;
							valor_imposto_outros 	with Cur_Tot_Impostos_Agr.valor_imposto_outros 
							IF Cur_Tot_Impostos_Agr.dif_ipi<>0 AND id_imposto=2
								REPLACE obs with 'IPI:' + ALLTRIM(TRANSFORM(Cur_Tot_Impostos_Agr.dif_ipi,'9999 999 999.99'))
							ENDIF
		
					IF xCount=1
						replace valor_contabil WITH cur_vl_contabil_sum.valor_contabil
					ENDIF
				ENDSCAN
			ENDDO


			*-- Total:
			DO CASE
			CASE kk=5
				xSubQb = 2
			CASE kk=6
				xSubQb = 4
			OTHERWISE
				xSubQb = 6
			ENDCASE 

			SELECT empresa,matriz_fiscal,razao_social_matriz_fiscal,rg_ie_matriz_fiscal,cgc_cpf_matriz_fiscal,mes,VAL(LEFT(codigo_fiscal_operacao,1)) as tipo_CFOP,id_imposto,imposto,;
				   Sum(base_imposto) base_imposto,Sum(valor_imposto) valor_imposto,SUM(dif_ipi) dif_ipi,;
				   sum(valor_imposto_isento) As valor_imposto_isento,Sum(valor_imposto_outros) As valor_imposto_outros ;
			  FROM cur_lf_registro_saida_01_filtro WHERE Qb=1 AND VAL(LEFT(codigo_fiscal_operacao,1))=kk ;
			 GROUP BY 1,2,3,4,5,6,7,8,9 INTO CURSOR Cur_Tot_Impostos_Agr READWRITE 
		
			SELECT Cur_Tot_Impostos_Agr
			GO TOP 
			DO whil !EOF()
				xempresa = empresa
				xMatriz  = matriz_fiscal
				xmes	 = mes
				xtCFOP	 = tipo_CFOP

				*--- total distinct para valor contabil  #1# #2# SITUACAO_TRIBUTARIA, 
				Select Distinct empresa,matriz_fiscal,nf_saida,serie_nf, cod_clifor, codigo_fiscal_operacao, mes, valor_contabil ;
				  From cur_lf_registro_saida_01_filtro ;
				 WHERE Qb=1 and empresa=?xempresa And matriz_fiscal=?xMatriz And mes=?xmes AND VAL(LEFT(codigo_fiscal_operacao,1))=xtCFOP AND (id_imposto = 1 OR id_imposto = 36) ;
				  Into Cursor cur_vl_contabil_distinct

				Select Sum(valor_contabil) valor_contabil From cur_vl_contabil_distinct Into Cursor cur_vl_contabil_sum

				SELECT Cur_Tot_Impostos_Agr
				xCount = 0
				SCAN WHILE empresa=xempresa and matriz_fiscal=xMatriz AND mes=xmes  AND tipo_CFOP=xtCFOP 
					xCount = xCount+1
					SELECT cur_lf_registro_saida_01_filtro 
					append blank
							
					REPLACE empresa 					with xempresa,;
							matriz_fiscal 				with xMatriz,;
							razao_social_matriz_fiscal 	WITH Cur_Tot_Impostos_Agr.razao_social_matriz_fiscal,;
							rg_ie_matriz_fiscal			WITH Cur_Tot_Impostos_Agr.rg_ie_matriz_fiscal,;
							cgc_cpf_matriz_fiscal		WITH Cur_Tot_Impostos_Agr.cgc_cpf_matriz_fiscal,;
							mes WITH xmes,;
							Qb with xTpQb, SubQb with xSubQb, Desc_SubQb with xSubQb_Desc(xSubQb),;
							id_imposto				with Cur_Tot_Impostos_Agr.id_imposto,;
							imposto     			with Cur_Tot_Impostos_Agr.imposto,;
							base_imposto			with Cur_Tot_Impostos_Agr.base_imposto,;
							valor_imposto			with Cur_Tot_Impostos_Agr.valor_imposto,;
							valor_imposto_isento	with Cur_Tot_Impostos_Agr.valor_imposto_isento,;
							valor_imposto_outros 	with Cur_Tot_Impostos_Agr.valor_imposto_outros 
							IF Cur_Tot_Impostos_Agr.dif_ipi<>0 AND id_imposto=2
								REPLACE obs with 'IPI:' + ALLTRIM(TRANSFORM(Cur_Tot_Impostos_Agr.dif_ipi,'9999 999 999.99'))
							ENDIF
		
					IF xCount=1
						replace valor_contabil WITH cur_vl_contabil_sum.valor_contabil
					ENDIF
				ENDSCAN
			ENDDO
			*--
	
		ENDFOR
		*===

	CASE xTpQb=4 && Por UF

		*===
		for kk = 1 to 2 && 1=Contribuinte / 2=Não Contribuinte
			xContrib = (kk - 1)
		
			*-- Detalhe:
			xOrdContrib = IIF(xContrib=0,1,3)

			SELECT empresa,matriz_fiscal,razao_social_matriz_fiscal,rg_ie_matriz_fiscal,cgc_cpf_matriz_fiscal,mes,uf,id_imposto,imposto,;
				   Sum(base_imposto) base_imposto,Sum(valor_imposto) valor_imposto,SUM(dif_ipi) dif_ipi,;
				   sum(valor_imposto_isento) As valor_imposto_isento,Sum(valor_imposto_outros) As valor_imposto_outros ;
			  FROM cur_lf_registro_saida_01_filtro WHERE Qb=1 AND Contribuinte=xContrib GROUP BY 1,2,3,4,5,6,7,8,9 INTO CURSOR Cur_Tot_Impostos_Agr READWRITE 
		
			SELECT Cur_Tot_Impostos_Agr
			GO TOP 
			DO whil !EOF()
				xempresa = empresa
				xMatriz  = matriz_fiscal
				xmes	 = mes
				xUF		 = uf

				*--- total distinct para valor contabil  #1# #2#	SITUACAO_TRIBUTARIA, 
				Select Distinct empresa,matriz_fiscal,nf_saida,serie_nf, cod_clifor, codigo_fiscal_operacao, mes, valor_contabil ;
				  From cur_lf_registro_saida_01_filtro ;
				 WHERE Qb=1 and empresa=?xempresa And matriz_fiscal=?xMatriz And mes=?xmes AND uf=xUF AND (id_imposto = 1 OR id_imposto = 36) ;
				  Into Cursor cur_vl_contabil_distinct

				Select Sum(valor_contabil) valor_contabil From cur_vl_contabil_distinct Into Cursor cur_vl_contabil_sum

				SELECT Cur_Tot_Impostos_Agr
				xCount = 0
				SCAN WHILE empresa=xempresa and matriz_fiscal=xMatriz AND mes=xmes  AND uf=xUF
					xCount = xCount+1
					SELECT cur_lf_registro_saida_01_filtro 
					append blank

					REPLACE empresa 					with xempresa,;
							matriz_fiscal 				with xMatriz,;
							razao_social_matriz_fiscal 	WITH Cur_Tot_Impostos_Agr.razao_social_matriz_fiscal,;
							rg_ie_matriz_fiscal			WITH Cur_Tot_Impostos_Agr.rg_ie_matriz_fiscal,;
							cgc_cpf_matriz_fiscal		WITH Cur_Tot_Impostos_Agr.cgc_cpf_matriz_fiscal,;
							mes WITH xmes, uf WITH xUF,;
							Qb with xTpQb, SubQb with xOrdContrib, Desc_SubQb with IIF(xContrib=1,'Contribuinte','Não Contribuinte'),;
							id_imposto				with Cur_Tot_Impostos_Agr.id_imposto,;
							imposto     			with Cur_Tot_Impostos_Agr.imposto,;
							base_imposto			with Cur_Tot_Impostos_Agr.base_imposto,;
							valor_imposto			with Cur_Tot_Impostos_Agr.valor_imposto,;
							valor_imposto_isento	with Cur_Tot_Impostos_Agr.valor_imposto_isento,;
							valor_imposto_outros 	with Cur_Tot_Impostos_Agr.valor_imposto_outros 
							*!*								IF Cur_Tot_Impostos_Agr.dif_ipi<>0 AND id_imposto=2
							*!*									REPLACE obs with 'IPI:' + ALLTRIM(TRANSFORM(Cur_Tot_Impostos_Agr.dif_ipi,'9999 999 999.99'))
							*!*								ENDIF
		
					IF xCount=1
						replace valor_contabil WITH cur_vl_contabil_sum.valor_contabil
					ENDIF
				ENDSCAN
			ENDDO


			*-- Total:
			xOrdContrib = IIF(xContrib=0,2,4)

			SELECT empresa,matriz_fiscal,razao_social_matriz_fiscal,rg_ie_matriz_fiscal,cgc_cpf_matriz_fiscal,mes,Contribuinte,id_imposto,imposto,;
				   Sum(base_imposto) base_imposto,Sum(valor_imposto) valor_imposto,SUM(dif_ipi) dif_ipi,;
				   sum(valor_imposto_isento) As valor_imposto_isento,Sum(valor_imposto_outros) As valor_imposto_outros ;
			  FROM cur_lf_registro_saida_01_filtro WHERE Qb=1 AND Contribuinte=xContrib GROUP BY 1,2,3,4,5,6,7,8,9 INTO CURSOR Cur_Tot_Impostos_Agr READWRITE 
		
			SELECT Cur_Tot_Impostos_Agr
			GO TOP 
			DO whil !EOF()
				xempresa = empresa
				xMatriz  = matriz_fiscal
				xmes	 = mes

				*--- total distinct para valor contabil  #1# #2#	SITUACAO_TRIBUTARIA, 
				Select Distinct empresa,matriz_fiscal,nf_saida,serie_nf, cod_clifor, codigo_fiscal_operacao, mes, valor_contabil ;
				  From cur_lf_registro_saida_01_filtro ;
				 WHERE Qb=1 and empresa=?xempresa And matriz_fiscal=?xMatriz And mes=?xmes AND Contribuinte=xContrib AND (id_imposto = 1 OR id_imposto = 36) ;
				  Into Cursor cur_vl_contabil_distinct

				Select Sum(valor_contabil) valor_contabil From cur_vl_contabil_distinct Into Cursor cur_vl_contabil_sum

				SELECT Cur_Tot_Impostos_Agr
				xCount = 0
				SCAN WHILE empresa=xempresa and matriz_fiscal=xMatriz AND mes=xmes AND Contribuinte=xContrib
					xCount = xCount+1
					SELECT cur_lf_registro_saida_01_filtro 
					append blank

					REPLACE empresa 					with xempresa,;
							matriz_fiscal 				with xMatriz,;
							razao_social_matriz_fiscal 	WITH Cur_Tot_Impostos_Agr.razao_social_matriz_fiscal,;
							rg_ie_matriz_fiscal			WITH Cur_Tot_Impostos_Agr.rg_ie_matriz_fiscal,;
							cgc_cpf_matriz_fiscal		WITH Cur_Tot_Impostos_Agr.cgc_cpf_matriz_fiscal,;
							mes WITH xmes,;
							Qb with xTpQb, SubQb with xOrdContrib, Desc_SubQb with 'Sub Total',;
							id_imposto				with Cur_Tot_Impostos_Agr.id_imposto,;
							imposto     			with Cur_Tot_Impostos_Agr.imposto,;
							base_imposto			with Cur_Tot_Impostos_Agr.base_imposto,;
							valor_imposto			with Cur_Tot_Impostos_Agr.valor_imposto,;
							valor_imposto_isento	with Cur_Tot_Impostos_Agr.valor_imposto_isento,;
							valor_imposto_outros 	with Cur_Tot_Impostos_Agr.valor_imposto_outros 
							*!*								IF Cur_Tot_Impostos_Agr.dif_ipi<>0 AND id_imposto=2
							*!*									REPLACE obs with 'IPI:' + ALLTRIM(TRANSFORM(Cur_Tot_Impostos_Agr.dif_ipi,'9999 999 999.99'))
							*!*								ENDIF
		
					IF xCount=1
						replace valor_contabil WITH cur_vl_contabil_sum.valor_contabil
					ENDIF
				ENDSCAN
			ENDDO
			*--

		ENDFOR
		*===
		
	ENDCASE

ENDPROC 
*---------------------------------------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------------------------------------*
PROCEDURE Fx_Report_Relation

	*--- Posiciona para impressão
	Sele cur_lf_registro_saida_01_filtro
	REPLACE ALL  Qb with 1 FOR EMPTY(Qb)
	REPLACE ALL  SubQb with 1 FOR EMPTY(SubQb)

	*-- Eclusivo Casa das Cuecas:
	REPLACE ALL especie WITH 'ECF' FOR (serie_nf_oficial='CUP' AND especie='SEM')

	set relation to empresa  into tmp_empresa
	go top

ENDPROC 
*---------------------------------------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------------------------------------*
PROCEDURE Fx_Report_End


	** Voltanto o century do sistema
	set century &xrel_cent

	** Tirando o relacionamento
	sele v_lf_registro_saida_01_filtro
	set relation to 

	** Fechar cusrores criados em memória
	if used('tmp_empresa')
	   sele tmp_empresa
	   use
	endif

	** Retirar da memória as variáveis públicas
	release xrel_data_ini,xrel_data_fim,xrel_cent,xrel_pagini


ENDPROC 	
*---------------------------------------------------------------------------------------------------------------------------------------------------*
	