-- ================================================
--   Primejtsu X | Flick Script
--   Custom GUI - PJTSU Style
-- ================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Camera           = workspace.CurrentCamera
local LP               = Players.LocalPlayer

-- ================================================
-- SCRIPT SETTINGS
-- ================================================
local Cfg = {
    ESPEnabled    = false,
    ESPMode       = "Highlight",
    ESPFillColor  = Color3.fromRGB(255, 0, 0),
    ESPOutColor   = Color3.fromRGB(255, 255, 255),
    ESPTransp     = 0.5,
    FOVEnabled    = false,
    FOVRadius     = 150,
    FOVColor      = Color3.fromRGB(255, 255, 255),
    AimbotEnabled = false,
    AimbotSmooth  = 0.2,
    AimbotPart    = "Head",
    InfJump       = false,
    SpeedEnabled  = false,
    SpeedValue    = 40,
    NoclipOn      = false,
    NoFallOn      = false,
    FullBright    = false,
}

-- ================================================
-- FOV
-- ================================================
local FOVDraw = Drawing.new("Circle")
FOVDraw.Visible   = false
FOVDraw.Thickness = 1.5
FOVDraw.Color     = Cfg.FOVColor
FOVDraw.Filled    = false
FOVDraw.NumSides  = 128
FOVDraw.Radius    = Cfg.FOVRadius

-- ================================================
-- ESP
-- ================================================
local ESPObjects = {}

local function clearESP(p)
    if not ESPObjects[p] then return end
    if ESPObjects[p].hl  then ESPObjects[p].hl:Destroy() end
    if ESPObjects[p].box then for _,l in pairs(ESPObjects[p].box) do l:Remove() end end
    if ESPObjects[p].tr  then ESPObjects[p].tr:Remove() end
    ESPObjects[p] = nil
end

local function applyESP(p)
    clearESP(p)
    if not Cfg.ESPEnabled or p == LP then return end
    if Cfg.ESPMode == "Highlight" then
        local hl = Instance.new("Highlight")
        hl.FillColor = Cfg.ESPFillColor
        hl.OutlineColor = Cfg.ESPOutColor
        hl.FillTransparency = Cfg.ESPTransp
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        if p.Character then hl.Parent = p.Character end
        p.CharacterAdded:Connect(function(c) hl.Parent = c end)
        ESPObjects[p] = {hl = hl}
    elseif Cfg.ESPMode == "Box" then
        local lines = {}
        for i=1,4 do
            local l = Drawing.new("Line")
            l.Visible=false; l.Color=Cfg.ESPFillColor; l.Thickness=1.5
            lines[i]=l
        end
        ESPObjects[p] = {box=lines}
    elseif Cfg.ESPMode == "Tracer" then
        local t = Drawing.new("Line")
        t.Visible=false; t.Color=Cfg.ESPFillColor; t.Thickness=1.5
        ESPObjects[p] = {tr=t}
    end
end

local function refreshESP() for _,p in pairs(Players:GetPlayers()) do applyESP(p) end end
Players.PlayerAdded:Connect(function(p) if Cfg.ESPEnabled then applyESP(p) end end)
Players.PlayerRemoving:Connect(clearESP)

local function getTarget()
    local best,bestD = nil, Cfg.FOVRadius
    local cx,cy = Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local part = p.Character:FindFirstChild(Cfg.AimbotPart) or p.Character:FindFirstChild("HumanoidRootPart")
                if part then
                    local sp,vis = Camera:WorldToViewportPoint(part.Position)
                    if vis then
                        local d = math.sqrt((sp.X-cx)^2+(sp.Y-cy)^2)
                        if d < bestD then bestD=d; best=part end
                    end
                end
            end
        end
    end
    return best
end

