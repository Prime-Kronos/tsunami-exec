-- ================================================
--   Primejtsu X | AI Mode v9
--   Creator: @Primejtsu
-- ================================================

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local RunService       = game:GetService("RunService")
local LP               = Players.LocalPlayer

local GROQ_KEYS = {
    "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",
    "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",
    "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",
    "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",
    "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",
    "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",
}
local keyIdx   = 1
local GROQ_URL = "https://api.groq.com/openai/v1/chat/completions"
local MODEL    = "llama-3.1-8b-instant"

local SYSTEM = "You are an expert Roblox Lua exploit script developer inside a game executor (Delta). You receive a GAME ANALYSIS before each request — use it to make scripts specific to that game. RULES: Output ONLY raw executable Lua code. No markdown, no backticks, no explanation, no comments. Use _G to store RunService connections so they can be stopped later (e.g. _G.PX_Fly, _G.PX_ESP, _G.PX_Aim). Always wrap in pcall. For disable/отключи/убери commands — disconnect _G connections and destroy instances. LocalPlayer = game.Players.LocalPlayer. When game has specific RemoteEvents — use them in scripts."

-- ================================================
-- HTTP с авто-ротацией ключей
-- ================================================
local function httpReq(url, method, headers, body)
    local fn = request or http_request or (syn and syn.request)
    if not fn then return nil, "No HTTP function in this executor" end
    local ok, res = pcall(fn, {Url=url, Method=method, Headers=headers, Body=body})
    if not ok then return nil, tostring(res) end
    return res, nil
end

local function groqRequest(body, callback)
    task.spawn(function()
        local tried = 0
        local res, err
        repeat
            tried = tried + 1
            local key = GROQ_KEYS[keyIdx]
            res, err = httpReq(GROQ_URL, "POST", {
                ["Content-Type"]  = "application/json",
                ["Authorization"] = "Bearer " .. key,
            }, body)
            if (not res) or (res and res.StatusCode == 429) then
                keyIdx = keyIdx % #GROQ_KEYS + 1
                task.wait(0.3)
            else
                break
            end
        until tried >= #GROQ_KEYS

        callback(res, err)
    end)
end

-- ================================================
-- ЖЁСТКИЙ АНАЛИЗАТОР
-- ================================================
local gameContext = ""

