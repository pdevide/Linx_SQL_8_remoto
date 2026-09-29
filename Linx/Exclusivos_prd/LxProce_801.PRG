*****************************************************************************************************
** BIBLIOTECA DE FUNÇÕES GENÉRICAS
*****************************************************************************************************

**//*************************************************************************************************
** VALIDAÇÃO DE CNPJ COM TRATAMENTO PARA CNPJ ALFANUMÉRICO
Function F_CnpjAlfaNumerico
	Lparameters C_GC

	C_GC = Alltrim(C_GC)
	M->D_1=0
	M->D_4=0
	M->X_X=1
	
	For M->CON_TA=1 To Len(M->C_GC)-2
		If At(Substr(M->C_GC,M->CON_TA,1),"/-.")=0
			M->D_1=M->D_1+(Asc(Substr(M->C_GC,M->CON_TA,1))-48)*(Iif(M->X_X<5,6,14)-M->X_X)
			M->D_4=M->D_4+(Asc(Substr(M->C_GC,M->CON_TA,1))-48)*(Iif(M->X_X<6,7,15)-M->X_X)

			M->X_X=M->X_X+1
		Endif
	Next
	
	M->RES_TO=M->D_1-(Int(M->D_1/11)*11)
	M->DIG_ITO=Iif(M->RES_TO<2,0,11-M->RES_TO)
	M->D_4=M->D_4+2*M->DIG_ITO
	M->RES_TO=M->D_4-(Int(M->D_4/11)*11)
	M->DIG_ITO=Val(Str(M->DIG_ITO,1)+Str(Iif(M->RES_TO<2,0,11-M->RES_TO),1))

	If DIG_ITO<>Val(Subs(M->C_GC,Len(M->C_GC)-1,2))
		Return .F.
	Else
		Return .T.
	Endif
Endfunc
