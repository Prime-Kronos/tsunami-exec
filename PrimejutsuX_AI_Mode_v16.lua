-- ================================================
--   Primejtsu X | AI Mode v16
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
-- ЗАХАРДКОЖЕННЫЕ ФУНКЦИИ (работают всегда)
-- ================================================
local function doESP(on)
    if not on then
        if _G.PX_ESP then
            for _,h in pairs(_G.PX_ESP) do pcall(function()h:Destroy()end) end
            _G.PX_ESP = nil
        end
        return "ESP выключен"
    end
    if _G.PX_ESP then
        for _,h in pairs(_G.PX_ESP) do pcall(function()h:Destroy()end) end
    end
    _G.PX_ESP = {}
    local function applyHL(char)
        local hl = Instance.new("Highlight", char)
        hl.FillColor = Color3.fromRGB(255,50,50)
        hl.OutlineColor = Color3.fromRGB(255,255,255)
        hl.FillTransparency = 0.5
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        table.insert(_G.PX_ESP, hl)
    end
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then applyHL(p.Character) end
        p.CharacterAdded:Connect(applyHL)
    end
    Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(applyHL)
    end)
    return "ESP включён"
end

local function doFly(on)
    if not on then
        if _G.PX_Fly then _G.PX_Fly:Disconnect(); _G.PX_Fly = nil end
        local char = LP.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum  = char:FindFirstChild("Humanoid")
            if root then
                local bv = root:FindFirstChild("PX_BV")
                local bg = root:FindFirstChild("PX_BG")
                if bv then bv:Destroy() end
                if bg then bg:Destroy() end
            end
            if hum then hum.PlatformStand = false end
        end
        return "Fly выключен"
    end
    if _G.PX_Fly then _G.PX_Fly:Disconnect() end
    local char = LP.Character or LP.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    local hum  = char:WaitForChild("Humanoid")
    local cam  = workspace.CurrentCamera
    hum.PlatformStand = true
    local bv = Instance.new("BodyVelocity", root)
    bv.Name = "PX_BV"; bv.MaxForce = Vector3.new(1e5,1e5,1e5); bv.Velocity = Vector3.new(0,0,0)
    local bg = Instance.new("BodyGyro", root)
    bg.Name = "PX_BG"; bg.MaxTorque = Vector3.new(1e5,1e5,1e5); bg.CFrame = cam.CFrame
    _G.PX_Fly = RunService.Heartbeat:Connect(function()
        local cf = cam.CFrame
        local d  = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then d=d+cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then d=d-cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then d=d-cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then d=d+cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then d=d+Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then d=d-Vector3.new(0,1,0) end
        bv.Velocity = d * 60; bg.CFrame = cf
    end)
    return "Fly включён (W/A/S/D + Space/Shift)"
end

local function doSpeed(val)
    local char = LP.Character
    if not char then return "Нет персонажа" end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return "Нет Humanoid" end
    hum.WalkSpeed = val or 80
    return "Speed = " .. tostring(val or 80)
end

local function doNoclip(on)
    if not on then
        if _G.PX_NC then _G.PX_NC:Disconnect(); _G.PX_NC = nil end
        local char = LP.Character
        if char then
            for _,p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then pcall(function()p.CanCollide=true end) end
            end
        end
        return "Noclip выключен"
    end
    if _G.PX_NC then _G.PX_NC:Disconnect() end
    _G.PX_NC = RunService.Stepped:Connect(function()
        local char = LP.Character
        if char then
            for _,p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end)
    return "Noclip включён"
end

local function doAimbot(on)
    if not on then
        if _G.PX_Aim then _G.PX_Aim:Disconnect(); _G.PX_Aim = nil end
        return "Aimbot выключен"
    end
    if _G.PX_Aim then _G.PX_Aim:Disconnect() end
    local cam = workspace.CurrentCamera
    _G.PX_Aim = RunService.RenderStepped:Connect(function()
        local best, bestD = nil, math.huge
        local cx = cam.ViewportSize.X/2
        local cy = cam.ViewportSize.Y/2
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local hum  = p.Character:FindFirstChild("Humanoid")
                local head = p.Character:FindFirstChild("Head")
                if hum and hum.Health > 0 and head then
                    local sp, vis = cam:WorldToViewportPoint(head.Position)
                    if vis then
                        local d = math.sqrt((sp.X-cx)^2+(sp.Y-cy)^2)
                        if d < bestD then bestD=d; best=head end
                    end
                end
            end
        end
        if best then
            cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position, best.Position), 0.2)
        end
    end)
    return "Aimbot включён"
