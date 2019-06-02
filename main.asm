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

	; wiadomosci
	fatalmsg      db 'Wystapil nieoczekiwany blad $'
	intromsg      db 'Podaj nazwe pliku $'
	invalidmsg    db 'Podano bledna nazwe pliku $'
	nofilemsg     db 'Podany o podanej nazwie nie istnieje $'
	openfailmsg   db 'Otwarcie pliku nie powiodlo sie $'
	enterfailmsg  db 'Pobranie nazwy nie powiodlo sie $'

; -----------------------------------------------------------------
section .bss
; -----------------------------------------------------------------

	filename      resb 0x100 + 1	; bufor na nazwe pliku
	length        resw 0x1          ; dlugosc nazwy
	handle        resw 0x1          ; handler do pliku
	buffer        resb 0x100        ; bufor na wczytanie pliku
	line          resw 0x1          ; numer aktualnej linii

; -----------------------------------------------------------------
section .text
; -----------------------------------------------------------------

; pomocnicze makro, któro wypisuje wiadomosc na ekran
%macro putline 1
	mov ah, 9h
	mov dx, %1
	int 21h
%endmacro

; pomocnicze makro, któro wypisuje znak na ekran
%macro putchar 1
	mov ah, 02h
	mov dl, %1
	int 21h
%endmacro

start:
	putline intromsg	; wyswietl komunikat powitalny
	mov word [line], 0	; wyzeruj licznik linii

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
	mov ah, 3Dh		; otworz plik o podanej nazwie
	mov al, 0		; atrybut otwarcia, 0 = read
	mov dx, filename
	int 21h
	jc openerror		; sprawdz czy byl blad
	mov [handle], ax

.loop:
	; Pobierz pojedynczy znak z pliku
	mov ah, 3Fh
	mov bx, [handle]
	mov cx, 1
	mov dx, buffer
	int 21h

	push ax			; zapamiętjamy status ax
	mov ax, [buffer]	; argument dla cosume
	call @consume
	pop ax			; przywrocmy status ax

	test ax, ax		; ax = 0? jeśli tak, mamy EOF
	jnz .loop               ; nie jest zerem, jeszcze raz!

	jmp exit


@consume:
	; procedura, która wykonuje działanie na podstawie
	; właśnie wczytanego znaku, który przekazujemy w ax
	; narazie poprostu wypisuje otrzymany znak

	push ax			; zapamietaj argument
	putchar al		; wypisz znak
	pop ax			; przywroc argument

	cmp ax, 0xa		; znak nowej linii?
	jne .end		; nie, skocz na koniec funkcji

	mov ax, [line]		; ustaw argument dla printnum
	call @printnum		; wywolaj printnum
	inc word [line]		; zwieksz numer linii

	putchar ' '
.end:
	ret


@printnum:
	; wypisuje liczbę podaną jako argument na wyjście
	; https://stackoverflow.com/a/45904076/4237072

	mov bx, 10	; ustaw podstawe dzielenia
	xor cx, cx	; wyzeruj licznik cx
.divide:
	xor dx, dx	; DX musi byc wyzerowany (DX:AX) / BX
	div bx		; AX = wynik, DX = reszta z dzielenia
	push dx		; zapiszmy reszte z dzielenia na stosie
	inc cx		; kolejna cyfra
	test ax, ax	; zostalo cos do dzielenia?
	jnz .divide	; tak, dzielimy dalej
.print:
	pop dx		; wez liczbe ze stosu
        add dl, "0"	; zamień liczbę na jej odpowiednik w ASCII
	putchar dl	; wypisz znak
	loop .print

	ret


exit:
	mov ah, 4Ch
	int 21h

openerror:
	putline openfailmsg
	jmp exit

entererror:
	putline enterfailmsg
	jmp exit
