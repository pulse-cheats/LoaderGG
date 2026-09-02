
  --]  ================================================================
 --   ⚔️ STEAL AN EGG - AUTO FARM + PvP EGG STEALER (CLEAN NO-AFK)
--    ================================================================
--]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Waypoints & Config
local GameData = {
    StartSpawn = Vector3.new(535.99, 71.11, -366.34),
    AmbushPoint = Vector3.new(650.00, 71.11, -350.00),

    Plots = {
        ["Plot 1"] = Vector3.new(459.94, 71.11, -429.17),
        ["Plot 2"] = Vector3.new(458.68, 71.11, -481.31),
        ["Plot 3"] = Vector3.new(522.99, 71.11, -489.49),
        ["Plot 4"] = Vector3.new(462.52, 71.11, -364.70),
        ["Plot 5"] = Vector3.new(461.95, 71.11, -301.24),
        ["Plot 6"] = Vector3.new(461.66, 71.11, -241.08),
        ["Plot 7"] = Vector3.new(521.48, 71.11, -242.86),
    },

    Stages = {
        { name = "Stage 1", pos = Vector3.new(595.56, 71.11, -329.72) },
        { name = "Stage 2", pos = Vector3.new(742.04, 71.11, -409.11) },
        { name = "Stage 3", pos = Vector3.new(948.37, 71.11, -325.05) },
        { name = "Stage 4", pos = Vector3.new(1188.19, 71.11, -409.72) },
        { name = "Stage 5", pos = Vector3.new(1491.32, 71.11, -314.87) },
        { name = "Stage 6", pos = Vector3.new(1876.62, 71.11, -398.11) },
        { name = "Stage 7", pos = Vector3.new(2280.25, 71.11, -327.72) },
        { name = "Stage 8", pos = Vector3.new(2816.33, 71.11, -398.40) },
        { name = "Stage 9", pos = Vector3.new(3393.07, 71.11, -324.87) },
        { name = "Stage 10", pos = Vector3.new(4026.32, 71.11, -397.62) },
        { name = "Stage 11", pos = Vector3.new(4797.51, 71.11, -327.99) },
    }
}

local State = {
    CurrentMode = "FARM",
    Running = false,
    SelectedStageIndex = 1,
    SelectedPlotName = "Plot 1",
    Status = "Idle",
    EggsCollected = 0,
    PlayersKilled = 0,
    SprintSpeed = 42,
    ApproachSpeed = 22,
    NormalSpeed = 16
}

-- Character Helpers
local function GetChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetHumanoid()
    local c = GetChar()
    return c and c:WaitForChild("Humanoid", 4)
end

local function GetHRP()
    local c = GetChar()
    return c and c:WaitForChild("HumanoidRootPart", 4)
end

local function SetPlayerSpeed(speed)
    local hum = GetHumanoid()
    if hum then hum.WalkSpeed = speed end
end

-- Tool detection
local function GetBatTool()
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")

    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") then
                local n = string.lower(item.Name)
                if string.find(n, "bat") or string.find(n, "club") or string.find(n, "weapon") then
                    return item
                end
            end
        end
    end

    if backpack then
        local tools = backpack:GetChildren()
        for _, item in ipairs(tools) do
            if item:IsA("Tool") then
                local n = string.lower(item.Name)
                if string.find(n, "bat") or string.find(n, "club") or string.find(n, "weapon") then
                    return item
                end
            end
        end
        if #tools > 0 and tools[1]:IsA("Tool") then
            return tools[1]
        end
    end

    return nil
end

local function EquipBat()
    local hum = GetHumanoid()
    local bat = GetBatTool()
    if hum and bat and bat.Parent ~= LocalPlayer.Character then
        hum:EquipTool(bat)
        task.wait(0.12)
    end
    return bat
end

local function AttackWithBat()
    local bat = EquipBat()
    if bat and bat:IsA("Tool") then
        bat:Activate()
        pcall(function()
            if typeof(firesignal) == "function" then
                firesignal(bat.Activated)
            end
        end)
    end
end

local function GetEggTool()
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")

    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") then
                local n = string.lower(item.Name)
                if string.find(n, "egg") or string.find(n, "dragon") or string.find(n, "pet") then
                    return item
                end
            end
        end
    end

    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                local n = string.lower(item.Name)
                if string.find(n, "egg") or string.find(n, "dragon") or string.find(n, "pet") then
                    return item
                end
            end
        end
    end

    return nil
