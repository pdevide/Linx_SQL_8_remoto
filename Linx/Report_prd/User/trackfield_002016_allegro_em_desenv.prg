*-- Cliente : Lx-Vs: Track & Field
*-- Conteudo: Programação Para Impressora Allegro
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------*
Procedure Etiqueta_Produto_Allegro

	xCtrlB   = ''
	xini     = xCtrlB + "L" + chr(10)+chr(13) + "SK" + chr(10)+chr(13) + "PG" + chr(10)+chr(13) + "D11" + chr(10)+chr(13) + "H14" + chr(10)+chr(13)
	xfim     = "E" + chr(10)+chr(13)
	xQtdeEti = "Q0001" + chr(10)+chr(13) 
	xArqImg  = "LOGOTRK"  && Arquivo BMP (nome fixo, sua imagem deve ser LOGOTRK.bmp)
	
	xColA = 030
	xColB = 310
	xColC = 590
	xQtde = 0
	store '' to x_Allegro

	sele vtmp_tabelas_preco_barra_00
	go top
	do while !eof()
		store '' to xA1,xA2,xA3,xA4,xA5,xA6,xA7,xA8,xA9,xA10,xA11,xA12,;
					xB1,xB2,xB3,xB4,xB5,xB6,xB7,xB8,xB9,xB10,xB11,xB12,;
					xC1,xC2,xC3,xC4,xC5,xC6,xC7,xC8,xC9,xC10,xC11,xC12  
		
		for k = 65 to 67
			K_ = chr(k)
			xQtde = xQtde + 1

			x&K_.1  = "1Y110000247"+f_StrZero(xCol&K_+030,4) + xArqImg + chr(10)+chr(13)
			x&K_.2  = "10220000243"+f_StrZero(xCol&K_+022,4) + "TROCA ATE:      /      /      " + chr(10)+chr(13)
			x&K_.3  = "1F620400115"+f_StrZero(xCol&K_+020,4) + Allt(vtmp_tabelas_preco_barra_00.codigo_barra) + chr(10)+chr(13)
			x&K_.4  = "11130000203"+f_StrZero(xCol&K_+020,4) + SubStr(allt(vtmp_tabelas_preco_barra_00.desc_produto),01,22) + chr(10)+chr(13)
			x&K_.5  = "11220000190"+f_StrZero(xCol&K_+020,4) + "REF: " +allt(vtmp_tabelas_preco_barra_00.desc_produto) + chr(10)+chr(13)
			x&K_.6  = "11220000178"+f_StrZero(xCol&K_+020,4) + "COR: " +allt(vtmp_tabelas_preco_barra_00.desc_cor_produto) + chr(10)+chr(13)
			x&K_.7  = "11220000165"+f_StrZero(xCol&K_+020,4) + Allt(vtmp_tabelas_preco_barra_00.nome_tamanho) + chr(10)+chr(13)
			x&K_.8  = "11220000102"+f_StrZero(xCol&K_+020,4) + SubStr(Allt(vtmp_tabelas_preco_barra_00.desc_produto),01,22) + chr(10)+chr(13)
			x&K_.9  = "11220000090"+f_StrZero(xCol&K_+020,4) + "REF: " +Allt(vtmp_tabelas_preco_barra_00.desc_produto) + chr(10)+chr(13)
			x&K_.10 = "11220000076"+f_StrZero(xCol&K_+020,4) + "COR: " +Allt(vtmp_tabelas_preco_barra_00.desc_cor_produto) + chr(10)+chr(13)
			x&K_.11 = "11220000076"+f_StrZero(xCol&K_+020,4) + "TAM: " +Allt(vtmp_tabelas_preco_barra_00.nome_tamanho) + chr(10)+chr(13)
			x&K_.12 = "1F620400115"+f_StrZero(xCol&K_+020,4) + Allt(vtmp_tabelas_preco_barra_00.codigo_barra) + chr(10)+chr(13)

			if xQtde >= vtmp_tabelas_preco_barra_00.qtde_etiquetas
				skip
				xQtde = 0
			endif

			if eof()
				Exit
			endif
		endfor

		x_Etiq = xIni + xA1+xA2+xA3+xA4+xA5+xA6+xA7+xA8+xA9+xA10+xA11+xA12+;
					  + xB1+xB2+xB3+xB4+xB5+xB6+xB7+xB8+xB9+xB10+xB11+xB12+;
					  + xC1+xC2+xC3+xC4+xC5+xC6+xC7+xC8+xC9+xC10+xC11+xC12 ;
	             	  + xQtdeEti + xfim
	             	  
		x_Allegro = x_Allegro + x_Etiq

		sele vtmp_tabelas_preco_barra_00
	enddo
	Return(allt(x_Allegro))

ENDFUNC
*---------------------------------------------------------------------------------------------------------------------------------------------------------------------*
