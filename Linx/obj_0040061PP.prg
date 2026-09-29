*****************************************************************************
** SANDRA ONO - 27/05/2014     
*****************************************************************************
***************************************************************************** 
***  CONSISTENCIA DE ITENS DE PACK (Itens de Pedido x Itens de Pack)
***  Consiste grade de packs, qtdes e Itens de Pedido  
******************************************************************************

******************************************************************************
** PAULO DEVIDE 15-08-2013
**  <uda o valor do campo DATA OTB na inclusão no caso de haver 
**  alteração no campo entrega 
******************************************************************************

******************************************************************************
*** PAULO DEVIDE - 14-08-2013
*** INCLUSÃO CAMPO DATA OTB
* REGRA -  NA OPERAÇÃO DE INCLUSÃO, O VALOR DO 
* CAMPO DATA É IGUAL AO CAMPO DATA DE ENTREGA
******************************************************************************

******************************************************************************
** PAULO DEVIDE -> 21-05-2013 (botao pra imprimir pedido em inglês)
******************************************************************************
** PAULO DEVIDE -> 21-05-2013*** Inclui Campo Data OTB 
******************************************************************************
** PAULO DEVIDE - muda o valor do campo DATA OTB na inclusão no caso de haver 
******************************************************************************
** PAULO DEVIDE -> 22-05-2013 Pedido Excel
******************************************************************************
*******************************************************************************
****   Sandra Ono   -  20/04/2013
*********** Verfica a semana (compras)         
**********  Solicita senha para alterar limite de entrega 
*********** Senha de Diretor e seha de Gerente
********************************************************************************
*****************************************************************************************
****   ????   -  Anterior a   2013
*********** Solicita a senha para alterar Pedidos com alguma entrega mesmo que parcial
********************************************************************************


*- Definindo a classe do objeto de entrada que sera criado na Form.
Define Class obj_entrada As Custom
*- Nome do metodo/função que os objetos linx vão chamar.
	Procedure metodo_usuario
	Lparam xmetodo, xobjeto, xnome_obj


	Do Case
	
	CASE Upper(xmetodo) == 'USR_INCLUDE_AFTER'
		thisformset.lx_form1.lx_pageframe1.Page1.tx_data_otb1.value = DATE() && Valor default para data OTB
		
		IF ThisFormSet.p_Tool_Status="I" && Somente na inclusão
				
			Select v_Compras_01
			Replace FILIAL_A_ENTREGAR With RTRIM(o_004006.pp_filial_padrao),;
			        FILIAL_COBRANCA   With 'TATUAPE',;
			        FILIAL_A_FATURAR  With RTRIM(o_004006.pp_filial_padrao)

			thisformset.lx_form1.lx_pageframe1.Page1.cmb_FILIAL_A_ENTREGAR.VALUE =  RTRIM(o_004006.pp_filial_padrao)  
			thisformset.lx_form1.lx_pageframe1.Page1.cmb_FILIAL_A_FATURAR.VALUE =  RTRIM(o_004006.pp_filial_padrao)  
					
	     endif			
		
	** PAULO DEVIDE - muda o valor do campo DATA OTB na inclusão no caso de haver 
	** alteração no campo entrega - 15-08-2013
	CASE Upper(xmetodo) == 'USR_VALID' AND UPPER(xnome_obj)='TX_ENTREGA_UNICA'

		IF ThisFormSet.p_Tool_Status="I" && Somente na inclusão
			thisformset.lx_form1.lx_pageframe1.Page1.tx_data_otb1.value = xobjeto.value	
		ENDIF
		
				
	Case Upper(xmetodo) == 'USR_ALTER_BEFORE'
		Select v_compras_01_ent_prod
		=Requery()

		Do Case
*CASE v_compras_01.status_aprovacao ='A'	 AND status_compra = '01'
		Case Reccount('v_compras_01_ent_prod') >= 1

			eMessageTitle = 'Atenção'
			eMessageText = 'Esse pedido de compra já foi recebido total ou parcialmente' +Chr(13)+;
				'Alterações permitidas apenas com Senha Gerencial.' +Chr(13)+'Deseja entra com senha de alteração ?'
			nDialogType = 4 + 16 + 256
			nAnswer = Messagebox(eMessageText, nDialogType, eMessageTitle)

			Do Case
			Case nAnswer = 6

				Local inppass
*	Password (masked)
				inppass = rbInputBox( "Digite a Senha", "Senha para alteração de Pedido de Compra", "", , , "!", , "*")
				inppass = Alltrim(inppass )

				f_select("Select valor_atual from parametros where parametro = 'CAE_SENHA_COMPRAS' ","LISTAUT"	)

				Select LISTAUT
				CAEWHERE = LISTAUT.VALOR_ATUAL
				xaut = 0

				If Inlist(inppass  , &CAEWHERE  )
					xaut = xaut  +1
				Endif



				If xaut > 0
					Return .T.
				Else
					Messagebox("Senha incorreta ou não autorizada")
					Return .F.
				Endif

			Case nAnswer = 7
				Return .F.

			Endcase
		Endcase

	Case Upper(xmetodo) == 'USR_INIT'

		** PAULO DEVIDE -> 21-05-2013 (botao pra imprimir pedido em inglês)
		thisformset.lx_form1.addobject('bt_pedido1', 'bt_pedido')
		WITH thisformset.lx_form1.bt_pedido1
			.height = 27
			.fontname = 'Arial'
			.Caption = 'Pedido'
			.Left = 624
			.Top = 31
			.Width = 70
			.Visible = .T.
			.Enabled = .T.
			.anchor = 0
			.p_manter_baixo = .f.
			.p_manter_cima = .f.
			.p_manter_direita = .f.
			.p_manter_esquerda = .f.
			.p_muda_size = .f.
			
		ENDWITH
		** FIM: 20-05-2013
		
		*** Inclui Campo Data OTB 
		thisformset.lx_form1.lx_pageframe1.Page1.addobject('sh_OTB1', 'sh_OTB')
		WITH thisformset.lx_form1.lx_pageframe1.Page1.sh_OTB1
			.visible = .t.
*!*				.Top = 342
*!*				.Left = 4
*!*				.Height = 40
		ENDWITH
		
		thisformset.lx_form1.lx_pageframe1.Page1.addobject('lb_data_otb1', 'lb_data_otb')
		WITH thisformset.lx_form1.lx_pageframe1.Page1.lb_data_otb1
			.visible = .t.
*!*				.Top = 348
*!*				.Left = 18
		ENDWITH

		thisformset.lx_form1.lx_pageframe1.Page1.addobject('tx_data_otb1', 'tx_data_otb')
		WITH thisformset.lx_form1.lx_pageframe1.Page1.tx_data_otb1
			.visible = .t.
*!*				.Top = 346
*!*				.Left = 84
			.ControlSource = 'V_COMPRAS_01.CAEDU_DATA_OTB'
		ENDWITH
		*************************************************************
		
		If wacesso_esp_2 And Type("oCurrentFormSet.lx_form1.lx_pageframe1.page10") == "O" And ;
				Type("oCurrentFormSet.lx_form1.lx_pageframe1.page10.lx_compr_rolos_m_vol1") == "U"
			AddNewObject(oCurrentFormSet.lx_form1.lx_pageframe1.page10, "lx_compr_rolos_m_vol1", "lx_compr_rolos_m_vol")
			oCurrentFormSet.lx_form1.lx_pageframe1.page10.lx_compr_rolos_m_vol1.Top = 112
			oCurrentFormSet.lx_form1.lx_pageframe1.page10.lx_compr_rolos_m_vol1.Left = 556
			oCurrentFormSet.lx_form1.lx_pageframe1.page10.lx_compr_rolos_m_vol1.Visible = .T.
		Endif

		Create Cursor xUserSenha(usuario Varchar(25), motivo Varchar(25))
		
** PAULO DEVIDE - 31-JUL-14 (INICIO)
*
		thisformset.lx_form1.lx_pageframe1.Page5.addobject('bt_obs_pack1', 'bt_obs_pack')
		WITH thisformset.lx_form1.lx_pageframe1.Page5.bt_obs_pack1
			.visible = .t.
*!*				.top=23
*!*				.left=8
		ENDWITH


