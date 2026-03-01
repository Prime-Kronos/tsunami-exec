-- ██████╗ ██████╗ ██╗███╗   ███╗███████╗
-- ██╔══██╗██╔══██╗██║████╗ ████║██╔════╝
-- ██████╔╝██████╔╝██║██╔████╔██║█████╗
-- ██╔═══╝ ██╔══██╗██║██║╚██╔╝██║██╔══╝
-- ██║     ██║  ██║██║██║ ╚═╝ ██║███████╗
-- PrimejTsuHub v5.0 | @Primejtsu | MM2

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local LP           = Players.LocalPlayer
local Camera       = workspace.CurrentCamera

local CFG = {
    god=false, speed=false, bhop=false, noclip=false,
    esp=false, coinFarm=false, knife=false, autoReward=false,
    fullbright=false, antiAfk=true, hide=false, bringCoins=false,
}
local coinCount = 0
local espObjects = {}

local function getChar() return LP.Character end
local function getHRP()  local c=getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()  local c=getChar() return c and c:FindFirstChildOfClass("Humanoid") end

-- ══════════════════════════════════════
--   GOD MODE = НЕВИДИМОСТЬ
--   Делаем персонажа прозрачным — никто не видит
--   + бесконечное HP через петлю
-- ══════════════════════════════════════
local function applyGod(on)
    pcall(function()
        local c = getChar() if not c then return end
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then
                p.LocalTransparencyModifier = on and 1 or 0
                if on then
                    p.CanCollide = false
                end
            end
            if p:IsA("Decal") or p:IsA("SpecialMesh") then
                p.Parent.LocalTransparencyModifier = on and 1 or 0
            end
        end
        local h = getHum()
        if h and on then
            h.MaxHealth = 1e6
            h.Health    = 1e6
            h.BreakJointsOnDeath = false
        end
    end)
end

RunService.Heartbeat:Connect(function()
    if not CFG.god then return end
    local h = getHum() if not h then return end
    if h.Health < 1e6 then h.Health = 1e6 end
    if h.MaxHealth ~= 1e6 then h.MaxHealth = 1e6 end
    h.BreakJointsOnDeath = false
    -- Держим невидимость
    local c = getChar() if not c then return end
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then
            p.LocalTransparencyModifier = 1
        end
    end
end)

LP.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if CFG.god then applyGod(true) end
end)

-- ══════════════════════════════════════
--   ANTI AFK — ГАРАНТИРОВАННЫЙ ПРЫЖОК
--   Каждые 5 секунд, без исключений
-- ══════════════════════════════════════
local afkTick = tick()
RunService.Heartbeat:Connect(function()
    if not CFG.antiAfk then return end
    if tick() - afkTick < 5 then return end
    afkTick = tick()
    pcall(function()
        local vu = game:GetService("VirtualUser")
        vu:Button2Down(Vector2.new(0,0), Camera.CFrame)
        task.wait(0.05)
        vu:Button2Up(Vector2.new(0,0), Camera.CFrame)
    end)
    pcall(function()
        local h = getHum() if h then h.Jump = true end
    end)
end)

pcall(function()
    LP.Idled:Connect(function()
        if not CFG.antiAfk then return end
        pcall(function()
            local vu = game:GetService("VirtualUser")
            vu:Button2Down(Vector2.new(0,0), Camera.CFrame)
            task.wait(0.05)
            vu:Button2Up(Vector2.new(0,0), Camera.CFrame)
        end)
    end)
end)

-- ══ SPEED / BHOP ══
RunService.Heartbeat:Connect(function()
    local h = getHum() if not h then return end
    if CFG.speed then
        if h.WalkSpeed < 26 then h.WalkSpeed = h.WalkSpeed + 0.5 end
    elseif not CFG.bhop then
        if h.WalkSpeed ~= 16 then h.WalkSpeed = 16 end
    end
    if CFG.bhop then h.WalkSpeed=24 if h.FloorMaterial~=Enum.Material.Air then h.Jump=true end end
end)

-- ══ NOCLIP ══
RunService.Stepped:Connect(function()
    if not CFG.noclip then return end
    local c=getChar() if not c then return end
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide=false end
    end
end)

-- ══════════════════════════════════════
--   COIN FARM — 0.6 СЕК
-- ══════════════════════════════════════
local function findNearestCoin()
    local hrp=getHRP() if not hrp then return nil,0 end
    local nearest=nil local nearDist=math.huge
    for _,o in ipairs(workspace:GetDescendants()) do
        if o:IsA("BasePart") or o:IsA("MeshPart") or o:IsA("UnionOperation") then
            local n=o.Name:lower()
            if n:find("coin") or n=="dropcoin" or n=="goldcoin" or n=="silvercoin" then
                if o.Parent and o.Transparency<1 then
                    local d=(hrp.Position-o.Position).Magnitude
                    if d<nearDist then nearDist=d nearest=o end
                end
            end
        end
    end
    return nearest,nearDist
end

task.spawn(function()
    while task.wait(0.6) do
        if not CFG.coinFarm then continue end
        local hrp=getHRP() local hum=getHum()
        if not hrp or not hum then continue end
        local coin,dist=findNearestCoin()
        if not coin then continue end
        if dist>3 then
            local dir=(coin.Position-hrp.Position)
            local step=math.min(dist-1,20)
            local tp=hrp.Position+dir.Unit*step
            hrp.CFrame=CFrame.new(tp.X,hrp.Position.Y,tp.Z)
            task.wait(0.05)
        end
        hum.Jump=true
        task.wait(0.05)
        if coin.Parent==nil then coinCount=coinCount+1 end
    end
end)

