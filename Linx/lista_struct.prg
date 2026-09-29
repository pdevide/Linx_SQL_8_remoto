SELECT vkardex01
=AFIELDS(laCampos,"vkardex01")
xx = ""
FOR ixx=1 TO ALEN(laCampos,1)
	xx=xx+laCampos(ixx,1)+";"
ENDFOR
STRTOFILE(xx,"c:\output\cabec.txt")

