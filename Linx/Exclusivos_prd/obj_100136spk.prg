** OBJ_100136SPK.PRG --> PAULO DEVIDE -> 05-11-2018 - ultima alteração 28-04-2021
*- Definindo a classe do objeto de entrada que sera criado na Form.
Define Class obj_entrada As Custom
	*- Nome do metodo/função que os objetos linx vão chamar.
	Procedure metodo_usuario
		Lparam xmetodo, xobjeto, xnome_obj

		Do Case
			Case Upper(xmetodo) == 'USR_ALTER_BEFORE'



			Case Upper(xmetodo) == 'USR_INIT'

				** PAULO DEVIDE -> 05-11-2018 (botao pra gerar modelo 7 em excel)
				thisformset.lx_form1.addobject('bt_report1', 'bt_report')
				WITH thisformset.lx_form1.bt_report1
					.height = 23
					.fontname = 'Arial'
					.Caption = 'Corrige UTC Barra Velha'
					.Left = 646
					.Top = 21
					.Width = 135
					.Visible = .T.
					.Enabled = .T.
					.anchor = 0
					.p_manter_baixo = .f.
					.p_manter_cima = .f.
					.p_manter_direita = .f.
					.p_manter_esquerda = .f.
					.p_muda_size = .f.

				ENDWITH
				** FIM: 05-11-2018


			Case Upper(xmetodo) == 'USR_SAVE_BEFORE'




		Endcase
	Endproc

Enddefine


** PAULO DEVIDE -> 05-11-2018
DEFINE CLASS bt_report as botao
	caption = 'Corrige UTC Barra Velha'
	*autosize = .T.
	WORDWRAP = .t.
	WIDTH = 192
	top = 3
	left = 502
	HEIGHT =  27
	enabled = .F.
	visible  = .t.
	backcolor =  RGB(64,128,128)

	PROCEDURE click
		CORRIGE_UTC()

	ENDPROC

	PROCEDURE refresh
		** Inclusão/Alteração/Exclusão/Tela (L)impa/(P)esquisa Feita!
		this.enabled = !INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L")
	ENDPROC

ENDDEFINE
** FIM: 05-11-2018

PROCEDURE CORRIGE_UTC
lnArea = SELECT()
SELECT v_status_documento_nfe_00
lnCount = 0
SCAN FOR v_status_documento_nfe_00.FILIAL="CD NAVEGANTES" AND v_status_documento_nfe_00.NOME_CLIFOR="CD BARRA VELHA" ;
				AND v_status_documento_nfe_00.STATUS_NFE=4
	m.emissao_nf  = DTOS(v_status_documento_nfe_00.emissao)

	WAIT WINDOW NOWAIT "Corrigindo NF "+ALLTRIM(v_status_documento_nfe_00.NF)

	TEXT TO lcSQL NOSHOW TEXTMERGE
		update faturamento 
		set UTC_DATA_SAIDA = 3, UTC_EMISSAO = 3, DATA_HORA_EMISSAO = dateadd(MI, -60, data_hora_emissao)
		WHERE	emissao='<<m.emissao_nf>>'	and filial='CD NAVEGANTES' and nome_clifor = 'CD BARRA VELHA' AND status_nfe=4
				AND NF_SAIDA = '<<ALLTRIM(v_status_documento_nfe_00.NF)>>' 
				AND SERIE_NF='<<ALLTRIM(v_status_documento_nfe_00.SERIE_NF)>>'
	ENDTEXT
	
	F_EXECUTE(lcSQL)	
		
	lnCount = lnCount + 1
	
	SELECT v_status_documento_nfe_00				
ENDSCAN
SELECT (lnArea)
IF lnCount > 0
	MESSAGEBOX(TRANSFORM(lnCount,"99999")+" notas corrigidas com sucesso"+CHR(13)+;
					"Favor clicar no botão para transmitir novamente",64,"Aviso")
ELSE
	MESSAGEBOX("Não há notas para corrigir na pesquisa efetuada!",64,"Aviso")

ENDIF
	
RETURN

