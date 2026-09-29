



*!*	F_SELECT("select distinct codigo_filial from loja_venda where DATA_VENDA >='20170516' ",'CURFIL2')

*!*	xcab = ''
*!*	xite=''
*!*	xfil=''

*!*	SELECT CURFIL2
*!*	SCAN
*!*		xcab = ALLTRIM(CURFIL2.codigo_filial)+"_CAB.xlsx"
*!*		xite = ALLTRIM(CURFIL2.codigo_filial)+"_ITE.xlsx"
*!*		xfil = ALLTRIM(CURFIL2.codigo_filial)

*!*		

*!*		TEXT TO cab NOSHOW ADDITIVE TEXTMERGE PRETEXT 7
*!*		SELECT   
*!*		 LOJA_VENDA.CODIGO_FILIAL,LOJA_VENDA.DATA_VENDA,  LOJA_VENDA.CPF_CGC_ECF AS CPF_CNPJ_NO_CUPOM, LOJA_VENDA.TICKET,   LOJA_VENDA.DATA_DIGITACAO, LOJA_VENDA.VENDEDOR,   LOJA_VENDA.OPERACAO_VENDA,    LOJA_VENDA.CODIGO_TAB_PRECO,
*!*		 LOJA_VENDA.DESCONTO,LOJA_VENDA.QTDE_TOTAL,  LOJA_VENDA.VALOR_TIKET,   LOJA_VENDA.VALOR_VENDA_BRUTA,LOJA_VENDA.VALOR_TROCA,LOJA_VENDA.QTDE_TROCA_TOTAL,  LOJA_VENDA.TICKET_IMPRESSO, LOJA_VENDA.TERMINAL,  LOJA_VENDA.GERENTE_LOJA,LOJA_VENDA.GERENTE_PERIODO,LOJA_VENDA.CODIGO_FILIAL_PGTO, 
*!*		 LOJA_VENDA.TERMINAL_PGTO,LOJA_VENDA.LANCAMENTO_CAIXA,LOJA_VENDA.VALOR_CANCELADO,LOJA_VENDA.TOTAL_QTDE_CANCELADA,    LOJA_VENDA.DATA_HORA_CANCELAMENTO,  LOJA_VENDA.PERIODO_FECHAMENTO,LOJA_VENDA.VALOR_PAGO, LOJA_VENDA_PGTO.CAIXA_VENDEDOR,       LOJA_VENDA_PGTO.COD_FORMA_PGTO, 
*!*		 LOJA_FORMAS_PGTO.FORMA_PGTO,  LOJA_OPERACOES_VENDA.DESC_OPERACAO_VENDA,LOJA_VENDEDORES_A.VENDEDOR_APELIDO AS GERENTE,   LOJA_VENDEDORES_B.VENDEDOR_APELIDO AS CAIXA,
*!*		 LOJA_VENDEDORES_C.VENDEDOR_APELIDO AS NOME_GERENTE_PERIODO, LOJA_VENDA_PGTO.CODIGO_FILIAL,LOJA_VENDA_PGTO.TERMINAL,LOJA_VENDA_PGTO.LANCAMENTO_CAIXA,  LOJA_VENDA_PGTO.VALOR_CANCELADO AS VALOR_CANCELADO_PGTO,LOJA_VENDA_PGTO.DESCONTO_PGTO AS DESCONTO_PGTO_VENDA,   LOJA_VENDA_PGTO.TOTAL_VENDA AS TOTAL_PGTO_VENDA         
*!*		 FROM  LOJA_VENDA 
*!*			INNER JOIN LOJA_VENDA_PGTO   
*!*				ON LOJA_VENDA.CODIGO_FILIAL_PGTO = LOJA_VENDA_PGTO.CODIGO_FILIAL    AND 
*!*				LOJA_VENDA.TERMINAL_PGTO = LOJA_VENDA_PGTO.TERMINAL   
*!*				AND LOJA_VENDA.LANCAMENTO_CAIXA = LOJA_VENDA_PGTO.LANCAMENTO_CAIXA  
*!*			INNER JOIN LOJA_FORMAS_PGTO 
*!*				ON LOJA_FORMAS_PGTO.COD_FORMA_PGTO = LOJA_VENDA_PGTO.COD_FORMA_PGTO  
*!*			LEFT JOIN CLIENTES_VAREJO   
*!*				ON CLIENTES_VAREJO.CODIGO_CLIENTE = LOJA_VENDA.CODIGO_CLIENTE  
*!*			INNER JOIN LOJA_VENDEDORES  
*!*				ON LOJA_VENDA.VENDEDOR = LOJA_VENDEDORES.VENDEDOR  
*!*			INNER JOIN LOJA_OPERACOES_VENDA 
*!*				ON LOJA_OPERACOES_VENDA.OPERACAO_VENDA = LOJA_VENDA.OPERACAO_VENDA  
*!*			INNER JOIN LOJA_VENDEDORES LOJA_VENDEDORES_A 
*!*				ON LOJA_VENDA.GERENTE_LOJA = LOJA_VENDEDORES_A.VENDEDOR  
*!*			INNER JOIN LOJA_VENDEDORES LOJA_VENDEDORES_B 
*!*				ON LOJA_VENDA_PGTO.CAIXA_VENDEDOR = LOJA_VENDEDORES_B.VENDEDOR  
*!*			INNER JOIN LOJA_VENDEDORES LOJA_VENDEDORES_C 
*!*				ON LOJA_VENDA.GERENTE_PERIODO = LOJA_VENDEDORES_C.VENDEDOR  
*!*			INNER JOIN LOJAS_VAREJO 
*!*				ON LOJA_VENDA.CODIGO_FILIAL = LOJAS_VAREJO.CODIGO_FILIAL  
*!*			INNER JOIN FILIAIS 
*!*				ON LOJAS_VAREJO.FILIAL = FILIAIS.FILIAL    
*!*			LEFT JOIN LOJA_NOTA_FISCAL 
*!*				ON LOJA_NOTA_FISCAL.NF_NUMERO=LOJA_VENDA_PGTO.NUMERO_FISCAL_VENDA  
*!*				AND  LOJA_NOTA_FISCAL.CODIGO_FILIAL=LOJA_VENDA_PGTO.CODIGO_FILIAL  
*!*				AND  LOJA_NOTA_FISCAL.SERIE_NF = LOJA_VENDA_PGTO.SERIE_NF_SAIDA  
*!*			LEFT JOIN SERIES_NF 
*!*				ON LOJA_NOTA_FISCAL.SERIE_NF=SERIES_NF.SERIE_NF  
*!*			LEFT JOIN CTB_ESPECIE_SERIE 
*!*				ON CTB_ESPECIE_SERIE.ESPECIE_SERIE=SERIES_NF.ESPECIE_SERIE 
*!*		WHERE (LOJA_VENDA_PGTO.NUMERO_CUPOM_FISCAL IS NOT NULL or 
*!*				LOJA_VENDA_PGTO.NUMERO_FISCAL_TROCA IS NOT NULL or 
*!*				LOJA_VENDA_PGTO.NUMERO_FISCAL_VENDA IS NOT NULL) 
*!*				AND LOJA_VENDA.CODIGO_FILIAL = <<xfil>>
*!*				AND LOJA_VENDA.DATA_VENDA >= '20160101' and  LOJA_VENDA.DATA_VENDA <= '20170430'
*!*				AND LOJA_VENDA.TICKET_IMPRESSO = 1 
*!*		ENDTEXT



*!*		*f_select(x,'cDate')

*!*		DO copytoxlsx WITH 'cdate', xcab, .T.







*!*		SELECT CURFIL2
*!*	endscan
SET STEP ON 

SELECT cur_result_cm


xcab = "CMV2017.xlsx"
DO copytoxlsx WITH 'cur_result_cm', xcab, .T.




FUNCTION copytoxlsx 
* Version 4.0
LPARAMETERS cCur,lcFileName,llHead,lnMaxIndexLen,lcFFields,llMemoAsComment,lnCodePage,llOpen
* Parameters
* cCur				name of the table / cursor
* lcFileName		name of the xlsx
* llHead			.T. first row of xlsx contain column names
* lnMaxIndexLen		optional, maximum length of the indexes. A value between 19 and 120. Default 60
* lcFFields			optional, list of fields to be outputed
* llMemoAsComment	optional, memo fields are converted into comments while the cell contains the word "Memo"
* lnCodePage		optional, codepage used for strings
* llOpen			optional, .T. the file is open (default .F.)
# DEFINE MAXIMUMCOMMENTHEIGHT 20 && maximum height of a comment (expressed in sheet rows)
# DEFINE MAXIMUMCOMMENTWIDTH 10  && maximum width of a comment (expressed in sheet columns) 
DECLARE INTEGER ShellExecute IN SHELL32.DLL INTEGER nWinHandle,STRING cOperation,STRING cFileName,STRING cParameters,STRING cDirectory,INTEGER nShowWindow
IF OS(3) < '6' && XP
	Declare INTEGER GetLocaleInfo in Win32API LONG Locale, LONG LCType, STRING @LpLCData, INTEGER cchData
ELSE
	Declare INTEGER GetLocaleInfoEx in Win32API String Locale, LONG LCType, STRING @LpLCData, INTEGER cchData
ENDIF
DECLARE Sleep IN kernel32 INTEGER
#DEFINE ERRLANG "EN"
#IF ERRLANG = "EN"
	#DEFINE ERRMESS1 "Abort"
	#DEFINE ERRMESS2 "Cannot create"
	#DEFINE ERRMESS3 "No xlsx generated"
	#DEFINE ERRMESS4 "Nothing to export"
	#DEFINE ERRMESS5 "Not a cursor/table name"
	#DEFINE ERRMESS6 "already exist."
	#DEFINE ERRMESS7 "Overwrite?"
#ELIF ERRLANG = "ES"
	#DEFINE ERRMESS1 "Abortar"
	#DEFINE ERRMESS2 "No se puede crear"
	#DEFINE ERRMESS3 "Ningún xslx generado"
	#DEFINE ERRMESS4 "Nada que exportar"
	#DEFINE ERRMESS5 "No es un nombre de cursor/tabla"
	#DEFINE ERRMESS6 "ya existe."
	#DEFINE ERRMESS7 "¿Sobreescribir?"
#ELSE
	#DEFINE ERRMESS1 "Abandon"
	#DEFINE ERRMESS2 "Nu se poate crea"
	#DEFINE ERRMESS3 "Nu s-a generat xlsx"
	#DEFINE ERRMESS4 "Nimic de exportat"
	#DEFINE ERRMESS5 "Nume invalid de cursor/tabel"
	#DEFINE ERRMESS6 "exista deja."
	#DEFINE ERRMESS7 "Suprascrieti?"
#ENDIF

