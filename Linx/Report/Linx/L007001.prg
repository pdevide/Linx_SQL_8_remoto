*---------------------------------------------------------------------------------------------------------------------------*
procedure f_process_itens

sele v_m_ordem_fabricacao_00_item
=tablerevert(.t.) && < prov. até ver com Alex-pt como vai ficar >
f_popula_filha('v_m_ordem_fabricacao_00','v_m_ordem_fabricacao_00_item')
Return .t.
*---------------------------------------------------------------------------------------------------------------------------*



**-------------------------------------------------------------------------------------------------------------------------**
procedure f_process_reservas

sele v_m_ordem_fabricacao_00_resumo_reserva
=afields(xcampos)
create cursor vtmp_m_ordem_fabricacao_00_resumo_reserva from array xcampos

sele v_m_ordem_fabricacao_00_reserva
=tablerevert(.t.)  && desconsiderar replaces até o Alex acertar views.

sele v_m_ordem_fabricacao_00
go top
scan
	sele v_m_ordem_fabricacao_00_reserva && filha
	requery()

	o_007001.Lx_form1.Lx_pageframe1.Page7.activate() && neta
	sele v_m_ordem_fabricacao_00_resumo_reserva
	go top

	scan
		scatter to xmemvar
		sele vtmp_m_ordem_fabricacao_00_resumo_reserva
		appe blank
		gather from xmemvar
		sele v_m_ordem_fabricacao_00_resumo_reserva
	endscan

	sele v_m_ordem_fabricacao_00
endscan
Return .t.
*---------------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------------*
procedure f_process_envio

sele *,space(25) as desc_material, space(25) as desc_cor_material from v_m_ordem_fabricacao_00_envios into cursor tmp_stru where .f.
sele tmp_stru
=afields(xcampos)
create cursor vtmp_m_ordem_fabricacao_00_envios from array xcampos

sele v_m_ordem_fabricacao_00_reserva
=tablerevert(.t.)  && desconsiderar replaces até o Alex acertar views.
*----------

sele v_m_ordem_fabricacao_00
go top
scan
	sele v_m_ordem_fabricacao_00_envios && filha
	requery()

	o_007001.Lx_form1.Lx_pageframe1.Page6.activate()
	sele v_m_ordem_fabricacao_00_envios
	go top

	scan
		scatter to xmemvar
		sele vtmp_m_ordem_fabricacao_00_envios
		appe blank
		gather from xmemvar

		*--- descrição ( porque não vem na view )
		f_select('select desc_material from materiais where material=?vtmp_m_ordem_fabricacao_00_envios.material','tmp_mat',alias())
		f_select('select desc_cor_material from materiais_cores where material=?vtmp_m_ordem_fabricacao_00_envios.material and cor_material=?vtmp_m_ordem_fabricacao_00_envios.cor_material','tmp_cor',alias())
		replace desc_material with tmp_mat.desc_material, desc_cor_material with tmp_cor.desc_cor_material

		sele v_m_ordem_fabricacao_00_envios
	endscan

	sele v_m_ordem_fabricacao_00
endscan
Return .t.
*---------------------------------------------------------------------------------------------------------------------------*
