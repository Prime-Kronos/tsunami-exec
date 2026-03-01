-- ╔═══════════════════════════════════╗
-- ║   MM2 AFK FARM v3 | @Primejtsu   ║
-- ╚═══════════════════════════════════╝

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LP           = Players.LocalPlayer
local Camera       = workspace.CurrentCamera

local ACTIVE = false

-- ══ ANTI AFK ══
pcall(function()
    local vu = game:GetService("VirtualUser")
    LP.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), Camera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), Camera.CFrame)
    end)
end)

local function getChar() return LP.Character end
local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

-- ══ GOD MODE — не умираем НИКОГДА ══
-- Ставим до телепорта чтобы при падении не умерали
RunService.Heartbeat:Connect(function()
    if not ACTIVE then return end
    local h = getHum()
    if h then
        h.MaxHealth = math.huge
        h.Health    = math.huge
        -- Запрещаем смерть
        h.BreakJointsOnDeath = false
    end
end)

-- ══ NOCLIP ══
RunService.Stepped:Connect(function()
    if not ACTIVE then return end
    local c = getChar() if not c then return end
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
end)

-- ══ ТЕЛЕПОРТ К МОНЕТАМ (БЕЗ ПОДЪЁМА ВВЕРХ) ══
local coinNames = {
    ["Coin"]       = true,
    ["DropCoin"]   = true,
    ["GoldCoin"]   = true,
    ["SilverCoin"] = true,
    ["coin"]       = true,
}

local function findCoins()
    local list = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if coinNames[obj.Name] and (
            obj:IsA("BasePart") or
            obj:IsA("MeshPart") or
            obj:IsA("UnionOperation") or
            obj:IsA("SpecialMesh")
        ) then
            -- Берём родителя если это Mesh внутри Part
            local part = obj:IsA("BasePart") and obj or obj.Parent
            if part and part:IsA("BasePart") and part.Parent then
                table.insert(list, part)
            end
        end
    end
    return list
end

local lastTP  = 0
local cidx    = 1
local coinCount = 0

RunService.Heartbeat:Connect(function()
    if not ACTIVE then return end
    if tick() - lastTP < 0.4 then return end
    lastTP = tick()

    local hrp = getHRP() if not hrp then return end
    local coins = findCoins()
    if #coins == 0 then return end

    if cidx > #coins then cidx = 1 end
    local target = coins[cidx]
    cidx = cidx + 1

    if target and target.Parent then
        -- Телепортируем НА ТУ ЖЕ ВЫСОТУ что и монета
        -- Не поднимаем вверх — просто X Z как у монеты, Y берём текущий персонажа
        hrp.CFrame = CFrame.new(
            target.Position.X,
            hrp.Position.Y,   -- ← остаёмся на своей высоте!
            target.Position.Z
        )
    end
end)

-- ══ АВТО КНОПКИ ══
RunService.Heartbeat:Connect(function()
    if not ACTIVE then return end
    pcall(function()
        for _, g in ipairs(LP.PlayerGui:GetDescendants()) do
            if g:IsA("TextButton") then
                local t = g.Text:lower()
                if t:find("play") or t:find("vote") or t:find("again")
                or t:find("ok") or t:find("ready") then
                    g.MouseButton1Click:Fire()
                end
            end
        end
    end)
end)

-- Счётчик через touch
local function trackCoins(char)
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if not hrp then return end
    hrp.Touched:Connect(function(hit)
        if ACTIVE and coinNames[hit.Name] then
            coinCount = coinCount + 1
        end
    end)
end

LP.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    trackCoins(char)
end)
if LP.Character then trackCoins(LP.Character) end

-- ════════════════════════════
--         МИНИ GUI
-- ════════════════════════════
if game.CoreGui:FindFirstChild("AFKv3") then
    game.CoreGui.AFKv3:Destroy()
end

local sg = Instance.new("ScreenGui", game.CoreGui)
sg.Name = "AFKv3"
sg.ResetOnSpawn = false

local TEAL = Color3.fromRGB(0, 201, 167)
local RED  = Color3.fromRGB(220, 50, 50)
local BG   = Color3.fromRGB(13, 17, 23)
local DIM  = Color3.fromRGB(60, 80, 100)
local TEXT = Color3.fromRGB(200, 220, 230)

-- ОКНО
local W = Instance.new("Frame", sg)
W.Size     = UDim2.new(0, 155, 0, 175)
W.Position = UDim2.new(0, 10, 0.4, 0)
W.BackgroundColor3 = BG
W.BorderSizePixel  = 0
W.Active    = true
W.Draggable = true
Instance.new("UICorner", W).CornerRadius = UDim.new(0, 10)
local ws = Instance.new("UIStroke", W)
ws.Color = TEAL ws.Thickness = 1

-- ШАПКА
local Hdr = Instance.new("Frame", W)
Hdr.Size = UDim2.new(1, 0, 0, 30)
Hdr.BackgroundColor3 = Color3.fromRGB(17, 24, 32)
Hdr.BorderSizePixel  = 0
Instance.new("UICorner", Hdr).CornerRadius = UDim.new(0, 10)
local hf = Instance.new("Frame", Hdr)
hf.Size = UDim2.new(1,0,0.5,0) hf.Position = UDim2.new(0,0,0.5,0)
hf.BackgroundColor3 = Color3.fromRGB(17,24,32) hf.BorderSizePixel = 0

