--[[
    ███╗   ███╗ █████╗ ██████╗ ██╗  ██╗    ███████╗ ██████╗██████╗ ██╗██████╗ ████████╗███████╗
    ████╗ ████║██╔══██╗██╔══██╗██║ ██╔╝    ██╔════╝██╔════╝██╔══██╗██║██╔══██╗╚══██╔══╝██╔════╝
    ██╔████╔██║███████║██████╔╝█████╔╝     ███████╗██║     ██████╔╝██║██████╔╝   ██║   ███████╗
    ██║╚██╔╝██║██╔══██║██╔══██╗██╔═██╗     ╚════██║██║     ██╔══██╗██║██╔═══╝    ██║   ╚════██║
    ██║ ╚═╝ ██║██║  ██║██║  ██║██║  ██╗    ███████║╚██████╗██║  ██║██║██║        ██║   ███████║
    ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝   ╚══════╝
    
    Fruit Forager Script | By MARK SCRIPTS
    Powered by Primejtsu
    
    Features:
    - Auto Farm (Collect Fruits)
    - Auto Sell
    - Speed Hack
    - Infinite Jump
    - No Clip
    - Server Hop
    - Fruit ESP
    - Auto Quest
    - Teleports
    - Rarity Filter
]]

-- ════════════════════════════════════════
--           SERVICES & VARIABLES
-- ════════════════════════════════════════
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- ════════════════════════════════════════
--           SCRIPT SETTINGS
-- ════════════════════════════════════════
local Settings = {
    AutoFarm = false,
    AutoSell = false,
    FruitESP = false,
    SpeedHack = false,
    InfiniteJump = false,
    NoClip = false,
    ServerHop = false,
    AutoQuest = false,
    WalkSpeed = 60,
    CollectRadius = 50,
    SelectedRarities = {
        Common = true,
        Uncommon = true,
        Rare = true,
        Epic = true,
        Legendary = true,
        Mythic = true,
        Unique = true,
    }
}

-- ════════════════════════════════════════
--           COLOR PALETTE
-- ════════════════════════════════════════
local Colors = {
    Background   = Color3.fromRGB(12, 12, 20),
    Panel        = Color3.fromRGB(20, 20, 35),
    Accent       = Color3.fromRGB(255, 80, 80),
    AccentGlow   = Color3.fromRGB(255, 120, 120),
    AccentDark   = Color3.fromRGB(180, 40, 40),
    Green        = Color3.fromRGB(50, 220, 100),
    GreenDark    = Color3.fromRGB(30, 150, 70),
    Text         = Color3.fromRGB(240, 240, 255),
    TextDim      = Color3.fromRGB(150, 150, 180),
    Border       = Color3.fromRGB(60, 60, 90),
    ButtonBg     = Color3.fromRGB(30, 30, 50),
    ButtonHover  = Color3.fromRGB(45, 45, 70),
    Off          = Color3.fromRGB(80, 30, 30),
    On           = Color3.fromRGB(30, 80, 50),
    TabActive    = Color3.fromRGB(255, 80, 80),
    TabInactive  = Color3.fromRGB(30, 30, 50),
    Shadow       = Color3.fromRGB(5, 5, 10),
    Gold         = Color3.fromRGB(255, 200, 50),
    Purple       = Color3.fromRGB(180, 80, 255),
}

-- ════════════════════════════════════════
--         SPLASH SCREEN (FULLSCREEN)
-- ════════════════════════════════════════
local SplashGui = Instance.new("ScreenGui")
SplashGui.Name = "MarkScriptsSplash"
SplashGui.ResetOnSpawn = false
SplashGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SplashGui.DisplayOrder = 999
SplashGui.Parent = PlayerGui

-- Full screen dark bg
local SplashBG = Instance.new("Frame")
SplashBG.Size = UDim2.new(1, 0, 1, 0)
SplashBG.Position = UDim2.new(0, 0, 0, 0)
SplashBG.BackgroundColor3 = Color3.fromRGB(5, 5, 12)
SplashBG.BorderSizePixel = 0
SplashBG.ZIndex = 10
SplashBG.Parent = SplashGui

-- Gradient overlay
local SplashGradient = Instance.new("UIGradient")
SplashGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 5, 30)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(5, 5, 12)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 5, 5)),
})
SplashGradient.Rotation = 135
SplashGradient.Parent = SplashBG

-- Center container
local SplashCenter = Instance.new("Frame")
SplashCenter.Size = UDim2.new(0, 600, 0, 320)
SplashCenter.Position = UDim2.new(0.5, -300, 0.5, -160)
SplashCenter.BackgroundTransparency = 1
SplashCenter.ZIndex = 11
SplashCenter.Parent = SplashBG

-- Decorative top line
local TopLine = Instance.new("Frame")
TopLine.Size = UDim2.new(0, 0, 0, 2)
TopLine.Position = UDim2.new(0.5, 0, 0, 0)
TopLine.BackgroundColor3 = Colors.Accent
TopLine.BorderSizePixel = 0
TopLine.ZIndex = 12
TopLine.Parent = SplashCenter

-- MARK SCRIPTS main title
local SplashTitle = Instance.new("TextLabel")
SplashTitle.Size = UDim2.new(1, 0, 0, 120)
SplashTitle.Position = UDim2.new(0, 0, 0, 20)
SplashTitle.BackgroundTransparency = 1
SplashTitle.Text = "MARK SCRIPTS"
SplashTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SplashTitle.TextSize = 72
SplashTitle.Font = Enum.Font.GothamBold
SplashTitle.ZIndex = 12
SplashTitle.TextTransparency = 1
SplashTitle.Parent = SplashCenter

