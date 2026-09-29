PROCEDURE Func_Relatorio
lParameter xTipo,xObj
	f_select("Select valor_atual From Parametros Where Parametro='TIPO_COMUNICACAO_XML_NFE'","CurTmp_ParamMide",Alias())
	If (Upper(Alltrim(CurTmp_ParamMide.valor_atual)) <> 'MIDE')
		f_msg(['Disponivel apenas quando integração com Fiscal Flow ativada.', 64 ,'Atenção'])
		Return .f.
	EndIf
	
	f_select("Select valor_atual From Parametros Where Parametro='MIDE_DANFE_APARTIR_XML'","CurTmp_ParamMide",Alias())
	If (Upper(Alltrim(CurTmp_ParamMide.valor_atual)) <> '.T.')
		f_msg(['Disponivel apenas quando MIDE_DANFE_APARTIR_XML ativado.', 64 ,'Atenção'])
		Return .f.
	EndIf
	
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

	SET PROCEDURE TO ..\Report.prg\NFe_Functions_mide.prg Additive
	PrintNFe(xTipo, xObj, 'v_impressao_nf_00')
	
	f_wait()
	RETURN .f.
	
ENDPROC   
*---------------------------------------------------------------------------------------------------------------------------------------------------*
