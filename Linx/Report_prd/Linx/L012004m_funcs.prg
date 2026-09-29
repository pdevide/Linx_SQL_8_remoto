*-- ALTERAÇÕES

*--17/05/2016 - CARLOS ALBERTO - ID 2821 - #1# - 01.16.010 - TRATAMENTO PARA CLIENTES SEM INFORMAÇÃO DE UF NO CADASTRO (SAT).


PROCEDURE Fx_Report_Begin

	Public xrel_data_ini,xrel_data_fim,xrel_cent,xrel_pagini,xQb_Desc,xSubQb_Desc

	xrel_data_ini=o_012004.lx_form1.lx_pageframe1.page2.lx_faixa_data1.data_inicial.value
	xrel_data_fim=o_012004.lx_form1.lx_pageframe1.page2.lx_faixa_data1.data_final.value

	xrel_pagini=0
	if messagebox('Deseja Alterar a Sequência de Numeração da Página Inicial?',4+32+256,'Atenção')=6
	   xrel_pagini = VAL(INPUTBOX('Página Inicial','Contabilidade'))
	   xrel_pagini = IIF(xrel_pagini>0,xrel_pagini-1,0)
	endif

	*** Trabalhar com a data no formato dd/mm/aaaa
	xrel_cent=set('century')
	set century on

	DECLARE xQb_Desc(4)
		xQb_Desc(1) = 'Registro de Entradas'
		xQb_Desc(2) = 'Totais do Periodo'
		xQb_Desc(3) = 'Resumo das Operações e Prestações por Codigo Fiscal de Operação'
		xQb_Desc(4) = 'Demonstrativo Por Estado de Destino da Mercadoria ou da Prestação de Serviço'

	DECLARE xSubQb_Desc(6)
		xSubQb_Desc(1) = '1. Entrada do Estado'
		xSubQb_Desc(2) = 'Sub Total'
		xSubQb_Desc(3) = '2. Entrada de Fora do Estado'
		xSubQb_Desc(4) = 'Sub Total'
		xSubQb_Desc(5) = '3. Entrada do Exterior'
		xSubQb_Desc(6) = 'Sub Total'
	
ENDPROC 
*---------------------------------------------------------------------------------------------------------------------------------------------------*


