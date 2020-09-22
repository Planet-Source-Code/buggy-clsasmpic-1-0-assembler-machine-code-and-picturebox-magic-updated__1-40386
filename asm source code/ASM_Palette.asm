;ASM_Palette.asm  by Robert Rayment  7/11/01

;VB

; Assumes MCode Structure set
; MCode Structure
; Public Type MCodeStruc
;   PICW As Long
;   PICH As Long
;   PtrPalBGR As Long
;   PtrPalLineCopy As Long
;   Increment As Long
;   QBLongColor As Long
;   OpCode As Long
; End Type
; Public MCODE As MCodeStruc
;
; ptrStruc = VarPtr(MCODE.PICW)
; ptMC = VarPtr mcode byte array

; Palette Effects
; OpCode& = 0    'Redder
; OpCode& = 1    'LessRed
; OpCode& = 2    'Greener
; OpCode& = 3    'LessGreen
; OpCode& = 4    'Bluer
; OpCode& = 5    'LessBlue
; OpCode& = 6    'Brighter
; OpCode& = 7    'Darker
; OpCode& = 8    'RotateColorsPlus
; OpCode& = 9    'RotateColorsMinus
; OpCode& = 10   'AddNoise
; OpCode& = 11   'Invert
; OpCode& = 12   'Grey
; OpCode& = 13   'Blacken < 24
; OpCode& = 14   'Whiten  > 248
; OpCode& = 15   'Black2White
; OpCode& = 16   'White2Black
; OpCode& = 17   'NonWhite2Black
; OpCode& = 18   'NonBlack2White
; OpCode& = 19   'BlackAndWhite
;
; Rand = 255 * Rnd
;   
; res = CallWindowProc(ptMC, ptrStruc, Rand, 3&, 4&)
;                      [ebp +  8        12   16  20 ]
; End Sub


%macro movab 2		; name & num of parameters
  push dword %2		; 2nd param
  pop dword %1		; 1st param
%endmacro			; use  movab %1,%2
; Allows eg	movab bmW,[ebx+4]

%define PICW            [ebp-4]		; PICW Mod 4
%define PICH            [ebp-8]		; PICH
%define PtrPalBGR       [ebp-12]	; PTR to PalBGR(1,1,1,N)
%define PtrPalLineCopy  [ebp-16]	; PTR to PalLineCopy(4,1)
%define Increment       [ebp-20] 	; 1,2,4,8
%define QBLongColor     [ebp-24]    ; RGB(QBRed, QBGreen, QBBlue)	
%define OpCode          [ebp-28]    ; 0,1,2,, etc

%define PalSize    [ebp-32]
%define LineBytes  [ebp-36]
%define Seed	   [ebp-40] ; from Rand
; For MMX
%define lo32 [ebp-44]
%define hi32 [ebp-48]


[bits 32]

	push ebp
	mov ebp,esp
	sub esp,76
	push edi
	push esi
	push ebx

	; Copy structure
	mov ebx,[ebp+8]
	
	movab PICW,          [ebx]
	movab PICH,          [ebx+4]
	movab PtrPalBGR,     [ebx+8]
	movab PtrPalLineCopy,[ebx+12]
	movab Increment,     [ebx+16]
	movab QBLongColor,   [ebx+20]
	movab OpCode,        [ebx+24]
	
	mov eax,[ebp+12]
	mov Seed,eax
	
	mov eax,PICH
	mov ebx,PICW
	mul ebx
	mov PalSize,eax		; In 4 byte chunks
	
	mov eax,PICW
	shl eax,2			; x4
	mov LineBytes,eax
	
	
	mov eax,OpCode
	cmp eax,0
	jne Test1
	Call near Redder
	jmp near GETOUT
Test1:
	cmp eax,1
	jne Test2
	Call near LessRed
	jmp near GETOUT
Test2:
	cmp eax,2
	jne Test3
	Call near Greener
	jmp near GETOUT
Test3:
	cmp eax,3
	jne Test4
	Call near LessGreen
	jmp near GETOUT
Test4:
	cmp eax,4
	jne Test5
	Call near Bluer
	jmp near GETOUT
Test5:
	cmp eax,5
	jne Test6
	Call near LessBlue
	jmp near GETOUT
Test6:
	cmp eax,6
	jne Test7
	Call near Brighter
Test7:
	cmp eax,7
	jne Test8
	Call Darker
Test8:
	cmp eax,8
	jne Test9
	Call near RotateColorsPlus
	jmp GETOUT
Test9:
	cmp eax,9
	jne Test10
	Call near RotateColorsMinus
	jmp GETOUT
