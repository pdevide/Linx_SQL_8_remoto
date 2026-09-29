**
**------------------------------------------------------------------------------------------------------------------------**
procedure calc_valor

	xalias = alias()

	sele vtmp_romaneios_reserva_01_produtos

	xrecno = recno( )
	
	scan

		xvalor_rom = 0
		xqtde_r = 0
		
		If Varia_Preco_Tam
		
			*--Passa Por Todos os Tamanhos Até wmaximo_tamanhos
			For xCount = 1 To wMaximo_tamanhos

				*--Pega Quantidade Romaneada do Tamanho Corrente
				xR   = "R"+AllT(Str(xCount))
				*--Pega Preco do Tamanhos Corrente Em Vendas
				xPR  = "Preco"+Subs(ponteiro_preco_tam,xCount,1)
				*--Calcula o Valor do Item + Valor do Tamanho Corrente
				xValor_Rom = xValor_Rom + ( &xR * &xPr ) - ( &xR * desconto_Item ) +;
				                          ((((&xR*&xPr)-(&xR*desconto_Item)) * ipi) /100)
			Next

		Else

			*--Pega Quantidade Romaneada

			*--Calcula o Valor do Item + Valor do Tamanho Corrente
			xqtde_r = r1+r2+r3+r4+r5+r6+r7+r8+r9+r10+r11+r12+r13+r14+r15+r16+r17+r18+r19+r20+;
					  r21+r22+r23+r24+r25+r26+r27+r28+r29+r30+r31+r32+r33+r34+r35+r36+r37+r38+;
					  r39+r40+r41+r42+r43+r44+r45+r46+r47+r48
					  
			xValor_Rom = ( xQtde_R * preco1 ) - ( xQtde_R * desconto_Item ) +;
                       ((((xQtde_R*preco1)-(xQtde_R*desconto_Item)) * ipi) /100)
		EndIf

		*--Atualiza o Valor Romaneado/Embalado do ITEM CORRENTE
		Repla tot_valor_original with xValor_Rom

	endscan

	go xrecno
	
	sele &xalias

retu .t.
**------------------------------------------------------------------------------------------------------------------------**
