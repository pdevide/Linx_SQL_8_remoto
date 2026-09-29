*------------------------------------------------------
* FUNCTION _StrTo39(tcString) * CODIGO 39
*------------------------------------------------------
* Converts a string to be printed with
* True Type Font "PF Barcode 39"
* USE: _StrTo39('Codigo 39')
* RETURNS: Character
*------------------------------------------------------
FUNCTION _StrTo39(tcString)
  LOCAL lcRet
  lcRet = '*' + tcString + '*'
  RETURN lcRet
ENDFUNC
*------------------------------------------------------
* FUNCTION _StrTo128A(tcString) * CODIGO 128A
*------------------------------------------------------
* Converts a string for printing with
* True Type Font "PF Barcode 128"
* Numerics and alphabetic (only upper case)
* If a character is not valid it is replaced by a space
* USE: _StrTo128A('CODIGO 128 A')
* RETURNS: Character
*------------------------------------------------------
FUNCTION _StrTo128A(tcString)
  LOCAL lcStart, lcStop, lcRet, lcCheck, ;
    lnLong, lnI, lnCheckSum, lnAsc
  lcStart = CHR(103 + 32)
  lcStop = CHR(106 + 32)
  lnCheckSum = ASC(lcStart) - 32
  lcRet = tcString
  lnLong = LEN(lcRet)
  FOR lnI = 1 TO lnLong
    lnAsc = ASC(SUBS(lcRet,lnI,1)) - 32
    IF NOT BETWEEN(lnAsc,0,64)
      lcRet = STUFF(lcRet,lnI,1,CHR(32))
      lnAsc = ASC(SUBS(lcRet,lnI,1)) - 32
    ENDIF
    lnCheckSum = lnCheckSum + (lnAsc * lnI)
  ENDFOR
  lcCheck = CHR(MOD(lnCheckSum,103) + 32)
  lcRet = lcStart + lcRet + lcCheck + lcStop
  *--- This changes spaces and invalid characters
  lcRet = STRTRAN(lcRet,CHR(32),CHR(232))
  lcRet = STRTRAN(lcRet,CHR(127),CHR(192))
  lcRet = STRTRAN(lcRet,CHR(128),CHR(193))
  RETURN lcRet
ENDFUNC
*------------------------------------------------------
* FUNCTION _StrTo128B(tcString) * CODIGO 128B
*------------------------------------------------------
* Converts a string to be printed with
* True Type Font "PF Barcode 128"
* Numerics and alphabetic (upper and lower case)
* If a character is not valid it is replaced by a space
* USE: _StrTo128B('Codigo 128 B')
* RETURNS: Character
*------------------------------------------------------
FUNCTION _StrTo128B(tcString)
  LOCAL lcStart, lcStop, lcRet, lcCheck, ;
    lnLong, lnI, lnCheckSum, lnAsc
  lcStart = CHR(104 + 32)
  lcStop = CHR(106 + 32)
  lnCheckSum = ASC(lcStart) - 32
  lcRet = tcString
  lnLong = LEN(lcRet)
  FOR lnI = 1 TO lnLong
    lnAsc = ASC(SUBS(lcRet,lnI,1)) - 32
    IF NOT BETWEEN(lnAsc,0,99)
      lcRet = STUFF(lcRet,lnI,1,CHR(32))
      lnAsc = ASC(SUBS(lcRet,lnI,1)) - 32
    ENDIF
    lnCheckSum = lnCheckSum + (lnAsc * lnI)
  ENDFOR
  lcCheck = CHR(MOD(lnCheckSum,103) + 32)
  lcRet = lcStart + lcRet + lcCheck + lcStop
  *--- This changes spaces and invalid characters
  lcRet = STRTRAN(lcRet,CHR(32),CHR(232))
  lcRet = STRTRAN(lcRet,CHR(127),CHR(192))
  lcRet = STRTRAN(lcRet,CHR(128),CHR(193))
  RETURN lcRet