Test10:	
	cmp eax,10
	jne Test11
	Call near AddNoise
	jmp GETOUT
Test11:
	cmp eax,11
	jne Test12
	Call near Invert
	jmp GETOUT
Test12:
	cmp eax,12
	jne Test13
	Call near Grey
	jmp GETOUT
Test13:
	cmp eax,13
	jne Test14
	Call near Blacken
	jmp GETOUT
Test14:
	cmp eax,14
	jne Test15
	Call near Whiten
	jmp GETOUT
Test15:
	cmp eax,15
	jne Test16
	Call near Black2White
	jmp GETOUT
Test16:
	cmp eax,16
	jne Test17
	Call near White2Black
	jmp GETOUT
Test17:
	cmp eax,17
	jne Test18
	Call near NonWhite2Black
	jmp GETOUT
Test18:
	cmp eax,18
	jne Test19
	Call near NonBlack2White
	jmp GETOUT
Test19:
	cmp eax,19
	jne Test20
	Call near BlackAndWhite
	jmp GETOUT
Test20:



GETOUT:
	pop ebx
	pop esi
	pop edi
	mov esp,ebp
	pop ebp
	ret 16

;############################################################
;============================================================

Redder:		; 0
	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue

	xor eax,eax
	mov eax,Increment
	shl eax,16			;00 In 00 00
	                    ;A  R  G  B
	mov lo32,eax
	mov hi32,eax
	movq mm0,hi32
	
	mov ecx,PalSize
	shr ecx,1			; Num 8 byte chunks
	mov ebx,8
L0:
	movq mm1,[esi]
	paddusb mm1,mm0
	movq [esi],mm1
	add esi,ebx
	dec ecx
	jnz L0
	emms
RET
;============================================================
LessRed:		; 1

	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue

	xor eax,eax
	mov eax,Increment
	shl eax,16			;00 In 00 00
	                    ;A  R  G  B
	mov lo32,eax
	mov hi32,eax
	movq mm0,hi32
	
	mov ecx,PalSize
	shr ecx,1			; Num 8 byte chunks
	mov ebx,8
L1:
	movq mm1,[esi]
	psubusb mm1,mm0
	movq [esi],mm1
	add esi,ebx
	dec ecx
	jnz L1
	emms
	
RET
;============================================================
Greener:		; 2

	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue

	xor eax,eax
	mov eax,Increment
	shl eax,8			;00 00 In 00
	                    ;A  R  G  B
	mov lo32,eax
	mov hi32,eax
	movq mm0,hi32
	
	mov ecx,PalSize
	shr ecx,1			; Num 8 byte chunks
	mov ebx,8
L2:
	movq mm1,[esi]
	paddusb mm1,mm0
	movq [esi],mm1
	add esi,ebx
	dec ecx
	jnz L2
	emms
	
RET
;============================================================
LessGreen:		; 3

	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue

	xor eax,eax
	mov eax,Increment
	shl eax,8			;00 00 In 00
	                    ;A  R  G  B
	mov lo32,eax
	mov hi32,eax
	movq mm0,hi32
	
	mov ecx,PalSize
	shr ecx,1			; Num 8 byte chunks
	mov ebx,8
L3:
	movq mm1,[esi]
	psubusb mm1,mm0
	movq [esi],mm1
	add esi,ebx
	dec ecx
	jnz L3
	emms

RET
;============================================================
Bluer:		; 4

	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue

	xor eax,eax
	mov eax,Increment
	          			;00 00 0 In
	                    ;A  R  G  B
	mov lo32,eax
	mov hi32,eax
	movq mm0,hi32
	
	mov ecx,PalSize
	shr ecx,1			; Num 8 byte chunks
	mov ebx,8
L4:
	movq mm1,[esi]
	paddusb mm1,mm0
	movq [esi],mm1
	add esi,ebx
	dec ecx
	jnz L4
	emms

RET
;============================================================
LessBlue:		; 5

	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue

	xor eax,eax
	mov eax,Increment
	          			;00 00 00 In
	                    ;A  R  G  B
	mov lo32,eax
	mov hi32,eax
	movq mm0,hi32
	
	mov ecx,PalSize
	shr ecx,1			; Num 8 byte chunks
	mov ebx,8
L5:
	movq mm1,[esi]
	psubusb mm1,mm0
	movq [esi],mm1
	add esi,ebx
	dec ecx
	jnz L5
	emms

