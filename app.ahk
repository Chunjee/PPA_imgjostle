#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

;ATTENTION requires FFmpeg, FFplay, and ImageMagick

IM := A_ScriptDir "\assets\ImageMagickconvert.exe"
FFmpeg := A_ScriptDir "\assets\ffmpeg.exe"
FFplay := A_ScriptDir "\assets\ffplay.exe"

Gui, Color, DDCEE9
Gui, Add, Button, x40 y121 w50 h23 gSelectImage, Input File
Gui Add, Text, x16 y6 w67 h31, % "Background          Color"
Gui Add, Edit, x16 y32 w67 h21 +Center vBackgroundColor, Transparent
Gui Add, Edit, x123 y31 w50 h21 vIterAmount +Center, 6
Gui Add, Text, x126 y5 w44 h26, % "  Frame     Amount"
Gui Add, Text, x24 y66 w52 h14, Spread - X
Gui Add, Text, x124 y66 w56 h14, Spread - Y
Gui Add, Edit, x24 y80 w50 h21 vSpreadX +Center, 3
Gui Add, Edit, x124 y80 w50 h21 vSpreadY +Center, 3
Gui, Add, Button,x111 y120 w50 h24 gLoopIt, Shake it!
Gui Show, w200 h150, % "       Image Shaker/Vibrator - v1.2"
Gui, -sysmenu
Return


SelectImage:
FileSelectFile, InputFile
sleep, 10
InputFile := chr(0x22) . InputFile . chr(0x22)
Return


LoopIt:
gosub, CloseGifMenu
Gui, Submit, NoHide
FileRemoveDir, %FrameDir%, 1
sleep, 10
FrameDir := A_ScriptDir . "\FRAMES"
FileCreateDir, %FrameDir%
sleep, 10
ViewAll := ComSpec . " /c " . " ffplay -i " . FrameDir . "\frame_%04d.png -loop 0"


kms := 0
while kms < IterAmount
{
	kms +=1 ;loop counter
	
	fileVal +=1
	Pack := "0000"
	zeropad := (SubStr(Pack, 1, StrLen(Pack) - StrLen(fileVal)) . fileVal) ;ZeroPadding for filenames
	
	;ViewIt := ComSpec . " /c " . " ffplay -i " . FrameDir . "\frame_" . zeropad . ".png"
	
	gosub, CommenceShakening
	if (A_Index = IterAmount) { ;Stop loop after IterAmount is reached.
		msgbox, done!
		runwait, %ViewAll%
		;WinWaitClose, cmd.exe
		;sleep, 50
		;FileDelete, frame_*.png
		
		fileVal := "" ;clear val
		zeropad := "" ;clear val
		kms := "" ;clear val
		
		gosub, FFGIFMenu
		
		Return
	}
}
Return



CommenceShakening:
Gui, Submit, NoHide
k += 1
m := Mod(k, 4)
s := Floor(m) 

sleep, 10
cus_presets := ["+" . SpreadX . "+" . SpreadY
                , "+" . SpreadX . "-" . SpreadY
                , "-" . SpreadX . "-" . SpreadY
			 , "-" . SpreadX . "+" . SpreadY]

CustomPreset := cus_presets[s+1]

ShakeCommand := " -page " . CustomPreset .  " -background " . BackgroundColor . " -flatten "
IMCommand := ComSpec . " /c " . IM . " -verbose " . InputFile . " " . ShakeCommand . " " . FrameDir . "\frame_" . zeropad ".png"

;msgbox, %IMCommand%
;IMOutput := ComObjCreate("WScript.Shell").Exec(IMCommand).StdOut.ReadAll()
runwait, %IMCommand%
Return

FFGIFMenu:
Gui Gif2:Destroy
Gui Gif:Color, DDCEE9
Gui Gif:Add, Button, x32 y106 w80 h23 gFFCreateGIF, Create GIF
Gui Gif:Add, Button, x32 y132 w80 h23 gFFCreateAVI, Create AVI
Gui Gif:Add, Edit, x51 y34 w43 h21 vFPS, 60
Gui Gif:Add, CheckBox, x7 y68 w130 h33 vLoopItPls, Loop Forever? (Press Q   to stop compression.)
Gui Gif:Add, Text, x27 y11 w92 h23 +0x200, Output Frame Rate
Gui Gif:Add, Button, x127 y0 w22 h20 gCloseGifMenu, X
Gui Gif:Add, Button, x0 y0 w22 h20 gIMGifMenu, IM
Gui Gif:Show, w150 h162, FFmpeg GIF
Gui Gif:-sysmenu
Return

