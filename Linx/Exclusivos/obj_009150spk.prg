** OBJ_009022SPK.PRG --> PAULO DEVIDE -> 05-11-2018 - alterado em 28-04-2021
*- Definindo a classe do objeto de entrada que sera criado na Form.
Define Class obj_entrada As Custom
	*- Nome do metodo/função que os objetos linx vão chamar.
	Procedure metodo_usuario
		Lparam xmetodo, xobjeto, xnome_obj

		Do Case
			Case Upper(xmetodo) == 'USR_ALTER_BEFORE'



			Case Upper(xmetodo) == 'USR_INIT'

				** PAULO DEVIDE -> 05-11-2018 (botao pra gerar modelo 7 em excel)
				thisformset.lx_form1.addobject('bt_report1', 'bt_report')
				WITH thisformset.lx_form1.bt_report1
					.height = 23
					.fontname = 'Arial'
					.Caption = 'Relatório Excel Modelo 7'
					.Left = 546
					.Top = 54
					.Width = 135
					.Visible = .T.
					.Enabled = .T.
					.anchor = 0
					.p_manter_baixo = .f.
					.p_manter_cima = .f.
					.p_manter_direita = .f.
					.p_manter_esquerda = .f.
					.p_muda_size = .f.

				ENDWITH
				** FIM: 05-11-2018


			Case Upper(xmetodo) == 'USR_SAVE_BEFORE'




		Endcase
	Endproc

Enddefine


** PAULO DEVIDE -> 05-11-2018
DEFINE CLASS bt_report as botao
	caption = 'Relatório Excel'
	*autosize = .T.
	WORDWRAP = .t.
	WIDTH = 192
	top = 3
	left = 502
	HEIGHT =  27
	enabled = .F.
	visible  = .t.
	backcolor =  RGB(64,128,128)

	PROCEDURE click
		LOCAL llRet
		llRet = MESSAGEBOX("Deseja Formatar Relatório no Excel?",292,"Aviso")=6

		IF llRet
			f_wait("Exportando dados para o Excel...")
			LOCAL lcArquivo as String
			lcArquivo = SYS(2023)+"\conta_corrente_"+STUFF(STUFF(DTOS(DATE()),5,0,'-'),8,0,'-')+SYS(2015)+".xlsx"

			MODELO_7(lcArquivo)
			f_wait()
			MESSAGEBOX("Processamento Concluído! Relatório Gerado!",64,"Aviso")
		ENDIF


	ENDPROC

	PROCEDURE refresh
		** Inclusão/Alteração/Exclusão/Tela (L)impa/(P)esquisa Feita!
		this.enabled = !INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L")
	ENDPROC

ENDDEFINE
** FIM: 05-11-2018