*---------------------------------------------------------------------------------------------------------------------------------------------------*
PROCEDURE Fx_Report_Qb_Detail
		
	*-- Selecionando Empresas
	f_select('select * from empresa','tmp_empresa')
	sele tmp_empresa
	index on empresa tag iEmpresa

	select *,00 as cod,;
			 base_imposto  as dif_ipi,;
			 valor_imposto as valor_imposto_cod,;
			 base_imposto  as base_imposto_cod,;
			 valor_imposto as valor_ipi_obs,;
			SPACE(6) as legenda_obs,1 as Qb, 0 as SubQb, SPACE(120) as Desc_SubQb ;
	  from v_lf_registro_entrada_01_filtro into cursor cur_lf_registro_entrada_01_filtro readwrite where .f.

	select v_lf_registro_entrada_01_filtro
	TRY 
		REPLACE ALL nome_clifor 			WITH '' FOR ISNULL(nome_clifor)
		REPLACE ALL nf_entrada  			WITH '' FOR ISNULL(nf_entrada)
		REPLACE ALL serie_nf_entrada 		WITH '' FOR ISNULL(serie_nf_entrada)
		REPLACE ALL codigo_fiscal_operacao 	WITH '' FOR ISNULL(codigo_fiscal_operacao)
		REPLACE ALL id_imposto 				WITH 0 FOR ISNULL(codigo_fiscal_operacao)
	CATCH 
		*/ WAIT WINDOW '<Index (2a.T.)>' NOWAIT && Erro do Fox 9: Eventualmente só aceita na 2a.tentativa
		REPLACE ALL nome_clifor 			WITH '' FOR ISNULL(nome_clifor)
		REPLACE ALL nf_entrada  			WITH '' FOR ISNULL(nf_entrada)
		REPLACE ALL serie_nf_entrada 		WITH '' FOR ISNULL(serie_nf_entrada)
		REPLACE ALL codigo_fiscal_operacao 	WITH '' FOR ISNULL(codigo_fiscal_operacao)
		REPLACE ALL id_imposto 				WITH 0 FOR ISNULL(codigo_fiscal_operacao)
	ENDTRY 
	index on nome_clifor+nf_entrada+serie_nf_entrada+codigo_fiscal_operacao+STR(id_imposto) tag iRE00

	DECLARE xV_Campo(3)
	xV_Campo(1) = 'v_lf_registro_entrada_01_filtro.valor_imposto'
	xV_Campo(2) = 'v_lf_registro_entrada_01_filtro.valor_imposto_isento'
	xV_Campo(3) = 'v_lf_registro_entrada_01_filtro.valor_imposto_outros'

	scan
		scatter memvar
		sele cur_lf_registro_entrada_01_filtro 
		IF v_lf_registro_entrada_01_filtro.nota_cancelada = 0
			x1a = .t.
			for k = 1 to 3
				IF EVALUATE(xV_Campo(k))<>0 OR ( EVALUATE(xV_Campo(1))=0 AND EVALUATE(xV_Campo(2))=0 AND EVALUATE(xV_Campo(3))=0 AND k=3 )
					appe blank
					gather memvar

					REPLACE valor_contabil WITH 0, id_imposto WITH 0
					IF x1a AND valor_contabil=0 AND imposto='ICMS'	
						select sum(valor_contabil) valor_contabil from v_lf_registro_entrada_01_filtro ;
						 where imposto=cur_lf_registro_entrada_01_filtro.imposto and nf_entrada=cur_lf_registro_entrada_01_filtro.nf_entrada and serie_nf_entrada=serie_nf_entrada and filial=cur_lf_registro_entrada_01_filtro.filial and nome_clifor=cur_lf_registro_entrada_01_filtro.nome_clifor and codigo_fiscal_operacao=cur_lf_registro_entrada_01_filtro.codigo_fiscal_operacao into cursor Cur_VC_nf
						sele cur_lf_registro_entrada_01_filtro 
						REPLACE valor_contabil WITH NVL(Cur_VC_nf.valor_contabil,0)
						x1a = .f.
					endif
					
					Replace cod with k, valor_imposto_cod with IIF(k<>1,0,EVALUATE(xV_Campo(k))), base_imposto_cod WITH IIF(k<>1,EVALUATE(xV_Campo(k)),base_imposto),;
							obs WITH NVL(v_lf_registro_entrada_01_filtro.obs,'')			
				endif
			endfor
		ELSE
			appe blank
			gather memvar
			replace legenda_obs WITH v_lf_registro_entrada_01_filtro.nf_entrada, ;
					obs WITH NVL(v_lf_registro_entrada_01_filtro.obs,'')
		ENDIF
		select v_lf_registro_entrada_01_filtro
	endscan

	SELECT cur_lf_registro_entrada_01_filtro 
	REPLACE ALL Qb WITH 1 && Detalhe
	REPLACE ALL Uf WITH Uf_Resumo && novo

	*--CDC: Somar IPI da  OBS
	REPLACE ALL valor_ipi_obs WITH VAL(SUBSTR(Obs,AT(':',obs)+1,LEN(Obs))) FOR 'VALOR DO IPI' $ obs
	*!*		Alteração CDC: Mostrar OBS	
	*!*		REPLACE ALL Obs WITH '' && 	*-- P1a: não sair NADA (Track)

	*-- teste do index:
	select v_lf_registro_entrada_01_filtro
	index on id_imposto tag iRE00

