PROCEDURE Func_Relatorio
lParameter xTipo,xObj

	***************************************************************************************************************************************************************
	** 20/01/2023 - VALMIR SOARES - LINXERP-12904 - Modelo de DANFE Simplificada com ajuste ref. instrução Normativa RE nº 79, de 19.09.2022 - DOE RS de 21.09.2022
	***************************************************************************************************************************************************************

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
	xObj.AddProperty('p_DANFE_Simplificado',.t.) && (Indica Modelo Simplificado/Etiqueta)
	PrintNFe(xTipo, xObj)

	f_wait()
	RETURN .f.
	
ENDPROC   
*---------------------------------------------------------------------------------------------------------------------------------------------------*