*
** PAULO DEVIDE - 31-JUL-14 (FIM)		

	Case Upper(xmetodo) == 'USR_SAVE_BEFORE'

		** PAULO DEVIDE -> 23-05-2013
		IF INLIST(ThisFormSet.p_Tool_Status,'I','A')
			LOCAL llRet as Boolean
			PRIVATE pdEntrega, pdLimite
			pdEntrega = ThisFormSet.lx_form1.Lx_pageframe1.Page1.tx_ENTREGA_UNICA.value
			pdLimite = ThisFormSet.lx_form1.Lx_pageframe1.Page1.tx_LIMITE_ENTREGA_UNICA.value
			
			*llRet = zvalida_campos_pedido_pack()
			
			IF NOT llRet
				RETURN .f.
			ENDIF
		ENDIF
		** Fim: 23-05-2013

    
		If Inlist(Thisformset.p_Tool_Status, "A")


			Select xUserSenha
			Zap
			Append Blank

			Select v_Compras_01_Produtos
			Go Top

************************************************
****   Sandra Ono 
*********** Verfica a semana (compras)  *********
			lc_pedido = Alltrim(v_Compras_01_Produtos.pedido)
			ld_limite_entrega = Dtoc(v_Compras_01_Produtos.limite_entrega,1)


			TEXT TO lcsql noshow
						     		    select pedido, LIMITE_ENTREGA, DATEPART( wk , LIMITE_ENTREGA ) as semana,
						     		       ENTREGA,  DATEPART( wk , getdate() ) as semana_atual
										from
										COMPRAS_PRODUTO
										where pedido like ?lc_pedido
			ENDTEXT


			If Used("x_entreg_atu")
				Use In x_entreg_atu
			Endif


			f_select(lcsql,'x_entreg_atu')
			


             IF RECCOUNT("x_entreg_atu")  = 0 or;
                f_vazio(x_entreg_atu.entrega)
                
                RETURN .T.
             
             ENDIF
			



			If Thisformset.px_entrega.Value <> Ttod(x_entreg_atu.entrega)


				***thisformset.formmotivo.Show(1)
				rbmotivo( "Motivo da alteração", "Motivo", "", , , "!", , "*")


			Endif



			If Ttod(x_entreg_atu.limite_entrega) != v_Compras_01_Produtos.limite_entrega

				LC_DATA_INI = Dtoc(Ttod(x_entreg_atu.limite_entrega),1)
				LC_DATA_FIM = Dtoc(Datetime(),1)
				
				SET STEP ON 
				
				XWK_ENTEGA =  WEEK(Ttod(x_entreg_atu.limite_entrega))
				XWK_ATUAL = WEEK(DATE( ))
				
				WKDIFF = XWK_ENTEGA - XWK_ATUAL 
				
				

				ld_limite_entrega = Dtoc(v_Compras_01_Produtos.limite_entrega,1)


				If Used("x_entreg_new")
					Use In x_entreg_new
				Endif


				TEXT TO lcsql noshow
							 select  DATEDIFF ( wk , ?LC_DATA_FIM,  ?LC_DATA_INI )  as wk_dif
				ENDTEXT

				f_select(lcsql,'x_entreg_new')



				Do Case
				*Case x_entreg_new.wk_dif <= 0
				Case WKDIFF  <= 0

					Local inppass

					inppass = rbInputBox2( " Senha", "SENHA de [DIRETOR]", "", , , "!", , "*")
					inppass = Alltrim(inppass)
					ll_senha_OK  = .F.



					TEXT TO lcsql noshow
					 				  SELECT par.usuario FROM  PARAMETROS_USERS par
						   	     	  WHERE parametro like 'PALMA_DIRETOR_CPA_ENT'
			   		   		     	  and usuario like ?xUserSenha.usuario
					ENDTEXT

					If Used("x_Diretor")
						Use In x_Diretor
					Endif

					f_select(lcsql,"x_Diretor")


					If Reccount("x_Diretor") = 0
						Messagebox("Usuario sem permissão de [diretor] p/ liberar alteração!",16,"Avisos")
						Return .F.
					Endif

					Select x_Diretor
					Scan

						lc_usuario = Alltrim(x_Diretor.usuario)
						f_select("select passw from users where usuario like ?lc_usuario ", 'X_CURSENHALINX')

						If UPPER(inppass) = UPPER(F_DS_CR(Alltrim(X_CURSENHALINX.Passw)))
							ll_senha_OK = .T.
						ENDIF
						SELECT x_Diretor

					Endscan

					If !ll_senha_OK
						Messagebox("Senha não confere com Diretores cadastrados!!!",16,"Atenção")
						Return .F.
					Endif

					lcsql = ""
					TEXT TO lcsql noshow
										INSERT INTO trigger_portal
										(id,
										login,
										pedido,
										entrega_antiga,
										entrega_nova,
										limite_entrega_antiga,
										limite_entrega_nova,
										data_alteracao ,
										user_senha,
										cargo_senha)
										VALUES
										((select MAX(id)+1 from trigger_portal),
										  ?wusuario,
			  							  ?x_entreg_atu.pedido,
										  ?x_entreg_atu.entrega,
										  ?v_compras_01_produtos.entrega,
										  ?x_entreg_atu.limite_entrega,
										  ?v_compras_01_produtos.limite_entrega,
										  getdate(),
										  ?lc_usuario,
										  'DIRETOR')
					ENDTEXT
					F_INSERT(lcsql)


Lparameters tcPrompt, tcTitle, txDefaultValue, tnLeft, tnTop, ;
	tcFormat, tcInputMask, tcPasswordChar


				*Case x_entreg_new.wk_dif  =  1  99999
				Case INLIST(WKDIFF  ,1,2)

					Local inppass
					inppass = rbInputBox2( "Digite a Senha", "SENHA de [GERENTE]", "", , , "!", , "*")
					inppass = Alltrim(inppass)
					ll_senha_OK  = .F.

					If Used("x_Gerente")
						Use In x_Gerente
					Endif

					TEXT TO lcsql noshow
			   	     			  SELECT USUARIO FROM  PARAMETROS_USERS
			   	     			  WHERE parametro like 'PALMA_GERENTE_CPA_ENT'
			   	     			  and usuario like ?xUserSenha.usuario
					ENDTEXT

					f_select(lcsql,"x_Gerente")

					If Reccount("x_Gerente") = 0
						Messagebox("Usuario sem permissão de [gerente] p/ liberar alteração!",16,"Avisos")
						Return .F.
					Endif


					Select x_Gerente
					Scan

						lc_usuario = Alltrim(x_Gerente.usuario)
						f_select("select passw from users where usuario like ?lc_usuario ", 'X_CURSENHALINX')

						If UPPER(inppass) = Upper(F_DS_CR(Alltrim(X_CURSENHALINX.Passw)))
							ll_senha_OK = .T.
						Endif

						Select x_Gerente
					Endscan

					If !ll_senha_OK
						Messagebox("Senha não confere com [GERENTES] cadastrados!!!",16,"Atenção")
						Return .F.
					Endif

					lcsql = ""
					TEXT TO lcsql noshow
									INSERT INTO trigger_portal
										(id,
										login,
										pedido,
										entrega_antiga,
										entrega_nova,
										limite_entrega_antiga,
										limite_entrega_nova,
										data_alteracao ,
										user_senha,
										cargo_senha)
										VALUES
										((select MAX(id)+1 from trigger_portal),
										 ?wusuario,
			  							 ?x_entreg_atu.pedido,
										  ?x_entreg_atu.entrega,
										  ?v_compras_01_produtos.entrega,
										  ?x_entreg_atu.limite_entrega,
										  ?v_compras_01_produtos.limite_entrega,
										  getdate(),
										  ?lc_usuario,
										  'GERENTE')
					ENDTEXT
					F_INSERT(lcsql)




				Endcase


			Endif

		Endif


	Endcase
	Endproc

Enddefine


DEFINE CLASS sh_OTB AS lx_shape 
	Top = 332
	Left = 4
	Height = 40
	Width = 342
	Name = "sh_OTB1"
ENDDEFINE


DEFINE CLASS lb_data_otb AS lx_label 
	FontBold = .T.
	Alignment = 0
	Caption = "Data OTB:"
	Left = 18
	Top = 348
	Name = "lb_data_otb1"
