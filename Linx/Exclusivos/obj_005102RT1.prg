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
******************** Calcula o Desconto  *****************

*- Definindo a classe do objeto de entrada que sera criado na Form.
Define Class obj_entrada As Custom
	*- Nome do metodo/função que os objetos linx vão chamar.
	Procedure metodo_usuario
		Lparam xmetodo, xobjeto, xnome_obj

		Do Case
			CASE UPPER(xmetodo) == 'USR_REFRESH'
				IF  thisformset.p_tool_status = "P" && pesquisa feita
			*!*			o_toolbar.botao_exclui.Enabled= .t.
					
					lcAlias = ALIAS()
					
					lcSQL = "SELECT ERP_EBS_AP_DATA_ENVIO, ERP_EBS_GL_DATA_ENVIO, ERP_EBS_SYNCHRO_DATA_ENVIO "
					lcSQL = lcSQL + " FROM ENTRADAS WHERE NF_ENTRADA = '"+ALLTRIM(v_entradas_00.NF_ENTRADA)
					lcSQL = lcSQL + "' AND NOME_CLIFOR = '"+ALLTRIM(v_entradas_00.NOME_CLIFOR)
					lcSQL = lcSQL +"' AND SERIE_NF_ENTRADA = '"+ALLTRIM(v_entradas_00.SERIE_NF_ENTRADA)+"'"
					IF USED("vStatusEBS01")
						USE IN vStatusEBS01
					ENDIF
					F_SELECT(lcSQL,"vStatusEBS01")

					IF !ISNULL(vStatusEBS01.ERP_EBS_AP_DATA_ENVIO) ;
						OR !ISNULL(vStatusEBS01.ERP_EBS_GL_DATA_ENVIO) ;
						OR !ISNULL(vStatusEBS01.ERP_EBS_SYNCHRO_DATA_ENVIO) 
						WAIT WINDOW NOWAIT "exclusão desabilitada - nota integrada" 
						o_toolbar.botao_exclui.Enabled= .f.
						o_toolbar.botao_altera.Enabled= .f.
					ENDIF
					
					SELECT (lcAlias)
					
				ENDIF
				
			CASE upper(xmetodo) == 'USR_ALTER_BEFORE'
				lcAlias = ALIAS()
				
				lcSQL = "SELECT ERP_EBS_AP_DATA_ENVIO, ERP_EBS_GL_DATA_ENVIO, ERP_EBS_SYNCHRO_DATA_ENVIO "
				lcSQL = lcSQL + " FROM ENTRADAS WHERE NF_ENTRADA = '"+ALLTRIM(v_entradas_00.NF_ENTRADA)
				lcSQL = lcSQL + "' AND NOME_CLIFOR = '"+ALLTRIM(v_entradas_00.NOME_CLIFOR)
				lcSQL = lcSQL +"' AND SERIE_NF_ENTRADA = '"+ALLTRIM(v_entradas_00.SERIE_NF_ENTRADA)+"'"
				IF USED("vStatusEBS01")
					USE IN vStatusEBS01
				ENDIF
				F_SELECT(lcSQL,"vStatusEBS01")

				IF !ISNULL(vStatusEBS01.ERP_EBS_AP_DATA_ENVIO) ;
					OR !ISNULL(vStatusEBS01.ERP_EBS_GL_DATA_ENVIO) ;
					OR !ISNULL(vStatusEBS01.ERP_EBS_SYNCHRO_DATA_ENVIO) 
					WAIT WINDOW NOWAIT "exclusão desabilitada - nota integrada" 
					MESSAGEBOX('Nota integrada, nao e possivel alterar!', 16, wusuario) 
					RETURN .F.
				ENDIF
				
				SELECT (lcAlias)


			
			case upper(xmetodo) == 'USR_INIT'

				WAIT WINDOW "OBJ" NOWAIT
				strAlias = ALIAS()
				
				*- Mit - Pesquisa do CCF - para selecionar pedidos por CCF
				CREATE CURSOR xCur_CCF (CCF c(25))
				
				***
				*  Configuração novos campos alias: V_ENTRADAS_00_PROD_ENT
				*  Paulo Devide: 24/05/2018
				*
				SELECT V_ENTRADAS_00_PROD_ENT
				oCursor = GETCURSORADAPTER("V_ENTRADAS_00_PROD_ENT")
				oCursor.AddBufferField("ESTOQUE_PROD_ENT.PEDIDO2","C(8)",.T.,"PEDIDO2","ESTOQUE_PROD_ENT.PEDIDO2")
				oCursor.confirmStructureChanges()
				*** Fim configuração alias: V_ENTRADAS_00_PROD_ENT

				***
				*  Configuração novos campos alias: V_ENTRADAS_00_PROD1_ENT
				*  Paulo Devide: 24/05/2018
				*
				SELECT V_ENTRADAS_00_PROD1_ENT
				oCursor = GETCURSORADAPTER("V_ENTRADAS_00_PROD1_ENT")
				oCursor.AddBufferField("ESTOQUE_PROD1_ENT.PEDIDO2","C(8)",.T.,"PEDIDO2","ESTOQUE_PROD1_ENT.PEDIDO2")
				oCursor.confirmStructureChanges()
				*** Fim configuração alias: V_ENTRADAS_00_PROD1_ENT

				***
				*  Configuração novos campos alias: V_COMPRAS_01
				*  Paulo Devide: 24/05/2018
				*
				SELECT V_COMPRAS_01
				oCursor = GETCURSORADAPTER("V_COMPRAS_01")
				oCursor.AddBufferField("COMPRAS.QUANTIDADE_AGENDAMENTO","I",.T.,"QUANTIDADE_AGENDAMENTO","COMPRAS.QUANTIDADE_AGENDAMENTO")
				oCursor.confirmStructureChanges()
				*** Fim configuração alias: V_COMPRAS_01
				SELECT (strAlias)
				thisformset.l_limpa()

				CREATE CURSOR xCalcula_Icms;
					(Valor_Prod Numeric(18,2),;
					Valor_ICMS Numeric(18,2),;
					Aliquota Numeric(18,2),;
					Desconto Numeric(18,2);
					)

				IF thisformset.pp_NF_REMESSA_GPO_AUTOMATICA = .t.

					*** Adiciona botão para emissão de nfe de contigencia da GPO Logistica
					IF "GPO" $ SET( "ClassLib" )
						** Ok, Registry carregado
					ELSE
						SET CLASSLIB TO GPO.vcx ADDITIVE
					ENDIF

					TRY

						thisformset.lx_FORM1.Lx_pageframe1.Page1.Pageframe1.Page1.addobject('btn_nfe_gpo1', 'btn_nfe_gpo')
						WITH thisformset.lx_FORM1.Lx_pageframe1.Page1.Pageframe1.Page1.btn_nfe_gpo1
							.visible=.t.
							.top = 290
							.left = 5
						ENDWITH

					CATCH
						** objeto ja inserido
					ENDTRY

				ELSE

					WAIT WINDOW "Parâmetro NF_REMESSA_GPO_AUTOMATICA está desligado!" TIMEOUT 1

				ENDIF

				thisformset.lx_forM1.lx_pageframe1.page6.AddObject("lblPedido21","lblPedido2")
				thisformset.lx_forM1.lx_pageframe1.page6.AddObject("txtPedido21","txtPedido2")
				thisformset.lx_forM1.lx_pageframe1.page6.lblPedido21.visible = .t.
				thisformset.lx_forM1.lx_pageframe1.page6.txtPedido21.visible = .t.
				
				TRY 
					thisformset.lx_FORM1.lx_pageframe1.page6.removeobject("botao1")
					thisformset.lx_FORM1.lx_pageframe1.page6.addobject("botao1","botao1") && adiciona objeto customizado
					thisformset.lx_FORM1.lx_pageframe1.page6.botao1.visible = .T.				
				CATCH TO oerro
					MESSAGEBOX(oerro.message, 16, "Aviso")

				ENDTRY

				
				**o_005102.lx_form1.lx_pageframe1.page7.lx_pageframe1.page1.lx_pageframe1.page1.lx_grid_filha1.col_TX_PEDIDO.H_TX_PEDIDO.Caption
				WITH thisformset.lx_forM1.lx_pageframe1.page7.lx_pageframe1.page1 &&.lx_pageframe1.page1
					.Lx_pageframe1.Page1.addobject("Lx_label8","Lx_label8")
					.Lx_pageframe1.Page1.Lx_label8.visible=.t.
					.Lx_pageframe1.Page1.addobject("cmb_ccf","cmb_ccf") 
					.Lx_pageframe1.Page1.cmb_ccf.CONTROLSOURCE	 = 'xcur_ccf.ccf'
					.Lx_pageframe1.Page1.cmb_ccf.ROWSOURCE		 = 'xcur_CCF.CCF'
					.Lx_pageframe1.Page1.cmb_ccf.visible = .t.
					WITH .Lx_pageframe1.Page1.Lx_Grid_Filha1
						.anchor = 0
						.Top = 111
						.Height = 190
					ENDWITH 

					WITH .Lx_pageframe1.Page1
						.addobject("lx_label6","lx_label6")
						.lx_label6.visible =.t.
						.addobject("Lx_limite_entrega","Lx_limite_entrega")
						.Lx_limite_entrega.visible =.t.						
						.addobject("lx_label5","lx_label5")
						.lx_label5.visible =.t.						
						.addobject("Lx_Semana_Atraso","Lx_Semana_Atraso")
						.Lx_Semana_Atraso.visible =.t.						
						.addobject("lx_label7","lx_label7")
						.lx_label7.visible =.t.						
						.addobject("Lx_limite_calc","Lx_limite_calc")
						.Lx_limite_calc.visible =.t.						
						.addobject("lx_label2","lx_label2")
						.lx_label2.visible =.t.						
						.addobject("Lx_Desconto_Digitado","Lx_Desconto_Digitado")
						.Lx_Desconto_Digitado.visible =.t.	
						.Lx_Grid_Filha1.Top = 111					
					ENDWITH
					
					
				ENDWITH 
				
			case upper(xmetodo) == 'USR_INCLUDE_AFTER'


				IF USED("xCalcula_Icms")

					SELECT xCalcula_Icms
					ZAP

				Endif

				**** case upper(xmetodo) = 'USR_INCLUDE_AFTER'


				**IF INLIST(ALLTRIM(v_Entradas_00.NATUREZA),'200.01')
				*!*			     	 IF MESSAGEBOX("Entrada referente à 'Compra de Produto Acabado' ?",32+4+256,"Confirma") = 6
				*!*

				*!*							SELECT xCalcula_Icms
				*!*							ZAP
				*!*							APPEND BLANK
				*!*							inppass = rbInputBox3( " ", "Calculo de Desconto do ICMS", "", , , "!", , "*")
				*!*
				*!*
				*!*					 Endif

				**ENDIF


				*!*		 			Case Upper(xmetodo) == 'USR_SAVE_BEFORE'
				*!*
				*!*
				*!*		 			      SELECT v_Entradas_00_Imposto_Total
				*!*		 			      LOCATE FOR 'ICMS'$UPPER(imposto)
				*!*
				*!*		 			      SET STEP ON
				*!*
				*!*		 			      IF FOUND()  and;
				*!*	      	 			      (v_Entradas_00_Imposto_Total.Valor_Imposto_Calc > 0)
				*!*
				*!*		 			            ln_imposto = v_Entradas_00_Imposto_Total.Valor_Imposto_Calc
				*!*		 			            ln_aliquota =  (ln_imposto/THISFORMSET.PX_SUB_TOTAL)*100
				*!*
				*!*					    		ln_Desconto = ROUND(THISFORMSET.PX_SUB_TOTAL*(( 12 -  (ln_imposto/THISFORMSET.PX_SUB_TOTAL)*100) )/100,2)
				*!*
				*!*
				*!*								IF !BETWEEN(v_entradas_00.Desconto, ln_Desconto - 0.10, ln_Desconto + 0.10)
				*!*
				*!*								   MESSAGEBOX("O valor de Desconto [ICMS Calculado] ("+ ALLTRIM(TRANSFORM(ln_Desconto,'9 999 999.99'))+ ") é diferente do desconto informado na tela ("+;
				*!*								   ALLTRIM(TRANSFORM(v_entradas_00.Desconto,'9 999 999.99'))+"). " +CHR(13) +;
				*!*								   "Impossível Salvar os Dados!",16,"Atenção")
				*!*
				*!*								   RETURN .F.
				*!*
				*!*					    		ENDIF
				*!*
				*!*			 			  Endif


			Case Upper(xmetodo) == 'USR_SAVE_AFTER'

				***///////////////////////////// comentado por Paulo Devide --> 18set17
				*!*							  TEXT TO lcsql noshow
				*!*													INSERT INTO Palma_Entradas_Desconto_ICMS_log
				*!*														(id,
				*!*														USUARIO,
				*!*														DATA_ALTERACAO,
				*!*														NOME_CLIFOR,
				*!*														NF_ENTRADA,
				*!*														SERIE_NF_ENTRADA,
				*!*														Valor_Prod,
				*!*														Valor_ICMS,
				*!*														Aliquota,
				*!*														Desconto)
				*!*													VALUES
				*!*															((select MAX(id)+1 from trigger_portal),
				*!*															  ?wusuario,
				*!*															  getdate(),
				*!*
				*!*														  	    ?v_Entradas_00.NOME_CLIFOR,
				*!*															    ?v_Entradas_00.NF_ENTRADA,
				*!*																?v_Entradas_00.SERIE_NF_ENTRADA,
				*!*
				*!*																?xCalcula_Icms.Valor_Prod,
				*!*																?xCalcula_Icms.Valor_ICMS,
				*!*																?xCalcula_Icms.Aliquota,
				*!*																?xCalcula_Icms.Desconto)
				*!*								ENDTEXT

				TEXT TO lcsql noshow
                   INSERT INTO Palma_Entradas_Desconto_ICMS_log
                         (id,
                         USUARIO,
                         DATA_INSERT,
                         DATA_ALTERACAO,
                         NOME_CLIFOR,
                         NF_ENTRADA,
                         SERIE_NF_ENTRADA,
                         Valor_Prod,
                         Valor_ICMS,
                         Aliquota,
                         Desconto)
                   VALUES
                       ((select MAX(id)+1 from trigger_portal),
                         ?wusuario,
                         getdate(),getdate(),
                           ?v_Entradas_00.NOME_CLIFOR,
                           ?v_Entradas_00.NF_ENTRADA,
                             ?v_Entradas_00.SERIE_NF_ENTRADA,
                             ?xCalcula_Icms.Valor_Prod,
                             ?xCalcula_Icms.Valor_ICMS,
                             ?xCalcula_Icms.Aliquota,
                             ?xCalcula_Icms.Desconto)
				ENDTEXT

				F_INSERT(lcsql)

				*** PAULO DEVIDE - ABR/14 == OPERADOR LOGISTICO ==
				IF thisformset.pp_NF_REMESSA_GPO_AUTOMATICA = .t.
					IF ThisFormSet.p_Tool_Status = "I" && operação de inclusão de NOTA de Entrada de PA

						*** Chama rotina para OPERADOR LOGISTICO
						IF INLIST(UPPER(ALLTRIM(v_entradas_00.filial)),"CD ARAQUARI","CD IMPORTACAO","CD REGIS")
							***cria_nf_remessa()
							** Verifica se a classe de objetos esta carregada em memória
							**SET STEP ON

							IF "GPO" $ SET( "ClassLib" )
								** Ok, Registry carregado
							ELSE
								SET CLASSLIB TO GPO.vcx ADDITIVE
							ENDIF

							objGPO = CREATEOBJECT("FUNCOES_GPO")
							objGPO.filial = v_entradas_00.filial
							objGPO.serie_nf_saida = "1"
							objGPO.operador_logistico = "GPO LOGISTICA"
							objGPO.nf_saida = F_SEQUENCIAIS_ESPECIAL("faturamento_sequenciais", "sequencial", "filial = ?v_entradas_00.filial and serie_nf = '1'", .T.)

							objGPO.cria_nf_remessa()

						ENDIF

					ENDIF
				ELSE
					WAIT WINDOW "Parâmetro NF_REMESSA_GPO_AUTOMATICA está desligado!" TIMEOUT 1
				ENDIF

				*** PAULO DEVIDE - ABR/14 == OPERADOR LOGISTICO ==

				***
				* PAULO EDUARDO DEVIDE
				* 28-04-2015
				* COLUNA FIN_EMISSAO_NFE ESTA GRAVANDO ERRADO - TA FORÇANDO VALOR = 1
				*/
				IF ALLTRIM(v_Entradas_00.NATUREZA) = '250.01' && DEVOLUÇÃO
					F_UPDATE("UPDATE ENTRADAS SET FIN_EMISSAO_NFE = 4 WHERE NOME_CLIFOR=?v_Entradas_00.NOME_CLIFOR AND NF_ENTRADA=?v_Entradas_00.NF_ENTRADA AND SERIE_NF_ENTRADA=?v_Entradas_00.SERIE_NF_ENTRADA")
				ENDIF

				*- Andre Maia - 04/05/2015 - Travar custo minimo do produto
			Case Upper(xmetodo) == 'USR_SAVE_BEFORE'
				IF !(ThisFormSet.p_Tool_Status $ "IA")
					lcAlias = ALIAS()
				
					lcSQL = "SELECT ERP_EBS_AP_DATA_ENVIO, ERP_EBS_GL_DATA_ENVIO, ERP_EBS_SYNCHRO_DATA_ENVIO "
					lcSQL = lcSQL + " FROM ENTRADAS WHERE NF_ENTRADA = '"+ALLTRIM(v_entradas_00.NF_ENTRADA)
					lcSQL = lcSQL + "' AND NOME_CLIFOR = '"+ALLTRIM(v_entradas_00.NOME_CLIFOR)
					lcSQL = lcSQL +"' AND SERIE_NF_ENTRADA = '"+ALLTRIM(v_entradas_00.SERIE_NF_ENTRADA)+"'"
					IF USED("vStatusEBS01")
						USE IN vStatusEBS01
					ENDIF
					F_SELECT(lcSQL,"vStatusEBS01")

					IF !ISNULL(vStatusEBS01.ERP_EBS_AP_DATA_ENVIO) ;
						OR !ISNULL(vStatusEBS01.ERP_EBS_GL_DATA_ENVIO) ;
						OR !ISNULL(vStatusEBS01.ERP_EBS_SYNCHRO_DATA_ENVIO) 
						WAIT WINDOW NOWAIT "exclusão desabilitada - nota integrada" 
						MESSAGEBOX('Nota integrada, nao e possivel excluir!', 16, wusuario) 
						RETURN .F.
					ENDIF
					
					SELECT (lcAlias)
				endif			
			
				*!*			 			IF ThisFormSet.p_Tool_Status $ "IA"
				*!*			 				IF V_ENTRADAS_00.natureza = '200.01'
				*!*			 					SET STEP ON
				*!*			 					*Busco o parametro com a tabela
				*!*			 					F_Select("select valor_atual from parametros where parametro = 'MIT_TABELA_CUSTO_ENTRADA'", 'cur_tab')
				*!*								VLC_Tabela = cur_tab.valor_atual
				*!*								USE IN cur_tab
				*!*
				*!*			 					F_Select("select valor_atual from parametros where parametro = 'MIT_PERCENTUAL_CUSTO'", 'cur_perc')
				*!*								VLN_Taxa_Custo = VAL(cur_perc.valor_atual)
				*!*								USE IN cur_perc
				*!*
				*!*			 					VLC_Texto = ''
				*!*			 					SELECT V_ENTRADAS_00_PROD1_ENT
				*!*			 					SCAN
				*!*			 						SELECT V_ENTRADAS_00_IMPOSTO
				*!*			 						LOCATE FOR ALLTRIM(V_ENTRADAS_00_PROD1_ENT.ITEM_IMPRESSAO) == ALLTRIM(V_ENTRADAS_00_IMPOSTO.ITEM_IMPRESSAO) AND V_ENTRADAS_00_IMPOSTO.ID_IMPOSTO = 1
				*!*			 						IF FOUND()
				*!*										SELECT V_ENTRADAS_00_ITENS
				*!*										LOCATE FOR ALLTRIM(V_ENTRADAS_00_PROD1_ENT.ITEM_IMPRESSAO) == ALLTRIM(V_ENTRADAS_00_ITENS.ITEM_IMPRESSAO)
				*!*
				*!*										IF FOUND()
				*!*					 						SELECT 1
				*!*					 						f_select("select preco1 from produtos_precos where codigo_tab_preco = ?VLC_Tabela and produto = ?V_ENTRADAS_00_PROD1_ENT.produto", 'cur_custo')
				*!*
				*!*					 						VLN_CustoNota = V_ENTRADAS_00_ITENS.preco_unitario - iif(V_ENTRADAS_00_ITENS.qtde_item > 0,V_ENTRADAS_00_IMPOSTO.valor_imposto/V_ENTRADAS_00_ITENS.qtde_item,0)
				*!*					 						VLN_CustoPrevisto = cur_custo.preco1 * ((100-VLN_Taxa_Custo)/100)
				*!*
				*!*					 						USE IN cur_custo
				*!*
				*!*					 						IF VLN_CustoNota > VLn_CustoPrevisto
				*!*					 							IF !ALLTRIM(V_ENTRADAS_00_PROD1_ENT.produto) $ VLC_texto
				*!*					 								VLC_Texto = VLC_Texto + IIF(EMPTY(VLC_Texto), '', CHR(13) + CHR(10)) + 'Produto:' + allt(V_ENTRADAS_00_PROD1_ENT.produto) + ' tem o custo mínimo de ' + ALLTRIM(STR(VLN_CustoPrevisto,10,2)) + ' e veio na nota com ' + ALLTRIM(STR(VLN_CustoNota,10,2))
				*!*					 							ENDIF
				*!*					 						ENDIF
				*!*										ELSE
				*!*											MESSAGEBOX('Nao foi possivel encontrar o ITEM para o item impressão ' + ALLTRIM(V_ENTRADAS_00_PROD1_ENT.ITEM_IMPRESSAO), 16, wusuario)
				*!*											RETURN .F.
				*!*										ENDIF
				*!*									ELSE
				*!*										MESSAGEBOX('Nao foi possivel encontrar o IMPOSTO para o item impressão ' + ALLTRIM(V_ENTRADAS_00_PROD1_ENT.ITEM_IMPRESSAO), 16, wusuario)
				*!*										RETURN .F.
				*!*									ENDIF
				*!*			 					ENDSCAN
				*!*
				*!*			 					IF !EMPTY(VLC_Texto)
				*!*			 						MESSAGEBOX(VLC_Texto, 16, wusuario)
				*!*			 						RETURN .F.
				*!*			 					ENDIF
				*!*			 				ENDIF
				*!*						ENDIF
				***********************************************************************************************************************************************

				*****
				* JIRA LC-219
				* VALIDAÇÃO DA CHAVE DE ACESSO DA NFe
				* PAULO DEVIDE
				* 08-JUN-17
				*/
				
				IF NOT v_entradas_00.nf_entrada_propria AND ALLTRIM(v_Entradas_00.NATUREZA) <> '250.01' && DEVOLUÇÃO

					IF UPPER(ALLTRIM(v_entradas_00.DESC_ESPECIE_SERIE)) = "NF-E" AND ;
							DTOS(v_entradas_00.emissao) > "20170617" && validação foi implantada em 12/06/2017
						IF F_ChaveAcessoValida()
							IF ! F_ValidaPartesChaveAcesso()
								RETURN .f.
							ENDIF

						ELSE
							MESSAGEBOX("Chave de Acesso da NFe informada está em formato inválido!",16,"Aviso")
							RETURN .f.

						ENDIF
					ENDIF

				ENDIF
				

				***********************************************************************************************************************************************

			OTHERWISE

				RETURN .T.

		endcase

	endproc

