
arq1 = GETFILE("txt","Selecione o arquivo")
IF EMPTY(arq1) 
	RETURN
ENDIF 
CREATE CURSOR tCaixas1 (caixa C(8))
APPEND FROM (arq1) sdf

SELECT tCaixas1
GO top

SCAN 
	f_wait("Carregando "+arq1+" : "+tCaixas1.caixa)
	o_100132.lx_form1.TX_CAIXA.value = ALLTRIM(tCaixas1.caixa)
	o_100132.lx_form1.TX_CAIXA.valid
	
	SELECT tCaixas1
ENDSCAN
f_wait()
MESSAGEBOX("Fim")


