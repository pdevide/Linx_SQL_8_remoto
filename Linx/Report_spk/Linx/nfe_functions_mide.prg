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
*-- Rodrigo Souza   : 09/05/2018: #18# - ID - 73661 - Correção no calculo de ICMS Diferimento para notas fiscais de entrada.
*-- Rodrigo Souza   : 27/08/2018: #19# - ID - 91227 - Correção para evitar duplicidade quando houver duas tabelas do IBPT com a mesma data de vigencia.
*-- Rodrigo Souza   : 28/08/2018: #20# - ID - 91148 - Correção para gerar informação de duplicata somente para os tipos de pagamento '02','03','15'
*-- Rodrigo Souza   : 26/09/2018: #21# - ID - 95370 - Alterado de INNER para LEFT validação com a tabela do IBPT.
*-- Rodrigo Souza   : 19/03/2019: #22# - ID - 113492 - Correção para comparar o valor inteiro do código de tipos de pagamento.
*-- Juliana Nascimento: 06/12/2019: #23# - MODASP-9055 - Correção no processo de diferimento.
*-- Douglas Garcia: 08/01/2020: #24# - MODASP-9922 - Ajuste na correção #23# / Removido chamada de cursor inexistente
*-- Juliana Nascimento: 20/03/2020: #25# - MODASP-11865 - Ajuste no valor do desconto caso exista o imposto icms_zf
*-- Juliana Nascimento: 24/08/2020: #26# - SUSTSP-1069 - Ajuste para trazer as informações do frete na descrição da danfe
*-- Juliana Nascimento: 02/09/2020: #27# - SUSTSP-1156 - Ajuste para do frete para versão 4.00
*-- Valmir Soares     : 13/01/2021: #28# - LINXERP-405 - Mensagem de Não Incidência de FECP em Dados Adicionais
*-- Juliana Nascimento: 09/06/2021: #29# - PRODSHOP-6729 - Ajuste no nome da transportadora
*-- Valmir Soares     : 11/08/2021: #30# - LINXERP-790 - INTEGSP-1877 RJ - Discriminar descontos promocionais nos documentos fiscais - Lei nº 8.603, de 01.11.2019 - DOE RJ de 04.11.2019
*-- Valmir Soares     : 16/02/2022: #31# - LINXERP-8978 - Ajuste condição para gerar obs_item (infAdProd)
*-- Juliana Nascimento: 24/05/2022: #32# - PRODSHOP-12797 - Ajuste na correção #19# para evitar lentidão na impressão da danfe.
*-- Valmir Soares     : 19/07/2022: #33# - LINXERP-10607  - Impressão do DANFE Simplificado
*-- Valmir Soares     : 21/07/2022: #34# - LINXERP-856    - Alteração na mensagem do FECP
*-- Carlos Alberto    : 11/08/2022: #35# - LINXERP-11311  - Revisão da alteração #33# para evitar erro por falta da propriedade p_DANFE_Simplificado
*-- Rafael Cassio     : 03/11/2022: #36# - LINXERP-12257  - Inclusão de opção para geração direta de PDF pela tela de Monitor NFe 100135
*-- Rafael Cassio     : 10/11/2022: #37# - LINXERP-12419  - Filtro para setar default somente se for diferente do tipo PDF
*-- Valmir Soares     : 20/01/2023: #38# - LINXERP-12904  - Modelo de DANFE Simplificada com ajuste ref. instrução Normativa RE nº 79, de 19.09.2022 - DOE RS de 21.09.2022
*-- Valmir Soares     : 14/02/2023: #39# - LINXERP-6399   - Adaptação relativo à ponto de retirada de mercadoria - Ajuste SINIEF nº 14, de 01.07.2022 - DOU de 06.07.2022 e Decreto nº 49.824, de 25.11.2020 - DOE PE de 26.11.2020
*-- Valmir Soares     : 02/03/2023: #40# - LINXERP-13645  - Padronização do nome do campo NOME_LOCAL_RETIRADA ref. ajuste #39#
*-- Dario Silva       : 19/04/2023: #41# - PRODSHOP-19012 - Correção de FATURA/DUPLICATA para quando gerada pela tela 400001.
*-- Juliana Nascimento: 06/06/2023: #42# - PRODSHOP-19682 - Correção na geração do código de barra
*-- Marcelo Faria:    : 06/06/2024: #43# - LINXERP-17560  - Construir danfe a partir dos dados do xml autorizado
*-- Marcelo Faria:    : 06/06/2024: #44# - LINXERP-18914  - Ajuste por conta de erro na obscont (mais de uma linha por nf)
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*



*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Procedure PrintNfe
	
	Lparameter xTipo,xObj,xCurSelecaoImpressao,cPastapdf,str_NF,strSerie_NF,intQtdeVias,FormMain
	Local bLinxErp As boolean, strFilial As String, strNf_numero As String, bModelo_Simplificado As boolean
	Public xkimp
	bLinxErp = Pcount() == 3
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
	
	If (Pcount() == 6 and xTipo = 'PDF')
		bLinxErp = .t.
	Endif
	
	intQtdeVias = Iif(Type("intQtdeVias") != "N" Or (Type("intQtdeVias") == "N" And intQtdeVias < 1), 1, Iif(intQtdeVias > 5, 5, intQtdeVias))
	
	If bLinxErp && #33#
		bModelo_Simplificado = Iif(Type("xObj.p_DANFE_Simplificado") = 'U', .F., Nvl(xObj.p_DANFE_Simplificado,.F.)) && #33# #35#
	Else
		bModelo_Simplificado = Iif(Type("FormMain.p_DANFE_Simplificado") = 'U', .F., Nvl(FormMain.p_DANFE_Simplificado,.F.)) && #33# #35#
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

	*--Inicio Geração de Arquivos em PDF -- #36#
	
	If Upper(xTipo)='PDF'
	
		oXFRX = XFRX("XFRX#LISTENER")
		pFileDest_ = cPastapdf
		pFileDest_ = pFileDest_ + "\"+ Alltrim(str_NF) + "_" + Alltrim(strSerie_NF) +".pdf"
		intStatusXFRX = oXFRX.SetParams(pFileDest_,,.T.,,,,xTipo)
		xsaida1 = "Object oXFRX NOPAGEEJECT"
		xsaida2  = 'Object oXFRX NOPAGEEJECT NORESET'
	EndIf
	
	*--Fim Geração de Arquivos em PDF -- #36#

	*-- Itens por formulário para o DANFE -- #30#
	f_select("Select valor_atual From Parametros Where Parametro='ITENS_P_FORM_DANFE'","CurTmp_Itens_p_form",Alias())
	xitenspd  = Nvl(Alltrim(curtmp_itens_p_form.valor_atual),'')

	xitenspd1 = Val(Iif(Atc('/',xitenspd,1)=0,'',Substr(xitenspd,1,Atc('/',xitenspd,1)-1)))																						&& Primeiro Formulário
	xitenspd2 = Val(Iif(Atc('/',xitenspd,1)=0,'',Substr(xitenspd,Atc('/',xitenspd,1)+1,Iif(Atc('/',xitenspd,2)>0,(Atc('/',xitenspd,2)-Atc('/',xitenspd,1)-1),Len(xitenspd))))) 	&& Segundo  Formulário
	xitenspd3 = Val(Iif(Atc('/',xitenspd,2)=0,'',Substr(xitenspd,Atc('/',xitenspd,2)+1,Len(xitenspd))))																			&& Terceiro Formulário

	xitenspd1 = Iif(xitenspd1>0,xitenspd1,16) && Padrão Primeiro Formulário
	xitenspd2 = Iif(xitenspd2>0,xitenspd2,46) && Padrão Segundo  Formulário
	xitenspd3 = Iif(xitenspd3>0,xitenspd3,46) && Padrão Terceiro Formulário
	*--

	Try
		If bLinxErp
			If !fx_danfe_init(xCurSelecaoImpressao,xitenspd1,xitenspd2,xitenspd3,xlenobsfrm) && -- #30#
				Return .F.
			Endif
		Else
			If !fx_danfe_init(xCurSelecaoImpressao,xitenspd1,xitenspd2,xitenspd3,xlenobsfrm,strFilial,strNf_numero,strSerie_NF,intQtdeVias,FormMain) && -- #30#
				Return .F.
			Endif
		Endif
	Catch
	Endtry
	&&#43#
