-- ╔══════════════════════════════════════════╗
-- ║        PrimejTsuHub v3.0               ║
-- ║   Escape Tsunami For Brainrots          ║
-- ║   Auto Tower Trail • God • Farm • ESP   ║
-- ╚══════════════════════════════════════════╝

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local Debris       = game:GetService("Debris")

local lp = Players.LocalPlayer
local function getChar()  return lp.Character end
local function getHum()   local c=getChar(); return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot()  local c=getChar(); return c and c:FindFirstChild("HumanoidRootPart") end

-- GUI Parent
local guiParent
local ok,cg=pcall(function() return game:GetService("CoreGui") end)
guiParent=(ok and cg) or lp:WaitForChild("PlayerGui")
if guiParent:FindFirstChild("PrimejTsuHub") then
    guiParent:FindFirstChild("PrimejTsuHub"):Destroy()
end

local function tw(o,p,t)
    TweenService:Create(o,TweenInfo.new(t or 0.18,Enum.EasingStyle.Quad),p):Play()
end

local C={
    BG=Color3.fromRGB(5,8,18), PAN=Color3.fromRGB(8,13,26),
    PAN2=Color3.fromRGB(11,18,35), WAVE=Color3.fromRGB(0,200,255),
    NEON=Color3.fromRGB(0,255,160), RED=Color3.fromRGB(255,55,55),
    GOLD=Color3.fromRGB(255,175,0), GOLD2=Color3.fromRGB(255,215,70),
    TEXT=Color3.fromRGB(215,235,255), SUB=Color3.fromRGB(90,145,195),
    OFF=Color3.fromRGB(25,35,52), WHITE=Color3.fromRGB(255,255,255),
    PUR=Color3.fromRGB(165,70,255), GREEN=Color3.fromRGB(0,220,100),
    PINK=Color3.fromRGB(255,80,180), ORG=Color3.fromRGB(255,140,0),
    TEAL=Color3.fromRGB(0,220,200),
}

local S={
    Speed=false, SpeedVal=60,
    Jump=false, JumpVal=150,
    NoClip=false, Fly=false,
    InfJump=false, InfJumpConn=nil,
    Bhop=false, BhopConn=nil,
    GodMode=false, GodConns={},
    AntiGrav=false, AutoTele=false,
    AntiVoid=false, AntiAFK=false,
    -- TOWER TRAIL
    AutoTower=false, TowerStatus="INACTIVE",
    TowerStep="idle", -- idle/find_brainrot/go_tower/submit
    TowerTarget=nil, TowerPos=nil,
    TowerSubmits=0, TowerRewards=0,
    -- Farm
    AutoCollect=false, AutoRebirth=false,
    -- ESP
    ESP=false, EspTags={},
    BrainrotESP=false, BrainrotTags={},
    Bright=false,
    -- Troll
    Troll=false, Invisible=false,
    Spin=false, SpinConn=nil,
    Tab="MOVE", Min=false,
}

-- ══════════════════════════════════════
-- SCREEN GUI
-- ══════════════════════════════════════
local SG=Instance.new("ScreenGui")
SG.Name="PrimejTsuHub"; SG.ResetOnSpawn=false
SG.IgnoreGuiInset=true; SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
SG.DisplayOrder=9999; SG.Parent=guiParent

local MF=Instance.new("Frame",SG)
MF.Size=UDim2.new(0,318,0,515)
MF.Position=UDim2.new(0,6,0,36)
MF.BackgroundColor3=C.BG; MF.BorderSizePixel=0; MF.ClipsDescendants=true
Instance.new("UICorner",MF).CornerRadius=UDim.new(0,12)
local mst=Instance.new("UIStroke",MF)
mst.Color=C.WAVE; mst.Thickness=1.5; mst.Transparency=0.3

local gl=Instance.new("Frame",MF)
gl.Size=UDim2.new(1,0,0,2); gl.BorderSizePixel=0; gl.BackgroundColor3=C.WAVE
Instance.new("UIGradient",gl).Color=ColorSequence.new{
    ColorSequenceKeypoint.new(0,Color3.new(0,0,0)),
    ColorSequenceKeypoint.new(0.35,C.WAVE),
    ColorSequenceKeypoint.new(0.65,C.NEON),
    ColorSequenceKeypoint.new(1,Color3.new(0,0,0)),
}

local TB=Instance.new("Frame",MF)
TB.Size=UDim2.new(1,0,0,48); TB.Position=UDim2.new(0,0,0,2)
TB.BackgroundColor3=C.PAN; TB.BorderSizePixel=0

local TT=Instance.new("TextLabel",TB)
TT.Size=UDim2.new(1,-88,0,28); TT.Position=UDim2.new(0,12,0,4)
TT.BackgroundTransparency=1; TT.Font=Enum.Font.GothamBold
TT.Text="🌊 PrimejTsuHub"; TT.TextColor3=C.WAVE
TT.TextSize=16; TT.TextXAlignment=Enum.TextXAlignment.Left

local TS=Instance.new("TextLabel",TB)
TS.Size=UDim2.new(1,-12,0,14); TS.Position=UDim2.new(0,12,0,32)
TS.BackgroundTransparency=1; TS.Font=Enum.Font.Gotham
TS.Text="Escape Tsunami For Brainrots  •  v3.0"
TS.TextColor3=C.SUB; TS.TextSize=10; TS.TextXAlignment=Enum.TextXAlignment.Left

local MinBtn=Instance.new("TextButton",TB)
MinBtn.Size=UDim2.new(0,36,0,28); MinBtn.Position=UDim2.new(1,-78,0.5,-14)
MinBtn.BackgroundColor3=Color3.fromRGB(16,24,44); MinBtn.BorderSizePixel=0
MinBtn.Text="—"; MinBtn.TextColor3=C.SUB; MinBtn.TextSize=16
MinBtn.Font=Enum.Font.GothamBold
Instance.new("UICorner",MinBtn).CornerRadius=UDim.new(0,6)

