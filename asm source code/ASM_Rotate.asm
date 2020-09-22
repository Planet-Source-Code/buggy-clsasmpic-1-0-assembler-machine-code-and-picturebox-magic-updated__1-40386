; ASM_Rotate.asm  by Robert Rayment  7/11/01

; VB

;zParam1 = iXp
;zParam2 = iYp
;
;RANG in whole degrees
;
;Select Case chkRotateIndex
;
;Case 0, 2   ' SIMPLE ROTATE   0(display)  2(perm)
;   MCODE.OpCode = chkRotateIndex
;   res = CallWindowProc(ptMC, ptrStruc, zParam1, zParam2, RANG)
;Case 1, 3   ' ANTI-ALIAS ROTATE   1(display)  3(perm)
;   MCODE.OpCode = chkRotateIndex
;   res = CallWindowProc(ptMC, ptrStruc, zParam1, zParam2, RANG)
;End Select


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

; Rotate
; OpCode& = 0	'Rotate32
; OpCode& = 1	'AARotate32
; OpCode& = 2	'Rotate12
; OpCode& = 3	'AARotate12
;   
; res = CallWindowProc(ptMC, ptrStruc, zParam1, zParam2, RANG)
;                      [ebp +  8        12       16       20 ]


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

%define Xp	  	 [ebp-40] ; from VB
%define Yp    	 [ebp-44] ; from VB
%define ix	       [ebp-48]	
%define iy         [ebp-52]
%define culB	   [ebp-56]	
%define culG	   [ebp-60]	
%define culR	   [ebp-64]	
%define RANG       [ebp-68]
%define zCos       [ebp-72]
%define zSin       [ebp-76]
%define Half       [ebp-80]
%define numbr      [ebp-84]
%define ixs		   [ebp-88]
%define iys		   [ebp-92]
%define xs	 	   [ebp-96]	
%define ys	 	   [ebp-100]	
%define xsf	 	   [ebp-104]	; scale factors	
%define ysf	 	   [ebp-108]	

%define culBT 	   [ebp-112]	; Temps
%define culGT 	   [ebp-116]	
%define culRT 	   [ebp-120]	

[bits 32]

	push ebp
	mov ebp,esp
	sub esp,120
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
	mov Xp,eax			; rotation point from VB
	mov eax,[ebp+16]
	mov Yp,eax
	mov eax,[ebp+20]
	mov RANG,eax
	
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
	
	; Get sin(RANG) & Cos(RANG)
	mov eax,180
	mov numbr,eax
	fldpi
	fild dword numbr	; 180, pi
	fdivp st1			; pi/180
	fild dword RANG
	fmulp st1			; RANG in radians
	fsincos
	fstp dword zCos		; Cos(RANG)
	fstp dword zSin		; Sin(RANG)
	
	; Make Yp PICH-Yp
	fild dword PICH
	fld dword Yp		; Yp, PICH
	fsubp st1			; PICH-Yp
	fstp dword Yp
	
	; Get 0.5 for int round down
	mov eax,2
	mov Half,eax
	fld1		
	fild dword Half		; 2, 1
	fdivp st1			; 1/2
	fstp dword Half

; Rotate
; OpCode& = 0	'Rotate32
; OpCode& = 1	'AARotate32
; OpCode& = 2	'Rotate12
; OpCode& = 3	'AARotate12

	mov eax,OpCode
	cmp eax,0
	jne Test1
	Call near Rotate32
	jmp near GETOUT
Test1:
	cmp eax,1
	jne Test2
	Call near AARotate32
	jmp near GETOUT
Test2:
	cmp eax,2
	jne Test3
	Call near Rotate12
	jmp near GETOUT
Test3:
	cmp eax,3
	jne Test4
	Call near AARotate12
	jmp near GETOUT
Test4:

GETOUT:
	pop ebx
	pop esi
	pop edi
	mov esp,ebp
	pop ebp
	ret 16

;############################################################
;============================================================

Rotate32:		;0		Rotate(display) 3 into 2
	
	mov edi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add edi,eax			; pts to DEST PalBGR(1,1,1,2) Blue
	
	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue
	add esi,eax			; pts to SOURCE PalBGR(1,1,1,3) Blue
	
	Call SimpleRotate

RET
;============================================================

