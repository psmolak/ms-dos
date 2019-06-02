org 0x100

; Program wczytuje plik o nazwie wczytanej z stdin.
;
; Jest to prosty automat przetwarzający plik znak
; po znaku, odpowiednio reagując na napotkanie nowej linii.
;
; Warto zadbać o obsługę błędów.
; Można dodać jakieś kolorki jak starczy czasu.

; -----------------------------------------------------------------
section .data
; -----------------------------------------------------------------

	; konfiguracja
	maxlength     dw 0x100

	; messages
	fatalmsg      db 'Wystapil nieoczekiwany blad $'
	intromsg      db 'Podaj nazwe pliku $'
	invalidmsg    db 'Podano bledna nazwe pliku $'
	nofilemsg     db 'Podany o podanej nazwie nie istnieje $'
	leavemsg      db 'Program pomyslnie zakonczyl dzialanie $'
	openfailmsg   db 'Otwarcie pliku nie powiodlo sie $'
	enterfailmsg  db 'Pobranie nazwy nie powiodlo sie $'
	emptymsg      db '$'

; -----------------------------------------------------------------
section .bss
; -----------------------------------------------------------------

	filename      resb 0x100 + 1
	handle        resw 0x1
	length        resw 0x1
	buffer        resb 0x100

; -----------------------------------------------------------------
section .text
; -----------------------------------------------------------------

; pomocnicze makro, któro wypisuje wiadomosc na ekran
%macro putline 1
	mov ah, 9h
	mov dx, %1
	int 21h
%endmacro

start:
	; Wyświetl komunikat powitalny
	putline intromsg

entername:
	; Wczytaj nazwe pliku
	mov ah, 3Fh
	mov bx, 0		; czytaj z stdin = 0
	mov cx, maxlength	; ustaw maksymalną długość nazwy
	mov dx, filename	; ustaw bufor na nazwę
	int 21h
	jc entererror		; sprawdz czy nie wystąpił błąd
	mov [length], ax	; zapisz długość pobranej nazwy

	; Ustaw NULL'a na końcu wczytanej nazwy
	mov di, filename
	add di, [length]
	sub di, 2
	mov byte [di], 0

readfile:
	; Otworz plik o podanej nazwie
	mov ah, 3Dh
	mov al, 0		; atrybut otwarcia, 0 = read
	mov dx, filename
	int 21h
	jc openerror
	mov [handle], ax

loop:
	; Pobierz pojedynczy znak z pliku
	mov ah, 3Fh
	mov bx, [handle]
	mov cx, 1
	mov dx, buffer
	int 21h

	; zapamiętjamy status ax (wypisanie znaku moze go zmienic)
	push ax

	; Wypisz wczytany znak na stdout
	mov ah, 40h
	mov bx, 1
	mov cx, 1
	mov dx, buffer
	int 21h

	pop ax			; przywrocmy status ax
	test ax, ax		; ax = 0? jeśli tak, mamy EOF
	jnz loop                ; nie jest zerem, jeszcze raz!

	; Wypisz wiadomosc o zakonczeniu programu
	putline emptymsg
	putline leavemsg

exit:
	mov ah, 4Ch
	int 21h

openerror:
	putline openfailmsg
	jmp exit

entererror:
	putline enterfailmsg
	jmp exit