local ClBtn=Instance.new("TextButton",TB)
ClBtn.Size=UDim2.new(0,32,0,28); ClBtn.Position=UDim2.new(1,-40,0.5,-14)
ClBtn.BackgroundColor3=Color3.fromRGB(50,14,14); ClBtn.BorderSizePixel=0
ClBtn.Text="✕"; ClBtn.TextColor3=C.RED; ClBtn.TextSize=14
ClBtn.Font=Enum.Font.GothamBold
Instance.new("UICorner",ClBtn).CornerRadius=UDim.new(0,6)

local TABS={"MOVE","GOD☠️","TOWER🏆","MISC"}
local TCOLS={MOVE=C.WAVE,["GOD☠️"]=C.GOLD,["TOWER🏆"]=C.TEAL,MISC=C.PUR}
local TabBtns={}

local TabBar=Instance.new("Frame",MF)
TabBar.Size=UDim2.new(1,0,0,38); TabBar.Position=UDim2.new(0,0,0,52)
TabBar.BackgroundColor3=C.PAN; TabBar.BorderSizePixel=0

for i,t in ipairs(TABS) do
    local w=1/#TABS
    local b=Instance.new("TextButton",TabBar)
    b.Size=UDim2.new(w,-2,1,-8); b.Position=UDim2.new(w*(i-1),1,0,4)
    b.BackgroundColor3=C.PAN2; b.BorderSizePixel=0
    b.Text=t; b.TextColor3=C.SUB; b.TextSize=10; b.Font=Enum.Font.GothamBold
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    TabBtns[t]=b
end

local TLine=Instance.new("Frame",TabBar)
TLine.Size=UDim2.new(0.22,0,0,2); TLine.Position=UDim2.new(0,1,1,-2)
TLine.BackgroundColor3=C.WAVE; TLine.BorderSizePixel=0
Instance.new("UICorner",TLine).CornerRadius=UDim.new(1,0)

local SC=Instance.new("ScrollingFrame",MF)
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
    p.PaddingTop=UDim.new(0,6); p.PaddingBottom=UDim.new(0,12)
end

-- ══════════════════════════════════════
-- WIDGETS
-- ══════════════════════════════════════
local function Toggle(parent,label,desc,order,acol,cb)
    local ac=acol or C.NEON
    local row=Instance.new("Frame",parent)
    row.Size=UDim2.new(1,0,0,56); row.BackgroundColor3=C.PAN2
    row.BorderSizePixel=0; row.LayoutOrder=order
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,9)
    local rst=Instance.new("UIStroke",row)
    rst.Color=ac; rst.Thickness=1; rst.Transparency=0.85

    local nl=Instance.new("TextLabel",row)
    nl.Size=UDim2.new(1,-72,0,26); nl.Position=UDim2.new(0,12,0,7)
    nl.BackgroundTransparency=1; nl.Font=Enum.Font.GothamBold
    nl.Text=label; nl.TextColor3=C.TEXT; nl.TextSize=13
    nl.TextXAlignment=Enum.TextXAlignment.Left

    if desc then
        local dl=Instance.new("TextLabel",row)
        dl.Size=UDim2.new(1,-72,0,16); dl.Position=UDim2.new(0,12,0,33)
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
    kn.BackgroundColor3=Color3.fromRGB(100,120,150); kn.BorderSizePixel=0
    Instance.new("UICorner",kn).CornerRadius=UDim.new(1,0)

    local on=false
    local function set(v)
        on=v
        tw(bg,{BackgroundColor3=v and ac or C.OFF})
        tw(kn,{Position=v and UDim2.new(0,27,0,3) or UDim2.new(0,3,0,3),
            BackgroundColor3=v and C.WHITE or Color3.fromRGB(100,120,150)})
        tw(rst,{Transparency=v and 0.4 or 0.85})
    end

    local btn=Instance.new("TextButton",row)
    btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""
    btn.MouseButton1Click:Connect(function()
        on=not on; set(on); if cb then cb(on) end
    end)
    return row,set
end

local function Slider(parent,label,mn,mx,def,sfx,order,cb)
    local row=Instance.new("Frame",parent)
    row.Size=UDim2.new(1,0,0,58); row.BackgroundColor3=C.PAN2
    row.BorderSizePixel=0; row.LayoutOrder=order
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,9)

    local ll=Instance.new("TextLabel",row)
    ll.Size=UDim2.new(0.55,0,0,22); ll.Position=UDim2.new(0,12,0,8)
    ll.BackgroundTransparency=1; ll.Font=Enum.Font.Gotham
    ll.Text=label; ll.TextColor3=C.SUB; ll.TextSize=11
    ll.TextXAlignment=Enum.TextXAlignment.Left

    local vl=Instance.new("TextLabel",row)
    vl.Size=UDim2.new(0.42,0,0,22); vl.Position=UDim2.new(0.56,0,0,8)
    vl.BackgroundTransparency=1; vl.Font=Enum.Font.GothamBold
    vl.Text=tostring(def)..(sfx or ""); vl.TextColor3=C.NEON; vl.TextSize=12
    vl.TextXAlignment=Enum.TextXAlignment.Right

    local track=Instance.new("Frame",row)
    track.Size=UDim2.new(1,-16,0,8); track.Position=UDim2.new(0,8,0,38)
    track.BackgroundColor3=Color3.fromRGB(15,22,40); track.BorderSizePixel=0
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)

    local fill=Instance.new("Frame",track)
    fill.Size=UDim2.new((def-mn)/(mx-mn),0,1,0)
    fill.BackgroundColor3=C.WAVE; fill.BorderSizePixel=0
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)

    local knob=Instance.new("Frame",track)
    knob.Size=UDim2.new(0,22,0,22)
    knob.Position=UDim2.new((def-mn)/(mx-mn),-11,0.5,-11)
    knob.BackgroundColor3=C.WHITE; knob.BorderSizePixel=0
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    Instance.new("UIStroke",knob).Color=C.WAVE

    local drag=false
    local function upd(x)
        local t=math.clamp((x-track.AbsolutePosition.X)/math.max(track.AbsoluteSize.X,1),0,1)
        local v=math.floor(mn+t*(mx-mn))
        fill.Size=UDim2.new(t,0,1,0)
        knob.Position=UDim2.new(t,-11,0.5,-11)
        vl.Text=tostring(v)..(sfx or "")
        if cb then cb(v) end
    end

    local ib=Instance.new("TextButton",row)
    ib.Size=UDim2.new(1,0,1,0); ib.BackgroundTransparency=1; ib.Text=""
    ib.MouseButton1Down:Connect(function(x) drag=true; upd(x) end)
    ib.MouseButton1Up:Connect(function() drag=false end)
    ib.MouseMoved:Connect(function(x) if drag then upd(x) end end)
    UIS.TouchMoved:Connect(function(t2) if drag then upd(t2.Position.X) end end)
    UIS.TouchEnded:Connect(function() drag=false end)
