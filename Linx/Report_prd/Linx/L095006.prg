** Funções para os reports da tela 095006
**
**-------------------------------------------------------------------------------------------------------------------------**
Function f_Processa_Remessa
Parameters xArq

*------- Pega dados do arquivo texto Remessa, armazena no cursor 
xRem = fopen(xArq)

if xRem < 1
	f_msg(['Problema na abertura do arquivo texto, verifique...',16,'Atenção!!!'])
	Return .f.
endif

xline  = fgets(xRem,400)
xCab   = xline

if at(allt(v_bancos_bordero_00.BANCO),xCab)=0
	=MessageBox(f_traduz('Arquivo Não Pertence ao Banco ') + v_bancos_bordero_00.BANCO + f_traduz(' Verifique...'),16,f_traduz('Atenção!!!'))
	=fclose(xRem)
	return .f.
endif 

do while ! feof(xRem)

	xline = fgets(xRem,400)
	if left(xline,1) = '1' && Detalhe

		*-- Obtem valores
		xNome_empresa = f_obter_string("NOME EMPRESA")
		xCod_banco    = allt(v_bancos_bordero_00.BANCO)
		xNome_banco   = f_obter_string("NOME BANCO")

		if allt(v_bancos_bordero_00.BANCO) = '237' && Bradesco
			xIdent    = f_obter_string("IDENTIFI EMPRESA")
			xAgencia  = subs(xIdent,5,5)
			xConta    = subs(xIdent,10,7)
			xCarteira = subs(xIdent,2,3)
			xCid_cobranca = ''
			xUf_cobranca  = ''
			xMoeda        = '9'
		else
			xAgencia      = f_obter_string("AGENCIA CEDENTE")
			xConta        = f_obter_string("CONTA CEDENTE")
			xCarteira     = f_obter_string("CARTEIRA")
			xCid_cobranca = f_obter_string("CIDADE SACADO")
			xUf_cobranca  = f_obter_string("UF SACADO")
			xMoeda        = f_obter_string("MOEDA")
		endif
		
	
		xEnd_cobranca = f_obter_string("ENDERECO SACADO")
		xCep_cobranca = f_obter_string("CEP SACADO")
		xNosso_Num    = f_obter_string("NOSSO NUMERO")
		xDocumento    = f_obter_string("DOCUMENTO CEDENTE")
		xData_venc    = f_obter_string("DATA VENCIMENTO")
		xEspecie      = f_obter_string("ESPECIE TITULO")
		xEspecie_doc  = ''
		xValor_tit    = f_obter_string("VALOR TITULO")
		xValor_tit    = iif(type('xValor_tit')<>'N',0,xValor_tit)
		xData_doc     = f_obter_string("DATA EMISSAO")
		xAceite       = f_obter_string("ACEITE")
		xData_proces  = xData_doc
		if allt(v_bancos_bordero_00.BANCO) = '275' && Real
			xInstru_1     = ''
			xInstru_2     = ''
		    xNosso_Num    = f_strzero(val(xNosso_Num),13)
			xDigitao      = f_Mod2Bco(xAgencia+xConta+xNosso_Num)
			xEspecie      = 'DM'
		else
			xInstru_1     = f_trata_instru(f_obter_string("INSTRUCAO 1"))
			xInstru_2     = f_trata_instru(f_obter_string("INSTRUCAO 2"))
		endif
		
		xNome_cliente = f_obter_string("NOME SACADO")
		xRep_barras   = f_obter_barras(1)
		xCod_Barras   = f_obter_barras(2)

		if allt(v_bancos_bordero_00.BANCO) = '275' && Real
			xConta   = xConta + '-' + right(xNosso_Num,1)
		endif

		if allt(v_bancos_bordero_00.BANCO) = '237' && Bradesco
			xDigAgencia  = f_mod11(xAgencia,9,1)
			xDigConta    = f_mod11(xConta,9,1)
			xConta     = xConta   + '-' + xDigConta
			xAgencia   = xAgencia + '-' + xDigAgencia
			xNosso_Num = right(allt(xNosso_Num),12)
			xNosso_Num = xCarteira + '/' + subs(xNosso_Num,1,2) + '/' + subs(xNosso_Num,3,9) + '-' + subs(xNosso_Num,12,1)
		endif

		*-- grava valores obtidos
		sele tmp_boleta
		appe blank
		Repl Nome_empresa with xNome_empresa,;
			 Cod_banco    with xCod_banco,;
			 Nome_banco   with xNome_banco,;
			 Agencia      with xAgencia,;
			 Conta        with xConta,;
			 Carteira     with xCarteira,;
			 Nosso_Num    with xNosso_Num,;
			 Documento    with xDocumento,;
			 Data_venc    with iif(empty(xData_venc),{},xData_venc),;
			 Especie      with xEspecie,;
			 Especie_doc  with xEspecie_doc,;
			 Valor_tit    with iif(empty(xValor_tit),0,xValor_tit),;
			 Data_doc     with iif(empty(xData_doc),{},xData_doc),;
			 Aceite       with xAceite,;
			 Data_proces  with iif(empty(xData_proces),{},xData_proces),;
			 Instru_1     with xInstru_1,;
			 Instru_2     with xInstru_2,;
			 Nome_cliente with xNome_cliente,;
			 End_cobranca with xEnd_cobranca,;
			 Cid_cobranca with xCid_cobranca,;
			 Uf_cobranca  with xUf_cobranca,;
			 Cep_cobranca with xCep_cobranca,;
			 Rep_barras   with xRep_barras,;
			 Cod_Barras   with xCod_Barras
	endif

