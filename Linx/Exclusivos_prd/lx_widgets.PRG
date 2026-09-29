**//***********************************************************************************************************************
**// WIDGETS	- TEMPO
**// 			- TAXAS DE JUROS
**//			- COTA«’ES DE MOEDAS
**//***********************************************************************************************************************
** 11/08/2023 - DIEGO QUARESMA     - LINXERP-15444 - #1# - Melhoria no par‚metro ATIVA_WIDGETS, para ser feito por usu·rio.
** 27/09/2024 - DARIO SILVA		   - PRODSHOP-25167- #2# - Ajuste na validaÁ„o da API ao abrir o ERP
**//***********************************************************************************************************************

**#1#
**f_select("select VALOR_ATUAL from dbo.PARAMETROS where parametro = 'ATIVA_WIDGETS'", 'TMPParametro')
lcSQL = "SELECT  "+;
	"COALESCE(B.VALOR_ATUAL_USER, A.VALOR_ATUAL, '.F.') AS VALOR_ATUAL "+;
	"FROM DBO.PARAMETROS AS A (NOLOCK) "+;
	"LEFT  JOIN DBO.PARAMETROS_USERS AS B (NOLOCK) "+;
	"ON B.PARAMETRO = A.PARAMETRO "+;
	"WHERE   A.PARAMETRO = 'ATIVA_WIDGETS' AND (B.USUARIO IS NULL OR B.USUARIO = ?wusuario)  "
f_select(lcSQL, 'TMPParametro')
**#1#

If !Used('TMPParametro') Or Reccount('TMPParametro')=0 Or Nvl(TMPParametro.VALOR_ATUAL, '') <> '.T.'
	Use In TMPParametro
	Return .T.
Endif
Use In TMPParametro

f_select("Select cidade, uf from dbo.users (nolock) where usuario = ?wusuario", 'tmpUsr')

oHTTP = Createobject("MSXML2.ServerXMLHTTP")

_posSeletor = Iif(Type("skin.selector.position")="C", skin.selector.position, 'RIGHT')
_colorText = Iif(_Screen.BackColor > 16769900, Rgb(0,0,0), Rgb(255, 255, 255))
_nIncremento = 0
_countICN = 0

If Type("_screen.cntWidgets") != "O"
	_Screen.AddObject("cntWidgets", "container")
	_Screen.cntWidgets.Height = 50
	_Screen.cntWidgets.Width = 250
	_Screen.cntWidgets.Top = Iif(_posSeletor = 'RIGHT', ( _Screen.Height - _Screen.cntWidgets.Height) - 30, o_seletor.Top)
	_Screen.cntWidgets.Left = Iif(_posSeletor = 'RIGHT', 20, _Screen.Width - 270)
	_Screen.cntWidgets.Visible = .T.
	_Screen.cntWidgets.BackStyle = 0
	_Screen.cntWidgets.BorderWidth = 0
Endif

