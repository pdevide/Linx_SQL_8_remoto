If !Pemstatus(O_TOOLBAR, 'IMG_DICA', 5)
	O_TOOLBAR.AddObject([IMG_Dica], [lx_image_dica])
	O_TOOLBAR.IMG_DICA.Picture  = [dicalinx.png]
	O_TOOLBAR.IMG_DICA.Top = 24
	O_TOOLBAR.IMG_DICA.Left = _screen.Width - 40
	O_TOOLBAR.IMG_DICA.ToolTipText = [Canal #DICALINX no YouTube]
	O_TOOLBAR.IMG_DICA.Width = 32
	O_TOOLBAR.IMG_DICA.Height = 32
	O_TOOLBAR.IMG_DICA.Visible = .T.
	O_TOOLBAR.IMG_DICA.Comment = 'https://www.youtube.com/channel/UCcLFShN8WMuL630SG-l0GOw'
Endif

Define Class lx_image_dica As lx_image
	Procedure Click
		If !f_vazio(This.Comment)
			Declare ShellExecute In shell32.Dll Integer, String, String, String, String, Integer
			ShellExecute( 0 , [open] , Alltrim(This.Comment) , [] , [] , 1 )
			Clear Dlls [ShellExecute]
		Endif
	EndProc
Enddefine
