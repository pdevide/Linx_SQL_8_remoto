*-- Objetivo: Funcões Impressão da DANFE (Nota Fiscal Eletrônica)
*-- Vs-Lx   : Linx8.0: DANFE NORMAL Em 31-Ago-2009 | DPEC+FSDA Em 24-Out-2009 | Versão Unificada (LinxERP+LinxPOS+Monitor) com Paulo Mader em 26-Mar-2010
*-- Padial  : 09/04/2010: Tratamento desconto item do total da nota para a zona franca "desconto + icms_zf + pis_zf + cofins_zf"
*-- Vs-Lx   : 03/07/2010: Endereço de Entrega + Controle de quebra dos itens
*-- Vs-Lx   : 17/07/2010: Marcar DANFE como Impressa
*-- Vs-Lx   : 25/08/2010: Tratamento no uso da função DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE (não pode ser usado mais que uma vez no join porque fica lento)
*-- Vs-Lx   : 25/08/2010: Tratamento quebra campo de observações
*-- Vs-Lx   : 01/09/2010: Incluido campo complemento_emitente
*-- Vs-Lx   : 20/09/2010: Incluido campo OBS_INTERESSE_FISCO
*-- Vs-Lx   : 17/02/2011: Tratamento para NFe Versão 2.0
*-- Vs-Lx   : 04/03/2011: Inclusão de Marca e Número de Volumes
*-- Vs-Lx   : 07/03/2011: Tratamento quebra campo codigo_item
*-- Padial  : 24/03/2011: Erro no codigo do tipo de frete da sefaz. Estava usando o padrao do Linx que estava errado
*-- Vs-Lx   : 15/04/2011: Alteração na ordem das faturas/parcelas (fx_ctb_simula_parcelas não traz na ordem)
*-- Vs-Lx   : 28/07/2011: Tratamento para NF Importação
*-- Padial	: 23/10/2011: Campo IM do emitente errado, faltando ISS_R
*-- Padial	: 23/10/2011: Controle da observacao do item
*-- Padial	: 23/10/2011: Controle da observacao do item (Utilizado o feito por valmir)
*-- Vs-Lx   : 23/10/2011: Tratamento para Obs do Item
*-- Padial 	: 24/10/2011: Retirado o nvl da informacao de justificativa e data
*-- Fabiano : 26/10/2011: Ajuste do campo codigo do item que estava quebrando errado para codigos caracteres
*-- Beda	: 26/10/2011: Ajuste do campo codigo do item que estava quebrando errado para codigos caracteres com muitos M, W, etc
*-- Szalontai: 08/11/2011: Adição do campo BAIRRO no endereco de entrega(entrega_bairro)
*-- Szalontai: 12/03/2012: Correção no tratamento do campo UF na função F_Dados_NFE_Add. Quando o mesmo estava com EX no cadastro, não estava sendo colocado 99. Corrigido para atender a TP 2349871
*-- Rafael  		: 05/09/2012: adição dos campos Hora_saida
*-- Rafael  		: 10/10/2012: adição dos campos VEICULO_PLACA, UF_PLACA_VEICULO
*-- Rafael  		: 16/05/2013: #1# - Adição das informações do valor_imposto_item
*-- Rodrigo 		: 29/10/2013: #2# - Adicionado condição para encontrar caracter e não travar a impressão quando não houver espaço na observação.
*-- Rodrigo 		: 02/07/2014: #3# - TP - 5884578 - Correção na soma dos tributos de cada nota.
*-- Barbara 		: 17/07/2014: #4# - TP - 5965782 - Incluir a Fonte da Lei de Transparência, Tabela IBPT nos "DADOS ADICIONAIS"
*-- Rodrigo 		: 05/11/2014: #5# - TP - 6875302 - Retirado o trecho das alterações #4# e #5# pois a informação será adicionada pela procedure LX_INFORMACAO_COMPLEMENTAR_NOTA_FISCAL.
*-- Diego Quaresma 	: 04/12/2014: #6# - TP - 7100759 - Relizado tratamento para não deixar estourar o campo codigo_item no relatorio Danfe.
*-- Rodrigo 		: 27/01/2015: #7# - TP - 7676003 - Alterada mensagem de observação em cada item para atender lei da transparência.
*-- Barbara		    : 06/03/2015: #8# - TP - 8000475 - Incluir filtro pela EXCESSAO_FISCAL_TABELA no cursor vTmp_impressao_nf_00_itens_BASE para evitar duplicidade de informação
*-- Diego Quaresma	: 15/05/2015: #9# - TP - 8449146 - Inclusão do processo de diferimento.
*-- Barbara 		: 17/07/2015: #10# - TP - 8595338 - Incluir filtro pela ORIGEM_NF, retornando somente notas emitidas pelo ERP.
*-- Barbara 		: 05/08/2015: #11# - TP - 9743159 - Incluir filtro de status notas fiscais autorizadas fora do prazo.
*-- Barbara 		: 10/08/2015: #12# - TP - 9777132 - Substituir o tamanho do campo "telefone1" de 8 para 9
*-- Rodrigo Souza	: 11/09/2015: #13# - TP - 10227410 - Correção na geração dos valores em notas com ICMS DIFERIMENTO.
*-- Rodrigo Souza	: 12/09/2015: #14# - TP - 10227410 - Correção na geração dos valores dos itens em notas com ICMS DIFERIMENTO.
*-- Rodrigo Souza	: 14/09/2015: #15# - TP - 10227410 - Correção no filtro pela origem da NFE em notas com ICMS DIFERIMENTO.
*-- Diego Quaresma	: 20/01/2016: #16# - TP - 1600     - Tratamento para calcular o icms corretamente quando houver diferimento.
*-- Daiana Hedlund  : 02/10/2017: #17# - TP - 41323 - Correção para retirar o DDD do número de telefone do emitente e destinatário
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*


*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Procedure PrintNFe
	Lparameter xTipo,xObj,strSerie_NF,intQtdeVias,FormMain

	Local bLinxERP As boolean, strFilial As String, strNF_Numero As String
	Public xKimp


	bLinxERP = Pcount() == 2
	intQtdeVias = Iif(Type("intQtdeVias") != "N" Or (Type("intQtdeVias") == "N" And intQtdeVias < 1), 1, Iif(intQtdeVias > 5, 5, intQtdeVias))

	If !bLinxERP
		strFilial = Rtrim(xTipo)
		strNF_Numero = Alltrim(xObj)
		xTipo = 'IMP'
		Public wwLogo As String
		wwLogo  = Addbs(FormMain.SystemPath) + "Reports\LogoReport.png"
		If !File(wwLogo)
			MsgBox('Logo não encontrado: ' + wwLogo, 64 ,'Atenção')
			Release wwLogo
			Return .F.
		Endif
	Endif


	f_select("Select valor_atual From Parametros Where Parametro='LOGO_EXCLUSIVO_DANFE'","CurTmp_LogoDanfe",Alias())
	xTmpLogo = Nvl(Alltrim(CurTmp_LogoDanfe.valor_atual),'')
	If !Empty(xTmpLogo) And File(xTmpLogo)
		wwLogo = xTmpLogo
	Endif

	xSele    = Select()
	xDefault = Sys(5) + Sys(2003)

	If bLinxERP
		xCodigoReport = Left(Justfname(Fx_GetReportProperty(xObj,'ReportProgramFile')), 8)
		xReportFile   = Fx_GetReportProperty(xObj,'ReportFile')
		xDirRel  	  = Substr(xReportFile,1,(At(xCodigoReport,xReportFile))-1)
	Endif

	xOk = Iif(Type('ReportExport')='O',Fx_Control_Obj_Export(.T.),.T.)
	If !xOk
		Return .F.
	Endif

	If Type('ReportExport')='O'
		xSaida1  = 'Object oXFRX NOPAGEEJECT'
		xSaida2  = 'Object oXFRX NOPAGEEJECT NORESET'
		xLenObsFrm = '9/133' && Limite de Linhas/Caracteres por linha no campo de observações (por formulário)
	Else
		xSaida1  = Iif(Upper(xTipo)='PRE','Preview NOPAGEEJECT','noConsole to Printer' + Iif(bLinxERP, ' Prompt NOPAGEEJECT', ''))
		xSaida2  = Iif(Upper(xTipo)='PRE','Preview NOPAGEEJECT NORESET','noConsole to Printer' + Iif(bLinxERP, ' NOPAGEEJECT NORESET', ''))
		xLenObsFrm = '8/139' && Limite de Linhas/Caracteres por linha no campo de observações (por formulário)
	Endif

	*-- Itens por formulário para o DANFE
	f_select("Select valor_atual From Parametros Where Parametro='ITENS_P_FORM_DANFE'","CurTmp_Itens_p_form",Alias())
	xItensPD = Nvl(Alltrim(CurTmp_Itens_p_form.valor_atual),'')

	If  Atc('/',xItensPD) > 0
		xItensPD1 = Val( Substr(xItensPD,1,Atc('/',xItensPD)-1) )				&& Definido por parametro Primeiro Formulário
		xItensPD2 = Val( Substr(xItensPD,Atc('/',xItensPD)+1,Len(xItensPD)) )	&& Definido por parametro Segundo  Formulário
	Else
		xItensPD1 = 16 && Padrão Primeiro Formulário
		xItensPD2 = 46 && Padrão Segundo  Formulário
	Endif


	If bLinxERP
		If !Fx_DANFE_Init(xItensPD1,xItensPD2,xLenObsFrm)
			Return .F.
		Endif
	Else
		If !Fx_DANFE_Init(xItensPD1,xItensPD2,xLenObsFrm, strFilial, strNF_Numero, strSerie_NF, intQtdeVias, FormMain)
			Return .F.
		Endif
	Endif

	*-- Formulários
	If bLinxERP
		pLst_Reports_1 = xDirRel+'L_DANFE1.FRX'
		pLst_Reports_2 = xDirRel+'L_DANFE2.FRX'
	Else
		pLst_Reports_1 = Addbs(FormMain.SystemPath) + "Reports\L_Danfe1.frx"
		pLst_Reports_2 = Addbs(FormMain.SystemPath) + "Reports\L_Danfe2.frx"
	Endif

	pLst_Reports_1_Cr = Strt(pLst_Reports_1,'FRX','RPT')

	If !File(pLst_Reports_1)
		If !File(pLst_Reports_1_Cr)
			If bLinxERP
				Messagebox('Report Não Encontrado: ' + Chr(13)+pLst_Reports_1,16,'Atenção')
			Else
				MsgBox('Report Não Encontrado:\n' + pLst_Reports_1, -16, 'Atenção')
			Endif
			Return .F.
		Else
			pLst_Reports_1 = pLst_Reports_1_Cr
		Endif

	Endif


