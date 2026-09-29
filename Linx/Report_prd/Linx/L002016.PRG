*--- Funccions to Bar Code (with ttf fonts )
*--- Adaptation on Linx by Valmir - April, 2002
*------------------------------------------------------------------------------------------------------------------------*



*------------------------------------------------------------------------------------------------------------------------*
*--- Code 39 Code Section

Procedure BC_Code39
Parameters m

*Call the option procedure with basic code39 and no check character
rtnp = BC_OCode39(m,"Basic",0)

return rtnp
*-------



*-------
Procedure BC_OCode39
Parameters m,full,check
private t,x,p,cval,chktot
set talk off
* Generates character pattern for code 39 bar codes
*    m  = text to decode into a character pattern
*
* Returns:
*    Bar pattern for code 39 bar code.
*    If an illegal value is found then a null will
*    be returned to the user.

*** if the parameter is not a character then quit
if type('m')<>"C"
  return ""
endif
*** verify full parameter
if type('full')<>"C"
  full = "BASIC"
  cval = 2
else
  full = upper(full)
  if full<>"FULL"
    full = "BASIC"
    cval = 2
  else
    cval = 3
  endif
endif

*** verify check parameter
if type('check')<>'N'
  check = 0
else
  if check <> 1
    check = 0
  endif
endif

*** Check to see if user added stop/start
*** character and returns null if true
if at("*"," "+m)>1
  return ""
endif

*** decode message into bar code character pattern and place
*** it into the variable

* initialize the output string and add the start code to it
p="*"

* Dimension the conversion array
dimension cvtarr[4,128]

* Define the conversion array
cvtarr[1,1]=chr(0)
cvtarr[2,1]=""
cvtarr[3,1]="%U"
cvtarr[4,1]=0
cvtarr[1,2]=chr(1)
cvtarr[2,2]=""
cvtarr[3,2]="$A"
cvtarr[4,2]=0
cvtarr[1,3]=chr(2)
cvtarr[2,3]=""
cvtarr[3,3]="$B"
cvtarr[4,3]=0
cvtarr[1,4]=chr(3)
cvtarr[2,4]=""
cvtarr[3,4]="$C"
cvtarr[4,4]=0
cvtarr[1,5]=chr(4)
cvtarr[2,5]=""
cvtarr[3,5]="$D"
cvtarr[4,5]=0
cvtarr[1,6]=chr(5)
cvtarr[2,6]=""
cvtarr[3,6]="$E"
cvtarr[4,6]=0
cvtarr[1,7]=chr(6)
cvtarr[2,7]=""
cvtarr[3,7]="$F"
cvtarr[4,7]=0
cvtarr[1,8]=chr(7)
cvtarr[2,8]=""
cvtarr[3,8]="$G"
cvtarr[4,8]=0
cvtarr[1,9]=chr(8)
cvtarr[2,9]=""
cvtarr[3,9]="$H"
cvtarr[4,9]=0
cvtarr[1,10]=chr(9)
cvtarr[2,10]=""
cvtarr[3,10]="$I"
cvtarr[4,10]=0
cvtarr[1,11]=chr(10)
cvtarr[2,11]=""
cvtarr[3,11]="$J"
cvtarr[4,11]=0
cvtarr[1,12]=chr(11)
cvtarr[2,12]=""
cvtarr[3,12]="$K"
cvtarr[4,12]=0
cvtarr[1,13]=chr(12)
cvtarr[2,13]=""
cvtarr[3,13]="$L"
cvtarr[4,13]=0
cvtarr[1,14]=chr(13)
cvtarr[2,14]=""
cvtarr[3,14]="$M"
cvtarr[4,14]=0
cvtarr[1,15]=chr(14)
cvtarr[2,15]=""
cvtarr[3,15]="$N"
cvtarr[4,15]=0
cvtarr[1,16]=chr(15)
cvtarr[2,16]=""
cvtarr[3,16]="$O"
cvtarr[4,16]=0
cvtarr[1,17]=chr(16)
cvtarr[2,17]=""
cvtarr[3,17]="$P"
cvtarr[4,17]=0
cvtarr[1,18]=chr(17)
cvtarr[2,18]=""
cvtarr[3,18]="$Q"
cvtarr[4,18]=0
cvtarr[1,19]=chr(18)
cvtarr[2,19]=""
cvtarr[3,19]="$R"
cvtarr[4,19]=0
cvtarr[1,20]=chr(19)
cvtarr[2,20]=""
cvtarr[3,20]="$S"
cvtarr[4,20]=0
cvtarr[1,21]=chr(20)
cvtarr[2,21]=""
cvtarr[3,21]="$T"
cvtarr[4,21]=0
cvtarr[1,22]=chr(21)
cvtarr[2,22]=""
cvtarr[3,22]="$U"
cvtarr[4,22]=0
cvtarr[1,23]=chr(22)
cvtarr[2,23]=""
cvtarr[3,23]="$V"
cvtarr[4,23]=0
cvtarr[1,24]=chr(23)
cvtarr[2,24]=""
cvtarr[3,24]="$W"
cvtarr[4,24]=0
cvtarr[1,25]=chr(24)
cvtarr[2,25]=""
cvtarr[3,25]="$X"
cvtarr[4,25]=0
cvtarr[1,26]=chr(25)
cvtarr[2,26]=""
cvtarr[3,26]="$Y"
cvtarr[4,26]=0
cvtarr[1,27]=chr(26)
cvtarr[2,27]=""
cvtarr[3,27]="$Z"
cvtarr[4,27]=0
cvtarr[1,28]=chr(27)
cvtarr[2,28]=""
cvtarr[3,28]="%A"
cvtarr[4,28]=0
cvtarr[1,29]=chr(28)
cvtarr[2,29]=""
cvtarr[3,29]="%B"
cvtarr[4,29]=0
cvtarr[1,30]=chr(29)
cvtarr[2,30]=""
cvtarr[3,30]="%C"
cvtarr[4,30]=0
cvtarr[1,31]=chr(30)
cvtarr[2,31]=""
cvtarr[3,31]="%D"
cvtarr[4,31]=0
cvtarr[1,32]=chr(31)
cvtarr[2,32]=""
cvtarr[3,32]="%E"
cvtarr[4,32]=0
cvtarr[1,33]=chr(32)
cvtarr[2,33]=" "
cvtarr[3,33]=" "
cvtarr[4,33]=38
cvtarr[1,34]="!"
cvtarr[2,34]=""
cvtarr[3,34]="/A"
cvtarr[4,34]=0
cvtarr[1,35]=chr(34)
cvtarr[2,35]=""
cvtarr[3,35]="/B"
cvtarr[4,35]=0
cvtarr[1,36]="#"
cvtarr[2,36]=""
cvtarr[3,36]="/C"
cvtarr[4,36]=0
cvtarr[1,37]="$"
cvtarr[2,37]="$"
cvtarr[3,37]="/D"
cvtarr[4,37]=39
cvtarr[1,38]="%"
cvtarr[2,38]="%"
cvtarr[3,38]="/E"
cvtarr[4,38]=42
cvtarr[1,39]="&"
cvtarr[2,39]=""
cvtarr[3,39]="/F"
cvtarr[4,39]=0
cvtarr[1,40]=chr(39)
cvtarr[2,40]=""
cvtarr[3,40]="/G"
cvtarr[4,40]=0
cvtarr[1,41]="("
cvtarr[2,41]=""
cvtarr[3,41]="/H"
cvtarr[4,41]=0
cvtarr[1,42]=")"
cvtarr[2,42]=""
cvtarr[3,42]="/I"
cvtarr[4,42]=0
cvtarr[1,43]="*"
cvtarr[2,43]=""
cvtarr[3,43]="/J"
cvtarr[4,43]=0
cvtarr[1,44]="+"
cvtarr[2,44]="+"
cvtarr[3,44]="/K"
cvtarr[4,44]=41
cvtarr[1,45]=","
cvtarr[2,45]=""
cvtarr[3,45]="/L"
cvtarr[4,45]=0
cvtarr[1,46]="-"
cvtarr[2,46]="-"
cvtarr[3,46]="-"
cvtarr[4,46]=36
cvtarr[1,47]="."
cvtarr[2,47]="."
cvtarr[3,47]="."
cvtarr[4,47]=37
cvtarr[1,48]="/"
cvtarr[2,48]="/"
cvtarr[3,48]="/O"
cvtarr[4,48]=40
cvtarr[1,49]="0"
cvtarr[2,49]="0"
cvtarr[3,49]="0"
cvtarr[4,49]=0
cvtarr[1,50]="1"
cvtarr[2,50]="1"
cvtarr[3,50]="1"
cvtarr[4,50]=1
cvtarr[1,51]="2"
cvtarr[2,51]="2"
cvtarr[3,51]="2"
cvtarr[4,51]=2
cvtarr[1,52]="3"
cvtarr[2,52]="3"
cvtarr[3,52]="3"
cvtarr[4,52]=3
cvtarr[1,53]="4"
cvtarr[2,53]="4"
cvtarr[3,53]="4"
cvtarr[4,53]=4
cvtarr[1,54]="5"
cvtarr[2,54]="5"
cvtarr[3,54]="5"
cvtarr[4,54]=5
cvtarr[1,55]="6"
cvtarr[2,55]="6"
cvtarr[3,55]="6"
cvtarr[4,55]=6
cvtarr[1,56]="7"
cvtarr[2,56]="7"
cvtarr[3,56]="7"
cvtarr[4,56]=7
cvtarr[1,57]="8"
cvtarr[2,57]="8"
cvtarr[3,57]="8"
cvtarr[4,57]=8
cvtarr[1,58]="9"
cvtarr[2,58]="9"
cvtarr[3,58]="9"
cvtarr[4,58]=9
cvtarr[1,59]=":"
cvtarr[2,59]=""
cvtarr[3,59]="/Z"
cvtarr[4,59]=0
cvtarr[1,60]=";"
cvtarr[2,60]=""
cvtarr[3,60]="%F"
cvtarr[4,60]=0
cvtarr[1,61]="<"
cvtarr[2,61]=""
cvtarr[3,61]="%G"
cvtarr[4,61]=0
cvtarr[1,62]="="
cvtarr[2,62]=""
cvtarr[3,62]="%H"
cvtarr[4,62]=0
cvtarr[1,63]=">"
cvtarr[2,63]=""
cvtarr[3,63]="%I"
cvtarr[4,63]=0
cvtarr[1,64]="?"
cvtarr[2,64]=""
cvtarr[3,64]="%J"
cvtarr[4,64]=0
cvtarr[1,65]="@"
cvtarr[2,65]=""
cvtarr[3,65]="%V"
cvtarr[4,65]=0
cvtarr[1,66]="A"
cvtarr[2,66]="A"
cvtarr[3,66]="A"
cvtarr[4,66]=10
cvtarr[1,67]="B"
cvtarr[2,67]="B"
cvtarr[3,67]="B"
cvtarr[4,67]=11
cvtarr[1,68]="C"
cvtarr[2,68]="C"
cvtarr[3,68]="C"
cvtarr[4,68]=12
cvtarr[1,69]="D"
cvtarr[2,69]="D"
cvtarr[3,69]="D"
cvtarr[4,69]=13
cvtarr[1,70]="E"
cvtarr[2,70]="E"
cvtarr[3,70]="E"
cvtarr[4,70]=14
cvtarr[1,71]="F"
cvtarr[2,71]="F"
cvtarr[3,71]="F"
cvtarr[4,71]=15
cvtarr[1,72]="G"
cvtarr[2,72]="G"
cvtarr[3,72]="G"
cvtarr[4,72]=16
cvtarr[1,73]="H"
cvtarr[2,73]="H"
cvtarr[3,73]="H"
cvtarr[4,73]=17
cvtarr[1,74]="I"
cvtarr[2,74]="I"
cvtarr[3,74]="I"
cvtarr[4,74]=18
cvtarr[1,75]="J"
cvtarr[2,75]="J"
cvtarr[3,75]="J"
cvtarr[4,75]=19
cvtarr[1,76]="K"
cvtarr[2,76]="K"
cvtarr[3,76]="K"
cvtarr[4,76]=20
cvtarr[1,77]="L"
cvtarr[2,77]="L"
cvtarr[3,77]="L"
cvtarr[4,77]=21
cvtarr[1,78]="M"
cvtarr[2,78]="M"
cvtarr[3,78]="M"
cvtarr[4,78]=22
cvtarr[1,79]="N"
cvtarr[2,79]="N"
cvtarr[3,79]="N"
cvtarr[4,79]=23
cvtarr[1,80]="O"
cvtarr[2,80]="O"
cvtarr[3,80]="O"
cvtarr[4,80]=24
cvtarr[1,81]="P"
cvtarr[2,81]="P"
cvtarr[3,81]="P"
cvtarr[4,81]=25
cvtarr[1,82]="Q"
cvtarr[2,82]="Q"
cvtarr[3,82]="Q"
cvtarr[4,82]=26
cvtarr[1,83]="R"
cvtarr[2,83]="R"
cvtarr[3,83]="R"
cvtarr[4,83]=27
cvtarr[1,84]="S"
cvtarr[2,84]="S"
cvtarr[3,84]="S"
cvtarr[4,84]=28
cvtarr[1,85]="T"
cvtarr[2,85]="T"
cvtarr[3,85]="T"
cvtarr[4,85]=29
cvtarr[1,86]="U"
cvtarr[2,86]="U"
cvtarr[3,86]="U"
cvtarr[4,86]=30
cvtarr[1,87]="V"
cvtarr[2,87]="V"
cvtarr[3,87]="V"
cvtarr[4,87]=31
cvtarr[1,88]="W"
cvtarr[2,88]="W"
cvtarr[3,88]="W"
cvtarr[4,88]=32
cvtarr[1,89]="X"
cvtarr[2,89]="X"
cvtarr[3,89]="X"
cvtarr[4,89]=33
cvtarr[1,90]="Y"
cvtarr[2,90]="Y"
cvtarr[3,90]="Y"
cvtarr[4,90]=34
cvtarr[1,91]="Z"
cvtarr[2,91]="Z"
cvtarr[3,91]="Z"
cvtarr[4,91]=35
cvtarr[1,92]="["
cvtarr[2,92]=""
cvtarr[3,92]="%K"
cvtarr[4,92]=0
cvtarr[1,93]="\"
cvtarr[2,93]=""
cvtarr[3,93]="%L"
cvtarr[4,93]=0
cvtarr[1,94]="]"
cvtarr[2,94]=""
cvtarr[3,94]="%M"
cvtarr[4,94]=0
cvtarr[1,95]="^"
cvtarr[2,95]=""
cvtarr[3,95]="%N"
cvtarr[4,95]=0
cvtarr[1,96]="_"
cvtarr[2,96]=""
cvtarr[3,96]="%O"
cvtarr[4,96]=0
cvtarr[1,97]=chr(96)
cvtarr[2,97]=""
cvtarr[3,97]="%W"
cvtarr[4,97]=0
cvtarr[1,98]="a"
cvtarr[2,98]=""
cvtarr[3,98]="+A"
cvtarr[4,98]=0
cvtarr[1,99]="b"
cvtarr[2,99]=""
cvtarr[3,99]="+B"
cvtarr[4,99]=0
cvtarr[1,100]="c"
cvtarr[2,100]=""
cvtarr[3,100]="+C"
cvtarr[4,100]=0
cvtarr[1,101]="d"
cvtarr[2,101]=""
cvtarr[3,101]="+D"
cvtarr[4,101]=0
cvtarr[1,102]="e"
cvtarr[2,102]=""
cvtarr[3,102]="+E"
cvtarr[4,102]=0
cvtarr[1,103]="f"
cvtarr[2,103]=""
cvtarr[3,103]="+F"
cvtarr[4,103]=0
cvtarr[1,104]="g"
cvtarr[2,104]=""
cvtarr[3,104]="+G"
cvtarr[4,104]=0
cvtarr[1,105]="h"
cvtarr[2,105]=""
cvtarr[3,105]="+H"
cvtarr[4,105]=0
cvtarr[1,106]="i"
cvtarr[2,106]=""
cvtarr[3,106]="+I"
cvtarr[4,106]=0
cvtarr[1,107]="j"
cvtarr[2,107]=""
cvtarr[3,107]="+J"
cvtarr[4,107]=0
cvtarr[1,108]="k"
cvtarr[2,108]=""
cvtarr[3,108]="+K"
cvtarr[4,108]=0
cvtarr[1,109]="l"
cvtarr[2,109]=""
cvtarr[3,109]="+L"
cvtarr[4,109]=0
cvtarr[1,110]="m"
cvtarr[2,110]=""
cvtarr[3,110]="+M"
cvtarr[4,110]=0
cvtarr[1,111]="n"
cvtarr[2,111]=""
cvtarr[3,111]="+N"
cvtarr[4,111]=0
cvtarr[1,112]="o"
cvtarr[2,112]=""
cvtarr[3,112]="+O"
cvtarr[4,112]=0
cvtarr[1,113]="p"
cvtarr[2,113]=""
cvtarr[3,113]="+P"
cvtarr[4,113]=0
cvtarr[1,114]="q"
cvtarr[2,114]=""
cvtarr[3,114]="+Q"
cvtarr[4,114]=0
cvtarr[1,115]="r"
cvtarr[2,115]=""
cvtarr[3,115]="+R"
cvtarr[4,115]=0
cvtarr[1,116]="s"
cvtarr[2,116]=""
cvtarr[3,116]="+S"
cvtarr[4,116]=0
cvtarr[1,117]="t"
cvtarr[2,117]=""
cvtarr[3,117]="+T"
cvtarr[4,117]=0
cvtarr[1,118]="u"
cvtarr[2,118]=""
cvtarr[3,118]="+U"
cvtarr[4,118]=0
cvtarr[1,119]="v"
cvtarr[2,119]=""
cvtarr[3,119]="+V"
cvtarr[4,119]=0
cvtarr[1,120]="w"
cvtarr[2,120]=""
cvtarr[3,120]="+W"
cvtarr[4,120]=0
cvtarr[1,121]="x"
cvtarr[2,121]=""
cvtarr[3,121]="+X"
cvtarr[4,121]=0
cvtarr[1,122]="y"
cvtarr[2,122]=""
cvtarr[3,122]="+Y"
cvtarr[4,122]=0
cvtarr[1,123]="z"
cvtarr[2,123]=""
cvtarr[3,123]="+Z"
cvtarr[4,123]=0
cvtarr[1,124]="{"
cvtarr[2,124]=""
cvtarr[3,124]="%P"
cvtarr[4,124]=0
cvtarr[1,125]="|"
cvtarr[2,125]=""
cvtarr[3,125]="%Q"
cvtarr[4,125]=0
cvtarr[1,126]="}"
cvtarr[2,126]=""
cvtarr[3,126]="%R"
cvtarr[4,126]=0
cvtarr[1,127]="~"
cvtarr[2,127]=""
cvtarr[3,127]="%S"
cvtarr[4,127]=0
cvtarr[1,128]=chr(127)
cvtarr[2,128]=""
cvtarr[3,128]="%T"
cvtarr[4,128]=0

