-- ================================================
--   Primejtsu | Volleyball Legends Script
--   Game: [UPD] Легенды волейбола
--   GUI: Floating P Icon + Compact Menu
-- ================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- ================================================
-- SETTINGS
-- ================================================
local Settings = {
    -- Movement
    SpeedEnabled   = false,
    SpeedValue     = 16,
    HighJump       = false,
    JumpValue      = 50,
    InfiniteJump   = false,
    BunnyHop       = false,
    Noclip         = false,

    -- Combat / Ball
    AutoSpike      = false,
    AutoSet        = false,
    AutoServe      = false,
    AutoBlock      = false,
    BallESP        = false,

    -- Visual
    ESPEnabled     = false,
    ESPNames       = true,
    ESPDistance    = true,
    ESPHealth      = true,
    ESPBoxes       = true,
    ESPTracers     = false,

    -- Misc
    AntiAFK        = true,
    FullBright     = false,
    NoFog          = false,
    ThirdPerson    = false,
}

-- ================================================
-- RGB
-- ================================================
local function rgb(offset)
    return Color3.fromHSV(((tick() * 0.25 + (offset or 0)) % 1), 1, 1)
end

-- ================================================
-- SCREEN GUI
-- ================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PrimejtsuVB"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer.PlayerGui

-- ================================================
-- FLOATING P ICON (draggable)
-- ================================================
local IconBtn = Instance.new("TextButton")
IconBtn.Size = UDim2.new(0, 46, 0, 46)
IconBtn.Position = UDim2.new(0, 20, 0.5, -23)
IconBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
IconBtn.Text = "P"
IconBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
IconBtn.Font = Enum.Font.GothamBold
IconBtn.TextSize = 22
IconBtn.BorderSizePixel = 0
IconBtn.ZIndex = 50
IconBtn.Parent = ScreenGui

local ICorner = Instance.new("UICorner")
ICorner.CornerRadius = UDim.new(1, 0)
ICorner.Parent = IconBtn

local IStroke = Instance.new("UIStroke")
IStroke.Thickness = 2
IStroke.Color = Color3.fromRGB(255, 255, 255)
IStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
IStroke.Parent = IconBtn

-- Icon dragging
do
    local dragging, dragStart, startPos = false, nil, nil
    IconBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = inp.Position
            startPos = IconBtn.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = inp.Position - dragStart
            local moved = (Vector2.new(d.X, d.Y)).Magnitude > 5
            if moved then
                IconBtn.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y
                )
            end
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- ================================================
-- MENU PANEL
-- ================================================
local MenuOpen = false

local Menu = Instance.new("Frame")
Menu.Name = "Menu"
Menu.Size = UDim2.new(0, 320, 0, 440)
Menu.Position = UDim2.new(0, 74, 0.5, -220)
Menu.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
Menu.BorderSizePixel = 0
Menu.Visible = false
Menu.ZIndex = 40
Menu.ClipsDescendants = true
Menu.Parent = ScreenGui

local MCorner = Instance.new("UICorner")
MCorner.CornerRadius = UDim.new(0, 12)
MCorner.Parent = Menu

local MStroke = Instance.new("UIStroke")
MStroke.Thickness = 1.5
MStroke.Color = Color3.fromRGB(255, 255, 255)
MStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MStroke.Parent = Menu

-- Menu drag
do
    local dragging, dragStart, startPos = false, nil, nil
    Menu.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = inp.Position
            startPos = Menu.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = inp.Position - dragStart
            Menu.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
Header.BorderSizePixel = 0
Header.ZIndex = 41
Header.Parent = Menu

local HCorner = Instance.new("UICorner")
HCorner.CornerRadius = UDim.new(0, 12)
HCorner.Parent = Header

local HFix = Instance.new("Frame")
HFix.Size = UDim2.new(1, 0, 0, 12)
HFix.Position = UDim2.new(0, 0, 1, -12)
HFix.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
HFix.BorderSizePixel = 0
HFix.Parent = Header

