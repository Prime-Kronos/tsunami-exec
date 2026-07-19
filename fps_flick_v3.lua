-- ================================================
--   FLICK PRO v3 | [FPS] FLICK
--   Author: @Primejtsu
--   GUI: RGB Toggle Button + Animated Menu
--   Fixed: Aimbot, Silent Aim, FOV Circle
--   ESP: Box / Line / Highlight
-- ================================================

local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local UIS           = game:GetService("UserInputService")
local TweenService  = game:GetService("TweenService")
local Camera        = workspace.CurrentCamera

local lp        = Players.LocalPlayer
local character = lp.Character or lp.CharacterAdded:Wait()
local humanoid  = character:WaitForChild("Humanoid")
local rootPart  = character:WaitForChild("HumanoidRootPart")

-- ================================================
--  STATE
-- ================================================
local menuOpen   = false
local minimized  = false
local currentTab = "COMBAT"
local draggingWin  = false
local dragWinStart, winStartPos
local draggingBtn  = false
local dragBtnStart, btnStartPos

local highlights = {}
local espBoxes   = {}
local espLines   = {}
local bv, bg
local rgbHue     = 0

local espMode    = "Highlight" -- "Highlight" / "Box" / "Line"

-- ================================================
--  FOV + AIMBOT DRAWING
-- ================================================
local fovCircle       = Drawing.new("Circle")
fovCircle.Visible     = false
fovCircle.Thickness   = 1.5
fovCircle.Color       = Color3.fromRGB(255,255,255)
fovCircle.Filled      = false
fovCircle.NumSides    = 64

-- ================================================
--  GUI ROOT
-- ================================================
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn   = false
gui.Name           = "FlickProV3"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.Parent         = lp.PlayerGui

-- ================================================
--  RGB TOGGLE BUTTON (draggable)
-- ================================================
local toggleBtn = Instance.new("ImageButton")
toggleBtn.Size            = UDim2.new(0, 58, 0, 58)
toggleBtn.Position        = UDim2.new(0, 20, 0.5, -29)
toggleBtn.BackgroundColor3 = Color3.fromRGB(20,20,28)
toggleBtn.BorderSizePixel = 0
toggleBtn.ZIndex          = 10
toggleBtn.Parent          = gui

local tbCorner = Instance.new("UICorner")
tbCorner.CornerRadius = UDim.new(0, 12)
tbCorner.Parent       = toggleBtn

local tbStroke = Instance.new("UIStroke")
tbStroke.Thickness = 2.5
tbStroke.Color     = Color3.fromRGB(255,80,80)
tbStroke.Parent    = toggleBtn

-- Rabbit logo inside button
local logoLabel = Instance.new("TextLabel")
logoLabel.Size               = UDim2.new(1,0,1,0)
logoLabel.BackgroundTransparency = 1
logoLabel.TextColor3         = Color3.fromRGB(255,255,255)
logoLabel.Font               = Enum.Font.GothamBold
logoLabel.TextSize           = 26
logoLabel.Text               = "P"
logoLabel.ZIndex             = 11
logoLabel.Parent             = toggleBtn

-- Small author tag under button
local authorTag = Instance.new("TextLabel")
authorTag.Size               = UDim2.new(0, 80, 0, 16)
authorTag.Position           = UDim2.new(0.5, -40, 1, 3)
authorTag.BackgroundTransparency = 1
authorTag.TextColor3         = Color3.fromRGB(160,160,180)
authorTag.Font               = Enum.Font.Gotham
authorTag.TextSize           = 9
authorTag.Text               = "@Primejtsu"
authorTag.ZIndex             = 11
authorTag.Parent             = toggleBtn

-- ================================================
--  MAIN WINDOW
-- ================================================
local win = Instance.new("Frame")
win.Size             = UDim2.new(0, 420, 0, 360)
win.Position         = UDim2.new(0, 90, 0.5, -180)
win.BackgroundColor3 = Color3.fromRGB(13,13,19)
win.BorderSizePixel  = 0
win.Visible          = false
win.ClipsDescendants = true
win.ZIndex           = 5
win.Parent           = gui

local winCorner = Instance.new("UICorner")
winCorner.CornerRadius = UDim.new(0,14)
winCorner.Parent       = win