chktot = 0
*** process the message
FOR x = 1 TO len(m)
  t = substr(m, x, 1)
  rtnc = asubscript(cvtarr,ascan(cvtarr,t,aelement(cvtarr,1,1),128),2)
  if rtnc <> 0
    p = p + cvtarr[cval,rtnc]
    chktot = chktot + cvtarr[4,rtnc]
  endif
endfor

if check = 1
  chkstr = 43 - (chktot % 43)
  rtnc = asubscript(cvtarr,ascan(cvtarr,chkstr,aelement(cvtarr,4,1),128),2)
  if rtnc <> 0
    p = p + cvtarr[1,rtnc]
  endif
endif

p = p + "*"

*** Return the bit pattern
return p
*------------------------------------------------------------------------------------------------------------------------*



*------------------------------------------------------------------------------------------------------------------------*
*--- Interleave 2 of 5 Code Section

Procedure BC_Inter25
Parameters m

*Call the option procedure with check character
rtnp = BC_OInter25(m,1)

return rtnp
*-------



*-------
Procedure BC_OInter25
Parameters m,check
private t,x,t1,odd_m,even_m,p,y

set talk off
* Generates character pattern for Interleaved 2 of 5 bar codes
*    m  = text to decode into a character pattern
*
* Returns:
*    Character pattern for Interleaved 2 of 5 bar code.
*    If an illegal value is found then a null will
*    be returned to the user.

*** if the parameter is not a character then quit
if type('m')<>"C"
  return ""
endif

*** verify check parameter
if type('check')<>'N'
  check = 1
else
  if check <> 0
    check = 1
  endif
endif

