-- ================================================
--   Primejtsu X | AI v2.0
--   Deep Analyzer + Smart AI
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

local function groqRequest(messages, callback)
    local body = HttpService:JSONEncode({
        model=MODEL, messages=messages, max_tokens=700, temperature=0.05
    })
    task.spawn(function()
        local tried, res, err = 0, nil, nil
        repeat
            tried = tried + 1
            res, err = httpReq(GROQ_URL, "POST", {
                ["Content-Type"]  = "application/json",
                ["Authorization"] = "Bearer " .. GROQ_KEYS[keyIdx],
            }, body)
            if (not res) or (res and (res.StatusCode==429 or res.StatusCode==413)) then
                keyIdx = keyIdx % #GROQ_KEYS + 1
                task.wait(0.3)
            else break end
        until tried >= #GROQ_KEYS
        callback(res, err)
    end)
end

-- ================================================
-- ЖЁСТКИЙ АНАЛИЗАТОР — узнаёт ВСЁ об игре
-- ================================================
local gameContext = ""
local gameInfo    = {}

local function deepAnalyze()
    local info = {}

    -- Название + PlaceId
    info.placeId = game.PlaceId
    info.placeVersion = game.PlaceVersion
    pcall(function()
        local prod = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
        info.gameName    = prod.Name
        info.gameCreator = prod.Creator and prod.Creator.Name or "?"
    end)

    -- Игроки
    info.playerCount = #Players:GetPlayers()
    info.players = {}
    for _, p in pairs(Players:GetPlayers()) do
        local pInfo = {name=p.Name, displayName=p.DisplayName}
        if p.Character then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum then
                pInfo.health    = math.floor(hum.Health)
                pInfo.maxHealth = math.floor(hum.MaxHealth)
                pInfo.walkSpeed = hum.WalkSpeed
                pInfo.jumpPower = hum.JumpPower
                pInfo.rigType   = tostring(hum.RigType)
            end
        end
        local ls = p:FindFirstChild("leaderstats")
        if ls then
            pInfo.stats = {}
            for _, v in pairs(ls:GetChildren()) do
                table.insert(pInfo.stats, v.Name.."="..tostring(v.Value))
            end
        end
        table.insert(info.players, pInfo)
    end

    -- Локальный игрок детально
    local myChar = LP.Character
    if myChar then
        local hum = myChar:FindFirstChild("Humanoid")
        if hum then
            info.mySpeed    = hum.WalkSpeed
            info.myJump     = hum.JumpPower
            info.myHP       = math.floor(hum.Health)
            info.myMaxHP    = math.floor(hum.MaxHealth)
            info.myRig      = tostring(hum.RigType)
            info.myState    = tostring(hum:GetState())
        end
        -- Инструменты в руках
        info.myTools = {}
        for _, v in pairs(myChar:GetChildren()) do
            if v:IsA("Tool") then table.insert(info.myTools, v.Name) end
        end
        -- Части тела
        info.myParts = {}
        for _, v in pairs(myChar:GetChildren()) do
            if v:IsA("BasePart") then table.insert(info.myParts, v.Name) end
        end
    end

    -- Backpack
    info.backpack = {}
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        for _, v in pairs(bp:GetChildren()) do
            table.insert(info.backpack, v.Name.."("..v.ClassName..")")
        end
    end

    -- Leaderstats
    info.myStats = {}
    local ls = LP:FindFirstChild("leaderstats")
    if ls then
        for _, v in pairs(ls:GetChildren()) do
            table.insert(info.myStats, v.Name.."="..tostring(v.Value).."("..v.ClassName..")")
        end
    end

    -- PlayerGui — что есть в UI игры
    info.guiItems = {}
    local pg = LP:FindFirstChild("PlayerGui")
    if pg then
        for _, v in pairs(pg:GetChildren()) do
            if not v.Name:find("PX_") then
                table.insert(info.guiItems, v.Name.."("..v.ClassName..")")
            end
        end
    end

    -- ReplicatedStorage — ВСЕ RemoteEvents и RemoteFunctions
    info.remoteEvents    = {}
    info.remoteFunctions = {}
    info.folders         = {}
    info.modules         = {}
    pcall(function()
        for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if v:IsA("RemoteEvent") then
                table.insert(info.remoteEvents, v:GetFullName())
            elseif v:IsA("RemoteFunction") then
                table.insert(info.remoteFunctions, v:GetFullName())
            elseif v:IsA("Folder") then
                table.insert(info.folders, v:GetFullName())
            elseif v:IsA("ModuleScript") then
                table.insert(info.modules, v.Name)
            end
        end
    end)

    -- Workspace — объекты в мире
    info.worldObjects = {}
    for _, v in pairs(workspace:GetChildren()) do
        local entry = v.Name.."("..v.ClassName..")"
        if v:IsA("Model") then
            -- Считаем дочерние объекты
            local childCount = #v:GetChildren()
            entry = entry.."["..childCount.."children]"
        end
        table.insert(info.worldObjects, entry)
    end

    -- Lighting
    local L = game:GetService("Lighting")
    info.lighting = {
        brightness  = L.Brightness,
        clockTime   = L.ClockTime,
        fogEnabled  = L.FogEnd < 10000,
    }

    -- SoundService
    info.sounds = {}
    pcall(function()
        for _, v in pairs(game:GetService("SoundService"):GetChildren()) do
            table.insert(info.sounds, v.Name.."("..v.ClassName..")")
        end
    end)

    -- Teams
    info.teams = {}
    pcall(function()
        for _, v in pairs(game:GetService("Teams"):GetChildren()) do
            table.insert(info.teams, v.Name)
        end
    end)

    -- Badges и GamePasses через MarketplaceService не доступны клиенту напрямую
    -- Но можем найти через StarterPack
    info.starterItems = {}
    pcall(function()
        for _, v in pairs(game:GetService("StarterPack"):GetChildren()) do
            table.insert(info.starterItems, v.Name.."("..v.ClassName..")")
        end
    end)

    gameInfo = info
    return info