end

-- Pathing Walk with Anti-Stuck & Dynamic Jump
local function SafeWalkTo(targetPos, threshold, timeout, speed)
    threshold = threshold or 4.0
    timeout = timeout or 15
    local hum = GetHumanoid()
    local hrp = GetHRP()
    if not hum or not hrp then return false end

    if speed then hum.WalkSpeed = speed end

    local stuckTimer = 0
    local elapsed = 0
    local lastPos = hrp.Position

    while State.Running and elapsed < timeout do
        if not hum or not hrp or hum.Health <= 0 then break end
        local currentPos = hrp.Position
        local dist = (Vector3.new(currentPos.X, 0, currentPos.Z) - Vector3.new(targetPos.X, 0, targetPos.Z)).Magnitude

        if dist <= threshold then return true end

        hum:MoveTo(targetPos)
        task.wait(0.1)
        elapsed = elapsed + 0.1

        if (hrp.Position - lastPos).Magnitude < 0.35 then
            stuckTimer = stuckTimer + 0.1
            if stuckTimer > 0.6 then
                hum.Jump = true
                stuckTimer = 0
            end
        else
            stuckTimer = 0
        end
        lastPos = hrp.Position
    end
    return false
end

-- Nearest Egg Prompt Detector
local function FindActiveEggPrompt()
    local hrp = GetHRP()
    if not hrp then return nil end

    local bestPrompt = nil
    local bestDist = 28

    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
            local p = prompt.Parent
            local pPos = p:IsA("BasePart") and p.Position or (p:IsA("Model") and p:GetPivot().Position)
            if pPos then
                local d = (pPos - hrp.Position).Magnitude
                local act = string.lower(prompt.ActionText)
                local obj = string.lower(prompt.ObjectText)

                if string.find(act, "steal") or string.find(obj, "egg") or string.find(act, "egg") or string.find(obj, "steal") or string.find(act, "take") or string.find(act, "grab") then
                    if d < bestDist then
                        bestDist = d
                        bestPrompt = prompt
                    end
                end
            end
        end
    end

    if not bestPrompt then
        for _, prompt in ipairs(Workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                local p = prompt.Parent
                local pPos = p:IsA("BasePart") and p.Position or (p:IsA("Model") and p:GetPivot().Position)
                if pPos then
                    local d = (pPos - hrp.Position).Magnitude
                    if d < 18 and d < bestDist then
                        bestDist = d
                        bestPrompt = prompt
                    end
                end
            end
        end
    end

    return bestPrompt
end

-- Instant Trigger (0.0s Delay)
local function InstantTriggerSteal()
    local prompt = FindActiveEggPrompt()

    if prompt then
        if typeof(fireproximityprompt) == "function" then
            pcall(function() fireproximityprompt(prompt) end)
        else
            local oldHold = prompt.HoldDuration
            prompt.HoldDuration = 0
            prompt:InputHoldBegin()
            prompt:InputHoldEnd()
            prompt.HoldDuration = oldHold
        end
    end

    local hrp = GetHRP()
    if hrp then
        for _, cd in ipairs(Workspace:GetDescendants()) do
            if cd:IsA("ClickDetector") and cd.Parent and cd.Parent:IsA("BasePart") then
                if (cd.Parent.Position - hrp.Position).Magnitude <= (cd.MaxActivationDistance or 32) then
                    if typeof(fireclickdetector) == "function" then fireclickdetector(cd) end
                end
            end
        end
    end

    pcall(function()
        for _, gui in ipairs(PlayerGui:GetDescendants()) do
            if gui:IsA("GuiButton") and gui.Visible then
                local t = gui:IsA("TextButton") and string.lower(gui.Text) or ""
                local n = string.lower(gui.Name)
                if string.find(t, "steal") or string.find(t, "egg") or string.find(t, "take") or string.find(n, "steal") then
                    if typeof(firesignal) == "function" then
                        firesignal(gui.Activated)
                        firesignal(gui.MouseButton1Click)
                    end
                end
            end
        end
    end)
end

-- Place Egg on Plot
local function PlaceEggAtPlot()
    local char = GetChar()
    local egg = GetEggTool()

    if egg and egg.Parent ~= char then
        local hum = GetHumanoid()
        if hum then hum:EquipTool(egg) else egg.Parent = char end
        task.wait(0.15)
    end

    if egg and egg:IsA("Tool") then
        egg:Activate()
        task.wait(0.2)
    end

    local hrp = GetHRP()
    if hrp then
        for _, cd in ipairs(Workspace:GetDescendants()) do
            if cd:IsA("ClickDetector") and cd.Parent and (cd.Parent.Position - hrp.Position).Magnitude < 16 then
                if typeof(fireclickdetector) == "function" then fireclickdetector(cd) end
            end
        end
    end
end

-- Find Player with Egg in Corridor
local function FindEggCarryingEnemy()
    local myHRP = GetHRP()
    if not myHRP then return nil end

    local bestTarget = nil
    local shortestDist = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local pChar = player.Character
            local pHum = pChar:FindFirstChild("Humanoid")
            local pHRP = pChar:FindFirstChild("HumanoidRootPart")

            if pHum and pHRP and pHum.Health > 0 then
                local inZone = (pHRP.Position.X < 1250 and pHRP.Position.X > 550)

                local hasEgg = false
                for _, item in ipairs(pChar:GetChildren()) do
                    if item:IsA("Tool") or item:IsA("Model") then
                        local n = string.lower(item.Name)
                        if string.find(n, "egg") or string.find(n, "dragon") or string.find(n, "pet") then
                            hasEgg = true
                            break
                        end
                    end
                end

                if inZone and hasEgg then
                    local d = (pHRP.Position - myHRP.Position).Magnitude
                    if d < shortestDist then
                        shortestDist = d
                        bestTarget = player
                    end
                end
            end
        end
    end

    return bestTarget
end

-- Main Controller Loop
local function MainControllerLoop()
    task.spawn(function()
        while State.Running do
            local hum = GetHumanoid()
            local plot = GameData.Plots[State.SelectedPlotName]

            -- ==================== MODE: PVP AMBUSH ====================
            if State.CurrentMode == "PVP" then
                State.Status = "👁️ Ambushing near Stages 1-3..."
                SafeWalkTo(GameData.AmbushPoint, 6.0, 6, State.SprintSpeed)

                local target = FindEggCarryingEnemy()
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local tHum = target.Character:FindFirstChild("Humanoid")

                    State.Status = "⚔️ ATTACKING " .. string.upper(target.DisplayName)
                    EquipBat()

                    local attackTimer = 0
                    while State.Running and tHum and tHum.Health > 0 and attackTimer < 10 do
                        if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then break end
                        
                        SetPlayerSpeed(State.SprintSpeed)
                        SafeWalkTo(target.Character.HumanoidRootPart.Position, 3.0, 0.5, State.SprintSpeed)
                        
                        AttackWithBat()
                        if hum then hum.Jump = true end
                        InstantTriggerSteal()

                        if GetEggTool() then
                            State.Status = "🎉 EGG STOLEN FROM PLAYER! 🏃💨"
                            break
                        end

                        task.wait(0.08)
                        attackTimer = attackTimer + 0.1
                    end

                    if GetEggTool() then
                        State.PlayersKilled = State.PlayersKilled + 1
                        
                        State.Status = "⚡ Rushing Egg to Start Spawn..."
                        SafeWalkTo(GameData.StartSpawn, 4.5, 10, State.SprintSpeed)
                        
                        State.Status = "🏡 Placing Egg in " .. State.SelectedPlotName
                        SafeWalkTo(plot, 4.0, 8, State.SprintSpeed)
                        if hum then hum.Jump = true end
                        task.wait(0.15)
                        PlaceEggAtPlot()
                        task.wait(0.25)
                        State.EggsCollected = State.EggsCollected + 1

                        SafeWalkTo(GameData.StartSpawn, 4.5, 8, State.SprintSpeed)
                    end
                else
                    task.wait(0.25)
                end

            -- ==================== MODE: AUTO FARM ====================
            else
                local stage = GameData.Stages[State.SelectedStageIndex]

                -- 0. Start Spawn
                State.Status = "🏁 Centering on Start Spawn..."
                SafeWalkTo(GameData.StartSpawn, 4.5, 8, State.SprintSpeed)
                if not State.Running then break end

                -- 1. Stage
                State.Status = "🏃 Rushing to " .. stage.name
                SafeWalkTo(stage.pos, 3.2, 14, State.ApproachSpeed)
                if not State.Running then break end

                -- 2. Grab Egg & Instant Escape
                State.Status = "⚡ GRABBING EGG & ESCAPING! 💨"
                SetPlayerSpeed(State.SprintSpeed)
                InstantTriggerSteal()
                if hum then hum.Jump = true end

                -- 3. Sprint to Spawn
                State.Status = "⚡ EVADING NPC -> RUSHING TO SPAWN! 🏃💨"
                SafeWalkTo(GameData.StartSpawn, 4.5, 12, State.SprintSpeed)
                if not State.Running then break end

                -- 4. Sprint to Plot
                State.Status = "🏡 Delivering to " .. State.SelectedPlotName .. " ⚡"
                SafeWalkTo(plot, 4.0, 9, State.SprintSpeed)
                if not State.Running then break end

                -- 5. Place Egg
                State.Status = "🦘 Placing Egg..."
                if hum then hum.Jump = true end
                task.wait(0.15)
                PlaceEggAtPlot()
                task.wait(0.25)
                State.EggsCollected = State.EggsCollected + 1

                -- 6. Return to Start Spawn
                State.Status = "🔄 Returning to Start Spawn..."
                SafeWalkTo(GameData.StartSpawn, 4.5, 9, State.SprintSpeed)
                if not State.Running then break end

                State.Status = "✅ Cycle Completed!"
                task.wait(0.1)
            end
        end
        SetPlayerSpeed(State.NormalSpeed)
        State.Status = "⏹️ Idle"
    end)
end




-- ================================================================
-- 🎨 NEW COMPACT SKETCHED UI & SETTINGS (CONNECTED TO ORIGINAL ENGINE)
-- ================================================================

pcall(function()
    local parentObj = (gethui and gethui()) or CoreGui or PlayerGui
    for _, child in ipairs(parentObj:GetChildren()) do
        if child.Name == "StealAnEggSketchUI" or child.Name == "StealEgg_Clean" then
            child:Destroy()
        end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StealAnEggSketchUI"
ScreenGui.ResetOnSpawn = false
pcall(function()
    if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = CoreGui end
end)
if not ScreenGui.Parent then ScreenGui.Parent = PlayerGui end

-- Floating Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 44, 0, 44)
ToggleBtn.Position = UDim2.new(0, 20, 0, 150)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
ToggleBtn.Text = "🥚"
ToggleBtn.TextSize = 22
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local tStroke = Instance.new("UIStroke", ToggleBtn)
tStroke.Color = Color3.fromRGB(56, 189, 248)
tStroke.Thickness = 2

-- Main Window (Compact Square Layout: 460 x 340)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 460, 0, 340)
MainFrame.Position = UDim2.new(0.5, -230, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
MainFrame.Visible = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(37, 99, 235)
MainStroke.Thickness = 2

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Top Bar: Avatar Circle + Username + Close
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

local AvatarCircle = Instance.new("ImageLabel")
AvatarCircle.Size = UDim2.new(0, 36, 0, 36)
AvatarCircle.Position = UDim2.new(0, 10, 0, 7)
AvatarCircle.BackgroundColor3 = Color3.fromRGB(56, 189, 248)
pcall(function()
    AvatarCircle.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size42x42)
end)
AvatarCircle.Parent = TopBar
Instance.new("UICorner", AvatarCircle).CornerRadius = UDim.new(1, 0)