-- ══════════════════════════════════════
--   BRING COINS — тянет монеты к тебе
--   Телепортирует все монеты на карте к HRP
-- ══════════════════════════════════════
task.spawn(function()
    while task.wait(0.3) do
        if not CFG.bringCoins then continue end
        local hrp=getHRP() if not hrp then continue end
        for _,o in ipairs(workspace:GetDescendants()) do
            if o:IsA("BasePart") or o:IsA("MeshPart") then
                local n=o.Name:lower()
                if n:find("coin") or n=="dropcoin" or n=="goldcoin" or n=="silvercoin" then
                    pcall(function()
                        if o.Parent and o.Transparency<1 then
                            o.CFrame = CFrame.new(
                                hrp.Position.X + math.random(-2,2),
                                hrp.Position.Y,
                                hrp.Position.Z + math.random(-2,2)
                            )
                        end
                    end)
                end
            end
        end
    end
end)

-- ══ KNIFE AURA ══
task.spawn(function()
    while task.wait(0.5) do
        if not CFG.knife then continue end
        local hum=getHum() local hrp=getHRP()
        if not hum or not hrp then continue end
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP and p.Character then
                local t=p.Character:FindFirstChild("HumanoidRootPart")
                local th=p.Character:FindFirstChildOfClass("Humanoid")
                if t and th and th.Health>0 and (hrp.Position-t.Position).Magnitude<=12 then
                    hum:MoveTo(t.Position)
                end
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
                if t:find("play") or t:find("vote") or t:find("again") or t:find("ok") or t:find("ready") then
                    g.MouseButton1Click:Fire()
                end
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
        if bp then for _,item in ipairs(bp:GetChildren()) do
            if item:IsA("Tool") then
                local n=item.Name:lower()
                if n:find("knife") or n:find("murder") then role="Murderer" return
                elseif n:find("gun") or n:find("sheriff") then role="Sheriff" return end
            end
        end end
    end)
    return role
end

local function removeESP(p)
    if espObjects[p] then pcall(function() espObjects[p]:Destroy() end) espObjects[p]=nil end
end

local function createESP(p)
    if p==LP then return end removeESP(p)
    local function setup(char)
        local hrp=char:WaitForChild("HumanoidRootPart",5)
        local hum=char:WaitForChild("Humanoid",5)
        if not hrp or not hum then return end
        local bb=Instance.new("BillboardGui") bb.Name="PTJESP" bb.AlwaysOnTop=true
        bb.Size=UDim2.new(0,110,0,66) bb.StudsOffset=Vector3.new(0,3.5,0)
        bb.Adornee=hrp bb.Parent=hrp bb.Enabled=false
        local nL=Instance.new("TextLabel",bb) nL.Size=UDim2.new(1,0,0,20) nL.BackgroundTransparency=1 nL.Font=Enum.Font.GothamBold nL.TextSize=13 nL.Text=p.Name nL.TextStrokeTransparency=0 nL.TextStrokeColor3=Color3.new(0,0,0)
        local rL=Instance.new("TextLabel",bb) rL.Size=UDim2.new(1,0,0,18) rL.Position=UDim2.new(0,0,0,20) rL.BackgroundTransparency=1 rL.Font=Enum.Font.GothamBold rL.TextSize=12 rL.TextStrokeTransparency=0 rL.TextStrokeColor3=Color3.new(0,0,0)
        local hL=Instance.new("TextLabel",bb) hL.Size=UDim2.new(1,0,0,14) hL.Position=UDim2.new(0,0,0,38) hL.BackgroundTransparency=1 hL.Font=Enum.Font.Code hL.TextSize=11 hL.TextColor3=Color3.fromRGB(200,200,200) hL.TextStrokeTransparency=0 hL.TextStrokeColor3=Color3.new(0,0,0)
        local dL=Instance.new("TextLabel",bb) dL.Size=UDim2.new(1,0,0,12) dL.Position=UDim2.new(0,0,0,52) dL.BackgroundTransparency=1 dL.Font=Enum.Font.Code dL.TextSize=10 dL.TextColor3=Color3.fromRGB(160,160,160) dL.TextStrokeTransparency=0 dL.TextStrokeColor3=Color3.new(0,0,0)
        local function upd()
            if not bb.Parent then return end
            local role=getRole(p) local col=ROLE_COLORS[role]
            nL.TextColor3=col rL.Text=ROLE_LABELS[role] rL.TextColor3=col
            local hp=math.max(0,math.min(100,math.floor(hum.Health)))
            hL.Text="❤ HP: "..hp
            local myH=getHRP()
            if myH then dL.Text="📍 "..math.floor((myH.Position-hrp.Position).Magnitude).." studs" end
            bb.Enabled=CFG.esp
        end
        hum:GetPropertyChangedSignal("Health"):Connect(function() pcall(function() hL.Text="❤ HP: "..math.max(0,math.min(100,math.floor(hum.Health))) end) end)
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

-- ════════════════════════════════════════
--                  GUI
-- ════════════════════════════════════════
if game.CoreGui:FindFirstChild("PTH50") then game.CoreGui.PTH50:Destroy() end
local sg=Instance.new("ScreenGui",game.CoreGui)
sg.Name="PTH50" sg.ResetOnSpawn=false sg.DisplayOrder=999

local BG=Color3.fromRGB(10,10,10) local SIDE=Color3.fromRGB(8,8,8)
local CARD=Color3.fromRGB(18,18,18) local BORDER=Color3.fromRGB(35,35,35)
local RED=Color3.fromRGB(210,25,25) local WHITE=Color3.fromRGB(225,225,225)
local MUTED=Color3.fromRGB(80,80,80) local DIM=Color3.fromRGB(38,38,38)
local GREEN=Color3.fromRGB(0,210,100) local GOLD=Color3.fromRGB(243,156,18)