ENDDEFINE


DEFINE CLASS tx_data_otb AS lx_textbox_base 
	Height = 21
	Left = 108
	Top = 346
	Width = 84
	Name = "tx_data_otb1"
ENDDEFINE
	
** (Inicio) PAULO DEVIDE - 31-JUL-14
DEFINE CLASS bt_obs_pack as botao
	caption = 'Preenche OBS'
	*autosize = .T.
	WORDWRAP = .t.
	WIDTH = 162
	top = 3
	left = 85
	HEIGHT =  18
	enabled = .t.
	visible  = .t.
	backcolor =  RGB(64,128,128)

	PROCEDURE click
		LOCAL lcObs, lnArea
		lnArea = SELECT()
		IF !INLIST(ThisFormSet.p_Tool_Status,"I","A")	
			MESSAGEBOX("Para editar observação entre em modo de Inclusão ou Alteração do Pedido",64,"Aviso")
			SELECT (lnArea)
			RETURN 
		ENDIF
			
		lcObs = ALLTRIM(V_COMPRAS_01.OBS)+CHR(13)+CHR(13)+;
		'PACK:'+CHR(13)+;
		REPLICATE('-',120)+CHR(13)
		SELECT v_caedu_compras_produtos_packs
		SCAN 		
			TEXT TO lcSQL NOSHOW TEXTMERGE
				exec pr_grade_produto_cor ?v_caedu_compras_produtos_packs.pedido,
					?v_caedu_compras_produtos_packs.produto,?v_caedu_compras_produtos_packs.cor_produto
			ENDTEXT
			f_execute(lcSQL,"tmpPack")
			lcObs = lcObs + tmpPack.descricao_grade+CHR(13)
		ENDSCAN
		
		SELECT V_COMPRAS_01
		IF NOT EMPTY(lcObs)
			replace V_COMPRAS_01.OBS WITH lcObs
		ENDIF
		thisformset.lx_form1.lx_pageframe1.Page5.ed_obs.refresh
		
		SELECT (lnArea)
		

	ENDPROC
	
*!*		PROCEDURE refresh
*!*			** Inclusão/Alteração/Exclusão/Tela (L)impa/(P)esquisa Feita!
*!*			this.enabled = !INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L") 
*!*		ENDPROC
	
ENDDEFINE
** (fim) PAULO DEVIDE - 31-JUL-14

** PAULO DEVIDE -> 22-05-2013
DEFINE CLASS bt_pedido as botao
	caption = 'Pedido Excel'
	*autosize = .T.
	WORDWRAP = .t.
	WIDTH = 192
	top = 3
	left = 502
	HEIGHT =  27
	enabled = .f.
	visible  = .t.
	backcolor =  RGB(64,128,128)

	PROCEDURE click
		LOCAL llRet
		llRet = MESSAGEBOX("Deseja Formatar Pedido no Excel em Inglês?",292,"Aviso")=6
		
		IF llRet
			f_wait("Exportando dados para o Excel...")
			LOCAL lcArquivo as String
			lcArquivo = SYS(2023)+"\pedido_compras_"+STUFF(STUFF(DTOS(DATE()),5,0,'-'),8,0,'-')+SYS(2015)+".xlsx"
			
			zPedido_Excel(lcArquivo)
			
			f_wait()	
		ENDIF
		

	ENDPROC
	
	PROCEDURE refresh
		** Inclusão/Alteração/Exclusão/Tela (L)impa/(P)esquisa Feita!
		this.enabled = !INLIST(ThisFormSet.p_Tool_Status,"I","A","E","L") 
	ENDPROC
	
ENDDEFINE
** FIM: 22-05-2013

** PAULO DEVIDE -> 23-05-2013
FUNCTION zvalida_campos_pedido_pack
SET STEP ON 


	LOCAL llOk as Boolean, lcMsg as String
	LOCAL lnTotReg1 as Integer, lnTotReg2 as Integer
	  
	llOk = .t.
	lcMsg = ""
	
	
	
	
	
	

	lnTotReg1 = RECCOUNT("v_caedu_compras_produtos_packs")
    lnTotReg2 = RECCOUNT("v_caedu_compras_produtos_packs_total")	

	** 1) Tipo de compra
	IF EMPTY(NVL(v_compras_01.tipo_compra,''))
		llOk=.f.
		lcMsg = lcMsg + "Campo [Tipo de Compra] é obrigatório..."
	ENDIF

	** 2) Requerido por:
	IF EMPTY(NVL(v_compras_01.requerido_por,''))
		llOk=.f.
		lcMsg = lcMsg + CHR(13)+ "Campo [Requerido por] é obrigatório..."
	ENDIF

	** 3) Aprovado/Reprovado:
	IF EMPTY(NVL(v_compras_01.aprovador_por,''))
		llOk=.f.
		lcMsg = lcMsg + CHR(13)+ "Campo [Aprovado/Reprovado] é obrigatório..."
	ENDIF		
	
	** 4) Natureza Entrada:
	IF EMPTY(NVL(v_compras_01.natureza_entrada,''))
		llOk=.f.
		lcMsg = lcMsg + CHR(13)+ "Campo [Natureza entrada] é obrigatório..."
	ENDIF		

	** 5) Data de Entrega:
	IF EMPTY(NVL(pdEntrega,CTOD('')))
		llOk=.f.
		lcMsg = lcMsg + CHR(13)+ "Campo [Data de Entrega] é obrigatório..."
	ENDIF		

	** 6) Data de Limite de Entrega:
	IF EMPTY(NVL(pdLimite,CTOD('')))
		llOk=.f.
		lcMsg = lcMsg + CHR(13)+ "Campo [Limite de Entrega] é obrigatório..."
	ENDIF		

	** 7) Observação:
	IF EMPTY(NVL(v_compras_01.OBS,''))
		llOk=.f.
		lcMsg = lcMsg + CHR(13)+ "Campo [Observação] é obrigatório..."
	ENDIF		

	** 8) Validar se existe itens cadastrados e com quantidade/valor:
	IF EMPTY(NVL(v_compras_01.tot_valor_original,0))
		llOk=.f.
		lcMsg = lcMsg + CHR(13)+ "É obrigatório informar os itens do pedido..."
	ENDIF	
	
	** 9) Validar se os grid´s da aba PACK contem registro
	IF lnTotReg1=0 
		llOk=.f.
		lcMsg = lcMsg + CHR(13)+ "É obrigatório informar os itens na aba PACKs..."
	ENDIF

	IF lnTotReg2=0
		llOk=.f.
		lcMsg = lcMsg + CHR(13)+ "É obrigatório ter registro totalizador na aba PACKs..."
	ENDIF


	*********************************************
	***          SANDRA ONO - 27/05/2014     ****
	*********************************************
	****************** INICIO********************
	********************************************* 
	*** Formula	 DA CONSISTENCIA DE ITENS DE PACK
	********************************************* 	
		*!*	D 	Item do Pedido
		*!*	A	Qtde total do Pedido
		*!*	B	Qtde total do item do Pack
		*!*	C	Item do Pack
		*!*	D = (A/B)*C	
	********************************************* 	
	
	*checagem de cor
	*SET STEP ON 
	
	SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS
	GO top
	scan
	
			  SELECT v_compras_01_produtos
			  GO top
			  LOCATE FOR ALLTRIM(v_compras_01_produtos.produto)+ALLTRIM(v_compras_01_produtos.cor_produto) = ;
	    				ALLTRIM(V_CAEDU_COMPRAS_PRODUTOS_PACKS.produto) + ALLTRIM(V_CAEDU_COMPRAS_PRODUTOS_PACKS.cor_produto)
			  
			  IF !FOUND()
					  llOk=.f.
					MESSAGEBOX("Erro na cor:"+V_CAEDU_COMPRAS_PRODUTOS_PACKS.cor_produto + " Verifique",16,"Aviso")  	
						
			  ENDIF
	
		SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS
	endscan	

			
			
			
	SELECT v_compras_01_produtos
	GO top
	scan
	
			  SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS
			  GO top
			  LOCATE FOR ALLTRIM(V_CAEDU_COMPRAS_PRODUTOS_PACKS.produto) + ALLTRIM(V_CAEDU_COMPRAS_PRODUTOS_PACKS.cor_produto) = ;
			  		ALLTRIM(v_compras_01_produtos.produto)+ALLTRIM(v_compras_01_produtos.cor_produto)
			  
			  IF !FOUND()
					  llOk=.f.
					MESSAGEBOX("Erro na cor:"+v_compras_01_produtos.cor_produto + " Verifique",16,"Aviso")  	
						
			  ENDIF
	
		SELECT v_compras_01_produtos
	endscan				





