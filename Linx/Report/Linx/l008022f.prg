procedure func_Relatorio
lparameter xtipo,xObj

Gerar_Neta_OC()
xObj.CopyTables('vtmp_producao_corte_ordem_01_ficha_tecnica')
xObj.CopyTables('v_produtos_tamanho_00')

Return .t.
*---------------------------------------------------------------------------------------------------------------------------*




*---------------------------------------------------------------------------------------------------------------------------*
Procedure Gerar_Neta_OC

*--- Index com Uniq ( porque o filtro da neta é apenas pela ordem_corte )
sele v_producao_corte_ordem_01_produtos && filha
	set uniq on
	CURSORSETPROP('Buffering',3)
	index on ordem_corte tag iUnCorte

*--- cursor (neta)
sele v_producao_corte_ordem_01_ficha_tecnica
afields(xcampos)
create cursor vtmp_producao_corte_ordem_01_ficha_tecnica from array xcampos

sele v_producao_corte_ordem_01 && Pai
count to xRegTotal
xRegAtual = 0
go top
Scan
	xRegAtual = xRegAtual + 1
	xmensagem = string.translate("Processando Registro : {0} / {1} ({2}%)", alltrim(str(xRegAtual)), alltrim(str(xRegTotal)), alltrim(str(xRegAtual / xRegTotal * 100)))
	Messagebox.ShowProgress(xmensagem, xRegTotal,,.t.)

	sele v_producao_corte_ordem_01_produtos && filha
    Requery() && Com Uniq

	go top
	scan
		sele v_producao_corte_ordem_01_ficha_tecnica && Neta
	    Requery()
		go top
		scan
			scatter to xmemvar
			sele vtmp_producao_corte_ordem_01_ficha_tecnica
			append blank
			gather from xmemvar
			sele v_producao_corte_ordem_01_ficha_tecnica
		endscan
		sele v_producao_corte_ordem_01_produtos
	endscan
	
	sele v_producao_corte_ordem_01
endscan
Messagebox.ShowProgress()

*--- Desfaz Uniq
sele v_producao_corte_ordem_01_produtos && filha
CURSORSETPROP('Buffering',3)
set index to
set uniq off

RETURN .t. 
*---------------------------------------------------------------------------------------------------------------------------*
