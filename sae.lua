
 --[[   ================================================================
    ⚔️ STEAL AN EGG - AUTO FARM + PvP EGG STEALER (CLEAN NO-AFK)
    ================================================================
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
-- ⚡ ROBUST CLEAN SCRIPT + PROFESSIONAL UI + EGG ESP
-- ================================================================

pcall(function()
    local parentObj = (gethui and gethui()) or CoreGui or PlayerGui
    for _, child in ipairs(parentObj:GetChildren()) do
        if child.Name == "StealAnEggProUI" or child.Name == "StealAnEggSketchUI" or child.Name == "StealEgg_Clean" then
            child:Destroy()
        end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StealAnEggProUI"
ScreenGui.ResetOnSpawn = false
pcall(function()
    if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = CoreGui end
end)
if not ScreenGui.Parent then ScreenGui.Parent = PlayerGui end

-- Floating Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 44, 0, 44)
ToggleBtn.Position = UDim2.new(0, 20, 0, 150)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
ToggleBtn.Text = "⚡"
ToggleBtn.TextSize = 20
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local tStroke = Instance.new("UIStroke", ToggleBtn)
tStroke.Color = Color3.fromRGB(139, 92, 246)
tStroke.Thickness = 2

-- Main Window Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 640, 0, 420)
MainFrame.Position = UDim2.new(0.5, -320, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 18)
MainFrame.Visible = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(139, 92, 246)
MainStroke.Thickness = 1.5

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Top Bar Header
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(0, 250, 1, 0)
TitleLbl.Position = UDim2.new(0, 15, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "Nasi Rendang - nr1script.com"
TitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLbl.TextSize = 13
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.Parent = TopBar

local SubTitleLbl = Instance.new("TextLabel")
SubTitleLbl.Size = UDim2.new(0, 250, 0, 14)
SubTitleLbl.Position = UDim2.new(0, 15, 0, 24)
SubTitleLbl.BackgroundTransparency = 1
SubTitleLbl.Text = "Steal an Egg"
SubTitleLbl.TextColor3 = Color3.fromRGB(156, 163, 175)
SubTitleLbl.TextSize = 11
SubTitleLbl.Font = Enum.Font.Gotham
SubTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
SubTitleLbl.Parent = TopBar

-- Stats Pill
local StatsPill = Instance.new("Frame")
StatsPill.Size = UDim2.new(0, 180, 0, 26)
StatsPill.Position = UDim2.new(1, -195, 0, 8)
StatsPill.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
StatsPill.Parent = TopBar
Instance.new("UICorner", StatsPill).CornerRadius = UDim.new(0, 6)

local StatsText = Instance.new("TextLabel")
StatsText.Size = UDim2.new(1, 0, 1, 0)
StatsText.BackgroundTransparency = 1
StatsText.Text = "1 stakes · 165 FPS · 884 cruds"
StatsText.TextColor3 = Color3.fromRGB(52, 211, 153)
StatsText.TextSize = 10
StatsText.Font = Enum.Font.GothamBold
StatsText.Parent = StatsPill

-- Left Sidebar
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 170, 1, -42)
Sidebar.Position = UDim2.new(0, 0, 0, 42)
Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Sidebar.BorderSizePixel = 0
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 320)
Sidebar.ScrollBarThickness = 2
Sidebar.Parent = MainFrame

local categories = {"Steal", "ESP & Visuals", "Predict (ERR)", "Pets", "Upgrades"}
local catButtons = {}
local catPages = {}

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -170, 1, -42)
ContentArea.Position = UDim2.new(0, 170, 0, 42)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

for i, catName in ipairs(categories) do
    local cBtn = Instance.new("TextButton")
    cBtn.Size = UDim2.new(1, -12, 0, 34)
    cBtn.Position = UDim2.new(0, 6, 0, (i-1)*38 + 10)
    cBtn.BackgroundColor3 = (i == 1) and Color3.fromRGB(139, 92, 246) or Color3.fromRGB(20, 20, 28)
    cBtn.Text = "   " .. catName
    cBtn.TextColor3 = (i == 1) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(156, 163, 175)
    cBtn.TextSize = 13
    cBtn.Font = Enum.Font.GothamBold
    cBtn.TextXAlignment = Enum.TextXAlignment.Left
    cBtn.Parent = Sidebar
    Instance.new("UICorner", cBtn).CornerRadius = UDim.new(0, 6)
    catButtons[catName] = cBtn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = (i == 1)
    page.CanvasSize = UDim2.new(0, 0, 0, 500)
    page.ScrollBarThickness = 3
    page.Parent = ContentArea
    catPages[catName] = page

    cBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(catPages) do p.Visible = false end
        for _, b in pairs(catButtons) do 
            b.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
            b.TextColor3 = Color3.fromRGB(156, 163, 175)
        end
        page.Visible = true
        cBtn.BackgroundColor3 = Color3.fromRGB(139, 92, 246)
        cBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
end

-- Premium footer
local FooterFrame = Instance.new("Frame")
FooterFrame.Size = UDim2.new(1, -12, 0, 45)
FooterFrame.Position = UDim2.new(0, 6, 1, -52)
FooterFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
FooterFrame.Parent = Sidebar
Instance.new("UICorner", FooterFrame).CornerRadius = UDim.new(0, 6)