*** check to make sure that all the characters are valid for Interleaved 25
*** between 0 and 9
for x = 1 to len(m)
  if substr(m,x,1) < chr(48) .or. substr(m,x,1) > chr(57)
    return ""
  endif
endfor

if check = 1
  *** make the total number of digits an odd number so adding a check char makes it even
  m = iif(mod(len(m),2)=0,"0"+m,m)

  *** Add check digit
  m = BC_InterCheck(m)

else
  *** make the total number of digits an even number
  m = iif(mod(len(m),2)=1,"0"+m,m)
endif

*** decode message into character pattern and place
*** it into the variable
* Start with start code
p = chr(97)

FOR x = 1 TO len(m) step 2
  t = substr(m, x, 1)
  do case
    CASE t = "0"
      t1 = substr(m,x+1,1)
      do case
        case t1 = "0"
          p = p + chr(34)+chr(93)
        case t1 = "1"
          p = p + chr(42)+chr(74)
        case t1 = "2"
          p = p + chr(36)+chr(74)
        case t1 = "3"
          p = p + chr(44)+chr(73)
        case t1 = "4"
          p = p + chr(34)+chr(90)
        case t1 = "5"
          p = p + chr(42)+chr(89)
        case t1 = "6"
          p = p + chr(36)+chr(89)
        case t1 = "7"
          p = p + chr(34)+chr(78)
        case t1 = "8"
          p = p + chr(42)+chr(77)
        case t1 = "9"
          p = p + chr(36)+chr(77)
      endcase
    CASE t = "1"
      t1 = substr(m,x+1,1)
      do case
        case t1 = "0"
          p = p + chr(49)+chr(87)
        case t1 = "1"
          p = p + chr(57)+chr(68)
        case t1 = "2"
          p = p + chr(51)+chr(68)
        case t1 = "3"
          p = p + chr(59)+chr(67)
        case t1 = "4"
          p = p + chr(49)+chr(84)
        case t1 = "5"
          p = p + chr(57)+chr(83)
        case t1 = "6"
          p = p + chr(51)+chr(83)
        case t1 = "7"
          p = p + chr(49)+chr(72)
        case t1 = "8"
          p = p + chr(57)+chr(71)
        case t1 = "9"
          p = p + chr(51)+chr(71)
      endcase
    CASE t = "2"
      t1 = substr(m,x+1,1)
      do case
        case t1 = "0"
          p = p + chr(37)+chr(87)
        case t1 = "1"
          p = p + chr(45)+chr(68)
        case t1 = "2"
          p = p + chr(39)+chr(68)
        case t1 = "3"
          p = p + chr(47)+chr(67)
        case t1 = "4"
          p = p + chr(37)+chr(84)
        case t1 = "5"
          p = p + chr(45)+chr(83)
        case t1 = "6"
          p = p + chr(39)+chr(83)
        case t1 = "7"
          p = p + chr(37)+chr(72)
        case t1 = "8"
          p = p + chr(45)+chr(71)
        case t1 = "9"
          p = p + chr(39)+chr(71)
      endcase
    CASE t = "3"
      t1 = substr(m,x+1,1)
      do case
        case t1 = "0"
          p = p + chr(53)+chr(85)
        case t1 = "1"
          p = p + chr(61)+chr(66)
        case t1 = "2"
          p = p + chr(55)+chr(66)
        case t1 = "3"
          p = p + chr(63)+chr(65)
        case t1 = "4"
          p = p + chr(53)+chr(82)
        case t1 = "5"
          p = p + chr(61)+chr(81)
        case t1 = "6"
          p = p + chr(55)+chr(81)
        case t1 = "7"
          p = p + chr(53)+chr(70)
        case t1 = "8"
          p = p + chr(61)+chr(69)
        case t1 = "9"
          p = p + chr(55)+chr(69)
      endcase
    CASE t = "4"
      t1 = substr(m,x+1,1)
      do case
        case t1 = "0"
          p = p + chr(34)+chr(87)
        case t1 = "1"
          p = p + chr(42)+chr(68)
        case t1 = "2"
          p = p + chr(36)+chr(68)
        case t1 = "3"
          p = p + chr(44)+chr(67)
        case t1 = "4"
          p = p + chr(34)+chr(84)
        case t1 = "5"
          p = p + chr(42)+chr(83)
        case t1 = "6"
          p = p + chr(36)+chr(83)
        case t1 = "7"
          p = p + chr(34)+chr(72)
        case t1 = "8"
          p = p + chr(42)+chr(71)
        case t1 = "9"
          p = p + chr(36)+chr(71)
      endcase
    CASE t = "5"
      t1 = substr(m,x+1,1)
      do case
        case t1 = "0"
          p = p + chr(50)+chr(85)
        case t1 = "1"
          p = p + chr(58)+chr(66)
        case t1 = "2"
          p = p + chr(52)+chr(66)
        case t1 = "3"
          p = p + chr(60)+chr(65)
        case t1 = "4"
          p = p + chr(50)+chr(82)
        case t1 = "5"
          p = p + chr(58)+chr(81)
        case t1 = "6"
          p = p + chr(52)+chr(81)
        case t1 = "7"
          p = p + chr(50)+chr(70)
        case t1 = "8"
          p = p + chr(58)+chr(69)
        case t1 = "9"
          p = p + chr(52)+chr(69)
      endcase
    CASE t = "6"
      t1 = substr(m,x+1,1)
      do case
        case t1 = "0"
          p = p + chr(38)+chr(85)
        case t1 = "1"
          p = p + chr(46)+chr(66)
        case t1 = "2"
          p = p + chr(40)+chr(66)
        case t1 = "3"
          p = p + chr(48)+chr(65)
        case t1 = "4"
          p = p + chr(38)+chr(82)
        case t1 = "5"
          p = p + chr(46)+chr(81)
        case t1 = "6"
          p = p + chr(40)+chr(81)
        case t1 = "7"
          p = p + chr(38)+chr(70)
        case t1 = "8"
          p = p + chr(46)+chr(69)
        case t1 = "9"
          p = p + chr(40)+chr(69)
      endcase
    CASE t = "7"
      t1 = substr(m,x+1,1)
      do case
        case t1 = "0"
          p = p + chr(33)+chr(95)
        case t1 = "1"
          p = p + chr(41)+chr(76)
        case t1 = "2"
          p = p + chr(35)+chr(76)
        case t1 = "3"
          p = p + chr(43)+chr(75)
        case t1 = "4"
          p = p + chr(33)+chr(92)
        case t1 = "5"
          p = p + chr(41)+chr(91)
        case t1 = "6"
          p = p + chr(35)+chr(91)
        case t1 = "7"
          p = p + chr(33)+chr(80)
        case t1 = "8"
          p = p + chr(41)+chr(79)
        case t1 = "9"
          p = p + chr(35)+chr(79)
      endcase
    CASE t = "8"
      t1 = substr(m,x+1,1)
      do case
        case t1 = "0"
          p = p + chr(49)+chr(93)
        case t1 = "1"
          p = p + chr(57)+chr(74)
        case t1 = "2"
          p = p + chr(51)+chr(74)
        case t1 = "3"
          p = p + chr(59)+chr(73)
        case t1 = "4"
          p = p + chr(49)+chr(90)
        case t1 = "5"
          p = p + chr(57)+chr(89)
        case t1 = "6"
          p = p + chr(51)+chr(89)
        case t1 = "7"
          p = p + chr(49)+chr(78)
        case t1 = "8"
          p = p + chr(57)+chr(77)
        case t1 = "9"
          p = p + chr(51)+chr(77)
      endcase
    CASE t = "9"
      t1 = substr(m,x+1,1)
      do case
        case t1 = "0"
          p = p + chr(37)+chr(93)
        case t1 = "1"
          p = p + chr(45)+chr(74)
        case t1 = "2"
          p = p + chr(39)+chr(74)
        case t1 = "3"
          p = p + chr(47)+chr(73)
        case t1 = "4"
          p = p + chr(37)+chr(90)
        case t1 = "5"
          p = p + chr(45)+chr(89)
        case t1 = "6"
          p = p + chr(39)+chr(89)
        case t1 = "7"
          p = p + chr(37)+chr(78)
        case t1 = "8"
          p = p + chr(45)+chr(77)
        case t1 = "9"
          p = p + chr(39)+chr(77)
      endcase
  endcase

endfor

*** Add stop code
p = p + chr(98)

*** Return the character pattern
return p
*-------



*-------
Procedure BC_InterCheck
Parameter msg
private bcc,bco

* Calculate and add the check character *
bcc = 0
bco = 0
for i = 1 to len(msg)
  bco = bco + val(substr(msg, i, 1)) * iif(mod(i,2) > 0,3,1)
endfor

bcc = mod(bco,10)

bcc = iif(bcc = 0,0,10-bcc)

*** Finish the UPC symbol.  Add the checksum character
msg = msg + str(bcc, 1)

return msg
*------------------------------------------------------------------------------------------------------------------------*



*------------------------------------------------------------------------------------------------------------------------*
*--- Code 128 Code Section

Procedure BC_Code128
Parameters m

*Call the option procedure with check character
rtnp = BC_OCode128(m,0,0,0)

return rtnp
*-------



*-------
Procedure BC_OCode128
Parameters m,fnc1,fnc2,fnc3
Private codeset,cset,shift,pfcn4,cont,s_char,cnt,rtncode,t,rtnc
Private fcn4,rcode

set talk off
codeset = 1
cset =1
shift = .f.
fcn4 = 1
pfcn4 = .f.
cont = .t.
dimension cvtarr[5,106]
dimension contarr[2,10]
s_char = chr(47)  && "/" character
cnt = 1
rtncode = ""

if fnc1 <> 1
  fnc1 = 0
endif
if fnc2 <> 1
  fnc2 = 0
endif
if fnc3 <> 1
  fnc3 = 0
endif

