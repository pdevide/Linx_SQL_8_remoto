**-------------------------------------------------------------------------------------------------------------------------**
Procedure Requery_004005
requery('v_compras_01_consumivel') 
f_select('select * from cadastro_cli_for where cadastro_cli_for.nome_clifor=?v_compras_01.fornecedor ','cadastro_cli_for',alias())
f_select('select * from cadastro_cli_for where  NOME_CLIFOR=?v_compras_01.Filial_a_faturar','filial',alias())
Return
**-------------------------------------------------------------------------------------------------------------------------**
