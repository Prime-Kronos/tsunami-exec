-- ╔══════════════════════════════════════════════════════════════╗
-- ║         PrimejTsuHub v6.0 | @Primejtsu | Nazar513000        ║
-- ║              Murder Mystery 2 | MEGA UPDATE                  ║
-- ║   CoinFarm v4 | ESP Pro | Trol v4 | Bypass v4 | Aimbot      ║
-- ╚══════════════════════════════════════════════════════════════╝

-- СЕРВИСЫ
local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local TweenService  = game:GetService("TweenService")
local UIS           = game:GetService("UserInputService")
local Lighting      = game:GetService("Lighting")
local HttpService   = game:GetService("HttpService")
local StarterGui    = game:GetService("StarterGui")
local CoreGui       = game:GetService("CoreGui")
local LP            = Players.LocalPlayer
local Camera        = workspace.CurrentCamera
local Mouse         = LP:GetMouse()

-- СОСТОЯНИЕ
local CFG = {
    -- Движение
    speed        = false,
    bhop         = false,
    noclip       = false,
    infiniteJump = false,
    fly          = false,
    -- Защита
    god          = false,
    antiKnock    = false,
    infAmmo      = false,
    -- Фарм
    coinFarm     = false,
    bringCoins   = false,
    autoReward   = false,
    knife        = false,
    -- Визуал
    esp          = false,
    chams        = false,
    fullbright   = false,
    tracers      = false,
    radarDot     = false,
    -- Байпас
    bypass       = false,
    antiAfk      = true,
    -- Скрытность
    hide         = false,
    -- Aimbot
    aimbot       = false,
    aimbotLocked = false,
    -- Trol
    follow       = false,
    block        = false,
    annoyMurd    = false,
    -- Misc
    noFog        = false,
    timeFreeze   = false,
    bigHead      = false,
    spinBot      = false,
    tpToMurd     = false,
}

local coinCount     = 0
local farmPaused    = false
local espObjects    = {}
local chamObjects   = {}
local tracerLines   = {}
local victimName    = "Никто"
local noclipWasOn   = false
local flyActive     = false
local flyBodyVel    = nil
local flyBodyGyro   = nil
local aimbotTarget  = nil
local spinConn      = nil
local radarConn     = nil

-- ХЕЛПЕРЫ
local function getChar()  return LP.Character end
local function getHRP()   local c=getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()   local c=getChar() return c and c:FindFirstChildOfClass("Humanoid") end
local function notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification",{Title=title,Text=text,Duration=dur or 3})
    end)
end
local function lerp(a,b,t) return a+(b-a)*t end

-- ════════════════════════════════════════════════════════════════
--   GOD MODE
-- ════════════════════════════════════════════════════════════════
local function applyGod(on)
    pcall(function()
        local h=getHum() if not h then return end
        if on then h.MaxHealth=1e6 h.Health=1e6 h.BreakJointsOnDeath=false end
    end)
end
RunService.Heartbeat:Connect(function()
    if not CFG.god then return end
    local h=getHum() if not h then return end
    if h.Health < h.MaxHealth then h.Health = h.MaxHealth end
    h.BreakJointsOnDeath = false
end)
LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    if CFG.god then applyGod(true) end
    if CFG.bigHead then
        pcall(function()
            local c=LP.Character
            if c then local head=c:FindFirstChild("Head") if head then head.Size=Vector3.new(4,4,4) end end
        end)
    end
end)

-- ════════════════════════════════════════════════════════════════
--   ANTI AFK
-- ════════════════════════════════════════════════════════════════
pcall(function()
    LP.Idled:Connect(function()
        if not CFG.antiAfk then return end
        local vu=game:GetService("VirtualUser")
        vu:Button2Down(Vector2.new(0,0),Camera.CFrame)
        task.wait(0.1)
        vu:Button2Up(Vector2.new(0,0),Camera.CFrame)
        local h=getHum() if h then h.Jump=true end
    end)
end)
task.spawn(function()
    while true do
        task.wait(55)
        if not CFG.antiAfk then continue end
        pcall(function()
            local vu=game:GetService("VirtualUser")
            vu:Button2Down(Vector2.new(0,0),Camera.CFrame)
            task.wait(0.1)
            vu:Button2Up(Vector2.new(0,0),Camera.CFrame)
            local h=getHum() if h then h.Jump=true end
        end)
    end
end)

-- ════════════════════════════════════════════════════════════════
--   SPEED / BHOP / INFINITE JUMP
-- ════════════════════════════════════════════════════════════════
UIS.JumpRequest:Connect(function()
    if CFG.infiniteJump then
        local h=getHum() if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)
RunService.Heartbeat:Connect(function()
    local h=getHum() if not h then return end
    if CFG.coinFarm then return end
    if CFG.speed then h.WalkSpeed=50
    elseif CFG.bhop then
        h.WalkSpeed=28
        if h.FloorMaterial~=Enum.Material.Air then h.Jump=true end
    else
        if h.WalkSpeed~=16 then h.WalkSpeed=16 end
    end
end)

