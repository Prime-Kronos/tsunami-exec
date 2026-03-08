-- ╔══════════════════════════════════════╗
-- ║        RIVALS HUB V2 by Prime        ║
-- ║     Enhanced GUI + Silent Aim        ║
-- ╚══════════════════════════════════════╝

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ===================== SETTINGS =====================
local Settings = {
    AimFOV = 120,
    AimbotEnabled = false,
    SilentAimEnabled = false,
    ESPEnabled = false,
    SpeedEnabled = false,
    NoclipEnabled = false,
    InfiniteAmmoEnabled = false,
    BunnyHopEnabled = false,
    AntiAFKEnabled = true,
    AimPart = "Head",
    SpeedValue = 40,
    SilentAimPrediction = true,
}

-- ===================== GUI SETUP =====================
pcall(function()
    if game.CoreGui:FindFirstChild("RivalsHubV2") then
        game.CoreGui:FindFirstChild("RivalsHubV2"):Destroy()
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RivalsHubV2"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = game.CoreGui

-- ===================== FOV CIRCLE =====================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = Settings.AimFOV
FOVCircle.Color = Color3.fromRGB(255, 60, 60)
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.NumSides = 64
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Radius = Settings.AimFOV
end)

-- ===================== KEYBIND OPEN/CLOSE (RightShift) =====================
local guiOpen = true

-- ===================== TOGGLE BUTTON (всегда видна) =====================
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 36, 0, 36)
ToggleBtn.Position = UDim2.new(0, 10, 0.5, -18)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
ToggleBtn.Text = "⚡"
ToggleBtn.TextSize = 18
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.ZIndex = 999
ToggleBtn.Parent = ScreenGui

local UICornerTB = Instance.new("UICorner")
UICornerTB.CornerRadius = UDim.new(0, 8)
UICornerTB.Parent = ToggleBtn

-- ===================== MAIN FRAME =====================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 310, 0, 520)
MainFrame.Position = UDim2.new(0, 54, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 10)
UICornerMain.Parent = MainFrame

local UIStrokeMain = Instance.new("UIStroke")
UIStrokeMain.Color = Color3.fromRGB(200, 30, 30)
UIStrokeMain.Thickness = 1.5
UIStrokeMain.Parent = MainFrame

-- Animated gradient top bar
local TopGradient = Instance.new("Frame")
TopGradient.Size = UDim2.new(1, 0, 0, 3)
TopGradient.Position = UDim2.new(0, 0, 0, 0)
TopGradient.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
TopGradient.BorderSizePixel = 0
TopGradient.ZIndex = 5
TopGradient.Parent = MainFrame

local UIGrad = Instance.new("UIGradient")
UIGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 30, 30)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 120, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 30, 30)),
})
UIGrad.Parent = TopGradient

-- Animate gradient
local rot = 0
RunService.Heartbeat:Connect(function(dt)
    rot = rot + dt * 30
    if rot > 360 then rot = 0 end
    UIGrad.Rotation = rot
end)

-- ===================== TITLE BAR =====================
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 44)
TitleBar.BackgroundColor3 = Color3.fromRGB(16, 16, 24)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ RIVALS HUB V2"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local VersionLabel = Instance.new("TextLabel")
VersionLabel.Size = UDim2.new(0, 80, 1, 0)
VersionLabel.Position = UDim2.new(1, -90, 0, 0)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Text = "by Prime"
VersionLabel.TextColor3 = Color3.fromRGB(180, 60, 60)
VersionLabel.TextSize = 11
VersionLabel.Font = Enum.Font.Gotham
VersionLabel.TextXAlignment = Enum.TextXAlignment.Right
VersionLabel.Parent = TitleBar

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -36, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar

local UICornerClose = Instance.new("UICorner")
UICornerClose.CornerRadius = UDim.new(0, 6)
UICornerClose.Parent = CloseBtn

-- ===================== SCROLL CONTENT =====================
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, 0, 1, -48)
ScrollFrame.Position = UDim2.new(0, 0, 0, 48)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 3
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(200, 30, 30)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 6)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.Parent = ScrollFrame

local UIPad = Instance.new("UIPaddingConstraint" ~= nil and "UIPadding" or "UIPadding")
UIPad.PaddingTop = UDim.new(0, 8)
UIPad.PaddingBottom = UDim.new(0, 8)
UIPad.Parent = ScrollFrame

