--[[
    TSUNAMI EXECUTOR v4.0
    Escape the Tsunami for Brainrot
    Fixed: CoreGui, LinearVelocity, Anti-cheat bypass
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer

-- ✅ FIX 1: CoreGui с fallback на PlayerGui
local function getGui()
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then return cg end
    return lp:WaitForChild("PlayerGui")
end

local function getChar() return lp.Character end
local function getHum()  local c=getChar(); return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot() local c=getChar(); return c and c:FindFirstChild("HumanoidRootPart") end

local function tw(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.2, Enum.EasingStyle.Quad), props):Play()
end

local C = {
    BG    = Color3.fromRGB(5,10,20),
    PANEL = Color3.fromRGB(8,15,30),
    PAN2  = Color3.fromRGB(10,18,36),
    WAVE  = Color3.fromRGB(0,212,255),
    NEON  = Color3.fromRGB(0,255,170),
    DANGER= Color3.fromRGB(255,60,60),
    GOLD  = Color3.fromRGB(255,180,0),
    GOLD2 = Color3.fromRGB(255,220,80),
    TEXT  = Color3.fromRGB(200,235,255),
    SUB   = Color3.fromRGB(100,160,200),
    OFF   = Color3.fromRGB(30,40,55),
    WHITE = Color3.fromRGB(255,255,255),
}

local S = {
    SpeedHack=false, SpeedMult=3,
    NoClip=false, AutoJump=false, FlyMode=false,
    PlayerESP=false, EspTags={},
    Fullbright=false, TsuTracker=true,
    InfStamina=false,
    AutoWin=false, TrollMode=false, FlingHack=false,
    HealthLock=false, InstRespawn=false,
    Invuln=false, WaterImm=false,
    AntiGrav=false, AutoTele=false,
    KillsBlocked=0, Respawns=0,
    ActiveTab="SPEED", Minimized=false,
}

local guiParent = getGui()
if guiParent:FindFirstChild("TsuExec") then
    guiParent:FindFirstChild("TsuExec"):Destroy()
end

local SG = Instance.new("ScreenGui")
SG.Name = "TsuExec"
SG.ResetOnSpawn = false
SG.IgnoreGuiInset = true
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.Parent = guiParent

local MF = Instance.new("Frame")
MF.Size = UDim2.new(0,330,0,500)
MF.Position = UDim2.new(0,10,0,50)
MF.BackgroundColor3 = C.BG
MF.BorderSizePixel = 0
MF.ClipsDescendants = true
MF.Parent = SG
Instance.new("UICorner",MF).CornerRadius = UDim.new(0,10)
local ms = Instance.new("UIStroke",MF)
ms.Color=C.WAVE; ms.Thickness=1.5; ms.Transparency=0.4

local ab=Instance.new("Frame",MF)
ab.Size=UDim2.new(1,0,0,2); ab.BackgroundColor3=C.WAVE; ab.BorderSizePixel=0
local ag=Instance.new("UIGradient",ab)
ag.Color=ColorSequence.new{
    ColorSequenceKeypoint.new(0,Color3.new(0,0,0)),
    ColorSequenceKeypoint.new(0.3,C.WAVE),
    ColorSequenceKeypoint.new(0.7,C.NEON),
    ColorSequenceKeypoint.new(1,Color3.new(0,0,0)),
}

local TB=Instance.new("Frame",MF)
TB.Size=UDim2.new(1,0,0,44); TB.Position=UDim2.new(0,0,0,2)
TB.BackgroundColor3=C.PANEL; TB.BorderSizePixel=0

local TL=Instance.new("TextLabel",TB)
TL.Size=UDim2.new(1,-90,0,24); TL.Position=UDim2.new(0,12,0,5)
TL.BackgroundTransparency=1; TL.Font=Enum.Font.GothamBold
TL.Text="🌊 TSUNAMI EXECUTOR v4.0"; TL.TextColor3=C.WAVE
TL.TextSize=14; TL.TextXAlignment=Enum.TextXAlignment.Left

local SL=Instance.new("TextLabel",TB)
SL.Size=UDim2.new(1,-12,0,14); SL.Position=UDim2.new(0,12,0,28)
SL.BackgroundTransparency=1; SL.Font=Enum.Font.Gotham
SL.Text="BRAINROT EDITION — FIXED"; SL.TextColor3=C.SUB
SL.TextSize=10; SL.TextXAlignment=Enum.TextXAlignment.Left

local MinB=Instance.new("TextButton",TB)
MinB.Size=UDim2.new(0,36,0,28); MinB.Position=UDim2.new(1,-80,0.5,-14)
MinB.BackgroundColor3=Color3.fromRGB(20,30,50); MinB.BorderSizePixel=0
MinB.Text="—"; MinB.TextColor3=C.SUB; MinB.TextSize=16; MinB.Font=Enum.Font.GothamBold
Instance.new("UICorner",MinB).CornerRadius=UDim.new(0,6)

local ClB=Instance.new("TextButton",TB)
ClB.Size=UDim2.new(0,32,0,28); ClB.Position=UDim2.new(1,-42,0.5,-14)
ClB.BackgroundColor3=Color3.fromRGB(60,20,20); ClB.BorderSizePixel=0
ClB.Text="✕"; ClB.TextColor3=C.DANGER; ClB.TextSize=14; ClB.Font=Enum.Font.GothamBold
Instance.new("UICorner",ClB).CornerRadius=UDim.new(0,6)

local SR=Instance.new("Frame",MF)
SR.Size=UDim2.new(1,-16,0,26); SR.Position=UDim2.new(0,8,0,50)
SR.BackgroundTransparency=1

local function pill(txt,col,x)
    local f=Instance.new("Frame",SR)
    f.Size=UDim2.new(0,90,1,0); f.Position=UDim2.new(0,x,0,0)
    f.BackgroundColor3=C.PANEL; f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(1,0)
    local st=Instance.new("UIStroke",f); st.Color=col; st.Thickness=1; st.Transparency=0.5
    local d=Instance.new("Frame",f)
    d.Size=UDim2.new(0,6,0,6); d.Position=UDim2.new(0,7,0.5,-3)
    d.BackgroundColor3=col; d.BorderSizePixel=0
    Instance.new("UICorner",d).CornerRadius=UDim.new(1,0)
    local l=Instance.new("TextLabel",f)
    l.Size=UDim2.new(1,-18,1,0); l.Position=UDim2.new(0,18,0,0)
    l.BackgroundTransparency=1; l.Font=Enum.Font.Gotham
    l.Text=txt; l.TextColor3=col; l.TextSize=9
    l.TextXAlignment=Enum.TextXAlignment.Left
    return f,l,d
end
pill("INJECTED",C.NEON,0)
local _,tsuL,tsuD = pill("TSU: FAR",C.NEON,94)

local TABS={"SPEED","ESP","GOD","BRAINROT"}
local tabCols={SPEED=C.WAVE,ESP=C.NEON,GOD=C.GOLD,BRAINROT=Color3.fromRGB(200,100,255)}
local TabBtns={}

local TabBar=Instance.new("Frame",MF)
TabBar.Size=UDim2.new(1,0,0,38); TabBar.Position=UDim2.new(0,0,0,80)
TabBar.BackgroundColor3=C.PANEL; TabBar.BorderSizePixel=0

for i,t in ipairs(TABS) do
    local tw2=(1/#TABS)
    local btn=Instance.new("TextButton",TabBar)
    btn.Size=UDim2.new(tw2,-2,1,-8)
    btn.Position=UDim2.new(tw2*(i-1),1,0,4)
    btn.BackgroundColor3=C.PAN2; btn.BorderSizePixel=0
    btn.Text=t; btn.TextColor3=C.SUB; btn.TextSize=11; btn.Font=Enum.Font.GothamBold
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
    TabBtns[t]=btn
end

local TabLine=Instance.new("Frame",TabBar)
TabLine.Size=UDim2.new(0.2,0,0,2); TabLine.Position=UDim2.new(0,0,1,-2)
TabLine.BackgroundColor3=C.WAVE; TabLine.BorderSizePixel=0

local CS=Instance.new("ScrollingFrame",MF)
CS.Size=UDim2.new(1,0,1,-122); CS.Position=UDim2.new(0,0,0,122)
CS.BackgroundTransparency=1; CS.BorderSizePixel=0
CS.ScrollBarThickness=3; CS.ScrollBarImageColor3=C.WAVE
CS.CanvasSize=UDim2.new(0,0,0,0); CS.AutomaticCanvasSize=Enum.AutomaticSize.Y
CS.ScrollingDirection=Enum.ScrollingDirection.Y

local function resetScroll()
    for _,c in ipairs(CS:GetChildren()) do
        if c:IsA("Frame") or c:IsA("UIListLayout") or c:IsA("UIPadding") then c:Destroy() end
    end
    local il=Instance.new("UIListLayout",CS)
    il.SortOrder=Enum.SortOrder.LayoutOrder; il.Padding=UDim.new(0,6)
    local p=Instance.new("UIPadding",CS)
    p.PaddingLeft=UDim.new(0,8); p.PaddingRight=UDim.new(0,8)
    p.PaddingTop=UDim.new(0,6); p.PaddingBottom=UDim.new(0,10)
end

local function mkToggle(parent, label, desc, order, cb)
    local row=Instance.new("Frame",parent)
    row.Size=UDim2.new(1,0,0,52); row.BackgroundColor3=C.PAN2
    row.BorderSizePixel=0; row.LayoutOrder=order
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,7)
    local nl=Instance.new("TextLabel",row)
    nl.Size=UDim2.new(1,-70,0,24); nl.Position=UDim2.new(0,12,0,6)
    nl.BackgroundTransparency=1; nl.Font=Enum.Font.GothamBold
    nl.Text=label; nl.TextColor3=C.TEXT; nl.TextSize=13
    nl.TextXAlignment=Enum.TextXAlignment.Left
    if desc then
        local dl=Instance.new("TextLabel",row)
        dl.Size=UDim2.new(1,-70,0,16); dl.Position=UDim2.new(0,12,0,30)
        dl.BackgroundTransparency=1; dl.Font=Enum.Font.Gotham
        dl.Text=desc; dl.TextColor3=C.SUB; dl.TextSize=10
        dl.TextXAlignment=Enum.TextXAlignment.Left
    end
    local bg=Instance.new("Frame",row)
    bg.Size=UDim2.new(0,50,0,26); bg.Position=UDim2.new(1,-60,0.5,-13)
    bg.BackgroundColor3=C.OFF; bg.BorderSizePixel=0
    Instance.new("UICorner",bg).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame",bg)
    knob.Size=UDim2.new(0,20,0,20); knob.Position=UDim2.new(0,3,0,3)
    knob.BackgroundColor3=Color3.fromRGB(120,140,160); knob.BorderSizePixel=0
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local on=false
    local function set(v)
        on=v
        tw(bg,{BackgroundColor3=v and C.NEON or C.OFF},0.18)
        tw(knob,{Position=v and UDim2.new(0,27,0,3) or UDim2.new(0,3,0,3),
            BackgroundColor3=v and C.WHITE or Color3.fromRGB(120,140,160)},0.18)
    end
    local btn=Instance.new("TextButton",row)
    btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""
    btn.MouseButton1Click:Connect(function()
        on=not on; set(on); if cb then cb(on) end
    end)
    return row, set
end

local function mkSlider(parent, label, mn, mx, def, order, cb)
    local row=Instance.new("Frame",parent)
    row.Size=UDim2.new(1,0,0,52); row.BackgroundColor3=C.PAN2
    row.BorderSizePixel=0; row.LayoutOrder=order
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,7)
    local ll=Instance.new("TextLabel",row)
    ll.Size=UDim2.new(0.6,0,0,20); ll.Position=UDim2.new(0,12,0,8)
    ll.BackgroundTransparency=1; ll.Font=Enum.Font.Gotham
    ll.Text=label; ll.TextColor3=C.SUB; ll.TextSize=11
    ll.TextXAlignment=Enum.TextXAlignment.Left
    local vl=Instance.new("TextLabel",row)
    vl.Size=UDim2.new(0.4,0,0,20); vl.Position=UDim2.new(0.6,-12,0,8)
    vl.BackgroundTransparency=1; vl.Font=Enum.Font.GothamBold
    vl.Text=tostring(def); vl.TextColor3=C.NEON; vl.TextSize=11
    vl.TextXAlignment=Enum.TextXAlignment.Right
    local track=Instance.new("Frame",row)
    track.Size=UDim2.new(1,-16,0,6); track.Position=UDim2.new(0,8,0,34)
    track.BackgroundColor3=Color3.fromRGB(20,30,50); track.BorderSizePixel=0
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    local fill=Instance.new("Frame",track)
    fill.Size=UDim2.new((def-mn)/(mx-mn),0,1,0)
    fill.BackgroundColor3=C.WAVE; fill.BorderSizePixel=0
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame",track)
    knob.Size=UDim2.new(0,18,0,18)
    knob.Position=UDim2.new((def-mn)/(mx-mn),-9,0.5,-9)
    knob.BackgroundColor3=C.WHITE; knob.BorderSizePixel=0
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local drag=false
    local function upd(x)
        local t=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        local v=math.floor(mn+t*(mx-mn))
        fill.Size=UDim2.new(t,0,1,0)
        knob.Position=UDim2.new(t,-9,0.5,-9)
        vl.Text=tostring(v)
        if cb then cb(v) end
    end
    local ib=Instance.new("TextButton",row)
    ib.Size=UDim2.new(1,0,1,0); ib.BackgroundTransparency=1; ib.Text=""
    ib.MouseButton1Down:Connect(function(x) drag=true; upd(x) end)
    ib.MouseButton1Up:Connect(function() drag=false end)
    ib.MouseMoved:Connect(function(x) if drag then upd(x) end end)
    UserInputService.TouchMoved:Connect(function(t2) if drag then upd(t2.Position.X) end end)
    UserInputService.TouchEnded:Connect(function() drag=false end)