Enddo
=fclose(xRem)
Return
**-------------------------------------------------------------------------------------------------------------------------**




**-------------------------------------------------------------------------------------------------------------------------**
Procedure f_obter_string
para xlike

xRet = ''
xlike = '%'+allt(xlike)+'%'

xAlias = select()
f_select("select nome_campo,posicao,tamanho,tipo_dado from bancos_layout where banco = ?v_bancos_bordero_00.BANCO and nome_campo like ?xlike","tmp_string")

if reccount()=0
	MessageBox( f_traduz('Ocorrência não encontrada no Layout [') + xLike + ']', 16, f_traduz('Aviso') )
endif
select (xAlias)

if subs(tmp_string.nome_campo,1,3) = 'HDR'
	xRet = subs(xCab,tmp_string.posicao,tmp_string.tamanho)
else
	xRet = subs(xLine,tmp_string.posicao,tmp_string.tamanho)
endif

if tmp_string.tipo_dado = 'D'
	xRet = CtoD(subs(xRet,1,2)+'/'+subs(xRet,3,2)+'/'+subs(xRet,5,2))
endif
if tmp_string.tipo_dado = 'N'
	xRet = val(xRet)/100
endif

Return (xRet)
**-------------------------------------------------------------------------------------------------------------------------**




**-------------------------------------------------------------------------------------------------------------------------**
Procedure f_obter_barras
Para xTipo

Do case
Case allt(v_bancos_bordero_00.BANCO) = '347'
	*-- obtem cod. barras
	zAgencia    = left(allt(xAgencia),3)
	zConta      = left(allt(xConta),8)
	zMoeda      = right(allt(xMoeda),1)
    zNosso_Num  = left(allt(xNosso_Num),9)
	zZeros      = '00000'
	zValor      = f_strzero(xValor_tit*100,14)
	zDig        = f_mod11((allt(v_bancos_bordero_00.BANCO)+zMoeda+zValor+zAgencia+zConta+zNosso_Num+zZeros),9,1)
	zCod_Barras = allt(v_bancos_bordero_00.BANCO) + zMoeda + zDig + zValor + zAgencia + zConta + zNosso_Num + zZeros

	*-- formacao dos 5 campos da representação do código de barras
	zcampo1 = allt(v_bancos_bordero_00.BANCO)+zMoeda+zAgencia+subs(zConta,1,2)
	zdig1   = f_mod11((zcampo1),9,1)
	zcampo1 = zcampo1+zdig1	
	
	zcampo2 = subs(zConta,5,3) + subs(zConta,6,2) + subs(zConta,8,1)  && [3 ult digitos + sufixo + digito da conta]
	zcampo2 = zcampo2 + subs(zNosso_Num,1,2) + subs(zNosso_Num,3,2)     && [prefixo + 2 primeiras pos. do nosso numero]
	zdig2   = f_mod11((zcampo2),9,1)
	zcampo2 = zcampo2+zdig2	
	
	zcampo3 = subs(zNosso_Num,5,4) + subs(zNosso_Num,9,1)    && [4 ultimos pos. do nosso numero + dig]
	zcampo3 = zcampo3 + '00000'
	zdig3   = f_mod11((zcampo3),9,1)
	zcampo3 = zcampo3+zdig3
		
	zcampo4 = zDig
	zcampo5 = iif(xValor_tit=0,'000',allt(str(xValor_tit*100)))

	*-- obtem representação do código de barras
	zRep_barras  = subs(zcampo1,1,5)+'.'+subs(zcampo1,6,len(zcampo1)-5) + space(2) + subs(zcampo2,1,5)+'.'+subs(zcampo2,6,len(zcampo2)-5) + space(2) + subs(zcampo3,1,5)+'.'+subs(zcampo3,6,len(zcampo3)-5) + space(2) + zcampo4 + space(2) + zcampo5




