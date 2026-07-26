-- ================================================
--   Primejtsu X | AI Mode
--   Groq AI — генерирует и выполняет читы
--   Creator: @Primejtsu
-- ================================================

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local RunService       = game:GetService("RunService")
local LP               = Players.LocalPlayer

local GROQ_KEY = "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"
local GROQ_URL = "https://api.groq.com/openai/v1/chat/completions"
local MODEL    = "llama3-70b-8192"

-- ================================================
-- СИСТЕМНЫЙ ПРОМПТ — учим ИИ генерировать читы
-- ================================================
local SYSTEM_PROMPT = [[
You are an expert Roblox Lua cheat script generator. You run INSIDE a Roblox game executor (Delta).
The local player is already available as: game.Players.LocalPlayer

Your job:
- When asked to generate a cheat (aimbot, esp, speed, fly, noclip, etc.) — output ONLY raw Lua code, no markdown, no backticks, no explanation.
- When asked to disable/turn off something — output Lua code that disables/cleans it up.
- The code must be short, efficient, and work inside Roblox executor environment.
- Use RunService, Players, workspace, Camera etc directly.
- For ESP use Highlight instances.
- For Aimbot use Camera CFrame lerp toward nearest enemy.
- For Speed: game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = N
- For Fly: use BodyVelocity on HumanoidRootPart.
- For Noclip: set CanCollide false on character parts each Heartbeat.
- Always wrap in pcall to avoid errors.
- NEVER output anything except pure Lua code. No comments in Russian. No markdown.
- If user says "disable X" or "turn off X" or "отключи X" — generate cleanup code.
- Output ONLY the Lua code. Nothing else.
]]

-- ================================================
-- ИСТОРИЯ СООБЩЕНИЙ
-- ================================================
local chatHistory = {}

-- ================================================
-- GROQ API ЗАПРОС
-- ================================================
local function askGroq(userMessage, callback)
    table.insert(chatHistory, {
        role    = "user",
        content = userMessage
    })

    local messages = {{role = "system", content = SYSTEM_PROMPT}}
    for _, msg in ipairs(chatHistory) do
        table.insert(messages, msg)
    end

    local body = HttpService:JSONEncode({
        model       = MODEL,
        messages    = messages,
        max_tokens  = 1024,
        temperature = 0.2,
    })

    task.spawn(function()
        local ok, result = pcall(function()
            return HttpService:RequestAsync({
                Url     = GROQ_URL,
                Method  = "POST",
                Headers = {
                    ["Content-Type"]  = "application/json",
                    ["Authorization"] = "Bearer " .. GROQ_KEY,
                },
                Body = body,
            })
        end)

        if not ok then
            callback(nil, "Network error: " .. tostring(result))
            return
        end

        if result.StatusCode ~= 200 then
            callback(nil, "API error: " .. tostring(result.StatusCode))
            return
        end

        local parsed = HttpService:JSONDecode(result.Body)
        local reply  = parsed.choices[1].message.content

        table.insert(chatHistory, {
            role    = "assistant",
            content = reply
        })

        callback(reply, nil)
    end)
end

-- ================================================
-- ВЫПОЛНИТЬ КОД ОТ ИИ
-- ================================================
local function executeCode(code)
    local fn, err = loadstring(code)
    if fn then
        local ok, runErr = pcall(fn)
        if not ok then
            return false, tostring(runErr)
        end
        return true, nil
    else
        return false, tostring(err)
    end
end

-- ================================================
-- GUI
-- ================================================
local old = LP.PlayerGui:FindFirstChild("PX_AiGui")
if old then old:Destroy() end

local Gui = Instance.new("ScreenGui")
Gui.Name           = "PX_AiGui"
Gui.ResetOnSpawn   = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.DisplayOrder   = 999
Gui.Parent         = LP.PlayerGui

-- ================================================
-- ГЛАВНОЕ ОКНО
-- ================================================
local W, H = 320, 420

local Main = Instance.new("Frame", Gui)
Main.Name             = "Main"
Main.Size             = UDim2.new(0, W, 0, H)
Main.Position         = UDim2.new(0.5, -W/2, 0.5, -H/2)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
Main.BorderSizePixel  = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

local mainStroke = Instance.new("UIStroke", Main)
mainStroke.Color       = Color3.fromRGB(80, 0, 200)
mainStroke.Thickness   = 1.8
mainStroke.Transparency = 0.2

-- ================================================
-- ТАЙТЛ
-- ================================================
local TitleBar = Instance.new("Frame", Main)
TitleBar.Size             = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(60, 0, 160)
TitleBar.BorderSizePixel  = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 14)

local titleFix = Instance.new("Frame", TitleBar)
titleFix.Size             = UDim2.new(1, 0, 0.5, 0)
titleFix.Position         = UDim2.new(0, 0, 0.5, 0)
titleFix.BackgroundColor3 = Color3.fromRGB(60, 0, 160)
titleFix.BorderSizePixel  = 0

