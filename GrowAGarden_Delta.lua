-- ================================================
--   GROW A GARDEN PRO
--   Logo: Dead Rabbit (71693879665391)
--   Compatible: Delta Executor Mobile
--   Author: Grandpa Script 🧓
-- ================================================

local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local UIS           = game:GetService("UserInputService")
local TweenService  = game:GetService("TweenService")
local HttpService   = game:GetService("HttpService")
local Workspace     = game:GetService("Workspace")

local lp        = Players.LocalPlayer
local character = lp.Character or lp.CharacterAdded:Wait()
local humanoid  = character:WaitForChild("Humanoid")
local rootPart  = character:WaitForChild("HumanoidRootPart")

-- ================================================
--  STATE
-- ================================================
local menuOpen    = false
local minimized   = false
local currentTab  = "FARM"
local rgbHue      = 0
local draggingWin = false
local dragWinStart, winStartPos
local btnDragging = false
local btnDragStart, btnPos0
local moved       = false

local toggles = {
    AutoPlant    = false,
    AutoHarvest  = false,
    AutoSell     = false,
    AutoWater    = false,
    InfWater     = false,
    SpeedBoost   = false,
    NoClip       = false,
    AutoPet      = false,
    MutationESP  = false,
    CropESP      = false,
    AntiTheft    = false,
    AutoQuest    = false,
}

local sliders = {
    WalkSpeed  = 16,
    FlySpeed   = 50,
    AutoDelay  = 1.0,
}

local espHighlights = {}

-- ================================================
--  GUI ROOT
-- ================================================
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn   = false
gui.Name           = "GrowAGardenPro"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.Parent         = lp.PlayerGui

-- ================================================
--  LOGO TOGGLE BUTTON (Dead Rabbit style)
-- ================================================
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size             = UDim2.new(0, 62, 0, 62)
toggleBtn.Position         = UDim2.new(0, 18, 0.5, -31)
toggleBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
toggleBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
toggleBtn.Font             = Enum.Font.GothamBold
toggleBtn.TextSize         = 22
toggleBtn.Text             = "🐰"
toggleBtn.BorderSizePixel  = 0
toggleBtn.ZIndex           = 10
toggleBtn.Parent           = gui
local tbc = Instance.new("UICorner"); tbc.CornerRadius = UDim.new(0,16); tbc.Parent = toggleBtn

local tbStroke = Instance.new("UIStroke")
tbStroke.Thickness = 2.5
tbStroke.Color     = Color3.fromRGB(100, 255, 100)
tbStroke.Parent    = toggleBtn

local tagLabel = Instance.new("TextLabel")
tagLabel.Size                = UDim2.new(0, 90, 0, 14)
tagLabel.Position            = UDim2.new(0.5, -45, 1, 4)
tagLabel.BackgroundTransparency = 1
tagLabel.TextColor3          = Color3.fromRGB(120, 220, 120)
tagLabel.Font                = Enum.Font.Gotham
tagLabel.TextSize            = 9
tagLabel.Text                = "GaG PRO"
tagLabel.ZIndex              = 11
tagLabel.Parent              = toggleBtn

-- ================================================
--  MAIN WINDOW
-- ================================================
local win = Instance.new("Frame")
win.Size             = UDim2.new(0, 440, 0, 400)
win.Position         = UDim2.new(0, 95, 0.5, -200)
win.BackgroundColor3 = Color3.fromRGB(8, 14, 8)
win.BorderSizePixel  = 0
win.Visible          = false
win.ClipsDescendants = true
win.ZIndex           = 5
win.Parent           = gui
local wc = Instance.new("UICorner"); wc.CornerRadius = UDim.new(0,16); wc.Parent = win

local winStroke = Instance.new("UIStroke")
winStroke.Thickness = 2
winStroke.Color     = Color3.fromRGB(50, 200, 50)
winStroke.Parent    = win

-- TITLEBAR
local bar = Instance.new("Frame")
bar.Size             = UDim2.new(1, 0, 0, 44)
bar.BackgroundColor3 = Color3.fromRGB(12, 22, 12)
bar.BorderSizePixel  = 0
bar.ZIndex           = 6
bar.Parent           = win
local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0,16); bc.Parent = bar

