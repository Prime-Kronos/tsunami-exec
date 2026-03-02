-- PrimejTsuHub v5.6 | @Primejtsu | Nazar513000 | MM2
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local Lighting     = game:GetService("Lighting")
local LP           = Players.LocalPlayer
local Camera       = workspace.CurrentCamera
local showGUI

local CFG = {
    god=false, speed=false, bhop=false, noclip=false, esp=false,
    coinFarm=false, knife=false, autoReward=false, fullbright=false,
    antiAfk=true, hide=false, bringCoins=false, bypass=false,
}
local coinCount = 0
local espObjects = {}

local function getChar() return LP.Character end
local function getHRP() local c=getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c=getChar() return c and c:FindFirstChildOfClass("Humanoid") end

-- ══ GOD MODE ══
local function applyGod(on)
    pcall(function()
        local c=getChar() if not c then return end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.LocalTransparencyModifier=on and 1 or 0 if on then p.CanCollide=false end end
        end
        local h=getHum() if h and on then h.MaxHealth=1e6 h.Health=1e6 h.BreakJointsOnDeath=false end
    end)
end

RunService.Heartbeat:Connect(function()
    if not CFG.god then return end
    local h=getHum() if not h then return end
    if h.Health<1e6 then h.Health=1e6 end
    h.BreakJointsOnDeath=false
    local c=getChar() if not c then return end
    for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.LocalTransparencyModifier=1 end end
end)
LP.CharacterAdded:Connect(function() task.wait(0.5) if CFG.god then applyGod(true) end end)

-- ══ ANTI AFK ══
local afkTick=tick()
RunService.Heartbeat:Connect(function()
    if not CFG.antiAfk then return end
    if tick()-afkTick<5 then return end
    afkTick=tick()
    pcall(function() local vu=game:GetService("VirtualUser") vu:Button2Down(Vector2.new(0,0),Camera.CFrame) task.wait(0.05) vu:Button2Up(Vector2.new(0,0),Camera.CFrame) end)
    pcall(function() local h=getHum() if h then h.Jump=true end end)
end)
pcall(function()
    LP.Idled:Connect(function()
        if not CFG.antiAfk then return end
        pcall(function() local vu=game:GetService("VirtualUser") vu:Button2Down(Vector2.new(0,0),Camera.CFrame) task.wait(0.05) vu:Button2Up(Vector2.new(0,0),Camera.CFrame) end)
    end)
end)

-- ══ SPEED / BHOP ══
RunService.Heartbeat:Connect(function()
    local h=getHum() if not h then return end
    if CFG.speed then if h.WalkSpeed<26 then h.WalkSpeed=h.WalkSpeed+0.5 end
    elseif not CFG.bhop then if h.WalkSpeed~=16 then h.WalkSpeed=16 end end
    if CFG.bhop then h.WalkSpeed=24 if h.FloorMaterial~=Enum.Material.Air then h.Jump=true end end
end)

-- ══ NOCLIP ══
RunService.Stepped:Connect(function()
    if not CFG.noclip then return end
    local c=getChar() if not c then return end
    for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
end)

-- ══════════════════════════════════════════════════════════════
--   АНТИЧИТ БАЙПАС v5.6 — УЛУЧШЕННАЯ ЗАЩИТА ОТ КИКА
--   Проблема v5.5: HRP телепорт слишком быстрый → сервер кикает
--   Решение: Humanoid:MoveTo + FireProximity + большие задержки
--   + ротация персонажа + имитация ввода с клавиатуры
-- ══════════════════════════════════════════════════════════════
local bypassActive = false
local farmDelay = 0.35 -- ВАЖНО: увеличено с 0.1 до 0.35 сек!

-- Байпас: случайная ротация камеры (имитирует живого игрока)
task.spawn(function()
    while true do
        task.wait(math.random(6,12))
        if CFG.bypass then
            pcall(function()
                local h=getHum() if not h then return end
                local hrp=getHRP() if not hrp then return end
                -- Небольшое движение в сторону (не телепорт, а MoveTo)
                local offX=math.random(-8,8) local offZ=math.random(-8,8)
                h:MoveTo(hrp.Position+Vector3.new(offX,0,offZ))
                task.wait(math.random(4,9)/10)
                -- Потом обратно (имитирует блуждание)
                h:MoveTo(hrp.Position)
            end)
        end
    end
end)

-- Байпас: периодически меняем WalkSpeed плавно чтобы не триггерить детектор скорости
task.spawn(function()
    while true do
        task.wait(math.random(25,45))
        if CFG.bypass then
            pcall(function()
                local h=getHum() if not h then return end
                local orig=h.WalkSpeed
                -- Плавное изменение скорости (не резкое)
                for _=1,3 do
                    h.WalkSpeed=math.random(13,17)
                    task.wait(0.3)
                end
                task.wait(math.random(8,15)/10)
                if not CFG.speed then h.WalkSpeed=orig end
            end)
        end
    end
end)

-- Байпас: случайные прыжки с реальным интервалом живого игрока
task.spawn(function()
    while true do
        task.wait(math.random(18,35))
        if CFG.bypass then
            pcall(function()
                local h=getHum() if h then
                    h.Jump=true
                    task.wait(math.random(12,25)/10)
                    h.Jump=true
                end
            end)
        end
    end
end)

-- Байпас: периодически останавливаем фарм на 2-5 секунд (как живой игрок отвлёкся)
local farmPaused = false
task.spawn(function()
    while true do
        task.wait(math.random(30,60))
        if CFG.bypass and (CFG.coinFarm or CFG.bringCoins) then
            farmPaused=true
            local pauseTime=math.random(2,5)
            task.wait(pauseTime)
            farmPaused=false
            -- Случайно изменяем задержку фарма после паузы
            farmDelay=math.random(28,50)/100
            task.wait(math.random(5,15))
            farmDelay=math.random(20,38)/100
        end
    end
end)