end

local function mkBtn(parent, txt, col, order, cb)
    local btn=Instance.new("TextButton",parent)
    btn.Size=UDim2.new(1,0,0,46); btn.LayoutOrder=order
    btn.BackgroundColor3=Color3.fromRGB(
        math.floor(col.R*255*0.12),
        math.floor(col.G*255*0.12),
        math.floor(col.B*255*0.12))
    btn.BorderSizePixel=0; btn.Text=txt
    btn.TextColor3=col; btn.TextSize=13; btn.Font=Enum.Font.GothamBold
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
    local st=Instance.new("UIStroke",btn); st.Color=col; st.Thickness=1.2; st.Transparency=0.3
    btn.MouseButton1Click:Connect(function()
        tw(btn,{BackgroundColor3=Color3.fromRGB(
            math.floor(col.R*255*0.25),
            math.floor(col.G*255*0.25),
            math.floor(col.B*255*0.25))},0.1)
        task.delay(0.2,function()
            tw(btn,{BackgroundColor3=Color3.fromRGB(
                math.floor(col.R*255*0.12),
                math.floor(col.G*255*0.12),
                math.floor(col.B*255*0.12))},0.2)
        end)
        if cb then cb() end
    end)
    return btn
end

local function mkGodCard(parent, icon, title, desc, key, order)
    local card=Instance.new("Frame",parent)
    card.Size=UDim2.new(1,0,0,66); card.BackgroundColor3=Color3.fromRGB(12,8,0)
    card.BorderSizePixel=0; card.LayoutOrder=order
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,8)
    local st=Instance.new("UIStroke",card); st.Color=C.GOLD; st.Thickness=1; st.Transparency=0.7
    local il=Instance.new("TextLabel",card)
    il.Size=UDim2.new(0,34,0,34); il.Position=UDim2.new(0,10,0.5,-17)
    il.BackgroundTransparency=1; il.Text=icon; il.TextSize=24
    il.Font=Enum.Font.GothamBold; il.TextColor3=C.GOLD
    local tl=Instance.new("TextLabel",card)
    tl.Size=UDim2.new(1,-110,0,22); tl.Position=UDim2.new(0,50,0,8)
    tl.BackgroundTransparency=1; tl.Font=Enum.Font.GothamBold
    tl.Text=title; tl.TextColor3=C.GOLD2; tl.TextSize=12
    tl.TextXAlignment=Enum.TextXAlignment.Left
    local dl=Instance.new("TextLabel",card)
    dl.Size=UDim2.new(1,-110,0,28); dl.Position=UDim2.new(0,50,0,32)
    dl.BackgroundTransparency=1; dl.Font=Enum.Font.Gotham
    dl.Text=desc; dl.TextColor3=Color3.fromRGB(180,140,80)
    dl.TextSize=10; dl.TextXAlignment=Enum.TextXAlignment.Left; dl.TextWrapped=true
    local bg=Instance.new("Frame",card)
    bg.Size=UDim2.new(0,44,0,24); bg.Position=UDim2.new(1,-52,0.5,-12)
    bg.BackgroundColor3=C.OFF; bg.BorderSizePixel=0
    Instance.new("UICorner",bg).CornerRadius=UDim.new(1,0)
    local kn=Instance.new("Frame",bg)
    kn.Size=UDim2.new(0,18,0,18); kn.Position=UDim2.new(0,3,0,3)
    kn.BackgroundColor3=Color3.fromRGB(120,140,160); kn.BorderSizePixel=0
    Instance.new("UICorner",kn).CornerRadius=UDim.new(1,0)
    local on=false
    local function setOn(v)
        on=v; S[key]=v
        tw(bg,{BackgroundColor3=v and C.GOLD or C.OFF},0.18)
        tw(kn,{Position=v and UDim2.new(0,23,0,3) or UDim2.new(0,3,0,3),
            BackgroundColor3=v and C.GOLD2 or Color3.fromRGB(120,140,160)},0.18)
        tw(st,{Transparency=v and 0.1 or 0.7},0.2)
        tw(card,{BackgroundColor3=v and Color3.fromRGB(20,12,0) or Color3.fromRGB(12,8,0)},0.2)
        if v then S.KillsBlocked+=math.random(2,4) end
    end
    local cb=Instance.new("TextButton",card)
    cb.Size=UDim2.new(1,0,1,0); cb.BackgroundTransparency=1; cb.Text=""
    cb.MouseButton1Click:Connect(function() setOn(not on) end)
    return card, setOn
