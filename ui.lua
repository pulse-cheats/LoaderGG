local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local UI = {}

function UI.Init(assetBaseUrl)
    local LocalPlayer = Players.LocalPlayer
    local targetParent = LocalPlayer:FindFirstChildOfClass("PlayerGui") or CoreGui
    
    local existing = targetParent:FindFirstChild("RoolLuaStudioMobile")
    if existing then existing:Destroy() end

    -- Custom PNG Asset loader with Roblox fallback IDs
    local function getAsset(name)
        if assetBaseUrl and getcustomasset and writefile and isfile then
            local localFile = "editor_asset_" .. name
            if not isfile(localFile) then
                pcall(function()
                    local rawPng = game:HttpGet(assetBaseUrl .. name, true)
                    writefile(localFile, rawPng)
                end)
            end
            if isfile(localFile) then
                return getcustomasset(localFile)
            end
        end
        
        local fallbacks = {
            ["code.png"] = "rbxassetid://6031075931",
            ["close.png"] = "rbxassetid://6031094678",
            ["file.png"] = "rbxassetid://6031086084",
            ["new_file.png"] = "rbxassetid://6031090990",
            ["run.png"] = "rbxassetid://6031094667",
            ["run_all.png"] = "rbxassetid://6031097225",
            ["ai.png"] = "rbxassetid://6031075929"
        }
        return fallbacks[name] or ""
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RoolLuaStudioMobile"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() ScreenGui.Parent = targetParent end)

    -- Main Frame
    local Main = Instance.new("Frame")
    Main.Name = "MainFrame"
    Main.Size = UDim2.new(0.92, 0, 0.82, 0)
    Main.Position = UDim2.new(0.04, 0, 0.09, 0)
    Main.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = Main

    -- TopBar
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 36)
    TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = Main

    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 8)
    TopCorner.Parent = TopBar

    local HeaderIcon = Instance.new("ImageLabel")
    HeaderIcon.Size = UDim2.new(0, 18, 0, 18)
    HeaderIcon.Position = UDim2.new(0, 10, 0.5, -9)
    HeaderIcon.BackgroundTransparency = 1
    HeaderIcon.Image = getAsset("code.png")
    HeaderIcon.ImageColor3 = Color3.fromRGB(99, 102, 241)
    HeaderIcon.Parent = TopBar

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0.5, 0, 1, 0)
    Title.Position = UDim2.new(0, 34, 0, 0)
    Title.Text = "Luau Studio Pro"
    Title.TextColor3 = Color3.fromRGB(240, 240, 245)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 13
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Parent = TopBar

    -- Close Button
    local CloseBtn = Instance.new("ImageButton")
    CloseBtn.Size = UDim2.new(0, 24, 0, 24)
    CloseBtn.Position = UDim2.new(1, -30, 0, 6)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
    CloseBtn.Image = getAsset("close.png")
    CloseBtn.ImageColor3 = Color3.fromRGB(200, 200, 200)
    CloseBtn.Parent = TopBar
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseBtn

    -- Sidebar (File Manager)
    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Size = UDim2.new(0.24, 0, 1, -44)
    Sidebar.Position = UDim2.new(0, 6, 0, 38)
    Sidebar.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
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
    NewFileBtn.Text = "   New File"
    NewFileBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    NewFileBtn.Font = Enum.Font.GothamBold
    NewFileBtn.TextSize = 11
    NewFileBtn.TextXAlignment = Enum.TextXAlignment.Left
    NewFileBtn.Parent = Sidebar
    local nfc = Instance.new("UICorner")
    nfc.CornerRadius = UDim.new(0, 4)
    nfc.Parent = NewFileBtn

    local NewFileIcon = Instance.new("ImageLabel")
    NewFileIcon.Size = UDim2.new(0, 14, 0, 14)
    NewFileIcon.Position = UDim2.new(1, -20, 0.5, -7)
    NewFileIcon.BackgroundTransparency = 1
    NewFileIcon.Image = getAsset("new_file.png")
    NewFileIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
    NewFileIcon.Parent = NewFileBtn

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

    -- Bottom Controls Bar
    local PromptBox = Instance.new("TextBox")
    PromptBox.Size = UDim2.new(0.38, 0, 0, 32)
    PromptBox.Position = UDim2.new(0.25, 0, 1, -36)
    PromptBox.BackgroundColor3 = Color3.fromRGB(34, 34, 40)
    PromptBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    PromptBox.PlaceholderText = "Ask AI to generate / edit code..."
    PromptBox.Font = Enum.Font.Gotham
    PromptBox.TextSize = 11
    PromptBox.ClearTextOnFocus = false
    PromptBox.Parent = Main
    local pbc = Instance.new("UICorner")
    pbc.CornerRadius = UDim.new(0, 6)
    pbc.Parent = PromptBox

    local function makeActionButton(name, pos, size, bg, text, assetName)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = size
        btn.Position = pos
        btn.BackgroundColor3 = bg
        btn.Text = "   " .. text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = Main
        
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 6)
        c.Parent = btn

        if assetName then
            local icon = Instance.new("ImageLabel")
            icon.Size = UDim2.new(0, 14, 0, 14)
            icon.Position = UDim2.new(1, -18, 0.5, -7)
            icon.BackgroundTransparency = 1
            icon.Image = getAsset(assetName)
            icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
            icon.Parent = btn
        end

        return btn
    end

    local AskBtn = makeActionButton("AskBtn", UDim2.new(0.64, 0, 1, -36), UDim2.new(0.10, 0, 0, 32), Color3.fromRGB(99, 102, 241), "AI", "ai.png")
    local RunFileBtn = makeActionButton("RunFileBtn", UDim2.new(0.75, 0, 1, -36), UDim2.new(0.11, 0, 0, 32), Color3.fromRGB(34, 197, 94), "Run File", "run.png")
    local RunProjectBtn = makeActionButton("RunProjectBtn", UDim2.new(0.87, 0, 1, -36), UDim2.new(0.12, 0, 0, 32), Color3.fromRGB(234, 88, 12), "Run All", "run_all.png")

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
        RunFileBtn = RunFileBtn,
        RunProjectBtn = RunProjectBtn,
        getAsset = getAsset
    }
end

return UI
