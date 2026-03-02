-- ╔══════════════════════════════════════════════════════╗
-- ║   PRIMEJTSU HUB  |  Garden Horizons  |  v3.0        ║
-- ║   @Primejtsu  |  Nazar513000                        ║
-- ║   Ключ: Primejtsu                                   ║
-- ╚══════════════════════════════════════════════════════╝

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local Lighting     = game:GetService("Lighting")
local LP           = Players.LocalPlayer
local Camera       = workspace.CurrentCamera
local VALID_KEY    = "Primejtsu"
local keyVerified  = false

-- ══ СОСТОЯНИЕ ══
local CFG = {
    speed        = false,
    fly          = false,
    noclip       = false,
    infiniteJump = false,
    antiAfk      = true,
    esp          = false,
    autoHarvest  = false,
    autoSell     = false,
    autoPlant    = false,
    fullbright   = false,
}

-- Список реальных фруктов/растений Garden Horizons
local FRUIT_NAMES = {
    -- Основные культуры (из кода игры)
    "Carrot","Corn","Onion","Strawberry","Mushroom","Beetroot","Tomato",
    "Apple","Rose","Wheat","Banana","Plum","Potato","Cabbage","Cherry",
    -- Дополнительные
    "Watermelon","Pumpkin","Grape","Lemon","Orange","Peach","Pear",
    "Blueberry","Raspberry","Sunflower","Pepper","Garlic","Radish","Turnip",
    -- Общие слова для поиска
    "Fruit","Crop","Plant","Harvest","Ripe","Grown","Berry","Flower","Seed",
}

local SELL_KEYWORDS = {
    "SellStation","Stall","Market","Sellbox","Cashier","ShopStand",
    "Vendor","Trader","sell","market","shop","stall","stand","bill",
}

local PLOT_KEYWORDS = {
    "Plot","FarmPlot","GardenPlot","Soil","Dirt","Bed","Farm",
    "plot","soil","dirt","bed","farm",
}

-- Статистика
local harvestCount = 0
local sellCount    = 0
local earnedCoins  = 0

-- ══ ХЕЛПЕРЫ ══
local function getChar() return LP.Character end
local function getHRP()  local c=getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()  local c=getChar() return c and c:FindFirstChildOfClass("Humanoid") end

local function notify(t,m,d)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification",{Title=t,Text=m,Duration=d or 4})
    end)
end

local function nameMatch(name, keywords)
    local n = name:lower()
    for _, kw in ipairs(keywords) do
        if n:find(kw:lower()) then return true end
    end
    return false
end

-- Получить позицию объекта (Model или Part)
local function getPos(obj)
    local ok, pos = pcall(function()
        if obj:IsA("Model") then return obj:GetPivot().Position
        elseif obj:IsA("BasePart") then return obj.Position
        end
    end)
    return ok and pos or nil
end

-- Получить все ProximityPrompts на объекте и рядом
local function getPrompts(obj)
    local prompts = {}
    pcall(function()
        for _, d in ipairs(obj:GetDescendants()) do
            if d:IsA("ProximityPrompt") then table.insert(prompts, d) end
        end
        if obj.Parent then
            for _, d in ipairs(obj.Parent:GetDescendants()) do
                if d:IsA("ProximityPrompt") then table.insert(prompts, d) end
            end
        end
    end)
    return prompts
end

-- ══════════════════════════════════════════════════════════
--   СИСТЕМЫ
-- ══════════════════════════════════════════════════════════

-- ANTI AFK
task.spawn(function()
    pcall(function()
        LP.Idled:Connect(function()
            if not CFG.antiAfk then return end
            local vu = game:GetService("VirtualUser")
            vu:Button2Down(Vector2.new(0,0), Camera.CFrame)
            task.wait(0.1)
            vu:Button2Up(Vector2.new(0,0), Camera.CFrame)
            local h = getHum()
            if h then h.Jump = true end
        end)
    end)
    while true do
        task.wait(55)
        if not CFG.antiAfk then continue end
        pcall(function()
            local vu = game:GetService("VirtualUser")
            vu:Button2Down(Vector2.new(0,0), Camera.CFrame)
            task.wait(0.1)
            vu:Button2Up(Vector2.new(0,0), Camera.CFrame)
            local h = getHum()
            if h then h.Jump = true end
        end)
    end
end)

-- SPEED
RunService.Heartbeat:Connect(function()
    if not keyVerified then return end
    local h = getHum()
    if not h then return end
    if CFG.fly or CFG.autoHarvest or CFG.autoPlant then return end
    if CFG.speed then
        h.WalkSpeed = 32
    elseif h.WalkSpeed ~= 16 then
        h.WalkSpeed = 16
    end
    if CFG.infiniteJump and h.FloorMaterial ~= Enum.Material.Air then
        h.Jump = true
    end
end)

-- NOCLIP
local noclipOn = false
RunService.Stepped:Connect(function()
    if not keyVerified then return end
    if CFG.noclip then
        noclipOn = true
        local c = getChar()
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    elseif noclipOn then
        noclipOn = false
        pcall(function()
            local c = getChar()
            if c then
                for _, p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = true end
                end
            end
            local hrp = getHRP()
            if hrp and hrp.Position.Y < -30 then
                hrp.CFrame = CFrame.new(hrp.Position.X, 10, hrp.Position.Z)
            end
        end)
    end
end)

-- FLY
local flyConn   = nil
local flyBodies = {}
local function startFly()
    local hrp = getHRP()
    local h   = getHum()
    if not hrp or not h then return end
    h.PlatformStand = true
    local bg = Instance.new("BodyGyro", hrp)
    bg.P = 9e4 bg.MaxTorque = Vector3.new(9e9,9e9,9e9) bg.CFrame = hrp.CFrame
    local bv = Instance.new("BodyVelocity", hrp)
    bv.Velocity = Vector3.zero bv.MaxForce = Vector3.new(9e9,9e9,9e9) bv.Name = "FlyVel"
    flyBodies = {bg, bv}
    flyConn = RunService.Heartbeat:Connect(function()
        if not CFG.fly then return end
        local hrp2 = getHRP()
        if not hrp2 then return end
        local bv2 = hrp2:FindFirstChild("FlyVel")
        if not bv2 then return end
        local cf  = Camera.CFrame
        local mv  = Vector3.zero
        local spd = 28
        if UIS:IsKeyDown(Enum.KeyCode.W) then mv = mv + cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then mv = mv - cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then mv = mv - cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then mv = mv + cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) or UIS:IsKeyDown(Enum.KeyCode.E) then mv = mv + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.Q) then mv = mv + Vector3.new(0,-1,0) end
        bv2.Velocity = mv.Magnitude > 0 and mv.Unit * spd or Vector3.zero
        bg.CFrame = cf
    end)
end
local function stopFly()
    if flyConn then flyConn:Disconnect() flyConn = nil end
    for _, b in ipairs(flyBodies) do pcall(function() b:Destroy() end) end
    flyBodies = {}
    local h = getHum()
    if h then h.PlatformStand = false end
end

-- FULLBRIGHT
local function setFB(v)
    if v then
        Lighting.Brightness    = 2.5
        Lighting.ClockTime     = 14
        Lighting.GlobalShadows = false
        Lighting.Ambient       = Color3.new(1,1,1)
        Lighting.OutdoorAmbient = Color3.new(1,1,1)
    else
        Lighting.Brightness    = 1
        Lighting.GlobalShadows = true
        Lighting.Ambient       = Color3.fromRGB(127,127,127)
        Lighting.OutdoorAmbient = Color3.fromRGB(127,127,127)
    end
end

-- ══════════════════════════════════════════════════════════
--   GARDEN HORIZONS — ГЛАВНЫЕ МЕХАНИКИ
--   Реальные механики: Quick Interact (E) + ProximityPrompt
--   Продажа: идёшь к SellStation и жмёшь E или fireproximityprompt
-- ══════════════════════════════════════════════════════════

-- Собрать урожай у конкретной позиции
local function harvestAt(pos)
    local hrp = getHRP()
    local hum = getHum()
    if not hrp or not hum then return false end
    hum:MoveTo(pos)
    local t0 = tick()
    repeat
        task.wait(0.08)
        if tick() - t0 > 0.5 then
            hum:MoveTo(pos)
        end
    until (hrp.Position - pos).Magnitude < 5 or tick() - t0 > 6

    -- Fire все ProximityPrompts в радиусе
    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("ProximityPrompt") then
                local part = obj.Parent
                if part and part:IsA("BasePart") then
                    if (part.Position - hrp.Position).Magnitude < 10 then
                        fireproximityprompt(obj)
                    end
                end
            end
            if obj:IsA("ClickDetector") then
                local part = obj.Parent
                if part and part:IsA("BasePart") then
                    if (part.Position - hrp.Position).Magnitude < 10 then
                        fireclickdetector(obj)
                    end
                end
            end
        end)
    end

    -- Также пробуем VirtualInput E (Quick Interact)
    pcall(function()
        local vu = game:GetService("VirtualUser")
        vu:Button1Down(Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2), Camera.CFrame)
        task.wait(0.07)
        vu:Button1Up(Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2), Camera.CFrame)
    end)
    return true
