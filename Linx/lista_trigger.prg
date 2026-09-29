TEXT TO cmdsql NOSHOW TEXTMERGE PRETEXT 7
select so.name, sc.text, OBJECT_NAME(so.parent_obj) as pai
from syscomments sc
inner join sysobjects so on so.id = sc.id
where sc.text like '%DATA_PARA_TRANSFERENCIA%'
and OBJECT_NAME(so.parent_obj) in 
('PRODUTOS_PACKS_PERMITIDOS'
,'PROP_PRODUTOS'
,'PRODUTO_CORES'
,'PRODUTOS'
,'PRODUTOS_GRIFFES'
,'PRODUTOS_GRUPO'
,'PRODUTOS_LINHAS'
,'PRODUTOS_PRECOS'
,'PRODUTOS_SUBGRUPO'
,'PRODUTOS_INDICADOR_CFOP'
,'PRODUTOS_BARRA')
AND so.type='TR' and so.name like '%PROD%'
ENDTEXT
f_select(cmdsql,"objs")

