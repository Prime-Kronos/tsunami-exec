-- ================================================
--   Primejtsu | Flick — PRO GUI v6
--   Style: Z3US Dark Purple
--   30+ Functions | Delta Compatible
--   Author: @Primejtsu
-- ================================================

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera       = workspace.CurrentCamera
local Lighting     = game:GetService("Lighting")

local lp        = Players.LocalPlayer
local character = lp.Character or lp.CharacterAdded:Wait()
local humanoid  = character:WaitForChild("Humanoid")
local rootPart  = character:WaitForChild("HumanoidRootPart")
local mouse     = lp:GetMouse()

-- ================================================
--  COLORS
-- ================================================
local C = {
    bg       = Color3.fromRGB(18, 12, 28),
    sidebar  = Color3.fromRGB(24, 16, 36),
    panel    = Color3.fromRGB(28, 20, 42),
    row      = Color3.fromRGB(34, 24, 50),
    accent   = Color3.fromRGB(138, 43, 226),
    accent2  = Color3.fromRGB(100, 30, 180),
    text     = Color3.fromRGB(230, 220, 255),
    subtext  = Color3.fromRGB(160, 140, 200),
    white    = Color3.fromRGB(255, 255, 255),
    green    = Color3.fromRGB(80, 220, 120),
    red      = Color3.fromRGB(220, 60, 60),
    pillOff  = Color3.fromRGB(50, 35, 70),
}

-- ================================================
--  STATE
-- ================================================
local bv, bg
local highlights = {}
local rgbHue     = 0
local dragging   = false
local dragStart, winStart
local currentTab = "Legit"

-- Feature states
local S = {
    -- Legit
    aimbot=false, showFov=false, triggerbot=false, prediction=false,
    -- Rage
    silentAim=false, rageAim=false, spinbot=false, antiAim=false,
    -- Visuals
    esp=false, chams=false, healthBar=false, nameTags=false,
    fullbright=false, noFog=false, crosshair=false, skeleton=false,
    -- Player
    speed=false, fly=false, noclip=false, bhop=false,
    infJump=false, antiKick=false, antiRagdoll=false, jumpPower=false,
    -- Teleport
    tpToPlayer=false, tpSpawn=false, tpLastDeath=false,
    -- World
    noGravity=false, timeChange=false, antiVoid=false,
    -- Unlock
    unlockAll=false, unlockSkins=false, unlockPets=false,
    -- Misc
    antiAfk=false, autoRespawn=false, fakeLatency=false,
    chatBypass=false, serverHop=false, copyPlayer=false,
}

-- Slider values
local V = {
    fovSize=150, smooth=5, walkSpeed=85, flySpeed=65,
    jumpPower=50, predX=0, predY=0,
    timeValue=14, fakeMs=0,
}

-- ================================================
--  GUI ROOT
-- ================================================
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn   = false
gui.Name           = "PrimejtsuFlick"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.Parent         = lp.PlayerGui

-- ================================================
--  HELPERS
-- ================================================
local function corner(p,r) local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 8);c.Parent=p;return c end
local function stroke(p,clr,th) local s=Instance.new("UIStroke");s.Color=clr;s.Thickness=th or 1;s.Parent=p;return s end

local function mkLabel(parent,txt,size,color,font,xAlign,pos,lsize,zi)
    local l=Instance.new("TextLabel")
    l.Text=txt; l.Size=lsize or UDim2.new(1,0,1,0)
    l.Position=pos or UDim2.new(0,0,0,0)
    l.BackgroundTransparency=1
    l.TextColor3=color or C.text
    l.Font=font or Enum.Font.GothamBold
    l.TextSize=size or 13
    l.TextXAlignment=xAlign or Enum.TextXAlignment.Left
    if zi then l.ZIndex=zi end
    l.Parent=parent
    return l
end

-- ================================================
--  MAIN WINDOW
-- ================================================
local win = Instance.new("Frame")
win.Size             = UDim2.new(0,680,0,440)
win.Position         = UDim2.new(0.5,-340,0.5,-220)
win.BackgroundColor3 = C.bg
win.BorderSizePixel  = 0
win.ZIndex           = 5
win.Parent           = gui
corner(win,14)
stroke(win,C.accent,1.5)

-- ================================================
--  TOPBAR
-- ================================================
local topbar = Instance.new("Frame")
topbar.Size             = UDim2.new(1,0,0,46)
topbar.BackgroundColor3 = Color3.fromRGB(14,9,22)
topbar.BorderSizePixel  = 0
topbar.ZIndex           = 6
topbar.Parent           = win
corner(topbar,14)