-- Байпас: VirtualUser имитация мыши (анти-AFK + выглядит как живой)
task.spawn(function()
    while true do
        task.wait(math.random(15,30))
        if CFG.bypass then
            pcall(function()
                local vu=game:GetService("VirtualUser")
                local x=math.random(100,800) local y=math.random(100,600)
                vu:MoveMouse(Vector2.new(x,y))
                task.wait(math.random(3,8)/10)
                vu:MoveMouse(Vector2.new(x+math.random(-30,30),y+math.random(-30,30)))
            end)
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
--   COIN FARM v5.6 — УЛУЧШЕННЫЙ БАЙПАС
--   Главное исправление: Humanoid:MoveTo вместо HRP.CFrame=coin.Position
--   Это выглядит как нормальное движение, а не телепорт!
--   + Уважение к farmPaused паузам + динамическая задержка
-- ══════════════════════════════════════════════════════════════
local function isCoin(o)
    if not(o:IsA("BasePart") or o:IsA("MeshPart") or o:IsA("UnionOperation")) then return false end
    local n=o.Name:lower()
    return (n=="coin" or n:find("coin") or n=="dropcoin" or n=="goldcoin" or n=="silvercoin")
        and o.Parent~=nil and o.Transparency<0.9 and o.Parent~=LP.Character
end

task.spawn(function()
    while true do
        task.wait(farmDelay)
        if not CFG.coinFarm then continue end
        if farmPaused then continue end -- байпас пауза
        local hrp=getHRP() local hum=getHum()
        if not hrp or not hum then continue end
        local coins={}
        for _,o in ipairs(workspace:GetDescendants()) do if isCoin(o) then table.insert(coins,o) end end
        -- Сортируем по дистанции (сначала ближайшие — выглядит натурально)
        table.sort(coins,function(a,b)
            return (hrp.Position-a.Position).Magnitude < (hrp.Position-b.Position).Magnitude
        end)
        for _,coin in ipairs(coins) do
            if not CFG.coinFarm or farmPaused then break end
            pcall(function()
                if coin and coin.Parent then
                    if CFG.bypass then
                        -- БАЙПАС: используем MoveTo (выглядит как ходьба!)
                        hum:MoveTo(coin.Position)
                        -- Ждём пока дойдём или таймаут
                        local t=tick()
                        repeat task.wait(0.05) until (not coin.Parent) or (hrp.Position-coin.Position).Magnitude<4 or tick()-t>3
                        task.wait(math.random(8,20)/100) -- небольшая доп. пауза
                    else
                        -- Без байпаса: быстрый телепорт
                        hrp.CFrame=CFrame.new(coin.Position)*CFrame.new(0,2,0)
                        task.wait(0.03)
                        hrp.CFrame=CFrame.new(coin.Position)
                    end
                end
            end)
            task.wait(CFG.bypass and math.random(15,35)/100 or 0.05)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(farmDelay+0.05)
        if not CFG.bringCoins then continue end
        if farmPaused then continue end -- байпас пауза
        local hrp=getHRP() local hum=getHum()
        if not hrp or not hum then continue end
        for _,o in ipairs(workspace:GetDescendants()) do
            if isCoin(o) then
                pcall(function()
                    o.CFrame=hrp.CFrame
                    task.wait(CFG.bypass and math.random(3,8)/100 or 0.01)
                end)
            end
        end
        pcall(function() if hum then hum.Jump=true end end)
    end
end)

task.spawn(function()
    local prevCoins={}
    while task.wait(0.2) do
        if not CFG.coinFarm and not CFG.bringCoins then continue end
        for _,o in ipairs(workspace:GetDescendants()) do if isCoin(o) then prevCoins[o]=true end end
        for obj in pairs(prevCoins) do
            if not obj or not obj.Parent or obj.Transparency>=0.9 then coinCount=coinCount+1 prevCoins[obj]=nil end
        end
    end
end)

-- ══ KNIFE AURA ══
task.spawn(function()
    while task.wait(0.5) do
        if not CFG.knife then continue end
        local hum=getHum() local hrp=getHRP() if not hum or not hrp then continue end
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP and p.Character then
                local t=p.Character:FindFirstChild("HumanoidRootPart")
                local th=p.Character:FindFirstChildOfClass("Humanoid")
                if t and th and th.Health>0 and (hrp.Position-t.Position).Magnitude<=12 then hum:MoveTo(t.Position) end
            end
        end
    end
end)

-- ══ AUTO REWARD ══
RunService.Heartbeat:Connect(function()
    if not CFG.autoReward then return end
    pcall(function()
        for _,g in ipairs(LP.PlayerGui:GetDescendants()) do
            if g:IsA("TextButton") then
                local t=g.Text:lower()
                if t:find("play") or t:find("vote") or t:find("again") or t:find("ok") or t:find("ready") then g.MouseButton1Click:Fire() end
            end
        end
    end)
end)

-- ══ FULLBRIGHT ══
local function setFB(v)
    if v then Lighting.Brightness=2.5 Lighting.ClockTime=14 Lighting.GlobalShadows=false Lighting.Ambient=Color3.new(1,1,1) Lighting.OutdoorAmbient=Color3.new(1,1,1)
    else Lighting.Brightness=1 Lighting.GlobalShadows=true Lighting.Ambient=Color3.fromRGB(127,127,127) Lighting.OutdoorAmbient=Color3.fromRGB(127,127,127) end
end

-- ══ ESP ══
local ROLE_COLORS={Murderer=Color3.fromRGB(255,60,60),Sheriff=Color3.fromRGB(60,140,255),Innocent=Color3.fromRGB(60,230,110)}
local ROLE_LABELS={Murderer="🔪 УБИЙЦА",Sheriff="🔫 ШЕРИФ",Innocent="😇 НЕВИННЫЙ"}
local function getRole(player)
    local role="Innocent"
    pcall(function()
        local char=player.Character if not char then return end
        for _,item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") then
                local n=item.Name:lower()
                if n:find("knife") or n:find("murder") or n:find("blade") then role="Murderer" return
                elseif n:find("gun") or n:find("sheriff") or n:find("revolver") then role="Sheriff" return end
            end
        end
        local bp=player:FindFirstChild("Backpack")
        if bp then
            for _,item in ipairs(bp:GetChildren()) do
                if item:IsA("Tool") then
                    local n=item.Name:lower()
                    if n:find("knife") or n:find("murder") then role="Murderer" return
                    elseif n:find("gun") or n:find("sheriff") then role="Sheriff" return end
                end
            end
        end
    end)
    return role
end

local function removeESP(p) if espObjects[p] then pcall(function() espObjects[p]:Destroy() end) espObjects[p]=nil end end
local function createESP(p)
    if p==LP then return end removeESP(p)
    local function setup(char)
        local hrp=char:WaitForChild("HumanoidRootPart",5)
        local hum=char:WaitForChild("Humanoid",5)
        if not hrp or not hum then return end
        local bb=Instance.new("BillboardGui") bb.Name="PTJESP" bb.AlwaysOnTop=true bb.Size=UDim2.new(0,110,0,66) bb.StudsOffset=Vector3.new(0,3.5,0) bb.Adornee=hrp bb.Parent=hrp bb.Enabled=false
        local nL=Instance.new("TextLabel",bb) nL.Size=UDim2.new(1,0,0,20) nL.BackgroundTransparency=1 nL.Font=Enum.Font.GothamBold nL.TextSize=13 nL.Text=p.Name nL.TextStrokeTransparency=0 nL.TextStrokeColor3=Color3.new(0,0,0)
        local rL=Instance.new("TextLabel",bb) rL.Size=UDim2.new(1,0,0,18) rL.Position=UDim2.new(0,0,0,20) rL.BackgroundTransparency=1 rL.Font=Enum.Font.GothamBold rL.TextSize=12 rL.TextStrokeTransparency=0 rL.TextStrokeColor3=Color3.new(0,0,0)
        local hL=Instance.new("TextLabel",bb) hL.Size=UDim2.new(1,0,0,14) hL.Position=UDim2.new(0,0,0,38) hL.BackgroundTransparency=1 hL.Font=Enum.Font.Code hL.TextSize=11 hL.TextColor3=Color3.fromRGB(200,200,200) hL.TextStrokeTransparency=0 hL.TextStrokeColor3=Color3.new(0,0,0)
        local dL=Instance.new("TextLabel",bb) dL.Size=UDim2.new(1,0,0,12) dL.Position=UDim2.new(0,0,0,52) dL.BackgroundTransparency=1 dL.Font=Enum.Font.Code dL.TextSize=10 dL.TextColor3=Color3.fromRGB(160,160,160) dL.TextStrokeTransparency=0 dL.TextStrokeColor3=Color3.new(0,0,0)
        local function upd()
            if not bb.Parent then return end
            local role=getRole(p) local col=ROLE_COLORS[role]
            nL.TextColor3=col rL.Text=ROLE_LABELS[role] rL.TextColor3=col
            hL.Text="❤ HP: "..math.max(0,math.min(100,math.floor(hum.Health)))
            local myH=getHRP() if myH then dL.Text="📍 "..math.floor((myH.Position-hrp.Position).Magnitude).." studs" end
            bb.Enabled=CFG.esp
        end
        hum:GetPropertyChangedSignal("Health"):Connect(function() pcall(upd) end)
        char.ChildAdded:Connect(function(ch) if ch:IsA("Tool") then task.wait(0.2) pcall(upd) end end)
        char.ChildRemoved:Connect(function(ch) if ch:IsA("Tool") then task.wait(0.2) pcall(upd) end end)
        RunService.Heartbeat:Connect(function() if bb and bb.Parent then bb.Enabled=CFG.esp end end)
        task.spawn(function() while bb and bb.Parent do pcall(upd) task.wait(1) end end)
        espObjects[p]=bb pcall(upd)
    end
    if p.Character then task.spawn(function() setup(p.Character) end) end
    p.CharacterAdded:Connect(function(c) task.wait(1) task.spawn(function() setup(c) end) end)
end
for _,p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(function(p) task.wait(1) createESP(p) end)
Players.PlayerRemoving:Connect(function(p) removeESP(p) end)

-- ════════════════════════════════════════════════════════════
--   ЗАСТАВКА v5.6 — ПОЛНЫЙ ЭКРАН — УЛУЧШЕННАЯ АНИМАЦИЯ
-- ════════════════════════════════════════════════════════════
if game.CoreGui:FindFirstChild("PTH55") then game.CoreGui.PTH55:Destroy() end
local sg=Instance.new("ScreenGui",game.CoreGui)
sg.Name="PTH55" sg.ResetOnSpawn=false sg.DisplayOrder=999
sg.IgnoreGuiInset=true -- ВАЖНО: убирает верхний отступ Roblox, настоящий фулл экран!

local BG=Color3.fromRGB(10,10,10) local SIDE=Color3.fromRGB(8,8,8) local CARD=Color3.fromRGB(18,18,18)
local BORDER=Color3.fromRGB(35,35,35) local RED=Color3.fromRGB(210,25,25) local WHITE=Color3.fromRGB(225,225,225)
local MUTED=Color3.fromRGB(80,80,80) local DIM=Color3.fromRGB(38,38,38) local GREEN=Color3.fromRGB(0,210,100)
local GOLD=Color3.fromRGB(243,156,18) local PINK=Color3.fromRGB(255,150,200) local PURPLE=Color3.fromRGB(120,60,200)

local function twQ(o,t,p) TweenService:Create(o,TweenInfo.new(t,Enum.EasingStyle.Quart),p):Play() end
local function twB(o,t,p) TweenService:Create(o,TweenInfo.new(t,Enum.EasingStyle.Back,Enum.EasingDirection.Out),p):Play() end

-- Полноэкранный фрейм (настоящий 100% экран)
local Splash=Instance.new("Frame",sg)
Splash.Size=UDim2.new(1,0,1,0)
Splash.Position=UDim2.new(0,0,0,0)
Splash.BackgroundColor3=Color3.fromRGB(2,2,8)
Splash.BorderSizePixel=0
Splash.ZIndex=100
Splash.AnchorPoint=Vector2.new(0,0)

local bgGrad=Instance.new("UIGradient",Splash)
bgGrad.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(2,2,15)),
    ColorSequenceKeypoint.new(0.5,Color3.fromRGB(5,3,20)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(3,2,12)),
})
bgGrad.Rotation=45

