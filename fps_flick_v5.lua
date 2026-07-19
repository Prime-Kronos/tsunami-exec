-- ================================================
--   FLICK PRO v5 | [FPS] FLICK
--   Author: @Primejtsu
--   Logo ID: 71693879665391
--   Delta Compatible: YES
-- ================================================

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera       = workspace.CurrentCamera

local lp        = Players.LocalPlayer
local character = lp.Character or lp.CharacterAdded:Wait()
local humanoid  = character:WaitForChild("Humanoid")
local rootPart  = character:WaitForChild("HumanoidRootPart")

-- ================================================
--  STATE
-- ================================================
local menuOpen    = false
local minimized   = false
local highlights  = {}
local bv, bg
local rgbHue      = 0
local draggingWin = false
local dragWinStart, winStartPos
local btnDragStart, btnPos0
local btnMoved    = false

-- ================================================
--  GUI ROOT
-- ================================================
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn    = false
gui.Name            = "FlickProV5"
gui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset  = true
gui.Parent          = lp.PlayerGui

-- ================================================
--  TOGGLE BUTTON (с логотипом кролика)
-- ================================================
local toggleFrame = Instance.new("Frame")
toggleFrame.Size             = UDim2.new(0, 62, 0, 62)
toggleFrame.Position         = UDim2.new(0, 20, 0.5, -31)
toggleFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
toggleFrame.BorderSizePixel  = 0
toggleFrame.ZIndex           = 10
toggleFrame.Parent           = gui
local tfc = Instance.new("UICorner"); tfc.CornerRadius = UDim.new(0,14); tfc.Parent = toggleFrame

local tbStroke = Instance.new("UIStroke")
tbStroke.Thickness = 2.5
tbStroke.Color     = Color3.fromRGB(255,80,80)
tbStroke.Parent    = toggleFrame

-- Логотип кролика
local logoImg = Instance.new("ImageLabel")
logoImg.Size               = UDim2.new(0, 46, 0, 46)
logoImg.Position           = UDim2.new(0.5, -23, 0.5, -23)
logoImg.BackgroundTransparency = 1
logoImg.Image              = "rbxassetid://71693879665391"
logoImg.ZIndex             = 11
logoImg.Parent             = toggleFrame

-- Кнопка поверх логотипа
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size               = UDim2.new(1,0,1,0)
toggleBtn.BackgroundTransparency = 1
toggleBtn.Text               = ""
toggleBtn.ZIndex             = 12
toggleBtn.Parent             = toggleFrame

local authorTag = Instance.new("TextLabel")
authorTag.Size               = UDim2.new(0,80,0,14)
authorTag.Position           = UDim2.new(0.5,-40,1,4)
authorTag.BackgroundTransparency = 1
authorTag.TextColor3         = Color3.fromRGB(160,160,180)
authorTag.Font               = Enum.Font.Gotham
authorTag.TextSize           = 9
authorTag.Text               = "@Primejtsu"
authorTag.ZIndex             = 11
authorTag.Parent             = toggleFrame

-- ================================================
--  MAIN WINDOW
-- ================================================
local win = Instance.new("Frame")
win.Size             = UDim2.new(0,430,0,380)
win.Position         = UDim2.new(0,92,0.5,-190)
win.BackgroundColor3 = Color3.fromRGB(13,13,19)
win.BorderSizePixel  = 0
win.Visible          = false
win.ClipsDescendants = true
win.ZIndex           = 5
win.Parent           = gui
local wc = Instance.new("UICorner"); wc.CornerRadius=UDim.new(0,14); wc.Parent=win

local winStroke = Instance.new("UIStroke")
winStroke.Thickness = 1.8
winStroke.Color     = Color3.fromRGB(90,60,200)
winStroke.Parent    = win