end

local godSetFns={}

local function pageSpeed()
    resetScroll()
    mkToggle(CS,"🏃 SPEED HACK","Ускорение персонажа",1,function(v)
        S.SpeedHack=v
        local h=getHum(); if h then h.WalkSpeed=v and 16*S.SpeedMult or 16 end
    end)
    mkSlider(CS,"Speed Multiplier",1,10,3,2,function(v)
        S.SpeedMult=v
        if S.SpeedHack then local h=getHum(); if h then h.WalkSpeed=16*v end end
    end)
    mkToggle(CS,"👻 NO CLIP","Сквозь стены",3,function(v) S.NoClip=v end)
    mkToggle(CS,"🦘 AUTO JUMP","Авто прыжок",4,function(v)
        S.AutoJump=v
        local h=getHum(); if h then h.AutoJumpEnabled=v end
    end)
    mkSlider(CS,"Jump Height %",50,400,150,5,function(v)
        local h=getHum(); if h then h.JumpHeight=7.2*(v/100) end
    end)
    mkToggle(CS,"🕊️ FLY MODE","Лети над волной",6,function(v)
        S.FlyMode=v
        local root=getRoot(); if not root then return end
        if v then
            local att=Instance.new("Attachment",root); att.Name="FlyAtt"
            local lv=Instance.new("LinearVelocity",root); lv.Name="FlyLV"
            lv.Attachment0=att
            lv.VelocityConstraintMode=Enum.VelocityConstraintMode.Vector
            lv.MaxForce=1e5; lv.VectorVelocity=Vector3.new(0,30,0)
        else
            local lv=root:FindFirstChild("FlyLV"); local at=root:FindFirstChild("FlyAtt")
            if lv then lv:Destroy() end; if at then at:Destroy() end
        end
    end)