-- Subtitle
local SplashSub = Instance.new("TextLabel")
SplashSub.Size = UDim2.new(1, 0, 0, 40)
SplashSub.Position = UDim2.new(0, 0, 0, 140)
SplashSub.BackgroundTransparency = 1
SplashSub.Text = "🍎 Fruit Forager Script"
SplashSub.TextColor3 = Colors.Accent
SplashSub.TextSize = 28
SplashSub.Font = Enum.Font.GothamSemibold
SplashSub.ZIndex = 12
SplashSub.TextTransparency = 1
SplashSub.Parent = SplashCenter

-- Divider line
local SplashDivider = Instance.new("Frame")
SplashDivider.Size = UDim2.new(0, 0, 0, 1)
SplashDivider.Position = UDim2.new(0.5, 0, 0, 200)
SplashDivider.BackgroundColor3 = Colors.Border
SplashDivider.BorderSizePixel = 0
SplashDivider.ZIndex = 12
SplashDivider.Parent = SplashCenter

-- Powered by text (bottom)
local SplashPowered = Instance.new("TextLabel")
SplashPowered.Size = UDim2.new(1, 0, 0, 30)
SplashPowered.Position = UDim2.new(0, 0, 0, 220)
SplashPowered.BackgroundTransparency = 1
SplashPowered.Text = "Powered by Primejtsu"
SplashPowered.TextColor3 = Colors.Gold
SplashPowered.TextSize = 20
SplashPowered.Font = Enum.Font.GothamSemibold
SplashPowered.ZIndex = 12
SplashPowered.TextTransparency = 1
SplashPowered.Parent = SplashCenter

-- Loading bar BG
local LoadBarBG = Instance.new("Frame")
LoadBarBG.Size = UDim2.new(0, 400, 0, 6)
LoadBarBG.Position = UDim2.new(0.5, -200, 0, 270)
LoadBarBG.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
LoadBarBG.BorderSizePixel = 0
LoadBarBG.ZIndex = 12
LoadBarBG.Parent = SplashCenter
Instance.new("UICorner", LoadBarBG).CornerRadius = UDim.new(1, 0)

local LoadBar = Instance.new("Frame")
LoadBar.Size = UDim2.new(0, 0, 1, 0)
LoadBar.BackgroundColor3 = Colors.Accent
LoadBar.BorderSizePixel = 0
LoadBar.ZIndex = 13
LoadBar.Parent = LoadBarBG
Instance.new("UICorner", LoadBar).CornerRadius = UDim.new(1, 0)

-- Loading text
local LoadText = Instance.new("TextLabel")
LoadText.Size = UDim2.new(1, 0, 0, 20)
LoadText.Position = UDim2.new(0, 0, 0, 290)
LoadText.BackgroundTransparency = 1
LoadText.Text = "Загрузка..."
LoadText.TextColor3 = Colors.TextDim
LoadText.TextSize = 14
LoadText.Font = Enum.Font.Gotham
LoadText.ZIndex = 12
LoadText.TextTransparency = 1
LoadText.Parent = SplashCenter

-- ════════ SPLASH ANIMATION ════════
local function animateSplash()
    task.wait(0.3)
    
    -- Animate top line expand
    TweenService:Create(TopLine, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()
    task.wait(0.3)
    
    -- Fade in title
    TweenService:Create(SplashTitle, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {
        TextTransparency = 0
    }):Play()
    task.wait(0.3)
    
    -- Fade in subtitle
    TweenService:Create(SplashSub, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
        TextTransparency = 0
    }):Play()
    task.wait(0.2)
    
    -- Expand divider
    TweenService:Create(SplashDivider, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 200)
    }):Play()
    task.wait(0.2)
    
    -- Fade in powered by
    TweenService:Create(SplashPowered, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
        TextTransparency = 0
    }):Play()
    TweenService:Create(LoadText, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
        TextTransparency = 0
    }):Play()
    task.wait(0.3)
    
    -- Loading bar animation
    local loadMessages = {
        "Инициализация скрипта...",
        "Загрузка функций...",
        "Подключение к игре...",
        "Поиск фруктов...",
        "Готово!"
    }
    for i, msg in ipairs(loadMessages) do
        LoadText.Text = msg
        TweenService:Create(LoadBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = UDim2.new(i / #loadMessages, 0, 1, 0)
        }):Play()
        task.wait(0.35)
    end
    
    task.wait(0.5)
    
    -- Fade out splash
    TweenService:Create(SplashBG, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 1
    }):Play()
    for _, obj in pairs(SplashCenter:GetDescendants()) do
        if obj:IsA("TextLabel") then
            TweenService:Create(obj, TweenInfo.new(0.6), {TextTransparency = 1}):Play()
        elseif obj:IsA("Frame") then
            TweenService:Create(obj, TweenInfo.new(0.6), {BackgroundTransparency = 1}):Play()
        end
    end
    
    task.wait(0.9)
    SplashGui:Destroy()
end

task.spawn(animateSplash)

-- ════════════════════════════════════════
--           MAIN GUI SETUP
-- ════════════════════════════════════════
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "MarkScriptsFruitForager"
MainGui.ResetOnSpawn = false
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MainGui.DisplayOrder = 100
MainGui.Parent = PlayerGui

-- ════════ MAIN WINDOW ════════
local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.Size = UDim2.new(0, 520, 0, 400)
MainWindow.Position = UDim2.new(0.5, -260, 0.5, -200)
MainWindow.BackgroundColor3 = Colors.Background
MainWindow.BorderSizePixel = 0
MainWindow.ZIndex = 1
MainWindow.Parent = MainGui

-- Corner radius
local WinCorner = Instance.new("UICorner")
WinCorner.CornerRadius = UDim.new(0, 12)
WinCorner.Parent = MainWindow