* Define the convertion array
cvtarr[1,1]="000"
cvtarr[2,1]=chr(32)
cvtarr[3,1]=chr(32)
cvtarr[4,1]="00"
cvtarr[5,1]=chr(37)+chr(38)+chr(38)
cvtarr[1,2]="001"
cvtarr[2,2]=chr(33)
cvtarr[3,2]=chr(33)
cvtarr[4,2]="01"
cvtarr[5,2]=chr(38)+chr(37)+chr(38)
cvtarr[1,3]="002"
cvtarr[2,3]=chr(34)
cvtarr[3,3]=chr(34)
cvtarr[4,3]="02"
cvtarr[5,3]=chr(38)+chr(38)+chr(37)
cvtarr[1,4]="003"
cvtarr[2,4]=chr(35)
cvtarr[3,4]=chr(35)
cvtarr[4,4]="03"
cvtarr[5,4]=chr(34)+chr(34)+chr(39)
cvtarr[1,5]="004"
cvtarr[2,5]=chr(36)
cvtarr[3,5]=chr(36)
cvtarr[4,5]="04"
cvtarr[5,5]=chr(34)+chr(35)+chr(38)
cvtarr[1,6]="005"
cvtarr[2,6]=chr(37)
cvtarr[3,6]=chr(37)
cvtarr[4,6]="05"
cvtarr[5,6]=chr(35)+chr(34)+chr(38)
cvtarr[1,7]="006"
cvtarr[2,7]=chr(38)
cvtarr[3,7]=chr(38)
cvtarr[4,7]="06"
cvtarr[5,7]=chr(34)+chr(38)+chr(35)
cvtarr[1,8]="007"
cvtarr[2,8]=chr(39)
cvtarr[3,8]=chr(39)
cvtarr[4,8]="07"
cvtarr[5,8]=chr(34)+chr(39)+chr(34)
cvtarr[1,9]="008"
cvtarr[2,9]=chr(40)
cvtarr[3,9]=chr(40)
cvtarr[4,9]="08"
cvtarr[5,9]=chr(35)+chr(38)+chr(34)
cvtarr[1,10]="009"
cvtarr[2,10]=chr(41)
cvtarr[3,10]=chr(41)
cvtarr[4,10]="09"
cvtarr[5,10]=chr(38)+chr(34)+chr(35)
cvtarr[1,11]="010"
cvtarr[2,11]=chr(42)
cvtarr[3,11]=chr(42)
cvtarr[4,11]="10"
cvtarr[5,11]=chr(38)+chr(35)+chr(34)
cvtarr[1,12]="011"
cvtarr[2,12]=chr(43)
cvtarr[3,12]=chr(43)
cvtarr[4,12]="11"
cvtarr[5,12]=chr(39)+chr(34)+chr(34)
cvtarr[1,13]="012"
cvtarr[2,13]=chr(44)
cvtarr[3,13]=chr(44)
cvtarr[4,13]="12"
cvtarr[5,13]=chr(33)+chr(38)+chr(42)
cvtarr[1,14]="013"
cvtarr[2,14]=chr(45)
cvtarr[3,14]=chr(45)
cvtarr[4,14]="13"
cvtarr[5,14]=chr(34)+chr(37)+chr(42)
cvtarr[1,15]="014"
cvtarr[2,15]=chr(46)
cvtarr[3,15]=chr(46)
cvtarr[4,15]="14"
cvtarr[5,15]=chr(34)+chr(38)+chr(41)
cvtarr[1,16]="015"
cvtarr[2,16]=chr(47)
cvtarr[3,16]=chr(47)
cvtarr[4,16]="15"
cvtarr[5,16]=chr(33)+chr(42)+chr(38)
cvtarr[1,17]="016"
cvtarr[2,17]=chr(48)
cvtarr[3,17]=chr(48)
cvtarr[4,17]="16"
cvtarr[5,17]=chr(34)+chr(41)+chr(38)
cvtarr[1,18]="017"
cvtarr[2,18]=chr(49)
cvtarr[3,18]=chr(49)
cvtarr[4,18]="17"
cvtarr[5,18]=chr(34)+chr(42)+chr(37)
cvtarr[1,19]="018"
cvtarr[2,19]=chr(50)
cvtarr[3,19]=chr(50)
cvtarr[4,19]="18"
cvtarr[5,19]=chr(38)+chr(42)+chr(33)
cvtarr[1,20]="019"
cvtarr[2,20]=chr(51)
cvtarr[3,20]=chr(51)
cvtarr[4,20]="19"
cvtarr[5,20]=chr(38)+chr(33)+chr(42)
cvtarr[1,21]="020"
cvtarr[2,21]=chr(52)
cvtarr[3,21]=chr(52)
cvtarr[4,21]="20"
cvtarr[5,21]=chr(38)+chr(34)+chr(41)
cvtarr[1,22]="021"
cvtarr[2,22]=chr(53)
cvtarr[3,22]=chr(53)
cvtarr[4,22]="21"
cvtarr[5,22]=chr(37)+chr(42)+chr(34)
cvtarr[1,23]="022"
cvtarr[2,23]=chr(54)
cvtarr[3,23]=chr(54)
cvtarr[4,23]="22"
cvtarr[5,23]=chr(38)+chr(41)+chr(34)
cvtarr[1,24]="023"
cvtarr[2,24]=chr(55)
cvtarr[3,24]=chr(55)
cvtarr[4,24]="23"
cvtarr[5,24]=chr(41)+chr(37)+chr(41)
cvtarr[1,25]="024"
cvtarr[2,25]=chr(56)
cvtarr[3,25]=chr(56)
cvtarr[4,25]="24"
cvtarr[5,25]=chr(41)+chr(34)+chr(38)
cvtarr[1,26]="025"
cvtarr[2,26]=chr(57)
cvtarr[3,26]=chr(57)
cvtarr[4,26]="25"
cvtarr[5,26]=chr(42)+chr(33)+chr(38)
cvtarr[1,27]="026"
cvtarr[2,27]=chr(58)
cvtarr[3,27]=chr(58)
cvtarr[4,27]="26"
cvtarr[5,27]=chr(42)+chr(34)+chr(37)
cvtarr[1,28]="027"
cvtarr[2,28]=chr(59)
cvtarr[3,28]=chr(59)
cvtarr[4,28]="27"
cvtarr[5,28]=chr(41)+chr(38)+chr(34)
cvtarr[1,29]="028"
cvtarr[2,29]=chr(60)
cvtarr[3,29]=chr(60)
cvtarr[4,29]="28"
cvtarr[5,29]=chr(42)+chr(37)+chr(34)
cvtarr[1,30]="029"
cvtarr[2,30]=chr(61)
cvtarr[3,30]=chr(61)
cvtarr[4,30]="29"
cvtarr[5,30]=chr(42)+chr(38)+chr(33)
cvtarr[1,31]="030"
cvtarr[2,31]=chr(62)
cvtarr[3,31]=chr(62)
cvtarr[4,31]="30"
cvtarr[5,31]=chr(37)+chr(37)+chr(39)
cvtarr[1,32]="031"
cvtarr[2,32]=chr(63)
cvtarr[3,32]=chr(63)
cvtarr[4,32]="31"
cvtarr[5,32]=chr(37)+chr(39)+chr(37)
cvtarr[1,33]="032"
cvtarr[2,33]=chr(64)
cvtarr[3,33]=chr(64)
cvtarr[4,33]="32"
cvtarr[5,33]=chr(39)+chr(37)+chr(37)
cvtarr[1,34]="033"
cvtarr[2,34]=chr(65)
cvtarr[3,34]=chr(65)
cvtarr[4,34]="33"
cvtarr[5,34]=chr(33)+chr(35)+chr(39)
cvtarr[1,35]="034"
cvtarr[2,35]=chr(66)
cvtarr[3,35]=chr(66)
cvtarr[4,35]="34"
cvtarr[5,35]=chr(35)+chr(33)+chr(39)
cvtarr[1,36]="035"
cvtarr[2,36]=chr(67)
cvtarr[3,36]=chr(67)
cvtarr[4,36]="35"
cvtarr[5,36]=chr(35)+chr(35)+chr(37)
cvtarr[1,37]="036"
cvtarr[2,37]=chr(68)
cvtarr[3,37]=chr(68)
cvtarr[4,37]="36"
cvtarr[5,37]=chr(33)+chr(39)+chr(35)
cvtarr[1,38]="037"
cvtarr[2,38]=chr(69)
cvtarr[3,38]=chr(69)
cvtarr[4,38]="37"
cvtarr[5,38]=chr(35)+chr(37)+chr(35)
cvtarr[1,39]="038"
cvtarr[2,39]=chr(70)
cvtarr[3,39]=chr(70)
cvtarr[4,39]="38"
cvtarr[5,39]=chr(35)+chr(39)+chr(33)
cvtarr[1,40]="039"
cvtarr[2,40]=chr(71)
cvtarr[3,40]=chr(71)
cvtarr[4,40]="39"
cvtarr[5,40]=chr(37)+chr(35)+chr(35)
cvtarr[1,41]="040"
cvtarr[2,41]=chr(72)
cvtarr[3,41]=chr(72)
cvtarr[4,41]="40"
cvtarr[5,41]=chr(39)+chr(33)+chr(35)
cvtarr[1,42]="041"
cvtarr[2,42]=chr(73)
cvtarr[3,42]=chr(73)
cvtarr[4,42]="41"
cvtarr[5,42]=chr(39)+chr(35)+chr(33)
cvtarr[1,43]="042"
cvtarr[2,43]=chr(74)
cvtarr[3,43]=chr(74)
cvtarr[4,43]="42"
cvtarr[5,43]=chr(33)+chr(37)+chr(43)
cvtarr[1,44]="043"
cvtarr[2,44]=chr(75)
cvtarr[3,44]=chr(75)
cvtarr[4,44]="43"
cvtarr[5,44]=chr(33)+chr(39)+chr(41)
cvtarr[1,45]="044"
cvtarr[2,45]=chr(76)
cvtarr[3,45]=chr(76)
cvtarr[4,45]="44"
cvtarr[5,45]=chr(35)+chr(37)+chr(41)
cvtarr[1,46]="045"
cvtarr[2,46]=chr(77)
cvtarr[3,46]=chr(77)
cvtarr[4,46]="45"
cvtarr[5,46]=chr(33)+chr(41)+chr(39)
cvtarr[1,47]="046"
cvtarr[2,47]=chr(78)
cvtarr[3,47]=chr(78)
cvtarr[4,47]="46"
cvtarr[5,47]=chr(33)+chr(43)+chr(37)
cvtarr[1,48]="047"
cvtarr[2,48]=chr(79)
cvtarr[3,48]=chr(79)
cvtarr[4,48]="47"
cvtarr[5,48]=chr(35)+chr(41)+chr(37)
cvtarr[1,49]="048"
cvtarr[2,49]=chr(80)
cvtarr[3,49]=chr(80)
cvtarr[4,49]="48"
cvtarr[5,49]=chr(41)+chr(41)+chr(37)
cvtarr[1,50]="049"
cvtarr[2,50]=chr(81)
cvtarr[3,50]=chr(81)
cvtarr[4,50]="49"
cvtarr[5,50]=chr(37)+chr(35)+chr(41)
cvtarr[1,51]="050"
cvtarr[2,51]=chr(82)
cvtarr[3,51]=chr(82)
cvtarr[4,51]="50"
cvtarr[5,51]=chr(39)+chr(33)+chr(41)
cvtarr[1,52]="051"
cvtarr[2,52]=chr(83)
cvtarr[3,52]=chr(83)
cvtarr[4,52]="51"
cvtarr[5,52]=chr(37)+chr(41)+chr(35)
cvtarr[1,53]="052"
cvtarr[2,53]=chr(84)
cvtarr[3,53]=chr(84)
cvtarr[4,53]="52"
cvtarr[5,53]=chr(37)+chr(43)+chr(33)
cvtarr[1,54]="053"
cvtarr[2,54]=chr(85)
cvtarr[3,54]=chr(85)
cvtarr[4,54]="53"
cvtarr[5,54]=chr(37)+chr(41)+chr(41)
cvtarr[1,55]="054"
cvtarr[2,55]=chr(86)
cvtarr[3,55]=chr(86)
cvtarr[4,55]="54"
cvtarr[5,55]=chr(41)+chr(33)+chr(39)
cvtarr[1,56]="055"
cvtarr[2,56]=chr(87)
cvtarr[3,56]=chr(87)
cvtarr[4,56]="55"
cvtarr[5,56]=chr(41)+chr(35)+chr(37)
cvtarr[1,57]="056"
cvtarr[2,57]=chr(88)
cvtarr[3,57]=chr(88)
cvtarr[4,57]="56"
cvtarr[5,57]=chr(43)+chr(33)+chr(37)
cvtarr[1,58]="057"
cvtarr[2,58]=chr(89)
cvtarr[3,58]=chr(89)
cvtarr[4,58]="57"
cvtarr[5,58]=chr(41)+chr(37)+chr(35)
cvtarr[1,59]="058"
cvtarr[2,59]=chr(90)
cvtarr[3,59]=chr(90)
cvtarr[4,59]="58"
cvtarr[5,59]=chr(41)+chr(39)+chr(33)
cvtarr[1,60]="059"
cvtarr[2,60]=chr(91)
cvtarr[3,60]=chr(91)
cvtarr[4,60]="59"
cvtarr[5,60]=chr(43)+chr(37)+chr(33)
cvtarr[1,61]="060"
cvtarr[2,61]=chr(92)
cvtarr[3,61]=chr(92)
cvtarr[4,61]="60"
cvtarr[5,61]=chr(41)+chr(45)+chr(33)
cvtarr[1,62]="061"
cvtarr[2,62]=chr(93)
cvtarr[3,62]=chr(93)
cvtarr[4,62]="61"
cvtarr[5,62]=chr(38)+chr(36)+chr(33)
cvtarr[1,63]="062"
cvtarr[2,63]=chr(94)
cvtarr[3,63]=chr(94)
cvtarr[4,63]="62"
cvtarr[5,63]=chr(47)+chr(33)+chr(33)
cvtarr[1,64]="063"
cvtarr[2,64]=chr(95)
cvtarr[3,64]=chr(95)
cvtarr[4,64]="63"
cvtarr[5,64]=chr(33)+chr(34)+chr(40)
cvtarr[1,65]="064"
cvtarr[2,65]=chr(0)
cvtarr[3,65]=chr(96)
cvtarr[4,65]="64"
cvtarr[5,65]=chr(33)+chr(36)+chr(38)
cvtarr[1,66]="065"
cvtarr[2,66]=chr(1)
cvtarr[3,66]=chr(97)
cvtarr[4,66]="65"
cvtarr[5,66]=chr(34)+chr(33)+chr(40)
cvtarr[1,67]="066"
cvtarr[2,67]=chr(2)
cvtarr[3,67]=chr(98)
cvtarr[4,67]="66"
cvtarr[5,67]=chr(34)+chr(36)+chr(37)
cvtarr[1,68]="067"
cvtarr[2,68]=chr(3)
cvtarr[3,68]=chr(99)
cvtarr[4,68]="67"
cvtarr[5,68]=chr(36)+chr(33)+chr(38)
cvtarr[1,69]="068"
cvtarr[2,69]=chr(4)
cvtarr[3,69]=chr(100)
cvtarr[4,69]="68"
cvtarr[5,69]=chr(36)+chr(34)+chr(37)
cvtarr[1,70]="069"
cvtarr[2,70]=chr(5)
cvtarr[3,70]=chr(101)
cvtarr[4,70]="69"
cvtarr[5,70]=chr(33)+chr(38)+chr(36)
cvtarr[1,71]="070"
cvtarr[2,71]=chr(6)
cvtarr[3,71]=chr(102)
cvtarr[4,71]="70"
cvtarr[5,71]=chr(33)+chr(40)+chr(34)
cvtarr[1,72]="071"
cvtarr[2,72]=chr(7)
cvtarr[3,72]=chr(103)
cvtarr[4,72]="71"
cvtarr[5,72]=chr(34)+chr(37)+chr(36)
cvtarr[1,73]="072"
cvtarr[2,73]=chr(8)
cvtarr[3,73]=chr(104)
cvtarr[4,73]="72"
cvtarr[5,73]=chr(34)+chr(40)+chr(33)
cvtarr[1,74]="073"
cvtarr[2,74]=chr(9)
cvtarr[3,74]=chr(105)
cvtarr[4,74]="73"
cvtarr[5,74]=chr(36)+chr(37)+chr(34)
cvtarr[1,75]="074"
cvtarr[2,75]=chr(10)
cvtarr[3,75]=chr(106)
cvtarr[4,75]="74"
cvtarr[5,75]=chr(36)+chr(38)+chr(33)
cvtarr[1,76]="075"
cvtarr[2,76]=chr(11)
cvtarr[3,76]=chr(107)
cvtarr[4,76]="75"
cvtarr[5,76]=chr(40)+chr(34)+chr(33)
cvtarr[1,77]="076"
cvtarr[2,77]=chr(12)
cvtarr[3,77]=chr(108)
cvtarr[4,77]="76"
cvtarr[5,77]=chr(38)+chr(33)+chr(36)
cvtarr[1,78]="077"
cvtarr[2,78]=chr(13)
cvtarr[3,78]=chr(109)
cvtarr[4,78]="77"
cvtarr[5,78]=chr(45)+chr(41)+chr(33)
cvtarr[1,79]="078"
cvtarr[2,79]=chr(14)
cvtarr[3,79]=chr(110)
cvtarr[4,79]="78"
cvtarr[5,79]=chr(40)+chr(33)+chr(34)
cvtarr[1,80]="079"
cvtarr[2,80]=chr(15)
cvtarr[3,80]=chr(111)
cvtarr[4,80]="79"
cvtarr[5,80]=chr(35)+chr(45)+chr(33)
cvtarr[1,81]="080"
cvtarr[2,81]=chr(16)
cvtarr[3,81]=chr(112)
cvtarr[4,81]="80"
cvtarr[5,81]=chr(33)+chr(34)+chr(46)
cvtarr[1,82]="081"
cvtarr[2,82]=chr(17)
cvtarr[3,82]=chr(113)
cvtarr[4,82]="81"
cvtarr[5,82]=chr(34)+chr(33)+chr(46)
cvtarr[1,83]="082"
cvtarr[2,83]=chr(18)
cvtarr[3,83]=chr(114)
cvtarr[4,83]="82"
cvtarr[5,83]=chr(34)+chr(34)+chr(45)
cvtarr[1,84]="083"
cvtarr[2,84]=chr(19)
cvtarr[3,84]=chr(115)
cvtarr[4,84]="83"
cvtarr[5,84]=chr(33)+chr(46)+chr(34)
cvtarr[1,85]="084"
cvtarr[2,85]=chr(20)
cvtarr[3,85]=chr(116)
cvtarr[4,85]="84"
cvtarr[5,85]=chr(34)+chr(45)+chr(34)
cvtarr[1,86]="085"
cvtarr[2,86]=chr(21)
cvtarr[3,86]=chr(117)
cvtarr[4,86]="85"
cvtarr[5,86]=chr(34)+chr(46)+chr(33)
cvtarr[1,87]="086"
cvtarr[2,87]=chr(22)
cvtarr[3,87]=chr(118)
cvtarr[4,87]="86"
cvtarr[5,87]=chr(45)+chr(34)+chr(34)
cvtarr[1,88]="087"
cvtarr[2,88]=chr(23)
cvtarr[3,88]=chr(119)
cvtarr[4,88]="87"
cvtarr[5,88]=chr(46)+chr(33)+chr(34)
cvtarr[1,89]="088"
cvtarr[2,89]=chr(24)
cvtarr[3,89]=chr(120)
cvtarr[4,89]="88"
cvtarr[5,89]=chr(46)+chr(34)+chr(33)
cvtarr[1,90]="089"
cvtarr[2,90]=chr(25)
cvtarr[3,90]=chr(121)
cvtarr[4,90]="89"
cvtarr[5,90]=chr(37)+chr(37)+chr(45)
cvtarr[1,91]="090"
cvtarr[2,91]=chr(26)
cvtarr[3,91]=chr(122)
cvtarr[4,91]="90"
cvtarr[5,91]=chr(37)+chr(45)+chr(37)
cvtarr[1,92]="091"
cvtarr[2,92]=chr(27)
cvtarr[3,92]=chr(123)
cvtarr[4,92]="91"
cvtarr[5,92]=chr(45)+chr(37)+chr(37)
cvtarr[1,93]="092"
cvtarr[2,93]=chr(28)
cvtarr[3,93]=chr(124)
cvtarr[4,93]="92"
cvtarr[5,93]=chr(33)+chr(33)+chr(47)
cvtarr[1,94]="093"
cvtarr[2,94]=chr(29)
cvtarr[3,94]=chr(125)
cvtarr[4,94]="93"
cvtarr[5,94]=chr(33)+chr(35)+chr(45)
cvtarr[1,95]="094"
cvtarr[2,95]=chr(30)
cvtarr[3,95]=chr(126)
cvtarr[4,95]="94"
cvtarr[5,95]=chr(35)+chr(33)+chr(45)
cvtarr[1,96]="095"
cvtarr[2,96]=chr(31)
cvtarr[3,96]=chr(127)
cvtarr[4,96]="95"
cvtarr[5,96]=chr(33)+chr(45)+chr(35)
cvtarr[1,97]="096"
cvtarr[2,97]=""
cvtarr[3,97]=""
cvtarr[4,97]="96"
cvtarr[5,97]=chr(33)+chr(47)+chr(33)
cvtarr[1,98]="097"
cvtarr[2,98]=""
cvtarr[3,98]=""
cvtarr[4,98]="97"
cvtarr[5,98]=chr(45)+chr(33)+chr(35)
cvtarr[1,99]="098"
cvtarr[2,99]=""
cvtarr[3,99]=""
cvtarr[4,99]="98"
cvtarr[5,99]=chr(45)+chr(35)+chr(33)
cvtarr[1,100]="099"
cvtarr[2,100]=""
cvtarr[3,100]=""
cvtarr[4,100]="99"
cvtarr[5,100]=chr(33)+chr(41)+chr(45)
cvtarr[1,101]="100"
cvtarr[2,101]=""
cvtarr[3,101]=""
cvtarr[4,101]=""
cvtarr[5,101]=chr(33)+chr(45)+chr(41)
cvtarr[1,102]="101"
cvtarr[2,102]=""
cvtarr[3,102]=""
cvtarr[4,102]=""
cvtarr[5,102]=chr(41)+chr(33)+chr(45)
cvtarr[1,103]="102"
cvtarr[2,103]=""
cvtarr[3,103]=""
cvtarr[4,103]=""
cvtarr[5,103]=chr(45)+chr(33)+chr(41)
cvtarr[1,104]="103"
cvtarr[2,104]=""
cvtarr[3,104]=""
cvtarr[4,104]=""
cvtarr[5,104]=chr(37)+chr(36)+chr(34)
cvtarr[1,105]="104"
cvtarr[2,105]=""
cvtarr[3,105]=""
cvtarr[4,105]=""
cvtarr[5,105]=chr(37)+chr(34)+chr(36)
cvtarr[1,106]="105"
cvtarr[2,106]=""
cvtarr[3,106]=""
cvtarr[4,106]=""
cvtarr[5,106]=chr(37)+chr(34)+chr(42)

