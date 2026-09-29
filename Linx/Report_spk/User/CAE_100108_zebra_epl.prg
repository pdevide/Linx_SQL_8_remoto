*-- Cliente   : Forum - ( Valmir Linx 19/02/2005 )
*-- Impressora: Termica - Zebra Liguagem: EPL2
*---------------------------------------------------------------------------------------------------------------------------------------------------*


*-- Cliente   : M5 - ( ALterado por Luciano Reis  15/04/2009 )
*-- Impressora: Termica - Zebra Liguagem: EPL2
*---------------------------------------------------------------------------------------------------------------------------------------------------*
Procedure Etiqueta_Rota_Zebra_EPL2

SET STEP ON 

*!*			SELECT TOP 1 * from v_impressao_nf_00 ORDER BY nf iNTO CURSOR cursor_M

*!*			XXNF		=  cursor_M.nf
*!*			XXSERIE		=  cursor_M.serie_nf
*!*			XXFILIAL	=  cursor_M.filial

*!*			x1 = 'select 0000 as ii, a.nf_saida, a.volumes, a.filial, a.serie_NF, a.nome_clifor, a.transportadora, a.qtde_total, a.tipo_volume, '+;
*!*			'b.razao_social, b.entrega_endereco, b.entrega_cidade, b.entrega_uf, b.entrega_bairro, b.entrega_cep , '+;
*!*			'c.caixa, sum(c.qtde) as qtde_caixa '+;
*!*			'from faturamento a '+;
*!*			'inner join   cadastro_cli_for B on a.nome_clifor = b.nome_clifor '+;
*!*			'left join 	faturamento_prod C on a.nf_saida = c.nf_saida and a.filial = c.filial and a.serie_nf = c.serie_nf '+;
*!*			'where  a.nf_saida = ?XXNF '+;
*!*			'and a.filial = ?XXFILIAL '+;
*!*			'and a.serie_nf = ?XXSERIE '+;
*!*			'group by a.nf_saida, a.volumes, a.filial, a.serie_NF, '+;
*!*			'a.nome_clifor, a.transportadora, a.qtde_total, a.tipo_volume, '+;
*!*			'b.razao_social, b.entrega_endereco, b.entrega_cidade, b.entrega_uf, '+;
*!*			'b.entrega_bairro, b.entrega_cep, c.caixa	'
*!*			F_SELECT( x1 , 'TMP_TT1')

*!*			SELECT TMP_TT1
*!*			gnFieldcount = AFIELDS(gaMyArray) 
*!*			CLEAR
*!*			CREATE CURSOR vtmp_notas  FROM ARRAY gaMyArray

*!*			SELECT TMP_TT1
*!*			USE

*!*			SELECT v_impressao_nf_00 
*!*			SCAN
*!*				XXNF		=  v_impressao_nf_00.nf
*!*				XXSERIE		=  v_impressao_nf_00.serie_nf
*!*				XXFILIAL	=  v_impressao_nf_00.filial

*!*				F_SELECT( x1 , 'TMP_TT')