-- ════════════════════════════════════════════════════════════════
--   FLY
-- ════════════════════════════════════════════════════════════════
local function enableFly(on)
    local hrp=getHRP()
    if on and hrp then
        flyActive=true
        local bv=Instance.new("BodyVelocity",hrp) bv.MaxForce=Vector3.new(1e5,1e5,1e5) bv.Velocity=Vector3.new(0,0,0) flyBodyVel=bv
        local bg=Instance.new("BodyGyro",hrp) bg.MaxTorque=Vector3.new(1e5,1e5,1e5) bg.D=500 flyBodyGyro=bg
        local h=getHum() if h then h.PlatformStand=true end
        task.spawn(function()
            while flyActive do
                task.wait()
                if not flyBodyVel or not flyBodyVel.Parent then break end
                local cf=Camera.CFrame
                local speed=30
                local vel=Vector3.new(0,0,0)
                if UIS:IsKeyDown(Enum.KeyCode.W) then vel=vel+cf.LookVector*speed end
                if UIS:IsKeyDown(Enum.KeyCode.S) then vel=vel-cf.LookVector*speed end
                if UIS:IsKeyDown(Enum.KeyCode.A) then vel=vel-cf.RightVector*speed end
                if UIS:IsKeyDown(Enum.KeyCode.D) then vel=vel+cf.RightVector*speed end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then vel=vel+Vector3.new(0,speed,0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then vel=vel-Vector3.new(0,speed,0) end
                flyBodyVel.Velocity=vel
                if flyBodyGyro then flyBodyGyro.CFrame=cf end
            end
        end)
    else
        flyActive=false
        if flyBodyVel then pcall(function() flyBodyVel:Destroy() end) flyBodyVel=nil end
        if flyBodyGyro then pcall(function() flyBodyGyro:Destroy() end) flyBodyGyro=nil end
        local h=getHum() if h then h.PlatformStand=false end
    end
end

-- ════════════════════════════════════════════════════════════════
--   NOCLIP v3
-- ════════════════════════════════════════════════════════════════
RunService.Stepped:Connect(function()
    if CFG.noclip then
        noclipWasOn=true
        local c=getChar() if not c then return end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=false end
        end
    elseif noclipWasOn then
        noclipWasOn=false
        pcall(function()
            local c=getChar() if not c then return end
            for _,p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
                    p.CanCollide=true
                end
            end
            local hrp=getHRP()
            if hrp and hrp.Position.Y < -30 then
                task.wait(0.1)
                hrp.CFrame=CFrame.new(hrp.Position.X, 15, hrp.Position.Z)
            end
        end)
    end
end)

-- ════════════════════════════════════════════════════════════════
--   COIN FARM v4 — ПОЛНЫЙ ПЕРЕПИСАН
--   Использует: firetouchinterest + fireclickdetector + MoveTo
--   Антикик: ближние монеты = бег, дальние = 2-шаговый телепорт
-- ════════════════════════════════════════════════════════════════
local function isCoin(o)
    if not o or not o.Parent then return false end
    if not(o:IsA("BasePart") or o:IsA("MeshPart") or o:IsA("UnionOperation")) then return false end
    if o.Transparency >= 0.85 then return false end
    if o.Parent == LP.Character then return false end
    local n = o.Name:lower()
    -- Все известные имена монет в MM2
    if n == "coin" then return true end
    if n == "dropcoin" then return true end
    if n == "goldcoin" then return true end
    if n == "silvercoin" then return true end
    if n == "coinpart" then return true end
    if n == "coin_part" then return true end
    if n == "coinmodel" then return true end
    -- Проверяем модели
    if o.Parent and o.Parent:IsA("Model") then
        local pn = o.Parent.Name:lower()
        if pn == "coin" or pn == "dropcoin" or pn == "goldcoin" or pn:find("coin") then
            return true
        end
    end
    return false
end

-- Попытка подобрать монету всеми методами
local function collectCoin(target, hrp)
    if not target or not target.Parent then return end
    pcall(function()
        -- Метод 1: firetouchinterest на саму монету
        firetouchinterest(hrp, target, 0)
        firetouchinterest(hrp, target, 1)
    end)
    pcall(function()
        -- Метод 2: fireclickdetector
        local cd = target:FindFirstChildOfClass("ClickDetector")
        if not cd and target.Parent then cd = target.Parent:FindFirstChildOfClass("ClickDetector") end
        if cd then fireclickdetector(cd) end
    end)
    pcall(function()
        -- Метод 3: все части родительской модели
        if target.Parent and target.Parent ~= workspace and target.Parent:IsA("Model") then
            for _,p in ipairs(target.Parent:GetDescendants()) do
                if p:IsA("BasePart") then
                    firetouchinterest(hrp, p, 0)
                    firetouchinterest(hrp, p, 1)
                end
            end
        end
    end)
end

-- Основной цикл фарма
task.spawn(function()
    while true do
        task.wait(0.05)
        if not CFG.coinFarm or farmPaused then continue end
        local hrp = getHRP()
        local hum = getHum()
        if not hrp or not hum or hum.Health <= 0 then continue end

        -- Ищем все монеты
        local coins = {}
        for _,o in ipairs(workspace:GetDescendants()) do
            if isCoin(o) then table.insert(coins, o) end
        end
        if #coins == 0 then task.wait(0.4) continue end

        -- Выбираем ближайшую
        local target, bestDist = nil, math.huge
        for _,c in ipairs(coins) do
            pcall(function()
                local d = (hrp.Position - c.Position).Magnitude
                if d < bestDist then bestDist = d target = c end
            end)
        end
        if not target or not target.Parent then continue end

        -- Сначала пробуем подобрать не двигаясь (если уже рядом)
        if bestDist < 6 then
            collectCoin(target, hrp)
            task.wait(0.05)
            continue
        end

        -- Далеко — двигаемся
        if bestDist > 60 then
            -- Очень далеко: телепорт в 2 шага чтобы не кикнул
            pcall(function()
                local mid = lerp(hrp.Position, target.Position, 0.5) + Vector3.new(0,4,0)
                hrp.CFrame = CFrame.new(mid)
            end)
            task.wait(0.12)
            pcall(function() hrp.CFrame = CFrame.new(target.Position + Vector3.new(0,2.5,0)) end)
        elseif bestDist > 20 then
            -- Средне: один телепорт
            pcall(function() hrp.CFrame = CFrame.new(target.Position + Vector3.new(0,2.5,0)) end)
        else
            -- Близко: бег (безопаснее всего)
            hum.WalkSpeed = 50
            pcall(function() hum:MoveTo(target.Position) end)
            local t0 = tick()
            repeat
                task.wait(0.04)
                if not CFG.coinFarm or hum.Health <= 0 then break end
                if not target or not target.Parent then break end
                collectCoin(target, hrp)
            until not target or not target.Parent
                or (hrp.Position - target.Position).Magnitude < 3
                or tick()-t0 > 2.5
            hum.WalkSpeed = 16
            continue
        end

        task.wait(0.05)
        -- Подбираем после телепорта
        for i = 1, 6 do
            if not target or not target.Parent then break end
            collectCoin(target, hrp)
            task.wait(0.04)
        end

        -- Пауза-имитация живого игрока
        task.wait(math.random(4,12)/100)
    end
end)

-- Bring Coins — притягивает монеты к себе
task.spawn(function()
    while true do
        task.wait(0.12)
        if not CFG.bringCoins or farmPaused then continue end
        local hrp = getHRP() if not hrp then continue end
        for _,o in ipairs(workspace:GetDescendants()) do
            if isCoin(o) then
                pcall(function() o.CFrame = hrp.CFrame + Vector3.new(math.random(-2,2),0,math.random(-2,2)) end)
            end
        end
    end
end)

-- Счётчик монет
task.spawn(function()
    local tracked = {}
    while task.wait(0.15) do
        if not CFG.coinFarm and not CFG.bringCoins then continue end
        for _,o in ipairs(workspace:GetDescendants()) do
            if isCoin(o) then tracked[o] = true end
        end
        for obj in pairs(tracked) do
            if not obj or not obj.Parent or obj.Transparency >= 0.85 then
                coinCount = coinCount + 1
                tracked[obj] = nil
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════════════
--   BYPASS v4 — АНТИКИК
-- ════════════════════════════════════════════════════════════════

-- Имитация движений мыши
task.spawn(function()
    while true do
        task.wait(math.random(8,18))
        if not CFG.bypass then continue end
        pcall(function()
            local vu = game:GetService("VirtualUser")
            local px, py = math.random(200,900), math.random(150,700)
            for _=1, math.random(2,5) do
                vu:MoveMouse(Vector2.new(px+math.random(-40,40), py+math.random(-40,40)))
                task.wait(math.random(1,3)/10)
            end
        end)
    end
end)

-- Случайные прыжки
task.spawn(function()
    while true do
        task.wait(math.random(20,40))
        if not CFG.bypass then continue end
        pcall(function() local h=getHum() if h then h.Jump=true end end)
    end
end)

-- Паузы фарма
task.spawn(function()
    while true do
        task.wait(math.random(30,60))
        if CFG.bypass and (CFG.coinFarm or CFG.bringCoins) then
            farmPaused = true
            task.wait(math.random(2,6))
            farmPaused = false
        end
    end
end)

-- Смена скорости
task.spawn(function()
    while true do
        task.wait(math.random(25,45))
        if not CFG.bypass then continue end
        pcall(function()
            local h=getHum() if not h then return end
            local s = h.WalkSpeed
            for _=1,3 do h.WalkSpeed=math.random(10,20) task.wait(0.3) end
            if not CFG.speed then h.WalkSpeed=s end
        end)
    end
end)

-- ════════════════════════════════════════════════════════════════
--   KNIFE AURA
-- ════════════════════════════════════════════════════════════════
task.spawn(function()
    while task.wait(0.35) do
        if not CFG.knife then continue end
        local hum=getHum() local hrp=getHRP()
        if not hum or not hrp then continue end
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP and p.Character then
                local t=p.Character:FindFirstChild("HumanoidRootPart")
                local th=p.Character:FindFirstChildOfClass("Humanoid")
                if t and th and th.Health>0 and (hrp.Position-t.Position).Magnitude<=16 then
                    hum:MoveTo(t.Position)
                end
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════════════
--   AUTO REWARD
-- ════════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    if not CFG.autoReward then return end
    pcall(function()
        for _,g in ipairs(LP.PlayerGui:GetDescendants()) do
            if g:IsA("TextButton") then
                local t=g.Text:lower()
                if t:find("play") or t:find("vote") or t:find("again") or t:find("ok") or t:find("ready") or t:find("skip") then
                    pcall(function() g.MouseButton1Click:Fire() end)
                end
            end
        end
    end)
end)

-- ════════════════════════════════════════════════════════════════
--   FULLBRIGHT / NO FOG / TIME FREEZE
-- ════════════════════════════════════════════════════════════════
local function setFB(v)
    if v then
        Lighting.Brightness=2.5 Lighting.ClockTime=14
        Lighting.GlobalShadows=false
        Lighting.Ambient=Color3.new(1,1,1)
        Lighting.OutdoorAmbient=Color3.new(1,1,1)
        for _,fx in ipairs(Lighting:GetChildren()) do
            if fx:IsA("BlurEffect") or fx:IsA("ColorCorrectionEffect") or fx:IsA("SunRaysEffect") then
                fx.Enabled=false
            end
        end
    else
        Lighting.Brightness=1 Lighting.GlobalShadows=true
        Lighting.Ambient=Color3.fromRGB(127,127,127)
        Lighting.OutdoorAmbient=Color3.fromRGB(127,127,127)
    end
end

local function setNoFog(v)
    pcall(function()
        local atmos = Lighting:FindFirstChildOfClass("Atmosphere")
        if atmos then atmos.Density = v and 0 or 0.395 end
        for _,fx in ipairs(Lighting:GetDescendants()) do
            if fx.ClassName=="DepthOfFieldEffect" then fx.Enabled=not v end
        end
    end)
end

-- ════════════════════════════════════════════════════════════════
--   ESP v2 — РАСШИРЕННЫЙ
-- ════════════════════════════════════════════════════════════════
local ROLE_COLORS={Murderer=Color3.fromRGB(255,50,50),Sheriff=Color3.fromRGB(50,130,255),Innocent=Color3.fromRGB(50,220,100)}
local ROLE_LABELS={Murderer="🔪 УБИЙЦА",Sheriff="🔫 ШЕРИФ",Innocent="😇 НЕВИННЫЙ"}

local function getRole(player)
    local role="Innocent"
    pcall(function()
        local char=player.Character if not char then return end
        local function checkTool(item)
            local n=item.Name:lower()
            if n:find("knife") or n:find("murder") or n:find("blade") then role="Murderer"
            elseif n:find("gun") or n:find("sheriff") or n:find("revolver") then role="Sheriff" end
        end
        for _,item in ipairs(char:GetChildren()) do if item:IsA("Tool") then checkTool(item) end end
        local bp=player:FindFirstChild("Backpack")
        if bp then for _,item in ipairs(bp:GetChildren()) do if item:IsA("Tool") then checkTool(item) end end end
    end)
    return role
end

local function removeESP(p)
    if espObjects[p] then pcall(function() espObjects[p]:Destroy() end) espObjects[p]=nil end
end

local function createESP(p)
    if p==LP then return end
    removeESP(p)
    local function setup(char)
        local hrp=char:WaitForChild("HumanoidRootPart",5)
        local hum=char:WaitForChild("Humanoid",5)
        if not hrp or not hum then return end

        local bb=Instance.new("BillboardGui")
        bb.Name="PTJESP" bb.AlwaysOnTop=true
        bb.Size=UDim2.new(0,140,0,80)
        bb.StudsOffset=Vector3.new(0,4,0)
        bb.Adornee=hrp bb.Parent=hrp bb.Enabled=false

        -- Фон
        local bg=Instance.new("Frame",bb)
        bg.Size=UDim2.new(1,0,1,0) bg.BackgroundColor3=Color3.fromRGB(5,5,8)
        bg.BackgroundTransparency=0.45 bg.BorderSizePixel=0
        Instance.new("UICorner",bg).CornerRadius=UDim.new(0,6)

        -- Имя
        local nL=Instance.new("TextLabel",bb)
        nL.Size=UDim2.new(1,0,0,22) nL.Position=UDim2.new(0,0,0,2)
        nL.BackgroundTransparency=1 nL.Font=Enum.Font.GothamBlack
        nL.TextSize=13 nL.Text=p.Name
        nL.TextStrokeTransparency=0 nL.TextStrokeColor3=Color3.new(0,0,0)

        -- Роль
        local rL=Instance.new("TextLabel",bb)
        rL.Size=UDim2.new(1,0,0,18) rL.Position=UDim2.new(0,0,0,24)
        rL.BackgroundTransparency=1 rL.Font=Enum.Font.GothamBold
        rL.TextSize=12 rL.TextStrokeTransparency=0
        rL.TextStrokeColor3=Color3.new(0,0,0)

        -- HP бар (визуально)
        local hpBg=Instance.new("Frame",bb)
        hpBg.Size=UDim2.new(0.85,0,0,5) hpBg.Position=UDim2.new(0.075,0,0,44)
        hpBg.BackgroundColor3=Color3.fromRGB(40,40,40) hpBg.BorderSizePixel=0
        Instance.new("UICorner",hpBg).CornerRadius=UDim.new(1,0)

        local hpBar=Instance.new("Frame",hpBg)
        hpBar.Size=UDim2.new(1,0,1,0) hpBar.BackgroundColor3=Color3.fromRGB(50,220,80)
        hpBar.BorderSizePixel=0
        Instance.new("UICorner",hpBar).CornerRadius=UDim.new(1,0)

        -- HP текст
        local hL=Instance.new("TextLabel",bb)
        hL.Size=UDim2.new(1,0,0,14) hL.Position=UDim2.new(0,0,0,50)
        hL.BackgroundTransparency=1 hL.Font=Enum.Font.Code
        hL.TextSize=11 hL.TextColor3=Color3.fromRGB(200,200,200)
        hL.TextStrokeTransparency=0 hL.TextStrokeColor3=Color3.new(0,0,0)

        -- Дистанция
        local dL=Instance.new("TextLabel",bb)
        dL.Size=UDim2.new(1,0,0,12) dL.Position=UDim2.new(0,0,0,65)
        dL.BackgroundTransparency=1 dL.Font=Enum.Font.Code
        dL.TextSize=10 dL.TextColor3=Color3.fromRGB(150,150,150)
        dL.TextStrokeTransparency=0 dL.TextStrokeColor3=Color3.new(0,0,0)

        local function upd()
            if not bb.Parent then return end
            local role=getRole(p)
            local col=ROLE_COLORS[role]
            nL.TextColor3=col
            rL.Text=ROLE_LABELS[role] rL.TextColor3=col
            local hp=math.max(0,math.min(100,math.floor(hum.Health/hum.MaxHealth*100)))
            hL.Text="❤ "..hp.."%"
            -- HP бар цвет
            local hpCol = hp>60 and Color3.fromRGB(50,220,80) or hp>30 and Color3.fromRGB(255,200,0) or Color3.fromRGB(255,50,50)
            hpBar.BackgroundColor3=hpCol
            hpBar.Size=UDim2.new(hp/100,0,1,0)
            local myH=getHRP()
            if myH then dL.Text="📍 "..math.floor((myH.Position-hrp.Position).Magnitude).."st" end
            bb.Enabled=CFG.esp
        end

        hum:GetPropertyChangedSignal("Health"):Connect(function() pcall(upd) end)
        char.ChildAdded:Connect(function(ch) if ch:IsA("Tool") then task.wait(0.2) pcall(upd) end end)
        char.ChildRemoved:Connect(function(ch) if ch:IsA("Tool") then task.wait(0.2) pcall(upd) end end)
        RunService.Heartbeat:Connect(function() if bb and bb.Parent then bb.Enabled=CFG.esp end end)
        task.spawn(function() while bb and bb.Parent do pcall(upd) task.wait(0.8) end end)
        espObjects[p]=bb
        pcall(upd)
    end
    if p.Character then task.spawn(function() setup(p.Character) end) end
    p.CharacterAdded:Connect(function(c) task.wait(1) task.spawn(function() setup(c) end) end)
end

for _,p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(function(p) task.wait(1) createESP(p) end)
Players.PlayerRemoving:Connect(function(p) removeESP(p) end)

-- ════════════════════════════════════════════════════════════════
--   CHAMS — подсвечивает игроков сквозь стены цветом
-- ════════════════════════════════════════════════════════════════
local function applyCham(p, on)
    if p == LP then return end
    pcall(function()
        if not p.Character then return end
        for _,part in ipairs(p.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name~="HumanoidRootPart" then
                if on then
                    local sel = Instance.new("SelectionBox", CoreGui)
                    sel.Adornee = part
                    sel.Color3 = ROLE_COLORS[getRole(p)] or Color3.fromRGB(255,255,0)
                    sel.SurfaceTransparency = 0.6
                    sel.LineThickness = 0.04
                    if not chamObjects[p] then chamObjects[p]={} end
                    table.insert(chamObjects[p], sel)
                end
            end
        end
    end)
end

local function removeCham(p)
    if chamObjects[p] then
        for _,s in ipairs(chamObjects[p]) do pcall(function() s:Destroy() end) end
        chamObjects[p]=nil
    end
end

RunService.Heartbeat:Connect(function()
    if not CFG.chams then
        for p in pairs(chamObjects) do removeCham(p) end
        return
    end
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Character and not chamObjects[p] then
            applyCham(p, true)
        end
    end
end)

-- ════════════════════════════════════════════════════════════════
--   TRACERS — линии от низа экрана до игроков
-- ════════════════════════════════════════════════════════════════
local tracerGui = Instance.new("ScreenGui", CoreGui)
tracerGui.Name = "PTHTracers" tracerGui.ResetOnSpawn=false tracerGui.Enabled=false

local tracerFrame = Instance.new("Frame", tracerGui)
tracerFrame.Size = UDim2.new(1,0,1,0) tracerFrame.BackgroundTransparency=1 tracerFrame.BorderSizePixel=0

local function updateTracers()
    for _,v in ipairs(tracerFrame:GetChildren()) do v:Destroy() end
    if not CFG.tracers then return end
    local camCF = Camera.CFrame
    local vp = Camera.ViewportSize
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Character then
            local hrp=p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local line=Instance.new("Frame", tracerFrame)
                    local sx = vp.X/2
                    local sy = vp.Y
                    local tx = pos.X
                    local ty = pos.Y
                    local dx = tx-sx local dy = ty-sy
                    local len = math.sqrt(dx*dx+dy*dy)
                    local angle = math.atan2(dy,dx)
                    line.Size=UDim2.new(0,len,0,2)
                    line.Position=UDim2.new(0,sx,0,sy)
                    line.Rotation=math.deg(angle)
                    line.AnchorPoint=Vector2.new(0,0.5)
                    line.BackgroundColor3=ROLE_COLORS[getRole(p)] or Color3.new(1,1,0)
                    line.BorderSizePixel=0
                    Instance.new("UICorner",line).CornerRadius=UDim.new(1,0)
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    tracerGui.Enabled = CFG.tracers
    if CFG.tracers then updateTracers() end
end)

-- ════════════════════════════════════════════════════════════════
--   AIMBOT — автоприцел на убийцу
-- ════════════════════════════════════════════════════════════════
local function getAimbotTarget()
    local hrp=getHRP() if not hrp then return nil end
    local bestDist=math.huge
    local best=nil
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Character then
            local th=p.Character:FindFirstChild("HumanoidRootPart")
            local hum=p.Character:FindFirstChildOfClass("Humanoid")
            if th and hum and hum.Health>0 then
                -- Приоритет: убийца первый
                local role=getRole(p)
                local d=(hrp.Position-th.Position).Magnitude
                local priorityDist = role=="Murderer" and d*0.5 or d
                if priorityDist < bestDist then
                    bestDist=priorityDist best=p
                end
            end
        end
    end
    return best
end

RunService.RenderStepped:Connect(function()
    if not CFG.aimbot then return end
    local target=getAimbotTarget()
    if not target or not target.Character then return end
    local head=target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
    if not head then return end
    local hrp=getHRP() if not hrp then return end
    -- Только поворот камеры к цели
    local dir=(head.Position-Camera.CFrame.Position).Unit
    Camera.CFrame=CFrame.lookAt(Camera.CFrame.Position, head.Position)
end)

-- ════════════════════════════════════════════════════════════════
--   SPIN BOT — вращение персонажа
-- ════════════════════════════════════════════════════════════════
local spinAngle=0
local function updateSpin()
    if not CFG.spinBot then return end
    local hrp=getHRP() if not hrp then return end
    spinAngle=spinAngle+8
    pcall(function()
        hrp.CFrame=CFrame.new(hrp.Position)*CFrame.Angles(0,math.rad(spinAngle),0)
    end)
end
RunService.Heartbeat:Connect(updateSpin)

-- ════════════════════════════════════════════════════════════════
--   INF AMMO — бесконечные патроны шерифа
-- ════════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    if not CFG.infAmmo then return end
    pcall(function()
        local c=getChar() if not c then return end
        for _,t in ipairs(c:GetChildren()) do
            if t:IsA("Tool") then
                local a=t:FindFirstChild("Ammo") if a then a.Value=999 end
                local a2=t:FindFirstChild("AmmoValue") if a2 then a2.Value=999 end
            end
        end
    end)
end)

-- ════════════════════════════════════════════════════════════════
--   ANTI KNOCK — неподвижный при ударе
-- ════════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    if not CFG.antiKnock then return end
    local hrp=getHRP() if not hrp then return end
    pcall(function()
        hrp.CustomPhysicalProperties=PhysicalProperties.new(0,0,0,0,0)
    end)
end)

-- ════════════════════════════════════════════════════════════════
--   BIG HEAD
-- ════════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    if not CFG.bigHead then return end
    pcall(function()
        local c=getChar() if not c then return end
        local head=c:FindFirstChild("Head")
        if head then head.Size=Vector3.new(4,4,4) end
    end)
end)

-- ════════════════════════════════════════════════════════════════
--   HIDE PLAYER
-- ════════════════════════════════════════════════════════════════
local function hidePlayer(v)
    pcall(function()
        local c=getChar() if not c then return end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") or p:IsA("Decal") then
                p.LocalTransparencyModifier=v and 1 or 0
            end
        end
    end)
end

-- ════════════════════════════════════════════════════════════════
--   TP К УБИЙЦЕ / ШЕРИФУ (с UI)
-- ════════════════════════════════════════════════════════════════
local function tpToRole(role)
    pcall(function()
        local hrp=getHRP() if not hrp then return end
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP and getRole(p)==role and p.Character then
                local t=p.Character:FindFirstChild("HumanoidRootPart")
                if t then hrp.CFrame=t.CFrame+Vector3.new(3,0,0) return end
            end
        end
        notify("TP","Роль '"..role.."' не найдена",2)
    end)
end

-- ════════════════════════════════════════════════════════════════
--   RADAR — мини-карта с точками игроков
-- ════════════════════════════════════════════════════════════════
-- (Будет создан в UI секции)

-- ════════════════════════════════════════════════════════════════
--   TROL v4 — ТРОЛЛИНГ
-- ════════════════════════════════════════════════════════════════
local followActive=false
local blockActive=false
local annoyMurdActive=false

-- Следить за жертвой
task.spawn(function()
    while true do task.wait(0.1)
        if not followActive then continue end
        pcall(function()
            local hrp=getHRP() if not hrp then return end
            for _,p in ipairs(Players:GetPlayers()) do
                if p.Name==victimName and p.Character then
                    local t=p.Character:FindFirstChild("HumanoidRootPart")
                    if t then hrp.CFrame=t.CFrame*CFrame.new(0,0,2.2) end
                end
            end
        end)
    end
end)

-- Блокировать путь
task.spawn(function()
    while true do task.wait(0.08)
        if not blockActive then continue end
        pcall(function()
            local hrp=getHRP() if not hrp then return end
            for _,p in ipairs(Players:GetPlayers()) do
                if p.Name==victimName and p.Character then
                    local t=p.Character:FindFirstChild("HumanoidRootPart")
                    if t then
                        local dir=t.CFrame.LookVector
                        hrp.CFrame=CFrame.new(t.Position+dir*2.5,t.Position)
                    end
                end
            end
        end)
    end
end)

-- Мешать убийце
task.spawn(function()
    while true do task.wait(0.4)
        if not annoyMurdActive then continue end
        pcall(function()
            local hrp=getHRP() if not hrp then return end
            for _,p in ipairs(Players:GetPlayers()) do
                if p~=LP and getRole(p)=="Murderer" and p.Character then
                    local t=p.Character:FindFirstChild("HumanoidRootPart")
                    if t then hrp.CFrame=t.CFrame*CFrame.new(0,0,1) end
                end
            end
        end)
    end
end)

-- ════════════════════════════════════════════════════════════════
--   ЗАСТАВКА — СОЛНЕЧНАЯ СИСТЕМА
-- ════════════════════════════════════════════════════════════════
if CoreGui:FindFirstChild("PTH60") then CoreGui.PTH60:Destroy() end
local sg=Instance.new("ScreenGui",CoreGui)
sg.Name="PTH60" sg.ResetOnSpawn=false sg.DisplayOrder=999 sg.IgnoreGuiInset=true

local BG    = Color3.fromRGB(10,10,12)
local SIDE  = Color3.fromRGB(14,14,17)
local CARD  = Color3.fromRGB(20,20,24)
local BORDER= Color3.fromRGB(38,38,46)
local RED   = Color3.fromRGB(215,25,25)
local WHITE = Color3.fromRGB(228,228,228)
local MUTED = Color3.fromRGB(85,85,95)
local DIM   = Color3.fromRGB(30,30,36)
local GREEN = Color3.fromRGB(0,215,100)
local GOLD  = Color3.fromRGB(243,156,18)
local PURPLE= Color3.fromRGB(120,60,200)
local CYAN  = Color3.fromRGB(0,200,220)
local ORANGE= Color3.fromRGB(220,120,0)

local Splash=Instance.new("Frame",sg)
Splash.Size=UDim2.new(1,0,1,0)
Splash.BackgroundColor3=Color3.fromRGB(2,2,8) Splash.BorderSizePixel=0 Splash.ZIndex=100

