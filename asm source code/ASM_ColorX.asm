; ASM_ColorX.asm  by Robert Rayment  7/11/01


; VB

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
; ptMC = Ptr to mcode byte array

; ColorX Effects
; OpCode& = 0	'AddRandColorX
; OpCode& = 1	'AddColoredHorzLines
; OpCode& = 2	'AddColoredVertLines
; OpCode& = 3	'AddColoredDots
; OpCode& = 4	'DiffuseColorX
; OpCode& = 5	'DiffuseColorXUp
; OpCode& = 6	'DiffuseColorXDown
; OpCode& = 7	'DiffuseColorXLeft
; OpCode& = 8	'DiffuseColorXRight
; OpCode& = 9	'BrightSpotXpYp
; OpCode& = 10
;
; Rand = 255 * Rnd
;   
; res = CallWindowProc(ptMC, ptrStruc, zParam1, zParam2, ptAnswer)
;                      [ebp +  8        12       16       20 ]
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

%define zRand1	   [ebp-40] ; Rnd1 or 0.9 from VB
%define zRand2     [ebp-44] ; Rnd2 or 0.1 from VB
%define ix	       [ebp-48]	
%define iy         [ebp-52]
%define culB	   [ebp-56]	
%define culG	   [ebp-60]	
%define culR	   [ebp-64]	
%define offset     [ebp-68]
%define ABSY       [ebp-72]
%define ABSX       [ebp-76]
%define A          [ebp-80]
%define numbr      [ebp-84]
%define ixx		   [ebp-88]
%define iyy		   [ebp-92]
%define cul	 	   [ebp-96]	
%define zNV	 	   [ebp-100]	; varying zN


[bits 32]

	push ebp
	mov ebp,esp
	sub esp,100
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
	mov zRand1,eax		; zN = 0.9 for Diffusers
	mov eax,[ebp+16]
	mov zRand2,eax		; zN2 = 0.1 for Diffusers
	
	mov eax,PICH
	mov ebx,PICW
	mul ebx
	mov PalSize,eax		; In 4 byte chunks
	
	mov eax,PICW
	shl eax,4			; x4
	mov LineBytes,eax
	

	; Get RGB	
	mov eax,QBLongColor
	and eax,0FFh
	mov culR,eax
	mov eax,QBLongColor
	and eax,0FF00h
	shr eax,8
	mov culG,eax
	mov eax,QBLongColor
	and eax,0FF0000h
	shr eax,16
	mov culB,eax

	mov eax,OpCode
	cmp eax,0
	jne Test1
	Call near AddRandColorX
	jmp near GETOUT
Test1:
	cmp eax,1
	jne Test2
	Call near AddColoredHorzLines
	jmp near GETOUT
Test2:
	cmp eax,2
	jne Test3
	Call near AddColoredVertLines
	jmp near GETOUT
Test3:
	cmp eax,3
	jne Test4
	Call near AddColoredDots
	jmp near GETOUT
Test4:
	cmp eax,4
	jne Test5
	Call near DiffuseColorX
	jmp near GETOUT
Test5:
	cmp eax,5
	jne Test6
	Call near DiffuseColorXUp
	jmp near GETOUT
Test6:
	cmp eax,6
	jne Test7
	Call near DiffuseColorXDown
	jmp near GETOUT
Test7:
	cmp eax,7
	jne Test8
	Call near DiffuseColorXLeft
	jmp near GETOUT
Test8:
	cmp eax,8
	jne Test9
	Call near DiffuseColorXRight
	jmp near GETOUT
Test9:
	cmp eax,9
	Call near BrightSpotXpYp


GETOUT:
	pop ebx
	pop esi
	pop edi
	mov esp,ebp
	pop ebp
	ret 16

;############################################################
;============================================================
AddRandColorX:		;0

;%define zRand1	   [ebp-40] ; Rnd1 from VB
;%define zrand2    [ebp-44] ; Rnd2 from VB
;%define ix	       [ebp-48]	
;%define iy        [ebp-52]
;%define culB	   [ebp-56]	
;%define culG	   [ebp-60]	
;%define culR	   [ebp-64]	


	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue

	;--------------------
	fld dword zRand1
	fild dword PICW
	fmulp st1			; PICW * Rnd
	fld1
	faddp st1			; PICW * Rnd + 1
	fistp dword ix
	;--------------------
	mov eax,ix
	cmp eax,PICW
	jle x0
	mov eax,PICW
	mov ix,eax
