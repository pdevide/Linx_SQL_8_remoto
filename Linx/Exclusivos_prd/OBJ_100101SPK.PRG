Define Class Obj_Entrada as Custom

   Procedure Metodo_Usuario
   
      Lparameters cMetodo, oObjeto, cNome_Obj
      
      DO Case
      
      	CASE Upper(cmetodo) == 'USR_INIT'
	      	nTopStarq = 146
	      	
			thisformset.lx_form1.lx_pageframe1.page1.lx_pageframe1.Page_NFe.addobject("btnStarq1","btnStarq")
			thisformset.lx_form1.lx_pageframe1.page1.lx_pageframe1.Page_NFe.btnStarq1.top = nTopStarq &&323
			thisformset.lx_form1.lx_pageframe1.page1.lx_pageframe1.Page_NFe.btnStarq1.left = 10 &&410
			thisformset.lx_form1.lx_pageframe1.page1.lx_pageframe1.Page_NFe.btnStarq1.Visible=.t.      	

			thisformset.lx_form1.lx_pageframe1.page1.lx_pageframe1.Page_NFe.addobject("btnxml1","btnxml")
			thisformset.lx_form1.lx_pageframe1.page1.lx_pageframe1.Page_NFe.btnxml1.top = nTopStarq &&323
			thisformset.lx_form1.lx_pageframe1.page1.lx_pageframe1.Page_NFe.btnxml1.left = 170 &&570
			thisformset.lx_form1.lx_pageframe1.page1.lx_pageframe1.Page_NFe.btnxml1.Visible=.t.      	

			** paulo devide --> 2024-12-18 - botao para importar arquivo produto;cor
			** dados de quantidade total e por grade pega do estoque da filial EMITENTE
			ThisFormset.Lx_form1.Lx_pageframe1.Page2.addobject("btnImportaTXT_Produto_Cor1","btnImportaTXT_Produto_Cor")
			ThisFormset.Lx_form1.Lx_pageframe1.Page2.btnImportaTXT_Produto_Cor1.top = 375
			ThisFormset.Lx_form1.Lx_pageframe1.Page2.btnImportaTXT_Produto_Cor1.left = 10
			ThisFormset.Lx_form1.Lx_pageframe1.Page2.btnImportaTXT_Produto_Cor1.Visible=.t. 
			


		Case Upper(Alltrim(cMetodo)) == 'USR_REFRESH'
         
			IF  thisformset.p_tool_status = "P" && pesquisa feita
				lcAlias = ALIAS()
				

				lcSQL = "SELECT ERP_EBS_AR_DATA_ENVIO, ERP_EBS_GL_DATA_ENVIO, ERP_EBS_SYNCHRO_DATA_ENVIO "
				lcSQL = lcSQL + " FROM FATURAMENTO "
				lcSQL = lcSQL + " WHERE NF_SAIDA = '"+ALLTRIM(v_faturamento_05.nf_saida)+"'"
				lcSQL = lcSQL + " AND SERIE_NF = '"+ALLTRIM(v_faturamento_05.serie_nf)+"'"
				lcSQL = lcSQL + " AND FILIAL = '"+ALLTRIM(v_faturamento_05.filial)+"'"
				
				IF USED("vStatusEBS02")
					USE IN vStatusEBS02
				ENDIF
				F_SELECT(lcSQL,"vStatusEBS02")

				IF !ISNULL(vStatusEBS02.ERP_EBS_AR_DATA_ENVIO) ;
					OR !ISNULL(vStatusEBS02.ERP_EBS_GL_DATA_ENVIO) ;
					OR !ISNULL(vStatusEBS02.ERP_EBS_SYNCHRO_DATA_ENVIO) 
					WAIT WINDOW NOWAIT "exclus„o desabilitada - nota integrada" 
					o_toolbar.botao_exclui.Enabled= .f.
					o_toolbar.botao_altera.enabled =.f.
				ENDIF
				
				SELECT (lcAlias)
				
			ENDIF         

		Case Upper(Alltrim(cMetodo)) == 'USR_ALTER_BEFORE'
			lcAlias = ALIAS()
			
			lcSQL = "SELECT ERP_EBS_AR_DATA_ENVIO, ERP_EBS_GL_DATA_ENVIO, ERP_EBS_SYNCHRO_DATA_ENVIO "
			lcSQL = lcSQL + " FROM FATURAMENTO "
			lcSQL = lcSQL + " WHERE NF_SAIDA = '"+ALLTRIM(v_faturamento_05.nf_saida)+"'"
			lcSQL = lcSQL + " AND SERIE_NF = '"+ALLTRIM(v_faturamento_05.serie_nf)+"'"
			lcSQL = lcSQL + " AND FILIAL = '"+ALLTRIM(v_faturamento_05.filial)+"'"
			
			IF USED("vStatusEBS02")
				USE IN vStatusEBS02
			ENDIF
			F_SELECT(lcSQL,"vStatusEBS02")

			IF !ISNULL(vStatusEBS02.ERP_EBS_AR_DATA_ENVIO) ;
				OR !ISNULL(vStatusEBS02.ERP_EBS_GL_DATA_ENVIO) ;
				OR !ISNULL(vStatusEBS02.ERP_EBS_SYNCHRO_DATA_ENVIO) 
				WAIT WINDOW NOWAIT "exclus„o desabilitada - nota integrada" 
				MESSAGEBOX('Nota Integrada, nao e possivel a alteracao!', 16, wusuario)
				RETURN .F.

			ENDIF
			
			SELECT (lcAlias)
				
		Case Upper(Alltrim(cMetodo)) == 'USR_SAVE_BEFORE'			
			IF !(thisformset.p_tool_status $ "IA")
			
				lcAlias = ALIAS()
				
				lcSQL = "SELECT ERP_EBS_AR_DATA_ENVIO, ERP_EBS_GL_DATA_ENVIO, ERP_EBS_SYNCHRO_DATA_ENVIO "
				lcSQL = lcSQL + " FROM FATURAMENTO "
				lcSQL = lcSQL + " WHERE NF_SAIDA = '"+ALLTRIM(v_faturamento_05.nf_saida)+"'"
				lcSQL = lcSQL + " AND SERIE_NF = '"+ALLTRIM(v_faturamento_05.serie_nf)+"'"
				lcSQL = lcSQL + " AND FILIAL = '"+ALLTRIM(v_faturamento_05.filial)+"'"
				
				IF USED("vStatusEBS02")
					USE IN vStatusEBS02
				ENDIF
				F_SELECT(lcSQL,"vStatusEBS02")

				IF !ISNULL(vStatusEBS02.ERP_EBS_AR_DATA_ENVIO) ;
					OR !ISNULL(vStatusEBS02.ERP_EBS_GL_DATA_ENVIO) ;
					OR !ISNULL(vStatusEBS02.ERP_EBS_SYNCHRO_DATA_ENVIO) 
					WAIT WINDOW NOWAIT "exclus„o desabilitada - nota integrada" 
					MESSAGEBOX('Nota Integrada, nao e possivel a exclusao!', 16, wusuario)
					RETURN .F.

				ENDIF
				
			
				SELECT (lcAlias)
			endif			


		  Case Upper(Alltrim(cMetodo)) == 'USR_SAVE_AFTER' AND thisformset.p_tool_status = 'I'
		        	*SET STEP ON
		         	LOCAL iCabidesA43,iCabidesA38,iCabidesA33,iCabidesM26,iCabidesM35, iBolachas, iCxPino, iCxBolacha, iCxPino
		         	STORE 0 TO iCabidesA43,iCabidesA38,iCabidesA33,iCabidesM26,iCabidesM35, iBolachas, iCxPino, iCxBolacha, iCxPino
			        f_select("select * from parametros where parametro = 'CABILOG_NATUREZA_ORIGEM'", 'vtmp_natureza')
			        f_select("select * from parametros where parametro = 'CABILOG_FILIAL_MATRIZ'", 'vtmp_filial_mtz')
			        IF ALLTRIM(vtmp_filial_mtz.valor_Atual) = ALLTRIM(v_faturamento_05.filial) AND ALLTRIM(vtmp_natureza.valor_Atual) = ALLTRIM(v_faturamento_05.natureza_saida)
			        	SELECT v_faturamento_05_prod 	
			        	SCAN
			        		strSelect = "select a.produto, a.cor_produto, max(case when e.erp_cab_cod_cabide <> '' and e.ERP_CAB_OPCAO in (2,4) then 1+ dbo.lx_occurs('+',e.erp_cab_cod_cabide) else 0 end) as cabides, "+;
										"max(case when e.ERP_CAB_OPCAO in (3,4) then  "+;
										"	   case when case when b.varia_preco_cor = 1 then d.preco1 else c.preco1 end  >= 80 then 2 "+;
										"		   when case when b.varia_preco_cor = 1 then d.preco1 else c.preco1 end  between 15 and 79.99 then 1 "+;
										"		   else 0 end "+;
										"    else 0 end) as bolachas, e.erp_cab_cod_cabide "+;
										"FROM COMPRAS_PRODUTO A "+;
										"JOIN COMPRAS E ON A.PEDIDO = E.PEDIDO "+;
										"JOIN PRODUTOS B ON A.PRODUTO = B.PRODUTO "+;
										"LEFT JOIN PRODUTOS_PRECOS C ON A.PRODUTO = C.PRODUTO AND C.CODIGO_TAB_PRECO = '01' "+;
										"LEFT JOIN PRODUTOS_PRECO_COR D ON A.PRODUTO = D.PRODUTO AND A.COR_PRODUTO = D.COR_PRODUTO AND D.CODIGO_TAB_PRECO = '01' "+;
										"WHERE A.PRODUTO = '"+ALLTRIM(v_faturamento_05_prod.produto)+"' and a.cor_produto = '"+ALLTRIM(v_faturamento_05_prod.cor_produto)+"' "+;
										"and e.ERP_CAB_OPCAO  > 1 "+;
										"group by a.produto, a.cor_produto, e.erp_cab_cod_cabide"
			        		f_select(strSelect,'vtmp_cabilog')
			        		SELECT vtmp_cabilog
			        		IF RECCOUNT('vtmp_cabilog') > 0
			        			iCabidesA43 = iCabidesA43 + IIF('A43'$ NVL(vtmp_cabilog.erp_cab_cod_cabide,''),(v_faturamento_05_prod.qtde),0)
			        			iCabidesA38 = iCabidesA38 + IIF('A38'$ NVL(vtmp_cabilog.erp_cab_cod_cabide,''),(v_faturamento_05_prod.qtde),0)
			        			iCabidesA33 = iCabidesA33 + IIF('A33'$ NVL(vtmp_cabilog.erp_cab_cod_cabide,''),(v_faturamento_05_prod.qtde),0)
			        			iCabidesM26 = iCabidesM26 + IIF('M26'$ NVL(vtmp_cabilog.erp_cab_cod_cabide,''),(v_faturamento_05_prod.qtde),0)
			        			iCabidesM35 = iCabidesM35 + IIF('M35'$ NVL(vtmp_cabilog.erp_cab_cod_cabide,''),(v_faturamento_05_prod.qtde),0)
			        			
			        			**iCabides = iCabides + (NVL(vtmp_cabilog.cabides,0)*v_faturamento_05_prod.qtde)
			        			iBolachas = iBolachas + (NVL(vtmp_cabilog.bolachas,0)*v_faturamento_05_prod.qtde)
			        		ENDIF 
			        	
			        		SELECT v_faturamento_05_prod
			        	ENDSCAN 
			        	IF iCabidesA43 > 0 OR iCabidesA38 > 0 OR iCabidesA33 > 0 OR iCabidesM26 > 0 OR iCabidesM35 > 0 OR iBolachas > 0
			        		xNota = ALLTRIM(v_faturamento_05.nf_saida)
			        		xSerie = alltr(v_faturamento_05.serie_nf)
						xFilial = ALLTRIM(v_faturamento_05.filial)		        		
						f_insert("INSERT CAEDU_FATURAMENTO_CABIDES (NF_SAIDA,REQUISICAO,SERIE_NF,FILIAL,NF_CABIDE,GERADO_FATURAMENTO,GERADO_ENTRADA) "+;
								"VALUES('"+Alltr(xNota)+"',null,'"+Alltr(xSerie)+"','"+Alltr(xFilial)+"',null,0,0)")
			        		
			        	ENDIF 
			        ENDIF 

					** CAEDU - AGRUPAMENTO POR PEDIDOS TAG XPED NO XML - 09-03-2026 **
					IF v_faturamento_05.AGRUPAMENTO_ITENS=3 
						nnselect = SELECT()			
						WAIT WINDOW "ALTERANDO AGRUPAMENTO DE PEDIDO DO CLIENTE TAG XPED" NOWAIT
						** capturamento o codigo do pedido do cliente

						SELECT V_FATURAMENTO_05_ITEM
						GO TOP
						
												
						nPosicaoEspaco = AT(" ",V_FATURAMENTO_05_ITEM.descricao_item)
						cPedidoCliente = ALLTRIM(SUBSTR(V_FATURAMENTO_05_ITEM.descricao_item,1,nPosicaoEspaco-1))


						TEXT TO cmdsql NOSHOW TEXTMERGE PRETEXT 7
						UPDATE a SET 
							codigo_item = ltrim(rtrim(replace(codigo_item,?cPedidoCliente,''))), 
							descricao_item = ltrim(rtrim(replace(DESCRICAO_ITEM,?cPedidoCliente,'')))
						from FATURAMENTO_ITEM a
						WHERE a.NF_SAIDA=?v_faturamento_05.NF_SAIDA 
						and a.SERIE_NF=?v_faturamento_05.SERIE_NF 
						and a.FILIAL=?v_faturamento_05.FILIAL
							
						ENDTEXT
						f_execute(cmdsql)
						
						SELECT (nnselect)
					ENDIF 

         Otherwise

            Return .T.

      EndCase

   EndProc

