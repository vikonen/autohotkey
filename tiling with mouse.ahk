; [HOTKEYS]
; 
; ralt + mbutton : to drag windows according to best-guess
; ralt + rbutton on edges of window : to resize and snap according to grid or other windows
; ralt + rbutton on middle of window : to move and snap according to grid or other windows
; ralt + lbutton : for quick colour-picker/pixel ruler
; ctrl + alt + a : minimize active window
; ctrl + alt + w : close active window
;
; 
; [PREPARATION]
; 
; The script needs an image called 000000.png in the same directory as the script for the grid to work.
; The image I'm using is a 1x1 pixel with the colour of #000, but any image can theoretically be used.
; If you do not wish to prepare an image, change UseGrid (below) to 0.
;
; 
; [CONFIGURATION]
; 
; Imagine the tiling grid that you wish to create, and the lines that make it up.
; For each vertical line starting from the left-most of your screen (IMPORTANT to be in ASCENDING ORDER), 
; type the following on one line in the variable VerticalLines below:
; 
; x-pos of line, 
; index of horizontal line representing top edge (ignore first if you don't understand), 
; index of horizontal line representing bottom edge (ignore first if you don't understand), 
; corner?, (1 if the line is at the edge of the screen, 0 otherwise (i.e. you want double the amount of margin border))
; resize-only?, (1 if you want the line to be of lesser priority when selecting best-fit-tile, 0 otherwise)
; 
; After that, repeat the steps for each horizontal line:
; 
; y-pos of line, 
; index of vertical line representing left edge (refer to VerticalLines, the first line is index 1 and the nth line is index n)
; index of vertical line representing right edge (refer to VerticalLines, the first line is index 1 and the nth line is index n)
; corner?, (1 if the line is at the edge of the screen, 0 otherwise (i.e. you want double the amount of margin border))
; resize-only?, (1 if you want the line to be of lesser priority when selecting best-fit-tile, 0 otherwise)
;
; The syntax is the same as in VerticalLines above.
; Remember to finish up VerticalLines with the horizontal line indices after completing this step.
; 
; An example grid would be this:
; VerticalLines = 
; (
; V[1] := [ 0,    1, 3, 1, 0 ]
; V[2] := [ 1440, 1, 3, 0, 0 ]
; V[3] := [ 1920, 1, 3, 1, 0 ]
; )
; HorizontalLines = 
; (
; H[1] := [ 0,     1, 3, 1, 0 ]
; H[2] := [ 540,   2, 3, 0, 0 ]
; H[3] := [ 1080,  1, 3, 1, 0 ]
; )
;
; And this would represent a grid that looks something like this
;
; +-----+-+
; |     | |
; |     +-+
; |     | |
; +-----+-+

SysGet, ScreenX, 76 ; SM_XVIRTUALSCREEN
SysGet, ScreenY, 77 ; SM_YVIRTUALSCREEN
SysGet, ScreenW, 78 ; SM_CXVIRTUALSCREEN
SysGet, ScreenH, 79 ; SM_CYVIRTUALSCREEN
MarginWidth := 16
MarginWidthHalf := MarginWidth//2
SnapDistance := 32
MinimumMovement := 5
GridColor := "FFFFFF"
UseGrid := 0
Exceptions := 1

; V[n]:= [ x-coord,   y0-index, y1-index, corner?, resize-only?]
V := []
V[1]  := [ -1440,     6,  10, 1, 0 ]
V[2]  := [ -1100,     6,  10, 0, 0 ]
V[3]  := [ V[2][1]/2, 6,  10, 0, 1 ]
V[4]  := [ 0,         1,  5,  1, 0 ]
V[5]  := [ 480,       4,  5,  0, 1 ]
V[6]  := [ 960,       4,  5,  0, 1 ]
V[7]  := [ 1440,      1,  5,  0, 0 ]
V[8]  := [ 1860,      1,  5,  1, 0 ]

H := []
H[1]  := [ 0,         4,  8,  1, 0 ]
H[2]  := [ 360,       7,  8,  0, 0 ]
H[3]  := [ 720,       7,  8,  0, 1 ]
H[4]  := [ 840,       4,  7,  0, 1 ]
H[5]  := [ 1080,      4,  8,  1, 0 ]
H[6]  := [ 196,       1,  4,  1, 0 ]
H[7]  := [ 350,       1,  2,  0, 0 ]
H[8]  := [ 711,       1,  2,  0, 0 ]
H[9]  := [ 636,       2,  4,  0, 1 ]
H[10] := [ 1080 ,      1,  4,  1, 0 ]

; some other calculation based positions, first is for a 16:9 grid, second is just to half the available space.
H[4][1] := (V[7][1] - MarginWidth - MarginWidthHalf)/16*9 + MarginWidth + MarginWidthHalf
H[9][1] := (H[10][1]-H[6][1])/2+H[6][1]

; DO NOT CHANGE ANYTHING BELOW THIS LINE

CoordMode, Mouse, Screen
CoordMode, Pixel, Screen
#SingleInstance, Force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Recommended for catching common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetBatchLines, -1
SetWinDelay, -1

Grid := CreateGrid()
Return

^!w::WinClose, A
^!a::WinMinimize, A
~ScrollLock::ShowGrid()
~ScrollLock Up::HideGrid()

; Color Picker + Ruler
>!LButton::
    If (GetKeyState("RButton", "P") or GetKeyState("MButton", "P"))
        Return
    MouseGetPos, X, Y
    If (!OldX)
    {
        OldX := X, OldY := Y
    }
    Length := X - OldX
    Height := Y - OldY
    D := round(sqrt(Length*Length + Height*Height), 1)
    OldX := X
    OldY := Y
    PixelGetColor, Color, X, Y, Slow|RGB
    Color := SubStr(Color, 3)
    Clipboard := Color
    R := "0x" . SubStr(Color, 1, 2)
    R += 0
    G := "0x" . SubStr(Color, 3, 2)
    G += 0
    B := "0x" . SubStr(Color, 5, 2)
    B += 0
    ToolTip(Color . "`tX: " . X . "`nR: " . R . "`tY: " . Y . "`nG: " . G . "`tL: " . Length . "`nB: " . B . "`tH: " . Height . "`n`tD: " . D, 5000)
Return

ToolTip(text, duration = 2000)
{
    ToolTip, % text
    SetTimer, RemoveToolTip, % -duration
}
RemoveToolTip:
    ToolTip
Return

GetLinePos(type, index)
{
    Global
    Corner := %type%[index][4]
    Resize := %type%[index][5]
    If (type = "V")
    {
        Y0 := H[V[index][2]][1]
        Y1 := H[V[index][3]][1]
        Return V[index][1]
    }
    Else If (type = "H")
    {
        X0 := V[H[index][2]][1]
        X1 := V[H[index][3]][1]
        Return H[index][1]
    }
}

GetLeftLine(MouseX, MouseY, Best=0)
{
    Global
    Loop % V.MaxIndex()
    {
        Index := V.MaxIndex() - A_Index + 1
        X := GetLinePos("V", Index)
        If (Best and Resize)
            Continue
        If (MouseY >= Y0 and MouseY <= Y1)
        {
            If (MouseX > X)
            {
                Return Index
            }
        }
    }
    Return 0
}

GetRightLine(MouseX, MouseY, Best=0)
{
    Global
    Loop % V.MaxIndex()
    {
        X := GetLinePos("V", A_Index)
        If (Best and Resize)
            Continue
        If (MouseY >= Y0 and MouseY <= Y1)
        {
            If (MouseX < X)
            {
                Return A_Index
            }
        }
    }
    Return 0
}

GetTopLine(MouseX, MouseY, Best=0)
{
    Global
    Loop % H.MaxIndex()
    {
        Index := H.MaxIndex() - A_Index + 1
        Y := GetLinePos("H", Index)
        If (Best and Resize)
            Continue
        If (MouseX >= X0 and MouseX <= X1)
        {
            If (MouseY > Y)
            {
                Return Index
            }
        }
    }
    Return 0
}

GetBottomLine(MouseX, MouseY, Best=0)
{
    Global
    Loop % H.MaxIndex()
    {
        Y := GetLinePos("H", A_Index)
        If (Best and Resize)
            Continue
        If (MouseX >= X0 and MouseX <= X1)
        {
            If (MouseY < Y)
            {
                Return A_Index
            }
        }
    }
    Return 0
}

GetLeftEdge(MouseX, MouseY, CurrentWindow)
{
    Global SnapDistance, ScreenX, MarginWidth
    If (abs(ScreenX + MarginWidth - MouseX) < SnapDistance)
        Return ScreenX + MarginWidth

    WinGetPos, CurrWinX, CurrWinY, CurrWinW, CurrWinH, % "ahk_id" . CurrentWindow
    CurrWinB := CurrWinY + CurrWinH
    Found := 0
    BestDistance := SnapDistance 
    WinGet, id, list,,, Program Manager
    Loop, %id%
    {
        If (id%A_Index% = CurrentWindow)
            Continue
        WinGetPos, WinX, WinY, WinW, WinH, % "ahk_id" . id%A_Index%
        If (CurrWinY > WinY + WinH + SnapDistance or CurrWinB + SnapDistance < WinY)
            Continue
        NewDistance := abs(WinX - MouseX)
        If (NewDistance < BestDistance)
        {
            Found := 1
            Pos := WinX
            BestDistance := NewDistance
        }
        WinRight := WinX + WinW
        NewDistance := abs(WinRight + MarginWidth - MouseX)
        If (NewDistance < BestDistance)
        {
            Found := 1
            Pos := WinRight + MarginWidth
            BestDistance := NewDistance
        }
    }
    Return Found ? Pos : MouseX
}

GetRightEdge(MouseX, MouseY, CurrentWindow)
{
    Global SnapDistance, ScreenX, ScreenW, MarginWidth
    If (abs(ScreenX + ScreenW - MarginWidth - MouseX) < SnapDistance)
        Return ScreenX + ScreenW - MarginWidth

    WinGetPos, CurrWinX, CurrWinY, CurrWinW, CurrWinH, % "ahk_id" . CurrentWindow
    CurrWinB := CurrWinY + CurrWinH
    Found := 0
    BestDistance := SnapDistance
    WinGet, id, list,,, Program Manager
    Loop, %id%
    {
        If (id%A_Index% = CurrentWindow)
            Continue
        WinGetPos, WinX, WinY, WinW, WinH, % "ahk_id" . id%A_Index%
        If (CurrWinY > WinY + WinH + SnapDistance or CurrWinB + SnapDistance < WinY)
            Continue
        NewDistance := abs(WinX - MarginWidth - MouseX)
        If (NewDistance < BestDistance)
        {
            Found := 1
            Pos := WinX - MarginWidth
            BestDistance := NewDistance
        }
        WinRight := WinX + WinW
        NewDistance := abs(WinRight  - MouseX)
        If (NewDistance < BestDistance)
        {
            Found := 1
            Pos := WinRight
            BestDistance := NewDistance
        }
    }
    Return Found ? Pos : MouseX
}

GetTopEdge(MouseX, MouseY, CurrentWindow)
{
    Global SnapDistance, ScreenY, MarginWidth
    If (abs(ScreenY + MarginWidth - MouseY) < SnapDistance)
        Return ScreenY + MarginWidth

    WinGetPos, CurrWinX, CurrWinY, CurrWinW, CurrWinH, % "ahk_id" . CurrentWindow
    CurrWinR := CurrWinX + CurrWinW
    Found := 0
    BestDistance := SnapDistance
    WinGet, id, list,,, Program Manager
    Loop, %id%
    {
        If (id%A_Index% = CurrentWindow)
            Continue
        WinGetPos, WinX, WinY, WinW, WinH, % "ahk_id" . id%A_Index%
        If (CurrWinX > WinX + WinW + SnapDistance or CurrWinR + SnapDistance < WinX)
            Continue
        NewDistance := abs(WinY - MouseY)
        If (NewDistance < BestDistance)
        {
            Found := 1
            Pos := WinY
            BestDistance := NewDistance
        }
        WinBottom := WinY + WinH
        NewDistance := abs(WinBottom + MarginWidth - MouseY)
        If (NewDistance < BestDistance)
        {
            Found := 1
            Pos := WinBottom + MarginWidth
            BestDistance := NewDistance
        }
    }
    Return Found ? Pos : MouseY
}

GetBottomEdge(MouseX, MouseY, CurrentWindow)
{
    Global SnapDistance, ScreenY, ScreenH, MarginWidth
    If (abs(ScreenY + ScreenH - MarginWidth - MouseY) < SnapDistance)
        Return ScreenY + ScreenH - MarginWidth

    WinGetPos, CurrWinX, CurrWinY, CurrWinW, CurrWinH, % "ahk_id" . CurrentWindow
    CurrWinR := CurrWinX + CurrWinW
    Found := 0
    BestDistance := SnapDistance
    WinGet, id, list,,, Program Manager
    Loop, %id%
    {
        If (id%A_Index% = CurrentWindow)
            Continue
        WinGetPos, WinX, WinY, WinW, WinH, % "ahk_id" . id%A_Index%
        If (CurrWinX > WinX + WinW + SnapDistance or CurrWinR + SnapDistance < WinX)
            Continue
        NewDistance := abs(WinY - MarginWidth - MouseY)
        If (NewDistance < BestDistance)
        {
            Found := 1
            Pos := WinY - MarginWidth
            BestDistance := NewDistance
        }
        WinBottom := WinY + WinH
        NewDistance := abs(WinBottom  - MouseY)
        If (NewDistance < BestDistance)
        {
            Found := 1
            Pos := WinBottom
            BestDistance := NewDistance
        }
    }
    Return Found ? Pos : MouseY
}

GetBestTile(MouseX0, MouseY0)
{
    Global Left, Right, Top, Bottom
    Left := GetLeftLine(MouseX0, MouseY0, 1)
    Right := GetRightLine(MouseX0, MouseY0, 1)
    Top := GetTopLine(MouseX0, MouseY0, 1)
    Bottom := GetBottomLine(MouseX0, MouseY0, 1)

    If (Left and Right and Top and Bottom)
        Return 1
    Else
        Return 0
}

GetSmallestTile(MouseX0, MouseY0, MouseX1="", MouseY1="")
{
    If (!MouseX1)
    {
        MouseX1 := MouseX0, MouseY1 := MouseY0
    }
    Else
    {
        ; Flip the positions if X0 > X1
        If (MouseX0 > MouseX1)
        {
            Temp := MouseX0
            MouseX0 := MouseX1
            MouseX1 := Temp
            Temp := MouseY0
            MouseY0 := MouseY1
            MouseY1 := Temp
        }
        ; Determine if Y is decreasing (1) or increasing (0)
        Inverted := 0
        If (MouseY0 > MouseY1)
        {
            Inverted = 1
        }
    }

    Global Left, Right, Top, Bottom
    Left := GetLeftLine(MouseX0, MouseY0)
    Right := GetRightLine(MouseX1, MouseY1)
    Top := GetTopLine(Inverted ? MouseX1 : MouseX0, Inverted ? MouseY1 : MouseY0)
    Bottom := GetBottomLine(Inverted ? MouseX0 : MouseX1, Inverted ? MouseY0 : MouseY1)

    If (Left and Right and Top and Bottom)
        Return 1
    Else
        Return 0
}

GetNearbyLine(type, MouseX, MouseY, distance = 0, Best = 0)
{
    Global
    distance := distance ? distance : SnapDistance
    If (type = "V")
    {
        Loop % V.MaxIndex()
        {
            X := GetLinePos("V", A_Index)
            If (Best and Resize)
                Continue
            If (MouseY >= Y0 and MouseY <= Y1)
            {
                If (abs(MouseX - X) <= distance)
                {
                    Return A_Index
                }
            }
        }
    }
    Else
    {
        Loop % H.MaxIndex()
        {
            Y := GetLinePos("H", A_Index)
            If (Best and Resize)
                Continue
            If (MouseX >= X0 and MouseX <= X1)
            {
                If (abs(MouseY - Y) <= distance)
                {
                    Return A_Index
                }
            }
        }
    }
}

; 0 1 2
; 3 4 5
; 6 7 8
GetOctant(X, Y, WinX, WinY, WinW, WinH)
{
    ScaledX := (X - WinX) * 3 // WinW
    ScaledY := (Y - WinY) * 3 // WinH
    Return ScaledX + ScaledY * 3
}

MoveWindowRelative(Title, X=0, Y=0, W=0, H=0)
{
    WinGetPos, WinX, WinY, WinW, WinH, % Title
    WinMove, % Title,, % WinX + X, % WinY + Y, % WinW + W, % WinH + H
}

MoveWindowToTile(Title, Left, Right, Top, Bottom)
{
    Global
    If (Exceptions and Left = 4 and Right = 7 and Top = 1 and Bottom = 5)
    {
        Local X := V[Left][1]
        Local Y := H[Top][1]
        WinMove, % Title,
            , % X
            , % Y
            , % V[Right][1] - X - MarginWidthHalf
            , % H[Bottom][1] - Y - 2
    }
    Else
    {
        Local X := V[Left][1] + (V[Left][4] ? MarginWidth : MarginWidthHalf)
        Local Y := H[Top][1] + (H[Top][4] ? MarginWidth : MarginWidthHalf)
        WinMove, % Title,
            , % X
            , % Y
            , % V[Right][1] - X - (V[Right][4] ? MarginWidth : MarginWidthHalf)
            , % H[Bottom][1] - Y  - (H[Bottom][4] ? MarginWidth : MarginWidthHalf)
    }
}

CreateGrid()
{
    Global
    If (!UseGrid)
        Return
    Local LineWidth := MarginWidth = 0 ? 2 : MarginWidth
    Gui, Color, % GridColor
    Gui, +LastFound
    WinSet, TransColor, 000000
    WinSet, Transparent, 64
    Gui, +Owner +AlwaysOnTop -Resize -SysMenu -MinimizeBox -MaximizeBox -Disabled -Caption -Border -ToolWindow 
    Loop, % V.MaxIndex()
    {
        Local X := GetLinePos("V", A_Index) - ScreenX   ; to convert the position to positive
        Local Y := Y0 - ScreenY                         ; to convert the position to positive
        Local Height := Y1 - Y0
        If (Corner)
            Gui, Add, Picture, % "x" . X-LineWidth . " y" . Y . " w" . LineWidth*2 . " h" . Height, 000000.png
        Else
            Gui, Add, Picture, % "x" . X-LineWidth//2 . " y" . Y . " w" . LineWidth . " h" . Height, 000000.png
    }
    Loop, % H.MaxIndex()
    {
        Local Y := GetLinePos("H", A_Index) - ScreenY   ; to convert the position to positive
        Local X := X0 - ScreenX                         ; to convert the position to positive
        Local Width := X1 - X0
        If (Corner)
            Gui, Add, Picture, % "x" . X . " y" . Y-LineWidth . " w" . Width . " h" . LineWidth*2, 000000.png
        Else
            Gui, Add, Picture, % "x" . X . " y" . Y-LineWidth//2 . " w" . Width . " h" . LineWidth, 000000.png
    }
}

ShowGrid()
{
    Global UseGrid
    If (!UseGrid)
        Return
    Global ScreenX, ScreenY, ScreenW, ScreenH
    Gui, Show, % "x" . ScreenX . " y" . ScreenY . " w" . ScreenW . " h" . ScreenH
}

HideGrid()
{
    Global UseGrid
    If (!UseGrid)
        Return
    Gui, Hide
}

; Move Window (Pixel Perfect)
; [Shift [Contro]] RAlt + Up/Down/Left/Right
>!Up::MoveWindowRelative("A", 0, -1),Return
>!Down::MoveWindowRelative("A", 0, 1),Return
>!Left::MoveWindowRelative("A", -1, 0),Return
>!Right::MoveWindowRelative("A", 1, 0),Return
+>!Up::MoveWindowRelative("A", 0, -1, 0, 1),Return
+>!Down::MoveWindowRelative("A", 0, 0, 0, 1),Return
+>!Left::MoveWindowRelative("A", -1, 0, 1, 0),Return
+>!Right::MoveWindowRelative("A", 0, 0, 1, 0),Return
^+>!Up::MoveWindowRelative("A", 0, 0, 0, -1),Return
^+>!Down::MoveWindowRelative("A", 0, 1, 0, -1),Return
^+>!Left::MoveWindowRelative("A", 0, 0, -1, 0),Return
^+>!Right::MoveWindowRelative("A", 1, 0, -1, 0),Return

; Move Window


>!RButton::
    MouseGetPos, X, Y, WinId
    OrigX := X, OrigY := Y

    ; Don't do anything until button is released OR mouse moves
    While 1
    {
        Sleep, 10
        MouseGetPos, X, Y
        If (abs(OrigX - X) > MinimumMovement or abs(OrigY - Y) > MinimumMovement)
        {
            Break
        }
        If (!GetKeyState("RButton", "P"))
        {
            Return
        }
    }

    WinTitle := "ahk_id " . WinId
    WinGet, MinMax, MinMax, % WinTitle
    If (MinMax = 1)
        WinRestore, % WinTitle
    WinGetPos, WinX, WinY, WinW, WinH, % WinTitle
    Octant := GetOctant(X, Y, WinX, WinY, WinW, WinH)

    WinSet, AlwaysOnTop, On, % WinTitle
    WinSet, Transparent, 212, % WinTitle
    ShowGrid()

    MultipleTiles := 0
    Snap := 0
    While (GetKeyState("RButton", "P"))
    {
        MouseGetPos, MouseX, MouseY
        If (!MultipleTiles)
        {
            If (Octant = 4)
            {
                If (GetKeyState("LButton", "P"))
                {
                    MultipleTiles := 1
                    Continue
                }
                Else
                {
                    NewX := MouseX - OrigX + WinX
                    NewY := MouseY - OrigY + WinY
                    If (!GetKeyState("Shift", "P"))
                    {
                        NewNewX := GetLeftEdge(NewX, NewY, WinId)
                        If (NewNewX = NewX)
                        {
                            NewNewX := GetRightEdge(NewX + WinW, NewY, WinId) - WinW
                            If (NewNewX = NewX)
                            {
                                NearbyLine := GetNearbyLine("V", NewX, NewY + WinH//2)
                                If (NearbyLine)
                                    NewX := GetLinePos("V", NearbyLine) + (Corner ? MarginWidth : MarginWidthHalf)
                                Else
                                {
                                    NearbyLine := GetNearbyLine("V", NewX + WinW, MouseY - OrigY + WinY + WinH//2)
                                    If (NearbyLine)
                                        NewX := GetLinePos("V", NearbyLine) - (Corner ? MarginWidth : MarginWidthHalf) - WinW
                                }
                            }
                            Else
                                NewX := NewNewX
                        }
                        Else
                            NewX := NewNewX
                        NewNewY := GetTopEdge(NewX, NewY, WinId)
                        If (NewNewY = NewY)
                        {
                            NewNewY := GetBottomEdge(NewX, NewY + WinH, WinId) - WinH
                            If (NewNewY = NewY)
                            {
                                NearbyLine := GetNearbyLine("H", NewX + WinW//2, NewY)
                                If (NearbyLine)
                                    NewY := GetLinePos("H", NearbyLine) + (Corner ? MarginWidth : MarginWidthHalf)
                                Else
                                {
                                    NearbyLine := GetNearbyLine("H", NewX + WinW//2, NewY + WinH)
                                    If (NearbyLine)
                                        NewY := GetLinePos("H", NearbyLine) - (Corner ? MarginWidth : MarginWidthHalf) - WinH
                                }
                            }
                            Else
                                NewY := NewNewY
                        }
                        Else
                            NewY := NewNewY
                    }
                    WinMove, % WinTitle,, % NewX, % NewY
                }
            }
            Else
            {
                If (mod(Octant, 3) = 0)
                {
                    If (GetKeyState("LButton", "P") or Snap)
                    {
                        Snap := 1
                        Edge := GetLeftLine(MouseX, MouseY)
                        If (Edge)
                        {
                            LinePos := GetLinePos("V", Edge)
                            NewX := LinePos + (Corner ? MarginWidth : MarginWidthHalf)
                            WinMove, % WinTitle,, % NewX,, % WinX - NewX + WinW
                        }
                    }
                    Else
                    {
                        NewX := MouseX - OrigX + WinX
                        If (!GetKeyState("Shift", "P"))
                        {
                            NewNewX := GetLeftEdge(NewX, MouseY, WinId)
                            If (NewNewX = NewX)
                            {
                                NearbyLine := GetNearbyLine("V", NewX - (Corner ? MarginWidth : MarginWidthHalf), MouseY)
                                If (NearbyLine)
                                    NewX := GetLinePos("V", NearbyLine) + (Corner ? MarginWidth : MarginWidthHalf)
                            }
                            Else
                                NewX := NewNewX
                        }
                        WinMove, % WinTitle,, % NewX,, % WinX - NewX + WinW
                    }
                }
                Else If (mod(Octant, 3) = 2)
                {
                    If (GetKeyState("LButton", "P") or Snap)
                    {
                        Snap := 1
                        Edge := GetRightLine(MouseX, MouseY)
                        If (Edge)
                        {
                            LinePos := GetLinePos("V", Edge)
                            NewX := LinePos - (Corner ? MarginWidth : MarginWidthHalf)
                            WinMove, % WinTitle,,,, % NewX - WinX
                        }
                    }
                    Else
                    {
                        NewW := MouseX - OrigX + WinW
                        If (!GetKeyState("Shift", "P"))
                        {
                            NewNewW := GetRightEdge(WinX + NewW, MouseY, WinId) - WinX
                            If (NewNewW = NewW)
                            {
                                NearbyLine := GetNearbyLine("V", NewW + WinX + (Corner ? MarginWidth : MarginWidthHalf), MouseY)
                                If (NearbyLine)
                                    NewW := GetLinePos("V", NearbyLine) - (Corner ? MarginWidth : MarginWidthHalf) - WinX
                            }
                            Else
                                NewW := NewNewW
                        }
                        WinMove, % WinTitle,,,, % NewW
                    }
                }
                If (Octant // 3 = 0)
                {
                    If (GetKeyState("LButton", "P") or Snap)
                    {
                        Snap := 1
                        Edge := GetTopLine(MouseX, MouseY)
                        If (Edge)
                        {
                            LinePos := GetLinePos("H", Edge)
                            NewY := LinePos + (Corner ? MarginWidth : MarginWidthHalf)
                            WinMove, % WinTitle,,, % NewY,, % WinY - NewY + WinH
                        }
                    }
                    Else
                    {
                        NewY := MouseY - OrigY + WinY
                        If (!GetKeyState("Shift", "P"))
                        {
                            NewNewY := GetTopEdge(NewX, MouseY, WinId)
                            If (NewNewY = NewY)
                            {
                                NearbyLine := GetNearbyLine("H", MouseX, NewY - (Corner ? MarginWidth : MarginWidthHalf))
                                If (NearbyLine)
                                    NewY := GetLinePos("H", NearbyLine) + (Corner ? MarginWidth : MarginWidthHalf)
                            }
                            Else
                                NewY := NewNewY
                        }
                        WinMove, % WinTitle,,, % NewY,, % WinY - NewY + WinH
                    }
                }
                Else If (Octant // 3 = 2)
                {
                    If (GetKeyState("LButton", "P") or Snap)
                    {
                        Snap := 1
                        Edge := GetBottomLine(MouseX, MouseY)
                        If (Edge)
                        {
                            LinePos := GetLinePos("H", Edge)
                            NewY := LinePos - (Corner ? MarginWidth : MarginWidthHalf)
                            WinMove, % WinTitle,,,,, % NewY - WinY
                        }
                    }
                    Else
                    {
                        NewH := MouseY - OrigY + WinH
                        If (!GetKeyState("Shift", "P"))
                        {
                            NewNewH := GetBottomEdge(MouseX, WinY + NewH, WinId) - WinY
                            If (NewNewH = NewH)
                            {
                                NearbyLine := GetNearbyLine("H", MouseX, NewH + WinY + (Corner ? MarginWidth : MarginWidthHalf))
                                If (NearbyLine)
                                    NewH := GetLinePos("H", NearbyLine) - (Corner ? MarginWidth : MarginWidthHalf) - WinY
                            }
                            Else
                                NewH := NewNewH
                        }
                        WinMove, % WinTitle,,,,, % NewH
                    }
                }
            }
        }
        Else
        {
            If (GetKeyState("LButton", "P"))
            {
                MouseGetPos, MouseX0, MouseY0
                While (GetKeyState("LButton", "P"))
                {
                    MouseGetPos, MouseX1, MouseY1
                    If (GetSmallestTile(MouseX0, MouseY0, MouseX1, MouseY1))
                    {
                        MoveWindowToTile(WinTitle, Left, Right, Top, Bottom)
                    }
                }
            }
        }
        Sleep, 10
    }

    WinSet, AlwaysOnTop, Off, % WinTitle
    WinSet, Transparent, Off, % WinTitle
    WinActivate, % WinTitle
    HideGrid()
Return