x0:
	;---------------	; Get random iy
	fld dword zRand2
	fild dword PICH
	fmulp st1			; PICH * Rnd
	fld1
	faddp st1			; PICH * Rnd + 1
	fistp dword iy
	;--------------------
	mov eax,iy
	cmp eax,PICH
	jle y0
	mov eax,PICH
	mov iy,eax
y0:

	; B = esi + (4*(iy-1)*PICW + 4*(ix-1))
	Call near GetAddr
	
	mov eax,culB
	mov byte[esi],aL
	mov eax,culG
	mov byte[esi+1],aL
	mov eax,culR
	mov byte[esi+2],aL

RET
;============================================================
AddColoredHorzLines:	; 1
;%define ix	       [ebp-48]	
;%define iy        [ebp-52]
;%define culB	   [ebp-56]	
;%define culG	   [ebp-60]	
;%define culR	   [ebp-64]	

	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue
	
	push esi
	pop edi				; copy

	mov ecx,PICH
y1:
	push ecx
	mov iy,ecx
	
	mov ecx,PICW
x1:
	mov ix,ecx

	Call near GetAddr

	mov eax,culB
	mov byte[esi],aL
	mov eax,culG
	mov byte[esi+1],aL
	mov eax,culR
	mov byte[esi+2],aL
	
	push edi			; reset
	pop esi
	
	dec ecx
	jnz x1

	pop ecx
	mov eax,Increment
	sub ecx,eax
	xor eax,eax
	cmp ecx,eax
	jg y1
RET

;============================================================
AddColoredVertLines:	; 2
	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue
	
	push esi
	pop edi				; copy

	mov ecx,PICH
y2:
	push ecx
	mov iy,ecx
	
	mov ecx,PICW
x2:
	mov ix,ecx

	Call near GetAddr

	mov eax,culB
	mov byte[esi],aL
	mov eax,culG
	mov byte[esi+1],aL
	mov eax,culR
	mov byte[esi+2],aL
	
	push edi			; reset
	pop esi
	
	mov eax,Increment
	sub ecx,eax
	xor eax,eax
	cmp ecx,eax
	jg x2

	pop ecx
	dec ecx
	jnz y2
	
RET

;============================================================
AddColoredDots:	; 3

	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue
	
	push esi
	pop edi				; copy

	mov ecx,PICH
y3:
	push ecx
	mov iy,ecx
	
	mov ecx,PICW
x3:
	mov ix,ecx

	Call near GetAddr

	mov eax,culB
	mov byte[esi],aL
	mov eax,culG
	mov byte[esi+1],aL
	mov eax,culR
	mov byte[esi+2],aL
	
	push edi			; reset
	pop esi
	
	mov eax,Increment
	sub ecx,eax
	xor eax,eax
	cmp ecx,eax
	jg x3

	pop ecx
	mov eax,Increment
	sub ecx,eax
	xor eax,eax
	cmp ecx,eax
	jg y3

RET
;============================================================
DiffuseColorX:	; 4

;%define zRand1	   [ebp-40] ; Rnd1 or 0.9 from VB
;%define zRand2    [ebp-44] ; Rnd2 or 0.1 from VB
;%define ix	       [ebp-48]	
;%define iy        [ebp-52]
;%define culB	   [ebp-56]	
;%define culG	   [ebp-60]	
;%define culR	   [ebp-64]	
;%define offset    [ebp-68]
;%define ABSY      [ebp-72]
;%define ABSX      [ebp-76]
;%define A         [ebp-80]
;%define numbr     [ebp-84]
;%define ixx	   [ebp-88]
;%define iyy	   [ebp-92]
;%define cul	   [ebp-96]	
;%define zNV	   [ebp-100]	; varying zN