RET
;============================================================
Brighter:	; 6

	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue

	xor eax,eax
	mov eax,Increment
	shl eax,8			;00 00 In 00
	                    ;A  R  G  B
	mov aL,Increment
	shl eax,8			;00 In In 00
	                    ;A  R  G  B
	mov aL,Increment	;00 In In In
	                    ;A  R  G  B
	
	mov lo32,eax
	mov hi32,eax
	movq mm0,hi32
	
	mov ecx,PalSize
	shr ecx,1			; Num 8 byte chunks
	mov ebx,8
L6:
	movq mm1,[esi]
	paddusb mm1,mm0
	movq [esi],mm1
	add esi,ebx
	dec ecx
	jnz L6
	emms
RET

;============================================================
Darker:	; 7

	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue

	xor eax,eax
	mov eax,Increment
	shl eax,8			;00 00 In 00
	                    ;A  R  G  B
	mov aL,Increment
	shl eax,8			;00 In In 00
	                    ;A  R  G  B
	mov aL,Increment	;00 In In In
	                    ;A  R  G  B
	
	mov lo32,eax
	mov hi32,eax
	movq mm0,hi32
	
	mov ecx,PalSize
	shr ecx,1			; Num 8 byte chunks
	mov ebx,8
L7:
	movq mm1,[esi]
	psubusb mm1,mm0
	movq [esi],mm1
	add esi,ebx
	dec ecx
	jnz L7
	emms
RET
;============================================================

RotateColorsPlus:	; 8

	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue

	xor eax,eax
	mov eax,Increment
	shl eax,8			;00 00 In 00
	                    ;A  R  G  B
	mov aL,Increment
	shl eax,8			;00 In In 00
	                    ;A  R  G  B
	mov aL,Increment	;00 In In In
	                    ;A  R  G  B
	
	mov lo32,eax
	mov hi32,eax
	movq mm0,hi32
	
	mov ecx,PalSize
	shr ecx,1			; Num 8 byte chunks
	mov ebx,8
L8:
	movq mm1,[esi]
	paddb mm1,mm0
	movq [esi],mm1
	add esi,ebx
	dec ecx
	jnz L8
	emms
RET
;============================================================
RotateColorsMinus:	; 9

	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue

	xor eax,eax
	mov eax,Increment
	shl eax,8			;00 00 In 00
	                    ;A  R  G  B
	mov aL,Increment
	shl eax,8			;00 In In 00
	                    ;A  R  G  B
	mov aL,Increment	;00 In In In
	                    ;A  R  G  B
	
	mov lo32,eax
	mov hi32,eax
	movq mm0,hi32
	
	mov ecx,PalSize
	shr ecx,1			; Num 8 byte chunks
	mov ebx,8
L9:
	movq mm1,[esi]
	psubb mm1,mm0
	movq [esi],mm1
	add esi,ebx
	dec ecx
	jnz L9
	emms
RET
;============================================================

%define zFac2      [ebp-52]	; = (zFac * 2 + 1)
%define a255	   [ebp-56]	
%define culB	   [ebp-60]	
%define culG	   [ebp-64]	
%define culR	   [ebp-68]	
%define aran       [ebp-72] ; aran 0-255
%define zFac	   [ebp-76]	; = 20 * Increment

AddNoise:	; 10

	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue

	mov eax,Increment
	mov ebx,20
	mul ebx
	mov zFac,eax		; zFac=20*Increment
	shl eax,1			; zFac*2
	add eax,1			; zFac*2+1
	mov zFac2,eax
	
	mov eax,255
	mov a255,eax
	
	mov ecx,PalSize
iy10:
	;---------------------
	Call RANDNOISE		; Out: aL & Seed & aran = rand(0-255)
	fild dword aran		
	fild dword a255		; 255,aran
	fdivp st1			; aran/255   0-1
	fild dword zFac2
	fmulp st1			; (zFac*2+1)*Rnd
	fild dword zFac		; zFac,(zFac*2+1)*Rnd
	fsubp st1			; (zFac*2+1)*Rnd - zFac
	
	movzx eax,byte [esi]   ; B
	mov culB,eax
	
	fild dword culB
	faddp st1
	fistp dword culB
	;---------------------
	inc esi				; G	
	;---------------------
	Call RANDNOISE		; Out: aL & Seed = rand(0-255)
	fild dword aran		
	fild dword a255		; 255,aran
	fdivp st1			; aran/255   0-1
	fild dword zFac2
	fmulp st1			; (zFac*2+1)*Rnd
	fild dword zFac		; zFac,(zFac*2+1)*Rnd
	fsubp st1			; (zFac*2+1)*Rnd - zFac
	
	movzx eax,byte [esi]   ; G
	mov culG,eax
	
	fild dword culG
	faddp st1
	fistp dword culG
	;---------------------
	inc esi				; R
	;---------------------
	Call RANDNOISE		; Out: aL & Seed = rand(0-255)
	fild dword aran		
	fild dword a255		; 255,aran
	fdivp st1			; aran/255   0-1
	fild dword zFac2
	fmulp st1			; (zFac*2+1)*Rnd
	fild dword zFac		; zFac,(zFac*2+1)*Rnd
	fsubp st1			; (zFac*2+1)*Rnd - zFac
	
	movzx eax,byte [esi]   ; R
	mov culR,eax
	
	fild dword culR
	faddp st1
	fistp dword culR
	;---------------------

	;---------------------
	mov eax,culB
	cmp eax,255
	jl t10
	mov eax,255
	jmp s10