enddefine




*!*	Local cOldAlias

*!*	cOldAlias = Select()

*!*	IF  ThisFormSet.p_Tool_Status $ 'IA'

*!*		Select v_Entradas_00
*!*		Replace Porc_Desconto_Digitado With .T.

*!*	ENDIF


*!*	O_005102.chk_Porc_Desconto_Digitado.Refresh()
*!*	O_005102.tx_Valor_Total.l_Desenhista_Recalculo()





************************************************************
* Validação do Calculo de ICMS                             *
************************************************************

Function rbInputBox3
	Lparameters tcPrompt, tcTitle, txDefaultValue, tnLeft, tnTop, ;
		tcFormat, tcInputMask, tcPasswordChar
	Private pcReturnValue
	pcReturnValue = txDefaultValue
	Local oInputBox
	oInputBox = Createobject("rbInputBox3", tcPrompt, tcTitle, ;
		txDefaultValue, tnLeft, tnTop, ;
		tcFormat, tcInputMask, tcPasswordChar)
	oInputBox.Show()
	Return pcReturnValue



	**************************************************
	*-- Class:        rbinputbox
	*-- ParentClass:  form
	*-- BaseClass:    form
	*-- Time Stamp:   01/29/03 01:03:14 PM
	*
Define Class rbInputBox3 As Form


	Height = 180
	Width = 318
	DoCreate = .T.
	AutoCenter = .T.
	Caption = "Input Box"
	ControlBox = .F.
	WindowType = 1
	Name = "frmInputBox"

	*-- empty value to return if Cancel is chosen; data type depends on data type of txValueIn
	xemptyvalue = .F.

	*-- the default value (if any)
	xdefaultvalue = .F.

	*-- the return value
	xreturnvalue = .F.


	Add Object lblvalor As Label With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Alignment = 1, ;
		Caption = "Valor Total dos Produtos", ;
		Height = 20, ;
		Left = 6, ;
		Top = 16, ;
		Width = 190, ;
		Name = "lblUser"


	Add Object txtvalor As TextBox With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Century = 1, ;
		Height = 24, ;
		Left = 202, ;
		SelectOnEntry = .T., ;
		TabIndex = 1, ;
		Top = 12, ;
		Width = 110, ;
		controlsource = "xCalcula_Icms.Valor_Prod",;
		inputmask = '999 999 999.99',;
		Name = "txtvalor "



	Add Object lblicms As Label With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Alignment = 1, ;
		Caption = "Valor ICMS", ;
		Height = 20, ;
		Left = 6, ;
		Top = 46, ;
		Width = 190, ;
		Name = "lblIcms"


	Add Object txticms As TextBox With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Century = 1, ;
		Height = 24, ;
		Left = 202, ;
		TabIndex = 2, ;
		Top = 42 ,;
		Width = 110, ;
		SelectOnEntry = .T., ;
		controlsource = "xCalcula_Icms.Valor_ICMS",;
		inputmask = '999 999 999.99',;
		Name = "txticms"




	Add Object lblaliq As Label With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Alignment = 1, ;
		Caption = "Aliquota ICMS", ;
		Height = 20, ;
		Left = 6, ;
		Top = 76, ;
		Width = 190, ;
		Name = "lblAliq"


	Add Object txtaliq As TextBox With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Century = 1, ;
		Height = 24, ;
		Left = 202, ;
		Top = 72, ;
		Width = 110, ;
		Readonly = .T.,;
		controlsource = "xCalcula_Icms.Aliquota",;
		inputmask = '999 999 999.99',;
		Name = "txtAliq"





	Add Object lblDesconto As Label With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Alignment = 1, ;
		Caption = "Valor Desconto", ;
		Height = 20, ;
		Left = 6, ;
		Top = 106, ;
		Width = 190, ;
		Name = "lblDesconto"


	Add Object txtDesconto As TextBox With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Century = 1, ;
		Height = 24, ;
		Left = 202, ;
		Top = 102, ;
		Width = 110, ;
		Readonly = .T.,;
		FontBold = .T.,;
		Forecolor = RGB(255,0,0),;
		controlsource = "xCalcula_Icms.Desconto",;
		inputmask = '999 999 999.99',;
		Name = "txtDesconto"





	Add Object cmdcalcula As CommandButton With ;
		Top = 132, ;
		Left = 32, ;
		Height = 24, ;
		Width = 72, ;
		Cancel = .T., ;
		Caption = "Calcular", ;
		TabIndex = 3, ;
		Name = "cmdCalcula"


	Add Object cmdok As CommandButton With ;
		Top = 132, ;
		Left = 124, ;
		Height = 24, ;
		Width = 72, ;
		Caption = "Confirmar", ;
		Default = .T., ;
		TabIndex = 20, ;
		Enabled = .F.,;
		Name = "cmdOK"


	Add Object cmdcancel As CommandButton With ;
		Top = 132, ;
		Left = 212, ;
		Height = 24, ;
		Width = 72, ;
		Cancel = .T., ;
		Caption = "Cancelar", ;
		TabIndex = 21, ;
		Enabled = .F.,;
		Name = "cmdCancel"





	Procedure Unload
		With Thisform
			If Type(".xReturnValue") = "C"
				.xreturnvalue = Rtrim( .xreturnvalue)
			Endif
			pcReturnValue = .xreturnvalue
		Endwith
	Endproc


	Procedure Init
		Lparameters tcPrompt, tcTitle, txDefaultValue, tnLeft, tnTop, ;
			tcFormat, tcInputMask, tcPasswordChar
		If Type("tcPrompt") <> "C"
			tcPrompt = "Enter the value"
		Endif
		If Type("tcTitle") <> "C"
			tcTitle = "Input Box"
		Endif
		If !( Type("txDefaultValue") $ "CDNY")
			*	Valid input data types are C, D, N, and Y
			txDefaultValue = ""	&& default to character data type
		Endif
		If Type("tcFormat") <> "C"
			tcFormat = ""
		Endif
		If Type("tcInputMask") <> "C"
			tcInputMask = ""
		Endif
		If Type("tcPasswordChar") <> "C"
			tcPasswordChar = ""
		Endif
		If Len( Alltrim( tcPasswordChar)) > 1
			tcPasswordChar = Left( tcPasswordChar, 1)
		Endif
		Local llAutoCenter
		If Pcount() < 5	&& Top and Left parameters were not passed
			tnLeft = 0
			tnTop = 0
		Else	&& Top and left parameters were passed but may not be numeric
			If Type("tnTop") = "N" And Type("tnLeft") = "N"		&& both are numeric
				llAutoCenter = .F.
			Else	&& one or both is not numeric, so AutoCenter the form
				tnLeft = 0
				tnTop = 0
				llAutoCenter = .T.
			Endif
		ENDIF



		With Thisform
			***.lblinputbox.Caption = Alltrim( tcPrompt)
			.Caption = Alltrim( tcTitle)
			.xdefaultvalue = txDefaultValue
			.xreturnvalue = .xdefaultvalue
			**.txtinputbox.Value = .xdefaultvalue
			**.txtinputbox.Format = Alltrim( tcFormat)
			**.txtinputbox.InputMask = Alltrim( tcInputMask)
			**.txtinputbox.PasswordChar = tcPasswordChar
			.Top = tnTop
			.Left = tnLeft
			.AutoCenter = llAutoCenter		&& Set AutoCenter last so it overrides Top and Left if .T.

			Do Case
				Case Type("txDefaultValue") = "D"
					.xemptyvalue = {}
				Case Type("txDefaultValue") = "N"
					.xemptyvalue = 0
				Case Type("txDefaultValue") = "Y"
					.xemptyvalue = $0
				Otherwise
					.xemptyvalue = ""
			Endcase
		Endwith
	ENDPROC



	Procedure txtDesconto.When
		RETURN .F.
	Endproc


	Procedure txtAliq.When
		RETURN .F.
	ENDPROC


	Procedure txtValor.InteractiveChange

		With Thisform


			.txtAliq.value =  0
			.txtDesconto.value = 0

			.cmdok.Enabled = .F.
			.cmdCancel.Enabled = .F.


		Endwith

	ENDPROC


	Procedure txtICMS.InteractiveChange

		With Thisform


			.txtAliq.value =  0
			.txtDesconto.value = 0

			.cmdok.Enabled = .F.
			.cmdCancel.Enabled = .F.



		Endwith

	ENDPROC



	Procedure cmdcalcula.Click
		With Thisform

			IF EMPTY(.txtvalor.value)	or;
					EMPTY(.txticms.value)
				MESSAGEBOX("Informe o Valor Total dos Produtos e o valor do ICMS",16,"Atenção")
				return
			Endif



			IF !EMPTY(.txtvalor.value)	and;
					!EMPTY(.txticms.value)

				.txtAliq.value =  ROUND((.txticms.value/.txtvalor.value)*100,2)

				ln_valor = ROUND(.txtvalor.value*(( 12 - .txtAliq.value) )/100,2)

				IF   ln_valor > 0
					.txtDesconto.value =  ln_valor
				ELSE
					.txtDesconto.value = 0

				Endif

			endif

			***IF .txtDesconto.value > 0
			.cmdok.Enabled = .T.
			**	.cmdCancel.Enabled = .T.
			***endif



		Endwith
	Endproc

	Procedure cmdok.Click
		With Thisform



			lcsql = ""

			*!*		    IF f_vazio(.txtUser.Value)
			*!*		       MESSAGEBOX("Informe o Usuário!")
			*!*		       RETURN
			*!*		    endif
			*!*
			*!*			.xreturnvalue = .txtinputbox.Value

			*!*	*!*			Select xUserSenha
			*!*	*!*			Zap
			*!*	*!*			Append Blank
			*!*			Replace usuario With Alltrim(.txtUser.Value) IN xUserSenha



			.Release()
		Endwith
	Endproc




	Procedure cmdcancel.Click
		*
		*	If Cancel was chosen, return the empty value of the correct data type.
		*
		With Thisform

			SELECT xCalcula_Icms
			ZAP


			.xreturnvalue = .xemptyvalue
			.Release()
		Endwith
	Endproc


