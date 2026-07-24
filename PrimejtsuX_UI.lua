-- ================================================
--   Primejtsu X | Project
--   Custom GUI Library - Pulse Hub Style
--   Creator: @Primejtsu
-- ================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Stats            = game:GetService("Stats")
local LP               = Players.LocalPlayer

-- ================================================
-- HELPERS
-- ================================================
local function tw(o, p, t, s)
    TweenService:Create(o, TweenInfo.new(t or 0.15, s or Enum.EasingStyle.Quad), p):Play()
end
local function corner(p, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = p; return c
end
local function stroke(p, col, t)
    local s = Instance.new("UIStroke"); s.Color = col or Color3.fromRGB(60,60,80)
    s.Thickness = t or 1; s.Parent = p; return s
end
local function newFrame(parent, size, pos, color, transp)
    local f = Instance.new("Frame")
    f.Size = size; f.Position = pos or UDim2.new(0,0,0,0)
    f.BackgroundColor3 = color or Color3.fromRGB(30,30,40)
    f.BackgroundTransparency = transp or 0
    f.BorderSizePixel = 0; f.Parent = parent; return f
end
local function newLabel(parent, text, size, color, font, pos, sz, xa)
    local l = Instance.new("TextLabel")
    l.Text = text; l.TextSize = size or 13
    l.TextColor3 = color or Color3.fromRGB(240,240,255)
    l.Font = font or Enum.Font.GothamBold
    l.BackgroundTransparency = 1
    l.Position = pos or UDim2.new(0,0,0,0)
    l.Size = sz or UDim2.new(1,0,1,0)
    l.TextXAlignment = xa or Enum.TextXAlignment.Left
    l.Parent = parent; return l
end

-- ================================================
-- SCREEN GUI
-- ================================================
local SG = Instance.new("ScreenGui")
SG.Name = "PrimejtsuX_UI"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.Parent = LP.PlayerGui

-- ================================================
-- MAIN WINDOW
-- ================================================
local Main = newFrame(SG, UDim2.new(0,580,0,400), UDim2.new(0.5,-290,0.5,-200), Color3.fromRGB(28,28,35))
corner(Main, 12)
stroke(Main, Color3.fromRGB(50,50,65), 1)

-- Drag
local drag, dragStart, startPos = false, nil, nil
Main.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        drag = true; dragStart = i.Position; startPos = Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if drag and (i.UserInputType == Enum.UserInputType.MouseMovement
    or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then drag = false end
end)

-- ================================================
-- TOP BAR
-- ================================================
local TopBar = newFrame(Main, UDim2.new(1,0,0,44), UDim2.new(0,0,0,0), Color3.fromRGB(22,22,30))
corner(TopBar, 12)
-- Fix bottom corners
newFrame(TopBar, UDim2.new(1,0,0,12), UDim2.new(0,0,1,-12), Color3.fromRGB(22,22,30))

-- Logo (красный фон + буква P)
local LogoBG = newFrame(TopBar, UDim2.new(0,30,0,30), UDim2.new(0,8,0.5,-15), Color3.fromRGB(200,30,50))
corner(LogoBG, 8)
newLabel(LogoBG, "P", 16, Color3.fromRGB(255,255,255), Enum.Font.GothamBold,
    UDim2.new(0,0,0,0), UDim2.new(1,0,1,0), Enum.TextXAlignment.Center)

-- Title
newLabel(TopBar, "Primejtsu X | Project", 14, Color3.fromRGB(230,225,255), Enum.Font.GothamBold,
    UDim2.new(0,46,0,0), UDim2.new(0,200,1,0))

-- Tabs top (General)
local topTabsFrame = newFrame(TopBar, UDim2.new(0,120,0,28), UDim2.new(0.5,-60,0.5,-14), Color3.fromRGB(18,18,25))
corner(topTabsFrame, 8)

local genBtn = Instance.new("TextButton")
genBtn.Size = UDim2.new(0.5,0,1,0)
genBtn.BackgroundColor3 = Color3.fromRGB(200,30,50)
genBtn.Text = "General"; genBtn.TextColor3 = Color3.fromRGB(255,255,255)
genBtn.Font = Enum.Font.GothamBold; genBtn.TextSize = 11
genBtn.BorderSizePixel = 0; genBtn.Parent = topTabsFrame
corner(genBtn, 7)

local uisBtn = Instance.new("TextButton")
uisBtn.Size = UDim2.new(0.5,0,1,0)
uisBtn.Position = UDim2.new(0.5,0,0,0)
uisBtn.BackgroundTransparency = 1
uisBtn.Text = "UIS"; uisBtn.TextColor3 = Color3.fromRGB(160,155,195)
uisBtn.Font = Enum.Font.GothamBold; uisBtn.TextSize = 11
uisBtn.BorderSizePixel = 0; uisBtn.Parent = topTabsFrame

-- FPS counter top right
local fpsLabel = newLabel(TopBar, "FPS: --", 11, Color3.fromRGB(150,145,185), Enum.Font.GothamBold,
    UDim2.new(1,-100,0,0), UDim2.new(0,60,1,0), Enum.TextXAlignment.Right)

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0,24,0,24)
closeBtn.Position = UDim2.new(1,-32,0.5,-12)
closeBtn.BackgroundColor3 = Color3.fromRGB(200,30,50)
closeBtn.Text = "×"; closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 16
closeBtn.BorderSizePixel = 0; closeBtn.Parent = TopBar
corner(closeBtn, 6)

