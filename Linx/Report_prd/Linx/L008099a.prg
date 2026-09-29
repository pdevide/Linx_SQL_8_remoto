Procedure Atraso(xfa,xenc)
xfim = iif(!isnull(xfa),"fim_atualizado","fim_previsto")
xatraso=iif(!isnull(xenc),&xfim - xenc,date() - &xfim)
Return xatraso