Enddefine
*
*-- EndDefine: btn_exp
**************************************************


FUNCTION F_ChaveAcessoValida
	LOCAL llOK as Boolean, lnArea as Integer
	llOk = .t.
	lnArea = SELECT()
	lcChave = ALLTRIM(v_entradas_00.chave_nfe)
	** Função em TSQL
	F_SELECT("SELECT dbo.usf_calcula_dv_nfe(?lcChave) as valida;","curValidaNF")
	llOk = curValidaNF.valida
	SELECT (lnArea)
	RETURN llOk
ENDFUNC

FUNCTION F_ValidaPartesChaveAcesso
	LOCAL llOK as Boolean, lnArea as Integer
	llOk = .t.
	lnArea = SELECT()

	lcStatusExact = SET("Exact")
	SET EXACT on

	LOCAL lcChave as String, lcMsg as String

	lcChave = ALLTRIM(v_entradas_00.chave_nfe)
	DIMENSION laPart[8]
	laPart = ""
	lcMsg = ""

	laPart[1] = SUBSTR(lcChave,1,2)
	laPart[2] = SUBSTR(lcChave,3,4)
	laPart[3] = SUBSTR(lcChave,7,14)
	laPart[4] = SUBSTR(lcChave,21,2)
	laPart[5] = SUBSTR(lcChave,23,3)
	laPart[6] = SUBSTR(lcChave,26,9)
	laPart[7] = SUBSTR(lcChave,35,9)
	laPart[8] = RIGHT(lcChave,1)

	f_select("select * from cae_estados_ibge order by codigo","estados_ibge")
	SELECT estados_ibge
	LOCATE FOR CODIGO = CAST(laPart[1] as int)

	DIMENSION laStatusChaveNFe[5]
	laStatusChaveNFe = .T.

	** Valida estado
	IF estados_ibge.sigla <> v_entradas_00.uf
		laStatusChaveNFe[1] = .F. && estado diferente
		llOk = .F.
		lcMsg = lcMsg + "(1) ESTADO da Chave de Acesso está diferente do fornecedor!" +CHR(13)
	ENDIF
	** Valida Ano/Mes da emissão
	IF SUBSTR(DTOS(v_entradas_00.emissao),3,4) <> laPart[2]
		laStatusChaveNFe[2] = .F. && mes/ano da emissao diferente
		llOk = .F.
		lcMsg = lcMsg + "(2) Data de Emissão informada está diferente da Chave de Acesso !" +CHR(13)
	ENDIF
	** Valida CNPJ do emitente
	IF STRTRAN(STRTRAN(STRTRAN(ALLTRIM(v_entradas_00.cgc_cpf),".",""),"/",""),"-","") <> laPart[3]
		laStatusChaveNFe[3] = .F. && mes/ano da emissao diferente
		llOk = .F.
		lcMsg = lcMsg + "(3) CNPJ do Fornecedor está diferente do CNPJ da Chave de Acesso !" +CHR(13)
	ENDIF
	** valida numero da NFe
	IF ALLTRIM(v_entradas_00.nf_entrada) <> laPart[6]
		laStatusChaveNFe[4] = .F. && mes/ano da emissao diferente
		llOk = .F.
		lcMsg = lcMsg + "(4) Nº da NF-e está diferente do número da NF-e da Chave de Acesso !" +CHR(13)
	ENDIF
	** Valida Serie da NFe
	lcSerieNF = ALLTRIM(v_entradas_00.serie_nf_entrada)
	IF lcSerieNF <> laPart[5]
		laStatusChaveNFe[5] = .F. && serie esta diferente
		llOk = .F.
		lcMsg = lcMsg + "(5) Nº de Série da NF-e está diferente do Nº de Série da NF-e da Chave de Acesso !" +CHR(13)
	ENDIF

	IF !llOk
		MESSAGEBOX(lcMsg,16,"Aviso")
	ENDIF

	SELECT (lnArea)
	SET EXACT &lcStatusExact.
	RETURN llOk
