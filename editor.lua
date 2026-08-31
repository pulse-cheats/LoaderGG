local Editor = {}

function Editor.Start(AI, UI_Module, assetBaseUrl)
    local ui = UI_Module.Init(assetBaseUrl)
    
    local files = {
        ["main.lua"] = "-- Main Entry Point\nprint('Project initialized.')",
        ["config.lua"] = "-- Global Configuration\n_G.DEBUG_MODE = true\nprint('Config loaded.')"
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
            fileBtn.BackgroundColor3 = (name == activeFile) and Color3.fromRGB(59, 130, 246) or Color3.fromRGB(36, 36, 42)
            fileBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
            fileBtn.Font = Enum.Font.Gotham
            fileBtn.TextSize = 11
            fileBtn.TextXAlignment = Enum.TextXAlignment.Left
            fileBtn.Text = "      " .. name
            fileBtn.Parent = ui.Sidebar
            
            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(0, 4)
            c.Parent = fileBtn

            local icon = Instance.new("ImageLabel")
            icon.Size = UDim2.new(0, 14, 0, 14)
            icon.Position = UDim2.new(0, 6, 0.5, -7)
            icon.BackgroundTransparency = 1
            icon.Image = ui.getAsset("file.png")
            icon.ImageColor3 = (name == activeFile) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 170)
            icon.Parent = fileBtn
            
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
        local newName = "module_" .. count .. ".lua"
        files[newName] = "-- " .. newName .. "\n"
        files[activeFile] = ui.CodeBox.Text
        activeFile = newName
        ui.CodeBox.Text = files[newName]
        renderFiles()
    end)
    
    -- Execute Single Active File
    ui.RunFileBtn.MouseButton1Click:Connect(function()
        files[activeFile] = ui.CodeBox.Text
        local fn, err = loadstring(ui.CodeBox.Text)
        if fn then
            task.spawn(fn)
            print("[Editor]: Executed " .. activeFile)
        else
            warn("[Syntax Error in " .. activeFile .. "]: " .. tostring(err))
        end
    end)

    -- Execute Whole Project (All Files Sequentially)
    ui.RunProjectBtn.MouseButton1Click:Connect(function()
        files[activeFile] = ui.CodeBox.Text
        print("[Editor]: Running entire project...")
        
        if files["main.lua"] then
            local mainFn, err = loadstring(files["main.lua"])
            if mainFn then
                task.spawn(mainFn)
            else
                warn("[Project Error in main.lua]: " .. tostring(err))
            end
        end

        for fileName, content in pairs(files) do
            if fileName ~= "main.lua" then
                local fn, err = loadstring(content)
                if fn then
                    task.spawn(fn)
                else
                    warn("[Project Error in " .. fileName .. "]: " .. tostring(err))
                end
            end
        end
        print("[Editor]: All project files executed!")
    end)
    
    -- Ask AI
    ui.AskBtn.MouseButton1Click:Connect(function()
        local prompt = ui.PromptBox.Text
        if prompt == "" then return end
        
        ui.AskBtn.Text = "   Thinking..."
        ui.PromptBox.Text = ""
        
        task.spawn(function()
            local result = AI.Ask(prompt, ui.CodeBox.Text)
            ui.CodeBox.Text = result
            files[activeFile] = result
            ui.AskBtn.Text = "   AI"
        end)
    end)
end

return Editor