EndDefine

DEFINE CLASS btnStarq as botao
	nTopStarq = 146
	top = nTopStarq &&323
	left = 10 &&410
	width = 150
	autosize = .f.
	caption = "Enviar para Starq"
	backcolor =  RGB(64,128,128)

	PROCEDURE when
		IF thisformset.pp_palma_acesso_botao_starq
			**WAIT WINDOW "voce tem acesso"
			RETURN .t.
		ELSE
			MESSAGEBOX("Acesso n„o permitido a esta funcionalidade!",16,"Aviso")
			RETURN .f.
		ENDIF
	ENDPROC
	
	PROCEDURE Click
		cmd = "update faturamento set status_nfe = -1 where nf_saida = '"+ALLTRIM(V_FATURAMENTO_05.NF_SAIDA)+;
				"' and filial = '"+ALLTRIM(V_FATURAMENTO_05.FILIAL)+"' and serie_nf='"+ALLTRIM(V_FATURAMENTO_05.SERIE_NF)+"'"
		f_execute(cmd)
		MESSAGEBOX("Status da nota fiscal "+ALLTRIM(V_FATURAMENTO_05.nf_saida) + " alterado para -1 com sucesso!")	
	ENDPROC

	PROCEDURE refresh
		** Inclus√£o/Altera√ß√£o/Exclus√£o/Tela (L)impa/(P)esquisa Feita!
		this.enabled = !INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L")
	ENDPROC