ENDFUNC

DEFINE CLASS lblPedido2 AS Label
	Autosize = .t.
	Left = 7
	Top = 317
	Caption = "Ref. Pedido"
	Name = "lblPedido2"
	BackStyle= 0
	FontSize=8
ENDDEFINE


DEFINE CLASS txtPedido2 AS lx_textbox_base
	Height = 21
	Left = 74
	Top = 317
	Width = 93
	ReadOnly = .F.
	Name = "txtPedido2"
	ControlSource = "V_ENTRADAS_00_PROD1_ENT.PEDIDO2"
	*p_tipo_dado = "EDITA"

	PROCEDURE when
		RETURN .t.
	ENDPROC

	PROCEDURE valid
		IF INLIST(ThisFormSet.p_tool_status,'I','A')
			** Nulo ou vazio não valida
			IF EMPTY(NVL(this.value,''))
				RETURN .t.
			ENDIF

			lcPedido = ALLTRIM(this.Value)
			lcProduto = V_ENTRADAS_00_PROD1_ENT.produto
				
			llOk=.f.
			f_select("select pedido from compras where pedido = '"+lcPedido+"'","tmpExistePedido")
			IF RECCOUNT("tmpExistePedido")< 1
				MESSAGEBOX("Pedido não encontrado!",16,"Aviso")
				RETURN .f.
			ENDIF
			
			llOk=.f.
			f_select("select pedido from compras_produto where pedido = '"+lcPedido+"' and produto = '"+lcProduto+"'","tmpExisteproduto")
			IF RECCOUNT("tmpExisteproduto")<1
				MESSAGEBOX("Produto não encontrado no pedido!",16,"Aviso")
				RETURN .f.
			ENDIF
		
		ELSE
			RETURN .t.
		ENDIF 

	ENDPROC

ENDDEFINE

DEFINE CLASS Lx_label8 as Lx_Label
	Autosize=.f.
	BackColor = RGB(192,192,192)
	Caption = "CCF"
	ForeColor = RGB(255,0,0)
	Height = 15
	Left = 253 &&293
	Name = "Lx_label8"
	Top = 34
	Width = 114
	
	PROCEDURE click
		IF MESSAGEBOX("Deseja selecionar por CCF?",292,"Aviso")=6
			this.Parent.cmb_pedidos.Value=""
			this.Parent.cmb_ccf.setfocus
		ENDIF
		
	ENDPROC
	
	PROCEDURE refresh
		IF INLIST(ALLTRIM(v_entradas_00.nome_clifor),"HARPIA IMPORTADORA E DIST","KOMPORT")
			this.Visible = .t.
		ELSE
			this.Visible = .f.
		ENDIF  
	ENDPROC 
	
ENDDEFINE 