-- TITLEBAR
local bar = Instance.new("Frame")
bar.Size             = UDim2.new(1,0,0,44)
bar.BackgroundColor3 = Color3.fromRGB(18,18,28)
bar.BorderSizePixel  = 0
bar.ZIndex           = 6
bar.Parent           = win
local brc=Instance.new("UICorner");brc.CornerRadius=UDim.new(0,14);brc.Parent=bar

local barFix=Instance.new("Frame")
barFix.Size=UDim2.new(1,0,0.5,0); barFix.Position=UDim2.new(0,0,0.5,0)
barFix.BackgroundColor3=Color3.fromRGB(18,18,28); barFix.BorderSizePixel=0
barFix.ZIndex=6; barFix.Parent=bar

local accentLine=Instance.new("Frame")
accentLine.Size=UDim2.new(1,0,0,2); accentLine.Position=UDim2.new(0,0,1,-2)
accentLine.BackgroundColor3=Color3.fromRGB(90,60,200)
accentLine.BorderSizePixel=0; accentLine.ZIndex=7; accentLine.Parent=bar

-- Мини лого в заголовке
local miniLogo=Instance.new("ImageLabel")
miniLogo.Size=UDim2.new(0,28,0,28); miniLogo.Position=UDim2.new(0,8,0.5,-14)
miniLogo.BackgroundTransparency=1
miniLogo.Image="rbxassetid://71693879665391"
miniLogo.ZIndex=8; miniLogo.Parent=bar

local titleLbl=Instance.new("TextLabel")
titleLbl.Text="FLICK PRO v5  |  @Primejtsu"
titleLbl.Size=UDim2.new(0.65,0,1,0); titleLbl.Position=UDim2.new(0,42,0,0)
titleLbl.BackgroundTransparency=1; titleLbl.TextColor3=Color3.fromRGB(255,255,255)
titleLbl.Font=Enum.Font.GothamBold; titleLbl.TextSize=12
titleLbl.TextXAlignment=Enum.TextXAlignment.Left
titleLbl.ZIndex=7; titleLbl.Parent=bar

local function mkHBtn(xOff,bgc,txt)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(0,26,0,22); b.Position=UDim2.new(1,xOff,0.5,-11)
    b.BackgroundColor3=bgc; b.TextColor3=Color3.fromRGB(255,255,255)
    b.Font=Enum.Font.GothamBold; b.TextSize=13; b.Text=txt
    b.BorderSizePixel=0; b.ZIndex=8; b.Parent=bar
    local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,6);c.Parent=b
    return b
end
local minBtn   = mkHBtn(-58,Color3.fromRGB(200,150,0),"_")
local closeBtn = mkHBtn(-28,Color3.fromRGB(200,50,50),"X")

-- TABS
local tabRow=Instance.new("Frame")
tabRow.Size=UDim2.new(1,0,0,34); tabRow.Position=UDim2.new(0,0,0,44)
tabRow.BackgroundColor3=Color3.fromRGB(16,16,24)
tabRow.BorderSizePixel=0; tabRow.ZIndex=6; tabRow.Parent=win

local tl=Instance.new("UIListLayout")
tl.FillDirection=Enum.FillDirection.Horizontal
tl.HorizontalAlignment=Enum.HorizontalAlignment.Left
tl.SortOrder=Enum.SortOrder.LayoutOrder
tl.Padding=UDim.new(0,3); tl.Parent=tabRow

local tp=Instance.new("UIPadding"); tp.PaddingLeft=UDim.new(0,8); tp.Parent=tabRow

local contentArea=Instance.new("Frame")
contentArea.Size=UDim2.new(1,0,1,-78); contentArea.Position=UDim2.new(0,0,0,78)
contentArea.BackgroundTransparency=1; contentArea.ZIndex=6; contentArea.Parent=win

local TABS={"COMBAT","MOVEMENT","VISUAL","MISC"}
local tabBtns={}; local tabPages={}