local winStroke = Instance.new("UIStroke")
winStroke.Thickness = 1.8
winStroke.Color     = Color3.fromRGB(90,60,200)
winStroke.Parent    = win

-- ===== TITLEBAR =====
local bar = Instance.new("Frame")
bar.Size             = UDim2.new(1,0,0,42)
bar.BackgroundColor3 = Color3.fromRGB(18,18,28)
bar.BorderSizePixel  = 0
bar.ZIndex           = 6
bar.Parent           = win

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(0,14)
barCorner.Parent       = bar

local barFix = Instance.new("Frame")
barFix.Size            = UDim2.new(1,0,0.5,0)
barFix.Position        = UDim2.new(0,0,0.5,0)
barFix.BackgroundColor3 = Color3.fromRGB(18,18,28)
barFix.BorderSizePixel = 0
barFix.ZIndex          = 6
barFix.Parent          = bar

local accentLine = Instance.new("Frame")
accentLine.Size            = UDim2.new(1,0,0,2)
accentLine.Position        = UDim2.new(0,0,1,-2)
accentLine.BackgroundColor3 = Color3.fromRGB(90,60,200)
accentLine.BorderSizePixel = 0
accentLine.ZIndex          = 7
accentLine.Parent          = bar

local titleLbl = Instance.new("TextLabel")
titleLbl.Text            = "FLICK PRO  v3   |   Author: @Primejtsu"
titleLbl.Size            = UDim2.new(0.72,0,1,0)
titleLbl.Position        = UDim2.new(0,12,0,0)
titleLbl.BackgroundTransparency = 1
titleLbl.TextColor3      = Color3.fromRGB(255,255,255)
titleLbl.Font            = Enum.Font.GothamBold
titleLbl.TextSize        = 12
titleLbl.TextXAlignment  = Enum.TextXAlignment.Left
titleLbl.ZIndex          = 7
titleLbl.Parent          = bar

local function mkHBtn(xOff, bg_, txt)
    local b = Instance.new("TextButton")
    b.Size             = UDim2.new(0,26,0,22)
    b.Position         = UDim2.new(1,xOff,0.5,-11)
    b.BackgroundColor3 = bg_
    b.TextColor3       = Color3.fromRGB(255,255,255)
    b.Font             = Enum.Font.GothamBold
    b.TextSize         = 13
    b.Text             = txt
    b.BorderSizePixel  = 0
    b.ZIndex           = 8
    b.Parent           = bar
    local c = Instance.new("UICorner"); c.CornerRadius=UDim.new(0,6); c.Parent=b
    return b
end
local minBtn   = mkHBtn(-58, Color3.fromRGB(200,150,0), "_")
local closeBtn = mkHBtn(-28, Color3.fromRGB(200,50,50),  "X")

-- ===== TABS =====
local tabRow = Instance.new("Frame")
tabRow.Size            = UDim2.new(1,0,0,34)
tabRow.Position        = UDim2.new(0,0,0,42)
tabRow.BackgroundColor3 = Color3.fromRGB(16,16,24)
tabRow.BorderSizePixel = 0
tabRow.ZIndex          = 6
tabRow.Parent          = win

local tLayout = Instance.new("UIListLayout")
tLayout.FillDirection       = Enum.FillDirection.Horizontal
tLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
tLayout.SortOrder           = Enum.SortOrder.LayoutOrder
tLayout.Padding             = UDim.new(0,3)
tLayout.Parent              = tabRow

local tPad = Instance.new("UIPadding")
tPad.PaddingLeft = UDim.new(0,8)
tPad.Parent      = tabRow

local contentArea = Instance.new("Frame")
contentArea.Size            = UDim2.new(1,0,1,-76)
contentArea.Position        = UDim2.new(0,0,0,76)
contentArea.BackgroundTransparency = 1
contentArea.ZIndex          = 6
contentArea.Parent          = win

local TABS     = {"COMBAT","MOVEMENT","VISUAL","MISC"}
local tabBtns  = {}
local tabPages = {}

