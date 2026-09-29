*-- Chamadas a Diversas Forms Aux. de Relatórios (Originária de Diversas Telas)
*-- 07/10/2024 - VALMIR SOARES - LINXERP-20077 - SPK 2.24.010 - Correção erro devido modo de chamar form auxiliar
*-- Ult. Atualização: Fev-2008
*---------------------------------------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------------------------------------*
Function Setar_Proc_Zebra && Setar Proc para Impressao na Zebra

	*---- Verifica existencia do arquivo prg (que contem o codigo zebra do cliente)
	xArq      = 'O_' + allt(strt(upper(wcontrole),'LX','')) + '.pp_arquivo_codigo_zebra'
	xArqZebra = &xarq

	if !file(xArqZebra)
		MessageBox( f_traduz('Atencão! Arquivo ') + xArqZebra + f_traduz(' Não Existe, Verifique...') )
		Return .f.
	else
		Set Proc to &xArqZebra Addi
	endif	
	
Return .t.
*---------------------------------------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------------------------------------*
Function Pegar_Seq_Zebra          && Ativa a Form com a Opção de Código INICIAL de Sequencial da impressora.
Parameters xSeq, xOri

	*/do form lxoprel_zebra with xSeq,xOri
	System.ExecuteForm('lxoprel_zebra',xSeq,xOri)

Return .t.
*---------------------------------------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------------------------------------*
Function Pegar_Obs_Adicional      && Ativa a Form com a Opção de Código INICIAL de Sequencial da impressora.
Parameters xPadrao

	*/do form lxoprel_obs with xPadrao
	System.ExecuteForm('lxoprel_obs',xPadrao)

Return .t.
*---------------------------------------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------------------------------------*
Function Set_Porta                && Ativa a Form com a Opção de Código INICIAL de Sequencial da impressora.
Parameters xTipo

  */do form lxoprel_set_porta with xTipo,'PRODUTO',IIF(xTipo='PRE',.f.,.t.)
	System.ExecuteForm('lxoprel_set_porta',xTipo,'PRODUTO',IIF(xTipo='PRE',.f.,.t.))

Return .t.
*---------------------------------------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------------------------------------*
Function Tamanho_Quebra_Zebra     && Define a Quebra
Parameters xQuebra

	*/do form lxoprel_quebra to xPausa
	System.ExecuteForm('lxoprel_quebra')

Return (xPausa)
*---------------------------------------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------------------------------------*
Function Pegar_TabPreco           && Ativa a Form com a Opção de selecionar uma tabela de Preço

	*/do form lxoprel_tabpreco
	System.ExecuteForm('lxoprel_tabpreco')

Return .t.
*---------------------------------------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------------------------------------*
Procedure Obter_Mult_Tabelas

	*/Do Form lxoprel_MultTab
	System.ExecuteForm('lxoprel_MultTab')

Return .t.
*---------------------------------------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------------------------------------*
Function Obter_Qtde               && Obter uma quantidade
Param xQtde_Sugest

	xQtde_Sugest = iif(type('xQtde_Sugest')<>'N',1,xQtde_Sugest)
	*/do form lxoprel_qtde with xQtde_Sugest
	System.ExecuteForm('lxoprel_qtde',xQtde_Sugest)
	
Return .t.
*---------------------------------------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------------------------------------*
Procedure Obter_Data_Base         && Obter Uma Data

	*/do form lxoprel_data
	System.ExecuteForm('lxoprel_data')

Return .t.

*------------------------------------------------------------------------------------------------------------------------*
Function Setar_Proc_Pack          && Ativa a Form com a Opção para selecionar Pack

	*/do form LxOpRel_EtqPack
	System.ExecuteForm('LxOpRel_EtqPack')

Return .t.


*------------------------------------------------------------------------------------------------------------------------*
Function f_Etiq_Pausa

	f_msg(['Aguarde a Impressora Zerar Buffer, Depois Pressione Enter Para Continuar...'])

