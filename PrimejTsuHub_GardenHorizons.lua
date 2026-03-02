-- PrimejTsu Hub | Garden Horizons | @Primejtsu | Nazar513000
-- Ключ доступа: Primejtsu

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local Lighting     = game:GetService("Lighting")
local LP           = Players.LocalPlayer
local Camera       = workspace.CurrentCamera
local Mouse        = LP:GetMouse()

local VALID_KEY    = "Primejtsu"
local keyVerified  = false

local CFG = {
    speed=false, fly=false, noclip=false, fullbright=false,
    antiAfk=true, esp=false, autoFarm=false, autoSell=false,
    autoPlant=false, itemEsp=false, infiniteJump=false,
}

local function getChar() return LP.Character end
local function getHRP() local c=getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c=getChar() return c and c:FindFirstChildOfClass("Humanoid") end

-- ══ ANTI AFK ══
task.spawn(function()
    pcall(function() LP.Idled:Connect(function()
        if not CFG.antiAfk then return end
        local vu=game:GetService("VirtualUser")
        vu:Button2Down(Vector2.new(0,0),Camera.CFrame) task.wait(0.1)
        vu:Button2Up(Vector2.new(0,0),Camera.CFrame)
        local h=getHum() if h then h.Jump=true end
    end) end)
    while true do
        task.wait(55)
        if not CFG.antiAfk then continue end
        pcall(function()
            local vu=game:GetService("VirtualUser")
            vu:Button2Down(Vector2.new(0,0),Camera.CFrame) task.wait(0.1)
            vu:Button2Up(Vector2.new(0,0),Camera.CFrame)
            local h=getHum() if h then h.Jump=true end
        end)
    end
end)

-- ══ SPEED ══
RunService.Heartbeat:Connect(function()
    if not keyVerified then return end
    local h=getHum() if not h then return end
    if CFG.fly then return end
    if CFG.speed then h.WalkSpeed=32
    else if h.WalkSpeed~=16 then h.WalkSpeed=16 end end
    if CFG.infiniteJump then
        if h.FloorMaterial~=Enum.Material.Air then h.Jump=true end
    end
end)

-- ══ NOCLIP ══
local noclipWasOn=false
RunService.Stepped:Connect(function()
    if not keyVerified then return end
    if CFG.noclip then
        noclipWasOn=true
        local c=getChar() if not c then return end
        for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
    elseif noclipWasOn then
        noclipWasOn=false
        pcall(function()
            local c=getChar() if not c then return end
            for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end
            local hrp=getHRP()
            if hrp and hrp.Position.Y<-30 then hrp.CFrame=CFrame.new(hrp.Position.X,10,hrp.Position.Z) end
        end)
    end
end)

-- ══ FLY ══
local flyConn=nil local flyBody=nil
local function startFly()
    local hrp=getHRP() if not hrp then return end
    local h=getHum() if not h then return end
    h.PlatformStand=true
    local bg=Instance.new("BodyGyro",hrp) bg.P=9e4 bg.MaxTorque=Vector3.new(9e9,9e9,9e9) bg.CFrame=hrp.CFrame flyBody=bg
    local bv=Instance.new("BodyVelocity",hrp) bv.Velocity=Vector3.zero bv.MaxForce=Vector3.new(9e9,9e9,9e9) bv.Name="FlyVel"
    local spd=28
    flyConn=RunService.Heartbeat:Connect(function()
        if not CFG.fly then return end
        local hrp2=getHRP() if not hrp2 then return end
        local bv2=hrp2:FindFirstChild("FlyVel") if not bv2 then return end
        local cf=Camera.CFrame
        local mv=Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) or UIS:IsKeyDown(Enum.KeyCode.Up) then mv=mv+cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) or UIS:IsKeyDown(Enum.KeyCode.Down) then mv=mv-cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) or UIS:IsKeyDown(Enum.KeyCode.Left) then mv=mv-cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) or UIS:IsKeyDown(Enum.KeyCode.Right) then mv=mv+cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) or UIS:IsKeyDown(Enum.KeyCode.E) then mv=mv+Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.Q) then mv=mv+Vector3.new(0,-1,0) end
        bv2.Velocity=mv.Magnitude>0 and mv.Unit*spd or Vector3.zero
        bg.CFrame=cf
    end)
end
local function stopFly()
    if flyConn then flyConn:Disconnect() flyConn=nil end
    pcall(function() local hrp=getHRP() if hrp then
        local bv=hrp:FindFirstChild("FlyVel") if bv then bv:Destroy() end
        if flyBody then flyBody:Destroy() flyBody=nil end
    end end)
    local h=getHum() if h then h.PlatformStand=false end
end

-- ══ FULLBRIGHT ══
local function setFB(v)
    if v then Lighting.Brightness=2.5 Lighting.ClockTime=14 Lighting.GlobalShadows=false Lighting.Ambient=Color3.new(1,1,1) Lighting.OutdoorAmbient=Color3.new(1,1,1)
    else Lighting.Brightness=1 Lighting.GlobalShadows=true Lighting.Ambient=Color3.fromRGB(127,127,127) Lighting.OutdoorAmbient=Color3.fromRGB(127,127,127) end
end

-- ══ AUTO FARM (Garden Horizons) ══
-- Ищем урожай по именам объектов в игре
local function isHarvestable(o)
    if not o:IsA("BasePart") and not o:IsA("Model") and not o:IsA("MeshPart") then return false end
    local n=o.Name:lower()
    return n:find("crop") or n:find("plant") or n:find("harvest") or n:find("fruit")
        or n:find("vegetable") or n:find("flower") or n:find("seed") or n:find("ripe")
        or n:find("tomato") or n:find("carrot") or n:find("potato") or n:find("wheat")
        or n:find("corn") or n:find("sunflower") or n:find("berry") or n:find("mushroom")
