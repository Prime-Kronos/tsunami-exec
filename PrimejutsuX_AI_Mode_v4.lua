-- ================================================
--   Primejtsu X | AI Mode v2
--   Creator: @Primejtsu
-- ================================================

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local LP               = Players.LocalPlayer

local GROQ_KEY = "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"
local GROQ_URL = "https://api.groq.com/openai/v1/chat/completions"
local MODEL    = "llama-3.3-70b-versatile"

-- ================================================
-- HTTP — используем request() экзекьютора (Delta)
-- ================================================
local function httpRequest(url, method, headers, body)
    -- Delta и большинство экзекьюторов имеют request() или http_request()
    local fn = request or http_request or (syn and syn.request)
    if not fn then
        return nil, "No HTTP function available in this executor"
    end

    local ok, result = pcall(fn, {
        Url     = url,
        Method  = method,
        Headers = headers,
        Body    = body,
    })

    if not ok then
        return nil, tostring(result)
    end

    return result, nil
end

-- ================================================
-- СИСТЕМНЫЙ ПРОМПТ
-- ================================================
local SYSTEM = [[You are an expert Roblox executor script generator. Output ONLY raw Lua code, nothing else. No markdown, no backticks, no explanations, no comments in any language.

IMPORTANT TEMPLATES — use these exactly:

FLY:
pcall(function()
local LP=game.Players.LocalPlayer
local UIS=game:GetService("UserInputService")
local RS=game:GetService("RunService")
local cam=workspace.CurrentCamera
local char=LP.Character or LP.CharacterAdded:Wait()
local root=char:WaitForChild("HumanoidRootPart")
local hum=char:WaitForChild("Humanoid")
hum.PlatformStand=true
local bv=Instance.new("BodyVelocity",root)
bv.MaxForce=Vector3.new(1e5,1e5,1e5)
bv.Velocity=Vector3.new(0,0,0)
local bg=Instance.new("BodyGyro",root)
bg.MaxTorque=Vector3.new(1e5,1e5,1e5)
bg.CFrame=cam.CFrame
local spd=50
local conn=RS.Heartbeat:Connect(function()
local cf=cam.CFrame
local d=Vector3.new()
if UIS:IsKeyDown(Enum.KeyCode.W) then d=d+cf.LookVector end
if UIS:IsKeyDown(Enum.KeyCode.S) then d=d-cf.LookVector end
if UIS:IsKeyDown(Enum.KeyCode.A) then d=d-cf.RightVector end
if UIS:IsKeyDown(Enum.KeyCode.D) then d=d+cf.RightVector end
if UIS:IsKeyDown(Enum.KeyCode.Space) then d=d+Vector3.new(0,1,0) end
if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then d=d-Vector3.new(0,1,0) end
bv.Velocity=d*spd
bg.CFrame=cf
end)
_G.FlyConn=conn
end)

DISABLE FLY:
pcall(function()
if _G.FlyConn then _G.FlyConn:Disconnect() end
local LP=game.Players.LocalPlayer
local char=LP.Character
if char then
local root=char:FindFirstChild("HumanoidRootPart")
local hum=char:FindFirstChild("Humanoid")
if root then
local bv=root:FindFirstChild("BodyVelocity")
local bg=root:FindFirstChild("BodyGyro")
if bv then bv:Destroy() end
if bg then bg:Destroy() end
end
if hum then hum.PlatformStand=false end
end
end)

ESP:
pcall(function()
local Players=game:GetService("Players")
local LP=Players.LocalPlayer
for _,p in pairs(Players:GetPlayers()) do
if p~=LP and p.Character then
local hl=Instance.new("Highlight",p.Character)
hl.FillColor=Color3.fromRGB(255,0,0)
hl.OutlineColor=Color3.fromRGB(255,255,255)
hl.FillTransparency=0.5
hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
end
end
Players.PlayerAdded:Connect(function(p)
p.CharacterAdded:Connect(function(c)
local hl=Instance.new("Highlight",c)
hl.FillColor=Color3.fromRGB(255,0,0)
hl.OutlineColor=Color3.fromRGB(255,255,255)
hl.FillTransparency=0.5
hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
end)
end)
end)

DISABLE ESP:
pcall(function()
local Players=game:GetService("Players")
for _,p in pairs(Players:GetPlayers()) do
if p.Character then
for _,v in pairs(p.Character:GetChildren()) do
if v:IsA("Highlight") then v:Destroy() end
end
end
end
end)

SPEED (replace N with requested speed, default 50):
pcall(function()
local hum=game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
if hum then hum.WalkSpeed=50 end
end)

DISABLE SPEED:
pcall(function()
local hum=game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
if hum then hum.WalkSpeed=16 end
end)

AIMBOT:
pcall(function()
local Players=game:GetService("Players")
local RS=game:GetService("RunService")
local LP=Players.LocalPlayer
local cam=workspace.CurrentCamera
local conn=RS.RenderStepped:Connect(function()
local best,bestD=nil,math.huge
local cx=cam.ViewportSize.X/2
local cy=cam.ViewportSize.Y/2
for _,p in pairs(Players:GetPlayers()) do
if p~=LP and p.Character then
local hum=p.Character:FindFirstChild("Humanoid")
local part=p.Character:FindFirstChild("Head")
if hum and hum.Health>0 and part then
local sp,vis=cam:WorldToViewportPoint(part.Position)
if vis then
local d=math.sqrt((sp.X-cx)^2+(sp.Y-cy)^2)
if d<bestD then bestD=d;best=part end
end
end
end
end
if best then
cam.CFrame=cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position,best.Position),0.15)
end
end)
_G.AimbotConn=conn
end)

