procedure func_Relatorio
lparameter xtipo,R
return .t.


fUNCT f_024202a
lpara ppedido,pfornecedor,pdata,pcusto
xalias = alias()
Sele V_Cotacoes_00_material
*- Faz a pesquisa na tabela  COMPRAS_MATERIAL para achar o numero do pedido 
xSele = "SELECT PEDIDO FROM COMPRAS_MATERIAL WHERE                        "+;
        "COTACAO            = ?V_COTACOES_00_MATERIAL.COTACAO  AND  "+;
  	     "MATERIAL            = ?V_COTACOES_00_MATERIAL.MATERIAL AND  "+;
  	     "COR_MATERIAL = ?V_COTACOES_00_MATERIAL.COR_MATERIAL"
	If ! F_Select(xSele,"xTemp1")	               
		f_msg(["Impossivel pesquizar em Compras_Material...",16,"Atenção...!"])
		Return .f.
	EndIf
	
	Sele V_Cotacoes_00_Mat_Fornecedor
	Locate For Cotacao         = V_Cotacoes_00_Material.Cotacao          and ;
              Material           = V_Cotacoes_00_Material.Material           and ;
              Cor_Material =  V_Cotacoes_00_Material.Cor_Material and ;
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