LOCAL lcMyPath,lcDir,loerr as Exception
LOCAL lnRowsNo,lnColsNo,lnCurRow,lnCurCol,lnTime,ltTime,lcSetDec,lnColsNoAll,laFieldsAll[1],lnLenStr,lnLenIdx,llMemos,lnII,lSetTalk,lnFFields,laFFields[1]
LOCAL cStrings,lnColChars,llCR,lcValue,lnDec,cMax,ldValue 
LOCAL lcCurr,lcTmp,lnj
LOCAL ldDat01,ldDat11,ldDat02,ldDat12,ldDat03,ltDat02
LOCAL lnFHStr,lnFHSh,lcLenStr,lcLenIdx,lnCountbefore,lcUnion,lcField,lnTotal,cTotal,lcCurRow,ofile,lcSource,lcZipFileName,oShell,oFolder,llBelow7
LOCAL laFields[1,6],lnType,lala[1],lcSetPoint,lnFHCo,lnFHDr,lnCurComm,lnNoRow,laNoRow[1],lniNoRow,lnMaxLenRow,lnCommW,lnCommH

LOCAL lcCurrAlias,llToClose,lcCodePage,lcOldPath,lcStrBad
lcStrBad = ''
FOR lni = 0 TO 31
	IF !INLIST(m.lni,9,10,13)
		lcStrBad = m.lcStrBad + CHR(m.lni)
	ENDIF
NEXT
lcCurrAlias = ALIAS()
llToClose = .F.

IF PCOUNT() < 1 
	MESSAGEBOX(ERRMESS4,48,ERRMESS3)
	RETURN
ELSE
	IF VARTYPE(m.cCur) $ "CV"
		IF !USED(m.cCur)
			USE (m.cCur) IN 0
			llToClose = .T.
		ENDIF
	ELSE
		MESSAGEBOX(ERRMESS5,48,ERRMESS3)
		RETURN
	ENDIF
ENDIF
IF PCOUNT() < 2 
	lcFileName = FORCEEXT(SYS(2015),"xlsx")
ELSE
	IF VARTYPE(m.lcFileName) $ "CV"
		lcFileName = FORCEEXT(m.lcFileName,"xlsx")
	ELSE
		lcFileName = FORCEEXT(SYS(2015),"xlsx")
	ENDIF
ENDIF
IF PCOUNT() < 3
	llHead = .F.
ELSE
	IF VARTYPE(m.llHead) <> "L"
		llHead = .F.
	ENDIF
ENDIF
IF PCOUNT()<4
	lnMaxIndexLen = 60
ELSE
	IF VARTYPE(m.lnMaxIndexLen) $ "NFYBI"
		lnMaxIndexLen = INT(m.lnMaxIndexLen)
	ELSE 
		lnMaxIndexLen = 60
	ENDIF
	lnMaxIndexLen = MIN(MAX(m.lnMaxIndexLen,19),120)
ENDIF

IF FILE(FORCEEXT(m.lcFileName,"xlsx"))
	IF MESSAGEBOX(FORCEEXT(m.lcFileName,"xlsx")+" "+ERRMESS6+CHR(13)+ERRMESS7,4+48,ERRMESS3) = 7
		RETURN
	ELSE
		ERASE (FORCEEXT(m.lcFileName,"xlsx")) RECYCLE
	ENDIF
ENDIF
lnFFields = 0
IF PCOUNT()<5
	lcFFields = ""
ELSE
	IF VARTYPE(m.lcFFields) <> "C"
		lcFFields = ""
	ELSE
		lnFFields = ALINES(laFFields,UPPER(m.lcFFields),1+4,",")
	ENDIF
ENDIF
IF PCOUNT() < 6
	llMemoAsComment = .F.
ELSE
	IF VARTYPE(m.llMemoAsComment) <> "L"
		llMemoAsComment = .F.
	ENDIF
ENDIF
* Thanks to Gregory Green
IF PCOUNT() < 7
	lcCodePage = ''
ELSE
	IF VARTYPE(m.lnCodePage) <> "N"
		lcCodePage = ''
	ELSE
		IF !INLIST(m.lnCodePage,437,620,737,850,852,857,861,865,866,874,895,932,936,949,950,1250,1251,1252,1253,1254,1255,1256)
			lcCodePage = ''
		ELSE
			lcCodePage = 'CODEPAGE = ' + TRANSFORM(m.lnCodePage)
		ENDIF
	ENDIF
ENDIF
IF PCOUNT() < 8
	llOpen = .F.
ELSE
	IF VARTYPE(m.llOpen) <> "L"
		llOpen = .F.
	ENDIF
ENDIF

lSetTalk = SET("Talk")
SET TALK OFF 
lcSetPoint = SET("Point")
SET POINT TO "."
lnColsNoAll=AFIELDS(m.laFieldsAll,m.cCur)
lnColsNo = 0
lnLenStr = 19 && for datetime
llMemos = .F.
lcUnion = ""
cTotal = SYS(2015)
lnTotal = 0
ldDat01 = DATE(1900,3,1)
ldDat02 = DATE(1900,1,1)
ldDat03 = DATE(1900,2,28)
ldDat11 = m.ldDat01 - 61
ldDat12 = m.ldDat02 - 1
ltDat02 = DATETIME(1900,1,1,0,0,0)
lnColChars = 0

FOR lnCurCol = 1 TO m.lnColsNoAll
	IF m.laFieldsAll[m.lnCurCol,2] $ "NFYBIDTLCVM"
		IF !EMPTY(m.lcFFields)
			IF ASCAN(m.laFFields,laFieldsAll[m.lnCurCol,1],1,-1,-1,1+2+4)=0
				LOOP
			ENDIF
		ENDIF
		lnColsNo = m.lnColsNo + 1
		DIMENSION laFields[m.lnColsNo,6]
		laFields[m.lnColsNo,1] = laFieldsAll[m.lnCurCol,1]
		laFields[m.lnColsNo,2] = IIF(laFieldsAll[m.lnCurCol,2] $ "CV",1,;
								IIF(laFieldsAll[m.lnCurCol,2] $ "NF",2,;
								IIF(laFieldsAll[m.lnCurCol,2] == "I",3,;
								IIF(laFieldsAll[m.lnCurCol,2] == "D",4,;
								IIF(laFieldsAll[m.lnCurCol,2] == "T",5,;
								IIF(laFieldsAll[m.lnCurCol,2] == "L",6,;
								IIF(laFieldsAll[m.lnCurCol,2] == "Y",7,;
								IIF(laFieldsAll[m.lnCurCol,2] == "B",8,;
								IIF(laFieldsAll[m.lnCurCol,2] == "M",9,10)))))))))
		laFields[m.lnColsNo,6] = m.lnCurCol
		laFields[m.lnColsNo,3] = laFieldsAll[m.lnCurCol,3]
		laFields[m.lnColsNo,4] = laFieldsAll[m.lnCurCol,4]
		laFields[m.lnColsNo,5] = IIF(m.lnColsNo<=26,[],CHR(64+FLOOR((m.lnColsNo-1)/26)))+CHR(65+MOD(m.lnColsNo-1,26))
	ELSE
		LOOP
	ENDIF
	lcField = laFieldsAll[m.lnCurCol,1]
	IF m.laFieldsAll[m.lnCurCol,2] $ "CV"
		lnLenStr = MAX(m.lnLenStr, laFieldsAll[m.lnCurCol,3])
		IF !EMPTY(m.lcUnion)
			lcUnion = m.lcUnion + " UNION"
		ENDIF
		lcUnion = m.lcUnion + " SELECT DISTINCT CAST(RTRIM(" + m.lcField + ") AS V("+TRANSFORM(m.laFieldsAll[m.lnCurCol,3])+")) FROM " + m.cCur + " WHERE !ISNULL(" + m.lcField + ")"
		SELECT COUNT(*) as no FROM (m.cCur) WHERE ISNULL(&lcField) INTO CURSOR (m.cTotal)
		lnTotal = m.lnTotal + RECCOUNT(m.cCur) - &cTotal..no
	ENDIF
	IF m.laFieldsAll[m.lnCurCol,2] == "D"
		IF !EMPTY(m.lcUnion)
			lcUnion = m.lcUnion + " UNION"
		ENDIF
		lcUnion = m.lcUnion + " SELECT DISTINCT DTOC(" + m.lcField + ") FROM " + m.cCur + " WHERE " + m.lcField + " < m.ldDat02 "
		SELECT COUNT(*) as no FROM (m.cCur) WHERE &lcField < m.ldDat02 INTO CURSOR (m.cTotal)
		lnTotal = m.lnTotal + &cTotal..no
	ENDIF
	IF m.laFieldsAll[m.lnCurCol,2] == "T"
		IF !EMPTY(m.lcUnion)
			lcUnion = m.lcUnion + " UNION"
		ENDIF
		lcUnion = m.lcUnion + " SELECT DISTINCT TTOC(" + m.lcField + ") FROM " + m.cCur + " WHERE " + m.lcField + " < m.ltDat02 "
		SELECT COUNT(*) as no FROM (m.cCur) WHERE &lcField < m.ltDat02 INTO CURSOR (m.cTotal)
		lnTotal = m.lnTotal + &cTotal..no
	ENDIF
	IF m.laFieldsAll[m.lnCurCol,2] == "M"
		lnColChars = m.lnColChars +1
		llMemos = .T.
	ENDIF
NEXT
lnLenIdx = MIN(m.lnMaxIndexLen, m.lnLenStr)
lnTotal = m.lnTotal + m.lnColsNo

SELECT (m.cCur)
COUNT TO m.lnRowsNo
lnTotal = m.lnTotal + m.lnRowsNo * m.lnColChars
lnRowsNo=m.lnRowsNo+IIF(m.llHead,1,0)

FOR lni = 1 TO m.lnFFields
	FOR lnCurCol = 1 TO m.lnColsNo
		IF m.laFields[m.lnCurCol,1] == m.laFFields[m.lni]
			FOR lnj = 1 TO ALEN(laFields,2)
				lcTmp = m.laFields[m.lnCurCol,m.lnj]
				laFields[m.lnCurCol,m.lnj] = m.laFields[m.lni,m.lnj]
				laFields[m.lni,m.lnj] = m.lcTmp
			NEXT
			EXIT
		ENDIF
	NEXT
NEXT

FOR lnCurCol = 1 TO m.lnColsNo
	laFields[m.lnCurCol,5] = IIF(m.lnCurCol<=26,[],CHR(64+FLOOR((m.lnCurCol-1)/26)))+CHR(65+MOD(m.lnCurCol-1,26))
NEXT


SELECT (m.cCur)
COUNT TO m.lnRowsNo
lnTotal = m.lnTotal + m.lnRowsNo * m.lnColChars
lnRowsNo=m.lnRowsNo+IIF(m.llHead,1,0)

cStrings = SYS(2015)
cMax = SYS(2015)
CREATE CURSOR (m.cStrings) &lcCodePage (ii I AUTOINC NEXTVALUE 0,cStr V(m.lnLenStr),cM M)
IF m.llMemoAsComment and m.llMemos
	INSERT INTO (m.cStrings) (cStr) VALUES ("Memo")