local guiOpen = true
closeBtn.MouseButton1Click:Connect(function()
    guiOpen = not guiOpen
    if guiOpen then
        Main.Visible = true
        tw(Main, {Size=UDim2.new(0,580,0,400)}, 0.25, Enum.EasingStyle.Back)
    else
        tw(Main, {Size=UDim2.new(0,580,0,0)}, 0.2)
        task.delay(0.21, function() Main.Visible=false end)
    end
end)

-- FPS update
local fpsTimer = 0
local fpsSamples = {}
RunService.Heartbeat:Connect(function(dt)
    fpsTimer = fpsTimer + dt
    table.insert(fpsSamples, 1/dt)
    if #fpsSamples > 20 then table.remove(fpsSamples, 1) end
    if fpsTimer >= 0.5 then
        fpsTimer = 0
        local sum = 0
        for _,v in pairs(fpsSamples) do sum = sum + v end
        local fps = math.floor(sum / #fpsSamples)
        fpsLabel.Text = "FPS: " .. fps
        if fps >= 50 then fpsLabel.TextColor3 = Color3.fromRGB(80,220,100)
        elseif fps >= 30 then fpsLabel.TextColor3 = Color3.fromRGB(220,180,50)
        else fpsLabel.TextColor3 = Color3.fromRGB(220,60,60) end
    end
end)

-- ================================================
-- SIDEBAR (левая панель)
-- ================================================
local Sidebar = newFrame(Main, UDim2.new(0,130,1,-44), UDim2.new(0,0,0,44), Color3.fromRGB(22,22,30))
newFrame(Sidebar, UDim2.new(0,10,1,0), UDim2.new(1,-10,0,0), Color3.fromRGB(22,22,30))

-- Sidebar divider
local sDiv = newFrame(Main, UDim2.new(0,1,1,-44), UDim2.new(0,130,0,44), Color3.fromRGB(40,40,55))

local tabList = newFrame(Sidebar, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), Color3.fromRGB(0,0,0), 1)
local tLayout = Instance.new("UIListLayout"); tLayout.Padding=UDim.new(0,2); tLayout.Parent=tabList
local tPad = Instance.new("UIPadding")
tPad.PaddingTop=UDim.new(0,8); tPad.PaddingLeft=UDim.new(0,8); tPad.PaddingRight=UDim.new(0,8)
tPad.Parent=tabList

