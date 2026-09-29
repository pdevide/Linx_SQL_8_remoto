procedure func_Relatorio
lparameter xtipo,xObj

if UPPER(xtipo)='PRE' or UPPER(xtipo)='IMP'

	**---------------------------------------------------------------------------------------------------------------------**
	*------ Gerar coluna acumulado
	select *,qtde as qtde_acum from v_materiais_extrato_01 into cursor tmp_stru where .f.
	sele tmp_stru
	=afields(xcampos)
	create cursor vtmp_materiais_extrato_01 from array xcampos

	*------ Gravar os registros básicos
	sele v_materiais_extrato_01
	repl all emissao with {} for isnull(emissao)
	go top
	scan
		scatter to xmemvar
		sele vtmp_materiais_extrato_01
		appe blank
		gather from xmemvar
		sele v_materiais_extrato_01
	endscan
	**---------------------------------------------------------------------------------------------------------------------**
	
	*------ Gravar acumulado
	sele vtmp_materiais_extrato_01
	index on material+cor_material+str(year(emissao))+str(month(emissao)) tag iExtr

	*------ Igualar Cores
	select distinct material,cor_material from vtmp_materiais_extrato_01 into cursor tmp_cores
	select distinct str(year(emissao)) as ano, str(month(emissao)) as mes from vtmp_materiais_extrato_01 into cursor tmp_anomes

	sele tmp_cores
	go top
	scan
		sele tmp_anomes
		scan
			sele vtmp_materiais_extrato_01
			seek tmp_cores.material + tmp_cores.cor_material + tmp_anomes.ano + tmp_anomes.mes
			if eof()
				select distinct desc_material,desc_cor_material from vtmp_materiais_extrato_01 where material=tmp_cores.material and cor_material=tmp_cores.cor_material into cursor tmp_descri
				sele vtmp_materiais_extrato_01
				appe blank 
				xDataRepl = ctod( '01/' + right('0'+allt(tmp_anomes.mes),2) + '/' + right(allt(tmp_anomes.ano),2) )
				replace material with tmp_cores.material, desc_material with tmp_descri.desc_material, cor_material with tmp_cores.cor_material, desc_cor_material with tmp_descri.desc_cor_material emissao with xDataRepl
			endif
		endscan
		sele tmp_cores
	endscan


	*------- Gravar Qtde Acumulado
	select material,cor_material,str(year(emissao)) as ano, str(month(emissao)) as mes,sum(qtde) as qtde from vtmp_materiais_extrato_01 group by 1,2,3,4 into cursor tmp_qtdes
	sele tmp_qtdes
	go top
	do whil ! eof()
		xMat = material
		xCor = cor_material
		xQtAcum = 0
		scan whil material=xMat and cor_material=xCor
			xAno = ano
			xMes = mes
			xQtAcum   = xQtAcum + qtde
			xDataRepl = ctod( '01/' + right('0'+allt(xMes),2) + '/' + right(allt(xAno),2) )

			sele vtmp_materiais_extrato_01
			seek xMat+xCor+xAno+xMes
			if eof()
				appe blank
				replace material with xMat, cor_material with xCor, emissao with xDataRepl
			endif

			replace qtde_acum with xQtAcum
			sele tmp_qtdes
		endscan
	enddo

	*------- Index Ordem da impressão antes de copiar
	sele vtmp_materiais_extrato_01
	index on material+str(year(emissao))+str(month(emissao))+tipo+cor_material tag iExtr

	*---- Substituir Tab.Pai (para copia)
	xObj.MainAlias =  'vtmp_materiais_extrato_01'
endif

sele v_materiais_extrato_01
index on material+cor_material+str(year(emissao))+RIGHT('0'+ALLTRIM(str(month(emissao))),2) tag iExtr
Return .t.
**-------------------------------------------------------------------------------------------------------------------------**
