Define Class Obj_Entrada as Custom

   Procedure Metodo_Usuario
   
      Lparameters cMetodo, oObjeto, cNome_Obj
      
      DO Case
         Case Upper(Alltrim(cMetodo)) == 'USR_INIT'
         
*!*	         	f_select("select DISTINCT NOME_CONTAGEM  from ESTOQUE_PROD_CONTAGEM a "+;
*!*				"left join faturamento b on a.nome_contagem = b.conferido_por "+;
*!*				"where A.estoque_Ajustado = 1 and b.NF_SAIDA IS NULL", 'CurInventarios')


            ThisFormSet.lx_Form1.lx_pageframe1.page3.AddObject('cmbInventarios', 'cmbInventarios')
            ThisFormSet.lx_Form1.lx_pageframe1.page3.cmbInventarios.enabled = .f.
            ThisFormSet.lx_Form1.lx_pageframe1.page3.cmbInventarios.visible = .t.
            ThisFormSet.lx_Form1.lx_pageframe1.page3.cmbInventarios.rowsourcetype = 3
            ThisFormSet.lx_Form1.lx_pageframe1.page3.cmbInventarios.rowsource = [f_select("select distinct nome_contagem from vw_inventarios order by nome_contagem ", 'CurInventarios')]
																						
            ThisFormSet.lx_Form1.lx_pageframe1.page3.AddObject('lblInventarios', 'lblInventarios')
            ThisFormSet.lx_Form1.lx_pageframe1.page3.lblInventarios.enabled = .f.
            ThisFormSet.lx_Form1.lx_pageframe1.page3.lblInventarios.visible = .t.
            
            ThisFormSet.lx_Form1.lx_pageframe1.page3.AddObject('btnInventarios', 'btnInventarios')
            ThisFormSet.lx_Form1.lx_pageframe1.page3.btnInventarios.enabled = .f.
            ThisFormSet.lx_Form1.lx_pageframe1.page3.btnInventarios.visible = .t.
            
            *** CUSTOMIZAÇÃO CAEDU *** 24-07-2019
            ThisFormSet.lx_form1.lx_pageframe1.page3.AddObject("botao_itens1","botao_itens")
			ThisFormSet.lx_form1.lx_pageframe1.page3.botao_itens1.Visible= .T.
			ThisFormSet.lx_form1.lx_pageframe1.page3.botao_itens1.left = 252
			ThisFormSet.lx_form1.lx_pageframe1.page3.botao_itens1.Width=140
			ThisFormSet.lx_form1.lx_pageframe1.page3.botao_itens1.Caption = "Importar TXT"
			ThisFormSet.lx_form1.lx_pageframe1.page3.botao_itens1.top = 50
            ***
            Return .T.

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
					WAIT WINDOW NOWAIT "exclusão desabilitada - nota integrada" 
					o_toolbar.botao_exclui.Enabled= .f.
					o_toolbar.botao_altera.enabled =.f.
				ENDIF
				
				SELECT (lcAlias)
				
			ENDIF         

            If Type('ThisFormSet.lx_Form1.lx_pageframe1.page3.cmbInventarios') == 'O'
               ThisFormSet.lx_Form1.lx_pageframe1.page3.cmbInventarios.enabled = ( ThisFormSet.p_Tool_Status $ 'IA' )
            ENDIF
            
            If Type('ThisFormSet.lx_Form1.lx_pageframe1.page3.btnInventarios') == 'O'
               ThisFormSet.lx_Form1.lx_pageframe1.page3.btnInventarios.enabled = ( ThisFormSet.p_Tool_Status $ 'IA' )
            EndIf

			Return .T.
		
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
				WAIT WINDOW NOWAIT "exclusão desabilitada - nota integrada" 
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
					WAIT WINDOW NOWAIT "exclusão desabilitada - nota integrada" 
					MESSAGEBOX('Nota Integrada, nao e possivel a exclusao!', 16, wusuario)
					RETURN .F.

				ENDIF
				
				SELECT (lcAlias)
			endif			
        
        Otherwise

            Return .T.

      EndCase

   EndProc

EndDefine

DEFINE CLASS cmbInventarios AS combobox

	Top = 32
	Left = 730
	Height = 24
	Width = 150
	FontName = "Tahoma"
	FontSize = 8
	Name = "cmbInventarios"
	style = 2
	
ENDDEFINE 	

DEFINE CLASS lblInventarios AS label

	Top = 20
	Left = 730
	Height = 24
	Width = 150
	FontName = "Tahoma"
	FontSize = 8
	Name = "cmbInventarios"
	Caption = "Ajustes"
	backstyle = 0
	
ENDDEFINE 	