local PremLbl = Instance.new("TextLabel")
PremLbl.Size = UDim2.new(1, -10, 1, 0)
PremLbl.Position = UDim2.new(0, 10, 0, 0)
PremLbl.BackgroundTransparency = 1
PremLbl.Text = "⭐ Premium\nSigned In (" .. LocalPlayer.Name .. ")"
PremLbl.TextColor3 = Color3.fromRGB(234, 179, 8)
PremLbl.TextSize = 11
PremLbl.Font = Enum.Font.GothamBold
PremLbl.TextXAlignment = Enum.TextXAlignment.Left
PremLbl.Parent = FooterFrame

-- --- STEAL PAGE ---
local stealPage = catPages["Steal"]

local secTitle = Instance.new("TextLabel", stealPage)
secTitle.Size = UDim2.new(1, -20, 0, 30)
secTitle.Position = UDim2.new(0, 15, 0, 10)
secTitle.BackgroundTransparency = 1
secTitle.Text = "General Settings & Automation"
secTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
secTitle.TextSize = 14
secTitle.Font = Enum.Font.GothamBold
secTitle.TextXAlignment = Enum.TextXAlignment.Left

local function CreateToggleRow(parent, labelText, defaultVal, callback, yPos)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, -30, 0, 34)
    row.Position = UDim2.new(0, 15, 0, yPos)
    row.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0, 200, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(220, 220, 230)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local tBtn = Instance.new("TextButton", row)
    tBtn.Size = UDim2.new(0, 44, 0, 22)
    tBtn.Position = UDim2.new(1, -54, 0.5, -11)
    tBtn.BackgroundColor3 = defaultVal and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(50, 50, 65)
    tBtn.Text = ""
    Instance.new("UICorner", tBtn).CornerRadius = UDim.new(1, 0)

    local dot = Instance.new("Frame", tBtn)
    dot.Size = UDim2.new(0, 18, 0, 18)
    dot.Position = defaultVal and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local active = defaultVal
    tBtn.MouseButton1Click:Connect(function()
        active = not active
        tBtn.BackgroundColor3 = active and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(50, 50, 65)
        dot.Position = active and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        callback(active)
    end)
    return row
end

CreateToggleRow(stealPage, "Auto Steal Eggs", false, function(v)
    State.Running = v
    if v then State.CurrentMode = "FARM" MainControllerLoop() end
end, 45)

CreateToggleRow(stealPage, "Auto Place to Plot", true, function(v)
    State.AutoPlace = v
end, 85)

CreateToggleRow(stealPage, "Real Godmode", false, function(v)
    State.Godmode = v
end, 125)

CreateToggleRow(stealPage, "Auto Treadmill", false, function(v)
    State.AutoTreadmill = v
end, 165)

-- Stage Selector Row
local stageRow = Instance.new("Frame", stealPage)
stageRow.Size = UDim2.new(1, -30, 0, 38)
stageRow.Position = UDim2.new(0, 15, 0, 210)
stageRow.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
Instance.new("UICorner", stageRow).CornerRadius = UDim.new(0, 6)

local sLbl = Instance.new("TextLabel", stageRow)
sLbl.Size = UDim2.new(0, 140, 1, 0)
sLbl.Position = UDim2.new(0, 12, 0, 0)
sLbl.BackgroundTransparency = 1
sLbl.Text = "Select Stage (1-11)"
sLbl.TextColor3 = Color3.fromRGB(220, 220, 230)
sLbl.TextSize = 12
sLbl.Font = Enum.Font.GothamBold
sLbl.TextXAlignment = Enum.TextXAlignment.Left

local sValBtn = Instance.new("TextButton", stageRow)
sValBtn.Size = UDim2.new(0, 120, 0, 26)
sValBtn.Position = UDim2.new(1, -132, 0.5, -13)
sValBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
sValBtn.Text = "Stage 1 ▾"
sValBtn.TextColor3 = Color3.fromRGB(139, 92, 246)
sValBtn.TextSize = 12
sValBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", sValBtn).CornerRadius = UDim.new(0, 6)

sValBtn.MouseButton1Click:Connect(function()
    State.SelectedStageIndex = State.SelectedStageIndex + 1
    if State.SelectedStageIndex > #GameData.Stages then State.SelectedStageIndex = 1 end
    sValBtn.Text = GameData.Stages[State.SelectedStageIndex].name .. " ▾"
end)

-- --- ESP & VISUALS PAGE ---
local espPage = catPages["ESP & Visuals"]
local espTitle = Instance.new("TextLabel", espPage)
espTitle.Size = UDim2.new(1, -20, 0, 30)
espTitle.Position = UDim2.new(0, 15, 0, 10)
espTitle.BackgroundTransparency = 1
espTitle.Text = "Egg & Player ESP Options"
espTitle.TextColor3 = Color3.fromRGB(56, 189, 248)
espTitle.TextSize = 14
espTitle.Font = Enum.Font.GothamBold
espTitle.TextXAlignment = Enum.TextXAlignment.Left

local EggESPEnabled = false
CreateToggleRow(espPage, "Egg ESP (Highlight Eggs)", false, function(v)
    EggESPEnabled = v
    task.spawn(function()
        while EggESPEnabled do
            pcall(function()
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():find("egg") or obj.Name:lower():find("nest")) then
                        if not obj:FindFirstChild("SAE_EggESP") then
                            local hl = Instance.new("Highlight")
                            hl.Name = "SAE_EggESP"
                            hl.FillColor = Color3.fromRGB(168, 85, 247)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.Parent = obj
                        end
                    end
                end
            end)
            task.wait(2)
        end
        -- Remove when disabled
        pcall(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj.Name == "SAE_EggESP" then obj:Destroy() end
            end
        end)
    end()
end, 45)

print("Steal An Egg Clean Pro UI Loaded Successfully!")