ENDIF

IF !EMPTY(m.lcUnion)
	EXECSCRIPT("LPARAMETERS ldDat02,ltDat02"+CHR(13)+"INSERT INTO " + m.cStrings + " (cStr)" + m.lcUnion,m.ldDat02,m.ltDat02)
ENDIF

IF m.lnLenStr > 0
	IF m.lnLenIdx >= m.lnLenStr
		INDEX on cStr TAG cStr
	ELSE
		lcLenIdx = LTRIM(STR(m.lnLenIdx))
		INDEX on LEFT(cStr,&lcLenIdx) TAG cStr
	ENDIF
ENDIF
IF m.llMemos
	lcLenStr = LTRIM(STR(m.lnLenStr))
	INDEX on LEFT(cM,&lcLenStr) TAG cM
ENDIF
SET ORDER TO cStr

lcCurr = Getcurr()

lcOldPath = SYS(5)+SYS(2003)
lcMyPath=''
IF !EMPTY(JUSTPATH(m.lcFileName))
	lcMyPath=ADDBS(JUSTPATH(m.lcFileName)) 
	SET DEFAULT TO (m.lcMyPath)
ELSE
	lcMyPath = ADDBS(JUSTPATH(FULLPATH(m.lcFileName)))
ENDIF

lcDir=gen_dirs(m.llMemoAsComment and m.llMemos)
gen_Content_Types(m.lcDir,m.llMemoAsComment and m.llMemos)
gen_rels(ADDBS(m.lcDir+[_rels]))
gen_app(ADDBS(m.lcDir+[docProps]))
gen_core(ADDBS(m.lcDir+[docProps]))
gen_workbook(ADDBS(ADDBS(m.lcDir+[xl])+[_rels]),m.llMemoAsComment and m.llMemos)
gen_styles(ADDBS(m.lcDir+[xl]),m.lcCurr,m.llMemoAsComment and m.llMemos)
gen_workbook2(ADDBS(m.lcDir+[xl]))
IF m.llMemoAsComment and m.llMemos
	gen_workbook3(ADDBS(ADDBS(ADDBS(m.lcDir+[xl])+[worksheets])+[_rels]))
ENDIF 

* Begin sheet1
lnFHSh = FCREATE(ADDBS(ADDBS(m.lcDir+[xl])+[worksheets])+"sheet1.xml")
IF m.lnFHSh < 0
	MESSAGEBOX(ERRMESS2 + ' sheet1.xml',16,ERRMESS1)
	DO cleanup WITH m.lcDir,m.llMemoAsComment AND m.llMemos,m.llToClose,m.cCur,m.cTotal,m.cMax,m.cStrings,m.lcCurrAlias,m.lnFHSh,m.lnFHStr,m.lnFHCo,m.lnFHDr,m.lcOldPath
	RETURN