local topFix=Instance.new("Frame")
topFix.Size=UDim2.new(1,0,0.5,0); topFix.Position=UDim2.new(0,0,0.5,0)
topFix.BackgroundColor3=Color3.fromRGB(14,9,22); topFix.BorderSizePixel=0
topFix.ZIndex=6; topFix.Parent=topbar

-- Logo image in topbar
local topLogo=Instance.new("ImageLabel")
topLogo.Size=UDim2.new(0,30,0,30); topLogo.Position=UDim2.new(0,12,0.5,-15)
topLogo.BackgroundTransparency=1
topLogo.Image="rbxassetid://71693879665391"
topLogo.ZIndex=8; topLogo.Parent=topbar

-- Title
local topTitle=Instance.new("TextLabel")
topTitle.Text="Primejtsu  |  Flick"
topTitle.Size=UDim2.new(0.5,0,1,0); topTitle.Position=UDim2.new(0,48,0,0)
topTitle.BackgroundTransparency=1; topTitle.TextColor3=C.white
topTitle.Font=Enum.Font.GothamBold; topTitle.TextSize=15
topTitle.TextXAlignment=Enum.TextXAlignment.Left
topTitle.ZIndex=7; topTitle.Parent=topbar

-- Version tag
local verTag=Instance.new("TextLabel")
verTag.Text="v6.0  •  Delta"
verTag.Size=UDim2.new(0.3,0,1,0); verTag.Position=UDim2.new(0.45,0,0,0)
verTag.BackgroundTransparency=1; verTag.TextColor3=C.subtext
verTag.Font=Enum.Font.Gotham; verTag.TextSize=11
verTag.TextXAlignment=Enum.TextXAlignment.Center
verTag.ZIndex=7; verTag.Parent=topbar

-- Window controls
local function mkWinBtn(xOff,bgc,txt)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(0,22,0,22); b.Position=UDim2.new(1,xOff,0.5,-11)
    b.BackgroundColor3=bgc; b.TextColor3=C.white
    b.Font=Enum.Font.GothamBold; b.TextSize=12; b.Text=txt
    b.BorderSizePixel=0; b.ZIndex=9; b.Parent=topbar
    corner(b,6)
    return b
end
local minBtn   = mkWinBtn(-72,Color3.fromRGB(200,160,0),"_")
local maxBtn   = mkWinBtn(-46,Color3.fromRGB(40,160,80),"□")
local closeBtn = mkWinBtn(-20,Color3.fromRGB(200,50,50),"×")

-- Accent line
local accentBar=Instance.new("Frame")
accentBar.Size=UDim2.new(1,0,0,2); accentBar.Position=UDim2.new(0,0,1,-2)
accentBar.BackgroundColor3=C.accent; accentBar.BorderSizePixel=0
accentBar.ZIndex=7; accentBar.Parent=topbar

-- ================================================
--  DRAG
-- ================================================
topbar.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or
       i.UserInputType==Enum.UserInputType.Touch then
        dragging=true; dragStart=i.Position; winStart=win.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or
       i.UserInputType==Enum.UserInputType.Touch) then
        local d=i.Position-dragStart
        win.Position=UDim2.new(winStart.X.Scale,winStart.X.Offset+d.X,
            winStart.Y.Scale,winStart.Y.Offset+d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or
       i.UserInputType==Enum.UserInputType.Touch then dragging=false end
end)

-- ================================================
--  SIDEBAR
-- ================================================
local sidebar=Instance.new("Frame")
sidebar.Size=UDim2.new(0,150,1,-46); sidebar.Position=UDim2.new(0,0,0,46)
sidebar.BackgroundColor3=C.sidebar; sidebar.BorderSizePixel=0
sidebar.ZIndex=6; sidebar.Parent=win

local sideLayout=Instance.new("UIListLayout")
sideLayout.SortOrder=Enum.SortOrder.LayoutOrder
sideLayout.Padding=UDim.new(0,2); sideLayout.Parent=sidebar

local sidePad=Instance.new("UIPadding")
sidePad.PaddingTop=UDim.new(0,10); sidePad.PaddingLeft=UDim.new(0,8)
sidePad.PaddingRight=UDim.new(0,8); sidePad.Parent=sidebar

-- ================================================
--  CONTENT AREA
-- ================================================
local content=Instance.new("Frame")
content.Size=UDim2.new(1,-150,1,-46); content.Position=UDim2.new(0,150,0,46)
content.BackgroundColor3=C.panel; content.BorderSizePixel=0
content.ZIndex=6; content.Parent=win

-- Divider
local divider=Instance.new("Frame")
divider.Size=UDim2.new(0,1,1,0); divider.Position=UDim2.new(0,0,0,0)
divider.BackgroundColor3=C.accent; divider.BorderSizePixel=0
divider.ZIndex=7; divider.Parent=content

local pages={}

