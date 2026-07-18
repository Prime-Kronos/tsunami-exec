-- ================================================
--   [FPS] FLICK — PROFESSIONAL EXPLOIT SCRIPT v2
--   GUI: Draggable, Collapsible, Tabbed
--   Features: Aimbot+FOV, ESP, Noclip, Speed,
--             Fly, Silent Aim, Anti-AFK, BHop
-- ================================================

local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UIS            = game:GetService("UserInputService")
local TweenService   = game:GetService("TweenService")
local Camera         = workspace.CurrentCamera

local lp = Players.LocalPlayer
local character = lp.Character or lp.CharacterAdded:Wait()
local humanoid  = character:WaitForChild("Humanoid")
local rootPart  = character:WaitForChild("HumanoidRootPart")

-- ================================================
--  CONFIG
-- ================================================
local CFG = {
    aimbot      = false,
    silentAim   = false,
    esp         = false,
    noclip      = false,
    speed       = false,
    fly         = false,
    bhop        = false,
    antiAfk     = false,
    fovSize     = 120,       -- радиус FOV круга (px)
    aimSmooth   = 0.18,      -- плавность (0.05 резкий, 0.3 мягкий)
    walkSpeed   = 85,
    flySpeed    = 65,
}

-- ================================================
--  STATE
-- ================================================
local bv, bg          -- BodyVelocity / BodyGyro
local highlights = {}
local minimized  = false
local currentTab = "COMBAT"

-- ================================================
--  GUI ROOT
-- ================================================
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn  = false
gui.Name          = "FlickPro"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent        = lp.PlayerGui

-- ================================================
--  HELPERS
-- ================================================
local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thick)
    local s = Instance.new("UIStroke")
    s.Color     = color or Color3.fromRGB(80,80,100)
    s.Thickness = thick or 1
    s.Parent    = parent
end

local function label(parent, text, size, color, font, xAlign)
    local l = Instance.new("TextLabel")
    l.Text                = text
    l.Size                = size
    l.BackgroundTransparency = 1
    l.TextColor3          = color or Color3.fromRGB(220,220,230)
    l.Font                = font  or Enum.Font.Gotham
    l.TextSize            = 12
    l.TextXAlignment      = xAlign or Enum.TextXAlignment.Left
    l.Parent              = parent
    return l
end

-- ================================================
--  MAIN WINDOW  (400 x 340)
-- ================================================
local win = Instance.new("Frame")
win.Size            = UDim2.new(0, 400, 0, 340)
win.Position        = UDim2.new(0, 30, 0, 80)
win.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
win.BorderSizePixel = 0
win.ClipsDescendants = true
win.Parent          = gui
corner(win, 12)
stroke(win, Color3.fromRGB(60, 60, 80), 1.5)

-- ===== TITLEBAR =====
local bar = Instance.new("Frame")
bar.Size            = UDim2.new(1, 0, 0, 38)
bar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
bar.BorderSizePixel = 0
bar.Parent          = win
corner(bar, 12)

local barFix = Instance.new("Frame")
barFix.Size              = UDim2.new(1, 0, 0.5, 0)
barFix.Position          = UDim2.new(0, 0, 0.5, 0)
barFix.BackgroundColor3  = Color3.fromRGB(20, 20, 30)
barFix.BorderSizePixel   = 0
barFix.Parent            = bar

-- accent line under titlebar
local accent = Instance.new("Frame")
accent.Size              = UDim2.new(1, 0, 0, 2)
accent.Position          = UDim2.new(0, 0, 1, -2)
accent.BackgroundColor3  = Color3.fromRGB(90, 60, 200)
accent.BorderSizePixel   = 0
accent.Parent            = bar

local titleTxt = Instance.new("TextLabel")
titleTxt.Text            = "FLICK PRO  |  [FPS] FLICK"
titleTxt.Size            = UDim2.new(0.6, 0, 1, 0)
titleTxt.Position        = UDim2.new(0, 12, 0, 0)
titleTxt.BackgroundTransparency = 1
titleTxt.TextColor3      = Color3.fromRGB(255, 255, 255)
titleTxt.Font            = Enum.Font.GothamBold
titleTxt.TextSize        = 13
titleTxt.TextXAlignment  = Enum.TextXAlignment.Left
titleTxt.Parent          = bar

