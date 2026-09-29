DIMENSION laTables[4]
laTables[1] = "faturamento"
laTables[2] = "faturamento_prod"
laTables[3] = "faturamento_item"
laTables[4] = "faturamento_imposto"

FOR q=1 TO 4

	f_select("select * from "+laTables[q]+" where 1=0","faturamento")
	AFIELDS(laCampos,"faturamento")
	lcString = ""
	FOR i=1 TO ALEN(laCampos,1)
		lcString = lcString  +;
			 TRANSFORM(LOWER(laCampos[i,1])) + ";" + TRANSFORM(laCampos[i,2]) + + ";" + TRANSFORM(laCampos[i,3]) + + ";" + TRANSFORM(laCampos[i,4]) +;
			 CHR(13)+CHR(10)
	ENDFOR

	* Defina o nome do arquivo
	lcFileName = "c:\temp\"+laTables[q]+".txt"

	* Abra o arquivo para escrita
	STRTOFILE(lcString, lcFileName)

	* Verifique se o arquivo foi criado com sucesso
	IF FILE(lcFileName)
	    MESSAGEBOX("Arquivo criado com sucesso!", 64, "Sucesso")
	ELSE
	    MESSAGEBOX("Falha ao criar o arquivo.", 16, "Erro")
	ENDIF

ENDFOR