*!*		A = v_compras_01_produtos.QTDE_ORIGINAL
*!*		D = "v_compras_01_produtos.CO"+ALLTRIM(PADR(ind,2," "))
	
	

	XPACKTOT = v_compras_01.tot_qtde_original  / V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.qtde


	SELECT v_compras_01_produtos
	GO top
	scan
	 *SET STEP on 	  
	  
		FOR IND = 1 TO 48
			
			Itab = "v_compras_01_produtos.CO"+ALLTRIM(PADR(ind,2," "))
			ptab = "V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q"+ALLTRIM(PADR(ind,2," "))
			
			XVALORCOL = &Itab. / XPACKTOT 
			
			SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS
			GO top
			LOCATE FOR ALLTRIM(V_CAEDU_COMPRAS_PRODUTOS_PACKS.produto) + ALLTRIM(V_CAEDU_COMPRAS_PRODUTOS_PACKS.cor_produto) = ;
			ALLTRIM(v_compras_01_produtos.produto)+ALLTRIM(v_compras_01_produtos.cor_produto)
			  
			IF !FOUND()
				llOk=.f.
				MESSAGEBOX("Erro na cor:"+v_compras_01_produtos.cor_produto + " Verifique",16,"Aviso")  	
			ELSE
				IF &ptab. <> XVALORCOL 
					llOk=.f.
					MESSAGEBOX("Erro na cor:"+v_compras_01_produtos.cor_produto + " Verifique",16,"Aviso")  	
				endif
			endif
		
		ENDFOR

	
		SELECT v_compras_01_produtos
	ENDSCAN
	
	
	
			
		

			

			
	  
	  Ln_erro_pack = .F. 
	  
	 	  
	  SELECT v_compras_01_produtos
	  GO top
	  scan
	  
		  FOR IND = 1 TO 48
		  
		  
		  
		  A = v_compras_01_produtos.QTDE_ORIGINAL
		  D = "v_compras_01_produtos.CO"+ALLTRIM(PADR(ind,2," "))
		  
		  
		  
		  
		  
		  SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL
		  LOCATE FOR V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.produto = v_compras_01_produtos.produto 
		   *AND V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.cor_produto = v_compras_01_produtos.cor_produto
		  
		  IF !FOUND()
		  
		  
	  		   lcMsg = "A cor ["+ALLTRIM(V_COMPRAS_01_PRODUTOS.DESC_COR_PRODUTO)+ "] não está cadastrada no Total geral de packs (LISTA ABAIXO)"
		       Ln_erro_pack = .T. 
		       LN_ITEM = IND 
		       EXIT

		  ELSE
		  
		     IF  !Ln_erro_pack 
		  
	  			  K = "V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q"+ALLTRIM(PADR(ind,2," "))
	  			  J = "V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Q"+ALLTRIM(PADR(ind,2," "))
			  
			       SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS
			       SUM &K. TO LNTotal1
			       

			       SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL
			       SUM &J. TO LNTotal2		       


				   if LNTotal1 != LNTotal2
				   
			  		   lcMsg = "O TAMANHO POSICAO ["+ALLTRIM(PADL(IND,2,"0"))+ "] está com problemas na soma do Total geral de packs (LISTA ABAIXO)"
				       Ln_erro_pack = .T. 
				       LN_ITEM = IND 
				       EXIT
				   
				   ENDIF		       
				   
			   Endif	   
		  
		       IF  !Ln_erro_pack 
		       
				   if V_CAEDU_COMPRAS_PRODUTOS_PACKS.Qtde != V_CAEDU_COMPRAS_PRODUTOS_PACKS_TOTAL.Qtde
				   
			  		   lcMsg = "A cor ["+ALLTRIM(V_COMPRAS_01_PRODUTOS.DESC_COR_PRODUTO)+ "] está com problemas na soma do Total geral de packs (LISTA ABAIXO)"
				       Ln_erro_pack = .T. 
				       LN_ITEM = IND 
				       EXIT
				   
				   ENDIF
			Endif	   
		   
		  
		  ENDIF
		  
		  
		  
	       IF  !Ln_erro_pack 
		  
			  SELECT V_CAEDU_COMPRAS_PRODUTOS_PACKS
			  LOCATE FOR V_CAEDU_COMPRAS_PRODUTOS_PACKS.produto = v_compras_01_produtos.produto  and;
	          		  V_CAEDU_COMPRAS_PRODUTOS_PACKS.cor_produto = v_compras_01_produtos.cor_produto  
			  
			  IF FOUND()
			  
				  B = V_CAEDU_COMPRAS_PRODUTOS_PACKS.Qtde
				  C = "V_CAEDU_COMPRAS_PRODUTOS_PACKS.Q"+ALLTRIM(PADR(ind,2," "))
			  
				    Total_D = (A/B)*&C.	

				    IF Total_D != &D.
				    
				       Ln_erro_pack = .T. 
				       LN_ITEM = IND 
		       			lcMsg = "Quantidades dos tamanhos dos itens do Pedido da cor ["+ALLTRIM(V_COMPRAS_01_PRODUTOS.DESC_COR_PRODUTO)+ "] não estão compativeis com a quantidade dos itens dos packs."
				       EXIT
				       
				    ENDIF
				    
				ELSE

			       Ln_erro_pack = .T. 
			       LN_ITEM = IND 
		   			lcMsg ="Quantidades dos tamanhos dos itens do Pedido da cor ["+ALLTRIM(V_COMPRAS_01_PRODUTOS.DESC_COR_PRODUTO)+ "] não estão compativeis com a quantidade dos itens dos packs."
			       EXIT
				    
				Endif    
				
			Endif
				
		  
		  ENDFOR
		  
		  
		  IF Ln_erro_pack
		  
	  		llOk=.f.
	  		
			***lcMsg =  "Quantidades dos tamanhos dos itens do Pedido da cor ["+ALLTRIM(V_COMPRAS_01_PRODUTOS.DESC_COR_PRODUTO)+ "] não estão compativeis com a quantidade dos itens dos packs."
			****MESSAGEBOX(lcMsg,16,"Aviso")
		    exit 
		    
	      ENDIF 	  
	      
	  Endscan    
	  
	*********************************************
	***          SANDRA ONO - 27/05/2014     ****
	*********************************************
	***************   FIM       *****************
	********************************************* 	
	
	 	

	IF NOT EMPTY(lcMsg)
		MESSAGEBOX(lcMsg,16,"Aviso")
	ENDIF
	
	RETURN llOk
ENDFUNC
** Fim: 23-05-2013

