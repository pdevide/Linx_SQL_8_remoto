Procedure Processa_Select()

xsele = alias()

=f_select('select * from cadastro_cli_for where cadastro_cli_for.nome_clifor=?v_compras_01.fornecedor ','cadastro_cli_for')
=f_select('select * from cadastro_cli_for where  NOME_CLIFOR=?v_compras_01.Filial_a_faturar','filial')
=f_select('select * from cadastro_cli_for where  NOME_CLIFOR=?v_compras_01.Filial_a_faturar','faturar')
=f_select('select  *  from cadastro_cli_for where  NOME_CLIFOR=?v_compras_01.Filial_a_entregar','entrega')
=f_select('select  *  from cadastro_cli_for where  NOME_CLIFOR=?v_compras_01.Filial_cobranca','COBRAR')

Sele (xsele)
Return