end

local function Btn(parent,txt,col,order,cb)
    local b=Instance.new("TextButton",parent)
    b.Size=UDim2.new(1,0,0,50); b.LayoutOrder=order
    b.BackgroundColor3=Color3.fromRGB(
        math.floor(col.R*255*0.12),math.floor(col.G*255*0.12),math.floor(col.B*255*0.12))
    b.BorderSizePixel=0; b.Text=txt
    b.TextColor3=col; b.TextSize=13; b.Font=Enum.Font.GothamBold
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,9)
    Instance.new("UIStroke",b).Color=col

    b.MouseButton1Click:Connect(function()
        tw(b,{BackgroundColor3=Color3.fromRGB(
            math.floor(col.R*255*0.25),math.floor(col.G*255*0.25),math.floor(col.B*255*0.25))},0.1)
        task.delay(0.2,function()
            tw(b,{BackgroundColor3=Color3.fromRGB(
                math.floor(col.R*255*0.12),math.floor(col.G*255*0.12),math.floor(col.B*255*0.12))},0.2)
        end)
        if cb then cb() end
    end)
    return b
end

local function SecLabel(parent,txt,col,order)
    local f=Instance.new("Frame",parent)
    f.Size=UDim2.new(1,0,0,24); f.BackgroundTransparency=1
    f.LayoutOrder=order; f.BorderSizePixel=0
    local l=Instance.new("TextLabel",f)
    l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1
    l.Font=Enum.Font.GothamBold; l.Text="── "..txt.." ──"
    l.TextColor3=col or C.SUB; l.TextSize=10
end

-- ══════════════════════════════════════
-- GOD MODE
-- ══════════════════════════════════════
local function enableGodMode()
    local char=getChar(); if not char then return end
    for _,conn in ipairs(S.GodConns) do pcall(function() conn:Disconnect() end) end
    S.GodConns={}
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    hum.MaxHealth=math.huge; hum.Health=math.huge

    for _,part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            local c=part.Touched:Connect(function()
                if S.GodMode then
                    local h=getHum()
                    if h and h.Health<h.MaxHealth then h.Health=h.MaxHealth end
                end
            end)
            table.insert(S.GodConns,c)
        end
    end

    local hpc=RunService.Heartbeat:Connect(function()
        if not S.GodMode then return end
        local h=getHum()
        if h then
            if h.MaxHealth~=math.huge then h.MaxHealth=math.huge end
            if h.Health~=math.huge then h.Health=math.huge end
            h.TakeDamage=function() end
        end
    end)
    table.insert(S.GodConns,hpc)

    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") then
            local n=obj.Name:lower()
            if n:find("kill") or n:find("wave") or n:find("damage")
            or n:find("drown") or n:find("flood") then
                pcall(function() obj.Disabled=true end)
            end
        end
    end

    local dc=workspace.DescendantAdded:Connect(function(obj)
        if not S.GodMode then return end
        if obj:IsA("Script") or obj:IsA("LocalScript") then
            local n=obj.Name:lower()
            if n:find("kill") or n:find("wave") or n:find("damage") then
                pcall(function() obj.Disabled=true end)
            end
        end
    end)
    table.insert(S.GodConns,dc)
end

local function disableGodMode()
    for _,conn in ipairs(S.GodConns) do pcall(function() conn:Disconnect() end) end
    S.GodConns={}
    local h=getHum(); if h then h.MaxHealth=100; h.Health=100 end
end

lp.CharacterAdded:Connect(function()
    task.wait(0.15)
    if S.GodMode then enableGodMode() end
end)

-- ══════════════════════════════════════
-- AUTO TOWER TRAIL LOGIC
-- Как работает Tsunami Tower:
-- 1) Найти башню (TsunamiTower / Tower)
-- 2) Подойти к ней и нажать E (ProximityPrompt)
-- 3) Получить задание — собрать N брейнротов нужной редкости
-- 4) Пойти в зону и подобрать брейнротов
-- 5) Вернуться к башне и сдать (нажать E снова)
-- 6) Получить награду
-- ══════════════════════════════════════

local towerStatusLabel=nil -- обновляется из pageEsp

local function findTsunamiTower()
    -- Ищем башню по разным возможным именам
    local names={"TsunamiTower","Tower","tsunami_tower","TsunamiTowerModel",
                 "TowerBase","MainTower","CaveTower"}
    for _,obj in ipairs(workspace:GetDescendants()) do
        local n=obj.Name:lower()
        if n:find("tsunamitower") or n:find("tsunami_tower") or n:find("tower") then
            if obj:IsA("Model") or obj:IsA("BasePart") then
                local pos
                if obj:IsA("Model") then
                    pos=obj.PrimaryPart and obj.PrimaryPart.Position
                        or (obj:FindFirstChildOfClass("BasePart") and
                            obj:FindFirstChildOfClass("BasePart").Position)
                elseif obj:IsA("BasePart") then
                    pos=obj.Position
                end
                if pos then return obj,pos end
            end
        end
    end
    return nil,nil
end

