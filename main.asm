org 0x100

; Program wczytuje plik o nazwie wczytanej z stdin.
;
; Jest to prosty automat przetwarzający plik znak
; po znaku, odpowiednio reagując na napotkanie nowej linii.
;
; Warto zadbać o obsługę błędów.
; Można dodać jakieś kolorki jak starczy czasu.

section .data

	; konfiguracja
	filename_maxlength     dw 0x100

	; messages
	fatalmsg      db 'Wystapil nieoczekiwany blad$'
	intromsg      db 'Podaj nazwe pliku$'
	invalidmsg    db 'Podany o podanej nazwie nie istnieje$'


section .bss

	filename      resb 0x100
	handler       resw 0x1


section .text

start:
	; Wyświetl komunikat powitalny
	mov ah, 9h
	mov dx, intromsg
	int 21h

exit:
	mov ah, 4Ch
	int 21h