end

-- Найти все зрелые плоды на карте
local function getFruits()
    local list = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if nameMatch(obj.Name, FRUIT_NAMES) and obj.Parent ~= LP.Character then
                local pos = getPos(obj)
                if pos then
                    table.insert(list, {obj=obj, pos=pos})
                end
            end
        end)
    end
    return list
end

-- Найти точки продажи
local function getSellPoints()
    local list = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if nameMatch(obj.Name, SELL_KEYWORDS) then
                local pos = getPos(obj)
                if pos then table.insert(list, {obj=obj, pos=pos}) end
            end
        end)
    end
    return list
end

-- Найти пустые грядки
local function getPlots()
    local list = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if nameMatch(obj.Name, PLOT_KEYWORDS) then
                local pos = getPos(obj)
                if pos then table.insert(list, {obj=obj, pos=pos}) end
            end
        end)
    end
    return list
end

-- ══ AUTO HARVEST LOOP ══
task.spawn(function()
    while true do
        task.wait(0.2)
        if not CFG.autoHarvest or not keyVerified then continue end
        local hum = getHum()
        if not hum then continue end
        hum.WalkSpeed = 50

        local fruits = getFruits()
        if #fruits == 0 then task.wait(1) continue end

        -- Берём ближайший
        local hrp = getHRP()
        if not hrp then continue end
        local best, bd = nil, math.huge
        for _, f in ipairs(fruits) do
            local d = (hrp.Position - f.pos).Magnitude
            if d < bd then bd = d best = f end
        end

        if best then
            local existed = best.obj and best.obj.Parent
            harvestAt(best.pos)
            if existed then
                harvestCount = harvestCount + 1
            end
        end
    end
end)

-- ══ AUTO SELL LOOP ══
task.spawn(function()
    while true do
        task.wait(1)
        if not CFG.autoSell or not keyVerified then continue end
        local hrp = getHRP()
        local hum = getHum()
        if not hrp or not hum then continue end

        local points = getSellPoints()
        if #points == 0 then
            -- Пробуем нажать кнопки продажи в GUI
            pcall(function()
                for _, g in ipairs(LP.PlayerGui:GetDescendants()) do
                    if g:IsA("TextButton") and g.Visible then
                        local t = g.Text:lower()
                        if t:find("sell") or t:find("продать") then
                            g.MouseButton1Click:Fire()
                        end
                    end
                end
            end)
            continue
        end

        -- Идём к ближайшей точке продажи
        local best, bd = nil, math.huge
        for _, p in ipairs(points) do
            local d = (hrp.Position - p.pos).Magnitude
            if d < bd then bd = d best = p end
        end

        if best then
            hum.WalkSpeed = 50
            hum:MoveTo(best.pos)
            local t0 = tick()
            repeat
                task.wait(0.1)
                if tick() - t0 > 0.5 then hum:MoveTo(best.pos) end
            until (hrp.Position - best.pos).Magnitude < 8 or tick() - t0 > 8

            task.wait(0.15)
            -- Жмём все промпты у точки продажи
            for _, pr in ipairs(getPrompts(best.obj)) do
                pcall(function() fireproximityprompt(pr) end)
            end
            -- В радиусе
            for _, obj in ipairs(workspace:GetDescendants()) do
                pcall(function()
                    if obj:IsA("ProximityPrompt") then
                        local part = obj.Parent
                        if part and part:IsA("BasePart") and (part.Position - hrp.Position).Magnitude < 12 then
                            fireproximityprompt(obj)
                        end
                    end
                    if obj:IsA("ClickDetector") then
                        local part = obj.Parent
                        if part and part:IsA("BasePart") and (part.Position - hrp.Position).Magnitude < 12 then
                            fireclickdetector(obj)
                        end
                    end
                end)
            end
            -- GUI кнопки
            pcall(function()
                for _, g in ipairs(LP.PlayerGui:GetDescendants()) do
                    if g:IsA("TextButton") and g.Visible then
                        local t = g.Text:lower()
                        if t:find("sell") or t:find("confirm") or t:find("ok") or t:find("продать") then
                            g.MouseButton1Click:Fire()
                        end
                    end
                end
            end)
            sellCount = sellCount + 1
        end
    end
end)

-- ══ AUTO PLANT LOOP ══
task.spawn(function()
    while true do
        task.wait(0.5)
        if not CFG.autoPlant or not keyVerified then continue end
        local hrp = getHRP()
        local hum = getHum()
        if not hrp or not hum then continue end
        hum.WalkSpeed = 45

        local plots = getPlots()
        for _, plot in ipairs(plots) do
            if not CFG.autoPlant then break end
            hum:MoveTo(plot.pos)
            local t0 = tick()
            repeat
                task.wait(0.08)
                if tick() - t0 > 0.5 then hum:MoveTo(plot.pos) end
            until (hrp.Position - plot.pos).Magnitude < 5 or tick() - t0 > 5

            for _, pr in ipairs(getPrompts(plot.obj)) do
                pcall(function() fireproximityprompt(pr) end)
            end
            pcall(function()
                for _, g in ipairs(LP.PlayerGui:GetDescendants()) do
                    if g:IsA("TextButton") and g.Visible then
                        local t = g.Text:lower()
                        if t:find("plant") or t:find("посадить") or t:find("seed") then
                            g.MouseButton1Click:Fire()
                        end
                    end
                end
            end)
            task.wait(0.3)
        end
    end
end)

-- ══ ESP ИГРОКОВ ══
local espObjects = {}
local function removeESP(p)
    if espObjects[p] then
        pcall(function() espObjects[p]:Destroy() end)
        espObjects[p] = nil
    end
end
local function createESP(p)
    if p == LP then return end
    removeESP(p)
    local function setup(char)
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        local hum = char:WaitForChild("Humanoid", 5)
        if not hrp or not hum then return end
        local bb = Instance.new("BillboardGui")
        bb.Name = "PTJESP3" bb.AlwaysOnTop = true
        bb.Size = UDim2.new(0,140,0,52) bb.StudsOffset = Vector3.new(0,3.5,0)
        bb.Adornee = hrp bb.Parent = hrp bb.Enabled = false
        local nL = Instance.new("TextLabel",bb)
        nL.Size=UDim2.new(1,0,0,26) nL.BackgroundTransparency=1
        nL.Font=Enum.Font.GothamBlack nL.TextSize=14
        nL.Text=p.Name nL.TextColor3=Color3.fromRGB(100,255,100)
        nL.TextStrokeTransparency=0 nL.TextStrokeColor3=Color3.new(0,0,0)
        local hL = Instance.new("TextLabel",bb)
        hL.Size=UDim2.new(1,0,0,14) hL.Position=UDim2.new(0,0,0,26)
        hL.BackgroundTransparency=1 hL.Font=Enum.Font.Code hL.TextSize=11
        hL.TextColor3=Color3.fromRGB(180,255,180)
        hL.TextStrokeTransparency=0 hL.TextStrokeColor3=Color3.new(0,0,0)
        local dL = Instance.new("TextLabel",bb)
        dL.Size=UDim2.new(1,0,0,12) dL.Position=UDim2.new(0,0,0,40)
        dL.BackgroundTransparency=1 dL.Font=Enum.Font.Code dL.TextSize=10
        dL.TextColor3=Color3.fromRGB(150,200,150)
        dL.TextStrokeTransparency=0 dL.TextStrokeColor3=Color3.new(0,0,0)
        local function upd()
            if not bb.Parent then return end
            hL.Text = "❤ " .. math.floor(math.clamp(hum.Health,0,hum.MaxHealth))
            local my = getHRP()
            if my then dL.Text = "📍 " .. math.floor((my.Position-hrp.Position).Magnitude) .. " st" end
            bb.Enabled = CFG.esp
        end
        hum:GetPropertyChangedSignal("Health"):Connect(function() pcall(upd) end)
        task.spawn(function() while bb and bb.Parent do pcall(upd) task.wait(1) end end)
        RunService.Heartbeat:Connect(function()
            if bb and bb.Parent then bb.Enabled = CFG.esp end
        end)
        espObjects[p] = bb
        pcall(upd)
    end
    if p.Character then task.spawn(function() setup(p.Character) end) end
    p.CharacterAdded:Connect(function(c) task.wait(1) task.spawn(function() setup(c) end) end)
