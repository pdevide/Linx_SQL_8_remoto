**
FUNCTION LoadSecurity
 PUBLIC stringbuffer AS LNSECURITY.StringBuffer, compact500 AS LNSECURITY.Compact500
 PRIVATE oexception
 IF TYPE("Data.SQLServerName")=="C" .AND. TYPE("Data.SQLDatabase")=="C"
    *IF LOWER(ALLTRIM(data.sqlservername))=="a-srv6\sqlwf" .AND. LOWER(ALLTRIM(data.sqldatabase))=="marte"
    IF LOWER(ALLTRIM(data.sqlservername))=="192.168.0.55" .AND. LOWER(ALLTRIM(data.sqldatabase))=="caedu"
    	WAIT WINDOW 'S H O W :'
       RETURN .T.
    ENDIF
 ENDIF
 TRY
    compact500 = CREATEOBJECT("LnSecurity.Compact500")
    stringbuffer = CREATEOBJECT("LnSecurity.StringBuffer")
 CATCH TO oexception
    messagebox.show(string.format("Não foi possível iniciar o componente de segurança. Por favor, execute o VisualLinx.exe. {0}", oexception.message), 16, "Erro criando componente")
 ENDTRY
 IF TYPE("oException")=="O"
    forceshutdown()
    RETURN .F.
 ENDIF
 DO WHILE .T.
    IF  .NOT. compact500.initialize()
       IF messagebox.show(string.translate("{0}Deseja tentar novamente?", compact500.lasterror), 36, "Erro ao inicializar a chave")=6
          LOOP
       ENDIF
       forceshutdown()
       RETURN .F.
    ENDIF
    EXIT
 ENDDO
 IF compact500.isadministrator
    RETURN .T.
 ENDIF
 IF TYPE("wLicenca")=="U" .OR. TYPE("wLicencaID")=="U"
    IF  .NOT. callsecurityform()
       forceshutdown()
       RETURN .F.
    ENDIF
 ENDIF
 strcode = stringbuffer.loadbuffer(stringbuffer.buildbuffer(), wlicencaid)
 IF  .NOT. compact500.isvalidcode(strcode)
    messagebox.show(compact500.lasterror, 16, "Código de licença inválido")
    forceshutdown()
    RETURN .F.
 ENDIF
 IF  .NOT. compact500.checkdate(wlicenca)
    IF messagebox.show(string.format("{0}{1}", compact500.lasterror, "Deseja entrar com uma nova licença agora?"), "Prazo de validade expirado", messageboxicon.question+messageboxbuttons.yesno)==messageboxresult.no
       forceshutdown()
       RETURN .F.
    ENDIF
    IF  .NOT. callsecurityform()
       forceshutdown()
       RETURN .F.
    ENDIF
 ENDIF
 strkeyinfo = stringbuffer.loadbuffer(stringbuffer.buildbuffer(), compact500.read(0, 100))
 IF  .NOT. EMPTY(strkeyinfo)
    strkeyexpire = SUBSTR(strkeyinfo, 18, 8)
    struserinfo = stringbuffer.loadbuffer(stringbuffer.buildbuffer(), wlicenca)
    struserexpire = SUBSTR(struserinfo, 18, 8)
    IF struserexpire>strkeyexpire .AND.  .NOT. compact500.update(wlicenca)
       messagebox.show(string.format("Não foi possível atualizar a chave de proteção. Por favor, entre em contato com o administrador do sistema.\n{0}", compact500.lasterror), 16, "Atenção")
       forceshutdown()
       RETURN .F.
    ENDIF
 ENDIF
 IF  .NOT. compact500.checkproduct(001)
    messagebox.show("A licença informada não permite a utilização desse produto.", 16, "Produto não permitido")
    forceshutdown()
    RETURN .F.
 ENDIF
 IF compact500.checkproduct(003)
    compact500.concurrentsessionscount = compact500.concurrentsessionscount-1
 ENDIF
 intdaystoexpire = 5
 IF f_select("select convert(int, valor_atual) as valor_atual from parametros where parametro = 'LicencaAviso'", "curParam")
    intdaystoexpire = curparam.valor_atual
    USE
 ENDIF
 IF  .NOT. f_select("select acesso_esp_1 from users where usuario = ?wusuario", "curTmpUser")
    messagebox.show("Não foi possível carregar suas permissões de segurança.", 16, "Erro")
    forceshutdown()
    RETURN .F.
 ENDIF
 IF (compact500.daystoexpire<=intdaystoexpire .AND. (curtmpuser.acesso_esp_1 .OR. wusuario="sa") .AND. messagebox.show(string.format("Faltam {0} dias para expirar sua licença de uso do sistema. Deseja atualizar agora?", TRANSFORM(compact500.daystoexpire)), 36, "Atenção")==6)
    callsecurityform()
 ENDIF
 SELECT curtmpuser
 USE
 RETURN .T.
ENDFUNC
**
FUNCTION CheckSecurity
 LOCAL strcode AS STRING
 IF TYPE("Data.SQLServerName")=="C" .AND. TYPE("Data.SQLDatabase")=="C"
    IF LOWER(ALLTRIM(data.sqlservername))=="a-srv6\sqlwf" .AND. LOWER(ALLTRIM(data.sqldatabase))=="marte"
       RETURN .T.
    ENDIF
 ENDIF
 IF TYPE("Data.Connection.State")<>"N" .OR. data.connection.state==0 .OR. compact500.isadministrator
    RETURN .T.
 ENDIF
 IF (TYPE("wLicencaID")=="U")
    messagebox.show("A licença de uso do sistema não foi encontrada.", 16, "Atenção")
    RETURN .F.
 ENDIF
 strcode = stringbuffer.loadbuffer(stringbuffer.buildbuffer(), wlicencaid)
 DO WHILE .T.
    IF  .NOT. compact500.isvalidcode(strcode)
       IF messagebox.show(string.format("{0}. Deseja tentar novamente?", compact500.lasterror), 36, "Atenção")==6
          LOOP
       ENDIF
       RETURN .F.
    ENDIF
    EXIT
 ENDDO
 RETURN .T.
