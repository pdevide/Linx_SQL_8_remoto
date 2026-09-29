procedure func_Relatorio
lparameter xtipo,R
return .t.

fUNCT f_024002a
lpara ppedido,pfornecedor,pdata,pcusto
xalias = alias()
Sele V_Cotacoes_00_Consumivel
*- Faz a pesquisa na tabela  COMPRAS_MATERIAL para achar o numero do pedido 
xSele = "SELECT PEDIDO FROM COMPRAS_CONSUMIVEL WHERE                        "+;
        "COTACAO            = ?V_COTACOES_00_CONSUMIVEL.COTACAO  AND  "+;
  	     "CONSUMIVEL            = ?V_COTACOES_00_CONSUMIVEL.CONSUMIVEL "
	If ! F_Select(xSele,"xTemp1")	               
		f_msg(["Impossivel pesquizar em Compras_Material...",16,"Atenção...!"])
		Return .f.
	EndIf
	
	Sele V_Cotacoes_00_Cons_Fornecedor
	Locate For Cotacao         = V_Cotacoes_00_CONSUMIVEL.Cotacao          and ;
              Consumivel           = V_Cotacoes_00_CONSUMIVEL.CONSUMIVEL           and ;
              Status             = "P"
	If ! Eof()
		pFornecedor = Fornecedor
		pCusto            = Custo_A_Vista
	Else
		pFornecedor = .Null.
		pCusto            = .Null.
	EndIf

	If ! F_Vazio(xTemp1.Pedido)

		pPedido = xTemp1.Pedido
		XPEDIDO  = xTemp1.Pedido

		*- Faz a pesquisa na tabela  COMPRAS para achar a data  de emissao do pedido 
		xSele = "SELECT EMISSAO FROM COMPRAS WHERE PEDIDO = ?XPEDIDO"

		If ! F_Select(xSele,"xTemp2")	               
			f_msg(["Impossivel pesquizar em Compras_Material...",16,"Atenção...!"])
			Return .f.
		EndIf
		pData = xTemp2.Emissao
	Else
		pPedido            = .Null.
		pData = .Null.
	EndIf

Sele (xalias)	
XPEDIDO = PPEDIDO
XFORNECEDOR = PFORNECEDOR
XDATA_PEDIDO = PDATA
XCUSTO_APROVADO = PCUSTO
return .T.