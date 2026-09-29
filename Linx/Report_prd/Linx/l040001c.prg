PROCEDURE Func_Relatorio
lParameter xTipo,xObj

	IF TYPE('ReportExport')='O'
		RETURN .t.
	ELSE 

		Public xCores_p,xMesma,xlComb,xcor_mat,xd_cor_mat,xpag,xcolor,xmcor,xpor_cor,xl_cor,xRevenda

		Store .f. To xi_materiais,xi_cores,xi_medidas,xi_fotos,xi_operacoes,xi_extras,xi_botao
		System.ExecuteForm("lxoprel_FT","v_produtos_ficha_01.PRODUTO")

		IF xTipo='PRE'
			xObj.Export()
		ELSE
			Func_Relatorio_Apos(xTipo,xObj)
		ENDIF

		RETURN .f.
	ENDIF

ENDPROC 
*---------------------------------------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------------------------------------*
PROCEDURE Func_Relatorio_Apos
lParameter xTipo,xObj
*-- 08/05/2013 - Rafael - TP 3645868 - #1# - Remoção da duplicação das informações do material
	*-- Report da FT	
		xa_materiais = "L0400001r Materiais.frx"
		xa_cores     = "L0400002r Cores.frx"
		xa_medidas   = "L0400003r Medidas.frx"
		xa_fotos     = "L0400004r Fotos.frx"
		xa_operacoes = "L0400005r Operações.frx"
		xa_extras    = "L0400006r Operações Extras.frx"

		if ! ( upper(allt(xtipo)) $ 'PRE,IMP' )
			MessageBox(f_traduz('Lista De Reports da Ficha Técnica:') + chr(13) + xa_materiais + ', ' + xa_medidas + ', ' + xa_fotos + ', ' + xa_operacoes + ', ' + xa_combina + ', ' + xa_extras)
			Return .f.
		endif

	*-- Seleção dos Rel's a imprimir
		sele v_produtos_ficha_01
		go top

		IF TYPE('xi_botao')='C' and xi_botao='CANCEL'
			RETURN .f.
		ENDIF

		CREATE CURSOR Cur_Selecao_Imp (Nome_Report c(50),ultimo l(1))
		SELECT Cur_Selecao_Imp 

		if xi_materiais
			APPEND BLANK 
			REPLACE Nome_Report with xa_materiais
		endif   
		
*--#1#- Inicio
*!*			if xi_materiais
*!*				APPEND BLANK 
*!*				REPLACE Nome_Report with xa_materiais
*!*			endif   
*--#1#- Fim

		if xi_cores
			APPEND BLANK 
			REPLACE Nome_Report with xa_cores
		endif
		if xi_medidas
			APPEND BLANK 
			REPLACE Nome_Report with xa_medidas
		endif   
		if xi_fotos
			APPEND BLANK 
			REPLACE Nome_Report with xa_fotos
		endif
		if xi_operacoes 
			APPEND BLANK 
			REPLACE Nome_Report with xa_operacoes
		endif
		if xi_extras 
			APPEND BLANK 
			REPLACE Nome_Report with xa_extras
		endif

		SELECT Cur_Selecao_Imp 
		GO BOTTOM 
		IF !EOF()
			REPLACE ultimo WITH .t.	
		ENDIF
		
	*--
		xpag     = 0
		xSele    = SELECT()
		xDefault = SYS(5) + SYS(2003)

		xCodigoReport = left(justfname(Fx_GetReportProperty(xObj,'ReportProgramFile')), 8)
		xReportFile   = Fx_GetReportProperty(xObj,'ReportFile')
		xDirRel  	  = SUBSTR(xReportFile,1,(AT(xCodigoReport,xReportFile))-1)

		xOk = IIF(TYPE('ReportExport')='O',Fx_Control_Obj_Export(.t.),.t.)
		IF !xOk
			RETURN .f.
		ENDIF 
		
		IF TYPE('ReportExport')='O'
			xSaida1  = 'Object oXFRX NOPAGEEJECT'
			xSaida2  = 'Object oXFRX NOPAGEEJECT NORESET'
		ELSE
			xSaida1  = iif(Upper(xTipo)='PRE','Preview NOPAGEEJECT','noConsole to Printer Prompt NOPAGEEJECT')
			xSaida2  = iif(Upper(xTipo)='PRE','Preview NOPAGEEJECT NORESET','noConsole to Printer NOPAGEEJECT NORESET')
		ENDIF
		

	*-- Envia para saida
		SELECT Cur_Selecao_Imp 
		xTReg = RECCOUNT()
		xRAtu = 0
		SCAN 
			xRAtu = xRAtu+1 
			xSaida = IIF(xRAtu=1,xSaida1,xSaida2)
			IF Cur_Selecao_Imp.ultimo
				xSaida = Strt(Strt(xSaida,'NOPAGEEJECT',''),'NORESET','')
			ENDIF
			REPORT FORM (xDirRel+ALLTRIM(Nome_Report)) &xSaida 
		ENDSCAN 

		Release xCores_p,xMesma,xlComb,xcor_mat,xd_cod_mat,xpag,xcolor,xmcor,xpor_cor,xl_cor,xRevenda

		xSentToPrinter = .t.
		IF TYPE('ReportExport')='O'
			Fx_Control_Obj_Export(.f.)
		ENDIF 

	SET DEFAULT TO &xDefault
	SELECT (xSele)
	*

	f_wait()
	
Return .f.
*---------------------------------------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------------------------------------*
FUNCTION Fx_GetReportProperty
lParameters xObj,strReportField as String 

	return iif(Type("strReportField") == "C" and !Empty(strReportField) and Type("xObj.SelectedListObject.ListIndex") == "N" and xObj.SelectedListObject.ListIndex >= 0 and ;
				type("xObj.SelectedListObject.ItemValues(xObj.SelectedListObject.ListIndex, strReportField)") == "O" and ;
				!IsNull(xObj.SelectedListObject.ItemValues(xObj.SelectedListObject.ListIndex, strReportField)) , ;
				xObj.SelectedListObject.ItemValues(xObj.SelectedListObject.ListIndex, strReportField).Value, "")

Return .f.
*---------------------------------------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------------------------------------*
FUNCTION Fx_Control_Obj_Export
LPARAMETERS pStart
 
	IF pStart
		PUBLIC oXFRX, intStatusXFRX
		oXFRX = XFRX("XFRX#LISTENER")
		intStatusXFRX = oXFRX.SetParams(ReportExport.Filename,,.T.,,,,ReportExport.CurrentFileFormat)	
		Return (intStatusXFRX = 0) && Success
	ELSE
		oXFRX.finalize()
		RELEASE oXFRX
		RETURN .t.
	ENDIF 

ENDFUNC 
*---------------------------------------------------------------------------------------------------------------------------------------------------*