* private chkcnt = 0
* private chktot = 0
chkcnt = 0
chktot = 0

*** check the character string and optimize the structure
m = chrcheck(m,fnc1,fnc2,fnc3)

do while cont
  t = substr(m,cnt,1)
  do case
    case t = s_char
      rtnc = substr(m,cnt+1,1)
*  remove this
*     if rtnc = "#"
*       rtnc = asubscript(contarr,ascan(contarr,t,aelement(contarr,2,1),10),2)
*     endif
      do case
        case rtnc == chr(98)
          shift = .t.
          rtncode = rtncode + cvtarr[5,99]
          chktot = chktot + (chkcnt * 98)
          chkcnt = chkcnt + 1
        case rtnc == chr(99)
          codeset = 3
          rtncode = rtncode + cvtarr[5,100]
          chktot = chktot + (chkcnt * 99)
          chkcnt = chkcnt + 1
        case rtnc == chr(100)
          codeset = 2
          rtncode = rtncode + cvtarr[5,101]
          chktot = chktot + (chkcnt * 100)
          chkcnt = chkcnt + 1
        case rtnc == chr(101)
          codeset = 1
          rtncode = rtncode + cvtarr[5,102]
          chktot = chktot + (chkcnt * 101)
          chkcnt = chkcnt + 1
        case rtnc == chr(103)
          codeset = 1
          rtncode = rtncode + cvtarr[5,104]
          chktot = chktot + 103
          chkcnt = chkcnt + 1
        case rtnc == chr(104)
          codeset = 2
          rtncode = rtncode + cvtarr[5,105]
          chktot = chktot + 104
          chkcnt = chkcnt + 1
        case rtnc == chr(105)
          codeset = 3
          rtncode = rtncode + cvtarr[5,106]
          chktot = chktot + 105
          chkcnt = chkcnt + 1
      endcase

      if (rtnc = chr(100) .and. codeset = 2) .or. ;
         (rtnc = chr(101) .and. codeset = 1)
         fcn4 = iif(fcn4 < 4,fcn4 + 1,1)
      endif
      cnt = cnt + 2

    case codeset = 3 .and. asc(t) >= asc("0") .and. asc(t) <= asc("9")
      t = substr(m,cnt,2)
      rtnc = asubscript(cvtarr,ascan(cvtarr,t,aelement(cvtarr,4,1),106),2)
      if rtnc <> 0
        rtncode = rtncode + cvtarr[5,rtnc]
        chktot = chktot + (chkcnt * val(cvtarr[1,rtnc]))
        chkcnt = chkcnt + 1
      endif
      cnt = cnt + 2
      shift = .f.

    otherwise
      if fcn4 > 1
        if fcn4 = 4
          t = chr(asc(t) - 128)
        endif
        fcn4 = iif(fcn4 == 2,1,3)
      endif
      cset = iif(shift,iif(codeset == 1,2,1),codeset)
      rtnc = asubscript(cvtarr,ascan(cvtarr,t,aelement(cvtarr,cset+1,1),100),2)
      if rtnc <> 0
        rtncode = rtncode + cvtarr[5,rtnc]
        chktot = chktot + (chkcnt * val(cvtarr[1,rtnc]))
        chkcnt = chkcnt + 1
      endif
      cnt = cnt + 1
      shift = .f.
  endcase
  cont = iif(cnt > len(m),.f.,.t.)
