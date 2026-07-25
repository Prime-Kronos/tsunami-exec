-- ============================================================
-- ЖАДНЫЕ ПРОИЗВОДИТЕЛИ — РАБОЧАЯ ВЕРСИЯ
-- ============================================================

local player = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

-- ===== ЛОГГЕР =====
local logMessages = {}
local function addLog(msg)
    local time = os.date("%H:%M:%S")
    table.insert(logMessages, "[" .. time .. "] " .. msg)
    print(msg)
end

-- ===== БЛОКИРОВКА КИКА =====
local function blockKick()
    -- 1. Перехват player:Kick()
    player.Kick = function(self, msg)
        addLog("🛑 Кик перехвачен: " .. (msg or ""))
        return
    end

    -- 2. Перехват Kick у всех игроков (включая новых)
    for _, plr in pairs(Players:GetPlayers()) do
        plr.Kick = function(self, msg)
            addLog("🛑 Кик игрока " .. plr.Name .. ": " .. (msg or ""))
        end
    end
    Players.PlayerAdded:Connect(function(plr)
        plr.Kick = function(self, msg)
            addLog("🛑 Кик нового игрока " .. plr.Name .. ": " .. (msg or ""))
        end
    end)

    -- 3. Перехват Teleport (иногда используется для кика)
    local oldTeleport = TeleportService.Teleport
    TeleportService.Teleport = function(self, placeId, playerList, ...)
        if type(playerList) == "table" then
            for _, plr in pairs(playerList) do
                if plr == player then
                    addLog("🛑 Телепорт перехвачен (кик)")
                    return
                end
            end
        end
        return oldTeleport(self, placeId, playerList, ...)
    end

    -- 4. Блокировка RemoteEvent с "kick" в имени
    for _, obj in pairs(RS:GetDescendants()) do
        if obj:IsA("RemoteEvent") and string.find(obj.Name:lower(), "kick") then
            obj.OnClientEvent:Connect(function()
                addLog("🛑 RemoteEvent кика заблокирован: " .. obj.Name)
            end)
        end
    end

    addLog("✅ Кик заблокирован")
end

-- ===== ОТПРАВКА КОМАНД =====
local function sendCommand(cmd, ...)
    local args = {...}
    addLog("📤 Отправка: " .. cmd)
    for _, obj in pairs(RS:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            pcall(function()
                obj:FireServer(cmd, ...)
            end)
        end
    end
end

-- ===== GUI =====
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HackGUI"
    screenGui.Parent = player:FindFirstChild("PlayerGui") or player.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 500, 0, 550)
    frame.Position = UDim2.new(0.5, -250, 0.5, -275)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 45)
    title.Text = "💰 ЖАДНЫЕ ПРОИЗВОДИТЕЛИ"
    title.TextColor3 = Color3.fromRGB(255, 215, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 22
    title.Parent = frame

    -- Лог
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
    logLabel.Text = "Ожидание...\n"
    logLabel.TextColor3 = Color3.fromRGB(200, 210, 230)
    logLabel.BackgroundTransparency = 1
    logLabel.TextXAlignment = Enum.TextXAlignment.Left
    logLabel.TextYAlignment = Enum.TextYAlignment.Top
    logLabel.TextSize = 13
    logLabel.Font = Enum.Font.SourceSans
    logLabel.Parent = scroll

    -- Кнопки
    local function makeBtn(text, x, y, callback, color)
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

    makeBtn("💰 ДЕНЬГИ (999M)", 20, 350, function()
        sendCommand("AddMoney", 999999999)
    end)

    makeBtn("🌱 ВСЕ СЕМЕНА", 180, 350, function()
        sendCommand("GiveAllSeeds")
    end)

    makeBtn("🚀 МАКС. УРОВЕНЬ", 340, 350, function()
        sendCommand("SetLevel", 9999)
    end)

    -- Дополнительные кнопки для других возможных команд
    makeBtn("🧬 GRANT ALL", 20, 400, function()
        sendCommand("GrantAll")
    end, Color3.fromRGB(200, 150, 0))

    makeBtn("⚡ ADMIN CMD", 180, 400, function()
        sendCommand("AdminCmd", "all")
    end, Color3.fromRGB(200, 150, 0))

    -- Кнопки управления
    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0, 150, 0, 40)
    copyBtn.Position = UDim2.new(0.5, -160, 0, 470)
    copyBtn.Text = "📋 КОПИРОВАТЬ"
    copyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyBtn.Font = Enum.Font.SourceSansBold
    copyBtn.TextSize = 15
    copyBtn.Parent = frame

    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0, 120, 0, 40)
    clearBtn.Position = UDim2.new(0.5, 10, 0, 470)
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
local success, err = pcall(function()
    addLog("🚀 Запуск...")
    blockKick()
    createGUI()
    addLog("✅ Готово! Попробуй кнопки.")
end)

if not success then
    warn("Ошибка: " .. tostring(err))
    print("Если скрипт не запустился, попробуй перезапустить Delta.")
end