DISABLE AIMBOT:
pcall(function()
if _G.AimbotConn then _G.AimbotConn:Disconnect();_G.AimbotConn=nil end
end)

NOCLIP:
pcall(function()
local RS=game:GetService("RunService")
local LP=game.Players.LocalPlayer
local conn=RS.Stepped:Connect(function()
local char=LP.Character
if char then
for _,p in pairs(char:GetDescendants()) do
if p:IsA("BasePart") then p.CanCollide=false end
end
end
end)
_G.NoclipConn=conn
end)

DISABLE NOCLIP:
pcall(function()
if _G.NoclipConn then _G.NoclipConn:Disconnect();_G.NoclipConn=nil end
local char=game.Players.LocalPlayer.Character
if char then
for _,p in pairs(char:GetDescendants()) do
if p:IsA("BasePart") then pcall(function()p.CanCollide=true end) end
end
end
end)

INFJUMP:
pcall(function()
local UIS=game:GetService("UserInputService")
local LP=game.Players.LocalPlayer
local conn=UIS.JumpRequest:Connect(function()
local char=LP.Character
if char then
local hum=char:FindFirstChild("Humanoid")
if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end
end)
_G.InfJumpConn=conn
end)

Use these templates. If user asks for something not listed, generate the best Lua code you can following the same style. Output ONLY Lua code.]]

-- ================================================
-- АНАЛИЗАТОР ИГРЫ
-- ================================================
local gameContext = ""