local TitleLbl = Instance.new("TextLabel", TitleBar)
TitleLbl.Size                 = UDim2.new(1, -50, 1, 0)
TitleLbl.Position             = UDim2.new(0, 14, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.TextColor3           = Color3.fromRGB(255, 255, 255)
TitleLbl.TextSize             = 14
TitleLbl.Font                 = Enum.Font.GothamBold
TitleLbl.Text                 = "Primejtsu X | AI Mode"
TitleLbl.TextXAlignment       = Enum.TextXAlignment.Left

-- Кнопка закрыть
local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size             = UDim2.new(0, 30, 0, 30)
CloseBtn.Position         = UDim2.new(1, -36, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 60)
CloseBtn.BorderSizePixel  = 0
CloseBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize         = 14
CloseBtn.Font             = Enum.Font.GothamBold
CloseBtn.Text             = "X"
CloseBtn.AutoButtonColor  = false
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
end)

-- ================================================
-- ОБЛАСТЬ ЧАТА (скроллинг)
-- ================================================
local ChatScroll = Instance.new("ScrollingFrame", Main)
ChatScroll.Size             = UDim2.new(1, -16, 1, -110)
ChatScroll.Position         = UDim2.new(0, 8, 0, 48)
ChatScroll.BackgroundColor3 = Color3.fromRGB(16, 16, 24)
ChatScroll.BorderSizePixel  = 0
ChatScroll.ScrollBarThickness = 3
ChatScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 0, 255)
ChatScroll.CanvasSize       = UDim2.new(0, 0, 0, 0)
ChatScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UICorner", ChatScroll).CornerRadius = UDim.new(0, 8)

local ChatLayout = Instance.new("UIListLayout", ChatScroll)
ChatLayout.Padding         = UDim.new(0, 6)
ChatLayout.SortOrder       = Enum.SortOrder.LayoutOrder
ChatLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

local ChatPad = Instance.new("UIPadding", ChatScroll)
ChatPad.PaddingLeft   = UDim.new(0, 6)
ChatPad.PaddingRight  = UDim.new(0, 6)
ChatPad.PaddingTop    = UDim.new(0, 6)
ChatPad.PaddingBottom = UDim.new(0, 6)

-- ================================================
-- СТАТУС (думает / готово)
-- ================================================
local StatusLbl = Instance.new("TextLabel", Main)
StatusLbl.Size                 = UDim2.new(1, -16, 0, 18)
StatusLbl.Position             = UDim2.new(0, 8, 1, -104)
StatusLbl.BackgroundTransparency = 1
StatusLbl.TextColor3           = Color3.fromRGB(120, 80, 200)
StatusLbl.TextSize             = 11
StatusLbl.Font                 = Enum.Font.Gotham
StatusLbl.Text                 = "AI готов к работе / AI is ready"
StatusLbl.TextXAlignment       = Enum.TextXAlignment.Left

-- ================================================
-- ПОЛЕ ВВОДА
-- ================================================
local InputFrame = Instance.new("Frame", Main)
InputFrame.Size             = UDim2.new(1, -16, 0, 38)
InputFrame.Position         = UDim2.new(0, 8, 1, -78)
InputFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 34)
InputFrame.BorderSizePixel  = 0
Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0, 8)

local inputStroke = Instance.new("UIStroke", InputFrame)
inputStroke.Color     = Color3.fromRGB(80, 0, 180)
inputStroke.Thickness = 1.2

local Input = Instance.new("TextBox", InputFrame)
Input.Size                 = UDim2.new(1, -50, 1, 0)
Input.Position             = UDim2.new(0, 8, 0, 0)
Input.BackgroundTransparency = 1
Input.TextColor3           = Color3.fromRGB(220, 220, 255)
Input.PlaceholderText      = "Напиши команду... / Type command..."
Input.PlaceholderColor3    = Color3.fromRGB(80, 80, 120)
Input.TextSize             = 12
Input.Font                 = Enum.Font.Gotham
Input.TextXAlignment       = Enum.TextXAlignment.Left
Input.ClearTextOnFocus     = false
Input.MultiLine            = false
Input.Text                 = ""

-- Кнопка отправить
local SendBtn = Instance.new("TextButton", InputFrame)
SendBtn.Size             = UDim2.new(0, 40, 1, -4)
SendBtn.Position         = UDim2.new(1, -44, 0, 2)
SendBtn.BackgroundColor3 = Color3.fromRGB(90, 0, 210)
SendBtn.BorderSizePixel  = 0
SendBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
SendBtn.TextSize         = 18
SendBtn.Font             = Enum.Font.GothamBold
SendBtn.Text             = ">"
SendBtn.AutoButtonColor  = false
Instance.new("UICorner", SendBtn).CornerRadius = UDim.new(0, 6)

