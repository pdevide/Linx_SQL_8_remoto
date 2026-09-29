*-- Objetivo : Funcões Para Faturamento Linx Com CTB+Loja Atacado ( Versão >= 5.00.000 )
*-- Desenv by: Célula Reports (Valmir): CTB=Jun-2003 / Atacado=Jun-2007
*---------------------------------------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------------------------------------*
FUNCTION F_Load_Ctrl_NF_Form() && Form Control

	SELECT vtmp_impressao_nf_00_itens
	INDEX ON filial+nf+serie_nf+item_impressao tag iItem
	do whil !eof()
		xKey   = filial+nf+serie_nf
		xFrm   = 1
		xCount = 0
		scan whil filial+nf+serie_nf=xKey 
			xCount = xCount+1
			IF xCount > o_100108.pp_itens_p_nota
				xFrm   = xFrm + 1
				xCount = 1
			ENDIF
			Replace n_form WITH xFrm
		endscan
	enddo
	select distinct filial,nf,serie_nf,max(n_form) as t_forms group by filial,nf,serie_nf from vtmp_impressao_nf_00_itens into cursor cur_frmt
	sele cur_frmt
	go top
	SCAN
		sele vtmp_impressao_nf_00_itens
		Replace all t_form with cur_frmt.t_forms for filial=cur_frmt.filial and nf=cur_frmt.nf and serie_nf=cur_frmt.serie_nf
	ENDSCAN

RETURN .t.
*---------------------------------------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------------------------------------*
FUNCTION F_Load_Ctrl_NF_Financ()
LPARAMETERS xTipoConf

	LOCAL xFields as Character, k as Character, k_ as Character 
	STORE '' TO xFields
	FOR k = 1 TO 48
		k_ = ALLTRIM(STR(k))
		xFields = xFields + IIF(EMPTY(xFields),'',',') + ;
				  'space(2) as id_parc'+k_ + ', 000000000.00 as val_parc'+k_ + ', {} as venc_parc'+k_
	ENDFOR

	IF USED('v_impressao_nf_00') && Impressão de NF
		Select Distinct ctb_lancamento, ctb_item, fatura, nf, serie_nf, filial, nome_clifor, SPACE(LEN(fatura)) as fatura_conf, &xFields ;
		  From v_impressao_nf_00 Into Cursor cur_ctb_parcelas ReadWrite
	ELSE && Classe
		Select Distinct ctb_lancamento, numero_conferencia, ctb_item, fatura, nf_saida as nf, serie_nf, filial, nome_clifor, SPACE(LEN(fatura)) as fatura_conf, &xFields ;
		  From v_faturamento_05 Into Cursor cur_ctb_parcelas ReadWrite
	ENDIF

	SELECT cur_ctb_parcelas 
	GO top
	SCAN
		IF TYPE('wDesativa_Financeiro')<>'U' AND wDesativa_Financeiro
			IF ISNULL(cur_ctb_parcelas.fatura) and cur_ctb_parcelas.ctb_lancamento=0 && Identifica Origem Loja Atacado
				REPLACE cur_ctb_parcelas.fatura WITH cur_ctb_parcelas.nf
*				F_SELECT('Select nf_saida as fatura,convert(char(2),parcela) parcela,valor_original as valor,vencimento From Faturamento_Pgto where nf_saida=?cur_ctb_parcelas.nf and serie_nf=?cur_ctb_parcelas.serie_nf and filial=?cur_ctb_parcelas.filial','cur_parc')
				F_SELECT("Select nf_saida as fatura,convert(char(2),parcela) parcela,valor_original as valor,vencimento From Faturamento_Pgto where nf_saida=?cur_ctb_parcelas.nf and serie_nf=?cur_ctb_parcelas.serie_nf and filial=?cur_ctb_parcelas.filial and tipo_movimento='1'",'cur_parc')				
			ELSE
				xLanc = IIF(xTipoConf,cur_ctb_parcelas.numero_conferencia,cur_ctb_parcelas.ctb_lancamento)
				f_select('select fatura,id_parcela as parcela,valor_original as valor,vencimento_real as vencimento from w_ctb_a_receber_parcela where lancamento=?xLanc and item=?cur_ctb_parcelas.ctb_item order by id_parcela','cur_parc')
			ENDIF
		ELSE
			xFatura = IIF(xTipoConf,cur_ctb_parcelas.numero_conferencia,cur_ctb_parcelas.fatura)
			f_select('select fatura,parcela,valor_original as valor,vencimento from a_receber_parcelas where nome_clifor=?cur_ctb_parcelas.nome_clifor and fatura=?xFatura order by parcela','cur_parc') && or fatura=?xFatura_Tipo2
		ENDIF

		SELE cur_parc
		GO top
		SELE cur_ctb_parcelas
		REPLACE fatura_conf WITH NVL(cur_parc.fatura,'')
		
		SELE cur_parc
		xi_parc = 0
		SCAN WHILE !EOF() AND xi_parc<48
			xi_parc = xi_parc + 1
			xi		= ALLTRIM(str(xi_parc))
			SELE cur_ctb_parcelas 
			Replace id_parc&xi   WITH NVL(cur_parc.parcela,''), ;
					val_parc&xi  WITH NVL(cur_parc.valor,0),;
					venc_parc&xi WITH NVL(cur_parc.vencimento,{})
			SELE cur_parc
		ENDSCAN

		SELE cur_ctb_parcelas
	ENDSCAN

