-- ============================================================
-- УНИВЕРСАЛЬНЫЙ ИИ-СКРИПТ ДЛЯ ROBLOX (С ИНТЕГРАЦИЕЙ GROQ)
-- Версия 1.0 – анализирует игру и выполняет команды на NL
-- ============================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- ===== НАСТРОЙКИ =====
local GROQ_API_KEY = "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"
local GROQ_MODEL = "llama-3.3-70b-versatile"
local GROQ_URL = "https://api.groq.com/openai/v1/chat/completions"

-- ===== ПЕРЕМЕННЫЕ =====
local isAnalyzed = false
local gameData = {}
local isExecuting = false

-- ===== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ =====
local function getCharacter()
    local char = Player.Character
    if not char then return nil, nil, nil end
    local hum = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    return char, hum, root
end

local function getPlayersInfo()
    local info = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then
            local char = plr.Character
            if char and char:FindFirstChild("Humanoid") then
                local root = char:FindFirstChild("HumanoidRootPart")
                local pos = root and root.Position or Vector3.new(0,0,0)
                table.insert(info, {
                    name = plr.Name,
                    health = char.Humanoid.Health,
                    maxHealth = char.Humanoid.MaxHealth,
                    position = {x=pos.X, y=pos.Y, z=pos.Z}
                })
            end
        end
    end
    return info
end

local function getItemsInfo()
    local items = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj:FindFirstChild("TouchInterest") then
            local name = obj.Name
            local pos = obj.Position
            table.insert(items, {
                name = name,
                position = {x=pos.X, y=pos.Y, z=pos.Z}
            })
        end
    end
    return items
end

local function getNPCsInfo()
    local npcs = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= Player.Character then
            local root = obj:FindFirstChild("HumanoidRootPart")
            if root then
                local pos = root.Position
                table.insert(npcs, {
                    name = obj.Name,
                    health = obj.Humanoid.Health,
                    position = {x=pos.X, y=pos.Y, z=pos.Z}
                })
            end
        end
    end
    return npcs
end

-- ===== ФУНКЦИЯ АНАЛИЗА =====
function analyzeGame()
    gameData = {
        players = getPlayersInfo(),
        items = getItemsInfo(),
        npcs = getNPCsInfo(),
        myHealth = Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health or 0,
        myPosition = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and {
            x = Player.Character.HumanoidRootPart.Position.X,
            y = Player.Character.HumanoidRootPart.Position.Y,
            z = Player.Character.HumanoidRootPart.Position.Z
        } or {x=0,y=0,z=0}
    }
    isAnalyzed = true
    print("[ИИ] Анализ завершён.")
end

-- ===== ФУНКЦИЯ ВЫПОЛНЕНИЯ КОМАНД =====
function executeAction(action)
    local cmd = action.cmd
    local params = action.params or {}
    local char, hum, root = getCharacter()
    if not char or not hum or not root then return end

    if cmd == "move" then
        local x = params.x or 0
        local y = params.y or 0
        local z = params.z or 0
        hum:MoveTo(Vector3.new(x, y, z))
    elseif cmd == "attack" then
        -- предполагается, что атака на клавишу Q или клик мыши
        keypress("Q")
        wait(0.1)
        mouse1click()
    elseif cmd == "collect" then
        -- подбираем предмет (нажимаем E)
        keypress("E")
    elseif cmd == "teleport" then
        local x = params.x or 0
        local y = params.y or 0
        local z = params.z or 0
        root.CFrame = CFrame.new(x, y, z)
    elseif cmd == "use" then
        -- использовать предмет (например, клавиша 1-9)
        local slot = params.slot or 1
        keypress(tostring(slot))
    elseif cmd == "wait" then
        local time = params.time or 1
        wait(time)
    else
        print("[ИИ] Неизвестная команда: " .. cmd)
    end
end