end

local function isSellPoint(o)
    local n=o.Name:lower()
    return n:find("sell") or n:find("shop") or n:find("market") or n:find("store") or n:find("trader")
end

task.spawn(function()
    while true do
        task.wait(0.15)
        if not CFG.autoFarm or not keyVerified then continue end
        local hrp=getHRP() local hum=getHum()
        if not hrp or not hum then continue end
        hum.WalkSpeed=40

        -- Ищем случайный урожай для сбора
        local crops={}
        for _,o in ipairs(workspace:GetDescendants()) do
            if isHarvestable(o) then
                local pos
                pcall(function()
                    if o:IsA("Model") then pos=o:GetPivot().Position
                    else pos=o.Position end
                end)
                if pos then table.insert(crops,{obj=o,pos=pos}) end
            end
        end
        if #crops==0 then continue end

        local t=crops[math.random(1,#crops)]
        -- Пробуем кликнуть
        pcall(function()
            local cd=t.obj:FindFirstChildOfClass("ClickDetector")
                or (t.obj.Parent and t.obj.Parent:FindFirstChildOfClass("ClickDetector"))
            if cd then fireclickdetector(cd) end
        end)
        -- Бежим туда
        hum:MoveTo(t.pos)
        local t0=tick()
        repeat task.wait(0.08)
            if tick()-t0>0.5 then pcall(function() hum:MoveTo(t.pos) end) end
        until (hrp.Position-t.pos).Magnitude<4 or tick()-t0>5 or not CFG.autoFarm
    end
end)

-- ══ AUTO SELL ══
task.spawn(function()
    while true do
        task.wait(0.2)
        if not CFG.autoSell or not keyVerified then continue end
        local hrp=getHRP() local hum=getHum()
        if not hrp or not hum then continue end
        for _,o in ipairs(workspace:GetDescendants()) do
            if isSellPoint(o) then
                local pos
                pcall(function()
                    if o:IsA("Model") then pos=o:GetPivot().Position
                    elseif o:IsA("BasePart") then pos=o.Position end
                end)
                if pos then
                    hum:MoveTo(pos)
                    pcall(function()
                        local cd=o:FindFirstChildOfClass("ClickDetector") or (o.Parent and o.Parent:FindFirstChildOfClass("ClickDetector"))
                        if cd then fireclickdetector(cd) end
                    end)
                    -- Ищем кнопки продажи в GUI
                    for _,g in ipairs(LP.PlayerGui:GetDescendants()) do
                        if g:IsA("TextButton") then
                            local t=g.Text:lower()
                            if t:find("sell") or t:find("продать") then
                                pcall(function() g.MouseButton1Click:Fire() end)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ══ ESP ИГРОКОВ ══
local espObjects={}
local function removeESP(p) if espObjects[p] then pcall(function() espObjects[p]:Destroy() end) espObjects[p]=nil end end
local function createESP(p)
    if p==LP then return end removeESP(p)
    local function setup(char)
        local hrp=char:WaitForChild("HumanoidRootPart",5)
        local hum=char:WaitForChild("Humanoid",5)
        if not hrp or not hum then return end
        local bb=Instance.new("BillboardGui") bb.Name="PTJESP" bb.AlwaysOnTop=true bb.Size=UDim2.new(0,130,0,50) bb.StudsOffset=Vector3.new(0,3,0) bb.Adornee=hrp bb.Parent=hrp bb.Enabled=false
        local nL=Instance.new("TextLabel",bb) nL.Size=UDim2.new(1,0,0,24) nL.BackgroundTransparency=1 nL.Font=Enum.Font.GothamBlack nL.TextSize=14 nL.Text=p.Name nL.TextColor3=Color3.fromRGB(0,200,255) nL.TextStrokeTransparency=0 nL.TextStrokeColor3=Color3.new(0,0,0)
        local hL=Instance.new("TextLabel",bb) hL.Size=UDim2.new(1,0,0,14) hL.Position=UDim2.new(0,0,0,24) hL.BackgroundTransparency=1 hL.Font=Enum.Font.Code hL.TextSize=11 hL.TextColor3=Color3.fromRGB(100,255,150) hL.TextStrokeTransparency=0 hL.TextStrokeColor3=Color3.new(0,0,0)
        local dL=Instance.new("TextLabel",bb) dL.Size=UDim2.new(1,0,0,12) dL.Position=UDim2.new(0,0,0,38) dL.BackgroundTransparency=1 dL.Font=Enum.Font.Code dL.TextSize=10 dL.TextColor3=Color3.fromRGB(180,180,180) dL.TextStrokeTransparency=0 dL.TextStrokeColor3=Color3.new(0,0,0)
        local function upd()
            if not bb.Parent then return end
            hL.Text="❤ "..math.floor(math.clamp(hum.Health,0,hum.MaxHealth))
            local myH=getHRP() if myH then dL.Text="📍 "..math.floor((myH.Position-hrp.Position).Magnitude).."st" end
            bb.Enabled=CFG.esp
        end
        hum:GetPropertyChangedSignal("Health"):Connect(function() pcall(upd) end)
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

-- ══ ITEM ESP ══
local itemEspTags={}
task.spawn(function()
    while true do
        task.wait(1)
        if not keyVerified then continue end
        -- Убираем старые
        for obj,bb in pairs(itemEspTags) do
            if not obj or not obj.Parent or not CFG.itemEsp then
                pcall(function() bb:Destroy() end) itemEspTags[obj]=nil
            end
        end
        if not CFG.itemEsp then continue end
        for _,o in ipairs(workspace:GetDescendants()) do
            if isHarvestable(o) and not itemEspTags[o] then
                pcall(function()
                    local pos
                    if o:IsA("Model") then pos=o:GetPivot().Position
                    elseif o:IsA("BasePart") then pos=o.Position end
                    if not pos then return end
                    local part=o:IsA("BasePart") and o or o:FindFirstChildOfClass("BasePart")
                    if not part then return end
                    local bb=Instance.new("BillboardGui") bb.AlwaysOnTop=true bb.Size=UDim2.new(0,90,0,24) bb.StudsOffset=Vector3.new(0,2,0) bb.Adornee=part bb.Parent=part
                    local lbl=Instance.new("TextLabel",bb) lbl.Size=UDim2.new(1,0,1,0) lbl.BackgroundTransparency=1 lbl.Font=Enum.Font.GothamBold lbl.TextSize=12 lbl.Text="🌱 "..o.Name lbl.TextColor3=Color3.fromRGB(100,255,100) lbl.TextStrokeTransparency=0 lbl.TextStrokeColor3=Color3.new(0,0,0)
                    itemEspTags[o]=bb
                end)
            end
        end
    end
end)

-- ══════════════════════════════════════════════════════════
--   GUI
-- ══════════════════════════════════════════════════════════
if game.CoreGui:FindFirstChild("PTH_GH") then game.CoreGui.PTH_GH:Destroy() end
local sg=Instance.new("ScreenGui",game.CoreGui)
sg.Name="PTH_GH" sg.ResetOnSpawn=false sg.DisplayOrder=999 sg.IgnoreGuiInset=true

local BG    = Color3.fromRGB(10,12,10)
local SIDE  = Color3.fromRGB(14,16,14)
local CARD  = Color3.fromRGB(18,22,18)
local BORDER= Color3.fromRGB(35,55,35)
local GREEN = Color3.fromRGB(50,200,80)
local DGREEN= Color3.fromRGB(30,120,50)
local WHITE = Color3.fromRGB(228,228,228)
local MUTED = Color3.fromRGB(85,100,85)
local DIM   = Color3.fromRGB(25,32,25)
local GOLD  = Color3.fromRGB(243,180,18)
local RED2  = Color3.fromRGB(200,50,50)

local function tw(o,t,p) TweenService:Create(o,TweenInfo.new(t,Enum.EasingStyle.Quart),p):Play() end
local function twB(o,t,p) TweenService:Create(o,TweenInfo.new(t,Enum.EasingStyle.Back,Enum.EasingDirection.Out),p):Play() end

-- ══════════════════════════════════════════
--   ЭКРАН ВВОДА КЛЮЧА
-- ══════════════════════════════════════════
local KeyScreen=Instance.new("Frame",sg)
KeyScreen.Size=UDim2.new(1,0,1,0) KeyScreen.BackgroundColor3=Color3.fromRGB(3,8,3) KeyScreen.BorderSizePixel=0 KeyScreen.ZIndex=200

local ksBG=Instance.new("UIGradient",KeyScreen)
ksBG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(2,10,2)),ColorSequenceKeypoint.new(1,Color3.fromRGB(5,20,5))}) ksBG.Rotation=135