for i, name in ipairs(TABS) do
    local tb = Instance.new("TextButton")
    tb.Size             = UDim2.new(0,90,1,-6)
    tb.BackgroundColor3 = Color3.fromRGB(22,22,34)
    tb.TextColor3       = Color3.fromRGB(120,120,150)
    tb.Font             = Enum.Font.GothamBold
    tb.TextSize         = 11
    tb.Text             = name
    tb.BorderSizePixel  = 0
    tb.LayoutOrder      = i
    tb.ZIndex           = 7
    tb.Parent           = tabRow
    local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,7);c.Parent=tb
    tabBtns[name] = tb

    local page = Instance.new("ScrollingFrame")
    page.Size                  = UDim2.new(1,0,1,0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel       = 0
    page.ScrollBarThickness    = 3
    page.ScrollBarImageColor3  = Color3.fromRGB(90,60,200)
    page.Visible               = (name=="COMBAT")
    page.ZIndex                = 6
    page.Parent                = contentArea
    tabPages[name] = page

    local l = Instance.new("UIListLayout")
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding   = UDim.new(0,5)
    l.Parent    = page

    local p = Instance.new("UIPadding")
    p.PaddingLeft  = UDim.new(0,10)
    p.PaddingRight = UDim.new(0,10)
    p.PaddingTop   = UDim.new(0,8)
    p.Parent       = page
end

local function selectTab(name)
    currentTab = name
    for n,btn in pairs(tabBtns) do
        btn.BackgroundColor3 = n==name and Color3.fromRGB(90,60,200) or Color3.fromRGB(22,22,34)
        btn.TextColor3       = n==name and Color3.fromRGB(255,255,255) or Color3.fromRGB(120,120,150)
        tabPages[n].Visible  = (n==name)
    end
end
selectTab("COMBAT")
for _,name in ipairs(TABS) do
    tabBtns[name].MouseButton1Click:Connect(function() selectTab(name) end)
end

-- ================================================
--  TOGGLE FACTORY (custom pill)
-- ================================================
local function makeToggle(page, txt, order)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1,0,0,48)
    row.BackgroundColor3 = Color3.fromRGB(20,20,30)
    row.BorderSizePixel  = 0
    row.LayoutOrder      = order
    row.ZIndex           = 7
    row.Parent           = page
    local rc=Instance.new("UICorner");rc.CornerRadius=UDim.new(0,9);rc.Parent=row

    local lbl = Instance.new("TextLabel")
    lbl.Text            = txt
    lbl.Size            = UDim2.new(0.62,0,1,0)
    lbl.Position        = UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3      = Color3.fromRGB(210,210,228)
    lbl.Font            = Enum.Font.GothamBold
    lbl.TextSize        = 12
    lbl.TextXAlignment  = Enum.TextXAlignment.Left
    lbl.ZIndex          = 8
    lbl.Parent          = row

    local pill = Instance.new("Frame")
    pill.Size            = UDim2.new(0,50,0,26)
    pill.Position        = UDim2.new(1,-62,0.5,-13)
    pill.BackgroundColor3 = Color3.fromRGB(40,40,55)
    pill.BorderSizePixel = 0
    pill.ZIndex          = 8
    pill.Parent          = row
    local pc=Instance.new("UICorner");pc.CornerRadius=UDim.new(0,13);pc.Parent=pill

    local knob = Instance.new("Frame")
    knob.Size            = UDim2.new(0,20,0,20)
    knob.Position        = UDim2.new(0,3,0.5,-10)
    knob.BackgroundColor3 = Color3.fromRGB(150,150,170)
    knob.BorderSizePixel = 0
    knob.ZIndex          = 9
    knob.Parent          = pill
    local kc=Instance.new("UICorner");kc.CornerRadius=UDim.new(1,0);kc.Parent=knob

    local active = false
    local hitbox = Instance.new("TextButton")
    hitbox.Size               = UDim2.new(1,0,1,0)
    hitbox.BackgroundTransparency = 1
    hitbox.Text               = ""
    hitbox.ZIndex             = 10
    hitbox.Parent             = row

    local statusDot = Instance.new("Frame")
    statusDot.Size            = UDim2.new(0,7,0,7)
    statusDot.Position        = UDim2.new(0,0,0.5,-3.5)
    statusDot.BackgroundColor3 = Color3.fromRGB(180,50,50)
    statusDot.BorderSizePixel = 0
    statusDot.ZIndex          = 8
    statusDot.Parent          = row
    local sd=Instance.new("UICorner");sd.CornerRadius=UDim.new(1,0);sd.Parent=statusDot

    local function setOn(state)
        active = state
        local kGoal   = state and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10)
        local pColor  = state and Color3.fromRGB(90,60,200) or Color3.fromRGB(40,40,55)
        local kColor  = state and Color3.fromRGB(255,255,255) or Color3.fromRGB(150,150,170)
        local dotClr  = state and Color3.fromRGB(80,220,120) or Color3.fromRGB(180,50,50)
        TweenService:Create(knob, TweenInfo.new(0.15),{Position=kGoal,BackgroundColor3=kColor}):Play()
        TweenService:Create(pill, TweenInfo.new(0.15),{BackgroundColor3=pColor}):Play()
        TweenService:Create(statusDot,TweenInfo.new(0.15),{BackgroundColor3=dotClr}):Play()
    end

    hitbox.MouseButton1Click:Connect(function() setOn(not active) end)
    return hitbox, function() return active end, setOn