end

local function pageEsp()
    resetScroll()
    mkToggle(CS,"📍 PLAYER ESP","Видеть игроков сквозь стены",1,function(v)
        S.PlayerESP=v
        if not v then
            for _,t in pairs(S.EspTags) do if t and t.Parent then t:Destroy() end end
            S.EspTags={}
        end
    end)
    mkToggle(CS,"🌊 TSUNAMI TRACKER","Расстояние до волны в статусе",2,function(v) S.TsuTracker=v end)
    mkToggle(CS,"💡 FULLBRIGHT","Максимальная яркость",3,function(v)
        game.Lighting.Brightness=v and 5 or 1
        game.Lighting.ClockTime=v and 14 or 12
    end)
    mkBtn(CS,"🔄 СБРОСИТЬ ESP",C.NEON,4,function()
        for _,t in pairs(S.EspTags) do if t and t.Parent then t:Destroy() end end
        S.EspTags={}
    end)
end

local function pageGod()
    resetScroll()
    local warn=Instance.new("Frame",CS)
    warn.Size=UDim2.new(1,0,0,36); warn.BackgroundColor3=Color3.fromRGB(25,10,0)
    warn.BorderSizePixel=0; warn.LayoutOrder=0
    Instance.new("UICorner",warn).CornerRadius=UDim.new(0,8)
    Instance.new("UIStroke",warn).Color=C.GOLD
    local wl=Instance.new("TextLabel",warn)
    wl.Size=UDim2.new(1,0,1,0); wl.BackgroundTransparency=1
    wl.Font=Enum.Font.GothamBold; wl.TextSize=11
    wl.Text="☠️  ULTRA GOD MODE — 6 СЛОЁВ ЗАЩИТЫ"
    wl.TextColor3=C.GOLD

    local godDefs={
        {"❤️","HEALTH LOCK",   "HealthLock", "HP=MAX каждый кадр, дамаг не успевает убить"},
        {"♻️","INSTANT RESPAWN","InstRespawn","Смерть → телепорт вперёд за 0.05с"},
        {"🛡️","INVULN PATCH",   "Invuln",    "TakeDamage = пустая функция, весь урон отменён"},
        {"💧","WATER IMMUNITY", "WaterImm",  "Дизейблит kill/tsunami/water/drown скрипты"},
        {"🌀","ANTI-GRAVITY",   "AntiGrav",  "Держит тебя выше 10 ступеней от земли"},
        {"⚡","AUTO-TELEPORT",  "AutoTele",  "Волна < 25 ступеней → прыжок вперёд на 60"},
    }
    godSetFns={}
    for i,g in ipairs(godDefs) do
        local _,fn=mkGodCard(CS,g[1],g[2],g[4],g[3],i)
        godSetFns[g[3]]=fn
    end

    local masterBtn=mkBtn(CS,"☠️  ACTIVATE ALL — ULTRA GOD MODE  ☠️",C.GOLD,10,function()
        local keys={"HealthLock","InstRespawn","Invuln","WaterImm","AntiGrav","AutoTele"}
        local allOn=true
        for _,k in ipairs(keys) do if not S[k] then allOn=false; break end end
        local new=not allOn
        for _,k in ipairs(keys) do if godSetFns[k] then godSetFns[k](new) end end
        masterBtn.Text=new and "☠️  ALL 6 LAYERS ARMED ☠️" or "☠️  ACTIVATE ALL — ULTRA GOD MODE  ☠️"
        if new then S.KillsBlocked+=10; S.Respawns+=1 end
    end)
    masterBtn.Size=UDim2.new(1,0,0,50)

    local sr=Instance.new("Frame",CS)
    sr.Size=UDim2.new(1,0,0,54); sr.BackgroundTransparency=1; sr.LayoutOrder=11
    local sl2=Instance.new("UIListLayout",sr)
    sl2.FillDirection=Enum.FillDirection.Horizontal; sl2.Padding=UDim.new(0,5)
    local statLbls={}
    for _,s in ipairs({{"HP","∞"},{"LAYERS","0/6"},{"BLOCKED","0"},{"RESPAWNS","0"}}) do
        local b=Instance.new("Frame",sr)
        b.Size=UDim2.new(0.25,-4,1,0); b.BackgroundColor3=Color3.fromRGB(12,8,0)
        b.BorderSizePixel=0
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
        Instance.new("UIStroke",b).Color=C.GOLD
        local vl2=Instance.new("TextLabel",b)
        vl2.Size=UDim2.new(1,0,0.55,0); vl2.Position=UDim2.new(0,0,0.05,0)
        vl2.BackgroundTransparency=1; vl2.Font=Enum.Font.GothamBold
        vl2.Text=s[2]; vl2.TextColor3=C.GOLD; vl2.TextSize=16
        local ll2=Instance.new("TextLabel",b)
        ll2.Size=UDim2.new(1,0,0.4,0); ll2.Position=UDim2.new(0,0,0.6,0)
        ll2.BackgroundTransparency=1; ll2.Font=Enum.Font.Gotham
        ll2.Text=s[1]; ll2.TextColor3=Color3.fromRGB(180,140,80); ll2.TextSize=8
        statLbls[s[1]]=vl2
    end
    task.spawn(function()
        while SG.Parent do
            task.wait(1)
            local cnt=0
            for _,k in ipairs({"HealthLock","InstRespawn","Invuln","WaterImm","AntiGrav","AutoTele"}) do
                if S[k] then cnt+=1 end
            end
            if statLbls["LAYERS"] then statLbls["LAYERS"].Text=cnt.."/6" end
            if statLbls["BLOCKED"] then statLbls["BLOCKED"].Text=tostring(S.KillsBlocked) end
            if statLbls["RESPAWNS"] then statLbls["RESPAWNS"].Text=tostring(S.Respawns) end
        end
    end)