-- ===================== SECTION LABEL =====================
local function createSection(text)
    local sec = Instance.new("TextLabel")
    sec.Size = UDim2.new(1, -20, 0, 22)
    sec.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
    sec.Text = "  " .. text
    sec.TextColor3 = Color3.fromRGB(255, 255, 255)
    sec.TextSize = 11
    sec.Font = Enum.Font.GothamBold
    sec.TextXAlignment = Enum.TextXAlignment.Left
    sec.BorderSizePixel = 0
    sec.Parent = ScrollFrame

    local UICornerSec = Instance.new("UICorner")
    UICornerSec.CornerRadius = UDim.new(0, 5)
    UICornerSec.Parent = sec

    local UIGradSec = Instance.new("UIGradient")
    UIGradSec.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 30, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 10, 10)),
    })
    UIGradSec.Rotation = 90
    UIGradSec.Parent = sec
end

-- ===================== TOGGLE FUNCTION =====================
local function createToggle(name, icon, settingKey, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -20, 0, 42)
    row.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    row.BorderSizePixel = 0
    row.Parent = ScrollFrame

    local UICornerRow = Instance.new("UICorner")
    UICornerRow.CornerRadius = UDim.new(0, 8)
    UICornerRow.Parent = row

    local UIStrokeRow = Instance.new("UIStroke")
    UIStrokeRow.Color = Color3.fromRGB(35, 35, 50)
    UIStrokeRow.Thickness = 1
    UIStrokeRow.Parent = row

    local iconLbl = Instance.new("TextLabel")
    iconLbl.Size = UDim2.new(0, 30, 1, 0)
    iconLbl.Position = UDim2.new(0, 8, 0, 0)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text = icon
    iconLbl.TextSize = 16
    iconLbl.Font = Enum.Font.GothamBold
    iconLbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    iconLbl.Parent = row

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -100, 1, 0)
    nameLbl.Position = UDim2.new(0, 42, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = name
    nameLbl.TextSize = 12
    nameLbl.Font = Enum.Font.GothamSemibold
    nameLbl.TextColor3 = Color3.fromRGB(210, 210, 210)
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = row

    -- Toggle pill
    local pillBG = Instance.new("Frame")
    pillBG.Size = UDim2.new(0, 44, 0, 22)
    pillBG.Position = UDim2.new(1, -52, 0.5, -11)
    pillBG.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    pillBG.BorderSizePixel = 0
    pillBG.Parent = row

    local UICornerPill = Instance.new("UICorner")
    UICornerPill.CornerRadius = UDim.new(1, 0)
    UICornerPill.Parent = pillBG

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 16, 0, 16)
    dot.Position = UDim2.new(0, 3, 0.5, -8)
    dot.BackgroundColor3 = Color3.fromRGB(160, 160, 180)
    dot.BorderSizePixel = 0
    dot.Parent = pillBG

    local UICornerDot = Instance.new("UICorner")
    UICornerDot.CornerRadius = UDim.new(1, 0)
    UICornerDot.Parent = dot

    local function setState(state)
        Settings[settingKey] = state
        local tweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad)
        if state then
            TweenService:Create(pillBG, tweenInfo, {BackgroundColor3 = Color3.fromRGB(200, 30, 30)}):Play()
            TweenService:Create(dot, tweenInfo, {Position = UDim2.new(0, 25, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255,255,255)}):Play()
            TweenService:Create(row, tweenInfo, {BackgroundColor3 = Color3.fromRGB(28, 14, 14)}):Play()
        else
            TweenService:Create(pillBG, tweenInfo, {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}):Play()
            TweenService:Create(dot, tweenInfo, {Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = Color3.fromRGB(160,160,180)}):Play()
            TweenService:Create(row, tweenInfo, {BackgroundColor3 = Color3.fromRGB(18, 18, 28)}):Play()
        end
        if callback then callback(state) end
    end

    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.Parent = row
    clickBtn.MouseButton1Click:Connect(function()
        setState(not Settings[settingKey])
    end)

    setState(Settings[settingKey])
end