local function deepAnalyze()
    local RS2 = game:GetService("ReplicatedStorage")
    local info = {
        placeId     = game.PlaceId,
        playerCount = #Players:GetPlayers(),
    }

    pcall(function()
        info.gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    end)

    -- Все RemoteEvents + RemoteFunctions с полными путями
    local remotes = {}
    pcall(function()
        for _, v in pairs(RS2:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                table.insert(remotes, v:GetFullName() .. "(" .. v.ClassName .. ")")
            end
        end
    end)
    info.remotes = remotes

    -- Персонаж
    local char = LP.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            info.walkSpeed  = hum.WalkSpeed
            info.jumpPower  = hum.JumpPower
            info.jumpHeight = hum.JumpHeight
            info.health     = math.floor(hum.Health)
            info.maxHealth  = math.floor(hum.MaxHealth)
            info.rigType    = tostring(hum.RigType)
        end
        local tools = {}
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("Tool") then table.insert(tools, v.Name) end
        end
        info.tools = tools
        local parts = {}
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("BasePart") then table.insert(parts, v.Name) end
        end
        info.bodyParts = parts
    end

    -- Backpack
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        local bpTools = {}
        for _, v in pairs(bp:GetChildren()) do
            table.insert(bpTools, v.Name .. "(" .. v.ClassName .. ")")
        end
        info.backpack = bpTools
    end

    -- leaderstats
    local ls = LP:FindFirstChild("leaderstats")
    if ls then
        local stats = {}
        for _, v in pairs(ls:GetChildren()) do
            table.insert(stats, v.Name .. "=" .. tostring(v.Value))
        end
        info.leaderstats = stats
    end

    -- Workspace
    local ws = {}
    for _, v in pairs(workspace:GetChildren()) do
        table.insert(ws, v.Name .. "(" .. v.ClassName .. ")")
    end
    info.workspace = ws

    -- Формируем контекст (компактно чтобы не превысить лимит)
    local lines = {
        "=== GAME ANALYSIS ===",
        "Game: " .. (info.gameName or "Unknown") .. " PlaceId:" .. tostring(info.placeId),
        "Players:" .. info.playerCount,
        "Rig:" .. (info.rigType or "?") .. " Speed:" .. tostring(info.walkSpeed) .. " Jump:" .. tostring(info.jumpPower) .. " HP:" .. tostring(info.health) .. "/" .. tostring(info.maxHealth),
    }

    if info.leaderstats and #info.leaderstats > 0 then
        table.insert(lines, "Stats: " .. table.concat(info.leaderstats, ", "))
    end

    if info.remotes and #info.remotes > 0 then
        -- Только 5 remotes чтобы не превышать лимит
        local r = {}
        for i = 1, math.min(5, #info.remotes) do r[i] = info.remotes[i] end
        table.insert(lines, "Remotes(" .. #info.remotes .. "total,top5): " .. table.concat(r, "|"))
    end

    if info.tools and #info.tools > 0 then
        table.insert(lines, "Tools: " .. table.concat(info.tools, ","))
    end
    if info.backpack and #info.backpack > 0 then
        table.insert(lines, "Backpack: " .. table.concat(info.backpack, ","))
    end

    table.insert(lines, "=== END ===")

    return table.concat(lines, "\n"), info
end

-- ================================================
-- ИСТОРИЯ
-- ================================================
local history = {}
local contextSent = false  -- флаг что контекст уже отправлен

-- ================================================
-- ЗАПРОС К GROQ
-- ================================================
local function askGroq(userMsg, callback)
    -- Контекст игры отправляем только один раз в начале
    local fullMsg = userMsg
    if gameContext ~= "" and not contextSent then
        fullMsg = gameContext .. "\nUser: " .. userMsg
        contextSent = true
    end

    table.insert(history, {role="user", content=fullMsg})

    -- Только последние 2 сообщения чтобы не превышать лимит
    if #history > 2 then
        local h2 = {}
        for i = #history - 1, #history do
            table.insert(h2, history[i])
        end
        history = h2
    end

    local messages = {{role="system", content=SYSTEM}}
    for _, m in ipairs(history) do
        table.insert(messages, m)
    end

    local body = HttpService:JSONEncode({
        model       = MODEL,
        messages    = messages,
        max_tokens  = 700,
        temperature = 0.1,
    })

    groqRequest(body, function(res, err)
        if err or not res then
            callback(nil, "HTTP: " .. tostring(err)); return
        end
        if res.StatusCode ~= 200 then
            callback(nil, "API " .. res.StatusCode .. ": " .. tostring(res.Body):sub(1, 100)); return
        end

        local ok, parsed = pcall(HttpService.JSONDecode, HttpService, res.Body)
        if not ok then callback(nil, "JSON error"); return end

        local reply = ""
        pcall(function() reply = parsed.choices[1].message.content end)
        if reply == "" then callback(nil, "Empty response"); return end

        -- Убираем markdown если ИИ добавил
        reply = reply:gsub("```lua%s*", ""):gsub("```%s*", ""):match("^%s*(.-)%s*$")

        table.insert(history, {role="assistant", content=reply})
        callback(reply, nil)
    end)
end

-- ================================================
-- АВТО-ИСПРАВЛЕНИЕ при ошибке
-- ================================================
local function askFix(errMsg, callback)
    local fixMsg = "Fix this Lua error and output ONLY the corrected code: " .. errMsg

    local messages = {
        {role="system", content=SYSTEM},
    }
    for _, m in ipairs(history) do
        table.insert(messages, m)
    end
    table.insert(messages, {role="user", content=fixMsg})

    local body = HttpService:JSONEncode({
        model=MODEL, messages=messages, max_tokens=700, temperature=0.05
    })

    groqRequest(body, function(res, err)
        if not res or res.StatusCode ~= 200 then callback(nil); return end
        local ok, parsed = pcall(HttpService.JSONDecode, HttpService, res.Body)
        if not ok then callback(nil); return end
        local reply = ""
        pcall(function() reply = parsed.choices[1].message.content end)
        reply = reply:gsub("```lua%s*", ""):gsub("```%s*", ""):match("^%s*(.-)%s*$")
        callback(reply)
    end)
end

-- ================================================
-- ВЫПОЛНИТЬ КОД
-- ================================================
local function runCode(code)
    local fn, e = loadstring(code)
    if not fn then return false, "Syntax: " .. tostring(e) end
    local ok, re = pcall(fn)
    if not ok then return false, "Runtime: " .. tostring(re) end
    return true, nil
end

-- ================================================
-- GUI
-- ================================================
local oldGui = LP.PlayerGui:FindFirstChild("PX_AI")
if oldGui then oldGui:Destroy() end

local Gui = Instance.new("ScreenGui")
Gui.Name="PX_AI"; Gui.ResetOnSpawn=false; Gui.DisplayOrder=999
Gui.Parent=LP.PlayerGui

local Main = Instance.new("Frame", Gui)
Main.Size=UDim2.new(0,310,0,460)
Main.Position=UDim2.new(0.5,-155,0.5,-230)
Main.BackgroundColor3=Color3.fromRGB(10,10,18)
Main.BorderSizePixel=0
Instance.new("UICorner",Main).CornerRadius=UDim.new(0,12)
local ms=Instance.new("UIStroke",Main)
ms.Color=Color3.fromRGB(100,0,220); ms.Thickness=1.5

-- Тайтл
local TB=Instance.new("Frame",Main)
TB.Size=UDim2.new(1,0,0,38); TB.BackgroundColor3=Color3.fromRGB(55,0,150)
TB.BorderSizePixel=0
Instance.new("UICorner",TB).CornerRadius=UDim.new(0,12)
local tbfix=Instance.new("Frame",TB)
tbfix.Size=UDim2.new(1,0,0.5,0); tbfix.Position=UDim2.new(0,0,0.5,0)
tbfix.BackgroundColor3=Color3.fromRGB(55,0,150); tbfix.BorderSizePixel=0

local TL=Instance.new("TextLabel",TB)
TL.Size=UDim2.new(1,-45,1,0); TL.Position=UDim2.new(0,12,0,0)
TL.BackgroundTransparency=1; TL.TextColor3=Color3.fromRGB(255,255,255)
TL.TextSize=13; TL.Font=Enum.Font.GothamBold
TL.Text="Primejtsu X | AI Mode"; TL.TextXAlignment=Enum.TextXAlignment.Left

local XBtn=Instance.new("TextButton",TB)
XBtn.Size=UDim2.new(0,28,0,28); XBtn.Position=UDim2.new(1,-34,0.5,-14)
XBtn.BackgroundColor3=Color3.fromRGB(160,0,50); XBtn.BorderSizePixel=0
XBtn.TextColor3=Color3.fromRGB(255,255,255); XBtn.TextSize=13
XBtn.Font=Enum.Font.GothamBold; XBtn.Text="X"; XBtn.AutoButtonColor=false
Instance.new("UICorner",XBtn).CornerRadius=UDim.new(0,6)

-- Чат
local Scroll=Instance.new("ScrollingFrame",Main)
Scroll.Size=UDim2.new(1,-12,1,-160); Scroll.Position=UDim2.new(0,6,0,44)
Scroll.BackgroundColor3=Color3.fromRGB(14,14,22); Scroll.BorderSizePixel=0
Scroll.ScrollBarThickness=3; Scroll.ScrollBarImageColor3=Color3.fromRGB(100,0,220)
Scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; Scroll.CanvasSize=UDim2.new(0,0,0,0)
Instance.new("UICorner",Scroll).CornerRadius=UDim.new(0,8)
local Layout=Instance.new("UIListLayout",Scroll)
Layout.Padding=UDim.new(0,5); Layout.SortOrder=Enum.SortOrder.LayoutOrder
local Pad=Instance.new("UIPadding",Scroll)
Pad.PaddingLeft=UDim.new(0,5); Pad.PaddingRight=UDim.new(0,5)
Pad.PaddingTop=UDim.new(0,5); Pad.PaddingBottom=UDim.new(0,5)

-- Кнопка анализа
local AnlBtn=Instance.new("TextButton",Main)
AnlBtn.Size=UDim2.new(1,-12,0,30); AnlBtn.Position=UDim2.new(0,6,1,-152)
AnlBtn.BackgroundColor3=Color3.fromRGB(0,100,180); AnlBtn.BorderSizePixel=0
AnlBtn.TextColor3=Color3.fromRGB(255,255,255); AnlBtn.TextSize=12
AnlBtn.Font=Enum.Font.GothamBold
AnlBtn.Text="Анализировать игру / Analyze Game"
AnlBtn.AutoButtonColor=false
Instance.new("UICorner",AnlBtn).CornerRadius=UDim.new(0,8)

-- Статус
local Stat=Instance.new("TextLabel",Main)
Stat.Size=UDim2.new(1,-12,0,16); Stat.Position=UDim2.new(0,6,1,-118)
Stat.BackgroundTransparency=1; Stat.TextColor3=Color3.fromRGB(140,80,220)
Stat.TextSize=10; Stat.Font=Enum.Font.Gotham; Stat.Text="Ready"
Stat.TextXAlignment=Enum.TextXAlignment.Left

-- Инпут
local IF=Instance.new("Frame",Main)
IF.Size=UDim2.new(1,-12,0,36); IF.Position=UDim2.new(0,6,1,-98)
IF.BackgroundColor3=Color3.fromRGB(20,20,32); IF.BorderSizePixel=0
Instance.new("UICorner",IF).CornerRadius=UDim.new(0,8)
Instance.new("UIStroke",IF).Color=Color3.fromRGB(80,0,180)

local Inp=Instance.new("TextBox",IF)
Inp.Size=UDim2.new(1,-46,1,0); Inp.Position=UDim2.new(0,8,0,0)
Inp.BackgroundTransparency=1; Inp.TextColor3=Color3.fromRGB(220,200,255)
Inp.PlaceholderText="Генерируй... / Generate..."
Inp.PlaceholderColor3=Color3.fromRGB(70,60,100)
Inp.TextSize=12; Inp.Font=Enum.Font.Gotham
Inp.TextXAlignment=Enum.TextXAlignment.Left
Inp.ClearTextOnFocus=false; Inp.Text=""

local SndBtn=Instance.new("TextButton",IF)
SndBtn.Size=UDim2.new(0,38,1,-4); SndBtn.Position=UDim2.new(1,-42,0,2)
SndBtn.BackgroundColor3=Color3.fromRGB(80,0,200); SndBtn.BorderSizePixel=0
SndBtn.TextColor3=Color3.fromRGB(255,255,255); SndBtn.TextSize=16
SndBtn.Font=Enum.Font.GothamBold; SndBtn.Text=">"; SndBtn.AutoButtonColor=false
Instance.new("UICorner",SndBtn).CornerRadius=UDim.new(0,6)

-- Очистить
local ClrBtn=Instance.new("TextButton",Main)
ClrBtn.Size=UDim2.new(1,-12,0,22); ClrBtn.Position=UDim2.new(0,6,1,-58)
ClrBtn.BackgroundColor3=Color3.fromRGB(22,22,36); ClrBtn.BorderSizePixel=0
ClrBtn.TextColor3=Color3.fromRGB(100,70,160); ClrBtn.TextSize=10
ClrBtn.Font=Enum.Font.Gotham; ClrBtn.Text="Очистить / Clear"
ClrBtn.AutoButtonColor=false
Instance.new("UICorner",ClrBtn).CornerRadius=UDim.new(0,6)

local Ver=Instance.new("TextLabel",Main)
Ver.Size=UDim2.new(1,0,0,14); Ver.Position=UDim2.new(0,0,1,-16)
Ver.BackgroundTransparency=1; Ver.TextColor3=Color3.fromRGB(50,50,80)
Ver.TextSize=9; Ver.Font=Enum.Font.Gotham; Ver.Text="v9.0 | @Primejtsu"

-- AI кнопка (когда скрыт)
local AIBtn=Instance.new("TextButton",Gui)
AIBtn.Size=UDim2.new(0,42,0,42); AIBtn.Position=UDim2.new(0,8,0.5,-21)
AIBtn.BackgroundColor3=Color3.fromRGB(55,0,150); AIBtn.BorderSizePixel=0
AIBtn.TextColor3=Color3.fromRGB(255,255,255); AIBtn.TextSize=13
AIBtn.Font=Enum.Font.GothamBold; AIBtn.Text="AI"
AIBtn.AutoButtonColor=false; AIBtn.Visible=false
Instance.new("UICorner",AIBtn).CornerRadius=UDim.new(0,10)
local as2=Instance.new("UIStroke",AIBtn)
as2.Color=Color3.fromRGB(150,80,255); as2.Thickness=1.5

XBtn.MouseButton1Click:Connect(function() Main.Visible=false; AIBtn.Visible=true end)
AIBtn.MouseButton1Click:Connect(function() Main.Visible=true; AIBtn.Visible=false end)

-- ================================================
-- СООБЩЕНИЕ В ЧАТ
-- ================================================
local msgCount=0
local function addMsg(text, who)
    msgCount=msgCount+1
    local bg=Instance.new("Frame",Scroll)
    bg.LayoutOrder=msgCount; bg.AutomaticSize=Enum.AutomaticSize.Y
    bg.Size=UDim2.new(1,0,0,0); bg.BorderSizePixel=0
    bg.BackgroundColor3 = who=="user" and Color3.fromRGB(50,0,120)
        or who=="ok"   and Color3.fromRGB(10,55,20)
        or who=="err"  and Color3.fromRGB(70,10,20)
        or who=="anl"  and Color3.fromRGB(10,40,70)
        or                 Color3.fromRGB(20,20,36)
    Instance.new("UICorner",bg).CornerRadius=UDim.new(0,7)
    local p=Instance.new("UIPadding",bg)
    p.PaddingLeft=UDim.new(0,7); p.PaddingRight=UDim.new(0,7)
    p.PaddingTop=UDim.new(0,5); p.PaddingBottom=UDim.new(0,5)
    local lbl=Instance.new("TextLabel",bg)
    lbl.AutomaticSize=Enum.AutomaticSize.Y; lbl.Size=UDim2.new(1,0,0,0)
    lbl.BackgroundTransparency=1
    lbl.TextColor3 = who=="user" and Color3.fromRGB(200,170,255)
        or who=="ok"   and Color3.fromRGB(100,255,120)
        or who=="err"  and Color3.fromRGB(255,100,100)
        or who=="anl"  and Color3.fromRGB(100,180,255)
        or                 Color3.fromRGB(210,210,255)
    lbl.TextSize=11; lbl.Font=Enum.Font.Gotham
    lbl.TextWrapped=true; lbl.TextXAlignment=Enum.TextXAlignment.Left
    local prefix = who=="user" and "Ты: " or who=="ok" and "Сделано: "
        or who=="err" and "Ошибка: " or who=="anl" and "Анализ: " or "AI: "
    lbl.Text=prefix..text
    task.wait(0.05)
    Scroll.CanvasPosition=Vector2.new(0,999999)
end

-- ================================================
-- УВЕДОМЛЕНИЕ
-- ================================================
local nY=0
local function notif(text, col)
    nY=nY+1
    local yp=-(52+(nY-1)*48)
    local nf=Instance.new("Frame",Gui)
    nf.Size=UDim2.new(0,320,0,38)
    nf.Position=UDim2.new(0.5,-160,1,yp+50)
    nf.BackgroundColor3=col or Color3.fromRGB(55,0,150)
    nf.BorderSizePixel=0
    Instance.new("UICorner",nf).CornerRadius=UDim.new(0,10)
    local ns=Instance.new("UIStroke",nf)
    ns.Color=Color3.fromRGB(150,80,255); ns.Thickness=1.2
    local nl=Instance.new("TextLabel",nf)
    nl.Size=UDim2.new(1,-14,1,0); nl.Position=UDim2.new(0,7,0,0)
    nl.BackgroundTransparency=1; nl.TextColor3=Color3.fromRGB(255,255,255)
    nl.TextSize=11; nl.Font=Enum.Font.GothamBold
    nl.TextWrapped=true; nl.TextXAlignment=Enum.TextXAlignment.Left
    nl.Text=text
    TweenService:Create(nf,TweenInfo.new(0.25,Enum.EasingStyle.Quart),{
        Position=UDim2.new(0.5,-160,1,yp)
    }):Play()
    task.delay(4,function()
        TweenService:Create(nf,TweenInfo.new(0.25,Enum.EasingStyle.Quart),{
            Position=UDim2.new(0.5,-160,1,yp+50)
        }):Play()
        task.wait(0.3); pcall(function()nf:Destroy()end)
        nY=math.max(0,nY-1)
    end)
end

-- ================================================
-- АНАЛИЗ
-- ================================================
AnlBtn.MouseButton1Click:Connect(function()
    AnlBtn.Text="Анализирую..."
    AnlBtn.BackgroundColor3=Color3.fromRGB(0,60,120)
    task.spawn(function()
        local ctx, info = deepAnalyze()
        gameContext = ctx

        local lines = {"Игра: "..(info.gameName or tostring(info.placeId))}
        table.insert(lines,"Игроков: "..info.playerCount)
        if info.walkSpeed then
            table.insert(lines,"Speed:"..info.walkSpeed.." Jump:"..tostring(info.jumpPower).." HP:"..tostring(info.health).."/"..tostring(info.maxHealth))
        end
        if info.leaderstats and #info.leaderstats>0 then
            table.insert(lines,"Stats: "..table.concat(info.leaderstats,", "))
        end
        if info.remotes and #info.remotes>0 then
            table.insert(lines,"Remotes("..#info.remotes.."): "..table.concat({table.unpack(info.remotes,1,math.min(5,#info.remotes))},", "))
        end
        if info.backpack and #info.backpack>0 then
            table.insert(lines,"Backpack: "..table.concat(info.backpack,", "))
        end
        if info.tools and #info.tools>0 then
            table.insert(lines,"Tools: "..table.concat(info.tools,", "))
        end

        addMsg(table.concat(lines,"\n"),"anl")
        Stat.Text="Проанализировано"
        Stat.TextColor3=Color3.fromRGB(80,200,120)
        AnlBtn.Text="Обновить анализ / Re-analyze"
        AnlBtn.BackgroundColor3=Color3.fromRGB(0,130,60)
        notif("Анализ завершён! / Done!", Color3.fromRGB(0,100,60))
    end)
end)

-- ================================================
-- ОТПРАВКА
-- ================================================
local busy=false

local function send()
    if busy then return end
    local txt=Inp.Text:match("^%s*(.-)%s*$")
    if txt=="" then return end
    Inp.Text=""

    addMsg(txt,"user")
    busy=true
    SndBtn.Text="..."
    SndBtn.BackgroundColor3=Color3.fromRGB(30,0,80)
    Stat.Text="AI думает..."
    Stat.TextColor3=Color3.fromRGB(220,160,50)

    askGroq(txt, function(code, err)
        busy=false
        SndBtn.Text=">"
        SndBtn.BackgroundColor3=Color3.fromRGB(80,0,200)

        if err then
            addMsg(err,"err")
            Stat.Text="Ошибка"; Stat.TextColor3=Color3.fromRGB(255,80,80)
            notif("Ошибка: "..err:sub(1,50), Color3.fromRGB(120,0,40))
            return
        end

        local ok, runErr = runCode(code)
        if ok then
            addMsg("Скрипт выполнен!","ok")
            Stat.Text="Выполнено"; Stat.TextColor3=Color3.fromRGB(80,220,100)
            notif("AI выполнил скрипт!", Color3.fromRGB(0,120,60))
        else
            addMsg("Ошибка, исправляю...","err")
            Stat.Text="Исправляю..."; Stat.TextColor3=Color3.fromRGB(220,160,50)

            askFix(tostring(runErr), function(fixedCode)
                if not fixedCode then
                    addMsg("Не удалось исправить: "..tostring(runErr),"err")
                    Stat.Text="Ошибка"; Stat.TextColor3=Color3.fromRGB(255,80,80)
                    return
                end
                local ok2, err2 = runCode(fixedCode)
                if ok2 then
                    addMsg("Исправлено и выполнено!","ok")
                    Stat.Text="Исправлено"; Stat.TextColor3=Color3.fromRGB(80,220,100)
                    notif("Скрипт исправлен!", Color3.fromRGB(0,120,60))
                else
                    addMsg("Не удалось: "..tostring(err2),"err")
                    Stat.Text="Ошибка"; Stat.TextColor3=Color3.fromRGB(255,80,80)
                end
            end)
        end
    end)
end

SndBtn.MouseButton1Click:Connect(send)
Inp.FocusLost:Connect(function(e) if e then send() end end)

ClrBtn.MouseButton1Click:Connect(function()
    for _,v in pairs(Scroll:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
    history={}; msgCount=0; gameContext=""; contextSent=false
    Stat.Text="Ready"; Stat.TextColor3=Color3.fromRGB(140,80,220)
end)

-- ================================================
-- DRAGGABLE
-- ================================================
local drg,ds,sp=false,nil,nil
TB.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1
    or i.UserInputType==Enum.UserInputType.Touch then
        drg=true; ds=i.Position; sp=Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if not drg then return end
    if i.UserInputType==Enum.UserInputType.MouseMovement
    or i.UserInputType==Enum.UserInputType.Touch then
        local d=i.Position-ds
        Main.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1
    or i.UserInputType==Enum.UserInputType.Touch then drg=false end
end)

-- ================================================
-- СТАРТ
-- ================================================
task.wait(0.8)
notif("Primejtsu X | AI Mode v9 Loaded!", Color3.fromRGB(55,0,150))
task.wait(1.2)
notif("Спасибо что выбрали нас! / Thank you!", Color3.fromRGB(80,0,200))
addMsg("Привет! Напиши что создать.\nПример: генерируй флай\nПример: сделай есп\nПример: отключи флай\nСначала нажми Analyze для лучших результатов!", "ai")
print("[PX] AI Mode v9 Loaded!")
