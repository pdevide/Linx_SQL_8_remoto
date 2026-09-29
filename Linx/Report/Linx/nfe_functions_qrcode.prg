*-- Objetivo: Funcões Impressão da DANFE QRCODE - SIMPLIFICADA (Nota Fiscal Eletrônica)
*-- Marcelo Freitas   : 30/06/2026: #45# - ENTERMODA-41280 - Linx ERP - NF-e - Criação da DANFE Simplificado - Tipo 2 - (NT2026.003 - v1.00 e NT2026.002 - v1.00)

*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*

*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Procedure PrintNfe
	Lparameter xTipo,xObj,strSerie_NF,intQtdeVias,FormMain
		
	Local bLinxErp As boolean, strFilial As String, strNf_numero As String, bModelo_Simplificado As boolean, bModelo_Simplificado_QrCode As Boolean, bUsaDanfeSimplificado As Boolean
	Public xkimp
	bLinxErp = Pcount() == 2
	
	intQtdeVias = Iif(Type("intQtdeVias") != "N" Or (Type("intQtdeVias") == "N" And intQtdeVias < 1), 1, Iif(intQtdeVias > 5, 5, intQtdeVias))

	If bLinxErp 
		&& Danfe Simplificado
		bModelo_Simplificado = Iif(Type("xObj.p_DANFE_Simplificado") = 'U', .F., Nvl(xObj.p_DANFE_Simplificado,.F.)) && #33# #35#
		
		&& Danfe Simplificado com QRCode 
		bModelo_Simplificado_QrCode = Iif(Type("xObj.p_DANFE_Simplificado_QrCode") = "U", .F., Nvl(xObj.p_DANFE_Simplificado_QrCode,.F.)) &&#45#
	Else
		&& Danfe Simplificado
		bModelo_Simplificado = Iif(Type("FormMain.p_DANFE_Simplificado") = 'U', .F., Nvl(FormMain.p_DANFE_Simplificado,.F.)) && #33# #35#
		
		&& Danfe Simplificado com QRCode
		bModelo_Simplificado_QrCode = Iif(Type("FormMain.p_DANFE_Simplificado_QrCode") = "U", .F., Nvl(FormMain.p_DANFE_Simplificado_QrCode,.F.)) &&#45#

		strFilial = Rtrim(xTipo)
		strNf_numero = Alltrim(xObj)
		xTipo = 'IMP'
		Public wwlogo As String
		wwlogo  = Addbs(FormMain.systempath) + "Reports\LogoReport.png"
		
		If !File(wwlogo)
			msgbox('Logo não encontrado: ' + wwlogo, 64 ,'Atenção')
			Release wwlogo
			Return .F.
		Endif
	
	Endif

	f_select("Select valor_atual From Parametros Where Parametro='LOGO_EXCLUSIVO_DANFE'","CurTmp_LogoDanfe",Alias())
	xtmplogo = Nvl(Alltrim(curtmp_logodanfe.valor_atual),'')
	If !Empty(xtmplogo) And File(xtmplogo)
		wwlogo = xtmplogo
	Endif

	xsele    = Select()
	xdefault = Sys(5) + Sys(2003)

	If bLinxErp
		xcodigoreport = Left(Justfname(fx_getreportproperty(xObj,'ReportProgramFile')), 8)
		xreportfile   = fx_getreportproperty(xObj,'ReportFile')
		xdirrel  	  = Substr(xreportfile,1,(At(xcodigoreport,xreportfile))-1)
	Endif

	xok = Iif(Type('ReportExport')='O',fx_control_obj_export(.T.),.T.)
	If !xok
		Return .F.
	Endif

	If Type('ReportExport')='O'
		xsaida1  = 'Object oXFRX NOPAGEEJECT'
		xsaida2  = 'Object oXFRX NOPAGEEJECT NORESET'
		xlenobsfrm = '9/133' && Limite de Linhas/Caracteres por linha no campo de observações (por formulário)
	Else
		xsaida1  = Iif(Upper(xTipo)='PRE','Preview NOPAGEEJECT','noConsole to Printer' + Iif(bLinxErp, ' Prompt NOPAGEEJECT', ''))
		xsaida2  = Iif(Upper(xTipo)='PRE','Preview NOPAGEEJECT NORESET','noConsole to Printer' + Iif(bLinxErp, ' NOPAGEEJECT NORESET', ''))
		xlenobsfrm = '8/139' && Limite de Linhas/Caracteres por linha no campo de observações (por formulário)
	Endif
	
	*--Inicio Geração de Arquivos em PDF 
	If Upper(xTipo)='PDF'
		oXFRX = XFRX("XFRX#LISTENER")
		pFileDest_ = o_100108.px_diretorio
		pFileDest_ = pFileDest_ + "\"+ Alltrim(nf) + "_" + Alltrim(serie_nf) + "_" + SUBSTR(SYS(2015), 6) + ".pdf"
		intStatusXFRX = oXFRX.SetParams(pFileDest_,,.T.,,,,xTipo)
		xsaida1 = "Object oXFRX NOPAGEEJECT"
		xsaida2  = 'Object oXFRX NOPAGEEJECT NORESET'
	EndIf
	*--Fim Geração de Arquivos em PDF 

	*-- Itens por formulário para o DANFE
	f_select("Select valor_atual From Parametros Where Parametro='ITENS_P_FORM_DANFE'","CurTmp_Itens_p_form",Alias())
	xitenspd  = Nvl(Alltrim(curtmp_itens_p_form.valor_atual),'')

	xitenspd1 = Val(Iif(Atc('/',xitenspd,1)=0,'',Substr(xitenspd,1,Atc('/',xitenspd,1)-1)))																						&& Primeiro Formulário
	xitenspd2 = Val(Iif(Atc('/',xitenspd,1)=0,'',Substr(xitenspd,Atc('/',xitenspd,1)+1,Iif(Atc('/',xitenspd,2)>0,(Atc('/',xitenspd,2)-Atc('/',xitenspd,1)-1),Len(xitenspd))))) 	&& Segundo  Formulário
	xitenspd3 = Val(Iif(Atc('/',xitenspd,2)=0,'',Substr(xitenspd,Atc('/',xitenspd,2)+1,Len(xitenspd))))																			&& Terceiro Formulário

	xitenspd1 = Iif(xitenspd1>0,xitenspd1,16) && Padrão Primeiro Formulário
	xitenspd2 = Iif(xitenspd2>0,xitenspd2,46) && Padrão Segundo  Formulário
	xitenspd3 = Iif(xitenspd3>0,xitenspd3,46) && Padrão Terceiro Formulário

	If bLinxErp
		If !fx_danfe_init(xitenspd1,xitenspd2,xitenspd3,xlenobsfrm) && -- #30#
			Return .F.
		Endif
	Else
		If !fx_danfe_init(xitenspd1,xitenspd2,xitenspd3,xlenobsfrm,strFilial,strNf_numero,strSerie_NF,intQtdeVias,FormMain) && -- #30#
			Return .F.
		Endif
	Endif

	&&#45#
	If bLinxErp

    	Do Case

	        Case bModelo_Simplificado_QrCode
	            plst_reports_1 = xdirrel + 'L_DANFE_SIMP_QRCODE.FRX'
	            plst_reports_2 = ''
	            plst_reports_3 = ''

	        Case bModelo_Simplificado
	            plst_reports_1 = xdirrel + 'L_DANFE_SIMP.FRX'
	            plst_reports_2 = ''
	            plst_reports_3 = ''

	        Otherwise
	            plst_reports_1 = xdirrel + 'L_DANFE1.FRX'
	            plst_reports_2 = xdirrel + 'L_DANFE2.FRX'
	            plst_reports_3 = xdirrel + 'L_DANFE3.FRX'

	    EndCase

	Else

	    Do Case

	        Case bModelo_Simplificado_QrCode
	            plst_reports_1 = Addbs(FormMain.systempath) + 'Reports\L_DANFE_SIMP_QRCODE.FRX'
	            plst_reports_2 = ''
	            plst_reports_3 = ''
	   
	        Case bModelo_Simplificado
	            plst_reports_1 = Addbs(FormMain.systempath) + 'Reports\L_DANFE_SIMP.FRX'
	            plst_reports_2 = ''
	            plst_reports_3 = ''

	        Otherwise
	            plst_reports_1 = Addbs(FormMain.systempath) + 'Reports\L_DANFE1.FRX'
	            plst_reports_2 = Addbs(FormMain.systempath) + 'Reports\L_DANFE2.FRX'
	            plst_reports_3 = plst_reports_2

	    EndCase

	Endif
    &&#45#
	
	plst_reports_1_cr = Strt(plst_reports_1,'FRX','RPT')

	If !File(plst_reports_1)
		If !File(plst_reports_1_cr)
			If bLinxErp
				Messagebox('Report Não Encontrado: ' + Chr(13)+plst_reports_1,16,'Atenção')
			Else
				msgbox('Report Não Encontrado:\n' + plst_reports_1, -16, 'Atenção')
			Endif
			Return .F.
		Else
			plst_reports_1 = plst_reports_1_cr
		ENDIF
	ENDIF
	
	&&#45#
	bUsaDanfeSimplificado = bModelo_Simplificado Or bModelo_Simplificado_QrCode
	&&#45#
	
	If Justext(plst_reports_1)='FRX' And (!bUsaDanfeSimplificado And !File(plst_reports_2)) && -- #33# e &&#45#
		If bLinxErp
			Messagebox('Report Não Encontrado: ' + Chr(13) + plst_reports_2,16,'Atenção')
		Else
			msgbox('Report Não Encontrado:\n' + plst_reports_2, -16, 'Atenção')
		Endif
		Return .F.
	Endif

	*-- Envia para saida
	Select Distinct nf,serie_nf,filial,n_form,frm_aux,t_form,.F. As is_ultimo From vtmp_impressao_nf_00_itens Into Cursor cur_lst_danfe_emitir Readwrite && -- #30#
	Select cur_lst_danfe_emitir
	Go Bottom
	Replace is_ultimo With .T.

	Local intcountreports As Integer, bpriterror As boolean, strmessage As String
	For intcountreports = 1 To intQtdeVias
		If !bLinxErp And intcountreports > 1
			FormMain.setmessage("Imprimindo " + Transform(intcountreports, '9.999') + "ª via...")
		Endif

		If bLinxErp And Justext(fx_getreportproperty(xObj,'ReportFile'))='RPT' && -- Gera Arquivos Externos (Para o Crystal)
			xObj.copytables("vTmp_impressao_nf_00")
			xObj.copytables("vTmp_impressao_nf_00_itens")
			xObj.copytables("Cur_FrmNfe_Obs")
			xObj.copytables("Cur_Ctb_Parcelas")
		Else
			Select Max(t_form) t_form From cur_lst_danfe_emitir Into Cursor curchk_t_form

			If curchk_t_form.t_form=1 && Mais Rápido quando só existe NFe's de uma via no lote.
				Select vtmp_impressao_nf_00_itens
				Go Top
				xsaida = xsaida1
				xsaida = Strt(Strt(xsaida,'NOPAGEEJECT',''),'NORESET','')
				Try
					Report Form (plst_reports_1) &xsaida && Impressão
				Catch To oprintererror
					strmessage = Alltrim(Str(oprintererror.ErrorNo)) + " - " + Alltrim(oprintererror.Message)
					If bLinxErp
						Messagebox(strmessage, -16, "Atenção")
					Else
						msgbox(strmessage, -16, "Atenção")
					Endif
				Endtry
			Else
				Select cur_lst_danfe_emitir
				xratu = 0
				Scan
					xratu = xratu+1
					xkimp = Alltrim(filial)+Alltrim(nf)+Alltrim(serie_nf)+Str(n_form)

					Select vtmp_impressao_nf_00_itens
					Set Filter To Alltrim(filial)+Alltrim(nf)+Alltrim(serie_nf)+Str(n_form)==xkimp
					Go Top
					xsaida = Iif(xratu=1,xsaida1,xsaida2)
					If cur_lst_danfe_emitir.is_ultimo
						xsaida = Strt(Strt(xsaida,'NOPAGEEJECT',''),'NORESET','')
					Endif

					If n_form=1
						Try
							Report Form (plst_reports_1) &xsaida && Impressão
						Catch To oprintererror
							strmessage = Alltrim(Str(oprintererror.ErrorNo)) + " - " + Alltrim(oprintererror.Message)
							If bLinxErp
								Messagebox(strmessage, -16, "Atenção")
							Else
								msgbox(strmessage, -16, "Atenção")
							Endif
						Endtry
					Else
						Try
							If cur_lst_danfe_emitir.frm_aux And !Empty(plst_reports_3) And File(plst_reports_3) 
								Report Form (plst_reports_3) &xsaida  && Impressão
							Else
								If !Empty(plst_reports_2) And File(plst_reports_2) 
									Report Form (plst_reports_2) &xsaida 
								Endif
							Endif
						Catch To oprintererror
							strmessage = Alltrim(Str(oprintererror.ErrorNo)) + " - " + Alltrim(oprintererror.Message)
							If bLinxErp
								Messagebox(strmessage, -16, "Atenção")
							Else
								msgbox(strmessage, -16, "Atenção")
							Endif
						Endtry
					Endif

					If bpriterror
						Return .F.
					Endif
					
					If Type('ReportExport') = 'O'    
						fx_control_obj_export(.F.) 
					Endif
					
				Endscan
				*
			Endif

			If !bLinxErp
				FormMain.setmessage()
			Endif
		Endif
	Endfor

	xsenttoprinter = .T.
	If Type('ReportExport')='O'
		fx_control_obj_export(.F.)
	Endif

	fx_danfe_destroy(bLinxErp)

	If bLinxErp and Alltrim(Upper(xTipo)) <> 'PDF' && Alterado para exportação de PDF no monitor
		try
			Set Default To &xdefault
		Catch 
			Set Default To Curdir()
		EndTry
		
	Endif

	Try
		Select (xsele)
	Catch
	Endtry