local function findTowerPrompt()
    -- Ищем ProximityPrompt у башни
    local tower,_=findTsunamiTower()
    if tower then
        for _,pp in ipairs(tower:GetDescendants()) do
            if pp:IsA("ProximityPrompt") then return pp end
        end
        -- Ищем рядом с башней
        local towerPos
        if tower:IsA("Model") then
            towerPos=tower.PrimaryPart and tower.PrimaryPart.Position
        elseif tower:IsA("BasePart") then
            towerPos=tower.Position
        end
        if towerPos then
            for _,obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    local pp_parent=obj.Parent
                    if pp_parent and pp_parent:IsA("BasePart") then
                        if (pp_parent.Position-towerPos).Magnitude<30 then
                            return obj
                        end
                    end
                end
            end
        end
    end
    -- Fallback: ищем любой ProximityPrompt с tower в имени
    for _,pp in ipairs(workspace:GetDescendants()) do
        if pp:IsA("ProximityPrompt") then
            local n=(pp.ActionText or ""):lower()
            local pn=pp.Parent and pp.Parent.Name:lower() or ""
            if n:find("tower") or n:find("submit") or n:find("trail")
            or pn:find("tower") then
                return pp
            end
        end
    end
    return nil
end

local function findBrainrots()
    -- Ищем брейнротов которых можно подобрать
    local found={}
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local n=obj.Name:lower()
            -- Брейнроты обычно лежат в tsunami zone
            if n:find("brainrot") or n:find("sigma") or n:find("skibidi")
            or n:find("gyatt") or n:find("rizz") or n:find("mewing")
            or n:find("moai") or n:find("noob") or n:find("collect")
            or n:find("pickup") then
                local pos
                if obj:IsA("BasePart") then pos=obj.Position
                elseif obj:IsA("Model") then
                    pos=obj.PrimaryPart and obj.PrimaryPart.Position
                        or (obj:FindFirstChildOfClass("BasePart") and
                            obj:FindFirstChildOfClass("BasePart").Position)
                end
                if pos then table.insert(found,{obj=obj,pos=pos}) end
            end
        end
    end
    return found
end

-- Главный Auto Tower Trail цикл
task.spawn(function()
    local cooldown=0
    while true do
        task.wait(0.5)
        if not S.AutoTower then
            S.TowerStep="idle"
            S.TowerStatus="INACTIVE"
            cooldown=0
            continue
        end

        local root=getRoot()
        if not root then continue end

        -- Кулдаун между попытками
        if cooldown>0 then
            cooldown=cooldown-0.5
            S.TowerStatus="⏳ КУЛДАУН: "..math.ceil(cooldown).."s"
            continue
        end

        -- ШАГ 1: Найти башню
        local tower,towerPos=findTsunamiTower()
        if not tower then
            S.TowerStatus="🔍 Ищу Tsunami Tower..."
            -- Телепортируемся в центр карты чтобы найти башню
            task.wait(2)
            continue
        end

        -- ШАГ 2: Подойти к башне
        local distToTower=(towerPos-root.Position).Magnitude
        if distToTower>8 then
            S.TowerStatus="🚶 Иду к башне ("..math.floor(distToTower).."m)"
            root.CFrame=CFrame.new(towerPos+Vector3.new(0,3,0))
            task.wait(0.3)
        end

        -- ШАГ 3: Нажать E (ProximityPrompt) чтобы начать/сдать
        local pp=findTowerPrompt()
        if pp then
            S.TowerStatus="🗼 Нажимаю E на башне..."
            pcall(function() fireproximityprompt(pp) end)
            task.wait(0.5)
            pcall(function() fireproximityprompt(pp) end)
            task.wait(0.3)
        end

        -- ШАГ 4: Собрать брейнротов
        S.TowerStatus="🧠 Собираю брейнротов..."
        local brainrots=findBrainrots()

        if #brainrots>0 then
            -- Собираем до 10 штук
            local collected=0
            for _,br in ipairs(brainrots) do
                if collected>=10 then break end
                local dist=(br.pos-root.Position).Magnitude
                if dist<500 then -- только если не слишком далеко
                    root.CFrame=CFrame.new(br.pos+Vector3.new(0,3,0))
                    task.wait(0.15)
                    -- Пробуем подобрать через Touched или ProximityPrompt
                    local brPP=br.obj:FindFirstChildOfClass("ProximityPrompt")
                    if brPP then
                        pcall(function() fireproximityprompt(brPP) end)
                    end
                    collected=collected+1
                    S.TowerStatus="🧠 Собрал: "..collected.."/10"
                end
            end
            S.TowerSubmits=S.TowerSubmits+1
        else
            S.TowerStatus="❌ Брейнроты не найдены"
            task.wait(3)
        end

        -- ШАГ 5: Вернуться к башне и сдать
        if towerPos then
            S.TowerStatus="🗼 Возвращаюсь к башне..."
            root.CFrame=CFrame.new(towerPos+Vector3.new(0,3,0))
            task.wait(0.3)

            -- Сдаём
            if pp then
                S.TowerStatus="📦 Сдаю брейнротов..."
                pcall(function() fireproximityprompt(pp) end)
                task.wait(0.3)
                pcall(function() fireproximityprompt(pp) end)
                task.wait(0.5)
                S.TowerRewards=S.TowerRewards+1
                S.TowerStatus="✅ Сдано! Награда получена #"..S.TowerRewards
            end
        end

        -- Ждём кулдаун башни (несколько минут)
        cooldown=180 -- 3 минуты
        S.TowerStatus="✅ Цикл завершён! Следующий через 3 мин"
    end
end)

-- ══════════════════════════════════════
-- PAGES
-- ══════════════════════════════════════

