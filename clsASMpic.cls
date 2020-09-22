VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsASMpic"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
'clsASMpic 1.0
'Buggy 2002/11
'use as you like.
'so far all assembler code by Robert Rayment, big thanks for your great work!

'clsASMpic is a simple class that makes possible REALTIME image manipulation of
'even large pictures in visual basic.
'this is accomplished using precompiled assembler code (machine code) in the
'time critical sections.
'it has a real wealth of functions, eg rotating and scaling with antialiasing,
'invertion and grayscaling, art effects like relief and smoothing,
'colour effects - each colour +/-, brightness and many more - plus some really
'nice and weird ideas.

'this is mostly a total conversion of one of Robert's former postings, to make
'using this great technique as easy as it is being fast:
'http://www.planet-source-code.com/vb/scripts/ShowCode.asp?txtCodeId=29034&lngWId=1
'also look there for explanation/additional info and more of his great work.

'I did my best to encapsulate everything into one single class and make calling
'its powerful functions as easy as possible. information hiding at its best.
'by using enums, the functions become self explanatory.
'decent error checking, to be improved (for example don't quit your prog until
'your loop of one degree rotation steps has finished...).
'even loading and saving pics with the standard dialog is handled.

'this could be made even faster if abandoning undo and reset function:
'I kept robert's original structure of 3 seperate copies in memory for each image:
'1 - original pic
'2 - current pic
'3 - undo pic
'if you need only parts of it, rip out the unneeded routines to keep the .exe small.

Option Explicit

'/// D E C L A R A T I O N S ///////////////////////////////////////////////////

Private Declare Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" _
        (Destination As Any, Source As Any, ByVal Length As Long)
'To fill BITMAP structure
Private Declare Function GetObjectAPI Lib "gdi32" Alias "GetObjectA" _
        (ByVal hObject As Long, ByVal Lenbmp As Long, dimbmp As Any) As Long
' APIs for getting DIB bits to PalBGR
Private Declare Function GetDIBits Lib "gdi32" _
        (ByVal aHDC As Long, ByVal hBitmap As Long, ByVal nStartScan As Long, ByVal nNumScans As Long, lpBits As Any, lpBI As BITMAPINFO, ByVal wUsage As Long) As Long

Private Declare Function CreateCompatibleDC Lib "gdi32" _
        (ByVal HDC As Long) As Long

Private Declare Function SelectObject Lib "gdi32" _
        (ByVal HDC As Long, ByVal hObject As Long) As Long

Private Declare Function DeleteDC Lib "gdi32" _
        (ByVal HDC As Long) As Long

Private Declare Function GetDeviceCaps Lib "gdi32" _
        (ByVal HDC As Long, ByVal nIndex As Long) As Long
' For transferring drawing in an integer array to Form or PicBox
Private Declare Function StretchDIBits Lib "gdi32" (ByVal HDC As Long, _
        ByVal X As Long, ByVal Y As Long, _
        ByVal DesW As Long, ByVal DesH As Long, _
        ByVal SrcX As Long, ByVal SrcY As Long, _
        ByVal PICWW As Long, ByVal PICHH As Long, _
        lpBits As Any, lpBitsInfo As BITMAPINFO, _
        ByVal wUsage As Long, ByVal dwRop As Long) As Long
'For calling machine code
Private Declare Function CallWindowProc Lib "user32" Alias "CallWindowProcA" _
        (ByVal lpMCode As Long, _
        ByVal Long1 As Long, ByVal Long2 As Single, _
        ByVal Long3 As Single, ByVal Long4 As Long) As Long

'for Open/Save/ChoseColor dialog
Private Declare Function GetOpenFileName Lib "comdlg32.dll" Alias "GetOpenFileNameA" (pOpenfilename As OPENFILENAME) As Long
Private Declare Function GetSaveFileName Lib "comdlg32.dll" Alias "GetSaveFileNameA" (pOpenfilename As OPENFILENAME) As Long
Private Declare Function CHOOSECOLOR Lib "comdlg32.dll" Alias "ChooseColorA" (pChoosecolor As CHOOSECOLOR) As Long

'/// T Y P E S /////////////////////////////////////////////////////////////////

Private Type BITMAP
    bmType As Long    ' Type of bitmap
    bmWidth As Long    ' Pixel width
    bmHeight As Long    ' Pixel height
    bmWidthBytes As Long    ' Byte width = 3 x Pixel width
    bmPlanes As Integer    ' Color depth of bitmap
    bmBitsPixel As Integer    ' Bits per pixel, must be 16 or 24
    bmBits As Long    ' This is the pointer to the bitmap data  !!!
End Type
'NB PICTURE STORED IN MEMORY UPSIDE DOWN
'WITH INCREASING MEMORY GOING UP THE PICTURE
'bmp.bmBits points to the bottom left of the picture

' Structures for StretchDIBits
Private Type BITMAPINFOHEADER ' 40 bytes
    biSize As Long
    biwidth As Long
    biheight As Long
    biPlanes As Integer
    biBitCount As Integer
    biCompression As Long
    biSizeImage As Long
    biXPelsPerMeter As Long
    biYPelsPerMeter As Long
    biClrUsed As Long
    biClrImportant As Long
End Type

Private Type BITMAPINFO
    bmiH As BITMAPINFOHEADER
    'bmiH As RGBTRIPLE            'NB Palette NOT NEEDED for 16,24 & 32-bit
End Type
'MCode Structure for parameter passing to machine code functions
Private Type MCodeStruc
    PICW As Long
    PICH As Long
    PtrPalBGR As Long
    PtrPalLineCopy As Long
    Increment As Long
    QBLongColor As Long
    OpCode As Long
End Type
'structure for GetOpenFileName/GetSaveFileName
Private Type OPENFILENAME
    lStructSize As Long
    hwndOwner As Long
    hInstance As Long
    lpstrFilter As String
    lpstrCustomFilter As String
    nMaxCustFilter As Long
    nFilterIndex As Long
    lpstrFile As String
    nMaxFile As Long
    lpstrFileTitle As String
    nMaxFileTitle As Long
    lpstrInitialDir As String
    lpstrTitle As String
    flags As Long
    nFileOffset As Integer
    nFileExtension As Integer
    lpstrDefExt As String
    lCustData As Long
    lpfnHook As Long
    lpTemplateName As String
End Type
'structure for ChoseColor
Private Type CHOOSECOLOR
    lStructSize As Long
    hwndOwner As Long
    hInstance As Long
    rgbResult As Long
    lpCustColors As String
    flags As Long
    lCustData As Long
    lpfnHook As Long
    lpTemplateName As String
End Type
'/// E N U M S /////////////////////////////////////////////////////////////////

Public Enum PIXchoice
    pix_0_smooth
    pix_1_contour
    pix_2_emboss
    pix_3_ripple
    pix_4_relief
    pix_5_twirl
End Enum

Public Enum PALchoice
    pal_00_redMORE
    pal_01_redLESS
    pal_02_greenMORE
    pal_03_greenLESS
    pal_04_blueMORE
    pal_05_blueLESS
    pal_06_brighten
    pal_07_darken
    pal_08_rotate_colors_plus
    pal_09_rotate_colors_minus
    pal_10_noise