local bgGrad=Instance.new("UIGradient",Splash)
bgGrad.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(2,2,15)),
    ColorSequenceKeypoint.new(0.5,Color3.fromRGB(5,3,20)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(3,2,12))
})
bgGrad.Rotation=45

-- Звёзды
math.randomseed(42)
for i=1,130 do
    local star=Instance.new("Frame",Splash)
    local sz=math.random(1,3)
    star.Size=UDim2.new(0,sz,0,sz)
    star.Position=UDim2.new(math.random(0,100)/100,0,math.random(0,100)/100,0)
    star.BackgroundColor3=Color3.fromRGB(220+math.random(0,35),220+math.random(0,35),255)
    star.BorderSizePixel=0 star.ZIndex=101
    Instance.new("UICorner",star).CornerRadius=UDim.new(1,0)
    task.spawn(function()
        task.wait(math.random()*5)
        while star and star.Parent do
            TweenService:Create(star,TweenInfo.new(math.random(8,20)/10),{BackgroundTransparency=math.random(10,90)/100}):Play()
            task.wait(math.random(8,20)/10)
        end
    end)
end
for i=1,25 do
    local bs=Instance.new("TextLabel",Splash)
    bs.Size=UDim2.new(0,14,0,14)
    bs.Position=UDim2.new(math.random(1,99)/100,0,math.random(1,99)/100,0)
    bs.BackgroundTransparency=1 bs.Text=(i%2==0 and "✦" or "✧")
    bs.TextColor3=Color3.fromRGB(200+math.random(0,55),200+math.random(0,55),255)
    bs.Font=Enum.Font.GothamBold bs.TextSize=math.random(8,16)
    bs.TextTransparency=math.random(30,60)/100 bs.ZIndex=101
    task.spawn(function()
        task.wait(math.random()*4)
        while bs and bs.Parent do
            TweenService:Create(bs,TweenInfo.new(math.random(10,25)/10),{TextTransparency=0}):Play()
            task.wait(math.random(10,25)/10)
            TweenService:Create(bs,TweenInfo.new(math.random(10,25)/10),{TextTransparency=0.9}):Play()
            task.wait(math.random(10,25)/10)
        end
    end)
end

-- Солнце
local SX=0.5 local SY=0.38
local sunGlow=Instance.new("Frame",Splash)
sunGlow.Size=UDim2.new(0,140,0,140) sunGlow.Position=UDim2.new(SX,-70,SY,-70)
sunGlow.BackgroundColor3=Color3.fromRGB(255,160,0) sunGlow.BackgroundTransparency=1
sunGlow.BorderSizePixel=0 sunGlow.ZIndex=103
Instance.new("UICorner",sunGlow).CornerRadius=UDim.new(1,0)

local sun=Instance.new("Frame",Splash)
sun.Size=UDim2.new(0,80,0,80) sun.Position=UDim2.new(SX,-40,SY,-40)
sun.BackgroundColor3=Color3.fromRGB(255,200,30) sun.BorderSizePixel=0 sun.ZIndex=105
Instance.new("UICorner",sun).CornerRadius=UDim.new(1,0)
local sunGrad=Instance.new("UIGradient",sun)
sunGrad.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(255,240,100)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(255,120,0))
})
sunGrad.Rotation=45
local sunIcon=Instance.new("TextLabel",sun)
sunIcon.Size=UDim2.new(1,0,1,0) sunIcon.BackgroundTransparency=1
sunIcon.Text="☀" sunIcon.TextColor3=Color3.fromRGB(255,255,200)
sunIcon.Font=Enum.Font.GothamBlack sunIcon.TextSize=44 sunIcon.ZIndex=106

task.spawn(function()
    while sunGlow and sunGlow.Parent do
        TweenService:Create(sunGlow,TweenInfo.new(1.4,Enum.EasingStyle.Sine),{BackgroundTransparency=0.45,Size=UDim2.new(0,160,0,160),Position=UDim2.new(SX,-80,SY,-80)}):Play()
        task.wait(1.4)
        TweenService:Create(sunGlow,TweenInfo.new(1.4,Enum.EasingStyle.Sine),{BackgroundTransparency=0.75,Size=UDim2.new(0,130,0,130),Position=UDim2.new(SX,-65,SY,-65)}):Play()
        task.wait(1.4)
    end
end)

-- Планеты
local planets={
    {name="Mercury",color=Color3.fromRGB(180,160,140),size=12,orbit=90,speed=4},
    {name="Venus",color=Color3.fromRGB(230,200,120),size=18,orbit=128,speed=7},
    {name="Earth",color=Color3.fromRGB(60,130,230),size=20,orbit=168,speed=10},
    {name="Mars",color=Color3.fromRGB(210,80,50),size=16,orbit=208,speed=14},
    {name="Jupiter",color=Color3.fromRGB(200,160,100),size=32,orbit=258,speed=22},
    {name="Saturn",color=Color3.fromRGB(220,190,130),size=26,orbit=304,speed=30},
}

for _,pd in ipairs(planets) do
    local ring=Instance.new("Frame",Splash)
    ring.Size=UDim2.new(0,pd.orbit*2,0,pd.orbit*0.76)
    ring.Position=UDim2.new(SX,-pd.orbit,SY,-pd.orbit*0.38)
    ring.BackgroundTransparency=1 ring.BorderSizePixel=0 ring.ZIndex=102
    Instance.new("UICorner",ring).CornerRadius=UDim.new(1,0)
    local rs=Instance.new("UIStroke",ring)
    rs.Color=Color3.fromRGB(50,50,75) rs.Thickness=1 rs.Transparency=0.55
end