RunService.RenderStepped:Connect(function()
    FOVDraw.Visible  = Cfg.FOVEnabled
    FOVDraw.Radius   = Cfg.FOVRadius
    FOVDraw.Color    = Cfg.FOVColor
    FOVDraw.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for p,obj in pairs(ESPObjects) do
        if p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            if obj.box and root then
                local pos,vis = Camera:WorldToViewportPoint(root.Position)
                if vis then
                    local sz=2000/pos.Z; local x,y=pos.X,pos.Y; local w,h=sz*0.4,sz*1.2
                    local c={{Vector2.new(x-w,y-h),Vector2.new(x+w,y-h)},{Vector2.new(x-w,y+h),Vector2.new(x+w,y+h)},{Vector2.new(x-w,y-h),Vector2.new(x-w,y+h)},{Vector2.new(x+w,y-h),Vector2.new(x+w,y+h)}}
                    for i,v in ipairs(c) do obj.box[i].From=v[1];obj.box[i].To=v[2];obj.box[i].Color=Cfg.ESPFillColor;obj.box[i].Visible=true end
                else for _,l in pairs(obj.box) do l.Visible=false end end
            end
            if obj.tr and root then
                local pos,vis = Camera:WorldToViewportPoint(root.Position)
                if vis then obj.tr.From=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y);obj.tr.To=Vector2.new(pos.X,pos.Y);obj.tr.Color=Cfg.ESPFillColor;obj.tr.Visible=true
                else obj.tr.Visible=false end
            end
        end
    end

    if Cfg.AimbotEnabled then
        local t = getTarget()
        if t then Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, t.Position), Cfg.AimbotSmooth) end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Cfg.InfJump and LP.Character then
        local h = LP.Character:FindFirstChild("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

RunService.Heartbeat:Connect(function()
    if LP.Character then
        local h = LP.Character:FindFirstChild("Humanoid")
        if h then h.WalkSpeed = Cfg.SpeedEnabled and Cfg.SpeedValue or 16 end
    end
end)

RunService.Stepped:Connect(function()
    if Cfg.NoclipOn and LP.Character then
        for _,p in pairs(LP.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=false end
        end
    end
end)

LP.CharacterAdded:Connect(function(char)
    local h = char:WaitForChild("Humanoid")
    h.StateChanged:Connect(function(_,new)
        if Cfg.NoFallOn and new==Enum.HumanoidStateType.Freefall then
            h:ChangeState(Enum.HumanoidStateType.Running)
        end
    end)
end)

local Lighting = game:GetService("Lighting")
local function setFullBright(on)
    Lighting.Brightness=on and 10 or 1
    Lighting.ClockTime=14
    Lighting.GlobalShadows=not on
    Lighting.Ambient=on and Color3.fromRGB(255,255,255) or Color3.fromRGB(127,127,127)
end

-- ================================================
-- GUI
-- ================================================
local function tween(obj,props,t)
    TweenService:Create(obj,TweenInfo.new(t or 0.15,Enum.EasingStyle.Quad),props):Play()
end
local function corner(p,r) local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 8);c.Parent=p end
local function stroke(p,c,t) local s=Instance.new("UIStroke");s.Color=c or Color3.fromRGB(60,65,90);s.Thickness=t or 1;s.Parent=p end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PrimejtsuX"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LP.PlayerGui

-- TOP BAR (кнопка показать/скрыть)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(0, 160, 0, 28)
TopBar.Position = UDim2.new(0.5, -80, 0, 0)
TopBar.BackgroundColor3 = Color3.fromRGB(28, 30, 40)
TopBar.BorderSizePixel = 0
TopBar.Parent = ScreenGui
corner(TopBar, 8)
stroke(TopBar, Color3.fromRGB(60,65,90), 1)

local TopBarBtn = Instance.new("TextButton")
TopBarBtn.Size = UDim2.new(1,0,1,0)
TopBarBtn.BackgroundTransparency = 1
TopBarBtn.Text = "Primejtsu X | Flick"
TopBarBtn.TextColor3 = Color3.fromRGB(220,220,255)
TopBarBtn.Font = Enum.Font.GothamBold
TopBarBtn.TextSize = 12
TopBarBtn.Parent = TopBar

-- MAIN WINDOW
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 580, 0, 400)
Main.Position = UDim2.new(0.5, -290, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(22, 24, 32)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui
corner(Main, 12)
stroke(Main, Color3.fromRGB(50,54,80), 1)

-- Drag
local drag,dragStart,startPos = false,nil,nil
Main.InputBegan:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
        drag=true; dragStart=inp.Position; startPos=Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if drag and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
        local d=inp.Position-dragStart
        Main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then drag=false end
end)

-- Toggle GUI
local guiVisible = true
TopBarBtn.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    tween(Main, {Size = guiVisible and UDim2.new(0,580,0,400) or UDim2.new(0,580,0,0)}, 0.2)
    Main.ClipsDescendants = true
end)

-- LEFT SIDEBAR
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 160, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main
corner(Sidebar, 12)

