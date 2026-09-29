procedure func_Relatorio
lparameter xtipo,xObj

if UPPER(xtipo)='PRE' or UPPER(xtipo)='IMP'
	IF USED('Cur_producao_reserva')
		SELECT Cur_producao_reserva
		USE
	ENDIF 

	IF USED('Cur_processo_tratamento')
		SELECT Cur_processo_tratamento
		USE
	ENDIF 


	*--Componentes
	TEXT TO xSqlReserva NOSHOW 
		select r.ordem_producao,r.material,m.desc_material,r.cor_material,c.desc_cor_material, m.fabricante,m.ref_fabricante,c.refer_fabricante,
			   r.data_reserva, r.reserva_original,r.consumida,m.unid_estoque  
		  from producao_reserva r
		  join materiais m on m.material = r.material
		  join materiais_cores c on c.material=r.material and c.cor_material=r.cor_material
		 where r.ordem_producao=?v_ordem_fabricao_item_01.ordem_producao
	ENDTEXT 

	f_wait('Aguarde.')
	SELECT v_ordem_fabricao_item_01
	SCAN
		f_select(xSqlReserva,'CurTmp_Reserva',ALIAS())
		IF !USED('Cur_producao_reserva')
			SELECT * FROM CurTmp_Reserva WHERE .f. INTO CURSOR Cur_producao_reserva READWRITE 
		ENDIF
		INSERT INTO Cur_producao_reserva SELECT * FROM CurTmp_Reserva  
	ENDSCAN

	
	*--Processo Produtivo
	SELECT distinct processo_produtivo FROM v_ordem_fabricao_item_01 INTO CURSOR CurLst_processo_produtivo 

	TEXT TO xSqlReserva NOSHOW 
		select p.processo_produtivo, p.tratamento, m.desc_maquina, t.desc_tratamento, p.maquina, m.marca_maquina, m.qtde_agulhas, m.platinas, m.diametro
		  from materiais_tratamento t 
		 inner join materiais_processo_tratamento p on t.tratamento=p.tratamento
		 inner join materiais_maquina m on p.maquina=m.maquina
		 where p.processo_produtivo=?CurLst_processo_produtivo.processo_produtivo
	ENDTEXT 

	f_wait('Aguarde..')
	SELECT CurLst_processo_produtivo
	SCAN
		f_select(xSqlReserva,'CurTmp_Processo',ALIAS())
		IF !USED('Cur_processo_tratamento')
			SELECT * FROM CurTmp_Processo WHERE .f. INTO CURSOR Cur_processo_tratamento READWRITE 
		ENDIF
		INSERT INTO Cur_processo_tratamento SELECT * FROM CurTmp_Processo
	ENDSCAN

	*--copia tabelas
	xObj.CopyTables('Cur_producao_reserva')
	xObj.CopyTables('Cur_processo_tratamento')	

	f_wait()
endif

Return .t.
*---------------------------------------------------------------------------------------------------------------------*