DEFINE CLASS btnInventarios AS botao

	Top = 60
	Left = 730
	Height = 24
	Width = 150
	FontName = "Tahoma"
	FontSize = 8
	Name = "cmbInventarios "
	Caption = "Processa"

	
	PROCEDURE click 
		LOCAL strAjuste, vll_completo 
		STORE .t. TO vll_completo 
		strAjuste =  ThisFormSet.lx_Form1.lx_pageframe1.page3.cmbInventarios.value
		IF !EMPTY(ALLTRIM(ThisFormSet.lx_Form1.lx_pageframe1.page3.cmbInventarios.value)) AND EMPTY(ALLTRIM(NVL(v_faturamento_05.conferido_por,'')))
			thisformset.p_item_impressao = 0
			ThisFormset.px_tabela_preco = '00'
			ThisFormSet.lx_Form1.lx_pageframe1.page3.lx_container1.ck_produtos.value = .T.
			f_select("select nome_contagem, produto, qtde  from vw_inventarios a "+;
					"where nome_Contagem = '"+alltr(strAjuste)+"' ",'vtmp_inventario')
			
			f_select("select a.produto from vw_inventarios a join produtos b on a.produto = b.produto "+;
					"where a.nome_Contagem = '"+alltr(strAjuste)+"' and b.inativo = 1 ",'vtmp_inativos')
			IF RECCOUNT('vtmp_inativos') > 0
				IF MESSAGEBOX('Existem produtos inativos neste inventario. Deseja ativa-los para continuar?',36,'Atencao') = 6
					f_wait('Ativando produtos...')
					SELECT vtmp_inativos
					SCAN
						f_update("update produtos set inativo = 0 where produto = '"+alltr(vtmp_inativos.produto)+"'")
					ENDSCAN 
				ELSE
					RETURN .f.
				ENDIF 
			ENDIF  
			ThisFormSet.lx_Form1.lockscreen = .t.
			SELECT vtmp_inventario
			SCAN
				IF thisformset.p_item_impressao < 840
					Messagebox.ShowProgress( "Importando Produtos ("+ALLTRIM(vtmp_inventario.produto)+") de Inventario " + Alltrim(Str(RECNO('vtmp_inventario')))+"/"+Alltrim(Str(RECCOUNT('vtmp_inventario')))) 
					thisformset.p_filha_Atual = 'V_FATURAMENTO_05_ITEM'
					thisformset.l_filhas_inclui()
					ThisFormSet.lx_Form1.lx_pageframe1.page3.lx_grid_filha1.col_tx_codigo_item.tx_codigo_item.value = ALLTRIM(vtmp_inventario.produto)
					ThisFormSet.lx_Form1.lx_pageframe1.page3.lx_grid_filha1.col_tx_codigo_item.tx_codigo_item.l_desenhista_recalculo()
					ThisFormSet.lx_Form1.lx_pageframe1.page3.lx_grid_filha1.col_tx_qtde_item.tx_qtde_item.value = ABS(vtmp_inventario.qtde)
					ThisFormSet.lx_Form1.lx_pageframe1.page3.lx_grid_filha1.col_tx_qtde_item.tx_qtde_item.l_desenhista_recalculo()
				ELSE
					vll_completo = .f.					
				ENDIF 
				SELECT vtmp_inventario
			ENDSCAN 		
			SELECT v_faturamento_05
			replace v_faturamento_05.conferido_por WITH strAjuste
			ThisFormSet.lx_Form1.lockscreen = .f.
			ThisFormSet.lx_Form1.lx_pageframe1.page3.btnInventarios.enabled = .f.
			ThisFormSet.lx_Form1.lx_pageframe1.page3.cmbInventarios.enabled = .f.
			IF USED('vtmp_inativos')
				SELECT vtmp_inativos
				SCAN
					f_update("update produtos set inativo = 1 where produto = '"+alltr(vtmp_inativos.produto)+"'")
				ENDSCAN
			ENDIF 
			f_wait()
			IF !vll_completo 
				MESSAGEBOX('Será necessario a geração de outra nota com o restante de produtos do Inventario',64,'Atencao')
			ENDIF 
		ENDIF 		
	ENDPROC 
	
ENDDEFINE 	