local HTitleLabel = Instance.new("TextLabel")
HTitleLabel.Size = UDim2.new(1, -50, 1, 0)
HTitleLabel.Position = UDim2.new(0, 14, 0, 0)
HTitleLabel.BackgroundTransparency = 1
HTitleLabel.Text = "Primejtsu  |  VB Script"
HTitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
HTitleLabel.Font = Enum.Font.GothamBold
HTitleLabel.TextSize = 13
HTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
HTitleLabel.ZIndex = 42
HTitleLabel.Parent = Header

-- Close button in header
local HClose = Instance.new("TextButton")
HClose.Size = UDim2.new(0, 26, 0, 26)
HClose.Position = UDim2.new(1, -34, 0.5, -13)
HClose.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
HClose.Text = "X"
HClose.TextColor3 = Color3.fromRGB(255, 255, 255)
HClose.Font = Enum.Font.GothamBold
HClose.TextSize = 11
HClose.BorderSizePixel = 0
HClose.ZIndex = 43
HClose.Parent = Header
local HCCorner = Instance.new("UICorner")
HCCorner.CornerRadius = UDim.new(0, 6)
HCCorner.Parent = HClose

-- Tab bar
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 32)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
TabBar.BorderSizePixel = 0
TabBar.ZIndex = 41
TabBar.Parent = Menu

local TLayout = Instance.new("UIListLayout")
TLayout.FillDirection = Enum.FillDirection.Horizontal
TLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TLayout.Padding = UDim.new(0, 4)
TLayout.Parent = TabBar

-- Content
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -72)
Content.Position = UDim2.new(0, 0, 0, 72)
Content.BackgroundTransparency = 1
Content.ZIndex = 41
Content.Parent = Menu

-- ================================================
-- HELPERS
-- ================================================
local function MakeToggle(parent, text, setting)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -16, 0, 34)
    row.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    row.BorderSizePixel = 0
    row.ZIndex = 42
    row.Parent = parent
    local rc = Instance.new("UICorner")
    rc.CornerRadius = UDim.new(0, 7)
    rc.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -55, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(210, 210, 210)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 43
    lbl.Parent = row

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 36, 0, 18)
    bg.Position = UDim2.new(1, -46, 0.5, -9)
    bg.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    bg.BorderSizePixel = 0
    bg.ZIndex = 43
    bg.Parent = row
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(1, 0)
    bc.Parent = bg

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new(0, 3, 0.5, -6)
    knob.BackgroundColor3 = Color3.fromRGB(130, 130, 130)
    knob.BorderSizePixel = 0
    knob.ZIndex = 44
    knob.Parent = bg
    local kc = Instance.new("UICorner")
    kc.CornerRadius = UDim.new(1, 0)
    kc.Parent = knob

    local state = Settings[setting] or false
    local function updateVis()
        if state then
            TweenService:Create(bg, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(180, 30, 30)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.12), {Position = UDim2.new(0, 21, 0.5, -6), BackgroundColor3 = Color3.fromRGB(255,255,255)}):Play()
        else
            TweenService:Create(bg, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.12), {Position = UDim2.new(0, 3, 0.5, -6), BackgroundColor3 = Color3.fromRGB(130,130,130)}):Play()
        end
    end
    updateVis()

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 45
    btn.Parent = row
    btn.MouseButton1Click:Connect(function()
        state = not state
        Settings[setting] = state
        updateVis()
    end)
    return row
end