-- Частицы/звёзды
math.randomseed(tick())
for i=1,80 do
    local s=Instance.new("TextLabel",KeyScreen) s.Size=UDim2.new(0,12,0,12)
    s.Position=UDim2.new(math.random(1,99)/100,0,math.random(1,99)/100,0)
    s.BackgroundTransparency=1 s.Text=(i%3==0 and "✦" or i%3==1 and "🌿" or "⭐")
    s.TextSize=math.random(8,16) s.TextTransparency=math.random(40,80)/100 s.ZIndex=201
    s.Font=Enum.Font.GothamBold
    task.spawn(function() while s and s.Parent do
        TweenService:Create(s,TweenInfo.new(math.random(15,30)/10),{TextTransparency=0.1}):Play()
        task.wait(math.random(15,30)/10)
        TweenService:Create(s,TweenInfo.new(math.random(15,30)/10),{TextTransparency=0.9}):Play()
        task.wait(math.random(15,30)/10)
    end end)
end

-- Центральная карточка
local ksCard=Instance.new("Frame",KeyScreen) ksCard.Size=UDim2.new(0.82,0,0,320) ksCard.Position=UDim2.new(0.09,0,0.5,-160) ksCard.BackgroundColor3=Color3.fromRGB(8,16,8) ksCard.BorderSizePixel=0 ksCard.ZIndex=202
Instance.new("UICorner",ksCard).CornerRadius=UDim.new(0,16)
Instance.new("UIStroke",ksCard).Color=BORDER

local ksTop=Instance.new("Frame",ksCard) ksTop.Size=UDim2.new(1,0,0,3) ksTop.BackgroundColor3=GREEN ksTop.BorderSizePixel=0 ksTop.ZIndex=203
Instance.new("UICorner",ksTop).CornerRadius=UDim.new(0,16)

-- Иконка
local ksIcon=Instance.new("TextLabel",ksCard) ksIcon.Size=UDim2.new(1,0,0,60) ksIcon.Position=UDim2.new(0,0,0,18) ksIcon.BackgroundTransparency=1 ksIcon.Text="🌱" ksIcon.TextSize=52 ksIcon.Font=Enum.Font.GothamBlack ksIcon.ZIndex=203

-- Заголовок
local ksTitle=Instance.new("TextLabel",ksCard) ksTitle.Size=UDim2.new(1,0,0,32) ksTitle.Position=UDim2.new(0,0,0,82) ksTitle.BackgroundTransparency=1 ksTitle.Text="PRIMEJTSU HUB" ksTitle.TextColor3=GREEN ksTitle.Font=Enum.Font.GothamBlack ksTitle.TextSize=22 ksTitle.ZIndex=203
local ksSub=Instance.new("TextLabel",ksCard) ksSub.Size=UDim2.new(1,0,0,18) ksSub.Position=UDim2.new(0,0,0,115) ksSub.BackgroundTransparency=1 ksSub.Text="Garden Horizons  •  @Primejtsu" ksSub.TextColor3=MUTED ksSub.Font=Enum.Font.Code ksSub.TextSize=11 ksSub.ZIndex=203