-- ===================== SLIDER FUNCTION =====================
local function createSlider(name, icon, min, max, default, onChange)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -20, 0, 60)
    row.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    row.BorderSizePixel = 0
    row.Parent = ScrollFrame

    local UICornerRow = Instance.new("UICorner")
    UICornerRow.CornerRadius = UDim.new(0, 8)
    UICornerRow.Parent = row

    local UIStrokeRow = Instance.new("UIStroke")
    UIStrokeRow.Color = Color3.fromRGB(35, 35, 50)
    UIStrokeRow.Thickness = 1
    UIStrokeRow.Parent = row

    local topRow = Instance.new("Frame")
    topRow.Size = UDim2.new(1, 0, 0, 28)
    topRow.BackgroundTransparency = 1
    topRow.Parent = row

    local iconLbl = Instance.new("TextLabel")
    iconLbl.Size = UDim2.new(0, 28, 1, 0)
    iconLbl.Position = UDim2.new(0, 8, 0, 0)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text = icon
    iconLbl.TextSize = 15
    iconLbl.Font = Enum.Font.GothamBold
    iconLbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    iconLbl.Parent = topRow

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -100, 1, 0)
    nameLbl.Position = UDim2.new(0, 40, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = name
    nameLbl.TextSize = 12
    nameLbl.Font = Enum.Font.GothamSemibold
    nameLbl.TextColor3 = Color3.fromRGB(210, 210, 210)
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = topRow

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 50, 1, 0)
    valLbl.Position = UDim2.new(1, -58, 0, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(default)
    valLbl.TextSize = 12
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextColor3 = Color3.fromRGB(200, 30, 30)
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = topRow

    -- Slider track
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 6)
    track.Position = UDim2.new(0, 10, 0, 38)
    track.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    track.BorderSizePixel = 0
    track.Parent = row

    local UICornerTrack = Instance.new("UICorner")
    UICornerTrack.CornerRadius = UDim.new(1, 0)
    UICornerTrack.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
    fill.BorderSizePixel = 0
    fill.Parent = track

    local UICornerFill = Instance.new("UICorner")
    UICornerFill.CornerRadius = UDim.new(1, 0)
    UICornerFill.Parent = fill

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 14, 0, 14)
    thumb.AnchorPoint = Vector2.new(0.5, 0.5)
    thumb.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.BorderSizePixel = 0
    thumb.Parent = track

    local UICornerThumb = Instance.new("UICorner")
    UICornerThumb.CornerRadius = UDim.new(1, 0)
    UICornerThumb.Parent = thumb

    local dragging = false
    local currentVal = default

    local function updateSlider(input)
        local trackPos = track.AbsolutePosition.X
        local trackWidth = track.AbsoluteSize.X
        local relX = math.clamp((input.Position.X - trackPos) / trackWidth, 0, 1)
        local val = math.floor(min + relX * (max - min))
        currentVal = val
        valLbl.Text = tostring(val)
        fill.Size = UDim2.new(relX, 0, 1, 0)
        thumb.Position = UDim2.new(relX, 0, 0.5, 0)
        onChange(val)
    end

    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
end

