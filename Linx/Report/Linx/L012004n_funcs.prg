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

	select *,00 as cod_ipi,;
			 00 as cod_icms,;
			 base_imposto  as dif_ipi,;
			 base_imposto  as base_imposto_ipi,;
			 taxa_imposto  as taxa_imposto_ipi,;
			 valor_imposto as valor_imposto_ipi,;
			 base_imposto  as base_imposto_icms,;
			 taxa_imposto  as taxa_imposto_icms,;
			 valor_imposto as valor_imposto_icms,;
			 valor_imposto as valor_ipi_obs,SPACE(6) as legenda_obs,1 as Qb, 0 as SubQb, SPACE(120) as Desc_SubQb ;
	  from v_lf_registro_entrada_01_filtro into cursor cur_lf_registro_entrada_01_filtro readwrite where .f.

	sele cur_lf_registro_entrada_01_filtro 
		REPLACE ALL nome_clifor 			WITH '' FOR ISNULL(nome_clifor)
		REPLACE ALL nf_entrada  			WITH '' FOR ISNULL(nf_entrada)
		REPLACE ALL serie_nf_entrada 		WITH '' FOR ISNULL(serie_nf_entrada)
		REPLACE ALL codigo_fiscal_operacao 	WITH '' FOR ISNULL(codigo_fiscal_operacao)
		REPLACE ALL id_imposto 				WITH 0 FOR ISNULL(codigo_fiscal_operacao)
	index on nome_clifor+nf_entrada+serie_nf_entrada+codigo_fiscal_operacao+STR(id_imposto) tag iRE00
	*-------------------------------------------------------------------------------------------------------------------*

	select v_lf_registro_entrada_01_filtro
		REPLACE ALL nome_clifor				WITH '' FOR ISNULL(nome_clifor) 
		REPLACE ALL nf_entrada				WITH '' FOR ISNULL(nf_entrada) 
		REPLACE ALL serie_nf_entrada		WITH '' FOR ISNULL(serie_nf_entrada) 
		REPLACE ALL codigo_fiscal_operacao	WITH '' FOR ISNULL(codigo_fiscal_operacao) 
	index on nome_clifor+nf_entrada+serie_nf_entrada+codigo_fiscal_operacao+STR(id_imposto) tag iRE

	DECLARE xV_Campo(3)
	xV_Campo(1) = 'v_lf_registro_entrada_01_filtro.valor_imposto'
	xV_Campo(2) = 'v_lf_registro_entrada_01_filtro.valor_imposto_isento'
	xV_Campo(3) = 'v_lf_registro_entrada_01_filtro.valor_imposto_outros'

	GO top
	DO whil !EOF()
		xCl   = NVL(nome_clifor,'')
		xNf   = NVL(nf_entrada,'')
		xSr   = NVL(serie_nf_entrada,'')
		xCFOP = NVL(codigo_fiscal_operacao,'')
		xItem = 0

		SCAN WHILE ( NVL(nome_clifor,'')=xCl AND NVL(nf_entrada,'')=xNf AND NVL(serie_nf_entrada,'')=xSr AND NVL(codigo_fiscal_operacao,'')=xCFOP )
			scatter memvar
			xItem = xItem+1
			xCol  = IIF(ALLT(IMPOSTO)='IPI','ipi',IIF(ALLT(IMPOSTO)='ICMS','icms',''))
			IF EMPTY(xCol)
				LOOP
			ENDIF
			sele cur_lf_registro_entrada_01_filtro 

			x1a = .t.
			for k = 1 to 3
				if EVALUATE(xV_Campo(k))<>0 OR ( EVALUATE(xV_Campo(1))=0 AND EVALUATE(xV_Campo(2))=0 AND EVALUATE(xV_Campo(3))=0 AND k=3 )
						
					IF EMPTY(xCol)
						appe blank
						gather memvar
						REPLACE valor_contabil WITH 0, id_imposto WITH 0
					ELSE
						*/SEEK xCl+xNf+xSr 
						SEEK xCl+xNf+xSr+xCFOP 
						IF !eof() AND cod_&xCol<>0 && posicionar na ultima
							SKIP
						ENDIF
						IF EOF() OR cod_&xCol<>0 OR xItem=1
							appe blank
							gather memvar
							REPLACE valor_contabil WITH 0, id_imposto WITH 0
						ENDIF
						IF EVALUATE(xV_Campo(k))<>0 OR ( EVALUATE(xV_Campo(1))=0 AND EVALUATE(xV_Campo(2))=0 AND EVALUATE(xV_Campo(3))=0 AND k=3 )
							Replace cod_&xCol with k,;
									base_imposto_&xCol   WITH IIF(k<>1,EVALUATE(xV_Campo(k)),v_lf_registro_entrada_01_filtro.base_imposto),;
								    taxa_imposto_&xCol   WITH v_lf_registro_entrada_01_filtro.taxa_imposto,;
								    valor_imposto_&xCol  WITH IIF(k<>1,0,EVALUATE(xV_Campo(k)))
							IF x1a AND valor_contabil=0		
								select sum(valor_contabil) valor_contabil from v_lf_registro_entrada_01_filtro ;
								 where imposto=cur_lf_registro_entrada_01_filtro.imposto and nf_entrada=cur_lf_registro_entrada_01_filtro.nf_entrada and serie_nf_entrada=cur_lf_registro_entrada_01_filtro.serie_nf_entrada and filial=cur_lf_registro_entrada_01_filtro.filial and nome_clifor=cur_lf_registro_entrada_01_filtro.nome_clifor and codigo_fiscal_operacao=cur_lf_registro_entrada_01_filtro.codigo_fiscal_operacao into cursor Cur_VC_nf
								*
								sele cur_lf_registro_entrada_01_filtro 
								REPLACE valor_contabil WITH NVL(Cur_VC_nf.valor_contabil,0)
								x1a = .f.
							endif
						ENDIF
					ENDIF
					Replace obs WITH NVL(v_lf_registro_entrada_01_filtro.obs,'')
				ENDIF
			ENDFOR
			
			select v_lf_registro_entrada_01_filtro
			RELEASE memvar 
		endscan

	EndDo

	SELECT cur_lf_registro_entrada_01_filtro 
	REPLACE ALL Qb WITH 1 && Detalhe
	REPLACE ALL Uf WITH Uf_Resumo && novo

	*--CDC: Somar IPI da  OBS
	REPLACE ALL valor_ipi_obs WITH VAL(SUBSTR(Obs,AT(':',obs)+1,LEN(Obs))) FOR 'VALOR DO IPI' $ obs

	*!*		*-- P1: só mostrar obs ref. IPI
	*!*			REPLACE All Obs WITH ''

	*!*			*-- Dif IPI (Distinct): (que tb aparece no campo OBS)
	*!*				SELECT Distinct empresa,matriz_fiscal,nf_entrada,serie_nf_entrada,;
	*!*					   valor_contabil,base_imposto,valor_imposto_outros,valor_imposto_isento,(valor_contabil-(base_imposto+valor_imposto_isento+valor_imposto_outros)) as dif_ipi ;
	*!*				  FROM V_lf_registro_entrada_01_filtro ;
	*!*				 WHERE (valor_contabil-(base_imposto+valor_imposto_isento+valor_imposto_outros))<>0 ;
	*!*				   AND IMPOSTO='IPI' AND (valor_imposto+valor_imposto_isento)=0 INTO CURSOR Cur_Distinct_Dif_Ipi

	*!*				SELECT Cur_Distinct_Dif_Ipi
	*!*				SCAN
	*!*					SELECT cur_lf_registro_entrada_01_filtro 
	*!*					LOCATE FOR empresa=Cur_Distinct_Dif_Ipi.empresa AND matriz_fiscal=Cur_Distinct_Dif_Ipi.matriz_fiscal AND nf_entrada=Cur_Distinct_Dif_Ipi.nf_entrada AND serie_nf_entrada=Cur_Distinct_Dif_Ipi.serie_nf_entrada
	*!*					IF !EOF()
	*!*						REPLACE dif_ipi WITH dif_ipi + Cur_Distinct_Dif_Ipi.dif_ipi
	*!*					endif
	*!*				ENDSCAN
	*!*			*--

	*!*			SELECT cur_lf_registro_entrada_01_filtro 
	*!*			REPLACE obs with 'IPI:' + ALLTRIM(TRANSFORM(dif_ipi,'9999 999 999.99')) FOR dif_ipi<>0 && AND id_imposto=2

	*!*			*--
	*!*	*/		REPLACE ALL base_imposto_ipi WITH (valor_contabil-dif_ipi) FOR 'IPI:' $ obs
	*!*	*/		REPLACE ALL base_imposto_ipi WITH (base_imposto_ipi-dif_ipi) FOR 'IPI:' $ obs
	*!*			
	*!*			REPLACE ALL cod_ipi WITH 1 FOR EMPTY(cod_ipi) AND base_imposto<>0 AND !('IPI:' $ obs)
	*!*			REPLACE ALL cod_ipi WITH 2 FOR EMPTY(cod_ipi) AND valor_imposto_isento<>0 AND !('IPI:' $ obs)
	*!*			REPLACE ALL cod_ipi WITH 3 FOR EMPTY(cod_ipi) AND valor_imposto_outros<>0 or ('IPI:' $ obs)