%define zN		[ebp-40] ; zN = .9 for Diffuse REDEFINED OK
%define zN2		[ebp-44] ; zN2 = 0.1

	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue
	
	push esi
	pop edi				; copy

	mov eax,Increment
	add eax,2
	shr eax,1			;(Increment+2)\2
	cmp eax,5
	jne i4
	mov eax,4
i4:
	mov offset,eax
	;-----------------------------------

	mov ecx,offset
	inc ecx				; iy = 1+offset to PICH - offset
	
IY4:
	mov iy,ecx
	push ecx

	mov ecx,offset
	inc ecx				; ix = 1+offset to PICW -offset

IX4:
	mov ix,ecx
	push ecx

	; Get LongCul @ ix,iy
	Call near GetAddr
	xor eax,eax
	mov aL,byte[esi]		; B
	shl eax,8
	mov aL,byte[esi+1]		; G
	shl eax,8
	mov aL,byte[esi+2]		; R
	
	push edi
	pop esi
	
	cmp eax,QBLongColor
	jne near nex4	
	;---------------

	mov eax,offset
	neg eax
	mov ecx,eax		; ecx = OFFY = -offset to offset

iyoff4:
	push ecx

	mov eax,iy
	add eax,ecx
	mov iyy,eax			; iyy=iy+OFFY
	
	mov eax,zN 
	mov zNV,eax		; zN = 0.9

	mov ABSY,ecx
	fild dword ABSY
	fabs
	fistp dword ABSY	; ABSY=Abs(OFFY)
	
	
	mov eax,offset
	neg eax
	mov ecx,eax		; ecx = OFFX = -offset to offset

ixoff4:
	mov eax,ix
	add eax,ecx
	mov ixx,eax		; ixx=ix+OFFX

	;---------------
	
	mov eax,ABSY
	mov A,eax

	mov ABSX,ecx		; OFFX
	fild dword ABSX
	fabs
	fistp dword ABSX    ; ABSX=Abs(OFFX)
	
	mov eax,ABSX
	cmp eax,A			; ABSX-A
	jl oxltoy			; A=ABSY
	mov A,eax			; A=ABSX
oxltoy:

	Call near EvalNewzN
	Call near GetAddrxxyy	
	Call near FillPalBGR
	
	push edi
	pop esi

	;---------------
	inc ecx			; OFFX=OFFX+1
	mov eax,offset
	cmp ecx,eax		; OFFX-offset
	jle near ixoff4

	pop ecx
	inc ecx			; OFFY=OFFY+1
	mov eax,offset
	cmp ecx,eax		; OFFY-offset
	jle near iyoff4
	;---------------

nex4:
	push edi
	pop esi

	pop ecx
	inc ecx			; ix+1
	mov eax,PICW
	sub eax,offset
	cmp ecx,eax		; ix - (PICW-offset)
	jle near IX4

	pop ecx
	inc ecx			; iy+1
	mov eax,PICH
	sub eax,offset
	cmp ecx,eax		; iy-(PICH-offset)
	jle near IY4


RET
;============================================================

EvalNewzN:	; For DiffuseColorX  In: offset, A, numbr zRand1=0.9, 
			;					 Out: zRand2 = new zN
			;					 eax used
	; A= ABSY or ABSX
	mov eax,offset
	sub eax,A
	mov A,eax		; A= offset-A
	
	fld dword zN	; 0.9
	fld dword zN2	; 0.1
	fild dword A	; (offset-A),0.1,0.9
	fmulp st1		; 0.1*(offset-A),0.9
	fsubp st1		; 0.9 - 0.1*(offset-A)
	fstp dword zNV	; new zN
RET

;============================================================
FillPalBGR:   ; For DiffuseColorX  esi->B, zRand2=zN, eax used
	;...................................
	movzx eax,byte[esi]
	mov cul,eax
	
	fld dword zNV
	fild dword cul
	fmulp st1			;zN*PalBGR(1,ixx,iyy,2)
	fld1
	fld dword zNV
	fsubp st1			;1-zN, zN*PalBGR(1,ixx,iyy,2)
	fild dword culB
	fmulp st1			;(1-zN)*QBBlue, ,zN*PalBGR(1,ixx,iyy,2)
	faddp st1			;zN*PalBGR()+(1-zN)*QBBlue
	fistp dword cul
	
	mov eax,cul
	cmp eax,255
	jle culB4OK
	mov eax,255
	mov cul,eax
