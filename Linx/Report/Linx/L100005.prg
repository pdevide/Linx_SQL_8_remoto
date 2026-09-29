*------- Funcao do Modulo 100005 / 100011
*        Obtem as Faturas Especiais para o Recibo de uma Nota Fiscal

Procedure Obter_Faturas
Param xGeral

xsele = alias()
xfatura_tipo2 = iif(f_vazio(v_faturamento_02.CONFERENCIA),v_faturamento_02.fatura,f_encripta(v_faturamento_02.CONFERENCIA))    && variavel padrao, necessaria para a view parcelas

sele v_faturamento_02_fatura
=tablerevert(.t.)
=requery()

sele v_faturamento_02_parcelas
set filt to
=tablerevert(.t.)
=requery()

xCPMed = allt(cnameform)+'.lx_calcula_prazo_medio()'
&xCPMed

sele v_faturamento_02_parcelas
if not xGeral
	set filt to fatura = XFATURA_TIPO2
endif
go top

release xFatura
public  xFatura
declare xFatura(6,iif(xGeral,24,12)) && (12=Produca ; 24=Producao+Normal)

for k = 1 to iif(xGeral,24,12)
	if ! eof()
		xFatura(1,k) = fatura + parcela
		xFatura(2,k) = vencimento
		xFatura(3,k) = valor_original
		xFatura(4,k) = prazo
		xFatura(5,k) = iif(isnull(desconto_venc),0,desconto_venc)
		xFatura(6,k) = iif(isnull(data_desconto_venc),{},data_desconto_venc)
		skip
	else
		xFatura(1,k) = space(1)
		xFatura(2,k) = {}
		xFatura(3,k) = 0
		xFatura(4,k) = 0
		xFatura(5,k) = 0
		xFatura(6,k) = {}
	endif
endfor	

sele (xsele)
Return
*---------------------------------------------------------------------------------------------------------------------------*