-- ===================== DROPDOWN FUNCTION =====================
local function createDropdown(name, icon, options, default, onChange)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -20, 0, 42)
    row.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    row.BorderSizePixel = 0
    row.Parent = ScrollFrame

    local UICornerRow = Instance.new("UICorner")
    UICornerRow.CornerRadius = UDim.new(0, 8)
    UICornerRow.Parent = row

    local UIStrokeRow = Instance.new("UIStroke")
    UIStrokeRow.Color = Color3.fromRGB(35, 35, 50)
    UIStrokeRow.Thickness = 1
    UIStrokeRow.Parent = row

    local iconLbl = Instance.new("TextLabel")
    iconLbl.Size = UDim2.new(0, 28, 1, 0)
    iconLbl.Position = UDim2.new(0, 8, 0, 0)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text = icon
    iconLbl.TextSize = 15
    iconLbl.Font = Enum.Font.GothamBold
    iconLbl.TextColor3 = Color3.fromRGB(220,220,220)
    iconLbl.Parent = row

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(0, 100, 1, 0)
    nameLbl.Position = UDim2.new(0, 40, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = name
    nameLbl.TextSize = 12
    nameLbl.Font = Enum.Font.GothamSemibold
    nameLbl.TextColor3 = Color3.fromRGB(210,210,210)
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = row

    local selBtn = Instance.new("TextButton")
    selBtn.Size = UDim2.new(0, 100, 0, 26)
    selBtn.Position = UDim2.new(1, -108, 0.5, -13)
    selBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
    selBtn.Text = default .. " ▾"
    selBtn.TextSize = 11
    selBtn.Font = Enum.Font.GothamBold
    selBtn.TextColor3 = Color3.fromRGB(255,255,255)
    selBtn.BorderSizePixel = 0
    selBtn.Parent = row

    local UICornerSel = Instance.new("UICorner")
    UICornerSel.CornerRadius = UDim.new(0, 6)
    UICornerSel.Parent = selBtn

    local idx = 1
    for i,v in ipairs(options) do if v == default then idx = i end end

    selBtn.MouseButton1Click:Connect(function()
        idx = idx % #options + 1
        selBtn.Text = options[idx] .. " ▾"
        onChange(options[idx])
    end)
end

-- ===================== BUILD UI =====================

createSection("◈ AIM SETTINGS")

createToggle("Aimbot", "🎯", "AimbotEnabled", function(state)
    -- handled in loop
end)

createToggle("Silent Aim", "👻", "SilentAimEnabled", function(state)
    -- handled in loop
end)

createToggle("Show FOV Circle", "⭕", "FOVVisible", function(state)
    FOVCircle.Visible = state
end)
Settings.FOVVisible = false

createSlider("FOV Size", "⭕", 30, 400, 120, function(val)
    Settings.AimFOV = val
end)

createDropdown("Aim Part", "🎯", {"Head", "HumanoidRootPart", "Torso"}, "Head", function(val)
    Settings.AimPart = val
end)

createSection("◈ PLAYER SETTINGS")

createToggle("Speed Hack", "🏃", "SpeedEnabled", function(state)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = state and Settings.SpeedValue or 16 end
    end
end)

createSlider("Speed Value", "💨", 16, 100, 40, function(val)
    Settings.SpeedValue = val
    if Settings.SpeedEnabled then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = val end
        end
    end
end)

createToggle("Bunny Hop", "🐇", "BunnyHopEnabled", function(state)
    -- handled in loop
end)

createToggle("No Clip", "👻", "NoclipEnabled", function(state)
    -- handled in loop
end)

createToggle("Infinite Ammo", "🔫", "InfiniteAmmoEnabled", function(state)
    -- handled in loop
end)

createSection("◈ VISUALS")

createToggle("ESP / Wallhack", "👁️", "ESPEnabled", function(state)
    if not state then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local h = player.Character:FindFirstChild("ESPHighlight")
                if h then h:Destroy() end
            end
        end
    end
end)

createSection("◈ MISC")

createToggle("Anti AFK", "✅", "AntiAFKEnabled", function(state) end)

-- Status bar
local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(1, 0, 0, 22)
statusBar.BackgroundColor3 = Color3.fromRGB(16, 8, 8)
statusBar.BorderSizePixel = 0
statusBar.ZIndex = 5
statusBar.Parent = MainFrame

-- Fix: overlap list
local UICornerStatus = Instance.new("UICorner")
UICornerStatus.CornerRadius = UDim.new(0, 10)
UICornerStatus.Parent = statusBar

local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(1, 0, 1, 0)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "RIVALS HUB V2  •  RightShift to toggle"
statusLbl.TextColor3 = Color3.fromRGB(100, 60, 60)
statusLbl.TextSize = 10
statusLbl.Font = Enum.Font.Gotham
statusLbl.Parent = statusBar

-- Reposition status bar to bottom
MainFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    statusBar.Position = UDim2.new(0, 0, 1, -22)
end)
statusBar.Position = UDim2.new(0, 0, 1, -22)
ScrollFrame.Size = UDim2.new(1, 0, 1, -70)

-- ===================== OPEN/CLOSE LOGIC =====================
local function toggleGUI(open)
    guiOpen = open
    local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    if open then
        MainFrame.Visible = true
        TweenService:Create(MainFrame, tweenInfo, {Size = UDim2.new(0, 310, 0, 520)}):Play()
    else
        local t = TweenService:Create(MainFrame, tweenInfo, {Size = UDim2.new(0, 310, 0, 0)})
        t:Play()
        t.Completed:Connect(function() MainFrame.Visible = false end)
    end
end

