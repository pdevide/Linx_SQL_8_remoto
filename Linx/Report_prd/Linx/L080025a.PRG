FuncTion FUNC_RELATORIO
Param xtipo,x

If f_msg(["Deseja emitir o pedido por ordem de digitacao? ",36,"Atencao!"]) = 6
    xarquivo = "l080025a_1"
Else
	xarquivo = "l080025a"
Endif

do case 
	case UPPER(xtipo)='PRE'
		xsaida='previ'
	case UPPER(xtipo)='IMP'
		xsaida='noConsole to print Prompt'
	other
		f_msg(['Favor Alterar o LayOut nos FRT dos Relatorios:',32,"Atenção"])
		retu .f.
endcase

*repo form &xarquivo &XSAIDA
*Retu .F.