-- Shadow effect
local Shadow = Instance.new("ImageLabel")
Shadow.Size = UDim2.new(1, 30, 1, 30)
Shadow.Position = UDim2.new(0, -15, 0, -15)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://5554236805"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
Shadow.ZIndex = 0
Shadow.Parent = MainWindow

-- Border glow
local BorderFrame = Instance.new("Frame")
BorderFrame.Size = UDim2.new(1, 2, 1, 2)
BorderFrame.Position = UDim2.new(0, -1, 0, -1)
BorderFrame.BackgroundColor3 = Colors.Accent
BorderFrame.BackgroundTransparency = 0.7
BorderFrame.BorderSizePixel = 0
BorderFrame.ZIndex = -1
BorderFrame.Parent = MainWindow
Instance.new("UICorner", BorderFrame).CornerRadius = UDim.new(0, 13)

-- ════════ TOP BAR ════════
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Colors.Panel
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 2
TopBar.Parent = MainWindow

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 12)
TopBarCorner.Parent = TopBar

-- Fix bottom corners of top bar
local TopBarFix = Instance.new("Frame")
TopBarFix.Size = UDim2.new(1, 0, 0.5, 0)
TopBarFix.Position = UDim2.new(0, 0, 0.5, 0)
TopBarFix.BackgroundColor3 = Colors.Panel
TopBarFix.BorderSizePixel = 0
TopBarFix.ZIndex = 2
TopBarFix.Parent = TopBar

-- Logo icon
local LogoLabel = Instance.new("TextLabel")
LogoLabel.Size = UDim2.new(0, 35, 0, 35)
LogoLabel.Position = UDim2.new(0, 8, 0.5, -17)
LogoLabel.BackgroundColor3 = Colors.Accent
LogoLabel.Text = "🍎"
LogoLabel.TextSize = 18
LogoLabel.Font = Enum.Font.GothamBold
LogoLabel.ZIndex = 3
LogoLabel.Parent = TopBar
Instance.new("UICorner", LogoLabel).CornerRadius = UDim.new(0, 8)

-- Title text
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 200, 1, 0)
TitleLabel.Position = UDim2.new(0, 50, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "MARK SCRIPTS"
TitleLabel.TextColor3 = Colors.Text
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 3
TitleLabel.Parent = TopBar

-- Subtitle
local SubLabel = Instance.new("TextLabel")
SubLabel.Size = UDim2.new(0, 200, 0, 16)
SubLabel.Position = UDim2.new(0, 50, 0.5, 2)
SubLabel.BackgroundTransparency = 1
SubLabel.Text = "Fruit Forager"
SubLabel.TextColor3 = Colors.Accent
SubLabel.TextSize = 11
SubLabel.Font = Enum.Font.Gotham
SubLabel.TextXAlignment = Enum.TextXAlignment.Left
SubLabel.ZIndex = 3
SubLabel.Parent = TopBar

-- Minimize button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -65, 0.5, -14)
MinBtn.BackgroundColor3 = Colors.ButtonBg
MinBtn.Text = "−"
MinBtn.TextColor3 = Colors.Text
MinBtn.TextSize = 20
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
MinBtn.ZIndex = 4
MinBtn.Parent = TopBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -33, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 4
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- ════════ TAB BAR ════════
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 38)
TabBar.Position = UDim2.new(0, 0, 0, 45)
TabBar.BackgroundColor3 = Colors.Panel
TabBar.BorderSizePixel = 0
TabBar.ZIndex = 2
TabBar.Parent = MainWindow

local TabBarLayout = Instance.new("UIListLayout")
TabBarLayout.FillDirection = Enum.FillDirection.Horizontal
TabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabBarLayout.Padding = UDim.new(0, 2)
TabBarLayout.Parent = TabBar

local TabBarPadding = Instance.new("UIPadding")
TabBarPadding.PaddingLeft = UDim.new(0, 6)
TabBarPadding.PaddingTop = UDim.new(0, 5)
TabBarPadding.PaddingBottom = UDim.new(0, 5)
TabBarPadding.Parent = TabBar

-- Separator line
local TabSep = Instance.new("Frame")
TabSep.Size = UDim2.new(1, 0, 0, 1)
TabSep.Position = UDim2.new(0, 0, 1, -1)
TabSep.BackgroundColor3 = Colors.Border
TabSep.BorderSizePixel = 0
TabSep.ZIndex = 3
TabSep.Parent = TabBar

-- ════════ CONTENT AREA ════════
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -84)
ContentFrame.Position = UDim2.new(0, 0, 0, 84)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ZIndex = 2
ContentFrame.Parent = MainWindow

-- ════════════════════════════════════════
--           HELPER FUNCTIONS
-- ════════════════════════════════════════

-- Create a toggle button
local function createToggle(parent, yPos, labelText, setting, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -20, 0, 36)
    row.Position = UDim2.new(0, 10, 0, yPos)
    row.BackgroundColor3 = Colors.ButtonBg
    row.BorderSizePixel = 0
    row.ZIndex = 3
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -70, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Colors.Text
    lbl.TextSize = 13
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 4
    lbl.Parent = row

    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 46, 0, 24)
    toggleBg.Position = UDim2.new(1, -56, 0.5, -12)
    toggleBg.BackgroundColor3 = Settings[setting] and Colors.Green or Colors.Off
    toggleBg.BorderSizePixel = 0
    toggleBg.ZIndex = 4
    toggleBg.Parent = row
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)

    local toggleKnob = Instance.new("Frame")
    toggleKnob.Size = UDim2.new(0, 18, 0, 18)
    toggleKnob.Position = Settings[setting] and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    toggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleKnob.BorderSizePixel = 0
    toggleKnob.ZIndex = 5
    toggleKnob.Parent = toggleBg
    Instance.new("UICorner", toggleKnob).CornerRadius = UDim.new(1, 0)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 6
    btn.Parent = row

    btn.MouseButton1Click:Connect(function()
        Settings[setting] = not Settings[setting]
        local isOn = Settings[setting]
        TweenService:Create(toggleBg, TweenInfo.new(0.2), {
            BackgroundColor3 = isOn and Colors.Green or Colors.Off
        }):Play()
        TweenService:Create(toggleKnob, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Position = isOn and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        }):Play()
        if callback then callback(isOn) end
    end)

    -- Hover effect
    btn.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = Colors.ButtonHover}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.15), {BackgroundColor3 = Colors.ButtonBg}):Play()
    end)

    return row
