--[[
    ╔══════════════════════════════════════════════════════════════════════╗
    ║                 ⚔️ STEAL AN EGG - PRO SUITE v2.0                    ║
    ║        GitHub Edition | Auto-Plot | Modern UI | Pet Wiki            ║
    ╚══════════════════════════════════════════════════════════════════════╝
--]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 🛡️ Anti-AFK
LocalPlayer.Idled:Connect(function()
    local VirtualUser = game:GetService("VirtualUser")
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- =================================================================
-- CONFIGURATION & DATA
-- =================================================================
local GameData = {
    Plots = {
        ["Plot 1"] = Vector3.new(459.94, 71.11, -429.17),
        ["Plot 2"] = Vector3.new(458.68, 71.11, -481.31),
        ["Plot 3"] = Vector3.new(522.99, 71.11, -489.49),
        ["Plot 4"] = Vector3.new(462.52, 71.11, -364.70),
        ["Plot 5"] = Vector3.new(461.95, 71.11, -301.24),
        ["Plot 6"] = Vector3.new(461.66, 71.11, -241.08),
        ["Plot 7"] = Vector3.new(521.48, 71.11, -242.86),
    },

    StartSpawn = Vector3.new(482.16, 71.11, -438.48),

    Stages = {
        { Pos = Vector3.new(511.45, 71.11, -374.00), Wait = 1.0,  Name = "Stage 1" },
        { Pos = Vector3.new(568.27, 71.11, -366.19), Wait = 1.5,  Name = "Stage 2" },
        { Pos = Vector3.new(623.58, 71.11, -365.17), Wait = 2.0,  Name = "Stage 3" },
        { Pos = Vector3.new(679.52, 71.11, -366.17), Wait = 2.5,  Name = "Stage 4" },
        { Pos = Vector3.new(736.32, 71.11, -365.25), Wait = 3.0,  Name = "Stage 5" },
        { Pos = Vector3.new(792.83, 71.11, -365.38), Wait = 3.5,  Name = "Stage 6" },
        { Pos = Vector3.new(849.27, 71.11, -366.67), Wait = 4.0,  Name = "Stage 7" },
        { Pos = Vector3.new(905.79, 71.11, -365.57), Wait = 4.5,  Name = "Stage 8" },
        { Pos = Vector3.new(962.38, 71.11, -365.41), Wait = 5.0,  Name = "Stage 9" },
        { Pos = Vector3.new(1018.77, 71.11, -365.48), Wait = 6.0, Name = "Stage 10" },
    },

    Rarities = {
        ["Common"]    = { Color = Color3.fromRGB(180, 185, 195), Multiplier = "1x" },
        ["Uncommon"]  = { Color = Color3.fromRGB(46, 204, 113),  Multiplier = "2x" },
        ["Rare"]      = { Color = Color3.fromRGB(52, 152, 219),  Multiplier = "5x" },
        ["Epic"]      = { Color = Color3.fromRGB(155, 89, 182),  Multiplier = "15x" },
        ["Legendary"] = { Color = Color3.fromRGB(243, 156, 18),  Multiplier = "50x" },
        ["Mythic"]    = { Color = Color3.fromRGB(233, 30, 99),   Multiplier = "150x" },
        ["Cosmic"]    = { Color = Color3.fromRGB(0, 230, 246),   Multiplier = "500x" },
        ["Secret"]    = { Color = Color3.fromRGB(231, 76, 60),   Multiplier = "1.5k x" },
        ["Eternal"]   = { Color = Color3.fromRGB(241, 196, 15),  Multiplier = "5k x" },
        ["Divine"]    = { Color = Color3.fromRGB(255, 255, 255), Multiplier = "15k x" },
    },

    PetsDatabase = {
        { name = "Chicken", biome = "Forest", rarity = "Common", mps = "$1/s", speed = "+420 Speed", price = "$100" },
        { name = "Dog", biome = "Forest", rarity = "Common", mps = "$2/s", speed = "+460 Speed", price = "$200" },
        { name = "Bird", biome = "Forest", rarity = "Uncommon", mps = "$8/s", speed = "+500 Speed", price = "$800" },
        { name = "Owl", biome = "Forest", rarity = "Rare", mps = "$35/s", speed = "+560 Speed", price = "$3.5k" },
        { name = "Raccoon", biome = "Forest", rarity = "Rare", mps = "$45/s", speed = "+620 Speed", price = "$4.5k" },
        { name = "Bear", biome = "Forest", rarity = "Epic", mps = "$240/s", speed = "+820 Speed", price = "$24k" },
        { name = "Fox", biome = "Forest", rarity = "Epic", mps = "$180/s", speed = "+720 Speed", price = "$18k" },
        { name = "Brr Brr Patapim", biome = "Forest", rarity = "Legendary", mps = "$1.8k/s", speed = "+1k Speed", price = "$180k" },
        { name = "Frog", biome = "Lake", rarity = "Common", mps = "$3/s", speed = "+2k Speed", price = "$300" },
        { name = "Duckling", biome = "Lake", rarity = "Common", mps = "$4/s", speed = "+2.2k Speed", price = "$400" },
        { name = "Catfish", biome = "Lake", rarity = "Uncommon", mps = "$12/s", speed = "+2.5k Speed", price = "$1.2k" },
        { name = "Turtle", biome = "Lake", rarity = "Rare", mps = "$60/s", speed = "+2.7k Speed", price = "$6k" },
        { name = "Trulimero Trulicina", biome = "Lake", rarity = "Epic", mps = "$260/s", speed = "+3k Speed", price = "$26k" },
        { name = "Swan", biome = "Lake", rarity = "Epic", mps = "$320/s", speed = "+3.5k Speed", price = "$32k" },
        { name = "Axolotl", biome = "Lake", rarity = "Legendary", mps = "$2.8k/s", speed = "+4k Speed", price = "$280k" },
        { name = "Leviathan", biome = "Lake", rarity = "Cosmic", mps = "$220k/s", speed = "+5k Speed", price = "$22m" },
        { name = "Jerboa", biome = "Desert", rarity = "Common", mps = "$6/s", speed = "+7.2k Speed", price = "$600" },
        { name = "Fennec", biome = "Desert", rarity = "Uncommon", mps = "$18/s", speed = "+8.1k Speed", price = "$1.8k" },
        { name = "Camel", biome = "Desert", rarity = "Rare", mps = "$75/s", speed = "+9k Speed", price = "$7.5k" },
        { name = "Tob Tobi Tob Tob", biome = "Desert", rarity = "Epic", mps = "$325/s", speed = "+9.9k Speed", price = "$32.5k" },
        { name = "Snake", biome = "Desert", rarity = "Legendary", mps = "$3.6k/s", speed = "+10.8k Speed", price = "$360k" },
        { name = "Scorpion", biome = "Desert", rarity = "Mythic", mps = "$18.5k/s", speed = "+14.4k Speed", price = "$1.8m" },
        { name = "Sand Spider", biome = "Desert", rarity = "Mythic", mps = "$16k/s", speed = "+12.6k Speed", price = "$1.6m" },
        { name = "Royal Sphinx", biome = "Desert", rarity = "Cosmic", mps = "$280k/s", speed = "+18k Speed", price = "$28m" },
        { name = "Toucan", biome = "Jungle", rarity = "Rare", mps = "$110/s", speed = "+8.1k Speed", price = "$11k" },
        { name = "Chimpanzee", biome = "Jungle", rarity = "Rare", mps = "$90/s", speed = "+7.2k Speed", price = "$9k" },
        { name = "Crocodile", biome = "Jungle", rarity = "Epic", mps = "$420/s", speed = "+9k Speed", price = "$42k" },
        { name = "Gorilla", biome = "Jungle", rarity = "Legendary", mps = "$4.8k/s", speed = "+9.9k Speed", price = "$480k" },
        { name = "Orangutini Ananassini", biome = "Jungle", rarity = "Legendary", mps = "$5.5k/s", speed = "+10.8k Speed", price = "$550k" },
        { name = "Spider", biome = "Jungle", rarity = "Mythic", mps = "$22k/s", speed = "+12.6k Speed", price = "$2.2m" },
        { name = "Tiger", biome = "Jungle", rarity = "Mythic", mps = "$28k/s", speed = "+14.4k Speed", price = "$2.8m" },
        { name = "King Snake", biome = "Jungle", rarity = "Secret", mps = "$3.5m/s", speed = "+18k Speed", price = "$350m" },
        { name = "Penguin", biome = "Snow", rarity = "Rare", mps = "$140/s", speed = "+12.8k Speed", price = "$14k" },
        { name = "Walrus", biome = "Snow", rarity = "Epic", mps = "$600/s", speed = "+14.4k Speed", price = "$60k" },
        { name = "Polar Bear", biome = "Snow", rarity = "Legendary", mps = "$7k/s", speed = "+16k Speed", price = "$700k" },
        { name = "Sabertooth Tiger", biome = "Snow", rarity = "Mythic", mps = "$35k/s", speed = "+17.6k Speed", price = "$3.5m" },
        { name = "Mammoth", biome = "Snow", rarity = "Mythic", mps = "$42k/s", speed = "+19.2k Speed", price = "$4.2m" },
        { name = "King Mammoth", biome = "Snow", rarity = "Cosmic", mps = "$400k/s", speed = "+22.4k Speed", price = "$40m" },
        { name = "Yeti", biome = "Snow", rarity = "Secret", mps = "$5m/s", speed = "+25.6k Speed", price = "$500m" },
        { name = "Ice Dragon", biome = "Snow", rarity = "Eternal", mps = "$65m/s", speed = "+32k Speed", price = "$6.5b" },
        { name = "Lava Gecko", biome = "Volcano", rarity = "Rare", mps = "$180/s", speed = "+24k Speed", price = "$18k" },
        { name = "Lava Frog", biome = "Volcano", rarity = "Epic", mps = "$850/s", speed = "+27k Speed", price = "$85k" },
        { name = "Flaming Bull", biome = "Volcano", rarity = "Legendary", mps = "$9.5k/s", speed = "+30k Speed", price = "$950k" },
        { name = "Lava Iguana", biome = "Volcano", rarity = "Legendary", mps = "$11k/s", speed = "+36k Speed", price = "$1.1m" },
        { name = "Chillin Chilli", biome = "Volcano", rarity = "Mythic", mps = "$55k/s", speed = "+33k Speed", price = "$5.5m" },
        { name = "Cerberus", biome = "Volcano", rarity = "Secret", mps = "$8m/s", speed = "+42k Speed", price = "$800m" },
        { name = "Phoenix", biome = "Volcano", rarity = "Eternal", mps = "85m/s", speed = "+48k Speed", price = "$8.5b" },
        { name = "Lava Dragon", biome = "Volcano", rarity = "Eternal", mps = "$100m/s", speed = "+60k Speed", price = "$10b" },
        { name = "Parrotfish", biome = "Abyss Ocean", rarity = "Rare", mps = "$220/s", speed = "+72k Speed", price = "$22k" },
        { name = "Swordfish", biome = "Abyss Ocean", rarity = "Epic", mps = "$1.1k/s", speed = "+81k Speed", price = "$110k" },
        { name = "Shark", biome = "Abyss Ocean", rarity = "Legendary", mps = "$15k/s", speed = "+90k Speed", price = "$1.5m" },
        { name = "Orca", biome = "Abyss Ocean", rarity = "Mythic", mps = "$80k/s", speed = "+99k Speed", price = "$8m" },
        { name = "Whale Shark", biome = "Abyss Ocean", rarity = "Cosmic", mps = "$700k/s", speed = "+108k Speed", price = "$70m" },
        { name = "Beluga Whale", biome = "Abyss Ocean", rarity = "Cosmic", mps = "$850k/s", speed = "+126k Speed", price = "$85m" },
        { name = "Kraken", biome = "Abyss Ocean", rarity = "Secret", mps = "$15m/s", speed = "+144k Speed", price = "$1.5b" },
        { name = "El Maja", biome = "Abyss Ocean", rarity = "Eternal", mps = "$130m/s", speed = "+180k Speed", price = "$13b" },
        { name = "Dodo", biome = "Prehistoric", rarity = "Rare", mps = "+280/s", speed = "+240k Speed", price = "$28k" },
        { name = "Pterodactyl", biome = "Prehistoric", rarity = "Legendary", mps = "+22k/s", speed = "+270k Speed", price = "$2.2m" },
        { name = "Ankylosaurus", biome = "Prehistoric", rarity = "Mythic", mps = "$120k/s", speed = "+330k Speed", price = "$12m" },
        { name = "Triceratops", biome = "Prehistoric", rarity = "Cosmic", mps = "$1.2m/s", speed = "+360k Speed", price = "$120m" },
        { name = "Bronto", biome = "Prehistoric", rarity = "Cosmic", mps = "$1.5m/s", speed = "+300k Speed", price = "$150m" },
        { name = "Tralaledon", biome = "Prehistoric", rarity = "Secret", mps = "$32m/s", speed = "+480k Speed", price = "$3.2b" },
        { name = "TRex", biome = "Prehistoric", rarity = "Secret", mps = "$25m/s", speed = "+420k Speed", price = "$2.5b" },
        { name = "Mosasaurus", biome = "Prehistoric", rarity = "Eternal", mps = "$180m/s", speed = "+600k Speed", price = "$18b" },
        { name = "Centapede", biome = "Cosmic", rarity = "Epic", mps = "$1.5k/s", speed = "+960k Speed", price = "$150k" },
        { name = "Cosmic Gecko", biome = "Cosmic", rarity = "Legendary", mps = "$30k/s", speed = "+1m Speed", price = "$3m" },
        { name = "Cosmic Gorilla", biome = "Cosmic", rarity = "Mythic", mps = "$180k/s", speed = "+1.2m Speed", price = "$18m" },
        { name = "La Vacca Saturno Saturnita", biome = "Cosmic", rarity = "Cosmic", mps = "$2.2m/s", speed = "+1.3m Speed", price = "Cosmic" },
        { name = "Cosmic Dragon", biome = "Cosmic", rarity = "Secret", mps = "$60m/s", speed = "+1.4m Speed", price = "$6b" },
        { name = "Cosmic Skeleton Boss", biome = "Cosmic", rarity = "Secret", mps = "$45m/s", speed = "+1.6m Speed", price = "$4.5b" },
        { name = "Eternal Lunar Dragon", biome = "Cosmic", rarity = "Eternal", mps = "$250m/s", speed = "+1.9m Speed", price = "$25b" },
        { name = "Unicorn", biome = "Cosmic", rarity = "Divine", mps = "$1b/s", speed = "+2.4m Speed", price = "$100b" },
        { name = "Crane", biome = "Cherry Blossom", rarity = "Epic", mps = "$4k/s", speed = "+2.7m Speed", price = "$400k" },
        { name = "Salamander", biome = "Cherry Blossom", rarity = "Legendary", mps = "$74k/s", speed = "+3m Speed$7.4m", price = "Cherry Blossom" },
        { name = "Red Panda", biome = "Cherry Blossom", rarity = "Mythic", mps = "450k/s", speed = "+3.4m Speed", price = "$45m" },
        { name = "Koi", biome = "Cherry Blossom", rarity = "Cosmic", mps = "$12m/s", speed = "+4.2m Speed", price = "$1.2b" },
        { name = "Snowy Owl", biome = "Cherry Blossom", rarity = "Cosmic", mps = "$7.5m/s", speed = "+3.7m Speed", price = "$750m" },
        { name = "Stag", biome = "Cherry Blossom", rarity = "Secret", mps = "$145m/s", speed = "+4.8m Speed", price = "$14.5b" },
        { name = "Oni Tiger", biome = "Cherry Blossom", rarity = "Eternal", mps = "$600m/s", speed = "+5.4m Speed", price = "$60b" },
        { name = "Kitsune", biome = "Cherry Blossom", rarity = "Divine", mps = "$1.8b/s", speed = "+6.5m Speed", price = "$180b" },
        { name = "Crustacia", biome = "Titan Temple", rarity = "Legendary", mps = "$130K/s", speed = "+2.7m Speed", price = "$13m" },
        { name = "Spideron", biome = "Titan Temple", rarity = "Legendary", mps = "$95K/s", speed = "+2.7m Speed", price = "$13m" },
        { name = "Bladehide", biome = "Titan Temple", rarity = "Mythic", mps = "$750K/s", speed = "+4.8m Speed", price = "$75m" },
        { name = "Mantaris", biome = "Titan Temple", rarity = "Cosmic", mps = "$11M/s", speed = "+3.4m Speed", price = "$1.1b" },
        { name = "Rhinotaur", biome = "Titan Temple", rarity = "Cosmic", mps = "$17.5M/s", speed = "+3m Speed", price = "$1.7b" },
        { name = "Mutant Shark", biome = "Titan Temple", rarity = "Secret", mps = "$215M/s", speed = "+4.1m Speed", price = "$21.5b" },
        { name = "Gorilla King", biome = "Titan Temple", rarity = "Eternal", mps = "$880M/s", speed = "+5.4m Speed", price = "$88b" },
        { name = "Tung Tung Sahur", biome = "Brainrot Eggs", rarity = "Rare", mps = "Unknown", speed = "+640 Speed", price = "$10k" },
        { name = "Bananita Dolphinita", biome = "Brainrot Eggs", rarity = "Epic", mps = "Unknown", speed = "+710 Speed", price = "$40k" },
        { name = "Belula Beluga", biome = "Brainrot Eggs", rarity = "Mythic", mps = "Unknown", speed = "+2.5k Speed", price = "$4m" },
        { name = "Mangolini Parrochini", biome = "Brainrot Eggs", rarity = "Cosmic", mps = "Unknown", speed = "+267k Speed", price = "$80m" },
        { name = "Bomboclat Crocolat", biome = "Brainrot Eggs", rarity = "Secret", mps = "Unknown", speed = "+860k Speed", price = "$2b" },
        { name = "Strawberry Elephant", biome = "Brainrot Eggs", rarity = "Eternal", mps = "Unknown", speed = "+143k Speed", price = "$11b" },
        { name = "Scorpio", biome = "Monster Eggs", rarity = "Legendary", mps = "Unknown", speed = "+0 Speed", price = "$1m" },
        { name = "Froggo", biome = "Monster Eggs", rarity = "Mythic", mps = "Unknown", speed = "+0 Speed", price = "$5" },
        { name = "Crawler", biome = "Monster Eggs", rarity = "Cosmic", mps = "Unknown", speed = "+0 Speed", price = "$150m" },
        { name = "Crocodon", biome = "Monster Eggs", rarity = "Secret", mps = "Unknown", speed = "+0 Speed", price = "$3b" },
        { name = "Krakenoid", biome = "Monster Eggs", rarity = "Eternal", mps = "Unknown", speed = "+0 Speed", price = "$50b" },
        { name = "Dreadscale", biome = "Monster Eggs", rarity = "Divine", mps = "Unknown", speed = "+0 Speed", price = "$200b" },
        { name = "Mecha Scorpio", biome = "Monster Eggs", rarity = "Legendary", mps = "Unknown", speed = "+0 Speed", price = "$2m" },
        { name = "Mecha Froggo", biome = "Monster Eggs", rarity = "Mythic", mps = "Unknown", speed = "+0 Speed", price = "$10m" },
        { name = "Mecha Crawler", biome = "Monster Eggs", rarity = "Cosmic", mps = "Unknown", speed = "+0 Speed", price = "$300m" },
        { name = "Mecha Crocodon", biome = "Monster Eggs", rarity = "Secret", mps = "Unknown", speed = "+0 Speed", price = "$6b" },
        { name = "Mecha Krakenoid", biome = "Monster Eggs", rarity = "Eternal", mps = "Unknown", speed = "+0 Speed", price = "$100b" },
        { name = "Mecha Dreadscale", biome = "Monster Eggs", rarity = "Divine", mps = "Unknown", speed = "+0 Speed", price = "$400b" }
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
local function GetChar() return LocalPlayer.Character end
local function GetHRP() local c = GetChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function GetHum() local c = GetChar() return c and c:FindFirstChildOfClass("Humanoid") end

local function SetPlayerSpeed(speed)
    local hum = GetHum()
    if hum then hum.WalkSpeed = speed end
end

local function ResetPlayerSpeed()
    SetPlayerSpeed(State.NormalSpeed)
end

-- 🔍 Auto Plot Detector
local function AutoDetectPlot()
    local myName = LocalPlayer.Name
    local myDisplayName = LocalPlayer.DisplayName
    local myUserId = LocalPlayer.UserId

    -- 1. Scan workspace plot folders
    local possibleFolders = {
        Workspace:FindFirstChild("Plots"),
        Workspace:FindFirstChild("Bases"),
        Workspace:FindFirstChild("PlayerPlots"),
        Workspace:FindFirstChild("Tycoons")
    }

    for _, folder in ipairs(possibleFolders) do
        if folder then
            for _, plotObj in ipairs(folder:GetChildren()) do
                local ownerVal = plotObj:FindFirstChild("Owner") or plotObj:FindFirstChild("Player") or plotObj:FindFirstChild("OwnerId")
                if ownerVal then
                    if (ownerVal:IsA("StringValue") and (ownerVal.Value == myName or ownerVal.Value == myDisplayName)) or
                       (ownerVal:IsA("ObjectValue") and ownerVal.Value == LocalPlayer) or
                       ((ownerVal:IsA("NumberValue") or ownerVal:IsA("IntValue")) and ownerVal.Value == myUserId) then
                        for pName, pPos in pairs(GameData.Plots) do
                            local part = plotObj:IsA("BasePart") and plotObj or plotObj:FindFirstChildWhichIsA("BasePart")
                            if part and (part.Position - pPos).Magnitude < 45 then
                                return pName
                            end
                        end
                    end
                end

                for _, descendant in ipairs(plotObj:GetDescendants()) do
                    if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
                        if string.find(descendant.Text:lower(), myName:lower()) or string.find(descendant.Text:lower(), myDisplayName:lower()) then
                            for pName, pPos in pairs(GameData.Plots) do
                                local part = plotObj:IsA("BasePart") and plotObj or plotObj:FindFirstChildWhichIsA("BasePart")
                                if part and (part.Position - pPos).Magnitude < 60 then
                                    return pName
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- 2. Proximity fallback
    local hrp = GetHRP()
    if hrp then
        local closestPlot = nil
        local minDist = math.huge
        for pName, pPos in pairs(GameData.Plots) do
            local d = (hrp.Position - pPos).Magnitude
            if d < minDist then
                minDist = d
                closestPlot = pName
            end
        end
        if closestPlot and minDist < 85 then
            return closestPlot
        end
    end

    return State.SelectedPlotName or "Plot 1"
end

-- Movement & Navigation
local function SafeWalkTo(targetPos, reachDist, timeout, speedOverride)
    reachDist = reachDist or 3.5
    timeout = timeout or 8.0
    if speedOverride then SetPlayerSpeed(speedOverride) end

    local hrp = GetHRP()
    local hum = GetHum()
    if not hrp or not hum then return false end

    hum:MoveTo(targetPos)
    local startTime = tick()
    local lastPos = hrp.Position
    local stuckCounter = 0

    while (hrp.Position - targetPos).Magnitude > reachDist do
        if not State.Running then hum:MoveTo(hrp.Position) return false end
        if (tick() - startTime) > timeout then break end

        RunService.Heartbeat:Wait()
        hum:MoveTo(targetPos)

        if (hrp.Position - lastPos).Magnitude < 0.15 then
            stuckCounter = stuckCounter + 1
            if stuckCounter > 30 then
                hum.Jump = true
                stuckCounter = 0
            end
        else
            stuckCounter = 0
        end
        lastPos = hrp.Position
    end
    return true
end

local function EquipBat()
    local char = GetChar()
    if not char then return nil end
    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool and string.find(currentTool.Name:lower(), "bat") then
        return currentTool
    end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and string.find(tool.Name:lower(), "bat") then
                local hum = GetHum()
                if hum then hum:EquipTool(tool) return tool end
            end
        end
        local firstTool = backpack:FindFirstChildOfClass("Tool")
        if firstTool then
            local hum = GetHum()
            if hum then hum:EquipTool(firstTool) return firstTool end
        end
    end
    return nil
end

local function UnequipTools()
    local hum = GetHum()
    if hum then hum:UnequipTools() end
end

local function AttackTarget(targetHRP)
    local tool = EquipBat()
    if tool then tool:Activate() end
    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local parent = prompt.Parent
            if parent and parent:IsA("BasePart") and (parent.Position - targetHRP.Position).Magnitude < 8 then
                pcall(function() fireproximityprompt(prompt, 0) end)
            end
        end
    end
end

local function InstantTriggerSteal()
    local hrp = GetHRP()
    if not hrp then return end
    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local parent = prompt.Parent
            if parent and parent:IsA("BasePart") and (parent.Position - hrp.Position).Magnitude < 14 then
                pcall(function() fireproximityprompt(prompt, 0) end)
            end
        end
    end
end

local function ScanForTargetPlayers()
    local hrp = GetHRP()
    if not hrp then return nil end
    local validTargets = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
            local targetHum = player.Character:FindFirstChildOfClass("Humanoid")
            if targetHRP and targetHum and targetHum.Health > 0 then
                for idx = 1, 3 do
                    local stg = GameData.Stages[idx]
                    if stg and (targetHRP.Position - stg.Pos).Magnitude < 35 then
                        table.insert(validTargets, { Player = player, HRP = targetHRP, Hum = targetHum, Dist = (hrp.Position - targetHRP.Position).Magnitude, StageIdx = idx })
                        break
                    end
                end
            end
        end
    end
    if #validTargets == 0 then return nil end
    table.sort(validTargets, function(a, b) return a.Dist < b.Dist end)
    return validTargets[1]
end

-- Controller Loop
local function MainControllerLoop()
    task.spawn(function()
        while State.Running do
            local myChar = GetChar()
            local hrp = GetHRP()
            local hum = GetHum()

            if not myChar or not hrp or not hum or hum.Health <= 0 then
                State.Status = "⏳ Respawning..."
                task.wait(1.5)
                continue
            end

            -- Auto-update Plot if needed
            State.SelectedPlotName = AutoDetectPlot()

            if State.CurrentMode == "PVP" then
                State.Status = "🔍 Scanning for Victims (Stage 1-3)..."
                local target = ScanForTargetPlayers()
                if target then
                    State.Status = "⚔️ AMBUSHING: " .. target.Player.DisplayName .. "!"
                    EquipBat()
                    SetPlayerSpeed(State.SprintSpeed)
                    local ambushStart = tick()
                    while State.Running and target.Hum.Health > 0 and (tick() - ambushStart) < 7.0 do
                        if not target.HRP or not target.HRP.Parent then break end
                        hum:MoveTo(target.HRP.Position)
                        local dist = (hrp.Position - target.HRP.Position).Magnitude
                        if dist < 7.5 then AttackTarget(target.HRP) end
                        if (target.HRP.Position - hrp.Position).Magnitude < 14 then InstantTriggerSteal() end
                        RunService.Heartbeat:Wait()
                    end
                    InstantTriggerSteal()
                    if target.Hum.Health <= 0 then State.PlayersKilled = State.PlayersKilled + 1 end
                    local plot = GameData.Plots[State.SelectedPlotName]
                    if plot then
                        State.Status = "🏃 Returning to " .. State.SelectedPlotName
                        SafeWalkTo(GameData.StartSpawn, 4.0, 5.0, State.SprintSpeed)
                        SafeWalkTo(plot, 4.0, 7.0, State.SprintSpeed)
                        InstantTriggerSteal()
                        State.EggsCollected = State.EggsCollected + 1
                    end
                else
                    SetPlayerSpeed(State.ApproachSpeed)
                    SafeWalkTo(GameData.Stages[1].Pos, 4.0, 5.0, State.ApproachSpeed)
                    task.wait(0.5)
                end
            else
                -- FARM MODE
                UnequipTools()
                local targetStage = GameData.Stages[State.SelectedStageIndex]
                if not targetStage then State.SelectedStageIndex = 1 targetStage = GameData.Stages[1] end

                State.Status = "🚶 Approaching " .. targetStage.Name .. "..."
                SafeWalkTo(targetStage.Pos, 3.5, 9.0, State.ApproachSpeed)
                if not State.Running then break end

                State.Status = "⏳ Securing Egg (" .. targetStage.Wait .. "s)..."
                SetPlayerSpeed(0)
                InstantTriggerSteal()
                task.wait(targetStage.Wait)
                if not State.Running then break end

                State.Status = "💥 STEALING! ⚡"
                SetPlayerSpeed(State.SprintSpeed)
                InstantTriggerSteal()
                if hum then hum.Jump = true end

                State.Status = "⚡ EVADING NPC -> RUSHING TO SPAWN!"
                SafeWalkTo(GameData.StartSpawn, 4.5, 12, State.SprintSpeed)
                if not State.Running then break end

                local plot = GameData.Plots[State.SelectedPlotName]
                if plot then
                    State.Status = "🏠 Delivering to " .. State.SelectedPlotName .. " ⚡"
                    SafeWalkTo(plot, 3.0, 10, State.SprintSpeed)
                    if not State.Running then break end
                    InstantTriggerSteal()
                    State.EggsCollected = State.EggsCollected + 1
                    task.wait(0.2)
                end
            end
            task.wait(0.1)
        end
        ResetPlayerSpeed()
        UnequipTools()
    end)
end

-- =================================================================
-- 🎨 MODERN CYBER / GLASSMORPHIC GUI INTERFACE
-- =================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StealEgg_Suite"
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

-- Draggable Utility
local function EnableSmoothDrag(frame, handle)
    local dragging, dragInput, dragStart, startPos
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
            TweenService:Create(frame, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end)
end

-- Floating Toggle Icon
local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = "FloatToggle"
FloatBtn.Size = UDim2.new(0, 48, 0, 48)
FloatBtn.Position = UDim2.new(0.02, 0, 0.45, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(18, 22, 36)
FloatBtn.Text = "🥚"
FloatBtn.TextSize = 22
FloatBtn.AutoButtonColor = false
FloatBtn.Parent = ScreenGui
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)
local fbStroke = Instance.new("UIStroke", FloatBtn)
fbStroke.Color = Color3.fromRGB(0, 230, 246)
fbStroke.Thickness = 2.0
EnableSmoothDrag(FloatBtn, FloatBtn)

-- Main Frame
local Main = Instance.new("Frame")
Main.Name = "MainCard"
Main.Size = UDim2.new(0, 390, 0, 520)
Main.Position = UDim2.new(0.5, -195, 0.5, -260)
Main.BackgroundColor3 = Color3.fromRGB(14, 17, 27)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)
local mainStroke = Instance.new("UIStroke", Main)
mainStroke.Color = Color3.fromRGB(38, 48, 72)
mainStroke.Thickness = 1.5

FloatBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 46)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 24, 38)
TopBar.BorderSizePixel = 0
TopBar.Parent = Main
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 14)
EnableSmoothDrag(Main, TopBar)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -90, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚔️ STEAL AN EGG <font color='#00E6F6'>PRO</font>"
Title.RichText = true
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -36, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

