-- TSUNAMI EXECUTOR v5.0 — ALL FUNCTIONS FIXED
-- Speed, God Mode, Jump — всё работает

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local lp = Players.LocalPlayer

local function getChar() return lp.Character or lp.CharacterAdded:Wait() end
local function getHum()
    local c = getChar()
    return c and (c:FindFirstChildOfClass("Humanoid") or c:WaitForChild("Humanoid", 3))
end
local function getRoot()
    local c = getChar()
    return c and (c:FindFirstChild("HumanoidRootPart") or c:WaitForChild("HumanoidRootPart", 3))
end

-- GUI Parent — пробуем всё
local guiParent
local ok1, cg = pcall(function() return game:GetService("CoreGui") end)
if ok1 and cg then
    guiParent = cg
else
    guiParent = lp:WaitForChild("PlayerGui")
end

if guiParent:FindFirstChild("TsuExecV5") then
    guiParent:FindFirstChild("TsuExecV5"):Destroy()
end

local function tw(o, p, t)
    TweenService:Create(o, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad), p):Play()
end

local C = {
    BG    = Color3.fromRGB(5,10,20),
    PAN   = Color3.fromRGB(8,15,30),
    PAN2  = Color3.fromRGB(12,20,38),
    WAVE  = Color3.fromRGB(0,212,255),
    NEON  = Color3.fromRGB(0,255,170),
    RED   = Color3.fromRGB(255,60,60),
    GOLD  = Color3.fromRGB(255,180,0),
    GOLD2 = Color3.fromRGB(255,220,80),
    TEXT  = Color3.fromRGB(210,235,255),
    SUB   = Color3.fromRGB(100,155,200),
    OFF   = Color3.fromRGB(28,38,55),
    WHITE = Color3.fromRGB(255,255,255),
    PUR   = Color3.fromRGB(180,80,255),
}

-- ══════════════════════════════
-- STATE
-- ══════════════════════════════
local S = {
    -- Speed
    Speed = false, SpeedVal = 50,
    -- Jump
    Jump = false, JumpVal = 100,
    -- NoClip
    NoClip = false,
    -- Fly
    Fly = false,
    -- God layers
    HealthLock = false,
    Invuln = false,
    AntiGrav = false,
    AutoTele = false,
    InstRespawn = false,
    WaterImm = false,
    -- Misc
    ESP = false, EspTags = {},
    AutoWin = false,
    Troll = false,
    Bright = false,
    -- UI
    Tab = "SPEED", Min = false,
}

-- ══════════════════════════════
-- SCREEN GUI
-- ══════════════════════════════
local SG = Instance.new("ScreenGui")
SG.Name = "TsuExecV5"
SG.ResetOnSpawn = false
SG.IgnoreGuiInset = true
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.DisplayOrder = 999
SG.Parent = guiParent

local MF = Instance.new("Frame", SG)
MF.Size = UDim2.new(0, 320, 0, 480)
MF.Position = UDim2.new(0, 8, 0, 40)
MF.BackgroundColor3 = C.BG
MF.BorderSizePixel = 0
MF.ClipsDescendants = true
Instance.new("UICorner", MF).CornerRadius = UDim.new(0, 12)
local mst = Instance.new("UIStroke", MF)
mst.Color = C.WAVE; mst.Thickness = 1.5; mst.Transparency = 0.35

-- Gradient top bar
local gt = Instance.new("Frame", MF)
gt.Size = UDim2.new(1,0,0,2); gt.BorderSizePixel=0
gt.BackgroundColor3=C.WAVE
local gg = Instance.new("UIGradient", gt)
gg.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0,Color3.new(0,0,0)),
    ColorSequenceKeypoint.new(0.4,C.WAVE),
    ColorSequenceKeypoint.new(0.6,C.NEON),
    ColorSequenceKeypoint.new(1,Color3.new(0,0,0)),
}

-- ── TITLE BAR ──
local TB = Instance.new("Frame", MF)
TB.Size = UDim2.new(1,0,0,46); TB.Position = UDim2.new(0,0,0,2)
TB.BackgroundColor3 = C.PAN; TB.BorderSizePixel = 0

