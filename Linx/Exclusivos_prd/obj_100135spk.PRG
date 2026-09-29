** obj_100135spk - monitor nfe
*	USR_INIT
*	USR_ALTER_BEFORE  ->Return .f. Para o Metodo
*	USR_ALTER_AFTER
*	USR_INCLUDE_AFTER
*	USR_SEARCH_BEFORE ->Return .f. Para o Metodo
*	USR_SEARCH_AFTER
*	USR_CLEAN_AFTER
*	USR_REFRESH
*	USR_SAVE_BEFORE   ->Return .f. Para o Metodo
*	USR_SAVE_AFTER
*	USR_ITEN_DELETE_BEFORE ->Return .f. Para o Metodo
*	USR_ITEN_DELETE_AFTER
*	USR_ITEN_INCLUDE_BEFORE ->Return .f. Para o Metodo
*	USR_ITEN_INCLUDE_AFTER
*   USR_LOSTFOCUS
*	USR_CLICK
define class obj_entrada as custom
	*- Nome do metodo/função que os objetos linx vão chamar.
	procedure metodo_usuario

		lparam xmetodo, xobjeto ,xnome_obj

		do case
			case UPPER(xmetodo) == 'USR_INIT'

				*!*			   		PUBLIC xobj100135
				*!*			   		xobj100135 = thisformset.lx_FORM1
				*!*
				*!*					thisformset.lx_FORM1.addobject('bt_rel_nfe1', 'bt_rel_nfe')
				*!*					WITH thisformset.lx_form1.bt_rel_nfe1
				*!*						.visible = .t.
				*!*					ENDWITH
				thisformset.lx_FORM1.lockScreen=.T.
				ADDPROPERTY(thisformset,"z_selecionada",.F.)

				thisformset.lx_FORM1.width = 1452
				WITH thisformset.LX_FORM1
					.LX_TITLEBAR.img_maximize.Click
					.refresh

					WAIT WINDOW "objeto" TIMEOUT 2

					.ADDOBJECT("command1","command1")
					.command1.visible = .t.

					.ADDOBJECT("command2","command2")
					.command2.visible = .t.

					.ADDOBJECT("check1","check1")
					.check1.visible =.t.

					.ADDOBJECT("btnCorrigeUTC","btnCorrigeUTC")
					.btnCorrigeUTC.visible = .T.

					.lx_pageframe.page1.lx_grid_status_documento.anchor = 0

					.LX_TITLEBAR.img_maximize.Click
				ENDWITH

				thisformset.lx_FORM1.lockScreen=.F.
				WAIT WINDOW "Ok!" TIMEOUT 2
				thisformset.LX_FORM1.refresh


			case UPPER(xmetodo) == 'USR_ALTER_BEFORE'


			otherwise
				return .t.
		endcase
	endproc
enddefine


** (inicio) --> PAULO DEVIDE - 30-SET-14
DEFINE CLASS bt_rel_nfe as botao
	caption = 'Imprime Relatórios'
	*autosize = .T.
	WORDWRAP = .t.
	WIDTH = 132
	top = 20
	left = 898
	HEIGHT =  18
	enabled = .t.
	visible  = .t.
	backcolor =  RGB(64,128,128)
	Style=0
	ToolTipText = "Impressão de relatórios de faturamento"
	SpecialEffect=0
	Autosize=.t.
	name="bt_rel_nfe1"

	PROCEDURE click

		LOCAL lcObs, lnArea
		lnArea = SELECT()

		PUBLIC frmRelat
		frmRelat = CreateObject ("Tform")
		frmRelat.show(1)

		SELECT (lnArea)


	ENDPROC

	*!*		PROCEDURE refresh
	*!*			** Inclusão/Alteração/Exclusão/Tela (L)impa/(P)esquisa Feita!
	*!*			this.enabled = !INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L")
	*!*		ENDPROC

ENDDEFINE
** (fim) PAULO DEVIDE - 30-SET-14



