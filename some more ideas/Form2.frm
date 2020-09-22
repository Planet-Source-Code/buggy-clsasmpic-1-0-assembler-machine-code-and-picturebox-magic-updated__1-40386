VERSION 5.00
Begin VB.Form Form2 
   AutoRedraw      =   -1  'True
   BackColor       =   &H8000000A&
   Caption         =   "Form2"
   ClientHeight    =   3885
   ClientLeft      =   165
   ClientTop       =   135
   ClientWidth     =   8700
   LinkTopic       =   "Form1"
   ScaleHeight     =   259
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   580
   StartUpPosition =   2  'CenterScreen
   Begin VB.OptionButton Option1 
      Caption         =   "flashlight"
      Height          =   255
      Index           =   7
      Left            =   4680
      TabIndex        =   11
      Top             =   3240
      Width           =   1695
   End
   Begin VB.OptionButton Option1 
      Caption         =   "red AND blue (x/y)"
      Height          =   255
      Index           =   8
      Left            =   4680
      TabIndex        =   10
      Top             =   3600
      Width           =   1695
   End
   Begin VB.OptionButton Option1 
      Caption         =   "xray"
      Height          =   255
      Index           =   6
      Left            =   4680
      TabIndex        =   9
      Top             =   2880
      Value           =   -1  'True
      Width           =   1695
   End
   Begin VB.OptionButton Option1 
      Caption         =   "magnify"
      Height          =   255
      Index           =   5
      Left            =   4680
      TabIndex        =   8
      Top             =   2280
      Width           =   1695
   End
   Begin VB.OptionButton Option1 
      Caption         =   "blue"
      Height          =   255
      Index           =   4
      Left            =   4680
      TabIndex        =   6
      Top             =   1920
      Width           =   1695
   End
   Begin VB.OptionButton Option1 
      Caption         =   "green"
      Height          =   255
      Index           =   3
      Left            =   4680
      TabIndex        =   5
      Top             =   1560
      Width           =   1695
   End
   Begin VB.OptionButton Option1 
      Caption         =   "red"
      Height          =   255
      Index           =   2
      Left            =   4680
      TabIndex        =   4
      Top             =   1200
      Width           =   1695
   End
   Begin VB.OptionButton Option1 
      Caption         =   "color rotation"
      Height          =   255
      Index           =   1
      Left            =   4680
      TabIndex        =   3
      Top             =   840
      Width           =   1695
   End
   Begin VB.OptionButton Option1 
      Caption         =   "brightness"
      Height          =   255
      Index           =   0
      Left            =   4680
      TabIndex        =   2
      Top             =   480
      Width           =   1695
   End
   Begin VB.Frame Frame1 
      BackColor       =   &H00808080&
      BorderStyle     =   0  'None
      Caption         =   "Frame2"
      Height          =   3615
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   4335
      Begin VB.PictureBox Picture1 
         AutoRedraw      =   -1  'True
         AutoSize        =   -1  'True
         BackColor       =   &H00C0C0C0&
         BorderStyle     =   0  'None
         FillColor       =   &H00808080&
         Height          =   3135
         Left            =   240
         Picture         =   "Form2.frx":0000
         ScaleHeight     =   209
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   256
         TabIndex        =   1
         Top             =   240
         Width           =   3840
      End
   End
   Begin VB.Label Label1 
      Caption         =   "Chose function and move mouse over picbox:"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   4680
      TabIndex        =   7
      Top             =   120
      Width           =   4095
   End
End
Attribute VB_Name = "Form2"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
Private ASMpic As New clsASMpic

Private Sub Form_Load()
    ASMpic = Picture1    'possible coz .picturebox is default property
End Sub

Private Sub Form_Unload(Cancel As Integer)
    Set ASMpic = Nothing

    Dim f As Form
    For Each f In Forms
        Unload f
    Next
    Unload Me
End Sub

Private Sub Picture1_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Dim PICH2 As Integer, PICW2 As Integer
    Dim i As Integer
    PICW2 = Picture1.Width \ Screen.TwipsPerPixelX \ 2
    PICH2 = Picture1.Height \ Screen.TwipsPerPixelY \ 2

    ASMpic.UndoLastDontDraw
    ASMpic.AutoDraw = False
    Select Case X
    Case Is < PICW2
        If Option1(0).Value Then
            ASMpic.ASM_IncrementalPalEffects pal_07_darken, 255 - X * 255 \ PICW2
        ElseIf Option1(1).Value Then
            ASMpic.ASM_IncrementalPalEffects pal_09_rotate_colors_minus, 255 - X * 255 \ PICW2
        ElseIf Option1(2).Value Then
            ASMpic.ASM_IncrementalPalEffects pal_01_redLESS, 255 - X * 255 \ PICW2
        ElseIf Option1(3).Value Then
            ASMpic.ASM_IncrementalPalEffects pal_03_greenLESS, 255 - X * 255 \ PICW2
        ElseIf Option1(4).Value Then
            ASMpic.ASM_IncrementalPalEffects pal_05_blueLESS, 255 - X * 255 \ PICW2
        ElseIf Option1(5).Value Then
            ASMpic.ASM_Magnify X / PICW2
        ElseIf Option1(6).Value Then
            ASMpic.ASM_ColorXEffects colx_9_splurge, vbBlack, 4, X, Y
        ElseIf Option1(7).Value Then
            ASMpic.ASM_ColorXEffects colx_9_splurge, vbWhite, 4, X, Y
        ElseIf Option1(8).Value Then
            ASMpic.ASM_IncrementalPalEffects pal_01_redLESS, 255 - X * 255 \ PICW2
        End If
    Case Else
        If Option1(0).Value Then
            ASMpic.ASM_IncrementalPalEffects pal_06_brighten, (X - PICW2) * 255 \ PICW2
        ElseIf Option1(1).Value Then
            ASMpic.ASM_IncrementalPalEffects pal_08_rotate_colors_plus, (X - PICW2) * 255 \ PICW2
        ElseIf Option1(2).Value Then
            ASMpic.ASM_IncrementalPalEffects pal_00_redMORE, (X - PICW2) * 255 \ PICW2
        ElseIf Option1(3).Value Then
            ASMpic.ASM_IncrementalPalEffects pal_02_greenMORE, (X - PICW2) * 255 \ PICW2
        ElseIf Option1(4).Value Then
            ASMpic.ASM_IncrementalPalEffects pal_04_blueMORE, (X - PICW2) * 255 \ PICW2
        ElseIf Option1(5).Value Then
            ASMpic.ASM_Magnify (X / PICW2 - 0.9) * 10, , , True
        ElseIf Option1(6).Value Then
            ASMpic.ASM_ColorXEffects colx_9_splurge, vbBlack, 4, X, Y
        ElseIf Option1(7).Value Then
            ASMpic.ASM_ColorXEffects colx_9_splurge, vbWhite, 4, X, Y
        ElseIf Option1(8).Value Then
            ASMpic.ASM_IncrementalPalEffects pal_00_redMORE, (X - PICW2) * 255 \ PICW2
        End If
    End Select
    
    Select Case Y
    Case Is < PICH2
        If Option1(8).Value Then
            ASMpic.ASM_IncrementalPalEffects pal_05_blueLESS, Abs((Y - PICH2) * 255 \ PICH2)
        End If
    Case Else
        If Option1(8).Value Then
            ASMpic.ASM_IncrementalPalEffects pal_04_blueMORE, Abs(255 - Y * 255 \ PICH2)
        End If
    End Select
    ASMpic.AutoDraw = True
End Sub
