-- ╔══════════════════════════════════════╗
-- ║     PrimejTsuHub • MM2 • v3.1       ║
-- ║     Разработчик: Primejtsu          ║
-- ║     Telegram: @Primejtsu           ║
-- ╚══════════════════════════════════════╝

local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local TweenService   = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting       = game:GetService("Lighting")
local Camera         = workspace.CurrentCamera
local LP             = Players.LocalPlayer

-- ══════════════════════
--     ANTI-CHEAT
-- ══════════════════════
local lastAct = 0
local function canAct(cd)
    local n = tick()
    if n - lastAct >= (cd or 0.4) then lastAct = n return true end
    return false
end
local function rndWait(a,b) task.wait(a + math.random()*(b-a)) end
local function safe(f,...) pcall(f,...) end

-- ══════════════════════
--      VARIABLES
-- ══════════════════════
local CFG = {
    speed=false, speedVal=28,
    noclip=false,
    freecam=false,
    bhop=false,
    god=false,
    esp=false,
    aimbot=false,
    coinFarm=false,
    knifeAura=false, knifeRadius=10,
    fullbright=false,
    antiAfk=true,
    hidePlayer=false,
}

-- ══════════════════════
--     GAME LOOPS
-- ══════════════════════
-- Noclip
RunService.Stepped:Connect(function()
    if not CFG.noclip then return end
    local c = LP.Character if not c then return end
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
end)

-- God + Speed + Bhop
RunService.Heartbeat:Connect(function()
    local c = LP.Character if not c then return end
    local h = c:FindFirstChildOfClass("Humanoid") if not h then return end
    if CFG.god then h.MaxHealth=1e9 h.Health=1e9 end
    if CFG.speed then
        if h.WalkSpeed < CFG.speedVal then h.WalkSpeed = h.WalkSpeed + 2 end
    else
        if h.WalkSpeed ~= 16 and not CFG.bhop then h.WalkSpeed = 16 end
    end
    if CFG.bhop then
        h.WalkSpeed = 30
        if h.FloorMaterial ~= Enum.Material.Air then h.Jump = true end
    end
end)

-- Coin Farm
RunService.Heartbeat:Connect(function()
    if not CFG.coinFarm then return end
    if not canAct(0.15) then return end
    local c = LP.Character if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart") if not hrp then return end
    for _,o in ipairs(workspace:GetDescendants()) do
        if (o.Name=="Coin" or o.Name=="DropCoin") and o:IsA("BasePart") then
            if (hrp.Position-o.Position).Magnitude < 80 then
                hrp.CFrame = CFrame.new(o.Position+Vector3.new(0,3,0))
                rndWait(0.05,0.15)
            end
        end
    end
end)

-- Knife Aura
RunService.Heartbeat:Connect(function()
    if not CFG.knifeAura then return end
    if not canAct(0.35) then return end
    local c = LP.Character if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart") if not hrp then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Character then
            local t = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if t and hum and hum.Health>0 then
                if (hrp.Position-t.Position).Magnitude<=CFG.knifeRadius then
                    hrp.CFrame = t.CFrame + Vector3.new(0,0,2)
                    rndWait(0.2,0.5)
                end
            end
        end
    end
end)

-- Anti-AFK
safe(function()
    local vu = game:GetService("VirtualUser")
    LP.Idled:Connect(function()
        if CFG.antiAfk then
            vu:Button2Down(Vector2.new(0,0),Camera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0,0),Camera.CFrame)
        end
    end)
end)

-- FullBright
local function setFB(v)
    if v then
        Lighting.Brightness=2.5 Lighting.ClockTime=14
        Lighting.FogEnd=1e5 Lighting.GlobalShadows=false
        Lighting.Ambient=Color3.new(1,1,1)
        Lighting.OutdoorAmbient=Color3.new(1,1,1)
    else
        Lighting.Brightness=1 Lighting.GlobalShadows=true
        Lighting.Ambient=Color3.fromRGB(127,127,127)
        Lighting.OutdoorAmbient=Color3.fromRGB(127,127,127)
    end
end

