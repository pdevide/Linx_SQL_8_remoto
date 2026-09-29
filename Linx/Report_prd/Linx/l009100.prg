*--- Funções Extras - para modulo de contabilidade (uso em diveros reports)
*--- Lx-Valmir | Desenv: Mai-2002 | Novas Funções: Mai-2005 | Adaptado para Cursor(ver.7): Ago-2007 |
*---------------------------------------------------------------------------------------------------------------------------------------------------*


*---------------------------------------------------------------------------------------------------------------------------------------------------*
Procedure lx_gerar_tabelas_dbf
Param xtipo,xObj

	*--- Parâmetros Extras
	*/do FORM lxoprel_ctb
	SYSTEM.ExecuteFormModal('lxoprel_ctb')

	IF !xOkCont
		RETURN .f.
	ENDIF

	*/xIs_View = ( 'VISUALLINX6' $ UPPER(wUserTempPath))
	  xIs_View = .f.
	
	if used('v_ctb_lancamento_01') and used('v_ctb_lancamento_01_item')
		*--- popula principal
		f_popula_filha('v_ctb_lancamento_01','v_ctb_lancamento_01_item',,,'00000 as NI, 00000 as NI_a, 00000 as NI_b,0000 as Jur_dias,000.00 as Jur_perc,00000000000.00 as credito_dif,00000000000.00 as debito_dif','lx_calc_DJ()')
		
		*--Exclusivo: MM
			SELECT vTmp_ctb_lancamento_01_item
			REPLACE ALL credito_dif WITH credito,debito_dif WITH debito FOR INLIST(lx_tipo_lancamento,'ECH')
		*--

		=lx_gerar_filhas() && filhas/netas
		=lx_gerar_origem_item()    && nivel de origem - item
		xObj.CopyTables("v_ctb_lancamento_01")
		xObj.CopyTables("vtmp_ctb_lancamento_01_item") 
	else
		f_msg(['Esta não é uma tela válida para este relatório...',16,'Atenção'])
		Return .f.
	endif

Return .t.
*---------------------------------------------------------------------------------------------------------------------------------------------------*


*---------------------------------------------------------------------------------------------------------------------------------------------------*
Procedure lx_gerar_filhas

	Declare xView(15,2)
	*--- ITR (Filha/Neta)
	xView(1,1) = 'xv_ctb_lancamento_01_a_receber'
	xView(1,2) = 'xv_ctb_lancamento_01_a_receber_parcelas'

	*--- BTR
	xView(2,1) = 'xv_ctb_lancamento_01_baixa_receber'
	xView(2,2) = ''

	*--- ITP (Filha/Neta)
	xView(3,1) = 'xv_ctb_lancamento_01_a_pagar'
	xView(3,2) = 'xv_ctb_lancamento_01_a_pagar_parcelas'

	*--- BTP
	xView(4,1) = 'xv_ctb_lancamento_01_baixa_pagar'
	xView(4,2) = ''

	*--- IAC
	xView(5,1) = 'xv_ctb_lancamento_01_aviso_credito'
	xView(5,2) = ''

	*--- BAC
	xView(6,1) = 'xv_ctb_lancamento_01_baixa_aviso_credito'
	xView(6,2) = ''

	*--- IAD
	xView(7,1) = 'xv_ctb_lancamento_01_aviso_debito'
	xView(7,2) = ''

	*--- BAD
	xView(8,1) = 'xv_ctb_lancamento_01_baixa_aviso_debito'
	xView(8,2) = ''

	*--- ECH
	xView(9,1) = 'xv_ctb_lancamento_01_cheque'
	xView(9,2) = ''

	*--- ICH
	xView(10,1) = 'xv_ctb_lancamento_01_a_receber_cheque'
	xView(10,2) = ''

	*--- ICR 
	xView(11,1) = 'xv_ctb_lancamento_01_a_receber_cartao'
	xView(11,2) = ''

	*--- BCH
	xView(12,1) = 'xv_ctb_lancamento_01_baixa_cheque_receber'
	xView(12,2) = ''

	*--- BCR
	xView(13,1) = 'xv_ctb_lancamento_01_baixa_cartao_receber'
	xView(13,2) = ''

	*--- RRC/ECP - bordero
	xView(14,1) = 'xv_ctb_lancamento_01_bordero'
	xView(14,2) = ''

	*--- RRC/ECP - parcelas
	xView(15,1) = 'xv_ctb_lancamento_01_bordero_rec_parc'
	xView(15,2) = ''

	for k = 1 to alen(xView,1)
		cMessage = string.translate("Processando : {0} {1}", xView(k, 1), iif(empty(xView(k, 2)), '', string.translate("{0}Filha :{1}", chr(13), xView(k, 2))))
		Messagebox.ShowProgress(cMessage, alen(xView, 1),,.t.)
		=lx_gerar_filhas_tmp(xView(k,1),xView(k,2))
	endfor
	
	Messagebox.ShowProgress()

RETURN .T.
*---------------------------------------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------------------------------------*
Procedure lx_gerar_filhas_tmp
Parameters xView_Filha,xView_Neta


	xView_Filha_Rel = xView_Filha+'_Rel'
	xView_Neta_Rel  = xView_Neta +'_Rel'
	
	STORE '' TO xStrCurFilha,xStrCurNeta

	if empty(xView_Filha)
		return .f.
	else
		*--- structure / filha 
		xCursor_filha = allt(subs(xView_Filha,2,1)+'tmp'+subs(xView_Filha,3,200))
		x_Filha_Used = used(xView_Filha)

			IF xIs_View && Views
				use in 0 (xView_Filha) nodata
				SELECT * from (xView_Filha) WHERE .f. into cursor &xCursor_filha readwrite
			ELSE && Cursor Adapter
				xStrCurFilha = Lx_Set_Stru_Cursor(xView_Filha)
				f_select(xStrCurFilha,xView_Filha_Rel,ALIAS())

				SELECT &xView_Filha_Rel
					=afields(xnovo)
					for j = 1 to alen(xnovo,1)
						xnovo(j,5) = .t.  && Setar Campos Para Aceitar Nulo Sempre
					endfor
				CREATE cursor &xCursor_filha from array xnovo
			ENDIF
	endif

	*--- structure / Neta
	if !empty(xView_Neta)
	    xCursor_neta = allt(subs(xView_Neta,2,1)+'tmp'+subs(xView_Neta,3,200))
		x_Neta_Used = used(xView_Neta)

			IF xIs_View && Views
				use in 0 (xView_Neta) nodata
				SELECT * from (xView_Neta)  WHERE .f. into cursor &xCursor_neta readwrite
			ELSE && Cursor Adapter
				xStrCurNeta = Lx_Set_Stru_Cursor(xView_Neta)
				f_select(xStrCurNeta,xView_Neta_Rel,ALIAS())
				
				SELECT &xView_Neta_Rel
					=afields(xnovo)
					for j = 1 to alen(xnovo,1)
						xnovo(j,5) = .t.  && Setar Campos Para Aceitar Nulo Sempre
					endfor
				CREATE cursor &xCursor_neta from array xnovo
			ENDIF
	endif

	if xOpen_SR
		*--- gerar dados / requery()
		sele v_ctb_lancamento_01
		COUNT TO xTRegLanc
		xRAtuLanc = 0

		go top
		SCAN 
			xRAtuLanc = xRAtuLanc + 1

			IF xIs_View
				sele (xView_Filha)
				xBuff = CursorGetProp('buffering')
				TableRevert(.t.)
				CURSORSETPROP('buffering',3)
				requery()
			ELSE
				f_select(xStrCurFilha,xView_Filha)
			ENDIF

			COUNT TO xTRegFilha
			xRAtuFilha = 0
			xTRegNeta  = 0

			go top
			SCAN 
				xRAtuFilha = xRAtuFilha + 1
				wait wind 'Processando... ' + xView_Filha + CHR(13) + ;
						  'Lançamento: ' + ALLTRIM(STR(v_ctb_lancamento_01.lancamento)) + ' > '+ allt(str(xRAtuLanc/xTRegLanc*100))+'%' + ;
						  '   -  Item: ' + allt(str(xRAtuFilha/xTRegFilha*100))+'% Concluido' nowait
				scatter memvar
				insert into (xCursor_filha) from memvar
				
				if !empty(xView_Neta)
					IF xIs_View
						sele (xView_Neta)
						TableRevert(.t.)
						requery()
					ELSE
						f_select(xStrCurNeta,xView_Neta)
					ENDIF
					
					IF xView_Neta = 'xv_ctb_lancamento_01_a_receber_parcelas' AND EMPTY(SET('filter'))
						SET filter TO ITEM=xv_ctb_lancamento_01_a_receber.ITEM
					ENDIF
					COUNT TO xTRegNeta
					
					go top
					scan
						scatter memvar
						insert into (xCursor_neta) from memvar
					endscan
				endif
				
				sele (xView_Filha)
			ENDSCAN 

			IF xIs_View
				sele (xView_Filha)
				CURSORSETPROP('buffering',xBuff)
			ENDIF
			
			=lx_reg_num_itens(v_ctb_lancamento_01.lancamento,xTRegFilha,'NI')
			sele v_ctb_lancamento_01
		ENDSCAN

		*--- fecha views abertas
		if !empty(xView_Filha) AND !x_Filha_Used AND USED('xView_Filha_Rel')
			sele (xView_Filha_Rel)
			use
		ELSE
			*--- volta posião
				sele v_ctb_lancamento_01
				GO top

				IF xIs_View
					sele (xView_Filha)
					requery()
				ENDIF
			*---	
		ENDIF 

		IF !empty(xView_Neta) AND !x_Neta_Used AND USED('xView_Neta_Rel')
			sele (xView_Neta_Rel)
			use
		ENDIF 

	ENDIF 

	*--- copia para cristal
	xCursor_alias = SUBSTR(xView_Filha,2,LEN(xView_Filha))
	xObj.CopyTables(xCursor_filha,xCursor_alias)

	if !empty(xView_Neta)
		xCursor_alias = SUBSTR(xView_Neta,2,LEN(xView_Neta))
		xObj.CopyTables(xCursor_neta,xCursor_alias)
	endif

Return .t.
*---------------------------------------------------------------------------------------------------------------------------------------------------*


*---------------------------------------------------------------------------------------------------------------------------------------------------*
Procedure lx_gerar_origem_item

	STORE '' TO xStrCur_ch,xStrCur_ct,xStrCur__br

	*------- Structure - Item
	select *,lancamento as lanc_origem,item as it_origem from v_ctb_lancamento_01_item into cursor cur_stru where .f.
		sele cur_stru
		afields(xFields)
		for j = 1 to alen(xFields,1)
			xFields(j,5) = .t.  && Setar Campos Para Aceitar Nulo Sempre
		endfor
		create cursor vtmp_ctb_lancamento_01_item_nivel_a from array xFields

	*------- Structure - a Receber Cheque
	xView_ch   = 'xv_ctb_lancamento_01_a_receber_cheque'
	xCursor_ch = 'vtmp_ctb_lancamento_01_a_receber_cheque_nivel_b'
	xUsed_ch   = used(xView_ch)
	if !xUsed_ch
		IF xIs_View && Views
			use in 0 (xView_ch) nodata
		ELSE && Cursor Adapter
			xStrCur_ch = Lx_Set_Stru_Cursor(xView_ch)
			f_select(xStrCur_ch,xView_ch,ALIAS())
		ENDIF
	endif

	select *,lancamento as lanc_origem,item as it_origem from &xView_ch into cursor cur_stru where .f.
		sele cur_stru
		afields(xFields)
		for j = 1 to alen(xFields,1)
			xFields(j,5) = .t.  && Setar Campos Para Aceitar Nulo Sempre
		endfor
		create cursor (xCursor_ch) from array xFields

	*------- Structure - a Receber Cartao
	xView_ct   = 'xv_ctb_lancamento_01_a_receber_cartao'
	xCursor_ct = 'vtmp_ctb_lancamento_01_a_receber_cartao_nivel_b'
	xUsed_ct   = used(xView_ct)
	if !xUsed_ct
		IF xIs_View && Views
			use in 0 (xView_ct) nodata
		ELSE && Cursor Adapter
			xStrCur_ct = Lx_Set_Stru_Cursor(xView_ct)
			f_select(xStrCur_ct,xView_ct,ALIAS())
		ENDIF
	endif

	select *,lancamento as lanc_origem,item as it_origem from &xView_ct into cursor cur_stru where .f.
		sele cur_stru
		afields(xFields)
		for j = 1 to alen(xFields,1)
			xFields(j,5) = .t.  && Setar Campos Para Aceitar Nulo Sempre
		endfor
		create cursor (xCursor_ct) from array xFields

	*------- Structure - baixa-receber
	xView_br   = 'xv_ctb_lancamento_01_baixa_receber'
	xCursor_br = 'vtmp_ctb_lancamento_01_baixa_receber_nivel_b'
	xUsed_br   = used(xView_br)
	if !xUsed_br
		IF xIs_View && Views
			use in 0 (xView_br) nodata
		ELSE && Cursor Adapter
			xStrCur_br = Lx_Set_Stru_Cursor(xView_br)
			f_select(xStrCur_br,xView_br,ALIAS())
		ENDIF
	endif
	select *,lancamento as lanc_origem,item as it_origem from &xView_br into cursor cur_stru where .f.
		sele cur_stru
		afields(xFields)
		for j = 1 to alen(xFields,1)
			xFields(j,5) = .t.  && Setar Campos Para Aceitar Nulo Sempre
		endfor
		create cursor (xCursor_br) from array xFields


	*------- Dados
	if xOpen_SR and xOpen_Na
		IF !USED('vtmp_ctb_lancamento_01_baixa_aviso_credito') AND !USED('vtmp_ctb_lancamento_01_baixa_aviso_debito')
			RETURN .f.
		ENDIF 
		
		sele v_ctb_lancamento_01
		go top

		*--- lancamentos item nivel A
		SELECT lancamento,item,lancamento_mov,item_mov from vtmp_ctb_lancamento_01_baixa_aviso_credito ;
		 union ;
		select lancamento,item,lancamento_mov,item_mov from vtmp_ctb_lancamento_01_baixa_aviso_debito into cursor lanc_cd
		
		select distinct lancamento,item,lancamento_mov,item_mov from lanc_cd into cursor lanc_nivel

		*--- gravar it
		sele lanc_nivel
		go top
		scan
			sele v_ctb_lancamento_01
			replace lancamento with lanc_nivel.lancamento_mov

			*--- Item nivel a
			sele v_ctb_lancamento_01_item
			requery()
			COUNT TO xTotReg_a
			
			go top
			scan
				scatter memvar
				insert into vtmp_ctb_lancamento_01_item_nivel_a from memvar
				sele vtmp_ctb_lancamento_01_item_nivel_a
				replace lanc_origem with lanc_nivel.lancamento,it_origem with lanc_nivel.item
			endscan
			=lx_reg_num_itens(lanc_nivel.lancamento,xTotReg_a,'NI_a')
		
			*--- 
			if xOpen_Nb

				*
				IF xIs_View
					sele (xView_ch)
					requery()
				ELSE
					IF !xUsed_ch AND !EMPTY(xStrCur_ch)
						f_select(xStrCur_ch,xView_ch)
					ELSE
						sele (xView_ch)
						REQUERY()
					ENDIF
				ENDIF

			
				COUNT TO xTotReg_ch
				go top
				scan
					scatter memvar
					insert into (xCursor_ch) from memvar
					sele (xCursor_ch)
					replace lanc_origem with lanc_nivel.lancamento,it_origem with lanc_nivel.item
				endscan

				*

				IF xIs_View
					sele (xView_ct)
					requery()
				ELSE
					IF !xUsed_ct AND !EMPTY(xStrCur_ct)
						f_select(xStrCur_ct,xView_ct)
					ELSE
						sele (xView_ct)
						REQUERY()
					ENDIF
				ENDIF

				COUNT TO xTotReg_ct
				go top
				scan
					scatter memvar
					insert into (xCursor_ct) from memvar
					sele (xCursor_ct)
					replace lanc_origem with lanc_nivel.lancamento,it_origem with lanc_nivel.item
				endscan

				*
				
				IF xIs_View
					sele (xView_br)
					requery()
				ELSE
					IF !xUsed_br AND !EMPTY(xStrCur_br)
						f_select(xStrCur_br,xView_br)
					ELSE
						sele (xView_br)
						REQUERY()
					ENDIF
				ENDIF

				COUNT TO xTotReg_br
				go top
				scan
					scatter memvar
					insert into (xCursor_br) from memvar
					sele (xCursor_br)
					replace lanc_origem with lanc_nivel.lancamento,it_origem with lanc_nivel.item
				endscan
				*
				
				=lx_reg_num_itens(lanc_nivel.lancamento,xTotReg_ch+xTotReg_br,'NI_b')
			endif
			*---

			sele lanc_nivel
		endscan

		sele v_ctb_lancamento_01_item
		set filter to

		sele v_ctb_lancamento_01
		tablerevert(.t.) && volta lancamento original
	endif

	if !xUsed_ch
		sele (xView_ch)
		use
	endif
	if !xUsed_ct
		sele (xView_ct)
		use
	endif
	if !xUsed_br
		sele (xView_br)
		use
	endif

	xObj.CopyTables('vtmp_ctb_lancamento_01_item_nivel_a')
	xObj.CopyTables(xCursor_ch)
	xObj.CopyTables(xCursor_ct)
	xObj.CopyTables(xCursor_br)