end
for _, p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(function(p) task.wait(1) createESP(p) end)
Players.PlayerRemoving:Connect(function(p) removeESP(p) end)

-- ══════════════════════════════════════════════════════════
--   GUI
-- ══════════════════════════════════════════════════════════

if game.CoreGui:FindFirstChild("PTH_GH3") then
    game.CoreGui.PTH_GH3:Destroy()
end
local sg = Instance.new("ScreenGui", game.CoreGui)
sg.Name = "PTH_GH3"
sg.ResetOnSpawn   = false
sg.DisplayOrder   = 999
sg.IgnoreGuiInset = true

-- ЦВЕТА
local C = {
    bg      = Color3.fromRGB(7,11,7),
    side    = Color3.fromRGB(11,17,11),
    card    = Color3.fromRGB(15,23,15),
    border  = Color3.fromRGB(28,55,28),
    green   = Color3.fromRGB(48,215,78),
    dgreen  = Color3.fromRGB(22,105,40),
    lgreen  = Color3.fromRGB(115,235,138),
    white   = Color3.fromRGB(232,232,232),
    muted   = Color3.fromRGB(78,108,78),
    dim     = Color3.fromRGB(18,28,18),
    gold    = Color3.fromRGB(238,185,18),
    red     = Color3.fromRGB(210,48,48),
}

local function tw(obj, t, props, style)
    TweenService:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quart), props):Play()
end
local function twBack(obj, t, props)
    TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Back, Enum.EasingDirection.Out), props):Play()
end

-- ══════════════════════════════════════════════════════════
--   ЭКРАН КЛЮЧА
-- ══════════════════════════════════════════════════════════

local KS = Instance.new("Frame", sg)
KS.Size = UDim2.new(1,0,1,0)
KS.BackgroundColor3 = Color3.fromRGB(2,5,2)
KS.BorderSizePixel  = 0
KS.ZIndex           = 200