End Enum

Public Enum PALchoice2
    pal_11_invert = 11
    pal_12_grey = 12
    pal_13_blacken = 13
    pal_14_whiten = 14
    pal_15_BtoW = 15
    pal_16_WtoB = 16
    pal_17_NWtoB = 17
    pal_18_NBtoW = 18
    pal_19_BlackORWhite = 19
End Enum

Public Enum COLXchoice
    colx_0_addRandomColorX
    colx_1_addHORZcolorXlines
    colx_2_addVERTcolorXlines
    colx_3_addColorXdots
    colx_4_diffuseColorX
    colx_5_diffuseColorXUP
    colx_6_diffuseColorXDOWN
    colx_7_diffuseColorXLEFT
    colx_8_diffuseColorXRIGHT
    colx_9_splurge
    'todo: splurge x,y coordinates...
End Enum

'/// V A R S ///////////////////////////////////////////////////////////////////

Private bm As BITMAPINFO    'Info about pic (colordepth etc)
Private PalLineCopy(1, 1) As Byte    'For copying 1 line of PalBGR()
Private PicRotateMC() As Byte    'Array to hold machine code for Rotations
Private PicPalMC() As Byte    'Array to hold machine code for Palette Effects
Private PicPixelMC() As Byte    'Array to hold machine code for Pixel Effects
Private PicColorXMC() As Byte    'Array to hold machine code for ColorX Effects
Private PicMagnifyMC() As Byte    'Array to hold machine code for Magnify Effects
Private PIC As PictureBox    'Pointer to picbox to manipulate
Private PICW As Long, PICH As Long    'Picbox Width & Height (pixels)
Private PalBGR() As Byte    'To hold 3 full palettes (12 x PICW x PICH)
Private PalSize As Long    'Size of 1 palette (4 x PICW x PICH)
'finally made these private again as dimming in each subfunction costs time.
Private MCODE As MCodeStruc
Private ptrStruc As Long, ptMC As Long
'new private to switch autodrawing off, so that large filter arrays dont redraw after each step
Private m_AutoDraw As Boolean

Public Property Let PictureBox(ByRef PicBox As PictureBox)
Attribute PictureBox.VB_UserMemId = 0
    On Error GoTo InitializeError
    Set PIC = PicBox
    PICW = PIC.Width / Screen.TwipsPerPixelX
    PICH = PIC.Height / Screen.TwipsPerPixelY
    If Not SysBPPok(PIC) Then
        Set PIC = Nothing
        MsgBox "Not 16 or 24-bit color setting", vbCritical, "clsASM"
        Exit Property
    End If
    MCODE.PICW = PICW
    MCODE.PICH = PICH
    ptrStruc = VarPtr(MCODE.PICW)
    '---------------------
    GeneratePalBGRs
    MCODE.PtrPalBGR = VarPtr(PalBGR(1, 1, 1, 1))
    MCODE.PtrPalLineCopy = VarPtr(PalLineCopy(1, 1))
    '---------------------
    ShowPalBGR 3
    '---------------------
    Exit Property
InitializeError:
    Set PIC = Nothing
    MsgBox "Couldn't assign picturebox", vbCritical, "clsASM"
End Property

Public Property Let AutoDraw(autoON As Boolean)
    m_AutoDraw = autoON
    If autoON Then
        ShowPalBGR 2 'if switched on again, draw last pic
    Else 'if switched off, update undo buffer
        CopyMemory PalBGR(1, 1, 1, 3), PalBGR(1, 1, 1, 2), PalSize
    End If
End Property
Public Property Get AutoDraw() As Boolean
    AutoDraw = m_AutoDraw
End Property

Public Function DrawNow()
    ShowPalBGR 2
    DoEvents
End Function

Private Function NoPicAssigned() As Boolean
    If PIC Is Nothing Then
        NoPicAssigned = True
        MsgBox "You must assign a picturebox to the class first!", vbInformation, "clsASM"
    Else
        NoPicAssigned = False
    End If
End Function

Public Function ASM_Rotate(ByVal Angle As Integer, Optional ByVal AntiAlias As Boolean = False, Optional ByVal SourcePic As Boolean = True, Optional ByVal colorX As Long = -1, Optional ByVal centerX As Variant, Optional ByVal centerY As Variant)
    If NoPicAssigned Then Exit Function
    If Angle = 0 Then Exit Function
    
    If Not SourcePic Then
        If m_AutoDraw Then
            CopyMemory PalBGR(1, 1, 1, 3), PalBGR(1, 1, 1, 2), PalSize
        End If
    End If

    If colorX < 0 Then colorX = PIC.BackColor

    'centerX and centerY are passed as variant because the use of IsMissing is only possible with type variant
    'if i used "optional centerx as long = -1" and checked for -1 as default value, rotating about this
    'coordinate would be impossible...
    If IsMissing(centerX) Then centerX = PICW \ 2
    If IsMissing(centerY) Then centerY = PICH \ 2

    MCODE.QBLongColor = colorX
    ptMC = VarPtr(PicRotateMC(0))

    If SourcePic Then
        MCODE.OpCode = 2
    Else
        MCODE.OpCode = 0
    End If
    If AntiAlias Then
        MCODE.OpCode = MCODE.OpCode + 1
    End If
    CallWindowProc ptMC, ptrStruc, centerX, centerY, Angle + 360
    '---------------------
    If m_AutoDraw Then
        ShowPalBGR 2
    End If
    '---------------------
End Function

Public Function ASM_PalEffects(ByVal OpCode As PALchoice2, Optional ByVal Amount As Integer = 1, Optional ByVal colorX As Long = -1)
    If NoPicAssigned Then Exit Function
    If m_AutoDraw Then
        CopyMemory PalBGR(1, 1, 1, 3), PalBGR(1, 1, 1, 2), PalSize
    End If
    
    If colorX < 0 Then colorX = PIC.BackColor

    MCODE.Increment = Amount
    MCODE.QBLongColor = colorX
    MCODE.OpCode = OpCode
    ptMC = VarPtr(PicPalMC(0))

    CallWindowProc ptMC, ptrStruc, 2&, 3&, 4&
    '---------------------
    If m_AutoDraw Then
        ShowPalBGR 2
    End If
    '---------------------
End Function

Public Function ASM_PixelEffects(OpCode As PIXchoice, Optional ByVal Amount As Integer = 1, Optional ByVal colorX As Long = -1)
    If NoPicAssigned Then Exit Function
    If m_AutoDraw Then
        CopyMemory PalBGR(1, 1, 1, 3), PalBGR(1, 1, 1, 2), PalSize
    End If
    
    If colorX < 0 Then colorX = PIC.BackColor
    Dim ptrWave As Long

    MCODE.Increment = Amount
    MCODE.QBLongColor = colorX
    MCODE.OpCode = OpCode
    ptMC = VarPtr(PicPixelMC(0))

    Select Case OpCode

    Case 0, 1, 2, 4, 5
        CallWindowProc ptMC, ptrStruc, 2&, 3&, 4&
    Case 3
        Dim WSize As Long
        WSize = PICH: If PICW > PICH Then WSize = PICW

        ReDim YWave(1 To WSize) As Single
        Dim i As Long
        For i = 1 To WSize
            YWave(i) = i + Sin(i / 5) * 2 * Amount
            If YWave(i) < 1 Then YWave(i) = 1
            If YWave(i) > PICH Then YWave(i) = PICH
        Next i
        ptrWave = VarPtr(YWave(1))

        CallWindowProc ptMC, ptrStruc, 2&, 3&, ptrWave
    End Select
    '---------------------
    If m_AutoDraw Then
        ShowPalBGR 2
    End If
    '---------------------