local barFix = Instance.new("Frame")
barFix.Size             = UDim2.new(1,0,0.5,0)
barFix.Position         = UDim2.new(0,0,0.5,0)
barFix.BackgroundColor3 = Color3.fromRGB(12,22,12)
barFix.BorderSizePixel  = 0
barFix.ZIndex           = 6
barFix.Parent           = bar

local accentLine = Instance.new("Frame")
accentLine.Size             = UDim2.new(1,0,0,2)
accentLine.Position         = UDim2.new(0,0,1,-2)
accentLine.BackgroundColor3 = Color3.fromRGB(50,200,50)
accentLine.BorderSizePixel  = 0
accentLine.ZIndex           = 7
accentLine.Parent           = bar

-- Logo icon in title
local titleIcon = Instance.new("TextLabel")
titleIcon.Text              = "🐰"
titleIcon.Size              = UDim2.new(0,28,1,0)
titleIcon.Position          = UDim2.new(0,8,0,0)
titleIcon.BackgroundTransparency = 1
titleIcon.TextColor3        = Color3.fromRGB(255,255,255)
titleIcon.Font              = Enum.Font.GothamBold
titleIcon.TextSize          = 18
titleIcon.ZIndex            = 7
titleIcon.Parent            = bar

local titleLbl = Instance.new("TextLabel")
titleLbl.Text               = "GROW A GARDEN PRO"
titleLbl.Size               = UDim2.new(0.65,0,1,0)
titleLbl.Position           = UDim2.new(0,40,0,0)
titleLbl.BackgroundTransparency = 1
titleLbl.TextColor3         = Color3.fromRGB(100, 255, 100)
titleLbl.Font               = Enum.Font.GothamBold
titleLbl.TextSize            = 13
titleLbl.TextXAlignment     = Enum.TextXAlignment.Left
titleLbl.ZIndex             = 7
titleLbl.Parent             = bar

-- Header buttons
local function mkHBtn(xOff, bgc, txt)
    local b = Instance.new("TextButton")
    b.Size             = UDim2.new(0,28,0,22)
    b.Position         = UDim2.new(1,xOff,0.5,-11)
    b.BackgroundColor3 = bgc
    b.TextColor3       = Color3.fromRGB(255,255,255)
    b.Font             = Enum.Font.GothamBold
    b.TextSize         = 13
    b.Text             = txt
    b.BorderSizePixel  = 0
    b.ZIndex           = 8
    b.Parent           = bar
    local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,6);c.Parent=b
    return b
end
local minBtn   = mkHBtn(-62, Color3.fromRGB(180,130,0), "_")
local closeBtn = mkHBtn(-30, Color3.fromRGB(200,40,40), "X")

-- ================================================
--  TABS
-- ================================================
local tabRow = Instance.new("Frame")
tabRow.Size             = UDim2.new(1,0,0,36)
tabRow.Position         = UDim2.new(0,0,0,44)
tabRow.BackgroundColor3 = Color3.fromRGB(10,18,10)
tabRow.BorderSizePixel  = 0
tabRow.ZIndex           = 6
tabRow.Parent           = win

local tl = Instance.new("UIListLayout")
tl.FillDirection       = Enum.FillDirection.Horizontal
tl.HorizontalAlignment = Enum.HorizontalAlignment.Left
tl.SortOrder           = Enum.SortOrder.LayoutOrder
tl.Padding             = UDim.new(0,3)
tl.Parent              = tabRow

local tp = Instance.new("UIPadding")
tp.PaddingLeft = UDim.new(0,8)
tp.Parent      = tabRow

local contentArea = Instance.new("Frame")
contentArea.Size             = UDim2.new(1,0,1,-80)
contentArea.Position         = UDim2.new(0,0,0,80)
contentArea.BackgroundTransparency = 1
contentArea.ZIndex           = 6
contentArea.Parent           = win

local TABS     = {"FARM","MOVEMENT","ESP","MISC"}
local tabBtns  = {}
local tabPages = {}