** PAULO DEVIDE -> 22-05-2013
FUNCTION zPedido_Excel
PARAMETERS tcArquivo
	
	** Define o nome do arquivo XLSX a ser criado
	lcSQL = "select codigo_modelo,descricao_modelo,imagem_modelo "+;
				"from CAE_MODELOS_EXCEL where codigo_modelo='0001'"

	** Pega o modelo (template em branco) para gerar o Excel do relatório
	f_select(lcSQL,"vCAE_Modelos") 

	** Converte a imagem para arquivo binário
	lcTmpArqxls = CAST(vCAE_Modelos.imagem_modelo as blob)
	STRTOFILE(lcTmpArqxls,tcArquivo) && grava modelo na pasta temporária do usuário

	** Querys de dados do relatório
	SELECT v_compras_01_produtos
	GO top

	TEXT TO lcSQL NOSHOW TEXTMERGE
		SELECT * FROM produtos
		where produto = ?v_compras_01_produtos.produto
	ENDTEXT
	f_select(lcSQL,"cur_produtos")
	
	TEXT TO lcSQL NOSHOW TEXTMERGE
		select RAZAO_SOCIAL AS buyer
		,RTRIM(LTRIM(ENDERECO))+' - '+RTRIM(LTRIM(COMPLEMENTO))+
		' - '+RTRIM(LTRIM(BAIRRO))+' - '+RTRIM(LTRIM(CIDADE))+' - '+RTRIM(LTRIM(UF)) AS adress
		,CEP AS zip_code ,CGC_CPF as CNPJ
		from CADASTRO_CLI_FOR where CLIFOR = '000040'
	ENDTEXT
	f_select(lcSQL,"cur_filial40")
	
	TEXT TO lcSQL NOSHOW TEXTMERGE
		select COLECAO,DESC_COLECAO 
		from COLECOES where COLECAO=?v_compras_01_produtos.colecao
	ENDTEXT
	f_select(lcSQL,"cur_colecao")
	
	TEXT TO lcSQL NOSHOW TEXTMERGE
		select MATERIAIS_COMPOSICAO.COMPOSICAO,  MATERIAIS_COMPOSICAO.DESC_COMPOSICAO
		From PRODUTOS 
		LEFT JOIN MATERIAIS_COMPOSICAO ON MATERIAIS_COMPOSICAO.COMPOSICAO = PRODUTOS.COMPOSICAO
		WHERE PRODUTOS.PRODUTO=?v_compras_01_produtos.produto		
	ENDTEXT
	f_select(lcSQL,"cur_composicao")
	
	TEXT TO lcSQL NOSHOW TEXTMERGE
		SELECT * FROM prop_compras WHERE pedido=?v_compras_01.pedido
	ENDTEXT
	f_select(lcSQL,"cur_prop_compras")	
	**
	
	f_select("select * from produtos_precos where produto = ?v_compras_01_produtos.produto and codigo_tab_preco='40'","cur_preco_venda")	
	
	LOCAL oExcel as Object
	oExcel = CREATEOBJECT("Excel.Application")
	
	
	
	WITH oExcel
		.workbooks.open(tcArquivo)
		.visible = .T.
		
		m.request_no = v_compras_01.pedido
		m.article_no = v_compras_01_produtos.produto
		
		m.buyer = ALLTRIM(NVL(cur_filial40.buyer,''))
		m.adress = ALLTRIM(NVL(cur_filial40.adress,''))
		m.zip_code = TRANSFORM(ALLTRIM(NVL(cur_filial40.zip_code,'')),"@R 99999-999")
		m.cnpj = TRANSFORM(ALLTRIM(NVL(cur_filial40.cnpj,'')),"@R 99.999.999/9999-99")
		
		m.collection1 = ALLTRIM(NVL(cur_colecao.desc_colecao,''))
		m.depto = v_compras_01_produtos.griffe
		m.line1 = v_compras_01_produtos.linha
		m.composition = ALLTRIM(NVL(cur_composicao.desc_composicao,''))
		m.type1 = ALLTRIM(NVL(cur_produtos.tipo_produto,''))


		m.supp_ref = NVL(LOOKUP(cur_prop_compras.valor_propriedade,'00068',cur_prop_compras.propriedade),'') &&ALLTRIM(NVL(cur_produtos.REFER_FABRICANTE,''))



		
		m.sizes = ALLTRIM(NVL(cur_produtos.grade,''))
		m.supp_ref = ALLTRIM(NVL(cur_produtos.REFER_FABRICANTE,''))
	
		m.cust_fob = STRTRAN(ALLTRIM(NVL(LOOKUP(cur_prop_compras.valor_propriedade,'00030',cur_prop_compras.propriedade),'')),",",".")
		m.cust_fob = CAST(m.cust_fob as numeric(14,2))
		
		m.amount = '=H17*M17'
		m.sales_price = cur_preco_venda.preco1 &&V_COMPRAS_01_PRODUTOS.custo1
		
		m.profoma_invoice = NVL(LOOKUP(cur_prop_compras.valor_propriedade,'00028',cur_prop_compras.propriedade),'')

		m.shipment_date = NVL(LOOKUP(cur_prop_compras.valor_propriedade,'00029',cur_prop_compras.propriedade),'')
		IF NOT EMPTY(m.shipment_date)
			** Data convertida para formato numérico do Excel
			m.shipment_date = (Val(Sys(11, NVL(m.shipment_date,CTOD("")))) - Val(Sys(11, {30/12/1899})))		
		ENDIF
			
		m.packs_of = NVL(LOOKUP(cur_prop_compras.valor_propriedade,'00031',cur_prop_compras.propriedade),0)
		m.quantity_of_packs = NVL(LOOKUP(cur_prop_compras.valor_propriedade,'00032',cur_prop_compras.propriedade),0)
		
		** Cursor detalhe (itens do pedido)
		IF USED("cur_itens_pedido")
			SELECT cur_itens_pedido
			USE
		ENDIF

		CREATE CURSOR cur_itens_pedido ( ;
			PRODUTO C(12) NULL,;
			INDICE INT NULL,;
			CODIGO_BARRA C(25) NULL,;
			DESCRICAO C(40) NULL,;
			COR C(40) NULL,;
			TAMANHO C(8) NULL,;
			QTD INT NULL )
		
		SELECT v_compras_01_produtos
		GO top	
		
		LOCAL lnCont as Integer
		SCAN 		

			FOR lnCont=1 TO 48
				lcCampo = "v_compras_01_produtos.co"+ALLTRIM(TRANSFORM(lnCont,"99"))
				lnCampo_value = NVL(EVALUATE(lcCampo),0)
				IF NOT EMPTY(lnCampo_value)
				
					TEXT TO lcSQL NOSHOW TEXTMERGE
						select PRODUTOS_BARRA.*
						from PRODUTOS
						LEFT JOIN PRODUTOS_BARRA ON PRODUTOS_BARRA.PRODUTO = PRODUTOS.PRODUTO
						WHERE PRODUTOS.PRODUTO = '<<v_compras_01_produtos.produto>>' 
							AND COR_PRODUTO = '<<v_compras_01_produtos.cor_produto>>' 
							and TAMANHO = <<lnCont>>
					ENDTEXT
					f_select(lcSQL,"cur_produto_barra")
					
					SELECT cur_itens_pedido 
					APPEND BLANK
					REPLACE PRODUTO WITH v_compras_01_produtos.produto
					REPLACE INDICE WITH lnCont
					REPLACE CODIGO_BARRA WITH ALLTRIM(cur_produto_barra.CODIGO_BARRA)
					REPLACE DESCRICAO WITH ALLTRIM(v_compras_01_produtos.DESC_PRODUTO)
					REPLACE COR WITH v_compras_01_produtos.DESC_COR_PRODUTO
					REPLACE TAMANHO WITH cur_produto_barra.GRADE
					REPLACE QTD WITH lnCampo_value
										
				ENDIF
				
			ENDFOR
				
		ENDSCAN

		SELECT cur_itens_pedido 
		INDEX on PRODUTO+COR+STR(INDICE,2,0) TAG IND01
		SET ORDER TO TAG IND01
		GO TOP
		
		.range("N2").value = m.request_no
		.range("N4").value = m.article_no
		
		.range("C8").value = m.buyer
		.range("C9").value = m.adress
		.range("C11").value = m.zip_code
		.range("C12").value = m.cnpj
		
		.range("C15").value = m.collection1
		.range("C16").value = m.depto
		.range("C17").value = m.line1
		.range("C18").value = m.composition		
		.range("C19").value = m.type1
		
		.range("H15").value = m.sizes
		.range("H16").value = m.supp_ref
		.range("H17").value = m.cust_fob
		.range("H18").value = m.amount		
		.range("H19").value = m.sales_price
				
		.range("M15").value = m.profoma_invoice
		.range("M16").value = m.shipment_date
		.range("M17").value = m.packs_of
		.range("M18").value = m.quantity_of_packs		

		*** Formatação dos Itens do Pedido		
		IF RECCOUNT("cur_itens_pedido")>0
		
			lnLinha = 24
			FOR lnRec = 1 TO RECCOUNT("cur_itens_pedido")
				.Rows("24:24").Select
			    .Selection.Copy
			    lcLinha = ALLTRIM(TRANSFORM(lnLinha+lnRec,"9999"))
			    .Rows(lcLinha+":"+lcLinha).Select
			    .Selection.Insert(-4121)
			ENDFOR
			
			SELECT cur_itens_pedido
			SCAN 			
			
				lcLinha = ALLTRIM(TRANSFORM(lnLinha,"9999"))
				.range("B"+lcLinha).value = "'"+ALLTRIM(NVL(cur_itens_pedido.CODIGO_BARRA,'')) 
				.range("D"+lcLinha).value = ALLTRIM(NVL(cur_itens_pedido.DESCRICAO,'')) 
				.range("I"+lcLinha).value = ALLTRIM(NVL(cur_itens_pedido.COR,'')) 
				.range("L"+lcLinha).value = ALLTRIM(NVL(cur_itens_pedido.TAMANHO,'')) 
				.range("N"+lcLinha).value = cur_itens_pedido.QTD 
				
				lnLinha = lnLinha + 1
			ENDSCAN
			
			lcLinhaFormula = ALLTRIM(CAST(24+RECCOUNT("cur_itens_pedido")+3 as char(4)))	
		    .Range("N"+lcLinhaFormula).Select
		    .ActiveCell.FormulaR1C1 = "=SUM(R[-"+ALLTRIM(TRANSFORM(RECCOUNT("cur_itens_pedido")+3,"9999"))+"]C:R[-4]C)"			    
		    
		    lnQtdTotal = CAST(.Range("N"+lcLinhaFormula).Value as Int)
			.range("H18").value = m.cust_fob * lnQtdTotal
			
		    lcLinhaFormula = ALLTRIM(CAST(24+RECCOUNT("cur_itens_pedido")+6 as char(4)))	
		    .Range("B"+lcLinhaFormula).value = ALLTRIM(v_compras_01.obs)		    
		ENDIF
		
		.range("A1").select
	    .ActiveWorkbook.Save		
	    
	ENDWITH
	RELEASE oExcel
	
	SELECT v_compras_01_produtos
	GO top						

