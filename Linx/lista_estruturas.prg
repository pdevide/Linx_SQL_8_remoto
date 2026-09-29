
=AUSED(laTabs)
CREATE CURSOR TABELAS01 (AREA INT ,;
TABELA C(50), COLUNA C(60), TIPO C(1), TAMANHO INT, DECIMAIS INT)

FOR ii=1 TO ALEN(laTabs,1)
	lcMsg = TRANSFORM(ii)+"/"+TRANSFORM(ALEN(laTabs,1)) + " - " + laTabs[ii,1]
	WAIT WINDOW lcMsg nowait
	SELECT (laTabs[ii,1])
	=AFIELDS(laCampos)
	FOR qq=1 TO ALEN(laCampos,1)
		INSERT INTO TABELAS01 VALUES (ii, laTabs[ii,1], laCampos[qq,1],;
										laCampos[qq,2],laCampos[qq,3],laCampos[qq,4])
	ENDFOR
ENDFOR 


	