; Vernamova sifra na architekture DLX
; Patrik Skaloš xskalo01

        .data 0x04          ; zacatek data segmentu v pameti
login:  .asciiz "xbidlo01"  ; <-- nahradte vasim loginem
cipher: .space 9 ; sem ukladejte sifrovane znaky, za posledni nezapomente dat 0

        .align 2            ; dale zarovnavej na ctverice (2^2) bajtu
laddr:  .word login         ; 4B adresa vstupniho textu (pro vypis)
caddr:  .word cipher        ; 4B adresa sifrovaneho retezce (pro vypis)

        .text 0x40          ; adresa zacatku programu v pameti
        .global main        ; 

; reg: (0) 2 4 6 17 24
; r2  = adresa spracovavaneho wordu z laddr
; r4  = spracovavany word (4 znaky, pocas sifrovania len znak) z laddr
; r6  = pomocna premenna pri sifrovani znaku
; r17 = 
; r24 = pouzity na shifting (separaciu znaku zo slova - z r4) a na docasne 
;       ulozenie sifrovacieho kluca (ascii: 's' a 'k')

main:   
	lw r2, laddr ;adresa laddr
	subi r2, r2, 4 ;na zaciatku getNextWord pridavame 4, tu treba ubrat
	nop
	nop

getNextWord:
		;po styroch iteraciach posunie na dalsi word
	addi r2, r2, 4
		;r24 zacne na 32 kedze od neho hned odratame 8
	addi r24, r0, 32
getNextChar:
		;nacitanie spracovaneho wordu do r4
	lw r4, 0(r2)   ;r4 = aksx, 10ol,...

		;separacia prave spracovavaneho znaku - bude v r4
        subi r24, r24, 8
	sll r4, r4, r24
	srli r4, r4, 24

		;ak je nasledujuci znak cislica, skoc na end
	add r6, r0, r4
	subi r6, r6, 97 ;'a' = 97 - po odcitani 97 bude hodnota zaporna
	srli r6, r6, 31 ; r=...0001 ak bolo cislo zaporne (znak bola cislica)
	bnez r6, end
	nop
	nop


	;r6 = 0 ak je v nom znak 'a', chceme aby 'a' reprezentovalo 1
	addi r6, r6, 1 



		;znak zasifruj a zapis do caddr
	;TODO sifracia znakov (strieda sa pricitanie a odcitanie)
	;add r4, r4, r6



		;kontrola, ci ascii nie je vacsia ako 'z'
	add r6, r0, r4
	subi r6, r6, 123 ;'z' = 122 - po odcitani 123 bude hodnota zaporna
	srli r6, r6, 31 ; r=...0001 ak bolo cislo zaporne (znak bol < 'z')
	beqz r6, charOverflow
	nop
	nop
		;kontrola, ci ascii nie je mensia ako 'a'
	add r6, r0, r4
	subi r6, r6, 97 ;'a' = 97 - po odcitani 123 bude hodnota zaporna
	srli r6, r6, 31 ; r=...0001 ak bolo cislo zaporne (znak bol < 'a')
	bnez r6, charUnderflow
	nop
	nop
		;ak je zasifrovany znak vporiadku
	j zasifrovane
	nop
	nop

	;ak je znak > 'z'
charOverflow:
	subi r4, r4, 26 ;ascii abeceda malych znakov ma velkost 26
	j zasifrovane
	nop
	nop

	;ak je znak < 'a'
charUnderflow:
	addi r4, r4, 26
	j zasifrovane
	nop
	nop

	;'a' <= spracovavany znak <= 'z'
zasifrovane:
	;TODO zapis znakov do caddr
	;adresu ziskat ako r2 + (caddr - laddr)?
	lw r17, caddr
	;lw r17, 0(r17) ; get word from caddr - nejdze bo caddr je nezarovnane
	;srli r17, r17, 16


	addi r1, r1, 1 ;TODO debug

		;ak sme este nespracovali 4 znaky, chceme dalsi z toho wordu
	bnez r24, getNextChar
	nop
	nop

		;po spracovani celeho wordu chceme dalsi word
	j getNextWord
	nop
	nop


end:    addi r14, r0, laddr ; <-- pro vypis sifry nahradte laddr adresou caddr
        trap 5  ; vypis textoveho retezce (jeho adresa se ocekava v r14)
        trap 0  ; ukonceni simulace
