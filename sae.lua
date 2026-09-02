
--[[    ================================================================
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
-- 🐾 PETS DATABASE JSON (DECODED SAFELY)
-- ================================================================
local HttpService = game:GetService("HttpService")
local PetsJsonString = [[[
  {
    "biome": "Forest",
    "name": "Chicken",
    "image": "Chicken Steal Egg.png",
    "rarity": "Common",
    "mps": "$1/s",
    "speed": "+420 Speed",
    "price": "$100"
  },
  {
    "biome": "Forest",
    "name": "Dog",
    "image": "Dog Steal Egg.png",
    "rarity": "Common",
    "mps": "$2/s",
    "speed": "+460 Speed",
    "price": "$200"
  },
  {
    "biome": "Forest",
    "name": "Bird",
    "image": "Bird Steal Egg.png",
    "rarity": "Uncommon",
    "mps": "$8/s",
    "speed": "+500 Speed",
    "price": "$800"
  },
  {
    "biome": "Forest",
    "name": "Owl",
    "image": "Owl Steal Egg.png",
    "rarity": "Rare",
    "mps": "$35/s",
    "speed": "+560 Speed",
    "price": "$3.5k"
  },
  {
    "biome": "Forest",
    "name": "Raccoon",
    "image": "Raccoon Steal Egg.png",
    "rarity": "Rare",
    "mps": "$45/s",
    "speed": "+620 Speed",
    "price": "$4.5k"
  },
  {
    "biome": "Forest",
    "name": "Bear",
    "image": "Bear Steal Egg.png",
    "rarity": "Epic",
    "mps": "$240/s",
    "speed": "+820 Speed",
    "price": "$24k"
  },
  {
    "biome": "Forest",
    "name": "Fox",
    "image": "Fox Steal Egg.png",
    "rarity": "Epic",
    "mps": "$180/s",
    "speed": "+720 Speed",
    "price": "$18k"
  },
  {
    "biome": "Forest",
    "name": "Brr Brr Patapim",
    "image": "Brr Steal Egg.png",
    "rarity": "Legendary",
    "mps": "$1.8k/s",
    "speed": "+1k Speed",
    "price": "$180k"
  },
  {
    "biome": "Lake",
    "name": "Frog",
    "image": "Frog Steal Egg.png",
    "rarity": "Common",
    "mps": "$3/s",
    "speed": "+2k Speed",
    "price": "$300"
  },
  {
    "biome": "Lake",
    "name": "Duckling",
    "image": "Duckling Steal Egg.png",
    "rarity": "Common",
    "mps": "$4/s",
    "speed": "+2.2k Speed",
    "price": "$400"
  },
  {
    "biome": "Lake",
    "name": "Catfish",
    "image": "Catfish Steal Egg.png",
    "rarity": "Uncommon",
    "mps": "$12/s",
    "speed": "+2.5k Speed",
    "price": "$1.2k"
  },
  {
    "biome": "Lake",
    "name": "Turtle",
    "image": "Turtle Steal Egg.png",
    "rarity": "Rare",
    "mps": "$60/s",
    "speed": "+2.7k Speed",
    "price": "$6k"
  },
  {
    "biome": "Lake",
    "name": "Trulimero Trulicina",
    "image": "Trulimero Steal Egg.png",
    "rarity": "Epic",
    "mps": "$260/s",
    "speed": "+3k Speed",
    "price": "$26k"
  },
  {
    "biome": "Lake",
    "name": "Swan",
    "image": "Swan Steal Egg.png",
    "rarity": "Epic",
    "mps": "$320/s",
    "speed": "+3.5k Speed",
    "price": "$32k"
  },
  {
    "biome": "Lake",
    "name": "Axolotl",
    "image": "Axolotl Steal Egg.png",
    "rarity": "Legendary",
    "mps": "$2.8k/s",
    "speed": "+4k Speed",
    "price": "$280k"
  },
  {
    "biome": "Lake",
    "name": "Leviathan",
    "image": "Leviathan Steal Egg.png",
    "rarity": "Cosmic",
    "mps": "$220k/s",
    "speed": "+5k Speed",
    "price": "$22m"
  },
  {
    "biome": "Desert",
    "name": "Jerboa",
    "image": "Jerboa Steal Egg.png",
    "rarity": "Common",
    "mps": "$6/s",
    "speed": "+7.2k Speed",
    "price": "$600"
  },
  {
    "biome": "Desert",
    "name": "Fennec",
    "image": "Fennec Steal Egg.png",
    "rarity": "Uncommon",
    "mps": "$18/s",
    "speed": "+8.1k Speed",
    "price": "$1.8k"
  },
  {
    "biome": "Desert",
    "name": "Camel",
    "image": "Camel Steal Egg.png",
    "rarity": "Rare",
    "mps": "$75/s",
    "speed": "+9k Speed",
    "price": "$7.5k"
  },
  {
    "biome": "Desert",
    "name": "Tob Tobi Tob Tob",
    "image": "Tob Steal Egg.png",
    "rarity": "Epic",
    "mps": "$325/s",
    "speed": "+9.9k Speed",
    "price": "$32.5k"
  },
  {
    "biome": "Desert",
    "name": "Snake",
    "image": "Snake Steal Egg.png",
    "rarity": "Legendary",
    "mps": "$3.6k/s",
    "speed": "+10.8k Speed",
    "price": "$360k"
  },
  {
    "biome": "Desert",
    "name": "Scorpion",
    "image": "Scorpion Steal Egg.png",
    "rarity": "Mythic",
    "mps": "$18.5k/s",
    "speed": "+14.4k Speed",
    "price": "$1.8m"
  },
  {
    "biome": "Desert",
    "name": "Sand Spider",
    "image": "Sand Spider Steal Egg.png",
    "rarity": "Mythic",
    "mps": "$16k/s",
    "speed": "+12.6k Speed",
    "price": "$1.6m"
  },
  {
    "biome": "Desert",
    "name": "Royal Sphinx",
    "image": "Royal Sphinx Steal Egg.png",
    "rarity": "Cosmic",
    "mps": "$280k/s",
    "speed": "+18k Speed",
    "price": "$28m"
  },
  {
    "biome": "Jungle",
    "name": "Toucan",
    "image": "Toucan Steal Egg.png",
    "rarity": "Rare",
    "mps": "$110/s",
    "speed": "+8.1k Speed",
    "price": "$11k"
  },
  {
    "biome": "Jungle",
    "name": "Chimpanzee",
    "image": "Chimpanzee Steal Egg.png",
    "rarity": "Rare",
    "mps": "$90/s",
    "speed": "+7.2k Speed",
    "price": "$9k"
  },
  {
    "biome": "Jungle",
    "name": "Crocodile",
    "image": "Crocodile Steal Egg.png",
    "rarity": "Epic",
    "mps": "$420/s",
    "speed": "+9k Speed",
    "price": "$42k"
  },
  {
    "biome": "Jungle",
    "name": "Gorilla",
    "image": "Gorilla Steal Egg.png",
    "rarity": "Legendary",
    "mps": "$4.8k/s",
    "speed": "+9.9k Speed",
    "price": "$480k"
  },
  {
    "biome": "Jungle",
    "name": "Orangutini Ananassini",
    "image": "Orangutini Steal Egg.png",
    "rarity": "Legendary",
    "mps": "$5.5k/s",
    "speed": "+10.8k Speed",
    "price": "$550k"
  },
  {
    "biome": "Jungle",
    "name": "Spider",
    "image": "Spider Steal Egg.png",
    "rarity": "Mythic",
    "mps": "$22k/s",
    "speed": "+12.6k Speed",
    "price": "$2.2m"
  },
  {
    "biome": "Jungle",
    "name": "Tiger",
    "image": "Tiger Steal Egg.png",
    "rarity": "Mythic",
    "mps": "$28k/s",
    "speed": "+14.4k Speed",
    "price": "$2.8m"
  },
  {
    "biome": "Jungle",
    "name": "King Snake",
    "image": "King Snake Steal Egg.png",
    "rarity": "Secret",
    "mps": "$3.5m/s",
    "speed": "+18k Speed",
    "price": "$350m"
  },
  {
    "biome": "Snow",
    "name": "Penguin",
    "image": "Penguin Steal Egg.png",
    "rarity": "Rare",
    "mps": "$140/s",
    "speed": "+12.8k Speed",
    "price": "$14k"
  },
  {
    "biome": "Snow",
    "name": "Walrus",
    "image": "Walrus Steal Egg.png",
    "rarity": "Epic",
    "mps": "$600/s",
    "speed": "+14.4k Speed",
    "price": "$60k"
  },
  {
    "biome": "Snow",
    "name": "Polar Bear",
    "image": "Polar Bear Steal Egg.png",
    "rarity": "Legendary",
    "mps": "$7k/s",
    "speed": "+16k Speed",
    "price": "$700k"
  },
  {
    "biome": "Snow",
    "name": "Sabertooth Tiger",
    "image": "Sabertooth Steal Egg.png",
    "rarity": "Mythic",
    "mps": "$35k/s",
    "speed": "+17.6k Speed",
    "price": "$3.5m"
  },
  {
    "biome": "Snow",
    "name": "Mammoth",
    "image": "Mammoth Steal Egg.png",
    "rarity": "Mythic",
    "mps": "$42k/s",
    "speed": "+19.2k Speed",
    "price": "$4.2m"
  },
  {
    "biome": "Snow",
    "name": "King Mammoth",
    "image": "King Mammoth Steal Egg.png",
    "rarity": "Cosmic",
    "mps": "$400k/s",
    "speed": "+22.4k Speed",
    "price": "$40m"
  },
  {
    "biome": "Snow",
    "name": "Yeti",
    "image": "Yeti Steal Egg.png",
    "rarity": "Secret",
    "mps": "$5m/s",
    "speed": "+25.6k Speed",
    "price": "$500m"
  },
  {
    "biome": "Snow",
    "name": "Ice Dragon",
    "image": "Ice Dragon Steal Egg.png",
    "rarity": "Eternal",
    "mps": "$65m/s",
    "speed": "+32k Speed",
    "price": "$6.5b"
  },
  {
    "biome": "Volcano",
    "name": "Lava Gecko",
    "image": "Lava Gecko Steal Egg.png",
    "rarity": "Rare",
    "mps": "$180/s",
    "speed": "+24k Speed",
    "price": "$18k"
  },
  {
    "biome": "Volcano",
    "name": "Lava Frog",
    "image": "Lava Frog Steal Egg.png",
    "rarity": "Epic",
    "mps": "$850/s",
    "speed": "+27k Speed",
    "price": "$85k"
  },
  {
    "biome": "Volcano",
    "name": "Flaming Bull",
    "image": "Flaming Bull Steal Egg.png",
    "rarity": "Legendary",
    "mps": "$9.5k/s",
    "speed": "+30k Speed",
    "price": "$950k"
  },
  {
    "biome": "Volcano",
    "name": "Lava Iguana",
    "image": "Lava Iguana Steal Egg.png",
    "rarity": "Legendary",
    "mps": "$11k/s",
    "speed": "+36k Speed",
    "price": "$1.1m"
  },
  {
    "biome": "Volcano",
    "name": "Chillin Chilli",
    "image": "Chillin Chili Steal Egg.png",
    "rarity": "Mythic",
    "mps": "$55k/s",
    "speed": "+33k Speed",
    "price": "$5.5m"
  },
  {
    "biome": "Volcano",
    "name": "Cerberus",
    "image": "Cerberus Steal Egg.png",
    "rarity": "Secret",
    "mps": "$8m/s",
    "speed": "+42k Speed",
    "price": "$800m"
  },
  {
    "biome": "Volcano",
    "name": "Phoenix",
    "image": "Phoenix Steal Egg.png",
    "rarity": "Eternal",
    "mps": "85m/s",
    "speed": "+48k Speed",
    "price": "$8.5b"
  },
  {
    "biome": "Volcano",
    "name": "Lava Dragon",
    "image": "Lava Dragon Steal Egg.png",
    "rarity": "Eternal",
    "mps": "$100m/s",
    "speed": "+60k Speed",
    "price": "$10b"
  },
  {
    "biome": "Abyss Ocean",
    "name": "Parrotfish",
    "image": "Parrotfish Steal Egg.png",
    "rarity": "Rare",
    "mps": "$220/s",
    "speed": "+72k Speed",
    "price": "$22k"
  },
  {
    "biome": "Abyss Ocean",
    "name": "Swordfish",
    "image": "Swordfish Steal Egg.png",
    "rarity": "Epic",
    "mps": "$1.1k/s",
    "speed": "+81k Speed",
    "price": "$110k"
  },
  {
    "biome": "Abyss Ocean",
    "name": "Shark",
    "image": "Shark Steal Egg.png",
    "rarity": "Legendary",
    "mps": "$15k/s",
    "speed": "+90k Speed",
    "price": "$1.5m"
  },
  {
    "biome": "Abyss Ocean",
    "name": "Orca",
    "image": "Orca Steal Egg.png",
    "rarity": "Mythic",
    "mps": "$80k/s",
    "speed": "+99k Speed",
    "price": "$8m"
  },
  {
    "biome": "Abyss Ocean",
    "name": "Whale Shark",
    "image": "Whale Shark Steal EGg.png",
    "rarity": "Cosmic",
    "mps": "$700k/s",
    "speed": "+108k Speed",
    "price": "$70m"
  },
  {
    "biome": "Abyss Ocean",
    "name": "Beluga Whale",
    "image": "Beluga Whale Steal Egg.png",
    "rarity": "Cosmic",
    "mps": "$850k/s",
    "speed": "+126k Speed",
    "price": "$85m"
  },
  {
    "biome": "Abyss Ocean",
    "name": "Kraken",
    "image": "Kraken Steal Egg.png",
    "rarity": "Secret",
    "mps": "$15m/s",
    "speed": "+144k Speed",
    "price": "$1.5b"
  },
  {
    "biome": "Abyss Ocean",
    "name": "El Maja",
    "image": "El Maja Steal Egg.png",
    "rarity": "Eternal",
    "mps": "$130m/s",
    "speed": "+180k Speed",
    "price": "$13b"
  },
  {
    "biome": "Prehistoric",
    "name": "Dodo",
    "image": "Dodo Steal Egg.png",
    "rarity": "Rare",
    "mps": "+280/s",
    "speed": "+240k Speed",
    "price": "$28k"
  },
  {
    "biome": "Prehistoric",
    "name": "Pterodactyl",
    "image": "Pterodactyl Steal Egg.png",
    "rarity": "Legendary",
    "mps": "+22k/s",
    "speed": "+270k Speed",
    "price": "$2.2m"
  },
  {
    "biome": "Prehistoric",
    "name": "Ankylosaurus",
    "image": "Ankylosaurus Steal Egg.png",
    "rarity": "Mythic",
    "mps": "$120k/s",
    "speed": "+330k Speed",
    "price": "$12m"
  },
  {
    "biome": "Prehistoric",
    "name": "Triceratops",
    "image": "Triceratops Steal Egg.png",
    "rarity": "Cosmic",
    "mps": "$1.2m/s",
    "speed": "+360k Speed",
    "price": "$120m"
  },
  {
    "biome": "Prehistoric",
    "name": "Bronto",
    "image": "Bronto Steal Egg.png",
    "rarity": "Cosmic",
    "mps": "$1.5m/s",
    "speed": "+300k Speed",
    "price": "$150m"
  },
  {
    "biome": "Prehistoric",
    "name": "Tralaledon",
    "image": "Tralaledon Steal Egg.png",
    "rarity": "Secret",
    "mps": "$32m/s",
    "speed": "+480k Speed",
    "price": "$3.2b"
  },
  {
    "biome": "Prehistoric",
    "name": "TRex",
    "image": "TRex Steal Egg.png",
    "rarity": "Secret",
    "mps": "$25m/s",
    "speed": "+420k Speed",
    "price": "$2.5b"
  },
  {
    "biome": "Prehistoric",
    "name": "Mosasaurus",
    "image": "Mosasaurus Steal Egg.png",
    "rarity": "Eternal",
    "mps": "$180m/s",
    "speed": "+600k Speed",
    "price": "$18b"
  },
  {
    "biome": "Cosmic",
    "name": "Centapede",
    "image": "Centapede Steal Egg.png",
    "rarity": "Epic",
    "mps": "$1.5k/s",
    "speed": "+960k Speed",
    "price": "$150k"
  },
  {
    "biome": "Cosmic",
    "name": "Cosmic Gecko",
    "image": "Cosmic Gecko Steal Egg.png",
    "rarity": "Legendary",
    "mps": "$30k/s",
    "speed": "+1m Speed",
    "price": "$3m"
  },
  {
    "biome": "Cosmic",
    "name": "Cosmic Gorilla",
    "image": "Cosmic Gorilla Steal Egg.png",
    "rarity": "Mythic",
    "mps": "$180k/s",
    "speed": "+1.2m Speed",
    "price": "$18m"
  },
  {
    "biome": "Cosmic",
    "name": "La Vacca Saturno Saturnita",
    "image": "La Vacca Steal Egg.png",
    "rarity": "Cosmic",
    "mps": "$2.2m/s",
    "speed": "+1.3m Speed",
    "price": "Cosmic"
  },
  {
    "biome": "Cosmic",
    "name": "Cosmic Dragon",
    "image": "Cosmic Dragon Steal Egg.png",
    "rarity": "Secret",
    "mps": "$60m/s",
    "speed": "+1.4m Speed",
    "price": "$6b"
  },
  {
    "biome": "Cosmic",
    "name": "Cosmic Skeleton Boss",
    "image": "Cosmic Skeleton Steal Egg.png",
    "rarity": "Secret",
    "mps": "$45m/s",
    "speed": "+1.6m Speed",
    "price": "$4.5b"
  },
  {
    "biome": "Cosmic",
    "name": "Eternal Lunar Dragon",
    "image": "Eternal Lunar Dragon Steal Egg.png",
    "rarity": "Eternal",
    "mps": "$250m/s",
    "speed": "+1.9m Speed",
    "price": "$25b"
  },
  {
    "biome": "Cosmic",
    "name": "Unicorn",
    "image": "Unicorn Steal Egg.png",
    "rarity": "Divine",
    "mps": "$1b/s",
    "speed": "+2.4m Speed",
    "price": "$100b"
  },
  {
    "biome": "Cherry Blossom",
    "name": "Crane",
    "image": "Crane Steal Egg.png",
    "rarity": "Epic",
    "mps": "$4k/s",
    "speed": "+2.7m Speed",
    "price": "$400k"
  },
  {
    "biome": "Cherry Blossom",
    "name": "Salamander",
    "image": "Salamander Steal Egg.png",
    "rarity": "Legendary",
    "mps": "$74k/s",
    "speed": "+3m Speed$7.4m",
    "price": "Cherry Blossom"
  },
  {
    "biome": "Cherry Blossom",
    "name": "Red Panda",
    "image": "Red Panda Steal Egg.png",
    "rarity": "Mythic",
    "mps": "450k/s",
    "speed": "+3.4m Speed",
    "price": "$45m"
  },
  {
    "biome": "Cherry Blossom",
    "name": "Koi",
    "image": "Koi Steal Egg.png",
    "rarity": "Cosmic",
    "mps": "$12m/s",
    "speed": "+4.2m Speed",
    "price": "$1.2b"
  },
  {
    "biome": "Cherry Blossom",
    "name": "Snowy Owl",
    "image": "Snowy Owl Steal Egg.png",
    "rarity": "Cosmic",
    "mps": "$7.5m/s",
    "speed": "+3.7m Speed",
    "price": "$750m"
  },
  {
    "biome": "Cherry Blossom",
    "name": "Stag",
    "image": "Stag Steal Egg.png",
    "rarity": "Secret",
    "mps": "$145m/s",
    "speed": "+4.8m Speed",
    "price": "$14.5b"
  },
  {
    "biome": "Cherry Blossom",
    "name": "Oni Tiger",
    "image": "Oni Tiger Steal Egg.png",
    "rarity": "Eternal",
    "mps": "$600m/s",
    "speed": "+5.4m Speed",
    "price": "$60b"
  },
  {
    "biome": "Cherry Blossom",
    "name": "Kitsune",
    "rarity": "Divine",
    "mps": "$1.8b/s",
    "speed": "+6.5m Speed",
    "price": "$180b"
  },
  {
    "biome": "Titan Temple",
    "name": "Crustacia",
    "image": "Crustacia Steal Egg.png",
    "rarity": "Legendary",
    "mps": "$130K/s",
    "speed": "+2.7m Speed",
    "price": "$13m"
  },
  {
    "biome": "Titan Temple",
    "name": "Spideron",
    "image": "Spideron Steal Egg.png",
    "rarity": "Legendary",
    "mps": "$95K/s",
    "speed": "+2.7m Speed",
    "price": "$13m"
  },
  {
    "biome": "Titan Temple",
    "name": "Bladehide",
    "image": "Bladehide Steal Egg.png",
    "rarity": "Mythic",
    "mps": "$750K/s",
    "speed": "+4.8m Speed",
    "price": "$75m"
  },
  {
    "biome": "Titan Temple",
    "name": "Mantaris",
    "image": "Mantaris Steal Egg.png",
    "rarity": "Cosmic",
    "mps": "$11M/s",
    "speed": "+3.4m Speed",
    "price": "$1.1b"
  },
  {
    "biome": "Titan Temple",
    "name": "Rhinotaur",
    "image": "Rhinotaur Steal Egg.png",
    "rarity": "Cosmic",
    "mps": "$17.5M/s",
    "speed": "+3m Speed",
    "price": "$1.7b"
  },
  {
    "biome": "Titan Temple",
    "name": "Mutant Shark",
    "image": "Mutant Shark Steal Egg.png",
    "rarity": "Secret",
    "mps": "$215M/s",
    "speed": "+4.1m Speed",
    "price": "$21.5b"
  },
  {
    "biome": "Titan Temple",
    "name": "Gorilla King",
    "image": "Gorilla King Steal Egg.png",
    "rarity": "Eternal",
    "mps": "$880M/s",
    "speed": "+5.4m Speed",
    "price": "$88b"
  },
  {
    "biome": "Brainrot Eggs",
    "name": "Tung Tung Sahur",
    "image": "Tung Steal Egg.png",
    "rarity": "Rare",
    "mps": "Unknown",
    "speed": "+640 Speed",
    "price": "$10k"
  },
  {
    "biome": "Brainrot Eggs",
    "name": "Bananita Dolphinita",
    "image": "Bananita Steal Egg.png",
    "rarity": "Epic",
    "mps": "Unknown",
    "speed": "+710 Speed",
    "price": "$40k"
  },
  {
    "biome": "Brainrot Eggs",
    "name": "Belula Beluga",
    "image": "Belula Steal Egg.png",
    "rarity": "Mythic",
    "mps": "Unknown",
    "speed": "+2.5k Speed",
    "price": "$4m"
  },
  {
    "biome": "Brainrot Eggs",
    "name": "Mangolini Parrochini",
    "image": "Mangolini Steal Egg.png",
    "rarity": "Cosmic",
    "mps": "Unknown",
    "speed": "+267k Speed",
    "price": "$80m"
  },
  {
    "biome": "Brainrot Eggs",
    "name": "Bomboclat Crocolat",
    "image": "Bomboclat Steal Egg.png",
    "rarity": "Secret",
    "mps": "Unknown",
    "speed": "+860k Speed",
    "price": "$2b"
  },
  {
    "biome": "Brainrot Eggs",
    "name": "Strawberry Elephant",
    "image": "Strawberry Elephant Steal Egg.png",
    "rarity": "Eternal",
    "mps": "Unknown",
    "speed": "+143k Speed",
    "price": "$11b"
  },
  {
    "biome": "Monster Eggs",
    "name": "Scorpio",
    "image": "Scorpio Steal Egg.png",
    "rarity": "Legendary",
    "mps": "Unknown",
    "speed": "+0 Speed",
    "price": "$1m"
  },
  {
    "biome": "Monster Eggs",
    "name": "Froggo",
    "image": "Froggo Steal Egg.png",
    "rarity": "Mythic",
    "mps": "Unknown",
    "speed": "+0 Speed",
    "price": "$5"
  },
  {
    "biome": "Monster Eggs",
    "name": "Crawler",
    "image": "Crawler Steal Egg.png",
    "rarity": "Cosmic",
    "mps": "Unknown",
    "speed": "+0 Speed",
    "price": "$150m"
  },
  {
    "biome": "Monster Eggs",
    "name": "Crocodon",
    "image": "Crocodon Steal Egg.png",
    "rarity": "Secret",
    "mps": "Unknown",
    "speed": "+0 Speed",
    "price": "$3b"
  },
  {
    "biome": "Monster Eggs",
    "name": "Krakenoid",
    "image": "Krakenoid Steal Egg.png",
    "rarity": "Eternal",
    "mps": "Unknown",
    "speed": "+0 Speed",
    "price": "$50b"
  },
  {
    "biome": "Monster Eggs",
    "name": "Dreadscale",
    "image": "Dreadscale Steal Egg.png",
    "rarity": "Divine",
    "mps": "Unknown",
    "speed": "+0 Speed",
    "price": "$200b"
  },
  {
    "biome": "Monster Eggs",
    "name": "Mecha Scorpio",
    "image": "Mecha Scorpio Steal Egg.png",
    "rarity": "Legendary",
    "mps": "Unknown",
    "speed": "+0 Speed",
    "price": "$2m"
  },
  {
    "biome": "Monster Eggs",
    "name": "Mecha Froggo",
    "image": "Mecha Froggo Steal Egg.png",
    "rarity": "Mythic",
    "mps": "Unknown",
    "speed": "+0 Speed",
    "price": "$10m"
  },
  {
    "biome": "Monster Eggs",
    "name": "Mecha Crawler",
    "image": "Mecha Crawler Steal Egg.png",
    "rarity": "Cosmic",
    "mps": "Unknown",
    "speed": "+0 Speed",
    "price": "$300m"
  },
  {
    "biome": "Monster Eggs",
    "name": "Mecha Crocodon",
    "image": "Mecha Dreadscale Steal Egg.png",
    "rarity": "Secret",
    "mps": "Unknown",
    "speed": "+0 Speed",
    "price": "$6b"
  },
  {
    "biome": "Monster Eggs",
    "name": "Mecha Krakenoid",
    "image": "Mecha Krakenoid Steal Egg.png",
    "rarity": "Eternal",
    "mps": "Unknown",
    "speed": "+0 Speed",
    "price": "$100b"
  },
  {
    "biome": "Monster Eggs",
    "name": "Mecha Dreadscale",
    "image": "Mecha Croconoid Steal Egg.png",
    "rarity": "Divine",
    "mps": "Unknown",
    "speed": "+0 Speed",
    "price": "$400b"
  }
]]]

local PetsList = {}
pcall(function()
    PetsList = HttpService:JSONDecode(PetsJsonString)
end)

-- ================================================================
-- ⚡ PROFESSIONAL CYBER UI (MATCHING REFERENCE PHOTO)
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

local categories = {"Steal", "Sakure Event", "Predict (ERR)", "Eggs", "Pets", "Upgrades"}
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
    page.CanvasSize = UDim2.new(0, 0, 0, 600)
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

CreateToggleRow(stealPage, "Fly Mode", false, function(v)
    State.FlyMode = v
end, 205)

-- Stage Selector Row
local stageRow = Instance.new("Frame", stealPage)
stageRow.Size = UDim2.new(1, -30, 0, 38)
stageRow.Position = UDim2.new(0, 15, 0, 245)
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

-- --- PETS TAB POPULATION ---
local petsPage = catPages["Pets"]
local pTitle = Instance.new("TextLabel", petsPage)
pTitle.Size = UDim2.new(1, -20, 0, 30)
pTitle.Position = UDim2.new(0, 15, 0, 10)
pTitle.BackgroundTransparency, pTitle.Text = 1, "Pets Database & Stats Wiki"
pTitle.TextColor3 = Color3.fromRGB(56, 189, 248)
pTitle.TextSize, pTitle.Font = 14, Enum.Font.GothamBold
pTitle.TextXAlignment = Enum.TextXAlignment.Left

local yOffset = 45
pcall(function()
    for _, pet in ipairs(PetsList) do
        local pRow = Instance.new("Frame", petsPage)
        pRow.Size = UDim2.new(1, -30, 0, 26)
        pRow.Position = UDim2.new(0, 15, 0, yOffset)
        pRow.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
        Instance.new("UICorner", pRow).CornerRadius = UDim.new(0, 4)

        local nLbl = Instance.new("TextLabel", pRow)
        nLbl.Size = UDim2.new(0.65, 0, 1, 0)
        nLbl.Position = UDim2.new(0, 8, 0, 0)
        nLbl.BackgroundTransparency = 1
        nLbl.Text = "• [" .. tostring(pet.biome) .. "] " .. tostring(pet.name) .. " (" .. tostring(pet.rarity) .. ")"
        nLbl.TextColor3 = Color3.fromRGB(200, 200, 210)
        nLbl.TextSize = 11
        nLbl.Font = Enum.Font.Gotham
        nLbl.TextXAlignment = Enum.TextXAlignment.Left

        local mLbl = Instance.new("TextLabel", pRow)
        mLbl.Size = UDim2.new(0.35, 0, 1, 0)
        mLbl.Position = UDim2.new(0.65, -10, 0, 0)
        mLbl.BackgroundTransparency = 1
        mLbl.Text = "MPS: " .. tostring(pet.mps)
        mLbl.TextColor3 = Color3.fromRGB(52, 211, 153)
        mLbl.TextSize = 11
        mLbl.Font = Enum.Font.GothamBold
        mLbl.TextXAlignment = Enum.TextXAlignment.Right

        yOffset = yOffset + 30
    end
end)
petsPage.CanvasSize = UDim2.new(0, 0, 0, yOffset + 50)
print("Steal An Egg Professional UI Loaded Successfully!")