-- Tab Selector Bar
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 32)
TabBar.Position = UDim2.new(0, 10, 0, 52)
TabBar.BackgroundColor3 = Color3.fromRGB(20, 24, 38)
TabBar.Parent = Main
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 8)

local TabButtons = {}
local TabFrames = {}
local TabNames = { "⚔️ Farm / PvP", "🏡 Plot", "🥚 Pets DB" }

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -20, 1, -94)
ContentContainer.Position = UDim2.new(0, 10, 0, 88)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = Main

local function SwitchTab(tabIndex)
    for i, btn in ipairs(TabButtons) do
        local isSel = (i == tabIndex)
        TweenService:Create(btn, TweenInfo.new(0.18), {
            BackgroundColor3 = isSel and Color3.fromRGB(0, 230, 246) or Color3.fromRGB(20, 24, 38),
            TextColor3 = isSel and Color3.fromRGB(10, 15, 25) or Color3.fromRGB(160, 175, 200)
        }):Play()
        if TabFrames[i] then TabFrames[i].Visible = isSel end
    end
end

for i, tname in ipairs(TabNames) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1 / #TabNames, -4, 1, -4)
    tabBtn.Position = UDim2.new((i - 1) / #TabNames, 2, 0, 2)
    tabBtn.BackgroundColor3 = (i == 1) and Color3.fromRGB(0, 230, 246) or Color3.fromRGB(20, 24, 38)
    tabBtn.Text = tname
    tabBtn.TextColor3 = (i == 1) and Color3.fromRGB(10, 15, 25) or Color3.fromRGB(160, 175, 200)
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 10
    tabBtn.Parent = TabBar
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)
    tabBtn.MouseButton1Click:Connect(function() SwitchTab(i) end)
    table.insert(TabButtons, tabBtn)

    -- Page Container
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(0, 230, 246)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = (i == 1)
    page.Parent = ContentContainer
    local pList = Instance.new("UIListLayout", page)
    pList.Padding = UDim.new(0, 8)
    pList.SortOrder = Enum.SortOrder.LayoutOrder
    table.insert(TabFrames, page)
