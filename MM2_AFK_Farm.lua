-- ╔═══════════════════════════════════╗
-- ║   MM2 AFK FARM | by Primejtsu    ║
-- ║   Telegram: @Primejtsu           ║
-- ╚═══════════════════════════════════╝
-- Летает | Бессмертный | Фарм монет | АФК

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ══ ANTI AFK ══
pcall(function()
    local vu = game:GetService("VirtualUser")
    LP.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), Camera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), Camera.CFrame)
    end)
end)

-- ══ ФУНКЦИИ ══
local function getChar()
    return LP.Character
end

local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

-- ── БОГ МОД (бессмертный) ──
RunService.Heartbeat:Connect(function()
    local hum = getHum()
    if hum then
        hum.MaxHealth = math.huge
        hum.Health    = math.huge
    end
end)

-- ── ПОЛЁТ ──
-- Поднимаем персонажа вверх и держим в воздухе
local flying = false
local flyHeight = 50  -- высота полёта над землёй

local function enableFly()
    local hrp = getHRP()
    if not hrp then return end

    -- Поднять вверх
    hrp.CFrame = hrp.CFrame + Vector3.new(0, flyHeight, 0)

    -- Убрать гравитацию
    local bg = Instance.new("BodyGyro", hrp)
    bg.MaxTorque = Vector3.new(0, 0, 0)
    bg.P = 0

    local bv = Instance.new("BodyVelocity", hrp)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(0, 1e9, 0)  -- держим по Y
    bv.Name = "FlyVelocity"

    flying = true
end

-- Применяем полёт после респауна тоже
local function setupFly(char)
    task.wait(1)
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if not hrp then return end

    hrp.CFrame = hrp.CFrame + Vector3.new(0, flyHeight, 0)

    local bv = Instance.new("BodyVelocity", hrp)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(0, 1e9, 0)
    bv.Name = "FlyVelocity"

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = false
    end
end

LP.CharacterAdded:Connect(setupFly)
if LP.Character then
    task.spawn(function() setupFly(LP.Character) end)
end

-- ── СБОР МОНЕТ ──
-- Каждые 0.3 сек телепортируемся к монетам
local lastCoin = 0
RunService.Heartbeat:Connect(function()
    if tick() - lastCoin < 0.3 then return end
    lastCoin = tick()

    local hrp = getHRP()
    if not hrp then return end

    -- Ищем ближайшую монету
    local nearest = nil
    local nearDist = math.huge

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and
           (obj.Name == "Coin" or obj.Name == "DropCoin" or
            obj.Name == "GoldCoin" or obj.Name == "SilverCoin") then
            local dist = (hrp.Position - obj.Position).Magnitude
            if dist < nearDist then
                nearDist = dist
                nearest = obj
            end
        end
    end

    -- ТП к монете
    if nearest and nearDist < 200 then
        hrp.CFrame = CFrame.new(nearest.Position + Vector3.new(0, 3, 0))
        task.wait(0.05)
    end
end)

-- ── АВТО ПЕРЕЗАПУСК ПОСЛЕ РАУНДА ──
-- Когда раунд кончился — жмём кнопку Play Again / Vote
RunService.Heartbeat:Connect(function()
    pcall(function()
        local pg = LP.PlayerGui
        for _, gui in ipairs(pg:GetDescendants()) do
            if gui:IsA("TextButton") then
                local t = gui.Text:lower()
                if t:find("play") or t:find("vote") or
                   t:find("again") or t:find("ok") or
                   t:find("continue") or t:find("skip") then
                    gui.MouseButton1Click:Fire()
                end
            end
        end
    end)
end)

-- ── NOCLIP (чтобы монеты не мешали) ──
RunService.Stepped:Connect(function()
    local c = getChar()
    if not c then return end
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then
            p.CanCollide = false
        end
    end
end)

-- ── УВЕДОМЛЕНИЕ ──
local function notify(title, text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text  = text,
            Duration = 5,
        })
    end)
end

task.wait(2)
notify("MM2 AFK Farm", "✅ Запущен! Летаешь + бессмертный + фарм монет")
print("╔══════════════════════════════╗")
print("║  MM2 AFK FARM | @Primejtsu  ║")
print("║  ✅ Бессмертный — АКТИВЕН   ║")
print("║  ✅ Полёт — АКТИВЕН         ║")
print("║  ✅ Фарм монет — АКТИВЕН    ║")
print("║  ✅ Анти-АФК — АКТИВЕН      ║")
print("╚══════════════════════════════╝")