end

-- Create action button
local function createButton(parent, yPos, labelText, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 34)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = color or Colors.Accent
    btn.Text = labelText
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamSemibold
    btn.BorderSizePixel = 0
    btn.ZIndex = 3
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {
            Size = UDim2.new(1, -24, 0, 32)
        }):Play()
        task.wait(0.1)
        TweenService:Create(btn, TweenInfo.new(0.1), {
            Size = UDim2.new(1, -20, 0, 34)
        }):Play()
        if callback then callback() end
    end)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.new(
                (color or Colors.Accent).R * 1.2,
                (color or Colors.Accent).G * 1.2,
                (color or Colors.Accent).B * 1.2
            )
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = color or Colors.Accent
        }):Play()
    end)

    return btn
end

-- Section label
local function createSection(parent, yPos, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 22)
    lbl.Position = UDim2.new(0, 10, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.Text = "  " .. text
    lbl.TextColor3 = Colors.Accent
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 3
    lbl.Parent = parent

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, -20, 0, 1)
    line.Position = UDim2.new(0, 10, 0, yPos + 20)
    line.BackgroundColor3 = Colors.Border
    line.BorderSizePixel = 0
    line.ZIndex = 3
    line.Parent = parent

    return lbl
end

-- ════════════════════════════════════════
--           TAB SYSTEM
-- ════════════════════════════════════════
local Tabs = {}
local TabPages = {}
local currentTab = nil

local tabDefs = {
    {name = "🌾 Фарм",    key = "farm"},
    {name = "⚡ Плеер",   key = "player"},
    {name = "📍 Телепорт",key = "teleport"},
    {name = "⚙️ Настройки",key = "settings"},
}

for i, def in ipairs(tabDefs) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0, 115, 1, 0)
    tabBtn.BackgroundColor3 = Colors.TabInactive
    tabBtn.Text = def.name
    tabBtn.TextColor3 = Colors.TextDim
    tabBtn.TextSize = 11
    tabBtn.Font = Enum.Font.GothamSemibold
    tabBtn.BorderSizePixel = 0
    tabBtn.ZIndex = 3
    tabBtn.LayoutOrder = i
    tabBtn.Parent = TabBar
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)

    -- Page
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Colors.Accent
    page.Visible = false
    page.ZIndex = 2
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Parent = ContentFrame

    Tabs[def.key] = tabBtn
    TabPages[def.key] = page

    tabBtn.MouseButton1Click:Connect(function()
        for k, t in pairs(Tabs) do
            TweenService:Create(t, TweenInfo.new(0.15), {
                BackgroundColor3 = Colors.TabInactive,
                TextColor3 = Colors.TextDim
            }):Play()
            TabPages[k].Visible = false
        end
        TweenService:Create(tabBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = Colors.TabActive,
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
        page.Visible = true
        currentTab = def.key
    end)
end

-- Default tab
Tabs["farm"].BackgroundColor3 = Colors.TabActive
Tabs["farm"].TextColor3 = Color3.fromRGB(255, 255, 255)
TabPages["farm"].Visible = true
currentTab = "farm"

-- ════════════════════════════════════════
--         FARM TAB CONTENT
-- ════════════════════════════════════════
local farmPage = TabPages["farm"]
farmPage.CanvasSize = UDim2.new(0, 0, 0, 400)

createSection(farmPage, 8, "АВТО СБОР")
createToggle(farmPage, 32, "🍎 Авто Сбор Фруктов", "AutoFarm", function(state)
    -- handled in loop
end)
createToggle(farmPage, 72, "💰 Авто Продажа", "AutoSell", function(state)
    -- handled in loop
end)
createToggle(farmPage, 112, "🔍 ESP Фруктов", "FruitESP", function(state)
    if not state then
        -- Remove all ESP highlights
        for _, v in pairs(Workspace:GetDescendants()) do
            if v.Name == "_MarkESP" then v:Destroy() end
        end
    end
end)
createToggle(farmPage, 152, "🔄 Авто Прыжок на Сервер", "ServerHop", nil)
createToggle(farmPage, 192, "📋 Авто Квест", "AutoQuest", nil)

createSection(farmPage, 238, "ФИЛЬТР РЕДКОСТИ")
-- Rarity checkboxes
local rarities = {
    {name = "Common",    label = "⬜ Common",    color = Color3.fromRGB(180,180,180)},
    {name = "Uncommon",  label = "🟩 Uncommon",  color = Color3.fromRGB(100,220,100)},
    {name = "Rare",      label = "🟧 Rare",      color = Color3.fromRGB(255,165,80)},
    {name = "Epic",      label = "🟪 Epic",      color = Color3.fromRGB(180,80,255)},
    {name = "Legendary", label = "🟨 Legendary", color = Color3.fromRGB(255,200,50)},
    {name = "Mythic",    label = "🔵 Mythic",    color = Color3.fromRGB(80,200,255)},
}
for i, rar in ipairs(rarities) do
    local yOff = 262 + (i-1) * 38
    farmPage.CanvasSize = UDim2.new(0, 0, 0, yOff + 50)

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -20, 0, 32)
    row.Position = UDim2.new(0, 10, 0, yOff)
    row.BackgroundColor3 = Colors.ButtonBg
    row.BorderSizePixel = 0
    row.ZIndex = 3
    row.Parent = farmPage
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local lbl2 = Instance.new("TextLabel")
    lbl2.Size = UDim2.new(1, -50, 1, 0)
    lbl2.Position = UDim2.new(0, 12, 0, 0)
    lbl2.BackgroundTransparency = 1
    lbl2.Text = rar.label
    lbl2.TextColor3 = rar.color
    lbl2.TextSize = 12
    lbl2.Font = Enum.Font.Gotham
    lbl2.TextXAlignment = Enum.TextXAlignment.Left
    lbl2.ZIndex = 4
    lbl2.Parent = row

    local checkBg = Instance.new("Frame")
    checkBg.Size = UDim2.new(0, 22, 0, 22)
    checkBg.Position = UDim2.new(1, -32, 0.5, -11)
    checkBg.BackgroundColor3 = Settings.SelectedRarities[rar.name] and Colors.Green or Colors.Off
    checkBg.BorderSizePixel = 0
    checkBg.ZIndex = 4
    checkBg.Parent = row
    Instance.new("UICorner", checkBg).CornerRadius = UDim.new(0, 4)

    local checkMark = Instance.new("TextLabel")
    checkMark.Size = UDim2.new(1, 0, 1, 0)
    checkMark.BackgroundTransparency = 1
    checkMark.Text = "✓"
    checkMark.TextColor3 = Color3.fromRGB(255,255,255)
    checkMark.TextSize = 14
    checkMark.Font = Enum.Font.GothamBold
    checkMark.ZIndex = 5
    checkMark.Parent = checkBg

    local checkBtn = Instance.new("TextButton")
    checkBtn.Size = UDim2.new(1, 0, 1, 0)
    checkBtn.BackgroundTransparency = 1
    checkBtn.Text = ""
    checkBtn.ZIndex = 6
    checkBtn.Parent = row

    checkBtn.MouseButton1Click:Connect(function()
        Settings.SelectedRarities[rar.name] = not Settings.SelectedRarities[rar.name]
        TweenService:Create(checkBg, TweenInfo.new(0.2), {
            BackgroundColor3 = Settings.SelectedRarities[rar.name] and Colors.Green or Colors.Off
        }):Play()
    end)
