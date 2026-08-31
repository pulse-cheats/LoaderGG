--!strict
-- Hub Loader

local config = {
    repoOwner = "pulse-cheats", -- Βάλε το GitHub username σου
    repoName = "LoaderGG",       -- Βάλε το όνομα του repository
    branch = "main",
    targetFile = "assets/video.luau"
}

local url = string.format("https://raw.githubusercontent.com/%s/%s/%s/%s",
    config.repoOwner, config.repoName, config.branch, config.targetFile)

local success, scriptContent = pcall(function()
    return game:HttpGet(url)
end)

if success and scriptContent then
    local runAnimation = loadstring(scriptContent)
    if typeof(runAnimation) == "function" then
        task.spawn(runAnimation)
    end
else
    warn("Failed to load video animation from GitHub!")
end