-- ================================================
-- CONTENT AREA (2 колонки как Pulse Hub)
-- ================================================
local ContentBG = newFrame(Main, UDim2.new(1,-130,1,-44), UDim2.new(0,131,0,44), Color3.fromRGB(0,0,0), 1)

local Col1 = Instance.new("ScrollingFrame")
Col1.Size = UDim2.new(0.5,-1,1,-8); Col1.Position = UDim2.new(0,0,0,4)
Col1.BackgroundTransparency=1; Col1.ScrollBarThickness=2
Col1.ScrollBarImageColor3=Color3.fromRGB(200,30,50); Col1.BorderSizePixel=0
Col1.Parent = ContentBG
local C1L = Instance.new("UIListLayout"); C1L.Padding=UDim.new(0,4); C1L.Parent=Col1
local C1P = Instance.new("UIPadding"); C1P.PaddingLeft=UDim.new(0,6); C1P.PaddingRight=UDim.new(0,4); C1P.Parent=Col1
C1L:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Col1.CanvasSize = UDim2.new(0,0,0,C1L.AbsoluteContentSize.Y+8)
end)

local ColDiv = newFrame(ContentBG, UDim2.new(0,1,1,-8), UDim2.new(0.5,0,0,4), Color3.fromRGB(40,40,55))

local Col2 = Instance.new("ScrollingFrame")
Col2.Size = UDim2.new(0.5,-1,1,-8); Col2.Position = UDim2.new(0.5,1,0,4)
Col2.BackgroundTransparency=1; Col2.ScrollBarThickness=2
Col2.ScrollBarImageColor3=Color3.fromRGB(200,30,50); Col2.BorderSizePixel=0
Col2.Parent = ContentBG
local C2L = Instance.new("UIListLayout"); C2L.Padding=UDim.new(0,4); C2L.Parent=Col2
local C2P = Instance.new("UIPadding"); C2P.PaddingLeft=UDim.new(0,4); C2P.PaddingRight=UDim.new(0,6); C2P.Parent=Col2
C2L:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Col2.CanvasSize = UDim2.new(0,0,0,C2L.AbsoluteContentSize.Y+8)
end)

-- Pages system
local Pages = {}
local sideButtons = {}

local function showPage(name)
    for n, p in pairs(Pages) do
        p.col1.Visible = (n==name)
        p.col2.Visible = (n==name)
    end
end

local function newPage(name)
    local p = {col1={}, col2={}}

    local f1 = Instance.new("Frame")
    f1.Size=UDim2.new(1,0,0,0); f1.BackgroundTransparency=1; f1.Visible=false; f1.Parent=Col1
    local l1=Instance.new("UIListLayout"); l1.Padding=UDim.new(0,4); l1.Parent=f1
    l1:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        f1.Size=UDim2.new(1,0,0,l1.AbsoluteContentSize.Y)
        Col1.CanvasSize=UDim2.new(0,0,0,l1.AbsoluteContentSize.Y+8)
    end)

    local f2 = Instance.new("Frame")
    f2.Size=UDim2.new(1,0,0,0); f2.BackgroundTransparency=1; f2.Visible=false; f2.Parent=Col2
    local l2=Instance.new("UIListLayout"); l2.Padding=UDim.new(0,4); l2.Parent=f2
    l2:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        f2.Size=UDim2.new(1,0,0,l2.AbsoluteContentSize.Y)
        Col2.CanvasSize=UDim2.new(0,0,0,l2.AbsoluteContentSize.Y+8)
    end)

    p.col1 = f1; p.col2 = f2
    Pages[name] = p
    return p
end

