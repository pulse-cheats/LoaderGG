-- ==============================================================================
-- GitHub Multi-File Loader: key.env, ai.lua, ui.lua, editor.lua
-- https://github.com/pulse-cheats/LoaderGG/new/main==============================================================================

local BASE_URL = "https://raw.githubusercontent.com/pulse-cheats/LoaderGG/main/"

local function fetch(fileName)
    local url = BASE_URL .. fileName
    local content = game:HttpGet(url, true)
    return content
end

-- 1. Parse key.env
local envContent = fetch("key.env")
local ENV = {}
for line in envContent:gmatch("[^\r\n]+") do
    local key, val = line:match("^([^=]+)=(.*)$")
    if key and val then
        ENV[key:gsub("%s+", "")] = val:gsub("%s+", "")
    end
end

-- 2. Load Modules
local AI = loadstring(fetch("ai.lua"))()
local UI = loadstring(fetch("ui.lua"))()
local Editor = loadstring(fetch("editor.lua"))()

-- 3. Initialize In-Game IDE
Editor.Start(ENV, AI, UI)
print("✅ Luau AI Studio loaded successfully!")
