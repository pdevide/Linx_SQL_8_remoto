LOCAL lcStrConn as String
lcStrConn = [Server=192.168.0.55;driver={SQL Server};Provider=SQLOLEDB.1;Persist Security Info=True;DATABASE=CAEDU;UID=printbar_user;PWD=#C@edu$7890@]
PUBLIC conexao

conexao = SqlStringConnect( lcStrConn , .T. )
=SQLSetprop(Conexao,"Asynchronous",.F.)
=SQLSetprop(Conexao,"Transactions",2)

IF conexao > 0
	MESSAGEBOX("Conexão no banco Linx efetuada com sucesso!",64,"Aviso")
ELSE
	MESSAGEBOX("Houve falha na conexão ao banco Linx",16,"Aviso")
ENDIF
		