ENDFUNC
** Fim: 22-05-2013


*--------------------------------------------------------
* Function Name.: rbInputBox()
*
* Author........: Rick Borup
*                 Information Technology Associates
*                 Champaign, IL U.S.A.
*                 http://www.ita-software.com
*                 rborup@ita-software.com
*
* Date Written..: March 20, 2000
*
* Date Released.: April 27, 2000
*
* Date Revised..: January 30, 2003
*
* Abstract......: A simple, general-purpose input box for Visual FoxPro.
*
* Parameters....: (All parameters are optional.)
*
*    tcPrompt - the prompt that the user sees.
*               The default is "Enter the value".
*
*    tcTitle - the title for the form.
*              The default is "InputBox".
*
*    txDefaultValue - default value.
*              This parameter can be a character, date, numeric, or
*              currency data type. If this parameter is omitted, an
*              empty textbox is displayed and the data type is character.
*              The data type of the return value is the same as the
*              data type of the default value.
*
*    tnLeft - the form's Left position
*
*    tnTop - the form's Top position.
*
*            If Left and Top are omitted or are not numeric, rbInputBox()
*            is auto-centered.
*
*    tcFormat - a value for the Format property of the textbox
*
*    tcInputMask - a value for the InputMask property of the textbox
*
*    tcPasswordChar - a value for the textbox's PasswordChar value
*                     (the default is blank)
*
* Returns.......: Character, Date, Numeric, or Currency depending
*                 on the data type of the default value
*
*                 If the Cancel button is chosen, rbInputBox() returns
*                 an empty value of the appropriate data type.
*
* Copyright.....: Copyright (c) Information Technology Associates, 2000-2003
*
* License.......: rbInputBox() is freeware. You may include rbInputBox()
*                 royalty-free inside a compiled Visual FoxPro APP or EXE
*                 that you create for your own use or for distribution to
*                 a third party.
*
*                 You may redistribute the rbInputBox() distribution
*                 package, INPUTBOX.ZIP, as long as (a) you distribute
*                 INPUTBOX.ZIP in its entirety and without modifications,
*                 and (b) you do not charge anything for it.
*
* Warranty......: NONE. This code is released AS IS without warranty
*                 of any kind. The user assumes all responsibility and
*                 liability for its use.
*
* Support.......: NONE, but your comments and suggestions for improvements
*                 are welcome. Please e-mail rborup@ita-software.com or
*                 reach me via the Universal Thread at
*                 http://www.universalthread.com.
*
* Release History:January 30, 2003 - Renamed as "rbInputBox" to avoid conflict
*                                    with the native InputBox() function in
*                                    VFP 7.0 and later.
*                                  - Added tcPasswordChar as 8th parameter
*
*                 May 2, 2000 - Corrected errata in the readme.txt file.
*
*                 April 27, 2000 - Original Release
*
* Known Limitations:
*                 The original release of rbInputBox does not automatically
*                 resize the form or any of its controls. The current
*                 sizes are designed to be adequate for most simple input
*                 functions. There is no arbitrary limitations, other than
*                 VFP's own inherent limitations, on the size of the return
*                 value. However, long titles, prompts, or entered values may
*                 appear truncated on the form.
*
Function rbInputBox
Lparameters tcPrompt, tcTitle, txDefaultValue, tnLeft, tnTop, ;
	tcFormat, tcInputMask, tcPasswordChar
Private pcReturnValue
pcReturnValue = txDefaultValue
Local oInputBox
oInputBox = Createobject("rbInputBox", tcPrompt, tcTitle, ;
	txDefaultValue, tnLeft, tnTop, ;
	tcFormat, tcInputMask, tcPasswordChar)
oInputBox.Show()
Return pcReturnValue



Function rbInputBox2
Lparameters tcPrompt, tcTitle, txDefaultValue, tnLeft, tnTop, ;
	tcFormat, tcInputMask, tcPasswordChar
Private pcReturnValue
pcReturnValue = txDefaultValue
Local oInputBox
oInputBox = Createobject("rbInputBox2", tcPrompt, tcTitle, ;
	txDefaultValue, tnLeft, tnTop, ;
	tcFormat, tcInputMask, tcPasswordChar)
oInputBox.Show()
Return pcReturnValue


Function rbMotivo
Lparameters tcPrompt, tcTitle, txDefaultValue, tnLeft, tnTop, ;
	tcFormat, tcInputMask, tcPasswordChar
	
Private pcReturnValue
pcReturnValue = txDefaultValue

Local oInputBox
oInputBox = Createobject("rbMotivo", tcPrompt, tcTitle, ;
	txDefaultValue, tnLeft, tnTop, ;
	tcFormat, tcInputMask, tcPasswordChar)
oInputBox.Show()

Return pcReturnValue




**************************************************
*-- Class:        rbinputbox
*-- ParentClass:  form
*-- BaseClass:    form
*-- Time Stamp:   01/29/03 01:03:14 PM
*
Define Class rbInputBox As Form


	Height = 113
	Width = 318
	DoCreate = .T.
	AutoCenter = .T.
	Caption = "Input Box"
	ControlBox = .F.
	WindowType = 1
	Name = "frmInputBox"

*-- empty value to return if Cancel is chosen; data type depends on data type of txValueIn
	xemptyvalue = .F.

*-- the default value (if any)
	xdefaultvalue = .F.

*-- the return value
	xreturnvalue = .F.


	Add Object lblinputbox As Label With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Alignment = 1, ;
		Caption = "Enter the value", ;
		Height = 20, ;
		Left = 6, ;
		Top = 26, ;
		Width = 190, ;
		TabIndex = 1, ;
		Name = "lblInputBox"


	Add Object txtinputbox As TextBox With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Century = 1, ;
		Height = 24, ;
		Left = 202, ;
		SelectOnEntry = .T., ;
		TabIndex = 2, ;
		Top = 22, ;
		Width = 110, ;
		Name = "txtInputBox"


	Add Object cmdok As CommandButton With ;
		Top = 72, ;
		Left = 84, ;
		Height = 24, ;
		Width = 72, ;
		Caption = "OK", ;
		Default = .T., ;
		TabIndex = 3, ;
		Name = "cmdOK"


	Add Object cmdcancel As CommandButton With ;
		Top = 72, ;
		Left = 172, ;
		Height = 24, ;
		Width = 72, ;
		Cancel = .T., ;
		Caption = "Cancel", ;
		TabIndex = 4, ;
		Name = "cmdCancel"


	Procedure Unload
	With Thisform
		If Type(".xReturnValue") = "C"
			.xreturnvalue = Rtrim( .xreturnvalue)
		Endif
		pcReturnValue = .xreturnvalue
	Endwith
	Endproc


	Procedure Init
	Lparameters tcPrompt, tcTitle, txDefaultValue, tnLeft, tnTop, ;
		tcFormat, tcInputMask, tcPasswordChar
	If Type("tcPrompt") <> "C"
		tcPrompt = "Enter the value"
	Endif
	If Type("tcTitle") <> "C"
		tcTitle = "Input Box"
	Endif
	If !( Type("txDefaultValue") $ "CDNY")