*!*		Set Step On
*!*		Select vtmp_impressao_nf_00
*!*		Browse
	
	
	*-- Formulários
	If bLinxErp
		plst_reports_1 = xdirrel+Iif(bModelo_Simplificado,'L_DANFE_SIMP','L_DANFE1')+'.FRX' 	&& -- #33#
		plst_reports_2 = Iif(bModelo_Simplificado,'',xdirrel+'L_DANFE2.FRX')				&& -- #33#
		plst_reports_3 = Iif(bModelo_Simplificado,'',xdirrel+'L_DANFE3.FRX') && -- #30#		&& -- #33#
	Else
		plst_reports_1 = Addbs(FormMain.systempath) + 'Reports\'+Iif(bModelo_Simplificado,'L_DANFE_SIMP','L_Danfe1')+'.FRX'	&& -- #33#
		plst_reports_2 = Iif(bModelo_Simplificado,'',Addbs(FormMain.systempath) + 'Reports\L_Danfe2.frx')					&& -- #33#
		plst_reports_3 = Iif(bModelo_Simplificado,'',plst_reports_2) && -- #30#												&& -- #33#
	Endif

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
		Endif

	Endif

	If Justext(plst_reports_1)='FRX' And (!bModelo_Simplificado And !File(plst_reports_2)) && -- #33#
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
							If cur_lst_danfe_emitir.frm_aux And !Empty(plst_reports_3) And File(plst_reports_3) && -- #33#
								Report Form (plst_reports_3) &xsaida  && Impressão -- #30#
							Else
								If !Empty(plst_reports_2) And File(plst_reports_2) && -- #33#
									Report Form (plst_reports_2) &xsaida  && Impressão -- #30#
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
	Lparameters xCurSelecaoImpressao,pitens1,pitens2,pitens3,plenobsfrm,strFilial,strNf_numero,strSerie_NF,intQtdeVias,FormMain && -- #30#

	Local bLinxErp As boolean
	bLinxErp = Pcount() == 5  && -- #30#

	*-- NF-e (D.A.N.F.E.)
	Public x_proce,ximp_dsai,ext1,ext2,ext3,xsenttoprinter

	xsenttoprinter = .F.
	ximp_dsai = .T. && f_msg(['Deseja Imprimir a Data de Saida?',4+32+256,'<Aviso...>'])=6

	If bLinxErp
		x_proce = Set('PROCE')
		Set Procedure To ..\Report.prg\l002016.prg Additive && Barcodes Retaguarda
		xfilterpai = " 1=2 "
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
					   INFO_PGTO, cod_filial, Convert(bit,0) as Mostra_Tot_NF_DANFE_Simp,
					   convert(bit,(case when NOME_LOCAL_RETIRADA IS NOT NULL AND NOME_LOCAL_RETIRADA<>NOME_CLIFOR AND INDICA_PRESENCA_COMPRADOR IN (2,3) then 1 else 0 end)) as Mostra_Retirada,
					   nome_local_retirada, retirada_entrega_razao_social, retirada_entrega_endereco, retirada_entrega_numero, retirada_entrega_complemento, retirada_entrega_cidade, retirada_entrega_uf, retirada_entrega_bairro, retirada_entrega_cep, retirada_entrega_telefone, retirada_entrega_ddd, retirada_entrega_ddi, retirada_entrega_cgc, retirada_entrega_ie, retirada_pj_pf,
					   retirada_entrega_tel_str = isnull(rtrim(ltrim(isnull(ddi,''))) + (case when len(rtrim(ltrim(isnull(telefone1,'')))) > 8 then ' ' else ' (' + rtrim(ltrim(isnull(ddd1,''))) + ') ' end) + rtrim(ltrim(isnull(telefone1,''))),''), Replicate(' ', 44) as chave_nfe_str,Replicate(' ', 50) as msg_protocolo, Replicate(' ', 10) as cmun_destinatario
				  From W_IMPRESSAO_NFE Where <<xFilterPai>> and 1=2
	ENDTEXT
		

	f_select(xsqlnfe_pai, "vTmp_impressao_nf_00")
	If Reccount('vTmp_impressao_nf_00')=0 and 1=2
		Messagebox('Nenhuma NFe Válida Selecionada no Filtro:'+Chr(13) + (xfilterpai),48,'Aviso')
		Return .F.
	Endif

	Select vTmp_impressao_nf_00
	Append blank in vTmp_impressao_nf_00
	
	&&#43#
	
	&&criar cursor filho vazio
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
	   NFE_ITENS.ipi_aliquota, (NFE_ITENS.valor_descontos - NFE_ITENS.icms_zf) valor_descontos,NFE_ITENS.desconto_total_item,NFE_ITENS.valor_unitario_bruto,CONVERT(Numeric(13,2),NFE_ITENS.valor_item_bruto) as valor_item_bruto,NFE_ITENS.frete,NFE_ITENS.seguro,NFE_ITENS.Importacao,NFE_ITENS.Danfe_NFe_Importacao_Calc, valor_imposto_item = ISNULL(NFE_ITENS.VALOR_IMPOSTO_ITEM, 0)
	   ,0 as status_nfe, 0 as tipo_emissao_nfe, 0 as n_form,0 as t_form, 1 as n_qb_item, cast(0 as bit) as ult_n_qb_item, 0 as item_add, 1 as seq_obs, cast(0 as bit) As frm_aux
	  From W_IMPRESSAO_NFE_ITENS NFE_ITENS
	  JOIN W_IMPRESSAO_NFE NFE on NFE.NF=NFE_ITENS.NF AND NFE.SERIE_NF=NFE_ITENS.SERIE_NF AND NFE.FILIAL=NFE_ITENS.FILIAL
	  	LEFT JOIN CADASTRO_CLI_FOR
			ON	CADASTRO_CLI_FOR.NOME_CLIFOR=NFE_ITENS.NOME_CLIFOR
	  Where 1=2 
	  EndText
	f_select(xSqlNFE_Filha,'vtmp_impressao_nf_00_itens')
	
	
	&&fim criar cursor filho vazio
	
	If AtualizaCursorComXml(xCurSelecaoImpressao) == .f.
		Return .f.
	EndIf
	
	&&#43#
	
	
	*-- #38#
	f_select("SELECT cod_filial, valor_atual FROM PARAMETROS_RETAGUARDA_FILIAL WHERE PARAMETRO='MOSTRA_TOT_NF_DANFE_SIMP'",'CurTmp_MostraTotNfDanfeSimp',ALIAS())
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
	*-- #38#
	*-- #41#
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
	*-- #41#
	

	If bLinxErp
		xfields_ctrl_add = "NVL(vTmp_impressao_nf_00.status_nfe,0) as status_nfe, NVL(VAL(vTmp_impressao_nf_00.tipo_emissao_nfe),0) as tipo_emissao_nfe, 0000 as n_form,0000 as t_form, 001 as n_qb_item, .f. as ult_n_qb_item, 0 as item_add, 1 as seq_obs, .F. As frm_aux" && --#30#
		Select vtmp_impressao_nf_00
		Count To xtreg
		xratu = 0
		Scan
			xratu = xratu + 1
			f_prog_bar('Gerando Itens da NFe: '+ vtmp_impressao_nf_00.nf,xratu,xtreg)

			
		Endscan
		f_wait()
	Else
		xrunmetodo = f_select(xsqlnfe_filha,'vTmp_impressao_nf_00_itens_Base')
		Select *, 00 As status_nfe, 00 As tipo_emissao_nfe, 0000 As n_form, 0000 As t_form, 001 As n_qb_item, .F. As ult_n_qb_item, 0 As item_add, 0000 As seq_obs, .F. As frm_aux ; && --#30#
		From vtmp_impressao_nf_00_itens_base Into Cursor vtmp_impressao_nf_00_itens Readwrite

		Use In vtmp_impressao_nf_00_itens_base
		Replace All seq_obs With 1, status_nfe With Nvl(vtmp_impressao_nf_00.status_nfe, 0), tipo_emissao_nfe With Nvl(Val(vtmp_impressao_nf_00.tipo_emissao_nfe),0) In vtmp_impressao_nf_00_itens
	Endif
	
	*--
	f_add_itens_frm_auxiliar() && -- #30#
	f_tratar_len_itens_danfe()
	f_load_ctrl_frm_danfe(pitens1,pitens2,pitens3,plenobsfrm, FormMain, bLinxErp) && -- #30#
	**f_load_ctrl_nf_financ_nfe(bLinxErp)
	
	
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
				**xupdate = 'Update Faturamento set Nota_impressa=1 Where nf_saida=?vTmp_Impressao_NF_00.nf and serie_nf=?vTmp_Impressao_NF_00.serie_nf and filial=?vTmp_Impressao_NF_00.filial and nota_impressa=0'
				xupdate = 'Update Faturamento set Nota_impressa=1 Where chave_nfe=?vTmp_Impressao_NF_00.chave_nfe and nota_impressa=0'
			Else
				**xupdate = 'Update Entradas set nf_propria_emitida=1 Where nf_entrada=?vTmp_Impressao_NF_00.nf and nome_clifor=?vTmp_Impressao_NF_00.nome_clifor and serie_nf_entrada=?vTmp_Impressao_NF_00.serie_nf and nf_propria_emitida=0'
				xupdate = 'Update Entradas set nf_propria_emitida=1 Where chave_nfe=?vTmp_Impressao_NF_00.chave_nfe and nf_propria_emitida=0'
			Endif
			If !f_update(xupdate)
				=f_msg(['Problema ao Marcar Nota Impressa !', 0+16, 'Erro !!!'])
				*Sele &xalias && #24# - Propriedade não é preenchida em nenhum ponto
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
	Local Array acursorsclose[28, 1] && -- 30 && #38#

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
	acursorsclose[27, 1] = "CurLst_Filiais" && #38#
	acursorsclose[28, 1] = "CurTmp_MostraTotNfDanfeSimp" && #38#

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
	Lparameters _pItens1, _pItens2, _pItens3, plenobsfrm, FormMain, bLinxErp && -- #30# --#39#
	*-  _pItens1   = Numero de Itens do primeiro formulário
	*-  _pItens2   = Numero de Itens dos demais formulários (Sem descontos RJ)
	*-  _pItens3   = Numero de Itens do formulário auxiliar (Descontos RJ)
	*-  pLenObsFrm = Tamanho Máximo para quebra da OBS por Formulário (Linhas/Caracteres por linha)

	Local intidentifica_ambiente_nfe As Integer
	intidentifica_ambiente_nfe = Iif(bLinxErp, widentifica_ambiente_nfe, FormMain.p_identifica_ambiente_nfe)

	*-- Controle de Itens Por Frm
	Select vtmp_impressao_nf_00_itens
	Index On filial+nf+serie_nf+Iif(frm_aux,'1','0')+Str(item_nfe)+Str(n_qb_item) Tag iitem && --#30#

	Do Whil !Eof()
		xkey   = filial+nf+serie_nf
		xTpAux = frm_aux
		xfrm   = 1
		xcount = 0
		
 		*--{ Controle devido bloco de informações do ponto de retirada &&#39#
			Select vtmp_impressao_nf_00
			LOCATE FOR filial+nf+serie_nf==xkey
			xLinsRet = 8 
			pItens1  = _pItens1 - IIF(_pItens1>xLinsRet and vtmp_impressao_nf_00.mostra_retirada,xLinsRet,0)
			pItens2  = _pItens2 - IIF(_pItens2>xLinsRet and vtmp_impressao_nf_00.mostra_retirada,xLinsRet,0)
			pItens3  = _pItens3 - IIF(_pItens3>xLinsRet and vtmp_impressao_nf_00.mostra_retirada,xLinsRet,0)
 		*--} &&#39#
		
		xitenspfrm = pItens1
		Select vtmp_impressao_nf_00_itens
		Scan Whil filial+nf+serie_nf==xkey
			xcount = xcount+1
			If xcount > xitenspfrm Or frm_aux<>xTpAux
				xfrm   = xfrm + 1
				xcount = 1
				xTpAux = frm_aux
				*/xItensPFrm = IIF(tipo_emissao_nfe=5,pItens1,pItens2) && [Formulário de Segurança igual para todas as páginas]
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
		Group By 1,2,3,4,5,6,7 Into Cursor cur_lst_nfs_base && -- #30#

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
		**mantido aqui para carregar info DPEC, somente usado na linha DPEC

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
			**Nvl(Allt(Nvl(curtmp_prot.protocolo_autorizacao_nfe,''))+' '+Nvl(Ttoc(curtmp_prot.data_autorizacao_nfe),''),'')
			
			Select cur_frmnfe_obs
			Append Blank In cur_frmnfe_obs
			Replace nf With cur_lst_nfs.nf, serie_nf With cur_lst_nfs.serie_nf, filial With cur_lst_nfs.filial, n_form With xn_form,;
				seq_obs 				With xseqobs,;
				obs_form 				With xobs,;
				endereco_emitente_str	With xendemitentestr,;
				msg_protocolo     		With Nvl(vtmp_impressao_nf_00.msg_protocolo,''),;
				msg_registrodped  		With Nvl(Allt(Nvl(curtmp_prot.registro_dpec,''))+' '+Nvl(Ttoc(curtmp_prot.data_registro_dpec),''),''),;
				chave_nfe_str	  		With xchavestr,;
				dados_add_nfe	  		With f_dados_nfe_add(.F.),;
				dados_add_nfe_str 		With f_dados_nfe_add(.T.), ;
				chave_nfe_str_barra 	With bc_ocode128(Alltrim(Nvl(Allt(vtmp_impressao_nf_00.chave_nfe),'')),0,0,0),;
				dados_add_nfe_barra 	With bc_ocode128(Allt(vtmp_impressao_nf_00.chave_nfe),0,0,0) In cur_frmnfe_obs

			
			
			
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


	*-- Ajuste/Padronização dos Itens: Fixar iguais para todos os formulários (para preencher espaçamento) -- #30#
	Select nf,serie_nf,filial,status_nfe,tipo_emissao_nfe,n_form,seq_obs,frm_aux,Max(item_nfe) item_nfe,Min(n_qb_item) n_qb_item,Count(*) cnt_itens ;
		FROM vtmp_impressao_nf_00_itens Group By 1,2,3,4,5,6,7,8 Into Cursor cur_lst_nfs

	Select cur_lst_nfs
	Scan
		xitenspfrm = Iif(n_form=1,pitens1,Iif(frm_aux,pitens3,pitens2)) && -- #30#
		If cnt_itens < xitenspfrm
			For i = cnt_itens+1 To xitenspfrm
				Select vtmp_impressao_nf_00_itens
				Append Blank
				Replace nf With cur_lst_nfs.nf, serie_nf With cur_lst_nfs.serie_nf, filial With cur_lst_nfs.filial, item_nfe With cur_lst_nfs.item_nfe,;
					status_nfe With cur_lst_nfs.status_nfe, tipo_emissao_nfe With  cur_lst_nfs.tipo_emissao_nfe, ;
					n_form With cur_lst_nfs.n_form, n_qb_item With cur_lst_nfs.n_qb_item, ;
					seq_obs With cur_lst_nfs.seq_obs, frm_aux With cur_lst_nfs.frm_aux, item_add With 1 && -- #30#
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

	*!*		f_select('SELECT TOP 1 f.uf,SUBSTRING(m.COD_MUNICIPIO_IBGE,1,2) as cMun '+;
	*!*			'  FROM cadastro_cli_for f  (nolock) '+;
	*!*			' INNER JOIN LCF_LX_MUNICIPIO m  (nolock) ON DBO.FX_REPLACE_CARACTER_ESPECIAL_NFE(default,f.cidade) = m.DESC_MUNICIPIO '+;
	*!*			' INNER JOIN LCF_LX_UF u (nolock) ON u.uf = f.uf and u.ID_UF = m.ID_UF'+;
	*!*			' WHERE f.nome_clifor=?vTmp_impressao_nf_00.nome_clifor','Cur_Info_UF',Alias())
	**MessageBox(vtmp_impressao_nf_00.cmun_destinatario) 
	*- Alterado por Szalontai em 12/03/2012 para atender a TP 2349871
	*	xCBA_Str = RIGHT('00'+ALLTRIM(NVL(Cur_Info_UF.cMun,'99')),2)+;

	xcba_str = Right('00'+Alltrim(Iif(f_vazio(vtmp_impressao_nf_00.cmun_destinatario),'99',vtmp_impressao_nf_00.cmun_destinatario)),2)+;
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
		oxfrx = xfrx("XFRX#LISTENER")
				oXFRX.setEmbeddingType(3) &&#42#
		intstatusxfrx = oxfrx.setparams(reportexport.filename,,.T.,,,,reportexport.currentfileformat)
		Return (intstatusxfrx = 0) && Success
	Else
		oxfrx.finalize()
		Release oxfrx
		Return .T.
	Endif

