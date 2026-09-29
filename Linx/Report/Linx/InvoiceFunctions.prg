FUNCTION F_Load_Ctrl_NF_Form() && To POS Version >= 5.4.23

	LOCAL intAlias as integer
	intAlias = select()


	LOCAL strSelect as string
	strSelect = "SELECT * FROM W_IMPRESSAO_NF_LOJA WHERE CODIGO_FILIAL=?curLojaNotaFiscal.codigo_filial " + ;
				"   AND NF_NUMERO=?curLojaNotaFiscal.nf_numero AND SERIE_NF=?curLojaNotaFiscal.serie_nf"
	if !SQLSelect(strSelect, "curImpressaoNF", "Erro pesquisando dados da nota fiscal para impressão")
		return .f.
	endif

	strSelect = "SELECT CONVERT(INT, 0) AS T_FORM, CONVERT(INT, 0) AS N_FORM, * " + ;
				"  FROM W_IMPRESSAO_NF_LOJA_ITENS WHERE CODIGO_FILIAL=?curLojaNotaFiscal.codigo_filial " + ;
				"   AND NF_NUMERO=?curLojaNotaFiscal.nf_numero AND SERIE_NF=?curLojaNotaFiscal.serie_nf"
	if !SQLSelect(strSelect, "curImpressaoNFItens", "Erro pesquisando itens da nota fiscal para impressão")
		return .f.
	endif
	

	SELECT curImpressaoNFItens
	index on codigo_filial + nf_numero + serie_nf + item_impressao tag tagItens

	do while !eof()
		strKey = codigo_filial + nf_numero + serie_nf
		intForm = 1
		intCount = 0

		scan while alltrim(codigo_filial + nf_numero + serie_nf) == alltrim(strKey)
			intCount = intCount + 1

			if intCount > evl(main.p_itens_nota, 10)
				intForm = intForm + 1
				intCount = 0
			endif

			replace n_form with intForm
		endscan
	enddo

	select distinct codigo_filial, nf_numero, serie_nf, max(n_form) as t_forms ;
		from curImpressaoNFItens ;
		group by codigo_filial, nf_numero, serie_nf ;
		into cursor curForms

	select curForms
	scan
		select curImpressaoNFItens
		replace all t_form with curForms.t_forms for codigo_filial == curForms.codigo_filial and nf_numero == curForms.nf_numero and serie_nf == curForms.serie_nf
	endscan
	use

	select(intAlias)

	return .t.
ENDFUNC 




FUNCTION F_Load_Ctrl_NF_Financ()

	create cursor curNFFinanceiro (codigo_filial c(LEN(CurImpressaoNF.codigo_filial)), nf_numero c(LEN(CurImpressaoNF.nf_numero)), serie_nf c(LEN(CurImpressaoNF.serie_nf)), ;
		vencimento_1 D, valor_1 n(16, 2), vencimento_2 D, valor_2 n(16, 2), vencimento_3 D, valor_3 n(16, 2), ;
		vencimento_4 D, valor_4 n(16, 2), vencimento_5 D, valor_5 n(16, 2), vencimento_6 D, valor_6 n(16, 2), ;
		vencimento_7 D, valor_7 n(16, 2), vencimento_8 D, valor_8 n(16, 2), vencimento_9 D, valor_9 n(16, 2), ;
		vencimento_10 D, valor_10 n(16, 2), vencimento_11 D, valor_11 n(16, 2), vencimento_12 D, valor_12 n(16, 2))




select curNFFinanceiro
index on codigo_filial + nf_numero + serie_nf tag tagParcela