-- Надпись "введи ключ"
local ksHint=Instance.new("TextLabel",ksCard) ksHint.Size=UDim2.new(0.85,0,0,18) ksHint.Position=UDim2.new(0.075,0,0,144) ksHint.BackgroundTransparency=1 ksHint.Text="🔑  Введи ключ доступа:" ksHint.TextColor3=MUTED ksHint.Font=Enum.Font.GothamBold ksHint.TextSize=12 ksHint.TextXAlignment=Enum.TextXAlignment.Left ksHint.ZIndex=203

-- Поле ввода
local ksBox=Instance.new("Frame",ksCard) ksBox.Size=UDim2.new(0.85,0,0,44) ksBox.Position=UDim2.new(0.075,0,0,166) ksBox.BackgroundColor3=DIM ksBox.BorderSizePixel=0 ksBox.ZIndex=203
Instance.new("UICorner",ksBox).CornerRadius=UDim.new(0,10)
Instance.new("UIStroke",ksBox).Color=BORDER

local ksInput=Instance.new("TextBox",ksBox) ksInput.Size=UDim2.new(1,-16,1,0) ksInput.Position=UDim2.new(0,8,0,0) ksInput.BackgroundTransparency=1 ksInput.Text="" ksInput.PlaceholderText="Введи ключ здесь..." ksInput.PlaceholderColor3=MUTED ksInput.TextColor3=WHITE ksInput.Font=Enum.Font.GothamBold ksInput.TextSize=14 ksInput.ClearTextOnFocus=false ksInput.ZIndex=204

-- Статус
local ksStatus=Instance.new("TextLabel",ksCard) ksStatus.Size=UDim2.new(0.85,0,0,20) ksStatus.Position=UDim2.new(0.075,0,0,216) ksStatus.BackgroundTransparency=1 ksStatus.Text="" ksStatus.Font=Enum.Font.GothamBold ksStatus.TextSize=11 ksStatus.ZIndex=203 ksStatus.TextXAlignment=Enum.TextXAlignment.Left

-- Кнопка Войти
local ksBtn=Instance.new("TextButton",ksCard) ksBtn.Size=UDim2.new(0.85,0,0,46) ksBtn.Position=UDim2.new(0.075,0,0,244) ksBtn.BackgroundColor3=DGREEN ksBtn.Text="✅  ВОЙТИ" ksBtn.TextColor3=WHITE ksBtn.Font=Enum.Font.GothamBlack ksBtn.TextSize=15 ksBtn.BorderSizePixel=0 ksBtn.ZIndex=204
Instance.new("UICorner",ksBtn).CornerRadius=UDim.new(0,10)
Instance.new("UIStroke",ksBtn).Color=GREEN

-- Версия
local ksVer=Instance.new("TextLabel",ksCard) ksVer.Size=UDim2.new(1,0,0,16) ksVer.Position=UDim2.new(0,0,0,298) ksVer.BackgroundTransparency=1 ksVer.Text="v1.0  •  Garden Horizons  •  Nazar513000" ksVer.TextColor3=Color3.fromRGB(60,80,60) ksVer.Font=Enum.Font.Code ksVer.TextSize=9 ksVer.ZIndex=203

local function showMain() end -- будет определена ниже

local function tryKey()
    local entered=ksInput.Text
    if entered==VALID_KEY then
        ksStatus.Text="✅ Ключ принят! Загружаю..."
        ksStatus.TextColor3=GREEN
        TweenService:Create(ksBtn,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(20,160,60)}):Play()
        Instance.new("UIStroke",ksBox).Color=GREEN
        keyVerified=true
        task.wait(0.8)
        tw(KeyScreen,0.5,{BackgroundTransparency=1})
        for _,o in ipairs(KeyScreen:GetDescendants()) do
            if o:IsA("TextLabel") then tw(o,0.3,{TextTransparency=1})
            elseif o:IsA("Frame") then tw(o,0.35,{BackgroundTransparency=1}) end
        end
        task.wait(0.6) KeyScreen:Destroy() showMain()
    else
        ksStatus.Text="❌ Неверный ключ! Попробуй снова."
        ksStatus.TextColor3=RED2
        TweenService:Create(ksBox,TweenInfo.new(0.05),{Position=UDim2.new(0.075,-8,0,166)}):Play()
        task.wait(0.05) TweenService:Create(ksBox,TweenInfo.new(0.05),{Position=UDim2.new(0.075,8,0,166)}):Play()
        task.wait(0.05) TweenService:Create(ksBox,TweenInfo.new(0.05),{Position=UDim2.new(0.075,0,0,166)}):Play()
        Instance.new("UIStroke",ksBox).Color=RED2
    end
end

ksBtn.MouseButton1Click:Connect(tryKey)
ksInput.FocusLost:Connect(function(enter) if enter then tryKey() end end)

-- ══════════════════════════════════════════
--   ГЛАВНЫЙ HUB
-- ══════════════════════════════════════════
showMain = function()

