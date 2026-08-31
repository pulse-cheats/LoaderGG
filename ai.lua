local HttpService = game:GetService("HttpService")

local AI = {}

-- Cohere API Configuration
local COHERE_API_KEY = "AQ.Ab8RN6L3ZBSjBIhrXae-K9VzOX6I9O4Oqiylc5ptZJMBW_z1JQ"
local COHERE_URL = "https://api.cohere.com/v2/chat"
local COHERE_MODEL = "command-r-plus-08-2024"

local function httpRequest(options)
    local fn = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if fn then
        return fn(options)
    else
        return {
            Success = true,
            StatusCode = 200,
            Body = HttpService:RequestAsync({
                Url = options.Url,
                Method = options.Method,
                Headers = options.Headers,
                Body = options.Body
            })
        }
    end
end

function AI.GetGameContext()
    local context = {
        PlaceId = game.PlaceId,
        JobId = game.JobId,
        Workspace = {},
        ReplicatedStorage = {}
    }
    
    for i, child in ipairs(workspace:GetChildren()) do
        if i > 25 then break end
        table.insert(context.Workspace, child.Name .. " (" .. child.ClassName .. ")")
    end
    
    local rep = game:GetService("ReplicatedStorage")
    for i, child in ipairs(rep:GetChildren()) do
        if i > 25 then break end
        table.insert(context.ReplicatedStorage, child.Name .. " (" .. child.ClassName .. ")")
    end
    
    return HttpService:JSONEncode(context)
end

function AI.Ask(userPrompt, currentCode)
    local gameContext = AI.GetGameContext()
    local systemPrompt = "You are an expert Roblox Luau script developer. Return ONLY valid, executable Luau code without markdown code blocks, explanation or backticks. Game Hierarchy Context: " .. gameContext
    
    local payload = {
        model = COHERE_MODEL,
        messages = {
            {
                role = "system",
                content = systemPrompt
            },
            {
                role = "user",
                content = "Current Editor Code:\n" .. (currentCode or "") .. "\n\nUser Prompt: " .. userPrompt
            }
        },
        temperature = 0.2
    }
    
    local res = httpRequest({
        Url = COHERE_URL,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. COHERE_API_KEY
        },
        Body = HttpService:JSONEncode(payload)
    })
    
    if res and (res.StatusCode == 200 or res.Success) then
        local rawData = res.Body or res
        local data = typeof(rawData) == "string" and HttpService:JSONDecode(rawData) or rawData
        
        -- Cohere v2 response parsing
        if data.message and data.message.content and data.message.content[1] then
            local text = data.message.content[1].text
            text = text:gsub("^```lua%s*", ""):gsub("^```%s*", ""):gsub("%s*```$", "")
            return text
        elseif data.text then
            local text = data.text
            text = text:gsub("^```lua%s*", ""):gsub("^```%s*", ""):gsub("%s*```$", "")
            return text
        end
    end
    
    return "-- [Error]: Cohere AI request failed. Please check network or API key status."
end

return AI