local function analyzeGame()
    local info = {}
    local MS = game:GetService("MarketplaceService")

    pcall(function()
        local prod = MS:GetProductInfo(game.PlaceId)
        info.name = prod.Name
    end)
    info.placeId = game.PlaceId

    -- RemoteEvents
    local remotes = {}
    pcall(function()
        for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) and #remotes < 20 then
                table.insert(remotes, v.Name)
            end
        end
    end)
    info.remotes = table.concat(remotes, ", ")

    -- Персонаж
    local char = LP.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            info.walkSpeed = hum.WalkSpeed
            info.jumpPower = hum.JumpPower
            info.health    = hum.Health
        end
    end

    -- Workspace объекты
    local ws = {}
    pcall(function()
        for _, v in pairs(workspace:GetChildren()) do
            if #ws < 15 then
                table.insert(ws, v.Name.."("..v.ClassName..")")
            end
        end
    end)
    info.workspace = table.concat(ws, ", ")

    -- Формируем контекст для ИИ
    local ctx = "GAME CONTEXT: "
    if info.name then ctx = ctx .. "Game=" .. info.name .. " " end
    ctx = ctx .. "PlaceId=" .. tostring(info.placeId) .. " "
    if info.remotes ~= "" then ctx = ctx .. "RemoteEvents=[" .. info.remotes .. "] " end
    if info.walkSpeed then ctx = ctx .. "WalkSpeed=" .. info.walkSpeed .. " JumpPower=" .. tostring(info.jumpPower) .. " " end
    if info.workspace ~= "" then ctx = ctx .. "Workspace=[" .. info.workspace .. "]" end

    return ctx, info
end

-- ================================================
-- ИСТОРИЯ
-- ================================================
local history = {}

-- ================================================
-- ЗАПРОС К GROQ
-- ================================================
local function askGroq(userMsg, callback)
    table.insert(history, {role = "user", content = userMsg})

    local messages = {{role = "system", content = SYSTEM}}
    for _, m in ipairs(history) do
        table.insert(messages, m)
    end

    -- Ограничиваем историю до 10 сообщений чтобы не превысить лимит
    if #messages > 12 then
        local trimmed = {{role = "system", content = SYSTEM}}
        for i = #messages - 9, #messages do
            table.insert(trimmed, messages[i])
        end
        messages = trimmed
    end

    local bodyStr = HttpService:JSONEncode({
        model       = MODEL,
        messages    = messages,
        max_tokens  = 800,
        temperature = 0.1,
    })

    task.spawn(function()
        local result, err = httpRequest(
            GROQ_URL,
            "POST",
            {
                ["Content-Type"]  = "application/json",
                ["Authorization"] = "Bearer " .. GROQ_KEY,
            },
            bodyStr
        )

        if err or not result then
            callback(nil, "HTTP Error: " .. tostring(err))
            return
        end

        if result.StatusCode ~= 200 then
            callback(nil, "API Error " .. tostring(result.StatusCode) .. ": " .. tostring(result.Body):sub(1, 100))
            return
        end

        local ok, parsed = pcall(HttpService.JSONDecode, HttpService, result.Body)
        if not ok or not parsed then
            callback(nil, "JSON parse error")
            return
        end

        local reply = ""
        pcall(function()
            reply = parsed.choices[1].message.content
        end)

        if reply == "" then
            callback(nil, "Empty response from AI")
            return
        end

        -- Чистим код от markdown если ИИ всё же добавил
        reply = reply:gsub("```lua", ""):gsub("```", ""):match("^%s*(.-)%s*$")

        table.insert(history, {role = "assistant", content = reply})
        callback(reply, nil)
    end)
end

-- ================================================
-- ВЫПОЛНИТЬ КОД
-- ================================================
local function runCode(code)
    local fn, syntaxErr = loadstring(code)
    if not fn then
        return false, "Syntax: " .. tostring(syntaxErr)
    end
    local ok, runtimeErr = pcall(fn)
    if not ok then
        return false, "Runtime: " .. tostring(runtimeErr)
    end
    return true, nil
end

-- ================================================
-- GUI
-- ================================================
local oldGui = LP.PlayerGui:FindFirstChild("PX_AI")
if oldGui then oldGui:Destroy() end

local Gui = Instance.new("ScreenGui")
Gui.Name           = "PX_AI"
Gui.ResetOnSpawn   = false
Gui.DisplayOrder   = 999
Gui.Parent         = LP.PlayerGui

-- Главное окно
local Main = Instance.new("Frame", Gui)
Main.Size             = UDim2.new(0, 300, 0, 440)
Main.Position         = UDim2.new(0.5, -150, 0.5, -220)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
Main.BorderSizePixel  = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", Main).Color        = Color3.fromRGB(100, 0, 220)
Main:FindFirstChildOfClass("UIStroke").Thickness    = 1.5

