Define Class Obj_Entrada as Custom

	Procedure Metodo_Usuario

		Lparameters cMetodo, oObjeto, cNome_Obj

		DO Case
			Case Upper(Alltrim(cMetodo)) == 'USR_INIT'

				*!*	         	f_select("select DISTINCT NOME_CONTAGEM  from ESTOQUE_PROD_CONTAGEM a "+;
				*!*				"left join faturamento b on a.nome_contagem = b.conferido_por "+;
				*!*				"where A.estoque_Ajustado = 1 and b.NF_SAIDA IS NULL", 'CurInventarios')

				oCursor = GETCURSORADAPTER("V_FATURAMENTO_05_IMPOSTO")
				** Instruções:
				**oCursor.AddBufferField("tabela.nome_da_coluna", "Tipo",  <atualizavel>, "caption", "tabela.nome_coluna")
				**
				oCursor.AddBufferField("FATURAMENTO_IMPOSTO.BASE_REGULAR","N(14,2)",.T.,"BASE_REGULAR","FATURAMENTO_IMPOSTO.BASE_REGULAR")
				oCursor.AddBufferField("FATURAMENTO_IMPOSTO.ALIQ_REGULAR","N(8,5)",.T.,"ALIQ_REGULAR","FATURAMENTO_IMPOSTO.ALIQ_REGULAR")
				oCursor.AddBufferField("FATURAMENTO_IMPOSTO.VALOR_REGULAR","N(14,2)",.T.,"VALOR_REGULAR","FATURAMENTO_IMPOSTO.VALOR_REGULAR")
				**
				oCursor.confirmStructureChanges()


				*ThisFormSet.lx_Form1.Width = 913
				ADDPROPERTY(thisformset, "px_fatura_caixa_auto", .T.) 
				
				WITH ThisFormSet.lx_Form1
					.AddObject("lx_label1","lx_label1")
					.lx_label1.visible =.t.
					.AddObject("cmbDoca","cmbDoca")
					.cmbDoca.visible =.t.					
					.AddObject("btnDocaOk","btnDocaOk")
					.btnDocaOk.visible =.t.					
					.AddObject("ck_fatura_caixa_fechada","ck_fatura_caixa_fechada")
					.ck_fatura_caixa_fechada.visible =.t.					
					.AddObject("lx_label4","lx_label4")
					.lx_label4.visible =.t.					
					.AddObject("edCaixas","edCaixas")
					.edCaixas.visible =.t.					
				ENDWITH 
				
*!*					thisformset.Lx_Form1.l_resize()
				
				Return .T.

			Case Upper(Alltrim(cMetodo)) == 'USR_REFRESH'

*!*					If Type('ThisFormSet.lx_Form1.lx_pageframe1.page3.cmbInventarios') == 'O'
*!*						ThisFormSet.lx_Form1.lx_pageframe1.page3.cmbInventarios.enabled = ( ThisFormSet.p_Tool_Status $ 'IA' )
*!*					ENDIF

*!*					If Type('ThisFormSet.lx_Form1.lx_pageframe1.page3.btnInventarios') == 'O'
*!*						ThisFormSet.lx_Form1.lx_pageframe1.page3.btnInventarios.enabled = ( ThisFormSet.p_Tool_Status $ 'IA' )
*!*					EndIf

*!*					Return .T.

				*!*			CASE UPPER(cMetodo) == 'USR_INCLUDE_AFTER'
				*!*				IF USED('CurInventarios')
				*!*					SELECT CurInventarios
				*!*					USE
				*!*				ENDIF
				*!*				ThisFormSet.lx_Form1.lx_pageframe1.page3.cmbInventarios.rowsource = ''
				*!*	         	f_select("select DISTINCT NOME_CONTAGEM  from ESTOQUE_PROD_CONTAGEM a "+;
				*!*						"left join faturamento b on a.nome_contagem = b.conferido_por "+;
				*!*						"where A.estoque_Ajustado = 1 and b.NF_SAIDA IS NULL", 'CurInventarios')
				*!*				ThisFormSet.lx_Form1.lx_pageframe1.page3.cmbInventarios.rowsource = 'CurInventarios'


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

DEFINE CLASS Lx_Label1 as Lx_label
	Alignment = 0
	Autosize = .f.
	Caption = "Doca:"
	FontBold = .t.
	FontName = "Tahoma"
	FontSize = 10
	ForeColor =RGB(0,0,0)
	Height = 19
	Left = 638
	Name = "Lx_Label1"
	Top = 24 
	Width=47

