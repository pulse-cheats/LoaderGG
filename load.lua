--[[
    ╔════════════════════════════════════════════════════════════════╗
    ║                 STEAL AN EGG - SCRIPT LOADER                   ║
    ║        Auto Farm + PvP Stealer + Auto Plot + Pet DB UI         ║
    ╚════════════════════════════════════════════════════════════════╝
--]]

local SCRIPT_URL = "https://raw.githubusercontent.com/pulse-cheats/LoaderGG/main/sae.lua"

local success, err = pcall(function()
    loadstring(game:HttpGet(SCRIPT_URL, true))()
end)

if not success then
    warn("[Steal An Egg Loader] Failed to load remote script: " .. tostring(err))
    -- Fallback alert notification in Roblox UI
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Steal An Egg Loader",
            Text = "Error loading sae.lua. Check URL or internet connection.",
            Duration = 6
        })
    end)
end