for i,name in ipairs(TABS) do
    local tb=Instance.new("TextButton")
    tb.Size=UDim2.new(0,90,1,-6)
    tb.BackgroundColor3=Color3.fromRGB(22,22,34)
    tb.TextColor3=Color3.fromRGB(120,120,150)
    tb.Font=Enum.Font.GothamBold; tb.TextSize=11; tb.Text=name
    tb.BorderSizePixel=0; tb.LayoutOrder=i; tb.ZIndex=7; tb.Parent=tabRow
    local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,7);c.Parent=tb
    tabBtns[name]=tb

    local page=Instance.new("ScrollingFrame")
    page.Size=UDim2.new(1,0,1,0)
    page.BackgroundTransparency=1; page.BorderSizePixel=0
    page.ScrollBarThickness=3
    page.ScrollBarImageColor3=Color3.fromRGB(90,60,200)
    page.Visible=(name=="COMBAT"); page.ZIndex=6
    page.CanvasSize=UDim2.new(0,0,0,0)
    page.AutomaticCanvasSize=Enum.AutomaticSize.Y
    page.Parent=contentArea
    tabPages[name]=page

    local l=Instance.new("UIListLayout")
    l.SortOrder=Enum.SortOrder.LayoutOrder; l.Padding=UDim.new(0,5); l.Parent=page
    local p=Instance.new("UIPadding")
    p.PaddingLeft=UDim.new(0,10); p.PaddingRight=UDim.new(0,10)
    p.PaddingTop=UDim.new(0,8); p.Parent=page
end

local function selectTab(name)
    for n,btn in pairs(tabBtns) do
        btn.BackgroundColor3=n==name and Color3.fromRGB(90,60,200) or Color3.fromRGB(22,22,34)
        btn.TextColor3=n==name and Color3.fromRGB(255,255,255) or Color3.fromRGB(120,120,150)
        tabPages[n].Visible=(n==name)
    end
end
selectTab("COMBAT")
for _,name in ipairs(TABS) do
    tabBtns[name].MouseButton1Click:Connect(function() selectTab(name) end)
end

-- ================================================
--  TOGGLE FACTORY
-- ================================================
local function makeToggle(page,txt,order)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,48)
    row.BackgroundColor3=Color3.fromRGB(20,20,30)
    row.BorderSizePixel=0; row.LayoutOrder=order; row.ZIndex=7; row.Parent=page
    local rc=Instance.new("UICorner");rc.CornerRadius=UDim.new(0,9);rc.Parent=row

    local dot=Instance.new("Frame")
    dot.Size=UDim2.new(0,7,0,7); dot.Position=UDim2.new(0,8,0.5,-3.5)
    dot.BackgroundColor3=Color3.fromRGB(180,50,50)
    dot.BorderSizePixel=0; dot.ZIndex=8; dot.Parent=row
    local dc=Instance.new("UICorner");dc.CornerRadius=UDim.new(1,0);dc.Parent=dot

    local lbl=Instance.new("TextLabel")
    lbl.Text=txt; lbl.Size=UDim2.new(0.58,0,1,0); lbl.Position=UDim2.new(0,20,0,0)
    lbl.BackgroundTransparency=1; lbl.TextColor3=Color3.fromRGB(210,210,228)
    lbl.Font=Enum.Font.GothamBold; lbl.TextSize=12
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=8; lbl.Parent=row

    local pill=Instance.new("Frame")
    pill.Size=UDim2.new(0,50,0,26); pill.Position=UDim2.new(1,-60,0.5,-13)
    pill.BackgroundColor3=Color3.fromRGB(40,40,55)
    pill.BorderSizePixel=0; pill.ZIndex=8; pill.Parent=row
    local pc=Instance.new("UICorner");pc.CornerRadius=UDim.new(0,13);pc.Parent=pill

    local knob=Instance.new("Frame")
    knob.Size=UDim2.new(0,20,0,20); knob.Position=UDim2.new(0,3,0.5,-10)
    knob.BackgroundColor3=Color3.fromRGB(150,150,170)
    knob.BorderSizePixel=0; knob.ZIndex=9; knob.Parent=pill
    local kc=Instance.new("UICorner");kc.CornerRadius=UDim.new(1,0);kc.Parent=knob

    local active=false
    local hitbox=Instance.new("TextButton")
    hitbox.Size=UDim2.new(1,0,1,0); hitbox.BackgroundTransparency=1
    hitbox.Text=""; hitbox.ZIndex=10; hitbox.Parent=row

    local function setOn(state)
        active=state
        local kGoal=state and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10)
        local pClr=state and Color3.fromRGB(90,60,200) or Color3.fromRGB(40,40,55)
        local kClr=state and Color3.fromRGB(255,255,255) or Color3.fromRGB(150,150,170)
        local dClr=state and Color3.fromRGB(80,220,120) or Color3.fromRGB(180,50,50)
        TweenService:Create(knob,TweenInfo.new(0.15),{Position=kGoal,BackgroundColor3=kClr}):Play()
        TweenService:Create(pill,TweenInfo.new(0.15),{BackgroundColor3=pClr}):Play()
        TweenService:Create(dot,TweenInfo.new(0.15),{BackgroundColor3=dClr}):Play()
    end

    hitbox.MouseButton1Click:Connect(function() setOn(not active) end)
    return hitbox, function() return active end, setOn