*	Valid input data types are C, D, N, and Y
		txDefaultValue = ""	&& default to character data type
	Endif
	If Type("tcFormat") <> "C"
		tcFormat = ""
	Endif
	If Type("tcInputMask") <> "C"
		tcInputMask = ""
	Endif
	If Type("tcPasswordChar") <> "C"
		tcPasswordChar = ""
	Endif
	If Len( Alltrim( tcPasswordChar)) > 1
		tcPasswordChar = Left( tcPasswordChar, 1)
	Endif
	Local llAutoCenter
	If Pcount() < 5	&& Top and Left parameters were not passed
		tnLeft = 0
		tnTop = 0
	Else	&& Top and left parameters were passed but may not be numeric
		If Type("tnTop") = "N" And Type("tnLeft") = "N"		&& both are numeric
			llAutoCenter = .F.
		Else	&& one or both is not numeric, so AutoCenter the form
			tnLeft = 0
			tnTop = 0
			llAutoCenter = .T.
		Endif
	Endif

	With Thisform
	*SET STEP ON 
		.lblinputbox.Caption = Alltrim( tcPrompt)
		.Caption = Alltrim( tcTitle)
		.xdefaultvalue = txDefaultValue
		.xreturnvalue = .xdefaultvalue
		.txtinputbox.Value = .xdefaultvalue
		.txtinputbox.Format = Alltrim( tcFormat)
		.txtinputbox.InputMask = Alltrim( tcInputMask)
		.txtinputbox.maxlength = 0
		.txtinputbox.PasswordChar = tcPasswordChar
		.Top = tnTop
		.Left = tnLeft
		.AutoCenter = llAutoCenter		&& Set AutoCenter last so it overrides Top and Left if .T.

		Do Case
		Case Type("txDefaultValue") = "D"
			.xemptyvalue = {}
		Case Type("txDefaultValue") = "N"
			.xemptyvalue = 0
		Case Type("txDefaultValue") = "Y"
			.xemptyvalue = $0
		Otherwise
			.xemptyvalue = ""
		Endcase
	Endwith
	Endproc


	Procedure cmdok.Click
	With Thisform
		.xreturnvalue = .txtinputbox.Value
		.Release()
	Endwith
	Endproc


	Procedure cmdcancel.Click
*
*	If Cancel was chosen, return the empty value of the correct data type.
*
	With Thisform
		.xreturnvalue = .xemptyvalue
		.Release()
	Endwith
	Endproc


Enddefine
*
*-- EndDefine: btn_exp
**************************************************












Define Class lx_compr_rolos_m_vol As Container


	Width = 162
	Height = 47
	Name = "lx_compr_rolos_m_vol1"
	BorderWidth = 0
	BackStyle = 0


	Add Object tx_marca_volume As lx_textbox_base With ;
		ControlSource = "v_compras_01.marca_volumes", ;
		Height = 21, ;
		Left = 104, ;
		TabIndex = 11, ;
		Top = 26, ;
		Width = 58, ;
		Name = "tx_marca_volume"


	Add Object lx_label5 As lx_label With ;
		AutoSize = .F., ;
		Caption = "Marca Volumes", ;
		Height = 15, ;
		Left = 0, ;
		Top = 29, ;
		Width = 100, ;
		TabIndex = 46, ;
		Name = "Lx_label5"


	Add Object tx_cmprimento_rolos As lx_textbox_base With ;
		ControlSource = "v_compras_01.comprimento_de_rolos", ;
		Height = 22, ;
		InputMask = "999.9999", ;
		Left = 104, ;
		TabIndex = 10, ;
		Top = 0, ;
		Width = 58, ;
		Name = "tx_cmprimento_rolos"


	Add Object lx_label4 As lx_label With ;
		AutoSize = .F., ;
		Caption = "Comprimento", ;
		Height = 15, ;
		Left = 0, ;
		Top = 4, ;
		Width = 100, ;
		TabIndex = 45, ;
		p_muda_size = .F., ;
		Name = "Lx_label4"


	Procedure tx_marca_volume.l_desenhista_recalculo
	If v_Compras_01.Marca_Volumes > 100

		f_Msg(['Marca volumes não deve passar de 100% !', 0+48, 'Atenção'])
		Return .F.

	Endif

	Return .T.
	Endproc


	Procedure tx_cmprimento_rolos.l_desenhista_recalculo
	If v_Compras_01.Comprimento_de_Rolos > 100

		f_Msg(['O comprimento não deve passar de 100% !', 0+48, 'Atenção'])
		Return .F.

	Endif

	Return .T.
	Endproc


Enddefine




**************************************************
*-- Class:        rbinputbox
*-- ParentClass:  form
*-- BaseClass:    form
*-- Time Stamp:   01/29/03 01:03:14 PM
*
Define Class rbInputBox2 As Form


	Height = 113
	Width = 318
	DoCreate = .T.
	AutoCenter = .T.
	Caption = "Input Box"
	ControlBox = .F.
	WindowType = 1
	Name = "frmInputBox"

*-- empty value to return if Cancel is chosen; data type depends on data type of txValueIn
	xemptyvalue = .F.

*-- the default value (if any)
	xdefaultvalue = .F.

*-- the return value
	xreturnvalue = .F.


	Add Object lbluser As Label With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Alignment = 1, ;
		Caption = "Usuário", ;
		Height = 20, ;
		Left = 6, ;
		Top = 16, ;
		Width = 190, ;
		TabIndex = 1, ;
		Name = "lblUser"


	Add Object txtUser As TextBox With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Century = 1, ;
		Height = 24, ;
		Left = 202, ;
		SelectOnEntry = .T., ;
		TabIndex = 2, ;
		Top = 12, ;
		Width = 110, ;
		Name = "txtUser"
	ControlSource = "xUserSenha.Usuario"


	Add Object lblinputbox As Label With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Alignment = 1, ;
		Caption = "Enter the value", ;
		Height = 20, ;
		Left = 6, ;
		Top = 46, ;
		Width = 190, ;
		TabIndex = 3, ;
		Name = "lblInputBox"


	Add Object txtinputbox As TextBox With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Century = 1, ;
		Height = 24, ;
		Left = 202, ;
		SelectOnEntry = .T., ;
		TabIndex = 4, ;
		Top = 42, ;
		Width = 110, ;
		Name = "txtInputBox"


	Add Object cmdok As CommandButton With ;
		Top = 72, ;
		Left = 84, ;
		Height = 24, ;
		Width = 72, ;
		Caption = "OK", ;
		Default = .T., ;
		TabIndex = 5, ;
		Name = "cmdOK"


	Add Object cmdcancel As CommandButton With ;
		Top = 72, ;
		Left = 172, ;
		Height = 24, ;
		Width = 72, ;
		Cancel = .T., ;
		Caption = "Cancel", ;
		TabIndex = 6, ;
		Name = "cmdCancel"


	Procedure Unload
	With Thisform
		If Type(".xReturnValue") = "C"
			.xreturnvalue = Rtrim( .xreturnvalue)
		Endif
		pcReturnValue = .xreturnvalue
	Endwith
	Endproc


	Procedure Init
	Lparameters tcPrompt, tcTitle, txDefaultValue, tnLeft, tnTop, ;
		tcFormat, tcInputMask, tcPasswordChar
	If Type("tcPrompt") <> "C"
		tcPrompt = "Enter the value"
	Endif
	If Type("tcTitle") <> "C"
		tcTitle = "Input Box"
	Endif
	If !( Type("txDefaultValue") $ "CDNY")