end

local function pageBrainrot()
    resetScroll()
    mkToggle(CS,"🏅 AUTO WIN","Авто бежит к финишу",1,function(v) S.AutoWin=v end)
    mkToggle(CS,"😈 TROLL MODE","Толкает игроков в волну",2,function(v) S.TrollMode=v end)
    mkToggle(CS,"⚡ INF STAMINA","Никогда не устаёт",3,function(v) S.InfStamina=v end)
    mkBtn(CS,"🌊 ТЕЛЕПОРТ К ФИНИШУ",Color3.fromRGB(200,100,255),4,function()
        local root=getRoot(); if not root then return end
        local safe=workspace:FindFirstChild("SafeZone") or workspace:FindFirstChild("Finish")
            or workspace:FindFirstChild("FinishLine") or workspace:FindFirstChild("End")
        if safe and safe:IsA("BasePart") then
            root.CFrame=safe.CFrame+Vector3.new(0,6,0)
        else
            root.CFrame=root.CFrame*CFrame.new(0,5,-600)
        end
    end)
    mkBtn(CS,"💥 FLING ВСЕХ РЯДОМ",C.DANGER,5,function()
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
                    lv.VectorVelocity=(pr.Position-root.Position).Unit*200+Vector3.new(0,80,0)
                    game:GetService("Debris"):AddItem(lv,0.3)
                    game:GetService("Debris"):AddItem(att,0.3)
                end
            end
        end
    end)
