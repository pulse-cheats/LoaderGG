--[[
    ================================================================
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

-- UI
pcall(function()
    local parentObj = (gethui and gethui()) or CoreGui or PlayerGui
    local old = parentObj:FindFirstChild("StealEgg_Clean")
    if old then old:Destroy() end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StealEgg_Clean"
ScreenGui.ResetOnSpawn = false

if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = PlayerGui end
end

local function EnableSmoothDrag(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle = handle or frame

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            TweenService:Create(frame, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            }):Play()
        end
    end)
end

-- Floating Button
local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = "FloatButton"
FloatBtn.Size = UDim2.new(0, 54, 0, 54)
FloatBtn.Position = UDim2.new(0.02, 0, 0.45, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(20, 22, 34)
FloatBtn.Text = "⚔️"
FloatBtn.TextSize = 24
FloatBtn.AutoButtonColor = false
FloatBtn.Parent = ScreenGui

Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)
local fbStroke = Instance.new("UIStroke", FloatBtn)
fbStroke.Color = Color3.fromRGB(255, 60, 80)
fbStroke.Thickness = 2.4

EnableSmoothDrag(FloatBtn, FloatBtn)

-- Main Frame
local Main = Instance.new("Frame")
Main.Name = "MainCard"
Main.Size = UDim2.new(0, 350, 0, 490)
Main.Position = UDim2.new(0.5, -175, 0.5, -245)
Main.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.ClipsDescendants = true
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 18)
local mStroke = Instance.new("UIStroke", Main)
mStroke.Color = Color3.fromRGB(45, 55, 80)
mStroke.Thickness = 1.6

-- Header Bar
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(18, 20, 30)
Header.BorderSizePixel = 0
Header.Parent = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 18)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -90, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚔️ STEAL EGG - PvP & FARM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Badge = Instance.new("TextLabel")
Badge.Size = UDim2.new(0, 56, 0, 20)
Badge.Position = UDim2.new(0, 200, 0.5, -10)
Badge.BackgroundColor3 = Color3.fromRGB(255, 60, 80)
Badge.TextColor3 = Color3.fromRGB(255, 255, 255)
Badge.Font = Enum.Font.GothamBold
Badge.TextSize = 9
Badge.Text = "v9 PRO"
Badge.Parent = Header
Instance.new("UICorner", Badge).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(235, 55, 75)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)
FloatBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)
EnableSmoothDrag(Main, Header)

-- Tabs
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 36)
TabBar.Position = UDim2.new(0, 10, 0, 56)
TabBar.BackgroundColor3 = Color3.fromRGB(18, 21, 32)
TabBar.Parent = Main
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 10)

local TabFarm = Instance.new("TextButton")
TabFarm.Size = UDim2.new(0.5, -2, 1, -4)
TabFarm.Position = UDim2.new(0, 2, 0, 2)
TabFarm.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
TabFarm.Text = "🥚 AUTO FARM"
TabFarm.TextColor3 = Color3.fromRGB(255, 255, 255)
TabFarm.Font = Enum.Font.GothamBold
TabFarm.TextSize = 11
TabFarm.Parent = TabBar
Instance.new("UICorner", TabFarm).CornerRadius = UDim.new(0, 8)

local TabPvP = Instance.new("TextButton")
TabPvP.Size = UDim2.new(0.5, -2, 1, -4)
TabPvP.Position = UDim2.new(0.5, 0, 0, 2)
TabPvP.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
TabPvP.Text = "⚔️ PVP STEALER"
TabPvP.TextColor3 = Color3.fromRGB(160, 170, 190)
TabPvP.Font = Enum.Font.GothamBold
TabPvP.TextSize = 11
TabPvP.Parent = TabBar
Instance.new("UICorner", TabPvP).CornerRadius = UDim.new(0, 8)

TabFarm.MouseButton1Click:Connect(function()
    State.CurrentMode = "FARM"
    TabFarm.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
    TabFarm.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabPvP.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
    TabPvP.TextColor3 = Color3.fromRGB(160, 170, 190)
end)

TabPvP.MouseButton1Click:Connect(function()
    State.CurrentMode = "PVP"
    TabPvP.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
    TabPvP.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabFarm.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
    TabFarm.TextColor3 = Color3.fromRGB(160, 170, 190)
end)