DEFINE CLASS cmb_ccf as lx_Combobox
	BoundColumn = 1
	ColumnCount=2
	Height=22
	Name = "cmb_ccf"
	Width = 164
	Top = 30
	Left = 370 &&410
	p_tipo_dado = "EDITA"
	
	PROCEDURE RightClick
		Nodefault
	ENDPROC 
	
	PROCEDURE when
		IF !f_vazio(this.Parent.cmb_pedidos.Value)
			RETURN .F.
		ELSE
			RETURN DODEFAULT()
		ENDIF	
	ENDPROC 
	
	PROCEDURE l_desenhista_recalculo
		Local cOldSele, nPerc, nPerc_Qtde, cSQL1, cSQL2, nQtde_Entrada, nQtde_Entregar, a, cCampo1, cCampo2, cCampo3
		Local nQtde_Total, nQtde_Cancel, cCampo5

		Private cPedido

		cOldSele = Select()

		IF !USED('cur_compras_prod')
			SELECT * FROM v_Compras_01_Produtos WHERE 1 = 0 INTO CURSOR cur_compras_prod readwrite
		ENDIF

		SELECT cur_compras_prod 
		DELETE ALL 


		Select v_Compras_01
		F_StuffDBC('Additive', 'erp_cups_processo_ccf_cca = ?xCur_ccf.ccf')
		Go Top

		SCAN

			If ! Eof()

				Select v_Compras_01_Produtos

				If ! ( PEDIDO == v_Compras_01.PEDIDO )

					Set Filter To
					Requery()
					
					Delete All For ( Qtde_Entregar <= 0 )

					If Type("ThisFormSet.pp_Filtrar_Limite_Pedido") == "L" AND ThisFormSet.pp_Filtrar_Limite_Pedido
						Delete All For LIMITE_ENTREGA < v_Entradas_00.RECEBIMENTO
					EndIf

					Go Top
					
					INSERT INTO cur_compras_prod SELECT * FROM v_Compras_01_Produtos WHERE !DELETED()
				Else

					Select(cOldSele)
					Return

				Endif

			EndIf
		ENDSCAN

		SELECT v_Compras_01_Produtos
		DELETE ALL
		INSERT INTO v_Compras_01_Produtos SELECT * FROM cur_compras_prod 
		GO TOP 

		this.Refresh()
		cPedido = ALLTRIM(This.Value)

		IF EMPTY(v_Entradas_00.RECEBIMENTO)
		   MESSAGEBOX("Informe a Data de Recebimento!",16,"Aviso")
		   return .T.
		Endif

		lc_Recebimento  = DTOC(v_Entradas_00.RECEBIMENTO,1)

		TEXT TO lc_SQL noshow
		SELECT  DATEDIFF ( WK , LIMITE_ENTREGA, ?lc_Recebimento ) as atraso
		from
		   COMPRAS (NOLOCK) CPA
		join 
		   COMPRAS_PRODUTO (NOLOCK) PROD
		      ON CPA.PEDIDO = PROD.PEDIDO
		WHERE CPA.pedido = ?cPedido 
		Endtext 

		F_SELECT(lc_SQL,"x_Calc_atraso" )

		this.Parent.lx_limite_calc.Value =  x_Calc_atraso.atraso
		this.Parent.lx_limite_entrega.refresh()

		F_Select('SELECT Compras.Comprimento_de_Rolos, Compras.Marca_Volumes FROM Compras WHERE Compras.Pedido = ?cPedido', 'curCompras')

		nPerc      = Iif( F_Vazio(curCompras.Comprimento_de_Rolos), 0, curCompras.Comprimento_de_Rolos )
		lMarca_Vol = ( ! InList(v_Entradas_00.Serie_NF_Entrada, wTipo_Producao, wTipo_Producao_Serie) )
		nPerc_Qtde = Iif( F_Vazio(curCompras.Marca_Volumes), 0, Iif( lMarca_Vol, curCompras.Marca_Volumes, ( 100 - curCompras.Marca_Volumes ) ) ) 

		cSQL1      = "SELECT SUM(c.En_1) AS En_1, SUM(c.En_2) AS En_2, SUM(c.En_3) AS En_3, SUM(c.En_4) AS En_4, " + ;
		             "SUM(c.En_5) AS En_5, SUM(c.En_6) AS En_6, SUM(c.En_7) AS En_7, SUM(c.En_8) AS En_8, " + ;
		             "SUM(c.En_9) AS En_9, SUM(c.En_10) AS En_10, SUM(c.En_11) AS En_11, SUM(c.En_12) AS En_12, " + ;
		             "SUM(c.En_13) AS En_13, SUM(c.En_14) AS En_14, SUM(c.En_15) AS En_15, SUM(c.En_16) AS En_16, " + ;
		             "SUM(c.En_17) AS En_17, SUM(c.En_18) AS En_18, SUM(c.En_19) AS En_19, SUM(c.En_20) AS En_20, " + ;
		             "SUM(c.En_21) AS En_21, SUM(c.En_22) AS En_22, SUM(c.En_23) AS En_23, SUM(c.En_24) AS En_24, " + ;
		             "SUM(c.En_25) AS En_25, SUM(c.En_26) AS En_26, SUM(c.En_27) AS En_27, SUM(c.En_28) AS En_28, " + ;
		             "SUM(c.En_29) AS En_29, SUM(c.En_30) AS En_30, SUM(c.En_31) AS En_31, SUM(c.En_32) AS En_32, " + ;
		             "SUM(c.En_33) AS En_33, SUM(c.En_34) AS En_34, SUM(c.En_35) AS En_35, SUM(c.En_36) AS En_36, " + ;
		             "SUM(c.En_37) AS En_37, SUM(c.En_38) AS En_38, SUM(c.En_39) AS En_39, SUM(c.En_40) AS En_40, " + ;
		             "SUM(c.En_41) AS En_41, SUM(c.En_42) AS En_42, SUM(c.En_43) AS En_43, SUM(c.En_44) AS En_44, " + ;
		             "SUM(c.En_45) AS En_45, SUM(c.En_46) AS En_46, SUM(c.En_47) AS En_47, SUM(c.En_48) AS En_48 " + ;
		             "FROM Estoque_Prod_Ent as b INNER JOIN Estoque_Prod1_Ent c ON b.Romaneio_Produto = c.Romaneio_Produto AND b.Filial = c.Filial " + ;
		             "WHERE c.Produto = ?v_Compras_01_Produtos.Produto AND c.Cor_Produto = " + ;
		             "?v_Compras_01_Produtos.Cor_Produto AND b.Pedido = ?v_Compras_01_Produtos.Pedido AND " + ;
		             "b.Entrega_Pedido = ?v_Compras_01_Produtos.Entrega AND b.Serie_NF_Entrada " + ;
		             Iif( InList(v_Entradas_00.Serie_NF_Entrada, wTipo_Producao, wTipo_Producao_Serie), ' IN ', ' NOT IN ' ) + ;
		             " ( ?wTipo_Producao, ?wTipo_Producao_Serie )"

		cSQL2      = "SELECT SUM(Co1) AS Co1, SUM(Co2) AS Co2, SUM(Co3) AS Co3, SUM(Co4) AS Co4, SUM(Co5) AS Co5, " + ;
		             "SUM(Co6) AS Co6, SUM(Co7) AS Co7, SUM(Co8) AS Co8, SUM(Co9) AS Co9, SUM(Co10) AS Co10, SUM(Co11) " + ;
		             "AS Co11, SUM(Co12) AS Co12, SUM(Co13) AS Co13, SUM(Co14) AS Co14, SUM(Co15) AS Co15, SUM(Co16) " + ;
		             "AS Co16, SUM(Co17) AS Co17, SUM(Co18) AS Co18, SUM(Co19) AS Co19, SUM(Co20) AS Co20, SUM(Co21) " + ;
		             "AS Co21, SUM(Co22) AS Co22, SUM(Co23) AS Co23, SUM(Co24) AS Co24, SUM(Co25) AS Co25, SUM(Co26) " + ;
		             "AS Co26, SUM(Co27) AS Co27, SUM(Co28) AS Co28, SUM(Co29) AS Co29, SUM(Co30) AS Co30, SUM(Co31) " + ;
		             "AS Co31, SUM(Co32) AS Co32, SUM(Co33) AS Co33, SUM(Co34) AS Co34, SUM(Co35) AS Co35, SUM(Co36) " + ;
		             "AS Co36, SUM(Co37) AS Co37, SUM(Co38) AS Co38, SUM(Co39) AS Co39, SUM(Co40) AS Co40, SUM(Co41) " + ;
		             "AS Co41, SUM(Co42) AS Co42, SUM(Co43) AS Co43, SUM(Co44) AS Co44, SUM(Co45) AS Co45, SUM(Co46) " + ;
		             "AS Co46, SUM(Co47) AS Co47, SUM(Co48) AS Co48 FROM Compras_Prod_Cancelada WHERE Pedido = " + ;
		             "?v_Compras_01_Produtos.Pedido AND Produto = ?v_Compras_01_Produtos.Produto AND " + ;
		             "Cor_Produto = ?v_Compras_01_Produtos.Cor_Produto AND Entrega = ?v_Compras_01_Produtos.Entrega"

		If ( nPerc > 0 ) OR ( nPerc_Qtde > 0 )

			Select v_Compras_01_Produtos
			Scan

				Messagebox.ShowProgress("Aguarde, verificando comprimento de rolos...", Reccount("v_Compras_01_Produtos"))

				F_Select(cSQL1, 'curEntrada')
				F_Select(cSQL2, 'curCancel')
				
				nQtde_Total = 0
				
				For a = 1 To wMaximo_Tamanhos
				
					cCampo1        = 'curEntrada.En_' + Alltrim(Str(a))
					cCampo2        = 'v_Compras_01_Produtos.Co' + Alltrim(Str(a))
					cCampo3        = 'v_Compras_01_Produtos.Ce' + Alltrim(Str(a))
					cCampo4        = 'curCancel.Co' + Alltrim(Str(a))
					cCampo5        = 'v_Entradas_00_Prod1_Ent.EN_' + Alltrim(Str(a))

					nQtde_Entrada  = Iif( f_Vazio(Evaluate(cCampo1)), 0, Evaluate(cCampo1) )
					nQtde_Cancel   = Iif( F_Vazio(Evaluate(cCampo4)), 0, Evaluate(cCampo4) )
					
					** Ajusta a qtde *********************************************************
					Select v_Entradas_00_Prod1_Ent
					Go Top

					Locate For Alltrim(PEDIDO)      == Alltrim(v_Compras_01_Produtos.PEDIDO) AND ;
					           Alltrim(PRODUTO)     == Alltrim(v_Compras_01_Produtos.PRODUTO) AND ;
					           Alltrim(COR_PRODUTO) == Alltrim(v_Compras_01_Produtos.Cor_PRODUTO) AND ;
					           ENTREGA_PEDIDO       == v_Compras_01_Produtos.ENTREGA

					If Found()

						Scan For Alltrim(PEDIDO)      == Alltrim(v_Compras_01_Produtos.PEDIDO) AND ;
						         Alltrim(PRODUTO)     == Alltrim(v_Compras_01_Produtos.PRODUTO) AND ;
						         Alltrim(COR_PRODUTO) == Alltrim(v_Compras_01_Produtos.Cor_PRODUTO) AND ;
						         ENTREGA_PEDIDO       == v_Compras_01_Produtos.ENTREGA

							nQtde_Entrada = ( nQtde_Entrada + Evaluate(cCampo5) )
						
						EndScan

					EndIf
					**************************************************************************

					nQtde_Entregar = ( ( Evaluate(cCampo2) - nQtde_Cancel - nQtde_Entrada ) - ( ( Evaluate(cCampo2) - nQtde_Cancel ) * ( nPerc_Qtde / 100 ) ) )
					nQtde_Total    = ( nQtde_Total + Iif( nQtde_Entregar < 0, 0, nQtde_Entregar ) )
					
					Select v_Compras_01_Produtos
					Replace &cCampo3 With Iif( nQtde_Entregar < 0, 0, nQtde_Entregar )

				Next

				Select v_Compras_01_Produtos
				Replace Comprimento_de_rolos With nPerc ,;
						Custo_Cheio1         With Custo1, ;
				        Custo_Cheio2         With Custo2, ;
				        Custo_Cheio3         With Custo3, ;
				        Custo_Cheio4         With Custo4, ;
				        Custo1               With ( Custo1 - ( ( Custo1 * nPerc ) / 100 ) ), ;
				        Custo2               With ( Custo2 - ( ( Custo2 * nPerc ) / 100 ) ), ;
				        Custo3               With ( Custo3 - ( ( Custo3 * nPerc ) / 100 ) ), ;
				        Custo4               With ( Custo4 - ( ( Custo4 * nPerc ) / 100 ) ), ;
				        Custo_Moeda1         With ( Custo_Moeda1 - ( ( Custo_Moeda1 * nPerc ) / 100 ) ), ;
				        Custo_Moeda2         With ( Custo_Moeda2 - ( ( Custo_Moeda2 * nPerc ) / 100 ) ), ;
				        Custo_Moeda3         With ( Custo_Moeda3 - ( ( Custo_Moeda3 * nPerc ) / 100 ) ), ;
				        Custo_Moeda4         With ( Custo_Moeda4 - ( ( Custo_Moeda4 * nPerc ) / 100 ) ), ;
				        Valor_Entregar       With ( Valor_Entregar - ( ( Valor_Entregar * nPerc ) / 100 ) ), ;
				        Qtde_Entregar        With nQtde_Total

				Select v_Compras_01_Produtos

			EndScan

			Messagebox.ShowProgress()
			
		EndIf

		Select v_Compras_01_Produtos
		Go Top

		Delete All For ( Qtde_Entregar <= 0 )
		Go Top

		This.Parent.lx_Desc_Produto.Refresh()
		This.Parent.lx_Desc_Cor.Refresh()
		This.Parent.lx_Desconto_Digitado.Refresh()  
		This.Parent.lx_semana_Atraso.Refresh()
		This.Parent.LX_LImite_entrega.Refresh()

		   
		This.Parent.lx_Grid_Filha1.col_Grade_48.lx_Grade48_1.l_Grade(.T.)
		This.Parent.lx_Grid_Filha1.Refresh()

		Select(cOldSele)
		Return	
	ENDPROC 

	PROCEDURE refresh
		IF INLIST(ALLTRIM(v_entradas_00.nome_clifor),"HARPIA IMPORTADORA E DIST","KOMPORT")
			this.Visible = .t.
		ELSE
			this.Visible = .f.
		ENDIF  
	ENDPROC 

ENDDEFINE 

***
* Botao Seleção da Aba Produtos
* Selecionar por pedido/ccf
* Remove o botao original da tela da Linx e substitui por este botão 
* que tem o merge do codigo novo pós SPK 01.18 com o codigo customizado CAEDU
* PAULO DEVIDE 
* 25/05/2018
*/
*!*	*!*	*!*	DEFINE CLASS botao1 as botao

*!*	*!*	*!*		caption = "\<Seleção..."
*!*	*!*	*!*		fontbold = .t.
*!*	*!*	*!*		Height = 24
*!*	*!*	*!*		Left = 590
*!*	*!*	*!*		Top = 108
*!*	*!*	*!*		Width = 115
*!*	*!*	*!*		Forecolor = RGB(0,0,255)
*!*	*!*	*!*		
*!*	*!*	*!*		PROCEDURE refresh
*!*	*!*	*!*			this.Enabled = INLIST(thisformset.p_tool_status,"I","A")
*!*	*!*	*!*		ENDPROC
*!*	*!*	*!*		
*!*	*!*	*!*		
*!*	*!*	*!*		
*!*	*!*	*!*		PROCEDURE click
*!*	*!*	*!*			Local nOldSele, cWhereNF, cWhere, cSQL as String

*!*	*!*	*!*			=MESSAGEBOX("A [Data de Recebimento] informada na tela  é [" +DTOC(v_Entradas_00.RECEBIMENTO) +"]!",16,"Aviso") 

*!*	*!*	*!*			if  MESSAGEBOX("Confirma a [Data de Recebimento da NF]  como  " +DTOC(v_Entradas_00.RECEBIMENTO) +"?",32+4+256,"Aviso") == 7

*!*	*!*	*!*			    =MESSAGEBOX("Por gentileza digite a Data de Recebimento Correta antes de selecionar o pedido !! ",16,"Aviso") 
*!*	*!*	*!*			    return .T.
*!*	*!*	*!*			    
*!*	*!*	*!*			Endif

*!*	*!*	*!*			nOldSele = Select()

*!*	*!*	*!*			If ! InList(ThisFormSet.p_Tool_Status, "I", "A") OR v_Entradas_00.NOTA_COMPLEMENTAR

*!*	*!*	*!*				Select(nOldSele)
*!*	*!*	*!*				Return

*!*	*!*	*!*			EndIf

*!*	*!*	*!*			If ( InList(v_Entradas_00.Tipo_Operacao, "D", "N") OR ( Inlist(v_Entradas_00.CTB_TIPO_OPERACAO, 222) AND v_Entradas_00.TIPO_OPERACAO == "T" ) )

*!*	*!*	*!*				If this.parent.lx_opcaoselecao.Value = 1
*!*	*!*	*!*					F_Msg(["Não é possível utilizar a opção de seleção de pedidos em devoluções!", 0+48, "Atenção"])
*!*	*!*	*!*					Select(nOldSele)
*!*	*!*	*!*					Return
*!*	*!*	*!*				Endif 

*!*	*!*	*!*				If (Type('ThisFormSet.pp_valida_pedido_dig_cod_bar') = "U" or ThisFormSet.pp_valida_pedido_dig_cod_bar)

*!*	*!*	*!*					F_Msg(["Para utilizar essa opção, ajuste o parâmetro VALIDA_PEDIDO_DIG_COD_BAR.", 0+48, "Atenção"])
*!*	*!*	*!*					Select(nOldSele)
*!*	*!*	*!*					Return
*!*	*!*	*!*					
*!*	*!*	*!*				Endif 	

*!*	*!*	*!*			EndIf

