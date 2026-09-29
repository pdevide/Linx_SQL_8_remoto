***/
* OBJETO DE ENTRADA DA TELA DE FILIAIS
* 29-04-2021
*!*	FILIAL DE					FILIAL PARA
*---------------------------------------------------------
*!*	CD NAVEGANTES            	CD BARRA VELHA
*!*	CD NAVEGANTES - W10      	CD BARRA VELHA - W10
*!*	CD NAVEGANTES - W20      	CD BARRA VELHA - W20
*!*	NAVEGANTES CQ            	BARRA VELHA - CQ
*!*	VENDA ATACADO SC 			VENDA ATACADO BARRA VELHA
*!*	BARRA VELHA - CQ         	NAVEGANTES CQ
*!*	CD BARRA VELHA           	CD NAVEGANTES
*!*	CD BARRA VELHA - W10     	CD NAVEGANTES - W10
*!*	CD BARRA VELHA - W20     	CD NAVEGANTES - W20
*!*	VENDA ATACADO BARRA VELHA	VENDA ATACADO SC

define class obj_entrada as custom
	procedure metodo_usuario
	lparam xmetodo, xobjeto ,xnome_obj
	DO CASE
	
		CASE UPPER(xmetodo) == 'USR_REFRESH'
			TRY 
				thisformset.lx_form1.lblFilial2.caption = F_DEPARA_NOME_FILIAL(ALLTRIM(v_filiais_01.filial))		
			CATCH
				
			FINALLY

			ENDTRY

		CASE UPPER(xmetodo) == 'USR_INIT'	
			WAIT WINDOW 'OBJ' NOWAIT
			thisformset.lx_form1.addobject("lblFilial2","label")
			thisformset.lx_form1.lblFilial2.top=27
			thisformset.lx_form1.lblFilial2.left=355
			thisformset.lx_form1.lblFilial2.height=32
			thisformset.lx_form1.lblFilial2.Width=140
			thisformset.lx_form1.lblFilial2.fontsize=8
			thisformset.lx_form1.lblFilial2.wordwrap=.t.
			thisformset.lx_form1.lblFilial2.forecolor=RGB(255,0,0) &&red
			thisformset.lx_form1.lblFilial2.fontitalic=.t.
			thisformset.lx_form1.lblFilial2.caption = ""
			thisformset.lx_form1.lblFilial2.visible=.t.

		CASE UPPER(xmetodo) == 'USR_SAVE_BEFORE'
			IF THISFORMSET.P_TOOL_STATUS != 'E'
				lcAlias = ALIAS()
				SELECT v_filiais_01	
				IF EMPTY(NVL(v_filiais_01.razao_social, ''))
					MESSAGEBOX('Antes de salvar Informe a raz„o social.', 0+64, 'OBJ - RAZAO SOCIAL INV¡LIDA')
					RETURN .F.
				ENDIF
				
				IF EMPTY(NVL(v_filiais_01.cgc_cpf, ''))
					MESSAGEBOX('Antes de salvar Informe o CNPJ.', 0+64, 'OBJ - CGC INV¡LIDO')
					RETURN .F.
				ENDIF
				
				IF EMPTY(NVL(v_filiais_01.rg_ie, ''))
					MESSAGEBOX('Antes de salvar Informe a InscriÁ„o Estadual.', 0+64, 'OBJ - INSCRI«√O INV¡LIDA')
					RETURN .F.
				ENDIF
				
				IF EMPTY(NVL(v_filiais_01.CEP, ''))
					MESSAGEBOX('Antes de salvar Informe o CEP.', 0+64, 'OBJ - CEP INV¡LIDO')
					RETURN .F.
				ENDIF
				
				IF EMPTY(NVL(v_filiais_01.ENDERECO, ''))
					MESSAGEBOX('Antes de salvar Informe o EndereÁo.', 0+64, 'OBJ - ENDERE«O INV¡LIDO')
					RETURN .F.
				ENDIF
			
				IF EMPTY(NVL(v_filiais_01.cidade, ''))
					MESSAGEBOX('Antes de salvar Informe a Cidade.', 0+64, 'OBJ - CIDADE INV¡LIDO')
					RETURN .F.
				ENDIF
							
				IF EMPTY(NVL(v_filiais_01.bairro, ''))
					MESSAGEBOX('Antes de salvar Informe o Bairro.', 0+64, 'OBJ - BAIRRO INV¡LIDO')
					RETURN .F.
				ENDIF
				
				IF EMPTY(NVL(v_filiais_01.uf, ''))
					MESSAGEBOX('Antes de salvar Informe o Estado.', 0+64, 'OBJ - ESTADO INV¡LIDO')
					RETURN .F.
				ENDIF
							
				IF EMPTY(NVL(v_filiais_01.numero, ''))
					MESSAGEBOX('Antes de salvar Informe o Numero do EndereÁo.', 0+64, 'OBJ - NUMERO INV¡LIDO')
					RETURN .F.
				ENDIF
			
				IF EMPTY(NVL(v_filiais_01.pais, ''))
					MESSAGEBOX('Antes de salvar Informe o Pais.', 0+64, 'OBJ - PAIS INV¡LIDO')
					RETURN .F.
				ENDIF
				
				IF UPPER(ALLTRIM(v_filiais_01.pais)) = 'BRASIL'
			  		F_SELECT("select * from LCF_LX_MUNICIPIO A JOIN LCF_LX_UF B ON A.ID_UF = B.ID_UF " +;
						 "WHERE UF=?v_filiais_01.uf AND DESC_MUNICIPIO =?v_filiais_01.CIDADE ",'CUR_VER',ALIAS())
						 
 					IF RECCOUNT('CUR_VER') =0
 					   MESSAGEBOX('A cidade+uf n„o esta cadastrada no SEFAZ,Favor Verificar a CIDADE e o ESTADO!!', 0+64, 'OBJ - CIDADE-UF INV¡LIDA')
					   RETURN .F.
				    ENDIF
				ENDIF     

				xCaracterInv = "¡…Õ”⁄·ÈÌÛ˙¿»Ã“Ÿ‡ËÏÚ˘¬ Œ‘€‚ÍÓÙ˚ƒÀœ÷‹‰ÎÔˆ¸√’„ı«Á—Ò∫"
				FOR x=1 TO LEN(xCaracterInv)
				    xCarac = SUBSTR(xCaracterInv ,x,1)
				    IF xCarac $ ALLTRIM(v_filiais_01.filial)
					   MESSAGEBOX("N„o pode Salvar Filial com Acento!!", 0+64, "OBJ - FILIAL COM ACENTO")
					   RETURN .F.
				    ENDIF
				ENDFOR
				SELECT (lcAlias)
           ENDIF
		OTHERWISE
			RETURN .t.
	ENDCASE
	ENDPROC
	

	