-- Тайтл
local TB = Instance.new("Frame", Main)
TB.Size             = UDim2.new(1, 0, 0, 38)
TB.BackgroundColor3 = Color3.fromRGB(55, 0, 150)
TB.BorderSizePixel  = 0
Instance.new("UICorner", TB).CornerRadius = UDim.new(0, 12)
Instance.new("Frame", TB).Size            = UDim2.new(1, 0, 0.5, 0)
TB:FindFirstChildOfClass("Frame").Position         = UDim2.new(0, 0, 0.5, 0)
TB:FindFirstChildOfClass("Frame").BackgroundColor3 = Color3.fromRGB(55, 0, 150)
TB:FindFirstChildOfClass("Frame").BorderSizePixel  = 0

local TL = Instance.new("TextLabel", TB)
TL.Size                 = UDim2.new(1, -45, 1, 0)
TL.Position             = UDim2.new(0, 12, 0, 0)
TL.BackgroundTransparency = 1
TL.TextColor3           = Color3.fromRGB(255, 255, 255)
TL.TextSize             = 13
TL.Font                 = Enum.Font.GothamBold
TL.Text                 = "Primejtsu X | AI Mode"
TL.TextXAlignment       = Enum.TextXAlignment.Left

local XBtn = Instance.new("TextButton", TB)
XBtn.Size             = UDim2.new(0, 28, 0, 28)
XBtn.Position         = UDim2.new(1, -34, 0.5, -14)
XBtn.BackgroundColor3 = Color3.fromRGB(160, 0, 50)
XBtn.BorderSizePixel  = 0
XBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
XBtn.TextSize         = 13
XBtn.Font             = Enum.Font.GothamBold
XBtn.Text             = "X"
XBtn.AutoButtonColor  = false
Instance.new("UICorner", XBtn).CornerRadius = UDim.new(0, 6)

-- Чат
local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size                    = UDim2.new(1, -12, 1, -150)
Scroll.Position                = UDim2.new(0, 6, 0, 44)
Scroll.BackgroundColor3        = Color3.fromRGB(14, 14, 22)
Scroll.BorderSizePixel         = 0
Scroll.ScrollBarThickness      = 3
Scroll.ScrollBarImageColor3    = Color3.fromRGB(100, 0, 220)
Scroll.AutomaticCanvasSize     = Enum.AutomaticSize.Y
Scroll.CanvasSize              = UDim2.new(0, 0, 0, 0)
Instance.new("UICorner", Scroll).CornerRadius = UDim.new(0, 8)

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding   = UDim.new(0, 5)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
local Pad = Instance.new("UIPadding", Scroll)
Pad.PaddingLeft   = UDim.new(0, 5)
Pad.PaddingRight  = UDim.new(0, 5)
Pad.PaddingTop    = UDim.new(0, 5)
Pad.PaddingBottom = UDim.new(0, 5)

-- Кнопка анализа
local AnlBtn = Instance.new("TextButton", Main)
AnlBtn.Size             = UDim2.new(1, -12, 0, 28)
AnlBtn.Position         = UDim2.new(0, 6, 1, -136)
AnlBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
AnlBtn.BorderSizePixel  = 0
AnlBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
AnlBtn.TextSize         = 11
AnlBtn.Font             = Enum.Font.GothamBold
AnlBtn.Text             = "Анализировать игру / Analyze game"
AnlBtn.AutoButtonColor  = false
Instance.new("UICorner", AnlBtn).CornerRadius = UDim.new(0, 7)

