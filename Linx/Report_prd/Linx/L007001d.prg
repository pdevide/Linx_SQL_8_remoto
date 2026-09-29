procedure func_Relatorio
lparameter xtipo,xObj

if UPPER(xtipo)='PRE' or UPPER(xtipo)='IMP'
	x__Proc = set('proce')
	set proc to report.prg\L007001.prg addi

	=f_process_itens()
	=f_process_reservas()
	=f_process_envio()

	*--- copia tabelas filhas
	xObj.CopyTables("vtmp_m_ordem_fabricacao_00_item")
	xObj.CopyTables("vtmp_m_ordem_fabricacao_00_resumo_reserva")
	xObj.CopyTables("vtmp_m_ordem_fabricacao_00_envios")

	set proce to &x__Proc
endif

sele v_m_ordem_fabricacao_00
go top
Return .t.
*---------------------------------------------------------------------------------------------------------------------------*