local HTitle = Instance.new("TextLabel", Hdr)
HTitle.Size = UDim2.new(1,-30,1,0)
HTitle.Position = UDim2.new(0,8,0,0)
HTitle.BackgroundTransparency = 1
HTitle.Text = "🌊 AFK Farm v3"
HTitle.TextColor3 = TEAL
HTitle.Font = Enum.Font.GothamBold
HTitle.TextSize = 11
HTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопка закрыть
local ClsBtn = Instance.new("TextButton", Hdr)
ClsBtn.Size = UDim2.new(0,20,0,20)
ClsBtn.Position = UDim2.new(1,-24,0.5,-10)
ClsBtn.BackgroundColor3 = RED
ClsBtn.Text = "✕"
ClsBtn.TextColor3 = Color3.new(1,1,1)
ClsBtn.Font = Enum.Font.GothamBold
ClsBtn.TextSize = 10
ClsBtn.BorderSizePixel = 0
Instance.new("UICorner", ClsBtn).CornerRadius = UDim.new(0,5)
ClsBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

-- СТАТУС
local StatLbl = Instance.new("TextLabel", W)
StatLbl.Size = UDim2.new(1,-10,0,16)
StatLbl.Position = UDim2.new(0,5,0,33)
StatLbl.BackgroundTransparency = 1
StatLbl.Text = "⭕  Выключен"
StatLbl.TextColor3 = RED
StatLbl.Font = Enum.Font.GothamBold
StatLbl.TextSize = 11
StatLbl.TextXAlignment = Enum.TextXAlignment.Left

-- СТРОКИ ФИЧ
local function mkRow(y, icon, txt)
    local l = Instance.new("TextLabel", W)
    l.Size = UDim2.new(1,-10,0,13)
    l.Position = UDim2.new(0,8,0,y)
    l.BackgroundTransparency = 1
    l.Text = icon.."  "..txt
    l.TextColor3 = DIM
    l.Font = Enum.Font.Code
    l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left
    return l
end

local r1 = mkRow(52,  "🛡", "God Mode")
local r2 = mkRow(66,  "💰", "Монеты: 0")
local r3 = mkRow(80,  "🔒", "Anti-AFK")
local r4 = mkRow(94,  "🌀", "Noclip")

-- Обновление счётчика монет
RunService.Heartbeat:Connect(function()
    if ACTIVE then
        r2.Text = "💰  Монеты: " .. coinCount
    end
end)

-- КНОПКА СТАРТ
local StartBtn = Instance.new("TextButton", W)
StartBtn.Size = UDim2.new(1,-16,0,26)
StartBtn.Position = UDim2.new(0,8,0,112)
StartBtn.BackgroundColor3 = TEAL
StartBtn.Text = "▶  СТАРТ"
StartBtn.TextColor3 = Color3.new(1,1,1)
StartBtn.Font = Enum.Font.GothamBold
StartBtn.TextSize = 12
StartBtn.BorderSizePixel = 0
Instance.new("UICorner", StartBtn).CornerRadius = UDim.new(0,7)

-- КНОПКА СТОП
local StopBtn = Instance.new("TextButton", W)
StopBtn.Size = UDim2.new(1,-16,0,26)
StopBtn.Position = UDim2.new(0,8,0,142)
StopBtn.BackgroundColor3 = Color3.fromRGB(30,15,15)
StopBtn.Text = "⏹  СТОП"
StopBtn.TextColor3 = RED
StopBtn.Font = Enum.Font.GothamBold
StopBtn.TextSize = 12
StopBtn.BorderSizePixel = 0
Instance.new("UIStroke", StopBtn).Color = RED
Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0,7)

-- ── ЛОГИКА КНОПОК ──
local function setRows(on)
    local col = on and TEAL or DIM
    for _, r in ipairs({r1,r2,r3,r4}) do r.TextColor3 = col end
end

StartBtn.MouseButton1Click:Connect(function()
    ACTIVE = true
    StatLbl.Text = "✅  Активен"
    StatLbl.TextColor3 = TEAL
    ws.Color = TEAL
    setRows(true)
    TweenService:Create(StartBtn, TweenInfo.new(0.1), {
        BackgroundColor3 = Color3.fromRGB(0,160,130)
    }):Play()
end)

StopBtn.MouseButton1Click:Connect(function()
    ACTIVE = false
    StatLbl.Text = "⭕  Выключен"
    StatLbl.TextColor3 = RED
    ws.Color = RED
    setRows(false)
    TweenService:Create(StartBtn, TweenInfo.new(0.1), {
        BackgroundColor3 = TEAL
    }):Play()
    -- Вернуть нормальный HP
    pcall(function()
        local h = getHum()
        if h then h.MaxHealth = 100 h.Health = 100 end
    end)
end)

print("[MM2 AFK Farm v3] Готов | Нажми СТАРТ | @Primejtsu")