MESSAGEBOX('TESTE')



	If Justext(pLst_Reports_1)='FRX' And !File(pLst_Reports_2)
		If bLinxERP
			Messagebox('Report Não Encontrado: ' + Chr(13) + pLst_Reports_2,16,'Atenção')
		Else
			MsgBox('Report Não Encontrado:\n' + pLst_Reports_2, -16, 'Atenção')
		Endif
		Return .F.
	Endif

	*-- Envia para saida
	Select Distinct nf,serie_nf,filial,n_form,t_form,.F. As is_ultimo From vtmp_impressao_nf_00_itens Into Cursor Cur_Lst_DANFE_Emitir Readwrite
	Select Cur_Lst_DANFE_Emitir
	Go Bottom
	Replace is_ultimo With .T.

	Local intCountReports As Integer, bPritError As boolean, strMessage As String
	For intCountReports = 1 To intQtdeVias
		If !bLinxERP And intCountReports > 1
			FormMain.SetMessage("Imprimindo " + Transform(intCountReports, '9.999') + "ª via...")
		Endif

		If bLinxERP And Justext(Fx_GetReportProperty(xObj,'ReportFile'))='RPT' && -- Gera Arquivos Externos (Para o Crystal)
			xObj.CopyTables("vTmp_impressao_nf_00")
			xObj.CopyTables("vTmp_impressao_nf_00_itens")
			xObj.CopyTables("Cur_FrmNfe_Obs")
			xObj.CopyTables("Cur_Ctb_Parcelas")
		Else
			Select Max(t_form) t_form From Cur_Lst_DANFE_Emitir Into Cursor CurChk_t_form

			If CurChk_t_form.t_form=1 && Mais Rápido quando só existe NFe's de uma via no lote.
				Select vtmp_impressao_nf_00_itens
				Go Top
				xSaida = xSaida1
				xSaida = Strt(Strt(xSaida,'NOPAGEEJECT',''),'NORESET','')
				Try
					Report Form (pLst_Reports_1) &xSaida && Impressão
				Catch To oPrinterError
					strMessage = Alltrim(Str(oPrinterError.ErrorNo)) + " - " + Alltrim(oPrinterError.Message)
					If bLinxERP
						Messagebox(strMessage, -16, "Atenção")
					Else
						MsgBox(strMessage, -16, "Atenção")
					Endif
				Endtry
			Else
				Select Cur_Lst_DANFE_Emitir
				xRAtu = 0
				Scan
					xRAtu = xRAtu+1
					xKimp = Alltrim(filial)+Alltrim(nf)+Alltrim(serie_nf)+Str(n_form)

					Select vtmp_impressao_nf_00_itens
					Set Filter To Alltrim(filial)+Alltrim(nf)+Alltrim(serie_nf)+Str(n_form)==xKimp
					Go Top
					xSaida = Iif(xRAtu=1,xSaida1,xSaida2)
					If Cur_Lst_DANFE_Emitir.is_ultimo
						xSaida = Strt(Strt(xSaida,'NOPAGEEJECT',''),'NORESET','')
					Endif

					If n_form=1
						Try
							Report Form (pLst_Reports_1) &xSaida && Impressão
						Catch To oPrinterError
							strMessage = Alltrim(Str(oPrinterError.ErrorNo)) + " - " + Alltrim(oPrinterError.Message)
							If bLinxERP
								Messagebox(strMessage, -16, "Atenção")
							Else
								MsgBox(strMessage, -16, "Atenção")
							Endif
						Endtry
					Else
						Try
							Report Form (pLst_Reports_2) &xSaida  && Impressão
						Catch To oPrinterError
							strMessage = Alltrim(Str(oPrinterError.ErrorNo)) + " - " + Alltrim(oPrinterError.Message)
							If bLinxERP
								Messagebox(strMessage, -16, "Atenção")
							Else
								MsgBox(strMessage, -16, "Atenção")
							Endif
						Endtry
					Endif

					If bPritError
						Return .F.
					Endif
				Endscan
				*
			Endif

			If !bLinxERP
				FormMain.SetMessage()
			Endif
		Endif
	Endfor

	xSentToPrinter = .T.
	If Type('ReportExport')='O'
		Fx_Control_Obj_Export(.F.)
	Endif

	Fx_DANFE_Destroy(bLinxERP)

	If bLinxERP
		Set Default To &xDefault
	Endif

	Try
		Select (xSele)
	Catch
	Endtry

Endproc
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*


*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Function Fx_DANFE_Init
	Lparameters pItens1,pItens2,pLenObsFrm,strFilial,strNF_Numero,strSerie_NF,intQtdeVias,FormMain

	Local bLinxERP As boolean
	bLinxERP = Pcount() == 3

	*-- NF-e (D.A.N.F.E.)
	Public x_Proce,xImp_DSai,Ext1,Ext2,Ext3,xSentToPrinter

	xSentToPrinter = .F.
	xImp_DSai = .T. && f_msg(['Deseja Imprimir a Data de Saida?',4+32+256,'<Aviso...>'])=6

	If bLinxERP
		x_Proce = Set('PROCE')
		Set Procedure To ..\Report.prg\L002016.prg Additive && Barcodes Retaguarda
		xFilterPai = Strt(o_100108.p_comando_where,'W_IMPRESSAO_NF.','W_IMPRESSAO_NFe.')
		xFilterPai = xFilterPai + Iif(Empty(xFilterPai),'',' AND ') + " Empresa='" + Alltrim(Str(wEmpresa_Atual)) + "'"
		**		xFilterPai = xFilterPai + Iif(Empty(xFilterPai),'',' AND ') + ' Chave_NFe is Not Null AND ((Status_nfe=5 OR Status_nfe=9) OR (Tipo_emissao_nfe=4 OR Tipo_emissao_nfe=5))' #11#
		xFilterPai = xFilterPai + Iif(Empty(xFilterPai),'',' AND ') + ' Chave_NFe is Not Null AND ((Status_nfe in (5,6,9)) OR (Tipo_emissao_nfe=4 OR Tipo_emissao_nfe=5))' &&#11#
		**--#10#
		xFilterPai = xFilterPai + Iif(Empty(xFilterPai),'',' AND ') + [ origem_nf in ('S', 'E')]
		**--#10#
	Else
		xFilterPai = "NF = '" + Alltrim(strNF_Numero) + "' and Serie_NF = '" + Alltrim(strSerie_NF) + "' and Filial = '" + Rtrim(strFilial) + "'"
	Endif

	*--#12#
