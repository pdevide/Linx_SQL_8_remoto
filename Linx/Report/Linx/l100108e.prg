PROCEDURE Func_Relatorio
lParameter xTipo,xObj

	IF JustExt(xObj.GetReportProperty('ReportFile'))='RPT'
		Func_Relatorio_Apos(xTipo,xObj)
	ELSE
		IF TYPE('ReportExport')='O'
			RETURN .t.
		ELSE 
			IF xTipo='PRE' && Preview em PDF (para executar os dois report's da NFe)
				xObj.Export()
			ELSE
				Func_Relatorio_Apos(xTipo,xObj)
			ENDIF
			RETURN .f.
		ENDIF
	ENDIF

ENDPROC 
*---------------------------------------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------------------------------------*
Procedure Func_Relatorio_Apos
lparameter xTipo, xObj

	SET PROCEDURE TO ..\Report.prg\NFe_Functions.prg Additive
	PrintNFe(xTipo, xObj)

	f_wait()
	RETURN .f.
	
ENDPROC   
*---------------------------------------------------------------------------------------------------------------------------------------------------*