local UserLabel = Instance.new("TextLabel")
UserLabel.Size = UDim2.new(0, 250, 1, 0)
UserLabel.Position = UDim2.new(0, 56, 0, 0)
UserLabel.BackgroundTransparency = 1
UserLabel.Text = LocalPlayer.Name
UserLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
UserLabel.TextSize = 15
UserLabel.Font = Enum.Font.GothamBold
UserLabel.TextXAlignment = Enum.TextXAlignment.Left
UserLabel.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -38, 0, 9)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(148, 163, 184)
CloseBtn.TextSize = 16
CloseBtn.Parent = TopBar
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- Sidebar Tabs (home, PvP, Farm, Others)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 110, 1, -58)
Sidebar.Position = UDim2.new(0, 8, 0, 54)
Sidebar.BackgroundTransparency = 1
Sidebar.Parent = MainFrame

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -132, 1, -58)
ContentArea.Position = UDim2.new(0, 124, 0, 54)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local tabs = {"home", "PvP", "Farm", "Others"}
local tabButtons = {}
local tabPages = {}

for i, tName in ipairs(tabs) do
    local sBtn = Instance.new("TextButton")
    sBtn.Size = UDim2.new(1, 0, 0, 38)
    sBtn.Position = UDim2.new(0, 0, 0, (i-1)*44)
    sBtn.BackgroundColor3 = (i == 1) and Color3.fromRGB(37, 99, 235) or Color3.fromRGB(30, 41, 59)
    sBtn.Text = tName
    sBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    sBtn.TextSize = 14
    sBtn.Font = Enum.Font.GothamBold
    sBtn.Parent = Sidebar
    Instance.new("UICorner", sBtn).CornerRadius = UDim.new(0, 6)
    tabButtons[tName] = sBtn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = (i == 1)
    page.CanvasSize = UDim2.new(0, 0, 0, 300)
    page.ScrollBarThickness = 3
    page.Parent = ContentArea
    tabPages[tName] = page

    sBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(tabPages) do p.Visible = false end
        for _, b in pairs(tabButtons) do b.BackgroundColor3 = Color3.fromRGB(30, 41, 59) end
        page.Visible = true
        sBtn.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
    end)