DEFINE CLASS Tform As Form

	Width = 300
	Height = 110
	AutoCenter = .T.
	Windowtype = 1
	AlwaysOnTop = .t.
	Caption = "Imprimir relatórios de Faturamento"



	ADD OBJECT cmd1 As CommandButton WITH;
		Width=60, Height=25, Left=164, Top=70, ;
		Caption="Cancel"

	ADD OBJECT cmd2 As CommandButton WITH;
		Width=60, Height=25, Left=234, Top=70, ;
		Caption="Ok", Default=.T.


	PROCEDURE cmd1.Click
		ThisForm.Release
	ENDPROC

	PROCEDURE cmd2.Click
		Tform_imprime()
		ThisForm.Release
	ENDPROC

ENDDEFINE

FUNCTION Tform_imprime()
	IF MESSAGEBOX("Confirma impressão dos relatórios",292,"Aviso")=6

		*!*			lcReport1 = ADDBS(WDIR_EXE)+"Report\User\U100135FR1 CÓPIA DE (B) CD CAEDU - CONFERÊNCIA DE PEÇAS.FRX"
		*!*			REPORT FORM (lcReport1) TO PRINTER PROMPT noconsole

		*!*			lcReport2 = ADDBS(WDIR_EXE)+"Report\User\U100135GD1 CÓPIA DE (B) CD CAEDU - RELAÇÃO DE CAIXAS.FRX"
		*!*			REPORT FORM (lcReport2) TO PRINTER PROMPT noconsole

		lcReport3 = ADDBS(WDIR_EXE)+"report\linx\l100135f.prg"
		IF NOT ("l100135f" $ SET("procedure"))
			SET PROCEDURE TO &lcReport3. additive
		ENDIF
		llReport = Func_Relatorio("IMP",xobj100135)

	ENDIF
	RETURN

ENDFUNC


DEFINE CLASS command1 as CommandButton
	caption = "Corrige NF"
	Height = 61
	Left = 1289
	Top = 126
	Width = 72

	PROCEDURE click
		*SET STEP ON
		IF  .NOT. F_SELECT("SELECT * from faturamento where  filial = ?V_status_documento_nfe_00.filial and nf_saida = ?V_status_documento_nfe_00.NF and serie_nf = ?V_status_documento_nfe_00.SERIE_NF  "+;
				"and filial = ?V_status_documento_nfe_00.FILIAL and status_nfe = 2 ", "VERIF_CAE")
			MESSAGEBOX("Erro, contacte a TI- ERP")
			RETURN .F.
		else
			IF RECCOUNT('VERIF_CAE') > 0
				SELECT VERIF_CAE
				IF ISNULL(UTC_DATA_SAIDA) AND ISNULL(UTC_EMISSAO) AND ISNULL(DATA_HORA_EMISSAO)
					*MESSAGEBOX('campos nulos')

					IF  .NOT. f_execute("update faturamento SET UTC_DATA_SAIDA = 3, UTC_EMISSAO = 3 ,DATA_HORA_EMISSAO = DATA_PARA_TRANSFERENCIA, status_nfe = 0 "+;
							" where filial = ?VERIF_CAE.filial and nf_saida = ?VERIF_CAE.nf_saida and serie_nf = ?VERIF_CAE.serie_nf " )
						MESSAGEBOX("Erro, contacte a TI- ERP")
						RETURN .F.
					ELSE
						IF  .NOT. f_execute("EXEC lx_gera_nfe_sefaz_4_00 '" + VERIF_CAE.nf_saida +"', '"+ VERIF_CAE.serie_nf +"','"+ VERIF_CAE.filial +"',"+"1 " )
							MESSAGEBOX("Erro, contacte a TI- ERP")
							RETURN .F.
						ELSE
							MESSAGEBOX("NOTA ATUALIZADA :"+ VERIF_CAE.nf_saida + " - serie :" + VERIF_CAE.serie_nf )
						ENDIF

					ENDIF




				endif
			ENDIF
		endif
	ENDPROC