-- Звёзды — точки
math.randomseed(42)
for i=1,100 do
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
            TweenService:Create(star,TweenInfo.new(math.random(8,20)/10),{BackgroundTransparency=0}):Play()
            task.wait(math.random(8,20)/10)
        end
    end)
end

-- Большие звёздочки
for i=1,20 do
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

-- СОЛНЕЧНАЯ СИСТЕМА — центр
local SX=0.5 local SY=0.40

-- Свечение
local sunGlow=Instance.new("Frame",Splash)
sunGlow.Size=UDim2.new(0,140,0,140) sunGlow.Position=UDim2.new(SX,-70,SY,-70)
sunGlow.BackgroundColor3=Color3.fromRGB(255,160,0) sunGlow.BackgroundTransparency=1
sunGlow.BorderSizePixel=0 sunGlow.ZIndex=103
Instance.new("UICorner",sunGlow).CornerRadius=UDim.new(1,0)

-- Солнце
local sun=Instance.new("Frame",Splash)
sun.Size=UDim2.new(0,80,0,80) sun.Position=UDim2.new(SX,-40,SY,-40)
sun.BackgroundColor3=Color3.fromRGB(255,200,30) sun.BorderSizePixel=0 sun.ZIndex=105
Instance.new("UICorner",sun).CornerRadius=UDim.new(1,0)
local sunGrad=Instance.new("UIGradient",sun)
sunGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,240,100)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,120,0))})
sunGrad.Rotation=45
local sunIcon=Instance.new("TextLabel",sun)
sunIcon.Size=UDim2.new(1,0,1,0) sunIcon.BackgroundTransparency=1 sunIcon.Text="☀"
sunIcon.TextColor3=Color3.fromRGB(255,255,200) sunIcon.Font=Enum.Font.GothamBlack sunIcon.TextSize=44 sunIcon.ZIndex=106

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
    {name="Mercury",color=Color3.fromRGB(180,160,140),size=14,orbit=95, speed=4 },
    {name="Venus",  color=Color3.fromRGB(230,200,120),size=20,orbit=135,speed=7 },
    {name="Earth",  color=Color3.fromRGB(60,130,230), size=22,orbit=178,speed=10},
    {name="Mars",   color=Color3.fromRGB(210,80,50),  size=17,orbit=220,speed=14},
    {name="Jupiter",color=Color3.fromRGB(200,160,100),size=36,orbit=275,speed=22},
    {name="Saturn", color=Color3.fromRGB(220,190,130),size=28,orbit=325,speed=30},
    {name="Uranus", color=Color3.fromRGB(140,210,230),size=24,orbit=372,speed=40},
    {name="Neptune",color=Color3.fromRGB(60,80,200),  size=22,orbit=415,speed=55},
}

-- Орбитальные кольца
for _,pd in ipairs(planets) do
    local ring=Instance.new("Frame",Splash)
    ring.Size=UDim2.new(0,pd.orbit*2,0,pd.orbit*0.76)
    ring.Position=UDim2.new(SX,-pd.orbit,SY,-pd.orbit*0.38)
    ring.BackgroundTransparency=1 ring.BorderSizePixel=0 ring.ZIndex=102
    Instance.new("UICorner",ring).CornerRadius=UDim.new(1,0)
    local rs=Instance.new("UIStroke",ring) rs.Color=Color3.fromRGB(50,50,75) rs.Thickness=1 rs.Transparency=0.55
end

-- Планеты + анимация
for i,pd in ipairs(planets) do
    local planet=Instance.new("Frame",Splash)
    planet.Size=UDim2.new(0,pd.size,0,pd.size)
    planet.BackgroundColor3=pd.color planet.BorderSizePixel=0 planet.ZIndex=106
    Instance.new("UICorner",planet).CornerRadius=UDim.new(1,0)
    local pg=Instance.new("UIGradient",planet)
    pg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))})
    pg.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.3),NumberSequenceKeypoint.new(1,0.65)})
    pg.Rotation=135

    local satRing=nil
    if pd.name=="Saturn" then
        satRing=Instance.new("Frame",Splash)
        satRing.Size=UDim2.new(0,pd.size+26,0,pd.size//3)
        satRing.BackgroundColor3=Color3.fromRGB(210,185,120) satRing.BackgroundTransparency=0.45
        satRing.BorderSizePixel=0 satRing.ZIndex=105
        Instance.new("UICorner",satRing).CornerRadius=UDim.new(1,0)
    end

    local pName=Instance.new("TextLabel",Splash)
    pName.Size=UDim2.new(0,65,0,12) pName.BackgroundTransparency=1
    pName.Text=pd.name pName.TextColor3=Color3.fromRGB(140,140,170)
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
            pName.Position=UDim2.new(SX,rx-32,SY,ry+pd.size/2+3)
            if satRing then
                local sh=pd.size//3
                satRing.Position=UDim2.new(SX,rx-(pd.size+26)/2,SY,ry-sh/2)
            end
        end
    end)
end

-- Метеорит
task.spawn(function()
    while true do
        task.wait(math.random(30,60)/10)
        local sy=math.random(5,55)/100
        local m=Instance.new("Frame",Splash)
        m.Size=UDim2.new(0,5,0,5) m.Position=UDim2.new(-0.02,0,sy,0)
        m.BackgroundColor3=Color3.fromRGB(255,255,220) m.BorderSizePixel=0 m.ZIndex=108
        Instance.new("UICorner",m).CornerRadius=UDim.new(1,0)
        local tl=Instance.new("Frame",Splash)
        tl.Size=UDim2.new(0,40,0,2) tl.Position=UDim2.new(-0.06,0,sy,1)
        tl.BackgroundColor3=Color3.fromRGB(200,200,255) tl.BackgroundTransparency=0.4 tl.BorderSizePixel=0 tl.ZIndex=107
        local dur=math.random(15,25)/10
        TweenService:Create(m,TweenInfo.new(dur,Enum.EasingStyle.Linear),{Position=UDim2.new(1.05,0,sy+0.35,0),BackgroundTransparency=1}):Play()
        TweenService:Create(tl,TweenInfo.new(dur,Enum.EasingStyle.Linear),{Position=UDim2.new(1.02,0,sy+0.35,1),BackgroundTransparency=1}):Play()
        task.delay(dur,function() pcall(function() m:Destroy() tl:Destroy() end) end)
    end
end)

-- ЛОГОТИП по центру экрана (v5.6 — вертикальный центр)
local bigP=Instance.new("TextLabel",Splash)
bigP.Size=UDim2.new(0,80,0,80) bigP.Position=UDim2.new(0.5,-195,0.72,-40)
bigP.BackgroundTransparency=1 bigP.Text="Ᵽ" bigP.TextColor3=RED bigP.Font=Enum.Font.GothamBlack
bigP.TextSize=80 bigP.TextTransparency=1 bigP.ZIndex=111
bigP.TextStrokeTransparency=0.2 bigP.TextStrokeColor3=Color3.fromRGB(255,80,80)

local nameLetters={"R","I","M","E","J","T","S","U"}
local nameLabels={}
for i,l in ipairs(nameLetters) do
    local lb=Instance.new("TextLabel",Splash)
    lb.Size=UDim2.new(0,30,0,80) lb.Position=UDim2.new(0.5,-84+(i-1)*30,0.72,-40)
    lb.BackgroundTransparency=1 lb.Text=l lb.TextColor3=WHITE lb.Font=Enum.Font.GothamBlack
    lb.TextSize=56 lb.TextTransparency=1 lb.ZIndex=111
    table.insert(nameLabels,lb)
end