for i, name in ipairs(TABS) do
    local tb = Instance.new("TextButton")
    tb.Size             = UDim2.new(0,94,1,-6)
    tb.BackgroundColor3 = Color3.fromRGB(18,30,18)
    tb.TextColor3       = Color3.fromRGB(80,130,80)
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
    page.Size                   = UDim2.new(1,0,1,0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel        = 0
    page.ScrollBarThickness     = 3
    page.ScrollBarImageColor3   = Color3.fromRGB(50,200,50)
    page.Visible                = (name=="FARM")
    page.ZIndex                 = 6
    page.CanvasSize             = UDim2.new(0,0,0,0)
    page.AutomaticCanvasSize    = Enum.AutomaticSize.Y
    page.Parent                 = contentArea
    tabPages[name] = page

    local l = Instance.new("UIListLayout")
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding   = UDim.new(0,6)
    l.Parent    = page

    local p = Instance.new("UIPadding")
    p.PaddingLeft   = UDim.new(0,12)
    p.PaddingRight  = UDim.new(0,12)
    p.PaddingTop    = UDim.new(0,10)
    p.Parent        = page
end

local function selectTab(name)
    currentTab = name
    for n, btn in pairs(tabBtns) do
        if n == name then
            btn.BackgroundColor3 = Color3.fromRGB(30,120,30)
            btn.TextColor3       = Color3.fromRGB(200,255,200)
        else
            btn.BackgroundColor3 = Color3.fromRGB(18,30,18)
            btn.TextColor3       = Color3.fromRGB(80,130,80)
        end
        tabPages[n].Visible = (n == name)
    end
end
selectTab("FARM")
for _, name in ipairs(TABS) do
    tabBtns[name].MouseButton1Click:Connect(function() selectTab(name) end)
end

-- ================================================
--  HELPER: CREATE TOGGLE ROW
-- ================================================
local function mkToggle(parent, labelTxt, key, order)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1,-4,0,38)
    row.BackgroundColor3 = Color3.fromRGB(14,24,14)
    row.BorderSizePixel  = 0
    row.LayoutOrder      = order
    row.ZIndex           = 7
    row.Parent           = parent
    local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0,8); rc.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Text                = labelTxt
    lbl.Size                = UDim2.new(1,-60,1,0)
    lbl.Position            = UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3          = Color3.fromRGB(180,230,180)
    lbl.Font                = Enum.Font.Gotham
    lbl.TextSize            = 12
    lbl.TextXAlignment      = Enum.TextXAlignment.Left
    lbl.ZIndex              = 8
    lbl.Parent              = row

    local bg = Instance.new("Frame")
    bg.Size             = UDim2.new(0,44,0,22)
    bg.Position         = UDim2.new(1,-52,0.5,-11)
    bg.BackgroundColor3 = Color3.fromRGB(40,40,40)
    bg.BorderSizePixel  = 0
    bg.ZIndex           = 8
    bg.Parent           = row
    local bgc = Instance.new("UICorner"); bgc.CornerRadius = UDim.new(1,0); bgc.Parent = bg

    local knob = Instance.new("Frame")
    knob.Size             = UDim2.new(0,16,0,16)
    knob.Position         = UDim2.new(0,3,0.5,-8)
    knob.BackgroundColor3 = Color3.fromRGB(180,180,180)
    knob.BorderSizePixel  = 0
    knob.ZIndex           = 9
    knob.Parent           = bg
    local kc = Instance.new("UICorner"); kc.CornerRadius = UDim.new(1,0); kc.Parent = knob

    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.Text             = ""
    btn.ZIndex           = 10
    btn.Parent           = bg

    local function refresh()
        local on = toggles[key]
        TweenService:Create(bg,   TweenInfo.new(0.15), {BackgroundColor3 = on and Color3.fromRGB(30,180,30) or Color3.fromRGB(40,40,40)}):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {Position = on and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)}):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {BackgroundColor3 = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(180,180,180)}):Play()
    end

    btn.MouseButton1Click:Connect(function()
        toggles[key] = not toggles[key]
        refresh()
    end)

    return row
end

-- ================================================
--  HELPER: SECTION LABEL
-- ================================================
local function mkSection(parent, txt, order)
    local lbl = Instance.new("TextLabel")
    lbl.Text                = "── " .. txt .. " ──"
    lbl.Size                = UDim2.new(1,-4,0,20)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3          = Color3.fromRGB(50,200,50)
    lbl.Font                = Enum.Font.GothamBold
    lbl.TextSize            = 10
    lbl.LayoutOrder         = order
    lbl.ZIndex              = 7
    lbl.Parent              = parent
