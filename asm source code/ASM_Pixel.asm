;ASM_Pixel.asm  by Robert Rayment  7/11/01

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

; Pixel Effects
; OpCode& = 0    'Smooth (Increment)
; OpCode& = 1    'Contour
; OpCode& = 2    'Emboss
; OpCode& = 3    'Ripple
; OpCode& = 4    'Relief
; OpCode& = 5    'Twirl
;
; res = CallWindowProc(ptMC, ptrStruc, param1, param2, INT)
;                      [ebp +  8        12     16      20 ]
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
%define Mask2	   [ebp-40] 
%define Mask4	   [ebp-44] 
%define Mask8	   [ebp-48] 

%define ix    [ebp-52]
%define iy    [ebp-56]

%define QBBlue	   [ebp-60]	
%define QBGreen	   [ebp-64]	
%define QBRed	   [ebp-68]	
%define culBT 	   [ebp-72]	; Temps
%define culGT 	   [ebp-76]	
%define culRT 	   [ebp-80]	

%define YWave      [ebp-84]

%define radmax     [ebp-88]
%define ixc        [ebp-92]
%define iyc        [ebp-96]
%define zpimul     [ebp-100]
%define zSin       [ebp-104]
%define zCos       [ebp-108]
%define ixs        [ebp-112]
%define iys        [ebp-116]

[bits 32]

	push ebp
	mov ebp,esp
	sub esp,116
	push edi
	push esi
	push ebx
	push edx

	; Copy structure
	mov ebx,[ebp+8]
	
	movab PICW,          [ebx]
	movab PICH,          [ebx+4]
	movab PtrPalBGR,     [ebx+8]
	movab PtrPalLineCopy,[ebx+12]
	movab Increment,     [ebx+16]
	movab QBLongColor,   [ebx+20]
	movab OpCode,        [ebx+24]
	
	mov eax,PICH
	mov ebx,PICW
	mul ebx
	mov PalSize,eax		; In 4 byte chunks
	
	mov eax,PICW
	shl eax,2			; x4
	mov LineBytes,eax
	
	; Get RGB	
	mov eax,QBLongColor
	and eax,0FFh
	mov QBRed,eax
	mov eax,QBLongColor
	and eax,0FF00h
	shr eax,8
	mov QBGreen,eax
	mov eax,QBLongColor
	and eax,0FF0000h
	shr eax,16
	mov QBBlue,eax

	mov eax,0FEFEFEFEh
	mov Mask2,eax
	
	mov eax,0FCFCFCFCh
	mov Mask4,eax

	mov eax,0F8F8F8F8h
	mov Mask8,eax

	mov eax,OpCode
	cmp eax,0
	jne Test1
	Call near Smooth
	jmp near GETOUT
Test1:
	cmp eax,1
	jne Test2
	Call near Contour
	jmp near GETOUT
Test2:
	cmp eax,2
	jne Test3
	Call near Emboss
	jmp near GETOUT
Test3:
	cmp eax,3
	jne Test4
	Call near Ripple
	jmp near GETOUT
Test4:
	cmp eax,4
	jne Test5
	Call near Relief
	jmp near GETOUT
Test5:
	cmp eax,5
	jne Test6
	Call near Twirl
	jmp near GETOUT
Test6:

GETOUT:
	pop edx
	pop ebx
	pop esi
	pop edi
	mov esp,ebp
	pop ebp
	ret 16

;############################################################
;============================================================

Smooth:		; 0
	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue
	push esi
	pop edi				; edi DEST to PalBGR(1,1,1,2) Blue
	add esi,eax			; esi SORCE to PalBGR(1,1,1,3) Blue

	mov eax,Increment
	cmp eax,1
	jne TI2
	Call near Smooth1
	RET
TI2:
	cmp eax,2
	jne TI4
	Call near Smooth2
	RET
TI4:
	cmp eax,4
	jne TI8
	Call near Smooth4
	RET