-- minimize / close buttons
local function headerBtn(xOff, bgColor, txt)
    local b = Instance.new("TextButton")
    b.Size            = UDim2.new(0, 26, 0, 22)
    b.Position        = UDim2.new(1, xOff, 0.5, -11)
    b.BackgroundColor3 = bgColor
    b.TextColor3      = Color3.fromRGB(255,255,255)
    b.Font            = Enum.Font.GothamBold
    b.TextSize        = 13
    b.Text            = txt
    b.BorderSizePixel = 0
    b.Parent          = bar
    corner(b, 6)
    return b
end

local minBtn   = headerBtn(-60, Color3.fromRGB(200,150,0), "_")
local closeBtn = headerBtn(-30, Color3.fromRGB(200,50,50),  "X")

-- ===== TABS ROW =====
local tabRow = Instance.new("Frame")
tabRow.Size            = UDim2.new(1, 0, 0, 32)
tabRow.Position        = UDim2.new(0, 0, 0, 38)
tabRow.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
tabRow.BorderSizePixel = 0
tabRow.Parent          = win

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection      = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
tabLayout.SortOrder          = Enum.SortOrder.LayoutOrder
tabLayout.Padding            = UDim.new(0, 2)
tabLayout.Parent             = tabRow

local tabPad = Instance.new("UIPadding")
tabPad.PaddingLeft = UDim.new(0, 6)
tabPad.Parent      = tabRow

-- ===== CONTENT AREA =====
local contentArea = Instance.new("Frame")
contentArea.Size            = UDim2.new(1, 0, 1, -70)
contentArea.Position        = UDim2.new(0, 0, 0, 70)
contentArea.BackgroundTransparency = 1
contentArea.Parent          = win

-- ================================================
--  TAB SYSTEM
-- ================================================
local tabBtns   = {}
local tabPages  = {}
local TABS      = {"COMBAT", "MOVEMENT", "VISUAL", "MISC"}

for i, name in ipairs(TABS) do
    local tb = Instance.new("TextButton")
    tb.Size            = UDim2.new(0, 88, 1, -6)
    tb.BackgroundColor3 = Color3.fromRGB(24,24,36)
    tb.TextColor3      = Color3.fromRGB(130,130,160)
    tb.Font            = Enum.Font.GothamBold
    tb.TextSize        = 11
    tb.Text            = name
    tb.BorderSizePixel = 0
    tb.LayoutOrder     = i
    tb.Parent          = tabRow
    corner(tb, 7)
    tabBtns[name] = tb

    local page = Instance.new("ScrollingFrame")
    page.Size             = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel  = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(90,60,200)
    page.Visible          = (name == "COMBAT")
    page.Parent           = contentArea
    tabPages[name] = page

    local layout = Instance.new("UIListLayout")
    layout.SortOrder  = Enum.SortOrder.LayoutOrder
    layout.Padding    = UDim.new(0, 6)
    layout.Parent     = page

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft   = UDim.new(0, 10)
    pad.PaddingRight  = UDim.new(0, 10)
    pad.PaddingTop    = UDim.new(0, 8)
    pad.Parent        = page
end