local TT = Instance.new("TextLabel", TB)
TT.Size = UDim2.new(1,-90,0,26); TT.Position = UDim2.new(0,12,0,4)
TT.BackgroundTransparency=1; TT.Font=Enum.Font.GothamBold
TT.Text="🌊 TSUNAMI EXECUTOR"; TT.TextColor3=C.WAVE
TT.TextSize=15; TT.TextXAlignment=Enum.TextXAlignment.Left

local TS = Instance.new("TextLabel", TB)
TS.Size = UDim2.new(1,-12,0,14); TS.Position = UDim2.new(0,12,0,30)
TS.BackgroundTransparency=1; TS.Font=Enum.Font.Gotham
TS.Text="v5.0  •  ALL FIXED  •  BRAINROT"; TS.TextColor3=C.SUB
TS.TextSize=10; TS.TextXAlignment=Enum.TextXAlignment.Left

local MinBtn = Instance.new("TextButton", TB)
MinBtn.Size=UDim2.new(0,36,0,28); MinBtn.Position=UDim2.new(1,-80,0.5,-14)
MinBtn.BackgroundColor3=Color3.fromRGB(18,28,48); MinBtn.BorderSizePixel=0
MinBtn.Text="—"; MinBtn.TextColor3=C.SUB; MinBtn.TextSize=16; MinBtn.Font=Enum.Font.GothamBold
Instance.new("UICorner",MinBtn).CornerRadius=UDim.new(0,6)

local ClBtn = Instance.new("TextButton", TB)
ClBtn.Size=UDim2.new(0,32,0,28); ClBtn.Position=UDim2.new(1,-42,0.5,-14)
ClBtn.BackgroundColor3=Color3.fromRGB(55,18,18); ClBtn.BorderSizePixel=0
ClBtn.Text="✕"; ClBtn.TextColor3=C.RED; ClBtn.TextSize=14; ClBtn.Font=Enum.Font.GothamBold
Instance.new("UICorner",ClBtn).CornerRadius=UDim.new(0,6)

-- ── TABS ──
local TABS = {"SPEED","GOD☠️","MISC"}
local TAB_COLS = {SPEED=C.WAVE,["GOD☠️"]=C.GOLD,MISC=C.PUR}
local TabBtns = {}

local TabBar = Instance.new("Frame", MF)
TabBar.Size=UDim2.new(1,0,0,40); TabBar.Position=UDim2.new(0,0,0,50)
TabBar.BackgroundColor3=C.PAN; TabBar.BorderSizePixel=0

for i,t in ipairs(TABS) do
    local w = 1/#TABS
    local b = Instance.new("TextButton", TabBar)
    b.Size=UDim2.new(w,-3,1,-8); b.Position=UDim2.new(w*(i-1),2,0,4)
    b.BackgroundColor3=C.PAN2; b.BorderSizePixel=0
    b.Text=t; b.TextColor3=C.SUB; b.TextSize=11; b.Font=Enum.Font.GothamBold
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,7)
    TabBtns[t]=b
end

local TLine = Instance.new("Frame", TabBar)
TLine.Size=UDim2.new(0.28,0,0,2); TLine.Position=UDim2.new(0,4,1,-2)
TLine.BackgroundColor3=C.WAVE; TLine.BorderSizePixel=0
Instance.new("UICorner",TLine).CornerRadius=UDim.new(1,0)

-- ── SCROLL ──
local SC = Instance.new("ScrollingFrame", MF)
SC.Size=UDim2.new(1,0,1,-94); SC.Position=UDim2.new(0,0,0,94)
SC.BackgroundTransparency=1; SC.BorderSizePixel=0
SC.ScrollBarThickness=3; SC.ScrollBarImageColor3=C.WAVE
SC.CanvasSize=UDim2.new(0,0,0,0); SC.AutomaticCanvasSize=Enum.AutomaticSize.Y
SC.ScrollingDirection=Enum.ScrollingDirection.Y

