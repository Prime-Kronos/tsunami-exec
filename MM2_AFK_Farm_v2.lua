-- ╔═══════════════════════════════════╗
-- ║   MM2 AFK FARM v2 | @Primejtsu   ║
-- ╚═══════════════════════════════════╝

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LP         = Players.LocalPlayer
local Camera     = workspace.CurrentCamera

-- ══ СОСТОЯНИЕ ══
local ACTIVE = false  -- скрипт выключен по умолчанию, жми START

-- ══ ANTI AFK ══
pcall(function()
    local vu = game:GetService("VirtualUser")
    LP.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), Camera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), Camera.CFrame)
    end)
end)

-- ══ HELPERS ══
local function getHRP()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c = LP.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

-- ══ GOD MODE ══
RunService.Heartbeat:Connect(function()
    if not ACTIVE then return end
    local h = getHum()
    if h then h.MaxHealth = math.huge h.Health = math.huge end
end)

-- ══ NOCLIP ══
RunService.Stepped:Connect(function()
    if not ACTIVE then return end
    local c = LP.Character if not c then return end
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
end)

-- ══ ПОЛЁТ ══
local function setupFly(char)
    task.wait(0.8)
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if not hrp then return end

    -- Удаляем старые если есть
    for _, v in ipairs(hrp:GetChildren()) do
        if v.Name == "AFKFlyBV" or v.Name == "AFKFlyBG" then v:Destroy() end
    end

    local bv = Instance.new("BodyVelocity", hrp)
    bv.Name = "AFKFlyBV"
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(0, 1e5, 0)
    bv.P = 1e4

    -- Поднять вверх
    hrp.CFrame = hrp.CFrame + Vector3.new(0, 40, 0)
end

LP.CharacterAdded:Connect(function(char)
    if ACTIVE then setupFly(char) end
end)

-- ══ ФИКС ТЕЛЕПОРТА К МОНЕТАМ ══
-- Проблема была: монеты ищем неправильно + телепорт слишком быстрый
-- Теперь: ищем ВСЕ BasePart с нужными именами + задержка между ТП

local coinNames = {
    Coin       = true,
    DropCoin   = true,
    GoldCoin   = true,
    SilverCoin = true,
    coin       = true,
    ["Coin"]   = true,
}

local function findAllCoins()
    local coins = {}
    -- Ищем в workspace и всех папках
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("UnionOperation") then
            if coinNames[obj.Name] then
                table.insert(coins, obj)
            end
        end
    end
    return coins
end

local lastTP = 0
local coinIndex = 1

RunService.Heartbeat:Connect(function()
    if not ACTIVE then return end
    -- Телепорт каждые 0.5 секунды (не слишком быстро — anti-ban)
    if tick() - lastTP < 0.5 then return end
    lastTP = tick()

    local hrp = getHRP()
    if not hrp then return end

    local coins = findAllCoins()

    if #coins == 0 then return end

    -- Перебираем монеты по очереди (не рандомно — надёжнее)
    if coinIndex > #coins then coinIndex = 1 end
    local target = coins[coinIndex]
    coinIndex = coinIndex + 1

    if target and target.Parent then
        -- Телепортируемся ТОЧНО на монету
        hrp.CFrame = CFrame.new(
            target.Position.X,
            target.Position.Y + 2,  -- чуть выше чтобы точно подобрать
            target.Position.Z
        )
    end
end)

-- ══ АВТО КНОПКИ ПОСЛЕ РАУНДА ══
RunService.Heartbeat:Connect(function()
    if not ACTIVE then return end
    pcall(function()
        for _, g in ipairs(LP.PlayerGui:GetDescendants()) do
            if g:IsA("TextButton") then
                local t = g.Text:lower()
                if t:find("play") or t:find("vote") or t:find("again")
                or t:find("ok") or t:find("continue") or t:find("skip")
                or t:find("ready") then
                    g.MouseButton1Click:Fire()
                end
            end
        end
    end)
end)

-- ══ RESPAWN SETUP ══
LP.CharacterAdded:Connect(function(char)
    if not ACTIVE then return end
    task.wait(1)
    setupFly(char)
end)

-- ════════════════════════════════
--          МИНИ GUI
-- ════════════════════════════════
if game.CoreGui:FindFirstChild("AFKFarmGUI") then
    game.CoreGui.AFKFarmGUI:Destroy()
end

local sg = Instance.new("ScreenGui", game.CoreGui)
sg.Name = "AFKFarmGUI"
sg.ResetOnSpawn = false

-- Главный фрейм (маленький, сбоку)
local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 160, 0, 195)
Main.Position = UDim2.new(0, 10, 0.5, -97)
Main.BackgroundColor3 = Color3.fromRGB(13, 17, 23)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(0, 201, 167)

-- Заголовок
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 32)
Title.BackgroundColor3 = Color3.fromRGB(17, 24, 32)
Title.BorderSizePixel = 0
Title.Text = "🌊 AFK Farm"
Title.TextColor3 = Color3.fromRGB(0, 201, 167)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)
-- фикс нижних углов заголовка
local tf = Instance.new("Frame", Title)
tf.Size = UDim2.new(1,0,0.5,0) tf.Position = UDim2.new(0,0,0.5,0)
tf.BackgroundColor3 = Color3.fromRGB(17,24,32) tf.BorderSizePixel = 0