local function selectTab(name)
    currentTab = name
    for n, btn in pairs(tabBtns) do
        if n == name then
            btn.BackgroundColor3 = Color3.fromRGB(90,60,200)
            btn.TextColor3       = Color3.fromRGB(255,255,255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(24,24,36)
            btn.TextColor3       = Color3.fromRGB(130,130,160)
        end
        tabPages[n].Visible = (n == name)
    end
end
selectTab("COMBAT")

for _, name in ipairs(TABS) do
    tabBtns[name].MouseButton1Click:Connect(function()
        selectTab(name)
    end)
end

-- ================================================
--  TOGGLE BUTTON FACTORY
-- ================================================
local function makeToggle(page, labelText, order)
    local row = Instance.new("Frame")
    row.Size            = UDim2.new(1, 0, 0, 46)
    row.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    row.BorderSizePixel = 0
    row.LayoutOrder     = order
    row.Parent          = page
    corner(row, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Text            = labelText
    lbl.Size            = UDim2.new(0.65, 0, 1, 0)
    lbl.Position        = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3      = Color3.fromRGB(210,210,225)
    lbl.Font            = Enum.Font.GothamBold
    lbl.TextSize        = 12
    lbl.TextXAlignment  = Enum.TextXAlignment.Left
    lbl.Parent          = row

    -- Toggle pill
    local pill = Instance.new("Frame")
    pill.Size            = UDim2.new(0, 46, 0, 24)
    pill.Position        = UDim2.new(1, -58, 0.5, -12)
    pill.BackgroundColor3 = Color3.fromRGB(45,45,60)
    pill.BorderSizePixel = 0
    pill.Parent          = row
    corner(pill, 12)

    local knob = Instance.new("Frame")
    knob.Size            = UDim2.new(0, 18, 0, 18)
    knob.Position        = UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(160,160,180)
    knob.BorderSizePixel = 0
    knob.Parent          = pill
    corner(knob, 9)

    local active = false
    local clickable = Instance.new("TextButton")
    clickable.Size               = UDim2.new(1,0,1,0)
    clickable.BackgroundTransparency = 1
    clickable.Text               = ""
    clickable.Parent             = row

    local function setOn(state)
        active = state
        local goal = state and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)
        local pillColor = state and Color3.fromRGB(90,60,200) or Color3.fromRGB(45,45,60)
        local knobColor = state and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,160,180)
        TweenService:Create(knob, TweenInfo.new(0.15), {Position=goal, BackgroundColor3=knobColor}):Play()
        TweenService:Create(pill, TweenInfo.new(0.15), {BackgroundColor3=pillColor}):Play()
    end

    clickable.MouseButton1Click:Connect(function()
        setOn(not active)
    end)

    return clickable, function() return active end, setOn
end