local iconFrame=Instance.new("Frame",sg) iconFrame.Size=UDim2.new(0,46,0,46) iconFrame.Position=UDim2.new(1,-56,0.5,-23) iconFrame.BackgroundColor3=Color3.fromRGB(10,25,10) iconFrame.BorderSizePixel=0 iconFrame.ZIndex=50
Instance.new("UICorner",iconFrame).CornerRadius=UDim.new(0,12)
local iconBG=Instance.new("Frame",iconFrame) iconBG.Size=UDim2.new(1,0,1,0) iconBG.BackgroundColor3=DGREEN iconBG.BorderSizePixel=0 iconBG.ZIndex=51
Instance.new("UICorner",iconBG).CornerRadius=UDim.new(0,12)
local iconBot=Instance.new("Frame",iconFrame) iconBot.Size=UDim2.new(1,0,0.35,0) iconBot.Position=UDim2.new(0,0,0.65,0) iconBot.BackgroundColor3=Color3.fromRGB(20,80,30) iconBot.BorderSizePixel=0 iconBot.ZIndex=52
Instance.new("UICorner",iconBot).CornerRadius=UDim.new(0,12)
local ibf=Instance.new("Frame",iconBot) ibf.Size=UDim2.new(1,0,0.5,0) ibf.BackgroundColor3=Color3.fromRGB(20,80,30) ibf.BorderSizePixel=0 ibf.ZIndex=52
local iconLetter=Instance.new("TextLabel",iconFrame) iconLetter.Size=UDim2.new(1,0,1,0) iconLetter.BackgroundTransparency=1 iconLetter.Text="🌱" iconLetter.TextSize=22 iconLetter.Font=Enum.Font.GothamBlack iconLetter.ZIndex=53
local dotIcon=Instance.new("Frame",iconFrame) dotIcon.Size=UDim2.new(0,10,0,10) dotIcon.Position=UDim2.new(1,-3,0,-3) dotIcon.BackgroundColor3=GREEN dotIcon.BorderSizePixel=0 dotIcon.ZIndex=54
Instance.new("UICorner",dotIcon).CornerRadius=UDim.new(1,0)
task.spawn(function() while sg and sg.Parent do tw(dotIcon,0.8,{BackgroundTransparency=0.6}) task.wait(0.8) tw(dotIcon,0.8,{BackgroundTransparency=0}) task.wait(0.8) end end)

-- Drag иконки
local drag=false local dSt=nil local sSt=nil
iconFrame.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true dSt=i.Position sSt=iconFrame.Position end end)
iconFrame.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
UIS.InputChanged:Connect(function(i) if drag and(i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMove) then local d=i.Position-dSt iconFrame.Position=UDim2.new(sSt.X.Scale,sSt.X.Offset+d.X,sSt.Y.Scale,sSt.Y.Offset+d.Y) end end)

-- Главное окно
local W=Instance.new("Frame",sg)
W.Size=UDim2.new(0.85,0,0.74,0) W.Position=UDim2.new(0.075,0,0.13,0)
W.BackgroundColor3=BG W.BorderSizePixel=0 W.Active=true W.Draggable=true W.ClipsDescendants=true W.Visible=false
Instance.new("UICorner",W).CornerRadius=UDim.new(0,12)
Instance.new("UIStroke",W).Color=BORDER

local guiOpen=false local tS2=Vector2.new(0,0) local tT2=0
local function openGUI()
    guiOpen=true W.Visible=true W.Size=UDim2.new(0,0,0,0) W.Position=UDim2.new(0.5,0,0.5,0)
    TweenService:Create(W,TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0.85,0,0.74,0),Position=UDim2.new(0.075,0,0.13,0)}):Play()
    tw(iconFrame,0.2,{Size=UDim2.new(0,38,0,38)})
end
local function closeGUI()
    guiOpen=false
    TweenService:Create(W,TweenInfo.new(0.2,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0)}):Play()
    task.wait(0.25) W.Visible=false
    tw(iconFrame,0.2,{Size=UDim2.new(0,46,0,46)})
end
iconFrame.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then tS2=Vector2.new(i.Position.X,i.Position.Y) tT2=tick() end end)
iconFrame.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
        local dist=(Vector2.new(i.Position.X,i.Position.Y)-tS2).Magnitude
        if dist<10 and tick()-tT2<0.4 then if guiOpen then closeGUI() else openGUI() end end
    end
end)

-- ХЕДЕР
local Hdr=Instance.new("Frame",W) Hdr.Size=UDim2.new(1,0,0,44) Hdr.BackgroundColor3=SIDE Hdr.BorderSizePixel=0
Instance.new("UICorner",Hdr).CornerRadius=UDim.new(0,12)
Instance.new("Frame",Hdr).Size=UDim2.new(1,0,0.5,0) -- fill bottom corners
local hf2=W:FindFirstChild("Frame") -- (не нужно)
local topLine=Instance.new("Frame",Hdr) topLine.Size=UDim2.new(1,0,0,2) topLine.BackgroundColor3=GREEN topLine.BorderSizePixel=0
local hIcon=Instance.new("TextLabel",Hdr) hIcon.Size=UDim2.new(0,26,1,0) hIcon.Position=UDim2.new(0,10,0,0) hIcon.BackgroundTransparency=1 hIcon.Text="🌱" hIcon.TextSize=22 hIcon.Font=Enum.Font.GothamBlack
local hTitle=Instance.new("TextLabel",Hdr) hTitle.Size=UDim2.new(0.5,0,0,26) hTitle.Position=UDim2.new(0,36,0.5,-13) hTitle.BackgroundTransparency=1 hTitle.Text="PRIMEJTSU HUB" hTitle.TextColor3=GREEN hTitle.Font=Enum.Font.GothamBlack hTitle.TextSize=15 hTitle.TextXAlignment=Enum.TextXAlignment.Left
local hSub=Instance.new("TextLabel",Hdr) hSub.Size=UDim2.new(1,0,0,13) hSub.Position=UDim2.new(0,36,1,-15) hSub.BackgroundTransparency=1 hSub.Text="Garden Horizons  •  @Primejtsu 🌿" hSub.TextColor3=MUTED hSub.Font=Enum.Font.Code hSub.TextSize=9 hSub.TextXAlignment=Enum.TextXAlignment.Left
local xBtn=Instance.new("TextButton",Hdr) xBtn.Size=UDim2.new(0,28,0,28) xBtn.Position=UDim2.new(1,-34,0.5,-14) xBtn.BackgroundColor3=Color3.fromRGB(60,20,20) xBtn.Text="✕" xBtn.TextColor3=WHITE xBtn.Font=Enum.Font.GothamBold xBtn.TextSize=12 xBtn.BorderSizePixel=0
Instance.new("UICorner",xBtn).CornerRadius=UDim.new(0,7) xBtn.MouseButton1Click:Connect(closeGUI)