ENDFUNC 
*---------------------------------------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------------------------------------*
PROCEDURE Fx_Report_Quebras
LPARAMETERS xTpQb

	DO case
	CASE xTpQb=2 && Totais

		*===
		select empresa,matriz_fiscal,razao_social_matriz_fiscal,rg_ie_matriz_fiscal,cgc_cpf_matriz_fiscal,id_imposto,imposto,cod,;
			   sum(base_imposto_cod) base_imposto_cod,sum(valor_imposto_cod) valor_imposto_cod,SUM(dif_ipi) dif_ipi,SUM(valor_ipi_obs) valor_ipi_obs,;
			   1 as Qb, 0 as SubQb, SPACE(40) as Desc_SubQb ;
		  from cur_lf_registro_entrada_01_filtro WHERE Qb=1 ;
		 group by 1,2,3,4,5,6,7,8 into cursor cur_provisorio readwrite

		*-- (+) Permitir sair totais zerados
			select DISTINCT empresa,matriz_fiscal,razao_social_matriz_fiscal,rg_ie_matriz_fiscal,cgc_cpf_matriz_fiscal FROM cur_provisorio INTO cursor cur_provisorio_zerados 
			select DISTINCT id_imposto,imposto FROM cur_provisorio INTO cursor cur_provisorio_impostos 
			sele cur_provisorio_zerados 
			GO top
			scan
				sele cur_provisorio_impostos 
				go top
				scan
					for k = 1 to 3
						sele cur_provisorio
						locate for empresa=cur_provisorio_zerados.empresa and matriz_fiscal=cur_provisorio_zerados.matriz_fiscal and id_imposto=cur_provisorio_impostos.id_imposto and imposto=cur_provisorio_impostos.imposto and cod=k 
						if eof()
							appe blank
							REPLACE empresa 					WITH cur_provisorio_zerados.empresa,;
									matriz_fiscal 				WITH cur_provisorio_zerados.matriz_fiscal,;
									razao_social_matriz_fiscal 	WITH cur_provisorio_zerados.razao_social_matriz_fiscal,;
									rg_ie_matriz_fiscal			WITH cur_provisorio_zerados.rg_ie_matriz_fiscal,;
									cgc_cpf_matriz_fiscal		WITH cur_provisorio_zerados.cgc_cpf_matriz_fiscal,;
									id_imposto WITH cur_provisorio_impostos.id_imposto,imposto WITH cur_provisorio_impostos.imposto,cod WITH k,;
									base_imposto_cod with 0, valor_imposto_cod with 0
						endif			
					endfor
					sele cur_provisorio_impostos 
				endscan
				sele cur_provisorio_zerados 
			endscan
		*-- (+)

		sele cur_provisorio
		INDEX ON STR(empresa,4)+matriz_fiscal+STR(id_imposto,4)+STR(cod,1)+imposto TAG iPrv
		DO whil !EOF()
			xempresa = empresa
			xMatriz  = matriz_fiscal

			xrazao   = razao_social_matriz_fiscal
			xrgie    = rg_ie_matriz_fiscal
			xcgccpf  = cgc_cpf_matriz_fiscal

			*--- total distinct para valor contabil
			select DISTINCT empresa,matriz_fiscal,nf_entrada,serie_nf_entrada, cod_clifor, codigo_fiscal_operacao, valor_contabil ;
			  from cur_lf_registro_entrada_01_filtro ;
			 WHERE Qb=1 and empresa=?xempresa and matriz_fiscal=?xMatriz AND imposto='ICMS';
			  INTO CURSOR cur_vl_contabil_distinct
			 
			select sum(valor_contabil) valor_contabil from cur_vl_contabil_distinct INTO CURSOR cur_vl_contabil_sum

			SELECT cur_provisorio
			xCount = 0
			SCAN WHILE empresa=xempresa and matriz_fiscal=xMatriz
				xCount = xCount+1

				*==
				FOR kk=1 TO 3 && 1=Total para o Detalhe/2=Total para resumo por CFOP/3=Total para resumo por UF
					xSubQb = 9
					IF kk=1
						xxTpQb = xTpQb
						xxSubQb_Desc = ''
					ELSE
						xxTpQb = IIF(kk=2,3,4)
						xxSubQb_Desc = 'T o t a l :  ' + xQb_Desc(xxTpQb)
					ENDIF

					SELECT cur_lf_registro_entrada_01_filtro 
					append blank
					REPLACE empresa 					WITH xempresa,;
							matriz_fiscal 				WITH xMatriz,;
							razao_social_matriz_fiscal 	WITH xrazao,;
							rg_ie_matriz_fiscal			WITH xrgie,;
							cgc_cpf_matriz_fiscal		WITH xcgccpf,;
							imposto 		  with cur_provisorio.imposto,;
						    cod               with cur_provisorio.cod,;
							base_imposto_cod  with cur_provisorio.base_imposto_cod,;
							valor_imposto_cod with cur_provisorio.valor_imposto_cod,;
							Qb with xxTpQb, SubQb with xSubQb, Desc_SubQb with xxSubQb_Desc
							IF cur_provisorio.dif_ipi<>0 AND kk<>3 && AND id_imposto=2
								REPLACE obs with 'IPI:' + ALLTRIM(TRANSFORM(cur_provisorio.dif_ipi,'9999 999 999.99'))
							ENDIF
							
					IF xCount=1
						replace valor_contabil WITH NVL(cur_vl_contabil_sum.valor_contabil,0)
						IF cur_provisorio.valor_ipi_obs<>0
							REPLACE obs with 'Total do IPI: ' + ALLTRIM(TRANSFORM(cur_provisorio.valor_ipi_obs,'9999 999 999.99'))
						ENDIF 
					ENDIF
				ENDFOR
				*==

			ENDSCAN
		ENDDO
		*===


	CASE xTpQb=3 && Por CFOP


		*===
		FOR kk = 1 TO 3 && 1=Do estado/2=De Fora do estado/3=Do Exterior/
			*-- Detalhe:
			DO CASE
			CASE kk=1
				xSubQb = 1
			CASE kk=2
				xSubQb = 3
			OTHERWISE
				xSubQb = 5
			ENDCASE 

			select empresa,matriz_fiscal,razao_social_matriz_fiscal,rg_ie_matriz_fiscal,cgc_cpf_matriz_fiscal,codigo_fiscal_operacao,id_imposto,imposto,cod,;
				   sum(base_imposto_cod) base_imposto_cod,sum(valor_imposto_cod) valor_imposto_cod,SUM(dif_ipi) dif_ipi,SUM(valor_ipi_obs) valor_ipi_obs,;
				   1 as Qb, 0 as SubQb, SPACE(40) as Desc_SubQb ;
			  from cur_lf_registro_entrada_01_filtro WHERE Qb=1 AND VAL(LEFT(codigo_fiscal_operacao,1))=kk ;
			 group by 1,2,3,4,5,6,7,8,9 into cursor cur_provisorio readwrite

			*-- (+) Permitir sair totais zerados
				select DISTINCT empresa,matriz_fiscal,razao_social_matriz_fiscal,rg_ie_matriz_fiscal,cgc_cpf_matriz_fiscal,codigo_fiscal_operacao FROM cur_provisorio INTO cursor cur_provisorio_zerados 
				select DISTINCT id_imposto,imposto FROM cur_provisorio INTO cursor cur_provisorio_impostos
				sele cur_provisorio_zerados 
				GO top
				scan
					sele cur_provisorio_impostos 
					go top
					scan
						for k = 1 to 3
							sele cur_provisorio
							locate for empresa=cur_provisorio_zerados.empresa and matriz_fiscal=cur_provisorio_zerados.matriz_fiscal AND codigo_fiscal_operacao=cur_provisorio_zerados.codigo_fiscal_operacao and id_imposto=cur_provisorio_impostos.id_imposto and imposto=cur_provisorio_impostos.imposto and cod=k
							if eof()
								appe blank
								REPLACE empresa 					WITH cur_provisorio_zerados.empresa,;
										matriz_fiscal 				WITH cur_provisorio_zerados.matriz_fiscal,;
										razao_social_matriz_fiscal 	WITH cur_provisorio_zerados.razao_social_matriz_fiscal,;
										rg_ie_matriz_fiscal			WITH cur_provisorio_zerados.rg_ie_matriz_fiscal,;
										cgc_cpf_matriz_fiscal		WITH cur_provisorio_zerados.cgc_cpf_matriz_fiscal,;
										codigo_fiscal_operacao		WITH cur_provisorio_zerados.codigo_fiscal_operacao,;
										id_imposto WITH cur_provisorio_impostos.id_imposto,imposto WITH cur_provisorio_impostos.imposto,cod WITH k,;
										base_imposto_cod with 0, valor_imposto_cod with 0
							endif			
						endfor
						sele cur_provisorio_impostos 
					endscan
					sele cur_provisorio_zerados 
				endscan
			*-- (+)

			sele cur_provisorio
			INDEX ON STR(empresa,4)+matriz_fiscal+codigo_fiscal_operacao+STR(id_imposto,4)+STR(cod,1)+imposto TAG iPrv
			DO whil !EOF()
				xempresa = empresa
				xMatriz  = matriz_fiscal
				xCFOP 	 = codigo_fiscal_operacao
				
				xrazao   = razao_social_matriz_fiscal
				xrgie    = rg_ie_matriz_fiscal
				xcgccpf  = cgc_cpf_matriz_fiscal

				*--- total distinct para valor contabil
				select DISTINCT empresa,matriz_fiscal,nf_entrada,serie_nf_entrada, cod_clifor, codigo_fiscal_operacao, valor_contabil ;
				  from cur_lf_registro_entrada_01_filtro ;
				 WHERE Qb=1 and empresa=?xempresa and matriz_fiscal=?xMatriz AND codigo_fiscal_operacao=xCFOP AND imposto='ICMS';
				  INTO CURSOR cur_vl_contabil_distinct
				 
				select sum(valor_contabil) valor_contabil from cur_vl_contabil_distinct INTO CURSOR cur_vl_contabil_sum

				SELECT cur_provisorio
				xCount = 0
				SCAN WHILE empresa=xempresa and matriz_fiscal=xMatriz AND codigo_fiscal_operacao=xCFOP
					xCount = xCount+1

					SELECT cur_lf_registro_entrada_01_filtro 
					append blank
					REPLACE empresa 					WITH xempresa,;
							matriz_fiscal 				WITH xMatriz,;
							codigo_fiscal_operacao		WITH xCFOP,;
							razao_social_matriz_fiscal 	WITH xrazao,;
							rg_ie_matriz_fiscal			WITH xrgie,;
							cgc_cpf_matriz_fiscal		WITH xcgccpf,;
							imposto 		  with cur_provisorio.imposto,;
						    cod               with cur_provisorio.cod,;
							base_imposto_cod  with cur_provisorio.base_imposto_cod,;
							valor_imposto_cod with cur_provisorio.valor_imposto_cod,;
								Qb with xTpQb, SubQb with xSubQb, Desc_SubQb with xSubQb_Desc(xSubQb)
							IF cur_provisorio.dif_ipi<>0 AND kk<>3 && AND id_imposto=2
								REPLACE obs with 'IPI:' + ALLTRIM(TRANSFORM(cur_provisorio.dif_ipi,'9999 999 999.99'))
							ENDIF
							
					IF xCount=1
						replace valor_contabil WITH NVL(cur_vl_contabil_sum.valor_contabil,0)
						IF cur_provisorio.valor_ipi_obs<>0
							REPLACE obs with 'Total do IPI: ' + ALLTRIM(TRANSFORM(cur_provisorio.valor_ipi_obs,'9999 999 999.99'))
						ENDIF 
					ENDIF

				ENDSCAN
			ENDDO


			*-- Sub Total:
			DO CASE
			CASE kk=1
				xSubQb = 2
			CASE kk=3
				xSubQb = 4
			OTHERWISE
				xSubQb = 6
			ENDCASE 

			select empresa,matriz_fiscal,razao_social_matriz_fiscal,rg_ie_matriz_fiscal,cgc_cpf_matriz_fiscal,VAL(LEFT(codigo_fiscal_operacao,1)) as tipo_CFOP,id_imposto,imposto,cod,;
				   sum(base_imposto_cod) base_imposto_cod,sum(valor_imposto_cod) valor_imposto_cod,SUM(dif_ipi) dif_ipi,SUM(valor_ipi_obs) valor_ipi_obs,;
				   1 as Qb, 0 as SubQb, SPACE(40) as Desc_SubQb ;
			  from cur_lf_registro_entrada_01_filtro WHERE Qb=1 AND VAL(LEFT(codigo_fiscal_operacao,1))=kk ;
			 group by 1,2,3,4,5,6,7,8,9 into cursor cur_provisorio readwrite


			*-- (+) Permitir sair totais zerados
				select DISTINCT empresa,matriz_fiscal,razao_social_matriz_fiscal,rg_ie_matriz_fiscal,cgc_cpf_matriz_fiscal,tipo_CFOP FROM cur_provisorio INTO cursor cur_provisorio_zerados 
				select DISTINCT id_imposto,imposto FROM cur_provisorio INTO cursor cur_provisorio_impostos
				sele cur_provisorio_zerados 
				GO top
				scan
					sele cur_provisorio_impostos 
					go top
					scan
						for k = 1 to 3
							sele cur_provisorio
							locate for empresa=cur_provisorio_zerados.empresa and matriz_fiscal=cur_provisorio_zerados.matriz_fiscal AND tipo_CFOP=cur_provisorio_zerados.tipo_CFOP and id_imposto=cur_provisorio_impostos.id_imposto and imposto=cur_provisorio_impostos.imposto and cod=k
							if eof()
								appe blank
								REPLACE empresa 					WITH cur_provisorio_zerados.empresa,;
										matriz_fiscal 				WITH cur_provisorio_zerados.matriz_fiscal,;
										razao_social_matriz_fiscal 	WITH cur_provisorio_zerados.razao_social_matriz_fiscal,;
										rg_ie_matriz_fiscal			WITH cur_provisorio_zerados.rg_ie_matriz_fiscal,;
										cgc_cpf_matriz_fiscal		WITH cur_provisorio_zerados.cgc_cpf_matriz_fiscal,;
										tipo_CFOP					WITH cur_provisorio_zerados.tipo_CFOP,;
										id_imposto WITH cur_provisorio_impostos.id_imposto,imposto WITH cur_provisorio_impostos.imposto,cod WITH k,;
										base_imposto_cod with 0, valor_imposto_cod with 0
							endif			
						endfor
						sele cur_provisorio_impostos 
					endscan
					sele cur_provisorio_zerados 
				endscan
			*-- (+)

			sele cur_provisorio
			INDEX ON STR(empresa,4)+matriz_fiscal+STR(tipo_CFOP)+STR(id_imposto,4)+STR(cod,1)+imposto TAG iPrv
			DO whil !EOF()
				xempresa = empresa
				xMatriz  = matriz_fiscal
				xtCFOP	 = tipo_CFOP
				
				xrazao   = razao_social_matriz_fiscal
				xrgie    = rg_ie_matriz_fiscal
				xcgccpf  = cgc_cpf_matriz_fiscal

				*--- total distinct para valor contabil
				select DISTINCT empresa,matriz_fiscal,nf_entrada,serie_nf_entrada, cod_clifor, VAL(LEFT(codigo_fiscal_operacao,1)) as tipo_CFOP, valor_contabil ;
				  from cur_lf_registro_entrada_01_filtro ;
				 WHERE Qb=1 and empresa=?xempresa and matriz_fiscal=?xMatriz AND VAL(LEFT(codigo_fiscal_operacao,1))=xtCFOP AND imposto='ICMS' ;
				  INTO CURSOR cur_vl_contabil_distinct
				 
				select sum(valor_contabil) valor_contabil from cur_vl_contabil_distinct INTO CURSOR cur_vl_contabil_sum

				SELECT cur_provisorio
				xCount = 0
				SCAN WHILE empresa=xempresa and matriz_fiscal=xMatriz AND tipo_CFOP=xtCFOP
					xCount = xCount+1

					SELECT cur_lf_registro_entrada_01_filtro 
					append blank
					REPLACE empresa 					WITH xempresa,;
							matriz_fiscal 				WITH xMatriz,;
							razao_social_matriz_fiscal 	WITH xrazao,;
							rg_ie_matriz_fiscal			WITH xrgie,;
							cgc_cpf_matriz_fiscal		WITH xcgccpf,;
							Qb with xTpQb, SubQb with xSubQb, Desc_SubQb with xSubQb_Desc(xSubQb)
							
							IF cur_provisorio.dif_ipi<>0 AND kk<>3 && AND id_imposto=2
								REPLACE obs with 'IPI:' + ALLTRIM(TRANSFORM(cur_provisorio.dif_ipi,'9999 999 999.99'))
							ENDIF

					REPLACE imposto 		  with cur_provisorio.imposto,;
						    cod               with cur_provisorio.cod,;
							base_imposto_cod  with cur_provisorio.base_imposto_cod,;
							valor_imposto_cod with cur_provisorio.valor_imposto_cod

							*!*								imposto 		  with cur_provisorio.imposto,;
							*!*							    cod               with cur_provisorio.cod,;
							*!*								base_imposto_cod  with cur_provisorio.base_imposto_cod,;
							*!*								valor_imposto_cod with cur_provisorio.valor_imposto_cod

							
					IF xCount=1
						replace valor_contabil WITH NVL(cur_vl_contabil_sum.valor_contabil,0)
						IF cur_provisorio.valor_ipi_obs<>0
							REPLACE obs with 'Total do IPI: ' + ALLTRIM(TRANSFORM(cur_provisorio.valor_ipi_obs,'9999 999 999.99'))
						ENDIF 
					ENDIF

				ENDSCAN
			ENDDO

		ENDFOR 
		*===


	CASE xTpQb=4 && Por UF
	
		*--#1#
	
		*===
			select empresa,matriz_fiscal,razao_social_matriz_fiscal,rg_ie_matriz_fiscal,cgc_cpf_matriz_fiscal,NVL(UF,'') AS uf,id_imposto,imposto,cod,;
				   sum(base_imposto_cod) base_imposto_cod,sum(valor_imposto_cod) valor_imposto_cod,SUM(dif_ipi) dif_ipi,SUM(valor_ipi_obs) valor_ipi_obs,;
				   1 as Qb, 0 as SubQb, SPACE(40) as Desc_SubQb ;
			  from cur_lf_registro_entrada_01_filtro WHERE Qb=1 ;
			 group by 1,2,3,4,5,6,7,8,9 into cursor cur_provisorio readwrite

			*-- (+) Permitir sair totais zerados
				select DISTINCT empresa,matriz_fiscal,razao_social_matriz_fiscal,rg_ie_matriz_fiscal,cgc_cpf_matriz_fiscal,NVL(UF,'') AS uf FROM cur_provisorio INTO cursor cur_provisorio_zerados 
				select DISTINCT id_imposto,imposto FROM cur_provisorio INTO cursor cur_provisorio_impostos
				sele cur_provisorio_zerados 
				GO top
				scan
					sele cur_provisorio_impostos 
					go top
					scan
						for k = 1 to 3
							sele cur_provisorio
							locate for empresa=cur_provisorio_zerados.empresa and matriz_fiscal=cur_provisorio_zerados.matriz_fiscal AND NVL(UF,'')=NVL(cur_provisorio_zerados.uf,'') and id_imposto=cur_provisorio_impostos.id_imposto and imposto=cur_provisorio_impostos.imposto and cod=k
							if eof()
								appe blank
								REPLACE empresa 					WITH cur_provisorio_zerados.empresa,;
										matriz_fiscal 				WITH cur_provisorio_zerados.matriz_fiscal,;
										razao_social_matriz_fiscal 	WITH cur_provisorio_zerados.razao_social_matriz_fiscal,;
										rg_ie_matriz_fiscal			WITH cur_provisorio_zerados.rg_ie_matriz_fiscal,;
										cgc_cpf_matriz_fiscal		WITH cur_provisorio_zerados.cgc_cpf_matriz_fiscal,;
										uf							WITH NVL(cur_provisorio_zerados.uf,''),;
										id_imposto WITH cur_provisorio_impostos.id_imposto,imposto WITH cur_provisorio_impostos.imposto,cod WITH k,;
										base_imposto_cod with 0, valor_imposto_cod with 0
							endif			
						endfor
						sele cur_provisorio_impostos 
					endscan
					sele cur_provisorio_zerados 
				endscan
			*-- (+)

			sele cur_provisorio
			INDEX ON STR(empresa,4)+matriz_fiscal+NVL(UF,'')+STR(id_imposto,4)+STR(cod,1)+imposto TAG iPrv
			DO whil !EOF()
				xempresa = empresa
				xMatriz  = matriz_fiscal
				xUF 	 = NVL(UF,'')
				
				xrazao   = razao_social_matriz_fiscal
				xrgie    = rg_ie_matriz_fiscal
				xcgccpf  = cgc_cpf_matriz_fiscal

				*--- total distinct para valor contabil
				select DISTINCT empresa,matriz_fiscal,nf_entrada,serie_nf_entrada, cod_clifor, NVL(UF,'') AS uf, valor_contabil ;
				  from cur_lf_registro_entrada_01_filtro ;
				 WHERE Qb=1 and empresa=?xempresa and matriz_fiscal=?xMatriz AND Uf=xUF AND imposto='ICMS';
				  INTO CURSOR cur_vl_contabil_distinct
				 
				select sum(valor_contabil) valor_contabil from cur_vl_contabil_distinct INTO CURSOR cur_vl_contabil_sum

				SELECT cur_provisorio
				xCount = 0
				SCAN WHILE empresa=xempresa and matriz_fiscal=xMatriz AND NVL(UF,'')=xUF
					xCount = xCount+1

					SELECT cur_lf_registro_entrada_01_filtro 
					append blank
					REPLACE empresa 					WITH xempresa,;
							matriz_fiscal 				WITH xMatriz,;
							uf							WITH xUF,;
							razao_social_matriz_fiscal 	WITH xrazao,;
							rg_ie_matriz_fiscal			WITH xrgie,;
							cgc_cpf_matriz_fiscal		WITH xcgccpf,;
							imposto 		  with cur_provisorio.imposto,;
						    cod               with cur_provisorio.cod,;
							base_imposto_cod  with cur_provisorio.base_imposto_cod,;
							valor_imposto_cod with cur_provisorio.valor_imposto_cod,;
							Qb 				  with xTpQb
							IF cur_provisorio.dif_ipi<>0 && AND id_imposto=2
								REPLACE obs with 'IPI:' + ALLTRIM(TRANSFORM(cur_provisorio.dif_ipi,'9999 999 999.99'))
							ENDIF
							
					IF xCount=1
						replace valor_contabil WITH NVL(cur_vl_contabil_sum.valor_contabil,0)
						IF cur_provisorio.valor_ipi_obs<>0
							REPLACE obs with 'Total do IPI: ' + ALLTRIM(TRANSFORM(cur_provisorio.valor_ipi_obs,'9999 999 999.99'))
						ENDIF 
					ENDIF

				ENDSCAN
			ENDDO
		*===
		
	ENDCASE