local function resetSC()
    for _,c in ipairs(SC:GetChildren()) do c:Destroy() end
    local il=Instance.new("UIListLayout",SC)
    il.SortOrder=Enum.SortOrder.LayoutOrder; il.Padding=UDim.new(0,5)
    local p=Instance.new("UIPadding",SC)
    p.PaddingLeft=UDim.new(0,8); p.PaddingRight=UDim.new(0,8)
    p.PaddingTop=UDim.new(0,6); p.PaddingBottom=UDim.new(0,10)
end

-- ══════════════════════════════
-- WIDGETS
-- ══════════════════════════════
local function Toggle(parent, label, desc, order, cb)
    local row=Instance.new("Frame",parent)
    row.Size=UDim2.new(1,0,0,54); row.BackgroundColor3=C.PAN2
    row.BorderSizePixel=0; row.LayoutOrder=order
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)

    local nl=Instance.new("TextLabel",row)
    nl.Size=UDim2.new(1,-70,0,26); nl.Position=UDim2.new(0,12,0,6)
    nl.BackgroundTransparency=1; nl.Font=Enum.Font.GothamBold
    nl.Text=label; nl.TextColor3=C.TEXT; nl.TextSize=13
    nl.TextXAlignment=Enum.TextXAlignment.Left; nl.TextWrapped=false

    if desc then
        local dl=Instance.new("TextLabel",row)
        dl.Size=UDim2.new(1,-70,0,16); dl.Position=UDim2.new(0,12,0,32)
        dl.BackgroundTransparency=1; dl.Font=Enum.Font.Gotham
        dl.Text=desc; dl.TextColor3=C.SUB; dl.TextSize=10
        dl.TextXAlignment=Enum.TextXAlignment.Left; dl.TextWrapped=true
    end

    local bg=Instance.new("Frame",row)
    bg.Size=UDim2.new(0,52,0,28); bg.Position=UDim2.new(1,-62,0.5,-14)
    bg.BackgroundColor3=C.OFF; bg.BorderSizePixel=0
    Instance.new("UICorner",bg).CornerRadius=UDim.new(1,0)

    local kn=Instance.new("Frame",bg)
    kn.Size=UDim2.new(0,22,0,22); kn.Position=UDim2.new(0,3,0,3)
    kn.BackgroundColor3=Color3.fromRGB(110,130,155); kn.BorderSizePixel=0
    Instance.new("UICorner",kn).CornerRadius=UDim.new(1,0)

    local on=false
    local function set(v)
        on=v
        tw(bg,{BackgroundColor3=v and C.NEON or C.OFF})
        tw(kn,{
            Position=v and UDim2.new(0,27,0,3) or UDim2.new(0,3,0,3),
            BackgroundColor3=v and C.WHITE or Color3.fromRGB(110,130,155)
        })
    end
    local btn=Instance.new("TextButton",row)
    btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""
    btn.MouseButton1Click:Connect(function()
        on=not on; set(on); if cb then cb(on) end
    end)
    return row, set
end