end

-- ================================================
--  SLIDER FACTORY
-- ================================================
local function makeSlider(page,txt,mn,mx,def,order)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,56); row.BackgroundColor3=Color3.fromRGB(20,20,30)
    row.BorderSizePixel=0; row.LayoutOrder=order; row.ZIndex=7; row.Parent=page
    local rc=Instance.new("UICorner");rc.CornerRadius=UDim.new(0,9);rc.Parent=row

    local lbl=Instance.new("TextLabel")
    lbl.Text=txt; lbl.Size=UDim2.new(0.65,0,0,24); lbl.Position=UDim2.new(0,12,0,4)
    lbl.BackgroundTransparency=1; lbl.TextColor3=Color3.fromRGB(210,210,228)
    lbl.Font=Enum.Font.GothamBold; lbl.TextSize=11
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=8; lbl.Parent=row

    local valLbl=Instance.new("TextLabel")
    valLbl.Text=tostring(def); valLbl.Size=UDim2.new(0.3,0,0,24)
    valLbl.Position=UDim2.new(0.67,0,0,4); valLbl.BackgroundTransparency=1
    valLbl.TextColor3=Color3.fromRGB(90,60,200); valLbl.Font=Enum.Font.GothamBold
    valLbl.TextSize=12; valLbl.TextXAlignment=Enum.TextXAlignment.Right
    valLbl.ZIndex=8; valLbl.Parent=row

    local track=Instance.new("Frame")
    track.Size=UDim2.new(1,-24,0,6); track.Position=UDim2.new(0,12,0,36)
    track.BackgroundColor3=Color3.fromRGB(38,38,52)
    track.BorderSizePixel=0; track.ZIndex=8; track.Parent=row
    local tc=Instance.new("UICorner");tc.CornerRadius=UDim.new(0,3);tc.Parent=track

    local fill=Instance.new("Frame")
    fill.Size=UDim2.new((def-mn)/(mx-mn),0,1,0)
    fill.BackgroundColor3=Color3.fromRGB(90,60,200)
    fill.BorderSizePixel=0; fill.ZIndex=9; fill.Parent=track
    local fc=Instance.new("UICorner");fc.CornerRadius=UDim.new(0,3);fc.Parent=fill

    local value=def; local sliderDrag=false

    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or
           i.UserInputType==Enum.UserInputType.Touch then sliderDrag=true end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or
           i.UserInputType==Enum.UserInputType.Touch then sliderDrag=false end
    end)
    UIS.InputChanged:Connect(function(i)
        if sliderDrag then
            local rel=math.clamp(
                (i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
            value=math.floor(mn+(mx-mn)*rel)
            fill.Size=UDim2.new(rel,0,1,0)
            valLbl.Text=tostring(value)
        end
    end)
    return function() return value end
end

-- ================================================
--  BUILD TABS
-- ================================================
local cp=tabPages["COMBAT"]
local _,aimbotOn,aimbotSet = makeToggle(cp,"Aimbot",1)
local _,silentOn,silentSet = makeToggle(cp,"Silent Aim",2)
local getFov               = makeSlider(cp,"FOV Radius",30,400,150,3)
local getSmooth            = makeSlider(cp,"Aim Smooth (1=fast 10=soft)",1,10,3,4)

local mp=tabPages["MOVEMENT"]
local _,speedOn,speedSet     = makeToggle(mp,"Speed Boost",1)
local _,flyOn,flySet         = makeToggle(mp,"Fly",2)
local _,noclipOn,noclipSet   = makeToggle(mp,"Noclip",3)
local _,bhopOn,bhopSet       = makeToggle(mp,"Bunny Hop",4)
local _,infJumpOn,infJumpSet = makeToggle(mp,"Infinite Jump",5)
local getWalkSpd             = makeSlider(mp,"Walk Speed",16,250,85,6)
local getFlySpd              = makeSlider(mp,"Fly Speed",20,200,65,7)

local vp=tabPages["VISUAL"]
local _,espOn,espSet       = makeToggle(vp,"ESP Highlight",1)
local _,chamsOn,chamsSet   = makeToggle(vp,"Chams Fill",2)

local xp=tabPages["MISC"]
local _,afkOn,afkSet         = makeToggle(xp,"Anti-AFK",1)
local _,showFovOn,showFovSet = makeToggle(xp,"Show FOV Ring",2)

-- ================================================
--  ESP
-- ================================================
local function clearESP()
    for _,h in pairs(highlights) do pcall(function() h:Destroy() end) end
    highlights={}
end

local espConn
local function enableESP()
    clearESP()
    for _,p in pairs(Players:GetPlayers()) do
        if p~=lp and p.Character then
            local hl=Instance.new("Highlight")
            hl.FillColor=Color3.fromRGB(255,50,50)
            hl.OutlineColor=Color3.fromRGB(255,255,255)
            hl.FillTransparency=chamsOn() and 0.45 or 1
            hl.OutlineTransparency=0
            hl.Adornee=p.Character; hl.Parent=p.Character
            highlights[p]=hl
        end
    end
    espConn=Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function(char)
            task.wait(0.1)
            if espOn() then
                local hl=Instance.new("Highlight")
                hl.FillColor=Color3.fromRGB(255,50,50)
                hl.OutlineColor=Color3.fromRGB(255,255,255)
                hl.FillTransparency=chamsOn() and 0.45 or 1
                hl.OutlineTransparency=0
                hl.Adornee=char; hl.Parent=char
                highlights[p]=hl
            end
        end)
    end)