-- Scroll Area
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -104)
Scroll.Position = UDim2.new(0, 10, 0, 98)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 60, 80)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = Main

local SList = Instance.new("UIListLayout", Scroll)
SList.Padding = UDim.new(0, 10)
SList.SortOrder = Enum.SortOrder.LayoutOrder

-- Status Card
local StatusCard = Instance.new("Frame")
StatusCard.Size = UDim2.new(1, 0, 0, 58)
StatusCard.BackgroundColor3 = Color3.fromRGB(20, 23, 34)
StatusCard.Parent = Scroll
Instance.new("UICorner", StatusCard).CornerRadius = UDim.new(0, 12)
local stStroke = Instance.new("UIStroke", StatusCard)
stStroke.Color = Color3.fromRGB(38, 46, 68)
stStroke.Thickness = 1.2

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -16, 0, 24)
StatusLabel.Position = UDim2.new(0, 10, 0, 6)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(130, 225, 255)
StatusLabel.Font = Enum.Font.GothamSemibold
StatusLabel.TextSize = 12
StatusLabel.Text = "Status: Idle"
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = StatusCard

local EggsLabel = Instance.new("TextLabel")
EggsLabel.Size = UDim2.new(1, -16, 0, 20)
EggsLabel.Position = UDim2.new(0, 10, 0, 30)
EggsLabel.BackgroundTransparency = 1
EggsLabel.TextColor3 = Color3.fromRGB(190, 200, 220)
EggsLabel.Font = Enum.Font.Gotham
EggsLabel.TextSize = 11
EggsLabel.Text = "🥚 Eggs: 0  |  ⚔️ Kills: 0  |  Mode: FARM"
EggsLabel.TextXAlignment = Enum.TextXAlignment.Left
EggsLabel.Parent = StatusCard

-- Start / Stop Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, 0, 0, 44)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.Text = "▶  START ENGINE"
ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = Scroll
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 12)

ToggleBtn.MouseButton1Click:Connect(function()
    State.Running = not State.Running
    if State.Running then
        TweenService:Create(ToggleBtn, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(239, 68, 68)}):Play()
        ToggleBtn.Text = "⏹  STOP ENGINE"
        MainControllerLoop()
    else
        TweenService:Create(ToggleBtn, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(34, 197, 94)}):Play()
        ToggleBtn.Text = "▶  START ENGINE"
        State.Status = "⏹️ Idle"
    end
end)

-- PvP Info
local PvPInfo = Instance.new("Frame")
PvPInfo.Size = UDim2.new(1, 0, 0, 36)
PvPInfo.BackgroundColor3 = Color3.fromRGB(25, 20, 30)
PvPInfo.Parent = Scroll
Instance.new("UICorner", PvPInfo).CornerRadius = UDim.new(0, 10)
local pStroke = Instance.new("UIStroke", PvPInfo)
pStroke.Color = Color3.fromRGB(120, 40, 50)

local PvPText = Instance.new("TextLabel")
PvPText.Size = UDim2.new(1, -16, 1, 0)
PvPText.Position = UDim2.new(0, 10, 0, 0)
PvPText.BackgroundTransparency = 1
PvPText.Text = "⚔️ Auto-Equips Bat (Slot 1) & ambushes at Stages 1-3"
PvPText.TextColor3 = Color3.fromRGB(255, 120, 130)
PvPText.Font = Enum.Font.GothamMedium
PvPText.TextSize = 10
PvPText.TextXAlignment = Enum.TextXAlignment.Left
PvPText.Parent = PvPInfo

-- Section: Stage Select
local StgHead = Instance.new("TextLabel")
StgHead.Size = UDim2.new(1, 0, 0, 16)
StgHead.BackgroundTransparency = 1
StgHead.TextColor3 = Color3.fromRGB(255, 195, 60)
StgHead.Font = Enum.Font.GothamBold
StgHead.TextSize = 11
StgHead.Text = "🎯 TARGET STAGE (FARM MODE)"
StgHead.TextXAlignment = Enum.TextXAlignment.Left
StgHead.Parent = Scroll

local StgGrid = Instance.new("Frame")
StgGrid.Size = UDim2.new(1, 0, 0, 0)
StgGrid.AutomaticSize = Enum.AutomaticSize.Y
StgGrid.BackgroundTransparency = 1
StgGrid.Parent = Scroll