Endproc
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*

*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Function fx_danfe_init
	Lparameters pitens1,pitens2,pitens3,plenobsfrm,strFilial,strNf_numero,strSerie_NF,intQtdeVias,FormMain 
	
	Local bLinxErp As boolean, lcTexto as String, lcUrlQR as String, lcUrlConsulta as String, lcChave as String, lcVersaoQRCode as String, lcAmbiente as String
	Local lcParametros as String, lcUrlFinalQRCode as String, lcUrlBaseQRCode as String, Msg_Trib 

	Public wwqrcode, loQrCode
	
	bLinxErp = Pcount() == 4  

	*-- NF-e (D.A.N.F.E.)
	Public x_proce,ximp_dsai,ext1,ext2,ext3,xsenttoprinter

	xsenttoprinter = .F.
	ximp_dsai = .T. 

	If bLinxErp
		x_proce = Set('PROCE')
		Set Procedure To ..\Report.prg\l002016.prg Additive && Barcodes Retaguarda
		xfilterpai = Strt(o_100108.p_comando_where,'W_IMPRESSAO_NF.','W_IMPRESSAO_NFe.')
		xfilterpai = xfilterpai + Iif(Empty(xfilterpai),'',' AND ') + " Empresa='" + Alltrim(Str(wempresa_atual)) + "'"
		xfilterpai = xfilterpai + Iif(Empty(xfilterpai),'',' AND ') + ' Chave_NFe is Not Null AND ((Status_nfe in (5,6,9)) OR (Tipo_emissao_nfe=4 OR Tipo_emissao_nfe=5))' &&#11#
		xfilterpai = xfilterpai + Iif(Empty(xfilterpai),'',' AND ') + [ origem_nf in ('S', 'E')]
	Else
		xfilterpai = "NF = '" + Alltrim(strNf_numero) + "' and Serie_NF = '" + Alltrim(strSerie_NF) + "' and Filial = '" + Rtrim(strFilial) + "'"
	Endif
 
	TEXT TO xSqlNFE_Pai NOSHOW TEXTMERGE
				SELECT filial,nf,serie_nf,chave_nfe,Origem_NF,Importacao,status_nfe,CAST(tipo_emissao_nfe AS varchar(1)) as tipo_emissao_nfe,convert(varchar(10), emissao, 103) as emissao,empresa, IsNull(ctb_lancamento,0) as ctb_lancamento, IsNull(ctb_item,0) as ctb_item,cod_transacao,convert(varchar(10), data_saida, 103) as data_saida, hora_saida, VEICULO_PLACA, UF_PLACA_VEICULO,
					   nome_clifor,IsNull(fatura,0) as fatura,desc_nf_natureza,pj_pf,CNPJ_DESTINATARIO AS CGC_CPF,razao_social_emitente,cnpj_emitente,endereco_emitente,numero_emitente,complemento_emitente,bairro_emitente,cidade_emitente,uf_emitente,pais_emitente,cep_emitente,ddd1_emitente, substring(telefone1_emitente, 3, len(telefone1_emitente)) as telefone1_emitente,ie_emitente,iest,pj_pf_emitente,razao_social,
					   endereco,numero,complemento,bairro,cep,cidade,ddi,RIGHT(RTRIM(ddd1),2) as ddd1, RTRIM(dbo.FX_REPLACE_CARACTER_ESPECIAL_NFe(1,SUBSTRING(TELEFONE1,3,LEN(TELEFONE1)))) as telefone1,
					   uf,case when pj_pf=0 then '' else rg_ie end as rg_ie,icms_base,icms,icms_st_base = icms_st_base + icms_str_base,icms_st = icms_st+icms_str,icms_str_base,icms_str,valor_sub_itens,
					   Case When Importacao=1 and Danfe_NFe_Importacao_Calc='.T.' Then (IMPORTACAO_ALFANDEGA+IMPORTACAO_OUTRAS_DESPESAS+IMPORTACAO_SEGURO+IMPORTACAO_DESEMBARACO+PIS+COFINS) Else encargo End as encargo,
					   frete,seguro,(desconto + pis_zf + cofins_zf) as desconto,desconto_cond_pgto,ipi,valor_total,TRANSPORTADORA as transportadora_razao_social,
					   Case When Entrega_cif=0 then cast(1 as numeric) else case when Entrega_cif = 1 then cast(0 as numeric) else Cast(entrega_cif AS numeric) end end as entrega_cif,
					   Case When Entrega_cif=1 THEN 'Emitente' ELSE Case When Entrega_cif=0 THEN 'Destinatário' ELSE Case When Entrega_cif=2 THEN 'Terceiros' ELSE Case When Entrega_cif=9 THEN 'Sem Frete' ELSE case when Entrega_cif=4 then 'Próprio Destinatário' else case when Entrega_cif=3 then 'Próprio Remetente' else '' END END END END END END  as desc_entrega_cif,
					   TRANSPORTADORA_PF_PJ, transportadora_cnpj,transportadora_endereco,transportadora_cidade,transportadora_uf,transportadora_ie,volumes,tipo_volume,marca_volumes,numeracao_volumes,peso_bruto,peso_liquido,IM_EMITENTE as im,(iss + ISS_R) as iss, (iss_base +ISS_R_BASE) as iss_base  ,valor_desconto_itens,valor_sub_itens_bruto,
					   rtrim(isnull(cod_serie_sintegra,case when serie_nf = 'U' OR serie_nf = 'UN' then '0' else Rtrim(serie_nf) end)) as serie_danfe, Obs, Texto_Legal,Obs_Interesse_Fisco, data_contingencia, justificativa_contingencia,
					   CASE When Entrega_Endereco Is Not Null AND (rtrim(IsNull(Endereco,''))+rtrim(IsNull(Numero,''))+rtrim(IsNull(Complemento,'')))<>(rtrim(IsNull(Entrega_Endereco,''))+rtrim(IsNull(Entrega_Numero,''))+rtrim(IsNull(Entrega_Complemento,'')))
					   Then IsNull('ENTREGA: '+rTrim(entrega_endereco),'') + IsNull(', '+rTrim(entrega_numero),'') + IsNull(' - ' + rTrim(entrega_complemento),'') + ' - ' + IsNull(rTrim(entrega_bairro),'') + ' - ' + IsNull(rTrim(entrega_cidade),'') + '/' + IsNull(rTrim(entrega_uf),'') + IsNull(' - CEP: ' + rTrim(entrega_cep),'') + Case When pj_pf=1 Then IsNull(' - CNPJ: '+rTrim(entrega_cgc),'') Else IsNull(' - CPF: ' + rTrim(entrega_cgc),'') End Else '' End as Obs_Entrega,
					   INFO_PGTO, cod_filial, Convert(bit,0) as Mostra_Tot_NF_DANFE_Simp, Convert(bit,Mostra_Retirada) AS Mostra_Retirada,
					   nome_local_retirada, retirada_entrega_razao_social, retirada_entrega_endereco, retirada_entrega_numero, retirada_entrega_complemento, retirada_entrega_cidade, retirada_entrega_uf, retirada_entrega_bairro, retirada_entrega_cep, retirada_entrega_telefone, retirada_entrega_ddd, retirada_entrega_ddi, retirada_entrega_cgc, retirada_entrega_ie, retirada_pj_pf,
					   retirada_entrega_tel_str = isnull(rtrim(ltrim(isnull(ddi,''))) + (case when len(rtrim(ltrim(isnull(telefone1,'')))) > 8 then ' ' else ' (' + rtrim(ltrim(isnull(ddd1,''))) + ') ' end) + rtrim(ltrim(isnull(telefone1,''))),''), Space(300) as url_qrCode, Space(150) as Link_Sefaz,
					   desc_condicao_pgto, protocolo_autorizacao_nfe, data_autorizacao_nfe, 0 as Valor_Cbs, 0 as Valor_Ibs, 0 as Valor_Is, convert(varchar(8), emissao, 108) as emissao_danfe, Space(300) as endereco_destino, Space(500) as Msg_Trib  
				  From W_IMPRESSAO_NFE Where <<xFilterPai>>
	ENDTEXT
	&&#45#
	
	f_select(xsqlnfe_pai, "vTmp_impressao_nf_00")
	If Reccount('vTmp_impressao_nf_00') = 0
		Messagebox('Nenhuma NFe Válida Selecionada no Filtro:'+Chr(13) + (xfilterpai),48,'Aviso')
		Return .F.
	ENDIF
	
	&&#45#
	uf = alltrim(vTmp_impressao_nf_00.uf)
	lcChave = alltrim(vTmp_impressao_nf_00.chave_nfe)
	lcVersaoQrCode = '3' && Versão do QRCode
	endComp = alltrim(vTmp_impressao_nf_00.CGC_CPF) + ' ' + alltrim(vTmp_impressao_nf_00.endereco) + ', ' + alltrim(vTmp_impressao_nf_00.numero) + ', ' + alltrim(vTmp_impressao_nf_00.bairro) + ' - ' +  alltrim(vTmp_impressao_nf_00.cidade) +  ' - ' + alltrim(vTmp_impressao_nf_00.uf) + ' - ' + alltrim(vTmp_impressao_nf_00.cep)	
		
	Text To csql22 Textmerge NoShow
		Select Isnull(ibs_est_valor,0) as Valor_IBS, Isnull(cbs_valor,0) as Valor_CBS, Isnull(is_valor,0) as Valor_IS	
		From W_impressao_nfe 
		Where nf = ?vTmp_impressao_nf_00.nf
		And Serie_nf = ?vTmp_impressao_nf_00.serie_nf
		And Filial = ?vTmp_impressao_nf_00.filial
	Endtext
	f_select(csql22, "Consulta_Valor")
	
	If Used("Consulta_Valor") AND Reccount("Consulta_Valor") > 0
		Select vTmp_impressao_nf_00
		Replace all vTmp_impressao_nf_00.Valor_IBS With Consulta_Valor.Valor_IBS
		Replace all vTmp_impressao_nf_00.Valor_CBS With Consulta_Valor.Valor_CBS
		Replace all vTmp_impressao_nf_00.Valor_IS With Consulta_Valor.Valor_IS
	Endif
		
	Text To csql1 Textmerge NoShow
		Select top 1 Isnull(ambiente, 2) as ambiente  From integracoes_api Where sistema = 'Fiscal Flow'	
	Endtext
	f_select(csql1, "Consulta_amb")
	
	If Reccount("Consulta_amb") = 0    
		Messagebox("Não foi possível identificar o ambiente (Produção/Homologação)." + CHR(13) + "Verifique o cadastro da integração Fiscal Flow.", 16, "Atenção")    
		Return .F.
	Endif
	
	lcAmbiente =  alltrim(str(Consulta_amb.ambiente)) && 1=Produção / 2=Homologação
	
	Text To csql Textmerge NoShow
		Select isnull(tpamb,2) as tpamb, url_consulta
		From sefaz_qrcode
		Where uf = '<<uf>>'
		And tpamb = '<<lcAmbiente>>' 
	Endtext
	f_select(csql, "Consulta_url")

	If Reccount("Consulta_url") = 0    
		Messagebox("Não foi possível identificar a URL de Consulta (Produção/Homologação)." + CHR(13) + "Verifique o cadastro das URLs na Tabela Sefaz QRCode.", 16, "Atenção")    
		Return .F.
	Endif

	lcUrlConsulta = alltrim(Consulta_url.url_consulta)  
	
	**Tratamento de todas as URLs	
	lcUrlBaseQRCode = Strtran(lcUrlConsulta, "nfce-consulta","qrcode")
	lcUrlBaseQRCode = Strtran(lcUrlConsulta, "nfeconsulta2", "qrcode")	
	lcUrlBaseQRCode = Strtran(lcUrlConsulta, "nfeconsulta", "qrcode")
	lcUrlBaseQRCode = Strtran(lcUrlConsulta, "consulta", "qrcode")
	lcParametros = lcChave + "|" + lcVersaoQRCode + "|" + lcAmbiente
	lcUrlFinalQRCode = lcUrlBaseQRCode + "?p=" + lcParametros

	**Versão por QuickChar API
	lcTexto = lcChave + "|" + lcVersaoQRCode + "|" + lcAmbiente + "|" + lcUrlConsulta
	* URL Encode
	lcTexto = Strtran(lcTexto,"|","%7C")
	lcTexto = Strtran(lcTexto,":","%3A")
	lcTexto = Strtran(lcTexto,"/","%2F")
	
	lcUrlQR = "https://quickchart.io/qr?width=150&height=150&text=" + lcTexto
	**Versão por QuickChar API

	lcTemp = ADDBS(SYS(2023))

	If !Directory(lcTemp)
    	Createpath(lcTemp) && Tenta criar a pasta se não existir
	Endif

	If !Directory(lcTemp)
	    Messagebox("A pasta TEMP não existe:" + CHR(13) + lcTemp)
	    Return .F.
	Endif

	*--- Teste de gravação simples na pasta TEMP
	lcTeste = lcTemp + "teste.tmp"
	Try
	    Strtofile("Teste", lcTeste)
	    IF !File(lcTeste)
	        Messagebox("Sem permissão para gravar na pasta:" + CHR(13) + lcTemp)
	        Return .F.
	    Endif
	    Delete File (lcTeste)
	Catch To loErro
	    Messagebox("Erro ao gravar na pasta TEMP:" + CHR(13) + loErro.Message)
	    Return .F.
	Endtry

	*--- Definição correta do nome do arquivo (sem barras duplicadas)
	lcArquivoQR = lcTemp + "QRCode_" + lcChave + ".jpg"

	*--- Se o arquivo já existir de um teste anterior, apaga para evitar conflito
	If File(lcArquivoQR)
	    Try
	        Delete File (lcArquivoQR)
	    Catch
	        * Arquivo pode estar travado por outro processo
	    Endtry
	Endif
	
	*--- Instancia a DLL do QR Code apenas uma vez
	Try
        If Type("loQRCode") <> "O"
			loQRCode = CREATEOBJECT("FoxQRCode.QRCode") 
		Endif
	    
	Catch To loErro
	    Messagebox("A DLL do QRCode não está instalada ou não foi registrada no servidor." + CHR(13) + "Instale e registre o componente FoxQRCode antes de gerar o QR Code.", 48, "Erro FoxQRCode")
	    Return .F.
	Endtry

	*--- Gera o QR Code
	Try
	    lnRetorno = loQRCode.ViewQRCode(lcUrlFinalQRCode, "", 150, 150, lcArquivoQR, 0, 0)

	    If !File(lcArquivoQR)
	        Messagebox("O QRCode não foi criado fisicamente no servidor." + CHR(13) + "Retorno da DLL: " + TRANSFORM(lnRetorno) + CHR(13) + "Caminho tentado: " + lcArquivoQR)
	        Return .F.
	    Endif

	Catch To loErro
	    Messagebox("Erro ao gerar o QRCode:" + CHR(13) + loErro.Message + CHR(13) + "Erro No: " + TRANSFORM(loErro.ErrorNo))
	    Return .F.
	Endtry

	*--- Libera o objeto da memória imediatamente para não travar a imagem PNG
	loQRCode = Null
	INKEY(0.5)

	Select vTmp_impressao_nf_00
	Replace all vTmp_impressao_nf_00.url_qrCode With lcArquivoQR
	Replace all vTmp_impressao_nf_00.Link_Sefaz With lcUrlConsulta 
	Replace all vTmp_impressao_nf_00.endereco_destino With endComp 
	
	wwqrcode = lcArquivoQR 
	&&#45#
	
	f_select("SELECT cod_filial, valor_atual From PARAMETROS_RETAGUARDA_FILIAL WHERE PARAMETRO='MOSTRA_TOT_NF_DANFE_SIMP'",'CurTmp_MostraTotNfDanfeSimp',ALIAS())
	SELECT Distinct cod_filial FROM vTmp_impressao_nf_00 INTO CURSOR CurLst_Filiais
	SELECT CurLst_Filiais
	SCAN
		SELECT CurTmp_MostraTotNfDanfeSimp
		LOCATE FOR cod_filial==CurLst_Filiais.cod_filial
		IF FOUND()
			SELECT vTmp_impressao_nf_00
			REPLACE ALL Mostra_Tot_NF_DANFE_Simp WITH (ALLTRIM(NVL(CurTmp_MostraTotNfDanfeSimp.valor_atual,''))=='.T.') FOR cod_filial==CurLst_Filiais.cod_filial
		ENDIF		
	ENDSCAN

	If vTmp_impressao_nf_00.cod_transacao = "LX400001_001"
		sqlinfo=''
		TEXT TO sqlinfo NOSHOW TEXTMERGE
							SELECT TOP 1 INFO_PGTO
							From W_INFORMACAO_PAGAMENTO
							Where nf=?vTmp_impressao_nf_00.nf and serie_nf=?vTmp_impressao_nf_00.serie_nf and filial=?vTmp_impressao_nf_00.filial
							AND INFO_PGTO IN ('02','03','14','15')
		ENDTEXT
		f_select(sqlinfo, "cur_info")
		If Used("cur_info") And Reccount("cur_info")>0
			SELECT vTmp_impressao_nf_00
			Replace INFO_PGTO With cur_info.INFO_PGTO
		Endif
	Endif

	* Diferimento ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	If vtmp_impressao_nf_00.origem_nf='S' 
		TEXT TO xSqlNFE_Diferimento NOSHOW
				SELECT  ABS(SUM(CASE FATURAMENTO_IMPOSTO.ID_IMPOSTO
							WHEN 51
							THEN (FATURAMENTO_IMPOSTO.VALOR_IMPOSTO)
						 ELSE FATURAMENTO_IMPOSTO.VALOR_IMPOSTO END)) Diferimento /*#43#*/
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
			  /*WHERE FATURAMENTO_IMPOSTO.ID_IMPOSTO IN  ('1','51') #23#*/
			  WHERE FATURAMENTO_IMPOSTO.ID_IMPOSTO IN ('51')
				AND FATURAMENTO.NF_SAIDA = ?vTmp_impressao_nf_00.NF
				AND FATURAMENTO.SERIE_NF = ?vTmp_impressao_nf_00.Serie_nf
				AND FATURAMENTO.FILIAL	 = ?vTmp_impressao_nf_00.Filial
				/*AND TEXTO_LEGAL IS NOT NULL #23#*/
		ENDTEXT

	Else
		TEXT TO xSqlNFE_Diferimento NOSHOW

			SELECT	ABS(SUM(CASE ENTRADAS_IMPOSTO.ID_IMPOSTO
					WHEN 51
					THEN (ENTRADAS_IMPOSTO.VALOR_IMPOSTO * -1)
					ELSE ENTRADAS_IMPOSTO.VALOR_IMPOSTO END)) Diferimento /*#43#*/
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
				/*AND	ENTRADAS_IMPOSTO.ID_IMPOSTO IN ('1','51') #18#*/
				AND	ENTRADAS_IMPOSTO.ID_IMPOSTO IN ('51') /*#23#*/
				AND ENTRADAS.NF_ENTRADA = ?vTmp_impressao_nf_00.NF
				AND ENTRADAS.SERIE_NF_ENTRADA = ?vTmp_impressao_nf_00.Serie_nf
				AND ENTRADAS.NOME_CLIFOR	 = ?vTmp_impressao_nf_00.nome_clifor
				AND ENTRADAS.NF_ENTRADA_PROPRIA=1
		ENDTEXT
	Endif

	f_select(xsqlnfe_diferimento , "vTmp_Diferimento")
	If Reccount('vTmp_Diferimento')>0
		If !f_vazio(vtmp_diferimento.diferimento)
			xdiferimento = vtmp_diferimento.diferimento
			xvalordiferimento = 0
			Select vtmp_impressao_nf_00
			xvalordiferimento = vtmp_impressao_nf_00.icms - xdiferimento
			Replace vtmp_impressao_nf_00.icms With xvalordiferimento
		Endif
	Endif

	* Diferimento ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	TEXT TO xSqlNFE_Filha NOSHOW
		Select NFE_ITENS.filial,NFE_ITENS.nf,NFE_ITENS.serie_nf,NFE_ITENS.Item_Impressao,NFE_ITENS.Item_NFe,NFE_ITENS.sub_item_tamanho,NFE_ITENS.codigo_item,NFE_ITENS.descricao_item,Informacao_adicional_prod,
		 case when (DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE(default,NFE_ITENS.INFORMACAO_ADICIONAL_PROD) = '' and NFE.UF_EMITENTE <> 'RJ')
		 		or (DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE(default,NFE_ITENS.INFORMACAO_ADICIONAL_PROD) = '' and NFE.UF_EMITENTE = 'RJ' and dbo.fx_parametro('INF_AD_COB_ALIQ_NF_NA_OBS')='.T.') then
			null
		else
			case when
				 NFE.UF_EMITENTE = 'RJ'
				 and  NFE_ITENS.FECP_BASE = 0										/*  <- Trecho usado na gravação da tag vBCFCP   */
				 and  NFE_ITENS.FECP_ALIQUOTA = 0									/*  <- Trecho usado na gravação da tag pFCP     */
				 and (NFE_ITENS.FECP_VALOR >= 0 and NFE_ITENS.FECP_BASE = 0)        /*  <- Trecho usado na gravação da tag vFCP     */
				 and (NFE_ITENS.FECP_ST_BASE     + NFE_ITENS.FECP_STR_BASE = 0)		/*  <- Trecho usado na gravação da tag vBCFCPST */
				 and (NFE_ITENS.FECP_ST_ALIQUOTA + NFE_ITENS.FECP_STR_ALIQUOTA = 0) /*  <- Trecho usado na gravação da tag pFCPST   */
				 and (NFE_ITENS.FECP_ST_VALOR    + NFE_ITENS.FECP_STR_VALOR = 0)    /*  <- Trecho usado na gravação da tag vFCPST   */
			then
				case when DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE(default,NFE_ITENS.INFORMACAO_ADICIONAL_PROD) = '' AND dbo.fx_parametro('INF_AD_COB_ALIQ_NF_NA_OBS')<>'.T.' then
					 DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE(default,'Não há Cobrança em favor do Fundo Estadual de Combate à Pobreza e às Desigualdades Sociais - FECP para o produto e/ou Serviço comercializado, conforme dispõe a Lei 8.405/2019.')
				else
					 DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE(default,rtrim(ltrim(NFE_ITENS.INFORMACAO_ADICIONAL_PROD))) + CASE WHEN dbo.fx_parametro('INF_AD_COB_ALIQ_NF_NA_OBS')<>'.T.' THEN ' ' + DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE(default,'Não há Cobrança em favor do Fundo Estadual de Combate à Pobreza e às Desigualdades Sociais - FECP para o produto e/ou Serviço comercializado, conforme dispõe a Lei 8.405/2019.') ELSE '' END -- #119#
				end
			else
				DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE(default,NFE_ITENS.INFORMACAO_ADICIONAL_PROD)
			end
		end as OBS_ITEM,
		substring(replace(NFE_ITENS.classif_fiscal,'.',''),1,8) as classif_fiscal,NFE_ITENS.tribut_origem,NFE_ITENS.tribut_icms,NFE_ITENS.codigo_fiscal_operacao,NFE_ITENS.id_excecao_imposto,NFE_ITENS.unidade,NFE_ITENS.qtde_item,NFE_ITENS.preco_unitario + Round((CASE WHEN NFE_ITENS.Importacao=1 and NFE_ITENS.Danfe_NFe_Importacao_Calc='.T.' and NFE_ITENS.encargo<>0 and NFE_ITENS.qtde_item<>0 then NFE_ITENS.encargo/NFE_ITENS.qtde_item ELSE 0 END) + (CASE WHEN NFE_ITENS.Importacao=1 and NFE_ITENS.Danfe_NFe_Importacao_Calc='.T.' and NFE_ITENS.i_import<>0 and NFE_ITENS.qtde_item<>0 then NFE_ITENS.i_import/NFE_ITENS.qtde_item ELSE 0 END) ,
	   (CASE WHEN NFE_ITENS.cod_tabela_filha='P' THEN 2 ELSE 5 END)) as preco_unitario, CASE WHEN NFE_ITENS.Importacao=1 and NFE_ITENS.Danfe_NFe_Importacao_Calc='.T.' THEN Round(NFE_ITENS.qtde_item * (NFE_ITENS.preco_unitario + Round((CASE WHEN NFE_ITENS.Importacao=1 and NFE_ITENS.Danfe_NFe_Importacao_Calc='.T.' and NFE_ITENS.encargo<>0 and NFE_ITENS.qtde_item<>0 then NFE_ITENS.encargo/NFE_ITENS.qtde_item ELSE 0 END) + (CASE WHEN NFE_ITENS.Importacao=1 and NFE_ITENS.Danfe_NFe_Importacao_Calc='.T.' and NFE_ITENS.i_import<>0 and NFE_ITENS.qtde_item<>0 then NFE_ITENS.i_import/NFE_ITENS.qtde_item ELSE 0 END) ,
	   (CASE WHEN NFE_ITENS.cod_tabela_filha='P' THEN 2 ELSE 5 END))),2) ELSE valor_item END as valor_item,
	   CASE WHEN NFE_ITENS.tribut_icms='51' THEN NFE_ITENS.ICMS_BST ELSE NFE_ITENS.ICMS END as icms,
	   NFE_ITENS.icms_base,
	   NFE_ITENS.icms_aliquota,
	   NFE_ITENS.ipi,
	   NFE_ITENS.ipi_aliquota, (NFE_ITENS.valor_descontos - NFE_ITENS.icms_zf) valor_descontos,NFE_ITENS.desconto_total_item,NFE_ITENS.valor_unitario_bruto,CONVERT(Numeric(13,2),NFE_ITENS.valor_item_bruto) as valor_item_bruto,NFE_ITENS.frete,NFE_ITENS.seguro,NFE_ITENS.Importacao,NFE_ITENS.Danfe_NFe_Importacao_Calc, valor_imposto_item = ISNULL(NFE_ITENS.VALOR_IMPOSTO_ITEM, 0),
	   NFE_ITENS.ibs_est_valor as Valor_Ibs , NFE_ITENS.cbs_valor as Valor_Cbs, NFE_ITENS.is_valor as Valor_Is
	  From W_IMPRESSAO_NFE_ITENS NFE_ITENS
	  JOIN W_IMPRESSAO_NFE NFE on NFE.NF=NFE_ITENS.NF AND NFE.SERIE_NF=NFE_ITENS.SERIE_NF AND NFE.FILIAL=NFE_ITENS.FILIAL
	  	LEFT JOIN CADASTRO_CLI_FOR
			ON	CADASTRO_CLI_FOR.NOME_CLIFOR=NFE_ITENS.NOME_CLIFOR
		/*
		LEFT JOIN TABELA_ALIQUOTA_IMPOSTO_ITEM
			ON	TABELA_ALIQUOTA_IMPOSTO_ITEM.UF=CADASTRO_CLI_FOR.UF
			AND	TABELA_ALIQUOTA_IMPOSTO_ITEM.NCM_NBS=replace(NFE_ITENS.classif_fiscal,'.','')
			AND TABELA_ALIQUOTA_IMPOSTO_ITEM.EXCESSAO_FISCAL_TABELA = 0
			AND	CONVERT(VARCHAR(8),NFE_ITENS.EMISSAO_RECEBIMENTO,112)  BETWEEN CONVERT(VARCHAR(8),TABELA_ALIQUOTA_IMPOSTO_ITEM.INICIO_VIGENCIA,112) AND
								CONVERT(VARCHAR(8),TABELA_ALIQUOTA_IMPOSTO_ITEM.FIM_VIGENCIA,112)
		INNER JOIN (	SELECT	NCM_NBS, UF, MAX(VERSAO) AS VERSAO, EXCESSAO_FISCAL_TABELA, MAX(INICIO_VIGENCIA) AS INICIO_VIGENCIA, MAX(FIM_VIGENCIA) AS FIM_VIGENCIA
						FROM	TABELA_ALIQUOTA_IMPOSTO_ITEM
						GROUP BY NCM_NBS,UF,EXCESSAO_FISCAL_TABELA
					) AS TABELA_ALIQUOTA_IMPOSTO_ITEM_TMP
			ON	TABELA_ALIQUOTA_IMPOSTO_ITEM_TMP.UF = TABELA_ALIQUOTA_IMPOSTO_ITEM.UF
			AND	TABELA_ALIQUOTA_IMPOSTO_ITEM_TMP.NCM_NBS = TABELA_ALIQUOTA_IMPOSTO_ITEM.NCM_NBS
			AND TABELA_ALIQUOTA_IMPOSTO_ITEM_TMP.VERSAO = TABELA_ALIQUOTA_IMPOSTO_ITEM.VERSAO
			AND TABELA_ALIQUOTA_IMPOSTO_ITEM_TMP.EXCESSAO_FISCAL_TABELA = TABELA_ALIQUOTA_IMPOSTO_ITEM.EXCESSAO_FISCAL_TABELA
			AND TABELA_ALIQUOTA_IMPOSTO_ITEM_TMP.INICIO_VIGENCIA = TABELA_ALIQUOTA_IMPOSTO_ITEM.INICIO_VIGENCIA
			AND TABELA_ALIQUOTA_IMPOSTO_ITEM_TMP.FIM_VIGENCIA = TABELA_ALIQUOTA_IMPOSTO_ITEM.FIM_VIGENCIA
			*/
	  Where NFE_ITENS.NF=?vTmp_impressao_nf_00.NF and NFE_ITENS.Serie_NF=?vTmp_impressao_nf_00.Serie_nf and NFE_ITENS.Filial=?vTmp_impressao_nf_00.Filial

	  UNION

	  Select NFE_ITENS.filial,NFE_ITENS.nf,NFE_ITENS.serie_nf,NFE_ITENS.Item_Impressao,NFE_ITENS.Item_NFe,NFE_ITENS.sub_item_tamanho,NFE_ITENS.codigo_item,NFE_ITENS.descricao_item,Informacao_adicional_prod,
		case when (DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE(default,NFE_ITENS.INFORMACAO_ADICIONAL_PROD) = '' and NFE.UF_EMITENTE <> 'RJ')
		 	   or (DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE(default,NFE_ITENS.INFORMACAO_ADICIONAL_PROD) = '' and NFE.UF_EMITENTE = 'RJ' and dbo.fx_parametro('INF_AD_COB_ALIQ_NF_NA_OBS')='.T.') then
			null
		else
			case when
				 NFE.UF_EMITENTE = 'RJ'
				 and  NFE_ITENS.FECP_BASE = 0										/*  <- Trecho usado na gravação da tag vBCFCP   */
				 and  NFE_ITENS.FECP_ALIQUOTA = 0									/*  <- Trecho usado na gravação da tag pFCP     */
				 and (NFE_ITENS.FECP_VALOR >= 0 and NFE_ITENS.FECP_BASE = 0)        /*  <- Trecho usado na gravação da tag vFCP     */
				 and (NFE_ITENS.FECP_ST_BASE     + NFE_ITENS.FECP_STR_BASE = 0)		/*  <- Trecho usado na gravação da tag vBCFCPST */
				 and (NFE_ITENS.FECP_ST_ALIQUOTA + NFE_ITENS.FECP_STR_ALIQUOTA = 0) /*  <- Trecho usado na gravação da tag pFCPST   */
				 and (NFE_ITENS.FECP_ST_VALOR    + NFE_ITENS.FECP_STR_VALOR = 0)    /*  <- Trecho usado na gravação da tag vFCPST   */
			then
				case when DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE(default,NFE_ITENS.INFORMACAO_ADICIONAL_PROD) = '' AND dbo.fx_parametro('INF_AD_COB_ALIQ_NF_NA_OBS')<>'.T.' then
					 DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE(default,'Não há Cobrança em favor do Fundo Estadual de Combate à Pobreza e às Desigualdades Sociais - FECP para o produto e/ou Serviço comercializado, conforme dispõe a Lei 8.405/2019.')
				else
					 DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE(default,rtrim(ltrim(NFE_ITENS.INFORMACAO_ADICIONAL_PROD))) + CASE WHEN dbo.fx_parametro('INF_AD_COB_ALIQ_NF_NA_OBS')<>'.T.' THEN ' ' + DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE(default,'Não há Cobrança em favor do Fundo Estadual de Combate à Pobreza e às Desigualdades Sociais - FECP para o produto e/ou Serviço comercializado, conforme dispõe a Lei 8.405/2019.') ELSE '' END -- #119#
				end
			else
				DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE(default,NFE_ITENS.INFORMACAO_ADICIONAL_PROD)
			end
		end as OBS_ITEM,
		substring(replace(NFE_ITENS.classif_fiscal,'.',''),1,8) as classif_fiscal,NFE_ITENS.tribut_origem,NFE_ITENS.tribut_icms,NFE_ITENS.codigo_fiscal_operacao,NFE_ITENS.id_excecao_imposto,NFE_ITENS.unidade,NFE_ITENS.qtde_item,NFE_ITENS.preco_unitario + Round((CASE WHEN NFE_ITENS.Importacao=1 and NFE_ITENS.Danfe_NFe_Importacao_Calc='.T.' and NFE_ITENS.encargo<>0 and NFE_ITENS.qtde_item<>0 then NFE_ITENS.encargo/NFE_ITENS.qtde_item ELSE 0 END) + (CASE WHEN NFE_ITENS.Importacao=1 and NFE_ITENS.Danfe_NFe_Importacao_Calc='.T.' and NFE_ITENS.i_import<>0 and NFE_ITENS.qtde_item<>0 then NFE_ITENS.i_import/NFE_ITENS.qtde_item ELSE 0 END) ,
	   (CASE WHEN NFE_ITENS.cod_tabela_filha='P' THEN 2 ELSE 5 END)) as preco_unitario, CASE WHEN NFE_ITENS.Importacao=1 and NFE_ITENS.Danfe_NFe_Importacao_Calc='.T.' THEN Round(NFE_ITENS.qtde_item * (NFE_ITENS.preco_unitario + Round((CASE WHEN NFE_ITENS.Importacao=1 and NFE_ITENS.Danfe_NFe_Importacao_Calc='.T.' and NFE_ITENS.encargo<>0 and NFE_ITENS.qtde_item<>0 then NFE_ITENS.encargo/NFE_ITENS.qtde_item ELSE 0 END) + (CASE WHEN NFE_ITENS.Importacao=1 and NFE_ITENS.Danfe_NFe_Importacao_Calc='.T.' and NFE_ITENS.i_import<>0 and NFE_ITENS.qtde_item<>0 then NFE_ITENS.i_import/NFE_ITENS.qtde_item ELSE 0 END) ,
	   (CASE WHEN NFE_ITENS.cod_tabela_filha='P' THEN 2 ELSE 5 END))),2) ELSE NFE_ITENS.valor_item END as valor_item,
	   CASE WHEN NFE_ITENS.tribut_icms='51' THEN NFE_ITENS.ICMS_BST ELSE NFE_ITENS.ICMS END as icms,
	   NFE_ITENS.icms_base,
	   NFE_ITENS.icms_aliquota,
	   NFE_ITENS.ipi,
	   NFE_ITENS.ipi_aliquota, (NFE_ITENS.valor_descontos - NFE_ITENS.icms_zf) valor_descontos,NFE_ITENS.desconto_total_item,NFE_ITENS.valor_unitario_bruto,CONVERT(Numeric(13,2),NFE_ITENS.valor_item_bruto) as valor_item_bruto,NFE_ITENS.frete,NFE_ITENS.seguro,NFE_ITENS.Importacao,NFE_ITENS.Danfe_NFe_Importacao_Calc, valor_imposto_item = ISNULL(VALOR_IMPOSTO_ITEM, 0),
   	   NFE_ITENS.ibs_est_valor as Valor_Ibs, NFE_ITENS.cbs_valor as Valor_Cbs, NFE_ITENS.is_valor as Valor_Is
	  From W_IMPRESSAO_NFE_ITENS NFE_ITENS
	  JOIN W_IMPRESSAO_NFE NFE on NFE.NF=NFE_ITENS.NF AND NFE.SERIE_NF=NFE_ITENS.SERIE_NF AND NFE.FILIAL=NFE_ITENS.FILIAL
	  	LEFT JOIN CADASTRO_CLI_FOR
			ON	CADASTRO_CLI_FOR.NOME_CLIFOR=NFE_ITENS.NOME_CLIFOR
		/*
		LEFT JOIN TABELA_ALIQUOTA_IMPOSTO_ITEM
			ON	TABELA_ALIQUOTA_IMPOSTO_ITEM.UF=CADASTRO_CLI_FOR.UF
			AND	TABELA_ALIQUOTA_IMPOSTO_ITEM.NCM_NBS=replace(NFE_ITENS.classif_fiscal,'.','')
			AND TABELA_ALIQUOTA_IMPOSTO_ITEM.EXCESSAO_FISCAL_TABELA = 0
			AND	CONVERT(VARCHAR(8),NFE_ITENS.EMISSAO_RECEBIMENTO,112)  BETWEEN CONVERT(VARCHAR(8),TABELA_ALIQUOTA_IMPOSTO_ITEM.INICIO_VIGENCIA,112) AND
								CONVERT(VARCHAR(8),TABELA_ALIQUOTA_IMPOSTO_ITEM.FIM_VIGENCIA,112)
		LEFT JOIN (	SELECT	NCM_NBS, UF, MAX(VERSAO) AS VERSAO, EXCESSAO_FISCAL_TABELA, MAX(INICIO_VIGENCIA) AS INICIO_VIGENCIA, MAX(FIM_VIGENCIA) AS FIM_VIGENCIA
						FROM	TABELA_ALIQUOTA_IMPOSTO_ITEM
						GROUP BY NCM_NBS,UF,EXCESSAO_FISCAL_TABELA
					) AS TABELA_ALIQUOTA_IMPOSTO_ITEM_TMP
			ON	TABELA_ALIQUOTA_IMPOSTO_ITEM_TMP.UF = TABELA_ALIQUOTA_IMPOSTO_ITEM.UF
			AND	TABELA_ALIQUOTA_IMPOSTO_ITEM_TMP.NCM_NBS = TABELA_ALIQUOTA_IMPOSTO_ITEM.NCM_NBS
			AND TABELA_ALIQUOTA_IMPOSTO_ITEM_TMP.VERSAO = TABELA_ALIQUOTA_IMPOSTO_ITEM.VERSAO
			AND TABELA_ALIQUOTA_IMPOSTO_ITEM_TMP.EXCESSAO_FISCAL_TABELA = TABELA_ALIQUOTA_IMPOSTO_ITEM.EXCESSAO_FISCAL_TABELA
			AND TABELA_ALIQUOTA_IMPOSTO_ITEM_TMP.INICIO_VIGENCIA = TABELA_ALIQUOTA_IMPOSTO_ITEM.INICIO_VIGENCIA
			AND TABELA_ALIQUOTA_IMPOSTO_ITEM_TMP.FIM_VIGENCIA = TABELA_ALIQUOTA_IMPOSTO_ITEM.FIM_VIGENCIA
		*/
	  Where NFE_ITENS.NF=?vTmp_impressao_nf_00.NF and NFE_ITENS.Serie_NF=?vTmp_impressao_nf_00.Serie_nf and NFE_ITENS.Filial=?vTmp_impressao_nf_00.Filial
	ENDTEXT

	If bLinxErp
	
		xfields_ctrl_add = "NVL(vTmp_impressao_nf_00.status_nfe,0) as status_nfe, NVL(VAL(vTmp_impressao_nf_00.tipo_emissao_nfe),0) as tipo_emissao_nfe, 0000 as n_form,0000 as t_form, 001 as n_qb_item, .f. as ult_n_qb_item, 0 as item_add, 1 as seq_obs, .F. As frm_aux" && --#30#
		Select vtmp_impressao_nf_00
		Count To xtreg
		xratu = 0
		Scan
			xratu = xratu + 1
			f_prog_bar('Gerando Itens da NFe: '+ vtmp_impressao_nf_00.nf,xratu,xtreg)

			f_select(xsqlnfe_filha,'vTmp_impressao_nf_00_itens_BASE',Alias())
			If !Used('vTmp_impressao_nf_00_itens')
				Select *,&xfields_ctrl_add From vtmp_impressao_nf_00_itens_base Into Cursor vtmp_impressao_nf_00_itens Readwrite
			Else
				Insert Into vtmp_impressao_nf_00_itens Select *,&xfields_ctrl_add From vtmp_impressao_nf_00_itens_base
			Endif

		Endscan

		Use In vtmp_impressao_nf_00_itens_base
		f_wait()
	Else
		xrunmetodo = f_select(xsqlnfe_filha,'vTmp_impressao_nf_00_itens_Base')
		Select *, 00 As status_nfe, 00 As tipo_emissao_nfe, 0000 As n_form, 0000 As t_form, 001 As n_qb_item, .F. As ult_n_qb_item, 0 As item_add, 0000 As seq_obs, .F. As frm_aux ; && --#30#
		From vtmp_impressao_nf_00_itens_base Into Cursor vtmp_impressao_nf_00_itens Readwrite

		Use In vtmp_impressao_nf_00_itens_base
		Replace All seq_obs With 1, status_nfe With Nvl(vtmp_impressao_nf_00.status_nfe, 0), tipo_emissao_nfe With Nvl(Val(vtmp_impressao_nf_00.tipo_emissao_nfe),0) In vtmp_impressao_nf_00_itens
	Endif

	Select vtmp_impressao_nf_00
	Go Top

	If vtmp_impressao_nf_00.origem_nf='S'
		xsqlnfe_diff_itens = ""
		TEXT TO xSqlNFE_Diff_itens NOSHOW
			SELECT  FATURAMENTO_IMPOSTO.ITEM_IMPRESSAO AS ITEM_IMPRESSAO , FATURAMENTO_IMPOSTO.SUB_ITEM_TAMANHO AS SUB_ITEM_TAMANHO,
			FATURAMENTO_IMPOSTO.VALOR_IMPOSTO AS VALOR_IMPOSTO ,FATURAMENTO_IMPOSTO.BASE_IMPOSTO AS BASE_IMPOSTO ,FATURAMENTO_IMPOSTO.ID_IMPOSTO
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
		ENDTEXT
	Else
		xsqlnfe_diff_itens = ""
		TEXT TO xSqlNFE_Diff_itens NOSHOW
	SELECT  ENTRADAS_IMPOSTO.ITEM_IMPRESSAO AS ITEM_IMPRESSAO , ENTRADAS_IMPOSTO.SUB_ITEM_TAMANHO AS SUB_ITEM_TAMANHO ,
	CASE WHEN ENTRADAS_IMPOSTO.VALOR_IMPOSTO = 0 THEN VALOR_IMPOSTO_ESPELHO ELSE ENTRADAS_IMPOSTO.VALOR_IMPOSTO END AS VALOR_IMPOSTO ,ENTRADAS_IMPOSTO.BASE_IMPOSTO AS BASE_IMPOSTO, ENTRADAS_IMPOSTO.ID_IMPOSTO /*#43#*/
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
		AND	ENTRADAS_IMPOSTO.ID_IMPOSTO IN ('1','51')
		AND ENTRADAS.NF_ENTRADA = ?vTmp_impressao_nf_00.NF
		AND ENTRADAS.SERIE_NF_ENTRADA = ?vTmp_impressao_nf_00.Serie_nf
		AND ENTRADAS.NOME_CLIFOR	 = ?vTmp_impressao_nf_00.nome_clifor
		AND ENTRADAS.NF_ENTRADA_PROPRIA=1
		ENDTEXT
	Endif

	f_select(xsqlnfe_diff_itens,'TMP_DIFF_ITENS',Alias())

	If Reccount('TMP_DIFF_ITENS')>0
		Select * From tmp_diff_itens Where id_imposto=1 Into Cursor tmp_diff_itens_imposto Readwrite
	Endif

	If Used("TMP_DIFF_ITENS_IMPOSTO")
		If Reccount('TMP_DIFF_ITENS_IMPOSTO')>0
			Select tmp_diff_itens_imposto
			Scan
				Select vtmp_impressao_nf_00_itens
				Locate For  vtmp_impressao_nf_00_itens.item_impressao =tmp_diff_itens_imposto.item_impressao  And  vtmp_impressao_nf_00_itens.sub_item_tamanho = tmp_diff_itens_imposto.sub_item_tamanho
				If Found()
					Replace vtmp_impressao_nf_00_itens.icms With (tmp_diff_itens_imposto.valor_imposto - vtmp_impressao_nf_00_itens.icms)
				Endif
			Endscan
		Endif
	Endif

	Select filial,nf,serie_nf,Sum(valor_item) valor_total From vtmp_impressao_nf_00_itens ;
		WHERE importacao=1 And danfe_nfe_importacao_calc='.T.' Group By 1,2,3 Into Cursor curtmp_calcsubitens_nf_import

	Select curtmp_calcsubitens_nf_import
	Scan
		Select vtmp_impressao_nf_00
		Locate For filial==curtmp_calcsubitens_nf_import.filial And nf==curtmp_calcsubitens_nf_import.nf And serie_nf==curtmp_calcsubitens_nf_import.serie_nf
		If Found()
			Replace valor_sub_itens With Round(curtmp_calcsubitens_nf_import.valor_total,2)
		Endif
	Endscan

	f_add_itens_frm_auxiliar() 
	f_tratar_len_itens_danfe()
	f_load_ctrl_frm_danfe(pitens1,pitens2,pitens3,plenobsfrm, FormMain, bLinxErp) 
	f_load_ctrl_nf_financ_nfe(bLinxErp)

	*-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------*

	Select cur_ctb_parcelas
	Index On Alltrim(filial)+Alltrim(nf)+Alltrim(serie_nf) Tag iparcs

	Select cur_frmnfe_obs
	Index On Alltrim(filial)+Alltrim(nf)+Alltrim(serie_nf)+Str(n_form)+Str(seq_obs) Tag iobsnfe

	Select vtmp_impressao_nf_00
	CursorSetProp('buffering',3)
	Index On Alltrim(filial)+Alltrim(nf)+Alltrim(serie_nf) Tag ifat
	Set Relation To Alltrim(filial)+Alltrim(nf)+Alltrim(serie_nf)  Into cur_ctb_parcelas

	Select vtmp_impressao_nf_00_itens
	Index On Alltrim(filial)+Alltrim(nf)+Alltrim(serie_nf)+Str(n_form)+Str(seq_obs)+Str(item_nfe)+Str(item_add)+Iif(frm_aux,'1','0')+Str(n_qb_item) Tag iitens && --#30#
	Set Relation To Alltrim(filial)+Alltrim(nf)+Alltrim(serie_nf) Into vtmp_impressao_nf_00
	Set Relation To Alltrim(filial)+Alltrim(nf)+Alltrim(serie_nf)+Str(n_form)+Str(seq_obs) Into cur_frmnfe_obs Additive
	Go Top