-- ================================================
-- SIDEBAR TAB MAKER
-- ================================================
local function makeSideTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,36)
    btn.BackgroundColor3 = Color3.fromRGB(28,28,38)
    btn.Text = (icon and icon.."  " or "") .. name
    btn.TextColor3 = Color3.fromRGB(140,135,175)
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 12
    btn.BorderSizePixel = 0; btn.Parent = tabList
    corner(btn, 8)
    local pad = Instance.new("UIPadding"); pad.PaddingLeft=UDim.new(0,10); pad.Parent=btn

    -- Red accent line left
    local accent = newFrame(btn, UDim2.new(0,3,0.6,0), UDim2.new(0,0,0.2,0), Color3.fromRGB(200,30,50))
    accent.Visible = false; corner(accent, 2)

    table.insert(sideButtons, {btn=btn, accent=accent})
    btn.MouseButton1Click:Connect(function()
        for _,b in pairs(sideButtons) do
            tw(b.btn,{BackgroundColor3=Color3.fromRGB(28,28,38),TextColor3=Color3.fromRGB(140,135,175)},0.12)
            b.accent.Visible=false
        end
        tw(btn,{BackgroundColor3=Color3.fromRGB(35,28,42),TextColor3=Color3.fromRGB(255,255,255)},0.12)
        accent.Visible=true
        showPage(name)
    end)
    return btn
end

-- ================================================
-- ELEMENT MAKERS
-- ================================================
local function makeSection(parent, name)
    local f = newFrame(parent, UDim2.new(1,0,0,24), nil, Color3.fromRGB(0,0,0), 1)
    local line = newFrame(f, UDim2.new(0,3,0.7,0), UDim2.new(0,0,0.15,0), Color3.fromRGB(200,30,50))
    corner(line,2)
    newLabel(f, name, 12, Color3.fromRGB(220,215,255), Enum.Font.GothamBold,
        UDim2.new(0,10,0,0), UDim2.new(1,-10,1,0))
end

local function makeToggle(parent, name, default, cb)
    local row = newFrame(parent, UDim2.new(1,0,0,38), nil, Color3.fromRGB(33,33,42))
    corner(row, 7)

    newLabel(row, name, 11, Color3.fromRGB(210,205,240), Enum.Font.GothamBold,
        UDim2.new(0,10,0,0), UDim2.new(1,-56,1,0))

    local bg = newFrame(row, UDim2.new(0,38,0,20), UDim2.new(1,-46,0.5,-10),
        default and Color3.fromRGB(80,200,120) or Color3.fromRGB(55,55,72))
    corner(bg, 10)
    local dot = newFrame(bg, UDim2.new(0,16,0,16),
        default and UDim2.new(0,20,0.5,-8) or UDim2.new(0,2,0.5,-8),
        Color3.fromRGB(255,255,255))
    corner(dot, 8)

    local val = default or false
    local hit = Instance.new("TextButton"); hit.Size=UDim2.new(1,0,1,0)
    hit.BackgroundTransparency=1; hit.Text=""; hit.Parent=row

    -- Hover effect
    row.MouseEnter:Connect(function() tw(row,{BackgroundColor3=Color3.fromRGB(40,40,52)},0.1) end)
    row.MouseLeave:Connect(function() tw(row,{BackgroundColor3=Color3.fromRGB(33,33,42)},0.1) end)

    hit.MouseButton1Click:Connect(function()
        val = not val
        tw(bg,{BackgroundColor3=val and Color3.fromRGB(80,200,120) or Color3.fromRGB(55,55,72)},0.15)
        tw(dot,{Position=val and UDim2.new(0,20,0.5,-8) or UDim2.new(0,2,0.5,-8)},0.15)
        -- Click animation
        tw(row,{BackgroundColor3=Color3.fromRGB(50,45,65)},0.07)
        task.delay(0.07,function() tw(row,{BackgroundColor3=Color3.fromRGB(33,33,42)},0.1) end)
        if cb then cb(val) end
    end)
    return {SetValue=function(v)
        val=v
        tw(bg,{BackgroundColor3=v and Color3.fromRGB(80,200,120) or Color3.fromRGB(55,55,72)},0.15)
        tw(dot,{Position=v and UDim2.new(0,20,0.5,-8) or UDim2.new(0,2,0.5,-8)},0.15)
        if cb then cb(v) end
    end}
