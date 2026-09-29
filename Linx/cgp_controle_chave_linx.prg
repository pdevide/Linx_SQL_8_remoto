IF PARAMETERS()=0
	p1=WONTOP()
ENDIF

f_select([select name from sysobjects where name='_controle_chave'], [controle_chave])

IF RECCOUNT([controle_chave])=0
*!*		MESSAGEBOX([A tabela de controle chave ainda não existe],48,[Atenção])
ELSE
*!*		MESSAGEBOX([A tabela de controle chave já existe!],48,[Atenção])
ENDIF
m.WORKSTATION = LEFT(SYS(0), AT([#],SYS(0))-2)
m.LOGIN = STRTRAN( SYS(0), m.WORKSTATION+[ # ], [])
m.LINXUSER = wusuario
m.DATE = DTOC(DATE())
m.TIME = TIME()
m.SCREEN = "TELA"
m.LINXKEY = compact500.internalid
if VAL( m.LINXKEY ) < 100	
	return
ENDIF
	
IF 1=2
	MESSAGEBOX( [Login: ]+   m.LOGIN+		CHR(13)+;
		[Estação: ]+ m.WORKSTATION+	CHR(13)+;
		[Usuário: ]+ m.LINXUSER+	CHR(13)+;
		[Data: ]+    m.DATE+		CHR(13)+;
		[Hora: ]+    m.TIME+		CHR(13)+;
		[Tela: ]+    m.SCREEN+		CHR(13)+;
		[Chave: ]+   m.LINXKEY+		CHR(13);				
		, 48, [Atenção])
ELSE
	TEXT TO xCOMANDO NOSHOW TEXTMERGE PRETEXT 7
		Insert into _controle_chave ( workstation, login, linxuser, linxkey)
		VALUES ( ?m.workstation, ?m.login, ?m.linxuser, ?m.linxkey)
	ENDTEXT

*!*		xCOMANDO = [Insert into _controle_chave ( workstation, login, linxuser, linxkey) ]+;
*!*			[ values ('] + m.WORKSTATION +[',']+ m.LOGIN +[',']+;
*!*			m.LINXUSER +[', m.LINXKEY + [')]
*!*	_cliptext= xCOMANDO
	f_insert(xCOMANDO)
	WAIT WINDOW NOWAIT SYS(0)
ENDIF