*!*		TEXT TO xSqlNFE_Pai NOSHOW TEXTMERGE
*!*					SELECT filial,nf,serie_nf,chave_nfe,Origem_NF,Importacao,status_nfe,CAST(tipo_emissao_nfe AS varchar(1)) as tipo_emissao_nfe,convert(varchar(10), emissao, 103) as emissao,empresa, IsNull(ctb_lancamento,0) as ctb_lancamento, IsNull(ctb_item,0) as ctb_item,cod_transacao,convert(varchar(10), data_saida, 103) as data_saida, hora_saida, VEICULO_PLACA, UF_PLACA_VEICULO,
*!*						   nome_clifor,IsNull(fatura,0) as fatura,desc_nf_natureza,pj_pf,CNPJ_DESTINATARIO AS CGC_CPF,razao_social_emitente,cnpj_emitente,endereco_emitente,numero_emitente,complemento_emitente,bairro_emitente,cidade_emitente,uf_emitente,pais_emitente,cep_emitente,ddd1_emitente, telefone1_emitente,ie_emitente,iest,pj_pf_emitente,razao_social,
*!*						   endereco,numero,complemento,bairro,cep,cidade,ddi,RIGHT(RTRIM(ddd1),2) as ddd1, RIGHT(RTRIM(dbo.FX_REPLACE_CARACTER_ESPECIAL_NFe(1,telefone1)),9) as telefone1,
*!*						   uf,case when pj_pf=0 then '' else rg_ie end as rg_ie,icms_base,icms,icms_st_base = icms_st_base + icms_str_base,icms_st = icms_st+icms_str,icms_str_base,icms_str,valor_sub_itens,
*!*						   Case When Importacao=1 and Danfe_NFe_Importacao_Calc='.T.' Then (IMPORTACAO_ALFANDEGA+IMPORTACAO_OUTRAS_DESPESAS+IMPORTACAO_SEGURO+IMPORTACAO_DESEMBARACO+PIS+COFINS) Else encargo End as encargo,
*!*						   frete,seguro,(desconto + icms_zf + pis_zf + cofins_zf) as desconto,desconto_cond_pgto,ipi,valor_total,transportadora_razao_social,
*!*						   Case When Entrega_cif=0 then cast(1 as numeric) else case when Entrega_cif = 1 then cast(0 as numeric) else Cast(entrega_cif AS numeric) end end as entrega_cif,
*!*						   Case When Entrega_cif=1 THEN 'Emitente' ELSE Case When Entrega_cif=0 THEN 'Dest/Rem' ELSE Case When Entrega_cif=2 THEN 'Terceiros' ELSE Case When Entrega_cif=9 THEN 'Sem Frete' ELSE '' END END END END as desc_entrega_cif,
*!*						   TRANSPORTADORA_PF_PJ, transportadora_cnpj,transportadora_endereco,transportadora_cidade,transportadora_uf,transportadora_ie,volumes,tipo_volume,marca_volumes,numeracao_volumes,peso_bruto,peso_liquido,IM_EMITENTE as im,(iss + ISS_R) as iss, (iss_base +ISS_R_BASE) as iss_base  ,valor_desconto_itens,valor_sub_itens_bruto,
*!*						   rtrim(isnull(cod_serie_sintegra,case when serie_nf = 'U' OR serie_nf = 'UN' then '0' else Rtrim(serie_nf) end)) as serie_danfe, Obs, Texto_Legal,Obs_Interesse_Fisco, data_contingencia, justificativa_contingencia,
*!*						   CASE When Entrega_Endereco Is Not Null AND (rtrim(IsNull(Endereco,''))+rtrim(IsNull(Numero,''))+rtrim(IsNull(Complemento,'')))<>(rtrim(IsNull(Entrega_Endereco,''))+rtrim(IsNull(Entrega_Numero,''))+rtrim(IsNull(Entrega_Complemento,'')))
*!*						   Then IsNull('ENTREGA: '+rTrim(entrega_endereco),'') + IsNull(', '+rTrim(entrega_numero),'') + IsNull(' - ' + rTrim(entrega_complemento),'') + ' - ' + IsNull(rTrim(entrega_bairro),'') + ' - ' + IsNull(rTrim(entrega_cidade),'') + '/' + IsNull(rTrim(entrega_uf),'') + IsNull(' - CEP: ' + rTrim(entrega_cep),'') + Case When pj_pf=1 Then IsNull(' - CNPJ: '+rTrim(entrega_cgc),'') Else IsNull(' - CPF: ' + rTrim(entrega_cgc),'') End Else '' End as Obs_Entrega
*!*					  From W_IMPRESSAO_NFE Where <<xFilterPai>>
*!*		ENDTEXT
	**--#12#
	
    *-- #17# Comentado alteração#12# e substituído pela query abaixo para retirar o DDD do telefone do emitente e destinatário
	TEXT TO xSqlNFE_Pai NOSHOW TEXTMERGE
				SELECT filial,nf,serie_nf,chave_nfe,Origem_NF,Importacao,status_nfe,CAST(tipo_emissao_nfe AS varchar(1)) as tipo_emissao_nfe,convert(varchar(10), emissao, 103) as emissao,empresa, IsNull(ctb_lancamento,0) as ctb_lancamento, IsNull(ctb_item,0) as ctb_item,cod_transacao,convert(varchar(10), data_saida, 103) as data_saida, hora_saida, VEICULO_PLACA, UF_PLACA_VEICULO,
					   nome_clifor,IsNull(fatura,0) as fatura,desc_nf_natureza,pj_pf,CNPJ_DESTINATARIO AS CGC_CPF,razao_social_emitente,cnpj_emitente,endereco_emitente,numero_emitente,complemento_emitente,bairro_emitente,cidade_emitente,uf_emitente,pais_emitente,cep_emitente,ddd1_emitente, substring(telefone1_emitente, 3, len(telefone1_emitente)) as telefone1_emitente,ie_emitente,iest,pj_pf_emitente,razao_social,
					   endereco,numero,complemento,bairro,cep,cidade,ddi,RIGHT(RTRIM(ddd1),2) as ddd1, RTRIM(dbo.FX_REPLACE_CARACTER_ESPECIAL_NFe(1,SUBSTRING(TELEFONE1,3,LEN(TELEFONE1)))) as telefone1,
					   uf,case when pj_pf=0 then '' else rg_ie end as rg_ie,icms_base,icms,icms_st_base = icms_st_base + icms_str_base,icms_st = icms_st+icms_str,icms_str_base,icms_str,valor_sub_itens,
					   Case When Importacao=1 and Danfe_NFe_Importacao_Calc='.T.' Then (IMPORTACAO_ALFANDEGA+IMPORTACAO_OUTRAS_DESPESAS+IMPORTACAO_SEGURO+IMPORTACAO_DESEMBARACO+PIS+COFINS) Else encargo End as encargo,
					   frete,seguro,(desconto + icms_zf + pis_zf + cofins_zf) as desconto,desconto_cond_pgto,ipi,valor_total,transportadora_razao_social,
					   Case When Entrega_cif=0 then cast(1 as numeric) else case when Entrega_cif = 1 then cast(0 as numeric) else Cast(entrega_cif AS numeric) end end as entrega_cif,
					   Case When Entrega_cif=1 THEN 'Emitente' ELSE Case When Entrega_cif=0 THEN 'Dest/Rem' ELSE Case When Entrega_cif=2 THEN 'Terceiros' ELSE Case When Entrega_cif=9 THEN 'Sem Frete' ELSE '' END END END END as desc_entrega_cif,
					   TRANSPORTADORA_PF_PJ, transportadora_cnpj,transportadora_endereco,transportadora_cidade,transportadora_uf,transportadora_ie,volumes,tipo_volume,marca_volumes,numeracao_volumes,peso_bruto,peso_liquido,IM_EMITENTE as im,(iss + ISS_R) as iss, (iss_base +ISS_R_BASE) as iss_base  ,valor_desconto_itens,valor_sub_itens_bruto,
					   rtrim(isnull(cod_serie_sintegra,case when serie_nf = 'U' OR serie_nf = 'UN' then '0' else Rtrim(serie_nf) end)) as serie_danfe, Obs, Texto_Legal,Obs_Interesse_Fisco, data_contingencia, justificativa_contingencia,
					   CASE When Entrega_Endereco Is Not Null AND (rtrim(IsNull(Endereco,''))+rtrim(IsNull(Numero,''))+rtrim(IsNull(Complemento,'')))<>(rtrim(IsNull(Entrega_Endereco,''))+rtrim(IsNull(Entrega_Numero,''))+rtrim(IsNull(Entrega_Complemento,'')))
					   Then IsNull('ENTREGA: '+rTrim(entrega_endereco),'') + IsNull(', '+rTrim(entrega_numero),'') + IsNull(' - ' + rTrim(entrega_complemento),'') + ' - ' + IsNull(rTrim(entrega_bairro),'') + ' - ' + IsNull(rTrim(entrega_cidade),'') + '/' + IsNull(rTrim(entrega_uf),'') + IsNull(' - CEP: ' + rTrim(entrega_cep),'') + Case When pj_pf=1 Then IsNull(' - CNPJ: '+rTrim(entrega_cgc),'') Else IsNull(' - CPF: ' + rTrim(entrega_cgc),'') End Else '' End as Obs_Entrega
				  From W_IMPRESSAO_NFE Where <<xFilterPai>>
	ENDTEXT
    *-- #17#

	f_select(xSqlNFE_Pai, "vTmp_impressao_nf_00")
	If Reccount('vTmp_impressao_nf_00')=0
		Messagebox('Nenhuma NFe Válida Selecionada no Filtro:'+Chr(13) + (xFilterPai),48,'Aviso')
		Return .F.
	Endif



	* Diferimento ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		*--#13#
	**If vTmp_impressao_nf_00.Origem_NF='F' #15#
	If vTmp_impressao_nf_00.Origem_NF='S' &&#16#
		*--#13#

		*--#9#
		TEXT TO xSqlNFE_Diferimento NOSHOW
				SELECT  SUM(CASE FATURAMENTO_IMPOSTO.ID_IMPOSTO
							WHEN 51
							THEN (FATURAMENTO_IMPOSTO.VALOR_IMPOSTO * -1)
						 ELSE FATURAMENTO_IMPOSTO.VALOR_IMPOSTO END) Diferimento
				FROM FATURAMENTO (NOLOCK)
					JOIN FATURAMENTO_ITEM (NOLOCK)
						ON FATURAMENTO.NF_SAIDA = FATURAMENTO_ITEM.NF_SAIDA AND
						   FATURAMENTO.SERIE_NF = FATURAMENTO_ITEM.SERIE_NF AND
						   FATURAMENTO.FILIAL	= FATURAMENTO_ITEM.FILIAL
					JOIN FATURAMENTO_IMPOSTO (NOLOCK)
						ON FATURAMENTO_ITEM.NF_SAIDA		 = FATURAMENTO_IMPOSTO.NF_SAIDA AND
						   FATURAMENTO_ITEM.SERIE_NF		 = FATURAMENTO_IMPOSTO.SERIE_NF AND
						   FATURAMENTO_ITEM.FILIAL			 = FATURAMENTO_IMPOSTO.FILIAL AND
						   FATURAMENTO_ITEM.ITEM_IMPRESSAO	 = FATURAMENTO_IMPOSTO.ITEM_IMPRESSAO AND
						   FATURAMENTO_ITEM.SUB_ITEM_TAMANHO = FATURAMENTO_IMPOSTO.SUB_ITEM_TAMANHO
					JOIN CTB_EXCECAO_IMPOSTO 
						ON	FATURAMENTO_ITEM.ID_EXCECAO_IMPOSTO=CTB_EXCECAO_IMPOSTO.ID_EXCECAO_IMPOSTO
						AND	CTB_EXCECAO_IMPOSTO.TRIBUT_ICMS= '51'
					JOIN	CTB_EXCECAO_IMPOSTO_ITEM
						ON	CTB_EXCECAO_IMPOSTO_ITEM.ID_EXCECAO_IMPOSTO=CTB_EXCECAO_IMPOSTO.ID_EXCECAO_IMPOSTO
						AND	CTB_EXCECAO_IMPOSTO_ITEM.ID_IMPOSTO=51
			WHERE FATURAMENTO_IMPOSTO.ID_IMPOSTO IN  ('1','51')
				AND FATURAMENTO.NF_SAIDA = ?vTmp_impressao_nf_00.NF
				AND FATURAMENTO.SERIE_NF = ?vTmp_impressao_nf_00.Serie_nf
				AND FATURAMENTO.FILIAL	 = ?vTmp_impressao_nf_00.Filial
				AND TEXTO_LEGAL IS NOT NULL
		ENDTEXT

	Else
		*--#13#
		TEXT TO xSqlNFE_Diferimento NOSHOW

		SELECT	SUM(CASE ENTRADAS_IMPOSTO.ID_IMPOSTO
				WHEN 51
				THEN (ENTRADAS_IMPOSTO.VALOR_IMPOSTO * -1)
				ELSE ENTRADAS_IMPOSTO.VALOR_IMPOSTO END) Diferimento
		FROM	ENTRADAS
		JOIN	ENTRADAS_ITEM
			ON	ENTRADAS.NF_ENTRADA=ENTRADAS_ITEM.NF_ENTRADA
			AND	ENTRADAS.SERIE_NF_ENTRADA=ENTRADAS_ITEM.SERIE_NF_ENTRADA
			AND ENTRADAS.NOME_CLIFOR = ENTRADAS_ITEM.NOME_CLIFOR
		JOIN	ENTRADAS_IMPOSTO
			ON	ENTRADAS_IMPOSTO.NF_ENTRADA = ENTRADAS_ITEM.NF_ENTRADA
			AND	ENTRADAS_IMPOSTO.SERIE_NF_ENTRADA = ENTRADAS_ITEM.SERIE_NF_ENTRADA
			AND	ENTRADAS_IMPOSTO.NOME_CLIFOR = ENTRADAS_ITEM.NOME_CLIFOR
			AND	ENTRADAS_IMPOSTO.ITEM_IMPRESSAO = ENTRADAS_ITEM.ITEM_IMPRESSAO
			AND	ENTRADAS_IMPOSTO.SUB_ITEM_TAMANHO = ENTRADAS_ITEM.SUB_ITEM_TAMANHO
		JOIN CTB_EXCECAO_IMPOSTO 
			ON	ENTRADAS_ITEM.ID_EXCECAO_IMPOSTO=CTB_EXCECAO_IMPOSTO.ID_EXCECAO_IMPOSTO
			AND	CTB_EXCECAO_IMPOSTO.TRIBUT_ICMS= '51'
			JOIN	CTB_EXCECAO_IMPOSTO_ITEM
			ON	CTB_EXCECAO_IMPOSTO_ITEM.ID_EXCECAO_IMPOSTO=CTB_EXCECAO_IMPOSTO.ID_EXCECAO_IMPOSTO
			AND	CTB_EXCECAO_IMPOSTO_ITEM.ID_IMPOSTO=51
			AND ENTRADAS.NF_ENTRADA = ?vTmp_impressao_nf_00.NF
			AND ENTRADAS.SERIE_NF_ENTRADA = ?vTmp_impressao_nf_00.Serie_nf
			AND ENTRADAS.NOME_CLIFOR	 = ?vTmp_impressao_nf_00.nome_clifor
			AND ENTRADAS.NF_ENTRADA_PROPRIA=1
		ENDTEXT
	Endif
		*--#16#
		*--#13#

	f_select(xSqlNFE_Diferimento , "vTmp_Diferimento")
	If Reccount('vTmp_Diferimento')>0
		If !F_Vazio(vTmp_Diferimento.diferimento)
			xDiferimento = vTmp_Diferimento.diferimento
			xValorDiferimento = 0
			Select vTmp_impressao_nf_00
			xValorDiferimento = vTmp_impressao_nf_00.icms - xDiferimento
			Replace vTmp_impressao_nf_00.icms With xValorDiferimento

		Endif
	Endif
	*--#9#
	* Diferimento ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	*--#8# Incluir filtro pela EXCESSAO_FISCAL_TABELA
	*--#1#