local function twQ(o,t,p) TweenService:Create(o,TweenInfo.new(t,Enum.EasingStyle.Quart),p):Play() end
local function twB(o,t,p) TweenService:Create(o,TweenInfo.new(t,Enum.EasingStyle.Back,Enum.EasingDirection.Out),p):Play() end
local function twS(o,t,p) TweenService:Create(o,TweenInfo.new(t,Enum.EasingStyle.Sine),p):Play() end

-- ══════════════════════════════════════
--   НОВАЯ SPLASH АНИМАЦИЯ
--   Стиль: кинематографичный, с частицами и глитч-эффектом
-- ══════════════════════════════════════
local Splash=Instance.new("Frame",sg)
Splash.Size=UDim2.new(1,0,1,0)
Splash.BackgroundColor3=Color3.fromRGB(0,0,0)
Splash.BorderSizePixel=0 Splash.ZIndex=100

-- Горизонтальные линии (глитч полосы)
for i=1,6 do
    local gl=Instance.new("Frame",Splash)
    gl.Size=UDim2.new(0,0,0,1)
    gl.Position=UDim2.new(0,0,math.random(10,90)/100,0)
    gl.BackgroundColor3=RED
    gl.BorderSizePixel=0 gl.ZIndex=101
    gl.BackgroundTransparency=0.4

    task.spawn(function()
        task.wait(0.3+i*0.08)
        TweenService:Create(gl,TweenInfo.new(0.4+math.random()*0.3,Enum.EasingStyle.Quart),
            {Size=UDim2.new(math.random(20,80)/100,0,0,1)}):Play()
        task.wait(0.5)
        TweenService:Create(gl,TweenInfo.new(0.3),{BackgroundTransparency=1}):Play()
    end)
end

-- Центральный контейнер
local centerY = 0.38

-- Большая буква P (красная, появляется с масштабированием)
local bigP=Instance.new("TextLabel",Splash)
bigP.Size=UDim2.new(0,80,0,90)
bigP.Position=UDim2.new(0.5,-160,centerY,-45)
bigP.BackgroundTransparency=1 bigP.Text="Ᵽ"
bigP.TextColor3=RED bigP.Font=Enum.Font.GothamBlack
bigP.TextSize=80 bigP.TextTransparency=1 bigP.ZIndex=102
bigP.TextStrokeTransparency=0.5 bigP.TextStrokeColor3=Color3.fromRGB(255,100,100)

-- RIME (белые буквы по одной)
local letters={"R","I","M","E"}
local letterLabels={}
for i,l in ipairs(letters) do
    local lb=Instance.new("TextLabel",Splash)
    lb.Size=UDim2.new(0,42,0,90)
    lb.Position=UDim2.new(0.5,-80+(i-1)*42,centerY,-45)
    lb.BackgroundTransparency=1 lb.Text=l
    lb.TextColor3=WHITE lb.Font=Enum.Font.GothamBlack
    lb.TextSize=72 lb.TextTransparency=1 lb.ZIndex=102
    table.insert(letterLabels,lb)
end

-- Красная линия под названием
local underline=Instance.new("Frame",Splash)
underline.Size=UDim2.new(0,0,0,2)
underline.Position=UDim2.new(0.5,0,centerY+0.16,0)
underline.BackgroundColor3=RED underline.BorderSizePixel=0 underline.ZIndex=102

-- Подпись
local sub1=Instance.new("TextLabel",Splash)
sub1.Size=UDim2.new(0,300,0,20) sub1.Position=UDim2.new(0.5,-150,centerY+0.19,0)
sub1.BackgroundTransparency=1 sub1.Text="Murder Mystery 2  •  v5.0"
sub1.TextColor3=Color3.fromRGB(120,120,120) sub1.Font=Enum.Font.Code
sub1.TextSize=12 sub1.TextTransparency=1 sub1.ZIndex=102

-- Loading bar (снизу)
local lbBG=Instance.new("Frame",Splash)
lbBG.Size=UDim2.new(0,260,0,3) lbBG.Position=UDim2.new(0.5,-130,0.78,0)
lbBG.BackgroundColor3=Color3.fromRGB(25,25,25) lbBG.BorderSizePixel=0 lbBG.ZIndex=101
Instance.new("UICorner",lbBG).CornerRadius=UDim.new(1,0)

local lbFill=Instance.new("Frame",lbBG)
lbFill.Size=UDim2.new(0,0,1,0) lbFill.BackgroundColor3=RED lbFill.BorderSizePixel=0 lbFill.ZIndex=102
Instance.new("UICorner",lbFill).CornerRadius=UDim.new(1,0)

local loadTxt=Instance.new("TextLabel",Splash)
loadTxt.Size=UDim2.new(0,260,0,16) loadTxt.Position=UDim2.new(0.5,-130,0.81,0)
loadTxt.BackgroundTransparency=1 loadTxt.Text="Инициализация..."
loadTxt.TextColor3=MUTED loadTxt.Font=Enum.Font.Code
loadTxt.TextSize=11 loadTxt.TextTransparency=1 loadTxt.ZIndex=102

local verTxt=Instance.new("TextLabel",Splash)
verTxt.Size=UDim2.new(0,260,0,14) verTxt.Position=UDim2.new(0.5,-130,0.87,0)
verTxt.BackgroundTransparency=1 verTxt.Text="@Primejtsu"
verTxt.TextColor3=Color3.fromRGB(60,60,60) verTxt.Font=Enum.Font.Code
verTxt.TextSize=10 verTxt.TextTransparency=1 verTxt.ZIndex=102