-- Fix right corners of sidebar
local SidebarFix = Instance.new("Frame")
SidebarFix.Size = UDim2.new(0, 12, 1, 0)
SidebarFix.Position = UDim2.new(1, -12, 0, 0)
SidebarFix.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
SidebarFix.BorderSizePixel = 0
SidebarFix.Parent = Sidebar

-- Logo area
local LogoFrame = Instance.new("Frame")
LogoFrame.Size = UDim2.new(1, 0, 0, 100)
LogoFrame.BackgroundTransparency = 1
LogoFrame.Parent = Sidebar

local LogoImg = Instance.new("ImageLabel")
LogoImg.Size = UDim2.new(0, 56, 0, 56)
LogoImg.Position = UDim2.new(0.5, -28, 0, 16)
LogoImg.BackgroundColor3 = Color3.fromRGB(35, 38, 52)
LogoImg.Image = ""
LogoImg.Parent = LogoFrame
corner(LogoImg, 28)
stroke(LogoImg, Color3.fromRGB(80,85,120), 1)

-- P letter as logo
local LogoLetter = Instance.new("TextLabel")
LogoLetter.Size = UDim2.new(1,0,1,0)
LogoLetter.BackgroundTransparency = 1
LogoLetter.Text = "PX"
LogoLetter.TextColor3 = Color3.fromRGB(180,160,255)
LogoLetter.Font = Enum.Font.GothamBold
LogoLetter.TextSize = 20
LogoLetter.Parent = LogoImg

local LogoTitle = Instance.new("TextLabel")
LogoTitle.Size = UDim2.new(1,0,0,20)
LogoTitle.Position = UDim2.new(0,0,0,76)
LogoTitle.BackgroundTransparency = 1
LogoTitle.Text = "PJTSU X"
LogoTitle.TextColor3 = Color3.fromRGB(220,220,255)
LogoTitle.Font = Enum.Font.GothamBold
LogoTitle.TextSize = 13
LogoTitle.TextXAlignment = Enum.TextXAlignment.Center
LogoTitle.Parent = LogoFrame

-- Divider
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(0.8, 0, 0, 1)
Divider.Position = UDim2.new(0.1, 0, 0, 100)
Divider.BackgroundColor3 = Color3.fromRGB(50,54,80)
Divider.BorderSizePixel = 0
Divider.Parent = Sidebar

-- Tab buttons in sidebar
local TabList = Instance.new("Frame")
TabList.Size = UDim2.new(1, 0, 1, -108)
TabList.Position = UDim2.new(0, 0, 0, 108)
TabList.BackgroundTransparency = 1
TabList.Parent = Sidebar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Padding = UDim.new(0, 4)
TabListLayout.Parent = TabList

local TabListPad = Instance.new("UIPadding")
TabListPad.PaddingLeft = UDim.new(0, 10)
TabListPad.PaddingRight = UDim.new(0, 10)
TabListPad.PaddingTop = UDim.new(0, 6)
TabListPad.Parent = TabList

-- CONTENT AREA
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -160, 1, 0)
ContentArea.Position = UDim2.new(0, 160, 0, 0)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = Main

-- Content header
local ContentHeader = Instance.new("Frame")
ContentHeader.Size = UDim2.new(1, -20, 0, 40)
ContentHeader.Position = UDim2.new(0, 10, 0, 10)
ContentHeader.BackgroundTransparency = 1
ContentHeader.Parent = ContentArea

local ContentTitle = Instance.new("TextLabel")
ContentTitle.Size = UDim2.new(1,0,1,0)
ContentTitle.BackgroundTransparency = 1
ContentTitle.Text = "ESP"
ContentTitle.TextColor3 = Color3.fromRGB(220,220,255)
ContentTitle.Font = Enum.Font.GothamBold
ContentTitle.TextSize = 18
ContentTitle.TextXAlignment = Enum.TextXAlignment.Left
ContentTitle.Parent = ContentHeader

-- Content scroll
local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Size = UDim2.new(1, -20, 1, -60)
ContentScroll.Position = UDim2.new(0, 10, 0, 55)
ContentScroll.BackgroundTransparency = 1
ContentScroll.ScrollBarThickness = 2
ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(120,100,220)
ContentScroll.BorderSizePixel = 0
ContentScroll.Parent = ContentArea

local ScrollLayout = Instance.new("UIListLayout")
ScrollLayout.Padding = UDim.new(0, 6)
ScrollLayout.Parent = ContentScroll

ScrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentScroll.CanvasSize = UDim2.new(0,0,0,ScrollLayout.AbsoluteContentSize.Y+10)
end)

-- Pages storage
local Pages = {}
local currentPage = nil

local function showPage(name)
    currentPage = name
    ContentTitle.Text = name
    for n,f in pairs(Pages) do
        f.Visible = (n == name)
    end
end

local function newPage(name)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,0,0)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.Parent = ContentScroll

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,6)
    layout.Parent = frame

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        frame.Size = UDim2.new(1,0,0,layout.AbsoluteContentSize.Y)
        ContentScroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+10)
    end)

    Pages[name] = frame
    return frame
end

-- Sidebar tab button maker
local function makeSideTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,36)
    btn.BackgroundColor3 = Color3.fromRGB(28,30,42)
    btn.BorderSizePixel = 0
    btn.Text = icon .. "  " .. name
    btn.TextColor3 = Color3.fromRGB(150,150,190)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = TabList
    corner(btn, 8)

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0,10)
    pad.Parent = btn

    btn.MouseButton1Click:Connect(function()
        -- reset all
        for _,b in pairs(TabList:GetChildren()) do
            if b:IsA("TextButton") then
                tween(b,{BackgroundColor3=Color3.fromRGB(28,30,42),TextColor3=Color3.fromRGB(150,150,190)},0.15)
            end
        end
        tween(btn,{BackgroundColor3=Color3.fromRGB(80,60,160),TextColor3=Color3.fromRGB(255,255,255)},0.15)
        showPage(name)
    end)

    return btn
end

-- Element makers
local function makeToggle(parent, name, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,0,0,42)
    row.BackgroundColor3 = Color3.fromRGB(28,30,42)
    row.BorderSizePixel = 0
    row.Parent = parent
    corner(row,8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-70,1,0)
    lbl.Position = UDim2.new(0,14,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(210,210,240)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0,44,0,24)
    bg.Position = UDim2.new(1,-56,0.5,-12)
    bg.BackgroundColor3 = default and Color3.fromRGB(100,70,220) or Color3.fromRGB(45,45,65)
    bg.Parent = row
    corner(bg,12)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0,18,0,18)
    circle.Position = default and UDim2.new(0,23,0.5,-9) or UDim2.new(0,3,0.5,-9)
    circle.BackgroundColor3 = Color3.fromRGB(255,255,255)
    circle.Parent = bg
    corner(circle,9)

    local val = default or false
    local hitbox = Instance.new("TextButton")
    hitbox.Size = UDim2.new(1,0,1,0)
    hitbox.BackgroundTransparency = 1
    hitbox.Text = ""
    hitbox.Parent = row
    hitbox.MouseButton1Click:Connect(function()
        val = not val
        tween(bg,{BackgroundColor3=val and Color3.fromRGB(100,70,220) or Color3.fromRGB(45,45,65)},0.15)
        tween(circle,{Position=val and UDim2.new(0,23,0.5,-9) or UDim2.new(0,3,0.5,-9)},0.15)
        if callback then callback(val) end
    end)
end

local function makeSlider(parent, name, min, max, default, inc, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,0,0,56)
    row.BackgroundColor3 = Color3.fromRGB(28,30,42)
    row.BorderSizePixel = 0
    row.Parent = parent
    corner(row,8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-70,0,28)
    lbl.Position = UDim2.new(0,14,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(210,210,240)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0,50,0,28)
    valLbl.Position = UDim2.new(1,-60,0,0)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(default)
    valLbl.TextColor3 = Color3.fromRGB(150,120,255)
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 13
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1,-28,0,6)
    track.Position = UDim2.new(0,14,1,-18)
    track.BackgroundColor3 = Color3.fromRGB(45,45,65)
    track.Parent = row
    corner(track,3)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(100,70,220)
    fill.Parent = track
    corner(fill,3)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0,14,0,14)
    dot.Position = UDim2.new(0,-7,0.5,-7)
    dot.BackgroundColor3 = Color3.fromRGB(255,255,255)
    dot.Parent = fill
    corner(dot,7)

    local val = default
    local sliding = false

    track.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            sliding=true
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            sliding=false
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if sliding and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
            local abs=track.AbsolutePosition; local sz=track.AbsoluteSize
            local pct=math.clamp((inp.Position.X-abs.X)/sz.X,0,1)
            val=math.clamp(math.round((min+(max-min)*pct)/inc)*inc,min,max)
            fill.Size=UDim2.new((val-min)/(max-min),0,1,0)
            valLbl.Text=tostring(val)
            if callback then callback(val) end
        end
    end)