ENDFUNC


*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*




	*----------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Function f_add_itens_frm_auxiliar() && Form auxiliar (RJ) #30#

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

		*-- 23/10/2011 - Padial/Beda: Controle da observacao do item
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
		*!*				If IsDigit(xCodItem)
		*!*					xLenMax = 16
		*!*				Else
		*!*					xLenMax = 11
		*!*				EndIf

		*			IF LEN(xCodItem)>xLenMax
		If xwidthitem > xwidthmax Then	&& Se o width do código do item for maior que o limite
			xcountqblin = 0

			Do Whil !Empty(xcoditem)
				xcountqblin = xcountqblin + 1
				xposquebra = f_quebra_texto_fonte(xcoditem, xwidthmax, 'Times New Roman',6,'N')	&& obtém próxima posição de quebra
				xcoditemqb = Left(xcoditem, xposquebra)
				*				 	xCodItemQb  = SUBSTR(xCodItem,1,xLenMax)

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
				*					xCodItem = SUBSTR(xCodItem,xLenMax+1,LEN(xCodItem))
			Enddo
		Endif
	Endscan
	*--

	
	*--
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
	*--

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

	*-- Vs-Lx   : 23/10/2011: Tratamento para Obs do Item
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
					If Empty(Substr(xlin_txt,u,1)) Or Substr(xlin_txt,u,1)=Chr(13) Or Inlist(Substr(xlin_txt,u,1),'/','\','-','.')  &&#2#
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



&&#43#
Function AtualizaCursorComXml(xCurSelecaoImpressao)
    	
	Dimension arrMapping[1, 2]
    Local lnArrayIndex
    lnArrayIndex = 1

    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "nf"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.ide.nNF"
    lnArrayIndex = lnArrayIndex + 1

    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "serie_nf"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.ide.serie"
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "serie_danfe"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.ide.serie"
    lnArrayIndex = lnArrayIndex + 1

	DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "chave_nfe"
    arrMapping[lnArrayIndex, 2] = "nfeProc.protNFe.infProt.chNFe"  
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "chave_nfe_str"
    arrMapping[lnArrayIndex, 2] = "nfeProc.protNFe.infProt.chNFe"  
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "origem_nf"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.ide.tpNF"
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "desc_nf_natureza"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.ide.natOp"
    lnArrayIndex = lnArrayIndex + 1 
    
	DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "tipo_emissao_nfe"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.ide.tpEmis"
    lnArrayIndex = lnArrayIndex + 1
	
	DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "emissao"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.ide.dhEmi"
    lnArrayIndex = lnArrayIndex + 1
	
	DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "data_saida"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.ide.dhSaiEnt"
    lnArrayIndex = lnArrayIndex + 1
      
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "hora_saida"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.ide.dhSaiEnt"
    lnArrayIndex = lnArrayIndex + 1
    
    &&info adicional
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "obs_interesse_fisco"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.infAdic.infAdFisco"
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "texto_legal"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.infAdic.obsCont"
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "obs"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.infAdic.infCpl"
    lnArrayIndex = lnArrayIndex + 1
	         
	&&emissor
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "cgc_cpf"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.dest.CPF | nfeProc.nfe.infNFe.dest.CNPJ"  
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "razao_social_emitente"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.emit.xNome"
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "cnpj_emitente"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.emit.CNPJ"  
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "cnpj_emitente"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.emit.CPF"  
    lnArrayIndex = lnArrayIndex + 1
          
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "endereco_emitente"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.emit.enderEmit.xLgr"
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "numero_emitente"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.emit.enderEmit.nro" 
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "complemento_emitente"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.emit.enderEmit.xCpl" 
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "bairro_emitente"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.emit.enderEmit.xBairro" 
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "cidade_emitente"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.emit.enderEmit.xMun" 
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "uf_emitente"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.emit.enderEmit.UF" 
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "pais_emitente"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.emit.enderEmit.xPais" 
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "cep_emitente"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.emit.enderEmit.CEP" 
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "ddd1_emitente"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.emit.enderEmit.fone" 
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "telefone1_emitente"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.emit.enderEmit.fone" 
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "ie_emitente"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.emit.IE" 
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "iest"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.emit.iest" 
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "pj_pf_emitente"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.emit.CNPJ" 
    lnArrayIndex = lnArrayIndex + 1
    &&fim emissor

    &&destinatario 
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "cgc_cpf"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.dest.CNPJ"  
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "cgc_cpf"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.dest.CPF"  
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "razao_social"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.dest.xNome"
    lnArrayIndex = lnArrayIndex + 1
          
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "endereco"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.dest.enderDest.xLgr"
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "numero"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.dest.enderDest.nro" 
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "complemento"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.dest.enderDest.xCpl" 
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "bairro"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.dest.enderDest.xBairro" 
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "cep"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.dest.enderDest.CEP" 
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "cidade"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.dest.enderDest.xMun" 
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "cmun_destinatario"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.dest.enderDest.cMun" 
    lnArrayIndex = lnArrayIndex + 1
    
   
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "ddd1"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.dest.enderDest.fone" 
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "telefone1"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.dest.enderDest.fone" 
    lnArrayIndex = lnArrayIndex + 1 
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "uf"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.dest.enderDest.UF" 
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "rg_ie"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.dest.IE" 
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "pj_pf"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.dest.CNPJ" 
    lnArrayIndex = lnArrayIndex + 1   
	&&fim destinatario  
	 
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "icms_base"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.total.ICMSTot.vBC"  
    lnArrayIndex = lnArrayIndex + 1
        
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "icms"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.total.ICMSTot.vICMS"  
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "icms_st_base"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.total.ICMSTot.vBCST"  
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "icms_st"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.total.ICMSTot.vST" 
    lnArrayIndex = lnArrayIndex + 1
          
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "icms_str_base"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.total.ICMSTot.vBCST"  
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "icms_str"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.total.ICMSTot.vST"  
    lnArrayIndex = lnArrayIndex + 1

    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "valor_sub_itens"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.total.ICMSTot.vProd"
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "encargo"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.total.ICMSTot.vOutro" &&confirmar com PO se este mesmo atributo, não existe encargo no schema
    lnArrayIndex = lnArrayIndex + 1
       
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "frete"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.total.ICMSTot.vFrete"
    lnArrayIndex = lnArrayIndex + 1

    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "seguro"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.total.ICMSTot.vSeg"
    lnArrayIndex = lnArrayIndex + 1

    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "desconto"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.total.ICMSTot.vDesc"
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "ipi"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.total.ICMSTot.vIPI"  
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "valor_total"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.total.ICMSTot.vNF"
    lnArrayIndex = lnArrayIndex + 1
     
    &&transporte
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "transportadora_razao_social"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.transp.transporta.xNome"
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "entrega_cif"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.transp.modfrete" 
    lnArrayIndex = lnArrayIndex + 1

    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "transportadora_pf_pj"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.transp.transporta.xNome"
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "transportadora_cnpj"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.transp.transporta.CNPJ"
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "transportadora_cnpj"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.transp.transporta.CPF"
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "transportadora_endereco"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.transp.transporta.xEnder"
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "transportadora_cidade"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.transp.transporta.xMun"
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "transportadora_uf"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.transp.transporta.UF"
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "transportadora_ie"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.transp.transporta.IE"
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "volumes"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.transp.vol.qVol"
    lnArrayIndex = lnArrayIndex + 1

    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "tipo_volume"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.transp.vol.esp"
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "marca_volumes"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.transp.vol.esp"
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "veiculo_placa"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.transp.veicTransp.placa" 
    lnArrayIndex = lnArrayIndex + 1
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "uf_placa"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.transp.veicTransp.uf" 
    lnArrayIndex = lnArrayIndex + 1 
    
    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "peso_liquido"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.transp.vol.pesoL"
    lnArrayIndex = lnArrayIndex + 1

    DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "peso_bruto"
    arrMapping[lnArrayIndex, 2] = "nfeProc.nfe.infNFe.transp.vol.pesoB"
    lnArrayIndex = lnArrayIndex + 1
  
  	DIMENSION arrMapping[lnArrayIndex, 2]
    arrMapping[lnArrayIndex, 1] = "msg_protocolo"
    arrMapping[lnArrayIndex, 2] = "nfeProc.protNFe.infProt.nProt"  
    lnArrayIndex = lnArrayIndex + 1
  
    **Itens
    Dimension arrMappingItem[1, 2]
    Local lnArrayIndexItem
    lnArrayIndexItem = 1
    
    DIMENSION arrMappingItem[lnArrayIndexItem, 2]
    arrMappingItem[lnArrayIndexItem, 1] = "codigo_item"
    arrMappingItem[lnArrayIndexItem, 2] = "prod.cprod"
    lnArrayIndexItem = lnArrayIndexItem + 1
    
    DIMENSION arrMappingItem[lnArrayIndexItem, 2]
    arrMappingItem[lnArrayIndexItem, 1] = "descricao_item"
    arrMappingItem[lnArrayIndexItem, 2] = "prod.xprod"
    lnArrayIndexItem = lnArrayIndexItem + 1
    
    DIMENSION arrMappingItem[lnArrayIndexItem, 2]
    arrMappingItem[lnArrayIndexItem, 1] = "classif_fiscal"
    arrMappingItem[lnArrayIndexItem, 2] = "prod.NCM"
    lnArrayIndexItem = lnArrayIndexItem + 1
    
    DIMENSION arrMappingItem[lnArrayIndexItem, 2]
    arrMappingItem[lnArrayIndexItem, 1] = "classif_fiscal"
    arrMappingItem[lnArrayIndexItem, 2] = "prod.NCM"
    lnArrayIndexItem = lnArrayIndexItem + 1
    
    DIMENSION arrMappingItem[lnArrayIndexItem, 2]
    arrMappingItem[lnArrayIndexItem, 1] = "qtde_item"
    arrMappingItem[lnArrayIndexItem, 2] = "prod.qtrib"
    lnArrayIndexItem = lnArrayIndexItem + 1
    
    DIMENSION arrMappingItem[lnArrayIndexItem, 2]
    arrMappingItem[lnArrayIndexItem, 1] = "codigo_fiscal_operacao"
    arrMappingItem[lnArrayIndexItem, 2] = "prod.cfop"
    lnArrayIndexItem = lnArrayIndexItem + 1
    
    DIMENSION arrMappingItem[lnArrayIndexItem, 2]
    arrMappingItem[lnArrayIndexItem, 1] = "preco_unitario"
    arrMappingItem[lnArrayIndexItem, 2] = "prod.vUnTrib"
    lnArrayIndexItem = lnArrayIndexItem + 1
     
    DIMENSION arrMappingItem[lnArrayIndexItem, 2]
    arrMappingItem[lnArrayIndexItem, 1] = "unidade"
    arrMappingItem[lnArrayIndexItem, 2] = "prod.uTrib"
    lnArrayIndexItem = lnArrayIndexItem + 1 
    
    DIMENSION arrMappingItem[lnArrayIndexItem, 2]
    arrMappingItem[lnArrayIndexItem, 1] = "valor_item"
    arrMappingItem[lnArrayIndexItem, 2] = "prod.vProd"
    lnArrayIndexItem = lnArrayIndexItem + 1
     
    &&impostos   
    DIMENSION arrMappingItem[lnArrayIndexItem, 2]
    arrMappingItem[lnArrayIndexItem, 1] = "tribut_origem"
    arrMappingItem[lnArrayIndexItem, 2] = "orig"
    lnArrayIndexItem = lnArrayIndexItem + 1
    
    DIMENSION arrMappingItem[lnArrayIndexItem, 2]
    arrMappingItem[lnArrayIndexItem, 1] = "tribut_icms"
    arrMappingItem[lnArrayIndexItem, 2] = "cst"
    lnArrayIndexItem = lnArrayIndexItem + 1   
    
    DIMENSION arrMappingItem[lnArrayIndexItem, 2]
    arrMappingItem[lnArrayIndexItem, 1] = "icms_base"
    arrMappingItem[lnArrayIndexItem, 2] = "vBC"
    lnArrayIndexItem = lnArrayIndexItem + 1 
    
    DIMENSION arrMappingItem[lnArrayIndexItem, 2]
    arrMappingItem[lnArrayIndexItem, 1] = "icms"
    arrMappingItem[lnArrayIndexItem, 2] = "vICMS"
    lnArrayIndexItem = lnArrayIndexItem + 1
    
    DIMENSION arrMappingItem[lnArrayIndexItem, 2]
    arrMappingItem[lnArrayIndexItem, 1] = "icms_aliquota"
    arrMappingItem[lnArrayIndexItem, 2] = "pICMS"
    lnArrayIndexItem = lnArrayIndexItem + 1
    
    **IPI
    DIMENSION arrMappingItem[lnArrayIndexItem, 2]
    arrMappingItem[lnArrayIndexItem, 1] = "ipi"
    arrMappingItem[lnArrayIndexItem, 2] = "vIPI"
    lnArrayIndexItem = lnArrayIndexItem + 1
           
    DIMENSION arrMappingItem[lnArrayIndexItem, 2]
    arrMappingItem[lnArrayIndexItem, 1] = "ipi_aliquota"
    arrMappingItem[lnArrayIndexItem, 2] = "pIPI"
    lnArrayIndexItem = lnArrayIndexItem + 1
    
    
    **ISSQN
    DIMENSION arrMappingItem[lnArrayIndexItem, 2]
    arrMappingItem[lnArrayIndexItem, 1] = "iss_base"
    arrMappingItem[lnArrayIndexItem, 2] = "ISSQN.vBC"
    lnArrayIndexItem = lnArrayIndexItem + 1
           
    DIMENSION arrMappingItem[lnArrayIndexItem, 2]
    arrMappingItem[lnArrayIndexItem, 1] = "iss"
    arrMappingItem[lnArrayIndexItem, 2] = "ISSQN.vISSQN"
    lnArrayIndexItem = lnArrayIndexItem + 1
    
    DIMENSION arrMappingItem[lnArrayIndexItem, 2]
    arrMappingItem[lnArrayIndexItem, 1] = "valor_sub_itens_bruto"
    arrMappingItem[lnArrayIndexItem, 2] = "ISSQN.vBC"
    lnArrayIndexItem = lnArrayIndexItem + 1
    licontadorNFs = 0
    
    Try
    	
    	Select chave_nfe from &xCurSelecaoImpressao into cursor curImprimir
		Select curImprimir
		
    	Scan
    		Append Blank in vtmp_impressao_nf_00
    		replace vtmp_impressao_nf_00.chave_nfe with curImprimir.chave_nfe in vtmp_impressao_nf_00
    	EndScan
    	
    	Select vtmp_impressao_nf_00 
    	Set filter to Len(Alltrim(chave_nfe)) == 44
	    Scan
	        lcConteudoXml = ""
			f_select("select a.xml_conteudo, b.filial from dados_cadastro_xml_nfe a join w_impressao_nfe b on a.chave_nfe=b.chave_nfe where b.Chave_NFe is Not Null AND ((b.Status_nfe in (5,6,9)) OR (b.Tipo_emissao_nfe=4 OR Tipo_emissao_nfe=5)) and a.chave_nfe = '" + Alltrim(vtmp_impressao_nf_00.chave_nfe)+"'",'CurTmp_DadosXml')
			If !f_vazio(CurTmp_DadosXml.xml_conteudo) 
				licontadorNFs = licontadorNFs + 1 
				StrToFile(CurTmp_DadosXml.xml_conteudo,wusertemppath + "impressao.xml")
				Replace filial with CurTmp_DadosXml.filial in vtmp_impressao_nf_00
				Replace status_nfe with 5 in vtmp_impressao_nf_00 && temporário
	        	xmlObj = nfXMLRead(wusertemppath + "impressao.xml")
		        
		        For i = 1 to Alen(arrMapping, 1)
		            lcCursorField = arrMapping[i, 1]
		            lcXmlAttribute = arrMapping[i, 2]
		            lcValue = xmlObj
		            If Type("xmlObj."+lcXmlAttribute) <> 'U'
		            	**lcValue = Evaluate("xmlObj."+lcXmlAttribute) #44#
		            	
		            	If Type("xmlObj."+lcXmlAttribute) <> 'O' &&#44#
					        lcValue = Evaluate("xmlObj."+lcXmlAttribute)
					    Else
							lcValue = ""
					    EndIf
		            	
		            	If lcXmlAttribute = "nfeProc.nfe.infNFe.ide.tpNF" and Alltrim(lcValue) = "1"
		            		lcValue = "S"	
		            	EndIf
		            	
		            	If lcCursorField = "msg_protocolo" and Type("xmlObj.nfeProc.protNFe.infProt.dhRecbto") <> "U"
		            		_dataHoraAutoriazacao = Evaluate("xmlObj.nfeProc.protNFe.infProt.dhRecbto")
		            		lcDate = SUBSTR(_dataHoraAutoriazacao, 9, 2) + "/" + SUBSTR(_dataHoraAutoriazacao, 6, 2) + "/" + SUBSTR(_dataHoraAutoriazacao, 1, 4)   
		            		lcTime = SUBSTR(_dataHoraAutoriazacao, 12, 8)
		            		_dataHoraAutoriazacao = lcDate + ' ' + lcTime 
		            		lcValue = lcValue + " - " + _dataHoraAutoriazacao
		            	EndIf

		            	If lcXmlAttribute = "nfeProc.nfe.infNFe.ide.nNF" 
		            		lcValue = Alltrim(lcValue)
		            	EndIf
		            	
		            	If (lcCursorField = "ddd1" or lcCursorField = "ddd1_emitente" )and Len(lcValue) > 2
		            		lcValue = Substr(Alltrim(lcValue),1,2)
		            	EndIf
		            	
		            	If (lcCursorField = "telefone1" or lcCursorField = "telefone1_emitente") and Len(lcValue) > 3
		            		lcValue = Substr(Alltrim(lcValue),3,Len(lcValue)-2)
		            	EndIf
		            	
		            	If lcCursorField = "pj_pf_emitente" and Type("xmlObj."+"nfeProc.nfe.infNFe.emit.CNPJ") <> 'U'
		            		lcValue = .t.
		            	EndIf
		            	
		            	If lcCursorField = "pj_pf_emitente" and Type("xmlObj."+"nfeProc.nfe.infNFe.emit.CPF") <> 'U'
		            		lcValue = .f.
		            	EndIf
		            	
		            	If lcCursorField = "pj_pf" and Type("xmlObj."+"nfeProc.nfe.infNFe.dest.CNPJ") <> 'U'
		            		lcValue = .t.
		            	EndIf
		            	
		            	If lcCursorField = "pj_pf" and Type("xmlObj."+"nfeProc.nfe.infNFe.dest.CPF") <> 'U'
		            		lcValue = .f.
		            	EndIf
		            	
		            	If lcCursorField = "transportadora_pf_pj" and Type("xmlObj."+"nfeProc.nfe.infNFe.transp.transporta.CNPJ") <> 'U'
		            		lcValue = .f.
		            	EndIf
		            	
		            	If lcCursorField = "transportadora_pf_pj" and Type("xmlObj."+"nfeProc.nfe.infNFe.transp.transporta.CPF") <> 'U'
		            		lcValue = .t.
		            	EndIf
		            	
		            	If lcXmlAttribute = "nfeProc.nfe.infNFe.ide.dhEmi" and Len(lcValue) >=10
		            		lcValue = SUBSTR(lcValue, 1, 10)
		            		lcValue = SUBSTR(lcValue, 9, 2) + "/" + SUBSTR(lcValue, 6, 2) + "/" + SUBSTR(lcValue, 1, 4)
		            	EndIf
		            	
		            	If lcXmlAttribute = "nfeProc.nfe.infNFe.ide.dhSaiEnt" and Len(lcValue) >=10 and lcCursorField = "data_saida"
		            		lcValue = SUBSTR(lcValue, 1, 10)
		            		lcValue = SUBSTR(lcValue, 9, 2) + "/" + SUBSTR(lcValue, 6, 2) + "/" + SUBSTR(lcValue, 1, 4)
		            	EndIf
		            	
		            	If lcXmlAttribute = "nfeProc.nfe.infNFe.ide.dhSaiEnt" and Len(lcValue) >=20 and lcCursorField = "hora_saida"
		            		lcValue = SUBSTR(lcValue, 12, 8)
		            	EndIf
		            	
		            	**converter para numérico
		            	If InList(lcCursorField, "icms_base","icms","icms_st_base","icms_st","icms_str_base","icms_str", "valor_sub_itens", "encargo","frete","seguro","desconto","ipi","valor_total","entrega_cif","volumes","peso_liquido","peso_bruto")
		            		lcValue = Val(lcValue)
		            	Endif
		            	
		            	If InList(lcCursorField, "entrega_cif")
			            	Entrega_cif = lcValue
			            	_desc_entrega_cif = ""
			            	Do case 
			            		Case Entrega_cif=1
			            			_desc_entrega_cif = "Emitente"
			            		Case Entrega_cif=0 
			            			_desc_entrega_cif = 'Destinatário'
			            		Case Entrega_cif=2 
			            			_desc_entrega_cif = 'Terceiros'
			            		Case Entrega_cif=9
			            			_desc_entrega_cif = 'Sem Frete'
			            		Case Entrega_cif=4 
			            			_desc_entrega_cif = 'Próprio Destinatário' 
			            		Case Entrega_cif=3 
			            			_desc_entrega_cif = 'Próprio Remetente'
			            		Otherwise
			            			_desc_entrega_cif = ''
			            	Endcase
		            		Replace desc_entrega_cif with _desc_entrega_cif in vtmp_impressao_nf_00
		            	Endif  
		            	xAtributo = "vtmp_impressao_nf_00."+lcCursorField
		            	tipo1 = Type(xAtributo)
		            	tipo2 = Type("lcValue")
		            	If tipo1 != tipo2
		            		If tipo1 == "C" and tipo2 == "N"
		            			lcValue = Str(lcValue)
		            		EndIf
		            		If tipo1 == "N" and tipo2 == "C"
		            			lcValue = Val(lcValue)
		            		EndIf
		            	EndIf
		            	Replace &lcCursorField with lcValue in vtmp_impressao_nf_00
		            EndIf    
		        EndFor
		   
		    
		    
			    If Type('xmlObj.nfeProc.nfe.infNFe.det') <> 'U' 
			    	
			    	If Type('xmlObj.nfeProc.nfe.infNFe.det.prod') <> 'U'
			    		Dimension laItens[1]        
			    		laItens[1] = xmlObj.nfeProc.nfe.infNFe.det
			    	Else
			    		lnCount = Alen(xmlObj.nfeProc.nfe.infNFe.det)        
			    		Dimension laItens[lnCount]
			    		For t = 1 to lnCount            
			    			laItens[t] = xmlObj.nfeProc.nfe.infNFe.det[t]        
			    		Next
			    	EndIf
			    	
			    	lcContadorItem = 0
					For each objItems in laItens 
						lcContadorItem = lcContadorItem + 1
						Select vtmp_impressao_nf_00_itens
						Append blank in vtmp_impressao_nf_00_itens
						Select vtmp_impressao_nf_00_itens
						Replace filial with vtmp_impressao_nf_00.filial in vtmp_impressao_nf_00_itens
						Replace nf with vtmp_impressao_nf_00.nf in vtmp_impressao_nf_00_itens
						Replace serie_nf with vtmp_impressao_nf_00.serie_nf in vtmp_impressao_nf_00_itens
						Replace item_impressao with Right(Replicate("0", 4) + Transform(lcContadorItem), 4) in vtmp_impressao_nf_00_itens
						Replace item_nfe with lcContadorItem in vtmp_impressao_nf_00_itens
						Replace n_qb_item with 1 in vtmp_impressao_nf_00_itens
						Replace item_add with 0 in vtmp_impressao_nf_00_itens
						Replace status_nfe with Nvl(vTmp_impressao_nf_00.status_nfe,0) in vtmp_impressao_nf_00_itens
						Replace tipo_emissao_nfe with Val(Nvl(vTmp_impressao_nf_00.tipo_emissao_nfe,0)) in vtmp_impressao_nf_00_itens
						Replace n_form with 0 in vtmp_impressao_nf_00_itens	
						Replace t_form with 0 in vtmp_impressao_nf_00_itens	
						Replace ult_n_qb_item with .f. in vtmp_impressao_nf_00_itens
						Replace seq_obs with 1 in vtmp_impressao_nf_00_itens 
						Replace frm_aux with .F. in vtmp_impressao_nf_00_itens 		
						
						For i = 1 to Alen(arrMappingItem, 1)
				            lcCursorField = arrMappingItem[i, 1]
				            lcXmlAttribute = arrMappingItem[i, 2]
				            If Type("objItems"+ "."+ lcXmlAttribute) <> 'U'
				            	lcValue = Evaluate("objItems"+"."+lcXmlAttribute)
				            	**converter para numérico
				            	If InList(lcCursorField, "qtde_item","preco_unitario","valor_item")
				            		lcValue = Val(lcValue)
				            	Endif
								Replace &lcCursorField with lcValue in vtmp_impressao_nf_00_itens
							EndIf
							
							If InList(lcCursorField,"tribut_origem","tribut_icms","icms_base","icms","icms_aliquota")
								Dimension aProperties[1]
								Amembers(aProperties, objitems.imposto.icms, 1)
								For x = 1 To ALen(aProperties, 1)
								    cProperty = aProperties[x]
								    If Type("objitems.imposto.icms." + cProperty + "."+lcXmlAttribute) <> 'U' 
								     	lcValue = Evaluate("objitems.imposto.icms." + cProperty + "."+lcXmlAttribute)
								     	If InList(lcCursorField, "icms_base","icms","icms_aliquota")
						            		lcValue = Val(lcValue)
						            	Endif
										Replace &lcCursorField with lcValue in vtmp_impressao_nf_00_itens
								   	EndIf
								EndFor
							EndIf
							
							If lcCursorField == "ipi"
								If Type("objitems.imposto.ipi." +lcXmlAttribute) <> 'U' 
							     	lcValue = Evaluate("objitems.imposto.ipi." +lcXmlAttribute)
							     	If InList(lcCursorField, "ipi")
					            		lcValue = Val(lcValue)
					            	Endif
									Replace &lcCursorField with lcValue in vtmp_impressao_nf_00_itens
							   	EndIf
							EndIf
							
							If InList(lcCursorField,"ipi_aliquota") and Type("objitems.imposto.ipi") <> 'U'
								Dimension aProperties[1]
								Amembers(aProperties, objitems.imposto.ipi, 1)
								For y = 1 To ALen(aProperties, 1)
								    cProperty = aProperties[y]
								    If Type("objitems.imposto.ipi." + cProperty + "."+lcXmlAttribute) <> 'U' 
								     	lcValue = Evaluate("objitems.imposto.ipi." + cProperty + "."+lcXmlAttribute)
								     	If InList(lcCursorField, "ipi_aliquota")
						            		lcValue = Val(lcValue)
						            	Endif
										Replace &lcCursorField with lcValue in vtmp_impressao_nf_00_itens
								   	EndIf
								EndFor
							EndIf
														
						EndFor
										
			   		EndFor
			   	EndIf
			   	
			   		
		   		Local xfields As Character, k As Character, k_ As Character
				Store '' To xfields
				For k = 1 To 48
					k_ = Alltrim(Str(k))
					xfields = xfields + Iif(Empty(xfields),'',',') + 'space(15) as Dup_Parc'+k_ + ', 000000000.00 as val_parc'+k_ + ', {} as venc_parc'+k_
				Endfor

				xfields = [nf,serie_nf,filial,chave_nfe,] + xfields 
				Select Distinct &xfields From vtmp_impressao_nf_00 Into Cursor cur_ctb_parcelas Readwrite
			   	
			   	
			   	If Type('xmlObj.nfeProc.nfe.infNFe.cobr.dup') <> 'U' 
					_xi = 0
					
					If Type('xmlObj.nfeProc.nfe.infNFe.cobr.dup.nDup') <> 'U'
			    		Dimension laCobranca[1]        
			    		laCobranca[1] = xmlObj.nfeProc.nfe.infNFe.cobr.dup
			    	Else
			    		lnCount = Alen(xmlObj.nfeProc.nfe.infNFe.cobr.dup)        
			    		Dimension laCobranca[lnCount]
			    		For t = 1 to lnCount            
			    			laCobranca[t] = xmlObj.nfeProc.nfe.infNFe.cobr.dup[t]        
			    		Next
			    	EndIf
					
		   			For each objCobranca in laCobranca
			   			_xi = _xi + 1
			   			xi		= Alltrim(Str(_xi))
			   			lcDtVenc = SUBSTR(objCobranca.dVenc, 1, 10)
			            lcDtVenc = SUBSTR(lcDtVenc, 9, 2) + "/" + SUBSTR(lcDtVenc, 6, 2) + "/" + SUBSTR(lcDtVenc, 1, 4)
			   			Sele cur_ctb_parcelas
			   			Replace dup_parc&xi  With Nvl(Alltrim(objCobranca.nDup),'') in cur_ctb_parcelas
						Replace val_parc&xi  With Val(Nvl(objCobranca.vDup,0)) in cur_ctb_parcelas
						Replace venc_parc&xi With Ctod(Nvl(lcDtVenc,{})) in cur_ctb_parcelas
						Replace filial with vtmp_impressao_nf_00.filial in cur_ctb_parcelas
						Replace nf with vtmp_impressao_nf_00.nf in cur_ctb_parcelas
						Replace serie_nf with vtmp_impressao_nf_00.serie_nf in cur_ctb_parcelas
			   		EndFor	
	   				
			   	EndIf
		     EndIf
	    EndScan
	        
    Catch to objError
    	Msg = "Ocorreu um erro ao processar o XML:" +  objError.Message
    	If Type('objError.linecontents') <> 'U'
    		Msg = Msg + " - " + objError.linecontents
    	EndIf
    	licontadorNFs = 0
        MessageBox(Msg) 
    EndTry
    
    If licontadorNFs == 0
    	Messagebox('XML da NF ' + Alltrim(chave_nfe) + ' não encontrado. ',48,'Aviso')
    	Return .f.
    Else
    	Return .t.
    EndIf

EndFunc

&&#43#