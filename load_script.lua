-- ==============================================================================
-- Fixed GitHub Multi-File Loader
-- ==============================================================================

local BASE_URL = "https://raw.githubusercontent.com/pulse-cheats/loaderGG/main/"

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

-- 1. Parse key.env with fallback
local ENV = {}
local envContent = fetch("key.env")
if envContent then
    for line in envContent:gmatch("[^\r\n]+") do
        local key, val = line:match("^([^=]+)=(.*)$")
        if key and val then
            ENV[key:gsub("%s+", "")] = val:gsub("%s+", "")
        end
    end
end

-- Fallback if key.env failed to load
if not ENV.GROQ_API_KEY or ENV.GROQ_API_KEY == "" then
    ENV.GROQ_API_KEY = "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"
    ENV.MODEL = "llama-3.3-70b-versatile"
end

-- 2. Load Modules
local aiContent = fetch("ai.lua")
local uiContent = fetch("ui.lua")
local editorContent = fetch("editor.lua")

if aiContent and uiContent and editorContent then
    local AI = loadstring(aiContent)()
    local UI = loadstring(uiContent)()
    local Editor = loadstring(editorContent)()

    -- 3. Initialize
    Editor.Start(ENV, AI, UI)
    print("✅ Editor loaded successfully without screen overlay issues.")
else
    warn("[Loader Error]: Failed to fetch one or more required modules.")
end