end

local function makeSlider(parent, name, min, max, default, inc, cb)
    local row = newFrame(parent, UDim2.new(1,0,0,52), nil, Color3.fromRGB(33,33,42))
    corner(row, 7)

    newLabel(row, name, 11, Color3.fromRGB(210,205,240), Enum.Font.GothamBold,
        UDim2.new(0,10,0,4), UDim2.new(1,-70,0,22))
    local valL = newLabel(row, tostring(default), 11, Color3.fromRGB(200,30,50), Enum.Font.GothamBold,
        UDim2.new(1,-60,0,4), UDim2.new(0,52,0,22), Enum.TextXAlignment.Right)

    local track = newFrame(row, UDim2.new(1,-20,0,5), UDim2.new(0,10,1,-16), Color3.fromRGB(44,44,58))
    corner(track, 3)
    local fill = newFrame(track, UDim2.new((default-min)/(max-min),0,1,0), nil, Color3.fromRGB(200,30,50))
    corner(fill, 3)
    local dot = newFrame(fill, UDim2.new(0,12,0,12), UDim2.new(0,-6,0.5,-6), Color3.fromRGB(255,255,255))
    corner(dot, 6)

    local val=default; local sliding=false
    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sliding and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local a=track.AbsolutePosition; local s=track.AbsoluteSize
            local p=math.clamp((i.Position.X-a.X)/s.X,0,1)
            val=math.clamp(math.round((min+(max-min)*p)/inc)*inc,min,max)
            fill.Size=UDim2.new((val-min)/(max-min),0,1,0)
            valL.Text=tostring(val)
            if cb then cb(val) end
        end
    end)
end