ENDDEFINE


DEFINE CLASS btnxml as botao
	top = 146 &&323
	left = 170 &&570
	width = 80
	autosize = .f.
	caption = "Gerar XML"

*!*		PROCEDURE when
*!*			IF thisformset.pp_palma_acesso_botao_starq
*!*				WAIT WINDOW "voce tem acesso"
*!*			ELSE
*!*				WAIT WINDOW "voce nao tem acesso"
*!*			ENDIF
*!*			
*!*		ENDPROC

	PROCEDURE refresh
		** Inclus√£o/Altera√ß√£o/Exclus√£o/Tela (L)impa/(P)esquisa Feita!
		this.enabled = !INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L")
	ENDPROC
	
	PROCEDURE click
		IF MESSAGEBOX("Deseja gerar o XML para esta nota fiscal?",292,"Aviso")=7
			RETURN
		ENDIF
		TEXT TO cmd NOSHOW TEXTMERGE
			exec lx_gera_nfe_sefaz_4_00 
			@NOTAFISCAL = '<<ALLTRIM(V_FATURAMENTO_05.NF_SAIDA)>>',        
			@SERIENOTA = '<<ALLTRIM(V_FATURAMENTO_05.SERIE_NF)>>',
			@FILIALNOTA = '<<ALLTRIM(V_FATURAMENTO_05.FILIAL)>>',
			@RETORNA_XML = 1
		ENDTEXT
		f_select(cmd, "v_xmlnfe")
		varq_saida = "nfe_"+ALLTRIM(V_FATURAMENTO_05.NF_SAIDA)+".xml"
		var_saida = PUTFILE("selecionar",varq_saida,"xml")
		IF EMPTY(var_saida)
			WAIT WINDOW "Cancelado pelo usu·rio!"
		ELSE
			select v_xmlnfe
			SCATTER MEMVAR memo
			STRTOFILE(m.xml_nfe,var_saida)
			MESSAGEBOX("Arquivo gerado em: "+var_saida,64,"Aviso")
		ENDIF
	ENDPROC
	
	
