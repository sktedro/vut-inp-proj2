; Vernamova sifra na architekture DLX
; Patrik Skaloš xskalo01

; registre: (0) 2 4 6 17 24
; r2  = char counter (index prave spracovavaneho znaku)
; r4  = znak spracovavany z laddr resp. zapisovany do caddr
; r6  = pomocna premenna pri citani, sifrovani, ukladani, ...
; r17 = pouzity na zistenie, ci mame dany znak sifrovat pricitanim alebo 
;       odcitanim
; r24 = nepouzite


        .data 0x04          	;zacatek data segmentu v pameti
login:  .asciiz "xskalo01"  	;vstupny retazec
cipher: .space 9 		;vystupny retazec

        .align 2            	;dale zarovnavej na ctverice (2^2) bajtu
laddr:  .word login         	;4B adresa vstupniho textu (pro vypis)
caddr:  .word cipher        	;4B adresa sifrovaneho retezce (pro vypis)

        .text 0x40          	;adresa zacatku programu v pameti
        .global main         


main:   
	subi r2, r0, 1 		;na zaciatku pridavame 1, tu treba ubrat

getNextChar:
		
	addi r2, r2, 1		;posun pocitadla na nasledujuci znak

		;NACITANIE NASLEDUJUCEHO ZNAKU (do r4)
	lw r4, laddr 		;nacitanie adresy nasledujuceho znaku do r4
	add r4, r4, r2 		;r4 = adresa + char counter
	lb r4, 0(r4)   		;nacitanie nasledujuceho znaku z laddr do r4

		;AK JE NASLEDUJUCI ZNAK (r4) CISLICA, KONCIME
	add r6, r0, r4
	subi r6, r6, 97 	;'a' = 97 - po odcitani 97 ma byt r6 kladne
	srli r6, r6, 31 	;r6 = ...0001 ak znak bola cislica
	bnez r6, end
	nop

		;AK JE r2 SUDE, PRICITAME 's', INAK ODCITAME 'k'
	add r17, r0, r2		;r17 = char counter
	slli r17, r17, 31 	;chceme len posledny bit (LSB)
	bnez r17, odd
	nop
even:
	addi r6, r0, 19		;r6 = 's' - 'a' + 1 = 19
	j posunHotovo
	add r4, r4, r6 		;r4 = spracovany znak + kluc
odd:
	addi r6, r0, 11		;r6 = 'k' - 'a' + 1 = 11
	sub r4, r4, r6 		;r4 = spracovany znak - kluc

		;ZNAK BOL POSUNUTY
posunHotovo:

		;KONTROLA, CI r4 (zasifrovany znak) NIE JE > 'z'
	add r6, r0, r4
	subi r6, r6, 123 	;'z' = 122 - po odcitani 123 ma byt r6 zaporny
	srli r6, r6, 31 	;r6 = ...0000 ak r4 > 'z'
	beqz r6, charOverflow
	nop

		;KONTROLA, CI r4 (zasifrovany znak) NIE JE < 'a'
	add r6, r0, r4
	subi r6, r6, 97 	;'a' = 97 - po odcitani 97 ma byt r6 kladny
	srli r6, r6, 31 	;r6 = ...0001 ak r4 < 'a'
	bnez r6, charUnderflow
	nop
		;AK JE ZASIFROVANY ZNAK VPORIADKU, IDEME DALEJ
	j zasifrovane
	nop

		;POZOR, ZNAK PRETIEKOL: r4 > 'z'
charOverflow:
	j zasifrovane
	subi r4, r4, 26 	;odcitame velkost abecedy

		;POZOR, ZNAK PODTIEKOL: r4 < 'a'
charUnderflow:
	addi r4, r4, 26 	;pricitame velkost abecedy

		;ZNAK BOL ZASIFROVANY A PLATI, ZE 'a' <= (znak) <= 'z'
zasifrovane:

		;ZAPIS ZNAKU DO caddr
	lw r6, caddr 		;r6 = adresa caddr
	add r6, r6, r2 		;r6 = adresa + char counter
	sb 0(r6), r4 		;zasifrovany znak zapiseme

		;PO SPRACOVANI ZNAKU POKRACUJEME NA DALSI
	j getNextChar
	nop

end:    
		;NA KONIEC VYSTUPNEHO RETAZCA ZAPISEME NULL BYTE ('\0')
	lw r6, caddr 		;r6 = adresa caddr
	add r6, r6, r2 		;r6 = adresa + char counter
	sb 0(r6), r0 		;do pamati zapiseme null byte (ascii = 0)

		;VYPIS VYSTUPNEHO RETAZCA A UKONCENIE SIMULACIE
	addi r14, r0, caddr 	;r14 = adresa vystupneho retazca
        trap 5  		;vypis textoveho retezce
        trap 0  		;ukonceni simulace
