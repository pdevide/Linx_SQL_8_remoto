***/
* OBJETO DE ENTRADA DA TELA CONSULTA DE ESTOQUE POR COR E FILIAL
* 28-04-2021
*
*1-Valida os campos 'ENDERECO/CEP/CIDADE/BAIRRO/PAIS/DDD1/TELEFONE1/CONTA_CONTABIL/' no cadastramento do fornecedor.
*Evita que o cadastro de fornecedor fique incompleto.
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
*   USR_LOSTFOCUS
*	USR_CLICK
define class obj_entrada as custom
	*- Nome do metodo/função que os objetos linx vão chamar.
	procedure metodo_usuario

		lparam xmetodo, xobjeto ,xnome_obj


		do case
			case UPPER(xmetodo) == 'USR_INIT'

				*!*				  ***thisformset.lx_form1.addobject('bt_copia', 'bt_estfilial')
				*!*	   			  thisformset.lx_FORM1.lx_pageframe1.page11.addobject('bt_prod', 'bt_produtos')
				*!*	  			  thisformset.lx_FORM1.lx_pageframe1.page11.addobject('bt_copia', 'bt_estfilial')
				*!*
				*!*	   			WITH thisformset
				*!*					.lx_FORM1.lx_pageframe1.page1.AddObject("bt_excel1","bt_excel")
				*!*					.lx_FORM1.lx_pageframe1.page1.bt_excel1.visible=.t.
				*!*				ENDWITH

				thisformset.lx_FORM1.lx_pageframe1.page1.AddObject("btnArqFinal","btnArqFinal")
				thisformset.lx_FORM1.lx_pageframe1.page1.btnArqFinal.visible=.t.
			case UPPER(xmetodo) == 'USR_SEARCH_AFTER'
				
				lcClausulaWhere = ALLTRIM(UPPER(thisformset.p_comando_where))
				IF ("FILIAL" $ lcClausulaWhere) AND !(".PRODUTO" $ lcClausulaWhere) AND ;
					EMPTY(thisformset.P_CLAUSULA_WHERE_ESPECIAL)
*!*						MESSAGEBOX(TRANSFORM(thisformset.px_total_qtde_estoque)+CHR(13)+;
*!*						TRANSFORM(thisformset.px_total_qtde_estoque_disponivel)+CHR(13)+;
*!*						TRANSFORM(thisformset.px_total_qtde_transito),64,"aviso")
					
					f_select("select GETDATE() AS DATA_HORA,FILIAL,EM_INVENTARIO,DT_ULTIMO_INVENTARIO,RESPONSAVEL_ULTIMO_INVENTARIO "+;
								"FROM FILIAIS WHERE FILIAL = ?v_estoque_produtos_00.filial","tmpData")
					tcDia = DOW(tmpData.data_hora)
					tcHora = HOUR(tmpData.data_hora)
					tcMsg = ""
					
					IF BETWEEN(tcHora,0,6) OR (tcHora >= CAST(LEFT(ALLTRIM(thisformset.pp_PALMA_HORA_INVENTARIO),2) as int))
						IF tmpData.EM_INVENTARIO=.F.
							tcMsg = tcMsg + "Você está entrando em inventário na filial "+ALLTRIM(tmpData.filial)+"??"
						ENDIF
					ENDIF

					IF !EMPTY(tcMsg)
				
						nOptMsg = MESSAGEBOX(tcMsg,292,"Aviso")
						IF nOptMsg = 6 && sim
						
							TEXT TO cmdsql NOSHOW TEXTMERGE PRETEXT 7
								UPDATE filiais SET 	EM_INVENTARIO=1,
													DT_ULTIMO_INVENTARIO='<<DTOS(DATE())>>',
													RESPONSAVEL_ULTIMO_INVENTARIO = '<<ALLTRIM(wusuario)>>'
								where filial = ?v_estoque_produtos_00.filial
							ENDTEXT
							f_execute(cmdsql)
							
						ENDIF
						
					ENDIF
					
					** INSERE O REGISTRO NO LOG COM OS VALORES DA ULTIMA PESQUISA
					TEXT TO CMDSQL NOSHOW TEXTMERGE PRETEXT 7
						EXEC DBO.CGP_PRC_LOG_CONSULTA_ESTOQUE_FILIAL
							@FILIAL ='<<ALLTRIM(v_estoque_produtos_00.filial)>>',
							@TOTAL_QTDE_ESTOQUE =<<NVL(thisformset.px_total_qtde_estoque,0)>>,
							@TOTAL_QTDE_ESTOQUE_DISPONIVEL =<<NVL(thisformset.px_total_qtde_estoque_disponivel,0)>>,
							@TOTAL_QTDE_TRANSITO =<<NVL(thisformset.px_total_qtde_transito,0)>>,
							@USUARIO = '<<ALLTRIM(WUSUARIO)>>'
					ENDTEXT
					F_EXECUTE(CMDSQL)

					
					** fazer o log do AF na rotina do AF aqui abaixo
					
					
					
				ENDIF
				
		ENDCASE

	ENDPROC

enddefine