*!*				IF RECCOUNT('TMP_TT') > 0
*!*					SELECT TMP_TT
*!*					x = 0
*!*					SCAN
*!*						IF !ISNULL(TMP_TT.caixa)
*!*							SELECT vtmp_notas  
*!*							APPEND BLANK 
*!*							x = x + 1
*!*							replace ii					WITH	X
*!*							replace nf_saida			WITH	TMP_TT.nf_saida 
*!*							replace volumes				WITH	TMP_TT.volumes
*!*							replace filial				WITH	TMP_TT.filial
*!*							replace serie_NF			WITH	TMP_TT.serie_NF
*!*							replace nome_clifor			WITH	TMP_TT.nome_clifor
*!*							replace transportadora		WITH	TMP_TT.transportadora
*!*							replace qtde_total			WITH	TMP_TT.qtde_total
*!*							replace tipo_volume			WITH	TMP_TT.tipo_volume
*!*							replace razao_social		WITH	TMP_TT.razao_social
*!*							replace entrega_endereco	WITH	TMP_TT.entrega_endereco
*!*							replace entrega_cidade		WITH	TMP_TT.entrega_cidade
*!*							replace entrega_uf			WITH	TMP_TT.entrega_uf
*!*							replace entrega_bairro		WITH	TMP_TT.entrega_bairro
*!*							replace entrega_cep			WITH	TMP_TT.entrega_cep
*!*							replace caixa				WITH	TMP_TT.caixa
*!*							replace qtde_caixa 			WITH	TMP_TT.qtde_caixa 
*!*						ELSE
*!*							SELECT vtmp_notas  
*!*							FOR Y = 1 TO TMP_TT.volumes
*!*								APPEND BLANK 
*!*								x = x + 1
*!*								replace ii					WITH	X
*!*								replace nf_saida			WITH	TMP_TT.nf_saida 
*!*								replace volumes				WITH	TMP_TT.volumes
*!*								replace filial				WITH	TMP_TT.filial
*!*								replace serie_NF			WITH	TMP_TT.serie_NF
*!*								replace nome_clifor			WITH	TMP_TT.nome_clifor
*!*								replace transportadora		WITH	TMP_TT.transportadora
*!*								replace qtde_total			WITH	TMP_TT.qtde_total
*!*								replace tipo_volume			WITH	TMP_TT.tipo_volume
*!*								replace razao_social		WITH	TMP_TT.razao_social
*!*								replace entrega_endereco	WITH	TMP_TT.entrega_endereco
*!*								replace entrega_cidade		WITH	TMP_TT.entrega_cidade
*!*								replace entrega_uf			WITH	TMP_TT.entrega_uf
*!*								replace entrega_bairro		WITH	TMP_TT.entrega_bairro
*!*								replace entrega_cep			WITH	TMP_TT.entrega_cep
*!*								replace caixa				WITH	TMP_TT.caixa
*!*								replace qtde_caixa 			WITH	TMP_TT.qtde_caixa 
*!*							endfor	
*!*						endif	
*!*						SELECT TMP_TT
*!*					endscan
*!*				endif
*!*				SELECT v_impressao_nf_00 
*!*			endscan





	*--- Controles
	xChr  = 'chr(13)+chr(10)'

	xControl   = ''       && caracter de controle
	xClear     = 'N'       && clears the image buffer prior to building a new label image
	xDirection = 'ZT'      && Print from bottom of image

	* xIni  = 'N' + eval(xChr) + 'R15,3' + eval(xChr) + 'I8,A' + eval(xChr)
	  xini  = xControl + eval(xChr) + xClear + eval(xChr) + xDirection + eval(xChr)
 	  xfim  =  '  ' + eval(xChr)

	xQtde   = 'P1' + eval(xChr)
	xBarra  = ALLTRIM(Cur_Print_Etiqueta.codigo_barra)
	
	*--- Box
*!*		xBox1 = 'X0,2,4,840,790' + eval(xChr)
	**'B550,700,2,1C,4,6,150,N,"' + xBarra + '"' + eval(xChr)