-- BODY
local Body=Instance.new("Frame",W) Body.Size=UDim2.new(1,0,1,-44) Body.Position=UDim2.new(0,0,0,44) Body.BackgroundColor3=BG Body.BorderSizePixel=0
local SB=Instance.new("Frame",Body) SB.Size=UDim2.new(0,90,1,0) SB.BackgroundColor3=SIDE SB.BorderSizePixel=0
Instance.new("Frame",Body).Size=UDim2.new(0,1,1,0)
local sdiv=Body:FindFirstChildOfClass("Frame")
local CT=Instance.new("ScrollingFrame",Body)
CT.Size=UDim2.new(1,-91,1,-46) CT.Position=UDim2.new(0,91,0,0)
CT.BackgroundColor3=BG CT.BackgroundTransparency=0 CT.BorderSizePixel=0
CT.ScrollBarThickness=0 CT.CanvasSize=UDim2.new(0,0,0,0)
CT.ScrollingDirection=Enum.ScrollingDirection.Y CT.ScrollingEnabled=true
-- Свайп скролл
local swSt=nil local swCanvas=0
CT.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then swSt=i.Position.Y swCanvas=CT.CanvasPosition.Y end end)
CT.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch and swSt then local mv=swSt-i.Position.Y local mx=math.max(0,CT.AbsoluteCanvasSize.Y-CT.AbsoluteSize.Y) CT.CanvasPosition=Vector2.new(0,math.clamp(swCanvas+mv,0,mx)) end end)
CT.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then swSt=nil end end)

-- Кнопки скролла
local scrollBtns=Instance.new("Frame",Body) scrollBtns.Size=UDim2.new(1,-91,0,42) scrollBtns.Position=UDim2.new(0,91,1,-42) scrollBtns.BackgroundColor3=SIDE scrollBtns.BorderSizePixel=0
Instance.new("Frame",scrollBtns).Size=UDim2.new(1,0,0,1)
local btnU=Instance.new("TextButton",scrollBtns) btnU.Size=UDim2.new(0.5,0,1,0) btnU.BackgroundColor3=SIDE btnU.BorderSizePixel=0 btnU.Text="▲" btnU.TextColor3=GREEN btnU.Font=Enum.Font.GothamBlack btnU.TextSize=18
local btnD=Instance.new("TextButton",scrollBtns) btnD.Size=UDim2.new(0.5,0,1,0) btnD.Position=UDim2.new(0.5,0,0,0) btnD.BackgroundColor3=SIDE btnD.BorderSizePixel=0 btnD.Text="▼" btnD.TextColor3=WHITE btnD.Font=Enum.Font.GothamBlack btnD.TextSize=18
Instance.new("Frame",scrollBtns).Size=UDim2.new(0,1,1,0)
local sc=false
local function doSc(d) task.spawn(function() while sc do local mx=math.max(0,CT.AbsoluteCanvasSize.Y-CT.AbsoluteSize.Y) CT.CanvasPosition=Vector2.new(0,math.clamp(CT.CanvasPosition.Y+d*26,0,mx)) task.wait(0.045) end end) end
btnU.MouseButton1Down:Connect(function() sc=true doSc(-1) end) btnU.InputEnded:Connect(function() sc=false end)
btnD.MouseButton1Down:Connect(function() sc=true doSc(1) end) btnD.InputEnded:Connect(function() sc=false end)

local CTL=Instance.new("UIListLayout",CT) CTL.Padding=UDim.new(0,5) CTL.SortOrder=Enum.SortOrder.LayoutOrder
local CTP=Instance.new("UIPadding",CT) CTP.PaddingLeft=UDim.new(0,10) CTP.PaddingRight=UDim.new(0,10) CTP.PaddingTop=UDim.new(0,8) CTP.PaddingBottom=UDim.new(0,8)
CTL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() CT.CanvasSize=UDim2.new(0,0,0,CTL.AbsoluteContentSize.Y+16) end)

local tabContent={} local tabBtns={}
local TABS={"Info","Player","Farm","ESP","Misc"}
for _,n in ipairs(TABS) do tabContent[n]={} end
Instance.new("UIListLayout",SB).Padding=UDim.new(0,0)
Instance.new("UIPadding",SB).PaddingTop=UDim.new(0,6)

local tabIcons={Info="ℹ",Player="🏃",Farm="🌾",ESP="👁",Misc="⚙"}
local function makeSideBtn(label,icon)
    local b=Instance.new("TextButton",SB) b.Size=UDim2.new(1,0,0,46) b.BackgroundTransparency=1 b.Text="" b.BorderSizePixel=0
    local dot=Instance.new("Frame",b) dot.Size=UDim2.new(0,3,0,22) dot.Position=UDim2.new(0,0,0.5,-11) dot.BackgroundColor3=GREEN dot.BorderSizePixel=0 dot.Visible=false
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    local il=Instance.new("TextLabel",b) il.Size=UDim2.new(1,0,0,22) il.Position=UDim2.new(0,0,0,4) il.BackgroundTransparency=1 il.Text=icon il.TextColor3=MUTED il.Font=Enum.Font.Gotham il.TextSize=16
    local l=Instance.new("TextLabel",b) l.Size=UDim2.new(1,0,0,16) l.Position=UDim2.new(0,0,0,26) l.BackgroundTransparency=1 l.Text=label l.TextColor3=MUTED l.Font=Enum.Font.GothamBold l.TextSize=9 l.TextXAlignment=Enum.TextXAlignment.Center
    tabBtns[label]={btn=b,dot=dot,lbl=l,ico=il} return b