ENDFUNC
*------------------------------------------------------
* FUNCTION _StrTo128C(tcString) * CODIGO 128C
*------------------------------------------------------
* Converts a string to be printed with
* True Type Font "PF Barcode 128"
* Only numeric characters
* USE: _StrTo128C('1234567890')
* RETURNS: Character
*------------------------------------------------------
FUNCTION _StrTo128C(tcString)
  LOCAL lcStart, lcStop, lcRet, lcCheck, lcCar, ;
    lnLong, lnI, lnCheckSum, lnAsc  
  lcStart = CHR(105 + 32)
  lcStop = CHR(106 + 32)
  lnCheckSum = ASC(lcStart) - 32
  lcRet = ALLTRIM(tcString)
  lnLong = LEN(lcRet)
  *--- La longitud debe ser par
  IF MOD(lnLong,2) # 0
    lcRet = '0' + lcRet
    lnLong = LEN(lcRet)
  ENDIF
  *--- Convert couple of digits to character
  lcCar = ''
  FOR lnI = 1 TO lnLong STEP 2
    lcCar = lcCar + CHR(VAL(SUBS(lcRet,lnI,2)) + 32)
  ENDFOR
  lcRet = lcCar
  lnLong = LEN(lcRet)
  FOR lnI = 1 TO lnLong
    lnAsc = ASC(SUBS(lcRet,lnI,1)) - 32
    lnCheckSum = lnCheckSum + (lnAsc * lnI)
  ENDFOR
  lcCheck = CHR(MOD(lnCheckSum,103) + 32)
  lcRet = lcStart + lcRet + lcCheck + lcStop
  *--- This changes spaces and invalid chara
  FOR lnI = 1 TO lnLong STEP 2
    lcCar = lcCar + CHR(VAL(SUBS(lcRet,lnI,2)) + 32)
  ENDFOR
  lcRet = lcCar
  lnLong = LEN(lcRet)
  FOR lnI = 1 TO lnLong
    lnAsc = ASC(SUBS(lcRet,lnI,1)) - 32
    lnCheckSum = lnCheckSum + (lnAsc * lnI)
  ENDFOR
  lcCheck = CHR(MOD(lnCheckSum,103) + 32)
  lcRet = lcStart + lcRet + lcCheck + lcStop
  *--- This changes spaces and invalid characters
  lcRet = STRTRAN(lcRet,CHR(32),CHR(232))
  lcRet = STRTRAN(lcRet,CHR(127),CHR(192))
  lcRet = STRTRAN(lcRet,CHR(128),CHR(193))
  RETURN lcRet
ENDFUNC
*------------------------------------------------------
* FUNCTION _StrToEan13(tcString,.T.) * CODIGO EAN-13
*------------------------------------------------------
* Converts a string to be printed with
* True Type Font "PF EAN P36" or "PF EAN P72"
* PARAMETERS:
*   tcString: 12 dígit string (0..9)
*   tlCheckD: .T. Only generates check digit
*             .F. Generates check digit and characters to be printed
* USE: _StrToEan13('123456789012')
* RETURNS: Character
*------------------------------------------------------
FUNCTION _StrToEan13(tcString,tlCheckD)
  LOCAL lcLat, lcMed, lcRet, lcJuego, ;
    lcIni, lcResto, lcCod, lnI, ;
    lnCheckSum, lnAux, laJuego(10), lnPri
  lcRet = ALLTRIM(tcString)
  IF LEN(lcRet) # 12
    *--- Error en parámetro
    *--- debe tener un largo = 12
    RETURN ''
  ENDIF
  *--- Generate Check digit
  lnCheckSum = 0
  FOR lnI = 1 TO 12
    IF MOD(lnI,2) = 0
      lnCheckSum = lnCheckSum + VAL(SUBS(lcRet,lnI,1)) * 3
    ELSE
      lnCheckSum = lnCheckSum + VAL(SUBS(lcRet,lnI,1)) * 1
    ENDIF
  ENDFOR
  lnAux = MOD(lnCheckSum,10)
  lcRet = lcRet + ALLTRIM(STR(IIF(lnAux = 0,0,10-lnAux)))
  IF tlCheckD
    *--- If I only generate a check digit
    RETURN lcRet
  ENDIF
  *--- To print with True Type Font PF_EAN_PXX
  *--- 1st. dígit (lnPri)
  lnPri = VAL(LEFT(lcRet,1))
  *--- Character code table
  *--- according to 'lnPri' (¡DO NOT TOUCH!)
  laJuego(1) = 'AAAAAACCCCCC' && 0
  laJuego(2) = 'AABABBCCCCCC' && 1
  laJuego(3) = 'AABBABCCCCCC' && 2
  laJuego(4) = 'AABBBACCCCCC' && 3
  laJuego(5) = 'ABAABBCCCCCC' && 4
  laJuego(6) = 'ABBAABCCCCCC' && 5
  laJuego(7) = 'ABBBAACCCCCC' && 6
  laJuego(8) = 'ABABABCCCCCC' && 7
  laJuego(9) = 'ABABBACCCCCC' && 8
  laJuego(10) = 'ABBABACCCCCC' && 9
  *--- Initial character (outside the code)
  lcIni = CHR(lnPri + 35)
  *--- Lateral and central characters
  lcLat = CHR(33)
  lcMed = CHR(45)
  *--- Rest of the characters
  lcResto = SUBS(lcRet,2,12)
  FOR lnI = 1 TO 12
    lcJuego = SUBS(laJuego(lnPri + 1),lnI,1)
    DO CASE
      CASE lcJuego = 'A'
        lcResto = STUFF(lcResto,lnI,1,CHR(VAL(SUBS(lcResto,lnI,1)) + 48))
      CASE lcJuego = 'B'
        lcResto = STUFF(lcResto,lnI,1,CHR(VAL(SUBS(lcResto,lnI,1)) + 65))
      CASE lcJuego = 'C'
        lcResto = STUFF(lcResto,lnI,1,CHR(VAL(SUBS(lcResto,lnI,1)) + 97))
    ENDCASE
  ENDFOR
  *--- Compose code
  lcCod = lcIni + lcLat + SUBS(lcResto,1,6) + lcMed + ;
    SUBS(lcResto,7,6) + lcLat
  RETURN lcCod