-- Статус
local Stat = Instance.new("TextLabel", Main)
Stat.Size                 = UDim2.new(1, -12, 0, 16)
Stat.Position             = UDim2.new(0, 6, 1, -104)
Stat.BackgroundTransparency = 1
Stat.TextColor3           = Color3.fromRGB(140, 80, 220)
Stat.TextSize             = 10
Stat.Font                 = Enum.Font.Gotham
Stat.Text                 = "Ready / Готов"
Stat.TextXAlignment       = Enum.TextXAlignment.Left

-- Инпут фрейм
local IF = Instance.new("Frame", Main)
IF.Size             = UDim2.new(1, -12, 0, 36)
IF.Position         = UDim2.new(0, 6, 1, -84)
IF.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
IF.BorderSizePixel  = 0
Instance.new("UICorner", IF).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", IF).Color        = Color3.fromRGB(80, 0, 180)

local Inp = Instance.new("TextBox", IF)
Inp.Size                 = UDim2.new(1, -46, 1, 0)
Inp.Position             = UDim2.new(0, 8, 0, 0)
Inp.BackgroundTransparency = 1
Inp.TextColor3           = Color3.fromRGB(220, 200, 255)
Inp.PlaceholderText      = "Генерируй... / Generate..."
Inp.PlaceholderColor3    = Color3.fromRGB(70, 60, 100)
Inp.TextSize             = 11
Inp.Font                 = Enum.Font.Gotham
Inp.TextXAlignment       = Enum.TextXAlignment.Left
Inp.ClearTextOnFocus     = false
Inp.Text                 = ""

local SndBtn = Instance.new("TextButton", IF)
SndBtn.Size             = UDim2.new(0, 38, 1, -4)
SndBtn.Position         = UDim2.new(1, -42, 0, 2)
SndBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 200)
SndBtn.BorderSizePixel  = 0
SndBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
SndBtn.TextSize         = 16
SndBtn.Font             = Enum.Font.GothamBold
SndBtn.Text             = ">"
SndBtn.AutoButtonColor  = false
Instance.new("UICorner", SndBtn).CornerRadius = UDim.new(0, 6)

-- Очистить
local ClrBtn = Instance.new("TextButton", Main)
ClrBtn.Size             = UDim2.new(1, -12, 0, 24)
ClrBtn.Position         = UDim2.new(0, 6, 1, -44)
ClrBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 36)
ClrBtn.BorderSizePixel  = 0
ClrBtn.TextColor3       = Color3.fromRGB(100, 70, 160)
ClrBtn.TextSize         = 10
ClrBtn.Font             = Enum.Font.Gotham
ClrBtn.Text             = "Очистить чат / Clear chat"
ClrBtn.AutoButtonColor  = false
Instance.new("UICorner", ClrBtn).CornerRadius = UDim.new(0, 6)

-- ================================================
-- КНОПКА AI (когда скрыт)
-- ================================================
local AIBtn = Instance.new("TextButton", Gui)
AIBtn.Size             = UDim2.new(0, 42, 0, 42)
AIBtn.Position         = UDim2.new(0, 8, 0.5, -21)
AIBtn.BackgroundColor3 = Color3.fromRGB(55, 0, 150)
AIBtn.BorderSizePixel  = 0
AIBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
AIBtn.TextSize         = 13
AIBtn.Font             = Enum.Font.GothamBold
AIBtn.Text             = "AI"
AIBtn.AutoButtonColor  = false
AIBtn.Visible          = false
Instance.new("UICorner", AIBtn).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", AIBtn).Color        = Color3.fromRGB(150, 80, 255)
AIBtn:FindFirstChildOfClass("UIStroke").Thickness = 1.5

XBtn.MouseButton1Click:Connect(function()
    Main.Visible  = false
    AIBtn.Visible = true
end)
AIBtn.MouseButton1Click:Connect(function()
    Main.Visible  = true
    AIBtn.Visible = false
end)