end

local curFrames={}
local function switchTab(name)
    for _,f in ipairs(curFrames) do f.Parent=nil end curFrames={}
    for k,t in pairs(tabBtns) do t.dot.Visible=false t.lbl.TextColor3=MUTED t.ico.TextColor3=MUTED end
    if tabBtns[name] then tabBtns[name].dot.Visible=true tabBtns[name].lbl.TextColor3=WHITE tabBtns[name].ico.TextColor3=GREEN end
    if tabContent[name] then for _,f in ipairs(tabContent[name]) do f.Parent=CT table.insert(curFrames,f) end end
    task.wait() CT.CanvasSize=UDim2.new(0,0,0,CTL.AbsoluteContentSize.Y+16) CT.CanvasPosition=Vector2.new(0,0)
end
for _,n in ipairs(TABS) do local b=makeSideBtn(n,tabIcons[n]) local nn=n b.MouseButton1Click:Connect(function() switchTab(nn) end) end

-- Вспом функции UI
local function mkSec(tab,title)
    local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,22) f.BackgroundTransparency=1 f.BorderSizePixel=0
    local l=Instance.new("TextLabel",f) l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1 l.Text=title l.TextColor3=Color3.fromRGB(80,140,80) l.Font=Enum.Font.GothamBold l.TextSize=11 l.TextXAlignment=Enum.TextXAlignment.Left
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
        local ti=TweenInfo.new(0.15)
        if on then TweenService:Create(track,ti,{BackgroundColor3=GREEN}):Play() TweenService:Create(circle,ti,{Position=UDim2.new(0,22,0.5,-8),BackgroundColor3=WHITE}):Play()
        else TweenService:Create(track,ti,{BackgroundColor3=DIM}):Play() TweenService:Create(circle,ti,{Position=UDim2.new(0,3,0.5,-8),BackgroundColor3=MUTED}):Play() end
        if cfgKey then CFG[cfgKey]=on end
        if onFn then onFn(on) end
    end)
    table.insert(tabContent[tab],f)
end

local function mkButton(tab,title,col,fn)
    local bc=col or DIM
    local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,40) f.BackgroundColor3=bc f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,8) Instance.new("UIStroke",f).Color=BORDER
    local b=Instance.new("TextButton",f) b.Size=UDim2.new(1,0,1,0) b.BackgroundTransparency=1 b.Text=title b.TextColor3=WHITE b.Font=Enum.Font.GothamBold b.TextSize=12 b.BorderSizePixel=0
    b.MouseButton1Click:Connect(function()
        TweenService:Create(f,TweenInfo.new(0.1),{BackgroundColor3=GREEN}):Play()
        task.wait(0.15) TweenService:Create(f,TweenInfo.new(0.1),{BackgroundColor3=bc}):Play()
        if fn then fn() end
    end)
    table.insert(tabContent[tab],f)
end

-- ══ INFO ══
mkSec("Info","🌿 О хабе")
local ic=Instance.new("Frame") ic.Size=UDim2.new(1,0,0,95) ic.BackgroundColor3=CARD ic.BorderSizePixel=0
Instance.new("UICorner",ic).CornerRadius=UDim.new(0,8) Instance.new("UIStroke",ic).Color=BORDER
local itop=Instance.new("Frame",ic) itop.Size=UDim2.new(1,0,0,2) itop.BackgroundColor3=GREEN itop.BorderSizePixel=0
local iIco=Instance.new("TextLabel",ic) iIco.Size=UDim2.new(0,50,0,55) iIco.Position=UDim2.new(0,10,0.5,-27) iIco.BackgroundTransparency=1 iIco.Text="🌱" iIco.TextSize=46 iIco.Font=Enum.Font.GothamBlack
local n1=Instance.new("TextLabel",ic) n1.Size=UDim2.new(1,-70,0,20) n1.Position=UDim2.new(0,62,0,12) n1.BackgroundTransparency=1 n1.Text="Primejtsu Hub" n1.TextColor3=GREEN n1.Font=Enum.Font.GothamBlack n1.TextSize=17 n1.TextXAlignment=Enum.TextXAlignment.Left
local n2=Instance.new("TextLabel",ic) n2.Size=UDim2.new(1,-70,0,14) n2.Position=UDim2.new(0,62,0,34) n2.BackgroundTransparency=1 n2.Text="Garden Horizons" n2.TextColor3=MUTED n2.Font=Enum.Font.Code n2.TextSize=12 n2.TextXAlignment=Enum.TextXAlignment.Left
local n3=Instance.new("TextLabel",ic) n3.Size=UDim2.new(1,-70,0,13) n3.Position=UDim2.new(0,62,0,50) n3.BackgroundTransparency=1 n3.Text="✈ @Primejtsu" n3.TextColor3=Color3.fromRGB(50,150,220) n3.Font=Enum.Font.Code n3.TextSize=11 n3.TextXAlignment=Enum.TextXAlignment.Left
local n4=Instance.new("TextLabel",ic) n4.Size=UDim2.new(1,0,0,14) n4.Position=UDim2.new(0,10,1,-17) n4.BackgroundTransparency=1 n4.Text="v1.0  •  @Primejtsu  •  Nazar513000 🌿" n4.TextColor3=Color3.fromRGB(50,120,50) n4.Font=Enum.Font.Code n4.TextSize=10 n4.TextXAlignment=Enum.TextXAlignment.Left
table.insert(tabContent["Info"],ic)