ENDFUNC
*------------------------------------------------------
* FUNCTION _StrToEan8(tcString,.T.) * CODIGO EAN-8
*------------------------------------------------------
* Converts a string to be printed with
* True Type Font "PF EAN P36" ó "PF EAN P72"
* PARAMETERS:
*   tcString: 7 digit string (0..9)
*   tlCheckD: .T. Only generates check digit
*             .F. Generates check digit and characters to be printed
* USE: _StrToEan8('1234567')
* RETURNS: Character
*------------------------------------------------------
FUNCTION _StrToEan8(tcString,tlCheckD)
  LOCAL lcLat, lcMed, lcRet, ;
    lcIni, lcCod, lnI, ;
    lnCheckSum, lnAux
  lcRet = ALLTRIM(tcString)
  IF LEN(lcRet) # 7
    *--- Parameter error
    *--- must have length = 7
    RETURN ''
  ENDIF
  *--- Generate check digit
  lnCheckSum = 0
  FOR lnI = 1 TO 7
    IF MOD(lnI,2) = 0
      lnCheckSum = lnCheckSum + VAL(SUBS(lcRet,lnI,1)) * 1
    ELSE
      lnCheckSum = lnCheckSum + VAL(SUBS(lcRet,lnI,1)) * 3
    ENDIF
  ENDFOR
  lnAux = MOD(lnCheckSum,10)
  lcRet = lcRet + ALLTRIM(STR(IIF(lnAux = 0,0,10-lnAux)))
  IF tlCheckD
    *--- If I only generate check digit
    RETURN lcRet
  ENDIF
  *--- To print with True Type Font PF_EAN_PXX
  *--- Lateral and central characters
  lcLat = CHR(33)
  lcMed = CHR(45)
  *--- Characters
  FOR lnI = 1 TO 8
    IF lnI <= 4
      lcRet = STUFF(lcRet,lnI,1,CHR(VAL(SUBS(lcRet,lnI,1)) + 48))
    ELSE
      lcRet = STUFF(lcRet,lnI,1,CHR(VAL(SUBS(lcRet,lnI,1)) + 97))
    ENDIF
  ENDFOR
  *--- Compose code
  lcCod = lcLat + SUBS(lcRet,1,4) + lcMed + SUBS(lcRet,5,4) + lcLat
  RETURN lcCod
ENDFUNC
*------------------------------------------------------
* FUNCTION _StrToI2of5(tcString) * INTERLEAVED 2 OF 5
*------------------------------------------------------
* Converts a string to be printed with
*   True Type Font "PF Interleaved 2 of 5"
*   or "PF Interleaved 2 of 5 Wide"
*   or "PF Interleaved 2 of 5 Text"
*   Only numeric characters
* USE: _StrToI2of5('1234567890')
* RETURNS: Character
*------------------------------------------------------
FUNCTION _StrToI2of5(tcString)
  LOCAL lcStart, lcStop, lcRet, lcCheck, ;
    lcCar, lnLong, lnI, lnSum, lnAux
  lcStart = CHR(40)
  lcStop = CHR(41)
  lcRet = ALLTRIM(tcString)
  *--- Generate check digit
  lnLong = LEN(lcRet)
  lnSum = 0
  lnCount = 1
  FOR lnI = lnLong TO 1 STEP -1
    lnSum = lnSum + VAL(SUBSTR(lcRet,lnI,1)) * ;
      IIF(MOD(lnCount,2) = 0,1,3)
    lnCount = lnCount + 1
  ENDFOR
  lnAux = MOD(lnSum,10)
  lcRet = lcRet + ALLTRIM(STR(IIF(lnAux = 0,0,10 - lnAux)))
  lnLong = LEN(lcRet)
  *--- Length must be even
  IF MOD(lnLong,2) # 0
    lcRet = '0' + lcRet
    lnLong = LEN(lcRet)
  ENDIF
  *--- Convert a couple of digits to character
  lcCar = ''
  FOR lnI = 1 TO lnLong STEP 2
    IF VAL(SUBS(lcRet,lnI,2)) < 50
      lcCar = lcCar + CHR(VAL(SUBS(lcRet,lnI,2)) + 48)
    ELSE
      lcCar = lcCar + CHR(VAL(SUBS(lcRet,lnI,2)) + 142)
    ENDIF
  ENDFOR
  *--- Compose code
  lcRet = lcStart + lcCar + lcStop
  RETURN lcRet
ENDFUNC

endproc



*------------------------------------------------------