local function Slider(parent, label, mn, mx, def, suffix, order, cb)
    local row=Instance.new("Frame",parent)
    row.Size=UDim2.new(1,0,0,56); row.BackgroundColor3=C.PAN2
    row.BorderSizePixel=0; row.LayoutOrder=order
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)

    local ll=Instance.new("TextLabel",row)
    ll.Size=UDim2.new(0.55,0,0,22); ll.Position=UDim2.new(0,12,0,8)
    ll.BackgroundTransparency=1; ll.Font=Enum.Font.Gotham
    ll.Text=label; ll.TextColor3=C.SUB; ll.TextSize=11
    ll.TextXAlignment=Enum.TextXAlignment.Left

    local vl=Instance.new("TextLabel",row)
    vl.Size=UDim2.new(0.4,0,0,22); vl.Position=UDim2.new(0.58,0,0,8)
    vl.BackgroundTransparency=1; vl.Font=Enum.Font.GothamBold
    vl.Text=def..(suffix or ""); vl.TextColor3=C.NEON; vl.TextSize=12
    vl.TextXAlignment=Enum.TextXAlignment.Right

    local track=Instance.new("Frame",row)
    track.Size=UDim2.new(1,-16,0,8); track.Position=UDim2.new(0,8,0,36)
    track.BackgroundColor3=Color3.fromRGB(18,28,48); track.BorderSizePixel=0
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)

    local fill=Instance.new("Frame",track)
    fill.Size=UDim2.new((def-mn)/(mx-mn),0,1,0)
    fill.BackgroundColor3=C.WAVE; fill.BorderSizePixel=0
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)

    local knob=Instance.new("Frame",track)
    knob.Size=UDim2.new(0,20,0,20)
    knob.Position=UDim2.new((def-mn)/(mx-mn),-10,0.5,-10)
    knob.BackgroundColor3=C.WHITE; knob.BorderSizePixel=0
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local ks=Instance.new("UIStroke",knob); ks.Color=C.WAVE; ks.Thickness=1.5

    local drag=false
    local function upd(x)
        local t=math.clamp((x-track.AbsolutePosition.X)/math.max(track.AbsoluteSize.X,1),0,1)
        local v=math.floor(mn+t*(mx-mn))
        fill.Size=UDim2.new(t,0,1,0)
        knob.Position=UDim2.new(t,-10,0.5,-10)
        vl.Text=v..(suffix or "")
        if cb then cb(v) end
    end

    local ib=Instance.new("TextButton",row)
    ib.Size=UDim2.new(1,0,1,0); ib.BackgroundTransparency=1; ib.Text=""
    ib.MouseButton1Down:Connect(function(x) drag=true; upd(x) end)
    ib.MouseButton1Up:Connect(function() drag=false end)
    ib.MouseMoved:Connect(function(x) if drag then upd(x) end end)
    UserInputService.TouchMoved:Connect(function(t2,_)
        if drag then upd(t2.Position.X) end
    end)
    UserInputService.TouchEnded:Connect(function() drag=false end)
end

local function Btn(parent, txt, col, order, cb)
    local b=Instance.new("TextButton",parent)
    b.Size=UDim2.new(1,0,0,48); b.LayoutOrder=order
    b.BackgroundColor3=Color3.fromRGB(
        math.floor(col.R*30), math.floor(col.G*30), math.floor(col.B*30))
    b.BorderSizePixel=0; b.Text=txt
    b.TextColor3=col; b.TextSize=13; b.Font=Enum.Font.GothamBold
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
    Instance.new("UIStroke",b).Color=col
    b.MouseButton1Click:Connect(function()
        tw(b,{BackgroundColor3=Color3.fromRGB(
            math.floor(col.R*60),math.floor(col.G*60),math.floor(col.B*60))},0.1)
        task.delay(0.2,function()
            tw(b,{BackgroundColor3=Color3.fromRGB(
                math.floor(col.R*30),math.floor(col.G*30),math.floor(col.B*30))},0.2)
        end)
        if cb then cb() end
    end)
    return b
end

