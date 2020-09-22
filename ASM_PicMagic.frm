VERSION 5.00
Begin VB.Form ASM_PicMagic 
   AutoRedraw      =   -1  'True
   BackColor       =   &H8000000A&
   Caption         =   "ASM_PicMagic"
   ClientHeight    =   8865
   ClientLeft      =   165
   ClientTop       =   135
   ClientWidth     =   13050
   LinkTopic       =   "Form1"
   ScaleHeight     =   591
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   870
   StartUpPosition =   2  'CenterScreen
   Begin VB.TextBox Text1 
      Appearance      =   0  'Flat
      BackColor       =   &H80000000&
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   1215
      Left            =   7800
      MultiLine       =   -1  'True
      TabIndex        =   80
      Text            =   "ASM_PicMagic.frx":0000
      Top             =   3000
      Width           =   3855
   End
   Begin VB.Frame Frame11 
      Caption         =   "Magnify Effects"
      Height          =   1575
      Left            =   6600
      TabIndex        =   76
      Top             =   6960
      Width           =   2055
      Begin VB.CommandButton cmd_magFX 
         Caption         =   "mag antialias @ x,y (X)"
         Height          =   375
         Index           =   1
         Left            =   120
         TabIndex        =   79
         Top             =   1080
         Width           =   1815
      End
      Begin VB.TextBox txt_magfactor 
         Alignment       =   2  'Center
         Height          =   375
         Left            =   120
         TabIndex        =   78
         Text            =   "1.5"
         Top             =   240
         Width           =   1815
      End
      Begin VB.CommandButton cmd_magFX 
         Caption         =   "magnify @ x,y (X)"
         Height          =   375
         Index           =   0
         Left            =   120
         TabIndex        =   77
         Top             =   720
         Width           =   1815
      End
   End
   Begin VB.Frame Frame10 
      BackColor       =   &H00C0FFC0&
      Caption         =   "some ideas..."
      Height          =   2775
      Left            =   10920
      TabIndex        =   69
      Top             =   5280
      Width           =   2055
      Begin VB.CommandButton cmd_idea 
         Caption         =   "patchwork"
         Height          =   375
         Index           =   4
         Left            =   120
         TabIndex        =   81
         Top             =   2280
         Width           =   1815
      End
      Begin VB.HScrollBar HScroll1 
         Height          =   255
         LargeChange     =   100
         Left            =   120
         Max             =   511
         Min             =   1
         SmallChange     =   10
         TabIndex        =   74
         Top             =   480
         Value           =   256
         Width           =   1815
      End
      Begin VB.CommandButton cmd_idea 
         Caption         =   "sparkling stars"
         Height          =   375
         Index           =   3
         Left            =   120
         TabIndex        =   73
         Top             =   1920
         Width           =   1815
      End
      Begin VB.CommandButton cmd_idea 
         Caption         =   "sour rain"
         Height          =   375
         Index           =   2
         Left            =   120
         TabIndex        =   72
         Top             =   1560
         Width           =   1815
      End
      Begin VB.CommandButton cmd_idea 
         Caption         =   "rotate original 360° (X)"
         Height          =   375
         Index           =   1
         Left            =   120
         TabIndex        =   71
         Top             =   1200
         Width           =   1815
      End
      Begin VB.CommandButton cmd_idea 
         Caption         =   "rotate colors"
         Height          =   375
         Index           =   0
         Left            =   120
         TabIndex        =   70
         Top             =   840
         Width           =   1815
      End
      Begin VB.Label Label1 
         Alignment       =   2  'Center
         BackColor       =   &H8000000A&
         Caption         =   "adjust brightness:"
         Height          =   255
         Left            =   120
         TabIndex        =   75
         Top             =   240
         Width           =   1815
      End
   End
   Begin VB.Frame Frame9 
      Caption         =   "ColorX Effects"
      Height          =   3975
      Left            =   8760
      TabIndex        =   56
      Top             =   4440
      Width           =   2055
      Begin VB.CommandButton cmd_colXFX 
         BackColor       =   &H00FFC0C0&
         Caption         =   "splurge @ x,y"
         Height          =   375
         Index           =   9
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   66
         Top             =   3480
         Width           =   1815
      End
      Begin VB.CommandButton cmd_colXFX 
         BackColor       =   &H00FFC0C0&
         Caption         =   "diffuse color X right"
         Height          =   375
         Index           =   8
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   65
         Top             =   3120
         Width           =   1815
      End
      Begin VB.CommandButton cmd_colXFX 
         BackColor       =   &H00FFC0C0&
         Caption         =   "diffuse color X left"
         Height          =   375
         Index           =   7
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   64
         Top             =   2760
         Width           =   1815
      End
      Begin VB.CommandButton cmd_colXFX 
         BackColor       =   &H00FFC0C0&
         Caption         =   "diffuse color X down"
         Height          =   375
         Index           =   6
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   63
         Top             =   2400
         Width           =   1815
      End
      Begin VB.CommandButton cmd_colXFX 
         BackColor       =   &H00FFC0C0&
         Caption         =   "diffuse color X up"
         Height          =   375
         Index           =   5
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   62
         Top             =   2040
         Width           =   1815
      End
      Begin VB.CommandButton cmd_colXFX 
         BackColor       =   &H00FFC0C0&
         Caption         =   "diffuse color X"
         Height          =   375
         Index           =   4
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   61
         Top             =   1680
         Width           =   1815
      End
      Begin VB.CommandButton cmd_colXFX 
         BackColor       =   &H00FFC0C0&
         Caption         =   "add color X dots"
         Height          =   375
         Index           =   3
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   60
         Top             =   1320
         Width           =   1815
      End
      Begin VB.CommandButton cmd_colXFX 
         BackColor       =   &H00FFC0C0&
         Caption         =   "add vert color X lines"
         Height          =   375
         Index           =   2
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   59
         Top             =   960
         Width           =   1815
      End
      Begin VB.CommandButton cmd_colXFX 
         BackColor       =   &H00FFC0C0&
         Caption         =   "add horz color X lines"
         Height          =   375
         Index           =   1
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   58
         Top             =   600
         Width           =   1815
      End
      Begin VB.CommandButton cmd_colXFX 
         BackColor       =   &H00FFC0C0&
         Caption         =   "add random color X"
         Height          =   375
         Index           =   0
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   57
         Top             =   240
         Width           =   1815
      End
   End
   Begin VB.Frame Frame8 
      BackColor       =   &H8000000A&
      Caption         =   "Program Flow"
      Height          =   735
      Left            =   120
      TabIndex        =   51
      Top             =   120
      Width           =   7455
      Begin VB.CommandButton cmd_progFlow 
         BackColor       =   &H00C0C0FF&
         Caption         =   "reset"
         Height          =   375
         Index           =   3
         Left            =   5520
         Style           =   1  'Graphical
         TabIndex        =   55
         Top             =   240
         Width           =   1815
      End
      Begin VB.CommandButton cmd_progFlow 
         BackColor       =   &H00C0C0FF&
         Caption         =   "undo"
         Height          =   375
         Index           =   2
         Left            =   3720
         Style           =   1  'Graphical
         TabIndex        =   54
         Top             =   240
         Width           =   1815
      End
      Begin VB.CommandButton cmd_progFlow 
         BackColor       =   &H00C0C0FF&
         Caption         =   "save picture"
         Height          =   375
         Index           =   1
         Left            =   1920
         Style           =   1  'Graphical
         TabIndex        =   53
         Top             =   240
         Width           =   1815
      End
      Begin VB.CommandButton cmd_progFlow 
         BackColor       =   &H00C0C0FF&
         Caption         =   "load picture"
         Height          =   375
         Index           =   0
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   52
         Top             =   240
         Width           =   1815
      End
   End
   Begin VB.Frame Frame7 
      Caption         =   "Palette Effects"
      Height          =   3615
      Left            =   120
      TabIndex        =   41
      Top             =   4440
      Width           =   2055
      Begin VB.CommandButton cmd_palFX 
         Caption         =   "black or white"
         Height          =   375
         Index           =   8
         Left            =   120
         TabIndex        =   50
         Top             =   3120
         Width           =   1815
      End
      Begin VB.CommandButton cmd_palFX 
         Caption         =   "not black to white"
         Height          =   375
         Index           =   7
         Left            =   120
         TabIndex        =   49
         Top             =   2760
         Width           =   1815
      End
      Begin VB.CommandButton cmd_palFX 
         Caption         =   "not white to black"
         Height          =   375
         Index           =   6
         Left            =   120
         TabIndex        =   48
         Top             =   2400
         Width           =   1815
      End
      Begin VB.CommandButton cmd_palFX 
         Caption         =   "white to black"
         Height          =   375
         Index           =   5
         Left            =   120
         TabIndex        =   47
         Top             =   2040
         Width           =   1815
      End
      Begin VB.CommandButton cmd_palFX 
         Caption         =   "black to white"
         Height          =   375
         Index           =   4
         Left            =   120
         TabIndex        =   46
         Top             =   1680
         Width           =   1815
      End
      Begin VB.CommandButton cmd_palFX 
         Caption         =   "whiten"
         Height          =   375
         Index           =   3
         Left            =   120
         TabIndex        =   45
         Top             =   1320
         Width           =   1815
      End
      Begin VB.CommandButton cmd_palFX 
         Caption         =   "blacken"
         Height          =   375
         Index           =   2
         Left            =   120
         TabIndex        =   44
         Top             =   960
         Width           =   1815
      End
      Begin VB.CommandButton cmd_palFX 
         Caption         =   "grey"
         Height          =   375
         Index           =   1
         Left            =   120
         TabIndex        =   43
         Top             =   600
         Width           =   1815
      End
      Begin VB.CommandButton cmd_palFX 
         Caption         =   "invert"
         Height          =   375
         Index           =   0
         Left            =   120
         TabIndex        =   42
         Top             =   240
         Width           =   1815
      End
   End
   Begin VB.Frame Frame6 
      BackColor       =   &H8000000A&
      Caption         =   "Color X"
      Height          =   2655
      Left            =   9840
      TabIndex        =   27
      Top             =   120
      Width           =   2055
      Begin VB.CommandButton cmd_choseColor 
         Caption         =   "chose color dialog"
         Height          =   375
         Left            =   120
         TabIndex        =   82
         Top             =   1680
         Width           =   1815
      End
      Begin VB.TextBox txt_centerX 
         Alignment       =   2  'Center
         Height          =   375
         Left            =   120
         TabIndex        =   68
         Text            =   "txt_centerX"
         Top             =   2160
         Width           =   855
      End
      Begin VB.TextBox txt_centerY 
         Alignment       =   2  'Center
         Height          =   375
         Left            =   1080
         TabIndex        =   67
         Text            =   "txt_centerY"
         Top             =   2160
         Width           =   855
      End
      Begin VB.Shape shp_colorX 
         BackColor       =   &H00000000&
         BackStyle       =   1  'Opaque
         Height          =   375
         Left            =   120
         Top             =   1200
         Width           =   1815
      End
      Begin VB.Label lbl_colX 
         BackColor       =   &H00FF0000&
         BorderStyle     =   1  'Fixed Single
         Height          =   375
         Index           =   7
         Left            =   1560
         TabIndex        =   35
         Top             =   720
         Width           =   375
      End
      Begin VB.Label lbl_colX 
         BackColor       =   &H0000FF00&
         BorderStyle     =   1  'Fixed Single
         Height          =   375
         Index           =   6
         Left            =   1080
         TabIndex        =   34
         Top             =   720
         Width           =   375
      End
      Begin VB.Label lbl_colX 
         BackColor       =   &H0000FFFF&
         BorderStyle     =   1  'Fixed Single
         Height          =   375
         Index           =   5
         Left            =   600
         TabIndex        =   33
         Top             =   720
         Width           =   375
      End
      Begin VB.Label lbl_colX 
         BackColor       =   &H000000FF&
         BorderStyle     =   1  'Fixed Single
         Height          =   375
         Index           =   4
         Left            =   120
         TabIndex        =   32
         Top             =   720
         Width           =   375
      End
      Begin VB.Label lbl_colX 
         BackColor       =   &H00FFFFFF&
         BorderStyle     =   1  'Fixed Single
         Height          =   375
         Index           =   3
         Left            =   1560
         TabIndex        =   31
         Top             =   240
         Width           =   375
      End
      Begin VB.Label lbl_colX 
         BackColor       =   &H00C0C0C0&
         BorderStyle     =   1  'Fixed Single
         Height          =   375
         Index           =   2
         Left            =   1080
         TabIndex        =   30
         Top             =   240
         Width           =   375
      End
      Begin VB.Label lbl_colX 
         BackColor       =   &H00808080&
         BorderStyle     =   1  'Fixed Single
         Height          =   375
         Index           =   1
         Left            =   600
         TabIndex        =   29
         Top             =   240
         Width           =   375
      End
      Begin VB.Label lbl_colX 
         BackColor       =   &H00000000&
         BorderStyle     =   1  'Fixed Single
         Height          =   375
         Index           =   0
         Left            =   120
         TabIndex        =   28
         Top             =   240
         Width           =   375
      End
   End
   Begin VB.Frame Frame5 
      BackColor       =   &H00FFC0C0&
      Caption         =   "Amount"
      Height          =   1815
      Left            =   7680
      TabIndex        =   22
      Top             =   120
      Width           =   2055
      Begin VB.OptionButton Option1 
         BackColor       =   &H00FFC0C0&
         Caption         =   "factor 8"
         Height          =   375
         Index           =   3
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   26
         Top             =   1320
         Width           =   1815
      End
      Begin VB.OptionButton Option1 
         BackColor       =   &H00FFC0C0&
         Caption         =   "factor 4"
         Height          =   375
         Index           =   2
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   25
         Top             =   960
         Width           =   1815
      End
      Begin VB.OptionButton Option1 
         BackColor       =   &H00FFC0C0&
         Caption         =   "factor 2"
         Height          =   375
         Index           =   1
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   24
         Top             =   600
         Value           =   -1  'True
         Width           =   1815
      End
      Begin VB.OptionButton Option1 
         BackColor       =   &H00FFC0C0&
         Caption         =   "factor 1"
         Height          =   375
         Index           =   0
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   23
         Top             =   240
         Width           =   1815
      End
   End
   Begin VB.Frame Frame4 
      Caption         =   "Incremental Pal Effects"
      Height          =   4335
      Left            =   2280
      TabIndex        =   4
      Top             =   4440
      Width           =   2055
      Begin VB.CommandButton cmd_incrPalFX 
         BackColor       =   &H00FFC0C0&
         Caption         =   "add noise"
         Height          =   375
         Index           =   10
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   18
         Top             =   3840
         Width           =   1815
      End
      Begin VB.CommandButton cmd_incrPalFX 
         BackColor       =   &H00FFC0C0&
         Caption         =   "rotate colors -"
         Height          =   375
         Index           =   9
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   17
         Top             =   3480
         Width           =   1815
      End
      Begin VB.CommandButton cmd_incrPalFX 
         BackColor       =   &H00FFC0C0&
         Caption         =   "rotate colors +"
         Height          =   375
         Index           =   8
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   21
         Top             =   3120
         Width           =   1815
      End
      Begin VB.CommandButton cmd_incrPalFX 
         BackColor       =   &H00FFC0C0&
         Caption         =   "darken"
         Height          =   375
         Index           =   7
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   20
         Top             =   2760
         Width           =   1815
      End
      Begin VB.CommandButton cmd_incrPalFX 
         BackColor       =   &H00FFC0C0&
         Caption         =   "brighten"
         Height          =   375
         Index           =   6
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   19
         Top             =   2400
         Width           =   1815
      End
      Begin VB.CommandButton cmd_incrPalFX 
         BackColor       =   &H00FFC0C0&
         Caption         =   "less blue"
         Height          =   375
         Index           =   5
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   16
         Top             =   2040
         Width           =   1815
      End
      Begin VB.CommandButton cmd_incrPalFX 
         BackColor       =   &H00FFC0C0&
         Caption         =   "bluer"
         Height          =   375
         Index           =   4
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   15
         Top             =   1680
         Width           =   1815
      End
      Begin VB.CommandButton cmd_incrPalFX 
         BackColor       =   &H00FFC0C0&
         Caption         =   "less green"
         Height          =   375
         Index           =   3
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   14
         Top             =   1320
         Width           =   1815
      End
      Begin VB.CommandButton cmd_incrPalFX 
         BackColor       =   &H00FFC0C0&
         Caption         =   "greener"
         Height          =   375
         Index           =   2
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   13
         Top             =   960
         Width           =   1815
      End
      Begin VB.CommandButton cmd_incrPalFX 
         BackColor       =   &H00FFC0C0&
         Caption         =   "less red"
         Height          =   375
         Index           =   1
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   12
         Top             =   600
         Width           =   1815
      End
      Begin VB.CommandButton cmd_incrPalFX 
         BackColor       =   &H00FFC0C0&
         Caption         =   "redder"
         Height          =   375
         Index           =   0
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   11
         Top             =   240
         Width           =   1815
      End
   End
   Begin VB.Frame Frame3 
      Caption         =   "Rotation Effects"
      Height          =   2415
      Left            =   6600
      TabIndex        =   3
      Top             =   4440
      Width           =   2055
      Begin VB.CommandButton cmd_rotFX 
         Caption         =   "rot original antialias (X)"
         Height          =   375
         Index           =   3
         Left            =   120
         TabIndex        =   40
         Top             =   1920
         Width           =   1815
      End
      Begin VB.CommandButton cmd_rotFX 
         Caption         =   "rot original (X)"
         Height          =   375
         Index           =   2
         Left            =   120
         TabIndex        =   39
         Top             =   1560
         Width           =   1815
      End
      Begin VB.CommandButton cmd_rotFX 
         Caption         =   "rot pic antialias (X)"
         Height          =   375
         Index           =   1
         Left            =   120
         TabIndex        =   38
         Top             =   1080
         Width           =   1815
      End
      Begin VB.CommandButton cmd_rotFX 
         Caption         =   "rot pic (X)"
         Height          =   375
         Index           =   0
         Left            =   120
         TabIndex        =   37
         Top             =   720
         Width           =   1815
      End
      Begin VB.TextBox txt_angle 
         Alignment       =   2  'Center
         Height          =   375
         Left            =   120
         TabIndex        =   36
         Text            =   "15"
         Top             =   240
         Width           =   1815
      End
   End
   Begin VB.Frame Frame2 
      Caption         =   "Pixel Effects"
      Height          =   2535
      Left            =   4440
      TabIndex        =   2
      Top             =   4440
      Width           =   2055
      Begin VB.CommandButton cmd_pixFX 
         BackColor       =   &H00FFC0C0&
         Caption         =   "twirl (X)"
         Height          =   375
         Index           =   5
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   10
         Top             =   2040
         Width           =   1815
      End
      Begin VB.CommandButton cmd_pixFX 
         Caption         =   "relief (X)"
         Height          =   375
         Index           =   4
         Left            =   120
         TabIndex        =   9
         Top             =   1680
         Width           =   1815
      End
      Begin VB.CommandButton cmd_pixFX 
         BackColor       =   &H00FFC0C0&
         Caption         =   "ripple"
         Height          =   375
         Index           =   3
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   8
         Top             =   1320
         Width           =   1815
      End
      Begin VB.CommandButton cmd_pixFX 
         Caption         =   "emboss (X)"
         Height          =   375
         Index           =   2
         Left            =   120
         TabIndex        =   7
         Top             =   960
         Width           =   1815
      End
      Begin VB.CommandButton cmd_pixFX 
         Caption         =   "contour (X)"
         Height          =   375
         Index           =   1
         Left            =   120
         TabIndex        =   6
         Top             =   600
         Width           =   1815
      End
      Begin VB.CommandButton cmd_pixFX 
         BackColor       =   &H00FFC0C0&
         Caption         =   "smooth"
         Height          =   375
         Index           =   0
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   5
         Top             =   240
         Width           =   1815
      End
   End
   Begin VB.Frame Frame1 
      BackColor       =   &H00808080&
      BorderStyle     =   0  'None
      Caption         =   "Frame2"
      Height          =   3375
      Left            =   120
      TabIndex        =   0
      Top             =   960
      Width           =   7455
      Begin VB.PictureBox Picture1 
         AutoRedraw      =   -1  'True
         AutoSize        =   -1  'True
         BackColor       =   &H00C0C0C0&
         BorderStyle     =   0  'None
         FillColor       =   &H00808080&
         Height          =   3135
         Left            =   120
         Picture         =   "ASM_PicMagic.frx":00F4
         ScaleHeight     =   209
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   256
         TabIndex        =   1
         Top             =   120
         Width           =   3840
      End
   End