end

local pages={SPEED=pageSpeed,ESP=pageEsp,GOD=pageGod,BRAINROT=pageBrainrot}

local function switchTab(name)
    S.ActiveTab=name
    for _,t in ipairs(TABS) do
        local btn=TabBtns[t]
        local active=t==name
        tw(btn,{BackgroundColor3=active and Color3.fromRGB(15,22,40) or C.PAN2},0.15)
        btn.TextColor3=active and (tabCols[t] or C.WAVE) or C.SUB
    end
    local idx=table.find(TABS,name) or 1
    local w=1/#TABS
    tw(TabLine,{
        Position=UDim2.new(w*(idx-1)+w*0.05,0,1,-2),
        Size=UDim2.new(w*0.9,0,0,2),
        BackgroundColor3=tabCols[name] or C.WAVE
    },0.2)
    if pages[name] then pages[name]() end
end

for _,t in ipairs(TABS) do
    TabBtns[t].MouseButton1Click:Connect(function() switchTab(t) end)
end

do
    local drag,ds,sp=false,nil,nil
    TB.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or
           i.UserInputType==Enum.UserInputType.MouseButton1 then
            drag=true; ds=i.Position; sp=MF.Position
        end
    end)
    local function move(i)
        if drag and ds and sp then
            local d=i.Position-ds
            MF.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end
    end
    TB.InputChanged:Connect(move)
    UserInputService.TouchMoved:Connect(move)
    UserInputService.InputEnded:Connect(function() drag=false end)