end

local function doOffAll()
    doESP(false); doFly(false); doNoclip(false); doAimbot(false)
    doSpeed(16)
    if _G.PX_Fly then _G.PX_Fly:Disconnect(); _G.PX_Fly=nil end
    return "Всё выключено"
end

-- ================================================
-- ДЕТЕКТ КОМАНД (без ИИ — мгновенно)
-- ================================================
local function detectLocalCmd(txt)
    local t = txt:lower()
    if t:find("esp") then
        if t:find("выкл") or t:find("off") or t:find("стоп") or t:find("убер") or t:find("откл") then
            return doESP(false)
        end
        return doESP(true)
    end
    if t:find("fl") or t:find("флай") or t:find("лет") then
        if t:find("выкл") or t:find("off") or t:find("стоп") or t:find("убер") or t:find("откл") then
            return doFly(false)
        end
        return doFly(true)
    end
    if t:find("speed") or t:find("спид") or t:find("скор") then
        if t:find("выкл") or t:find("off") or t:find("стоп") or t:find("убер") or t:find("откл") then
            return doSpeed(16)
        end
        local n = tonumber(t:match("%d+")) or 80
        return doSpeed(n)
    end
    if t:find("noclip") or t:find("ноклип") or t:find("сквоз") then
        if t:find("выкл") or t:find("off") or t:find("стоп") or t:find("убер") or t:find("откл") then
            return doNoclip(false)
        end
        return doNoclip(true)
    end
    if t:find("aim") or t:find("аим") then
        if t:find("выкл") or t:find("off") or t:find("стоп") or t:find("убер") or t:find("откл") then
            return doAimbot(false)
        end
        return doAimbot(true)
    end
    if t:find("выкл") and (t:find("всё") or t:find("все") or t:find("all")) then
        return doOffAll()
    end
    if t:find("off all") or t:find("отключи всё") then
        return doOffAll()
    end
    return nil  -- не распознано, отправляем в ИИ
