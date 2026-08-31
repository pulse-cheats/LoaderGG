--!strict
-- [[ Hub Quick Loader ]]

local config = {
    repoOwner = "YOUR_GITHUB_USERNAME", -- Το GitHub username σου
    repoName = "YOUR_REPO_NAME",       -- Το όνομα του repository σου
    branch = "main",                   -- Το branch (συνήθως main)
    targetFile = "assets/video.luau"   -- Το αρχείο με το animation σου (ή video.lua)
}

local url = string.format(
    "https://raw.githubusercontent.com/%s/%s/%s/%s",
    config.repoOwner,
    config.repoName,
    config.branch,
    config.targetFile
)

-- Φόρτωση και εκτέλεση του animation σου
local success, result = pcall(function()
    return game:HttpGet(url)
end)

if not success or not result or result == "" then
    warn("[Loader Error] Failed to fetch animation from GitHub: " .. tostring(result))
    return
end

local execSuccess, runAnimation = pcall(function()
    return loadstring(result)
end)

if execSuccess and typeof(runAnimation) == "function" then
    -- Εκκίνηση του animation σου
    task.spawn(runAnimation)
else
    warn("[Loader Error] Failed to execute animation script: " .. tostring(runAnimation))
end
