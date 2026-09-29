f_select('select VALIDA_CONTABIL from users where usuario = ?wUsuario', 'TMP_User')

If Used('TMP_User') and Reccount('TMP_User')>0 and TMP_User.VALIDA_CONTABIL

	Text to _lcSql NOSHOW PRETEXT 2 TEXTMERGE 
		SELECT
				SUM(CCUSTO) AS CCUSTO
			   ,SUM(FILIAL) AS FILIAL
		FROM (		SELECT
							CAST(0 AS INT) AS CCUSTO
						   ,COUNT(*)	   AS FILIAL
					FROM [DBO].[CTB_FILIAL_RATEIO]
					WHERE STATUS_RATEIO = 1
					UNION ALL
					SELECT
							COUNT(*)	   AS CCUSTO
						   ,CAST(0 AS INT) AS FILIAL
					FROM [DBO].[CTB_CENTRO_CUSTO_RATEIO]
					WHERE STATUS_RATEIO = 1) AS A;
	EndText 
	
	f_select(_lcSql, 'TMP_Valida')

	If Used('TMP_Valida') and Reccount('TMP_Valida') > 0 and (TMP_Valida.ccusto > 0 or TMP_Valida.filial>0)
		
		If TMP_Valida.filial>0
			If MessageBox("Existem lançamentos contábeis com rateios de FILIAL inconsistentes! Deseja corrigir agora?", 36, wUsuario) = 6

				cTela  = "009012"
				cWhere = " where modulo = 'CONTAB' and control_sistema like ?cTela+'%'"
				oNForm = "o_"+Left(cTela,6)

				If Type("oNForm") != "O"
					lcControlSystem = cTela + "%"
					f_select("select control_sistema, navegacao, modulo from transacoes_navega a left join transacoes b "+;
						" on a.cod_transacao = b.cod_transacao" + cWhere,"vTmpNav")
					If Reccount() = 0
						f_msg(["Identificação de navegação não encontrada!", 16, "Aviso"])
						Return .F.
					Endif
					bResult = Evaluate("o_seletor." + Alltrim(vTmpNav.modulo) + ".Click()")
					If !bResult
						f_msg(["Não foi possível acessar o módulo especificado!", 16, "Acesso Negado"])
						Return .F.
					Endif
					If !f_doform(vTmpNav.modulo, vTmpNav.Control_sistema, vTmpNav.NAVEGACAO)
						Return .F.
					Endif
				Endif

				oNForm = &oNForm

				&&Abre o form 009012
				oNForm.Show()

				With oNForm

					&&Monta a consulta no form 009012
					.LX_FORM1.CK_STATUS_RATEIO.Value = 1

					&&Efetua a pesquisa
					o_toolbar.Botao_procura.Click()

					.Refresh
				Endwith
			Else 
				MessageBox("Para correção dos rateios inconsistentes é preciso acessar a tela LX009012 - Rateio de Filial, nas tabelas de apoio do módulo CONTABILIDADE!"+Chr(13)+Chr(10)+"Não ajustar esses rateior fará com que os lançamentos que os utilizam não sejam devidamente fechados!", 48, wUsuario)
			EndIf 
		EndIf 
		
		If TMP_Valida.ccusto>0
			If MessageBox("Existem lançamentos contábeis com rateios de CENTRO DE CUSTO inconsistentes! Deseja corrigir agora?", 36, wUsuario) = 6

				cTela  = "009011"
				cWhere = " where modulo = 'CONTAB' and control_sistema like ?cTela+'%'"
				oNForm = "o_"+Left(cTela,6)

				If Type("oNForm") != "O"
					lcControlSystem = cTela + "%"
					f_select("select control_sistema, navegacao, modulo from transacoes_navega a left join transacoes b "+;
						" on a.cod_transacao = b.cod_transacao" + cWhere,"vTmpNav")
					If Reccount() = 0
						f_msg(["Identificação de navegação não encontrada!", 16, "Aviso"])
						Return .F.
					Endif
					bResult = Evaluate("o_seletor." + Alltrim(vTmpNav.modulo) + ".Click()")
					If !bResult
						f_msg(["Não foi possível acessar o módulo especificado!", 16, "Acesso Negado"])
						Return .F.
					Endif
					If !f_doform(vTmpNav.modulo, vTmpNav.Control_sistema, vTmpNav.NAVEGACAO)
						Return .F.
					Endif
				Endif

				oNForm = &oNForm

				&&Abre o form 009011
				oNForm.Show()

				With oNForm

					&&Monta a consulta no form 009011
					.LX_FORM1.CK_STATUS_RATEIO.Value = 1

					&&Efetua a pesquisa
					o_toolbar.Botao_procura.Click()

					.Refresh
				Endwith
			Else 
				MessageBox("Para correção dos rateios inconsistentes é preciso acessar a tela LX009011 - Rateio de Centro de Custo, nas tabelas de apoio do módulo CONTABILIDADE!"+Chr(13)+Chr(10)+"Não ajustar esses rateior fará com que os lançamentos que os utilizam não sejam devidamente fechados!", 48, wUsuario)
			EndIf 
		EndIf 
		
	EndIf 
	
EndIf 

If Used('TMP_Valida')
	Use IN TMP_Valida
EndIf 

If Used('TMP_User')
	Use in TMP_User
EndIf 