end

-- ================================================
--  SLIDER FACTORY
-- ================================================
local function makeSlider(page, txt, mn, mx, def, order)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1,0,0,56)
    row.BackgroundColor3 = Color3.fromRGB(20,20,30)
    row.BorderSizePixel  = 0
    row.LayoutOrder      = order
    row.ZIndex           = 7
    row.Parent           = page
    local rc=Instance.new("UICorner");rc.CornerRadius=UDim.new(0,9);rc.Parent=row

    local lbl=Instance.new("TextLabel")
    lbl.Text=txt; lbl.Size=UDim2.new(0.6,0,0,24); lbl.Position=UDim2.new(0,12,0,4)
    lbl.BackgroundTransparency=1; lbl.TextColor3=Color3.fromRGB(210,210,228)
    lbl.Font=Enum.Font.GothamBold; lbl.TextSize=12
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=8; lbl.Parent=row

    local valLbl=Instance.new("TextLabel")
    valLbl.Text=tostring(def); valLbl.Size=UDim2.new(0.35,0,0,24)
    valLbl.Position=UDim2.new(0.62,0,0,4); valLbl.BackgroundTransparency=1
    valLbl.TextColor3=Color3.fromRGB(90,60,200); valLbl.Font=Enum.Font.GothamBold
    valLbl.TextSize=12; valLbl.TextXAlignment=Enum.TextXAlignment.Right
    valLbl.ZIndex=8; valLbl.Parent=row

    local track=Instance.new("Frame")
    track.Size=UDim2.new(1,-24,0,6); track.Position=UDim2.new(0,12,0,36)
    track.BackgroundColor3=Color3.fromRGB(38,38,52); track.BorderSizePixel=0
    track.ZIndex=8; track.Parent=row
    local tc=Instance.new("UICorner");tc.CornerRadius=UDim.new(0,3);tc.Parent=track

    local fill=Instance.new("Frame")
    fill.Size=UDim2.new((def-mn)/(mx-mn),0,1,0)
    fill.BackgroundColor3=Color3.fromRGB(90,60,200)
    fill.BorderSizePixel=0; fill.ZIndex=9; fill.Parent=track
    local fc=Instance.new("UICorner");fc.CornerRadius=UDim.new(0,3);fc.Parent=fill

    local value=def; local dragging=false

    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or
           i.UserInputType==Enum.UserInputType.Touch then dragging=true end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or
           i.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging then
            local rel=math.clamp((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
            value=math.floor(mn+(mx-mn)*rel)
            fill.Size=UDim2.new(rel,0,1,0)
            valLbl.Text=tostring(value)
        end
    end)
    return function() return value end
end

-- ================================================
--  DROPDOWN FACTORY (ESP mode)
-- ================================================
local function makeDropdown(page, txt, options, order)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,48); row.BackgroundColor3=Color3.fromRGB(20,20,30)
    row.BorderSizePixel=0; row.LayoutOrder=order; row.ZIndex=7; row.Parent=page
    local rc=Instance.new("UICorner");rc.CornerRadius=UDim.new(0,9);rc.Parent=row

    local lbl=Instance.new("TextLabel")
    lbl.Text=txt; lbl.Size=UDim2.new(0.45,0,1,0); lbl.Position=UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency=1; lbl.TextColor3=Color3.fromRGB(210,210,228)
    lbl.Font=Enum.Font.GothamBold; lbl.TextSize=12
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=8; lbl.Parent=row

    local selected=options[1]
    local selBtn=Instance.new("TextButton")
    selBtn.Size=UDim2.new(0,130,0,30); selBtn.Position=UDim2.new(1,-140,0.5,-15)
    selBtn.BackgroundColor3=Color3.fromRGB(90,60,200); selBtn.TextColor3=Color3.fromRGB(255,255,255)
    selBtn.Font=Enum.Font.GothamBold; selBtn.TextSize=11; selBtn.Text=selected
    selBtn.BorderSizePixel=0; selBtn.ZIndex=8; selBtn.Parent=row
    local sc=Instance.new("UICorner");sc.CornerRadius=UDim.new(0,7);sc.Parent=selBtn

    local idx=1
    selBtn.MouseButton1Click:Connect(function()
        idx=idx%#options+1
        selected=options[idx]
        selBtn.Text=selected
    end)
    return function() return selected end