end

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
        model=MODEL, messages=messages, max_tokens=600, temperature=0.1
    })
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
    local info = {placeId=game.PlaceId, playerCount=#Players:GetPlayers()}
    pcall(function()
        info.gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    end)
    local remotes = {}
    pcall(function()
        for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                table.insert(remotes, v:GetFullName())
            end
        end
    end)
    info.remotes = remotes
    local char = LP.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then info.speed=hum.WalkSpeed; info.hp=math.floor(hum.Health) end
    end
    local ls = LP:FindFirstChild("leaderstats")
    if ls then
        local stats={}
        for _,v in pairs(ls:GetChildren()) do table.insert(stats,v.Name.."="..tostring(v.Value)) end
        info.leaderstats=stats
    end
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        local tools={}
        for _,v in pairs(bp:GetChildren()) do table.insert(tools,v.Name) end
        info.backpack=tools
    end

    local parts = {
        "GAME:"    .. (info.gameName or "?") .. " PlaceId:" .. tostring(info.placeId),
        "Players:" .. info.playerCount .. " Speed:" .. tostring(info.speed) .. " HP:" .. tostring(info.hp),
    }
    if info.leaderstats and #info.leaderstats>0 then
        table.insert(parts, "Stats:" .. table.concat(info.leaderstats,","))
    end
    if #remotes>0 then
        local r={}
        for i=1,math.min(8,#remotes) do r[i]=remotes[i] end
        table.insert(parts, "Remotes("..#remotes.."):"..table.concat(r,"|"))
    end
    if info.backpack and #info.backpack>0 then
        table.insert(parts, "Backpack:"..table.concat(info.backpack,","))
    end
    return table.concat(parts," | "), info
end

-- ================================================
-- GROQ — только для игровых команд
-- ================================================
local function askAI(userMsg, callback)
    local sys = "You are a Roblox Lua exploit script generator inside Delta executor. Output ONLY raw Lua code. No markdown, no backticks, no text. Use game RemoteEvents from the GAME ANALYSIS with FireServer(). Find remotes: game:GetService('ReplicatedStorage'):FindFirstChild('Name',true):FireServer(). Wrap in pcall. LocalPlayer=game.Players.LocalPlayer."
    if gameContext ~= "" then
        sys = sys .. " GAME ANALYSIS: " .. gameContext
    end
    local messages = {
        {role="system", content=sys},
        {role="user",   content=userMsg},
    }
    groqRequest(messages, function(res, err)
        if err or not res then callback(nil,"HTTP: "..tostring(err)); return end
        if res.StatusCode ~= 200 then callback(nil,"API "..res.StatusCode..": "..res.Body:sub(1,80)); return end
        local ok, parsed = pcall(HttpService.JSONDecode, HttpService, res.Body)
        if not ok then callback(nil,"JSON error"); return end
        local reply=""
        pcall(function() reply=parsed.choices[1].message.content end)
        if reply=="" then callback(nil,"Empty"); return end
        reply = reply:gsub("```lua%s*",""):gsub("```%s*",""):match("^%s*(.-)%s*$")
        callback(reply, nil)
    end)
end

local function runCode(code)
    local fn,e = loadstring(code)
    if not fn then return false,"Syntax: "..tostring(e) end
    local ok,re = pcall(fn)
    if not ok then return false,"Runtime: "..tostring(re) end
    return true, nil
end

-- ================================================
-- GUI — горизонтальный снизу экрана
-- ================================================
local oldGui = LP.PlayerGui:FindFirstChild("PX_AI")
if oldGui then oldGui:Destroy() end

local Gui = Instance.new("ScreenGui")
Gui.Name="PX_AI"; Gui.ResetOnSpawn=false; Gui.DisplayOrder=999
Gui.Parent=LP.PlayerGui

local Main = Instance.new("Frame", Gui)
Main.Size=UDim2.new(1,-16,0,175)
Main.Position=UDim2.new(0,8,1,-183)
Main.BackgroundColor3=Color3.fromRGB(10,10,18)
Main.BorderSizePixel=0
Instance.new("UICorner",Main).CornerRadius=UDim.new(0,10)
local ms=Instance.new("UIStroke",Main)
ms.Color=Color3.fromRGB(100,0,220); ms.Thickness=1.2

-- Тайтл
local TB=Instance.new("Frame",Main)
TB.Size=UDim2.new(1,0,0,26); TB.BackgroundColor3=Color3.fromRGB(55,0,150)
TB.BorderSizePixel=0
Instance.new("UICorner",TB).CornerRadius=UDim.new(0,10)
local tbfix=Instance.new("Frame",TB)
tbfix.Size=UDim2.new(1,0,0.5,0); tbfix.Position=UDim2.new(0,0,0.5,0)
tbfix.BackgroundColor3=Color3.fromRGB(55,0,150); tbfix.BorderSizePixel=0

local TL=Instance.new("TextLabel",TB)
TL.Size=UDim2.new(1,-95,1,0); TL.Position=UDim2.new(0,10,0,0)
TL.BackgroundTransparency=1; TL.TextColor3=Color3.fromRGB(255,255,255)
TL.TextSize=11; TL.Font=Enum.Font.GothamBold
TL.Text="Primejtsu X | AI Mode"; TL.TextXAlignment=Enum.TextXAlignment.Left

local function mkTBtn(txt, xOff, col)
    local b=Instance.new("TextButton",TB)
    b.Size=UDim2.new(0,28,0,20); b.Position=UDim2.new(1,xOff,0.5,-10)
    b.BackgroundColor3=col; b.BorderSizePixel=0
    b.TextColor3=Color3.fromRGB(255,255,255); b.TextSize=9
    b.Font=Enum.Font.GothamBold; b.Text=txt; b.AutoButtonColor=false
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,4)
    return b
end
local DbgBtn = mkTBtn("DBG",-92,Color3.fromRGB(70,70,20))
local MinBtn = mkTBtn("_",  -60,Color3.fromRGB(40,40,80))
local XBtn   = mkTBtn("X",  -30,Color3.fromRGB(150,0,40))

-- Левая колонка — чат
local Scroll=Instance.new("ScrollingFrame",Main)
Scroll.Size=UDim2.new(0.54,-4,1,-54); Scroll.Position=UDim2.new(0,3,0,28)
Scroll.BackgroundColor3=Color3.fromRGB(14,14,22); Scroll.BorderSizePixel=0
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
IF.Size=UDim2.new(0.54,-4,0,22); IF.Position=UDim2.new(0,3,1,-26)
IF.BackgroundColor3=Color3.fromRGB(20,20,32); IF.BorderSizePixel=0
Instance.new("UICorner",IF).CornerRadius=UDim.new(0,5)
Instance.new("UIStroke",IF).Color=Color3.fromRGB(80,0,180)

local Inp=Instance.new("TextBox",IF)
Inp.Size=UDim2.new(1,-32,1,0); Inp.Position=UDim2.new(0,5,0,0)
Inp.BackgroundTransparency=1; Inp.TextColor3=Color3.fromRGB(220,200,255)
Inp.PlaceholderText="Команда..."; Inp.PlaceholderColor3=Color3.fromRGB(70,60,100)
Inp.TextSize=10; Inp.Font=Enum.Font.Gotham
Inp.TextXAlignment=Enum.TextXAlignment.Left; Inp.ClearTextOnFocus=false; Inp.Text=""

local SndBtn=Instance.new("TextButton",IF)
SndBtn.Size=UDim2.new(0,26,1,-2); SndBtn.Position=UDim2.new(1,-28,0,1)
SndBtn.BackgroundColor3=Color3.fromRGB(80,0,200); SndBtn.BorderSizePixel=0
SndBtn.TextColor3=Color3.fromRGB(255,255,255); SndBtn.TextSize=13
SndBtn.Font=Enum.Font.GothamBold; SndBtn.Text=">"; SndBtn.AutoButtonColor=false
Instance.new("UICorner",SndBtn).CornerRadius=UDim.new(0,4)

-- Правая колонка
local RP=Instance.new("Frame",Main)
RP.Size=UDim2.new(0.46,-4,1,-30); RP.Position=UDim2.new(0.54,1,0,28)
RP.BackgroundTransparency=1; RP.BorderSizePixel=0

-- Быстрые кнопки 2x3
local QF=Instance.new("Frame",RP)
QF.Size=UDim2.new(1,0,0,66); QF.Position=UDim2.new(0,0,0,0)
QF.BackgroundColor3=Color3.fromRGB(14,14,22); QF.BorderSizePixel=0
Instance.new("UICorner",QF).CornerRadius=UDim.new(0,6)
local QGL=Instance.new("UIGridLayout",QF)
QGL.CellSize=UDim2.new(0.5,-3,0,19); QGL.CellPadding=UDim2.new(0,2,0,2)
local QP=Instance.new("UIPadding",QF)
QP.PaddingLeft=UDim.new(0,3); QP.PaddingTop=UDim.new(0,3)

local quickCmds={
    {"ESP","сделай есп"},{"Fly","сделай флай"},
    {"Speed","сделай спид"},{"Noclip","сделай ноклип"},
    {"Aimbot","сделай аимбот"},{"Off All","отключи всё"},
}
local quickBtns={}
for i,cmd in ipairs(quickCmds) do
    local b=Instance.new("TextButton",QF)
    b.BackgroundColor3=Color3.fromRGB(50,0,120); b.BorderSizePixel=0
    b.TextColor3=Color3.fromRGB(200,180,255); b.TextSize=9
    b.Font=Enum.Font.GothamBold; b.Text=cmd[1]; b.AutoButtonColor=false; b.LayoutOrder=i
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,4)
    quickBtns[i]={btn=b,cmd=cmd[2]}
end

-- Кнопка анализа
local AnlBtn=Instance.new("TextButton",RP)
AnlBtn.Size=UDim2.new(1,0,0,18); AnlBtn.Position=UDim2.new(0,0,0,70)
AnlBtn.BackgroundColor3=Color3.fromRGB(0,90,160); AnlBtn.BorderSizePixel=0
AnlBtn.TextColor3=Color3.fromRGB(255,255,255); AnlBtn.TextSize=9
AnlBtn.Font=Enum.Font.GothamBold; AnlBtn.Text="Analyze Game"
AnlBtn.AutoButtonColor=false
Instance.new("UICorner",AnlBtn).CornerRadius=UDim.new(0,4)

-- История команд
local HF=Instance.new("Frame",RP)
HF.Size=UDim2.new(1,0,0,18); HF.Position=UDim2.new(0,0,0,91)
HF.BackgroundColor3=Color3.fromRGB(14,14,22); HF.BorderSizePixel=0
Instance.new("UICorner",HF).CornerRadius=UDim.new(0,4)
local HL=Instance.new("UIListLayout",HF)
HL.FillDirection=Enum.FillDirection.Horizontal; HL.Padding=UDim.new(0,2)
local HP=Instance.new("UIPadding",HF); HP.PaddingLeft=UDim.new(0,2); HP.PaddingTop=UDim.new(0,2)

local histBtns={}
for i=1,3 do
    local hb=Instance.new("TextButton",HF)
    hb.Size=UDim2.new(0.33,-2,1,0)
    hb.BackgroundColor3=Color3.fromRGB(30,15,60); hb.BorderSizePixel=0
    hb.TextColor3=Color3.fromRGB(150,120,200); hb.TextSize=8
    hb.Font=Enum.Font.Gotham; hb.Text="—"; hb.AutoButtonColor=false
    hb.TextTruncate=Enum.TextTruncate.AtEnd
    Instance.new("UICorner",hb).CornerRadius=UDim.new(0,3)
    histBtns[i]=hb
end

-- Статус
local Stat=Instance.new("TextLabel",RP)
Stat.Size=UDim2.new(1,0,0,10); Stat.Position=UDim2.new(0,0,0,112)
Stat.BackgroundTransparency=1; Stat.TextColor3=Color3.fromRGB(140,80,220)
Stat.TextSize=8; Stat.Font=Enum.Font.Gotham; Stat.Text="Ready"
Stat.TextXAlignment=Enum.TextXAlignment.Left

-- Повтор + Очистить
local RepBtn=Instance.new("TextButton",RP)
RepBtn.Size=UDim2.new(0.48,0,0,14); RepBtn.Position=UDim2.new(0,0,0,125)
RepBtn.BackgroundColor3=Color3.fromRGB(50,20,80); RepBtn.BorderSizePixel=0
RepBtn.TextColor3=Color3.fromRGB(255,255,255); RepBtn.TextSize=8
RepBtn.Font=Enum.Font.GothamBold; RepBtn.Text="Повтор"; RepBtn.AutoButtonColor=false
Instance.new("UICorner",RepBtn).CornerRadius=UDim.new(0,3)

local ClrBtn=Instance.new("TextButton",RP)
ClrBtn.Size=UDim2.new(0.48,0,0,14); ClrBtn.Position=UDim2.new(0.52,0,0,125)
ClrBtn.BackgroundColor3=Color3.fromRGB(30,30,50); ClrBtn.BorderSizePixel=0
ClrBtn.TextColor3=Color3.fromRGB(200,200,255); ClrBtn.TextSize=8
ClrBtn.Font=Enum.Font.GothamBold; ClrBtn.Text="Очистить"; ClrBtn.AutoButtonColor=false
Instance.new("UICorner",ClrBtn).CornerRadius=UDim.new(0,3)

-- Кнопка AI (когда скрыт)
local AIBtn=Instance.new("TextButton",Gui)
AIBtn.Size=UDim2.new(0,40,0,40); AIBtn.Position=UDim2.new(0,8,1,-56)
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
    Main.Size=collapsed and UDim2.new(1,-16,0,26) or UDim2.new(1,-16,0,175)
    Main.Position=collapsed and UDim2.new(0,8,1,-34) or UDim2.new(0,8,1,-183)
end)