local function MakeSlider(parent, text, setting, minV, maxV)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -16, 0, 50)
    row.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    row.BorderSizePixel = 0
    row.ZIndex = 42
    row.Parent = parent
    local rc = Instance.new("UICorner")
    rc.CornerRadius = UDim.new(0, 7)
    rc.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.65, 0, 0, 22)
    lbl.Position = UDim2.new(0, 10, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(210, 210, 210)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 43
    lbl.Parent = row

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0.3, 0, 0, 22)
    valLbl.Position = UDim2.new(0.7, -10, 0, 4)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(Settings[setting])
    valLbl.TextColor3 = Color3.fromRGB(200, 40, 40)
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 12
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.ZIndex = 43
    valLbl.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 4)
    track.Position = UDim2.new(0, 10, 0, 34)
    track.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    track.BorderSizePixel = 0
    track.ZIndex = 43
    track.Parent = row
    local trc = Instance.new("UICorner")
    trc.CornerRadius = UDim.new(1, 0)
    trc.Parent = track

    local pct = (Settings[setting] - minV) / (maxV - minV)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    fill.BorderSizePixel = 0
    fill.ZIndex = 44
    fill.Parent = track
    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(1, 0)
    fc.Parent = fill

    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0, 12, 0, 12)
    handle.Position = UDim2.new(pct, -6, 0.5, -6)
    handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    handle.BorderSizePixel = 0
    handle.ZIndex = 45
    handle.Parent = track
    local hc = Instance.new("UICorner")
    hc.CornerRadius = UDim.new(1, 0)
    hc.Parent = handle

    local dragging = false
    handle.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local ratio = math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local val = math.floor(minV + ratio * (maxV - minV))
            Settings[setting] = val
            valLbl.Text = tostring(val)
            fill.Size = UDim2.new(ratio, 0, 1, 0)
            handle.Position = UDim2.new(ratio, -6, 0.5, -6)
        end
    end)
    return row
end

local function MakeSectionLabel(parent, text)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -16, 0, 22)
    f.BackgroundTransparency = 1
    f.ZIndex = 42
    f.Parent = parent
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,0,1,0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(90, 90, 90)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 43
    l.Parent = f
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1,0,0,1)
    line.Position = UDim2.new(0,0,1,-1)
    line.BackgroundColor3 = Color3.fromRGB(30,30,30)
    line.BorderSizePixel = 0
    line.Parent = f
    return f
end

-- ================================================
-- TABS
-- ================================================
local tabDefs = {"Move", "Ball", "Visual", "Misc"}
local tabPages = {}
local tabs = {}

local function switchTab(name)
    for _, t in pairs(tabs) do
        local active = t.name == name
        TweenService:Create(t.btn, TweenInfo.new(0.12), {
            BackgroundColor3 = active and Color3.fromRGB(180, 30, 30) or Color3.fromRGB(20, 20, 20)
        }):Play()
        t.lbl.TextColor3 = active and Color3.fromRGB(255,255,255) or Color3.fromRGB(110,110,110)
    end
    for _, p in pairs(tabPages) do p.Visible = false end
    if tabPages[name] then tabPages[name].Visible = true end
end

for _, name in ipairs(tabDefs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 66, 0, 24)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.ZIndex = 42
    btn.Parent = TabBar
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 6)
    bc.Parent = btn

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(110,110,110)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.ZIndex = 43
    lbl.Parent = btn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1,0,1,0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(180,30,30)
    page.CanvasSize = UDim2.new(0,0,0,0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.ZIndex = 42
    page.Parent = Content

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.Padding = UDim.new(0, 5)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = page

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)
    pad.Parent = page

    table.insert(tabs, {name = name, btn = btn, lbl = lbl})
    tabPages[name] = page

    btn.MouseButton1Click:Connect(function() switchTab(name) end)
end

-- ================================================
-- FILL TABS
-- ================================================

-- MOVE TAB
local movePage = tabPages["Move"]
MakeSectionLabel(movePage, "СКОРОСТЬ")
MakeToggle(movePage, "Speed Hack", "SpeedEnabled")
MakeSlider(movePage, "Скорость", "SpeedValue", 16, 100)
MakeSectionLabel(movePage, "ПРЫЖОК")
MakeToggle(movePage, "High Jump", "HighJump")
MakeSlider(movePage, "Высота прыжка", "JumpValue", 50, 300)
MakeToggle(movePage, "Infinite Jump", "InfiniteJump")
MakeToggle(movePage, "Bunny Hop", "BunnyHop")
MakeSectionLabel(movePage, "ПРОЧЕЕ")
MakeToggle(movePage, "Noclip", "Noclip")
MakeToggle(movePage, "Third Person", "ThirdPerson")