RETURN .t.
*---------------------------------------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------------------------------------*
FUNCTION F_Load_Ctrl_Excecao()
	LOCAL xExcecao,xalias,xNfAtual,xSrAtual,xFlAtual

	xalias   = ALIAS()
	xExcecao = ''
	xNfAtual = vtmp_impressao_nf_00_itens.Nf
	xSrAtual = vtmp_impressao_nf_00_itens.Serie_nf
	xFlAtual = vtmp_impressao_nf_00_itens.Filial

	SELECT distinct id_excecao_imposto FROM vtmp_impressao_nf_00_itens ;
	 WHERE nf=?xNfAtual AND Serie_nf=?xSrAtual AND Filial=?xFlAtual AND id_excecao_imposto is NOT null INTO CURSOR cur_distinct_excecao
	SELECT cur_distinct_excecao
	GO top
	SCAN
		f_select('select texto_legal FROM CTB_EXCECAO_IMPOSTO_ITEM where id_excecao_imposto=?cur_distinct_excecao.id_excecao_imposto order by 1','cur_excecao')
		SELECT cur_excecao
		GO top
		SCAN
			IF !f_vazio(texto_legal)
				IF !(ALLTRIM(texto_legal) $ xExcecao)
					xChr = IIF(f_vazio(xExcecao),'',CHR(13))
					xExcecao = xExcecao + xChr + ALLTRIM(texto_legal)
				ENDIF
			ENDIF
		ENDSCAN

		SELECT cur_distinct_excecao
	ENDSCAN

	SELECT (xalias)
RETURN ALLTRIM(xExcecao)
*---------------------------------------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------------------------------------*
FUNCTION F_NF_GetCF()
LPARAMETERS xCodClas

	LOCAL xReturn, xSele
	xSele = SELECT()

	IF TYPE('xCodClas')<>'C'
		xReturn = ALLTRIM(v_impressao_nf_00.classificacoes)
	ELSE
		SELECT DISTINCT classif_fiscal FROM vtmp_impressao_nf_00_itens ;
				  WHERE filial=?v_impressao_nf_00.filial AND nf=?v_impressao_nf_00.nf ;
				  	AND serie_nf=?v_impressao_nf_00.serie_nf AND classif_reduzida=?xCodClas ;
			INTO CURSOR Cur_Result_CF
		xReturn = ALLTRIM(Cur_Result_CF.classif_fiscal)
		SELECT Cur_Result_CF
		USE
	ENDIF

	SELECT (xSele)
RETURN IIF(isnull(xReturn),'...',xReturn)
*---------------------------------------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------------------------------------*
FUNCTION F_Invert_Field()
PARAMETERS xField

	LOCAL xResult

	if ! type('xField') $ 'NIC'
		Return(xField)
	endif

	if type('xField') $ 'NI'
		xField= str(xField)
	endif
	xField= allt(xField)

	xResult = ''
	for k = len(xField) to 1 step -1
		xResult=xResult+subs(xField,k,1)
	endfor

Return (xResult)
*---------------------------------------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------------------------------------*
FUNCTION F_Filtro_Acesso()

	if !wAcesso_Esp_2
		=f_msg( ['Não Há Informações Válidas, Verifique Seu Nível de Acesso',48,'< A v i s o >'] )
		Return .f.
	endif

	*-- Verifica se a informação é do tipo 1/2/Sem
	sele v_faturamento_05
	set filt to !isnull(timestamp)
	go top
	if eof()
		=f_msg( ['Não Há Informações Válidas (Campo Nulo)',48,'< A v i s o >'] )
		Return .f.
	endif

	*-- Verifica houve alteração ( e consequentemente perda da condição de nulo )
	set filt to !isnull(timestamp) and !empty(timestamp)
	go top
	if eof()
		=f_msg( ['Não Há Informações Válidas (Campo Nulo ou Vazio)',48,'< A v i s o >'] )
		Return .f.
	endif

RETURN .t.
*---------------------------------------------------------------------------------------------------------------------------------------------------*