local function makeDropdown(parent, name, options, default, cb)
    local row = newFrame(parent, UDim2.new(1,0,0,38), nil, Color3.fromRGB(33,33,42))
    row.ClipsDescendants=false; corner(row,7)
    newLabel(row, name, 11, Color3.fromRGB(210,205,240), Enum.Font.GothamBold,
        UDim2.new(0,10,0,0), UDim2.new(0.5,0,1,0))

    local sel = default or options[1]
    local dBtn = Instance.new("TextButton")
    dBtn.Size=UDim2.new(0,90,0,24); dBtn.Position=UDim2.new(1,-98,0.5,-12)
    dBtn.BackgroundColor3=Color3.fromRGB(22,22,30)
    dBtn.Text=sel.."  ▾"; dBtn.TextColor3=Color3.fromRGB(200,195,235)
    dBtn.Font=Enum.Font.Gotham; dBtn.TextSize=10; dBtn.Parent=row
    corner(dBtn,5); stroke(dBtn,Color3.fromRGB(50,50,68),1)

    local dFrame = newFrame(row, UDim2.new(0,90,0,#options*26+6), UDim2.new(1,-98,1,4), Color3.fromRGB(22,22,30))
    dFrame.Visible=false; dFrame.ZIndex=50; dFrame.ClipsDescendants=false
    corner(dFrame,6); stroke(dFrame,Color3.fromRGB(50,50,68),1)
    local dl=Instance.new("UIListLayout"); dl.Padding=UDim.new(0,2); dl.Parent=dFrame
    local dp=Instance.new("UIPadding"); dp.PaddingTop=UDim.new(0,3); dp.PaddingLeft=UDim.new(0,3); dp.PaddingRight=UDim.new(0,3); dp.Parent=dFrame

    for _,opt in pairs(options) do
        local ob=Instance.new("TextButton")
        ob.Size=UDim2.new(1,0,0,22); ob.BackgroundColor3=Color3.fromRGB(28,28,38)
        ob.Text=opt; ob.TextColor3=Color3.fromRGB(200,195,235)
        ob.Font=Enum.Font.Gotham; ob.TextSize=10; ob.ZIndex=51; ob.Parent=dFrame
        corner(ob,4)
        ob.MouseButton1Click:Connect(function()
            sel=opt; dBtn.Text=opt.."  ▾"; dFrame.Visible=false
            tw(row,{Size=UDim2.new(1,0,0,38)},0.1)
            if cb then cb(opt) end
        end)
    end
    local open=false
    dBtn.MouseButton1Click:Connect(function()
        open=not open; dFrame.Visible=open
        tw(row,{Size=UDim2.new(1,0,0,open and 38+#options*26+10 or 38)},0.15)
    end)
    if cb then cb(sel) end
end

local function makeButton(parent, name, cb)
    local btn = Instance.new("TextButton")
    btn.Size=UDim2.new(1,0,0,34)
    btn.BackgroundColor3=Color3.fromRGB(200,30,50)
    btn.Text=name; btn.TextColor3=Color3.fromRGB(255,255,255)
    btn.Font=Enum.Font.GothamBold; btn.TextSize=11
    btn.BorderSizePixel=0; btn.Parent=parent
    corner(btn,7)
    btn.MouseButton1Click:Connect(function()
        tw(btn,{BackgroundColor3=Color3.fromRGB(240,60,80),Size=UDim2.new(1,-4,0,30)},0.08)
        task.delay(0.12,function()
            tw(btn,{BackgroundColor3=Color3.fromRGB(200,30,50),Size=UDim2.new(1,0,0,34)},0.1)
        end)
        if cb then cb() end
    end)
    btn.MouseEnter:Connect(function() tw(btn,{BackgroundColor3=Color3.fromRGB(220,45,65)},0.1) end)
    btn.MouseLeave:Connect(function() tw(btn,{BackgroundColor3=Color3.fromRGB(200,30,50)},0.1) end)
end

-- ================================================
-- MINI TOGGLE BUTTON (выдвигается)
-- ================================================
local miniBtn = newFrame(SG, UDim2.new(0,36,0,36), UDim2.new(0,-36,0.5,-18), Color3.fromRGB(200,30,50))
corner(miniBtn, 10)
stroke(miniBtn, Color3.fromRGB(240,80,100), 1.5)

-- P logo
newLabel(miniBtn, "P", 18, Color3.fromRGB(255,255,255), Enum.Font.GothamBold)

local miniBtnHit = Instance.new("TextButton")
miniBtnHit.Size=UDim2.new(1,0,1,0); miniBtnHit.BackgroundTransparency=1
miniBtnHit.Text=""; miniBtnHit.Parent=miniBtn

-- Slide in animation on start
task.wait(0.5)
tw(miniBtn, {Position=UDim2.new(0,8,0.5,-18)}, 0.4, Enum.EasingStyle.Back)

miniBtnHit.MouseButton1Click:Connect(function()
    -- Click animation
    tw(miniBtn, {Size=UDim2.new(0,30,0,30), Position=UDim2.new(0,8,0.5,-15)}, 0.08)
    task.delay(0.1, function()
        tw(miniBtn, {Size=UDim2.new(0,36,0,36), Position=UDim2.new(0,8,0.5,-18)}, 0.12, Enum.EasingStyle.Back)
    end)
    task.wait(0.1)

    guiOpen = not guiOpen
    if guiOpen then
        Main.Visible = true
        tw(Main, {Size=UDim2.new(0,580,0,400)}, 0.3, Enum.EasingStyle.Back)
    else
        tw(Main, {Size=UDim2.new(0,580,0,0)}, 0.2)
        task.delay(0.21, function() Main.Visible=false end)
    end
end)

-- ================================================
-- BUILD TABS
-- ================================================

-- Main
makeSideTab("Main", "⊞")
local mainP = newPage("Main")
makeSection(mainP.col1, "ESP")
makeToggle(mainP.col1, "Enable ESP", false, function(v) end)
makeToggle(mainP.col1, "Name ESP", false, function(v) end)
makeToggle(mainP.col1, "Health Bar", false, function(v) end)
makeDropdown(mainP.col1, "ESP Mode", {"Highlight","Box","Tracer"}, "Highlight", function(v) end)
makeDropdown(mainP.col1, "ESP Color", {"Red","Green","Blue","Yellow","Cyan","White"}, "Red", function(v) end)
makeSlider(mainP.col1, "Transparency", 0, 10, 5, 1, function(v) end)

makeSection(mainP.col2, "Movement")
makeToggle(mainP.col2, "Noclip", false, function(v) end)
makeToggle(mainP.col2, "Infinite Jump", false, function(v) end)
makeToggle(mainP.col2, "Speed Hack", false, function(v) end)
makeSlider(mainP.col2, "Walk Speed", 16, 200, 40, 1, function(v) end)
makeToggle(mainP.col2, "Fly", false, function(v) end)
makeSlider(mainP.col2, "Fly Speed", 10, 200, 50, 5, function(v) end)

-- Combat
makeSideTab("Combat", "⊕")
local combatP = newPage("Combat")
makeSection(combatP.col1, "Aimbot")
makeToggle(combatP.col1, "Enable Aimbot", false, function(v) end)
makeToggle(combatP.col1, "FOV Circle", false, function(v) end)
makeSlider(combatP.col1, "FOV Radius", 30, 500, 150, 5, function(v) end)
makeSlider(combatP.col1, "Smoothness", 1, 100, 15, 1, function(v) end)
makeDropdown(combatP.col1, "Aim Part", {"Head","HumanoidRootPart","UpperTorso"}, "Head", function(v) end)

makeSection(combatP.col2, "AI Helper")
makeToggle(combatP.col2, "AI Dodge", false, function(v) end)
makeSlider(combatP.col2, "Dodge Distance", 1, 10, 3, 1, function(v) end)

-- Visuals
makeSideTab("Visuals", "◈")
local visP = newPage("Visuals")
makeSection(visP.col1, "World")
makeToggle(visP.col1, "Fullbright", false, function(v)
    local L=game:GetService("Lighting")
    L.Brightness=v and 10 or 1; L.GlobalShadows=not v
    L.Ambient=v and Color3.fromRGB(255,255,255) or Color3.fromRGB(127,127,127)
end)
makeSection(visP.col2, "Player")
makeToggle(visP.col2, "Show FPS", true, function(v) fpsLabel.Visible=v end)

-- Misc
makeSideTab("Misc", "⊙")
local miscP = newPage("Misc")
makeSection(miscP.col1, "Utility")
makeToggle(miscP.col1, "Anti-AFK", false, function(v)
    if v then
        LP.Idled:Connect(function()
            local vu=game:GetService("VirtualUser")
            vu:Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(0.1)
            vu:Button1Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    end
end)
makeButton(miscP.col1, "Rejoin", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
end)
makeButton(miscP.col1, "Respawn", function()
    if LP.Character then
        local h=LP.Character:FindFirstChild("Humanoid"); if h then h.Health=0 end
    end
end)

-- Settings
makeSideTab("Settings", "⚙")
local setP = newPage("Settings")
makeSection(setP.col1, "GUI Settings")
makeToggle(setP.col1, "Mini Button Visible", true, function(v) miniBtn.Visible=v end)
makeSection(setP.col2, "About")
newLabel(setP.col2, "Creator: @Primejtsu", 11, Color3.fromRGB(180,175,215), Enum.Font.Gotham,
    UDim2.new(0,0,0,0), UDim2.new(1,0,0,22)).Parent = setP.col2
newLabel(setP.col2, "Version: v1.0", 11, Color3.fromRGB(140,135,175), Enum.Font.Gotham,
    UDim2.new(0,0,0,0), UDim2.new(1,0,0,22)).Parent = setP.col2

-- Show first page
showPage("Main")
tw(sideButtons[1].btn, {BackgroundColor3=Color3.fromRGB(35,28,42),TextColor3=Color3.fromRGB(255,255,255)}, 0)
sideButtons[1].accent.Visible = true

print("[Primejtsu X] Custom UI Loaded!")