end

-- ==================== TAB 1: FARM / PVP ====================
local Page1 = TabFrames[1]

-- Status Card
local StatusCard = Instance.new("Frame")
StatusCard.Size = UDim2.new(1, 0, 0, 58)
StatusCard.BackgroundColor3 = Color3.fromRGB(20, 24, 38)
StatusCard.Parent = Page1
Instance.new("UICorner", StatusCard).CornerRadius = UDim.new(0, 10)
local stStroke = Instance.new("UIStroke", StatusCard)
stStroke.Color = Color3.fromRGB(38, 48, 72)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -16, 0, 24)
StatusLabel.Position = UDim2.new(0, 10, 0, 6)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(0, 230, 246)
StatusLabel.Font = Enum.Font.GothamSemibold
StatusLabel.TextSize = 11
StatusLabel.Text = "Status: Idle"
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = StatusCard

local EggsLabel = Instance.new("TextLabel")
EggsLabel.Size = UDim2.new(1, -16, 0, 20)
EggsLabel.Position = UDim2.new(0, 10, 0, 30)
EggsLabel.BackgroundTransparency = 1
EggsLabel.TextColor3 = Color3.fromRGB(190, 200, 220)
EggsLabel.Font = Enum.Font.Gotham
EggsLabel.TextSize = 10
EggsLabel.Text = "🥚 Eggs: 0  |  ⚔️ Kills: 0  |  Mode: FARM"
EggsLabel.TextXAlignment = Enum.TextXAlignment.Left
EggsLabel.Parent = StatusCard

