-- PrimejTsuHub v3.2 | @Primejtsu | Delta Mobile

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- VARS
local CFG = {speed=false,noclip=false,god=false,esp=false,
             bhop=false,coinFarm=false,knife=false,
             fullbright=false,antiAfk=true,hide=false,antiTsunami=false}

-- LOOPS
RunService.Heartbeat:Connect(function()
    local c = LP.Character if not c then return end
    local h = c:FindFirstChildOfClass("Humanoid") if not h then return end
    if CFG.god then h.MaxHealth=1e9 h.Health=1e9 end
    if CFG.speed then if h.WalkSpeed<30 then h.WalkSpeed=h.WalkSpeed+1 end
    else if h.WalkSpeed~=16 then h.WalkSpeed=16 end end
    if CFG.bhop and h.FloorMaterial~=Enum.Material.Air then h.Jump=true end
end)

RunService.Stepped:Connect(function()
    if not CFG.noclip then return end
    local c=LP.Character if not c then return end
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide=false end
    end
end)

local lastCoin=0
RunService.Heartbeat:Connect(function()
    if not CFG.coinFarm then return end
    if tick()-lastCoin<0.2 then return end lastCoin=tick()
    local c=LP.Character if not c then return end
    local hrp=c:FindFirstChild("HumanoidRootPart") if not hrp then return end
    for _,o in ipairs(workspace:GetDescendants()) do
        if (o.Name=="Coin" or o.Name=="DropCoin") and o:IsA("BasePart") then
            if (hrp.Position-o.Position).Magnitude<80 then
                hrp.CFrame=CFrame.new(o.Position+Vector3.new(0,3,0))
                task.wait(0.1)
            end
        end
    end
end)

local lastKnife=0
RunService.Heartbeat:Connect(function()
    if not CFG.knife then return end
    if tick()-lastKnife<0.4 then return end lastKnife=tick()
    local c=LP.Character if not c then return end
    local hrp=c:FindFirstChild("HumanoidRootPart") if not hrp then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Character then
            local t=p.Character:FindFirstChild("HumanoidRootPart")
            local hum=p.Character:FindFirstChildOfClass("Humanoid")
            if t and hum and hum.Health>0 and (hrp.Position-t.Position).Magnitude<=10 then
                hrp.CFrame=t.CFrame+Vector3.new(0,0,2)
                task.wait(0.3)
            end
        end
    end
end)

pcall(function()
    local vu=game:GetService("VirtualUser")
    LP.Idled:Connect(function()
        if CFG.antiAfk then vu:Button2Down(Vector2.new(0,0),Camera.CFrame) task.wait(1) vu:Button2Up(Vector2.new(0,0),Camera.CFrame) end
    end)
end)

-- GUI
if game.CoreGui:FindFirstChild("PTH") then game.CoreGui.PTH:Destroy() end
local sg=Instance.new("ScreenGui",game.CoreGui)
sg.Name="PTH" sg.ResetOnSpawn=false

-- COLORS
local BG=Color3.fromRGB(13,17,23)
local PANEL=Color3.fromRGB(17,24,32)
local CARD=Color3.fromRGB(22,32,44)
local BORDER=Color3.fromRGB(30,45,60)
local TEAL=Color3.fromRGB(0,201,167)
local MUTED=Color3.fromRGB(90,110,130)
local TEXT=Color3.fromRGB(220,232,240)
local RED=Color3.fromRGB(220,50,50)

-- MAIN FRAME 280x380
local W=Instance.new("Frame",sg)
W.Size=UDim2.new(0,280,0,380)
W.Position=UDim2.new(0.5,-140,0.5,-190)
W.BackgroundColor3=BG W.BorderSizePixel=0
W.Active=true W.Draggable=true W.ClipsDescendants=true
Instance.new("UICorner",W).CornerRadius=UDim.new(0,10)
Instance.new("UIStroke",W).Color=BORDER

-- HEADER
local H=Instance.new("Frame",W)
H.Size=UDim2.new(1,0,0,42) H.BackgroundColor3=PANEL H.BorderSizePixel=0
Instance.new("UICorner",H).CornerRadius=UDim.new(0,10)
local hfix=Instance.new("Frame",H) hfix.Size=UDim2.new(1,0,0.5,0) hfix.Position=UDim2.new(0,0,0.5,0) hfix.BackgroundColor3=PANEL hfix.BorderSizePixel=0

