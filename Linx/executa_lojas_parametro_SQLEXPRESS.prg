
SET STEP ON

TEXT TO lc_sql TEXTMERGE noshow  

select  CODIGO_FILIAL, IP, BANCO , loja
from
INFO_LOJAS
where codigo_filial is not null
and instancia not like  '%EXPRESS%'
AND IP IS NOT NULL
  			
ENDTEXT

	IF USED("xconfig")
	   	USE IN xconfig
	endif


	f_select(lc_sql, 'xconfig')
	
	
SELECT xconfig
SCAN

	lc_codigo_filial  = ALLTRIM(xconfig.codigo_filial)  
	lc_filial  = ALLTRIM(xconfig.loja)  
	lc_usuario  = 'sa'
	lc_senha    = 'C@edu1234'
	lc_Nome_BD  = ALLTRIM(xconfig.banco)
	lc_servidor  = ALLTRIM(xconfig.ip)
	  
	lc_string_conn = "DRIVER=SQL Server; UID=<usuario>; pwd=<senha>; DATABASE=<nome_banco>;WSID=FISCAL ;APP=Microsoft Visual FoxPro ;SERVER=<servidor>"


	lc_string_conn = STRTRAN(lc_string_conn, '<usuario>', lc_usuario)  
	lc_string_conn = STRTRAN(lc_string_conn, '<senha>', lc_senha)  
	lc_string_conn = STRTRAN(lc_string_conn, '<nome_banco>', lc_Nome_BD)  
	lc_string_conn = STRTRAN(lc_string_conn, '<servidor>', lc_servidor )  

	 **lnConnHandle = SQLSTRINGCONNECT("DRIVER=SQL Server; UID=sa; pwd=52; DATABASE=base_52 ;WSID=FISCAL ;APP=Microsoft Visual FoxPro ;SERVER=10.56.52.10")
	 
	WAIT WINDOW lc_string_conn

	lnConnHandle = SQLSTRINGCONNECT(lc_string_conn)


	WAIT WINDOW  lnConnHandle

	IF lnConnHandle > 0
	    MESSAGEBOX("Filial "+ lc_codigo_filial +" OK")
	    	
		l_sql = ""

	   	TEXT TO l_sql  NOSHOW

declare @codigo_filial varchar(06)
set @codigo_filial = ?lc_codigo_filial



delete item
from
CAEDU_GRUPO_DESCONTO_ITEM item
join produtos_barra bar
  on item.codigo_barra  COLLATE Latin1_General_CI_AS = bar.codigo_barra  COLLATE Latin1_General_CI_AS
where  
bar.produto in
('02080229',
'02080230',
'02220214',
'02220206',
'02220212',
'02220217',
'02220213',
'02220221',
'02220220',
'02220216',
'02220219',
'02220236',
'02220235',
'02220239',
'02220218',
'02220237',
'02220227',
'02220230',
'02220229',
'02220228',
'02220226',
'02220243',
'02220244',
'02220225',
'02220248',
'02220238',
'02220245',
'02220247',
'02220246',
'38030244',
'38030243',
'38030294',
'38030246',
'38030247',
'38030210',
'38030245',
'02220252',
'38030209',
'38030352',
'38030339',
'38030351',
'38030215',
'38030249',
'38030250',
'38030216',
'38030213',
'38030211',
'38030248',
'38030214',
'38030212')


update preco
set preco1 = 19.99
from
   produtos_precos preco
join LOJA_OPERACOES_VENDA oper
      on preco.codigo_tab_preco = oper.codigo_tab_preco
join      
	parametros_loja param
    on rtrim(param.valor_atual) = oper.operacao_venda
    and  param.parametro like 'OPERACAO_VENDA'
 where  param.codigo_filial like @codigo_filial
and 
 preco.produto in
('02080229',
'02080230',
'02220214',
'02220206',
'02220212',
'02220217',
'02220213',
'02220221',
'02220220',
'02220216',
'02220219',
'02220236',
'02220235',
'02220239',
'02220218',
'02220237',
'02220227',
'02220230',
'02220229',
'02220228',
'02220226',
'02220243',
'02220244',
'02220225',
'02220248',
'02220238',
'02220245',
'02220247',
'02220246',
'38030244',
'38030243',
'38030294',
'38030246',
'38030247',
'38030210',
'38030245',
'02220252',
'38030209',
'38030352',
'38030339',
'38030351',
'38030215',
'38030249',
'38030250',
'38030216',
'38030213',
'38030211',
'38030248',
'38030214',
'38030212')
			    					 	
		ENDTEXT
					
			
	    ln_Num_sel =  SQLEXEC(lnConnHandle,l_sql)
	   	SQLDISCONNECT(lnConnHandle )
	ELSE
		    MESSAGEBOX("ERRO CONEXAO Filial "+ lc_codigo_filial +" !!!!")
	ENDIF

	SELECT xconfig
	
ENDSCAN
	