for i,pd in ipairs(planets) do
    local planet=Instance.new("Frame",Splash)
    planet.Size=UDim2.new(0,pd.size,0,pd.size)
    planet.BackgroundColor3=pd.color planet.BorderSizePixel=0 planet.ZIndex=106
    Instance.new("UICorner",planet).CornerRadius=UDim.new(1,0)
    local satRing=nil
    if pd.name=="Saturn" then
        satRing=Instance.new("Frame",Splash)
        satRing.Size=UDim2.new(0,pd.size+24,0,pd.size//3)
        satRing.BackgroundColor3=Color3.fromRGB(210,185,120)
        satRing.BackgroundTransparency=0.45 satRing.BorderSizePixel=0 satRing.ZIndex=105
        Instance.new("UICorner",satRing).CornerRadius=UDim.new(1,0)
    end
    local pName=Instance.new("TextLabel",Splash)
    pName.Size=UDim2.new(0,60,0,12) pName.BackgroundTransparency=1
    pName.Text=pd.name pName.TextColor3=Color3.fromRGB(130,130,160)
    pName.Font=Enum.Font.Code pName.TextSize=9 pName.ZIndex=107
    local startAngle=(i-1)*(math.pi*2/#planets)
    task.spawn(function()
        local elapsed=0
        while planet and planet.Parent do
            elapsed=elapsed+task.wait(0.033)
            local angle=startAngle+(elapsed/pd.speed)*math.pi*2
            local rx=math.cos(angle)*pd.orbit
            local ry=math.sin(angle)*pd.orbit*0.38
            planet.Position=UDim2.new(SX,rx-pd.size/2,SY,ry-pd.size/2)
            pName.Position=UDim2.new(SX,rx-30,SY,ry+pd.size/2+2)
            if satRing then local sh=pd.size//3 satRing.Position=UDim2.new(SX,rx-(pd.size+24)/2,SY,ry-sh/2) end
        end
    end)
end

-- Метеориты
task.spawn(function()
    while Splash and Splash.Parent do
        task.wait(math.random(25,55)/10)
        local sy=math.random(5,55)/100
        local m=Instance.new("Frame",Splash)
        m.Size=UDim2.new(0,5,0,5) m.Position=UDim2.new(-0.02,0,sy,0)
        m.BackgroundColor3=Color3.fromRGB(255,255,220) m.BorderSizePixel=0 m.ZIndex=108
        Instance.new("UICorner",m).CornerRadius=UDim.new(1,0)
        local tl=Instance.new("Frame",Splash)
        tl.Size=UDim2.new(0,40,0,2) tl.Position=UDim2.new(-0.06,0,sy,1)
        tl.BackgroundColor3=Color3.fromRGB(200,200,255) tl.BackgroundTransparency=0.4
        tl.BorderSizePixel=0 tl.ZIndex=107
        local dur=math.random(15,25)/10
        TweenService:Create(m,TweenInfo.new(dur,Enum.EasingStyle.Linear),{Position=UDim2.new(1.05,0,sy+0.35,0),BackgroundTransparency=1}):Play()
        TweenService:Create(tl,TweenInfo.new(dur,Enum.EasingStyle.Linear),{Position=UDim2.new(1.02,0,sy+0.35,1),BackgroundTransparency=1}):Play()
        task.delay(dur,function() pcall(function() m:Destroy() tl:Destroy() end) end)
    end
end)

-- Логотип по центру
local bigP=Instance.new("TextLabel",Splash)
bigP.Size=UDim2.new(0,80,0,80) bigP.Position=UDim2.new(0.5,-195,0.7,-40)
bigP.BackgroundTransparency=1 bigP.Text="Ᵽ" bigP.TextColor3=RED
bigP.Font=Enum.Font.GothamBlack bigP.TextSize=80 bigP.TextTransparency=1
bigP.ZIndex=111 bigP.TextStrokeTransparency=0.2 bigP.TextStrokeColor3=Color3.fromRGB(255,80,80)

local nameLetters={"R","I","M","E","J","T","S","U"}
local nameLabels={}
for i,l in ipairs(nameLetters) do
    local lbl=Instance.new("TextLabel",Splash)
    lbl.Size=UDim2.new(0,28,0,45) lbl.Position=UDim2.new(0.5,-120+(i-1)*30,0.7,-10)
    lbl.BackgroundTransparency=1 lbl.Text=l lbl.TextColor3=WHITE
    lbl.Font=Enum.Font.GothamBlack lbl.TextSize=36 lbl.TextTransparency=1 lbl.ZIndex=111
    lbl.TextStrokeTransparency=0.3 lbl.TextStrokeColor3=Color3.fromRGB(180,180,255)
    table.insert(nameLabels,lbl)
end
local verLbl=Instance.new("TextLabel",Splash)
verLbl.Size=UDim2.new(0,300,0,20) verLbl.Position=UDim2.new(0.5,-150,0.7,45)
verLbl.BackgroundTransparency=1 verLbl.Text="v6.0 | @Primejtsu | Nazar513000"
verLbl.TextColor3=Color3.fromRGB(80,100,220) verLbl.Font=Enum.Font.Code
verLbl.TextSize=13 verLbl.TextTransparency=1 verLbl.ZIndex=111

local subLbl=Instance.new("TextLabel",Splash)
subLbl.Size=UDim2.new(0,300,0,16) subLbl.Position=UDim2.new(0.5,-150,0.7,68)
subLbl.BackgroundTransparency=1 subLbl.Text="🪐 Murder Mystery 2 | MEGA UPDATE"
subLbl.TextColor3=GREEN subLbl.Font=Enum.Font.Code
subLbl.TextSize=11 subLbl.TextTransparency=1 subLbl.ZIndex=111

-- Анимация появления
task.spawn(function()
    task.wait(0.4)
    TweenService:Create(bigP,TweenInfo.new(0.6,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{TextTransparency=0}):Play()
    task.wait(0.2)
    for i,lbl in ipairs(nameLabels) do
        task.delay((i-1)*0.06,function()
            TweenService:Create(lbl,TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{TextTransparency=0}):Play()
        end)
    end
    task.wait(0.7)
    TweenService:Create(verLbl,TweenInfo.new(0.5),{TextTransparency=0}):Play()
    TweenService:Create(subLbl,TweenInfo.new(0.5),{TextTransparency=0}):Play()
end)

-- ════════════════════════════════════════════════════════════════
--   ГЛАВНЫЙ UI
-- ════════════════════════════════════════════════════════════════
local function showGUI()
    -- Основное окно
    local Body=Instance.new("Frame",sg)
    Body.Size=UDim2.new(0,480,0,480)
    Body.Position=UDim2.new(0.5,-240,0.5,-240)
    Body.BackgroundColor3=BG Body.BorderSizePixel=0 Body.ZIndex=10
    Instance.new("UICorner",Body).CornerRadius=UDim.new(0,12)
    Instance.new("UIStroke",Body).Color=BORDER

    -- Тень
    local shadow=Instance.new("Frame",sg)
    shadow.Size=UDim2.new(0,490,0,490) shadow.Position=UDim2.new(0.5,-245,0.5,-245)
    shadow.BackgroundColor3=Color3.new(0,0,0) shadow.BackgroundTransparency=0.6
    shadow.BorderSizePixel=0 shadow.ZIndex=9
    Instance.new("UICorner",shadow).CornerRadius=UDim.new(0,14)

    -- Шапка
    local Header=Instance.new("Frame",Body)
    Header.Size=UDim2.new(1,0,0,44) Header.BackgroundColor3=SIDE Header.BorderSizePixel=0
    local hcorner=Instance.new("UICorner",Header) hcorner.CornerRadius=UDim.new(0,12)
    local hFix=Instance.new("Frame",Header) hFix.Size=UDim2.new(1,0,0.5,0) hFix.Position=UDim2.new(0,0,0.5,0) hFix.BackgroundColor3=SIDE hFix.BorderSizePixel=0
    local redLine=Instance.new("Frame",Header) redLine.Size=UDim2.new(1,0,0,2) redLine.Position=UDim2.new(0,0,1,-2) redLine.BackgroundColor3=RED redLine.BorderSizePixel=0

    local hIcon=Instance.new("TextLabel",Header)
    hIcon.Size=UDim2.new(0,30,1,0) hIcon.Position=UDim2.new(0,10,0,0)
    hIcon.BackgroundTransparency=1 hIcon.Text="Ᵽ" hIcon.TextColor3=RED
    hIcon.Font=Enum.Font.GothamBlack hIcon.TextSize=26

    local hTitle=Instance.new("TextLabel",Header)
    hTitle.Size=UDim2.new(0,200,1,0) hTitle.Position=UDim2.new(0,42,0,0)
    hTitle.BackgroundTransparency=1 hTitle.Text="Primejtsu Hub"
    hTitle.TextColor3=WHITE hTitle.Font=Enum.Font.GothamBlack hTitle.TextSize=16
    hTitle.TextXAlignment=Enum.TextXAlignment.Left

    local hVer=Instance.new("TextLabel",Header)
    hVer.Size=UDim2.new(0,100,1,0) hVer.Position=UDim2.new(0,200,0,0)
    hVer.BackgroundTransparency=1 hVer.Text="v6.0"
    hVer.TextColor3=Color3.fromRGB(80,80,100) hVer.Font=Enum.Font.Code hVer.TextSize=12
    hVer.TextXAlignment=Enum.TextXAlignment.Left

    -- Кнопка закрыть
    local closeBtn=Instance.new("TextButton",Header)
    closeBtn.Size=UDim2.new(0,30,0,30) closeBtn.Position=UDim2.new(1,-36,0.5,-15)
    closeBtn.BackgroundColor3=Color3.fromRGB(60,10,10) closeBtn.BorderSizePixel=0
    closeBtn.Text="✕" closeBtn.TextColor3=WHITE closeBtn.Font=Enum.Font.GothamBold closeBtn.TextSize=14
    Instance.new("UICorner",closeBtn).CornerRadius=UDim.new(0,6)

    local guiVisible=true
    local toggleBtn=Instance.new("TextButton",sg)
    toggleBtn.Size=UDim2.new(0,36,0,36) toggleBtn.Position=UDim2.new(0,8,0.5,-18)
    toggleBtn.BackgroundColor3=Color3.fromRGB(15,15,20) toggleBtn.BorderSizePixel=0
    toggleBtn.Text="Ᵽ" toggleBtn.TextColor3=RED toggleBtn.Font=Enum.Font.GothamBlack toggleBtn.TextSize=22
    toggleBtn.Visible=false
    Instance.new("UICorner",toggleBtn).CornerRadius=UDim.new(0,8)
    Instance.new("UIStroke",toggleBtn).Color=BORDER

    closeBtn.MouseButton1Click:Connect(function()
        guiVisible=false Body.Visible=false shadow.Visible=false toggleBtn.Visible=true
    end)
    toggleBtn.MouseButton1Click:Connect(function()
        guiVisible=true Body.Visible=true shadow.Visible=true toggleBtn.Visible=false
    end)

    -- Перетаскивание
    local dragging=false local dragStart=nil local startPos=nil
    Header.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true dragStart=i.Position
            startPos=Body.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local delta=i.Position-dragStart
            Body.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
            shadow.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X-5,startPos.Y.Scale,startPos.Y.Offset+delta.Y-5)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=false
        end
    end)

    -- Боковая навигация
    local SB=Instance.new("Frame",Body)
    SB.Size=UDim2.new(0,88,1,-44) SB.Position=UDim2.new(0,0,0,44)
    SB.BackgroundColor3=SIDE SB.BorderSizePixel=0

    local sbRight=Instance.new("Frame",Body)
    sbRight.Size=UDim2.new(0,1,1,-44) sbRight.Position=UDim2.new(0,88,0,44)
    sbRight.BackgroundColor3=BORDER sbRight.BorderSizePixel=0

    -- Контент (ScrollingFrame)
    local CT=Instance.new("ScrollingFrame",Body)
    CT.Size=UDim2.new(1,-97,1,-96) CT.Position=UDim2.new(0,97,0,44)
    CT.BackgroundTransparency=1 CT.BorderSizePixel=0
    CT.ScrollBarThickness=3 CT.ScrollBarImageColor3=RED
    CT.CanvasSize=UDim2.new(0,0,0,0)
    CT.ScrollingEnabled=true
    CT.ElasticBehavior=Enum.ElasticBehavior.Never

    -- Кнопки скролла
    local scrollBtns=Instance.new("Frame",Body)
    scrollBtns.Size=UDim2.new(1,-97,0,46) scrollBtns.Position=UDim2.new(0,97,1,-46)
    scrollBtns.BackgroundColor3=SIDE scrollBtns.BorderSizePixel=0
    local sbDiv=Instance.new("Frame",scrollBtns) sbDiv.Size=UDim2.new(1,0,0,1) sbDiv.BackgroundColor3=BORDER sbDiv.BorderSizePixel=0

    local btnUp=Instance.new("TextButton",scrollBtns)
    btnUp.Size=UDim2.new(0.5,0,1,0) btnUp.Position=UDim2.new(0,0,0,0)
    btnUp.BackgroundColor3=SIDE btnUp.BorderSizePixel=0
    btnUp.Text="▲  Вверх" btnUp.TextColor3=MUTED btnUp.Font=Enum.Font.GothamBold btnUp.TextSize=13

    local btnDown=Instance.new("TextButton",scrollBtns)
    btnDown.Size=UDim2.new(0.5,0,1,0) btnDown.Position=UDim2.new(0.5,0,0,0)
    btnDown.BackgroundColor3=SIDE btnDown.BorderSizePixel=0
    btnDown.Text="▼  Вниз" btnDown.TextColor3=WHITE btnDown.Font=Enum.Font.GothamBold btnDown.TextSize=13

    local divLine=Instance.new("Frame",scrollBtns)
    divLine.Size=UDim2.new(0,1,1,0) divLine.Position=UDim2.new(0.5,0,0,0)
    divLine.BackgroundColor3=BORDER divLine.BorderSizePixel=0

    -- Скролл логика (Touch + Mouse)
    local scrolling=false
    local function doScroll(dir)
        task.spawn(function()
            while scrolling do
                local maxY=math.max(0,CT.AbsoluteCanvasSize.Y-CT.AbsoluteSize.Y)
                CT.CanvasPosition=Vector2.new(0,math.clamp(CT.CanvasPosition.Y+dir*30,0,maxY))
                task.wait(0.04)
            end
        end)
    end
    local function stopScroll() scrolling=false end

    btnUp.MouseButton1Down:Connect(function() scrolling=true doScroll(-1) end)
    btnUp.MouseButton1Up:Connect(stopScroll) btnUp.MouseLeave:Connect(stopScroll)
    btnUp.TouchLongPress:Connect(function() scrolling=true doScroll(-1) end)
    btnUp.TouchTap:Connect(function()
        local maxY=math.max(0,CT.AbsoluteCanvasSize.Y-CT.AbsoluteSize.Y)
        CT.CanvasPosition=Vector2.new(0,math.clamp(CT.CanvasPosition.Y-100,0,maxY))
    end)
    btnUp.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then stopScroll() end end)

    btnDown.MouseButton1Down:Connect(function() scrolling=true doScroll(1) end)
    btnDown.MouseButton1Up:Connect(stopScroll) btnDown.MouseLeave:Connect(stopScroll)
    btnDown.TouchLongPress:Connect(function() scrolling=true doScroll(1) end)
    btnDown.TouchTap:Connect(function()
        local maxY=math.max(0,CT.AbsoluteCanvasSize.Y-CT.AbsoluteSize.Y)
        CT.CanvasPosition=Vector2.new(0,math.clamp(CT.CanvasPosition.Y+100,0,maxY))
    end)
    btnDown.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then stopScroll() end end)

    -- Подсветка кнопок скролла
    btnUp.MouseButton1Down:Connect(function() TweenService:Create(btnUp,TweenInfo.new(0.1),{BackgroundColor3=DIM}):Play() end)
    btnUp.MouseButton1Up:Connect(function() TweenService:Create(btnUp,TweenInfo.new(0.1),{BackgroundColor3=SIDE}):Play() end)
    btnDown.MouseButton1Down:Connect(function() TweenService:Create(btnDown,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(50,10,10)}):Play() end)
    btnDown.MouseButton1Up:Connect(function() TweenService:Create(btnDown,TweenInfo.new(0.1),{BackgroundColor3=SIDE}):Play() end)

    local CTL=Instance.new("UIListLayout",CT) CTL.Padding=UDim.new(0,5) CTL.SortOrder=Enum.SortOrder.LayoutOrder
    local CTP=Instance.new("UIPadding",CT) CTP.PaddingLeft=UDim.new(0,10) CTP.PaddingRight=UDim.new(0,10) CTP.PaddingTop=UDim.new(0,8) CTP.PaddingBottom=UDim.new(0,8)
    CTL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        CT.CanvasSize=UDim2.new(0,0,0,CTL.AbsoluteContentSize.Y+16)
    end)

    -- Табы
    local tabContent={} local tabBtns={}
    local TABS={"Info","Player","God","Farm","Visual","Bypass","TP","Trol","Misc"}
    for _,n in ipairs(TABS) do tabContent[n]={} end

    Instance.new("UIListLayout",SB).Padding=UDim.new(0,0)
    Instance.new("UIPadding",SB).PaddingTop=UDim.new(0,4)

    local function makeSideBtn(label,icon)
        local b=Instance.new("TextButton",SB) b.Size=UDim2.new(1,0,0,40) b.BackgroundTransparency=1 b.Text="" b.BorderSizePixel=0
        local d=Instance.new("Frame",b) d.Size=UDim2.new(0,3,0,22) d.Position=UDim2.new(0,0,0.5,-11) d.BackgroundColor3=RED d.BorderSizePixel=0 d.Visible=false
        Instance.new("UICorner",d).CornerRadius=UDim.new(1,0)
        local il=Instance.new("TextLabel",b) il.Size=UDim2.new(0,20,1,0) il.Position=UDim2.new(0,10,0,0) il.BackgroundTransparency=1 il.Text=icon il.TextColor3=MUTED il.Font=Enum.Font.Gotham il.TextSize=14
        local l=Instance.new("TextLabel",b) l.Size=UDim2.new(1,-32,1,0) l.Position=UDim2.new(0,32,0,0) l.BackgroundTransparency=1 l.Text=label l.TextColor3=MUTED l.Font=Enum.Font.GothamBold l.TextSize=11 l.TextXAlignment=Enum.TextXAlignment.Left
        tabBtns[label]={btn=b,dot=d,lbl=l,ico=il} return b
    end

    local curFrames={}
    local function switchTab(name)
        for _,f in ipairs(curFrames) do f.Parent=nil end curFrames={}
        for k,t in pairs(tabBtns) do t.dot.Visible=false t.lbl.TextColor3=MUTED t.ico.TextColor3=MUTED end
        if tabBtns[name] then tabBtns[name].dot.Visible=true tabBtns[name].lbl.TextColor3=WHITE tabBtns[name].ico.TextColor3=RED end
        if tabContent[name] then for _,f in ipairs(tabContent[name]) do f.Parent=CT table.insert(curFrames,f) end end
        task.wait() CT.CanvasSize=UDim2.new(0,0,0,CTL.AbsoluteContentSize.Y+16) CT.CanvasPosition=Vector2.new(0,0)
    end

    local tabIcons={Info="ℹ",Player="🏃",God="🛡",Farm="💰",Visual="👁",Bypass="🔓",TP="📍",Trol="😈",Misc="⚙"}
    for _,n in ipairs(TABS) do
        local b=makeSideBtn(n,tabIcons[n]) local nn=n
        b.MouseButton1Click:Connect(function() switchTab(nn) end)
    end

    -- ──────── ХЕЛПЕРЫ UI ────────
    local function mkSec(tab,title)
        local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,22) f.BackgroundTransparency=1 f.BorderSizePixel=0
        local l=Instance.new("TextLabel",f) l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1 l.Text=title l.TextColor3=Color3.fromRGB(130,130,140) l.Font=Enum.Font.GothamBold l.TextSize=11 l.TextXAlignment=Enum.TextXAlignment.Left
        local line=Instance.new("Frame",f) line.Size=UDim2.new(1,0,0,1) line.Position=UDim2.new(0,0,1,-1) line.BackgroundColor3=BORDER line.BorderSizePixel=0
        table.insert(tabContent[tab],f)
    end

    local function mkToggle(tab,title,cfgKey,onFn)
        local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,40) f.BackgroundColor3=CARD f.BorderSizePixel=0
        Instance.new("UICorner",f).CornerRadius=UDim.new(0,8) Instance.new("UIStroke",f).Color=BORDER
        local lbl=Instance.new("TextLabel",f) lbl.Size=UDim2.new(1,-58,1,0) lbl.Position=UDim2.new(0,12,0,0) lbl.BackgroundTransparency=1 lbl.Text=title lbl.TextColor3=WHITE lbl.Font=Enum.Font.Gotham lbl.TextSize=12 lbl.TextXAlignment=Enum.TextXAlignment.Left
        local track=Instance.new("Frame",f) track.Size=UDim2.new(0,40,0,22) track.Position=UDim2.new(1,-48,0.5,-11) track.BackgroundColor3=DIM track.BorderSizePixel=0
        Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
        local circle=Instance.new("Frame",track) circle.Size=UDim2.new(0,16,0,16) circle.Position=UDim2.new(0,3,0.5,-8) circle.BackgroundColor3=MUTED circle.BorderSizePixel=0
        Instance.new("UICorner",circle).CornerRadius=UDim.new(1,0)
        local btn=Instance.new("TextButton",track) btn.Size=UDim2.new(1,0,1,0) btn.BackgroundTransparency=1 btn.Text=""
        local on=false
        btn.MouseButton1Click:Connect(function()
            on=not on
            local t2=TweenInfo.new(0.15)
            if on then
                TweenService:Create(track,t2,{BackgroundColor3=RED}):Play()
                TweenService:Create(circle,t2,{Position=UDim2.new(0,22,0.5,-8),BackgroundColor3=WHITE}):Play()
            else
                TweenService:Create(track,t2,{BackgroundColor3=DIM}):Play()
                TweenService:Create(circle,t2,{Position=UDim2.new(0,3,0.5,-8),BackgroundColor3=MUTED}):Play()
            end
            if cfgKey then CFG[cfgKey]=on end
            if onFn then onFn(on) end
        end)
        table.insert(tabContent[tab],f)
        return {frame=f, setState=function(v)
            on=v
            local t2=TweenInfo.new(0.15)
            if v then TweenService:Create(track,t2,{BackgroundColor3=RED}):Play() TweenService:Create(circle,t2,{Position=UDim2.new(0,22,0.5,-8),BackgroundColor3=WHITE}):Play()
            else TweenService:Create(track,t2,{BackgroundColor3=DIM}):Play() TweenService:Create(circle,t2,{Position=UDim2.new(0,3,0.5,-8),BackgroundColor3=MUTED}):Play() end
            if cfgKey then CFG[cfgKey]=v end
        end}
    end

    local function mkButton(tab,title,col,fn)
        local bc=col or DIM
        local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,40) f.BackgroundColor3=bc f.BorderSizePixel=0
        Instance.new("UICorner",f).CornerRadius=UDim.new(0,8) Instance.new("UIStroke",f).Color=BORDER
        local b=Instance.new("TextButton",f) b.Size=UDim2.new(1,0,1,0) b.BackgroundTransparency=1 b.Text=title b.TextColor3=WHITE b.Font=Enum.Font.GothamBold b.TextSize=12 b.BorderSizePixel=0
        b.MouseButton1Click:Connect(function()
            TweenService:Create(f,TweenInfo.new(0.1),{BackgroundColor3=RED}):Play()
            task.wait(0.15) TweenService:Create(f,TweenInfo.new(0.1),{BackgroundColor3=bc}):Play()
            if fn then fn() end
        end)
        table.insert(tabContent[tab],f)
    end

    local function mkSlider(tab,title,min,max,default,onFn)
        local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,52) f.BackgroundColor3=CARD f.BorderSizePixel=0
        Instance.new("UICorner",f).CornerRadius=UDim.new(0,8) Instance.new("UIStroke",f).Color=BORDER
        local lbl=Instance.new("TextLabel",f) lbl.Size=UDim2.new(0.65,0,0,24) lbl.Position=UDim2.new(0,12,0,4) lbl.BackgroundTransparency=1 lbl.Text=title lbl.TextColor3=WHITE lbl.Font=Enum.Font.Gotham lbl.TextSize=12 lbl.TextXAlignment=Enum.TextXAlignment.Left
        local valLbl=Instance.new("TextLabel",f) valLbl.Size=UDim2.new(0.3,0,0,24) valLbl.Position=UDim2.new(0.68,0,0,4) valLbl.BackgroundTransparency=1 valLbl.Text=tostring(default) valLbl.TextColor3=RED valLbl.Font=Enum.Font.GothamBold valLbl.TextSize=13 valLbl.TextXAlignment=Enum.TextXAlignment.Right
        local track=Instance.new("Frame",f) track.Size=UDim2.new(1,-24,0,6) track.Position=UDim2.new(0,12,0,34) track.BackgroundColor3=DIM track.BorderSizePixel=0
        Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
        local fill=Instance.new("Frame",track) fill.Size=UDim2.new((default-min)/(max-min),0,1,0) fill.BackgroundColor3=RED fill.BorderSizePixel=0
        Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
        local knob=Instance.new("Frame",track) knob.Size=UDim2.new(0,14,0,14) knob.AnchorPoint=Vector2.new(0.5,0.5) knob.Position=UDim2.new((default-min)/(max-min),0,0.5,0) knob.BackgroundColor3=WHITE knob.BorderSizePixel=0
        Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
        local val=default
        local sliding=false
        local function updateSlider(x)
            local rel=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
            val=math.floor(min+rel*(max-min))
            fill.Size=UDim2.new(rel,0,1,0)
            knob.Position=UDim2.new(rel,0,0.5,0)
            valLbl.Text=tostring(val)
            if onFn then onFn(val) end
        end
        track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=true updateSlider(i.Position.X) end end)
        UIS.InputChanged:Connect(function(i) if sliding and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then updateSlider(i.Position.X) end end)
        UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=false end end)
        table.insert(tabContent[tab],f)
    end

    -- ════════════════════════════════════════
    --   ВКЛАДКА: INFO
    -- ════════════════════════════════════════
    mkSec("Info","Информация")
    local ic=Instance.new("Frame") ic.Size=UDim2.new(1,0,0,90) ic.BackgroundColor3=CARD ic.BorderSizePixel=0
    Instance.new("UICorner",ic).CornerRadius=UDim.new(0,8) Instance.new("UIStroke",ic).Color=BORDER
    local irt=Instance.new("Frame",ic) irt.Size=UDim2.new(1,0,0,2) irt.BackgroundColor3=RED irt.BorderSizePixel=0
    local _lp=Instance.new("TextLabel",ic) _lp.Size=UDim2.new(0,36,0,44) _lp.Position=UDim2.new(0,12,0.5,-22) _lp.BackgroundTransparency=1 _lp.Text="Ᵽ" _lp.TextColor3=RED _lp.Font=Enum.Font.GothamBlack _lp.TextSize=40
    local _n1=Instance.new("TextLabel",ic) _n1.Size=UDim2.new(1,-60,0,18) _n1.Position=UDim2.new(0,54,0,12) _n1.BackgroundTransparency=1 _n1.Text="Primejtsu Hub" _n1.TextColor3=WHITE _n1.Font=Enum.Font.GothamBlack _n1.TextSize=17 _n1.TextXAlignment=Enum.TextXAlignment.Left
    local _n2=Instance.new("TextLabel",ic) _n2.Size=UDim2.new(1,-60,0,14) _n2.Position=UDim2.new(0,54,0,33) _n2.BackgroundTransparency=1 _n2.Text="✈ @Primejtsu" _n2.TextColor3=Color3.fromRGB(50,150,220) _n2.Font=Enum.Font.Code _n2.TextSize=12 _n2.TextXAlignment=Enum.TextXAlignment.Left
    local _n2b=Instance.new("TextLabel",ic) _n2b.Size=UDim2.new(1,-60,0,13) _n2b.Position=UDim2.new(0,54,0,49) _n2b.BackgroundTransparency=1 _n2b.Text="Nazar513000" _n2b.TextColor3=Color3.fromRGB(100,100,150) _n2b.Font=Enum.Font.Code _n2b.TextSize=11 _n2b.TextXAlignment=Enum.TextXAlignment.Left
    local _n3=Instance.new("TextLabel",ic) _n3.Size=UDim2.new(1,0,0,14) _n3.Position=UDim2.new(0,12,1,-17) _n3.BackgroundTransparency=1 _n3.Text="v6.0  •  Bypass v4  •  CoinFarm v4  •  @Primejtsu 🪐" _n3.TextColor3=GREEN _n3.Font=Enum.Font.Code _n3.TextSize=10 _n3.TextXAlignment=Enum.TextXAlignment.Left
    table.insert(tabContent["Info"],ic)

    -- Счётчик монет
    local cd=Instance.new("Frame") cd.Size=UDim2.new(1,0,0,40) cd.BackgroundColor3=CARD cd.BorderSizePixel=0
    Instance.new("UICorner",cd).CornerRadius=UDim.new(0,8) Instance.new("UIStroke",cd).Color=BORDER
    local cdl=Instance.new("TextLabel",cd) cdl.Size=UDim2.new(0.55,0,1,0) cdl.Position=UDim2.new(0,12,0,0) cdl.BackgroundTransparency=1 cdl.Text="💰 Монет собрано" cdl.TextColor3=MUTED cdl.Font=Enum.Font.Gotham cdl.TextSize=12 cdl.TextXAlignment=Enum.TextXAlignment.Left
    local cdv=Instance.new("TextLabel",cd) cdv.Size=UDim2.new(0.4,0,1,0) cdv.Position=UDim2.new(0.58,0,0,0) cdv.BackgroundTransparency=1 cdv.Text="0" cdv.TextColor3=GOLD cdv.Font=Enum.Font.GothamBold cdv.TextSize=20 cdv.TextXAlignment=Enum.TextXAlignment.Right
    table.insert(tabContent["Info"],cd)
    RunService.Heartbeat:Connect(function() if cdv and cdv.Parent then cdv.Text=tostring(coinCount) end end)

    -- Статус игроков
    mkSec("Info","Игроки в лобби")
    local playerListFrame=Instance.new("Frame") playerListFrame.Size=UDim2.new(1,0,0,10) playerListFrame.BackgroundTransparency=1 playerListFrame.AutomaticSize=Enum.AutomaticSize.Y playerListFrame.BorderSizePixel=0
    Instance.new("UIListLayout",playerListFrame).Padding=UDim.new(0,4)
    table.insert(tabContent["Info"],playerListFrame)
    local function refreshInfoPlayers()
        for _,c in ipairs(playerListFrame:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        for _,p in ipairs(Players:GetPlayers()) do
            local role=getRole(p)
            local pf=Instance.new("Frame",playerListFrame) pf.Size=UDim2.new(1,0,0,28) pf.BackgroundColor3=CARD pf.BorderSizePixel=0
            Instance.new("UICorner",pf).CornerRadius=UDim.new(0,6) Instance.new("UIStroke",pf).Color=BORDER
            local roleColor=ROLE_COLORS[role] or WHITE
            local acc=Instance.new("Frame",pf) acc.Size=UDim2.new(0,3,0.6,0) acc.Position=UDim2.new(0,0,0.2,0) acc.BackgroundColor3=roleColor acc.BorderSizePixel=0
            Instance.new("UICorner",acc).CornerRadius=UDim.new(1,0)
            local nm=Instance.new("TextLabel",pf) nm.Size=UDim2.new(0.7,0,1,0) nm.Position=UDim2.new(0,14,0,0) nm.BackgroundTransparency=1 nm.Text=(p==LP and "★ " or "")..p.Name nm.TextColor3=p==LP and GOLD or WHITE nm.Font=Enum.Font.GothamBold nm.TextSize=11 nm.TextXAlignment=Enum.TextXAlignment.Left
            local rl=Instance.new("TextLabel",pf) rl.Size=UDim2.new(0.28,0,1,0) rl.Position=UDim2.new(0.7,0,0,0) rl.BackgroundTransparency=1 rl.Text=(role=="Murderer" and "🔪" or role=="Sheriff" and "🔫" or "😇") rl.Font=Enum.Font.GothamBold rl.TextSize=14 rl.TextXAlignment=Enum.TextXAlignment.Right
        end
    end
    task.spawn(function() while sg and sg.Parent do pcall(refreshInfoPlayers) task.wait(3) end end)

    -- ════════════════════════════════════════
    --   ВКЛАДКА: PLAYER
    -- ════════════════════════════════════════
    mkSec("Player","Движение")
    mkToggle("Player","⚡ Speed Hack (WalkSpeed 50)","speed")
    mkToggle("Player","🐇 Bunny Hop","bhop")
    mkToggle("Player","👻 Noclip v3","noclip")
    mkToggle("Player","🦘 Infinite Jump","infiniteJump")
    mkToggle("Player","🕊 Fly (WASD + Space/Ctrl)","fly",function(v) enableFly(v) end)
    mkSec("Player","Скорость")
    mkSlider("Player","WalkSpeed",6,100,16,function(v)
        pcall(function() local h=getHum() if h then h.WalkSpeed=v end end)
    end)
    mkSlider("Player","JumpPower",0,200,50,function(v)
        pcall(function() local h=getHum() if h then h.JumpPower=v end end)
    end)

    -- ════════════════════════════════════════
    --   ВКЛАДКА: GOD
    -- ════════════════════════════════════════
    mkSec("God","Защита")
    mkToggle("God","❤ God Mode","god",function(v) applyGod(v) end)
    mkToggle("God","🛡 Anti Knock (нельзя откинуть)","antiKnock")
    mkToggle("God","🔄 Spin Bot (защита от слежки)","spinBot")
    mkSec("God","Оружие")
    mkToggle("God","🔫 Inf Ammo (∞ патронов шерифа)","infAmmo")
    mkToggle("God","🎯 Aimbot (автоприцел на убийцу)","aimbot")
    mkSec("God","Статус HP")
    mkButton("God","💉 Пополнить HP до макс",Color3.fromRGB(15,40,15),function()
        pcall(function() local h=getHum() if h then h.Health=h.MaxHealth end end)
        notify("God","HP пополнен",2)
    end)
    mkButton("God","💀 Сбросить персонажа",Color3.fromRGB(40,10,10),function()
        pcall(function() LP:LoadCharacter() end)
    end)

    -- ════════════════════════════════════════
    --   ВКЛАДКА: FARM
    -- ════════════════════════════════════════
    mkSec("Farm","💰 Монеты")

    -- Инфо блок
    local farmInfo=Instance.new("Frame") farmInfo.Size=UDim2.new(1,0,0,72) farmInfo.BackgroundColor3=Color3.fromRGB(12,20,10) farmInfo.BorderSizePixel=0
    Instance.new("UICorner",farmInfo).CornerRadius=UDim.new(0,8) Instance.new("UIStroke",farmInfo).Color=Color3.fromRGB(0,150,50)
    local farmTxt=Instance.new("TextLabel",farmInfo) farmTxt.Size=UDim2.new(1,-16,1,0) farmTxt.Position=UDim2.new(0,8,0,0) farmTxt.BackgroundTransparency=1
    farmTxt.Text="CoinFarm v4:\n• Ближние монеты (<20st) — бег WS50\n• Средние (20-60st) — телепорт\n• Далёкие (>60st) — 2-шаговый телепорт\n• firetouchinterest + fireclickdetector"
    farmTxt.TextColor3=Color3.fromRGB(100,200,100) farmTxt.Font=Enum.Font.Code farmTxt.TextSize=10 farmTxt.TextWrapped=true farmTxt.TextXAlignment=Enum.TextXAlignment.Left farmTxt.TextYAlignment=Enum.TextYAlignment.Top
    table.insert(tabContent["Farm"],farmInfo)

    mkToggle("Farm","🪙 Coin Farm v4","coinFarm")
    mkToggle("Farm","🧲 Bring Coins (монеты к тебе)","bringCoins")
    mkToggle("Farm","🔪 Knife Aura","knife")
    mkToggle("Farm","🎁 Auto Reward (авто-кнопки)","autoReward")
    mkSec("Farm","АФК")
    mkToggle("Farm","💤 Anti AFK","antiAfk")
    mkSec("Farm","Статистика")
    mkButton("Farm","🔄 Сбросить счётчик монет",DIM,function()
        coinCount=0 notify("Farm","Счётчик сброшен",2)
    end)

    -- ════════════════════════════════════════
    --   ВКЛАДКА: VISUAL
    -- ════════════════════════════════════════
    mkSec("Visual","👁 ESP")
    mkToggle("Visual","👁 ESP (роли + HP + дистанция)","esp")
    mkToggle("Visual","🎨 Chams (подсветка сквозь стены)","chams")
    mkToggle("Visual","📡 Tracers (линии к игрокам)","tracers")
    mkSec("Visual","Окружение")
    mkToggle("Visual","☀ Fullbright (убрать темноту)","fullbright",function(v) setFB(v) end)
    mkToggle("Visual","🌫 No Fog (убрать туман)","noFog",function(v) setNoFog(v) end)
    mkSec("Visual","Персонаж")
    mkToggle("Visual","👻 Hide Player (невидимый)","hide",function(v) hidePlayer(v) end)
    mkToggle("Visual","🗿 Big Head (большая голова)","bigHead")
    mkSec("Visual","Показать роли")
    mkButton("Visual","🎭 ESP всех ролей (уведомление)",Color3.fromRGB(20,20,50),function()
        task.spawn(function()
            local m,s,inn={},{},{}
            for _,p in ipairs(Players:GetPlayers()) do
                if p~=LP then
                    local r=getRole(p)
                    if r=="Murderer" then table.insert(m,p.Name)
                    elseif r=="Sheriff" then table.insert(s,p.Name)
                    else table.insert(inn,p.Name) end
                end
            end
            local txt=""
            if #m>0 then txt=txt.."🔪 "..table.concat(m,", ").." | " end
            if #s>0 then txt=txt.."🔫 "..table.concat(s,", ").." | " end
            if #inn>0 then txt=txt.."😇 "..table.concat(inn,", ") end
            notify("👁 ESP Роли",txt,7)
        end)
    end)
    mkButton("Visual","🔪 Кто убийца?",Color3.fromRGB(50,5,5),function()
        for _,p in ipairs(Players:GetPlayers()) do
            if getRole(p)=="Murderer" then
                notify("🔪 УБИЙЦА",p.Name,5) return
            end
        end
        notify("Убийца","Не найден",2)
    end)
    mkButton("Visual","🔫 Кто шериф?",Color3.fromRGB(5,20,60),function()
        for _,p in ipairs(Players:GetPlayers()) do
            if getRole(p)=="Sheriff" then
                notify("🔫 ШЕРИФ",p.Name,5) return
            end
        end
        notify("Шериф","Не найден",2)
    end)

    -- ════════════════════════════════════════
    --   ВКЛАДКА: BYPASS
    -- ════════════════════════════════════════
    mkSec("Bypass","🔓 Antikick Bypass v4")
    local bypassInfo=Instance.new("Frame") bypassInfo.Size=UDim2.new(1,0,0,72) bypassInfo.BackgroundColor3=Color3.fromRGB(18,10,6) bypassInfo.BorderSizePixel=0
    Instance.new("UICorner",bypassInfo).CornerRadius=UDim.new(0,8) Instance.new("UIStroke",bypassInfo).Color=Color3.fromRGB(200,100,0)
    local bypassTxt=Instance.new("TextLabel",bypassInfo) bypassTxt.Size=UDim2.new(1,-16,1,0) bypassTxt.Position=UDim2.new(0,8,0,0) bypassTxt.BackgroundTransparency=1
    bypassTxt.Text="Bypass v4:\n• Имитация мыши (VirtualUser)\n• Случайные прыжки каждые 20-40 сек\n• Паузы фарма 2-6 сек каждые 30-60 сек\n• Плавная смена WalkSpeed"
    bypassTxt.TextColor3=Color3.fromRGB(210,160,80) bypassTxt.Font=Enum.Font.Code bypassTxt.TextSize=10 bypassTxt.TextWrapped=true bypassTxt.TextXAlignment=Enum.TextXAlignment.Left bypassTxt.TextYAlignment=Enum.TextYAlignment.Top
    table.insert(tabContent["Bypass"],bypassInfo)

    mkToggle("Bypass","🛡 Bypass v4 (включи с фармом)","bypass")
    mkToggle("Bypass","💤 Anti AFK","antiAfk")
    mkSec("Bypass","Утилиты")
    mkButton("Bypass","🔄 Перезапустить персонажа",Color3.fromRGB(25,25,55),function()
        pcall(function() LP:LoadCharacter() end)
    end)
    mkButton("Bypass","🧹 Стелс — выключить ВСЕ читы",Color3.fromRGB(20,45,20),function()
        CFG.coinFarm=false CFG.bringCoins=false CFG.knife=false CFG.speed=false CFG.bhop=false
        CFG.bypass=false CFG.esp=false CFG.chams=false CFG.tracers=false CFG.noclip=false
        CFG.aimbot=false CFG.spinBot=false CFG.fly=false
        enableFly(false)
        pcall(function() local h=getHum() if h then h.WalkSpeed=16 h.JumpPower=50 end end)
        notify("🧹 Стелс","Все читы выключены",3)
    end)
    mkButton("Bypass","📋 Версия",DIM,function()
        notify("Primejtsu Hub","v6.0 | @Primejtsu | Nazar513000",4)
    end)

    -- ════════════════════════════════════════
    --   ВКЛАДКА: TP
    -- ════════════════════════════════════════
    mkSec("TP","Быстрый TP")
    mkButton("TP","🔪 TP к Убийце",Color3.fromRGB(75,10,10),function() tpToRole("Murderer") end)
    mkButton("TP","🔫 TP к Шерифу",Color3.fromRGB(10,25,75),function() tpToRole("Sheriff") end)
    mkButton("TP","😇 TP к случайному игроку",Color3.fromRGB(25,35,25),function()
        pcall(function()
            local hrp=getHRP() if not hrp then return end
            local others={}
            for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then table.insert(others,p) end end
            if #others==0 then notify("TP","Нет игроков",2) return end
            local p=others[math.random(1,#others)]
            local t=p.Character:FindFirstChild("HumanoidRootPart")
            if t then hrp.CFrame=t.CFrame+Vector3.new(3,0,0) end
        end)
    end)
    mkButton("TP","🏠 TP к спавну (0,10,0)",DIM,function()
        pcall(function() local hrp=getHRP() if hrp then hrp.CFrame=CFrame.new(0,10,0) end end)
    end)
    mkSec("TP","Игроки")
    local plf=Instance.new("Frame") plf.Size=UDim2.new(1,0,0,10) plf.BackgroundTransparency=1 plf.BorderSizePixel=0 plf.AutomaticSize=Enum.AutomaticSize.Y
    Instance.new("UIListLayout",plf).Padding=UDim.new(0,4)
    table.insert(tabContent["TP"],plf)
    local function rebuildPL()
        for _,ch in ipairs(plf:GetChildren()) do if ch:IsA("Frame") then ch:Destroy() end end
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP then continue end
            local pf2=Instance.new("Frame",plf) pf2.Size=UDim2.new(1,0,0,34) pf2.BackgroundColor3=CARD pf2.BorderSizePixel=0
            Instance.new("UICorner",pf2).CornerRadius=UDim.new(0,7) Instance.new("UIStroke",pf2).Color=BORDER
            local role=getRole(p) local col=ROLE_COLORS[role]
            local acc2=Instance.new("Frame",pf2) acc2.Size=UDim2.new(0,3,0.6,0) acc2.Position=UDim2.new(0,0,0.2,0) acc2.BackgroundColor3=col acc2.BorderSizePixel=0
            Instance.new("UICorner",acc2).CornerRadius=UDim.new(1,0)
            local nm=Instance.new("TextLabel",pf2) nm.Size=UDim2.new(1,-70,1,0) nm.Position=UDim2.new(0,14,0,0) nm.BackgroundTransparency=1 nm.Text=p.Name nm.TextColor3=WHITE nm.Font=Enum.Font.GothamBold nm.TextSize=12 nm.TextXAlignment=Enum.TextXAlignment.Left
            local rt=Instance.new("TextLabel",pf2) rt.Size=UDim2.new(0,55,1,0) rt.Position=UDim2.new(1,-57,0,0) rt.BackgroundTransparency=1 rt.Text=(role=="Murderer" and "🔪" or role=="Sheriff" and "🔫" or "😇") rt.Font=Enum.Font.GothamBold rt.TextSize=16
            local tb=Instance.new("TextButton",pf2) tb.Size=UDim2.new(1,0,1,0) tb.BackgroundTransparency=1 tb.Text=""
            tb.MouseButton1Click:Connect(function()
                pcall(function()
                    local hrp=getHRP() if not hrp then return end
                    if p.Character then
                        local t=p.Character:FindFirstChild("HumanoidRootPart")
                        if t then
                            TweenService:Create(pf2,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(60,10,10)}):Play()
                            task.wait(0.15) TweenService:Create(pf2,TweenInfo.new(0.1),{BackgroundColor3=CARD}):Play()
                            hrp.CFrame=t.CFrame+Vector3.new(0,0,3)
                        end
                    end
                end)
            end)
        end
    end
    task.spawn(function() while sg and sg.Parent do pcall(rebuildPL) task.wait(3) end end)
    Players.PlayerAdded:Connect(function() task.wait(1) pcall(rebuildPL) end)
    Players.PlayerRemoving:Connect(function() task.wait(0.5) pcall(rebuildPL) end)

    -- ════════════════════════════════════════
    --   ВКЛАДКА: TROL v4
    -- ════════════════════════════════════════
    mkSec("Trol","😈 Выбери жертву")
    local victimLabel=Instance.new("Frame") victimLabel.Size=UDim2.new(1,0,0,34) victimLabel.BackgroundColor3=CARD victimLabel.BorderSizePixel=0
    Instance.new("UICorner",victimLabel).CornerRadius=UDim.new(0,8) Instance.new("UIStroke",victimLabel).Color=Color3.fromRGB(200,50,50)
    local vl=Instance.new("TextLabel",victimLabel) vl.Size=UDim2.new(1,0,1,0) vl.BackgroundTransparency=1 vl.Text="😈 Жертва: "..victimName vl.TextColor3=Color3.fromRGB(255,80,80) vl.Font=Enum.Font.GothamBold vl.TextSize=12
    table.insert(tabContent["Trol"],victimLabel)

    local trollPLF=Instance.new("Frame") trollPLF.Size=UDim2.new(1,0,0,10) trollPLF.BackgroundTransparency=1 trollPLF.AutomaticSize=Enum.AutomaticSize.Y trollPLF.BorderSizePixel=0
    Instance.new("UIListLayout",trollPLF).Padding=UDim.new(0,3)
    table.insert(tabContent["Trol"],trollPLF)

    local function rebuildTrollList()
        for _,ch in ipairs(trollPLF:GetChildren()) do if ch:IsA("Frame") then ch:Destroy() end end
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP then continue end
            local pf3=Instance.new("Frame",trollPLF) pf3.Size=UDim2.new(1,0,0,30) pf3.BackgroundColor3=CARD pf3.BorderSizePixel=0
            Instance.new("UICorner",pf3).CornerRadius=UDim.new(0,7) Instance.new("UIStroke",pf3).Color=BORDER
            local nm=Instance.new("TextLabel",pf3) nm.Size=UDim2.new(1,-55,1,0) nm.Position=UDim2.new(0,10,0,0) nm.BackgroundTransparency=1 nm.Text=p.Name nm.TextColor3=WHITE nm.Font=Enum.Font.GothamBold nm.TextSize=11 nm.TextXAlignment=Enum.TextXAlignment.Left
            local selLbl=Instance.new("TextLabel",pf3) selLbl.Size=UDim2.new(0,44,1,0) selLbl.Position=UDim2.new(1,-46,0,0) selLbl.BackgroundTransparency=1 selLbl.Text="▶ Выбрать" selLbl.TextColor3=Color3.fromRGB(255,100,100) selLbl.Font=Enum.Font.GothamBold selLbl.TextSize=9
            local tb2=Instance.new("TextButton",pf3) tb2.Size=UDim2.new(1,0,1,0) tb2.BackgroundTransparency=1 tb2.Text=""
            tb2.MouseButton1Click:Connect(function()
                victimName=p.Name vl.Text="😈 Жертва: "..victimName
                TweenService:Create(pf3,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(60,10,10)}):Play()
                task.wait(0.2) TweenService:Create(pf3,TweenInfo.new(0.1),{BackgroundColor3=CARD}):Play()
                notify("😈 Жертва","Выбран: "..victimName,2)
            end)
        end
    end
    task.spawn(function() while sg and sg.Parent do pcall(rebuildTrollList) task.wait(4) end end)

    mkSec("Trol","Действия над жертвой")
    mkToggle("Trol","👣 Постоянно следить (мешать)",nil,function(v) followActive=v end)
    mkToggle("Trol","🚧 Блокировать путь жертве",nil,function(v) blockActive=v end)
    mkToggle("Trol","🔪 Мешать Убийце (прыгать на него)",nil,function(v) annoyMurdActive=v end)

    mkButton("Trol","💢 TP прямо на жертву",Color3.fromRGB(80,10,10),function()
        pcall(function()
            local hrp=getHRP() if not hrp then return end
            for _,p in ipairs(Players:GetPlayers()) do
                if p.Name==victimName and p.Character then
                    local t=p.Character:FindFirstChild("HumanoidRootPart")
                    if t then hrp.CFrame=t.CFrame end
                end
            end
        end)
    end)

    mkButton("Trol","💥 Спам TP на жертву (4 сек)",Color3.fromRGB(60,10,10),function()
        task.spawn(function()
            for i=1,25 do task.wait(0.16)
                pcall(function()
                    local hrp=getHRP() if not hrp then return end
                    for _,p in ipairs(Players:GetPlayers()) do
                        if p.Name==victimName and p.Character then
                            local t=p.Character:FindFirstChild("HumanoidRootPart")
                            if t then hrp.CFrame=t.CFrame*CFrame.new(math.random(-3,3),0,math.random(-3,3)) end
                        end
                    end
                end)
            end
        end)
    end)

    mkButton("Trol","🚀 Прыгнуть на жертву сверху",Color3.fromRGB(50,20,80),function()
        pcall(function()
            local hrp=getHRP() if not hrp then return end
            for _,p in ipairs(Players:GetPlayers()) do
                if p.Name==victimName and p.Character then
                    local t=p.Character:FindFirstChild("HumanoidRootPart")
                    if t then
                        hrp.CFrame=CFrame.new(t.Position+Vector3.new(0,28,0))
                        hrp.Velocity=Vector3.new(0,-80,0)
                    end
                end
            end
        end)
    end)

    mkButton("Trol","😤 Стоять вплотную к жертве",Color3.fromRGB(40,20,5),function()
        pcall(function()
            local hrp=getHRP() if not hrp then return end
            for _,p in ipairs(Players:GetPlayers()) do
                if p.Name==victimName and p.Character then
                    local t=p.Character:FindFirstChild("HumanoidRootPart")
                    if t then hrp.CFrame=CFrame.new(t.Position+Vector3.new(0,0,0.8),t.Position) end
                end
            end
        end)
    end)

    mkButton("Trol","🌀 Фризнуть экран жертвы (ESP)",Color3.fromRGB(30,10,60),function()
        task.spawn(function()
            local hrp=getHRP() if not hrp then return end
            local origPos=hrp.CFrame
            for i=1,40 do task.wait(0.04)
                pcall(function() hrp.CFrame=origPos*CFrame.new(math.random(-50,50),math.random(-5,30),math.random(-50,50)) end)
            end
            task.wait(0.1) hrp.CFrame=origPos
        end)
    end)

    mkButton("Trol","👁 Узнать роль жертвы",Color3.fromRGB(20,30,60),function()
        for _,p in ipairs(Players:GetPlayers()) do
            if p.Name==victimName then
                local r=getRole(p)
                notify("👁 "..victimName,(r=="Murderer" and "🔪 ЭТО УБИЙЦА!" or r=="Sheriff" and "🔫 ЭТО ШЕРИФ!" or "😇 Невинный"),5)
            end
        end
    end)

    mkButton("Trol","🎭 Показать роли ВСЕХ",Color3.fromRGB(30,20,60),function()
        task.spawn(function()
            local m,s,inn={},{},{}
            for _,p in ipairs(Players:GetPlayers()) do
                if p~=LP then local r=getRole(p)
                    if r=="Murderer" then table.insert(m,p.Name)
                    elseif r=="Sheriff" then table.insert(s,p.Name)
                    else table.insert(inn,p.Name) end
                end
            end
            local txt=""
            if #m>0 then txt=txt.."🔪 "..table.concat(m,", ").." | " end
            if #s>0 then txt=txt.."🔫 "..table.concat(s,", ").." | " end
            if #inn>0 then txt=txt.."😇 "..table.concat(inn,", ") end
            notify("👁 ESP Роли",txt,7)
        end)
    end)

    mkButton("Trol","💣 Быстрые телепорты (дезориентация)",Color3.fromRGB(80,30,0),function()
        task.spawn(function()
            local hrp=getHRP() if not hrp then return end
            local orig=hrp.CFrame
            for i=1,15 do
                task.wait(0.07)
                pcall(function()
                    hrp.CFrame=orig*CFrame.new(math.random(-30,30),math.random(0,15),math.random(-30,30))
                end)
            end
            hrp.CFrame=orig
        end)
    end)

    mkButton("Trol","🔁 Телепортировать жертву (к себе)",Color3.fromRGB(60,0,60),function()
        pcall(function()
            -- Локальный телепорт (только визуально)
            local hrp=getHRP() if not hrp then return end
            for _,p in ipairs(Players:GetPlayers()) do
                if p.Name==victimName and p.Character then
                    local victHRP=p.Character:FindFirstChild("HumanoidRootPart")
                    if victHRP then
                        victHRP.CFrame=hrp.CFrame*CFrame.new(0,0,3)
                        notify("Trol","Жертва притянута (локально)",2)
                    end
                end
            end
        end)
    end)

    -- ════════════════════════════════════════
    --   ВКЛАДКА: MISC
    -- ════════════════════════════════════════
    mkSec("Misc","Разное")
    mkToggle("Misc","☀ Fullbright","fullbright",function(v) setFB(v) end)
    mkToggle("Misc","🌫 No Fog","noFog",function(v) setNoFog(v) end)
    mkToggle("Misc","👻 Hide Player","hide",function(v) hidePlayer(v) end)
    mkToggle("Misc","🗿 Big Head","bigHead")
    mkToggle("Misc","🌀 Spin Bot","spinBot")
    mkToggle("Misc","🦘 Infinite Jump","infiniteJump")
    mkSec("Misc","Быстрые действия")
    mkButton("Misc","📸 Скриншот координат",DIM,function()
        pcall(function()
            local hrp=getHRP() if not hrp then return end
            local p=hrp.Position
            notify("📍 Позиция","X:"..math.floor(p.X).." Y:"..math.floor(p.Y).." Z:"..math.floor(p.Z),5)
        end)
    end)
    mkButton("Misc","🧹 Стелс (выкл все читы)",Color3.fromRGB(20,45,20),function()
        CFG.coinFarm=false CFG.bringCoins=false CFG.knife=false CFG.speed=false CFG.bhop=false
        CFG.bypass=false CFG.esp=false CFG.chams=false CFG.tracers=false CFG.noclip=false
        CFG.aimbot=false CFG.spinBot=false CFG.fly=false
        enableFly(false)
        pcall(function() local h=getHum() if h then h.WalkSpeed=16 h.JumpPower=50 end end)
        notify("🧹 Стелс","Все читы выключены",3)
    end)
    mkButton("Misc","🔄 Перезапустить персонажа",Color3.fromRGB(25,25,55),function()
        pcall(function() LP:LoadCharacter() end)
    end)
    mkButton("Misc","📋 Версия",DIM,function()
        notify("Primejtsu Hub","v6.0 | @Primejtsu | Nazar513000",4)
    end)

    task.wait(0.15)
    switchTab("Info")
end -- showGUI

-- ════════════════════════════════════════════════════════════════
--   ЗАПУСК — сначала заставка потом UI
-- ════════════════════════════════════════════════════════════════
task.spawn(function()
    task.wait(4.5)
    -- Убираем заставку
    TweenService:Create(Splash,TweenInfo.new(0.8,Enum.EasingStyle.Quart),{BackgroundTransparency=1}):Play()
    for _,v in ipairs(Splash:GetDescendants()) do
        pcall(function()
            if v:IsA("TextLabel") then TweenService:Create(v,TweenInfo.new(0.5),{TextTransparency=1}):Play()
            elseif v:IsA("Frame") then TweenService:Create(v,TweenInfo.new(0.5),{BackgroundTransparency=1}):Play()
                local st=v:FindFirstChildOfClass("UIStroke") if st then TweenService:Create(st,TweenInfo.new(0.5),{Transparency=1}):Play() end
            end
        end)
    end
    task.wait(0.9)
    Splash:Destroy()
    -- Показываем UI
    showGUI()
end)

print("[Primejtsu Hub v6.0] @Primejtsu | Nazar513000 | CoinFarm v4 + ESP v2 + Fly + Aimbot + Tracers + Chams 🪐😈")

-- ════════════════════════════════════════════════════════════════
--   ДОПОЛНИТЕЛЬНЫЕ ТОПОВЫЕ ФИЧИ v6.0
-- ════════════════════════════════════════════════════════════════

-- ────────────────────────────────────────
--  RADAR — мини-карта с точками игроков
-- ────────────────────────────────────────
local radarGui = Instance.new("ScreenGui", CoreGui)
radarGui.Name = "PTHRadar"
radarGui.ResetOnSpawn = false
radarGui.Enabled = false

local radarFrame = Instance.new("Frame", radarGui)
radarFrame.Size = UDim2.new(0, 160, 0, 160)
radarFrame.Position = UDim2.new(1, -175, 1, -175)
radarFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
radarFrame.BackgroundTransparency = 0.25
radarFrame.BorderSizePixel = 0
Instance.new("UICorner", radarFrame).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", radarFrame).Color = Color3.fromRGB(215, 25, 25)

local radarTitle = Instance.new("TextLabel", radarFrame)
radarTitle.Size = UDim2.new(1, 0, 0, 16)
radarTitle.BackgroundTransparency = 1
radarTitle.Text = "📡 RADAR"
radarTitle.TextColor3 = Color3.fromRGB(215, 25, 25)
radarTitle.Font = Enum.Font.GothamBold
radarTitle.TextSize = 10

-- Центральная точка (ты)
local selfDot = Instance.new("Frame", radarFrame)
selfDot.Size = UDim2.new(0, 8, 0, 8)
selfDot.AnchorPoint = Vector2.new(0.5, 0.5)
selfDot.Position = UDim2.new(0.5, 0, 0.5, 0)
selfDot.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
selfDot.BorderSizePixel = 0
Instance.new("UICorner", selfDot).CornerRadius = UDim.new(1, 0)

-- Обновление радара
local radarDots = {}
RunService.Heartbeat:Connect(function()
    radarGui.Enabled = CFG.radarDot
    if not CFG.radarDot then
        for _,d in pairs(radarDots) do pcall(function() d:Destroy() end) end
        radarDots = {}
        return
    end
    local hrp = getHRP()
    if not hrp then return end
    local myPos = hrp.Position
    local radarScale = 4 -- 1 stuд = 4 пикселя

    -- Удаляем старые точки
    for p,d in pairs(radarDots) do
        if not p or not p.Parent then pcall(function() d:Destroy() end) radarDots[p]=nil end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        if not p.Character then continue end
        local pHRP = p.Character:FindFirstChild("HumanoidRootPart")
        if not pHRP then continue end

        if not radarDots[p] then
            local dot = Instance.new("Frame", radarFrame)
            dot.Size = UDim2.new(0, 7, 0, 7)
            dot.AnchorPoint = Vector2.new(0.5, 0.5)
            dot.BorderSizePixel = 0
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
            local nameLbl = Instance.new("TextLabel", dot)
            nameLbl.Size = UDim2.new(0, 50, 0, 12)
            nameLbl.Position = UDim2.new(0.5, -25, 1, 1)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text = p.Name:sub(1, 8)
            nameLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
            nameLbl.Font = Enum.Font.Code
            nameLbl.TextSize = 8
            radarDots[p] = dot
        end

        local dot = radarDots[p]
        local role = getRole(p)
        dot.BackgroundColor3 = ROLE_COLORS[role] or Color3.fromRGB(200, 200, 200)

        local diff = pHRP.Position - myPos
        local rx = math.clamp(diff.X / radarScale, -75, 75)
        local rz = math.clamp(diff.Z / radarScale, -75, 75)
        dot.Position = UDim2.new(0.5, rx, 0.5, rz)
    end
end)

-- ────────────────────────────────────────
--  KILL / DEATH COUNTER
-- ────────────────────────────────────────
local kdGui = Instance.new("ScreenGui", CoreGui)
kdGui.Name = "PTHKillCounter"
kdGui.ResetOnSpawn = false

local kdFrame = Instance.new("Frame", kdGui)
kdFrame.Size = UDim2.new(0, 120, 0, 50)
kdFrame.Position = UDim2.new(1, -135, 0, 10)
kdFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
kdFrame.BackgroundTransparency = 0.3
kdFrame.BorderSizePixel = 0
Instance.new("UICorner", kdFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", kdFrame).Color = Color3.fromRGB(38, 38, 46)

local killsVal = 0
local deathsVal = 0

local kLabel = Instance.new("TextLabel", kdFrame)
kLabel.Size = UDim2.new(0.5, 0, 1, 0)
kLabel.BackgroundTransparency = 1
kLabel.Text = "🔪 0"
kLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
kLabel.Font = Enum.Font.GothamBold
kLabel.TextSize = 16

local dLabel = Instance.new("TextLabel", kdFrame)
dLabel.Size = UDim2.new(0.5, 0, 1, 0)
dLabel.Position = UDim2.new(0.5, 0, 0, 0)
dLabel.BackgroundTransparency = 1
dLabel.Text = "💀 0"
dLabel.TextColor3 = Color3.fromRGB(100, 100, 150)
dLabel.Font = Enum.Font.GothamBold
dLabel.TextSize = 16

-- Следим за смертями
LP.CharacterAdded:Connect(function()
    deathsVal = deathsVal + 1
    dLabel.Text = "💀 " .. deathsVal
end)

-- Следим за смертями игроков рядом (как убийство)
Players.PlayerRemoving:Connect(function(p)
    if p ~= LP then
        -- Проверяем был ли убит рядом с нами
        pcall(function()
            local hrp = getHRP()
            if not hrp then return end
            local pHRP = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if pHRP and (hrp.Position - pHRP.Position).Magnitude < 30 then
                -- Мог быть убит нами (примерно)
            end
        end)
    end
end)

-- ────────────────────────────────────────
--  CUSTOM CROSSHAIR
-- ────────────────────────────────────────
local crosshairGui = Instance.new("ScreenGui", CoreGui)
crosshairGui.Name = "PTHCrosshair"
crosshairGui.ResetOnSpawn = false
crosshairGui.Enabled = false

local crossSize = 20
local crossThick = 2
local crossColor = Color3.fromRGB(255, 50, 50)
local crossGap = 5

local function createCrosshair()
    crosshairGui:ClearAllChildren()
    local vp = Camera.ViewportSize
    local cx = vp.X / 2
    local cy = vp.Y / 2

    -- Горизонтальная линия левая
    local hl = Instance.new("Frame", crosshairGui)
    hl.Size = UDim2.new(0, crossSize, 0, crossThick)
    hl.Position = UDim2.new(0, cx - crossSize - crossGap, 0, cy - crossThick/2)
    hl.BackgroundColor3 = crossColor hl.BorderSizePixel = 0
    Instance.new("UICorner", hl).CornerRadius = UDim.new(1, 0)

    -- Горизонтальная линия правая
    local hr = Instance.new("Frame", crosshairGui)
    hr.Size = UDim2.new(0, crossSize, 0, crossThick)
    hr.Position = UDim2.new(0, cx + crossGap, 0, cy - crossThick/2)
    hr.BackgroundColor3 = crossColor hr.BorderSizePixel = 0
    Instance.new("UICorner", hr).CornerRadius = UDim.new(1, 0)

    -- Вертикальная линия верхняя
    local vu2 = Instance.new("Frame", crosshairGui)
    vu2.Size = UDim2.new(0, crossThick, 0, crossSize)
    vu2.Position = UDim2.new(0, cx - crossThick/2, 0, cy - crossSize - crossGap)
    vu2.BackgroundColor3 = crossColor vu2.BorderSizePixel = 0
    Instance.new("UICorner", vu2).CornerRadius = UDim.new(1, 0)

    -- Вертикальная линия нижняя
    local vd = Instance.new("Frame", crosshairGui)
    vd.Size = UDim2.new(0, crossThick, 0, crossSize)
    vd.Position = UDim2.new(0, cx - crossThick/2, 0, cy + crossGap)
    vd.BackgroundColor3 = crossColor vd.BorderSizePixel = 0
    Instance.new("UICorner", vd).CornerRadius = UDim.new(1, 0)

    -- Центральная точка
    local dot = Instance.new("Frame", crosshairGui)
    dot.Size = UDim2.new(0, 4, 0, 4)
    dot.Position = UDim2.new(0, cx - 2, 0, cy - 2)
    dot.BackgroundColor3 = crossColor dot.BorderSizePixel = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
end

local crosshairEnabled = false
local function toggleCrosshair(v)
    crosshairEnabled = v
    crosshairGui.Enabled = v
    if v then createCrosshair() end
end

-- Перестраиваем при изменении размера экрана
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    if crosshairEnabled then createCrosshair() end
end)

-- ────────────────────────────────────────
--  FOV CHANGER — меняет поле зрения
-- ────────────────────────────────────────
local defaultFOV = 70
RunService.RenderStepped:Connect(function()
    -- FOV восстанавливается если не изменён
end)

local function setFOV(v)
    Camera.FieldOfView = v
end

-- ────────────────────────────────────────
--  WALKSPEED DISPLAY — показывает скорость на экране
-- ────────────────────────────────────────
local wsGui = Instance.new("ScreenGui", CoreGui)
wsGui.Name = "PTHSpeedDisplay"
wsGui.ResetOnSpawn = false

local wsFrame = Instance.new("Frame", wsGui)
wsFrame.Size = UDim2.new(0, 100, 0, 26)
wsFrame.Position = UDim2.new(0.5, -50, 1, -70)
wsFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
wsFrame.BackgroundTransparency = 0.4
wsFrame.BorderSizePixel = 0
Instance.new("UICorner", wsFrame).CornerRadius = UDim.new(0, 6)

local wsLabel = Instance.new("TextLabel", wsFrame)
wsLabel.Size = UDim2.new(1, 0, 1, 0)
wsLabel.BackgroundTransparency = 1
wsLabel.Font = Enum.Font.Code
wsLabel.TextSize = 12
wsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)