ENDDEFINE

*!*	PAULO DEVIDE
*!*	25-NOV-2024
*!*	FILIAL NAVEGANTES COM DADOS INVERTIDOS COM BARRA VELHA E VICE VERSA
FUNCTION F_DEPARA_NOME_FILIAL
PARAMETERS pFilial
cRetNome = ""
DO CASE

CASE 	pFilial =="CD NAVEGANTES"            	
	cRetNome = "CD BARRA VELHA"
CASE 	pFilial =="CD NAVEGANTES - W10"      	
	cRetNome = "CD BARRA VELHA - W10"
CASE 	pFilial =="CD NAVEGANTES - W20"      	
	cRetNome = "CD BARRA VELHA - W20"
CASE 	pFilial =="NAVEGANTES CQ"            	
	cRetNome = "BARRA VELHA - CQ"
CASE 	pFilial =="VENDA ATACADO SC" 			
	cRetNome = "VENDA ATACADO BARRA VELHA"
CASE 	pFilial =="BARRA VELHA - CQ"         	
	cRetNome = "NAVEGANTES CQ"
CASE 	pFilial =="CD BARRA VELHA"           	
	cRetNome = "CD NAVEGANTES"
CASE 	pFilial =="CD BARRA VELHA - W10"     	
	cRetNome = "CD NAVEGANTES - W10"
CASE 	pFilial =="CD BARRA VELHA - W20"     	
	cRetNome = "CD NAVEGANTES - W20"
CASE 	pFilial =="VENDA ATACADO BARRA VELHA"	
	cRetNome = "VENDA ATACADO SC"
OTHERWISE
	cRetNome = ""
ENDCASE
RETURN cRetNome

ENDFUNC 