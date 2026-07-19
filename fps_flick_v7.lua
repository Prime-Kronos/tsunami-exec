-- ================================================
--   Primejtsu | Flick  v7
--   Game: [FPS] Flick by Groundwork
--   Compatible: Delta Executor Mobile
--   Author: @Primejtsu
-- ================================================

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting     = game:GetService("Lighting")
local Camera       = workspace.CurrentCamera

local lp        = Players.LocalPlayer
local character = lp.Character or lp.CharacterAdded:Wait()
local humanoid  = character:WaitForChild("Humanoid")
local rootPart  = character:WaitForChild("HumanoidRootPart")

-- ================================================
--  COLORS
-- ================================================
local C = {
    bg      = Color3.fromRGB(15, 10, 24),
    sidebar = Color3.fromRGB(20, 14, 32),
    panel   = Color3.fromRGB(24, 18, 38),
    row     = Color3.fromRGB(30, 22, 46),
    accent  = Color3.fromRGB(130, 40, 220),
    accent2 = Color3.fromRGB(90, 25, 160),
    text    = Color3.fromRGB(228, 218, 255),
    sub     = Color3.fromRGB(155, 135, 195),
    white   = Color3.fromRGB(255, 255, 255),
    pillOff = Color3.fromRGB(45, 32, 65),
    green   = Color3.fromRGB(70, 210, 110),
    red     = Color3.fromRGB(210, 55, 55),
}

-- ================================================
--  STATE
-- ================================================
local bv, bg
local highlights  = {}
local rgbHue      = 0
local dragging    = false
local dragStart, winStart
local isVisible   = true
local isMinimized = false
local waypoint    = nil

-- ================================================
--  HELPERS
-- ================================================
local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
    return c
end

local function mkStroke(p, clr, th)
    local s = Instance.new("UIStroke")
    s.Color = clr or C.accent
    s.Thickness = th or 1
    s.Parent = p
    return s
end

-- ================================================
--  GUI ROOT
-- ================================================
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn   = false
gui.Name           = "PrimejtsuFlickV7"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.Parent         = lp.PlayerGui

-- ================================================
--  MAIN WINDOW
-- ================================================
local win = Instance.new("Frame")
win.Size             = UDim2.new(0, 660, 0, 430)
win.Position         = UDim2.new(0.5, -330, 0.5, -215)
win.BackgroundColor3 = C.bg
win.BorderSizePixel  = 0
win.ZIndex           = 5
win.Parent           = gui
corner(win, 14)
local winStroke = mkStroke(win, C.accent, 1.5)

-- ================================================
--  TOPBAR
-- ================================================
local topbar = Instance.new("Frame")
topbar.Size             = UDim2.new(1, 0, 0, 44)
topbar.BackgroundColor3 = Color3.fromRGB(12, 8, 20)
topbar.BorderSizePixel  = 0
topbar.ZIndex           = 6
topbar.Parent           = win
corner(topbar, 14)

-- fix bottom of topbar
local topFix = Instance.new("Frame")
topFix.Size = UDim2.new(1,0,0.5,0); topFix.Position = UDim2.new(0,0,0.5,0)
topFix.BackgroundColor3 = Color3.fromRGB(12,8,20)
topFix.BorderSizePixel = 0; topFix.ZIndex = 6; topFix.Parent = topbar

-- Logo
local topLogo = Instance.new("ImageLabel")
topLogo.Size = UDim2.new(0,28,0,28); topLogo.Position = UDim2.new(0,10,0.5,-14)
topLogo.BackgroundTransparency = 1
topLogo.Image = "rbxassetid://71693879665391"
topLogo.ZIndex = 8; topLogo.Parent = topbar

-- Title
local topTitle = Instance.new("TextLabel")
topTitle.Text = "Primejtsu  |  Flick"
topTitle.Size = UDim2.new(0,220,1,0); topTitle.Position = UDim2.new(0,44,0,0)
topTitle.BackgroundTransparency = 1; topTitle.TextColor3 = C.white
topTitle.Font = Enum.Font.GothamBold; topTitle.TextSize = 14
topTitle.TextXAlignment = Enum.TextXAlignment.Left
topTitle.ZIndex = 7; topTitle.Parent = topbar