*!*	*!*	*!*			ThisFormSet.px_Zerar_Qtde_Entrada = ( This.Parent.lx_OpcaoSelecao.Value == 2 )   && Se for código de barras

*!*	*!*	*!*			If F_Vazio(v_Entradas_00.NOME_CLIFOR)

*!*	*!*	*!*				F_Msg(["Informe o fornecedor para selecionar os pedidos !", 0+48, "Atenção"])
*!*	*!*	*!*				Select(nOldSele)
*!*	*!*	*!*				Return .F.

*!*	*!*	*!*			EndIf

*!*	*!*	*!*	**o_005102.lx_form1.lx_pageframe1.page7.lx_pageframe1.page1.lx_pageframe1.page1.lx_grid_filha1.col_TX_PEDIDO.H_TX_PEDIDO.Caption
*!*	*!*	*!*	*!*			Novos endereços dos componentes		
*!*	*!*	*!*	*!*			ThisForm.Lx_pageframe1.Page7.Lx_pageframe1.Page1.Lx_pageframe1.Page1.cmb_pedidos
*!*	*!*	*!*	*!*			ThisForm.Lx_pageframe1.Page7.Lx_pageframe1.Page2.cmb_pedidos

*!*	*!*	*!*	*!*			With This.Parent.Parent.Page7.lx_PageFrame1.page1.lx_pageframe1

*!*	*!*	*!*	*!*				.Page1.cmb_Fornecedores.ControlSource = ""
*!*	*!*	*!*	*!*				.Page1.cmb_Fornecedores.RowSource     = ""
*!*	*!*	*!*	*!*				.Page1.cmb_PEDIDOS.CONTROLSOURCE	  = ""
*!*	*!*	*!*	*!*				.Page1.cmb_PEDIDOS.ROWSOURCE		  = ""
*!*	*!*	*!*	*!*				
*!*	*!*	*!*	*!*				
*!*	*!*	*!*	*!*				.Page2.cmb_Fornecedores.ControlSource = ""
*!*	*!*	*!*	*!*				.Page2.cmb_Fornecedores.RowSource     = ""
*!*	*!*	*!*	*!*				.Page2.cmb_PEDIDOS.CONTROLSOURCE	  = ""
*!*	*!*	*!*	*!*				.Page2.cmb_PEDIDOS.ROWSOURCE		  = ""	
*!*	*!*	*!*	*!*				
*!*	*!*	*!*	*!*			EndWith

*!*	*!*	*!*			WITH ThisForm.Lx_pageframe1.Page7.Lx_pageframe1.Page1.Lx_pageframe1.Page1
*!*	*!*	*!*				.cmb_Fornecedores.ControlSource = ""
*!*	*!*	*!*				.cmb_Fornecedores.RowSource     = ""
*!*	*!*	*!*				** PAULO DEVIDE - 21/09/2025 - COMENTARIOS - CUSTOMIZAÇÃO
*!*	*!*	*!*				** foi necessário incluir fisicamente o componente na tela pois foi retirado no spk 2025
*!*	*!*	*!*				** trocaram por TV_pedidos e eu deixei o componente novo invisivel
*!*	*!*	*!*				.cmb_PEDIDOS.CONTROLSOURCE	  = ""
*!*	*!*	*!*				.cmb_PEDIDOS.ROWSOURCE		  = ""
*!*	*!*	*!*			ENDWITH 
*!*	*!*	*!*			** A Page2 se manteve inalterada como estava na versão anterior
*!*	*!*	*!*			** por este motivo quebrei em dois with..endwith
*!*	*!*	*!*			WITH ThisForm.Lx_pageframe1.Page7.Lx_pageframe1.Page2
*!*	*!*	*!*				.cmb_Fornecedores.ControlSource = ""
*!*	*!*	*!*				.cmb_Fornecedores.RowSource     = ""

*!*	*!*	*!*				.cmb_PEDIDOS.CONTROLSOURCE	  = ""
*!*	*!*	*!*				.cmb_PEDIDOS.ROWSOURCE		  = ""
*!*	*!*	*!*			ENDWITH 

*!*	*!*	*!*			If Used("xCur_Pedidos")

*!*	*!*	*!*				Select xCur_Pedidos
*!*	*!*	*!*				Use

*!*	*!*	*!*			EndIf

*!*	*!*	*!*			If Used("xCur_Pedidos_Fornec")

*!*	*!*	*!*				Select xCur_Pedidos_Fornec
*!*	*!*	*!*				Use

*!*	*!*	*!*			EndIf

*!*	*!*	*!*			**-Trecho de codigo que existia antes do SPK 01.18
*!*	*!*	*!*			**-If ThisFormSet.px_Bloq_EntPed_NOP
*!*	*!*	*!*			**-	cWhereNF = " AND ( COMPRAS.NATUREZA_ENTRADA IS NULL OR COMPRAS.NATUREZA_ENTRADA = ?v_Entradas_00.NATUREZA ) "
*!*	*!*	*!*			**-Else
*!*	*!*	*!*			**-	cWhereNF = ""
*!*	*!*	*!*			**-EndIf