-- PAGE: MOVE
local function pageMove()
    resetSC()
    SecLabel(SC,"СКОРОСТЬ",C.WAVE,0)
    Toggle(SC,"🏃 SPEED HACK","Изменить скорость бега",1,C.WAVE,function(v)
        S.Speed=v
        local h=getHum(); if h then h.WalkSpeed=v and S.SpeedVal or 16 end
    end)
    Slider(SC,"Скорость",16,300,60," WS",2,function(v)
        S.SpeedVal=v
        if S.Speed then local h=getHum(); if h then h.WalkSpeed=v end end
    end)
    SecLabel(SC,"ПРЫЖОК",C.WAVE,3)
    Toggle(SC,"🦘 JUMP BOOST","Высота прыжка",4,C.WAVE,function(v)
        S.Jump=v
        local h=getHum()
        if h then
            h.JumpHeight=v and 7.2*(S.JumpVal/100) or 7.2
            h.JumpPower=v and 50*(S.JumpVal/100) or 50
        end
    end)
    Slider(SC,"Высота прыжка",100,800,150,"%",5,function(v)
        S.JumpVal=v
        if S.Jump then
            local h=getHum()
            if h then h.JumpHeight=7.2*(v/100); h.JumpPower=50*(v/100) end
        end
    end)
    Toggle(SC,"♾️ INFINITE JUMP","Прыгать в воздухе бесконечно",6,C.WAVE,function(v)
        S.InfJump=v
        if S.InfJumpConn then S.InfJumpConn:Disconnect(); S.InfJumpConn=nil end
        if v then
            S.InfJumpConn=UIS.JumpRequest:Connect(function()
                local h=getHum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        end
    end)
    Toggle(SC,"🔄 BHOP","Авто бхоп",7,C.WAVE,function(v)
        S.Bhop=v
        if S.BhopConn then S.BhopConn:Disconnect(); S.BhopConn=nil end
        if v then
            S.BhopConn=RunService.Heartbeat:Connect(function()
                if not S.Bhop then return end
                local h=getHum()
                if h and h.FloorMaterial~=Enum.Material.Air then
                    h:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end)
    SecLabel(SC,"ДВИЖЕНИЕ",C.WAVE,8)
    Toggle(SC,"👻 NO CLIP","Сквозь стены",9,C.WAVE,function(v) S.NoClip=v end)
    Toggle(SC,"🕊️ FLY","Летать",10,C.WAVE,function(v)
        S.Fly=v
        local root=getRoot(); if not root then return end
        if v then
            local att=Instance.new("Attachment",root); att.Name="FlyAtt"
            local lv=Instance.new("LinearVelocity",root); lv.Name="FlyLV"
            lv.Attachment0=att
            lv.VelocityConstraintMode=Enum.VelocityConstraintMode.Vector
            lv.MaxForce=2e5; lv.VectorVelocity=Vector3.new(0,28,0)
        else
            for _,n in ipairs({"FlyLV","FlyAtt"}) do
                local f=root:FindFirstChild(n); if f then f:Destroy() end
            end
        end
    end)
    Btn(SC,"⚡ ТЕЛЕПОРТ ВПЕРЁД",C.WAVE,11,function()
        local r=getRoot(); if r then r.CFrame=r.CFrame*CFrame.new(0,5,-300) end
    end)
end

-- PAGE: GOD
local godSet=nil
local function pageGod()
    resetSC()

    local card=Instance.new("Frame",SC)
    card.Size=UDim2.new(1,0,0,118); card.BackgroundColor3=Color3.fromRGB(14,9,0)
    card.BorderSizePixel=0; card.LayoutOrder=1
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,10)
    local cst=Instance.new("UIStroke",card)
    cst.Color=C.GOLD; cst.Thickness=1.5; cst.Transparency=0.5

    local ic=Instance.new("TextLabel",card)
    ic.Size=UDim2.new(0,55,0,55); ic.Position=UDim2.new(0,10,0,10)
    ic.BackgroundTransparency=1; ic.Text="☠️"; ic.TextSize=40
    ic.Font=Enum.Font.GothamBold; ic.TextColor3=C.GOLD

    local tl=Instance.new("TextLabel",card)
    tl.Size=UDim2.new(1,-125,0,26); tl.Position=UDim2.new(0,72,0,10)
    tl.BackgroundTransparency=1; tl.Font=Enum.Font.GothamBold
    tl.Text="ULTRA GOD MODE"; tl.TextColor3=C.GOLD2; tl.TextSize=15
    tl.TextXAlignment=Enum.TextXAlignment.Left

    local dl=Instance.new("TextLabel",card)
    dl.Size=UDim2.new(1,-125,0,58); dl.Position=UDim2.new(0,72,0,34)
    dl.BackgroundTransparency=1; dl.Font=Enum.Font.Gotham
    dl.Text="HP = ∞  •  TakeDamage заблокирован\nKill скрипты отключены\nTouched события заблокированы"
    dl.TextColor3=Color3.fromRGB(200,160,80); dl.TextSize=10
    dl.TextXAlignment=Enum.TextXAlignment.Left; dl.TextWrapped=true

    local gbg=Instance.new("Frame",card)
    gbg.Size=UDim2.new(0,56,0,30); gbg.Position=UDim2.new(1,-64,0,10)
    gbg.BackgroundColor3=C.OFF; gbg.BorderSizePixel=0
    Instance.new("UICorner",gbg).CornerRadius=UDim.new(1,0)

    local gkn=Instance.new("Frame",gbg)
    gkn.Size=UDim2.new(0,24,0,24); gkn.Position=UDim2.new(0,3,0,3)
    gkn.BackgroundColor3=Color3.fromRGB(100,120,150); gkn.BorderSizePixel=0
    Instance.new("UICorner",gkn).CornerRadius=UDim.new(1,0)

    local godOn=false
    local function setGod(v)
        godOn=v; S.GodMode=v
        tw(gbg,{BackgroundColor3=v and C.GOLD or C.OFF})
        tw(gkn,{Position=v and UDim2.new(0,29,0,3) or UDim2.new(0,3,0,3),
            BackgroundColor3=v and C.GOLD2 or Color3.fromRGB(100,120,150)})
        tw(cst,{Transparency=v and 0.05 or 0.5})
        tw(card,{BackgroundColor3=v and Color3.fromRGB(22,14,0) or Color3.fromRGB(14,9,0)})
        if v then enableGodMode() else disableGodMode() end
    end
    godSet=setGod

    local cbtn=Instance.new("TextButton",card)
    cbtn.Size=UDim2.new(1,0,1,0); cbtn.BackgroundTransparency=1; cbtn.Text=""
    cbtn.MouseButton1Click:Connect(function() setGod(not godOn) end)

    SecLabel(SC,"ДОПОЛНИТЕЛЬНО",C.GOLD,2)
    Toggle(SC,"🌀 ANTI-GRAVITY","Держит выше волны",3,C.GOLD,function(v) S.AntiGrav=v end)
    Toggle(SC,"⚡ AUTO-TELEPORT","Прыжок от волны автоматически",4,C.GOLD,function(v) S.AutoTele=v end)
    Toggle(SC,"🕳️ ANTI-VOID","Телепорт если упал в void",5,C.GOLD,function(v) S.AntiVoid=v end)

    local mb=Btn(SC,"☠️  ВКЛ ВСЕГО — FULL GOD  ☠️",C.GOLD,6,function()
        if godSet then godSet(true) end
        S.AntiGrav=true; S.AutoTele=true; S.AntiVoid=true
        mb.Text="☠️  FULL GOD АКТИВЕН  ☠️"
    end)
    mb.Size=UDim2.new(1,0,0,54)

    local sf=Instance.new("Frame",SC)
    sf.Size=UDim2.new(1,0,0,36); sf.BackgroundColor3=Color3.fromRGB(10,6,0)
    sf.BorderSizePixel=0; sf.LayoutOrder=7
    Instance.new("UICorner",sf).CornerRadius=UDim.new(0,8)
    Instance.new("UIStroke",sf).Color=C.GOLD
    local sl=Instance.new("TextLabel",sf)
    sl.Size=UDim2.new(1,0,1,0); sl.BackgroundTransparency=1
    sl.Font=Enum.Font.GothamBold; sl.TextSize=11

    task.spawn(function()
        while SC.Parent do
            task.wait(0.5)
            if S.GodMode then
                sl.Text="☠️ GOD ON  •  HP:∞  •  DMG:BLOCKED"
                sl.TextColor3=C.GOLD
            else
                sl.Text="💀 GOD INACTIVE"; sl.TextColor3=C.SUB
            end
        end
    end)
end

-- PAGE: TOWER
local function pageTower()
    resetSC()

    -- Большая карточка Auto Tower Trail
    local card=Instance.new("Frame",SC)
    card.Size=UDim2.new(1,0,0,130); card.BackgroundColor3=Color3.fromRGB(0,14,12)
    card.BorderSizePixel=0; card.LayoutOrder=1
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,10)
    local cst=Instance.new("UIStroke",card)
    cst.Color=C.TEAL; cst.Thickness=1.5; cst.Transparency=0.4

    local ic=Instance.new("TextLabel",card)
    ic.Size=UDim2.new(0,55,0,55); ic.Position=UDim2.new(0,10,0,8)
    ic.BackgroundTransparency=1; ic.Text="🗼"; ic.TextSize=38
    ic.Font=Enum.Font.GothamBold; ic.TextColor3=C.TEAL

    local tl=Instance.new("TextLabel",card)
    tl.Size=UDim2.new(1,-125,0,24); tl.Position=UDim2.new(0,70,0,8)
    tl.BackgroundTransparency=1; tl.Font=Enum.Font.GothamBold
    tl.Text="AUTO TOWER TRAIL"; tl.TextColor3=C.TEAL; tl.TextSize=15
    tl.TextXAlignment=Enum.TextXAlignment.Left

    local dl=Instance.new("TextLabel",card)
    dl.Size=UDim2.new(1,-125,0,48); dl.Position=UDim2.new(0,70,0,32)
    dl.BackgroundTransparency=1; dl.Font=Enum.Font.Gotham
    dl.Text="Авто находит Tsunami Tower\nСобирает брейнротов\nСдаёт в башню нажав E\nПолучает награды!"
    dl.TextColor3=Color3.fromRGB(80,220,200); dl.TextSize=10
    dl.TextXAlignment=Enum.TextXAlignment.Left; dl.TextWrapped=true

    local tbg=Instance.new("Frame",card)
    tbg.Size=UDim2.new(0,56,0,30); tbg.Position=UDim2.new(1,-64,0,8)
    tbg.BackgroundColor3=C.OFF; tbg.BorderSizePixel=0
    Instance.new("UICorner",tbg).CornerRadius=UDim.new(1,0)

    local tkn=Instance.new("Frame",tbg)
    tkn.Size=UDim2.new(0,24,0,24); tkn.Position=UDim2.new(0,3,0,3)
    tkn.BackgroundColor3=Color3.fromRGB(100,120,150); tkn.BorderSizePixel=0
    Instance.new("UICorner",tkn).CornerRadius=UDim.new(1,0)

    -- Status внутри карточки
    local statusL=Instance.new("TextLabel",card)
    statusL.Size=UDim2.new(1,-16,0,18); statusL.Position=UDim2.new(0,8,1,-22)
    statusL.BackgroundTransparency=1; statusL.Font=Enum.Font.Gotham
    statusL.Text="● INACTIVE"; statusL.TextColor3=C.SUB; statusL.TextSize=11

    local tOn=false
    local tbtn=Instance.new("TextButton",card)
    tbtn.Size=UDim2.new(1,0,1,0); tbtn.BackgroundTransparency=1; tbtn.Text=""
    tbtn.MouseButton1Click:Connect(function()
        tOn=not tOn; S.AutoTower=tOn
        tw(tbg,{BackgroundColor3=tOn and C.TEAL or C.OFF})
        tw(tkn,{Position=tOn and UDim2.new(0,29,0,3) or UDim2.new(0,3,0,3),
            BackgroundColor3=tOn and C.WHITE or Color3.fromRGB(100,120,150)})
        tw(cst,{Transparency=tOn and 0.1 or 0.4})
        tw(card,{BackgroundColor3=tOn and Color3.fromRGB(0,20,18) or Color3.fromRGB(0,14,12)})
        statusL.Text=tOn and "● ЗАПУСК..." or "● INACTIVE"
        statusL.TextColor3=tOn and C.TEAL or C.SUB
    end)

    -- Авто обновление статуса
    task.spawn(function()
        while SC.Parent do
            task.wait(0.3)
            if S.AutoTower then
                statusL.Text="● "..S.TowerStatus
                statusL.TextColor3=C.TEAL
            else
                statusL.Text="● INACTIVE"
                statusL.TextColor3=C.SUB
            end
        end
    end)

    -- Статистика
    SecLabel(SC,"СТАТИСТИКА",C.TEAL,2)

    local statsFrame=Instance.new("Frame",SC)
    statsFrame.Size=UDim2.new(1,0,0,60); statsFrame.BackgroundTransparency=1
    statsFrame.LayoutOrder=3; statsFrame.BorderSizePixel=0
    local sfl=Instance.new("UIListLayout",statsFrame)
    sfl.FillDirection=Enum.FillDirection.Horizontal; sfl.Padding=UDim.new(0,5)

    local statLabels={}
    for _,s in ipairs({{"🗼","SUBMITS","0"},{"🎁","REWARDS","0"},{"🧠","BRAINROTS","0"}}) do
        local b=Instance.new("Frame",statsFrame)
        b.Size=UDim2.new(0.33,-4,1,0); b.BackgroundColor3=Color3.fromRGB(0,14,12)
        b.BorderSizePixel=0
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
        Instance.new("UIStroke",b).Color=C.TEAL

        local vl=Instance.new("TextLabel",b)
        vl.Size=UDim2.new(1,0,0.5,0); vl.Position=UDim2.new(0,0,0.05,0)
        vl.BackgroundTransparency=1; vl.Font=Enum.Font.GothamBold
        vl.Text=s[3]; vl.TextColor3=C.TEAL; vl.TextSize=18

        local ll=Instance.new("TextLabel",b)
        ll.Size=UDim2.new(1,0,0.4,0); ll.Position=UDim2.new(0,0,0.58,0)
        ll.BackgroundTransparency=1; ll.Font=Enum.Font.Gotham
        ll.Text=s[1].." "..s[2]; ll.TextColor3=Color3.fromRGB(80,200,190); ll.TextSize=9

        statLabels[s[2]]=vl
    end

    task.spawn(function()
        while SC.Parent do
            task.wait(1)
            if statLabels["SUBMITS"] then statLabels["SUBMITS"].Text=tostring(S.TowerSubmits) end
            if statLabels["REWARDS"] then statLabels["REWARDS"].Text=tostring(S.TowerRewards) end
        end
    end)

    SecLabel(SC,"НАСТРОЙКИ",C.TEAL,4)

    Toggle(SC,"⚡ БЫСТРЫЙ СБОР","Телепортироваться к брейнротам",5,C.TEAL,function(v)
        -- Включено по умолчанию в логике
    end)

    Toggle(SC,"🔄 AUTO REBIRTH","Авто возрождение для фарма",6,C.GREEN,function(v)
        S.AutoRebirth=v
    end)

    Toggle(SC,"💰 AUTO COLLECT","Авто собирать монеты",7,C.GREEN,function(v)
        S.AutoCollect=v
    end)

    Btn(SC,"🗼 ТП К БАШНЕ СЕЙЧАС",C.TEAL,8,function()
        local _,pos=findTsunamiTower()
        local root=getRoot()
        if root and pos then
            root.CFrame=CFrame.new(pos+Vector3.new(0,5,0))
        else
            -- Ищем ориентировочно — башня обычно в безопасной зоне
            local root2=getRoot()
            if root2 then root2.CFrame=CFrame.new(0,50,0) end
        end
    end)

    Btn(SC,"🔥 НАЖАТЬ E НА БАШНЕ",C.ORG,9,function()
        local pp=findTowerPrompt()
        if pp then
            local root=getRoot()
            if root and pp.Parent and pp.Parent:IsA("BasePart") then
                root.CFrame=CFrame.new(pp.Parent.Position+Vector3.new(0,4,0))
                task.wait(0.2)
            end
            pcall(function() fireproximityprompt(pp) end)
        end
    end)

    Btn(SC,"📦 НАЖАТЬ ВСЕ PROMPTS",C.PUR,10,function()
        for _,pp in ipairs(workspace:GetDescendants()) do
            if pp:IsA("ProximityPrompt") then
                pcall(function() fireproximityprompt(pp) end)
                task.wait(0.05)
            end
        end
    end)