-- Start / Stop Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, 0, 0, 40)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 13
ToggleBtn.Text = "▶  START ENGINE"
ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = Page1
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 10)

ToggleBtn.MouseButton1Click:Connect(function()
    State.Running = not State.Running
    if State.Running then
        TweenService:Create(ToggleBtn, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(239, 68, 68)}):Play()
        ToggleBtn.Text = "⏹  STOP ENGINE"
        MainControllerLoop()
    else
        TweenService:Create(ToggleBtn, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(34, 197, 94)}):Play()
        ToggleBtn.Text = "▶  START ENGINE"
        State.Status = "⏹ Idle"
    end
end)

-- Mode Switcher Sub-Bar
local ModeBox = Instance.new("Frame")
ModeBox.Size = UDim2.new(1, 0, 0, 32)
ModeBox.BackgroundColor3 = Color3.fromRGB(20, 24, 38)
ModeBox.Parent = Page1
Instance.new("UICorner", ModeBox).CornerRadius = UDim.new(0, 8)

local MBtnFarm = Instance.new("TextButton")
MBtnFarm.Size = UDim2.new(0.5, -2, 1, -4)
MBtnFarm.Position = UDim2.new(0, 2, 0, 2)
MBtnFarm.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
MBtnFarm.Text = "🥚 AUTO FARM"
MBtnFarm.TextColor3 = Color3.fromRGB(255, 255, 255)
MBtnFarm.Font = Enum.Font.GothamBold
MBtnFarm.TextSize = 10
MBtnFarm.Parent = ModeBox
Instance.new("UICorner", MBtnFarm).CornerRadius = UDim.new(0, 6)

