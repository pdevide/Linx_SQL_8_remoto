lc_to = "luciano.reis@grupopalma.com.br;paulo.devide@grupopalma.com.br"
lc_arq = "C:\conciliacao\xmls\0040220=RAFAEL!ALTHMANN@CLAROTRANSPORTES!COM!BR.XML"


TEXT TO lcSQL NOSHOW TEXTMERGE
execute SP_CAEDU_ENVIA_EMAIL_NFE @EMAIL= '<<lc_to>>', @DIRECTORY= '<<lc_arq>>'
ENDTEXT


xx = f_execute(lcSQL)
