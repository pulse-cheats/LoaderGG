-- ==============================================================================
-- GitHub Multi-File Loader + Animated Loading Screen
-- ==============================================================================

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local targetParent = LocalPlayer:FindFirstChildOfClass("PlayerGui") or CoreGui

-- ==============================================================================
-- 1. Create Animated Loading Screen UI
-- ==============================================================================
local LoadGui = Instance.new("ScreenGui")
LoadGui.Name = "StudioLoaderScreen"
LoadGui.ResetOnSpawn = false
LoadGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() LoadGui.Parent = targetParent end)

local Card = Instance.new("Frame")
Card.Size = UDim2.new(0, 320, 0, 140)
Card.Position = UDim2.new(0.5, -160, 0.5, -70)
Card.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
Card.BorderSizePixel = 0
Card.Parent = LoadGui

local CardCorner = Instance.new("UICorner")
CardCorner.CornerRadius = UDim.new(0, 10)
CardCorner.Parent = Card

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 24)
Title.Position = UDim2.new(0, 0, 0, 18)
Title.Text = "Luau Studio Pro"
Title.TextColor3 = Color3.fromRGB(240, 240, 245)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.BackgroundTransparency = 1
Title.Parent = Card

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 20)
Status.Position = UDim2.new(0, 0, 0, 46)
Status.Text = "Initializing loader..."
Status.TextColor3 = Color3.fromRGB(156, 163, 175)
Status.Font = Enum.Font.Gotham
Status.TextSize = 12
Status.BackgroundTransparency = 1
Status.Parent = Card

-- Progress Bar Background
local BarBg = Instance.new("Frame")
BarBg.Size = UDim2.new(0.85, 0, 0, 8)
BarBg.Position = UDim2.new(0.075, 0, 0, 82)
BarBg.BackgroundColor3 = Color3.fromRGB(39, 39, 45)
BarBg.BorderSizePixel = 0
BarBg.Parent = Card

local BarBgCorner = Instance.new("UICorner")
BarBgCorner.CornerRadius = UDim.new(1, 0)
BarBgCorner.Parent = BarBg

-- Progress Bar Fill
local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
BarFill.BorderSizePixel = 0
BarFill.Parent = BarBg

local BarFillCorner = Instance.new("UICorner")
BarFillCorner.CornerRadius = UDim.new(1, 0)
BarFillCorner.Parent = BarFill

local function updateProgress(percent, text)
    Status.Text = text
    TweenService:Create(BarFill, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(percent, 0, 1, 0)
    }):Play()
    task.wait(0.35)
end

-- ==============================================================================
-- 2. Fetch Modules with Real-time Status
-- ==============================================================================
local BASE_URL = "https://raw.githubusercontent.com/pulse-cheats/LoaderGG/main/"
local ASSET_URL = BASE_URL .. "assets/"

local function fetch(fileName)
    local success, res = pcall(function()
        return game:HttpGet(BASE_URL .. fileName, true)
    end)
    if success and res then
        return res
    end
    warn("[Loader Fetch Warning]: Could not fetch " .. tostring(fileName))
    return nil
end

updateProgress(0.20, "Connecting to GitHub...")
local aiContent = fetch("ai.lua")

updateProgress(0.50, "Fetching UI & Assets...")
local uiContent = fetch("ui.lua")

updateProgress(0.75, "Loading Editor Engine...")
local editorContent = fetch("editor.lua")

if aiContent and uiContent and editorContent then
    updateProgress(0.95, "Compiling Modules...")
    local AI = loadstring(aiContent)()
    local UI = loadstring(uiContent)()
    local Editor = loadstring(editorContent)()

    updateProgress(1.0, "Ready!")
    
    -- Fade out Loading Screen
    TweenService:Create(Card, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Title, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    TweenService:Create(Status, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    TweenService:Create(BarBg, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    TweenService:Create(BarFill, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    
    task.wait(0.4)
    LoadGui:Destroy()

    -- Start Studio
    Editor.Start(AI, UI, ASSET_URL)
    print("✅ Luau AI Studio loaded successfully!")
else
    Status.Text = "Failed to load files from GitHub!"
    Status.TextColor3 = Color3.fromRGB(239, 68, 68)
    task.wait(2.5)
    LoadGui:Destroy()
end
