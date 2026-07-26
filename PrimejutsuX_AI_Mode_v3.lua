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
local SYSTEM = "You are a Roblox Lua script generator running inside a Roblox executor. " ..
"The user will ask you to generate scripts like aimbot, esp, speed hack, fly, noclip, etc. " ..
"Rules: " ..
"1. Output ONLY raw Lua code. No markdown, no backticks, no explanation, no comments. " ..
"2. The code runs inside Roblox on the client side via loadstring(). " ..
"3. LocalPlayer = game.Players.LocalPlayer, Character, HumanoidRootPart etc are available. " ..
"4. For ESP use Highlight instances on player characters. " ..
"5. For Aimbot use Camera CFrame lerp toward nearest enemy HumanoidRootPart. " ..
"6. For Speed: game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 50 " ..
"7. For Fly use BodyVelocity on HumanoidRootPart with RunService.Heartbeat. " ..
"8. For Noclip use RunService.Stepped to set CanCollide false on character parts. " ..
"9. Always wrap everything in pcall. " ..
"10. If user says disable/off/отключи — generate cleanup code to remove what was added. " ..
"11. Keep code short and working. Output ONLY Lua code, nothing else."

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
Main.Size             = UDim2.new(0, 300, 0, 400)
Main.Position         = UDim2.new(0.5, -150, 0.5, -200)
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
Scroll.Size                    = UDim2.new(1, -12, 1, -110)
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

-- Статус
local Stat = Instance.new("TextLabel", Main)
Stat.Size                 = UDim2.new(1, -12, 0, 16)
Stat.Position             = UDim2.new(0, 6, 1, -96)
Stat.BackgroundTransparency = 1
Stat.TextColor3           = Color3.fromRGB(140, 80, 220)
Stat.TextSize             = 10
Stat.Font                 = Enum.Font.Gotham
Stat.Text                 = "Ready / Готов"
Stat.TextXAlignment       = Enum.TextXAlignment.Left

-- Инпут фрейм
local IF = Instance.new("Frame", Main)
IF.Size             = UDim2.new(1, -12, 0, 36)
IF.Position         = UDim2.new(0, 6, 1, -76)
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
ClrBtn.Position         = UDim2.new(0, 6, 1, -36)
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

    addMsg(txt, "user")
    busy           = true
    SndBtn.Text    = "..."
    SndBtn.BackgroundColor3 = Color3.fromRGB(30, 0, 80)
    Stat.Text      = "AI думает... / Thinking..."
    Stat.TextColor3 = Color3.fromRGB(220, 160, 50)

    askGroq(txt, function(code, err)
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

ClrBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(Scroll:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
    history  = {}
    msgCount = 0
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
notif("Primejtsu X | AI Mode v2 — Loaded!", Color3.fromRGB(55, 0, 150))
task.wait(1)
notif("Спасибо что выбрали нас! / Thank you for choosing us!", Color3.fromRGB(80, 0, 200))
addMsg("Привет! Напиши что сгенерировать.\nПример: генерируй aimbot\nПример: отключи aimbot\nHi! Type what to generate.\nExample: generate esp", "ai")

print("[Primejtsu X] AI Mode v2 Loaded!")
