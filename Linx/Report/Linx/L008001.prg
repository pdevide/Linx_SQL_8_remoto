**-------------------------------------------------------------------------------------------------------------------------**
Procedure Requery_Pedidos
xsele = sele()

sele v_producao_ordem_01_cores
=requery()

sele v_producao_ordem_01_expedicao  && filha
=requery()

**-- Gera Cursor agrupado por cor
xsele1 = 'produto,cor_pedido,sum(qtde_r),sum(r1),sum(r2),sum(r3),sum(r4),sum(r5),sum(r6),sum(r7),sum(r8),sum(r9),sum(r10),sum(r11),sum(r12),sum(r13),sum(r14),sum(r15),sum(r16),sum(r17),sum(r18),sum(r19),sum(r20),sum(r21),sum(r22),sum(r23),sum(r24),'
xsele2 = 'sum(r25),sum(r26),sum(r27),sum(r28),sum(r29),sum(r30),sum(r31),sum(r32),sum(r33),sum(r34),sum(r35),sum(r36),sum(r37),sum(r38),sum(r39),sum(r40),sum(r41),sum(r42),sum(r43),sum(r44),sum(r45),sum(r46),sum(r47),sum(r48)'
xselect = xsele1 + xsele2
select &xselect from v_producao_ordem_01_expedicao group by cor_pedido into cursor vtmp_cursor

if !used('vtmp_producao_ordem_01_expedicao_cor')
	sele vtmp_cursor
	=afields(xnovo)
	create cursor vtmp_producao_ordem_01_expedicao_cor from array xnovo
endif


**-- atualiza dados (para não perder relacionamentos)
sele vtmp_producao_ordem_01_expedicao_cor
zap

sele vtmp_cursor
go top

scan
	scatter memvar
	sele vtmp_producao_ordem_01_expedicao_cor
	appe blank
	gather memvar
	sele vtmp_cursor
endscan

sele vtmp_producao_ordem_01_expedicao_cor
go top


sele (xsele)
**-------------------------------------------------------------------------------------------------------------------------**