local underline=Instance.new("Frame",Splash)
underline.Size=UDim2.new(0,0,0,2) underline.Position=UDim2.new(0.5,0,0.72,46)
underline.BackgroundColor3=RED underline.BorderSizePixel=0 underline.ZIndex=111
local ulGrad=Instance.new("UIGradient",underline)
ulGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,80,80)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(255,200,60)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,80,80))})

local byLine=Instance.new("TextLabel",Splash)
byLine.Size=UDim2.new(0,320,0,18) byLine.Position=UDim2.new(0.5,-160,0.72,56)
byLine.BackgroundTransparency=1 byLine.Text="by  @Primejtsu  •  MM2  •  v5.6"
byLine.TextColor3=Color3.fromRGB(140,110,220) byLine.Font=Enum.Font.GothamBold
byLine.TextSize=12 byLine.TextTransparency=1 byLine.ZIndex=111

local nazarLine=Instance.new("TextLabel",Splash)
nazarLine.Size=UDim2.new(0,200,0,14) nazarLine.Position=UDim2.new(0.5,-100,0.72,78)
nazarLine.BackgroundTransparency=1 nazarLine.Text="Nazar513000"
nazarLine.TextColor3=Color3.fromRGB(100,100,150) nazarLine.Font=Enum.Font.Code
nazarLine.TextSize=10 nazarLine.TextTransparency=1 nazarLine.ZIndex=111

local lbBG=Instance.new("Frame",Splash)
lbBG.Size=UDim2.new(0.65,0,0,5) lbBG.Position=UDim2.new(0.175,0,0.72,102)
lbBG.BackgroundColor3=Color3.fromRGB(20,15,40) lbBG.BorderSizePixel=0 lbBG.ZIndex=111
Instance.new("UICorner",lbBG).CornerRadius=UDim.new(1,0)
local lbFill=Instance.new("Frame",lbBG)
lbFill.Size=UDim2.new(0,0,1,0) lbFill.BackgroundColor3=PURPLE lbFill.BorderSizePixel=0 lbFill.ZIndex=112
Instance.new("UICorner",lbFill).CornerRadius=UDim.new(1,0)

local loadTxt=Instance.new("TextLabel",Splash)
loadTxt.Size=UDim2.new(0.65,0,0,14) loadTxt.Position=UDim2.new(0.175,0,0.72,88)
loadTxt.BackgroundTransparency=1 loadTxt.Text="Primejtsu Hub загружается..."
loadTxt.TextColor3=Color3.fromRGB(120,120,160) loadTxt.Font=Enum.Font.Code
loadTxt.TextSize=10 loadTxt.TextTransparency=1 loadTxt.ZIndex=111

-- Анимация 10 сек
task.spawn(function()
    task.wait(0.5)
    sun.BackgroundTransparency=1 sunGlow.BackgroundTransparency=1 sunIcon.TextTransparency=1
    twQ(sun,0.8,{BackgroundTransparency=0}) twQ(sunGlow,0.8,{BackgroundTransparency=0.6}) twQ(sunIcon,0.6,{TextTransparency=0})
    task.wait(0.8)
    twB(bigP,0.55,{TextTransparency=0})
    task.wait(0.1)
    for i,lb in ipairs(nameLabels) do task.wait(0.06) twB(lb,0.42,{TextTransparency=0}) end
    task.wait(0.5)
    TweenService:Create(underline,TweenInfo.new(0.6,Enum.EasingStyle.Quart),{Size=UDim2.new(0,340,0,2),Position=UDim2.new(0.5,-170,0.72,46)}):Play()
    task.wait(0.3)
    twQ(byLine,0.4,{TextTransparency=0}) task.wait(0.15) twQ(nazarLine,0.4,{TextTransparency=0})
    task.wait(0.3) twQ(loadTxt,0.3,{TextTransparency=0})
    local steps={
        {txt="🪐 Запуск орбит...",          pct=0.14,wait=0.85},
        {txt="⭐ Загрузка звёзд...",         pct=0.28,wait=0.88},
        {txt="🌍 Инициализация ESP...",      pct=0.48,wait=0.92},
        {txt="☀ Активация Coin Farm...",     pct=0.65,wait=0.88},
        {txt="🛡 Античит байпас готов...",   pct=0.84,wait=0.85},
        {txt="✨ Primejtsu Hub v5.6 готов!", pct=1.00,wait=0.82},
    }
    for i,s in ipairs(steps) do
        task.wait(s.wait)
        loadTxt.Text=s.txt
        TweenService:Create(lbFill,TweenInfo.new(0.5,Enum.EasingStyle.Quart),{Size=UDim2.new(s.pct,0,1,0)}):Play()
        if i==#steps then
            task.wait(0.2) loadTxt.TextColor3=GREEN
            TweenService:Create(lbFill,TweenInfo.new(0.35),{BackgroundColor3=GREEN}):Play()
        end
    end
    task.wait(0.9)
    twQ(Splash,0.7,{BackgroundTransparency=1})
    for _,o in ipairs(Splash:GetDescendants()) do
        if o:IsA("TextLabel") then twQ(o,0.4,{TextTransparency=1})
        elseif o:IsA("Frame") and o~=Splash then twQ(o,0.45,{BackgroundTransparency=1}) end
    end
    task.wait(0.9) Splash:Destroy() showGUI()
    task.wait(0.4)
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title="✅ Primejtsu Hub v5.6",Text="Античит байпас v2 активен 🛡 @Primejtsu",Duration=5}) end)
end)

-- ═══════════════════════════════════════════════════════════
showGUI = function()

-- Иконка Ᵽ справа
local iconFrame=Instance.new("Frame",sg)
iconFrame.Size=UDim2.new(0,46,0,46) iconFrame.Position=UDim2.new(1,-56,0.5,-23)
iconFrame.BackgroundColor3=Color3.fromRGB(0,0,0) iconFrame.BorderSizePixel=0 iconFrame.ZIndex=50
Instance.new("UICorner",iconFrame).CornerRadius=UDim.new(0,12)
local iconBG=Instance.new("Frame",iconFrame) iconBG.Size=UDim2.new(1,0,1,0) iconBG.BackgroundColor3=RED iconBG.BorderSizePixel=0 iconBG.ZIndex=51
Instance.new("UICorner",iconBG).CornerRadius=UDim.new(0,12)
local iconBot=Instance.new("Frame",iconFrame) iconBot.Size=UDim2.new(1,0,0.35,0) iconBot.Position=UDim2.new(0,0,0.65,0) iconBot.BackgroundColor3=Color3.fromRGB(140,15,15) iconBot.BorderSizePixel=0 iconBot.ZIndex=52
Instance.new("UICorner",iconBot).CornerRadius=UDim.new(0,12)
local ibf=Instance.new("Frame",iconBot) ibf.Size=UDim2.new(1,0,0.5,0) ibf.BackgroundColor3=Color3.fromRGB(140,15,15) ibf.BorderSizePixel=0 ibf.ZIndex=52
local iconLetter=Instance.new("TextLabel",iconFrame) iconLetter.Size=UDim2.new(1,0,1,0) iconLetter.BackgroundTransparency=1 iconLetter.Text="Ᵽ" iconLetter.TextColor3=Color3.new(1,1,1) iconLetter.Font=Enum.Font.GothamBlack iconLetter.TextSize=26 iconLetter.ZIndex=53
local dotIcon=Instance.new("Frame",iconFrame) dotIcon.Size=UDim2.new(0,10,0,10) dotIcon.Position=UDim2.new(1,-3,0,-3) dotIcon.BackgroundColor3=GREEN dotIcon.BorderSizePixel=0 dotIcon.ZIndex=54
Instance.new("UICorner",dotIcon).CornerRadius=UDim.new(1,0) Instance.new("UIStroke",dotIcon).Color=Color3.fromRGB(0,0,0)
task.spawn(function() while sg and sg.Parent do TweenService:Create(dotIcon,TweenInfo.new(0.8),{BackgroundTransparency=0.6}):Play() task.wait(0.8) TweenService:Create(dotIcon,TweenInfo.new(0.8),{BackgroundTransparency=0}):Play() task.wait(0.8) end end)

local drag=false local dSt=nil local sSt=nil
iconFrame.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true dSt=i.Position sSt=iconFrame.Position end end)
iconFrame.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
UIS.InputChanged:Connect(function(i) if drag and(i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMove) then local d=i.Position-dSt iconFrame.Position=UDim2.new(sSt.X.Scale,sSt.X.Offset+d.X,sSt.Y.Scale,sSt.Y.Offset+d.Y) end end)