*	Valid input data types are C, D, N, and Y
		txDefaultValue = ""	&& default to character data type
	Endif
	If Type("tcFormat") <> "C"
		tcFormat = ""
	Endif
	If Type("tcInputMask") <> "C"
		tcInputMask = ""
	Endif
	If Type("tcPasswordChar") <> "C"
		tcPasswordChar = ""
	Endif
	If Len( Alltrim( tcPasswordChar)) > 1
		tcPasswordChar = Left( tcPasswordChar, 1)
	Endif
	Local llAutoCenter
	If Pcount() < 5	&& Top and Left parameters were not passed
		tnLeft = 0
		tnTop = 0
	Else	&& Top and left parameters were passed but may not be numeric
		If Type("tnTop") = "N" And Type("tnLeft") = "N"		&& both are numeric
			llAutoCenter = .F.
		Else	&& one or both is not numeric, so AutoCenter the form
			tnLeft = 0
			tnTop = 0
			llAutoCenter = .T.
		Endif
	Endif

	With Thisform
		.lblinputbox.Caption = Alltrim( tcPrompt)
		.Caption = Alltrim( tcTitle)
		.xdefaultvalue = txDefaultValue
		.xreturnvalue = .xdefaultvalue
		.txtinputbox.Value = .xdefaultvalue
		.txtinputbox.Format = Alltrim( tcFormat)
		.txtinputbox.InputMask = Alltrim( tcInputMask)
		.txtinputbox.PasswordChar = tcPasswordChar
		.Top = tnTop
		.Left = tnLeft
		.AutoCenter = llAutoCenter		&& Set AutoCenter last so it overrides Top and Left if .T.

		Do Case
		Case Type("txDefaultValue") = "D"
			.xemptyvalue = {}
		Case Type("txDefaultValue") = "N"
			.xemptyvalue = 0
		Case Type("txDefaultValue") = "Y"
			.xemptyvalue = $0
		Otherwise
			.xemptyvalue = ""
		Endcase
	Endwith
	Endproc


	Procedure cmdok.Click
	With Thisform
	
	    IF f_vazio(.txtUser.Value)
	       MESSAGEBOX("Informe o Usuário!")
	       RETURN 
	    endif
	
		.xreturnvalue = .txtinputbox.Value

*!*			Select xUserSenha
*!*			Zap
*!*			Append Blank
		Replace usuario With Alltrim(.txtUser.Value) IN xUserSenha



		.Release()
	Endwith
	Endproc




	Procedure cmdcancel.Click
*
*	If Cancel was chosen, return the empty value of the correct data type.
*
	With Thisform
		.xreturnvalue = .xemptyvalue
		.Release()
	Endwith
	Endproc


Enddefine
*
*-- EndDefine: btn_exp
**************************************************




**************************************************
*-- Class:        rbinputbox
*-- ParentClass:  form
*-- BaseClass:    form
*-- Time Stamp:   01/29/03 01:03:14 PM
*
Define Class rbMotivo As Form


	Height = 113
	Width = 318
	DoCreate = .T.
	AutoCenter = .T.
	Caption = "Motivo"
	ControlBox = .F.
	WindowType = 1
	Name = "frmMotivoAlt"

*-- empty value to return if Cancel is chosen; data type depends on data type of txValueIn
	xemptyvalue = .F.

*-- the default value (if any)
	xdefaultvalue = .F.

*-- the return value
	xreturnvalue = .F.


	Add Object lblMotivo As Label With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Alignment = 1, ;
		Caption = "MOTIVO", ;
		Height = 20, ;
		Left = 35, ;
		Top = 6, ;
		Width = 60, ;
		TabIndex = 1, ;
		Name = "lblUser"


	Add Object cboMotivo As Combobox With ;
		FontName = "Arial", ;
		FontSize = 9, ;
		Century = 1, ;
		Height = 24, ;
		Left = 50, ;
		TabIndex = 2, ;
		Top = 22, ;
		Width = 250, ;
		style = 2,;
		Name = "cboMotivo"



	Add Object cmdok As CommandButton With ;
	   Top = 72, ;
		Left = 230, ;
		Height = 24, ;
		Width = 72, ;
		Cancel = .T., ;
		Caption = "OK", ;
		TabIndex = 6, ;
		Name = "cmdOK"



	Procedure Unload
	With Thisform
		If Type(".xReturnValue") = "C"
			.xreturnvalue = Rtrim( .xreturnvalue)
		Endif
		pcReturnValue = .xreturnvalue
	Endwith
	Endproc


	Procedure Init
	
	Lparameters tcPrompt, tcTitle, txDefaultValue, tnLeft, tnTop, ;
		tcFormat, tcInputMask, tcPasswordChar
	If Type("tcPrompt") <> "C"
		tcPrompt = "Enter the value"
	Endif
	If Type("tcTitle") <> "C"
		tcTitle = "Input Box"
	Endif
	If !( Type("txDefaultValue") $ "CDNY")
*	Valid input data types are C, D, N, and Y
		txDefaultValue = ""	&& default to character data type
	Endif
	If Type("tcFormat") <> "C"
		tcFormat = ""
	Endif
	If Type("tcInputMask") <> "C"
		tcInputMask = ""
	Endif
	If Type("tcPasswordChar") <> "C"
		tcPasswordChar = ""
	Endif
	If Len( Alltrim( tcPasswordChar)) > 1
		tcPasswordChar = Left( tcPasswordChar, 1)
	ENDIF
	
	Local llAutoCenter
	If Pcount() < 5	&& Top and Left parameters were not passed
		tnLeft = 0
		tnTop = 0
	Else	&& Top and left parameters were passed but may not be numeric
		If Type("tnTop") = "N" And Type("tnLeft") = "N"		&& both are numeric
			llAutoCenter = .F.
		Else	&& one or both is not numeric, so AutoCenter the form
			tnLeft = 0
			tnTop = 0
			llAutoCenter = .T.
		Endif
	Endif

	With Thisform
*!*		
*!*			.lblinputbox.Caption = Alltrim( tcPrompt)
			.Caption = "Motivo da Alteração de Entrega"
*!*			.xdefaultvalue = txDefaultValue
*!*			.xreturnvalue = .xdefaultvalue
*!*			.txtinputbox.Value = .xdefaultvalue
*!*			.txtinputbox.Format = Alltrim( tcFormat)
*!*			.txtinputbox.InputMask = Alltrim( tcInputMask)
*!*			.txtinputbox.PasswordChar = tcPasswordChar

	    .cbomotivo.rowsourcetype  = 1
		.cbomotivo.rowsource = "Alteração compras,Alteração Fornecedor"
		.cbomotivo.requery()
		
		.Top = tnTop
		.Left = tnLeft
		.AutoCenter = llAutoCenter		&& Set AutoCenter last so it overrides Top and Left if .T.

		Do Case
		Case Type("txDefaultValue") = "D"
			.xemptyvalue = {}
		Case Type("txDefaultValue") = "N"
			.xemptyvalue = 0
		Case Type("txDefaultValue") = "Y"
			.xemptyvalue = $0
		Otherwise
			.xemptyvalue = ""
		ENDCASE
		
		
	Endwith
	Endproc


	Procedure cmdok.Click
	With Thisform
	
	    IF f_vazio(.cboMotivo.Value)
	       MESSAGEBOX("Informe o MOTIVO!")
	       RETURN 
	    endif
	
		
		
		xmot = .cboMotivo.Value
		
		Replace motivo With Alltrim(xmot) IN xUserSenha

	

		f_insert("insert into CAEDU_COMPRAS_ENTREGA_LOG (PEDIDO, DATA_ALTERACAO_ENTREGA, DATA_ENTREGA, DATA_ENTREGA_NOVA, MOTIVO, USUARIO ) "+;
			" values (?V_COMPRAS_01.PEDIDO, getdate(), ?x_entreg_atu.entrega , ?v_compras_01_produtos.entrega, ?xmot, ?wusuario )")
			
		=REQUERY('V_CAEDU_LOG_ENTRADA')
		
		thisform.Visible = .f.


		.Release()
		
	Endwith
	Endproc


Enddefine
*
*-- EndDefine: btn_exp
**************************************************