End
Attribute VB_Name = "ASM_PicMagic"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
Private ASMpic As New clsASMpic
Private LastCommandWasBrightnessSlider As Boolean    'just for brightness slider example

Private Property Get Amount() As Integer
    Amount = Abs(Option1.Item(0).Value * 1 + Option1.Item(1).Value * 2 + Option1.Item(2).Value * 4 + Option1.Item(3).Value * 8)
End Property
Private Property Get colorX() As Long
    colorX = shp_colorX.BackColor
End Property

Private Sub cmd_choseColor_Click()
    Dim result As Long
    result = ASMpic.dialogChoseColor
    If result <> -1 Then shp_colorX.BackColor = result
End Sub

Private Sub Form_Load()
    ASMpic = Picture1    'possible coz .picturebox is default property
End Sub

Private Sub cmd_progFlow_Click(Index As Integer)
    Select Case Index
    Case 0: ASMpic.dialogShowOpen
    Case 1: ASMpic.dialogShowSave
    Case 2: ASMpic.UndoLast
    Case 3: ASMpic.ResetPic
    End Select
End Sub

Private Sub cmd_colXFX_Click(Index As Integer)
    Select Case Index
    Case 0: ASMpic.ASM_ColorXEffects colx_0_addRandomColorX, colorX, Amount
    Case 1: ASMpic.ASM_ColorXEffects colx_1_addHORZcolorXlines, colorX, Amount
    Case 2: ASMpic.ASM_ColorXEffects colx_2_addVERTcolorXlines, colorX, Amount
    Case 3: ASMpic.ASM_ColorXEffects colx_3_addColorXdots, colorX, Amount
    Case 4: ASMpic.ASM_ColorXEffects colx_4_diffuseColorX, colorX, Amount
    Case 5: ASMpic.ASM_ColorXEffects colx_5_diffuseColorXUP, colorX, Amount
    Case 6: ASMpic.ASM_ColorXEffects colx_6_diffuseColorXDOWN, colorX, Amount
    Case 7: ASMpic.ASM_ColorXEffects colx_7_diffuseColorXLEFT, colorX, Amount
    Case 8: ASMpic.ASM_ColorXEffects colx_8_diffuseColorXRIGHT, colorX, Amount
    Case 9: ASMpic.ASM_ColorXEffects colx_9_splurge, colorX, Amount, Val(txt_centerX), Val(txt_centerY)
    End Select
    LastCommandWasBrightnessSlider = False