CloseBtn.MouseButton1Click:Connect(function() toggleGUI(false) end)
ToggleBtn.MouseButton1Click:Connect(function() toggleGUI(not guiOpen) end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        toggleGUI(not guiOpen)
    end
end)

-- ===================== HELPER: GET CLOSEST PLAYER =====================
local function getClosestPlayer()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local closest, closestDist = nil, Settings.AimFOV
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local part = player.Character:FindFirstChild(Settings.AimPart) or player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if part and hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = player
                    end
                end
            end
        end
    end
    return closest
end

-- ===================== AIMBOT LOOP =====================
RunService.RenderStepped:Connect(function()
    if Settings.AimbotEnabled then
        local target = getClosestPlayer()
        if target and target.Character then
            local part = target.Character:FindFirstChild(Settings.AimPart) or target.Character:FindFirstChild("HumanoidRootPart")
            if part then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
            end
        end
    end
end)

-- ===================== SILENT AIM =====================
-- Hooks mouse ray to redirect bullets to target
local oldRaycast = workspace.FindPartOnRay
local silentTarget = nil

RunService.RenderStepped:Connect(function()
    if Settings.SilentAimEnabled then
        silentTarget = getClosestPlayer()
    else
        silentTarget = nil
    end
end)

-- Override Mouse Hit for Silent Aim
local mt = getrawmetatable and getrawmetatable(game)
if mt then
    local old_index = mt.__index
    local old_newindex = mt.__newindex
    setreadonly = setreadonly or (function() end)
    pcall(function() setreadonly(mt, false) end)
    mt.__index = newcclosure(function(self, key)
        if Settings.SilentAimEnabled and silentTarget then
            local part = silentTarget.Character and (silentTarget.Character:FindFirstChild(Settings.AimPart) or silentTarget.Character:FindFirstChild("HumanoidRootPart"))
            if self == Mouse and key == "Hit" and part then
                return CFrame.new(part.Position)
            end
            if self == Mouse and key == "Target" and part then
                return part
            end
        end
        return old_index(self, key)
    end)
    pcall(function() setreadonly(mt, true) end)
end

-- ===================== ESP LOOP =====================
local function applyESP(player)
    if player == LocalPlayer then return end
    RunService.Heartbeat:Connect(function()
        if not Settings.ESPEnabled then return end
        if not player.Character then return end
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            if not player.Character:FindFirstChild("ESPHighlight") then
                local hl = Instance.new("Highlight")
                hl.Name = "ESPHighlight"
                hl.FillColor = Color3.fromRGB(255, 30, 30)
                hl.OutlineColor = Color3.fromRGB(255, 200, 0)
                hl.FillTransparency = 0.55
                hl.Parent = player.Character
            end
        else
            local h = player.Character:FindFirstChild("ESPHighlight")
            if h then h:Destroy() end
        end
    end)
end

for _, p in ipairs(Players:GetPlayers()) do applyESP(p) end
Players.PlayerAdded:Connect(applyESP)

-- ===================== NOCLIP LOOP =====================
RunService.Stepped:Connect(function()
    if not Settings.NoclipEnabled then return end
    local char = LocalPlayer.Character
    if char then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

-- ===================== BUNNY HOP =====================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if Settings.BunnyHopEnabled and input.KeyCode == Enum.KeyCode.Space then
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.FloorMaterial ~= Enum.Material.Air then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                hrp.Velocity = Vector3.new(hrp.Velocity.X * 1.1, hrp.Velocity.Y, hrp.Velocity.Z * 1.1)
            end
        end
    end
end)

-- ===================== INFINITE AMMO =====================
RunService.Heartbeat:Connect(function()
    if not Settings.InfiniteAmmoEnabled then return end
    local char = LocalPlayer.Character
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            for _, v in ipairs(tool:GetDescendants()) do
                if (v.Name:lower():find("ammo") or v.Name:lower():find("mag")) and v:IsA("IntValue") then
                    v.Value = 999
                end
            end
        end
    end
end)

-- ===================== SPEED ON RESPAWN =====================
LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    if Settings.SpeedEnabled then
        hum.WalkSpeed = Settings.SpeedValue
    end
end)

-- ===================== ANTI AFK =====================
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    if Settings.AntiAFKEnabled then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

print("✅ RIVALS HUB V2 загружен! RightShift = открыть/закрыть")