-- АНИМАЦИЯ
task.spawn(function()
    task.wait(0.3)

    -- 1. Большая P влетает слева
    twB(bigP,0.5,{TextTransparency=0, Position=UDim2.new(0.5,-160,centerY,-45)})
    task.wait(0.1)

    -- 2. Буквы R I M E падают по очереди сверху
    for i,lb in ipairs(letterLabels) do
        task.wait(0.08)
        local finalPos=UDim2.new(0.5,-80+(i-1)*42,centerY,-45)
        lb.Position=UDim2.new(0.5,-80+(i-1)*42,centerY-0.15,-45)
        twB(lb,0.4,{TextTransparency=0, Position=finalPos})
    end

    task.wait(0.4)

    -- 3. Подчёркивание разъезжается
    TweenService:Create(underline,TweenInfo.new(0.5,Enum.EasingStyle.Quart),
        {Size=UDim2.new(0,320,0,2), Position=UDim2.new(0.5,-160,centerY+0.16,0)}):Play()

    task.wait(0.2)
    twQ(sub1,0.4,{TextTransparency=0})

    -- 4. Loading bar
    task.wait(0.2)
    twQ(loadTxt,0.3,{TextTransparency=0})
    twQ(verTxt,0.3,{TextTransparency=0})

    local steps={
        {txt="Загрузка модулей...",     pct=0.25},
        {txt="God Mode (Невидимость)...",pct=0.50},
        {txt="ESP + Роли...",            pct=0.75},
        {txt="Готово ✓",                 pct=1.00},
    }
    for i,s in ipairs(steps) do
        task.wait(0.35)
        loadTxt.Text=s.txt
        TweenService:Create(lbFill,TweenInfo.new(0.3,Enum.EasingStyle.Quart),
            {Size=UDim2.new(s.pct,0,1,0)}):Play()
        if i==#steps then
            loadTxt.TextColor3=GREEN
            lbFill.BackgroundColor3=GREEN
        end
    end

    task.wait(0.6)

    -- 5. Всё исчезает вверх
    twQ(Splash,0.5,{BackgroundTransparency=1})
    for _,o in ipairs(Splash:GetDescendants()) do
        if o:IsA("TextLabel") then twQ(o,0.35,{TextTransparency=1})
        elseif o:IsA("Frame") then twQ(o,0.35,{BackgroundTransparency=1}) end
    end

    task.wait(0.6)
    Splash:Destroy()
    showGUI()

    task.wait(0.4)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification",{
            Title="✅ PrimejTsuHub v5.0",
            Text="God=Невидимость | TP меню | @Primejtsu",
            Duration=5
        })
    end)
end)

-- ════════════════════════════════════════
function showGUI()

-- ICON
local iconFrame=Instance.new("Frame",sg)
iconFrame.Size=UDim2.new(0,46,0,46) iconFrame.Position=UDim2.new(1,-56,0.5,-23)
iconFrame.BackgroundColor3=Color3.fromRGB(0,0,0) iconFrame.BorderSizePixel=0 iconFrame.ZIndex=50
Instance.new("UICorner",iconFrame).CornerRadius=UDim.new(0,12)
local iconBG=Instance.new("Frame",iconFrame) iconBG.Size=UDim2.new(1,0,1,0) iconBG.BackgroundColor3=RED iconBG.BorderSizePixel=0 iconBG.ZIndex=51
Instance.new("UICorner",iconBG).CornerRadius=UDim.new(0,12)
local iconBot=Instance.new("Frame",iconFrame) iconBot.Size=UDim2.new(1,0,0.35,0) iconBot.Position=UDim2.new(0,0,0.65,0) iconBot.BackgroundColor3=Color3.fromRGB(140,15,15) iconBot.BorderSizePixel=0 iconBot.ZIndex=52
Instance.new("UICorner",iconBot).CornerRadius=UDim.new(0,12)
local ibFix=Instance.new("Frame",iconBot) ibFix.Size=UDim2.new(1,0,0.5,0) ibFix.BackgroundColor3=Color3.fromRGB(140,15,15) ibFix.BorderSizePixel=0 ibFix.ZIndex=52
local iconLetter=Instance.new("TextLabel",iconFrame) iconLetter.Size=UDim2.new(1,0,1,0) iconLetter.BackgroundTransparency=1 iconLetter.Text="Ᵽ" iconLetter.TextColor3=Color3.new(1,1,1) iconLetter.Font=Enum.Font.GothamBlack iconLetter.TextSize=26 iconLetter.ZIndex=53
local dotIcon=Instance.new("Frame",iconFrame) dotIcon.Size=UDim2.new(0,10,0,10) dotIcon.Position=UDim2.new(1,-3,0,-3) dotIcon.BackgroundColor3=GREEN dotIcon.BorderSizePixel=0 dotIcon.ZIndex=54
Instance.new("UICorner",dotIcon).CornerRadius=UDim.new(1,0) Instance.new("UIStroke",dotIcon).Color=Color3.fromRGB(0,0,0)
task.spawn(function() while sg and sg.Parent do TweenService:Create(dotIcon,TweenInfo.new(0.8),{BackgroundTransparency=0.6}):Play() task.wait(0.8) TweenService:Create(dotIcon,TweenInfo.new(0.8),{BackgroundTransparency=0}):Play() task.wait(0.8) end end)

-- Drag иконки
local drag=false local dSt=nil local sSt=nil
iconFrame.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true dSt=i.Position sSt=iconFrame.Position end
end)
iconFrame.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
end)
UIS.InputChanged:Connect(function(i)
    if drag and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMove) then
        local d=i.Position-dSt iconFrame.Position=UDim2.new(sSt.X.Scale,sSt.X.Offset+d.X,sSt.Y.Scale,sSt.Y.Offset+d.Y)
    end