End Function

Public Function ASM_IncrementalPalEffects(OpCode As PALchoice, Optional ByVal Amount As Integer = 1)
    If NoPicAssigned Then Exit Function
    If m_AutoDraw Then
        CopyMemory PalBGR(1, 1, 1, 3), PalBGR(1, 1, 1, 2), PalSize
    End If

    MCODE.Increment = Amount
    MCODE.QBLongColor = PIC.BackColor
    MCODE.OpCode = OpCode
    ptMC = VarPtr(PicPalMC(0))

    ' Ensure same sequence each time
    Rnd -1
    Randomize 1

    If OpCode = 10 Then    'noise
        CallWindowProc ptMC, ptrStruc, 255 * Rnd, 3&, 4&
    Else
        CallWindowProc ptMC, ptrStruc, 2&, 3&, 4&
    End If
    '---------------------
    If m_AutoDraw Then
        ShowPalBGR 2
    End If
    '---------------------
End Function

Public Function ASM_ColorXEffects(OpCode As COLXchoice, ByVal colorX As Long, Optional ByVal Amount As Integer = 1, Optional ByVal centerX As Variant, Optional ByVal centerY As Variant)
    If NoPicAssigned Then Exit Function
    If m_AutoDraw Then
        CopyMemory PalBGR(1, 1, 1, 3), PalBGR(1, 1, 1, 2), PalSize
    End If
    
    Dim ptAns As Long

    'centerX and centerY are passed as variant because the use of IsMissing is only possible with type variant
    'if i used "optional centerx as long = -1" and checked for -1 as default value, using this
    'coordinate would be impossible...
    If IsMissing(centerX) Then centerX = PICW \ 2
    If IsMissing(centerY) Then centerY = PICH \ 2

    MCODE.Increment = Amount
    MCODE.QBLongColor = colorX
    MCODE.OpCode = OpCode
    ptMC = VarPtr(PicColorXMC(0))

    Dim Answer As Long
    Answer = 99
    ptAns = VarPtr(Answer)
    Randomize
    Select Case OpCode
    Case 0    ' Add Random ColorX
        ' Difficult to get a good spacial random
        ' number in mcode without using input from
        ' timer BUT this disallowed above Win98,
        ' thus this no quicker than VB.
        Dim i As Long
        For i = 1 To 20 * Amount
            CallWindowProc ptMC, ptrStruc, Rnd, Rnd, ptAns
        Next i
    Case 1 To 3: CallWindowProc ptMC, ptrStruc, 2&, 3&, ptAns
    Case 4 To 8
        CallWindowProc ptMC, ptrStruc, 0.9, 0.1, ptAns
    Case 9    ' Bright SPOT @ iXp,iYp
        CallWindowProc ptMC, ptrStruc, centerX, centerY, ptAns
    End Select
    '---------------------
    If m_AutoDraw Then
        ShowPalBGR 2
    End If
    '---------------------
End Function

Public Function ASM_Magnify(ByVal Factor As Single, Optional ByVal centerX As Variant, Optional ByVal centerY As Variant, Optional ByVal AntiAlias As Boolean = False, Optional ByVal colorX As Long = -1)
    If NoPicAssigned Then Exit Function
    If m_AutoDraw Then
        CopyMemory PalBGR(1, 1, 1, 3), PalBGR(1, 1, 1, 2), PalSize
    End If
    
    If colorX < 0 Then colorX = PIC.BackColor
    'centerX and centerY are passed as variant because the use of IsMissing is only possible with type variant
    'if i used "optional centerx as long = -1" and checked for -1 as default value, using this
    'coordinate would be impossible...
    If IsMissing(centerX) Then centerX = PICW \ 2
    If IsMissing(centerY) Then centerY = PICH \ 2

    MCODE.QBLongColor = colorX
    ptMC = VarPtr(PicMagnifyMC(0))

    Select Case AntiAlias
    Case False: MCODE.OpCode = 0
    Case Else: MCODE.OpCode = 1
    End Select

    CallWindowProc ptMC, ptrStruc, centerX, centerY, Factor * 10

    '---------------------
    If m_AutoDraw Then
        ShowPalBGR 2
    End If
    '---------------------
End Function

Private Function LoadMCodeFromString(asm_code_ARRAY() As Byte, MCODE As String)
    Dim i As Long, aSize As Long

    aSize = Len(MCODE)
    Debug.Assert Not aSize And 1    'may not be odd (bytes)!
    aSize = aSize \ 2
    ReDim Preserve asm_code_ARRAY(0 To aSize - 1)
    For i = 0 To aSize - 1
        asm_code_ARRAY(i) = Val("&H" & Mid$(MCODE, i * 2 + 1, 2))
    Next
End Function

Private Function GeneratePalBGRs()
    GETDIBS PIC.Image
    ' Mem storage
    'PalBGR for 32 bitcount
    ' BLUE     GREEN     RED       ALPHA
    '(1,1,1,1)(2,1,1,1),(3,1,1,1),(4,1,1,1),,,(1,X,1,1),(2,X,1,1),(3,X,1,1),(4,X,1,1)
    '(1,1,Y,1)(2,1,Y,1),(3,1,Y,1),(4,1,1,1),,,(1,X,Y,1),(2,X,Y,1),(3,X,Y,1),(4,X,Y,1)
    '-----------------------------------------------------------------------------------
    '(1,1,1,2)(2,1,1,2),(3,1,1,2),(4,1,1,2),,,(1,X,1,2),(2,X,1,2),(3,X,1,2),(4,X,1,2)
    '(1,1,Y,2)(2,1,Y,1),(3,1,Y,1),(4,1,1,1),,,(1,X,Y,2),(2,X,Y,2),(3,X,Y,2),(4,X,Y,2)
    '-----------------------------------------------------------------------------------
    '(1,1,1,3)(2,1,1,3),(3,1,1,3),(4,1,1,3),,,(1,X,1,3),(2,X,1,3),(3,X,1,3),(4,X,1,3)
    '(1,1,Y,3)(2,1,Y,3),(3,1,Y,3),(4,1,Y,3),,,(1,X,Y,3),(2,X,Y,3),(3,X,Y,3),(4,X,Y,3)
    '-----------------------------------------------------------------------------------
    ' Save 2 copies of palette
    PalSize = 4 * PICW * PICH    ' Bytes
    CopyMemory PalBGR(1, 1, 1, 2), PalBGR(1, 1, 1, 1), PalSize
    CopyMemory PalBGR(1, 1, 1, 3), PalBGR(1, 1, 1, 1), PalSize