-- ================================================
--  SLIDER FACTORY
-- ================================================
local function makeSlider(page, labelText, minVal, maxVal, defaultVal, order)
    local row = Instance.new("Frame")
    row.Size            = UDim2.new(1, 0, 0, 54)
    row.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    row.BorderSizePixel = 0
    row.LayoutOrder     = order
    row.Parent          = page
    corner(row, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size            = UDim2.new(0.6, 0, 0, 22)
    lbl.Position        = UDim2.new(0, 12, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3      = Color3.fromRGB(210,210,225)
    lbl.Font            = Enum.Font.GothamBold
    lbl.TextSize        = 12
    lbl.TextXAlignment  = Enum.TextXAlignment.Left
    lbl.Text            = labelText
    lbl.Parent          = row

    local valLbl = Instance.new("TextLabel")
    valLbl.Size         = UDim2.new(0.35, 0, 0, 22)
    valLbl.Position     = UDim2.new(0.62, 0, 0, 4)
    valLbl.BackgroundTransparency = 1
    valLbl.TextColor3   = Color3.fromRGB(90,60,200)
    valLbl.Font         = Enum.Font.GothamBold
    valLbl.TextSize     = 12
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Text         = tostring(defaultVal)
    valLbl.Parent       = row

    local track = Instance.new("Frame")
    track.Size          = UDim2.new(1, -24, 0, 6)
    track.Position      = UDim2.new(0, 12, 0, 34)
    track.BackgroundColor3 = Color3.fromRGB(40,40,55)
    track.BorderSizePixel = 0
    track.Parent        = row
    corner(track, 3)

    local fill = Instance.new("Frame")
    fill.Size           = UDim2.new((defaultVal - minVal)/(maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(90,60,200)
    fill.BorderSizePixel = 0
    fill.Parent         = track
    corner(fill, 3)

    local value = defaultVal
    local dragging = false

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging then
            local rel = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            rel = math.clamp(rel, 0, 1)
            value = math.floor(minVal + (maxVal - minVal) * rel)
            fill.Size  = UDim2.new(rel, 0, 1, 0)
            valLbl.Text = tostring(value)
        end
    end)

    return function() return value end
end

-- ================================================
--  BUILD COMBAT TAB
-- ================================================
local combatPage = tabPages["COMBAT"]

local aimbotClick, aimbotOn, aimbotSet = makeToggle(combatPage, "Aimbot", 1)
local silentClick, silentOn, silentSet = makeToggle(combatPage, "Silent Aim", 2)
local getFov   = makeSlider(combatPage, "FOV Size", 40, 300, 120, 3)
local getSmooth = makeSlider(combatPage, "Aim Smooth (x10)", 1, 10, 2, 4)

-- ================================================
--  BUILD MOVEMENT TAB
-- ================================================
local movePage = tabPages["MOVEMENT"]
local speedClick, speedOn, speedSet     = makeToggle(movePage, "Speed Boost", 1)
local flyClick,   flyOn,   flySet       = makeToggle(movePage, "Fly", 2)
local noclipClick,noclipOn,noclipSet    = makeToggle(movePage, "Noclip", 3)
local bhopClick,  bhopOn,  bhopSet      = makeToggle(movePage, "Bunny Hop", 4)
local getWalkSpd = makeSlider(movePage, "Walk Speed", 16, 250, 85, 5)
local getFlySpd  = makeSlider(movePage, "Fly Speed",  20, 200, 65, 6)

-- ================================================
--  BUILD VISUAL TAB
-- ================================================
local visPage = tabPages["VISUAL"]
local espClick,   espOn,   espSet       = makeToggle(visPage, "ESP / Highlight", 1)
local chamsClick, chamsOn, chamsSet     = makeToggle(visPage, "Chams (Fill)", 2)

-- ================================================
--  BUILD MISC TAB
-- ================================================
local miscPage = tabPages["MISC"]
local afkClick,   afkOn,   afkSet       = makeToggle(miscPage, "Anti-AFK", 1)
local infJumpClick,infJumpOn,infJumpSet = makeToggle(miscPage, "Infinite Jump", 2)

-- ================================================
--  FOV CIRCLE DRAWING
-- ================================================
local fovCircle = Drawing.new("Circle")
fovCircle.Visible   = false
fovCircle.Thickness = 1.5
fovCircle.Color     = Color3.fromRGB(255, 255, 255)
fovCircle.Filled    = false
fovCircle.NumSides  = 64

-- ================================================
--  AIMBOT LOGIC
-- ================================================
local function getClosestEnemy()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local best, bestDist = nil, getFov()

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local head = p.Character:FindFirstChild("Head")
            if head then
                local sPos, onScreen = Camera:WorldToScreenPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(sPos.X, sPos.Y) - center).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        best = head
                    end
                end
            end
        end
    end
    return best
end

-- ================================================
--  ESP LOGIC
-- ================================================
local function applyESP(p)
    if p == lp then return end
    local function apply(char)
        if highlights[p] then highlights[p]:Destroy() end
        local hl = Instance.new("Highlight")
        hl.FillColor         = chamsOn() and Color3.fromRGB(255,50,50) or Color3.fromRGB(0,0,0)
        hl.OutlineColor      = Color3.fromRGB(255,255,255)
        hl.FillTransparency  = chamsOn() and 0.5 or 1
        hl.OutlineTransparency = 0
        hl.Adornee           = char
        hl.Parent            = char
        highlights[p]        = hl
    end
    if p.Character then apply(p.Character) end
    p.CharacterAdded:Connect(apply)
end

local function clearESP()
    for _, hl in pairs(highlights) do hl:Destroy() end
    highlights = {}
end

-- ================================================
--  FLY LOGIC
-- ================================================
local function startFly()
    humanoid.PlatformStand = true
    bv = Instance.new("BodyVelocity")
    bv.Velocity   = Vector3.new(0,0,0)
    bv.MaxForce   = Vector3.new(1e5,1e5,1e5)
    bv.Parent     = rootPart
    bg = Instance.new("BodyGyro")
    bg.MaxTorque  = Vector3.new(1e5,1e5,1e5)
    bg.P          = 1e4
    bg.Parent     = rootPart
end

local function stopFly()
    humanoid.PlatformStand = false
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
end

-- ================================================
--  ANTI-AFK
-- ================================================
local afkConn
local function startAntiAfk()
    afkConn = RunService.Heartbeat:Connect(function()
        lp:Move(Vector3.new(0,0,0))
    end)
    local vrs = lp:FindFirstChildOfClass("VirtualUser")
    if vrs then
        vrs:Button2Down(Vector2.new(0,0), CFrame.new())
        task.wait(0.1)
        vrs:Button2Up(Vector2.new(0,0), CFrame.new())
    end
end
local function stopAntiAfk()
    if afkConn then afkConn:Disconnect() end
end

-- ================================================
--  BUTTON CONNECTIONS
-- ================================================
espClick.MouseButton1Click:Connect(function()
    if espOn() then
        for _, p in pairs(Players:GetPlayers()) do applyESP(p) end
        Players.PlayerAdded:Connect(applyESP)
    else
        clearESP()
    end
end)

flyClick.MouseButton1Click:Connect(function()
    if flyOn() then startFly() else stopFly() end
end)

afkClick.MouseButton1Click:Connect(function()
    if afkOn() then startAntiAfk() else stopAntiAfk() end
end)

-- ================================================
--  MAIN LOOP
-- ================================================
RunService.Heartbeat:Connect(function()
    -- Noclip
    if noclipOn() then
        for _, p in pairs(character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end

    -- Speed
    humanoid.WalkSpeed = speedOn() and getWalkSpd() or 16

    -- BHop
    if bhopOn() and humanoid:GetState() == Enum.HumanoidStateType.Freefall then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    -- Infinite Jump
    if infJumpOn() and UIS:IsKeyDown(Enum.KeyCode.Space) then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    -- FOV Circle
    local fovRadius = getFov()
    local center2   = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    fovCircle.Position = center2
    fovCircle.Radius   = fovRadius
    fovCircle.Visible  = aimbotOn() or silentOn()

    -- Aimbot
    if aimbotOn() then
        local target = getClosestEnemy()
        if target then
            local smooth = getSmooth() / 10
            Camera.CFrame = Camera.CFrame:Lerp(
                CFrame.new(Camera.CFrame.Position, target.Position),
                smooth
            )
        end
    end

    -- Fly movement
    if flyOn() and bv and bg then
        local spd = getFlySpd()
        local dir = Vector3.new(0,0,0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space)     then dir = dir + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
        bv.Velocity  = dir * spd
        bg.CFrame    = Camera.CFrame
    end
end)

-- ================================================
--  DRAG TITLEBAR
-- ================================================
local dragging, dragStart, winStart = false, nil, nil

bar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        dragging  = true
        dragStart = input.Position
        winStart  = win.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
       input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragStart
        win.Position = UDim2.new(
            winStart.X.Scale, winStart.X.Offset + d.X,
            winStart.Y.Scale, winStart.Y.Offset + d.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ================================================
--  MINIMIZE / CLOSE
-- ================================================
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(win, TweenInfo.new(0.2), {Size = UDim2.new(0,400,0,38)}):Play()
        minBtn.Text = "+"
    else
        TweenService:Create(win, TweenInfo.new(0.2), {Size = UDim2.new(0,400,0,340)}):Play()
        minBtn.Text = "_"
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    fovCircle:Remove()
    gui:Destroy()
end)

-- ================================================
--  RESPAWN HANDLER
-- ================================================
lp.CharacterAdded:Connect(function(char)
    character = char
    humanoid  = char:WaitForChild("Humanoid")
    rootPart  = char:WaitForChild("HumanoidRootPart")
    flySet(false); noclipSet(false); speedSet(false)
    bhopSet(false); infJumpSet(false)
end)

print("[FLICK PRO] Loaded successfully")