Endfunc
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*

*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Function fx_danfe_destroy
	Lparameters bLinxErp
		
	*-- Marcar DANFE como Impressa (para botão IMPRIMIR ou Print no Preview)
	If bLinxErp And (( Type('Mreport')='C' And mreport='IMP' ) Or ( Type('xSentToPrinter')='L' And xsenttoprinter ))
		Select vtmp_impressao_nf_00
		Scan
			If origem_nf = "S"
				xupdate = 'Update Faturamento set Nota_impressa=1 Where nf_saida=?vTmp_Impressao_NF_00.nf and serie_nf=?vTmp_Impressao_NF_00.serie_nf and filial=?vTmp_Impressao_NF_00.filial and nota_impressa=0'
			Else
				xupdate = 'Update Entradas set nf_propria_emitida=1 Where nf_entrada=?vTmp_Impressao_NF_00.nf and nome_clifor=?vTmp_Impressao_NF_00.nome_clifor and serie_nf_entrada=?vTmp_Impressao_NF_00.serie_nf and nf_propria_emitida=0'
			Endif
			If !f_update(xupdate)
				=f_msg(['Problema ao Marcar Nota Impressa !', 0+16, 'Erro !!!'])
				Return .F.
			Endif
			Wait Window 'Marcando NFe Como Impressa: '+ Alltrim(vtmp_impressao_nf_00.nf) Nowait
		Endscan
		Wait Clear
	Endif

	*-- Clear
	If bLinxErp
		Set Procedure To &x_proce
	Else
		Release wwlogo
	Endif
	Release x_proce,ximp_dsai,ext1,ext2,ext3,xmsg_nfe,xreport_printed,xkimp

	Local intcount As Integer, strcursor As String
	Local Array acursorsclose[30, 1] 

	acursorsclose[1, 1]  = "cur_Ctb_Parcelas"
	acursorsclose[2, 1]  = "cur_FrmNfe_Obs"
	acursorsclose[3, 1]  = "vTmp_Impressao_NF_00_Itens"
	acursorsclose[4, 1]  = "vTmp_Impressao_NF_00"
	acursorsclose[5, 1]  = "cur_Lst_DANFE_Emitir"
	acursorsclose[6, 1]  = "curTmp_Maxfrm"
	acursorsclose[7, 1]  = "Cur_Lst_Nfs_Base"
	acursorsclose[8, 1]  = "cur_Lst_NFs"
	acursorsclose[9, 1]  = "cur_Info_UF"
	acursorsclose[10, 1] = "curTmp_Prot"
	acursorsclose[11, 1] = "cur_frmnfe_obs"
	acursorsclose[12, 1] = "cur_Ctb_Parcelas"
	acursorsclose[13, 1] = "curTmp_Itens_p_Form"
	acursorsclose[14, 1] = "Cur_Count_n_Form"
	acursorsclose[15, 1] = "curTmp_parc"
	acursorsclose[16, 1] = "Cur_lst_itens_add_len"
	acursorsclose[17, 1] = "CurTmp_TamLin_Item"
	acursorsclose[18, 1] = "CurTmp_Controle_Ult_ItemQb"
	acursorsclose[19, 1] = "CurChk_t_form"
	acursorsclose[20, 1] = "CurTmp_LogoDanfe"
	acursorsclose[21, 1] = "cur_ctrl_obsform"
	acursorsclose[22, 1] = "curtmp_calcsubitens_nf_import"
	acursorsclose[23, 1] = "tmp_diff_itens_imposto"
	acursorsclose[24, 1] = "tmp_diff_itens"
	acursorsclose[25, 1] = "vtmp_diferimento"
	acursorsclose[26, 1] = "vTmp_ItensComDesc"
	acursorsclose[27, 1] = "CurLst_Filiais" 
	acursorsclose[28, 1] = "CurTmp_MostraTotNfDanfeSimp" 
	acursorsclose[29, 1] = "Consulta_amb" && #45#
	acursorsclose[30, 1] = "Consulta_url" && #45#

	For intcount = 1 To Alen(acursorsclose, 1)
		strcursor = Alltrim(acursorsclose[intCount, 1])
		If Used(strcursor)
			Use In &strcursor
		Endif
	Endfor

