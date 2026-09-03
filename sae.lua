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



-- ================================================================
-- ⚔️ MASTER EXTENSION v2: LOADING BAR + COMBAT MODULES + WIKI (GitHub JSON)
-- ================================================================

task.spawn(function()
    local success, err = pcall(function()
        local CoreGui = game:GetService("CoreGui")
        local TweenService = game:GetService("TweenService")
        local HttpService = game:GetService("HttpService")
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

        -- Cleanup old UIs
        pcall(function()
            for _, child in ipairs(PlayerGui:GetChildren()) do
                if child.Name == "StealAnEggProUI" or child.Name == "StealEgg_Clean" then child:Destroy() end
            end
            if CoreGui then
                for _, child in ipairs(CoreGui:GetChildren()) do
                    if child.Name == "StealAnEggProUI" or child.Name == "StealEgg_Clean" then child:Destroy() end
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

        -- ================================================================
        -- 🌟 CLEAN COMPACT LOADING SCREEN WITH 0-100% PROGRESS BAR (7 SECONDS)
        -- ================================================================
        local LoadFrame = Instance.new("Frame", ScreenGui)
        LoadFrame.Size = UDim2.new(0, 340, 0, 140)
        LoadFrame.Position = UDim2.new(0.5, -170, 0.5, -70)
        LoadFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 18)
        LoadFrame.BorderSizePixel = 0
        LoadFrame.ZIndex = 50
        Instance.new("UICorner", LoadFrame).CornerRadius = UDim.new(0, 10)
        local LoadStroke = Instance.new("UIStroke", LoadFrame)
        LoadStroke.Color = Color3.fromRGB(139, 92, 246)
        LoadStroke.Thickness = 1.5

        local LoadTitle = Instance.new("TextLabel", LoadFrame)
        LoadTitle.Size = UDim2.new(1, 0, 0, 26)
        LoadTitle.Position = UDim2.new(0, 0, 0, 8)
        LoadTitle.BackgroundTransparency = 1
        LoadTitle.Text = "🥚 Steal An Egg - Loading..."
        LoadTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        LoadTitle.TextSize = 13
        LoadTitle.Font = Enum.Font.GothamBold
        LoadTitle.ZIndex = 51

        local LoadImage = Instance.new("ImageLabel", LoadFrame)
        LoadImage.Size = UDim2.new(0, 50, 0, 50)
        LoadImage.Position = UDim2.new(0.5, -25, 0, 36)
        LoadImage.BackgroundTransparency = 1
        LoadImage.Image = "https://raw.githubusercontent.com/Gkalimanis/StealAnEgg/main/assets/giphy-downsized-medium.gif"
        LoadImage.ZIndex = 51

        local BarBG = Instance.new("Frame", LoadFrame)
        BarBG.Size = UDim2.new(0, 280, 0, 16)
        BarBG.Position = UDim2.new(0.5, -140, 0, 96)
        BarBG.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
        BarBG.BorderSizePixel = 0
        BarBG.ZIndex = 52
        Instance.new("UICorner", BarBG).CornerRadius = UDim.new(1, 0)

        local BarFill = Instance.new("Frame", BarBG)
        BarFill.Size = UDim2.new(0, 0, 1, 0)
        BarFill.BackgroundColor3 = Color3.fromRGB(139, 92, 246)
        BarFill.BorderSizePixel = 0
        BarFill.ZIndex = 53
        Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

        local BarText = Instance.new("TextLabel", BarBG)
        BarText.Size = UDim2.new(1, 0, 1, 0)
        BarText.BackgroundTransparency = 1
        BarText.Text = "0%"
        BarText.TextColor3 = Color3.fromRGB(255, 255, 255)
        BarText.TextSize = 9
        BarText.Font = Enum.Font.GothamBold
        BarText.ZIndex = 54

        for i = 0, 100, 2 do
            BarFill.Size = UDim2.new(i / 100, 0, 1, 0)
            BarText.Text = i .. "%"
            task.wait(0.14)
        end
        task.wait(0.3)

        local fadeTween = TweenService:Create(LoadFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
        fadeTween:Play()
        TweenService:Create(LoadImage, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
        TweenService:Create(LoadTitle, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        TweenService:Create(BarBG, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        TweenService:Create(BarFill, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        TweenService:Create(BarText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        task.wait(0.5)
        LoadFrame:Destroy()

        -- ================================================================
        -- 🎮 ADDITIONAL STATE & MODULES
        -- ================================================================
        State.AutoPlotDetect = true
        State.AntiRagdoll = true
        State.NoAnimation = false
        State.EggESP = false
        State.SpeedModule = false
        State.TeleportModule = false
        State.InfiniteJump = false
        State.Noclip = false
        State.AntiAFK = true
        State.PetESP = false
        State.PlayerESP = false
        State.SafeWalk = true


        -- Auto Plot Detector (Smart Labels + Proximity)
        local function DetectMyPlot()
            local found = false
            pcall(function()
                local myName = tostring(LocalPlayer.Name):lower()
                local myDisplay = tostring(LocalPlayer.DisplayName):lower()

                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("TextLabel") or obj:IsA("BillboardGui") or obj:IsA("StringValue") then
                        local text = ""
                        if obj:IsA("TextLabel") then text = obj.Text or "" end
                        if obj:IsA("StringValue") then text = obj.Value or "" end
                        text = tostring(text):lower()
                        if text:find(myName) or text:find(myDisplay) then
                            local part = obj:FindFirstAncestorWhichIsA("BasePart") or obj:FindFirstAncestorWhichIsA("Model")
                            if part then
                                local pos = nil
                                if part:IsA("BasePart") then pos = part.Position end
                                if part:IsA("Model") and part.GetPivot then pos = part:GetPivot().Position end
                                if pos then
                                    local bestDist = 999999
                                    local bestPlot = "Plot 1"
                                    for pName, pPos in pairs(GameData.Plots) do
                                        local d = (pos - pPos).Magnitude
                                        if d < bestDist then
                                            bestDist = d
                                            bestPlot = pName
                                        end
                                    end
                                    State.SelectedPlotName = bestPlot
                                    found = true
                                    return
                                end
                            end
                        end
                    end
                end

                if not found then
                    local hrp = GetHRP()
                    if hrp then
                        local closest = "Plot 1"
                        local minDist = 999999
                        for pName, pPos in pairs(GameData.Plots) do
                            local dist = (hrp.Position - pPos).Magnitude
                            if dist < minDist then
                                minDist = dist
                                closest = pName
                            end
                        end
                        if minDist < 150 then
                            State.SelectedPlotName = closest
                            found = true
                        end
                    end
                end

                if not found then State.SelectedPlotName = "Plot 1" end
            end)
        end

        -- Anti-Ragdoll & No Animation Loop
        task.spawn(function()
            while true do
                task.wait(0.2)
                pcall(function()
                    local ch = GetChar()
                    if ch then
                        if State.AntiRagdoll then
                            for _, descendant in ipairs(ch:GetDescendants()) do
                                if descendant:IsA("BallSocketConstraint") or descendant.Name:lower():find("ragdoll") then
                                    descendant:Destroy()
                                end
                            end
                            local hum = GetHumanoid()
                            if hum then hum.PlatformStand = false end
                        end
                        if State.NoAnimation then
                            local hum = GetHumanoid()
                            if hum then
                                for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
                                    if track.Animation and track.Animation.AnimationId then
                                        local id = track.Animation.AnimationId:lower()
                                        if id:find("walk") or id:find("run") or id:find("move") or id:find("fall") then
                                            track:Stop()
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end)

        -- Extra Combat Loop (Bat Reach & Auto Equip & Kill Aura)
        State.BatKillAura = false
        State.AutoBlock = false
        State.CombatSpeed = false
        task.spawn(function()
            while true do
                task.wait(0.2)
                pcall(function()
                    if State.BatKillAura then
                        local hrp = GetHRP()
                        if hrp then
                            for _, p in ipairs(Players:GetPlayers()) do
                                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                    local d = (hrp.Position - p.Character.HumanoidRootPart.Position).Magnitude
                                    if d <= 18 then
                                        EquipBat()
                                        AttackWithBat()
                                    end
                                end
                            end
                        end
                    end
                    if State.CombatSpeed and State.CurrentMode == "PVP" and State.Running then
                        SetPlayerSpeed(State.SprintSpeed + 10)
                    end
                end)
            end
        end)


        -- Floating Toggle Button
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

        -- Main Compact Window Frame (470 x 330)
        local MainFrame = Instance.new("Frame", ScreenGui)
        MainFrame.Size = UDim2.new(0, 470, 0, 330)
        MainFrame.Position = UDim2.new(0.5, -235, 0.5, -165)
        MainFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 18)
        MainFrame.Visible = false
        Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
        local MainStroke = Instance.new("UIStroke", MainFrame)
        MainStroke.Color = Color3.fromRGB(139, 92, 246)
        MainStroke.Thickness = 1.2

        ToggleBtn.MouseButton1Click:Connect(function()
            MainFrame.Visible = true
            ToggleBtn.Visible = false
        end)

        -- Top Bar Header
        local TopBar = Instance.new("Frame", MainFrame)
        TopBar.Size = UDim2.new(1, 0, 0, 32)
        TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
        Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

        local TitleLbl = Instance.new("TextLabel", TopBar)
        TitleLbl.Size = UDim2.new(0, 240, 1, 0)
        TitleLbl.Position = UDim2.new(0, 10, 0, 0)
        TitleLbl.BackgroundTransparency = 1
        TitleLbl.Text = "Steal An Egg - Ultimate Pro"
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

        -- Left Sidebar Categories
        local Sidebar = Instance.new("ScrollingFrame", MainFrame)
        Sidebar.Size = UDim2.new(0, 120, 1, -32)
        Sidebar.Position = UDim2.new(0, 0, 0, 32)
        Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        Sidebar.BorderSizePixel = 0
        Sidebar.CanvasSize = UDim2.new(0, 0, 0, 220)
        Sidebar.ScrollBarThickness = 2

        local categories = {"Steal & Farm", "PvP Combat", "ESP & Visuals", "Pets Wiki"}
        local catButtons = {}
        local catPages = {}

        local ContentArea = Instance.new("Frame", MainFrame)
        ContentArea.Size = UDim2.new(1, -120, 1, -32)
        ContentArea.Position = UDim2.new(0, 120, 0, 32)
        ContentArea.BackgroundTransparency = 1

        for i, catName in ipairs(categories) do
            local cBtn = Instance.new("TextButton", Sidebar)
            cBtn.Size = UDim2.new(1, -6, 0, 28)
            cBtn.Position = UDim2.new(0, 3, 0, (i-1)*32 + 6)
            cBtn.BackgroundColor3 = (i == 1) and Color3.fromRGB(139, 92, 246) or Color3.fromRGB(20, 20, 28)
            cBtn.Text = " " .. catName
            cBtn.TextColor3 = (i == 1) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(156, 163, 175)
            cBtn.TextSize = 10
            cBtn.Font = Enum.Font.GothamBold
            cBtn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", cBtn).CornerRadius = UDim.new(0, 4)
            catButtons[catName] = cBtn

            local page = Instance.new("ScrollingFrame", ContentArea)
            page.Size = UDim2.new(1, 0, 1, 0)
            page.BackgroundTransparency = 1
            page.Visible = (i == 1)
            page.CanvasSize = UDim2.new(0, 0, 0, 380)
            page.ScrollBarThickness = 2
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

        local function CreateToggleRow(parent, labelText, defaultVal, callback, yPos)
            local row = Instance.new("Frame", parent)
            row.Size = UDim2.new(1, -12, 0, 26)
            row.Position = UDim2.new(0, 6, 0, yPos)
            row.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)

            local lbl = Instance.new("TextLabel", row)
            lbl.Size = UDim2.new(0, 160, 1, 0)
            lbl.Position = UDim2.new(0, 8, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = labelText
            lbl.TextColor3 = Color3.fromRGB(220, 220, 230)
            lbl.TextSize = 10
            lbl.Font = Enum.Font.GothamBold
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local tBtn = Instance.new("TextButton", row)
            tBtn.Size = UDim2.new(0, 36, 0, 16)
            tBtn.Position = UDim2.new(1, -40, 0.5, -8)
            tBtn.BackgroundColor3 = defaultVal and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(50, 50, 65)
            tBtn.Text = defaultVal and "ON" or "OFF"
            tBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            tBtn.TextSize = 8
            Instance.new("UICorner", tBtn).CornerRadius = UDim.new(1, 0)

            local active = defaultVal
            tBtn.MouseButton1Click:Connect(function()
                active = not active
                tBtn.BackgroundColor3 = active and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(50, 50, 65)
                tBtn.Text = active and "ON" or "OFF"
                callback(active)
            end)
            return row
        end


        -- --- 1. STEAL & FARM PAGE ---
        local farmPage = catPages["Steal & Farm"]
        CreateToggleRow(farmPage, "Auto Steal Eggs", false, function(v)
            State.Running = v
            if v then
                State.CurrentMode = "FARM"
                MainControllerLoop()
            end
        end, 6)

        -- Stage Selector Row
        local stageRow = Instance.new("Frame", farmPage)
        stageRow.Size = UDim2.new(1, -12, 0, 28)
        stageRow.Position = UDim2.new(0, 6, 0, 36)
        stageRow.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
        Instance.new("UICorner", stageRow).CornerRadius = UDim.new(0, 4)

        local sLbl = Instance.new("TextLabel", stageRow)
        sLbl.Size = UDim2.new(0, 100, 1, 0)
        sLbl.Position = UDim2.new(0, 8, 0, 0)
        sLbl.BackgroundTransparency = 1
        sLbl.Text = "Select Stage (1-11)"
        sLbl.TextColor3 = Color3.fromRGB(220, 220, 230)
        sLbl.TextSize = 10
        sLbl.Font = Enum.Font.GothamBold
        sLbl.TextXAlignment = Enum.TextXAlignment.Left

        local sValBtn = Instance.new("TextButton", stageRow)
        sValBtn.Size = UDim2.new(0, 95, 0, 20)
        sValBtn.Position = UDim2.new(1, -99, 0.5, -10)
        sValBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
        sValBtn.Text = GameData.Stages[State.SelectedStageIndex].name .. " ▾"
        sValBtn.TextColor3 = Color3.fromRGB(139, 92, 246)
        sValBtn.TextSize = 10
        sValBtn.Font = Enum.Font.GothamBold
        Instance.new("UICorner", sValBtn).CornerRadius = UDim.new(0, 4)

        sValBtn.MouseButton1Click:Connect(function()
            State.SelectedStageIndex = State.SelectedStageIndex + 1
            if State.SelectedStageIndex > #GameData.Stages then State.SelectedStageIndex = 1 end
            sValBtn.Text = GameData.Stages[State.SelectedStageIndex].name .. " ▾"
        end)

        -- Plot Selector Row
        local plotRow = Instance.new("Frame", farmPage)
        plotRow.Size = UDim2.new(1, -12, 0, 28)
        plotRow.Position = UDim2.new(0, 6, 0, 68)
        plotRow.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
        Instance.new("UICorner", plotRow).CornerRadius = UDim.new(0, 4)

        local pLbl = Instance.new("TextLabel", plotRow)
        pLbl.Size = UDim2.new(0, 100, 1, 0)
        pLbl.Position = UDim2.new(0, 8, 0, 0)
        pLbl.BackgroundTransparency = 1
        pLbl.Text = "Base Plot (1-7)"
        pLbl.TextColor3 = Color3.fromRGB(220, 220, 230)
        pLbl.TextSize = 10
        pLbl.Font = Enum.Font.GothamBold
        pLbl.TextXAlignment = Enum.TextXAlignment.Left

        local pValBtn = Instance.new("TextButton", plotRow)
        pValBtn.Size = UDim2.new(0, 95, 0, 20)
        pValBtn.Position = UDim2.new(1, -99, 0.5, -10)
        pValBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
        pValBtn.Text = State.SelectedPlotName .. " ▾"
        pValBtn.TextColor3 = Color3.fromRGB(56, 189, 248)
        pValBtn.TextSize = 10
        pValBtn.Font = Enum.Font.GothamBold
        Instance.new("UICorner", pValBtn).CornerRadius = UDim.new(0, 4)

        local plotNumber = 1
        pValBtn.MouseButton1Click:Connect(function()
            plotNumber = plotNumber + 1
            if plotNumber > 7 then plotNumber = 1 end
            State.SelectedPlotName = "Plot " .. plotNumber
            State.AutoPlotDetect = false
            pValBtn.Text = State.SelectedPlotName .. " ▾"
        end)

        CreateToggleRow(farmPage, "Auto Plot Detect", true, function(v)
            State.AutoPlotDetect = v
            if v then DetectMyPlot() end
        end, 100)

        CreateToggleRow(farmPage, "Anti-Ragdoll", true, function(v)
            State.AntiRagdoll = v
        end, 130)

        CreateToggleRow(farmPage, "No Animation", false, function(v)
            State.NoAnimation = v
        end, 160)

        CreateToggleRow(farmPage, "Speed Boost (+45)", false, function(v)
            State.SpeedModule = v
        end, 190)

        -- --- 2. PVP COMBAT PAGE (MORE MODULES) ---
        local pvpPage = catPages["PvP Combat"]
        CreateToggleRow(pvpPage, "PvP Stealer Mode", false, function(v)
            State.Running = v
            if v then
                State.CurrentMode = "PVP"
                MainControllerLoop()
            end
        end, 6)

        CreateToggleRow(pvpPage, "Bat Kill Aura (18 studs)", false, function(v)
            State.BatKillAura = v
        end, 36)

        CreateToggleRow(pvpPage, "Auto Equip Bat", true, function(v)
            State.AutoEquipBat = v
        end, 66)

        CreateToggleRow(pvpPage, "Combat Speed Boost", false, function(v)
            State.CombatSpeed = v
        end, 96)

        CreateToggleRow(pvpPage, "Steal Only Secret", false, function(v)
            State.StealOnlySecret = v
        end, 126)

        CreateToggleRow(pvpPage, "Steal Bigger Size", false, function(v)
            State.StealBiggerSize = v
        end, 156)

        -- --- 3. ESP & VISUALS PAGE (MORE MODULES) ---
        local espPage = catPages["ESP & Visuals"]
        CreateToggleRow(espPage, "Egg ESP (Highlight)", false, function(v)
            State.EggESP = v
            task.spawn(function()
                while State.EggESP do
                    pcall(function()
                        for _, obj in pairs(Workspace:GetDescendants()) do
                            if obj:IsA("BasePart") and (obj.Name:lower():find("egg") or obj.Name:lower():find("nest")) then
                                if not obj:FindFirstChild("SAE_EggESP") then
                                    local hl = Instance.new("Highlight", obj)
                                    hl.Name = "SAE_EggESP"
                                    hl.FillColor = Color3.fromRGB(168, 85, 247)
                                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                end
                            end
                        end
                    end)
                    task.wait(2)
                end
                pcall(function()
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj.Name == "SAE_EggESP" then obj:Destroy() end
                    end
                end)
            end)
        end, 6)

        CreateToggleRow(espPage, "Player ESP (Chams)", false, function(v)
            State.PlayerESP = v
            task.spawn(function()
                while State.PlayerESP do
                    pcall(function()
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p ~= LocalPlayer and p.Character then
                                if not p.Character:FindFirstChild("SAE_PlayerESP") then
                                    local hl = Instance.new("Highlight", p.Character)
                                    hl.Name = "SAE_PlayerESP"
                                    hl.FillColor = Color3.fromRGB(239, 68, 68)
                                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                end
                            end
                        end
                    end)
                    task.wait(2)
                end
                pcall(function()
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p.Character and p.Character:FindFirstChild("SAE_PlayerESP") then
                            p.Character.SAE_PlayerESP:Destroy()
                        end
                    end
                end)
            end)
        end, 36)

        CreateToggleRow(espPage, "Fullbright / No Fog", false, function(v)
            pcall(function()
                local Lighting = game:GetService("Lighting")
                Lighting.Brightness = v and 3 or 1
                Lighting.ClockTime = v and 14 or 12
                Lighting.FogEnd = v and 100000 or 1000
            end)
        end, 66)

        CreateToggleRow(espPage, "FPS Boost (Anti-Lag)", false, function(v)
            pcall(function()
                local Terrain = Workspace:FindFirstChildOfClass("Terrain")
                if Terrain then Terrain.WaterWaveSize = v and 0 or 0.1 end
            end)
        end, 96)

        -- --- 4. PETS WIKI PAGE (GITHUB DATABASE INTEGRATION) ---
        local petsPage = catPages["Pets Wiki"]
        local statusLbl = Instance.new("TextLabel", petsPage)
        statusLbl.Size = UDim2.new(1, -12, 0, 20)
        statusLbl.Position = UDim2.new(0, 6, 0, 4)
        statusLbl.BackgroundTransparency = 1
        statusLbl.Text = "Fetching live Pets Database from GitHub..."
        statusLbl.TextColor3 = Color3.fromRGB(168, 85, 247)
        statusLbl.TextSize = 10
        statusLbl.Font = Enum.Font.GothamBold

        local petsList = Instance.new("ScrollingFrame", petsPage)
        petsList.Size = UDim2.new(1, -12, 1, -28)
        petsList.Position = UDim2.new(0, 6, 0, 26)
        petsList.BackgroundTransparency = 1
        petsList.BorderSizePixel = 0
        petsList.CanvasSize = UDim2.new(0, 0, 0, 3000)
        petsList.ScrollBarThickness = 2

        task.spawn(function()
            local rawJson = nil
            local ok, res = pcall(function()
                return game:HttpGet("https://raw.githubusercontent.com/Gkalimanis/StealAnEgg/main/Pets_Database.json", true)
            end)
            if ok and res and #res > 20 then
                rawJson = res
            end

            if rawJson then
                local decodeOk, pets = pcall(function()
                    return HttpService:JSONDecode(rawJson)
                end)
                if decodeOk and pets and type(pets) == "table" then
                    statusLbl.Text = "Loaded " .. tostring(#pets) .. " Pets from GitHub DB"
                    statusLbl.TextColor3 = Color3.fromRGB(34, 197, 94)
                    local y = 0
                    for idx, pet in ipairs(pets) do
                        local card = Instance.new("Frame", petsList)
                        card.Size = UDim2.new(1, -4, 0, 24)
                        card.Position = UDim2.new(0, 2, 0, y)
                        card.BackgroundColor3 = (idx % 2 == 0) and Color3.fromRGB(16, 16, 24) or Color3.fromRGB(22, 22, 32)
                        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 4)

                        local nameLbl = Instance.new("TextLabel", card)
                        nameLbl.Size = UDim2.new(0.4, 0, 1, 0)
                        nameLbl.Position = UDim2.new(0, 6, 0, 0)
                        nameLbl.BackgroundTransparency = 1
                        nameLbl.Text = tostring(pet.name or "Pet") .. " (" .. tostring(pet.rarity or "Common") .. ")"
                        nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                        nameLbl.TextSize = 9
                        nameLbl.Font = Enum.Font.GothamBold
                        nameLbl.TextXAlignment = Enum.TextXAlignment.Left

                        local statsLbl = Instance.new("TextLabel", card)
                        statsLbl.Size = UDim2.new(0.55, 0, 1, 0)
                        statsLbl.Position = UDim2.new(0.42, 0, 0, 0)
                        statsLbl.BackgroundTransparency = 1
                        statsLbl.Text = tostring(pet.biome or "") .. " | MPS: " .. tostring(pet.mps or "") .. " | " .. tostring(pet.price or "")
                        statsLbl.TextColor3 = Color3.fromRGB(156, 163, 175)
                        statsLbl.TextSize = 8
                        statsLbl.Font = Enum.Font.Gotham
                        statsLbl.TextXAlignment = Enum.TextXAlignment.Right

                        y = y + 26
                    end
                    petsList.CanvasSize = UDim2.new(0, 0, 0, y + 10)
                else
                    statusLbl.Text = "Failed to parse JSON DB"
                    statusLbl.TextColor3 = Color3.fromRGB(239, 68, 68)
                end
            else
                statusLbl.Text = "Could not fetch DB from GitHub"
                statusLbl.TextColor3 = Color3.fromRGB(239, 68, 68)
            end
        end)

        
        -- ================================================================
        -- 🔑 KEY SYSTEM WINDOW (Appears after Loading Screen)
        -- ================================================================
        local KeyFrame = Instance.new("Frame", ScreenGui)
        KeyFrame.Size = UDim2.new(0, 360, 0, 190)
        KeyFrame.Position = UDim2.new(0.5, -180, 0.5, -95)
        KeyFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 18)
        KeyFrame.BorderSizePixel = 0
        KeyFrame.Visible = true
        Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 10)
        local KeyStroke = Instance.new("UIStroke", KeyFrame)
        KeyStroke.Color = Color3.fromRGB(139, 92, 246)
        KeyStroke.Thickness = 1.5

        local KeyTitle = Instance.new("TextLabel", KeyFrame)
        KeyTitle.Size = UDim2.new(1, 0, 0, 30)
        KeyTitle.Position = UDim2.new(0, 0, 0, 8)
        KeyTitle.BackgroundTransparency = 1
        KeyTitle.Text = "🔑 Steal An Egg - Key System"
        KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        KeyTitle.TextSize = 13
        KeyTitle.Font = Enum.Font.GothamBold

        local KeySub = Instance.new("TextLabel", KeyFrame)
        KeySub.Size = UDim2.new(1, 0, 0, 18)
        KeySub.Position = UDim2.new(0, 0, 0, 34)
        KeySub.BackgroundTransparency = 1
        KeySub.Text = "Enter your key to unlock the script."
        KeySub.TextColor3 = Color3.fromRGB(156, 163, 175)
        KeySub.TextSize = 10
        KeySub.Font = Enum.Font.Gotham

        local KeyInput = Instance.new("TextBox", KeyFrame)
        KeyInput.Size = UDim2.new(1, -30, 0, 34)
        KeyInput.Position = UDim2.new(0, 15, 0, 58)
        KeyInput.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
        KeyInput.BorderSizePixel = 0
        KeyInput.PlaceholderText = "Paste key here..."
        KeyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
        KeyInput.Text = ""
        KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
        KeyInput.TextSize = 10
        KeyInput.Font = Enum.Font.Gotham
        KeyInput.ClearTextOnFocus = false
        Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 6)

        local KeyStatus = Instance.new("TextLabel", KeyFrame)
        KeyStatus.Size = UDim2.new(1, -30, 0, 16)
        KeyStatus.Position = UDim2.new(0, 15, 0, 96)
        KeyStatus.BackgroundTransparency = 1
        KeyStatus.Text = ""
        KeyStatus.TextColor3 = Color3.fromRGB(239, 68, 68)
        KeyStatus.TextSize = 9
        KeyStatus.Font = Enum.Font.GothamBold

        local VerifyBtn = Instance.new("TextButton", KeyFrame)
        VerifyBtn.Size = UDim2.new(0.46, 0, 0, 32)
        VerifyBtn.Position = UDim2.new(0, 15, 1, -44)
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(139, 92, 246)
        VerifyBtn.Text = "Verify Key"
        VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        VerifyBtn.TextSize = 11
        VerifyBtn.Font = Enum.Font.GothamBold
        Instance.new("UICorner", VerifyBtn).CornerRadius = UDim.new(0, 6)

        local GetLinkBtn = Instance.new("TextButton", KeyFrame)
        GetLinkBtn.Size = UDim2.new(0.46, 0, 0, 32)
        GetLinkBtn.Position = UDim2.new(0.54, 0, 1, -44)
        GetLinkBtn.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
        GetLinkBtn.Text = "Get Link"
        GetLinkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        GetLinkBtn.TextSize = 11
        GetLinkBtn.Font = Enum.Font.GothamBold
        Instance.new("UICorner", GetLinkBtn).CornerRadius = UDim.new(0, 6)

        local ValidKey = "user45566677788777877788_keyid7882828282929299292!7282882288228true"

        VerifyBtn.MouseButton1Click:Connect(function()
            local rawInput = KeyInput.Text or ""
            local cleaned = rawInput:gsub("^%s*(.-)%s*$", "%1")
            if cleaned == ValidKey then
                KeyStatus.Text = "Key Validated! Welcome."
                KeyStatus.TextColor3 = Color3.fromRGB(34, 197, 94)
                task.wait(0.5)
                KeyFrame:Destroy()
                MainFrame.Visible = true
            else
                KeyStatus.Text = "Invalid Key! Please try again."
                KeyStatus.TextColor3 = Color3.fromRGB(239, 68, 68)
            end
        end)

        GetLinkBtn.MouseButton1Click:Connect(function()
            local link = "https://rvstudios-keysystem.netlify.app"
            pcall(function()
                if setclipboard then
                    setclipboard(link)
                elseif toclipboard then
                    toclipboard(link)
                end
            end)
            KeyStatus.Text = "Link copied to clipboard!"
            KeyStatus.TextColor3 = Color3.fromRGB(56, 189, 248)
        end)

        print("Steal An Egg Ultimate Master Script Loaded Successfully!")
    end)
    if not success then
        warn("Error:", err)
    end
end)
