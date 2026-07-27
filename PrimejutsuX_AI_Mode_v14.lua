-- ================================================
--   Primejtsu X | AI Mode v13
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

local SYSTEM = [[You are an elite Roblox Lua exploit developer inside a game executor (Delta). You MUST use the GAME ANALYSIS to write game-specific scripts.

ABSOLUTE RULES:
1. Output ONLY raw Lua code. Zero markdown. Zero backticks. Zero explanation. Zero comments.
2. Use RemoteEvents from GAME ANALYSIS for server actions.
3. Store RunService connections in _G (e.g. _G.PX_Fly).
4. ALWAYS wrap in pcall(function() ... end).
5. disable/отключи/убери/stop = disconnect _G and destroy instances.
6. LocalPlayer = game.Players.LocalPlayer

PATTERNS:
REMOTE: pcall(function() local r=game:GetService("ReplicatedStorage"):FindFirstChild("Name",true) if r then r:FireServer() end end)
FLY: pcall(function() if _G.PX_Fly then _G.PX_Fly:Disconnect()end local LP=game.Players.LocalPlayer local UIS=game:GetService("UserInputService") local RS=game:GetService("RunService") local cam=workspace.CurrentCamera local char=LP.Character or LP.CharacterAdded:Wait() local root=char:WaitForChild("HumanoidRootPart") char:WaitForChild("Humanoid").PlatformStand=true local bv=Instance.new("BodyVelocity",root) bv.Name="PX_BV" bv.MaxForce=Vector3.new(1e5,1e5,1e5) bv.Velocity=Vector3.new(0,0,0) local bg=Instance.new("BodyGyro",root) bg.Name="PX_BG" bg.MaxTorque=Vector3.new(1e5,1e5,1e5) bg.CFrame=cam.CFrame _G.PX_Fly=RS.Heartbeat:Connect(function() local cf=cam.CFrame local d=Vector3.new() if UIS:IsKeyDown(Enum.KeyCode.W)then d=d+cf.LookVector end if UIS:IsKeyDown(Enum.KeyCode.S)then d=d-cf.LookVector end if UIS:IsKeyDown(Enum.KeyCode.A)then d=d-cf.RightVector end if UIS:IsKeyDown(Enum.KeyCode.D)then d=d+cf.RightVector end if UIS:IsKeyDown(Enum.KeyCode.Space)then d=d+Vector3.new(0,1,0)end if UIS:IsKeyDown(Enum.KeyCode.LeftShift)then d=d-Vector3.new(0,1,0)end bv.Velocity=d*60 bg.CFrame=cf end) end)
ESP: pcall(function() if _G.PX_ESP then for _,h in pairs(_G.PX_ESP)do pcall(function()h:Destroy()end)end end _G.PX_ESP={} local P=game:GetService("Players") local LP=P.LocalPlayer local function hl(char) local h=Instance.new("Highlight",char) h.FillColor=Color3.fromRGB(255,0,0) h.OutlineColor=Color3.fromRGB(255,255,255) h.FillTransparency=0.5 h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop table.insert(_G.PX_ESP,h) end for _,p in pairs(P:GetPlayers())do if p~=LP and p.Character then hl(p.Character)end p.CharacterAdded:Connect(hl) end end)
SPEED: pcall(function() local h=game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") if h then h.WalkSpeed=80 end end)
NOCLIP: pcall(function() if _G.PX_NC then _G.PX_NC:Disconnect()end _G.PX_NC=game:GetService("RunService").Stepped:Connect(function() local c=game.Players.LocalPlayer.Character if c then for _,p in pairs(c:GetDescendants())do if p:IsA("BasePart")then p.CanCollide=false end end end end) end)
GUI: pcall(function() local LP=game.Players.LocalPlayer local old=LP.PlayerGui:FindFirstChild("PX_GUI") if old then old:Destroy()end local sg=Instance.new("ScreenGui") sg.Name="PX_GUI" sg.ResetOnSpawn=false sg.Parent=LP.PlayerGui local f=Instance.new("Frame",sg) f.Size=UDim2.new(0,300,0,200) f.Position=UDim2.new(0.5,-150,0.5,-100) f.BackgroundColor3=Color3.fromRGB(15,15,25) f.BorderSizePixel=0 Instance.new("UICorner",f).CornerRadius=UDim.new(0,10) _G.PX_GUI=sg _G.PX_GUI_Frame=f end)]]

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

local function groqRequest(body, callback)
    task.spawn(function()
        local tried, res, err = 0, nil, nil
        repeat
            tried = tried + 1
            res, err = httpReq(GROQ_URL, "POST", {
                ["Content-Type"]  = "application/json",
                ["Authorization"] = "Bearer " .. GROQ_KEYS[keyIdx],
            }, body)
            if (not res) or (res and res.StatusCode == 429) then
                keyIdx = keyIdx % #GROQ_KEYS + 1
                task.wait(0.3)
            else break end
        until tried >= #GROQ_KEYS
        callback(res, err)
    end)
end

-- ================================================
-- АНАЛИЗАТОР
-- ================================================
local gameContext = ""

local function deepAnalyze()
    local RS2 = game:GetService("ReplicatedStorage")
    local info = {placeId=game.PlaceId, playerCount=#Players:GetPlayers()}

    pcall(function()
        info.gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    end)

    local remotes = {}
    pcall(function()
        for _, v in pairs(RS2:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                table.insert(remotes, v:GetFullName())
            end
        end
    end)
    info.remotes = remotes

    local char = LP.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            info.walkSpeed = hum.WalkSpeed
            info.jumpPower = hum.JumpPower
            info.health    = math.floor(hum.Health)
            info.rigType   = tostring(hum.RigType)
        end
        local tools = {}
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("Tool") then table.insert(tools, v.Name) end
        end
        info.tools = tools
    end

    local bp = LP:FindFirstChild("Backpack")
    if bp then
        local bpTools = {}
        for _, v in pairs(bp:GetChildren()) do
            table.insert(bpTools, v.Name)
        end
        info.backpack = bpTools
    end

    local ls = LP:FindFirstChild("leaderstats")
    if ls then
        local stats = {}
        for _, v in pairs(ls:GetChildren()) do
            table.insert(stats, v.Name.."="..tostring(v.Value))
        end
        info.leaderstats = stats
    end

    -- Компактный контекст
    local parts = {
        "GAME:"  .. (info.gameName or "?") .. " Id:" .. tostring(info.placeId),
        "Players:" .. info.playerCount .. " Rig:" .. (info.rigType or "?") .. " Speed:" .. tostring(info.walkSpeed) .. " HP:" .. tostring(info.health),
    }
    if info.leaderstats and #info.leaderstats > 0 then
        table.insert(parts, "Stats:" .. table.concat(info.leaderstats, ","))
    end
    if #remotes > 0 then
        local r = {}
        for i = 1, math.min(8, #remotes) do r[i] = remotes[i] end
        table.insert(parts, "Remotes(" .. #remotes .. "):" .. table.concat(r, "|"))
    end
    if info.tools and #info.tools > 0 then
        table.insert(parts, "Tools:" .. table.concat(info.tools, ","))
    end
    if info.backpack and #info.backpack > 0 then
        table.insert(parts, "Backpack:" .. table.concat(info.backpack, ","))
    end

    return table.concat(parts, " | "), info
end

-- ================================================
-- ИСТОРИЯ + ПАМЯТЬ В _G
-- ================================================
if not _G.PX_AI_History then _G.PX_AI_History = {} end
if not _G.PX_AI_CmdHistory then _G.PX_AI_CmdHistory = {} end
local history    = _G.PX_AI_History
local cmdHistory = _G.PX_AI_CmdHistory  -- история команд

local function buildSystem()
    if gameContext == "" then return SYSTEM end
    return SYSTEM .. "\n\nGAME ANALYSIS: " .. gameContext
end

-- ================================================
-- GROQ ЗАПРОСЫ
-- ================================================
local function askGroq(userMsg, callback)
    table.insert(history, {role="user", content=userMsg})
    if #history > 3 then
        local h2 = {}
        for i = #history-2, #history do table.insert(h2, history[i]) end
        history = h2
        _G.PX_AI_History = history
    end

    local messages = {{role="system", content=buildSystem()}}
    for _, m in ipairs(history) do table.insert(messages, m) end

    local body = HttpService:JSONEncode({
        model=MODEL, messages=messages, max_tokens=700, temperature=0.1
    })

    groqRequest(body, function(res, err)
        if err or not res then callback(nil,"HTTP: "..tostring(err)); return end
        if res.StatusCode ~= 200 then callback(nil,"API "..res.StatusCode..": "..res.Body:sub(1,80)); return end
        local ok, parsed = pcall(HttpService.JSONDecode, HttpService, res.Body)
        if not ok then callback(nil,"JSON error"); return end
        local reply = ""
        pcall(function() reply = parsed.choices[1].message.content end)
        if reply == "" then callback(nil,"Empty"); return end
        reply = reply:gsub("```lua%s*",""):gsub("```%s*",""):match("^%s*(.-)%s*$")
        table.insert(history, {role="assistant", content=reply})
        _G.PX_AI_History = history
        callback(reply, nil)
    end)
end

local function askFix(errMsg, callback)
    local messages = {{role="system", content=buildSystem()}}
    for _, m in ipairs(history) do table.insert(messages, m) end
    table.insert(messages, {role="user", content="Fix Lua error, output ONLY code: "..errMsg})
    local body = HttpService:JSONEncode({model=MODEL,messages=messages,max_tokens=700,temperature=0.05})
    groqRequest(body, function(res, err)
        if not res or res.StatusCode ~= 200 then callback(nil); return end
        local ok, parsed = pcall(HttpService.JSONDecode, HttpService, res.Body)
        if not ok then callback(nil); return end
        local reply = ""
        pcall(function() reply = parsed.choices[1].message.content end)
        reply = reply:gsub("```lua%s*",""):gsub("```%s*",""):match("^%s*(.-)%s*$")
        callback(reply)
    end)
end

-- ================================================
-- ВЫПОЛНИТЬ КОД
-- ================================================
local lastCode   = ""  -- для режима отладки
local debugMode  = false

local function runCode(code)
    lastCode = code
    local fn, e = loadstring(code)
    if not fn then return false,"Syntax: "..tostring(e) end
    local ok, re = pcall(fn)
    if not ok then return false,"Runtime: "..tostring(re) end
    return true, nil
end

-- ================================================
-- GUI — горизонтальный компактный
-- ================================================
local oldGui = LP.PlayerGui:FindFirstChild("PX_AI")
if oldGui then oldGui:Destroy() end

local Gui = Instance.new("ScreenGui")
Gui.Name="PX_AI"; Gui.ResetOnSpawn=false; Gui.DisplayOrder=999
Gui.Parent=LP.PlayerGui

-- Главное окно — горизонтальное, снизу экрана
local Main = Instance.new("Frame", Gui)
Main.Size=UDim2.new(1,-20,0,180)
Main.Position=UDim2.new(0,10,1,-190)
Main.BackgroundColor3=Color3.fromRGB(10,10,18)
Main.BorderSizePixel=0
Instance.new("UICorner",Main).CornerRadius=UDim.new(0,10)
local ms=Instance.new("UIStroke",Main)
ms.Color=Color3.fromRGB(100,0,220); ms.Thickness=1.2

-- Тайтл (тонкий)
local TB=Instance.new("Frame",Main)
TB.Size=UDim2.new(1,0,0,28); TB.BackgroundColor3=Color3.fromRGB(55,0,150)
TB.BorderSizePixel=0
Instance.new("UICorner",TB).CornerRadius=UDim.new(0,10)
local tbfix=Instance.new("Frame",TB)
tbfix.Size=UDim2.new(1,0,0.5,0); tbfix.Position=UDim2.new(0,0,0.5,0)
tbfix.BackgroundColor3=Color3.fromRGB(55,0,150); tbfix.BorderSizePixel=0

local TL=Instance.new("TextLabel",TB)
TL.Size=UDim2.new(1,-110,1,0); TL.Position=UDim2.new(0,10,0,0)
TL.BackgroundTransparency=1; TL.TextColor3=Color3.fromRGB(255,255,255)
TL.TextSize=11; TL.Font=Enum.Font.GothamBold
TL.Text="Primejtsu X | AI Mode v13"; TL.TextXAlignment=Enum.TextXAlignment.Left

-- Кнопки в тайтле
local function makeTitleBtn(text, xOff, col)
    local b=Instance.new("TextButton",TB)
    b.Size=UDim2.new(0,30,0,22); b.Position=UDim2.new(1,xOff,0.5,-11)
    b.BackgroundColor3=col; b.BorderSizePixel=0
    b.TextColor3=Color3.fromRGB(255,255,255); b.TextSize=9
    b.Font=Enum.Font.GothamBold; b.Text=text; b.AutoButtonColor=false
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,4)
    return b
end
local DbgBtn = makeTitleBtn("DBG",-100,Color3.fromRGB(80,80,30))
local CodeBtn= makeTitleBtn("Код",-66, Color3.fromRGB(30,60,20))
local MinBtn = makeTitleBtn("_",  -32, Color3.fromRGB(40,40,80))
local XBtn   = makeTitleBtn("X",  -2,  Color3.fromRGB(160,0,50))

-- Основная область — 2 колонки
-- Левая: чат | Правая: кнопки

-- ЧАТ (левая часть)
local Scroll=Instance.new("ScrollingFrame",Main)
Scroll.Size=UDim2.new(0.55,0,1,-32); Scroll.Position=UDim2.new(0,4,0,30)
Scroll.BackgroundColor3=Color3.fromRGB(14,14,22); Scroll.BorderSizePixel=0
Scroll.ScrollBarThickness=2; Scroll.ScrollBarImageColor3=Color3.fromRGB(100,0,220)
Scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; Scroll.CanvasSize=UDim2.new(0,0,0,0)
Instance.new("UICorner",Scroll).CornerRadius=UDim.new(0,6)
local Layout=Instance.new("UIListLayout",Scroll)
Layout.Padding=UDim.new(0,3); Layout.SortOrder=Enum.SortOrder.LayoutOrder
local Pad=Instance.new("UIPadding",Scroll)
Pad.PaddingLeft=UDim.new(0,4); Pad.PaddingRight=UDim.new(0,4)
Pad.PaddingTop=UDim.new(0,3); Pad.PaddingBottom=UDim.new(0,3)

-- ПРАВАЯ ПАНЕЛЬ
local RightPanel=Instance.new("Frame",Main)
RightPanel.Size=UDim2.new(0.43,-4,1,-32); RightPanel.Position=UDim2.new(0.57,0,0,30)
RightPanel.BackgroundTransparency=1; RightPanel.BorderSizePixel=0

-- Быстрые кнопки (2x3 сетка)
local QuickFrame=Instance.new("Frame",RightPanel)
QuickFrame.Size=UDim2.new(1,0,0,70); QuickFrame.Position=UDim2.new(0,0,0,0)
QuickFrame.BackgroundColor3=Color3.fromRGB(14,14,22); QuickFrame.BorderSizePixel=0
Instance.new("UICorner",QuickFrame).CornerRadius=UDim.new(0,6)
local QuickLayout=Instance.new("UIGridLayout",QuickFrame)
QuickLayout.CellSize=UDim2.new(0.5,-3,0,20)
QuickLayout.CellPadding=UDim2.new(0,2,0,2)
local qp=Instance.new("UIPadding",QuickFrame)
qp.PaddingLeft=UDim.new(0,3); qp.PaddingTop=UDim.new(0,3)

local quickCmds = {
    {"ESP","сделай есп"},{"Fly","сделай флай"},
    {"Speed","сделай спид"},{"Noclip","сделай ноклип"},
    {"Aimbot","сделай аимбот"},{"Off All","отключи всё"},
}
local quickBtns={}
for i,cmd in ipairs(quickCmds) do
    local b=Instance.new("TextButton",QuickFrame)
    b.BackgroundColor3=Color3.fromRGB(50,0,120); b.BorderSizePixel=0
    b.TextColor3=Color3.fromRGB(200,180,255); b.TextSize=9
    b.Font=Enum.Font.GothamBold; b.Text=cmd[1]; b.AutoButtonColor=false
    b.LayoutOrder=i
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,4)
    quickBtns[i]={btn=b,cmd=cmd[2]}
end

-- Кнопка анализа
local AnlBtn=Instance.new("TextButton",RightPanel)
AnlBtn.Size=UDim2.new(1,0,0,20); AnlBtn.Position=UDim2.new(0,0,0,74)
AnlBtn.BackgroundColor3=Color3.fromRGB(0,100,180); AnlBtn.BorderSizePixel=0
AnlBtn.TextColor3=Color3.fromRGB(255,255,255); AnlBtn.TextSize=9
AnlBtn.Font=Enum.Font.GothamBold; AnlBtn.Text="Analyze Game"
AnlBtn.AutoButtonColor=false
Instance.new("UICorner",AnlBtn).CornerRadius=UDim.new(0,5)

-- История команд
local HistFrame=Instance.new("Frame",RightPanel)
HistFrame.Size=UDim2.new(1,0,0,20); HistFrame.Position=UDim2.new(0,0,0,97)
HistFrame.BackgroundColor3=Color3.fromRGB(14,14,22); HistFrame.BorderSizePixel=0
Instance.new("UICorner",HistFrame).CornerRadius=UDim.new(0,5)
local hl2=Instance.new("UIListLayout",HistFrame)
hl2.FillDirection=Enum.FillDirection.Horizontal
hl2.Padding=UDim.new(0,2)
local hp2=Instance.new("UIPadding",HistFrame)
hp2.PaddingLeft=UDim.new(0,2); hp2.PaddingTop=UDim.new(0,2)

local histBtns={}
for i=1,3 do
    local hb=Instance.new("TextButton",HistFrame)
    hb.Size=UDim2.new(0.33,-2,1,0)
    hb.BackgroundColor3=Color3.fromRGB(30,15,60); hb.BorderSizePixel=0
    hb.TextColor3=Color3.fromRGB(150,120,200); hb.TextSize=8
    hb.Font=Enum.Font.Gotham; hb.Text="—"; hb.AutoButtonColor=false
    hb.TextTruncate=Enum.TextTruncate.AtEnd
    Instance.new("UICorner",hb).CornerRadius=UDim.new(0,3)
    histBtns[i]=hb
end

-- Статус
local Stat=Instance.new("TextLabel",RightPanel)
Stat.Size=UDim2.new(1,0,0,10); Stat.Position=UDim2.new(0,0,0,120)
Stat.BackgroundTransparency=1; Stat.TextColor3=Color3.fromRGB(140,80,220)
Stat.TextSize=8; Stat.Font=Enum.Font.Gotham; Stat.Text="Ready"
Stat.TextXAlignment=Enum.TextXAlignment.Left

-- Кнопки Повтор + Очистить
local RepeatBtn=Instance.new("TextButton",RightPanel)
RepeatBtn.Size=UDim2.new(0.48,0,0,16); RepeatBtn.Position=UDim2.new(0,0,0,133)
RepeatBtn.BackgroundColor3=Color3.fromRGB(60,30,80); RepeatBtn.BorderSizePixel=0
RepeatBtn.TextColor3=Color3.fromRGB(255,255,255); RepeatBtn.TextSize=8
RepeatBtn.Font=Enum.Font.GothamBold; RepeatBtn.Text="Повтор"
RepeatBtn.AutoButtonColor=false
Instance.new("UICorner",RepeatBtn).CornerRadius=UDim.new(0,4)

local ClrBtn=Instance.new("TextButton",RightPanel)
ClrBtn.Size=UDim2.new(0.48,0,0,16); ClrBtn.Position=UDim2.new(0.52,0,0,133)
ClrBtn.BackgroundColor3=Color3.fromRGB(30,30,50); ClrBtn.BorderSizePixel=0
ClrBtn.TextColor3=Color3.fromRGB(200,200,255); ClrBtn.TextSize=8
ClrBtn.Font=Enum.Font.GothamBold; ClrBtn.Text="Очистить"
ClrBtn.AutoButtonColor=false
Instance.new("UICorner",ClrBtn).CornerRadius=UDim.new(0,4)

-- ИНПУТ (снизу слева)
local IF=Instance.new("Frame",Main)
IF.Size=UDim2.new(0.55,-4,0,26); IF.Position=UDim2.new(0,4,1,-30)
IF.BackgroundColor3=Color3.fromRGB(20,20,32); IF.BorderSizePixel=0
Instance.new("UICorner",IF).CornerRadius=UDim.new(0,6)
Instance.new("UIStroke",IF).Color=Color3.fromRGB(80,0,180)

local Inp=Instance.new("TextBox",IF)
Inp.Size=UDim2.new(1,-36,1,0); Inp.Position=UDim2.new(0,6,0,0)
Inp.BackgroundTransparency=1; Inp.TextColor3=Color3.fromRGB(220,200,255)
Inp.PlaceholderText="Генерируй..."; Inp.PlaceholderColor3=Color3.fromRGB(70,60,100)
Inp.TextSize=11; Inp.Font=Enum.Font.Gotham
Inp.TextXAlignment=Enum.TextXAlignment.Left; Inp.ClearTextOnFocus=false; Inp.Text=""

local SndBtn=Instance.new("TextButton",IF)
SndBtn.Size=UDim2.new(0,30,1,-4); SndBtn.Position=UDim2.new(1,-33,0,2)
SndBtn.BackgroundColor3=Color3.fromRGB(80,0,200); SndBtn.BorderSizePixel=0
SndBtn.TextColor3=Color3.fromRGB(255,255,255); SndBtn.TextSize=14
SndBtn.Font=Enum.Font.GothamBold; SndBtn.Text=">"; SndBtn.AutoButtonColor=false
Instance.new("UICorner",SndBtn).CornerRadius=UDim.new(0,5)

-- Кнопка AI (когда скрыт)
local AIBtn=Instance.new("TextButton",Gui)
AIBtn.Size=UDim2.new(0,40,0,40); AIBtn.Position=UDim2.new(0,8,1,-56)
AIBtn.BackgroundColor3=Color3.fromRGB(55,0,150); AIBtn.BorderSizePixel=0
AIBtn.TextColor3=Color3.fromRGB(255,255,255); AIBtn.TextSize=12
AIBtn.Font=Enum.Font.GothamBold; AIBtn.Text="AI"; AIBtn.AutoButtonColor=false
AIBtn.Visible=false
Instance.new("UICorner",AIBtn).CornerRadius=UDim.new(0,10)
Instance.new("UIStroke",AIBtn).Color=Color3.fromRGB(150,80,255)

-- Свернуть/развернуть
local mainVisible = true
XBtn.MouseButton1Click:Connect(function()
    Main.Visible=false; AIBtn.Visible=true
end)
AIBtn.MouseButton1Click:Connect(function()
    Main.Visible=true; AIBtn.Visible=false
end)
MinBtn.MouseButton1Click:Connect(function()
    mainVisible = not mainVisible
    Scroll.Visible = mainVisible
    RightPanel.Visible = mainVisible
    IF.Visible = mainVisible
    Main.Size = mainVisible and UDim2.new(1,-20,0,180) or UDim2.new(0,220,0,28)
    Main.Position = mainVisible and UDim2.new(0,10,1,-190) or UDim2.new(0,10,1,-38)
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
        or who=="code" and Color3.fromRGB(20,40,20)
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
        or who=="code" and Color3.fromRGB(150,255,150)
        or                 Color3.fromRGB(210,210,255)
    lbl.TextSize=11; lbl.Font = who=="code" and Enum.Font.Code or Enum.Font.Gotham
    lbl.TextWrapped=true; lbl.TextXAlignment=Enum.TextXAlignment.Left
    local prefix = who=="user" and "Ты: " or who=="ok" and "Сделано: "
        or who=="err" and "Ошибка: " or who=="anl" and "Анализ: "
        or who=="code" and "Код: " or "AI: "
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
    nf.Size=UDim2.new(0,320,0,38); nf.Position=UDim2.new(0.5,-160,1,yp+50)
    nf.BackgroundColor3=col or Color3.fromRGB(55,0,150); nf.BorderSizePixel=0
    Instance.new("UICorner",nf).CornerRadius=UDim.new(0,10)
    local ns=Instance.new("UIStroke",nf); ns.Color=Color3.fromRGB(150,80,255); ns.Thickness=1.2
    local nl=Instance.new("TextLabel",nf)
    nl.Size=UDim2.new(1,-14,1,0); nl.Position=UDim2.new(0,7,0,0)
    nl.BackgroundTransparency=1; nl.TextColor3=Color3.fromRGB(255,255,255)
    nl.TextSize=11; nl.Font=Enum.Font.GothamBold; nl.TextWrapped=true
    nl.TextXAlignment=Enum.TextXAlignment.Left; nl.Text=text
    TweenService:Create(nf,TweenInfo.new(0.25,Enum.EasingStyle.Quart),{Position=UDim2.new(0.5,-160,1,yp)}):Play()
    task.delay(4,function()
        TweenService:Create(nf,TweenInfo.new(0.25,Enum.EasingStyle.Quart),{Position=UDim2.new(0.5,-160,1,yp+50)}):Play()
        task.wait(0.3); pcall(function()nf:Destroy()end); nY=math.max(0,nY-1)
    end)
end

-- ================================================
-- ОБНОВИТЬ ИСТОРИЮ КОМАНД
-- ================================================
local function updateCmdHistory(cmd)
    table.insert(cmdHistory, 1, cmd)
    if #cmdHistory > 3 then
        table.remove(cmdHistory, #cmdHistory)
    end
    _G.PX_AI_CmdHistory = cmdHistory
    for i, hb in ipairs(histBtns) do
        hb.Text = cmdHistory[i] or "—"
    end
end

-- Восстанавливаем историю команд из памяти
for i, hb in ipairs(histBtns) do
    hb.Text = cmdHistory[i] or "—"
end

-- ================================================
-- АНАЛИЗ
-- ================================================
local function doAnalyze()
    AnlBtn.Text="Анализирую..."
    AnlBtn.BackgroundColor3=Color3.fromRGB(0,60,120)
    task.spawn(function()
        local ctx, info = deepAnalyze()
        gameContext = ctx
        history = {}
        _G.PX_AI_History = history

        local lines = {"Игра: "..(info.gameName or tostring(info.placeId))}
        table.insert(lines,"Players:"..info.playerCount.." Speed:"..(info.walkSpeed or "?").." HP:"..(info.health or "?"))
        if info.leaderstats and #info.leaderstats>0 then
            table.insert(lines,"Stats: "..table.concat(info.leaderstats,", "))
        end
        if info.remotes and #info.remotes>0 then
            table.insert(lines,"Remotes("..#info.remotes.."): "..table.concat({table.unpack(info.remotes,1,math.min(5,#info.remotes))},", "))
        end
        if info.backpack and #info.backpack>0 then
            table.insert(lines,"Backpack: "..table.concat(info.backpack,", "))
        end

        addMsg(table.concat(lines,"\n"),"anl")
        Stat.Text="Проанализировано — ИИ знает игру!"
        Stat.TextColor3=Color3.fromRGB(80,200,120)
        AnlBtn.Text="Обновить анализ / Re-analyze"
        AnlBtn.BackgroundColor3=Color3.fromRGB(0,130,60)
        notif("Анализ завершён! ИИ знает игру!", Color3.fromRGB(0,100,60))
    end)
end

AnlBtn.MouseButton1Click:Connect(doAnalyze)

-- ================================================
-- ОТПРАВКА
-- ================================================
local busy     = false
local lastCmd  = ""

local function sendCmd(txt)
    if busy then return end
    if txt == "" then return end

    lastCmd = txt
    updateCmdHistory(txt)
    addMsg(txt,"user")
    busy=true; SndBtn.Text="..."; SndBtn.BackgroundColor3=Color3.fromRGB(30,0,80)
    Stat.Text="AI думает..."; Stat.TextColor3=Color3.fromRGB(220,160,50)

    askGroq(txt, function(code, err)
        busy=false; SndBtn.Text=">"; SndBtn.BackgroundColor3=Color3.fromRGB(80,0,200)

        if err then
            addMsg(err,"err")
            Stat.Text="Ошибка"; Stat.TextColor3=Color3.fromRGB(255,80,80)
            notif("Ошибка: "..err:sub(1,50), Color3.fromRGB(120,0,40))
            return
        end

        -- Режим отладки — показываем код
        if debugMode then
            addMsg(code:sub(1,200)..(#code>200 and "..." or ""), "code")
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
                    addMsg("Не удалось: "..tostring(runErr),"err")
                    Stat.Text="Ошибка"; Stat.TextColor3=Color3.fromRGB(255,80,80)
                    return
                end
                if debugMode then
                    addMsg(fixedCode:sub(1,200)..(#fixedCode>200 and "..." or ""), "code")
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

local function send()
    local txt = Inp.Text:match("^%s*(.-)%s*$")
    if txt == "" then return end
    Inp.Text = ""
    sendCmd(txt)
end

SndBtn.MouseButton1Click:Connect(send)
Inp.FocusLost:Connect(function(e) if e then send() end end)

-- Быстрые кнопки
for _, qb in ipairs(quickBtns) do
    qb.btn.MouseButton1Click:Connect(function()
        sendCmd(qb.cmd)
    end)
end

-- История команд
for i, hb in ipairs(histBtns) do
    hb.MouseButton1Click:Connect(function()
        if cmdHistory[i] then sendCmd(cmdHistory[i]) end
    end)
end

-- Кнопка повтора
RepeatBtn.MouseButton1Click:Connect(function()
    if lastCmd ~= "" then sendCmd(lastCmd) end
end)

-- Кнопка Debug
DbgBtn.MouseButton1Click:Connect(function()
    debugMode = not debugMode
    DbgBtn.BackgroundColor3 = debugMode and Color3.fromRGB(120,120,0) or Color3.fromRGB(80,80,30)
    DbgBtn.TextColor3 = debugMode and Color3.fromRGB(255,255,0) or Color3.fromRGB(255,220,0)
    notif(debugMode and "Debug ON — будет показывать код" or "Debug OFF", Color3.fromRGB(80,80,0))
end)

-- Кнопка показать последний код
CodeBtn.MouseButton1Click:Connect(function()
    if lastCode ~= "" then
        addMsg(lastCode:sub(1,300)..(#lastCode>300 and "..." or ""), "code")
    else
        addMsg("Ещё нет сгенерированного кода","err")
    end
end)

-- Очистить
ClrBtn.MouseButton1Click:Connect(function()
    for _,v in pairs(Scroll:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
    history={}; msgCount=0; _G.PX_AI_History={}
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
-- СТАРТ — авто-анализ
-- ================================================
task.wait(0.8)
notif("Primejtsu X | AI Mode v13 — Loaded!", Color3.fromRGB(55,0,150))
task.wait(0.5)
notif("Спасибо что выбрали нас! / Thank you!", Color3.fromRGB(80,0,200))
addMsg("Привет! v13 загружен.\nБыстрые кнопки внизу — ESP/Fly/Speed/Noclip\nИстория команд сохраняется\nDBG = режим отладки (показывает код)\nЗапускаю авто-анализ игры...", "ai")

-- Авто-анализ через 2 секунды
task.delay(2, function()
    doAnalyze()
end)

print("[PX] AI Mode v13 Loaded!")