;This is what I use so I can Datamosh the vibrating image.
FFCreateAVI:
GuiControlGet, LoopItPls
if (LoopItPls = 1) {
	LoopForever := "-loop 1"
}

if (LoopItPls = 0) {
	LoopForever := ""
}

GuiControlGet, FPS
FFCommand := ComSpec . " /c " . FFmpeg . " " . LoopForever . " -r " . FPS . " -i " . FrameDir . "\frame_%04d.png -r " . FPS . " -f avi -c:v huffyuv " . FrameDir . "\output.avi -y"
ViewGIF := ComSpec . " /c " . FFplay . " -i " . FrameDir . "\output.avi -loop 0"

runwait, %FFCommand%
runwait, %ViewGIF%
Return

FFCreateGIF:
GuiControlGet, LoopItPls
if (LoopItPls = 1) {
	LoopForever := "-loop 1"
}

if (LoopItPls = 0) {
	LoopForever := ""
}

GuiControlGet, FPS
;IMCommand := ComSpec . " /k " . IM . " " . "-delay 39x1000 -dispose previous " . FrameDir . "\frame_*.png -background purple -alpha remove -alpha off -loop 0 output.gif"


FFCommand := ComSpec . " /c " . FFmpeg . " " . LoopForever . " -r " . FPS . " -i " . FrameDir . "\frame_%04d.png -r " . FPS . " " . FrameDir . "\output.gif -y"
ViewGIF := ComSpec . " /c " . FFplay . " -i " . FrameDir . "\output.gif -loop 0"

runwait, %FFCommand%
runwait, %ViewGIF%
Return



IMGifMenu:
Gui Gif:Destroy
Gui Gif2:Color, DDCEE9
Gui Gif2:Add, Button, x32 y106 w80 h23 gIMCreateGIF, Create GIF
Gui Gif2:Add, Edit, x29 y34 w90 h21 vDelayAmount +Center, 39x1000
Gui Gif2:Add, CheckBox, x7 y68 w130 h33 vLoopItPls, Loop Forever? (Press Q   to stop compression.)
Gui Gif2:Add, Text, x27 y11 w92 h23 +0x200, Output Delay Rate
Gui Gif2:Add, Button, x127 y0 w22 h20 gCloseGifMenu, X
Gui Gif2:Add, Button, x0 y0 w22 h20 gFFGifMenu, FF
Gui Gif2:Show, w150 h147, ImageMagick GIF
Gui Gif2:-sysmenu
GuiControl, Gif2:Disable, LoopItPls
Return

IMCreateGIF:
Gui Gif2:Submit, NoHide
;GuiControlGet, LoopItPls
;if (LoopItPls = 1) {
;	LoopForever := "-loop 1"
;}

;if (LoopItPls = 0) {
;	LoopForever := ""
;}

ShaveX := (SpreadX * 2 + 5)
ShaveY := (SpreadY * 2 + 5)


ShaveAmount := " +repage -shave " . ShaveX . " " ShaveY
;Trims empty edges, +repage needed to fill in transparent spaces.

IMCommand := ComSpec . " /c " . IM . " " . LoopForever . " -verbose -delay " . DelayAmount . " -dispose previous " . FrameDir . "\frame_*.png -channel rgba -alpha on -background black -loop 0 " . ShaveAmount . " " . FrameDir . "\output.gif"
ViewGIF := ComSpec . " /c " . FFplay . " -i " . FrameDir . "\output.gif -loop 0"

runwait, %IMCommand%
runwait, %ViewGIF%
Return

CloseGifMenu:
if(WinExist("FFmpeg GIF")) {
	Gui, Gif:Destroy
}

if(WinExist("ImageMagick GIF")) {
	Gui, Gif2:Destroy
}
Return

GuiEscape:
GuiClose:
ExitApp