-- ================================================
--  SIDEBAR TAB FACTORY
-- ================================================
local TABS={
    {name="Legit",   icon="🎯"},
    {name="Rage",    icon="💢"},
    {name="Visuals", icon="👁"},
    {name="Player",  icon="🏃"},
    {name="Teleport",icon="📍"},
    {name="World",   icon="🌍"},
    {name="Unlock",  icon="🔓"},
    {name="Misc",    icon="⚙️"},
    {name="Settings",icon="🔧"},
}

local sideButtons={}

local function selectTab(name)
    currentTab=name
    for n,btn in pairs(sideButtons) do
        if n==name then
            btn.BackgroundColor3=C.accent2
            btn.TextColor3=C.white
        else
            btn.BackgroundColor3=Color3.fromRGB(0,0,0,0)
            btn.BackgroundTransparency=1
            btn.TextColor3=C.subtext
        end
    end
    for n,page in pairs(pages) do
        page.Visible=(n==name)
    end
end

for i,tab in ipairs(TABS) do
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,0,0,38)
    btn.BackgroundColor3=Color3.fromRGB(0,0,0)
    btn.BackgroundTransparency=1
    btn.TextColor3=C.subtext
    btn.Font=Enum.Font.GothamBold; btn.TextSize=12
    btn.Text=tab.icon.."  "..tab.name
    btn.TextXAlignment=Enum.TextXAlignment.Left
    btn.BorderSizePixel=0; btn.LayoutOrder=i
    btn.ZIndex=7; btn.Parent=sidebar
    corner(btn,8)

    local btnPad=Instance.new("UIPadding")
    btnPad.PaddingLeft=UDim.new(0,10); btnPad.Parent=btn

    sideButtons[tab.name]=btn

    -- Page
    local page=Instance.new("ScrollingFrame")
    page.Size=UDim2.new(1,-1,1,0); page.Position=UDim2.new(0,1,0,0)
    page.BackgroundTransparency=1; page.BorderSizePixel=0
    page.ScrollBarThickness=3
    page.ScrollBarImageColor3=C.accent
    page.CanvasSize=UDim2.new(0,0,0,0)
    page.AutomaticCanvasSize=Enum.AutomaticSize.Y
    page.Visible=(tab.name=="Legit")
    page.ZIndex=7; page.Parent=content
    pages[tab.name]=page

    local pl=Instance.new("UIListLayout")
    pl.SortOrder=Enum.SortOrder.LayoutOrder; pl.Padding=UDim.new(0,4); pl.Parent=page
    local pp=Instance.new("UIPadding")
    pp.PaddingLeft=UDim.new(0,14); pp.PaddingRight=UDim.new(0,14)
    pp.PaddingTop=UDim.new(0,14); pp.Parent=page

    btn.MouseButton1Click:Connect(function() selectTab(tab.name) end)
end
selectTab("Legit")

-- ================================================
--  ROW FACTORIES
-- ================================================
local function mkSectionTitle(page,txt,order)
    local lbl=Instance.new("TextLabel")
    lbl.Text=txt; lbl.Size=UDim2.new(1,0,0,30)
    lbl.BackgroundTransparency=1; lbl.TextColor3=C.white
    lbl.Font=Enum.Font.GothamBold; lbl.TextSize=16
    lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.LayoutOrder=order; lbl.ZIndex=8; lbl.Parent=page
    return lbl
end

local function mkToggle(page,txt,order,desc)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,50)
    row.BackgroundColor3=C.row
    row.BorderSizePixel=0; row.LayoutOrder=order; row.ZIndex=8; row.Parent=page
    corner(row,8)

    local lbl=Instance.new("TextLabel")
    lbl.Text=txt; lbl.Size=UDim2.new(0.6,0,0,26); lbl.Position=UDim2.new(0,14,0,6)
    lbl.BackgroundTransparency=1; lbl.TextColor3=C.text
    lbl.Font=Enum.Font.GothamBold; lbl.TextSize=13
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=9; lbl.Parent=row

    if desc then
        local sub=Instance.new("TextLabel")
        sub.Text=desc; sub.Size=UDim2.new(0.75,0,0,16); sub.Position=UDim2.new(0,14,0,28)
        sub.BackgroundTransparency=1; sub.TextColor3=C.subtext
        sub.Font=Enum.Font.Gotham; sub.TextSize=10
        sub.TextXAlignment=Enum.TextXAlignment.Left; sub.ZIndex=9; sub.Parent=row
    end

    -- Pill toggle
    local pill=Instance.new("Frame")
    pill.Size=UDim2.new(0,46,0,24); pill.Position=UDim2.new(1,-58,0.5,-12)
    pill.BackgroundColor3=C.pillOff; pill.BorderSizePixel=0; pill.ZIndex=9; pill.Parent=row
    corner(pill,12)

    local knob=Instance.new("Frame")
    knob.Size=UDim2.new(0,18,0,18); knob.Position=UDim2.new(0,3,0.5,-9)
    knob.BackgroundColor3=C.subtext; knob.BorderSizePixel=0; knob.ZIndex=10; knob.Parent=pill
    corner(knob,9)

    local active=false
    local hitbox=Instance.new("TextButton")
    hitbox.Size=UDim2.new(1,0,1,0); hitbox.BackgroundTransparency=1
    hitbox.Text=""; hitbox.ZIndex=11; hitbox.Parent=row

    local function setOn(state)
        active=state
        local kGoal=state and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)
        local pClr=state and C.accent or C.pillOff
        local kClr=state and C.white or C.subtext
        TweenService:Create(knob,TweenInfo.new(0.15),{Position=kGoal,BackgroundColor3=kClr}):Play()
        TweenService:Create(pill,TweenInfo.new(0.15),{BackgroundColor3=pClr}):Play()
    end

    hitbox.MouseButton1Click:Connect(function() setOn(not active) end)
    return hitbox, function() return active end, setOn
