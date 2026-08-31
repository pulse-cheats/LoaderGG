local Editor = {}

function Editor.Start(ENV, AI, UI_Module)
    local ui = UI_Module.Init()
    
    local files = {
        ["main.lua"] = "-- In-Game Script Editor\nprint('Hello from Lua Studio!')",
        ["fly.lua"] = "-- Fly / Movement Script\nlocal player = game.Players.LocalPlayer\nlocal char = player.Character or player.CharacterAdded:Wait()\nprint('Character:', char.Name)"
    }
    local activeFile = "main.lua"
    
    local function renderFiles()
        for _, item in ipairs(ui.Sidebar:GetChildren()) do
            if item:IsA("TextButton") and item.Name ~= "NewFileBtn" and item ~= ui.NewFileBtn then
                item:Destroy()
            end
        end
        
        for name, _ in pairs(files) do
            local fileBtn = Instance.new("TextButton")
            fileBtn.Size = UDim2.new(1, -4, 0, 26)
            fileBtn.BackgroundColor3 = (name == activeFile) and Color3.fromRGB(59, 130, 246) or Color3.fromRGB(40, 40, 46)
            fileBtn.Text = " 📄 " .. name
            fileBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
            fileBtn.Font = Enum.Font.Gotham
            fileBtn.TextSize = 11
            fileBtn.TextXAlignment = Enum.TextXAlignment.Left
            fileBtn.Parent = ui.Sidebar
            
            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(0, 4)
            c.Parent = fileBtn
            
            fileBtn.MouseButton1Click:Connect(function()
                files[activeFile] = ui.CodeBox.Text
                activeFile = name
                ui.CodeBox.Text = files[name]
                renderFiles()
            end)
        end
    end
    
    ui.CodeBox.Text = files[activeFile]
    renderFiles()
    
    -- Create New File
    ui.NewFileBtn.MouseButton1Click:Connect(function()
        local count = 1
        for _ in pairs(files) do count = count + 1 end
        local newName = "script_" .. count .. ".lua"
        files[newName] = "-- " .. newName .. "\n"
        files[activeFile] = ui.CodeBox.Text
        activeFile = newName
        ui.CodeBox.Text = files[newName]
        renderFiles()
    end)
    
    -- Run Code
    ui.RunBtn.MouseButton1Click:Connect(function()
        files[activeFile] = ui.CodeBox.Text
        local fn, err = loadstring(ui.CodeBox.Text)
        if fn then
            task.spawn(fn)
        else
            warn("[Luau Editor Syntax Error]: " .. tostring(err))
        end
    end)
    
    -- Ask AI
    ui.AskBtn.MouseButton1Click:Connect(function()
        local prompt = ui.PromptBox.Text
        if prompt == "" then return end
        
        ui.AskBtn.Text = "⏳..."
        ui.PromptBox.Text = ""
        
        task.spawn(function()
            local result = AI.Ask(ENV.GROQ_API_KEY, ENV.MODEL, prompt, ui.CodeBox.Text)
            ui.CodeBox.Text = result
            files[activeFile] = result
            ui.AskBtn.Text = "✨ Ask AI"
        end)
    end)
end

return Editor