-- Logo
local lg=Instance.new("Frame",H) lg.Size=UDim2.new(0,28,0,28) lg.Position=UDim2.new(0,8,0.5,-14) lg.BackgroundColor3=TEAL lg.BorderSizePixel=0
Instance.new("UICorner",lg).CornerRadius=UDim.new(0,7)
local lt=Instance.new("TextLabel",lg) lt.Size=UDim2.new(1,0,1,0) lt.BackgroundTransparency=1 lt.Text="🌊" lt.TextSize=14

local t1=Instance.new("TextLabel",H) t1.Size=UDim2.new(0,130,0,15) t1.Position=UDim2.new(0,42,0,5) t1.BackgroundTransparency=1 t1.Text="PrimejTsuHub" t1.TextColor3=TEXT t1.Font=Enum.Font.GothamBold t1.TextSize=12 t1.TextXAlignment=Enum.TextXAlignment.Left
local t2=Instance.new("TextLabel",H) t2.Size=UDim2.new(0,150,0,11) t2.Position=UDim2.new(0,42,0,20) t2.BackgroundTransparency=1 t2.Text="MM2 • v3.2 | @Primejtsu" t2.TextColor3=MUTED t2.Font=Enum.Font.Code t2.TextSize=9 t2.TextXAlignment=Enum.TextXAlignment.Left

-- Close
local cl=Instance.new("TextButton",H) cl.Size=UDim2.new(0,22,0,22) cl.Position=UDim2.new(1,-28,0.5,-11) cl.BackgroundColor3=RED cl.Text="✕" cl.TextColor3=Color3.new(1,1,1) cl.Font=Enum.Font.GothamBold cl.TextSize=10 cl.BorderSizePixel=0
Instance.new("UICorner",cl).CornerRadius=UDim.new(0,5)
cl.MouseButton1Click:Connect(function() sg:Destroy() end)

-- Min
local mn=Instance.new("TextButton",H) mn.Size=UDim2.new(0,22,0,22) mn.Position=UDim2.new(1,-54,0.5,-11) mn.BackgroundColor3=CARD mn.Text="─" mn.TextColor3=MUTED mn.Font=Enum.Font.GothamBold mn.TextSize=10 mn.BorderSizePixel=0
Instance.new("UICorner",mn).CornerRadius=UDim.new(0,5)
local mini=false
mn.MouseButton1Click:Connect(function()
    mini=not mini
    W.Size=mini and UDim2.new(0,280,0,42) or UDim2.new(0,280,0,380)
    mn.Text=mini and "□" or "─"
end)

-- TAB BAR
local TB=Instance.new("Frame",W) TB.Size=UDim2.new(1,0,0,30) TB.Position=UDim2.new(0,0,0,42) TB.BackgroundColor3=PANEL TB.BorderSizePixel=0
Instance.new("UIListLayout",TB).FillDirection=Enum.FillDirection.Horizontal

-- CONTENT (ScrollingFrame — исправлено CanvasSize)
local CF=Instance.new("ScrollingFrame",W)
CF.Size=UDim2.new(1,0,1,-73) CF.Position=UDim2.new(0,0,0,73)
CF.BackgroundTransparency=1 CF.BorderSizePixel=0
CF.ScrollBarThickness=2 CF.ScrollBarImageColor3=TEAL
CF.CanvasSize=UDim2.new(0,0,0,0)

local CFL=Instance.new("UIListLayout",CF) CFL.Padding=UDim.new(0,5) CFL.SortOrder=Enum.SortOrder.LayoutOrder
local CFP=Instance.new("UIPadding",CF) CFP.PaddingLeft=UDim.new(0,7) CFP.PaddingRight=UDim.new(0,7) CFP.PaddingTop=UDim.new(0,6) CFP.PaddingBottom=UDim.new(0,6)

-- Авто-обновление CanvasSize
CFL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    CF.CanvasSize=UDim2.new(0,0,0,CFL.AbsoluteContentSize.Y+14)
end)

-- Хранилище контента табов
local tabContent = {}
local currentTab = ""