local sg = Instance.new("UIGridLayout", StgGrid)
sg.CellSize = UDim2.new(0.31, 0, 0, 30)
sg.CellPadding = UDim2.new(0.035, 0, 0, 6)

local StgBtns = {}
for i = 1, #GameData.Stages do
    local b = Instance.new("TextButton")
    b.Text = "Stage " .. i
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 11
    b.TextColor3 = (i == State.SelectedStageIndex) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 170, 190)
    b.BackgroundColor3 = (i == State.SelectedStageIndex) and Color3.fromRGB(255, 145, 0) or Color3.fromRGB(26, 30, 42)
    b.AutoButtonColor = false
    b.Parent = StgGrid
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

    b.MouseButton1Click:Connect(function()
        State.SelectedStageIndex = i
        for idx, btn in ipairs(StgBtns) do
            local isSel = (idx == i)
            TweenService:Create(btn, TweenInfo.new(0.15), {
                BackgroundColor3 = isSel and Color3.fromRGB(255, 145, 0) or Color3.fromRGB(26, 30, 42),
                TextColor3 = isSel and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 170, 190)
            }):Play()
        end
    end)
    table.insert(StgBtns, b)
end

-- Section: Plot Select
local PltHead = Instance.new("TextLabel")
PltHead.Size = UDim2.new(1, 0, 0, 16)
PltHead.BackgroundTransparency = 1
PltHead.TextColor3 = Color3.fromRGB(70, 210, 160)
PltHead.Font = Enum.Font.GothamBold
PltHead.TextSize = 11
PltHead.Text = "🏡 YOUR PLOT"
PltHead.TextXAlignment = Enum.TextXAlignment.Left
PltHead.Parent = Scroll

local PltGrid = Instance.new("Frame")
PltGrid.Size = UDim2.new(1, 0, 0, 0)
PltGrid.AutomaticSize = Enum.AutomaticSize.Y
PltGrid.BackgroundTransparency = 1
PltGrid.Parent = Scroll

local pg = Instance.new("UIGridLayout", PltGrid)
pg.CellSize = UDim2.new(0.22, 0, 0, 28)
pg.CellPadding = UDim2.new(0.04, 0, 0, 6)

local PltBtns = {}
for i = 1, 7 do
    local pName = "Plot " .. i
    local b = Instance.new("TextButton")
    b.Text = "Plot " .. i
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 11
    local isSel = (pName == State.SelectedPlotName)
    b.TextColor3 = isSel and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 170, 190)
    b.BackgroundColor3 = isSel and Color3.fromRGB(37, 99, 235) or Color3.fromRGB(26, 30, 42)
    b.AutoButtonColor = false
    b.Parent = PltGrid
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

    b.MouseButton1Click:Connect(function()
        State.SelectedPlotName = pName
        for name, btn in pairs(PltBtns) do
            local sel = (name == pName)
            TweenService:Create(btn, TweenInfo.new(0.15), {
                BackgroundColor3 = sel and Color3.fromRGB(37, 99, 235) or Color3.fromRGB(26, 30, 42),
                TextColor3 = sel and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 170, 190)
            }):Play()
        end
    end)
    PltBtns[pName] = b
end

-- Live Updater
RunService.RenderStepped:Connect(function()
    StatusLabel.Text = "Status: " .. State.Status
    EggsLabel.Text = "🥚 Eggs: " .. State.EggsCollected .. "  |  ⚔️ Kills: " .. State.PlayersKilled .. "  |  Mode: " .. State.CurrentMode
end)

--[[
    ================================================================
    ⚔️ UI, GIPHY LOADING, AUTO PLOT & ANTI-RAGDOLL EXTENSION
    ================================================================
--]]