AARotate32:	; 1			Anti-alias Rotate(display) 3 into 2

	mov edi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add edi,eax			; pts to DEST PalBGR(1,1,1,2) Blue
	
	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue
	add esi,eax			; pts to SOURCE PalBGR(1,1,1,3) Blue

	Call near AARotate

RET
;============================================================

Rotate12:	; 2			Rotate(perm) 1 into 2


	mov edi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add edi,eax			; pts to DEST PalBGR(1,1,1,2) Blue
	
	mov esi,PtrPalBGR   ; pts to SOURCE PalBGR(1,1,1,1)

	Call SimpleRotate

RET

;============================================================

AARotate12:	; 3			Anti-alias Rotate 1 into 2


	mov edi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add edi,eax			; pts to DEST PalBGR(1,1,1,2) Blue
	
	mov esi,PtrPalBGR   ; pts to SOURCE PalBGR(1,1,1,1)


	Call near AARotate


RET

;============================================================
;============================================================
SimpleRotate:		; 0 & 2

	mov eax,PICH
	mov ecx,eax
IY0:
	mov iy,ecx
	push ecx
	
	mov eax,PICW
	mov ecx,eax
IX0:
	mov ix,ecx
	;-----------------------
	; Get ixs
	fild dword ix
	fld dword Xp
	fsubp st1			; (ix-Xp)
	fld dword zCos
	fmulp st1			; (ix-Xp)*zCos
	fild dword iy
	fld dword Yp
	fsubp st1			; (iy-Yp)
	fld dword zSin
	fmulp st1			; (iy-Yp)*zSin, (ix-Xp)*zCos
	fsubp st1			; (ix-Xp)*zCos - (iy-Yp)*zSin
	fld dword Xp
	faddp st1			; Xp + (ix-Xp)*zCos - (iy-Yp)*zSin
	fistp dword ixs

	; Test if ixs in-range
	mov eax,ixs
	cmp eax,1
	jl QB0
	cmp eax,PICW
	jle Getiys0
QB0:
	;edi->blue in 2
	push edi
	
	Call GetAddrEDIixiy
	
	mov eax,culB
	mov byte[edi],aL
	mov eax,culG
	mov byte[edi+1],aL
	mov eax,culR
	mov byte[edi+2],aL
	
	pop edi
	jmp nexix0

Getiys0:
	fild dword iy
	fld dword Yp
	fsubp st1			; (iy-Yp)
	fld dword zCos
	fmulp st1			; (iy-Yp)*zCos
	fild dword ix
	fld dword Xp
	fsubp st1			; (ix-Xp)
	fld dword zSin
	fmulp st1			; (ix-Xp)*zSin, (iy-Yp)*zCos
	faddp st1			; (iy-Yp)*zCos + (ix-Xp)*zSin
	fld dword Yp
	faddp st1			; Yp + (iy-Yp)*zCos + (ix-Xp)*zSin
	fistp dword iys
	
	; Test if iys in-range
	mov eax,iys
	cmp eax,1
	jl QB00
	cmp eax,PICH
	jle FillBGR0
QB00:
	;edi->blue in 2
	push edi
	
	Call GetAddrEDIixiy	
	
	mov eax,culB
	mov byte[edi],aL
	mov eax,culG
	mov byte[edi+1],aL
	mov eax,culR
	mov byte[edi+2],aL
	
	pop edi
	jmp nexix0

FillBGR0:
	; BGR @ ixs,iys in 3 -> ix,iy in 2
	; esi->3  edi->2
	
	push edi
	push esi
	
	Call GetAddrESIixsiys		; 3 @ ixs,iys
	Call GetAddrEDIixiy			; 2 @ ix,iy
	
	mov aL,byte [esi]
	mov byte [edi],aL
	mov aL,byte [esi+1]
	mov byte [edi+1],aL
	mov aL,byte [esi+2]
	mov byte [edi+2],aL

	pop esi
	pop edi
	
	;-----------------------
nexix0:
	dec ecx
	jnz near IX0
	
	pop ecx
	dec ecx
	jnz near IY0
RET
;============================================================

AARotate:

	mov eax,PICH
	mov ecx,eax
IY1:
	mov iy,ecx
	push ecx
	
	mov eax,PICW
	mov ecx,eax
