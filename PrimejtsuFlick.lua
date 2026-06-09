-- ================================================
--   Primejtsu | Flick Script
--   Game: [FPS] Флик (Groundwork)
--   GUI: RGB Black/White Theme
-- ================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ================================================
-- SETTINGS
-- ================================================
local Settings = {
    -- Aimbot
    AimBot = false,
    AimPart = "Head",
    AimFOV = 200,
    AimSmooth = 0.15,
    SilentAim = false,

    -- Crosshair
    Crosshair = false,
    CrosshairSize = 8,
    CrosshairColor = Color3.fromRGB(255, 255, 255),

    -- Speed
    SpeedEnabled = false,
    SpeedValue = 16,

    -- ESP
    ESPEnabled = false,
    ESPBoxes = true,
    ESPNames = true,
    ESPDistance = true,
    ESPHealth = true,
    ESPTracers = false,
    ESPColor = Color3.fromRGB(255, 50, 50),

    -- Misc
    InfiniteAmmo = false,
    AutoFire = false,
    NoRecoil = false,
    BunnyHop = false,
    ThirdPerson = false,
}

-- ================================================
-- RGB UTILITY
-- ================================================
local rgbStep = 0
local function getRainbowColor(offset)
    offset = offset or 0
    local h = ((tick() * 0.3 + offset) % 1)
    return Color3.fromHSV(h, 1, 1)
end