end

-- --- HOME PAGE ---
local home = tabPages["home"]
local hTitle = Instance.new("TextLabel", home)
hTitle.Size = UDim2.new(1, 0, 0, 24)
hTitle.BackgroundTransparency = 1
hTitle.Text = "(Tab title) Home Dashboard"
hTitle.TextColor3 = Color3.fromRGB(56, 189, 248)
hTitle.TextSize = 13
hTitle.Font = Enum.Font.GothamBold

local autoLbl = Instance.new("TextLabel", home)
autoLbl.Size = UDim2.new(0, 150, 0, 30)
autoLbl.Position = UDim2.new(0, 0, 0, 30)
autoLbl.BackgroundTransparency = 1
autoLbl.Text = "auto steal"
autoLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
autoLbl.TextSize = 14
autoLbl.Font = Enum.Font.GothamBold
autoLbl.TextXAlignment = Enum.TextXAlignment.Left
autoLbl.Parent = home

local autoBtn = Instance.new("TextButton", home)
autoBtn.Size = UDim2.new(0, 55, 0, 26)
autoBtn.Position = UDim2.new(0, 165, 0, 32)
autoBtn.BackgroundColor3 = State.Running and Color3.fromRGB(22, 163, 74) or Color3.fromRGB(30, 41, 59)
autoBtn.Text = State.Running and "ON" or "OFF"
autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBtn.TextSize = 12
autoBtn.Parent = home
Instance.new("UICorner", autoBtn).CornerRadius = UDim.new(1, 0)