-- ГЛАВНОЕ ОКНО — 400px шириной
local W=Instance.new("Frame",sg)
W.Size=UDim2.new(0,400,0,420) W.Position=UDim2.new(0.5,-200,0.5,-210)
W.BackgroundColor3=BG W.BorderSizePixel=0 W.Active=true W.Draggable=true W.ClipsDescendants=true W.Visible=false
Instance.new("UICorner",W).CornerRadius=UDim.new(0,10) Instance.new("UIStroke",W).Color=BORDER

local guiOpen=false local tS2=Vector2.new(0,0) local tT2=0

local function openGUI()
    guiOpen=true W.Visible=true W.Size=UDim2.new(0,0,0,0) W.Position=UDim2.new(0.5,0,0.5,0)
    TweenService:Create(W,TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,400,0,420),Position=UDim2.new(0.5,-200,0.5,-210)}):Play()
    TweenService:Create(iconFrame,TweenInfo.new(0.2),{Size=UDim2.new(0,38,0,38)}):Play()
end
local function closeGUI()
    guiOpen=false
    TweenService:Create(W,TweenInfo.new(0.2,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0)}):Play()
    task.wait(0.25) W.Visible=false
    TweenService:Create(iconFrame,TweenInfo.new(0.2),{Size=UDim2.new(0,46,0,46)}):Play()
end

iconFrame.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then tS2=Vector2.new(i.Position.X,i.Position.Y) tT2=tick() end end)
iconFrame.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
        local dist=(Vector2.new(i.Position.X,i.Position.Y)-tS2).Magnitude
        if dist<10 and tick()-tT2<0.4 then if guiOpen then closeGUI() else openGUI() end end
    end
end)

-- ХЕДЕР
local Hdr=Instance.new("Frame",W) Hdr.Size=UDim2.new(1,0,0,40) Hdr.BackgroundColor3=SIDE Hdr.BorderSizePixel=0
Instance.new("UICorner",Hdr).CornerRadius=UDim.new(0,10)
local hf=Instance.new("Frame",Hdr) hf.Size=UDim2.new(1,0,0.5,0) hf.Position=UDim2.new(0,0,0.5,0) hf.BackgroundColor3=SIDE hf.BorderSizePixel=0
local topLine=Instance.new("Frame",Hdr) topLine.Size=UDim2.new(1,0,0,2) topLine.BackgroundColor3=RED topLine.BorderSizePixel=0
local lp2=Instance.new("TextLabel",Hdr) lp2.Size=UDim2.new(0,22,0,32) lp2.Position=UDim2.new(0,10,0.5,-16) lp2.BackgroundTransparency=1 lp2.Text="Ᵽ" lp2.TextColor3=RED lp2.Font=Enum.Font.GothamBlack lp2.TextSize=24
local lr2=Instance.new("TextLabel",Hdr) lr2.Size=UDim2.new(0,100,0,32) lr2.Position=UDim2.new(0,30,0.5,-16) lr2.BackgroundTransparency=1 lr2.Text="RIMEJTSU" lr2.TextColor3=WHITE lr2.Font=Enum.Font.GothamBlack lr2.TextSize=16 lr2.TextXAlignment=Enum.TextXAlignment.Left
local ls2=Instance.new("TextLabel",Hdr) ls2.Size=UDim2.new(0,200,0,14) ls2.Position=UDim2.new(0,10,1,-15) ls2.BackgroundTransparency=1 ls2.Text="MM2  •  v5.6  •  @Primejtsu 🪐" ls2.TextColor3=GREEN ls2.Font=Enum.Font.Code ls2.TextSize=9 ls2.TextXAlignment=Enum.TextXAlignment.Left
local xBtn=Instance.new("TextButton",Hdr) xBtn.Size=UDim2.new(0,24,0,24) xBtn.Position=UDim2.new(1,-30,0.5,-12) xBtn.BackgroundColor3=RED xBtn.Text="✕" xBtn.TextColor3=WHITE xBtn.Font=Enum.Font.GothamBold xBtn.TextSize=10 xBtn.BorderSizePixel=0
Instance.new("UICorner",xBtn).CornerRadius=UDim.new(0,6) xBtn.MouseButton1Click:Connect(closeGUI)

-- BODY
local Body=Instance.new("Frame",W) Body.Size=UDim2.new(1,0,1,-40) Body.Position=UDim2.new(0,0,0,40) Body.BackgroundTransparency=1
-- Боковая панель 88px
local SB=Instance.new("Frame",Body) SB.Size=UDim2.new(0,88,1,0) SB.BackgroundColor3=SIDE SB.BorderSizePixel=0
local sdiv=Instance.new("Frame",Body) sdiv.Size=UDim2.new(0,1,1,0) sdiv.Position=UDim2.new(0,88,0,0) sdiv.BackgroundColor3=BORDER sdiv.BorderSizePixel=0
local CT=Instance.new("ScrollingFrame",Body) CT.Size=UDim2.new(1,-89,1,0) CT.Position=UDim2.new(0,89,0,0) CT.BackgroundTransparency=1 CT.BorderSizePixel=0 CT.ScrollBarThickness=3 CT.ScrollBarImageColor3=RED CT.CanvasSize=UDim2.new(0,0,0,0)
local CTL=Instance.new("UIListLayout",CT) CTL.Padding=UDim.new(0,5) CTL.SortOrder=Enum.SortOrder.LayoutOrder
local CTP=Instance.new("UIPadding",CT) CTP.PaddingLeft=UDim.new(0,8) CTP.PaddingRight=UDim.new(0,8) CTP.PaddingTop=UDim.new(0,8) CTP.PaddingBottom=UDim.new(0,8)
CTL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() CT.CanvasSize=UDim2.new(0,0,0,CTL.AbsoluteContentSize.Y+16) end)

local tabContent={} local tabBtns={}
local TABS={"Info","Player","God","Farm","Bypass","TP","Trol","Misc"}
for _,n in ipairs(TABS) do tabContent[n]={} end
Instance.new("UIListLayout",SB).Padding=UDim.new(0,0)
Instance.new("UIPadding",SB).PaddingTop=UDim.new(0,4)

local function makeSideBtn(label,icon)
    local b=Instance.new("TextButton",SB) b.Size=UDim2.new(1,0,0,36) b.BackgroundTransparency=1 b.Text="" b.BorderSizePixel=0
    local d=Instance.new("Frame",b) d.Size=UDim2.new(0,3,0,20) d.Position=UDim2.new(0,0,0.5,-10) d.BackgroundColor3=RED d.BorderSizePixel=0 d.Visible=false
    Instance.new("UICorner",d).CornerRadius=UDim.new(1,0)
    local il=Instance.new("TextLabel",b) il.Size=UDim2.new(0,18,1,0) il.Position=UDim2.new(0,10,0,0) il.BackgroundTransparency=1 il.Text=icon il.TextColor3=MUTED il.Font=Enum.Font.Gotham il.TextSize=13
    local l=Instance.new("TextLabel",b) l.Size=UDim2.new(1,-30,1,0) l.Position=UDim2.new(0,30,0,0) l.BackgroundTransparency=1 l.Text=label l.TextColor3=MUTED l.Font=Enum.Font.GothamBold l.TextSize=10 l.TextXAlignment=Enum.TextXAlignment.Left
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

local tabIcons={Info="ℹ",Player="🏃",God="🛡",Farm="💰",Bypass="🔓",TP="📍",Trol="😈",Misc="⚙"}
for _,n in ipairs(TABS) do local b=makeSideBtn(n,tabIcons[n]) local nn=n b.MouseButton1Click:Connect(function() switchTab(nn) end) end

local function mkSec(tab,title)
    local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,22) f.BackgroundTransparency=1 f.BorderSizePixel=0
    local l=Instance.new("TextLabel",f) l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1 l.Text=title l.TextColor3=Color3.fromRGB(130,130,130) l.Font=Enum.Font.GothamBold l.TextSize=11 l.TextXAlignment=Enum.TextXAlignment.Left
    local line=Instance.new("Frame",f) line.Size=UDim2.new(1,0,0,1) line.Position=UDim2.new(0,0,1,-1) line.BackgroundColor3=BORDER line.BorderSizePixel=0
    table.insert(tabContent[tab],f)
end

