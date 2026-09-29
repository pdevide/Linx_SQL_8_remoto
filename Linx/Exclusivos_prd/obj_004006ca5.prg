***************************************************************************
** PAULO EDUARDO DEVID…
** 04/05/2018
** OBJETIVO:
** =========
** OBJETO DE ENTRADA TELA DE PEDIDO DE COMPRAS
** UTILIZANDO O PACK DO CADASTRO DE PRODUTOS
***************************************************************************
** ALTERA«’ES DA TELA (NOME DO ARQUIVO/DATA/DESCRI«√O DA CUSTOMIZA«√O)
***************************************************************************
** 004006PK0 - 18/08/2016
** ADEQUA«√O DA TELA DE PEDIDOS ORIGINAL DA LINX PARA UTILIZAR 
** OS CONTROLES DE PACK DO CADASTRO DE PRODUTOS
**
** IMPORTA«√O DAS CUSTOMIZA«’ES DO PROGRAMA 004006PD1 PARA A NOVA TELA 
** DE PEDIDO DE COMPRAS
**
** 16-10-2017 -- ALTERA«√O CABILOG - IMPLEMENTA«√O DE BOLACHA DE ALARMES
***************************************************************************
*	USR_INIT
*	USR_ALTER_BEFORE  ->Return .f. Para o Metodo
*	USR_ALTER_AFTER
*	USR_INCLUDE_AFTER
*	USR_SEARCH_BEFORE ->Return .f. Para o Metodo
*	USR_SEARCH_AFTER
*	USR_CLEAN_AFTER
*	USR_REFRESH
*	USR_SAVE_BEFORE   ->Return .f. Para o Metodo
*	USR_SAVE_AFTER
*	USR_ITEN_DELETE_BEFORE ->Return .f. Para o Metodo
*	USR_ITEN_DELETE_AFTER
*	USR_ITEN_INCLUDE_BEFORE ->Return .f. Para o Metodo
*	USR_ITEN_INCLUDE_AFTER

DEFINE CLASS obj_entrada As Custom

	PROCEDURE metodo_usuario
	LPARAMETERS xmetodo, xobjeto, xnome_obj

	*** WAIT WINDOW NOWAIT xmetodo+CHR(13)+NVL(xnome_obj,"...")
	
	***
	* DEFINE O ROWSOURCE DOS COMBOBOX
	* CABIDES E MOEDAS
	*/
	PRIVATE ZZ_LISTA_CABIDES_CABILOG, ZZ_LISTA_MOEDAS
	
	**wait window xmetodo+chr(13)+TRANSFORM(xobjeto)+chr(13)+xnome_obj

	***F_SELECT("select VALOR_ATUAL AS COMBO_LISTA_CABIDES from PARAMETROS WHERE PARAMETRO ='LISTA_CABIDES_CABILOG'","TMPLISTA_COMBO_CABIDES")
	** MUDOU DE PARAMETRO PARA TABELA POIS ESTOUROU O TAMANHO DE 100 CARACTERES DO CAMPO PARAMETROS.VALOR_ATUAL ** -- 16-OUT-2020
	CMDSQL = "SELECT descricao FROM CAEDU_LISTA_COMBO WHERE id_dominio='022' ORDER BY descricao"
	F_SELECT(CMDSQL,"TMPLISTA_COMBO_CABIDES")
	SELECT TMPLISTA_COMBO_CABIDES
	ZZ_LISTA_CABIDES_CABILOG = ""
	SCAN
		ZZ_LISTA_CABIDES_CABILOG = ZZ_LISTA_CABIDES_CABILOG + ALLTRIM(TMPLISTA_COMBO_CABIDES.DESCRICAO)+","
	ENDSCAN
	**ZZ_LISTA_CABIDES_CABILOG = alltrim(TMPLISTA_COMBO_CABIDES.COMBO_LISTA_CABIDES)
	ZZ_LISTA_CABIDES_CABILOG = LEFT(ZZ_LISTA_CABIDES_CABILOG,LEN(ZZ_LISTA_CABIDES_CABILOG)-1) 

	F_SELECT("select VALOR_ATUAL AS COMBO_LISTA_MOEDAS from PARAMETROS WHERE PARAMETRO = 'PALMA_MOEDA_COMPRAS'","TMPLISTA_COMBO_MOEDAS")
	ZZ_LISTA_MOEDAS = alltrim(TMPLISTA_COMBO_MOEDAS.COMBO_LISTA_MOEDAS)

	F_SELECT("select NOTA_PROGRAMADOR from parametros where parametro =	'PALMA_GERENTES_PEDIDO'","V_CUR_GERENTES")
	lnQtdItens = GETWORDCOUNT(ALLTRIM(V_CUR_GERENTES.NOTA_PROGRAMADOR),";")
	
	PUBLIC array ZZ_LISTA_GERENTES[lnQtdItens]
	FOR izz=1 TO lnQtdItens
		ZZ_LISTA_GERENTES[izz] = GETWORDNUM(ALLTRIM(V_CUR_GERENTES.NOTA_PROGRAMADOR),izz,";")
	ENDFOR
	
	*****
	* INICIO DO OBJETO DE ENTRADA
	*/
	DO CASE
	CASE Upper(xmetodo) == 'USR_REFRESH'
		desabilita_toolbar_filha(thisformset)
		
		habilita_page_cabilog(thisformset)
	
	CASE Upper(xmetodo) == 'USR_INCLUDE_AFTER'
		** reseta o valor da propriedade
		THISFORMSET.PEDIDO_ORIGINAL_COPIA = ""

		desabilita_toolbar_filha(thisformset)
		LIMPA_LOG_AUTORIZACAO()
		PROC_004006_INCLUDE_AFTER(THISFORMSET, xmetodo, xobjeto, xnome_obj)
		ThisFormSet.EXCLUIU_ITENS = .F. && reset propriedade 	
		
		lcFilialPadrao = NVL(v_compras_01.FILIAL_A_ENTREGAR,RTRIM(o_004006.pp_filial_padrao))
		SELECT V_FILIAIS_00
		LOCATE FOR UPPER(ALLTRIM(FILIAL)) = UPPER(ALLTRIM(lcFilialPadrao))
		replace v_compras_01.RATEIO_FILIAL WITH V_FILIAIS_00.CLIFOR

	CASE Upper(xmetodo) == 'USR_VALID' AND UPPER(xnome_obj)='CMB_FILIAL_A_ENTREGAR'				
		IF INLIST(ThisFormSet.p_Tool_Status,"I","A")
			lcFilialPadrao = v_compras_01.FILIAL_A_ENTREGAR
			SELECT V_FILIAIS_00
			
			LOCATE FOR UPPER(ALLTRIM(FILIAL)) = UPPER(ALLTRIM(lcFilialPadrao))
			replace v_compras_01.RATEIO_FILIAL WITH V_FILIAIS_00.CLIFOR
			ThisFormSet.lx_form1.Lx_pageframe1.Page1.tv_rateio_filial.refresh
		ENDIF
		
	CASE Upper(xmetodo) == 'USR_VALID' AND UPPER(xnome_obj)='TX_PEDIDO_ORIGINAL'
		** atribui o conteudo do textbox TX_PEDIDO_ORIGINAL para guardar na propriedade
		** PEDIDO_ORIGINAL_COPIA, pois o conteudo do textbox √© apagado ap√≥s o processamento na tela
		thisformset.PEDIDO_ORIGINAL_COPIA = ALLTRIM(VTMP_PEDIDO_COPIA.pedido_origem)
	
	CASE Upper(xmetodo) == 'USR_VALID' AND UPPER(xnome_obj)='BT_DUPLICA'
		COPIAR_PEDIDO_EXT(thisformset) && copiar campos exclusivos do pedido, que n√£o s√£o padr√£o do Linx
		
	CASE Upper(xmetodo) == 'USR_VALID' AND UPPER(xnome_obj)='TV_FORNECEDOR'

		IF ThisFormSet.p_Tool_Status="I" && Somente na inclus√£o
			f_select("select * from fornecedores where fornecedor = ?v_compras_01.fornecedor", 'vtmp_forn')
			IF RECCOUNT('vtmp_forn') > 0 
				SELECT v_compras_01
				replace v_compras_01.FILIAL_A_ENTREGAR	WITH NVL(vtmp_forn.ERP_FILIAL_A_ENTREGAR,RTRIM(o_004006.pp_filial_padrao)),;
						v_compras_01.FILIAL_COBRANCA 	WITH NVL(vtmp_forn.ERP_FILIAL_COBRANCA,'MATRIZ'),;
						v_compras_01.FILIAL_A_FATURAR	WITH NVL(vtmp_forn.ERP_FILIAL_A_FATURAR,RTRIM(o_004006.pp_filial_padrao))

				lcFilialPadrao = NVL(vtmp_forn.ERP_FILIAL_A_ENTREGAR,RTRIM(o_004006.pp_filial_padrao))
				SELECT V_FILIAIS_00
				
				LOCATE FOR UPPER(ALLTRIM(FILIAL)) = UPPER(ALLTRIM(lcFilialPadrao))
				replace v_compras_01.RATEIO_FILIAL WITH V_FILIAIS_00.CLIFOR
			
			ENDIF 
		ENDIF		
	CASE Upper(xmetodo) == 'USR_VALID' AND UPPER(xnome_obj)='TV_TIPO_COMPRA'
		WAIT WINDOW NOWAIT ALLTRIM(V_COMPRAS_01.TIPO_COMPRA)
		habilita_page_cabilog(thisformset)
		
	CASE Upper(xmetodo) == 'USR_VALID' AND UPPER(xnome_obj)='TX_ENTREGA_UNICA'

		IF ThisFormSet.p_Tool_Status="I" && Somente na inclus√£o
			thisformset.lx_form1.lx_pageframe1.Page1.tx_data_otb1.value = xobjeto.value
		ENDIF

	CASE Upper(xmetodo) == 'USR_WHEN' AND UPPER(xnome_obj)='TX_LIMITE_ENTREGA_UNICA'

		IF ThisFormSet.p_Tool_Status="I" && Somente na inclus√£o
	
			pDataEntregaUnica = thisformset.lx_form1.lx_pageframe1.Page1.TX_ENTREGA_UNICA.value

*!*				thisformset.lx_form1.lx_pageframe1.Page1.tx_LIMITE_ENTREGA_UNICA.value = xobjeto.value+;
*!*				ICASE(DOW(xobjeto.value)=1,4,DOW(xobjeto.value)=2,3,DOW(xobjeto.value)=3,2,;
*!*				DOW(xobjeto.value)=4,1,DOW(xobjeto.value)=5,7,DOW(xobjeto.value)=6,6,5)
			thisformset.lx_form1.lx_pageframe1.Page1.tx_LIMITE_ENTREGA_UNICA.value = pDataEntregaUnica +;
			ICASE(DOW(pDataEntregaUnica)=1,4,DOW(pDataEntregaUnica)=2,3,DOW(pDataEntregaUnica)=3,2,;
			DOW(pDataEntregaUnica)=4,1,DOW(pDataEntregaUnica)=5,7,DOW(pDataEntregaUnica)=6,6,5)

			thisformset.lx_form1.lx_pageframe1.Page1.tx_LIMITE_ENTREGA_UNICA.REFRESH
		ENDIF
																		
	
	CASE Upper(xmetodo) == 'USR_ALTER_BEFORE'
		** reseta o valor da propriedade
		THISFORMSET.PEDIDO_ORIGINAL_COPIA = ""
		
		ThisFormSet.EXCLUIU_ITENS = .F. && reset propriedade 			
		LIMPA_LOG_AUTORIZACAO()
		desabilita_toolbar_filha(thisformset)
		THISFORMSET.QUANTIDADE_TOTAL_ORIGINAL = v_Compras_01.TOT_QTDE_ORIGINAL
		*WAIT WINDOW THISFORMSET.QUANTIDADE_TOTAL_ORIGINAL
		RETURN (PROC_004006_ALTER_BEFORE(THISFORMSET, xmetodo, xobjeto, xnome_obj))
	
	CASE Upper(xmetodo) == 'USR_INIT'
		
		PUBLIC meuproduto
		meuproduto = ""
		
		INIT_CONFIGURA(THISFORMSET, xmetodo, xobjeto, xnome_obj)
		
		ADICIONA_CONTROLES(THISFORMSET, xmetodo, xobjeto, xnome_obj)
		
		THISFORMSET.l_limpa()

	CASE Upper(xmetodo) == 'USR_SAVE_BEFORE'
	
		WAIT WINDOW "validando..." TIMEOUT 1
		*verifica se preencheu a propriedade quando È ecommerce
		IF ALLTRIM(v_compras_01.tipo_compra) = "E-COMMERCE"

			lcAliasAntes = ALIAS()
			SELECT CURPROPCOMPRAS
			cfilter = SET("Filter") && guarda o filtro da abra propriedades
			SET FILTER TO && desliga o filtro
			LOCATE FOR propriedade = "00115" &&AND ALLTRIM(pedido) = ALLTRIM(v_compras_01.pedido)
			lxPedido1 = ALLTRIM(valor_propriedade)
			f_select("select COUNT(*) as qty from compras where pedido = ?lxPedido1","tmpPropComprasX")
			IF tmpPropComprasX.qty = 0
				IF (ALLTRIM(UPPER(lxPedido1)) <> ALLTRIM(UPPER(v_compras_01.pedido))) 
					MESSAGEBOX("ObrigatÛrio informar um pedido m„e v·lido quando o pedido È de E-commerce",16,"Aviso")
					SELECT CURPROPCOMPRAS	
					SET FILTER TO &cfilter
					GO top
					SELECT &lcAliasAntes.
				
					RETURN .f.
				ENDIF
				
			ENDIF
			SELECT CURPROPCOMPRAS	
			SET FILTER TO &cfilter
			GO top
			SELECT &lcAliasAntes.
			
		ENDIF
		
		************
		*SET STEP ON 
		llCancela = (RECCOUNT("V_COMPRAS_01_CANCELAMENTO")>0)
		
		***
		* Se tiver dados de cancelamento, n√£o validar 
		* nenhuma regra e permitir salvar o pedido
		*/
		IF llCancela 
			RETURN .t.
		ENDIF

		***
		* Muda o valor de STATUS_APROVACAO para "A"
		* independente do valor que seja informado pelo Linx
		* 14-nov-17
		*/
		IF V_COMPRAS_01.STATUS_APROVACAO <> "A"
			WAIT WINDOW [STATUS_APROVACAO ALTERADO DE "]+V_COMPRAS_01.STATUS_APROVACAO+[" PARA "A"] TIMEOUT 2
		ENDIF
		REPLACE V_COMPRAS_01.STATUS_APROVACAO WITH "A"
		
		llOk0 = VALIDA_CABILOG(ThisFormSet.lx_form1.lx_pageframe1.pgWarning.lista_erro1, ThisformSet)
		IF !llOk0
			Thisformset.lx_form1.lx_pageframe1.activepage = getPageIndex(Thisformset, "Avisos")
			RETURN llOk0 && retorna falso e interrompe o comando salvar at√© que o 
							&& usu√°rio corrija os erros e salve novamente.
		ENDIF
		
		PRIVATE pdEntrega, pdLimite
		pdEntrega = ThisFormSet.lx_form1.Lx_pageframe1.Page1.tx_ENTREGA_UNICA.value
		pdLimite = ThisFormSet.lx_form1.Lx_pageframe1.Page1.tx_LIMITE_ENTREGA_UNICA.value


		llOk1 = VALIDA_CAMPOS_PEDIDO(ThisFormSet.lx_form1.lx_pageframe1.pgWarning.lista_erro1)

		IF !llOk1
			Thisformset.lx_form1.lx_pageframe1.activepage = getPageIndex(Thisformset, "Avisos")
			RETURN llOk1 && retorna falso e interrompe o comando salvar at√© que o 
						&& usu√°rio corrija os erros e salve novamente.
		ENDIF
		
		llOk2 = VALIDA_METRICAS_PEDIDO(ThisFormSet.lx_form1.lx_pageframe1.pgWarning.lista_metrica1)

		IF !llOk2
			Thisformset.lx_form1.lx_pageframe1.activepage = getPageIndex(Thisformset, "Avisos")
			
			GRAVA_LOG_AUTORIZACAO()
			
			SELECT V_COMPRAS_01
			REPLACE STATUS_COMPRA WITH '04' && AGUARDANDO SENHA (LIBERA√á√ÉO)
			
			***
			* Muda o valor de STATUS_APROVACAO para "A"
			* independente do valor que seja informado pelo Linx
			* 14-nov-17
			*/
			REPLACE V_COMPRAS_01.STATUS_APROVACAO WITH "A"
			
			
			RETURN .T. &&llOk2 -- retorna falso e interrompe o comando salvar at√© que o 
					   && usu√°rio corrija os erros e salve novamente.
		ENDIF
			
	CASE Upper(xmetodo) == 'USR_SAVE_AFTER'

		IF ThisFormSet.p_Tool_Status="A" && Somente no modo alteraÁ„o
			F_EXECUTE("UPDATE COMPRAS SET ERP_UNOUS_DATA_ENVIO = null WHERE PEDIDO=?v_compras_01.PEDIDO")
		ENDIF

		** reseta o valor da propriedade
		THISFORMSET.PEDIDO_ORIGINAL_COPIA = ""
		
		***
		* PROJETO CUPS - ATUALIZAR DATA_PARA_TRANSFERENCIA DO CADASTRO DE PRODUTOS PARA SENSIBILIZAR O ENSEMBLE
		*/
		IF ALLTRIM(v_compras_01.ERP_CUPS_TIPO_PEDIDO)=="CCF"
			IF !USED("vcur_total_produto")
				SELECT produto,SUM(qtde_original) as qtde_original, 00000000.0000 as PACKTOTAL ;
				FROM v_compras_01_produtos WITH (BUFFERING=.T.) ;
				GROUP BY produto INTO CURSOR vcur_total_produto READWRITE
			ENDIF
			
			SELECT vcur_total_produto
			GO top
			SCAN
				f_execute("UPDATE PRODUTOS SET DATA_PARA_TRANSFERENCIA = GETDATE() WHERE PRODUTO=?vcur_total_produto.PRODUTO")
			ENDSCAN
		ENDIF
		
		** CUPS - ATUALIZA O CAMPO DATA_PARA_TRANSFERENCIA --------------------------------------------------
		F_EXECUTE("UPDATE COMPRAS SET STATUS_APROVACAO = 'A', DATA_PARA_TRANSFERENCIA = GETDATE() WHERE PEDIDO=?v_compras_01.PEDIDO")
		** --------------------------------------------------------------------------------------------------

		ThisFormSet.EXCLUIU_ITENS = .F. && reset propriedade 	
		
		*** <<CAEDU>> - PAULO DEVIDE - 19-01-2026 - RECALCULO DO TOT_VALOR_ORIGINAL, ESTAVA FICANDO NULO APOS SALVAR
		IF ThisFormSet.p_Tool_Status="A" && Somente no modo alteraÁ„o
			
			TEXT TO cmdsql01 NOSHOW TEXTMERGE PRETEXT 7
				UPDATE COMPRAS SET TOT_VALOR_ORIGINAL=(SELECT sum(VALOR_ORIGINAL) 
													FROM COMPRAS_PRODUTO B where B.pedido = ?v_compras_01.PEDIDO) - isnull(compras.DESCONTO,0)
				WHERE COMPRAS.PEDIDO = ?v_compras_01.PEDIDO and COMPRAS.TOT_VALOR_ORIGINAL IS NULL
			ENDTEXT
			f_execute(cmdsql01)
			** atualiza a tela
			*thisformset.l_procura()
			ThisFormset.Lx_form1.Lx_pageframe1.activepage = 1 
			o_toolbar.Botao_refresh.Click
			
						
		ENDIF 
			
	OTHERWISE
		RETURN .T.

	ENDCASE
	*/
	* FIM DO OBJETO DE ENTRADA
	*****

	ENDPROC && fim --> PROCEDURE metodo_usuario

ENDDEFINE

****************************************************************************
******************** FUNCTION E PROCEDURES DA CLASSE ***********************
****************************************************************************

****
* PAULO DEVIDE
* CONFIGURA√á√ïES DO M√âTODO USR_INIT
* CRIADO EM: 18/08/2016
*/
FUNCTION INIT_CONFIGURA
	LPARAMETERS objTelaPai, xmetodo, xobjeto, xnome_obj
	WAIT WINDOW NOWAIT "OBJETO"

	SELECT v_compras_01
	oCursor = GETCURSORADAPTER("v_compras_01")
	oCursor.AddBufferField("COMPRAS.CAEDU_DATA_ENTREGA_ORIGINAL","D",.T.,"CAEDU_DATA_ENTREGA_ORIGINAL","COMPRAS.CAEDU_DATA_ENTREGA_ORIGINAL")
	oCursor.AddBufferField("COMPRAS.CAEDU_DATA_OTB","D",.T.,"CAEDU_DATA_OTB","COMPRAS.CAEDU_DATA_OTB")
	oCursor.AddBufferField("COMPRAS.ERP_CAB_COD_CABIDE","C(15)",.T.,"ERP_CAB_COD_CABIDE","COMPRAS.ERP_CAB_COD_CABIDE")
	oCursor.AddBufferField("COMPRAS.ERP_CAB_CD_ENTREGA","C(15)",.T.,"ERP_CAB_CD_ENTREGA","COMPRAS.ERP_CAB_CD_ENTREGA")
	oCursor.AddBufferField("COMPRAS.ERP_CAB_ENCABIDADO","L(1)",.T.,"ERP_CAB_ENCABIDADO","COMPRAS.ERP_CAB_ENCABIDADO")
	oCursor.AddBufferField("COMPRAS.ERP_CAB_STATUS","C(1)",.T.,"ERP_CAB_STATUS","COMPRAS.ERP_CAB_STATUS")
	oCursor.AddBufferField("COMPRAS.ERP_CAB_LOCALIZACAO","C(20)",.T.,"ERP_CAB_LOCALIZACAO","COMPRAS.ERP_CAB_LOCALIZACAO")
	oCursor.AddBufferField("COMPRAS.ERP_CAB_QTDPECAS","I",.T.,"ERP_CAB_QTDPECAS","COMPRAS.ERP_CAB_QTDPECAS")
	oCursor.AddBufferField("COMPRAS.ERP_CAB_TIPO_PEDIDO","C(15)",.T.,"ERP_CAB_TIPO_PEDIDO","COMPRAS.ERP_CAB_TIPO_PEDIDO")
	oCursor.AddBufferField("COMPRAS.ERP_CAB_DATA_ENVIO","D",.T.,"ERP_CAB_DATA_ENVIO","COMPRAS.ERP_CAB_DATA_ENVIO")
	oCursor.AddBufferField("COMPRAS.ERP_FOLLOW_UP_MARGEM","M",.T.,"ERP_FOLLOW_UP_MARGEM","COMPRAS.ERP_FOLLOW_UP_MARGEM")
	oCursor.AddBufferField("COMPRAS.ERP_CUPS_TIPO_PEDIDO","C(3)",.T.,"ERP_CUPS_TIPO_PEDIDO","COMPRAS.ERP_CUPS_TIPO_PEDIDO")
	oCursor.AddBufferField("COMPRAS.ERP_CUPS_SEGMENTO","C(7)",.T.,"ERP_CUPS_SEGMENTO","COMPRAS.ERP_CUPS_SEGMENTO")
	oCursor.AddBufferField("COMPRAS.ERP_CUPS_DATA_ACORDADA","D",.T.,"ERP_CUPS_DATA_ACORDADA","COMPRAS.ERP_CUPS_DATA_ACORDADA")
	oCursor.AddBufferField("COMPRAS.ERP_CUPS_PECA_MOSTRUARIO","L",.T.,"ERP_CUPS_PECA_MOSTRUARIO","COMPRAS.ERP_CUPS_PECA_MOSTRUARIO")
	oCursor.AddBufferField("COMPRAS.ERP_CUPS_EMBARQUE_ATUAL","D",.T.,"ERP_CUPS_EMBARQUE_ATUAL","COMPRAS.ERP_CUPS_EMBARQUE_ATUAL")
	oCursor.AddBufferField("COMPRAS.ERP_CUPS_EMBARQUE_REAL","D",.T.,"ERP_CUPS_EMBARQUE_REAL","COMPRAS.ERP_CUPS_EMBARQUE_REAL")
	oCursor.AddBufferField("COMPRAS.ERP_CUPS_CONTRATO","C(25)",.T.,"ERP_CUPS_CONTRATO","COMPRAS.ERP_CUPS_CONTRATO")
	oCursor.AddBufferField("COMPRAS.ERP_CUPS_CHEGADA_PORTO","D",.T.,"ERP_CUPS_CHEGADA_PORTO","COMPRAS.ERP_CUPS_CHEGADA_PORTO")
	oCursor.AddBufferField("COMPRAS.ERP_CUPS_CHEGADA_CD","D",.T.,"ERP_CUPS_CHEGADA_CD","COMPRAS.ERP_CUPS_CHEGADA_CD")
	oCursor.AddBufferField("COMPRAS.ERP_CUPS_PROCESSO_CCF_CCA","C(25)",.T.,"ERP_CUPS_PROCESSO_CCF_CCA","COMPRAS.ERP_CUPS_PROCESSO_CCF_CCA")
	oCursor.AddBufferField("COMPRAS.ERP_CUPS_EMBARQUE_LIBERADO","L",.T.,"ERP_CUPS_EMBARQUE_LIBERADO","COMPRAS.ERP_CUPS_EMBARQUE_LIBERADO")
	oCursor.AddBufferField("COMPRAS.ERP_CUPS_SEQ_PRODUTO","I",.T.,"ERP_CUPS_SEQ_PRODUTO","COMPRAS.ERP_CUPS_SEQ_PRODUTO")
	oCursor.AddBufferField("COMPRAS.ERP_CUPS_INCOTERM","C(6)",.T.,"ERP_CUPS_INCOTERM","COMPRAS.ERP_CUPS_INCOTERM")
	oCursor.AddBufferField("COMPRAS.ERP_CUPS_ID_CONTRATO","C(7)",.T.,"ERP_CUPS_ID_CONTRATO","COMPRAS.ERP_CUPS_ID_CONTRATO")
	oCursor.AddBufferField("COMPRAS.ERP_PERCENT_VERBAS","N(10,4)",.T.,"ERP_PERCENT_VERBAS","COMPRAS.ERP_PERCENT_VERBAS")
	oCursor.AddBufferField("COMPRAS.ERP_IMPORTADO","L",.T.,"ERP_IMPORTADO","COMPRAS.ERP_IMPORTADO")
	oCursor.AddBufferField("COMPRAS.ERP_MOEDA","C(5)",.T.,"ERP_MOEDA","COMPRAS.ERP_MOEDA")
	oCursor.AddBufferField("COMPRAS.ERP_TOTAL_QTD_DISTRIB","I",.T.,"ERP_TOTAL_QTD_DISTRIB","COMPRAS.ERP_TOTAL_QTD_DISTRIB")
	oCursor.AddBufferField("COMPRAS.ERP_PERCENT_DISTRIB","N(10,6)",.T.,"ERP_PERCENT_DISTRIB","COMPRAS.ERP_PERCENT_DISTRIB")
	oCursor.AddBufferField("COMPRAS.ERP_TOTAL_CAIXAS_ORIGINAL","I",.T.,"ERP_TOTAL_CAIXAS_ORIGINAL","COMPRAS.ERP_TOTAL_CAIXAS_ORIGINAL")
	oCursor.AddBufferField("COMPRAS.ERP_PACK_RESTO","L",.T.,"ERP_PACK_RESTO","COMPRAS.ERP_PACK_RESTO")
	oCursor.AddBufferField("COMPRAS.ERP_DISTRIBUICAO","L",.T.,"ERP_DISTRIBUICAO","COMPRAS.ERP_DISTRIBUICAO")
	oCursor.AddBufferField("COMPRAS.ERP_MANUAL","L",.T.,"ERP_MANUAL","COMPRAS.ERP_MANUAL")
	oCursor.AddBufferField("COMPRAS.ERP_LIBERADO_CQ","L",.T.,"ERP_LIBERADO_CQ","COMPRAS.ERP_LIBERADO_CQ")
	oCursor.AddBufferField("COMPRAS.ERP_FATURADO","L",.T.,"ERP_FATURADO","COMPRAS.ERP_FATURADO")
	oCursor.AddBufferField("COMPRAS.ERP_CAB_OPCAO","I",.T.,"ERP_CAB_OPCAO","COMPRAS.ERP_CAB_OPCAO")
	oCursor.AddBufferField("COMPRAS.ERP_CAB_COD_BOLACHA","C(15)",.T.,"ERP_CAB_COD_BOLACHA","COMPRAS.ERP_CAB_COD_BOLACHA")
	oCursor.AddBufferField("COMPRAS.ERP_MES_NA_LOJA","C(10)",.T.,"ERP_MES_NA_LOJA","COMPRAS.ERP_MES_NA_LOJA") && JIRA SI-12
	oCursor.confirmStructureChanges()
	
	SELECT v_compras_01_produtos
	oCursor = GETCURSORADAPTER("v_compras_01_produtos")

*!*		oCursor.bufferfields("COMPRAS_PRODUTO.CUSTO1","N(20,6)",.T.,"CUSTO1","COMPRAS_PRODUTO.CUSTO1")
*!*		oCursor.bufferfields("COMPRAS_PRODUTO.CUSTO2","N(20,6)",.T.,"CUSTO2","COMPRAS_PRODUTO.CUSTO2")
*!*		oCursor.bufferfields("COMPRAS_PRODUTO.CUSTO3","N(20,6)",.T.,"CUSTO3","COMPRAS_PRODUTO.CUSTO3")
*!*		oCursor.bufferfields("COMPRAS_PRODUTO.CUSTO4","N(20,6)",.T.,"CUSTO4","COMPRAS_PRODUTO.CUSTO4")
*!*		oCursor.bufferfields("COMPRAS_PRODUTO.CUSTO_MOEDA1","N(20,6)",.T.,"CUSTO_MOEDA1","COMPRAS_PRODUTO.CUSTO_MOEDA1")
*!*		oCursor.bufferfields("COMPRAS_PRODUTO.CUSTO_MOEDA2","N(20,6)",.T.,"CUSTO_MOEDA2","COMPRAS_PRODUTO.CUSTO_MOEDA2")
*!*		oCursor.bufferfields("COMPRAS_PRODUTO.CUSTO_MOEDA3","N(20,6)",.T.,"CUSTO_MOEDA3","COMPRAS_PRODUTO.CUSTO_MOEDA3")
*!*		oCursor.bufferfields("COMPRAS_PRODUTO.CUSTO_MOEDA4","N(20,6)",.T.,"CUSTO_MOEDA4","COMPRAS_PRODUTO.CUSTO_MOEDA4")
	oCursor.AddBufferField("COMPRAS_PRODUTO.ERP_CUPS_PACKS_POR_CAIXA","I",.T.,"ERP_CUPS_PACKS_POR_CAIXA","COMPRAS_PRODUTO.ERP_CUPS_PACKS_POR_CAIXA")
	oCursor.AddBufferField("COMPRAS_PRODUTO.ERP_CUPS_CUSTO_FOB","N(9,4)",.T.,"ERP_CUPS_CUSTO_FOB","COMPRAS_PRODUTO.ERP_CUPS_CUSTO_FOB")
	oCursor.AddBufferField("COMPRAS_PRODUTO.ERP_PERC_MARGEM","N(9,6)",.T.,"ERP_PERC_MARGEM","COMPRAS_PRODUTO.ERP_PERC_MARGEM")
	oCursor.AddBufferField("COMPRAS_PRODUTO.ERP_CUPS_SEQUENCIA","I",.T.,"ERP_CUPS_SEQUENCIA","COMPRAS_PRODUTO.ERP_CUPS_SEQUENCIA")
	oCursor.AddBufferField("COMPRAS_PRODUTO.ERP_CUPS_CUSTO_FOB_MINIMO","N(9,4)",.T.,"ERP_CUPS_CUSTO_FOB_MINIMO","COMPRAS_PRODUTO.ERP_CUPS_CUSTO_FOB_MINIMO")
	oCursor.AddBufferField("COMPRAS_PRODUTO.ERP_VERBAS_EMPENHO","N(9,2)",.T.,"ERP_VERBAS_EMPENHO","COMPRAS_PRODUTO.ERP_VERBAS_EMPENHO")
	oCursor.AddBufferField("COMPRAS_PRODUTO.ERP_VERBAS_DATA_EMPENHO","D",.T.,"ERP_VERBAS_DATA_EMPENHO","COMPRAS_PRODUTO.ERP_VERBAS_DATA_EMPENHO")
	oCursor.AddBufferField("COMPRAS_PRODUTO.ERP_VERBAS_EMPENHO_ANO_MES","I",.T.,"ERP_VERBAS_EMPENHO_ANO_MES","COMPRAS_PRODUTO.ERP_VERBAS_EMPENHO_ANO_MES")
	oCursor.AddBufferField("COMPRAS_PRODUTO.ERP_VERBAS_STATUS_PR","L",.T.,"ERP_VERBAS_STATUS_PR","COMPRAS_PRODUTO.ERP_VERBAS_STATUS_PR")
	oCursor.AddBufferField("COMPRAS_PRODUTO.ERP_CONJUNTO","L",.T.,"ERP_CONJUNTO","COMPRAS_PRODUTO.ERP_CONJUNTO")
	oCursor.AddBufferField("COMPRAS_PRODUTO.ERP_COR_PRODUTO2","C(6)",.T.,"ERP_COR_PRODUTO2","COMPRAS_PRODUTO.ERP_COR_PRODUTO2")
	oCursor.confirmStructureChanges()


	load_ca_vproduto(objTelaPai)
	load_caedu_compras_produtos_packs(objTelaPai)
	load_caedu_compras_produtos_packs_total(objTelaPai)
	load_v_produtos_99(objTelaPai)
	load_v_produtos_00_packs_permitidos(objTelaPai)
	load_v_produtos_00_packs_permitidos_total(objTelaPai)
	load_produtos_pack_distrib(objTelaPai)
	load_cursor_caedu_compras_entrega_log(objTelaPai)

	objTelaPai.lx_form1.minbutton=.t.
	objTelaPai.lx_form1.maxbutton=.t.

	objTelaPai.lx_form1.lx_pageframe1.TabStretch = 0 && multiple rows (pageframe)

	objTelaPai.lx_form1.Height = objTelaPai.lx_form1.Height + 90
	objTelaPai.lx_form1.Width = objTelaPai.lx_form1.Width + 90

	*** FILTRO PARA N√ÉO PERMITIR USAR CONDICAO DE PAGAMENTO E FORNECEDOR QUE N√ÉO TENHA UMA ID ORACLE VALIDA
	* PAULO DEVIDE - 30-06-2016	
	* ALTERA√á√ÉO JIRA - LC-342 (BLOQUEIO DE PEDIDOS PARA FORNECEDOR - CAMPO FORNECEDORES.ERP_BLOQUEIO_AUDITORIA BIT)
	objTelaPai.LX_FORM1.LX_pageframe1.Page1.TV_condicao_pgto.p_valida_where = " AND EBS_ID_COND_PAGAMENTO IS NOT NULL "
	objTelaPai.LX_FORM1.TV_FORNECEDOR.p_valida_where = " AND (EBS_ID_FORNECEDOR IS NOT NULL)  AND (ISNULL(ERP_BLOQUEIO_AUDITORIA,0) = 0) "
	***********************************************************************************************************************	

	TRY 
		ADDPROPERTY(objTelaPai,"PEDIDO_ORIGINAL_COPIA","")		
		ADDPROPERTY(objTelaPai,"QUANTIDADE_TOTAL_ORIGINAL")	
		ADDPROPERTY(objTelaPai,"EXCLUIU_ITENS")	 && Paulo Devide --> 29/11/2017
	CATCH TO err1
		WAIT WINDOW NOWAIT err1.message
	FINALLY
		objTelaPai.PEDIDO_ORIGINAL_COPIA = ""
		objTelaPai.QUANTIDADE_TOTAL_ORIGINAL = v_Compras_01.TOT_QTDE_ORIGINAL
		objTelaPai.EXCLUIU_ITENS = .F. && verifica se excluiu item para extornar a quantidade empenhada de Saldo de OTB
		WAIT clear
	ENDTRY

	** Carrega VCX para mem√≥ria	
	IF "CUPS01" $ SET( "ClassLib" )
		** Ok, Registry carregado
	ELSE
		SET CLASSLIB TO CUPS01.vcx ADDITIVE
	ENDIF

	** CLASSE DE COMPONENTES - PAULO DEVIDE
	IF "CONTROLES" $ SET( "ClassLib" )
		** Ok, Registry carregado
	ELSE
		SET CLASSLIB TO CONTROLES.vcx ADDITIVE
	ENDIF

	*** CURSOR PARA ARMAZENAR O NUMERO DO PEDIDO DE ORIGEM PARA FUN√á√ÉO COPIA
	CREATE CURSOR VTMP_PEDIDO_COPIA (;
		PEDIDO_ORIGEM C(8) NULL )
	INSERT INTO VTMP_PEDIDO_COPIA VALUES ("")
	SELECT VTMP_PEDIDO_COPIA
	GO TOP	

	Create Cursor ;
		xUserSenha(usuario Varchar(25), motivo Varchar(25))
		
	CREATE CURSOR vCboPack (CODIGO_PACK C(1) NULL)
	
	***
	* TABELA DE METRICAS DO M√ìDULO DE COMPRAS
	*/	
	TEXT TO lcSQL NOSHOW TEXTMERGE PRETEXT 7
		SELECT 
			COD_METRICA, DESC_METRICA, TIPO_DADO 
		FROM 
			CAEDU_METRICAS_LOG_COMPRAS 
		ORDER BY 
			COD_METRICA
	ENDTEXT
	F_SELECT(lcSQL, "vLOG_METRICAS")

	***
	* CRIA O CURSOR V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM
	* PARA ARMAZENAR OS AVISOS DE METRICAS DO CABE√áALHO
	*/
	TEXT TO lcSQL NOSHOW TEXTMERGE PRETEXT 7
		select * 
		from CAEDU_LOG_AUTORIZA_COMPRAS 
		WHERE 1=0
	ENDTEXT
	F_SELECT(lcSQL, "vtmpLogPedido")
	=AFIELDS(laFields1, "vtmpLogPedido")
	
	CREATE CURSOR V_CAEDU_LOG_AUTORIZA_COMPRAS ;
	FROM ARRAY laFields1
	
	***
	* CRIA O CURSOR V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM
	* PARA ARMAZENAR OS AVISOS DE METRICAS DE ITENS
	*/
	TEXT TO lcSQL NOSHOW TEXTMERGE PRETEXT 7
		select * 
		from CAEDU_LOG_AUTORIZA_COMPRAS_ITEM 
		WHERE 1=0
	ENDTEXT
	F_SELECT(lcSQL, "vtmpLogPedidoItem")
	=AFIELDS(laFields2, "vtmpLogPedidoItem")
	
	CREATE CURSOR V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM ;
	FROM ARRAY laFields2
	
	USE IN vtmpLogPedidoItem
	USE IN vtmpLogPedido
	
		

	objTelaPai.LX_FORM1.LX_pageframe1.PAGE5.TX_pedido_original.controlsource = "VTMP_PEDIDO_COPIA.pedido_origem"
	
	desabilita_toolbar_filha()


	RETURN .T.
ENDFUNC

FUNCTION habilita_page_cabilog
LPARAMETERS objTelaPai
		** Se for e-commerce desabilita a aba cabilog
		TRY 
			IF (ALLTRIM(UPPER(V_COMPRAS_01.TIPO_COMPRA)) = "E-COMMERCE")
				objTelaPai.lx_form1.lx_pageframe1.pgCabilog.enabled = .f.
				WAIT WINDOW NOWAIT "Desabilitando Aba Cabilog..."
			ELSE
				objTelaPai.lx_form1.lx_pageframe1.pgCabilog.enabled = .t.
				WAIT WINDOW NOWAIT "Habilitando Aba Cabilog..."
			ENDIF
				
		CATCH TO ex

			WAIT WINDOW NOWAIT 'carregando...'
		ENDTRY
ENDFUNC

PROCEDURE COPIAR_PEDIDO_EXT
	LPARAMETERS objTelaPai

	lnArea = SELECT()
	
	**cPedido = ALLTRIM(objTelaPai.LX_FORM1.LX_pageframe1.PAGE5.TX_pedido_original.Value)
	cPedido = objTelaPai.PEDIDO_ORIGINAL_COPIA &&  PEGA da propriedade, 
												&& pois o metodo do Linx limpa a variavel 
	
	TEXT TO lcSQL NOSHOW TEXTMERGE PRETEXT 7
		SELECT 
		    PEDIDO
		    ,RATEIO_CENTRO_CUSTO
		    ,RATEIO_FILIAL
		    ,NATUREZA_ENTRADA
		    ,CAEDU_DATA_OTB
		    ,ERP_CONFERENCIA_PACKS
		    ,ERP_CUPS_TIPO_PEDIDO
		    ,ERP_CUPS_SEGMENTO
		    ,ERP_CUPS_DATA_ACORDADA
		    ,ERP_CUPS_PECA_MOSTRUARIO
		    ,ERP_CUPS_EMBARQUE_ATUAL
		    ,ERP_CUPS_EMBARQUE_REAL
		    ,ERP_CUPS_CONTRATO
		    ,ERP_CUPS_CHEGADA_PORTO
		    ,ERP_CUPS_CHEGADA_CD
		    ,ERP_CUPS_PROCESSO_CCF_CCA
		    ,ERP_CUPS_EMBARQUE_LIBERADO
		    ,ERP_CUPS_INCOTERM
		    ,ERP_CUPS_ID_CONTRATO
		    ,ERP_PERCENT_VERBAS
		    ,ERP_IMPORTADO
		    ,ERP_MOEDA
		    ,ERP_TOTAL_QTD_DISTRIB
		    ,ERP_PERCENT_DISTRIB
		    ,ERP_TOTAL_CAIXAS_ORIGINAL
		    ,CTB_TIPO_OPERACAO
		    ,DESC_TIPO_OPERACAO
		FROM COMPRAS
		WHERE PEDIDO = '<<cPedido>>'
	ENDTEXT

	F_SELECT(lcSQL,"tmpCompras02")
	SELECT tmpCompras02
	GO TOP
	WAIT WINDOW tmpCompras02.PEDIDO
		
	Select v_Compras_01
	** INICIO: PAULO DEVIDE - 30-JUL-14 **
	** INCLUS√ÉO DOS CAMPOS:
	** NATUREZA_ENTRADA
	** RATEIO_FILIAL
	** RATEIO_CENTRO_CUSTO

	REPLACE v_Compras_01.RATEIO_CENTRO_CUSTO WITH tmpCompras02.RATEIO_CENTRO_CUSTO
	REPLACE v_Compras_01.RATEIO_FILIAL WITH tmpCompras02.RATEIO_FILIAL
	REPLACE v_Compras_01.NATUREZA_ENTRADA WITH tmpCompras02.NATUREZA_ENTRADA
	REPLACE v_Compras_01.CAEDU_DATA_OTB WITH tmpCompras02.CAEDU_DATA_OTB
	REPLACE v_Compras_01.ERP_CUPS_TIPO_PEDIDO WITH tmpCompras02.ERP_CUPS_TIPO_PEDIDO
	REPLACE v_Compras_01.ERP_CUPS_SEGMENTO WITH tmpCompras02.ERP_CUPS_SEGMENTO
	REPLACE v_Compras_01.ERP_CUPS_DATA_ACORDADA WITH tmpCompras02.ERP_CUPS_DATA_ACORDADA
	REPLACE v_Compras_01.ERP_CUPS_PECA_MOSTRUARIO WITH tmpCompras02.ERP_CUPS_PECA_MOSTRUARIO
	REPLACE v_Compras_01.ERP_CUPS_EMBARQUE_ATUAL WITH tmpCompras02.ERP_CUPS_EMBARQUE_ATUAL
	REPLACE v_Compras_01.ERP_CUPS_EMBARQUE_REAL WITH tmpCompras02.ERP_CUPS_EMBARQUE_REAL
	REPLACE v_Compras_01.ERP_CUPS_CONTRATO WITH tmpCompras02.ERP_CUPS_CONTRATO
	REPLACE v_Compras_01.ERP_CUPS_CHEGADA_PORTO WITH tmpCompras02.ERP_CUPS_CHEGADA_PORTO
	REPLACE v_Compras_01.ERP_CUPS_CHEGADA_CD WITH tmpCompras02.ERP_CUPS_CHEGADA_CD
	REPLACE v_Compras_01.ERP_CUPS_PROCESSO_CCF_CCA WITH tmpCompras02.ERP_CUPS_PROCESSO_CCF_CCA
	REPLACE v_Compras_01.ERP_CUPS_EMBARQUE_LIBERADO WITH tmpCompras02.ERP_CUPS_EMBARQUE_LIBERADO
	REPLACE v_Compras_01.ERP_CUPS_INCOTERM WITH tmpCompras02.ERP_CUPS_INCOTERM
	REPLACE v_Compras_01.ERP_CUPS_ID_CONTRATO WITH tmpCompras02.ERP_CUPS_ID_CONTRATO
	REPLACE v_Compras_01.ERP_PERCENT_VERBAS WITH tmpCompras02.ERP_PERCENT_VERBAS
	REPLACE v_Compras_01.ERP_IMPORTADO WITH tmpCompras02.ERP_IMPORTADO
	REPLACE v_Compras_01.ERP_MOEDA WITH tmpCompras02.ERP_MOEDA
	REPLACE v_Compras_01.ERP_TOTAL_QTD_DISTRIB WITH tmpCompras02.ERP_TOTAL_QTD_DISTRIB
	REPLACE v_Compras_01.ERP_PERCENT_DISTRIB WITH tmpCompras02.ERP_PERCENT_DISTRIB
	REPLACE v_Compras_01.ERP_TOTAL_CAIXAS_ORIGINAL WITH tmpCompras02.ERP_TOTAL_CAIXAS_ORIGINAL
	REPLACE v_Compras_01.CTB_TIPO_OPERACAO WITH tmpCompras02.CTB_TIPO_OPERACAO
	REPLACE v_Compras_01.DESC_TIPO_OPERACAO WITH tmpCompras02.DESC_TIPO_OPERACAO
	** FINAL: PAULO DEVIDE - 30-JUL-14 **


	*** DUPLICA PROPRIEDADES
	lcPedido = cPedido

	TEXT TO lcSQL NOSHOW TEXTMERGE
		select * 
		from prop_compras 
		where pedido=?lcPedido
	ENDTEXT

	f_select(lcSQL,"tmpProp_compras1")

	IF USED("tmpProp_compras1")
		SELECT tmpProp_compras1
		SCAN 	
			SELECT curpropcompras
			LOCATE FOR propriedade = tmpProp_compras1.propriedade
			IF FOUND()
				replace valor_propriedade WITH tmpProp_compras1.valor_propriedade
			ENDIF
			SELECT tmpProp_compras1	
		ENDSCAN
	ENDIF


	SELECT (lnArea)

	**** DUPLICA PACKS

	TEXT TO lcSQL NOSHOW TEXTMERGE
		SELECT * 
		FROM CAEDU_COMPRAS_PRODUTOS_PACKS 
		WHERE PEDIDO = ?lcPedido
	ENDTEXT

	f_select(lcSQL,"tmpCAEDU_COMPRAS_PRODUTOS_PACKS")

	TEXT TO lcSQL NOSHOW TEXTMERGE
		SELECT * 
		FROM CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL 
		WHERE PEDIDO = ?lcPedido
	ENDTEXT

	f_select(lcSQL,"tmpCAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL")

	IF USED("tmpCAEDU_COMPRAS_PRODUTOS_PACKS") AND USED("tmpCAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL")

		LOCAL ii as Integer
		SELECT tmpCAEDU_COMPRAS_PRODUTOS_PACKS
		FOR ii=1 TO 48
			SCAN
				lcCampo="tmpCAEDU_COMPRAS_PRODUTOS_PACKS.Q"+ALLTRIM(TRANSFORM(ii,"99"))
				replace &lcCampo. WITH NVL(&lcCampo.,0)	
			ENDSCAN
		ENDFOR

		SELECT tmpCAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL
		FOR ii=1 TO 48
			SCAN
				lcCampo="tmpCAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q"+ALLTRIM(TRANSFORM(ii,"99"))
				replace &lcCampo. WITH NVL(&lcCampo.,0)	
			ENDSCAN
		ENDFOR

		**thisformset.lx_form1.lx_pageframe1.ActivePage=21
		
		SELECT tmpCAEDU_COMPRAS_PRODUTOS_PACKS
		SCAN 	
			
			SCATTER MEMVAR 
			
			SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS
			APPEND BLANK
			GATHER memvar

			**WITH ThisFormset.Lx_form1.Lx_pageframe1.Page21.Lx_grid_filha1
			**	.afterrowcolchange()
			**	.Refresh
			**ENDWITH
					
			SELECT tmpCAEDU_COMPRAS_PRODUTOS_PACKS
			
		ENDSCAN

		SELECT tmpCAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL
		SCAN 	
			
			SCATTER MEMVAR 
			
			SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL
			APPEND BLANK
			GATHER memvar

			**WITH ThisFormset.Lx_form1.Lx_pageframe1.Page21.Lx_grid_filha2
			**	.afterrowcolchange()
			**	.Refresh
			**ENDWITH
			
			SELECT tmpCAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL

		ENDSCAN

		
	ENDIF


	
	SELECT (lnArea)
	RETURN
	
ENDPROC


PROCEDURE LIMPA_LOG_AUTORIZACAO
	LOCAL lnArea
	
	lnArea = SELECT()
	TRY 
		SET SAFETY off
		IF USED("V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM")
			SELECT V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM			
			ZAP
		ENDIF
		
		IF USED("V_CAEDU_LOG_AUTORIZA_COMPRAS")		
			SELECT V_CAEDU_LOG_AUTORIZA_COMPRAS
			ZAP
		ENDIF
	CATCH TO oErro
		MESSAGEBOX(oErro.Message, 16, "Aviso")

	ENDTRY
	
	SELECT (lnArea)
ENDPROC

FUNCTION GRAVA_LOG_AUTORIZACAO
	llRet = .t.
	TRY 
	
		SELECT V_CAEDU_LOG_AUTORIZA_COMPRAS 
		SCAN 		
	
			F_SELECT("SELECT * FROM dbo.CAEDU_LOG_AUTORIZA_COMPRAS "+;
						"WHERE PEDIDO=?v_compras_01.PEDIDO AND PRODUTO=?V_CAEDU_LOG_AUTORIZA_COMPRAS.PRODUTO","VTMPLOG1")

			llExiste = .t.

			IF RECCOUNT("VTMPLOG1")=0
				llExiste = .f.
			ENDIF

			IF llExiste
				lcSQL = "UPDATE dbo.CAEDU_LOG_AUTORIZA_COMPRAS SET "
				lcSQL = lcSQL + " STATUS_PEDIDO = 3 " && AGUARDANDO APROVA√á√ÉO
				lcSQL = lcSQL + " WHERE PEDIDO = '"+ALLTRIM(v_compras_01.PEDIDO)+"' AND "
				lcSQL = lcSQL + " PRODUTO = '"+ALLTRIM(V_CAEDU_LOG_AUTORIZA_COMPRAS.PRODUTO)+"'" 
			ELSE
				lcSQL = "INSERT INTO dbo.CAEDU_LOG_AUTORIZA_COMPRAS "
				lcSQL = lcSQL + " (PEDIDO,PRODUTO,DATA_LOG,STATUS_PEDIDO) "
				lcSQL = lcSQL + " VALUES ('"+ALLTRIM(v_compras_01.PEDIDO)+"','"+ALLTRIM(V_CAEDU_LOG_AUTORIZA_COMPRAS.PRODUTO)+"','"
				lcSQL = lcSQL + DTOS(DATE())+"', 3)"
			ENDIF
			
			F_EXECUTE(lcSQL)
									
			SELECT V_CAEDU_LOG_AUTORIZA_COMPRAS 

		ENDSCAN

		SELECT V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM
		SCAN
			TEXT TO lcSQL NOSHOW TEXTMERGE PRETEXT 7
				INSERT INTO dbo.CAEDU_LOG_AUTORIZA_COMPRAS_ITEM
				(PEDIDO,PRODUTO,COR_PRODUTO,COD_METRICA,DATA_LOG,TIPO_OP,
				VALOR_ANTES,VALOR_DEPOIS,APROVADO,USUARIO_PEDIDO,USUARIO_APROVADOR,OBS)
				VALUES (
				?V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM.PEDIDO,
				?V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM.PRODUTO,
				?V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM.COR_PRODUTO,
				?V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM.COD_METRICA,
				?V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM.DATA_LOG,
				?V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM.TIPO_OP,
				?V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM.VALOR_ANTES,
				?V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM.VALOR_DEPOIS,
				?V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM.APROVADO,
				?V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM.USUARIO_PEDIDO,
				?V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM.USUARIO_APROVADOR,
				?V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM.OBS)
			ENDTEXT
			F_INSERT(lcSQL)
			
			SELECT V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM
		ENDSCAN

	CATCH TO oErro
		MESSAGEBOX(oErro.message,16, "Aviso")
		llRet = .f.

	ENDTRY
	RETURN llRet
	
ENDFUNC

***
* 
*/
PROCEDURE desabilita_toolbar_filha
	PARAMETERS objTelaPai
	TRY 
		o_toolbar.Botao_filhas_inserir.Enabled= .F.
		o_toolbar.botao_filhas_deletar.Enabled= .f.
		
	CATCH TO oErro
		MESSAGEBOX(oErro.message, 16, "Aviso")

	ENDTRY

ENDPROC


****
* PAULO DEVIDE
* ADICIONA OBJETOS NA TELA DE COMPRAS
* CRIADO EM: 18/08/2016
*/
FUNCTION ADICIONA_CONTROLES
	LPARAMETERS objTelaPai, xmetodo, xobjeto, xnome_obj


	** Label para trazer a data original do pedido quando for uma copia de pedido
	objTelaPai.lx_form1.lx_pageframe1.page1.AddObject("lblCopiarData","lblCopiarData")
	objTelaPai.lx_form1.lx_pageframe1.page1.lblCopiarData.visible = .t.
	
	objTelaPai.lx_form1.lx_pageframe1.page1.Addobject("cmbRequeridoPor","cmbRequeridoPor")
	objTelaPai.lx_form1.lx_pageframe1.page1.cmbRequeridoPor.visible = .t.
		
	objTelaPai.lx_form1.lx_pageframe1.Page4.addobject("btnCorrigeCusto","btnCorrigeCusto")
	objTelaPai.lx_form1.lx_pageframe1.Page4.btnCorrigeCusto.visible = .t.
	
	objTelaPai.lx_form1.AddObject("botaoecom","botaoecom")
	objTelaPai.lx_form1.botaoecom.visible = .t.
	

	** Adiciona Page da Cabilog
	lnLastPage = objTelaPai.lx_form1.lx_pageframe1.pagecount + 1
	lcLastPage = "pgCabilog"
	objTelaPai.lx_form1.lx_pageframe1.addobject(lcLastPage,"cPageCabilog") && classe cPageCabilog - definida neste objeto de entrada
	WITH objTelaPai.lx_form1.lx_pageframe1.pgCabilog
		.enabled=.t.
		lnPageIndex = .pageorder
	ENDWITH

	** Adiciona Page de Avisos/Erros
	lnLastPage = objTelaPai.lx_form1.lx_pageframe1.pagecount + 1
	lcLastPage = "pgWarning"
	objTelaPai.lx_form1.lx_pageframe1.addobject(lcLastPage,"cPageWarning") && classe cPageCabilog - definida neste objeto de entrada
	WITH objTelaPai.lx_form1.lx_pageframe1.pgWarning
		.enabled=.t.
		lnPageIndex = .pageorder
	ENDWITH

	** Adiciona Page de PACK
	lnLastPage = objTelaPai.lx_form1.lx_pageframe1.pagecount + 1
	lcLastPage = "pgPack"
	objTelaPai.lx_form1.lx_pageframe1.addobject(lcLastPage,"cPagePack") && classe cPagePack - definida neste objeto de entrada
	WITH objTelaPai.lx_form1.lx_pageframe1.pgPack
		.enabled=.t.
		lnPageIndex = .pageorder
	ENDWITH

	
	** Adiciona Page de Importado (Atacado)
	lnLastPage = objTelaPai.lx_form1.lx_pageframe1.pagecount + 1
	lcLastPage = "pgAtacado"
	objTelaPai.lx_form1.lx_pageframe1.addobject(lcLastPage,"cPageAtacado") && classe cPageAtacado - definida neste objeto de entrada
	WITH objTelaPai.lx_form1.lx_pageframe1.pgAtacado
		.enabled=.t.
		lnPageIndex = .pageorder
	ENDWITH
	objTelaPai.lx_form1.lx_pageframe1.Activepage = lnPageIndex
	
	*** Adiciona objetos na page 'Atacado'
	WITH objTelaPai.lx_form1.lx_pageframe1.pgAtacado

		.addobject('chk_mostruario1', 'chk_mostruario')
		WITH .chk_mostruario1
			.top = 20
			.left = 290
			.visible = .t.
			.controlsource = "v_compras_01.ERP_CUPS_PECA_MOSTRUARIO"
		ENDWITH

		.addobject('chk_embarque_liberado1', 'chk_embarque_liberado')
		WITH .chk_embarque_liberado1
			.top = 170
			.left = 25
			.visible = .t.
			.controlsource = "v_compras_01.ERP_CUPS_EMBARQUE_LIBERADO"
		ENDWITH

		.addobject('lbl_data_acordada', 'rotulo')
		.addobject('txt_data_acordada1', 'txt_data_acordada')
		WITH .txt_data_acordada1
			.top = 20
			.left = 117
			.controlsource = "v_compras_01.ERP_CUPS_DATA_ACORDADA"
			.visible = .t.
			.parent.lbl_data_acordada.caption = "Data Acordada"
			.parent.lbl_data_acordada.top = 23
			.parent.lbl_data_acordada.left = 25
			.parent.lbl_data_acordada.visible = .t.
		ENDWITH

		.addobject('lbl_embarque_atual', 'rotulo')
		.addobject('txt_embarque_atual1', 'txt_embarque_atual')
		WITH .txt_embarque_atual1
			.top = 50
			.left = 117
			.controlsource = "v_compras_01.ERP_CUPS_EMBARQUE_ATUAL"
			.visible = .t.
			.parent.lbl_embarque_atual.caption = "Embarque Atual"
			.parent.lbl_embarque_atual.top = 53
			.parent.lbl_embarque_atual.left = 25
			.parent.lbl_embarque_atual.visible = .t.
		ENDWITH

		.addobject('lbl_moeda', 'rotulo')
		.addobject('cbo_moeda1', 'cbo_moeda')
		WITH .cbo_moeda1
			.controlsource = "v_compras_01.ERP_MOEDA"
			.visible = .t.
			.parent.lbl_moeda.caption = "Moeda"
			.parent.lbl_moeda.top = 83
			.parent.lbl_moeda.left = 290
			.parent.lbl_moeda.visible = .t.
		ENDWITH


		.addobject('lbl_embarque_real', 'rotulo')
		.addobject('txt_embarque_real1', 'txt_embarque_real')
		WITH .txt_embarque_real1
			.top = 80
			.left = 117
			.controlsource = "v_compras_01.ERP_CUPS_EMBARQUE_REAL"
			.visible = .t.
			.parent.lbl_embarque_real.caption = "Embarque Real"
			.parent.lbl_embarque_real.top = 83
			.parent.lbl_embarque_real.left = 25
			.parent.lbl_embarque_real.visible = .t.
		ENDWITH

		.addobject('lbl_contrato', 'rotulo')

		.addobject('tv_contrato1', "tv_contrato")
		WITH .tv_contrato1
			.controlsource = "v_compras_01.ERP_CUPS_ID_CONTRATO"
			*.Height = 21
			.Left = 340
			.Top = 110
			*.Width = 120
			.Name = "tv_contrato1"
			.descricao = "NUM_CONTRATO"
			.lista_campos = "NUM_CONTRATO,ID_CONTRATO"
			.tabela_valida="CAEDU_CUPS_CONTRATOS"
			.ImgPesquisa.Stretch = 2
			.ImgPesquisa.picture = LOCFILE("lupa.gif","GIF","Localizar")
			
			.visible = .t.
			.parent.lbl_contrato.caption = "Contrato"
			.parent.lbl_contrato.top = 113
			.parent.lbl_contrato.left = 290
			.parent.lbl_contrato.visible = .t.
		ENDWITH	
						
		.addobject('lbl_data_chegada_porto', 'rotulo')
		.addobject('txt_data_chegada_porto1', 'txt_data_chegada_porto')
		WITH .txt_data_chegada_porto1
			.top = 110
			.left = 117
			.controlsource = "v_compras_01.ERP_CUPS_CHEGADA_PORTO"
			.visible = .t.
			.parent.lbl_data_chegada_porto.caption = "Chegada Porto"
			.parent.lbl_data_chegada_porto.top = 113
			.parent.lbl_data_chegada_porto.left = 25
			.parent.lbl_data_chegada_porto.visible = .t.
		ENDWITH
		
		.addobject('lbl_data_chegada_cd', 'rotulo')
		.addobject('txt_data_chegada_cd1', 'txt_data_chegada_cd')
		WITH .txt_data_chegada_cd1
			.top = 140
			.left = 117
			.controlsource = "v_compras_01.ERP_CUPS_CHEGADA_CD"
			.visible = .t.
			.parent.lbl_data_chegada_cd.caption = "Chegada CD"
			.parent.lbl_data_chegada_cd.top = 143
			.parent.lbl_data_chegada_cd.left = 25
			.parent.lbl_data_chegada_cd.visible = .t.
		ENDWITH

		.addobject('lbl_processo_ccf', 'rotulo')
		.addobject('txt_processo_ccf1', 'txt_processo_ccf')
		WITH .txt_processo_ccf1
			.top = 140
			.left = 340
			.controlsource = "v_compras_01.ERP_CUPS_PROCESSO_CCF_CCA"
			.visible = .t.
			.parent.lbl_processo_ccf.caption = "Processo/CCF"
			.parent.lbl_processo_ccf.top = 143
			.parent.lbl_processo_ccf.left = 256
			.parent.lbl_processo_ccf.visible = .t.
			.p_valida=.F. && 20-07-15 --> N√£o √© mais obrigat√≥rio
		ENDWITH
		
		.addobject('lbl_incoterm', 'rotulo')
		.addobject('cbo_incoterm1', 'cbo_incoterm')
		WITH .cbo_incoterm1
			.top = 170
			.left = 340
			.controlsource = "v_compras_01.ERP_CUPS_INCOTERM"
			.visible = .t.
			.parent.lbl_incoterm.caption = "Incoterm"
			.parent.lbl_incoterm.top = 173
			.parent.lbl_incoterm.left = 283
			.parent.lbl_incoterm.visible = .t.
		ENDWITH						
					
	ENDWITH
	
	WITH objTelaPai.lx_form1.lx_pageframe1.Page1

	
		.addobject("lblTotPercentDistrib1","lblTotPercentDistrib")
		.lblTotPercentDistrib1.visible=.t.
		
		.addobject("lblTotQtdDistrib1","lblTotQtdDistrib")
		.lblTotQtdDistrib1.visible=.t.

		.addobject("txtTotQtdDistrib1","txtTotQtdDistrib")
		.txtTotQtdDistrib1.visible=.t.

		.addobject("txtTotPercentDistrib1","txtTotPercentDistrib")
		.txtTotPercentDistrib1.visible=.t.
	
		.addobject("ck_importado1","ck_importado")
		.ck_importado1.visible=.t.
		
		.addobject("ck_distribuicao","ck_distribuicao")
		.ck_distribuicao.visible=.t.
		
		.addobject("ck_manual","ck_manual")
		.ck_manual.visible=.t.
		
		.addobject("ck_liberado_cq","ck_liberado_cq")
		.ck_liberado_cq.visible=.t.
		
		.addobject("ck_faturado","ck_faturado")
		.ck_faturado.visible=.t.
			
		.addobject('CBO_tipo_pedido1','CBO_tipo_pedido')
		.CBO_tipo_pedido1.Left = 425
		.CBO_tipo_pedido1.Top = 376
		.CBO_tipo_pedido1.controlsource = "v_compras_01.ERP_CUPS_TIPO_PEDIDO"
		.CBO_tipo_pedido1.Visible = .T.

		.addobject('label_tipo_pedido','rotulo')
		.label_tipo_pedido.Left = 393
		.label_tipo_pedido.Top = 379
		
		.label_tipo_pedido.Caption = "Tipo"
		.label_tipo_pedido.autosize = .T.
		.label_tipo_pedido.Visible = .T.

		.addobject('label_segmento_pedido','rotulo')
		.label_segmento_pedido.Left = 608
		.label_segmento_pedido.Top = 379
		
		.label_segmento_pedido.Caption = "Segmento"
		
		.label_segmento_pedido.autosize = .T.
		.label_segmento_pedido.Visible = .T.		
		
		.addobject('CBO_segmento_pedido1','CBO_segmento_pedido')
		.CBO_segmento_pedido1.Left = 673
		.CBO_segmento_pedido1.Top = 376
		.CBO_segmento_pedido1.controlsource = "v_compras_01.ERP_CUPS_SEGMENTO"
		.CBO_segmento_pedido1.Visible = .T.
										
	ENDWITH

	FOR EACH loPg IN objTelaPai.lx_form1.lx_pageframe1.pages
		**** 
		* paulo devide -> 30-07-2015 **
		*/
		IF UPPER(ALLTRIM(loPg.Caption)) = "\<ITENS"
			WITH loPg
				.addobject("txt_custo_fob1","txt_custo_fob")
				.txt_custo_fob1.top = 374
				.txt_custo_fob1.left = 97
				.txt_custo_fob1.visible=.t.
				.txt_custo_fob1.controlsource = "V_COMPRAS_01_PRODUTOS.ERP_CUPS_CUSTO_FOB"
				.addobject("lbl_custo_fob1","rotulo")
				.lbl_custo_fob1.caption = "Custo Fob"
				.lbl_custo_fob1.left = .txt_custo_fob1.left - 75
				.lbl_custo_fob1.top = .txt_custo_fob1.top + 3
				.lbl_custo_fob1.visible = .t.
				
				.addobject("txt_qtd_caixas1","txt_qtd_caixas")
				.txt_qtd_caixas1.top = 374
				.txt_qtd_caixas1.left = 481
				.txt_qtd_caixas1.visible=.t.
				.txt_qtd_caixas1.controlsource = "V_COMPRAS_01_PRODUTOS.ERP_CUPS_PACKS_POR_CAIXA"
				.addobject("lbl_qtd_caixas1","rotulo")
				.lbl_qtd_caixas1.caption = "PACK p/CX."
				.lbl_qtd_caixas1.left = .txt_qtd_caixas1.left - 70
				.lbl_qtd_caixas1.top = .txt_qtd_caixas1.top + 3
				.lbl_qtd_caixas1.visible = .t.
				
				.addobject("txt_custo_fob_minimo1","txt_custo_fob")
				.txt_custo_fob_minimo1.top = 404
				.txt_custo_fob_minimo1.left = 97
				.txt_custo_fob_minimo1.visible=.t.
				.txt_custo_fob_minimo1.controlsource = "V_COMPRAS_01_PRODUTOS.ERP_CUPS_CUSTO_FOB_MINIMO"
				.addobject("lbl_custo_fob_minino1","rotulo")
				.lbl_custo_fob_minino1.caption = "Fob Minimo"
				.lbl_custo_fob_minino1.left = .txt_custo_fob_minimo1.left - 75
				.lbl_custo_fob_minino1.top =  .txt_custo_fob_minimo1.top + 3
				.lbl_custo_fob_minino1.visible = .t.
				
				
				.addobject("cmdAtualizar1","cmdAtualizar")
				.cmdAtualizar1.visible = .t.

				***
				* Bot√£o Adicionar Produtos
				*/
				.addobject("cmdAddProduto1","cmdAddProduto",objTelaPai)
				.cmdAddProduto1.visible = .t.

				***
				* Bot√£o Excluir Produtos
				*/
				.addobject("cmdDelProduto1","cmdDelProduto",objTelaPai)
				.cmdDelProduto1.visible = .t.

								
				***
				* Adiciona um shape invisivel para n√£o deixar o usu√°rio editar o
				* pack dos itens do pedido 
				*/
				.AddObject("shape11","shape")
				WITH .shape11
					.Top = 32
					.left = 7
					.visible = .t.
					.height = 117   && altura
					.Width = 820    && largura
					.BackStyle= 0   && transparente
					.BorderStyle= 0 && borda invisivel
				ENDWITH
				
				.AddObject("chkPackResto1","chkPackResto")
				WITH .chkPackResto1
					.visible = .t.
				ENDWITH

				.AddObject("chkE_Conjunto1","chkE_Conjunto")
				WITH .chkE_Conjunto1
					.visible = .t.
				ENDWITH

				.AddObject("lblCor21","lblCor2")
				WITH .lblCor21
					.visible = .t.
				ENDWITH

				.AddObject("cboCor21","cboCor2")
				WITH .cboCor21
					.visible = .t.
				ENDWITH
				
			ENDWITH
		
		ENDIF
	
	ENDFOR
	
	***
	* Bot√£o de Pedido em Ingl√™s --> 21-05-2013
	*/
	objTelaPai.lx_form1.addobject('bt_pedido1', 'bt_pedido')
	WITH objTelaPai.lx_form1.bt_pedido1
		.height = 27
		.fontname = 'Arial'
		.Caption = 'Pedido'
		.Left = 644
		.Top = 31
		.Width = 50
		.Visible = .T.
		.Enabled = .T.
		.anchor = 0
		.forecolor = rgb(255,255,255)
		.p_manter_baixo = .f.
		.p_manter_cima = .f.
		.p_manter_direita = .f.
		.p_manter_esquerda = .f.
		.p_muda_size = .f.

	ENDWITH
	
	*** Inclui Campo Data OTB
	objTelaPai.lx_form1.lx_pageframe1.Page1.addobject('sh_OTB1', 'sh_OTB')
	WITH objTelaPai.lx_form1.lx_pageframe1.Page1.sh_OTB1
		.visible = .F.
	ENDWITH

	objTelaPai.lx_form1.lx_pageframe1.Page1.addobject('lb_data_otb1', 'lb_data_otb')
	WITH objTelaPai.lx_form1.lx_pageframe1.Page1.lb_data_otb1
		.visible = .t.
		.top = 382
		.Left = 204
	ENDWITH

	objTelaPai.lx_form1.lx_pageframe1.Page1.addobject('tx_data_otb1', 'tx_data_otb')
	WITH objTelaPai.lx_form1.lx_pageframe1.Page1.tx_data_otb1
		.visible = .t.
		.top = 382
		.left = 280
		.ControlSource = 'V_COMPRAS_01.CAEDU_DATA_OTB'
	ENDWITH

	**lb_mes_lojas - JIRA SI-12
	objTelaPai.lx_form1.lx_pageframe1.Page1.addobject('lb_mes_lojas1', 'lb_mes_lojas')
	WITH objTelaPai.lx_form1.lx_pageframe1.Page1.lb_mes_lojas1
		.visible = .t.
		.top = 412
		.Left = 204
	ENDWITH

	objTelaPai.lx_form1.lx_pageframe1.Page1.addobject('cb_mes_lojas1', 'cb_mes_lojas')
	WITH objTelaPai.lx_form1.lx_pageframe1.Page1.cb_mes_lojas1
		.visible = .t.
		.top = 412
		.left = 280
		.ControlSource = 'V_COMPRAS_01.ERP_MES_NA_LOJA'
	ENDWITH
	** FIM JIRA SI-12
	
	objTelaPai.lx_form1.lx_pageframe1.Page1.addobject('btn_Recalcula1', 'btn_Recalcula')
	WITH objTelaPai.lx_form1.lx_pageframe1.Page1.btn_Recalcula1
		.visible = .t.
	ENDWITH
	
	*************************************************************


	objTelaPai.lx_form1.lx_pageframe1.Page5.addobject('bt_obs_pack1', 'bt_obs_pack')
	WITH objTelaPai.lx_form1.lx_pageframe1.Page5.bt_obs_pack1
		.visible = .t.
	ENDWITH

	
	** PAULO DEVIDE - 09-SET-14 (INICIO) --> Pageframe Cabilog
	TRY

		lcPage = ALLTRIM(TRANSFORM(objTelaPai.lx_form1.lx_pageframe1.pagecount,"99"))

		FOR EACH loPg IN objTelaPai.lx_form1.lx_pageframe1.pages
			IF "cabilog" $ LOWER(loPg.caption)

				**loPg.caption = "Cabilog"
				lcPgName = LOWER(ALLTRIM(loPg.name))

				*** Adiciona os objetos na page da Cabilog
				*** COMENTADO EM 16-10-2017
				*>* loPg.addobject("ck_cab_encabidado1","ck_cab_encabidado")
				*>* loPg.ck_cab_encabidado1.visible=.t.
				*** SUBSTITUIDO POR:
				loPg.addobject("optCabilog1","optCabilog")
				loPg.optCabilog1.visible=.t.
 
				loPg.addobject("lb_cod_cabide1","lb_cod_cabide")
				loPg.lb_cod_cabide1.visible=.t.

				loPg.addobject("cb_cod_cabide1","cb_cod_cabide")
				loPg.cb_cod_cabide1.visible=.t.

				loPg.addobject("lb_cab_cd_entrega1","lb_cab_cd_entrega")
				loPg.lb_cab_cd_entrega1.visible=.t.

				loPg.addobject("tx_cab_cd_entrega1","tx_cab_cd_entrega")
				loPg.tx_cab_cd_entrega1.visible=.t.

				loPg.addobject("lb_cab_status1","lb_cab_status")
				loPg.lb_cab_status1.visible=.t.

				loPg.addobject("tx_cab_status1","tx_cab_status")
				loPg.tx_cab_status1.visible=.t.

				loPg.addobject("lb_cab_localizacao1","lb_cab_localizacao")
				loPg.lb_cab_localizacao1.visible=.t.

				loPg.addobject("cb_cab_localizacao1","cb_cab_localizacao")
				loPg.cb_cab_localizacao1.visible=.t.

				loPg.addobject("lb_cab_qtdpecas1","lb_cab_qtdpecas")
				loPg.lb_cab_qtdpecas1.visible=.t.

				loPg.addobject("tx_cab_qtdpecas1","tx_cab_qtdpecas")
				loPg.tx_cab_qtdpecas1.visible=.t.

				loPg.addobject("LB_cab_envio1","LB_cab_envio")
				loPg.LB_cab_envio1.visible=.t.

				loPg.addobject("tx_cab_envio1","tx_cab_envio")
				loPg.tx_cab_envio1.visible=.t.

				loPg.addobject("lb_cab_tipo_pedido1","lb_cab_tipo_pedido")
				loPg.lb_cab_tipo_pedido1.visible=.t.

				loPg.addobject("tx_cab_tipo_pedido1","cb_cab_tipo_pedido")
				loPg.tx_cab_tipo_pedido1.visible=.t.
				
				loPg.addobject("lblCdBolacha1","lblCdBolacha")
				loPg.lblCdBolacha1.visible=.t.

				loPg.addobject("txtCdBolacha1","txtCdBolacha")
				loPg.txtCdBolacha1.visible=.t.				
				
				loPg.addobject("label1","label")
				loPg.label1.top = 400
				loPg.label1.left = 40
				loPg.label1.visible=.t.

				**xuxa
				loPg.addobject("lstCabilogAviso1","lstCabilogAviso")
				loPg.lstCabilogAviso1.visible=.t.
				
				loPg.addobject("cmdAtualizaCabilog1","cmdAtualizaCabilog")
				loPg.cmdAtualizaCabilog1.visible=.t.

				loPg.refresh
				
			ENDIF
			
			IF "avisos" $ LOWER(loPg.caption)

				loPg.addobject("lista_erro1","lista_erro")
				loPg.lista_erro1.visible=.t.
				
				loPg.addobject("label_erro1","label_erro")
				loPg.label_erro1.visible=.t.

				loPg.addobject("lista_metrica1","lista_metrica")
				loPg.lista_metrica1.visible=.t.
				
				loPg.addobject("label_metrica1","label_metrica")
				loPg.label_metrica1.visible=.t.			
				
			ENDIF
			
			
		ENDFOR
		
		objTelaPai.lx_form1.lx_pageframe1.activepage = 1 &&CAST(lcPage as Int)
		
	CATCH TO loErro
		MESSAGEBOX(loErro.Message,16,"Aviso")

	ENDTRY
	** PAULO DEVIDE - 09-SET-14 (FIM)
	
	*** para pegar o numero da p√°gina para acessar
	** objTelaPai.lx_form1.lx_pageframe1.activepage = getPageIndex(objTelaPai, "Avisos")
	***
	
	*** Ordem de NavegaÁ„o dos objetos da Aba CabeÁalho
	objTelaPai.lx_foRM1.lx_pageframe1.page1.tv_condicao_pgto.TabIndex = 1
	objTelaPai.lx_foRM1.lx_pageframe1.page1.tx_desc_condicao_pgto.TabIndex = 2
	objTelaPai.lx_foRM1.lx_pageframe1.page1.tx_tipo_condicao.TabIndex = 3
	objTelaPai.lx_foRM1.lx_pageframe1.page1.TV_TIPO_COMPRA.TabIndex = 4
	objTelaPai.lx_foRM1.lx_pageframe1.page1.tx_PEDIDO_FORNECEDOR.TabIndex = 5
	objTelaPai.lx_foRM1.lx_pageframe1.page1.TV_REQUERIDO_POR.TabIndex = 6
	objTelaPai.lx_foRM1.lx_pageframe1.page1.cmbRequeridoPor.TabIndex = 7
	objTelaPai.lx_foRM1.lx_pageframe1.page1.tx_REQUERIDO_POR.TabStop = .f.
	objTelaPai.lx_foRM1.lx_pageframe1.page1.tx_REQUERIDO_POR.TabIndex = 8
	objTelaPai.lx_foRM1.lx_pageframe1.page1.tx_APROVADOR_POR.TabIndex = 9
	objTelaPai.lx_foRM1.lx_pageframe1.page1.tv_PROGRAMACAO.TabIndex = 10
	objTelaPai.lx_foRM1.lx_pageframe1.page1.tv_TRANSPORTADORA.TabIndex = 11
	objTelaPai.lx_foRM1.lx_pageframe1.page1.TV_PEDIDO_COMPRA_ORIGEM.TabIndex = 12
	objTelaPai.lx_foRM1.lx_pageframe1.page1.cmdFretePagar.TabIndex = 13
	objTelaPai.lx_foRM1.lx_pageframe1.page1.cmb_FILIAL_A_ENTREGAR.TabIndex = 14
	objTelaPai.lx_foRM1.lx_pageframe1.page1.cmb_FILIAL_COBRANCA.TabIndex = 15
	objTelaPai.lx_foRM1.lx_pageframe1.page1.cmb_FILIAL_A_FATURAR.TabIndex = 16
	objTelaPai.lx_foRM1.lx_pageframe1.page1.tx_TOT_QTDE_ENTREGAR.TabIndex = 17
	objTelaPai.lx_foRM1.lx_pageframe1.page1.tx_TOT_VALOR_ENTREGAR.TabIndex = 18
	objTelaPai.lx_foRM1.lx_pageframe1.page1.tx_variacao.TabIndex = 19
	objTelaPai.lx_foRM1.lx_pageframe1.page1.tx_total_padrao.TabIndex = 20
	objTelaPai.lx_foRM1.lx_pageframe1.page1.tx_saldo_padrao.TabIndex = 21
	objTelaPai.lx_foRM1.lx_pageframe1.page1.tx_CADASTRAMENTO.TabIndex = 22
	objTelaPai.lx_foRM1.lx_pageframe1.page1.tx_EMISSAO.TabIndex = 23
	objTelaPai.lx_foRM1.lx_pageframe1.page1.Lx_textbox_valida1.TabIndex = 24
	objTelaPai.lx_foRM1.lx_pageframe1.page1.tx_data_faturamento_relativo.TabIndex = 25
	objTelaPai.lx_foRM1.lx_pageframe1.page1.tx_CTB_Tipo_Operacao.TabIndex = 26
	objTelaPai.lx_foRM1.lx_pageframe1.page1.tx_Desc_Tipo_Operacao.TabIndex = 27
	objTelaPai.lx_foRM1.lx_pageframe1.page1.sp_ENTREGA_ACEITAVEL.TabStop = .f.
	objTelaPai.lx_foRM1.lx_pageframe1.page1.sp_ENTREGA_ACEITAVEL.TabIndex = 28
	objTelaPai.lx_foRM1.lx_pageframe1.page1.cmb_MOEDA.TabIndex = 29
	objTelaPai.lx_foRM1.lx_pageframe1.page1.Cmb_status_compra.TabIndex = 30
	objTelaPai.lx_foRM1.lx_pageframe1.page1.lx_aprovado.TabIndex = 31
	objTelaPai.lx_foRM1.lx_pageframe1.page1.lx_data_aprovacao.TabIndex = 32
	objTelaPai.lx_foRM1.lx_pageframe1.page1.tv_Rateio_Filial.TabIndex = 33
	objTelaPai.lx_foRM1.lx_pageframe1.page1.tx_desc_rateio_filial.TabIndex = 34
	objTelaPai.lx_foRM1.lx_pageframe1.page1.tv_rateio_centro_custo.TabIndex = 35
	objTelaPai.lx_foRM1.lx_pageframe1.page1.tx_desc_rateio_centro_custo.TabIndex = 36
	objTelaPai.lx_foRM1.lx_pageframe1.page1.ck_CTRL_MULT_ENTREGAS.TabIndex = 37
	objTelaPai.lx_foRM1.lx_pageframe1.page1.tx_ENTREGA_UNICA.TabIndex = 38
	objTelaPai.lx_foRM1.lx_pageframe1.page1.tx_LIMITE_ENTREGA_UNICA.TabIndex = 39
	objTelaPai.lx_foRM1.lx_pageframe1.page1.tx_VALOR_IPI.TabIndex = 40
	objTelaPai.lx_foRM1.lx_pageframe1.page1.tx_TOT_QTDE_ORIGINAL.TabIndex = 41
	objTelaPai.lx_foRM1.lx_pageframe1.page1.tx_PORC_DESCONTO.TabIndex = 42
	objTelaPai.lx_foRM1.lx_pageframe1.page1.tx_DESCONTO.TabIndex = 43
	objTelaPai.lx_foRM1.lx_pageframe1.page1.tx_SUB_TOTAL.TabIndex = 44
	objTelaPai.lx_foRM1.lx_pageframe1.page1.tx_PORC_ENCARGO.TabIndex = 45
	objTelaPai.lx_foRM1.lx_pageframe1.page1.tx_ENCARGO.TabIndex = 46
	objTelaPai.lx_foRM1.lx_pageframe1.page1.tx_TOT_VALOR_ORIGINAL.TabIndex = 47
	objTelaPai.lx_foRM1.lx_pageframe1.page1.tx_tot_qtde_rateio.TabIndex = 48
	objTelaPai.lx_foRM1.lx_pageframe1.page1.tx_tot_valor_rateio.TabIndex = 49
	objTelaPai.lx_foRM1.lx_pageframe1.page1.Tx_Despesas.TabIndex = 50
	objTelaPai.lx_foRM1.lx_pageframe1.page1.Tx_ORIGINAL_DESP.TabIndex = 51
	objTelaPai.lx_foRM1.lx_pageframe1.page1.ck_distribuicao.TabIndex = 52
	objTelaPai.lx_foRM1.lx_pageframe1.page1.ck_liberado_cq.TabIndex = 53
	objTelaPai.lx_foRM1.lx_pageframe1.page1.ck_manual.TabIndex = 54
	objTelaPai.lx_foRM1.lx_pageframe1.page1.ck_faturado.TabIndex = 55
	objTelaPai.lx_foRM1.lx_pageframe1.page1.TXTTOTPERCENTDISTRIB1.TabIndex = 56
	objTelaPai.lx_foRM1.lx_pageframe1.page1.TXTTOTQTDDISTRIB1.TabIndex = 57
	objTelaPai.lx_foRM1.lx_pageframe1.page1.TX_DATA_OTB1.TabIndex = 58
	objTelaPai.lx_foRM1.lx_pageframe1.page1.CBO_TIPO_PEDIDO1.TabIndex = 59
	objTelaPai.lx_foRM1.lx_pageframe1.page1.CBO_SEGMENTO_PEDIDO1.TabIndex = 60
	objTelaPai.lx_foRM1.lx_pageframe1.page1.CK_IMPORTADO1.TabIndex = 61

	
	RETURN .T.
ENDFUNC

PROCEDURE PROC_004006_INCLUDE_AFTER
	PARAMETERS objTelaPai, xmetodo, xobjeto, xnome_obj
	****
	* MONTA UMA CURSOR TEMPORARIO COM OS CAMPOS DE CONTROLE DE VERBAS DE OTB
	* PARA SER SUBTRAIDO AO ATUALIZAR A TABELA Caedu_verba_compras no SQL
	* PAULO DEVIDE - 28-01-2016
	*/
	lnArea = SELECT()

	SELECT ;
		PRODUTO,;
		MAX(LIMITE_ENTREGA) AS LIMITE_ENTREGA, ;
		SUM(VALOR_ORIGINAL) AS VALOR_ORIGINAL, ;
		SUM(NVL(ERP_VERBAS_EMPENHO,0)) AS ERP_VERBAS_EMPENHO, ;
		MAX(NVL(ERP_VERBAS_DATA_EMPENHO,{})) AS ERP_VERBAS_DATA_EMPENHO, ;
		MAX(CAST(NVL(ERP_VERBAS_EMPENHO_ANO_MES,0) AS NUMERIC(6,0))) AS ERP_VERBAS_EMPENHO_ANO_MES, ;
		.f. AS ERP_VERBAS_STATUS_PR ;
	FROM ;
		V_COMPRAS_01_PRODUTOS WITH (BUFFERING = .T.) ;
	GROUP BY ;
		PRODUTO INTO CURSOR CURVERBAS_BEFORE_ALTER READWRITE

	SELECT (lnArea)


	objTelaPai.lx_form1.lx_pageframe1.Page1.tx_data_otb1.value = DATE() && Valor default para data OTB

	IF objTelaPai.p_Tool_Status="I" && Somente na inclus√£o

		Select v_Compras_01
		Replace FILIAL_A_ENTREGAR With RTRIM(o_004006.pp_filial_padrao),;
			FILIAL_COBRANCA   With 'MATRIZ',;
			FILIAL_A_FATURAR  With RTRIM(o_004006.pp_filial_padrao)

		objTelaPai.lx_form1.lx_pageframe1.Page1.cmb_FILIAL_A_ENTREGAR.VALUE =  RTRIM(o_004006.pp_filial_padrao)
		objTelaPai.lx_form1.lx_pageframe1.Page1.cmb_FILIAL_A_FATURAR.VALUE =  RTRIM(o_004006.pp_filial_padrao)
		
		REPLACE v_Compras_01.ERP_CUPS_SEGMENTO WITH "VAREJO"

	endif
	** PAULO DEVIDE - muda o valor do campo DATA OTB na inclus√£o no caso de haver
	** altera√ß√£o no campo entrega - 15-08-2013
ENDPROC

FUNCTION PROC_004006_ALTER_BEFORE 
	PARAMETERS objTelaPai, xmetodo, xobjeto, xnome_obj
	** PAULO DEVIDE - 17-11-2014 - PROPRIEDADE PARA GUARDAR O VALOR DA CONDI√á√ÉO DE PAGAMENTO
	TRY 
		ADDPROPERTY(objTelaPai,"CONDICAO_PGTO_ANTES",v_compras_01.condicao_pgto)				
	CATCH TO err1
		WAIT WINDOW NOWAIT err1.message
	FINALLY
		objTelaPai.CONDICAO_PGTO_ANTES = v_compras_01.condicao_pgto
		WAIT clear
	ENDTRY

	Select v_compras_01_ent_prod
	=Requery()

	DO Case

		Case Reccount('v_compras_01_ent_prod') >= 1

			nAnswer = Messagebox('Esse pedido de compra j· foi recebido total ou parcialmente' +Chr(13)+;
									'AlteraÁıes permitidas apenas com Senha Gerencial.' +Chr(13)+;
									'Deseja entrar com senha de alteraÁ„o ?', 292, "Aviso")

			Do Case
				Case nAnswer = 6

					glSenha = ""
					oSenha = CREATEOBJECT("tsenhapedido")
					oSenha.show(1)

					f_select("Select valor_atual from parametros where parametro = 'CAE_SENHA_COMPRAS' ","LISTAUT"	)

					Select LISTAUT
					CAEWHERE = LISTAUT.VALOR_ATUAL
					xaut = 0

					If Inlist(glSenha  , &CAEWHERE  )
						xaut = xaut  +1
					Endif

					If xaut > 0
						Return .T.
					Else
						Messagebox("Senha incorreta ou n„o autorizada",16, "Aviso")
						Return .F.
					Endif

				Case nAnswer = 7
					Return .F.

			Endcase
	ENDCASE

	****
	* MONTA UMA CURSOR TEMPORARIO COM OS CAMPOS DE CONTROLE DE VERBAS DE OTB
	* PARA SER SUBTRAIDO AO ATUALIZAR A TABELA Caedu_verba_compras no SQL
	* PAULO DEVIDE - 28-01-2016
	*/
	
	lnArea = SELECT()

	SELECT ;
		PRODUTO,;
		MAX(LIMITE_ENTREGA) AS LIMITE_ENTREGA, ;
		SUM(VALOR_ORIGINAL) AS VALOR_ORIGINAL, ;
		SUM(NVL(ERP_VERBAS_EMPENHO,0)) AS ERP_VERBAS_EMPENHO, ;
		MAX(NVL(ERP_VERBAS_DATA_EMPENHO,{})) AS ERP_VERBAS_DATA_EMPENHO, ;
		MAX(CAST(NVL(ERP_VERBAS_EMPENHO_ANO_MES,0) AS NUMERIC(6,0))) AS ERP_VERBAS_EMPENHO_ANO_MES, ;
		.f. AS ERP_VERBAS_STATUS_PR ;
	FROM ;
		V_COMPRAS_01_PRODUTOS WITH (BUFFERING = .T.) ;
	GROUP BY ;
		PRODUTO INTO CURSOR CURVERBAS_BEFORE_ALTER READWRITE

	SELECT (lnArea)
	RETURN .T.
ENDFUNC


FUNCTION PROC_004006_ITENS_CANCELADOS
	llCancela = (RECCOUNT("V_COMPRAS_01_CANCELAMENTO")>0)
	RETURN llCancela
ENDFUNC

***
* ALIMENTA UM OBJETO LISTBOX COM AS MENSAGENS DE ERRO DA TELA
*/		
PROCEDURE ADICIONA_ERRO
	PARAMETERS loListaErro, lcMensagemErro, blnLimparLista
	IF blnLimparLista
		loListaErro.Clear
	ENDIF
	IF EMPTY(lcMensagemErro)
		RETURN
	ELSE
		loListaErro.AddItem(lcMensagemErro)
	ENDIF
	RETURN
ENDPROC


******************************************************************************************
** PAULO DEVIDE --> 22-NOV-2016 VALIDA CABILOG(INICIO)
******************************************************************************************
FUNCTION VALIDA_CABILOG
	PARAMETERS objLista, objTelaPai
	llRet = .t.
	IF Inlist(objTelaPai.p_Tool_Status, "A","I")
	
		objTelaPai.lx_form1.lx_pageframe1.Page1.ACTIVATE()
		** verifica se todos os campos foram preenchidos
		lcMsgErr = ""

		** COMANDO ABAIXO COMENTADO EM 16-10-2017
		** IF v_Compras_01.ERP_CAB_ENCABIDADO && se estiver clicado, valida os campos obrigat√≥rios

		** OP√á√ïES DO CAMPO v_Compras_01.ERP_CAB_OPCAO:
		**	1 = "Nenhum"
		**	2 = "S√≥ Encabidado"
		**	3 = "S√≥ Alarme"
		**	4 = "Encabidado + Alarme"
		IF NVL(v_Compras_01.ERP_CAB_OPCAO,0) > 1 && se estiver clicado, valida os campos obrigat√≥rios
		
			IF INLIST(NVL(v_Compras_01.ERP_CAB_OPCAO,0),2,4)		
				IF EMPTY(NVL(v_Compras_01.ERP_CAB_COD_CABIDE,""))
					ADICIONA_ERRO(objLista, "ObrigatÛrio preencher o CÛdigo do Cabide (Aba - Cabilog)", .F.)
					llRet = .f.
				ENDIF
			ENDIF
			
			** VERIFICA SE O C√ìDIGO DO ALARME FOI PREENCHIDO CONFORME FAIXA DE VALOR 
			** RETORNADO PELA FUNCAO F_FAIXA_VALOR_CABILOG()
			** AT√â 14,99 ISENTO, CAMPO TEM QUE ESTAR EM BRANCO
			** DE 15,00 AT√â 79,99 - CAMPO TEM QUE ESTAR PREENCHIDO COM VALOR = "E1"
			** ACIMA DE 80,00 - CAMPO TEM QUE ESTAR PREENCHIDO COM VALOR = "E2"
			
			IF INLIST(NVL(v_Compras_01.ERP_CAB_OPCAO,0),3,4)
				cRespFaixa = F_FAIXA_VALOR_CABILOG()
				IF ALLTRIM(NVL(v_Compras_01.ERP_CAB_COD_BOLACHA,"")) <> cRespFaixa
					replace v_Compras_01.ERP_CAB_COD_BOLACHA WITH cRespFaixa
					WAIT WINDOW NOWAIT "CÛdigo de Alarme estava divergente e foi atualizado..."
					*ADICIONA_ERRO(objLista, "VALOR do campo cÛdigo do alarme est· com divergÍncia (Aba - Cabilog)", .F.)
					*llRet = .f.
					llRet = .t.
				ENDIF
			ENDIF
					
			IF EMPTY(NVL(v_Compras_01.ERP_CAB_CD_ENTREGA,""))
				ADICIONA_ERRO(objLista, "ObrigatÛrio preencher o CÛdigo do CD Entrega  (Aba - Cabilog)", .F.)
				llRet = .f.
			ENDIF
			
			IF EMPTY(NVL(v_Compras_01.ERP_CAB_LOCALIZACAO,""))
				ADICIONA_ERRO(objLista, "ObrigatÛrio preencher a LocalizaÁ„o Cabide  (Aba - Cabilog)", .F.)
				llRet = .f.
			ENDIF
			
			IF EMPTY(NVL(v_Compras_01.ERP_CAB_TIPO_PEDIDO,""))
				ADICIONA_ERRO(objLista, "ObrigatÛrio preencher o Tipo de Pedido  (Aba - Cabilog)", .F.)
				llRet = .f.
			ENDIF
			
			IF EMPTY(NVL(v_Compras_01.ERP_CAB_QTDPECAS,0))
				ADICIONA_ERRO(objLista, "ObrigatÛrio preencher a QTDE de peÁas (Aba - Cabilog)", .F.)
				llRet = .f.
			ENDIF
		
			IF EMPTY(NVL(v_Compras_01.ERP_CAB_STATUS,""))
				ADICIONA_ERRO(objLista, "ObrigatÛrio preencher o STATUS (Aba - Cabilog)", .F.)
				llRet = .f.
			ENDIF

		ENDIF
		
		IF NOT llRet 
			RETURN .f.
		ENDIF

		llNaoValidar = .t.

		lcCab_Status = "M"
		llData_Envio = .f.
		
		DO CASE
			CASE objTelaPai.p_Tool_Status="A"		&& ATUALIZA PROPRIEDADE CAB_STATUS PARA 'M'
				*SET STEP ON
				IF RECCOUNT("V_COMPRAS_01_CANCELAMENTO")>0
				
					IF NOT EMPTY(NVL(v_Compras_01.ERP_CAB_DATA_ENVIO,CTOD("")))
						lcCab_Status = "C" && pedido cancelado
						llData_Envio = .t.
					ELSE
						lcCab_Status = "A" && pedido cancelado
					ENDIF
					

				ELSE
					llMudouQtdOriginal = .f.
					IF objTelaPai.QUANTIDADE_TOTAL_ORIGINAL <> v_Compras_01.TOT_QTDE_ORIGINAL
						*MESSAGEBOX("MUDOU A QUANTIDADE",64,"AVISO")
						llMudouQtdOriginal = .T.
						replace v_Compras_01.ERP_CAB_DATA_ENVIO WITH NULL
						lcCab_Status = "M"
						replace v_Compras_01.ERP_CAB_STATUS WITH "M"
						
						***
						* Le a tabela de Produtos e sumariza a coluna QTDE_ORIGINAL
						*/
						lnArea1 = SELECT()
						lnQtdOriginal = 0
						SELECT V_COMPRAS_01_PRODUTOS
						SCAN
							lnQtdOriginal = lnQtdOriginal + V_COMPRAS_01_PRODUTOS.QTDE_ORIGINAL
						ENDSCAN

						SELECT (lnArea1)
						
						lnErp_cab_qtdpecas = CEILING(lnQtdOriginal * (objTelaPai.pp_porcentagem_qtd_cabides/100))

						WAIT WINDOW "QUANTIDADE PE«AS CABILOG ATUALIZADO PARA:"+CHR(13)+;
									TRANSFORM(lnErp_cab_qtdpecas,"9999999") timeout 2
									
						replace v_Compras_01.ERP_CAB_QTDPECAS with lnErp_cab_qtdpecas
								
					ELSE
						*MESSAGEBOX("QUANTIDADE PERMANECEU IGUAL",64,"AVISO")
						llMudouQtdOriginal = .f.
					ENDIF

					IF NOT EMPTY(NVL(v_Compras_01.ERP_CAB_DATA_ENVIO,CTOD("")))
						lcCab_Status = "M" && pedido Ok!
						llData_Envio = .t.
					ELSE
				
						*lcCab_Status = "A" && pedido Ok!
					ENDIF

				ENDIF


				REPLACE v_Compras_01.ERP_CAB_STATUS WITH lcCab_Status
*!*					replace v_Compras_01.ERP_CAB_QTDPECAS with ;
*!*						CEILING(v_Compras_01.TOT_QTDE_ORIGINAL * (objTelaPai.pp_porcentagem_qtd_cabides/100)) 
				
				IF llData_Envio && grava NULL na data de envio para poder enviar arquivo novamente para a CABILOG
					replace v_compras_01.ERP_CAB_DATA_ENVIO WITH CTOD("")
				ENDIF
				
				objTelaPai.lx_form1.lx_pageframe1.pgCabilog.cmdAtualizaCabilog1.click()
				
			CASE objTelaPai.p_Tool_Status="I"		&& ATUALIZA PROPRIEADE CAB_STATUS PARA 'A'

				IF RECCOUNT("V_COMPRAS_01_CANCELAMENTO")>0
					IF NOT EMPTY(NVL(v_Compras_01.ERP_CAB_DATA_ENVIO,CTOD("")))
						lcCab_Status = "C" && pedido cancelado
						llData_Envio = .t.
					ELSE
						lcCab_Status = "A" && pedido cancelado
					ENDIF

				ELSE
					lcCab_Status = "A" && pedido Ok!

				ENDIF

				REPLACE v_Compras_01.ERP_CAB_STATUS WITH lcCab_Status
				replace v_Compras_01.ERP_CAB_QTDPECAS with ;
					CEILING(v_Compras_01.TOT_QTDE_ORIGINAL * (objTelaPai.pp_porcentagem_qtd_cabides/100)) 

				IF llData_Envio && grava NULL na data de envio para poder enviar arquivo novamente para a CABILOG
					replace v_compras_01.ERP_CAB_DATA_ENVIO WITH CTOD("")
				ENDIF


			OTHERWISE

		ENDCASE
		
	ENDIF
ENDFUNC
******************************************************************************************
** PAULO DEVIDE --> 22-NOV-2016 VALIDA CABILOG(FIM)
******************************************************************************************

*********************************************************************************************
*********************************************************************************************
*********************************************************************************************
*** VALIDA√á√ÉO DE CAMPOS OBRIGAT√ìRIOS DO PEDIDO
* SE objLista.ListCount = 0 retorna .T., caso contr√°rio retorna .F.
*/	
FUNCTION VALIDA_CAMPOS_PEDIDO
	PARAMETERS objLista
	LOCAL lnArea as Integer
	LOCAL lnTotReg1 as Integer, lnTotReg2 as Integer

	lnArea = SELECT()

	SELECT v_caedu_compras_produtos_packs
	lnTotReg1 = RECCOUNT("v_caedu_compras_produtos_packs")

	SELECT v_caedu_compras_produtos_packs_total
	lnTotReg2 = RECCOUNT("v_caedu_compras_produtos_packs_total")

	*
	ADICIONA_ERRO(objLista, "", .T.) && limpa o listbox de erros
	*
	SELECT v_compras_01
	** 1) Tipo de compra
	IF EMPTY(NVL(v_compras_01.tipo_compra,''))
		ADICIONA_ERRO(objLista, "Campo [Tipo de Compra] È obrigatÛrio...", .F.)
	ENDIF
	** 2) Requerido por:
	IF EMPTY(NVL(v_compras_01.requerido_por,''))
		ADICIONA_ERRO(objLista, "Campo [Requerido por] È obrigatÛrio...", .F.)
	ENDIF
	** 3) Aprovado/Reprovado:
	IF EMPTY(NVL(v_compras_01.aprovador_por,''))
		ADICIONA_ERRO(objLista, "Campo [Aprovado/Reprovado] È obrigatÛrio...", .F.)
	ENDIF
	** 4) Natureza Entrada:
	IF EMPTY(NVL(v_compras_01.natureza_entrada,''))
		ADICIONA_ERRO(objLista, "Campo [Natureza entrada] È obrigatÛrio...", .F.)
	ENDIF
	** 5) Data de Entrega:
	IF EMPTY(NVL(pdEntrega,CTOD('')))
		ADICIONA_ERRO(objLista, "Campo [Data de Entrega] È obrigatÛrio...", .F.)
	ENDIF
	** 6) Data de Limite de Entrega:
	IF EMPTY(NVL(pdLimite,CTOD('')))
		ADICIONA_ERRO(objLista, "Campo [Limite de Entrega] È obrigatÛrio...", .F.)
	ENDIF
	** 7) Validar se existe itens cadastrados e com quantidade/valor:
	IF EMPTY(NVL(v_compras_01.tot_valor_original,0))
		ADICIONA_ERRO(objLista, "… obrigatÛrio informar os itens do pedido...", .F.)
	ENDIF
	** 8) Validar se os cursor adapter PACK contem registro
	IF lnTotReg1=0
		ADICIONA_ERRO(objLista, "InconsistÍncia na informaÁ„o de PACKs...", .F.)
	ENDIF
	** 9) Validar se os cursor adapter PACK contem registro
	IF lnTotReg2=0
		ADICIONA_ERRO(objLista, "InconsistÍncia na informaÁ„o de Totalizador de PACKs...", .F.)
	ENDIF
	** 10) Validar filial_a_entregar
	IF EMPTY(NVL(v_compras_01.FILIAL_A_ENTREGAR,''))
		ADICIONA_ERRO(objLista, "… obrigatÛrio informar [FILIAL_A_ENTREGAR]...", .F.)
	ENDIF
	** 11) Validar filial_cobranca
	IF EMPTY(NVL(v_compras_01.FILIAL_COBRANCA,''))
		ADICIONA_ERRO(objLista, "… obrigatÛrio informar [FILIAL_COBRANCA]...", .F.)
	ENDIF
	** 12) Validar filial_a_faturar
	IF EMPTY(NVL(v_compras_01.FILIAL_A_FATURAR,''))
		ADICIONA_ERRO(objLista, "… obrigatÛrio informar [FILIAL_A_FATURAR]...", .F.)
	ENDIF
	** 13) Validar RATEIO_CENTRO_CUSTO
	IF EMPTY(NVL(v_compras_01.RATEIO_CENTRO_CUSTO,""))
		ADICIONA_ERRO(objLista, "ObrigatÛrio preencher RATEIO CENTRO DE CUSTO", .F.)
	ENDIF
	** 14) Validar RATEIO_FILIAL
	IF EMPTY(NVL(v_compras_01.RATEIO_FILIAL,""))
		ADICIONA_ERRO(objLista, "ObrigatÛrio preencher RATEIO FILIAL", .F.)
	ENDIF
	** 15) Validar CTB_TIPO_OPERACAO
	IF EMPTY(NVL(v_compras_01.CTB_TIPO_OPERACAO,0))
		ADICIONA_ERRO(objLista, "ObrigatÛrio preencher TIPO de OPERA«√O/NATUREZA de OperaÁ„o", .F.)
	ENDIF
	

	***
	* importado/estrangeiro 
	*/
	IF ZORIGEM_PEDIDO_IMPORTADO()=.t. AND !ZAUTORIZA_ATACADO()
		IF EMPTY(NVL(v_compras_01.ERP_CUPS_TIPO_PEDIDO,""))
			ADICIONA_ERRO(objLista, "ObrigatÛrio preencher TIPO DE PEDIDO (CCF/CCA)", .F.)
		ENDIF
		
		IF EMPTY(NVL(v_compras_01.ERP_CUPS_DATA_ACORDADA,{}))
			ADICIONA_ERRO(objLista, "ObrigatÛrio preencher DATA ACORDADA", .F.)
		ENDIF
		
		IF EMPTY(NVL(v_compras_01.ERP_CUPS_INCOTERM,""))
			ADICIONA_ERRO(objLista, "ObrigatÛrio preencher INCOTERM na aba IMPORTADO", .F.)
		ENDIF
		
		IF EMPTY(NVL(v_compras_01.ERP_CUPS_ID_CONTRATO,""))
			ADICIONA_ERRO(objLista, "ObrigatÛrio preencher CONTRATO na aba IMPORTADO", .F.)
		ENDIF

		SELECT v_compras_01_produtos
		GO top

		SCAN 					

			IF EMPTY(NVL(v_compras_01_produtos.ERP_CUPS_CUSTO_FOB,0))
				ADICIONA_ERRO(objLista, "Campo CUSTO FOB em branco.", .F.)
			ENDIF
			
			SELECT v_compras_01_produtos
			
		ENDSCAN
	ENDIF
	
	SELECT (lnArea)
	RETURN (objLista.ListCount = 0)
ENDFUNC
*** VALIDA√á√ÉO DE M√âTRICAS DEFINIDAS DO PEDIDO
*********************************************************************************************
*********************************************************************************************
*********************************************************************************************

*** VALIDA√á√ÉO DE M√âTRICAS DEFINIDAS DO PEDIDO
* SE objLista.ListCount = 0 retorna .T., caso contr√°rio retorna .F.
*/	
FUNCTION VALIDA_METRICAS_PEDIDO
	PARAMETERS objLista
	LOCAL lnArea as Integer
	LOCAL lnTotReg1 as Integer, lnTotReg2 as Integer

	LOCAL objMetrica as object 
	objMetrica = CREATEOBJECT("funcoes_metricas", objLista)
	
	lnArea = SELECT()

	*
	ADICIONA_ERRO(objLista, "", .T.) && limpa o listbox de metricas
	*
	**>> ADICIONA_ERRO(objLista, "Campo [Tipo de Compra] √© obrigat√≥rio...", .F.)
	
	***
	* Vefifica se √© necess√°rio adicionar 
	* o registro da tabela pai, e adiciona se precisar
	*/

	** Cria um registro de cabe√ßalho (tabela pai) 
	** para cada PEDIDO + PRODUTO distinto
	objMetrica.ADICIONA_CABECALHO_LOG() 
	***********************************
	
	************************************************
	** PEGA REGISTRO ANTERIOR DOS ITENS DO PEDIDO **
	************************************************
	TEXT TO lcSQL NOSHOW TEXTMERGE
		SELECT * FROM COMPRAS_PRODUTO
		WHERE PEDIDO = '<<v_compras_01.PEDIDO>>'
	ENDTEXT
	F_SELECT(lcSQL, "V_COMPRAS_PRODUTO_ANTES")
	************************************************
	
	***
	* Percorre a tabela de M√©tricas e verifica cada uma
	*/
	SELECT vLOG_METRICAS
	GO TOP
	SCAN

		objMetrica.retorno = .f.
		objMetrica.metrica_erro = ""
		objMetrica.Executa(vLOG_METRICAS.COD_METRICA)


		SELECT vLOG_METRICAS
	ENDSCAN
	
	SELECT (lnArea)
	RETURN (objLista.ListCount = 0)
ENDFUNC


*** VALIDA√á√ÉO DE M√âTRICAS DEFINIDAS DO PEDIDO
*********************************************************************************************
*********************************************************************************************
*********************************************************************************************

FUNCTION ZAUTORIZA_ATACADO
	lnArea = SELECT()
	SELECT * FROM curpropcompras WITH (BUFFERING=.T.) ;
		WHERE ALLTRIM(PROPRIEDADE) = "00077" ;
		INTO CURSOR tmp_autoriza
	llRet = UPPER(ALLTRIM(NVL(tmp_autoriza.valor_propriedade,"")))=="SIM"		
	SELECT (lnArea)

	IF llRet
		MESSAGEBOX("AutorizaÁ„o para TransferÍncia Atacado foi liberada!",48,"Aviso")
	ENDIF
	
	RETURN llRet
ENDFUNC

***
* data_excel - retorna data no formato numerico do Excel
* parametros varialvel_data no formato Date do foxpro
* PAULO DEVIDE - 27-07-2015
*/
FUNCTION data_excel
	PARAMETERS tcData1
	RETURN CAST(SYS(11,tcData1) as int) - CAST(SYS(11,{30/12/1899}) as int)
ENDFUNC

FUNCTION ZORIGEM_PEDIDO_IMPORTADO
	** VERIFICA OS PRODUTOS NO CAMPO TRIBUT_ORIGEM, SE ENCONTRAR PELO MENOS UM PRODUTO COM VALOR = '1' ENT√ÉO ORIGEM √â ESTRANGEIRA
	** RETORNA .T. SE FOR ESTRANGEIRO E .F. SE N√ÉO FOR
	** alterado em 30/11/15 - inclui os codigos 2, 6 e 7 que s√£o estrangeiros tamb√©m
	** ser√° utilizado esta fun√ß√£o para verificar nacional, no caso tem que retorna .f.
	LOCAL lnArea as Integer, llRet as Boolean
	llRet = .f.
	lnArea = SELECT()

	SELECT DISTINCT PRODUTO ;
	FROM V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL ;
	WITH (BUFFERING = .T.) ;
	INTO CURSOR WPRODUTOS1

	SELECT WPRODUTOS1
	SCAN 
		F_SELECT("SELECT TRIBUT_ORIGEM FROM PRODUTOS WHERE PRODUTO = '"+ALLTRIM(WPRODUTOS1.PRODUTO)+"'","tmpTributOrigem")
		IF INLIST(ALLTRIM(NVL(tmpTributOrigem.TRIBUT_ORIGEM,"")),"1","2","6","7")
			llRet = .T.
			EXIT
		ENDIF
	ENDSCAN

	SELECT (lnArea)
	RETURN llRet
ENDFUNC

** PAULO DEVIDE -> 22-05-2013 --> alterado em 15-set-14 impressao de varios pedidos
FUNCTION zPedido_Excel
	PARAMETERS tcArquivo, oExcel, lnSheet

	IF PARAMETERS()<3
		lnSheet = 0 && imprime s√≥ um pedido 
	ENDIF
	
	** Querys de dados do relat√≥rio
	SELECT v_compras_01_produtos
	=REQUERY("v_compras_01_produtos")
	GO top
	MPRODUTO = ALLTRIM(v_compras_01_produtos.produto)

	TEXT TO lcSQL NOSHOW TEXTMERGE
		SELECT * FROM produtos
		where produto = ?v_compras_01_produtos.produto
	ENDTEXT
	f_select(lcSQL,"cur_produtos")

	TEXT TO lcSQL NOSHOW TEXTMERGE
		select RAZAO_SOCIAL AS buyer
		,RTRIM(LTRIM(ENDERECO))+' - '+RTRIM(LTRIM(COMPLEMENTO))+
		' - '+RTRIM(LTRIM(BAIRRO))+' - '+RTRIM(LTRIM(CIDADE))+' - '+RTRIM(LTRIM(UF)) AS adress
		,CEP AS zip_code ,CGC_CPF as CNPJ
		from CADASTRO_CLI_FOR where CLIFOR = '000040'
	ENDTEXT
	f_select(lcSQL,"cur_filial40")

	TEXT TO lcSQL NOSHOW TEXTMERGE
		select COLECAO,DESC_COLECAO
		from COLECOES where COLECAO=?v_compras_01_produtos.colecao
	ENDTEXT
	f_select(lcSQL,"cur_colecao")

	TEXT TO lcSQL NOSHOW TEXTMERGE
		select MATERIAIS_COMPOSICAO.COMPOSICAO,  MATERIAIS_COMPOSICAO.DESC_COMPOSICAO
		From PRODUTOS
		LEFT JOIN MATERIAIS_COMPOSICAO ON MATERIAIS_COMPOSICAO.COMPOSICAO = PRODUTOS.COMPOSICAO
		WHERE PRODUTOS.PRODUTO=?v_compras_01_produtos.produto
	ENDTEXT
	f_select(lcSQL,"cur_composicao")

	TEXT TO lcSQL NOSHOW TEXTMERGE
		SELECT * FROM prop_compras WHERE pedido=?v_compras_01.pedido
	ENDTEXT
	f_select(lcSQL,"cur_prop_compras")
	**

	f_select("select * from produtos_precos where produto = ?v_compras_01_produtos.produto and codigo_tab_preco='40'","cur_preco_venda")


	WITH oExcel && objeto publico passado de parametro para esta fun√ß√£o
		IF lnSheet = 0
			.Sheets(1).Name = ALLTRIM(v_compras_01.pedido)
		ELSE
    		.Sheets(ALLTRIM(TRANSFORM(lnSheet,"9999"))).Select
		    .ActiveSheet.Name = ALLTRIM(v_compras_01.pedido)
		ENDIF

		m.request_no = v_compras_01.pedido
		m.article_no = v_compras_01_produtos.produto

		m.buyer = ALLTRIM(NVL(cur_filial40.buyer,''))
		m.adress = ALLTRIM(NVL(cur_filial40.adress,''))
		m.zip_code = TRANSFORM(ALLTRIM(NVL(cur_filial40.zip_code,'')),"@R 99999-999")
		m.cnpj = TRANSFORM(ALLTRIM(NVL(cur_filial40.cnpj,'')),"@R 99.999.999/9999-99")

		m.collection1 = ALLTRIM(NVL(cur_colecao.desc_colecao,''))
		m.depto = v_compras_01_produtos.griffe
		m.line1 = v_compras_01_produtos.linha
		m.composition = ALLTRIM(NVL(cur_composicao.desc_composicao,''))
		m.type1 = ALLTRIM(NVL(cur_produtos.tipo_produto,''))

		** CUPS --> Propriedade 00068 √© AGORA produtos.ERP_CUPS_STYLENUMBER
		*m.supp_ref = NVL(LOOKUP(cur_prop_compras.valor_propriedade,'00068',cur_prop_compras.propriedade),'') &&ALLTRIM(NVL(cur_produtos.REFER_FABRICANTE,''))
		m.supp_ref = ALLTRIM(NVL(cur_produtos.ERP_CUPS_STYLENUMBER,'')) &&+ "/V"

		m.sizes = ALLTRIM(NVL(cur_produtos.grade,''))
		** PAULO DEVIDE --> 06/10/2014
		**m.supp_ref = ALLTRIM(NVL(cur_produtos.REFER_FABRICANTE,''))

*!*			m.cust_fob = STRTRAN(ALLTRIM(NVL(LOOKUP(cur_prop_compras.valor_propriedade,'00030',cur_prop_compras.propriedade),'')),",",".")
*!*			m.cust_fob = CAST(m.cust_fob as numeric(14,2))

		m.amount = '=H17*M17'
		m.sales_price = cur_preco_venda.preco1 &&V_COMPRAS_01_PRODUTOS.custo1

		m.profoma_invoice = v_compras_01.ERP_CUPS_CONTRATO &&NVL(LOOKUP(cur_prop_compras.valor_propriedade,'00028',cur_prop_compras.propriedade),'')
		
		** PROJETO CUPS - MUDOU PARA CAMPO COMPRAS.ERP_CUPS_EMBARQUE_ATUAL
		** m.shipment_date = NVL(LOOKUP(cur_prop_compras.valor_propriedade,'00029',cur_prop_compras.propriedade),'')

		SET CENTURY ON
		SET DATE BRITISH
		m.shipment_date = v_compras_01.ERP_CUPS_DATA_ACORDADA &&DTOC(v_compras_01.ERP_CUPS_DATA_ACORDADA)
		
		IF NOT EMPTY(m.shipment_date)
			** Data convertida para formato num√©rico do Excel
			m.shipment_date = (Val(Sys(11, NVL(m.shipment_date,CTOD("")))) - Val(Sys(11, {30/12/1899})))
		ENDIF

*!*			m.packs_of = NVL(LOOKUP(cur_prop_compras.valor_propriedade,'00031',cur_prop_compras.propriedade),0)
*!*			m.quantity_of_packs = NVL(LOOKUP(cur_prop_compras.valor_propriedade,'00032',cur_prop_compras.propriedade),0)

		** Cursor detalhe (itens do pedido)
		IF USED("cur_itens_pedido")
			SELECT cur_itens_pedido
			USE
		ENDIF

		CREATE CURSOR cur_itens_pedido ( ;
			PRODUTO C(12) NULL,;
			INDICE INT NULL,;
			CODIGO_BARRA C(25) NULL,;
			DESCRICAO C(40) NULL,;
			COR C(40) NULL,;
			TAMANHO C(8) NULL,;
			QTD INT NULL )

		SELECT v_compras_01_produtos
		GO top
		
		** PROJETO CUPS --> agora pega no item do pedido
		m.cust_fob = v_compras_01_produtos.ERP_CUPS_CUSTO_FOB


		LOCAL lnCont as Integer
		m.quantity_of_packs = 0
		SCAN
			
			FOR lnCont=1 TO 48
				lcCampo = "v_compras_01_produtos.co"+ALLTRIM(TRANSFORM(lnCont,"99"))
				lnCampo_value = NVL(EVALUATE(lcCampo),0)
				IF NOT EMPTY(lnCampo_value)

					TEXT TO lcSQL NOSHOW TEXTMERGE
						select PRODUTOS_BARRA.*
						from PRODUTOS
						LEFT JOIN PRODUTOS_BARRA ON PRODUTOS_BARRA.PRODUTO = PRODUTOS.PRODUTO
						WHERE PRODUTOS.PRODUTO = '<<v_compras_01_produtos.produto>>'
							AND COR_PRODUTO = '<<v_compras_01_produtos.cor_produto>>'
							and TAMANHO = <<lnCont>>
					ENDTEXT
					f_select(lcSQL,"cur_produto_barra")

					SELECT cur_itens_pedido
					APPEND BLANK
					REPLACE PRODUTO WITH v_compras_01_produtos.produto
					REPLACE INDICE WITH lnCont
					REPLACE CODIGO_BARRA WITH ALLTRIM(cur_produto_barra.CODIGO_BARRA)
					REPLACE DESCRICAO WITH ALLTRIM(v_compras_01_produtos.DESC_PRODUTO)
					REPLACE COR WITH v_compras_01_produtos.DESC_COR_PRODUTO
					REPLACE TAMANHO WITH cur_produto_barra.GRADE
					REPLACE QTD WITH lnCampo_value

				ENDIF

			ENDFOR

			m.packs_of = v_compras_01_produtos.ERP_CUPS_PACKS_POR_CAIXA 
			m.quantity_of_packs = m.quantity_of_packs + v_compras_01_produtos.QTDE_ORIGINAL

		ENDSCAN

		
		*** Pega o Pack total agrupado do produto - Paulo Devide -> 20-07-2015
		lnArea = SELECT()
		SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL
		=REQUERY("V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL")
		LOCATE FOR ALLTRIM(produto) = MPRODUTO 
		SELECT (lnArea)
		
		M.PACKS_OF = V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.qtde
		
		IF m.packs_of>0
			m.quantity_of_packs = m.quantity_of_packs/m.packs_of
		ELSE
			m.quantity_of_packs = 0
		ENDIF
		
		
		SELECT cur_itens_pedido
		INDEX on PRODUTO+COR+STR(INDICE,2,0) TAG IND01
		SET ORDER TO TAG IND01
		GO TOP

		.range("N2").value = m.request_no
		.range("N4").value = m.article_no

		.range("C8").value = m.buyer
		.range("C9").value = m.adress
		.range("C11").value = m.zip_code
		.range("C12").value = m.cnpj

		.range("C15").value = m.collection1
		.range("C16").value = m.depto
		.range("C17").value = m.line1
		.range("C18").value = m.composition
		.range("C19").value = m.type1

		.range("H15").value = m.sizes
		.range("H16").value = m.supp_ref
		.range("H17").value = m.cust_fob
		.range("H18").value = m.amount
		.range("H19").value = m.sales_price

		.range("M15").value = m.profoma_invoice
		.range("M16").value = m.shipment_date
		.range("M17").value = m.packs_of
		.range("M18").value = m.quantity_of_packs

    	.Range("L19").value = "Order:"
	    .Range("L19").Select
	    .Selection.Font.Bold = .t.
    	.Range("N19").value = "RETAIL" && varejo
    
		*** Formata√ß√£o dos Itens do Pedido
		IF RECCOUNT("cur_itens_pedido")>0

			lnLinha = 24
			FOR lnRec = 1 TO RECCOUNT("cur_itens_pedido")
				.Rows("24:24").Select
				.Selection.Copy
				lcLinha = ALLTRIM(TRANSFORM(lnLinha+lnRec,"9999"))
				.Rows(lcLinha+":"+lcLinha).Select
				.Selection.Insert(-4121)
			ENDFOR

			SELECT cur_itens_pedido
			SCAN

				lcLinha = ALLTRIM(TRANSFORM(lnLinha,"9999"))
				.range("B"+lcLinha).value = "'"+ALLTRIM(NVL(cur_itens_pedido.CODIGO_BARRA,''))
				.range("D"+lcLinha).value = ALLTRIM(NVL(cur_itens_pedido.DESCRICAO,''))
				.range("I"+lcLinha).value = ALLTRIM(NVL(cur_itens_pedido.COR,''))
				.range("L"+lcLinha).value = ALLTRIM(NVL(cur_itens_pedido.TAMANHO,''))
				.range("N"+lcLinha).value = cur_itens_pedido.QTD

				lnLinha = lnLinha + 1
			ENDSCAN

			lcLinhaFormula = ALLTRIM(CAST(24+RECCOUNT("cur_itens_pedido")+3 as char(4)))
			.Range("N"+lcLinhaFormula).Select
			.ActiveCell.FormulaR1C1 = "=SUM(R[-"+ALLTRIM(TRANSFORM(RECCOUNT("cur_itens_pedido")+3,"9999"))+"]C:R[-4]C)"

			lnQtdTotal = CAST(.Range("N"+lcLinhaFormula).Value as Int)
			.range("H18").value = m.cust_fob * lnQtdTotal

			lcLinhaFormula = ALLTRIM(CAST(24+RECCOUNT("cur_itens_pedido")+6 as char(4)))
			.Range("B"+lcLinhaFormula).value = ALLTRIM(v_compras_01.obs)
		ENDIF

		.range("A1").select
		.ActiveWorkbook.Save

	ENDWITH

	SELECT v_compras_01_produtos
	GO top

ENDFUNC
** Fim: 22-05-2013

FUNCTION zPedido_Excel_Atc
	PARAMETERS tcArquivo, oExcel, lnSheet

	IF PARAMETERS()<3
		lnSheet = 0 && imprime s√≥ um produto do pedido 
	ENDIF
	
	** Querys de dados do relat√≥rio
	SELECT v_compras_01_produtos
	=REQUERY("v_compras_01_produtos")
	GO top

	LOCATE FOR PRODUTO = tmpProdutos1.PRODUTO
	
	TEXT TO lcSQL NOSHOW TEXTMERGE
		SELECT * FROM produtos
		where produto = ?tmpProdutos1.produto
	ENDTEXT
	f_select(lcSQL,"cur_produtos")

	TEXT TO lcSQL NOSHOW TEXTMERGE
		select RAZAO_SOCIAL AS buyer
		,RTRIM(LTRIM(ENDERECO))+' - '+RTRIM(LTRIM(COMPLEMENTO))+
		' - '+RTRIM(LTRIM(BAIRRO))+' - '+RTRIM(LTRIM(CIDADE))+' - '+RTRIM(LTRIM(UF)) AS adress
		,CEP AS zip_code ,CGC_CPF as CNPJ
		from CADASTRO_CLI_FOR where CLIFOR = '000040'
	ENDTEXT
	f_select(lcSQL,"cur_filial40")

	TEXT TO lcSQL NOSHOW TEXTMERGE
		select COLECAO,DESC_COLECAO
		from COLECOES where COLECAO=?v_compras_01_produtos.colecao
	ENDTEXT
	f_select(lcSQL,"cur_colecao")

	TEXT TO lcSQL NOSHOW TEXTMERGE
		select MATERIAIS_COMPOSICAO.COMPOSICAO,  MATERIAIS_COMPOSICAO.DESC_COMPOSICAO
		From PRODUTOS
		LEFT JOIN MATERIAIS_COMPOSICAO ON MATERIAIS_COMPOSICAO.COMPOSICAO = PRODUTOS.COMPOSICAO
		WHERE PRODUTOS.PRODUTO=?tmpProdutos1.produto
	ENDTEXT
	f_select(lcSQL,"cur_composicao")

	TEXT TO lcSQL NOSHOW TEXTMERGE
		SELECT * FROM prop_compras WHERE pedido=?v_compras_01.pedido
	ENDTEXT
	f_select(lcSQL,"cur_prop_compras")
	**

	f_select("select * from produtos_precos where produto = ?tmpProdutos1.produto and codigo_tab_preco='AT'","cur_preco_venda")


	WITH oExcel && objeto publico passado de parametro para esta fun√ß√£o
		IF lnSheet = 0
			.Sheets(1).Name = ALLTRIM(tmpProdutos1.PRODUTO) &&ALLTRIM(v_compras_01.pedido)
		ELSE
			***
			* {Paulo Devid√© - 20-07-15}
			*/
			IF .Sheets.Count>1
    			.Sheets(ALLTRIM(TRANSFORM(lnSheet,"9999"))).Select
    		ELSE
	    		.Sheets("matriz").Select
    		ENDIF
		    .ActiveSheet.Name = ALLTRIM(tmpProdutos1.PRODUTO) &&ALLTRIM(v_compras_01.pedido)
		ENDIF

		m.request_no = v_compras_01.pedido
		m.article_no = tmpProdutos1.PRODUTO &&v_compras_01_produtos.produto

		m.buyer = ALLTRIM(NVL(cur_filial40.buyer,''))
		m.adress = ALLTRIM(NVL(cur_filial40.adress,''))
		m.zip_code = TRANSFORM(ALLTRIM(NVL(cur_filial40.zip_code,'')),"@R 99999-999")
		m.cnpj = TRANSFORM(ALLTRIM(NVL(cur_filial40.cnpj,'')),"@R 99.999.999/9999-99")

		m.collection1 = ALLTRIM(NVL(cur_colecao.desc_colecao,''))
		m.depto = v_compras_01_produtos.griffe
		m.line1 = v_compras_01_produtos.linha
		m.composition = ALLTRIM(NVL(cur_composicao.desc_composicao,''))
		m.type1 = ALLTRIM(NVL(cur_produtos.tipo_produto,''))

		** CUPS --> Propriedade 00068 √© AGORA produtos.ERP_CUPS_STYLENUMBER
		*m.supp_ref = NVL(LOOKUP(cur_prop_compras.valor_propriedade,'00068',cur_prop_compras.propriedade),'') &&ALLTRIM(NVL(cur_produtos.REFER_FABRICANTE,''))
		m.supp_ref = ALLTRIM(NVL(cur_produtos.ERP_CUPS_STYLENUMBER,'')) &&+ "/A"

		m.sizes = ALLTRIM(NVL(cur_produtos.grade,''))
		** PAULO DEVIDE --> 06/10/2014
		**m.supp_ref = ALLTRIM(NVL(cur_produtos.REFER_FABRICANTE,''))

*!*			m.cust_fob = STRTRAN(ALLTRIM(NVL(LOOKUP(cur_prop_compras.valor_propriedade,'00030',cur_prop_compras.propriedade),'')),",",".")
*!*			m.cust_fob = CAST(m.cust_fob as numeric(14,2))

		m.amount = '=H17*M17'
		m.sales_price = cur_preco_venda.preco1 &&V_COMPRAS_01_PRODUTOS.custo1
		
		m.profoma_invoice = v_compras_01.ERP_CUPS_CONTRATO &&NVL(LOOKUP(cur_prop_compras.valor_propriedade,'00028',cur_prop_compras.propriedade),'')
		
		** PROJETO CUPS - MUDOU PARA CAMPO COMPRAS.ERP_CUPS_EMBARQUE_ATUAL
		** m.shipment_date = NVL(LOOKUP(cur_prop_compras.valor_propriedade,'00029',cur_prop_compras.propriedade),'')
		SET CENTURY ON
		SET DATE BRITISH
		m.shipment_date = v_compras_01.ERP_CUPS_DATA_ACORDADA &&DTOC(v_compras_01.ERP_CUPS_DATA_ACORDADA) &&DTOC(v_compras_01.ERP_CUPS_EMBARQUE_ATUAL)
		
		IF NOT EMPTY(m.shipment_date)
			** Data convertida para formato num√©rico do Excel
			m.shipment_date = (Val(Sys(11, NVL(m.shipment_date,CTOD("")))) - Val(Sys(11, {30/12/1899})))
		ENDIF

*!*			m.packs_of = NVL(LOOKUP(cur_prop_compras.valor_propriedade,'00031',cur_prop_compras.propriedade),0)
*!*			m.quantity_of_packs = NVL(LOOKUP(cur_prop_compras.valor_propriedade,'00032',cur_prop_compras.propriedade),0)

		** Cursor detalhe (itens do pedido)
		IF USED("cur_itens_pedido")
			SELECT cur_itens_pedido
			USE
		ENDIF

		CREATE CURSOR cur_itens_pedido ( ;
			PRODUTO C(12) NULL,;
			INDICE INT NULL,;
			CODIGO_BARRA C(25) NULL,;
			DESCRICAO C(40) NULL,;
			COR C(40) NULL,;
			TAMANHO C(8) NULL,;
			QTD INT NULL )


		SELECT produto,SUM(qtde_original) as qtde_original ;
		FROM v_compras_01_produtos WITH (BUFFERING=.T.) ;
		WHERE PRODUTO = tmpProdutos1.PRODUTO ;
		GROUP BY produto INTO CURSOR vtotal_produto1
		
					
		SELECT v_compras_01_produtos
		LOCATE FOR PRODUTO = tmpProdutos1.PRODUTO
		
		*GO top 

		** PROJETO CUPS --> agora pega no item do pedido
		m.cust_fob = v_compras_01_produtos.ERP_CUPS_CUSTO_FOB

		SELECT vtotal_produto1
		LOCAL lnCont as Integer
		m.quantity_of_packs = 0

		DIMENSION laBarCode[3,2]
		laBarCode[1,1] = NVL(cur_produtos.ERP_CUPS_CODEBAR_REF,'')
		laBarCode[2,1] = NVL(cur_produtos.ERP_CUPS_CODEBAR_PB,'')
		laBarCode[3,1] = NVL(cur_produtos.ERP_CUPS_CODEBAR_CX,'')
		**------------------------------------------------------------------**
		*** Pega o Pack total agrupado do produto - Paulo Devide -> 20-07-2015
		lnArea = SELECT()
		SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL
		LOCATE FOR produto = v_compras_01_produtos.produto
		SELECT (lnArea)
		
		laBarCode[1,2] = 0 &&V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.qtde &&v_compras_01_produtos.ERP_CUPS_PACKS_POR_CAIXA * vtotal_produto1.qtde_original 
		laBarCode[2,2] = 0 &&vtotal_produto1.qtde_original
		laBarCode[3,2] = 0 &&IIF(v_compras_01_produtos.ERP_CUPS_PACKS_POR_CAIXA>0,CEILING(vtotal_produto1.qtde_original / v_compras_01_produtos.ERP_CUPS_PACKS_POR_CAIXA),0)
		
		lcDescr_Peca = "Piece;Master Polybag;Carton"

		FOR lnCont=1 TO 3

				SELECT cur_itens_pedido
				APPEND BLANK
				REPLACE PRODUTO WITH vtotal_produto1.produto
				REPLACE INDICE WITH lnCont
				REPLACE CODIGO_BARRA WITH laBarCode[lnCont,1]
				REPLACE DESCRICAO WITH ALLTRIM(cur_Produtos.DESC_PRODUTO)
				REPLACE COR WITH GETWORDNUM(lcDescr_Peca,lnCont,";")
				REPLACE TAMANHO WITH ''
				REPLACE QTD WITH laBarCode[lnCont,2]


		ENDFOR

		m.packs_of = V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.qtde &&v_compras_01_produtos.ERP_CUPS_PACKS_POR_CAIXA 
		IF V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.qtde>0
			m.quantity_of_packs = vtotal_produto1.QTDE_ORIGINAL / V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.qtde &&m.quantity_of_packs + v_compras_01_produtos.QTDE_ORIGINAL
		ELSE
			m.quantity_of_packs = 0
		ENDIF

		
*!*			IF m.packs_of>0
*!*				m.quantity_of_packs = m.quantity_of_packs/m.packs_of
*!*			ELSE
*!*				m.quantity_of_packs = 0
*!*			ENDIF
		
		
		SELECT cur_itens_pedido
*!*			INDEX on PRODUTO+COR+STR(INDICE,2,0) TAG IND01
		INDEX on PRODUTO+STR(INDICE,2,0) TAG IND01
		SET ORDER TO TAG IND01
		GO TOP

		.range("N2").value = m.request_no
		.range("N4").value = m.article_no

		.range("C8").value = m.buyer
		.range("C9").value = m.adress
		.range("C11").value = m.zip_code
		.range("C12").value = m.cnpj

		.range("C15").value = m.collection1
		.range("C16").value = m.depto
		.range("C17").value = m.line1
		.range("C18").value = m.composition
		.range("C19").value = m.type1

		.range("H15").value = m.sizes
		.range("H16").value = m.supp_ref
		.range("H17").value = m.cust_fob
		.range("H18").value = m.amount
		.range("H19").value = m.sales_price

		.range("M15").value = m.profoma_invoice
		.range("M16").value = m.shipment_date
		.range("M17").value = m.packs_of
		.range("M18").value = m.quantity_of_packs

    	.Range("L19").value = "Order:"
	    .Range("L19").Select
	    .Selection.Font.Bold = .t.
    	.Range("N19").value = "WHOLESALE" && atacado

		*** Formata√ß√£o dos Itens do Pedido
		IF RECCOUNT("cur_itens_pedido")>0

			lnLinha = 24
			FOR lnRec = 1 TO RECCOUNT("cur_itens_pedido")
				.Rows("24:24").Select
				.Selection.Copy
				lcLinha = ALLTRIM(TRANSFORM(lnLinha+lnRec,"9999"))
				.Rows(lcLinha+":"+lcLinha).Select
				.Selection.Insert(-4121)
			ENDFOR

			SELECT cur_itens_pedido
			SCAN

				lcLinha = ALLTRIM(TRANSFORM(lnLinha,"9999"))
				.range("B"+lcLinha).value = "'"+ALLTRIM(NVL(cur_itens_pedido.CODIGO_BARRA,''))
				.range("D"+lcLinha).value = ALLTRIM(NVL(cur_itens_pedido.DESCRICAO,''))
				.range("I"+lcLinha).value = ALLTRIM(NVL(cur_itens_pedido.COR,''))
				.range("L"+lcLinha).value = ALLTRIM(NVL(cur_itens_pedido.TAMANHO,''))
				.range("N"+lcLinha).value = '' &&cur_itens_pedido.QTD

				lnLinha = lnLinha + 1
			ENDSCAN

			lcLinhaFormula = ALLTRIM(CAST(24+RECCOUNT("cur_itens_pedido")+3 as char(4)))
			.Range("N"+lcLinhaFormula).Select
			.ActiveCell.FormulaR1C1 = '' &&"=SUM(R[-"+ALLTRIM(TRANSFORM(RECCOUNT("cur_itens_pedido")+3,"9999"))+"]C:R[-4]C)"
			.Range("K"+lcLinhaFormula).value = ''
			
			lnQtdTotal = CAST(.Range("N"+lcLinhaFormula).Value as Int)
			.range("H18").value = m.cust_fob * lnQtdTotal

			lcLinhaFormula = ALLTRIM(CAST(24+RECCOUNT("cur_itens_pedido")+6 as char(4)))
			.Range("B"+lcLinhaFormula).value = ALLTRIM(v_compras_01.obs)
		ENDIF

		.range("A1").select
		.ActiveWorkbook.Save

	ENDWITH

	SELECT v_compras_01_produtos
	GO top

ENDFUNC



***
* Fun√ß√£o para obter o PageIndex para manipular o objeto ActivePage
*/
FUNCTION getPageIndex
PARAMETERS objTelaPai, tcCaption
	LOCAL liPageIndex as Integer
	liPageIndex = 1
	TRY 
		FOR EACH loPage IN objTelaPai.lx_form1.lx_pageframe1.pages
			IF LOWER(tcCaption) $ LOWER(loPage.caption)
				liPageIndex = loPage.pageorder
			ENDIF
		ENDFOR
		
	CATCH TO oErro1
		MESSAGEBOX(oErro1.message,16,"Aviso")
	ENDTRY
	RETURN liPageIndex
ENDFUNC


******************************************************************************************************************************************************
******************** DEFINE DE OBJETOS DA CLASSE *****************************************************************************************************
******************************************************************************************************************************************************

DEFINE CLASS cmbRequeridoPor as lx_ComboBox
	top = 69
	left = 122
	height = 19
	width = 225
	controlsource = "V_COMPRAS_01.REQUERIDO_POR"
	rowsourcetype = 5
	rowsource = [ZZ_LISTA_GERENTES]
	
	PROCEDURE refresh
		this.Visible= .F.
		IF INLIST(thisformset.p_tool_status,"I","A")
			this.Visible= .T.
		ENDIF
	ENDPROC
	
	
ENDDEFINE


DEFINE CLASS lblCopiarData as label
	left = 477
	MousePointer = 15
	width = 300
	Forecolor = RGB(0,0,255)
	FontBold = .t.
	top = 169
	Caption = "Clique para Copiar as Datas do Pedido Original"
	BackStyle = 0 && transparente
	FontUnderline = .t.
	
	PROCEDURE click
		cPedido = THISFORMSET.PEDIDO_ORIGINAL_COPIA
		IF EMPTY(cPedido)
			MESSAGEBOX("Esta n„o È uma cÛpia de pedido! OperaÁ„o n„o permitida!",64,"Aviso")
			RETURN 
		ENDIF
		IF !(ThisFormSet.p_Tool_Status="I")
			MESSAGEBOX("Esta OperaÁ„o È permitida somente para Inclus„o de Pedidos!",64,"Aviso")
			RETURN 
		ENDIF
		** Puxa as datas de entrega/limite entrega do pedido origem **
		f_select("select pedido, entrega, limite_entrega from compras_produto where pedido = ?cPedido","tmpComprasProduto") 
		Select v_Compras_01_Produtos
		
		tcEntrega = TTOD(tmpComprasProduto.entrega)
		tcLimite_entrega = TTOD(tmpComprasProduto.limite_entrega)
		THISFORMSET.PX_ENTREGA.value = tcEntrega
		THISFORMSET.PX_LIMITE_ENTREGA.value = tcLimite_entrega
		replace ALL entrega WITH tcEntrega, limite_entrega WITH tcLimite_entrega
		GO top		

	ENDPROC
	
ENDDEFINE


***
* Bot√£o para chamar a tela para excluir produto/pack
*/
DEFINE CLASS cmdAtualizaCabilog AS CommandButton

	Height = 34
	Left = 18
	Top = 170
	Width = 185
	Name = "cmdAtualizaCabilog"
	caption = "Atualizar Dados"
	wordwrap = .t.
	
	objTelaPai = .f.
	objLista = .f.
	
	PROCEDURE init
		
		PARAMETERS oThisformSet
		this.objTelaPai = oThisformSet
*!*			WITH this.objTelaPai
*!*				this.objLista = .lx_form1.lx_pageframe1.pgCabilog.lstCabilogAviso1
*!*			ENDWITH
		
	ENDPROC
	
	PROCEDURE when
		RETURN .t.		
	ENDPROC

	PROCEDURE click
		WAIT WINDOW NOWAIT "Atualizando..."
		
		*** mudou do Activate da page para ca, pois estava dando erro no evento
		IF Inlist(Thisformset.p_Tool_Status, "A","I")
			SELECT v_Compras_01
			IF EMPTY(NVL(v_Compras_01.ERP_CAB_CD_ENTREGA,""))	
				replace v_Compras_01.ERP_CAB_CD_ENTREGA WITH "64"
			ENDIF
			IF EMPTY(NVL(v_Compras_01.ERP_CAB_LOCALIZACAO,""))
				replace v_Compras_01.ERP_CAB_LOCALIZACAO WITH "PAREDE"
			ENDIF
			IF EMPTY(NVL(v_Compras_01.ERP_CAB_TIPO_PEDIDO,""))
				replace v_Compras_01.ERP_CAB_TIPO_PEDIDO WITH "NORMAL"
			ENDIF	
			
			IF NVL(v_Compras_01.ERP_CAB_ENCABIDADO,.F.)=.F.
				replace v_Compras_01.ERP_CAB_ENCABIDADO WITH .F.
			ENDIF
			
		ENDIF	
		***
		* Limpa o Listbox de avisos de erros
		*/		
		ADICIONA_ERRO(ThisFormSet.lx_form1.lx_pageframe1.pgCabilog.lstCabilogAviso1, "", .T.) 
		*==========================================================
		
		lcMsg = ""
		lcEnter = CHR(13)
		llRet = .T.
		
		***IF v_Compras_01.ERP_CAB_ENCABIDADO && se estiver clicado, valida os campos obrigat√≥rios
		** OP√á√ïES DO CAMPO v_Compras_01.ERP_CAB_OPCAO:
		**	1 = "Nenhum"
		**	2 = "S√≥ Encabidado"
		**	3 = "S√≥ Alarme"
		**	4 = "Encabidado + Alarme"
		IF NVL(v_Compras_01.ERP_CAB_OPCAO,0) > 1 && se estiver clicado, valida os campos obrigat√≥rios

			IF INLIST(NVL(v_Compras_01.ERP_CAB_OPCAO,0),2,4)		
				IF EMPTY(NVL(v_Compras_01.ERP_CAB_COD_CABIDE,""))
					lcMsg = lcEnter + lcMsg + "ObrigatÛrio preencher o cÛdigo do Cabide (Aba - Cabilog)"+lcEnter
					
					***
					* Adiciona uma linha no Listbox com Aviso de erro
					*/
					lcAviso = "ObrigatÛrio preencher o cÛdigo do Cabide (Aba - Cabilog)"
					ADICIONA_ERRO(ThisFormSet.lx_form1.lx_pageframe1.pgCabilog.lstCabilogAviso1, lcAviso , .f.)
					
					llRet = .f.
				ENDIF
			ENDIF
			
			** VERIFICA SE O C√ìDIGO DO ALARME FOI PREENCHIDO CONFORME FAIXA DE VALOR 
			** RETORNADO PELA FUNCAO F_FAIXA_VALOR_CABILOG()
			** AT√â 14,99 ISENTO, CAMPO TEM QUE ESTAR EM BRANCO
			** DE 15,00 AT√â 79,99 - CAMPO TEM QUE ESTAR PREENCHIDO COM VALOR = "E1"
			** ACIMA DE 80,00 - CAMPO TEM QUE ESTAR PREENCHIDO COM VALOR = "E2"
			
			IF INLIST(NVL(v_Compras_01.ERP_CAB_OPCAO,0),3,4)
				IF ALLTRIM(NVL(v_Compras_01.ERP_CAB_COD_BOLACHA,"")) <> F_FAIXA_VALOR_CABILOG()
					lcMsg = lcEnter + lcMsg + "VALOR do campo cÛdigo do alarme est· com divergÍncia (Aba - Cabilog)"+lcEnter

					***
					* Adiciona uma linha no Listbox com Aviso de erro
					*/
					lcAviso ="VALOR do campo cÛdigo do alarme est· com divergÍncia (Aba - Cabilog)"
					ADICIONA_ERRO(ThisFormSet.lx_form1.lx_pageframe1.pgCabilog.lstCabilogAviso1, lcAviso , .f.)

					llRet = .f.
				ENDIF
			ENDIF

			IF EMPTY(NVL(v_Compras_01.ERP_CAB_CD_ENTREGA,""))
				lcMsg = lcEnter + lcMsg + "ObrigatÛrio preencher o CÛdigo do CD Entrega  (Aba - Cabilog)" + lcEnter

				***
				* Adiciona uma linha no Listbox com Aviso de erro
				*/
				lcAviso ="ObrigatÛrio preencher o CÛdigo do CD Entrega  (Aba - Cabilog)" 
				ADICIONA_ERRO(ThisFormSet.lx_form1.lx_pageframe1.pgCabilog.lstCabilogAviso1, lcAviso , .f.)

				llRet = .f.
			ENDIF
			
			IF EMPTY(NVL(v_Compras_01.ERP_CAB_LOCALIZACAO,""))
				lcMsg = lcEnter + lcMsg + "ObrigatÛrio preencher a LocalizaÁ„o Cabide  (Aba - Cabilog)" + lcEnter

				***
				* Adiciona uma linha no Listbox com Aviso de erro
				*/
				lcAviso ="ObrigatÛrio preencher a LocalizaÁ„o Cabide (Aba - Cabilog)"
				ADICIONA_ERRO(ThisFormSet.lx_form1.lx_pageframe1.pgCabilog.lstCabilogAviso1, lcAviso , .f.)
				
				llRet = .f.
			ENDIF
			
			IF EMPTY(NVL(v_Compras_01.ERP_CAB_TIPO_PEDIDO,""))
				lcMsg = lcEnter + lcMsg + "ObrigatÛrio preencher o Tipo de Pedido  (Aba - Cabilog)" + lcEnter

				***
				* Adiciona uma linha no Listbox com Aviso de erro
				*/
				lcAviso ="ObrigatÛrio preencher o Tipo de Pedido  (Aba - Cabilog)"
				ADICIONA_ERRO(ThisFormSet.lx_form1.lx_pageframe1.pgCabilog.lstCabilogAviso1, lcAviso , .f.)

				llRet = .f.
			ENDIF
		ELSE
			MESSAGEBOX("Check CABILOG n„o selecionado!"+CHR(13)+"Dados n„o atualizados!",64,"Aviso")	
			RETURN 	
		ENDIF
		
		IF NOT llRet
			** N√£o exibe mais o messagebox, agora mostra os erros no listbox na aba cabilog
			*MESSAGEBOX(lcMsg,16,"Aviso")
			ThisFormSet.lx_form1.lx_pageframe1.pgCabilog.lstCabilogAviso1.refresh
			RETURN 
		ENDIF

		lcCab_Status = "M"
		llData_Envio = .f.

		SELECT v_Compras_01
		thisformset.lx_form1.lx_pageframe1.Page1.ACTIVATE()
				
		DO CASE
			CASE ThisformSet.p_Tool_Status="A"		&& ATUALIZA PROPRIEDADE CAB_STATUS PARA 'M'

				IF RECCOUNT("V_COMPRAS_01_CANCELAMENTO")>0
				
					IF NOT EMPTY(NVL(v_Compras_01.ERP_CAB_DATA_ENVIO,CTOD("")))
						lcCab_Status = "C" && pedido cancelado
						llData_Envio = .t.
					ELSE
						lcCab_Status = "A" && pedido cancelado
					ENDIF
					

				ELSE
				
					IF NOT EMPTY(NVL(v_Compras_01.ERP_CAB_DATA_ENVIO,CTOD("")))
						lcCab_Status = "M" && pedido Ok!
						llData_Envio = .t.
					ELSE
						*lcCab_Status = "A" && pedido Ok!
					ENDIF

				ENDIF


				REPLACE v_Compras_01.ERP_CAB_STATUS WITH lcCab_Status
				replace v_Compras_01.ERP_CAB_QTDPECAS with ;
					CEILING(v_Compras_01.TOT_QTDE_ORIGINAL * (ThisformSet.pp_porcentagem_qtd_cabides/100)) 
				
				IF llData_Envio && grava NULL na data de envio para poder enviar arquivo novamente para a CABILOG
					replace v_compras_01.ERP_CAB_DATA_ENVIO WITH CTOD("")
				ENDIF
				
				
			CASE ThisformSet.p_Tool_Status="I"		&& ATUALIZA PROPRIEADE CAB_STATUS PARA 'A'

				IF RECCOUNT("V_COMPRAS_01_CANCELAMENTO")>0
					IF NOT EMPTY(NVL(v_Compras_01.ERP_CAB_DATA_ENVIO,CTOD("")))
						lcCab_Status = "C" && pedido cancelado
						llData_Envio = .t.
					ELSE
						lcCab_Status = "A" && pedido cancelado
					ENDIF

				ELSE
					lcCab_Status = "A" && pedido Ok!

				ENDIF

				
				lnQtdOrig = v_Compras_01.TOT_QTDE_ORIGINAL 
				lnQtdEncabidados = CEILING( lnQtdOrig * (ThisformSet.pp_porcentagem_qtd_cabides/100)) 

				REPLACE v_Compras_01.ERP_CAB_STATUS WITH lcCab_Status
				replace v_Compras_01.ERP_CAB_QTDPECAS with lnQtdEncabidados

				IF llData_Envio && grava NULL na data de envio para poder enviar arquivo novamente para a CABILOG
					replace v_compras_01.ERP_CAB_DATA_ENVIO WITH CTOD("")
				ENDIF


			OTHERWISE

		ENDCASE
		This.Parent.Refresh		
		WAIT WINDOW "OK!" TIMEOUT 1
		
	ENDPROC
	
	PROCEDURE refresh
		** Inclus√£o/Altera√ß√£o/Exclus√£o/Tela (L)impa/(P)esquisa Feita!
		this.enabled = INLIST(ThisFormSet.p_Tool_Status,"I","A")
	ENDPROC
	
ENDDEFINE

DEFINE CLASS lstCabilogAviso AS ListBox
	Height = 184
	Left = 18
	Top = 210
	Width = 485
	Name = "lstCabilogAviso"
	
	objTelaPai = .f.
	
	PROCEDURE init
		
		PARAMETERS oThisformSet
		this.objTelaPai = oThisformSet
					
	ENDPROC
	
	PROCEDURE when
		RETURN .t.		
	ENDPROC

ENDDEFINE


DEFINE CLASS lblTotPercentDistrib AS Label
	Autosize = .t.
	Left = 5
	Top = 376
	Caption = "% Distrib."
	Name = "lblTotPercentDistrib1"
	BackStyle= 0
ENDDEFINE

DEFINE CLASS lblTotQtdDistrib AS Label
	Autosize = .t.
	Left = 5
	Top = 400
	Caption = "Qtd. Distrib."
	Name = "lblTotQtdDistrib1"
	BackStyle= 0
ENDDEFINE

** CAMPO PARA INFORMAR TOTAL QTDE A DISTRIBUIR DO PEDIDO
DEFINE CLASS txtTotQtdDistrib AS lx_textbox_base
	Height = 21
	Left = 80
	Top = 400
	Width = 84
	ReadOnly = .T.
	Name = "txtTotQtdDistrib1"
	ControlSource = "v_compras_01.ERP_TOTAL_QTD_DISTRIB"
	p_tipo_dado = "MOSTRA"

	PROCEDURE when
		RETURN .F. 
	ENDPROC
ENDDEFINE

** CAMPO PARA INFORMAR PERCENTUAL A DISTRIBUIR DO PEDIDO
DEFINE CLASS txtTotPercentDistrib AS lx_textbox_base
	Height = 21
	Left = 80
	Top = 376
	Width = 84
	Name = "txtTotPercentDistrib1"
	InputMask = "999.999999"
	ControlSource = "v_compras_01.ERP_PERCENT_DISTRIB"
	p_tipo_dado = "EDITA"

	PROCEDURE when
			lnArea = SELECT()
			IF USED("tmpPackPedido1")
				SELECT tmpPackPedido1
				USE
			ENDIF
			
			TEXT TO lcSQL NOSHOW TEXTMERGE PRETEXT 7
				select distinct b.pack
				from compras_produto a
				left join produtos_packs_permitidos b on b.produto = a.produto
				where a.produto = ?v_compras_01_produtos.produto
			ENDTEXT
			
			F_SELECT(lcSQL, "tmpPackPedido1")
			SELECT (lnArea)			
			
*!*				IF RECCOUNT("tmpPackPedido1")>1
*!*					MESSAGEBOX("Distribui√ß√£o n√£o permitida para WMS, pois produto "+CHR(13)+;
*!*								"tem packs diferentes cadastrados!",64, "Aviso")
*!*					RETURN .f.
*!*				ENDIF
			
			IF UPPER(ALLTRIM(v_compras_01.TIPO_COMPRA)) = "CATALOGO"
				MESSAGEBOX("DistribuiÁ„o n„o permitida para WMS, " +CHR(13)+;
							"pois produto È de CATALOGO!",64, "Aviso")
				RETURN .f.
			ENDIF
	ENDPROC
	

	PROCEDURE valid
		IF INLIST(ThisFormSet.p_Tool_Status,"I","A")

			lnTamanhoPack = V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.qtde
			lnQtdeOriginal = v_compras_01.TOT_QTDE_ORIGINAL
			lnQtdCaixas = lnQtdeOriginal / lnTamanhoPack
			
			lnQtdDistrib = INT((this.Value/100) * lnQtdCaixas)
			
			**replace v_compras_01.ERP_TOTAL_QTD_DISTRIB WITH INT((this.Value/100) * v_compras_01.ERP_TOTAL_CAIXAS_ORIGINAL)
			**replace v_compras_01.ERP_TOTAL_QTD_DISTRIB WITH lnQtdDistrib
			
			this.Parent.txtTotQtdDistrib1.Value = lnQtdDistrib
			this.Parent.txtTotQtdDistrib1.refresh
		ENDIF
			
		RETURN .T. 
	ENDPROC

ENDDEFINE

** Checkbox Importado
DEFINE CLASS ck_importado AS lx_checkbox
	Height = 21
	Left = 610
	Top = 406
	Width = 125
	Alignment = 0
	FontBold = .T.
	Caption = "  Importado"
	Name = "ck_importado1"
	ControlSource = "v_compras_01.ERP_IMPORTADO"
	p_tipo_dado = "EDITA"
ENDDEFINE

DEFINE CLASS ck_distribuicao AS lx_checkbox
	Height = 21
	Left = 40
	Top = 335
	Width = 125
	Alignment = 0
	FontBold = .T.
	Caption = "  DistribuiÁ„o"
	Name = "ck_distribuicao"
	ControlSource = "v_compras_01.ERP_DISTRIBUICAO"
	p_tipo_dado = "EDITA"
ENDDEFINE

DEFINE CLASS ck_manual AS lx_checkbox
	Height = 21
	Left = 40
	Top = 350
	Width = 125
	Alignment = 0
	FontBold = .T.
	Caption = "  Manual"
	Name = "ck_manual"
	ControlSource = "v_compras_01.ERP_MANUAL"
	p_tipo_dado = "EDITA"
ENDDEFINE

DEFINE CLASS ck_liberado_cq AS lx_checkbox
	Height = 21
	Left = 180
	Top = 335
	Width = 125
	Alignment = 0
	FontBold = .T.
	Caption = "  Liberado CQ"
	Name = "ck_liberado_cq"
	ControlSource = "v_compras_01.ERP_LIBERADO_CQ"
	p_tipo_dado = "EDITA"
ENDDEFINE

DEFINE CLASS ck_faturado AS lx_checkbox
	Height = 21
	Left = 180
	Top = 350
	Width = 125
	Alignment = 0
	FontBold = .T.
	Caption = "  Faturado"
	Name = "ck_faturado"
	ControlSource = "v_compras_01.ERP_FATURADO"
	p_tipo_dado = "EDITA"
ENDDEFINE

** Combobox de Moeda
DEFINE CLASS cbo_moeda AS lx_combobox
	Height = 21
	Left = 340
	Top = 80
	Width = 84
	Name = "cbo_moeda1"

	RowSourceType = 1
	RowSource = ZZ_LISTA_MOEDAS

	ControlSource = "v_compras_01.ERP_MOEDA"
	p_tipo_dado = "EDITA"
ENDDEFINE

** Page de objetos de Importa√ß√£o
DEFINE CLASS cPageAtacado as Page

	caption = "Importado"
	PROCEDURE Activate
		thisform.refresh
	ENDPROC
	
ENDDEFINE

** Page de objetos de Importa√ß√£o
DEFINE CLASS cPageCabilog as Page

	caption = "Cabilog"
	PROCEDURE Activate
	
		IF .f. AND Inlist(Thisformset.p_Tool_Status, "A","I")
			
			IF EMPTY(NVL(v_Compras_01.ERP_CAB_CD_ENTREGA,""))	
				replace v_Compras_01.ERP_CAB_CD_ENTREGA WITH "64"
			ENDIF
			IF EMPTY(NVL(v_Compras_01.ERP_CAB_LOCALIZACAO,""))
				replace v_Compras_01.ERP_CAB_LOCALIZACAO WITH "PAREDE"
			ENDIF
			IF EMPTY(NVL(v_Compras_01.ERP_CAB_TIPO_PEDIDO,""))
				replace v_Compras_01.ERP_CAB_TIPO_PEDIDO WITH "NORMAL"
			ENDIF	
			
			IF NVL(v_Compras_01.ERP_CAB_ENCABIDADO,.F.)=.F.
				replace v_Compras_01.ERP_CAB_ENCABIDADO WITH .F.
			ENDIF
			
		ENDIF

		THIS.LABEL1.Caption = NVL(v_Compras_01.ERP_CAB_STATUS,"nulo")

		this.refresh()	
	
	ENDPROC
	
ENDDEFINE

** Page de objetos de Erros/Avisos
DEFINE CLASS cPageWarning as Page

	caption = "Avisos"
	PROCEDURE Activate
		thisform.refresh
	ENDPROC
	
ENDDEFINE

** Page de GRIDs pack e pack total
DEFINE CLASS cPagePack as Page

	caption = "PACK"
	
	ADD OBJECT lx_grid_filha1 AS lx_grid_filha WITH ;
		ColumnCount = 4, ;
		Height = 200, ;
		Left = 10, ;
		Panel = 1, ;
		RecordSource = "V_CAEDU_COMPRAS_PRODUTOS_PACKS", ;
		Top = 10, ;
		Width = 800, ;
		p_manter_baixo = .F., ;
		p_manter_cima = .F., ;
		p_manter_direita = .F., ;
		p_manter_esquerda = .F., ;
		p_mostra_botao_excluir = .T., ;
		p_mostra_botao_incluir = .T., ;
		p_mostra_botao_soma = .F., ;
		p_mostrar_tool_grid = .T., ;
		Name = "Lx_grid_filha1", ;
		Column1.FontName = "Tahoma", ;
		Column1.FontSize = 8, ;
		Column1.ColumnOrder = 1, ;
		Column1.ControlSource = "V_caedu_compras_produtos_packs.PRODUTO", ;
		Column1.Width = 84, ;
		Column1.Sparse = .F., ;
		Column1.Name = "COL_TX_PRODUTO", ;
		Column2.FontName = "Tahoma", ;
		Column2.FontSize = 8, ;
		Column2.ColumnOrder = 2, ;
		Column2.ControlSource = "V_caedu_compras_produtos_packs.COR_PRODUTO", ;
		Column2.Width = 70, ;
		Column2.Sparse = .F., ;
		Column2.Name = "COL_TX_COR_PRODUTO", ;
		Column3.FontName = "Tahoma", ;
		Column3.FontSize = 8, ;
		Column3.ColumnOrder = 3, ;
		Column3.ControlSource = "V_caedu_compras_produtos_packs.DESC_COR_PRODUTO", ;
		Column3.Width = 102, ;
		Column3.Sparse = .F., ;
		Column3.Name = "COL_TX_DESC_COR_PRODUTO", ;
		Column4.FontName = "Tahoma", ;
		Column4.FontSize = 8, ;
		Column4.ColumnOrder = 4, ;
		Column4.ControlSource = "V_caedu_compras_produtos_packs.QTDE", ;
		Column4.Width = 600, ;
		Column4.Sparse = .F., ;
		Column4.Name = "COL_LX_GRADE48_QTDE"
		
	PROCEDURE lx_grid_filha1.init

		IF DODEFAULT()
			this.columns(1).Header1.Caption = "Produto"	
			this.columns(2).Header1.Caption = "Cor"	
			this.columns(3).Header1.Caption = "Descri√ß√£o Cor"	
			this.columns(4).Header1.Caption = "PACK"	

			this.columns(1).ReadOnly = .t.
			this.columns(2).ReadOnly = .t.
			this.columns(3).ReadOnly = .t.
			this.columns(4).ReadOnly = .t.

			this.columns(4).AddObject("lx_grade48_qtde","lx_grade48_qt")
			this.columns(4).CurrentControl = "lx_grade48_qtde"
			
			WITH this.columns(4).lx_grade48_qtde
				.visible = .t.
			ENDWITH
			
		ENDIF
		
	ENDPROC

	ADD OBJECT lx_grid_filha2 AS lx_grid_filha WITH ;
		ColumnCount = 2, ;
		Height = 128, ;
		Left = 10, ;
		Panel = 1, ;
		RecordSource = "V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL", ;
		Top = 223, ;
		Width = 800, ;
		p_mostra_botao_detalhe = .F., ;
		p_mostrar_tool_grid = .T., ;
		p_mostra_botao_soma = .F., ;
		p_mostra_botao_incluir = .T., ;
		p_mostra_botao_excluir = .T., ;
		p_manter_esquerda = .F., ;
		p_manter_direita = .F., ;
		p_manter_cima = .F., ;
		p_manter_baixo = .F., ;
		Name = "Lx_grid_filha2", ;
		Column1.FontName = "Tahoma", ;
		Column1.FontSize = 8, ;
		Column1.ColumnOrder = 1, ;
		Column1.ControlSource = "V_caedu_compras_produtos_packs_total.PRODUTO", ;
		Column1.Width = 258, ;
		Column1.Sparse = .F., ;
		Column1.Name = "COL_TX_PRODUTO", ;
		Column2.FontName = "Tahoma", ;
		Column2.FontSize = 8, ;
		Column2.ColumnOrder = 2, ;
		Column2.ControlSource = "V_caedu_compras_produtos_packs_total.QTDE", ;
		Column2.Width = 600, ;
		Column2.Sparse = .F., ;
		Column2.Name = "COL_LX_GRADE48_QTDE"

	
	PROCEDURE Activate
		this.lx_grid_filha1.AfterRowColChange	
		this.lx_grid_filha2.AfterRowColChange	
		thisform.refresh
	ENDPROC
	
	PROCEDURE lx_grid_filha2.init

		IF DODEFAULT()
			this.columns(1).Header1.Caption = "Produto"	
			this.columns(2).Header1.Caption = "PACK"	

			this.columns(1).ReadOnly = .t.
			this.columns(2).ReadOnly = .t.

			this.columns(2).AddObject("lx_grade48_qtde","lx_grade48_qt2")
			this.columns(2).CurrentControl = "lx_grade48_qtde"
			
			WITH this.columns(2).lx_grade48_qtde
				.visible = .t.
			ENDWITH
			
		ENDIF
		
	ENDPROC

	PROCEDURE lx_grid_filha1.AfterRowColChange
		LPARAMETERS ncolindex
		this.col_LX_GRADE48_QTDE.lx_GRADE48_QTDE.l_grade(.t.)
	ENDPROC

	PROCEDURE lx_grid_filha2.AfterRowColChange
		LPARAMETERS ncolindex
		this.col_LX_GRADE48_QTDE.lx_GRADE48_QTDE.l_grade(.t.)
	ENDPROC
		
ENDDEFINE

DEFINE CLASS lx_grade48_qt as lx_grade48_
	p_view = "V_CAEDU_COMPRAS_PRODUTOS_PACKS"
	p_view_campo = "Q"
	p_campo_total = "QTDE"
	p_view_grade = "v_compras_01_produtos"
	p_tipo_dado = "EDITA"
	Name = "LX_GRADE48_QTDE"
	
	PROCEDURE l_desenhista_recalculo
		lPara xPara
		Local xQtde,xS,xQtde_Ant,xQtde_Atual
		Sele V_CAEDU_COMPRAS_PRODUTOS_PACKS

		xQtde = F_Tam()
		xQtde.Carga('Q#')
		Replace Qtde With xQtde.Soma_Grade()
	ENDPROC	
ENDDEFINE

DEFINE CLASS lx_grade48_qt2 as lx_grade48_
	p_view = "V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL"
	p_view_campo = "Q"
	p_campo_total = "QTDE"
	p_view_grade = "v_compras_01_produtos"
	p_tipo_dado = "EDITA"
	Name = "LX_GRADE48_QT2"
	
	PROCEDURE l_desenhista_recalculo
		lPara xPara
		Local xQtde,xS,xQtde_Ant,xQtde_Atual
		Sele V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL

		xQtde = F_Tam()
		xQtde.Carga('Q#')
		Replace Qtde With xQtde.Soma_Grade()
	ENDPROC	
ENDDEFINE


** Shape da Data do OTB
DEFINE CLASS sh_OTB AS lx_shape
	Top = 376
	Left = 194
	Height = 40
	Width = 342
	Name = "sh_OTB1"
ENDDEFINE

** Label da Data do OTB
DEFINE CLASS lb_data_otb AS lx_label
	FontBold = .T.
	Alignment = 0
	Caption = "Data OTB:"
	Left = 204
	Top = 382
	Name = "lb_data_otb1"
ENDDEFINE

** Textbox da Data do OTB
DEFINE CLASS tx_data_otb AS lx_textbox_base
	Height = 21
	Left = 280
	Top = 382
	Width = 100
	Name = "tx_data_otb1"
	
	PROCEDURE when
		If !Inlist(Thisformset.p_Tool_Status, "A","I")
			WAIT WINDOW "AlteraÁ„o n„o permitida em modo consulta" TIMEOUT 2
			RETURN .f.
		ENDIF
		
	ENDPROC
	
ENDDEFINE

** Label de Mes nas Lojas - JIRA SI-12
DEFINE CLASS lb_mes_lojas AS lx_label
	FontBold = .T.
	Alignment = 0
	Caption = "MÍs nas Lojas:"
	Left = 204
	Top = 407
	Name = "lb_mes_lojas1"
ENDDEFINE

DEFINE CLASS cb_mes_lojas AS lx_combobox
	Height = 21
	Left = 300
	Top = 407
	Width = 100
	Name = "cb_mes_lojas1"
	rowsourcetype = 1
	rowsource = "JANEIRO,FEVEREIRO,MAR«O,ABRIL,MAIO,JUNHO,JULHO,AGOSTO,SETEMBRO,OUTUBRO,NOVEMBRO,DEZEMBRO"
	
	PROCEDURE when
		IF Thisformset.p_Tool_Status = "L" && TELA COM FILTRO LIMPO - PERMITIDO PARA NOVO FILTRO
			RETURN .T.
		ELSE
			If !Inlist(Thisformset.p_Tool_Status, "A","I") && N√O EST¡ EM MODO INSERT OU EDIT -> PROIBIDO
				WAIT WINDOW "AlteraÁ„o n„o permitida em modo consulta" TIMEOUT 2
				RETURN .f.
			ENDIF
		ENDIF
		
	ENDPROC
	
ENDDEFINE
** FIM JIRA SI-12

DEFINE CLASS btn_Recalcula as CommandButton

	Width = 105
	Top = 158
	Height = 21
	FontBold = .T.
	Left = 237
	Caption = "Recalcula Saldo"

	PROCEDURE click
		IF MESSAGEBOX("Deseja recalcular os saldos de quantidades para o PEDIDO n∫."+ALLTRIM(V_COMPRAS_01.PEDIDO)+"?",292,"Aviso")=6

			cmdsql = "exec lx_movimenta_compras_pa @PEDIDO = '"+ ALLTRIM(V_COMPRAS_01.PEDIDO) + "'"
			
			F_WAIT("Aguarde ... recalculando saldos do PEDIDO  n∫."+ALLTRIM(V_COMPRAS_01.PEDIDO))

			f_execute(cmdsql)
			
			F_WAIT()
			
			MESSAGEBOX("Processamento concluÌdo!",64,"Aviso")
			
		ENDIF
	ENDPROC

	PROCEDURE refresh
		** Inclus√£o/Altera√ß√£o/Exclus√£o/Tela (L)impa/(P)esquisa Feita!
		this.enabled = !INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L")
	ENDPROC
	
ENDDEFINE


DEFINE CLASS tv_produto as lx_textbox_valida 

	ControlSource = "V_COMPRAS_01.ERP_CAB_COD_CABIDE"
	Format = "!"
	Height = 25
	Left = 270
	Top = 150
	Width = 200
	p_valida_coluna = "PRODUTO"
	p_valida_coluna_tabela = "PRODUTOS"
	p_valida_colunas_incluir = "PRODUTOS.DESC_PRODUTO"
	p_valida_nao_existencia = .F.
	p_bloqueia_na_alteracao = .F.
	Name = "tv_produto"
	
ENDDEFINE
	

****
* DEFINI√á√ÉO CLASSE tv_contrato 
* baseado na classe fk_picklist
* PAULO DEVIDE -> 13-08-2015
*/					
DEFINE CLASS tv_contrato AS fk_picklist
	controlsource = "v_compras_01.ERP_CUPS_ID_CONTRATO"
	left = 340
	top = 110
	name = "tv_contrato1"
	descricao = "NUM_CONTRATO"
	lista_campos = "NUM_CONTRATO,ID_CONTRATO"
	tabela_valida = "CAEDU_CUPS_CONTRATOS"
	p_valida = .f.
	
	PROCEDURE m_valida
		RETURN .t.
	ENDPROC
	
	PROCEDURE tv_descricao.when
		LOCAL llOk1 as Boolean
		llOk1 = .t.
		IF Inlist(Thisformset.p_Tool_Status, "A", "I")
			llOk1 = (this.Parent.p_digita AND (v_compras_01.TOT_QTDE_ORIGINAL=v_compras_01.TOT_QTDE_ENTREGAR))
			IF (v_compras_01.TOT_QTDE_ORIGINAL <> v_compras_01.TOT_QTDE_ENTREGAR)
				MESSAGEBOX("Contrato n„o pode ser alterado, pois pedido j· foi recebido!",16,"Aviso")
			ENDIF
		ENDIF
		RETURN llOk1
	ENDPROC
	
	PROCEDURE tv_descricao.valid
		LOCAL oPesq
		IF "CONTROLES" $ SET( "ClassLib" )
			** Ok, Registry carregado
		ELSE
			SET CLASSLIB TO CONTROLES.vcx ADDITIVE
		ENDIF
						
		oPesq=CREATEOBJECT("controles.tv_valida")
		oPesq.Pesquisa(this.Value, this.parent.lista_campos, this.parent.coluna_retorno, this.parent.tabela_valida, this.Parent.pwhere, this.Parent.p_expressao)

		this.parent.descricao = oPesq.resultado_foco
		this.parent.valor = oPesq.resultado
		
		lcSQL2 = "SELECT * FROM COMPRAS WHERE ERP_CUPS_CONTRATO = '"+oPesq.resultado_foco+"' "
		lcSQL2 = lcSQL2 + " AND PEDIDO <> '"+ALLTRIM(NVL(v_compras_01.PEDIDO,""))+"' AND ERP_CUPS_SEGMENTO <> '"
		lcSQL2 = lcSQL2 + ALLTRIM(NVL(v_compras_01.ERP_CUPS_SEGMENTO,""))+"'"
		
		f_select(lcSQL2,"tmpValidaContrato")
		
		IF RECCOUNT("tmpValidaContrato")>0

			MESSAGEBOX("Este contrato j· foi utilizado em outros Pedidos com SEGMENTO diferente deste.",16,"Aviso")

		ELSE
				
			this.Parent.tv_fkey.Value = oPesq.resultado
			this.Value = oPesq.resultado_foco

			IF this.Parent.atualiza_foco
				lcTabela_controle = ALLTRIM(GETWORDNUM(this.Parent.controlSource,1,"."))
				lcCampo_controle = ALLTRIM(GETWORDNUM(this.Parent.controlSource,2,"."))
				SELECT (lcTabela_controle)
				replace &lcCampo_controle. WITH this.parent.valor
			ENDIF
		ENDIF
			
		IF RECCOUNT("tmpValidaContrato")=0

			REPLACE v_compras_01.ERP_CUPS_CONTRATO WITH ALLTRIM(NVL(this.value,''))
		
			IF v_compras_01.TOT_QTDE_ORIGINAL=v_compras_01.TOT_QTDE_ENTREGAR && pedido ainda n√£o recebido

				lcSQL1 = "select ID_CONTRATO,NUM_CONTRATO,CONDICAO_PAGAMENTO, B.DESC_COND_PGTO, B.TIPO_CONDICAO "
				lcSQL1 = lcSQL1 +" from CAEDU_CUPS_CONTRATOS A "
				lcSQL1 = lcSQL1 +" LEFT JOIN COND_ENT_PGTOS B ON B.CONDICAO_PGTO=A.CONDICAO_PAGAMENTO "
				lcSQL1 = lcSQL1 +" where ID_CONTRATO = '"+oPesq.resultado+"'"
				
				f_select(lcSQL1,"tmpCondicao1")
				
				replace v_compras_01.CONDICAO_PGTO WITH tmpCondicao1.CONDICAO_PAGAMENTO
				replace v_compras_01.DESC_COND_PGTO WITH tmpCondicao1.DESC_COND_PGTO
				replace v_compras_01.TIPO_CONDICAO WITH tmpCondicao1.TIPO_CONDICAO 
				
			ENDIF
		
		ENDIF

		this.Parent.p_digita=.f.
		This.Parent.Refresh	
		RELEASE oPesq
				
	ENDPROC	
	
	PROCEDURE tv_descricao.Refresh
		this.readonly = !this.Parent.p_digita
	ENDPROC
	
	
ENDDEFINE


*** 30-07-2015 -> paulo devide
DEFINE CLASS cmdAtualizar AS CommandButton

	Height = 54
	Left = 695
	Top = 374
	Width = 135
	Name = "cmdAtualizar"
	caption = "Atualizar Custo Fob / Packs p/Caixa"
	wordwrap = .t.
	
	PROCEDURE when
		If !Inlist(Thisformset.p_Tool_Status, "A")
			WAIT WINDOW "AtualizaÁ„o sÛ permitida em modo ALTERA«√O" TIMEOUT 2
			RETURN .f.
		ENDIF
		
	ENDPROC

	PROCEDURE click

		SELECT V_COMPRAS_01_PRODUTOS
		lnRecAtual = recno("V_COMPRAS_01_PRODUTOS")
		lcProduto = V_COMPRAS_01_PRODUTOS.PRODUTO
		lnCusto_Fob = V_COMPRAS_01_PRODUTOS.ERP_CUPS_CUSTO_FOB
		lnCusto_Fob_Min = V_COMPRAS_01_PRODUTOS.ERP_CUPS_CUSTO_FOB_MINIMO
		lnPacks_Cxa = V_COMPRAS_01_PRODUTOS.ERP_CUPS_PACKS_POR_CAIXA
		llConjunto = NVL(V_COMPRAS_01_PRODUTOS.ERP_CONJUNTO,.F.)
		lcCor2 = V_COMPRAS_01_PRODUTOS.ERP_COR_PRODUTO2

		UPDATE V_COMPRAS_01_PRODUTOS ;
		SET V_COMPRAS_01_PRODUTOS.ERP_CUPS_CUSTO_FOB = lnCusto_Fob, ; 
			V_COMPRAS_01_PRODUTOS.ERP_CUPS_PACKS_POR_CAIXA =lnPacks_Cxa, ;
			V_COMPRAS_01_PRODUTOS.ERP_CUPS_CUSTO_FOB_MINIMO = lnCusto_Fob_Min, ; 
			V_COMPRAS_01_PRODUTOS.ERP_CONJUNTO = llConjunto , ;
			V_COMPRAS_01_PRODUTOS.ERP_COR_PRODUTO2 = lcCor2 ;
		WHERE V_COMPRAS_01_PRODUTOS.PRODUTO = lcProduto

		IF lnRecAtual>0
		   GO lnRecAtual
		ENDIF
		
		MESSAGEBOX("Atualizado!",64,"Aviso")
		
	ENDPROC
	
ENDDEFINE

*** INICIO CABILOG --> 09/09/14

DEFINE CLASS lb_cod_cabide AS lx_label
	FontBold = .T.
	Alignment = 0
	Caption = "CÛdigo Cabide:"
	Left = 18
	Top = 48
	Name = "lb_cod_cabide1"
ENDDEFINE

DEFINE CLASS cb_cod_cabide AS lx_combobox
	Height = 21
	Left = 110
	Top = 48
	Width = 84
	Name = "tx_cod_cabide1"

	RowSourceType = 1
	RowSource = ZZ_LISTA_CABIDES_CABILOG

	ControlSource = "v_compras_01.ERP_CAB_COD_CABIDE"
	p_tipo_dado = "EDITA"
	
	PROCEDURE valid
		this.parent.cmdAtualizaCabilog1.click()
	ENDPROC
	
ENDDEFINE

DEFINE CLASS lb_cab_cd_entrega AS lx_label
	FontBold = .T.
	Alignment = 0
	Caption = "CÛd. CD Entrega:"
	Left = 218
	Top = 48
	Name = "lb_cab_cd_entrega1"
ENDDEFINE


DEFINE CLASS tx_cab_cd_entrega AS lx_textbox_base
	Height = 21
	Left = 318
	Top = 48
	Width = 42
	Name = "tx_cab_cd_entrega1"
	ControlSource = "v_compras_01.ERP_CAB_CD_ENTREGA"
	p_tipo_dado = "MOSTRA"
ENDDEFINE

DEFINE CLASS lb_cab_status AS lx_label
	FontBold = .T.
	Alignment = 0
	Caption = "Status:"
	Left = 18
	Top = 73
	Name = "lb_cab_status1"
ENDDEFINE


DEFINE CLASS tx_cab_status AS lx_textbox_base
	Height = 21
	Left = 110
	Top = 73
	Width = 21
	Name = "tx_cab_status1"
	ControlSource = "v_compras_01.ERP_CAB_STATUS"
	Format = "!"
	p_tipo_dado = "EDITA"

	PROCEDURE when
*!*			WAIT WINDOW NOWAIT "Campo n√£o edit√°vel"
*!*			RETURN .f. && campo √© somente leitura, conteudo √© formula
		RETURN .T. && Deixa editar
	ENDPROC

	PROCEDURE valid
		IF NOT INLIST(v_compras_01.ERP_CAB_STATUS, "M", "A") OR EMPTY(NVL(v_compras_01.ERP_CAB_STATUS,""))
			MESSAGEBOX("Preencher com (A)dicionar ou (M)odificar!",16,"Aviso")
			RETURN .f.
		ELSE
			* Se alterou para M, a data de envio tem que ser NULA para reenviar o pedido
			IF v_compras_01.ERP_CAB_STATUS="M"
				replace v_compras_01.ERP_CAB_DATA_ENVIO WITH null
			ENDIF
		ENDIF
		** refresh no campo data de envio
		this.parent.tx_cab_envio1.refresh
		
	ENDPROC
	

ENDDEFINE

DEFINE CLASS lb_cab_localizacao AS lx_label
	FontBold = .T.
	Alignment = 0
	Caption = "LocalizaÁ„o:"
	Left = 218
	Top = 73
	Name = "lb_cab_localizacao1"
ENDDEFINE


DEFINE CLASS cb_cab_localizacao AS lx_combobox
	Height = 21
	Left = 318
	Top = 73
	Width = 84
	Name = "cb_cab_localizacao1"
	RowSourceType = 1
	RowSource = "PAREDE,SOLO,TABLE"
	ControlSource = "v_compras_01.ERP_CAB_LOCALIZACAO"
	p_tipo_dado = "MOSTRA"

ENDDEFINE

DEFINE CLASS lb_cab_qtdpecas AS lx_label
	FontBold = .T.
	Alignment = 0
	Caption = "Qtd. PeÁas:"
	Left = 18
	Top = 98
	Name = "lb_cab_qtdpecas1"
ENDDEFINE


DEFINE CLASS tx_cab_qtdpecas AS lx_textbox_base
	Height = 21
	Left = 110
	Top = 98
	Width = 84
	Name = "tx_cab_qtdpecas1"
	ControlSource = "v_compras_01.ERP_CAB_QTDPECAS"
	p_tipo_dado = "MOSTRA"

	PROCEDURE when
		WAIT WINDOW NOWAIT "Campo n„o edit·vel"
		RETURN .f. && campo √© somente leitura, conteudo √© formula
	ENDPROC

ENDDEFINE

DEFINE CLASS txtCdBolacha AS lx_textbox_base
	Height = 21
	Left = 318
	Top = 128
	Width = 84
	Name = "txtCdBolacha1"
	ControlSource = "v_compras_01.ERP_CAB_COD_BOLACHA"
	p_tipo_dado = "MOSTRA"

	PROCEDURE when
		WAIT WINDOW NOWAIT "Campo n„o edit·vel"
		RETURN .f. && campo √© somente leitura, conteudo √© formula
	ENDPROC

ENDDEFINE

DEFINE CLASS lb_cab_tipo_pedido AS lx_label
	FontBold = .T.
	Alignment = 0
	Caption = "Tipo Pedido:"
	Left = 218
	Top = 98
	Name = "lb_cab_tipo_pedido1"
ENDDEFINE

DEFINE CLASS lblCdBolacha AS lx_label
	FontBold = .T.
	Alignment = 0
	Caption = "CÛd. Alarme:"
	Left = 218
	Top = 128
	Name = "lblCdBolacha1"
ENDDEFINE

DEFINE CLASS cb_cab_tipo_pedido AS lx_combobox
	Height = 21
	Left = 318
	Top = 98
	Width = 100
	Name = "cb_cab_tipo_pedido1"
	RowSourceType = 1
	RowSource = "NORMAL,IMPORTA«√O,BONIFICA«√O,AMOSTRA"
	ControlSource = "v_compras_01.ERP_CAB_TIPO_PEDIDO"
	p_tipo_dado = "MOSTRA"

ENDDEFINE

DEFINE CLASS ck_cab_encabidado AS lx_checkbox
	Height = 21
	Left = 36
	Top = 20
	Width = 84
	Alignment = 1
	FontBold = .T.
	Caption = "Encabidado?"+SPACE(6)
	Name = "ck_cab_encabidado1"
	ControlSource = "v_compras_01.ERP_CAB_ENCABIDADO"
	p_tipo_dado = "EDITA"
	
	PROCEDURE valid
		*this.parent.cmdAtualizaCabilog1.click()
		this.Parent.Activate()
	ENDPROC
	

ENDDEFINE

DEFINE CLASS optCabilog as OptionGroup
	TOP = 10
	BUTTONCOUNT = 4
	OPTION1.CAPTION = "Nenhum"
	OPTION2.CAPTION = "SÛ Encabidado"
	OPTION3.CAPTION = "SÛ Alarme"
	OPTION4.CAPTION = "Encabidado + Alarme"
	OPTION1.AUTOSIZE = .T.
	OPTION2.AUTOSIZE = .T.
	OPTION3.AUTOSIZE = .T.
	OPTION4.AUTOSIZE = .T.
	LEFT = 10
	WIDTH = 432
	HEIGHT = 30
	OPTION1.TOP = 5
	OPTION2.TOP = 5
	OPTION3.TOP = 5
	OPTION4.TOP = 5

	OPTION1.LEFT = 4
	OPTION2.LEFT = 93
	OPTION3.LEFT = 203
	OPTION4.LEFT = 281

	BACKSTYLE = 0
	OPTION1.BACKSTYLE = 0
	OPTION2.BACKSTYLE = 0
	OPTION3.BACKSTYLE = 0
	OPTION4.BACKSTYLE = 0
	
	CONTROLSOURCE = "v_Compras_01.ERP_CAB_OPCAO"
	
	PROCEDURE refresh

		IF NOT Inlist(thisformset.p_Tool_Status, "A","I")
			THIS.Enabled=.F.
		ELSE
			this.Enabled=.t.
		ENDIF

		***
		* se parametro VALIDA_FORNECEDOR_CABILOG for .T. 
		* necess√°rio verificar se o fornecedor usa alarme atraves de FLAG (ERP_USA_BOLACHA)
		* caso contrario, se .F. todos fornecedores usam alarme
		*/	
		IF thisformset.pp_VALIDA_FORNECEDOR_CABILOG=.t.
			TEXT TO lcSQL NOSHOW TEXTMERGE
				SELECT FORNECEDOR, ERP_USA_BOLACHA 
				FROM FORNECEDORES 
				WHERE FORNECEDOR = '<<ALLTRIM(v_compras_01.fornecedor)>>'
			ENDTEXT
			
			IF USED("vFornecedorBolacha")
				SELECT vFornecedorBolacha
				USE
			ENDIF
			
			F_SELECT(lcSQL, "vFornecedorBolacha")
			this.option3.enabled = .t.
			this.option4.enabled = .T.

			IF NVL(vFornecedorBolacha.ERP_USA_BOLACHA,.f.)=.F.
				this.option3.enabled = .F.
				this.option4.enabled = .F.
			ENDIF
		ENDIF
		
		
	ENDPROC
	
	PROCEDURE when
		***
		* se parametro VALIDA_FORNECEDOR_CABILOG for .T. 
		* necess√°rio verificar se o fornecedor usa alarme atraves de FLAG (ERP_USA_BOLACHA)
		* caso contrario, se .F. todos fornecedores usam alarme
		*/	
		IF thisformset.pp_VALIDA_FORNECEDOR_CABILOG=.t.
			TEXT TO lcSQL NOSHOW TEXTMERGE
				SELECT FORNECEDOR, ERP_USA_BOLACHA 
				FROM FORNECEDORES 
				WHERE FORNECEDOR = '<<ALLTRIM(v_compras_01.fornecedor)>>'
			ENDTEXT
			IF USED("vFornecedorBolacha")
				SELECT vFornecedorBolacha
				USE
			ENDIF
			F_SELECT(lcSQL, "vFornecedorBolacha")
			IF NVL(vFornecedorBolacha.ERP_USA_BOLACHA,.f.)=.T.
				this.option3.enabled = .t.
				this.option4.enabled = .T.

				RETURN .t. && OK - fornecedor usa alarme de bolacha
			ELSE
				WAIT WINDOW "opÁ„o 3 e 4 inv·lida para " + ALLTRIM(NVL(vFornecedorBolacha.FORNECEDOR,'este fornecedor!')) + "!"
				this.option3.enabled = .F.
				this.option4.enabled = .F.
				RETURN .t.	
			ENDIF
			
		ELSE
			this.option3.enabled = .t.
			this.option4.enabled = .T.
			RETURN .T.
		ENDIF
		
	ENDPROC
		
	PROCEDURE valid
		WITH this.parent
			.lb_cod_cabide1.visible = (this.Value>1)
			.cb_cod_cabide1.visible = (this.Value>1)
			.lb_cab_cd_entrega1.visible = (this.Value>1)
			.tx_cab_cd_entrega1.visible = (this.Value>1)
			.lb_cab_status1.visible = (this.Value>1)
			.tx_cab_status1.visible = (this.Value>1)
			.lb_cab_localizacao1.visible = (this.Value>1)
			.cb_cab_localizacao1.visible = (this.Value>1)
			.lb_cab_qtdpecas1.visible = (this.Value>1)
			.tx_cab_qtdpecas1.visible = (this.Value>1)
			.LB_cab_envio1.visible = (this.Value>1)
			.tx_cab_envio1.visible = (this.Value>1)
			.lb_cab_tipo_pedido1.visible = (this.Value>1)
			.tx_cab_tipo_pedido1.visible = (this.Value>1)
			.lblCdBolacha1.visible = (this.Value>1)
			.txtCdBolacha1.visible = (this.Value>1)
			.cmdAtualizaCabilog1.visible = (this.Value>1)		
		endwith	
		
		IF Inlist(thisformset.p_Tool_Status, "A","I")
		
			IF INLIST(this.Value,3,4) 	&& 3-S√≥ Alarme ou 4-Encabidado + Alarme
				this.parent.txtCdBolacha1.value = F_FAIXA_VALOR_CABILOG()
				this.parent.txtCdBolacha1.refresh()
			ELSE
				this.parent.txtCdBolacha1.value = ""
			ENDIF
			
			** atualiza os campos
			this.parent.cmdAtualizaCabilog1.click()
			this.Parent.refresh()
			
			
		ENDIF
		
	ENDPROC
	
ENDDEFINE


DEFINE CLASS lb_cab_envio AS lx_label
	FontBold = .T.
	Alignment = 0
	Caption = "Data Envio:"
	Left = 18
	Top = 131
	Name = "lb_cab_envio1"
ENDDEFINE

DEFINE CLASS tx_cab_envio AS lx_textbox_base
	Height = 21
	Left = 110
	Top = 128
	Width = 84
	Name = "tx_cab_envio1"
	ControlSource = "v_compras_01.ERP_CAB_DATA_ENVIO"
	p_tipo_dado = "MOSTRA"

	PROCEDURE when
		WAIT WINDOW NOWAIT "Campo n„o edit·vel"
		RETURN .f. && campo √© somente leitura, conteudo √© formula
	ENDPROC

ENDDEFINE

*** FIM CABILOG --> 09/09/14

** PREENCHE A OBSERVA√á√ÉO DO PEDIDO --> 31/07/14
DEFINE CLASS bt_obs_pack as botao
	caption = 'Preenche OBS'
	*autosize = .T.
	WORDWRAP = .t.
	WIDTH = 162
	top = 3
	left = 85
	HEIGHT =  18
	enabled = .t.
	visible  = .t.
	backcolor =  RGB(64,128,128)

	PROCEDURE click
		LOCAL lcObs, lnArea
		lnArea = SELECT()
		IF !INLIST(ThisFormSet.p_Tool_Status,"A")
			MESSAGEBOX("Para editar observaÁ„o entre em modo de AlteraÁ„o do Pedido",64,"Aviso")
			SELECT (lnArea)
			RETURN
		ENDIF

		IF "PACK:" $ UPPER(ALLTRIM(V_COMPRAS_01.OBS))
			MESSAGEBOX("Apague manualmente a observaÁ„o antes de executar a rotina de preenchimento do PACK na observaÁ„o do pedido",64,"Aviso")
			SELECT (lnArea)
			RETURN
		ENDIF

		lcObs = ALLTRIM(V_COMPRAS_01.OBS)+CHR(13)+CHR(13)+;
			'PACK:'+CHR(13)+;
			REPLICATE('-',120)+ ' ' + CHR(13)
		SELECT v_caedu_compras_produtos_packs
		SCAN
			TEXT TO lcSQL NOSHOW TEXTMERGE
				exec pr_grade_produto_cor ?v_caedu_compras_produtos_packs.pedido,
					?v_caedu_compras_produtos_packs.produto,?v_caedu_compras_produtos_packs.cor_produto
			ENDTEXT
			f_execute(lcSQL,"tmpPack")
			lcObs = lcObs + tmpPack.descricao_grade+CHR(13)
		ENDSCAN

		SELECT V_COMPRAS_01
		IF NOT EMPTY(lcObs)
			replace V_COMPRAS_01.OBS WITH lcObs
		ENDIF
		thisformset.lx_form1.lx_pageframe1.Page5.ed_obs.refresh

		SELECT (lnArea)


	ENDPROC

	*!*		PROCEDURE refresh
	*!*			** Inclus√£o/Altera√ß√£o/Exclus√£o/Tela (L)impa/(P)esquisa Feita!
	*!*			this.enabled = !INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L")
	*!*		ENDPROC

ENDDEFINE

DEFINE CLASS botaoEcom as CommandButton
	Top = 27
	Left = 785
	height = 35
	width = 65
	WordWrap=.t.
	Caption = "Gerar E-comm"
	Name = "botaoEcom"
	visible = .t.
	backcolor =  RGB(0,0,255)
	ForeColor= RGB(255,255,255)
	
	PROCEDURE click
			frmEcom = CreateObject ("TformEcom")
			frmEcom.show(1)
	ENDPROC
	
	PROCEDURE refresh
		** Inclusao/Alteracao/Exclusao/Tela (L)impa/(P)esquisa Feita!
		this.enabled = !INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L") && sÛ habilita botao se a pesquisa estiver feita e modo consulta
	ENDPROC
	
	PROCEDURE when
		IF ALLTRIM(v_compras_01.tipo_compra)="E-COMMERCE" OR RIGHT(ALLTRIM(v_compras_01.pedido),1)="V"
			MESSAGEBOX("N„o È possÌvel gerar pedido de e-commerce atravÈs de outro pedido de e-commerce",48,"Aviso")
			RETURN .f.
		ENDIF
		RETURN .t.
	ENDPROC
	
	
ENDDEFINE 

DEFINE CLASS TformEcom As Form

	Width = 350
	Height = 210
	AutoCenter = .F.
	Windowtype = 1
	AlwaysOnTop = .t.
	Top = 300
	Left = 250
	Caption = "Gerar Pedido E-commerce"


	** Adiciona o Label
	ADD OBJECT lblPack1 As Label WITH;
		Width=100, Height=24, Left=22, Top=15,;
		Caption="Quantidade de Packs?", Autosize=.t.
		
	** Adiciona o Textbox
	nQtdPack = 2
	ADD OBJECT txtPack1 As textbox WITH;
		Width=60, Height=24, Left=152, Top=15, InputMask = "99", value = 2, format = "K" 
		
	ADD OBJECT txtObs1 As editbox WITH;
		Width=320, Height=74, Left=22, Top=45
	
		
	ADD OBJECT listbox1 As listbox WITH;
		Width=100, Height=64, Left=22, Top=135  


	ADD OBJECT cmd1 As CommandButton WITH;
		Width=60, Height=25, Left=214, Top=170, ;
		Caption="Cancel" 
		
	ADD OBJECT cmd2 As CommandButton WITH;
		Width=60, Height=25, Left=284, Top=170, ;
		Caption="Ok", Default=.T.

	ADD OBJECT cmd3 As CommandButton WITH;
		Width=60, Height=25, Left=284, Top=15, ;
		Caption="Puxa OBS"

	PROCEDURE cmd3.Click
		this.Parent.txtObs1.value = ALLTRIM(v_compras_01.obs)
		this.Parent.txtObs1.refresh
	ENDPROC

	PROCEDURE cmd1.Click
		ThisForm.Release
	ENDPROC

	PROCEDURE cmd2.Click

		cPedido = ALLTRIM(v_compras_01.pedido)
		cPedidoDest = ALLTRIM(STRTRAN(v_compras_01.pedido,"-",""))+"V"
		nQtdPack = CAST(this.Parent.txtPack1.value as Int)
		this.Parent.listbox1.Clear
		this.Parent.listbox1.additem(cPedido)
		this.Parent.listbox1.additem(cPedidoDest)
		this.Parent.listbox1.additem(TRANSFORM(nQtdPack,"99"))
		
		IF MESSAGEBOX("Confirma a geraÁ„o do pedido de E-commerce com os parametros listados?",292,"Aviso")=6
			TEXT TO cmdsql1 NOSHOW TEXTMERGE PRETEXT 7
				EXEC CGP_LX_GERA_PEDIDO_E_COMM '<<cPedido>>', '<<cPedidoDest>>', <<nQtdPack>>
			ENDTEXT
	*!*			MESSAGEBOX(cmdsql1)
			IF f_execute(cmdsql1)
				** ATUALIZA OBS INFORMADA PELO USU¡RIO PARA O PEDIDO DESTINO
				cObs = ALLTRIM(this.Parent.txtObs1.value)
				cmdsql2 = "UPDATE COMPRAS SET OBS = ?cObs WHERE pedido = ?cPedidoDest"
				f_execute(cmdsql2)
				** MARCA O FLAG PARA FALSO PARA ENVIAR PARA TODAS AS LOJAS
				cmdsql3 = "UPDATE PROP_COMPRAS SET VALOR_PROPRIEDADE = 'N√O' WHERE PEDIDO = ?cPedidoDest AND PROPRIEDADE='00106'"
				f_execute(cmdsql3)
				MESSAGEBOX("Processo ConcluÌdo!",64,"Aviso")
			ENDIF
					
			ThisForm.Release
		ENDIF

	ENDPROC
	
ENDDEFINE

DEFINE CLASS btnCorrigeCusto as botao
	caption = 'Corrige Custo do Pedido'
	*autosize = .T.
	WORDWRAP = .t.
	WIDTH = 180
	top = 410
	left = 480
	HEIGHT =  24
	enabled = .t.
	visible  = .t.
	backcolor =  RGB(0,0,255)
	ForeColor= RGB(255,255,255)
	MousePointer= 15
	FontBold=.t.
	ToolTipText="Aplica o preÁo da tabela 00 neste pedido"
	name = "btnCorrigeCusto"

	PROCEDURE click
		IF v_compras_01.TOT_QTDE_ENTREGAR <> 0
			THIS.ATUALIZA_CUSTO()
		ELSE
			MESSAGEBOX("Custo do Pedido n„o pode ser atualizado pois o pedido j· foi recebido!", 64, "Aviso")	
		ENDIF
	ENDPROC

	PROCEDURE ATUALIZA_CUSTO

		F_SELECT("SELECT * FROM PRODUTOS_PRECOS WHERE PRODUTO = '"+ALLTRIM(v_compras_01_produtos.PRODUTO)+"' AND CODIGO_TAB_PRECO = '00'","VCUR_PRECO_00")
		
		tcCusto = VCUR_PRECO_00.preco1

		TEXT TO lcSQL NOSHOW TEXTMERGE PRETEXT 7
			update compras_produto 
			set		custo1 = ?tcCusto, 
					VALOR_ORIGINAL = QTDE_ORIGINAL*?tcCusto, 
					VALOR_ENTREGAR=QTDE_ENTREGAR*?tcCusto, 
					ERP_VERBAS_EMPENHO=QTDE_ORIGINAL*?tcCusto 
			where pedido = ?v_compras_01.PEDIDO
		ENDTEXT
		F_EXECUTE(lcSQL)

		TEXT TO lcSQL NOSHOW TEXTMERGE PRETEXT 7
			update compras 
			set TOT_VALOR_ORIGINAL= TOT_QTDE_ORIGINAL * ?tcCusto, 
				TOT_VALOR_ENTREGAR = TOT_QTDE_ENTREGAR * ?tcCusto 
			WHERE PEDIDO = ?v_compras_01.PEDIDO
		ENDTEXT	
		F_EXECUTE(lcSQL)

		MESSAGEBOX("Custo do Pedido foi atualizado para "+TRANSFORM(tcCusto, "999999.99")+"! Recarregue o Pedido para atualizar a tela", 64, "Aviso")
	ENDPROC

	procedure refresh
		** inclus„£o/altera„ß„£o/exclus„£o/tela (l)impa/(p)esquisa feita!
		this.enabled = thisformset.p_tool_status="P"
	endproc

ENDDEFINE


*** PAULO DEVIDE
*** TELA PARA PARAMETROS DO 
*** PEDIDO EM INGL√äS (EXCEL)
*** (Inicio) --> 12-09-2014
DEFINE CLASS Tform As Form

	Width = 300
	Height = 110
	AutoCenter = .T.
	Windowtype = 1
	AlwaysOnTop = .t.
	Caption = "Exportar Pedido para Excel"

	ADD OBJECT chk As Checkbox WITH;
		Width=100, Height=24, Left=22, Top=30,;
		Caption="Agrupar Pedidos na Planilha?", Autosize=.t., ControlSource = 'llAgrupaPedido'

	ADD OBJECT cmd1 As CommandButton WITH;
		Width=60, Height=25, Left=164, Top=70, ;
		Caption="Cancel" 
		
	ADD OBJECT cmd2 As CommandButton WITH;
		Width=60, Height=25, Left=234, Top=70, ;
		Caption="Ok", Default=.T.


	PROCEDURE cmd1.Click
		llRespInvoice=.f.
		ThisForm.Release
	ENDPROC

	PROCEDURE cmd2.Click
		llRespInvoice=.t.
		ThisForm.Release
	ENDPROC
	
ENDDEFINE
*** PAULO DEVIDE
*** (Final) --> 12-09-2014


** PAULO DEVIDE -> 22-05-2013
** BOT√ÉO PEDIDO INGLES EXCEL
DEFINE CLASS bt_pedido as botao
	caption = 'Pedido Excel'
	*autosize = .T.
	WORDWRAP = .t.
	WIDTH = 192
	top = 3
	left = 502
	HEIGHT =  27
	enabled = .f.
	visible  = .t.
	backcolor =  RGB(64,128,128)

	PROCEDURE click
		
		LOCAL llRet
		llRet = MESSAGEBOX("Deseja Formatar Pedido no Excel em InglÍs?",292,"Aviso")=6


		IF llRet && AND ALLTRIM(NVL(v_compras_01.ERP_CUPS_SEGMENTO,''))<> "ATACADO"

			PUBLIC frmInvoice, llRespInvoice, llAgrupaPedido

			llRespInvoice =.f.
			llAgrupaPedido =.f.
			frmInvoice = CreateObject ("Tform")
			frmInvoice.show(1)
			
			IF llRespInvoice && clicou OK
			
				PUBLIC oExcel as Object
				oExcel = CREATEOBJECT("Excel.Application")
				** Define o nome do arquivo XLSX a ser criado
				lcSQL = "select codigo_modelo,descricao_modelo,imagem_modelo "+;
					"from CAE_MODELOS_EXCEL where codigo_modelo='0001'"

				** Pega o modelo (template em branco) para gerar o Excel do relat√≥rio
				f_select(lcSQL,"vCAE_Modelos")

				** Converte a imagem para arquivo bin√°rio
				lcTmpArqxls = CAST(vCAE_Modelos.imagem_modelo as blob)

				LOCAL lcArquivo as String
				lcArquivo = SYS(2023)+"\pedido_compras_"+STUFF(STUFF(DTOS(DATE()),5,0,'-'),8,0,'-')+SYS(2015)+".xlsx"

				STRTOFILE(lcTmpArqxls,lcArquivo) && grava modelo na pasta tempor√°ria do usu√°rio
				WITH oExcel				
					.workbooks.open(lcArquivo)
					.Sheets(1).Name = "matriz"
					.visible = .T.
					.DisplayAlerts = .F. && Excel n√£o apresenta caixa de dialogo que solicita confirma√ß√£o

					** Pega a matriz em branco e duplica "n" vezes a quantidade de registro selecionada na pesquisa						
					IF llAgrupaPedido AND RECCOUNT("v_compras_01")>1
					
						FOR ixx=1 TO RECCOUNT("v_compras_01")
							.Sheets(1).Copy( , .Sheets(ixx))
							.ActiveSheet.name = ALLTRIM(TRANSFORM(ixx,"9999"))
						ENDFOR
						
					ENDIF
					
				ENDWITH

				IF !llAgrupaPedido
					f_wait("Exportando dados para o Excel...")
					LOCAL lcArquivo as String
					lcArquivo = SYS(2023)+"\pedido_compras_"+STUFF(STUFF(DTOS(DATE()),5,0,'-'),8,0,'-')+SYS(2015)+".xlsx"

					zPedido_Excel(lcArquivo, oExcel)

					f_wait()
				ELSE
					LOCAL lcArquivo as String
					lcArquivo = SYS(2023)+"\pedido_compras_"+STUFF(STUFF(DTOS(DATE()),5,0,'-'),8,0,'-')+SYS(2015)+".xlsx"

					SELECT V_COMPRAS_01
					GO top
					
					
					lnSheet = 1
					SCAN 					

						f_wait("Exportando dados do Pedido "+V_COMPRAS_01.pedido+"para o Excel...")

						zPedido_Excel(lcArquivo, oExcel, lnSheet)

						f_wait()
						
						lnSheet = lnSheet + 1

					ENDSCAN
					** Exclui planilha matriz em branco
				    oExcel.Sheets("matriz").Select
				    oExcel.ActiveWindow.SelectedSheets.Delete
					oExcel.DisplayAlerts = .T. && volta status Default - Excel solicita confirma√ß√£o para Salvar, Excluir, etc.
				ENDIF
				
			
			ENDIF
			
			RELEASE frmInvoice, llRespInvoice, oExcel
			SELECT v_compras_01
			GO top
			
		ELSE
			llRet = .f.
			IF llRet
			
				IF ALLTRIM(NVL(v_compras_01.ERP_CUPS_SEGMENTO,'')) = "ATACADO"		
					*** chamada do PEDIDO INGL√äS PARA ATACADO
					*** 1 produto por ABA no Excel

					PUBLIC oExcel as Object
					oExcel = CREATEOBJECT("Excel.Application")
					** Define o nome do arquivo XLSX a ser criado
					lcSQL = "select codigo_modelo,descricao_modelo,imagem_modelo "+;
						"from CAE_MODELOS_EXCEL where codigo_modelo='0001'"

					** Pega o modelo (template em branco) para gerar o Excel do relat√≥rio
					f_select(lcSQL,"vCAE_Modelos")
					** SET STEP ON
					** Converte a imagem para arquivo bin√°rio
					lcTmpArqxls = CAST(vCAE_Modelos.imagem_modelo as blob)

					LOCAL lcArquivo as String
					lcArquivo = SYS(2023)+"\pedido_compras_"+STUFF(STUFF(DTOS(DATE()),5,0,'-'),8,0,'-')+SYS(2015)+".xlsx"

					STRTOFILE(lcTmpArqxls,lcArquivo) && grava modelo na pasta tempor√°ria do usu√°rio

					SELECT distinct PRODUTO ;
					FROM v_compras_01_produtos ;
					INTO CURSOR tmpProdutos1

					WITH oExcel				
						.workbooks.open(lcArquivo)
						.Sheets(1).Name = "matriz"
						.visible = .T.
						.DisplayAlerts = .F. && Excel n√£o apresenta caixa de dialogo que solicita confirma√ß√£o

						** Pega a matriz em branco e duplica "n" vezes a quantidade de registro selecionada na pesquisa						
						IF RECCOUNT("tmpProdutos1")>1
						
							FOR ixx=1 TO RECCOUNT("tmpProdutos1")
								.Sheets(1).Copy( , .Sheets(ixx))
								.ActiveSheet.name = ALLTRIM(TRANSFORM(ixx,"9999"))
							ENDFOR
							
						ENDIF
						
					ENDWITH


					LOCAL lcArquivo as String
					lcArquivo = SYS(2023)+"\pedido_compras_"+STUFF(STUFF(DTOS(DATE()),5,0,'-'),8,0,'-')+SYS(2015)+".xlsx"

					SELECT tmpProdutos1
					GO top


					lnSheet = 1
					SCAN 					

						f_wait("Exportando dados do Pedido "+V_COMPRAS_01.pedido+"para o Excel...")

						zPedido_Excel_Atc(lcArquivo, oExcel, lnSheet)

						f_wait()
						
						lnSheet = lnSheet + 1

					ENDSCAN
					** Exclui planilha matriz em branco

					IF oExcel.worksheets(1).name = "matriz"
						oExcel.Sheets("matriz").Select
						oExcel.ActiveWindow.SelectedSheets.Delete
					ENDIF
						
					oExcel.DisplayAlerts = .T. && volta status Default - Excel solicita confirma√ß√£o para Salvar, Excluir, etc.
					

					RELEASE oExcel

					SELECT v_compras_01
					GO top
					
				ENDIF
				
			ENDIF
				
		ENDIF


	ENDPROC

	PROCEDURE refresh
		** Inclus√£o/Altera√ß√£o/Exclus√£o/Tela (L)impa/(P)esquisa Feita!
		this.enabled = !INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L")
	ENDPROC

ENDDEFINE
** BOT√ÉO PEDIDO INGLES EXCEL
** FIM: 22-05-2013

*** TELA QUE PEDE A SENHA DO DIRETOR/GERENTE
DEFINE CLASS TformLoginWindows As Form

	Width = 350
	Height = 380
	AutoCenter = .T.
	Windowtype = 1
	AlwaysOnTop = .t.
	Caption = "Login e Senha da Rede Windows - "

	gcLogin = ""
	gcPwd = ""

	ADD OBJECT lblLogin as Label WITH;
		Width=200, Height=25, Left=20, Top=35, Caption = "Login"
	
	ADD OBJECT lblSenha as Label WITH;
		Width=200, Height=25, Left=20, Top=65, Caption = "Password"

	ADD OBJECT txtLogin as Textbox WITH;
		Width=200, Height=25, Left=100, Top=30, controlsource = "gcLogin"
	
	ADD OBJECT txtSenha as Textbox WITH;
		Width=200, Height=25, Left=100, Top=60, controlsource = "gcPwd", Passwordchar = "*"

	ADD OBJECT cmd1 As CommandButton WITH;
		Width=60, Height=25, Left=218, Top=350, ;
		Caption="Cancel" 
		
	ADD OBJECT cmd2 As CommandButton WITH;
		Width=60, Height=25, Left=284, Top=350, ;
		Caption="Ok", Default=.T.

	ADD OBJECT lblMensagem as Label WITH;
		Width=300, Height=200, Left=10, Top=90, Caption = "", Autosize = .f., Wordwrap = .T.

	PROCEDURE init
		=CAPSLOCK(.F.)
		WAIT WINDOW "CAPSLOCK is off" TIMEOUT 0.5		
	ENDPROC
	
	PROCEDURE cmd1.Click
		ThisForm.Release
	ENDPROC

	PROCEDURE cmd2.Click
		llOk_ad = zvalida_login(gcLogin, gcPwd)
		IF llOk_ad
			MESSAGEBOX("Login Autenticado com sucesso!",64,"Aviso")
		ELSE
			MESSAGEBOX("Falha na AutenticaÁ„o do Login!",64,"Aviso")
		ENDIF
		
		ThisForm.Release
	ENDPROC
	
ENDDEFINE
**** 

***
* Bot√£o para chamar a tela para adicionar produto/pack
*/
DEFINE CLASS cmdAddProduto AS CommandButton

	Height = 34
	Left = 19
	Top = 150
	Width = 135
	Name = "cmdAddProduto"
	caption = "Adicionar Produto"
	wordwrap = .t.
	
	objTelaPai = .f.
	
	PROCEDURE init
		
		PARAMETERS oThisformSet
		this.objTelaPai = oThisformSet
					
	ENDPROC
	
	PROCEDURE when
		RETURN .t.		
	ENDPROC

	PROCEDURE click
		IF v_compras_01.TOT_QTDE_ENTREGAR <> v_compras_01.TOT_QTDE_ORIGINAL
			Messagebox('Esse pedido de compra j· foi recebido total ou parcialmente' +Chr(13)+;
									'AlteraÁıes n„o permitidas!', 16, "Aviso")
			RETURN .F.
		ENDIF

		IF USED("VPRODUTO")
			SELECT VPRODUTO
			IF RECCOUNT("VPRODUTO")=0
				APPEND BLANK
			ENDIF
		ENDIF
		
		IF UPPER(ALLTRIM(v_compras_01.ERP_CUPS_SEGMENTO)) <> "ATACADO"
			
			SELECT V_COMPRAS_01_PRODUTOS
			
			COUNT TO lnTotLinhas ;
				FOR NOT DELETED()
			
			WAIT WINDOW NOWAIT TRANSFORM(lnTotLinhas)
				
			IF lnTotLinhas > 0 &&RECCOUNT("V_COMPRAS_01_PRODUTOS") > 0
			
				MESSAGEBOX("N„o È permitido inserir mais de um "+CHR(13)+;
							"produto para o Segmento VAREJO",64,"Aviso")
				RETURN .F.
				
			ENDIF
			
		ENDIF
		
		frm = CREATEOBJECT("TFormPack",this.objTelaPai)
		frm.show(1)						
	ENDPROC

	PROCEDURE refresh
		** Inclus√£o/Altera√ß√£o/Exclus√£o/Tela (L)impa/(P)esquisa Feita!
		this.enabled = INLIST(ThisFormSet.p_Tool_Status,"I","A")
	ENDPROC
	
ENDDEFINE

***
* Bot√£o para chamar a tela para excluir produto/pack
*/
DEFINE CLASS cmdDelProduto AS CommandButton

	Height = 34
	Left = 160
	Top = 150
	Width = 135
	Name = "cmdDelProduto"
	caption = "Excluir Produto"
	wordwrap = .t.
	
	objTelaPai = .f.
	
	PROCEDURE init
		
		PARAMETERS oThisformSet
		this.objTelaPai = oThisformSet
					
	ENDPROC
	
	PROCEDURE when
		RETURN .t.		
	ENDPROC

	PROCEDURE click
		IF v_compras_01.TOT_QTDE_ENTREGAR <> v_compras_01.TOT_QTDE_ORIGINAL
			Messagebox('Esse pedido de compra j· foi recebido total ou parcialmente' +Chr(13)+;
									'AlteraÁıes n„o permitidas!', 16, "Aviso")
			RETURN .F.
		ENDIF
		TEXT TO cmdsql NOSHOW TEXTMERGE
			select count(*) as qty 
			from caedu_reserva_automatica 
			where pedido = ?v_compras_01.pedido   
		ENDTEXT
		*** Paulo Devide - 01/08/2019
		f_select(cmdsql, "tmpVerificaDistrib")
		IF tmpVerificaDistrib.qty > 0
			Messagebox('Esse pedido de compra j· tem DistribuiÁ„o feita.' +Chr(13)+;
									'Caso necessite alterar, favor solicitar ao planejamento ' +CHR(13) +; 
									'excluir a DistribuiÁ„o primeiro !!!', 16, "Aviso")
			RETURN .F.
		ENDIF
		
		this.excluir_produtos()
	ENDPROC
	
	PROCEDURE excluir_produtos
		lnResp = MESSAGEBOX("Deseja excluir os lanÁamentos informados para o "+CHR(13)+"produto selecionado para todas as cores?", 292, "Aviso")
		IF lnResp = 7
			WAIT WINDOW NOWAIT "OperaÁ„o cancelada pelo usu·rio..."
		ENDIF
		
		SET DELETED on
		
		meuproduto = ALLTRIM(v_compras_01_produtos.produto)
		
		SELECT v_caedu_compras_produtos_packs
		delete FOR ALLTRIM(v_caedu_compras_produtos_packs.produto) = meuproduto		

		SELECT v_caedu_compras_produtos_packs_total
		delete FOR ALLTRIM(v_caedu_compras_produtos_packs_total.produto) = meuproduto		
		
		SELECT v_compras_01_produtos
		
		IF USED("v_compras_01_produtos_excluidos")
			USE IN v_compras_01_produtos_excluidos
		ENDIF
		
		****
		* altera√ß√£o para pegar dados dos itens excluidos para alimentar os campos que se perdem 
		* ao excluir e incluir novamente o mesmo item
		* quando √© conjunto: cor2 e flag de conjunto
		* perde o valor do campo erp_perc_margem
		*=======================================================
		* Paulo Devide -> 01/10/2018
		*/
		SELECT * ;
		FROM v_compras_01_produtos ;
		WITH (BUFFERING = .T.) ;
		WHERE ALLTRIM(v_compras_01_produtos.produto) = meuproduto ;
		INTO CURSOR v_compras_01_produtos_excluidos
		
		SELECT v_compras_01_produtos		
		delete FOR ALLTRIM(v_compras_01_produtos.produto) = meuproduto		
		
		ThisFormSet.EXCLUIU_ITENS = .T. && exclus√£o confirmada, na hora de gravar vai estornar o empenho de otb
		this.objTelaPai.refresh
		
	ENDPROC
	

	PROCEDURE refresh
		** Inclus√£o/Altera√ß√£o/Exclus√£o/Tela (L)impa/(P)esquisa Feita!
		this.enabled = INLIST(ThisFormSet.p_Tool_Status,"I","A")
	ENDPROC
	
ENDDEFINE


***
* Tela para adicionar produto/pack
*/
DEFINE CLASS TFormPack As Form

	Width = 580
	Height = 440
	AutoCenter = .T.
	Windowtype = 1
	AlwaysOnTop = .t.
	Minbutton = .f.
	Maxbutton = .f.
	borderstyle = 1
	Caption = "Selecionar Produto/Pack"

	objTelaPai = .f.
	
	gcLogin = ""
	gcPwd = ""

	ADD OBJECT lblProduto as Label WITH;
		Width=200, Height=25, Left=20, Top=15, Caption = "Produto"
	
	ADD OBJECT lblPack as Label WITH;
		Width=200, Height=25, Left=20, Top=45, Caption = "Pack"

	ADD OBJECT lblQtdPack1 as Label WITH;
		Width=200, Height=25, Left=180, Top=45, Caption = "Qtd. Pack", VISIBLE = .T.
		
	ADD OBJECT list1 AS listbox WITH ;
		FontName = "Tahoma", FontSize = 8, ;
		Height = 120, Left = 20, Top = 75, Width = 540, Name = "List1"		

	ADD OBJECT lblQtdTotalPack1 as Label WITH;
		Width=200, Height=25, Left=20, Top=225, Caption = "Qtde. Total" 

	ADD OBJECT lblValorTotalPack1 as Label WITH;
		Width=200, Height=25, Left=180, Top=225, Caption = "Valor Total"

	ADD OBJECT lblCustoFob1 as Label WITH;
		Width=200, Height=25, Left=20, Top=255, Caption = "Custo FOB"

	ADD OBJECT lblCustoFobMinimo1 as Label WITH;
		Width=200, Height=25, Left=180, Top=255, Caption = "FOB MÌn."

	ADD OBJECT txtProduto as Textbox WITH;
		Width=100, Height=25, Left=100, Top=10 , controlsource = "vPRODUTO.PRODUTO"

	ADD OBJECT lblOrigem1 as Label WITH ;
		Width=100, Height=25, Left=240, Top=10 , CAPTION = "", ForeColor = RGB(255,0,0), ;
		FontBold = .T.
		
	ADD OBJECT cboPack1 as Combobox WITH;
		Width=60, Height=25, Left=100, Top=40 , controlsource = "vPRODUTO.CODIGO_PACK", ;
		RowSourceType = 6, RowSource = "vCboPack.CODIGO_PACK", Style = 2, ;
		SpecialEffect = 1

	ADD OBJECT txtQtdPack1 as Textbox WITH;
		Width=60, Height=25, Left=240, Top=40 , controlsource = "vPRODUTO.QtdPack", VISIBLE = .T.

	ADD OBJECT txtQtdTotalPack1 as Textbox WITH;
		Width=70, Height=25, Left=100, Top=220 , controlsource = "vPRODUTO.QtdTotalPack", ReadOnly = .T.

	ADD OBJECT txtValorTotalPack1 as Textbox WITH;
		Width=100, Height=25, Left=240, Top=220 , controlsource = "vPRODUTO.ValorTotalPack", ReadOnly = .T.

	ADD OBJECT txtCustoFob1 as Textbox WITH;
		Width=70, Height=25, Left=100, Top=250 , controlsource = "vPRODUTO.custofob", ReadOnly = .F.

	ADD OBJECT txtFobMinimo1 as Textbox WITH;
		Width=100, Height=25, Left=240, Top=250 , controlsource = "vPRODUTO.fobminimo", ReadOnly = .F.

	ADD OBJECT cmd1 As CommandButton WITH;
		Width=60, Height=25, Left=422, Top=410, ;
		Caption="Cancel" 
		
	ADD OBJECT cmd2 As CommandButton WITH;
		Width=60, Height=25, Left=484, Top=410, ;
		Caption="Ok"
		
	ADD OBJECT cmdPesq1 As CommandButton WITH;
		Width=25, Height=25, Left=200, Top=10, ;
		Caption="..."

	ADD OBJECT cntDadosProduto1 as Container WITH ;
		Width=330, Height=100, Left=10, Top=315, SpecialEffect = 1
	
*** Comentado em 26/10/2017
*** Edi√ß√£o destes campos ser√° feita na Aba Itens do Pedido de Compras, registro a registro
*!*		ADD OBJECT chkConjunto1 as Checkbox WITH ;
*!*			Width=110, Height=21, Left=10, Top=280, Caption = "√â conjunto?", ControlSource = "vPRODUTO.ERP_CONJUNTO"


*!*		ADD OBJECT lblCor2 as Label WITH ;
*!*			Width=100, Height=25, Left=190, Top=285 , CAPTION = "Cor 2:", FontBold = .F.

*!*		ADD OBJECT cboCor2 as Combobox WITH;
*!*			Width=220, Height=25, Left=240, Top=280 , controlsource = "vPRODUTO.ERP_COR_PRODUTO2", ;
*!*			RowSourceType = 6, RowSource = "vcboCor2.DESCRICAO,CODIGO", Style = 2, ;
*!*			SpecialEffect = 1, ColumnCount = 2, ColumnWidths="240,80", BoundColumn=2
	
	*********************************************************
	*** PROCEDURES, M√âTODOS E FUNCTIONS DA TELA TFormPack ***
	*********************************************************
	PROCEDURE load
		***
		* QUERY PARA ALIMENTAR CURSOR DO COMBOBOX DE SEGUNDA COR ==> cboCor2 
		*/
*** Comentado em 26/10/2017
*** Edi√ß√£o destes campos ser√° feita na Aba Itens do Pedido de Compras, registro a registro
*!*			TEXT TO lcSQL NOSHOW TEXTMERGE
*!*				SELECT DESCRICAO,CODIGO 
*!*				FROM CAEDU_LISTA_COMBO 
*!*				WHERE ID_DOMINIO = '016' 
*!*				ORDER BY DESCRICAO
*!*			ENDTEXT
*!*			IF USED("vcboCor2")
*!*				SELECT vcboCor2
*!*				USE
*!*			ENDIF
*!*			F_SELECT(lcSQL,"vcboCor2") 
	
	ENDPROC
	
*** Comentado em 26/10/2017
*** Edi√ß√£o destes campos ser√° feita na Aba Itens do Pedido de Compras, registro a registro
*!*		PROCEDURE cboCor2.valid
*!*			**WAIT WINDOW this.value
*!*			
*!*		ENDPROC
*!*		
*!*		PROCEDURE cboCor2.when
*!*			IF !NVL(vPRODUTO.ERP_CONJUNTO,.F.)
*!*				WAIT WINDOW "Somente permitido a escolha de 2¬™. cor para Conjunto"+CHR(13)+;
*!*							"Clique em Conjunto para selecionar uma cor."
*!*				RETURN .F.
*!*			ENDIF
*!*			RETURN .t.
*!*		ENDPROC
	
	PROCEDURE init
		
		PARAMETERS oThisformSet
		thisform.objTelaPai = oThisformSet
		
		
		SELECT vPRODUTO
		GO top
		SCATTER MEMVAR MEMO BLANK
		*
		GATHER MEMVAR
					
	ENDPROC
	
	PROCEDURE monta_lista_pack
		PARAMETERS tcProduto, tcPack
		TEXT TO cSQL NOSHOW TEXTMERGE
		select produtos.produto,PRODUTOS_TAMANHOS.GRADE,PRODUTOS_TAMANHOS.TAMANHOS_DIGITADOS, 
		      a.Q1, a.Q2, a.Q3, a.Q4, a.Q5, a.Q6, a.Q7, a.Q8, a.Q9, a.Q10, 
		      a.Q11, a.Q12, a.Q13, a.Q14, a.Q15, a.Q16, C.DESC_COR_PRODUTO,
		      a.QTDE, produtos.ERP_CUPS_CUSTO_FOB, produtos.ERP_CUPS_CUSTO_FOB_MINIMO
		      from PRODUTOS_PACKS_PERMITIDOS a
		      join PRODUTOS on PRODUTOS.PRODUTO=a.PRODUTO
			  JOIN PRODUTO_CORES c 
				ON c.PRODUTO = a.PRODUTO 
					AND c.COR_PRODUTO = a.COR_PRODUTO
		      JOIN PRODUTOS_TAMANHOS ON PRODUTOS_TAMANHOS.GRADE=PRODUTOS.GRADE
		      where A.PRODUTO = ?tcProduto and A.PACK = ?tcPack
		ENDTEXT
		f_select(cSQL, "vprod1")
		
		IF RECCOUNT("vprod1") = 0
			MESSAGEBOX("Grade do Produto n„o encontrada ou n„o configurada no cadastro de Produtos!", 64, "Aviso")
			ThisForm.List1.ColumnCount = -1
			ThisForm.List1.Clear
			RETURN 
		ENDIF
		
		csql = "select * from produtos_tamanhos where grade = ?vprod1.grade"
		f_select(csql, "vprodutos_tam1")

		nTamDig = vprodutos_tam1.TAMANHOS_DIGITADOS
		DIMENSION laTam(nTamDig)
		laTam = ""

		FOR ixx = 1 TO nTamDig

			lcField = "vprodutos_tam1.TAMANHO_"+ALLTRIM(TRANSFORM(ixx,"99"))
			lcTam = EVALUATE(lcField)

			IF EMPTY(lcTam) OR ("." $ lcTam)
				lcValor = " -"
			ELSE
				lcValor = PADL(lcTam,2," ")
			ENDIF

			laTam[ixx] = ALLTRIM(lcValor)

		ENDFOR

		SELECT vprod1
		PUBLIC ARRAY laLista[RECCOUNT("vprod1")+1,nTamDig+2]

		lcWidth = ""
		FOR ixx = 1 TO RECCOUNT("vprod1")+1
			IF ixx = 1 && cabe√ßalho
				laLista[ixx,1] = " COR "
				ncol = 1
				lcWidth = lcWidth + "100" + ","

				laLista[ixx,2] = " QTDE "
				ncol = 2
				lcWidth = lcWidth + "40" + ","

				FOR iqq=1 TO ALEN(latam,1)
					ncol = ncol + 1
					laLista[ixx,ncol] = latam[iqq]
					lcWidth = lcWidth + "40" + ","
				ENDFOR
				lcWidth = LEFT(lcWidth,LEN(lcWidth)-1)
			ELSE
				GO (ixx - 1)
				laLista[ixx,1] = ALLTRIM(desc_cor_produto)
				ncol = 1
				laLista[ixx,2] = TRANSFORM(QTDE,"9999")
				ncol = 2

				FOR iqq=1 TO ALEN(latam,1)
					ncol = ncol + 1
					lcCampo = "Q"+ALLTRIM(TRANSFORM(iqq,"99"))
					laLista[ixx,ncol] = TRANSFORM(EVALUATE(lcCampo),"999") 
				ENDFOR
			ENDIF
		ENDFOR

		ThisForm.List1.ColumnCount = -1

		ThisForm.List1.RowSourceType= 5
		ThisForm.List1.RowSource = "lalista"
		ThisForm.List1.ColumnCount = ALEN(laLista,2)
		ThisForm.List1.ColumnWidths = lcWidth
		ThisForm.List1.ColumnLines= .T.
		ThisForm.List1.Requery
		ThisForm.List1.Refresh


		ThisForm.txtCustoFob1.value = vprod1.ERP_CUPS_CUSTO_FOB
		ThisForm.txtFobMinimo1.value = vprod1.ERP_CUPS_CUSTO_FOB_MINIMO

		ThisForm.txtCustoFob1.Refresh
		ThisForm.txtFobMinimo1.Refresh

	ENDPROC && fim proc: monta_lista_pack
		
	
	PROCEDURE cntDadosProduto1.init
	
		this.AddObject("lblProduto","label")
		WITH this.lblProduto
			.AutoSize = .T.
			.Caption = "Produto"
			.Height = 17
			.Left = 8
			.Top = 14
			.Width = 45
			.Name = "lblProduto"
			.Visible = .t.
		ENDWITH
		
		this.AddObject("edtProduto","editbox")
		WITH this.edtProduto
			.Height = 46
			.Left = 68
			.ReadOnly = .T.
			.Enabled = .f.
			.Top = 14
			.Width = 255
			.Name = "edtProduto"
			.Value = ""
			.Visible = .t.
		ENDWITH

		this.AddObject("lblTotalPack","label")
		WITH this.lblTotalPack
			.AutoSize = .T.
			.Caption = "Total Pack"
			.Height = 17
			.Left = 8
			.Top = 74
			.Width = 45
			.Name = "lblTotalPack"
			.Visible = .t.
		ENDWITH
		
		this.AddObject("txtTotalPack","textbox")
		WITH this.txtTotalPack
			.Height = 23
			.Left = 68
			.ReadOnly = .T.
			.Enabled = .f.
			.Top = 74
			.Width = 60
			.Name = "txtTotalPack"
			.Value = 0
			.Visible = .t.
		ENDWITH

		this.AddObject("lblCusto","label")
		WITH this.lblCusto
			.AutoSize = .T.
			.Caption = "Custo R$"
			.Height = 17
			.Left = 163
			.Top = 74
			.Width = 45
			.Name = "lblCusto"
			.Visible = .t.
		ENDWITH
		
		this.AddObject("txtCusto","textbox")
		WITH this.txtCusto
			.Height = 23
			.Left = 225
			.ReadOnly = .T.
			.Enabled = .f.
			.Top = 74
			.Width = 100
			.Name = "txtCusto"
			.Value = 0.00
			.InputMask = "999,999.99"
			.Visible = .t.
		ENDWITH

	ENDPROC
	

	PROCEDURE activate
		thisform.Refresh
	ENDPROC
	
	PROCEDURE cmd1.Click
		ThisForm.Release
	ENDPROC

	** Bot√£o OK
	PROCEDURE cmd2.Click
		
		thisform.calcula2()
		IF thisform.inserir_produto()		
			ThisForm.Release
		ENDIF
	ENDPROC

	PROCEDURE cmdPesq1.Click
		frmPesq1 = NEWOBJECT("Tpesqproduto")
		frmPesq1.show(1)						
	ENDPROC
	
	PROCEDURE txtProduto.Valid
		TEXT TO lcSQL NOSHOW TEXTMERGE
			SELECT produto FROM produtos 
			where produto = '<<ALLTRIM(NVL(this.value,""))>>'
		ENDTEXT
		f_select(lcSQL,"vInfoProduto")
		IF RECCOUNT("vInfoProduto")=0
			thisform.cmdPesq1.Click()
			meuproduto = ALLTRIM(vProduto.produto)
			thisform.requery_cursores_produtos()
			thisform.montaComboPack()	
			thisform.lblOrigem1.CAPTION = IIF(thisform.ORIGEM_PRODUTO(meuproduto)="N","nacional","importado")
		ELSE
			meuproduto = ALLTRIM(vProduto.produto)
			thisform.requery_cursores_produtos()
			thisform.montaComboPack()	
			thisform.lblOrigem1.CAPTION = IIF(thisform.ORIGEM_PRODUTO(meuproduto)="N","nacional","importado")
		ENDIF

		lcProduto = ALLTRIM(vPRODUTO.PRODUTO)
		lcPack = ALLTRIM(vPRODUTO.CODIGO_PACK)
		thisform.monta_lista_pack(lcProduto, lcPack)		

	ENDPROC

	PROCEDURE ORIGEM_PRODUTO
		LPARAMETERS _produtoId
		oMetrica = CREATEOBJECT("funcoes_metricas")
		RETURN oMetrica.ORIGEM_PRODUTO(_produtoId)
	ENDPROC
		
	PROCEDURE requery_cursores_produtos
		SELECT v_produtos_99
		=REQUERY()

		SELECT V_PRODUTOS_00_PACKS_PERMITIDOS
		=REQUERY()

		SELECT V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL
		=REQUERY()	
		WAIT WINDOW NOWAIT "Cursores carregados..."

		f_select("select preco1 from PRODUTOS_precos where PRODUTO = ?meuproduto and CODIGO_TAB_PRECO = '00' ","caepreco")
		xcaepreco = caepreco.preco1

		TEXT TO lcSQL NOSHOW TEXTMERGE
			SELECT * 
			FROM PRODUTOS_PACKS_PERMITIDOS 
			WHERE PRODUTO = '<<meuproduto>>'
		ENDTEXT
		F_select(lcSQL, "vtmpProdutoPackPermitido")
		SELECT vtmpProdutoPackPermitido
		INDEX ON PACK + PRODUTO + COR_PRODUTO TAG INDX1
		SET ORDER TO TAG INDX1
				
		thisform.cntDadosProduto1.edtProduto.value = ALLTRIM(v_produtos_99.desc_produto)
		thisform.cntDadosProduto1.txtTotalPack.value = v_produtos_99.erp_qtd_pack
		thisform.cntDadosProduto1.txtCusto.value = xcaepreco
		thisform.cntDadosProduto1.Refresh
		
	ENDPROC

		
	PROCEDURE montaComboPack
		***
		* carrega dados no combobox de sele√ß√£o de pack
		*/
		SET SAFETY off
		SELECT vCboPack
		ZAP
		
		TEXT TO lcSQL NOSHOW TEXTMERGE
			SELECT distinct PACK AS CODIGO_PACK 
			FROM PRODUTOS_PACKS_PERMITIDOS 
			WHERE PRODUTO = '<<ALLTRIM(vPRODUTO.PRODUTO)>>'
		ENDTEXT
		F_SELECT(lcSQL,"tmpPackProduto1")
		
		SELECT vCboPack
		APPEND FROM DBF("tmpPackProduto1")			
		GO top
		REPLACE vPRODUTO.CODIGO_PACK WITH vCboPack.CODIGO_PACK 
		thisform.Refresh
		
	ENDPROC

	PROCEDURE txtQtdPack1.when
		thisform.cboPack1.valid()
		RETURN .t.
	ENDPROC

	PROCEDURE txtQtdPack1.valid

		thisform.calcula1()
		SELECT V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL
		GO top

		xtotpack  = V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.qtde

		thisform.txtQtdTotalPack1.Value = xtotpack  * (thisform.txtQtdPack1.Value)

		f_select("select preco1 from PRODUTOS_precos where PRODUTO = ?meuproduto and CODIGO_TAB_PRECO = '00' ","caepreco")
		xcaepreco = caepreco.preco1

		thisform.txtValorTotalPack1.Value  = thisform.txtQtdTotalPack1.Value * xcaepreco 
	ENDPROC
	

	PROCEDURE cboPack1.valid
		thisform.requery_cursores_produtos()
		
		SELECT vtmpProdutoPackPermitido
		GO top
		
		SCAN FOR ALLTRIM(PACK) = ALLTRIM(vPRODUTO.CODIGO_PACK)
			SELECT vtmpProdutoPackPermitido		
			SCATTER MEMVAR
			
			SELECT V_PRODUTOS_00_PACKS_PERMITIDOS
			LOCATE FOR ALLTRIM(PRODUTO) = ALLTRIM(vtmpProdutoPackPermitido.PRODUTO) ;
				AND ALLTRIM(COR_PRODUTO) = ALLTRIM(vtmpProdutoPackPermitido.COR_PRODUTO)
			IF FOUND()
				GATHER MEMVAR
				REPLACE INATIVO WITH 1
			ENDIF
						
			SELECT vtmpProdutoPackPermitido		
		ENDSCAN
		
		lcProduto = ALLTRIM(vPRODUTO.PRODUTO)
		lcPack = ALLTRIM(vPRODUTO.CODIGO_PACK)
		thisform.monta_lista_pack(lcProduto, lcPack)		
		
	ENDPROC
		
	*** ROTINAS DE CALCULO DA GRADE DE PACK ***
	
	PROCEDURE calcula1
		SELECT V_PRODUTOS_00_PACKS_PERMITIDOS
		*replace ALL inativo WITH 1
		GO top

		SUM qtde ,Q1, Q2, Q3, Q4,Q5, Q6, Q7, Q8,Q9, Q10, Q11, Q12,Q13, Q14, Q15, Q16,Q17, Q18, Q19, Q20,Q21, Q22, Q23, Q24,Q25, Q26, Q27, Q28 for inativo = 1 ;
			TO VCAEQTDE, VCAE1, VCAE2, VCAE3, VCAE4, VCAE5, VCAE6, VCAE7, VCAE8, VCAE9, VCAE10, VCAE11, VCAE12, VCAE13, VCAE14, VCAE15, VCAE16, VCAE17, ;
			VCAE18, VCAE19, VCAE20, VCAE21, VCAE22, VCAE23, VCAE24, VCAE25, VCAE26, VCAE27, VCAE28


		SELECT V_PRODUTOS_00_PACKS_PERMITIDOS_total

		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.qtde with VCAEqtde
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q1 with VCAE1
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q2 with VCAE2
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q3 with VCAE3
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q4 with VCAE4
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q5 with VCAE5
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q6 with VCAE6
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q7 with VCAE7
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q8 with VCAE8
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q9 with VCAE9
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q10 with VCAE10
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q11 with VCAE11
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q12 with VCAE12
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q13 with VCAE13
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q14 with VCAE14
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q15 with VCAE15
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q16 with VCAE16
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q17 with VCAE17
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q18 with VCAE18
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q19 with VCAE19
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q20 with VCAE20
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q21 with VCAE21
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q22 with VCAE22
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q23 with VCAE23
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q24 with VCAE24
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q25 with VCAE25
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q26 with VCAE26
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q27 with VCAE27
		replace V_PRODUTOS_00_PACKS_PERMITIDOS_total.Q28 with VCAE28

		thisform.lx_grade48_recalculo()
	
	ENDPROC
	
	PROCEDURE calcula2
		SELECT V_PRODUTOS_PACK_DISTRIB
		DELETE all
		 
		thisform.calcula1()

		IF thisform.txtQtdPack1.Value  > 0

			SELECT V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL
			GO top
			xtotpack =  V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.qtde
			xtotprod = thisform.txtQtdTotalPack1.Value

			SELECT v_produtos_00_packs_permitidos
			SCAN
				IF V_produtos_00_packs_permitidos.INATIVO = 1
					
					SELECT v_produtos_pack_distrib
					APPEND BLANK 

					replace v_produtos_pack_distrib.COR_PRODUTO WITH   v_produtos_00_packs_permitidos.COR_PRODUTO
					replace v_produtos_pack_distrib.DESC_COR_PRODUTO WITH   v_produtos_00_packs_permitidos.DESC_COR_PRODUTO
					replace v_produtos_pack_distrib.produto WITH   v_produtos_00_packs_permitidos.produto

					replace v_produtos_pack_distrib.qtde WITH   ((xtotprod  /xtotpack )* v_produtos_00_packs_permitidos.qtde )
					replace v_produtos_pack_distrib.Q1 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q1 )
					replace v_produtos_pack_distrib.Q2 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q2 )
					replace v_produtos_pack_distrib.Q3 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q3 )
					replace v_produtos_pack_distrib.Q4 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q4 )
					replace v_produtos_pack_distrib.Q5 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q5 )
					replace v_produtos_pack_distrib.Q6 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q6 )
					replace v_produtos_pack_distrib.Q7 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q7 )
					replace v_produtos_pack_distrib.Q8 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q8 )
					replace v_produtos_pack_distrib.Q9 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q9 )
					replace v_produtos_pack_distrib.Q10 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q10 )
					replace v_produtos_pack_distrib.Q11 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q11 )
					replace v_produtos_pack_distrib.Q12 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q12 )
					replace v_produtos_pack_distrib.Q13 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q13 )
					replace v_produtos_pack_distrib.Q14 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q14 )
					replace v_produtos_pack_distrib.Q15 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q15 )
					replace v_produtos_pack_distrib.Q16 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q16 )
					replace v_produtos_pack_distrib.Q17 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q17 )
					replace v_produtos_pack_distrib.Q18 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q18 )
					replace v_produtos_pack_distrib.Q19 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q19 )
					replace v_produtos_pack_distrib.Q20 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q20 )
					replace v_produtos_pack_distrib.Q21 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q21 )
					replace v_produtos_pack_distrib.Q22 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q22 )
					replace v_produtos_pack_distrib.Q23 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q23 )
					replace v_produtos_pack_distrib.Q24 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q24 )
					replace v_produtos_pack_distrib.Q25 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q25 )
					replace v_produtos_pack_distrib.Q26 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q26 )
					replace v_produtos_pack_distrib.Q27 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q27 )
					replace v_produtos_pack_distrib.Q28 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q28 )
					replace v_produtos_pack_distrib.Q29 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q29 )
					replace v_produtos_pack_distrib.Q30 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q30 )
					replace v_produtos_pack_distrib.Q31 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q31 )
					replace v_produtos_pack_distrib.Q32 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q32 )
					replace v_produtos_pack_distrib.Q33 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q33 )
					replace v_produtos_pack_distrib.Q34 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q34 )
					replace v_produtos_pack_distrib.Q35 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q35 )
					replace v_produtos_pack_distrib.Q36 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q36 )
					replace v_produtos_pack_distrib.Q37 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q37 )
					replace v_produtos_pack_distrib.Q38 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q38 )
					replace v_produtos_pack_distrib.Q39 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q39 )
					replace v_produtos_pack_distrib.Q40 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q40 )
					replace v_produtos_pack_distrib.Q41 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q41 )
					replace v_produtos_pack_distrib.Q42 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q42 )
					replace v_produtos_pack_distrib.Q43 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q43 )
					replace v_produtos_pack_distrib.Q44 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q44 )
					replace v_produtos_pack_distrib.Q45 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q45 )
					replace v_produtos_pack_distrib.Q46 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q46 )
					replace v_produtos_pack_distrib.Q47 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q47 )
					replace v_produtos_pack_distrib.Q48 WITH   ((xtotprod /xtotpack )* v_produtos_00_packs_permitidos.Q48 )
				ENDIF
			SELECT v_produtos_00_packs_permitidos	
			ENDSCAN
		ELSE
		ENDIF

		SELECT v_produtos_pack_distrib
		GO top

		thisform.Refresh()
	
	ENDPROC
			
	PROCEDURE lx_grade48_recalculo
		lPara xPara
		Local xQtde,xS,xQtde_Ant,xQtde_Atual
		Sele V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL

		xQtde = F_Tam()
		xQtde.Carga('Q#')
		Replace Qtde With xQtde.Soma_Grade()
	ENDPROC
	
	***
	* Preenche os dados do campo observa√ß√£o do pedido, com as informa√ß√µes 
	* da grade de pack do produto
	*/
	PROCEDURE preenche_obs_pack
		LOCAL lcObs, lnArea
		lnArea = SELECT()

		IF ALLTRIM(NVL(V_COMPRAS_01.ERP_CUPS_SEGMENTO,"")) = "VAREJO" && OBS. somente √© preenchido para o segmento VAREJO -> PAULO DEVID√â - 25-08-2015

			SELECT v_caedu_compras_produtos_packs
			GO top

			** variavel que acumula as observa√ß√µes de cada linha
			lcObs = ALLTRIM(V_COMPRAS_01.OBS)+CHR(13)+CHR(13)+;
				'PACK:'+CHR(13)+;
				REPLICATE('-',120)+CHR(13)


			SCAN

				zret = ""

				F_SELECT("SELECT * FROM PRODUTOS WHERE PRODUTO=?v_caedu_compras_produtos_packs.produto","tmpProduto1")

				zgrade = ""
				IF RECCOUNT("tmpProduto1")>0
					STORE UPPER(ALLTRIM(tmpProduto1.grade)) TO zgrade
				ENDIF

				SELECT v_produtos_tamanho_00
				LOCATE FOR UPPER(ALLTRIM(grade)) = zgrade
				ztam_digitados = v_produtos_tamanho_00.tamanhos_digitados

				FOR ii=1 TO ztam_digitados

					ztamanho = "TAMANHO_"+ALLTRIM(TRANSFORM(ii,"99"))
					IF RIGHT(ALLTRIM(NVL(EVALUATE(ztamanho),"")),1)="."
						ztam1 = ""
					ELSE
						ztam1 = ALLTRIM(NVL(EVALUATE(ztamanho),""))
						zq = "NVL(v_caedu_compras_produtos_packs.q"+ALLTRIM(TRANSFORM(ii,"99"))+",0)"
						ztam1 = ztam1 + "=" + ALLTRIM(TRANSFORM(EVALUATE(zq),"99999"))
					ENDIF

					zret= zret + ztam1 + IIF(EMPTY(ztam1),""," / ")

				ENDFOR

				IF RIGHT(ALLTRIM(zret),1)="/"
					zret = LEFT(zret,LEN(zret)-2)
				ENDIF
				zret = ALLTRIM(v_caedu_compras_produtos_packs.DESC_COR_PRODUTO)+": "+ zret + " TOTAL = "+;
					TRANSFORM(v_caedu_compras_produtos_packs.qtde,"9999") + CHR(13)
				lcObs = lcObs + zret

			ENDSCAN


			SELECT V_COMPRAS_01
			IF NOT EMPTY(lcObs)
				replace V_COMPRAS_01.OBS WITH lcObs
			ENDIF
			
			thisform.objTelaPai.lx_form1.lx_pageframe1.Page5.ed_obs.refresh

			SELECT (lnArea)

		ENDIF


	ENDPROC
	

	***
	* Grava o produto selecionado na tabela compras_produto
	*/	
	PROCEDURE inserir_produto
		IF RECCOUNT("V_PRODUTOS_PACK_DISTRIB")<= 0
			RETURN .f.
		endif

		IF UPPER(ALLTRIM(v_compras_01.ERP_CUPS_SEGMENTO)) = "ATACADO"
			lcMessage = ""

			IF EMPTY(NVL(vPRODUTO.CUSTOFOB,0))
				lcMessage = lcMessage + "Campo Custo Fob deve ser preenchido para o segmento ATACADO" + REPLICATE(CHR(13),2)
			ENDIF

			IF !EMPTY(lcMessage)
				MESSAGEBOX(lcMessage,16,"Aviso")
				RETURN .f.
			ENDIF

		ENDIF

		SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS
		IF UPPER(ALLTRIM(v_compras_01.ERP_CUPS_SEGMENTO)) <> "ATACADO"
			DELETE ALL
		ENDIF

		SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL
		IF UPPER(ALLTRIM(v_compras_01.ERP_CUPS_SEGMENTO)) <> "ATACADO"
			DELETE ALL
		ENDIF

		SELECT v_produtos_00_packs_permitidos
		SCAN
			IF V_produtos_00_packs_permitidos.INATIVO = 1

				SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS
				APPEND BLANK

				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Pedido WITH   v_compras_01.PEDIDO
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.COR_PRODUTO WITH   v_produtos_00_packs_permitidos.COR_PRODUTO
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.DESC_COR_PRODUTO WITH   v_produtos_00_packs_permitidos.DESC_COR_PRODUTO
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.produto WITH   v_produtos_00_packs_permitidos.produto

				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.qtde WITH   v_produtos_00_packs_permitidos.qtde
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q1 WITH    v_produtos_00_packs_permitidos.Q1
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q2 WITH    v_produtos_00_packs_permitidos.Q2
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q3 WITH    v_produtos_00_packs_permitidos.Q3
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q4 WITH    v_produtos_00_packs_permitidos.Q4
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q5 WITH    v_produtos_00_packs_permitidos.Q5
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q6 WITH    v_produtos_00_packs_permitidos.Q6
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q7 WITH    v_produtos_00_packs_permitidos.Q7
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q8 WITH    v_produtos_00_packs_permitidos.Q8
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q9 WITH    v_produtos_00_packs_permitidos.Q9
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q10 WITH    v_produtos_00_packs_permitidos.Q10
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q11 WITH    v_produtos_00_packs_permitidos.Q11
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q12 WITH    v_produtos_00_packs_permitidos.Q12
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q13 WITH    v_produtos_00_packs_permitidos.Q13
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q14 WITH    v_produtos_00_packs_permitidos.Q14
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q15 WITH    v_produtos_00_packs_permitidos.Q15
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q16 WITH    v_produtos_00_packs_permitidos.Q16
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q17 WITH    v_produtos_00_packs_permitidos.Q17
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q18 WITH    v_produtos_00_packs_permitidos.Q18
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q19 WITH    v_produtos_00_packs_permitidos.Q19
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q20 WITH    v_produtos_00_packs_permitidos.Q20
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q21 WITH    v_produtos_00_packs_permitidos.Q21
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q22 WITH    v_produtos_00_packs_permitidos.Q22
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q23 WITH    v_produtos_00_packs_permitidos.Q23
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q24 WITH    v_produtos_00_packs_permitidos.Q24
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q25 WITH    v_produtos_00_packs_permitidos.Q25
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q26 WITH    v_produtos_00_packs_permitidos.Q26
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q27 WITH    v_produtos_00_packs_permitidos.Q27
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q28 WITH    v_produtos_00_packs_permitidos.Q28
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q29 WITH    v_produtos_00_packs_permitidos.Q29
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q30 WITH    v_produtos_00_packs_permitidos.Q30
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q31 WITH    v_produtos_00_packs_permitidos.Q31
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q32 WITH    v_produtos_00_packs_permitidos.Q32
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q33 WITH    v_produtos_00_packs_permitidos.Q33
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q34 WITH    v_produtos_00_packs_permitidos.Q34
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q35 WITH    v_produtos_00_packs_permitidos.Q35
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q36 WITH    v_produtos_00_packs_permitidos.Q36
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q37 WITH    v_produtos_00_packs_permitidos.Q37
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q38 WITH    v_produtos_00_packs_permitidos.Q38
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q39 WITH    v_produtos_00_packs_permitidos.Q39
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q40 WITH    v_produtos_00_packs_permitidos.Q40
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q41 WITH    v_produtos_00_packs_permitidos.Q41
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q42 WITH    v_produtos_00_packs_permitidos.Q42
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q43 WITH    v_produtos_00_packs_permitidos.Q43
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q44 WITH    v_produtos_00_packs_permitidos.Q44
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q45 WITH    v_produtos_00_packs_permitidos.Q45
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q46 WITH    v_produtos_00_packs_permitidos.Q46
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q47 WITH    v_produtos_00_packs_permitidos.Q47
				replace V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q48 WITH    v_produtos_00_packs_permitidos.Q48

			ENDIF
			SELECT v_produtos_00_packs_permitidos
		ENDSCAN

		SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS
		GO top

		SELECT V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL
		SCAN

			SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL
			APPEND BLANK

			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Pedido WITH   v_compras_01.PEDIDO
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.produto WITH   V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.produto
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.qtde WITH   V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.qtde
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q1 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q1
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q2 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q2
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q3 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q3
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q4 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q4
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q5 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q5
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q6 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q6
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q7 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q7
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q8 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q8
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q9 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q9
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q10 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q10
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q11 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q11
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q12 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q12
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q13 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q13
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q14 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q14
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q15 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q15
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q16 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q16
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q17 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q17
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q18 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q18
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q19 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q19
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q20 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q20
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q21 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q21
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q22 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q22
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q23 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q23
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q24 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q24
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q25 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q25
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q26 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q26
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q27 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q27
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q28 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q28
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q29 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q29
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q30 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q30
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q31 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q31
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q32 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q32
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q33 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q33
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q34 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q34
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q35 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q35
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q36 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q36
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q37 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q37
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q38 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q38
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q39 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q39
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q40 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q40
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q41 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q41
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q42 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q42
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q43 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q43
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q44 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q44
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q45 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q45
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q46 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q46
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q47 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q47
			replace V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q48 WITH    V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL.Q48
			SELECT V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL
		ENDSCAN

		sele V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL
		go top
		

		
		SELECT V_PRODUTOS_PACK_DISTRIB
		GO top
		SCAN
			xProduto = Alltrim( V_PRODUTOS_PACK_DISTRIB.PRODUTO )
			xcor_produto =  Alltrim( V_PRODUTOS_PACK_DISTRIB.cor_PRODUTO )
			If F_Select('SELECT PRODUTO, COR_PRODUTO, DESC_COR_PRODUTO, SORTIMENTO_COR FROM PRODUTO_CORES where produto = ?xProduto and cor_produto = ?cor_produto ','xCurCor')
				If Reccount('xCurCor') > 0

					Select xCurCor
					Scan
						Select V_Compras_01_Produtos
						Append Blank
						thisform.objTelaPai.l_desenhista_filhas_inclui_apos()

						Replace Produto 	 With xCurCor.Produto, ;
							Cor_Produto 	 With xCurCor.Cor_Produto, ;
							Desc_Cor_Produto With xCurCor.Desc_Cor_Produto, ;
							Sortimento_cor   With xCurCor.SORTIMENTO_COR, ;
							REQUISICAO       With NULL In v_Compras_01_Produtos
							
						thisform.objTelaPai.LX_Form1.lx_pageframe1.page4.tv_COR_PRODUTO.l_desenhista_recalculo()

						SELECT xCurCor
					endscan
				endif
			endif
			SELECT V_PRODUTOS_PACK_DISTRIB
		ENDSCAN

		******************************************************************************************************************************************

		SELECT v_produtos_pack_distrib
		SCAN

			SELECT v_compras_01_produtos
			GO top
			LOCATE FOR v_produtos_pack_distrib.produto = v_compras_01_produtos.produto  AND ;
				v_produtos_pack_distrib.cor_produto = v_compras_01_produtos.cor_produto
			IF FOUND()

				f_select('select * from produtos where produto = ?v_produtos_pack_distrib.produto ', 'xydesc')

				SELECT V_COMPRAS_01_PRODUTOS


				replace V_COMPRAS_01_PRODUTOS.DESC_PRODUTO WITH xydesc.desc_produto
				replace V_COMPRAS_01_PRODUTOS.entrega	WITH thisform.objTelaPai.lx_foRM1.lx_PAGEFRAME1.page1.tx_ENTREGA_UNICA.Value
				replace V_COMPRAS_01_PRODUTOS.limite_entrega	WITH thisform.objTelaPai.lx_foRM1.lx_PAGEFRAME1.page1.tx_lIMITE_ENTREGA_UNICA.Value

				replace V_COMPRAS_01_PRODUTOS.packs WITH vPRODUTO.CODIGO_PACK
				
				*** Comentado em 26/10/2017
				*** Edi√ß√£o destes campos ser√° feita na Aba Itens do Pedido de Compras, registro a registro
				*** atualiza segunda cor
				*!*replace V_COMPRAS_01_PRODUTOS.ERP_CONJUNTO WITH vPRODUTO.ERP_CONJUNTO 
				*!*replace V_COMPRAS_01_PRODUTOS.ERP_COR_PRODUTO2 WITH vPRODUTO.ERP_COR_PRODUTO2 
				**
				
				replace v_compras_01_produtos.CO1 WITH   v_produtos_pack_distrib.Q1
				replace v_compras_01_produtos.CO2 WITH   v_produtos_pack_distrib.Q2
				replace v_compras_01_produtos.CO3 WITH   v_produtos_pack_distrib.Q3
				replace v_compras_01_produtos.CO4 WITH   v_produtos_pack_distrib.Q4
				replace v_compras_01_produtos.CO5 WITH   v_produtos_pack_distrib.Q5
				replace v_compras_01_produtos.CO6 WITH   v_produtos_pack_distrib.Q6
				replace v_compras_01_produtos.CO7 WITH   v_produtos_pack_distrib.Q7
				replace v_compras_01_produtos.CO8 WITH   v_produtos_pack_distrib.Q8
				replace v_compras_01_produtos.CO9 WITH   v_produtos_pack_distrib.Q9
				replace v_compras_01_produtos.CO10 WITH   v_produtos_pack_distrib.Q10
				replace v_compras_01_produtos.CO11 WITH   v_produtos_pack_distrib.Q11
				replace v_compras_01_produtos.CO12 WITH   v_produtos_pack_distrib.Q12
				replace v_compras_01_produtos.CO13 WITH   v_produtos_pack_distrib.Q13
				replace v_compras_01_produtos.CO14 WITH   v_produtos_pack_distrib.Q14
				replace v_compras_01_produtos.CO15 WITH   v_produtos_pack_distrib.Q15
				replace v_compras_01_produtos.CO16 WITH   v_produtos_pack_distrib.Q16
				replace v_compras_01_produtos.CO17 WITH   v_produtos_pack_distrib.Q17
				replace v_compras_01_produtos.CO18 WITH   v_produtos_pack_distrib.Q18
				replace v_compras_01_produtos.CO19 WITH   v_produtos_pack_distrib.Q19
				replace v_compras_01_produtos.CO20 WITH   v_produtos_pack_distrib.Q20
				replace v_compras_01_produtos.CO21 WITH   v_produtos_pack_distrib.Q21
				replace v_compras_01_produtos.CO22 WITH   v_produtos_pack_distrib.Q22
				replace v_compras_01_produtos.CO23 WITH   v_produtos_pack_distrib.Q23
				replace v_compras_01_produtos.CO24 WITH   v_produtos_pack_distrib.Q24
				replace v_compras_01_produtos.CO25 WITH   v_produtos_pack_distrib.Q25
				replace v_compras_01_produtos.CO26 WITH   v_produtos_pack_distrib.Q26
				replace v_compras_01_produtos.CO27 WITH   v_produtos_pack_distrib.Q27
				replace v_compras_01_produtos.CO28 WITH   v_produtos_pack_distrib.Q28
				replace v_compras_01_produtos.CO29 WITH   v_produtos_pack_distrib.Q29
				replace v_compras_01_produtos.CO30 WITH   v_produtos_pack_distrib.Q30
				replace v_compras_01_produtos.CO31 WITH   v_produtos_pack_distrib.Q31
				replace v_compras_01_produtos.CO32 WITH   v_produtos_pack_distrib.Q32
				replace v_compras_01_produtos.CO33 WITH   v_produtos_pack_distrib.Q33
				replace v_compras_01_produtos.CO34 WITH   v_produtos_pack_distrib.Q34
				replace v_compras_01_produtos.CO35 WITH   v_produtos_pack_distrib.Q35
				replace v_compras_01_produtos.CO36 WITH   v_produtos_pack_distrib.Q36
				replace v_compras_01_produtos.CO37 WITH   v_produtos_pack_distrib.Q37
				replace v_compras_01_produtos.CO38 WITH   v_produtos_pack_distrib.Q38
				replace v_compras_01_produtos.CO39 WITH   v_produtos_pack_distrib.Q39
				replace v_compras_01_produtos.CO40 WITH   v_produtos_pack_distrib.Q40
				replace v_compras_01_produtos.CO41 WITH   v_produtos_pack_distrib.Q41
				replace v_compras_01_produtos.CO42 WITH   v_produtos_pack_distrib.Q42
				replace v_compras_01_produtos.CO43 WITH   v_produtos_pack_distrib.Q43
				replace v_compras_01_produtos.CO44 WITH   v_produtos_pack_distrib.Q44
				replace v_compras_01_produtos.CO45 WITH   v_produtos_pack_distrib.Q45
				replace v_compras_01_produtos.CO46 WITH   v_produtos_pack_distrib.Q46
				replace v_compras_01_produtos.CO47 WITH   v_produtos_pack_distrib.Q47
				replace v_compras_01_produtos.CO48 WITH   v_produtos_pack_distrib.Q48
				replace v_compras_01_produtos.CE1 WITH   v_produtos_pack_distrib.Q1
				replace v_compras_01_produtos.CE2 WITH   v_produtos_pack_distrib.Q2
				replace v_compras_01_produtos.CE3 WITH   v_produtos_pack_distrib.Q3
				replace v_compras_01_produtos.CE4 WITH   v_produtos_pack_distrib.Q4
				replace v_compras_01_produtos.CE5 WITH   v_produtos_pack_distrib.Q5
				replace v_compras_01_produtos.CE6 WITH   v_produtos_pack_distrib.Q6
				replace v_compras_01_produtos.CE7 WITH   v_produtos_pack_distrib.Q7
				replace v_compras_01_produtos.CE8 WITH   v_produtos_pack_distrib.Q8
				replace v_compras_01_produtos.CE9 WITH   v_produtos_pack_distrib.Q9
				replace v_compras_01_produtos.CE10 WITH   v_produtos_pack_distrib.Q10
				replace v_compras_01_produtos.CE11 WITH   v_produtos_pack_distrib.Q11
				replace v_compras_01_produtos.CE12 WITH   v_produtos_pack_distrib.Q12
				replace v_compras_01_produtos.CE13 WITH   v_produtos_pack_distrib.Q13
				replace v_compras_01_produtos.CE14 WITH   v_produtos_pack_distrib.Q14
				replace v_compras_01_produtos.CE15 WITH   v_produtos_pack_distrib.Q15
				replace v_compras_01_produtos.CE16 WITH   v_produtos_pack_distrib.Q16
				replace v_compras_01_produtos.CE17 WITH   v_produtos_pack_distrib.Q17
				replace v_compras_01_produtos.CE18 WITH   v_produtos_pack_distrib.Q18
				replace v_compras_01_produtos.CE19 WITH   v_produtos_pack_distrib.Q19
				replace v_compras_01_produtos.CE20 WITH   v_produtos_pack_distrib.Q20
				replace v_compras_01_produtos.CE21 WITH   v_produtos_pack_distrib.Q21
				replace v_compras_01_produtos.CE22 WITH   v_produtos_pack_distrib.Q22
				replace v_compras_01_produtos.CE23 WITH   v_produtos_pack_distrib.Q23
				replace v_compras_01_produtos.CE24 WITH   v_produtos_pack_distrib.Q24
				replace v_compras_01_produtos.CE25 WITH   v_produtos_pack_distrib.Q25
				replace v_compras_01_produtos.CE26 WITH   v_produtos_pack_distrib.Q26
				replace v_compras_01_produtos.CE27 WITH   v_produtos_pack_distrib.Q27
				replace v_compras_01_produtos.CE28 WITH   v_produtos_pack_distrib.Q28
				replace v_compras_01_produtos.CE29 WITH   v_produtos_pack_distrib.Q29
				replace v_compras_01_produtos.CE30 WITH   v_produtos_pack_distrib.Q30
				replace v_compras_01_produtos.CE31 WITH   v_produtos_pack_distrib.Q31
				replace v_compras_01_produtos.CE32 WITH   v_produtos_pack_distrib.Q32
				replace v_compras_01_produtos.CE33 WITH   v_produtos_pack_distrib.Q33
				replace v_compras_01_produtos.CE34 WITH   v_produtos_pack_distrib.Q34
				replace v_compras_01_produtos.CE35 WITH   v_produtos_pack_distrib.Q35
				replace v_compras_01_produtos.CE36 WITH   v_produtos_pack_distrib.Q36
				replace v_compras_01_produtos.CE37 WITH   v_produtos_pack_distrib.Q37
				replace v_compras_01_produtos.CE38 WITH   v_produtos_pack_distrib.Q38
				replace v_compras_01_produtos.CE39 WITH   v_produtos_pack_distrib.Q39
				replace v_compras_01_produtos.CE40 WITH   v_produtos_pack_distrib.Q40
				replace v_compras_01_produtos.CE41 WITH   v_produtos_pack_distrib.Q41
				replace v_compras_01_produtos.CE42 WITH   v_produtos_pack_distrib.Q42
				replace v_compras_01_produtos.CE43 WITH   v_produtos_pack_distrib.Q43
				replace v_compras_01_produtos.CE44 WITH   v_produtos_pack_distrib.Q44
				replace v_compras_01_produtos.CE45 WITH   v_produtos_pack_distrib.Q45
				replace v_compras_01_produtos.CE46 WITH   v_produtos_pack_distrib.Q46
				replace v_compras_01_produtos.CE47 WITH   v_produtos_pack_distrib.Q47
				replace v_compras_01_produtos.CE48 WITH   v_produtos_pack_distrib.Q48

				***
				* projeto CUPS
				*/
				replace v_compras_01_produtos.GRADE WITH ALLTRIM(NVL(xydesc.grade,''))
				***
				* verificar estes 2 campos abaixo - 26/08/2016
				*/
				**replace v_compras_01_produtos.ERP_CUPS_PACKS_POR_CAIXA with thisform.objTelaPai.lx_form1.lx_pageframe1.page20.txt_qtd_caixas1.value
				replace v_compras_01_produtos.ERP_CUPS_CUSTO_FOB with vPRODUTO.CUSTOFOB &&thisform.objTelaPai.lx_form1.lx_pageframe1.page20.txt_custo_fob1.value
				replace v_compras_01_produtos.ERP_CUPS_CUSTO_FOB_MINIMO with vPRODUTO.FOBMINIMO &&thisform.objTelaPai.lx_form1.lx_pageframe1.page20.txt_custo_fob1.value
				************************************************************************************************************************************

				xtoty  =  v_compras_01_produtos.CO1 + v_compras_01_produtos.CO2 +  v_compras_01_produtos.CO3 +  ;
					v_compras_01_produtos.CO4 + v_compras_01_produtos.CO5 +  v_compras_01_produtos.CO6 +  ;
					v_compras_01_produtos.CO7 +  v_compras_01_produtos.CO8 +  v_compras_01_produtos.CO9 +  ;
					v_compras_01_produtos.CO10 +  v_compras_01_produtos.CO11 +  v_compras_01_produtos.CO12 +  ;
					v_compras_01_produtos.CO13 +  v_compras_01_produtos.CO14 +  v_compras_01_produtos.CO15 +  ;
					v_compras_01_produtos.CO16 +  v_compras_01_produtos.CO17 +  v_compras_01_produtos.CO18 +  ;
					v_compras_01_produtos.CO19 +  v_compras_01_produtos.CO20 +  v_compras_01_produtos.CO21 +  ;
					v_compras_01_produtos.CO22 +  v_compras_01_produtos.CO23 +  v_compras_01_produtos.CO24 +  ;
					v_compras_01_produtos.CO25 +  v_compras_01_produtos.CO26 +  v_compras_01_produtos.CO27 +  ;
					v_compras_01_produtos.CO28 +  v_compras_01_produtos.CO29 +  v_compras_01_produtos.CO30 +  ;
					v_compras_01_produtos.CO31 +  v_compras_01_produtos.CO32 +  v_compras_01_produtos.CO33 +  ;
					v_compras_01_produtos.CO34 +  v_compras_01_produtos.CO35 +  v_compras_01_produtos.CO36 +  ;
					v_compras_01_produtos.CO37 +  v_compras_01_produtos.CO38 +  v_compras_01_produtos.CO39 +  ;
					v_compras_01_produtos.CO40 +  v_compras_01_produtos.CO41 +  v_compras_01_produtos.CO42 +  ;
					v_compras_01_produtos.CO43 +  v_compras_01_produtos.CO44 +  v_compras_01_produtos.CO45 +  ;
					v_compras_01_produtos.CO46 +  v_compras_01_produtos.CO47 +  v_compras_01_produtos.CO48

				replace v_compras_01_produtos.qtde_entregar WITH   xtoty
				replace v_compras_01_produtos.qtde_original WITH   xtoty
				replace v_compras_01_produtos.valor_entregar WITH   v_compras_01_produtos.custo1 * xtoty
				replace v_compras_01_produtos.valor_original WITH   v_compras_01_produtos.custo1 * xtoty

				***
				*  CARREGA OS DADOS DO REGISTRO EXCLUIDO PARA O NOVO REGISTRO A SER INCLUIDO
				*  CASO O PRODUTO INCLUIDO SEJA O MESMO QUE FOI EXCLUIDO
				*  ERP_PERC_MARGEM
				*  ERP_CONJUNTO
				*  ERP_COR_PRODUTO2
				*  CUSTO1
				*  ENTREGA
				*  LIMITE_ENTREGA
				*/
				*!* SET STEP ON
				IF thisform.objTelaPai.EXCLUIU_ITENS
					SELECT v_compras_01_produtos_excluidos
					GO top
					LOCATE FOR v_compras_01_produtos_excluidos.produto=v_compras_01_produtos.produto  AND ;
						v_compras_01_produtos_excluidos.cor_produto = v_compras_01_produtos.cor_produto	 ;
						AND ALLTRIM(v_compras_01_produtos_excluidos.packs)=ALLTRIM(v_compras_01_produtos.packs)
										
					IF FOUND()
						SELECT v_compras_01_produtos
						replace v_compras_01_produtos.ERP_PERC_MARGEM WITH v_compras_01_produtos_excluidos.ERP_PERC_MARGEM
						replace v_compras_01_produtos.ERP_CONJUNTO WITH v_compras_01_produtos_excluidos.ERP_CONJUNTO
						replace v_compras_01_produtos.ERP_COR_PRODUTO2 WITH v_compras_01_produtos_excluidos.ERP_COR_PRODUTO2
						replace v_compras_01_produtos.CUSTO1 WITH v_compras_01_produtos_excluidos.CUSTO1
						replace v_compras_01_produtos.ENTREGA WITH v_compras_01_produtos_excluidos.ENTREGA
						replace v_compras_01_produtos.LIMITE_ENTREGA WITH v_compras_01_produtos_excluidos.LIMITE_ENTREGA
					ENDIF	
					
				ENDIF

			endif
		ENDSCAN

		SELECT v_compras_01_produtos
		GO top

		*meuproduto = 'xpto'
		SELECT V_PRODUTOS_00_PACKS_PERMITIDOS
		=REQUERY()

		SELECT V_PRODUTOS_00_PACKS_PERMITIDOS_TOTAL
		=REQUERY()


		SELECT V_PRODUTOS_PACK_DISTRIB
		DELETE ALL

		*!*			this.Parent.TExt1.Value =0
		*!*			this.Parent.TExt2.Value =0
		*!*			this.Parent.TExt3.Value =0
		*!*			this.Parent.TExt4.Value =''


		** PAULO DEVIDE 12/08/2014 ****
		*>>>>>>>>>>thisform.objTelaPai.preenche_obs_pack()
		thisform.preenche_obs_pack()
		*******************************

		thisform.atualiza_qtd_caixa()
		
		RETURN .T.

	ENDPROC
	
	FUNCTION valida_dados_umode
*!*				*/		
*!*				f_select('select * from produtos where produto = ?v_compras_01_produtos.produto', 'vumode_produto')
*!*				f_select('select FORNECEDOR,FILIAL_A_ENTREGAR,FILIAL_COBRANCA,FILIAL_A_FATURAR from fornecedores where FORNECEDOR = ?vumode_produto.fabricante', 'vumode_fornec')

*!*				** array com valores do cadastro de produtos **
*!*				DECLARE a_umode_prod[10]
*!*				a_umode_prod[1]= vumode_produto.requerido_por
*!*				a_umode_prod[2]= vumode_produto.tipo_compra
*!*				a_umode_prod[3]= NVL(vumode_produto.ERP_CAB_OPCAO,1)
*!*				a_umode_prod[4]= NVL(vumode_produto.ERP_CAB_COD_CABIDE,'')
*!*				a_umode_prod[5]= NVL(vumode_produto.fabricante,'')
*!*				a_umode_prod[6]= NVL(vumode_fornec.FILIAL_A_ENTREGAR,'')
*!*				a_umode_prod[7]= NVL(vumode_fornec.FILIAL_COBRANCA,'MATRIZ')
*!*				a_umode_prod[8]= NVL(vumode_fornec.FILIAL_A_FATURAR,'')
*!*				a_umode_prod[9]= NVL(vumode_produto.ERP_CUPS_CUSTO_FOB,0)
*!*				a_umode_prod[10]= NVL(vumode_produto.ERP_CUPS_CUSTO_FOB_MINIMO,0)
			
*!*			lRet = .t.	
*!*			lcMessage = ""
*!*			** valida requerido por
*!*			IF !(ALLTRIM(NVL(vumode_produto.requerido_por,"...")) $ ZZ_LISTA_GERENTES)	
*!*				lRet = .f.
*!*				lcMessage = lcMessage + "requerido por n„o preenchido na uMode"
*!*			ENDIF
*!*			** valida tipo_compra
*!*			IF !(ALLTRIM(NVL(vumode_produto.tipo_compra,"...")) $ ZZ_LISTA_GERENTES)	
*!*				lRet = .f.
*!*				lcMessage = lcMessage + "requerido por n„o preenchido na uMode"
*!*			ENDIF
*!*				
*!*			RETURN lRet
	ENDFUNC 
	
	PROCEDURE atualiza_qtd_caixa
		lnArea = SELECT()
		SELECT v_compras_01_produtos
		GO top
		
		lnQtd = 0
		SCAN
			lnQtd = lnQtd + v_compras_01_produtos.QTDE_ORIGINAL
		ENDSCAN
		
		IF V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.qtde > 0
			
			lnTotalCaixas = (lnQtd / V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.qtde)
			SELECT v_compras_01
			replace v_compras_01.ERP_TOTAL_CAIXAS_ORIGINAL WITH lnTotalCaixas
			replace v_compras_01.ERP_PERCENT_DISTRIB WITH 100.000000
			replace v_compras_01.ERP_TOTAL_QTD_DISTRIB WITH lnTotalCaixas
			
		ENDIF
		
		SELECT v_compras_01_produtos
		GO top
		SELECT (lnArea)

		nOptPerguntaUmode = 6
		IF thisform.objTelaPai.PP_palma_pergunta_umode_plm = .T.
			nOptPerguntaUmode = MESSAGEBOX("Deseja carregar os dados vindos da uMode /PLM para o pedido de compras?",292,"Aviso")
		ENDIF
		
		** ESTE PARAMETRO VALIDA SE VAI TRAZER OS DADOS DE PEDIDOS DA UMODE OU N√O (DEFAULT = .F.)
		cmdsql = "EXEC CGP_VALIDA_PEDIDO_UMODE '"+ALLTRIM(v_compras_01_produtos.produto)+"'"
		F_select(cmdsql, "curVerificarUmode")
		
*!*			STATUS_UMODE	MENSAGEM
*!*				OK	

		IF (thisform.objTelaPai.PP_habilita_pedido_umode_plm = .T.) ;
			AND (ALLTRIM(curVerificarUmode.STATUS_UMODE)=="OK") AND (nOptPerguntaUmode = 6)&& tudo certinho
			** busca dados do produto (aba pedido) -> 23-03-2023
			*/		
			f_select('select * from produtos where produto = ?v_compras_01_produtos.produto', 'vumode_produto')
			f_select('select FORNECEDOR,FILIAL_A_ENTREGAR,FILIAL_COBRANCA,FILIAL_A_FATURAR from fornecedores where FORNECEDOR = ?vumode_produto.fabricante', 'vumode_fornec')

			** array com valores do cadastro de produtos **
			DECLARE a_umode_prod[10]
			a_umode_prod[1]= vumode_produto.requerido_por
			a_umode_prod[2]= vumode_produto.tipo_compra
			a_umode_prod[3]= NVL(vumode_produto.ERP_CAB_OPCAO,1)
			a_umode_prod[4]= NVL(vumode_produto.ERP_CAB_COD_CABIDE,'')
			a_umode_prod[5]= NVL(vumode_produto.fabricante,'')
			a_umode_prod[6]= NVL(vumode_fornec.FILIAL_A_ENTREGAR,'')
			a_umode_prod[7]= NVL(vumode_fornec.FILIAL_COBRANCA,'MATRIZ')
			a_umode_prod[8]= NVL(vumode_fornec.FILIAL_A_FATURAR,'')
			a_umode_prod[9]= NVL(vumode_produto.ERP_CUPS_CUSTO_FOB,0)
			a_umode_prod[10]= NVL(vumode_produto.ERP_CUPS_CUSTO_FOB_MINIMO,0)
			
			TEXT TO cTexto1 NOSHOW TEXTMERGE PRETEXT 7
			Produto = <<vumode_produto.produto + " - " + vumode_produto.desc_produto>>
			Requerido Por = <<vumode_produto.requerido_por>>
			Tipo de Compra = <<vumode_produto.tipo_compra>>
			OpÁ„o Cabide/Alarme = <<vumode_produto.ERP_CAB_OPCAO>>
			CÛdigo Cabide = <<vumode_produto.ERP_CAB_COD_CABIDE>>
			Fornecedor = <<vumode_produto.fabricante>>
			Filial a Entregar = <<vumode_fornec.FILIAL_A_ENTREGAR>>
			Filial de CobranÁa = <<vumode_fornec.FILIAL_COBRANCA>>
			Filial a Faturar = <<vumode_fornec.FILIAL_A_FATURAR>>		
			Custo FOB = <<vumode_produto.ERP_CUPS_CUSTO_FOB>>
			Custo FOB Minimo = <<vumode_produto.ERP_CUPS_CUSTO_FOB_MINIMO>>
			ENDTEXT
			
		
	        replace v_compras_01.requerido_por 		WITH a_umode_prod[1]
	        replace v_compras_01.tipo_compra   		WITH a_umode_prod[2]
	        replace v_compras_01.ERP_CAB_OPCAO 		WITH a_umode_prod[3]
	        replace v_compras_01.ERP_CAB_COD_CABIDE WITH a_umode_prod[4]
	        replace v_compras_01.fornecedor 		WITH a_umode_prod[5]
	        replace v_compras_01.FILIAL_A_ENTREGAR	WITH a_umode_prod[6]
	        replace v_compras_01.FILIAL_COBRANCA	WITH a_umode_prod[7]
	        replace v_compras_01.FILIAL_A_FATURAR	WITH a_umode_prod[8]
	        xprod1 = v_compras_01_produtos.produto
	        replace v_compras_01_produtos.ERP_CUPS_CUSTO_FOB WITH a_umode_prod[9] FOR v_compras_01_produtos.PRODUTO = xprod1
	        replace v_compras_01_produtos.ERP_CUPS_CUSTO_FOB_MINIMO WITH a_umode_prod[10] FOR v_compras_01_produtos.PRODUTO = xprod1
	        
	        ** cabilog **
*!*		        IF v_compras_01.ERP_CAB_OPCAO>1 && 1/nenhum - 2/so cabide - 3/sÛ alarme - 4/alarme + cabide
*!*		        
*!*		        	IF Inlist(thisform.objTelaPai.p_Tool_Status, "A","I")
*!*			        	replace v_compras_01.erp_cab_status WITH "A"
*!*			        	replace v_compras_01.erp_cab_localizacao WITH "PAREDE"
*!*			        	replace v_compras_01.erp_cab_tipo_pedido WITH "NORMAL"
*!*			        	replace v_compras_01.erp_cab_cd_entrega WITH "64"
*!*		        	ENDIF
*!*		        	
*!*		        ENDIF
	        
	        
	        
			MESSAGEBOX(cTexto1, 64,"Aviso")
			
			WITH thisform.objTelaPai
			
				.lx_FORM1.tv_FORNECEDOR.l_desenhista_recalculo()
				.Lx_form1.Lx_pageframe1.Page1.tx_ENTREGA_UNICA.value=TTOD(vumode_produto.erp_entrega)
				.Lx_form1.Lx_pageframe1.Page1.tx_LIMITE_ENTREGA_UNICA.value=TTOD(vumode_produto.erp_limite_entrega)
				.Lx_form1.Lx_pageframe1.Page1.tx_ENTREGA_UNICA.l_desenhista_recalculo()
				.Lx_form1.Lx_pageframe1.Page1.tx_LIMITE_ENTREGA_UNICA.l_desenhista_recalculo()
				.Lx_form1.Lx_pageframe1.Page1.TV_TIPO_COMPRA.l_desenhista_recalculo()
				.Lx_form1.Lx_pageframe1.Page1.TV_TIPO_COMPRA.valid()
				
				**aba cabilog
				nPgCabilog = -1
				
				FOR EACH loPg IN .lx_form1.lx_pageframe1.pages
					IF "cabilog" $ LOWER(loPg.caption)
						nPgCabilog = loPg.pageorder
					ENDIF
				ENDFOR
				IF nPgCabilog > 0
					.Lx_form1.Lx_pageframe1.ActivePage=nPgCabilog
				ENDIF
				
				IF v_compras_01.ERP_CAB_OPCAO>1
					**.lx_form1.lx_pageframe1.pgCabilog.optCabilog1.when()
					.lx_form1.lx_pageframe1.pgCabilog.optCabilog1.valid()
				ENDIF
				
				
				SELECT v_compras_01_produtos
				GO top
				
				SELECT v_compras_01
				*.Lx_form1.Lx_pageframe1.activepage = 1
				
			ENDWITH 
			

		ENDIF && -->thisform.objTelaPai.PP_habilita_pedido_umode_plm
		
		IF thisform.objTelaPai.PP_habilita_pedido_umode_plm = .T. ;
				AND ALLTRIM(curVerificarUmode.STATUS_UMODE)=="NOK" AND (nOptPerguntaUmode = 6)
			MESSAGEBOX(curVerificarUmode.MENSAGEM, 16, "Aviso")
		ENDIF
		
		
	ENDPROC
		
ENDDEFINE

***
* Pesquisa de Produtos
*/
DEFINE CLASS Tpesqproduto AS form

	Height = 350
	Width = 473
	ShowWindow = 1
	ShowTips = .T.
	AutoCenter = .T.
	Caption = "Pesquisa de Produtos"
	KeyPreview = .T.
	WindowType = 1
	AlwaysOnTop = .T.
	Minbutton = .f.
	Maxbutton = .f.
	borderstyle = 1
	Name = "frmPesquisaProduto"


	ADD OBJECT optiongroup1 AS optiongroup WITH ;
		AutoSize = .T., ;
		ButtonCount = 2, ;
		Value = 1, ;
		Height = 46, ;
		Left = 14, ;
		Top = 25, ;
		Width = 84, ;
		Name = "Optiongroup1", ;
		Option1.Caption = "CÛdigo", ;
		Option1.Value = 1, ;
		Option1.Height = 17, ;
		Option1.Left = 5, ;
		Option1.Top = 5, ;
		Option1.Width = 61, ;
		Option1.Name = "Option1", ;
		Option2.Caption = "DescriÁ„o", ;
		Option2.Height = 17, ;
		Option2.Left = 5, ;
		Option2.Top = 24, ;
		Option2.Width = 74, ;
		Option2.AutoSize = .T., ;
		Option2.Name = "Option2"


	ADD OBJECT label1 AS label WITH ;
		AutoSize = .T., ;
		Caption = "Pesquisar por:", ;
		Height = 17, ;
		Left = 14, ;
		Top = 5, ;
		Width = 83, ;
		Name = "Label1"


	ADD OBJECT text1 AS textbox WITH ;
		Height = 23, ;
		Left = 108, ;
		Top = 25, ;
		Width = 337, ;
		Name = "Text1", ;
		ControlSource = "vPRODUTO.PRODUTO"


	ADD OBJECT grid1 AS grid WITH ;
		ColumnCount = 2, ;
		DeleteMark = .F., ;
		GridLines = 2, ;
		Height = 236, ;
		Left = 12, ;
		Panel = 1, ;
		ReadOnly = .T., ;
		RecordSource = "vGridProdutos", ;
		Top = 78, ;
		Width = 456, ;
		GridLineColor = RGB(192,192,192), ;
		HighlightBackColor = RGB(255,255,128), ;
		HighlightForeColor = RGB(0,0,0), ;
		HighlightStyle = 1, ;
		Name = "Grid1", ;
		Column1.ControlSource = "vGridProdutos.PRODUTO", ;
		Column1.ReadOnly = .T., ;
		Column1.Name = "Column1", ;
		Column2.ControlSource = "vGridProdutos.DESC_PRODUTO", ;
		Column2.Width = 347, ;
		Column2.ReadOnly = .T., ;
		Column2.Name = "Column2"


	PROCEDURE grid1.init		
		this.column1.header1.caption = "CÛdigo"
		this.column2.header1.caption = "DescriÁ„o do Produto"
	ENDPROC


	ADD OBJECT command1 AS commandbutton WITH ;
		Top = 25, ;
		Left = 445, ;
		Height = 23, ;
		Width = 23, ;
		Picture = "..\linx_sql_8\linx\exclusivos\lupa.gif", ;
		Caption = "", ;
		Name = "Command1"


	ADD OBJECT lblmensagem AS label WITH ;
		AutoSize = .T., ;
		FontBold = .T., ;
		Caption = "Retornou 0 registros.", ;
		Height = 17, ;
		Left = 108, ;
		Top = 54, ;
		Width = 122, ;
		ForeColor = RGB(255,0,0), ;
		Name = "lblMensagem"


	ADD OBJECT command2 AS commandbutton WITH ;
		Top = 48, ;
		Left = 416, ;
		Height = 27, ;
		Width = 52, ;
		Caption = "Limpar", ;
		Name = "Command2"


	ADD OBJECT btnselecionar AS commandbutton WITH ;
		Top = 319, ;
		Left = 398, ;
		Height = 27, ;
		Width = 72, ;
		Caption = "Selecionar", ;
		Name = "btnSelecionar"


	PROCEDURE pesquisa
		SET SAFETY OFF
		lcTexto = ALLTRIM(ThisForm.Text1.Value)

		IF !("%" $ lcTexto)
			thisform.text1.value = ALLTRIM(ThisForm.Text1.Value)+"%"
			lcTexto = ALLTRIM(ThisForm.Text1.Value)
		ENDIF

		IF ThisForm.Optiongroup1.Value = 1
			lcWhere = " PRODUTO LIKE '"+lcTexto+"'"
		ELSE
			lcWhere = " DESC_PRODUTO LIKE '"+lcTexto+"'"
		ENDIF

		TEXT TO lcSQL NOSHOW TEXTMERGE
			SELECT PRODUTO, DESC_PRODUTO, INATIVO 
			FROM PRODUTOS 
			WHERE <<lcWhere>>
		ENDTEXT

		f_select(lcSQL,"tmpProduto1")


		SELECT vGridProdutos
		ZAP
		APPEND FROM DBF("tmpProduto1")
		GO TOP
		ThisForm.lblMensagem.Caption = "Retornou "+LTRIM(TRANSFORM(RECCOUNT("vGridProdutos"),"9,999,999"))+" registros."
	ENDPROC


	PROCEDURE tecla_grid
		LPARAMETERS nKeyCode, nShiftAltCtrl
		IF nKeyCode=13
			thisform.fechar(13)
		ENDIF
		IF nKeyCode=27
			thisform.fechar(27)
		ENDIF
	ENDPROC


	PROCEDURE fechar
		LPARAMETERS nKeyCode
		IF nKeyCode=13 && ENTER
			SELECT vPRODUTO
			IF RECCOUNT("vPRODUTO")=0
				APPEND BLANK
			ENDIF
			REPLACE PRODUTO WITH vGridProdutos.PRODUTO

			***
			* carrega dados no combobox de sele√ß√£o de pack
			*/
			SET SAFETY off
			SELECT vCboPack
			ZAP
			
			TEXT TO lcSQL NOSHOW TEXTMERGE
				SELECT distinct PACK AS CODIGO_PACK 
				FROM PRODUTOS_PACKS_PERMITIDOS 
				WHERE PRODUTO = '<<ALLTRIM(vPRODUTO.PRODUTO)>>'
			ENDTEXT
			F_SELECT(lcSQL,"tmpPackProduto1")
			
			SELECT vCboPack
			APPEND FROM DBF("tmpPackProduto1")			
			GO top
			REPLACE vPRODUTO.CODIGO_PACK WITH vCboPack.CODIGO_PACK 

		ENDIF
		Thisform.Release
	ENDPROC


	PROCEDURE duplo_clique

		thisform.fechar(13)
	ENDPROC


	PROCEDURE Load

		CREATE CURSOR vGridProdutos ( ;
		PRODUTO C(12) NULL ,;
		DESC_PRODUTO C(40) NULL ,;
		INATIVO L )

	ENDPROC


	PROCEDURE Init
		
		FOR EACH loColumn IN ThisForm.Grid1.Columns
			BINDEVENT(loColumn.text1,"Keypress",;
			THIS,"tecla_grid")
		ENDFOR

		FOR EACH loColumn IN ThisForm.Grid1.Columns
			BINDEVENT(loColumn.text1,"DblClick",;
			THIS,"duplo_clique")
		ENDFOR
		
		IF !EMPTY(vPRODUTO.PRODUTO)
			thisform.pesquisa()
		ENDIF
		
	ENDPROC


	PROCEDURE text1.KeyPress
		LPARAMETERS nKeyCode, nShiftAltCtrl
		IF nKeyCode = 13
			thisform.pesquisa()
		ENDIF

	ENDPROC


	PROCEDURE command1.Click
		THISFORM.pesquisa()
		thisform.Refresh
	ENDPROC


	PROCEDURE command2.Click
		ThisForm.Text1.Value = ""

		SELECT vGridProdutos
		ZAP

		ThisForm.lblMensagem.Caption = "Retornou "+LTRIM(TRANSFORM(RECCOUNT("vGridProdutos"),"9,999,999"))+" registros."

		thisform.Refresh
	ENDPROC


	PROCEDURE btnselecionar.Click

		Thisform.fechar(13)
	ENDPROC


ENDDEFINE
*
*-- EndDefine: pesqproduto
**************************************************

***
* Tela para pegar a senha para liberar o pedido
* Retorna a vari√°vel glSenha preenchida
* PAULO DEVIDE - 27/08/16
*/
DEFINE CLASS tsenhapedido AS form


	BorderStyle = 1
	Height = 108
	Width = 289
	DoCreate = .T.
	AutoCenter = .T.
	Caption = "Permiss„o para alterar pedido"
	ControlBox = .F.
	WindowType = 1
	senha = ""
	Name = "tsenhapedido"


	ADD OBJECT label1 AS label WITH ;
		AutoSize = .T., ;
		Caption = "Digite a senha:", ;
		Height = 17, ;
		Left = 12, ;
		Top = 24, ;
		Width = 85, ;
		Name = "Label1"


	ADD OBJECT text1 AS textbox WITH ;
		ControlSource = "thisform.senha", ;
		Format = "!", ;
		Height = 23, ;
		Left = 109, ;
		MaxLength = 15, ;
		Top = 24, ;
		Width = 134, ;
		PasswordChar = "*" ,;
		Name = "Text1"


	ADD OBJECT command1 AS commandbutton WITH ;
		Top = 72, ;
		Left = 110, ;
		Height = 27, ;
		Width = 84, ;
		Caption = "Cancel", ;
		Name = "Command1"


	ADD OBJECT command2 AS commandbutton WITH ;
		Top = 72, ;
		Left = 195, ;
		Height = 27, ;
		Width = 84, ;
		Caption = "OK", ;
		Name = "Command2"


	PROCEDURE Init
		thisform.senha = SPACE(15)
	ENDPROC

	PROCEDURE command1.Click
		thisform.senha = ""
		glSenha = ""
		thisform.Release
	ENDPROC


	PROCEDURE command2.Click
		glSenha = ALLTRIM(thisform.senha)
		thisform.Release
	ENDPROC


ENDDEFINE

***
* Listbox de valida√ß√µes de campos
*/
DEFINE CLASS lista_erro as ListBox
	Height = 160
	Left = 19
	Top = 30
	Width = 635
	Name = "lista_erro"
	
	PROCEDURE init
		this.Clear		
	ENDPROC
	
	PROCEDURE when
		RETURN .t.		
	ENDPROC

	PROCEDURE refresh
		** Inclus√£o/Altera√ß√£o/Exclus√£o/Tela (L)impa/(P)esquisa Feita!
		this.enabled = INLIST(ThisFormSet.p_Tool_Status,"I","A")
	ENDPROC
ENDDEFINE

DEFINE CLASS label_erro as label
	Height = 20
	Left = 19
	Top = 10
	Width = 200
	Name = "label_erro"
	Caption = "Lista de Erros"
	BackStyle = 0 
	FontBold = .T.
ENDDEFINE

***
* Listbox de valida√ß√µes de metricas
*/
DEFINE CLASS lista_metrica as ListBox
	Height = 200
	Left = 19
	Top = 215
	Width = 635
	Name = "lista_metrica"
	
	PROCEDURE init
		this.Clear		
	ENDPROC
	
	PROCEDURE when
		RETURN .t.		
	ENDPROC

	PROCEDURE refresh
		** Inclus√£o/Altera√ß√£o/Exclus√£o/Tela (L)impa/(P)esquisa Feita!
		this.enabled = INLIST(ThisFormSet.p_Tool_Status,"I","A")
	ENDPROC
ENDDEFINE

DEFINE CLASS label_metrica as label
	Height = 20
	Left = 19
	Top = 195
	Width = 200
	Name = "label_erro"
	Caption = "Lista MÈtricas com Erros"
	BackStyle = 0 
	FontBold = .T.
ENDDEFINE

DEFINE CLASS lblCor2 as label
	Height = 20
	Top = 145
	Left = 535
	Autosize = .T.
	Width = 115
	Name = "lblCor2"
	Caption = "Segunda Cor"
	BackStyle = 0 
	FontBold = .T.
ENDDEFINE

DEFINE CLASS cboCor2 as combobox
	name = "cboCor2"
	Top = 160
	Left = 535
	Style= 2
	BackStyle= 0
	Width = 180
	ControlSource = "v_compras_01_produtos.ERP_COR_PRODUTO2"
	Rowsource="F_SELECT([SELECT DESCRICAO,CODIGO FROM CAEDU_LISTA_COMBO WHERE ID_DOMINIO = '016' ORDER BY DESCRICAO],[VCOMBO_COR2])"
	ColumnCount =2
	ColumnWidths = "240,80"
	Rowsourcetype=3
	BoundColumn=2
	
	PROCEDURE when
		IF NOT NVL(v_compras_01_produtos.ERP_CONJUNTO,.f.)
			WAIT WINDOW "Somente È permitido a escolha de 2™. cor para Conjunto"+CHR(13)+;
						"Clique em Conjunto para selecionar uma cor."		
			RETURN .f.
		ENDIF
		RETURN .t.
	ENDPROC
	
	PROCEDURE valid
		*** Comentado em 26/10/2017
		*** Edi√ß√£o destes campos ser√° feita na Aba Itens do Pedido de Compras, registro a registro
		** Chamada abaixo comentada, pois copiava igual para todos os itens, e neste caso podemos
		** ter segunda cor diferente para cada item
		**this.parent.cmdAtualizar1.click() 
	ENDPROC
	
	PROCEDURE refresh
		this.enabled = INLIST(ThisFormSet.p_Tool_Status,"I","A")
	ENDPROC
ENDDEFINE

DEFINE CLASS chkE_Conjunto as checkbox
	name = "chkE_Conjunto"
	Top = 160
	Left = 415
	Caption = "… conjunto?"
	Style= 0
	BackStyle= 0
	ControlSource = "v_compras_01_produtos.ERP_CONJUNTO"
	
	PROCEDURE refresh
		this.enabled = INLIST(ThisFormSet.p_Tool_Status,"I","A")
	ENDPROC
ENDDEFINE
	

DEFINE CLASS chkPackResto as checkbox
	name = "chkPackResto"
	Top = 160
	Left = 305
	Caption = "Pack Resto?"
	Style= 0
	BackStyle= 0
	ControlSource = "V_COMPRAS_01.ERP_PACK_RESTO"
	
	PROCEDURE refresh
		this.enabled = INLIST(ThisFormSet.p_Tool_Status,"I","A")
	ENDPROC
	
	PROCEDURE valid

		WITH this.Parent.shape11
			.Top = 32
			.left = 7
			.visible = .t.
			.height = 117   && altura
			.Width = 820    && largura
			.BackStyle= 0   && transparente
			.BorderStyle= 0 && borda invisivel
		ENDWITH		

		IF this.Value = .T.
			WITH this.Parent.shape11
				.Top = 32
				.left = 7
				.visible = .t.
				.height = 11   && altura
				.Width = 11    && largura
				.BackStyle= 0   && transparente
				.BorderStyle= 0 && borda invisivel
			ENDWITH		
		ENDIF
		
	ENDPROC
	
ENDDEFINE

***
* Tela para informar o motivo da altera√ß√£o
* da data de entrega
*/
DEFINE CLASS frmmotivo AS form

	Height = 130
	Width = 310
	ShowWindow = 1
	ShowTips = .T.
	AutoCenter = .T.
	Caption = "Motivo da alteraÁ„o"
	ControlBox = .F.
	WindowType = 1
	AlwaysOnTop = .T.
	Name = "frmmotivo"


	ADD OBJECT label1 AS label WITH ;
		AutoSize = .T., ;
		FontBold = .T., ;
		BackStyle = 0, ;
		Caption = "Informe o motivo", ;
		Height = 17, ;
		Left = 12, ;
		Top = 8, ;
		Width = 97, ;
		Name = "Label1"


	ADD OBJECT cbomotivo AS combobox WITH ;
		RowSourceType = 1, ;
		RowSource = "ALTERA«√O DE COMPRAS,ALTERA«√O DO FORNECEDOR", ;
		Height = 24, ;
		Left = 12, ;
		SpecialEffect = 1, ;
		Style = 2, ;
		Top = 32, ;
		Width = 288, ;
		Name = "cboMotivo"


	ADD OBJECT btnok AS commandbutton WITH ;
		Top = 96, ;
		Left = 216, ;
		Height = 27, ;
		Width = 84, ;
		Caption = "OK", ;
		Name = "btnOk"


	PROCEDURE gravarmotivo

			xmot = ALLTRIM(thisform.cboMotivo.value)
			f_insert("insert into CAEDU_COMPRAS_ENTREGA_LOG (PEDIDO, DATA_ALTERACAO_ENTREGA, DATA_ENTREGA, DATA_ENTREGA_NOVA, MOTIVO, USUARIO ) "+;
				" values (?V_COMPRAS_01.PEDIDO, getdate(), ?x_entreg_atu.entrega , ?v_compras_01_produtos.entrega, ?xmot, ?wusuario )")

			=REQUERY('V_CAEDU_LOG_ENTRADA')

	ENDPROC


	PROCEDURE btnok.Valid
		IF EMPTY(ThisForm.cboMotivo.Value)
			MESSAGEBOX("Informe um motivo!", 64, "Aviso")
			RETURN .f.
		ELSE
			thisform.gravarmotivo()
		ENDIF
		thisform.Release

	ENDPROC

ENDDEFINE

****
* CLASSE DE FUN√á√ïES DE VALIDA√á√ÉO
* DE M√âTRICAS DEFINIDAS DO PEDIDO
*/
DEFINE CLASS funcoes_metricas AS custom
	***
	* Declara e inicia propriedades 
	* desta classe
	*/
	retorno = .f.
	err_message = ""
	metrica_erro = ""
	pedidoId = ""
	produtoId = ""
	custoOriginal = 0.000000
	vendaOriginal = 0.000000
	custoInformado =  0.000000
	margemCalculada = 0.000000
	oLista = .f.
	valorempenho = 0.00 && propriedade para armazenar o valor empenhado do pedido do Saldo de Verbas de OTB
	dataEntregaInformada = {} 
	metricaId = ""
	
	Name = "funcoes_metricas"
	
	PROCEDURE init
		PARAMETERS _oLista && recebe o Listbox de parametro
		IF PARAMETERS()>0
			this.oLista = _oLista
		ENDIF
			
	ENDPROC
	
	***
	* Procedure para chamar os m√©todos conforme parametro passado
	*/
	PROCEDURE executa
		LPARAMETERS lcMetrica
		
		this.metricaId = lcMetrica
		
		DO CASE
		CASE lcMetrica = "01" && ALTERA√á√ÉO DE QUANTIDADE
			this.retorno = this.VALIDA_METRICA_01()
		
		CASE lcMetrica = "02" && ALTERA√á√ÉO DE VALOR
			this.retorno = this.VALIDA_METRICA_02()
		
		CASE lcMetrica = "03" && ALTERA√á√ÉO DE CUSTO
			this.retorno = this.VALIDA_METRICA_03()
		
		CASE lcMetrica = "04" && DATA DE LIMITE DE ENTREGA
			this.retorno = this.VALIDA_METRICA_04()
		
		CASE lcMetrica = "05" && MARGEM DO PEDIDO
			this.retorno = this.VALIDA_METRICA_05()
		
		CASE lcMetrica = "06" && CONDI√á√ÉO DE PAGAMENTO
			this.retorno = this.VALIDA_METRICA_06()
		
		CASE lcMetrica = "07" && SALDO OTB NACIONAL
			this.retorno = this.VALIDA_METRICA_07()

		ENDCASE
	ENDPROC
	
	PROCEDURE add_lista
		LPARAMETERS lcMsg, blnLimparLista
		IF PARAMETERS()=1
			blnLimparLista = .f.
		ENDIF
		ADICIONA_ERRO(this.oLista, lcMsg, blnLimparLista)
	ENDPROC
	
	***
	* VERIFICA SE O REGISTRO DA TABELA PAI EXISTE
	* CASO NECESS√ùRIO, ADICIONA
	* PAULO DEVIDE - ALTERA√á√ÉO EM 16-01-17 ==> INCLUSAO DE PARAMETRO NA CLAUSULA WHERE and PRODUTO = '<<vPRODUTO.PRODUTO>>'
	*/
	PROCEDURE ADICIONA_CABECALHO_LOG
		
		this.pedidoId = v_compras_01.PEDIDO
		TEXT TO lcSQL NOSHOW TEXTMERGE PRETEXT 7
			select * 
			from CAEDU_LOG_AUTORIZA_COMPRAS 
			WHERE PEDIDO='<<this.pedidoId>>' and PRODUTO = '<<vPRODUTO.PRODUTO>>'
		ENDTEXT
		
		F_SELECT(lcSQL, "vLogPedido")
		IF RECCOUNT("vLogPedido")=0

			SELECT distinct PRODUTO ;
			FROM v_compras_01_produtos WITH (BUFFERING = .T.) ;
			INTO ARRAY laProdutos1
			
			SELECT V_CAEDU_LOG_AUTORIZA_COMPRAS
			FOR ixx=1 TO ALEN(laProdutos1,1)
				APPEND BLANK
				REPLACE PEDIDO WITH v_compras_01.PEDIDO
				REPLACE PRODUTO WITH laProdutos1[ixx]
				REPLACE DATA_LOG WITH DATE()
				REPLACE STATUS_PEDIDO WITH 3 && AGUARDANDO APROVA√á√ÉO
			ENDFOR
			
						
		ELSE && Carrega o(s) registro(s) lido(s)
			SELECT V_CAEDU_LOG_AUTORIZA_COMPRAS
			APPEND FROM DBF("vLogPedido")
			GO TOP
		ENDIF

	ENDPROC
	
	PROCEDURE ADICIONA_ITEM_LOG
		LPARAMETERS tcPedido, tcProduto, tcCorProduto, tcCodMetrica, ;
						tcValorAntes, tcValorDepois, tcObs
		LOCAL lnArea
		lnArea = SELECT()
		
		SELECT V_CAEDU_LOG_AUTORIZA_COMPRAS_ITEM 
		APPEND BLANK
		REPLACE PEDIDO WITH tcPedido
		REPLACE PRODUTO WITH tcProduto
		REPLACE COR_PRODUTO WITH tcCorProduto
		REPLACE COD_METRICA WITH tcCodMetrica
		REPLACE DATA_LOG WITH DATETIME()
		REPLACE TIPO_OP WITH o_004006.p_Tool_Status
		REPLACE VALOR_ANTES WITH tcValorAntes
		REPLACE VALOR_DEPOIS WITH tcValorDepois
		REPLACE APROVADO WITH .F.
		REPLACE USUARIO_PEDIDO WITH WUSUARIO
		REPLACE USUARIO_APROVADOR WITH NULL
		REPLACE OBS WITH tcObs
		
		SELECT (lnArea)
	ENDPROC
	

	***
	* VALIDA√á√ÉO M√âTRICA DE ALTERA√á√ÉO DE QUANTIDADE
	*/
	PROCEDURE VALIDA_METRICA_01
		LOCAL llRetorno as Boolean
		llRetorno = .T.
		RETURN llRetorno
	ENDPROC

	***
	* VALIDA√á√ÉO M√âTRICA DE ALTERA√á√ÉO DE VALOR
	*/
	PROCEDURE VALIDA_METRICA_02
		LOCAL llRetorno as Boolean
		llRetorno = .T.
		RETURN llRetorno
	ENDPROC

	***
	* VALIDA√á√ÉO M√âTRICA DE ALTERA√á√ÉO DE CUSTO
	*/
	PROCEDURE VALIDA_METRICA_03
		LOCAL llRetorno as Boolean
		llRetorno = .T.
		RETURN llRetorno
	ENDPROC

	***
	* VALIDA√á√ÉO M√âTRICA DE DATA DE LIMITE DE ENTREGA
	*/
	PROCEDURE VALIDA_METRICA_04
		LOCAL llRetorno as Boolean
		llRetorno = .T.
		llCancela = (RECCOUNT("V_COMPRAS_01_CANCELAMENTO")>0) && se .T. deixa passar direto
		IF llCancela
			RETURN .t.
		ENDIF

		this.dataEntregaInformada = o_004006.px_entrega.Value

		SELECT v_Compras_01_Produtos
		GO TOP

		lc_pedido = ALLTRIM(v_Compras_01_Produtos.pedido)
		ld_limite_entrega = DTOC(v_Compras_01_Produtos.limite_entrega,1)
		TEXT TO lcsql noshow
		    select pedido, LIMITE_ENTREGA, DATEPART( wk , LIMITE_ENTREGA ) as semana,
		       ENTREGA,  DATEPART( wk , getdate() ) as semana_atual
			from
			COMPRAS_PRODUTO
			where pedido like ?lc_pedido
		ENDTEXT

		IF USED("x_entreg_atu")
			USE IN x_entreg_atu
		ENDIF
		f_select(lcsql,'x_entreg_atu')

		IF RECCOUNT("x_entreg_atu")  = 0 OR;
				f_vazio(x_entreg_atu.entrega)
			RETURN .T.
		ENDIF

		IF this.dataEntregaInformada <> TTOD(x_entreg_atu.entrega)
			frm = CREATEOBJECT("frmmotivo")
			frm.show(1)	
		ENDIF

		IF TTOD(x_entreg_atu.limite_entrega) != v_Compras_01_Produtos.limite_entrega
			LC_DATA_INI = DTOC(TTOD(x_entreg_atu.limite_entrega),1)
			LC_DATA_FIM = DTOC(DATETIME(),1)

			XWK_ENTEGA =  IIF( YEAR(x_entreg_atu.limite_entrega) > YEAR(DATE()), WEEK(TTOD(x_entreg_atu.limite_entrega)) +50 ,WEEK(TTOD(x_entreg_atu.limite_entrega)))

			XWK_ATUAL = WEEK(DATE( ))
			WKDIFF = XWK_ENTEGA - XWK_ATUAL
			ld_limite_entrega = DTOC(v_Compras_01_Produtos.limite_entrega,1)
			IF USED("x_entreg_new")
				USE IN x_entreg_new
			ENDIF

			TEXT TO lcsql noshow
				select  DATEDIFF ( wk , ?LC_DATA_FIM,  ?LC_DATA_INI )  as wk_dif
			ENDTEXT
			f_select(lcsql,'x_entreg_new')

			DO CASE
				CASE WKDIFF  <= 2 && 0

					tcValorAntes = DTOC(x_entreg_atu.entrega)
					tcValorDepois = DTOC(v_Compras_01_Produtos.entrega)
					this.metrica_erro = "Data de Entrega foi alterada de => "+tcValorAntes+" para => "+tcValorDepois
					SELECT v_compras_01_produtos
					GO top

					this.add_lista(this.metrica_erro)
					
					this.ADICIONA_ITEM_LOG(v_compras_01.PEDIDO, v_compras_01_produtos.produto, v_compras_01_produtos.cor_produto, ;
											"04", tcValorAntes, tcValorDepois, this.metrica_erro)
					llRetorno = .F.


					lcsql = ""
					lc_usuario = "Gerente Compras" && cursor aberto e usuario do diretor autenticado
					TEXT TO lcsql noshow
						INSERT INTO trigger_portal
						(id,login,pedido,entrega_antiga,entrega_nova,limite_entrega_antiga,	limite_entrega_nova,data_alteracao ,user_senha,	cargo_senha)
						VALUES	((select MAX(id)+1 from trigger_portal), ?wusuario, ?x_entreg_atu.pedido, ?x_entreg_atu.entrega, ?v_compras_01_produtos.entrega,
						  ?x_entreg_atu.limite_entrega, ?v_compras_01_produtos.limite_entrega, getdate(), ?lc_usuario, 'DIRETOR')
					ENDTEXT
					F_INSERT(lcsql)
					** (fim) PAULO DEVIDE --> 13-NOV-14


			ENDCASE


		ENDIF
		
		RETURN llRetorno
	ENDPROC

	***
	* VALIDA√á√ÉO M√âTRICA DE MARGEM DE LUCRO SOBRE PRE√áOS
	*/
	PROCEDURE VALIDA_METRICA_05
		LOCAL llRetorno as Boolean
		llRetorno = .T.

		IF ALLTRIM(NVL(v_compras_01.ERP_CUPS_SEGMENTO,'')) = "ATACADO"
			RETURN llRetorno
		ENDIF
		
		SELECT v_compras_01_produtos
		** PAULO DEVIDE --> 28-05-2015
		DIMENSION laMargem[IIF(RECCOUNT("v_compras_01_produtos")=0,1,RECCOUNT("v_compras_01_produtos")),3]
		FOR itt=1 TO ALEN(laMargem,1)
			laMargem[itt,1]="" 			&& produto
			laMargem[itt,2]="" 			&& cor produto
			laMargem[itt,3]=0.000000 	&& Margem
		ENDFOR

		PRIVATE lnMargem, lcOrigem
		lnMargem = 0
		lcOrigem = ""
		lcMsg1 = ""

		llRetorno = .t.
		itt = 1
		SCAN

			lnPercMargem = 0
			
			** popula as propriedades custoOriginal e vendaOriginal
			this.produtoId = ALLTRIM(v_compras_01_produtos.produto)
			this.getPRECOS_PRODUTO()
			this.custoInformado = v_compras_01_produtos.CUSTO1
			
			** Calcula a margem e popula o parametro margemCalculada			
			this.margemCalculada = this.CALCULA_MARGEM_PEDIDO(this.vendaOriginal, this.custoInformado)
			lnPercMargem = this.margemCalculada
			
			** Valida a margem e retorna .T. ou .F.
			llStatus = this.validaMargem(lnPercMargem)
			
			laMargem[itt,1]=v_compras_01_produtos.produto 			&& produto
			laMargem[itt,2]=v_compras_01_produtos.cor_produto		&& cor produto
			laMargem[itt,3]=this.margemCalculada					&& Margem

			lcOrigem = IIF(this.ORIGEM_PRODUTO(this.produtoId)="N","nacional","importado")
			
			** Compara com o valor da margem gravado no item, se for igual, n√£o pede a senha
			IF ( ROUND(NVL(v_compras_01_produtos.ERP_PERC_MARGEM,0.000000),6) = ROUND(lnPercMargem,6) )
				llStatus = .t.
			ENDIF

			IF !llStatus

				this.metrica_erro =	"AutorizaÁ„o para Margem mÌnima de produto "+ lcOrigem + " atingida ("+ ;
					ALLTRIM(TRANSFORM(lnPercMargem,"999,999.99"))+"%)"
				** Calcula a margem e popula o parametro margemCalculada			
				SELECT V_COMPRAS_PRODUTO_ANTES
				LOCATE FOR ALLTRIM(PRODUTO)=ALLTRIM(laMargem[itt,1]) AND ALLTRIM(COR_PRODUTO)=ALLTRIM(laMargem[itt,2])
				lnMargemAnterior = 0.000000
				IF FOUND()				
					lnMargemAnterior = this.CALCULA_MARGEM_PEDIDO(this.vendaOriginal, V_COMPRAS_PRODUTO_ANTES.custo1)
				ENDIF

				this.add_lista(this.metrica_erro)
				
				tcValorAntes = TRANSFORM(lnMargemAnterior)
				tcValorDepois = TRANSFORM(this.margemCalculada)
				
				this.ADICIONA_ITEM_LOG(v_compras_01.PEDIDO, v_compras_01_produtos.produto, v_compras_01_produtos.cor_produto, ;
										this.MetricaId, tcValorAntes, tcValorDepois, this.metrica_erro)

				llRetorno=.F.
			ENDIF

			SELECT v_compras_01_produtos
			itt = itt + 1

		ENDSCAN
		
		
		RETURN llRetorno
	ENDPROC

	***
	* VALIDA√á√ÉO M√âTRICA DE CONDI√á√ÉO DE PAGAMENTO
	*/
	PROCEDURE VALIDA_METRICA_06
		LOCAL llRetorno as Boolean
		llRetorno = .T.
		IF o_004006.p_Tool_Status="I"
			RETURN llRetorno
		ENDIF
		
		IF o_004006.CONDICAO_PGTO_ANTES <> v_compras_01.condicao_pgto

				tcValorAntes = o_004006.CONDICAO_PGTO_ANTES
				tcValorDepois = v_compras_01.condicao_pgto
				this.metrica_erro = "CondiÁ„o de Pagamento foi alterada de => "+tcValorAntes+" para => "+tcValorDepois
				SELECT v_compras_01_produtos
				GO top

				this.add_lista(this.metrica_erro)
				
				this.ADICIONA_ITEM_LOG(v_compras_01.PEDIDO, v_compras_01_produtos.produto, v_compras_01_produtos.cor_produto, ;
										this.metricaId, tcValorAntes, tcValorDepois, this.metrica_erro)
				llRetorno = .F.
		ENDIF
		
		RETURN llRetorno
	ENDPROC

	***
	* VALIDA√á√ÉO M√âTRICA DE SALDO OTB NACIONAL
	*/
	PROCEDURE VALIDA_METRICA_07
		LOCAL llRetorno as Boolean
		llRetorno = .T.

		IF INLIST(o_004006.p_Tool_Status,'I','A') ;
			AND !ZORIGEM_PEDIDO_IMPORTADO() AND ;
				ALLTRIM(V_COMPRAS_01.erp_cups_segmento) = 'VAREJO'
			
			IF o_004006.EXCLUIU_ITENS=.T.	
				This.estorna_empenho_OTB()
			ENDIF
				
			IF NOT This.verifica_verba_OTB()

				llRetorno = .F.

			ENDIF
			***
			* ATUALIZA CAEDU_VERBA_COMPRAS E COMPRAS_PRODUTO
			*/
			This.ATUALIZA_TABELAS_VERBAS_OTB()
			*----------------------------------------------------------------------/
		ENDIF
		


		RETURN llRetorno
	ENDPROC

	***
	* ROTINA PARA ATUALIZAR COMPRAS_PRODUTO E 
	* TABELA CAEDU_VERBA_COMPRAS
	* PAULO DEVIDE --> nov/17
	*/
	PROCEDURE ATUALIZA_TABELAS_VERBAS_OTB
		lcListaProdutos = ""
		SELECT curVerbas
		SCAN 					
			lcListaProdutos = lcListaProdutos + "'"+curVerbas.PRODUTO+"',"
		ENDSCAN
		
		lcListaProdutos = LEFT(lcListaProdutos,LEN(lcListaProdutos)-1)

		TEXT TO lcSQL NOSHOW TEXTMERGE
			select PR.PRODUTO, PR.GRIFFE, PR.LINHA, PR.GRUPO_PRODUTO, PR.SUBGRUPO_PRODUTO
			FROM produtos PR 
			WHERE PR.PRODUTO IN (<<lcListaProdutos>>)
		ENDTEXT
		f_select(lcSQL, "curGrupoProdutosOTB")

		select ;
			b.griffe,;
			b.linha,;
			b.grupo_produto,;
			b.subgrupo_produto, ;
			sum(a.erp_verbas_empenho) as erp_verbas_empenho, ;
			max(a.erp_verbas_data_empenho) as erp_verbas_data_empenho, ;
			max(a.erp_verbas_empenho_ano_mes) as erp_verbas_empenho_ano_mes, ;
			max(a.erp_verbas_status_pr) as erp_verbas_status_pr ;
		from ;
			CURVERBAS_BEFORE_ALTER a ;
		inner join ;
			 CURGRUPOPRODUTOSOTB B ON B.PRODUTO=A.PRODUTO ;
		group by ;
			b.griffe,;
			b.linha,;
			b.grupo_produto,;
			b.subgrupo_produto ;
		INTO CURSOR CUR_TOTAL_AGRUPADO_BEFORE_ALTER

		select ;
			b.griffe,;
			b.linha,;
			b.grupo_produto,;
			b.subgrupo_produto, ;
			sum(a.erp_verbas_empenho) as erp_verbas_empenho, ;
			max(a.erp_verbas_data_empenho) as erp_verbas_data_empenho, ;
			max(a.erp_verbas_empenho_ano_mes) as erp_verbas_empenho_ano_mes, ;
			max(a.erp_verbas_status_pr) as erp_verbas_status_pr ;
		from ;
			curverbas a ;
		inner join ;
			 CURGRUPOPRODUTOSOTB B ON B.PRODUTO=A.PRODUTO ;
		group by ;
			b.griffe,;
			b.linha,;
			b.grupo_produto,;
			b.subgrupo_produto ;
		INTO CURSOR CUR_TOTAL_AGRUPADO

		**AAAA
		
		SELECT CUR_TOTAL_AGRUPADO
		SCAN 	

			SELECT CUR_TOTAL_AGRUPADO_BEFORE_ALTER
			LOCATE FOR ALLTRIM(griffe) = ALLTRIM(CUR_TOTAL_AGRUPADO.griffe) AND ;
					 	ALLTRIM(linha) = ALLTRIM(CUR_TOTAL_AGRUPADO.linha) AND  ;
					 	ALLTRIM(grupo_produto) = ALLTRIM(CUR_TOTAL_AGRUPADO.grupo_produto) AND ;
					 	ALLTRIM(subgrupo_produto) = ALLTRIM(CUR_TOTAL_AGRUPADO.subgrupo_produto) ; 
						AND  erp_verbas_empenho_ano_mes = CUR_TOTAL_AGRUPADO.erp_verbas_empenho_ano_mes
						
			IF FOUND("CUR_TOTAL_AGRUPADO_BEFORE_ALTER")
				lnEmpenhoAnterior = CUR_TOTAL_AGRUPADO_BEFORE_ALTER.erp_verbas_empenho
			ELSE
				lnEmpenhoAnterior = 0
			ENDIF
			
			TEXT TO lcSQL NOSHOW TEXTMERGE
			UPDATE Caedu_verba_compras
			SET empenho = ISNULL(empenho,0) - <<lnEmpenhoAnterior>> + <<CUR_TOTAL_AGRUPADO.erp_verbas_empenho>>
			where griffe = '<<ALLTRIM(CUR_TOTAL_AGRUPADO.griffe)>>' and linha = '<<ALLTRIM(CUR_TOTAL_AGRUPADO.linha)>>' 
				and grupo = '<<ALLTRIM(CUR_TOTAL_AGRUPADO.grupo_produto)>>' and subgrupo = '<<ALLTRIM(CUR_TOTAL_AGRUPADO.subgrupo_produto)>>' 
				and mes = <<CUR_TOTAL_AGRUPADO.erp_verbas_empenho_ano_mes>>
			ENDTEXT
			
			f_execute(lcSQL)				
			SELECT CUR_TOTAL_AGRUPADO
			
		ENDSCAN
		
		*** ATUALIZA CAMPOS DA TABELA COMPRAS_PRODUTO E PROSSEGUE COM A GRAVA√á√ÉO NORMAL
		SELECT V_COMPRAS_01_PRODUTOS 
		SCAN
		
			 	
			SELECT CURVERBAS
			LOCATE FOR PRODUTO = V_COMPRAS_01_PRODUTOS.produto
			
			IF FOUND()
			
				SELECT V_COMPRAS_01_PRODUTOS 
				REPLACE ERP_VERBAS_EMPENHO WITH V_COMPRAS_01_PRODUTOS.VALOR_ORIGINAL
				REPLACE ERP_VERBAS_DATA_EMPENHO WITH CURVERBAS.ERP_VERBAS_DATA_EMPENHO
				REPLACE ERP_VERBAS_EMPENHO_ANO_MES WITH CURVERBAS.ERP_VERBAS_EMPENHO_ANO_MES
				REPLACE ERP_VERBAS_STATUS_PR WITH .T. && FOI AUTORIZADO, OU ESTAVA DENTRO DO LIMITE DO SALDO OTB
			
			ENDIF
							
			SELECT V_COMPRAS_01_PRODUTOS 
		ENDSCAN

	ENDPROC
	
	***
	* Calcula a Margem e retorna o valor da margem
	*/
	PROCEDURE CALCULA_MARGEM_PEDIDO
		PARAMETERS lnPrecoVenda, lnCustoInformado
		LOCAL lnMargem as Decimal
		IF lnPrecoVenda = 0 && tratamento para n√£o dar divis√£o por Zero
			lnMargem = 0
		ELSE
			lnMargem = ((lnPrecoVenda - lnCustoInformado)/lnPrecoVenda) * 100
		ENDIF
		RETURN lnMargem
	ENDPROC

	PROCEDURE getPRECOS_PRODUTO	
		LOCAL lnArea
		lnArea = SELECT()
		** RESET nos pre√ßos
		this.custoOriginal = 0.00
		this.vendaOriginal = 0.00
		
		IF USED("tmpMargem")
			SELECT tmpMargem
			USE
		ENDIF
			
		TEXT TO lcSQL NOSHOW TEXTMERGE
			SELECT PRODUTOS_PRECOS.PRODUTO,PRODUTOS_PRECOS.CODIGO_TAB_PRECO,
			PRODUTOS_PRECOS.PRECO1,PRODUTOS.TRIBUT_ORIGEM
			FROM PRODUTOS_PRECOS
			INNER JOIN PRODUTOS ON PRODUTOS.PRODUTO=PRODUTOS_PRECOS.PRODUTO
			WHERE PRODUTOS_PRECOS.CODIGO_TAB_PRECO IN ('00','01')
			AND PRODUTOS_PRECOS.PRODUTO = '<<this.produtoId>>'
		ENDTEXT

		f_select(lcSQL,"tmpMargem")
		SELECT tmpMargem
		** pega o pre√ßo de custo
		LOCATE FOR CODIGO_TAB_PRECO = "00"
		IF FOUND()
			this.custoOriginal = tmpMargem.PRECO1
		ENDIF
		** pega o pre√ßo de venda
		LOCATE FOR CODIGO_TAB_PRECO = "01"
		IF FOUND()
			this.vendaOriginal = tmpMargem.PRECO1
		ENDIF
		
		SELECT (lnArea)
	ENDPROC

	***
	* Origem do Produto 
	* Retorna Char(1) ==> N para nacional ou I para importado
	*/	
	PROCEDURE ORIGEM_PRODUTO
		PARAMETERS tcProduto
		LOCAL lcOrigem as String, lnArea as Integer
		lcOrigem = "N" && default
		lnArea = SELECT()
		F_SELECT("SELECT TRIBUT_ORIGEM FROM PRODUTOS WHERE PRODUTO = '"+;
					ALLTRIM(tcProduto)+"'","tmpTributOrigem")

		IF INLIST(ALLTRIM(NVL(tmpTributOrigem.TRIBUT_ORIGEM,"")),"1","2","6","7")
			lcOrigem = "I" && produto importado
		ENDIF
		
		SELECT (lnArea)
		
		RETURN lcOrigem
	ENDPROC

	PROCEDURE validaMargem
		LPARAMETERS lnMargem
		LOCAL lnArea, llStatus1
		lnArea = SELECT()
		
		llStatus1 = .T.
		IF (this.ORIGEM_PRODUTO(this.produtoId)="N") && Nacional = 51% (margem minima)

			IF lnMargem < o_004006.pp_palma_margem_minima_nac
				llStatus1 = .f.
			ENDIF
			
		ELSE && importado = 62% (margem minima)
							
			IF lnMargem < o_004006.pp_palma_margem_minima_imp
				llStatus1 = .f.
			ENDIF

		ENDIF
		SELECT (lnArea)
		RETURN llStatus1		
	ENDPROC

	****
	* Verifica se ha saldo para griffe, linha, grupo e subgrupo no ano/M√™s do Limite de Entrega do pedido 
	* Tabela Caedu_verba_compras - atualizada diariamente pelo Ensemble
	* Paulo Devid√© - 30-11-2015
	*/
	procedure verifica_verba_OTB
		LOCAL lnArea as Integer, llRet as Boolean

		llRet = .t.
		lnArea = SELECT()
		
		SELECT ;
			PRODUTO,;
			MAX(LIMITE_ENTREGA) AS LIMITE_ENTREGA, ;
			SUM(VALOR_ORIGINAL) AS VALOR_ORIGINAL, ;
			SUM(NVL(ERP_VERBAS_EMPENHO,0)) AS ERP_VERBAS_EMPENHO, ;
			MAX(NVL(ERP_VERBAS_DATA_EMPENHO,{})) AS ERP_VERBAS_DATA_EMPENHO, ;
			MAX(CAST(NVL(ERP_VERBAS_EMPENHO_ANO_MES,0) AS NUMERIC(6,0))) AS ERP_VERBAS_EMPENHO_ANO_MES, ;
			.f. AS ERP_VERBAS_STATUS_PR ;
		FROM ;
			V_COMPRAS_01_PRODUTOS WITH (BUFFERING = .T.) ;
		GROUP BY ;
			PRODUTO INTO CURSOR CURVERBAS READWRITE

		SELECT CURVERBAS 
		SCAN 

			TEXT TO lcSQL NOSHOW TEXTMERGE
			select 
				CV.* 
			from 
				Caedu_verba_compras CV
			inner join
				produtos PR on (PR.GRIFFE = CV.GRIFFE) AND (PR.LINHA = CV.LINHA) 
								AND (PR.GRUPO_PRODUTO = CV.grupo) AND (PR.SUBGRUPO_PRODUTO = CV.SUBGRUPO)
			WHERE (PR.PRODUTO = '<<ALLTRIM(CURVERBAS.produto)>>' ) AND (CV.mes = <<LEFT(DTOS(CURVERBAS.LIMITE_ENTREGA),6)>>) 
			ENDTEXT

			f_select(lcSQL,"curVerbas_OTB")
			
			IF RECCOUNT("curVerbas_OTB")=0
				MESSAGEBOX("N„o foi localizado Verba de OTB para o produto",16,"Aviso")
				SELECT (lnArea)
				RETURN .f.
			ENDIF
			

			lnEmpenho = curVerbas_OTB.empenho 
			** verifica se houve uma ocorr√™ncia de altera√ß√£o de pedido no mesmo dia, ent√£o estorna o saldo e coloca a nova quantidade original
			IF (DTOS(CURVERBAS.ERP_VERBAS_DATA_EMPENHO) = DTOS(DATE())) AND (LEFT(DTOS(CURVERBAS.LIMITE_ENTREGA),6) = TRANSFORM(curVerbas_OTB.mes,"999999")) 
				lnEmpenho = lnEmpenho - CURVERBAS.ERP_VERBAS_EMPENHO && Estorna a quantidade do dia
			ENDIF

			lnEmpenho = lnEmpenho + CURVERBAS.VALOR_ORIGINAL

			lnSaldo_OTB = curVerbas_OTB.otb_nac - lnEmpenho

			***
			* Parametro o_004006.pp_palma_limite_saldo_otb
			* 	cont√©m o valor do limite parametriz√°vel por usu√°rio
			* 	limite default = R$ 10.000,00
			*/
			
			xxdebug = .F.
			IF xxdebug
				MESSAGEBOX("valor original = " +TRANSFORM(CURVERBAS.VALOR_ORIGINAL)  +CHR(13) +;
								"saldo = " + TRANSFORM(lnSaldo_OTB) +CHR(13) +;
								"limite = " + TRANSFORM(o_004006.pp_palma_limite_saldo_otb) + CHR(13) +;
								"Empenho = " + TRANSFORM(lnEmpenho) + CHR(13) +;
								"limite + saldo = " + TRANSFORM(o_004006.pp_palma_limite_saldo_otb + lnSaldo_OTB), ;
								"Aviso", 64)
			ENDIF
							
			llERP_VERBAS_STATUS_PR = .f.
			IF CURVERBAS.VALOR_ORIGINAL <= (o_004006.pp_palma_limite_saldo_otb + lnSaldo_OTB)
				llERP_VERBAS_STATUS_PR = .T.
			ENDIF

			SELECT CURVERBAS
			REPLACE ERP_VERBAS_STATUS_PR WITH llERP_VERBAS_STATUS_PR 
			REPLACE ERP_VERBAS_EMPENHO WITH CURVERBAS.VALOR_ORIGINAL
			REPLACE ERP_VERBAS_DATA_EMPENHO WITH DATE() 
			REPLACE ERP_VERBAS_EMPENHO_ANO_MES WITH CAST(LEFT(DTOS(CURVERBAS.LIMITE_ENTREGA),6) AS INT)

		ENDSCAN

		SELECT CURVERBAS
		SCAN
			IF NOT CURVERBAS.ERP_VERBAS_STATUS_PR 
				llRet = .F.
				this.valorempenho = CURVERBAS.ERP_VERBAS_EMPENHO
				***
				* preenche o listbox de m√©tricas e gera o Log de Metrica
				*/
				
				tcValorAntes = ""
				tcValorDepois = TRANSFORM(this.valorempenho)
				lcMsg1 = "Saldo OTB Nacional para validaÁ„o deste pedido È insuficiente! Saldo de Empenho = " + tcValorDepois
				
				this.metrica_erro = lcMsg1
				SELECT v_compras_01_produtos
				GO top

				this.add_lista(this.metrica_erro)
				
				this.ADICIONA_ITEM_LOG(v_compras_01.PEDIDO, v_compras_01_produtos.produto, v_compras_01_produtos.cor_produto, ;
										this.metricaId, tcValorAntes, tcValorDepois, this.metrica_erro)				
				*EXIT
			ENDIF
		ENDSCAN

		SELECT (lnArea)	
		RETURN llRet
	ENDPROC

	PROCEDURE estorna_empenho_OTB()
		*MESSAGEBOX("√â necess√°rio excluir o empenho",64,"Aviso")
		
		***======================================================================
		** Corre√ß√£o efetuada na chamada da procedure, antes estava sem Aspas '' e dava erro nos pedidos -5 (bonificados)
		** Paulo Devide -> 01-10-2018
		*/
		F_EXECUTE("EXEC lx_estorna_empenho_otb '" + v_compras_01.PEDIDO+"'")
		WAIT WINDOW  "Estornando o empenho de OTB..." TIMEOUT 3
		WAIT CLEAR
	ENDPROC

		
ENDDEFINE

FUNCTION F_FAIXA_VALOR_CABILOG()
	LOCAL lnArea as Integer
	LOCAL lcFaixa as String, ixx as Integer
	LOCAL lnRange1 as Double, lnRange2 as Double, lcRetorno as String
	lcFaixa = ALLTRIM(o_004006.pp_palma_faixa_cabilog)

	lnArea = SELECT()
	
	****
	* Pega o produto do compras_produto e verifica o pre√ßo da tabela 01 (venda original)
	*
	*/
	SELECT V_COMPRAS_01_PRODUTOS
	lnReg = RECNO("V_COMPRAS_01_PRODUTOS")
	GO top
	TEXT TO lcSQL NOSHOW TEXTMERGE
		SELECT preco1 FROM produtos_precos 
		WHERE CODIGO_TAB_PRECO = '01' and produto ='<<ALLTRIM(V_COMPRAS_01_PRODUTOS.PRODUTO)>>'
	ENDTEXT
	f_select(lcSQL,"vPRECO1")
	lnPreco = NVL(vPreco1.Preco1, 0.00)
	
	SELECT V_COMPRAS_01_PRODUTOS
	*!*		IF RECCOUNT("V_COMPRAS_01_PRODUTOS")>0 AND lnReg>0
	*!*			GO lnReg
	*!*		ENDIF
		
	DIMENSION la_faixa[GETWORDCOUNT(lcFaixa,";")]
	FOR ixx=1 TO ALEN(la_faixa,1)
	
		la_faixa[ixx] = GETWORDNUM(lcFaixa,ixx,";")
		
	ENDFOR
		
	FOR ixx=1 TO ALEN(la_faixa,1)
		lnRange1 = GETWORDNUM(la_faixa[ixx],1,"|")
		lnRange2 = GETWORDNUM(la_faixa[ixx],2,"|")
		lcRetorno = GETWORDNUM(la_faixa[ixx],3,"|")
		IF BETWEEN(lnPreco,CAST(lnRange1 as N(10,2)),CAST(lnRange2 as N(10,2)))
			EXIT
		ENDIF
	ENDFOR
	
	** se for conjunto È obrigatÛrio o alarme independente da faixa de preÁo
	if V_COMPRAS_01_PRODUTOS.ERP_CONJUNTO
		
		IF EMPTY(lcRetorno)
			lcRetorno = "E1" 
		ENDIF
		
	ENDIF
	
	SELECT (lnArea)

	RETURN lcRetorno	
ENDFUNC

*******                                        I  N  I  C  I  O                                          *******
******* CURSOR ADAPTER UTILIZADOS NA TELA DE COMPRAS  *******
*******                                                                                                         *******

FUNCTION load_ca_vproduto
PARAMETERS oThisformset

With oThisformset.dataenvironment 
  if Type(".CursorVPRODUTO")="U" 
      AddNewObject(oThisformset.dataenvironment, "CursorVPRODUTO","ccursoradapter") 
	.CursorVPRODUTO.DataSourceType			="ADO"
	Text to .CursorVPRODUTO.SelectCmd TextMerge NOSHOW PRETEXT 7
	SELECT SPACE(12) AS PRODUTO, SPACE(1) AS CODIGO_PACK, CAST(0 AS INT) AS QTDPACK, CAST(0 AS INT) AS QTDTOTALPACK, 
	CAST(0 AS NUMERIC(14,2)) AS VALORTOTALPACK, CAST(0 AS NUMERIC(10,4)) AS CUSTOFOB, CAST(0 AS NUMERIC(10,4)) AS FOBMINIMO, 
	CAST(0 AS BIT) AS ERP_CONJUNTO, SPACE(6) AS ERP_COR_PRODUTO2
	EndText
	Text to .CursorVPRODUTO.CursorSchema TextMerge NoShow
	PRODUTO C(12), CODIGO_PACK C(1), QTDPACK I, QTDTOTALPACK I, VALORTOTALPACK N(16,2), CUSTOFOB N(12,4), 
	FOBMINIMO N(12,4), ERP_CONJUNTO L, ERP_COR_PRODUTO2 C(6) 
	EndText
	Text to .CursorVPRODUTO.UpdateNameList TextMerge NoShow
	
	EndText
	Text to .CursorVPRODUTO.UpdatableFieldList TextMerge NoShow
	
	EndText
	.CursorVPRODUTO.Tables				=""
	.CursorVPRODUTO.KeyFieldList		=""
	Text to .CursorVPRODUTO.QueryList TextMerge NoShow
	
	EndText
	Text to .CursorVPRODUTO.CaptionList TextMerge NoShow
	PRODUTO Produto, CODIGO_PACK Codigo Pack, QTDPACK Qtdpack, QTDTOTALPACK Qtdtotalpack, VALORTOTALPACK Valortotalpack, 
	CUSTOFOB Custofob, FOBMINIMO Fobminimo, ERP_CONJUNTO CONJUNTO, ERP_COR_PRODUTO2 COR2 
	EndText
	Text to .CursorVPRODUTO.DefaultsValuesList TextMerge NoShow
	
	EndText
	.CursorVPRODUTO.FTableList		=""
	.CursorVPRODUTO.Alias				="VPRODUTO"
	.CursorVPRODUTO.ParentCursor		=""
	.CursorVPRODUTO.BufferModeOverride	=3
	.CursorVPRODUTO.NoDataOnLoad		=.F.
	.CursorVPRODUTO.IsUpdateCursor		=.F.
	.CursorVPRODUTO.IsMaster		=.F.
	.CursorVPRODUTO.UpdateType			=1
	.CursorVPRODUTO.WhereType			=3
	.CursorVPRODUTO.FetchMemo			=.T.
	.CursorVPRODUTO.SendUpdates		=.F.
	.CursorVPRODUTO.UseMemoSize		=255
	.CursorVPRODUTO.FetchSize			=-1
	.CursorVPRODUTO.MaxRecords			=-1
	.CursorVPRODUTO.Prepared			=.F.
	.CursorVPRODUTO.CompareMemo		=.F.
	.CursorVPRODUTO.BatchUpdateCount	=1
	.CursorVPRODUTO.OpenCursor() 
  EndIf 
EndWith 
ENDFUNC && FUNCTION load_ca_vproduto

FUNCTION load_caedu_compras_produtos_packs
PARAMETERS oThisformset

if Type(".CursorV_CAEDU_COMPRAS_PRODUTOS_PACKS")="U" 
   AddNewObject(oThisformset.dataenvironment, "CursorV_CAEDU_COMPRAS_PRODUTOS_PACKS","ccursoradapter") 
	With oThisformset.dataenvironment.CursorV_CAEDU_COMPRAS_PRODUTOS_PACKS
		.DataSourceType = "ADO"

		TEXT TO .SelectCmd NOSHOW TEXTMERGE PRETEXT 7
		SELECT CAEDU_COMPRAS_PRODUTOS_PACKS.PEDIDO, CAEDU_COMPRAS_PRODUTOS_PACKS.PRODUTO, 
		CAEDU_COMPRAS_PRODUTOS_PACKS.COR_PRODUTO, CAEDU_COMPRAS_PRODUTOS_PACKS.DESC_COR_PRODUTO, 
		CAEDU_COMPRAS_PRODUTOS_PACKS.QTDE, CAEDU_COMPRAS_PRODUTOS_PACKS.Q1, CAEDU_COMPRAS_PRODUTOS_PACKS.Q2, 
		CAEDU_COMPRAS_PRODUTOS_PACKS.Q3, CAEDU_COMPRAS_PRODUTOS_PACKS.Q4, CAEDU_COMPRAS_PRODUTOS_PACKS.Q5, 
		CAEDU_COMPRAS_PRODUTOS_PACKS.Q6, CAEDU_COMPRAS_PRODUTOS_PACKS.Q7, CAEDU_COMPRAS_PRODUTOS_PACKS.Q8, 
		CAEDU_COMPRAS_PRODUTOS_PACKS.Q9, CAEDU_COMPRAS_PRODUTOS_PACKS.Q10, CAEDU_COMPRAS_PRODUTOS_PACKS.Q11, 
		CAEDU_COMPRAS_PRODUTOS_PACKS.Q12, CAEDU_COMPRAS_PRODUTOS_PACKS.Q13, CAEDU_COMPRAS_PRODUTOS_PACKS.Q14, 
		CAEDU_COMPRAS_PRODUTOS_PACKS.Q15, CAEDU_COMPRAS_PRODUTOS_PACKS.Q16, 0 AS Q17, 0 AS Q18, 0 AS Q19, 
		0 AS Q20, 0 AS Q21, 0 AS Q22, 0 AS Q23, 0 AS Q24, 0 AS Q25, 0 AS Q26, 0 AS Q27, 0 AS Q28, 0 AS Q29, 
		0 AS Q30, 0 AS Q31, 0 AS Q32, 0 AS Q33, 0 AS Q34, 0 AS Q35, 0 AS Q36, 0 AS Q37, 0 AS Q38, 0 AS Q39, 
		0 AS Q40, 0 AS Q41, 0 AS Q42, 0 AS Q43, 0 AS Q44, 0 AS Q45, 0 AS Q46, 0 AS Q47, 0 AS Q48  
		FROM CAEDU_COMPRAS_PRODUTOS_PACKS WHERE   CAEDU_COMPRAS_PRODUTOS_PACKS.PEDIDO = ?V_COMPRAS_01.PEDIDO
		ENDTEXT

		TEXT TO .CursorSchema NOSHOW TEXTMERGE PRETEXT 7
		PEDIDO C(8), PRODUTO C(12), COR_PRODUTO C(10), DESC_COR_PRODUTO C(40), QTDE I, Q1 I, Q2 I, Q3 I, Q4 I, 
		Q5 I, Q6 I, Q7 I, Q8 I, Q9 I, Q10 I, Q11 I, Q12 I, Q13 I, Q14 I, Q15 I, Q16 I, Q17 I, Q18 I, Q19 I, Q20 I, 
		Q21 I, Q22 I, Q23 I, Q24 I, Q25 I, Q26 I, Q27 I, Q28 I, Q29 I, Q30 I, Q31 I, Q32 I, Q33 I, Q34 I, Q35 I, 
		Q36 I, Q37 I, Q38 I, Q39 I, Q40 I, Q41 I, Q42 I, Q43 I, Q44 I, Q45 I, Q46 I, Q47 I, Q48 I
		ENDTEXT

		TEXT TO .UpdateNameList NOSHOW TEXTMERGE PRETEXT 7
		PEDIDO CAEDU_COMPRAS_PRODUTOS_PACKS.PEDIDO, PRODUTO CAEDU_COMPRAS_PRODUTOS_PACKS.PRODUTO, 
		COR_PRODUTO CAEDU_COMPRAS_PRODUTOS_PACKS.COR_PRODUTO, DESC_COR_PRODUTO CAEDU_COMPRAS_PRODUTOS_PACKS.DESC_COR_PRODUTO,
		QTDE CAEDU_COMPRAS_PRODUTOS_PACKS.QTDE, Q1 CAEDU_COMPRAS_PRODUTOS_PACKS.Q1, Q2 CAEDU_COMPRAS_PRODUTOS_PACKS.Q2, 
		Q3 CAEDU_COMPRAS_PRODUTOS_PACKS.Q3, Q4 CAEDU_COMPRAS_PRODUTOS_PACKS.Q4, Q5 CAEDU_COMPRAS_PRODUTOS_PACKS.Q5, 
		Q6 CAEDU_COMPRAS_PRODUTOS_PACKS.Q6, Q7 CAEDU_COMPRAS_PRODUTOS_PACKS.Q7, Q8 CAEDU_COMPRAS_PRODUTOS_PACKS.Q8, 
		Q9 CAEDU_COMPRAS_PRODUTOS_PACKS.Q9, Q10 CAEDU_COMPRAS_PRODUTOS_PACKS.Q10, Q11 CAEDU_COMPRAS_PRODUTOS_PACKS.Q11, 
		Q12 CAEDU_COMPRAS_PRODUTOS_PACKS.Q12, Q13 CAEDU_COMPRAS_PRODUTOS_PACKS.Q13, Q14 CAEDU_COMPRAS_PRODUTOS_PACKS.Q14, 
		Q15 CAEDU_COMPRAS_PRODUTOS_PACKS.Q15, Q16 CAEDU_COMPRAS_PRODUTOS_PACKS.Q16
		ENDTEXT

		TEXT TO .UpdatableFieldList NOSHOW TEXTMERGE PRETEXT 7
		PEDIDO, PRODUTO, COR_PRODUTO, DESC_COR_PRODUTO, QTDE, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10, 
		Q11, Q12, Q13, Q14, Q15, Q16
		ENDTEXT

		.Tables = "CAEDU_COMPRAS_PRODUTOS_PACKS"
		.KeyFieldList = "PEDIDO, PRODUTO, COR_PRODUTO"

		TEXT TO .QueryList NOSHOW TEXTMERGE PRETEXT 7
		PEDIDO CAEDU_COMPRAS_PRODUTOS_PACKS.PEDIDO, PRODUTO CAEDU_COMPRAS_PRODUTOS_PACKS.PRODUTO, 
		COR_PRODUTO CAEDU_COMPRAS_PRODUTOS_PACKS.COR_PRODUTO, DESC_COR_PRODUTO CAEDU_COMPRAS_PRODUTOS_PACKS.DESC_COR_PRODUTO, 
		QTDE CAEDU_COMPRAS_PRODUTOS_PACKS.QTDE, Q1 CAEDU_COMPRAS_PRODUTOS_PACKS.Q1, Q2 CAEDU_COMPRAS_PRODUTOS_PACKS.Q2, 
		Q3 CAEDU_COMPRAS_PRODUTOS_PACKS.Q3, Q4 CAEDU_COMPRAS_PRODUTOS_PACKS.Q4, Q5 CAEDU_COMPRAS_PRODUTOS_PACKS.Q5, 
		Q6 CAEDU_COMPRAS_PRODUTOS_PACKS.Q6, Q7 CAEDU_COMPRAS_PRODUTOS_PACKS.Q7, Q8 CAEDU_COMPRAS_PRODUTOS_PACKS.Q8, 
		Q9 CAEDU_COMPRAS_PRODUTOS_PACKS.Q9, Q10 CAEDU_COMPRAS_PRODUTOS_PACKS.Q10, Q11 CAEDU_COMPRAS_PRODUTOS_PACKS.Q11, 
		Q12 CAEDU_COMPRAS_PRODUTOS_PACKS.Q12, Q13 CAEDU_COMPRAS_PRODUTOS_PACKS.Q13, Q14 CAEDU_COMPRAS_PRODUTOS_PACKS.Q14, 
		Q15 CAEDU_COMPRAS_PRODUTOS_PACKS.Q15, Q16 CAEDU_COMPRAS_PRODUTOS_PACKS.Q16
		ENDTEXT

		TEXT TO .CaptionList NOSHOW TEXTMERGE PRETEXT 7
		PEDIDO Pedido, PRODUTO Produto, COR_PRODUTO Cor Produto, DESC_COR_PRODUTO Desc Cor Produto, QTDE Qtde, Q1 Q1, 
		Q2 Q2, Q3 Q3, Q4 Q4, Q5 Q5, Q6 Q6, Q7 Q7, Q8 Q8, Q9 Q9, Q10 Q10, Q11 Q11, Q12 Q12, Q13 Q13, Q14 Q14, 
		Q15 Q15, Q16 Q16, Q17 Q17, Q18 Q18, Q19 Q19, Q20 Q20, Q21 Q21, Q22 Q22, Q23 Q23, Q24 Q24, Q25 Q25, 
		Q26 Q26, Q27 Q27, Q28 Q28, Q29 Q29, Q30 Q30, Q31 Q31, Q32 Q32, Q33 Q33, Q34 Q34, Q35 Q35, Q36 Q36, Q37 Q37, 
		Q38 Q38, Q39 Q39, Q40 Q40, Q41 Q41, Q42 Q42, Q43 Q43, Q44 Q44, Q45 Q45, Q46 Q46, Q47 Q47, Q48 Q48
		ENDTEXT

		TEXT TO .DefaultsValuesList NOSHOW TEXTMERGE PRETEXT 7

		ENDTEXT

		.FTableList		=""
		.Alias				="v_caedu_compras_produtos_packs"
		.ParentCursor		="v_compras_01"
		.BufferModeOverride=5
		.NoDataOnLoad		=.T.
		.IsUpdateCursor	=.T.
		.IsMaster			=.F.
		.UpdateType		=1
		.WhereType			=3
		.FetchMemo			=.T.
		.SendUpdates		=.F.
		.UseMemoSize		=255
		.FetchSize			=-1
		.MaxRecords		=-1
		.Prepared			=.F.
		.CompareMemo		=.F.
		.BatchUpdateCount	=1
		.OpenCursor() 

	ENDWITH
ENDIF

ENDFUNC && FUNCTION load_caedu_compras_produtos_packs

FUNCTION load_caedu_compras_produtos_packs_total
PARAMETERS oThisformset

if Type(".CursorV_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL")="U" 
   AddNewObject(oThisformset.dataenvironment, "CursorV_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL","ccursoradapter") 
	With oThisformset.dataenvironment.CursorV_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL
		.DataSourceType = "ADO"

		TEXT TO .SelectCmd NOSHOW TEXTMERGE PRETEXT 7
		SELECT PEDIDO, PRODUTO, QTDE, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10, Q11, Q12, Q13, Q14, Q15, Q16, 
		0 AS Q17, 0 AS Q18, 0 AS Q19, 0 AS Q20, 0 AS Q21, 0 AS Q22, 0 AS Q23, 0 AS Q24, 0 AS Q25, 0 AS Q26, 
		0 AS Q27, 0 AS Q28, 0 AS Q29, 0 AS Q30, 0 AS Q31, 0 AS Q32, 0 AS Q33, 0 AS Q34, 0 AS Q35, 0 AS Q36, 
		0 AS Q37, 0 AS Q38, 0 AS Q39, 0 AS Q40, 0 AS Q41, 0 AS Q42, 0 AS Q43, 0 AS Q44, 0 AS Q45, 0 AS Q46, 
		0 AS Q47, 0 AS Q48 FROM CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL WHERE PEDIDO = ?V_COMPRAS_01.PEDIDO
		ENDTEXT

		TEXT TO .CursorSchema NOSHOW TEXTMERGE PRETEXT 7
		PEDIDO C(8), PRODUTO C(12), QTDE I, Q1 I, Q2 I, Q3 I, Q4 I, Q5 I, Q6 I, Q7 I, Q8 I, Q9 I, Q10 I, Q11 I, Q12 I, 
		Q13 I, Q14 I, Q15 I, Q16 I, Q17 I, Q18 I, Q19 I, Q20 I, Q21 I, Q22 I, Q23 I, Q24 I, Q25 I, Q26 I, Q27 I, Q28 I, 
		Q29 I, Q30 I, Q31 I, Q32 I, Q33 I, Q34 I, Q35 I, Q36 I, Q37 I, Q38 I, Q39 I, Q40 I, Q41 I, Q42 I, Q43 I, Q44 I, 
		Q45 I, Q46 I, Q47 I, Q48 I
		ENDTEXT

		TEXT TO .UpdateNameList NOSHOW TEXTMERGE PRETEXT 7
		PEDIDO CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.PEDIDO, PRODUTO CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.PRODUTO, QTDE CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.QTDE, 
		Q1 CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q1, Q2 CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q2, Q3 CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q3, 
		Q4 CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q4, Q5 CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q5, Q6 CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q6, 
		Q7 CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q7, Q8 CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q8, Q9 CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q9, 
		Q10 CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q10, Q11 CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q11, Q12 CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q12, 
		Q13 CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q13, Q14 CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q14, Q15 CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q15, 
		Q16 CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q16 
		ENDTEXT

		TEXT TO .UpdatableFieldList NOSHOW TEXTMERGE PRETEXT 7
		PEDIDO, PRODUTO, QTDE, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10, Q11, Q12, Q13, Q14, Q15, Q16
		ENDTEXT

		.Tables = "CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL"
		.KeyFieldList = "PEDIDO, PRODUTO"

		TEXT TO .QueryList NOSHOW TEXTMERGE PRETEXT 7
		PEDIDO CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.PEDIDO, PRODUTO CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.PRODUTO, QTDE CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.QTDE, 
		Q1 CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q1, Q2 CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q2, Q3 CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q3, Q4 CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q4, 
		Q5 CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q5, Q6 CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q6, Q7 CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q7, Q8 CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q8, 
		Q9 CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q9, Q10 CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q10, Q11 CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q11, Q12 CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q12, 
		Q13 CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q13, Q14 CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q14, Q15 CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q15, Q16 CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q16
		ENDTEXT

		TEXT TO .CaptionList NOSHOW TEXTMERGE PRETEXT 7
		PEDIDO Pedido, PRODUTO Produto, QTDE Qtde, Q1 Q1, Q2 Q2, Q3 Q3, Q4 Q4, Q5 Q5, Q6 Q6, Q7 Q7, Q8 Q8, Q9 Q9, Q10 Q10, Q11 Q11, Q12 Q12, Q13 Q13, Q14 Q14, Q15 Q15, Q16 Q16, Q17 Q17, 
		Q18 Q18, Q19 Q19, Q20 Q20, Q21 Q21, Q22 Q22, Q23 Q23, Q24 Q24, Q25 Q25, Q26 Q26, Q27 Q27, Q28 Q28, Q29 Q29, Q30 Q30, Q31 Q31, Q32 Q32, Q33 Q33, Q34 Q34, Q35 Q35, Q36 Q36, Q37 Q37, 
		Q38 Q38, Q39 Q39, Q40 Q40, Q41 Q41, Q42 Q42, Q43 Q43, Q44 Q44, Q45 Q45, Q46 Q46, Q47 Q47, Q48 Q48
		ENDTEXT

		TEXT TO .DefaultsValuesList NOSHOW TEXTMERGE PRETEXT 7

		ENDTEXT

		.FTableList		=""
		.Alias				="v_caedu_compras_produtos_packs_total"
		.ParentCursor		="v_compras_01"
		.BufferModeOverride=5
		.NoDataOnLoad		=.T.
		.IsUpdateCursor	=.T.
		.IsMaster			=.F.
		.UpdateType		=1
		.WhereType			=3
		.FetchMemo			=.T.
		.SendUpdates		=.F.
		.UseMemoSize		=255
		.FetchSize			=-1
		.MaxRecords		=-1
		.Prepared			=.F.
		.CompareMemo		=.F.
		.BatchUpdateCount	=1
		.OpenCursor() 

	ENDWITH
ENDIF

ENDFUNC && FUNCTION load_caedu_compras_produtos_packs_total


FUNCTION load_v_produtos_99
PARAMETERS oThisformset
With oThisformset.dataenvironment 
  if Type(".Cursorv_produtos_99")="U" 
      AddNewObject(oThisformset.dataenvironment, "Cursorv_produtos_99","ccursoradapter") 
	.Cursorv_produtos_99.DataSourceType			="ADO"
	Text to .Cursorv_produtos_99.SelectCmd TextMerge NoShow PRETEXT 7
	SELECT PRODUTOS.PRODUTO, PRODUTOS.DESC_PRODUTO, PRODUTOS.GRUPO_PRODUTO, PRODUTOS.SUBGRUPO_PRODUTO, PRODUTOS.PERIODO_PCP, PRODUTOS.TABELA_OPERACOES, PRODUTOS.FATOR_OPERACOES, PRODUTOS.CLASSIF_FISCAL, PRODUTOS.TIPO_PRODUTO, PRODUTOS.MATERIAL,
	   PRODUTOS.CODIGO_PRECO, PRODUTOS.TABELA_MEDIDAS, PRODUTOS.COLECAO, PRODUTOS.GRADE, PRODUTOS.DESC_PROD_NF, PRODUTOS.LINHA, PRODUTOS.GRIFFE, PRODUTOS.CARTELA, PRODUTOS.UNIDADE, PRODUTOS.PESO, PRODUTOS.REVENDA, PRODUTOS.REFER_FABRICANTE,
	   PRODUTOS.MODELAGEM, PRODUTOS.SORTIMENTO_COR, PRODUTOS.FABRICANTE, PRODUTOS.SORTIMENTO_TAMANHO, PRODUTOS.OBS, PRODUTOS.VARIA_PRECO_COR, PRODUTOS.VARIA_PRECO_TAM, PRODUTOS.PONTEIRO_PRECO_TAM, PRODUTOS.VARIA_CUSTO_COR, PRODUTOS.PERTENCE_A_CONJUNTO,
	   PRODUTOS.TRIBUT_ICMS, PRODUTOS.TRIBUT_ORIGEM, PRODUTOS.VARIA_CUSTO_TAM, PRODUTOS.CUSTO_REPOSICAO1, PRODUTOS.CUSTO_REPOSICAO2, PRODUTOS.CUSTO_REPOSICAO3, PRODUTOS.CUSTO_REPOSICAO4, PRODUTOS.DATA_REPOSICAO, PRODUTOS.ESTILISTA, PRODUTOS.MODELISTA,
	   PRODUTOS.TAMANHO_BASE,PRODUTOS.GIRO_ENTREGA,PRODUTOS.DIAS_COMPRA, PRODUTOS.INATIVO, PRODUTOS.ENVIA_LOJA_VAREJO, PRODUTOS.ENVIA_LOJA_ATACADO, PRODUTOS.ENVIA_REPRESENTANTE, PRODUTOS.ENVIA_VAREJO_INTERNET, PRODUTOS.ENVIA_ATACADO_INTERNET,
	   PRODUTOS.MODELO, PRODUTOS.REDE_LOJAS, PRODUTOS.DATA_PARA_TRANSFERENCIA, PRODUTOS.FABRICANTE_ICMS_ABATER, PRODUTOS.FABRICANTE_PRAZO_PGTO, PRODUTOS.TAXA_JUROS_DEFLACIONAR, PRODUTOS.TAXAS_IMPOSTOS_APLICAR, PRODUTOS.PRECO_REPOSICAO_1,
	   PRODUTOS.PRECO_REPOSICAO_2, PRODUTOS.PRECO_REPOSICAO_3, PRODUTOS.PRECO_REPOSICAO_4, PRODUTOS.PRECO_A_VISTA_REPOSICAO_1, PRODUTOS.PRECO_A_VISTA_REPOSICAO_2, PRODUTOS.PRECO_A_VISTA_REPOSICAO_3, PRODUTOS.PRECO_A_VISTA_REPOSICAO_4,
	   PRODUTOS.DROP_DE_TAMANHOS, PRODUTOS.FABRICANTE_FRETE, PRODUTOS.DATA_CADASTRAMENTO, PRODUTOS.STATUS_PRODUTO, PRODUTOS.TIPO_STATUS_PRODUTO, MATERIAIS.DESC_MATERIAL, PRODUTOS.EMPRESA, PRODUTOS_MODELO.DESC_MODELO, PRODUTOS.RESTRICAO_LAVAGEM,
	   PRODUTOS.COMPOSICAO, PRODUTOS.ORCAMENTO, PRODUTOS.CLIENTE_DO_PRODUTO, CLIENTES_ATACADO.CLIFOR, CLIENTES_ATACADO.COD_CLIENTE, PRODUTOS.CONTA_CONTABIL, PRODUTOS.ESPESSURA, PRODUTOS.ALTURA, PRODUTOS.LARGURA, PRODUTOS.COMPRIMENTO,
	   PRODUTOS.EMPILHAMENTO_MAXIMO, PRODUTOS.SEXO_TIPO, PRODUTOS.PARTE_TIPO, PRODUTOS_TAB_MEDIDAS.DESCRICAO_TABELA,PRODUTOS_TAB_OPERACOES.DESCRICAO_TABELA AS DESCRICAO_TAB_OPERACOES, PRODUTOS.INDICADOR_CFOP, PRODUTOS.QUALIDADE, PRODUTOS.MONTAGEM_KIT,
	   PRODUTOS.MRP_AGRUPAR_NECESSIDADE_TIPO, PRODUTOS.MRP_AGRUPAR_NECESSIDADE_DIAS, PRODUTOS.MRP_MAIOR_GIRO_MP_DIAS, PRODUTOS.MRP_EMISSAO_LIBERACAO_DIAS, PRODUTOS.MRP_ENTREGA_GIRO_DIAS, PRODUTOS.MRP_RR, PRODUTOS.MRP_FP, PRODUTOS.MRP_DIAS_SEGURANCA,
	   PRODUTOS.COD_FLUXO_PRODUTO, PRODUTOS_FLUXO.DESC_FLUXO_PRODUTO, PRODUTOS.DATA_INICIO_DESENVOLVIMENTO, SPACE(8) AS DESC_TAMANHO_BASE, CTB_CONTA_PLANO.DESC_CONTA, CTB_CONTA_PLANO.CODIGO_RESUMIDO, PRODUTOS.CONTA_CONTABIL_COMPRA,
	   CTB_CONTA_PLANO_A.DESC_CONTA, CTB_CONTA_PLANO_A.CODIGO_RESUMIDO, PRODUTOS.CONTA_CONTABIL_VENDA, CTB_CONTA_PLANO_B.DESC_CONTA, CTB_CONTA_PLANO_B.CODIGO_RESUMIDO, PRODUTOS.CONTA_CONTABIL_DEV_COMPRA, CTB_CONTA_PLANO_C.DESC_CONTA,
	   CTB_CONTA_PLANO_C.CODIGO_RESUMIDO, PRODUTOS.CONTA_CONTABIL_DEV_VENDA, CTB_CONTA_PLANO_D.DESC_CONTA, CTB_CONTA_PLANO_D.CODIGO_RESUMIDO, PRODUTOS.MRP_PARTICIPANTE, PRODUTOS.ID_EXCECAO_GRUPO, CTB_EXCECAO_GRUPO.DESC_EXCECAO_GRUPO ,
	  DESCRICAO_INDICADOR_CFOP,CONTINUIDADE, FATOR_P, FATOR_Q, FATOR_F, COD_CATEGORIA,   COD_SUBCATEGORIA, PRODUTOS.COD_PRODUTO_SOLUCAO, PRODUTOS.COD_PRODUTO_SEGMENTO, PRODUTOS_SOLUCAO.DESC_PRODUTO_SOLUCAO, PRODUTOS_SEGMENTO.DESC_PRODUTO_SEGMENTO,
	 COLECOES.DESC_COLECAO, PRODUTOS.ERP_QTD_PACK 
	 FROM PRODUTOS INNER JOIN COLECOES ON PRODUTOS.COLECAO = COLECOES.COLECAO    LEFT JOIN MATERIAIS ON MATERIAIS.MATERIAL = PRODUTOS.MATERIAL LEFT JOIN CTB_CONTA_PLANO AS CTB_CONTA_PLANO_D ON PRODUTOS.CONTA_CONTABIL_DEV_VENDA = 
	CTB_CONTA_PLANO_D.CONTA_CONTABIL LEFT JOIN CTB_CONTA_PLANO AS   CTB_CONTA_PLANO_C ON PRODUTOS.CONTA_CONTABIL_DEV_COMPRA = CTB_CONTA_PLANO_C.CONTA_CONTABIL LEFT JOIN CTB_CONTA_PLANO AS CTB_CONTA_PLANO_B ON PRODUTOS.CONTA_CONTABIL_VENDA = 
	CTB_CONTA_PLANO_B.CONTA_CONTABIL LEFT JOIN CTB_CONTA_PLANO AS   CTB_CONTA_PLANO_A ON PRODUTOS.CONTA_CONTABIL_COMPRA = CTB_CONTA_PLANO_A.CONTA_CONTABIL LEFT JOIN CTB_CONTA_PLANO AS CTB_CONTA_PLANO ON PRODUTOS.CONTA_CONTABIL = 
	CTB_CONTA_PLANO.CONTA_CONTABIL LEFT JOIN EMPRESA ON PRODUTOS.EMPRESA = EMPRESA.EMPRESA   LEFT JOIN PRODUTOS_MODELO ON PRODUTOS.MODELAGEM = PRODUTOS_MODELO.MODELAGEM LEFT JOIN CLIENTES_ATACADO ON PRODUTOS.CLIENTE_DO_PRODUTO = 
	CLIENTES_ATACADO.CLIENTE_ATACADO LEFT JOIN PRODUTOS_TAB_MEDIDAS ON PRODUTOS.TABELA_MEDIDAS =   PRODUTOS_TAB_MEDIDAS.TABELA_MEDIDAS LEFT JOIN PRODUTOS_TAB_OPERACOES ON PRODUTOS.TABELA_OPERACOES = PRODUTOS_TAB_OPERACOES.TABELA_OPERACOES LEFT JOIN 
	PRODUTOS_FLUXO ON PRODUTOS.COD_FLUXO_PRODUTO = PRODUTOS_FLUXO.COD_FLUXO_PRODUTO LEFT JOIN   CTB_EXCECAO_GRUPO ON PRODUTOS.ID_EXCECAO_GRUPO = CTB_EXCECAO_GRUPO.ID_EXCECAO_GRUPO LEFT JOIN CTB_LX_INDICADOR_CFOP ON PRODUTOS.INDICADOR_CFOP = 
	CTB_LX_INDICADOR_CFOP.INDICADOR_CFOP LEFT JOIN PRODUTOS_SEGMENTO ON ( PRODUTOS.COD_PRODUTO_SEGMENTO = PRODUTOS_SEGMENTO.COD_PRODUTO_SEGMENTO ) LEFT JOIN PRODUTOS_SOLUCAO ON ( PRODUTOS.COD_PRODUTO_SOLUCAO = PRODUTOS_SOLUCAO.COD_PRODUTO_SOLUCAO  )     
	WHERE PRODUTOS.PRODUTO = ?MEUPRODUTO 
	EndText

	Text to .Cursorv_produtos_99.CursorSchema TextMerge NoShow PRETEXT 7
	PRODUTO C(12), DESC_PRODUTO C(40), GRUPO_PRODUTO C(25), SUBGRUPO_PRODUTO C(25), PERIODO_PCP C(25), TABELA_OPERACOES C(25), FATOR_OPERACOES N(9,3), CLASSIF_FISCAL C(10), TIPO_PRODUTO C(25), MATERIAL C(11), CODIGO_PRECO C(4), TABELA_MEDIDAS C(25),
	 COLECAO C(6), GRADE C(25), DESC_PROD_NF C(40), LINHA C(25), GRIFFE C(25), CARTELA C(6), UNIDADE C(5), PESO N(16,8), REVENDA L, REFER_FABRICANTE C(25), MODELAGEM C(10), SORTIMENTO_COR L, FABRICANTE C(25), SORTIMENTO_TAMANHO L, OBS M,
	 VARIA_PRECO_COR L, VARIA_PRECO_TAM L, PONTEIRO_PRECO_TAM C(48), VARIA_CUSTO_COR L, PERTENCE_A_CONJUNTO L, TRIBUT_ICMS C(3), TRIBUT_ORIGEM C(3), VARIA_CUSTO_TAM L, CUSTO_REPOSICAO1 N(16,2), CUSTO_REPOSICAO2 N(16,2), CUSTO_REPOSICAO3 N(16,2),
	 CUSTO_REPOSICAO4 N(16,2), DATA_REPOSICAO D, ESTILISTA C(25), MODELISTA C(25), TAMANHO_BASE I, GIRO_ENTREGA I, DIAS_COMPRA C(50), INATIVO L, ENVIA_LOJA_VAREJO L, ENVIA_LOJA_ATACADO L, ENVIA_REPRESENTANTE L, ENVIA_VAREJO_INTERNET L,
	 ENVIA_ATACADO_INTERNET L, MODELO C(8), REDE_LOJAS C(6), DATA_PARA_TRANSFERENCIA D, FABRICANTE_ICMS_ABATER N(10,5), FABRICANTE_PRAZO_PGTO I, TAXA_JUROS_DEFLACIONAR N(10,5), TAXAS_IMPOSTOS_APLICAR N(10,5), PRECO_REPOSICAO_1 N(16,2),
	 PRECO_REPOSICAO_2 N(16,2), PRECO_REPOSICAO_3 N(16,2), PRECO_REPOSICAO_4 N(16,2), PRECO_A_VISTA_REPOSICAO_1 N(16,2), PRECO_A_VISTA_REPOSICAO_2 N(16,2), PRECO_A_VISTA_REPOSICAO_3 N(16,2), PRECO_A_VISTA_REPOSICAO_4 N(16,2), DROP_DE_TAMANHOS I,
	 FABRICANTE_FRETE N(10,5), DATA_CADASTRAMENTO D, STATUS_PRODUTO C(2), TIPO_STATUS_PRODUTO I, DESC_MATERIAL C(40), EMPRESA I, DESC_MODELO C(80), RESTRICAO_LAVAGEM C(6), COMPOSICAO C(6), ORCAMENTO C(25), CLIENTE_DO_PRODUTO C(25), CLIFOR C(6),
	 COD_CLIENTE C(6), CONTA_CONTABIL C(20), ESPESSURA N(16,2), ALTURA N(16,2), LARGURA N(12,5), COMPRIMENTO N(16,2), EMPILHAMENTO_MAXIMO I, SEXO_TIPO I, PARTE_TIPO I, DESCRICAO_TABELA C(60), DESCRICAO_TAB_OPERACOES C(60), INDICADOR_CFOP I, QUALIDADE I,
	 MONTAGEM_KIT I, MRP_AGRUPAR_NECESSIDADE_TIPO I, MRP_AGRUPAR_NECESSIDADE_DIAS I, MRP_MAIOR_GIRO_MP_DIAS I, MRP_EMISSAO_LIBERACAO_DIAS I, MRP_ENTREGA_GIRO_DIAS I, MRP_RR I, MRP_FP I, MRP_DIAS_SEGURANCA I, COD_FLUXO_PRODUTO C(5),
	 DESC_FLUXO_PRODUTO C(40), DATA_INICIO_DESENVOLVIMENTO D, DESC_TAMANHO_BASE C(8), DESC_CONTA C(40), CODIGO_RESUMIDO C(5), CONTA_CONTABIL_COMPRA C(20), DESC_CONTA1 C(40), CODIGO_RESUMIDO1 C(5), CONTA_CONTABIL_VENDA C(20), DESC_CONTA2 C(40),
	 CODIGO_RESUMIDO2 C(5), CONTA_CONTABIL_DEV_COMPRA C(20), DESC_CONTA3 C(40), CODIGO_RESUMIDO3 C(5), CONTA_CONTABIL_DEV_VENDA C(20), DESC_CONTA4 C(40), CODIGO_RESUMIDO4 C(5), MRP_PARTICIPANTE I, ID_EXCECAO_GRUPO I, DESC_EXCECAO_GRUPO C(40),
	 DESCRICAO_INDICADOR_CFOP C(40), CONTINUIDADE I, FATOR_P I, FATOR_Q I, FATOR_F I, COD_CATEGORIA C(2), COD_SUBCATEGORIA C(2), COD_PRODUTO_SOLUCAO I, COD_PRODUTO_SEGMENTO I, DESC_PRODUTO_SOLUCAO C(40), DESC_PRODUTO_SEGMENTO C(40),
	 DESC_COLECAO C(40), ERP_QTD_PACK I
	EndText

	Text to .Cursorv_produtos_99.UpdateNameList TextMerge NoShow PRETEXT 7
	
	EndText

	Text to .Cursorv_produtos_99.UpdatableFieldList TextMerge NoShow PRETEXT 7
	
	EndText

	.Cursorv_produtos_99.Tables	  =""
	.Cursorv_produtos_99.KeyFieldList =""
	
	Text to .Cursorv_produtos_99.QueryList TextMerge NoShow PRETEXT 7
	PRODUTO PRODUTOS.PRODUTO, DESC_PRODUTO PRODUTOS.DESC_PRODUTO, GRUPO_PRODUTO PRODUTOS.GRUPO_PRODUTO, SUBGRUPO_PRODUTO PRODUTOS.SUBGRUPO_PRODUTO, PERIODO_PCP PRODUTOS.PERIODO_PCP, TABELA_OPERACOES PRODUTOS.TABELA_OPERACOES,
	 FATOR_OPERACOES PRODUTOS.FATOR_OPERACOES, CLASSIF_FISCAL PRODUTOS.CLASSIF_FISCAL, TIPO_PRODUTO PRODUTOS.TIPO_PRODUTO, 
	MATERIAL PRODUTOS.MATERIAL, CODIGO_PRECO PRODUTOS.CODIGO_PRECO, TABELA_MEDIDAS PRODUTOS.TABELA_MEDIDAS, COLECAO PRODUTOS.COLECAO, GRADE PRODUTOS.GRADE, DESC_PROD_NF PRODUTOS.DESC_PROD_NF, LINHA PRODUTOS.LINHA, GRIFFE PRODUTOS.GRIFFE,
	 CARTELA PRODUTOS.CARTELA, UNIDADE PRODUTOS.UNIDADE, 
	PESO PRODUTOS.PESO, REVENDA PRODUTOS.REVENDA, REFER_FABRICANTE PRODUTOS.REFER_FABRICANTE, MODELAGEM PRODUTOS.MODELAGEM, SORTIMENTO_COR PRODUTOS.SORTIMENTO_COR, FABRICANTE PRODUTOS.FABRICANTE, SORTIMENTO_TAMANHO PRODUTOS.SORTIMENTO_TAMANHO,
	 OBS PRODUTOS.OBS, VARIA_PRECO_COR PRODUTOS.VARIA_PRECO_COR, VARIA_PRECO_TAM PRODUTOS.VARIA_PRECO_TAM, 
	PONTEIRO_PRECO_TAM PRODUTOS.PONTEIRO_PRECO_TAM, VARIA_CUSTO_COR PRODUTOS.VARIA_CUSTO_COR, PERTENCE_A_CONJUNTO PRODUTOS.PERTENCE_A_CONJUNTO, TRIBUT_ICMS PRODUTOS.TRIBUT_ICMS, TRIBUT_ORIGEM PRODUTOS.TRIBUT_ORIGEM,
	 VARIA_CUSTO_TAM PRODUTOS.VARIA_CUSTO_TAM, CUSTO_REPOSICAO1 PRODUTOS.CUSTO_REPOSICAO1, CUSTO_REPOSICAO2 PRODUTOS.CUSTO_REPOSICAO2, CUSTO_REPOSICAO3 PRODUTOS.CUSTO_REPOSICAO3, CUSTO_REPOSICAO4 PRODUTOS.CUSTO_REPOSICAO4, 
	DATA_REPOSICAO PRODUTOS.DATA_REPOSICAO, ESTILISTA PRODUTOS.ESTILISTA, MODELISTA PRODUTOS.MODELISTA, TAMANHO_BASE PRODUTOS.TAMANHO_BASE, GIRO_ENTREGA PRODUTOS.GIRO_ENTREGA, DIAS_COMPRA PRODUTOS.DIAS_COMPRA, INATIVO PRODUTOS.INATIVO,
	 ENVIA_LOJA_VAREJO PRODUTOS.ENVIA_LOJA_VAREJO, ENVIA_LOJA_ATACADO PRODUTOS.ENVIA_LOJA_ATACADO, ENVIA_REPRESENTANTE PRODUTOS.ENVIA_REPRESENTANTE, 
	ENVIA_VAREJO_INTERNET PRODUTOS.ENVIA_VAREJO_INTERNET, ENVIA_ATACADO_INTERNET PRODUTOS.ENVIA_ATACADO_INTERNET, MODELO PRODUTOS.MODELO, REDE_LOJAS PRODUTOS.REDE_LOJAS, DATA_PARA_TRANSFERENCIA PRODUTOS.DATA_PARA_TRANSFERENCIA,
	 FABRICANTE_ICMS_ABATER PRODUTOS.FABRICANTE_ICMS_ABATER, FABRICANTE_PRAZO_PGTO PRODUTOS.FABRICANTE_PRAZO_PGTO, TAXA_JUROS_DEFLACIONAR PRODUTOS.TAXA_JUROS_DEFLACIONAR, TAXAS_IMPOSTOS_APLICAR PRODUTOS.TAXAS_IMPOSTOS_APLICAR,
	 PRECO_REPOSICAO_1 PRODUTOS.PRECO_REPOSICAO_1, 
	PRECO_REPOSICAO_2 PRODUTOS.PRECO_REPOSICAO_2, PRECO_REPOSICAO_3 PRODUTOS.PRECO_REPOSICAO_3, PRECO_REPOSICAO_4 PRODUTOS.PRECO_REPOSICAO_4, PRECO_A_VISTA_REPOSICAO_1 PRODUTOS.PRECO_A_VISTA_REPOSICAO_1,
	 PRECO_A_VISTA_REPOSICAO_2 PRODUTOS.PRECO_A_VISTA_REPOSICAO_2, PRECO_A_VISTA_REPOSICAO_3 PRODUTOS.PRECO_A_VISTA_REPOSICAO_3, PRECO_A_VISTA_REPOSICAO_4 PRODUTOS.PRECO_A_VISTA_REPOSICAO_4, DROP_DE_TAMANHOS PRODUTOS.DROP_DE_TAMANHOS,
	 FABRICANTE_FRETE PRODUTOS.FABRICANTE_FRETE, DATA_CADASTRAMENTO PRODUTOS.DATA_CADASTRAMENTO, 
	STATUS_PRODUTO PRODUTOS.STATUS_PRODUTO, TIPO_STATUS_PRODUTO PRODUTOS.TIPO_STATUS_PRODUTO, DESC_MATERIAL MATERIAIS.DESC_MATERIAL, EMPRESA PRODUTOS.EMPRESA, DESC_MODELO PRODUTOS_MODELO.DESC_MODELO, RESTRICAO_LAVAGEM PRODUTOS.RESTRICAO_LAVAGEM,
	 COMPOSICAO PRODUTOS.COMPOSICAO, ORCAMENTO PRODUTOS.ORCAMENTO, CLIENTE_DO_PRODUTO PRODUTOS.CLIENTE_DO_PRODUTO, CLIFOR CLIENTES_ATACADO.CLIFOR, 
	COD_CLIENTE CLIENTES_ATACADO.COD_CLIENTE, CONTA_CONTABIL PRODUTOS.CONTA_CONTABIL, ESPESSURA PRODUTOS.ESPESSURA, ALTURA PRODUTOS.ALTURA, LARGURA PRODUTOS.LARGURA, COMPRIMENTO PRODUTOS.COMPRIMENTO, EMPILHAMENTO_MAXIMO PRODUTOS.EMPILHAMENTO_MAXIMO,
	 SEXO_TIPO PRODUTOS.SEXO_TIPO, PARTE_TIPO PRODUTOS.PARTE_TIPO, DESCRICAO_TABELA PRODUTOS_TAB_MEDIDAS.DESCRICAO_TABELA, 
	DESCRICAO_TAB_OPERACOES PRODUTOS_TAB_OPERACOES.DESCRICAO_TABELA, INDICADOR_CFOP PRODUTOS.INDICADOR_CFOP, QUALIDADE PRODUTOS.QUALIDADE, MONTAGEM_KIT PRODUTOS.MONTAGEM_KIT, MRP_AGRUPAR_NECESSIDADE_TIPO PRODUTOS.MRP_AGRUPAR_NECESSIDADE_TIPO,
	 MRP_AGRUPAR_NECESSIDADE_DIAS PRODUTOS.MRP_AGRUPAR_NECESSIDADE_DIAS, MRP_MAIOR_GIRO_MP_DIAS PRODUTOS.MRP_MAIOR_GIRO_MP_DIAS, MRP_EMISSAO_LIBERACAO_DIAS PRODUTOS.MRP_EMISSAO_LIBERACAO_DIAS, MRP_ENTREGA_GIRO_DIAS PRODUTOS.MRP_ENTREGA_GIRO_DIAS,
	 MRP_RR PRODUTOS.MRP_RR, 
	MRP_FP PRODUTOS.MRP_FP, MRP_DIAS_SEGURANCA PRODUTOS.MRP_DIAS_SEGURANCA, COD_FLUXO_PRODUTO PRODUTOS.COD_FLUXO_PRODUTO, DESC_FLUXO_PRODUTO PRODUTOS_FLUXO.DESC_FLUXO_PRODUTO, DATA_INICIO_DESENVOLVIMENTO PRODUTOS.DATA_INICIO_DESENVOLVIMENTO,
	 DESC_CONTA CTB_CONTA_PLANO.DESC_CONTA, CODIGO_RESUMIDO CTB_CONTA_PLANO.CODIGO_RESUMIDO, CONTA_CONTABIL_COMPRA PRODUTOS.CONTA_CONTABIL_COMPRA, CONTA_CONTABIL_VENDA PRODUTOS.CONTA_CONTABIL_VENDA,
	 CONTA_CONTABIL_DEV_COMPRA PRODUTOS.CONTA_CONTABIL_DEV_COMPRA, CONTA_CONTABIL_DEV_VENDA PRODUTOS.CONTA_CONTABIL_DEV_VENDA, 
	MRP_PARTICIPANTE PRODUTOS.MRP_PARTICIPANTE, ID_EXCECAO_GRUPO PRODUTOS.ID_EXCECAO_GRUPO, DESC_EXCECAO_GRUPO CTB_EXCECAO_GRUPO.DESC_EXCECAO_GRUPO, DESCRICAO_INDICADOR_CFOP DESCRICAO_INDICADOR_CFOP, CONTINUIDADE CONTINUIDADE, FATOR_P FATOR_P,
	 FATOR_Q FATOR_Q, FATOR_F FATOR_F, COD_CATEGORIA COD_CATEGORIA, COD_SUBCATEGORIA COD_SUBCATEGORIA, 
	COD_PRODUTO_SOLUCAO PRODUTOS.COD_PRODUTO_SOLUCAO, COD_PRODUTO_SEGMENTO PRODUTOS.COD_PRODUTO_SEGMENTO, DESC_PRODUTO_SOLUCAO PRODUTOS_SOLUCAO.DESC_PRODUTO_SOLUCAO, DESC_PRODUTO_SEGMENTO PRODUTOS_SEGMENTO.DESC_PRODUTO_SEGMENTO,
	 DESC_COLECAO COLECOES.DESC_COLECAO, ERP_QTD_PACK PRODUTOS.ERP_QTD_PACK 
	EndText

	Text to .Cursorv_produtos_99.CaptionList TextMerge NoShow PRETEXT 7
	PRODUTO Produto, DESC_PRODUTO Desc Produto, GRUPO_PRODUTO Grupo Produto, SUBGRUPO_PRODUTO Subgrupo Produto, PERIODO_PCP Periodo Pcp, TABELA_OPERACOES Tabela Operacoes, FATOR_OPERACOES Fator Operacoes, CLASSIF_FISCAL Classif Fiscal,
	 TIPO_PRODUTO Tipo Produto, MATERIAL Material, CODIGO_PRECO Codigo Preco, TABELA_MEDIDAS Tabela Medidas, COLECAO Colecao, GRADE Grade, DESC_PROD_NF Desc Prod Nf, LINHA Linha, GRIFFE Griffe, CARTELA Cartela, UNIDADE Unidade, PESO Peso,
	 REVENDA Revenda, REFER_FABRICANTE Refer Fabricante, MODELAGEM Modelagem, SORTIMENTO_COR Sortimento Cor, FABRICANTE Fabricante, SORTIMENTO_TAMANHO Sortimento Tamanho, OBS Obs, VARIA_PRECO_COR Varia Preco Cor, VARIA_PRECO_TAM Varia Preco Tam,
	 PONTEIRO_PRECO_TAM Ponteiro Preco Tam, VARIA_CUSTO_COR Varia Custo Cor, PERTENCE_A_CONJUNTO Pertence A Conjunto, TRIBUT_ICMS Tribut Icms, TRIBUT_ORIGEM Tribut Origem, VARIA_CUSTO_TAM Varia Custo Tam, CUSTO_REPOSICAO1 Custo Reposicao1,
	 CUSTO_REPOSICAO2 Custo Reposicao2, CUSTO_REPOSICAO3 Custo Reposicao3, CUSTO_REPOSICAO4 Custo Reposicao4, DATA_REPOSICAO Data Reposicao, ESTILISTA Estilista, MODELISTA Modelista, TAMANHO_BASE Tamanho Base, GIRO_ENTREGA Giro Entrega,
	 DIAS_COMPRA Dias Compra, INATIVO Inativo, ENVIA_LOJA_VAREJO Envia Loja Varejo, ENVIA_LOJA_ATACADO Envia Loja Atacado, ENVIA_REPRESENTANTE Envia Representante, ENVIA_VAREJO_INTERNET Envia Varejo Internet,
	 ENVIA_ATACADO_INTERNET Envia Atacado Internet, MODELO Modelo, REDE_LOJAS Rede Lojas, DATA_PARA_TRANSFERENCIA Data Para Transferencia, FABRICANTE_ICMS_ABATER Fabricante Icms Abater, FABRICANTE_PRAZO_PGTO Fabricante Prazo Pgto,
	 TAXA_JUROS_DEFLACIONAR Taxa Juros Deflacionar, TAXAS_IMPOSTOS_APLICAR Taxas Impostos Aplicar, PRECO_REPOSICAO_1 Preco Reposicao 1, PRECO_REPOSICAO_2 Preco Reposicao 2, PRECO_REPOSICAO_3 Preco Reposicao 3, PRECO_REPOSICAO_4 Preco Reposicao 4,
	 PRECO_A_VISTA_REPOSICAO_1 Preco A Vista Reposicao 1, PRECO_A_VISTA_REPOSICAO_2 Preco A Vista Reposicao 2, PRECO_A_VISTA_REPOSICAO_3 Preco A Vista Reposicao 3, PRECO_A_VISTA_REPOSICAO_4 Preco A Vista Reposicao 4, DROP_DE_TAMANHOS Drop De Tamanhos,
	 FABRICANTE_FRETE Fabricante Frete, DATA_CADASTRAMENTO Data Cadastramento, STATUS_PRODUTO Status Produto, TIPO_STATUS_PRODUTO Tipo Status Produto, DESC_MATERIAL Desc Material, EMPRESA Empresa, DESC_MODELO Desc Modelo,
	 RESTRICAO_LAVAGEM Restricao Lavagem, COMPOSICAO Composicao, ORCAMENTO Orcamento, CLIENTE_DO_PRODUTO Cliente Do Produto, CLIFOR Clifor, COD_CLIENTE Cod Cliente, CONTA_CONTABIL Conta Contabil, ESPESSURA Espessura, ALTURA Altura, LARGURA Largura,
	 COMPRIMENTO Comprimento, EMPILHAMENTO_MAXIMO Empilhamento Maximo, SEXO_TIPO Sexo Tipo, PARTE_TIPO Parte Tipo, DESCRICAO_TABELA Descricao Tabela, DESCRICAO_TAB_OPERACOES Descricao Tab Operacoes, INDICADOR_CFOP Indicador Cfop, QUALIDADE Qualidade,
	 MONTAGEM_KIT Montagem Kit, MRP_AGRUPAR_NECESSIDADE_TIPO Mrp Agrupar Necessidade Tipo, MRP_AGRUPAR_NECESSIDADE_DIAS Mrp Agrupar Necessidade Dias, MRP_MAIOR_GIRO_MP_DIAS Mrp Maior Giro Mp Dias, MRP_EMISSAO_LIBERACAO_DIAS Mrp Emissao Liberacao Dias,
	 MRP_ENTREGA_GIRO_DIAS Mrp Entrega Giro Dias, MRP_RR Mrp Rr, MRP_FP Mrp Fp, MRP_DIAS_SEGURANCA Mrp Dias Seguranca, COD_FLUXO_PRODUTO Cod Fluxo Produto, DESC_FLUXO_PRODUTO Desc Fluxo Produto, DATA_INICIO_DESENVOLVIMENTO Data Inicio Desenvolvimento,
	 DESC_TAMANHO_BASE Desc Tamanho Base, DESC_CONTA Desc Conta, CODIGO_RESUMIDO Codigo Resumido, CONTA_CONTABIL_COMPRA Conta Contabil Compra, DESC_CONTA1 Desc Conta1, CODIGO_RESUMIDO1 Codigo Resumido1, CONTA_CONTABIL_VENDA Conta Contabil Venda,
	 DESC_CONTA2 Desc Conta2, CODIGO_RESUMIDO2 Codigo Resumido2, CONTA_CONTABIL_DEV_COMPRA Conta Contabil Dev Compra, DESC_CONTA3 Desc Conta3, CODIGO_RESUMIDO3 Codigo Resumido3, CONTA_CONTABIL_DEV_VENDA Conta Contabil Dev Venda, DESC_CONTA4 Desc Conta4,
	 CODIGO_RESUMIDO4 Codigo Resumido4, MRP_PARTICIPANTE Mrp Participante, ID_EXCECAO_GRUPO Id Excecao Grupo, DESC_EXCECAO_GRUPO Desc Excecao Grupo, DESCRICAO_INDICADOR_CFOP Descricao Indicador Cfop, CONTINUIDADE Continuidade, FATOR_P Fator P,
	 FATOR_Q Fator Q, FATOR_F Fator F, COD_CATEGORIA Cod Categoria, COD_SUBCATEGORIA Cod Subcategoria, COD_PRODUTO_SOLUCAO Cod Produto Solucao, COD_PRODUTO_SEGMENTO Cod Produto Segmento, DESC_PRODUTO_SOLUCAO Desc Produto Solucao,
	 DESC_PRODUTO_SEGMENTO Desc Produto Segmento,
	 DESC_COLECAO Desc Colecao,  ERP_QTD_PACK QTD PACK
	EndText

	Text to .Cursorv_produtos_99.DefaultsValuesList TextMerge NoShow PRETEXT 7
	
	EndText
	
	.Cursorv_produtos_99.FTableList	=""
	.Cursorv_produtos_99.Alias ="v_produtos_99"
	.Cursorv_produtos_99.ParentCursor =""
	.Cursorv_produtos_99.BufferModeOverride	=5
	.Cursorv_produtos_99.NoDataOnLoad =.T.
	.Cursorv_produtos_99.IsUpdateCursor =.F.
	.Cursorv_produtos_99.IsMaster 	=.F.
	.Cursorv_produtos_99.UpdateType	=1
	.Cursorv_produtos_99.WhereType	=3
	.Cursorv_produtos_99.FetchMemo	=.T.
	.Cursorv_produtos_99.SendUpdates =.F.
	.Cursorv_produtos_99.UseMemoSize =255
	.Cursorv_produtos_99.FetchSize	=-1
	.Cursorv_produtos_99.MaxRecords	=-1
	.Cursorv_produtos_99.Prepared	=.F.
	.Cursorv_produtos_99.CompareMemo=.F.
	.Cursorv_produtos_99.BatchUpdateCount	=1
	.Cursorv_produtos_99.OpenCursor() 
  EndIf 
EndWith 
ENDFUNC && FUNCTION load_v_produtos_99

FUNCTION load_v_produtos_00_packs_permitidos
PARAMETERS oThisformset

With oThisformset.dataenvironment 
  if Type(".Cursorv_produtos_00_packs_permitidos")="U" 
      AddNewObject(oThisformset.dataenvironment, "Cursorv_produtos_00_packs_permitidos","ccursoradapter") 
	.Cursorv_produtos_00_packs_permitidos.DataSourceType			="ADO"
	Text to .Cursorv_produtos_00_packs_permitidos.SelectCmd TextMerge NoShow
	SELECT PRODUTO_CORES.PRODUTO, 00000 AS QTDE, '' AS PACK, 0000 AS Q1, 0000 AS Q2, 0000 AS Q3, 0000 AS Q4, 0000 AS Q5, 0000 AS Q6, 0000 AS Q7, 0000 AS Q8, 0000 AS Q9, 0000 AS Q10, 0000 AS Q11, 0000 AS Q12, 0000 AS Q13, 0000 AS Q14, 0000 AS Q15,
 0000 AS Q16, 0000 AS Q17, 0000 AS Q18, 0000 AS Q19, 0000 AS Q20, 0000 AS Q21, 0000 AS Q22, 0000 AS Q23, 0000 AS Q24, 0000 AS Q25, 0000 AS Q26, 0000 AS Q27, 0000 AS Q28, 0000 AS Q29, 0000 AS Q30, 0000 AS Q31, 0000 AS Q32, 0000 AS Q33, 0000 AS Q34,
 0000 AS Q35, 0000 AS Q36, 0000 AS Q37, 0000 AS Q38, 0000 AS Q39, 0000 AS Q40, 0000 AS Q41, 0000 AS Q42, 0000 AS Q43, 0000 AS Q44, 0000 AS Q45, 0000 AS Q46, 0000 AS Q47, 0000 AS Q48, PRODUTO_CORES.COR_PRODUTO, 0 AS INDICA_PACK_COR, 0 AS INATIVO,
     PRODUTO_CORES.DESC_COR_PRODUTO   FROM PRODUTO_CORES    WHERE   PRODUTO_CORES.PRODUTO = ?MEUPRODUTO 

	EndText
	Text to .Cursorv_produtos_00_packs_permitidos.CursorSchema TextMerge NoShow
	PRODUTO C(12), QTDE I, PACK C(1), Q1 I, Q2 I, Q3 I, Q4 I, Q5 I, Q6 I, Q7 I, Q8 I, Q9 I, Q10 I, Q11 I, Q12 I, Q13 I, Q14 I, Q15 I, Q16 I, Q17 I, Q18 I, Q19 I, Q20 I, Q21 I, Q22 I, Q23 I, Q24 I, Q25 I, Q26 I, Q27 I, Q28 I, Q29 I, Q30 I, Q31 I, Q32 I,
 Q33 I, Q34 I, Q35 I, Q36 I, Q37 I, Q38 I, Q39 I, Q40 I, Q41 I, Q42 I, Q43 I, Q44 I, Q45 I, Q46 I, Q47 I, Q48 I, COR_PRODUTO C(10), INDICA_PACK_COR I, INATIVO I,
 DESC_COR_PRODUTO C(40) 

	EndText
	Text to .Cursorv_produtos_00_packs_permitidos.UpdateNameList TextMerge NoShow
	
	EndText
	Text to .Cursorv_produtos_00_packs_permitidos.UpdatableFieldList TextMerge NoShow
	
	EndText
	.Cursorv_produtos_00_packs_permitidos.Tables				=""
	.Cursorv_produtos_00_packs_permitidos.KeyFieldList		=""
	Text to .Cursorv_produtos_00_packs_permitidos.QueryList TextMerge NoShow
	PRODUTO PRODUTO_CORES.PRODUTO, QTDE 00000, PACK '', Q1 0000, Q2 0000, Q3 0000, Q4 0000, Q5 0000, Q6 0000, 
Q7 0000, Q8 0000, Q9 0000, Q10 0000, Q11 0000, Q12 0000, Q13 0000, Q14 0000, Q15 0000, Q16 0000, 
Q17 0000, Q18 0000, Q19 0000, Q20 0000, Q21 0000, Q22 0000, Q23 0000, Q24 0000, Q25 0000, Q26 0000, 
Q27 0000, Q28 0000, Q29 0000, Q30 0000, Q31 0000, Q32 0000, Q33 0000, Q34 0000, Q35 0000, Q36 0000, 
Q37 0000, Q38 0000, Q39 0000, Q40 0000, Q41 0000, Q42 0000, Q43 0000, Q44 0000, Q45 0000, Q46 0000, 
Q47 0000, Q48 0000, COR_PRODUTO PRODUTO_CORES.COR_PRODUTO, INDICA_PACK_COR 0, INATIVO 0,
 DESC_COR_PRODUTO PRODUTO_CORES.DESC_COR_PRODUTO 

	EndText
	Text to .Cursorv_produtos_00_packs_permitidos.CaptionList TextMerge NoShow
	PRODUTO Produto, QTDE Qtde, PACK Pack, Q1 Q1, Q2 Q2, Q3 Q3, Q4 Q4, Q5 Q5, Q6 Q6, Q7 Q7, Q8 Q8, Q9 Q9, Q10 Q10, Q11 Q11, Q12 Q12, Q13 Q13, Q14 Q14, Q15 Q15, Q16 Q16, Q17 Q17, Q18 Q18, Q19 Q19, Q20 Q20, Q21 Q21, Q22 Q22, Q23 Q23, Q24 Q24, Q25 Q25,
 Q26 Q26, Q27 Q27, Q28 Q28, Q29 Q29, Q30 Q30, Q31 Q31, Q32 Q32, Q33 Q33, Q34 Q34, Q35 Q35, Q36 Q36, Q37 Q37, Q38 Q38, Q39 Q39, Q40 Q40, Q41 Q41, Q42 Q42, Q43 Q43, Q44 Q44, Q45 Q45, Q46 Q46, Q47 Q47, Q48 Q48, COR_PRODUTO Cor Produto,
 INDICA_PACK_COR Indica Pack Cor, INATIVO Inativo,
 DESC_COR_PRODUTO Desc Cor Produto 

	EndText
	Text to .Cursorv_produtos_00_packs_permitidos.DefaultsValuesList TextMerge NoShow
	
	EndText
	.Cursorv_produtos_00_packs_permitidos.FTableList		=""
	.Cursorv_produtos_00_packs_permitidos.Alias				="v_produtos_00_packs_permitidos"
	.Cursorv_produtos_00_packs_permitidos.ParentCursor		=""
	.Cursorv_produtos_00_packs_permitidos.BufferModeOverride	=5
	.Cursorv_produtos_00_packs_permitidos.NoDataOnLoad		=.T.
	.Cursorv_produtos_00_packs_permitidos.IsUpdateCursor		=.F.
	.Cursorv_produtos_00_packs_permitidos.IsMaster		=.F.
	.Cursorv_produtos_00_packs_permitidos.UpdateType			=1
	.Cursorv_produtos_00_packs_permitidos.WhereType			=3
	.Cursorv_produtos_00_packs_permitidos.FetchMemo			=.T.
	.Cursorv_produtos_00_packs_permitidos.SendUpdates		=.F.
	.Cursorv_produtos_00_packs_permitidos.UseMemoSize		=255
	.Cursorv_produtos_00_packs_permitidos.FetchSize			=-1
	.Cursorv_produtos_00_packs_permitidos.MaxRecords			=-1
	.Cursorv_produtos_00_packs_permitidos.Prepared			=.F.
	.Cursorv_produtos_00_packs_permitidos.CompareMemo		=.F.
	.Cursorv_produtos_00_packs_permitidos.BatchUpdateCount	=1
	.Cursorv_produtos_00_packs_permitidos.OpenCursor() 
  EndIf 
EndWith 

ENDFUNC && FUNCTION load_v_produtos_00_packs_permitidos

FUNCTION load_v_produtos_00_packs_permitidos_total
PARAMETERS oThisformset

With oThisformset.dataenvironment 
  if Type(".Cursorv_produtos_00_packs_permitidos_total")="U" 
      AddNewObject(oThisformset.dataenvironment, "Cursorv_produtos_00_packs_permitidos_total","ccursoradapter") 
	.Cursorv_produtos_00_packs_permitidos_total.DataSourceType			="ADO"
	Text to .Cursorv_produtos_00_packs_permitidos_total.SelectCmd TextMerge NoShow
	SELECT PRODUTOS.PRODUTO, 'PACK TOTAL' AS TIPO,  0 AS FUNCAO, SUM(0000) AS QTDE, SUM(0000) AS Q1, SUM(0000) AS Q2, SUM(0000) AS Q3, SUM(0000) AS Q4, SUM(0000) AS Q5, SUM(0000) AS Q6, SUM(0000) AS Q7, SUM(0000) AS Q8, SUM(0000) AS Q9, SUM(0000) AS Q10,
 SUM(0000) AS Q11, SUM(0000) AS Q12, SUM(0000) AS Q13, SUM(0000) AS Q14, SUM(0000) AS Q15, SUM(0000) AS Q16, SUM(0000) AS Q17, SUM(0000) AS Q18, SUM(0000) AS Q19, SUM(0000) AS Q20, SUM(0000) AS Q21, SUM(0000) AS Q22, SUM(0000) AS Q23,
 SUM(0000) AS Q24, SUM(0000) AS Q25, SUM(0000) AS Q26, SUM(0000) AS Q27, SUM(0000) AS Q28, SUM(0000) AS Q29, SUM(0000) AS Q30, SUM(0000) AS Q31, SUM(0000) AS Q32, SUM(0000) AS Q33, SUM(0000) AS Q34, SUM(0000) AS Q35, SUM(0000) AS Q36,
 SUM(0000) AS Q37, SUM(0000) AS Q38, SUM(0000) AS Q39, SUM(0000) AS Q40, SUM(0000) AS Q41, SUM(0000) AS Q42, SUM(0000) AS Q43, SUM(0000) AS Q44, SUM(0000) AS Q45, SUM(0000) AS Q46, SUM(0000) AS Q47,
 SUM(0000) AS Q48 FROM PRODUTOS WHERE   PRODUTOS.PRODUTO = ?MEUPRODUTO  GROUP BY PRODUTOS.PRODUTO 

	EndText
	Text to .Cursorv_produtos_00_packs_permitidos_total.CursorSchema TextMerge NoShow
	PRODUTO C(12), TIPO C(10), FUNCAO I, QTDE I, Q1 I, Q2 I, Q3 I, Q4 I, Q5 I, Q6 I, Q7 I, Q8 I, Q9 I, Q10 I, Q11 I, Q12 I, Q13 I, Q14 I, Q15 I, Q16 I, Q17 I, Q18 I, Q19 I, Q20 I, Q21 I, Q22 I, Q23 I, Q24 I, Q25 I, Q26 I, Q27 I, Q28 I, Q29 I, Q30 I,
 Q31 I, Q32 I, Q33 I, Q34 I, Q35 I, Q36 I, Q37 I, Q38 I, Q39 I, Q40 I, Q41 I, Q42 I, Q43 I, Q44 I, Q45 I, Q46 I, Q47 I,
 Q48 I 

	EndText
	Text to .Cursorv_produtos_00_packs_permitidos_total.UpdateNameList TextMerge NoShow
	
	EndText
	Text to .Cursorv_produtos_00_packs_permitidos_total.UpdatableFieldList TextMerge NoShow
	
	EndText
	.Cursorv_produtos_00_packs_permitidos_total.Tables				=""
	.Cursorv_produtos_00_packs_permitidos_total.KeyFieldList		=""
	Text to .Cursorv_produtos_00_packs_permitidos_total.QueryList TextMerge NoShow
	PRODUTO PRODUTOS.PRODUTO, TIPO 'PACK TOTAL',
 FUNCAO 0 

	EndText
	Text to .Cursorv_produtos_00_packs_permitidos_total.CaptionList TextMerge NoShow
	PRODUTO Produto, TIPO Tipo, FUNCAO Funcao, QTDE Qtde, Q1 Q1, Q2 Q2, Q3 Q3, Q4 Q4, Q5 Q5, Q6 Q6, Q7 Q7, Q8 Q8, Q9 Q9, Q10 Q10, Q11 Q11, Q12 Q12, Q13 Q13, Q14 Q14, Q15 Q15, Q16 Q16, Q17 Q17, Q18 Q18, Q19 Q19, Q20 Q20, Q21 Q21, Q22 Q22, Q23 Q23,
 Q24 Q24, Q25 Q25, Q26 Q26, Q27 Q27, Q28 Q28, Q29 Q29, Q30 Q30, Q31 Q31, Q32 Q32, Q33 Q33, Q34 Q34, Q35 Q35, Q36 Q36, Q37 Q37, Q38 Q38, Q39 Q39, Q40 Q40, Q41 Q41, Q42 Q42, Q43 Q43, Q44 Q44, Q45 Q45, Q46 Q46, Q47 Q47,
 Q48 Q48 

	EndText
	Text to .Cursorv_produtos_00_packs_permitidos_total.DefaultsValuesList TextMerge NoShow
	
	EndText
	.Cursorv_produtos_00_packs_permitidos_total.FTableList		=""
	.Cursorv_produtos_00_packs_permitidos_total.Alias				="v_produtos_00_packs_permitidos_total"
	.Cursorv_produtos_00_packs_permitidos_total.ParentCursor		=""
	.Cursorv_produtos_00_packs_permitidos_total.BufferModeOverride	=5
	.Cursorv_produtos_00_packs_permitidos_total.NoDataOnLoad		=.T.
	.Cursorv_produtos_00_packs_permitidos_total.IsUpdateCursor		=.F.
	.Cursorv_produtos_00_packs_permitidos_total.IsMaster		=.F.
	.Cursorv_produtos_00_packs_permitidos_total.UpdateType			=1
	.Cursorv_produtos_00_packs_permitidos_total.WhereType			=3
	.Cursorv_produtos_00_packs_permitidos_total.FetchMemo			=.T.
	.Cursorv_produtos_00_packs_permitidos_total.SendUpdates		=.F.
	.Cursorv_produtos_00_packs_permitidos_total.UseMemoSize		=255
	.Cursorv_produtos_00_packs_permitidos_total.FetchSize			=-1
	.Cursorv_produtos_00_packs_permitidos_total.MaxRecords			=-1
	.Cursorv_produtos_00_packs_permitidos_total.Prepared			=.F.
	.Cursorv_produtos_00_packs_permitidos_total.CompareMemo		=.F.
	.Cursorv_produtos_00_packs_permitidos_total.BatchUpdateCount	=1
	.Cursorv_produtos_00_packs_permitidos_total.OpenCursor() 
  EndIf 
EndWith 
ENDFUNC && FUNCTION load_v_produtos_00_packs_permitidos_total

FUNCTION load_produtos_pack_distrib
PARAMETERS oThisformset

With oThisformset.dataenvironment 
  if Type(".Cursorv_produtos_pack_distrib")="U" 
      AddNewObject(oThisformset.dataenvironment, "Cursorv_produtos_pack_distrib","ccursoradapter") 
	.Cursorv_produtos_pack_distrib.DataSourceType			="ADO"
	Text to .Cursorv_produtos_pack_distrib.SelectCmd TextMerge NoShow
	SELECT PRODUTOS_PACKS_PERMITIDOS.PRODUTO, 0000 AS QTDE,  SPACE(1) AS PACK,  00000 AS  Q1,    00000 AS  Q2,    00000 AS  Q3,    00000 AS  Q4,    00000 AS  Q5,    00000 AS  Q6,    00000 AS  Q7,    00000 AS  Q8,    00000 AS  Q9,    00000 AS  Q10,
    00000 AS  Q11,    00000 AS  Q12,    00000 AS  Q13,    00000 AS  Q14,    00000 AS  Q15,    00000 AS  Q16,    00000 AS  Q17,    00000 AS  Q18,    00000 AS  Q19,    00000 AS  Q20,    00000 AS  Q21,    00000 AS  Q22,    00000 AS  Q23,
    00000 AS  Q24,    00000 AS  Q25,    00000 AS  Q26,    00000 AS  Q27,    00000 AS  Q28,    00000 AS  Q29,    00000 AS  Q30,    00000 AS  Q31,    00000 AS  Q32,    00000 AS  Q33,    00000 AS  Q34,    00000 AS  Q35,    00000 AS  Q36,
    00000 AS  Q37,    00000 AS  Q38,    00000 AS  Q39,    00000 AS  Q40,    00000 AS  Q41,    00000 AS  Q42,    00000 AS  Q43,    00000 AS  Q44,    00000 AS  Q45,    00000 AS  Q46,    00000 AS  Q47,    00000 AS  Q48,
    PRODUTOS_PACKS_PERMITIDOS.COR_PRODUTO, PRODUTOS_PACKS_PERMITIDOS.INDICA_PACK_COR, 1 AS INATIVO,
     PRODUTO_CORES.DESC_COR_PRODUTO   FROM PRODUTOS_PACKS_PERMITIDOS   LEFT JOIN PRODUTO_CORES ON PRODUTOS_PACKS_PERMITIDOS.PRODUTO = PRODUTO_CORES.PRODUTO   AND PRODUTOS_PACKS_PERMITIDOS.COR_PRODUTO = PRODUTO_CORES.COR_PRODUTO   WHERE   1=2 

	EndText
	Text to .Cursorv_produtos_pack_distrib.CursorSchema TextMerge NoShow
	PRODUTO C(12), QTDE I, PACK C(1), Q1 I, Q2 I, Q3 I, Q4 I, Q5 I, Q6 I, Q7 I, Q8 I, Q9 I, Q10 I, Q11 I, Q12 I, Q13 I, Q14 I, Q15 I, Q16 I, Q17 I, Q18 I, Q19 I, Q20 I, Q21 I, Q22 I, Q23 I, Q24 I, Q25 I, Q26 I, Q27 I, Q28 I, Q29 I, Q30 I, Q31 I, Q32 I,
 Q33 I, Q34 I, Q35 I, Q36 I, Q37 I, Q38 I, Q39 I, Q40 I, Q41 I, Q42 I, Q43 I, Q44 I, Q45 I, Q46 I, Q47 I, Q48 I, COR_PRODUTO C(10), INDICA_PACK_COR L, INATIVO I,
 DESC_COR_PRODUTO C(40) 

	EndText
	Text to .Cursorv_produtos_pack_distrib.UpdateNameList TextMerge NoShow
	
	EndText
	Text to .Cursorv_produtos_pack_distrib.UpdatableFieldList TextMerge NoShow
	
	EndText
	.Cursorv_produtos_pack_distrib.Tables				=""
	.Cursorv_produtos_pack_distrib.KeyFieldList		=""
	Text to .Cursorv_produtos_pack_distrib.QueryList TextMerge NoShow
	PRODUTO PRODUTOS_PACKS_PERMITIDOS.PRODUTO, QTDE 0000, Q1 00000, Q2 00000, Q3 00000, Q4 00000, Q5 00000, Q6 00000, 
Q7 00000, Q8 00000, Q9 00000, Q10 00000, Q11 00000, Q12 00000, Q13 00000, Q14 00000, Q15 00000, Q16 00000, 
Q17 00000, Q18 00000, Q19 00000, Q20 00000, Q21 00000, Q22 00000, Q23 00000, Q24 00000, Q25 00000, Q26 00000, 
Q27 00000, Q28 00000, Q29 00000, Q30 00000, Q31 00000, Q32 00000, Q33 00000, Q34 00000, Q35 00000, Q36 00000, 
Q37 00000, Q38 00000, Q39 00000, Q40 00000, Q41 00000, Q42 00000, Q43 00000, Q44 00000, Q45 00000, Q46 00000, 
Q47 00000, Q48 00000, COR_PRODUTO PRODUTOS_PACKS_PERMITIDOS.COR_PRODUTO, INDICA_PACK_COR PRODUTOS_PACKS_PERMITIDOS.INDICA_PACK_COR, INATIVO 1,
 DESC_COR_PRODUTO PRODUTO_CORES.DESC_COR_PRODUTO 

	EndText
	Text to .Cursorv_produtos_pack_distrib.CaptionList TextMerge NoShow
	PRODUTO Produto, QTDE Qtde, PACK Pack, Q1 Q1, Q2 Q2, Q3 Q3, Q4 Q4, Q5 Q5, Q6 Q6, Q7 Q7, Q8 Q8, Q9 Q9, Q10 Q10, Q11 Q11, Q12 Q12, Q13 Q13, Q14 Q14, Q15 Q15, Q16 Q16, Q17 Q17, Q18 Q18, Q19 Q19, Q20 Q20, Q21 Q21, Q22 Q22, Q23 Q23, Q24 Q24, Q25 Q25,
 Q26 Q26, Q27 Q27, Q28 Q28, Q29 Q29, Q30 Q30, Q31 Q31, Q32 Q32, Q33 Q33, Q34 Q34, Q35 Q35, Q36 Q36, Q37 Q37, Q38 Q38, Q39 Q39, Q40 Q40, Q41 Q41, Q42 Q42, Q43 Q43, Q44 Q44, Q45 Q45, Q46 Q46, Q47 Q47, Q48 Q48, COR_PRODUTO Cor Produto,
 INDICA_PACK_COR Indica Pack Cor, INATIVO Inativo,
 DESC_COR_PRODUTO Desc Cor Produto 

	EndText
	Text to .Cursorv_produtos_pack_distrib.DefaultsValuesList TextMerge NoShow
	
	EndText
	.Cursorv_produtos_pack_distrib.FTableList		=""
	.Cursorv_produtos_pack_distrib.Alias				="v_produtos_pack_distrib"
	.Cursorv_produtos_pack_distrib.ParentCursor		=""
	.Cursorv_produtos_pack_distrib.BufferModeOverride	=5
	.Cursorv_produtos_pack_distrib.NoDataOnLoad		=.T.
	.Cursorv_produtos_pack_distrib.IsUpdateCursor		=.F.
	.Cursorv_produtos_pack_distrib.IsMaster		=.F.
	.Cursorv_produtos_pack_distrib.UpdateType			=1
	.Cursorv_produtos_pack_distrib.WhereType			=3
	.Cursorv_produtos_pack_distrib.FetchMemo			=.T.
	.Cursorv_produtos_pack_distrib.SendUpdates		=.F.
	.Cursorv_produtos_pack_distrib.UseMemoSize		=255
	.Cursorv_produtos_pack_distrib.FetchSize			=-1
	.Cursorv_produtos_pack_distrib.MaxRecords			=-1
	.Cursorv_produtos_pack_distrib.Prepared			=.F.
	.Cursorv_produtos_pack_distrib.CompareMemo		=.F.
	.Cursorv_produtos_pack_distrib.BatchUpdateCount	=1
	.Cursorv_produtos_pack_distrib.OpenCursor() 
  EndIf 
EndWith 
ENDFUNC && FUNCTION load_produtos_pack_distrib

FUNCTION load_cursor_caedu_compras_entrega_log
PARAMETERS oThisformset

With oThisformset.dataenvironment 
  if Type(".CursorV_CAEDU_LOG_ENTRADA")="U" 
      AddNewObject(oThisformset.dataenvironment, "CursorV_CAEDU_LOG_ENTRADA","ccursoradapter") 
	.CursorV_CAEDU_LOG_ENTRADA.DataSourceType			="ADO"
	Text to .CursorV_CAEDU_LOG_ENTRADA.SelectCmd TextMerge NoShow
	SELECT PEDIDO, DATA_ALTERACAO_ENTREGA, DATA_ENTREGA, DATA_ENTREGA_NOVA, MOTIVO, USUARIO 
	FROM DBO.CAEDU_COMPRAS_ENTREGA_LOG WHERE CAEDU_COMPRAS_ENTREGA_LOG.PEDIDO = ?V_COMPRAS_01.PEDIDO
	EndText
	Text to .CursorV_CAEDU_LOG_ENTRADA.CursorSchema TextMerge NoShow
	PEDIDO C(8), DATA_ALTERACAO_ENTREGA D, DATA_ENTREGA D, DATA_ENTREGA_NOVA D, MOTIVO C(200), USUARIO C(25)
	EndText
	Text to .CursorV_CAEDU_LOG_ENTRADA.UpdateNameList TextMerge NoShow
	
	EndText
	Text to .CursorV_CAEDU_LOG_ENTRADA.UpdatableFieldList TextMerge NoShow
	
	EndText
	.CursorV_CAEDU_LOG_ENTRADA.Tables				=""
	.CursorV_CAEDU_LOG_ENTRADA.KeyFieldList		=""

	Text to .CursorV_CAEDU_LOG_ENTRADA.QueryList TextMerge NoShow
	 PEDIDO CAEDU_COMPRAS_ENTREGA_LOG.PEDIDO ,DATA_ALTERACAO_ENTREGA CAEDU_COMPRAS_ENTREGA_LOG.DATA_ALTERACAO_ENTREGA
	,DATA_ENTREGA CAEDU_COMPRAS_ENTREGA_LOG.DATA_ENTREGA ,DATA_ENTREGA_NOVA CAEDU_COMPRAS_ENTREGA_LOG.DATA_ENTREGA_NOVA
	,MOTIVO CAEDU_COMPRAS_ENTREGA_LOG.MOTIVO ,USUARIO CAEDU_COMPRAS_ENTREGA_LOG.USUARIO 
	EndText

	Text to .CursorV_CAEDU_LOG_ENTRADA.CaptionList TextMerge NoShow
	 PEDIDO PEDIDO ,DATA_ALTERACAO_ENTREGA DATA ALTERACAO ENTREGA ,DATA_ENTREGA DATA ENTREGA
	 ,DATA_ENTREGA_NOVA DATA ENTREGA NOVA ,MOTIVO MOTIVO ,USUARIO USUARIO
	EndText
	Text to .CursorV_CAEDU_LOG_ENTRADA.DefaultsValuesList TextMerge NoShow
	
	EndText
	.CursorV_CAEDU_LOG_ENTRADA.FTableList		=""
	.CursorV_CAEDU_LOG_ENTRADA.Alias		="V_CAEDU_LOG_ENTRADA"
	.CursorV_CAEDU_LOG_ENTRADA.ParentCursor		="V_COMPRAS_01"
	.CursorV_CAEDU_LOG_ENTRADA.BufferModeOverride	=5
	.CursorV_CAEDU_LOG_ENTRADA.NoDataOnLoad		=.T.
	.CursorV_CAEDU_LOG_ENTRADA.IsUpdateCursor	=.F.
	.CursorV_CAEDU_LOG_ENTRADA.IsMaster		=.F.
	.CursorV_CAEDU_LOG_ENTRADA.UpdateType		=1
	.CursorV_CAEDU_LOG_ENTRADA.WhereType		=3
	.CursorV_CAEDU_LOG_ENTRADA.FetchMemo		=.T.
	.CursorV_CAEDU_LOG_ENTRADA.SendUpdates		=.F.
	.CursorV_CAEDU_LOG_ENTRADA.UseMemoSize		=255
	.CursorV_CAEDU_LOG_ENTRADA.FetchSize		=-1
	.CursorV_CAEDU_LOG_ENTRADA.MaxRecords		=-1
	.CursorV_CAEDU_LOG_ENTRADA.Prepared		=.F.
	.CursorV_CAEDU_LOG_ENTRADA.CompareMemo		=.F.
	.CursorV_CAEDU_LOG_ENTRADA.BatchUpdateCount	=1
	.CursorV_CAEDU_LOG_ENTRADA.OpenCursor() 
  EndIf 
EndWith 

ENDFUNC && FUNCTION load_cursor_caedu_compras_entrega_log

******* F  I  N  A  L						*******
******* CURSOR ADAPTER UTILIZADOS NA TELA DE COMPRAS		*******
*******                                                         *******