ENDDEFINE

DEFINE CLASS btnImportaTXT_Produto_Cor as botao
	top = 375
	left = 10
	width = 252
	autosize = .f.
	caption = "Importar arquivo TXT Produto e Cor"

*!*		PROCEDURE when
*!*			IF thisformset.pp_palma_acesso_botao_starq
*!*				WAIT WINDOW "voce tem acesso"
*!*			ELSE
*!*				WAIT WINDOW "voce nao tem acesso"
*!*			ENDIF
*!*			
*!*		ENDPROC

	PROCEDURE refresh
		** Inclus√£o/Altera√ß√£o/Exclus√£o/Tela (L)impa/(P)esquisa Feita!
		this.enabled = INLIST(ThisFormSet.p_Tool_Status,"I","A")
	ENDPROC
	
	PROCEDURE click
		IF MESSAGEBOX("Deseja importar o arquivo Txt (Produto;Cor)?",292,"Aviso")=7
			RETURN
		ENDIF

		lxArq = GETFILE("TXT","Selecione o Arquivo", "Selecione",0,"SeleÁ„o de Arquivo TXT")
		
		IF EMPTY(lxArq)
			MESSAGEBOX("Processo cancelado pelo usu·rio!", 64, "Aviso")
			RETURN 
		ENDIF

		IF USED("VESTOQUE1")
			SELECT VESTOQUE1 
			USE
		ENDIF
		
		CREATE CURSOR VESTOQUE1 (;
		produto	 C(8) NULL,;
		cor		 C(5) NULL)


		SELECT VESTOQUE1 
		APPEND FROM (lxArq) DELIMITED WITH CHARACTER ";"
		GO TOP
		lcTotReg = ALLTRIM(TRANSFORM(RECCOUNT("VESTOQUE1"),"999999"))
				
		SCAN 
			
			lcMsg1 = "Aguarde processando item "+ALLTRIM(TRANSFORM(RECNO("VESTOQUE1"),"999999"))+"/"+lcTotReg 

			f_wait(lcMsg1)
			IF !F_INFO_DADOS_PRODUTO_FAT(VESTOQUE1.produto,VESTOQUE1.cor,v_faturamento_05.filial)
				** exibe a msg e continua processando o arquivo para os demais itens
				MESSAGEBOX("Produto = "+ALLTRIM(VESTOQUE1.produto)+" Cor = "+ALLTRIM(VESTOQUE1.cor)+;
							" n„o encontrado ou n„o possui estoque"+CHR(13)+;
							"para a filial "+ALLTRIM(v_faturamento_05.filial)+"!",64,"Aviso")
			ENDIF
			
			
			SELECT VESTOQUE1
			
		ENDSCAN
		SELECT V_FATURAMENTO_05_ITEM
		GO TOP
		f_wait()
		
		SELECT v_faturamento_05
		replace nome_clifor_entrega WITH v_faturamento_05.nome_clifor ,;
				gerente WITH v_faturamento_05.filial ,;
				representante WITH v_faturamento_05.filial ,;
				moeda WITH "R$"
				
	ENDPROC
	
	