mkSec("Info","🔑 Ключ")
local kf=Instance.new("Frame") kf.Size=UDim2.new(1,0,0,34) kf.BackgroundColor3=Color3.fromRGB(10,25,10) kf.BorderSizePixel=0
Instance.new("UICorner",kf).CornerRadius=UDim.new(0,8) Instance.new("UIStroke",kf).Color=Color3.fromRGB(30,100,30)
local kl=Instance.new("TextLabel",kf) kl.Size=UDim2.new(1,0,1,0) kl.BackgroundTransparency=1 kl.Text="🔑 Ключ принят: "..VALID_KEY.." ✅" kl.TextColor3=GREEN kl.Font=Enum.Font.GothamBold kl.TextSize=12
table.insert(tabContent["Info"],kf)

-- ══ PLAYER ══
mkSec("Player","🏃 Движение")
mkToggle("Player","⚡ Speed Hack (x2)","speed")
mkToggle("Player","🦅 Fly (лети!)", "fly", function(v)
    if v then startFly() else stopFly() end
end)
mkToggle("Player","👻 Noclip","noclip")
mkToggle("Player","🐇 Infinite Jump","infiniteJump")
mkSec("Player","🛡 Прочее")
mkButton("Player","🔄 Respawn (перерождение)",DIM,function() pcall(function() LP:LoadCharacter() end) end)
mkButton("Player","🚀 Подбросить себя вверх",DIM,function()
    pcall(function() local hrp=getHRP() if hrp then hrp.Velocity=Vector3.new(0,120,0) end end)
end)

-- ══ FARM ══
mkSec("Farm","🌾 Авто-фарм")
mkToggle("Farm","🌿 Авто собирать урожай","autoFarm")
mkToggle("Farm","💰 Авто продавать","autoSell")
mkSec("Farm","💤 АФК")
mkToggle("Farm","😴 Anti AFK","antiAfk")
mkSec("Farm","🔧 Инструменты")
mkButton("Farm","📦 Собрать всё рядом (50st)",Color3.fromRGB(20,50,20),function()
    pcall(function()
        local hrp=getHRP() local hum=getHum() if not hrp or not hum then return end
        hum.WalkSpeed=50
        for _,o in ipairs(workspace:GetDescendants()) do
            if isHarvestable(o) then
                local pos
                pcall(function()
                    if o:IsA("Model") then pos=o:GetPivot().Position
                    elseif o:IsA("BasePart") then pos=o.Position end
                end)
                if pos and (hrp.Position-pos).Magnitude<50 then
                    pcall(function()
                        local cd=o:FindFirstChildOfClass("ClickDetector") or (o.Parent and o.Parent:FindFirstChildOfClass("ClickDetector"))
                        if cd then fireclickdetector(cd) end
                    end)
                end
            end
        end
        task.wait(1) hum.WalkSpeed=16
    end)
end)
mkButton("Farm","🏪 TP к магазину (продать)",Color3.fromRGB(15,40,25),function()
    pcall(function()
        local hrp=getHRP() if not hrp then return end
        for _,o in ipairs(workspace:GetDescendants()) do
            if isSellPoint(o) then
                local pos
                if o:IsA("Model") then pos=o:GetPivot().Position
                elseif o:IsA("BasePart") then pos=o.Position end
                if pos then hrp.CFrame=CFrame.new(pos+Vector3.new(0,3,0)) return end
            end
        end
    end)
end)

-- ══ ESP ══
mkSec("ESP","👁 ESP")
mkToggle("ESP","👥 ESP игроков (имя + HP)","esp")
mkToggle("ESP","🌱 Item ESP (урожай на карте)","itemEsp")
mkSec("ESP","📍 Найти")
mkButton("ESP","🏪 Найти магазин",Color3.fromRGB(15,35,25),function()
    task.spawn(function()
        local found=false
        for _,o in ipairs(workspace:GetDescendants()) do
            if isSellPoint(o) then
                local hrp=getHRP() if not hrp then break end
                local pos
                if o:IsA("Model") then pos=o:GetPivot().Position
                elseif o:IsA("BasePart") then pos=o.Position end
                if pos then
                    local dist=math.floor((hrp.Position-pos).Magnitude)
                    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title="🏪 Магазин найден",Text=o.Name.." — "..dist.." studs от тебя",Duration=5}) end)
                    found=true break
                end
            end
        end
        if not found then pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title="❌ Магазин",Text="Магазин не найден на карте",Duration=3}) end) end
    end)
end)
mkButton("ESP","🌿 Найти урожай",Color3.fromRGB(15,40,15),function()
    task.spawn(function()
        local count=0
        for _,o in ipairs(workspace:GetDescendants()) do if isHarvestable(o) then count=count+1 end end
        pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title="🌿 Урожай",Text="Найдено "..count.." объектов для сбора",Duration=4}) end)
    end)
end)

-- ══ MISC ══
mkSec("Misc","⚙ Разное")
mkToggle("Misc","☀ Fullbright",nil,function(v) setFB(v) end)
mkToggle("Misc","👻 Hide Player (скрыть себя)",nil,function(v)
    pcall(function() local c=getChar() if not c then return end
        for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") or p:IsA("Decal") then p.LocalTransparencyModifier=v and 1 or 0 end end end)
end)
mkButton("Misc","📋 Версия",DIM,function()
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title="🌱 Primejtsu Hub",Text="v1.0 | Garden Horizons | @Primejtsu",Duration=4}) end)
end)

task.wait(0.1) switchTab("Info")
task.wait(0.3) openGUI()

pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title="✅ Primejtsu Hub",Text="Garden Horizons загружен! 🌱 @Primejtsu",Duration=5}) end)

end -- showMain

print("[Primejtsu Hub] Garden Horizons | @Primejtsu | Nazar513000 🌱")
