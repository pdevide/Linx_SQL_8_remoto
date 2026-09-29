** coloca o objeto da tela Linx
oo = o_002006

=AMEMBERS(laProps,oo)

CREATE CURSOR tabprops (propriedade C(50))

FOR ii=1 TO ALEN(laProps,1)
	INSERT INTO tabprops VALUES (laProps[ii])
ENDFOR

SELECT tabprops 
arqsaida = "c:\temp\"+"prop_"+SYS(2015)+".txt"
COPY TO &arqsaida. TYPE sdf