End Sub

Private Sub cmd_incrPalFX_Click(Index As Integer)
    Select Case Index
    Case 0: ASMpic.ASM_IncrementalPalEffects pal_00_redMORE, Amount
    Case 1: ASMpic.ASM_IncrementalPalEffects pal_01_redLESS, Amount
    Case 2: ASMpic.ASM_IncrementalPalEffects pal_02_greenMORE, Amount
    Case 3: ASMpic.ASM_IncrementalPalEffects pal_03_greenLESS, Amount
    Case 4: ASMpic.ASM_IncrementalPalEffects pal_04_blueMORE, Amount
    Case 5: ASMpic.ASM_IncrementalPalEffects pal_05_blueLESS, Amount
    Case 6: ASMpic.ASM_IncrementalPalEffects pal_06_brighten, Amount
    Case 7: ASMpic.ASM_IncrementalPalEffects pal_07_darken, Amount
    Case 8: ASMpic.ASM_IncrementalPalEffects pal_08_rotate_colors_plus, Amount
    Case 9: ASMpic.ASM_IncrementalPalEffects pal_09_rotate_colors_minus, Amount
    Case 10: ASMpic.ASM_IncrementalPalEffects pal_10_noise, Amount
    End Select
    LastCommandWasBrightnessSlider = False