end)

-- MAIN WINDOW
local W=Instance.new("Frame",sg)
W.Size=UDim2.new(0,300,0,360) W.Position=UDim2.new(0.5,-150,0.5,-180)
W.BackgroundColor3=BG W.BorderSizePixel=0 W.Active=true W.Draggable=true W.ClipsDescendants=true W.Visible=false
Instance.new("UICorner",W).CornerRadius=UDim.new(0,8)
Instance.new("UIStroke",W).Color=BORDER

local guiOpen=false
local tS2=Vector2.new(0,0) local tT2=0

local function openGUI()
    guiOpen=true W.Visible=true W.Size=UDim2.new(0,0,0,0) W.Position=UDim2.new(0.5,0,0.5,0)
    TweenService:Create(W,TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
        {Size=UDim2.new(0,300,0,360),Position=UDim2.new(0.5,-150,0.5,-180)}):Play()
    TweenService:Create(iconFrame,TweenInfo.new(0.2),{Size=UDim2.new(0,38,0,38)}):Play()
end
local function closeGUI()
    guiOpen=false
    TweenService:Create(W,TweenInfo.new(0.2,Enum.EasingStyle.Quart,Enum.EasingDirection.In),
        {Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0)}):Play()
    task.wait(0.25) W.Visible=false
    TweenService:Create(iconFrame,TweenInfo.new(0.2),{Size=UDim2.new(0,46,0,46)}):Play()
end

iconFrame.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then tS2=Vector2.new(i.Position.X,i.Position.Y) tT2=tick() end
end)
iconFrame.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
        local dist=(Vector2.new(i.Position.X,i.Position.Y)-tS2).Magnitude
        if dist<10 and tick()-tT2<0.4 then if guiOpen then closeGUI() else openGUI() end end
    end
end)

-- HEADER
local Hdr=Instance.new("Frame",W) Hdr.Size=UDim2.new(1,0,0,36) Hdr.BackgroundColor3=SIDE Hdr.BorderSizePixel=0
Instance.new("UICorner",Hdr).CornerRadius=UDim.new(0,8)
local hf=Instance.new("Frame",Hdr) hf.Size=UDim2.new(1,0,0.5,0) hf.Position=UDim2.new(0,0,0.5,0) hf.BackgroundColor3=SIDE hf.BorderSizePixel=0
local topLine=Instance.new("Frame",Hdr) topLine.Size=UDim2.new(1,0,0,2) topLine.BackgroundColor3=RED topLine.BorderSizePixel=0
local lp2=Instance.new("TextLabel",Hdr) lp2.Size=UDim2.new(0,18,0,28) lp2.Position=UDim2.new(0,8,0.5,-14) lp2.BackgroundTransparency=1 lp2.Text="Ᵽ" lp2.TextColor3=RED lp2.Font=Enum.Font.GothamBlack lp2.TextSize=20
local lr2=Instance.new("TextLabel",Hdr) lr2.Size=UDim2.new(0,60,0,28) lr2.Position=UDim2.new(0,24,0.5,-14) lr2.BackgroundTransparency=1 lr2.Text="RIME" lr2.TextColor3=WHITE lr2.Font=Enum.Font.GothamBlack lr2.TextSize=16 lr2.TextXAlignment=Enum.TextXAlignment.Left
local ls2=Instance.new("TextLabel",Hdr) ls2.Size=UDim2.new(0,130,0,12) ls2.Position=UDim2.new(0,8,1,-13) ls2.BackgroundTransparency=1 ls2.Text="MM2  •  v5.0" ls2.TextColor3=GREEN ls2.Font=Enum.Font.Code ls2.TextSize=8 ls2.TextXAlignment=Enum.TextXAlignment.Left
local xBtn=Instance.new("TextButton",Hdr) xBtn.Size=UDim2.new(0,20,0,20) xBtn.Position=UDim2.new(1,-26,0.5,-10) xBtn.BackgroundColor3=RED xBtn.Text="✕" xBtn.TextColor3=WHITE xBtn.Font=Enum.Font.GothamBold xBtn.TextSize=9 xBtn.BorderSizePixel=0
Instance.new("UICorner",xBtn).CornerRadius=UDim.new(0,5) xBtn.MouseButton1Click:Connect(closeGUI)

-- BODY
local Body=Instance.new("Frame",W) Body.Size=UDim2.new(1,0,1,-36) Body.Position=UDim2.new(0,0,0,36) Body.BackgroundTransparency=1
local SB=Instance.new("Frame",Body) SB.Size=UDim2.new(0,75,1,0) SB.BackgroundColor3=SIDE SB.BorderSizePixel=0
local sdiv=Instance.new("Frame",Body) sdiv.Size=UDim2.new(0,1,1,0) sdiv.Position=UDim2.new(0,75,0,0) sdiv.BackgroundColor3=BORDER sdiv.BorderSizePixel=0
local CT=Instance.new("ScrollingFrame",Body) CT.Size=UDim2.new(1,-76,1,0) CT.Position=UDim2.new(0,76,0,0) CT.BackgroundTransparency=1 CT.BorderSizePixel=0 CT.ScrollBarThickness=2 CT.ScrollBarImageColor3=RED CT.CanvasSize=UDim2.new(0,0,0,0)
local CTL=Instance.new("UIListLayout",CT) CTL.Padding=UDim.new(0,4) CTL.SortOrder=Enum.SortOrder.LayoutOrder
local CTP=Instance.new("UIPadding",CT) CTP.PaddingLeft=UDim.new(0,6) CTP.PaddingRight=UDim.new(0,6) CTP.PaddingTop=UDim.new(0,6) CTP.PaddingBottom=UDim.new(0,6)
CTL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() CT.CanvasSize=UDim2.new(0,0,0,CTL.AbsoluteContentSize.Y+12) end)