end

-- ════════════════════════════════════════
--         PLAYER TAB CONTENT
-- ════════════════════════════════════════
local playerPage = TabPages["player"]
playerPage.CanvasSize = UDim2.new(0, 0, 0, 380)

createSection(playerPage, 8, "ДВИЖЕНИЕ")
createToggle(playerPage, 32, "⚡ Ускорение", "SpeedHack", function(state)
    if state then
        if Character and Character:FindFirstChildOfClass("Humanoid") then
            Character:FindFirstChildOfClass("Humanoid").WalkSpeed = Settings.WalkSpeed
        end
    else
        if Character and Character:FindFirstChildOfClass("Humanoid") then
            Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
        end
    end
end)
createToggle(playerPage, 72, "🦘 Бесконечный Прыжок", "InfiniteJump", nil)
createToggle(playerPage, 112, "👻 Без Коллизий (NoClip)", "NoClip", nil)

-- Speed slider display
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, -20, 0, 24)
speedLabel.Position = UDim2.new(0, 10, 0, 155)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Скорость: " .. Settings.WalkSpeed
speedLabel.TextColor3 = Colors.TextDim
speedLabel.TextSize = 12
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.ZIndex = 3
speedLabel.Parent = playerPage

-- Speed slider
local sliderBG = Instance.new("Frame")
sliderBG.Size = UDim2.new(1, -20, 0, 8)
sliderBG.Position = UDim2.new(0, 10, 0, 182)
sliderBG.BackgroundColor3 = Colors.ButtonBg
sliderBG.BorderSizePixel = 0
sliderBG.ZIndex = 3
sliderBG.Parent = playerPage
Instance.new("UICorner", sliderBG).CornerRadius = UDim.new(1, 0)

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new((Settings.WalkSpeed - 16) / (200 - 16), 0, 1, 0)
sliderFill.BackgroundColor3 = Colors.Accent
sliderFill.BorderSizePixel = 0
sliderFill.ZIndex = 4
sliderFill.Parent = sliderBG
Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

local sliderKnob = Instance.new("Frame")
sliderKnob.Size = UDim2.new(0, 16, 0, 16)
sliderKnob.Position = UDim2.new(sliderFill.Size.X.Scale, -8, 0.5, -8)
sliderKnob.BackgroundColor3 = Color3.fromRGB(255,255,255)
sliderKnob.BorderSizePixel = 0
sliderKnob.ZIndex = 5
sliderKnob.Parent = sliderBG
Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)

local sliderBtn = Instance.new("TextButton")
sliderBtn.Size = UDim2.new(1, 0, 0, 20)
sliderBtn.Position = UDim2.new(0, 0, 0.5, -10)
sliderBtn.BackgroundTransparency = 1
sliderBtn.Text = ""
sliderBtn.ZIndex = 6
sliderBtn.Parent = sliderBG

