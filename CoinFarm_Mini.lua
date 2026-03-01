-- CoinFarm | @Primejtsu | MM2 | 0.6s

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local LP           = Players.LocalPlayer

local farming  = false
local coinCount = 0

local function getHRP()
    local c = LP.Character return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c = LP.Character return c and c:FindFirstChildOfClass("Humanoid")
end

-- ══ ФАРМ МОНЕТ 0.6 СЕК ══
local function findNearestCoin()
    local hrp = getHRP() if not hrp then return nil, 0 end
    local nearest = nil local nearDist = math.huge
    for _, o in ipairs(workspace:GetDescendants()) do
        if o:IsA("BasePart") or o:IsA("MeshPart") or o:IsA("UnionOperation") then
            local n = o.Name:lower()
            if n:find("coin") or n == "dropcoin" or n == "goldcoin" or n == "silvercoin" then
                if o.Parent and o.Transparency < 1 then
                    local d = (hrp.Position - o.Position).Magnitude
                    if d < nearDist then nearDist = d nearest = o end
                end
            end
        end
    end
    return nearest, nearDist
end

task.spawn(function()
    while task.wait(0.6) do
        if not farming then continue end
        local hrp = getHRP()
        local hum = getHum()
        if not hrp or not hum then continue end

        local coin, dist = findNearestCoin()
        if not coin then continue end

        if dist > 3 then
            local dir   = (coin.Position - hrp.Position)
            local step  = math.min(dist - 1, 20)
            local tp    = hrp.Position + dir.Unit * step
            hrp.CFrame  = CFrame.new(tp.X, hrp.Position.Y, tp.Z)
            task.wait(0.05)
        end

        -- Прыжок чтобы подобрать
        hum.Jump = true
        task.wait(0.05)
        if coin.Parent == nil then
            coinCount = coinCount + 1
        end
    end
end)

-- ══ ANTI AFK ══
task.spawn(function()
    while task.wait(5) do
        pcall(function()
            local vu = game:GetService("VirtualUser")
            vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(0.05)
            vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
        pcall(function()
            local h = getHum() if h then h.Jump = true end
        end)
    end
end)

-- ══════════════════════════════
--         МИНИ GUI
-- ══════════════════════════════
if game.CoreGui:FindFirstChild("CoinFarmMini") then
    game.CoreGui.CoinFarmMini:Destroy()
end

local sg = Instance.new("ScreenGui", game.CoreGui)
sg.Name = "CoinFarmMini"
sg.ResetOnSpawn = false
sg.DisplayOrder = 999

local RED   = Color3.fromRGB(200, 30,  30)
local WHITE = Color3.fromRGB(220, 220, 220)
local BG    = Color3.fromRGB(14,  14,  14)
local CARD  = Color3.fromRGB(22,  22,  22)
local GREEN = Color3.fromRGB(0,   200, 100)
local MUTED = Color3.fromRGB(90,  90,  90)
local DIM   = Color3.fromRGB(40,  40,  40)

-- Мини окно 180×90
local W = Instance.new("Frame", sg)
W.Size     = UDim2.new(0, 180, 0, 90)
W.Position = UDim2.new(0.5, -90, 1, -110)
W.BackgroundColor3 = BG
W.BorderSizePixel  = 0
W.Active    = true
W.Draggable = true
Instance.new("UICorner", W).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", W).Color = Color3.fromRGB(35,35,35)

-- Анимация появления снизу
W.Position = UDim2.new(0.5,-90,1.2,0)
TweenService:Create(W, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    {Position = UDim2.new(0.5,-90,1,-110)}):Play()

-- Красная линия сверху
local topLine = Instance.new("Frame", W)
topLine.Size = UDim2.new(1,0,0,2)
topLine.BackgroundColor3 = RED
topLine.BorderSizePixel  = 0

-- Логотип Ᵽ + заголовок
local logoP = Instance.new("TextLabel", W)
logoP.Size = UDim2.new(0,18,0,22)
logoP.Position = UDim2.new(0,8,0,6)
logoP.BackgroundTransparency = 1
logoP.Text = "Ᵽ"
logoP.TextColor3 = RED
logoP.Font = Enum.Font.GothamBlack
logoP.TextSize = 18

local titleLbl = Instance.new("TextLabel", W)
titleLbl.Size = UDim2.new(1,-50,0,22)
titleLbl.Position = UDim2.new(0,26,0,6)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "Coin Farm"
titleLbl.TextColor3 = WHITE
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextSize = 13
titleLbl.TextXAlignment = Enum.TextXAlignment.Left

-- Счётчик монет
local coinLbl = Instance.new("TextLabel", W)
coinLbl.Size = UDim2.new(1,-16,0,18)
coinLbl.Position = UDim2.new(0,8,0,30)
coinLbl.BackgroundTransparency = 1
coinLbl.Text = "💰  0 монет"
coinLbl.TextColor3 = Color3.fromRGB(243,156,18)
coinLbl.Font = Enum.Font.GothamBold
coinLbl.TextSize = 12
coinLbl.TextXAlignment = Enum.TextXAlignment.Left

-- Статус
local statusLbl = Instance.new("TextLabel", W)
statusLbl.Size = UDim2.new(1,-16,0,14)
statusLbl.Position = UDim2.new(0,8,0,50)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "⏸  Остановлен"
statusLbl.TextColor3 = MUTED
statusLbl.Font = Enum.Font.Code
statusLbl.TextSize = 10
statusLbl.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопка START/STOP
local Btn = Instance.new("TextButton", W)
Btn.Size = UDim2.new(1,-16,0,22)
Btn.Position = UDim2.new(0,8,0,66)
Btn.BackgroundColor3 = DIM
Btn.Text = "▶  СТАРТ"
Btn.TextColor3 = WHITE
Btn.Font = Enum.Font.GothamBold
Btn.TextSize = 11
Btn.BorderSizePixel = 0
Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,6)

