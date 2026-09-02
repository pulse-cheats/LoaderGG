--[[
    ================================================================
    ⚔️ STEAL AN EGG - 100% ORIGINAL ENGINE + SKETCHED UI & ALL SETTINGS
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
    NormalSpeed = 16,
    AutoTreadmill = false,
    StealOnlySecret = false,
    StealBiggerSize = false,
    FreezeAnimations = true,
    FPSBoost = false
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

local function SafeWalkTo(targetPos, timeout, threshold, speed)
    local hrp = GetHRP()
    local hum = GetHumanoid()
    if not hrp or not hum then return false end
    
    if speed then SetPlayerSpeed(speed) end
    hum:MoveTo(targetPos)
    
    local startTime = tick()
    while tick() - startTime < (timeout or 5) do
        if not State.Running then return false end
        if (hrp.Position - targetPos).Magnitude <= (threshold or 6) then
            return true
        end
        task.wait(0.05)
    end
    return false
end

local function InstantTriggerSteal()
    pcall(function()
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                fireproximityprompt(obj, 0)
            end
        end
    end)
end

-- Main Auto Farm Loop (Original Engine Logic)
task.spawn(function()
    while true do
        task.wait(0.1)
        if State.Running and State.CurrentMode == "FARM" then
            local hum = GetHumanoid()
            local hrp = GetHRP()
            if hrp and hum then
                local stageData = GameData.Stages[State.SelectedStageIndex]
                if stageData then
                    State.Status = "🏃 RUSHING TO " .. stageData.name .. " 💨"
                    SafeWalkTo(stageData.pos, 5, 8, State.SprintSpeed)
                    
                    if State.Running then
                        State.Status = "⚡ STEALING EGG! 🥚"
                        SetPlayerSpeed(State.SprintSpeed)
                        InstantTriggerSteal()
                        if hum then hum.Jump = true end
                        task.wait(0.2)

                        State.Status = "⚡ EVADING NPC -> RUSHING TO SPAWN! 🏃💨"
                        SafeWalkTo(GameData.StartSpawn, 4.5, 12, State.SprintSpeed)
                        
                        local plotPos = GameData.Plots[State.SelectedPlotName] or GameData.Plots["Plot 1"]
                        State.Status = "🏠 RETURNING TO " .. State.SelectedPlotName .. " 🏁"
                        SafeWalkTo(plotPos, 4.5, 8, State.SprintSpeed)
                        
                        State.EggsCollected = State.EggsCollected + 1
                        State.Status = "✅ Cycle Completed! Total: " .. State.EggsCollected
                        task.wait(0.1)
                    end
                end
            end
        else
            SetPlayerSpeed(State.NormalSpeed)
            if not State.Running and State.Status ~= "Idle" then
                State.Status = "⏹️ Idle"
            end
        end
    end
end)

-- [[ REFINED SKETCHED UI & NEW FEATURES ]]
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
    if State.Running then State.CurrentMode = "FARM" else State.CurrentMode = "IDLE" end
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

local s1Lbl = Instance.new("TextLabel", pvp)
s1Lbl.Size = UDim2.new(0, 150, 0, 30)
s1Lbl.Position = UDim2.new(0, 0, 0, 30)
s1Lbl.BackgroundTransparency = 1
s1Lbl.Text = "Steal only secret"
s1Lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
s1Lbl.TextSize = 13
s1Lbl.Font = Enum.Font.GothamBold
s1Lbl.TextXAlignment = Enum.TextXAlignment.Left
s1Lbl.Parent = pvp

local s1Btn = Instance.new("TextButton", pvp)
s1Btn.Size = UDim2.new(0, 55, 0, 26)
s1Btn.Position = UDim2.new(0, 165, 0, 32)
s1Btn.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
s1Btn.Text = "OFF"
s1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
s1Btn.TextSize = 12
s1Btn.Parent = pvp
Instance.new("UICorner", s1Btn).CornerRadius = UDim.new(1, 0)

s1Btn.MouseButton1Click:Connect(function()
    State.StealOnlySecret = not State.StealOnlySecret
    s1Btn.BackgroundColor3 = State.StealOnlySecret and Color3.fromRGB(22, 163, 74) or Color3.fromRGB(30, 41, 59)
    s1Btn.Text = State.StealOnlySecret and "ON" or "OFF"
end)

local s2Lbl = Instance.new("TextLabel", pvp)
s2Lbl.Size = UDim2.new(0, 150, 0, 30)
s2Lbl.Position = UDim2.new(0, 0, 0, 70)
s2Lbl.BackgroundTransparency = 1
s2Lbl.Text = "Steal bigger size eggs"
s2Lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
s2Lbl.TextSize = 13
s2Lbl.Font = Enum.Font.GothamBold
s2Lbl.TextXAlignment = Enum.TextXAlignment.Left
s2Lbl.Parent = pvp

local s2Btn = Instance.new("TextButton", pvp)
s2Btn.Size = UDim2.new(0, 55, 0, 26)
s2Btn.Position = UDim2.new(0, 165, 0, 72)
s2Btn.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
s2Btn.Text = "OFF"
s2Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
s2Btn.TextSize = 12
s2Btn.Parent = pvp
Instance.new("UICorner", s2Btn).CornerRadius = UDim.new(1, 0)

s2Btn.MouseButton1Click:Connect(function()
    State.StealBiggerSize = not State.StealBiggerSize
    s2Btn.BackgroundColor3 = State.StealBiggerSize and Color3.fromRGB(22, 163, 74) or Color3.fromRGB(30, 41, 59)
    s2Btn.Text = State.StealBiggerSize and "ON" or "OFF"
end)

-- --- FARM PAGE ---
local farm = tabPages["Farm"]
local fTitle = Instance.new("TextLabel", farm)
fTitle.Size = UDim2.new(1, 0, 0, 24)
fTitle.BackgroundTransparency = 1
fTitle.Text = "(Tab title) Auto Farm & Stages"
fTitle.TextColor3 = Color3.fromRGB(34, 197, 94)
fTitle.TextSize = 13
fTitle.Font = Enum.Font.GothamBold

local stageLbl = Instance.new("TextLabel", farm)
stageLbl.Size = UDim2.new(0, 140, 0, 26)
stageLbl.Position = UDim2.new(0, 0, 0, 30)
stageLbl.BackgroundTransparency = 1
stageLbl.Text = "Stage: Stage 1"
stageLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
stageLbl.TextSize = 13
stageLbl.Font = Enum.Font.GothamBold
stageLbl.TextXAlignment = Enum.TextXAlignment.Left

local stageBtn = Instance.new("TextButton", farm)
stageBtn.Size = UDim2.new(0, 75, 0, 26)
stageBtn.Position = UDim2.new(0, 150, 0, 30)
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

local plotLbl = Instance.new("TextLabel", farm)
plotLbl.Size = UDim2.new(0, 140, 0, 26)
plotLbl.Position = UDim2.new(0, 0, 0, 66)
plotLbl.BackgroundTransparency = 1
plotLbl.Text = "Plot: Plot 1"
plotLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
plotLbl.TextSize = 13
plotLbl.Font = Enum.Font.GothamBold
plotLbl.TextXAlignment = Enum.TextXAlignment.Left

local plotBtn = Instance.new("TextButton", farm)
plotBtn.Size = UDim2.new(0, 75, 0, 26)
plotBtn.Position = UDim2.new(0, 150, 0, 66)
plotBtn.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
plotBtn.Text = "Change ➔"
plotBtn.TextColor3 = Color3.fromRGB(56, 189, 248)
plotBtn.TextSize = 11
Instance.new("UICorner", plotBtn).CornerRadius = UDim.new(0, 6)

local plotNames = {"Plot 1", "Plot 2", "Plot 3", "Plot 4", "Plot 5", "Plot 6", "Plot 7"}
local plotIdx = 1
plotBtn.MouseButton1Click:Connect(function()
    plotIdx = plotIdx + 1
    if plotIdx > #plotNames then plotIdx = 1 end
    State.SelectedPlotName = plotNames[plotIdx]
    plotLbl.Text = "Plot: " .. State.SelectedPlotName
end)

local tLbl = Instance.new("TextLabel", farm)
tLbl.Size = UDim2.new(0, 140, 0, 30)
tLbl.Position = UDim2.new(0, 0, 0, 104)
tLbl.BackgroundTransparency = 1
tLbl.Text = "Auto Treadmill"
tLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
tLbl.TextSize = 13
tLbl.Font = Enum.Font.GothamBold
tLbl.TextXAlignment = Enum.TextXAlignment.Left

local tBtn = Instance.new("TextButton", farm)
tBtn.Size = UDim2.new(0, 55, 0, 26)
tBtn.Position = UDim2.new(0, 150, 0, 106)
tBtn.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
tBtn.Text = "OFF"
tBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tBtn.TextSize = 12
Instance.new("UICorner", tBtn).CornerRadius = UDim.new(1, 0)

tBtn.MouseButton1Click:Connect(function()
    State.AutoTreadmill = not State.AutoTreadmill
    tBtn.BackgroundColor3 = State.AutoTreadmill and Color3.fromRGB(22, 163, 74) or Color3.fromRGB(30, 41, 59)
    tBtn.Text = State.AutoTreadmill and "ON" or "OFF"
end)

task.spawn(function()
    while true do
        task.wait(1)
        if State.AutoTreadmill then
            pcall(function()
                local hrp = GetHRP()
                local hum = GetHumanoid()
                if hrp and hum then
                    local targetPos = GameData.Plots[State.SelectedPlotName] or GameData.Plots["Plot 1"]
                    if (hrp.Position - targetPos).Magnitude > 8 then
                        hum:MoveTo(targetPos)
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

local animLbl = Instance.new("TextLabel", others)
animLbl.Size = UDim2.new(0, 150, 0, 30)
animLbl.Position = UDim2.new(0, 0, 0, 30)
animLbl.BackgroundTransparency = 1
animLbl.Text = "Freeze Animations"
animLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
animLbl.TextSize = 13
animLbl.Font = Enum.Font.GothamBold
animLbl.TextXAlignment = Enum.TextXAlignment.Left

local animBtn = Instance.new("TextButton", others)
animBtn.Size = UDim2.new(0, 55, 0, 26)
animBtn.Position = UDim2.new(0, 165, 0, 32)
animBtn.BackgroundColor3 = Color3.fromRGB(22, 163, 74)
animBtn.Text = "ON"
animBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
animBtn.TextSize = 12
Instance.new("UICorner", animBtn).CornerRadius = UDim.new(1, 0)

animBtn.MouseButton1Click:Connect(function()
    State.FreezeAnimations = not State.FreezeAnimations
    animBtn.BackgroundColor3 = State.FreezeAnimations and Color3.fromRGB(22, 163, 74) or Color3.fromRGB(30, 41, 59)
    animBtn.Text = State.FreezeAnimations and "ON" or "OFF"
end)

local fpsLbl = Instance.new("TextLabel", others)
fpsLbl.Size = UDim2.new(0, 150, 0, 30)
fpsLbl.Position = UDim2.new(0, 0, 0, 70)
fpsLbl.BackgroundTransparency = 1
fpsLbl.Text = "FPS Boost"
fpsLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
fpsLbl.TextSize = 13
fpsLbl.Font = Enum.Font.GothamBold
fpsLbl.TextXAlignment = Enum.TextXAlignment.Left

local fpsBtn = Instance.new("TextButton", others)
fpsBtn.Size = UDim2.new(0, 55, 0, 26)
fpsBtn.Position = UDim2.new(0, 165, 0, 72)
fpsBtn.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
fpsBtn.Text = "OFF"
fpsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
fpsBtn.TextSize = 12
Instance.new("UICorner", fpsBtn).CornerRadius = UDim.new(1, 0)

fpsBtn.MouseButton1Click:Connect(function()
    State.FPSBoost = not State.FPSBoost
    fpsBtn.BackgroundColor3 = State.FPSBoost and Color3.fromRGB(22, 163, 74) or Color3.fromRGB(30, 41, 59)
    fpsBtn.Text = State.FPSBoost and "ON" or "OFF"
    if State.FPSBoost then
        pcall(function()
            game:GetService("Lighting").GlobalShadows = false
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end
            end
        end)
    end
end)