TI8:
	cmp eax,8
	jne TI16
	Call Near Smooth8
	RET 
TI16:

RET
;============================================================
Smooth1:		; esi->B3   o x o

	mov ecx,PICH	; iy PICH->1
SY1:
	push ecx
	mov iy,ecx

	mov ecx,PICW
	dec ecx			; ix PICW-2 -> 1
	dec ecx
SX1:
	mov ix,ecx
	
	push esi
	push edi
	
	Call near GetAddrESIixiy
	Call near GetAddrEDIixiy
	
	mov eax,[esi]
	and eax,Mask2
	shr eax,1
	
	mov edx,[esi+8]
	and edx,Mask2
	shr edx,1
	add eax,edx
	
	mov [edi+4],eax
	
	pop edi
	pop esi
	
	dec ecx
	jnz SX1
	
	pop ecx
	dec ecx
	jnz SY1
	
RET
;============================================================
Smooth2:		; esi->B3    o 
                ;            x
                ;            o 

	
	mov ecx,PICH	; iy PICH-2->1
	dec ecx
	dec ecx
SY2:
	push ecx
	mov iy,ecx

	mov ecx,PICW	; ix PICW ->1 
SX2:
	mov ix,ecx
	
	push esi
	push edi
	
	Call near GetAddrESIixiy
	Call near GetAddrEDIixiy
	
	mov ebx,PICW
	shl ebx,2

	mov eax,[esi]
	and eax,Mask2
	shr eax,1
	
	mov edx,[esi+ebx+ebx]
	and edx,Mask2
	shr edx,1
	add eax,edx
	
	mov [edi+ebx],eax
	
	pop edi
	pop esi
	
	dec ecx
	jnz SX2
	
	pop ecx
	dec ecx
	jnz SY2

RET
;============================================================
Smooth4:		; esi->B3    o   o
                ;              x
                ;            o   o

	mov ecx,PICH	; iy PICH-2->1
	dec ecx
	dec ecx
SY4:
	push ecx
	mov iy,ecx

	mov ecx,PICW	; ix PICW-2 ->1 
	dec ecx
	dec ecx
SX4:
	mov ix,ecx
	
	push esi
	push edi
	
	Call near GetAddrESIixiy
	Call near GetAddrEDIixiy
	
	mov ebx,PICW
	shl ebx,2
	
	mov eax,[esi]
	and eax,Mask4
	shr eax,2
	
	mov edx,[esi+ebx+ebx]
	and edx,Mask4
	shr edx,2
	add eax,edx
	
	mov edx,[esi+8]
	and edx,Mask4
	shr edx,2
	add eax,edx
	
	mov edx,[esi+ebx+ebx+8]
	and edx,Mask4
	shr edx,2
	add eax,edx
	
	
	mov [edi+ebx+4],eax
	
	pop edi
	pop esi
	
	dec ecx
	jnz SX4
	
	pop ecx
	dec ecx
	jnz SY4

RET
;============================================================
Smooth8:        ; esi->B3    o o o
                ;            o x o
                ;            o o o
                
                
	mov ecx,PICH	; iy PICH-2->1
	dec ecx
	dec ecx
SY8:
	push ecx
	mov iy,ecx

	mov ecx,PICW	; ix PICW-2 ->1 
	dec ecx
	dec ecx