local MBtnPvP = Instance.new("TextButton")
MBtnPvP.Size = UDim2.new(0.5, -2, 1, -4)
MBtnPvP.Position = UDim2.new(0.5, 0, 0, 2)
MBtnPvP.BackgroundColor3 = Color3.fromRGB(26, 30, 46)
MBtnPvP.Text = "⚔️ PVP STEALER"
MBtnPvP.TextColor3 = Color3.fromRGB(160, 170, 190)
MBtnPvP.Font = Enum.Font.GothamBold
MBtnPvP.TextSize = 10
MBtnPvP.Parent = ModeBox
Instance.new("UICorner", MBtnPvP).CornerRadius = UDim.new(0, 6)

MBtnFarm.MouseButton1Click:Connect(function()
    State.CurrentMode = "FARM"
    MBtnFarm.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
    MBtnFarm.TextColor3 = Color3.fromRGB(255, 255, 255)
    MBtnPvP.BackgroundColor3 = Color3.fromRGB(26, 30, 46)
    MBtnPvP.TextColor3 = Color3.fromRGB(160, 170, 190)
end)

MBtnPvP.MouseButton1Click:Connect(function()
    State.CurrentMode = "PVP"
    MBtnPvP.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
    MBtnPvP.TextColor3 = Color3.fromRGB(255, 255, 255)
    MBtnFarm.BackgroundColor3 = Color3.fromRGB(26, 30, 46)
    MBtnFarm.TextColor3 = Color3.fromRGB(160, 170, 190)
end)

