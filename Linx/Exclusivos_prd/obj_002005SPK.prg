*****
* OBJETO DE ENTRADA OBJ_002005SPK
* CADASTRO DE GRIFFES
* PAULO DEVIDE - 01-10-2025
*/
define class obj_entrada as custom
	procedure metodo_usuario
		lparam xmetodo, xobjeto ,xnome_obj
		DO CASE
			CASE UPPER(xmetodo) == 'USR_INIT'
				WAIT WINDOW 'OBJ' NOWAIT

				***
				* Modifica o cursor adapter de clientes - inclui coluna nova sem precisar alterar dentro do formulário
				*
				************************************************************************************************************
				strInitAlias = ALIAS()	
				***
				*** Carrega cursor v_clientes_01 (CURSORV_CLIENTES_01)
				***
				carrega_ca_v_produtos_grifes_00 (thisformset)
				SELECT (strInitAlias)
				************************************************************************************************************

				IF "CUPS" $ SET( "ClassLib" )
					** Ok, Registry carregado
				ELSE
					SET CLASSLIB TO CUPS.vcx ADDITIVE
				ENDIF
				
				thisformset.lx_form1.minbutton=.f.
				thisformset.lx_form1.maxbutton=.f.								
				
				WITH thisformset.lx_form1
					.width = 877
					.Lx_TitleBar.Width=877
					.Lx_frame_3d1.Width = 870
*!*						.label_GRIFFE.Left = 0
*!*						.tx_COD_GRIFFE.Left = 85
*!*						.tx_GRIFFE.Left = 112
					.addobject("lbl_Descricao1","label")
					.lbl_descricao1.left = 540
					.lbl_descricao1.caption = "Desc.Importado"
					.lbl_descricao1.autosize=.t.
					.lbl_descricao1.top = .label_GRIFFE.top
					.lbl_descricao1.visible=.t.					

					.addobject("txt_Griffe_Desc_Importado1","txt_Griffe_Desc_Importado")
					.txt_Griffe_Desc_Importado1.left = .lbl_descricao1.left + .lbl_descricao1.width + 10
					.txt_Griffe_Desc_Importado1.top = .label_GRIFFE.top - 3
					.txt_Griffe_Desc_Importado1.ControlSource = "v_produtos_grifes_00.ERP_CUPS_DESCRICAO_IMPORTACAO"
					.txt_Griffe_Desc_Importado1.width = 220
					.txt_Griffe_Desc_Importado1.visible=.t.					
					
				ENDWITH
				
				thisformset.l_limpa()

			CASE UPPER(xmetodo) == 'USR_SAVE_BEFORE'
			OTHERWISE
				RETURN .t.
		ENDCASE
	ENDPROC
ENDDEFINE

