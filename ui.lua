local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local UI = {}

function UI.Init()
    local LocalPlayer = Players.LocalPlayer
    local targetParent = LocalPlayer:FindFirstChildOfClass("PlayerGui") or CoreGui
    
    -- Cleanup any existing UI
    local existing = targetParent:FindFirstChild("RoolLuaStudioMobile")
    if existing then existing:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RoolLuaStudioMobile"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() ScreenGui.Parent = targetParent end)

    -- Main UI Frame
    local Main = Instance.new("Frame")
    Main.Name = "MainFrame"
    Main.Size = UDim2.new(0.90, 0, 0.80, 0)
    Main.Position = UDim2.new(0.05, 0, 0.10, 0)
    Main.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = Main

    -- Header / TopBar
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 36)
    TopBar.BackgroundColor3 = Color3.fromRGB(34, 34, 40)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = Main

    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 8)
    TopCorner.Parent = TopBar

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0.6, 0, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Text = "⚡ Luau Script Editor & AI"
    Title.TextColor3 = Color3.fromRGB(240, 240, 240)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 13
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Parent = TopBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 26, 0, 26)
    CloseBtn.Position = UDim2.new(1, -32, 0, 5)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 12
    CloseBtn.Parent = TopBar
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseBtn

    -- Sidebar (File List)
    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Size = UDim2.new(0.24, 0, 1, -42)
    Sidebar.Position = UDim2.new(0, 6, 0, 38)
    Sidebar.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 2
    Sidebar.Parent = Main

    local SideLayout = Instance.new("UIListLayout")
    SideLayout.Padding = UDim.new(0, 4)
    SideLayout.Parent = Sidebar

    local NewFileBtn = Instance.new("TextButton")
    NewFileBtn.Name = "NewFileBtn"
    NewFileBtn.Size = UDim2.new(1, -4, 0, 26)
    NewFileBtn.BackgroundColor3 = Color3.fromRGB(45, 55, 72)
    NewFileBtn.Text = "➕ New File"
    NewFileBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    NewFileBtn.Font = Enum.Font.GothamBold
    NewFileBtn.TextSize = 11
    NewFileBtn.Parent = Sidebar
    local nfc = Instance.new("UICorner")
    nfc.CornerRadius = UDim.new(0, 4)
    nfc.Parent = NewFileBtn

    -- Code Editor Container
    local EditorScroll = Instance.new("ScrollingFrame")
    EditorScroll.Size = UDim2.new(0.74, 0, 0.74, 0)
    EditorScroll.Position = UDim2.new(0.25, 0, 0, 38)
    EditorScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    EditorScroll.BorderSizePixel = 0
    EditorScroll.ScrollBarThickness = 4
    EditorScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    EditorScroll.AutomaticCanvasSize = Enum.AutomaticSize.XY
    EditorScroll.Parent = Main

    -- Textbox for typing / editing
    local CodeBox = Instance.new("TextBox")
    CodeBox.Size = UDim2.new(1, -10, 1, -10)
    CodeBox.Position = UDim2.new(0, 5, 0, 5)
    CodeBox.BackgroundTransparency = 1
    CodeBox.TextColor3 = Color3.fromRGB(230, 230, 230)
    CodeBox.Font = Enum.Font.Code
    CodeBox.TextSize = 13
    CodeBox.ClearTextOnFocus = false
    CodeBox.MultiLine = true
    CodeBox.TextXAlignment = Enum.TextXAlignment.Left
    CodeBox.TextYAlignment = Enum.TextYAlignment.Top
    CodeBox.AutomaticSize = Enum.AutomaticSize.XY
    CodeBox.Parent = EditorScroll

    -- Bottom Bar: Prompt Input & Buttons
    local PromptBox = Instance.new("TextBox")
    PromptBox.Size = UDim2.new(0.48, 0, 0, 32)
    PromptBox.Position = UDim2.new(0.25, 0, 1, -36)
    PromptBox.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
    PromptBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    PromptBox.PlaceholderText = "Ask AI to write or fix code..."
    PromptBox.Font = Enum.Font.Gotham
    PromptBox.TextSize = 11
    PromptBox.ClearTextOnFocus = false
    PromptBox.Parent = Main
    local pbc = Instance.new("UICorner")
    pbc.CornerRadius = UDim.new(0, 6)
    pbc.Parent = PromptBox

    local function makeButton(name, pos, size, bg, text)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = size
        btn.Position = pos
        btn.BackgroundColor3 = bg
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.Parent = Main
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 6)
        c.Parent = btn
        return btn
    end

    local AskBtn = makeButton("AskBtn", UDim2.new(0.74, 0, 1, -36), UDim2.new(0.12, 0, 0, 32), Color3.fromRGB(99, 102, 241), "✨ AI")
    local RunBtn = makeButton("RunBtn", UDim2.new(0.87, 0, 1, -36), UDim2.new(0.12, 0, 0, 32), Color3.fromRGB(34, 197, 94), "▶ Run")

    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui.Enabled = not ScreenGui.Enabled
    end)

    return {
        ScreenGui = ScreenGui,
        Sidebar = Sidebar,
        NewFileBtn = NewFileBtn,
        CodeBox = CodeBox,
        PromptBox = PromptBox,
        AskBtn = AskBtn,
        RunBtn = RunBtn
    }
end

return UI