ENDFUNC
**
FUNCTION UnloadSecurity
 IF TYPE("Data.SQLServerName")=="C" .AND. TYPE("Data.SQLDatabase")=="C"
    IF LOWER(ALLTRIM(data.sqlservername))=="a-srv6\sqlwf" .AND. LOWER(ALLTRIM(data.sqldatabase))=="marte"
       RETURN .T.
    ENDIF
 ENDIF
 IF TYPE("Compact500")=="O"
    IF  .NOT. compact500.dispose()
       messagebox.show(compact500.lasterror, 16, "Atenção")
       RETURN .F.
    ENDIF
 ENDIF
 RELEASE compact500, stringbuffer
 RETURN .T.
ENDFUNC
**
FUNCTION CallSecurityForm
 DO FORM Security TO breturnform
 IF  .NOT. breturnform
    RETURN .F.
 ENDIF
 RETURN .T.
ENDFUNC
**
PROCEDURE ForceShutdown
 FOR EACH oform IN _SCREEN.forms
    IF TYPE("oForm.parent.p_pai_alias")<>"U"
       SET DATASESSION TO oform.datasessionid
       SELECT (oform.parent.p_pai_alias)
       TABLEREVERT(.T.)
    ENDIF
 ENDFOR
 ON SHUTDOWN
 CLEAR EVENTS
 CLOSE DATABASES ALL
 unloadsecurity()
 TRY
    QUIT
 CATCH
 ENDTRY
ENDPROC
**
FUNCTION f_en_cr
 LPARAMETERS xpassw
 IF EMPTY(xpassw)
    RETURN ''
 ENDIF
 LOCAL xchar, xval, i, z, xstr, xencriptado, xpal, xinvert
 xpassw = ALLTRIM(xpassw)
 DIMENSION xbin[1]
 FOR i = 1 TO LEN(xpassw)
    xchar = SUBSTR(xpassw, i, 1)
    xval = ASC(xchar)
    xstr = ''
    DO WHILE xval>0
       xrest = MOD(xval, 2)
       xval = INT(xval/2)
       xstr = STR(xrest, 1)+xstr
    ENDDO
    xstr = REPLICATE('0', 8-LEN(xstr))+xstr
    IF TYPE('xbin')<>'L'
       DIMENSION xbin[ALEN(xbin, 1)+1]
    ENDIF
    xbin[i] = xstr
 ENDFOR
 xinvert = ''
 IF LEN(xpassw)>1
    FOR i = 1 TO 8
       FOR z = 1 TO ALEN(xbin, 1)
          xinvert = xinvert+SUBSTR(xbin(z), i, 1)
       ENDFOR
    ENDFOR
 ELSE
    FOR i = 1 TO 8
       xinvert = SUBSTR(xbin(1), i, 1)+xinvert
    ENDFOR
 ENDIF
 xencriptado = ''
 FOR i = 1 TO LEN(xinvert) STEP 8
    xpal = SUBSTR(xinvert, i, 8)
    xbin = 0
    FOR z = 1 TO LEN(xpal)
       xbin = xbin+VAL(SUBSTR(xpal, z, 1))*2**(8-z)
    ENDFOR
    xencriptado = xencriptado+CHR(xbin)
 ENDFOR
 RETURN xencriptado
ENDFUNC
**
FUNCTION f_ds_cr
 LPARAMETERS xsenha
 IF EMPTY(xsenha)
    RETURN ''
 ENDIF
 LOCAL i, z, xstring, xchar, xval, xrest, xstr, xdesencriptado
 xstring = ''
 FOR i = 1 TO LEN(xsenha)
    xchar = SUBSTR(xsenha, i, 1)
    xval = ASC(xchar)
    xstr = ''
    DO WHILE xval>0
       xrest = MOD(xval, 2)
       xval = INT(xval/2)
       xstr = STR(xrest, 1)+xstr
    ENDDO
    xstr = REPLICATE('0', 8-LEN(xstr))+xstr
    xstring = xstring+xstr
 ENDFOR
 DIMENSION xsaida[LEN(xsenha)]
 xsaida = ''
 IF LEN(xsenha)>1
    FOR i = 1 TO LEN(xstring) STEP LEN(xsenha)
       FOR z = 1 TO LEN(xsenha)
          xsaida[z] = xsaida(z)+SUBSTR(xstring, i+z-1, 1)
       ENDFOR
    ENDFOR
 ELSE
    FOR i = 1 TO 8
       xsaida = SUBSTR(xstring, i, 1)+xsaida
    ENDFOR
 ENDIF
 xdesencriptado = ''
 FOR i = 1 TO ALEN(xsaida, 1)
    xbin = 0
    FOR z = 1 TO LEN(xsaida(i))
       xbin = xbin+VAL(SUBSTR(xsaida(i), z, 1))*2**(8-z)
    ENDFOR
    xdesencriptado = xdesencriptado+CHR(xbin)
 ENDFOR
 RETURN xdesencriptado
ENDFUNC
**