RunService.Heartbeat:Connect(function()
    local hum = getHum()
    if hum then
        wsLabel.Text = "⚡ WS: " .. math.floor(hum.WalkSpeed)
    end
end)

-- ────────────────────────────────────────
--  CHAT SPY — видит удалённые сообщения
-- ────────────────────────────────────────
local chatLog = {}
local chatSpyEnabled = false

-- Подключаемся к чату
pcall(function()
    local Chat = game:GetService("Chat")
    -- Перехватываем сообщения через локальный скрипт
    Players.PlayerAdded:Connect(function(p)
        p.Chatted:Connect(function(msg)
            if chatSpyEnabled then
                table.insert(chatLog, {player=p.Name, msg=msg, time=os.clock()})
                notify("💬 " .. p.Name, msg:sub(1,80), 4)
            end
        end)
    end)
    for _, p in ipairs(Players:GetPlayers()) do
        p.Chatted:Connect(function(msg)
            if chatSpyEnabled then
                table.insert(chatLog, {player=p.Name, msg=msg, time=os.clock()})
                notify("💬 " .. p.Name, msg:sub(1,80), 4)
            end
        end)
    end
end)

-- ────────────────────────────────────────
--  ITEM ESP — показывает нож на карте
-- ────────────────────────────────────────
local knifeESPEnabled = false
local knifeESPObjects = {}