local tabContent={} local tabBtns={} local TABS={"Info","Player","God","Farm","TP","Misc"}
for _,n in ipairs(TABS) do tabContent[n]={} end
local SBL=Instance.new("UIListLayout",SB) SBL.Padding=UDim.new(0,0) SBL.SortOrder=Enum.SortOrder.LayoutOrder
local SBP=Instance.new("UIPadding",SB) SBP.PaddingTop=UDim.new(0,4)

local function makeSideBtn(label, icon)
    local b=Instance.new("TextButton",SB) b.Size=UDim2.new(1,0,0,34) b.BackgroundTransparency=1 b.Text="" b.BorderSizePixel=0
    local d=Instance.new("Frame",b) d.Size=UDim2.new(0,3,0,18) d.Position=UDim2.new(0,0,0.5,-9) d.BackgroundColor3=RED d.BorderSizePixel=0 d.Visible=false
    Instance.new("UICorner",d).CornerRadius=UDim.new(1,0)
    local il=Instance.new("TextLabel",b) il.Size=UDim2.new(0,16,1,0) il.Position=UDim2.new(0,10,0,0) il.BackgroundTransparency=1 il.Text=icon il.TextColor3=MUTED il.Font=Enum.Font.Gotham il.TextSize=12
    local l=Instance.new("TextLabel",b) l.Size=UDim2.new(1,-28,1,0) l.Position=UDim2.new(0,28,0,0) l.BackgroundTransparency=1 l.Text=label l.TextColor3=MUTED l.Font=Enum.Font.GothamBold l.TextSize=10 l.TextXAlignment=Enum.TextXAlignment.Left
    tabBtns[label]={btn=b,dot=d,lbl=l,ico=il} return b
end

local curFrames={}
local function switchTab(name)
    for _,f in ipairs(curFrames) do f.Parent=nil end curFrames={}
    for k,t in pairs(tabBtns) do t.dot.Visible=false t.lbl.TextColor3=MUTED t.ico.TextColor3=MUTED end
    if tabBtns[name] then tabBtns[name].dot.Visible=true tabBtns[name].lbl.TextColor3=WHITE tabBtns[name].ico.TextColor3=RED end
    if tabContent[name] then for _,f in ipairs(tabContent[name]) do f.Parent=CT table.insert(curFrames,f) end end
    task.wait() CT.CanvasSize=UDim2.new(0,0,0,CTL.AbsoluteContentSize.Y+12) CT.CanvasPosition=Vector2.new(0,0)
end

local tabIcons={Info="ℹ",Player="🏃",God="🛡",Farm="💰",TP="📍",Misc="⚙"}
for _,n in ipairs(TABS) do
    local b=makeSideBtn(n,tabIcons[n]) local nn=n
    b.MouseButton1Click:Connect(function() switchTab(nn) end)
end

-- ── BUILDERS ──
local function mkSec(tab,title)
    local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,20) f.BackgroundTransparency=1 f.BorderSizePixel=0
    local l=Instance.new("TextLabel",f) l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1 l.Text=title l.TextColor3=Color3.fromRGB(130,130,130) l.Font=Enum.Font.GothamBold l.TextSize=10 l.TextXAlignment=Enum.TextXAlignment.Left
    local line=Instance.new("Frame",f) line.Size=UDim2.new(1,0,0,1) line.Position=UDim2.new(0,0,1,-1) line.BackgroundColor3=BORDER line.BorderSizePixel=0
    table.insert(tabContent[tab],f)
end

local function mkToggle(tab,title,cfgKey,onFn)
    local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,34) f.BackgroundColor3=CARD f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,6) Instance.new("UIStroke",f).Color=BORDER
    local lbl=Instance.new("TextLabel",f) lbl.Size=UDim2.new(1,-52,1,0) lbl.Position=UDim2.new(0,10,0,0) lbl.BackgroundTransparency=1 lbl.Text=title lbl.TextColor3=WHITE lbl.Font=Enum.Font.Gotham lbl.TextSize=11 lbl.TextXAlignment=Enum.TextXAlignment.Left
    local track=Instance.new("Frame",f) track.Size=UDim2.new(0,34,0,18) track.Position=UDim2.new(1,-42,0.5,-9) track.BackgroundColor3=DIM track.BorderSizePixel=0
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    local circle=Instance.new("Frame",track) circle.Size=UDim2.new(0,13,0,13) circle.Position=UDim2.new(0,2,0.5,-6) circle.BackgroundColor3=MUTED circle.BorderSizePixel=0
    Instance.new("UICorner",circle).CornerRadius=UDim.new(1,0)
    local btn=Instance.new("TextButton",track) btn.Size=UDim2.new(1,0,1,0) btn.BackgroundTransparency=1 btn.Text=""
    local on=false
    btn.MouseButton1Click:Connect(function()
        on=not on
        local t2=TweenInfo.new(0.15)
        if on then TweenService:Create(track,t2,{BackgroundColor3=RED}):Play() TweenService:Create(circle,t2,{Position=UDim2.new(0,19,0.5,-6),BackgroundColor3=WHITE}):Play()
        else TweenService:Create(track,t2,{BackgroundColor3=DIM}):Play() TweenService:Create(circle,t2,{Position=UDim2.new(0,2,0.5,-6),BackgroundColor3=MUTED}):Play() end
        if cfgKey then CFG[cfgKey]=on end
        if onFn then onFn(on) end
    end)
    table.insert(tabContent[tab],f)
end

