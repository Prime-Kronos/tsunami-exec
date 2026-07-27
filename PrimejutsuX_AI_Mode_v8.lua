-- ================================================
--   Primejtsu X | AI Mode v5
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
local currentKeyIndex = 1

local function getKey()
    return GROQ_KEYS[currentKeyIndex]
end

local function nextKey()
    currentKeyIndex = currentKeyIndex + 1
    if currentKeyIndex > #GROQ_KEYS then
        currentKeyIndex = 1
    end
    return GROQ_KEYS[currentKeyIndex]
end
local GROQ_URL = "https://api.groq.com/openai/v1/chat/completions"
local MODEL = "llama-3.1-8b-instant"

-- ================================================
-- HTTP
-- ================================================
local function httpReq(url, method, headers, body)
    local fn = request or http_request or (syn and syn.request)
    if not fn then return nil, "No HTTP function" end
    local ok, res = pcall(fn, {Url=url, Method=method, Headers=headers, Body=body})
    if not ok then return nil, tostring(res) end
    return res, nil
end

-- ================================================
-- ХРАНИЛИЩЕ СГЕНЕРИРОВАННОГО КОДА
-- Ключ = тема (fly, esp, aimbot и т.д.)
-- Значение = последний сгенерированный код
-- ================================================
local codeStore = {}
local gameContext = ""

