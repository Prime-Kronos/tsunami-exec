-- ================================================================
-- ЖАДНЫЕ ПРОИЗВОДИТЕЛИ — АДМИН-КОМАНДЫ + ОБХОД КИКА + ЛОГ
-- ================================================================

local player = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- ===== ЛОГГЕР =====
local logMessages = {}
local function addLog(msg)
    local time = os.date("%H:%M:%S")
    table.insert(logMessages, "[" .. time .. "] " .. msg)
    print(msg)
end

-- ===== 1. БЛОКИРОВКА КИКА =====
local function blockKick()
    local origKick = player.Kick
    player.Kick = function(self, msg)
        addLog("🛑 Кик перехвачен: " .. (msg or "без причины"))
        return
    end
    -- Также перехватываем у всех игроков
    for _, plr in pairs(game.Players:GetPlayers()) do
        plr.Kick = function(self, msg)
            addLog("🛑 Кик игрока " .. plr.Name .. ": " .. (msg or ""))
        end
    end
    game.Players.PlayerAdded:Connect(function(plr)
        plr.Kick = function(self, msg)
            addLog("🛑 Кик нового игрока " .. plr.Name .. ": " .. (msg or ""))
        end
    end)
    addLog("✅ Кик заблокирован")
end

-- ===== 2. ПЕРЕХВАТ ПРОВЕРКИ ПРАВ =====
local function bypassAdminCheck()
    local function hookModule(obj)
        for _, child in pairs(obj:GetDescendants()) do
            if child:IsA("ModuleScript") then
                local success, mod = pcall(require, child)
                if success and type(mod) == "table" then
                    for k, v in pairs(mod) do
                        if type(v) == "function" and string.lower(k):find("admin") then
                            mod[k] = function(...) return true end
                            addLog("🔓 Перехвачена проверка: " .. k)
                        end
                    end
                end
            end
        end
    end
    hookModule(player)
    hookModule(RS)
    addLog("✅ Проверки админа перехвачены")
end