**#14#

	*--Início: Os itens da nota estavam duplicando em alguns casos, inserindo a condição DISTINCT no select para correção - Zé Luis ( 04-08-2022 )
	TEXT TO xSqlNFE_Filha NOSHOW
					Select distinct filial,nf,serie_nf,Item_Impressao,Item_NFe,sub_item_tamanho,codigo_item,descricao_item,
					 INFORMACAO_ADICIONAL_PROD AS OBS_ITEM,
					substring(replace(classif_fiscal,'.',''),1,8) as classif_fiscal, tribut_origem,tribut_icms,codigo_fiscal_operacao,id_excecao_imposto,unidade,qtde_item, preco_unitario + Round((CASE WHEN Importacao=1 and Danfe_NFe_Importacao_Calc='.T.' and encargo<>0 and qtde_item<>0 then encargo/qtde_item ELSE 0 END) + (CASE WHEN Importacao=1 and Danfe_NFe_Importacao_Calc='.T.' and i_import<>0 and qtde_item<>0 then i_import/qtde_item ELSE 0 END) ,
				   (CASE WHEN cod_tabela_filha='P' THEN 2 ELSE 5 END)) as preco_unitario, CASE WHEN Importacao=1 and Danfe_NFe_Importacao_Calc='.T.' THEN Round(qtde_item * (preco_unitario + Round((CASE WHEN Importacao=1 and Danfe_NFe_Importacao_Calc='.T.' and encargo<>0 and qtde_item<>0 then encargo/qtde_item ELSE 0 END) + (CASE WHEN Importacao=1 and Danfe_NFe_Importacao_Calc='.T.' and i_import<>0 and qtde_item<>0 then i_import/qtde_item ELSE 0 END) ,
				   (CASE WHEN cod_tabela_filha='P' THEN 2 ELSE 5 END))),2) ELSE valor_item END as valor_item, 
				   CASE WHEN tribut_icms='51' THEN ICMS_BST ELSE ICMS END as icms,
    			   icms_base,
				   icms_aliquota,
				   ipi,
				   ipi_aliquota, valor_descontos,desconto_total_item,valor_unitario_bruto,CONVERT(Numeric(13,2),valor_item_bruto) as valor_item_bruto,frete,seguro,Importacao,Danfe_NFe_Importacao_Calc
				   , valor_imposto_item = ISNULL(VALOR_IMPOSTO_ITEM, 0)
				  From W_IMPRESSAO_NFE_ITENS
				  	LEFT JOIN CADASTRO_CLI_FOR
						ON	CADASTRO_CLI_FOR.NOME_CLIFOR=W_IMPRESSAO_NFE_ITENS.NOME_CLIFOR
					LEFT JOIN TABELA_ALIQUOTA_IMPOSTO_ITEM
						ON	TABELA_ALIQUOTA_IMPOSTO_ITEM.UF=CADASTRO_CLI_FOR.UF
						AND	TABELA_ALIQUOTA_IMPOSTO_ITEM.NCM_NBS=replace(W_IMPRESSAO_NFE_ITENS.classif_fiscal,'.','')
						AND TABELA_ALIQUOTA_IMPOSTO_ITEM.EXCESSAO_FISCAL_TABELA = 0
						AND	CONVERT(VARCHAR(8),W_IMPRESSAO_NFE_ITENS.EMISSAO_RECEBIMENTO,112)  BETWEEN CONVERT(VARCHAR(8),TABELA_ALIQUOTA_IMPOSTO_ITEM.INICIO_VIGENCIA,112) AND
											CONVERT(VARCHAR(8),TABELA_ALIQUOTA_IMPOSTO_ITEM.FIM_VIGENCIA,112)
				  Where NF=?vTmp_impressao_nf_00.NF and Serie_NF=?vTmp_impressao_nf_00.Serie_nf and Filial=?vTmp_impressao_nf_00.Filial
	ENDTEXT
	*--Fim

*!*		TEXT TO xSqlNFE_Filha NOSHOW
*!*						Select filial,nf,serie_nf,Item_Impressao,Item_NFe,sub_item_tamanho,codigo_item,descricao_item,
*!*						 INFORMACAO_ADICIONAL_PROD AS OBS_ITEM,
*!*						substring(replace(classif_fiscal,'.',''),1,8) as classif_fiscal, tribut_origem,tribut_icms,codigo_fiscal_operacao,id_excecao_imposto,unidade,qtde_item, preco_unitario + Round((CASE WHEN Importacao=1 and Danfe_NFe_Importacao_Calc='.T.' and encargo<>0 and qtde_item<>0 then encargo/qtde_item ELSE 0 END) + (CASE WHEN Importacao=1 and Danfe_NFe_Importacao_Calc='.T.' and i_import<>0 and qtde_item<>0 then i_import/qtde_item ELSE 0 END) ,
*!*					   (CASE WHEN cod_tabela_filha='P' THEN 2 ELSE 5 END)) as preco_unitario, CASE WHEN Importacao=1 and Danfe_NFe_Importacao_Calc='.T.' THEN Round(qtde_item * (preco_unitario + Round((CASE WHEN Importacao=1 and Danfe_NFe_Importacao_Calc='.T.' and encargo<>0 and qtde_item<>0 then encargo/qtde_item ELSE 0 END) + (CASE WHEN Importacao=1 and Danfe_NFe_Importacao_Calc='.T.' and i_import<>0 and qtde_item<>0 then i_import/qtde_item ELSE 0 END) ,
*!*					   (CASE WHEN cod_tabela_filha='P' THEN 2 ELSE 5 END))),2) ELSE valor_item END as valor_item, 
*!*					   CASE WHEN tribut_icms='51' THEN ICMS_BST ELSE ICMS END as icms,
*!*	    			   icms_base,
*!*					   icms_aliquota,
*!*					   ipi,
*!*					   ipi_aliquota, valor_descontos,desconto_total_item,valor_unitario_bruto,CONVERT(Numeric(13,2),valor_item_bruto) as valor_item_bruto,frete,seguro,Importacao,Danfe_NFe_Importacao_Calc
*!*					   , valor_imposto_item = ISNULL(VALOR_IMPOSTO_ITEM, 0)
*!*					  From W_IMPRESSAO_NFE_ITENS
*!*					  	LEFT JOIN CADASTRO_CLI_FOR
*!*							ON	CADASTRO_CLI_FOR.NOME_CLIFOR=W_IMPRESSAO_NFE_ITENS.NOME_CLIFOR
*!*						LEFT JOIN TABELA_ALIQUOTA_IMPOSTO_ITEM
*!*							ON	TABELA_ALIQUOTA_IMPOSTO_ITEM.UF=CADASTRO_CLI_FOR.UF
*!*							AND	TABELA_ALIQUOTA_IMPOSTO_ITEM.NCM_NBS=replace(W_IMPRESSAO_NFE_ITENS.classif_fiscal,'.','')
*!*							AND TABELA_ALIQUOTA_IMPOSTO_ITEM.EXCESSAO_FISCAL_TABELA = 0
*!*							AND	CONVERT(VARCHAR(8),W_IMPRESSAO_NFE_ITENS.EMISSAO_RECEBIMENTO,112)  BETWEEN CONVERT(VARCHAR(8),TABELA_ALIQUOTA_IMPOSTO_ITEM.INICIO_VIGENCIA,112) AND
*!*												CONVERT(VARCHAR(8),TABELA_ALIQUOTA_IMPOSTO_ITEM.FIM_VIGENCIA,112)
*!*					  Where NF=?vTmp_impressao_nf_00.NF and Serie_NF=?vTmp_impressao_nf_00.Serie_nf and Filial=?vTmp_impressao_nf_00.Filial
*!*		ENDTEXT