SX8:
	mov ix,ecx
	
	push esi
	push edi
	
	Call near GetAddrESIixiy
	Call near GetAddrEDIixiy
	
	mov ebx,PICW
	shl ebx,2
	
	mov eax,[esi]
	and eax,Mask8
	shr eax,3
	mov edx,[esi+ebx]
	and edx,Mask8
	shr edx,3
	add eax,edx
	mov edx,[esi+ebx+ebx]
	and edx,Mask8
	shr edx,3
	add eax,edx

	mov edx,[esi+4]
	and edx,Mask8
	shr edx,3
	add eax,edx
	mov edx,[esi+ebx+ebx+4]
	and edx,Mask8
	shr edx,3
	add eax,edx
	
	mov edx,[esi+8]
	and edx,Mask8
	shr edx,3
	add eax,edx
	mov edx,[esi+ebx+8]
	and edx,Mask8
	shr edx,3
	add eax,edx
	mov edx,[esi+ebx+ebx+8]
	and edx,Mask8
	shr edx,3
	add eax,edx

	mov [edi+ebx+4],eax
	
	pop edi
	pop esi
	
	dec ecx
	jnz near SX8
	
	pop ecx
	dec ecx
	jnz near SY8

RET
;============================================================

				;                    6 7 8
Contour:     ;1 ; esi->B3  culBGR =  o o o   culBGR =  8 * x - SUM8(culBGR) + QBBGR
                ;                  4 o x o 5
                ;                    o o o
				;                    1 2 3

	mov ebx,PICW
	shl ebx,2

	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue
	add esi,ebx			; pts to PalBGR(1,1,2,2) Blue
	inc esi
	inc esi
	inc esi
	inc esi				; pts to PalBGR(1,2,2,2) Blue
	
	push esi
	pop edi				; edi DEST to PalBGR(1,2,2,2) Blue
	add esi,eax			; esi SOURCE to PalBGR(1,2,2,3) Blue

	
	mov ecx,PICH	; iy PICH-2->2
	dec ecx
	dec ecx
CY1:
	push ecx
	mov iy,ecx

	mov ecx,PICW	; ix PICW-2 ->2 
	dec ecx
	dec ecx
CX1:
	mov ix,ecx
	
	push esi
	push edi
	
	Call near GetAddrESIixiy
	Call near GetAddrEDIixiy
	
	mov ebx,PICW
	shl ebx,2
	;----------------------------
	; BLUE
	neg ebx
	movzx edx,byte[esi+ebx-4] ;1  == movzx edx,byte[esi-ebx-4]
	movzx eax,byte[esi+ebx]   ;2
	add edx,eax
	movzx eax,byte[esi+ebx+4] ;3
	add edx,eax
	
	movzx eax,byte[esi-4]     ;4
	add edx,eax
	movzx eax,byte[esi+4]     ;5
	add edx,eax
	
	neg ebx
	movzx eax,byte[esi+ebx-4] ;6
	add edx,eax
	movzx eax,byte[esi+ebx]   ;7
	add edx,eax
	movzx eax,byte[esi+ebx+4] ;8
	add edx,eax
	mov culBT,edx
	
	inc esi		; GREEN
	
	neg ebx
	movzx edx,byte[esi+ebx-4] ;1
	movzx eax,byte[esi+ebx]   ;2
	add edx,eax
	movzx eax,byte[esi+ebx+4] ;3
	add edx,eax
	
	movzx eax,byte[esi-4]     ;4
	add edx,eax
	movzx eax,byte[esi+4]     ;5
	add edx,eax
	
	neg ebx
	movzx eax,byte[esi+ebx-4] ;6
	add edx,eax
	movzx eax,byte[esi+ebx]   ;7
	add edx,eax
	movzx eax,byte[esi+ebx+4] ;8
	add edx,eax
	mov culGT,edx
	
	inc esi		; RED
	
	neg ebx
	movzx edx,byte[esi+ebx-4] ;1
	movzx eax,byte[esi+ebx]   ;2
	add edx,eax
	movzx eax,byte[esi+ebx+4] ;3
	add edx,eax
	
	movzx eax,byte[esi-4]     ;4
	add edx,eax
	movzx eax,byte[esi+4]     ;5
	add edx,eax
	
	neg ebx
	movzx eax,byte[esi+ebx-4] ;6
	add edx,eax
	movzx eax,byte[esi+ebx]   ;7
	add edx,eax
	movzx eax,byte[esi+ebx+4] ;8
	add edx,eax
	mov culRT,edx
	
	dec esi
	dec esi
	
	movzx eax,byte[esi]		; B
	shl eax,3				; 8 * PalBGR(1,ix,iy,3)
	sub eax,culBT
	add eax,QBBlue			; 8 * PalBGR(1,ix,iy,3) - CulBT + QBBlue
	mov culBT,eax
	
	movzx eax,byte[esi+1]	; G
	shl eax,3
	sub eax,culGT
	add eax,QBGreen
	mov culGT,eax

	movzx eax,byte[esi+2]	; R
	shl eax,3
	sub eax,culRT
	add eax,QBRed
	mov culRT,eax
	
	;Check culBGRT size 0-255
	Call near CheckculBGRT
	;----------------------------
	mov eax,culBT
	mov byte[edi],aL
	mov eax,culGT
	mov [edi+1],aL
	mov eax,culRT
	mov [edi+2],aL
	
	pop edi
	pop esi
	
	dec ecx
	cmp ecx,2
	jae near CX1
	
	pop ecx
	dec ecx
	cmp ecx,2
	jae near CY1