-- Статус
local Status = Instance.new("TextLabel", Main)
Status.Size = UDim2.new(1, -10, 0, 18)
Status.Position = UDim2.new(0, 5, 0, 36)
Status.BackgroundTransparency = 1
Status.Text = "⭕ ВЫКЛЮЧЕН"
Status.TextColor3 = Color3.fromRGB(220, 50, 50)
Status.Font = Enum.Font.GothamBold
Status.TextSize = 11

-- Иконки статуса фич
local function mkStatus(parent, yPos, icon, label)
    local f = Instance.new("TextLabel", parent)
    f.Size = UDim2.new(1, -10, 0, 14)
    f.Position = UDim2.new(0, 8, 0, yPos)
    f.BackgroundTransparency = 1
    f.Text = icon .. " " .. label
    f.TextColor3 = Color3.fromRGB(70, 90, 110)
    f.Font = Enum.Font.Code
    f.TextSize = 10
    f.TextXAlignment = Enum.TextXAlignment.Left
    return f
end

local s1 = mkStatus(Main, 58,  "🛡", "God Mode")
local s2 = mkStatus(Main, 74,  "🕊", "Полёт")
local s3 = mkStatus(Main, 90,  "💰", "Монеты")
local s4 = mkStatus(Main, 106, "🔒", "Anti-AFK")

local TEAL = Color3.fromRGB(0, 201, 167)
local RED  = Color3.fromRGB(220, 50, 50)
local DIM  = Color3.fromRGB(70, 90, 110)

local function setActive(state)
    ACTIVE = state

    if state then
        Status.Text = "✅ АКТИВЕН"
        Status.TextColor3 = TEAL
        for _, s in ipairs({s1,s2,s3,s4}) do
            s.TextColor3 = TEAL
        end
        -- Включаем полёт
        if LP.Character then
            task.spawn(function() setupFly(LP.Character) end)
        end
    else
        Status.Text = "⭕ ВЫКЛЮЧЕН"
        Status.TextColor3 = RED
        for _, s in ipairs({s1,s2,s3,s4}) do
            s.TextColor3 = DIM
        end
        -- Выключаем полёт
        pcall(function()
            local c = LP.Character if not c then return end
            local hrp = c:FindFirstChild("HumanoidRootPart") if not hrp then return end
            for _, v in ipairs(hrp:GetChildren()) do
                if v.Name == "AFKFlyBV" then v:Destroy() end
            end
            local h = c:FindFirstChildOfClass("Humanoid")
            if h then h.MaxHealth = 100 h.Health = 100 end
        end)
    end
end

-- Кнопка START
local StartBtn = Instance.new("TextButton", Main)
StartBtn.Size = UDim2.new(1, -16, 0, 28)
StartBtn.Position = UDim2.new(0, 8, 0, 126)
StartBtn.BackgroundColor3 = TEAL
StartBtn.Text = "▶  СТАРТ"
StartBtn.TextColor3 = Color3.new(1,1,1)
StartBtn.Font = Enum.Font.GothamBold
StartBtn.TextSize = 12
StartBtn.BorderSizePixel = 0
Instance.new("UICorner", StartBtn).CornerRadius = UDim.new(0, 7)

StartBtn.MouseButton1Click:Connect(function()
    setActive(true)
    TweenService:Create(StartBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(0, 160, 130)
    }):Play()
end)

-- Кнопка СТОП
local StopBtn = Instance.new("TextButton", Main)
StopBtn.Size = UDim2.new(1, -16, 0, 28)
StopBtn.Position = UDim2.new(0, 8, 0, 158)
StopBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
StopBtn.Text = "⏹  СТОП"
StopBtn.TextColor3 = RED
StopBtn.Font = Enum.Font.GothamBold
StopBtn.TextSize = 12
StopBtn.BorderSizePixel = 0
Instance.new("UIStroke", StopBtn).Color = RED
Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0, 7)

StopBtn.MouseButton1Click:Connect(function()
    setActive(false)
    TweenService:Create(StartBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = TEAL
    }):Play()
end)

-- Счётчик монет
local coinCount = 0
local CoinCounter = Instance.new("TextLabel", Main)
CoinCounter.Size = UDim2.new(1, -10, 0, 14)
CoinCounter.Position = UDim2.new(0, 5, 0, 88)  -- под монеты
CoinCounter.BackgroundTransparency = 1
CoinCounter.Text = ""
CoinCounter.TextColor3 = Color3.fromRGB(243, 156, 18)
CoinCounter.Font = Enum.Font.Code
CoinCounter.TextSize = 9

-- Считаем монеты через touch
local function trackCoins()
    local c = LP.Character if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart") if not hrp then return end
    hrp.Touched:Connect(function(hit)
        if coinNames[hit.Name] then
            coinCount = coinCount + 1
            s3.Text = "💰 Монеты: " .. coinCount
        end
    end)
end

LP.CharacterAdded:Connect(function(char)
    task.wait(1)
    trackCoins()
end)
if LP.Character then trackCoins() end

print("[MM2 AFK Farm v2] GUI готов | Нажми СТАРТ | @Primejtsu")