PROCEDURE MODELO_7
	PARAMETERS tcArquivo
	System.ExecuteFormModal('LxOprel_009150_Filtros') && Retorna: xOpRelOrd,xOpRelPA,xOpRelMP

	PUBLIC xPg_i,xPoint,xSepar,xPorCor

	xPoint = SET('POINT')
	xSepar = SET('SEPARATOR')

	set point to ','
	set separator to '.'

	xPg_i = 0
	If Messagebox('Deseja Alterar a Sequência de Numeração da Página Inicial?',4+32+256,'Atenção')=6
		xPg_i = Val(Inputbox('Página Inicial','Contabilidade'))
		xPg_i = Iif(xPg_i>0,xPg_i-1,0)
	ENDIF

	xPorCor = (Messagebox('Deseja Visualizar Por Cor?',4+32+256,'Atenção')=6)

	f_wait('Aguarde...')

	xListaCamposPA = 'data_saldo,filial_matriz_contabil,filial_matriz_fiscal,conta_contabil_estoque,desc_conta_estoque,classif_fiscal,'+;
		'produto as Cod_Item,desc_produto as Desc_Item,unidade,'+;
		IIF(xPorCor,'cor_produto as Cod_Cor_Item,desc_cor_produto as Desc_Cor_Item','space(1) as Cod_Cor_Item,space(1) as Desc_Cor_Item')+;
		',sum(qtde) qtde,sum(valor) valor,000000000.00 Media'

	xListaCamposMP = 'data_saldo,filial_matriz_contabil,filial_matriz_fiscal,conta_contabil_estoque,desc_conta_estoque,classif_fiscal,'+;
		'material as Cod_Item,desc_material as Desc_Item,unid_estoque as Unidade,'+;
		IIF(xPorCor,'cor_material as Cod_Cor_Item,desc_cor_material as Desc_Cor_Item','space(1) as Cod_Cor_Item,space(1) as Desc_Cor_Item')+;
		',sum(qtde) qtde,sum(valor) valor,000000000.00 Media'

	SELECT v_fechamento_custo_medio_00_composicao_pa
	SET FILTER TO

	SELECT v_fechamento_custo_medio_00_composicao_mp
	SET FILTER TO


	SELECT &xListaCamposMP,SPACE(6) as Origem From v_fechamento_custo_medio_00_composicao_mp GROUP BY 1,2,3,4,5,6,7,8,9,10,11 WHERE .f. INTO CURSOR Cur_Result_CM READWRITE
	*----------------------------------------------------------------------------------------------------------------------------------------------------*

	* Filtra por filial
	local xFilialPA, xFilialMP
	xFilialPA = Alltrim(o_009150.px_Filial_PA)
	xFilialMP = Alltrim(o_009150.px_Filial_MP)

	**-- #1# Barbara Lima - TP 6055278 - Adicionar "==" para que realize o filtro pela filial exata.
	IF xOpRelPA
		If !f_Vazio(xFilialPA)
			INSERT INTO Cur_Result_CM ;
				SELECT &xListaCamposPA,'1 - PA' as Origem from v_fechamento_custo_medio_00_composicao_pa ;
				WHERE item_composicao='999' AND FILIAL == xFilialPA GROUP BY 1,2,3,4,5,6,7,8,9,10,11
		Else
			INSERT INTO Cur_Result_CM ;
				SELECT &xListaCamposPA,'1 - PA' as Origem from v_fechamento_custo_medio_00_composicao_pa ;
				WHERE item_composicao='999' GROUP BY 1,2,3,4,5,6,7,8,9,10,11
		endif

	ENDIF

	IF xOpRelMP
		If !f_Vazio(xFilialMP)
			INSERT INTO Cur_Result_CM ;
				SELECT &xListaCamposMP,'2 - MP' as Origem from v_fechamento_custo_medio_00_composicao_mp ;
				WHERE item_composicao='999' AND FILIAL == xFilialMP GROUP BY 1,2,3,4,5,6,7,8,9,10,11
		Else
			INSERT INTO Cur_Result_CM ;
				SELECT &xListaCamposMP,'2 - MP' as Origem from v_fechamento_custo_medio_00_composicao_mp ;
				WHERE item_composicao='999' GROUP BY 1,2,3,4,5,6,7,8,9,10,11
		EndIf

	ENDIF
	**-- #1#

	*-- MC
	SELECT distinct filial_matriz_contabil,SPACE(90) razao_social,SPACE(6) cod_clifor,SPACE(19) rg_ie,SPACE(19) cgc_cpf ;
		FROM Cur_Result_CM INTO CURSOR Cur_Info_MC READWRITE

	SELECT Cur_Info_MC
	SCAN
		f_select('select b.razao_social,b.cod_clifor,b.rg_ie,b.cgc_cpf From filiais a join cadastro_cli_for b on a.cod_filial=b.cod_clifor where a.filial=?Cur_Info_MC.filial_matriz_fiscal','CurTmp_MC',alias())
		REPLACE razao_social WITH NVL(CurTmp_MC.razao_social,''),;
			cod_clifor	 WITH NVL(CurTmp_MC.cod_clifor,''),;
			rg_ie	 	 WITH NVL(CurTmp_MC.rg_ie,''),;
			cgc_cpf  	 WITH NVL(CurTmp_MC.cgc_cpf,'')
	ENDSCAN


	*-- MF
	SELECT distinct filial_matriz_fiscal,SPACE(90) razao_social,SPACE(6) cod_clifor,SPACE(19) rg_ie,SPACE(19) cgc_cpf ;
		FROM Cur_Result_CM INTO CURSOR Cur_Info_MF READWRITE

	SELECT Cur_Info_MF
	SCAN
		f_select('select b.razao_social,b.cod_clifor,b.rg_ie,b.cgc_cpf From filiais a join cadastro_cli_for b on a.cod_filial=b.cod_clifor where a.filial=?Cur_Info_MF.filial_matriz_fiscal','CurTmp_MF',alias())
		REPLACE razao_social WITH NVL(CurTmp_MF.razao_social,''),;
			cod_clifor	 WITH NVL(CurTmp_MF.cod_clifor,''),;
			rg_ie	 	 WITH NVL(CurTmp_MF.rg_ie,''),;
			cgc_cpf  	 WITH NVL(CurTmp_MF.cgc_cpf,'')
	ENDSCAN

	*----------------------------------------------------------------------------------------------------------------------------------------------------*

	SELECT Cur_Info_Mc
	INDEX on filial_matriz_contabil tag iMC

	SELECT Cur_Info_MF
	INDEX on filial_matriz_fiscal tag iMF

	SELECT Cur_Result_CM
	REPLACE ALL Media WITH IIF(qtde=0,0,valor/qtde)
	IF xOpRelOrd=1
		INDEX on DTOS(data_saldo)+filial_matriz_contabil+filial_matriz_fiscal+conta_contabil_estoque+Classif_Fiscal+Origem+Cod_Item+Cod_Cor_Item tag iCM
	ELSE
		INDEX on DTOS(data_saldo)+filial_matriz_contabil+filial_matriz_fiscal+conta_contabil_estoque+Origem+Cod_Item+Cod_Cor_Item tag iCM
	ENDIF

	SET RELATION TO filial_matriz_contabil 	INTO Cur_Info_MC
	SET RELATION TO filial_matriz_fiscal 	INTO Cur_Info_MF ADDITIVE
	GO top

	f_wait()

	CREATE CURSOR vReport01 (;
		Codigo_Filial	C(6) null ,;
		Filial	C(25) null ,;
		Data_Saldo	D null ,;
		Conta_Contabil_Estoque	C(20) null ,;
		Descricao_conta_estoque	C(70) null ,;
		codigo_mercadoria	C(12) null ,;
		Origem	C(6) null ,;
		Cor	C(6) null ,;
		Descricao	C(70) null ,;
		Classif_Fiscal	C(30) null ,;
		Unidade	C(6) null ,;
		Quantidade	N(13,3) null ,;
		Media	N(13,2) null ,;
		Valor	N(16,5) null )
	SET SAFETY OFF
	ZAP

	SELECT Cur_Result_CM
	GO top
	SCAN

		SELECT vReport01
		APPEND BLANK
		REPLACE Codigo_Filial WITH Cur_Info_MF.cod_clifor
		REPLACE Filial WITH Cur_Result_CM.Filial_matriz_fiscal
		REPLACE Data_Saldo WITH Cur_Result_CM.data_saldo
		REPLACE Conta_Contabil_Estoque WITH Cur_Result_CM.Conta_Contabil_Estoque
		REPLACE Descricao_conta_estoque WITH Cur_Result_CM.desc_conta_estoque
		REPLACE codigo_mercadoria WITH Cur_Result_CM.Cod_Item
		REPLACE Origem WITH right(Cur_Result_CM.Origem,2)
		REPLACE Cor WITH Cur_Result_CM.Cod_Cor_Item
		REPLACE Descricao WITH allt(Cur_Result_CM.Desc_Item) + ' ' + allt(Cur_Result_CM.Desc_Cor_Item)
		REPLACE Classif_Fiscal WITH Cur_Result_CM.classif_fiscal
		REPLACE Unidade WITH Cur_Result_CM.unidade
		REPLACE Quantidade WITH iif((Cur_Result_CM.qtde - INT(Cur_Result_CM.qtde) = 0), int(Cur_Result_CM.qtde),Cur_Result_CM.qtde)
		REPLACE Media WITH Cur_Result_CM.media
		REPLACE Valor WITH Cur_Result_CM.valor

		SELECT Cur_Result_CM

	ENDSCAN

	**** EXPORTA PARA O EXCEL
	oxlsx = CREATEOBJECT("exporta_xlsx","vReport01")