*-- Tempo
If Used('tmpUsr') And Reccount('tmpUsr')>0 And !f_vazio(tmpUsr.cidade)

	_url = 'http://servicos.cptec.inpe.br/XML/listaCidades?city='+Upper(Alltrim(tmpUsr.cidade))
	oHTTP.Open("GET", _url , .F.)
	_Error = .F.
	Try
		oHTTP.Send()
	Catch
		_Error = .T.
	Endtry

	If !_Error
		cSujeira = "‰„‡·‚ÍÎËÈÔÏÌˆıÚÛÙ¸˘˙˚ÒÁƒ√¿¡¬ À»…œÃÕ÷’“”‘‹Ÿ⁄€—«"
		cLimpo   = "aaaaaeeeeiiiooooouuuuncAAAAAEEEEIIIOOOOOUUUUNC"

		_count = 0
		_cityCode = ''
		Do While .T.
			_count = _count + 1
			_cityName = Strtran(Strtran(Chrtran(Upper(Alltrim(Strextract(oHTTP.ResponseText,'<nome>', '</nome>', _count))),cSujeira,cLimpo),"'", ""),'|', '')
			_UF = Strextract(oHTTP.ResponseText,'<uf>', '</uf>', _count)
			_cityCode = Strextract(oHTTP.ResponseText,'<id>', '</id>', _count)

			If f_vazio(_cityName)
				Exit
			Endif
			If Strtran(Strtran(Chrtran(Upper(Alltrim(tmpUsr.cidade)),cSujeira,cLimpo),"'", ""),'|', '') == _cityName And Upper(Alltrim(tmpUsr.uf)) == Upper(Alltrim(_UF))
				Exit
			Endif
		Enddo

		_url = 'https://brasilapi.com.br/api/cptec/v1/clima/previsao/'+_cityCode
		oHTTP.Open("GET", _url , .F.)
		oHTTP.Send()

		_condicao = Upper(Strextract(oHTTP.ResponseText,'"condicao":"', '","condicao_desc":"', 1))
		_condicaoDesc = Strextract(oHTTP.ResponseText,'","condicao_desc":"', '","min":', 1)
		_min = Strextract(oHTTP.ResponseText,'","min":', ',"max":', 1)
		_max = Strextract(oHTTP.ResponseText,',"max":', ',"indice_uv":', 1)
		_uv = Strextract(oHTTP.ResponseText,',"indice_uv":', '}]}', 1)

		If Type("_screen.cntWidgets.icnWheater") != "O"
			_Screen.cntWidgets.AddObject("icnWheater", "image")
			_Screen.cntWidgets.icnWheater.Height = 50
			_Screen.cntWidgets.icnWheater.Width = 50
			_Screen.cntWidgets.icnWheater.Top = 0
			_Screen.cntWidgets.icnWheater.Left = Iif(_posSeletor = 'RIGHT', 0, 200)
			_Screen.cntWidgets.icnWheater.BackStyle = 0
			_Screen.cntWidgets.icnWheater.Visible = .T.

			_nIncremento = Iif(Type("_screen.cntWidgets.icnWheater") != "O", 0, 60)
			_countICN = _countICN + 1
		Endif

		If Type("_screen.cntWidgets.Textw1") != "O"
			_Screen.cntWidgets.AddObject("Textw1", "label")
			_Screen.cntWidgets.Textw1.Width = 200
			_Screen.cntWidgets.Textw1.Top = 0
			_Screen.cntWidgets.Textw1.Left = Iif(_posSeletor = 'RIGHT', 52, 0)
			_Screen.cntWidgets.Textw1.BackStyle = 0
			_Screen.cntWidgets.Textw1.Alignment = Iif(_posSeletor = 'RIGHT', 0, 1)
			_Screen.cntWidgets.Textw1.Visible = .T.
			_Screen.cntWidgets.Textw1.FontName = "Tahoma"
			_Screen.cntWidgets.Textw1.FontSize = 8
			_Screen.cntWidgets.Textw1.FontBold = .T.
		Endif
		_Screen.cntWidgets.Textw1.Caption = _condicaoDesc
		_Screen.cntWidgets.Textw1.ForeColor = _colorText

		If Type("_screen.cntWidgets.Textw2") != "O"
			_Screen.cntWidgets.AddObject("Textw2", "label")
			_Screen.cntWidgets.Textw2.Width = 200
			_Screen.cntWidgets.Textw2.Top = 18
			_Screen.cntWidgets.Textw2.Left = Iif(_posSeletor = 'RIGHT', 52, 0)
			_Screen.cntWidgets.Textw2.BackStyle = 0
			_Screen.cntWidgets.Textw2.Alignment = Iif(_posSeletor = 'RIGHT', 0, 1)
			_Screen.cntWidgets.Textw2.Visible = .T.
			_Screen.cntWidgets.Textw2.FontName = "Tahoma"
			_Screen.cntWidgets.Textw2.FontSize = 8
			_Screen.cntWidgets.Textw2.FontBold = .T.
		Endif
		_Screen.cntWidgets.Textw2.Caption = "Temperatura - Min: "+_min+" M·x: "+_max
		_Screen.cntWidgets.Textw2.ForeColor = _colorText

		If Type("_screen.cntWidgets.Textw3") != "O"
			_Screen.cntWidgets.AddObject("Textw3", "label")
			_Screen.cntWidgets.Textw3.Width = 200
			_Screen.cntWidgets.Textw3.Top = 36
			_Screen.cntWidgets.Textw3.Left = Iif(_posSeletor = 'RIGHT', 52, 0)
			_Screen.cntWidgets.Textw3.BackStyle = 0
			_Screen.cntWidgets.Textw3.Alignment = Iif(_posSeletor = 'RIGHT', 0, 1)
			_Screen.cntWidgets.Textw3.Visible = .T.
			_Screen.cntWidgets.Textw3.FontName = "Tahoma"
			_Screen.cntWidgets.Textw3.FontSize = 8
			_Screen.cntWidgets.Textw3.FontBold = .T.
		Endif
		_Screen.cntWidgets.Textw3.Caption = "NÌvel de RadiaÁ„o UV: "+_uv
		_Screen.cntWidgets.Textw3.ForeColor = _colorText

		Do Case
			Case Inlist(_condicao, 'EC', 'CM', 'CN', 'PCM', 'PCT', 'PCN', 'PSC', 'PNT', 'IN')
				w_file = 'w_chuva1.png'
			Case Inlist(_condicao, 'C', 'CI', 'CV', 'CH', 'CT')
				w_file = 'w_chuva2.png'
			Case Inlist(_condicao, 'NPT', 'NPN', 'NCN', 'NCM', 'NCT', 'NPP', 'VN')
				w_file = 'w_nublado.png'
			Case Inlist(_condicao, 'PN', 'NV')
				w_file = 'w_p_nublado.png'
			Case Inlist(_condicao, 'NE')
				w_file = 'w_neve.png'
			Case Inlist(_condicao, 'PC', 'PP', 'PT', 'PM', 'NP', 'PNT', 'PPN', 'PPT', 'PPM')
				w_file = 'w_chuva3.png'
			Case Inlist(_condicao, 'T')
				w_file = 'w_chuva4.png'
			Case Inlist(_condicao, 'PS', 'CL')
				w_file = 'w_sol.png'
			Case Inlist(_condicao, 'N', 'E')
				w_file = 'w_nublado.png'
			Otherwise
				w_file = 'w_nd.png'
		Endcase
		_Screen.cntWidgets.icnWheater.Picture = w_file
	Endif
