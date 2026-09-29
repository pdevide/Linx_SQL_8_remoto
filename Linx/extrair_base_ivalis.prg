SET SYSMENU TO default
SET DEFAULT TO c:\temp

TEXT TO cmdsql NOSHOW TEXTMERGE PRETEXT 7
select 
RTRIM(CAST(REPLACE(CODIGO_BARRA,';','?') AS varchar(25))) AS  CODIGO_BARRA, 
pb.PRODUTO, 
COR_PRODUTO, 
pb.TAMANHO, 
RTRIM(CAST(REPLACE(PB.GRADE,';','?') AS varchar(25))) AS GRADE, 
p.INATIVO, 
RTRIM(CAST(replace(p.DESC_PRODUTO, ';', '') AS VARCHAR(40) )) as DESC_PRODUTO
from PRODUTOS_BARRA pb
inner join produtos p 
	on p.PRODUTO = pb.PRODUTO
ENDTEXT

f_select(cmdsql,"vbaseprod")

arquivo_saida = "saida_"+DTOS(DATE())+".csv"
arquivo_cabec = "cabecalho_"+DTOS(DATE())+".txt"
arquivo_final = "baseprod_"+DTOS(DATE())+".csv"

lcCabec = [Codigo_barra;Produto;Cor_produto;Tamanho;Grade;Inativo;DESCRICAO]&&+CHR(13)+CHR(10)
STRTOFILE(lcCabec,arquivo_cabec)

WAIT WINDOW "Gerando arquivo..." nowait
SELECT vbaseprod

CREATE CURSOR saida_csv (texto C(100) null)
APPEND BLANK
replace texto WITH lcCabec

SELECT vbaseprod
COPY TO &arquivo_saida. DELIMITED WITH CHARACTER ";" WITH ""
SELECT saida_csv
APPEND FROM &arquivo_saida. TYPE sdf
SET DEFAULT TO c:\temp

GO top
COPY TO &arquivo_final. TYPE sdf
 
*!*	lcDosCommand = "geracsv "+arquivo_cabec+" "+arquivo_saida+" "+arquivo_final
*!*	RUN /N &lcDosCommand.
MESSAGEBOX("Arquivo gerado - c:\temp\"+arquivo_final, 64,"Aviso")