t10:
	cmp eax,0
	jg s10
	mov eax,0
s10:
	mov culB,eax
	;---------------------
	mov eax,culG
	cmp eax,255
	jl t100
	mov eax,255
	jmp s100
t100:
	cmp eax,0
	jg s100
	mov eax,0
s100:
	mov culG,eax
	;---------------------
	mov eax,culR
	cmp eax,255
	jl t1000
	mov eax,255
	jmp s1000
t1000:
	cmp eax,0
	jg s1000
	mov eax,0
s1000:
	mov culR,eax
	;---------------------
	; esi->R
	mov eax,culR
	mov byte[esi],aL
	dec esi			; ->G
	mov eax,culG
	mov byte[esi],aL
	dec esi			; ->B
	mov eax,culB
	mov byte[esi],aL
	
	mov edx,4
	add esi,edx		; -> next B
	
	dec ecx
	jnz near iy10

RET

;============================================================
RANDNOISE:		; Out: aL & Seed = rand(0-255)
	mov eax,011813h	 	; 71699 prime 
	imul DWORD Seed
	add eax, 0AB209h 	; 700937 prime
	rcr eax,1			; leaving out gives vertical lines plus
						; faint horizontal ones, tartan

	;----------------------------------------
	;jc ok				; these 2 have little effect
	;rol eax,1			;
ok:						;
	;----------------------------------------
	
	;----------------------------------------
	;dec eax			; these produce vert lines
	;inc eax			; & with fsin marble arches
	;----------------------------------------

	mov Seed,eax	; save seed
	and eax,255
	mov aran,eax	; aran = rnd(0-255)
RET

;============================================================
Invert:	; 11

	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue

	xor eax,eax
	mov eax,0FFFFFFFFh
	
	mov lo32,eax
	mov hi32,eax
	
	mov ecx,PalSize
	shr ecx,1			; Num 8 byte chunks
	mov ebx,8
L11:
	movq mm0,hi32
	movq mm1,[esi]
	psubb mm0,mm1
	movq [esi],mm0
	add esi,ebx
	dec ecx
	jnz L11
	emms
RET
;============================================================
Grey:	; 12
	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue

	mov ecx,PalSize
iy12:
	movzx ax,byte[esi]
	mov bx,ax
	movzx ax,byte[esi+1]
	mov dx,ax
	movzx ax,byte[esi+2]
	add ax,dx
	add ax,bx
	mov bx,3
	div bL				; to get result in aL !
	mov byte[esi],aL	; B
	inc esi
	mov byte[esi],aL	; G
	inc esi	
	mov byte[esi],aL	; R
	inc esi			; -> A
	inc esi			; -> next B
	
	dec ecx
	jnz iy12

RET
;============================================================
Blacken:	; 13	Blacken if R,G & B <24
	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue

	mov ecx,PalSize
iy13:
	mov aL,byte[esi]
	cmp aL,24
	ja ny13				; ja not jg 
	mov aL,byte[esi+1]
	cmp aL,24
	ja ny13
	mov aL,byte[esi+2]
	cmp aL,24
	ja ny13
	mov aL,0
	mov byte[esi],aL	; B
	inc esi
	mov byte[esi],aL	; G
	inc esi	
	mov byte[esi],aL	; R
	inc esi			; -> A
	inc esi			; -> next B
	jmp ny130
ny13:
	mov edx,4
	add esi,edx
ny130:
	dec ecx
	jnz iy13

RET

;============================================================
Whiten:	; 14 Whiten if R,G & B >248
	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue

	mov ecx,PalSize