IX1:
	mov ix,ecx
	;-----------------------
	; Get xs
	fild dword ix
	fld dword Xp
	fsubp st1			; (ix-Xp)
	fld dword zCos
	fmulp st1			; (ix-Xp)*zCos
	fild dword iy
	fld dword Yp
	fsubp st1			; (iy-Yp)
	fld dword zSin
	fmulp st1			; (iy-Yp)*zSin, (ix-Xp)*zCos
	fsubp st1			; (ix-Xp)*zCos - (iy-Yp)*zSin
	fld dword Xp
	faddp st1			; Xp + (ix-Xp)*zCos - (iy-Yp)*zSin
	fstp dword xs		; REAL
	; Get ys
	fild dword iy
	fld dword Yp
	fsubp st1			; (iy-Yp)
	fld dword zCos
	fmulp st1			; (iy-Yp)*zCos
	fild dword ix
	fld dword Xp
	fsubp st1			; (ix-Xp)
	fld dword zSin
	fmulp st1			; (ix-Xp)*zSin, (iy-Yp)*zCos
	faddp st1			; (iy-Yp)*zCos + (ix-Xp)*zSin
	fld dword Yp
	faddp st1			; Yp + (iy-Yp)*zCos + (ix-Xp)*zSin
	fstp dword ys		; REAL
	;-----------------------
	; Get ixs,iys  INTEGERS
	fld dword xs
	fld dword Half		; 0.5, xs
	fsubp st1			; xs-0.5
	fistp dword ixs		; truncated xs

	fld dword ys
	fld dword Half		; 0.5, ys
	fsubp st1			; ys-0.5
	fistp dword iys		; truncated ys
	
	
	; Check in-range
	mov eax,ixs
	cmp eax,1
	jl QB1
	cmp eax,PICW
	jge QB1
	mov eax,iys
	cmp eax,1
	jl QB1
	cmp eax,PICH
	jge QB1
	jmp InRange
QB1:
	;edi->blue in 2
	push edi
	
	Call GetAddrEDIixiy
	
	mov eax,culB
	mov byte[edi],aL
	mov eax,culG
	mov byte[edi+1],aL
	mov eax,culR
	mov byte[edi+2],aL
	
	pop edi
	jmp near nexix1
	;-----------------------
InRange:
	; Get scale factors xsf=xs-ixs, ysf=ys-iys
	fld dword xs
	fild dword ixs
	fsubp st1		; xs-ixs
	fstp dword xsf
	
	fld dword ys
	fild dword iys
	fsubp st1		; ys-iys
	fstp dword ysf
	
	; Pick up from 3 esi
	
	push esi
	
	Call near GetAddrESIixsiys

	mov ebx,PICW
	shl ebx,2				; 4*PICW
	;===================================
	; Get weighted Blue over 4 points
	; y, x->x+1
	movzx eax,byte[esi]		; B
	mov culBT,eax
	fild dword culBT
	movzx eax,byte[esi+4]	; B+1
	mov culBT,eax
	fild dword culBT		; P2, P1
	fsub st1				; (P2-P1), P1
	fld dword xsf
	fmulp st1				; xsf*(P2-P1), P1
	faddp st1				; PA = P1 + xsf*(P2-P1)
	; y+1, x->x+1
	movzx eax,byte[esi+ebx]	; B
	mov culBT,eax
	fild dword culBT
	movzx eax,byte[esi+ebx+4]	; B+1
	mov culBT,eax
	fild dword culBT		; P4, P3
	fsub st1				; (P4-P3), P3
	fld dword xsf
	fmulp st1				; xsf*(P4-P3), P3
	faddp st1				; PB= P3 + xsf*(P4-P3), PA
	; y->y+1
	fsub st1				; (PB-PA), PA
	fld dword ysf
	fmulp st1				; ysf*(PB-PA), PA
	faddp st1				; PA + ysf*(PB-PA)
	
	fistp dword culBT
	;===================================
	
	; Get weighted Green over 4 points
	
	inc esi	; GREEN
	
	movzx eax,byte[esi]		; G
	mov culGT,eax
	fild dword culGT
	movzx eax,byte[esi+4]	; G+1
	mov culGT,eax
	fild dword culGT		; P2, P1
	fsub st1				; (P2-P1), P1
	fld dword xsf
	fmulp st1				; xsf*(P2-P1), P1
	faddp st1				; PA = P1 + xsf*(P2-P1)
	
	movzx eax,byte[esi+ebx]	; G
	mov culGT,eax
	fild dword culGT
	movzx eax,byte[esi+ebx+4]	; B+1
	mov culGT,eax
	fild dword culGT		; P4, P3
	fsub st1				; (P4-P3), P3
	fld dword xsf
	fmulp st1				; xsf*(P4-P3), P3
	faddp st1				; PB= P3 + xsf*(P4-P3), PA
	
	fsub st1				; (PB-PA), PA
	fld dword ysf
	fmulp st1				; ysf*(PB-PA), PA
	faddp st1				; PA + ysf*(PB-PA)
	
	fistp dword culGT
	;===================================

	; Get weighted Red over 4 points
	
	inc esi	; RED  
	
	movzx eax,byte[esi]		; R
	mov culRT,eax
	fild dword culRT
	movzx eax,byte[esi+4]	; R+1
	mov culRT,eax
	fild dword culRT		; P2, P1
	fsub st1				; (P2-P1), P1
	fld dword xsf
	fmulp st1				; xsf*(P2-P1), P1
	faddp st1				; PA = P1 + xsf*(P2-P1)
	
	movzx eax,byte[esi+ebx]	; R
	mov culRT,eax
	fild dword culRT
	movzx eax,byte[esi+ebx+4]	; R+1
	mov culRT,eax
	fild dword culRT		; P4, P3
	fsub st1				; (P4-P3), P3
	fld dword xsf
	fmulp st1				; xsf*(P4-P3), P3
	faddp st1				; PB= P3 + xsf*(P4-P3), PA
	
	fsub st1				; (PB-PA), PA
	fld dword ysf
	fmulp st1				; ysf*(PB-PA), PA
	faddp st1				; PA + ysf*(PB-PA)
	
	fistp dword culRT
	;===================================

	pop esi
	

	; Ensure colors in range
	Call near CheckculBGRT
	
	push edi
	
	Call GetAddrEDIixiy
	
	mov eax,culBT
	mov byte[edi],aL
	mov eax,culGT
	mov byte[edi+1],aL
	mov eax,culRT
	mov byte[edi+2],aL
	
	pop edi

	;-----------------------