ENDDEFINE

DEFINE CLASS check1 as CheckBox
	Alignment = 0
	Caption = "Apenas Nf Selecionada"
	ControlSource = "thisformset.z_selecionada"
	Height = 36
	left = 1301
	Name = "Check1"
	Top = 330
	Width = 96
	WordWrap = .T.

ENDDEFINE

DEFINE CLASS Command2 as CommandButton
	Caption = "Envia e-mail Transportadora"
	Height = 108
	Left = 1289
	Name = "Command2"
	Top = 210
	Width = 120
	WordWrap =.T.

	PROCEDURE click

		local clSelectRetorno as String, clArquivo_XML as String, sProcedureXml as String

		*	SET STEP ON
		xconts = 0

		SELECT MAX(emissao) as maior, MIN(emissao) as menor FROM v_status_documento_nfe_00 INTO CURSOR verif_data
		IF (verif_data.maior - verif_data.menor) > 1  AND thisformset.lx_FORM1.check1.Value = .f.
			MESSAGEBOX('Numero de emails supera mais de um dia de notas emitidas ')
			return
		endif

		IF thisform.check1.Value = .T.


			SELECT V_STATUS_DOCUMENTO_NFE_00

			xnf = ALLTRIM(V_STATUS_DOCUMENTO_NFE_00.nf)
			xserie = ALLTRIM(V_STATUS_DOCUMENTO_NFE_00.serie_nf)
			xfilial = ALLTRIM(V_STATUS_DOCUMENTO_NFE_00.filial)


			if !f_vazio(v_status_documento_nfe_00.chave_nfe) AND v_status_documento_nfe_00.status_nfe = 5 AND !f_vazio(v_status_documento_nfe_00.protocolo_autorizacao_nfe)

				xconts  = xconts  +1
				WAIT WINDOW "fazendo nota : "+STR(	xconts ) nowait


				F_select(" select b.regiao_atuacao, a.*  from faturamento a left join transportadoras  b  on a.transportadora = b.transportadora "+;
					"  where a.nf_saida = ?xnf  and a.serie_nf = ?xserie and a.filial = ?xfilial  ", 'XNFEcae')

				** SUBSTITUIU A VARIAVEL EMAIL POR REGIAO_ATUACAO
				** PAULO DEVIDE - 09-12-15
				**xemail2 = LOWER(ALLTRIM(XNFEcae.email))+';'+'luciano.reis@grupopalma.com.br;paulo.devide@grupopalma.com.br'
				xemail2 = LOWER(ALLTRIM(XNFEcae.REGIAO_ATUACAO))+';'+'luciano.reis@grupopalma.com.br;paulo.devide@grupopalma.com.br'

				*!*					xemail2 = 'luciano.reis@grupopalma.com.br;paulo.devide@grupopalma.com.br' && apagar esta linha 01/06/16

				xemail = DTOS(DATE())

				xnome = 'NF_'+xnf+"="+xemail+".XML"

				if alltrim(WLAYOUT_XML_NFE) = [IT] && verifica o layout e a versao do layout para a versao 2.0

					if inlist(v_status_documento_nfe_00.status_nfe,4,5)
						*-- Codigo para verificar se a nota ja teve retorno da Sefaz na fila do Linx
						clSelectRetorno = 	"select top 1 id_msg, status_fila, data_recebimento, convert(xml,mensagem) as xml_retorno from fila_msg (nolock)"+;
							"where mensagem like '%chNFe>"+alltrim(v_status_documento_nfe_00.chave_nfe)+"</%' "+;
							"order by id_msg desc"

						IF !f_select(clSelectRetorno,"curRecebSefaz")
							f_msg("'Não foi possível verificar se houve retorno no Linx da Sefaz.',64,'Aviso!'")
							return .f.
						ENDIF

						select curRecebSefaz
						if reccount("curRecebSefaz") = 0
							use in curRecebSefaz
							return .f.
						else
						endif


						select curRecebSefaz
						replace curRecebSefaz.xml_retorno with strconv(curRecebSefaz.xml_retorno,9)

						Copy Memo curRecebSefaz.xml_retorno to wusertemppath+xnome  sdf

						clArquivo_XML = '\\192.168.0.55\conciliacao\xmls\'+"&xnome"

						*!*						clArquivo_XML = 'c:\conciliacao\xmls\'+"&xnome" && apagar essa linha 01/06/2016


						use in curRecebSefaz
					else
						if alltrim(wVersao_Layout_Xml_NFe) = [1.10]
							sProcedureXml = [LX_GERA_NFE_IT]
						else
							sProcedureXml = [LX_GERA_NFE_IT_]+alltrim(strtran(wVersao_Layout_Xml_NFe,'.','_'))
						endif

						clProceXML = [ exec ]+sProcedureXml+[ ']+ALLTRIM(v_status_documento_nfe_00.nf)+[',']+Alltrim(v_status_documento_nfe_00.serie_nf)+[',']+Alltrim(v_status_documento_nfe_00.filial)+[' ]

						If !f_select(clProceXML,'curXML')
							messagebox.ShowProgressBar('Transmitindo Documento '+Alltrim(cldocumento)+'...',0)
							IF !blAutomatico
								f_msg(['Erro na geração do XML'])
							ENDIF
							Return
						Endif

						select curXML

						Copy Memo curXML.XML_NFE to '\\192.168.0.55\conciliacao\xmls\'+"&xnome" &&sdf
						clArquivo_XML = '\\192.168.0.55\conciliacao\xmls\'+"&xnome"

						*!*						clArquivo_XML = 'c:\conciliacao\xmls\'+"&xnome" && apagar essa linha 01/06/2016

						IF USED("curXML")
							use in curXML
						ENDIF
						IF USED("curXML1")
							use in curXML1
						ENDIF

					endif

				else

					if alltrim(wVersao_Layout_Xml_NFe) = [1.10]
						sProcedureXml = [LX_GERA_NFE_SEFAZ]
					else
						sProcedureXml = [LX_GERA_NFE_SEFAZ_]+alltrim(strtran(wVersao_Layout_Xml_NFe,'.','_'))
					endif

					clProceXML = [ exec ]+sProcedureXml+[ ']+ALLTRIM(v_status_documento_nfe_00.nf)+[',']+Alltrim(v_status_documento_nfe_00.serie_nf)+[',']+Alltrim(v_status_documento_nfe_00.filial)+[' ]

					If !f_select(clProceXML,'curXML')
						messagebox.ShowProgressBar('Transmitindo Documento '+Alltrim(cldocumento)+'...',0)
						IF !blAutomatico
							f_msg(['Erro na geração do XML'])
						ENDIF
						Return
					Endif

					select curXML


					if ("<?xml version" $ curXML.XML_NFE)
						replace curXML.XML_NFE with strtran(curXML.XML_NFE,'"utf-8"','"ISO-8859-1"')
						replace curXML.XML_NFE with strtran(curXML.XML_NFE,'"UTF-8"','"ISO-8859-1"')
					else
						replace curXML.XML_NFE with '<?xml version="1.0" encoding="ISO-8859-1"?>'+alltrim(curXML.XML_NFE)
					endif

					copy Memo curXML.XML_NFE to '\\192.168.0.55\conciliacao\xmls\'+"&xnome" sdf
					clArquivo_XML = '\\192.168.0.55\conciliacao\xmls\'+"&xnome"

					** apagar essas 2 linhas abaixo e descomentar as 2 de cima - 01/06/2016
					*!*					copy Memo curXML.XML_NFE to 'c:\conciliacao\xmls\'+"&xnome" sdf
					*!*					clArquivo_XML = 'c:\conciliacao\xmls\'+"&xnome"



					lc_to = xemail2
					lc_arq = 'C:\conciliacao\xmls\'+"&xnome"

					TEXT TO lcSQL NOSHOW TEXTMERGE
			execute SP_CAEDU_ENVIA_EMAIL_NFE @EMAIL= '<<lc_to>>', @DIRECTORY= '<<lc_arq>>'
					ENDTEXT


					xx = f_execute(lcSQL)

					IF USED("curXML")
						use in curXML
					ENDIF
					IF USED("curXML1")
						use in curXML1
					ENDIF

				endif

			endif

			SELECT V_STATUS_DOCUMENTO_NFE_00


		ELSE


			SELECT V_STATUS_DOCUMENTO_NFE_00
			SCAN

				xnf = ALLTRIM(V_STATUS_DOCUMENTO_NFE_00.nf)
				xserie = ALLTRIM(V_STATUS_DOCUMENTO_NFE_00.serie_nf)
				xfilial = ALLTRIM(V_STATUS_DOCUMENTO_NFE_00.filial)


				if !f_vazio(v_status_documento_nfe_00.chave_nfe) AND v_status_documento_nfe_00.status_nfe = 5 AND !f_vazio(v_status_documento_nfe_00.protocolo_autorizacao_nfe)



					xconts  = xconts  +1
					WAIT WINDOW "fazendo nota : "+STR(	xconts ) nowait


					F_select(" select b.regiao_atuacao, a.*  from faturamento a left join transportadoras  b  on a.transportadora = b.transportadora "+;
						"  where a.nf_saida = ?xnf  and a.serie_nf = ?xserie and a.filial = ?xfilial  ", 'XNFEcae')

					** SUBSTITUIU A VARIAVEL EMAIL POR REGIAO_ATUACAO
					** PAULO DEVIDE - 09-12-15

					*xemail2 = LOWER(ALLTRIM(XNFEcae.email))
					**xemail2 = LOWER(ALLTRIM(XNFEcae.email))+';'+'luciano.reis@grupopalma.com.br;paulo.devide@grupopalma.com.br'
					xemail2 = LOWER(ALLTRIM(XNFEcae.REGIAO_ATUACAO))+';'+'luciano.reis@grupopalma.com.br;paulo.devide@grupopalma.com.br'
					*xemail2 = 'luciano.reis@grupopalma.com.br;paulo.devide@grupopalma.com.br'


					xemail = DTOS(DATE())

					xnome = 'NF_'+xnf+"="+xemail+".XML"

					if alltrim(WLAYOUT_XML_NFE) = [IT] && verifica o layout e a versao do layout para a versao 2.0

						if inlist(v_status_documento_nfe_00.status_nfe,4,5)
							*-- Codigo para verificar se a nota ja teve retorno da Sefaz na fila do Linx
							clSelectRetorno = 	"select top 1 id_msg, status_fila, data_recebimento, convert(xml,mensagem) as xml_retorno from fila_msg (nolock)"+;
								"where mensagem like '%chNFe>"+alltrim(v_status_documento_nfe_00.chave_nfe)+"</%' "+;
								"order by id_msg desc"

							IF !f_select(clSelectRetorno,"curRecebSefaz")
								f_msg("'Não foi possível verificar se houve retorno no Linx da Sefaz.',64,'Aviso!'")
								return .f.
							ENDIF

							select curRecebSefaz
							if reccount("curRecebSefaz") = 0
								use in curRecebSefaz
								return .f.
							else
							endif


							select curRecebSefaz
							replace curRecebSefaz.xml_retorno with strconv(curRecebSefaz.xml_retorno,9)

							Copy Memo curRecebSefaz.xml_retorno to wusertemppath+xnome  sdf

							*clArquivo_XML = wusertemppath+"&xnome"
							clArquivo_XML = '\\192.168.0.55\conciliacao\xmls\'+"&xnome"

							*!*						clArquivo_XML = 'c:\conciliacao\xmls\'+"&xnome" && apagar essa linha - 01/06/16

							use in curRecebSefaz
						else
							if alltrim(wVersao_Layout_Xml_NFe) = [1.10]
								sProcedureXml = [LX_GERA_NFE_IT]
							else
								sProcedureXml = [LX_GERA_NFE_IT_]+alltrim(strtran(wVersao_Layout_Xml_NFe,'.','_'))
							endif

							clProceXML = [ exec ]+sProcedureXml+[ ']+ALLTRIM(v_status_documento_nfe_00.nf)+[',']+Alltrim(v_status_documento_nfe_00.serie_nf)+[',']+Alltrim(v_status_documento_nfe_00.filial)+[' ]

							If !f_select(clProceXML,'curXML')
								messagebox.ShowProgressBar('Transmitindo Documento '+Alltrim(cldocumento)+'...',0)
								IF !blAutomatico
									f_msg(['Erro na geração do XML'])
								ENDIF
								Return
							Endif

							select curXML

							*Copy Memo curXML.XML_NFE to wusertemppath+"&xnome" &&sdf
							Copy Memo curXML.XML_NFE to '\\192.168.0.55\conciliacao\xmls\'+"&xnome" &&sdf
							*clArquivo_XML = wusertemppath+xnome
							clArquivo_XML = '\\192.168.0.55\conciliacao\xmls\'+"&xnome"

							*!*						clArquivo_XML = 'c:\conciliacao\xmls\'+"&xnome" && apagar essa linha - 01/06/16

							IF USED("curXML")
								use in curXML
							ENDIF
							IF USED("curXML1")
								use in curXML1
							ENDIF

						endif

					else

						if alltrim(wVersao_Layout_Xml_NFe) = [1.10]
							sProcedureXml = [LX_GERA_NFE_SEFAZ]
						else
							sProcedureXml = [LX_GERA_NFE_SEFAZ_]+alltrim(strtran(wVersao_Layout_Xml_NFe,'.','_'))
						endif

						clProceXML = [ exec ]+sProcedureXml+[ ']+ALLTRIM(v_status_documento_nfe_00.nf)+[',']+Alltrim(v_status_documento_nfe_00.serie_nf)+[',']+Alltrim(v_status_documento_nfe_00.filial)+[' ]

						If !f_select(clProceXML,'curXML')
							messagebox.ShowProgressBar('Transmitindo Documento '+Alltrim(cldocumento)+'...',0)
							IF !blAutomatico
								f_msg(['Erro na geração do XML'])
							ENDIF
							Return
						Endif

						select curXML


						if ("<?xml version" $ curXML.XML_NFE)
							replace curXML.XML_NFE with strtran(curXML.XML_NFE,'"utf-8"','"ISO-8859-1"')
							replace curXML.XML_NFE with strtran(curXML.XML_NFE,'"UTF-8"','"ISO-8859-1"')
						else
							replace curXML.XML_NFE with '<?xml version="1.0" encoding="ISO-8859-1"?>'+alltrim(curXML.XML_NFE)
						endif

						*copy Memo curXML.XML_NFE to wusertemppath+"&xnome" sdf
						copy Memo curXML.XML_NFE to '\\192.168.0.55\conciliacao\xmls\'+"&xnome" sdf
						*clArquivo_XML = wusertemppath+xnome
						clArquivo_XML = '\\192.168.0.55\conciliacao\xmls\'+"&xnome"

						** apagar essas 2 linhas abaixo e descomentar as linhas acima - 01/06/16
						*!*					copy Memo curXML.XML_NFE to 'c:\conciliacao\xmls\'+"&xnome" sdf
						*!*					clArquivo_XML = 'c:\conciliacao\xmls\'+"&xnome"




						*!*	email = CREATEOBJECT("Jmail.message")
						*!*	email.from = 'luciano.reis@grupopalma.com.br'
						*!*	email.fromname = 'LOGISTICA CAEDU'
						*!*	email.body = 'Informe de emissão de NFE '
						*!*	email.subject = 'Informe de emissão de NFE'
						*!*	cdestino = 'luciano.reis@grupopalma.com.br'
						*!*	email.addrecipient( cdestino)
						*!*	email.addattachment(clArquivo_XML)
						*!*	email.send("192.168.0.25")


						lc_to = xemail2
						lc_arq = 'C:\conciliacao\xmls\'+"&xnome"

						TEXT TO lcSQL NOSHOW TEXTMERGE
						execute SP_CAEDU_ENVIA_EMAIL_NFE @EMAIL= '<<lc_to>>', @DIRECTORY= '<<lc_arq>>'
						ENDTEXT


						xx = f_execute(lcSQL)


						DELETE FILE 'C:\conciliacao\xmls\'+"&xnome"




						IF USED("curXML")
							use in curXML
						ENDIF
						IF USED("curXML1")
							use in curXML1
						ENDIF

					endif

				endif

				SELECT V_STATUS_DOCUMENTO_NFE_00
			ENDSCAN
		ENDIF

		MESSAGEBOX("FIM")

		*this.Parent.Refresh

	ENDPROC