end

-- ================================================
--  HELPER: SLIDER
-- ================================================
local function mkSlider(parent, labelTxt, key, minVal, maxVal, order)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1,-4,0,50)
    row.BackgroundColor3 = Color3.fromRGB(14,24,14)
    row.BorderSizePixel  = 0
    row.LayoutOrder      = order
    row.ZIndex           = 7
    row.Parent           = parent
    local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0,8); rc.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Text                = labelTxt .. ": " .. tostring(sliders[key])
    lbl.Size                = UDim2.new(1,-12,0,20)
    lbl.Position            = UDim2.new(0,12,0,4)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3          = Color3.fromRGB(180,230,180)
    lbl.Font                = Enum.Font.Gotham
    lbl.TextSize            = 12
    lbl.TextXAlignment      = Enum.TextXAlignment.Left
    lbl.ZIndex              = 8
    lbl.Parent              = row

    local track = Instance.new("Frame")
    track.Size             = UDim2.new(1,-24,0,6)
    track.Position         = UDim2.new(0,12,0,30)
    track.BackgroundColor3 = Color3.fromRGB(30,50,30)
    track.BorderSizePixel  = 0
    track.ZIndex           = 8
    track.Parent           = row
    local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(1,0); tc.Parent = track

    local fill = Instance.new("Frame")
    fill.Size             = UDim2.new((sliders[key]-minVal)/(maxVal-minVal),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(50,200,50)
    fill.BorderSizePixel  = 0
    fill.ZIndex           = 9
    fill.Parent           = track
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(1,0); fc.Parent = fill

    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.Text             = ""
    btn.ZIndex           = 10
    btn.Parent           = track

    local sliding = false
    btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            sliding = true
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local tPos  = track.AbsolutePosition.X
            local tSize = track.AbsoluteSize.X
            local rel   = math.clamp((i.Position.X - tPos) / tSize, 0, 1)
            local val   = math.floor(minVal + rel * (maxVal - minVal))
            sliders[key] = val
            fill.Size   = UDim2.new(rel, 0, 1, 0)
            lbl.Text    = labelTxt .. ": " .. tostring(val)
        end
    end)
end

-- ================================================
--  BUILD TABS CONTENT
-- ================================================

-- FARM TAB
local fp = tabPages["FARM"]
mkSection(fp, "AUTO FARM", 1)
mkToggle(fp, "Auto Plant Seeds",    "AutoPlant",   2)
mkToggle(fp, "Auto Harvest Crops",  "AutoHarvest", 3)
mkToggle(fp, "Auto Sell Produce",   "AutoSell",    4)
mkToggle(fp, "Auto Water Plants",   "AutoWater",   5)
mkToggle(fp, "Infinite Water Can",  "InfWater",    6)
mkSection(fp, "AUTOMATION", 7)
mkToggle(fp, "Auto Complete Quests","AutoQuest",   8)
mkToggle(fp, "Auto Collect Pets",   "AutoPet",     9)
mkToggle(fp, "Anti Crop Theft",     "AntiTheft",   10)
mkSlider(fp,  "Auto Delay (s)",     "AutoDelay",   0.1, 5.0, 11)

-- MOVEMENT TAB
local mp = tabPages["MOVEMENT"]
mkSection(mp, "PLAYER", 1)
mkToggle(mp, "Speed Boost",  "SpeedBoost", 2)
mkSlider(mp, "Walk Speed",   "WalkSpeed",  16, 100, 3)
mkToggle(mp, "No Clip",      "NoClip",     4)
mkSlider(mp, "Fly Speed",    "FlySpeed",   10, 200, 5)

-- ESP TAB
local ep = tabPages["ESP"]
mkSection(ep, "VISUALS", 1)
mkToggle(ep, "Crop ESP (see all crops)", "CropESP",     2)
mkToggle(ep, "Mutation ESP (highlights)","MutationESP", 3)

-- MISC TAB
local xp = tabPages["MISC"]
mkSection(xp, "EXTRA", 1)

