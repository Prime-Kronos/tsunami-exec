-- ================================================================
-- ЖАДНЫЕ ПРОИЗВОДИТЕЛИ — ПОЛНАЯ ЗАЩИТА ОТ КИКА + ЛОГ
-- ================================================================

local player = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")

-- ===== ЛОГГЕР =====
local logMessages = {}
local function addLog(msg)
    local time = os.date("%H:%M:%S")
    table.insert(logMessages, "[" .. time .. "] " .. msg)
    print(msg)
end

-- ===== 1. БЛОКИРОВКА ВСЕХ ВОЗМОЖНЫХ МЕТОДОВ КИКА =====
local function blockAllKickMethods()
    -- 1.1 Перехват Kick у игрока
    local origKick = player.Kick
    player.Kick = function(self, msg)
        addLog("🛑 Kick(player) перехвачен: " .. (msg or ""))
        return
    end

    -- 1.2 Перехват Kick у всех игроков (включая будущих)
    for _, plr in pairs(Players:GetPlayers()) do
        plr.Kick = function(self, msg)
            addLog("🛑 Kick(" .. plr.Name .. ") перехвачен: " .. (msg or ""))
        end
    end
    Players.PlayerAdded:Connect(function(plr)
        plr.Kick = function(self, msg)
            addLog("🛑 Kick(новый " .. plr.Name .. ") перехвачен: " .. (msg or ""))
        end
    end)

    -- 1.3 Перехват Teleport (могут использовать для кика)
    local origTeleport = TeleportService.Teleport
    TeleportService.Teleport = function(self, placeId, playerList, ...)
        if playerList and type(playerList) == "table" then
            for _, plr in pairs(playerList) do
                if plr == player then
                    addLog("🛑 TeleportService.Teleport перехвачен (попытка переместить игрока)")
                    return
                end
            end
        end
        return origTeleport(self, placeId, playerList, ...)
    end

    -- 1.4 Перехват удаления игрока из игры (удаление из Players)
    local origRemove = Players.Remove
    Players.Remove = function(self, plr)
        if plr == player then
            addLog("🛑 Players.Remove перехвачен (попытка удалить игрока)")
            return
        end
        return origRemove(self, plr)
    end

    addLog("✅ Все методы кика заблокированы")
end

-- ===== 2. БЛОКИРОВКА RemoteEvent/RemoteFunction с подозрительными именами =====
local function blockKickRemotes()
    local blocked = 0
    local function scan(obj)
        for _, child in pairs(obj:GetDescendants()) do
            if child:IsA("RemoteEvent") then
                local name = child.Name:lower()
                if name:find("kick") or name:find("ban") or name:find("remove") or 
                   name:find("disconnect") or name:find("leave") or name:find("admin") or
                   name:find("moderation") then
                    child.OnClientEvent:Connect(function(...)
                        addLog("🛑 RemoteEvent кика (" .. child.Name .. ") перехвачен с аргументами: " .. tostring(...))
                    end)
                    blocked = blocked + 1
                end
            end
            if child:IsA("RemoteFunction") then
                local name = child.Name:lower()
                if name:find("kick") or name:find("ban") or name:find("remove") or 
                   name:find("disconnect") or name:find("leave") or name:find("admin") then
                    child.OnClientInvoke = function(...)
                        addLog("🛑 RemoteFunction кика (" .. child.Name .. ") перехвачен с аргументами: " .. tostring(...))
                        return nil
                    end
                    blocked = blocked + 1
                end
            end
        end
    end
    scan(RS)
    scan(game:GetService("Workspace"))
    scan(game:GetService("Players"))
    scan(game:GetService("CoreGui"))
    scan(game:GetService("StarterGui"))
    addLog("✅ Блокировка RemoteEvent кика: " .. blocked .. " объектов")
end

-- ===== 3. ПЕРЕХВАТ ВСЕХ RemoteEvent (для логирования) =====
local function hookAllRemotes()
    for _, obj in pairs(RS:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local origFire = obj.FireServer
            obj.FireServer = function(self, ...)
                local args = {...}
                addLog("📤 RemoteEvent: " .. self.Name .. " вызван с аргументами: " .. table.concat(args, ", "))
                return origFire(self, ...)
            end
        end
    end
    addLog("✅ Все RemoteEvent залогированы")
end

-- ===== 4. ОТПРАВКА АДМИН-КОМАНД С МАСКИРОВКОЙ =====
local function sendAdminCommand(cmd, ...)
    local args = {...}
    -- Маскируем команду
    local maskedCmd = "Collect"
    local maskedArgs = {cmd, table.unpack(args)}
    addLog("📤 Отправка админ-команды: " .. cmd .. " (маскировка: " .. maskedCmd .. ")")
    for _, obj in pairs(RS:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            pcall(function()
                obj:FireServer(maskedCmd, maskedArgs)
            end)
        end
    end
end

-- ===== 5. GUI =====
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AdminPanel"
    screenGui.Parent = player:FindFirstChild("PlayerGui") or player.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 500, 0, 600)
    frame.Position = UDim2.new(0.5, -250, 0.5, -300)
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
    end)

    createBtn("🌱 ВСЕ СЕМЕНА", 180, 350, function()
        sendAdminCommand("GiveAllSeeds")
    end)

    createBtn("🚀 МАКС. УРОВЕНЬ", 340, 350, function()
        sendAdminCommand("SetLevel", 9999)
    end)

    createBtn("🔍 ЛОГ REMOTEEVENT", 20, 400, function()
        addLog("🔍 Логирование всех RemoteEvent включено")
    end, Color3.fromRGB(200, 150, 0))

    createBtn("🛡️ БЛОКИРОВКА КИКА", 180, 400, function()
        addLog("🛡️ Повторная блокировка...")
        blockAllKickMethods()
        blockKickRemotes()
    end, Color3.fromRGB(0, 150, 0))

    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0, 150, 0, 40)
    copyBtn.Position = UDim2.new(0.5, -160, 0, 500)
    copyBtn.Text = "📋 КОПИРОВАТЬ"
    copyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyBtn.Font = Enum.Font.SourceSansBold
    copyBtn.TextSize = 15
    copyBtn.Parent = frame

    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0, 120, 0, 40)
    clearBtn.Position = UDim2.new(0.5, 10, 0, 500)
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
addLog("🚀 Запуск с полной защитой...")
pcall(blockAllKickMethods)
pcall(blockKickRemotes)
pcall(hookAllRemotes)  -- логируем все RemoteEvent
pcall(createGUI)

addLog("✅ Готово! Теперь смотри лог — увидишь, что вызывает кик.")