Case allt(v_bancos_bordero_00.BANCO) = '237'  && Bradesco
	*-- obtem cod. barras

    zNosso_Num  = left(allt(xNosso_Num),11)
	zAgencia    = right(allt(xAgencia),4)
	zCarteira	= right(allt(xCarteira),2)
	zConta      = left(allt(xConta),7)
	zZeros      = '0'
	zMoeda      = right(allt(xMoeda),1)
	zValor      = f_strzero(xValor_tit*100,14)
	zCampoLivre = zAgencia + zCarteira + zNosso_Num + zConta + zZeros
	zDig        = f_mod11((allt(v_bancos_bordero_00.BANCO) + zMoeda + zValor + zCampoLivre),9,1)
	zCod_Barras = allt(v_bancos_bordero_00.BANCO) + zMoeda + zDig + zValor + zCampoLivre
	
	
	*-- formacao dos 5 campos da representação do código de barras
	zcampo1 = allt(v_bancos_bordero_00.BANCO)+zMoeda+subs(zCampoLivre,1,5)
	zdig1   = f_Mod2Bco(zcampo1)
	zcampo1 = zcampo1+zdig1	
		
	zcampo2 = +subs(zCampoLivre,6,10)
	zdig2   = f_Mod2Bco(zcampo2)
	zcampo2 = zcampo2+zdig2	
	
	zcampo3 = +subs(zCampoLivre,16,10)
	zdig3   = f_Mod2Bco(zcampo3)
	zcampo3 = zcampo3+zdig3

	zcampo4 = zDig
	zcampo5 = iif(xValor_tit=0,'000',allt(str(xValor_tit*100)))
	
	*-- obtem representação do código de barras
	zRep_barras  = subs(zcampo1,1,5)+'.'+subs(zcampo1,6,len(zcampo1)-5) + space(2) + subs(zcampo2,1,5)+'.'+subs(zcampo2,6,len(zcampo2)-5) + space(2) + subs(zcampo3,1,5)+'.'+subs(zcampo3,6,len(zcampo3)-5) + space(2) + zcampo4 + space(2) + zcampo5




Case allt(v_bancos_bordero_00.BANCO) = '275'  && Real
	*-- obtem cod. barras
	
	zNosso_Num  = xNosso_Num
	zDigitao    = xDigitao
	zAgencia    = left(allt(xAgencia),4)
	zConta      = left(allt(xConta),7)
	zMoeda      = '9' && Reais
	zValor      = f_strzero(xValor_tit*100,14)
	zCampoLivre = zAgencia + zConta + zDigitao + zNosso_Num

	zDig        = f_mod11((allt(v_bancos_bordero_00.BANCO) + zMoeda + zValor + zCampoLivre),9,1)
	zCod_Barras = allt(v_bancos_bordero_00.BANCO) + zMoeda + zDig + zValor + zCampoLivre
	
	*-- formacao dos 5 campos da representação do código de barras
	zcampo1 = allt(v_bancos_bordero_00.BANCO)+zMoeda+subs(zCampoLivre,1,5)
	zdig1   = f_Mod2Bco(zcampo1)
	zcampo1 = zcampo1+zdig1	
		
	zcampo2 = +subs(zCampoLivre,6,10)
	zdig2   = f_Mod2Bco(zcampo2)
	zcampo2 = zcampo2+zdig2	
	
	zcampo3 = +subs(zCampoLivre,16,10)
	zdig3   = f_Mod2Bco(zcampo3)
	zcampo3 = zcampo3+zdig3

	zcampo4 = zDig
	zcampo5 = iif(xValor_tit=0,'000',allt(str(xValor_tit*100)))

	*-- obtem representação do código de barras
	zRep_barras  = subs(zcampo1,1,5)+'.'+subs(zcampo1,6,len(zcampo1)-5) + space(2) + subs(zcampo2,1,5)+'.'+subs(zcampo2,6,len(zcampo2)-5) + space(2) + subs(zcampo3,1,5)+'.'+subs(zcampo3,6,len(zcampo3)-5) + space(2) + zcampo4 + space(2) + zcampo5