culB4OK:
	mov eax,cul
	mov byte[esi],aL
	;...................................
	;...................................
	movzx eax,byte[esi+1]
	mov cul,eax
	
	fld dword zNV
	fild dword cul
	fmulp st1			;zN*PalBGR(2,ixx,iyy,2)
	fld1
	fld dword zNV
	fsubp st1			;1-zN
	fild dword culG
	fmulp st1			;(1-zN)*QBGreen
	faddp st1			;zN*PalBGR()+(1-zN)*QBGreen
	fistp dword cul
	
	mov eax,cul
	cmp eax,255
	jle culG4OK
	mov eax,255
	mov cul,eax
culG4OK:
	mov eax,cul
	mov byte[esi+1],aL
	;...................................
	;...................................
	movzx eax,byte[esi+2]
	mov cul,eax
	
	fld dword zNV
	fild dword cul
	fmulp st1			;zN*PalBGR(3,ixx,iyy,2)
	fld1
	fld dword zNV
	fsubp st1			;1-zN
	fild dword culR
	fmulp st1			;(1-zN)*QBRed
	faddp st1			;zN*PalBGR()+(1-zN)*QBRed
	fistp dword cul
	
	mov eax,cul
	cmp eax,255
	jle culR4OK
	mov eax,255
	mov cul,eax
culR4OK:
	mov eax,cul
	mov byte[esi+2],aL
	;...................................
RET
;============================================================

GetAddr:	; In esi-> PalBGR(1,1,1,2),ix,iy  Out: new esi->B
	;B = esi + (4 * (iy-1) * PICW + 4 * (ix-1))
	;B = esi + 4 * [(iy-1) * PICW + (ix-1))]
	mov eax,iy
	dec eax
	mov ebx,PICW
	mul ebx
	mov ebx,ix
	dec ebx
	add eax,ebx
	shl eax,2		; x4
	add esi,eax
RET
;============================================================

GetAddrxxyy:	; In esi-> PalBGR(1,1,1,2),ixx,iyy  Out: new esi->B
	;B = esi + (4 * (iy-1) * PICW + 4 * (ix-1))
	;B = esi + 4 * [(iy-1) * PICW + (ix-1))]
	mov eax,iyy
	dec eax
	mov ebx,PICW
	mul ebx
	mov ebx,ixx
	dec ebx
	add eax,ebx
	shl eax,2		; x4
	add esi,eax
RET
;============================================================
DiffuseColorXUp:	; 5

;%define zN			[ebp-40] ; zN = .9 for Diffuse REDEFINED OK
;%define zN2		[ebp-44] ; zN2 = 0.1
;%define ix			[ebp-48]	
;%define iy			[ebp-52]
;%define culB		[ebp-56]	
;%define culG		[ebp-60]	
;%define culR		[ebp-64]	
;%define offset		[ebp-68]
;%define ABSY		[ebp-72]
;%define ABSX		[ebp-76]
;%define A			[ebp-80]
;%define numbr		[ebp-84]
;%define ixx		[ebp-88]
;%define iyy		[ebp-92]
;%define cul		[ebp-96]	
;%define zNV		[ebp-100]	; varying zN

	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue
	
	push esi
	pop edi				; copy

	mov eax,Increment
	add eax,2
	shr eax,1			;(Increment+2)\2
	cmp eax,5
	jne i5
	mov eax,4
i5:
	mov offset,eax
	;-----------------------------------

	mov ecx,1		; iy = 1 to PICH - offset
	
IY5:
	mov iy,ecx
	push ecx

	mov ecx,1		; ix = 1 to PICW 

IX5:
	mov ix,ecx
	mov ixx,ecx
	
	push ecx

	; Get LongCul @ ix,iy
	Call near GetAddr
	xor eax,eax
	mov aL,byte[esi]		; B
	shl eax,8
	mov aL,byte[esi+1]		; G
	shl eax,8
	mov aL,byte[esi+2]		; R
	
	push edi
	pop esi
	
	cmp eax,QBLongColor
	jne near nex5	
	;=======================

	mov eax,zN 
	mov zNV,eax		; zN = 0.9

	mov eax,offset
	mov ecx,eax		; OFFY = offset to 0