-- Анимированный фон
math.randomseed(tick())
local EMOJIS = {"🍎","🥕","🍓","🌽","🍄","🥔","🍇","🍋","🍑","🌻","🌿","🍃","🌱","☘️","🌾"}
for i = 1, 55 do
    local lf = Instance.new("TextLabel", KS)
    lf.Size                = UDim2.new(0,24,0,24)
    lf.Position            = UDim2.new(math.random(2,97)/100, 0, math.random(2,97)/100, 0)
    lf.BackgroundTransparency = 1
    lf.Text                = EMOJIS[math.random(1,#EMOJIS)]
    lf.TextSize            = math.random(11,24)
    lf.TextTransparency    = math.random(50,85)/100
    lf.Font                = Enum.Font.GothamBold
    lf.ZIndex              = 201
    -- Анимация плавания
    task.spawn(function()
        task.wait(math.random() * 5)
        while lf and lf.Parent do
            local newY = lf.Position.Y.Scale + (math.random() - 0.5) * 0.04
            newY = math.clamp(newY, 0.02, 0.97)
            TweenService:Create(lf, TweenInfo.new(math.random(25,45)/10, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                TextTransparency = math.random(10,35)/100,
                Position = UDim2.new(lf.Position.X.Scale, 0, newY, 0),
            }):Play()
            task.wait(math.random(25,45)/10)
            TweenService:Create(lf, TweenInfo.new(math.random(25,45)/10, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                TextTransparency = math.random(60,90)/100,
                Position = UDim2.new(lf.Position.X.Scale, 0, newY + (math.random()-0.5)*0.03, 0),
            }):Play()
            task.wait(math.random(25,45)/10)
        end
    end)
end

-- Карточка ключа
local KC = Instance.new("Frame", KS)
KC.Size               = UDim2.new(0.86,0,0,350)
KC.Position           = UDim2.new(0.07,0,0.5,-175)
KC.BackgroundColor3   = Color3.fromRGB(5,12,5)
KC.BorderSizePixel    = 0
KC.ZIndex             = 202
Instance.new("UICorner", KC).CornerRadius = UDim.new(0,18)
local kcStroke = Instance.new("UIStroke", KC)
kcStroke.Color = C.dgreen kcStroke.Thickness = 1.5

-- Верхняя зелёная полоска
local kcBar = Instance.new("Frame", KC)
kcBar.Size = UDim2.new(1,0,0,3) kcBar.BackgroundColor3 = C.green kcBar.BorderSizePixel = 0 kcBar.ZIndex = 203
Instance.new("UICorner", kcBar).CornerRadius = UDim.new(1,0)

-- Иконка с пульсацией
local kcIco = Instance.new("TextLabel", KC)
kcIco.Size = UDim2.new(1,0,0,75) kcIco.Position = UDim2.new(0,0,0,12)
kcIco.BackgroundTransparency = 1 kcIco.Text = "🌱" kcIco.TextSize = 62
kcIco.Font = Enum.Font.GothamBlack kcIco.ZIndex = 203
task.spawn(function()
    while kcIco and kcIco.Parent do
        tw(kcIco, 0.75, {TextSize=70}, Enum.EasingStyle.Sine) task.wait(0.75)
        tw(kcIco, 0.75, {TextSize=60}, Enum.EasingStyle.Sine) task.wait(0.75)
    end
end)

-- Заголовок
local kcTitle = Instance.new("TextLabel", KC)
kcTitle.Size = UDim2.new(1,0,0,28) kcTitle.Position = UDim2.new(0,0,0,92)
kcTitle.BackgroundTransparency = 1 kcTitle.Text = "PRIMEJTSU HUB"
kcTitle.TextColor3 = C.green kcTitle.Font = Enum.Font.GothamBlack kcTitle.TextSize = 22 kcTitle.ZIndex = 203

-- Печать заголовка
task.spawn(function()
    task.wait(0.3)
    local full = "PRIMEJTSU HUB"
    kcTitle.Text = ""
    for i = 1, #full do
        kcTitle.Text = full:sub(1,i)
        task.wait(0.05)
    end
end)

local kcSub = Instance.new("TextLabel", KC)
kcSub.Size = UDim2.new(1,0,0,17) kcSub.Position = UDim2.new(0,0,0,122)
kcSub.BackgroundTransparency = 1 kcSub.Text = "🌿 Garden Horizons  •  @Primejtsu"
kcSub.TextColor3 = C.muted kcSub.Font = Enum.Font.Code kcSub.TextSize = 11 kcSub.ZIndex = 203

-- Разделитель
local kcLine = Instance.new("Frame", KC)
kcLine.Size = UDim2.new(0.8,0,0,1) kcLine.Position = UDim2.new(0.1,0,0,148)
kcLine.BackgroundColor3 = C.border kcLine.BorderSizePixel = 0 kcLine.ZIndex = 203

local kcHint = Instance.new("TextLabel", KC)
kcHint.Size = UDim2.new(0.84,0,0,18) kcHint.Position = UDim2.new(0.08,0,0,158)
kcHint.BackgroundTransparency = 1 kcHint.Text = "🔑  Ключ доступа:"
kcHint.TextColor3 = C.lgreen kcHint.Font = Enum.Font.GothamBold kcHint.TextSize = 12
kcHint.TextXAlignment = Enum.TextXAlignment.Left kcHint.ZIndex = 203

-- Поле ввода
local kcBox = Instance.new("Frame", KC)
kcBox.Size = UDim2.new(0.84,0,0,48) kcBox.Position = UDim2.new(0.08,0,0,180)
kcBox.BackgroundColor3 = C.dim kcBox.BorderSizePixel = 0 kcBox.ZIndex = 203
Instance.new("UICorner", kcBox).CornerRadius = UDim.new(0,10)
local kcStroke2 = Instance.new("UIStroke", kcBox)
kcStroke2.Color = C.border kcStroke2.Thickness = 1.5

-- Мигающий курсор
local kcCursor = Instance.new("TextLabel", kcBox)
kcCursor.Size = UDim2.new(0,2,0.7,0) kcCursor.Position = UDim2.new(0,8,0.15,0)
kcCursor.BackgroundColor3 = C.green kcCursor.BorderSizePixel = 0 kcCursor.Text = "" kcCursor.ZIndex = 206
task.spawn(function()
    while kcCursor and kcCursor.Parent do
        tw(kcCursor,0.4,{BackgroundTransparency=0}) task.wait(0.4)
        tw(kcCursor,0.4,{BackgroundTransparency=1}) task.wait(0.4)
    end
end)

local kcInput = Instance.new("TextBox", kcBox)
kcInput.Size = UDim2.new(1,-18,1,0) kcInput.Position = UDim2.new(0,9,0,0)
kcInput.BackgroundTransparency = 1 kcInput.Text = ""
kcInput.PlaceholderText = "Введи ключ..." kcInput.PlaceholderColor3 = C.muted
kcInput.TextColor3 = C.white kcInput.Font = Enum.Font.GothamBold kcInput.TextSize = 16
kcInput.ClearTextOnFocus = false kcInput.ZIndex = 204
kcInput.FocusLost:Connect(function() kcCursor.Visible = true end)
kcInput.Focused:Connect(function() kcCursor.Visible = false end)

local kcStatus = Instance.new("TextLabel", KC)
kcStatus.Size = UDim2.new(0.84,0,0,20) kcStatus.Position = UDim2.new(0.08,0,0,232)
kcStatus.BackgroundTransparency = 1 kcStatus.Text = ""
kcStatus.Font = Enum.Font.GothamBold kcStatus.TextSize = 11 kcStatus.ZIndex = 203
kcStatus.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопка входа
local kcBtn = Instance.new("TextButton", KC)
kcBtn.Size = UDim2.new(0.84,0,0,50) kcBtn.Position = UDim2.new(0.08,0,0,256)
kcBtn.BackgroundColor3 = C.dgreen kcBtn.Text = "🌱  ВОЙТИ"
kcBtn.TextColor3 = C.white kcBtn.Font = Enum.Font.GothamBlack kcBtn.TextSize = 17
kcBtn.BorderSizePixel = 0 kcBtn.ZIndex = 204
Instance.new("UICorner", kcBtn).CornerRadius = UDim.new(0,11)
Instance.new("UIStroke", kcBtn).Color = C.green

-- Hover кнопки
kcBtn.MouseEnter:Connect(function() tw(kcBtn,0.1,{BackgroundColor3=Color3.fromRGB(30,130,55)}) end)
kcBtn.MouseLeave:Connect(function() tw(kcBtn,0.1,{BackgroundColor3=C.dgreen}) end)
kcBtn.MouseButton1Down:Connect(function() tw(kcBtn,0.07,{BackgroundColor3=C.green}) end)
kcBtn.MouseButton1Up:Connect(function() tw(kcBtn,0.1,{BackgroundColor3=Color3.fromRGB(30,130,55)}) end)

local kcVer = Instance.new("TextLabel", KC)
kcVer.Size = UDim2.new(1,0,0,16) kcVer.Position = UDim2.new(0,0,0,320)
kcVer.BackgroundTransparency = 1 kcVer.Text = "v3.0  •  Nazar513000  •  2025"
kcVer.TextColor3 = Color3.fromRGB(35,65,35) kcVer.Font = Enum.Font.Code kcVer.TextSize = 9 kcVer.ZIndex = 203

-- Входной анимированный прогресс
local kcProg = Instance.new("Frame", KC)
kcProg.Size = UDim2.new(0,0,0,2) kcProg.Position = UDim2.new(0,0,0,2)
kcProg.BackgroundColor3 = C.green kcProg.BorderSizePixel = 0 kcProg.ZIndex = 204
local kcProgInner = Instance.new("UICorner", kcProg) kcProgInner.CornerRadius = UDim.new(1,0)

local showMain  -- объявлено позже

-- Shake-анимация
local function shake()
    local orig = kcBox.Position
    task.spawn(function()
        for _ = 1, 4 do
            tw(kcBox,0.04,{Position=UDim2.new(orig.X.Scale,-9,orig.Y.Scale,orig.Y.Offset)})
            task.wait(0.06)
            tw(kcBox,0.04,{Position=UDim2.new(orig.X.Scale,9,orig.Y.Scale,orig.Y.Offset)})
            task.wait(0.06)
        end
        tw(kcBox,0.06,{Position=orig})
    end)
end

local function tryKey()
    local entered = kcInput.Text
    if entered == VALID_KEY then
        kcStatus.Text      = "✅ Ключ принят! Загружаю..."
        kcStatus.TextColor3 = C.green
        kcStroke2.Color    = C.green
        keyVerified        = true

        -- Прогресс-бар
        TweenService:Create(kcProg, TweenInfo.new(0.7, Enum.EasingStyle.Quart), {Size=UDim2.new(1,0,0,2)}):Play()
        task.wait(0.75)

        -- Выход с анимацией масштаба
        tw(KC, 0.3, {Size=UDim2.new(0,0,0,0), Position=UDim2.new(0.5,0,0.5,0)}, Enum.EasingStyle.Back)
        tw(KS, 0.5, {BackgroundTransparency=1})
        task.wait(0.6)
        KS:Destroy()
        showMain()
    else
        kcStatus.Text      = "❌ Неверный ключ! Попробуй ещё."
        kcStatus.TextColor3 = C.red
        kcStroke2.Color    = C.red
        -- Красная пульсация
        tw(kcBox, 0.15, {BackgroundColor3=Color3.fromRGB(40,8,8)})
        task.wait(0.15)
        tw(kcBox, 0.15, {BackgroundColor3=C.dim})
        shake()
        task.wait(2)
        kcStroke2.Color = C.border
    end
end

kcBtn.MouseButton1Click:Connect(tryKey)
kcInput.FocusLost:Connect(function(enter) if enter then tryKey() end end)

-- ══════════════════════════════════════════════════════════
--   ГЛАВНЫЙ ХАБ
-- ══════════════════════════════════════════════════════════

showMain = function()

-- Иконка (перетаскиваемая)
local iconF = Instance.new("Frame", sg)
iconF.Size = UDim2.new(0,50,0,50)
iconF.Position = UDim2.new(1,-60,0.5,-25)
iconF.BackgroundColor3 = C.dgreen
iconF.BorderSizePixel  = 0
iconF.ZIndex           = 50
Instance.new("UICorner", iconF).CornerRadius = UDim.new(0,14)
Instance.new("UIStroke", iconF).Color = C.green
local iconLbl = Instance.new("TextLabel", iconF)
iconLbl.Size = UDim2.new(1,0,1,0) iconLbl.BackgroundTransparency = 1
iconLbl.Text = "🌱" iconLbl.TextSize = 28 iconLbl.Font = Enum.Font.GothamBlack iconLbl.ZIndex = 51

-- Пульс-точка
local dot = Instance.new("Frame", iconF)
dot.Size = UDim2.new(0,11,0,11) dot.Position = UDim2.new(1,-2,0,-2)
dot.BackgroundColor3 = C.green dot.BorderSizePixel = 0 dot.ZIndex = 52
Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
task.spawn(function()
    while sg and sg.Parent do
        tw(dot, 0.85, {BackgroundTransparency=0.75}) task.wait(0.85)
        tw(dot, 0.85, {BackgroundTransparency=0}) task.wait(0.85)
    end
end)

-- Drag иконки
local dragging, dragStart, startPos = false, nil, nil
iconF.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true dragStart = i.Position startPos = iconF.Position
    end
end)
iconF.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMove) then
        local d = i.Position - dragStart
        iconF.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- Главное окно
local W = Instance.new("Frame", sg)
W.Size               = UDim2.new(0.87,0,0.76,0)
W.Position           = UDim2.new(0.065,0,0.12,0)
W.BackgroundColor3   = C.bg
W.BorderSizePixel    = 0
W.Active             = true
W.Draggable          = true
W.ClipsDescendants   = true
W.Visible            = false
Instance.new("UICorner", W).CornerRadius = UDim.new(0,14)
Instance.new("UIStroke", W).Color = C.border

local guiOpen  = false
local tapStart = Vector2.zero
local tapTime  = 0

local function openGUI()
    guiOpen = true
    W.Visible  = true
    W.Size     = UDim2.new(0,0,0,0)
    W.Position = UDim2.new(0.5,0,0.5,0)
    TweenService:Create(W, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size     = UDim2.new(0.87,0,0.76,0),
        Position = UDim2.new(0.065,0,0.12,0),
    }):Play()
    tw(iconF, 0.2, {Size=UDim2.new(0,40,0,40)})
end

local function closeGUI()
    guiOpen = false
    TweenService:Create(W, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Size     = UDim2.new(0,0,0,0),
        Position = UDim2.new(0.5,0,0.5,0),
    }):Play()
    task.wait(0.25)
    W.Visible = false
    tw(iconF, 0.2, {Size=UDim2.new(0,50,0,50)})
