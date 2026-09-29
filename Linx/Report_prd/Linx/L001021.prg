Procedure Processa_Comissao
local xsele
xsele = sele()

xIRRF_Minimo = o_001021.pp_darf_minimo
xImpIRMin=f_msg(['Deseja Imprimir IRRF Com Valores Abaixo do Definido no Parâmetro DARF_MINIMO ?' + chr(13) + 'Valor Mínimo Para Recolhimento:' + transf(xIRRF_Minimo,"9999 999.99"),36,'Atenção!!!'])
xFilGer=7
if o_001021.Px_Pesquisa_Gerente
	xFilGer=f_msg(['Deseja Filtrar Apenas Tipo Gerente? ',36,'Atenção!!!'])
endif

=Gerar_Comissao_Base()
=Gerar_Comissao_Totas()

sele (xsele)
Return 
**-------------------------------------------------------------------------------------------------------------------------**




**-------------------------------------------------------------------------------------------------------------------------**
Procedure Gerar_Comissao_Base  && Prepara estrutura básica

Local xFiltro,xFiltro_Tela
if xFilGer=6
	xFiltro = " tipo $ '02 04 06 08 11 13 15 17' "
else
	xFiltro = " iif(tipo $ '02 04 06 08 11 13 15 17',representante=gerente,.t.) " && Tipos Definidos Para Gerente ( AddItem da Tela )
endif

*------- Gerar Cursor Resultante
sele v_representantes_00
cursorsetprop("Buffering",3)
index on representante tag iRep

select a.*, a.fatura as nf_saida,space(25) as pedido, b.irrf from v_representantes_comissao_00 a,v_representantes_00 b into cursor tmp_stru where .f.
sele tmp_stru
=afields(xcampos)
create cursor vtmp_representantes_comissao_00 from array xcampos

sele v_representantes_comissao_00
set filter to &xFiltro
count to xTotItens
if xTotItens = 0
	f_msg(['Nenhum Registro Selecionado Nestas Condições',48,'Atenção!!!'])
	set filt to
	Return .f.
endif
set relation to representante into v_representantes_00
go top

xItemAtu = 0
scan
	xItemAtu = xItemAtu + 1
	f_prog_bar('Processando Comissões...',xItemAtu,xTotItens)

	f_select('select pedido from vendas where pedido in (select distinct pedido from faturamento_prod where nf_saida=?v_representantes_comissao_00.fatura)','Tmp_Pedido',alias())
	f_select('select nf_saida from faturamento where fatura=?v_representantes_comissao_00.fatura','Tmp_NF',alias())
	scatter to xmemvar
	sele vtmp_representantes_comissao_00
	appe blank
	gather from xmemvar
	replace irrf with v_representantes_00.irrf, pedido with Tmp_Pedido.pedido, nf_saida with Tmp_NF.nf_saida
	sele v_representantes_comissao_00
endscan

sele v_representantes_comissao_00
set filter to 
**-------------------------------------------------------------------------------------------------------------------------**




**-------------------------------------------------------------------------------------------------------------------------**
Procedure Gerar_Comissao_Totas && Gerar Cursor com totais

sele vtmp_representantes_comissao_00
index on representante+gerente+tipo tag iComiss

select representante, gerente, tipo, saldo as repre_saldo, saldo as repre_comple, saldo as repre_irrf, 000000.0000 as repre_perc_irrf from v_representantes_comissao_00 where .f. into cursor tmp_stru
sele tmp_stru
=afields(xcampos)
create cursor tmp_comissao_totais from array xcampos

sele vtmp_representantes_comissao_00
count to xTotItens
go top

xItemAtu = 0
do whil ! eof()
	xRepre   = representante
	xGeren   = gerente
	xTipo    = tipo
	xPerc_Ir = iif(isnull(irrf),0,irrf)

	stor 0 to xSld,xComple
	scan while representante=xRepre and gerente=xGeren and tipo=xTipo
		xItemAtu = xItemAtu + 1
		f_prog_bar('Processando Totais...',xItemAtu,xTotItens)
		xSld     = xSld    + (credito-debito)
		xComple  = xComple + iif(val(tipo)>=10,(credito-debito),0)  && >=10 == COMPLEMENTO
	endscan

	xVal_Ir  = round( ( (xSld-xComple)*(xPerc_Ir/100) ) ,2)
	if xImpIRMin <> 6 and xVal_Ir < xIRRF_Minimo && Imposto Mínimo 
		stor 0 to xPerc_Ir,xVal_Ir
	endif	
	
	sele tmp_comissao_totais
	appe blank
	replace representante   with xRepre,;
	        gerente         with xGeren,;
	        tipo            with xTipo,;
			repre_saldo     with xSld,;
			repre_comple    with xComple,;
			repre_perc_irrf with xPerc_Ir,;
			repre_irrf      with xVal_Ir

	sele vtmp_representantes_comissao_00
enddo
**------------------------------------------------------------------------------------------------------------------------**