Other
	Stor '' to zCod_Barras,zRep_barras
Endcase

Return iif(xTipo=1,zRep_barras,zCod_Barras)
**-------------------------------------------------------------------------------------------------------------------------**




**-------------------------------------------------------------------------------------------------------------------------**
Procedure f_trata_instru
Para xInstru

xInstru = allt(xInstru)
f_select("select descricao_campo from bancos_tab_campos where banco = ?v_bancos_bordero_00.BANCO and valor_campo like ?xInstru","tmp_instru",alias())

xResult = tmp_instru.descricao_campo
xPosFim = at('(',xResult)

if xPosFim > 0
	xResult = subs(xResult,1,xPosFim-1)
endif
xNN = at('NN',xResult)
if xNN > 0
	xResult = strtran(xResult,'NN',f_obter_string("PRAZO PARA PROTESTO"))
endif
if 'DESCONTO POR DIA' $ xResult
	xResult = strtran(xResult,'-','') + str(f_obter_string("VALOR DESCONTO 1"))
endif

Return (xResult)
**-------------------------------------------------------------------------------------------------------------------------**





**-------------------------------------------------------------------------------------------------------------------------**
Procedure f_Mod2Bco
Para xNum

xMult = 1
xRes  = ''
for k = 1 to len(xNum)
	xMult = iif(xMult=1,2,1)
	xRes  = xRes + allt(str(val(subs(xNum,len(xNum)-k+1,1)) * xMult))
endfor

xSoma = 0
For k = 1 to len(xRes)
	xSoma = xSoma + val(subs(xRes,k,1))
EndFor

xDig = ''
if allt(v_bancos_bordero_00.BANCO) = '237' && Bradesco
	xFator = round(xSoma/10,0)
	if 10*xFator < xSoma
		xFator=xFator+1
	endif
	xDig = allt(str((10*xFator)-xSoma))
else
	if allt(v_bancos_bordero_00.BANCO) = '275' && Real
		xDig = 10 - (xSoma-(int(xSoma/10)*10))
		if xDig>9
			xDig = 0
		endif
		xDig = allt(str(xDig))
	endif	
endif

Return (xDig)
**-------------------------------------------------------------------------------------------------------------------------**




*!*	**-------------------------------------------------------------------------------------------------------------------------**
*!*	Procedure f_Hex
*!*	Para xNumDc

*!*	if !(len(xNumDc) = 2*int(len(xNumDc)/2))
*!*		xNumDc = '0' + xNumDc
*!*	endif

*!*	*-- Tabela Bin
*!*	declare xbin(10)
*!*	xbin(10) = '00110'
*!*	xbin(1)  = '10001'
*!*	xbin(2)  = '01001'
*!*	xbin(3)  = '11000'
*!*	xbin(4)  = '00101'
*!*	xbin(5)  = '10100'
*!*	xbin(6)  = '01100'
*!*	xbin(7)  = '00011'
*!*	xbin(8)  = '10010'
*!*	xbin(9)  = '01010'

*!*	*-- Tabela Hex
*!*	xHex_ini = '3C'
*!*	xHex_00  = '95'
*!*	xHex_01  = 'D5'
*!*	xHex_10  = 'A6'
*!*	xHex_11  = 'E6'
*!*	xHex_fim = '3E'

*!*	xHexRes  = ''
*!*	for k = 1 to len(xNumDc) step 2
*!*		xDig1 = val(subs(xNumDc,k  ,1))
*!*		xDig2 = val(subs(xNumDc,k+1,1))