iy14:
	mov aL,byte[esi]
	cmp aL,248			; aL-248
	jbe ny14	 
	mov aL,byte[esi+1]
	cmp aL,248
	jbe ny14
	mov aL,byte[esi+2]
	cmp aL,248
	jbe ny14
	
	mov aL,255
	mov byte[esi],aL	; B
	inc esi
	mov byte[esi],aL	; G
	inc esi	
	mov byte[esi],aL	; R
	inc esi			; -> A
	inc esi			; -> next B
	jmp ny140
ny14:
	mov edx,4
	add esi,edx
ny140:
	dec ecx
	jnz iy14

RET

;============================================================
Black2White:	; 15 B to W if R,G & B = 0
	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue

	mov ecx,PalSize
iy15:
	mov aL,byte[esi]
	cmp aL,0			; aL-0
	jne ny15	 
	mov aL,byte[esi+1]
	cmp aL,0
	jne ny15
	mov aL,byte[esi+2]
	cmp aL,0
	jne ny15
	
	mov aL,255
	mov byte[esi],aL	; B
	inc esi
	mov byte[esi],aL	; G
	inc esi	
	mov byte[esi],aL	; R
	inc esi			; -> A
	inc esi			; -> next B
	jmp ny150
ny15:
	mov edx,4
	add esi,edx
ny150:
	dec ecx
	jnz iy15

RET

;============================================================
White2Black:	; 16 W to B if R,G & B = 255
	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue

	mov ecx,PalSize
iy16:
	mov aL,byte[esi]
	cmp aL,255		
	jne ny16	 
	mov aL,byte[esi+1]
	cmp aL,255
	jne ny16
	mov aL,byte[esi+2]
	cmp aL,255
	jne ny16
	
	mov aL,0
	mov byte[esi],aL	; B
	inc esi
	mov byte[esi],aL	; G
	inc esi	
	mov byte[esi],aL	; R
	inc esi			; -> A
	inc esi			; -> next B
	jmp ny160
ny16:
	mov edx,4
	add esi,edx
ny160:
	dec ecx
	jnz iy16

RET

;============================================================
NonWhite2Black:	; 17 NW to B if R,G & B <> 255
	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue

	mov ecx,PalSize
iy17:
	mov aL,byte[esi]
	cmp aL,255		
	jne ny17	 
	mov aL,byte[esi+1]
	cmp aL,255
	jne ny17
	mov aL,byte[esi+2]
	cmp aL,255
	je ny170
ny17:
	mov aL,0
	mov byte[esi],aL	; B
	inc esi
	mov byte[esi],aL	; G
	inc esi	
	mov byte[esi],aL	; R
	inc esi			; -> A
	inc esi			; -> next B
	jmp ny1700
ny170:
	mov edx,4
	add esi,edx
ny1700:
	dec ecx
	jnz iy17

RET
;============================================================
NonBlack2White:	; 18 NB to W if R,G & B <> 0
	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue

	mov ecx,PalSize
iy18:
	mov aL,byte[esi]
	cmp aL,0		
	jnz ny18	 
	mov aL,byte[esi+1]
	cmp aL,0
	jnz ny18
	mov aL,byte[esi+2]
	cmp aL,0
	jz ny180
ny18:	
	mov aL,255
	mov byte[esi],aL	; B
	inc esi
	mov byte[esi],aL	; G
	inc esi	
	mov byte[esi],aL	; R
	inc esi			; -> A
	inc esi			; -> next B
	jmp ny1800
ny180:
	mov edx,4
	add esi,edx
ny1800:
	dec ecx
	jnz iy18

RET

;============================================================
BlackAndWhite:	; 19 Whiten if R,G & B >=180 else Black
	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue

	mov ecx,PalSize
iy19:
	mov aL,byte[esi]	; B
	cmp aL,180			; aL-180
	jb ny19	 
	mov aL,byte[esi+1]	; G
	cmp aL,180
	jb ny191
	mov aL,byte[esi+2]	; R
	cmp aL,180
	jb ny192
GE180:
	mov aL,255
BW19:
	mov byte[esi],aL	; B
	inc esi
	mov byte[esi],aL	; G
	inc esi	
	mov byte[esi],aL	; R
	inc esi			; -> A
	inc esi			; -> next B
	jmp ny1900
ny19:
	mov aL,byte[esi+1]	; G
	cmp aL,180
	jae GE180 
ny191:
	mov aL,byte[esi+2]	; R
	cmp aL,180
	jae GE180 
ny192:
	mov aL,0
	jmp BW19			; All < 180

ny1900:
	dec ecx
	jnz iy19

RET