autoBtn.MouseButton1Click:Connect(function()
    State.Running = not State.Running
    autoBtn.BackgroundColor3 = State.Running and Color3.fromRGB(22, 163, 74) or Color3.fromRGB(30, 41, 59)
    autoBtn.Text = State.Running and "ON" or "OFF"
    if State.Running then
        State.CurrentMode = "FARM"
        MainControllerLoop()
    end
end)

local statusLbl = Instance.new("TextLabel", home)
statusLbl.Size = UDim2.new(1, 0, 0, 35)
statusLbl.Position = UDim2.new(0, 0, 0, 70)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "Status: Idle"
statusLbl.TextColor3 = Color3.fromRGB(148, 163, 184)
statusLbl.TextSize = 12
statusLbl.Font = Enum.Font.Gotham
statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.TextWrapped = true
statusLbl.Parent = home

task.spawn(function()
    while true do
        task.wait(0.2)
        pcall(function() statusLbl.Text = "Status: " .. tostring(State.Status) end)
    end
end)

-- --- PVP PAGE ---
local pvp = tabPages["PvP"]
local pTitle = Instance.new("TextLabel", pvp)
pTitle.Size = UDim2.new(1, 0, 0, 24)
pTitle.BackgroundTransparency = 1
pTitle.Text = "(Tab title) PvP Stealer"
pTitle.TextColor3 = Color3.fromRGB(239, 68, 68)
pTitle.TextSize = 13
pTitle.Font = Enum.Font.GothamBold

