PARAMETERS tcnpj
    LOCAL cnpjLimpo, i, soma, digito1, digito2, tamanhoCNPJ

    * Remove a máscara do CNPJ
    cnpjLimpo = STRTRAN(tcnpj, '.', '')
    cnpjLimpo = STRTRAN(cnpjLimpo, '-', '')
    cnpjLimpo = STRTRAN(cnpjLimpo, '/', '')

    * Verifica se tem 14 dígitos
    tamanhoCNPJ = LEN(cnpjLimpo)
    IF tamanhoCNPJ != 14
        RETURN .F.
    ENDIF

    * Verifica se todos os dígitos são iguais (caso inválido)
    IF cnpjLimpo = REPLICATE(SUBSTR(cnpjLimpo, 1, 1), 14)
        RETURN .F.
    ENDIF

    * Cálculo do primeiro dígito verificador
    soma = 0
    FOR i = 1 TO 12
        soma = soma + VAL(SUBSTR(cnpjLimpo, i, 1)) * (5 - (i MOD 8))
    ENDFOR
    digito1 = MOD(soma, 11)
    IF digito1 < 2
        digito1 = 0
    ELSE
        digito1 = 11 - digito1
    ENDIF

    * Cálculo do segundo dígito verificador
    soma = 0
    FOR i = 1 TO 13
        soma = soma + VAL(SUBSTR(cnpjLimpo, i, 1)) * (6 - (i MOD 8))
    ENDFOR
    digito2 = MOD(soma, 11)
    IF digito2 < 2
        digito2 = 0
    ELSE
        digito2 = 11 - digito2
    ENDIF

    * Verifica se os dígitos verificadores estão corretos
    IF (digito1 = VAL(SUBSTR(cnpjLimpo, 13, 1))) AND (digito2 = VAL(SUBSTR(cnpjLimpo, 14, 1)))
    	WAIT WINDOW "CNPJ OK!" NOWAIT 
        RETURN .T.
    ELSE
    	WAIT WINDOW "CNPJ INVALIDO!" NOWAIT 
        RETURN .F.
    ENDIF