*!*		TEXT TO xSqlNFE_Filha NOSHOW
*!*						Select filial,nf,serie_nf,Item_Impressao,Item_NFe,sub_item_tamanho,codigo_item,descricao_item,
*!*						 INFORMACAO_ADICIONAL_PROD AS OBS_ITEM,
*!*						substring(replace(classif_fiscal,'.',''),1,8) as classif_fiscal, tribut_origem,tribut_icms,codigo_fiscal_operacao,id_excecao_imposto,unidade,qtde_item, preco_unitario + Round((CASE WHEN Importacao=1 and Danfe_NFe_Importacao_Calc='.T.' and encargo<>0 and qtde_item<>0 then encargo/qtde_item ELSE 0 END) + (CASE WHEN Importacao=1 and Danfe_NFe_Importacao_Calc='.T.' and i_import<>0 and qtde_item<>0 then i_import/qtde_item ELSE 0 END) ,
*!*					   (CASE WHEN cod_tabela_filha='P' THEN 2 ELSE 5 END)) as preco_unitario, CASE WHEN Importacao=1 and Danfe_NFe_Importacao_Calc='.T.' THEN Round(qtde_item * (preco_unitario + Round((CASE WHEN Importacao=1 and Danfe_NFe_Importacao_Calc='.T.' and encargo<>0 and qtde_item<>0 then encargo/qtde_item ELSE 0 END) + (CASE WHEN Importacao=1 and Danfe_NFe_Importacao_Calc='.T.' and i_import<>0 and qtde_item<>0 then i_import/qtde_item ELSE 0 END) ,
*!*					   (CASE WHEN cod_tabela_filha='P' THEN 2 ELSE 5 END))),2) ELSE valor_item END as valor_item, 
*!*					   icms,
*!*	    			   icms_base,
*!*					   icms_aliquota,
*!*					   ipi,
*!*					   ipi_aliquota, valor_descontos,desconto_total_item,valor_unitario_bruto,CONVERT(Numeric(13,2),valor_item_bruto) as valor_item_bruto,frete,seguro,Importacao,Danfe_NFe_Importacao_Calc
*!*					   , valor_imposto_item = ISNULL(VALOR_IMPOSTO_ITEM, 0)
*!*					  From W_IMPRESSAO_NFE_ITENS
*!*					  	LEFT JOIN CADASTRO_CLI_FOR
*!*							ON	CADASTRO_CLI_FOR.NOME_CLIFOR=W_IMPRESSAO_NFE_ITENS.NOME_CLIFOR
*!*						LEFT JOIN TABELA_ALIQUOTA_IMPOSTO_ITEM
*!*							ON	TABELA_ALIQUOTA_IMPOSTO_ITEM.UF=CADASTRO_CLI_FOR.UF
*!*							AND	TABELA_ALIQUOTA_IMPOSTO_ITEM.NCM_NBS=replace(W_IMPRESSAO_NFE_ITENS.classif_fiscal,'.','')
*!*							AND TABELA_ALIQUOTA_IMPOSTO_ITEM.EXCESSAO_FISCAL_TABELA = 0
*!*							AND	CONVERT(VARCHAR(8),W_IMPRESSAO_NFE_ITENS.EMISSAO_RECEBIMENTO,112)  BETWEEN CONVERT(VARCHAR(8),TABELA_ALIQUOTA_IMPOSTO_ITEM.INICIO_VIGENCIA,112) AND
*!*												CONVERT(VARCHAR(8),TABELA_ALIQUOTA_IMPOSTO_ITEM.FIM_VIGENCIA,112)
*!*					  Where NF=?vTmp_impressao_nf_00.NF and Serie_NF=?vTmp_impressao_nf_00.Serie_nf and Filial=?vTmp_impressao_nf_00.Filial
*!*		ENDTEXT
**#14#








	*--#8#

	*--#7#
	&&CASE WHEN RTRIM(ISNULL(OBS_ITEM, '')) + CASE WHEN ISNULL(VALOR_IMPOSTO_ITEM, 0)=0 THEN '' ELSE CONVERT(VARCHAR(16), VALOR_IMPOSTO_ITEM) END = '' THEN NULL ELSE RTRIM(ISNULL(OBS_ITEM, '')) + CASE WHEN ISNULL(VALOR_IMPOSTO_ITEM, 0)=0 THEN '' ELSE '.   Val Aprox Tributos: ' + CONVERT(VARCHAR(16), VALOR_IMPOSTO_ITEM)+'('+CONVERT(VARCHAR(25), convert(numeric(15,2),(VALOR_IMPOSTO_ITEM/VALOR_ITEM)*100))+'%)' END END AS OBS_ITEM,
	*--#7#

	*--#1#


	*!*	* #99#
	*!*	CASE WHEN Rtrim(Isnull(W_IMPRESSAO_NFE_ITENS.obs_item, ''))
	*!*	                	 + CASE WHEN Isnull(W_IMPRESSAO_NFE_ITENS.valor_imposto_item, 0)=0 THEN '' ELSE CONVERT(VARCHAR(16), W_IMPRESSAO_NFE_ITENS.valor_imposto_item) END = '' THEN NULL
	*!*				         ELSE Rtrim(Isnull(W_IMPRESSAO_NFE_ITENS.obs_item, ''))
	*!*	            		 + CASE WHEN Isnull(W_IMPRESSAO_NFE_ITENS.valor_imposto_item, 0)=0 THEN '' ELSE '.Trib. Aprox. R$: ' + CONVERT(VARCHAR(16), W_IMPRESSAO_NFE_ITENS.valor_imposto_item)+' Federal ' END
	*!*					     END	+	CASE WHEN W_IMPRESSAO_NFE_ITENS.VALOR_IMPOSTO_ITEM_MUNICIPAL<>0 and W_IMPRESSAO_NFE_ITENS.VALOR_IMPOSTO_ITEM_ESTADUAL<>0 THEN ', '+CONVERT(VARCHAR(15),W_IMPRESSAO_NFE_ITENS.VALOR_IMPOSTO_ITEM_MUNICIPAL)+' Municipal '
	*!*						 WHEN W_IMPRESSAO_NFE_ITENS.VALOR_IMPOSTO_ITEM_MUNICIPAL<>0 THEN ', '+CONVERT(VARCHAR(15),W_IMPRESSAO_NFE_ITENS.VALOR_IMPOSTO_ITEM_MUNICIPAL)+' Municipal'
	*!*						 ELSE '' END
	*!*						 +	CASE WHEN W_IMPRESSAO_NFE_ITENS.VALOR_IMPOSTO_ITEM_MUNICIPAL<>0 and W_IMPRESSAO_NFE_ITENS.VALOR_IMPOSTO_ITEM_ESTADUAL<>0 THEN 'e '+CONVERT(VARCHAR(15),W_IMPRESSAO_NFE_ITENS.VALOR_IMPOSTO_ITEM_ESTADUAL)+' Estadual '
	*!*						 WHEN W_IMPRESSAO_NFE_ITENS.VALOR_IMPOSTO_ITEM_ESTADUAL<>0  THEN 'e '+CONVERT(VARCHAR(15),W_IMPRESSAO_NFE_ITENS.VALOR_IMPOSTO_ITEM_ESTADUAL)+' Estadual'
	*!*						 ELSE '' END+' Fonte: '+RTRIM(TABELA_ALIQUOTA_IMPOSTO_ITEM.FONTE)+'    '+RTRIM(TABELA_ALIQUOTA_IMPOSTO_ITEM.CHAVE) AS OBS_ITEM,
	If bLinxERP
		xFields_Ctrl_Add = "NVL(vTmp_impressao_nf_00.status_nfe,0) as status_nfe, NVL(VAL(vTmp_impressao_nf_00.tipo_emissao_nfe),0) as tipo_emissao_nfe, 0000 as n_form,0000 as t_form, 001 as n_qb_item, .f. as ult_n_qb_item, 0 as item_add, 1 as seq_obs"
		Select vTmp_impressao_nf_00
		Count To xTreg
		xRAtu = 0
		Scan
			xRAtu = xRAtu + 1
			f_prog_bar('Gerando Itens da NFe: '+ vTmp_impressao_nf_00.nf,xRAtu,xTreg)

			f_select(xSqlNFE_Filha,'vTmp_impressao_nf_00_itens_BASE',Alias())
			If !Used('vTmp_impressao_nf_00_itens')
				Select *,&xFields_Ctrl_Add From vTmp_impressao_nf_00_itens_BASE Into Cursor vtmp_impressao_nf_00_itens Readwrite
			Else
				Insert Into vtmp_impressao_nf_00_itens Select *,&xFields_Ctrl_Add From vTmp_impressao_nf_00_itens_BASE
			Endif

		Endscan
		Use In vTmp_impressao_nf_00_itens_BASE
		f_wait()
	Else
		xRunMetodo = f_select(xSqlNFE_Filha,'vTmp_impressao_nf_00_itens_Base')
		Select *, 00 As status_nfe, 00 As tipo_emissao_nfe, 0000 As n_form, 0000 As t_form, 001 As n_qb_item, .F. As ult_n_qb_item, 0 As item_add, 0000 As seq_obs ;
			From vTmp_impressao_nf_00_itens_BASE Into Cursor vtmp_impressao_nf_00_itens Readwrite

		Use In vTmp_impressao_nf_00_itens_BASE
		Replace All seq_obs With 1, status_nfe With Nvl(vTmp_impressao_nf_00.status_nfe, 0), tipo_emissao_nfe With Nvl(Val(vTmp_impressao_nf_00.tipo_emissao_nfe),0) In vtmp_impressao_nf_00_itens
	Endif

	*-- Reculcular 'VALOR TOTAL DOS PRODUTOS' para NFe Importação COM Danfe_NFe_Importacao_Calc='.T.'
	Select filial,nf,serie_nf,Sum(valor_item) valor_total From vtmp_impressao_nf_00_itens ;
		WHERE Importacao=1 And Danfe_NFe_Importacao_Calc='.T.' Group By 1,2,3 Into Cursor CurTmp_CalcSubItens_NF_import

	Select CurTmp_CalcSubItens_NF_import
	Scan
		Select vTmp_impressao_nf_00
		Locate For filial==CurTmp_CalcSubItens_NF_import.filial And nf==CurTmp_CalcSubItens_NF_import.nf And serie_nf==CurTmp_CalcSubItens_NF_import.serie_nf
		If Found()
			Replace valor_sub_itens With Round(CurTmp_CalcSubItens_NF_import.valor_total,2)
		Endif
	Endscan

	*--
	F_Tratar_Len_Itens_DANFE()
	F_Load_Ctrl_Frm_DANFE(pItens1,pItens2,pLenObsFrm, FormMain, bLinxERP)
	F_Load_Ctrl_NF_Financ_Nfe(bLinxERP)

	*-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------*

	Select Cur_Ctb_Parcelas
	Index On Alltrim(filial)+Alltrim(nf)+Alltrim(serie_nf) Tag iParcs

	Select Cur_FrmNfe_Obs
	Index On Alltrim(filial)+Alltrim(nf)+Alltrim(serie_nf)+Str(n_form)+Str(seq_obs) Tag iObsNfe

	Select vTmp_impressao_nf_00
	CursorSetProp('buffering',3)
	Index On Alltrim(filial)+Alltrim(nf)+Alltrim(serie_nf) Tag iFat
	Set Relation To Alltrim(filial)+Alltrim(nf)+Alltrim(serie_nf)  Into Cur_Ctb_Parcelas

	Select vtmp_impressao_nf_00_itens
	Index On Alltrim(filial)+Alltrim(nf)+Alltrim(serie_nf)+Str(n_form)+Str(seq_obs)+Str(Item_nfe)+Str(item_add)+Str(n_qb_item) Tag iItens

	Set Relation To Alltrim(filial)+Alltrim(nf)+Alltrim(serie_nf) Into vTmp_impressao_nf_00
	Set Relation To Alltrim(filial)+Alltrim(nf)+Alltrim(serie_nf)+Str(n_form)+Str(seq_obs) Into Cur_FrmNfe_Obs Additive
	Go Top

Endfunc
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*



*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Function Fx_DANFE_Destroy
	Lparameters bLinxERP


	*-- Marcar DANFE como Impressa (para botão IMPRIMIR ou Print no Preview)
	If bLinxERP And (( Type('Mreport')='C' And Mreport='IMP' ) Or ( Type('xSentToPrinter')='L' And xSentToPrinter ))
		Select vTmp_impressao_nf_00
		Scan
			If Origem_NF = "S"
				xupdate = 'Update Faturamento set Nota_impressa=1 Where nf_saida=?vTmp_Impressao_NF_00.nf and serie_nf=?vTmp_Impressao_NF_00.serie_nf and filial=?vTmp_Impressao_NF_00.filial and nota_impressa=0'
			Else
				xupdate = 'Update Entradas set nf_propria_emitida=1 Where nf_entrada=?vTmp_Impressao_NF_00.nf and nome_clifor=?vTmp_Impressao_NF_00.nome_clifor and serie_nf_entrada=?vTmp_Impressao_NF_00.serie_nf and nf_propria_emitida=0'
			Endif
			If !f_update(xupdate)
				=F_msg(['Problema ao Marcar Nota Impressa !', 0+16, 'Erro !!!'])
				Sele &xalias
				Return .F.
			Endif
			Wait Window 'Marcando NFe Como Impressa: '+ Alltrim(vTmp_impressao_nf_00.nf) Nowait
		Endscan
		Wait Clear
	Endif


	*-- Clear
	If bLinxERP
		Set Procedure To &x_Proce
	Else
		Release wwLogo
	Endif
	Release x_Proce,xImp_DSai,Ext1,Ext2,Ext3,xMsg_NFe,xReport_Printed,xKimp

	Local intCount As Integer, strCursor As String
	Local Array aCursorsClose[20, 1]

	aCursorsClose[1, 1]  = "cur_Ctb_Parcelas"
	aCursorsClose[2, 1]  = "cur_FrmNfe_Obs"
	aCursorsClose[3, 1]  = "vTmp_Impressao_NF_00_Itens"
	aCursorsClose[4, 1]  = "vTmp_Impressao_NF_00"
	aCursorsClose[5, 1]  = "cur_Lst_DANFE_Emitir"
	aCursorsClose[6, 1]  = "curTmp_Maxfrm"
	aCursorsClose[7, 1]  = "Cur_Lst_Nfs_Base"
	aCursorsClose[8, 1]  = "cur_Lst_NFs"
	aCursorsClose[9, 1]  = "cur_Info_UF"
	aCursorsClose[10, 1] = "curTmp_Prot"
	aCursorsClose[11, 1] = "cur_frmnfe_obs"
	aCursorsClose[12, 1] = "cur_Ctb_Parcelas"
	aCursorsClose[13, 1] = "curTmp_Itens_p_Form"
	aCursorsClose[14, 1] = "Cur_Count_n_Form"
	aCursorsClose[15, 1] = "curTmp_parc"
	aCursorsClose[16, 1] = "Cur_lst_itens_add_len"
	aCursorsClose[17, 1] = "CurTmp_TamLin_Item"
	aCursorsClose[18, 1] = "CurTmp_Controle_Ult_ItemQb"
	aCursorsClose[19, 1] = "CurChk_t_form"
	aCursorsClose[20, 1] = "CurTmp_LogoDanfe"

	For intCount = 1 To Alen(aCursorsClose, 1)
		strCursor = Alltrim(aCursorsClose[intCount, 1])
		If Used(strCursor)
			Use In &strCursor
		Endif
	Endfor