*!*		xDig1 = iif(xDig1=0,10,xDig1)
*!*		xDig2 = iif(xDig2=0,10,xDig2)

*!*		for j = 1 to 5
*!*			xH = subs(xbin(xDig1),j,1) + subs(xbin(xDig2),j,1)
*!*			xHexRes = xHexRes + xHex_&xH
*!*		endfor
*!*	endfor

*!*	xHexRes = xHex_ini + xHexRes + xHex_fim
*!*	Return (xHexRes)
*!*	**-------------------------------------------------------------------------------------------------------------------------**




*!*	**-------------------------------------------------------------------------------------------------------------------------**
*!*	Procedure f_Bin
*!*	Para xNumDc

*!*	if !(len(xNumDc) = 2*int(len(xNumDc)/2))
*!*		xNumDc = '0' + xNumDc
*!*	endif

*!*	*-- Tabela Bin
*!*	declare xbin(10)
*!*	xbin(10) = '00110'
*!*	xbin(1)  = '10001'
*!*	xbin(2)  = '01001'
*!*	xbin(3)  = '11000'
*!*	xbin(4)  = '00101'
*!*	xbin(5)  = '10100'
*!*	xbin(6)  = '01100'
*!*	xbin(7)  = '00011'
*!*	xbin(8)  = '10010'
*!*	xbin(9)  = '01010'

*!*	xBinRes = ''
*!*	for k = 1 to len(xNumDc) step 2
*!*		xDig1 = val(subs(xNumDc,k  ,1))
*!*		xDig2 = val(subs(xNumDc,k+1,1))

*!*		xDig1 = iif(xDig1=0,10,xDig1)
*!*		xDig2 = iif(xDig2=0,10,xDig2)

*!*		for j = 1 to 5
*!*			xB = subs(xbin(xDig1),j,1) + subs(xbin(xDig2),j,1)
*!*			xBinRes = xBinRes + xB
*!*		endfor

*!*	endfor

*!*	Return (xBinRes)
*!*	**-------------------------------------------------------------------------------------------------------------------------**




*!*	**-------------------------------------------------------------------------------------------------------------------------**
*!*	Procedure f_EbcDic
*!*	Para xNumDc

*!*	if !(len(xNumDc) = 2*int(len(xNumDc)/2))
*!*		xNumDc = '0' + xNumDc
*!*	endif

*!*	*-- Tabela Bin
*!*	declare xbin(10)
*!*	xbin(10) = '00110'
*!*	xbin(1)  = '10001'
*!*	xbin(2)  = '01001'
*!*	xbin(3)  = '11000'
*!*	xbin(4)  = '00101'
*!*	xbin(5)  = '10100'
*!*	xbin(6)  = '01100'
*!*	xbin(7)  = '00011'
*!*	xbin(8)  = '10010'
*!*	xbin(9)  = '01010'

*!*	*-- Tabela EbcDic
*!*	*!*	xEbc_ini = '<'
*!*	*!*	xEbc_00  = 'n'
*!*	*!*	xEbc_01  = 'N'
*!*	*!*	xEbc_10  = 'w'
*!*	*!*	xEbc_11  = 'W'
*!*	*!*	xEbc_fim = '>'

*!*	xEbc_ini = '<'
*!*	xEbc_00  = 'E'
*!*	xEbc_01  = 'W'
*!*	xEbc_10  = 'N'
*!*	xEbc_11  = 'L'
*!*	xEbc_fim = '>'


*!*	xEbc  = ''
*!*	for k = 1 to len(xNumDc) step 2
*!*		xDig1 = val(subs(xNumDc,k  ,1))
*!*		xDig2 = val(subs(xNumDc,k+1,1))

*!*		xDig1 = iif(xDig1=0,10,xDig1)
*!*		xDig2 = iif(xDig2=0,10,xDig2)

*!*		for j = 1 to 5
*!*			xE = subs(xbin(xDig1),j,1) + subs(xbin(xDig2),j,1)
*!*			xEbc = xEbc + xEbc_&xE
*!*		endfor
*!*	endfor

*!*	xEbc = xEbc_ini + xEbc + xEbc_fim
*!*	Return (xEbc)
*!*	**-------------------------------------------------------------------------------------------------------------------------**
