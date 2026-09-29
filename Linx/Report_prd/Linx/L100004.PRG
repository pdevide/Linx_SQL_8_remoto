*--- Objetivo: Funcões Para Uso na Nota Fiscal/R. - ( VSCG/Linx: 1997a2002  )
*---
*------------------------------------------------------------------------------------------------------------------------*



*------------------------------------------------------------------------------------------------------------------------*
Function Pegar_SeloNF   && Chamada da Form (para obter dados ref. SELO FISCAL - Clientes do Nordeste)
Parameters xSer, xNum
do form lxoprel_SeloNF with xSer,xNum
Return .t.
*------------------------------------------------------------------------------------------------------------------------*



*------------------------------------------------------------------------------------------------------------------------*
Function Pegar_Transp   && Chamada da Form (Para Obter dados p/ transp.)
do form lxoprel_Transp
Return .t.
*------------------------------------------------------------------------------------------------------------------------*



*------------------------------------------------------------------------------------------------------------------------*
Procedure f_NF_Requery   && Requery da Filha na mudanca de nota
Param xOpenGrd,xOpenMod,pxSeparator
xsele = sele()
sele v_faturamento_00_imprimir
=tablerevert(.t.)
=requery()
=Atualiza_ICMS()   && Atualiza perc. de icms na tabela _imprimir
go top
Release xCF_Array
Public xCF_Array, xCF_Count
xCF_Count = 1
Declare xCF_Array(xCF_Count,2)
xCF_Array(xCF_Count,1) = ''
xCF_Array(xCF_Count,2) = ''
scan 
	=Ctrl_cf()
endscan
sele v_faturamento_00_imprimir
go top

if xOpenGrd
	xFilha_Origem = allt(upper(v_faturamento_00_imprimir.tipo))
	=f_open_grid(xOpenMod,pxSeparator,xFilha_Origem)
endif

=Prod_Equiv_Cliente()
sele v_faturamento_00_imprimir
go top

*!*	*--- Adicionar Itens de Importação - 005020
*!*	if v_faturamento_00.cod_transacao='ENTRADAS_001' and type('xnf_add_inport')='L'
*!*		if xnf_add_inport
*!*			=f_Add_Import()
*!*		endif
*!*	endif

x_Tot_Itens    = reccount() && guarda total de itens da nf atual
x_this_Frm_top = 1          && guarda formulário atual (só para para uso no header da nf)
go top
x_tot_forms = f_Tot_Forms() && guarda calculo do total de formulários da nf atual
x_caixas    = iif(isnull(v_faturamento_00.caixas_enviadas),'',f_get_Caixas(v_faturamento_00.filial,v_faturamento_00.nf_saida)) && Pega Caixas
Sele (xsele)
Return
*------------------------------------------------------------------------------------------------------------------------*



*------------------------------------------------------------------------------------------------------------------------*
*--- Atualiza ICMS na filha
Procedure Atualiza_ICMS   && Replace do perc. de icms na tabela _imprimir conforme perc. da pai
*> Para os casos abaixo não se calcula o percentual, pois este já vem na view:
*> Coluna: V_faturamento_00.tabela_filha Contendo 'FATURAMENTO_CONSUM'  ou 'FATURAMENTO_SAI1_MAT'
if ! ('CONSUM' $ v_faturamento_00.tabela_filha .or. 'SAI1_MAT' $ v_faturamento_00.tabela_filha)
	if v_faturamento_00.icms # 0
		**--calc. anterior (considerava campo cif)
		**  xperc_icms = v_faturamento_00.icms / (v_faturamento_00.valor_total- iif(v_faturamento_00.entrega_cif,v_faturamento_00.frete,0) - v_faturamento_00.seguro - v_faturamento_00.ipi_valor)*100
		**--calc. conforme form: logo, no lay-out pode-se pegar direto da pai, porém precisaria checar tabela filha (Consum/Sai1_mat)
		xsend = cursorget('sendupdate')
		=cursorsetprop('sendupdate',.f.)
		replace all icms with v_faturamento_00.porc_icms_base
		=cursorsetprop('sendupdate',xsend)
	endif
endif
Return
*------------------------------------------------------------------------------------------------------------------------*