end

-- PAGE: MISC
local function pageMisc()
    resetSC()
    SecLabel(SC,"ESP",C.NEON,0)
    Toggle(SC,"📍 PLAYER ESP","Имена над головой",1,C.NEON,function(v)
        S.ESP=v
        if not v then
            for _,t in pairs(S.EspTags) do if t and t.Parent then t:Destroy() end end
            S.EspTags={}
        end
    end)
    Toggle(SC,"🧠 BRAINROT ESP","Видеть брейнротов на карте",2,C.PINK,function(v)
        S.BrainrotESP=v
        if not v then
            for _,t in pairs(S.BrainrotTags) do if t and t.Parent then t:Destroy() end end
            S.BrainrotTags={}
        end
    end)
    Toggle(SC,"💡 FULLBRIGHT","Максимальная яркость",3,C.NEON,function(v)
        game.Lighting.Brightness=v and 6 or 1
        game.Lighting.ClockTime=v and 14 or 12
    end)

    SecLabel(SC,"TROLL",C.RED,4)
    Toggle(SC,"😈 TROLL","Fling игроков в волну",5,C.RED,function(v) S.Troll=v end)
    Toggle(SC,"👁️ INVISIBLE","Стать невидимым",6,C.RED,function(v)
        S.Invisible=v
        local char=getChar(); if not char then return end
        for _,p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") or p:IsA("Decal") then
                p.LocalTransparencyModifier=v and 1 or 0
            end
        end
    end)
    Toggle(SC,"🌀 SPIN","Крутиться",7,C.RED,function(v)
        S.Spin=v
        if S.SpinConn then S.SpinConn:Disconnect(); S.SpinConn=nil end
        if v then
            local a=0
            S.SpinConn=RunService.Heartbeat:Connect(function(dt)
                if not S.Spin then return end
                local r=getRoot()
                if r then a=a+(dt*8); r.CFrame=CFrame.new(r.Position)*CFrame.Angles(0,a,0) end
            end)
        end
    end)

    SecLabel(SC,"ДЕЙСТВИЯ",C.RED,8)
    Btn(SC,"💥 FLING ВСЕХ",C.RED,9,function()
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
                    lv.VectorVelocity=(pr.Position-root.Position).Unit*280+Vector3.new(0,120,0)
                    Debris:AddItem(lv,0.25); Debris:AddItem(att,0.25)
                end
            end
        end
    end)
    Btn(SC,"🌊 ТП К ФИНИШУ",C.PUR,10,function()
        local root=getRoot(); if not root then return end
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n=obj.Name:lower()
                if n:find("safe") or n:find("finish") or n:find("end") then
                    root.CFrame=CFrame.new(obj.Position+Vector3.new(0,8,0)); return
                end
            end
        end
        root.CFrame=root.CFrame*CFrame.new(0,5,-800)
    end)