end

iconF.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
        tapStart = Vector2.new(i.Position.X, i.Position.Y)
        tapTime  = tick()
    end
end)
iconF.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
        local moved = (Vector2.new(i.Position.X, i.Position.Y) - tapStart).Magnitude
        if moved < 10 and tick() - tapTime < 0.4 then
            if guiOpen then closeGUI() else openGUI() end
        end
    end
end)

-- ── ХЕДЕР ──────────────────────────────────────────────
local Hdr = Instance.new("Frame", W)
Hdr.Size = UDim2.new(1,0,0,48) Hdr.BackgroundColor3 = C.side Hdr.BorderSizePixel = 0
Instance.new("UICorner", Hdr).CornerRadius = UDim.new(0,14)
-- Заполнение нижних углов хедера
local hFill = Instance.new("Frame", Hdr)
hFill.Size = UDim2.new(1,0,0.5,0) hFill.Position = UDim2.new(0,0,0.5,0)
hFill.BackgroundColor3 = C.side hFill.BorderSizePixel = 0
-- Зелёная полоска
local hBar = Instance.new("Frame", Hdr)
hBar.Size = UDim2.new(1,0,0,2) hBar.BackgroundColor3 = C.green hBar.BorderSizePixel = 0
-- Иконка
local hIco = Instance.new("TextLabel", Hdr)
hIco.Size = UDim2.new(0,30,1,0) hIco.Position = UDim2.new(0,10,0,0)
hIco.BackgroundTransparency = 1 hIco.Text = "🌱" hIco.TextSize = 24 hIco.Font = Enum.Font.GothamBlack
-- Название
local hTitle = Instance.new("TextLabel", Hdr)
hTitle.Size = UDim2.new(0.6,0,0,25) hTitle.Position = UDim2.new(0,42,0.5,-12)
hTitle.BackgroundTransparency = 1 hTitle.Text = "PRIMEJTSU HUB"
hTitle.TextColor3 = C.green hTitle.Font = Enum.Font.GothamBlack hTitle.TextSize = 15
hTitle.TextXAlignment = Enum.TextXAlignment.Left
-- Подзаголовок
local hSub = Instance.new("TextLabel", Hdr)
hSub.Size = UDim2.new(0.7,0,0,13) hSub.Position = UDim2.new(0,42,1,-15)
hSub.BackgroundTransparency = 1 hSub.Text = "Garden Horizons  •  @Primejtsu"
hSub.TextColor3 = C.muted hSub.Font = Enum.Font.Code hSub.TextSize = 9
hSub.TextXAlignment = Enum.TextXAlignment.Left
-- Кнопка закрытия
local xBtn = Instance.new("TextButton", Hdr)
xBtn.Size = UDim2.new(0,28,0,28) xBtn.Position = UDim2.new(1,-36,0.5,-14)
xBtn.BackgroundColor3 = Color3.fromRGB(60,18,18) xBtn.Text = "✕"
xBtn.TextColor3 = C.white xBtn.Font = Enum.Font.GothamBold xBtn.TextSize = 13
xBtn.BorderSizePixel = 0
Instance.new("UICorner", xBtn).CornerRadius = UDim.new(0,7)
xBtn.MouseButton1Click:Connect(closeGUI)

-- ── BODY ───────────────────────────────────────────────
local Body = Instance.new("Frame", W)
Body.Size = UDim2.new(1,0,1,-48) Body.Position = UDim2.new(0,0,0,48)
Body.BackgroundColor3 = C.bg Body.BorderSizePixel = 0

-- Сайдбар
local SB = Instance.new("Frame", Body)
SB.Size = UDim2.new(0,90,1,0) SB.BackgroundColor3 = C.side SB.BorderSizePixel = 0
-- Разделитель
local sdiv = Instance.new("Frame", Body)
sdiv.Size = UDim2.new(0,1,1,0) sdiv.Position = UDim2.new(0,90,0,0)
sdiv.BackgroundColor3 = C.border sdiv.BorderSizePixel = 0

-- Контент
local CT = Instance.new("ScrollingFrame", Body)
CT.Size = UDim2.new(1,-91,1,-42) CT.Position = UDim2.new(0,91,0,0)
CT.BackgroundColor3 = C.bg CT.BorderSizePixel = 0
CT.ScrollBarThickness = 0 CT.CanvasSize = UDim2.new(0,0,0,0)
CT.ScrollingDirection = Enum.ScrollingDirection.Y CT.ScrollingEnabled = true

local CTL = Instance.new("UIListLayout", CT)
CTL.Padding = UDim.new(0,5) CTL.SortOrder = Enum.SortOrder.LayoutOrder
local CTP = Instance.new("UIPadding", CT)
CTP.PaddingLeft = UDim.new(0,10) CTP.PaddingRight = UDim.new(0,10)
CTP.PaddingTop  = UDim.new(0,8)  CTP.PaddingBottom = UDim.new(0,8)
CTL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    CT.CanvasSize = UDim2.new(0,0,0,CTL.AbsoluteContentSize.Y+16)
end)

-- Свайп-скролл пальцем
local swipeStart = nil local swipeCanvas = 0
CT.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch then
        swipeStart = i.Position.Y swipeCanvas = CT.CanvasPosition.Y
    end
end)
CT.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch and swipeStart then
        local mx = math.max(0, CT.AbsoluteCanvasSize.Y - CT.AbsoluteSize.Y)
        CT.CanvasPosition = Vector2.new(0, math.clamp(swipeCanvas + (swipeStart - i.Position.Y), 0, mx))
    end
end)
CT.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch then swipeStart = nil end
end)

-- Кнопки ▲▼
local ScrBar = Instance.new("Frame", Body)
ScrBar.Size = UDim2.new(1,-91,0,40) ScrBar.Position = UDim2.new(0,91,1,-40)
ScrBar.BackgroundColor3 = C.side ScrBar.BorderSizePixel = 0
local scrTop = Instance.new("Frame", ScrBar)
scrTop.Size = UDim2.new(1,0,0,1) scrTop.BackgroundColor3 = C.border scrTop.BorderSizePixel = 0
local bU = Instance.new("TextButton", ScrBar)
bU.Size = UDim2.new(0.5,-0.5,1,0) bU.BackgroundColor3 = C.side bU.BorderSizePixel = 0
bU.Text = "▲" bU.TextColor3 = C.green bU.Font = Enum.Font.GothamBlack bU.TextSize = 20
local bDiv = Instance.new("Frame", ScrBar)
bDiv.Size = UDim2.new(0,1,1,0) bDiv.Position = UDim2.new(0.5,0,0,0)
bDiv.BackgroundColor3 = C.border bDiv.BorderSizePixel = 0
local bD = Instance.new("TextButton", ScrBar)
bD.Size = UDim2.new(0.5,-0.5,1,0) bD.Position = UDim2.new(0.5,1,0,0)
bD.BackgroundColor3 = C.side bD.BorderSizePixel = 0
bD.Text = "▼" bD.TextColor3 = C.white bD.Font = Enum.Font.GothamBlack bD.TextSize = 20

local scrolling = false
local function doScroll(dir)
    task.spawn(function()
        while scrolling do
            local mx = math.max(0, CT.AbsoluteCanvasSize.Y - CT.AbsoluteSize.Y)
            CT.CanvasPosition = Vector2.new(0, math.clamp(CT.CanvasPosition.Y + dir*28, 0, mx))
            task.wait(0.045)
        end
    end)
end
bU.MouseButton1Down:Connect(function() scrolling=true tw(bU,0.1,{BackgroundColor3=C.dim}) doScroll(-1) end)
bD.MouseButton1Down:Connect(function() scrolling=true tw(bD,0.1,{BackgroundColor3=C.dim}) doScroll(1) end)
bU.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then scrolling=false tw(bU,0.1,{BackgroundColor3=C.side}) end end)
bD.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then scrolling=false tw(bD,0.1,{BackgroundColor3=C.side}) end end)

-- ── ТАБЫ ───────────────────────────────────────────────
local tabContent = {} local tabBtns = {}
local TABS = {"Info","Player","Farm","Sell","Misc"}
for _, n in ipairs(TABS) do tabContent[n] = {} end

local sbLayout = Instance.new("UIListLayout", SB) sbLayout.Padding = UDim.new(0,0)
Instance.new("UIPadding", SB).PaddingTop = UDim.new(0,6)

local tabIcons = {Info="ℹ",Player="🏃",Farm="🌾",Sell="💰",Misc="⚙"}