Endif

*-- Taxas
_url = 'https://brasilapi.com.br/api/taxas/v1'
oHTTP.Open("GET", _url , .F.)
_Error = .F.
Try
	oHTTP.Send()
Catch
	_Error = .T.
Endtry

If !_Error
	If oHTTP.Status=200 &&#2#
		If Type("_aTaxas") <> 'U'
			Release _aTaxas
		Endif
		Dimension _aTaxas[3]

		For _count = 1 To 3
			_taxName = Strextract(oHTTP.ResponseText,'"nome":"', '","valor":', _count)
			_valTax = Strextract(oHTTP.ResponseText,'","valor":', '}', _count)

			If f_vazio(_taxName)
				Exit
			Endif

			_aTaxas[_count] = _taxName + ' : ' + _valTax + '%'
		Next

		If Type("_screen.cntWidgets.icnTaxes") != "O"

			If _posSeletor = 'RIGHT'
				_Screen.cntWidgets.Top = _Screen.cntWidgets.Top - _nIncremento
			Endif
			_Screen.cntWidgets.Height = _Screen.cntWidgets.Height + _nIncremento

			_Screen.cntWidgets.AddObject("icnTaxes", "image")
			_Screen.cntWidgets.icnTaxes.Height = 50
			_Screen.cntWidgets.icnTaxes.Width = 50
			_Screen.cntWidgets.icnTaxes.Top = _nIncremento
			_Screen.cntWidgets.icnTaxes.Left = Iif(_posSeletor = 'RIGHT', 0, 200)
			_Screen.cntWidgets.icnTaxes.BackStyle = 0
			_Screen.cntWidgets.icnTaxes.Visible = .T.
			_Screen.cntWidgets.icnTaxes.Picture = 'w_taxas.png'
			_countICN = _countICN + 1
		Endif

		If Type("_screen.cntWidgets.Textt1") != "O"
			_Screen.cntWidgets.AddObject("Textt1", "label")
			_Screen.cntWidgets.Textt1.Width = 200
			_Screen.cntWidgets.Textt1.Top = _nIncremento
			_Screen.cntWidgets.Textt1.Left = Iif(_posSeletor = 'RIGHT', 52, 0)
			_Screen.cntWidgets.Textt1.BackStyle = 0
			_Screen.cntWidgets.Textt1.Alignment = Iif(_posSeletor = 'RIGHT', 0, 1)
			_Screen.cntWidgets.Textt1.Visible = .T.
			_Screen.cntWidgets.Textt1.FontName = "Tahoma"
			_Screen.cntWidgets.Textt1.FontSize = 8
			_Screen.cntWidgets.Textt1.FontBold = .T.
		Endif
		_Screen.cntWidgets.Textt1.Caption = _aTaxas[1]
		_Screen.cntWidgets.Textt1.ForeColor = _colorText

		If Type("_screen.cntWidgets.Textt2") != "O"
			_Screen.cntWidgets.AddObject("Textt2", "label")
			_Screen.cntWidgets.Textt2.Width = 200
			_Screen.cntWidgets.Textt2.Top = _nIncremento + 18
			_Screen.cntWidgets.Textt2.Left = Iif(_posSeletor = 'RIGHT', 52, 0)
			_Screen.cntWidgets.Textt2.BackStyle = 0
			_Screen.cntWidgets.Textt2.Alignment = Iif(_posSeletor = 'RIGHT', 0, 1)
			_Screen.cntWidgets.Textt2.Visible = .T.
			_Screen.cntWidgets.Textt2.FontName = "Tahoma"
			_Screen.cntWidgets.Textt2.FontSize = 8
			_Screen.cntWidgets.Textt2.FontBold = .T.
		Endif
		_Screen.cntWidgets.Textt2.Caption = _aTaxas[2]
		_Screen.cntWidgets.Textt2.ForeColor = _colorText

		If Type("_screen.cntWidgets.Textt3") != "O"
			_Screen.cntWidgets.AddObject("Textt3", "label")
			_Screen.cntWidgets.Textt3.Width = 200
			_Screen.cntWidgets.Textt3.Top = _nIncremento + 36
			_Screen.cntWidgets.Textt3.Left = Iif(_posSeletor = 'RIGHT', 52, 0)
			_Screen.cntWidgets.Textt3.BackStyle = 0
			_Screen.cntWidgets.Textt3.Alignment = Iif(_posSeletor = 'RIGHT', 0, 1)
			_Screen.cntWidgets.Textt3.Visible = .T.
			_Screen.cntWidgets.Textt3.FontName = "Tahoma"
			_Screen.cntWidgets.Textt3.FontSize = 8
			_Screen.cntWidgets.Textt3.FontBold = .T.
		Endif
		_Screen.cntWidgets.Textt3.Caption = _aTaxas[3]
		_Screen.cntWidgets.Textt3.ForeColor = _colorText

		_nIncremento = Iif(Type("_screen.cntWidgets.icnTaxes") != "O" And Type("_screen.cntWidgets.icnWheater") != "O", 0, 60)
	Endif
