Procedure f_requery_095016
xsele = sele()
Sele V_Contas_Lancamentos_01_itens
=requery()
Sele V_A_Receber_Pgtos_01_Quitacao
=requery()
f_select('select clifor from cadastro_cli_for where nome_clifor=?v_contas_lancamentos_01.favorecido_cheque','x_favorecido','v_contas_lancamentos_01')
sele (xsele)
Return
