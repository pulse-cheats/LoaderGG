local HttpService = game:GetService("HttpService")

local AI = {}

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

function AI.Ask(apiKey, model, userPrompt, currentCode)
    local gameContext = AI.GetGameContext()
    local systemPrompt = "You are an expert Roblox Luau script developer. Return ONLY valid, executable Luau code without markdown code blocks, explanation or backticks. Game Hierarchy Context: " .. gameContext
    
    local payload = {
        model = model or "llama-3.3-70b-versatile",
        messages = {
            { role = "system", content = systemPrompt },
            { role = "user", content = "Current Editor Code:\n" .. (currentCode or "") .. "\n\nUser Prompt: " .. userPrompt }
        },
        temperature = 0.2,
        max_tokens = 2048
    }
    
    local res = httpRequest({
        Url = "https://api.groq.com/openai/v1/chat/completions",
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. apiKey
        },
        Body = HttpService:JSONEncode(payload)
    })
    
    if res and (res.StatusCode == 200 or res.Success) then
        local rawData = res.Body or res
        local data = typeof(rawData) == "string" and HttpService:JSONDecode(rawData) or rawData
        if data.choices and data.choices[1] then
            local text = data.choices[1].message.content
            text = text:gsub("^```lua%s*", ""):gsub("^```%s*", ""):gsub("%s*```$", "")
            return text
        end
    end
    return "-- [Error]: AI request failed. Check your API key or network."
end

return AI