-- Stage Select
local StgHead = Instance.new("TextLabel")
StgHead.Size = UDim2.new(1, 0, 0, 16)
StgHead.BackgroundTransparency = 1
StgHead.TextColor3 = Color3.fromRGB(255, 195, 60)
StgHead.Font = Enum.Font.GothamBold
StgHead.TextSize = 11
StgHead.Text = "🎯 TARGET STAGE (FARM MODE)"
StgHead.TextXAlignment = Enum.TextXAlignment.Left
StgHead.Parent = Page1

local StgGrid = Instance.new("Frame")
StgGrid.Size = UDim2.new(1, 0, 0, 0)
StgGrid.AutomaticSize = Enum.AutomaticSize.Y
StgGrid.BackgroundTransparency = 1
StgGrid.Parent = Page1

local sg = Instance.new("UIGridLayout", StgGrid)
sg.CellSize = UDim2.new(0.31, 0, 0, 28)
sg.CellPadding = UDim2.new(0.035, 0, 0, 6)

local StgBtns = {}
for i = 1, #GameData.Stages do
    local b = Instance.new("TextButton")
    b.Text = "Stage " .. i
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 10
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

-- ==================== TAB 2: PLOT MANAGER ====================
local Page2 = TabFrames[2]

local AutoPlotCard = Instance.new("Frame")
AutoPlotCard.Size = UDim2.new(1, 0, 0, 65)
AutoPlotCard.BackgroundColor3 = Color3.fromRGB(20, 24, 38)
AutoPlotCard.Parent = Page2
Instance.new("UICorner", AutoPlotCard).CornerRadius = UDim.new(0, 10)