-- ================================================
-- ДОБАВИТЬ СООБЩЕНИЕ
-- ================================================
local msgCount = 0
local function addMsg(text, who)
    -- who: "user" | "ai" | "ok" | "err"
    msgCount = msgCount + 1

    local bg = Instance.new("Frame", Scroll)
    bg.LayoutOrder      = msgCount
    bg.AutomaticSize    = Enum.AutomaticSize.Y
    bg.Size             = UDim2.new(1, 0, 0, 0)
    bg.BorderSizePixel  = 0
    bg.BackgroundColor3 = who == "user" and Color3.fromRGB(50, 0, 120)
        or who == "ok"   and Color3.fromRGB(10, 50, 20)
        or who == "err"  and Color3.fromRGB(60, 10, 20)
        or                    Color3.fromRGB(20, 20, 36)
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 7)
    local p = Instance.new("UIPadding", bg)
    p.PaddingLeft   = UDim.new(0, 7)
    p.PaddingRight  = UDim.new(0, 7)
    p.PaddingTop    = UDim.new(0, 5)
    p.PaddingBottom = UDim.new(0, 5)

    local prefix = who == "user" and "Ты: "
        or who == "ok"   and "Выполнено: "
        or who == "err"  and "Ошибка: "
        or                    "AI: "

    local lbl = Instance.new("TextLabel", bg)
    lbl.AutomaticSize   = Enum.AutomaticSize.Y
    lbl.Size            = UDim2.new(1, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3      = who == "user" and Color3.fromRGB(200, 170, 255)
        or who == "ok"   and Color3.fromRGB(100, 255, 120)
        or who == "err"  and Color3.fromRGB(255, 100, 100)
        or                    Color3.fromRGB(210, 210, 255)
    lbl.TextSize        = 11
    lbl.Font            = Enum.Font.Gotham
    lbl.TextWrapped     = true
    lbl.TextXAlignment  = Enum.TextXAlignment.Left
    lbl.Text            = prefix .. text

    task.wait(0.05)
    Scroll.CanvasPosition = Vector2.new(0, 999999)
end

-- ================================================
-- УВЕДОМЛЕНИЕ
-- ================================================
local notifY = 0
local function notif(text, col)
    notifY = notifY + 1
    local yp = -(52 + (notifY-1)*48)

    local nf = Instance.new("Frame", Gui)
    nf.Size             = UDim2.new(0, 320, 0, 38)
    nf.Position         = UDim2.new(0.5, -160, 1, yp + 50)
    nf.BackgroundColor3 = col or Color3.fromRGB(55, 0, 150)
    nf.BorderSizePixel  = 0
    Instance.new("UICorner", nf).CornerRadius = UDim.new(0, 10)
    local ns = Instance.new("UIStroke", nf)
    ns.Color = Color3.fromRGB(150, 80, 255); ns.Thickness = 1.2

    local nl = Instance.new("TextLabel", nf)
    nl.Size                 = UDim2.new(1, -14, 1, 0)
    nl.Position             = UDim2.new(0, 7, 0, 0)
    nl.BackgroundTransparency = 1
    nl.TextColor3           = Color3.fromRGB(255, 255, 255)
    nl.TextSize             = 11
    nl.Font                 = Enum.Font.GothamBold
    nl.TextWrapped          = true
    nl.TextXAlignment       = Enum.TextXAlignment.Left
    nl.Text                 = text

    TweenService:Create(nf, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
        Position = UDim2.new(0.5, -160, 1, yp)
    }):Play()

    task.delay(4, function()
        TweenService:Create(nf, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
            Position = UDim2.new(0.5, -160, 1, yp + 50)
        }):Play()
        task.wait(0.3)
        pcall(function() nf:Destroy() end)
        notifY = math.max(0, notifY - 1)
    end)
end

-- ================================================
-- ОТПРАВКА
-- ================================================
local busy = false

