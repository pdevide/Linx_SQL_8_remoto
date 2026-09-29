lcScx = "C:\Linx_sql_8\Linx\Exclusivos\lx002006pe4.scx"
USE (lcScx) ALIAS curScx SHARED

LOCATE FOR OBJTYPE = 1
IF FOUND()
    ? "RESERVED1:", RESERVED1
    ? "RESERVED2:", RESERVED2
    ? "RESERVED3:", RESERVED3
    ? "RESERVED4:", RESERVED4
    ? "RESERVED5:", RESERVED5
    ? "RESERVED6:", RESERVED6
    ? "RESERVED7:", RESERVED7
    ? "RESERVED8:", RESERVED8
ENDIF

*!*	* Cria cursor de saída
*!*	CREATE CURSOR curProps ;
*!*	    (Parent C(40), ObjName C(40), BaseClass C(40), PropName C(60), Visibility C(10))

*!*	* Para cada registro de propriedade
*!*	SCAN FOR OBJTYPE = 7
*!*	    INSERT INTO curProps VALUES ;
*!*	        (ALLTRIM(PARENT), ALLTRIM(NAME), ALLTRIM(BASECLASS), ALLTRIM(NAME), ;
*!*	         IIF(EMPTY(ACCESS), "Public", ALLTRIM(ACCESS)))
*!*	ENDSCAN

*!*	* Se quiser exportar para CSV
*!*	COPY TO "C:\TEMP\props_lx002006pe4.csv" TYPE CSV
SELECT curScx
USE