local function makeSideBtn(label, icon)
    local b = Instance.new("TextButton", SB)
    b.Size = UDim2.new(1,0,0,56) b.BackgroundTransparency = 1 b.Text = "" b.BorderSizePixel = 0
    local actDot = Instance.new("Frame", b)
    actDot.Size = UDim2.new(0,3,0,26) actDot.Position = UDim2.new(0,0,0.5,-13)
    actDot.BackgroundColor3 = C.green actDot.BorderSizePixel = 0 actDot.Visible = false
    Instance.new("UICorner", actDot).CornerRadius = UDim.new(1,0)
    local ico = Instance.new("TextLabel", b)
    ico.Size = UDim2.new(1,0,0,26) ico.Position = UDim2.new(0,0,0,8)
    ico.BackgroundTransparency = 1 ico.Text = icon ico.TextColor3 = C.muted
    ico.Font = Enum.Font.Gotham ico.TextSize = 20
    local lbl = Instance.new("TextLabel", b)
    lbl.Size = UDim2.new(1,0,0,16) lbl.Position = UDim2.new(0,0,0,34)
    lbl.BackgroundTransparency = 1 lbl.Text = label lbl.TextColor3 = C.muted
    lbl.Font = Enum.Font.GothamBold lbl.TextSize = 9 lbl.TextXAlignment = Enum.TextXAlignment.Center
    tabBtns[label] = {dot=actDot, lbl=lbl, ico=ico}
    return b
end

local curFrames = {}
local function switchTab(name)
    for _, f in ipairs(curFrames) do f.Parent = nil end curFrames = {}
    for k, t in pairs(tabBtns) do
        t.dot.Visible = false t.lbl.TextColor3 = C.muted t.ico.TextColor3 = C.muted
    end
    if tabBtns[name] then
        tabBtns[name].dot.Visible   = true
        tabBtns[name].lbl.TextColor3 = C.white
        tabBtns[name].ico.TextColor3 = C.green
    end
    if tabContent[name] then
        for _, f in ipairs(tabContent[name]) do
            f.Parent = CT table.insert(curFrames, f)
        end
    end
    task.wait()
    CT.CanvasSize = UDim2.new(0,0,0,CTL.AbsoluteContentSize.Y+16)
    CT.CanvasPosition = Vector2.new(0,0)
end
for _, n in ipairs(TABS) do
    local b = makeSideBtn(n, tabIcons[n])
    local nn = n
    b.MouseButton1Click:Connect(function() switchTab(nn) end)
end

-- ── UI КОМПОНЕНТЫ ──────────────────────────────────────

local function mkSection(tab, title)
    local f = Instance.new("Frame") f.Size = UDim2.new(1,0,0,22) f.BackgroundTransparency = 1 f.BorderSizePixel = 0
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1,0,1,0) l.BackgroundTransparency = 1 l.Text = title
    l.TextColor3 = Color3.fromRGB(68,148,68) l.Font = Enum.Font.GothamBold l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    local line = Instance.new("Frame", f)
    line.Size = UDim2.new(1,0,0,1) line.Position = UDim2.new(0,0,1,-1)
    line.BackgroundColor3 = C.border line.BorderSizePixel = 0
    table.insert(tabContent[tab], f)
end

local function mkToggle(tab, title, cfgKey, onFn)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,44) f.BackgroundColor3 = C.card f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,9)
    Instance.new("UIStroke", f).Color = C.border
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1,-60,1,0) lbl.Position = UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency = 1 lbl.Text = title
    lbl.TextColor3 = C.white lbl.Font = Enum.Font.Gotham lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    local track = Instance.new("Frame", f)
    track.Size = UDim2.new(0,42,0,23) track.Position = UDim2.new(1,-50,0.5,-11.5)
    track.BackgroundColor3 = C.dim track.BorderSizePixel = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)
    local circle = Instance.new("Frame", track)
    circle.Size = UDim2.new(0,17,0,17) circle.Position = UDim2.new(0,3,0.5,-8.5)
    circle.BackgroundColor3 = C.muted circle.BorderSizePixel = 0
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1,0)
    local btn = Instance.new("TextButton", track)
    btn.Size = UDim2.new(1,0,1,0) btn.BackgroundTransparency = 1 btn.Text = ""
    local on = false
    btn.MouseButton1Click:Connect(function()
        on = not on
        local ti = TweenInfo.new(0.17)
        if on then
            TweenService:Create(track, ti, {BackgroundColor3=C.green}):Play()
            TweenService:Create(circle, ti, {Position=UDim2.new(0,23,0.5,-8.5), BackgroundColor3=C.white}):Play()
            -- Анимация карточки при включении
            TweenService:Create(f, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(18,35,18)}):Play()
            task.spawn(function() task.wait(0.2) TweenService:Create(f, TweenInfo.new(0.2), {BackgroundColor3=C.card}):Play() end)
        else
            TweenService:Create(track, ti, {BackgroundColor3=C.dim}):Play()
            TweenService:Create(circle, ti, {Position=UDim2.new(0,3,0.5,-8.5), BackgroundColor3=C.muted}):Play()
        end
        if cfgKey then CFG[cfgKey] = on end
        if onFn then onFn(on) end
    end)
    table.insert(tabContent[tab], f)
end

local function mkButton(tab, title, col, fn)
    local bc = col or C.dim
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,44) f.BackgroundColor3 = bc f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,9)
    Instance.new("UIStroke", f).Color = C.border
    local b = Instance.new("TextButton", f)
    b.Size = UDim2.new(1,0,1,0) b.BackgroundTransparency = 1 b.Text = title
    b.TextColor3 = C.white b.Font = Enum.Font.GothamBold b.TextSize = 12 b.BorderSizePixel = 0
    b.MouseEnter:Connect(function() tw(f,0.1,{BackgroundColor3=Color3.fromRGB(bc.R*300,bc.G*300+15,bc.B*300)}) end)
    b.MouseLeave:Connect(function() tw(f,0.1,{BackgroundColor3=bc}) end)
    b.MouseButton1Click:Connect(function()
        TweenService:Create(f, TweenInfo.new(0.1), {BackgroundColor3=C.green}):Play()
        task.wait(0.18)
        TweenService:Create(f, TweenInfo.new(0.15), {BackgroundColor3=bc}):Play()
        if fn then pcall(fn) end
    end)
    table.insert(tabContent[tab], f)
end

-- Карточка с фруктом (для таба Sell)
local function mkFruitBtn(tab, emoji, name, col)
    local bc = col or C.card
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0.48,0,0,50) f.BackgroundColor3 = bc f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,9)
    Instance.new("UIStroke", f).Color = C.border
    local icoL = Instance.new("TextLabel", f)
    icoL.Size = UDim2.new(0,36,1,0) icoL.BackgroundTransparency = 1
    icoL.Text = emoji icoL.TextSize = 26 icoL.Font = Enum.Font.GothamBlack
    local nameL = Instance.new("TextLabel", f)
    nameL.Size = UDim2.new(1,-38,0,20) nameL.Position = UDim2.new(0,36,0.5,-18)
    nameL.BackgroundTransparency = 1 nameL.Text = name
    nameL.TextColor3 = C.white nameL.Font = Enum.Font.GothamBold nameL.TextSize = 12
    nameL.TextXAlignment = Enum.TextXAlignment.Left
    local sellL = Instance.new("TextLabel", f)
    sellL.Size = UDim2.new(1,-38,0,14) sellL.Position = UDim2.new(0,36,0.5,2)
    sellL.BackgroundTransparency = 1 sellL.Text = "Продать 🌀"
    sellL.TextColor3 = C.muted sellL.Font = Enum.Font.Code sellL.TextSize = 10
    sellL.TextXAlignment = Enum.TextXAlignment.Left
    -- Кнопка продажи
    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(1,0,1,0) btn.BackgroundTransparency = 1 btn.Text = ""
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(f, TweenInfo.new(0.1), {BackgroundColor3=C.green}):Play()
        task.wait(0.2)
        TweenService:Create(f, TweenInfo.new(0.15), {BackgroundColor3=bc}):Play()
        -- Ищем конкретный фрукт и продаём
        task.spawn(function()
            local hrp = getHRP() local hum = getHum()
            if not hrp or not hum then return end
            -- Ищем объект с именем фрукта
            for _, obj in ipairs(workspace:GetDescendants()) do
                pcall(function()
                    if obj.Name:lower():find(name:lower()) and obj.Parent ~= LP.Character then
                        local pos = getPos(obj)
                        if pos then
                            hum.WalkSpeed = 50
                            hum:MoveTo(pos)
                            local t0 = tick()
                            repeat task.wait(0.07) until (hrp.Position-pos).Magnitude<5 or tick()-t0>4
                            -- Fire промпты рядом
                            for _, o in ipairs(workspace:GetDescendants()) do
                                pcall(function()
                                    if o:IsA("ProximityPrompt") then
                                        local p = o.Parent
                                        if p and p:IsA("BasePart") and (p.Position-hrp.Position).Magnitude<10 then
                                            fireproximityprompt(o)
                                        end
                                    end
                                end)
                            end
                            harvestCount = harvestCount + 1
                        end
                    end
                end)
            end
            -- Идём продавать
            local pts = getSellPoints()
            if #pts > 0 then
                local p = pts[1]
                hum:MoveTo(p.pos)
                local t0 = tick()
                repeat task.wait(0.1) until (hrp.Position-p.pos).Magnitude<8 or tick()-t0>6
                for _, pr in ipairs(getPrompts(p.obj)) do pcall(function() fireproximityprompt(pr) end) end
                sellCount = sellCount + 1
                notify("💰 Продано","Продал "..emoji.." "..name.."!",3)
            end
        end)
    end)
    table.insert(tabContent[tab], f)