-- Subtitle
local topSub = Instance.new("TextLabel")
topSub.Text = "[FPS] Flick  •  v7  •  Delta"
topSub.Size = UDim2.new(0,220,1,0); topSub.Position = UDim2.new(0,270,0,0)
topSub.BackgroundTransparency = 1; topSub.TextColor3 = C.sub
topSub.Font = Enum.Font.Gotham; topSub.TextSize = 11
topSub.TextXAlignment = Enum.TextXAlignment.Left
topSub.ZIndex = 7; topSub.Parent = topbar

-- Accent line
local accentLine = Instance.new("Frame")
accentLine.Size = UDim2.new(1,0,0,2); accentLine.Position = UDim2.new(0,0,1,-2)
accentLine.BackgroundColor3 = C.accent
accentLine.BorderSizePixel = 0; accentLine.ZIndex = 7; accentLine.Parent = topbar

-- Window buttons
local function mkWBtn(xOff, bgc, txt)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0,22,0,22); b.Position = UDim2.new(1,xOff,0.5,-11)
    b.BackgroundColor3 = bgc; b.TextColor3 = C.white
    b.Font = Enum.Font.GothamBold; b.TextSize = 12; b.Text = txt
    b.BorderSizePixel = 0; b.ZIndex = 9; b.Parent = topbar
    corner(b, 5)
    return b
end
local minBtn   = mkWBtn(-68, Color3.fromRGB(180,140,0), "_")
local closeBtn = mkWBtn(-42, Color3.fromRGB(180,45,45), "X")
local hideBtn  = mkWBtn(-16, Color3.fromRGB(40,140,80),  "H")

-- Drag
topbar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or
       i.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = i.Position; winStart = win.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or
       i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dragStart
        win.Position = UDim2.new(winStart.X.Scale, winStart.X.Offset+d.X,
            winStart.Y.Scale, winStart.Y.Offset+d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or
       i.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

-- ================================================
--  SIDEBAR
-- ================================================
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0,148,1,-44); sidebar.Position = UDim2.new(0,0,0,44)
sidebar.BackgroundColor3 = C.sidebar; sidebar.BorderSizePixel = 0
sidebar.ZIndex = 6; sidebar.Parent = win

local sDiv = Instance.new("Frame")
sDiv.Size = UDim2.new(0,1,1,0); sDiv.Position = UDim2.new(1,0,0,0)
sDiv.BackgroundColor3 = C.accent; sDiv.BorderSizePixel = 0
sDiv.ZIndex = 7; sDiv.Parent = sidebar

local sLayout = Instance.new("UIListLayout")
sLayout.SortOrder = Enum.SortOrder.LayoutOrder
sLayout.Padding = UDim.new(0,2); sLayout.Parent = sidebar

local sPad = Instance.new("UIPadding")
sPad.PaddingTop = UDim.new(0,8); sPad.PaddingLeft = UDim.new(0,6)
sPad.PaddingRight = UDim.new(0,6); sPad.Parent = sidebar

-- Content
local content = Instance.new("Frame")
content.Size = UDim2.new(1,-148,1,-44); content.Position = UDim2.new(0,148,0,44)
content.BackgroundColor3 = C.panel; content.BorderSizePixel = 0
content.ZIndex = 6; content.Parent = win

-- ================================================
--  TABS
-- ================================================
local TABS = {
    {n="Aimbot",   i="◎"},
    {n="Silent",   i="🔇"},
    {n="Weapon",   i="🔫"},
    {n="Visuals",  i="👁"},
    {n="Movement", i="🏃"},
    {n="World",    i="🌍"},
    {n="Misc",     i="⚙️"},
}

local tabBtns = {}; local pages = {}
local currentTab = "Aimbot"