local function updateKnifeESP()
    if not knifeESPEnabled then
        for _,v in pairs(knifeESPObjects) do pcall(function() v:Destroy() end) end
        knifeESPObjects = {}
        return
    end
    -- Ищем нож в workspace
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") or obj:IsA("Model") then
            local n = obj.Name:lower()
            if (n:find("knife") or n:find("gun") or n:find("sheriff")) and not knifeESPObjects[obj] then
                pcall(function()
                    local part = obj:IsA("BasePart") and obj or obj:FindFirstChildOfClass("BasePart")
                    if not part then return end
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "KnifeESP" bb.AlwaysOnTop = true
                    bb.Size = UDim2.new(0, 80, 0, 30)
                    bb.StudsOffset = Vector3.new(0, 3, 0)
                    bb.Adornee = part bb.Parent = part
                    local lbl = Instance.new("TextLabel", bb)
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = (n:find("knife") and "🔪 НОЖ" or "🔫 ПИСТОЛЕТ")
                    lbl.TextColor3 = n:find("knife") and Color3.fromRGB(255,50,50) or Color3.fromRGB(50,130,255)
                    lbl.Font = Enum.Font.GothamBlack lbl.TextSize = 14
                    lbl.TextStrokeTransparency = 0 lbl.TextStrokeColor3 = Color3.new(0,0,0)
                    knifeESPObjects[obj] = bb
                end)
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    if knifeESPEnabled then updateKnifeESP() end
end)

