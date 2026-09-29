***/
* OBJETO DE ENTRADA DA TELA ENTRADAS DE NOTAS FISCAIS DE CONSUMÍVEIS
* 28-04-2021
*
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

					lcAlias = SELECT() &&ALIAS()
					
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
				lcAlias = SELECT() &&ALIAS()
				
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

				
			Case Upper(xmetodo) == 'USR_SAVE_BEFORE'
				IF !(ThisFormSet.p_Tool_Status $ "IA")
					lcAlias = SELECT() &&ALIAS()
				
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
			

			OTHERWISE

				RETURN .T.

		endcase

	endproc

enddefine


