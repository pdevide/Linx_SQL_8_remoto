IF USED("result")
	USE IN result
ENDIF
IF USED("result1")
	USE IN result1
ENDIF
IF USED("result2")
	USE IN result2
ENDIF
	
tcProduto = '45030886'
tcData = '20220228'
SQL1 = "CSM_MEMORIA_CALCULO_CUSTO_MEDIO 'CD CAJAMAR',?tcProduto,?tcData,1,1"
F_SELECT(SQL1, "RESULT")

oxlsx = CREATEOBJECT("exporta_xlsx",3) && cria uma planilha com 3 sheets

IF USED("result")
	SELECT result
	oxlsx.processaPlanilha("result",1,"Planilha1")
ENDIF
IF USED("result1")
	SELECT result1
	oxlsx.processaPlanilha("result1",2,"Planilha2")
ENDIF
IF USED("result2")
	SELECT result2
	oxlsx.processaPlanilha("result2",3,"Planilha3")
ENDIF
	

*!*	IF USED("RESULT")
*!*		SELECT RESULT
*!*		=AFIELDS(COLS)
*!*		FOR i=1 TO ALEN(cols,1)
*!*			campo = cols[i,1] + " " + iif(cols[i,2] $ "DTI",  cols[i,2], iif(cols[i,2] $ "N",cols[i,2]+	"("+TRANSFORM(cols[i,3])+","+TRANSFORM(cols[i,4])+")",cols[i,2]+"("+TRANSFORM(cols[i,3])+")")+",")
*!*					
*!*			WAIT WINDOW CAMPO
*!*		ENDFOR
*!*		SET STEP ON
*!*		a=0
*!*		
*!*		
*!*	ENDIF

RETURN 



** codigo da classe
**===============================================================================================================================


*!*	DEFINE CLASS botaoGerar as botao
*!*		Top=336
*!*		left=154
*!*		width=342
*!*		height=27
*!*		visible=.t.
*!*		Caption = "Gerar Kardex para os produtos/cores Selecionados"
*!*		FontBold = .t.
*!*		FontSize = 10
*!*		
*!*		PROCEDURE refresh
*!*			** Inclusão/Alteração/Exclusão/Tela (L)impa/(P)esquisa Feita!
*!*			**this.enabled = INLIST(ThisFormSet.p_Tool_Status,"I","A","L")
*!*		ENDPROC

*!*		PROCEDURE click
*!*			IF !thisformset.valida_parametros()
*!*				RETURN .f.
*!*			ENDIF

*!*			lcMeses="JANFEVMARABRMAIJUNJULAGOSETOUTNOVDEZ"
*!*			lcDataSaida = "_"+PADL(DAY(DATE()),2,"0")+"-"+SUBSTR(lcMeses,(MONTH(DATE())*3)-2,3)+"-"+TRANSFORM(YEAR(DATE()),"9999")

*!*			llGerarPlanilha=.t.
*!*			llGerarBase = .f.
*!*			lcTot = ALLTRIM(TRANSFORM(RECCOUNT("PARAMREPORT"),"999999"))
*!*			
*!*			SELECT COUNT(*) as qtd FROM PARAMREPORT WHERE selecao = .t. INTO CURSOR vqtdSaida

*!*			IF vqtdSaida.qtd >= 1000
*!*				IF MESSAGEBOX("Atenção foram marcadas muitas linhas. O processamento poderá demorar MUITAS HORAS!!!"+CHR(13)+;
*!*									"Deseja realmente continuar???", 292,"Aviso") = 7
*!*					SELECT PARAMREPORT
*!*					this.Parent.botao2.click()
*!*					
*!*					RETURN 
*!*				ENDIF
*!*			ENDIF
*!*			
*!*			SELECT PARAMREPORT
*!*			
*!*			lnCountPlan = 0
*!*			SCAN FOR selecao = .t.
*!*				tcProduto = ALLTRIM(PARAMREPORT.PRODUTO)
*!*				tcCor = ALLTRIM(PARAMREPORT.COR_PRODUTO)
*!*				tcFilial = ALLTRIM(PARAMREPORT.FILIAL)

*!*				WAIT WINDOW NOWAIT ALLTRIM(TRANSFORM(RECNO("PARAMREPORT"),"999999"))+"/"+lcTot
*!*				thisformset.busca_kardex(tcProduto, tcCor, tcFilial)

*!*				** Se nao encontrou registros, pula para o proximo
*!*				IF RECCOUNT("vKardex01")=0
*!*					LOOP
*!*				ENDIF

*!*				IF llGerarPlanilha
*!*					lnSheet = 1
*!*					oxlsx = CREATEOBJECT("exporta_xlsx",1)
*!*					oxlsx.processaPlanilha("vKardex01",lnSheet,tcProduto+"_"+tcCor)