ENDDEFINE

DEFINE CLASS btnCorrigeUTC as CommandButton
	caption = "Corrige NF Rejeitada por Horario de Verão - CD BARRA VELHA"
	Height = 91
	Left = 1289
	Top = 376
	Width = 132
	WordWrap = .T.

	PROCEDURE click
		*SET STEP ON
		TEXT TO lcSQL1 NOSHOW TEXTMERGE PRETEXT 7
			SELECT * from faturamento
			where  filial = ?V_status_documento_nfe_00.filial and nf_saida = ?V_status_documento_nfe_00.NF
				and serie_nf = ?V_status_documento_nfe_00.SERIE_NF
				and filial = ?V_status_documento_nfe_00.FILIAL
				and status_nfe = 4
		ENDTEXT

		IF  .NOT. F_SELECT(lcSQL1, "VERIF_CAE4")
			MESSAGEBOX("Erro(1), contacte a TI- ERP", 16, "Aviso")
			RETURN .F.
		else
			IF RECCOUNT('VERIF_CAE4') > 0
				SELECT VERIF_CAE4
				*MESSAGEBOX('campos nulos')
				TEXT TO lcSQL2 NOSHOW TEXTMERGE PRETEXT 7
					update faturamento SET UTC_DATA_SAIDA = 3, UTC_EMISSAO = 3 ,
						DATA_HORA_EMISSAO = dateadd(MI, -60, data_hora_emissao) 
						where filial = ?VERIF_CAE4.filial and nf_saida = ?VERIF_CAE4.nf_saida 
							and serie_nf = ?VERIF_CAE4.serie_nf 
							and nome_clifor = 'CD BARRA VELHA' AND status_nfe=4
				ENDTEXT

				IF  .NOT. f_execute(lcSQL2)
					MESSAGEBOX("Erro, contacte a TI- ERP")
					RETURN .F.
				ELSE
					IF  .NOT. f_execute("EXEC lx_gera_nfe_sefaz_4_00 '" + VERIF_CAE4.nf_saida +"', '"+ VERIF_CAE4.serie_nf +"','"+ VERIF_CAE4.filial +"',"+"1 " )
						MESSAGEBOX("Erro(2), contacte a TI- ERP", 16, "Aviso")
						RETURN .F.
					ELSE
						MESSAGEBOX("NOTA ATUALIZADA :"+ VERIF_CAE4.nf_saida + " - serie :" + VERIF_CAE4.serie_nf, 64, "Aviso" )
					ENDIF

				ENDIF

			ENDIF
		endif
	ENDPROC
ENDDEFINE