enddo

*** add check digit
* calculate the check digit
rtnc = asubscript(cvtarr,ascan(cvtarr,padl(ltrim(str(mod(chktot,103),3,0)),3,"0"),;
             aelement(cvtarr,1,1),106),2)

if rtnc > 0
  * add check digit and stop code
  rtncode = rtncode+cvtarr[5,rtnc]+chr(39)+chr(41)+chr(33)+chr(49)
endif

** return the character pattern

return rtncode
*-------



*-------
Procedure BC_128CHR
Parameters ch
Private s_char
s_char = chr(128)
return s_char+s_char+chr(ch-96)
*-------



*-------
Procedure chrcheck
Parameter m,fnc1,fnc2,fnc3
private i,tstr,rtnstr,codeset,cset,shift,fcn4,pfcn4,cont,numchr,malen

codeset = 1
cset =1
shift = .f.
fcn4 = 1
pfcn4 = .f.
numchr = 0

if substr(m,1,1) = "/"
  return m
endif

** place the message string in an array
dimension ma(len(m))
for i = 1 to len(m)
  ma[i] = substr(m,i,1)
endfor
malen = alen(ma)

rtnstr = ""

ncodec = tcode(@ma,malen,1,3)

*** calculate start code
do case
  case malen = 2 .and. ncodec = 2
    rtnstr = "/"+chr(105)
    codeset = 3

  case ncodec >= 4

   if chrodd(ncodec)
     rtnstr = "/" + chr(104)
     codeset = 2
   else
     rtnstr = "/" + chr(105)
     codeset = 3
   endif

  otherwise
    cont = .t.
    i = 1
    do while cont
      do case
        case chrbtwn(ma[i],chr(0),chr(31))
          cont = .f.
          rtnstr = "/"+chr(103)
          codeset = 1
        case chrbtwn(ma[i],chr(96),chr(127))
          cont = .f.
          rtnstr = "/"+chr(104)
          codeset = 2
      endcase
      i = i + 1
      if malen < i .and. cont
        cont = .f.
        rtnstr = "/"+chr(104)
        codeset = 2
      endif
    enddo
endcase

if fnc1 = 1
  rtnstr = rtnstr + "/" + chr(102)
endif
if fnc2 = 1
  rtnstr = rtnstr + "/" + chr(97)
endif
if fnc3 = 1
  rtnstr = rtnstr + "/" + chr(96)
endif

*** convert the message
cont = .t.
i = 1
do while cont
  ** process until code change is necessary
  do case
    case codeset = 1
      numchr = tcode(@ma, malen, i, 1)
      for k = 1 to numchr
        rtnstr = rtnstr + ma[i]
        i = i + 1
      endfor
    case codeset = 2
      numchr = tcode(@ma,malen,i,2)
      for k = 1 to numchr
        rtnstr = rtnstr + ma[i]
        i = i + 1
      endfor
    case codeset = 3
      numchr = tcode(@ma,malen,i,3)
      for k = 1 to numchr
        rtnstr = rtnstr + ma[i]
        i = i + 1
      endfor
  endcase

  if i > malen
    ** hit end of string
    cont = .f.
  endif

  ** process code change
  if cont
    do case
      case codeset = 1
        do case
          case chrbtwn(ma[i],"0","9")
            numchr = tcode(@ma,malen,i,3)
            if numchr >= 4
              if chrodd(numchr)
                rtnstr = rtnstr + ma[i] + "/" + chr(99)
                codeset = 3
                i = i + 1
              else
                rtnstr = rtnstr + "/" + chr(99)
                codeset = 3
              endif
            else
              for k = 1 to numchr
                rtnstr = rtnstr + ma[i]
                i = i + 1
              endfor
            endif
          otherwise
            * next char must be code set 2
            if i+1 <= malen
              do nxtab with ma,i+1,numchr
              if numchr = 1
                rtnstr = rtnstr + "/" + chr(98) + ma[i]
                i = i + 1
              else
                rtnstr = rtnstr + "/" + chr(100)
                codeset = 2
              endif
            else
              rtnstr = rtnstr + "/" + chr(100)
              codeset = 2
            endif
        endcase
      case codeset = 2
        do case
          case chrbtwn(ma[i],"0","9")
            numchr = tcode(@ma,malen,i,3)
            if numchr >= 4
              if chrodd(numchr)
                rtnstr = rtnstr + ma[i] + "/" + chr(99)
                codeset = 3
                i = i + 1
              else
                rtnstr = rtnstr + "/" + chr(99)
                codeset = 3
              endif
            else
              for k = 1 to numchr
                rtnstr = rtnstr + ma[i]
                i = i + 1
              endfor
            endif
          otherwise
            * next char must be code set 1
            if i+1 <= malen
              do nxtab with ma,i,numchr
              if numchr = 2
                rtnstr = rtnstr + "/" + chr(98) + ma[i]
                i = i + 1
              else
                rtnstr = rtnstr + "/" + chr(101)
                codeset = 1
              endif
            else
              rtnstr = rtnstr + "/" + chr(101)
              codeset = 1
            endif
        endcase
      case codeset = 3
        do nxtab with ma,i,numchr
        if numchr = 1
          rtnstr = rtnstr + "/" + chr(101)
          codeset = 1
        else
          rtnstr = rtnstr + "/" + chr(100)
          codeset = 2
        endif
    endcase
  endif
  
  if i > malen
    ** hit end of string
    cont = .f.
  endif
  