Endfunc
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*

*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Function f_load_ctrl_frm_danfe() && Form Control
	Lparameters _pItens1, _pItens2, _pItens3, plenobsfrm, FormMain, bLinxErp 
	*-  _pItens1   = Numero de Itens do primeiro formulário
	*-  _pItens2   = Numero de Itens dos demais formulários (Sem descontos RJ)
	*-  _pItens3   = Numero de Itens do formulário auxiliar (Descontos RJ)
	*-  pLenObsFrm = Tamanho Máximo para quebra da OBS por Formulário (Linhas/Caracteres por linha)

	Local intidentifica_ambiente_nfe As Integer, vQtdeOriginalItens as Integer
	intidentifica_ambiente_nfe = Iif(bLinxErp, widentifica_ambiente_nfe, FormMain.p_identifica_ambiente_nfe)

	*-- Controle de Itens Por Frm
	Select vtmp_impressao_nf_00_itens
	Index On filial+nf+serie_nf+Iif(frm_aux,'1','0')+Str(item_nfe)+Str(n_qb_item) Tag iitem 

	Do Whil !Eof()
		xkey   = filial+nf+serie_nf
		xTpAux = frm_aux
		xfrm   = 1
		xcount = 0
		
	 		*--{ Controle devido bloco de informações do ponto de retirada
			Select vtmp_impressao_nf_00
			LOCATE FOR filial+nf+serie_nf==xkey
			xLinsRet = 8 
			pItens1  = _pItens1 - IIF(_pItens1>xLinsRet and vtmp_impressao_nf_00.Mostra_Retirada,xLinsRet,0)
			pItens2  = _pItens2 - IIF(_pItens2>xLinsRet and vtmp_impressao_nf_00.Mostra_Retirada,xLinsRet,0)
			pItens3  = _pItens3 - IIF(_pItens3>xLinsRet and vtmp_impressao_nf_00.Mostra_Retirada,xLinsRet,0)
		
		xitenspfrm = pItens1
			
		Select vtmp_impressao_nf_00_itens
		Scan Whil filial+nf+serie_nf==xkey
			xcount = xcount+1
			If xcount > xitenspfrm Or frm_aux<>xTpAux
				xfrm   = xfrm + 1
				xcount = 1
				xTpAux = frm_aux
				xitenspfrm = Iif(frm_aux,pitens3,pitens2) && Papel timbrado (igual ao normal)
			Endif
			Replace n_form With xfrm
		Endscan

	Enddo

	*-- Controle de Quebra da OBS
	Declare xmsg_nfe(3)
	xmsg_nfe(1) = '( S E M   V A L O R   F I S C A L )'									 					  	&& > Para: wIdentifica_Ambiente_NFe=0 ou 2 ( quando em ambiente de homologação )
	xmsg_nfe(2) = 'DANFE IMPRESSO EM CONTINGÊNCIA - DPEC REGULARMENTE RECEBIDA PELA RECEITA FEDERAL DO BRASIL'	&& > Para: vTmp_impressao_nf_00.tipo_emissao_nfe='4'
	xmsg_nfe(3) = 'DANFE EM CONTINGÊNCIA - IMPRESSO EM DECORRÊNCIA DE PROBLEMAS TÉCNICOS' 						&& > Para: vTmp_impressao_nf_00.tipo_emissao_nfe='5'

	*-- Trata Obs
	Select nf,serie_nf,filial,status_nfe,tipo_emissao_nfe,n_form,frm_aux, Count(*) cnt_itens ;
		FROM vtmp_impressao_nf_00_itens ;
		Group By 1,2,3,4,5,6,7 Into Cursor cur_lst_nfs_base 

	Select a.*, b.obs, b.obs_entrega, b.texto_legal, obs_interesse_fisco, obs As obs_final_frm,;
		TTOC(b.data_contingencia) As data_contingencia, b.justificativa_contingencia justificativa_contingencia ;
		FROM cur_lst_nfs_base a ;
		Join vtmp_impressao_nf_00 b On a.nf=b.nf And a.serie_nf=b.serie_nf And a.filial=b.filial ;
		ORDER By a.nf,a.serie_nf,a.filial,a.n_form Into Cursor cur_lst_nfs Readwrite

	Select cur_lst_nfs
	Do Whil !Eof()
		xk=nf+serie_nf+filial
		xobsfinal = Iif(intidentifica_ambiente_nfe=0 Or intidentifica_ambiente_nfe=2,xmsg_nfe(1)+Chr(13),'') +;
			IIF(tipo_emissao_nfe=4,xmsg_nfe(2)+' '+Chr(13)+Alltrim(Nvl(justificativa_contingencia,''))+' '+Alltrim(Nvl(data_contingencia,''))+Chr(13),;
			IIF(tipo_emissao_nfe=5,xmsg_nfe(3)+' '+Chr(13)+Alltrim(Nvl(justificativa_contingencia,''))+' '+Alltrim(Nvl(data_contingencia,''))+Chr(13),''))

		xobsintfisco = Iif(Empty(Nvl(obs_interesse_fisco,'')),'','Informações Adicionais de Interesse do Fisco: '+Nvl(Alltrim(obs_interesse_fisco),''))

		If !('ENTREGA:' $ Upper(Nvl(obs,'')))
			xobsfinal = xobsfinal + Iif(Empty(xobsfinal) Or Empty(Nvl(obs_entrega,'')),'',Chr(13)+Chr(10)) + Nvl(obs_entrega,'')
		Endif

		xobsfinal = xobsfinal + Iif(Empty(xobsfinal) Or Empty(Nvl(obs,'')),'',Chr(13)+Chr(10)) + Nvl(obs,'')
		xobsfinal = xobsfinal + Iif(Empty(xobsfinal) Or Empty(Nvl(texto_legal,'')),'',Chr(13)+Chr(10)) + Nvl(texto_legal,'')
		xobsfinal = xobsfinal + Iif(Empty(xobsfinal) Or Empty(Nvl(obs_interesse_fisco,'')),'',Chr(13)+Chr(10)) + xobsintfisco

		Replace obs_final_frm With Left(xobsfinal,5000) && Limite estipulado no manual
		Skip
		Scan While nf+serie_nf+filial==xk
			Replace obs_final_frm With ''
		Endscan
	Enddo

	*--
	Select nf,serie_nf,filial,vtmp_impressao_nf_00.obs As obs_form,vtmp_impressao_nf_00.obs As endereco_emitente_str,;
		00000 As n_form,00000 As seq_obs,;
		SPACE(50) As msg_protocolo,Space(50) As msg_registrodped,;
		SPACE(55) chave_nfe_str,Space(36) dados_add_nfe,Space(44) dados_add_nfe_str,;
		SPACE(100) chave_nfe_str_barra,Space(100) dados_add_nfe_barra ;
		FROM cur_lst_nfs Where .F. Into Cursor cur_frmnfe_obs Readwrite

	Select cur_lst_nfs
	Scan
		Select Count(Distinct n_form) cnt_n_form From vtmp_impressao_nf_00_itens ;
			WHERE nf=cur_lst_nfs.nf And serie_nf=cur_lst_nfs.serie_nf And filial=cur_lst_nfs.filial Into Cursor cur_count_n_form

		Select vtmp_impressao_nf_00
		Locate For Alltrim(filial)+Alltrim(nf)+Alltrim(serie_nf) == Alltrim(cur_lst_nfs.filial)+Alltrim(cur_lst_nfs.nf)+Alltrim(cur_lst_nfs.serie_nf)
		xchavestr = Nvl(Subs(chave_nfe,1,4)+' '+Subs(chave_nfe,5,4)+' '+Subs(chave_nfe,9,4)+' '+Subs(chave_nfe,13,4)+' '+Subs(chave_nfe,17,4)+' '+Subs(chave_nfe,21,4)+' '+Subs(chave_nfe,25,4)+' '+Subs(chave_nfe,29,4)+' '+Subs(chave_nfe,33,4)+' '+Subs(chave_nfe,37,4)+' '+Subs(chave_nfe,41,4),'')

		xendemitentestr = Allt(Nvl(vtmp_impressao_nf_00.endereco_emitente,'')) + Nvl(', ' + Allt(vtmp_impressao_nf_00.numero_emitente),'') + Nvl(Space(2) + Allt(vtmp_impressao_nf_00.complemento_emitente),'') + Nvl(' - '+Allt(vtmp_impressao_nf_00.bairro_emitente),'') + Chr(13) +;
			allt(vtmp_impressao_nf_00.cidade_emitente) + '/' + Allt(vtmp_impressao_nf_00.uf_emitente) + Nvl(' - ' + Allt(vtmp_impressao_nf_00.pais_emitente),'') + Chr(13) +;
			'CEP: ' + Allt(vtmp_impressao_nf_00.cep_emitente) + Chr(13) +;
			nvl('TEL: ' + '('+Allt(vtmp_impressao_nf_00.ddd1_emitente)+')'+Allt(vtmp_impressao_nf_00.telefone1_emitente),'')

		f_select('Select PROTOCOLO_AUTORIZACAO_NFe,DATA_AUTORIZACAO_NFe,REGISTRO_DPEC,DATA_REGISTRO_DPEC '+;
			'  FROM w_Impressao_NFe where nf=?Cur_Lst_Nfs.nf and serie_nf=?Cur_Lst_Nfs.serie_nf and filial=?Cur_Lst_Nfs.filial','CurTmp_Prot',Alias())

		xobsfrm = Alltrim(Nvl(cur_lst_nfs.obs_final_frm,''))
		=f_quebra_obs_frm_danfe(Upper(xobsfrm),plenobsfrm)

		xseqobs = 0
		xseqobsfrm = 0

		Do Whil !Eof('Cur_Lst_Nfs')
			xseqobs = xseqobs + 1
			xseqobsfrm = xseqobsfrm+1

			Select cur_ctrl_obsform
			Locate For id_form==xseqobsfrm
			xobs = Alltrim(obs_form)

			xn_form = cur_lst_nfs.n_form
			If !Empty(xobs) And xseqobs>1 And cur_count_n_form.cnt_n_form>1
				xn_form = xn_form+1
				xseqobs = 1
				Select cur_lst_nfs
				Skip
			Endif

			If xseqobs>1 And cur_count_n_form.cnt_n_form=1
				xn_form = xseqobs
			Endif

			Select cur_frmnfe_obs
			Append Blank In cur_frmnfe_obs
			Replace nf With cur_lst_nfs.nf, serie_nf With cur_lst_nfs.serie_nf, filial With cur_lst_nfs.filial, n_form With xn_form,;
				seq_obs 				With xseqobs,;
				obs_form 				With xobs,;
				endereco_emitente_str	With xendemitentestr,;
				msg_protocolo     		With Nvl(Allt(Nvl(curtmp_prot.protocolo_autorizacao_nfe,''))+' '+Nvl(Ttoc(curtmp_prot.data_autorizacao_nfe),''),''),;
				msg_registrodped  		With Nvl(Allt(Nvl(curtmp_prot.registro_dpec,''))+' '+Nvl(Ttoc(curtmp_prot.data_registro_dpec),''),''),;
				chave_nfe_str	  		With xchavestr,;
				dados_add_nfe	  		With f_dados_nfe_add(.F.),;
				dados_add_nfe_str 		With f_dados_nfe_add(.T.), ;
				chave_nfe_str_barra 	With bc_ocode128(Alltrim(Nvl(Allt(vtmp_impressao_nf_00.chave_nfe),'')),0,0,0),;
				dados_add_nfe_barra 	With bc_ocode128(Allt(cur_frmnfe_obs.dados_add_nfe),0,0,0) In cur_frmnfe_obs

			Select vtmp_impressao_nf_00_itens
			Locate For nf=cur_lst_nfs.nf And serie_nf=cur_lst_nfs.serie_nf And filial=cur_lst_nfs.filial And n_form=xn_form And seq_obs=xseqobs
			If Eof()
				Append Blank
				Replace nf With cur_lst_nfs.nf, serie_nf With cur_lst_nfs.serie_nf, filial With cur_lst_nfs.filial,;
					status_nfe With cur_lst_nfs.status_nfe, tipo_emissao_nfe With  cur_lst_nfs.tipo_emissao_nfe, n_form With xn_form, seq_obs With xseqobs,item_add With 1
			Endif

			Select vtmp_impressao_nf_00_itens
			If Reccount('Cur_Ctrl_ObsForm')=0 Or Reccount('Cur_Ctrl_ObsForm')=xseqobsfrm && Sem Obs ou Ultima linha da obs
				Exit
			Endif
		Enddo
	Endscan


	*-- Ajuste/Padronização dos Itens: Fixar iguais para todos os formulários (para preencher espaçamento) 
	Select nf,serie_nf,filial,status_nfe,tipo_emissao_nfe,n_form,seq_obs,frm_aux,Max(item_nfe) item_nfe,Min(n_qb_item) n_qb_item,Count(*) cnt_itens ;
		FROM vtmp_impressao_nf_00_itens Group By 1,2,3,4,5,6,7,8 Into Cursor cur_lst_nfs
	
	Select cur_lst_nfs
	Scan
		xitenspfrm = Iif(n_form=1,pitens1,Iif(frm_aux,pitens3,pitens2)) 
		If cnt_itens < xitenspfrm
			For i = cnt_itens+1 To xitenspfrm
				Select vtmp_impressao_nf_00_itens
				Append Blank
				Replace nf With cur_lst_nfs.nf, serie_nf With cur_lst_nfs.serie_nf, filial With cur_lst_nfs.filial, item_nfe With cur_lst_nfs.item_nfe,;
					status_nfe With cur_lst_nfs.status_nfe, tipo_emissao_nfe With  cur_lst_nfs.tipo_emissao_nfe, ;
					n_form With cur_lst_nfs.n_form, n_qb_item With cur_lst_nfs.n_qb_item, ;
					seq_obs With cur_lst_nfs.seq_obs, frm_aux With cur_lst_nfs.frm_aux, item_add With 1 
			Endfor
		Endif
	Endscan

	*-- Ajuste t_form
	Select nf,serie_nf,filial,Max(n_form) num_frm From vtmp_impressao_nf_00_itens Group By 1,2,3 Into Cursor curtmp_maxfrm
	Select curtmp_maxfrm
	Scan
		Select vtmp_impressao_nf_00_itens
		Replace All t_form With curtmp_maxfrm.num_frm For  nf=curtmp_maxfrm.nf And serie_nf=curtmp_maxfrm.serie_nf And filial=curtmp_maxfrm.filial
	Endscan

	Return .T.
	*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*


	*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Function f_dados_nfe_add()
	Lparameters pcomspace

	Local xcba_str,xdv_cba,xretdados

	f_select('SELECT TOP 1 f.uf,SUBSTRING(m.COD_MUNICIPIO_IBGE,1,2) as cMun '+;
		'  FROM cadastro_cli_for f  (nolock) '+;
		' INNER JOIN LCF_LX_MUNICIPIO m  (nolock) ON DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE(default,f.cidade) = m.DESC_MUNICIPIO '+;
		' INNER JOIN LCF_LX_UF u (nolock) ON u.uf = f.uf and u.ID_UF = m.ID_UF'+;
		' WHERE f.nome_clifor=?vTmp_impressao_nf_00.nome_clifor','Cur_Info_UF',Alias())

	xcba_str = Right('00'+Alltrim(Iif(f_vazio(cur_info_uf.cmun),'99',cur_info_uf.cmun)),2)+;
		RIGHT('0'+Alltrim(Nvl(vtmp_impressao_nf_00.tipo_emissao_nfe,'')),1)+;
		RIGHT(Replicate('0',14)+Alltrim(Nvl(vtmp_impressao_nf_00.cnpj_emitente,'')),14)+;
		RIGHT(Replicate('0',14)+Alltrim(Str(vtmp_impressao_nf_00.valor_total*100)),14)+;
		IIF(vtmp_impressao_nf_00.icms>0,'1','2')+;
		IIF(vtmp_impressao_nf_00.icms_st>0,'1','2')+;
		RIGHT('00'+Alltrim(Str(Day(Ctod(vtmp_impressao_nf_00.emissao)))),2)

	xdv_cba = f_mod11_nfe(xcba_str)
	xretdados = xcba_str+xdv_cba

	If pcomspace
		xretdados = Subs(xretdados,1,4)+' '+Subs(xretdados,5,4)+' '+Subs(xretdados,9,4)+' '+Subs(xretdados,13,4)+' '+Subs(xretdados,17,4)+' '+Subs(xretdados,21,4)+' '+Subs(xretdados,25,4)+' '+Subs(xretdados,29,4)+' '+Subs(xretdados,33,4)
	Endif

	Return (xretdados)
	*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*

	*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Function f_mod11_nfe()
	Lparameters pstrchave

	Local xstrpeso,xseqmult,xresacum,m,xcalc
	xstrpeso = '98765432'

	xseqmult = 1
	xresacum = 0
	For m = Len(pstrchave) To 1 Step -1
		xseqmult = xseqmult+1
		If xseqmult>9
			xseqmult = 2
		Endif
		xresacum = xresacum + ( Val(Substr(pstrchave,m,1)) * xseqmult )
	Endfor

	xcalc = (11 - Mod(xresacum,11))

	Return Alltrim(Str((xcalc)))
	*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*

	*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Function fx_getreportproperty
	Lparameters xObj,strreportfield As String

	Return Iif(Type("strReportField") == "C" And !Empty(strreportfield) And Type("xObj.SelectedListObject.ListIndex") == "N" And xObj.selectedlistobject.ListIndex >= 0 And ;
		type("xObj.SelectedListObject.ItemValues(xObj.SelectedListObject.ListIndex, strReportField)") == "O" And ;
		!Isnull(xObj.selectedlistobject.itemvalues(xObj.selectedlistobject.ListIndex, strreportfield)) , ;
		xObj.selectedlistobject.itemvalues(xObj.selectedlistobject.ListIndex, strreportfield).Value, "")

	Return .F.
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*

*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*

Function fx_control_obj_export
	Lparameters pstart

	If pstart
		Public oxfrx, intstatusxfrx
		
		Try    
			oxfrx = xfrx("XFRX#LISTENER")
		Catch To loErro    
			Messagebox(loErro.Message)    
			Return .F.
		Endtry
		
		oXFRX.setEmbeddingType(3) 
		intstatusxfrx = oxfrx.setparams(reportexport.filename,,.T.,,,,reportexport.currentfileformat)
		Return (intstatusxfrx = 0) 
	Else
		*--- Se o objeto existe, finaliza e libera SEMPRE (evita travar na rede)
		If Type('oXFRX') = 'O' 
			Try        
				oxfrx.finalize()     
			Catch 
				* Caso o método finalize não exista na versão do XFRX
			EndTry
			
			* Garante a destruição total da referência do objeto
			oxfrx = .Null.
			Release oxfrx
			
			* Força o Windows a salvar fisicamente os dados na rede UNC
			Flush
			
			* Aguarda 1 segundo para a rede liberar o arquivo de vez
			Inkey(1)
			
			Return .T.
		Endif
	Endif
	
Endfunc

*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*

*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Function f_load_ctrl_nf_financ_nfe
	Lparameters bLinxErp

	*-- Cursor (Cur_CTB_Parcelas)
	Local xfields As Character, k As Character, k_ As Character
	Store '' To xfields
	For k = 1 To 48
		k_ = Alltrim(Str(k))
		xfields = xfields + Iif(Empty(xfields),'',',') + 'space(15) as Dup_Parc'+k_ + ', 000000000.00 as val_parc'+k_ + ', {} as venc_parc'+k_
	Endfor

	xfields = [nf,serie_nf,filial,NVL(fatura,'') as Fatura,ctb_lancamento,SPACE(LEN(fatura)) as fatura_conf,ctb_item,nome_clifor,origem_nf,cod_transacao,tipo_emissao_nfe,status_nfe,INFO_PGTO,] + xfields &&#20#
	Select Distinct &xfields From vtmp_impressao_nf_00 Into Cursor cur_ctb_parcelas Readwrite &&##

	*-- Dados
	Select cur_ctb_parcelas
	Scan For Inlist(Val(info_pgto),2,3,15,14) &&#20# &&#22#
		f_select("Select nFat as Fatura,Id_parcela as parcela,nDup as Duplicata,vDup as Valor,dVenc as Vencimento "+;
			"  From dbo.fx_ctb_simula_parcelas('" + Alltrim(cur_ctb_parcelas.filial) + "','" + Alltrim(cur_ctb_parcelas.nf) + "','" + Alltrim(cur_ctb_parcelas.serie_nf) + "','" + Alltrim(cur_ctb_parcelas.origem_nf) + "','" + Alltrim(cur_ctb_parcelas.cod_transacao) + "') Order by Fatura,Parcela","curTmp_parc",Alias())

		Sele curtmp_parc
		Go Top

		Sele curtmp_parc
		xi_parc = 0
		Scan While !Eof() And xi_parc<48
			xi_parc = xi_parc + 1
			xi		= Alltrim(Str(xi_parc))

			If !Empty(Nvl(Alltrim(curtmp_parc.duplicata),'')) And Nvl(curtmp_parc.valor,0)>0
				Sele cur_ctb_parcelas
				Replace dup_parc&xi  With Nvl(Alltrim(curtmp_parc.duplicata),''), ;
					val_parc&xi  With Nvl(curtmp_parc.valor,0),;
					venc_parc&xi With Nvl(curtmp_parc.vencimento,{})
				Sele curtmp_parc
			Endif

		Endscan

		Sele cur_ctb_parcelas
	Endscan

	Return .T.
	*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*

	*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Function f_add_itens_frm_auxiliar() 

	Select  b.nf,b.serie_nf,b.filial,b.item_nfe,b.item_impressao,b.sub_item_tamanho,b.codigo_item,b.descricao_item,b.desconto_total_item,b.status_nfe,b.tipo_emissao_nfe,b.item_add,b.seq_obs,b.n_qb_item,b.frm_aux ;
		INTO Cursor vTmp_ItensComDesc ;
		FROM vtmp_impressao_nf_00 a ;
		JOIN vtmp_impressao_nf_00_itens b On b.nf=a.nf And b.serie_nf=b.serie_nf And b.filial=a.filial ;
		WHERE a.uf_emitente='RJ' And desconto_total_item>0

	Insert Into vtmp_impressao_nf_00_itens (nf,serie_nf,filial,item_nfe,item_impressao,sub_item_tamanho,codigo_item,descricao_item,desconto_total_item,status_nfe,tipo_emissao_nfe,item_add,seq_obs,n_qb_item,frm_aux);
		select nf,serie_nf,filial,item_nfe,item_impressao,sub_item_tamanho,codigo_item,descricao_item,desconto_total_item,status_nfe,tipo_emissao_nfe,item_add,seq_obs,n_qb_item,.T. As frm_aux From vTmp_ItensComDesc

	Return .T.
	*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*


	*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Function f_tratar_len_itens_danfe

	*-- Numero de Caracters para quebra de linha (Descricao_Item)
	f_select("Select valor_atual From Parametros Where Parametro='TAMANHO_LINHA_ITEM_DANFE'","CurTmp_TamLin_Item",Alias())
	xlenmax = Val(Nvl(Alltrim(curtmp_tamlin_item.valor_atual),''))
	xlenmax = Iif(xlenmax=0,38,xlenmax)

	Select * From vtmp_impressao_nf_00_itens Where .F. Into Cursor cur_lst_itens_add_len Readwrite

	Select vtmp_impressao_nf_00_itens
	Scan

		xobsitem = ''
		If !(Isnull(obs_item) Or Empty(obs_item))
			xcarultimalinha = Len(Alltrim(descricao_item)) % xlenmax
			If xcarultimalinha > 0 Then
				xobsitem = Replicate(' ',xlenmax - xcarultimalinha)
			Endif
			xobsitem = xobsitem + Alltrim(obs_item)
		Endif

		xdescitem = Alltrim(descricao_item) + xobsitem

		If Len(xdescitem)>xlenmax
			xcountqblin = 0

			Do Whil !Empty(xdescitem)
				xcountqblin = xcountqblin + 1
				xdesitemqb  = Substr(xdescitem,1,xlenmax)

				If xcountqblin > 1
					Select cur_lst_itens_add_len
					Append Blank
					Replace filial 		 With vtmp_impressao_nf_00_itens.filial,;
						nf 				 With vtmp_impressao_nf_00_itens.nf,;
						serie_nf 		 With vtmp_impressao_nf_00_itens.serie_nf,;
						item_nfe		 With vtmp_impressao_nf_00_itens.item_nfe,;
						item_impressao	 With vtmp_impressao_nf_00_itens.item_impressao,;
						sub_item_tamanho With vtmp_impressao_nf_00_itens.sub_item_tamanho,;
						status_nfe		 With vtmp_impressao_nf_00_itens.status_nfe,;
						tipo_emissao_nfe With vtmp_impressao_nf_00_itens.tipo_emissao_nfe,;
						item_add		 With vtmp_impressao_nf_00_itens.item_add,;
						seq_obs			 With vtmp_impressao_nf_00_itens.seq_obs,;
						n_qb_item		 With xcountqblin
				Else
					Select vtmp_impressao_nf_00_itens
				Endif

				Replace descricao_item With xdesitemqb
				xdescitem = Substr(xdescitem,xlenmax+1,Len(xdescitem))
			Enddo
		Endif
	Endscan
	*--


	*-- Numero de Caracters para quebra de linha (codigo_item)
	*		xLenMax = 17
	*		xWidthMax = 22	&& Width máximo em função da fonte utilizada no DANFE
	xwidthmax = 22 &&**#6#

	Select vtmp_impressao_nf_00_itens
	Scan
		xcoditem = Alltrim(codigo_item)
		xwidthitem = Txtwidth(xcoditem,'Times New Roman',6,'N')	&& Width do código do item em função da fonte

		If xwidthitem > xwidthmax Then	&& Se o width do código do item for maior que o limite
			xcountqblin = 0

			Do Whil !Empty(xcoditem)
				xcountqblin = xcountqblin + 1
				xposquebra = f_quebra_texto_fonte(xcoditem, xwidthmax, 'Times New Roman',6,'N')	&& obtém próxima posição de quebra
				xcoditemqb = Left(xcoditem, xposquebra)

				If xcountqblin > 1
					Select cur_lst_itens_add_len
					Locate For filial==vtmp_impressao_nf_00_itens.filial And ;
						nf==vtmp_impressao_nf_00_itens.nf And ;
						serie_nf==vtmp_impressao_nf_00_itens.serie_nf And ;
						item_nfe==vtmp_impressao_nf_00_itens.item_nfe And ;
						item_impressao==vtmp_impressao_nf_00_itens.item_impressao And ;
						sub_item_tamanho==vtmp_impressao_nf_00_itens.sub_item_tamanho And ;
						item_add==vtmp_impressao_nf_00_itens.item_add And ;
						n_qb_item==xcountqblin
					If Eof()
						Append Blank
						Replace filial 			 With vtmp_impressao_nf_00_itens.filial,;
							nf 				 With vtmp_impressao_nf_00_itens.nf,;
							serie_nf 		 With vtmp_impressao_nf_00_itens.serie_nf,;
							item_nfe		 With vtmp_impressao_nf_00_itens.item_nfe,;
							item_impressao	 With vtmp_impressao_nf_00_itens.item_impressao,;
							sub_item_tamanho With vtmp_impressao_nf_00_itens.sub_item_tamanho,;
							status_nfe		 With vtmp_impressao_nf_00_itens.status_nfe,;
							tipo_emissao_nfe With vtmp_impressao_nf_00_itens.tipo_emissao_nfe,;
							item_add		 With vtmp_impressao_nf_00_itens.item_add,;
							seq_obs			 With vtmp_impressao_nf_00_itens.seq_obs,;
							n_qb_item		 With xcountqblin
					Endif
				Else
					Select vtmp_impressao_nf_00_itens
				Endif

				Replace codigo_item With xcoditemqb
				xcoditem = Substr(xcoditem,xposquebra + 1, Len(xcoditem))	&& Estabelece o código restante
			Enddo
		Endif
	Endscan

	If Reccount('Cur_Lst_Itens_Add_Len')>0
		Insert Into vtmp_impressao_nf_00_itens Select * From cur_lst_itens_add_len
	Endif

	Select filial,nf,serie_nf,item_impressao,item_nfe,Max(n_qb_item) max_n_qb_item ;
		FROM vtmp_impressao_nf_00_itens Where n_qb_item>1 Group By 1,2,3,4,5 Into Cursor curtmp_controle_ult_itemqb

	Select curtmp_controle_ult_itemqb
	Scan && Controle (identifica ultimo Item adicionado para uso na linha de separação)
		Select vtmp_impressao_nf_00_itens
		Locate For  filial==curtmp_controle_ult_itemqb.filial And nf==curtmp_controle_ult_itemqb.nf And serie_nf==curtmp_controle_ult_itemqb.serie_nf;
			AND item_impressao==curtmp_controle_ult_itemqb.item_impressao ;
			AND item_nfe==curtmp_controle_ult_itemqb.item_nfe And n_qb_item==curtmp_controle_ult_itemqb.max_n_qb_item
		If !Eof()
			Replace ult_n_qb_item With .T.
		Endif
	Endscan

	Return .T.
	*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*

Function f_quebra_texto_fonte() && Quebra o texto em função da fonte retornando a posição da quebra
	Lparameters ptexto, pwidthmax, pfontenome, pfontetamanho, pfonteestilo

	xtexto = ptexto
	xwidthtexto = Txtwidth(xtexto, pfontenome, pfontetamanho, pfonteestilo)
	Do While xwidthtexto > pwidthmax
		xtexto = Left(xtexto,Len(xtexto)-1)
		xwidthtexto = Txtwidth(xtexto, pfontenome, pfontetamanho, pfonteestilo)
	Enddo
	xposicaoquebra = Len(xtexto)

	Return xposicaoquebra

	*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*

Function f_quebra_obs_frm_danfe() && Form Control
	Lparameters pobs,plenobsfrm

	xlim_tamlin = Int(Val(Substr(xlenobsfrm,At('/',xlenobsfrm)+1,Len(xlenobsfrm))))
	xlim_linfrm = Int(Val(Substr(xlenobsfrm,1,At('/',xlenobsfrm)-1)))

	*-- Tamanho das Linhas
	Declare xobslines(1)
	xobs = Alltrim(Strt(pobs,Chr(10),''))
	xobs = Strt(xobs,' = ','=')
	xlim_tamlin = Iif(xlim_tamlin=0,Len(xobs),xlim_tamlin)

	xcountlin = 0
	Do Whil !Empty(xobs)

		xlin_txt = Substr(xobs,1,xlim_tamlin)
		If At(Chr(13),xlin_txt)>0
			xlin_txt = Substr(xlin_txt,1,At(Chr(13),xlin_txt))
			xobs = Substr(xobs,At(Chr(13),xlin_txt)+1,Len(xobs))
		Else
			If Substr(xobs,xlim_tamlin,1)=Chr(13) Or Empty(Substr(xobs,xlim_tamlin+1,1))
				xlin_txt = Strt(xlin_txt,Chr(13),'')
				xobs	 = Substr(xobs,xlim_tamlin+1,Len(xobs))
			Else
				For u = Len(xlin_txt) To 1 Step -1
					If Empty(Substr(xlin_txt,u,1)) Or Substr(xlin_txt,u,1)=Chr(13) Or Inlist(Substr(xlin_txt,u,1),'/','\','-','.') 
						xlin_txt = Substr(xlin_txt,1,u)
						xobs = Substr(xobs,u+1,Len(xobs))
						Exit
					Endif
				Endfor
			Endif
		Endif

		xcountlin = xcountlin+1
		Declare xobslines(xcountlin)
		xobslines(xcountlin) = Strt(xlin_txt,Chr(13),'')
		xobs = Iif(Left(xobs,1)=Chr(13),Substr(xobs,2,Len(xobs)),xobs)
	Enddo


	*-- Linhas por formulário
	If Used('Cur_Ctrl_ObsForm')
		Use In cur_ctrl_obsform
	Endif

	Create Cursor cur_ctrl_obsform(id_form N(1),obs_form m(4))
	Select cur_ctrl_obsform
	Append Blank
	Replace id_form With 1

	If xcountlin > 0
		xcount_frm    = 1
		xcountlin_frm = 0
		For kl =  1 To Alen(xobslines)
			xcountlin_frm = xcountlin_frm+1
			If xcountlin_frm> xlim_linfrm
				xcount_frm = xcount_frm + 1
				xcountlin_frm = 1
				Append Blank
				Replace id_form With xcount_frm In cur_ctrl_obsform
			Endif
			Replace obs_form With Iif( Empty(obs_form) , xobslines(kl) , Alltrim(obs_form)+Chr(13) + xobslines(kl) )
		Endfor
	Endif

	Return .T.

	*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