DEFINE CLASS btnArqFinal as COMMANDBUTTON

	caption = 'Gerar Arq Final'
	*autosize = .T.
	WORDWRAP = .t.
	caption = "AF"
	WIDTH = 25
	top = 120
	left = 4
	HEIGHT =  24
	enabled = .T.
	visible  = .T.

	****backcolor =  RGB(64,128,128)
	PROCEDURE refresh
		** Inclusão/Alteração/Exclusão/Tela (L)impa/(P)esquisa Feita!
		this.enabled = !INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L")
	ENDPROC

	PROCEDURE click

		TEXT TO CMDSQL NOSHOW TEXTMERGE PRETEXT 7
			 SELECT c.griffe, c.linha, c.GRUPO_PRODUTO, c.SUBGRUPO_PRODUTO, C.PRODUTO, b.COR_PRODUTO, B.CODIGO_BARRA, c.DESC_PRODUTO,
			                e.desc_cor_produto, RIGHT('00'+convert(varchar,b.TAMANHO),2) as TAMANHO, unpvt.qtde, h.PRECO1
			         FROM (SELECT produto, cor_produto,  ES1,ES2,ES3,ES4,ES5,ES6,ES7,ES8,ES9,ES10,ES11,ES12,ES13,ES14,ES15,ES16,ES17,ES18,ES19,ES20
			         FROM [CAEDU].[dbo].estoque_produtos
			         where FILIAL =?v_estoque_produtos_00.filial
			                           ) p
			         UNPIVOT
			(qtde FOR tamanho IN
			(ES1,ES2,ES3,ES4,ES5,ES6,ES7,ES8,ES9,ES10,ES11,ES12,ES13,ES14,ES15,ES16,ES17,ES18,ES19,ES20) )AS unpvt
			LEFT JOIN (
			SELECT  PRODUTO, COR_PRODUTO, TAMANHO, MIN(CODIGO_BARRA) AS CODIGO_BARRA
			FROM [CAEDU].[dbo].PRODUTOS_BARRA
			GROUP BY PRODUTO, COR_PRODUTO, TAMANHO
			) B ON B.PRODUTO = unpvt.PRODUTO AND B.COR_PRODUTO = unpvt.COR_PRODUTO AND B.TAMANHO = substring(unpvt.tamanho,3,2)
			LEFT join [CAEDU].[dbo].PRODUTOS as c on b.PRODUTO=c.PRODUTO
			LEFT join [CAEDU].[dbo].PRODUTO_CORES as e on c.PRODUTO=e.PRODUTO and unpvt.COR_PRODUTO=e.COR_PRODUTO
			LEFT join [CAEDU].[dbo].produtos_precos as H on c.PRODUTO=h.PRODUTO where h.CODIGO_TAB_PRECO ='00';
		ENDTEXT
		f_wait("Aguarde executando consulta...")
		F_SELECT(CMDSQL,"VARQFINAL")
		f_wait()

		SELECT SUM(NVL(qtde,0)) AS SOMAQTDE FROM VARQFINAL INTO CURSOR VCONT_ARQFINAL
		
		** resumo para gravar o Log no SQL
		TEXT TO CSQL1 NOSHOW TEXTMERGE PRETEXT 7
			SELECT count(produto) as qtd_produtos, sum(qtab2.qtde) as estoque, sum(qtd_sku) as total_linhas ;
			FROM ( ;
			SELECT PRODUTO, SUM(QTDE) AS QTDE, COUNT(PRODUTO) AS QTD_SKU ;
			FROM VARQFINAL ;
			GROUP BY PRODUTO) AS QTAB2 ;
			INTO CURSOR VCONT_RESUMO
		ENDTEXT
		=EXECSCRIPT(CSQL1)
		
		lcMsgQtde = "Saldo de quantidades do arquivo = "+ALLTRIM(TRANSFORM(VCONT_ARQFINAL.SOMAQTDE,"9999999"))
		
		MESSAGEBOX(lcMsgQtde,64,"Aviso")
		
		** INSERE O REGISTRO NO LOG COM OS VALORES DA ULTIMA PESQUISA DO BOTAO AF
		TEXT TO CMDSQL NOSHOW TEXTMERGE PRETEXT 7
			EXEC DBO.CGP_PRC_LOG_ARQUIVO_AF_INVENTARIO
				@FILIAL ='<<ALLTRIM(v_estoque_produtos_00.filial)>>',
				@QTD_PRODUTOS =<<NVL(VCONT_RESUMO.QTD_PRODUTOS,0)>>,
				@ESTOQUE =<<NVL(VCONT_RESUMO.ESTOQUE,0)>>,
				@TOTAL_LINHAS =<<NVL(VCONT_RESUMO.TOTAL_LINHAS,0)>>,
				@USUARIO = '<<ALLTRIM(WUSUARIO)>>'
		ENDTEXT
		F_EXECUTE(CMDSQL)
							
		pSeparadorM = SET("Separator")
		pSeparadorD = SET("Point")
		
		SELECT VARQFINAL
		
		lcNomeFilial = STRTRAN(ALLTRIM(v_estoque_produtos_00.filial)," ","_")
		arqfinal = "arq_final_"+lcNomeFilial+SYS(2015)+".txt"
		arqfinal = PUTFILE("Salvar arquivo",arqfinal,"txt")
		IF EMPTY(arqfinal)
			MESSAGEBOX("Procedimento Cancelado pelo usuário!",64,"Aviso")
			RETURN 
		ENDIF
		
		SET POINT TO "."
		SET SEPARATOR TO ","
		
		copy to  (arqfinal) ;
		FIELDS GRIFFE,LINHA,GRUPO_PRODUTO,PRODUTO,COR_PRODUTO,CODIGO_BARRA,;
		DESC_PRODUTO,DESC_COR_PRODUTO,QTDE,PRECO1 ;
		type delimited WITH "" WITH CHARACTER "|"
		
		SET POINT TO &pSeparadorD.
		SET SEPARATOR TO &pSeparadorM.

	ENDPROC
ENDDEFINE