ENDIF
FWRITE(m.lnFHSh,[<?xml version="1.0" encoding="UTF-8" standalone="yes"?>]+CHR(10))
FWRITE(m.lnFHSh,[<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" ])
IF m.llMemoAsComment AND m.llMemos
  FWRITE(m.lnFHSh,[xmlns:xdr="http://schemas.openxmlformats.org/drawingml/2006/spreadsheetDrawing" ])
ENDIF
  FWRITE(m.lnFHSh,[xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" mc:Ignorable="x14ac" xmlns:x14ac="http://schemas.microsoft.com/office/spreadsheetml/2009/9/ac"> ])
FWRITE(m.lnFHSh,[<dimension ref="A1:]+IIF(m.lnColsNo>26,CHR(64+FLOOR((m.lnColsNo-1)/26)),[])+CHR(65+MOD(m.lnColsNo-1,26))+TRANSFORM(m.lnRowsNo)+["/>])
*FWRITE(m.lnFHSh,[<sheetViews><sheetView tabSelected="1" workbookViewId="0"/></sheetViews>])
FWRITE(m.lnFHSh,[<sheetViews><sheetView workbookViewId="0"/></sheetViews>])
FWRITE(m.lnFHSh,[<sheetFormatPr defaultRowHeight="15" x14ac:dyDescent="0.25"/>])
FWRITE(m.lnFHSh,[<sheetData>])

IF m.llMemoAsComment AND m.llMemos
* Begin comments1
	lnFHCo = FCREATE(ADDBS(m.lcDir+[xl])+"comments1.xml")
	IF m.lnFHCo < 0
		MESSAGEBOX(ERRMESS2 + ' comments1.xml',16,ERRMESS1)
		DO cleanup WITH m.lcDir,m.llMemoAsComment AND m.llMemos,m.llToClose,m.cCur,m.cTotal,m.cMax,m.cStrings,m.lcCurrAlias,m.lnFHSh,m.lnFHStr,m.lnFHCo,m.lnFHDr,m.lcOldPath
		RETURN
	ENDIF
	FWRITE(m.lnFHCo,[<?xml version="1.0" encoding="UTF-8" standalone="yes"?>]+CHR(10))
	FWRITE(m.lnFHCo,[<comments xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">])
		FWRITE(m.lnFHCo,[<authors>])
			FWRITE(m.lnFHCo,[<author>CopyToXlsx</author>])
		FWRITE(m.lnFHCo,[</authors>])
		FWRITE(m.lnFHCo,[<commentList>])
* Begin vmlDrawing1.vml
	lnFHDr = FCREATE(ADDBS(ADDBS(m.lcDir+[xl])+[drawings])+"vmlDrawing1.vml")
	IF m.lnFHDr < 0
		MESSAGEBOX(ERRMESS2 + ' vmlDrawing1.vml',16,ERRMESS1)
		DO cleanup WITH m.lcDir,m.llMemoAsComment AND m.llMemos,m.llToClose,m.cCur,m.cTotal,m.cMax,m.cStrings,m.lcCurrAlias,m.lnFHSh,m.lnFHStr,m.lnFHCo,m.lnFHDr,m.lcOldPath
		RETURN
	ENDIF
	FWRITE(m.lnFHDr,[<?xml version="1.0"?>]+CHR(10))
	FWRITE(m.lnFHDr,[<xml xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:v="urn:schemas-microsoft-com:vml">])
		FWRITE(m.lnFHDr,[<o:shapelayout v:ext="edit">])
			FWRITE(m.lnFHDr,[<o:idmap v:ext="edit" data="1"/>])
		FWRITE(m.lnFHDr,[</o:shapelayout>])
		FWRITE(m.lnFHDr,[<v:shapetype path="m,l,21600r21600,l21600,xe" o:spt="202" coordsize="21600,21600" id="_x0000_t202">])
			FWRITE(m.lnFHDr,[<v:stroke joinstyle="miter"/>])
			FWRITE(m.lnFHDr,[<v:path o:connecttype="rect" gradientshapeok="t"/>])
		FWRITE(m.lnFHDr,[</v:shapetype>])
ENDIF

* Begin sharedStrings
lnFHStr = FCREATE(ADDBS(m.lcDir+[xl])+"sharedStrings.xml")
IF m.lnFHStr < 0
	MESSAGEBOX(ERRMESS2 + ' sharedStrings.xml',16,ERRMESS1)
	DO cleanup WITH m.lcDir,m.llMemoAsComment AND m.llMemos,m.llToClose,m.cCur,m.cTotal,m.cMax,m.cStrings,m.lcCurrAlias,m.lnFHSh,m.lnFHStr,m.lnFHCo,m.lnFHDr,m.lcOldPath
	RETURN
ENDIF
FWRITE(m.lnFHStr,[<?xml version="1.0" encoding="UTF-8" standalone="yes"?>]+CHR(10))
FWRITE(m.lnFHStr,[<sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" count="]+SPACE(40)) 

SELECT (m.cStrings)
SET ORDER TO 
SCAN NOOPTIMIZE
	FWRITE(m.lnFHStr,[<si><t>]+htmspec(cStr,m.lcStrBad)+[</t></si>])
ENDSCAN
SET ORDER TO cStr

lnCurRow = 0
IF m.llHead
	lnCurRow = m.lnCurRow + 1
	lcCurRow = LTRIM(STR(m.lnCurRow))
	FWRITE(m.lnFHSh,[<row r="]+m.lcCurRow+[" spans="1:1" x14ac:dyDescent="0.25">])
	FOR lnCurCol = 1 TO m.lnColsNo
		FWRITE(m.lnFHSh,[<c r="]+IIF(m.lnCurCol>26,CHR(64+FLOOR((m.lnCurCol-1)/26)),[])+CHR(65+MOD(m.lnCurCol-1,26))+m.lcCurRow)
		lcValue = m.laFields[m.lnCurCol,1]
		SELECT (m.cStrings)
		IF m.lnLenIdx >= m.lnLenStr
			SET KEY TO m.lcValue
		ELSE
			SET KEY TO LEFT(m.lcValue,m.lnLenIdx)
		ENDIF
		lnII = 0
		SCAN
			IF cStr == m.lcValue
				lnII = ii
				EXIT
			ENDIF
		ENDSCAN
		SET KEY TO
		IF m.lnII > 0
			FWRITE(m.lnFHSh,[" t="s"><v>]+LTRIM(STR(m.lnII))+[</v></c>])
		ELSE
			FWRITE(m.lnFHStr,[<si><t>]+htmspec(m.lcValue,m.lcStrBad)+[</t></si>])
			INSERT INTO (m.cStrings) (cStr) VALUES (m.lcValue)
			SELECT MAX(ii) as ii FROM (m.cStrings) INTO CURSOR (m.cMax)
			SELECT (m.cMax)
			lnII = ii
			FWRITE(m.lnFHSh,[" t="s"><v>]+LTRIM(STR(m.lnII))+[</v></c>])
		ENDIF
	NEXT
	FWRITE(m.lnFHSh,[</row>]+CHR(10))
ENDIF

lcSetDec = SET("Decimals")
SET DECIMALS TO 13
IF m.llMemoAsComment AND m.llMemos
	lnCurComm = 0
ENDIF
SELECT (m.cCur)
DO CASE
CASE m.llMemos AND m.lnLenIdx < m.lnLenStr
	SCAN 
		lnCurRow = m.lnCurRow + 1
		lcCurRow = LTRIM(STR(m.lnCurRow))
		FWRITE(m.lnFHSh,[<row r="]+m.lcCurRow+[" spans="1:1" x14ac:dyDescent="0.25">])
		SCATTER MEMO TO lala
		FOR lnCurCol = 1 TO m.lnColsNo
			SET ORDER TO cStr IN (m.cStrings)
			lcValue = lala[m.laFields[m.lnCurCol,6]]
			IF ISNULL(m.lcValue)
				LOOP
			ENDIF
			lnType = m.laFields[m.lnCurCol,2]
			lnDec = m.laFields[m.lnCurCol,4]
			FWRITE(m.lnFHSh,[<c r="]+m.laFields[m.lnCurCol,5]+m.lcCurRow)
			IF m.lnType == 1
				lcValue = RTRIM(m.lcValue)
				IF EMPTY(m.lcValue)
					FWRITE(m.lnFHSh,[" t="s"></c>]) && Empty cell
				ELSE
					SELECT (m.cStrings)
					SET KEY TO LEFT(m.lcValue,m.lnLenIdx)
					SCAN
						IF cStr == m.lcValue
							EXIT
						ENDIF
					ENDSCAN
					SET KEY TO
					FWRITE(m.lnFHSh,[" t="s"><v>]+LTRIM(STR(II))+[</v></c>])
				ENDIF
				SELECT (m.cCur)
			ELSE
			IF m.lnType == 2
				FWRITE(m.lnFHSh,["><v>]+LTRIM(STR(m.lcValue,m.laFields[m.lnCurCol,3],m.lnDec))+[</v></c>])
			ELSE
			IF m.lnType == 3
				FWRITE(m.lnFHSh,["><v>]+LTRIM(STR(m.lcValue))+[</v></c>])
			ELSE
			IF m.lnType == 4
				IF EMPTY(m.lcValue)
					FWRITE(m.lnFHSh,["></c>]) && Empty cell
				ELSE
				IF m.lcValue >= m.ldDat01
					FWRITE(m.lnFHSh,[" s="1"><v>]+LTRIM(STR(m.lcValue - m.ldDat11))+[</v></c>])
				ELSE
				IF BETWEEN(m.lcValue,m.ldDat02,m.ldDat03)
					FWRITE(m.lnFHSh,[" s="1"><v>]+LTRIM(STR(m.lcValue - m.ldDat12))+[</v></c>])
				ELSE
					lcValue = DTOC(m.lcValue)
					SELECT (m.cStrings)
					SET KEY TO LEFT(m.lcValue,m.lnLenIdx)
					SCAN
						IF cStr == m.lcValue
							EXIT 
						ENDIF
					ENDSCAN
					SET KEY TO
					FWRITE(m.lnFHSh,[" t="s"><v>]+LTRIM(STR(II))+[</v></c>])
					SELECT (m.cCur)
				ENDIF
				ENDIF
				ENDIF
			ELSE
			IF m.lnType == 5
				IF EMPTY(m.lcValue)
					FWRITE(m.lnFHSh,["></c>]) && Empty cell
				ELSE
					ltTime = m.lcValue 
					ldValue = TTOD(m.lcValue)
					lnTime = (m.ltTime-DATETIME(YEAR(m.ltTime),MONTH(m.ltTime),DAY(m.ltTime),0,0,0))/(86400.0)
				IF m.ldValue >= m.ldDat01
					FWRITE(m.lnFHSh,[" s="2"><v>]+LTRIM(STR(m.ldValue - m.ldDat11))+SUBSTR(TRANSFORM(m.lnTime),2,14)+[</v></c>])
				ELSE
				IF BETWEEN(m.ldValue,m.ldDat02,m.ldDat03)
					FWRITE(m.lnFHSh,[" s="2"><v>]+LTRIM(STR(m.ldValue - m.ldDat12))+SUBSTR(TRANSFORM(m.lnTime),2,14)+[</v></c>])
				ELSE
					lcValue = TTOC(m.lcValue)
					SELECT (m.cStrings)
					SET KEY TO LEFT(m.lcValue,m.lnLenIdx)
					SCAN
						IF cStr == m.lcValue
							EXIT
						ENDIF
					ENDSCAN
					SET KEY TO
					FWRITE(m.lnFHSh,[" t="s"><v>]+LTRIM(STR(II))+[</v></c>])
					SELECT (m.cCur)
				ENDIF
				ENDIF
				ENDIF
			ELSE
			IF m.lnType == 6
				FWRITE(m.lnFHSh,[" t="b"><v>]+IIF(m.lcValue ,[1],[0])+[</v></c>])
			ELSE
			IF m.lnType == 7
				FWRITE(m.lnFHSh,[" s="4"><v>]+LTRIM(STR(m.lcValue,21,4))+[</v></c>])
			ELSE
			IF m.lnType == 8
				FWRITE(m.lnFHSh,["><v>]+LTRIM(STR(m.lcValue,21,m.lnDec))+[</v></c>])
			ELSE
			IF m.lnType == 9
				lcValue = RTRIM(m.lcValue)
				IF m.llMemoAsComment
					lnCurComm = m.lnCurComm + 1
					IF EMPTY(m.lcValue)
						FWRITE(m.lnFHSh,[" t="s"></c>]) && Empty cell
					ELSE
						FWRITE(m.lnFHSh,IIF(m.llCR,[" s="3],[])+[" t="s"><v>0</v></c>]) && Type "Memo" in sheet1
						FWRITE(m.lnFHCo,[<comment authorId="0" ref="] + m.laFields[m.lnCurCol,5]+m.lcCurRow + [">]) && comments1
							FWRITE(m.lnFHCo,[<text>])
								FWRITE(m.lnFHCo,[<r>])
									FWRITE(m.lnFHCo,[<rPr>])
										FWRITE(m.lnFHCo,[<sz val="9"/>])
										FWRITE(m.lnFHCo,[<color indexed="81"/>])
										FWRITE(m.lnFHCo,[<rFont val="Tahoma"/>])
										FWRITE(m.lnFHCo,[<family val="2"/>])
										FWRITE(m.lnFHCo,[<charset val="238"/>])
									FWRITE(m.lnFHCo,[</rPr>])
									FWRITE(m.lnFHCo,[<t>] + m.lcValue + [</t>])
								FWRITE(m.lnFHCo,[</r>])
							FWRITE(m.lnFHCo,[</text>])
						FWRITE(m.lnFHCo,[</comment>])
						
						
						FWRITE(m.lnFHDr,[<v:shape id="_x] + PADL(LTRIM(STR(m.lnCurComm)),10,"0") + [" o:insetmode="auto" fillcolor="#ffffe1" style="position:absolute; margin-left:] + ;
								LTRIM(STR(59.25 + 48 * (m.lnCurCol - 1))) + [pt;margin-top:] + LTRIM(STR(1.5 + 15 * (m.lnCurRow - 1))) + [pt;width:108pt;height:59.25pt;z-index:] + ; &&[pt;width:108pt;height:59.25pt;z-index:] + 
								LTRIM(STR(m.lnCurComm)) + [; visibility:hidden" type="#_x0000_t202">])
							FWRITE(m.lnFHDr,[<v:fill color2="#ffffe1"/>])
							FWRITE(m.lnFHDr,[<v:shadow obscured="t" color="black" on="t"/>])
							FWRITE(m.lnFHDr,[<v:path o:connecttype="none"/>])
							FWRITE(m.lnFHDr,[<v:textbox style="mso-direction-alt:auto">])
								FWRITE(m.lnFHDr,[<div style="text-align:left"/>])
							FWRITE(m.lnFHDr,[</v:textbox>])
							FWRITE(m.lnFHDr,[<x:ClientData ObjectType="Note">])
								FWRITE(m.lnFHDr,[<x:MoveWithCells/>])
								FWRITE(m.lnFHDr,[<x:SizeWithCells/>])
								
								
								lnNoRow = ALINES(laNoRow,m.lcValue) 
								lnMaxLenRow = LEN(m.laNoRow[1])
								FOR lniNoRow = 2 TO m.lnNoRow
									IF m.lnMaxLenRow < LEN(m.laNoRow[m.lniNoRow])
										m.lnMaxLenRow = LEN(m.laNoRow[m.lniNoRow])
									ENDIF
								NEXT
								lnCommH = MAX(3,MIN(m.lnNoRow - 2, MAXIMUMCOMMENTHEIGHT))
								lnCommW  = MAX(2, MIN(CEILING(m.lnMaxLenRow / 5), MAXIMUMCOMMENTWIDTH))
								FWRITE(m.lnFHDr,[<x:Anchor> ] + LTRIM(STR(m.lnCurCol)) + [, 15, ] + LTRIM(STR(m.lnCurRow - 1)) + [, 2, ] + LTRIM(STR(m.lnCurCol + m.lnCommW)) + [, 31, ] + LTRIM(STR(m.lnCurRow + m.lnCommH)) + [, 1</x:Anchor>])

*								FWRITE(m.lnFHDr,[<x:Anchor> ] + LTRIM(STR(m.lnCurCol)) + [, 15, ] + LTRIM(STR(m.lnCurRow - 1)) + [, 2, ] + LTRIM(STR(m.lnCurCol + 2)) + [, 31, ] + LTRIM(STR(m.lnCurRow + 3)) + [, 1</x:Anchor>])
								FWRITE(m.lnFHDr,[<x:AutoFill>False</x:AutoFill>])
								FWRITE(m.lnFHDr,[<x:Row>] + LTRIM(STR(m.lnCurRow - 1)) + [</x:Row>])
								FWRITE(m.lnFHDr,[<x:Column>] + LTRIM(STR(m.lnCurCol - 1)) + [</x:Column>])
							FWRITE(m.lnFHDr,[</x:ClientData>])
						FWRITE(m.lnFHDr,[</v:shape>])
					ENDIF
				ELSE
					IF EMPTY(m.lcValue)
						FWRITE(m.lnFHSh,[" t="s"></c>]) && Empty cell
					ELSE
						llCR=AT(CHR(13),m.lcValue)>0 or AT(CHR(10),m.lcValue)>0
						SELECT (m.cStrings)
						SET ORDER TO cM
						SET KEY TO LEFT(m.lcValue,m.lnLenIdx)
						lnII = 0
						SCAN
							IF cM == m.lcValue
								lnII = ii
								EXIT
							ENDIF
						ENDSCAN
						SET KEY TO
						IF lnII > 0
							FWRITE(m.lnFHSh,IIF(m.llCR,[" s="3],[])+[" t="s"><v>]+LTRIM(STR(m.lnII))+[</v></c>])
						ELSE
							FWRITE(m.lnFHStr,[<si><t>]+htmspec(m.lcValue,m.lcStrBad)+[</t></si>])
							INSERT INTO (m.cStrings) (cM) VALUES (m.lcValue)
							SELECT MAX(ii) as ii FROM (m.cStrings) INTO CURSOR (m.cMax)
							SELECT (m.cMax)
							lnII = ii
							FWRITE(m.lnFHSh,IIF(m.llCR,[" s="3],[])+[" t="s"><v>]+LTRIM(STR(m.lnII))+[</v></c>])
						ENDIF
					ENDIF
				ENDIF
				SELECT (m.cCur)
			ENDIF
			ENDIF
			ENDIF
			ENDIF
			ENDIF
			ENDIF
			ENDIF
			ENDIF
			ENDIF
		NEXT
		FWRITE(m.lnFHSh,[</row>]+CHR(10))
	ENDSCAN
CASE m.llMemos AND m.lnLenIdx >= m.lnLenStr
	SCAN
		lnCurRow = m.lnCurRow + 1
		lcCurRow = LTRIM(STR(m.lnCurRow))
		FWRITE(m.lnFHSh,[<row r="]+m.lcCurRow+[" spans="1:1" x14ac:dyDescent="0.25">])
		SCATTER MEMO TO lala
		FOR lnCurCol = 1 TO m.lnColsNo
			SET ORDER TO cStr IN (m.cStrings)
			lcValue = lala[m.laFields[m.lnCurCol,6]]
			IF ISNULL(m.lcValue)
				LOOP
			ENDIF
			lnType = m.laFields[m.lnCurCol,2]
			lnDec = m.laFields[m.lnCurCol,4]
			FWRITE(m.lnFHSh,[<c r="]+m.laFields[m.lnCurCol,5]+m.lcCurRow)
			IF m.lnType = 1
				lcValue = RTRIM(m.lcValue)
				IF EMPTY(m.lcValue)
					FWRITE(m.lnFHSh,[" t="s"></c>]) && Empty cell
				ELSE
					SELECT (m.cStrings)
					SEEK m.lcValue
					FWRITE(m.lnFHSh,[" t="s"><v>]+LTRIM(STR(II))+[</v></c>])
				ENDIF
				SELECT (m.cCur)
			ELSE
			IF m.lnType = 2
				FWRITE(m.lnFHSh,["><v>]+LTRIM(STR(m.lcValue,m.laFields[m.lnCurCol,3],m.lnDec))+[</v></c>])
			ELSE 
			IF m.lnType = 3
				FWRITE(m.lnFHSh,["><v>]+LTRIM(STR(m.lcValue))+[</v></c>])
			ELSE 
			IF m.lnType = 4
				IF EMPTY(m.lcValue)
					FWRITE(m.lnFHSh,["></c>]) && Empty cell
				ELSE
				IF m.lcValue >= m.ldDat01
					FWRITE(m.lnFHSh,[" s="1"><v>]+LTRIM(STR(m.lcValue - m.ldDat11))+[</v></c>])
				ELSE
				IF BETWEEN(m.lcValue,m.ldDat02,m.ldDat03)
					FWRITE(m.lnFHSh,[" s="1"><v>]+LTRIM(STR(m.lcValue - m.ldDat12))+[</v></c>])
				ELSE
					lcValue = DTOC(m.lcValue)
					SELECT (m.cStrings)
					SEEK m.lcValue
					FWRITE(m.lnFHSh,[" t="s"><v>]+LTRIM(STR(II))+[</v></c>])
					SELECT (m.cCur)
				ENDIF
				ENDIF
				ENDIF
			ELSE 
			IF m.lnType = 5
				IF EMPTY(m.lcValue)
					FWRITE(m.lnFHSh,["></c>]) && Empty cell
				ELSE
					ltTime = m.lcValue 
					ldValue = TTOD(m.lcValue)
					lnTime = (m.ltTime-DATETIME(YEAR(m.ltTime),MONTH(m.ltTime),DAY(m.ltTime),0,0,0))/(86400.0)
				IF m.ldValue >= m.ldDat01
					FWRITE(m.lnFHSh,[" s="2"><v>]+LTRIM(STR(m.ldValue - m.ldDat11))+SUBSTR(TRANSFORM(m.lnTime),2,14)+[</v></c>])
				ELSE
				IF BETWEEN(m.ldValue,m.ldDat02,m.ldDat03)
					FWRITE(m.lnFHSh,[" s="2"><v>]+LTRIM(STR(m.ldValue - m.ldDat12))+SUBSTR(TRANSFORM(m.lnTime),2,14)+[</v></c>])
				ELSE
					lcValue = TTOC(m.lcValue)
					SELECT (m.cStrings)
					SEEK m.lcValue
					FWRITE(m.lnFHSh,[" t="s"><v>]+LTRIM(STR(II))+[</v></c>])
					SELECT (m.cCur)
				ENDIF
				ENDIF
				ENDIF
			ELSE 
			IF m.lnType = 6
				FWRITE(m.lnFHSh,[" t="b"><v>]+IIF(m.lcValue ,[1],[0])+[</v></c>])
			ELSE 
			IF m.lnType = 7
				FWRITE(m.lnFHSh,[" s="4"><v>]+LTRIM(STR(m.lcValue,21,4))+[</v></c>])
			ELSE 
			IF m.lnType = 8
				FWRITE(m.lnFHSh,["><v>]+LTRIM(STR(m.lcValue,21,m.lnDec))+[</v></c>])
			ELSE
			IF m.lnType = 9
				lcValue = RTRIM(m.lcValue)
				IF m.llMemoAsComment
					lnCurComm = m.lnCurComm + 1
					IF EMPTY(m.lcValue)
						FWRITE(m.lnFHSh,[" t="s"></c>]) && Empty cell
					ELSE
						FWRITE(m.lnFHSh,IIF(m.llCR,[" s="3],[])+[" t="s"><v>0</v></c>]) && Tyoe "Memo" in sheet1
						FWRITE(m.lnFHCo,[<comment authorId="0" ref="] + m.laFields[m.lnCurCol,5]+m.lcCurRow + [">]) && comments1
							FWRITE(m.lnFHCo,[<text>])
								FWRITE(m.lnFHCo,[<r>])
									FWRITE(m.lnFHCo,[<rPr>])
										FWRITE(m.lnFHCo,[<sz val="9"/>])
										FWRITE(m.lnFHCo,[<color indexed="81"/>])
										FWRITE(m.lnFHCo,[<rFont val="Tahoma"/>])
										FWRITE(m.lnFHCo,[<family val="2"/>])
										FWRITE(m.lnFHCo,[<charset val="238"/>])
									FWRITE(m.lnFHCo,[</rPr>])
									FWRITE(m.lnFHCo,[<t>] + m.lcValue + [</t>])
								FWRITE(m.lnFHCo,[</r>])
							FWRITE(m.lnFHCo,[</text>])
						FWRITE(m.lnFHCo,[</comment>])
						
						
						FWRITE(m.lnFHDr,[<v:shape id="_x] + PADL(LTRIM(STR(m.lnCurComm)),10,"0") + [" o:insetmode="auto" fillcolor="#ffffe1" style="position:absolute; margin-left:] + ;
								LTRIM(STR(59.25 + 48 * (m.lnCurCol - 1))) + [pt;margin-top:] + LTRIM(STR(1.5 + 15 * (m.lnCurRow - 1))) + [pt;width:108pt;height:59.25pt;z-index:] + ; && [pt;width:108pt;height:59.25pt;z-index:] + 
								LTRIM(STR(m.lnCurComm)) + [; visibility:hidden" type="#_x0000_t202">])
							FWRITE(m.lnFHDr,[<v:fill color2="#ffffe1"/>])
							FWRITE(m.lnFHDr,[<v:shadow obscured="t" color="black" on="t"/>])
							FWRITE(m.lnFHDr,[<v:path o:connecttype="none"/>])
							FWRITE(m.lnFHDr,[<v:textbox style="mso-direction-alt:auto">])
								FWRITE(m.lnFHDr,[<div style="text-align:left"/>])
							FWRITE(m.lnFHDr,[</v:textbox>])
							FWRITE(m.lnFHDr,[<x:ClientData ObjectType="Note">])
								FWRITE(m.lnFHDr,[<x:MoveWithCells/>])
								FWRITE(m.lnFHDr,[<x:SizeWithCells/>])
								
								lnNoRow = ALINES(laNoRow,m.lcValue) 
								lnMaxLenRow = LEN(m.laNoRow[1])
								FOR lniNoRow = 2 TO m.lnNoRow
									IF m.lnMaxLenRow < LEN(m.laNoRow[m.lniNoRow])
										m.lnMaxLenRow = LEN(m.laNoRow[m.lniNoRow])
									ENDIF
								NEXT
								lnCommH = MAX(3,MIN(m.lnNoRow - 2, MAXIMUMCOMMENTHEIGHT))
								lnCommW  = MAX(2, MIN(CEILING(m.lnMaxLenRow / 5), MAXIMUMCOMMENTWIDTH))
								FWRITE(m.lnFHDr,[<x:Anchor> ] + LTRIM(STR(m.lnCurCol)) + [, 15, ] + LTRIM(STR(m.lnCurRow - 1)) + [, 2, ] + LTRIM(STR(m.lnCurCol + m.lnCommW)) + [, 31, ] + LTRIM(STR(m.lnCurRow + m.lnCommH)) + [, 1</x:Anchor>])

*								FWRITE(m.lnFHDr,[<x:Anchor> ] + LTRIM(STR(m.lnCurCol)) + [, 15, ] + LTRIM(STR(m.lnCurRow - 1)) + [, 2, ] + LTRIM(STR(m.lnCurCol + 2)) + [, 31, ] + LTRIM(STR(m.lnCurRow + 3)) + [, 1</x:Anchor>])
								FWRITE(m.lnFHDr,[<x:AutoFill>False</x:AutoFill>])
								FWRITE(m.lnFHDr,[<x:Row>] + LTRIM(STR(m.lnCurRow - 1)) + [</x:Row>])
								FWRITE(m.lnFHDr,[<x:Column>] + LTRIM(STR(m.lnCurCol - 1)) + [</x:Column>])
							FWRITE(m.lnFHDr,[</x:ClientData>])
						FWRITE(m.lnFHDr,[</v:shape>])
					ENDIF
				ELSE
					IF EMPTY(m.lcValue)
						FWRITE(m.lnFHSh,[" t="s"></c>]) && Empty cell
					ELSE
						llCR=AT(CHR(13),m.lcValue)>0 or AT(CHR(10),m.lcValue)>0
						SELECT (m.cStrings)
						SET ORDER TO cM
						SET KEY TO LEFT(m.lcValue,m.lnLenIdx)
						lnII = 0
						SCAN
							IF cM == m.lcValue
								lnII = ii
								EXIT
							ENDIF
						ENDSCAN
						SET KEY TO
						IF lnII > 0
							FWRITE(m.lnFHSh,IIF(m.llCR,[" s="3],[])+[" t="s"><v>]+LTRIM(STR(m.lnII))+[</v></c>])
						ELSE
							FWRITE(m.lnFHStr,[<si><t>]+htmspec(m.lcValue,m.lcStrBad)+[</t></si>])
							INSERT INTO (m.cStrings) (cM) VALUES (m.lcValue)
							SELECT MAX(ii) as ii FROM (m.cStrings) INTO CURSOR (m.cMax)
							SELECT (m.cMax)
							lnII = ii
							FWRITE(m.lnFHSh,IIF(m.llCR,[" s="3],[])+[" t="s"><v>]+LTRIM(STR(m.lnII))+[</v></c>])
						ENDIF
					ENDIF
				ENDIF
				SELECT (m.cCur)
			ENDIF
			ENDIF
			ENDIF
			ENDIF
			ENDIF
			ENDIF
			ENDIF
			ENDIF
			ENDIF
		NEXT
		FWRITE(m.lnFHSh,[</row>]+CHR(10))
	ENDSCAN
CASE !m.llMemos AND m.lnLenIdx < m.lnLenStr
	SET ORDER TO cStr IN (m.cStrings)
	SCAN 
		lnCurRow = m.lnCurRow + 1
		lcCurRow = LTRIM(STR(m.lnCurRow))
		FWRITE(m.lnFHSh,[<row r="]+m.lcCurRow+[" spans="1:1" x14ac:dyDescent="0.25">])
		SCATTER TO lala
		FOR lnCurCol = 1 TO m.lnColsNo
			lcValue = lala[m.laFields[m.lnCurCol,6]]
			IF ISNULL(m.lcValue)
				LOOP
			ENDIF
			lnType = m.laFields[m.lnCurCol,2]
			lnDec = m.laFields[m.lnCurCol,4]
			FWRITE(m.lnFHSh,[<c r="]+m.laFields[m.lnCurCol,5]+m.lcCurRow)
			IF m.lnType = 1
				lcValue = RTRIM(m.lcValue)
				IF EMPTY(m.lcValue)
					FWRITE(m.lnFHSh,[" t="s"></c>]) && Empty cell
				ELSE
					SELECT (m.cStrings)
					SET KEY TO LEFT(m.lcValue,m.lnLenIdx)
					SCAN
						IF cStr == m.lcValue
							EXIT
						ENDIF
					ENDSCAN
					SET KEY TO
					FWRITE(m.lnFHSh,[" t="s"><v>]+LTRIM(STR(II))+[</v></c>])
				ENDIF
				SELECT (m.cCur)
			ELSE
			IF m.lnType = 2
				FWRITE(m.lnFHSh,["><v>]+LTRIM(STR(m.lcValue,m.laFields[m.lnCurCol,3],m.lnDec))+[</v></c>])
			ELSE
			IF m.lnType = 3
				FWRITE(m.lnFHSh,["><v>]+LTRIM(STR(m.lcValue))+[</v></c>])
			ELSE
			IF m.lnType = 4
				IF EMPTY(m.lcValue)
					FWRITE(m.lnFHSh,["></c>]) && Empty cell
				ELSE
				IF m.lcValue >= m.ldDat01
					FWRITE(m.lnFHSh,[" s="1"><v>]+LTRIM(STR(m.lcValue - m.ldDat11))+[</v></c>])
				ELSE
				IF BETWEEN(m.lcValue,m.ldDat02,m.ldDat03)
					FWRITE(m.lnFHSh,[" s="1"><v>]+LTRIM(STR(m.lcValue - m.ldDat12))+[</v></c>])
				ELSE
					lcValue = DTOC(m.lcValue)
					SELECT (m.cStrings)
					SET KEY TO LEFT(m.lcValue,m.lnLenIdx)
					SCAN
						IF cStr == m.lcValue
							EXIT 
						ENDIF
					ENDSCAN
					SET KEY TO
					FWRITE(m.lnFHSh,[" t="s"><v>]+LTRIM(STR(II))+[</v></c>])
					SELECT (m.cCur)
				ENDIF
				ENDIF
				ENDIF
			ELSE
			IF m.lnType = 5
				IF EMPTY(m.lcValue)
					FWRITE(m.lnFHSh,["></c>]) && Empty cell
				ELSE
					ltTime = m.lcValue 
					ldValue = TTOD(m.lcValue)
					lnTime = (m.ltTime-DATETIME(YEAR(m.ltTime),MONTH(m.ltTime),DAY(m.ltTime),0,0,0))/(86400.0)
				IF m.ldValue >= m.ldDat01
					FWRITE(m.lnFHSh,[" s="2"><v>]+LTRIM(STR(m.ldValue - m.ldDat11))+SUBSTR(TRANSFORM(m.lnTime),2,14)+[</v></c>])
				ELSE
				IF BETWEEN(m.ldValue,m.ldDat02,m.ldDat03)
					FWRITE(m.lnFHSh,[" s="2"><v>]+LTRIM(STR(m.ldValue - m.ldDat12))+SUBSTR(TRANSFORM(m.lnTime),2,14)+[</v></c>])
				ELSE
					lcValue = TTOC(m.lcValue)
					SELECT (m.cStrings)
					SET KEY TO LEFT(m.lcValue,m.lnLenIdx)
					SCAN
						IF cStr == m.lcValue
							EXIT
						ENDIF
					ENDSCAN
					SET KEY TO
					FWRITE(m.lnFHSh,[" t="s"><v>]+LTRIM(STR(II))+[</v></c>])
					SELECT (m.cCur)
				ENDIF
				ENDIF
				ENDIF
			ELSE
			IF m.lnType = 6
				FWRITE(m.lnFHSh,[" t="b"><v>]+IIF(m.lcValue ,[1],[0])+[</v></c>])
			ELSE
			IF m.lnType = 7
				FWRITE(m.lnFHSh,[" s="4"><v>]+LTRIM(STR(m.lcValue,21,4))+[</v></c>])
			ELSE
			IF m.lnType = 8
				FWRITE(m.lnFHSh,["><v>]+LTRIM(STR(m.lcValue,21,m.lnDec))+[</v></c>])
			ENDIF
			ENDIF
			ENDIF
			ENDIF
			ENDIF
			ENDIF
			ENDIF
			ENDIF
		NEXT
		FWRITE(m.lnFHSh,[</row>]+CHR(10))
	ENDSCAN
CASE !m.llMemos AND m.lnLenIdx >= m.lnLenStr
	SET ORDER TO cStr IN (m.cStrings)
	SCAN 
		lnCurRow = m.lnCurRow + 1
		lcCurRow = LTRIM(STR(m.lnCurRow))
		FWRITE(m.lnFHSh,[<row r="]+m.lcCurRow+[" spans="1:1" x14ac:dyDescent="0.25">])
		SCATTER TO lala
		FOR lnCurCol = 1 TO m.lnColsNo
			lcValue = lala[m.laFields[m.lnCurCol,6]]
			IF ISNULL(m.lcValue)
				LOOP
			ENDIF
			lnType = m.laFields[m.lnCurCol,2]
			lnDec = m.laFields[m.lnCurCol,4]
			FWRITE(m.lnFHSh,[<c r="]+m.laFields[m.lnCurCol,5]+m.lcCurRow)
			IF m.lnType = 1
				lcValue = RTRIM(m.lcValue)
				IF EMPTY(m.lcValue)
					FWRITE(m.lnFHSh,[" t="s"></c>]) && Empty cell
				ELSE
					SELECT (m.cStrings)
					SEEK m.lcValue
					FWRITE(m.lnFHSh,[" t="s"><v>]+LTRIM(STR(II))+[</v></c>])
				ENDIF
				SELECT (m.cCur)
			ELSE
			IF m.lnType = 2
				FWRITE(m.lnFHSh,["><v>]+LTRIM(STR(m.lcValue,m.laFields[m.lnCurCol,3],m.lnDec))+[</v></c>])
			ELSE
			IF m.lnType = 3
				FWRITE(m.lnFHSh,["><v>]+LTRIM(STR(m.lcValue))+[</v></c>])
			ELSE
			IF m.lnType = 4
				IF EMPTY(m.lcValue)
					FWRITE(m.lnFHSh,["></c>]) && Empty cell
				ELSE
				IF m.lcValue >= m.ldDat01
					FWRITE(m.lnFHSh,[" s="1"><v>]+LTRIM(STR(m.lcValue - m.ldDat11))+[</v></c>])
				ELSE
				IF BETWEEN(m.lcValue,m.ldDat02,m.ldDat03)
					FWRITE(m.lnFHSh,[" s="1"><v>]+LTRIM(STR(m.lcValue - m.ldDat12))+[</v></c>])
				ELSE
					lcValue = DTOC(m.lcValue)
					SELECT (m.cStrings)
					SEEK m.lcValue
					FWRITE(m.lnFHSh,[" t="s"><v>]+LTRIM(STR(II))+[</v></c>])
					SELECT (m.cCur)
				ENDIF
				ENDIF
				ENDIF
			ELSE
			IF m.lnType = 5
				IF EMPTY(m.lcValue)
					FWRITE(m.lnFHSh,["></c>]) && Empty cell
				ELSE
					ltTime = m.lcValue 
					ldValue = TTOD(m.lcValue)
					lnTime = (m.ltTime-DATETIME(YEAR(m.ltTime),MONTH(m.ltTime),DAY(m.ltTime),0,0,0))/(86400.0)
				IF m.ldValue >= m.ldDat01
					FWRITE(m.lnFHSh,[" s="2"><v>]+LTRIM(STR(m.ldValue - m.ldDat11))+SUBSTR(TRANSFORM(m.lnTime),2,14)+[</v></c>])
				ELSE
				IF BETWEEN(m.ldValue,m.ldDat02,m.ldDat03)
					FWRITE(m.lnFHSh,[" s="2"><v>]+LTRIM(STR(m.ldValue - m.ldDat12))+SUBSTR(TRANSFORM(m.lnTime),2,14)+[</v></c>])
				ELSE
					lcValue = TTOC(m.lcValue)
					SELECT (m.cStrings)
					SEEK m.lcValue
					FWRITE(m.lnFHSh,[" t="s"><v>]+LTRIM(STR(II))+[</v></c>])
					SELECT (m.cCur)
				ENDIF
				ENDIF
				ENDIF
			ELSE
			IF m.lnType = 6
				FWRITE(m.lnFHSh,[" t="b"><v>]+IIF(m.lcValue ,[1],[0])+[</v></c>])
			ELSE
			IF m.lnType = 7
				FWRITE(m.lnFHSh,[" s="4"><v>]+LTRIM(STR(m.lcValue,21,4))+[</v></c>])
			ELSE
			IF m.lnType = 8
				FWRITE(m.lnFHSh,["><v>]+LTRIM(STR(m.lcValue,21,m.lnDec))+[</v></c>])
			ENDIF
			ENDIF
			ENDIF
			ENDIF
			ENDIF
			ENDIF
			ENDIF
			ENDIF
		NEXT
		FWRITE(m.lnFHSh,[</row>]+CHR(10))
	ENDSCAN
ENDCASE

SET DECIMALS TO &lcSetDec 

* End sheet1
FWRITE(m.lnFHSh,[</sheetData>])
FWRITE(m.lnFHSh,[<pageMargins left="0.7" right="0.7" top="0.75" bottom="0.75" header="0.3" footer="0.3"/>])
IF m.llMemoAsComment AND m.llMemos
	FWRITE(m.lnFHSh,[<legacyDrawing r:id="rId6"/>])
ENDIF
FWRITE(m.lnFHSh,[</worksheet>])
FCLOSE(m.lnFHSh)

* End sharedStrings
FWRITE(m.lnFHStr,[</sst>])
FSEEK(m.lnFHStr,55+1+LEN([<sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" count="]))
FWRITE(m.lnFHStr,LTRIM(STR(m.lnTotal))+[" uniqueCount="]+LTRIM(STR(RECCOUNT(m.cStrings)))+[">])
FCLOSE(m.lnFHStr)

IF m.llMemoAsComment AND m.llMemos
* End comment1
	FWRITE(m.lnFHCo,[</commentList>])
	FWRITE(m.lnFHCo,[</comments>])
	FCLOSE(m.lnFHCo)
* End comment1
	FWRITE(m.lnFHDr,[</xml>])
	FCLOSE(m.lnFHDr)
ENDIF

*****

lcSource = m.lcMyPath + m.lcDir &&"<< fully qualified path name to some folder >>"
lcZipFileName = m.lcMyPath + FORCEEXT(JUSTFNAME(m.lcFileName),'zip') &&"<< fully qualified path name to some zip file >>"

TRY
	IF FILE(m.lcZipFileName)
		ERASE (m.lcZipFileName)
	ENDIF
CATCH TO m.loerr
ENDTRY

TRY
	IF FILE(m.lcFileName)
		ERASE (m.lcFileName)
	ENDIF
CATCH TO m.loerr
ENDTRY

STRTOFILE(CHR( 80 )+CHR( 75 )+CHR( 5 )+CHR( 6 )+REPLICATE( CHR(0), 18 ), m.lcZipFileName)
oShell = CREATEOBJECT("shell.application")
oFolder = m.oShell.NameSpace( m.lcSource ).items

llBelow7 = OS(3)<'6' OR OS(3)='6' AND OS(4)<'1'
IF m.llBelow7 && Win XP
	TRY
		FOR EACH ofile IN m.oFolder
			lnCountbefore = m.oShell.NameSpace( m.lcSource ).items.count
			oShell.NameSpace( m.lcZipFileName ).copyhere( m.ofile )
			sleep(100)
		ENDFOR
	CATCH TO loErr
	ENDTRY

	llErr = .T.
	DO WHILE llErr
		TRY
			llErr = .F.
			RENAME (m.lcZipFileName) TO (FORCEEXT(m.lcZipFileName,"xlsx"))
		CATCH
			llErr = .T.
			sleep(100)
		ENDTRY
	ENDDO
	DO cleanup WITH m.lcDir,m.llMemoAsComment AND m.llMemos,m.llToClose,m.cCur,m.cTotal,m.cMax,m.cStrings,m.lcCurrAlias,m.lnFHSh,m.lnFHStr,m.lnFHCo,m.lnFHDr,m.lcOldPath
ELSE && WIN 7
	TRY
		FOR EACH ofile IN m.oFolder
			lnCountbefore = m.oShell.NameSpace( m.lcSource ).items.count
			oShell.NameSpace( m.lcZipFileName ).movehere( m.ofile )
			sleep(100)
			DO WHILE m.lnCountbefore = m.oShell.NameSpace( m.lcSource ).items.count
				sleep(100)
			ENDDO
		ENDFOR
	CATCH TO loErr
	ENDTRY

	TRY 
		RD (m.lcDir)
	CATCH TO m.loErr
	ENDTRY
	DO cleanup2 WITH m.llToClose,m.cCur,m.cTotal,m.cMax,m.cStrings,m.lcCurrAlias,m.lnFHSh,m.lnFHStr,m.lnFHCo,m.lnFHDr,m.lcOldPath

	RENAME (m.lcZipFileName) TO (FORCEEXT(m.lcZipFileName,"xlsx"))
ENDIF

IF m.llOpen
	ShellExecute(0,"Open",FORCEEXT(m.lcZipFileName,"xlsx"),"","",1)
ENDIF

SET TALK &lSetTalk
SET POINT TO lcSetPoint

endfunc


**********************
* Special characters *
**********************
FUNCTION htmspec
	LPARAMETERS cStr,lcStrBad
	LOCAL lni,lcStrF,lcChar,lnChar,lcStrF2
	lcStrF = m.cStr
	IF AT(CHR(38),m.lcStrF)>0
		lcStrF = STRTRAN(m.lcStrF,CHR(38),'&amp;')
	ENDIF
	IF AT('>',m.lcStrF)>0
		lcStrF = STRTRAN(m.lcStrF,'>','&gt;')
	ENDIF
	IF AT('<',m.lcStrF)>0
		lcStrF = STRTRAN(m.lcStrF,'<','&lt;')
	ENDIF
	IF AT('"',m.lcStrF)>0
		lcStrF = STRTRAN(m.lcStrF,'"','&quot;')
	ENDIF
	IF AT("'",m.lcStrF)>0
		lcStrF = STRTRAN(m.lcStrF,"'",'&apos;')
	ENDIF
    * suggested by Koen Piller
    lcStrF2 = STRCONV(CHRTRAN(m.lcStrF,m.lcStrBad,''),9)

	RETURN m.lcStrF2
ENDFUNC

*******************
* Currency symbol *
*******************
FUNCTION getcurr
LOCAL nretval,LpLCData,cchData,llLeftCurr,lcCurr,lni
llLeftCurr = SET("Currency")=="LEFT"
LpLCData = space(255)
cchData = LEN(LpLCData)
IF OS(3)<'6' && Win XP
	nretval = GetLocaleInfo(1024, 0x14, @LpLCData, cchData) && get symbol
	lcCurr = LEFT(ALLTRIM(m.LpLCData) , m.nretval - 1)
	nretval = GetLocaleInfo(1024, 0x1B, @LpLCData, cchData)
	LpLCData = LEFT(ALLTRIM(m.LpLCData) , m.nretval - 1) && get position
	IF m.lcCurr == CHR(128)
		lcCurr = [&quot;&#8364;&quot;]
	ELSE
		lcCurr = [&quot;]+htmspec(m.lcCurr)+[&quot;]
	ENDIF
ELSE && Win Vista +  
	nretval = GetLocaleInfoEx(Null, 0x14, @LpLCData, cchData) && get symbol
	lcCurr = [&quot;]
	FOR lni = 1 TO m.nretval - 1
		lcCurr = m.lcCurr + [&#x] + RIGHT(TRANSFORM(ASC(SUBSTR(m.LpLCData,2*m.lni)),"@0"),2) + RIGHT(TRANSFORM(ASC(SUBSTR(m.LpLCData,2*m.lni - 1)),"@0"),2) + [;]
	NEXT
	lcCurr = m.lcCurr + [&quot;]
	
	nretval = GetLocaleInfoEx(Null, 0x1B, @LpLCData, cchData) && get position
	LpLCData = LEFT(m.LpLCData,1)
ENDIF
DO CASE
CASE LpLCData = "0"
	lcCurr = m.lcCurr  + [#,##0.00]
CASE LpLCData = "1"
	lcCurr = [#,##0.00] + m.lcCurr
CASE LpLCData = "2"
	lcCurr = m.lcCurr + [\ #,##0.00]
CASE LpLCData = "3"
	lcCurr = [#,##0.00\ ] + m.lcCurr
ENDCASE
RETURN m.lcCurr

**********************
* Generate temp dirs *
**********************
FUNCTION gen_dirs
	LPARAMETERS llMemoAsComment
	LOCAL lcDir
	lcDir=ADDBS(SYS(2015))
	MD (m.lcDir)
	MD (ADDBS(m.lcDir+[_rels]))
	MD (ADDBS(m.lcDir+[docProps]))
	MD (ADDBS(m.lcDir+[xl]))
	MD (ADDBS(ADDBS(m.lcDir+[xl])+[_rels]))
	MD (ADDBS(ADDBS(m.lcDir+[xl])+[worksheets]))
	IF m.llMemoAsComment
		MD (ADDBS(ADDBS(m.lcDir+[xl])+[drawings]))
		MD (ADDBS(ADDBS(ADDBS(m.lcDir+[xl])+[worksheets])+[_rels]))
	ENDIF
RETURN m.lcDir

**********************
* For OS below Win 7 *
**********************
PROCEDURE cleanup
	LPARAMETERS lcDir,llMemoAsComment,llToClose,cCur,cTotal,cMax,cStrings,lcCurrAlias,lnFHSh,lnFHStr,lnFHCo,lnFHDr,lcOldPath
	LOCAL lSetSafety
	lSetSafety = SET("Safety")
	SET SAFETY OFF
	DO cleanup2 WITH m.llToClose,m.cCur,m.cTotal,m.cMax,m.cStrings,m.lcCurrAlias,m.lnFHSh,m.lnFHStr,m.lnFHCo,m.lnFHDr,m.lcOldPath
	
	ERASE (ADDBS(ADDBS(m.lcDir+[xl])+[_rels]) + "*.*")
	RD (ADDBS(ADDBS(m.lcDir+[xl])+[_rels]))
	IF m.llMemoAsComment
		ERASE (ADDBS(ADDBS(m.lcDir+[xl])+[drawings]) + "*.*")
		RD (ADDBS(ADDBS(m.lcDir+[xl])+[drawings]))
		ERASE (ADDBS(ADDBS(ADDBS(m.lcDir+[xl])+[worksheets])+[_rels]) + "*.*")
		RD (ADDBS(ADDBS(ADDBS(m.lcDir+[xl])+[worksheets])+[_rels]))
	ENDIF
	ERASE (ADDBS(ADDBS(m.lcDir+[xl])+[worksheets]) + "*.*")
	RD (ADDBS(ADDBS(m.lcDir+[xl])+[worksheets]))
	ERASE (ADDBS(m.lcDir+[xl]) + "*.*")
	RD (ADDBS(m.lcDir+[xl]))
	ERASE (ADDBS(m.lcDir+[docProps]) + "*.*")
	RD (ADDBS(m.lcDir+[docProps]))
	ERASE (ADDBS(m.lcDir+[_rels]) + "*.*")
	RD (ADDBS(m.lcDir+[_rels]))
	ERASE (m.lcDir + "*.*")
	RD (m.lcDir)
	SET SAFETY &lSetSafety
ENDPROC

PROCEDURE cleanup2
	LPARAMETERS llToClose,cCur,cTotal,cMax,cStrings,lcCurrAlias,lnFHSh,lnFHStr,lnFHCo,lnFHDr,lcOldPath
	IF m.llToClose
		USE IN (m.cCur)
	ENDIF
	IF USED(m.cTotal)
		USE IN (m.cTotal)
	ENDIF
	IF USED(m.cMax)
		USE IN (m.cMax)
	ENDIF
	IF USED(m.cStrings)
		USE IN (m.cStrings)
	ENDIF
	IF !EMPTY(m.lcCurrAlias)
		SELECT (m.lcCurrAlias)
	ENDIF 
	IF VARTYPE(m.lnFHSh) == "N"
		FCLOSE(m.lnFHSh)
	ENDIF
	IF VARTYPE(m.lnFHStr) == "N"
		FCLOSE(m.lnFHStr)
	ENDIF
	IF VARTYPE(m.lnFHCo) == "N"
		FCLOSE(m.lnFHCo)
	ENDIF
	IF VARTYPE(m.lnFHDr) == "N"
		FCLOSE(m.lnFHDr)
	ENDIF
	IF !EMPTY(m.lcOldPath)
		SET DEFAULT TO (m.lcOldPath)
	ENDIF
ENDPROC

********************************
* Generate [Content_Types].xml *
********************************
PROCEDURE gen_Content_Types
	LPARAMETERS lcDir,llMemoAsComment
	LOCAL lnF
	lnF = FCREATE(m.lcDir+"[Content_Types].xml")
	IF m.lnF < 0
		MESSAGEBOX(ERRMESS2 + ' [Content_Types].xml',16,ERRMESS1)
		RETURN TO MASTER
	ENDIF
	FWRITE(m.lnF,[<?xml version="1.0" encoding="UTF-8" standalone="yes"?>])
	FWRITE(m.lnF,[<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">])
	FWRITE(m.lnF,[<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>])
	FWRITE(m.lnF,[<Default Extension="xml" ContentType="application/xml"/>])
	IF m.llMemoAsComment
		FWRITE(m.lnF,[<Default ContentType="application/vnd.openxmlformats-officedocument.vmlDrawing" Extension="vml"/>])
		FWRITE(m.lnF,[<Override ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.comments+xml" PartName="/xl/comments1.xml"/>])
	ENDIF
	FWRITE(m.lnF,[<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>])
	FWRITE(m.lnF,[<Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>])
	FWRITE(m.lnF,[<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>])
	FWRITE(m.lnF,[<Override PartName="/xl/sharedStrings.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sharedStrings+xml"/>])
	FWRITE(m.lnF,[<Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>])
	FWRITE(m.lnF,[<Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>]+CHR(10))
	FWRITE(m.lnF,[</Types>])
	FCLOSE(m.lnF)
ENDPROC

***************************
* Generate _rels\rels.xml *
***************************
PROCEDURE gen_rels
	LPARAMETERS lcDir
	LOCAL lnF
	lnF = FCREATE(m.lcDir+".rels")
	IF m.lnF < 0
		MESSAGEBOX(ERRMESS2 + ' .rels',16,ERRMESS1)
		RETURN TO MASTER
	ENDIF
	FWRITE(m.lnF,[<?xml version="1.0" encoding="UTF-8" standalone="yes"?>]+CHR(10))
	FWRITE(m.lnF,[<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">])
	FWRITE(m.lnF,[<Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>])
	FWRITE(m.lnF,[<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>])
	FWRITE(m.lnF,[<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>]+CHR(10))
	FWRITE(m.lnF,[</Relationships>])
	FCLOSE(m.lnF)
ENDPROC

*****************************
* Generate docProps\app.xml *
*****************************
PROCEDURE gen_app
	LPARAMETERS lcDir
	LOCAL lnF
	lnF = FCREATE(m.lcDir+"app.xml")
	IF m.lnF < 0
		MESSAGEBOX(ERRMESS2 + ' app.xml',16,ERRMESS1)
		RETURN TO MASTER
	ENDIF
	FWRITE(m.lnF,[<?xml version="1.0" encoding="UTF-8" standalone="yes"?>]+CHR(10))
	FWRITE(m.lnF,[<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties" xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">])
	FWRITE(m.lnF,[<Application>copytoxlsx</Application>])
	FWRITE(m.lnF,[<AppVersion>4.0000</AppVersion>])
	FWRITE(m.lnF,[</Properties>])
	FCLOSE(m.lnF)
ENDPROC

******************************
* Generate docProps\core.xml *
******************************
PROCEDURE gen_core
	LPARAMETERS lcDir
	LOCAL lnF
	lnF = FCREATE(m.lcDir+"core.xml")
	IF m.lnF < 0
		MESSAGEBOX(ERRMESS2 + ' core.xml',16,ERRMESS1)
		RETURN TO MASTER
	ENDIF
	FWRITE(m.lnF,[<?xml version="1.0" encoding="UTF-8" standalone="yes"?>]+CHR(10))
	FWRITE(m.lnF,[<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" ])
		FWRITE(m.lnF,[xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">])
	FWRITE(m.lnF,[<dc:creator>Vilhelm-Ion Praisach</dc:creator>])
	FWRITE(m.lnF,[<dcterms:created xsi:type="dcterms:W3CDTF">]+TTOC(DATETIME(),3)+[</dcterms:created>])
	FWRITE(m.lnF,[</cp:coreProperties>])
	FCLOSE(m.lnF)
ENDPROC

***************************************
* Generate xl\_rels\workbook.xml.rels *
***************************************
PROCEDURE gen_workbook
	LPARAMETERS lcDir,llMemoAsComment
	LOCAL lnF
	lnF = FCREATE(m.lcDir+"workbook.xml.rels")
	IF m.lnF < 0
		MESSAGEBOX(ERRMESS2 + ' workbook.xml.rels',16,ERRMESS1)
		RETURN TO MASTER
	ENDIF
	FWRITE(m.lnF,[<?xml version="1.0" encoding="UTF-8" standalone="yes"?>]+CHR(10))
	FWRITE(m.lnF,[<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">])
	FWRITE(m.lnF,[<Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>])
	FWRITE(m.lnF,[<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>])
	IF m.llMemoAsComment
		FWRITE(m.lnF,[<Relationship Id="rId5" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/comments" Target="../comments1.xml"/>])
		FWRITE(m.lnF,[<Relationship Id="rId6" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/vmlDrawing" Target="../drawings/vmlDrawing1.vml"/>])
	ENDIF
	FWRITE(m.lnF,[<Relationship Id="rId4" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings" Target="sharedStrings.xml"/>]+CHR(10))
	FWRITE(m.lnF,[</Relationships>])
	FCLOSE(m.lnF)
ENDPROC

**************************
* Generate xl\styles.xml *
**************************
PROCEDURE gen_styles
	LPARAMETERS lcDir,lcCurr,llMemoAsComment
	LOCAL lnF
	lnF = FCREATE(m.lcDir+"styles.xml")
	IF m.lnF < 0
		MESSAGEBOX(ERRMESS2 + ' styles.xml',16,ERRMESS1)
		RETURN TO MASTER
	ENDIF
	FWRITE(m.lnF,[<?xml version="1.0" encoding="UTF-8" standalone="yes"?>]+CHR(10))
	FWRITE(m.lnF,[<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" ])
	  FWRITE(m.lnF,[mc:Ignorable="x14ac" xmlns:x14ac="http://schemas.microsoft.com/office/spreadsheetml/2009/9/ac">])
	FWRITE(m.lnF,[<numFmts count="2">]) && currency
		FWRITE(m.lnF,[<numFmt numFmtId="164" formatCode="]+m.lcCurr+["/>])
		FWRITE(m.lnF,[<numFmt formatCode="dd/mm/yyyy\ hh:mm:ss" numFmtId="22"/>])
	FWRITE(m.lnF,[</numFmts>])
	IF m.llMemoAsComment
		FWRITE(m.lnF,[<fonts count="2" x14ac:knownFonts="1">])
	ELSE
		FWRITE(m.lnF,[<fonts count="1" x14ac:knownFonts="1">])
	ENDIF
		FWRITE(m.lnF,[<font><sz val="11"/>])
			FWRITE(m.lnF,[<name val="Calibri"/>])
		FWRITE(m.lnF,[</font>])
	IF m.llMemoAsComment
		FWRITE(m.lnF,[<font>])
			FWRITE(m.lnF,[<sz val="9"/>])
			FWRITE(m.lnF,[<color indexed="81"/>])
			FWRITE(m.lnF,[<name val="Tahoma"/>])
			FWRITE(m.lnF,[<family val="2"/>])
			FWRITE(m.lnF,[<charset val="238"/>])
		FWRITE(m.lnF,[</font>])
	ENDIF
	FWRITE(m.lnF,[</fonts>])
	FWRITE(m.lnF,[<fills count="1">])
		FWRITE(m.lnF,[<fill>])
			FWRITE(m.lnF,[<patternFill patternType="none"/>])
		FWRITE(m.lnF,[</fill>])
	FWRITE(m.lnF,[</fills>])
	FWRITE(m.lnF,[<borders count="1">])
		FWRITE(m.lnF,[<border>])
			FWRITE(m.lnF,[<left/><right/><top/><bottom/><diagonal/>])
		FWRITE(m.lnF,[</border>])
	FWRITE(m.lnF,[</borders>])
	FWRITE(m.lnF,[<cellXfs count="5">])
		FWRITE(m.lnF,[<xf numFmtId="0" fontId="0"/>]) && Number
		FWRITE(m.lnF,[<xf numFmtId="14" fontId="0" applyNumberFormat="1"/>]) && date
		FWRITE(m.lnF,[<xf numFmtId="22" fontId="0" applyNumberFormat="1"/>]) && time
		FWRITE(m.lnF,[<xf numFmtId="0" fontId="0" applyAlignment="1"><alignment wrapText="1"/></xf>]) && enter in memo
		FWRITE(m.lnF,[<xf numFmtId="164" fontId="0" applyNumberFormat="1"/>]) && currency
	FWRITE(m.lnF,[</cellXfs>])
	FWRITE(m.lnF,[</styleSheet>])
	FCLOSE(m.lnF)
ENDPROC

****************************
* Generate xl\workbook.xml *
****************************
PROCEDURE gen_workbook2
	LPARAMETERS lcDir
	LOCAL lnF
	lnF = FCREATE(m.lcDir+"workbook.xml")
	IF m.lnF < 0
		MESSAGEBOX(ERRMESS2 + ' workbook.xml',16,ERRMESS1)
		RETURN TO MASTER
	ENDIF
	FWRITE(m.lnF,[<?xml version="1.0" encoding="UTF-8" standalone="yes"?>]+CHR(10))
	FWRITE(m.lnF,[<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">])
		FWRITE(m.lnF,[<sheets>])
			FWRITE(m.lnF,[<sheet name="Sheet1" sheetId="1" r:id="rId1"/>])
		FWRITE(m.lnF,[</sheets>])
	FWRITE(m.lnF,[</workbook>])
	FCLOSE(m.lnF)
ENDPROC


************************************************
* Generate xl\worksheets\_rels\sheet1.xml.rels *
************************************************
PROCEDURE gen_workbook3
	LPARAMETERS lcDir
	LOCAL lnF
	lnF = FCREATE(m.lcDir+"sheet1.xml.rels")
	IF m.lnF < 0
		MESSAGEBOX(ERRMESS2 + ' sheet1.xml.rels',16,ERRMESS1)
		RETURN TO MASTER
	ENDIF
	FWRITE(m.lnF,[<?xml version="1.0" encoding="UTF-8" standalone="yes"?>]+CHR(10))
	
	FWRITE(m.lnF,[<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">])
		FWRITE(m.lnF,[<Relationship Id="rId5" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/comments" Target="../comments1.xml"/>])
		FWRITE(m.lnF,[<Relationship Id="rId6" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/vmlDrawing" Target="../drawings/vmlDrawing1.vml"/>])
	FWRITE(m.lnF,[</Relationships>])
	FCLOSE(m.lnF)
ENDPROC