iyoff5:

	mov eax,iy
	add eax,ecx
	mov iyy,eax	    ; iyy=iy+OFFY
	
	;------------------------------

	fld dword zNV
	fld dword zN2	; 0.1,zNV
	fsubp st1		; zNV-0.1
	fstp dword zNV
	
	Call near GetAddrxxyy	
	Call near FillPalBGR
	
	push edi
	pop esi

	;------------------------------
	dec ecx			; OFFY=OFFY-1
	jnz near iyoff5

	;=======================
nex5:

	pop ecx
	inc ecx			; ix+1
	cmp ecx,PICW	; ix - PICW
	jle near IX5

ney5:	
	pop ecx
	inc ecx			; iy+1
	mov eax,PICH
	sub eax,offset
	cmp ecx,eax		; iy-(PICH-offset)
	jle near IY5

RET
;============================================================

DiffuseColorXDown:	; 6
	
	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue
	
	push esi
	pop edi				; copy

	mov eax,Increment
	add eax,2
	shr eax,1			;(Increment+2)\2
	cmp eax,5
	jne i6
	mov eax,4
i6:
	mov offset,eax
	;-----------------------------------

	mov ecx,1
	add ecx,eax		; iy = 1+offset to PICH
	
IY6:
	mov iy,ecx
	push ecx

	mov ecx,1		; ix = 1 to PICW 

IX6:
	mov ix,ecx
	mov ixx,ecx
	
	push ecx

	; Get LongCul @ ix,iy
	Call near GetAddr
	xor eax,eax
	mov aL,byte[esi]		; B
	shl eax,8
	mov aL,byte[esi+1]		; G
	shl eax,8
	mov aL,byte[esi+2]		; R
	
	push edi
	pop esi
	
	cmp eax,QBLongColor
	jne near nex6	
	;=======================

	mov eax,zN 
	mov zNV,eax		; zN = 0.9

	mov eax,offset
	neg eax
	mov ecx,eax		; OFFY = -offset to 0

iyoff6:

	mov eax,iy
	add eax,ecx
	mov iyy,eax	    ; iyy=iy+OFFY
	
	;------------------------------

	fld dword zNV
	fld dword zN2	; 0.1,zNV
	fsubp st1		; zNV-0.1
	fstp dword zNV
	
	Call near GetAddrxxyy	
	Call near FillPalBGR
	
	push edi
	pop esi

	;------------------------------
	inc ecx			; OFFY=OFFY+1
	jnz near iyoff6

	;=======================
nex6:

	pop ecx
	inc ecx			; ix+1
	cmp ecx,PICW	; ix - PICW
	jle near IX6

	pop ecx
	inc ecx			; iy+1
	cmp ecx,PICH	; iy-PICH
	jle near IY6
RET
;============================================================

DiffuseColorXLeft:	; 7

	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue
	
	push esi
	pop edi				; copy

	mov eax,Increment
	add eax,2
	shr eax,1			;(Increment+2)\2
	cmp eax,5
	jne i7
	mov eax,4
i7:
	mov offset,eax
	;-----------------------------------

	mov ecx,1		; iy = 1 to PICH
	
IY7:
	mov iy,ecx
	mov iyy,ecx
	push ecx

	mov ecx,1
	mov eax,offset
	add ecx,eax		; ix = 1+offset to PICW
	
IX7:
	mov ix,ecx
	
	push ecx

	; Get LongCul @ ix,iy
	Call near GetAddr
	xor eax,eax
	mov aL,byte[esi]		; B
	shl eax,8
	mov aL,byte[esi+1]		; G
	shl eax,8
	mov aL,byte[esi+2]		; R
	
	push edi
	pop esi
	
	cmp eax,QBLongColor
	jne near nex7	
	;=======================

	mov eax,zN 
	mov zNV,eax		; zN = 0.9

	mov eax,offset
	neg eax
	mov ecx,eax		; OFFX = -offset to 0