end

local function makeDropdown(parent, name, options, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,0,0,42)
    row.BackgroundColor3 = Color3.fromRGB(28,30,42)
    row.BorderSizePixel = 0
    row.ClipsDescendants = false
    row.Parent = parent
    corner(row,8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.45,0,1,0)
    lbl.Position = UDim2.new(0,14,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(210,210,240)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local sel = default or options[1]
    local dropBtn = Instance.new("TextButton")
    dropBtn.Size = UDim2.new(0,140,0,28)
    dropBtn.Position = UDim2.new(1,-150,0.5,-14)
    dropBtn.BackgroundColor3 = Color3.fromRGB(38,40,58)
    dropBtn.Text = sel .. " v"
    dropBtn.TextColor3 = Color3.fromRGB(210,210,240)
    dropBtn.Font = Enum.Font.Gotham
    dropBtn.TextSize = 12
    dropBtn.Parent = row
    corner(dropBtn,6)
    stroke(dropBtn, Color3.fromRGB(60,64,90), 1)

    local dropFrame = Instance.new("Frame")
    dropFrame.Size = UDim2.new(0,140,0,#options*30+6)
    dropFrame.Position = UDim2.new(1,-150,1,4)
    dropFrame.BackgroundColor3 = Color3.fromRGB(28,30,42)
    dropFrame.BorderSizePixel = 0
    dropFrame.Visible = false
    dropFrame.ZIndex = 20
    dropFrame.Parent = row
    corner(dropFrame,6)
    stroke(dropFrame, Color3.fromRGB(60,64,90), 1)

    local dLayout = Instance.new("UIListLayout")
    dLayout.Padding = UDim.new(0,2)
    dLayout.Parent = dropFrame
    local dPad = Instance.new("UIPadding")
    dPad.PaddingTop=UDim.new(0,3); dPad.PaddingLeft=UDim.new(0,3); dPad.PaddingRight=UDim.new(0,3)
    dPad.Parent = dropFrame

    local open = false
    for _,opt in pairs(options) do
        local ob = Instance.new("TextButton")
        ob.Size = UDim2.new(1,0,0,26)
        ob.BackgroundColor3 = Color3.fromRGB(35,37,55)
        ob.Text = opt
        ob.TextColor3 = Color3.fromRGB(200,200,230)
        ob.Font = Enum.Font.Gotham
        ob.TextSize = 12
        ob.ZIndex = 21
        ob.Parent = dropFrame
        corner(ob,4)
        ob.MouseButton1Click:Connect(function()
            sel=opt; dropBtn.Text=opt.." v"; dropFrame.Visible=false; open=false
            tween(row,{Size=UDim2.new(1,0,0,42)},0.1)
            if callback then callback(opt) end
        end)
    end

    dropBtn.MouseButton1Click:Connect(function()
        open=not open
        dropFrame.Visible=open
        tween(row,{Size=UDim2.new(1,0,0,open and 42+#options*30+10 or 42)},0.15)
    end)

    if callback then callback(sel) end
end

local function makeButton(parent, name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,38)
    btn.BackgroundColor3 = Color3.fromRGB(80,55,170)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = parent
    corner(btn,8)
    btn.MouseButton1Click:Connect(function()
        tween(btn,{BackgroundColor3=Color3.fromRGB(110,80,210)},0.08)
        task.delay(0.15,function() tween(btn,{BackgroundColor3=Color3.fromRGB(80,55,170)},0.08) end)
        if callback then callback() end
    end)
end

local function makeSection(parent, name)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,22)
    f.BackgroundTransparency = 1
    f.Parent = parent
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,0,1,0)
    l.BackgroundTransparency = 1
    l.Text = "-- " .. name .. " --"
    l.TextColor3 = Color3.fromRGB(120,100,200)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
end

-- ================================================
-- BUILD TABS
-- ================================================

-- ESP TAB
makeSideTab("ESP", "")
local espPage = newPage("ESP")
makeSection(espPage, "Player Visuals")
makeToggle(espPage, "Enable ESP", false, function(v) Cfg.ESPEnabled=v; refreshESP() end)
makeDropdown(espPage, "ESP Mode", {"Highlight","Box","Tracer"}, "Highlight", function(v) Cfg.ESPMode=v; refreshESP() end)
makeDropdown(espPage, "ESP Color", {"Red","Green","Blue","Yellow","Purple","Cyan","White","Orange"}, "Red", function(v)
    local c={Red=Color3.fromRGB(255,0,0),Green=Color3.fromRGB(0,255,0),Blue=Color3.fromRGB(0,100,255),
        Yellow=Color3.fromRGB(255,255,0),Purple=Color3.fromRGB(180,0,255),Cyan=Color3.fromRGB(0,255,255),
        White=Color3.fromRGB(255,255,255),Orange=Color3.fromRGB(255,140,0)}
    if c[v] then Cfg.ESPFillColor=c[v]; Cfg.ESPOutColor=c[v]; refreshESP() end
end)
makeSlider(espPage,"Transparency",0,10,5,1,function(v) Cfg.ESPTransp=v/10; refreshESP() end)

-- AIMBOT TAB
makeSideTab("Aimbot", "")
local aimPage = newPage("Aimbot")
makeSection(aimPage, "Aimbot Settings")
makeToggle(aimPage, "Enable Aimbot", false, function(v) Cfg.AimbotEnabled=v end)
makeToggle(aimPage, "FOV Circle", false, function(v) Cfg.FOVEnabled=v end)
makeSlider(aimPage, "FOV Radius", 30, 500, 150, 5, function(v) Cfg.FOVRadius=v end)
makeSlider(aimPage, "Smoothness", 1, 100, 20, 1, function(v) Cfg.AimbotSmooth=v/100 end)
makeDropdown(aimPage, "Aim Part", {"Head","HumanoidRootPart","UpperTorso","Torso"}, "Head", function(v) Cfg.AimbotPart=v end)
makeDropdown(aimPage, "FOV Color", {"White","Yellow","Red","Green","Blue","Cyan","Purple"}, "White", function(v)
    local c={White=Color3.fromRGB(255,255,255),Yellow=Color3.fromRGB(255,255,0),Red=Color3.fromRGB(255,0,0),
        Green=Color3.fromRGB(0,255,0),Blue=Color3.fromRGB(0,100,255),Cyan=Color3.fromRGB(0,255,255),Purple=Color3.fromRGB(150,80,255)}
    if c[v] then Cfg.FOVColor=c[v] end
end)

-- MOVEMENT TAB
makeSideTab("Movement", "")
local movePage = newPage("Movement")
makeSection(movePage, "Player Movement")
makeToggle(movePage, "Infinite Jump", false, function(v) Cfg.InfJump=v end)
makeToggle(movePage, "Speed Hack", false, function(v) Cfg.SpeedEnabled=v end)
makeSlider(movePage, "Walk Speed", 16, 200, 40, 1, function(v) Cfg.SpeedValue=v end)
makeToggle(movePage, "Noclip", false, function(v) Cfg.NoclipOn=v end)
makeToggle(movePage, "No Fall Damage", false, function(v) Cfg.NoFallOn=v end)

-- MISC TAB
makeSideTab("Misc", "")
local miscPage = newPage("Misc")
makeSection(miscPage, "Miscellaneous")
makeToggle(miscPage, "Fullbright", false, function(v) setFullBright(v) end)
makeToggle(miscPage, "Anti-AFK", false, function(v)
    if v then
        LP.Idled:Connect(function()
            local vu=game:GetService("VirtualUser")
            vu:Button1Down(Vector2.new(0,0),Camera.CFrame)
            task.wait(0.1)
            vu:Button1Up(Vector2.new(0,0),Camera.CFrame)
        end)
    end
end)
makeButton(miscPage, "Teleport to Spawn", function()
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.CFrame = CFrame.new(0,10,0)
    end
end)
makeButton(miscPage, "Respawn", function()
    if LP.Character then
        local h=LP.Character:FindFirstChild("Humanoid")
        if h then h.Health=0 end
    end
end)
makeButton(miscPage, "Rejoin", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
end)

-- Show first tab by default
showPage("ESP")
-- Highlight first tab button
local firstBtn = TabList:GetChildren()[1]
if firstBtn and firstBtn:IsA("TextButton") then
    tween(firstBtn,{BackgroundColor3=Color3.fromRGB(80,60,160),TextColor3=Color3.fromRGB(255,255,255)},0)
end

print("[Primejtsu X] Custom GUI Loaded.")