local dragging = false
sliderBtn.MouseButton1Down:Connect(function()
    dragging = true
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
RunService.RenderStepped:Connect(function()
    if dragging then
        local mousePos = UserInputService:GetMouseLocation()
        local absPos = sliderBG.AbsolutePosition
        local absSize = sliderBG.AbsoluteSize
        local pct = math.clamp((mousePos.X - absPos.X) / absSize.X, 0, 1)
        local speed = math.floor(16 + pct * (200 - 16))
        Settings.WalkSpeed = speed
        speedLabel.Text = "Скорость: " .. speed
        sliderFill.Size = UDim2.new(pct, 0, 1, 0)
        sliderKnob.Position = UDim2.new(pct, -8, 0.5, -8)
        if Settings.SpeedHack then
            local hum = Character and Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = speed end
        end
    end
end)

createSection(playerPage, 206, "ДЕЙСТВИЯ")
createButton(playerPage, 230, "🏠 Вернуться на Спавн", Colors.ButtonBg, function()
    if HumanoidRootPart then
        local spawn = Workspace:FindFirstChild("SpawnLocation")
        if spawn then
            HumanoidRootPart.CFrame = spawn.CFrame + Vector3.new(0, 5, 0)
        end
    end
end)
createButton(playerPage, 268, "❤️ Восстановить Здоровье", Color3.fromRGB(180, 40, 40), function()
    local hum = Character and Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health = hum.MaxHealth end
end)
createButton(playerPage, 306, "🔄 Обновить Персонажа", Colors.ButtonBg, function()
    LocalPlayer:LoadCharacter()
end)

-- ════════════════════════════════════════
--         TELEPORT TAB CONTENT
-- ════════════════════════════════════════
local teleportPage = TabPages["teleport"]
teleportPage.CanvasSize = UDim2.new(0, 0, 0, 450)

createSection(teleportPage, 8, "ЗОНЫ")

local tpLocations = {
    {name = "🏪 Торговая точка",    pos = Vector3.new(0, 5, 0)},
    {name = "🌲 Лес",               pos = Vector3.new(100, 5, 100)},
    {name = "🏔️ Горы",             pos = Vector3.new(-200, 30, 150)},
    {name = "🏝️ Острова",          pos = Vector3.new(300, 5, -100)},
    {name = "🌊 Берег",             pos = Vector3.new(-150, 5, -200)},
    {name = "🌋 Вулкан",            pos = Vector3.new(250, 50, 250)},
    {name = "❄️ Снежная зона",      pos = Vector3.new(-300, 5, 300)},
    {name = "🔮 Секретная зона",    pos = Vector3.new(0, 5, 400)},
}

for i, loc in ipairs(tpLocations) do
    createButton(teleportPage, 32 + (i-1) * 44, loc.name, Colors.ButtonBg, function()
        -- Try to find actual location or use stored coords
        local found = false
        for _, obj in pairs(Workspace:GetDescendants()) do
            local lname = obj.Name:lower()
            if (lname:find("sell") or lname:find("shop") or lname:find("market")) and i == 1 then
                if obj:IsA("BasePart") then
                    HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 5, 0)
                    found = true
                    break
                end
            end
        end
        if not found and HumanoidRootPart then
            HumanoidRootPart.CFrame = CFrame.new(loc.pos)
        end
    end)
end

-- ════════════════════════════════════════
--         SETTINGS TAB CONTENT
-- ════════════════════════════════════════
local settingsPage = TabPages["settings"]
settingsPage.CanvasSize = UDim2.new(0, 0, 0, 300)

createSection(settingsPage, 8, "ИНТЕРФЕЙС")

-- Theme toggle
local themeMode = "dark"
createButton(settingsPage, 32, "🎨 Сменить Тему (Тёмная)", Colors.ButtonBg, function()
    -- simple theme toggle placeholder
end)

createSection(settingsPage, 80, "ИНФОРМАЦИЯ")

local infoFrame = Instance.new("Frame")
infoFrame.Size = UDim2.new(1, -20, 0, 100)
infoFrame.Position = UDim2.new(0, 10, 0, 104)
infoFrame.BackgroundColor3 = Colors.ButtonBg
infoFrame.BorderSizePixel = 0
infoFrame.ZIndex = 3
infoFrame.Parent = settingsPage
Instance.new("UICorner", infoFrame).CornerRadius = UDim.new(0, 8)

local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1, -16, 1, -16)
infoText.Position = UDim2.new(0, 8, 0, 8)
infoText.BackgroundTransparency = 1
infoText.Text = "🍎 MARK SCRIPTS\nFruit Forager Hub v1.0\n\nПовед by Primejtsu\n\nАвтор: MARK SCRIPTS"
infoText.TextColor3 = Colors.TextDim
infoText.TextSize = 12
infoText.Font = Enum.Font.Gotham
infoText.ZIndex = 4
infoText.TextYAlignment = Enum.TextYAlignment.Top
infoText.Parent = infoFrame

createButton(settingsPage, 214, "🗑️ Закрыть Скрипт", Color3.fromRGB(100, 30, 30), function()
    MainGui:Destroy()
end)

-- ════════════════════════════════════════
--         DRAGGABLE WINDOW
-- ════════════════════════════════════════
local draggingWindow = false
local dragStart, startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        draggingWindow = true
        dragStart = input.Position
        startPos = MainWindow.Position
    end
end)

TopBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        draggingWindow = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingWindow and (input.UserInputType == Enum.UserInputType.MouseMovement or
       input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainWindow.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- ════════════════════════════════════════
--         MINIMIZE / CLOSE
-- ════════════════════════════════════════
local minimized = false
local originalSize = MainWindow.Size

MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(MainWindow, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 520, 0, 45)
        }):Play()
        MinBtn.Text = "+"
        ContentFrame.Visible = false
        TabBar.Visible = false
    else
        TweenService:Create(MainWindow, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Size = originalSize
        }):Play()
        MinBtn.Text = "−"
        task.wait(0.25)
        ContentFrame.Visible = true
        TabBar.Visible = true
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainWindow, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(
            MainWindow.Position.X.Scale,
            MainWindow.Position.X.Offset + 260,
            MainWindow.Position.Y.Scale,
            MainWindow.Position.Y.Offset + 200
        )
    }):Play()
    task.wait(0.3)
    MainGui:Destroy()