end

-- ================================================
--  BUILD TABS
-- ================================================
-- COMBAT
local cp=tabPages["COMBAT"]
local _,aimbotOn,aimbotSet   = makeToggle(cp,"Aimbot",1)
local _,silentOn,silentSet   = makeToggle(cp,"Silent Aim",2)
local getFov                  = makeSlider(cp,"FOV Radius",30,400,150,3)
local getSmooth               = makeSlider(cp,"Aim Smooth (1=fast 10=soft)",1,10,3,4)

-- MOVEMENT
local mp=tabPages["MOVEMENT"]
local _,speedOn,speedSet     = makeToggle(mp,"Speed Boost",1)
local _,flyOn,flySet         = makeToggle(mp,"Fly",2)
local _,noclipOn,noclipSet   = makeToggle(mp,"Noclip",3)
local _,bhopOn,bhopSet       = makeToggle(mp,"Bunny Hop",4)
local _,infJumpOn,infJumpSet = makeToggle(mp,"Infinite Jump",5)
local getWalkSpd              = makeSlider(mp,"Walk Speed",16,250,85,6)
local getFlySpd               = makeSlider(mp,"Fly Speed",20,200,65,7)

-- VISUAL
local vp=tabPages["VISUAL"]
local _,espOn,espSet         = makeToggle(vp,"ESP",1)
local _,chamsOn,chamsSet     = makeToggle(vp,"Chams Fill",2)
local getEspMode              = makeDropdown(vp,"ESP Mode",{"Highlight","Box","Line"},3)

-- MISC
local xp=tabPages["MISC"]
local _,afkOn,afkSet         = makeToggle(xp,"Anti-AFK",1)
local _,showFovOn,showFovSet  = makeToggle(xp,"Show FOV Circle",2)

-- ================================================
--  ESP LOGIC
-- ================================================
local function clearAllESP()
    for _,h in pairs(highlights) do pcall(function() h:Destroy() end) end
    highlights={}
    for _,b in pairs(espBoxes) do pcall(function() b:Remove() end) end
    espBoxes={}
    for _,l in pairs(espLines) do pcall(function() l:Remove() end) end
    espLines={}
end

local function applyHighlight(p)
    if p==lp then return end
    local function apply(char)
        if highlights[p] then pcall(function() highlights[p]:Destroy() end) end
        local hl=Instance.new("Highlight")
        hl.FillColor=chamsOn() and Color3.fromRGB(255,50,50) or Color3.fromRGB(0,0,0)
        hl.OutlineColor=Color3.fromRGB(255,255,255)
        hl.FillTransparency=chamsOn() and 0.5 or 1
        hl.OutlineTransparency=0
        hl.Adornee=char; hl.Parent=char
        highlights[p]=hl
    end
    if p.Character then apply(p.Character) end
    p.CharacterAdded:Connect(apply)
end

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
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
end

-- ================================================
--  SILENT AIM — override bullet target
-- ================================================
local oldIndex
local function enableSilentAim()
    oldIndex = oldIndex or hookmetamethod(game,"__index",function(self,key)
        if key=="Hit" or key=="Target" then
            for _,p in pairs(Players:GetPlayers()) do
                if p~=lp and p.Character then
                    local head=p.Character:FindFirstChild("Head")
                    if head then
                        local sPos,onScreen=Camera:WorldToScreenPoint(head.Position)
                        if onScreen then
                            if key=="Hit" then
                                return CFrame.new(head.Position)
                            else
                                return head
                            end
                        end
                    end
                end
            end
        end
        return oldIndex(self,key)
    end)