local AutoPlotTitle = Instance.new("TextLabel")
AutoPlotTitle.Size = UDim2.new(1, -16, 0, 20)
AutoPlotTitle.Position = UDim2.new(0, 10, 0, 6)
AutoPlotTitle.BackgroundTransparency = 1
AutoPlotTitle.TextColor3 = Color3.fromRGB(70, 210, 160)
AutoPlotTitle.Font = Enum.Font.GothamBold
AutoPlotTitle.TextSize = 11
AutoPlotTitle.Text = "⚡ SMART AUTO-DETECT PLOT"
AutoPlotTitle.TextXAlignment = Enum.TextXAlignment.Left
AutoPlotTitle.Parent = AutoPlotCard

local AutoPlotBtn = Instance.new("TextButton")
AutoPlotBtn.Size = UDim2.new(1, -20, 0, 28)
AutoPlotBtn.Position = UDim2.new(0, 10, 0, 28)
AutoPlotBtn.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
AutoPlotBtn.Text = "🔍 SCAN & LOCK MY PLOT NOW"
AutoPlotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoPlotBtn.Font = Enum.Font.GothamBold
AutoPlotBtn.TextSize = 10
AutoPlotBtn.Parent = AutoPlotCard
Instance.new("UICorner", AutoPlotBtn).CornerRadius = UDim.new(0, 6)

local PltBtns = {}
local function UpdatePlotButtons(selected)
    for name, btn in pairs(PltBtns) do
        local sel = (name == selected)
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = sel and Color3.fromRGB(37, 99, 235) or Color3.fromRGB(26, 30, 42),
            TextColor3 = sel and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 170, 190)
        }):Play()
    end