end)

-- ════════════════════════════════════════
--         KEYBIND: INSERT = TOGGLE GUI
-- ════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        MainWindow.Visible = not MainWindow.Visible
    end
    -- Infinite jump
    if input.KeyCode == Enum.KeyCode.Space and Settings.InfiniteJump then
        local hum = Character and Character:FindFirstChildOfClass("Humanoid")
        if hum and hum:GetState() == Enum.HumanoidStateType.Jumping then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ════════════════════════════════════════
--         STATUS BAR (bottom of window)
-- ════════════════════════════════════════
local StatusBar = Instance.new("Frame")
StatusBar.Size = UDim2.new(1, 0, 0, 22)
StatusBar.Position = UDim2.new(0, 0, 1, -22)
StatusBar.BackgroundColor3 = Colors.Panel
StatusBar.BorderSizePixel = 0
StatusBar.ZIndex = 5
StatusBar.Parent = MainWindow

local StatusBarCorner = Instance.new("UICorner")
StatusBarCorner.CornerRadius = UDim.new(0, 12)
StatusBarCorner.Parent = StatusBar

local StatusBarFix = Instance.new("Frame")
StatusBarFix.Size = UDim2.new(1, 0, 0.5, 0)
StatusBarFix.BackgroundColor3 = Colors.Panel
StatusBarFix.BorderSizePixel = 0
StatusBarFix.ZIndex = 5
StatusBarFix.Parent = StatusBar

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(0.7, 0, 1, 0)
StatusText.Position = UDim2.new(0, 8, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "✅ MARK SCRIPTS | Активен"
StatusText.TextColor3 = Colors.Green
StatusText.TextSize = 10
StatusText.Font = Enum.Font.Gotham
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.ZIndex = 6
StatusText.Parent = StatusBar

local PoweredText = Instance.new("TextLabel")
PoweredText.Size = UDim2.new(0.4, 0, 1, 0)
PoweredText.Position = UDim2.new(0.6, 0, 0, 0)
PoweredText.BackgroundTransparency = 1
PoweredText.Text = "Powered by Primejtsu"
PoweredText.TextColor3 = Colors.Gold
PoweredText.TextSize = 10
PoweredText.Font = Enum.Font.GothamSemibold
PoweredText.TextXAlignment = Enum.TextXAlignment.Right
PoweredText.ZIndex = 6
PoweredText.Parent = StatusBar

-- ════════════════════════════════════════
--         CORE FARMING LOOP
-- ════════════════════════════════════════
local function getFruits()
    local fruits = {}
    local possibleNames = {
        "Fruit", "Apple", "Orange", "Banana", "Grape", "Berry",
        "Mango", "Cherry", "Pear", "Peach", "Plum", "Lemon",
        "Watermelon", "Strawberry", "Blueberry", "Pineapple",
        "Coconut", "Papaya", "Guava", "Dragonfruit", "Starfruit",
        "Passionfruit", "Kiwi", "Lychee", "Durian", "Jackfruit",
        "Pomegranate", "Fig", "Avocado", "Melon", "Lime",
        "Grapefruit", "Tangerine", "Clementine", "Mandarin"
    }
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            for _, fname in ipairs(possibleNames) do
                if obj.Name:lower():find(fname:lower()) then
                    table.insert(fruits, obj)
                    break
                end
            end
        end
    end
    return fruits
end

local function getSellPoint()
    local sellNames = {"sell", "shop", "market", "store", "vendor", "trader"}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            for _, n in ipairs(sellNames) do
                if obj.Name:lower():find(n) then
                    return obj
                end
            end
        end
    end
    return nil
end

local function collectFruit(fruitObj)
    if not fruitObj or not fruitObj.Parent then return end
    local pos
    if fruitObj:IsA("BasePart") then
        pos = fruitObj.Position
    elseif fruitObj:IsA("Model") and fruitObj.PrimaryPart then
        pos = fruitObj.PrimaryPart.Position
    elseif fruitObj:IsA("Model") then
        pos = fruitObj:GetModelCFrame().p
    else
        return
    end
    -- Teleport close to fruit
    HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    task.wait(0.1)
    -- Try to fire collect remote
    local remotes = ReplicatedStorage:GetDescendants()
    for _, r in pairs(remotes) do
        if r:IsA("RemoteEvent") or r:IsA("RemoteFunction") then
            local n = r.Name:lower()
            if n:find("collect") or n:find("pickup") or n:find("grab") or n:find("fruit") then
                pcall(function()
                    if r:IsA("RemoteEvent") then
                        r:FireServer(fruitObj)
                    end
                end)
            end
        end
    end
end

local function doAutoSell()
    local sell = getSellPoint()
    if sell then
        local origPos = HumanoidRootPart.CFrame
        HumanoidRootPart.CFrame = CFrame.new(sell.Position + Vector3.new(0, 3, 0))
        task.wait(0.3)
        -- Try sell remotes
        for _, r in pairs(ReplicatedStorage:GetDescendants()) do
            if r:IsA("RemoteEvent") or r:IsA("RemoteFunction") then
                local n = r.Name:lower()
                if n:find("sell") or n:find("cash") or n:find("coins") then
                    pcall(function()
                        if r:IsA("RemoteEvent") then r:FireServer() end
                    end)
                end
            end
        end
        task.wait(0.2)
        HumanoidRootPart.CFrame = origPos
    end
end

-- ESP function
local function updateESP()
    -- Remove old ESP
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "_MarkESP" then v:Destroy() end
    end
    if not Settings.FruitESP then return end

    local fruits = getFruits()
    for _, fruit in ipairs(fruits) do
        local pos
        if fruit:IsA("BasePart") then
            pos = fruit.Position
        elseif fruit:IsA("Model") then
            pcall(function() pos = fruit:GetModelCFrame().p end)
        end
        if pos then
            local bb = Instance.new("BillboardGui")
            bb.Name = "_MarkESP"
            bb.Size = UDim2.new(0, 60, 0, 20)
            bb.StudsOffset = Vector3.new(0, 3, 0)
            bb.AlwaysOnTop = true
            bb.Parent = fruit:IsA("BasePart") and fruit or fruit.PrimaryPart or fruit
            local lbl3 = Instance.new("TextLabel", bb)
            lbl3.Size = UDim2.new(1, 0, 1, 0)
            lbl3.BackgroundTransparency = 1
            lbl3.Text = "🍎"
            lbl3.TextColor3 = Colors.Green
            lbl3.TextSize = 16
            lbl3.Font = Enum.Font.GothamBold
        end
    end
end

-- ════════════════════════════════════════
--         MAIN GAME LOOP
-- ════════════════════════════════════════
local farmTick = 0
local espTick = 0
local sellCounter = 0

RunService.Heartbeat:Connect(function(dt)
    farmTick = farmTick + dt
    espTick = espTick + dt

    -- Update character references
    Character = LocalPlayer.Character
    if Character then
        HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") or HumanoidRootPart
        Humanoid = Character:FindFirstChildOfClass("Humanoid") or Humanoid
    end

    -- Speed hack
    if Settings.SpeedHack and Humanoid then
        if Humanoid.WalkSpeed ~= Settings.WalkSpeed then
            Humanoid.WalkSpeed = Settings.WalkSpeed
        end
    end

    -- No clip
    if Settings.NoClip and Character then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    -- Farm tick every 0.5s
    if farmTick >= 0.5 then
        farmTick = 0

        if Settings.AutoFarm and HumanoidRootPart then
            local fruits = getFruits()
            local closest = nil
            local closestDist = math.huge
            for _, f in ipairs(fruits) do
                local pos
                if f:IsA("BasePart") then pos = f.Position
                elseif f:IsA("Model") then
                    pcall(function() pos = f:GetModelCFrame().p end)
                end
                if pos then
                    local dist = (HumanoidRootPart.Position - pos).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = f
                    end
                end
            end
            if closest then
                collectFruit(closest)
                sellCounter = sellCounter + 1
                StatusText.Text = "🌾 Собрано: " .. sellCounter .. " фруктов"
            end
        end

        if Settings.AutoSell then
            doAutoSell()
        end
    end

    -- ESP tick every 2s
    if espTick >= 2 then
        espTick = 0
        if Settings.FruitESP then
            pcall(updateESP)
        end
    end

    -- Server hop
    if Settings.ServerHop then
        local fruits = getFruits()
        if #fruits < 3 then
            pcall(function()
                local TeleportService = game:GetService("TeleportService")
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end)
        end
    end

    -- Auto Quest
    if Settings.AutoQuest then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name:lower():find("quest") or obj.Name:lower():find("order") then
                if obj:IsA("BasePart") then
                    for _, r in pairs(ReplicatedStorage:GetDescendants()) do
                        if r:IsA("RemoteEvent") and r.Name:lower():find("quest") then
                            pcall(function() r:FireServer(obj) end)
                        end
                    end
                end
            end
        end
    end
end)

-- Infinite jump
UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ════════════════════════════════════════
--         NOTIFICATION SYSTEM
-- ════════════════════════════════════════
local function notify(title, message, duration)
    duration = duration or 3
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 280, 0, 60)
    notif.Position = UDim2.new(1, -290, 1, -80)
    notif.BackgroundColor3 = Colors.Panel
    notif.BorderSizePixel = 0
    notif.ZIndex = 100
    notif.Parent = MainGui
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 10)

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 4, 1, 0)
    accent.BackgroundColor3 = Colors.Accent
    accent.BorderSizePixel = 0
    accent.ZIndex = 101
    accent.Parent = notif
    Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 10)

    local t1 = Instance.new("TextLabel")
    t1.Size = UDim2.new(1, -16, 0, 22)
    t1.Position = UDim2.new(0, 12, 0, 6)
    t1.BackgroundTransparency = 1
    t1.Text = title
    t1.TextColor3 = Colors.Text
    t1.TextSize = 13
    t1.Font = Enum.Font.GothamBold
    t1.TextXAlignment = Enum.TextXAlignment.Left
    t1.ZIndex = 101
    t1.Parent = notif

    local t2 = Instance.new("TextLabel")
    t2.Size = UDim2.new(1, -16, 0, 18)
    t2.Position = UDim2.new(0, 12, 0, 30)
    t2.BackgroundTransparency = 1
    t2.Text = message
    t2.TextColor3 = Colors.TextDim
    t2.TextSize = 11
    t2.Font = Enum.Font.Gotham
    t2.TextXAlignment = Enum.TextXAlignment.Left
    t2.ZIndex = 101
    t2.Parent = notif

    -- Slide in
    notif.Position = UDim2.new(1, 10, 1, -80)
    TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Position = UDim2.new(1, -290, 1, -80)
    }):Play()

    task.delay(duration, function()
        TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Position = UDim2.new(1, 10, 1, -80)
        }):Play()
        task.wait(0.3)
        notif:Destroy()
    end)
end

-- Welcome notification
task.wait(2)
notify("🍎 MARK SCRIPTS", "Fruit Forager Hub загружен! [INSERT] - скрыть GUI", 4)
task.wait(1.5)
notify("⚡ Powered by Primejtsu", "Нажмите кнопки для активации функций", 3)

print([[
    ╔══════════════════════════════════════╗
    ║        MARK SCRIPTS LOADED           ║
    ║     Fruit Forager | v1.0             ║
    ║     Powered by Primejtsu            ║
    ╚══════════════════════════════════════╝
]])
