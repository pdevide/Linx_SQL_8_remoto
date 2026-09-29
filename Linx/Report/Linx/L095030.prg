*-----           Funcões Para Uso na Nota Fiscal-Fatura - nova  ( VS-2000  )                 -----*
**-----------------------------------------------------------------------------------------------**



**-----------------------------------------------------------------------------------------------**
Function Pegar_SeloNF && Chamada da Form (para obter dados ref. SELO FISCAL - Clientes do Nordeste)
Parameters xSer, xNum
do form lxoprel_SeloNF with xSer,xNum
Return .t.


**-----------------------------------------------------------------------------------------------**
Function Pegar_Transp   && Chamada da Form (Para Obter dados p/ transp.)
do form lxoprel_Transp
Return .t.


**-----------------------------------------------------------------------------------------------**
Procedure f_NF_Requery   && Requery da Filha na mudanca de nota
Param xOpenGrd
xsele = sele()
sele v_a_receber_fatura_01_itens
=tablerevert(.t.)
=requery()
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
sele v_a_receber_fatura_01_itens
go top
x_Tot_Itens    = reccount() && guarda total de itens da nf atual
x_this_Frm_top = 1          && guarda formulário atual (só para para uso no header da nf)
go top
x_tot_forms = f_Tot_Forms() && guarda calculo do total de formulários da nf atual
Sele (xsele)
Return


*---------------------------------------------------------- Controle de Class.Fiscal da Nota Fiscal/ Controle de Caixas
Procedure Ctrl_CF
*--Gera Array com Codigo Completo e Reduzido da Classificacao Fiscal
If Type('xCF_Count') = 'U'
	Public xCF_Array, xCF_Count
	xCF_Count = 1
	Declare xCF_Array(xCF_Count,2)
	xCF_Array(xCF_Count,1) = ''
	xCF_Array(xCF_Count,2) = ''
EndIf
xNovoCod = UPPER(allt(v_a_receber_fatura_01_itens.classif_reduzida))
xNovoCla = UPPER(allt(v_a_receber_fatura_01_itens.classif_fiscal))
if ASCAN(xCF_array, xNovoCod,1) = 0 .and. !empty(xNovoCod)
	Declare xCF_Array(xCF_Count,2)
	xCF_Array(xCF_Count,1) = xNovoCod
	xCF_Array(xCF_Count,2) = xNovoCla
	xCF_Count = xCF_Count + 1
EndIf		
Return


**-----------------------------------------------------------------------------------------------**
Function f_Tot_Forms  && Calcula o Numero de Formularios para cada nota fiscal
local x_Tnotas, x_Tnotas2
x_Tnotas  = x_Tot_Itens/10 && teste provisorio ***> o_095030.pp_itens_p_nota
x_Tnotas2 = int(x_Tnotas) + iif(x_Tnotas - int(x_Tnotas) #0 ,1,0)
Return x_Tnotas2


**-----------------------------------------------------------------------------------------------**
Procedure f_Next_Item  && Controle de Itens Por Form. de Nota Fiscal
x_Next_Item  = x_Next_Item + 1    && Proximo Item           (comeca com 1)
x_Acum_Item  = x_Acum_Item + 1    && 'Atual' Item Acumulado (comeca com 0 a cada nova nota (requery) )
if x_Next_Item > 10 && ***> teste o_095030.pp_itens_p_nota  && Mudanca de Formulario
    x_This_Frm  = x_Next_Frm
	x_Next_Frm  = x_Next_Frm + 1
	x_Next_Item = 1    && Comeca contar novamente na mudanca de formulario
endif
if x_Acum_Item >= x_Tot_Itens
	stor 1 to x_Next_Frm, x_Next_Item
	x_This_Frm  = f_Tot_Forms()   && // x_Tot_Forms //
endif
Return 


**-----------------------------------------------------------------------------------------------**
Procedure f_count_nf_top    && contador de form atual, para uso no topo da nf
x_this_Frm_top = x_this_Frm_top + 1
Return


**-----------------------------------------------------------------------------------------------**
Procedure f_Exit_Rodape  && Posiciona Controles no final de cada nota (para a proxima nf, se existir)
if x_Acum_Item >= x_Tot_Itens
	stor 1 to x_Next_Frm,x_This_Frm,x_Next_Item
	stor 0 to x_Acum_Item
endif
Return


**--------------------------------------------------------------------------Soma_Esp/ "Para Uso no Recibo"
Procedure f_Soma_Esp
lParameters x_id
if x_id = 0
	xval_esp = 0
else
	xval_esp = xval_esp + ((val(f_encripta(vtmp_faturamento_00_prod.timestamp,.f.)) * vtmp_faturamento_00_prod.qtde) - vtmp_faturamento_00_prod.valor)
endif
Return




**-------------------------------------------------------------Pega Class.Fiscal conforme parametro
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
					xVolta = xCF_array(k,2)                       && Caso a
				endif
			endif
		endfor
	case empty(xLetra) .or. (xLetra) = '='             && Caso c,d
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



**------------------------------------------------------------------------------------------------------------------------**
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
**------------------------------------------------------------------------------------------------------------------------**