local function mkToggle(tab,title,cfgKey,onFn)
    local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,38) f.BackgroundColor3=CARD f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,7) Instance.new("UIStroke",f).Color=BORDER
    local lbl=Instance.new("TextLabel",f) lbl.Size=UDim2.new(1,-56,1,0) lbl.Position=UDim2.new(0,12,0,0) lbl.BackgroundTransparency=1 lbl.Text=title lbl.TextColor3=WHITE lbl.Font=Enum.Font.Gotham lbl.TextSize=12 lbl.TextXAlignment=Enum.TextXAlignment.Left
    local track=Instance.new("Frame",f) track.Size=UDim2.new(0,38,0,20) track.Position=UDim2.new(1,-46,0.5,-10) track.BackgroundColor3=DIM track.BorderSizePixel=0
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    local circle=Instance.new("Frame",track) circle.Size=UDim2.new(0,15,0,15) circle.Position=UDim2.new(0,2,0.5,-7) circle.BackgroundColor3=MUTED circle.BorderSizePixel=0
    Instance.new("UICorner",circle).CornerRadius=UDim.new(1,0)
    local btn=Instance.new("TextButton",track) btn.Size=UDim2.new(1,0,1,0) btn.BackgroundTransparency=1 btn.Text=""
    local on=false
    btn.MouseButton1Click:Connect(function()
        on=not on
        local t2=TweenInfo.new(0.15)
        if on then TweenService:Create(track,t2,{BackgroundColor3=RED}):Play() TweenService:Create(circle,t2,{Position=UDim2.new(0,21,0.5,-7),BackgroundColor3=WHITE}):Play()
        else TweenService:Create(track,t2,{BackgroundColor3=DIM}):Play() TweenService:Create(circle,t2,{Position=UDim2.new(0,2,0.5,-7),BackgroundColor3=MUTED}):Play() end
        if cfgKey then CFG[cfgKey]=on end
        if onFn then onFn(on) end
    end)
    table.insert(tabContent[tab],f)
end

local function mkButton(tab,title,col,fn)
    local bc=col or DIM
    local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,38) f.BackgroundColor3=bc f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,7) Instance.new("UIStroke",f).Color=BORDER
    local b=Instance.new("TextButton",f) b.Size=UDim2.new(1,0,1,0) b.BackgroundTransparency=1 b.Text=title b.TextColor3=WHITE b.Font=Enum.Font.GothamBold b.TextSize=12 b.BorderSizePixel=0
    b.MouseButton1Click:Connect(function()
        TweenService:Create(f,TweenInfo.new(0.1),{BackgroundColor3=RED}):Play()
        task.wait(0.15) TweenService:Create(f,TweenInfo.new(0.1),{BackgroundColor3=bc}):Play()
        if fn then fn() end
    end)
    table.insert(tabContent[tab],f)
end

-- ══ INFO ══
mkSec("Info","Информация")
local ic=Instance.new("Frame") ic.Size=UDim2.new(1,0,0,90) ic.BackgroundColor3=CARD ic.BorderSizePixel=0
Instance.new("UICorner",ic).CornerRadius=UDim.new(0,7) Instance.new("UIStroke",ic).Color=BORDER
local irt=Instance.new("Frame",ic) irt.Size=UDim2.new(1,0,0,2) irt.BackgroundColor3=RED irt.BorderSizePixel=0
local _lp=Instance.new("TextLabel",ic) _lp.Size=UDim2.new(0,32,0,40) _lp.Position=UDim2.new(0,10,0.5,-20) _lp.BackgroundTransparency=1 _lp.Text="Ᵽ" _lp.TextColor3=RED _lp.Font=Enum.Font.GothamBlack _lp.TextSize=36
local _n1=Instance.new("TextLabel",ic) _n1.Size=UDim2.new(1,-55,0,17) _n1.Position=UDim2.new(0,48,0,12) _n1.BackgroundTransparency=1 _n1.Text="Primejtsu Hub" _n1.TextColor3=WHITE _n1.Font=Enum.Font.GothamBlack _n1.TextSize=16 _n1.TextXAlignment=Enum.TextXAlignment.Left
local _n2=Instance.new("TextLabel",ic) _n2.Size=UDim2.new(1,-55,0,13) _n2.Position=UDim2.new(0,48,0,32) _n2.BackgroundTransparency=1 _n2.Text="✈ @Primejtsu" _n2.TextColor3=Color3.fromRGB(50,150,220) _n2.Font=Enum.Font.Code _n2.TextSize=11 _n2.TextXAlignment=Enum.TextXAlignment.Left
local _n2b=Instance.new("TextLabel",ic) _n2b.Size=UDim2.new(1,-55,0,12) _n2b.Position=UDim2.new(0,48,0,47) _n2b.BackgroundTransparency=1 _n2b.Text="Nazar513000" _n2b.TextColor3=Color3.fromRGB(100,100,150) _n2b.Font=Enum.Font.Code _n2b.TextSize=10 _n2b.TextXAlignment=Enum.TextXAlignment.Left
local _n3=Instance.new("TextLabel",ic) _n3.Size=UDim2.new(1,0,0,13) _n3.Position=UDim2.new(0,10,1,-16) _n3.BackgroundTransparency=1 _n3.Text="v5.6  •  Bypass v2  •  Trol+  •  @Primejtsu 🪐" _n3.TextColor3=GREEN _n3.Font=Enum.Font.Code _n3.TextSize=10 _n3.TextXAlignment=Enum.TextXAlignment.Left
table.insert(tabContent["Info"],ic)

local cd=Instance.new("Frame") cd.Size=UDim2.new(1,0,0,32) cd.BackgroundColor3=CARD cd.BorderSizePixel=0
Instance.new("UICorner",cd).CornerRadius=UDim.new(0,7) Instance.new("UIStroke",cd).Color=BORDER
local cdl=Instance.new("TextLabel",cd) cdl.Size=UDim2.new(0.55,0,1,0) cdl.Position=UDim2.new(0,12,0,0) cdl.BackgroundTransparency=1 cdl.Text="💰 Монет собрано" cdl.TextColor3=MUTED cdl.Font=Enum.Font.Gotham cdl.TextSize=12 cdl.TextXAlignment=Enum.TextXAlignment.Left
local cdv=Instance.new("TextLabel",cd) cdv.Size=UDim2.new(0.4,0,1,0) cdv.Position=UDim2.new(0.58,0,0,0) cdv.BackgroundTransparency=1 cdv.Text="0" cdv.TextColor3=GOLD cdv.Font=Enum.Font.GothamBold cdv.TextSize=15 cdv.TextXAlignment=Enum.TextXAlignment.Right
table.insert(tabContent["Info"],cd)
RunService.Heartbeat:Connect(function() if cdv and cdv.Parent then cdv.Text=tostring(coinCount) end end)

-- ══ PLAYER ══
mkSec("Player","Движение")
mkToggle("Player","Speed Hack","speed")
mkToggle("Player","Bunny Hop","bhop")
mkToggle("Player","Noclip","noclip")

-- ══ GOD ══
mkSec("God","Бессмертие")
mkToggle("God","God Mode","god",function(v) applyGod(v) end)
mkToggle("God","ESP (роли игроков)","esp")
mkToggle("God","Anti Knock",nil,function(v) pcall(function() local hrp=getHRP() if not hrp then return end hrp.CustomPhysicalProperties=v and PhysicalProperties.new(0,0,0,0,0) or PhysicalProperties.new(0.7,0.3,0.5) end) end)
mkToggle("God","Inf Ammo (шериф)",nil,function(v) pcall(function() local c=getChar() if not c then return end for _,t in ipairs(c:GetChildren()) do if t:IsA("Tool") then local a=t:FindFirstChild("Ammo") if a then a.Value=v and 999 or a.Value end end end end) end)

-- ══ FARM ══
mkSec("Farm","💰 Coin Farm")
mkToggle("Farm","Coin Farm 🪙 (HRP → монеты)","coinFarm")
mkToggle("Farm","Bring Coins (монеты → HRP)","bringCoins")
mkToggle("Farm","Knife Aura","knife")
mkToggle("Farm","Auto Reward","autoReward")
mkSec("Farm","АФК") mkToggle("Farm","Anti AFK","antiAfk")