local pvpModeLbl = Instance.new("TextLabel", pvp)
pvpModeLbl.Size = UDim2.new(0, 150, 0, 30)
pvpModeLbl.Position = UDim2.new(0, 0, 0, 30)
pvpModeLbl.BackgroundTransparency = 1
pvpModeLbl.Text = "PvP Mode"
pvpModeLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
pvpModeLbl.TextSize = 13
pvpModeLbl.Font = Enum.Font.GothamBold
pvpModeLbl.TextXAlignment = Enum.TextXAlignment.Left
pvpModeLbl.Parent = pvp

local pvpBtn = Instance.new("TextButton", pvp)
pvpBtn.Size = UDim2.new(0, 55, 0, 26)
pvpBtn.Position = UDim2.new(0, 165, 0, 32)
pvpBtn.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
pvpBtn.Text = "OFF"
pvpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
pvpBtn.TextSize = 12
pvpBtn.Parent = pvp
Instance.new("UICorner", pvpBtn).CornerRadius = UDim.new(1, 0)

pvpBtn.MouseButton1Click:Connect(function()
    if State.CurrentMode == "PVP" then
        State.CurrentMode = "FARM"
        pvpBtn.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
        pvpBtn.Text = "OFF"
    else
        State.CurrentMode = "PVP"
        State.Running = true
        pvpBtn.BackgroundColor3 = Color3.fromRGB(22, 163, 74)
        pvpBtn.Text = "ON"
        MainControllerLoop()
    end
end)

-- --- FARM PAGE (Stages, Plots, Auto Treadmill with smart own plot detection) ---
local farm = tabPages["Farm"]
local fTitle = Instance.new("TextLabel", farm)
fTitle.Size = UDim2.new(1, 0, 0, 24)
fTitle.BackgroundTransparency = 1
fTitle.Text = "(Tab title) Auto Farm & Stages"
fTitle.TextColor3 = Color3.fromRGB(34, 197, 94)
fTitle.TextSize = 13
fTitle.Font = Enum.Font.GothamBold

-- Auto Detect Plot button
local autoPlotBtn = Instance.new("TextButton", farm)
autoPlotBtn.Size = UDim2.new(0, 220, 0, 26)
autoPlotBtn.Position = UDim2.new(0, 0, 0, 30)
autoPlotBtn.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
autoPlotBtn.Text = "🔍 Auto Detect My Plot"
autoPlotBtn.TextColor3 = Color3.fromRGB(56, 189, 248)
autoPlotBtn.TextSize = 12
Instance.new("UICorner", autoPlotBtn).CornerRadius = UDim.new(0, 6)

autoPlotBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local hrp = GetHRP()
        if hrp then
            local closestPlot = "Plot 1"
            local minDst = math.huge
            for pName, pPos in pairs(GameData.Plots) do
                local dst = (hrp.Position - pPos).Magnitude
                if dst < minDst then
                    minDst = dst
                    closestPlot = pName
                end
            end
            State.SelectedPlotName = closestPlot
            autoPlotBtn.Text = "✅ Detected: " .. closestPlot
            task.delay(2, function() autoPlotBtn.Text = "🔍 Auto Detect My Plot" end)
        end
    end)
end)

local stageLbl = Instance.new("TextLabel", farm)
stageLbl.Size = UDim2.new(0, 140, 0, 26)
stageLbl.Position = UDim2.new(0, 0, 0, 66)
stageLbl.BackgroundTransparency = 1
stageLbl.Text = "Stage: Stage 1"
stageLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
stageLbl.TextSize = 13
stageLbl.Font = Enum.Font.GothamBold
stageLbl.TextXAlignment = Enum.TextXAlignment.Left

local stageBtn = Instance.new("TextButton", farm)
stageBtn.Size = UDim2.new(0, 75, 0, 26)
stageBtn.Position = UDim2.new(0, 150, 0, 66)
stageBtn.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
stageBtn.Text = "Change ➔"
stageBtn.TextColor3 = Color3.fromRGB(56, 189, 248)
stageBtn.TextSize = 11
Instance.new("UICorner", stageBtn).CornerRadius = UDim.new(0, 6)