end

AutoPlotBtn.MouseButton1Click:Connect(function()
    local detected = AutoDetectPlot()
    State.SelectedPlotName = detected
    UpdatePlotButtons(detected)
    AutoPlotBtn.Text = "✅ LOCKED TO: " .. detected
    task.delay(2, function() AutoPlotBtn.Text = "🔍 SCAN & LOCK MY PLOT NOW" end)
end)

local PltHead = Instance.new("TextLabel")
PltHead.Size = UDim2.new(1, 0, 0, 16)
PltHead.BackgroundTransparency = 1
PltHead.TextColor3 = Color3.fromRGB(160, 170, 190)
PltHead.Font = Enum.Font.GothamBold
PltHead.TextSize = 11
PltHead.Text = "🏡 MANUAL OVERRIDE (SELECT BASE):"
PltHead.TextXAlignment = Enum.TextXAlignment.Left
PltHead.Parent = Page2

local PltGrid = Instance.new("Frame")
PltGrid.Size = UDim2.new(1, 0, 0, 0)
PltGrid.AutomaticSize = Enum.AutomaticSize.Y
PltGrid.BackgroundTransparency = 1
PltGrid.Parent = Page2

local pg = Instance.new("UIGridLayout", PltGrid)
pg.CellSize = UDim2.new(0.31, 0, 0, 32)
pg.CellPadding = UDim2.new(0.035, 0, 0, 6)

for i = 1, 7 do
    local pName = "Plot " .. i
    local b = Instance.new("TextButton")
    b.Text = "🏡 Plot " .. i
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
        UpdatePlotButtons(pName)
    end)
    PltBtns[pName] = b
end

-- ==================== TAB 3: PET DATABASE ====================
local Page3 = TabFrames[3]

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, 0, 0, 32)
SearchBox.BackgroundColor3 = Color3.fromRGB(20, 24, 38)
SearchBox.PlaceholderText = "🔍 Filter pets by name, biome or rarity..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(130, 140, 160)
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 10
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = Page3
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 8)

local PetListContainer = Instance.new("Frame")
PetListContainer.Size = UDim2.new(1, 0, 0, 0)
PetListContainer.AutomaticSize = Enum.AutomaticSize.Y
PetListContainer.BackgroundTransparency = 1
PetListContainer.Parent = Page3
local plList = Instance.new("UIListLayout", PetListContainer)
plList.Padding = UDim.new(0, 4)

local PetCardFrames = {}
for _, pet in ipairs(GameData.PetsDatabase) do
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 42)
    card.BackgroundColor3 = Color3.fromRGB(20, 24, 38)
    card.Parent = PetListContainer
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

    local rarityInfo = GameData.Rarities[pet.rarity] or { Color = Color3.fromRGB(200, 200, 200), Multiplier = "1x" }
    local cStroke = Instance.new("UIStroke", card)
    cStroke.Color = rarityInfo.Color
    cStroke.Thickness = 1.0

    local petNameLbl = Instance.new("TextLabel")
    petNameLbl.Size = UDim2.new(0.55, 0, 0, 18)
    petNameLbl.Position = UDim2.new(0, 8, 0, 4)
    petNameLbl.BackgroundTransparency = 1
    petNameLbl.Text = pet.name .. "  <font color='#888'>[" .. pet.biome .. "]</font>"
    petNameLbl.RichText = true
    petNameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    petNameLbl.Font = Enum.Font.GothamBold
    petNameLbl.TextSize = 10
    petNameLbl.TextXAlignment = Enum.TextXAlignment.Left
    petNameLbl.Parent = card

    local rarityBadge = Instance.new("TextLabel")
    rarityBadge.Size = UDim2.new(0.4, 0, 0, 18)
    rarityBadge.Position = UDim2.new(0.58, 0, 0, 4)
    rarityBadge.BackgroundTransparency = 1
    rarityBadge.Text = pet.rarity .. " (" .. rarityInfo.Multiplier .. ")"
    rarityBadge.TextColor3 = rarityInfo.Color
    rarityBadge.Font = Enum.Font.GothamBold
    rarityBadge.TextSize = 10
    rarityBadge.TextXAlignment = Enum.TextXAlignment.Right
    rarityBadge.Parent = card

    local statsLbl = Instance.new("TextLabel")
    statsLbl.Size = UDim2.new(1, -16, 0, 16)
    statsLbl.Position = UDim2.new(0, 8, 0, 22)
    statsLbl.BackgroundTransparency = 1
    statsLbl.Text = "💰 " .. pet.mps .. "  |  ⚡ " .. pet.speed .. "  |  🏷️ " .. pet.price
    statsLbl.TextColor3 = Color3.fromRGB(150, 165, 185)
    statsLbl.Font = Enum.Font.Gotham
    statsLbl.TextSize = 9
    statsLbl.TextXAlignment = Enum.TextXAlignment.Left
    statsLbl.Parent = card

    table.insert(PetCardFrames, { Frame = card, Pet = pet })
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local q = SearchBox.Text:lower()
    for _, item in ipairs(PetCardFrames) do
        local p = item.Pet
        local match = (q == "") or string.find(p.name:lower(), q) or string.find(p.biome:lower(), q) or string.find(p.rarity:lower(), q)
        item.Frame.Visible = (match ~= nil)
    end
end)

-- Live Runtime Updater
RunService.RenderStepped:Connect(function()
    StatusLabel.Text = "Status: " .. State.Status
    EggsLabel.Text = "🥚 Eggs: " .. State.EggsCollected .. "  |  ⚔️ Kills: " .. State.PlayersKilled .. "  |  Mode: " .. State.CurrentMode
end)

-- Initial Auto-Detection on script start
task.spawn(function()
    task.wait(1.0)
    local autoPlot = AutoDetectPlot()
    State.SelectedPlotName = autoPlot
    UpdatePlotButtons(autoPlot)
end)