Endfunc
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*



*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Function F_Load_Ctrl_Frm_DANFE() && Form Control
	Lparameters pItens1,pItens2,pLenObsFrm, FormMain, bLinxERP

	*-  pItens1	   = Numero de Itens do primeiro formulário
	*-  pItens2	   = Numero de Itens dos demais formulários
	*-  pLenObsFrm = Tamanho Máximo para quebra da OBS por Formulário (Linhas/Caracteres por linha)

	Local intIdentifica_Ambiente_NFe As Integer
	intIdentifica_Ambiente_NFe = Iif(bLinxERP, wIdentifica_Ambiente_NFe, FormMain.p_Identifica_Ambiente_NFe)


	*-- Controle de Itens Por Frm
	Select vtmp_impressao_nf_00_itens
	Index On filial+nf+serie_nf+Str(Item_nfe) Tag iItem
	Do Whil !Eof()
		xKey   = filial+nf+serie_nf
		xFrm   = 1
		xCount = 0
		xItensPFrm = pItens1
		Scan Whil filial+nf+serie_nf==xKey
			xCount = xCount+1
			If xCount > xItensPFrm
				xFrm   = xFrm + 1
				xCount = 1
				*/xItensPFrm = IIF(tipo_emissao_nfe=5,pItens1,pItens2) && [Formulário de Segurança igual para todas as páginas]
				xItensPFrm = pItens2 && Papel timbrado (igual ao normal)
			Endif
			Replace n_form With xFrm
		Endscan
	Enddo


	*-- Controle de Quebra da OBS
	Declare xMsg_NFe(3)
	xMsg_NFe(1) = '( S E M   V A L O R   F I S C A L )'									 					  	&& > Para: wIdentifica_Ambiente_NFe=0 ou 2 ( quando em ambiente de homologação )
	xMsg_NFe(2) = 'DANFE IMPRESSO EM CONTINGÊNCIA - DPEC REGULARMENTE RECEBIDA PELA RECEITA FEDERAL DO BRASIL'	&& > Para: vTmp_impressao_nf_00.tipo_emissao_nfe='4'
	xMsg_NFe(3) = 'DANFE EM CONTINGÊNCIA - IMPRESSO EM DECORRÊNCIA DE PROBLEMAS TÉCNICOS' 						&& > Para: vTmp_impressao_nf_00.tipo_emissao_nfe='5'


	*-- Trata Obs
	Select nf,serie_nf,filial,status_nfe,tipo_emissao_nfe,n_form,Count(*) Cnt_Itens ;
		FROM vtmp_impressao_nf_00_itens Group By 1,2,3,4,5,6 Into Cursor Cur_Lst_Nfs_Base

	Select a.*, b.Obs, b.Obs_Entrega, b.Texto_Legal, Obs_Interesse_Fisco, Obs As Obs_Final_Frm,;
		TTOC(b.data_contingencia) As data_contingencia, b.justificativa_contingencia justificativa_contingencia ;
		FROM Cur_Lst_Nfs_Base a Join vTmp_impressao_nf_00 b On a.nf=b.nf And a.serie_nf=b.serie_nf And a.filial=b.filial ;
		ORDER By a.nf,a.serie_nf,a.filial,a.n_form Into Cursor Cur_Lst_Nfs Readwrite

	Select Cur_Lst_Nfs
	Do Whil !Eof()
		xK=nf+serie_nf+filial
		xObsFinal = Iif(intIdentifica_Ambiente_NFe=0 Or intIdentifica_Ambiente_NFe=2,xMsg_NFe(1)+Chr(13),'') +;
			IIF(tipo_emissao_nfe=4,xMsg_NFe(2)+' '+Chr(13)+Alltrim(Nvl(justificativa_contingencia,''))+' '+Alltrim(Nvl(data_contingencia,''))+Chr(13),;
			IIF(tipo_emissao_nfe=5,xMsg_NFe(3)+' '+Chr(13)+Alltrim(Nvl(justificativa_contingencia,''))+' '+Alltrim(Nvl(data_contingencia,''))+Chr(13),''))

		xObsIntFisco = Iif(Empty(Nvl(Obs_Interesse_Fisco,'')),'','Informações Adicionais de Interesse do Fisco: '+Nvl(Alltrim(Obs_Interesse_Fisco),''))

		If !('ENTREGA:' $ Upper(Nvl(Obs,'')))
			xObsFinal = xObsFinal + Iif(Empty(xObsFinal) Or Empty(Nvl(Obs_Entrega,'')),'',Chr(13)+Chr(10)) + Nvl(Obs_Entrega,'')
		Endif

		xObsFinal = xObsFinal + Iif(Empty(xObsFinal) Or Empty(Nvl(Obs,'')),'',Chr(13)+Chr(10)) + Nvl(Obs,'')
		xObsFinal = xObsFinal + Iif(Empty(xObsFinal) Or Empty(Nvl(Texto_Legal,'')),'',Chr(13)+Chr(10)) + Nvl(Texto_Legal,'')
		xObsFinal = xObsFinal + Iif(Empty(xObsFinal) Or Empty(Nvl(Obs_Interesse_Fisco,'')),'',Chr(13)+Chr(10)) + xObsIntFisco

		Replace Obs_Final_Frm With Left(xObsFinal,5000) && Limite estipulado no manual
		Skip
		Scan While nf+serie_nf+filial==xK
			Replace Obs_Final_Frm With ''
		Endscan
	Enddo

	*--

	Select nf,serie_nf,filial,vTmp_impressao_nf_00.Obs As Obs_Form,vTmp_impressao_nf_00.Obs As endereco_emitente_str,;
		00000 As n_form,00000 As seq_obs,;
		SPACE(50) As msg_Protocolo,Space(50) As msg_RegistroDped,;
		SPACE(55) chave_nfe_str,Space(36) dados_add_nfe,Space(44) dados_add_nfe_str,;
		SPACE(100) chave_nfe_str_barra,Space(100) dados_add_nfe_barra ;
		FROM Cur_Lst_Nfs Where .F. Into Cursor Cur_FrmNfe_Obs Readwrite

	Select Cur_Lst_Nfs
	Scan
		Select Count(Distinct n_form) Cnt_n_form From vtmp_impressao_nf_00_itens ;
			WHERE nf=Cur_Lst_Nfs.nf And serie_nf=Cur_Lst_Nfs.serie_nf And filial=Cur_Lst_Nfs.filial Into Cursor Cur_Count_n_Form

		Select vTmp_impressao_nf_00
		Locate For Alltrim(filial)+Alltrim(nf)+Alltrim(serie_nf) == Alltrim(Cur_Lst_Nfs.filial)+Alltrim(Cur_Lst_Nfs.nf)+Alltrim(Cur_Lst_Nfs.serie_nf)
		xChaveSTR = Nvl(Subs(chave_nfe,1,4)+' '+Subs(chave_nfe,5,4)+' '+Subs(chave_nfe,9,4)+' '+Subs(chave_nfe,13,4)+' '+Subs(chave_nfe,17,4)+' '+Subs(chave_nfe,21,4)+' '+Subs(chave_nfe,25,4)+' '+Subs(chave_nfe,29,4)+' '+Subs(chave_nfe,33,4)+' '+Subs(chave_nfe,37,4)+' '+Subs(chave_nfe,41,4),'')

		xEndEmitenteStr = Allt(Nvl(vTmp_impressao_nf_00.endereco_emitente,'')) + Nvl(', ' + Allt(vTmp_impressao_nf_00.numero_emitente),'') + Nvl(Space(2) + Allt(vTmp_impressao_nf_00.complemento_emitente),'') + Nvl(' - '+Allt(vTmp_impressao_nf_00.bairro_emitente),'') + Chr(13) +;
			allt(vTmp_impressao_nf_00.cidade_emitente) + '/' + Allt(vTmp_impressao_nf_00.uf_emitente) + Nvl(' - ' + Allt(vTmp_impressao_nf_00.pais_emitente),'') + Chr(13) +;
			'CEP: ' + Allt(vTmp_impressao_nf_00.cep_emitente) + Chr(13) +;
			nvl('TEL: ' + '('+Allt(vTmp_impressao_nf_00.ddd1_emitente)+')'+Allt(vTmp_impressao_nf_00.telefone1_emitente),'')

		f_select('Select PROTOCOLO_AUTORIZACAO_NFe,DATA_AUTORIZACAO_NFe,REGISTRO_DPEC,DATA_REGISTRO_DPEC '+;
			'  FROM w_Impressao_NFe where nf=?Cur_Lst_Nfs.nf and serie_nf=?Cur_Lst_Nfs.serie_nf and filial=?Cur_Lst_Nfs.filial','CurTmp_Prot',Alias())

		xObsFrm = Alltrim(Nvl(Cur_Lst_Nfs.Obs_Final_Frm,''))
		=F_Quebra_Obs_Frm_DANFE(Upper(xObsFrm),pLenObsFrm)

		xSeqObs = 0
		xSeqObsFrm = 0

		Do Whil !Eof('Cur_Lst_Nfs')
			xSeqObs = xSeqObs + 1
			xSeqObsFrm = xSeqObsFrm+1

			Select Cur_Ctrl_ObsForm
			Locate For id_form==xSeqObsFrm
			xObs = Alltrim(Obs_Form)

			xn_form = Cur_Lst_Nfs.n_form
			If !Empty(xObs) And xSeqObs>1 And Cur_Count_n_Form.Cnt_n_form>1
				xn_form = xn_form+1
				xSeqObs = 1
				Select Cur_Lst_Nfs
				Skip
			Endif

			If xSeqObs>1 And Cur_Count_n_Form.Cnt_n_form=1
				xn_form = xSeqObs
			Endif

			Select Cur_FrmNfe_Obs
			Append Blank In Cur_FrmNfe_Obs
			Replace nf With Cur_Lst_Nfs.nf, serie_nf With Cur_Lst_Nfs.serie_nf, filial With Cur_Lst_Nfs.filial, n_form With xn_form,;
				seq_obs 				With xSeqObs,;
				Obs_Form 				With xObs,;
				endereco_emitente_str	With xEndEmitenteStr,;
				msg_Protocolo     		With Nvl(Allt(Nvl(CurTmp_Prot.PROTOCOLO_AUTORIZACAO_NFe,''))+' '+Nvl(Ttoc(CurTmp_Prot.DATA_AUTORIZACAO_NFe),''),''),;
				msg_RegistroDped  		With Nvl(Allt(Nvl(CurTmp_Prot.REGISTRO_DPEC,''))+' '+Nvl(Ttoc(CurTmp_Prot.DATA_REGISTRO_DPEC),''),''),;
				chave_nfe_str	  		With xChaveSTR,;
				dados_add_nfe	  		With F_Dados_NFE_Add(.F.),;
				dados_add_nfe_str 		With F_Dados_NFE_Add(.T.), ;
				chave_nfe_str_barra 	With bc_ocode128(Alltrim(Nvl(Allt(vTmp_impressao_nf_00.chave_nfe),'')),0,0,0),;
				dados_add_nfe_barra 	With bc_ocode128(Allt(Cur_FrmNfe_Obs.dados_add_nfe),0,0,0) In Cur_FrmNfe_Obs

			Select vtmp_impressao_nf_00_itens
			Locate For nf=Cur_Lst_Nfs.nf And serie_nf=Cur_Lst_Nfs.serie_nf And filial=Cur_Lst_Nfs.filial And n_form=xn_form And seq_obs=xSeqObs
			If Eof()
				Append Blank
				Replace nf With Cur_Lst_Nfs.nf, serie_nf With Cur_Lst_Nfs.serie_nf, filial With Cur_Lst_Nfs.filial,;
					status_nfe With Cur_Lst_Nfs.status_nfe, tipo_emissao_nfe With  Cur_Lst_Nfs.tipo_emissao_nfe, n_form With xn_form, seq_obs With xSeqObs,item_add With 1
			Endif

			*--#5#
			*--#3#
			*!*					nValorImposto = 0
			*!*					nValorItem = 0
			*!*					cResultado = ''
			*!*
			*!*					Sum Valor_imposto_item, Valor_item TO nValorImposto, nValorItem FOR nf=Cur_Lst_Nfs.nf AND serie_nf=Cur_Lst_Nfs.serie_nf AND filial=Cur_Lst_Nfs.filial
			*!*
			*!*					*--#4#
			*!*					f_select("Select valor_atual From Parametros where Parametro = 'MENSAGEM_LEI_TRANSP'","Cur_Lei_Transp_Obs",ALIAS())
			*!*					cLei_Transp = ALLTRIM(Cur_Lei_Transp_Obs.valor_atual)
			*!*
			*!*					If ((nValorImposto/nValorItem)*100) > 0
			*!*
			*!*						 cResultado = STRTRAN(cLei_Transp,'#TRIBUTO#',Alltrim(Str(nValorImposto,14,2)) + ' ('+Alltrim(Str(((nValorImposto/nValorItem)*100),14,2))+'%)')
			*!*					*--#4#
			*!*						SELECT Cur_FrmNfe_Obs
			*!*						replace Obs_Form with Iif(f_vazio(Obs_Form),'',Alltrim(Obs_Form))+Chr(13)+Nvl(cResultado,'')
			*!*					EndIf
			*--#3#
			*--#5#

			Select vtmp_impressao_nf_00_itens
			If Reccount('Cur_Ctrl_ObsForm')=0 Or Reccount('Cur_Ctrl_ObsForm')=xSeqObsFrm && Sem Obs ou Ultima linha da obs
				Exit
			Endif
		Enddo
	Endscan


	*-- Ajuste/Padronização dos Itens: Fixar iguais para todos os formulários (para preencher espaçamento)
	Select nf,serie_nf,filial,status_nfe,tipo_emissao_nfe,n_form,seq_obs,Max(Item_nfe) Item_nfe,Min(n_qb_item) n_qb_item,Count(*) Cnt_Itens ;
		FROM vtmp_impressao_nf_00_itens Group By 1,2,3,4,5,6,7 Into Cursor Cur_Lst_Nfs

	Select Cur_Lst_Nfs
	Scan
		xItensPFrm = Iif(n_form=1,pItens1,pItens2)
		If Cnt_Itens < xItensPFrm
			For i = Cnt_Itens+1 To xItensPFrm
				Select vtmp_impressao_nf_00_itens
				Append Blank
				Replace nf With Cur_Lst_Nfs.nf, serie_nf With Cur_Lst_Nfs.serie_nf, filial With Cur_Lst_Nfs.filial, Item_nfe With Cur_Lst_Nfs.Item_nfe,;
					status_nfe With Cur_Lst_Nfs.status_nfe, tipo_emissao_nfe With  Cur_Lst_Nfs.tipo_emissao_nfe, ;
					n_form With Cur_Lst_Nfs.n_form, n_qb_item With Cur_Lst_Nfs.n_qb_item, seq_obs With Cur_Lst_Nfs.seq_obs, item_add With 1
			Endfor
		Endif
	Endscan


	*-- Ajuste t_form
	Select nf,serie_nf,filial,Max(n_form) num_frm From vtmp_impressao_nf_00_itens Group By 1,2,3 Into Cursor CurTmp_MaxFrm
	Select CurTmp_MaxFrm
	Scan
		Select vtmp_impressao_nf_00_itens
		Replace All t_form With CurTmp_MaxFrm.num_frm For  nf=CurTmp_MaxFrm.nf And serie_nf=CurTmp_MaxFrm.serie_nf And filial=CurTmp_MaxFrm.filial
	Endscan


	Return .T.
	*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*



	*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Function F_Dados_NFE_Add()
	Lparameters pComSpace

	Local xCBA_Str,xDV_CBA,xRetDados

	f_select('SELECT TOP 1 f.uf,SUBSTRING(m.COD_MUNICIPIO_IBGE,1,2) as cMun '+;
		'  FROM cadastro_cli_for f  (nolock) '+;
		' INNER JOIN LCF_LX_MUNICIPIO m  (nolock) ON DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE(default,f.cidade) = m.DESC_MUNICIPIO '+;
		' INNER JOIN LCF_LX_UF u (nolock) ON u.uf = f.uf and u.ID_UF = m.ID_UF'+;
		' WHERE f.nome_clifor=?vTmp_impressao_nf_00.nome_clifor','Cur_Info_UF',Alias())

	*- Alterado por Szalontai em 12/03/2012 para atender a TP 2349871
	*	xCBA_Str = RIGHT('00'+ALLTRIM(NVL(Cur_Info_UF.cMun,'99')),2)+;

	xCBA_Str = Right('00'+Alltrim(Iif(F_Vazio(Cur_Info_UF.cMun),'99',Cur_Info_UF.cMun)),2)+;
		RIGHT('0'+Alltrim(Nvl(vTmp_impressao_nf_00.tipo_emissao_nfe,'')),1)+;
		RIGHT(Replicate('0',14)+Alltrim(Nvl(vTmp_impressao_nf_00.cnpj_emitente,'')),14)+;
		RIGHT(Replicate('0',14)+Alltrim(Str(vTmp_impressao_nf_00.valor_total*100)),14)+;
		IIF(vTmp_impressao_nf_00.icms>0,'1','2')+;
		IIF(vTmp_impressao_nf_00.icms_st>0,'1','2')+;
		RIGHT('00'+Alltrim(Str(Day(Ctod(vTmp_impressao_nf_00.emissao)))),2)

	xDV_CBA = F_Mod11_Nfe(xCBA_Str)
	xRetDados = xCBA_Str+xDV_CBA

	If pComSpace
		xRetDados = Subs(xRetDados,1,4)+' '+Subs(xRetDados,5,4)+' '+Subs(xRetDados,9,4)+' '+Subs(xRetDados,13,4)+' '+Subs(xRetDados,17,4)+' '+Subs(xRetDados,21,4)+' '+Subs(xRetDados,25,4)+' '+Subs(xRetDados,29,4)+' '+Subs(xRetDados,33,4)
	Endif

	Return (xRetDados)
	*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*



	*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Function F_Mod11_Nfe()
	Lparameters pStrChave

	Local xStrPeso,xSeqMult,xResAcum,m,xCalc
	xStrPeso = '98765432'

	xSeqMult = 1
	xResAcum = 0
	For m = Len(pStrChave) To 1 Step -1
		xSeqMult = xSeqMult+1
		If xSeqMult>9
			xSeqMult = 2
		Endif
		xResAcum = xResAcum + ( Val(Substr(pStrChave,m,1)) * xSeqMult )
	Endfor

	xCalc = (11 - Mod(xResAcum,11))

	Return Alltrim(Str((xCalc)))
	*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*



	*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Function Fx_GetReportProperty
	Lparameters xObj,strReportField As String

	Return Iif(Type("strReportField") == "C" And !Empty(strReportField) And Type("xObj.SelectedListObject.ListIndex") == "N" And xObj.SelectedListObject.ListIndex >= 0 And ;
		type("xObj.SelectedListObject.ItemValues(xObj.SelectedListObject.ListIndex, strReportField)") == "O" And ;
		!Isnull(xObj.SelectedListObject.ItemValues(xObj.SelectedListObject.ListIndex, strReportField)) , ;
		xObj.SelectedListObject.ItemValues(xObj.SelectedListObject.ListIndex, strReportField).Value, "")

	Return .F.
	*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*



	*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Function Fx_Control_Obj_Export
	Lparameters pStart

	If pStart
		Public oXFRX, intStatusXFRX
		oXFRX = XFRX("XFRX#LISTENER")
		intStatusXFRX = oXFRX.SetParams(ReportExport.Filename,,.T.,,,,ReportExport.CurrentFileFormat)
		Return (intStatusXFRX = 0) && Success
	Else
		oXFRX.finalize()
		Release oXFRX
		Return .T.
	Endif