-- ================================================
-- ЖЁСТКИЙ АНАЛИЗАТОР
-- ================================================
local function deepAnalyze()
    local RS2 = game:GetService("ReplicatedStorage")
    local SS   = game:GetService("ServerStorage")
    local info = {
        placeId      = game.PlaceId,
        placeVersion = game.PlaceVersion,
        jobId        = game.JobId:sub(1,8),
        playerCount  = #Players:GetPlayers(),
    }

    -- Название игры
    pcall(function()
        info.gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    end)

    -- Все RemoteEvents и RemoteFunctions
    local remotes = {}
    pcall(function()
        for _, v in pairs(RS2:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                table.insert(remotes, v:GetFullName())
            end
        end
    end)
    info.remotes = remotes

    -- Персонаж
    local char = LP.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            info.walkSpeed   = hum.WalkSpeed
            info.jumpPower   = hum.JumpPower
            info.jumpHeight  = hum.JumpHeight
            info.health      = hum.Health
            info.maxHealth   = hum.MaxHealth
            info.rigType     = tostring(hum.RigType)
        end
        -- Инструменты
        local tools = {}
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("Tool") then table.insert(tools, v.Name) end
        end
        info.tools = tools

        -- Части тела
        local parts = {}
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("BasePart") then table.insert(parts, v.Name) end
        end
        info.bodyParts = parts
    end

    -- Backpack инструменты
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        local bpTools = {}
        for _, v in pairs(bp:GetChildren()) do
            table.insert(bpTools, v.Name.."("..v.ClassName..")")
        end
        info.backpack = bpTools
    end

    -- PlayerGui
    local pg = LP:FindFirstChild("PlayerGui")
    if pg then
        local guis = {}
        for _, v in pairs(pg:GetChildren()) do
            table.insert(guis, v.Name.."("..v.ClassName..")")
        end
        info.playerGui = guis
    end

    -- leaderstats
    local ls = LP:FindFirstChild("leaderstats")
    if ls then
        local stats = {}
        for _, v in pairs(ls:GetChildren()) do
            table.insert(stats, v.Name.."="..tostring(v.Value))
        end
        info.leaderstats = stats
    end

    -- Workspace топ-объекты
    local ws = {}
    for _, v in pairs(workspace:GetChildren()) do
        table.insert(ws, v.Name.."("..v.ClassName..")")
    end
    info.workspace = ws

    -- Lighting
    local L = game:GetService("Lighting")
    info.lighting = {
        brightness  = L.Brightness,
        clockTime   = L.ClockTime,
        fogEnd      = L.FogEnd,
    }

    -- Формируем контекст для ИИ
    local lines = {
        "=== GAME ANALYSIS ===",
        "Game: " .. (info.gameName or "Unknown") .. " | PlaceId: " .. tostring(info.placeId),
        "Players online: " .. info.playerCount,
        "RigType: " .. (info.rigType or "?"),
        "WalkSpeed: " .. tostring(info.walkSpeed) .. " | JumpPower: " .. tostring(info.jumpPower),
        "Health: " .. tostring(info.health) .. "/" .. tostring(info.maxHealth),
    }

    if info.leaderstats and #info.leaderstats > 0 then
        table.insert(lines, "Leaderstats: " .. table.concat(info.leaderstats, ", "))
    end

    if info.remotes and #info.remotes > 0 then
        -- Показываем только первые 15
        local r = {}
        for i=1, math.min(15, #info.remotes) do r[i]=info.remotes[i] end
        table.insert(lines, "RemoteEvents (" .. #info.remotes .. " total): " .. table.concat(r, " | "))
    end

    if info.tools and #info.tools > 0 then
        table.insert(lines, "Tools in hand: " .. table.concat(info.tools, ", "))
    end

    if info.backpack and #info.backpack > 0 then
        table.insert(lines, "Backpack: " .. table.concat(info.backpack, ", "))
    end

    if info.bodyParts and #info.bodyParts > 0 then
        table.insert(lines, "Body parts: " .. table.concat(info.bodyParts, ", "))
    end

    table.insert(lines, "Workspace objects: " .. table.concat(info.workspace or {}, ", "))
    table.insert(lines, "=== END ANALYSIS ===")

    return table.concat(lines, "\n"), info
end

-- ================================================
-- СИСТЕМНЫЙ ПРОМПТ
-- ================================================
local SYSTEM = "Roblox Lua cheat generator for executor. Output ONLY raw Lua code. No markdown, no backticks, no comments. Use _G to store RBXScriptConnections. pcall everything. Fly=BodyVelocity+BodyGyro+PlatformStand stored in _G.PX_Fly. ESP=Highlight AlwaysOnTop stored in _G.PX_ESP table. Aimbot=Camera lerp to nearest Head stored in _G.PX_Aim. Noclip=Stepped CanCollide false stored in _G.PX_Noclip. Speed=WalkSpeed. GUI=ScreenGui in PlayerGui stored in _G.PX_Gui. Disable=disconnect _G connection and destroy instances. Output ONLY Lua code."

-- ================================================
-- ИСТОРИЯ
-- ================================================
local history = {}

-- ================================================
-- ЗАПРОС К GROQ
-- ================================================
local function askGroq(userMsg, callback)
    local fullMsg = userMsg
    -- Добавляем контекст только если это первый запрос
    if gameContext ~= "" and #history == 0 then
        fullMsg = gameContext .. "\nUser request: " .. userMsg
    end

    table.insert(history, {role="user", content=fullMsg})

    local messages = {{role="system", content=SYSTEM}}
    -- Только последние 4 сообщения чтобы не превысить лимит
    local start = math.max(1, #history - 3)
    for i = start, #history do
        table.insert(messages, history[i])
    end

    local bodyStr = HttpService:JSONEncode({
        model       = MODEL,
        messages    = messages,
        max_tokens  = 600,
        temperature = 0.05,
    })

    task.spawn(function()
        local tried = 0
        local res, err

        repeat
            tried = tried + 1
            local key = GROQ_KEYS[currentKeyIndex]

            res, err = httpReq(
                GROQ_URL, "POST",
                {["Content-Type"]="application/json", ["Authorization"]="Bearer "..key},
                bodyStr
            )

            if err or not res then
                currentKeyIndex = currentKeyIndex % #GROQ_KEYS + 1
            elseif res.StatusCode == 429 then
                print("[PX AI] Key #"..currentKeyIndex.." rate limited, switching...")
                currentKeyIndex = currentKeyIndex % #GROQ_KEYS + 1
                task.wait(0.3)
            else
                break
            end
        until tried >= #GROQ_KEYS

        if err or not res then
            callback(nil, "HTTP: " .. tostring(err)); return
        end
        if res.StatusCode ~= 200 then
            callback(nil, "API "..tostring(res.StatusCode)..": "..tostring(res.Body):sub(1,100)); return
        end

        local ok, parsed = pcall(HttpService.JSONDecode, HttpService, res.Body)
        if not ok then callback(nil, "JSON error"); return end

        local reply = ""
        pcall(function() reply = parsed.choices[1].message.content end)
        if reply == "" then callback(nil, "Empty response"); return end

        reply = reply:gsub("```lua%s*", ""):gsub("```%s*", ""):match("^%s*(.-)%s*$")

        table.insert(history, {role="assistant", content=reply})

        -- Чистим старую историю чтобы не росла бесконечно
        if #history > 10 then
            local newHistory = {}
            for i = #history - 7, #history do
                table.insert(newHistory, history[i])
            end
            history = newHistory
        end

        callback(reply, nil)
    end)
end

-- ================================================
-- ВЫПОЛНИТЬ КОД
-- ================================================
local function runCode(code)
    local fn, e = loadstring(code)
    if not fn then return false, "Syntax: "..tostring(e) end
    local ok, re = pcall(fn)
    if not ok then return false, "Runtime: "..tostring(re) end
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

-- Главное окно
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
TB.Size=UDim2.new(1,0,0,38)
TB.BackgroundColor3=Color3.fromRGB(55,0,150)
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
Scroll.Size=UDim2.new(1,-12,1,-160)
Scroll.Position=UDim2.new(0,6,0,44)
Scroll.BackgroundColor3=Color3.fromRGB(14,14,22)
Scroll.BorderSizePixel=0
Scroll.ScrollBarThickness=3
Scroll.ScrollBarImageColor3=Color3.fromRGB(100,0,220)
Scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
Scroll.CanvasSize=UDim2.new(0,0,0,0)
Instance.new("UICorner",Scroll).CornerRadius=UDim.new(0,8)
local Layout=Instance.new("UIListLayout",Scroll)
Layout.Padding=UDim.new(0,5); Layout.SortOrder=Enum.SortOrder.LayoutOrder
local Pad=Instance.new("UIPadding",Scroll)
Pad.PaddingLeft=UDim.new(0,5); Pad.PaddingRight=UDim.new(0,5)
Pad.PaddingTop=UDim.new(0,5); Pad.PaddingBottom=UDim.new(0,5)

-- Кнопка анализа
local AnlBtn=Instance.new("TextButton",Main)
AnlBtn.Size=UDim2.new(1,-12,0,30)
AnlBtn.Position=UDim2.new(0,6,1,-152)
AnlBtn.BackgroundColor3=Color3.fromRGB(0,100,180)
AnlBtn.BorderSizePixel=0
AnlBtn.TextColor3=Color3.fromRGB(255,255,255)
AnlBtn.TextSize=12; AnlBtn.Font=Enum.Font.GothamBold
AnlBtn.Text="Анализировать игру / Analyze Game"
AnlBtn.AutoButtonColor=false
Instance.new("UICorner",AnlBtn).CornerRadius=UDim.new(0,8)

-- Статус
local Stat=Instance.new("TextLabel",Main)
Stat.Size=UDim2.new(1,-12,0,16)
Stat.Position=UDim2.new(0,6,1,-118)
Stat.BackgroundTransparency=1
Stat.TextColor3=Color3.fromRGB(140,80,220)
Stat.TextSize=10; Stat.Font=Enum.Font.Gotham
Stat.Text="Ready / Готов"
Stat.TextXAlignment=Enum.TextXAlignment.Left

-- Инпут
local IF=Instance.new("Frame",Main)
IF.Size=UDim2.new(1,-12,0,36)
IF.Position=UDim2.new(0,6,1,-98)
IF.BackgroundColor3=Color3.fromRGB(20,20,32)
IF.BorderSizePixel=0
Instance.new("UICorner",IF).CornerRadius=UDim.new(0,8)
Instance.new("UIStroke",IF).Color=Color3.fromRGB(80,0,180)

local Inp=Instance.new("TextBox",IF)
Inp.Size=UDim2.new(1,-46,1,0); Inp.Position=UDim2.new(0,8,0,0)
Inp.BackgroundTransparency=1
Inp.TextColor3=Color3.fromRGB(220,200,255)
Inp.PlaceholderText="Генерируй... / Generate..."
Inp.PlaceholderColor3=Color3.fromRGB(70,60,100)
Inp.TextSize=12; Inp.Font=Enum.Font.Gotham
Inp.TextXAlignment=Enum.TextXAlignment.Left
Inp.ClearTextOnFocus=false; Inp.Text=""

local SndBtn=Instance.new("TextButton",IF)
SndBtn.Size=UDim2.new(0,38,1,-4); SndBtn.Position=UDim2.new(1,-42,0,2)
SndBtn.BackgroundColor3=Color3.fromRGB(80,0,200)
SndBtn.BorderSizePixel=0
SndBtn.TextColor3=Color3.fromRGB(255,255,255)
SndBtn.TextSize=16; SndBtn.Font=Enum.Font.GothamBold
SndBtn.Text=">"; SndBtn.AutoButtonColor=false
Instance.new("UICorner",SndBtn).CornerRadius=UDim.new(0,6)

-- Очистить
local ClrBtn=Instance.new("TextButton",Main)
ClrBtn.Size=UDim2.new(1,-12,0,22)
ClrBtn.Position=UDim2.new(0,6,1,-58)
ClrBtn.BackgroundColor3=Color3.fromRGB(22,22,36)
ClrBtn.BorderSizePixel=0
ClrBtn.TextColor3=Color3.fromRGB(100,70,160)
ClrBtn.TextSize=10; ClrBtn.Font=Enum.Font.Gotham
ClrBtn.Text="Очистить / Clear"
ClrBtn.AutoButtonColor=false
Instance.new("UICorner",ClrBtn).CornerRadius=UDim.new(0,6)

-- Версия
local Ver=Instance.new("TextLabel",Main)
Ver.Size=UDim2.new(1,0,0,14); Ver.Position=UDim2.new(0,0,1,-16)
Ver.BackgroundTransparency=1; Ver.TextColor3=Color3.fromRGB(50,50,80)
Ver.TextSize=9; Ver.Font=Enum.Font.Gotham; Ver.Text="v5.0 | @Primejtsu"

-- Кнопка AI (когда скрыт)
local AIBtn=Instance.new("TextButton",Gui)
AIBtn.Size=UDim2.new(0,42,0,42); AIBtn.Position=UDim2.new(0,8,0.5,-21)
AIBtn.BackgroundColor3=Color3.fromRGB(55,0,150)
AIBtn.BorderSizePixel=0; AIBtn.TextColor3=Color3.fromRGB(255,255,255)
AIBtn.TextSize=13; AIBtn.Font=Enum.Font.GothamBold
AIBtn.Text="AI"; AIBtn.AutoButtonColor=false; AIBtn.Visible=false
Instance.new("UICorner",AIBtn).CornerRadius=UDim.new(0,10)
local as=Instance.new("UIStroke",AIBtn)
as.Color=Color3.fromRGB(150,80,255); as.Thickness=1.5

XBtn.MouseButton1Click:Connect(function() Main.Visible=false; AIBtn.Visible=true end)
AIBtn.MouseButton1Click:Connect(function() Main.Visible=true; AIBtn.Visible=false end)

-- ================================================
-- ДОБАВИТЬ СООБЩЕНИЕ В ЧАТ
-- ================================================
local msgCount = 0
local function addMsg(text, who)
    msgCount=msgCount+1
    local bg=Instance.new("Frame",Scroll)
    bg.LayoutOrder=msgCount
    bg.AutomaticSize=Enum.AutomaticSize.Y
    bg.Size=UDim2.new(1,0,0,0)
    bg.BorderSizePixel=0
    bg.BackgroundColor3 = who=="user" and Color3.fromRGB(50,0,120)
        or who=="ok"    and Color3.fromRGB(10,55,20)
        or who=="err"   and Color3.fromRGB(70,10,20)
        or who=="anl"   and Color3.fromRGB(10,40,70)
        or                   Color3.fromRGB(20,20,36)
    Instance.new("UICorner",bg).CornerRadius=UDim.new(0,7)
    local p=Instance.new("UIPadding",bg)
    p.PaddingLeft=UDim.new(0,7); p.PaddingRight=UDim.new(0,7)
    p.PaddingTop=UDim.new(0,5);  p.PaddingBottom=UDim.new(0,5)

    local prefix = who=="user" and "Ты: "
        or who=="ok"    and "Сделано: "
        or who=="err"   and "Ошибка: "
        or who=="anl"   and "Анализ: "
        or                   "AI: "

    local lbl=Instance.new("TextLabel",bg)
    lbl.AutomaticSize=Enum.AutomaticSize.Y
    lbl.Size=UDim2.new(1,0,0,0)
    lbl.BackgroundTransparency=1
    lbl.TextColor3 = who=="user" and Color3.fromRGB(200,170,255)
        or who=="ok"    and Color3.fromRGB(100,255,120)
        or who=="err"   and Color3.fromRGB(255,100,100)
        or who=="anl"   and Color3.fromRGB(100,180,255)
        or                   Color3.fromRGB(210,210,255)
    lbl.TextSize=11; lbl.Font=Enum.Font.Gotham
    lbl.TextWrapped=true; lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.Text=prefix..text

    task.wait(0.05)
    Scroll.CanvasPosition=Vector2.new(0,999999)
end

-- ================================================
-- УВЕДОМЛЕНИЕ
-- ================================================
local notifY=0
local function notif(text, col)
    notifY=notifY+1
    local yp=-(52+(notifY-1)*48)
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
        task.wait(0.3)
        pcall(function()nf:Destroy()end)
        notifY=math.max(0,notifY-1)
    end)
end

-- ================================================
-- АНАЛИЗ
-- ================================================
AnlBtn.MouseButton1Click:Connect(function()
    AnlBtn.Text="Анализирую... / Analyzing..."
    AnlBtn.BackgroundColor3=Color3.fromRGB(0,60,120)
    task.spawn(function()
        local ctx, info = deepAnalyze()
        gameContext = ctx

        -- Показываем результат в чате
        local lines = {}
        table.insert(lines, "Игра: "..(info.gameName or tostring(info.placeId)))
        table.insert(lines, "Игроков: "..info.playerCount)
        if info.walkSpeed then
            table.insert(lines, "Speed: "..info.walkSpeed.." | Jump: "..tostring(info.jumpPower))
        end
        if info.leaderstats and #info.leaderstats>0 then
            table.insert(lines, "Stats: "..table.concat(info.leaderstats,", "))
        end
        if info.remotes and #info.remotes>0 then
            table.insert(lines, "Remotes("..#info.remotes.."): "..table.concat({table.unpack(info.remotes,1,math.min(5,#info.remotes))},", "))
        end
        if info.backpack and #info.backpack>0 then
            table.insert(lines, "Backpack: "..table.concat(info.backpack,", "))
        end

        addMsg(table.concat(lines,"\n"), "anl")
        Stat.Text="Игра проанализирована / Analyzed"
        Stat.TextColor3=Color3.fromRGB(80,200,120)
        AnlBtn.Text="Обновить анализ / Re-analyze"
        AnlBtn.BackgroundColor3=Color3.fromRGB(0,130,60)
        notif("Анализ завершён! / Analysis done!", Color3.fromRGB(0,100,60))
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
    Stat.Text="AI думает... / Thinking..."
    Stat.TextColor3=Color3.fromRGB(220,160,50)

    askGroq(txt, function(code, err)
        busy=false
        SndBtn.Text=">"
        SndBtn.BackgroundColor3=Color3.fromRGB(80,0,200)

        if err then
            addMsg(err,"err")
            Stat.Text="Ошибка / Error"
            Stat.TextColor3=Color3.fromRGB(255,80,80)
            notif("Ошибка / Error", Color3.fromRGB(120,0,40))
            return
        end

        -- НЕ показываем код — только результат
        local ok, runErr = runCode(code)
        if ok then
            addMsg("Скрипт выполнен успешно!", "ok")
            Stat.Text="Выполнено / Done"
            Stat.TextColor3=Color3.fromRGB(80,220,100)
            notif("AI выполнил скрипт!", Color3.fromRGB(0,120,60))
        else
            -- Пробуем исправить автоматически
            addMsg("Ошибка, пробую исправить...", "err")
            -- Просим ИИ исправить
            table.insert(history, {role="user", content="Fix this error in your last code: "..tostring(runErr)})
            local msgs2 = {{role="system",content=SYSTEM}}
            local s2 = math.max(1,#history-9)
            for i=s2,#history do table.insert(msgs2,history[i]) end
            local b2 = HttpService:JSONEncode({model=MODEL,messages=msgs2,max_tokens=1200,temperature=0.05})
            task.spawn(function()
                local res2,e2 = httpReq(GROQ_URL,"POST",
                    {["Content-Type"]="application/json",["Authorization"]="Bearer "..GROQ_KEY},b2)
                if res2 and res2.StatusCode==200 then
                    local ok2,p2=pcall(HttpService.JSONDecode,HttpService,res2.Body)
                    if ok2 then
                        local code2=""
                        pcall(function()code2=p2.choices[1].message.content end)
                        code2=code2:gsub("```lua%s*",""):gsub("```%s*",""):match("^%s*(.-)%s*$")
                        local ok3,e3=runCode(code2)
                        if ok3 then
                            addMsg("Исправлено и выполнено!","ok")
                            Stat.Text="Исправлено / Fixed"
                            Stat.TextColor3=Color3.fromRGB(80,220,100)
                            notif("Скрипт исправлен и выполнен!",Color3.fromRGB(0,120,60))
                        else
                            addMsg("Не удалось: "..tostring(e3),"err")
                            Stat.Text="Ошибка / Error"
                            Stat.TextColor3=Color3.fromRGB(255,80,80)
                        end
                    end
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
    history={}; msgCount=0; gameContext=""
    Stat.Text="Ready / Готов"
    Stat.TextColor3=Color3.fromRGB(140,80,220)
end)

-- ================================================
-- DRAGGABLE
-- ================================================
local drg,ds,sp=false,nil,nil
TB.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1
    or i.UserInputType==Enum.UserInputType.Touch then
        drg=true;ds=i.Position;sp=Main.Position
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
notif("Primejtsu X | AI Mode v5 — Loaded!", Color3.fromRGB(55,0,150))
task.wait(1.2)
notif("Спасибо что выбрали нас! / Thank you for choosing us!", Color3.fromRGB(80,0,200))
addMsg("Привет! Напиши что создать.\nПример: генерируй флай\nПример: создай пустой GUI\nПример: добавь ESP в GUI\nПример: отключи флай\nНажми Analyze для анализа игры!", "ai")
print("[Primejtsu X] AI Mode v5 Loaded!")