for idx, tab in ipairs(TABS) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,40)
    btn.BackgroundColor3 = C.sidebar
    btn.BackgroundTransparency = 1
    btn.TextColor3 = C.sub
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 12
    btn.Text = tab.i.."  "..tab.n
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0; btn.LayoutOrder = idx
    btn.ZIndex = 7; btn.Parent = sidebar
    corner(btn, 8)
    local bPad = Instance.new("UIPadding")
    bPad.PaddingLeft = UDim.new(0,10); bPad.Parent = btn
    tabBtns[tab.n] = btn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1,0,1,0)
    page.BackgroundTransparency = 1; page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = C.accent
    page.CanvasSize = UDim2.new(0,0,0,0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = (tab.n == "Aimbot")
    page.ZIndex = 7; page.Parent = content
    pages[tab.n] = page

    local pl = Instance.new("UIListLayout")
    pl.SortOrder = Enum.SortOrder.LayoutOrder
    pl.Padding = UDim.new(0,4); pl.Parent = page
    local pp = Instance.new("UIPadding")
    pp.PaddingLeft = UDim.new(0,12); pp.PaddingRight = UDim.new(0,12)
    pp.PaddingTop = UDim.new(0,12); pp.Parent = page

    btn.MouseButton1Click:Connect(function()
        currentTab = tab.n
        for n, b in pairs(tabBtns) do
            b.BackgroundTransparency = n==tab.n and 0 or 1
            b.BackgroundColor3 = C.accent2
            if n~=tab.n then b.BackgroundTransparency=1 end
            b.TextColor3 = n==tab.n and C.white or C.sub
        end
        for n, pg in pairs(pages) do pg.Visible=(n==tab.n) end
    end)
end
-- set default
tabBtns["Aimbot"].BackgroundTransparency = 0
tabBtns["Aimbot"].BackgroundColor3 = C.accent2
tabBtns["Aimbot"].TextColor3 = C.white

-- ================================================
--  SECTION TITLE
-- ================================================
local function mkTitle(page, txt, order)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,32); f.BackgroundTransparency = 1
    f.LayoutOrder = order; f.ZIndex = 8; f.Parent = page
    local l = Instance.new("TextLabel")
    l.Text = txt; l.Size = UDim2.new(1,0,1,0)
    l.BackgroundTransparency = 1; l.TextColor3 = C.white
    l.Font = Enum.Font.GothamBold; l.TextSize = 15
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 8; l.Parent = f
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1,0,0,1); line.Position = UDim2.new(0,0,1,-1)
    line.BackgroundColor3 = C.accent2; line.BorderSizePixel = 0
    line.ZIndex = 8; line.Parent = f
end

-- ================================================
--  TOGGLE
-- ================================================
local function mkToggle(page, txt, sub, order)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,0,0, sub and 52 or 46)
    row.BackgroundColor3 = C.row
    row.BorderSizePixel = 0; row.LayoutOrder = order; row.ZIndex = 8; row.Parent = page
    corner(row, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Text = txt; lbl.Size = UDim2.new(0.7,0,0,22)
    lbl.Position = UDim2.new(0,12,0,sub and 4 or 0)
    lbl.AnchorPoint = sub and Vector2.new(0,0) or Vector2.new(0,0.5)
    if not sub then lbl.Position = UDim2.new(0,12,0.5,-11) end
    lbl.BackgroundTransparency = 1; lbl.TextColor3 = C.text
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 9; lbl.Parent = row

    if sub then
        local sl = Instance.new("TextLabel")
        sl.Text = sub; sl.Size = UDim2.new(0.8,0,0,16)
        sl.Position = UDim2.new(0,12,0,26)
        sl.BackgroundTransparency = 1; sl.TextColor3 = C.sub
        sl.Font = Enum.Font.Gotham; sl.TextSize = 10
        sl.TextXAlignment = Enum.TextXAlignment.Left; sl.ZIndex = 9; sl.Parent = row
    end

    -- Pill
    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0,44,0,22); pill.Position = UDim2.new(1,-54,0.5,-11)
    pill.BackgroundColor3 = C.pillOff; pill.BorderSizePixel = 0
    pill.ZIndex = 9; pill.Parent = row
    corner(pill, 11)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0,16,0,16); knob.Position = UDim2.new(0,3,0.5,-8)
    knob.BackgroundColor3 = C.sub; knob.BorderSizePixel = 0
    knob.ZIndex = 10; knob.Parent = pill
    corner(knob, 8)

    local active = false
    local hit = Instance.new("TextButton")
    hit.Size = UDim2.new(1,0,1,0); hit.BackgroundTransparency = 1
    hit.Text = ""; hit.ZIndex = 11; hit.Parent = row

    local function setOn(s)
        active = s
        TweenService:Create(knob, TweenInfo.new(0.13), {
            Position = s and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8),
            BackgroundColor3 = s and C.white or C.sub
        }):Play()
        TweenService:Create(pill, TweenInfo.new(0.13), {
            BackgroundColor3 = s and C.accent or C.pillOff
        }):Play()
    end

    hit.MouseButton1Click:Connect(function() setOn(not active) end)
    return hit, function() return active end, setOn