stageBtn.MouseButton1Click:Connect(function()
    State.SelectedStageIndex = State.SelectedStageIndex + 1
    if State.SelectedStageIndex > #GameData.Stages then State.SelectedStageIndex = 1 end
    stageLbl.Text = "Stage: " .. GameData.Stages[State.SelectedStageIndex].name
end)

-- Auto Treadmill (Smart AFK: automatically finds player's plot, walks there and stays AFK)
local tLbl = Instance.new("TextLabel", farm)
tLbl.Size = UDim2.new(0, 140, 0, 30)
tLbl.Position = UDim2.new(0, 0, 0, 102)
tLbl.BackgroundTransparency = 1
tLbl.Text = "Auto Treadmill (AFK)"
tLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
tLbl.TextSize = 13
tLbl.Font = Enum.Font.GothamBold
tLbl.TextXAlignment = Enum.TextXAlignment.Left

local tBtn = Instance.new("TextButton", farm)
tBtn.Size = UDim2.new(0, 55, 0, 26)
tBtn.Position = UDim2.new(0, 150, 0, 104)
tBtn.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
tBtn.Text = "OFF"
tBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tBtn.TextSize = 12
Instance.new("UICorner", tBtn).CornerRadius = UDim.new(1, 0)

local autoTreadmillActive = false
tBtn.MouseButton1Click:Connect(function()
    autoTreadmillActive = not autoTreadmillActive
    tBtn.BackgroundColor3 = autoTreadmillActive and Color3.fromRGB(22, 163, 74) or Color3.fromRGB(30, 41, 59)
    tBtn.Text = autoTreadmillActive and "ON" or "OFF"
end)

-- Background loop for Auto Treadmill: detects own plot and walks/sits there AFK
task.spawn(function()
    while true do
        task.wait(1)
        if autoTreadmillActive then
            pcall(function()
                local hrp = GetHRP()
                local hum = GetHumanoid()
                if hrp and hum then
                    -- Find closest plot automatically if not set
                    local myPlotPos = GameData.Plots[State.SelectedPlotName] or GameData.Plots["Plot 1"]
                    if (hrp.Position - myPlotPos).Magnitude > 10 then
                        hum:MoveTo(myPlotPos)
                    end
                end
            end)
        end
    end
end)

-- --- OTHERS PAGE ---
local others = tabPages["Others"]
local oTitle = Instance.new("TextLabel", others)
oTitle.Size = UDim2.new(1, 0, 0, 24)
oTitle.BackgroundTransparency = 1
oTitle.Text = "(Tab title) Others & Settings"
oTitle.TextColor3 = Color3.fromRGB(168, 85, 247)
oTitle.TextSize = 13
oTitle.Font = Enum.Font.GothamBold

local fpsLbl = Instance.new("TextLabel", others)
fpsLbl.Size = UDim2.new(0, 150, 0, 30)
fpsLbl.Position = UDim2.new(0, 0, 0, 30)
fpsLbl.BackgroundTransparency = 1
fpsLbl.Text = "FPS Boost"
fpsLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
fpsLbl.TextSize = 13
fpsLbl.Font = Enum.Font.GothamBold
fpsLbl.TextXAlignment = Enum.TextXAlignment.Left

local fpsBtn = Instance.new("TextButton", others)
fpsBtn.Size = UDim2.new(0, 55, 0, 26)
fpsBtn.Position = UDim2.new(0, 165, 0, 32)
fpsBtn.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
fpsBtn.Text = "OFF"
fpsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
fpsBtn.TextSize = 12
Instance.new("UICorner", fpsBtn).CornerRadius = UDim.new(1, 0)

local fpsBoostActive = false
fpsBtn.MouseButton1Click:Connect(function()
    fpsBoostActive = not fpsBoostActive
    fpsBtn.BackgroundColor3 = fpsBoostActive and Color3.fromRGB(22, 163, 74) or Color3.fromRGB(30, 41, 59)
    fpsBtn.Text = fpsBoostActive and "ON" or "OFF"
    if fpsBoostActive then
        pcall(function()
            game:GetService("Lighting").GlobalShadows = false
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end
            end
        end)
    end
end)

print("Steal An Egg Complete Core Engine + Sketched Compact UI Loaded Successfully!")