enddo
return rtnstr
*-------



*-------
Procedure chrbtwn
parameters c,b,e
return iif(asc(c)>=asc(b) .and. asc(c) <= asc(e),.t.,.f.)
*-------



*-------
Procedure tcode
parameters ma, strl, i, cset, retnum

private cont,j

j = i
cont = .t.
retnum = 0
do case
  case cset = 1
    do while cont
      nstr = asc(ma[j])
      if (nstr >= 0 .and. nstr <= 47) .or. (nstr >= 58 .and. nstr <= 95)
        retnum = retnum + 1
        j = j + 1
      else
        if (nstr >= 48 .and. nstr <= 57)
          nchr = tcode(@ma,strl,j,3)
          if (nchr >= 4)
            if chrodd(nchr)
              retnum = retnum + 1
            endif
            cont = .f.
          else
            for k = 1 to nchr
              retnum = retnum + 1
              j = j + 1
            endfor
          endif
        else
          cont = .f.
        endif
      endif

      if j > strl
        cont = .f.
      endif
    enddo
  case cset = 2
    do while cont
      nstr = asc(ma[j])
      if (nstr >= 32 .and. nstr <= 47) .or. (nstr >= 58 .and. nstr <= 127)
        retnum = retnum + 1
        j = j + 1
      else
        if nstr >= 48 .and. nstr <= 57
          nchr = tcode(@ma,strl,j,3)
          if (nchr >= 4)
            if chrodd(nchr)
              retnum = retnum + 1
            endif
            cont = .f.
          else
            for k = 1 to nchr
              retnum = retnum + 1
              j = j + 1
            endfor
          endif
        else
          cont = .f.
        endif
      endif
      if j >= strl
        cont = .f.
      endif
    enddo
  case cset = 3
    * this does not check for an even # of char
    do while cont
      nstr = asc(ma[j])
      if nstr >= 48 .and. nstr <= 57
        retnum = retnum + 1
        j = j + 1
      else
        cont = .f.
      endif

      if j > strl
        cont = .f.
      endif
    enddo

endcase
return retnum
*-------



*-------
Procedure nxtab
parameters carr,c,retnum
private i,cont

i = c
cont = .t.
retnum = 0
do while cont
  do case
    case asc(carr[i]) >= 96 .and. asc(carr[i]) <= 127
      retnum = 2
      return
    case asc(carr[i]) >= 0 .and. asc(carr[i]) <= 31
      retnum = 1
      return 1
  endcase
  i = i + 1
  if i > alen(carr)
    retnum = 0
    return
  endif
enddo
retnum = 0
return
*-------



*-------
Procedure chrodd
parameters c
return iif(c%2>0,.t.,.f.)
*-------



*------------------------------------------------------------------------------------------------------------------------*
*--- PostNet Code Section

Procedure BC_PostNet
Parameters m
private sh,lb,t,x,p
set talk off
* Generates bar character pattern for PostNet bar codes
*    m  = text to decode into a character pattern
*
* Returns:
*    Bar pattern for PostNet bar code.
*    If an illegal value is found then a null will
*    be returned to the user.

*** if the parameter is not a character then quit
if type('m')<>"C"
  return ""
endif

*** encode message into bar code character pattern and place
*** it into the variable
*** initialize variable and add start code
p="*"

*** add check digit character
m = BC_PNCheck(m)

FOR x = 1 TO len(m)
  t = substr(m, x, 1)

  do case
    CASE t = "0"
      p = p + "0"
    CASE t = "1"
      p = p + "1"
    CASE t = "2"
      p = p + "2"
    CASE t = "3"
      p = p + "3"
    CASE t = "4"
      p = p + "4"
    CASE t = "5"
      p = p + "5"
    CASE t = "6"
      p = p + "6"
    CASE t = "7"
      p = p + "7"
    CASE t = "8"
      p = p + "8"
    CASE t = "9"
      p = p + "9"
    otherwise
      *** Invalid code found
      return ""
  endcase
endfor

*** add stop character
p = p + "*"

*** Return the character pattern
return p
*-------



*-------
Procedure BC_PNCheck
Parameter msg
Private bcc,i,msg

* Calculate and add the check character *
bcc = 0
for i = 1 to len(msg)
  bcc = bcc + val(substr(msg, i, 1))
endfor

bcc = iif(bcc%10 = 0,0,10 - (bcc % 10))

*** Finish the UPC symbol.  Add the checksum character
msg = msg + str(bcc, 1)
return msg
*-------



*------------------------------------------------------------------------------------------------------------------------*
*--- CodaBar Code Section

Procedure BC_Codabar
Parameters m

*Call the option procedure with check character
rtnp = BC_OCodabar(m,"A","B",1)

return rtnp

Procedure BC_OCodaBar
Parameters m,strt,stp,chk
private sh,lb,t,x,p
set talk off
* Generates bar character pattern for Codabar bar codes
*    m  = text to decode into a character pattern
*
* Returns:
*    Bar pattern for Codeabar bar code.
*    If an illegal value is found then a null will
*    be returned to the user.

*** if the parameter is not a character then quit
if type('m')<>"C"
  return ""
endif

* establish whether or not there should be a check character
if parameters() > 1
  if chk <> 0
    chk = 1
  endif
else
  chk = 1
endif

* establish what the start and endcodes should be
if !empty(strt)
  if strt < "A" .or. strt > "D"
    strt = "A"
  endif
else
  strt = "A"
endif

if !empty(stp)
  if stp < "A" .or. stp > "D"
    stp = "B"
  endif
else
  stp = "B"
endif


*** encode message into bar code character pattern and place
*** it into the variable
*** initialize variable and add start code
p=""

*** add check digit character
if chk = 1
  m = BC_CBCheck(strt+m+stp)
else
  m = strt + m + stp
endif

FOR x = 1 TO len(m)
  t = substr(m, x, 1)

  do case
    CASE t = "0"
      p = p + "0"
    CASE t = "1"
      p = p + "1"
    CASE t = "2"
      p = p + "2"
    CASE t = "3"
      p = p + "3"
    CASE t = "4"
      p = p + "4"
    CASE t = "5"
      p = p + "5"
    CASE t = "6"
      p = p + "6"
    CASE t = "7"
      p = p + "7"
    CASE t = "8"
      p = p + "8"
    CASE t = "9"
      p = p + "9"
    CASE t = "-"
      p = p + "-"
    CASE t = "$"
      p = p + "$"
    CASE t = ":"
      p = p + ":"
    CASE t = "/"
      p = p + "/"
    CASE t = "."
      p = p + "."
    CASE t = "+"
      p = p + "+"
    CASE t = "A"
      p = p + "A"
    CASE t = "B"
      p = p + "B"
    CASE t = "C"
      p = p + "C"
    CASE t = "D"
      p = p + "D"

    otherwise
      *** Invalid code found
      return ""
  endcase
endfor

*** Return the character pattern
return p
*-------



*-------
Procedure BC_CBCheck
Parameter msg
Private bcc,i,msg

* Calculate and add the check character *
bcc = 0
for i = 1 to len(msg)
  bcc = bcc + cbval(substr(msg, i, 1))
endfor

bcc = cbchr(iif(bcc % 16 = 0,0,16 - (bcc % 16)))

*** Finish the Codabar symbol.  Add the checksum character
msg = substr(msg,1,len(msg)-1) + bcc + substr(msg,len(msg),1)
return msg
*-------



*-------
Procedure cbval
Parameter ckval
Private ckval

do case
  case asc(ckval) >= 48 .and. asc(ckval) <= 57
    retval=val(ckval)
  case ckval = "-"
    retval=10
  case ckval = "$"
    retval=11
  case ckval = ":"
    retval=12
  case ckval = "/"
    retval=13
  case ckval = "."
    retval=14
  case ckval = "+"
    retval=15
  case ckval = "A"
    retval=16
  case ckval = "B"
    retval=17
  case ckval = "C"
    retval=18
  case ckval = "D"
    retval=19
endcase

return retval
*-------



*-------
Procedure cbchr
Parameter ckval
Private ckval

do case
  case ckval >= 0 .and. ckval <= 9
    retval=chr(ckval+48)
  case ckval = 10
    retval="-"
  case ckval = 11
    retval="$"
  case ckval = 12
    retval=":"
  case ckval = 13
    retval="/"
  case ckval = 14
    retval="."
  case ckval = 15
    retval="+"
  case ckval = 16
    retval="A"
  case ckval = 17
    retval="B"
  case ckval = 18
    retval="C"
  case ckval = 19
    retval="D"
endcase

return retval
*-------



*------------------------------------------------------------------------------------------------------------------------*
*--- UPC A Code Section

Procedure BC_UPCA
Parameters m
private sh,lb,t,x,p
set talk off
* Generates bar character pattern for Codabar bar codes
*    m  = text to decode into a character pattern
*
* Returns:
*    Bar pattern for UPC A bar code.
*    If an illegal value is found then a null will
*    be returned to the user.

*** if the parameter is not a character then quit
if type('m')<>"C"
  return ""
endif

*** encode message into bar code character pattern and place
*** it into the variable
*** initialize variable and add start code
p=chr(46)

*** add check digit character
m = BC_UPCACheck(m)

FOR x = 1 TO len(m)
  t = substr(m, x, 1)

  do case
    CASE t = "0"
      p = p + iif(x < 7,"0",chr(58))
    CASE t = "1"
      p = p + iif(x < 7,"1",chr(59))
    CASE t = "2"
      p = p + iif(x < 7,"2",chr(60))
    CASE t = "3"
      p = p + iif(x < 7,"3",chr(61))
    CASE t = "4"
      p = p + iif(x < 7,"4",chr(62))
    CASE t = "5"
      p = p + iif(x < 7,"5",chr(63))
    CASE t = "6"
      p = p + iif(x < 7,"6",chr(64))
    CASE t = "7"
      p = p + iif(x < 7,"7",chr(65))
    CASE t = "8"
      p = p + iif(x < 7,"8",chr(66))
    CASE t = "9"
      p = p + iif(x < 7,"9",chr(67))

    otherwise
      *** Invalid code found
      return ""
  endcase
  if x = 6
    p = p + chr(47)
  endif
endfor

* Add the stop code
p = p + chr(46)