*!*		xBox1  = xbox1 + 'X5,2,4,788,790' + eval(xChr)

	xBox1  = 'X5,2,4,600,790' + eval(xChr)
	xBox2  = 'X133,2,4,243,790' + eval(xChr)
	xBox3  = 'X133,550,4,243,790' + eval(xChr)
	xBox4  = 'X133,2,4,243,270' + eval(xChr)
	xBox5  = 'X301,2,4,373,790' + eval(xChr)


	
	*xBox6  = 'X370,2,4,479,790' + eval(xChr)
	xBox6  = 'X370,2,4,450,790' + eval(xChr)
	*xBox6  = ''

	xBox6a  = 'X447,2,4,527,790' + eval(xChr)

	
	xBox7  = 'X725,2,4,788,790' + eval(xChr)

	*--- Dados
	xTxt1  = 'A141,784,3,2,1,1,R," NF:"' + eval(xChr)
	xTxt2  = 'A141,547,3,2,1,1,R," Cod. Dest."' + eval(xChr)
	xTxt3  = 'A139,264,3,2,1,1,R," Vol:"' + eval(xChr)
	xTxt4  = 'A246,784,3,2,1,1,R," Rem:"' + eval(xChr)
	xTxt5  = 'A307,784,3,2,1,1,R," Dest:"' + eval(xChr)
	xTxt6  = 'A260,265,3,2,1,1,N,"Origem -"' + eval(xChr)

	xTxt7  = ''  && 'A408,266,3,2,1,1,R," FROTA: "' + eval(xChr)
	*xTxt8  = 'A452,780,3,4,1,1,N,"CEP:"' + eval(xChr)
	xTxt8  = 'A420,780,3,4,1,1,N,"CEP:"' + eval(xChr)
	xTxt9  = 'A20,770,3,5,2,2,N,"'   + ALLTRIM(Cur_Print_Etiqueta.Filial_sigla) + '"' + eval(xChr)
	xTxt10 = 'A20,390,3,5,2,2,N,"'   + ALLTRIM(Cur_Print_Etiqueta.rota_numero) + '"' + eval(xChr)
	xTxt11 = 'A173,780,3,5,1,1,N,"'  + ALLTRIM(Cur_Print_Etiqueta.nf) + '"' + eval(xChr)
	xTxt12 = 'A160,510,3,2,2,2,N,"'  + ALLTRIM(Cur_Print_Etiqueta.cod_destinatario) + '"' + eval(xChr)
	
	xTxt13 = 'A173,262,3,3,3,2,N,"'  + ALLTRIM(Cur_Print_Etiqueta.volumes) +'"' + eval(xChr)
	xTxt14 = 'A266,780,3,2,2,1,N,"'  + ALLTRIM(Cur_Print_Etiqueta.remetente) + '"' + eval(xChr)
	xTxt15 = 'A260,160,3,4,1,2,N,"'  + ALLTRIM(Cur_Print_Etiqueta.origem) + '"' + eval(xChr)

	xTxt16 = 'A333,780,3,2,2,1,N,"'  + ALLTRIM(Cur_Print_Etiqueta.destinatario) + '"' + eval(xChr)
	xTxt17 = 'A328,255,3,4,2,2,N,""' + eval(xChr) && Campo Viagem (Não usado)
	xTxt18 = 'A385,780,3,2,2,1,N,"'  + Allt(Cur_Print_Etiqueta.endereco) + ' - ' + ALLTRIM(Cur_Print_Etiqueta.bairro) + '"' + eval(xChr)
	*xTxt19 = 'A452,704,3,4,1,1,N,"'  + ALLTRIM(Cur_Print_Etiqueta.cep) + ' - ' + ALLTRIM(Cur_Print_Etiqueta.cidade)+'/'+ALLTRIM(Cur_Print_Etiqueta.uf) + '"' + eval(xChr)
	xTxt19 = 'A420,704,3,4,1,1,N,"'  + ALLTRIM(Cur_Print_Etiqueta.cep) + ' - ' + ALLTRIM(Cur_Print_Etiqueta.cidade)+'/'+ALLTRIM(Cur_Print_Etiqueta.uf) + '"' + eval(xChr)
	xTxt20 = 'A434,255,3,3,2,2,N,""' + eval(xChr) && Campo Frota (Não usado)
	

	xTxt20a = 'A465,780,3,5,1,1,N,"'  + "CAIXA: "+ALLTRIM(Cur_Print_Etiqueta.caixa) + " QTD: "+ ALLTRIM(STR(Cur_Print_Etiqueta.qtde))   +")"+ '"' + eval(xChr)
	
	
	f_select( "select DISTINCT PEDIDO FROM FATURAMENTO_PROD WHERE NF_SAIDA = '" + ALLTRIM(Cur_Print_Etiqueta.nf) + "' AND caixa = '" + ALLTRIM(Cur_Print_Etiqueta.caixa) + "'", 'v_tmp_pedido', ALIAS() )
	spedido = NVL(v_tmp_pedido.pedido,'')

	*xTxt21 = 'B485,700,3,1C,4,6,210,N,"' + xBarra + '"' + eval(xChr)
*!*		xTxt21 = 'B550,700,3,1C,4,6,150,N,"' + xBarra + '"' + eval(xChr)
	xBox1B  = 'X5,790,4,600,1050' + eval(xChr)
	xTxt21 = 'B560,1000,2,1C,4,6,150,N,"' + xBarra + '"' + eval(xChr)
*!*		xTxt21 = 'B800,8,2,1C,4,6,150,N,"' + xBarra + '"' + eval(xChr)
	
	xTxt22 = 'A560,840,2,2,1,1,N,"' 	 + xBarra + '"' + eval(xChr)
	xTxt23 = 'A210,840,2,2,1,1,N,"' + DTOC(DATE()) + ' ' + PADL(ALLTRIM(STR(HOUR(DateTime()))),2,'0') + ':' + PADL(ALLTRIM(STR(MINUTE(DateTime()))),2,'0') + '"' + eval(xChr)
	xTxt23b = 'A560,780,3,4,1,1,N," Pedido: ' + spedido + '"' + eval(xChr)