End Function

Private Function GETDIBS(ByVal PICIM As Long)
    Dim NewDC As Long, OldH As Long
    Dim BytesPerScanLine As Long, PadBytesPerScanLine As Long
    Dim bmp As BITMAP
    On Error GoTo DIBError

    'Get info on picture loaded into PIC
    GetObjectAPI PICIM, Len(bmp), bmp

    NewDC = CreateCompatibleDC(0&)
    OldH = SelectObject(NewDC, PICIM)

    ' Set up bm struc for GetDIBits & StretchDIBits
    With bm.bmiH
        .biSize = 40
        .biwidth = bmp.bmWidth
        .biheight = bmp.bmHeight
        .biPlanes = 1
        .biBitCount = 32    ' Sets up BGRA pixels
        .biCompression = 0
        BytesPerScanLine = ((((.biwidth * .biBitCount) + 31) \ 32) * 4)
        PadBytesPerScanLine = _
                BytesPerScanLine - (((.biwidth * .biBitCount) + 7) \ 8)
        .biSizeImage = BytesPerScanLine * Abs(.biheight)
    End With

    ' Set PalBGR to receive color bytes
    ReDim PalBGR(1 To 4, 1 To PICW, 1 To PICH, 1 To 3) As Byte
    ' Load color bytes to 1st third of PalBGR
    GetDIBits NewDC, PICIM, 0, PICH, PalBGR(1, 1, 1, 1), bm, 1
    ' Clear mem
    SelectObject NewDC, OldH

    DeleteDC NewDC
    Exit Function
    '==========
DIBError:
    MsgBox "Error in function GETDIBS", vbCritical, "clsASM"
    On Error GoTo 0
End Function

Private Function ShowPalBGR(N)
' Blit PalBGR(N) to PIC
' N= 1,2 or 3
    PIC.Picture = LoadPicture()
    PIC.Visible = True

    Dim PalBGRPtr As Long    ' Pointer to PalBGR(1,1,1,1)
    PalBGRPtr = VarPtr(PalBGR(1, 1, 1, N))

    bm.bmiH.biwidth = PICW
    bm.bmiH.biheight = PICH
    If StretchDIBits(ByVal PIC.HDC, _
            0, 0, _
            PICW, PICH, _
            0, 0, _
            PICW, PICH, _
            ByVal PalBGRPtr, bm, _
            1, vbSrcCopy) = 0 Then
        Erase PalBGR
        MsgBox "Blit Error", vbCritical, "clsASM"
        End
    End If

    PIC.Refresh
End Function

Private Function SysBPPok(PIC As PictureBox) As Boolean
    Dim SysBPP As Long
    SysBPP = GetDeviceCaps(PIC.HDC, 12)    'HORZRES = 8, VERTRES = 10, BITSPIXEL = 12
    If SysBPP <> 16 And SysBPP <> 32 Then    '16, 32 (24-bit BGR)
        SysBPPok = False
    Else
        SysBPPok = True
    End If
End Function

Public Function UndoLast()
    If NoPicAssigned Then Exit Function
    CopyMemory PalBGR(1, 1, 1, 2), PalBGR(1, 1, 1, 3), PalSize
    ShowPalBGR 2
End Function

Public Function ResetPic()
    If NoPicAssigned Then Exit Function
    CopyMemory PalBGR(1, 1, 1, 2), PalBGR(1, 1, 1, 1), PalSize
    CopyMemory PalBGR(1, 1, 1, 3), PalBGR(1, 1, 1, 1), PalSize
    ShowPalBGR 1
End Function

Public Function UndoLastDontDraw()
    If NoPicAssigned Then Exit Function
    CopyMemory PalBGR(1, 1, 1, 2), PalBGR(1, 1, 1, 3), PalSize
End Function

Public Function dialogShowOpen(Optional ByVal Caption As String)
    If NoPicAssigned Then Exit Function
    If Caption = "" Then Caption = "Load a Picture file"
    Dim OFName As OPENFILENAME
    OFName.lStructSize = Len(OFName)    'set structure size
    OFName.hwndOwner = PIC.Parent.hWnd    'Set the parent window
    OFName.hInstance = App.hInstance    'Set the application's instance
    OFName.lpstrFilter = "Pictures (*.bmp *.gif *.jpg *.wmf *.ico *.cur)" & Chr$(0) & "*.bmp;*.gif;*.jpg;*.ico;*.cur" & Chr$(0) & "All Files (*.*)" & Chr$(0) & "*.*" & Chr$(0)    'Select a filter
    OFName.lpstrFile = Space$(254)    'create a buffer for the file
    OFName.nMaxFile = 255    'set the maximum length of a returned file
    OFName.lpstrFileTitle = Space$(254)    'Create a buffer for the file title
    OFName.nMaxFileTitle = 255    'Set the maximum length of a returned file title
    'OFName.lpstrInitialDir = "C:\"      'Set the initial directory
    OFName.lpstrTitle = Caption    'Set the title
    OFName.flags = 0    'No flags

    On Error GoTo OpenError
    'Show the 'Open File'-dialog
    If GetOpenFileName(OFName) Then
        PIC.Visible = False
        PIC.Picture = LoadPicture(Trim$(OFName.lpstrFile))
        PIC.Parent.MousePointer = vbHourglass
        PictureBox = PIC
        PIC.Parent.Refresh
        PIC.Parent.MousePointer = vbDefault
    End If
    Exit Function
OpenError:
    PIC.Visible = True
    MsgBox "Error loading picture file", vbCritical, PIC.Parent.Caption
End Function

Public Function dialogShowSave(Optional ByVal Caption As String)
    If NoPicAssigned Then Exit Function
    If Caption = "" Then Caption = "Save Picture file"
    Dim SFName As OPENFILENAME
    SFName.lStructSize = Len(SFName)    'Set the structure size
    SFName.hwndOwner = PIC.Parent.hWnd    'Set the owner window
    SFName.hInstance = App.hInstance    'Set the application's instance
    SFName.lpstrFilter = "Pictures (*.bmp)" & Chr$(0) & "*.bmp" & Chr$(0)    'Set the filet
    SFName.lpstrFile = Space$(254)    'Create a buffer
    SFName.nMaxFile = 255    'Set the maximum number of chars
    SFName.lpstrFileTitle = Space$(254)    'Create a buffer
    SFName.nMaxFileTitle = 255    'Set the maximum number of chars
    'SFName.lpstrInitialDir = "C:\"      'Set the initial directory
    SFName.lpstrTitle = Caption    'Set the dialog title
    SFName.flags = 0    'no extra flags

    On Error GoTo SaveError
    'Show the 'Save File'-dialog
    If GetSaveFileName(SFName) Then
        Dim SaveFileName As String
        SaveFileName = Replace(Trim$(SFName.lpstrFile), Chr(0), "")
        If LCase(Right(SaveFileName, 4)) <> ".bmp" Then SaveFileName = Trim$(SaveFileName) & ".bmp"
        SavePicture PIC.Image, SaveFileName
    End If
    Exit Function
