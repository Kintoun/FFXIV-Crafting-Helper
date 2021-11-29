;;;;;;;; Instructions ;;;;;;;
; HOW TO USE:
; If ahk file association is setup, double click this script to launch it
; Control + F12 to open UI.
; Select an item from the dropdown and click one of the buttons to start the script
; PREREQUESITES:
; The script expects that you have your in-game crafting UI open (hotkey N) with the desired item selected
; If using HQ, ALWAYS ensure your in-game "active selection" is an item in the crafting list area

; Incredibly useful tool for determing rotations/macros/durations - https://ffxivteamcraft.com/simulator

; Actions:
; Do Once - Executes dropdown item once then stops.
; Repeat - Executes dropdown item inifitely.
; Pause - Pauses execution of the dropdown item. Click again to resume.
; Stop - Stops execution of the dropdown item.
; Run Simulation - Do Once in simulation mode. Will display commands in message box. If notepad is running commands will be sent there

; FAQ:
; Help I selected HQ mats and the craft won't start!
;	See above. The script expects your in-game "active selection" to start in the crafting list area NOT the actual craft where material selection is done.
;	Simply left click in-game on the craft list area then try again

; TODO:
; Find a way to navigate even if user selected HQ mats

#Include JSON.ahk

;;;;;;;;;; Hotkeys ;;;;;;;;;;
^F12::
#MaxThreadsPerHotkey 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;; Globals ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ProcessName := "ffxiv_dx11.exe"
Simulation := false ; no need to set here, controlled via UI

class Action
{
	hotkey := ""
	duration := 0
	
	__New(h, d)
	{
		this.hotkey := h
		this.duration := d * 1000
	}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; Crafts ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Example Json format
TestRawJson =
(
{
	"3.5* 70D": {
		"macros": [
			{
				"hotkey": "7",
				"duration": 39
			},
			{
				"hotkey": "8",
				"duration": 11
			}
		]
	},
}
)
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; Main ;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; If we're already running, then hotkey again means STOP
if KeepRunning
{
	SignalStop()
    return
}
KeepRunning := true
Running := false
ShowDialog()

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;; Functions ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LoadCrafts()
{
	global

	if Running
	{
		MsgBox % "Unable to Reload JSON while running!"
		return
	}

	Fileread, rawJSON, crafts.json
	if ErrorLevel
	{
		MsgBox % "'crafts.json' file not found!"
		return
	}

	Crafts := JSON.Load(rawJSON)

	craftables := ""
	for k, v in Crafts
		craftables .= k "|"

	GuiControl,, CraftChoice, |%craftables%
}

ShowDialog()
{	
	global

	LoadCrafts()
	
	Gui, Margin, 4, 7
	Gui, Add, Text, xm ym w0 h0 section, dummy ; dummy element to enable finer pos control of next element
	Gui, Add, Text, ys+3, Recipe:
	Gui, Add, DropDownList, ys w150 vCraftChoice, %craftables%
	Gui, Add, Text, ys+3, Iterations:
	Gui, Add, Edit, ys w50
	Gui, Add, UpDown, vIterSpinner Range0-999, 0
	Gui, Add, Button, default xm section, Craft
	Gui, Add, Button, ys, Pause
	Gui, Add, Button, ys, Stop
	Gui, Add, Button, ys, Run Simulation
	Gui, Add, Button, ys, Reload Crafts
	Gui, Add, Text, xm section w200 vStatusText, Status: Idle
	;Gui, Add, Progress, ys w100 h10 cBlue vProgressBar, 10
	
	Gui, Show,, Crafting Helper
	return
	
	ButtonOK:
	ButtonCraft:
	Gui, Submit, NoHide
	Run(CraftChoice, IterSpinner)
	return
	
	ButtonReloadCrafts:
	Gui, Submit, NoHide
	LoadCrafts()
	GuiControl,, StatusText, Status: Crafts Reloaded
	return

	ButtonRunSimulation:
	Gui, Submit, NoHide
	Run(CraftChoice, IterSpinner, true)
	return
	
	ButtonPause:
	Pause,,1
	return
	
	ButtonStop:
	SignalStop()
	return
	
	GuiClose:
	ExitApp
}

Run(CraftChoice, Iterations, RunSimulation = false)
{
	global

	if not CraftChoice
	{
		MsgBox % "No craft selected from dropdown!"
		return
	}

	Running := true
	KeepRunning := true
	Simulation := RunSimulation

	if (Iterations <= 0)
	{
		GuiControl,,StatusText,Status: Running forever
	}
	
	;if (1)
	if (Simulation)
	{
		; if you're running Notepad.exe hotkeys will be output to it as if it was FFXIV
		ProcessName := "notepad.exe"
	}
	else
	{
		ProcessName := "ffxiv_dx11.exe"
	}
	
	Loop
	{
		; infinite loop at 0, else honor Iterations
		if (Iterations > 0 and A_Index > Iterations)
        	break

		if (Iterations > 0)
		{
			GuiControl,, StatusText, Status: Running %A_Index%/%Iterations%
		}

		DoOnce(CraftChoice)
		
		if Simulation or not KeepRunning
			break
		
		Sleep 7000

		if Simulation or not KeepRunning
			break

		if (Iterations > 0)
		{
			;progress :=  ROUND((A_Index / Iterations) * 100.0)
			;GuiControl,, ProgressBar, progress
		}
	}
	
	Running := false
	KeepRunning := false
	GuiControl,, StatusText, Status: Complete
	Tooltip Done
	Sleep 1000
	Tooltip
	return
}

DoOnce(CraftChoice)
{
	BasicCraft(CraftChoice)

	; Accept for collectable
	; SendToGame("{Numpad0}", 500)
}

BasicCraft(CraftChoice)
{
	global
	
	if (not Simulation)
	{
		StartSynthesis()
		Sleep 1500
	}
	
	Craft := Crafts[CraftChoice].macros
	actionLog := ""
	Loop % Craft.MaxIndex()
	{
		action := new Action(Craft[A_Index].hotkey, Craft[A_Index].duration)
		ExecuteAction(action)
		actionLog .= action.hotkey " <wait." action.duration ">"
	}

	if (Simulation)
	{
		SendToGame("{Enter}", 100) ; newline for Notepad to separate simulations
		MsgBox % "Simulation complete: " actionLog
	}
	
	return
}

StartSynthesis()
{
	; Send "UI confirm" messages to select item and start crafting process
	SendToGame("{Numpad0}", 750)
	SendToGame("{Numpad0}", 1000)
	SendToGame("{Numpad0}", 500)
	SendToGame("{Numpad0}", 500)

	SendToGame("{Numpad0}", 1000)	
}

ExecuteAction(action)
{
	global 
	
	if (Simulation)
	{
		SendToGame(action.hotkey, 100)
	}
	else
	{
		SendToGame(action.hotkey, action.duration)
	}
}

SendToGame(KeyToSend, SleepTime)
{
	global
	; ahk_exe searches by exe name e.g. Task Manager process name
	ControlSend,, %KeyToSend%, ahk_exe %ProcessName%
	Sleep %SleepTime%
}

SignalStop()
{
	global
	
	KeepRunning := false
	GuiControl,, StatusText, Status: Cancelling after this iteration
}