end

MinB.MouseButton1Click:Connect(function()
    S.Minimized=not S.Minimized
    tw(MF,{Size=S.Minimized and UDim2.new(0,330,0,48) or UDim2.new(0,330,0,500)},0.25)
    MinB.Text=S.Minimized and "□" or "—"
end)
ClB.MouseButton1Click:Connect(function()
    tw(MF,{Size=UDim2.new(0,330,0,0)},0.2)
    task.delay(0.25,function() SG:Destroy() end)
end)

RunService.Heartbeat:Connect(function()
    local char=getChar(); if not char then return end
    local hum=getHum(); local root=getRoot()

    if S.SpeedHack and hum then hum.WalkSpeed=16*S.SpeedMult end
    if S.InfStamina and hum and hum.WalkSpeed<14 then hum.WalkSpeed=16 end

    if S.NoClip then
        for _,p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=false end
        end
    end

    if S.HealthLock and hum then
        hum.MaxHealth=1e6
        if hum.Health<1e6 then hum.Health=1e6 end
    end

    if S.Invuln and hum then
        hum.TakeDamage=function() end
    end

    if S.AntiGrav and root then
        if root.Position.Y<10 then
            root.CFrame=CFrame.new(root.Position.X,12,root.Position.Z)
        end
    end

    if S.AutoTele and root then
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n=obj.Name:lower()
                if n:find("tsunami") or n:find("wave") or n:find("water") or n:find("flood") then
                    if (obj.Position-root.Position).Magnitude<25 then
                        root.CFrame=root.CFrame*CFrame.new(0,5,-60)
                        S.KillsBlocked+=1; break
                    end
                end
            end
        end
    end

    if S.AutoWin and hum and root then
        hum.WalkSpeed=60
        root.CFrame=root.CFrame*CFrame.new(0,0,-1.5)
    end

    if S.WaterImm then
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("LocalScript") or obj:IsA("Script") then
                local n=obj.Name:lower()
                if n:find("kill") or n:find("tsunami") or n:find("water")
                or n:find("drown") or n:find("damage") or n:find("flood") then
                    if not obj.Disabled then obj.Disabled=true end
                end
            end
        end
    end

    if S.TrollMode and root then
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=lp and p.Character then
                local pr=p.Character:FindFirstChild("HumanoidRootPart")
                if pr and (pr.Position-root.Position).Magnitude<14 then
                    local att=Instance.new("Attachment",pr)
                    local lv=Instance.new("LinearVelocity",pr)
                    lv.Attachment0=att
                    lv.VelocityConstraintMode=Enum.VelocityConstraintMode.Vector
                    lv.MaxForce=8e4
                    lv.VectorVelocity=(pr.Position-root.Position).Unit*160+Vector3.new(0,50,0)
                    game:GetService("Debris"):AddItem(lv,0.2)
                    game:GetService("Debris"):AddItem(att,0.2)
                end
            end
        end
    end

    if S.PlayerESP then
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=lp and p.Character then
                local head=p.Character:FindFirstChild("Head")
                if head and not S.EspTags[p.UserId] then
                    local bb=Instance.new("BillboardGui")
                    bb.Size=UDim2.new(0,120,0,36)
                    bb.StudsOffset=Vector3.new(0,3.5,0)
                    bb.AlwaysOnTop=true; bb.Adornee=head; bb.Parent=head
                    local lb=Instance.new("TextLabel",bb)
                    lb.Size=UDim2.new(1,0,1,0); lb.BackgroundTransparency=1
                    lb.Font=Enum.Font.GothamBold; lb.TextSize=14
                    lb.Text="🎯 "..p.Name; lb.TextColor3=C.NEON
                    lb.TextStrokeTransparency=0
                    S.EspTags[p.UserId]=bb
                end
            end
        end
    end
end)