ENDDEFINE

FUNCTION F_INFO_DADOS_PRODUTO_FAT
PARAMETERS tProduto, tCor, tFilial

lcArea = SELECT()

TEXT TO CMDSQL NOSHOW TEXTMERGE PRETEXT 7
SELECT E.PRODUTO, E.COR_PRODUTO, '0000' as item, 
NULL AS PEDIDO_COR, NULL AS CAIXA, NULL AS PEDIDO, NULL AS PEDIDO_PRODUTO,NULL AS ENTREGA,0.00 AS DESCONTO_ITEM,
E.ESTOQUE as qtde, 
PP.PRECO1 AS PRECO, (E.ESTOQUE*PP.PRECO1) AS VALOR, 
E.ES1 AS F1, E.ES2 AS F2, E.ES3 AS F3, E.ES4 AS F4, E.ES5 AS F5, E.ES6 AS F6, E.ES7 AS F7, E.ES8 AS F8, E.ES9 AS F9, E.ES10 AS F10, 
E.ES11 AS F11, E.ES12 AS F12, E.ES13 AS F13, E.ES14 AS F14, E.ES15 AS F15, E.ES16 AS F16, E.ES17 AS F17, E.ES18 AS F18, E.ES19 AS F19, 
E.ES20 AS F20, E.ES21 AS F21, E.ES22 AS F22, E.ES23 AS F23, E.ES24 AS F24, E.ES25 AS F25, E.ES26 AS F26, E.ES27 AS F27, E.ES28 AS F28, 
E.ES29 AS F29, E.ES30 AS F30, E.ES31 AS F31, E.ES32 AS F32, E.ES33 AS F33, E.ES34 AS F34, E.ES35 AS F35, E.ES36 AS F36, E.ES37 AS F37, 
E.ES38 AS F38, E.ES39 AS F39, E.ES40 AS F40, E.ES41 AS F41, E.ES42 AS F42, E.ES43 AS F43, E.ES44 AS F44, E.ES45 AS F45, E.ES46 AS F46, 
E.ES47 AS F47, E.ES48 AS F48, '1' AS FAIXA,'O' AS ORIGEM, NULL AS ROMANEIO, CURRENT_TIMESTAMP AS TIMESTAMP,
0.00 AS CUSTO_NA_DATA, 0 AS MATA_SALDO, 'R$' AS MOEDA,     1.000000 AS CAMBIO_NA_DATA, NULL AS CODIGO_LOCAL_ENTREGA,
NULL AS ITEM_PEDIDO, NULL AS ORDEM_PRODUCAO, '5152' AS CODIGO_FISCAL_OPERACAO, FI.COD_FILIAL AS COD_FILIAL_ESTOQUE,
p.DESC_PROD_NF AS DESC_PRODUTO, p.CLASSIF_FISCAL, p.GRADE, CAST(0 AS bit) AS VARIA_CUSTO_TAM, CAST(0 AS bit) AS VARIA_PRECO_TAM,
p.PONTEIRO_PRECO_TAM, p.INDICADOR_CFOP, CAST(0 AS bit) AS VARIA_PRECO_COR, p.UNIDADE, p.CONTA_CONTABIL, p.TRIBUT_ICMS, 
p.TRIBUT_ORIGEM, PC.DESC_COR_PRODUTO, CX.DESCRICAO_INDICADOR_CFOP,
E.FILIAL AS FILIAL_ESTOQUE, 16 AS NUMERO_TAMANHOS, TB.DESCRICAO	AS TRIBUT_ORIGEM_DESCRICAO, TI.DESCRICAO AS TRIBUT_ICMS_DESCRICAO,
XP.DESC_CONTA, CF.DESC_CLASSIFICACAO,
0.00 AS COMISSAO_ITEM, 0.00 AS COMISSAO_ITEM_GERENTE, 
1 AS PESO1, 1 AS PESO2, 1 AS PESO3, 1 AS PESO4, 1 AS PESO5, 1 AS PESO6, 1 AS PESO7, 1 AS PESO8, 1 AS PESO9, 1 AS PESO10, 
1 AS PESO11, 1 AS PESO12, 1 AS PESO13, 1 AS PESO14, 1 AS PESO15, 1 AS PESO16, 1 AS PESO17, 1 AS PESO18, 1 AS PESO19, 
1 AS PESO20, 1 AS PESO21, 1 AS PESO22, 1 AS PESO23, 1 AS PESO24, 1 AS PESO25, 1 AS PESO26, 1 AS PESO27, 1 AS PESO28, 
1 AS PESO29, 1 AS PESO30, 1 AS PESO31, 1 AS PESO32, 1 AS PESO33, 1 AS PESO34, 1 AS PESO35, 1 AS PESO36, 1 AS PESO37, 
1 AS PESO38, 1 AS PESO39, 1 AS PESO40, 1 AS PESO41, 1 AS PESO42, 1 AS PESO43, 1 AS PESO44, 1 AS PESO45, 1 AS PESO46, 
1 AS PESO47, 1 AS PESO48, CAST(1 AS bit) AS GERAR_ITEM, 'P' AS COD_TABELA_FILHA, 0.00 AS PORC_DESCONTO_ITEM,
0.00 AS PESO_BRUTO, p.DESC_PROD_NF, NULL AS ID_VENDA_ENTREGA_FUTURA, 'P' AS ORIGEM_ITEM, p.ID_CEST_NCM,
TBCEST.DESCRICAO, TBCEST.CODIGO_CEST
FROM ESTOQUE_PRODUTOS E
inner join PRODUTOS p on p.PRODUTO = E.PRODUTO
inner join PRODUTOS_PRECOS PP ON PP.PRODUTO=E.PRODUTO AND PP.CODIGO_TAB_PRECO='02'
INNER JOIN FILIAIS FI ON FI.FILIAL = E.FILIAL
INNER JOIN PRODUTO_CORES PC ON PC.PRODUTO=E.PRODUTO AND PC.COR_PRODUTO=E.COR_PRODUTO
INNER JOIN CTB_LX_INDICADOR_CFOP CX ON CX.INDICADOR_CFOP = p.INDICADOR_CFOP
INNER JOIN TRIBUT_ORIGEM TB ON TB.TRIBUT_ORIGEM = p.TRIBUT_ORIGEM
INNER JOIN TRIBUT_ICMS TI ON TI.TRIBUT_ICMS = p.TRIBUT_ICMS
INNER JOIN W_CTB_CONTA_CONTABIL AS XP ON XP.CONTA_CONTABIL=p.CONTA_CONTABIL
INNER JOIN CLASSIF_FISCAL CF ON CF.CLASSIF_FISCAL = p.CLASSIF_FISCAL
LEFT JOIN (
select  
	TABELA_LX_CEST.CODIGO_CEST, 
	TABELA_LX_NCM.CODIGO_NCM, 
	Cast(TABELA_LX_CEST.DESCRICAO As VARCHAR(254)) As DESCRICAO, 
	CEST_NCM.ID, TABELA_LX_CEST.INATIVO 
from TABELA_LX_CEST   
JOIN CEST_NCM ON TABELA_LX_CEST.ID = CEST_NCM.ID_CEST 
JOIN TABELA_LX_NCM ON CEST_NCM.ID_NCM = TABELA_LX_NCM.ID) AS TBCEST 
	ON TBCEST.ID = p.ID_CEST_NCM AND TBCEST.CODIGO_NCM=p.CLASSIF_FISCAL
where E.PRODUTO = ?tProduto AND E.COR_PRODUTO = ?tCor AND E.FILIAL=?tFilial    

ENDTEXT
F_SELECT(CMDSQL,"v_item_01")
IF RECCOUNT("v_item_01")=0
	SELECT (lcArea)
	RETURN .f.
else
	SELECT V_FATURAMENTO_05_PROD
	APPEND BLANK && insere um registro em branco

	SELECT v_item_01
	SCATTER MEMVAR && copia os dados da temporaria v_item_01

	SELECT V_FATURAMENTO_05_PROD
	GATHER MEMVAR && cola os dados da temporaria v_item_01 na V_FATURAMENTO_05_PROD (tabela Linx)
	REPLACE V_FATURAMENTO_05_PROD.ITEM WITH RIGHT(REPLICATE("0",4)+TRANSFORM(RECNO("V_FATURAMENTO_05_PROD")),4)
	SELECT (lcArea)
	RETURN .t.
ENDIF

ENDFUNC