end

-- ── ВКЛАДКА INFO ───────────────────────────────────────
mkSection("Info","🌿 О хабе")
-- Карточка о хабе
local ic = Instance.new("Frame") ic.Size = UDim2.new(1,0,0,92) ic.BackgroundColor3 = C.card ic.BorderSizePixel = 0
Instance.new("UICorner",ic).CornerRadius=UDim.new(0,9) Instance.new("UIStroke",ic).Color=C.border
local icBar=Instance.new("Frame",ic) icBar.Size=UDim2.new(1,0,0,2) icBar.BackgroundColor3=C.green icBar.BorderSizePixel=0
local icI=Instance.new("TextLabel",ic) icI.Size=UDim2.new(0,52,0,55) icI.Position=UDim2.new(0,10,0.5,-27) icI.BackgroundTransparency=1 icI.Text="🌱" icI.TextSize=46 icI.Font=Enum.Font.GothamBlack
local icN1=Instance.new("TextLabel",ic) icN1.Size=UDim2.new(1,-70,0,22) icN1.Position=UDim2.new(0,64,0,12) icN1.BackgroundTransparency=1 icN1.Text="Primejtsu Hub" icN1.TextColor3=C.green icN1.Font=Enum.Font.GothamBlack icN1.TextSize=18 icN1.TextXAlignment=Enum.TextXAlignment.Left
local icN2=Instance.new("TextLabel",ic) icN2.Size=UDim2.new(1,-70,0,14) icN2.Position=UDim2.new(0,64,0,36) icN2.BackgroundTransparency=1 icN2.Text="🌿 Garden Horizons" icN2.TextColor3=C.muted icN2.Font=Enum.Font.Code icN2.TextSize=12 icN2.TextXAlignment=Enum.TextXAlignment.Left
local icN3=Instance.new("TextLabel",ic) icN3.Size=UDim2.new(1,-70,0,13) icN3.Position=UDim2.new(0,64,0,51) icN3.BackgroundTransparency=1 icN3.Text="✈ @Primejtsu | Nazar513000" icN3.TextColor3=Color3.fromRGB(50,150,220) icN3.Font=Enum.Font.Code icN3.TextSize=11 icN3.TextXAlignment=Enum.TextXAlignment.Left
local icN4=Instance.new("TextLabel",ic) icN4.Size=UDim2.new(1,0,0,14) icN4.Position=UDim2.new(0,10,1,-17) icN4.BackgroundTransparency=1 icN4.Text="v3.0  •  🔑 Ключ: Primejtsu" icN4.TextColor3=Color3.fromRGB(38,95,38) icN4.Font=Enum.Font.Code icN4.TextSize=10 icN4.TextXAlignment=Enum.TextXAlignment.Left
table.insert(tabContent["Info"],ic)

mkSection("Info","📊 Статистика сессии")
local statF = Instance.new("Frame") statF.Size=UDim2.new(1,0,0,65) statF.BackgroundColor3=C.card statF.BorderSizePixel=0
Instance.new("UICorner",statF).CornerRadius=UDim.new(0,9) Instance.new("UIStroke",statF).Color=C.border
local stH=Instance.new("TextLabel",statF) stH.Size=UDim2.new(0.5,0,0.5,0) stH.Position=UDim2.new(0,10,0,8) stH.BackgroundTransparency=1 stH.Text="🌾 Собрано: 0" stH.TextColor3=C.lgreen stH.Font=Enum.Font.GothamBold stH.TextSize=12 stH.TextXAlignment=Enum.TextXAlignment.Left
local stS=Instance.new("TextLabel",statF) stS.Size=UDim2.new(0.5,0,0.5,0) stS.Position=UDim2.new(0.5,0,0,8) stS.BackgroundTransparency=1 stS.Text="💰 Продаж: 0" stS.TextColor3=C.gold stS.Font=Enum.Font.GothamBold stS.TextSize=12 stS.TextXAlignment=Enum.TextXAlignment.Left
local stT=Instance.new("TextLabel",statF) stT.Size=UDim2.new(1,-10,0,16) stT.Position=UDim2.new(0,10,0.5,2) stT.BackgroundTransparency=1 stT.Text="⏱ Время: 0 мин" stT.TextColor3=C.muted stT.Font=Enum.Font.Code stT.TextSize=11 stT.TextXAlignment=Enum.TextXAlignment.Left
table.insert(tabContent["Info"],statF)
-- Обновление статистики
local sessionStart = tick()
RunService.Heartbeat:Connect(function()
    if stH and stH.Parent then stH.Text = "🌾 Собрано: "..harvestCount end
    if stS and stS.Parent then stS.Text = "💰 Продаж: "..sellCount end
    if stT and stT.Parent then
        local mins = math.floor((tick()-sessionStart)/60)
        local secs = math.floor((tick()-sessionStart)%60)
        stT.Text = "⏱ Время: "..mins.."м "..secs.."с"
    end
end)

-- ── ВКЛАДКА PLAYER ─────────────────────────────────────
mkSection("Player","🏃 Движение")
mkToggle("Player","⚡ Speed Hack (×2)","speed")
mkToggle("Player","🦅 Fly (WASD + E/Q)","fly",function(v) if v then startFly() else stopFly() end end)
mkToggle("Player","👻 Noclip","noclip")
mkToggle("Player","🐇 Infinite Jump","infiniteJump")
mkSection("Player","⚡ Действия")
mkButton("Player","🚀 Запустить вверх",C.dim,function()
    local hrp=getHRP() if hrp then hrp.Velocity=Vector3.new(0,115,0) end
end)
mkButton("Player","🔄 Respawn",C.dim,function() LP:LoadCharacter() end)
mkButton("Player","🌀 TP к случайному игроку",C.dim,function()
    local hrp=getHRP() if not hrp then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Character then
            local t=p.Character:FindFirstChild("HumanoidRootPart")
            if t then hrp.CFrame=t.CFrame+Vector3.new(3,3,0) notify("📍 TP","К игроку: "..p.Name,2) return end
        end
    end
end)

-- ── ВКЛАДКА FARM ───────────────────────────────────────
mkSection("Farm","🌾 Авто-фарм")
mkToggle("Farm","🍎 Авто Собирать урожай","autoHarvest")
mkToggle("Farm","🌱 Авто Сажать семена","autoPlant")
mkSection("Farm","⚡ Быстрые действия")
mkButton("Farm","🍎 Собрать всё сейчас",Color3.fromRGB(16,48,16),function()
    task.spawn(function()
        local hrp=getHRP() local hum=getHum() if not hrp or not hum then return end
        hum.WalkSpeed = 55
        local fruits = getFruits()
        local n = 0
        for _, f in ipairs(fruits) do
            if not f.obj or not f.obj.Parent then continue end
            harvestAt(f.pos)
            n = n + 1
            harvestCount = harvestCount + 1
            task.wait(0.1)
        end
        hum.WalkSpeed = 16
        notify("🌾 Готово","Собрано: "..n.." штук!",3)
    end)
end)
mkButton("Farm","📍 TP к ближайшему урожаю",C.dim,function()
    local hrp=getHRP() if not hrp then return end
    local fruits=getFruits()
    if #fruits==0 then notify("❌","Урожай не найден",2) return end
    local best,bd=nil,math.huge
    for _,f in ipairs(fruits) do local d=(hrp.Position-f.pos).Magnitude if d<bd then bd=d best=f end end
    if best then hrp.CFrame=CFrame.new(best.pos+Vector3.new(0,4,0)) notify("📍 TP","К урожаю!",2) end
end)
mkSection("Farm","😴 АФК-фарм")
mkToggle("Farm","💤 Anti AFK","antiAfk")