*** Return the character pattern
return p
*-------



*-------
Procedure BC_UPCACheck
Parameter msg
Private bcc,i,msg

* Calculate and add the check character *
bcc = 0
for i = 1 to len(msg)
  bcc = bcc + iif(i%2=0,val(substr(msg, i, 1)),val(substr(msg,i,1))*3)
endfor

msg = msg + alltrim(str(iif(bcc % 10 = 0,0,10 - (bcc % 10))))

return msg
*-------



*------------------------------------------------------------------------------------------------------------------------*
*--- UPC E Code Section

Procedure BC_UPCE
Parameters m
private sh,lb,t,x,p,chkstr
set talk off
* Generates bar character pattern for UPC E bar codes
*    m  = text to decode into a character pattern
*
* Returns:
*    Bar pattern for UPC E bar code.
*    If an illegal value is found then a null will
*    be returned to the user.

*** if the parameter is not a character then quit
if type('m')<>"C"
  return ""
endif

* the message must be 6 digits
if len(m) < 6
  return ""
endif
if len(m) > 6
  m = substr(m,len(m)-5,6)
endif

*** encode message into bar code character pattern and place
*** it into the variable
*** initialize variable and add start code
p=chr(46)

* decode the UPC E string
chkstr = BC_UPCEcode(m)

*** calculate the check digit character
chkchr = BC_UPCECheck(chkstr)

dimension upcestr(10)
upcestr[1] = "EEOEOO"
upcestr[2] = "EEOOEO"
upcestr[3] = "EEOOOE"
upcestr[4] = "EOEEOO"
upcestr[5] = "EOOEEO"
upcestr[6] = "EOOOEE"
upcestr[7] = "EOEOEO"
upcestr[8] = "EOEOOE"
upcestr[9] = "EOOEOE"
upcestr[10] = "EEEOOO"

nval = val(chkchr)
if nval = 0
  nval = 10
endif

FOR x = 1 TO len(m)
  t = substr(m, x, 1)

  do case
    CASE t = "0"
      p = p + iif(substr(upcestr[nval],x,1)="O",chr(48),chr(68))
    CASE t = "1"
      p = p + iif(substr(upcestr[nval],x,1)="O",chr(49),chr(69))
    CASE t = "2"
      p = p + iif(substr(upcestr[nval],x,1)="O",chr(50),chr(70))
    CASE t = "3"
      p = p + iif(substr(upcestr[nval],x,1)="O",chr(51),chr(71))
    CASE t = "4"
      p = p + iif(substr(upcestr[nval],x,1)="O",chr(52),chr(72))
    CASE t = "5"
      p = p + iif(substr(upcestr[nval],x,1)="O",chr(53),chr(73))
    CASE t = "6"
      p = p + iif(substr(upcestr[nval],x,1)="O",chr(54),chr(74))
    CASE t = "7"
      p = p + iif(substr(upcestr[nval],x,1)="O",chr(55),chr(75))
    CASE t = "8"
      p = p + iif(substr(upcestr[nval],x,1)="O",chr(56),chr(76))
    CASE t = "9"
      p = p + iif(substr(upcestr[nval],x,1)="O",chr(57),chr(77))
    otherwise
      *** Invalid code found
      return ""
  endcase
endfor

* Add the stop code
p = p + chr(45)

*** Return the character pattern
return p
*-------



*-------
Procedure BC_UPCECode
Parameter msg
Private bcc,rtnmsg

* Decode the UPC E string to the full UPC A equivalent
bcc = substr(msg,6,1)

do case
  case bcc = "0" .or. bcc = "1" .or. bcc = "2"
    rtnmsg = "0"+substr(msg,1,2)+substr(msg,6,1)+"0000"+substr(msg,3,3)
  case bcc = "3"
    rtnmsg = "0"+substr(msg,1,3)+"00000"+substr(msg,4,2)
  case bcc = "4"
    rtnmsg = "0"+substr(msg,1,4)+"00000"+substr(msg,5,1)
  otherwise
    rtnmsg = "0"+substr(msg,1,5)+"0000"+substr(msg,6,1)
endcase

return rtnmsg
*-------



*-------
Procedure BC_UPCECheck
Parameter msg
Private bcc,i,rtnmsg

* Calculate and add the check character *
bcc = 0
for i = 1 to len(msg)
  bcc = bcc + iif(i%2=0,val(substr(msg, i, 1)),val(substr(msg,i,1))*3)
endfor

rtnmsg = alltrim(str(iif(bcc % 10 = 0,0,10 - (bcc % 10))))

return rtnmsg
*-------



*------------------------------------------------------------------------------------------------------------------------*
*--- EAN 13 Code Section

Procedure BC_EAN13
Parameters m
private sh,lb,t,x,p,chk
set talk off
* Generates bar character pattern for EAN 13 bar codes
*    m  = text to decode into a character pattern
*
* Returns:
*    Bar pattern for EAN 13 bar code.
*    If an illegal value is found then a null will
*    be returned to the user.

dimension eanstr(10)
eanstr[1] = "OOEOEE"
eanstr[2] = "OOEEOE"
eanstr[3] = "OOEEEO"
eanstr[4] = "OEOOEE"
eanstr[5] = "OEEOOE"
eanstr[6] = "OEEEOO"
eanstr[7] = "OEOEOE"
eanstr[8] = "OEOEEO"
eanstr[9] = "OEEOEO"
eanstr[10] = "OOOOOO"

*** if the parameter is not a character then quit
if type('m')<>"C"
  return ""
endif

*** encode message into bar code character pattern and place
*** it into the variable
*** initialize variable and add start code
p=chr(46)

*** add check digit character
IF LEN(m)=12
	m = BC_EAN13Check(m)
ENDIF

nval = val(substr(m,1,1))
if nval = 0
  nval = 10
endif

FOR x = 2 TO len(m)
  t = substr(m, x, 1)

  do case
    CASE t = "0"
      p = p + iif(x < 8,iif(substr(eanstr[nval],x-1,1)="O",chr(48),chr(68)),chr(58))
    CASE t = "1"
      p = p + iif(x < 8,iif(substr(eanstr[nval],x-1,1)="O",chr(49),chr(69)),chr(59))
    CASE t = "2"
      p = p + iif(x < 8,iif(substr(eanstr[nval],x-1,1)="O",chr(50),chr(70)),chr(60))
    CASE t = "3"
      p = p + iif(x < 8,iif(substr(eanstr[nval],x-1,1)="O",chr(51),chr(71)),chr(61))
    CASE t = "4"
      p = p + iif(x < 8,iif(substr(eanstr[nval],x-1,1)="O",chr(52),chr(72)),chr(62))
    CASE t = "5"
      p = p + iif(x < 8,iif(substr(eanstr[nval],x-1,1)="O",chr(53),chr(73)),chr(63))
    CASE t = "6"
      p = p + iif(x < 8,iif(substr(eanstr[nval],x-1,1)="O",chr(54),chr(74)),chr(64))
    CASE t = "7"
      p = p + iif(x < 8,iif(substr(eanstr[nval],x-1,1)="O",chr(55),chr(75)),chr(65))
    CASE t = "8"
      p = p + iif(x < 8,iif(substr(eanstr[nval],x-1,1)="O",chr(56),chr(76)),chr(66))
    CASE t = "9"
      p = p + iif(x < 8,iif(substr(eanstr[nval],x-1,1)="O",chr(57),chr(77)),chr(67))

    otherwise
      *** Invalid code found
      return ""
  endcase
  if x = 7
    p = p + chr(47)
  endif
endfor

* Add the stop code
p = p + chr(46)

*** Return the character pattern
return p
*-------



*-------
Procedure BC_EAN13Check
Parameter msg
Private bcc,i,msg

* check message to make sure it is 12 characters long if not add a zero to
* beginning making this the same as the UPC-A barcode
msg = alltrim(msg)
if len(msg) < 12
  msg = "0"+msg
endif

* Calculate and add the check character *
bcc = 0
for i = 1 to len(msg)
  bcc = bcc + iif(i%2=1,val(substr(msg, i, 1)),val(substr(msg,i,1))*3)
endfor

msg = msg + alltrim(str(iif(bcc % 10 = 0,0,10 - (bcc % 10))))

return msg
*-------



*------------------------------------------------------------------------------------------------------------------------*
*--- EAN 8 Code Section

Procedure BC_EAN8
Parameters m
private sh,lb,t,x,p
set talk off
* Generates bar character pattern for EAN 8 bar codes
*    m  = text to decode into a character pattern
*
* Returns:
*    Bar pattern for EAN 8 bar code.
*    If an illegal value is found then a null will
*    be returned to the user.

*** if the parameter is not a character then quit
if type('m')<>"C"
  return ""
endif

*** encode message into bar code character pattern and place
*** it into the variable
*** initialize variable and add start code
p=chr(46)

*** add check digit character
IF LEN(m)=12
	m = BC_EAN8Check(m)
ENDIF

FOR x = 1 TO len(m)
  t = substr(m, x, 1)

  do case
    CASE t = "0"
      p = p + iif(x < 5,"0",chr(58))
    CASE t = "1"
      p = p + iif(x < 5,"1",chr(59))
    CASE t = "2"
      p = p + iif(x < 5,"2",chr(60))
    CASE t = "3"
      p = p + iif(x < 5,"3",chr(61))
    CASE t = "4"
      p = p + iif(x < 5,"4",chr(62))
    CASE t = "5"
      p = p + iif(x < 5,"5",chr(63))
    CASE t = "6"
      p = p + iif(x < 5,"6",chr(64))
    CASE t = "7"
      p = p + iif(x < 5,"7",chr(65))
    CASE t = "8"
      p = p + iif(x < 5,"8",chr(66))
    CASE t = "9"
      p = p + iif(x < 5,"9",chr(67))

    otherwise
      *** Invalid code found
      return ""
  endcase
  if x = 4
    p = p + chr(47)
  endif
endfor

* Add the stop code
p = p + chr(46)

*** Return the character pattern
return p
*-------



*-------
Procedure BC_EAN8Check
Parameter msg
Private bcc,i,msg

* Calculate and add the check character *
bcc = 0
for i = 1 to len(msg)
  bcc = bcc + iif(i%2=0,val(substr(msg, i, 1)),val(substr(msg,i,1))*3)
endfor

msg = msg + alltrim(str(iif(bcc % 10 = 0,0,10 - (bcc % 10))))

return msg
*--------------------------------------------------------------------------------------------------------------------*