Return .t.
*---------------------------------------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------------------------------------*
Function f_Etiq_Quebra_002006
para xLim

	select *, 00000 as quebra from v_etiquetas_00 into cursor tmp_bar where .f.
	sele tmp_bar
	=afields(xcampos)
	create cursor tmp_etq from array xcampos

	sele v_etiquetas_00
	go top
	xSld = 0

	Scan
		x_produto      = PRODUTO
		x_cor_produto  = COR_PRODUTO
		x_desc_cor     = DESC_COR_PRODUTO
		x_codigo       = CODIGO_BARRA
		x_tamanho      = TAMANHO
		x_grade        = GRADE
		x_origem       = ORIGEM
		x_desc_produto = DESC_PRODUTO

		xqtde  = QTDE_ETIQ
		xAcum  = xSld + xqtde

		xCompl = (xLim - xSld)
		xResto = xqtde - xCompl

		if xResto<=0
			xCompl = xqtde
		endif
		
		sele tmp_etq
		Append Blank
		Repl PRODUTO with x_produto, COR_PRODUTO with x_cor_produto, DESC_COR_PRODUTO with x_desc_cor, ;
		CODIGO_BARRA with x_codigo, TAMANHO with x_tamanho, GRADE with x_grade,;
		QTDE_ETIQ with xCompl , ORIGEM with x_origem, DESC_PRODUTO with x_desc_produto
		sele v_etiquetas_00

		Do whil xResto >= xLim
			sele tmp_etq
			Append Blank
			Repl PRODUTO with x_produto, COR_PRODUTO with x_cor_produto, DESC_COR_PRODUTO with x_desc_cor, ;
			CODIGO_BARRA with x_codigo, TAMANHO with x_tamanho, GRADE with x_grade,;
			QTDE_ETIQ with xLim , ORIGEM with x_origem, DESC_PRODUTO with x_desc_produto
			sele v_etiquetas_00
			xResto = (xResto-xLim)	
		Enddo

		if xResto > 0 
			sele tmp_etq
			Append Blank
			Repl PRODUTO with x_produto, COR_PRODUTO with x_cor_produto, DESC_COR_PRODUTO with x_desc_cor, ;
			CODIGO_BARRA with x_codigo, TAMANHO with x_tamanho, GRADE with x_grade,;
			QTDE_ETIQ with xResto , ORIGEM with x_origem, DESC_PRODUTO with x_desc_produto
			sele v_etiquetas_00
		endif

		xSld = xResto
		sele v_etiquetas_00
	EndScan

	sele v_etiquetas_00
	sum qtde_etiq to xqIni
	go top

	sele tmp_etq
	sum qtde_etiq to xqFim

	if (xqFim - xqFim) # 0
		f_msg(['Diferença na Geração das quebras, tente novamente...'])
		Return .f.
	endif

	sele v_etiquetas_00
	use
	create view v_etiquetas_00 as select * from tmp_etq
	use v_etiquetas_00
	go top

	xqtde   = 0
	xQuebra = 1

	scan
		replace quebra with xQuebra
		xqtde = (xqtde + qtde_etiq)
		if xqtde => xLim
			xQuebra = xQuebra + 1
			xqtde   = 0
		endif
	endscan

	sele v_etiquetas_00
	go top
	
Return .t.
*---------------------------------------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------------------------------------*
PROCEDURE PxGDI_SaveImg_AsBMP  && Copia Qualquer Imagem para formato BMP (Exemplo de Uso: Relatórios das Telas 008021 e 040001)
PARAMETERS pFoto

	IF RIGHT(UPPER(pFoto),3)='BMP'
		RETURN (pFoto)
	ENDIF 

	TRY 
		oIniGdi = CreateObject("gpInit")
		oImg    = CreateObject("GDIPImage")
		oImg.Load(pFoto)

		xfoto_dest = wUserTempPath+"Tmp_" + JUSTSTEM(pFoto) 
		oImg.SaveAsBMP(xfoto_dest)

		xfoto_copy = xfoto_dest + '.bmp'
		IF !FILE(xfoto_copy)
			RETURN (pFoto)
		ENDIF
		
		xCompatible = SET('COMPATIBLE')
		SET COMPATIBLE ON
		IF FSIZE(xfoto_copy)>15000000
			WAIT WINDOW 'Imagem Muito Grande, Verifique:'+CHR(13)+xfoto TIMEOUT 5
			xfoto_copy = pFoto
		ENDIF
		SET COMPATIBLE &xCompatible
	CATCH 
		xfoto_copy = pFoto
	ENDTRY 

	RETURN (xfoto_copy)

ENDFUNC
*---------------------------------------------------------------------------------------------------------------------------------------------------*