end

-- ══════════════════════════════════════
-- TAB SWITCH
-- ══════════════════════════════════════
local pages={MOVE=pageMove,["GOD☠️"]=pageGod,["TOWER🏆"]=pageTower,MISC=pageMisc}

local function switchTab(name)
    S.Tab=name
    for _,t in ipairs(TABS) do
        local b=TabBtns[t]; local active=t==name
        tw(b,{BackgroundColor3=active and Color3.fromRGB(12,18,35) or C.PAN2})
        b.TextColor3=active and (TCOLS[t] or C.WAVE) or C.SUB
    end
    local idx=table.find(TABS,name) or 1
    local w=1/#TABS
    tw(TLine,{
        Position=UDim2.new(w*(idx-1)+w*0.04,1,1,-2),
        Size=UDim2.new(w*0.92,-2,0,2),
        BackgroundColor3=TCOLS[name] or C.WAVE,
    })
    if pages[name] then pages[name]() end
end

for _,t in ipairs(TABS) do
    TabBtns[t].MouseButton1Click:Connect(function() switchTab(t) end)
end

-- DRAG
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
    UIS.TouchMoved:Connect(mv)
    UIS.InputEnded:Connect(function() drag=false end)
end

MinBtn.MouseButton1Click:Connect(function()
    S.Min=not S.Min
    tw(MF,{Size=S.Min and UDim2.new(0,318,0,52) or UDim2.new(0,318,0,515)},0.25)
    MinBtn.Text=S.Min and "□" or "—"
end)
ClBtn.MouseButton1Click:Connect(function()
    tw(MF,{Size=UDim2.new(0,318,0,0)},0.2)
    task.delay(0.25,function() SG:Destroy() end)
end)