Endfunc
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*



*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Function F_Load_Ctrl_NF_Financ_Nfe
	Lparameters bLinxERP

	*-- Cursor (Cur_CTB_Parcelas)
	Local xFields As Character, k As Character, k_ As Character
	Store '' To xFields
	For k = 1 To 48
		k_ = Alltrim(Str(k))
		xFields = xFields + Iif(Empty(xFields),'',',') + 'space(15) as Dup_Parc'+k_ + ', 000000000.00 as val_parc'+k_ + ', {} as venc_parc'+k_
	Endfor

	xFields = [nf,serie_nf,filial,NVL(fatura,'') as Fatura,ctb_lancamento,SPACE(LEN(fatura)) as fatura_conf,ctb_item,nome_clifor,origem_nf,cod_transacao,tipo_emissao_nfe,status_nfe,] + xFields
	Select Distinct &xFields From vTmp_impressao_nf_00 Into Cursor Cur_Ctb_Parcelas Readwrite

	*-- Dados
	Select Cur_Ctb_Parcelas
	Scan
		f_select("Select nFat as Fatura,Id_parcela as parcela,nDup as Duplicata,vDup as Valor,dVenc as Vencimento "+;
			"  From dbo.fx_ctb_simula_parcelas('" + Alltrim(Cur_Ctb_Parcelas.filial) + "','" + Alltrim(Cur_Ctb_Parcelas.nf) + "','" + Alltrim(Cur_Ctb_Parcelas.serie_nf) + "','" + Alltrim(Cur_Ctb_Parcelas.Origem_NF) + "','" + Alltrim(Cur_Ctb_Parcelas.cod_transacao) + "') Order by Fatura,Parcela","curTmp_parc",Alias())

		Sele curTmp_parc
		Go Top

		Sele curTmp_parc
		xi_parc = 0
		Scan While !Eof() And xi_parc<48
			xi_parc = xi_parc + 1
			xi		= Alltrim(Str(xi_parc))

			If !Empty(Nvl(Alltrim(curTmp_parc.Duplicata),'')) And Nvl(curTmp_parc.valor,0)>0
				Sele Cur_Ctb_Parcelas
				Replace Dup_Parc&xi  With Nvl(Alltrim(curTmp_parc.Duplicata),''), ;
					Val_parc&xi  With Nvl(curTmp_parc.valor,0),;
					Venc_parc&xi With Nvl(curTmp_parc.vencimento,{})
				Sele curTmp_parc
			Endif

		Endscan

		Sele Cur_Ctb_Parcelas
	Endscan

	Return .T.
	*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*



	*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Function F_Tratar_Len_Itens_DANFE

	*-- Numero de Caracters para quebra de linha (Descricao_Item)
	f_select("Select valor_atual From Parametros Where Parametro='TAMANHO_LINHA_ITEM_DANFE'","CurTmp_TamLin_Item",Alias())
	xLenMax = Val(Nvl(Alltrim(CurTmp_TamLin_Item.valor_atual),''))
	xLenMax = Iif(xLenMax=0,38,xLenMax)

	Select * From vtmp_impressao_nf_00_itens Where .F. Into Cursor Cur_Lst_Itens_Add_Len Readwrite

	Select vtmp_impressao_nf_00_itens
	Scan

		*-- 23/10/2011 - Padial/Beda: Controle da observacao do item
		xObsItem = ''
		If !(Isnull(OBS_ITEM) Or Empty(OBS_ITEM))
			xcarUltimaLinha = Len(Alltrim(Descricao_Item)) % xLenMax
			If xcarUltimaLinha > 0 Then
				xObsItem = Replicate(' ',xLenMax - xcarUltimaLinha)
			Endif
			xObsItem = xObsItem + Alltrim(OBS_ITEM)
		Endif

		xDescItem = Alltrim(Descricao_Item) + xObsItem

		If Len(xDescItem)>xLenMax
			xCountQbLin = 0

			Do Whil !Empty(xDescItem)
				xCountQbLin = xCountQbLin + 1
				xDesItemQb  = Substr(xDescItem,1,xLenMax)

				If xCountQbLin > 1
					Select Cur_Lst_Itens_Add_Len
					Append Blank
					Replace filial 			 With vtmp_impressao_nf_00_itens.filial,;
						nf 				 With vtmp_impressao_nf_00_itens.nf,;
						serie_nf 		 With vtmp_impressao_nf_00_itens.serie_nf,;
						Item_nfe		 With vtmp_impressao_nf_00_itens.Item_nfe,;
						item_impressao	 With vtmp_impressao_nf_00_itens.item_impressao,;
						sub_item_tamanho With vtmp_impressao_nf_00_itens.sub_item_tamanho,;
						status_nfe		 With vtmp_impressao_nf_00_itens.status_nfe,;
						tipo_emissao_nfe With vtmp_impressao_nf_00_itens.tipo_emissao_nfe,;
						item_add		 With vtmp_impressao_nf_00_itens.item_add,;
						seq_obs			 With vtmp_impressao_nf_00_itens.seq_obs,;
						n_qb_item		 With xCountQbLin
				Else
					Select vtmp_impressao_nf_00_itens
				Endif

				Replace Descricao_Item With xDesItemQb
				xDescItem = Substr(xDescItem,xLenMax+1,Len(xDescItem))
			Enddo
		Endif
	Endscan
	*--


	*-- Numero de Caracters para quebra de linha (codigo_item)
	*		xLenMax = 17
	*		xWidthMax = 22	&& Width máximo em função da fonte utilizada no DANFE
	xWidthMax = 22 &&**#6#

	Select vtmp_impressao_nf_00_itens
	Scan
		xCodItem = Alltrim(Codigo_Item)
		xWidthItem = Txtwidth(xCodItem,'Times New Roman',6,'N')	&& Width do código do item em função da fonte
		*!*				If IsDigit(xCodItem)
		*!*					xLenMax = 16
		*!*				Else
		*!*					xLenMax = 11
		*!*				EndIf

		*			IF LEN(xCodItem)>xLenMax
		If xWidthItem > xWidthMax Then	&& Se o width do código do item for maior que o limite
			xCountQbLin = 0

			Do Whil !Empty(xCodItem)
				xCountQbLin = xCountQbLin + 1
				xPosQuebra = F_Quebra_Texto_Fonte(xCodItem, xWidthMax, 'Times New Roman',6,'N')	&& obtém próxima posição de quebra
				xCodItemQb = Left(xCodItem, xPosQuebra)
				*				 	xCodItemQb  = SUBSTR(xCodItem,1,xLenMax)

				If xCountQbLin > 1
					Select Cur_Lst_Itens_Add_Len
					Locate For filial==vtmp_impressao_nf_00_itens.filial And ;
						nf==vtmp_impressao_nf_00_itens.nf And ;
						serie_nf==vtmp_impressao_nf_00_itens.serie_nf And ;
						Item_nfe==vtmp_impressao_nf_00_itens.Item_nfe And ;
						item_impressao==vtmp_impressao_nf_00_itens.item_impressao And ;
						sub_item_tamanho==vtmp_impressao_nf_00_itens.sub_item_tamanho And ;
						item_add==vtmp_impressao_nf_00_itens.item_add And ;
						n_qb_item==xCountQbLin
					If Eof()
						Append Blank
						Replace filial 			 With vtmp_impressao_nf_00_itens.filial,;
							nf 				 With vtmp_impressao_nf_00_itens.nf,;
							serie_nf 		 With vtmp_impressao_nf_00_itens.serie_nf,;
							Item_nfe		 With vtmp_impressao_nf_00_itens.Item_nfe,;
							item_impressao	 With vtmp_impressao_nf_00_itens.item_impressao,;
							sub_item_tamanho With vtmp_impressao_nf_00_itens.sub_item_tamanho,;
							status_nfe		 With vtmp_impressao_nf_00_itens.status_nfe,;
							tipo_emissao_nfe With vtmp_impressao_nf_00_itens.tipo_emissao_nfe,;
							item_add		 With vtmp_impressao_nf_00_itens.item_add,;
							seq_obs			 With vtmp_impressao_nf_00_itens.seq_obs,;
							n_qb_item		 With xCountQbLin
					Endif
				Else
					Select vtmp_impressao_nf_00_itens
				Endif

				Replace Codigo_Item With xCodItemQb
				xCodItem = Substr(xCodItem,xPosQuebra + 1, Len(xCodItem))	&& Estabelece o código restante
				*					xCodItem = SUBSTR(xCodItem,xLenMax+1,LEN(xCodItem))
			Enddo
		Endif
	Endscan
	*--


	*--
	If Reccount('Cur_Lst_Itens_Add_Len')>0
		Insert Into vtmp_impressao_nf_00_itens Select * From Cur_Lst_Itens_Add_Len
	Endif

	Select filial,nf,serie_nf,item_impressao,Item_nfe,Max(n_qb_item) max_n_qb_item ;
		FROM vtmp_impressao_nf_00_itens Where n_qb_item>1 Group By 1,2,3,4,5 Into Cursor CurTmp_Controle_Ult_ItemQb

	Select CurTmp_Controle_Ult_ItemQb
	Scan && Controle (identifica ultimo Item adicionado para uso na linha de separação)
		Select vtmp_impressao_nf_00_itens
		Locate For  filial==CurTmp_Controle_Ult_ItemQb.filial And nf==CurTmp_Controle_Ult_ItemQb.nf And serie_nf==CurTmp_Controle_Ult_ItemQb.serie_nf;
			AND item_impressao==CurTmp_Controle_Ult_ItemQb.item_impressao ;
			AND Item_nfe==CurTmp_Controle_Ult_ItemQb.Item_nfe And n_qb_item==CurTmp_Controle_Ult_ItemQb.max_n_qb_item
		If !Eof()
			Replace ult_n_qb_item With .T.
		Endif
	Endscan
	*--

	Return .T.
	*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*