Endif

*-- CotaÁıes
_url = 'https://economia.awesomeapi.com.br/json/last/USD-BRL'
oHTTP.Open("GET", _url , .F.)
_Error = .F.
Try
	oHTTP.Send()
Catch
	_Error = .T.
Endtry

If !_Error
	_dolar = Strextract(oHTTP.ResponseText, '"ask":"', '","timestamp"', 1)

	_url = 'https://economia.awesomeapi.com.br/json/last/EUR-BRL'
	oHTTP.Open("GET", _url , .F.)
	oHTTP.Send()
	_euro = Strextract(oHTTP.ResponseText, '"ask":"', '","timestamp"', 1)

	_url = 'https://economia.awesomeapi.com.br/json/last/GBP-BRL'
	oHTTP.Open("GET", _url , .F.)
	oHTTP.Send()
	_libra = Strextract(oHTTP.ResponseText, '"ask":"', '","timestamp"', 1)

	If Type("_screen.cntWidgets.icnCotacoes") != "O"
		If _posSeletor = 'RIGHT'
			_Screen.cntWidgets.Top = _Screen.cntWidgets.Top - _nIncremento
		Endif
		_Screen.cntWidgets.Height = _Screen.cntWidgets.Height + _nIncremento

		_Screen.cntWidgets.AddObject("icnCotacoes", "lx_w_image")
		_Screen.cntWidgets.icnCotacoes.Height = 50
		_Screen.cntWidgets.icnCotacoes.Width = 50
		_Screen.cntWidgets.icnCotacoes.Top = _nIncremento * _countICN
		_Screen.cntWidgets.icnCotacoes.Left = Iif(_posSeletor = 'RIGHT', 0, 200)
		_Screen.cntWidgets.icnCotacoes.BackStyle = 0
		_Screen.cntWidgets.icnCotacoes.Visible = .T.
		_Screen.cntWidgets.icnCotacoes.Picture = 'w_cotacoes.png'
		*_countICN = _countICN + 1
	Endif

	If Type("_screen.cntWidgets.Textc1") != "O"
		_Screen.cntWidgets.AddObject("Textc1", "label")
		_Screen.cntWidgets.Textc1.Width = 200
		_Screen.cntWidgets.Textc1.Top = _nIncremento * _countICN
		_Screen.cntWidgets.Textc1.Left = Iif(_posSeletor = 'RIGHT', 52, 0)
		_Screen.cntWidgets.Textc1.BackStyle = 0
		_Screen.cntWidgets.Textc1.Alignment = Iif(_posSeletor = 'RIGHT', 0, 1)
		_Screen.cntWidgets.Textc1.Visible = .T.
		_Screen.cntWidgets.Textc1.FontName = "Tahoma"
		_Screen.cntWidgets.Textc1.FontSize = 8
		_Screen.cntWidgets.Textc1.FontBold = .T.
	Endif
	_Screen.cntWidgets.Textc1.Caption = 'DÛlar (USD): '+_dolar
	_Screen.cntWidgets.Textc1.ForeColor = _colorText

	If Type("_screen.cntWidgets.Textc2") != "O"
		_Screen.cntWidgets.AddObject("Textc2", "label")
		_Screen.cntWidgets.Textc2.Width = 200
		_Screen.cntWidgets.Textc2.Top = (_nIncremento * _countICN) + 18
		_Screen.cntWidgets.Textc2.Left = Iif(_posSeletor = 'RIGHT', 52, 0)
		_Screen.cntWidgets.Textc2.BackStyle = 0
		_Screen.cntWidgets.Textc2.Alignment = Iif(_posSeletor = 'RIGHT', 0, 1)
		_Screen.cntWidgets.Textc2.Visible = .T.
		_Screen.cntWidgets.Textc2.FontName = "Tahoma"
		_Screen.cntWidgets.Textc2.FontSize = 8
		_Screen.cntWidgets.Textc2.FontBold = .T.
	Endif
	_Screen.cntWidgets.Textc2.Caption = 'Euro (EUR): '+_euro
	_Screen.cntWidgets.Textc2.ForeColor = _colorText

	If Type("_screen.cntWidgets.Textc3") != "O"
		_Screen.cntWidgets.AddObject("Textc3", "label")
		_Screen.cntWidgets.Textc3.Width = 200
		_Screen.cntWidgets.Textc3.Top = (_nIncremento * _countICN) + 36
		_Screen.cntWidgets.Textc3.Left = Iif(_posSeletor = 'RIGHT', 52, 0)
		_Screen.cntWidgets.Textc3.BackStyle = 0
		_Screen.cntWidgets.Textc3.Alignment = Iif(_posSeletor = 'RIGHT', 0, 1)
		_Screen.cntWidgets.Textc3.Visible = .T.
		_Screen.cntWidgets.Textc3.FontName = "Tahoma"
		_Screen.cntWidgets.Textc3.FontSize = 8
		_Screen.cntWidgets.Textc3.FontBold = .T.
	Endif
	_Screen.cntWidgets.Textc3.Caption = 'Libra Esterlina (GBP): '+_libra
	_Screen.cntWidgets.Textc3.ForeColor = _colorText