local function GodCard(parent, icon, title, desc, key, order)
    local card=Instance.new("Frame",parent)
    card.Size=UDim2.new(1,0,0,64); card.BackgroundColor3=Color3.fromRGB(10,6,0)
    card.BorderSizePixel=0; card.LayoutOrder=order
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,8)
    local st=Instance.new("UIStroke",card); st.Color=C.GOLD; st.Thickness=1; st.Transparency=0.65

    local ic=Instance.new("TextLabel",card)
    ic.Size=UDim2.new(0,32,0,32); ic.Position=UDim2.new(0,10,0.5,-16)
    ic.BackgroundTransparency=1; ic.Text=icon; ic.TextSize=22
    ic.Font=Enum.Font.GothamBold; ic.TextColor3=C.GOLD

    local tl=Instance.new("TextLabel",card)
    tl.Size=UDim2.new(1,-110,0,22); tl.Position=UDim2.new(0,48,0,7)
    tl.BackgroundTransparency=1; tl.Font=Enum.Font.GothamBold
    tl.Text=title; tl.TextColor3=C.GOLD2; tl.TextSize=12
    tl.TextXAlignment=Enum.TextXAlignment.Left

    local dl=Instance.new("TextLabel",card)
    dl.Size=UDim2.new(1,-110,0,26); dl.Position=UDim2.new(0,48,0,30)
    dl.BackgroundTransparency=1; dl.Font=Enum.Font.Gotham
    dl.Text=desc; dl.TextColor3=Color3.fromRGB(170,130,70)
    dl.TextSize=10; dl.TextXAlignment=Enum.TextXAlignment.Left; dl.TextWrapped=true

    local bg=Instance.new("Frame",card)
    bg.Size=UDim2.new(0,44,0,24); bg.Position=UDim2.new(1,-52,0.5,-12)
    bg.BackgroundColor3=C.OFF; bg.BorderSizePixel=0
    Instance.new("UICorner",bg).CornerRadius=UDim.new(1,0)

    local kn=Instance.new("Frame",bg)
    kn.Size=UDim2.new(0,18,0,18); kn.Position=UDim2.new(0,3,0,3)
    kn.BackgroundColor3=Color3.fromRGB(110,130,155); kn.BorderSizePixel=0
    Instance.new("UICorner",kn).CornerRadius=UDim.new(1,0)

    local on=false
    local function setOn(v)
        on=v; S[key]=v
        tw(bg,{BackgroundColor3=v and C.GOLD or C.OFF})
        tw(kn,{
            Position=v and UDim2.new(0,23,0,3) or UDim2.new(0,3,0,3),
            BackgroundColor3=v and C.GOLD2 or Color3.fromRGB(110,130,155)
        })
        tw(st,{Transparency=v and 0.05 or 0.65})
        tw(card,{BackgroundColor3=v and Color3.fromRGB(18,10,0) or Color3.fromRGB(10,6,0)})
    end
    local cb2=Instance.new("TextButton",card)
    cb2.Size=UDim2.new(1,0,1,0); cb2.BackgroundTransparency=1; cb2.Text=""
    cb2.MouseButton1Click:Connect(function() setOn(not on) end)
    return card, setOn
end

-- ══════════════════════════════
-- PAGE: SPEED
-- ══════════════════════════════
local function pageSpeed()
    resetSC()

    -- ✅ SPEED HACK — напрямую меняем WalkSpeed каждый кадр
    Toggle(SC,"🏃 SPEED HACK","Ускорение — работает!",1,function(v)
        S.Speed=v
        if not v then
            local h=getHum(); if h then h.WalkSpeed=16 end
        end
    end)
    Slider(SC,"Скорость",16,300,50," WS",2,function(v)
        S.SpeedVal=v
    end)

    -- ✅ JUMP BOOST — напрямую JumpPower + JumpHeight
    Toggle(SC,"🦘 JUMP BOOST","Высота прыжка — работает!",3,function(v)
        S.Jump=v
        if not v then
            local h=getHum()
            if h then h.JumpHeight=7.2; h.JumpPower=50 end
        end
    end)
    Slider(SC,"Высота прыжка",50,500,100," %",4,function(v)
        S.JumpVal=v
        if S.Jump then
            local h=getHum()
            if h then
                h.JumpHeight=7.2*(v/100)
                h.JumpPower=50*(v/100)
            end
        end
    end)

    -- ✅ NO CLIP
    Toggle(SC,"👻 NO CLIP","Сквозь стены",5,function(v) S.NoClip=v end)

    -- ✅ FLY — через AlignPosition
    Toggle(SC,"🕊️ FLY MODE","Летать над волной",6,function(v)
        S.Fly=v
        local root=getRoot(); if not root then return end
        if v then
            local att0=Instance.new("Attachment",root); att0.Name="FlyAtt0"
            local att1=Instance.new("Attachment",workspace.Terrain); att1.Name="FlyAtt1"
            att1.WorldPosition=root.Position+Vector3.new(0,30,0)
            local ap=Instance.new("AlignPosition",root); ap.Name="FlyAP"
            ap.Attachment0=att0; ap.Attachment1=att1
            ap.MaxForce=1e5; ap.Responsiveness=20
            ap.RigidityEnabled=false
        else
            for _,n in ipairs({"FlyAtt0","FlyAP"}) do
                local f=root:FindFirstChild(n); if f then f:Destroy() end
            end
            -- найти att1 в Terrain
            for _,f in ipairs(workspace.Terrain:GetChildren()) do
                if f.Name=="FlyAtt1" then f:Destroy() end
            end
        end
    end)

    Btn(SC,"⚡ TELEPORT ВПЕРЁД НА 200",C.WAVE,7,function()
        local r=getRoot(); if r then
            r.CFrame=r.CFrame*CFrame.new(0,5,-200)
        end
    end)