ENDFUNC 
*---------------------------------------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------------------------------------*
PROCEDURE Fx_Report_Quebras
LPARAMETERS xTpQb

	DO case
	CASE xTpQb=2 && Totais

		*===
		SELECT empresa,matriz_fiscal,razao_social_matriz_fiscal,rg_ie_matriz_fiscal,cgc_cpf_matriz_fiscal,cod_icms,00 cod_ipi,;
			   SUM(base_imposto_icms) base_imposto_icms,SUM(valor_imposto_icms) valor_imposto_icms,SUM(dif_ipi) dif_ipi,;
			   000000000000.00 base_imposto_ipi,000000000000.00 valor_imposto_ipi,SUM(valor_ipi_obs) valor_ipi_obs ;
		  FROM cur_lf_registro_entrada_01_filtro WHERE Qb=1 GROUP BY 1,2,3,4,5,6 INTO CURSOR Cur_Tot_Impostos_Agr READWRITE 
		  
		SELECT empresa,matriz_fiscal,razao_social_matriz_fiscal,rg_ie_matriz_fiscal,cgc_cpf_matriz_fiscal,cod_ipi,SUM(base_imposto_ipi) base_imposto_ipi,SUM(valor_imposto_ipi)  valor_imposto_ipi,SUM(dif_ipi) dif_ipi ;
		  FROM cur_lf_registro_entrada_01_filtro WHERE Qb=1 GROUP BY 1,2,3,4,5,6 INTO CURSOR Cur_Tot_Ipi

		SELECT Cur_Tot_Ipi
		SCAN
			SELECT Cur_Tot_Impostos_Agr 
			LOCATE FOR empresa=Cur_Tot_Ipi.empresa AND matriz_fiscal=Cur_Tot_Ipi.matriz_fiscal
			IF EOF() OR cod_ipi<>0
				APPEND BLANK 
				REPLACE empresa WITH Cur_Tot_Ipi.empresa,matriz_fiscal WITH Cur_Tot_Ipi.matriz_fiscal
			ENDIF
			REPLACE cod_ipi WITH Cur_Tot_Ipi.cod_ipi, base_imposto_ipi WITH Cur_Tot_Ipi.base_imposto_ipi, valor_imposto_ipi WITH Cur_Tot_Ipi.valor_imposto_ipi &&, dif_ipi WITH Cur_Tot_Ipi.dif_ipi  
		ENDSCAN
		
		SELECT Cur_Tot_Impostos_Agr
		GO TOP 
		DO whil !EOF()
			xempresa = empresa
			xMatriz  = matriz_fiscal

			*--- total distinct para valor contabil
			select DISTINCT empresa,matriz_fiscal,nf_entrada,serie_nf_entrada, cod_clifor, codigo_fiscal_operacao, valor_contabil ;
			  from cur_lf_registro_entrada_01_filtro ;
			 WHERE Qb=1 and empresa=?xempresa and matriz_fiscal=?xMatriz ;
			  INTO CURSOR cur_vl_contabil_distinct
			 
			select sum(valor_contabil) valor_contabil from cur_vl_contabil_distinct INTO CURSOR cur_vl_contabil_sum

			SELECT Cur_Tot_Impostos_Agr
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
							razao_social_matriz_fiscal 	WITH Cur_Tot_Impostos_Agr.razao_social_matriz_fiscal,;
							rg_ie_matriz_fiscal			WITH Cur_Tot_Impostos_Agr.rg_ie_matriz_fiscal,;
							cgc_cpf_matriz_fiscal		WITH Cur_Tot_Impostos_Agr.cgc_cpf_matriz_fiscal,;
							Qb with xxTpQb, SubQb with xSubQb, Desc_SubQb with xxSubQb_Desc,;
							cod_icms           with Cur_Tot_Impostos_Agr.cod_icms,;
							base_imposto_icms  with Cur_Tot_Impostos_Agr.base_imposto_icms,;
							valor_imposto_icms with Cur_Tot_Impostos_Agr.valor_imposto_icms,;
							cod_ipi            with Cur_Tot_Impostos_Agr.cod_ipi,;
							base_imposto_Ipi   with Cur_Tot_Impostos_Agr.base_imposto_Ipi,;
							valor_imposto_Ipi  with Cur_Tot_Impostos_Agr.valor_imposto_Ipi
							IF Cur_Tot_Impostos_Agr.dif_ipi<>0 AND kk<>3 && AND id_imposto=2
								REPLACE obs with 'IPI:' + ALLTRIM(TRANSFORM(Cur_Tot_Impostos_Agr.dif_ipi,'9999 999 999.99'))
							ENDIF
							
					IF xCount=1
						replace valor_contabil WITH cur_vl_contabil_sum.valor_contabil
						IF Cur_Tot_Impostos_Agr.valor_ipi_obs<>0
							REPLACE obs with 'Total do IPI: ' + ALLTRIM(TRANSFORM(Cur_Tot_Impostos_Agr.valor_ipi_obs,'9999 999 999.99'))
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

			SELECT empresa,matriz_fiscal,razao_social_matriz_fiscal,rg_ie_matriz_fiscal,cgc_cpf_matriz_fiscal,codigo_fiscal_operacao,cod_icms,00 cod_ipi,;
				   SUM(base_imposto_icms) base_imposto_icms,SUM(valor_imposto_icms) valor_imposto_icms,SUM(dif_ipi) dif_ipi,;
				   000000000000.00 base_imposto_ipi,000000000000.00 valor_imposto_ipi,SUM(valor_ipi_obs) valor_ipi_obs ;
			  FROM cur_lf_registro_entrada_01_filtro WHERE Qb=1 AND VAL(LEFT(codigo_fiscal_operacao,1))=kk GROUP BY 1,2,3,4,5,6,7 INTO CURSOR Cur_Tot_Impostos_Agr READWRITE 
			  
			SELECT empresa,matriz_fiscal,razao_social_matriz_fiscal,rg_ie_matriz_fiscal,cgc_cpf_matriz_fiscal,codigo_fiscal_operacao,cod_ipi,SUM(base_imposto_ipi) base_imposto_ipi,SUM(valor_imposto_ipi)  valor_imposto_ipi,SUM(dif_ipi) dif_ipi ;
			  FROM cur_lf_registro_entrada_01_filtro WHERE Qb=1 AND VAL(LEFT(codigo_fiscal_operacao,1))=kk GROUP BY 1,2,3,4,5,6,7 INTO CURSOR Cur_Tot_Ipi

			SELECT Cur_Tot_Ipi
			SCAN
				SELECT Cur_Tot_Impostos_Agr 
				LOCATE FOR empresa=Cur_Tot_Ipi.empresa AND matriz_fiscal=Cur_Tot_Ipi.matriz_fiscal AND codigo_fiscal_operacao=Cur_Tot_Ipi.codigo_fiscal_operacao
				IF EOF() OR cod_ipi<>0
					APPEND BLANK 
					REPLACE empresa WITH Cur_Tot_Ipi.empresa,matriz_fiscal WITH Cur_Tot_Ipi.matriz_fiscal, codigo_fiscal_operacao WITH Cur_Tot_Ipi.codigo_fiscal_operacao
				ENDIF
				REPLACE cod_ipi WITH Cur_Tot_Ipi.cod_ipi, base_imposto_ipi WITH Cur_Tot_Ipi.base_imposto_ipi, valor_imposto_ipi WITH Cur_Tot_Ipi.valor_imposto_ipi, dif_ipi WITH Cur_Tot_Ipi.dif_ipi 
			ENDSCAN
			
			SELECT Cur_Tot_Impostos_Agr
			GO TOP 
			DO whil !EOF()
				xempresa = empresa
				xMatriz  = matriz_fiscal
				xCFOP 	 = codigo_fiscal_operacao

				*--- total distinct para valor contabil
				select DISTINCT empresa,matriz_fiscal,nf_entrada,serie_nf_entrada, cod_clifor, codigo_fiscal_operacao, valor_contabil ;
				  from cur_lf_registro_entrada_01_filtro ;
				 WHERE Qb=1 and empresa=?xempresa and matriz_fiscal=?xMatriz AND codigo_fiscal_operacao=xCFOP;
				  INTO CURSOR cur_vl_contabil_distinct
				 
				select sum(valor_contabil) valor_contabil from cur_vl_contabil_distinct INTO CURSOR cur_vl_contabil_sum

				SELECT Cur_Tot_Impostos_Agr
				xCount = 0
				SCAN WHILE empresa=xempresa and matriz_fiscal=xMatriz AND codigo_fiscal_operacao=xCFOP
					xCount = xCount+1
					SELECT cur_lf_registro_entrada_01_filtro 
					append blank
							
					REPLACE empresa 					with xempresa,;
							matriz_fiscal 				with xMatriz,codigo_fiscal_operacao WITH xCFOP,;
							razao_social_matriz_fiscal 	WITH Cur_Tot_Impostos_Agr.razao_social_matriz_fiscal,;
							rg_ie_matriz_fiscal			WITH Cur_Tot_Impostos_Agr.rg_ie_matriz_fiscal,;
							cgc_cpf_matriz_fiscal		WITH Cur_Tot_Impostos_Agr.cgc_cpf_matriz_fiscal,;
							Qb with xTpQb, SubQb with xSubQb, Desc_SubQb with xSubQb_Desc(xSubQb),;
							cod_icms           with Cur_Tot_Impostos_Agr.cod_icms,;
							base_imposto_icms  with Cur_Tot_Impostos_Agr.base_imposto_icms,;
							valor_imposto_icms with Cur_Tot_Impostos_Agr.valor_imposto_icms,;
							cod_ipi            with Cur_Tot_Impostos_Agr.cod_ipi,;
							base_imposto_Ipi   with Cur_Tot_Impostos_Agr.base_imposto_Ipi,;
							valor_imposto_Ipi  with Cur_Tot_Impostos_Agr.valor_imposto_Ipi
							IF Cur_Tot_Impostos_Agr.dif_ipi<>0 AND kk<>3 && AND id_imposto=2
								REPLACE obs with 'IPI:' + ALLTRIM(TRANSFORM(Cur_Tot_Impostos_Agr.dif_ipi,'9999 999 999.99'))
							ENDIF

					IF xCount=1
						replace valor_contabil WITH cur_vl_contabil_sum.valor_contabil
						IF Cur_Tot_Impostos_Agr.valor_ipi_obs<>0
							REPLACE obs with 'Total do IPI: ' + ALLTRIM(TRANSFORM(Cur_Tot_Impostos_Agr.valor_ipi_obs,'9999 999 999.99'))
						ENDIF 
					ENDIF
				ENDSCAN
			ENDDO

			*-- Total:
			DO CASE
			CASE kk=1
				xSubQb = 2
			CASE kk=3
				xSubQb = 4
			OTHERWISE
				xSubQb = 6
			ENDCASE 

			SELECT empresa,matriz_fiscal,razao_social_matriz_fiscal,rg_ie_matriz_fiscal,cgc_cpf_matriz_fiscal,VAL(LEFT(codigo_fiscal_operacao,1)) as tipo_CFOP,cod_icms,00 cod_ipi,SUM(dif_ipi) dif_ipi,;
				   SUM(base_imposto_icms) base_imposto_icms,SUM(valor_imposto_icms) valor_imposto_icms,;
				   000000000000.00 base_imposto_ipi,000000000000.00 valor_imposto_ipi,SUM(valor_ipi_obs) valor_ipi_obs ;
			  FROM cur_lf_registro_entrada_01_filtro WHERE Qb=1 AND VAL(LEFT(codigo_fiscal_operacao,1))=kk GROUP BY 1,2,3,4,5,6,7 INTO CURSOR Cur_Tot_Impostos_Agr READWRITE 
			  
			SELECT empresa,matriz_fiscal,razao_social_matriz_fiscal,rg_ie_matriz_fiscal,cgc_cpf_matriz_fiscal,VAL(LEFT(codigo_fiscal_operacao,1)) as tipo_CFOP,cod_ipi,SUM(base_imposto_ipi) base_imposto_ipi,SUM(valor_imposto_ipi)  valor_imposto_ipi,SUM(dif_ipi) dif_ipi ;
			  FROM cur_lf_registro_entrada_01_filtro WHERE Qb=1 AND VAL(LEFT(codigo_fiscal_operacao,1))=kk GROUP BY 1,2,3,4,5,6,7 INTO CURSOR Cur_Tot_Ipi

			SELECT Cur_Tot_Ipi
			SCAN
				SELECT Cur_Tot_Impostos_Agr 
				LOCATE FOR empresa=Cur_Tot_Ipi.empresa AND matriz_fiscal=Cur_Tot_Ipi.matriz_fiscal AND tipo_CFOP=Cur_Tot_Ipi.tipo_CFOP
				IF EOF() OR cod_ipi<>0
					APPEND BLANK 
					REPLACE empresa WITH Cur_Tot_Ipi.empresa,matriz_fiscal WITH Cur_Tot_Ipi.matriz_fiscal, tipo_CFOP WITH Cur_Tot_Ipi.tipo_CFOP
				ENDIF
				REPLACE cod_ipi WITH Cur_Tot_Ipi.cod_ipi, base_imposto_ipi WITH Cur_Tot_Ipi.base_imposto_ipi, valor_imposto_ipi WITH Cur_Tot_Ipi.valor_imposto_ipi 
			ENDSCAN
			
			SELECT Cur_Tot_Impostos_Agr
			GO TOP 
			DO whil !EOF()
				xempresa = empresa
				xMatriz  = matriz_fiscal
				xtCFOP	 = tipo_CFOP

				*--- total distinct para valor contabil
				select DISTINCT empresa,matriz_fiscal,nf_entrada,serie_nf_entrada, cod_clifor, codigo_fiscal_operacao, valor_contabil ;
				  from cur_lf_registro_entrada_01_filtro ;
				 WHERE Qb=1 and empresa=?xempresa and matriz_fiscal=?xMatriz  AND VAL(LEFT(codigo_fiscal_operacao,1))=xtCFOP;
				  INTO CURSOR cur_vl_contabil_distinct
				 
				select sum(valor_contabil) valor_contabil from cur_vl_contabil_distinct INTO CURSOR cur_vl_contabil_sum

				SELECT Cur_Tot_Impostos_Agr
				xCount = 0
				SCAN WHILE empresa=xempresa and matriz_fiscal=xMatriz  AND tipo_CFOP=xtCFOP
					xCount = xCount+1
					SELECT cur_lf_registro_entrada_01_filtro 
					append blank
							
					REPLACE empresa 					with xempresa,;
							matriz_fiscal 				with xMatriz,;
							razao_social_matriz_fiscal 	WITH Cur_Tot_Impostos_Agr.razao_social_matriz_fiscal,;
							rg_ie_matriz_fiscal			WITH Cur_Tot_Impostos_Agr.rg_ie_matriz_fiscal,;
							cgc_cpf_matriz_fiscal		WITH Cur_Tot_Impostos_Agr.cgc_cpf_matriz_fiscal,;
							Qb with xTpQb, SubQb with xSubQb, Desc_SubQb with xSubQb_Desc(xSubQb),;
							cod_icms           with Cur_Tot_Impostos_Agr.cod_icms,;
							base_imposto_icms  with Cur_Tot_Impostos_Agr.base_imposto_icms,;
							valor_imposto_icms with Cur_Tot_Impostos_Agr.valor_imposto_icms,;
							cod_ipi            with Cur_Tot_Impostos_Agr.cod_ipi,;
							base_imposto_Ipi   with Cur_Tot_Impostos_Agr.base_imposto_Ipi,;
							valor_imposto_Ipi  with Cur_Tot_Impostos_Agr.valor_imposto_Ipi
							IF Cur_Tot_Impostos_Agr.dif_ipi<>0 AND kk<>3 && AND id_imposto=2
								REPLACE obs with 'IPI:' + ALLTRIM(TRANSFORM(Cur_Tot_Impostos_Agr.dif_ipi,'9999 999 999.99'))
							ENDIF

					IF xCount=1
						replace valor_contabil WITH cur_vl_contabil_sum.valor_contabil
						IF Cur_Tot_Impostos_Agr.valor_ipi_obs<>0
							REPLACE obs with 'Total do IPI: ' + ALLTRIM(TRANSFORM(Cur_Tot_Impostos_Agr.valor_ipi_obs,'9999 999 999.99'))
						ENDIF 
					ENDIF
				ENDSCAN
			ENDDO

		ENDFOR
		*===

	CASE xTpQb=4 && Por UF

		*--#1#
		
		*===
			SELECT empresa,matriz_fiscal,razao_social_matriz_fiscal,rg_ie_matriz_fiscal,cgc_cpf_matriz_fiscal,NVL(UF,'') AS uf,cod_icms,00 cod_ipi,;
				   SUM(base_imposto_icms) base_imposto_icms,SUM(valor_imposto_icms) valor_imposto_icms,SUM(dif_ipi) dif_ipi,;
				   000000000000.00 base_imposto_ipi,000000000000.00 valor_imposto_ipi,SUM(valor_ipi_obs) valor_ipi_obs ;
			  FROM cur_lf_registro_entrada_01_filtro WHERE Qb=1 GROUP BY 1,2,3,4,5,6,7 INTO CURSOR Cur_Tot_Impostos_Agr READWRITE 
			  
			SELECT empresa,matriz_fiscal,razao_social_matriz_fiscal,rg_ie_matriz_fiscal,cgc_cpf_matriz_fiscal,NVL(UF,'') uf,cod_ipi,SUM(base_imposto_ipi) base_imposto_ipi,SUM(valor_imposto_ipi)  valor_imposto_ipi,SUM(dif_ipi) dif_ipi ;
			  FROM cur_lf_registro_entrada_01_filtro WHERE Qb=1 GROUP BY 1,2,3,4,5,6,7 INTO CURSOR Cur_Tot_Ipi

			SELECT Cur_Tot_Ipi
			SCAN
				SELECT Cur_Tot_Impostos_Agr 
				LOCATE FOR empresa=Cur_Tot_Ipi.empresa AND matriz_fiscal=Cur_Tot_Ipi.matriz_fiscal AND NVL(UF,'')=Cur_Tot_Ipi.uf
				IF EOF() OR cod_ipi<>0
					APPEND BLANK 
					REPLACE empresa WITH Cur_Tot_Ipi.empresa,matriz_fiscal WITH Cur_Tot_Ipi.matriz_fiscal, uf WITH Cur_Tot_Ipi.uf
				ENDIF
				REPLACE cod_ipi WITH Cur_Tot_Ipi.cod_ipi, base_imposto_ipi WITH Cur_Tot_Ipi.base_imposto_ipi , valor_imposto_ipi WITH Cur_Tot_Ipi.valor_imposto_ipi, dif_ipi WITH Cur_Tot_Ipi.dif_ipi 
			ENDSCAN
			
			SELECT Cur_Tot_Impostos_Agr
			GO TOP 
			DO whil !EOF()
				xempresa = empresa
				xMatriz  = matriz_fiscal
				xUF 	 = NVL(UF,'')

				*--- total distinct para valor contabil
				select DISTINCT empresa,matriz_fiscal,nf_entrada,serie_nf_entrada, cod_clifor, NVL(UF,'') AS uf, valor_contabil ;
				  from cur_lf_registro_entrada_01_filtro ;
				 WHERE Qb=1 and empresa=?xempresa and matriz_fiscal=?xMatriz AND NVL(UF,'')=xUF;
				  INTO CURSOR cur_vl_contabil_distinct
				 
				select sum(valor_contabil) valor_contabil from cur_vl_contabil_distinct INTO CURSOR cur_vl_contabil_sum

				SELECT Cur_Tot_Impostos_Agr
				xCount = 0
				SCAN WHILE empresa=xempresa and matriz_fiscal=xMatriz AND uf=xUF
					xCount = xCount+1
					SELECT cur_lf_registro_entrada_01_filtro 
					append blank
							
					REPLACE empresa 					with xempresa,;
							matriz_fiscal 				with xMatriz,;
							uf 							with xUF,;
							Qb 							with xTpQb,;
							razao_social_matriz_fiscal 	with Cur_Tot_Impostos_Agr.razao_social_matriz_fiscal,;
							rg_ie_matriz_fiscal			with Cur_Tot_Impostos_Agr.rg_ie_matriz_fiscal,;
							cgc_cpf_matriz_fiscal		with Cur_Tot_Impostos_Agr.cgc_cpf_matriz_fiscal,;
							cod_icms           with Cur_Tot_Impostos_Agr.cod_icms,;
							base_imposto_icms  with Cur_Tot_Impostos_Agr.base_imposto_icms,;
							valor_imposto_icms with Cur_Tot_Impostos_Agr.valor_imposto_icms,;
							cod_ipi            with Cur_Tot_Impostos_Agr.cod_ipi,;
							base_imposto_Ipi   with Cur_Tot_Impostos_Agr.base_imposto_Ipi,;
							valor_imposto_Ipi  with Cur_Tot_Impostos_Agr.valor_imposto_Ipi
							*!*								IF Cur_Tot_Impostos_Agr.dif_ipi<>0 && AND id_imposto=2
							*!*									REPLACE obs with 'IPI:' + ALLTRIM(TRANSFORM(Cur_Tot_Impostos_Agr.dif_ipi,'9999 999 999.99'))
							*!*								ENDIF

					IF xCount=1
						replace valor_contabil WITH cur_vl_contabil_sum.valor_contabil
						IF Cur_Tot_Impostos_Agr.valor_ipi_obs<>0
							REPLACE obs with 'Total do IPI: ' + ALLTRIM(TRANSFORM(Cur_Tot_Impostos_Agr.valor_ipi_obs,'9999 999 999.99'))
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
	