Function F_Quebra_Texto_Fonte() && Quebra o texto em função da fonte retornando a posição da quebra
	Lparameters pTexto, pWidthMax, pFonteNome, pFonteTamanho, pFonteEstilo

	xTexto = pTexto
	xWidthTexto = Txtwidth(xTexto, pFonteNome, pFonteTamanho, pFonteEstilo)
	Do While xWidthTexto > pWidthMax
		xTexto = Left(xTexto,Len(xTexto)-1)
		xWidthTexto = Txtwidth(xTexto, pFonteNome, pFonteTamanho, pFonteEstilo)
	Enddo
	xPosicaoQuebra = Len(xTexto)


	Return xPosicaoQuebra


	*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Function F_Quebra_Obs_Frm_DANFE() && Form Control
	Lparameters pObs,pLenObsFrm

	*-- Vs-Lx   : 23/10/2011: Tratamento para Obs do Item

	xLim_TamLin = Int(Val(Substr(xLenObsFrm,At('/',xLenObsFrm)+1,Len(xLenObsFrm))))
	xLim_LinFrm = Int(Val(Substr(xLenObsFrm,1,At('/',xLenObsFrm)-1)))

	*-- Tamanho das Linhas
	Declare xObsLines(1)
	xObs = Alltrim(Strt(pObs,Chr(10),''))
	xObs = Strt(xObs,' = ','=')
	xLim_TamLin = Iif(xLim_TamLin=0,Len(xObs),xLim_TamLin)

	xCountLin = 0
	Do Whil !Empty(xObs)

		xLin_txt = Substr(xObs,1,xLim_TamLin)
		If At(Chr(13),xLin_txt)>0
			xLin_txt = Substr(xLin_txt,1,At(Chr(13),xLin_txt))
			xObs = Substr(xObs,At(Chr(13),xLin_txt)+1,Len(xObs))
		Else
			If Substr(xObs,xLim_TamLin,1)=Chr(13) Or Empty(Substr(xObs,xLim_TamLin+1,1))
				xLin_txt = Strt(xLin_txt,Chr(13),'')
				xObs	 = Substr(xObs,xLim_TamLin+1,Len(xObs))
			Else
				For u = Len(xLin_txt) To 1 Step -1
					If Empty(Substr(xLin_txt,u,1)) Or Substr(xLin_txt,u,1)=Chr(13) Or Inlist(Substr(xLin_txt,u,1),'/','\','-','.')  &&#2#
						xLin_txt = Substr(xLin_txt,1,u)
						xObs = Substr(xObs,u+1,Len(xObs))
						Exit
					Endif
				Endfor
			Endif
		Endif

		xCountLin = xCountLin+1
		Declare xObsLines(xCountLin)
		xObsLines(xCountLin) = Strt(xLin_txt,Chr(13),'')
		xObs = Iif(Left(xObs,1)=Chr(13),Substr(xObs,2,Len(xObs)),xObs)
	Enddo


	*-- Linhas por formulário
	If Used('Cur_Ctrl_ObsForm')
		Use In Cur_Ctrl_ObsForm
	Endif

	Create Cursor Cur_Ctrl_ObsForm(id_form N(1),Obs_Form m(4))
	Select Cur_Ctrl_ObsForm
	Append Blank
	Replace id_form With 1

	If xCountLin > 0
		xCount_Frm    = 1
		xCountLin_Frm = 0
		For kL =  1 To Alen(xObsLines)
			xCountLin_Frm = xCountLin_Frm+1
			If xCountLin_Frm> xLim_LinFrm
				xCount_Frm = xCount_Frm + 1
				xCountLin_Frm = 1
				Append Blank
				Replace id_form With xCount_Frm In Cur_Ctrl_ObsForm
			Endif
			Replace Obs_Form With Iif( Empty(Obs_Form) , xObsLines(kL) , Alltrim(Obs_Form)+Chr(13) + xObsLines(kL) )
		Endfor
	Endif

	Return .T.
	*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