-- ================================================
-- ДОБАВИТЬ СООБЩЕНИЕ
-- ================================================
local msgCount=0
local debugMode=false
local lastCode=""
local lastCmd=""
local cmdHistory={}

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
        or who=="code" and Color3.fromRGB(150,255,150)
        or                 Color3.fromRGB(210,210,255)
    lbl.TextSize=9; lbl.Font=Enum.Font.Gotham
    lbl.TextWrapped=true; lbl.TextXAlignment=Enum.TextXAlignment.Left
    local prefix=who=="user" and ">" or who=="ok" and "OK: " or who=="err" and "Err: "
        or who=="anl" and "Info: " or who=="code" and "Code: " or "AI: "
    lbl.Text=prefix..text
    task.wait(0.03)
    Scroll.CanvasPosition=Vector2.new(0,999999)
end

-- ================================================
-- УВЕДОМЛЕНИЕ
-- ================================================
local nY=0
local function notif(text, col)
    nY=nY+1
    local yp=-(192+(nY-1)*44)
    local nf=Instance.new("Frame",Gui)
    nf.Size=UDim2.new(0,300,0,36); nf.Position=UDim2.new(0.5,-150,1,yp+44)
    nf.BackgroundColor3=col or Color3.fromRGB(55,0,150); nf.BorderSizePixel=0
    Instance.new("UICorner",nf).CornerRadius=UDim.new(0,8)
    local ns=Instance.new("UIStroke",nf); ns.Color=Color3.fromRGB(150,80,255); ns.Thickness=1
    local nl=Instance.new("TextLabel",nf)
    nl.Size=UDim2.new(1,-12,1,0); nl.Position=UDim2.new(0,6,0,0)
    nl.BackgroundTransparency=1; nl.TextColor3=Color3.fromRGB(255,255,255)
    nl.TextSize=10; nl.Font=Enum.Font.GothamBold; nl.TextWrapped=true
    nl.TextXAlignment=Enum.TextXAlignment.Left; nl.Text=text
    TweenService:Create(nf,TweenInfo.new(0.2,Enum.EasingStyle.Quart),{Position=UDim2.new(0.5,-150,1,yp)}):Play()
    task.delay(3,function()
        TweenService:Create(nf,TweenInfo.new(0.2,Enum.EasingStyle.Quart),{Position=UDim2.new(0.5,-150,1,yp+44)}):Play()
        task.wait(0.25); pcall(function()nf:Destroy()end); nY=math.max(0,nY-1)
    end)