-- ===== ФУНКЦИЯ ОБРАБОТКИ КОМАНДЫ ЧЕРЕЗ GROQ =====
function processCommand(userCommand)
    if not isAnalyzed then
        print("[ИИ] Сначала нажмите 'Анализировать'.")
        return
    end

    -- Подготовка промпта для Groq
    local prompt = string.format([[
Ты – ИИ-помощник для игры Roblox. Игрок даёт тебе команду на естественном языке.
Ты должен проанализировать текущее состояние игры и вернуть JSON-массив действий, которые нужно выполнить последовательно.

Состояние игры (в формате JSON):
%s

Команда игрока: %s

Формат ответа: 
[
    {"cmd": "move", "params": {"x": число, "y": число, "z": число}},
    {"cmd": "attack", "params": {}},
    {"cmd": "collect", "params": {}},
    {"cmd": "teleport", "params": {"x": число, "y": число, "z": число}},
    {"cmd": "use", "params": {"slot": число}},
    {"cmd": "wait", "params": {"time": число}}
]
Не добавляй пояснений, только JSON-массив.
]], HttpService:JSONEncode(gameData), userCommand)

    -- Отправка запроса к Groq
    local headers = {
        ["Authorization"] = "Bearer " .. GROQ_API_KEY,
        ["Content-Type"] = "application/json"
    }
    local body = {
        model = GROQ_MODEL,
        messages = {
            {role = "system", content = "Ты – ИИ-ассистент для Roblox. Отвечай только JSON-массивом команд."},
            {role = "user", content = prompt}
        },
        temperature = 0.3,
        max_tokens = 500
    }

    local success, response = pcall(function()
        return HttpService:PostAsync(GROQ_URL, HttpService:JSONEncode(body), Enum.HttpContentType.ApplicationJson, false, headers)
    end)

    if not success then
        print("[ИИ] Ошибка запроса к Groq.")
        return
    end

    local decoded = HttpService:JSONDecode(response)
    if not decoded or not decoded.choices or #decoded.choices == 0 then
        print("[ИИ] Пустой ответ от Groq.")
        return
    end

    local content = decoded.choices[1].message.content
    local actions = HttpService:JSONDecode(content)
    if not actions or type(actions) ~= "table" then
        print("[ИИ] Неверный формат ответа: " .. content)
        return
    end

    -- Выполнение действий
    isExecuting = true
    for _, action in ipairs(actions) do
        if not isExecuting then break end
        executeAction(action)
        wait(0.2)
    end
    isExecuting = false
    print("[ИИ] Все команды выполнены.")
end

-- ===== СОЗДАНИЕ GUI =====
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AIGui"
    screenGui.Parent = Player.PlayerGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 300)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -150)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Text = "🧠 ИИ-УПРАВЛЕНИЕ"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 18
    title.Parent = mainFrame

    -- Кнопка "Анализировать"
    local analyzeBtn = Instance.new("TextButton")
    analyzeBtn.Size = UDim2.new(0, 150, 0, 35)
    analyzeBtn.Position = UDim2.new(0.5, -75, 0, 40)
    analyzeBtn.Text = "🔍 АНАЛИЗИРОВАТЬ"
    analyzeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    analyzeBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    analyzeBtn.Font = Enum.Font.SourceSansBold
    analyzeBtn.TextSize = 14
    analyzeBtn.Parent = mainFrame
    analyzeBtn.MouseButton1Click:Connect(function()
        analyzeGame()
        analyzeBtn.Text = "✅ АНАЛИЗ ВЫПОЛНЕН"
        analyzeBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    end)

    -- Поле ввода команды
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(0, 300, 0, 30)
    inputBox.Position = UDim2.new(0.5, -150, 0, 90)
    inputBox.Text = "Напишите команду..."
    inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    inputBox.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    inputBox.Font = Enum.Font.SourceSans
    inputBox.TextSize = 14
    inputBox.ClearTextOnFocus = false
    inputBox.Parent = mainFrame

    -- Кнопка "Выполнить"
    local execBtn = Instance.new("TextButton")
    execBtn.Size = UDim2.new(0, 150, 0, 35)
    execBtn.Position = UDim2.new(0.5, -75, 0, 135)
    execBtn.Text = "⚡ ВЫПОЛНИТЬ"
    execBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    execBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    execBtn.Font = Enum.Font.SourceSansBold
    execBtn.TextSize = 14
    execBtn.Parent = mainFrame
    execBtn.MouseButton1Click:Connect(function()
        local cmd = inputBox.Text
        if cmd == "" or cmd == "Напишите команду..." then
            print("[ИИ] Введите команду.")
            return
        end
        if not isAnalyzed then
            print("[ИИ] Сначала проанализируйте игру.")
            return
        end
        execBtn.Text = "⏳ ВЫПОЛНЕНИЕ..."
        execBtn.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        processCommand(cmd)
        execBtn.Text = "⚡ ВЫПОЛНИТЬ"
        execBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end)

    -- Лог сообщений
    local logBox = Instance.new("TextBox")
    logBox.Size = UDim2.new(0, 300, 0, 60)
    logBox.Position = UDim2.new(0.5, -150, 0, 185)
    logBox.Text = "Ожидание команд..."
    logBox.TextColor3 = Color3.fromRGB(200, 200, 200)
    logBox.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    logBox.Font = Enum.Font.SourceSans
    logBox.TextSize = 12
    logBox.ClearTextOnFocus = false
    logBox.TextXAlignment = Enum.TextXAlignment.Left
    logBox.TextYAlignment = Enum.TextYAlignment.Top
    logBox.MultiLine = true
    logBox.Parent = mainFrame

    -- Обновление лога
    local oldPrint = print
    print = function(...)
        local msg = table.concat({...}, " ")
        logBox.Text = msg .. "\n" .. logBox.Text
        oldPrint(...)
    end
end

-- ===== ЗАПУСК =====
createGUI()
print("[ИИ] Скрипт загружен. Нажмите 'Анализировать' для сканирования игры.")