*!*	*!*	*!*			* #76#
*!*	*!*	*!*			**-Trecho de codigo novo após SPK 01.18 (#76)
*!*	*!*	*!*			cWhereNF = ""
*!*	*!*	*!*			If thisformset.lx_FORM1.lx_pageframe1.page6.ck_tipo_operacao.Value = 1 
*!*	*!*	*!*				cWhereNF = cWhereNF  + " AND (COMPRAS.CTB_Tipo_Operacao = ?v_Entradas_00.CTB_Tipo_Operacao ) "
*!*	*!*	*!*			Endif

*!*	*!*	*!*			If thisformset.lx_FORM1.lx_pageframe1.page6.ck_natureza_operazao.Value = 1 
*!*	*!*	*!*				cWhereNF = cWhereNF + " AND ( COMPRAS.NATUREZA_ENTRADA = ?v_Entradas_00.NATUREZA ) "
*!*	*!*	*!*			Endif
*!*	*!*	*!*			* #76#

*!*	*!*	*!*			cWhere = "RTRIM(COMPRAS.TABELA_FILHA) = 'COMPRAS_PRODUTO' AND " + ;
*!*	*!*	*!*			         "COMPRAS.TOT_QTDE_ENTREGAR > 0 AND " + ;
*!*	*!*	*!*			         Iif( Type("ThisFormSet.pp_Controla_Aprovacao_Pedido") == "L" AND ThisFormSet.pp_Controla_Aprovacao_Pedido, ;
*!*	*!*	*!*			              "COMPRAS.STATUS_APROVACAO = 'A' AND ", ;
*!*	*!*	*!*			              "" ) + ;
*!*	*!*	*!*			         "FILIAIS.MATRIZ_FISCAL = ?v_Entradas_00.FILIAL_MATRIZ_FISCAL " + ;
*!*	*!*	*!*			         cWhereNF

*!*	*!*	*!*			If wCtrl_Multi_Empresa
*!*	*!*	*!*				cWhere = cWhere + " AND FILIAIS.EMPRESA = ?wEmpresa_Atual"
*!*	*!*	*!*			EndIf

*!*	*!*	*!*			If Type("ThisFormSet.pp_Valida_Pedido_Dig_Cod_Bar") == "L" AND ! ThisFormSet.pp_Valida_Pedido_Dig_Cod_Bar AND This.Parent.lx_OpcaoSelecao.Value == 2

*!*	*!*	*!*				F_Select("SELECT DISTINCT COMPRAS.PEDIDO, COMPRAS.FORNECEDOR, COMPRAS.FILIAL_COBRANCA, SPACE(06) AS COD_FILIAL_COBRANCA " + ;
*!*	*!*	*!*				         "FROM COMPRAS " + ;
*!*	*!*	*!*				         "WHERE 1 = 0", "xCur_Pedidos")
*!*	*!*	*!*				         
*!*	*!*	*!*				Select distinct fornecedor from xcur_pedidos into cursor xcur_pedidos_fornec

*!*	*!*	*!*			Else

*!*	*!*	*!*				**-cSQL = "SELECT DISTINCT COMPRAS.PEDIDO, COMPRAS.FORNECEDOR, COMPRAS.FILIAL_COBRANCA, FILIAIS_COBRANCA.COD_FILIAL AS COD_FILIAL_COBRANCA " + ;
*!*	*!*	*!*				**-       "FROM COMPRAS "
*!*	*!*	*!*				**- Andre Maia - Inclusão da Coluna CCF da tabela COMPRAS
*!*	*!*	*!*				cSQL = "SELECT DISTINCT COMPRAS.PEDIDO, COMPRAS.FORNECEDOR, COMPRAS.FILIAL_COBRANCA, FILIAIS_COBRANCA.COD_FILIAL AS COD_FILIAL_COBRANCA, " +;
*!*	*!*	*!*				       " ISNULL(compras.erp_cups_processo_ccf_cca, '') as CCF  " + ;
*!*	*!*	*!*				       "FROM COMPRAS "

*!*	*!*	*!*				If Type("ThisFormSet.pp_Filtrar_Limite_Pedido")== "L" AND ThisFormSet.pp_Filtrar_Limite_Pedido
*!*	*!*	*!*					cSQL = cSQL + "INNER JOIN COMPRAS_PRODUTO ON COMPRAS.PEDIDO = COMPRAS_PRODUTO.PEDIDO AND COMPRAS_PRODUTO.LIMITE_ENTREGA >= ?v_Entradas_00.RECEBIMENTO "
*!*	*!*	*!*				EndIf
*!*	*!*	*!*				
*!*	*!*	*!*				cSQL = cSQL + "INNER JOIN FILIAIS ON COMPRAS.FILIAL_A_ENTREGAR = FILIAIS.FILIAL " + ;
*!*	*!*	*!*				              "LEFT JOIN FILIAIS AS FILIAIS_COBRANCA ON COMPRAS.FILIAL_COBRANCA = FILIAIS_COBRANCA.FILIAL " + ;
*!*	*!*	*!*				              "WHERE " + cWhere + " " + ;
*!*	*!*	*!*				              "ORDER BY COMPRAS.PEDIDO"

*!*	*!*	*!*				If ! F_Select(cSQL, "xCur_Pedidos")

*!*	*!*	*!*					Select(nOldSele)
*!*	*!*	*!*					Return .F.
*!*	*!*	*!*				**- Trecho de codigo do Else foi inserido para filtrar por CCF
*!*	*!*	*!*				ELSE &&  Andre  Maia 04/05 - inclusao do campo CCF
*!*	*!*	*!*					SELECT xCur_Pedidos
*!*	*!*	*!*					APPEND BLANK
*!*	*!*	*!*					replace fornecedor WITH v_entradas_00.nome_clifor

*!*	*!*	*!*					SELECT xCur_CCF
*!*	*!*	*!*					DELETE ALL
*!*	*!*	*!*					
*!*	*!*	*!*					INSERT INTO xCur_CCF SELECT distinct CCF FROM xCur_Pedidos 
*!*	*!*	*!*					GO TOP IN xcur_pedidos
*!*	*!*	*!*					
*!*	*!*	*!*					** liga o recordsource
*!*	*!*	*!*					**o_005102.lx_form1.lx_pageframe1.page7.lx_pageframe1.page1.lx_pageframe1.page1.lx_grid_filha1.col_TX_PEDIDO.H_TX_PEDIDO.Caption
*!*	*!*	*!*					WITH thisformset.lx_forM1.lx_pageframe1.page7.lx_pageframe1.page1
*!*	*!*	*!*						.Lx_pageframe1.Page1.cmb_ccf.CONTROLSOURCE = 'xcur_ccf.ccf'
*!*	*!*	*!*						.Lx_pageframe1.Page1.cmb_ccf.ROWSOURCE	   = 'xcur_CCF.CCF'
*!*	*!*	*!*						.Lx_pageframe1.Page1.cmb_ccf.visible	   = .t.
*!*	*!*	*!*						.Lx_pageframe1.Page1.cmb_ccf.enabled	   = .t.
*!*	*!*	*!*					Endwith
*!*	*!*	*!*					
*!*	*!*	*!*				EndIf
*!*	*!*	*!*				
*!*	*!*	*!*				If Reccount("xCur_Pedidos") == 0

*!*	*!*	*!*					F_Msg(["Não há pedidos em aberto !", 0+48, "Atenção"])

*!*	*!*	*!*					Select(nOldSele)
*!*	*!*	*!*					Return .F.

*!*	*!*	*!*				EndIf
*!*	*!*	*!*				
*!*	*!*	*!*				Select distinct fornecedor from xcur_pedidos into cursor xcur_pedidos_fornec

*!*	*!*	*!*				Select xCur_Pedidos_Fornec
*!*	*!*	*!*				Locate For FORNECEDOR == v_Entradas_00.NOME_CLIFOR

*!*	*!*	*!*				If ! Found()
*!*	*!*	*!*					F_Msg(["Não existem pedidos para o fornecedor da entrada, será utilizado para filtro um outro fornecedor.", 0+48, "Atenção"])
*!*	*!*	*!*					Go Top
*!*	*!*	*!*				EndIf
*!*	*!*	*!*				
*!*	*!*	*!*			EndIf

*!*	*!*	*!*			With This.Parent.Parent

*!*	*!*	*!*				.Page1.Enabled = .F.
*!*	*!*	*!*				.Page2.Enabled = .F.
*!*	*!*	*!*				.Page3.Enabled = .F.
*!*	*!*	*!*				.Page4.Enabled = .F.
*!*	*!*	*!*				.Page5.Enabled = .F.
*!*	*!*	*!*				.Page6.Enabled = .F.
*!*	*!*	*!*				
*!*	*!*	*!*				With .Page7
*!*	*!*	*!*				
*!*	*!*	*!*					.Enabled           = .T.
*!*	*!*	*!*					.Parent.ActivePage = 7
*!*	*!*	*!*					
*!*	*!*	*!*					If This.Parent.lx_OpcaoSelecao.Value == 2 && Se código de barras
*!*	*!*	*!*					
*!*	*!*	*!*						With .lx_PageFrame1
*!*	*!*	*!*						
*!*	*!*	*!*							.Page1.Enabled                   = .F.
*!*	*!*	*!*							.Page2.Enabled                   = .T.
*!*	*!*	*!*							
*!*	*!*	*!*							.Page2.cmb_Fornecedores.ControlSource = "xcur_pedidos_fornec.FORNECEDOR"
*!*	*!*	*!*							.Page2.cmb_Fornecedores.RowSource     = "xcur_pedidos_fornec.FORNECEDOR"
*!*	*!*	*!*							.Page2.cmb_Fornecedores.Requery()	
*!*	*!*	*!*							.Page2.cmb_Fornecedores.Refresh()	
*!*	*!*	*!*							.Page2.cmb_Fornecedores.l_Desenhista_Recalculo()
*!*	*!*	*!*							
*!*	*!*	*!*							.Page2.cmb_Pedidos.ControlSource = "xCur_Pedidos.PEDIDO"
*!*	*!*	*!*							.Page2.cmb_Pedidos.RowSource     = "xCur_Pedidos.PEDIDO"
*!*	*!*	*!*							.Page2.cmb_Pedidos.Requery()
*!*	*!*	*!*							.Page2.cmb_PEDIDOS.LISTITEMID    = 1
*!*	*!*	*!*							
*!*	*!*	*!*							If Reccount("v_Entradas_00_Prod1_Ent") > 0

*!*	*!*	*!*								.Page2.lx_Importa_CBar1.p_Converte_48_Barra = .T.
*!*	*!*	*!*								.Page2.lx_Importa_CBar1.l_Conv_G48_To_Barra()

*!*	*!*	*!*							EndIf

*!*	*!*	*!*							.Page2.cmb_Pedidos.l_Desenhista_Recalculo()
*!*	*!*	*!*							.ActivePage = 2

*!*	*!*	*!*						EndWith

*!*	*!*	*!*					Else
*!*	*!*	*!*					
*!*	*!*	*!*						With .lx_PageFrame1

*!*	*!*	*!*							.Page1.Enabled = .T.
*!*	*!*	*!*							.Page2.Enabled = .F.
*!*	*!*	*!*							.ActivePage    = 1

*!*	*!*	*!*						EndWith

*!*	*!*	*!*					EndIf
*!*	*!*	*!*					
*!*	*!*	*!*				EndWith

*!*	*!*	*!*			EndWith

*!*	*!*	*!*			Select(nOldSele)
*!*	*!*	*!*			RETURN
*!*	*!*	*!*		ENDPROC
*!*	*!*	*!*		
*!*	*!*	*!*	ENDDEFINE && fim metodo botao1

***
* Botao Seleção da Aba Produtos
* Selecionar por pedido/ccf
* Remove o botao original da tela da Linx e substitui por este botão 
* que tem o merge do codigo novo pós SPK 01.18 com o codigo customizado CAEDU
* PAULO DEVIDE 
* 25/05/2018
** metodo editado service pack 2025
*/
DEFINE CLASS botao1 as botao

	caption = "\<Seleção..."
	fontbold = .t.
	Height = 24
	Left = 590
	Top = 108
	Width = 115
	Forecolor = RGB(0,0,255)
	
	PROCEDURE refresh
		this.Enabled = INLIST(thisformset.p_tool_status,"I","A")
	ENDPROC
	
	
	
	PROCEDURE click
		Local nOldSele, cWhereNF, cWhere, cSQL as String

		=MESSAGEBOX("A [Data de Recebimento] informada na tela  é [" +DTOC(v_Entradas_00.RECEBIMENTO) +"]!",16,"Aviso") 

		if  MESSAGEBOX("Confirma a [Data de Recebimento da NF]  como  " +DTOC(v_Entradas_00.RECEBIMENTO) +"?",32+4+256,"Aviso") == 7

		    =MESSAGEBOX("Por gentileza digite a Data de Recebimento Correta antes de selecionar o pedido !! ",16,"Aviso") 
		    return .T.
		    
		Endif

		nOldSele = Select()

		If ! InList(ThisFormSet.p_Tool_Status, "I", "A") OR v_Entradas_00.NOTA_COMPLEMENTAR

			Select(nOldSele)
			Return

		EndIf

		If ( InList(v_Entradas_00.Tipo_Operacao, "D", "N") OR ( Inlist(v_Entradas_00.CTB_TIPO_OPERACAO, 222) AND v_Entradas_00.TIPO_OPERACAO == "T" ) )

			If this.parent.lx_opcaoselecao.Value = 1
				F_Msg(["Não é possível utilizar a opção de seleção de pedidos em devoluções!", 0+48, "Atenção"])
				Select(nOldSele)
				Return
			Endif 

			If (Type('ThisFormSet.pp_valida_pedido_dig_cod_bar') = "U" or ThisFormSet.pp_valida_pedido_dig_cod_bar)

				F_Msg(["Para utilizar essa opção, ajuste o parâmetro VALIDA_PEDIDO_DIG_COD_BAR.", 0+48, "Atenção"])
				Select(nOldSele)
				Return
				
			Endif 	

		EndIf

		ThisFormSet.px_Zerar_Qtde_Entrada = ( This.Parent.lx_OpcaoSelecao.Value == 2 )   && Se for código de barras

		If F_Vazio(v_Entradas_00.NOME_CLIFOR)

			F_Msg(["Informe o fornecedor para selecionar os pedidos !", 0+48, "Atenção"])
			Select(nOldSele)
			Return .F.

		EndIf

**o_005102.lx_form1.lx_pageframe1.page7.lx_pageframe1.page1.lx_pageframe1.page1.lx_grid_filha1.col_TX_PEDIDO.H_TX_PEDIDO.Caption
*!*			Novos endereços dos componentes		
*!*			ThisForm.Lx_pageframe1.Page7.Lx_pageframe1.Page1.Lx_pageframe1.Page1.cmb_pedidos
*!*			ThisForm.Lx_pageframe1.Page7.Lx_pageframe1.Page2.cmb_pedidos

*!*			With This.Parent.Parent.Page7.lx_PageFrame1.page1.lx_pageframe1

*!*				.Page1.cmb_Fornecedores.ControlSource = ""
*!*				.Page1.cmb_Fornecedores.RowSource     = ""
*!*				.Page1.cmb_PEDIDOS.CONTROLSOURCE	  = ""
*!*				.Page1.cmb_PEDIDOS.ROWSOURCE		  = ""
*!*				
*!*				
*!*				.Page2.cmb_Fornecedores.ControlSource = ""
*!*				.Page2.cmb_Fornecedores.RowSource     = ""
*!*				.Page2.cmb_PEDIDOS.CONTROLSOURCE	  = ""
*!*				.Page2.cmb_PEDIDOS.ROWSOURCE		  = ""	
*!*				
*!*			EndWith

		WITH ThisForm.Lx_pageframe1.Page7.Lx_pageframe1.Page1.Lx_pageframe1.Page1
			.cmb_Fornecedores.ControlSource = ""
			.cmb_Fornecedores.RowSource     = ""
			** PAULO DEVIDE - 21/09/2025 - COMENTARIOS - CUSTOMIZAÇÃO
			** foi necessário incluir fisicamente o componente na tela pois foi retirado no spk 2025
			** trocaram por TV_pedidos e eu deixei o componente novo invisivel
			.cmb_PEDIDOS.CONTROLSOURCE	  = ""
			.cmb_PEDIDOS.ROWSOURCE		  = ""
		ENDWITH 
		** A Page2 se manteve inalterada como estava na versão anterior
		** por este motivo quebrei em dois with..endwith
		WITH ThisForm.Lx_pageframe1.Page7.Lx_pageframe1.Page2
			.cmb_Fornecedores.ControlSource = ""
			.cmb_Fornecedores.RowSource     = ""

			.cmb_PEDIDOS.CONTROLSOURCE	  = ""
			.cmb_PEDIDOS.ROWSOURCE		  = ""
		ENDWITH 

		If Used("xCur_Pedidos")

			Select xCur_Pedidos
			Use

		EndIf

		If Used("xCur_Pedidos_Fornec")

			Select xCur_Pedidos_Fornec
			Use

		EndIf

		**-Trecho de codigo que existia antes do SPK 01.18
		**-If ThisFormSet.px_Bloq_EntPed_NOP
		**-	cWhereNF = " AND ( COMPRAS.NATUREZA_ENTRADA IS NULL OR COMPRAS.NATUREZA_ENTRADA = ?v_Entradas_00.NATUREZA ) "
		**-Else
		**-	cWhereNF = ""
		**-EndIf


		* #76#
		**-Trecho de codigo novo após SPK 01.18 (#76)
		cWhereNF = ""
		If thisformset.lx_FORM1.lx_pageframe1.page6.ck_tipo_operacao.Value = 1 
			cWhereNF = cWhereNF  + " AND (COMPRAS.CTB_Tipo_Operacao = ?v_Entradas_00.CTB_Tipo_Operacao ) "
		Endif

		If thisformset.lx_FORM1.lx_pageframe1.page6.ck_natureza_operazao.Value = 1 
			cWhereNF = cWhereNF + " AND ( COMPRAS.NATUREZA_ENTRADA = ?v_Entradas_00.NATUREZA ) "
		Endif
		* #76#

		cWhere = "RTRIM(COMPRAS.TABELA_FILHA) = 'COMPRAS_PRODUTO' AND " + ;
		         "COMPRAS.TOT_QTDE_ENTREGAR > 0 AND " + ;
		         Iif( Type("ThisFormSet.pp_Controla_Aprovacao_Pedido") == "L" AND ThisFormSet.pp_Controla_Aprovacao_Pedido, ;
		              "COMPRAS.STATUS_APROVACAO = 'A' AND ", ;
		              "" ) + ;
		         "FILIAIS.MATRIZ_FISCAL = ?v_Entradas_00.FILIAL_MATRIZ_FISCAL " + ;
		         cWhereNF

		If wCtrl_Multi_Empresa
			cWhere = cWhere + " AND FILIAIS.EMPRESA = ?wEmpresa_Atual"
		EndIf
		
		** incluido no SPK-2025
		cWhere = cWhere + " AND COMPRAS.FORNECEDOR = ?v_Entradas_00.nome_clifor" && #190# (deve filtrar o FORNECEDOR)

		If Type("ThisFormSet.pp_Valida_Pedido_Dig_Cod_Bar") == "L" AND ! ThisFormSet.pp_Valida_Pedido_Dig_Cod_Bar AND This.Parent.lx_OpcaoSelecao.Value == 2

			*F_Select("SELECT DISTINCT COMPRAS.PEDIDO, COMPRAS.FORNECEDOR, COMPRAS.FILIAL_COBRANCA, SPACE(06) AS COD_FILIAL_COBRANCA " + ;
			*         "FROM COMPRAS " + ;
			*         "WHERE 1 = 0", "xCur_Pedidos")
			** Entrou coluna nova - spk-2025
			F_Select("SELECT DISTINCT COMPRAS.PEDIDO, COMPRAS.PEDIDO_FORNECEDOR, COMPRAS.FORNECEDOR, COMPRAS.FILIAL_COBRANCA, SPACE(06) AS COD_FILIAL_COBRANCA, CONVERT(BIT,1) AS COM_SALDO " + ; && #187#
				 "FROM COMPRAS " + ;
				 "WHERE 1 = 0", "xCur_Pedidos")			         
				 
			Select distinct fornecedor from xcur_pedidos into cursor xcur_pedidos_fornec

		Else

			**-cSQL = "SELECT DISTINCT COMPRAS.PEDIDO, COMPRAS.FORNECEDOR, COMPRAS.FILIAL_COBRANCA, FILIAIS_COBRANCA.COD_FILIAL AS COD_FILIAL_COBRANCA " + ;
			**-       "FROM COMPRAS "
			**- Andre Maia - Inclusão da Coluna CCF da tabela COMPRAS
			**-cSQL = "SELECT DISTINCT COMPRAS.PEDIDO, COMPRAS.FORNECEDOR, COMPRAS.FILIAL_COBRANCA, FILIAIS_COBRANCA.COD_FILIAL AS COD_FILIAL_COBRANCA, " +;
			**-       " ISNULL(compras.erp_cups_processo_ccf_cca, '') as CCF  " + ;
			**-       "FROM COMPRAS "
			**- PAULO DEVIDE - INCLUSAO DA COLUNA COM_SALDO - SPK2025
			TEXT TO cSQL NOSHOW TEXTMERGE PRETEXT 7
				SELECT DISTINCT COMPRAS.PEDIDO, 
					   COMPRAS.PEDIDO_FORNECEDOR, 
					   COMPRAS.FORNECEDOR, 
					   COMPRAS.FILIAL_COBRANCA, 
					   FILIAIS_COBRANCA.COD_FILIAL AS COD_FILIAL_COBRANCA, 
					   CONVERT(BIT,1) AS COM_SALDO, 
					   ISNULL(compras.erp_cups_processo_ccf_cca, '') as CCF
				FROM COMPRAS			
			ENDTEXT

			If Type("ThisFormSet.pp_Filtrar_Limite_Pedido")== "L" AND ThisFormSet.pp_Filtrar_Limite_Pedido
				cSQL = cSQL + "INNER JOIN COMPRAS_PRODUTO ON COMPRAS.PEDIDO = COMPRAS_PRODUTO.PEDIDO AND COMPRAS_PRODUTO.LIMITE_ENTREGA >= ?v_Entradas_00.RECEBIMENTO "
			EndIf
			
			cSQL = cSQL + "INNER JOIN FILIAIS ON COMPRAS.FILIAL_A_ENTREGAR = FILIAIS.FILIAL " + ;
			              "LEFT JOIN FILIAIS AS FILIAIS_COBRANCA ON COMPRAS.FILIAL_COBRANCA = FILIAIS_COBRANCA.FILIAL " + ;
			              "WHERE " + cWhere + " " + ;
			              "ORDER BY COMPRAS.PEDIDO"

			If ! F_Select(cSQL, "xCur_Pedidos")

				Select(nOldSele)
				Return .F.
			**- Trecho de codigo do Else foi inserido para filtrar por CCF
			ELSE &&  Andre  Maia 04/05 - inclusao do campo CCF
				SELECT xCur_Pedidos
				APPEND BLANK
				replace fornecedor WITH v_entradas_00.nome_clifor

				SELECT xCur_CCF
				DELETE ALL
				
				INSERT INTO xCur_CCF SELECT distinct CCF FROM xCur_Pedidos 
				GO TOP IN xcur_pedidos
				
				** liga o recordsource
				**o_005102.lx_form1.lx_pageframe1.page7.lx_pageframe1.page1.lx_pageframe1.page1.lx_grid_filha1.col_TX_PEDIDO.H_TX_PEDIDO.Caption
				WITH thisformset.lx_forM1.lx_pageframe1.page7.lx_pageframe1.page1
					.Lx_pageframe1.Page1.cmb_ccf.CONTROLSOURCE = 'xcur_ccf.ccf'
					.Lx_pageframe1.Page1.cmb_ccf.ROWSOURCE	   = 'xcur_CCF.CCF'
					.Lx_pageframe1.Page1.cmb_ccf.visible	   = .t.
					.Lx_pageframe1.Page1.cmb_ccf.enabled	   = .t.
				Endwith
				
			EndIf
			
			** INCLUIDO NO SPK-2025 --> PAULO DEVIDE - 22-09-2025
			Thisformset.lx_filtrar_saldo_pedido()
			
			If Reccount("xCur_Pedidos") == 0

				F_Msg(["Não há pedidos em aberto !", 0+48, "Atenção"])

				Select(nOldSele)
				Return .F.

			EndIf
			
			Select distinct fornecedor from xcur_pedidos into cursor xcur_pedidos_fornec

			Select xCur_Pedidos_Fornec
			Locate For FORNECEDOR == v_Entradas_00.NOME_CLIFOR

			If ! Found()
				F_Msg(["Não existem pedidos para o fornecedor da entrada, será utilizado para filtro um outro fornecedor.", 0+48, "Atenção"])
				Go Top
			EndIf
			
		EndIf

		With This.Parent.Parent

			.Page1.Enabled = .F.
			.Page2.Enabled = .F.
			.Page3.Enabled = .F.
			.Page4.Enabled = .F.
			.Page5.Enabled = .F.
			.Page6.Enabled = .F.
			
			With .Page7
			
				.Enabled           = .T.
				.Parent.ActivePage = 7
				
				If This.Parent.lx_OpcaoSelecao.Value == 2 && Se código de barras
				
					With .lx_PageFrame1
					
						.Page1.Enabled                   = .F.
						.Page2.Enabled                   = .T.
						
						.Page2.cmb_Fornecedores.ControlSource = "xcur_pedidos_fornec.FORNECEDOR"
						.Page2.cmb_Fornecedores.RowSource     = "xcur_pedidos_fornec.FORNECEDOR"
						.Page2.cmb_Fornecedores.Requery()	
						.Page2.cmb_Fornecedores.Refresh()	
						.Page2.cmb_Fornecedores.l_Desenhista_Recalculo()
						
						.Page2.cmb_Pedidos.ControlSource = "xCur_Pedidos.PEDIDO"
						.Page2.cmb_Pedidos.RowSource     = "xCur_Pedidos.PEDIDO"
						.Page2.cmb_Pedidos.Requery()
						.Page2.cmb_PEDIDOS.LISTITEMID    = 1
						
						If Reccount("v_Entradas_00_Prod1_Ent") > 0

							.Page2.lx_Importa_CBar1.p_Converte_48_Barra = .T.
							.Page2.lx_Importa_CBar1.l_Conv_G48_To_Barra()

						EndIf
						** TRECHO COMENTADO PELA LINX - SPK-2025 - PAULO DEVIDE
						**.Page2.cmb_Pedidos.l_Desenhista_Recalculo()

						
						.ActivePage = 2

					EndWith

				Else
				
					With .lx_PageFrame1

						.Page1.Enabled = .T.
						.Page2.Enabled = .F.
						.ActivePage    = 1

					EndWith

				EndIf
				
			EndWith

		EndWith

		Select(nOldSele)
		RETURN
	ENDPROC
	
ENDDEFINE

***   codigo botao selecionar por pedido/ccf - aba (produtos)                                                                                                                                                                                                           ***
**=========================================================================================================**
***   

***   codigo botao selecionar por pedido/ccf - aba (produtos)                                                                                                                                                                                                           ***
**=========================================================================================================**
***                                                                                                                                                                                                                                                                                                                      ***


****
** OBJETOS CUSTOMIZADOS (NOSHOW - ABA SELEÇÃO)
****
DEFINE CLASS  Lx_label6 as Lx_Label
	autosize = .f.
	caption = "Limite de Entrega"
	Height = 15
	Left = 3
	Top = 85
	Width = 87
	p_muda_size = .f.
	Name = "Lx_label6"
ENDDEFINE

DEFINE CLASS Lx_limite_entrega as Lx_textbox_base
	controlsource = "v_compras_01_produtos.limite_entrega"
	FontBold = .t.
	Height = 20
	Left = 94
	Name = "Lx_limite_entrega"
	Top = 82
	Width = 118
	p_bloqueia_na_alteracao = .T.
	p_tipo_dado = "MOSTRA"
ENDDEFINE 

DEFINE CLASS  Lx_label5 as Lx_Label
	autosize = .f.
	caption = "Semanas Atraso (Portal)"
	Height = 15
	Left = 215
	Top = 85
	Width = 118
	p_muda_size = .f.
	Name = "Lx_label5"
ENDDEFINE

DEFINE CLASS Lx_Semana_Atraso as Lx_textbox_base
	controlsource = "v_compras_01.quantidade_agendamento"
	FontBold = .t.
	Height = 20
	Left = 334
	Name = "Lx_Semana_Atraso"
	Top = 82
	Width = 45
	p_bloqueia_na_alteracao = .T.
	p_tipo_dado = "MOSTRA"
ENDDEFINE 

DEFINE CLASS  Lx_label7 as Lx_Label
	autosize = .f.
	caption = "Semanas Atraso Calc"
	Height = 15
	Left = 383
	Top = 85
	Width = 103
	p_muda_size = .f.
	Name = "Lx_label7"
ENDDEFINE

DEFINE CLASS Lx_limite_calc as Lx_textbox_base
	FontBold = .t.
	Height = 20
	Left = 488
	Name = "Lx_limite_calc"
	Top = 82
	Width = 31
	p_bloqueia_na_alteracao = .T.
	p_tipo_dado = "MOSTRA"
ENDDEFINE 

DEFINE CLASS  Lx_label2 as Lx_Label
	autosize = .f.
	caption = "Desconto  Digitado"
	Height = 15
	Left = 511
	Top = 85
	Width = 103
	p_muda_size = .f.
	Name = "Lx_label2"
ENDDEFINE

DEFINE CLASS Lx_Desconto_Digitado as Lx_textbox_base
	controlsource = "v_compras_01.desconto"
	FontBold = .t.
	InputMask = "999 999 999.99"
	Height = 20
	Left = 615
	Name = "Lx_Desconto_Digitado"
	Top = 82
	Width = 97
	p_bloqueia_na_alteracao = .T.
	p_tipo_dado = "MOSTRA"
ENDDEFINE 