end

-- ================================================
-- АНАЛИЗ
-- ================================================
local function doAnalyze()
    AnlBtn.Text="..."; AnlBtn.BackgroundColor3=Color3.fromRGB(0,60,120)
    task.spawn(function()
        local ctx, info = deepAnalyze()
        gameContext = ctx
        local lines={"Игра: "..(info.gameName or tostring(info.placeId))}
        table.insert(lines,"Players:"..info.playerCount.." Speed:"..(info.speed or "?").." HP:"..(info.hp or "?"))
        if info.leaderstats and #info.leaderstats>0 then table.insert(lines,"Stats: "..table.concat(info.leaderstats,", ")) end
        if info.remotes and #info.remotes>0 then
            table.insert(lines,"Remotes("..#info.remotes.."): "..table.concat({table.unpack(info.remotes,1,math.min(5,#info.remotes))},", "))
        end
        if info.backpack and #info.backpack>0 then table.insert(lines,"Backpack: "..table.concat(info.backpack,", ")) end
        addMsg(table.concat(lines,"\n"),"anl")
        Stat.Text="ИИ знает игру!"; Stat.TextColor3=Color3.fromRGB(80,200,120)
        AnlBtn.Text="Re-analyze"; AnlBtn.BackgroundColor3=Color3.fromRGB(0,130,60)
        notif("Анализ готов! ИИ знает игру!", Color3.fromRGB(0,100,60))
    end)
end

AnlBtn.MouseButton1Click:Connect(doAnalyze)

-- ================================================
-- ОБНОВИТЬ ИСТОРИЮ КОМАНД
-- ================================================
local function updateHistory(cmd)
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
    updateHistory(txt)
    addMsg(txt,"user")

    -- Сначала пробуем локальные команды (мгновенно)
    local localResult = detectLocalCmd(txt)
    if localResult then
        addMsg(localResult,"ok")
        Stat.Text=localResult; Stat.TextColor3=Color3.fromRGB(80,220,100)
        notif(localResult, Color3.fromRGB(0,120,60))
        return
    end

    -- Если не распознано — отправляем в ИИ
    busy=true; SndBtn.Text="..."; SndBtn.BackgroundColor3=Color3.fromRGB(30,0,80)
    Stat.Text="AI думает..."; Stat.TextColor3=Color3.fromRGB(220,160,50)

    askAI(txt, function(code, err)
        busy=false; SndBtn.Text=">"; SndBtn.BackgroundColor3=Color3.fromRGB(80,0,200)
        if err then
            addMsg(err,"err")
            Stat.Text="Ошибка"; Stat.TextColor3=Color3.fromRGB(255,80,80)
            notif("Ошибка: "..err:sub(1,40), Color3.fromRGB(120,0,40))
            return
        end
        lastCode=code
        if debugMode then addMsg(code:sub(1,150)..(#code>150 and "..." or ""),"code") end
        local ok,runErr = runCode(code)
        if ok then
            addMsg("Выполнено!","ok")
            Stat.Text="Выполнено"; Stat.TextColor3=Color3.fromRGB(80,220,100)
            notif("AI выполнил скрипт!", Color3.fromRGB(0,120,60))
        else
            addMsg(tostring(runErr):sub(1,80),"err")
            Stat.Text="Ошибка кода"; Stat.TextColor3=Color3.fromRGB(255,80,80)
        end
    end)
end

local function send()
    local txt=Inp.Text:match("^%s*(.-)%s*$")
    if txt=="" then return end
    Inp.Text=""
    sendCmd(txt)
end

SndBtn.MouseButton1Click:Connect(send)
Inp.FocusLost:Connect(function(e) if e then send() end end)

for _,qb in ipairs(quickBtns) do
    qb.btn.MouseButton1Click:Connect(function() sendCmd(qb.cmd) end)
end
for i,hb in ipairs(histBtns) do
    hb.MouseButton1Click:Connect(function() if cmdHistory[i] then sendCmd(cmdHistory[i]) end end)
end

RepBtn.MouseButton1Click:Connect(function() if lastCmd~="" then sendCmd(lastCmd) end end)

DbgBtn.MouseButton1Click:Connect(function()
    debugMode=not debugMode
    DbgBtn.BackgroundColor3=debugMode and Color3.fromRGB(120,120,0) or Color3.fromRGB(70,70,20)
    notif(debugMode and "Debug ON" or "Debug OFF", Color3.fromRGB(60,60,0))
end)

ClrBtn.MouseButton1Click:Connect(function()
    for _,v in pairs(Scroll:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
    msgCount=0
    Stat.Text="Ready"; Stat.TextColor3=Color3.fromRGB(140,80,220)
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
-- СТАРТ
-- ================================================
task.wait(0.5)
notif("Primejtsu X | AI Mode v16!", Color3.fromRGB(55,0,150))
task.wait(0.8)
notif("Спасибо что выбрали нас! / Thank you!", Color3.fromRGB(80,0,200))
addMsg("ESP/Fly/Speed/Noclip/Aimbot — работают мгновенно!\nДля игровых команд — ИИ использует RemoteEvents.\nНажми Analyze для анализа игры!","ai")

task.delay(2, doAnalyze)
print("[PX] AI Mode v16 Loaded!")