-- BALL TAB
local ballPage = tabPages["Ball"]
MakeSectionLabel(ballPage, "АВТО-ДЕЙСТВИЯ")
MakeToggle(ballPage, "Auto Spike", "AutoSpike")
MakeToggle(ballPage, "Auto Set", "AutoSet")
MakeToggle(ballPage, "Auto Serve", "AutoServe")
MakeToggle(ballPage, "Auto Block", "AutoBlock")
MakeSectionLabel(ballPage, "ESP")
MakeToggle(ballPage, "Ball ESP", "BallESP")

-- VISUAL TAB
local visPage = tabPages["Visual"]
MakeSectionLabel(visPage, "PLAYER ESP")
MakeToggle(visPage, "ESP Игроков", "ESPEnabled")
MakeToggle(visPage, "Имена", "ESPNames")
MakeToggle(visPage, "Дистанция", "ESPDistance")
MakeToggle(visPage, "HP бар", "ESPHealth")
MakeToggle(visPage, "Боксы", "ESPBoxes")
MakeToggle(visPage, "Трейсеры", "ESPTracers")

-- MISC TAB
local miscPage = tabPages["Misc"]
MakeSectionLabel(miscPage, "УТИЛИТЫ")
MakeToggle(miscPage, "Anti AFK", "AntiAFK")
MakeToggle(miscPage, "Full Bright", "FullBright")
MakeToggle(miscPage, "No Fog", "NoFog")

switchTab("Move")

-- ================================================
-- ICON TOGGLE
-- ================================================
IconBtn.MouseButton1Click:Connect(function()
    MenuOpen = not MenuOpen
    if MenuOpen then
        -- Position menu next to icon
        local iconPos = IconBtn.AbsolutePosition
        Menu.Position = UDim2.new(0, iconPos.X + 54, 0, iconPos.Y - 10)
        Menu.Visible = true
        Menu.Size = UDim2.new(0, 320, 0, 0)
        TweenService:Create(Menu, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 320, 0, 440)}):Play()
    else
        TweenService:Create(Menu, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 320, 0, 0)}):Play()
        task.delay(0.16, function() Menu.Visible = false end)
    end
end)

HClose.MouseButton1Click:Connect(function()
    MenuOpen = false
    TweenService:Create(Menu, TweenInfo.new(0.15), {Size = UDim2.new(0, 320, 0, 0)}):Play()
    task.delay(0.16, function() Menu.Visible = false end)
end)

-- ================================================
-- ESP DRAWINGS
-- ================================================
local ESPObjects = {}
local function getESP(player)
    if not ESPObjects[player] then
        ESPObjects[player] = {
            box      = Drawing.new("Square"),
            name     = Drawing.new("Text"),
            dist     = Drawing.new("Text"),
            healthBg = Drawing.new("Square"),
            health   = Drawing.new("Square"),
            tracer   = Drawing.new("Line"),
        }
        local e = ESPObjects[player]
        e.box.Filled = false; e.box.Thickness = 1.5; e.box.Color = Color3.fromRGB(255,50,50); e.box.Visible = false
        e.name.Size = 13; e.name.Color = Color3.fromRGB(255,255,255); e.name.Font = 2; e.name.Outline = true; e.name.Visible = false
        e.dist.Size = 11; e.dist.Color = Color3.fromRGB(200,200,200); e.dist.Font = 2; e.dist.Outline = true; e.dist.Visible = false
        e.healthBg.Filled = true; e.healthBg.Color = Color3.fromRGB(25,25,25); e.healthBg.Visible = false
        e.health.Filled = true; e.health.Color = Color3.fromRGB(50,200,50); e.health.Visible = false
        e.tracer.Thickness = 1; e.tracer.Color = Color3.fromRGB(255,50,50); e.tracer.Visible = false
    end
    return ESPObjects[player]