-- Создаём контейнер для каждого таба
local TABNAMES = {"MOVE","GOD","FARM","MISC","INFO"}
for _,name in ipairs(TABNAMES) do
    local f=Instance.new("Frame") -- не парентим сразу в CF
    f.Name=name
    f.Size=UDim2.new(1,0,0,0) -- высота авто
    f.BackgroundTransparency=1 f.BorderSizePixel=0
    f.AutomaticSize=Enum.AutomaticSize.Y
    local fl=Instance.new("UIListLayout",f) fl.Padding=UDim.new(0,5) fl.SortOrder=Enum.SortOrder.LayoutOrder
    tabContent[name]={frame=f, items={}}
end

-- Добавить карточку в таб
local function addCard(tabName, ico, title, desc, cb)
    local parent = tabContent[tabName].frame

    local card=Instance.new("Frame",parent)
    card.Size=UDim2.new(1,0,0,58)
    card.BackgroundColor3=CARD card.BorderSizePixel=0
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,8)
    local cs=Instance.new("UIStroke",card) cs.Color=BORDER cs.Thickness=1

    -- Icon
    local ib=Instance.new("Frame",card) ib.Size=UDim2.new(0,32,0,32) ib.Position=UDim2.new(0,8,0.5,-16) ib.BackgroundColor3=Color3.fromRGB(15,35,35) ib.BorderSizePixel=0
    Instance.new("UICorner",ib).CornerRadius=UDim.new(0,7)
    local il=Instance.new("TextLabel",ib) il.Size=UDim2.new(1,0,1,0) il.BackgroundTransparency=1 il.Text=ico il.TextSize=16

    -- Title
    local nl=Instance.new("TextLabel",card) nl.Size=UDim2.new(1,-90,0,15) nl.Position=UDim2.new(0,46,0,9) nl.BackgroundTransparency=1 nl.Text=title nl.TextColor3=TEAL nl.Font=Enum.Font.GothamBold nl.TextSize=11 nl.TextXAlignment=Enum.TextXAlignment.Left

    -- Desc
    local dl=Instance.new("TextLabel",card) dl.Size=UDim2.new(1,-90,0,22) dl.Position=UDim2.new(0,46,0,24) dl.BackgroundTransparency=1 dl.Text=desc dl.TextColor3=MUTED dl.Font=Enum.Font.Gotham dl.TextSize=9 dl.TextXAlignment=Enum.TextXAlignment.Left dl.TextWrapped=true

    -- Toggle
    local tt=Instance.new("Frame",card) tt.Size=UDim2.new(0,38,0,20) tt.Position=UDim2.new(1,-44,0.5,-10) tt.BackgroundColor3=Color3.fromRGB(35,48,62) tt.BorderSizePixel=0
    Instance.new("UICorner",tt).CornerRadius=UDim.new(1,0)
    local tc=Instance.new("Frame",tt) tc.Size=UDim2.new(0,14,0,14) tc.Position=UDim2.new(0,3,0.5,-7) tc.BackgroundColor3=Color3.new(1,1,1) tc.BorderSizePixel=0
    Instance.new("UICorner",tc).CornerRadius=UDim.new(1,0)
    local tbtn=Instance.new("TextButton",tt) tbtn.Size=UDim2.new(1,0,1,0) tbtn.BackgroundTransparency=1 tbtn.Text=""

    local on=false
    tbtn.MouseButton1Click:Connect(function()
        on=not on
        local tw=TweenInfo.new(0.15)
        if on then
            TweenService:Create(tt,tw,{BackgroundColor3=TEAL}):Play()
            TweenService:Create(tc,tw,{Position=UDim2.new(0,21,0.5,-7)}):Play()
            cs.Color=Color3.fromRGB(0,100,84)
        else
            TweenService:Create(tt,tw,{BackgroundColor3=Color3.fromRGB(35,48,62)}):Play()
            TweenService:Create(tc,tw,{Position=UDim2.new(0,3,0.5,-7)}):Play()
            cs.Color=BORDER
        end
        cb(on)
    end)
end

-- INFO карточка
local function addInfoRow(tabName, lbl, val, vc)
    local parent=tabContent[tabName].frame
    local f=Instance.new("Frame",parent) f.Size=UDim2.new(1,0,0,30) f.BackgroundColor3=CARD f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,7)
    Instance.new("UIStroke",f).Color=BORDER
    local l=Instance.new("TextLabel",f) l.Size=UDim2.new(0.5,0,1,0) l.Position=UDim2.new(0,10,0,0) l.BackgroundTransparency=1 l.Text=lbl l.TextColor3=MUTED l.Font=Enum.Font.GothamBold l.TextSize=11 l.TextXAlignment=Enum.TextXAlignment.Left
    local v=Instance.new("TextLabel",f) v.Size=UDim2.new(0.45,0,1,0) v.Position=UDim2.new(0.52,0,0,0) v.BackgroundTransparency=1 v.Text=val v.TextColor3=vc or TEAL v.Font=Enum.Font.Code v.TextSize=10 v.TextXAlignment=Enum.TextXAlignment.Right