end

-- ================================================
--  SLIDER
-- ================================================
local function mkSlider(page, txt, mn, mx, def, order)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,0,0,60)
    row.BackgroundColor3 = C.row
    row.BorderSizePixel = 0; row.LayoutOrder = order; row.ZIndex = 8; row.Parent = page
    corner(row, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Text = txt; lbl.Size = UDim2.new(0.65,0,0,20)
    lbl.Position = UDim2.new(0,12,0,8)
    lbl.BackgroundTransparency = 1; lbl.TextColor3 = C.text
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 9; lbl.Parent = row

    local valL = Instance.new("TextLabel")
    valL.Text = tostring(def); valL.Size = UDim2.new(0.3,0,0,20)
    valL.Position = UDim2.new(0.67,0,0,8)
    valL.BackgroundTransparency = 1; valL.TextColor3 = C.accent
    valL.Font = Enum.Font.GothamBold; valL.TextSize = 13
    valL.TextXAlignment = Enum.TextXAlignment.Right; valL.ZIndex = 9; valL.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1,-24,0,5); track.Position = UDim2.new(0,12,0,36)
    track.BackgroundColor3 = Color3.fromRGB(36,24,56)
    track.BorderSizePixel = 0; track.ZIndex = 9; track.Parent = row
    corner(track, 3)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((def-mn)/(mx-mn),0,1,0)
    fill.BackgroundColor3 = C.accent
    fill.BorderSizePixel = 0; fill.ZIndex = 10; fill.Parent = track
    corner(fill, 3)

    local tknob = Instance.new("Frame")
    tknob.Size = UDim2.new(0,13,0,13)
    tknob.Position = UDim2.new((def-mn)/(mx-mn),0,0.5,-6.5)
    tknob.BackgroundColor3 = C.white
    tknob.BorderSizePixel = 0; tknob.ZIndex = 11; tknob.Parent = track
    corner(tknob, 7)

    local value = def; local sd = false
    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or
           i.UserInputType==Enum.UserInputType.Touch then sd=true end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or
           i.UserInputType==Enum.UserInputType.Touch then sd=false end
    end)
    UIS.InputChanged:Connect(function(i)
        if sd then
            local rel=math.clamp((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
            value=math.floor(mn+(mx-mn)*rel)
            fill.Size=UDim2.new(rel,0,1,0)
            tknob.Position=UDim2.new(rel,0,0.5,-6.5)
            valL.Text=tostring(value)
        end
    end)
    return function() return value end
end

-- ================================================
--  ACTION BUTTON
-- ================================================
local function mkButton(page, txt, order, cb)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,44)
    btn.BackgroundColor3 = C.accent2
    btn.TextColor3 = C.white; btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13; btn.Text = txt
    btn.BorderSizePixel = 0; btn.LayoutOrder = order; btn.ZIndex = 8; btn.Parent = page
    corner(btn, 8)
    if cb then btn.MouseButton1Click:Connect(cb) end
    return btn
end

-- ================================================
--  BUILD: AIMBOT TAB
-- ================================================
local ap = pages["Aimbot"]
mkTitle(ap, "Aimbot", 1)
local _,aimbotOn,aimbotSet = mkToggle(ap,"Aimbot","Smooth lock onto nearest enemy head",2)
local _,showFovOn,_        = mkToggle(ap,"Show FOV Circle","Show aim radius ring on screen",3)
local getFov               = mkSlider(ap,"FOV Radius",20,500,150,4)
local getSmooth            = mkSlider(ap,"Smoothness  (1=instant  100=soft)",1,100,40,5)
mkTitle(ap,"Triggerbot",6)
local _,trigOn,_           = mkToggle(ap,"Triggerbot","Auto fire when aim on target",7)
local _,predOn,_           = mkToggle(ap,"Movement Prediction","Lead shots based on enemy velocity",8)
local getPredStr           = mkSlider(ap,"Prediction Strength",0,20,5,9)

-- ================================================
--  BUILD: SILENT TAB
-- ================================================
local sp2 = pages["Silent"]
mkTitle(sp2,"Silent Aim",1)
local _,silentOn,silentSet = mkToggle(sp2,"Silent Aim","Redirect bullet toward nearest head",2)
local _,visChkOn,_         = mkToggle(sp2,"Visibility Check","Only target visible enemies",3)
local _,hlTargOn,_         = mkToggle(sp2,"Highlight Target","Glow on currently locked target",4)
local getSilFov            = mkSlider(sp2,"Silent FOV",20,400,120,5)
mkTitle(sp2,"Hitsounds",6)
local _,hitsoundOn,_       = mkToggle(sp2,"Hitsound","Play sound on successful hit",7)
mkTitle(sp2,"Hitlog",8)
local _,hitlogOn,_         = mkToggle(sp2,"Hit Notifications","Show hit/kill notification on screen",9)

-- ================================================
--  BUILD: WEAPON TAB
-- ================================================
local wp2 = pages["Weapon"]
mkTitle(wp2,"Weapon Mods",1)
local _,noReloadOn,_  = mkToggle(wp2,"No Reload","Remove reload animation/delay",2)
local _,autoFireOn,_  = mkToggle(wp2,"Auto Fire","Automatically fire when aiming",3)
local _,spinOn,_      = mkToggle(wp2,"Spinbot","Rapidly rotate character",4)
local _,noRecoilOn,_  = mkToggle(wp2,"No Recoil","Remove weapon recoil",5)
local _,rapidOn,_     = mkToggle(wp2,"Rapid Fire","Increase fire rate",6)

-- ================================================
--  BUILD: VISUALS TAB
-- ================================================
local vp2 = pages["Visuals"]
mkTitle(vp2,"ESP",1)
local _,espOn,espSet       = mkToggle(vp2,"ESP Highlight","Glow outline on all enemies",2)
local _,chamsOn,_          = mkToggle(vp2,"Chams Fill","Fill enemy model with color",3)
local _,nameOn,_           = mkToggle(vp2,"Name Tags","Show player names",4)
local _,distOn,_           = mkToggle(vp2,"Distance ESP","Show distance to each player",5)
local _,tracerOn,_         = mkToggle(vp2,"Tracers","Draw line from bottom to enemy",6)
mkTitle(vp2,"World Visuals",7)
local _,fbOn,_             = mkToggle(vp2,"Fullbright","Max brightness, remove shadows",8)
local _,noFogOn,_          = mkToggle(vp2,"No Fog","Remove all map fog",9)
local _,crossOn,_          = mkToggle(vp2,"Crosshair Dot","Show center dot on screen",10)
local _,noBlurOn,_         = mkToggle(vp2,"No Motion Blur","Remove motion blur",11)
local _,thirdOn,_          = mkToggle(vp2,"Third Person","Switch to third person view",12)

-- ================================================
--  BUILD: MOVEMENT TAB
-- ================================================
local mp2 = pages["Movement"]
mkTitle(mp2,"Movement",1)
local _,speedOn,_          = mkToggle(mp2,"Speed Boost","Increase walk speed",2)
local getWalk              = mkSlider(mp2,"Walk Speed",16,250,85,3)
local _,flyOn,flySet       = mkToggle(mp2,"Fly","Fly freely (WASD+Space+Shift)",4)
local getFlySpd            = mkSlider(mp2,"Fly Speed",10,200,60,5)
local _,noclipOn,_         = mkToggle(mp2,"Noclip","Walk through all walls",6)
local _,bhopOn,_           = mkToggle(mp2,"Bunny Hop","Auto jump continuously",7)
local _,infJOn,_           = mkToggle(mp2,"Infinite Jump","Jump again mid-air",8)
local _,antiVoidOn,_       = mkToggle(mp2,"Anti-Void","Teleport back if falling too low",9)
mkTitle(mp2,"Teleport",10)
mkButton(mp2,"Teleport to Spawn",11,function()
    if workspace:FindFirstChild("SpawnLocation") then
        rootPart.CFrame=workspace.SpawnLocation.CFrame+Vector3.new(0,5,0)
    end
end)
mkButton(mp2,"Set Waypoint Here",12,function()
    waypoint=rootPart.Position
end)
mkButton(mp2,"Go to Waypoint",13,function()
    if waypoint then rootPart.CFrame=CFrame.new(waypoint) end
end)

-- Player list
mkTitle(mp2,"TP to Player",14)
local function buildTPList()
    for _,ch in pairs(mp2:GetChildren()) do
        if ch.LayoutOrder>=20 then ch:Destroy() end
    end
    local i=20
    for _,p in pairs(Players:GetPlayers()) do
        if p~=lp then
            mkButton(mp2,"→ "..p.Name,i,function()
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    rootPart.CFrame=p.Character.HumanoidRootPart.CFrame+Vector3.new(3,0,0)
                end
            end)
            i=i+1
        end
    end
end
buildTPList()
mkButton(mp2,"Refresh Player List",15,buildTPList)

-- ================================================
--  BUILD: WORLD TAB
-- ================================================
local wrp = pages["World"]
mkTitle(wrp,"Lighting",1)
local _,fbWOn,_    = mkToggle(wrp,"Fullbright",nil,2)
local _,noFgOn,_   = mkToggle(wrp,"No Fog",nil,3)
local _,noBlOn,_   = mkToggle(wrp,"No Blur",nil,4)
local getTime      = mkSlider(wrp,"Time of Day",0,24,14,5)
local _,timeOn,_   = mkToggle(wrp,"Apply Custom Time",nil,6)
mkTitle(wrp,"Physics",7)
local _,noGravOn,_ = mkToggle(wrp,"No Gravity","Set workspace gravity to near zero",8)

-- ================================================
--  BUILD: MISC TAB
-- ================================================
local xp = pages["Misc"]
mkTitle(xp,"Utility",1)
local _,afkOn,_       = mkToggle(xp,"Anti-AFK","Prevent kick for being idle",2)
local _,autoRespOn,_  = mkToggle(xp,"Auto Respawn","Instantly click respawn on death",3)
local _,insKeyOn,_    = mkToggle(xp,"INSERT Toggle","Press INSERT to show/hide menu",4)
mkTitle(xp,"Info",5)
local infoLbl = Instance.new("TextLabel")
infoLbl.Text="Built for [FPS] Flick by Groundwork\nSniper FFA arena — 8 players per server\nAuthor: @Primejtsu"
infoLbl.Size=UDim2.new(1,0,0,70); infoLbl.BackgroundColor3=C.row
infoLbl.TextColor3=C.sub; infoLbl.Font=Enum.Font.Gotham; infoLbl.TextSize=11
infoLbl.TextXAlignment=Enum.TextXAlignment.Left
infoLbl.TextYAlignment=Enum.TextYAlignment.Top
infoLbl.BorderSizePixel=0; infoLbl.LayoutOrder=6; infoLbl.ZIndex=8
infoLbl.Parent=xp; corner(infoLbl,8)
local infoPad=Instance.new("UIPadding"); infoPad.PaddingLeft=UDim.new(0,10)
infoPad.PaddingTop=UDim.new(0,8); infoPad.Parent=infoLbl

-- ================================================
--  FOV RING
-- ================================================
local fovRing = Instance.new("Frame")
fovRing.BackgroundTransparency = 1; fovRing.BorderSizePixel = 0
fovRing.ZIndex = 20; fovRing.Visible = false; fovRing.Parent = gui
corner(fovRing, 999)
local fovSt = Instance.new("UIStroke")
fovSt.Thickness = 1.5; fovSt.Color = C.accent; fovSt.Parent = fovRing

-- Crosshair dot
local cdot = Instance.new("Frame")
cdot.Size = UDim2.new(0,6,0,6); cdot.BackgroundColor3 = C.accent
cdot.BorderSizePixel = 0; cdot.ZIndex = 20; cdot.Visible = false; cdot.Parent = gui
corner(cdot, 3)

-- Hit notification label
local hitLabel = Instance.new("TextLabel")
hitLabel.Size = UDim2.new(0,200,0,30); hitLabel.Position = UDim2.new(0.5,-100,0.35,-15)
hitLabel.BackgroundTransparency = 1; hitLabel.TextColor3 = C.green
hitLabel.Font = Enum.Font.GothamBold; hitLabel.TextSize = 16
hitLabel.Text = ""; hitLabel.ZIndex = 25; hitLabel.Parent = gui

-- ================================================
--  ESP LOGIC
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
            hl.FillColor=Color3.fromRGB(220,40,40)
            hl.OutlineColor=C.white
            hl.FillTransparency=chamsOn() and 0.5 or 1
            hl.OutlineTransparency=0
            hl.Adornee=p.Character; hl.Parent=p.Character
            highlights[p]=hl
        end
    end
    Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function(char)
            task.wait(0.1)
            if espOn() then
                local hl=Instance.new("Highlight")
                hl.FillColor=Color3.fromRGB(220,40,40)
                hl.OutlineColor=C.white
                hl.FillTransparency=chamsOn() and 0.5 or 1
                hl.OutlineTransparency=0
                hl.Adornee=char; hl.Parent=char
                highlights[p]=hl
            end
        end)
    end)