select CurImpressaoNF
index on codigo_filial + nf_numero + serie_nf tag tagNF
set relation to codigo_filial + nf_numero + serie_nf into curNFFinanceiro









	if curImpressaoNF.tipo_origem == 1 and used("curVendaParcelas")
		select curNFFinanceiro
		append blank
		replace codigo_filial with curImpressaoNF.codigo_filial, nf_numero with curImpressaoNF.nf_numero, ;
			serie_nf with curImpressaoNF.serie_nf

		local intCounter as integer, evlValor as string, evlVencimento as string
		intCounter = 1
		scan
			evlValor = "valor_" + transform(intCounter)
			evlVencimento = "vencimento_" + transform(intCounter)

			select curNFFinanceiro
			replace &evlValor with curVendaParcelas.valor, &evlVencimento with curVendaParcelas.vencimento

			intCounter = intCounter + 1
			if intCounter > 12
				exit
			endif
		endscan
	else
		select curImpressaoNF
		scan
			select curNFFinanceiro
			append blank
			replace codigo_filial with curImpressaoNF.codigo_filial, nf_numero with curImpressaoNF.nf_numero, ;
				serie_nf with curImpressaoNF.serie_nf, vencimento_1 with curImpressaoNF.data_saida, valor_1 with curImpressaoNF.valor_total
		endscan
	endif

	return .t.
ENDFUNC 




FUNCTION F_Load_Ctrl_Excecao()
	local intAlias as integer, strExcecao as string, strCodigoFilial as string, strNFNumero as string, strSerieNF as string

	intAlias = select()

	strExcecao = ""

	strCodigoFilial = curImpressaoNFItens.codigo_filial
	strNFNumero = curImpressaoNFItens.nf_numero
	strSerieNF = curImpressaoNFItens.serie_nf

	select distinct id_excecao_imposto from curImpressaoNFItens ;
		where codigo_filial = strCodigoFilial and nf_numero = strNFNumero and serie_nf = strSerieNF ;
		and id_excecao_imposto is not null into cursor cur_distinct_excecao

	select cur_distinct_excecao
	scan
		if !SQLSelect("SELECT TEXTO_LEGAL FROM CTB_EXCECAO_IMPOSTO_ITEM WHERE ID_EXCECAO_IMPOSTO = ?cur_distinct_excecao.id_excecao_imposto order by 1", "cur_excecao", "Não foi possível pesquisar a exceção")
			return .f.
		endif
		select cur_excecao
		scan for !empty(nvl(texto_legal, "")) and atc(alltrim(texto_legal), strExcecao) == 0
			strExcecao = strExcecao + iif(empty(nvl(strExcecao, "")), "", chr(13)) + alltrim(texto_legal)
		endscan
	endscan

	select (intAlias)

	return alltrim(strExcecao)
ENDFUNC 




FUNCTION F_NF_GetCF(strCodClassif as string)
	local intAlias as integer, strReturn as string

	intAlias = select()

	if type("strCodClassif") != "C"
		strReturn = alltrim(curImpressaoNF.classificacoes)
	else
		select distinct classif_fiscal from curImpressaoNFItens ;
			where codigo_filial = curImpressaoNF.codigo_filial and nf_numero = ?curImpressaoNF.nf_numero ;
			and serie_nf = ?curImpressaoNF.serie_nf and classif_reduzida = strCodClassif ;
			into cursor cur_result_CF

		strReturn = alltrim(cur_result_CF.classif_fiscal)

		use in cur_result_CF
	endif

	select (intAlias)

	return nvl(strReturn, main.general.Translate("(nulo)"))
ENDFUNC




FUNCTION F_NF_GetCF_Geral(strCodClassif as string)
	local intAlias as integer, strReturn as string

	intAlias = select()

	select distinct classif_reduzida, classif_fiscal from curImpressaoNFItens order by classif_reduzida into cursor cur_result_CF
	select cur_result_CF
	scan
		strReturn = iif(empty(strReturn), ;
			alltrim(cur_result_CF.classif_reduzida) + "-" + alltrim(cur_result_CF.classif_fiscal), ;
			alltrim(strReturn) + " ; " + alltrim(cur_result_CF.classif_reduzida) + "-" + alltrim(cur_result_CF.classif_fiscal))
	endscan

	select (intAlias)

	replace all classificacoes with nvl(strReturn, main.general.Translate("(nulo)"))

	return .t.
ENDFUNC 




FUNCTION F_Invert_Field()
	parameters strField
	local strResult
	if ! type("strField") $ "NIC"
		return(strField)
	endif
	if type("xField") $ "NI"
		strField = str(strField)
	endif
	strField = alltrim(strField)
	strResult = ''
	for k = len(strField) to 1 step -1
		strResult = strResult + substr(strResult, k, 1)
	endfor

	return (strResult)
ENDFUNC 