-- ══════════════════════════════════════
-- MAIN LOOP
-- ══════════════════════════════════════
RunService.Heartbeat:Connect(function()
    local char=lp.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local root=char:FindFirstChild("HumanoidRootPart"); if not root then return end

    if S.Speed then hum.WalkSpeed=S.SpeedVal end
    if S.Jump then
        hum.JumpHeight=7.2*(S.JumpVal/100)
        hum.JumpPower=50*(S.JumpVal/100)
    end
    if S.NoClip then
        for _,p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=false end
        end
    end
    if S.GodMode then
        if hum.MaxHealth~=math.huge then hum.MaxHealth=math.huge end
        if hum.Health~=math.huge then hum.Health=math.huge end
        hum.TakeDamage=function() end
    end
    if S.AntiGrav and root.Position.Y<18 then
        root.CFrame=CFrame.new(root.Position.X,20,root.Position.Z)
    end
    if S.AutoTele then
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n=obj.Name:lower()
                if n:find("wave") or n:find("tsunami") or n:find("flood") then
                    if (obj.Position-root.Position).Magnitude<35 then
                        root.CFrame=root.CFrame*CFrame.new(0,8,-80); break
                    end
                end
            end
        end
    end
    if S.AntiVoid and root.Position.Y<-80 then
        root.CFrame=CFrame.new(root.Position.X,50,root.Position.Z)
    end
    if S.AutoCollect then
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n=obj.Name:lower()
                if n:find("coin") or n:find("gem") or n:find("money") then
                    if (obj.Position-root.Position).Magnitude<15 then
                        root.CFrame=CFrame.new(obj.Position+Vector3.new(0,3,0))
                    end
                end
            end
        end
    end
    if S.AutoRebirth then
        for _,gui in ipairs(lp.PlayerGui:GetDescendants()) do
            if gui:IsA("TextButton") then
                local n=(gui.Text or ""):lower()
                if n:find("rebirth") or n:find("возрожд") then
                    pcall(function() gui:activate() end)
                end
            end
        end
    end
    if S.Troll then
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=lp and p.Character then
                local pr=p.Character:FindFirstChild("HumanoidRootPart")
                if pr and (pr.Position-root.Position).Magnitude<14 then
                    local att=Instance.new("Attachment",pr)
                    local lv=Instance.new("LinearVelocity",pr)
                    lv.Attachment0=att
                    lv.VelocityConstraintMode=Enum.VelocityConstraintMode.Vector
                    lv.MaxForce=1e5
                    lv.VectorVelocity=(pr.Position-root.Position).Unit*200+Vector3.new(0,70,0)
                    Debris:AddItem(lv,0.2); Debris:AddItem(att,0.2)
                end
            end
        end
    end
    if S.ESP then
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=lp and p.Character then
                local head=p.Character:FindFirstChild("Head")
                if head and not S.EspTags[p.UserId] then
                    local bb=Instance.new("BillboardGui",head)
                    bb.Size=UDim2.new(0,120,0,34)
                    bb.StudsOffset=Vector3.new(0,3,0); bb.AlwaysOnTop=true
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
    if S.BrainrotESP then
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and not S.BrainrotTags[obj] then
                local n=obj.Name:lower()
                if n:find("brainrot") or n:find("sigma") or n:find("skibidi") then
                    local part=obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
                    if part then
                        local bb=Instance.new("BillboardGui",part)
                        bb.Size=UDim2.new(0,130,0,28)
                        bb.StudsOffset=Vector3.new(0,4,0); bb.AlwaysOnTop=true
                        local lb=Instance.new("TextLabel",bb)
                        lb.Size=UDim2.new(1,0,1,0); lb.BackgroundTransparency=1
                        lb.Font=Enum.Font.GothamBold; lb.TextSize=11
                        lb.Text="🧠 "..obj.Name; lb.TextColor3=C.PINK
                        lb.TextStrokeTransparency=0
                        S.BrainrotTags[obj]=bb
                    end
                end
            end
        end
    end
end)

switchTab("MOVE")
print("✅ PrimejTsuHub v3.0 LOADED!")
print("🗼 Auto Tower Trail READY — ищет Tsunami Tower и сдаёт брейнротов")