-- Version label at bottom of MISC
local verLbl = Instance.new("TextLabel")
verLbl.Text                = "GaG PRO v1.0 | Dead Rabbit 🐰"
verLbl.Size                = UDim2.new(1,-4,0,24)
verLbl.BackgroundTransparency = 1
verLbl.TextColor3          = Color3.fromRGB(60,120,60)
verLbl.Font                = Enum.Font.Gotham
verLbl.TextSize            = 10
verLbl.LayoutOrder         = 99
verLbl.ZIndex              = 7
verLbl.Parent              = xp

-- ================================================
--  OPEN / CLOSE MENU
-- ================================================
local function openMenu()
    menuOpen = true
    win.Visible = true
    win.Size    = UDim2.new(0,0,0,0)
    TweenService:Create(win, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = UDim2.new(0,440,0,400)}):Play()
end

local function closeMenu()
    menuOpen = false
    TweenService:Create(win, TweenInfo.new(0.2),
        {Size = UDim2.new(0,0,0,0)}):Play()
    task.delay(0.22, function() win.Visible = false end)
end

toggleBtn.MouseButton1Click:Connect(function()
    if not btnDragging then
        if menuOpen then closeMenu() else openMenu() end
    end
end)
closeBtn.MouseButton1Click:Connect(closeMenu)
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(win, TweenInfo.new(0.2), {Size = UDim2.new(0,440,0,44)}):Play()
        minBtn.Text = "+"
    else
        TweenService:Create(win, TweenInfo.new(0.2), {Size = UDim2.new(0,440,0,400)}):Play()
        minBtn.Text = "_"
    end
end)

-- ================================================
--  DRAG WINDOW
-- ================================================
bar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or
       i.UserInputType == Enum.UserInputType.Touch then
        draggingWin  = true
        dragWinStart = i.Position
        winStartPos  = win.Position
    end
end)

toggleBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or
       i.UserInputType == Enum.UserInputType.Touch then
        btnDragging = false; moved = false
        btnDragStart = i.Position
        btnPos0      = toggleBtn.Position
    end
end)

UIS.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseMovement or
       i.UserInputType == Enum.UserInputType.Touch then
        if draggingWin and dragWinStart then
            local d = i.Position - dragWinStart
            win.Position = UDim2.new(
                winStartPos.X.Scale, winStartPos.X.Offset + d.X,
                winStartPos.Y.Scale, winStartPos.Y.Offset + d.Y)
        end
        if btnDragStart then
            local d = i.Position - btnDragStart
            if d.Magnitude > 6 then
                btnDragging = true; moved = true
                toggleBtn.Position = UDim2.new(
                    btnPos0.X.Scale, btnPos0.X.Offset + d.X,
                    btnPos0.Y.Scale, btnPos0.Y.Offset + d.Y)
            end
        end
    end
end)

UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or
       i.UserInputType == Enum.UserInputType.Touch then
        draggingWin = false
        task.delay(0.05, function() btnDragging = false end)
    end
end)

-- ================================================
--  HELPER: FIND GARDEN OBJECTS
-- ================================================
local function findByClass(className, parent)
    parent = parent or Workspace
    local results = {}
    for _, v in pairs(parent:GetDescendants()) do
        if v:IsA(className) then
            table.insert(results, v)
        end
    end
    return results
end

local function findNearbyParts(namePattern, maxDist)
    local root = rootPart
    if not root then return {} end
    local results = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and string.find(v.Name:lower(), namePattern:lower()) then
            local dist = (v.Position - root.Position).Magnitude
            if dist <= (maxDist or 999) then
                table.insert(results, v)
            end
        end
    end
    return results
end

