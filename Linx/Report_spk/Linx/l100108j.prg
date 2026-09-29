Procedure Func_Relatorio
lParameter xTipo,xObj

	***************************************************************************************************************************************************************
	** 30/06/2026 - MARCELO FREITAS - ENTERMODA-41280 - Linx ERP - NF-e - Criação da DANFE Simplificado - Tipo 2 - (NT2026.003 - v1.00 e NT2026.002 - v1.00)
	***************************************************************************************************************************************************************

	If JustExt(xObj.GetReportProperty('ReportFile'))='RPT'
		Func_Relatorio_Apos(xTipo,xObj)
	Else
		If Type('ReportExport')='O'
			Return .t.
		Else 
			If xTipo='PRE' 
				xObj.Export()
			Else
				Func_Relatorio_Apos(xTipo,xObj)
			Endif
			Return .f.
		Endif
	Endif

Endproc 
*---------------------------------------------------------------------------------------------------------------------------------------------------*

*---------------------------------------------------------------------------------------------------------------------------------------------------*
Procedure Func_Relatorio_Apos
lparameter xTipo, xObj
	
	Set Procedure To ..\Report.prg\nfe_functions_qrcode.prg Additive
	xObj.AddProperty('p_DANFE_Simplificado_QrCode',.t.) 
	PrintNFe(xTipo, xObj)

	f_wait()
	Return .f.
	
Endproc   
*---------------------------------------------------------------------------------------------------------------------------------------------------*