ENDDEFINE 

DEFINE CLASS cmbDoca as Lx_combobox
	columncount = 2
	Height = 20
	left = 635
	Name = "cmbDoca"
	Top = 48
	Width = 214
	
	PROCEDURE when
		f_select("select distinct substring(a.DOCA,1,30) as doca, b.filial, a.codigo_filial from PDA_WMS_TB_EMBARQUE a join filiais b on a.codigo_filial = b.clifor where a.faturado = 0 order by 1 ",'CurDocas')
		this.RowSourceType = 2 
		this.RowSource = 'CurDocas'
		this.Requery()
	ENDPROC 
	
	PROCEDURE l_desenhista_recalculo
		LOCAL edCaixas, strDoca, strCodFilial
		STORE '' TO edCaixas
		SELECT curDocas
		strDoca = curDocas.doca
		strCodFilial = curDocas.codigo_filial
		*!*	strDoca = this.Value 
		*!*	f_select("select caixa from PDA_WMS_TB_EMBARQUE where faturado = 0 and doca = '"+allt(strDoca)+"' and codigo_filial = '"+allt(strCodFilial)+"'",'CurCaixas')

		*!*		f_select("select distinct PDA_WMS_TB_EMBARQUE.caixa, PDA_WMS_TB_EMBARQUE.lacre, PDA_WMS_TB_EMBARQUE.placa, transportadoras.TRANSPORTADORA "+;
		*!*				"from PDA_WMS_TB_EMBARQUE "+;
		*!*				"join transportadoras on PDA_WMS_TB_EMBARQUE.CODIGO_TRANSPORTADORA = TRANSPORTADORAS.CODIGO_TRANSP  "+;
		*!*				"where PDA_WMS_TB_EMBARQUE.faturado = 0  and PDA_WMS_TB_EMBARQUE.doca = '"+allt(strDoca)+"' and PDA_WMS_TB_EMBARQUE.codigo_filial = '"+allt(strCodFilial)+"'",'CurCaixas')

		TEXT TO cSQL NOSHOW TEXTMERGE PRETEXT 7
			select distinct PDA_WMS_TB_EMBARQUE.caixa, 
			PDA_WMS_TB_EMBARQUE.lacre, 
			pda_wms_tb_embarque.placa AS placa, 
			transportadoras.TRANSPORTADORA, PDA_WMS_TB_EMBARQUE.COD_TIPO_VEICULO, PDA_WMS_TB_TIPO_VEICULO.DESCRICAO
			from PDA_WMS_TB_EMBARQUE 
			join transportadoras on PDA_WMS_TB_EMBARQUE.CODIGO_TRANSPORTADORA = TRANSPORTADORAS.CODIGO_TRANSP 
			left join PDA_WMS_TB_TIPO_VEICULO on PDA_WMS_TB_TIPO_VEICULO.CODIGO = PDA_WMS_TB_EMBARQUE.COD_TIPO_VEICULO
			where PDA_WMS_TB_EMBARQUE.faturado = 0  
			and PDA_WMS_TB_EMBARQUE.doca like '<<allt(strDoca)>>%' 
			and PDA_WMS_TB_EMBARQUE.codigo_filial = '<<+allt(strCodFilial)>>'
		ENDTEXT

		f_select(cSQL,'CurCaixas')

		SELECT CurCaixas
		SCAN
			edCaixas = edCaixas + ALLTRIM(CurCaixas.caixa)+CHR(13) + CHR(10) 
		ENDSCAN 
		this.Parent.edCaixas.Value = edCaixas 
		this.Parent.edCaixas.Refresh()
			
	ENDPROC
	

ENDDEFINE

DEFINE CLASS ck_fatura_caixa_fechada as lx_checkbox
	Alignment = 0
	Caption = "Fatura automaticamente"
	ControlSource = "thisformset.px_fatura_caixa_auto"
	Left = 636
	Name = "ck_fatura_caixa_fechada"
	ReadOnly = .f.
	Top = 72
	Value = .T.
	p_tipo_dado = "CHAVE"
ENDDEFINE 

DEFINE CLASS Lx_Label4 as Lx_label
	Alignment = 0
	Autosize = .f.
	Caption = "Relação de Caixas:"
	FontBold = .t.
	FontName = "Arial"
	FontSize = 10
	ForeColor =RGB(0,0,0)
	Height = 19
	Left = 726
	Name = "Lx_Label4"
	Top = 100
	Width=131

ENDDEFINE 