End Sub

Private Sub cmd_palFX_Click(Index As Integer)
    Select Case Index
    Case 0: ASMpic.ASM_PalEffects pal_11_invert, Amount, colorX
    Case 1: ASMpic.ASM_PalEffects pal_12_grey, Amount, colorX
    Case 2: ASMpic.ASM_PalEffects pal_13_blacken, Amount, colorX
    Case 3: ASMpic.ASM_PalEffects pal_14_whiten, Amount, colorX
    Case 4: ASMpic.ASM_PalEffects pal_15_BtoW, Amount, colorX
    Case 5: ASMpic.ASM_PalEffects pal_16_WtoB, Amount, colorX
    Case 6: ASMpic.ASM_PalEffects pal_17_NWtoB, Amount, colorX
    Case 7: ASMpic.ASM_PalEffects pal_18_NBtoW, Amount, colorX
    Case 8: ASMpic.ASM_PalEffects pal_19_BlackORWhite, Amount, colorX
    End Select
    LastCommandWasBrightnessSlider = False
End Sub

Private Sub cmd_pixFX_Click(Index As Integer)
    Select Case Index
    Case 0: ASMpic.ASM_PixelEffects pix_0_smooth, Amount, colorX
    Case 1: ASMpic.ASM_PixelEffects pix_1_contour, Amount, colorX
    Case 2: ASMpic.ASM_PixelEffects pix_2_emboss, Amount, colorX
    Case 3: ASMpic.ASM_PixelEffects pix_3_ripple, Amount, colorX
    Case 4: ASMpic.ASM_PixelEffects pix_4_relief, Amount, colorX
    Case 5: ASMpic.ASM_PixelEffects pix_5_twirl, Amount, colorX
    End Select
    LastCommandWasBrightnessSlider = False