-- ===== 3. ОТПРАВКА АДМИН-КОМАНД С МАСКИРОВКОЙ =====
local function sendAdminCommand(cmd, ...)
    local args = {...}
    -- Маскируем команду под сбор
    local maskedCmd = "Collect"
    local maskedArgs = {cmd, table.unpack(args)}
    addLog("📤 Отправка: " .. cmd .. " (маскировка: " .. maskedCmd .. ")")
    for _, obj in pairs(RS:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            pcall(function()
                obj:FireServer(maskedCmd, maskedArgs)
            end)
        end
    end
end

-- ===== 4. ПОИСК СКРИПТОВ КИКА =====
local function findKickScripts()
    local found = {}
    local function search(obj)
        for _, child in pairs(obj:GetChildren()) do
            if child:IsA("Script") or child:IsA("LocalScript") or child:IsA("ModuleScript") then
                local success, src = pcall(function() return child.Source end)
                if success and src and string.find(src:lower(), "kick") then
                    table.insert(found, child:GetFullName())
                    addLog("📄 Найден скрипт с киком: " .. child:GetFullName())
                end
            end
            search(child)
        end
    end
    search(game)
    return found
end

-- ===== 5. GUI С АДМИН-КНОПКАМИ И ЛОГОМ =====
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AdminPanel"
    screenGui.Parent = player.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 500, 0, 550)
    frame.Position = UDim2.new(0.5, -250, 0.5, -275)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 45)
    title.Text = "👑 АДМИН-ПАНЕЛЬ"
    title.TextColor3 = Color3.fromRGB(255, 215, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 22
    title.Parent = frame

    -- Лог-консоль
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -20, 0, 280)
    scroll.Position = UDim2.new(0, 10, 0, 55)
    scroll.BackgroundColor3 = Color3.fromRGB(5, 5, 15)
    scroll.BackgroundTransparency = 0.3
    scroll.BorderSizePixel = 0
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollBarThickness = 6
    scroll.Parent = frame

    local logLabel = Instance.new("TextLabel")
    logLabel.Size = UDim2.new(1, 0, 1, 0)
    logLabel.Text = "Ожидание действий...\n"
    logLabel.TextColor3 = Color3.fromRGB(200, 210, 230)
    logLabel.BackgroundTransparency = 1
    logLabel.TextXAlignment = Enum.TextXAlignment.Left
    logLabel.TextYAlignment = Enum.TextYAlignment.Top
    logLabel.TextSize = 13
    logLabel.Font = Enum.Font.SourceSans
    logLabel.Parent = scroll

    -- Кнопки админ-команд
    local function createBtn(text, x, y, callback, color)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 140, 0, 40)
        btn.Position = UDim2.new(0, x, 0, y)
        btn.Text = text
        btn.BackgroundColor3 = color or Color3.fromRGB(0, 120, 215)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 15
        btn.Parent = frame
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    createBtn("💰 ДЕНЬГИ (999M)", 20, 350, function()
        sendAdminCommand("AddMoney", 999999999)
        addLog("💸 Запрос на 999M")
    end)

    createBtn("🌱 ВСЕ СЕМЕНА", 180, 350, function()
        sendAdminCommand("GiveAllSeeds")
        addLog("🌱 Все семена выданы")
    end)

    createBtn("🚀 МАКС. УРОВЕНЬ", 340, 350, function()
        sendAdminCommand("SetLevel", 9999)
        addLog("🚀 Уровень установлен")
    end)

    -- Кнопка поиска скриптов кика
    createBtn("🔍 НАЙТИ КИК", 20, 400, function()
        addLog("🔍 Поиск скриптов с киком...")
        local scripts = findKickScripts()
        if #scripts > 0 then
            addLog("🔍 Найдено: " .. #scripts)
            for _, name in pairs(scripts) do
                addLog("   📄 " .. name)
            end
        else
            addLog("❌ Скрипты с киком не найдены")
        end
    end, Color3.fromRGB(200, 150, 0))

    -- Кнопка копирования
    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0, 150, 0, 40)
    copyBtn.Position = UDim2.new(0.5, -160, 0, 460)
    copyBtn.Text = "📋 КОПИРОВАТЬ"
    copyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyBtn.Font = Enum.Font.SourceSansBold
    copyBtn.TextSize = 15
    copyBtn.Parent = frame

    -- Кнопка очистки
    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0, 120, 0, 40)
    clearBtn.Position = UDim2.new(0.5, 10, 0, 460)
    clearBtn.Text = "🧹 ОЧИСТИТЬ"
    clearBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearBtn.Font = Enum.Font.SourceSansBold
    clearBtn.TextSize = 15
    clearBtn.Parent = frame

    -- Кнопка закрыть
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 50, 0, 30)
    closeBtn.Position = UDim2.new(1, -60, 0, 5)
    closeBtn.Text = "✕"
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.TextSize = 16
    closeBtn.Parent = frame

    -- Обновление лога
    local function updateLog()
        logLabel.Text = table.concat(logMessages, "\n")
        scroll.CanvasSize = UDim2.new(0, 0, 0, logLabel.TextBounds.Y + 10)
        scroll.CanvasPosition = Vector2.new(0, logLabel.TextBounds.Y)
    end

    local origAdd = addLog
    addLog = function(msg)
        origAdd(msg)
        updateLog()
    end

    copyBtn.MouseButton1Click:Connect(function()
        local fullLog = table.concat(logMessages, "\n")
        if setclipboard then
            setclipboard(fullLog)
            addLog("📋 Лог скопирован")
        else
            addLog("❌ setclipboard недоступен")
        end
    end)

    clearBtn.MouseButton1Click:Connect(function()
        logMessages = {}
        logLabel.Text = "Лог очищен.\n"
        scroll.CanvasPosition = Vector2.new(0, 0)
        addLog("🧹 Лог очищен")
    end)

    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    addLog("✅ GUI создан")
end

-- ===== ЗАПУСК =====
addLog("🚀 Запуск админ-панели...")
pcall(blockKick)
pcall(bypassAdminCheck)
pcall(createGUI)

-- Автоматический фоновый спам (без админ-команд, чтобы не перегружать)
task.spawn(function()
    while task.wait(3) do
        pcall(function()
            for _, obj in pairs(RS:GetDescendants()) do
                if obj:IsA("RemoteEvent") then
                    pcall(function()
                        obj:FireServer("Collect", 999999)
                    end)
                end
            end
        end)
    end
end)

addLog("✅ Админ-панель активна! Используй кнопки.")