*!*		B250,310,0,1,3,0,100,N,"66453"
	xTxt23c = 'B590,64,1,1,3,6,60,N,"' + spedido + '"' + eval(xChr)
*!*		xTxt23c = 'B560,784,3,1C,4,6,80,N,"' + ALLTRIM(spedido) + '"' + eval(xChr)

	xTxt24 = 'A731,785,3,2,1,1,R," Obs.:"' + eval(xChr)
	xTxt25 = 'A731,250,3,2,1,1,R," Conf.:"' + eval(xChr)
	xTxt26 = 'A731,150,3,2,1,1,N,"' + LEFT(Cur_Print_Etiqueta.Embalador,12) + '"' + eval(xChr)
	xTxt27 = 'A752,775,3,2,2,2,N,"' + ALLTRIM(Cur_Print_Etiqueta.transportadora) + '"' + eval(xChr)

	*--- Linhas
	xLin1  = 'LE9,410,124,377' + eval(xChr)
	xLin2  = 'LE244,6,58,266' + eval(xChr)
	xLin3  = '' && 'LE306,6,94,264' + eval(xChr)
	xLin4  = 'LW1,680,1,1' + eval(xChr)

	xLayOut = (xBox1+xBox2+xBox3+xBox4+xBox5+xBox6+xBox6a+xBox7+xBox1b) + ;
			   (xTxt1+xTxt2+xTxt3+xTxt4+xTxt5+xTxt6+xTxt7+xTxt8+xTxt9+xTxt10+xTxt11+xTxt12+xTxt13+xTxt14+xTxt15+xTxt16+xTxt17+xTxt18+xTxt19+xTxt20+xTxt20a+xTxt21+xTxt22+xTxt23+xTxt23b+xTxt23c+xTxt24+xTxt25+xTxt26+xTxt27) + ;
			   (xLin1+xLin2+xLin3+xLin4)

	*--- Retorno
	xRetorno = xini + ( xLayOut ) + xQtde + xfim


Return(xRetorno)



