procedure func_Relatorio
lparameter xtipo,xObj

if UPPER(xtipo)='PRE' or UPPER(xtipo)='IMP'
	=Select_Data()
	=General_Img_Modulos()
	=General_Img_Empresa()
	xObj.MainAlias = 'vtmp_documentacoes_fechamento_00'
	xObj.CopyTables("tmp_modulos")
	xObj.CopyTables("tmp_logotipo")
endif

Return .t.
*---------------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------------*
Procedure Select_Data

select modulo,transacao,descricao_transacao,comentario_resumido,comentario_detalhado,mostra_destaque,versao,build into cursor tmp_stru from v_documentacoes_fechamento_00 where .f.
sele tmp_stru
=afields(xcampos)

create cursor vtmp_documentacoes_fechamento_00 from array xcampos
sele v_documentacoes_fechamento_00
count to xRger
xRatu = 0

go top
scan
	xRatu = xRatu + 1
*	f_prog_bar(f_traduz('Processanto Dados'),xRatu,xRger)
	Messagebox.ShowProgress("Processando Dados...", xRger)
	xComent    = iif(widioma='1',v_documentacoes_fechamento_00.comentario_resumido,v_documentacoes_fechamento_00.comentario_resumido_idioma)
	xComentDet = iif(widioma='1',v_documentacoes_fechamento_00.comentario_detalhado,v_documentacoes_fechamento_00.comentario_detalhado_idioma)
	sele vtmp_documentacoes_fechamento_00
	appe blank
	replace modulo               with v_documentacoes_fechamento_00.modulo,;
	        transacao            with allt(v_documentacoes_fechamento_00.transacao),;
	        descricao_transacao  with allt(f_traduz(v_documentacoes_fechamento_00.descricao_transacao)),;
	        comentario_resumido  with allt(xComent),;
	        comentario_detalhado with allt(xComentDet),;
	        mostra_destaque      with v_documentacoes_fechamento_00.mostra_destaque,;
	        versao               with v_documentacoes_fechamento_00.versao,;
	        build                with v_documentacoes_fechamento_00.build

	sele v_documentacoes_fechamento_00
endscan
go top
Messagebox.ShowProgress()
Return .t.
*---------------------------------------------------------------------------------------------------------------------------*
	


*---------------------------------------------------------------------------------------------------------------------------*
Procedure General_Img_Modulos
*--- cursor
create cursor tmp_modulos (modulo c(6),descritivo c(50),ico g,idioma c(1))

*--- gravar icones do módulos ( bmp )
select distinct modulo,descritivo,imagem from v_documentacoes_fechamento_00 into cursor tmp_mod readwrite
sele tmp_mod
count to xRger
xRatu = 0

go top
scan
	xRatu = xRatu + 1
*	f_prog_bar(f_traduz('Processanto Imagens'),xRatu,xRger)
	Messagebox.ShowProgress("Processando Imagens...", xRger)
	sele tmp_modulos
	appe blank
	replace modulo with tmp_mod.modulo, descritivo with f_traduz(tmp_mod.descritivo),idioma with widioma

	if file(allt(tmp_mod.imagem))
		xico = allt(tmp_mod.imagem)
	else
		xico = allt('linx_lg.bmp')
	endif
	if !isnull(xico) and file(xico)
		append general ico from &xico
	endif 	

	sele tmp_mod
endscan

sele tmp_modulos
go top
Messagebox.ShowProgress()
Return .t.
*---------------------------------------------------------------------------------------------------------------------------*



*---------------------------------------------------------------------------------------------------------------------------*
Procedure General_Img_Empresa
create cursor tmp_logotipo (cab_empresa c(50),cab_titulo c(50),idioma c(1),logo g)

ximg = iif(widioma='1','linxScreen.bmp','linxScreen_gf.bmp')
if file(ximg)
	sele tmp_logotipo
	appe blank
	replace cab_empresa with f_traduz(wempresa_nome),cab_titulo with f_traduz('Documentação da Versão'),idioma with widioma
*/	append general logo from &ximg
	append general logo from '&ximg'
endif

Return .t.
*---------------------------------------------------------------------------------------------------------------------------*