-- ────────────────────────────────────────
--  WALL HIGHLIGHT — подсвечивает стены
-- ────────────────────────────────────────
local wallHighlight = nil
local function toggleWallHL(v)
    if v then
        wallHighlight = Instance.new("SelectionBox", CoreGui)
        -- Подсвечиваем весь workspace
        wallHighlight.Adornee = workspace
        wallHighlight.Color3 = Color3.fromRGB(0, 100, 255)
        wallHighlight.SurfaceTransparency = 0.9
        wallHighlight.LineThickness = 0.02
    else
        if wallHighlight then pcall(function() wallHighlight:Destroy() end) wallHighlight=nil end
    end
end

-- ────────────────────────────────────────
--  INFINITE STAMINA (некоторые игры)
-- ────────────────────────────────────────
RunService.Heartbeat:Connect(function()
    pcall(function()
        local c = getChar() if not c then return end
        local stamina = c:FindFirstChild("Stamina") or c:FindFirstChild("Energy")
        if stamina and stamina:IsA("NumberValue") then
            stamina.Value = stamina.Value < 50 and 100 or stamina.Value
        end
    end)
end)

-- ────────────────────────────────────────
--  SAFE ZONE INDICATOR
-- ────────────────────────────────────────
task.spawn(function()
    while true do
        task.wait(2)
        pcall(function()
            local hrp = getHRP() if not hrp then return end
            -- Ищем зоны безопасности в MM2
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local n = obj.Name:lower()
                    if n:find("safe") or n:find("lobby") then
                        local dist = (hrp.Position - obj.Position).Magnitude
                        if dist < 10 then
                            -- В безопасной зоне
                        end
                    end
                end
            end
        end)
    end
end)

-- ────────────────────────────────────────
--  PLAYER NOTES — заметки на игроков
-- ────────────────────────────────────────
local playerNotes = {}

local function setNote(playerName, note)
    playerNotes[playerName] = note
end

local function getNote(playerName)
    return playerNotes[playerName] or ""
end

-- ────────────────────────────────────────
--  ROUND TIMER — показывает таймер раунда
-- ────────────────────────────────────────
local roundTimerGui = Instance.new("ScreenGui", CoreGui)
roundTimerGui.Name = "PTHRoundTimer"
roundTimerGui.ResetOnSpawn = false

local rtFrame = Instance.new("Frame", roundTimerGui)
rtFrame.Size = UDim2.new(0, 120, 0, 30)
rtFrame.Position = UDim2.new(0.5, -60, 0, 50)
rtFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
rtFrame.BackgroundTransparency = 0.35
rtFrame.BorderSizePixel = 0
Instance.new("UICorner", rtFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", rtFrame).Color = Color3.fromRGB(38, 38, 46)

local rtLabel = Instance.new("TextLabel", rtFrame)
rtLabel.Size = UDim2.new(1, 0, 1, 0)
rtLabel.BackgroundTransparency = 1
rtLabel.Font = Enum.Font.GothamBold
rtLabel.TextSize = 13
rtLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
rtLabel.Text = "⏱ Раунд"

-- Ищем таймер в игре
task.spawn(function()
    while true do
        task.wait(0.5)
        pcall(function()
            -- Ищем TimerLabel или похожие
            for _, obj in ipairs(LP.PlayerGui:GetDescendants()) do
                if obj:IsA("TextLabel") then
                    local t = obj.Text
                    if t:match("^%d+:%d+$") or t:match("^%d+s?$") then
                        rtLabel.Text = "⏱ " .. t
                        break
                    end
                end
            end
        end)
    end
end)

-- ────────────────────────────────────────
--  EXTENDED UI — добавляем новые кнопки в уже созданный UI
--  (делается через отдельный ScreenGui чтобы не ломать основной)
-- ────────────────────────────────────────

-- Добавляем кнопки в уже открытый GUI (когда showGUI уже запустился)
-- Эти фичи доступны через Visual и Misc вкладки

-- ────────────────────────────────────────
--  АВТОМАТИЧЕСКОЕ ОБНАРУЖЕНИЕ МОНЕТ v4.1
--  Улучшенный поиск — сканирует не только имена но и теги
-- ────────────────────────────────────────
local coinScanCache = {}
local function refreshCoinCache()
    coinScanCache = {}
    for _,o in ipairs(workspace:GetDescendants()) do
        if isCoin(o) then
            table.insert(coinScanCache, o)
        end
    end
end

-- Обновляем кэш каждые 2 секунды вместо каждого кадра
task.spawn(function()
    while true do
        task.wait(1.5)
        if CFG.coinFarm or CFG.bringCoins then
            pcall(refreshCoinCache)
        end
    end
end)

-- ────────────────────────────────────────
--  LOBBY DETECTOR — определяет фазу игры
-- ────────────────────────────────────────
local gamePhase = "Lobby" -- Lobby, Waiting, Playing, Ending

task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            -- Пытаемся определить фазу по наличию монет и игрового состояния
            local hasMurderer = false
            for _, p in ipairs(Players:GetPlayers()) do
                if getRole(p) == "Murderer" then hasMurderer = true break end
            end
            if hasMurderer then
                gamePhase = "Playing"
            else
                gamePhase = "Lobby"
            end
        end)
    end
end)

-- ────────────────────────────────────────
--  AUTO COLLECT ON TOUCH — ещё один метод
--  Автоматически стреляет touch на ВСЕ монеты поблизости
-- ────────────────────────────────────────
task.spawn(function()
    while true do
        task.wait(0.2)
        if not CFG.coinFarm then continue end
        local hrp = getHRP() if not hrp then continue end
        pcall(function()
            for _, o in ipairs(workspace:GetDescendants()) do
                if isCoin(o) then
                    local dist = (hrp.Position - o.Position).Magnitude
                    if dist < 8 then
                        -- Рядом — стреляем touch без движения
                        firetouchinterest(hrp, o, 0)
                        firetouchinterest(hrp, o, 1)
                        -- ClickDetector
                        local cd = o:FindFirstChildOfClass("ClickDetector")
                        if not cd and o.Parent then cd = o.Parent:FindFirstChildOfClass("ClickDetector") end
                        if cd then fireclickdetector(cd) end
                    end
                end
            end
        end)
    end
end)

-- ────────────────────────────────────────
--  HOTKEYS — горячие клавиши
-- ────────────────────────────────────────
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    -- F1 — включить/выключить ESP
    if input.KeyCode == Enum.KeyCode.F1 then
        CFG.esp = not CFG.esp
        notify("ESP", CFG.esp and "Включён" or "Выключен", 1.5)
    end
    -- F2 — включить/выключить CoinFarm
    if input.KeyCode == Enum.KeyCode.F2 then
        CFG.coinFarm = not CFG.coinFarm
        notify("CoinFarm", CFG.coinFarm and "Включён" or "Выключен", 1.5)
    end
    -- F3 — включить/выключить Speed
    if input.KeyCode == Enum.KeyCode.F3 then
        CFG.speed = not CFG.speed
        notify("Speed", CFG.speed and "Включён" or "Выключен", 1.5)
    end
    -- F4 — включить/выключить God Mode
    if input.KeyCode == Enum.KeyCode.F4 then
        CFG.god = not CFG.god
        if CFG.god then applyGod(true) end
        notify("God Mode", CFG.god and "Включён" or "Выключен", 1.5)
    end
    -- F5 — включить/выключить Noclip
    if input.KeyCode == Enum.KeyCode.F5 then
        CFG.noclip = not CFG.noclip
        notify("Noclip", CFG.noclip and "Включён" or "Выключен", 1.5)
    end
    -- F6 — включить/выключить Fly
    if input.KeyCode == Enum.KeyCode.F6 then
        CFG.fly = not CFG.fly
        enableFly(CFG.fly)
        notify("Fly", CFG.fly and "Включён" or "Выключен", 1.5)
    end
    -- F7 — TP к убийце
    if input.KeyCode == Enum.KeyCode.F7 then
        tpToRole("Murderer")
    end
    -- F8 — стелс (выключить всё)
    if input.KeyCode == Enum.KeyCode.F8 then
        CFG.coinFarm=false CFG.speed=false CFG.bhop=false CFG.bypass=false
        CFG.esp=false CFG.noclip=false CFG.aimbot=false CFG.spinBot=false CFG.fly=false
        enableFly(false)
        pcall(function() local h=getHum() if h then h.WalkSpeed=16 end end)
        notify("🧹 F8 Стелс","Все читы выключены",2)
    end