end
local function disableSilentAim()
    -- hookmetamethod persists; toggling aimbot handles it
end

-- ================================================
--  BUTTON CONNECTIONS
-- ================================================
espOn -- connected below in loop

flyOn -- connected below
local flyConn
local function onFlyToggle()
    if flyOn() then startFly() else stopFly() end
end

silentOn -- handled in loop

afkOn -- handled in loop

-- ================================================
--  OPEN/CLOSE ANIMATION
-- ================================================
local function openMenu()
    menuOpen=true
    win.Visible=true
    win.Size=UDim2.new(0,420,0,0)
    TweenService:Create(win,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
        {Size=UDim2.new(0,420,0,360)}):Play()
end

local function closeMenu()
    menuOpen=false
    TweenService:Create(win,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
        {Size=UDim2.new(0,420,0,0)}):Play()
    task.delay(0.22,function() win.Visible=false end)
end

toggleBtn.MouseButton1Click:Connect(function()
    if menuOpen then closeMenu() else openMenu() end
end)

closeBtn.MouseButton1Click:Connect(function()
    closeMenu()
end)

minBtn.MouseButton1Click:Connect(function()
    minimized=not minimized
    if minimized then
        TweenService:Create(win,TweenInfo.new(0.2),{Size=UDim2.new(0,420,0,42)}):Play()
        minBtn.Text="+"
    else
        TweenService:Create(win,TweenInfo.new(0.2),{Size=UDim2.new(0,420,0,360)}):Play()
        minBtn.Text="_"
    end
end)

-- ================================================
--  DRAG WINDOW
-- ================================================
bar.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or
       i.UserInputType==Enum.UserInputType.Touch then
        draggingWin=true; dragWinStart=i.Position; winStartPos=win.Position
    end
end)

-- ================================================
--  DRAG TOGGLE BUTTON
-- ================================================
local btnDragging=false; local btnDragStart,btnPos0
toggleBtn.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or
       i.UserInputType==Enum.UserInputType.Touch then
        btnDragging=true; btnDragStart=i.Position; btnPos0=toggleBtn.Position
    end
end)

UIS.InputChanged:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseMovement or
       i.UserInputType==Enum.UserInputType.Touch then
        if draggingWin and dragWinStart then
            local d=i.Position-dragWinStart
            win.Position=UDim2.new(winStartPos.X.Scale,winStartPos.X.Offset+d.X,
                winStartPos.Y.Scale,winStartPos.Y.Offset+d.Y)
        end
        if btnDragging and btnDragStart then
            local d=i.Position-btnDragStart
            toggleBtn.Position=UDim2.new(btnPos0.X.Scale,btnPos0.X.Offset+d.X,
                btnPos0.Y.Scale,btnPos0.Y.Offset+d.Y)
        end
    end
end)

UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or
       i.UserInputType==Enum.UserInputType.Touch then
        draggingWin=false; btnDragging=false
    end
end)

-- ================================================
--  MAIN LOOP
-- ================================================
local prevFov,prevEspMode=0,""

