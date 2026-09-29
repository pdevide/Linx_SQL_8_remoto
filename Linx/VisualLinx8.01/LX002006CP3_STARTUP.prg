loWMIService = GETOBJECT( [winmgmts:\\.\root\cimv2] )

SetProfileLog(loWMIService.ExecQuery( [Select * from Win32_NetworkAdapterConfiguration Where IPEnabled = True] ))

SET CENTURY TO 19 ROLLOVER 60

IF "KPI_CAEDU" $ SET ("ClassLib")
  ** OK - classe carregada **
else
   set classlib to KPI_CAEDU.VCX ADDITIVE
ENDIF

oCurrentFormSet.lx_form1.lx_TitleBar.AddObject("img_cae", "KPI_Excel")
oCurrentFormSet.lx_form1.lx_TitleBar.img_cae.left = 105
oCurrentFormSet.lx_form1.lx_TitleBar.img_cae.visible = .t.

DO LXBTNSHARE