ENDPROC

**************************************************
*-- Class:        exporta_excel (c:\linx_sql_8\linx\exclusivos\controles.vcx)
*-- ParentClass:  custom
*-- BaseClass:    custom
*-- Time Stamp:   08/03/15 05:53:06 PM
*
DEFINE CLASS exporta_xlsx AS custom


	Name = "exporta_xlsx"


	PROCEDURE Init
		PARAMETERS lcCursor, lcListaFields, tcMataObj, objExcel
		lnParms = PARAMETERS()

		IF lnParms < 2
			lcListaFields = ""
			tcMataObj = .t.
		ENDIF

		IF lnParms < 3
			tcMataObj = .t.
		ENDIF


		IF NOT USED(lcCursor)
			RETURN
		ENDIF

		SELECT (lcCursor)
		IF RECCOUNT(lcCursor)=0
			MESSAGEBOX("Não há dados para exportar para o Excel!"+ CHR(13)+;
				"Selecione outro filtro.", 64, "Aviso")
			RETURN
		ENDIF

		IF NOT EMPTY(lcListaFields)
			SET FIELDS TO &lcListaFields.
		ENDIF

		GO top

		** Formata cursor no excel
		lcOldPoint = SET("Point")
		lcOldSeparator = SET("Separator")

		SET SEPARATOR TO ","
		SET POINT TO "."

		LOCAL oExcel as Object

		oExcel = CREATEOBJECT("Excel.application")

		WITH oExcel
			.Application.ErrorCheckingOptions.BackgroundChecking = .f.
			.SheetsInNewWorkbook = 1 && quantas sheets vai criar dentro do workbook = 1
			.workbooks.Add
			.Sheets(1).Name = lcCursor

			.visible = .f.

			** formata as celulas no excel, conforme se tipo no cursor
			lcColsDateFormat = ""

			lnFields = AFIELDS(laFields,lcCursor)
			FOR lnCount=1 TO ALEN(laFields,1)

				.Cells(1,lnCount).Select
				lcAdress = SUBSTR(.ActiveCell.Address,2,ATC("$",.ActiveCell.Address,2)-2)
				.Columns(lcAdress+":"+lcAdress).Select

				DO CASE
					CASE INLIST(laFields[lnCount,2],'C','M','V') && caracter
						.Selection.NumberFormat = "@" && formata a celula para TEXTO

					CASE laFields[lnCount,2] = 'Y' && moeda
						.Selection.NumberFormat = [_(* #,##0.00_);_(* (#,##0.00);_(* ""-""??_);_(@_)]

					CASE laFields[lnCount,2] = 'D' && Date
						.Selection.NumberFormat = "@" &&"m/d/yyyy"
						lcColsDateFormat = 	lcColsDateFormat + lcAdress + ";D,"

					CASE laFields[lnCount,2] = 'T' && Datetime
						.Selection.NumberFormat = "@" &&"d/m/yy h:mm;@"
						lcColsDateFormat = 	lcColsDateFormat + lcAdress + ";T,"

					CASE laFields[lnCount,2] = 'B' && Double (Numeric)
						lcMascara = "#,##0." + PADL(0,laFields[lnCount,4],'0')
						.Selection.NumberFormat = lcMascara

					CASE laFields[lnCount,2] = 'F' && Float (Numeric)
						lcMascara = "#,##0." + PADL(0,laFields[lnCount,4],'0')
						.Selection.NumberFormat = lcMascara

					CASE laFields[lnCount,2] = 'I' && Inteiro
						.Selection.NumberFormat = "#,##0"

					CASE laFields[lnCount,2] = 'L' && Logico (Verdadeiro/Falso)
						.Selection.NumberFormat = "General"

					CASE laFields[lnCount,2] = 'N' && Numeric
						lcMascara = "#,##0." + PADL(0,laFields[lnCount,4],'0')
						.Selection.NumberFormat = lcMascara

					OTHERWISE
						.Selection.NumberFormat = "General"
				ENDCASE

				IF INLIST(laFields[lnCount,2],"B","F","I","N") && ALINHAMENTO A DIREITA DA CELULA numericos

					With .Selection
						.HorizontalAlignment = -4152
						.VerticalAlignment = -4107
						.WrapText = .F.
						.Orientation = 0
						.AddIndent = .F.
						.IndentLevel = 0
						.ShrinkToFit = .F.
						.ReadingOrder = -5002
						.MergeCells = .F.
					Endwith

				ENDIF

				.cells(1,lnCount).Select
				.Selection.NumberFormat = "@" && Formata a célula de cabeçalho (nome da coluna) como texto
				With .Selection.Interior
					.Pattern = 1
					.PatternColorIndex = -4105
					.Color = 65535
					.TintAndShade = 0
					.PatternTintAndShade = 0
				EndWith
				.Selection.Font.Bold = .t.

				.cells(1,lnCount).value = PROPER(laFields[lnCount,1])


			ENDFOR

			*** faz o fetch de linhas para não estourar a memoria
			SELECT (lcCursor)
			lnTamanhoFatia = 30000
			lnTotFatias = CEILING(RECCOUNT()/lnTamanhoFatia) && quebra em arquivos temporarios de 30000 linhas
			lnNextReg = 1

			FOR iww = 1 TO lnTotFatias
				SELECT (lcCursor)
				lcArqtmp = "curtmp"+SYS(2015)+".txt"
				lcArqtmp = SYS(2023)+"\"+lcArqtmp
				
				COPY TO (lcArqtmp) DELIMITED WITH TAB FOR RECNO()>=lnNextReg AND RECNO() < (lnNextReg+lnTamanhoFatia)
				
				lcStrArq = FILETOSTR(lcArqtmp)
				_cliptext = lcStrArq

				.cells(lnNextReg+1,1).select
				.ActiveSheet.Paste

				.Cells.Select
				.Cells.EntireColumn.AutoFit

				.Cells(1,1).select
				.Application.WindowState = -4137

				DELETE FILE (lcArqtmp)
				_cliptext = ""

				** Formatação de campo Date e Datetime
				IF NOT EMPTY(lcColsDateFormat)
					lcColsDateFormat = LEFT(lcColsDateFormat,LEN(lcColsDateFormat)-1) && tira a ultima virgula
					lnCols = GETWORDCOUNT(lcColsDateFormat,",")
					FOR lnCount=1 TO lnCols
						lcInfoColuna = GETWORDNUM(lcColsDateFormat,lnCount,",")
						lcColuna = GETWORDNUM(lcInfoColuna,1,";")
						lcTipoColuna = GETWORDNUM(lcInfoColuna,2,";")
						.Columns(lcColuna+":"+lcColuna).Select

						DO CASE
							CASE lcTipoColuna = "D"
								.Selection.NumberFormat = "m/d/yyyy"
							CASE lcTipoColuna = "T"
								.Selection.NumberFormat = "d/m/yy h:mm;@"
						ENDCASE

					ENDFOR
				ENDIF
				
				lnNextReg = (lnNextReg+lnTamanhoFatia)
				.Cells(lnNextReg+1,1).select
			ENDFOR && ==> FOR iww = 1 TO lnTotFatias

			.cells(1,1).select
			.visible = .T.


		ENDWITH
		SET SEPARATOR TO &lcOldSeparator.
		SET POINT TO &lcOldPoint.

		IF SET("Fields")<>""
			SET FIELDS TO
		ENDIF

		IF lnParms = 4
			objExcel = oExcel
		ENDIF

		IF tcMataObj
			RELEASE oExcel
		ENDIF

		RETURN
	ENDPROC


ENDDEFINE
*
*-- EndDefine: exporta_excel
**************************************************