end)

-- ────────────────────────────────────────
--  NOTIFICATION при запуске
-- ────────────────────────────────────────
task.spawn(function()
    task.wait(5.2)
    notify("🪐 Primejtsu Hub v6.0","Загружен! Хоткеи: F1=ESP F2=Farm F3=Speed F4=God F6=Fly F8=Стелс",6)
end)

-- ────────────────────────────────────────
--  МОНИТОРИНГ ИГРЫ — уведомления о событиях
-- ────────────────────────────────────────
local lastMurderer = ""
task.spawn(function()
    while true do
        task.wait(3)
        pcall(function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and getRole(p) == "Murderer" then
                    if p.Name ~= lastMurderer then
                        lastMurderer = p.Name
                        if CFG.esp then
                            notify("🔪 УБИЙЦА НАЙДЕН", p.Name .. " — УБИЙЦА!", 5)
                        end
                    end
                end
            end
        end)
    end
end)

-- ────────────────────────────────────────
--  SCOPE / ZOOM для шерифа
-- ────────────────────────────────────────
local scopeActive = false
local origFOV = 70
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Z then
        scopeActive = not scopeActive
        if scopeActive then
            TweenService:Create(Camera, TweenInfo.new(0.3), {FieldOfView = 20}):Play()
            notify("🔭 Scope","Зум включён (Z для отключения)",2)
        else
            TweenService:Create(Camera, TweenInfo.new(0.3), {FieldOfView = 70}):Play()
        end
    end
end)

-- ────────────────────────────────────────
--  БЕЗОПАСНЫЙ ВЫХОД
-- ────────────────────────────────────────
game:GetService("CoreGui").DescendantRemoving:Connect(function(d)
    if d.Name == "PTH60" then
        -- Очищаем всё при удалении GUI
        for p in pairs(espObjects) do removeESP(p) end
        for p in pairs(chamObjects) do removeCham(p) end
        enableFly(false)
    end
end)

-- ────────────────────────────────────────
--  ИТОГОВЫЙ ВЫВОД В КОНСОЛЬ
-- ────────────────────────────────────────
print("╔══════════════════════════════════════════╗")
print("║    Primejtsu Hub v6.0 | @Primejtsu       ║")
print("║    Nazar513000 | MM2 MEGA UPDATE          ║")
print("╠══════════════════════════════════════════╣")
print("║  CoinFarm v4  |  ESP v2  |  Fly          ║")
print("║  Aimbot  |  Tracers  |  Chams  |  Radar  ║")
print("║  Crosshair  |  ChatSpy  |  HotKeys       ║")
print("║  Hotkeys: F1-F8 для быстрого включения   ║")
print("╚══════════════════════════════════════════╝")

-- ════════════════════════════════════════════════════════════════
--   ДОПОЛНИТЕЛЬНЫЙ UI — Radar, Crosshair, Visual настройки
--   Добавляется ПОСЛЕ showGUI() через отдельную функцию
-- ════════════════════════════════════════════════════════════════
local extraUIAdded = false

local function addExtraUI()
    if extraUIAdded then return end
    extraUIAdded = true

    -- Ищем основной ScreenGui и добавляем кнопки
    task.spawn(function()
        task.wait(5.5) -- Ждём пока showGUI() полностью загрузится

        -- Второй мини-тулбар снизу-слева
        local miniBar = Instance.new("Frame", CoreGui:FindFirstChild("PTH60") or sg)
        miniBar.Size = UDim2.new(0, 220, 0, 38)
        miniBar.Position = UDim2.new(0, 8, 1, -52)
        miniBar.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
        miniBar.BackgroundTransparency = 0.2
        miniBar.BorderSizePixel = 0
        Instance.new("UICorner", miniBar).CornerRadius = UDim.new(0, 8)
        Instance.new("UIStroke", miniBar).Color = Color3.fromRGB(38, 38, 46)

        local barLayout = Instance.new("UIListLayout", miniBar)
        barLayout.FillDirection = Enum.FillDirection.Horizontal
        barLayout.Padding = UDim.new(0, 2)
        barLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        Instance.new("UIPadding", miniBar).PaddingLeft = UDim.new(0, 4)

        local function mkMiniBtn(text, color, fn)
            local b = Instance.new("TextButton", miniBar)
            b.Size = UDim2.new(0, 50, 0, 28)
            b.BackgroundColor3 = color
            b.BorderSizePixel = 0
            b.Text = text
            b.TextColor3 = Color3.fromRGB(228, 228, 228)
            b.Font = Enum.Font.GothamBold
            b.TextSize = 9
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
            b.MouseButton1Click:Connect(fn)
            b.TouchTap:Connect(fn)
            return b
        end

        -- Радар
        local radarBtn = mkMiniBtn("📡 Радар", Color3.fromRGB(15,30,15), function()
            CFG.radarDot = not CFG.radarDot
            radarGui.Enabled = CFG.radarDot
            notify("Радар", CFG.radarDot and "Включён" or "Выключен", 1.5)
        end)

        -- Прицел
        local crossBtn = mkMiniBtn("🎯 Прицел", Color3.fromRGB(35,10,10), function()
            toggleCrosshair(not crosshairEnabled)
            notify("Прицел", crosshairEnabled and "Включён" or "Выключен", 1.5)
        end)

        -- Chat Spy
        local chatBtn = mkMiniBtn("💬 Чат", Color3.fromRGB(15,15,35), function()
            chatSpyEnabled = not chatSpyEnabled
            notify("Chat Spy", chatSpyEnabled and "Включён" or "Выключен", 1.5)
        end)

        -- Item ESP
        local itemBtn = mkMiniBtn("🔪 ItemESP", Color3.fromRGB(30,10,10), function()
            knifeESPEnabled = not knifeESPEnabled
            if not knifeESPEnabled then
                for _,v in pairs(knifeESPObjects) do pcall(function() v:Destroy() end) end
                knifeESPObjects = {}
            end
            notify("Item ESP", knifeESPEnabled and "Включён" or "Выключен", 1.5)
        end)

        -- Scope
        local scopeBtn = mkMiniBtn("🔭 Зум", Color3.fromRGB(10,20,30), function()
            scopeActive = not scopeActive
            if scopeActive then
                TweenService:Create(Camera, TweenInfo.new(0.3), {FieldOfView = 25}):Play()
            else
                TweenService:Create(Camera, TweenInfo.new(0.3), {FieldOfView = 70}):Play()
            end
            notify("Zoom", scopeActive and "x3" or "Normal", 1.5)
        end)
    end)
end

addExtraUI()

-- ════════════════════════════════════════════════════════════════
--   ПРОДВИНУТЫЙ AIMBOT v2
--   Плавный поворот камеры, FOV настройка, включение по кнопке мыши
-- ════════════════════════════════════════════════════════════════
local aimbotFOV = 150 -- Радиус обнаружения в пикселях
local aimbotSmooth = 0.15 -- Плавность (0.05 = очень плавно, 1 = мгновенно)
local aimbotBone = "Head" -- Кость для прицела

local function screenToWorld(pos2D)
    local unitRay = Camera:ScreenPointToRay(pos2D.X, pos2D.Y)
    return unitRay.Origin + unitRay.Direction * 500
end

local function worldToScreen(pos3D)
    local screenPos, onScreen = Camera:WorldToScreenPoint(pos3D)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

local function getClosestPlayerToCenter()
    local centerScreen = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local closest = nil
    local closestDist = math.huge

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        if not p.Character then continue end
        local hum = p.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end

        local bone = p.Character:FindFirstChild(aimbotBone) or p.Character:FindFirstChild("HumanoidRootPart")
        if not bone then continue end

        local screenPos, onScreen = worldToScreen(bone.Position)
        if not onScreen then continue end

        -- Проверяем что в FOV прицела
        local dist = (screenPos - centerScreen).Magnitude
        if dist < aimbotFOV then
            -- Приоритет убийцы
            local role = getRole(p)
            local priorityDist = role == "Murderer" and dist * 0.3 or dist
            if priorityDist < closestDist then
                closestDist = priorityDist
                closest = p
            end
        end
    end
    return closest
end

-- Кольцо FOV прицела
local aimbotCircleGui = Instance.new("ScreenGui", CoreGui)
aimbotCircleGui.Name = "PTHAimbotFOV"
aimbotCircleGui.ResetOnSpawn = false
aimbotCircleGui.Enabled = false

local aimbotCircle = Instance.new("Frame", aimbotCircleGui)
aimbotCircle.AnchorPoint = Vector2.new(0.5, 0.5)
aimbotCircle.BackgroundTransparency = 1
aimbotCircle.BorderSizePixel = 0
Instance.new("UICorner", aimbotCircle).CornerRadius = UDim.new(1, 0)
local aimbotStroke = Instance.new("UIStroke", aimbotCircle)
aimbotStroke.Color = Color3.fromRGB(215, 25, 25)
aimbotStroke.Thickness = 1.5
aimbotStroke.Transparency = 0.4

RunService.RenderStepped:Connect(function()
    aimbotCircleGui.Enabled = CFG.aimbot
    if CFG.aimbot then
        local vp = Camera.ViewportSize
        local circleDiam = aimbotFOV * 2
        aimbotCircle.Size = UDim2.new(0, circleDiam, 0, circleDiam)
        aimbotCircle.Position = UDim2.new(0.5, 0, 0.5, 0)

        local target = getClosestPlayerToCenter()
        if target and target.Character then
            local bone = target.Character:FindFirstChild(aimbotBone) or target.Character:FindFirstChild("HumanoidRootPart")
            if bone then
                local targetCF = CFrame.lookAt(Camera.CFrame.Position, bone.Position)
                Camera.CFrame = Camera.CFrame:Lerp(targetCF, aimbotSmooth)
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════════════
--   РАСШИРЕННЫЙ ESP — Box ESP
--   Рисует рамку вокруг игроков на экране
-- ════════════════════════════════════════════════════════════════
local boxESPGui = Instance.new("ScreenGui", CoreGui)
boxESPGui.Name = "PTHBoxESP"
boxESPGui.ResetOnSpawn = false
boxESPGui.Enabled = false

local boxFrames = {}

local function createBoxESP(p)
    if p == LP then return end
    if boxFrames[p] then return end

    local container = Instance.new("Frame", boxESPGui)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0

    -- 4 линии рамки
    local lines = {}
    for i = 1, 4 do
        local line = Instance.new("Frame", container)
        line.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        line.BorderSizePixel = 0
        table.insert(lines, line)
    end

    boxFrames[p] = {container = container, lines = lines}
end

local function updateBoxESP()
    if not CFG.esp then
        boxESPGui.Enabled = false
        return
    end
    boxESPGui.Enabled = true

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        if not p.Character then continue end

        createBoxESP(p)
        local data = boxFrames[p]
        if not data then continue end

        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
        local head = p.Character:FindFirstChild("Head")
        local hum = p.Character:FindFirstChildOfClass("Humanoid")
        if not hrp or not head or not hum or hum.Health <= 0 then
            data.container.Visible = false
            continue
        end

        -- Получаем 2D позиции
        local headScreen, headOnScreen = Camera:WorldToScreenPoint(head.Position + Vector3.new(0, 0.7, 0))
        local feetScreen, feetOnScreen = Camera:WorldToScreenPoint(hrp.Position - Vector3.new(0, 2.5, 0))

        if not headOnScreen or not feetOnScreen then
            data.container.Visible = false
            continue
        end

        data.container.Visible = true
        local role = getRole(p)
        local col = ROLE_COLORS[role]

        local top = math.min(headScreen.Y, feetScreen.Y)
        local bottom = math.max(headScreen.Y, feetScreen.Y)
        local height = bottom - top
        local width = height * 0.6
        local left = headScreen.X - width/2
        local right = headScreen.X + width/2
        local thick = 1.5

        for i, line in ipairs(data.lines) do line.BackgroundColor3 = col end

        -- Верх
        data.lines[1].Position = UDim2.new(0, left, 0, top)
        data.lines[1].Size = UDim2.new(0, width, 0, thick)
        -- Низ
        data.lines[2].Position = UDim2.new(0, left, 0, bottom)
        data.lines[2].Size = UDim2.new(0, width, 0, thick)
        -- Лево
        data.lines[3].Position = UDim2.new(0, left, 0, top)
        data.lines[3].Size = UDim2.new(0, thick, 0, height)
        -- Право
        data.lines[4].Position = UDim2.new(0, right, 0, top)
        data.lines[4].Size = UDim2.new(0, thick, 0, height)
    end

    -- Удаляем вышедших игроков
    for p, data in pairs(boxFrames) do
        if not p or not p.Parent then
            pcall(function() data.container:Destroy() end)
            boxFrames[p] = nil
        end
    end
end

RunService.RenderStepped:Connect(updateBoxESP)
for _, p in ipairs(Players:GetPlayers()) do createBoxESP(p) end
Players.PlayerAdded:Connect(function(p) task.wait(1) createBoxESP(p) end)
Players.PlayerRemoving:Connect(function(p)
    if boxFrames[p] then
        pcall(function() boxFrames[p].container:Destroy() end)
        boxFrames[p] = nil
    end
end)

-- ════════════════════════════════════════════════════════════════
--   HEALTH BAR на экране (для себя)
-- ════════════════════════════════════════════════════════════════
local selfHPGui = Instance.new("ScreenGui", CoreGui)
selfHPGui.Name = "PTHSelfHP"
selfHPGui.ResetOnSpawn = false

local hpBarFrame = Instance.new("Frame", selfHPGui)
hpBarFrame.Size = UDim2.new(0, 200, 0, 18)
hpBarFrame.Position = UDim2.new(0.5, -100, 1, -100)
hpBarFrame.BackgroundColor3 = Color3.fromRGB(25, 5, 5)
hpBarFrame.BorderSizePixel = 0
Instance.new("UICorner", hpBarFrame).CornerRadius = UDim.new(0, 9)

local hpFill = Instance.new("Frame", hpBarFrame)
hpFill.Size = UDim2.new(1, 0, 1, 0)
hpFill.BackgroundColor3 = Color3.fromRGB(50, 220, 80)
hpFill.BorderSizePixel = 0
Instance.new("UICorner", hpFill).CornerRadius = UDim.new(0, 9)

local hpText = Instance.new("TextLabel", hpBarFrame)
hpText.Size = UDim2.new(1, 0, 1, 0)
hpText.BackgroundTransparency = 1
hpText.Font = Enum.Font.GothamBold
hpText.TextSize = 11
hpText.TextColor3 = Color3.fromRGB(255, 255, 255)
hpText.TextStrokeTransparency = 0
hpText.TextStrokeColor3 = Color3.new(0, 0, 0)

RunService.Heartbeat:Connect(function()
    local hum = getHum()
    if hum then
        local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
        hpFill.Size = UDim2.new(pct, 0, 1, 0)
        local hp = math.floor(hum.Health)
        hpText.Text = "❤ " .. hp
        if pct > 0.6 then hpFill.BackgroundColor3 = Color3.fromRGB(50,220,80)
        elseif pct > 0.3 then hpFill.BackgroundColor3 = Color3.fromRGB(255,200,0)
        else hpFill.BackgroundColor3 = Color3.fromRGB(255,50,50) end
    end
end)

-- ════════════════════════════════════════════════════════════════
--   СКРИПТ ЗАВЕРШЁН
-- ════════════════════════════════════════════════════════════════
print("✅ Все модули загружены!")
print("📌 Версия: v6.0 | @Primejtsu | Nazar513000")
print("🔑 Хоткеи: F1=ESP | F2=Farm | F3=Speed | F4=God | F5=Noclip | F6=Fly | F7=TP Убийца | F8=Стелс | Z=Зум")
