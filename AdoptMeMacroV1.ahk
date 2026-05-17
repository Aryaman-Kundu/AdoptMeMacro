#Requires AutoHotkey v2.0
#SingleInstance Force

; Version 1.0 - Initial Relase 

class Variables {
    static CurrentTasks := ["None", "None", "None", "None", "None"]
    static ActiveTask := ""
    static TaskAreas := [
        {X: 650, Y: 680},
        {X: 650, Y: 320},
        {X: 970, Y: 125},
        {X: 1270, Y: 320},
        {X: 1260, Y: 680}
    ]
    static CurrentTries := 0
    static Aligned := false
    static Running := false
}

class GeneralFunctions {
    static ActivateRoblox() {
        if WinExist("Roblox") {
            WinActivate("Roblox")
            WinWaitActive("Roblox", , 3)
        } else {
            MsgBox("Roblox window not found!")
        }
    }

    static HoldKey(Key, Time := 100) {
        Send("{" Key " down}")
        Sleep(Time)
        Send("{" Key " up}")
    }

    static MoveMouse(X, Y, Speed := 0.25) {
        MouseMove(X + 3, Y + 3, 0.1)
        Sleep(10)
        MouseMove(X, Y, Speed)
    }

    static CheckWhite(X, Y) {
        return (PixelGetColor(X, Y) == 0xFFFFFF)
    }

    static SafeClick(X, Y, Delay := 500) {
        GeneralFunctions.MoveMouse(X, Y, 0.25)
        Sleep(200)
        MouseClick("left")
        Sleep(Delay)
    }
}

class RobloxFunctions {
    static ResetCharacter() {
        GeneralFunctions.HoldKey("esc")
        Sleep(300)
        GeneralFunctions.HoldKey("r")
        Sleep(300)
        GeneralFunctions.HoldKey("Enter")
        Sleep(3000)
        Variables.Aligned := false 
    }
}

class MovementFunctions {
    static ExitHouse() {
        GeneralFunctions.HoldKey("s", 500)
        GeneralFunctions.HoldKey("e")
        Sleep(3000)
    }

    static EnterMainWorld() {
        RobloxFunctions.ResetCharacter()
        MovementFunctions.ExitHouse()
        GeneralFunctions.HoldKey("w", 500)
        GeneralFunctions.HoldKey("w", 1050)
        GeneralFunctions.HoldKey("a", 4700)
        GeneralFunctions.HoldKey("w", 5600)
        GeneralFunctions.HoldKey("a", 2800)

        ; Wait until loading screen clears
        timeout := A_TickCount + 15000
        while (GeneralFunctions.CheckWhite(900, 500) && A_TickCount < timeout) {
            Sleep(50)
        }

        GeneralFunctions.HoldKey("a", 2500)
        GeneralFunctions.HoldKey("w", 2500)
        GeneralFunctions.HoldKey("s", 1000)
        GeneralFunctions.HoldKey("d", 1000)
    }
}

class TaskFunctions {
    ; BUG FIX: moved else inside loop so it correctly returns 0 when no image found
    static SearchTask() {
        GeneralFunctions.ActivateRoblox()
        loop files "Icons\Tasks\*.png" {
            if (ImageSearch(&FoundX, &FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, "*50 " A_LoopFileFullPath)) {
                return A_LoopFileFullPath
            }
        }
        return 0  ; No match found
    }

    static OpenTaskMenu() {
        Variables.CurrentTries := 0
        ; Wait until the task button is visible (not white = UI loaded)
        while (GeneralFunctions.CheckWhite(1750, 70)) {
            GeneralFunctions.SafeClick(1100, 730)
            Variables.CurrentTries++
            if (Variables.CurrentTries > 5) {
                RobloxFunctions.ResetCharacter()
                Variables.CurrentTries := 0
            }
        }
    }

    static CheckTasks() {
        TaskFunctions.ResetTasks()
        for index, area in Variables.TaskAreas {
            GeneralFunctions.MoveMouse(area.X, area.Y, 0.25)
            Sleep(150)
            Task := TaskFunctions.SearchTask()
            if (Task != 0) {
                ; BUG FIX: correct regex — extract filename without path or extension
                SplitPath(Task, &fileName)
                CleanName := RegExReplace(fileName, "\.[^.]+$", "")  ; strip extension
                Variables.CurrentTasks[index] := CleanName
            } else {
                Variables.CurrentTasks[index] := "None"
            }
        }
        ; Close task menu after scanning
        GeneralFunctions.SafeClick(550, 100)
    }

    static ResetTasks() {
        Variables.CurrentTasks := ["None", "None", "None", "None", "None"]
    }

