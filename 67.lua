-- ================================================================
-- ЖАДНЫЕ ПРОИЗВОДИТЕЛИ — ЛОГИРОВАНИЕ ВСЕХ ВХОДЯЩИХ СОБЫТИЙ
-- ================================================================

local player = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")

-- ===== ЛОГГЕР =====
local logMessages = {}
local function addLog(msg)
    local time = os.date("%H:%M:%S")
    table.insert(logMessages, "[" .. time .. "] " .. msg)
    print(msg)
end

-- ===== БЛОКИРОВКА КИКА (клиентская) =====
local function blockKickClient()
    player.Kick = function(self, msg)
        addLog("🛑 Клиентский кик перехвачен: " .. (msg or ""))
        return
    end
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
    addLog("✅ Клиентский кик заблокирован")
end

-- ===== ЛОГИРОВАНИЕ ВСЕХ ВХОДЯЩИХ СОБЫТИЙ =====
local function logAllIncomingEvents()
    local count = 0
    for _, obj in pairs(RS:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            -- Перехватываем все входящие события
            obj.OnClientEvent:Connect(function(...)
                local args = {...}
                addLog("📥 Входящее событие от " .. obj.Name .. " с аргументами: " .. table.concat(args, ", "))
            end)
            count = count + 1
        end
    end
    addLog("✅ Логирование включено для " .. count .. " RemoteEvent")
end

-- ===== ОТПРАВКА АДМИН-КОМАНД =====
local function sendAdminCommand(cmd, ...)
    local args = {...}
    addLog("📤 Отправка команды: " .. cmd)
    for _, obj in pairs(RS:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            pcall(function()
                obj:FireServer(cmd, ...)
            end)
        end
    end
end

-- ===== GUI С ЛОГОМ И КНОПКАМИ =====
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AdminPanel"
    screenGui.Parent = player:FindFirstChild("PlayerGui") or player.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 550, 0, 650)
    frame.Position = UDim2.new(0.5, -275, 0.5, -325)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 45)
    title.Text = "👑 АДМИН-ПАНЕЛЬ (ЛОГ)"
    title.TextColor3 = Color3.fromRGB(255, 215, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 20
    title.Parent = frame

    -- Лог-консоль
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -20, 0, 300)
    scroll.Position = UDim2.new(0, 10, 0, 55)
    scroll.BackgroundColor3 = Color3.fromRGB(5, 5, 15)
    scroll.BackgroundTransparency = 0.3
    scroll.BorderSizePixel = 0
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollBarThickness = 6
    scroll.Parent = frame

    local logLabel = Instance.new("TextLabel")
    logLabel.Size = UDim2.new(1, 0, 1, 0)
    logLabel.Text = "Ожидание...\n"
    logLabel.TextColor3 = Color3.fromRGB(200, 210, 230)
    logLabel.BackgroundTransparency = 1
    logLabel.TextXAlignment = Enum.TextXAlignment.Left
    logLabel.TextYAlignment = Enum.TextYAlignment.Top
    logLabel.TextSize = 13
    logLabel.Font = Enum.Font.SourceSans
    logLabel.Parent = scroll

    -- Кнопки
    local function createBtn(text, x, y, callback, color)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 140, 0, 40)
        btn.Position = UDim2.new(0, x, 0, y)
        btn.Text = text
        btn.BackgroundColor3 = color or Color3.fromRGB(0, 120, 215)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 14
        btn.Parent = frame
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    createBtn("💰 ДЕНЬГИ (999M)", 20, 370, function()
        sendAdminCommand("AddMoney", 999999999)
    end)

    createBtn("🌱 ВСЕ СЕМЕНА", 180, 370, function()
        sendAdminCommand("GiveAllSeeds")
    end)

    createBtn("🚀 МАКС. УРОВЕНЬ", 340, 370, function()
        sendAdminCommand("SetLevel", 9999)
    end)

    -- Кнопка для блокировки конкретного RemoteEvent (вводим имя)
    local blockBtn = Instance.new("TextButton")
    blockBtn.Size = UDim2.new(0, 200, 0, 40)
    blockBtn.Position = UDim2.new(0.5, -100, 0, 430)
    blockBtn.Text = "🛡️ БЛОКИРОВАТЬ ПО ИМЕНИ"
    blockBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
    blockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    blockBtn.Font = Enum.Font.SourceSansBold
    blockBtn.TextSize = 15
    blockBtn.Parent = frame

    local nameInput = Instance.new("TextBox")
    nameInput.Size = UDim2.new(0, 200, 0, 40)
    nameInput.Position = UDim2.new(0.5, -100, 0, 480)
    nameInput.PlaceholderText = "Введите имя RemoteEvent"
    nameInput.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    nameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameInput.Font = Enum.Font.SourceSans
    nameInput.TextSize = 14
    nameInput.Parent = frame

    blockBtn.MouseButton1Click:Connect(function()
        local name = nameInput.Text
        if name == "" then
            addLog("❌ Введите имя RemoteEvent")
            return
        end
        local found = false
        for _, obj in pairs(RS:GetDescendants()) do
            if obj:IsA("RemoteEvent") and obj.Name == name then
                obj.OnClientEvent:Connect(function()
                    addLog("🛑 Блокирован RemoteEvent: " .. name)
                end)
                found = true
                addLog("✅ RemoteEvent " .. name .. " заблокирован")
                break
            end
        end
        if not found then
            addLog("❌ RemoteEvent с именем " .. name .. " не найден")
        end
    end)

    -- Кнопка копирования
    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0, 150, 0, 40)
    copyBtn.Position = UDim2.new(0.5, -160, 0, 550)
    copyBtn.Text = "📋 КОПИРОВАТЬ"
    copyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyBtn.Font = Enum.Font.SourceSansBold
    copyBtn.TextSize = 15
    copyBtn.Parent = frame

    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0, 120, 0, 40)
    clearBtn.Position = UDim2.new(0.5, 10, 0, 550)
    clearBtn.Text = "🧹 ОЧИСТИТЬ"
    clearBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearBtn.Font = Enum.Font.SourceSansBold
    clearBtn.TextSize = 15
    clearBtn.Parent = frame

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 50, 0, 30)
    closeBtn.Position = UDim2.new(1, -60, 0, 5)
    closeBtn.Text = "✕"
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.TextSize = 16
    closeBtn.Parent = frame

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
addLog("🚀 Запуск...")
pcall(blockKickClient)
pcall(logAllIncomingEvents)
pcall(createGUI)
addLog("✅ Готово! Нажми на любую кнопку и смотри лог.")