-- ================================================
-- GALAXY ANIMATION (10 seconds fullscreen)
-- ================================================
local function CreateGalaxyAnimation()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PrimejtsuIntro"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = LocalPlayer.PlayerGui

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.Position = UDim2.new(0, 0, 0, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BorderSizePixel = 0
    bg.ZIndex = 100
    bg.Parent = ScreenGui

    -- Star particles
    local starContainer = Instance.new("Frame")
    starContainer.Size = UDim2.new(1, 0, 1, 0)
    starContainer.BackgroundTransparency = 1
    starContainer.ZIndex = 101
    starContainer.Parent = bg

    local function createStar(x, y, size, brightness)
        local star = Instance.new("Frame")
        star.Size = UDim2.new(0, size, 0, size)
        star.Position = UDim2.new(0, x, 0, y)
        star.BackgroundColor3 = Color3.fromRGB(brightness, brightness, brightness)
        star.BorderSizePixel = 0
        star.ZIndex = 102
        star.Parent = starContainer
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = star
        return star
    end

    -- Generate stars
    local stars = {}
    local rng = Random.new()
    for i = 1, 120 do
        local x = rng:NextInteger(0, 1200)
        local y = rng:NextInteger(0, 700)
        local size = rng:NextInteger(1, 4)
        local b = rng:NextInteger(100, 255)
        local s = createStar(x, y, size, b)
        table.insert(stars, {frame = s, baseX = x, baseY = y, speed = rng:NextNumber(0.2, 1.2)})
    end

    -- Galaxy glow orbs
    local function createOrb(x, y, size, color)
        local orb = Instance.new("Frame")
        orb.Size = UDim2.new(0, size, 0, size)
        orb.Position = UDim2.new(0, x - size/2, 0, y - size/2)
        orb.BackgroundColor3 = color
        orb.BackgroundTransparency = 0.6
        orb.BorderSizePixel = 0
        orb.ZIndex = 101
        orb.Parent = bg
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = orb
        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(1, color)
        })
        gradient.Parent = orb
        return orb
    end

    createOrb(600, 350, 400, Color3.fromRGB(80, 0, 180))
    createOrb(400, 200, 250, Color3.fromRGB(0, 80, 200))
    createOrb(800, 450, 200, Color3.fromRGB(150, 0, 150))
    createOrb(600, 350, 180, Color3.fromRGB(200, 100, 255))

    -- Main title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 80)
    titleLabel.Position = UDim2.new(0, 0, 0.38, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Primejtsu"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 72
    titleLabel.ZIndex = 110
    titleLabel.Parent = bg

    -- Subtitle
    local subLabel = Instance.new("TextLabel")
    subLabel.Size = UDim2.new(1, 0, 0, 40)
    subLabel.Position = UDim2.new(0, 0, 0.76, 0)
    subLabel.BackgroundTransparency = 1
    subLabel.Text = "Flick Script GUI"
    subLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    subLabel.TextTransparency = 1
    subLabel.Font = Enum.Font.Gotham
    subLabel.TextSize = 28
    subLabel.ZIndex = 110
    subLabel.Parent = bg

    -- Divider line
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(0, 0, 0, 2)
    divider.Position = UDim2.new(0.5, 0, 0.52, 0)
    divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    divider.BackgroundTransparency = 0.3
    divider.BorderSizePixel = 0
    divider.ZIndex = 110
    divider.Parent = bg

    -- Version badge
    local versionBadge = Instance.new("Frame")
    versionBadge.Size = UDim2.new(0, 120, 0, 28)
    versionBadge.Position = UDim2.new(0.5, -60, 0.58, 0)
    versionBadge.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    versionBadge.BackgroundTransparency = 0.3
    versionBadge.BorderSizePixel = 0
    versionBadge.ZIndex = 111
    versionBadge.Visible = false
    versionBadge.Parent = bg
    local vCorner = Instance.new("UICorner")
    vCorner.CornerRadius = UDim.new(0, 8)
    vCorner.Parent = versionBadge
    local vText = Instance.new("TextLabel")
    vText.Size = UDim2.new(1,0,1,0)
    vText.BackgroundTransparency = 1
    vText.Text = "v1.0  BETA"
    vText.TextColor3 = Color3.fromRGB(180,180,180)
    vText.Font = Enum.Font.GothamBold
    vText.TextSize = 13
    vText.ZIndex = 112
    vText.Parent = versionBadge

    -- Animate: fade in title
    task.delay(0.5, function()
        TweenService:Create(titleLabel, TweenInfo.new(1.5, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
    end)
    task.delay(1.5, function()
        TweenService:Create(divider, TweenInfo.new(1, Enum.EasingStyle.Quad), {Size = UDim2.new(0.4, 0, 0, 2), Position = UDim2.new(0.3, 0, 0.52, 0)}):Play()
    end)
    task.delay(2, function()
        TweenService:Create(subLabel, TweenInfo.new(1.5, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
        versionBadge.Visible = true
    end)

    -- RGB title color cycle
    local animConn
    animConn = RunService.Heartbeat:Connect(function()
        titleLabel.TextColor3 = getRainbowColor(0)
    end)

    -- Fade out and destroy after 10 seconds
    task.delay(8, function()
        TweenService:Create(bg, TweenInfo.new(2, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
        TweenService:Create(titleLabel, TweenInfo.new(2), {TextTransparency = 1}):Play()
        TweenService:Create(subLabel, TweenInfo.new(2), {TextTransparency = 1}):Play()
        TweenService:Create(divider, TweenInfo.new(2), {BackgroundTransparency = 1}):Play()
        for _, s in ipairs(stars) do
            TweenService:Create(s.frame, TweenInfo.new(2), {BackgroundTransparency = 1}):Play()
        end
    end)
    task.delay(10, function()
        animConn:Disconnect()
        ScreenGui:Destroy()
    end)

    -- Slow star drift animation
    local driftConn
    driftConn = RunService.Heartbeat:Connect(function(dt)
        for _, s in ipairs(stars) do
            local nx = s.baseX + math.sin(tick() * s.speed + s.baseY) * 4
            s.frame.Position = UDim2.new(0, nx, 0, s.baseY)
        end
    end)
    task.delay(10.1, function()
        driftConn:Disconnect()
    end)
end

-- ================================================
-- MAIN GUI
-- ================================================
local function CreateMainGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PrimejtsuGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = LocalPlayer.PlayerGui

    -- ===== MAIN WINDOW =====
    local MainWindow = Instance.new("Frame")
    MainWindow.Name = "MainWindow"
    MainWindow.Size = UDim2.new(0, 500, 0, 420)
    MainWindow.Position = UDim2.new(0.5, -250, 0.5, -210)
    MainWindow.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    MainWindow.BorderSizePixel = 0
    MainWindow.ClipsDescendants = true
    MainWindow.Parent = ScreenGui

    local WinCorner = Instance.new("UICorner")
    WinCorner.CornerRadius = UDim.new(0, 12)
    WinCorner.Parent = MainWindow

    -- Outer RGB border stroke
    local WinStroke = Instance.new("UIStroke")
    WinStroke.Thickness = 1.5
    WinStroke.Color = Color3.fromRGB(255, 255, 255)
    WinStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    WinStroke.Parent = MainWindow

    -- ===== TOP BAR =====
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 44)
    TopBar.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    TopBar.BorderSizePixel = 0
    TopBar.ZIndex = 10
    TopBar.Parent = MainWindow

    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 12)
    TopCorner.Parent = TopBar

    -- Fix bottom corners of topbar
    local TopFix = Instance.new("Frame")
    TopFix.Size = UDim2.new(1, 0, 0, 12)
    TopFix.Position = UDim2.new(0, 0, 1, -12)
    TopFix.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    TopFix.BorderSizePixel = 0
    TopFix.Parent = TopBar

    -- Custom icon (crosshair SVG style via Frame)
    local IconFrame = Instance.new("Frame")
    IconFrame.Size = UDim2.new(0, 24, 0, 24)
    IconFrame.Position = UDim2.new(0, 12, 0.5, -12)
    IconFrame.BackgroundTransparency = 1
    IconFrame.ZIndex = 11
    IconFrame.Parent = TopBar

    local IconH = Instance.new("Frame") -- horizontal line
    IconH.Size = UDim2.new(0, 24, 0, 2)
    IconH.Position = UDim2.new(0, 0, 0.5, -1)
    IconH.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    IconH.BorderSizePixel = 0
    IconH.ZIndex = 12
    IconH.Parent = IconFrame
    local IconV = Instance.new("Frame") -- vertical line
    IconV.Size = UDim2.new(0, 2, 0, 24)
    IconV.Position = UDim2.new(0.5, -1, 0, 0)
    IconV.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    IconV.BorderSizePixel = 0
    IconV.ZIndex = 12
    IconV.Parent = IconFrame
    local IconDot = Instance.new("Frame")
    IconDot.Size = UDim2.new(0, 6, 0, 6)
    IconDot.Position = UDim2.new(0.5, -3, 0.5, -3)
    IconDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    IconDot.BorderSizePixel = 0
    IconDot.ZIndex = 13
    IconDot.Parent = IconFrame
    local IdCorner = Instance.new("UICorner")
    IdCorner.CornerRadius = UDim.new(1,0)
    IdCorner.Parent = IconDot

    -- Title text
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    TitleLabel.Position = UDim2.new(0, 44, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "Primejtsu"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 11
    TitleLabel.Parent = TopBar

    local SubLabel = Instance.new("TextLabel")
    SubLabel.Size = UDim2.new(0, 200, 1, 0)
    SubLabel.Position = UDim2.new(0, 44, 0, 18)
    SubLabel.BackgroundTransparency = 1
    SubLabel.Text = "Flick Script"
    SubLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
    SubLabel.Font = Enum.Font.Gotham
    SubLabel.TextSize = 11
    SubLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubLabel.ZIndex = 11
    SubLabel.Parent = TopBar

    -- Close button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -38, 0.5, -14)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    CloseBtn.Text = ""
    CloseBtn.ZIndex = 12
    CloseBtn.Parent = TopBar
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseBtn
    local CloseIcon = Instance.new("TextLabel")
    CloseIcon.Size = UDim2.new(1,0,1,0)
    CloseIcon.BackgroundTransparency = 1
    CloseIcon.Text = "X"
    CloseIcon.TextColor3 = Color3.fromRGB(255,255,255)
    CloseIcon.Font = Enum.Font.GothamBold
    CloseIcon.TextSize = 13
    CloseIcon.ZIndex = 13
    CloseIcon.Parent = CloseBtn

    -- Minimize button
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 28, 0, 28)
    MinBtn.Position = UDim2.new(1, -70, 0.5, -14)
    MinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    MinBtn.Text = ""
    MinBtn.ZIndex = 12
    MinBtn.Parent = TopBar
    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 6)
    MinCorner.Parent = MinBtn
    local MinIcon = Instance.new("TextLabel")
    MinIcon.Size = UDim2.new(1,0,1,0)
    MinIcon.BackgroundTransparency = 1
    MinIcon.Text = "-"
    MinIcon.TextColor3 = Color3.fromRGB(255,255,255)
    MinIcon.Font = Enum.Font.GothamBold
    MinIcon.TextSize = 18
    MinIcon.ZIndex = 13
    MinIcon.Parent = MinBtn

    -- ===== TAB BAR =====
    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1, 0, 0, 36)
    TabBar.Position = UDim2.new(0, 0, 0, 44)
    TabBar.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    TabBar.BorderSizePixel = 0
    TabBar.Parent = MainWindow

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TabLayout.Padding = UDim.new(0, 4)
    TabLayout.Parent = TabBar

    -- ===== CONTENT AREA =====
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "Content"
    ContentFrame.Size = UDim2.new(1, 0, 1, -80)
    ContentFrame.Position = UDim2.new(0, 0, 0, 80)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainWindow

    -- ===== HELPER FUNCTIONS =====
    local function MakeSection(parent, title)
        local sec = Instance.new("Frame")
        sec.Size = UDim2.new(1, -24, 0, 30)
        sec.BackgroundTransparency = 1
        sec.Parent = parent

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1,0,1,0)
        lbl.BackgroundTransparency = 1
        lbl.Text = title
        lbl.TextColor3 = Color3.fromRGB(100,100,100)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = sec

        local line = Instance.new("Frame")
        line.Size = UDim2.new(1,0,0,1)
        line.Position = UDim2.new(0,0,1,-1)
        line.BackgroundColor3 = Color3.fromRGB(35,35,35)
        line.BorderSizePixel = 0
        line.Parent = sec
        return sec
    end

    local function MakeToggle(parent, labelText, setting, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -24, 0, 36)
        row.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        row.BorderSizePixel = 0
        row.Parent = parent
        local rc = Instance.new("UICorner")
        rc.CornerRadius = UDim.new(0, 8)
        rc.Parent = row

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -60, 1, 0)
        lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = labelText
        lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row

        local toggleBg = Instance.new("Frame")
        toggleBg.Size = UDim2.new(0, 38, 0, 20)
        toggleBg.Position = UDim2.new(1, -50, 0.5, -10)
        toggleBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        toggleBg.BorderSizePixel = 0
        toggleBg.Parent = row
        local tbc = Instance.new("UICorner")
        tbc.CornerRadius = UDim.new(1, 0)
        tbc.Parent = toggleBg

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 14, 0, 14)
        knob.Position = UDim2.new(0, 3, 0.5, -7)
        knob.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
        knob.BorderSizePixel = 0
        knob.Parent = toggleBg
        local kc = Instance.new("UICorner")
        kc.CornerRadius = UDim.new(1, 0)
        kc.Parent = knob

        local state = Settings[setting] or false
        local function updateVisual()
            if state then
                TweenService:Create(toggleBg, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(220, 40, 40)}):Play()
                TweenService:Create(knob, TweenInfo.new(0.15), {Position = UDim2.new(0, 21, 0.5, -7), BackgroundColor3 = Color3.fromRGB(255,255,255)}):Play()
            else
                TweenService:Create(toggleBg, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
                TweenService:Create(knob, TweenInfo.new(0.15), {Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = Color3.fromRGB(150,150,150)}):Play()
            end
        end
        updateVisual()

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,0,1,0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.ZIndex = 5
        btn.Parent = row
        btn.MouseButton1Click:Connect(function()
            state = not state
            Settings[setting] = state
            updateVisual()
            if callback then callback(state) end
        end)

        return row
    end

    local function MakeSlider(parent, labelText, setting, minVal, maxVal, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -24, 0, 52)
        row.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        row.BorderSizePixel = 0
        row.Parent = parent
        local rc = Instance.new("UICorner")
        rc.CornerRadius = UDim.new(0, 8)
        rc.Parent = row

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.6, 0, 0, 22)
        lbl.Position = UDim2.new(0, 12, 0, 6)
        lbl.BackgroundTransparency = 1
        lbl.Text = labelText
        lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row

        local valLbl = Instance.new("TextLabel")
        valLbl.Size = UDim2.new(0.35, 0, 0, 22)
        valLbl.Position = UDim2.new(0.65, -12, 0, 6)
        valLbl.BackgroundTransparency = 1
        valLbl.Text = tostring(Settings[setting])
        valLbl.TextColor3 = Color3.fromRGB(200, 40, 40)
        valLbl.Font = Enum.Font.GothamBold
        valLbl.TextSize = 13
        valLbl.TextXAlignment = Enum.TextXAlignment.Right
        valLbl.Parent = row

        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, -24, 0, 4)
        track.Position = UDim2.new(0, 12, 0, 36)
        track.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        track.BorderSizePixel = 0
        track.Parent = row
        local trc = Instance.new("UICorner")
        trc.CornerRadius = UDim.new(1,0)
        trc.Parent = track

        local fill = Instance.new("Frame")
        local pct = (Settings[setting] - minVal) / (maxVal - minVal)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        fill.BorderSizePixel = 0
        fill.Parent = track
        local fc = Instance.new("UICorner")
        fc.CornerRadius = UDim.new(1,0)
        fc.Parent = fill

        local handle = Instance.new("Frame")
        handle.Size = UDim2.new(0, 12, 0, 12)
        handle.Position = UDim2.new(pct, -6, 0.5, -6)
        handle.BackgroundColor3 = Color3.fromRGB(255,255,255)
        handle.BorderSizePixel = 0
        handle.ZIndex = 5
        handle.Parent = track
        local hc = Instance.new("UICorner")
        hc.CornerRadius = UDim.new(1,0)
        hc.Parent = handle

        local dragging = false
        handle.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                local absPos = track.AbsolutePosition.X
                local absSize = track.AbsoluteSize.X
                local mouseX = inp.Position.X
                local ratio = math.clamp((mouseX - absPos) / absSize, 0, 1)
                local value = math.floor(minVal + ratio * (maxVal - minVal))
                Settings[setting] = value
                valLbl.Text = tostring(value)
                fill.Size = UDim2.new(ratio, 0, 1, 0)
                handle.Position = UDim2.new(ratio, -6, 0.5, -6)
                if callback then callback(value) end
            end
        end)

        return row
    end

    -- ===== CREATE TABS =====
    local tabs = {}
    local tabPages = {}
    local activeTab = nil

    local tabDefs = {
        {name = "Aim",   icon = "[+]"},
        {name = "Visual",icon = "[O]"},
        {name = "Move",  icon = "[>]"},
        {name = "Misc",  icon = "[*]"},
    }

    local function switchTab(name)
        for _, t in pairs(tabs) do
            local isActive = t.name == name
            TweenService:Create(t.btn, TweenInfo.new(0.15), {
                BackgroundColor3 = isActive and Color3.fromRGB(200, 40, 40) or Color3.fromRGB(22, 22, 22)
            }):Play()
            t.lbl.TextColor3 = isActive and Color3.fromRGB(255,255,255) or Color3.fromRGB(120,120,120)
        end
        for _, page in pairs(tabPages) do
            page.Visible = false
        end
        if tabPages[name] then tabPages[name].Visible = true end
        activeTab = name
    end

    for _, def in ipairs(tabDefs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 100, 0, 28)
        btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        btn.Text = ""
        btn.BorderSizePixel = 0
        btn.Parent = TabBar
        local bc = Instance.new("UICorner")
        bc.CornerRadius = UDim.new(0, 7)
        bc.Parent = btn

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1,0,1,0)
        lbl.BackgroundTransparency = 1
        lbl.Text = def.name
        lbl.TextColor3 = Color3.fromRGB(120,120,120)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 12
        lbl.Parent = btn

        local page = Instance.new("ScrollingFrame")
        page.Name = def.name
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = Color3.fromRGB(200, 40, 40)
        page.CanvasSize = UDim2.new(0,0,0,0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.Visible = false
        page.Parent = ContentFrame

        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.Padding = UDim.new(0, 6)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.Parent = page

        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0,10)
        padding.PaddingBottom = UDim.new(0,10)
        padding.Parent = page

        table.insert(tabs, {name = def.name, btn = btn, lbl = lbl})
        tabPages[def.name] = page

        btn.MouseButton1Click:Connect(function()
            switchTab(def.name)
        end)
    end

    -- ===== AIM TAB =====
    local aimPage = tabPages["Aim"]
    MakeSection(aimPage, "AIMBOT")
    MakeToggle(aimPage, "Aimbot", "AimBot", nil)
    MakeToggle(aimPage, "Silent Aim", "SilentAim", nil)
    MakeSlider(aimPage, "FOV Radius", "AimFOV", 50, 600, nil)
    MakeSection(aimPage, "CROSSHAIR")
    MakeToggle(aimPage, "Crosshair", "Crosshair", nil)
    MakeSlider(aimPage, "Crosshair Size", "CrosshairSize", 2, 30, nil)

    -- ===== VISUAL TAB =====
    local visPage = tabPages["Visual"]
    MakeSection(visPage, "ESP")
    MakeToggle(visPage, "Player ESP", "ESPEnabled", nil)
    MakeToggle(visPage, "Boxes", "ESPBoxes", nil)
    MakeToggle(visPage, "Names", "ESPNames", nil)
    MakeToggle(visPage, "Health Bar", "ESPHealth", nil)
    MakeToggle(visPage, "Distance", "ESPDistance", nil)
    MakeToggle(visPage, "Tracers", "ESPTracers", nil)

    -- ===== MOVE TAB =====
    local movePage = tabPages["Move"]
    MakeSection(movePage, "MOVEMENT")
    MakeToggle(movePage, "Speed Hack", "SpeedEnabled", nil)
    MakeSlider(movePage, "Speed", "SpeedValue", 16, 256, nil)
    MakeToggle(movePage, "Bunny Hop", "BunnyHop", nil)
    MakeSection(movePage, "CAMERA")
    MakeToggle(movePage, "Third Person", "ThirdPerson", nil)

    -- ===== MISC TAB =====
    local miscPage = tabPages["Misc"]
    MakeSection(miscPage, "COMBAT")
    MakeToggle(miscPage, "No Recoil", "NoRecoil", nil)
    MakeToggle(miscPage, "Auto Fire", "AutoFire", nil)
    MakeToggle(miscPage, "Infinite Ammo", "InfiniteAmmo", nil)

    -- Default tab
    switchTab("Aim")

    -- ===== FOV CIRCLE =====
    local fovCircle = Drawing.new("Circle")
    fovCircle.Visible = false
    fovCircle.Radius = Settings.AimFOV
    fovCircle.Color = Color3.fromRGB(255,255,255)
    fovCircle.Thickness = 1.2
    fovCircle.Filled = false
    fovCircle.NumSides = 64
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- ===== CROSSHAIR DRAWING =====
    local chH = Drawing.new("Line")
    chH.Visible = false
    chH.Color = Settings.CrosshairColor
    chH.Thickness = 1.5

    local chV = Drawing.new("Line")
    chV.Visible = false
    chV.Color = Settings.CrosshairColor
    chV.Thickness = 1.5

    local chDot = Drawing.new("Circle")
    chDot.Visible = false
    chDot.Color = Color3.fromRGB(255,255,255)
    chDot.Radius = 2
    chDot.Filled = true
    chDot.NumSides = 20

    -- ===== ESP DRAWINGS PER PLAYER =====
    local ESPObjects = {}

    local function getESP(player)
        if not ESPObjects[player] then
            ESPObjects[player] = {
                box      = Drawing.new("Square"),
                name     = Drawing.new("Text"),
                health   = Drawing.new("Square"),
                healthBg = Drawing.new("Square"),
                dist     = Drawing.new("Text"),
                tracer   = Drawing.new("Line"),
            }
            local e = ESPObjects[player]
            e.box.Filled = false
            e.box.Thickness = 1.5
            e.box.Color = Settings.ESPColor
            e.box.Visible = false

            e.name.Size = 13
            e.name.Color = Color3.fromRGB(255,255,255)
            e.name.Font = 2
            e.name.Outline = true
            e.name.Visible = false

            e.dist.Size = 11
            e.dist.Color = Color3.fromRGB(200,200,200)
            e.dist.Font = 2
            e.dist.Outline = true
            e.dist.Visible = false

            e.healthBg.Filled = true
            e.healthBg.Color = Color3.fromRGB(30,30,30)
            e.healthBg.Visible = false

            e.health.Filled = true
            e.health.Color = Color3.fromRGB(50,200,50)
            e.health.Visible = false

            e.tracer.Thickness = 1
            e.tracer.Color = Settings.ESPColor
            e.tracer.Visible = false
        end
        return ESPObjects[player]
    end

    local function clearESP(player)
        if ESPObjects[player] then
            for _, d in pairs(ESPObjects[player]) do
                d.Visible = false
            end
            ESPObjects[player] = nil
        end
    end

    Players.PlayerRemoving:Connect(clearESP)

    -- ===== DRAG TOPBAR =====
    local dragging = false
    local dragStart, startPos

    TopBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = inp.Position
            startPos = MainWindow.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = inp.Position - dragStart
            MainWindow.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    -- Close / Minimize
    local minimized = false
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        for _, d in pairs(ESPObjects) do
            for _, obj in pairs(d) do obj.Visible = false end
        end
        fovCircle.Visible = false
        chH.Visible = false
        chV.Visible = false
        chDot.Visible = false
    end)
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        ContentFrame.Visible = not minimized
        TabBar.Visible = not minimized
        local newH = minimized and 44 or 420
        TweenService:Create(MainWindow, TweenInfo.new(0.2), {Size = UDim2.new(0, 500, 0, newH)}):Play()
    end)

    -- ===== MAIN LOOP =====
    RunService.Heartbeat:Connect(function(dt)
        -- RGB border
        WinStroke.Color = getRainbowColor(0)
        TitleLabel.TextColor3 = getRainbowColor(0.1)

        local vp = Camera.ViewportSize
        local cx, cy = vp.X / 2, vp.Y / 2

        -- Crosshair
        if Settings.Crosshair then
            local s = Settings.CrosshairSize
            chH.Visible = true
            chH.From = Vector2.new(cx - s, cy)
            chH.To = Vector2.new(cx + s, cy)
            chH.Color = getRainbowColor(0.2)
            chV.Visible = true
            chV.From = Vector2.new(cx, cy - s)
            chV.To = Vector2.new(cx, cy + s)
            chV.Color = getRainbowColor(0.2)
            chDot.Visible = true
            chDot.Position = Vector2.new(cx, cy)
        else
            chH.Visible = false
            chV.Visible = false
            chDot.Visible = false
        end

        -- FOV circle
        fovCircle.Visible = Settings.AimBot
        fovCircle.Radius = Settings.AimFOV
        fovCircle.Position = Vector2.new(cx, cy)

        -- Speed
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                if Settings.SpeedEnabled then
                    hum.WalkSpeed = Settings.SpeedValue
                else
                    if hum.WalkSpeed ~= 16 and not Settings.SpeedEnabled then
                        hum.WalkSpeed = 16
                    end
                end
                -- Bunny hop
                if Settings.BunnyHop and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    hum.Jump = true
                end
            end
            -- Third person
            if Settings.ThirdPerson then
                Camera.CameraType = Enum.CameraType.Attach
            end
        end

        -- Aimbot
        if Settings.AimBot then
            local closest = nil
            local closestDist = Settings.AimFOV
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local target = p.Character:FindFirstChild(Settings.AimPart)
                    if target then
                        local _, onScreen = Camera:WorldToViewportPoint(target.Position)
                        if onScreen then
                            local screenPos = Camera:WorldToViewportPoint(target.Position)
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(cx, cy)).Magnitude
                            if dist < closestDist then
                                closestDist = dist
                                closest = target
                            end
                        end
                    end
                end
            end
            if closest then
                local targetCF = CFrame.new(Camera.CFrame.Position, closest.Position)
                Camera.CFrame = Camera.CFrame:Lerp(targetCF, Settings.AimSmooth)
            end
        end

        -- ESP
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            local e = getESP(p)
            local char2 = p.Character
            local showESP = Settings.ESPEnabled and char2 ~= nil

            if showESP then
                local root = char2:FindFirstChild("HumanoidRootPart")
                local hum2 = char2:FindFirstChildOfClass("Humanoid")
                if root and hum2 then
                    local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    if onScreen then
                        local topPos = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
                        local botPos = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, -3, 0))
                        local height = math.abs(topPos.Y - botPos.Y)
                        local width = height * 0.5
                        local bx = rootPos.X - width / 2
                        local by = topPos.Y

                        -- Box
                        if Settings.ESPBoxes then
                            e.box.Visible = true
                            e.box.Position = Vector2.new(bx, by)
                            e.box.Size = Vector2.new(width, height)
                            e.box.Color = Settings.ESPColor
                        else
                            e.box.Visible = false
                        end

                        -- Name
                        if Settings.ESPNames then
                            e.name.Visible = true
                            e.name.Position = Vector2.new(rootPos.X, by - 16)
                            e.name.Text = p.DisplayName
                            e.name.Color = Color3.fromRGB(255,255,255)
                        else
                            e.name.Visible = false
                        end

                        -- Distance
                        if Settings.ESPDistance then
                            local dist2 = math.floor((Camera.CFrame.Position - root.Position).Magnitude)
                            e.dist.Visible = true
                            e.dist.Position = Vector2.new(rootPos.X, by + height + 2)
                            e.dist.Text = dist2 .. "m"
                        else
                            e.dist.Visible = false
                        end

                        -- Health
                        if Settings.ESPHealth then
                            local hp = hum2.Health / hum2.MaxHealth
                            local barH = height
                            local barX = bx - 8
                            e.healthBg.Visible = true
                            e.healthBg.Position = Vector2.new(barX, by)
                            e.healthBg.Size = Vector2.new(4, barH)
                            e.health.Visible = true
                            e.health.Position = Vector2.new(barX, by + barH * (1 - hp))
                            e.health.Size = Vector2.new(4, barH * hp)
                            local r = math.floor(255 * (1 - hp))
                            local g = math.floor(255 * hp)
                            e.health.Color = Color3.fromRGB(r, g, 0)
                        else
                            e.healthBg.Visible = false
                            e.health.Visible = false
                        end

                        -- Tracer
                        if Settings.ESPTracers then
                            e.tracer.Visible = true
                            e.tracer.From = Vector2.new(cx, vp.Y)
                            e.tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                            e.tracer.Color = Settings.ESPColor
                        else
                            e.tracer.Visible = false
                        end
                    else
                        for _, d in pairs(e) do d.Visible = false end
                    end
                end
            else
                for _, d in pairs(e) do d.Visible = false end
            end
        end
    end)

    return ScreenGui
end

-- ================================================
-- LAUNCH
-- ================================================
CreateGalaxyAnimation()
task.delay(10.2, function()
    CreateMainGUI()
end)