end

local function buildContext(info)
    local lines = {}

    -- Основное
    table.insert(lines, "=== GAME INFO ===")
    table.insert(lines, "Name: "..(info.gameName or "?").." | Creator: "..(info.gameCreator or "?").." | PlaceId: "..tostring(info.placeId))
    table.insert(lines, "Players online: "..info.playerCount)

    -- Мой персонаж
    if info.myHP then
        table.insert(lines, "=== MY CHARACTER ===")
        table.insert(lines, "HP: "..info.myHP.."/"..info.myMaxHP.." | Speed: "..info.mySpeed.." | Jump: "..info.myJump.." | Rig: "..info.myRig)
    end
    if #info.myStats > 0 then
        table.insert(lines, "My Stats: "..table.concat(info.myStats, ", "))
    end
    if #info.myTools > 0 then
        table.insert(lines, "Tools in hand: "..table.concat(info.myTools, ", "))
    end
    if #info.backpack > 0 then
        table.insert(lines, "Backpack: "..table.concat(info.backpack, ", "))
    end

    -- Другие игроки
    if #info.players > 0 then
        table.insert(lines, "=== OTHER PLAYERS ===")
        for _, p in ipairs(info.players) do
            if p.name ~= LP.Name then
                local pline = p.name
                if p.health then pline = pline.." HP:"..p.health.."/"..p.maxHealth end
                if p.stats and #p.stats > 0 then pline = pline.." ["..table.concat(p.stats,",").."]" end
                table.insert(lines, pline)
            end
        end
    end

    -- RemoteEvents (самые важные)
    if #info.remoteEvents > 0 then
        table.insert(lines, "=== REMOTE EVENTS ("..#info.remoteEvents..") ===")
        for i=1, math.min(15, #info.remoteEvents) do
            table.insert(lines, info.remoteEvents[i])
        end
        if #info.remoteEvents > 15 then
            table.insert(lines, "...and "..(#info.remoteEvents-15).." more")
        end
    end

    -- RemoteFunctions
    if #info.remoteFunctions > 0 then
        table.insert(lines, "=== REMOTE FUNCTIONS ("..#info.remoteFunctions..") ===")
        for i=1, math.min(8, #info.remoteFunctions) do
            table.insert(lines, info.remoteFunctions[i])
        end
    end

    -- Folders и Modules
    if #info.folders > 0 then
        table.insert(lines, "=== FOLDERS ===")
        table.insert(lines, table.concat(info.folders, " | "):sub(1, 200))
    end
    if #info.modules > 0 then
        table.insert(lines, "=== MODULES ===")
        table.insert(lines, table.concat(info.modules, ", "):sub(1, 150))
    end

    -- Мир
    if #info.worldObjects > 0 then
        table.insert(lines, "=== WORKSPACE ===")
        table.insert(lines, table.concat(info.worldObjects, " | "):sub(1, 300))
    end

    -- Teams
    if #info.teams > 0 then
        table.insert(lines, "Teams: "..table.concat(info.teams, ", "))
    end

    -- GUI игры
    if #info.guiItems > 0 then
        table.insert(lines, "Game GUI: "..table.concat(info.guiItems, ", "):sub(1, 150))
    end

    table.insert(lines, "=== END ===")

    return table.concat(lines, "\n")
end

local SYSTEM = "You are an elite Roblox Lua exploit script developer running inside a Roblox game executor called Delta. You have been given a DEEP GAME ANALYSIS that tells you EVERYTHING about the current game: its name, all RemoteEvents, RemoteFunctions, player stats, items, world objects, GUI elements, and more. You MUST use this analysis to write game-specific scripts. STRICT RULES: 1) Output ONLY raw executable Lua code. Absolutely no markdown, no backticks, no explanation, no comments, no text whatsoever. 2) Always use the exact RemoteEvent paths from the analysis when firing server actions. Access them via: game:GetService('ReplicatedStorage'):FindFirstChild('EventName', true):FireServer(args). 3) Store all RunService connections in _G so they can be disabled: _G.PX_Fly, _G.PX_ESP etc. 4) Always wrap ALL code in pcall(function() ... end). 5) LocalPlayer = game.Players.LocalPlayer. 6) When user says disable/отключи/stop/убери/выкл — generate cleanup Lua code that disconnects _G connections and destroys created instances. 7) Use exact data from the game analysis to make scripts that actually work in THIS specific game. 8) Output ONLY Lua code. Nothing else. Ever."

-- ================================================
-- ЗАПРОС К AI
-- ================================================
local history = {}

local function askAI(userMsg, callback)
    -- Системный промпт + контекст игры
    local sysContent = SYSTEM
    if gameContext ~= "" then
        sysContent = SYSTEM .. "\n\nDEEP GAME ANALYSIS:\n" .. gameContext
    end

    table.insert(history, {role="user", content=userMsg})

    -- Последние 3 сообщения
    if #history > 3 then
        local h2 = {}
        for i=#history-2, #history do table.insert(h2, history[i]) end
        history = h2
    end

    local messages = {{role="system", content=sysContent}}
    for _, m in ipairs(history) do table.insert(messages, m) end

    groqRequest(messages, function(res, err)
        if err or not res then callback(nil,"HTTP: "..tostring(err)); return end
        if res.StatusCode ~= 200 then
            callback(nil,"API "..res.StatusCode..": "..tostring(res.Body):sub(1,100)); return
        end
        local ok, parsed = pcall(HttpService.JSONDecode, HttpService, res.Body)
        if not ok then callback(nil,"JSON error"); return end
        local reply = ""
        pcall(function() reply = parsed.choices[1].message.content end)
        if reply == "" then callback(nil,"Empty response"); return end
        reply = reply:gsub("```lua%s*",""):gsub("```%s*",""):match("^%s*(.-)%s*$")
        table.insert(history, {role="assistant", content=reply})
        callback(reply, nil)
    end)
end

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
local oldGui = LP.PlayerGui:FindFirstChild("PX_AI2")
if oldGui then oldGui:Destroy() end

local Gui = Instance.new("ScreenGui")
Gui.Name="PX_AI2"; Gui.ResetOnSpawn=false; Gui.DisplayOrder=999
Gui.Parent=LP.PlayerGui

-- Главный фрейм — снизу экрана горизонтальный
local Main = Instance.new("Frame",Gui)
Main.Size=UDim2.new(1,-16,0,180)
Main.Position=UDim2.new(0,8,1,-188)
Main.BackgroundColor3=Color3.fromRGB(8,8,15)
Main.BorderSizePixel=0
Instance.new("UICorner",Main).CornerRadius=UDim.new(0,10)
local ms=Instance.new("UIStroke",Main)
ms.Color=Color3.fromRGB(100,0,220); ms.Thickness=1.5

-- Тайтл
local TB=Instance.new("Frame",Main)
TB.Size=UDim2.new(1,0,0,28); TB.BackgroundColor3=Color3.fromRGB(55,0,150)
TB.BorderSizePixel=0
Instance.new("UICorner",TB).CornerRadius=UDim.new(0,10)
local tbfix=Instance.new("Frame",TB)
tbfix.Size=UDim2.new(1,0,0.5,0); tbfix.Position=UDim2.new(0,0,0.5,0)
tbfix.BackgroundColor3=Color3.fromRGB(55,0,150); tbfix.BorderSizePixel=0

local TL=Instance.new("TextLabel",TB)
TL.Size=UDim2.new(1,-100,1,0); TL.Position=UDim2.new(0,10,0,0)
TL.BackgroundTransparency=1; TL.TextColor3=Color3.fromRGB(255,255,255)
TL.TextSize=12; TL.Font=Enum.Font.GothamBold
TL.Text="Primejtsu X | AI v2.0"; TL.TextXAlignment=Enum.TextXAlignment.Left

local function mkBtn(txt, xOff, col, w)
    local b=Instance.new("TextButton",TB)
    b.Size=UDim2.new(0,w or 28,0,22); b.Position=UDim2.new(1,xOff,0.5,-11)
    b.BackgroundColor3=col; b.BorderSizePixel=0
    b.TextColor3=Color3.fromRGB(255,255,255); b.TextSize=9
    b.Font=Enum.Font.GothamBold; b.Text=txt; b.AutoButtonColor=false
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,4)
    return b
end

local AnlTBtn = mkBtn("Анализ",-98,Color3.fromRGB(0,100,180),60)
local MinBtn  = mkBtn("_",     -34,Color3.fromRGB(40,40,80))
local XBtn    = mkBtn("X",     -4, Color3.fromRGB(150,0,40))

-- Чат (левая часть)
local Scroll=Instance.new("ScrollingFrame",Main)
Scroll.Size=UDim2.new(0.58,-4,1,-54); Scroll.Position=UDim2.new(0,3,0,30)
Scroll.BackgroundColor3=Color3.fromRGB(12,12,20); Scroll.BorderSizePixel=0
Scroll.ScrollBarThickness=2; Scroll.ScrollBarImageColor3=Color3.fromRGB(100,0,220)
Scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; Scroll.CanvasSize=UDim2.new(0,0,0,0)
Instance.new("UICorner",Scroll).CornerRadius=UDim.new(0,6)
local SL=Instance.new("UIListLayout",Scroll)
SL.Padding=UDim.new(0,3); SL.SortOrder=Enum.SortOrder.LayoutOrder
local SP=Instance.new("UIPadding",Scroll)
SP.PaddingLeft=UDim.new(0,4); SP.PaddingRight=UDim.new(0,4)
SP.PaddingTop=UDim.new(0,3); SP.PaddingBottom=UDim.new(0,3)

-- Инпут снизу слева
local IF=Instance.new("Frame",Main)
IF.Size=UDim2.new(0.58,-4,0,22); IF.Position=UDim2.new(0,3,1,-26)
IF.BackgroundColor3=Color3.fromRGB(18,18,30); IF.BorderSizePixel=0
Instance.new("UICorner",IF).CornerRadius=UDim.new(0,5)
Instance.new("UIStroke",IF).Color=Color3.fromRGB(80,0,180)

local Inp=Instance.new("TextBox",IF)
Inp.Size=UDim2.new(1,-32,1,0); Inp.Position=UDim2.new(0,6,0,0)
Inp.BackgroundTransparency=1; Inp.TextColor3=Color3.fromRGB(220,200,255)
Inp.PlaceholderText="Генерируй..."; Inp.PlaceholderColor3=Color3.fromRGB(70,60,100)
Inp.TextSize=11; Inp.Font=Enum.Font.Gotham
Inp.TextXAlignment=Enum.TextXAlignment.Left; Inp.ClearTextOnFocus=false; Inp.Text=""

local SndBtn=Instance.new("TextButton",IF)
SndBtn.Size=UDim2.new(0,26,1,-2); SndBtn.Position=UDim2.new(1,-28,0,1)
SndBtn.BackgroundColor3=Color3.fromRGB(80,0,200); SndBtn.BorderSizePixel=0
SndBtn.TextColor3=Color3.fromRGB(255,255,255); SndBtn.TextSize=14
SndBtn.Font=Enum.Font.GothamBold; SndBtn.Text=">"; SndBtn.AutoButtonColor=false
Instance.new("UICorner",SndBtn).CornerRadius=UDim.new(0,4)

-- Правая панель
local RP=Instance.new("Frame",Main)
RP.Size=UDim2.new(0.42,-4,1,-30); RP.Position=UDim2.new(0.58,1,0,30)
RP.BackgroundTransparency=1; RP.BorderSizePixel=0

-- Статус анализа
local AnlStatus=Instance.new("TextLabel",RP)
AnlStatus.Size=UDim2.new(1,0,0,12); AnlStatus.Position=UDim2.new(0,0,0,0)
AnlStatus.BackgroundTransparency=1; AnlStatus.TextColor3=Color3.fromRGB(100,100,150)
AnlStatus.TextSize=8; AnlStatus.Font=Enum.Font.Gotham
AnlStatus.Text="Анализ не запущен"; AnlStatus.TextXAlignment=Enum.TextXAlignment.Left

-- Инфо об игре
local GameInfo=Instance.new("TextLabel",RP)
GameInfo.Size=UDim2.new(1,0,0,30); GameInfo.Position=UDim2.new(0,0,0,14)
GameInfo.BackgroundColor3=Color3.fromRGB(14,14,24); GameInfo.BorderSizePixel=0
GameInfo.TextColor3=Color3.fromRGB(150,200,255); GameInfo.TextSize=9
GameInfo.Font=Enum.Font.Gotham; GameInfo.Text="Игра: —\nRemotes: —"
GameInfo.TextXAlignment=Enum.TextXAlignment.Left; GameInfo.TextWrapped=true
Instance.new("UICorner",GameInfo).CornerRadius=UDim.new(0,5)
local gip=Instance.new("UIPadding",GameInfo)
gip.PaddingLeft=UDim.new(0,5); gip.PaddingTop=UDim.new(0,3)

-- Статус AI
local AIStat=Instance.new("TextLabel",RP)
AIStat.Size=UDim2.new(1,0,0,10); AIStat.Position=UDim2.new(0,0,0,47)
AIStat.BackgroundTransparency=1; AIStat.TextColor3=Color3.fromRGB(140,80,220)
AIStat.TextSize=8; AIStat.Font=Enum.Font.Gotham; AIStat.Text="Готов"
AIStat.TextXAlignment=Enum.TextXAlignment.Left

-- Кнопка Анализ
local AnlBtn=Instance.new("TextButton",RP)
AnlBtn.Size=UDim2.new(1,0,0,20); AnlBtn.Position=UDim2.new(0,0,0,60)
AnlBtn.BackgroundColor3=Color3.fromRGB(0,90,170); AnlBtn.BorderSizePixel=0
AnlBtn.TextColor3=Color3.fromRGB(255,255,255); AnlBtn.TextSize=9
AnlBtn.Font=Enum.Font.GothamBold; AnlBtn.Text="Анализ игры"; AnlBtn.AutoButtonColor=false
Instance.new("UICorner",AnlBtn).CornerRadius=UDim.new(0,5)

-- История команд
local HistFrame=Instance.new("Frame",RP)
HistFrame.Size=UDim2.new(1,0,0,18); HistFrame.Position=UDim2.new(0,0,0,84)
HistFrame.BackgroundColor3=Color3.fromRGB(14,14,24); HistFrame.BorderSizePixel=0
Instance.new("UICorner",HistFrame).CornerRadius=UDim.new(0,4)
local HFL=Instance.new("UIListLayout",HistFrame)
HFL.FillDirection=Enum.FillDirection.Horizontal; HFL.Padding=UDim.new(0,2)
local HFP=Instance.new("UIPadding",HistFrame); HFP.PaddingLeft=UDim.new(0,2); HFP.PaddingTop=UDim.new(0,2)

local histBtns={}
for i=1,3 do
    local hb=Instance.new("TextButton",HistFrame)
    hb.Size=UDim2.new(0.33,-2,1,0)
    hb.BackgroundColor3=Color3.fromRGB(30,15,60); hb.BorderSizePixel=0
    hb.TextColor3=Color3.fromRGB(150,120,200); hb.TextSize=7
    hb.Font=Enum.Font.Gotham; hb.Text="—"; hb.AutoButtonColor=false
    hb.TextTruncate=Enum.TextTruncate.AtEnd
    Instance.new("UICorner",hb).CornerRadius=UDim.new(0,3)
    histBtns[i]=hb
end

-- Повтор + Очистить
local RepBtn=Instance.new("TextButton",RP)
RepBtn.Size=UDim2.new(0.48,0,0,16); RepBtn.Position=UDim2.new(0,0,0,106)
RepBtn.BackgroundColor3=Color3.fromRGB(50,20,80); RepBtn.BorderSizePixel=0
RepBtn.TextColor3=Color3.fromRGB(255,255,255); RepBtn.TextSize=8
RepBtn.Font=Enum.Font.GothamBold; RepBtn.Text="Повтор"; RepBtn.AutoButtonColor=false
Instance.new("UICorner",RepBtn).CornerRadius=UDim.new(0,3)

local ClrBtn=Instance.new("TextButton",RP)
ClrBtn.Size=UDim2.new(0.48,0,0,16); ClrBtn.Position=UDim2.new(0.52,0,0,106)
ClrBtn.BackgroundColor3=Color3.fromRGB(30,30,50); ClrBtn.BorderSizePixel=0
ClrBtn.TextColor3=Color3.fromRGB(200,200,255); ClrBtn.TextSize=8
ClrBtn.Font=Enum.Font.GothamBold; ClrBtn.Text="Очистить"; ClrBtn.AutoButtonColor=false
Instance.new("UICorner",ClrBtn).CornerRadius=UDim.new(0,3)

-- Кнопка AI (когда скрыт)
local AIBtn=Instance.new("TextButton",Gui)
AIBtn.Size=UDim2.new(0,42,0,42); AIBtn.Position=UDim2.new(0,8,1,-56)
AIBtn.BackgroundColor3=Color3.fromRGB(55,0,150); AIBtn.BorderSizePixel=0
AIBtn.TextColor3=Color3.fromRGB(255,255,255); AIBtn.TextSize=12
AIBtn.Font=Enum.Font.GothamBold; AIBtn.Text="AI"; AIBtn.AutoButtonColor=false; AIBtn.Visible=false
Instance.new("UICorner",AIBtn).CornerRadius=UDim.new(0,10)
Instance.new("UIStroke",AIBtn).Color=Color3.fromRGB(150,80,255)

XBtn.MouseButton1Click:Connect(function() Main.Visible=false; AIBtn.Visible=true end)
AIBtn.MouseButton1Click:Connect(function() Main.Visible=true; AIBtn.Visible=false end)

local collapsed=false
MinBtn.MouseButton1Click:Connect(function()
    collapsed=not collapsed
    Scroll.Visible=not collapsed; RP.Visible=not collapsed; IF.Visible=not collapsed
    Main.Size=collapsed and UDim2.new(1,-16,0,28) or UDim2.new(1,-16,0,180)
    Main.Position=collapsed and UDim2.new(0,8,1,-36) or UDim2.new(0,8,1,-188)
end)

-- ================================================
-- ДОБАВИТЬ СООБЩЕНИЕ
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
        or                 Color3.fromRGB(18,18,32)
    Instance.new("UICorner",bg).CornerRadius=UDim.new(0,5)
    local p=Instance.new("UIPadding",bg)
    p.PaddingLeft=UDim.new(0,5); p.PaddingRight=UDim.new(0,5)
    p.PaddingTop=UDim.new(0,3); p.PaddingBottom=UDim.new(0,3)
    local lbl=Instance.new("TextLabel",bg)
    lbl.AutomaticSize=Enum.AutomaticSize.Y; lbl.Size=UDim2.new(1,0,0,0)
    lbl.BackgroundTransparency=1
    lbl.TextColor3 = who=="user" and Color3.fromRGB(200,170,255)
        or who=="ok"   and Color3.fromRGB(100,255,120)
        or who=="err"  and Color3.fromRGB(255,100,100)
        or who=="anl"  and Color3.fromRGB(100,180,255)
        or                 Color3.fromRGB(210,210,255)
    lbl.TextSize=10; lbl.Font=Enum.Font.Gotham
    lbl.TextWrapped=true; lbl.TextXAlignment=Enum.TextXAlignment.Left
    local prefix=who=="user" and "> " or who=="ok" and "OK: " or who=="err" and "Err: " or who=="anl" and "Info: " or "AI: "
    lbl.Text=prefix..text
    task.wait(0.03)
    Scroll.CanvasPosition=Vector2.new(0,999999)
end

-- ================================================
-- АНАЛИЗ
-- ================================================
local function doAnalyze()
    AnlBtn.Text="Анализирую..."
    AnlBtn.BackgroundColor3=Color3.fromRGB(0,60,120)
    AnlTBtn.BackgroundColor3=Color3.fromRGB(0,60,120)
    AnlStatus.Text="Сканирую игру..."
    AnlStatus.TextColor3=Color3.fromRGB(220,160,50)

    task.spawn(function()
        local info = deepAnalyze()
        gameContext = buildContext(info)
        history = {}  -- сбрасываем историю при новом анализе

        -- Обновляем UI
        GameInfo.Text = "Игра: "..(info.gameName or tostring(info.placeId))
            .."\nRemotes: "..#info.remoteEvents.." | Func: "..#info.remoteFunctions

        AnlStatus.Text="Проанализировано! ИИ знает всё"
        AnlStatus.TextColor3=Color3.fromRGB(80,200,120)
        AnlBtn.Text="Обновить анализ"
        AnlBtn.BackgroundColor3=Color3.fromRGB(0,130,60)
        AnlTBtn.BackgroundColor3=Color3.fromRGB(0,100,60)
        AnlTBtn.Text="✓ Анализ"

        -- Краткий отчёт в чат
        local lines = {
            "Игра: "..(info.gameName or "?").." | Creator: "..(info.gameCreator or "?"),
            "Игроков: "..info.playerCount,
        }
        if info.myHP then
            table.insert(lines,"Мой HP: "..info.myHP.."/"..info.myMaxHP.." | Speed: "..info.mySpeed)
        end
        if #info.myStats>0 then table.insert(lines,"Stats: "..table.concat(info.myStats,", ")) end
        table.insert(lines,"RemoteEvents: "..#info.remoteEvents.." | Functions: "..#info.remoteFunctions)
        if #info.remoteEvents>0 then
            table.insert(lines,"Top remotes: "..table.concat({table.unpack(info.remoteEvents,1,math.min(5,#info.remoteEvents))},", "))
        end
        if #info.myTools>0 then table.insert(lines,"Tools: "..table.concat(info.myTools,", ")) end
        if #info.backpack>0 then table.insert(lines,"Backpack: "..table.concat(info.backpack,", ")) end
        if #info.teams>0 then table.insert(lines,"Teams: "..table.concat(info.teams,", ")) end

        addMsg(table.concat(lines,"\n"),"anl")
        AIStat.Text="ИИ готов — знает игру!"
        AIStat.TextColor3=Color3.fromRGB(80,200,120)
    end)
end

AnlBtn.MouseButton1Click:Connect(doAnalyze)
AnlTBtn.MouseButton1Click:Connect(doAnalyze)

-- ================================================
-- ИСТОРИЯ КОМАНД
-- ================================================
local cmdHistory={}
local lastCmd=""

local function updateCmdHistory(cmd)
    table.insert(cmdHistory,1,cmd)
    if #cmdHistory>3 then table.remove(cmdHistory,#cmdHistory) end
    for i,hb in ipairs(histBtns) do hb.Text=cmdHistory[i] or "—" end
end

-- ================================================
-- ОТПРАВКА
-- ================================================
local busy=false

local function sendCmd(txt)
    if busy then return end
    if txt=="" then return end
    lastCmd=txt
    updateCmdHistory(txt)
    addMsg(txt,"user")
    busy=true; SndBtn.Text="..."; SndBtn.BackgroundColor3=Color3.fromRGB(30,0,80)
    AIStat.Text="AI думает..."; AIStat.TextColor3=Color3.fromRGB(220,160,50)

    askAI(txt, function(code, err)
        busy=false; SndBtn.Text=">"; SndBtn.BackgroundColor3=Color3.fromRGB(80,0,200)
        if err then
            addMsg(err,"err")
            AIStat.Text="Ошибка"; AIStat.TextColor3=Color3.fromRGB(255,80,80)
            return
        end
        local ok, runErr = runCode(code)
        if ok then
            addMsg("Выполнено!","ok")
            AIStat.Text="Выполнено"; AIStat.TextColor3=Color3.fromRGB(80,220,100)
        else
            addMsg(tostring(runErr):sub(1,100),"err")
            AIStat.Text="Ошибка кода"; AIStat.TextColor3=Color3.fromRGB(255,80,80)
        end
    end)
end

local function send()
    local txt=Inp.Text:match("^%s*(.-)%s*$")
    if txt=="" then return end
    Inp.Text=""; sendCmd(txt)
end

SndBtn.MouseButton1Click:Connect(send)
Inp.FocusLost:Connect(function(e) if e then send() end end)
RepBtn.MouseButton1Click:Connect(function() if lastCmd~="" then sendCmd(lastCmd) end end)
for i,hb in ipairs(histBtns) do
    hb.MouseButton1Click:Connect(function() if cmdHistory[i] then sendCmd(cmdHistory[i]) end end)
end
ClrBtn.MouseButton1Click:Connect(function()
    for _,v in pairs(Scroll:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
    msgCount=0; history={}
    AIStat.Text="Готов"; AIStat.TextColor3=Color3.fromRGB(140,80,220)
end)

-- ================================================
-- DRAGGABLE
-- ================================================
local drg,ds,sp=false,nil,nil
TB.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1
    or i.UserInputType==Enum.UserInputType.Touch then drg=true;ds=i.Position;sp=Main.Position end
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
-- СТАРТ — авто анализ
-- ================================================
task.wait(0.5)
addMsg("AI v2.0 загружен!\nАвто-анализ запускается через 3 секунды...\nПосле анализа — пиши любую команду!","ai")
task.delay(3, doAnalyze)
print("[PX] AI v2.0 Loaded!")