ixoff7:

	mov eax,ix
	add eax,ecx
	mov ixx,eax	    ; ixx=ix+OFFX
	
	;------------------------------

	fld dword zNV
	fld dword zN2	; 0.1,zNV
	fsubp st1		; zNV-0.1
	fstp dword zNV
	
	Call near GetAddrxxyy	
	Call near FillPalBGR
	
	push edi
	pop esi

	;------------------------------
	inc ecx			; OFFX=OFFX+1
	jnz near ixoff7

	;=======================
nex7:

	pop ecx
	inc ecx			; ix+1
	cmp ecx,PICW	; ix - PICW
	jle near IX7

	pop ecx
	inc ecx			; iy+1
	cmp ecx,PICH	; iy-PICH
	jle near IY7

RET
;============================================================
DiffuseColorXRight:	; 8

	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue
	
	push esi
	pop edi				; copy

	mov eax,Increment
	add eax,2
	shr eax,1			;(Increment+2)\2
	cmp eax,5
	jne i8
	mov eax,4
i8:
	mov offset,eax
	;-----------------------------------

	mov ecx,1		; iy = 1 to PICH
	
IY8:
	mov iy,ecx
	mov iyy,ecx
	push ecx

	mov ecx,1		; ix = 1 to PICW-offset
	
IX8:
	mov ix,ecx
	
	push ecx

	; Get LongCul @ ix,iy
	Call near GetAddr
	xor eax,eax
	mov aL,byte[esi]		; B
	shl eax,8
	mov aL,byte[esi+1]		; G
	shl eax,8
	mov aL,byte[esi+2]		; R
	
	push edi
	pop esi
	
	cmp eax,QBLongColor
	jne near nex8	
	;=======================

	mov eax,zN 
	mov zNV,eax		; zN = 0.9

	mov eax,offset
	mov ecx,eax		; OFFX = offset to 0

ixoff8:

	mov eax,ix
	add eax,ecx
	mov ixx,eax	    ; ixx=ix+OFFX
	
	;------------------------------

	fld dword zNV
	fld dword zN2	; 0.1,zNV
	fsubp st1		; zNV-0.1
	fstp dword zNV
	
	Call near GetAddrxxyy	
	Call near FillPalBGR
	
	push edi
	pop esi

	;------------------------------
	dec ecx			; OFFX=OFFX-1
	jnz near ixoff8

	;=======================
nex8:

	pop ecx
	inc ecx			; ix+1
	mov eax,PICW
	sub eax,offset	; PICW-offset
	cmp ecx,PICW	; ix - (PICW-offset)
	jle near IX8

	pop ecx
	inc ecx			; iy+1
	cmp ecx,PICH	; iy-PICH
	jle near IY8

RET
;============================================================
BrightSpotXpYp:	;9

;%define zN			[ebp-40] ; zN = .9 for Diffuse REDEFINED OK
;%define zN2		[ebp-44] ; zN2 = 0.1
;%define ix			[ebp-48]	
;%define iy			[ebp-52]
;%define culB		[ebp-56]	
;%define culG		[ebp-60]	
;%define culR		[ebp-64]	
;%define offset		[ebp-68]
;%define ABSY		[ebp-72]
;%define ABSX		[ebp-76]
;%define A			[ebp-80]
;%define numbr		[ebp-84]
;%define ixx		[ebp-88]
;%define iyy		[ebp-92]
;%define cul		[ebp-96]	
;%define zNV		[ebp-100]	; varying zN

%define Xp		[ebp-40] ; iXp from VB
%define Yp		[ebp-44] ; iYp from VB
%define rad     [ebp-68]
%define theta   [ebp-72]
%define zFrac	[ebp-76]
%define d2r		[ebp-80]	; pi/180, deg to rads

	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue
	
	push esi
	pop edi				; copy

	mov eax,24
	mov numbr,eax
	
	mov eax,180
	mov d2r,eax
	
	fldpi
	fild dword d2r		;180, pi
	fdivp st1			;pi/180
	fstp dword d2r
	
	mov ecx,1			; rad=1 to 24*Increment