ENDPROC 
*---------------------------------------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------------------------------------*
PROCEDURE Fx_Report_Relation

	*--- Posiciona para impressão
*!*		xIndex = "str(empresa,4)+matriz_fiscal+str(Qb)+STR(SubQb)+dtos(recebimento)+str(val(nf_entrada)) + especie+serie_nf_entrada + "+;
*!*				 "cod_clifor+uf+conta_contabil+codigo_fiscal_operacao+STR(id_imposto)"

	xIndex = "str(empresa,4)+matriz_fiscal+str(Qb)+STR(SubQb)+dtos(recebimento)+str(val(nf_entrada)) + especie+serie_nf_entrada + "+;
			 "cod_clifor+uf+conta_contabil+codigo_fiscal_operacao+STR(id_imposto)"

	SELECT cur_lf_registro_entrada_01_filtro
		REPLACE ALL cod_clifor 				WITH '' FOR ISNULL(cod_clifor) 
		REPLACE ALL codigo_cliente			WITH '' FOR ISNULL(codigo_cliente) 
		REPLACE ALL uf 						WITH '' FOR ISNULL(uf) 
		REPLACE ALL conta_contabil 			WITH '' FOR ISNULL(conta_contabil) 
		REPLACE ALL codigo_fiscal_operacao 	WITH '' FOR ISNULL(codigo_fiscal_operacao) 
		REPLACE ALL  Qb with 1 FOR EMPTY(Qb)
		REPLACE ALL  SubQb with 1 FOR EMPTY(SubQb)
	index on &xIndex tag iEnt01

	set relation to empresa  into tmp_empresa
	go top

ENDPROC 
*---------------------------------------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------------------------------------*
PROCEDURE Fx_Report_End

	** Voltanto o century do sistema
	set century &xrel_cent

	** Tirando o relacionamento
	sele v_lf_registro_entrada_01_filtro
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
	