-- ── ВКЛАДКА SELL — ФРУКТЫ ──────────────────────────────
mkSection("Sell","💰 Авто-продажа")
mkToggle("Sell","💰 Авто Продавать всё","autoSell")
mkButton("Sell","💰 Продать всё СЕЙЧАС",Color3.fromRGB(12,42,22),function()
    task.spawn(function()
        local hrp=getHRP() local hum=getHum() if not hrp or not hum then return end
        local pts=getSellPoints()
        if #pts==0 then notify("❌","Магазин не найден!",3) return end
        hum.WalkSpeed=55
        local pt=pts[1]
        hum:MoveTo(pt.pos)
        local t0=tick()
        repeat task.wait(0.1) until (hrp.Position-pt.pos).Magnitude<8 or tick()-t0>8
        task.wait(0.15)
        for _,pr in ipairs(getPrompts(pt.obj)) do pcall(function() fireproximityprompt(pr) end) end
        for _,obj in ipairs(workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("ProximityPrompt") then
                    local p=obj.Parent if p and p:IsA("BasePart") and (p.Position-hrp.Position).Magnitude<12 then fireproximityprompt(obj) end
                end
            end)
        end
        for _,g in ipairs(LP.PlayerGui:GetDescendants()) do
            pcall(function()
                if g:IsA("TextButton") and g.Visible then
                    local t=g.Text:lower()
                    if t:find("sell") or t:find("confirm") or t:find("ok") then g.MouseButton1Click:Fire() end
                end
            end)
        end
        sellCount=sellCount+1 hum.WalkSpeed=16
        notify("💰 Продано","Всё продано!",3)
    end)
end)

mkSection("Sell","🍎 Фрукты — выбери и продай")

-- Грид для фруктов
local fruitGrid=Instance.new("Frame")
fruitGrid.Size=UDim2.new(1,0,0,0) fruitGrid.BackgroundTransparency=1 fruitGrid.BorderSizePixel=0
fruitGrid.AutomaticSize=Enum.AutomaticSize.Y
local gl=Instance.new("UIGridLayout",fruitGrid)
gl.CellSize=UDim2.new(0.48,0,0,50) gl.CellPaddingSize=UDim2.new(0.04,0,0,5)
gl.SortOrder=Enum.SortOrder.LayoutOrder
table.insert(tabContent["Sell"],fruitGrid)

-- Список фруктов с эмодзи
local FRUIT_LIST = {
    {"🍎","Apple"},   {"🥕","Carrot"},   {"🌽","Corn"},     {"🧅","Onion"},
    {"🍓","Strawberry"},{"🍄","Mushroom"},{"🟣","Beetroot"},{"🍅","Tomato"},
    {"🌹","Rose"},    {"🌾","Wheat"},     {"🍌","Banana"},   {"🫐","Plum"},
    {"🥔","Potato"},  {"🥬","Cabbage"},   {"🍒","Cherry"},   {"🍉","Watermelon"},
    {"🎃","Pumpkin"}, {"🍇","Grape"},     {"🍋","Lemon"},    {"🍊","Orange"},
    {"🍑","Peach"},   {"🍐","Pear"},      {"🫐","Blueberry"},{"🌻","Sunflower"},
}

for i, data in ipairs(FRUIT_LIST) do
    local emoji, name = data[1], data[2]
    local bc = (i%2==0) and Color3.fromRGB(15,28,15) or Color3.fromRGB(18,33,18)
    local f = Instance.new("Frame", fruitGrid)
    f.Size = UDim2.new(1,0,0,50) f.BackgroundColor3 = bc f.BorderSizePixel = 0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,9)
    Instance.new("UIStroke",f).Color=C.border
    local eL = Instance.new("TextLabel",f) eL.Size=UDim2.new(0,34,1,0) eL.BackgroundTransparency=1 eL.Text=emoji eL.TextSize=24 eL.Font=Enum.Font.GothamBlack
    local nL = Instance.new("TextLabel",f) nL.Size=UDim2.new(1,-36,0,20) nL.Position=UDim2.new(0,36,0,6) nL.BackgroundTransparency=1 nL.Text=name nL.TextColor3=C.white nL.Font=Enum.Font.GothamBold nL.TextSize=11 nL.TextXAlignment=Enum.TextXAlignment.Left
    local sL = Instance.new("TextLabel",f) sL.Size=UDim2.new(1,-36,0,14) sL.Position=UDim2.new(0,36,0,27) sL.BackgroundTransparency=1 sL.Text="Tap → собрать+продать" sL.TextColor3=C.muted sL.Font=Enum.Font.Code sL.TextSize=9 sL.TextXAlignment=Enum.TextXAlignment.Left
    local btn=Instance.new("TextButton",f) btn.Size=UDim2.new(1,0,1,0) btn.BackgroundTransparency=1 btn.Text=""
    local capName=name
    local capEmoji=emoji
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(f,TweenInfo.new(0.1),{BackgroundColor3=C.green}):Play()
        task.wait(0.2)
        TweenService:Create(f,TweenInfo.new(0.2),{BackgroundColor3=bc}):Play()
        task.spawn(function()
            local hrp=getHRP() local hum=getHum() if not hrp or not hum then return end
            -- Ищем этот фрукт
            local found=false
            for _,obj in ipairs(workspace:GetDescendants()) do
                pcall(function()
                    if obj.Name:lower():find(capName:lower()) and obj.Parent~=LP.Character then
                        local pos=getPos(obj)
                        if pos then
                            hum.WalkSpeed=50 hum:MoveTo(pos)
                            local t0=tick() repeat task.wait(0.07) until (hrp.Position-pos).Magnitude<5 or tick()-t0>5
                            for _,o in ipairs(workspace:GetDescendants()) do
                                pcall(function()
                                    if o:IsA("ProximityPrompt") then
                                        local p=o.Parent if p and p:IsA("BasePart") and (p.Position-hrp.Position).Magnitude<10 then fireproximityprompt(o) end
                                    end
                                    if o:IsA("ClickDetector") then
                                        local p=o.Parent if p and p:IsA("BasePart") and (p.Position-hrp.Position).Magnitude<10 then fireclickdetector(o) end
                                    end
                                end)
                            end
                            harvestCount=harvestCount+1 found=true
                        end
                    end
                end)
                if found then break end
            end
            -- Продаём
            local pts=getSellPoints()
            if #pts>0 then
                local pt=pts[1] hum:MoveTo(pt.pos)
                local t0=tick() repeat task.wait(0.1) until (hrp.Position-pt.pos).Magnitude<8 or tick()-t0>6
                for _,pr in ipairs(getPrompts(pt.obj)) do pcall(function() fireproximityprompt(pr) end) end
                sellCount=sellCount+1
            end
            hum.WalkSpeed=16
            notify("💰 "..capEmoji.." "..capName, found and "Собрано и продано!" or "Не найдено на карте",3)
        end)
    end)
end

-- ── ВКЛАДКА MISC ───────────────────────────────────────
mkSection("Misc","⚙ Настройки")
mkToggle("Misc","☀ Fullbright (день)",nil,function(v) setFB(v) end)
mkToggle("Misc","👁 ESP игроков","esp")
mkToggle("Misc","👻 Скрыть персонажа",nil,function(v)
    pcall(function()
        local c=getChar() if not c then return end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") or p:IsA("Decal") then p.LocalTransparencyModifier = v and 1 or 0 end
        end
    end)
end)
mkSection("Misc","🌐 Сервер")
mkButton("Misc","🔄 Сменить сервер",C.dim,function()
    local attempts=0
    repeat
        local id=nil
        for _,s in ipairs(game:GetService("TeleportService"):GetTeleportSetting("servers") or {}) do
            if s.playing<s.maxplayers then id=s.jobId break end
        end
        if id then
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, id, LP)
            break
        end
        attempts=attempts+1 task.wait(1)
    until attempts>=3
    if attempts>=3 then
        game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
    end
end)
mkButton("Misc","🔄 Reжоин (выйти-войти)",C.dim,function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
end)

-- Старт
task.wait(0.1)
switchTab("Info")
task.wait(0.35)
openGUI()
notify("✅ Primejtsu Hub","Garden Horizons v3.0 готов! 🌱",5)

end -- showMain

print("[Primejtsu Hub v3.0] Garden Horizons | @Primejtsu | Nazar513000 🌱")