task.spawn(function()
    local success, err = pcall(function()
        local CoreGui = game:GetService("CoreGui")
        local TweenService = game:GetService("TweenService")
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

        -- Cleanup old UIs
        pcall(function()
            for _, child in ipairs(PlayerGui:GetChildren()) do
                if child.Name == "StealAnEggProUI" then child:Destroy() end
            end
            if CoreGui then
                for _, child in ipairs(CoreGui:GetChildren()) do
                    if child.Name == "StealAnEggProUI" then child:Destroy() end
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

        -- Loading Screen
        local LoadOverlay = Instance.new("Frame", ScreenGui)
        LoadOverlay.Size = UDim2.new(1, 0, 1, 0)
        LoadOverlay.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
        LoadOverlay.ZIndex = 999

        local LoadImage = Instance.new("ImageLabel", LoadOverlay)
        LoadImage.Size = UDim2.new(0, 220, 0, 220)
        LoadImage.Position = UDim2.new(0.5, -110, 0.5, -130)
        LoadImage.BackgroundTransparency = 1
        LoadImage.Image = "https://raw.githubusercontent.com/Gkalimanis/StealAnEgg/main/assets/giphy-downsized-medium.gif"
        LoadImage.ZIndex = 1000

        local LoadText = Instance.new("TextLabel", LoadOverlay)
        LoadText.Size = UDim2.new(0, 300, 0, 30)
        LoadText.Position = UDim2.new(0.5, -150, 0.5, 100)
        LoadText.BackgroundTransparency = 1
        LoadText.Text = "Loading Steal An Egg Pro..."
        LoadText.TextColor3 = Color3.fromRGB(168, 85, 247)
        LoadText.TextSize = 13
        LoadText.Font = Enum.Font.GothamBold
        LoadText.ZIndex = 1000

        task.wait(7.0)

        local fadeTween = TweenService:Create(LoadOverlay, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
        fadeTween:Play()
        TweenService:Create(LoadImage, TweenInfo.new(0.8), {ImageTransparency = 1}):Play()
        TweenService:Create(LoadText, TweenInfo.new(0.8), {TextTransparency = 1}):Play()
        task.wait(0.8)
        LoadOverlay:Destroy()

        -- Toggle Button
        local ToggleBtn = Instance.new("TextButton", ScreenGui)
        ToggleBtn.Size = UDim2.new(0, 38, 0, 38)
        ToggleBtn.Position = UDim2.new(0, 15, 0, 140)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
        ToggleBtn.Text = "⚡"
        ToggleBtn.TextSize = 18
        ToggleBtn.Visible = false
        Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
        local tStroke = Instance.new("UIStroke", ToggleBtn)
        tStroke.Color = Color3.fromRGB(139, 92, 246)
        tStroke.Thickness = 2

        -- Main Frame
        local MainFrame = Instance.new("Frame", ScreenGui)
        MainFrame.Size = UDim2.new(0, 420, 0, 280)
        MainFrame.Position = UDim2.new(0.5, -210, 0.5, -140)
        MainFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 18)
        MainFrame.Visible = true
        Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
        local MainStroke = Instance.new("UIStroke", MainFrame)
        MainStroke.Color = Color3.fromRGB(139, 92, 246)
        MainStroke.Thickness = 1.2

        ToggleBtn.MouseButton1Click:Connect(function()
            MainFrame.Visible = true
            ToggleBtn.Visible = false
        end)

        -- Top Bar
        local TopBar = Instance.new("Frame", MainFrame)
        TopBar.Size = UDim2.new(1, 0, 0, 32)
        TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
        Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

        local TitleLbl = Instance.new("TextLabel", TopBar)
        TitleLbl.Size = UDim2.new(0, 220, 1, 0)
        TitleLbl.Position = UDim2.new(0, 10, 0, 0)
        TitleLbl.BackgroundTransparency = 1
        TitleLbl.Text = "Steal An Egg - Compact Pro"
        TitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        TitleLbl.TextSize = 11
        TitleLbl.Font = Enum.Font.GothamBold
        TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

        -- Close Button (X)
        local CloseBtn = Instance.new("TextButton", TopBar)
        CloseBtn.Size = UDim2.new(0, 24, 0, 24)
        CloseBtn.Position = UDim2.new(1, -28, 0.5, -12)
        CloseBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
        CloseBtn.Text = "X"
        CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        CloseBtn.TextSize = 10
        CloseBtn.Font = Enum.Font.GothamBold
        Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

        CloseBtn.MouseButton1Click:Connect(function()
            MainFrame.Visible = false
            ToggleBtn.Visible = true
        end)

        print("Full Master Script with Original Engine + UI Loaded Successfully!")
    end)
    if not success then warn(err) end
end)