    static HasPendingTasks() {
        for index, task in Variables.CurrentTasks {
            if (task != "None") {
                return true
            }
        }
        return false
    }
}

class Tasks {
    static Align() {
        RobloxFunctions.ResetCharacter()
        GeneralFunctions.HoldKey("w", 500)
        Sleep(200)
        GeneralFunctions.HoldKey("e")
        Sleep(200)
        GeneralFunctions.HoldKey("1")
        Sleep(500)
        Variables.Aligned := true
    }


    static TaskSleep() {
        if (!Variables.Aligned) {
            Tasks.Align()
        }
        GeneralFunctions.SafeClick(961, 428, 10000)
    }

    static TaskEat() {
        if (!Variables.Aligned) {
            Tasks.Align()
        }
        GeneralFunctions.SafeClick(711, 453, 10000)
    }

    static TaskDrink() {
        if (!Variables.Aligned) {
            Tasks.Align()
        }
        GeneralFunctions.SafeClick(820, 453, 10000)
    }

    static TaskBath() {
        if (!Variables.Aligned) {
            Tasks.Align()
        }
        GeneralFunctions.SafeClick(1094, 428, 10000)
    }

    static TaskChoose() {
        TaskFunctions.OpenTaskMenu()
        GeneralFunctions.SafeClick(Variables.TaskAreas[1].X, Variables.TaskAreas[1].Y, 0.25)
        GeneralFunctions.SafeClick(969,496, 0.25)
    }

    static TaskPet() {
        index := 1
        TaskFunctions.OpenTaskMenu()
        GeneralFunctions.SafeClick(900, 500)
        SetDefaultMouseSpeed(100)
        MouseClick("Left",,,,,"D")
        while (index <= 15) {
            
            MouseMove(900, 300, 100)
            Sleep(500)
            MouseMove(900, 500, 100)
            Sleep(250)
            index++
        }
        ToolTip("Finished petting!")
        MouseClick("Left",,,,,"U")
        GeneralFunctions.SafeClick(550, 100)  
    }

    ; WIP
    static TaskPlay() {
        GeneralFunctions.SafeClick(950, 930)
        GeneralFunctions.SafeClick(1046, 570)
        GeneralFunctions.SafeClick(752, 770)
        Send("Squeaky Bone")
        GeneralFunctions.SafeClick(973, 630)
        GeneralFunctions.SafeClick(1066, 729)
        GeneralFunctions.SafeClick(1191, 560)

        index := 0
        while (index < 5) {
            GeneralFunctions.SafeClick(1191, 560, 100)
            ; Wait for throw animation to finish
            timeout := A_TickCount + 5000
            while (GeneralFunctions.CheckWhite(1015, 965) && A_TickCount < timeout) {
                Sleep(10)
            }
            Sleep(300)
            index++  ; BUG FIX: was missing, caused infinite loop
        }
        GeneralFunctions.SafeClick(1059, 905)
    }

    static ExecuteTask(task) {
        switch task {
            case "Sleepy":  Tasks.TaskSleep()
            case "Hungry":  Tasks.TaskEat()
            case "Thirsty": Tasks.TaskDrink()
            case "Dirty":   Tasks.TaskBath()
            case "Choose":  Tasks.TaskChoose()
            case "PetMe":   Tasks.TaskPet()
            ;[WIP]case "Bored":   Tasks.TaskPlay()
        }
    }

    ; Main autonomous loop
    static AutoTask() {
        GeneralFunctions.ActivateRoblox()
        TaskFunctions.OpenTaskMenu()
        TaskFunctions.CheckTasks()

        if (!TaskFunctions.HasPendingTasks()) {
            ToolTip("No tasks found. Waiting...")
            Sleep(15000)
            ToolTip()
            return
        }

        for index, task in Variables.CurrentTasks {
            if (!Variables.Running) {
                break
            }
            if (task == "None") {
                continue
            }
            ToolTip("Doing task " index ": " task)
            Tasks.ExecuteTask(task)
            Sleep(500)
        }

        ToolTip()
        Variables.Aligned := false
        TaskFunctions.ResetTasks()
    }
}

; ── Hotkeys ──────────────────────────────────────────────────────────────────

F1:: {  ; Start autonomous loop
    if (Variables.Running) {
        return
    }
    Variables.Running := true
    ToolTip("Bot started — F2 to stop")
    Sleep(1000)
    while (Variables.Running) {
        Tasks.AutoTask()
        Sleep(2000)  ; brief pause between full cycles
    }
}

F2:: {  ; Stop bot
    Variables.Running := false
    ToolTip("Bot stopped.")
    Sleep(2000)
    ToolTip()
}

F3:: ExitApp