-- FreeCam
local fcConn
local function enableFC()
    Camera.CameraType = Enum.CameraType.Scriptable
    local cf = Camera.CFrame
    fcConn = RunService.RenderStepped:Connect(function()
        if not CFG.freecam then return end
        local mv = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then mv=mv+Vector3.new(0,0,-1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then mv=mv+Vector3.new(0,0,1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then mv=mv+Vector3.new(-1,0,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then mv=mv+Vector3.new(1,0,0) end
        if mv.Magnitude>0 then cf=cf*CFrame.new(mv*0.4) end
        Camera.CFrame = cf
    end)
end
local function disableFC()
    if fcConn then fcConn:Disconnect() fcConn=nil end
    Camera.CameraType = Enum.CameraType.Custom
    -- Observer mode: спектируем случайного живого игрока
    safe(function()
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP and p.Character then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health>0 then
                    Camera.CameraSubject = hum
                    break
                end
            end
        end
    end)
end

-- ══════════════════════════════════════
--            GUI
-- ══════════════════════════════════════
if game.CoreGui:FindFirstChild("PTHub") then
    game.CoreGui.PTHub:Destroy()
end

local sg = Instance.new("ScreenGui")
sg.Name = "PTHub"
sg.ResetOnSpawn = false
sg.Parent = game.CoreGui

-- ── COLORS ──
local C = {
    bg     = Color3.fromRGB(13,17,23),
    panel  = Color3.fromRGB(17,24,32),
    card   = Color3.fromRGB(22,32,44),
    border = Color3.fromRGB(30,45,60),
    teal   = Color3.fromRGB(0,201,167),
    muted  = Color3.fromRGB(90,110,130),
    text   = Color3.fromRGB(220,232,240),
    red    = Color3.fromRGB(220,50,50),
}

-- ── MAIN WINDOW ──
-- Размер подобран под мобилу (меньше чем раньше)
local W = Instance.new("Frame")
W.Name = "Win"
W.Size = UDim2.new(0, 300, 0, 400)
W.Position = UDim2.new(0.5,-150, 0.5,-200)
W.BackgroundColor3 = C.bg
W.BorderSizePixel = 0
W.Active = true
W.Draggable = true
W.ClipsDescendants = true
W.Parent = sg
local _wc = Instance.new("UICorner",W) _wc.CornerRadius=UDim.new(0,10)
local _ws = Instance.new("UIStroke",W) _ws.Color=C.border _ws.Thickness=1

-- ── HEADER (высота 44) ──
local Hdr = Instance.new("Frame")
Hdr.Size = UDim2.new(1,0,0,44)
Hdr.BackgroundColor3 = C.panel
Hdr.BorderSizePixel = 0
Hdr.ZIndex = 3
Hdr.Parent = W
local _hc = Instance.new("UICorner",Hdr) _hc.CornerRadius=UDim.new(0,10)
-- patch bottom corners
local _hf=Instance.new("Frame",Hdr)
_hf.Size=UDim2.new(1,0,0.5,0) _hf.Position=UDim2.new(0,0,0.5,0)
_hf.BackgroundColor3=C.panel _hf.BorderSizePixel=0 _hf.ZIndex=3

-- Logo circle
local Logo=Instance.new("Frame",Hdr)
Logo.Size=UDim2.new(0,30,0,30) Logo.Position=UDim2.new(0,8,0.5,-15)
Logo.BackgroundColor3=C.teal Logo.BorderSizePixel=0 Logo.ZIndex=4
Instance.new("UICorner",Logo).CornerRadius=UDim.new(0,7)
local LogoTxt=Instance.new("TextLabel",Logo)
LogoTxt.Size=UDim2.new(1,0,1,0) LogoTxt.BackgroundTransparency=1
LogoTxt.Text="🌊" LogoTxt.TextSize=15 LogoTxt.ZIndex=5

-- Title
local Ttl=Instance.new("TextLabel",Hdr)
Ttl.Size=UDim2.new(0,140,0,16) Ttl.Position=UDim2.new(0,44,0,6)
Ttl.BackgroundTransparency=1 Ttl.Text="PrimejTsuHub"
Ttl.TextColor3=C.text Ttl.Font=Enum.Font.GothamBold Ttl.TextSize=13
Ttl.TextXAlignment=Enum.TextXAlignment.Left Ttl.ZIndex=4

local Sub=Instance.new("TextLabel",Hdr)
Sub.Size=UDim2.new(0,160,0,12) Sub.Position=UDim2.new(0,44,0,22)
Sub.BackgroundTransparency=1 Sub.Text="Murder Mystery 2 • v3.1"
Sub.TextColor3=C.muted Sub.Font=Enum.Font.Code Sub.TextSize=9
Sub.TextXAlignment=Enum.TextXAlignment.Left Sub.ZIndex=4

-- Close btn
local Cls=Instance.new("TextButton",Hdr)
Cls.Size=UDim2.new(0,24,0,24) Cls.Position=UDim2.new(1,-30,0.5,-12)
Cls.BackgroundColor3=C.red Cls.Text="✕"
Cls.TextColor3=Color3.new(1,1,1) Cls.Font=Enum.Font.GothamBold Cls.TextSize=11
Cls.BorderSizePixel=0 Cls.ZIndex=5
Instance.new("UICorner",Cls).CornerRadius=UDim.new(0,5)
Cls.MouseButton1Click:Connect(function() sg:Destroy() end)

-- Min btn
local Min=Instance.new("TextButton",Hdr)
Min.Size=UDim2.new(0,24,0,24) Min.Position=UDim2.new(1,-58,0.5,-12)
Min.BackgroundColor3=C.card Min.Text="─"
Min.TextColor3=C.muted Min.Font=Enum.Font.GothamBold Min.TextSize=11
Min.BorderSizePixel=0 Min.ZIndex=5
Instance.new("UICorner",Min).CornerRadius=UDim.new(0,5)
local minned=false
Min.MouseButton1Click:Connect(function()
    minned=not minned
    W.Size = minned and UDim2.new(0,300,0,44) or UDim2.new(0,300,0,400)
    Min.Text = minned and "□" or "─"
end)

-- ── TAB BAR (высота 32) ──
local TBar=Instance.new("Frame",W)
TBar.Size=UDim2.new(1,0,0,32) TBar.Position=UDim2.new(0,0,0,44)
TBar.BackgroundColor3=C.panel TBar.BorderSizePixel=0 TBar.ZIndex=3

local TDiv=Instance.new("Frame",W)
TDiv.Size=UDim2.new(1,0,0,1) TDiv.Position=UDim2.new(0,0,0,76)
TDiv.BackgroundColor3=C.border TDiv.BorderSizePixel=0

-- Tab layout
local TBL=Instance.new("UIListLayout",TBar)
TBL.FillDirection=Enum.FillDirection.Horizontal
TBL.SortOrder=Enum.SortOrder.LayoutOrder

-- Content area
local CA=Instance.new("Frame",W)
CA.Size=UDim2.new(1,0,1,0) -- займёт всё под header+tabs
CA.Position=UDim2.new(0,0,0,77)
CA.Size=UDim2.new(1,0,1,-77)
CA.BackgroundTransparency=1
CA.ClipsDescendants=true

-- ── HELPERS ──
local panels={}

local function mkPanel(name)
    local f=Instance.new("ScrollingFrame",CA)
    f.Name=name f.Size=UDim2.new(1,0,1,0)
    f.BackgroundTransparency=1 f.BorderSizePixel=0
    f.ScrollBarThickness=2 f.ScrollBarImageColor3=C.teal
    f.CanvasSize=UDim2.new(0,0,0,0) f.AutomaticCanvasSize=Enum.AutomaticSize.Y
    f.Visible=false
    local ul=Instance.new("UIListLayout",f)
    ul.Padding=UDim.new(0,5) ul.SortOrder=Enum.SortOrder.LayoutOrder
    local up=Instance.new("UIPadding",f)
    up.PaddingLeft=UDim.new(0,8) up.PaddingRight=UDim.new(0,8)
    up.PaddingTop=UDim.new(0,6) up.PaddingBottom=UDim.new(0,6)
    panels[name]=f
    return f
end

-- Toggle card (компактная)
local function mkCard(parent, ico, name_, desc_, cb)
    local card=Instance.new("Frame",parent)
    card.Size=UDim2.new(1,0,0,60)
    card.BackgroundColor3=C.card card.BorderSizePixel=0
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,8)
    local cs=Instance.new("UIStroke",card) cs.Color=C.border cs.Thickness=1

    -- Icon
    local ib=Instance.new("Frame",card)
    ib.Size=UDim2.new(0,34,0,34) ib.Position=UDim2.new(0,8,0.5,-17)
    ib.BackgroundColor3=Color3.fromRGB(15,38,38) ib.BorderSizePixel=0
    Instance.new("UICorner",ib).CornerRadius=UDim.new(0,7)
    Instance.new("UIStroke",ib).Color=Color3.fromRGB(0,70,60)
    local il=Instance.new("TextLabel",ib)
    il.Size=UDim2.new(1,0,1,0) il.BackgroundTransparency=1
    il.Text=ico il.TextSize=17

    -- Name
    local nl=Instance.new("TextLabel",card)
    nl.Size=UDim2.new(1,-100,0,16) nl.Position=UDim2.new(0,48,0,10)
    nl.BackgroundTransparency=1 nl.Text=name_
    nl.TextColor3=C.teal nl.Font=Enum.Font.GothamBold nl.TextSize=12
    nl.TextXAlignment=Enum.TextXAlignment.Left

    -- Desc
    local dl=Instance.new("TextLabel",card)
    dl.Size=UDim2.new(1,-100,0,24) dl.Position=UDim2.new(0,48,0,26)
    dl.BackgroundTransparency=1 dl.Text=desc_
    dl.TextColor3=C.muted dl.Font=Enum.Font.Gotham dl.TextSize=10
    dl.TextXAlignment=Enum.TextXAlignment.Left dl.TextWrapped=true

    -- Toggle track
    local tt=Instance.new("Frame",card)
    tt.Size=UDim2.new(0,40,0,22) tt.Position=UDim2.new(1,-48,0.5,-11)
    tt.BackgroundColor3=Color3.fromRGB(35,48,62) tt.BorderSizePixel=0
    Instance.new("UICorner",tt).CornerRadius=UDim.new(1,0)

    local tc=Instance.new("Frame",tt)
    tc.Size=UDim2.new(0,16,0,16) tc.Position=UDim2.new(0,3,0.5,-8)
    tc.BackgroundColor3=Color3.new(1,1,1) tc.BorderSizePixel=0
    Instance.new("UICorner",tc).CornerRadius=UDim.new(1,0)

    local on=false
    local btn=Instance.new("TextButton",tt)
    btn.Size=UDim2.new(1,0,1,0) btn.BackgroundTransparency=1 btn.Text=""

    btn.MouseButton1Click:Connect(function()
        on=not on
        local tw=TweenInfo.new(0.18)
        if on then
            TweenService:Create(tt,tw,{BackgroundColor3=C.teal}):Play()
            TweenService:Create(tc,tw,{Position=UDim2.new(0,21,0.5,-8)}):Play()
            cs.Color=Color3.fromRGB(0,100,84)
            nl.TextColor3=C.teal
        else
            TweenService:Create(tt,tw,{BackgroundColor3=Color3.fromRGB(35,48,62)}):Play()
            TweenService:Create(tc,tw,{Position=UDim2.new(0,3,0.5,-8)}):Play()
            cs.Color=C.border
        end
        cb(on)
    end)
    return card
end

-- Section label
local function mkSec(parent,txt)
    local f=Instance.new("Frame",parent)
    f.Size=UDim2.new(1,0,0,20) f.BackgroundTransparency=1
    local l=Instance.new("TextLabel",f)
    l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1
    l.Text="── "..txt.." ──" l.TextColor3=C.muted
    l.Font=Enum.Font.GothamBold l.TextSize=9 l.LetterSpacing=2
end

-- ════════════════════════
--     BUILD PANELS
-- ════════════════════════

-- ── MOVE ──
local mp=mkPanel("MOVE")
mkSec(mp,"ДВИЖЕНИЕ")
mkCard(mp,"⚡","SPEED HACK","Увеличение скорости (anti-ban плавно)",function(v) CFG.speed=v if not v then local c=LP.Character if c then local h=c:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed=16 end end end end)
mkCard(mp,"🏃","BUNNY HOP","Авто-прыжок при приземлении",function(v) CFG.bhop=v end)
mkCard(mp,"🌀","NOCLIP","Проходить сквозь стены",function(v) CFG.noclip=v end)
mkCard(mp,"📷","FREE CAM","Свободная камера. Выкл → Observer Mode",function(v) CFG.freecam=v if v then enableFC() else disableFC() end end)
mkCard(mp,"🎯","AUTO TP","ТП к ближайшему игроку",function(v) if v and canAct(1) then safe(function() local c=LP.Character if not c then return end local hrp=c:FindFirstChild("HumanoidRootPart") if not hrp then return end for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local t=p.Character:FindFirstChild("HumanoidRootPart") if t then hrp.CFrame=t.CFrame+Vector3.new(0,0,3) break end end end end) end end)

-- ── GOD ──
local gp=mkPanel("GOD")
mkSec(gp,"ЗАЩИТА")
mkCard(gp,"🛡","GOD MODE","Бесконечное HP — нельзя умереть",function(v) CFG.god=v end)
mkCard(gp,"👁","ESP","Игроки сквозь стены с именем и HP",function(v) CFG.esp=v end)
mkCard(gp,"💨","ANTI KNOCK","Тебя не отбрасывают",function(v) safe(function() local c=LP.Character if not c then return end local hrp=c:FindFirstChild("HumanoidRootPart") if not hrp then return end if v then hrp.CustomPhysicalProperties=PhysicalProperties.new(0,0,0,0,0) else hrp.CustomPhysicalProperties=PhysicalProperties.new(0.7,0.3,0.5) end end) end)
mkCard(gp,"♾","INF AMMO","Бесконечные патроны для шерифа",function(v) safe(function() local c=LP.Character if not c then return end for _,t in ipairs(c:GetChildren()) do if t:IsA("Tool") then local a=t:FindFirstChild("Ammo") if a then a.Value=v and 999 or a.Value end end end end) end)

-- ── FARM ──
local fp=mkPanel("FARM")
mkSec(fp,"ФАРМ")
mkCard(fp,"💰","COIN FARM","Авто-сбор всех монет на карте",function(v) CFG.coinFarm=v end)
mkCard(fp,"🔪","KNIFE AURA","Авто-убийство в радиусе (убийца)",function(v) CFG.knifeAura=v end)
mkCard(fp,"💎","ITEM COLLECT","Авто-подбор предметов",function(v) CFG.autoItem=v end)
mkCard(fp,"🎁","AUTO REWARD","Авто-нажатие наград в конце раунда",function(v) if v then safe(function() for _,g in ipairs(LP.PlayerGui:GetDescendants()) do if g:IsA("TextButton") and (g.Text:find("Reward") or g.Text:find("Claim") or g.Text:find("Ok")) then g.MouseButton1Click:Fire() end end end) end end)

-- ── MISC ──
local xp=mkPanel("MISC")
mkSec(xp,"РАЗНОЕ")
mkCard(xp,"☀","FULLBRIGHT","Максимум яркости, нет теней",function(v) CFG.fullbright=v setFB(v) end)
mkCard(xp,"🔒","ANTI AFK","Защита от кика за бездействие",function(v) CFG.antiAfk=v end)
mkCard(xp,"👻","HIDE PLAYER","Твой персонаж невидим",function(v) safe(function() local c=LP.Character if not c then return end for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") or p:IsA("Decal") then p.LocalTransparencyModifier=v and 1 or 0 end end end) end)
mkCard(xp,"🌊","ANTI TSUNAMI","Авто-прыжок от волны цунами",function(v) CFG.antiTsunami=v if v then RunService.Heartbeat:Connect(function() if not CFG.antiTsunami then return end safe(function() local c=LP.Character if not c then return end local h=c:FindFirstChildOfClass("Humanoid") if h and h.FloorMaterial~=Enum.Material.Air then h.Jump=true end end) end) end end)

-- ── INFO ──
local ip=mkPanel("INFO")

local devCard=Instance.new("Frame",ip)
devCard.Size=UDim2.new(1,0,0,110) devCard.BackgroundColor3=C.card devCard.BorderSizePixel=0
Instance.new("UICorner",devCard).CornerRadius=UDim.new(0,8)
Instance.new("UIStroke",devCard).Color=C.border

local av=Instance.new("Frame",devCard)
av.Size=UDim2.new(0,52,0,52) av.Position=UDim2.new(0.5,-26,0,10)
av.BackgroundColor3=C.teal av.BorderSizePixel=0
Instance.new("UICorner",av).CornerRadius=UDim.new(0,12)
local avt=Instance.new("TextLabel",av)
avt.Size=UDim2.new(1,0,1,0) avt.BackgroundTransparency=1 avt.Text="👑" avt.TextSize=26

local dn=Instance.new("TextLabel",devCard)
dn.Size=UDim2.new(1,0,0,16) dn.Position=UDim2.new(0,0,0,66)
dn.BackgroundTransparency=1 dn.Text="Primejtsu"
dn.TextColor3=C.teal dn.Font=Enum.Font.GothamBold dn.TextSize=14

local tgb=Instance.new("TextButton",devCard)
tgb.Size=UDim2.new(0,140,0,24) tgb.Position=UDim2.new(0.5,-70,0,84)
tgb.BackgroundColor3=Color3.fromRGB(0,90,160) tgb.Text="✈  @Primejtsu"
tgb.TextColor3=Color3.new(1,1,1) tgb.Font=Enum.Font.GothamBold tgb.TextSize=11
tgb.BorderSizePixel=0
Instance.new("UICorner",tgb).CornerRadius=UDim.new(0,6)

local function mkRow(parent,lbl,val,vc)
    local f=Instance.new("Frame",parent)
    f.Size=UDim2.new(1,0,0,32) f.BackgroundColor3=C.card f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,7)
    Instance.new("UIStroke",f).Color=C.border
    local l=Instance.new("TextLabel",f) l.Size=UDim2.new(0.5,0,1,0) l.Position=UDim2.new(0,10,0,0)
    l.BackgroundTransparency=1 l.Text=lbl l.TextColor3=C.muted
    l.Font=Enum.Font.GothamBold l.TextSize=11 l.TextXAlignment=Enum.TextXAlignment.Left
    local v=Instance.new("TextLabel",f) v.Size=UDim2.new(0.45,0,1,0) v.Position=UDim2.new(0.52,0,0,0)
    v.BackgroundTransparency=1 v.Text=val v.TextColor3=vc or C.teal
    v.Font=Enum.Font.Code v.TextSize=10 v.TextXAlignment=Enum.TextXAlignment.Right
end

mkRow(ip,"Разработчик","Primejtsu",Color3.fromRGB(243,156,18))
mkRow(ip,"Telegram","@Primejtsu",Color3.fromRGB(41,182,246))
mkRow(ip,"Версия","v3.1")
mkRow(ip,"Executor","Delta (Mobile)")
mkRow(ip,"Игра","Murder Mystery 2")
mkRow(ip,"Anti-Cheat","✓ ACTIVE",C.teal)
mkRow(ip,"Фич","17")

-- ════════════════════════
--     BUILD TABS
-- ════════════════════════
local TABS={"MOVE","GOD","FARM","MISC","INFO"}
local tabBtns={}

local function switchTab(name)
    for k,b in pairs(tabBtns) do
        b.TextColor3=C.muted
        local ind=b:FindFirstChild("Ind")
        if ind then ind.Visible=false end
        if panels[k] then panels[k].Visible=false end
    end
    tabBtns[name].TextColor3=C.teal
    local ind=tabBtns[name]:FindFirstChild("Ind")
    if ind then ind.Visible=true end
    if panels[name] then panels[name].Visible=true end
end

for _,name in ipairs(TABS) do
    local btn=Instance.new("TextButton",TBar)
    -- равная ширина
    btn.Size=UDim2.new(0,60,1,0)
    btn.BackgroundTransparency=1 btn.Text=name
    btn.TextColor3=C.muted btn.Font=Enum.Font.GothamBold btn.TextSize=9
    btn.BorderSizePixel=0 btn.ZIndex=4

    local ind=Instance.new("Frame",btn)
    ind.Name="Ind"
    ind.Size=UDim2.new(0.7,0,0,2)
    ind.Position=UDim2.new(0.15,0,1,-2)
    ind.BackgroundColor3=C.teal ind.BorderSizePixel=0 ind.Visible=false
    Instance.new("UICorner",ind).CornerRadius=UDim.new(1,0)

    tabBtns[name]=btn
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
end

-- Первый таб
switchTab("MOVE")

print("[PrimejTsuHub v3.1] ✓ | @Primejtsu | Delta Mobile")