RunService.Heartbeat:Connect(function(dt)
    -- RGB stroke on toggle button
    rgbHue=(rgbHue+dt*0.4)%1
    local rgb=Color3.fromHSV(rgbHue,1,1)
    tbStroke.Color=rgb
    accentLine.BackgroundColor3=rgb
    winStroke.Color=rgb

    -- Noclip
    if noclipOn() then
        for _,p in pairs(character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=false end
        end
    end

    -- Speed
    humanoid.WalkSpeed=speedOn() and getWalkSpd() or 16

    -- BHop
    if bhopOn() and humanoid:GetState()==Enum.HumanoidStateType.Freefall then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    -- Inf Jump
    if infJumpOn() and UIS:IsKeyDown(Enum.KeyCode.Space) then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    -- FOV circle
    local fovR=getFov()
    local center=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
    fovCircle.Position=center
    fovCircle.Radius=fovR
    fovCircle.Visible=(aimbotOn() or silentOn()) and showFovOn()
    fovCircle.Color=rgb

    -- Aimbot (fixed smooth lerp)
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
            local s=math.clamp(getSmooth()/10,0.02,0.5)
            local goal=CFrame.new(Camera.CFrame.Position,best.Position)
            Camera.CFrame=Camera.CFrame:Lerp(goal,s)
        end
    end

    -- Silent Aim
    if silentOn() then
        enableSilentAim()
    end

    -- Fly
    if flyOn() and bv and bg then
        local spd=getFlySpd()
        local dir=Vector3.new(0,0,0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir=dir+Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir=dir-Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir=dir-Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir=dir+Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space)     then dir=dir+Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir=dir-Vector3.new(0,1,0) end
        bv.Velocity=dir*spd; bg.CFrame=Camera.CFrame
    end

    -- ESP update
    local eMode=getEspMode()
    if espOn() then
        if eMode~=prevEspMode then
            clearAllESP(); prevEspMode=eMode
        end
        if eMode=="Highlight" then
            for _,p in pairs(Players:GetPlayers()) do
                if not highlights[p] then applyHighlight(p) end
            end
        elseif eMode=="Box" or eMode=="Line" then
            -- update drawings each frame
            local existing={}
            for _,p in pairs(Players:GetPlayers()) do
                if p~=lp and p.Character then
                    existing[p]=true
                    local root=p.Character:FindFirstChild("HumanoidRootPart")
                    local head=p.Character:FindFirstChild("Head")
                    if root then
                        local sPos,onScreen=Camera:WorldToScreenPoint(root.Position)
                        if onScreen then
                            if eMode=="Box" then
                                if not espBoxes[p] then
                                    local sq=Drawing.new("Square")
                                    sq.Thickness=2; sq.Color=Color3.fromRGB(255,50,50)
                                    sq.Filled=false; sq.Visible=true
                                    espBoxes[p]=sq
                                end
                                local topPos=head and Camera:WorldToScreenPoint(head.Position+Vector3.new(0,0.5,0)) or sPos
                                local botPos=Camera:WorldToScreenPoint(root.Position-Vector3.new(0,2.5,0))
                                local w=math.abs(topPos.X-botPos.X)+40
                                local h=math.abs(topPos.Y-botPos.Y)+10
                                espBoxes[p].Position=Vector2.new(sPos.X-w/2,math.min(topPos.Y,botPos.Y)-5)
                                espBoxes[p].Size=Vector2.new(w,h)
                            elseif eMode=="Line" then
                                if not espLines[p] then
                                    local ln=Drawing.new("Line")
                                    ln.Thickness=2; ln.Color=Color3.fromRGB(255,50,50)
                                    ln.Visible=true
                                    espLines[p]=ln
                                end
                                espLines[p].From=Vector2.new(center.X,Camera.ViewportSize.Y)
                                espLines[p].To=Vector2.new(sPos.X,sPos.Y)
                            end
                        else
                            if espBoxes[p] then espBoxes[p].Visible=false end
                            if espLines[p] then espLines[p].Visible=false end
                        end
                    end
                end
            end
            -- clean disconnected players
            for p,_ in pairs(espBoxes) do
                if not existing[p] then
                    espBoxes[p]:Remove(); espBoxes[p]=nil
                end
            end
            for p,_ in pairs(espLines) do
                if not existing[p] then
                    espLines[p]:Remove(); espLines[p]=nil
                end
            end
        end
    else
        if prevEspMode~="" then clearAllESP(); prevEspMode="" end
    end

    -- Anti-AFK
    if afkOn() then
        lp:Move(Vector3.new(0,0,0))
    end

    -- Fly toggle
    if flyOn() and not bv then startFly()
    elseif not flyOn() and bv then stopFly() end
end)

-- ================================================
--  RESPAWN
-- ================================================
lp.CharacterAdded:Connect(function(char)
    character=char
    humanoid=char:WaitForChild("Humanoid")
    rootPart=char:WaitForChild("HumanoidRootPart")
    flySet(false); noclipSet(false); speedSet(false)
    bhopSet(false); infJumpSet(false)
    clearAllESP()
end)

print("[FLICK PRO v3] by @Primejtsu — Loaded!")