End Sub

Private Sub cmd_rotFX_Click(Index As Integer)
    Select Case Index
    Case 0: ASMpic.ASM_Rotate Val(txt_angle.Text), False, False, colorX
    Case 1: ASMpic.ASM_Rotate Val(txt_angle.Text), True, False, colorX
    Case 2: ASMpic.ASM_Rotate Val(txt_angle.Text), False, True, colorX
    Case 3: ASMpic.ASM_Rotate Val(txt_angle.Text), True, True, colorX
    End Select
    LastCommandWasBrightnessSlider = False
End Sub

Private Sub cmd_magFX_Click(Index As Integer)
    Select Case Index
    Case 0: ASMpic.ASM_Magnify Val(txt_magfactor), Val(txt_centerX.Text), Val(txt_centerY.Text), False, colorX
    Case 1: ASMpic.ASM_Magnify Val(txt_magfactor), Val(txt_centerX.Text), Val(txt_centerY.Text), True, colorX
    End Select
    LastCommandWasBrightnessSlider = False
End Sub

Private Sub cmd_idea_Click(Index As Integer)
    Dim i As Integer
    Select Case Index
    Case 0    'rotate colors
        For i = 1 To 50
            ASMpic.ASM_IncrementalPalEffects pal_08_rotate_colors_plus, 10
            DoEvents
        Next
        For i = 1 To 50
            ASMpic.ASM_IncrementalPalEffects pal_09_rotate_colors_minus, 10
            DoEvents
        Next
    Case 1    'rotate original 360°
        For i = 0 To 360 Step 10
            ASMpic.ASM_Rotate i, False, True, colorX
            DoEvents
        Next
    Case 2    'sour rain
        ASMpic.AutoDraw = False
        ASMpic.ASM_IncrementalPalEffects pal_06_brighten, 30
        ASMpic.ASM_ColorXEffects colx_0_addRandomColorX, vbBlack, 100
        ASMpic.ASM_ColorXEffects colx_4_diffuseColorX, vbBlack, 4
        ASMpic.ASM_ColorXEffects colx_6_diffuseColorXDOWN, vbBlack, 15
        ASMpic.AutoDraw = True
    Case 3    'sparkling stars
        ASMpic.AutoDraw = False
        ASMpic.ASM_ColorXEffects colx_0_addRandomColorX, vbWhite, 8
        ASMpic.ASM_ColorXEffects colx_5_diffuseColorXUP, vbWhite, 10
        ASMpic.ASM_ColorXEffects colx_6_diffuseColorXDOWN, vbWhite, 10
        ASMpic.ASM_ColorXEffects colx_7_diffuseColorXLEFT, vbWhite, 10
        ASMpic.ASM_ColorXEffects colx_8_diffuseColorXRIGHT, vbWhite, 10
        ASMpic.AutoDraw = True
    Case 4    'patchwork
        ASMpic.AutoDraw = False
        ASMpic.ASM_ColorXEffects colx_1_addHORZcolorXlines, vbWhite, 9
        ASMpic.ASM_ColorXEffects colx_2_addVERTcolorXlines, vbWhite, 9
        ASMpic.ASM_ColorXEffects colx_6_diffuseColorXDOWN, vbWhite, 4
        ASMpic.ASM_ColorXEffects colx_7_diffuseColorXLEFT, vbWhite, 4
        ASMpic.ASM_ColorXEffects colx_1_addHORZcolorXlines, vbBlack, 9
        ASMpic.ASM_ColorXEffects colx_2_addVERTcolorXlines, vbBlack, 9
        ASMpic.ASM_ColorXEffects colx_5_diffuseColorXUP, vbBlack, 6
        ASMpic.ASM_ColorXEffects colx_8_diffuseColorXRIGHT, vbBlack, 6
        ASMpic.AutoDraw = True
    End Select
    LastCommandWasBrightnessSlider = False