-- ══ BYPASS — АНТИЧИТ ══
mkSec("Bypass","🔓 Античит Байпас")
local bypassInfo=Instance.new("Frame") bypassInfo.Size=UDim2.new(1,0,0,70) bypassInfo.BackgroundColor3=Color3.fromRGB(20,12,8) bypassInfo.BorderSizePixel=0
Instance.new("UICorner",bypassInfo).CornerRadius=UDim.new(0,7)
local bypassStroke=Instance.new("UIStroke",bypassInfo) bypassStroke.Color=Color3.fromRGB(200,100,0) bypassStroke.Thickness=1
local bypassTxt=Instance.new("TextLabel",bypassInfo) bypassTxt.Size=UDim2.new(1,-16,1,0) bypassTxt.Position=UDim2.new(0,8,0,0) bypassTxt.BackgroundTransparency=1
bypassTxt.Text="Bypass v2 — улучшенная защита:\n• MoveTo вместо телепорта HRP\n• Паузы 2-5 сек каждые 30-60 сек\n• Имитация ввода мыши/движения"
bypassTxt.TextColor3=Color3.fromRGB(200,150,80) bypassTxt.Font=Enum.Font.Code bypassTxt.TextSize=10 bypassTxt.TextWrapped=true bypassTxt.TextXAlignment=Enum.TextXAlignment.Left bypassTxt.TextYAlignment=Enum.TextYAlignment.Top
table.insert(tabContent["Bypass"],bypassInfo)
mkToggle("Bypass","🛡 Antikick Bypass v2 (вкл с фармом)","bypass")
mkToggle("Bypass","Anti AFK (усиленный)","antiAfk")
mkSec("Bypass","Дополнительно")
mkButton("Bypass","🔄 Перезапустить персонажа",Color3.fromRGB(30,30,60),function()
    pcall(function() LP:LoadCharacter() end)
end)
mkButton("Bypass","🧹 Очистить читы (стелс)",Color3.fromRGB(25,50,25),function()
    CFG.coinFarm=false CFG.bringCoins=false CFG.knife=false CFG.speed=false CFG.bhop=false
    pcall(function() local h=getHum() if h then h.WalkSpeed=16 end end)
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title="🧹 Стелс режим",Text="Все читы выключены",Duration=3}) end)
end)

-- ══ TP ══
mkSec("TP","Быстрый TP")
mkButton("TP","🔪  TP к Убийце",Color3.fromRGB(80,10,10),function()
    pcall(function() local hrp=getHRP() if not hrp then return end for _,p in ipairs(Players:GetPlayers()) do if p~=LP and getRole(p)=="Murderer" and p.Character then local t=p.Character:FindFirstChild("HumanoidRootPart") if t then hrp.CFrame=t.CFrame+Vector3.new(0,0,3) return end end end end)
end)
mkButton("TP","🔫  TP к Шерифу",Color3.fromRGB(10,30,80),function()
    pcall(function() local hrp=getHRP() if not hrp then return end for _,p in ipairs(Players:GetPlayers()) do if p~=LP and getRole(p)=="Sheriff" and p.Character then local t=p.Character:FindFirstChild("HumanoidRootPart") if t then hrp.CFrame=t.CFrame+Vector3.new(0,0,3) return end end end end)
end)
mkSec("TP","Игроки")
local plf=Instance.new("Frame") plf.Size=UDim2.new(1,0,0,10) plf.BackgroundTransparency=1 plf.BorderSizePixel=0 plf.AutomaticSize=Enum.AutomaticSize.Y
Instance.new("UIListLayout",plf).Padding=UDim.new(0,4)
table.insert(tabContent["TP"],plf)
local function rebuildPL()
    for _,ch in ipairs(plf:GetChildren()) do if ch:IsA("Frame") then ch:Destroy() end end
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local pf=Instance.new("Frame",plf) pf.Size=UDim2.new(1,0,0,32) pf.BackgroundColor3=CARD pf.BorderSizePixel=0
        Instance.new("UICorner",pf).CornerRadius=UDim.new(0,7) Instance.new("UIStroke",pf).Color=BORDER
        local role=getRole(p) local col=ROLE_COLORS[role]
        local acc=Instance.new("Frame",pf) acc.Size=UDim2.new(0,3,0.6,0) acc.Position=UDim2.new(0,0,0.2,0) acc.BackgroundColor3=col acc.BorderSizePixel=0
        Instance.new("UICorner",acc).CornerRadius=UDim.new(1,0)
        local nm=Instance.new("TextLabel",pf) nm.Size=UDim2.new(1,-65,1,0) nm.Position=UDim2.new(0,14,0,0) nm.BackgroundTransparency=1 nm.Text=p.Name nm.TextColor3=WHITE nm.Font=Enum.Font.GothamBold nm.TextSize=12 nm.TextXAlignment=Enum.TextXAlignment.Left
        local rt=Instance.new("TextLabel",pf) rt.Size=UDim2.new(0,55,1,0) rt.Position=UDim2.new(1,-57,0,0) rt.BackgroundTransparency=1 rt.Text=(role=="Murderer" and "🔪" or role=="Sheriff" and "🔫" or "😇") rt.Font=Enum.Font.GothamBold rt.TextSize=16
        local tb=Instance.new("TextButton",pf) tb.Size=UDim2.new(1,0,1,0) tb.BackgroundTransparency=1 tb.Text=""
        tb.MouseButton1Click:Connect(function()
            pcall(function()
                local hrp=getHRP() if not hrp then return end
                if p.Character then
                    local t=p.Character:FindFirstChild("HumanoidRootPart")
                    if t then TweenService:Create(pf,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(60,10,10)}):Play() task.wait(0.15) TweenService:Create(pf,TweenInfo.new(0.1),{BackgroundColor3=CARD}):Play() hrp.CFrame=t.CFrame+Vector3.new(0,0,3) end
                end
            end)
        end)
    end
end
task.spawn(function() while sg and sg.Parent do pcall(rebuildPL) task.wait(3) end end)
Players.PlayerAdded:Connect(function() task.wait(1) pcall(rebuildPL) end)
Players.PlayerRemoving:Connect(function() task.wait(0.5) pcall(rebuildPL) end)

-- ══════════════════════════════════════════════
--   TROL TAB — Троллинг игроков 😈
-- ══════════════════════════════════════════════
mkSec("Trol","😈 Троллинг")

-- Выбор жертвы
local victimName="Никто"
local victimLabel=Instance.new("Frame") victimLabel.Size=UDim2.new(1,0,0,32) victimLabel.BackgroundColor3=CARD victimLabel.BorderSizePixel=0
Instance.new("UICorner",victimLabel).CornerRadius=UDim.new(0,7) Instance.new("UIStroke",victimLabel).Color=Color3.fromRGB(200,50,50)
local vl=Instance.new("TextLabel",victimLabel) vl.Size=UDim2.new(1,0,1,0) vl.BackgroundTransparency=1 vl.Text="😈 Жертва: "..victimName vl.TextColor3=Color3.fromRGB(255,80,80) vl.Font=Enum.Font.GothamBold vl.TextSize=12
table.insert(tabContent["Trol"],victimLabel)

-- Список игроков для выбора жертвы
local trollPLF=Instance.new("Frame") trollPLF.Size=UDim2.new(1,0,0,10) trollPLF.BackgroundTransparency=1 trollPLF.AutomaticSize=Enum.AutomaticSize.Y trollPLF.BorderSizePixel=0
Instance.new("UIListLayout",trollPLF).Padding=UDim.new(0,3)
table.insert(tabContent["Trol"],trollPLF)

local function rebuildTrollList()
    for _,ch in ipairs(trollPLF:GetChildren()) do if ch:IsA("Frame") then ch:Destroy() end end
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local pf=Instance.new("Frame",trollPLF) pf.Size=UDim2.new(1,0,0,28) pf.BackgroundColor3=CARD pf.BorderSizePixel=0
        Instance.new("UICorner",pf).CornerRadius=UDim.new(0,6) Instance.new("UIStroke",pf).Color=BORDER
        local nm=Instance.new("TextLabel",pf) nm.Size=UDim2.new(1,-50,1,0) nm.Position=UDim2.new(0,10,0,0) nm.BackgroundTransparency=1 nm.Text=p.Name nm.TextColor3=WHITE nm.Font=Enum.Font.GothamBold nm.TextSize=11 nm.TextXAlignment=Enum.TextXAlignment.Left
        local sel=Instance.new("TextLabel",pf) sel.Size=UDim2.new(0,40,1,0) sel.Position=UDim2.new(1,-42,0,0) sel.BackgroundTransparency=1 sel.Text="Выбрать" sel.TextColor3=Color3.fromRGB(255,100,100) sel.Font=Enum.Font.GothamBold sel.TextSize=9
        local tb=Instance.new("TextButton",pf) tb.Size=UDim2.new(1,0,1,0) tb.BackgroundTransparency=1 tb.Text=""
        tb.MouseButton1Click:Connect(function()
            victimName=p.Name
            vl.Text="😈 Жертва: "..victimName
            TweenService:Create(pf,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(60,10,10)}):Play()
            task.wait(0.2) TweenService:Create(pf,TweenInfo.new(0.1),{BackgroundColor3=CARD}):Play()
        end)
    end
end
task.spawn(function() while sg and sg.Parent do pcall(rebuildTrollList) task.wait(4) end end)

mkSec("Trol","Действия над жертвой")

-- TP за жертвой (следить)
local followActive=false
mkToggle("Trol","👣 Следовать за жертвой",nil,function(v)
    followActive=v
    if v then
        task.spawn(function()
            while followActive do
                task.wait(0.1)
                pcall(function()
                    local hrp=getHRP() if not hrp then return end
                    for _,p in ipairs(Players:GetPlayers()) do
                        if p.Name==victimName and p.Character then
                            local t=p.Character:FindFirstChild("HumanoidRootPart")
                            if t then hrp.CFrame=t.CFrame*CFrame.new(0,0,3) end
                        end
                    end
                end)
            end
        end)
    end
end)

