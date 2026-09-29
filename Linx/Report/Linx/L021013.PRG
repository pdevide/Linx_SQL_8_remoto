Function F_Soma
Para pTipo

Do Case
	Case pTipo = "S"
	xProducao_Celula = xProducao_Celula + v_produtiv_metas_00.producao
	xMeta_Celula     = xMeta_Celula     + v_produtiv_metas_00.Meta_dia
	Case pTipo = "Z"
	xProducao_Dia = xProducao_Dia + xProducao_Celula
	xProducao_Celula = 0
	xMeta_Dia     = xMeta_Dia     + xMeta_Celula
	xMeta_Celula     = 0
	Case pTipo = "T"
	xProducao_Dia = 0
	xProducao_Celula = 0
	xMeta_Dia     = 0
	xMeta_Celula     = 0
EndCase