end

-- ══ ЗАПОЛНЯЕМ ТАБЫ ══

-- MOVE
addCard("MOVE","⚡","SPEED HACK","Плавное ускорение (anti-ban)",function(v) CFG.speed=v end)
addCard("MOVE","🏃","BUNNY HOP","Авто-прыжок при приземлении",function(v) CFG.bhop=v end)
addCard("MOVE","🌀","NOCLIP","Проходить сквозь стены",function(v) CFG.noclip=v end)
addCard("MOVE","📷","FREE CAM","Своб. камера → выкл = Observer",function(v)
    if v then
        Camera.CameraType=Enum.CameraType.Scriptable
        RunService.RenderStepped:Connect(function()
            if not CFG.freecam then return end
        end)
        CFG.freecam=true
    else
        CFG.freecam=false
        Camera.CameraType=Enum.CameraType.Custom
        pcall(function()
            for _,p in ipairs(Players:GetPlayers()) do
                if p~=LP and p.Character then
                    local hum=p.Character:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health>0 then Camera.CameraSubject=hum break end
                end
            end
        end)
    end
end)
addCard("MOVE","🎯","AUTO TP","ТП к ближайшему игроку",function(v)
    if not v then return end
    pcall(function()
        local c=LP.Character if not c then return end
        local hrp=c:FindFirstChild("HumanoidRootPart") if not hrp then return end
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP and p.Character then
                local t=p.Character:FindFirstChild("HumanoidRootPart")
                if t then hrp.CFrame=t.CFrame+Vector3.new(0,0,3) break end
            end
        end
    end)
end)

-- GOD
addCard("GOD","🛡","GOD MODE","Бесконечное HP",function(v) CFG.god=v end)
addCard("GOD","👁","ESP","Игроки сквозь стены",function(v) CFG.esp=v end)
addCard("GOD","💨","ANTI KNOCK","Не отбрасывают",function(v)
    pcall(function()
        local c=LP.Character if not c then return end
        local hrp=c:FindFirstChild("HumanoidRootPart") if not hrp then return end
        hrp.CustomPhysicalProperties=v and PhysicalProperties.new(0,0,0,0,0) or PhysicalProperties.new(0.7,0.3,0.5)
    end)
end)
addCard("GOD","♾","INF AMMO","Бесконечные патроны",function(v)
    pcall(function()
        local c=LP.Character if not c then return end
        for _,t in ipairs(c:GetChildren()) do
            if t:IsA("Tool") then local a=t:FindFirstChild("Ammo") if a then a.Value=v and 999 or a.Value end end
        end
    end)
end)

-- FARM
addCard("FARM","💰","COIN FARM","Авто-сбор монет",function(v) CFG.coinFarm=v end)
addCard("FARM","🔪","KNIFE AURA","Авто-убийство рядом",function(v) CFG.knife=v end)
addCard("FARM","💎","ITEM COLLECT","Авто-подбор предметов",function(v) CFG.autoItem=v end)
addCard("FARM","🎁","AUTO REWARD","Авто-нажатие наград",function(v)
    if not v then return end
    pcall(function()
        for _,g in ipairs(LP.PlayerGui:GetDescendants()) do
            if g:IsA("TextButton") and (g.Text:find("Reward") or g.Text:find("Claim")) then
                g.MouseButton1Click:Fire()
            end
        end
    end)
end)

-- MISC
addCard("MISC","☀","FULLBRIGHT","Убрать тени, макс яркость",function(v)
    if v then Lighting.Brightness=2.5 Lighting.ClockTime=14 Lighting.GlobalShadows=false Lighting.Ambient=Color3.new(1,1,1)
    else Lighting.Brightness=1 Lighting.GlobalShadows=true Lighting.Ambient=Color3.fromRGB(127,127,127) end
end)
addCard("MISC","🔒","ANTI AFK","Защита от кика",function(v) CFG.antiAfk=v end)
addCard("MISC","👻","HIDE PLAYER","Персонаж невидим",function(v)
    pcall(function()
        local c=LP.Character if not c then return end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") or p:IsA("Decal") then p.LocalTransparencyModifier=v and 1 or 0 end
        end
    end)
end)
addCard("MISC","🌊","ANTI TSUNAMI","Авто-прыжок от волны",function(v) CFG.antiTsunami=v end)