Procedure Etiqueta_Rota_CAIXA


	*--- Controles
	xChr  = 'chr(13)+chr(10)'

	xControl   = ''       && caracter de controle
	xClear     = 'N'       && clears the image buffer prior to building a new label image
	xDirection = 'ZB'      && Print from bottom of image

	* xIni  = 'N' + eval(xChr) + 'R15,3' + eval(xChr) + 'I8,A' + eval(xChr)
	  xini  = xControl + eval(xChr) + xClear + eval(xChr) + xDirection + eval(xChr)
 	  xfim  =  '  ' + eval(xChr)

	xQtde   = 'P1' + eval(xChr)
	xBarra  = ALLTRIM(Cur_Print_Etiqueta.codigo_barra)
	
	*--- Box
	xBox1  = 'X5,2,4,788,790' + eval(xChr)
	xBox2  = 'X133,2,4,243,790' + eval(xChr)
	xBox3  = 'X133,550,4,243,790' + eval(xChr)
	xBox4  = 'X133,2,4,243,270' + eval(xChr)
	xBox5  = 'X301,2,4,373,790' + eval(xChr)
	xBox6  = 'X370,2,4,479,790' + eval(xChr)
	xBox7  = 'X725,2,4,788,790' + eval(xChr)

	*--- Dados
	xTxt1  = 'A141,784,3,2,1,1,R," NF:"' + eval(xChr)
	xTxt2  = 'A141,547,3,2,1,1,R," Cod. Dest."' + eval(xChr)
	xTxt3  = 'A139,264,3,2,1,1,R," Vol:"' + eval(xChr)
	xTxt4  = 'A246,784,3,2,1,1,R," Rem:"' + eval(xChr)
	xTxt5  = 'A307,784,3,2,1,1,R," Dest:"' + eval(xChr)
	xTxt6  = 'A260,265,3,2,1,1,N,"Origem -"' + eval(xChr)

	xTxt7  = ''  && 'A408,266,3,2,1,1,R," FROTA: "' + eval(xChr)
	xTxt8  = 'A452,780,3,4,1,1,N,"CEP:"' + eval(xChr)
	xTxt9  = 'A20,770,3,5,2,2,N,"'   + ALLTRIM(Cur_Print_Etiqueta.Filial_sigla) + '"' + eval(xChr)
	xTxt10 = 'A20,390,3,5,2,2,N,"'   + ALLTRIM(Cur_Print_Etiqueta.rota_numero) + '"' + eval(xChr)
	xTxt11 = 'A173,780,3,5,1,1,N,"'  + ALLTRIM(Cur_Print_Etiqueta.nf) + '"' + eval(xChr)
	xTxt12 = 'A160,510,3,2,2,2,N,"'  + ALLTRIM(Cur_Print_Etiqueta.cod_destinatario) + '"' + eval(xChr)
	
	xTxt13 = 'A173,262,3,3,3,2,N,"'  + ALLTRIM(Cur_Print_Etiqueta.volumes) +'"' + eval(xChr)
	xTxt14 = 'A266,780,3,2,2,1,N,"'  + ALLTRIM(Cur_Print_Etiqueta.remetente) + '"' + eval(xChr)
	xTxt15 = 'A260,160,3,4,1,2,N,"'  + ALLTRIM(Cur_Print_Etiqueta.origem) + '"' + eval(xChr)

	xTxt16 = 'A333,780,3,2,2,1,N,"'  + ALLTRIM(Cur_Print_Etiqueta.destinatario) + '"' + eval(xChr)
	xTxt17 = 'A328,255,3,4,2,2,N,""' + eval(xChr) && Campo Viagem (Não usado)
	xTxt18 = 'A385,780,3,2,2,1,N,"'  + Allt(Cur_Print_Etiqueta.endereco) + ' - ' + ALLTRIM(Cur_Print_Etiqueta.bairro) + '"' + eval(xChr)
	xTxt19 = 'A452,704,3,4,1,1,N,"'  + ALLTRIM(Cur_Print_Etiqueta.cep) + ' - ' + ALLTRIM(Cur_Print_Etiqueta.cidade)+'/'+ALLTRIM(Cur_Print_Etiqueta.uf) + '"' + eval(xChr)
	xTxt20 = 'A434,255,3,3,2,2,N,""' + eval(xChr) && Campo Frota (Não usado)

	xTxt21 = 'B485,700,3,1C,4,6,210,N,"' + xBarra + '"' + eval(xChr)
	xTxt22 = 'A705,700,3,2,1,1,N,"' 	 + xBarra + '"' + eval(xChr)
	xTxt23 = 'A705,210,3,2,1,1,N,"' + DTOC(DATE()) + ' ' + PADL(ALLTRIM(STR(HOUR(DateTime()))),2,'0') + ':' + PADL(ALLTRIM(STR(MINUTE(DateTime()))),2,'0') + '"' + eval(xChr)

	xTxt24 = 'A731,785,3,2,1,1,R," Obs.:"' + eval(xChr)
	xTxt25 = 'A731,250,3,2,1,1,R," Conf.:"' + eval(xChr)
	xTxt26 = 'A731,150,3,2,1,1,N,"' + LEFT(Cur_Print_Etiqueta.Embalador,12) + '"' + eval(xChr)
	xTxt27 = 'A752,775,3,2,2,2,N,"' + ALLTRIM(Cur_Print_Etiqueta.transportadora) + '"' + eval(xChr)

	*--- Linhas
	xLin1  = 'LE9,410,124,377' + eval(xChr)
	xLin2  = 'LE244,6,58,266' + eval(xChr)
	xLin3  = '' && 'LE306,6,94,264' + eval(xChr)
	xLin4  = 'LW1,680,1,1' + eval(xChr)

	xLayOut = (xBox1+xBox2+xBox3+xBox4+xBox5+xBox6+xBox7) + ;
			   (xTxt1+xTxt2+xTxt3+xTxt4+xTxt5+xTxt6+xTxt7+xTxt8+xTxt9+xTxt10+xTxt11+xTxt12+xTxt13+xTxt14+xTxt15+xTxt16+xTxt17+xTxt18+xTxt19+xTxt20+xTxt21+xTxt22+xTxt23+xTxt24+xTxt25+xTxt26+xTxt27) + ;
			   (xLin1+xLin2+xLin3+xLin4)

	*--- Retorno
	xRetorno = xini + ( xLayOut ) + xQtde + xfim


Return(xRetorno)
*---------------------------------------------------------------------------------------------------------------------------------------------------*








*---------------------------------------------------------------------------------------------------------------------------------------------------*