-- ================================================
--  AUTO HARVEST
-- ================================================
RunService.Heartbeat:Connect(function(dt)

    -- RGB EFFECT
    rgbHue = (rgbHue + dt * 0.35) % 1
    local rgb = Color3.fromHSV(rgbHue, 0.8, 1)
    tbStroke.Color              = rgb
    accentLine.BackgroundColor3 = rgb
    winStroke.Color             = rgb

    -- SPEED BOOST
    if toggles.SpeedBoost then
        humanoid.WalkSpeed = sliders.WalkSpeed
    else
        humanoid.WalkSpeed = 16
    end

    -- NO CLIP
    if toggles.NoClip then
        for _, p in pairs(character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end

    -- AUTO HARVEST (finds grown crop parts)
    if toggles.AutoHarvest then
        local crops = findNearbyParts("crop", 60)
        for _, crop in pairs(crops) do
            pcall(function()
                local hum = crop:FindFirstChild("HarvestPrompt") or
                            crop:FindFirstChildWhichIsA("ProximityPrompt")
                if hum then
                    fireproximityprompt(hum)
                end
            end)
        end
    end

    -- AUTO SELL
    if toggles.AutoSell then
        local sells = findNearbyParts("sell", 80)
        for _, s in pairs(sells) do
            pcall(function()
                local pp = s:FindFirstChildWhichIsA("ProximityPrompt")
                if pp then fireproximityprompt(pp) end
            end)
        end
    end

    -- CROP ESP
    if toggles.CropESP then
        local crops = findNearbyParts("crop", 200)
        for _, crop in pairs(crops) do
            if not espHighlights[crop] then
                local h = Instance.new("SelectionBox")
                h.Adornee    = crop
                h.Color3     = Color3.fromRGB(100, 255, 100)
                h.LineThickness = 0.05
                h.SurfaceTransparency = 0.7
                h.SurfaceColor3 = Color3.fromRGB(100, 255, 100)
                h.Parent     = gui
                espHighlights[crop] = h
            end
        end
    else
        for k, h in pairs(espHighlights) do
            h:Destroy()
            espHighlights[k] = nil
        end
    end

    -- MUTATION ESP
    if toggles.MutationESP then
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and (
                string.find(v.Name:lower(), "mutation") or
                string.find(v.Name:lower(), "mutant") or
                string.find(v.Name:lower(), "moonlit") or
                string.find(v.Name:lower(), "frozen") or
                string.find(v.Name:lower(), "rainbow")
            ) then
                if not espHighlights["m_"..v:GetFullName()] then
                    local h = Instance.new("SelectionBox")
                    h.Adornee    = v
                    h.Color3     = Color3.fromRGB(255, 50, 255)
                    h.LineThickness = 0.08
                    h.SurfaceTransparency = 0.5
                    h.SurfaceColor3 = Color3.fromRGB(255,50,255)
                    h.Parent     = gui
                    espHighlights["m_"..v:GetFullName()] = h
                end
            end
        end
    end

end)

-- ================================================
--  AUTO WATER LOOP (slower interval)
-- ================================================
task.spawn(function()
    while true do
        task.wait(sliders.AutoDelay)
        if toggles.AutoWater then
            local plants = findNearbyParts("plant", 50)
            for _, plant in pairs(plants) do
                pcall(function()
                    local pp = plant:FindFirstChildWhichIsA("ProximityPrompt")
                    if pp then fireproximityprompt(pp) end
                end)
            end
        end
    end
end)

-- ================================================
--  AUTO PLANT LOOP
-- ================================================
task.spawn(function()
    while true do
        task.wait(sliders.AutoDelay + 0.5)
        if toggles.AutoPlant then
            local plots = findNearbyParts("plot", 60)
            for _, plot in pairs(plots) do
                pcall(function()
                    local pp = plot:FindFirstChildWhichIsA("ProximityPrompt")
                    if pp then fireproximityprompt(pp) end
                end)
            end
        end
    end
end)

-- ================================================
--  AUTO QUEST LOOP
-- ================================================
task.spawn(function()
    while true do
        task.wait(3)
        if toggles.AutoQuest then
            local quests = findNearbyParts("quest", 80)
            for _, q in pairs(quests) do
                pcall(function()
                    local pp = q:FindFirstChildWhichIsA("ProximityPrompt")
                    if pp then fireproximityprompt(pp) end
                end)
            end
        end
    end
end)

-- ================================================
--  RESPAWN
-- ================================================
lp.CharacterAdded:Connect(function(char)
    character = char
    humanoid  = char:WaitForChild("Humanoid")
    rootPart  = char:WaitForChild("HumanoidRootPart")
    toggles.NoClip     = false
    toggles.SpeedBoost = false
end)

print("[GaG PRO] Dead Rabbit 🐰 Loaded! by Grandpa Script")
