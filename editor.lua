local Editor = {}

function Editor.Start(ENV, AI, UI_Module)
    -- Fallback API key verification
    local apiKey = (ENV and ENV.GROQ_API_KEY) or "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"
    local model = (ENV and ENV.MODEL) or "llama-3.3-70b-versatile"

    local ui = UI_Module.Init()
    
    local files = {
        ["main.lua"] = "-- Script Editor Ready\nprint('Hello World')",
        ["sample.lua"] = "-- Sample File\nlocal p = game.Players.LocalPlayer\nprint('Logged as:', p.Name)"
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
            fileBtn.Size = UDim2.new(1, -4, 0, 24)
            fileBtn.BackgroundColor3 = (name == activeFile) and Color3.fromRGB(59, 130, 246) or Color3.fromRGB(38, 38, 44)
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
            warn("[Syntax Error]: " .. tostring(err))
        end
    end)
    
    -- Ask AI
    ui.AskBtn.MouseButton1Click:Connect(function()
        local prompt = ui.PromptBox.Text
        if prompt == "" then return end
        
        ui.AskBtn.Text = "⏳..."
        ui.PromptBox.Text = ""
        
        task.spawn(function()
            local result = AI.Ask(apiKey, model, prompt, ui.CodeBox.Text)
            ui.CodeBox.Text = result
            files[activeFile] = result
            ui.AskBtn.Text = "✨ AI"
        end)
    end)
end

return Editor