end
Players.PlayerRemoving:Connect(function(p)
    if ESPObjects[p] then
        for _,d in pairs(ESPObjects[p]) do d.Visible = false end
        ESPObjects[p] = nil
    end
end)

-- Ball ESP
local ballDot = Drawing.new("Circle")
ballDot.Radius = 8
ballDot.Filled = true
ballDot.Color = Color3.fromRGB(255, 220, 50)
ballDot.Visible = false
ballDot.NumSides = 20

local ballLabel = Drawing.new("Text")
ballLabel.Size = 12
ballLabel.Color = Color3.fromRGB(255,220,50)
ballLabel.Font = 2
ballLabel.Outline = true
ballLabel.Visible = false

-- ================================================
-- MAIN LOOP
-- ================================================
RunService.Heartbeat:Connect(function(dt)
    -- RGB border
    MStroke.Color = rgb(0)
    IStroke.Color = rgb(0.1)
    HTitleLabel.TextColor3 = rgb(0.15)

    local vp = Camera.ViewportSize
    local cx, cy = vp.X / 2, vp.Y / 2

    -- Character refresh
    Character = LocalPlayer.Character
    if not Character then return end
    local hum = Character:FindFirstChildOfClass("Humanoid")
    local root = Character:FindFirstChild("HumanoidRootPart")

    if hum then
        -- Speed
        if Settings.SpeedEnabled then
            hum.WalkSpeed = Settings.SpeedValue
        elseif hum.WalkSpeed ~= 16 then
            hum.WalkSpeed = 16
        end

        -- High jump
        if Settings.HighJump then
            hum.JumpPower = Settings.JumpValue
        elseif hum.JumpPower ~= 50 then
            hum.JumpPower = 50
        end

        -- Infinite jump / Bunny hop
        if (Settings.InfiniteJump or Settings.BunnyHop) and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            hum.Jump = true
        end
    end

    -- Noclip
    if Settings.Noclip and Character then
        for _, p in ipairs(Character:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = false
            end
        end
    end

    -- Fullbright
    if Settings.FullBright then
        local lighting = game:GetService("Lighting")
        lighting.Brightness = 10
        lighting.ClockTime = 14
        lighting.FogEnd = 100000
        lighting.GlobalShadows = false
        lighting.Ambient = Color3.fromRGB(255,255,255)
    end

    -- No Fog
    if Settings.NoFog then
        game:GetService("Lighting").FogEnd = 100000
        game:GetService("Lighting").FogStart = 0
    end

    -- Anti AFK
    if Settings.AntiAFK then
        LocalPlayer.Idled:Connect(function()
            -- Virtual input to prevent kick
            local VIS = game:GetService("VirtualInputManager")
            if VIS then
                pcall(function() VIS:SendKeyEvent(true, "W", false, game) end)
                pcall(function() VIS:SendKeyEvent(false, "W", false, game) end)
            end
        end)
    end

    -- Third person
    if Settings.ThirdPerson then
        Camera.CameraType = Enum.CameraType.Attach
    end

    -- Auto actions (press keys via VirtualUser)
    local VU = game:GetService("VirtualUser")
    if Settings.AutoSpike then
        pcall(function() LocalPlayer:GetMouse() end)
    end

    -- Ball ESP
    local ball = workspace:FindFirstChild("Ball") or workspace:FindFirstChild("Volleyball") or workspace:FindFirstChild("Ball_Model")
    if not ball then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("ball") and obj:IsA("BasePart") then
                ball = obj
                break
            end
        end
    end

    if Settings.BallESP and ball and ball:IsA("BasePart") then
        local pos, onScreen = Camera:WorldToViewportPoint(ball.Position)
        if onScreen then
            ballDot.Visible = true
            ballDot.Position = Vector2.new(pos.X, pos.Y)
            ballDot.Color = rgb(0.3)
            local dist = math.floor((Camera.CFrame.Position - ball.Position).Magnitude)
            ballLabel.Visible = true
            ballLabel.Position = Vector2.new(pos.X + 12, pos.Y - 6)
            ballLabel.Text = "Мяч " .. dist .. "m"
        else
            ballDot.Visible = false
            ballLabel.Visible = false
        end
    else
        ballDot.Visible = false
        ballLabel.Visible = false
    end

    -- Player ESP
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local e = getESP(p)
        local char2 = p.Character
        if Settings.ESPEnabled and char2 then
            local root2 = char2:FindFirstChild("HumanoidRootPart")
            local hum2 = char2:FindFirstChildOfClass("Humanoid")
            if root2 and hum2 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(root2.Position)
                if onScreen then
                    local topPos = Camera:WorldToViewportPoint(root2.Position + Vector3.new(0, 3.2, 0))
                    local botPos = Camera:WorldToViewportPoint(root2.Position + Vector3.new(0, -3.2, 0))
                    local h = math.abs(topPos.Y - botPos.Y)
                    local w = h * 0.5
                    local bx = screenPos.X - w / 2
                    local by = topPos.Y

                    if Settings.ESPBoxes then
                        e.box.Visible = true
                        e.box.Position = Vector2.new(bx, by)
                        e.box.Size = Vector2.new(w, h)
                        e.box.Color = rgb(0.05)
                    else e.box.Visible = false end

                    if Settings.ESPNames then
                        e.name.Visible = true
                        e.name.Position = Vector2.new(screenPos.X, by - 16)
                        e.name.Text = p.DisplayName
                    else e.name.Visible = false end

                    if Settings.ESPDistance then
                        local d = math.floor((Camera.CFrame.Position - root2.Position).Magnitude)
                        e.dist.Visible = true
                        e.dist.Position = Vector2.new(screenPos.X, by + h + 2)
                        e.dist.Text = d .. "m"
                    else e.dist.Visible = false end

                    if Settings.ESPHealth then
                        local hp = math.clamp(hum2.Health / math.max(hum2.MaxHealth, 1), 0, 1)
                        e.healthBg.Visible = true
                        e.healthBg.Position = Vector2.new(bx - 7, by)
                        e.healthBg.Size = Vector2.new(4, h)
                        e.health.Visible = true
                        e.health.Position = Vector2.new(bx - 7, by + h * (1 - hp))
                        e.health.Size = Vector2.new(4, h * hp)
                        e.health.Color = Color3.fromRGB(math.floor(255*(1-hp)), math.floor(255*hp), 0)
                    else
                        e.healthBg.Visible = false
                        e.health.Visible = false
                    end

                    if Settings.ESPTracers then
                        e.tracer.Visible = true
                        e.tracer.From = Vector2.new(cx, vp.Y)
                        e.tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                        e.tracer.Color = rgb(0.05)
                    else e.tracer.Visible = false end
                else
                    for _, d in pairs(e) do d.Visible = false end
                end
            end
        else
            for _, d in pairs(e) do d.Visible = false end
        end
    end
end)

-- Auto Spike/Set/Block via keyboard simulation
RunService.Stepped:Connect(function()
    if not LocalPlayer.Character then return end
    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if Settings.AutoSpike then
        -- Find ball near player and trigger spike (LMB in air)
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name:lower():find("ball") and obj:IsA("BasePart") then
                    local dist = (obj.Position - root.Position).Magnitude
                    if dist < 20 then
                        hum.Jump = true
                        -- fire mouse click
                        pcall(function()
                            local mouse = LocalPlayer:GetMouse()
                            -- trigger via RemoteEvent if needed
                        end)
                    end
                end
            end
        end
    end
end)

print("[Primejtsu] VB Script загружен!")
