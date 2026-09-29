If Used([tmpLink])
	Use In tmplink
EndIf

f_select([SELECT 1 AS VERIFICACAO FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'TRANSACOES' AND COLUMN_NAME = 'LINK_SHARE'], [tmpLink])

If Used([tmpLink]) and Reccount([tmpLink])>0 and Nvl(tmpLink.VERIFICACAO, 0) = 1

	If Used([tmpLink])
		Use In tmplink
	Endif

	f_select([select link_share from DBO.TRANSACOES where cod_transacao = ?wTransacao], [tmpLink])

	If !F_VAZIO(tmpLink.link_share)

		_LocateForm = .f.

		For _CntForms = 1 to _screen.FormCount
			If Alltrim(Upper(_screen.Forms[_CntForms].Name)) == [LX_FORM1]
				If Alltrim(Upper(_screen.Forms[_CntForms].Parent.Name)) == Upper(Alltrim(wTransacao))
					_LocateForm = .t.
					Exit
				EndIf 
			EndIf 
		Next 

		If _LocateForm
			_screen.Forms[_CntForms].lx_titlebar.AddObject([btnHelp], [lx_image_help])
			_screen.Forms[_CntForms].lx_titlebar.btnhelp.Picture  = [Icone_SistemaLinxShare_64x64.png]
			_screen.Forms[_CntForms].lx_titlebar.btnhelp.Top = 1
			_screen.Forms[_CntForms].lx_titlebar.btnhelp.left = 80
			_screen.Forms[_CntForms].lx_titlebar.btnhelp.ToolTipText = [Ajuda no Linx Share]
			_screen.Forms[_CntForms].lx_titlebar.btnhelp.Width = 16
			_screen.Forms[_CntForms].lx_titlebar.btnhelp.Height = 16
			_screen.Forms[_CntForms].lx_titlebar.btnhelp.Visible = .t.
			_screen.Forms[_CntForms].lx_titlebar.btnhelp.Comment = Alltrim(tmplink.link_share)
			_screen.Forms[_CntForms].lx_titlebar.btnhelp.anchor = 512
		   
		EndIf 

	EndIf 
EndIf 


If Used([tmpLink])
	Use In tmplink
Endif

Define Class lx_image_help As lx_image
	Procedure Click
		If !f_vazio(This.Comment)
			Declare ShellExecute In shell32.Dll Integer, String, String, String, String, Integer
			shellexecute( 0 , [open] , Alltrim(This.Comment) , [] , [] , 1 )
			Clear Dlls [ShellExecute]
		Endif
	Endproc
Enddefine