FUNCTION carrega_ca_v_produtos_grifes_00 
***
* CURSOR ADAPTER: v_produtos_grifes_00 (cur_v_produtos_grifes_00)
* Paulo Devide => 25/04/18
*
PARAMETERS oThisformset
With oThisformset.dataenvironment
	if Type(".cur_v_produtos_grifes_00")="O"
		*AddNewObject(oThisformset.dataenvironment, "cur_v_produtos_grifes_00","ccursoradapter")
		
		SELECT v_produtos_grifes_00
		oCursor = GETCURSORADAPTER("v_produtos_grifes_00")
		** Instruções:
		**oCursor.AddBufferField("tabela.nome_da_coluna", "Tipo",  <atualizavel>, "caption", "tabela.nome_coluna")
		**
		oCursor.AddBufferField("produtos_griffes.erp_cups_descricao_importacao", "C(50)",.T.,"erp_cups_descricao_importacao","produtos_griffes.erp_cups_descricao_importacao")
		oCursor.confirmStructureChanges()
		
		.cur_v_produtos_grifes_00.DataSourceType ="ADO"

		***
		*** SelectCmd 
		***
		TEXT TO  .cur_v_produtos_grifes_00.SelectCmd NOSHOW TEXTMERGE PRETEXT 7
			SELECT produtos_griffes.cod_griffe, 
			       produtos_griffes.griffe, 
			       produtos_griffes.licenciado, 
			       produtos_griffes.licenciador, 
			       produtos_griffes.royalties, 
			       produtos_griffes.inativo, 
			       produtos_griffes.valor_minimo_pedido, 
			       produtos_griffes.recebimento AS CAPACIDADE, 
			       produtos_griffes.rateio_filial, 
			       ctb_filial_rateio.desc_rateio_filial, 
			       produtos_griffes.rateio_centro_custo, 
			       ctb_centro_custo_rateio.desc_rateio_centro_custo,
			       produtos_griffes.erp_cups_descricao_importacao
			FROM   produtos_griffes PRODUTOS_GRIFFES 
			       LEFT JOIN ctb_filial_rateio CTB_FILIAL_RATEIO 
				      ON ctb_filial_rateio.rateio_filial = 
					 produtos_griffes.rateio_filial 
			       LEFT JOIN ctb_centro_custo_rateio CTB_CENTRO_CUSTO_RATEIO 
				      ON ctb_centro_custo_rateio.rateio_centro_custo = 
					 produtos_griffes.rateio_centro_custo 
			ORDER  BY produtos_griffes.griffe 
		ENDTEXT

		***
		*** CursorSchema 
		***
		TEXT TO  .cur_v_produtos_grifes_00.CursorSchema NOSHOW TEXTMERGE PRETEXT 7
			COD_GRIFFE C(2), GRIFFE C(25), LICENCIADO C(25), LICENCIADOR C(25), ROYALTIES N(10,5), 
			INATIVO L, VALOR_MINIMO_PEDIDO N(16,2), CAPACIDADE N(11,3), 
			RATEIO_FILIAL C(15), DESC_RATEIO_FILIAL C(40), RATEIO_CENTRO_CUSTO C(15), 
			DESC_RATEIO_CENTRO_CUSTO C(40), ERP_CUPS_DESCRICAO_IMPORTACAO C(50)  
		ENDTEXT

		***
		*** UpdateNameList 
		***
		TEXT TO  .cur_v_produtos_grifes_00.UpdateNameList NOSHOW TEXTMERGE PRETEXT 7
			COD_GRIFFE PRODUTOS_GRIFFES.COD_GRIFFE, GRIFFE PRODUTOS_GRIFFES.GRIFFE, 
			LICENCIADO PRODUTOS_GRIFFES.LICENCIADO, LICENCIADOR 
			PRODUTOS_GRIFFES.LICENCIADOR, ROYALTIES PRODUTOS_GRIFFES.ROYALTIES, INATIVO 
			PRODUTOS_GRIFFES.INATIVO, VALOR_MINIMO_PEDIDO 
			PRODUTOS_GRIFFES.VALOR_MINIMO_PEDIDO, CAPACIDADE PRODUTOS_GRIFFES.RECEBIMENTO, 
			RATEIO_FILIAL PRODUTOS_GRIFFES.RATEIO_FILIAL, RATEIO_CENTRO_CUSTO 
			PRODUTOS_GRIFFES.RATEIO_CENTRO_CUSTO,
			ERP_CUPS_DESCRICAO_IMPORTACAO PRODUTOS_GRIFFES.ERP_CUPS_DESCRICAO_IMPORTACAO
		ENDTEXT

		***
		*** UpdatableFieldList 
		***
		TEXT TO  .cur_v_produtos_grifes_00.UpdatableFieldList NOSHOW TEXTMERGE PRETEXT 7
			COD_GRIFFE, GRIFFE, LICENCIADO, LICENCIADOR, ROYALTIES, INATIVO, VALOR_MINIMO_PEDIDO, CAPACIDADE, 
			RATEIO_FILIAL, RATEIO_CENTRO_CUSTO, ERP_CUPS_DESCRICAO_IMPORTACAO
		ENDTEXT

		***
		*** Tables
		***
		 .cur_v_produtos_grifes_00.Tables = "PRODUTOS_GRIFFES"

		***
		*** KeyFieldList
		***
		 .cur_v_produtos_grifes_00.KeyFieldList= "GRIFFE"

		***
		*** QueryList
		***
		TEXT TO  .cur_v_produtos_grifes_00.QueryList NOSHOW TEXTMERGE PRETEXT 7
			COD_GRIFFE PRODUTOS_GRIFFES.COD_GRIFFE, GRIFFE PRODUTOS_GRIFFES.GRIFFE, LICENCIADO PRODUTOS_GRIFFES.LICENCIADO, LICENCIADOR PRODUTOS_GRIFFES.LICENCIADOR, ROYALTIES PRODUTOS_GRIFFES.ROYALTIES, INATIVO PRODUTOS_GRIFFES.INATIVO, VALOR_MINIMO_PEDIDO PRODUTOS_GRIFFES.VALOR_MINIMO_PEDIDO, CAPACIDADE PRODUTOS_GRIFFES.RECEBIMENTO, RATEIO_FILIAL PRODUTOS_GRIFFES.RATEIO_FILIAL, DESC_RATEIO_FILIAL CTB_FILIAL_RATEIO.DESC_RATEIO_FILIAL, RATEIO_CENTRO_CUSTO PRODUTOS_GRIFFES.RATEIO_CENTRO_CUSTO, DESC_RATEIO_CENTRO_CUSTO CTB_CENTRO_CUSTO_RATEIO.DESC_RATEIO_CENTRO_CUSTO
		ENDTEXT

		***
		*** CaptionList
		***
		TEXT TO  .cur_v_produtos_grifes_00.CaptionList NOSHOW TEXTMERGE PRETEXT 7
			COD_GRIFFE Cod Griffe, GRIFFE Griffe, LICENCIADO Licenciado, LICENCIADOR Licenciador, ROYALTIES Royalties, INATIVO Inativo, VALOR_MINIMO_PEDIDO Valor Minimo Pedido, CAPACIDADE Capacidade, RATEIO_FILIAL Rateio Filial, DESC_RATEIO_FILIAL Desc Rateio Filial, RATEIO_CENTRO_CUSTO Rateio Centro Custo, DESC_RATEIO_CENTRO_CUSTO Desc Rateio Centro Custo
		ENDTEXT

		***
		*** DefaultsValuesList
		***
		TEXT TO  .cur_v_produtos_grifes_00.DefaultsValuesList NOSHOW TEXTMERGE PRETEXT 7
			
		ENDTEXT

		***
		*** FTableList
		***
		TEXT TO  .cur_v_produtos_grifes_00.FTableList NOSHOW TEXTMERGE PRETEXT 7
			FORNECEDORES
		ENDTEXT

		***
		*** Alias
		***
		 *.cur_v_produtos_grifes_00.Alias = "v_produtos_grifes_00"

		***
		*** ParentCursor
		***
		 .cur_v_produtos_grifes_00.ParentCursor = ""
		***
		*** BufferModeOverride
		***
		.cur_v_produtos_grifes_00.BufferModeOverride	=5
		***
		*** NoDataOnLoad
		***
		.cur_v_produtos_grifes_00.NoDataOnLoad		=.T.
		***
		*** IsUpdateCursor
		***
		.cur_v_produtos_grifes_00.IsUpdateCursor		=.T.
		***
		*** IsMaster
		***
		.cur_v_produtos_grifes_00.IsMaster		        =.T.
		***
		*** UpdateType
		***
		.cur_v_produtos_grifes_00.UpdateType			=1
		***
		*** WhereType
		***
		.cur_v_produtos_grifes_00.WhereType			=3
		***
		*** FetchMemo
		***
		.cur_v_produtos_grifes_00.FetchMemo			=.T.
		***
		*** SendUpdates
		***
		.cur_v_produtos_grifes_00.SendUpdates		=.F.
		***
		*** UseMemoSize
		***
		.cur_v_produtos_grifes_00.UseMemoSize		=255
		***
		*** FetchSize
		***
		.cur_v_produtos_grifes_00.FetchSize			=-1
		***
		*** MaxRecords
		***
		.cur_v_produtos_grifes_00.MaxRecords			=-1
		***
		*** Prepared
		***
		.cur_v_produtos_grifes_00.Prepared			=.F.
		***
		*** CompareMemo
		***
		.cur_v_produtos_grifes_00.CompareMemo		=.F.
		***
		*** BatchUpdateCount
		***
		.cur_v_produtos_grifes_00.BatchUpdateCount	=1
		***
		*** OpenCursor()
		***
		.cur_v_produtos_grifes_00.OpenCursor()
	EndIf

ENDWITH
ENDFUNC