Return .t.
*---------------------------------------------------------------------------------------------------------------------------------------------------*


*---------------------------------------------------------------------------------------------------------------------------------------------------*
PROCEDURE lx_reg_num_itens
PARAMETERS xLanc,xNItens,xNivel

	IF xNItens > 0
		SELECT vtmp_ctb_lancamento_01_item
		replace ALL &xNivel WITH xNItens FOR lancamento = xLanc
	ENDIF
	
RETURN
*---------------------------------------------------------------------------------------------------------------------------------------------------*


*---------------------------------------------------------------------------------------------------------------------------------------------------*
PROCEDURE lx_calc_DJ && Calc Juros

	IF lx_tipo_lancamento <> 'LJR'
		RETURN .f.
	ENDIF

	xAlias_Ori = ALIAS()
	xRecno_Ori = RECNO()

	xSelDts = 'select vencimento from ctb_aviso_lancamento_mov a join ctb_aviso_lancamento b on ' + ;
			  '       a.empresa = b.empresa and a.lancamento_mov = b.lancamento and a.item_mov = b.item ' + ;
			  ' where a.empresa=?v_ctb_lancamento_01.empresa and ' + ;
			  '       a.lancamento=?v_ctb_lancamento_01.lancamento and a.item=?v_ctb_lancamento_01_item.item '

	SELE v_ctb_lancamento_01_item
	xrec_psq  = RECNO()
	xJur_Val  = (credito - debito)
	xVal_BAD  = 0

	locate for lx_tipo_lancamento = "BAC"
	IF EOF()
		GOTO (xrec_psq)
		SELECT(xAlias_Ori)
		GOTO (xRecno_Ori)
		RETURN .f.
	ELSE
		f_select(xSelDts,'cur_BAC')
	ENDIF

	SELE v_ctb_lancamento_01_item
	locate for lx_tipo_lancamento = "BAD"
	IF EOF()
		GOTO (xrec_psq)
		SELECT(xAlias_Ori)
		GOTO (xRecno_Ori)
		RETURN .f.
	ELSE
		xVal_BAD  = (credito - debito)
		f_select(xSelDts,'cur_BAD')
	ENDIF

	SELE v_ctb_lancamento_01_item
	GOTO (xrec_psq)

	SELECT(xAlias_Ori)
	GOTO (xRecno_Ori)

	IF xJur_Val<>0 AND xVal_BAD<>0
		xJur_Dias = TTOD(cur_BAC.vencimento) - TTOD(cur_BAD.vencimento)
		xJur_Perc = ((xJur_Val/xVal_BAD)/xJur_Dias)*100
		Replace Jur_dias WITH xJur_Dias,;
				Jur_perc WITH xJur_Perc
	endif

RETURN .t.
*---------------------------------------------------------------------------------------------------------------------------------------------------*


*---------------------------------------------------------------------------------------------------------------------------------------------------*
FUNCTION Fx_Char_Diagonal
LPARAMETERS pChar,pNRep,pVl_Inc,pVl_Max

	*--- Objetivo: No final do report mostrar linha de caracter (na diagonal)
	*---  Exemplo: =Fx_Char_Diagonal('***',34,4)

	Fx_Incremento()
	xRet = pChar + chr(13)
	FOR y = 1 TO pNRep
		xRet = xRet + Space(Fx_Incremento(pVl_Inc,pVl_Max)) + pChar + chr(13)
	ENDFOR

RETURN (xRet)
*---------------------------------------------------------------------------------------------------------------------------------------------------*


*---------------------------------------------------------------------------------------------------------------------------------------------------*
*--- Incremento

FUNCTION Fx_Incremento
LPARAMETERS pVl_Inc,pVl_Max

	if TYPE('pVl_Inc')<>'N' OR TYPE('xVl_Incremento')<>'N'
		RELEASE xVl_Incremento
		PUBLIC  xVl_Incremento
		STORE 0 TO xVl_Incremento
	ELSE
		xVl_Incremento = xVl_Incremento + pVl_Inc
	ENDIF

	IF TYPE('pVl_Max')='N' AND xVl_Incremento>(pVl_Max*pVl_Inc)
		STORE 0 TO xVl_Incremento
	ENDIF

RETURN (xVl_Incremento)
*---------------------------------------------------------------------------------------------------------------------------------------------------*