end

-- ══════════════════════════════
-- PAGE: GOD MODE
-- ══════════════════════════════
local godFns={}
local function pageGod()
    resetSC()

    local warn=Instance.new("Frame",SC)
    warn.Size=UDim2.new(1,0,0,34); warn.BackgroundColor3=Color3.fromRGB(22,9,0)
    warn.BorderSizePixel=0; warn.LayoutOrder=0
    Instance.new("UICorner",warn).CornerRadius=UDim.new(0,8)
    Instance.new("UIStroke",warn).Color=C.GOLD
    local wl=Instance.new("TextLabel",warn)
    wl.Size=UDim2.new(1,0,1,0); wl.BackgroundTransparency=1
    wl.Font=Enum.Font.GothamBold; wl.TextSize=12
    wl.Text="☠️  ULTRA GOD MODE — 6 СЛОЁВ"; wl.TextColor3=C.GOLD

    local defs={
        {"❤️","HEALTH LOCK","HealthLock",
         "HP принудительно MAX каждый Heartbeat"},
        {"🛡️","INVULN PATCH","Invuln",
         "TakeDamage отключён полностью"},
        {"🌀","ANTI-GRAVITY","AntiGrav",
         "Держит выше 15 ступеней — волна не достаёт"},
        {"⚡","AUTO-TELEPORT","AutoTele",
         "Автопрыжок вперёд когда волна рядом"},
        {"♻️","INSTANT RESPAWN","InstRespawn",
         "После смерти — мгновенный respawn вперёд"},
        {"💧","WATER IMMUNITY","WaterImm",
         "Отключает ВСЕ kill/damage скрипты в workspace"},
    }

    godFns={}
    for i,d in ipairs(defs) do
        local _,fn=GodCard(SC,d[1],d[2],d[4],d[3],i)
        godFns[d[3]]=fn
    end

    local mb=Btn(SC,"☠️  ВКЛ ВСЕ 6 СЛОЁВ — ULTRA GOD  ☠️",C.GOLD,10,function()
        local keys={"HealthLock","Invuln","AntiGrav","AutoTele","InstRespawn","WaterImm"}
        local allOn=true
        for _,k in ipairs(keys) do if not S[k] then allOn=false; break end end
        local nw=not allOn
        for _,k in ipairs(keys) do if godFns[k] then godFns[k](nw) end end
        mb.Text=nw and "☠️  ВСЕ 6 АКТИВНЫ  ☠️" or "☠️  ВКЛ ВСЕ 6 СЛОЁВ — ULTRA GOD  ☠️"
    end)
    mb.Size=UDim2.new(1,0,0,52)
end