-- ================================================
-- КНОПКА ОЧИСТИТЬ ЧАТ
-- ================================================
local ClearBtn = Instance.new("TextButton", Main)
ClearBtn.Size             = UDim2.new(1, -16, 0, 26)
ClearBtn.Position         = UDim2.new(0, 8, 1, -36)
ClearBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 46)
ClearBtn.BorderSizePixel  = 0
ClearBtn.TextColor3       = Color3.fromRGB(120, 80, 180)
ClearBtn.TextSize         = 11
ClearBtn.Font             = Enum.Font.Gotham
ClearBtn.Text             = "Очистить чат / Clear chat"
ClearBtn.AutoButtonColor  = false
Instance.new("UICorner", ClearBtn).CornerRadius = UDim.new(0, 6)

local orderCounter = 0

-- ================================================
-- ДОБАВИТЬ СООБЩЕНИЕ В ЧАТ
-- ================================================
local function addMessage(text, isUser, isError, isCode)
    orderCounter = orderCounter + 1

    local bubble = Instance.new("Frame", ChatScroll)
    bubble.BackgroundColor3 = isError and Color3.fromRGB(80, 10, 20)
        or isCode  and Color3.fromRGB(10, 30, 10)
        or isUser  and Color3.fromRGB(60, 0, 140)
        or                Color3.fromRGB(22, 22, 38)
    bubble.BorderSizePixel  = 0
    bubble.AutomaticSize    = Enum.AutomaticSize.Y
    bubble.Size             = UDim2.new(1, 0, 0, 0)
    bubble.LayoutOrder      = orderCounter
    Instance.new("UICorner", bubble).CornerRadius = UDim.new(0, 8)

    local pad = Instance.new("UIPadding", bubble)
    pad.PaddingLeft   = UDim.new(0, 8)
    pad.PaddingRight  = UDim.new(0, 8)
    pad.PaddingTop    = UDim.new(0, 6)
    pad.PaddingBottom = UDim.new(0, 6)

    -- Префикс
    local prefix = isUser  and "Ты: "
        or isError and "Ошибка: "
        or isCode  and "Код выполнен: "
        or             "AI: "

    local lbl = Instance.new("TextLabel", bubble)
    lbl.Size                 = UDim2.new(1, 0, 0, 0)
    lbl.AutomaticSize        = Enum.AutomaticSize.Y
    lbl.BackgroundTransparency = 1
    lbl.TextColor3           = isError and Color3.fromRGB(255, 100, 100)
        or isCode  and Color3.fromRGB(100, 255, 100)
        or isUser  and Color3.fromRGB(200, 180, 255)
        or             Color3.fromRGB(210, 210, 255)
    lbl.TextSize             = 11
    lbl.Font                 = isCode and Enum.Font.Code or Enum.Font.Gotham
    lbl.Text                 = prefix .. text
    lbl.TextWrapped          = true
    lbl.TextXAlignment       = Enum.TextXAlignment.Left
    lbl.RichText             = false

    -- Скроллим вниз
    task.wait(0.05)
    ChatScroll.CanvasPosition = Vector2.new(0, 999999)

    return bubble
end

-- ================================================
-- УВЕДОМЛЕНИЕ ВНИЗУ ЭКРАНА
-- ================================================
local notifOrder = 0
local function showNotif(text, color)
    notifOrder = notifOrder + 1
    local yOff = -(60 + (notifOrder - 1) * 50)

    local nf = Instance.new("Frame", Gui)
    nf.Size             = UDim2.new(0, 340, 0, 40)
    nf.Position         = UDim2.new(0.5, -170, 1, yOff)
    nf.BackgroundColor3 = color or Color3.fromRGB(60, 0, 160)
    nf.BorderSizePixel  = 0
    Instance.new("UICorner", nf).CornerRadius = UDim.new(0, 10)

    local ns = Instance.new("UIStroke", nf)
    ns.Color     = Color3.fromRGB(150, 80, 255)
    ns.Thickness = 1.2

    local nl = Instance.new("TextLabel", nf)
    nl.Size                 = UDim2.new(1, -16, 1, 0)
    nl.Position             = UDim2.new(0, 8, 0, 0)
    nl.BackgroundTransparency = 1
    nl.TextColor3           = Color3.fromRGB(255, 255, 255)
    nl.TextSize             = 12
    nl.Font                 = Enum.Font.GothamBold
    nl.Text                 = text
    nl.TextWrapped          = true
    nl.TextXAlignment       = Enum.TextXAlignment.Left

    -- Анимация появления
    nf.Position = UDim2.new(0.5, -170, 1, yOff + 60)
    TweenService:Create(nf, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
        Position = UDim2.new(0.5, -170, 1, yOff)
    }):Play()

    -- Убираем через 4 секунды
    task.delay(4, function()
        TweenService:Create(nf, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Position = UDim2.new(0.5, -170, 1, yOff + 60)
        }):Play()
        task.wait(0.35)
        nf:Destroy()
        notifOrder = math.max(0, notifOrder - 1)
    end)