end

-- ================================================
--  FLY LOGIC
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
--  WINDOW CONTROLS
-- ================================================
closeBtn.MouseButton1Click:Connect(function()
    win.Visible=false
end)
minBtn.MouseButton1Click:Connect(function()
    isMinimized=not isMinimized
    if isMinimized then
        TweenService:Create(win,TweenInfo.new(0.2),{Size=UDim2.new(0,660,0,44)}):Play()
        minBtn.Text="+"
    else
        TweenService:Create(win,TweenInfo.new(0.2),{Size=UDim2.new(0,660,0,430)}):Play()
        minBtn.Text="_"
    end
end)
hideBtn.MouseButton1Click:Connect(function()
    isVisible=not isVisible
    win.Visible=isVisible
end)
UIS.InputBegan:Connect(function(i,gpe)
    if not gpe and i.KeyCode==Enum.KeyCode.Insert then
        isVisible=not isVisible; win.Visible=isVisible
    end
end)

-- ================================================
--  MAIN LOOP
-- ================================================
local prevEspState=false

RunService.Heartbeat:Connect(function(dt)
    rgbHue=(rgbHue+dt*0.22)%1
    local rgb=Color3.fromHSV(rgbHue,0.9,1)
    winStroke.Color=rgb
    accentLine.BackgroundColor3=rgb
    fovSt.Color=rgb
    cdot.BackgroundColor3=rgb

    -- Speed
    if speedOn() then humanoid.WalkSpeed=getWalk() else humanoid.WalkSpeed=16 end

    -- Noclip
    if noclipOn() then
        for _,p in pairs(character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=false end
        end
    end

    -- Bhop
    if bhopOn() and humanoid:GetState()==Enum.HumanoidStateType.Freefall then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    -- Inf jump
    if infJOn() and UIS:IsKeyDown(Enum.KeyCode.Space) then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    -- Anti-void
    if antiVoidOn() and rootPart.Position.Y < -80 then
        rootPart.CFrame=CFrame.new(rootPart.Position.X,10,rootPart.Position.Z)
    end

    -- Spinbot
    if spinOn() then
        rootPart.CFrame=rootPart.CFrame*CFrame.Angles(0,math.rad(12),0)
    end

    -- Fullbright
    if fbOn() or fbWOn() then
        Lighting.Brightness=2; Lighting.GlobalShadows=false
        Lighting.Ambient=Color3.fromRGB(255,255,255)
        Lighting.OutdoorAmbient=Color3.fromRGB(255,255,255)
    end

    -- No Fog
    if noFogOn() or noFgOn() then
        Lighting.FogEnd=1e6; Lighting.FogStart=1e6
    end

    -- Time
    if timeOn() then Lighting.ClockTime=getTime() end

    -- No gravity
    if noGravOn() then workspace.Gravity=1 else workspace.Gravity=196.2 end

    -- No blur
    if noBlurOn() or noBlOn() then
        for _,e in pairs(Lighting:GetChildren()) do
            if e:IsA("BlurEffect") or e:IsA("MotionBlurEffect") then e.Enabled=false end
        end
    end

    -- Third person
    if thirdOn() then Camera.CameraType=Enum.CameraType.Follow end

    -- Anti-AFK
    if afkOn() then lp:Move(Vector3.new(0,0,0)) end

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

    -- FOV ring
    local cx=Camera.ViewportSize.X/2
    local cy=Camera.ViewportSize.Y/2
    local fovR=getFov()
    local silFovR=getSilFov()

    if showFovOn() and (aimbotOn() or silentOn()) then
        local r=aimbotOn() and fovR or silFovR
        fovRing.Visible=true
        fovRing.Size=UDim2.new(0,r*2,0,r*2)
        fovRing.Position=UDim2.new(0,cx-r,0,cy-r)
    else
        fovRing.Visible=false
    end

    -- Crosshair dot
    cdot.Visible=crossOn()
    if crossOn() then
        cdot.Position=UDim2.new(0,cx-3,0,cy-3)
    end

    -- AIMBOT
    local center=Vector2.new(cx,cy)
    if aimbotOn() then
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
            -- Prediction
            local targetPos=best.Position
            if predOn() and best.Parent and best.Parent:FindFirstChild("HumanoidRootPart") then
                local vel=best.Parent.HumanoidRootPart.Velocity
                targetPos=targetPos+vel*(getPredStr()/20)
            end
            local s=math.clamp((101-getSmooth())/100,0.01,1)
            Camera.CFrame=Camera.CFrame:Lerp(
                CFrame.new(Camera.CFrame.Position,targetPos),s)
        end
    end

    -- SILENT AIM
    if silentOn() then
        local best,bestDist=nil,silFovR
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
                mousemoverel(sPos.X-cx, sPos.Y-cy)
            end)
        end
    end

    -- ESP
    local eState=espOn()
    if eState~=prevEspState then
        prevEspState=eState
        if eState then doESP() else clearESP() end
    end
end)

-- ================================================
--  RESPAWN
-- ================================================
lp.CharacterAdded:Connect(function(char)
    character=char
    humanoid=char:WaitForChild("Humanoid")
    rootPart=char:WaitForChild("HumanoidRootPart")
    flySet(false)
    clearESP()
    if autoRespOn() then
        task.wait(0.1)
        pcall(function() lp:LoadCharacter() end)
    end
end)

print("[Primejtsu | Flick v7] Ready! Press INSERT to toggle.")