nexix1:
	dec ecx
	jnz near IX1
	
	pop ecx
	dec ecx
	jnz near IY1

RET
;============================================================
;============================================================

CheckculBGRT:
	
	; Ensure colors in range
	mov eax,255
	cmp culBT,eax	; culBT-255
	jle THG
	mov culBT,eax
THG:
	cmp culGT,eax
	jle THR
	mov culGT,eax
THR:
	cmp culRT,eax
	jle LoLim
	mov culRT,eax
LoLim:
	mov eax,0
	cmp culBT,eax	; culBT-0
	jge TLG
	mov culBT,eax
TLG:
	cmp culGT,eax
	jge TLR
	mov culGT,eax
TLR:
	cmp culRT,eax
	jge CulsDone
	mov culRT,eax

CulsDone:

RET
;============================================================


GetAddrESIixsiys:	; In esi-> PalBGR(1,1,1,2),ix,iy  Out: new esi->B
	;B = esi + (4 * (iy-1) * PICW + 4 * (ix-1))
	;B = esi + 4 * [(iy-1) * PICW + (ix-1))]
	mov eax,iys
	dec eax
	mov ebx,PICW
	mul ebx
	mov ebx,ixs
	dec ebx
	add eax,ebx
	shl eax,2		; x4
	add esi,eax
RET

;============================================================

GetAddrEDIixiy:
	;B = edi + (4 * (iy-1) * PICW + 4 * (ix-1))
	;B = edi + 4 * [(iy-1) * PICW + (ix-1))]
	mov eax,iy
	dec eax
	mov ebx,PICW
	mul ebx
	mov ebx,ix
	dec ebx
	add eax,ebx
	shl eax,2		; x4
	add edi,eax
RET
;============================================================
GetAddrEDIixsiys:	; In edi-> PalBGR(1,1,1,2),ixs,iys  Out: new edi->B
	;B = edi + (4 * (iy-1) * PICW + 4 * (ix-1))
	;B = edi + 4 * [(iy-1) * PICW + (ix-1))]
	mov eax,iys
	dec eax
	mov ebx,PICW
	mul ebx
	mov ebx,ixs
	dec ebx
	add eax,ebx
	shl eax,2		; x4
	add edi,eax
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