DEFINE CLASS botao_itens AS botao

	left = 252
	Width=140
	Caption = "Importar TXT"
	top = 50

	PROCEDURE click
		*** importa arquivo itens de estoque ***
		*** layout
		
		*arq produto    cor      sku              descricao do produto               desc. cor  qtd custo
		*1;"I1010002";"00206";"I10100020020605";"CALCA FEM CT 56291 JNS CIG.BLACK";"JEANS BLACK";2;36,30
		
		lxArq = GETFILE("TXT","Selecione o Arquivo", "Selecione",0,"Seleção de Arquivo TXT")
		
		IF EMPTY(lxArq)
			MESSAGEBOX("Processo cancelado pelo usuário!", 64, "Aviso")
			RETURN 
		ENDIF

		IF USED("VESTOQUE1")
			SELECT VESTOQUE1 
			USE
		ENDIF
		
		CREATE CURSOR VESTOQUE1 (;
		ARQUIVO	 INT NULL,;
		produto	 C(8) NULL,;
		cor		 C(5) NULL,;
		sku		 C(16) NULL,;
		desc_produto C(40) NULL,;	
		cor_produto	 C(40) NULL,;
		qtde 	 INT NULL,;	
		custo 	 N(10,2) NULL)

		SELECT VESTOQUE1 
		APPEND FROM (lxArq) DELIMITED WITH CHARACTER ";"
		GO TOP
		lcTotReg = ALLTRIM(TRANSFORM(RECCOUNT("VESTOQUE1"),"999999"))		
		SCAN 
			
			lcMsg1 = "Aguarde processando item "+ALLTRIM(TRANSFORM(RECNO("VESTOQUE1"),"999999"))+"/"+lcTotReg 

			f_wait(lcMsg1)
			
			F_SELECT("SELECT * FROM PRODUTOS WHERE PRODUTO = ?VESTOQUE1.PRODUTO","VINFO_PRODUTO")
			
			SELECT V_FATURAMENTO_05_ITEM
			APPEND BLANK
			
			replace numero_imobilizado           with ""
			replace filial                       with ""
			replace nf_saida                     with ""
			replace serie_nf                     with ""
			replace item_impressao               with PADL(RECNO("VESTOQUE1"),4,"0")
			replace sub_item_tamanho             with 0
			replace descricao_item               with VINFO_PRODUTO.DESC_PRODUTO
			replace qtde_item                    with VESTOQUE1.QTDE
			replace codigo_item                  with VESTOQUE1.PRODUTO
			replace cod_tabela_filha             with "R"
			replace tribut_icms                  with "41"
			replace tribut_origem                with "0"
			replace unidade                      with "PC"
			replace valor_item                   with VESTOQUE1.CUSTO
			replace classif_fiscal               with VINFO_PRODUTO.CLASSIF_FISCAL
			replace preco_unitario               with VESTOQUE1.CUSTO
			replace porcentagem_item_rateio      with 0
			replace codigo_fiscal_operacao       with "5927"
			replace desconto_item                with 0
			replace peso                         with 1
			replace conta_contabil               with "114.01.005"
			replace qtde_retornar_beneficiamento with 0
			replace mpadrao_preco_unitario       with VESTOQUE1.CUSTO
			replace mpadrao_desconto_item        with 0
			replace mpadrao_valor_item           with VESTOQUE1.CUSTO * VESTOQUE1.QTDE
			replace faixa                        with "1"
			replace comissao_item                with 0
			replace comissao_item_gerente        with 0
			replace indicador_cfop               with 11
			replace qtde_devolvida               with 0
			replace id_excecao_imposto           with 1507
			replace referencia                   with VESTOQUE1.PRODUTO
			replace referencia_item              with ""
			replace referencia_pedido            with ""
			replace descricao_indicador_cfop with ""
			replace tribut_origem_descricao with ""
			replace tribut_icms_descricao with ""
			replace GERAR_IMPOSTO with .T.
			replace mpadrao_valor_encargos with 0
			replace mpadrao_valor_descontos with 0
			replace nao_soma_valor with .F.
			replace possui_subs_tributaria with .F.
			replace porc_desconto_item with 0
			replace preco_bruto with VESTOQUE1.CUSTO
			replace mpadrao_preco_bruto with VESTOQUE1.CUSTO
			replace obs_item with ""
			replace item_fiscal_grupo with ""
			replace desc_item_fiscal_grupo with ""
			replace item_nfe with 0
			replace nao_fatura with .F.
			replace mpadrao_seguro_item with 0
			replace mpadrao_frete_item with 0
			replace mpadrao_encargo_item with 0
			replace rateio_filial with ""
			replace rateio_centro_custo with ""
			replace desc_rateio_filial with ""
			replace desc_rateio_centro_custo with ""
			replace origem_item with "P"
			replace valor_imposto_item with 0
			replace preco_unitario_original with VESTOQUE1.CUSTO
			replace codigo_fci with NULL
			replace id_sub_projeto with NULL
			replace nome_sub_projeto with NULL
			replace tipo_item_sped with ""
			replace valor_imposto_item_municipal with 0
			replace valor_imposto_item_estadual with 0
			replace id_cest_ncm with NULL
			replace codigo_cest with NULL
			replace descricao with NULL
			
			SELECT VESTOQUE1
			
		ENDSCAN
		SELECT V_FATURAMENTO_05_ITEM
		GO TOP
		f_wait()
		
	ENDPROC
	
ENDDEFINE