SaveError:
    MsgBox "Error saving picture file", vbCritical, PIC.Parent.Caption
End Function
Public Function dialogChoseColor() As Long
    If NoPicAssigned Then Exit Function
    Dim cc As CHOOSECOLOR
    Static CustomColors() As Byte
    ReDim Preserve CustomColors(0 To 16 * 4 - 1) ' As Byte
    cc.lStructSize = Len(cc) 'set the structure size
    cc.hwndOwner = PIC.Parent.hWnd  'Set the owner
    cc.hInstance = App.hInstance 'set the application's instance
    cc.lpCustColors = StrConv(CustomColors, vbUnicode) 'set the custom colors (converted to Unicode)
    cc.flags = 0    'no extra flags

    'Show the 'Select Color'-dialog
    If CHOOSECOLOR(cc) <> 0 Then
        dialogChoseColor = cc.rgbResult
        CustomColors = StrConv(cc.lpCustColors, vbFromUnicode)
    Else
        dialogChoseColor = -1
    End If
End Function

Private Sub Class_Initialize()
    m_AutoDraw = True
    'load all those mutthas...
    LoadMCodeFromString PicRotateMC, _
            "5589E581EC780000005756538B5D08FF338F45FCFF73048F45F8FF73088F45F4FF730C8F45F0FF73108F45ECFF73148F45E8FF73188F45E48B450C8945D88B45108945D48B45148945BC8B45F88B5DFCF7E38945E08B45FCC1E0048945DC8B45E825FF0000008945C08B45E82500FF0000C1E8088945C48B45E8250000FF00C1E8108945C8B8B40000008945ACD9EBDB45ACDEF9DB45BCDEC9D9FBD95DB8D95DB4DB45F8D945D4DEE9D95DD4B8020000008945B0D9E8DB45B0DEF9D95DB08B45E43D00000000750AE841000000E9330000003D01000000750AE848000000E9220000003D02000000750AE84F000000E9110000003D03000000750AE852000000E9000000005B5E5F89EC5DC210008B7DF48B45E0C1E00201C78B75F401C601C6E841000000C38B7DF48B45E0C1E00201C78B75F401C601C6E808010000C38B7DF48B45E0C1E00201C78B75F4E815000000C38B7DF48B45E0C1E00201C78B75F4E8E0000000C38B45F889C1894DCC518B45FC89C1894DD0DB45D0D945D8DEE9D945B8DEC9DB45CCD945D4DEE9D945B4DEC9DEE9D945D8DEC1DB5DA88B45A83D010000007C053B45FC7E1D57E8B80200008B45C888078B45C48847018B45C08847025FE96E000000DB45CCD945D4DEE9D945B8DEC9DB45D0D945D8DEE9D945B4DEC9DEC1D945D4DEC1DB5DA48B45A43D010000007C" & _
            "053B45F87E1D57E8680200008B45C888078B45C48847018B45C08847025FE91E0000005756E835020000E8450200008A0688078A46018847018A46028847025E5F490F8538FFFFFF59490F8527FFFFFFC38B45F889C1894DCC518B45FC89C1894DD0DB45D0D945D8DEE9D945B8DEC9DB45CCD945D4DEE9D945B4DEC9DEE9D945D8DEC1D95DA0DB45CCD945D4DEE9D945B8DEC9DB45D0D945D8DEE9D945B4DEC9DEC1D945D4DEC1D95D9CD945A0D945B0DEE9DB5DA8D9459CD945B0DEE9DB5DA48B45A83D010000007C193B45FC7D148B45A43D010000007C0A3B45F87D05E91D00000057E88B0100008B45C888078B45C48847018B45C08847025FE914010000D945A0DB45A8DEE9D95D98D9459CDB45A4DEE9D95D9456E8430100008B5DFCC1E3020FB606894590DB45900FB64604894590DB4590D8E1D94598DEC9DEC10FB6041E894590DB45900FB6441E04894590DB4590D8E1D94598DEC9DEC1D8E1D94594DEC9DEC1DB5D90460FB60689458CDB458C0FB6460489458CDB458CD8E1D94598DEC9DEC10FB6041E89458CDB458C0FB6441E0489458CDB458CD8E1D94598DEC9DEC1D8E1D94594DEC9DEC1DB5D8C460FB606894588DB45880FB64604894588DB4588D8E1D94598DEC9DEC10FB6041E894588DB45880FB6441E04894588DB4588D8E1D94598DEC9DEC1D8E1D94594DEC9DEC1DB" & _
            "5D885EE82800000057E8720000008B459088078B458C8847018B45888847025F490F8544FEFFFF59490F8533FEFFFFC3B8FF0000003945907E0389459039458C7E0389458C3945887E03894588B8000000003945907D0389459039458C7D0389458C3945887D03894588C38B45A4488B5DFCF7E38B5DA84B01D8C1E00201C6C38B45CC488B5DFCF7E38B5DD04B01D8C1E00201C7C38B45A4488B5DFCF7E38B5DA84B01D8C1E00201C7C3"
    LoadMCodeFromString PicPalMC, _
            "5589E581EC4C0000005756538B5D08FF338F45FCFF73048F45F8FF73088F45F4FF730C8F45F0FF73108F45ECFF73148F45E8FF73188F45E48B450C8945D88B45F88B5DFCF7E38945E08B45FCC1E0028945DC8B45E43D00000000750AE847010000E9390100003D01000000750AE86E010000E9280100003D02000000750AE895010000E9170100003D03000000750AE8BC010000E9060100003D04000000750AE8E3010000E9F50000003D05000000750AE807020000E9E40000003D060000007505E82B0200003D070000007505E8600200003D08000000750AE895020000E9BB0000003D09000000750AE8C5020000E9AA0000003D0A000000750AE8F5020000E9990000003D0B000000750AE826040000E9880000003D0C000000750AE84C040000E9770000003D0D000000750AE877040000E9660000003D0E000000750AE8A4040000E9550000003D0F000000750AE8D1040000E9440000003D10000000750AE8FE040000E9330000003D11000000750AE82B050000E9220000003D12000000750AE858050000E9110000003D13000000750AE885050000E9000000005B5E5F89EC5DC210008B75F48B45E0C1E00201C631C08B45ECC1E0108945D48945D00F6F45D08B4DE0D1E9BB080000000F6F0E0FDCC80F7F0E01DE4975F20F77C38B75F48B45E0C1E00201C631C08B45ECC1E01089" & _
            "45D48945D00F6F45D08B4DE0D1E9BB080000000F6F0E0FD8C80F7F0E01DE4975F20F77C38B75F48B45E0C1E00201C631C08B45ECC1E0088945D48945D00F6F45D08B4DE0D1E9BB080000000F6F0E0FDCC80F7F0E01DE4975F20F77C38B75F48B45E0C1E00201C631C08B45ECC1E0088945D48945D00F6F45D08B4DE0D1E9BB080000000F6F0E0FD8C80F7F0E01DE4975F20F77C38B75F48B45E0C1E00201C631C08B45EC8945D48945D00F6F45D08B4DE0D1E9BB080000000F6F0E0FDCC80F7F0E01DE4975F20F77C38B75F48B45E0C1E00201C631C08B45EC8945D48945D00F6F45D08B4DE0D1E9BB080000000F6F0E0FD8C80F7F0E01DE4975F20F77C38B75F48B45E0C1E00201C631C08B45ECC1E0088A45ECC1E0088A45EC8945D48945D00F6F45D08B4DE0D1E9BB080000000F6F0E0FDCC80F7F0E01DE4975F20F77C38B75F48B45E0C1E00201C631C08B45ECC1E0088A45ECC1E0088A45EC8945D48945D00F6F45D08B4DE0D1E9BB080000000F6F0E0FD8C80F7F0E01DE4975F20F77C38B75F48B45E0C1E00201C631C08B45ECC1E0088A45ECC1E0088A45EC8945D48945D00F6F45D08B4DE0D1E9BB080000000F6F0E0FFCC80F7F0E01DE4975F20F77C38B75F48B45E0C1E00201C631C08B45ECC1E0088A45ECC1E0088A45EC8945D48945D00F6F45D08B4DE0D1E9BB080000000F6F0E" & _
            "0FF8C80F7F0E01DE4975F20F77C38B75F48B45E0C1E00201C68B45ECBB14000000F7E38945B4D1E005010000008945CCB8FF0000008945C88B4DE0E8F5000000DB45B8DB45C8DEF9DB45CCDEC9DB45B4DEE90FB6068945C4DB45C4DEC1DB5DC446E8CF000000DB45B8DB45C8DEF9DB45CCDEC9DB45B4DEE90FB6068945C0DB45C0DEC1DB5DC046E8A9000000DB45B8DB45C8DEF9DB45CCDEC9DB45B4DEE90FB6068945BCDB45BCDEC1DB5DBC8B45C43DFF0000007C0AB8FF000000E90C0000003D000000007F05B8000000008945C48B45C03DFF0000007C0AB8FF000000E90C0000003D000000007F05B8000000008945C08B45BC3DFF0000007C0AB8FF000000E90C0000003D000000007F05B8000000008945BC8B45BC88064E8B45C088064E8B45C48806BA0400000001D6490F8507FFFFFFC3B813180100F76DD80509B20A00D1D88945D825FF0000008945B8C38B75F48B45E0C1E00201C631C0B8FFFFFFFF8945D48945D08B4DE0D1E9BB080000000F6F45D00F6F0E0FF8C10F7F0601DE4975EE0F77C38B75F48B45E0C1E00201C68B4DE0660FB6066689C3660FB646016689C2660FB646026601D06601D866BB0300F6F3880646880646880646464975D3C38B75F48B45E0C1E00201C68B4DE08A063C18771F8A46013C1877188A46023C187711B00088064688064688064646E90700" & _
            "0000BA0400000001D64975D1C38B75F48B45E0C1E00201C68B4DE08A063CF8761F8A46013CF876188A46023CF87611B0FF88064688064688064646E907000000BA0400000001D64975D1C38B75F48B45E0C1E00201C68B4DE08A063C00751F8A46013C0075188A46023C007511B0FF88064688064688064646E907000000BA0400000001D64975D1C38B75F48B45E0C1E00201C68B4DE08A063CFF751F8A46013CFF75188A46023CFF7511B00088064688064688064646E907000000BA0400000001D64975D1C38B75F48B45E0C1E00201C68B4DE08A063CFF750E8A46013CFF75078A46023CFF7411B00088064688064688064646E907000000BA0400000001D64975D1C38B75F48B45E0C1E00201C68B4DE08A063C00750E8A46013C0075078A46023C007411B0FF88064688064688064646E907000000BA0400000001D64975D1C38B75F48B45E0C1E00201C68B4DE08A063CB4721F8A46013CB4721F8A46023CB4721FB0FF88064688064688064646E9150000008A46013CB473E88A46023CB473E1B000E9DCFFFFFF4975C3C3"
    LoadMCodeFromString PicPixelMC, _
            "5589E581EC74000000575653528B5D08FF338F45FCFF73048F45F8FF73088F45F4FF730C8F45F0FF73108F45ECFF73148F45E8FF73188F45E48B45F88B5DFCF7E38945E08B45FCC1E0028945DC8B45E825FF0000008945BC8B45E82500FF0000C1E8088945C08B45E8250000FF00C1E8108945C4B8FEFEFEFE8945D8B8FCFCFCFC8945D4B8F8F8F8F88945D08B45E43D00000000750AE864000000E9550000003D01000000750AE8FE010000E9440000003D02000000750AE878030000E9330000003D03000000750AE815040000E9220000003D04000000750AE865040000E9110000003D05000000750AE880050000E9000000005A5B5E5F89EC5DC210008B75F48B45E0C1E00201C6565F01C68B45EC3D010000007506E829000000C33D020000007506E855000000C33D040000007506E887000000C33D080000007506E8D5000000C3C38B4DF851894DC88B4DFC4949894DCC5657E8AF060000E8BF0600008B062345D8D1E88B56082355D8D1EA01D08947045F5E4975D8594975CBC38B4DF8494951894DC88B4DFC894DCC5657E876060000E8860600008B5DFCC1E3028B062345D8D1E88B145E2355D8D1EA01D089041F5F5E4975D2594975C7C38B4DF8494951894DC88B4DFC4949894DCC5657E835060000E8450600008B5DFCC1E3028B062345D4C1E8028B145E2355D4C1EA0201D0" & _
            "8B56082355D4C1EA0201D08B545E082355D4C1EA0201D089441F045F5E4975B8594975ABC38B4DF8494951894DC88B4DFC4949894DCC5657E8DA050000E8EA0500008B5DFCC1E3028B062345D0C1E8038B141E2355D0C1EA0301D08B145E2355D0C1EA0301D08B56042355D0C1EA0301D08B545E042355D0C1EA0301D08B56082355D0C1EA0301D08B541E082355D0C1EA0301D08B545E082355D0C1EA0301D089441F045F5E490F8586FFFFFF59490F8575FFFFFFC38B5DFCC1E3028B75F48B45E0C1E00201C601DE46464646565F01C68B4DF8494951894DC88B4DFC4949894DCC5657E82E050000E83E0500008B5DFCC1E302F7DB0FB6541EFC0FB6041E01C20FB6441E0401C20FB646FC01C20FB6460401C2F7DB0FB6441EFC01C20FB6041E01C20FB6441E0401C28955B846F7DB0FB6541EFC0FB6041E01C20FB6441E0401C20FB646FC01C20FB6460401C2F7DB0FB6441EFC01C20FB6041E01C20FB6441E0401C28955B446F7DB0FB6541EFC0FB6041E01C20FB6441E0401C20FB646FC01C20FB6460401C2F7DB0FB6441EFC01C20FB6041E01C20FB6441E0401C28955B04E4E0FB606C1E0032B45B80345C48945B80FB64601C1E0032B45B40345C08945B40FB64602C1E0032B45B00345BC8945B0E82F0000008B45B888078B45B48847018B45B08847025F5E4981F9020000000F83E8" & _
            "FEFFFF594981F9020000000F83D1FEFFFFC3B8FF0000003945B87E038945B83945B47E038945B43945B07E038945B0B8000000003945B87D038945B83945B47D038945B43945B07D038945B0C38B75F48B45E0C1E00201C6565F01C68B4DF84951894DC88B4DFC49894DCC5657E8B1030000E8C10300008B5DFCC1E3020FB6060FB6541E0429D02B45C48945B8DB45B8D9E1DB5DB8460FB6060FB6541E0429D02B45C08945B4DB45B4D9E1DB5DB4460FB6060FB6541E0429D02B45BC8945B0DB45B0D9E1DB5DB0E846FFFFFF8B45B888078B45B48847018B45B08847025F5E4981F9020000000F8D7CFFFFFF594981F9020000000F8D66FFFFFFC38B75F48B45E0C1E00201C6565F01C68B5D148B4DFC51894DCC8B4DF856578B448BFC8945ACD945ACDB5DC853E8F70200005B894DC853E8020300005B0FB60688070FB646018847010FB646028847025F5E490F85C4FFFFFF59490F85B5FFFFFFC38B75F48B45E0C1E00201C6565F01C68B4DF84951894DC88B4DFC49894DCC5657E8A2020000E8B20200008B5DFCC1E302E87F0000008955B846E8760000008955B446E86D0000008955B04E4E8B1E0FB6C30345B8D1E805320000008945B80FB6C70345B4D1E805320000008945B40FCB0FB6C70345B0D1E805320000008945B0E85E0000008B45B888078B45B48847018B45B08847025F5E" & _
            "4981F9020000000F8376FFFFFF594981F9020000000F8360FFFFFFC30FB6041E89C20FB6441E0401C201C20FB6460401C20FB646FC29C2F7DB0FB6441EFC29C229C20FB6041E29C2F7DBC3B8FF0000003945B87E068B5DC4895DB83945B47E068B5DC0895DB43945B07E0B8B5DBC895DB0E91D000000B8000000003945B87D038945B83945B47D038945B43945B07D038945B0C38B75F48B45E0C1E00201C6565F01C68B45F83B45FC7F038B45FC8945A88B45FCD1E88945A48B45F8D1E88945A08B45EC3D010000007512D9EBD9E8D9E8DEC1DEF9D95D9CE9420000003D020000007511D9EBD95D9CE9310000003D0400000075213D04000000751AD9EBD9EBD9EBDEC1DEC1D9E8D9E8DEC1DEF9D95D9CE909000000D9EBD9EBDEC1D95D9C8B4DF851894DC88B4DFC894DCC57E8120100008B45CC8B5DA429D889C3F7E3508B45C88B5DA029D889C3F7E35B01D8894598DB4598D9FADB45A8DEF9D9459CDEC9D9FBD95D94D95D98DB45CCDB45A4DEE9D94594DEC9DB45C8DB45A0DEE9D94598DEC9DEE9DB45A4DEC1DB5D908B45903D010000007E0A3B45FC7D05E9160000008B45C488078B45C08847018B45BC884702E968000000DB45CCDB45A4DEE9D94598DEC9DB45C8DB45A0DEE9D94594DEC9DEC1DB45A0DEC1DB5D8C8B458C3D010000007E0A3B45F87D05E9160000008B45C488078B" & _
            "45C08847018B45BC884702E91A00000056E84F0000000FB60688070FB646018847010FB646028847025E5F490F8503FFFFFF59490F85F4FEFFFFC38B45C8488B5DFCF7E38B5DCC4B01D8C1E00201C6C38B45C8488B5DFCF7E38B5DCC4B01D8C1E00201C7C38B458C488B5DFCF7E38B5D904B01D8C1E00201C6C3"
    LoadMCodeFromString PicColorXMC, _
            "5589E581EC640000005756538B5D08FF338F45FCFF73048F45F8FF73088F45F4FF730C8F45F0FF73108F45ECFF73148F45E8FF73188F45E48B450C8945D88B45108945D48B45F88B5DFCF7E38945E08B45FCC1E0048945DC8B45E825FF0000008945C08B45E82500FF0000C1E8088945C48B45E8250000FF00C1E8108945C88B45E43D00000000750AE8A0000000E9920000003D01000000750AE8EB000000E9810000003D02000000750AE81C010000E9700000003D03000000750AE84D010000E95F0000003D04000000750AE886010000E94E0000003D05000000750AE84F030000E93D0000003D06000000750AE8E6030000E92C0000003D07000000750AE87C040000E91B0000003D08000000750AE815050000E90A0000003D09000000E8AF0500005B5E5F89EC5DC210008B75F48B45E0C1E00201C6D945D8DB45FCDEC9D9E8DEC1DB5DD08B45D03B45FC7E068B45FC8945D0D945D4DB45F8DEC9D9E8DEC1DB5DCC8B45CC3B45F87E068B45F88945CCE8900200008B45C888068B45C48846018B45C0884602C38B75F48B45E0C1E00201C6565F8B4DF851894DCC8B4DFC894DD0E85F0200008B45C888068B45C48846018B45C0884602575E4975E2598B45EC29C131C039C17FCFC38B75F48B45E0C1E00201C6565F8B4DF851894DCC8B4DFC894DD0E81D0200008B45C888068B45C488" & _
            "46018B45C0884602575E8B45EC29C131C039C17FDA594975CFC38B75F48B45E0C1E00201C6565F8B4DF851894DCC8B4DFC894DD0E8DB0100008B45C888068B45C48846018B45C0884602575E8B45EC29C131C039C17FDA598B45EC29C131C039C17FC7C38B75F48B45E0C1E00201C6565F8B45EC0502000000D1E83D050000007505B8040000008945BC8B4DBC41894DCC518B4DBC41894DD051E87501000031C08A06C1E0088A4601C1E0088A4602575E3B45E80F85760000008B45BCF7D889C1518B45CC01C88945A48B45D889459C894DB8DB45B8D9E1DB5DB88B45BCF7D889C18B45D001C88945A88B45B88945B0894DB4DB45B4D9E1DB5DB48B45B43B45B07C038945B0E848000000E819010000E858000000575E418B45BC39C10F8EBFFFFFFF59418B45BC39C10F8E91FFFFFF575E59418B45FC2B45BC39C10F8E54FFFFFF59418B45F82B45BC39C10F8E3CFFFFFFC38B45BC2B45B08945B0D945D8D945D4DB45B0DEC9DEE9D95D9CC30FB6068945A0D9459CDB45A0DEC9D9E8D9459CDEE9DB45C8DEC9DEC1DB5DA08B45A03DFF0000007E08B8FF0000008945A08B45A088060FB646018945A0D9459CDB45A0DEC9D9E8D9459CDEE9DB45C4DEC9DEC1DB5DA08B45A03DFF0000007E08B8FF0000008945A08B45A08846010FB646028945A0D9459CDB45A0DEC9D9E8D9459CDEE9DB45C0" & _
            "DEC9DEC1DB5DA08B45A03DFF0000007E08B8FF0000008945A08B45A0884602C38B45CC488B5DFCF7E38B5DD04B01D8C1E00201C6C38B45A4488B5DFCF7E38B5DA84B01D8C1E00201C6C38B75F48B45E0C1E00201C6565F8B45EC0502000000D1E83D050000007505B8040000008945BCB901000000894DCC51B901000000894DD0894DA851E896FFFFFF31C08A06C1E0088A4601C1E0088A4602575E3B45E80F85310000008B45D889459C8B45BC89C18B45CC01C88945A4D9459CD945D4DEE9D95D9CE86DFFFFFFE8ACFEFFFF575E490F85DAFFFFFF59413B4DFC0F8E9DFFFFFF59418B45F82B45BC39C10F8E84FFFFFFC38B75F48B45E0C1E00201C6565F8B45EC0502000000D1E83D050000007505B8040000008945BCB90100000001C1894DCC51B901000000894DD0894DA851E8ECFEFFFF31C08A06C1E0088A4601C1E0088A4602575E3B45E80F85330000008B45D889459C8B45BCF7D889C18B45CC01C88945A4D9459CD945D4DEE9D95D9CE8C1FEFFFFE800FEFFFF575E410F85DAFFFFFF59413B4DFC0F8E9BFFFFFF59413B4DF80F8E87FFFFFFC38B75F48B45E0C1E00201C6565F8B45EC0502000000D1E83D050000007505B8040000008945BCB901000000894DCC894DA451B9010000008B45BC01C1894DD051E842FEFFFF31C08A06C1E0088A4601C1E0088A4602575E3B45E80F" & _
            "85330000008B45D889459C8B45BCF7D889C18B45D001C88945A8D9459CD945D4DEE9D95D9CE817FEFFFFE856FDFFFF575E410F85DAFFFFFF59413B4DFC0F8E9EFFFFFF59413B4DF80F8E82FFFFFFC38B75F48B45E0C1E00201C6565F8B45EC0502000000D1E83D050000007505B8040000008945BCB901000000894DCC894DA451B901000000894DD051E89DFDFFFF31C08A06C1E0088A4601C1E0088A4602575E3B45E80F85310000008B45D889459C8B45BC89C18B45D001C88945A8D9459CD945D4DEE9D95D9CE874FDFFFFE8B3FCFFFF575E490F85DAFFFFFF59418B45FC2B45BC3B4DFC0F8E9AFFFFFF59413B4DF80F8E83FFFFFFC38B75F48B45E0C1E00201C6565FB8180000008945ACB8B40000008945B0D9EBDB45B0DEF9D95DB0B90100000051894DBCD9E8DB45BCDB45ECDB45ACDEC9DEF9DEE9D9E8DEC1D95DB4B967010000894DB8DB45B8D945B0DEC9D9FEDB45BCDEC9D945D8DEC1DB5DD0DB45B8D945B0DEC9D9FFDB45BCDEC9DB45F8D945D4DEE9DEC1DB5DCC8B45D03D010000007C203B45FC7F1B8B45CC3D010000007C113B45F87F0CE88EFCFFFFE81A000000575E49759D59418B45ECBB18000000F7E339C10F8E68FFFFFFC30FB6068945A0DB45A0D945B4DEC9DB5DA08B45A03DFF00000076088B45C8E9090000003D00000000730231C088060FB646018945A0DB45" & _
            "A0D945B4DEC9DB5DA08B45A03DFF00000076088B45C4E9090000003D00000000730231C08846010FB646028945A0DB45A0D945B4DEC9DB5DA08B45A03DFF00000076088B45C0E9090000003D00000000730231C0884602C3"
    LoadMCodeFromString PicMagnifyMC, _
            "5589E581EC780000005756538B5D08FF338F45FCFF73048F45F8FF73088F45F4FF730C8F45F0FF73108F45ECFF73148F45E8FF73188F45E48B450C8945D88B45108945D48B45148945BCB80A0000008945ACD9E8DB45BCDB45ACDEF9DEF9D95DBC8B45F88B5DFCF7E38945E08B45FCC1E0048945DC8B45E825FF0000008945C08B45E82500FF0000C1E8088945C48B45E8250000FF00C1E8108945C8DB45F8D945D4DEE9D95DD4B8020000008945B0D9E8DB45B0DEF9D95DB08B45E43D00000000750AE81F000000E9110000003D01000000750AE826000000E9000000005B5E5F89EC5DC210008B7DF48B45E0C1E00201C78B75F401C601C6E819000000C38B7DF48B45E0C1E00201C78B75F401C601C6E8C2000000C38B45F889C1894DCC518B45FC89C1894DD0DB45D0D945D8DEE9D945BCDEC9D945D8DEC1DB5DA88B45A83D010000007C053B45FC7E1D57E88B0200008B45C888078B45C48847018B45C08847025FE95F000000DB45CCD945D4DEE9D945BCDEC9D945D4DEC1DB5DA48B45A43D010000007C053B45F87E1D57E84A0200008B45C888078B45C48847018B45C08847025FE91E0000005756E817020000E8270200008A0688078A46018847018A46028847025E5F490F8556FFFFFF59490F8545FFFFFFC38B45F889C1894DCC518B45FC89C1894DD0DB45D0D945D8DEE9D945BC" & _
            "DEC9D945D8DEC1D95DA0DB45CCD945D4DEE9D945BCDEC9D945D4DEC1D95D9CD945A0D945B0DEE9DB5DA8D9459CD945B0DEE9DB5DA48B45A83D010000007C193B45FC7D148B45A43D010000007C0A3B45F87D05E91D00000057E88B0100008B45C888078B45C48847018B45C08847025FE914010000D945A0DB45A8DEE9D95D98D9459CDB45A4DEE9D95D9456E8430100008B5DFCC1E3020FB606894590DB45900FB64604894590DB4590D8E1D94598DEC9DEC10FB6041E894590DB45900FB6441E04894590DB4590D8E1D94598DEC9DEC1D8E1D94594DEC9DEC1DB5D90460FB60689458CDB458C0FB6460489458CDB458CD8E1D94598DEC9DEC10FB6041E89458CDB458C0FB6441E0489458CDB458CD8E1D94598DEC9DEC1D8E1D94594DEC9DEC1DB5D8C460FB606894588DB45880FB64604894588DB4588D8E1D94598DEC9DEC10FB6041E894588DB45880FB6441E04894588DB4588D8E1D94598DEC9DEC1D8E1D94594DEC9DEC1DB5D885EE82800000057E8720000008B459088078B458C8847018B45888847025F490F8562FEFFFF59490F8551FEFFFFC3B8FF0000003945907E0389459039458C7E0389458C3945887E03894588B8000000003945907D0389459039458C7D0389458C3945887D03894588C38B45A4488B5DFCF7E38B5DA84B01D8C1E00201C6C38B45CC488B5DFCF7E38B5D" & _
            "D04B01D8C1E00201C7C38B45A4488B5DFCF7E38B5DA84B01D8C1E00201C7C3"

End Sub

Private Sub Class_Terminate()
    Erase PalBGR
    Set PIC = Nothing
End Sub