rad9:
	push ecx
	mov rad,ecx
	;====================
	; Calc 1+zFrac
	fld1				; 1
	fild dword rad		; rad, 1
	fild dword Increment
	fild dword numbr
	fmulp st1			; (24*Increment), rad, 1
	fdivp st1			; rad/(24*Increment), 1
	fsubp st1			; zFrac = 1 - rad/(24*Increment)
	fld1
	faddp st1
	fstp dword zFrac	; 1+zFrac
	
	mov ecx,359			; theta = 359 to 0
theta9:
	mov theta,ecx
	;-----------	
	; Calc ix
	fild dword theta
	fld dword d2r
	fmulp st1
	fsin
	fild dword rad
	fmulp st1			; rad*sin(theta*d2r)
	fld dword Xp
	faddp st1			; iXp+rad*sin(theta*d2r)
	fistp dword ix
	
	; Calc iy
	fild dword theta
	fld dword d2r
	fmulp st1
	fcos
	fild dword rad
	fmulp st1			; rad*cos(theta*d2r)
	fild dword PICH
	fld dword Yp		; Yp, PICH
	fsubp st1			; PICH-Yp
	faddp st1			; (PICh-iYp)+rad*cos(theta*d2r)
	fistp dword iy
	
	; Ensure ix,iy in-range
	
	mov eax,ix
	cmp eax,1
	jl nextheta9
	cmp eax,PICW
	jg nextheta9
	mov eax,iy
	cmp eax,1
	jl nextheta9
	cmp eax,PICH
	jg nextheta9
	
	; Modify BGR
	Call near GetAddr
	
	Call near FillModTestBGR
	
	push edi
	pop esi
	
nextheta9:
	;-----------	
	dec ecx
	jnz theta9
	;====================
	pop ecx
	inc ecx				; rad=rad+1
	mov eax,Increment
	mov ebx,24
	mul ebx
	cmp ecx,eax			;rad-(24*Increment)
	jle near rad9
RET

;============================================================
FillModTestBGR:	;In: esi, (1+zFrac) in zFrac
				; Calc culBGR = PalBGR()*(1+zFrac)
	movzx eax,byte[esi]	; B
	mov cul,eax
	fild dword cul
	fld dword zFrac
	fmulp st1
	fistp dword cul
	mov eax,cul
	cmp eax,255
	jbe BT0
	mov eax,culB
	jmp BOK
BT0:
	cmp eax,0
	jae BOK
	xor eax,eax
BOK:
	mov byte[esi],aL
	;-----------------
	movzx eax,byte[esi+1]	; G
	mov cul,eax
	fild dword cul
	fld dword zFrac
	fmulp st1
	fistp dword cul
	mov eax,cul
	cmp eax,255
	jbe GT0
	mov eax,culG
	jmp GOK
GT0:
	cmp eax,0
	jae GOK
	xor eax,eax
GOK:
	mov byte[esi+1],aL
	;-----------------
	movzx eax,byte[esi+2]	; R
	mov cul,eax
	fild dword cul
	fld dword zFrac
	fmulp st1
	fistp dword cul
	mov eax,cul
	cmp eax,255
	jbe RT0
	mov eax,culR
	jmp ROK
RT0:
	cmp eax,0
	jae ROK
	xor eax,eax
ROK:
	mov byte[esi+2],aL
	;-----------------
RET
	

;============================================================
;============================================================
	;mov ebx,[ebp+20]
	;mov [ebx],eax
	;ret
	;jmp GETOUT

;mov eax,ecx
;mov ebx,[ebp+20]
;mov [ebx],eax

;============================================================
;RANDNOISE:		; Out: aL & Seed = rand(0-255)
;	mov eax,011813h	 	; 71699 prime 
;	imul DWORD Seed
;	add eax, 0AB209h 	; 700937 prime
;
;
;	rcr eax,1			; leaving out gives vertical lines plus
;						; faint horizontal ones, tartan
;
;	;----------------------------------------
;	jc ok				; these 2 have little effect
;	rol eax,1			;
;ok:						;
;	;----------------------------------------
;	
;	;----------------------------------------
;	;dec eax			; these produce vert lines
;	;inc eax			; & with fsin marble arches
;	;----------------------------------------
;
;	mov Seed,eax	; save seed
;	and eax,255
;	mov aran,eax	; aran = rnd(0-255)
;RET
;============================================================