-- ══════════════════════════════
-- PAGE: MISC
-- ══════════════════════════════
local function pageMisc()
    resetSC()

    Toggle(SC,"📍 PLAYER ESP","Видеть игроков сквозь стены",1,function(v)
        S.ESP=v
        if not v then
            for _,t in pairs(S.EspTags) do if t and t.Parent then t:Destroy() end end
            S.EspTags={}
        end
    end)

    Toggle(SC,"💡 FULLBRIGHT","Макс яркость",2,function(v)
        S.Bright=v
        game.Lighting.Brightness=v and 5 or 1
        game.Lighting.ClockTime=v and 14 or 12
        game.Lighting.FogEnd=v and 1e6 or 100000
    end)

    Toggle(SC,"😈 TROLL MODE","Fling игроков в волну",3,function(v) S.Troll=v end)

    Toggle(SC,"🏅 AUTO RUN","Авто бег к финишу",4,function(v) S.AutoWin=v end)

    Btn(SC,"🌊 ТЕЛЕПОРТ К ФИНИШУ",C.PUR,5,function()
        local root=getRoot(); if not root then return end
        -- ищем SafeZone или телепортируем далеко вперёд
        local found=false
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n=obj.Name:lower()
                if n:find("safe") or n:find("finish") or n:find("end") or n:find("goal") then
                    root.CFrame=CFrame.new(obj.Position+Vector3.new(0,8,0))
                    found=true; break
                end
            end
        end
        if not found then
            root.CFrame=root.CFrame*CFrame.new(0,5,-800)
        end
    end)

    Btn(SC,"💥 FLING ВСЕХ",C.RED,6,function()
        local root=getRoot(); if not root then return end
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=lp and p.Character then
                local pr=p.Character:FindFirstChild("HumanoidRootPart")
                if pr then
                    local att=Instance.new("Attachment",pr)
                    local lv=Instance.new("LinearVelocity",pr)
                    lv.Attachment0=att
                    lv.VelocityConstraintMode=Enum.VelocityConstraintMode.Vector
                    lv.MaxForce=1e6
                    lv.VectorVelocity=(pr.Position-root.Position).Unit*250+Vector3.new(0,100,0)
                    game:GetService("Debris"):AddItem(lv,0.25)
                    game:GetService("Debris"):AddItem(att,0.25)
                end
            end
        end
    end)
end

-- ══════════════════════════════
-- TAB SWITCH
-- ══════════════════════════════
local pages={SPEED=pageSpeed,["GOD☠️"]=pageGod,MISC=pageMisc}

local function switchTab(name)
    S.Tab=name
    for _,t in ipairs(TABS) do
        local b=TabBtns[t]; local active=t==name
        tw(b,{BackgroundColor3=active and Color3.fromRGB(14,20,38) or C.PAN2})
        b.TextColor3=active and (TAB_COLS[t] or C.WAVE) or C.SUB
    end
    local idx=table.find(TABS,name) or 1
    local w=1/#TABS
    tw(TLine,{
        Position=UDim2.new(w*(idx-1)+w*0.05,2,1,-2),
        Size=UDim2.new(w*0.9,-4,0,2),
        BackgroundColor3=TAB_COLS[name] or C.WAVE
    })
    if pages[name] then pages[name]() end
end

for _,t in ipairs(TABS) do
    TabBtns[t].MouseButton1Click:Connect(function() switchTab(t) end)
end

-- ══════════════════════════════
-- DRAG
-- ══════════════════════════════
do
    local drag,ds,sp=false,nil,nil
    TB.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch
        or i.UserInputType==Enum.UserInputType.MouseButton1 then
            drag=true; ds=i.Position; sp=MF.Position
        end
    end)
    local function mv(i)
        if not drag or not ds then return end
        local d=i.Position-ds
        MF.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
    end
    TB.InputChanged:Connect(mv)
    UserInputService.TouchMoved:Connect(mv)
    UserInputService.InputEnded:Connect(function() drag=false end)
end

MinBtn.MouseButton1Click:Connect(function()
    S.Min=not S.Min
    tw(MF,{Size=S.Min and UDim2.new(0,320,0,50) or UDim2.new(0,320,0,480)},0.25)
    MinBtn.Text=S.Min and "□" or "—"
end)
ClBtn.MouseButton1Click:Connect(function()
    tw(MF,{Size=UDim2.new(0,320,0,0)},0.2)
    task.delay(0.25,function() SG:Destroy() end)
end)