local function mkButton(tab,title,col,fn)
    local bc=col or DIM
    local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,30) f.BackgroundColor3=bc f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,6)
    Instance.new("UIStroke",f).Color=BORDER
    local b=Instance.new("TextButton",f) b.Size=UDim2.new(1,0,1,0) b.BackgroundTransparency=1 b.Text=title b.TextColor3=WHITE b.Font=Enum.Font.GothamBold b.TextSize=11 b.BorderSizePixel=0
    b.MouseButton1Click:Connect(function()
        TweenService:Create(f,TweenInfo.new(0.1),{BackgroundColor3=RED}):Play()
        task.wait(0.15) TweenService:Create(f,TweenInfo.new(0.1),{BackgroundColor3=bc}):Play()
        if fn then fn() end
    end)
    table.insert(tabContent[tab],f)
end

-- ══ INFO TAB ══
mkSec("Info","Информация")
local ic=Instance.new("Frame") ic.Size=UDim2.new(1,0,0,76) ic.BackgroundColor3=CARD ic.BorderSizePixel=0
Instance.new("UICorner",ic).CornerRadius=UDim.new(0,6) Instance.new("UIStroke",ic).Color=BORDER
local irt=Instance.new("Frame",ic) irt.Size=UDim2.new(1,0,0,2) irt.BackgroundColor3=RED irt.BorderSizePixel=0
local _lp=Instance.new("TextLabel",ic) _lp.Size=UDim2.new(0,28,0,36) _lp.Position=UDim2.new(0,8,0.5,-18) _lp.BackgroundTransparency=1 _lp.Text="Ᵽ" _lp.TextColor3=RED _lp.Font=Enum.Font.GothamBlack _lp.TextSize=32
local _n2=Instance.new("TextLabel",ic) _n2.Size=UDim2.new(1,-50,0,15) _n2.Position=UDim2.new(0,42,0,14) _n2.BackgroundTransparency=1 _n2.Text="Primejtsu" _n2.TextColor3=WHITE _n2.Font=Enum.Font.GothamBold _n2.TextSize=13 _n2.TextXAlignment=Enum.TextXAlignment.Left
local _n3=Instance.new("TextLabel",ic) _n3.Size=UDim2.new(1,-50,0,11) _n3.Position=UDim2.new(0,42,0,30) _n3.BackgroundTransparency=1 _n3.Text="Script Developer" _n3.TextColor3=MUTED _n3.Font=Enum.Font.Code _n3.TextSize=10 _n3.TextXAlignment=Enum.TextXAlignment.Left
local _n4=Instance.new("TextLabel",ic) _n4.Size=UDim2.new(1,-50,0,11) _n4.Position=UDim2.new(0,42,0,44) _n4.BackgroundTransparency=1 _n4.Text="✈ @Primejtsu" _n4.TextColor3=Color3.fromRGB(50,150,220) _n4.Font=Enum.Font.Code _n4.TextSize=10 _n4.TextXAlignment=Enum.TextXAlignment.Left
local _n5=Instance.new("TextLabel",ic) _n5.Size=UDim2.new(1,0,0,11) _n5.Position=UDim2.new(0,8,1,-14) _n5.BackgroundTransparency=1 _n5.Text="v5.0  •  God=Invisible  •  TP Menu" _n5.TextColor3=GREEN _n5.Font=Enum.Font.Code _n5.TextSize=9 _n5.TextXAlignment=Enum.TextXAlignment.Left
table.insert(tabContent["Info"],ic)

local cd=Instance.new("Frame") cd.Size=UDim2.new(1,0,0,28) cd.BackgroundColor3=CARD cd.BorderSizePixel=0
Instance.new("UICorner",cd).CornerRadius=UDim.new(0,6) Instance.new("UIStroke",cd).Color=BORDER
local cdl=Instance.new("TextLabel",cd) cdl.Size=UDim2.new(0.55,0,1,0) cdl.Position=UDim2.new(0,10,0,0) cdl.BackgroundTransparency=1 cdl.Text="💰 Монет собрано" cdl.TextColor3=MUTED cdl.Font=Enum.Font.Gotham cdl.TextSize=11 cdl.TextXAlignment=Enum.TextXAlignment.Left
local cdv=Instance.new("TextLabel",cd) cdv.Size=UDim2.new(0.4,0,1,0) cdv.Position=UDim2.new(0.58,0,0,0) cdv.BackgroundTransparency=1 cdv.Text="0" cdv.TextColor3=GOLD cdv.Font=Enum.Font.GothamBold cdv.TextSize=13 cdv.TextXAlignment=Enum.TextXAlignment.Right
table.insert(tabContent["Info"],cd)
RunService.Heartbeat:Connect(function() if cdv and cdv.Parent then cdv.Text=tostring(coinCount) end end)

-- ══ PLAYER TAB ══
mkSec("Player","Движение")
mkToggle("Player","Speed Hack","speed")
mkToggle("Player","Bunny Hop","bhop")
mkToggle("Player","Noclip","noclip")

-- ══ GOD TAB ══
mkSec("God","Бессмертие + Скрытность")
mkToggle("God","God Mode (Невидимость)","god",function(v) applyGod(v) end)
mkToggle("God","ESP (роли игроков)","esp")
mkToggle("God","Anti Knock",nil,function(v)
    pcall(function()
        local hrp=getHRP() if not hrp then return end
        hrp.CustomPhysicalProperties=v and PhysicalProperties.new(0,0,0,0,0) or PhysicalProperties.new(0.7,0.3,0.5)
    end)
end)
mkToggle("God","Inf Ammo (шериф)",nil,function(v)
    pcall(function()
        local c=getChar() if not c then return end
        for _,t in ipairs(c:GetChildren()) do
            if t:IsA("Tool") then local a=t:FindFirstChild("Ammo") if a then a.Value=v and 999 or a.Value end end
        end
    end)
end)