-- Кнопка X
local xBtn = Instance.new("TextButton", W)
xBtn.Size = UDim2.new(0,18,0,18)
xBtn.Position = UDim2.new(1,-22,0,5)
xBtn.BackgroundColor3 = RED
xBtn.Text = "✕"
xBtn.TextColor3 = WHITE
xBtn.Font = Enum.Font.GothamBold
xBtn.TextSize = 9
xBtn.BorderSizePixel = 0
Instance.new("UICorner", xBtn).CornerRadius = UDim.new(0,5)
xBtn.MouseButton1Click:Connect(function()
    farming = false
    TweenService:Create(W, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
        {Position = UDim2.new(0.5,-90,1.2,0)}):Play()
    task.wait(0.35)
    sg:Destroy()
end)

-- Обновление UI
RunService.Heartbeat:Connect(function()
    if not W.Parent then return end
    coinLbl.Text = "💰  " .. tostring(coinCount) .. " монет"
    if farming then
        statusLbl.Text = "▶  Фарм активен • 0.6s"
        statusLbl.TextColor3 = GREEN
    else
        statusLbl.Text = "⏸  Остановлен"
        statusLbl.TextColor3 = MUTED
    end
end)

-- Кнопка старт/стоп
Btn.MouseButton1Click:Connect(function()
    farming = not farming
    if farming then
        TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = RED}):Play()
        Btn.Text = "⏹  СТОП"
        -- Пульсация кнопки пока работает
        task.spawn(function()
            while farming do
                TweenService:Create(Btn, TweenInfo.new(0.5), {BackgroundColor3 = Color3.fromRGB(160,20,20)}):Play()
                task.wait(0.5)
                TweenService:Create(Btn, TweenInfo.new(0.5), {BackgroundColor3 = RED}):Play()
                task.wait(0.5)
            end
            TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = DIM}):Play()
            Btn.Text = "▶  СТАРТ"
        end)
    else
        TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = DIM}):Play()
        Btn.Text = "▶  СТАРТ"
    end
end)

-- Уведомление
task.wait(0.5)
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "💰 Coin Farm",
        Text  = "Нажми СТАРТ | @Primejtsu",
        Duration = 3
    })
end)

print("[CoinFarm] @Primejtsu | 0.6s | Нажми СТАРТ")