end

local function mkSlider(page,txt,mn,mx,def,order,desc)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,desc and 68 or 58)
    row.BackgroundColor3=C.row
    row.BorderSizePixel=0; row.LayoutOrder=order; row.ZIndex=8; row.Parent=page
    corner(row,8)

    local lbl=Instance.new("TextLabel")
    lbl.Text=txt; lbl.Size=UDim2.new(0.65,0,0,22); lbl.Position=UDim2.new(0,14,0,6)
    lbl.BackgroundTransparency=1; lbl.TextColor3=C.text
    lbl.Font=Enum.Font.GothamBold; lbl.TextSize=13
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=9; lbl.Parent=row

    local valLbl=Instance.new("TextLabel")
    valLbl.Text=tostring(def); valLbl.Size=UDim2.new(0.3,0,0,22)
    valLbl.Position=UDim2.new(0.67,0,0,6); valLbl.BackgroundTransparency=1
    valLbl.TextColor3=C.accent; valLbl.Font=Enum.Font.GothamBold; valLbl.TextSize=13
    valLbl.TextXAlignment=Enum.TextXAlignment.Right; valLbl.ZIndex=9; valLbl.Parent=row

    local trackY = desc and 48 or 36
    local track=Instance.new("Frame")
    track.Size=UDim2.new(1,-28,0,5); track.Position=UDim2.new(0,14,0,trackY)
    track.BackgroundColor3=Color3.fromRGB(40,28,60); track.BorderSizePixel=0
    track.ZIndex=9; track.Parent=row
    corner(track,3)

    local fill=Instance.new("Frame")
    fill.Size=UDim2.new((def-mn)/(mx-mn),0,1,0)
    fill.BackgroundColor3=C.accent; fill.BorderSizePixel=0; fill.ZIndex=10; fill.Parent=track
    corner(fill,3)

    -- Knob
    local tknob=Instance.new("Frame")
    tknob.Size=UDim2.new(0,14,0,14)
    tknob.Position=UDim2.new((def-mn)/(mx-mn),0,0.5,-7)
    tknob.BackgroundColor3=C.white; tknob.BorderSizePixel=0; tknob.ZIndex=11; tknob.Parent=track
    corner(tknob,7)

    local value=def; local sdrag=false
    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or
           i.UserInputType==Enum.UserInputType.Touch then sdrag=true end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or
           i.UserInputType==Enum.UserInputType.Touch then sdrag=false end
    end)
    UIS.InputChanged:Connect(function(i)
        if sdrag then
            local rel=math.clamp((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
            value=math.floor(mn+(mx-mn)*rel)
            fill.Size=UDim2.new(rel,0,1,0)
            tknob.Position=UDim2.new(rel,0,0.5,-7)
            valLbl.Text=tostring(value)
        end
    end)
    return function() return value end
end

local function mkColorBox(page,txt,order,defaultColor)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,50); row.BackgroundColor3=C.row
    row.BorderSizePixel=0; row.LayoutOrder=order; row.ZIndex=8; row.Parent=page
    corner(row,8)

    local lbl=Instance.new("TextLabel")
    lbl.Text=txt; lbl.Size=UDim2.new(0.7,0,1,0); lbl.Position=UDim2.new(0,14,0,0)
    lbl.BackgroundTransparency=1; lbl.TextColor3=C.text
    lbl.Font=Enum.Font.GothamBold; lbl.TextSize=13
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=9; lbl.Parent=row

    local colorBox=Instance.new("Frame")
    colorBox.Size=UDim2.new(0,32,0,32); colorBox.Position=UDim2.new(1,-46,0.5,-16)
    colorBox.BackgroundColor3=defaultColor or C.accent
    colorBox.BorderSizePixel=0; colorBox.ZIndex=9; colorBox.Parent=row
    corner(colorBox,6)
    stroke(colorBox,C.white,1)
end

-- ================================================
--  LEGIT TAB
-- ================================================
local lp2=pages["Legit"]
mkSectionTitle(lp2,"Aimbot",1)
local _,aimbotOn,aimbotSet   = mkToggle(lp2,"Aimbot","Smooth aim assist toward target head",2)
local _,showFovOn,showFovSet = mkToggle(lp2,"Show FOV","Display aim circle on screen",3)
local getFov                  = mkSlider(lp2,"FOV Size",30,500,150,4)
local getFovClr               = mkColorBox(lp2,"FOV Color",5,C.accent)
local getSmooth               = mkSlider(lp2,"Smoothness",1,100,50,6,"Higher = softer aim movement")
local getPredX                = mkSlider(lp2,"Prediction Strength X",-50,50,0,7)
local getPredY                = mkSlider(lp2,"Prediction Strength Y",-50,50,0,8)
mkSectionTitle(lp2,"Triggerbot",9)
local _,trigOn,trigSet        = mkToggle(lp2,"Triggerbot","Auto shoot when crosshair on enemy",10)
local _,silentOn,silentSet    = mkToggle(lp2,"Silent Aim","Redirect shots to nearest enemy",11)

-- ================================================
--  RAGE TAB
-- ================================================
local rp=pages["Rage"]
mkSectionTitle(rp,"Rage Aimbot",1)
local _,rageOn,rageSet       = mkToggle(rp,"Rage Aimbot","Instant snap aim — max speed",2,"High visibility, use carefully")
local _,spinOn,spinSet       = mkToggle(rp,"Spinbot","Rapidly spin character",3)
local _,antiAimOn,antiAimSet = mkToggle(rp,"Anti-Aim","Desync body from head position",4)
local _,infRangeOn,_         = mkToggle(rp,"Infinite Range","Hit targets at any distance",5)
local _,autoShtOn,_          = mkToggle(rp,"Auto Shoot","Automatically fire weapon",6)

-- ================================================
--  VISUALS TAB
-- ================================================
local vp=pages["Visuals"]
mkSectionTitle(vp,"ESP",1)
local _,espOn,espSet         = mkToggle(vp,"ESP Highlight","Highlight all enemies",2)
local _,chamsOn,chamsSet     = mkToggle(vp,"Chams Fill","Fill enemy models with color",3)
local _,nameOn,nameSet       = mkToggle(vp,"Name Tags","Show player names above heads",4)
local _,healthOn,healthSet   = mkToggle(vp,"Health Bar","Show enemy health bars",5)
local _,skelOn,skelSet       = mkToggle(vp,"Skeleton ESP","Draw skeleton lines on enemies",6)
mkSectionTitle(vp,"World",7)
local _,fbOn,fbSet           = mkToggle(vp,"Fullbright","Remove darkness from map",8)
local _,noFogOn,noFogSet     = mkToggle(vp,"No Fog","Remove all atmospheric fog",9)
local _,crossOn,crossSet     = mkToggle(vp,"Crosshair","Show dot crosshair on screen",10)
local _,noBlurOn,_           = mkToggle(vp,"No Blur","Remove motion blur effects",11)

-- ================================================
--  PLAYER TAB
-- ================================================
local pp2=pages["Player"]
mkSectionTitle(pp2,"Movement",1)
local _,speedOn,speedSet     = mkToggle(pp2,"Speed Boost","Increase walk speed",2)
local getWalk                = mkSlider(pp2,"Walk Speed",16,300,85,3)
local _,flyOn,flySet         = mkToggle(pp2,"Fly","Fly freely around the map",4)
local getFlySpd              = mkSlider(pp2,"Fly Speed",10,300,65,5)
local _,noclipOn,noclipSet   = mkToggle(pp2,"Noclip","Walk through walls",6)
local _,bhopOn,bhopSet       = mkToggle(pp2,"Bunny Hop","Auto jump on landing",7)
local _,infJOn,infJSet       = mkToggle(pp2,"Infinite Jump","Jump endlessly in air",8)
local getJumpPow             = mkSlider(pp2,"Jump Power",50,300,50,9)
mkSectionTitle(pp2,"Protection",10)
local _,antiKickOn,_         = mkToggle(pp2,"Anti-Kick","Prevent being kicked",11)
local _,antiRagOn,_          = mkToggle(pp2,"Anti-Ragdoll","Prevent ragdoll state",12)
local _,godOn,godSet         = mkToggle(pp2,"God Mode (local)","Disable local damage",13)

-- ================================================
--  TELEPORT TAB
-- ================================================
local tp2=pages["Teleport"]
mkSectionTitle(tp2,"Teleport",1)
local _,tpSpawnOn,_          = mkToggle(tp2,"TP to Spawn","Teleport to spawn point",2)
local _,tpWayptOn,_          = mkToggle(tp2,"TP Waypoint","Teleport to set waypoint",3)
local setWayptBtn            = Instance.new("TextButton")
setWayptBtn.Size=UDim2.new(1,0,0,44); setWayptBtn.BackgroundColor3=C.accent
setWayptBtn.TextColor3=C.white; setWayptBtn.Font=Enum.Font.GothamBold
setWayptBtn.TextSize=13; setWayptBtn.Text="Set Waypoint Here"
setWayptBtn.BorderSizePixel=0; setWayptBtn.LayoutOrder=4; setWayptBtn.ZIndex=8
setWayptBtn.Parent=tp2; corner(setWayptBtn,8)

local waypoint=nil
setWayptBtn.MouseButton1Click:Connect(function()
    if rootPart then waypoint=rootPart.Position end
end)

mkSectionTitle(tp2,"Players",5)
-- Player list buttons
local function refreshPlayerList()
    for _,child in pairs(tp2:GetChildren()) do
        if child.LayoutOrder>=10 then child:Destroy() end
    end
    local i=10
    for _,p in pairs(Players:GetPlayers()) do
        if p~=lp then
            local btn=Instance.new("TextButton")
            btn.Size=UDim2.new(1,0,0,44); btn.BackgroundColor3=C.row
            btn.TextColor3=C.text; btn.Font=Enum.Font.GothamBold
            btn.TextSize=12; btn.Text="TP to  "..p.Name
            btn.BorderSizePixel=0; btn.LayoutOrder=i; btn.ZIndex=8
            btn.Parent=tp2; corner(btn,8)
            btn.MouseButton1Click:Connect(function()
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    rootPart.CFrame=p.Character.HumanoidRootPart.CFrame+Vector3.new(2,0,0)
                end
            end)
            i=i+1
        end
    end
end
refreshPlayerList()

local refBtn=Instance.new("TextButton")
refBtn.Size=UDim2.new(1,0,0,44); refBtn.BackgroundColor3=C.accent2
refBtn.TextColor3=C.white; refBtn.Font=Enum.Font.GothamBold
refBtn.TextSize=13; refBtn.Text="Refresh Player List"
refBtn.BorderSizePixel=0; refBtn.LayoutOrder=6; refBtn.ZIndex=8
refBtn.Parent=tp2; corner(refBtn,8)
refBtn.MouseButton1Click:Connect(refreshPlayerList)

-- ================================================
--  WORLD TAB
-- ================================================
local wp=pages["World"]
mkSectionTitle(wp,"World Settings",1)
local _,noGravOn,_  = mkToggle(wp,"No Gravity","Remove gravity from workspace",2)
local _,antiVoidOn,_ = mkToggle(wp,"Anti-Void","Teleport back if falling too low",3)
local getTime        = mkSlider(wp,"Time of Day",0,24,14,4)
local _,timeOn,timeSet = mkToggle(wp,"Change Time","Apply custom time of day",5)
local _,noAnmOn,_   = mkToggle(wp,"No Animations","Disable player animations",6)
local _,thirdOn,_   = mkToggle(wp,"Third Person Lock","Lock camera to third person",7)

-- ================================================
--  UNLOCK TAB
-- ================================================
local ulp=pages["Unlock"]
mkSectionTitle(ulp,"Unlock",1)
local _,ulAllOn,_   = mkToggle(ulp,"Unlock All Items","Unlock all game items locally",2)
local _,ulSkinOn,_  = mkToggle(ulp,"Unlock Skins","Unlock all cosmetic skins",3)
local _,ulPetOn,_   = mkToggle(ulp,"Unlock Pets","Unlock all pets locally",4)
local _,ulMapOn,_   = mkToggle(ulp,"Unlock Maps","Unlock all maps",5)
local _,ulPassOn,_  = mkToggle(ulp,"Unlock Gamepasses","Simulate gamepass ownership",6)

-- ================================================
--  MISC TAB
-- ================================================
local mp2=pages["Misc"]
mkSectionTitle(mp2,"Misc",1)
local _,afkOn,afkSet     = mkToggle(mp2,"Anti-AFK","Prevent AFK kick",2)
local _,autoRespOn,_     = mkToggle(mp2,"Auto Respawn","Instantly respawn on death",3)
local _,chatBypOn,_      = mkToggle(mp2,"Chat Bypass","Bypass chat filter",4)
local _,srvHopOn,_       = mkToggle(mp2,"Server Hop","Hop to new server",5)
local _,copyOn,_         = mkToggle(mp2,"Copy Player","Copy nearest player movement",6)
local _,notifOn,_        = mkToggle(mp2,"Kill Notifications","Show kill/death feed",7)

-- ================================================
--  SETTINGS TAB
-- ================================================
local sp=pages["Settings"]
mkSectionTitle(sp,"Interface",1)
local _,rgbUIOn,_        = mkToggle(sp,"RGB Accent","Animate accent color with RGB",2)
local _,blurBGOn,_       = mkToggle(sp,"Blur Background","Blur game when menu open",3)
mkSectionTitle(sp,"Keybinds",4)

local keybindInfo=Instance.new("TextLabel")
keybindInfo.Text="Press  INSERT  to toggle menu visibility"
keybindInfo.Size=UDim2.new(1,0,0,44); keybindInfo.BackgroundColor3=C.row
keybindInfo.TextColor3=C.subtext; keybindInfo.Font=Enum.Font.Gotham; keybindInfo.TextSize=12
keybindInfo.BorderSizePixel=0; keybindInfo.LayoutOrder=5; keybindInfo.ZIndex=8
keybindInfo.Parent=sp; corner(keybindInfo,8)

-- ================================================
--  FOV RING UI
-- ================================================
local fovRingFrame=Instance.new("Frame")
fovRingFrame.BackgroundTransparency=1; fovRingFrame.BorderSizePixel=0
fovRingFrame.ZIndex=20; fovRingFrame.Visible=false; fovRingFrame.Parent=gui

local fovSt=Instance.new("UIStroke")
fovSt.Thickness=1.5; fovSt.Color=C.accent; fovSt.Parent=fovRingFrame

local fovCo=Instance.new("UICorner")
fovCo.CornerRadius=UDim.new(1,0); fovCo.Parent=fovRingFrame

-- Crosshair dot
local crossDot=Instance.new("Frame")
crossDot.Size=UDim2.new(0,6,0,6)
crossDot.BackgroundColor3=C.accent
crossDot.BorderSizePixel=0; crossDot.ZIndex=20; crossDot.Visible=false
crossDot.Parent=gui
corner(crossDot,3)

-- ================================================
--  FLY
-- ================================================
local function startFly()
    humanoid.PlatformStand=true
    bv=Instance.new("BodyVelocity")
    bv.Velocity=Vector3.new(0,0,0); bv.MaxForce=Vector3.new(1e5,1e5,1e5); bv.Parent=rootPart
    bg=Instance.new("BodyGyro")
    bg.MaxTorque=Vector3.new(1e5,1e5,1e5); bg.P=1e4; bg.Parent=rootPart
end
local function stopFly()
    humanoid.PlatformStand=false
    if bv then bv:Destroy(); bv=nil end
    if bg then bg:Destroy(); bg=nil end
end

-- ================================================
--  ESP
-- ================================================
local function clearESP()
    for _,h in pairs(highlights) do pcall(function() h:Destroy() end) end
    highlights={}
end
local prevEsp=false

local function doESP()
    clearESP()
    for _,p in pairs(Players:GetPlayers()) do
        if p~=lp and p.Character then
            local hl=Instance.new("Highlight")
            hl.FillColor=Color3.fromRGB(255,50,50)
            hl.OutlineColor=C.white
            hl.FillTransparency=chamsOn() and 0.45 or 1
            hl.OutlineTransparency=0
            hl.Adornee=p.Character; hl.Parent=p.Character
            highlights[p]=hl
        end
    end
end

-- ================================================
--  WINDOW CONTROLS
-- ================================================
local isVisible=true
closeBtn.MouseButton1Click:Connect(function()
    isVisible=not isVisible
    win.Visible=isVisible
end)
minBtn.MouseButton1Click:Connect(function()
    local minimized=content.Visible
    content.Visible=not minimized
    sidebar.Visible=not minimized
    win.Size=minimized and UDim2.new(0,680,0,46) or UDim2.new(0,680,0,440)
end)

-- INSERT key toggle
UIS.InputBegan:Connect(function(i,gpe)
    if not gpe and i.KeyCode==Enum.KeyCode.Insert then
        isVisible=not isVisible
        win.Visible=isVisible
    end
end)

-- ================================================
--  MAIN LOOP
-- ================================================
RunService.Heartbeat:Connect(function(dt)
    rgbHue=(rgbHue+dt*0.25)%1
    local rgb=Color3.fromHSV(rgbHue,1,1)

    -- Noclip
    if noclipOn() then
        for _,p in pairs(character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=false end
        end
    end

    -- Speed
    humanoid.WalkSpeed=speedOn() and getWalk() or 16

    -- Jump Power
    humanoid.JumpPower=infJOn() and getJumpPow() or 50

    -- BHop
    if bhopOn() and humanoid:GetState()==Enum.HumanoidStateType.Freefall then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    -- Inf Jump
    if infJOn() and UIS:IsKeyDown(Enum.KeyCode.Space) then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    -- Fullbright
    if fbOn() then
        Lighting.Brightness=2
        Lighting.ClockTime=14
        Lighting.FogEnd=1e6
        Lighting.GlobalShadows=false
        Lighting.Ambient=Color3.fromRGB(255,255,255)
    end

    -- No Fog
    if noFogOn() then
        Lighting.FogEnd=1e6
        Lighting.FogStart=1e6
    end

    -- Spinbot
    if spinOn() and rootPart then
        rootPart.CFrame=rootPart.CFrame*CFrame.Angles(0,math.rad(15),0)
    end

    -- Anti-Void
    if antiVoidOn() and rootPart and rootPart.Position.Y<-100 then
        rootPart.CFrame=CFrame.new(0,10,0)
    end

    -- Anti-AFK
    if afkOn() then lp:Move(Vector3.new(0,0,0)) end

    -- Time
    if timeOn() then Lighting.ClockTime=getTime() end

    -- No gravity
    if noGravOn() then workspace.Gravity=0.1 else workspace.Gravity=196.2 end

    -- FOV Ring
    local fovR=getFov()
    local cx=Camera.ViewportSize.X/2
    local cy=Camera.ViewportSize.Y/2
    if showFovOn() and (aimbotOn() or silentOn()) then
        fovRingFrame.Visible=true
        fovRingFrame.Size=UDim2.new(0,fovR*2,0,fovR*2)
        fovRingFrame.Position=UDim2.new(0,cx-fovR,0,cy-fovR)
        fovSt.Color=rgb
    else
        fovRingFrame.Visible=false
    end

    -- Crosshair dot
    if crossOn() then
        crossDot.Visible=true
        crossDot.Position=UDim2.new(0,cx-3,0,cy-3)
    else
        crossDot.Visible=false
    end

    -- Aimbot
    local center=Vector2.new(cx,cy)
    if aimbotOn() or rageOn() then
        local best,bestDist=nil,fovR
        if rageOn() then bestDist=9999 end
        for _,p in pairs(Players:GetPlayers()) do
            if p~=lp and p.Character then
                local head=p.Character:FindFirstChild("Head")
                if head then
                    local sPos,onScreen=Camera:WorldToScreenPoint(head.Position)
                    if onScreen then
                        local dist=(Vector2.new(sPos.X,sPos.Y)-center).Magnitude
                        if dist<bestDist then bestDist=dist; best=head end
                    end
                end
            end
        end
        if best then
            local s=rageOn() and 1 or math.clamp((101-getSmooth())/100,0.02,0.99)
            Camera.CFrame=Camera.CFrame:Lerp(
                CFrame.new(Camera.CFrame.Position,best.Position),s)
        end
    end

    -- Silent aim
    if silentOn() then
        local best,bestDist=nil,fovR
        for _,p in pairs(Players:GetPlayers()) do
            if p~=lp and p.Character then
                local head=p.Character:FindFirstChild("Head")
                if head then
                    local sPos,onScreen=Camera:WorldToScreenPoint(head.Position)
                    if onScreen then
                        local dist=(Vector2.new(sPos.X,sPos.Y)-center).Magnitude
                        if dist<bestDist then bestDist=dist; best=head end
                    end
                end
            end
        end
        if best then
            pcall(function()
                local sPos=Camera:WorldToScreenPoint(best.Position)
                mousemoverel(sPos.X-cx,sPos.Y-cy)
            end)
        end
    end

    -- Fly
    if flyOn() and not bv then startFly()
    elseif not flyOn() and bv then stopFly() end
    if flyOn() and bv and bg then
        local spd=getFlySpd(); local dir=Vector3.new(0,0,0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir=dir+Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir=dir-Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir=dir-Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir=dir+Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space)     then dir=dir+Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir=dir-Vector3.new(0,1,0) end
        bv.Velocity=dir*spd; bg.CFrame=Camera.CFrame
    end

    -- ESP
    local espState=espOn()
    if espState~=prevEsp then
        prevEsp=espState
        if espState then doESP() else clearESP() end
    end

    -- Waypoint teleport
    if tpWayptOn and waypoint and rootPart then
        rootPart.CFrame=CFrame.new(waypoint)
    end
end)

-- ================================================
--  RESPAWN
-- ================================================
lp.CharacterAdded:Connect(function(char)
    character=char
    humanoid=char:WaitForChild("Humanoid")
    rootPart=char:WaitForChild("HumanoidRootPart")
    flySet(false); noclipSet(false); speedSet(false)
    bhopSet(false); infJSet(false)
    clearESP()
end)

print("[Primejtsu | Flick v6] Loaded! Press INSERT to toggle.")