*!*					tPasta = ADDBS(ALLTRIM(ThisFormset.lx_form1.txtPastaDestino.value ))
*!*					lcArqNome = STRTRAN(ALLTRIM(PARAMREPORT.FILIAL)," ","-")+"-"+;
*!*								ALLTRIM(PARAMREPORT.PRODUTO)+"-"+ALLTRIM(PARAMREPORT.COR_PRODUTO)+lcDataSaida 
*!*					lcArqFull = tPasta + lcArqNome

*!*					tcSaida = lcArqFull+".xlsx"
*!*					tcSaida = STRTRAN(tcSaida," ","_")
*!*	*!*					MESSAGEBOX(tcSAida)
*!*					WAIT WINDOW "Aguarde salvando planilha "+ tcSaida NOWAIT 
*!*					oxlsx.salvar(tcSaida,.t.)

*!*					RELEASE oExcel, oxlsx
*!*				ENDIF

*!*				IF llGerarBase
*!*					IF !used("vKardex00")
*!*						=AFIELDS(arrFields,"vKardex01")
*!*						CREATE CURSOR vKardex00 FROM ARRAY arrFields
*!*					ENDIF

*!*					SELECT vKardex00
*!*					APPEND FROM DBF("vKardex01")
*!*					thisformset.exporta_csv(lcDataSaida,ALLTRIM(ThisForm.txtPastaDestino.value ))

*!*				ENDIF
*!*				SELECT PARAMREPORT
*!*				lnCountPlan = lnCountPlan + 1

*!*			ENDSCAN
*!*			IF lnCountPlan > 0
*!*				MESSAGEBOX("Foram geradas "+ALLTRIM(TRANSFORM(lnCountPlan,"999999"))+" planilhas com sucesso!",64, "Aviso")
*!*			ENDIF
*!*			
*!*			RETURN

*!*		ENDPROC

*!*	ENDDEFINE


DEFINE CLASS exporta_xlsx AS custom


	Name = "exporta_xlsx"
	objExcel = .f. && propriedade que armazena o objeto Planilha Excel

	PROCEDURE Init
		PARAMETERS lnQtdPlan

		LOCAL oExcel as Object
		oExcel = CREATEOBJECT("Excel.application")
		
		this.objExcel = oExcel
		
		WITH oExcel
			.Application.ErrorCheckingOptions.BackgroundChecking = .f.
			.SheetsInNewWorkbook = lnQtdPlan && quantas sheets vai criar dentro do workbook = 1
			.workbooks.Add
			.displayAlerts = .f.
		ENDWITH
		
		RETURN 

	ENDPROC
	
	***
	* Parametros de Entrada:
	* lcCursor - alias() do cursor que vai ser trabalhado na planilha
	* lnSheet - numero da sheet que vai ser selecionada onde vai colocar os dados do cursor
	* lcNameSheet - nome (apelido) da sheet que vai ser usada
	*/
	PROCEDURE processaPlanilha
		PARAMETERS lcCursor, lnSheet, lcNameSheet
		** Formata cursor no excel
		IF NOT USED(lcCursor)
			RETURN
		ENDIF


		lcOldPoint = SET("Point")
		lcOldSeparator = SET("Separator")

		SET SEPARATOR TO ","
		SET POINT TO "."
		
		oExcel = this.objExcel

		WITH oExcel
			.Sheets(lnSheet).Select
			.Sheets(lnSheet).Name = lcNameSheet

			SELECT (lcCursor)
			IF RECCOUNT(lcCursor)=0
				WAIT WINDOW  NOWAIT "N?o h? dados para exportar para o Excel!"+ CHR(13)+;
					"Selecione outro filtro."
				RETURN
			ENDIF
			GO top

			.visible = .T.

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
				.Selection.NumberFormat = "@" && Formata a c?lula de cabe?alho (nome da coluna) como texto
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

			*** faz o fetch de linhas para n?o estourar a memoria
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

				** Formata??o de campo Date e Datetime
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

		RETURN
	ENDPROC
	
	PROCEDURE salvar
		PARAMETERS tcNome, blnFechar
		
		WITH this.objExcel
			.ActiveWorkbook.SaveAs(tcNome)
			IF blnFechar
				.quit
			ENDIF
		ENDWITH

	ENDPROC
		
	

ENDDEFINE
*
*-- EndDefine: exporta_excel
**************************************************

FUNCTION CriarPasta
PARAMETERS tcPasta
LOCAL ofs as Object
ofs = CreateObject("Scripting.FileSystemObject")
IF NOT ofs.FolderExists(tcPasta)
	ofs.CreateFolder(tcPasta)
ENDIF
RELEASE ofs
RETURN .t.