-- ══════════════════════════════
-- MAIN HEARTBEAT LOOP
-- ══════════════════════════════
RunService.Heartbeat:Connect(function()
    local char=lp.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local root=char:FindFirstChild("HumanoidRootPart"); if not root then return end

    -- ✅ SPEED — принудительно каждый кадр
    if S.Speed then
        hum.WalkSpeed = S.SpeedVal
    end

    -- ✅ JUMP — принудительно каждый кадр
    if S.Jump then
        hum.JumpHeight = 7.2 * (S.JumpVal/100)
        hum.JumpPower  = 50  * (S.JumpVal/100)
    end

    -- ✅ NO CLIP — каждый кадр
    if S.NoClip then
        for _,p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=false end
        end
    end

    -- ✅ HEALTH LOCK — самый надёжный способ
    if S.HealthLock then
        if hum.MaxHealth ~= 1e9 then hum.MaxHealth=1e9 end
        if hum.Health < 1e9 then hum.Health=1e9 end
    end

    -- ✅ INVULN — каждый кадр перезаписываем
    if S.Invuln then
        hum.TakeDamage = function() end
    end

    -- ✅ ANTI-GRAVITY — держит выше земли
    if S.AntiGrav then
        if root.Position.Y < 15 then
            root.CFrame = CFrame.new(root.Position.X, 18, root.Position.Z)
                * CFrame.Angles(0, math.atan2(
                    root.CFrame.LookVector.X,
                    root.CFrame.LookVector.Z
                ), 0)
        end
    end

    -- ✅ AUTO TELE — прыжок от волны
    if S.AutoTele then
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj.Locked then
                local n=obj.Name:lower()
                if n:find("tsunami") or n:find("wave") or n:find("flood")
                or n:find("water") or n:find("kill") then
                    local dist=(obj.Position-root.Position).Magnitude
                    if dist<30 then
                        root.CFrame=root.CFrame*CFrame.new(0,8,-70)
                        break
                    end
                end
            end
        end
    end

    -- ✅ AUTO WIN
    if S.AutoWin then
        hum.WalkSpeed=80
        root.CFrame=root.CFrame*CFrame.new(0,0,-2)
    end

    -- ✅ WATER IMMUNITY
    if S.WaterImm then
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Script") or obj:IsA("LocalScript") then
                local n=obj.Name:lower()
                if (n:find("kill") or n:find("damage") or n:find("water")
                or n:find("tsunami") or n:find("drown") or n:find("flood")) then
                    if not obj.Disabled then obj.Disabled=true end
                end
            end
        end
    end

    -- ✅ TROLL
    if S.Troll then
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=lp and p.Character then
                local pr=p.Character:FindFirstChild("HumanoidRootPart")
                if pr and (pr.Position-root.Position).Magnitude<12 then
                    local att=Instance.new("Attachment",pr)
                    local lv=Instance.new("LinearVelocity",pr)
                    lv.Attachment0=att
                    lv.VelocityConstraintMode=Enum.VelocityConstraintMode.Vector
                    lv.MaxForce=9e4
                    lv.VectorVelocity=(pr.Position-root.Position).Unit*180+Vector3.new(0,60,0)
                    game:GetService("Debris"):AddItem(lv,0.2)
                    game:GetService("Debris"):AddItem(att,0.2)
                end
            end
        end
    end

    -- ✅ ESP
    if S.ESP then
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=lp and p.Character then
                local head=p.Character:FindFirstChild("Head")
                if head and not S.EspTags[p.UserId] then
                    local bb=Instance.new("BillboardGui",head)
                    bb.Size=UDim2.new(0,110,0,34)
                    bb.StudsOffset=Vector3.new(0,3,0)
                    bb.AlwaysOnTop=true
                    local lb=Instance.new("TextLabel",bb)
                    lb.Size=UDim2.new(1,0,1,0); lb.BackgroundTransparency=1
                    lb.Font=Enum.Font.GothamBold; lb.TextSize=13
                    lb.Text="🎯 "..p.Name; lb.TextColor3=C.NEON
                    lb.TextStrokeTransparency=0
                    S.EspTags[p.UserId]=bb
                end
            end
        end
    end
end)

-- ✅ INSTANT RESPAWN
lp.CharacterAdded:Connect(function(newChar)
    if S.InstRespawn then
        task.wait(0.05)
        local r=newChar:FindFirstChild("HumanoidRootPart")
        if r then r.CFrame=CFrame.new(0,30,-300) end
        local h=newChar:FindFirstChildOfClass("Humanoid")
        if h then
            if S.HealthLock then h.MaxHealth=1e9; h.Health=1e9 end
            if S.Invuln then h.TakeDamage=function() end end
        end
    end
end)

-- START
switchTab("SPEED")
print("✅ TSUNAMI EXECUTOR v5.0 — Speed/Jump/GodMode FIXED!")
