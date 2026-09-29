TRY
    cc = SQLSTRINGCONNECT("",.t.) && <<<--- error
CATCH TO oEx
    MESSAGEBOX("Error!")
    THROW oEx
FINALLY
    MESSAGEBOX("Cleanup Code")
ENDTRY
MESSAGEBOX("More Code") && <<<--- oops