local function send()
    if busy then return end
    local txt = Inp.Text:match("^%s*(.-)%s*$")
    if txt == "" then return end
    Inp.Text = ""

    -- Добавляем контекст игры если есть
    local fullMsg = txt
    if gameContext ~= "" then
        fullMsg = gameContext .. "\nUser request: " .. txt
    end

    addMsg(txt, "user")
    busy           = true
    SndBtn.Text    = "..."
    SndBtn.BackgroundColor3 = Color3.fromRGB(30, 0, 80)
    Stat.Text      = "AI думает... / Thinking..."
    Stat.TextColor3 = Color3.fromRGB(220, 160, 50)

    askGroq(fullMsg, function(code, err)
        busy           = false
        SndBtn.Text    = ">"
        SndBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 200)

        if err then
            addMsg(err, "err")
            Stat.Text       = "Ошибка / Error"
            Stat.TextColor3 = Color3.fromRGB(255, 80, 80)
            notif("Ошибка / Error: " .. err:sub(1,60), Color3.fromRGB(120, 0, 40))
            return
        end

        -- Показываем превью кода
        local preview = code:sub(1, 100) .. (code:len() > 100 and "..." or "")
        addMsg(preview, "ai")

        -- Запускаем
        local ok, runErr = runCode(code)
        if ok then
            addMsg("Скрипт запущен! / Script executed!", "ok")
            Stat.Text       = "Выполнено / Executed"
            Stat.TextColor3 = Color3.fromRGB(80, 220, 100)
            notif("AI выполнил скрипт / AI executed script", Color3.fromRGB(0, 120, 60))
        else
            addMsg(tostring(runErr), "err")
            Stat.Text       = "Ошибка кода / Code error"
            Stat.TextColor3 = Color3.fromRGB(255, 80, 80)
            notif("Ошибка кода / Code error", Color3.fromRGB(120, 0, 40))
        end
    end)
end

SndBtn.MouseButton1Click:Connect(send)
Inp.FocusLost:Connect(function(enter) if enter then send() end end)

AnlBtn.MouseButton1Click:Connect(function()
    if busy then return end
    AnlBtn.Text             = "Анализирую... / Analyzing..."
    AnlBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 120)
    task.spawn(function()
        local ctx, info = analyzeGame()
        gameContext = ctx
        local summary = "Игра: " .. (info.name or tostring(game.PlaceId))
            .. "\nRemotes: " .. (info.remotes ~= "" and info.remotes:sub(1,80) or "none")
        addMsg("Анализ готов!\n" .. summary, "ok")
        Stat.Text       = "Игра проанализирована / Analyzed"
        Stat.TextColor3 = Color3.fromRGB(80, 200, 120)
        AnlBtn.Text             = "Проанализировано / Analyzed"
        AnlBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 60)
        notif("Игра проанализирована! / Game analyzed!", Color3.fromRGB(0, 100, 60))
        task.wait(3)
        AnlBtn.Text             = "Анализировать снова / Re-analyze"
        AnlBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
    end)
end)

ClrBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(Scroll:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
    history     = {}
    msgCount    = 0
    gameContext = ""
    Stat.Text       = "Ready / Готов"
    Stat.TextColor3 = Color3.fromRGB(140, 80, 220)
end)

-- ================================================
-- DRAGGABLE
-- ================================================
local drg, ds, sp = false, nil, nil
TB.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        drg = true; ds = i.Position; sp = Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if not drg then return end
    if i.UserInputType == Enum.UserInputType.MouseMovement
    or i.UserInputType == Enum.UserInputType.Touch then
        local d = i.Position - ds
        Main.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then drg = false end
end)

-- ================================================
-- СТАРТ
-- ================================================
task.wait(0.8)
notif("Primejtsu X | AI Mode v3 — Loaded!", Color3.fromRGB(55, 0, 150))
task.wait(1)
notif("Спасибо что выбрали нас! / Thank you for choosing us!", Color3.fromRGB(80, 0, 200))
addMsg("Привет! Напиши что сгенерировать.\nПример: генерируй флай\nПример: отключи флай\nНажми Analyze для анализа игры!\nExample: generate esp / disable esp", "ai")

print("[Primejtsu X] AI Mode v3 Loaded!")