*---------------------------------------------------------------------------------------------------------------------------------------------------*
Procedure Lx_Set_Stru_Cursor
Parameters xView_Cursor

	DO CASE 
	*--: Lista de filhas
	
	CASE xView_Cursor == 'xv_ctb_lancamento_01_a_receber'
		TEXT TO xStruCursor NOSHOW 
		   SELECT Ctb_a_receber_fatura.EMPRESA, Ctb_a_receber_fatura.LANCAMENTO,Ctb_a_receber_fatura.COD_EMISSOR, Ctb_a_receber_fatura.ITEM,  
		   		  Ctb_a_receber_fatura.COD_CLIFOR,  Ctb_a_receber_fatura.LX_TIPO_DOCUMENTO,  Ctb_a_receber_fatura.FATURA_IMPRESSA, 
		   		  Ctb_a_receber_fatura.SERIE, Ctb_a_receber_fatura.DOCUMENTO, Ctb_a_receber_fatura.FATURA,  Ctb_a_receber_fatura.MOEDA, 
		   		  Ctb_a_receber_fatura.EMISSAO,  Ctb_a_receber_fatura.POSSUI_SAIDA,  Ctb_a_receber_fatura.PORCENTAGEM_ACERTO,  
		   		  Ctb_a_receber_fatura.COMISSAO_GERENTE, Ctb_a_receber_fatura.COMISSAO,  Ctb_PARCELA.CAMBIO_NA_DATA_EMISSAO,  
		   		  Ctb_a_receber_fatura.JUROS_POR_ATRASO,  Ctb_a_receber_fatura.MULTA_POR_ATRASO,  Ctb_a_receber_fatura.NUMERO_PARCELAS,  
		   		  Ctb_a_receber_fatura.COD_REPRESENTANTE,  Ctb_a_receber_fatura.COD_REPRESENTANTE_GERENTE,  Ctb_lx_documento_tipo.TIPO_DOCUMENTO,  
		   		  Cadastro_cli_for.NOME_CLIFOR AS nome_emissor,  Cadastro_cli_for.RAZAO_SOCIAL, Cadastro_cli_for.CGC_CPF,  Cadastro_cli_for.TELEFONE1, 
		   		  Cadastro_cli_for.DDD1,  Cadastro_cli_for_a.NOME_CLIFOR, Cadastro_cli_for_a.RAZAO_SOCIAL,  Cadastro_cli_for_a.CGC_CPF, 
		   		  Cadastro_cli_for_a.TELEFONE1,  Cadastro_cli_for_a.DDD1,  Ctb_a_receber_fatura.CODIGO_CONSUMIDOR,  Clientes_varejo.CLIENTE_VAREJO, 
		   		  Clientes_varejo.ENDERECO,  Clientes_varejo.PF_PJ, Clientes_varejo.RG_IE, Clientes_varejo.CPF_CGC,  
		   		  Clientes_varejo.CIDADE, Clientes_varejo.COMPLEMENTO,  Clientes_varejo.TELEFONE, Clientes_varejo.DDD, Clientes_varejo.UF,  
		   		  Clientes_varejo.EMAIL,  Representantes.REPRESENTANTE AS nome_representante,  Representantes_a.REPRESENTANTE AS nome_gerente 
		   	 FROM CTB_A_RECEBER_FATURA CTB_A_RECEBER_FATURA 
		   	 JOIN CADASTRO_CLI_FOR CADASTRO_CLI_FOR   ON CTB_A_RECEBER_FATURA.COD_EMISSOR = CADASTRO_CLI_FOR.COD_CLIFOR	
		   	 JOIN CADASTRO_CLI_FOR CADASTRO_CLI_FOR_A ON CTB_A_RECEBER_FATURA.COD_CLIFOR  = CADASTRO_CLI_FOR_A.COD_CLIFOR 
		   	 JOIN CTB_LX_DOCUMENTO_TIPO CTB_LX_DOCUMENTO_TIPO ON CTB_A_RECEBER_FATURA.LX_TIPO_DOCUMENTO = CTB_LX_DOCUMENTO_TIPO.LX_TIPO_DOCUMENTO 
		   	 LEFT JOIN (SELECT     EMPRESA, LANCAMENTO, ITEM, convert(numeric(20,6), convert(numeric(20,6), sum(valor_original_padrao))/convert(numeric(20,6), sum(valor_original))) as CAMBIO_NA_DATA_EMISSAO  
		   	 			  FROM CTB_A_RECEBER_PARCELA GROUP BY EMPRESA, LANCAMENTO, ITEM) CTB_PARCELA ON CTB_A_RECEBER_FATURA.EMPRESA = CTB_PARCELA.EMPRESA AND CTB_A_RECEBER_FATURA.LANCAMENTO = CTB_PARCELA.LANCAMENTO AND CTB_A_RECEBER_FATURA.ITEM = CTB_PARCELA.ITEM 
		   	 LEFT JOIN REPRESENTANTES REPRESENTANTES ON CTB_A_RECEBER_FATURA.COD_REPRESENTANTE = REPRESENTANTES.COD_REPRESENTANTE  
		   	 LEFT JOIN REPRESENTANTES REPRESENTANTES_A ON CTB_A_RECEBER_FATURA.COD_REPRESENTANTE_GERENTE = REPRESENTANTES_A.COD_REPRESENTANTE 
		   	 LEFT JOIN CLIENTES_VAREJO CLIENTES_VAREJO ON CTB_A_RECEBER_FATURA.CODIGO_CONSUMIDOR = CLIENTES_VAREJO.CODIGO_CLIENTE 
		   	WHERE (Ctb_a_receber_fatura.EMPRESA = cast(?v_ctb_lancamento_01.EMPRESA as int)   AND Ctb_a_receber_fatura.LANCAMENTO = cast(?v_ctb_lancamento_01.LANCAMENTO as int))
		ENDTEXT 


	CASE xView_Cursor == 'xv_ctb_lancamento_01_a_receber_parcelas'
	
		TEXT TO xStruCursor NOSHOW 
			SELECT Ctb_a_receber_parcela.LANCAMENTO, Ctb_a_receber_parcela.EMPRESA, Ctb_a_receber_parcela.ITEM,   Ctb_a_receber_parcela.ID_PARCELA,  
				   Ctb_a_receber_parcela.VENCIMENTO, Ctb_a_receber_parcela.NUMERO_BANCARIO,   Ctb_a_receber_parcela.VALOR_ORIGINAL,  
				   Ctb_a_receber_parcela.DIAS_PRORROGADOS,   Ctb_a_receber_parcela.DESCONTO_VENC, Ctb_a_receber_parcela.DATA_DESCONTO_VENC,  
				   Ctb_a_receber_parcela.AGENCIA,   Ctb_a_receber_parcela.VALOR_ORIGINAL_PADRAO, Ctb_conta_plano.DESC_CONTA, 
				   Ctb_a_receber_parcela.CONTA_PORTADOR,   W_moedas_conversao.cambio_atual,  W_CTB_A_RECEBER_PARCELA_SALDO.VALOR_A_RECEBER,
				   W_CTB_A_RECEBER_PARCELA_SALDO.VENCIMENTO_REAL, W_CTB_A_RECEBER_PARCELA_SALDO.VALOR_A_RECEBER_PADRAO,
				   ctb_a_receber_parcela.cambio_fixo_pgto, ctb_a_receber_parcela.INDICA_PROTESTO, ctb_a_receber_parcela.banco, bancos.nome_banco,
				   ((Ctb_a_receber_parcela.valor_original_padrao * Ctb_a_receber_parcela.DESCONTO_VENC) / 100) As Valor_Desconto_Venc   
			  FROM W_CTB_A_RECEBER_PARCELA_SALDO  
			 INNER JOIN CTB_A_RECEBER_FATURA Ctb_a_receber_fatura  
			 INNER JOIN CTB_A_RECEBER_PARCELA Ctb_a_receber_parcela  ON Ctb_a_receber_fatura.EMPRESA = Ctb_a_receber_parcela.EMPRESA AND   Ctb_a_receber_fatura.LANCAMENTO = Ctb_a_receber_parcela.LANCAMENTO AND   Ctb_a_receber_fatura.ITEM = Ctb_a_receber_parcela.ITEM 
			 INNER JOIN w_moedas_conversao W_moedas_conversao ON Ctb_a_receber_fatura.MOEDA = W_moedas_conversao.MOEDA ON  W_CTB_A_RECEBER_PARCELA_SALDO.EMPRESA = Ctb_a_receber_parcela.EMPRESA AND  W_CTB_A_RECEBER_PARCELA_SALDO.LANCAMENTO = Ctb_a_receber_parcela.LANCAMENTO AND  W_CTB_A_RECEBER_PARCELA_SALDO.ITEM = Ctb_a_receber_parcela.ITEM AND  W_CTB_A_RECEBER_PARCELA_SALDO.ID_PARCELA = Ctb_a_receber_parcela.ID_PARCELA 
			 LEFT OUTER JOIN CTB_CONTA_PLANO Ctb_conta_plano ON Ctb_a_receber_parcela.CONTA_PORTADOR = Ctb_conta_plano.CONTA_CONTABIL  
			 left join bancos on ctb_a_receber_parcela.banco=bancos.banco 
			 where (Ctb_a_receber_parcela.EMPRESA = cast(?v_ctb_lancamento_01_a_receber.empresa as int) AND  Ctb_a_receber_parcela.LANCAMENTO = cast(?v_ctb_lancamento_01_a_receber.lancamento as int)) 
			 order by ctb_a_receber_parcela.empresa, ctb_a_receber_parcela.lancamento, ctb_a_receber_parcela.item, ctb_a_receber_parcela.id_parcela
		ENDTEXT 


	CASE xView_Cursor == 'xv_ctb_lancamento_01_baixa_receber'
	
		TEXT TO xStruCursor NOSHOW 
			SELECT Ctb_a_receber_mov.EMPRESA,  Ctb_a_receber_mov.LANCAMENTO,  Ctb_a_receber_mov.ITEM,  Ctb_a_receber_mov.LANCAMENTO_MOV,  
					Ctb_a_receber_mov.ITEM_MOV,  Ctb_a_receber_mov.ID_PARCELA,  Ctb_a_receber_mov.DATA_PAGAMENTO,  Ctb_a_receber_mov.PGTO_CARTORIO,  
					Ctb_a_receber_mov.CAMBIO_NA_DATA, Ctb_a_receber_mov.VALOR_MOV,  ctb_a_receber_mov.VALOR_MULTA_GERADA,  ctb_a_receber_mov.VALOR_MULTA_PAGA,  
					ctb_a_receber_mov.VALOR_JUROS_GERADO,  ctb_a_receber_mov.VALOR_JUROS_PAGO,  ctb_a_receber_mov.DESCONTO_EFETIVADO,  
					ctb_a_receber_mov.DESCONTO_CONCEDIDO,  Ctb_a_receber_mov.VALOR_MOV_PADRAO,  ctb_a_receber_mov.VALOR_MULTA_PAGA_PADRAO,  
					ctb_a_receber_mov.VALOR_JUROS_PAGO_PADRAO,  ctb_a_receber_mov.DESCONTO_EFETIVADO_PADRAO,  CTB_A_RECEBER_PARCELA.VENCIMENTO_REAL,  
					CTB_A_RECEBER_PARCELA.VALOR_ORIGINAL,  CTB_A_RECEBER_PARCELA.VALOR_ORIGINAL_PADRAO,  CTB_A_RECEBER_PARCELA.VALOR_A_RECEBER,  
					W_CTB_A_RECEBER_PARCELA_SALDO.VALOR_A_RECEBER_PADRAO,  W_CTB_A_RECEBER_PARCELA_SALDO.SALDO_PRINCIPAL_DEVIDO,  
					W_CTB_A_RECEBER_PARCELA_SALDO.SALDO_MULTA_GERADA,  W_CTB_A_RECEBER_PARCELA_SALDO.SALDO_JUROS_GERADO,  
					W_CTB_A_RECEBER_PARCELA_SALDO.SALDO_DESCONTO_CONCEDIDO,  W_CTB_A_RECEBER_PARCELA_SALDO.TOTAL_PRINCIPAL_RECEBIDO,  
					W_CTB_A_RECEBER_PARCELA_SALDO.TOTAL_MULTA_PAGA,  W_CTB_A_RECEBER_PARCELA_SALDO.TOTAL_JUROS_PAGO,  
					W_CTB_A_RECEBER_PARCELA_SALDO.TOTAL_DESCONTO_EFETIVADO, W_CTB_A_RECEBER_PARCELA_SALDO.TOTAL_MULTA_GERADA,  
					W_CTB_A_RECEBER_PARCELA_SALDO.TOTAL_JUROS_GERADO, W_CTB_A_RECEBER_PARCELA_SALDO.TOTAL_DESCONTO_CONCEDIDO,  
					W_CTB_A_RECEBER_PARCELA_SALDO.SALDO_PRINCIPAL_DEVIDO_PADRAO,  W_CTB_A_RECEBER_PARCELA_SALDO.SALDO_MULTA_GERADA_PADRAO,  
					W_CTB_A_RECEBER_PARCELA_SALDO.SALDO_JUROS_GERADO_PADRAO,  W_CTB_A_RECEBER_PARCELA_SALDO.SALDO_DESCONTO_CONCEDIDO_PADRAO,  
					W_CTB_A_RECEBER_PARCELA_SALDO.TOTAL_PRINCIPAL_RECEBIDO_PADRAO, W_CTB_A_RECEBER_PARCELA_SALDO.TOTAL_MULTA_PAGA_PADRAO,  
					W_CTB_A_RECEBER_PARCELA_SALDO.TOTAL_JUROS_PAGO_PADRAO,  W_CTB_A_RECEBER_PARCELA_SALDO.TOTAL_DESCONTO_EFETIVADO_PADRAO, 
					W_CTB_A_RECEBER_PARCELA_SALDO.TOTAL_MULTA_GERADA_PADRAO,  W_CTB_A_RECEBER_PARCELA_SALDO.TOTAL_JUROS_GERADO_PADRAO, 
					W_CTB_A_RECEBER_PARCELA_SALDO.TOTAL_DESCONTO_CONCEDIDO_PADRAO,  CTB_A_RECEBER_FATURA.FATURA,  CTB_A_RECEBER_FATURA.SERIE,  
					CTB_A_RECEBER_FATURA.DOCUMENTO,  CTB_A_RECEBER_FATURA.EMISSAO,  CTB_A_RECEBER_FATURA.COD_EMISSOR,  CTB_A_RECEBER_FATURA.COD_CLIFOR,  
					CTB_A_RECEBER_FATURA.LX_TIPO_DOCUMENTO,  CTB_A_RECEBER_FATURA.CODIGO_CONSUMIDOR,  CTB_A_RECEBER_FATURA.MOEDA,  
					CTB_A_RECEBER_FATURA.JUROS_POR_ATRASO,  CTB_A_RECEBER_FATURA.MULTA_POR_ATRASO,  CTB_A_RECEBER_FATURA.NUMERO_PARCELAS,  
					CTB_LANCAMENTO_ITEM.CONTA_CONTABIL,   CTB_CONTA_PLANO.DESC_CONTA,  CTB_A_RECEBER_PARCELA.CONTA_PORTADOR,   
					DESC_CONTA_PORTADOR = CTB_CONTA_PLANO_PORTADOR.DESC_CONTA,  CTB_A_RECEBER_PARCELA.VENCIMENTO,  CTB_A_RECEBER_PARCELA.NUMERO_BANCARIO,  
					CTB_A_RECEBER_PARCELA.DIAS_PRORROGADOS,  CTB_A_RECEBER_PARCELA.DESCONTO_VENC,  CTB_A_RECEBER_PARCELA.AGENCIA,  
					CTB_A_RECEBER_FATURA.CAMBIO_NA_DATA_EMISSAO,  CTB_A_RECEBER_PARCELA.DATA_DESCONTO_VENC,  CTB_LX_DOCUMENTO_TIPO.TIPO_DOCUMENTO,  
					CTB_LX_DOCUMENTO_TIPO.SERIE_NF,  CTB_LX_DOCUMENTO_TIPO.NOME_RECIBO,  FILIAL = CADASTRO_CLI_FOR_FILIAIS.NOME_CLIFOR,  
					CLIENTES_VAREJO.CLIENTE_VAREJO,  CTB_LANCAMENTO_ITEM.RATEIO_CENTRO_CUSTO,  CTB_CENTRO_CUSTO_RATEIO.DESC_RATEIO_CENTRO_CUSTO, 
					CTB_LANCAMENTO_ITEM.RATEIO_FILIAL,  CTB_FILIAL_RATEIO.DESC_RATEIO_FILIAL, CADASTRO_CLI_FOR.NOME_CLIFOR,  CADASTRO_CLI_FOR.RAZAO_SOCIAL,  
					CADASTRO_CLI_FOR.DDD1,  CADASTRO_CLI_FOR.TELEFONE1 ,  
					VALOR_LIQUIDO_RECEBIDO = ((CTB_A_RECEBER_MOV.VALOR_MOV+CTB_A_RECEBER_MOV.VALOR_JUROS_PAGO+CTB_A_RECEBER_MOV.VALOR_MULTA_PAGA)-CTB_A_RECEBER_MOV.DESCONTO_EFETIVADO),  
					VALOR_LIQUIDO_DEVIDO = ((W_CTB_A_RECEBER_PARCELA_SALDO.SALDO_PRINCIPAL_DEVIDO+W_CTB_A_RECEBER_PARCELA_SALDO.SALDO_JUROS_GERADO+W_CTB_A_RECEBER_PARCELA_SALDO.SALDO_MULTA_GERADA)-W_CTB_A_RECEBER_PARCELA_SALDO.SALDO_DESCONTO_CONCEDIDO),  
					VALOR_LIQUIDO_RECEBIDO_PADRAO = ((CTB_A_RECEBER_MOV.VALOR_MOV_PADRAO+CTB_A_RECEBER_MOV.VALOR_JUROS_PAGO_PADRAO+CTB_A_RECEBER_MOV.VALOR_MULTA_PAGA_PADRAO)-CTB_A_RECEBER_MOV.DESCONTO_EFETIVADO_PADRAO),  
					VALOR_LIQUIDO_DEVIDO_PADRAO = ((W_CTB_A_RECEBER_PARCELA_SALDO.SALDO_PRINCIPAL_DEVIDO_PADRAO+W_CTB_A_RECEBER_PARCELA_SALDO.SALDO_JUROS_GERADO_PADRAO+W_CTB_A_RECEBER_PARCELA_SALDO.SALDO_MULTA_GERADA_PADRAO)-W_CTB_A_RECEBER_PARCELA_SALDO.SALDO_DESCONTO_CONCEDIDO_PADRAO)  
				FROM CTB_A_RECEBER_MOV 
				JOIN CTB_A_RECEBER_FATURA ON CTB_A_RECEBER_MOV.EMPRESA = CTB_A_RECEBER_FATURA.EMPRESA AND CTB_A_RECEBER_MOV.LANCAMENTO_MOV = CTB_A_RECEBER_FATURA.LANCAMENTO AND CTB_A_RECEBER_MOV.ITEM_MOV = CTB_A_RECEBER_FATURA.ITEM 
				JOIN CTB_A_RECEBER_PARCELA ON CTB_A_RECEBER_MOV.EMPRESA = CTB_A_RECEBER_PARCELA.EMPRESA AND CTB_A_RECEBER_MOV.LANCAMENTO_MOV = CTB_A_RECEBER_PARCELA.LANCAMENTO AND CTB_A_RECEBER_MOV.ITEM_MOV = CTB_A_RECEBER_PARCELA.ITEM AND CTB_A_RECEBER_MOV.ID_PARCELA = CTB_A_RECEBER_PARCELA.ID_PARCELA 
				JOIN W_CTB_A_RECEBER_PARCELA_SALDO ON Ctb_a_receber_mov.EMPRESA = W_CTB_A_RECEBER_PARCELA_SALDO.EMPRESA AND Ctb_a_receber_mov.LANCAMENTO_MOV = W_CTB_A_RECEBER_PARCELA_SALDO.LANCAMENTO AND Ctb_a_receber_mov.ITEM_MOV = W_CTB_A_RECEBER_PARCELA_SALDO.ITEM AND  Ctb_a_receber_mov.ID_PARCELA = W_CTB_A_RECEBER_PARCELA_SALDO.ID_PARCELA 
				JOIN CTB_LANCAMENTO_ITEM ON CTB_A_RECEBER_FATURA.EMPRESA = CTB_LANCAMENTO_ITEM.EMPRESA AND CTB_A_RECEBER_FATURA.LANCAMENTO = CTB_LANCAMENTO_ITEM.LANCAMENTO AND CTB_A_RECEBER_FATURA.ITEM = CTB_LANCAMENTO_ITEM.ITEM JOIN CTB_CONTA_PLANO ON CTB_CONTA_PLANO.CONTA_CONTABIL = CTB_LANCAMENTO_ITEM.CONTA_CONTABIL 
				JOIN CTB_CONTA_PLANO CTB_CONTA_PLANO_PORTADOR ON CTB_CONTA_PLANO_PORTADOR.CONTA_CONTABIL = CTB_A_RECEBER_PARCELA.CONTA_PORTADOR JOIN CTB_LX_DOCUMENTO_TIPO ON CTB_LX_DOCUMENTO_TIPO.LX_TIPO_DOCUMENTO = CTB_A_RECEBER_FATURA.LX_TIPO_DOCUMENTO JOIN CTB_CENTRO_CUSTO_RATEIO ON CTB_CENTRO_CUSTO_RATEIO.RATEIO_CENTRO_CUSTO = CTB_LANCAMENTO_ITEM.RATEIO_CENTRO_CUSTO 
				JOIN CTB_FILIAL_RATEIO ON CTB_FILIAL_RATEIO.RATEIO_FILIAL = CTB_LANCAMENTO_ITEM.RATEIO_FILIAL LEFT JOIN CADASTRO_CLI_FOR ON CTB_A_RECEBER_FATURA.COD_CLIFOR=CADASTRO_CLI_FOR.COD_CLIFOR  
				LEFT JOIN CADASTRO_CLI_FOR CADASTRO_CLI_FOR_FILIAIS ON CTB_A_RECEBER_FATURA.COD_EMISSOR =CADASTRO_CLI_FOR_FILIAIS.COD_CLIFOR 
				LEFT JOIN CLIENTES_VAREJO ON CLIENTES_VAREJO.CODIGO_CLIENTE = CTB_A_RECEBER_FATURA.CODIGO_CONSUMIDOR 
			   WHERE (Ctb_a_receber_mov.EMPRESA=cast(?v_ctb_lancamento_01.EMPRESA as int) AND Ctb_a_receber_mov.LANCAMENTO = cast(?v_ctb_lancamento_01.LANCAMENTO as int))
		ENDTEXT 


	CASE xView_Cursor == 'xv_ctb_lancamento_01_a_pagar'
		TEXT TO xStruCursor NOSHOW 
			SELECT CTB_A_PAGAR_FATURA.COD_CLIFOR_SACADO, CADASTRO_CLI_FOR_SACADO.NOME_CLIFOR AS NOME_CLIFOR_SACADO, CTB_A_PAGAR_FATURA.DOCUMENTO, 
				   CTB_A_PAGAR_FATURA.INDICA_SACADO_PRINCIPAL, CTB_A_PAGAR_FATURA.LANCAMENTO, CTB_A_PAGAR_FATURA.EMPRESA,  CTB_A_PAGAR_FATURA.ITEM, 
				   CTB_A_PAGAR_FATURA.COD_CLIFOR, CTB_A_PAGAR_FATURA.ESPECIE_SERIE,  CTB_A_PAGAR_FATURA.LX_TIPO_DOCUMENTO, 
				   CTB_A_PAGAR_FATURA.COD_FILIAL, CTB_A_PAGAR_FATURA.FATURA,  CTB_A_PAGAR_FATURA.FATURA_SERIE, CTB_A_PAGAR_FATURA.MOEDA, 
				   CTB_A_PAGAR_FATURA.EMISSAO,  CTB_A_PAGAR_FATURA.DATA_ENTRADA, CTB_A_PAGAR_FATURA.FATURA_OK, CTB_A_PAGAR_FATURA.POSSUI_ENTRADA,  
				   CTB_A_PAGAR_FATURA.PROVISAO, CTB_A_PAGAR_FATURA.COMPLEMENTO_NOME, CTB_A_PAGAR_FATURA.TAXA_MULTA,  CTB_A_PAGAR_FATURA.TAXA_JUROS, 
				   CTB_PARCELA.CAMBIO_NA_DATA_EMISSAO, CTB_A_PAGAR_FATURA.NUMERO_ENTRADA,  CTB_PARCELA.NUMERO_PARCELAS, 
				   CADASTRO_CLI_FOR.RAZAO_SOCIAL, CADASTRO_CLI_FOR.CGC_CPF,  CADASTRO_CLI_FOR.TELEFONE1, CADASTRO_CLI_FOR.DDD1, 
				   CADASTRO_CLI_FOR.NOME_CLIFOR,  CTB_LX_DOCUMENTO_TIPO.TIPO_DOCUMENTO, FILIAIS.FILIAL, CTB_ESPECIE_SERIE.DESC_ESPECIE_SERIE,  CTB_A_PAGAR_FATURA.USUARIO 
			  FROM CTB_A_PAGAR_FATURA 
			  LEFT JOIN (SELECT EMPRESA, LANCAMENTO, ITEM, ISNULL(count(*),0) as NUMERO_PARCELAS, convert(numeric(20,6), convert(numeric(20,6), sum(valor_original_padrao))/convert(numeric(20,6), sum(valor_original))) as CAMBIO_NA_DATA_EMISSAO  
			  			   FROM CTB_A_PAGAR_PARCELA GROUP BY EMPRESA, LANCAMENTO, ITEM) CTB_PARCELA ON CTB_A_PAGAR_FATURA.EMPRESA = CTB_PARCELA.EMPRESA AND CTB_A_PAGAR_FATURA.LANCAMENTO = CTB_PARCELA.LANCAMENTO AND CTB_A_PAGAR_FATURA.ITEM = CTB_PARCELA.ITEM 
			 INNER JOIN CADASTRO_CLI_FOR ON CTB_A_PAGAR_FATURA.COD_CLIFOR = CADASTRO_CLI_FOR.COD_CLIFOR 
			 INNER JOIN CADASTRO_CLI_FOR CADASTRO_CLI_FOR_SACADO ON CTB_A_PAGAR_FATURA.COD_CLIFOR_SACADO = CADASTRO_CLI_FOR_SACADO.COD_CLIFOR 
			 INNER JOIN CTB_LX_DOCUMENTO_TIPO ON  CTB_A_PAGAR_FATURA.LX_TIPO_DOCUMENTO = CTB_LX_DOCUMENTO_TIPO.LX_TIPO_DOCUMENTO 
			 LEFT OUTER JOIN FILIAIS ON CTB_A_PAGAR_FATURA.COD_FILIAL = FILIAIS.COD_FILIAL 
			 LEFT OUTER JOIN CTB_ESPECIE_SERIE ON CTB_A_PAGAR_FATURA.ESPECIE_SERIE = CTB_ESPECIE_SERIE.ESPECIE_SERIE 
			 where CTB_A_PAGAR_FATURA.empresa = cast(?v_ctb_lancamento_01.empresa as int) and CTB_A_PAGAR_FATURA.LANCAMENTO = cast(?v_ctb_lancamento_01.lancamento as int)
		ENDTEXT 


	CASE xView_Cursor == 'xv_ctb_lancamento_01_a_pagar_parcelas'
		TEXT TO xStruCursor NOSHOW 
			SELECT Ctb_a_pagar_parcela.EMPRESA, Ctb_a_pagar_parcela.ITEM,  Ctb_a_pagar_parcela.LANCAMENTO,   Ctb_a_pagar_parcela.ID_PARCELA,  
				   Ctb_a_pagar_parcela.BANCO, Ctb_a_pagar_parcela.VALOR_ORIGINAL,    Ctb_a_pagar_parcela.VALOR_ORIGINAL_PADRAO,  
				   w_ctb_a_pagar_parcela.VALOR_A_PAGAR,   w_ctb_a_pagar_parcela.VALOR_A_PAGAR_PADRAO,w_ctb_a_pagar_parcela.VENCIMENTO_REAL,   
				   Ctb_a_pagar_parcela.DATA_DESCONTO_VENC,  Ctb_a_pagar_parcela.DESCONTO_VENC,    Ctb_a_pagar_parcela.NUMERO_BANCARIO, 
				   Ctb_a_pagar_parcela.VENCIMENTO,  Ctb_a_pagar_parcela.DIAS_PRORROGADOS,    Ctb_a_pagar_parcela.PAGAMENTO_APROVADO,  
				   Ctb_a_pagar_parcela.CODIGO_BARRA,  Ctb_a_pagar_parcela.CONTA_PORTADOR,  Ctb_conta_plano.DESC_CONTA, Bancos.NOME_BANCO,  
				   ctb_a_pagar_parcela.cambio_fixo_pgto,  w_ctb_a_pagar_parcela.em_carteira, w_ctb_a_pagar_parcela.em_cobranca,   
				   w_ctb_a_pagar_parcela.ID_ASSINATURA_DOCUMENTO, w_ctb_a_pagar_parcela.ID_ASSINATURA_APROVACAO, 
				   w_ctb_a_pagar_parcela.total_multa_paga,  w_ctb_a_pagar_parcela.total_juros_pago,w_ctb_a_pagar_parcela.total_desconto_obtido,
			       w_ctb_a_pagar_parcela.total_multa_gerada,w_ctb_a_pagar_parcela.total_juros_gerado,    w_ctb_a_pagar_parcela.valor_outras_entidades,   
			       ((Ctb_a_pagar_parcela.VALOR_ORIGINAL_PADRAO * Ctb_a_pagar_parcela.DESCONTO_VENC) / 100) As Valor_Desconto_Venc  
		       FROM CTB_A_PAGAR_PARCELA  
		       JOIN w_ctb_a_pagar_parcela   ON CTB_A_PAGAR_PARCELA.EMPRESA=w_ctb_a_pagar_parcela.EMPRESA and   CTB_A_PAGAR_PARCELA.LANCAMENTO=w_ctb_a_pagar_parcela.LANCAMENTO and   CTB_A_PAGAR_PARCELA.ITEM=w_ctb_a_pagar_parcela.ITEM and   CTB_A_PAGAR_PARCELA.ID_PARCELA=w_ctb_a_pagar_parcela.ID_PARCELA   
		       LEFT JOIN BANCOS  ON CTB_A_PAGAR_PARCELA.BANCO= BANCOS.BANCO   
		       LEFT JOIN CTB_CONTA_PLANO  ON CTB_A_PAGAR_PARCELA.CONTA_PORTADOR= CTB_CONTA_PLANO.CONTA_CONTABIL   
		       WHERE (Ctb_a_pagar_parcela.EMPRESA = CAST(?v_ctb_lancamento_01_a_pagar.Empresa AS int) AND   Ctb_a_pagar_parcela.LANCAMENTO = CAST(?v_ctb_lancamento_01_a_pagar.Lancamento AS INT))   
		       order by Ctb_a_pagar_parcela.EMPRESA, Ctb_a_pagar_parcela.LANCAMENTO, Ctb_a_pagar_parcela.ITEM,   Ctb_a_pagar_parcela.ID_PARCELA
		ENDTEXT 


	CASE xView_Cursor == 'xv_ctb_lancamento_01_baixa_pagar'
	
		TEXT TO xStruCursor NOSHOW 
			SELECT CTB_A_PAGAR_MOV.LANCAMENTO_MOV,  CTB_A_PAGAR_MOV.EMPRESA,  CTB_A_PAGAR_MOV.ITEM_MOV,   CTB_A_PAGAR_MOV.LANCAMENTO,  
					CTB_A_PAGAR_MOV.ITEM,  CTB_A_PAGAR_MOV.ID_PARCELA,   CTB_A_PAGAR_MOV.DATA_PAGAMENTO,  CTB_A_PAGAR_MOV.PGTO_CARTORIO,  
					CTB_A_PAGAR_MOV.CAMBIO_NA_DATA, CTB_A_PAGAR_MOV.VALOR_MULTA_GERADA,  CTB_A_PAGAR_MOV.VALOR_MULTA_PAGA,  
					CTB_A_PAGAR_MOV.VALOR_JUROS_GERADO,  CTB_A_PAGAR_MOV.VALOR_JUROS_PAGO,  CTB_A_PAGAR_MOV.DESCONTO_EFETIVADO,  
					CTB_A_PAGAR_MOV.DESCONTO_OBTIDO,   CTB_A_PAGAR_MOV.VALOR_MULTA_PAGA_padrao,  CTB_A_PAGAR_MOV.VALOR_JUROS_PAGO_padrao,  
					CTB_A_PAGAR_MOV.DESCONTO_EFETIVADO_padrao,  CTB_A_PAGAR_MOV.VALOR_MOV,  CTB_A_PAGAR_MOV.VALOR_MOV_PADRAO,  
					CTB_A_PAGAR_PARCELA.VENCIMENTO_REAL,   W_CTB_A_PAGAR_PARCELA_SALDO.SALDO_PRINCIPAL_DEVIDO,  
					W_CTB_A_PAGAR_PARCELA_SALDO.SALDO_MULTA_GERADA,   CTB_LANCAMENTO_ITEM.HISTORICO, CTB_LANCAMENTO_ITEM.CODIGO_HISTORICO, 
					W_CTB_A_PAGAR_PARCELA_SALDO.SALDO_JUROS_GERADO,  W_CTB_A_PAGAR_PARCELA_SALDO.SALDO_DESCONTO_OBTIDO,   
					W_CTB_A_PAGAR_PARCELA_SALDO.TOTAL_PRINCIPAL_PAGO,  W_CTB_A_PAGAR_PARCELA_SALDO.TOTAL_MULTA_PAGA,   
					W_CTB_A_PAGAR_PARCELA_SALDO.TOTAL_JUROS_PAGO,  CTB_A_PAGAR_FATURA.INDICA_SACADO_PRINCIPAL, 
					W_CTB_A_PAGAR_PARCELA_SALDO.TOTAL_DESCONTO_EFETIVADO,   W_CTB_A_PAGAR_PARCELA_SALDO.TOTAL_MULTA_GERADA,  
					W_CTB_A_PAGAR_PARCELA_SALDO.TOTAL_JUROS_GERADO,   W_CTB_A_PAGAR_PARCELA_SALDO.TOTAL_DESCONTO_OBTIDO,  
					CTB_A_PAGAR_PARCELA.VALOR_ORIGINAL,   CTB_A_PAGAR_PARCELA.VALOR_ORIGINAL_PADRAO,  CTB_A_PAGAR_PARCELA.VALOR_A_PAGAR,   
					W_CTB_A_PAGAR_PARCELA_SALDO.VALOR_A_PAGAR_PADRAO,  CONVERT(NUMERIC(14, 2),  CTB_A_PAGAR_MOV.VALOR_MOV + CTB_A_PAGAR_MOV.VALOR_MULTA_PAGA + CTB_A_PAGAR_MOV.VALOR_JUROS_PAGO - CTB_A_PAGAR_MOV.DESCONTO_EFETIVADO) AS VALOR_LIQUIDO_PAGO,  
					CTB_A_PAGAR_FATURA.FATURA,  CTB_A_PAGAR_FATURA.FATURA_SERIE,   CTB_A_PAGAR_FATURA.EMISSAO,  CTB_A_PAGAR_FATURA.DOCUMENTO, CTB_A_PAGAR_FATURA.COD_CLIFOR,  CTB_A_PAGAR_FATURA.LX_TIPO_DOCUMENTO,   CTB_A_PAGAR_FATURA.MOEDA,  CTB_A_PAGAR_FATURA.TAXA_JUROS,  CTB_A_PAGAR_FATURA.TAXA_MULTA,   
					CTB_A_PAGAR_FATURA.NUMERO_PARCELAS,  CTB_A_PAGAR_PARCELA.CONTA_PORTADOR,   CTB_A_PAGAR_PARCELA.VENCIMENTO,  CTB_A_PAGAR_PARCELA.NUMERO_BANCARIO,  CTB_A_PAGAR_PARCELA.DIAS_PRORROGADOS,  CTB_A_PAGAR_PARCELA.DESCONTO_VENC,   
					CTB_A_PAGAR_FATURA.CAMBIO_NA_DATA_EMISSAO,  CTB_A_PAGAR_PARCELA.DATA_DESCONTO_VENC,   CTB_LANCAMENTO_ITEM.CONTA_CONTABIL,  CTB_LANCAMENTO_ITEM.HISTORICO,   CTB_LANCAMENTO_ITEM.RATEIO_CENTRO_CUSTO,  
					CTB_LANCAMENTO_ITEM.RATEIO_FILIAL,   CTB_CONTA_PLANO.CODIGO_RESUMIDO,  CTB_CONTA_PLANO.DESC_CONTA,   CTB_LX_LANCAMENTO_TIPO.DESC_TIPO_LANCAMENTO,  CTB_CONTA_PLANO.DESC_CONTA_REDUZIDA,   
					CTB_CENTRO_CUSTO_RATEIO.DESC_RATEIO_CENTRO_CUSTO,  CTB_FILIAL_RATEIO.DESC_RATEIO_FILIAL,   'D' as CREDITO_DEBITO,  CTB_LX_LANCAMENTO_TIPO.INDICA_ID_CONTABIL_TERCEIRO,  
					'BTP' as LX_TIPO_LANCAMENTO ,  CTB_LX_LANCAMENTO_TIPO.CONTA_PADRAO,   CTB_LX_DOCUMENTO_TIPO.TIPO_DOCUMENTO,   CTB_LX_DOCUMENTO_TIPO.SERIE_NF,   
					CTB_LX_DOCUMENTO_TIPO.NOME_RECIBO,  CTB_CONTA_PORTADOR.DESC_CONTA AS DESC_CONTA_PORTADOR,   CADASTRO_CLI_FOR.NOME_CLIFOR,  CADASTRO_CLI_FOR.RAZAO_SOCIAL,  CADASTRO_CLI_FOR.DDD1,   CADASTRO_CLI_FOR.TELEFONE1,  CONVERT(NUMERIC(14, 2), 
					CTB_A_PAGAR_MOV.VALOR_MOV_PADRAO + CTB_A_PAGAR_MOV.VALOR_MULTA_PAGA_PADRAO + CTB_A_PAGAR_MOV.VALOR_JUROS_PAGO_PADRAO - CTB_A_PAGAR_MOV.DESCONTO_EFETIVADO_PADRAO) AS VALOR_LIQUIDO_PAGO_PADRAO,  CTB_A_PAGAR_MOV.VALOR_MULTA_PAGA_PADRAO,
				    CTB_A_PAGAR_MOV.VALOR_JUROS_PAGO_PADRAO, CTB_A_PAGAR_MOV.DESCONTO_EFETIVADO_PADRAO,   W_CTB_A_PAGAR_PARCELA_SALDO.SALDO_PRINCIPAL_DEVIDO_PADRAO,  W_CTB_A_PAGAR_PARCELA_SALDO.SALDO_MULTA_GERADA_PADRAO,   W_CTB_A_PAGAR_PARCELA_SALDO.SALDO_JUROS_GERADO_PADRAO,
				    W_CTB_A_PAGAR_PARCELA_SALDO.SALDO_DESCONTO_OBTIDO_PADRAO,  W_CTB_A_PAGAR_PARCELA_SALDO.TOTAL_PRINCIPAL_PAGO_PADRAO,  W_CTB_A_PAGAR_PARCELA_SALDO.TOTAL_MULTA_PAGA_PADRAO,   W_CTB_A_PAGAR_PARCELA_SALDO.TOTAL_JUROS_PAGO_PADRAO,
				    W_CTB_A_PAGAR_PARCELA_SALDO.TOTAL_DESCONTO_EFETIVADO_PADRAO,  W_CTB_A_PAGAR_PARCELA_SALDO.TOTAL_MULTA_GERADA_PADRAO,  W_CTB_A_PAGAR_PARCELA_SALDO.TOTAL_JUROS_GERADO_PADRAO,   W_CTB_A_PAGAR_PARCELA_SALDO.TOTAL_DESCONTO_OBTIDO_PADRAO,
			        CTB_A_PAGAR_PARCELA.pagamento_aprovado, CTB_A_PAGAR_FATURA.cod_clifor_sacado, nome_clifor_sacado = CADASTRO_CLI_FOR_SACADO.nome_clifor 
		        FROM CTB_A_PAGAR_MOV 
		        INNER JOIN CTB_A_PAGAR_PARCELA ON CTB_A_PAGAR_MOV.EMPRESA = CTB_A_PAGAR_PARCELA.EMPRESA AND  CTB_A_PAGAR_MOV.LANCAMENTO_MOV = CTB_A_PAGAR_PARCELA.LANCAMENTO AND  CTB_A_PAGAR_MOV.ITEM_MOV = CTB_A_PAGAR_PARCELA.ITEM AND  CTB_A_PAGAR_MOV.ID_PARCELA = CTB_A_PAGAR_PARCELA.ID_PARCELA 
		        JOIN W_CTB_A_PAGAR_PARCELA_SALDO ON CTB_A_PAGAR_MOV.EMPRESA = W_CTB_A_PAGAR_PARCELA_SALDO.EMPRESA AND  CTB_A_PAGAR_MOV.LANCAMENTO_MOV = W_CTB_A_PAGAR_PARCELA_SALDO.LANCAMENTO AND  CTB_A_PAGAR_MOV.ITEM_MOV = W_CTB_A_PAGAR_PARCELA_SALDO.ITEM AND  CTB_A_PAGAR_MOV.ID_PARCELA = W_CTB_A_PAGAR_PARCELA_SALDO.ID_PARCELA 
		        JOIN CTB_LANCAMENTO_ITEM ON CTB_A_PAGAR_PARCELA.EMPRESA = CTB_LANCAMENTO_ITEM.EMPRESA AND CTB_A_PAGAR_PARCELA.LANCAMENTO = CTB_LANCAMENTO_ITEM.LANCAMENTO AND CTB_A_PAGAR_PARCELA.ITEM = CTB_LANCAMENTO_ITEM.ITEM 
		        JOIN CTB_A_PAGAR_FATURA ON  CTB_A_PAGAR_PARCELA.EMPRESA = CTB_A_PAGAR_FATURA.EMPRESA AND CTB_A_PAGAR_PARCELA.LANCAMENTO = CTB_A_PAGAR_FATURA.LANCAMENTO AND CTB_A_PAGAR_PARCELA.ITEM = CTB_A_PAGAR_FATURA.ITEM 
		        LEFT OUTER JOIN CADASTRO_CLI_FOR ON CTB_A_PAGAR_FATURA.COD_CLIFOR = CADASTRO_CLI_FOR.COD_CLIFOR  JOIN CTB_CONTA_PLANO ON CTB_CONTA_PLANO.CONTA_CONTABIL = CTB_LANCAMENTO_ITEM.CONTA_CONTABIL 
		        JOIN CTB_CONTA_PLANO CTB_CONTA_PORTADOR ON CTB_CONTA_PORTADOR.CONTA_CONTABIL = CTB_LANCAMENTO_ITEM.CONTA_CONTABIL JOIN CTB_LX_LANCAMENTO_TIPO ON CTB_LX_LANCAMENTO_TIPO.LX_TIPO_LANCAMENTO = CTB_LANCAMENTO_ITEM.LX_TIPO_LANCAMENTO 
		        JOIN CTB_CENTRO_CUSTO_RATEIO ON CTB_CENTRO_CUSTO_RATEIO.RATEIO_CENTRO_CUSTO = CTB_LANCAMENTO_ITEM.RATEIO_CENTRO_CUSTO JOIN CTB_FILIAL_RATEIO ON CTB_FILIAL_RATEIO.RATEIO_FILIAL = CTB_LANCAMENTO_ITEM.RATEIO_FILIAL 
		        LEFT JOIN CTB_LX_DOCUMENTO_TIPO ON	CTB_A_PAGAR_FATURA.LX_TIPO_DOCUMENTO = CTB_LX_DOCUMENTO_TIPO.LX_TIPO_DOCUMENTO  
		        LEFT OUTER JOIN CADASTRO_CLI_FOR CADASTRO_CLI_FOR_SACADO ON CTB_A_PAGAR_FATURA.COD_CLIFOR_sacado = CADASTRO_CLI_FOR_SACADO.COD_CLIFOR  
		        WHERE (Ctb_a_PAGAR_mov.EMPRESA = CAST(?v_ctb_lancamento_01.EMPRESA AS int) AND Ctb_a_PAGAR_mov.LANCAMENTO = CAST(?v_ctb_lancamento_01.LANCAMENTO AS INT))
		ENDTEXT 


	CASE xView_Cursor == 'xv_ctb_lancamento_01_aviso_credito'
		TEXT TO xStruCursor NOSHOW 
			SELECT CTB_AVISO_LANCAMENTO.EMPRESA, CTB_AVISO_LANCAMENTO.ITEM, CTB_AVISO_LANCAMENTO.LANCAMENTO,  CTB_AVISO_LANCAMENTO.CODIGO_CONSUMIDOR,
			 	   CTB_AVISO_LANCAMENTO.COD_CLIFOR,  CTB_AVISO_LANCAMENTO.CODIGO_FISCAL_OPERACAO, CTB_AVISO_LANCAMENTO.LX_TIPO_DOCUMENTO,
				   CTB_AVISO_LANCAMENTO.AVISO_LANCAMENTO, CTB_AVISO_LANCAMENTO.VENCIMENTO,  W_CTB_AVISO_LANCAMENTO.VENCIMENTO_REAL, 
				   CTB_AVISO_LANCAMENTO.STATUS_APROVACAO, CTB_AVISO_LANCAMENTO.MOEDA, CTB_AVISO_LANCAMENTO.CAMBIO_NA_DATA_EMISSAO, 
				   CTB_AVISO_LANCAMENTO.DESCRICAO,  CTB_AVISO_LANCAMENTO.DESC_AVISO_LANCAMENTO, CTB_AVISO_LANCAMENTO.VALOR_ORIGINAL,  
				   CTB_AVISO_LANCAMENTO.EMISSAO, CTB_AVISO_LANCAMENTO.VALOR_ORIGINAL_PADRAO,  W_CTB_AVISO_LANCAMENTO.VALOR_AVISO, 
				   W_CTB_AVISO_LANCAMENTO.VALOR_AVISO_PADRAO,  CTB_AVISO_LANCAMENTO.SUB_ITEM, W_CTB_AVISO_LANCAMENTO.NOME_CLIFOR, 
				   W_CTB_AVISO_LANCAMENTO.TIPO_DOCUMENTO, W_CTB_AVISO_LANCAMENTO.CLIENTE_VAREJO, W_CTB_AVISO_LANCAMENTO.RAZAO_SOCIAL, 
				   CTB_AVISO_LANCAMENTO.USUARIO, ctb_aviso_lancamento.cambio_fixo_pgto, ctb_aviso_lancamento.id_assinatura_documento 
			   FROM CTB_AVISO_LANCAMENTO INNER JOIN W_CTB_AVISO_LANCAMENTO ON CTB_AVISO_LANCAMENTO.EMPRESA = W_CTB_AVISO_LANCAMENTO.EMPRESA AND  CTB_AVISO_LANCAMENTO.LANCAMENTO = W_CTB_AVISO_LANCAMENTO.LANCAMENTO AND  CTB_AVISO_LANCAMENTO.ITEM = W_CTB_AVISO_LANCAMENTO.ITEM AND  CTB_AVISO_LANCAMENTO.SUB_ITEM = W_CTB_AVISO_LANCAMENTO.SUB_ITEM 
			   WHERE (W_CTB_AVISO_LANCAMENTO.LX_TIPO_LANCAMENTO = 'IAC' and Ctb_aviso_lancamento.EMPRESA = cast(?v_ctb_lancamento_01.empresa as int) AND Ctb_aviso_lancamento.LANCAMENTO = cast(?v_ctb_lancamento_01.lancamento as int))
		ENDTEXT 


	CASE xView_Cursor == 'xv_ctb_lancamento_01_baixa_aviso_credito'
		TEXT TO xStruCursor NOSHOW 
			SELECT dbo.CTB_AVISO_LANCAMENTO_MOV.LANCAMENTO_MOV, dbo.CTB_AVISO_LANCAMENTO_MOV.ITEM,  dbo.CTB_AVISO_LANCAMENTO_MOV.LANCAMENTO, 
					dbo.CTB_AVISO_LANCAMENTO_MOV.EMPRESA, dbo.CTB_AVISO_LANCAMENTO_MOV.ITEM_MOV, dbo.CTB_AVISO_LANCAMENTO_MOV.SUB_ITEM, 
					dbo.CTB_AVISO_LANCAMENTO_MOV.VALOR_MOV,  dbo.CTB_AVISO_LANCAMENTO_MOV.CAMBIO_NA_DATA, dbo.CTB_AVISO_LANCAMENTO_MOV.VALOR_MOV_PADRAO,  
					dbo.CTB_AVISO_LANCAMENTO_MOV.DATA_PAGAMENTO, dbo.CTB_AVISO_LANCAMENTO.CODIGO_CONSUMIDOR,  dbo.CTB_AVISO_LANCAMENTO.COD_CLIFOR, 
					dbo.CTB_AVISO_LANCAMENTO.CODIGO_FISCAL_OPERACAO,  dbo.CTB_AVISO_LANCAMENTO.LX_TIPO_DOCUMENTO, dbo.CTB_AVISO_LANCAMENTO.AVISO_LANCAMENTO,  
					dbo.CTB_AVISO_LANCAMENTO.VENCIMENTO, dbo.W_CTB_AVISO_LANCAMENTO.VENCIMENTO_REAL,  dbo.CTB_AVISO_LANCAMENTO.EMISSAO, dbo.CTB_AVISO_LANCAMENTO.STATUS_APROVACAO, dbo.CTB_AVISO_LANCAMENTO.VALOR_ORIGINAL,  
					dbo.CTB_AVISO_LANCAMENTO.VALOR_ORIGINAL_PADRAO, dbo.W_CTB_AVISO_LANCAMENTO.VALOR_AVISO,  dbo.W_CTB_AVISO_LANCAMENTO.VALOR_AVISO_PADRAO, dbo.CTB_AVISO_LANCAMENTO.MOEDA,  dbo.CTB_AVISO_LANCAMENTO.CAMBIO_NA_DATA_EMISSAO, 
					dbo.CTB_AVISO_LANCAMENTO.DESCRICAO,  dbo.CTB_AVISO_LANCAMENTO.DESC_AVISO_LANCAMENTO, W_CTB_AVISO_LANCAMENTO.TIPO_DOCUMENTO, W_CTB_AVISO_LANCAMENTO.SERIE_NF, W_CTB_AVISO_LANCAMENTO.NOME_RECIBO,  
					dbo.CLIENTES_VAREJO.CLIENTE_VAREJO, dbo.CADASTRO_CLI_FOR.NOME_CLIFOR, dbo.CADASTRO_CLI_FOR.RAZAO_SOCIAL,  dbo.CADASTRO_CLI_FOR.DDD1, dbo.CADASTRO_CLI_FOR.TELEFONE1 
				FROM         dbo.CTB_AVISO_LANCAMENTO_MOV 
				INNER JOIN dbo.CTB_AVISO_LANCAMENTO ON dbo.CTB_AVISO_LANCAMENTO_MOV.EMPRESA = dbo.CTB_AVISO_LANCAMENTO.EMPRESA AND  dbo.CTB_AVISO_LANCAMENTO_MOV.LANCAMENTO_MOV = dbo.CTB_AVISO_LANCAMENTO.LANCAMENTO AND  dbo.CTB_AVISO_LANCAMENTO_MOV.ITEM_MOV = dbo.CTB_AVISO_LANCAMENTO.ITEM AND  dbo.CTB_AVISO_LANCAMENTO_MOV.SUB_ITEM = dbo.CTB_AVISO_LANCAMENTO.SUB_ITEM 
				INNER JOIN dbo.W_CTB_AVISO_LANCAMENTO ON dbo.CTB_AVISO_LANCAMENTO.EMPRESA = dbo.W_CTB_AVISO_LANCAMENTO.EMPRESA AND  dbo.CTB_AVISO_LANCAMENTO.LANCAMENTO = dbo.W_CTB_AVISO_LANCAMENTO.LANCAMENTO AND  dbo.CTB_AVISO_LANCAMENTO.ITEM = dbo.W_CTB_AVISO_LANCAMENTO.ITEM AND  dbo.CTB_AVISO_LANCAMENTO.SUB_ITEM = dbo.W_CTB_AVISO_LANCAMENTO.SUB_ITEM 
				INNER JOIN dbo.CTB_LX_DOCUMENTO_TIPO ON  dbo.CTB_AVISO_LANCAMENTO.LX_TIPO_DOCUMENTO = dbo.CTB_LX_DOCUMENTO_TIPO.LX_TIPO_DOCUMENTO 
				LEFT OUTER JOIN dbo.CADASTRO_CLI_FOR ON dbo.CTB_AVISO_LANCAMENTO.COD_CLIFOR = dbo.CADASTRO_CLI_FOR.COD_CLIFOR 
				LEFT OUTER JOIN dbo.CLIENTES_VAREJO ON dbo.CTB_AVISO_LANCAMENTO.CODIGO_CONSUMIDOR = dbo.CLIENTES_VAREJO.CODIGO_CLIENTE 
				WHERE (Ctb_aviso_lancamento_mov.EMPRESA= cast(?v_ctb_lancamento_01.EMPRESA as int) AND Ctb_aviso_lancamento_mov.LANCAMENTO = cast(?v_ctb_lancamento_01.LANCAMENTO as int) ) and W_CTB_AVISO_LANCAMENTO.lx_tipo_lancamento = 'IAC'
		ENDTEXT 


	CASE xView_Cursor == 'xv_ctb_lancamento_01_aviso_debito'
		TEXT TO xStruCursor NOSHOW 
			SELECT CTB_AVISO_LANCAMENTO.EMPRESA, CTB_AVISO_LANCAMENTO.ITEM, CTB_AVISO_LANCAMENTO.LANCAMENTO, CTB_AVISO_LANCAMENTO.INDICA_SACADO_PRINCIPAL,  
					CTB_AVISO_LANCAMENTO.CODIGO_CONSUMIDOR, CTB_AVISO_LANCAMENTO.COD_CLIFOR,  CTB_AVISO_LANCAMENTO.CODIGO_FISCAL_OPERACAO, CTB_AVISO_LANCAMENTO.LX_TIPO_DOCUMENTO,  
					CTB_AVISO_LANCAMENTO.AVISO_LANCAMENTO, CTB_AVISO_LANCAMENTO.VENCIMENTO,  W_CTB_AVISO_LANCAMENTO.VENCIMENTO_REAL, CTB_AVISO_LANCAMENTO.STATUS_APROVACAO, 
					CTB_AVISO_LANCAMENTO.MOEDA, CTB_AVISO_LANCAMENTO.CAMBIO_NA_DATA_EMISSAO, CTB_AVISO_LANCAMENTO.DESCRICAO,  CTB_AVISO_LANCAMENTO.DESC_AVISO_LANCAMENTO, 
					CTB_AVISO_LANCAMENTO.VALOR_ORIGINAL,  CTB_AVISO_LANCAMENTO.EMISSAO, CTB_AVISO_LANCAMENTO.VALOR_ORIGINAL_PADRAO,  W_CTB_AVISO_LANCAMENTO.VALOR_AVISO, 
					W_CTB_AVISO_LANCAMENTO.VALOR_AVISO_PADRAO,  CTB_AVISO_LANCAMENTO.SUB_ITEM, W_CTB_AVISO_LANCAMENTO.NOME_CLIFOR, W_CTB_AVISO_LANCAMENTO.NOME_CLIFOR_SACADO, 
					W_CTB_AVISO_LANCAMENTO.TIPO_DOCUMENTO, W_CTB_AVISO_LANCAMENTO.CLIENTE_VAREJO, W_CTB_AVISO_LANCAMENTO.RAZAO_SOCIAL, CTB_AVISO_LANCAMENTO.USUARIO, 
					ctb_aviso_lancamento.cambio_fixo_pgto, CTB_AVISO_LANCAMENTO.ID_ASSINATURA_DOCUMENTO, CTB_AVISO_LANCAMENTO.COD_CLIFOR_SACADO, CTB_AVISO_LANCAMENTO.PEDIDO_COMPRA 
				FROM CTB_AVISO_LANCAMENTO 
				INNER JOIN W_CTB_AVISO_LANCAMENTO ON CTB_AVISO_LANCAMENTO.EMPRESA = W_CTB_AVISO_LANCAMENTO.EMPRESA AND  CTB_AVISO_LANCAMENTO.LANCAMENTO = W_CTB_AVISO_LANCAMENTO.LANCAMENTO AND  CTB_AVISO_LANCAMENTO.ITEM = W_CTB_AVISO_LANCAMENTO.ITEM AND  CTB_AVISO_LANCAMENTO.SUB_ITEM = W_CTB_AVISO_LANCAMENTO.SUB_ITEM 
				WHERE (W_CTB_AVISO_LANCAMENTO.LX_TIPO_LANCAMENTO = 'IAD' and Ctb_aviso_lancamento.EMPRESA = cast(?v_ctb_lancamento_01.empresa as int) AND Ctb_aviso_lancamento.LANCAMENTO = cast(?v_ctb_lancamento_01.lancamento as int))
		ENDTEXT 


	CASE xView_Cursor == 'xv_ctb_lancamento_01_baixa_aviso_debito'

		TEXT TO xStruCursor NOSHOW 
			SELECT     CTB_AVISO_LANCAMENTO_MOV.EMPRESA, CTB_AVISO_LANCAMENTO_MOV.LANCAMENTO, CTB_AVISO_LANCAMENTO_MOV.ITEM,  
						CTB_AVISO_LANCAMENTO_MOV.LANCAMENTO_MOV, CTB_AVISO_LANCAMENTO_MOV.ITEM_MOV,  CTB_AVISO_LANCAMENTO_MOV.SUB_ITEM, CTB_AVISO_LANCAMENTO_MOV.VALOR_MOV,  CTB_AVISO_LANCAMENTO_MOV.CAMBIO_NA_DATA, CTB_AVISO_LANCAMENTO_MOV.VALOR_MOV_PADRAO,  
						CTB_AVISO_LANCAMENTO_MOV.DATA_PAGAMENTO, CTB_AVISO_LANCAMENTO.CODIGO_CONSUMIDOR,  CTB_AVISO_LANCAMENTO.COD_CLIFOR, CTB_AVISO_LANCAMENTO.CODIGO_FISCAL_OPERACAO,  CTB_AVISO_LANCAMENTO.LX_TIPO_DOCUMENTO, CTB_AVISO_LANCAMENTO.AVISO_LANCAMENTO,  
						CTB_AVISO_LANCAMENTO.VENCIMENTO, W_CTB_AVISO_LANCAMENTO_SALDO.VENCIMENTO_REAL,  CTB_AVISO_LANCAMENTO.EMISSAO, CTB_AVISO_LANCAMENTO.STATUS_APROVACAO, CTB_AVISO_LANCAMENTO.VALOR_ORIGINAL,  CTB_AVISO_LANCAMENTO.VALOR_ORIGINAL_PADRAO, W_CTB_AVISO_LANCAMENTO_SALDO.VALOR_AVISO,  
						W_CTB_AVISO_LANCAMENTO_SALDO.VALOR_AVISO_PADRAO, CTB_AVISO_LANCAMENTO.COD_CLIFOR_SACADO, CTB_AVISO_LANCAMENTO.INDICA_SACADO_PRINCIPAL, CADASTRO_CLIFOR_SACADO.NOME_CLIFOR AS NOME_CLIFOR_SACADO, CTB_AVISO_LANCAMENTO.MOEDA,  CTB_AVISO_LANCAMENTO.CAMBIO_NA_DATA_EMISSAO, CTB_AVISO_LANCAMENTO.DESCRICAO,  CTB_AVISO_LANCAMENTO.DESC_AVISO_LANCAMENTO, CTB_LX_DOCUMENTO_TIPO.TIPO_DOCUMENTO, CTB_LX_DOCUMENTO_TIPO.SERIE_NF, CTB_LX_DOCUMENTO_TIPO.NOME_RECIBO,  CLIENTES_VAREJO.CLIENTE_VAREJO, CADASTRO_CLI_FOR.NOME_CLIFOR, CADASTRO_CLI_FOR.RAZAO_SOCIAL,  CADASTRO_CLI_FOR.DDD1, CADASTRO_CLI_FOR.TELEFONE1, 
						left(dbo.CTB_AVISO_LANCAMENTO.LOJA_CHAVE,6) AS rateio_filial, LOJAS_VAREJO.FILIAL as desc_rateio_filial
			FROM         CTB_AVISO_LANCAMENTO_MOV 
			INNER JOIN CTB_AVISO_LANCAMENTO ON CTB_AVISO_LANCAMENTO_MOV.EMPRESA = CTB_AVISO_LANCAMENTO.EMPRESA AND  CTB_AVISO_LANCAMENTO_MOV.LANCAMENTO_MOV = CTB_AVISO_LANCAMENTO.LANCAMENTO AND  CTB_AVISO_LANCAMENTO_MOV.ITEM_MOV = CTB_AVISO_LANCAMENTO.ITEM AND  CTB_AVISO_LANCAMENTO_MOV.SUB_ITEM = CTB_AVISO_LANCAMENTO.SUB_ITEM 
			INNER JOIN W_CTB_AVISO_LANCAMENTO_SALDO ON CTB_AVISO_LANCAMENTO.EMPRESA = W_CTB_AVISO_LANCAMENTO_SALDO.EMPRESA AND CTB_AVISO_LANCAMENTO.LANCAMENTO = W_CTB_AVISO_LANCAMENTO_SALDO.LANCAMENTO AND  CTB_AVISO_LANCAMENTO.ITEM = W_CTB_AVISO_LANCAMENTO_SALDO.ITEM AND  CTB_AVISO_LANCAMENTO.SUB_ITEM = W_CTB_AVISO_LANCAMENTO_SALDO.SUB_ITEM 
			INNER JOIN CTB_LX_DOCUMENTO_TIPO ON  CTB_AVISO_LANCAMENTO.LX_TIPO_DOCUMENTO = CTB_LX_DOCUMENTO_TIPO.LX_TIPO_DOCUMENTO 
			LEFT OUTER JOIN CADASTRO_CLI_FOR ON CTB_AVISO_LANCAMENTO.COD_CLIFOR = CADASTRO_CLI_FOR.COD_CLIFOR 
			LEFT OUTER JOIN CADASTRO_CLI_FOR CADASTRO_CLIFOR_SACADO ON CTB_AVISO_LANCAMENTO.COD_CLIFOR_SACADO = CADASTRO_CLIFOR_SACADO.COD_CLIFOR 
			LEFT OUTER JOIN CLIENTES_VAREJO ON CTB_AVISO_LANCAMENTO.CODIGO_CONSUMIDOR = CLIENTES_VAREJO.CODIGO_CLIENTE 
			LEFT OUTER JOIN dbo.LOJAS_VAREJO ON left(dbo.CTB_AVISO_LANCAMENTO.LOJA_CHAVE,6)  = dbo.LOJAS_VAREJO.CODIGO_FILIAL 
			WHERE (CTB_AVISO_LANCAMENTO_MOV.EMPRESA = CAST(?V_CTB_LANCAMENTO_01.EMPRESA AS INT) AND CTB_AVISO_LANCAMENTO_MOV.LANCAMENTO = CAST(?V_CTB_LANCAMENTO_01.LANCAMENTO AS INT)) AND W_CTB_AVISO_LANCAMENTO_SALDO.LX_TIPO_LANCAMENTO = 'IAD'
		ENDTEXT


	CASE xView_Cursor == 'xv_ctb_lancamento_01_cheque'
	
		TEXT TO xStruCursor NOSHOW 
			SELECT Ctb_cheque.LANCAMENTO, Ctb_cheque.ITEM, Ctb_cheque.EMISSAO,  Ctb_cheque.USUARIO_ASSINADO,  Ctb_cheque.DATA_MOV_ASSINADO,  
					Ctb_cheque.CANCELADO, Ctb_cheque.FAVORECIDO_CHEQUE,  Ctb_cheque.VALOR_CHEQUE,  W_Ctb_cheque.MOEDA_CONTA, Ctb_cheque.NUMERO_CHEQUE, 
					Ctb_cheque.CONTA_CONTABIL,  Ctb_cheque.VENCIMENTO,  Ctb_cheque.EMITIDO, Ctb_cheque.EMITE_RECIBO,  W_ctb_cheque.valor_a_pagar,Ctb_cheque.RECIBO_IMPRESSO,  
					Ctb_cheque.EMPRESA,  W_ctb_cheque.LX_GRUPO_FLUXO, W_ctb_cheque.DESC_CONTA,  W_ctb_cheque.DESC_CONTA_SAQUE,  W_ctb_cheque.BANCO,  W_ctb_cheque.AGENCIA, 
					W_ctb_cheque.NUMERO_CONTA_CORRENTE,  CTB_CHEQUE.COD_CLIFOR, CTB_CHEQUE.CAMBIO_NA_DATA_EMISSAO, CTB_CHEQUE.CAMBIO_FIXO_PGTO, CTB_CHEQUE.VALOR_CHEQUE_PADRAO, 
					W_CTB_CHEQUE.VALOR_A_PAGAR_PADRAO, W_CTB_CHEQUE.NOME_CLIFOR_TERCEIRO  
				FROM dbo.W_CTB_CHEQUE W_ctb_cheque, dbo.CTB_CHEQUE Ctb_cheque 
				WHERE Ctb_cheque.EMPRESA = W_ctb_cheque.EMPRESA   AND  Ctb_cheque.LANCAMENTO = W_ctb_cheque.LANCAMENTO   AND  Ctb_cheque.ITEM = W_ctb_cheque.ITEM   AND  (W_ctb_cheque.LANCAMENTO = cast( ?v_ctb_lancamento_01.LANCAMENTO as int )  AND  W_ctb_cheque.EMPRESA = cast( ?v_ctb_lancamento_01.EMPRESA as int ) )
		ENDTEXT 
	
		
	CASE xView_Cursor == 'xv_ctb_lancamento_01_a_receber_cheque'
		TEXT TO xStruCursor NOSHOW 
			SELECT Ctb_cheque_cartao.EMPRESA, Ctb_cheque_cartao.LANCAMENTO,  Ctb_cheque_cartao.ITEM, Ctb_cheque_cartao.SUB_ITEM,  Ctb_cheque_cartao.LX_CONCILIADO, 
					Ctb_cheque_cartao.LX_DATA_CONCILIACAO, Ctb_cheque_cartao.USUARIO_CONCILIACAO, Ctb_cheque_cartao.CONTA_PORTADOR,  Ctb_cheque_cartao.COD_CLIFOR_RESPONSAVEL, 
					Ctb_cheque_cartao.CODIGO_CONSUMIDOR,  Ctb_cheque_cartao.LX_TIPO_DOCUMENTO, Ctb_cheque_cartao.COD_FILIAL,  Ctb_cheque_cartao.CODIGO_ADMINISTRADORA,  Ctb_cheque_cartao.DATA_EMISSAO, 
					Ctb_cheque_cartao.VENDA_DOCUMENTO,  Ctb_cheque_cartao.NUMERO_CHEQUE_CARTAO,  Ctb_cheque_cartao.DATA_DIGITACAO,  Ctb_cheque_cartao.VENDA_TOTAL_PARCELAMENTO,  Ctb_cheque_cartao.INDICA_CARTAO, 
					Ctb_cheque_cartao.CHEQUE_AGENCIA,  Ctb_cheque_cartao.VENCIMENTO,  Ctb_cheque_cartao.CHEQUE_CONTA_CORRENTE,  Ctb_cheque_cartao.PRORROGACAO, Ctb_cheque_cartao.ORIGEM,  Ctb_cheque_cartao.VALOR_ORIGINAL,  
					Ctb_cheque_cartao.NUMERO_DEVOLUCOES,  Ctb_cheque_cartao.TAXA_ADMINISTRACAO, Ctb_cheque_cartao.GUIA_ENVIO,  Ctb_cheque_cartao.CHEQUE_BANCO, Ctb_cheque_cartao.VENDA_PARCELAMENTO,  Ctb_cheque_cartao.CMC7_CVCARTAO, 
					Ctb_cheque_cartao.COD_CLIFOR,  Ctb_cheque_cartao.LOJA_TERMINAL,  Ctb_cheque_cartao.LOJA_LANCAMENTO_CAIXA,  Ctb_cheque_cartao.VALOR_ORIGINAL_PADRAO, Ctb_cheque_cartao.MOEDA, Ctb_cheque_cartao.CAMBIO_NA_DATA_EMISSAO, 
					Ctb_cheque_cartao.CAMBIO_FIXO_PGTO, Ctb_cheque_cartao.LOJA_PARCELA, Ctb_cheque_cartao.VALOR_A_RECEBER,  Ctb_cheque_cartao.VENCIMENTO_REAL, Ctb_cheque_cartao.NR_DEVOLUCOES,  W_ctb_a_receber_cheque.tipo_movimento,  
					W_ctb_a_receber_cheque.desc_tipo_movimento,  W_ctb_a_receber_cheque.lote_lancamento,  W_ctb_a_receber_cheque.desc_lote, W_ctb_a_receber_cheque.data_lote,  W_ctb_a_receber_cheque.lote_conciliado,  
					W_ctb_a_receber_cheque.lancamento_padrao,  W_ctb_a_receber_cheque.data_lancamento,  W_ctb_a_receber_cheque.cod_filial_lancamento,  W_ctb_a_receber_cheque.filial_lancamento,  W_ctb_a_receber_cheque.conta_contabil,  
					W_ctb_a_receber_cheque.desc_conta,  W_ctb_a_receber_cheque.lx_tipo_lancamento,  W_ctb_a_receber_cheque.desc_tipo_lancamento,  W_ctb_a_receber_cheque.conta_padrao,  W_ctb_a_receber_cheque.credito_debito,  
					W_ctb_a_receber_cheque.historico,  W_ctb_a_receber_cheque.codigo_historico,  W_ctb_a_receber_cheque.rateio_centro_custo,  W_ctb_a_receber_cheque.desc_rateio_centro_custo,  W_ctb_a_receber_cheque.conciliado,  
					W_ctb_a_receber_cheque.permite_alteracao,  W_ctb_a_receber_cheque.dispara_formula,  W_ctb_a_receber_cheque.data_digitacao_item,  W_ctb_a_receber_cheque.rateio_filial,  W_ctb_a_receber_cheque.desc_rateio_filial,  
					W_ctb_a_receber_cheque.moeda_LANCAMENTO,  W_ctb_a_receber_cheque.cambio_na_data_lancamento,  W_ctb_a_receber_cheque.desc_conta_portador,  W_ctb_a_receber_cheque.tipo_documento,  W_ctb_a_receber_cheque.cliente_varejo, 
					W_ctb_a_receber_cheque.filial,  W_ctb_a_receber_cheque.valor_principal_pago,  W_ctb_a_receber_cheque.descr_devolucao,  W_ctb_a_receber_cheque.em_carteira,  W_ctb_a_receber_cheque.em_cobranca,  W_ctb_a_receber_cheque.nome_clifor, 
					W_ctb_a_receber_cheque.cgc_cpf,  W_ctb_a_receber_cheque.razao_social, W_ctb_a_receber_cheque.endereco,  W_ctb_a_receber_cheque.bairro, W_ctb_a_receber_cheque.cidade,  W_ctb_a_receber_cheque.cep, W_ctb_a_receber_cheque.VALOR_A_RECEBER_PADRAO, 
					W_ctb_a_receber_cheque.uf,  W_ctb_a_receber_cheque.ddi, W_ctb_a_receber_cheque.ddd1,  W_ctb_a_receber_cheque.telefone1, W_ctb_a_receber_cheque.ddd2,  W_ctb_a_receber_cheque.telefone2,  W_ctb_a_receber_cheque.cgc_cpf_filial,  
					W_ctb_a_receber_cheque.razao_social_filial,  W_ctb_a_receber_cheque.endereco_filial,  W_ctb_a_receber_cheque.bairro_filial,  W_ctb_a_receber_cheque.cidade_filial,  W_ctb_a_receber_cheque.uf_filial, 
					W_ctb_a_receber_cheque.cep_filial,  W_ctb_a_receber_cheque.ddi_filial,  W_ctb_a_receber_cheque.ddd1_filial,  W_ctb_a_receber_cheque.telefone1_filial,  W_ctb_a_receber_cheque.ddd2_filial,  
					W_ctb_a_receber_cheque.telefone2_filial,  W_ctb_a_receber_cheque.cpf_cgc_consumidor,  W_ctb_a_receber_cheque.rg_ie_consumidor,  W_ctb_a_receber_cheque.razao_social_consumidor,  
					W_ctb_a_receber_cheque.endereco_consumidor,  W_ctb_a_receber_cheque.bairro_consumidor,  W_ctb_a_receber_cheque.NOME_CLIFOR_RESPONSAVEL , W_ctb_a_receber_cheque.cidade_consumidor,  W_ctb_a_receber_cheque.cep_consumidor,  
					W_ctb_a_receber_cheque.uf_consumidor,  W_ctb_a_receber_cheque.ddd_consumidor,  W_ctb_a_receber_cheque.telefone_consumidor, w_ctb_a_receber_cheque.NOME_CLIFOR as NOME_CLIFOR_OLD, W_ctb_a_receber_cheque.conta_contabil as conta_contabil_old 
				FROM dbo.CTB_CHEQUE_CARTAO Ctb_cheque_cartao join  dbo.w_ctb_a_receber_cheque W_ctb_a_receber_cheque on Ctb_cheque_cartao.EMPRESA = W_ctb_a_receber_cheque.empresa   AND Ctb_cheque_cartao.LANCAMENTO = W_ctb_a_receber_cheque.lancamento   AND Ctb_cheque_cartao.ITEM = W_ctb_a_receber_cheque.item   AND Ctb_cheque_cartao.SUB_ITEM = W_ctb_a_receber_cheque.sub_item   
				where (Ctb_cheque_cartao.empresa = cast(?v_ctb_lancamento_01.empresa as int)   AND Ctb_cheque_cartao.lancamento = cast(?v_ctb_lancamento_01.lancamento as int))
		ENDTEXT 

		
	CASE xView_Cursor == 'xv_ctb_lancamento_01_a_receber_cartao'
		TEXT TO xStruCursor NOSHOW 
			SELECT  dbo.CTB_CHEQUE_CARTAO.EMPRESA,  dbo.CTB_CHEQUE_CARTAO.LANCAMENTO,  dbo.CTB_CHEQUE_CARTAO.ITEM,   dbo.CTB_CHEQUE_CARTAO.SUB_ITEM,  dbo.CTB_CHEQUE_CARTAO.COD_CLIFOR,  dbo.CTB_CHEQUE_CARTAO.LX_TIPO_DOCUMENTO,
					dbo.CTB_CHEQUE_CARTAO.COD_FILIAL,  dbo.CTB_CHEQUE_CARTAO.DATA_EMISSAO,   dbo.CTB_CHEQUE_CARTAO.DATA_DIGITACAO,  dbo.CTB_CHEQUE_CARTAO.VENDA_DOCUMENTO,  dbo.CTB_CHEQUE_CARTAO.loja_parcela,   
					dbo.CTB_CHEQUE_CARTAO.VENDA_PARCELAMENTO,  dbo.CTB_CHEQUE_CARTAO.VENDA_TOTAL_PARCELAMENTO,   dbo.CTB_CHEQUE_CARTAO.VENCIMENTO,  dbo.CTB_CHEQUE_CARTAO.VALOR_ORIGINAL,  dbo.CTB_CHEQUE_CARTAO.CHEQUE_BANCO,  
					dbo.CTB_CHEQUE_CARTAO.CHEQUE_AGENCIA,   dbo.CTB_CHEQUE_CARTAO.CHEQUE_CONTA_CORRENTE,  dbo.CTB_CHEQUE_CARTAO.NUMERO_CHEQUE_CARTAO,   dbo.CTB_CHEQUE_CARTAO.INDICA_CARTAO,  dbo.CTB_CHEQUE_CARTAO.ORIGEM,  
					dbo.CTB_CHEQUE_CARTAO.CODIGO_ADMINISTRADORA,   dbo.CTB_CHEQUE_CARTAO.NUMERO_DEVOLUCOES,  dbo.CTB_CHEQUE_CARTAO.PRORROGACAO,   dbo.CTB_CHEQUE_CARTAO.TAXA_ADMINISTRACAO,  dbo.CTB_CHEQUE_CARTAO.CMC7_CVCARTAO,  
					dbo.CTB_CHEQUE_CARTAO.GUIA_ENVIO,   dbo.CTB_CHEQUE_CARTAO.DATA_PARA_TRANSFERENCIA,  dbo.CTB_CHEQUE_CARTAO.CONTA_PORTADOR,   dbo.CTB_CHEQUE_CARTAO.CODIGO_CONSUMIDOR,  dbo.ctb_cheque_cartao.loja_terminal,  
					dbo.ctb_cheque_cartao.loja_lancamento_caixa, dbo.w_ctb_cheque_cartao.FILIAL,  dbo.w_ctb_cheque_cartao.VENCIMENTO_REAL,   dbo.w_ctb_cheque_cartao.VALOR_A_RECEBER,   
					dbo.w_ctb_cheque_cartao.NOME_CLIFOR as NOME_CLIFOR_OLD,   dbo.w_ctb_cheque_cartao.CLIENTE_VAREJO,   dbo.w_ctb_cheque_cartao.desc_conta_portador,  dbo.w_ctb_cheque_cartao.TIPO_DOCUMENTO,   
					dbo.w_ctb_cheque_cartao.VALOR_PRINCIPAL_PAGO,  dbo.w_ctb_cheque_cartao.ADMINISTRADORA,  dbo.w_ctb_cheque_cartao.NOME_CLIFOR,  dbo.w_ctb_cheque_cartao.cgc_cpf, dbo.w_ctb_cheque_cartao.razao_social, 
					dbo.w_ctb_cheque_cartao.endereco,  dbo.w_ctb_cheque_cartao.bairro,  dbo.w_ctb_cheque_cartao.cidade,  dbo.w_ctb_cheque_cartao.uf,  dbo.w_ctb_cheque_cartao.cep,  dbo.w_ctb_cheque_cartao.ddi,   
					dbo.w_ctb_cheque_cartao.ddd1,  dbo.w_ctb_cheque_cartao.telefone1,  dbo.w_ctb_cheque_cartao.ddd2,  dbo.w_ctb_cheque_cartao.telefone2,  dbo.w_ctb_cheque_cartao.cgc_cpf_filial,  dbo.w_ctb_cheque_cartao.razao_social_filial,  
					dbo.w_ctb_cheque_cartao.endereco_filial,  dbo.w_ctb_cheque_cartao.bairro_filial,  dbo.w_ctb_cheque_cartao.cidade_filial,  dbo.w_ctb_cheque_cartao.uf_filial,  dbo.w_ctb_cheque_cartao.cep_filial,  dbo.w_ctb_cheque_cartao.ddi_filial,   
					dbo.w_ctb_cheque_cartao.ddd1_filial,  dbo.w_ctb_cheque_cartao.telefone1_filial,  dbo.w_ctb_cheque_cartao.ddd2_filial,  dbo.w_ctb_cheque_cartao.telefone2_filial,  dbo.w_ctb_cheque_cartao.cpf_cgc_consumidor, 
					dbo.w_ctb_cheque_cartao.razao_social_consumidor, dbo.w_ctb_cheque_cartao.endereco_consumidor,  dbo.w_ctb_cheque_cartao.bairro_consumidor,  dbo.w_ctb_cheque_cartao.cidade_consumidor,  dbo.w_ctb_cheque_cartao.uf_consumidor,  
					dbo.w_ctb_cheque_cartao.cep_consumidor,  dbo.w_ctb_cheque_cartao.ddd_consumidor,  dbo.w_ctb_cheque_cartao.telefone_consumidor, dbo.CTB_CHEQUE_CARTAO.moeda  
				FROM dbo.CTB_CHEQUE_CARTAO  
				INNER JOIN dbo.CTB_LX_DOCUMENTO_TIPO ON  dbo.CTB_CHEQUE_CARTAO.LX_TIPO_DOCUMENTO = dbo.CTB_LX_DOCUMENTO_TIPO.LX_TIPO_DOCUMENTO  
				INNER JOIN dbo.w_ctb_cheque_cartao ON dbo.CTB_CHEQUE_CARTAO.EMPRESA = dbo.w_ctb_cheque_cartao.EMPRESA AND  dbo.CTB_CHEQUE_CARTAO.LANCAMENTO = dbo.w_ctb_cheque_cartao.LANCAMENTO AND  dbo.CTB_CHEQUE_CARTAO.ITEM = dbo.w_ctb_cheque_cartao.ITEM AND  dbo.CTB_CHEQUE_CARTAO.SUB_ITEM = dbo.w_ctb_cheque_cartao.SUB_ITEM  
				WHERE (Ctb_cheque_cartao.EMPRESA=cast(?v_ctb_lancamento_01.EMPRESA as int) AND Ctb_cheque_cartao.LANCAMENTO=cast(?v_ctb_lancamento_01.LANCAMENTO as int) and CTB_CHEQUE_CARTAO.INDICA_CARTAO=1)
		ENDTEXT 

		
	CASE xView_Cursor == 'xv_ctb_lancamento_01_baixa_cheque_receber'
		TEXT TO xStruCursor NOSHOW 
			SELECT CTB_CHEQUE_CARTAO_MOV.EMPRESA, CTB_CHEQUE_CARTAO_MOV.LANCAMENTO, CTB_CHEQUE_CARTAO_MOV.ITEM,  CTB_CHEQUE_CARTAO_MOV.SUB_ITEM, CTB_CHEQUE_CARTAO_MOV.LANCAMENTO_MOV, CTB_CHEQUE_CARTAO_MOV.ITEM_MOV,  
					CTB_CHEQUE_CARTAO_MOV.VALOR_MOV, CTB_CHEQUE_CARTAO_MOV.VALOR_MOV_PADRAO,CTB_CHEQUE_CARTAO_MOV.CAMBIO_NA_DATA,  CTB_CHEQUE_CARTAO_MOV.ALINEA_DEVOLUCAO, W_CTB_CHEQUE_CARTAO.COD_FILIAL,  
					W_CTB_CHEQUE_CARTAO.COD_CLIFOR, W_CTB_CHEQUE_CARTAO.CONTA_PORTADOR, W_CTB_CHEQUE_CARTAO.LX_TIPO_DOCUMENTO,  W_CTB_CHEQUE_CARTAO.DATA_EMISSAO, W_CTB_CHEQUE_CARTAO.DATA_DIGITACAO, 
					W_CTB_CHEQUE_CARTAO.VENDA_DOCUMENTO,  W_CTB_CHEQUE_CARTAO.loja_parcela, W_CTB_CHEQUE_CARTAO.VENDA_PARCELAMENTO,  W_CTB_CHEQUE_CARTAO.VENDA_TOTAL_PARCELAMENTO, W_CTB_CHEQUE_CARTAO.VENCIMENTO,  
					W_CTB_CHEQUE_CARTAO.RATEIO_CENTRO_CUSTO, W_CTB_CHEQUE_CARTAO.DESC_RATEIO_CENTRO_CUSTO, W_CTB_CHEQUE_CARTAO.RATEIO_FILIAL, W_CTB_CHEQUE_CARTAO.DESC_RATEIO_FILIAL, W_CTB_CHEQUE_CARTAO.CONTA_CONTABIL, 
					W_CTB_CHEQUE_CARTAO.DESC_CONTA, W_CTB_CHEQUE_CARTAO.VENCIMENTO_REAL, W_CTB_CHEQUE_CARTAO.VALOR_A_RECEBER_PADRAO, W_CTB_CHEQUE_CARTAO.VALOR_ORIGINAL_PADRAO, W_CTB_CHEQUE_CARTAO.CAMBIO_FIXO_PGTO, 
					W_CTB_CHEQUE_CARTAO.CAMBIO_NA_DATA_EMISSAO, W_CTB_CHEQUE_CARTAO.MOEDA, W_CTB_CHEQUE_CARTAO.INDICA_CARTAO, W_CTB_CHEQUE_CARTAO.ORIGEM,  W_CTB_CHEQUE_CARTAO.CODIGO_ADMINISTRADORA, 
					W_CTB_CHEQUE_CARTAO.CODIGO_CONSUMIDOR,  W_CTB_CHEQUE_CARTAO.NUMERO_DEVOLUCOES, W_CTB_CHEQUE_CARTAO.NR_DEVOLUCOES_CALC, W_CTB_CHEQUE_CARTAO.PRORROGACAO, W_CTB_CHEQUE_CARTAO.VALOR_ORIGINAL,  
					W_CTB_CHEQUE_CARTAO.VALOR_A_RECEBER, W_CTB_CHEQUE_CARTAO.TAXA_ADMINISTRACAO,  W_CTB_CHEQUE_CARTAO.CHEQUE_BANCO, W_CTB_CHEQUE_CARTAO.CHEQUE_AGENCIA,  W_CTB_CHEQUE_CARTAO.CHEQUE_CONTA_CORRENTE, 
					W_CTB_CHEQUE_CARTAO.NUMERO_CHEQUE_CARTAO,  W_CTB_CHEQUE_CARTAO.CMC7_CVCARTAO, W_CTB_CHEQUE_CARTAO.GUIA_ENVIO, W_CTB_CHEQUE_CARTAO.TIPO_DOCUMENTO, Space(6) as SERIE_NF, Space(40) as NOME_RECIBO,  
					W_CTB_CHEQUE_CARTAO.DESC_CONTA_PORTADOR, W_CTB_CHEQUE_CARTAO.FILIAL, W_CTB_CHEQUE_CARTAO.CLIENTE_VAREJO,  W_CTB_CHEQUE_CARTAO.NOME_CLIFOR, W_CTB_CHEQUE_CARTAO.COD_CLIFOR_RESPONSAVEL,  
					W_CTB_CHEQUE_CARTAO.NOME_CLIFOR_RESPONSAVEL, W_CTB_CHEQUE_CARTAO.RAZAO_SOCIAL,  W_CTB_CHEQUE_CARTAO.VALOR_ORIGINAL, W_CTB_CHEQUE_CARTAO.VALOR_PRINCIPAL_PAGO, W_CTB_CHEQUE_CARTAO.HISTORICO, W_CTB_CHEQUE_CARTAO.CODIGO_HISTORICO 
				FROM CTB_CHEQUE_CARTAO_MOV INNER JOIN W_CTB_CHEQUE_CARTAO ON CTB_CHEQUE_CARTAO_MOV.EMPRESA = W_CTB_CHEQUE_CARTAO.EMPRESA AND  CTB_CHEQUE_CARTAO_MOV.LANCAMENTO_MOV = W_CTB_CHEQUE_CARTAO.LANCAMENTO AND  CTB_CHEQUE_CARTAO_MOV.ITEM_MOV = W_CTB_CHEQUE_CARTAO.ITEM AND  CTB_CHEQUE_CARTAO_MOV.SUB_ITEM = W_CTB_CHEQUE_CARTAO.SUB_ITEM 
				WHERE ( Ctb_cheque_cartao_mov.LANCAMENTO=convert(int,?v_ctb_lancamento_01.lancamento) and Ctb_cheque_cartao_mov.EMPRESA= convert(int, ?v_ctb_lancamento_01.empresa) )
		ENDTEXT 

		
	CASE xView_Cursor == 'xv_ctb_lancamento_01_baixa_cartao_receber'
		TEXT TO xStruCursor NOSHOW 
			SELECT CTB_CHEQUE_CARTAO_MOV.EMPRESA, CTB_CHEQUE_CARTAO_MOV.LANCAMENTO, CTB_CHEQUE_CARTAO_MOV.ITEM,  CTB_CHEQUE_CARTAO_MOV.SUB_ITEM, CTB_CHEQUE_CARTAO_MOV.LANCAMENTO_MOV, CTB_CHEQUE_CARTAO_MOV.ITEM_MOV,  CTB_CHEQUE_CARTAO_MOV.VALOR_MOV, CTB_CHEQUE_CARTAO_MOV.VALOR_MOV_PADRAO, CTB_CHEQUE_CARTAO_MOV.CAMBIO_NA_DATA, CTB_CHEQUE_CARTAO_MOV.ALINEA_DEVOLUCAO, CTB_CHEQUE_CARTAO.COD_FILIAL,  
					CTB_CHEQUE_CARTAO.COD_CLIFOR, CTB_CHEQUE_CARTAO.CONTA_PORTADOR, CTB_CHEQUE_CARTAO.LX_TIPO_DOCUMENTO,  CTB_CHEQUE_CARTAO.DATA_EMISSAO, CTB_CHEQUE_CARTAO.DATA_DIGITACAO, CTB_CHEQUE_CARTAO.VENDA_DOCUMENTO,  CTB_CHEQUE_CARTAO.loja_parcela, CTB_CHEQUE_CARTAO.VENDA_PARCELAMENTO,  CTB_CHEQUE_CARTAO.VENDA_TOTAL_PARCELAMENTO, CTB_CHEQUE_CARTAO.VENCIMENTO,  
					W_CTB_CHEQUE_CARTAO_SALDO.VENCIMENTO_REAL, CTB_CHEQUE_CARTAO.INDICA_CARTAO, CTB_CHEQUE_CARTAO.ORIGEM,  CTB_CHEQUE_CARTAO.CODIGO_ADMINISTRADORA, administradoras_cartao.administradora, CTB_CHEQUE_CARTAO.CODIGO_CONSUMIDOR,  CTB_CHEQUE_CARTAO.NUMERO_DEVOLUCOES, CTB_CHEQUE_CARTAO.PRORROGACAO, CTB_CHEQUE_CARTAO.VALOR_ORIGINAL,  
					W_CTB_CHEQUE_CARTAO_SALDO.VALOR_A_RECEBER, CTB_CHEQUE_CARTAO.TAXA_ADMINISTRACAO,  CTB_CHEQUE_CARTAO.CHEQUE_BANCO, CTB_CHEQUE_CARTAO.CHEQUE_AGENCIA,  CTB_CHEQUE_CARTAO.CHEQUE_CONTA_CORRENTE, CTB_CHEQUE_CARTAO.NUMERO_CHEQUE_CARTAO,  CTB_CHEQUE_CARTAO.CMC7_CVCARTAO, CTB_CHEQUE_CARTAO.GUIA_ENVIO, 
					CTB_LX_DOCUMENTO_TIPO.TIPO_DOCUMENTO, CTB_LX_DOCUMENTO_TIPO.SERIE_NF, CTB_LX_DOCUMENTO_TIPO.NOME_RECIBO,  CTB_CONTA_PLANO.DESC_CONTA AS DESC_CONTA_PORTADOR, FILIAIS.FILIAL, CLIENTES_VAREJO.CLIENTE_VAREJO,  CADASTRO_CLI_FOR.NOME_CLIFOR, CADASTRO_CLI_FOR.RAZAO_SOCIAL,  W_CTB_CHEQUE_CARTAO_SALDO.VALOR_PRINCIPAL_PAGO 
				FROM CTB_CHEQUE_CARTAO_MOV  
				INNER JOIN CTB_CHEQUE_CARTAO ON CTB_CHEQUE_CARTAO_MOV.EMPRESA = CTB_CHEQUE_CARTAO.EMPRESA AND  CTB_CHEQUE_CARTAO_MOV.LANCAMENTO_MOV = CTB_CHEQUE_CARTAO.LANCAMENTO AND  CTB_CHEQUE_CARTAO_MOV.ITEM_MOV = CTB_CHEQUE_CARTAO.ITEM AND  CTB_CHEQUE_CARTAO_MOV.SUB_ITEM = CTB_CHEQUE_CARTAO.SUB_ITEM  
				INNER JOIN W_CTB_CHEQUE_CARTAO_SALDO ON CTB_CHEQUE_CARTAO.EMPRESA = W_CTB_CHEQUE_CARTAO_SALDO.EMPRESA AND  CTB_CHEQUE_CARTAO.LANCAMENTO = W_CTB_CHEQUE_CARTAO_SALDO.LANCAMENTO AND  CTB_CHEQUE_CARTAO.ITEM = W_CTB_CHEQUE_CARTAO_SALDO.ITEM AND  CTB_CHEQUE_CARTAO.SUB_ITEM = W_CTB_CHEQUE_CARTAO_SALDO.SUB_ITEM  
				INNER JOIN CTB_LX_DOCUMENTO_TIPO ON  CTB_CHEQUE_CARTAO.LX_TIPO_DOCUMENTO = CTB_LX_DOCUMENTO_TIPO.LX_TIPO_DOCUMENTO  
				LEFT OUTER JOIN CADASTRO_CLI_FOR ON CTB_CHEQUE_CARTAO.COD_CLIFOR = CADASTRO_CLI_FOR.COD_CLIFOR  
				LEFT OUTER JOIN FILIAIS ON CTB_CHEQUE_CARTAO.COD_FILIAL = FILIAIS.COD_FILIAL  
				LEFT OUTER JOIN CTB_CONTA_PLANO ON CTB_CHEQUE_CARTAO.CONTA_PORTADOR = CTB_CONTA_PLANO.CONTA_CONTABIL 
				LEFT OUTER JOIN CLIENTES_VAREJO ON CTB_CHEQUE_CARTAO.CODIGO_CONSUMIDOR = CLIENTES_VAREJO.CODIGO_CLIENTE  
				left outer join administradoras_cartao on ctb_cheque_cartao.codigo_administradora=administradoras_cartao.codigo_administradora 
				WHERE (Ctb_cheque_cartao_mov.EMPRESA= cast(?v_ctb_lancamento_01.empresa as int) AND Ctb_cheque_cartao_mov.LANCAMENTO= cast(?v_ctb_lancamento_01.lancamento as int))
		ENDTEXT 


	CASE xView_Cursor == 'xv_ctb_lancamento_01_bordero'
		TEXT TO xStruCursor NOSHOW 
			SELECT Ctb_bordero.EMPRESA, Ctb_bordero.LANCAMENTO, Ctb_bordero.CONTA_PORTADOR, Ctb_bordero.LAYOUT, Ctb_bordero.PROCESSADO,  Ctb_bordero.LX_TIPO_BORDERO, Ctb_bordero.CONTRATO_TAXA, Ctb_bordero.CONTRATO_DESAGIO, Ctb_bordero.DATA_CRIACAO,  
					Ctb_bordero.NOME_ARQUIVO, Ctb_bordero.DATA_COMUNICACAO, Ctb_bordero.OBS, Ctb_bordero_layout.DESC_LAYOUT,  Ctb_bordero_layout.DIRETORIO_ARQUIVO, Ctb_bordero_layout.MASCARA_ARQUIVO, Ctb_bordero_layout.SEQUENCIAL_LAYOUT,  
					Ctb_bordero_layout.TAMANHO_REGISTRO, Ctb_bordero_layout.LISTA_CODIGO_LIQUIDACAO, Ctb_bordero_layout.SEQUENCIAL_NUMERO_BOLETA,  Ctb_bordero_layout.SEQUENCIAL_NUMERO_BOLETA_FINAL, Ctb_bordero_layout.INATIVO, Ctb_bordero_layout.LOTE, Ctb_bordero_layout.TRANSACAO,  
					Ctb_conta_plano.ID_CARTEIRA_COBRANCA, Ctb_carteira_cobranca.DESCONTADA, Ctb_carteira_cobranca.CARTEIRA, Ctb_conta_plano.DESC_CONTA,  Ctb_conta_plano.CODIGO_RESUMIDO, Ctb_bordero.CONTRATO_IOF, ctb_bordero_layout.gerar_numero_bancario, 
					CTB_CONTA_CORRENTE.BANCO, CTB_CONTA_CORRENTE.AGENCIA, CTB_CONTA_CORRENTE.NUMERO_CONTA_CORRENTE, ctb_bordero.arquivo, ctb_bordero_layout.mascara_data, ctb_bordero_layout.gera_lote_banco, ctb_bordero_layout.INDICA_TERMINADOR 
				FROM CTB_BORDERO JOIN CTB_BORDERO_LAYOUT ON CTB_BORDERO_LAYOUT.LAYOUT=CTB_BORDERO.LAYOUT 
				LEFT JOIN CTB_CONTA_PLANO ON CTB_BORDERO.CONTA_PORTADOR=CTB_CONTA_PLANO.CONTA_CONTABIL 
				LEFT JOIN CTB_CARTEIRA_COBRANCA ON CTB_CONTA_PLANO.ID_CARTEIRA_COBRANCA=CTB_CARTEIRA_COBRANCA.ID_CARTEIRA_COBRANCA 
				LEFT JOIN CTB_CONTA_LAYOUT ON CTB_BORDERO.LAYOUT=CTB_CONTA_LAYOUT.LAYOUT AND CTB_BORDERO.CONTA_PORTADOR=CTB_CONTA_LAYOUT.CONTA_PORTADOR 
				LEFT JOIN CTB_CONTA_PLANO CTB_CONTA_CORRENTE ON CTB_CONTA_LAYOUT.CONTA_CORRENTE=CTB_CONTA_CORRENTE.CONTA_CONTABIL 
				WHERE (Ctb_bordero.EMPRESA = cast(?v_ctb_lancamento_01.empresa as int)) AND (Ctb_bordero.LANCAMENTO = cast(?v_ctb_lancamento_01.lancamento as int))
		ENDTEXT 

		
	CASE xView_Cursor == 'xv_ctb_lancamento_01_bordero_rec_parc'
		TEXT TO xStruCursor NOSHOW 
			SELECT CTB_BORDERO_PARCELA_CMD.OCORRENCIA,CTB_BORDERO_PARCELA_CMD.EMPRESA,CTB_BORDERO_PARCELA_CMD.LANCAMENTO_MOV,CTB_BORDERO_PARCELA_CMD.OCORRENCIA_IGNORADA,CTB_BORDERO_PARCELA_CMD.ITEM_MOV,CTB_BORDERO_PARCELA_CMD.ID_PARCELA,
					CTB_BORDERO_PARCELA_CMD.LX_TIPO_OCORRENCIA,CTB_BORDERO_PARCELA_CMD.DATA_OCORRENCIA,CTB_BORDERO_PARCELA_CMD.LANCAMENTO,CTB_LX_BORDERO_OCORRENCIA.DESCRICAO_OCORRENCIA,CTB_A_RECEBER_PARCELA.VENCIMENTO,CTB_A_RECEBER_PARCELA.NUMERO_BANCARIO,
					CTB_A_RECEBER_PARCELA.VALOR_ORIGINAL_PADRAO,CTB_A_RECEBER_PARCELA.VALOR_ORIGINAL,CTB_A_RECEBER_PARCELA.DIAS_PRORROGADOS,CTB_A_RECEBER_PARCELA.DESCONTO_VENC,CTB_A_RECEBER_PARCELA.DATA_DESCONTO_VENC,CTB_A_RECEBER_PARCELA.AGENCIA,
					CTB_A_RECEBER_FATURA.FATURA,CTB_A_RECEBER_FATURA.LX_TIPO_DOCUMENTO,CTB_A_RECEBER_FATURA.CODIGO_CONSUMIDOR,CTB_A_RECEBER_FATURA.EMISSAO,CTB_A_RECEBER_FATURA.DOCUMENTO,CTB_A_RECEBER_FATURA.FATURA_IMPRESSA,CTB_A_RECEBER_FATURA.POSSUI_SAIDA,
					CTB_A_RECEBER_FATURA.COMISSAO_GERENTE, CTB_A_RECEBER_FATURA.PORCENTAGEM_ACERTO,CTB_A_RECEBER_FATURA.COMISSAO,CTB_A_RECEBER_FATURA.CAMBIO_NA_DATA_EMISSAO,CTB_A_RECEBER_FATURA.JUROS_POR_ATRASO,CTB_A_RECEBER_FATURA.MULTA_POR_ATRASO,
					CTB_A_RECEBER_FATURA.SERIE,CTB_A_RECEBER_FATURA.NUMERO_PARCELAS,CTB_A_RECEBER_FATURA.COD_REPRESENTANTE,CTB_A_RECEBER_FATURA.COD_REPRESENTANTE_GERENTE,CTB_A_RECEBER_FATURA.MOEDA,CTB_A_RECEBER_FATURA.COD_CLIFOR,CTB_A_RECEBER_FATURA.COD_EMISSOR, 
					ISNULL(CV.CLIENTE_VAREJO,A.NOME_CLIFOR)NOME_CLIFOR, ISNULL(CV.CPF_CGC,A.CGC_CPF)CGC_CPF, ISNULL(CV.RG_IE,A.RG_IE)RG_IE,  CAST(CASE WHEN CV.PF_PJ IS NULL THEN A.PJ_PF ELSE CASE WHEN CV.PF_PJ = 1 THEN 0 ELSE 1 END END AS BIT) AS PJ_PF,ISNULL(CV.CADASTRAMENTO,A.CADASTRAMENTO) CADASTRAMENTO, 
					ISNULL(CASE WHEN CV.CLIENTE_VAREJO=NULL THEN NULL ELSE '' END,A.CONTATO)CONTATO, ISNULL(CV.CLIENTE_VAREJO,A.RAZAO_SOCIAL)RAZAO_SOCIAL, CASE WHEN CV.ENDERECO IS NOT NULL THEN ISNULL(LTRIM(RTRIM(ISNULL(CV.TIPO_LOGRADOURO,''))+' ')+LTRIM(RTRIM(ISNULL(CV.LOGRADOURO,''))+' ')+LTRIM(RTRIM(ISNULL(CV.ENDERECO,''))+' ')+LTRIM(RTRIM(ISNULL(CV.NUMERO,''))+' ')+RTRIM(ISNULL(CV.COMPLEMENTO,'')),'') ELSE A.ENDERECO END ENDERECO, 
					ISNULL(CV.BAIRRO,A.BAIRRO)BAIRRO, ISNULL(CV.CIDADE,A.CIDADE)CIDADE, ISNULL(CV.UF,A.UF)UF, ISNULL(CV.CEP,A.CEP)CEP, ISNULL(CV.PAIS,A.PAIS)PAIS, ISNULL(CASE WHEN CV.CLIENTE_VAREJO=NULL THEN NULL ELSE '' END,A.DDI)DDI, ISNULL(CV.DDD,A.DDD1)DDD1, ISNULL(CV.TELEFONE,A.TELEFONE1)TELEFONE1, ISNULL(CASE WHEN CV.CLIENTE_VAREJO=NULL THEN NULL ELSE '' END,A.TELEFONE2)TELEFONE2, 
					ISNULL(CASE WHEN CV.CLIENTE_VAREJO=NULL THEN NULL ELSE '' END,A.FAX)FAX, ISNULL(CASE WHEN CV.CLIENTE_VAREJO=NULL THEN NULL ELSE '' END,A.RAMAL1)RAMAL1, ISNULL(CASE WHEN CV.CLIENTE_VAREJO=NULL THEN NULL ELSE '' END,A.DDD2)DDD2, ISNULL(CASE WHEN CV.CLIENTE_VAREJO=NULL THEN NULL ELSE '' END,A.RAMAL2)RAMAL2, ISNULL(CASE WHEN CV.CLIENTE_VAREJO=NULL THEN NULL ELSE '' END,A.DDDFAX)DDDFAX, 
					ISNULL(CASE WHEN CV.CLIENTE_VAREJO=NULL THEN NULL ELSE '' END,A.EMAIL)EMAIL, CASE WHEN CV.ENDERECO IS NOT NULL THEN ISNULL(LTRIM(RTRIM(ISNULL(CV.TIPO_LOGRADOURO,''))+' ')+LTRIM(RTRIM(ISNULL(CV.LOGRADOURO,''))+' ')+LTRIM(RTRIM(ISNULL(CV.ENDERECO,''))+' ')+LTRIM(RTRIM(ISNULL(CV.NUMERO,''))+' ')+RTRIM(ISNULL(CV.COMPLEMENTO,'')),'') ELSE A.COBRANCA_ENDERECO END COBRANCA_ENDERECO, 
					ISNULL(CV.CIDADE,A.COBRANCA_CIDADE)COBRANCA_CIDADE, ISNULL(CV.BAIRRO,A.COBRANCA_BAIRRO)COBRANCA_BAIRRO, ISNULL(CV.UF,A.COBRANCA_UF)COBRANCA_UF, ISNULL(CV.CEP,A.COBRANCA_CEP)COBRANCA_CEP, ISNULL(CV.TELEFONE,A.COBRANCA_TELEFONE)COBRANCA_TELEFONE, ISNULL(CASE WHEN CV.CLIENTE_VAREJO=NULL THEN NULL ELSE '' END,A.COBRANCA_DDI)COBRANCA_DDI, ISNULL(CV.DDD,A.COBRANCA_DDD)COBRANCA_DDD, 
					ISNULL(CV.CPF_CGC,A.COBRANCA_CGC)COBRANCA_CGC, ISNULL(CV.RG_IE,A.COBRANCA_IE)COBRANCA_IE, ISNULL(CV.PAIS,A.COBRANCA_PAIS)COBRANCA_PAIS, CASE WHEN CV.ENDERECO IS NOT NULL THEN ISNULL(LTRIM(RTRIM(ISNULL(CV.TIPO_LOGRADOURO,''))+' ')+LTRIM(RTRIM(ISNULL(CV.LOGRADOURO,''))+' ')+LTRIM(RTRIM(ISNULL(CV.ENDERECO,''))+' ')+LTRIM(RTRIM(ISNULL(CV.NUMERO,''))+' ')+RTRIM(ISNULL(CV.COMPLEMENTO,'')),'') ELSE A.ENTREGA_ENDERECO END ENTREGA_ENDERECO, 
					ISNULL(CV.CIDADE,A.ENTREGA_CIDADE)ENTREGA_CIDADE, ISNULL(CV.UF,A.ENTREGA_UF)ENTREGA_UF, ISNULL(CV.BAIRRO,A.ENTREGA_BAIRRO)ENTREGA_BAIRRO, ISNULL(CV.CEP,A.ENTREGA_CEP)ENTREGA_CEP, ISNULL(CASE WHEN CV.CLIENTE_VAREJO=NULL THEN NULL ELSE '' END, A.ENTREGA_DDI)ENTREGA_DDI, ISNULL(CV.DDD,A.ENTREGA_DDD)ENTREGA_DDD, ISNULL(CV.TELEFONE,A.ENTREGA_TELEFONE)ENTREGA_TELEFONE, ISNULL(CV.CPF_CGC,A.ENTREGA_CGC)ENTREGA_CGC, 
					ISNULL(CV.RG_IE,A.ENTREGA_IE)ENTREGA_IE, ISNULL(CV.PAIS,A.ENTREGA_PAIS)ENTREGA_PAIS, ISNULL(CASE WHEN CV.CLIENTE_VAREJO=NULL THEN NULL ELSE '' END,A.CC_AGENCIA)CC_AGENCIA, ISNULL(CASE WHEN CV.CLIENTE_VAREJO=NULL THEN NULL ELSE '' END,A.CC_CONTA)CC_CONTA, ISNULL(CASE WHEN CV.CLIENTE_VAREJO=NULL THEN NULL ELSE '' END,A.CC_NOME_AGENCIA)CC_NOME_AGENCIA, 
					SALDO.VENCIMENTO_REAL, SALDO.VALOR_A_RECEBER,  SALDO.VALOR_A_RECEBER_PADRAO,SALDO.SALDO_PRINCIPAL_DEVIDO, SALDO.SALDO_MULTA_GERADA, SALDO.SALDO_JUROS_GERADO,SALDO.SALDO_DESCONTO_CONCEDIDO,  SALDO.TOTAL_PRINCIPAL_RECEBIDO, SALDO.TOTAL_MULTA_PAGA,SALDO.TOTAL_JUROS_PAGO, SALDO.TOTAL_DESCONTO_EFETIVADO,  CTB_BORDERO_LAYOUT.LAYOUT, CTB_BORDERO_LAYOUT.DESC_LAYOUT,
					CTB_BORDERO_LAYOUT.DIRETORIO_ARQUIVO, CTB_BORDERO_LAYOUT.MASCARA_ARQUIVO,  CTB_BORDERO_LAYOUT.SEQUENCIAL_LAYOUT, CTB_BORDERO_LAYOUT.TAMANHO_REGISTRO,CTB_BORDERO_LAYOUT.LISTA_CODIGO_LIQUIDACAO, CTB_BORDERO_LAYOUT.SEQUENCIAL_NUMERO_BOLETA,  CTB_BORDERO_LAYOUT.SEQUENCIAL_NUMERO_BOLETA_FINAL,CTB_BORDERO_LAYOUT.INATIVO,  
					CTB_BORDERO_LAYOUT.LOTE, CTB_CONTA_LAYOUT.CONTA_PORTADOR, CTB_CONTA_LAYOUT.CONTA_CORRENTE,CTB_CONTA_CORRENTE.BANCO AS BANCO_CONTA_CORRENTE, CTB_CONTA_CORRENTE.AGENCIA AS AGENCIA_CONTA_CORRENTE,  CTB_CONTA_CORRENTE.NUMERO_CONTA_CORRENTE 
				FROM CTB_BORDERO_PARCELA_CMD INNER JOIN CTB_A_RECEBER_PARCELA ON CTB_BORDERO_PARCELA_CMD.EMPRESA=CTB_A_RECEBER_PARCELA.EMPRESA and CTB_BORDERO_PARCELA_CMD.LANCAMENTO_MOV=CTB_A_RECEBER_PARCELA.LANCAMENTO AND CTB_BORDERO_PARCELA_CMD.ITEM_MOV=CTB_A_RECEBER_PARCELA.ITEM AND CTB_BORDERO_PARCELA_CMD.ID_PARCELA=CTB_A_RECEBER_PARCELA.ID_PARCELA 
				INNER JOIN CTB_A_RECEBER_FATURA ON CTB_A_RECEBER_PARCELA.EMPRESA=CTB_A_RECEBER_FATURA.EMPRESA AND CTB_A_RECEBER_PARCELA.LANCAMENTO=CTB_A_RECEBER_FATURA.LANCAMENTO AND CTB_A_RECEBER_PARCELA.ITEM=CTB_A_RECEBER_FATURA.ITEM 
				INNER JOIN CADASTRO_CLI_FOR A  ON CTB_A_RECEBER_FATURA.COD_CLIFOR=A.COD_CLIFOR 
				INNER JOIN CTB_LX_BORDERO_OCORRENCIA  ON CTB_BORDERO_PARCELA_CMD.LX_TIPO_OCORRENCIA=CTB_LX_BORDERO_OCORRENCIA.LX_TIPO_OCORRENCIA 
				INNER JOIN W_CTB_A_RECEBER_PARCELA_SALDO SALDO  ON CTB_A_RECEBER_PARCELA.EMPRESA=SALDO.EMPRESA AND CTB_A_RECEBER_PARCELA.LANCAMENTO=SALDO.LANCAMENTO AND CTB_A_RECEBER_PARCELA.ITEM=SALDO.ITEM AND CTB_A_RECEBER_PARCELA.ID_PARCELA=SALDO.ID_PARCELA 
				INNER JOIN CTB_BORDERO  ON CTB_BORDERO_PARCELA_CMD.EMPRESA=CTB_BORDERO.EMPRESA AND CTB_BORDERO_PARCELA_CMD.LANCAMENTO=CTB_BORDERO.LANCAMENTO 
				INNER JOIN CTB_BORDERO_LAYOUT  ON CTB_BORDERO.LAYOUT=CTB_BORDERO_LAYOUT.LAYOUT 
				INNER JOIN CTB_CONTA_LAYOUT ON CTB_BORDERO.LAYOUT=CTB_CONTA_LAYOUT.LAYOUT AND CTB_BORDERO.CONTA_PORTADOR=CTB_CONTA_LAYOUT.CONTA_PORTADOR 
				INNER JOIN CTB_CONTA_PLANO CTB_CONTA_CORRENTE ON CTB_CONTA_LAYOUT.CONTA_CORRENTE=CTB_CONTA_CORRENTE.CONTA_CONTABIL LEFT JOIN CLIENTES_VAREJO CV ON CTB_A_RECEBER_FATURA.CODIGO_CONSUMIDOR=CV.CODIGO_CLIENTE  
				WHERE ctb_bordero_parcela_cmd.EMPRESA=cast(?v_ctb_lancamento_01.EMPRESA as INT) AND ctb_bordero_parcela_cmd.LANCAMENTO=cast(?v_ctb_lancamento_01.LANCAMENTO as int)
		ENDTEXT 


	OTHERWISE
		RETURN ''
	ENDCASE


RETURN xStruCursor
*---------------------------------------------------------------------------------------------------------------------------------------------------*