DEFINE CLASS edCaixas as Lx_editbox
	FontSize = 10
	ForeColor =RGB(0,0,0)
	Height = 324
	Left = 722
	Name = "edCaixas"
	ReadOnly = .T.
	Top = 120
	Width=180

ENDDEFINE 

DEFINE CLASS  btnDocaOk as Botao

	Caption = "\<Ok"
	Height = 27
	Left = 854
	MousePointer = 15
	Name = "btnDocaOk"
	ToolTipText = "Faturar caixas conferidas"
	Top = 44
	Width = 44
	p_manter_baixo = .t.
	p_manter_cima = .f.
	p_manter_esquerda = .f.
	
	PROCEDURE refresh
		this.Enabled = !thisformset.p_tool_status $ 'IA'
	ENDPROC 

	PROCEDURE click
		LOCAL strDoca, strCodFilial
		SELECT CurDocas

		strDoca = CurDocas.doca
		strCodFilial = CurDocas.codigo_filial
		*!*	strDoca = this.Parent.cmbDoca.Value


		IF !EMPTY(ALLTRIM(strDoca))
		*!*		f_select("select distinct caixa from PDA_WMS_TB_EMBARQUE where faturado = 0 and doca = '"+allt(strDoca)+"' and codigo_filial = '"+allt(strCodFilial)+"'",'CurCaixas')
		*!*		f_select("select distinct PDA_WMS_TB_EMBARQUE.caixa, PDA_WMS_TB_EMBARQUE.lacre, PDA_WMS_TB_EMBARQUE.placa, transportadoras.TRANSPORTADORA "+;
		*!*				"from PDA_WMS_TB_EMBARQUE "+;
		*!*				"join transportadoras on PDA_WMS_TB_EMBARQUE.CODIGO_TRANSPORTADORA = TRANSPORTADORAS.CODIGO_TRANSP  "+;
		*!*				"where PDA_WMS_TB_EMBARQUE.faturado = 0  and PDA_WMS_TB_EMBARQUE.doca = '"+allt(strDoca)+"' and PDA_WMS_TB_EMBARQUE.codigo_filial = '"+allt(strCodFilial)+"'",'CurCaixas')

			TEXT TO cSQL NOSHOW TEXTMERGE PRETEXT 7
				select distinct PDA_WMS_TB_EMBARQUE.caixa, 
				PDA_WMS_TB_EMBARQUE.lacre, 
				pda_wms_tb_embarque.placa AS placa, 
				transportadoras.TRANSPORTADORA, PDA_WMS_TB_EMBARQUE.COD_TIPO_VEICULO, PDA_WMS_TB_TIPO_VEICULO.DESCRICAO
				from PDA_WMS_TB_EMBARQUE 
				join transportadoras on PDA_WMS_TB_EMBARQUE.CODIGO_TRANSPORTADORA = TRANSPORTADORAS.CODIGO_TRANSP 
				left join PDA_WMS_TB_TIPO_VEICULO on PDA_WMS_TB_TIPO_VEICULO.CODIGO = PDA_WMS_TB_EMBARQUE.COD_TIPO_VEICULO
				where PDA_WMS_TB_EMBARQUE.faturado = 0  
				and PDA_WMS_TB_EMBARQUE.doca like '<<allt(strDoca)>>%' 
				and PDA_WMS_TB_EMBARQUE.codigo_filial = '<<+allt(strCodFilial)>>'
			ENDTEXT

			f_select(cSQL,'CurCaixas')


			IF RECCOUNT('CurCaixas') > 0
				SELECT CurCaixas
				SCAN
				
					IF !thisformset.lx_recursos_bip_caixas(ALLTRIM(CurCaixas.caixa))
						RETURN .f.
					ENDIF 
					SELECT cur_conferencia_caixas
					LOCATE FOR cur_conferencia_caixas.conferida AND ALLTRIM(cur_conferencia_caixas.caixa) = ALLTRIM(CurCaixas.caixa)
					IF !FOUND()
						MESSAGEBOX('Processo abortado!!',16,'Atencao')
						thisformset.lx_limpa_ambiente()
						RETURN .f.
					ENDIF 

				ENDSCAN 
				IF thisformset.px_fatura_caixa_auto 
					this.Parent.botao1.Click()		
				ENDIF 
			ELSE
				MESSAGEBOX('A doca '+alltr(strDoca)+ ' não esta mais disponivel para faturamento',16,'Atencao')
				thisformset.lx_limpa_ambiente()
			ENDIF 
		ENDIF 	
	ENDPROC
		
ENDDEFINE 