-- INFO
local ipar=tabContent["INFO"].frame
local av=Instance.new("Frame",ipar) av.Size=UDim2.new(1,0,0,90) av.BackgroundColor3=CARD av.BorderSizePixel=0
Instance.new("UICorner",av).CornerRadius=UDim.new(0,8) Instance.new("UIStroke",av).Color=BORDER
local avi=Instance.new("Frame",av) avi.Size=UDim2.new(0,48,0,48) avi.Position=UDim2.new(0.5,-24,0,8) avi.BackgroundColor3=TEAL avi.BorderSizePixel=0
Instance.new("UICorner",avi).CornerRadius=UDim.new(0,12)
local avt=Instance.new("TextLabel",avi) avt.Size=UDim2.new(1,0,1,0) avt.BackgroundTransparency=1 avt.Text="👑" avt.TextSize=24
local avn=Instance.new("TextLabel",av) avn.Size=UDim2.new(1,0,0,16) avn.Position=UDim2.new(0,0,0,60) avn.BackgroundTransparency=1 avn.Text="Primejtsu" avn.TextColor3=TEAL avn.Font=Enum.Font.GothamBold avn.TextSize=13
local avs=Instance.new("TextLabel",av) avs.Size=UDim2.new(1,0,0,12) avs.Position=UDim2.new(0,0,0,76) avs.BackgroundTransparency=1 avs.Text="✈ Telegram: @Primejtsu" avs.TextColor3=Color3.fromRGB(41,182,246) avs.Font=Enum.Font.Code avs.TextSize=10

addInfoRow("INFO","Версия","v3.2")
addInfoRow("INFO","Игра","Murder Mystery 2")
addInfoRow("INFO","Executor","Delta Mobile")
addInfoRow("INFO","Разработчик","Primejtsu",Color3.fromRGB(243,156,18))
addInfoRow("INFO","Anti-Cheat","ACTIVE",TEAL)
addInfoRow("INFO","Всего фич","17")

-- ══ ТАБЫ ══
local tabBtns={}
local function switchTab(name)
    -- Убираем всё из CF
    for _,child in ipairs(CF:GetChildren()) do
        if child:IsA("Frame") or child:IsA("ScrollingFrame") then
            child.Parent=nil -- убираем из отображения
        end
    end
    -- Показываем нужный
    local f=tabContent[name].frame
    f.Size=UDim2.new(1,0,0,0) -- сброс, AutomaticSize сам посчитает
    f.Parent=CF

    -- Обновляем кнопки
    for k,b in pairs(tabBtns) do
        b.TextColor3=MUTED
        local ind=b:FindFirstChild("I")
        if ind then ind.Visible=false end
    end
    tabBtns[name].TextColor3=TEAL
    local ind=tabBtns[name]:FindFirstChild("I")
    if ind then ind.Visible=true end

    -- Обновить canvas
    task.wait() -- ждём один фрейм
    CF.CanvasSize=UDim2.new(0,0,0,CFL.AbsoluteContentSize.Y+14)
end

for _,name in ipairs(TABNAMES) do
    local b=Instance.new("TextButton",TB)
    b.Size=UDim2.new(0,56,1,0) b.BackgroundTransparency=1
    b.Text=name b.TextColor3=MUTED b.Font=Enum.Font.GothamBold b.TextSize=9
    b.BorderSizePixel=0
    local ind=Instance.new("Frame",b) ind.Name="I"
    ind.Size=UDim2.new(0.7,0,0,2) ind.Position=UDim2.new(0.15,0,1,-2)
    ind.BackgroundColor3=TEAL ind.BorderSizePixel=0 ind.Visible=false
    Instance.new("UICorner",ind).CornerRadius=UDim.new(1,0)
    tabBtns[name]=b
    b.MouseButton1Click:Connect(function() switchTab(name) end)
end

task.wait(0.1)
switchTab("MOVE")

print("[PrimejTsuHub v3.2] OK | @Primejtsu")