-- ══ FARM TAB ══
mkSec("Farm","Фарм")
mkToggle("Farm","Coin Farm (0.6s)","coinFarm")
mkToggle("Farm","Bring Coins (тянет монеты)","bringCoins")
mkToggle("Farm","Knife Aura","knife")
mkToggle("Farm","Auto Reward","autoReward")
mkSec("Farm","АФК (прыжок каждые 5с)")
mkToggle("Farm","Anti AFK","antiAfk")

-- ══ TP TAB ══
mkSec("TP","Быстрый TP")
mkButton("TP","🔪  TP к Убийце",Color3.fromRGB(80,10,10),function()
    pcall(function()
        local hrp=getHRP() if not hrp then return end
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP then
                local role=getRole(p)
                if role=="Murderer" and p.Character then
                    local t=p.Character:FindFirstChild("HumanoidRootPart")
                    if t then hrp.CFrame=t.CFrame+Vector3.new(0,0,3) return end
                end
            end
        end
    end)
end)

mkButton("TP","🔫  TP к Шерифу",Color3.fromRGB(10,30,80),function()
    pcall(function()
        local hrp=getHRP() if not hrp then return end
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP then
                local role=getRole(p)
                if role=="Sheriff" and p.Character then
                    local t=p.Character:FindFirstChild("HumanoidRootPart")
                    if t then hrp.CFrame=t.CFrame+Vector3.new(0,0,3) return end
                end
            end
        end
    end)
end)

mkSec("TP","Список игроков")

-- Список игроков — динамически обновляется
local playerListFrame=Instance.new("Frame")
playerListFrame.Size=UDim2.new(1,0,0,10) playerListFrame.BackgroundTransparency=1 playerListFrame.BorderSizePixel=0
playerListFrame.AutomaticSize=Enum.AutomaticSize.Y
local pll=Instance.new("UIListLayout",playerListFrame) pll.Padding=UDim.new(0,3) pll.SortOrder=Enum.SortOrder.LayoutOrder
table.insert(tabContent["TP"],playerListFrame)

local function rebuildPlayerList()
    for _,ch in ipairs(playerListFrame:GetChildren()) do
        if ch:IsA("Frame") or ch:IsA("TextButton") then ch:Destroy() end
    end
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local pf=Instance.new("Frame",playerListFrame)
        pf.Size=UDim2.new(1,0,0,28) pf.BackgroundColor3=CARD pf.BorderSizePixel=0
        Instance.new("UICorner",pf).CornerRadius=UDim.new(0,6)
        Instance.new("UIStroke",pf).Color=BORDER

        local role=getRole(p)
        local col=ROLE_COLORS[role]

        -- Цветная полоска слева
        local accent=Instance.new("Frame",pf) accent.Size=UDim2.new(0,3,0.6,0) accent.Position=UDim2.new(0,0,0.2,0) accent.BackgroundColor3=col accent.BorderSizePixel=0
        Instance.new("UICorner",accent).CornerRadius=UDim.new(1,0)

        local name=Instance.new("TextLabel",pf) name.Size=UDim2.new(1,-60,1,0) name.Position=UDim2.new(0,12,0,0) name.BackgroundTransparency=1 name.Text=p.Name name.TextColor3=WHITE name.Font=Enum.Font.GothamBold name.TextSize=11 name.TextXAlignment=Enum.TextXAlignment.Left

        local roleTag=Instance.new("TextLabel",pf) roleTag.Size=UDim2.new(0,50,1,0) roleTag.Position=UDim2.new(1,-52,0,0) roleTag.BackgroundTransparency=1
        roleTag.Text=(role=="Murderer" and "🔪" or role=="Sheriff" and "🔫" or "😇")
        roleTag.Font=Enum.Font.GothamBold roleTag.TextSize=14

        -- Кнопка TP
        local tpBtn=Instance.new("TextButton",pf) tpBtn.Size=UDim2.new(1,0,1,0) tpBtn.BackgroundTransparency=1 tpBtn.Text=""
        tpBtn.MouseButton1Click:Connect(function()
            pcall(function()
                local hrp=getHRP() if not hrp then return end
                if p.Character then
                    local t=p.Character:FindFirstChild("HumanoidRootPart")
                    if t then
                        TweenService:Create(pf,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(60,10,10)}):Play()
                        task.wait(0.15)
                        TweenService:Create(pf,TweenInfo.new(0.1),{BackgroundColor3=CARD}):Play()
                        hrp.CFrame=t.CFrame+Vector3.new(0,0,3)
                    end
                end
            end)
        end)
    end
end

-- Обновление списка каждые 3 сек
task.spawn(function()
    while sg and sg.Parent do
        pcall(rebuildPlayerList)
        task.wait(3)
    end
end)

Players.PlayerAdded:Connect(function() task.wait(1) pcall(rebuildPlayerList) end)
Players.PlayerRemoving:Connect(function() task.wait(0.5) pcall(rebuildPlayerList) end)

-- ══ MISC TAB ══
mkSec("Misc","Разное")
mkToggle("Misc","Fullbright",nil,function(v) setFB(v) end)
mkToggle("Misc","Hide Player",nil,function(v)
    pcall(function()
        local c=getChar() if not c then return end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") or p:IsA("Decal") then p.LocalTransparencyModifier=v and 1 or 0 end
        end
    end)
end)

task.wait(0.15)
switchTab("Info")

end -- showGUI

print("[PrimejTsuHub v5.0] God=Invisible | TP Menu | BringCoins | @Primejtsu")