end

-- ================================================
-- ОТПРАВКА СООБЩЕНИЯ
-- ================================================
local isThinking = false

local function sendMessage()
    if isThinking then return end
    local text = Input.Text:match("^%s*(.-)%s*$")
    if text == "" then return end

    Input.Text = ""
    addMessage(text, true)
    isThinking = true

    StatusLbl.Text      = "AI думает... / AI is thinking..."
    StatusLbl.TextColor3 = Color3.fromRGB(200, 150, 50)

    -- Анимация кнопки
    SendBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 100)
    SendBtn.Text = "..."

    askGroq(text, function(reply, err)
        isThinking = false
        SendBtn.BackgroundColor3 = Color3.fromRGB(90, 0, 210)
        SendBtn.Text = ">"

        if err then
            addMessage(err, false, true)
            StatusLbl.Text       = "Ошибка / Error"
            StatusLbl.TextColor3 = Color3.fromRGB(255, 80, 80)
            showNotif("Ошибка запроса / Request error", Color3.fromRGB(140, 0, 40))
            return
        end

        -- Показываем сгенерированный код (первые 120 символов)
        local preview = reply:sub(1, 120) .. (reply:len() > 120 and "..." or "")
        addMessage(preview, false, false, false)

        -- Выполняем код
        local ok, execErr = executeCode(reply)

        if ok then
            StatusLbl.Text       = "Выполнено / Executed successfully"
            StatusLbl.TextColor3 = Color3.fromRGB(80, 200, 80)
            addMessage("Выполнено! / Executed!", false, false, true)
            showNotif("AI выполнил код / AI executed code", Color3.fromRGB(0, 130, 60))
        else
            StatusLbl.Text       = "Ошибка выполнения / Execution error"
            StatusLbl.TextColor3 = Color3.fromRGB(255, 80, 80)
            addMessage("Ошибка: " .. tostring(execErr), false, true)
            showNotif("Ошибка кода / Code error", Color3.fromRGB(140, 0, 40))
        end
    end)
end

SendBtn.MouseButton1Click:Connect(sendMessage)

Input.FocusLost:Connect(function(enter)
    if enter then sendMessage() end
end)

ClearBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(ChatScroll:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
    chatHistory = {}
    orderCounter = 0
    StatusLbl.Text       = "AI готов к работе / AI is ready"
    StatusLbl.TextColor3 = Color3.fromRGB(120, 80, 200)
end)

-- ================================================
-- DRAGGABLE
-- ================================================
local dragging, dragStart, startPos = false, nil, nil

TitleBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        dragging  = true
        dragStart = inp.Position
        startPos  = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(inp)
    if not dragging then return end
    if inp.UserInputType == Enum.UserInputType.MouseMovement
    or inp.UserInputType == Enum.UserInputType.Touch then
        local d = inp.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ================================================
-- КНОПКА ПОКАЗАТЬ/СКРЫТЬ (когда закрыт)
-- ================================================
local ToggleBtn = Instance.new("TextButton", Gui)
ToggleBtn.Size             = UDim2.new(0, 44, 0, 44)
ToggleBtn.Position         = UDim2.new(0, 10, 0.5, -22)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 160)
ToggleBtn.BorderSizePixel  = 0
ToggleBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize         = 22
ToggleBtn.Font             = Enum.Font.GothamBold
ToggleBtn.Text             = "AI"
ToggleBtn.AutoButtonColor  = false
ToggleBtn.Visible          = false
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 12)

local tStroke = Instance.new("UIStroke", ToggleBtn)
tStroke.Color     = Color3.fromRGB(150, 80, 255)
tStroke.Thickness = 1.5

CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible   = false
    ToggleBtn.Visible = true
end)

ToggleBtn.MouseButton1Click:Connect(function()
    Main.Visible      = true
    ToggleBtn.Visible = false
end)

-- ================================================
-- СТАРТ — уведомления приветствия
-- ================================================
task.wait(1)

showNotif("Primejtsu X | AI Mode — Loaded!", Color3.fromRGB(60, 0, 160))

task.wait(1.2)
showNotif("Спасибо что выбрали нас! Thank you for choosing us!", Color3.fromRGB(80, 0, 200))

task.wait(0.5)
addMessage("Привет! Напиши что сгенерировать.\nПример: генерируй Aimbot + ESP\nHello! Type what to generate.\nExample: generate Aimbot + ESP", false)

print("[Primejtsu X] AI Mode Loaded!")