*------------------------------------------------------------------------------------------------------------------------*
*--- Controle de Class.Fiscal da Nota Fiscal
Procedure Ctrl_CF
*--Gera Array com Codigo Completo e Reduzido da Classificacao Fiscal
If Type('xCF_Count') = 'U'
	Public xCF_Array, xCF_Count
	xCF_Count = 1
	Declare xCF_Array(xCF_Count,2)
	xCF_Array(xCF_Count,1) = ''
	xCF_Array(xCF_Count,2) = ''
EndIf
xNovoCod = UPPER(allt(v_classif_fiscal_00.classif_reduzida))
xNovoCla = UPPER(allt(v_classif_fiscal_00.classif_fiscal))
if ASCAN(xCF_array, xNovoCod,1) = 0 .and. !empty(xNovoCod)
	Declare xCF_Array(xCF_Count,2)
	xCF_Array(xCF_Count,1) = xNovoCod
	xCF_Array(xCF_Count,2) = xNovoCla
	xCF_Count = xCF_Count + 1
EndIf		
Return
*------------------------------------------------------------------------------------------------------------------------*



*------------------------------------------------------------------------------------------------------------------------*
*--- Calcula o Numero de Formularios para cada nota fiscal
Function f_Tot_Forms
local x_Tnotas, x_Tnotas2
x_Tnotas  = x_Tot_Itens/o_100004.pp_itens_p_nota
x_Tnotas2 = int(x_Tnotas) + iif(x_Tnotas - int(x_Tnotas) #0 ,1,0)
Return x_Tnotas2
*------------------------------------------------------------------------------------------------------------------------*



*------------------------------------------------------------------------------------------------------------------------*
*--- Controle de Itens Por Form. de Nota Fiscal
Procedure f_Next_Item
x_Next_Item  = x_Next_Item + 1    && Proximo Item           (comeca com 1)
x_Acum_Item  = x_Acum_Item + 1    && 'Atual' Item Acumulado (comeca com 0 a cada nova nota (requery) )
if x_Next_Item > o_100004.pp_itens_p_nota  && Mudanca de Formulario
    x_This_Frm  = x_Next_Frm
	x_Next_Frm  = x_Next_Frm + 1
	x_Next_Item = 1    && Comeca contar novamente na mudanca de formulario
endif
if x_Acum_Item >= x_Tot_Itens
	stor 1 to x_Next_Frm, x_Next_Item
	x_This_Frm  = f_Tot_Forms()   && // x_Tot_Forms //
endif
Return 
*------------------------------------------------------------------------------------------------------------------------*



*------------------------------------------------------------------------------------------------------------------------*
*--- Contador de form atual, para uso no topo da nf
Procedure f_count_nf_top
x_this_Frm_top = x_this_Frm_top + 1
Return
*------------------------------------------------------------------------------------------------------------------------*



*------------------------------------------------------------------------------------------------------------------------*
*--- Posiciona Controles no final de cada nota
Procedure f_Exit_Rodape  && (para a proxima nf, se existir)
if x_Acum_Item >= x_Tot_Itens
	stor 1 to x_Next_Frm,x_This_Frm,x_Next_Item
	stor 0 to x_Acum_Item
endif
Return
*------------------------------------------------------------------------------------------------------------------------*



*------------------------------------------------------------------------------------------------------------------------*
function f_get_Caixas       && Objetivo: Pegar as Caixas referente a nota fiscal informada
lparam xfilial, xnf_saida   &&         : Mantido apenas porquer a view só suporta até 250 caracters ( usar esta funcao em ultimo caso )
xalias  = sele()
xcaixas = ' '
=f_select("select distinct caixa from faturamento_prod where filial = '"+xfilial+"' and nf_saida = '"+xnf_saida+"'", "cur_caixas")
SELE cur_caixas
Scan
	xcaixas = xcaixas+Allt(cur_caixas.caixa)+","
EndScan
if len(xCaixas) > 0
	xcaixas = SubStr(xcaixas,1,Len(xcaixas)-1)
endif
use
sele (xalias)
RETURN(xcaixas)
*------------------------------------------------------------------------------------------------------------------------*



*------------------------------------------------------------------------------------------------------------------------*
*--- Soma_Esp/ "Para Uso no Recibo"
Procedure f_Soma_Esp
lParameters x_id
if x_id = 0
	xval_esp = 0
else
	xval_esp = xval_esp + ((val(f_encripta(vtmp_faturamento_00_prod.timestamp,.f.)) * vtmp_faturamento_00_prod.qtde) - vtmp_faturamento_00_prod.valor)
endif
Return
*------------------------------------------------------------------------------------------------------------------------*



*------------------------------------------------------------------------------------------------------------------------*
*--- Pega Class.Fiscal conforme parametro
*xVolta Retorna Classificacao Fiscal:
*Casos: a >   f_GetCF(X) -> Retorna uma Unica Classificacao no formato "Class"
*       b >   f_GetCF(X=)-> Retorna uma Unica Classificacao no formato "X=ClassX"
*       c >   f_GetCF(=) -> Retorna Todas as Classificacoes no formato "X=Class,Y=ClassY,Z=ClassZ,..."
*       d >   f_GetCF()  -> Retorna Todas as Classificacoes no formato "ClassX,ClassY,ClassZ,..."
Procedure f_GetCF
Para xLetra
Local k, xVolta
stor space(1) to xVolta

if type('xCF_array') # 'U'
	aSort(xCF_array,1)
	do case
	case (len(xLetra) >= 1 .and. (xLetra) # '=')  .or.  (len(xLetra)>= 2 .and. right(xLetra,1) = '=')  && casos a,b
		xtam = len(xLetra) - iif(right(xLetra,1) = '=',1,0)
		for k = 1 to Alen(xCF_array,1)
			if xCF_array(k,1)=left(xLetra,xtam)
				if  right(xLetra,1) = '='                        && Caso b
					xVolta = xCF_array(k,1)+'-'+xCF_array(k,2)
				else
					xVolta = xCF_array(k,2)                      && Caso a
				endif
			endif
		endfor
	case empty(xLetra) .or. (xLetra) = '='                       && Caso c,d
		for k = 1 to Alen(xCF_array)*1/2
			if empty(xLetra) && Caso d
				xVolta = iif(len(xVolta)=1,'',xVolta + ',') + xCF_array(k,2)
			else             && Caso c
				xVolta = iif(len(xVolta)=1,'',xVolta + ',') + xCF_array(k,1) + '-' + xCF_array(k,2)
			endif
		endfor
	endcase
EndIf
Return allt(xVolta)
*------------------------------------------------------------------------------------------------------------------------*



*------------------------------------------------------------------------------------------------------------------------*
Procedure Inverte_Campo 
para xCampo
if ! type('xCampo') $ 'NIC'
	Return(xCampo)
endif

if type('xCampo') $ 'NI'
	xCampo = str(xCampo)
endif
xCampo = allt(xCampo)

xResult = ''
for k = len(xCampo) to 1 step -1
	xResult=xResult+subs(xCampo,k,1)
endfor
Return (xResult)
*------------------------------------------------------------------------------------------------------------------------*



*------------------------------------------------------------------------------------------------------------------------*
Procedure f_open_grid
Parameters pxOpenMod,pxSeparator,xFilha_Origem
pxOpenMod = iif(type('pxOpenMod')<>'N',3,pxOpenMod)   && [ 1=Cor, 2=Cor+Desc, 3=Grade, 4=Cor+Grade, 5=Cor+Desc+Grade ]
pxSeparator = iif(type('pxSeparator')<>'C','/',pxSeparator)

do case
case 'PRODUTO SAIDA'  $ xFilha_Origem && "Produto Saida ( ver>=3.50 Sp1) 
*>
	=Open_Grid_Produto_Saida(pxOpenMod,pxSeparator)
case ('MATERIAL SAIDA' $ xFilha_Origem or 'MATERIAL ENTRADA' $ xFilha_Origem) and (pxOpenMod=1 or pxOpenMod=2)  && Materiais Por Cor
	=Open_Grid_Mat_Ent_Sai(pxOpenMod,pxSeparator,xFilha_Origem)
endcase
Return .t.
*------------------------------------------------------------------------------------------------------------------------*



*------------------------------------------------------------------------------------------------------------------------*
function Open_Grid_Produto_Saida
Parameters pxOpenMod,pxSeparator
*--- Saida
*-------- Campos Incluidos ( o que muda em relação a view normal ) >> cor_produto, f1,...,f48 + desc_cor_produto
xs1  = "Select distinct a.produto,"
xs2  = "a.cor_produto, d.desc_cor_produto," &&
xs3  = "a.nf_saida, 'Produto Saida       ' tipo,desc_prod_nf+convert(char(60),space(60)) desc_prod_nf,"
xs4  = "convert(char(120),space(120)) obs_produto,classif_fiscal,tribut_icms,tribut_origem,unidade,convert(numeric(9,3),"
xs5  = "sum(qtde)) qtde,"
xs6  = "sum(f1)   f1, sum(f2)  f2,sum(f3)   f3,sum(f4)   f4,sum(f5)   f5,sum(f6)   f6, sum(f7)  f7, sum(f8)  f8, sum(f9)  f9,sum(f10) f10,"
xs7  = "sum(f11) f11,sum(f12) f12,sum(f13) f13,sum(f14) f14,sum(f15) f15,sum(f16) f16,sum(f17) f17,sum(f18) f18,sum(f19) f19,sum(f20) f20,"
xs8  = "sum(f21) f21,sum(f22) f22,sum(f23) f23,sum(f24) f24,sum(f25) f25,sum(f26) f26,sum(f27) f27,sum(f28) f28,sum(f29) f29,sum(f30) f30,"
xs9  = "sum(f31) f31,sum(f32) f32,sum(f33) f33,sum(f34) f34,sum(f35) f35,sum(f36) f36,sum(f37) f37,sum(f38) f38,sum(f39) f39,sum(f40) f40,"
xs10 = "sum(f41) f41,sum(f42) f42,sum(f43) f43,sum(f44) f44,sum(f45) f45,sum(f46) f46,sum(f47) f47,sum(f48) f48,"
xs11 = " convert(numeric(15,5),(preco*case when a.cambio_na_data is null or a.cambio_na_data=0 then 1 else a.cambio_na_data end)) preco,"
xs12 = "ipi,Sum((((preco*qtde)*ipi)/100)*case when a.cambio_na_data is null or a.cambio_na_data=0 then 1 else a.cambio_na_data end) val_IPI,"
xs13 = "convert(numeric(14,2),0) icms,convert(numeric(14,2),0) irrf, (desconto_item*case when a.cambio_na_data is null or a.cambio_na_data=0 then 1 else a.cambio_na_data end) desconto_item,"
xs14 = "convert(numeric(14,2),sum(valor*case when a.cambio_na_data is null or a.cambio_na_data=0 then 1 else a.cambio_na_data end)) valor,"
xs15 = "faixa From Faturamento_prod a, Produtos b, faturamento c "
xs16 = ",produto_cores d " &&
xs17 = "Where b.produto=a.produto and a.nf_saida=c.nf_saida and a.serie_nf=c.serie_nf and a.filial=c.filial "
xs18 = "and a.produto=d.produto and a.cor_produto=d.cor_produto " &&
xs19 = "and c.tabela_filha=?v_faturamento_00.tabela_filha and a.nf_saida=?v_faturamento_00.nf_saida "
xs20 = "and a.filial=?v_faturamento_00.filial and a.serie_nf=?v_faturamento_00.serie_nf "
xs21 = "Group By a.nf_saida,a.Produto,"
xs22 = "a.cor_produto,d.desc_cor_produto," &&
xs23 = "a.Preco,b.produto,faixa,desc_prod_nf,classif_fiscal,tribut_icms,tribut_origem,unidade,"
xs24 = "ipi,desconto_item,a.cambio_na_data"
if pxOpenMod=3
	xselect = xs1+    xs3+xs4+xs5+xs6+xs7+xs8+xs9+xs10+xs11+xs12+xs13+xs14+xs15+     xs17+     xs19+xs20+xs21+     xs23+xs24
else
	xselect = xs1+xs2+xs3+xs4+xs5+xs6+xs7+xs8+xs9+xs10+xs11+xs12+xs13+xs14+xs15+xs16+xs17+xs18+xs19+xs20+xs21+xs22+xs23+xs24
endif

*--- Processo
f_select(xselect,'Tmp_Grd_imprimir',alias())
sele tmp_grd_imprimir
index on left(Produto,12)+left(desc_prod_nf,40)+left(classif_fiscal,10)+left(tribut_icms,3)+left(tribut_origem,3)+left(unidade,5)+left(faixa,1)+left(str(preco),10) tag igrd

sele v_faturamento_00_imprimir
=cursorset('sendupdate',.f.)
Select * from v_faturamento_00_imprimir into cursor vtmp_imprimir
sele v_faturamento_00_imprimir
zap

sele vtmp_imprimir
go top
scan
	scatter memvar
	f_select('select * from produtos_tamanhos where grade in (select grade from produtos where produto=?vtmp_imprimir.produto)','tmp_grade',alias())

	sele Tmp_Grd_imprimir
	seek left(m.Produto,12)+left(m.desc_prod_nf,40)+left(m.classif_fiscal,10)+left(m.tribut_icms,3)+left(m.tribut_origem,3)+left(m.unidade,5)+left(m.faixa,1)+left(str(m.preco),10)
	if found()
		scan whil left(produto,12)=left(m.Produto,12) and left(desc_prod_nf,40)=left(m.desc_prod_nf,40) and left(classif_fiscal,10)=left(m.classif_fiscal,10) and left(tribut_icms,3)=left(m.tribut_icms,3) and left(tribut_origem,3)=left(m.tribut_origem,3) and left(unidade,5)=left(m.unidade,5) and left(faixa,1)=left(m.faixa,1) and left(str(preco),10)=left(str(m.preco),10) and !eof()
			sele v_faturamento_00_imprimir

			if pxOpenMod=1 or pxOpenMod=2 && Cor ou Cor+Desc 
				xqGrd = Tmp_Grd_imprimir.qtde
				if xqGrd <> 0
					appe blank
					gather memvar
					Replace qtde with xqGrd, valor with (xqGrd*preco), val_ipi with (xqGrd*preco*ipi/100),;
					        desc_prod_nf with allt(desc_prod_nf), obs_produto with allt(Tmp_Grd_imprimir.cor_produto) + iif(pxOpenMod=2,pxSeparator+allt(Tmp_Grd_imprimir.desc_cor_produto),'')
				endif
			else  && Por Grade ou Cor/Grade
				for k = 1 to 48
					k_ = allt(str(k))
					xqGrd = Tmp_Grd_imprimir.f&k_
					if xqGrd <> 0
				    	xObsp = iif(pxOpenMod=3 , tmp_grade.tamanho_&k_ , allt(Tmp_Grd_imprimir.cor_produto)+iif(pxOpenMod=5,pxSeparator+allt(Tmp_Grd_imprimir.desc_cor_produto),'')+pxSeparator+tmp_grade.tamanho_&k_ )
						appe blank
						gather memvar
						Replace qtde with xqGrd, valor with (xqGrd*preco), val_ipi with (xqGrd*preco*ipi/100),;
						        desc_prod_nf with allt(desc_prod_nf), obs_produto with xObsp
					endif
				endfor
			endif

			sele Tmp_Grd_imprimir
		endscan	
	else
		f_msg(['Problema: Provavel Mudança na Estrutura da Tabela Filha' + chr(13) + 'Não Será Possivel Abrir Por Grade...',16,'Atenção'])
	endif

	sele v_faturamento_00_imprimir
endscan

sele tmp_grd_imprimir
use
sele tmp_grade
use
sele v_faturamento_00_imprimir
go top
Return
*------------------------------------------------------------------------------------------------------------------------*



*------------------------------------------------------------------------------------------------------------------------*
function Open_Grid_Mat_Ent_Sai
Parameters pxOpenMod,pxSeparator,xFilha_Origem

if 'MATERIAL SAIDA' $ xFilha_Origem
	*--- Materias - Saidas
	xs1  = "select a.material produto,"
	xs2  = "a.cor_material cor_produto, d.desc_cor_material desc_cor_produto," &&
	xs3  = "a.nf_saida,'Material Saida ' tipo,b.desc_material+convert(char(60),space(60)) desc_prod_nf,"
	xs4  = "convert(char(120), space(120)) obs_produto,b.classif_fiscal,tribut_icms,tribut_origem,unid_estoque unidade,convert(numeric(9,3),"
	xs5  = "sum(qtde)) qtde, "
	xs6  = "convert(numeric(15,5),preco*case when cambio_na_data is null or cambio_na_data=0 then 1 else cambio_na_data end) preco, "
	xs7  = "ipi,sum((((preco*qtde)*ipi)/100)*case when cambio_na_data is null or cambio_na_data=0 then 1 else cambio_na_data end) val_IPI, "
	xs8  = "a.icms,convert(numeric(14,2),0) irrf,desconto_item*case when cambio_na_data is null or cambio_na_data=0 then 1 else cambio_na_data end desconto_item, "
	xs9  = "convert(numeric(20,2),sum(valor*case when cambio_na_data is null or cambio_na_data=0 then 1 else cambio_na_data end)) valor,"
	xs10  = "space(1) faixa from estoque_sai1_mat a,materiais b,faturamento c "
	xs11 = ",materiais_cores d " &&
	xs12 = "where a.nf_saida=c.nf_saida and a.serie_nf=c.serie_nf and a.filial_faturamento=c.filial and b.material=a.material "
	xs13 = "and a.material=d.material and a.cor_material=d.cor_material " &&
	xs14 = "and tabela_filha=?v_faturamento_00.tabela_filha and a.nf_saida=?v_faturamento_00.nf_saida "
	xs15 = "and filial_faturamento=?v_faturamento_00.filial and a.serie_nf=?v_faturamento_00.serie_nf "
	xs16 = "Group By a.nf_saida,a.material, "
	xs17 = "a.cor_material,d.desc_cor_material," &&
	xs18 = "a.preco,b.material,b.desc_material,classif_fiscal,tribut_icms,tribut_origem,unid_estoque,"
	xs19 = "ipi,desconto_item,a.icms,cambio_na_data "
else
	*---Materias - Entradas
	xs1  = "select a.material produto,"
	xs2  = "a.cor_material cor_produto, d.desc_cor_material desc_cor_produto," &&
	xs3  = "a.nf_entrada,'Material Entrada' tipo,desc_material+convert(char(60),space(60)) desc_prod_nf,"
	xs4  = "convert(char(120), space(120)) obs_produto,classif_fiscal,tribut_icms,tribut_origem,unidade_fornecedor unidade,convert(numeric(9,3),"
	xs5  = "sum(qtde)) qtde, "
	xs6  = "convert(numeric(15,5),((custo-desconto_item)*fator_conversao_unidade)) preco, "
	xs7  = "ipi,sum(((((custo-desconto_item)*fator_conversao_unidade)*qtde)*ipi)/100) val_IPI, "
	xs8  = "convert(numeric(14,2),0) icms,convert(numeric(14,2),0) irrf,desconto_item, "
	xs9  = "convert(numeric(20,2),sum(valor*fator_conversao_unidade)) valor,"
	xs10  = "space(1) faixa from entradas_material a,materiais b,entradas c "
	xs11 = ",materiais_cores d " &&
	xs12 = "where a.nf_entrada=c.nf_entrada and a.nome_clifor=c.nome_clifor and a.material=b.material "
	xs13 = "and a.material=d.material and a.cor_material=d.cor_material " &&
	xs14 = "and tabela_filha=?v_faturamento_00.tabela_filha and a.nf_entrada=?v_faturamento_00.nf_saida "
	xs15 = "and a.nome_clifor=?v_faturamento_00.nome_clifor "
	xs16 = "Group By a.nf_entrada,a.material, "
	xs17 = "a.cor_material,d.desc_cor_material," &&
	xs18 = "custo,b.material,desc_material,classif_fiscal,tribut_icms,tribut_origem,unidade_fornecedor,"
	xs19 = "ipi,desconto_item,fator_conversao_unidade "
endif
xselect = xs1+xs2+xs3+xs4+xs5+xs6+xs7+xs8+xs9+xs10+xs11+xs12+xs13+xs14+xs15+xs16+xs17+xs18++xs19

*--- Processo
f_select(xselect,'Tmp_Grd_imprimir',alias())

sele v_faturamento_00_imprimir
=cursorset('sendupdate',.f.)
zap

sele tmp_grd_imprimir
go top
scan
	scatter memvar
	sele v_faturamento_00_imprimir
	appe blank
	gather memvar
	Replace obs_produto with allt(Tmp_Grd_imprimir.cor_produto) + iif(pxOpenMod=2,pxSeparator+allt(Tmp_Grd_imprimir.desc_cor_produto),'')
	sele tmp_grd_imprimir
endscan

sele tmp_grd_imprimir
use
sele v_faturamento_00_imprimir
go top
Return
*------------------------------------------------------------------------------------------------------------------------*



*------------------------------------------------------------------------------------------------------------------------*
*--- Dados_Boleta
Proce f_Add_Boleta
xLogoBco = IIF(FILE('m:\linx_sql\linx\imagens\237.bmp'),'m:\linx_sql\linx\imagens\237.bmp',wwlogo)

*--- Dados Empresa
f_select('select * from cadastro_cli_for where  NOME_CLIFOR=?v_faturamento_00.Filial','tmp_dados_empresa',ALIAS())

*--- cria cursor caso não exista
xalias=sele()

if !used('tmp_boleta')
	xcur1 = "nome_empresa c(40),cod_banco c(3),nome_banco c(20),agencia c(10),conta c(15),"
	xcur2 = "carteira c(4),nosso_num c(25),documento c(15),data_venc d(8),especie c(4),"
	xcur3 = "especie_doc c(3),valor_tit n(11,2),data_doc d(8),aceite c(1),data_proces d(8),"
	xcur4 = "instru_1 c(100),instru_2 c(100),nome_cliente c(40),end_cobranca c(40),"
	xcur5 = "cid_cobranca c(20),uf_cobranca c(2),cep_cobranca c(9),rep_barras c(50),cod_barras c(50),logo_banco c(50)"
	xcursor = xcur1+xcur2+xcur3+xcur4+xcur5
	Create Cursor tmp_boleta (&xcursor)
endif

*--- Parcelas ( experimental em 09-11-2001 )
select DISTINCT filial,nf_saida,serie_nf FROM v_faturamento_00 INTO CURSOR tmp_lista_nfs
SELECT tmp_lista_nfs
GO top
SCAN
	sele v_faturamento_00
	LOCATE FOR filial=tmp_lista_nfs.filial and nf_saida=tmp_lista_nfs.nf_saida AND serie_nf=tmp_lista_nfs.serie_nf
	IF !EOF()
		scatter to xMemFat
		sele v_faturamento_00_parcelas
		requery()

		*--- Adapt Pai 
		xItParc=0
		GO top
		SCAN
			IF valor_a_receber > 0

				*--- Controle Quebra Pai
				xItParc = xItParc + 1
				sele v_faturamento_00
				IF xItParc>1
					APPEND BLANK
					GATHER FROM xMemFat
				endif
				Replace Tipo_Operacao WITH v_faturamento_00_parcelas.parcela  && porque aínda não tem campo apropriado

				*--- Add Itens da Boleta
				f_select('select a.documento,b.agencia,b.carteira from a_receber_fatura a, a_receber_parcelas b where a.fatura=b.fatura and b.fatura=?v_faturamento_00_parcelas.fatura and b.parcela=?v_faturamento_00_parcelas.parcela','tmp_receb',ALIAS())
				f_select('select nome_banco from bancos where banco=?v_faturamento_00_parcelas.banco','tmp_bancos',ALIAS())
				sele tmp_boleta
				appe blank
				Repl Nome_empresa with wempresa_nome,;
					 Cod_banco    with v_faturamento_00_parcelas.banco,;
					 Nome_banco   with IIF(ISNULL(tmp_bancos.nome_banco),'',tmp_bancos.nome_banco),;
					 Agencia      with IIF(ISNULL(tmp_receb.agencia),'',tmp_receb.agencia),;
					 Conta        with '<CONTA>',;
					 Carteira     with IIF(ISNULL(tmp_receb.carteira),'',tmp_receb.carteira),;
					 Nosso_Num    with ALLTRIM(v_faturamento_00.NF_SAIDA),;
					 Documento    with IIF(ISNULL(tmp_receb.documento),'',tmp_receb.documento),;
					 Data_venc    with iif(empty(v_faturamento_00_parcelas.vencimento),{},v_faturamento_00_parcelas.vencimento),;
					 Especie      with '<E>',;
					 Especie_doc  with '<ESPECIE DOC>',;
					 Valor_tit    with iif(empty(v_faturamento_00_parcelas.valor_a_receber),0,v_faturamento_00_parcelas.valor_a_receber),;
					 Data_doc     with iif(empty(v_faturamento_00.emissao),{},v_faturamento_00.emissao),;
					 Aceite       with '<A>',;
					 Data_proces  with iif(empty(v_faturamento_00.emissao),{},v_faturamento_00.emissao),;
					 Instru_1     with '<Instrução 1>',;
					 Instru_2     with '<Instrução 2>',;
					 Nome_cliente with v_faturamento_00.razao_social,;
					 End_cobranca with v_faturamento_00.cobranca_endereco,;
					 Cid_cobranca with v_faturamento_00.cobranca_cidade,;
					 Uf_cobranca  with v_faturamento_00.cobranca_uf,;
					 Cep_cobranca with v_faturamento_00.cobranca_cep,;
					 Rep_barras   with '12345678901234567890123456789012345678901234',;
					 Cod_Barras   with '12345678901234567890123456789012345678901234',;
					 logo_banco   with xLogoBco
				*---

			endif		
		ENDSCAN
	ENDIF
	SELECT tmp_lista_nfs
ENDSCAN

SELECT (xalias)
*------------------------------------------------------------------------------------------------------------------------*



*------------------------------------------------------------------------------------------------------------------------*
*--- Equiv Prod Cliente
FUNCTION Prod_Equiv_Cliente

sele v_faturamento_00_imprimir
xIdx=SET('index')
SET INDEX TO
GO top

SCAN
	f_select('select referencia_cliente, desc_produto_cliente from produtos_cliente where cliente_atacado=?v_faturamento_00.nome_clifor and produto=?v_faturamento_00_imprimir.produto','cur_equiv',ALIAS())
	IF !f_vazio(cur_equiv.referencia_cliente) AND !f_vazio(cur_equiv.desc_produto_cliente)
		Replace produto WITH cur_equiv.referencia_cliente, desc_prod_nf WITH cur_equiv.desc_produto_cliente
	ENDIF
ENDSCAN

SET INDEX TO &xIdx
GO top
RETURN
*------------------------------------------------------------------------------------------------------------------------*




*!*	*------------------------------------------------------------------------------------------------------------------------*
*!*	Procedure f_Add_Import   && Importação: Origem tela 005020
*!*	xsele = sele()

*!*	sele v_faturamento_00_imprimir
*!*	=cursorset('sendupdate',.f.)

*!*	f_select('select * from entrada_importacao where nf_entrada=?v_faturamento_00.nf_saida','cur_ent_import')
*!*	sele cur_ent_import
*!*	go top
*!*	stor 0 to xi_Qtde, xi_Valor
*!*	scan
*!*		xi_Qtde  = xi_Qtde  + qtde
*!*		xi_Valor = xi_Valor + (qtde*custo)
*!*		sele v_faturamento_00_imprimir
*!*		appe blank
*!*		Replace nf_saida       with v_faturamento_00.nf_saida,;
*!*				produto        with cur_ent_import.ncm,;
*!*				desc_prod_nf   with cur_ent_import.desc_ncm,;
*!*				classif_fiscal with cur_ent_import.classif_fiscal,;
*!*				tribut_origem  with cur_ent_import.tributacao,;
*!*				unidade        with cur_ent_import.unidade,;
*!*				qtde           with cur_ent_import.qtde,;
*!*				preco          with cur_ent_import.custo,;
*!*				valor          with (cur_ent_import.qtde*cur_ent_import.custo)

*!*		sele cur_ent_import
*!*	endscan

*!*	sele v_faturamento_00
*!*	tablerevert(.t.)
*!*	Replace qtde_total  with (qtde_total+xi_Qtde),;
*!*			valor_total with (valor_total+xi_Valor)

*!*	sele v_faturamento_00_imprimir
*!*	GO top

*!*	sele(xsele)
*!*	Return
*!*	*------------------------------------------------------------------------------------------------------------------------*