RET
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
            ;                  o
Emboss:		; 2              x      ABS[ PBGR(,ix,iy,3) - PBGR(,ix+1,iy+1,3-QBBGR ]


	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue
	push esi
	pop edi				; edi DEST to PalBGR(1,1,1,2) Blue
	add esi,eax			; esi SORCE to PalBGR(1,1,1,3) Blue
	
	mov ecx,PICH	; iy PICH-1 ->2
	dec ecx
EY2:
	push ecx
	mov iy,ecx

	mov ecx,PICW	; ix PICW-1 ->2 
	dec ecx
EX2:
	mov ix,ecx

	push esi
	push edi
	
	Call near GetAddrESIixiy
	Call near GetAddrEDIixiy
	
	;----------------------
	mov ebx,PICW
	shl ebx,2

	movzx eax,byte [esi]
	movzx edx,byte [esi+ebx+4]
	sub eax,edx
	sub eax,QBBlue
	mov culBT,eax
	fild dword culBT
	fabs
	fistp dword culBT

	inc esi	;G
	movzx eax,byte [esi]
	movzx edx,byte [esi+ebx+4]
	sub eax,edx
	sub eax,QBGreen
	mov culGT,eax
	fild dword culGT
	fabs
	fistp dword culGT
	
	inc esi	;R
	movzx eax,byte [esi]
	movzx edx,byte [esi+ebx+4]
	sub eax,edx
	sub eax,QBRed
	mov culRT,eax
	fild dword culRT
	fabs
	fistp dword culRT
	
	;Check culBGRT size 0-255
	Call near CheckculBGRT
	;----------------------------
	mov eax,culBT
	mov byte[edi],aL
	mov eax,culGT
	mov [edi+1],aL
	mov eax,culRT
	mov [edi+2],aL

	;----------------------
	pop edi
	pop esi
	
	dec ecx
	cmp ecx,2
	jge near EX2
	
	pop ecx
	dec ecx
	cmp ecx,2
	jge near EY2

RET
;============================================================
Ripple:		; 3

; res = CallWindowProc(ptMC, ptrStruc, zParam1, zParam2, ptrWave)
; ptrWave pointer to YWave table made in VB      
; For ix = 1 To PICW - 1
; For iy = 1 To PICH - 1
;   
;         PalBGR(1, ix, iy, 2) = PalBGR(1, ix, YWave(iy), 3)

	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue
	push esi
	pop edi				; edi DEST to PalBGR(1,1,1,2) Blue
	add esi,eax			; esi SORCE to PalBGR(1,1,1,3) Blue

	mov ebx,[ebp+20]	;ptr to YWave(1)  NBNB edx cannot be used for this!!
	
	mov ecx,PICW	; ix PICW->1
RX3:
	push ecx
	mov ix,ecx

	mov ecx,PICH	; iy PICH -> 1
RY3:
	;----------------------
	push esi
	push edi

	; Source iy
	mov eax,[ebx+4*(ecx-1)]
	mov YWave,eax
	fld dword YWave
	fistp dword iy
	push ebx
	Call near GetAddrESIixiy
	pop ebx
	
	; Dest iy
	mov iy,ecx
	push ebx
	Call near GetAddrEDIixiy
	pop ebx

	movzx eax,byte[esi]    ; B
	mov byte[edi],aL
	movzx eax,byte[esi+1]  ; G
	mov [edi+1],aL
	movzx eax,byte[esi+2]  ; R
	mov [edi+2],aL

	pop edi
	pop esi
	;----------------------
	dec ecx
	jnz near RY3
	
	pop ecx
	dec ecx
	jnz near RX3
RET
;============================================================

				;                    6 7 8
Relief:      ;4 ; esi->B3  culBGR =  o o o     0  +1  +2   SUM(PalBGR())
                ;                  4 o x o 5  -1  XX  +1
                ;                    o o o    -2  -1   0
				;                    1 2 3
				; culBGRT=[ Pal(XX) + culBGRT ]\2 + 50

	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue
	push esi
	pop edi				; edi DEST to PalBGR(1,1,1,2) Blue
	add esi,eax			; esi SORCE to PalBGR(1,1,1,3) Blue


	mov ecx,PICH	; iy PICH-1 ->2
	dec ecx
RY4:
	push ecx
	mov iy,ecx

	mov ecx,PICW	; ix PICW-1 ->2 
	dec ecx
RX4:
	mov ix,ecx
	
	push esi
	push edi
	
	Call near GetAddrESIixiy
	Call near GetAddrEDIixiy
	
	mov ebx,PICW
	shl ebx,2			; 4 * PICW
	;----------------------------
	; BLUE
	; ebx +ve
	Call near ExtractReliefBytes
	mov culBT,edx
	; ebx +ve
	inc esi	; GREEN
	Call near ExtractReliefBytes
	mov culGT,edx
	; ebx +ve
	inc esi	; RED
	Call near ExtractReliefBytes
	mov culRT,edx
	
	;----------------------------
	dec esi
	dec esi		; Back to Blue

	mov ebx,dword[esi]	; Hi ARGB Lo

	movzx eax,byte bL		; B PalBGR(1,ix,iy,3)
	add eax,culBT			; PalBGR(1,ix,iy,3)+culBT
	shr eax,1				; (PalBGR(1,ix,iy,3)+culBT)\2
	add eax,50				; (PalBGR(1,ix,iy,3)+culBT)\2 + 50
	mov culBT,eax

	movzx eax,byte bH		; G PalBGR(1,ix,iy,3)
	add eax,culGT			; PalBGR(1,ix,iy,3)+culGT
	shr eax,1				; (PalBGR(1,ix,iy,3)+culGT)\2
	add eax,50				; (PalBGR(1,ix,iy,3)+culGT)\2 + 50
	mov culGT,eax

	bswap ebx			; Hi BGRA Lo
	
	movzx eax,byte bH		; R PalBGR(1,ix,iy,3)
	add eax,culRT			; PalBGR(1,ix,iy,3)+culRT
	shr eax,1				; (PalBGR(1,ix,iy,3)+culRT)\2
	add eax,50				; (PalBGR(1,ix,iy,3)+culRT)\2 + 50
	mov culRT,eax

pass:
	;Check culBGRT size 0-255 or 0-QBBGR
	Call near CheckculBGRTQB
	;----------------------------
	; Move BGR to 3
	mov eax,culBT
	mov byte[edi],aL
	mov eax,culGT
	mov byte[edi+1],aL
	mov eax,culRT
	mov byte[edi+2],aL
	
	pop edi
	pop esi
	
	dec ecx
	cmp ecx,2
	jae near RX4
	
	pop ecx
	
	dec ecx
	cmp ecx,2
	jae near RY4

RET
;============================================================

ExtractReliefBytes:		; esi -> BGR X, ebx = 4*PICW
                        ; Out: SUM in edx

	movzx eax,byte[esi+ebx]   ; +1
	mov edx,eax
	movzx eax,byte[esi+ebx+4] ; +2
	add edx,eax
	add edx,eax
	movzx eax,byte[esi+4]     ; +1
	add edx,eax

	movzx eax,byte[esi-4]     ; -1
	sub edx,eax
	neg ebx	; -ve
	movzx eax,byte[esi+ebx-4] ; -2  == movzx edx,byte[esi-ebx-4]
	sub edx,eax
	sub edx,eax
	movzx eax,byte[esi+ebx]   ; -1
	sub edx,eax
	neg ebx ; +ve

RET
;============================================================

CheckculBGRTQB:
	
	; Ensure colors in range
	mov eax,255
	cmp culBT,eax	; culBT-255
	jle THG2
	mov ebx,QBBlue
	mov culBT,ebx
THG2:
	cmp culGT,eax
	jle THR2
	mov ebx,QBGreen
	mov culGT,ebx
THR2:
	cmp culRT,eax
	jle LoLim2
	mov ebx,QBRed
	mov culRT,ebx
	jmp CulsDone2
LoLim2:
	mov eax,0
	cmp culBT,eax	; culBT-0
	jge TLG2
	mov culBT,eax
TLG2:
	cmp culGT,eax
	jge TLR2
	mov culGT,eax
TLR2:
	cmp culRT,eax
	jge CulsDone2
	mov culRT,eax

CulsDone2:

RET
;============================================================

Twirl:		; 5

	mov esi,PtrPalBGR   ; pts to PalBGR(1,1,1,1)
	mov eax,PalSize
	shl eax,2			; x4
	add esi,eax			; pts to PalBGR(1,1,1,2) Blue
	push esi
	pop edi				; edi DEST to PalBGR(1,1,1,2) Blue
	add esi,eax			; esi SORCE to PalBGR(1,1,1,3) Blue

;%define radmax     [ebp-88]
;%define ixc        [ebp-92]
;%define iyc        [ebp-96]
;%define zpimul     [ebp-100]
;%define zSin       [ebp-104]
;%define zCos       [ebp-108]
;%define ixs        [ebp-112]
;%define iys        [ebp-116]

	mov eax,PICH
	cmp eax,PICW	; eax-PICW
	jg fillradmax	
	mov eax,PICW
fillradmax:			; PICH>PICW
	mov radmax,eax
	
	mov eax,PICW
	shr eax,1
	mov ixc,eax
	mov eax,PICH
	shr eax,1
	mov iyc,eax
	
	mov eax,Increment
	cmp eax,1
	jne TW2
	
	fldpi			; pi
	fld1
	fld1
	faddp st1		; 2, pi
	fdivp st1		; pi/2
	fstp dword zpimul
	jmp pidone
TW2:
	cmp eax,2
	jne TW4
	fldpi			; pi
	fstp dword zpimul
	jmp pidone
	cmp eax,4
	jne TW8
TW4:	
	cmp eax,4
	jne TW8
	fldpi			; pi
	fldpi			; pi
	fldpi			; pi
	faddp st1	
	faddp st1		; 3*pi
	fld1
	fld1
	faddp st1		; 2, 3*pi
	fdivp st1		; 3*pi/2
	fstp dword zpimul
	jmp pidone
TW8:
	fldpi			; pi
	fldpi			; pi
	faddp st1		; 2*pi
	fstp dword zpimul
pidone:

	mov ecx,PICH	; iy = PICH to 1
TY5:

	push ecx
	mov iy,ecx
	
	mov ecx,PICW	; ix = PICW to 1
TX5:
	mov ix,ecx
	
	push edi
	
	Call near GetAddrEDIixiy	; 2


	mov eax,ix
	mov ebx,ixc
	sub eax,ebx
	mov ebx,eax
	mul ebx			; (ix-ixc)^2
	push eax
	mov eax,iy
	mov ebx,iyc
	sub eax,ebx
	mov ebx,eax
	mul ebx			; (iy-iyc)^2
	pop ebx
	add eax,ebx		; (ix-ixc)^2 + (iy-iyc)^2
	
	mov zSin,eax	; Temp
	fild dword zSin
	fsqrt			; rad = Sqr[ (ix-ixc)^2 + (iy-iyc)^2 ]
	fild dword radmax
	fdivp st1		; rad/radmax
	fld dword zpimul
	fmulp st1		; zTheta
	fsincos			; cos(Theta), Sin(Theta)
	fstp dword zCos
	fstp dword zSin
	
	fild dword ix
	fild dword ixc
	fsubp st1		; (ix-ixc)
	fld dword zCos
	fmulp st1		; (ix-ixc)*zCos

	fild dword iy
	fild dword iyc
	fsubp st1		; (iy-iyc)
	fld dword zSin
	fmulp st1		; (iy-iyc)*zSin
	
	fsubp st1		; (ix-ixc)*zCos - (iy-iyc)*zSin
	fild dword ixc
	faddp st1		; ixc + (ix-ixc)*zCos - (iy-iyc)*zSin
	fistp dword ixs
	
	; Test ixs in range
	mov eax,ixs
	cmp eax,1
	jle ixsNo
	cmp eax,PICW
	jge ixsNo
	jmp Getiys
ixsNo:
	mov eax,QBBlue
	mov byte[edi],aL
	mov eax,QBGreen
	mov byte[edi+1],aL
	mov eax,QBRed
	mov byte[edi+2],aL
	jmp nex5

Getiys:
	fild dword ix
	fild dword ixc
	fsubp st1		; (ix-ixc)
	fld dword zSin
	fmulp st1		; (ix-ixc)*zSin

	fild dword iy
	fild dword iyc
	fsubp st1		; (iy-iyc)
	fld dword zCos
	fmulp st1		; (iy-iyc)*zCos
	
	faddp st1		; (ix-ixc)*zSin + (iy-iyc)*zCos
	fild dword iyc
	faddp st1		; iyc + (ix-ixc)*zSin + (iy-iyc)*zCos
	fistp dword iys
	
	; Test iys in range
	mov eax,iys
	cmp eax,1
	jle iysNo
	cmp eax,PICH
	jge iysNo
	jmp FillPal_ixys3_ixy2
iysNo:
	mov eax,QBBlue
	mov byte[edi],aL
	mov eax,QBGreen
	mov byte[edi+1],aL
	mov eax,QBRed
	mov byte[edi+2],aL
	jmp nex5

FillPal_ixys3_ixy2:

	push esi
	
	Call near GetAddrESIixsiys	; 3
	
	movzx eax,byte[esi]    ; B
	mov byte[edi],aL
	movzx eax,byte[esi+1]  ; G
	mov [edi+1],aL
	movzx eax,byte[esi+2]  ; R
	mov [edi+2],aL

	pop esi	

nex5:
	
	pop edi
	
	dec ecx
	jnz near TX5
	
	pop ecx
	dec ecx
	jnz near TY5


RET
;============================================================
;============================================================

GetAddrESIixiy:	; In esi,ix,iy  Out: new esi->B
                ; Uses eax,ebx
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

GetAddrEDIixiy: ; In edi,ix,iy  Out: new edi->B
                ; Uses eax,ebx
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
GetAddrESIixsiys:	; In esi,ixs,iys  Out: new esi->B
                ; Uses eax,ebx
	;B = esi + 4 * [(iys-1) * PICW + (ixs-1))]
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