Endif

Release oHTTP

*-- Classe especÌfica para o Ìcone de cotaÁıes
Define Class lx_w_image As Image

	Procedure DblClick

		If Messagebox("Atualiza as cotaÁıes das moedas?",36,wUsuario) = 6
			_colorText = Iif(_Screen.BackColor > 16769900, Rgb(0,0,0), Rgb(255, 255, 255))

			oHTTP = Createobject("MSXML2.ServerXMLHTTP")

			_url = 'https://economia.awesomeapi.com.br/json/last/USD-BRL'
			oHTTP.Open("GET", _url , .F.)
			oHTTP.Send()
			_dolar = Strextract(oHTTP.ResponseText, '"ask":"', '","timestamp"', 1)

			_url = 'https://economia.awesomeapi.com.br/json/last/EUR-BRL'
			oHTTP.Open("GET", _url , .F.)
			oHTTP.Send()
			_euro = Strextract(oHTTP.ResponseText, '"ask":"', '","timestamp"', 1)

			_url = 'https://economia.awesomeapi.com.br/json/last/GBP-BRL'
			oHTTP.Open("GET", _url , .F.)
			oHTTP.Send()
			_libra = Strextract(oHTTP.ResponseText, '"ask":"', '","timestamp"', 1)

			_Screen.cntWidgets.Textc1.Caption = 'DÛlar (USD): '+_dolar
			_Screen.cntWidgets.Textc1.ForeColor = _colorText

			_Screen.cntWidgets.Textc2.Caption = 'Euro (EUR): '+_euro
			_Screen.cntWidgets.Textc2.ForeColor = _colorText

			_Screen.cntWidgets.Textc3.Caption = 'Libra Esterlina (GBP): '+_libra
			_Screen.cntWidgets.Textc3.ForeColor = _colorText

			Release oHTTP

		Endif
	Endproc

Enddefine