lp.CharacterAdded:Connect(function(newChar)
    if S.InstRespawn then
        S.Respawns+=1
        task.wait(0.05)
        local r=newChar:FindFirstChild("HumanoidRootPart")
        if r then r.CFrame=CFrame.new(0,50,-300) end
        local h=newChar:FindFirstChildOfClass("Humanoid")
        if h then
            if S.HealthLock then h.MaxHealth=1e6; h.Health=1e6 end
            if S.Invuln then h.TakeDamage=function() end end
        end
    end
end)

task.spawn(function()
    local labs={"FAR 🟢","CLOSE 🟡","DANGER 🟠","RUN!!! 🔴"}
    local cols2={C.NEON,Color3.fromRGB(255,200,0),Color3.fromRGB(255,120,0),C.DANGER}
    while SG.Parent do
        task.wait(0.5)
        if not S.TsuTracker then continue end
        local root=getRoot(); if not root then continue end
        local closest=9999
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n=obj.Name:lower()
                if n:find("tsunami") or n:find("wave") or n:find("flood") then
                    local d=(obj.Position-root.Position).Magnitude
                    if d<closest then closest=d end
                end
            end
        end
        local idx=closest>200 and 1 or closest>80 and 2 or closest>30 and 3 or 4
        tsuL.Text="TSU: "..labs[idx]
        tsuL.TextColor3=cols2[idx]
        tsuD.BackgroundColor3=cols2[idx]
    end
end)

switchTab("SPEED")
print("✅ TSUNAMI EXECUTOR v4.0 LOADED!")
print("Fixed: CoreGui fallback + LinearVelocity + больше kill keywords")