end

-- ================================================
--  FOV RING на экране через Frame
-- ================================================
local fovRingUI=Instance.new("Frame")
fovRingUI.BackgroundTransparency=1
fovRingUI.BorderSizePixel=0
fovRingUI.ZIndex=20
fovRingUI.Parent=gui

local fovStroke=Instance.new("UIStroke")
fovStroke.Thickness=2
fovStroke.Color=Color3.fromRGB(255,255,255)
fovStroke.Parent=fovRingUI

local fovCorner=Instance.new("UICorner")
fovCorner.CornerRadius=UDim.new(1,0)
fovCorner.Parent=fovRingUI

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
--  OPEN / CLOSE
-- ================================================
local function openMenu()
    menuOpen=true; win.Visible=true
    win.Size=UDim2.new(0,430,0,0)
    TweenService:Create(win,TweenInfo.new(0.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
        {Size=UDim2.new(0,430,0,380)}):Play()
end
local function closeMenu()
    menuOpen=false
    TweenService:Create(win,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
        {Size=UDim2.new(0,430,0,0)}):Play()
    task.delay(0.22,function() win.Visible=false end)
end

toggleBtn.MouseButton1Click:Connect(function()
    if not btnMoved then
        if menuOpen then closeMenu() else openMenu() end
    end
    btnMoved=false
end)
closeBtn.MouseButton1Click:Connect(closeMenu)
minBtn.MouseButton1Click:Connect(function()
    minimized=not minimized
    if minimized then
        TweenService:Create(win,TweenInfo.new(0.2),{Size=UDim2.new(0,430,0,44)}):Play()
        minBtn.Text="+"
    else
        TweenService:Create(win,TweenInfo.new(0.2),{Size=UDim2.new(0,430,0,380)}):Play()
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

-- DRAG TOGGLE BUTTON (фиксированная скорость)
toggleFrame.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or
       i.UserInputType==Enum.UserInputType.Touch then
        btnDragStart=i.Position; btnPos0=toggleFrame.Position; btnMoved=false
    end
end)

UIS.InputChanged:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseMovement or
       i.UserInputType==Enum.UserInputType.Touch then
        -- Drag window
        if draggingWin and dragWinStart then
            local d=i.Position-dragWinStart
            win.Position=UDim2.new(
                winStartPos.X.Scale,winStartPos.X.Offset+d.X,
                winStartPos.Y.Scale,winStartPos.Y.Offset+d.Y)
        end
        -- Drag toggle button (только если сдвинули больше 8px)
        if btnDragStart then
            local d=i.Position-btnDragStart
            if d.Magnitude>8 then
                btnMoved=true
                toggleFrame.Position=UDim2.new(
                    btnPos0.X.Scale,btnPos0.X.Offset+d.X,
                    btnPos0.Y.Scale,btnPos0.Y.Offset+d.Y)
            end
        end
    end
end)

UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or
       i.UserInputType==Enum.UserInputType.Touch then
        draggingWin=false; btnDragStart=nil
    end
end)

-- ================================================
--  MAIN LOOP
-- ================================================
local prevEsp=false

RunService.Heartbeat:Connect(function(dt)
    -- RGB
    rgbHue=(rgbHue+dt*0.3)%1
    local rgb=Color3.fromHSV(rgbHue,1,1)
    tbStroke.Color=rgb
    accentLine.BackgroundColor3=rgb
    winStroke.Color=rgb
    fovStroke.Color=rgb

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

    -- FOV Ring (Frame круглый на экране)
    local fovR=getFov()
    local showFov=showFovOn() and (aimbotOn() or silentOn())
    if showFov then
        local cx=Camera.ViewportSize.X/2
        local cy=Camera.ViewportSize.Y/2
        fovRingUI.Visible=true
        fovRingUI.Size=UDim2.new(0,fovR*2,0,fovR*2)
        fovRingUI.Position=UDim2.new(0,cx-fovR,0,cy-fovR)
    else
        fovRingUI.Visible=false
    end

    -- Aimbot
    if aimbotOn() then
        local center=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
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
            local s=math.clamp(getSmooth()/25,0.02,0.35)
            Camera.CFrame=Camera.CFrame:Lerp(
                CFrame.new(Camera.CFrame.Position,best.Position),s)
        end
    end

    -- Silent Aim — телепортирует прицел к голове
    if silentOn() then
        local center=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
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
            -- Двигаем мышку к цели
            pcall(function()
                local sPos=Camera:WorldToScreenPoint(best.Position)
                mousemoverel(
                    sPos.X - Camera.ViewportSize.X/2,
                    sPos.Y - Camera.ViewportSize.Y/2
                )
            end)
        end
    end

    -- ESP
    local espState=espOn()
    if espState~=prevEsp then
        prevEsp=espState
        if espState then enableESP() else clearESP() end
    end

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
    clearESP()
end)

print("[FLICK PRO v5] by @Primejtsu — Ready!")