mkButton("Trol","🚀 Подбросить жертву вверх",Color3.fromRGB(50,20,80),function()
    pcall(function()
        for _,p in ipairs(Players:GetPlayers()) do
            if p.Name==victimName and p.Character then
                local hrp=p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.Velocity=Vector3.new(0,200,0) end
            end
        end
    end)
end)

mkButton("Trol","💨 Отбросить жертву",Color3.fromRGB(50,30,10),function()
    pcall(function()
        local myHRP=getHRP() if not myHRP then return end
        for _,p in ipairs(Players:GetPlayers()) do
            if p.Name==victimName and p.Character then
                local hrp=p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dir=(hrp.Position-myHRP.Position).Unit
                    hrp.Velocity=dir*150+Vector3.new(0,80,0)
                end
            end
        end
    end)
end)

mkButton("Trol","💥 Спамить TP на жертву (3с)",Color3.fromRGB(60,10,10),function()
    task.spawn(function()
        for i=1,15 do
            task.wait(0.2)
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

mkButton("Trol","🌀 Спиннер (крутить жертву)",Color3.fromRGB(30,10,60),function()
    task.spawn(function()
        for i=1,30 do
            task.wait(0.05)
            pcall(function()
                for _,p in ipairs(Players:GetPlayers()) do
                    if p.Name==victimName and p.Character then
                        local hrp=p.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then hrp.CFrame=hrp.CFrame*CFrame.Angles(0,math.rad(24),0) end
                    end
                end
            end)
        end
    end)
end)

mkButton("Trol","🔊 Системное сообщение (себе)",Color3.fromRGB(20,40,20),function()
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification",{
            Title="⚠️ АДМИНИСТРАТОР",
            Text="Игрок "..victimName.." будет заблокирован!",
            Duration=6
        })
    end)
end)

mkSec("Trol","Глобальные приколы")
mkButton("Trol","🌑 Выключить свет (всем темно)",Color3.fromRGB(10,10,10),function()
    pcall(function()
        Lighting.Brightness=0 Lighting.ClockTime=0 Lighting.GlobalShadows=true
        Lighting.Ambient=Color3.fromRGB(0,0,0) Lighting.OutdoorAmbient=Color3.fromRGB(0,0,0)
    end)
end)
mkButton("Trol","🌟 Включить свет (ультраяркий)",Color3.fromRGB(80,70,10),function()
    pcall(function()
        Lighting.Brightness=8 Lighting.ClockTime=14 Lighting.GlobalShadows=false
        Lighting.Ambient=Color3.new(1,1,1) Lighting.OutdoorAmbient=Color3.new(1,1,1)
    end)
end)
mkButton("Trol","🔄 Вернуть нормальный свет",Color3.fromRGB(20,40,20),function() setFB(false) end)

-- ═══ НОВЫЕ TROL ФУНКЦИИ v5.6 ═══
mkSec("Trol","💥 Новое в v5.6")

-- Заморозить жертву (ставим скорость 0)
local freezeActive=false
mkToggle("Trol","🧊 Заморозить жертву",nil,function(v)
    freezeActive=v
    if v then
        task.spawn(function()
            while freezeActive do
                task.wait(0.1)
                pcall(function()
                    for _,p in ipairs(Players:GetPlayers()) do
                        if p.Name==victimName and p.Character then
                            local h=p.Character:FindFirstChildOfClass("Humanoid")
                            if h then h.WalkSpeed=0 h.JumpPower=0 end
                        end
                    end
                end)
            end
            -- Разморозить
            pcall(function()
                for _,p in ipairs(Players:GetPlayers()) do
                    if p.Name==victimName and p.Character then
                        local h=p.Character:FindFirstChildOfClass("Humanoid")
                        if h then h.WalkSpeed=16 h.JumpPower=50 end
                    end
                end
            end)
        end)
    end
end)

-- Loop TP: жертва телепортируется к тебе каждые 0.5 сек (выглядит как лаги)
local loopTpActive=false
mkToggle("Trol","🔁 Loop TP жертвы к себе",nil,function(v)
    loopTpActive=v
    if v then
        task.spawn(function()
            while loopTpActive do
                task.wait(0.5)
                pcall(function()
                    local myHRP=getHRP() if not myHRP then return end
                    for _,p in ipairs(Players:GetPlayers()) do
                        if p.Name==victimName and p.Character then
                            local t=p.Character:FindFirstChild("HumanoidRootPart")
                            if t then t.CFrame=myHRP.CFrame*CFrame.new(0,0,-3) end
                        end
                    end
                end)
            end
        end)
    end
end)

-- Гравитационный хак: подбрасывать снова и снова
local gravSpamActive=false
mkToggle("Trol","☁ Анти-гравитация (спам вверх)",nil,function(v)
    gravSpamActive=v
    if v then
        task.spawn(function()
            while gravSpamActive do
                task.wait(0.3)
                pcall(function()
                    for _,p in ipairs(Players:GetPlayers()) do
                        if p.Name==victimName and p.Character then
                            local hrp=p.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then hrp.Velocity=Vector3.new(math.random(-10,10),120,math.random(-10,10)) end
                        end
                    end
                end)
            end
        end)
    end
end)

-- Имитировать смерть (убираем всё здоровье)
mkButton("Trol","💀 Fake Kill (убить жертву)",Color3.fromRGB(80,0,0),function()
    pcall(function()
        for _,p in ipairs(Players:GetPlayers()) do
            if p.Name==victimName and p.Character then
                local h=p.Character:FindFirstChildOfClass("Humanoid")
                if h then h.Health=0 end
            end
        end
    end)
end)

-- Спам уведомлений себе с именем жертвы
mkButton("Trol","📢 Fake Admin Warn (себе)",Color3.fromRGB(40,20,0),function()
    task.spawn(function()
        local msgs={"⚠ WARN: "..victimName.." нарушает правила!","🔨 BAN: "..victimName.." будет заблокирован!","🚨 "..victimName.." обнаружен чит-клиент!","👮 Модератор наблюдает за "..victimName,"❌ "..victimName.." получил предупреждение №1"}
        for _,m in ipairs(msgs) do
            task.wait(1.5)
            pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title="⚙ Roblox Admin",Text=m,Duration=4}) end)
        end
    end)
end)

-- Телепорт под карту (себе)
mkButton("Trol","🕳 TP себя под карту",Color3.fromRGB(20,20,50),function()
    pcall(function()
        local hrp=getHRP() if hrp then hrp.CFrame=hrp.CFrame*CFrame.new(0,-500,0) end
    end)
end)

-- Телепорт жертвы под карту
mkButton("Trol","⬇ TP жертвы под карту",Color3.fromRGB(60,0,0),function()
    pcall(function()
        for _,p in ipairs(Players:GetPlayers()) do
            if p.Name==victimName and p.Character then
                local hrp=p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame=hrp.CFrame*CFrame.new(0,-500,0) end
            end
        end
    end)
end)

-- Спиральный полёт жертвы
mkButton("Trol","🌀 Спираль (10 сек)",Color3.fromRGB(50,0,80),function()
    task.spawn(function()
        for i=1,100 do
            task.wait(0.1)
            pcall(function()
                for _,p in ipairs(Players:GetPlayers()) do
                    if p.Name==victimName and p.Character then
                        local hrp=p.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local angle=i*0.3
                            hrp.CFrame=CFrame.new(hrp.Position+Vector3.new(math.cos(angle)*2,1.5,math.sin(angle)*2))
                            hrp.CFrame=hrp.CFrame*CFrame.Angles(0,math.rad(18),0)
                        end
                    end
                end
            end)
        end
    end)
end)

-- ══ MISC ══
mkSec("Misc","Разное")
mkToggle("Misc","Fullbright",nil,function(v) setFB(v) end)
mkToggle("Misc","Hide Player",nil,function(v) pcall(function() local c=getChar() if not c then return end for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") or p:IsA("Decal") then p.LocalTransparencyModifier=v and 1 or 0 end end end) end)
mkButton("Misc","📋 Скопировать версию (уведомление)",DIM,function()
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title="Primejtsu Hub",Text="v5.6 | @Primejtsu | Nazar513000",Duration=4}) end)
end)

task.wait(0.15)
switchTab("Info")

end -- showGUI

print("[Primejtsu Hub v5.6] @Primejtsu | Nazar513000 | Bypass v2+Trol+ 😈🪐")
