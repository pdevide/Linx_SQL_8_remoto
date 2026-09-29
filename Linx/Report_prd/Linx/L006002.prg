Function Setar_Proc_Termica_Mat && Setar Proc para Impressoras Térmicas (Zebra / Allegro / etc ) - Materiais

*---- Verifica existencia do arquivo prg ( que contem o codigo exclusivo do cliente )
xArq      = 'O_' + allt(strt(upper(wcontrole),'LX','')) + '.pp_arquivo_codigo_zebra_ent'
xArqComm  = &xarq
if !file(xArqComm)
	MessageBox( f_traduz('Atencão! Arquivo ') + xArqComm + f_traduz(' Não Existe, Verifique...') )
	Return .f.
else
	Set Proc to &xArqComm Addi
endif	
Return .t.
*-----------------------------------------------------------------------------------------------------------------------* 