End Sub

Private Sub lbl_colX_Click(Index As Integer)
    shp_colorX.BackColor = lbl_colX(Index).BackColor
End Sub

Private Sub HScroll1_Scroll()
    If LastCommandWasBrightnessSlider Then ASMpic.UndoLastDontDraw
    If HScroll1.Value = 256 Then Exit Sub
    If HScroll1.Value < 256 Then    'darken
        ASMpic.ASM_IncrementalPalEffects 7, 255 - HScroll1.Value
    Else    'brighten
        ASMpic.ASM_IncrementalPalEffects 6, HScroll1.Value - 256
    End If
    LastCommandWasBrightnessSlider = True
End Sub

Private Sub HScroll1_Change()
    If LastCommandWasBrightnessSlider Then ASMpic.UndoLastDontDraw
    If HScroll1.Value = 256 Then Exit Sub
    If HScroll1.Value < 256 Then    'darken
        ASMpic.ASM_IncrementalPalEffects pal_07_darken, 255 - HScroll1.Value
    Else    'brighten
        ASMpic.ASM_IncrementalPalEffects pal_06_brighten, HScroll1.Value - 256
    End If
    LastCommandWasBrightnessSlider = True
End Sub

Private Sub Picture1_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
    If Button = 1 Then
        txt_centerX = X
        txt_centerY = Y
    ElseIf Button = 2 Then
        shp_colorX.BackColor = Picture1.Point(X, Y)
    End If
End Sub

Private Sub Form_Unload(Cancel As Integer)
    Set ASMpic = Nothing

    Dim f As Form
    For Each f In Forms
        Unload f
    Next
    Unload Me
End Sub

