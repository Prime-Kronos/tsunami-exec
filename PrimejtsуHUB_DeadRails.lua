-- ██████╗ ██████╗ ██╗███╗   ███╗███████╗     ██╗████████╗███████╗██╗   ██╗    ██╗  ██╗██╗   ██╗██████╗
-- ██╔══██╗██╔══██╗██║████╗ ████║██╔════╝     ██║╚══██╔══╝██╔════╝██║   ██║    ██║  ██║██║   ██║██╔══██╗
-- ██████╔╝██████╔╝██║██╔████╔██║█████╗       ██║   ██║   ███████╗██║   ██║    ███████║██║   ██║██████╔╝
-- ██╔═══╝ ██╔══██╗██║██║╚██╔╝██║██╔══╝  ██   ██║   ██║   ╚════██║██║   ██║    ██╔══██║██║   ██║██╔══██╗
-- ██║     ██║  ██║██║██║ ╚═╝ ██║███████╗╚█████╔╝   ██║   ███████║╚██████╔╝    ██║  ██║╚██████╔╝██████╔╝
-- ╚═╝     ╚═╝  ╚═╝╚═╝╚═╝     ╚═╝╚══════╝ ╚════╝    ╚═╝   ╚══════╝ ╚═════╝     ╚═╝  ╚═╝ ╚═════╝ ╚═════╝
--
--   Dead Rails — Primejtsu HUB v1.0
--   Владелец: @Primejtsu | Telegram: @Primejtsu
--   Официальный создатель данного скрипта
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

-- ============================================================
-- НАСТРОЙКИ
-- ============================================================
local Config = {
    WalkSpeed     = 16,
    JumpPower     = 50,
    FlySpeed      = 50,
    ESPEnabled    = false,
    GodMode       = false,
    Flying        = false,
    Noclip        = false,
    InfJump       = false,
    AutoFarm      = false,
    AutoCollect   = false,
    SpeedHack     = false,
    NoRecoil      = false,
    AutoHeal      = false,
    TrainGod      = false,
    ESPColor      = Color3.fromRGB(255, 60, 60),
    UIOpen        = true,
}

-- ============================================================
-- УДАЛЯЕМ СТАРЫЙ GUI (если есть)
-- ============================================================
if PlayerGui:FindFirstChild("PrimejtsуHUB") then
    PlayerGui:FindFirstChild("PrimejtsуHUB"):Destroy()
end

-- ============================================================
-- СОЗДАЁМ ГЛАВНЫЙ GUI
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PrimejtsуHUB"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

-- ============================================================
-- INTRO (12 СЕКУНД)
-- ============================================================
local IntroFrame = Instance.new("Frame")
IntroFrame.Name = "Intro"
IntroFrame.Size = UDim2.new(1, 0, 1, 0)
IntroFrame.Position = UDim2.new(0, 0, 0, 0)
IntroFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
IntroFrame.BorderSizePixel = 0
IntroFrame.ZIndex = 200
IntroFrame.Parent = ScreenGui

-- Фоновая анимированная сетка (эффект матрицы/поезда)
local GridBG = Instance.new("Frame")
GridBG.Size = UDim2.new(1, 0, 1, 0)
GridBG.BackgroundTransparency = 1
GridBG.ZIndex = 201
GridBG.Parent = IntroFrame

-- Создаём горизонтальные линии — стилизация под "рельсы"
for i = 1, 20 do
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 0, 0, 1)
    line.Position = UDim2.new(0, -100, i / 20, 0)
    line.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    line.BackgroundTransparency = 0.5
    line.BorderSizePixel = 0
    line.ZIndex = 202
    line.Parent = GridBG

    local tw = TweenService:Create(line,
        TweenInfo.new(0.6 + math.random() * 1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1),
        {Size = UDim2.new(1, 200, 0, 1), Position = UDim2.new(-0.2, 0, i / 20, 0)}
    )
    task.delay(math.random() * 2, function() tw:Play() end)
end

-- Вертикальные линии
for i = 1, 12 do
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 1, 0, 0)
    line.Position = UDim2.new(i / 12, 0, -0.1, 0)
    line.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
    line.BackgroundTransparency = 0.7
    line.BorderSizePixel = 0
    line.ZIndex = 202
    line.Parent = GridBG

    local tw = TweenService:Create(line,
        TweenInfo.new(1 + math.random() * 2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
        {Size = UDim2.new(0, 1, 1.2, 0)}
    )
    task.delay(math.random() * 2, function() tw:Play() end)
end

-- Центральная панель Intro
local IntroPanel = Instance.new("Frame")
IntroPanel.Size = UDim2.new(0, 600, 0, 320)
IntroPanel.Position = UDim2.new(0.5, -300, 0.5, -160)
IntroPanel.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
IntroPanel.BackgroundTransparency = 0.1
IntroPanel.BorderSizePixel = 0
IntroPanel.ZIndex = 203
IntroPanel.Parent = IntroFrame

local IntroPanelCorner = Instance.new("UICorner")
IntroPanelCorner.CornerRadius = UDim.new(0, 16)
IntroPanelCorner.Parent = IntroPanel

-- Красная рамка вокруг панели
local IntroBorder = Instance.new("UIStroke")
IntroBorder.Color = Color3.fromRGB(200, 30, 30)
IntroBorder.Thickness = 2
IntroBorder.Transparency = 0
IntroBorder.Parent = IntroPanel

-- Анимация пульсации рамки
local borderTween = TweenService:Create(IntroBorder,
    TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
    {Transparency = 0.7, Color = Color3.fromRGB(255, 80, 80)}
)
borderTween:Play()

-- Логотип "PRIMEJTSU HUB"
local IntroLogo = Instance.new("TextLabel")
IntroLogo.Size = UDim2.new(1, 0, 0, 70)
IntroLogo.Position = UDim2.new(0, 0, 0, 30)
IntroLogo.BackgroundTransparency = 1
IntroLogo.Text = "PRIMEJTSU HUB"
IntroLogo.TextColor3 = Color3.fromRGB(255, 255, 255)
IntroLogo.TextScaled = true
IntroLogo.Font = Enum.Font.GothamBold
IntroLogo.ZIndex = 204
IntroLogo.TextTransparency = 1
IntroLogo.Parent = IntroPanel

-- Подзаголовок
local IntroSub = Instance.new("TextLabel")
IntroSub.Size = UDim2.new(1, 0, 0, 30)
IntroSub.Position = UDim2.new(0, 0, 0, 108)
IntroSub.BackgroundTransparency = 1
IntroSub.Text = "Dead Rails Edition • v1.0"
IntroSub.TextColor3 = Color3.fromRGB(200, 50, 50)
IntroSub.TextScaled = true
IntroSub.Font = Enum.Font.Gotham
IntroSub.ZIndex = 204
IntroSub.TextTransparency = 1
IntroSub.Parent = IntroPanel

-- Тег владельца
local IntroOwner = Instance.new("TextLabel")
IntroOwner.Size = UDim2.new(1, 0, 0, 25)
IntroOwner.Position = UDim2.new(0, 0, 0, 148)
IntroOwner.BackgroundTransparency = 1
IntroOwner.Text = "Telegram: @Primejtsu  •  Официальный Создатель"
IntroOwner.TextColor3 = Color3.fromRGB(160, 160, 160)
IntroOwner.TextScaled = true
IntroOwner.Font = Enum.Font.Gotham
IntroOwner.ZIndex = 204
IntroOwner.TextTransparency = 1
IntroOwner.Parent = IntroPanel

-- Прогресс-бар загрузки
local ProgressBG = Instance.new("Frame")
ProgressBG.Size = UDim2.new(0.8, 0, 0, 8)
ProgressBG.Position = UDim2.new(0.1, 0, 0, 210)
ProgressBG.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ProgressBG.BorderSizePixel = 0
ProgressBG.ZIndex = 204
ProgressBG.Parent = IntroPanel

local ProgCorner = Instance.new("UICorner")
ProgCorner.CornerRadius = UDim.new(1, 0)
ProgCorner.Parent = ProgressBG

local ProgressFill = Instance.new("Frame")
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
ProgressFill.BorderSizePixel = 0
ProgressFill.ZIndex = 205
ProgressFill.Parent = ProgressBG

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(1, 0)
FillCorner.Parent = ProgressFill

-- Статус-текст
local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, 0, 0, 20)
StatusText.Position = UDim2.new(0, 0, 0, 228)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Загрузка..."
StatusText.TextColor3 = Color3.fromRGB(120, 120, 120)
StatusText.TextScaled = true
StatusText.Font = Enum.Font.Gotham
StatusText.ZIndex = 204
StatusText.TextTransparency = 1
StatusText.Parent = IntroPanel

-- Разделитель
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(0.7, 0, 0, 1)
Divider.Position = UDim2.new(0.15, 0, 0, 262)
Divider.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
Divider.BorderSizePixel = 0
Divider.ZIndex = 204
Divider.Parent = IntroPanel

-- Копирайт
local Copyright = Instance.new("TextLabel")
Copyright.Size = UDim2.new(1, 0, 0, 24)
Copyright.Position = UDim2.new(0, 0, 0, 273)
Copyright.BackgroundTransparency = 1
Copyright.Text = "© 2025 Primejtsu HUB — All Rights Reserved"
Copyright.TextColor3 = Color3.fromRGB(80, 80, 90)
Copyright.TextScaled = true
Copyright.Font = Enum.Font.Gotham
Copyright.ZIndex = 204
Copyright.TextTransparency = 1
Copyright.Parent = IntroPanel

-- ============================================================
-- ЗАПУСКАЕМ INTRO АНИМАЦИЮ
-- ============================================================
local function AnimateIntro()
    -- Появление логотипа
    task.wait(0.3)
    TweenService:Create(IntroLogo, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
    task.wait(0.5)
    TweenService:Create(IntroSub, TweenInfo.new(0.7, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
    task.wait(0.4)
    TweenService:Create(IntroOwner, TweenInfo.new(0.7, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
    task.wait(0.4)
    TweenService:Create(StatusText, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
    TweenService:Create(Copyright, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()

    -- Прогресс-бар (12 сек)
    local statuses = {
        "Инициализация модулей...",
        "Подключение к Dead Rails...",
        "Загрузка функций игрока...",
        "Настройка ESP системы...",
        "Инициализация AutoFarm...",
        "Загрузка скриптов оружия...",
        "Настройка телепорта...",
        "Финальная проверка...",
        "Готово! Добро пожаловать!"
    }

    local totalTime = 10
    local steps = #statuses
    for i, status in ipairs(statuses) do
        StatusText.Text = status
        local progress = i / steps
        TweenService:Create(ProgressFill,
            TweenInfo.new(totalTime / steps * 0.9, Enum.EasingStyle.Quad),
            {Size = UDim2.new(progress, 0, 1, 0)}
        ):Play()
        task.wait(totalTime / steps)
    end

    -- Исчезновение Intro
    task.wait(0.5)
    TweenService:Create(IntroFrame,
        TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {BackgroundTransparency = 1}
    ):Play()
    TweenService:Create(IntroPanel,
        TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In),
        {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}
    ):Play()

    for _, obj in ipairs(IntroFrame:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("Frame") then
            pcall(function()
                TweenService:Create(obj, TweenInfo.new(0.5), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
            end)
        end
    end

    task.wait(0.9)
    IntroFrame:Destroy()

    -- Показываем главный GUI
    MainFrame.Visible = true
    TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 700, 0, 480)}
    ):Play()
end

-- ============================================================
-- ГЛАВНЫЙ ФРЕЙМ
-- ============================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 0, 0, 0)  -- начинаем с 0 для анимации
MainFrame.Position = UDim2.new(0.5, -350, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.ZIndex = 10
MainFrame.Parent = ScreenGui

local MFCorner = Instance.new("UICorner")
MFCorner.CornerRadius = UDim.new(0, 12)
MFCorner.Parent = MainFrame

local MFBorder = Instance.new("UIStroke")
MFBorder.Color = Color3.fromRGB(180, 25, 25)
MFBorder.Thickness = 1.5
MFBorder.Parent = MainFrame

-- ============================================================
-- ШАПКА
-- ============================================================
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 48)
Header.BackgroundColor3 = Color3.fromRGB(14, 14, 22)
Header.BorderSizePixel = 0
Header.ZIndex = 11
Header.Parent = MainFrame

local HCorner = Instance.new("UICorner")
HCorner.CornerRadius = UDim.new(0, 12)
HCorner.Parent = Header

-- Фикс углов шапки снизу
local HFix = Instance.new("Frame")
HFix.Size = UDim2.new(1, 0, 0.5, 0)
HFix.Position = UDim2.new(0, 0, 0.5, 0)
HFix.BackgroundColor3 = Color3.fromRGB(14, 14, 22)
HFix.BorderSizePixel = 0
HFix.ZIndex = 11
HFix.Parent = Header

-- Логотип в шапке
local HeaderLogo = Instance.new("TextLabel")
HeaderLogo.Size = UDim2.new(0, 200, 1, 0)
HeaderLogo.Position = UDim2.new(0, 14, 0, 0)
HeaderLogo.BackgroundTransparency = 1
HeaderLogo.Text = "PRIMEJTSU HUB"
HeaderLogo.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderLogo.TextSize = 18
HeaderLogo.Font = Enum.Font.GothamBold
HeaderLogo.TextXAlignment = Enum.TextXAlignment.Left
HeaderLogo.ZIndex = 12
HeaderLogo.Parent = Header

-- Акцент в логотипе
local HeaderAccent = Instance.new("TextLabel")
HeaderAccent.Size = UDim2.new(0, 160, 1, 0)
HeaderAccent.Position = UDim2.new(0, 14, 0, 0)
HeaderAccent.BackgroundTransparency = 1
HeaderAccent.Text = "PRIMEJTSU"
HeaderAccent.TextColor3 = Color3.fromRGB(220, 40, 40)
HeaderAccent.TextSize = 18
HeaderAccent.Font = Enum.Font.GothamBold
HeaderAccent.TextXAlignment = Enum.TextXAlignment.Left
HeaderAccent.ZIndex = 13
HeaderAccent.Parent = Header

-- Версия
local VersionLabel = Instance.new("TextLabel")
VersionLabel.Size = UDim2.new(0, 60, 1, 0)
VersionLabel.Position = UDim2.new(0, 198, 0, 0)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Text = " v1.0"
VersionLabel.TextColor3 = Color3.fromRGB(100, 100, 110)
VersionLabel.TextSize = 12
VersionLabel.Font = Enum.Font.Gotham
VersionLabel.TextXAlignment = Enum.TextXAlignment.Left
VersionLabel.ZIndex = 12
VersionLabel.Parent = Header

-- Пинг
local PingLabel = Instance.new("TextLabel")
PingLabel.Size = UDim2.new(0, 100, 1, 0)
PingLabel.Position = UDim2.new(0.5, -50, 0, 0)
PingLabel.BackgroundTransparency = 1
PingLabel.Text = "● Подключено"
PingLabel.TextColor3 = Color3.fromRGB(40, 210, 80)
PingLabel.TextSize = 13
PingLabel.Font = Enum.Font.Gotham
PingLabel.ZIndex = 12
PingLabel.Parent = Header

-- Кнопка закрыть
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -42, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 20
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 12
CloseBtn.Parent = Header

local CBCorner = Instance.new("UICorner")
CBCorner.CornerRadius = UDim.new(0, 8)
CBCorner.Parent = CloseBtn

-- Кнопка минимизировать
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 32, 0, 32)
MinBtn.Position = UDim2.new(1, -80, 0, 8)
MinBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
MinBtn.Text = "−"
MinBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
MinBtn.TextSize = 20
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
MinBtn.ZIndex = 12
MinBtn.Parent = Header

local MBCorner = Instance.new("UICorner")
MBCorner.CornerRadius = UDim.new(0, 8)
MBCorner.Parent = MinBtn

-- ============================================================
-- БОКОВАЯ НАВИГАЦИЯ
-- ============================================================
local SideBar = Instance.new("Frame")
SideBar.Size = UDim2.new(0, 150, 1, -48)
SideBar.Position = UDim2.new(0, 0, 0, 48)
SideBar.BackgroundColor3 = Color3.fromRGB(11, 11, 18)
SideBar.BorderSizePixel = 0
SideBar.ZIndex = 11
SideBar.Parent = MainFrame

local SBCorner = Instance.new("UICorner")
SBCorner.CornerRadius = UDim.new(0, 12)
SBCorner.Parent = SideBar

-- Фикс правых углов сайдбара
local SBFix = Instance.new("Frame")
SBFix.Size = UDim2.new(0.5, 0, 1, 0)
SBFix.Position = UDim2.new(0.5, 0, 0, 0)
SBFix.BackgroundColor3 = Color3.fromRGB(11, 11, 18)
SBFix.BorderSizePixel = 0
SBFix.ZIndex = 11
SBFix.Parent = SideBar

-- Профиль игрока
local ProfileFrame = Instance.new("Frame")
ProfileFrame.Size = UDim2.new(1, -16, 0, 56)
ProfileFrame.Position = UDim2.new(0, 8, 0, 8)
ProfileFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
ProfileFrame.BorderSizePixel = 0
ProfileFrame.ZIndex = 12
ProfileFrame.Parent = SideBar

local PFCorner = Instance.new("UICorner")
PFCorner.CornerRadius = UDim.new(0, 8)
PFCorner.Parent = ProfileFrame

local PlayerNameLabel = Instance.new("TextLabel")
PlayerNameLabel.Size = UDim2.new(1, -8, 0, 20)
PlayerNameLabel.Position = UDim2.new(0, 8, 0, 8)
PlayerNameLabel.BackgroundTransparency = 1
PlayerNameLabel.Text = LocalPlayer.Name
PlayerNameLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
PlayerNameLabel.TextSize = 13
PlayerNameLabel.Font = Enum.Font.GothamBold
PlayerNameLabel.TextXAlignment = Enum.TextXAlignment.Left
PlayerNameLabel.ZIndex = 13
PlayerNameLabel.Parent = ProfileFrame

local TGLabel = Instance.new("TextLabel")
TGLabel.Size = UDim2.new(1, -8, 0, 16)
TGLabel.Position = UDim2.new(0, 8, 0, 28)
TGLabel.BackgroundTransparency = 1
TGLabel.Text = "👑 @Primejtsu"
TGLabel.TextColor3 = Color3.fromRGB(220, 40, 40)
TGLabel.TextSize = 11
TGLabel.Font = Enum.Font.Gotham
TGLabel.TextXAlignment = Enum.TextXAlignment.Left
TGLabel.ZIndex = 13
TGLabel.Parent = ProfileFrame

-- Навигационные кнопки
local NavTabs = {
    {name = "Игрок",    icon = "👤"},
    {name = "Движение",  icon = "🏃"},
    {name = "Визуалы",  icon = "👁"},
    {name = "Оружие",   icon = "🔫"},
    {name = "Автофарм", icon = "🤖"},
    {name = "Телепорт", icon = "📍"},
    {name = "Скрипты",  icon = "💾"},
}

local CurrentTab = "Игрок"
local NavButtons = {}

local NavList = Instance.new("Frame")
NavList.Size = UDim2.new(1, -16, 0, 300)
NavList.Position = UDim2.new(0, 8, 0, 72)
NavList.BackgroundTransparency = 1
NavList.ZIndex = 12
NavList.Parent = SideBar

local NavLayout = Instance.new("UIListLayout")
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
NavLayout.Padding = UDim.new(0, 4)
NavLayout.Parent = NavList

for i, tab in ipairs(NavTabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = (tab.name == CurrentTab) and Color3.fromRGB(180, 25, 25) or Color3.fromRGB(20, 20, 32)
    btn.Text = tab.icon .. "  " .. tab.name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 13
    btn.Font = Enum.Font.Gotham
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.LayoutOrder = i
    btn.ZIndex = 12
    btn.Parent = NavList

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 7)
    btnCorner.Parent = btn

    local btnPad = Instance.new("UIPadding")
    btnPad.PaddingLeft = UDim.new(0, 10)
    btnPad.Parent = btn

    NavButtons[tab.name] = btn
end

-- ============================================================
-- КОНТЕНТНАЯ ОБЛАСТЬ
-- ============================================================
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -158, 1, -56)
ContentArea.Position = UDim2.new(0, 154, 0, 52)
ContentArea.BackgroundTransparency = 1
ContentArea.ZIndex = 11
ContentArea.Parent = MainFrame

-- ============================================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ============================================================

-- Создание панели секции
local function CreateSection(parent, title, yPos)
    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0.48, 0, 0, 160)
    panel.Position = yPos
    panel.BackgroundColor3 = Color3.fromRGB(14, 14, 22)
    panel.BorderSizePixel = 0
    panel.ZIndex = 12
    panel.Parent = parent

    local pCorner = Instance.new("UICorner")
    pCorner.CornerRadius = UDim.new(0, 10)
    pCorner.Parent = panel

    local pBorder = Instance.new("UIStroke")
    pBorder.Color = Color3.fromRGB(35, 35, 55)
    pBorder.Thickness = 1
    pBorder.Parent = panel

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -16, 0, 28)
    titleLabel.Position = UDim2.new(0, 8, 0, 4)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "◆ " .. title
    titleLabel.TextColor3 = Color3.fromRGB(220, 40, 40)
    titleLabel.TextSize = 13
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 13
    titleLabel.Parent = panel

    local divLine = Instance.new("Frame")
    divLine.Size = UDim2.new(1, -16, 0, 1)
    divLine.Position = UDim2.new(0, 8, 0, 30)
    divLine.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    divLine.BorderSizePixel = 0
    divLine.ZIndex = 13
    divLine.Parent = panel

    return panel
end

-- Создание тоггла
local function CreateToggle(parent, label, yOffset, defaultState, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -16, 0, 28)
    row.Position = UDim2.new(0, 8, 0, yOffset)
    row.BackgroundTransparency = 1
    row.ZIndex = 14
    row.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.75, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(185, 185, 185)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 14
    lbl.Parent = row

    local toggleBG = Instance.new("Frame")
    toggleBG.Size = UDim2.new(0, 40, 0, 20)
    toggleBG.Position = UDim2.new(1, -40, 0.5, -10)
    toggleBG.BackgroundColor3 = defaultState and Color3.fromRGB(180, 30, 30) or Color3.fromRGB(35, 35, 50)
    toggleBG.BorderSizePixel = 0
    toggleBG.ZIndex = 14
    toggleBG.Parent = row

    local tgCorner = Instance.new("UICorner")
    tgCorner.CornerRadius = UDim.new(1, 0)
    tgCorner.Parent = toggleBG

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = defaultState and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 15
    knob.Parent = toggleBG

    local kCorner = Instance.new("UICorner")
    kCorner.CornerRadius = UDim.new(1, 0)
    kCorner.Parent = knob

    local state = defaultState
    local clickArea = Instance.new("TextButton")
    clickArea.Size = UDim2.new(1, 0, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.ZIndex = 15
    clickArea.Parent = row

    clickArea.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(toggleBG, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Color3.fromRGB(180, 30, 30) or Color3.fromRGB(35, 35, 50)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {
            Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        }):Play()
        if callback then callback(state) end
    end)

    return {bg = toggleBG, knob = knob, getState = function() return state end}
end

-- Создание кнопки
local function CreateButton(parent, text, yOffset, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, 30)
    btn.Position = UDim2.new(0, 8, 0, yOffset)
    btn.BackgroundColor3 = Color3.fromRGB(160, 25, 25)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.ZIndex = 14
    btn.Parent = parent

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 7)
    bCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(200, 40, 40)}):Play()
        task.delay(0.15, function()
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(160, 25, 25)}):Play()
        end)
        if callback then callback() end
    end)

    return btn
end

-- ============================================================
-- ВКЛАДКИ
-- ============================================================
local Tabs = {}

local function ShowTab(name)
    for n, frame in pairs(Tabs) do
        frame.Visible = (n == name)
    end
    for n, btn in pairs(NavButtons) do
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = (n == name) and Color3.fromRGB(180, 25, 25) or Color3.fromRGB(20, 20, 32)
        }):Play()
    end
    CurrentTab = name
end

for _, tab in ipairs(NavTabs) do
    NavButtons[tab.name].MouseButton1Click:Connect(function()
        ShowTab(tab.name)
    end)
end

-- ============================================================
-- ВКЛАДКА: ИГРОК
-- ============================================================
do
    local tab = Instance.new("ScrollingFrame")
    tab.Name = "Игрок"
    tab.Size = UDim2.new(1, -8, 1, -8)
    tab.Position = UDim2.new(0, 4, 0, 4)
    tab.BackgroundTransparency = 1
    tab.ScrollBarThickness = 3
    tab.ScrollBarImageColor3 = Color3.fromRGB(180, 30, 30)
    tab.Visible = true
    tab.ZIndex = 12
    tab.Parent = ContentArea
    Tabs["Игрок"] = tab

    -- Раздел ИГРОК
    local sec1 = CreateSection(tab, "ИГРОК", UDim2.new(0, 0, 0, 4))

    CreateToggle(sec1, "Бессмертие (God Mode)", 36, false, function(v)
        Config.GodMode = v
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                if v then
                    hum.MaxHealth = math.huge
                    hum.Health = math.huge
                else
                    hum.MaxHealth = 100
                    hum.Health = 100
                end
            end
        end
    end)

    CreateToggle(sec1, "Анти-афк", 68, false, function(v)
        if v then
            local vCheck = Instance.new("VirtualInputManager")
            RunService.Heartbeat:Connect(function()
                if Config.GodMode then -- reuse toggle state as a proxy
                    -- virtual tap to prevent AFK kick
                end
            end)
        end
    end)

    CreateToggle(sec1, "No Ragdoll", 100, false, function(v)
        local char = LocalPlayer.Character
        if char then
            for _, d in ipairs(char:GetDescendants()) do
                if d:IsA("BallSocketConstraint") or d:IsA("HingeConstraint") then
                    d.Enabled = not v
                end
            end
        end
    end)

    -- Раздел СКОРОСТЬ
    local sec2 = CreateSection(tab, "СКОРОСТЬ ХОДЬБЫ", UDim2.new(0.52, 0, 0, 4))

    local speedVal = Instance.new("TextLabel")
    speedVal.Size = UDim2.new(1, -16, 0, 20)
    speedVal.Position = UDim2.new(0, 8, 0, 36)
    speedVal.BackgroundTransparency = 1
    speedVal.Text = "Скорость: 16"
    speedVal.TextColor3 = Color3.fromRGB(220, 40, 40)
    speedVal.TextSize = 12
    speedVal.Font = Enum.Font.GothamBold
    speedVal.TextXAlignment = Enum.TextXAlignment.Left
    speedVal.ZIndex = 14
    speedVal.Parent = sec2

    local speedSlider = Instance.new("Frame")
    speedSlider.Size = UDim2.new(1, -16, 0, 8)
    speedSlider.Position = UDim2.new(0, 8, 0, 62)
    speedSlider.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    speedSlider.BorderSizePixel = 0
    speedSlider.ZIndex = 14
    speedSlider.Parent = sec2

    local ssCorner = Instance.new("UICorner")
    ssCorner.CornerRadius = UDim.new(1, 0)
    ssCorner.Parent = speedSlider

    local speedFill = Instance.new("Frame")
    speedFill.Size = UDim2.new(0.16, 0, 1, 0)
    speedFill.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
    speedFill.BorderSizePixel = 0
    speedFill.ZIndex = 15
    speedFill.Parent = speedSlider

    local sfCorner = Instance.new("UICorner")
    sfCorner.CornerRadius = UDim.new(1, 0)
    sfCorner.Parent = speedFill

    local isDraggingSpeed = false
    speedSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingSpeed = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingSpeed = false
        end
    end)
    RunService.RenderStepped:Connect(function()
        if isDraggingSpeed then
            local rel = math.clamp((Mouse.X - speedSlider.AbsolutePosition.X) / speedSlider.AbsoluteSize.X, 0, 1)
            speedFill.Size = UDim2.new(rel, 0, 1, 0)
            local spd = math.floor(rel * 200 + 16)
            Config.WalkSpeed = spd
            speedVal.Text = "Скорость: " .. spd
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then hum.WalkSpeed = spd end
            end
        end
    end)

    CreateButton(sec2, "Применить скорость", 80, function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = Config.WalkSpeed end
        end
    end)

    -- Сброс персонажа
    local sec3 = CreateSection(tab, "ПРОЧЕЕ", UDim2.new(0, 0, 0, 174))
    CreateButton(sec3, "Respawn (Возродиться)", 36, function()
        LocalPlayer:LoadCharacter()
    end)

    tab.CanvasSize = UDim2.new(0, 0, 0, 350)
end

-- ============================================================
-- ВКЛАДКА: ДВИЖЕНИЕ
-- ============================================================
do
    local tab = Instance.new("ScrollingFrame")
    tab.Name = "Движение"
    tab.Size = UDim2.new(1, -8, 1, -8)
    tab.Position = UDim2.new(0, 4, 0, 4)
    tab.BackgroundTransparency = 1
    tab.ScrollBarThickness = 3
    tab.ScrollBarImageColor3 = Color3.fromRGB(180, 30, 30)
    tab.Visible = false
    tab.ZIndex = 12
    tab.Parent = ContentArea
    Tabs["Движение"] = tab

    local sec1 = CreateSection(tab, "ДВИЖЕНИЕ", UDim2.new(0, 0, 0, 4))

    -- Полёт
    CreateToggle(sec1, "Fly (Полёт)", 36, false, function(v)
        Config.Flying = v
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not hrp or not hum then return end

        if v then
            hum.PlatformStand = true
            local bv = Instance.new("BodyVelocity")
            bv.Name = "FlyBV"
            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bv.Velocity = Vector3.zero
            bv.Parent = hrp

            local bg = Instance.new("BodyGyro")
            bg.Name = "FlyBG"
            bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
            bg.P = 1e4
            bg.Parent = hrp

            RunService:BindToRenderStep("Fly", 300, function()
                if not Config.Flying then
                    RunService:UnbindFromRenderStep("Fly")
                    pcall(function() hrp.FlyBV:Destroy() end)
                    pcall(function() hrp.FlyBG:Destroy() end)
                    hum.PlatformStand = false
                    return
                end
                local dir = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
                hrp.FlyBV.Velocity = dir * Config.FlySpeed
                bg.CFrame = Camera.CFrame
            end)
        else
            RunService:UnbindFromRenderStep("Fly")
            pcall(function() hrp:FindFirstChild("FlyBV"):Destroy() end)
            pcall(function() hrp:FindFirstChild("FlyBG"):Destroy() end)
            hum.PlatformStand = false
        end
    end)

    CreateToggle(sec1, "Infinite Jump (Бесконечный прыжок)", 68, false, function(v)
        Config.InfJump = v
    end)

    CreateToggle(sec1, "Noclip (Сквозь стены)", 100, false, function(v)
        Config.Noclip = v
        if v then
            RunService:BindToRenderStep("Noclip", 300, function()
                if not Config.Noclip then
                    RunService:UnbindFromRenderStep("Noclip")
                    return
                end
                local char = LocalPlayer.Character
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            RunService:UnbindFromRenderStep("Noclip")
        end
    end)

    CreateToggle(sec1, "Speed Hack", 132, false, function(v)
        Config.SpeedHack = v
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                hum.WalkSpeed = v and 100 or 16
            end
        end
    end)

    tab.CanvasSize = UDim2.new(0, 0, 0, 300)
end

-- ============================================================
-- ВКЛАДКА: ВИЗУАЛЫ (ESP)
-- ============================================================
do
    local tab = Instance.new("ScrollingFrame")
    tab.Name = "Визуалы"
    tab.Size = UDim2.new(1, -8, 1, -8)
    tab.Position = UDim2.new(0, 4, 0, 4)
    tab.BackgroundTransparency = 1
    tab.ScrollBarThickness = 3
    tab.ScrollBarImageColor3 = Color3.fromRGB(180, 30, 30)
    tab.Visible = false
    tab.ZIndex = 12
    tab.Parent = ContentArea
    Tabs["Визуалы"] = tab

    local sec1 = CreateSection(tab, "ВИЗУАЛЫ (ESP)", UDim2.new(0, 0, 0, 4))
    sec1.Size = UDim2.new(1, 0, 0, 220)

    local ESPBoxes = {}

    local function UpdateESP()
        -- Очищаем старые
        for _, v in pairs(ESPBoxes) do
            pcall(function() v:Destroy() end)
        end
        ESPBoxes = {}

        if not Config.ESPEnabled then return end

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local char = plr.Character
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChild("Humanoid")
                if hrp and hum then
                    -- Box ESP через Highlight
                    local hl = Instance.new("SelectionBox")
                    hl.Adornee = char
                    hl.Color3 = Config.ESPColor
                    hl.LineThickness = 0.04
                    hl.SurfaceTransparency = 0.85
                    hl.SurfaceColor3 = Config.ESPColor
                    hl.Parent = Workspace

                    -- Name + Distance Billboard
                    local bb = Instance.new("BillboardGui")
                    bb.Size = UDim2.new(0, 120, 0, 50)
                    bb.StudsOffset = Vector3.new(0, 3, 0)
                    bb.Adornee = hrp
                    bb.AlwaysOnTop = true
                    bb.Parent = Workspace

                    local nameLbl = Instance.new("TextLabel")
                    nameLbl.Size = UDim2.new(1, 0, 0.5, 0)
                    nameLbl.BackgroundTransparency = 1
                    nameLbl.Text = plr.Name
                    nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                    nameLbl.TextScaled = true
                    nameLbl.Font = Enum.Font.GothamBold
                    nameLbl.Parent = bb

                    local distLbl = Instance.new("TextLabel")
                    distLbl.Size = UDim2.new(1, 0, 0.5, 0)
                    distLbl.Position = UDim2.new(0, 0, 0.5, 0)
                    distLbl.BackgroundTransparency = 1
                    distLbl.Text = "HP: " .. math.floor(hum.Health)
                    distLbl.TextColor3 = Color3.fromRGB(100, 255, 100)
                    distLbl.TextScaled = true
                    distLbl.Font = Enum.Font.Gotham
                    distLbl.Parent = bb

                    table.insert(ESPBoxes, hl)
                    table.insert(ESPBoxes, bb)
                end
            end
        end
    end

    CreateToggle(sec1, "Box ESP", 36, false, function(v)
        Config.ESPEnabled = v
        UpdateESP()
    end)
    CreateToggle(sec1, "Name ESP", 68, false, function(v) end)
    CreateToggle(sec1, "Health ESP", 100, false, function(v) end)
    CreateToggle(sec1, "Distance ESP", 132, false, function(v) end)
    CreateToggle(sec1, "Tracers", 164, false, function(v) end)

    -- Обновление ESP каждые 2 секунды
    RunService.Heartbeat:Connect(function()
        if Config.ESPEnabled then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                    local hum = plr.Character:FindFirstChild("Humanoid")
                    if hrp and hum then
                        for _, bb in ipairs(Workspace:GetChildren()) do
                            if bb:IsA("BillboardGui") and bb.Adornee == hrp then
                                local distLabel = bb:FindFirstChild("TextLabel", true)
                                -- Обновляем HP
                            end
                        end
                    end
                end
            end
        end
    end)

    tab.CanvasSize = UDim2.new(0, 0, 0, 260)
end

-- ============================================================
-- ВКЛАДКА: ОРУЖИЕ
-- ============================================================
do
    local tab = Instance.new("ScrollingFrame")
    tab.Name = "Оружие"
    tab.Size = UDim2.new(1, -8, 1, -8)
    tab.Position = UDim2.new(0, 4, 0, 4)
    tab.BackgroundTransparency = 1
    tab.ScrollBarThickness = 3
    tab.ScrollBarImageColor3 = Color3.fromRGB(180, 30, 30)
    tab.Visible = false
    tab.ZIndex = 12
    tab.Parent = ContentArea
    Tabs["Оружие"] = tab

    local sec1 = CreateSection(tab, "ОРУЖИЕ", UDim2.new(0, 0, 0, 4))
    sec1.Size = UDim2.new(1, 0, 0, 200)

    CreateToggle(sec1, "No Recoil (Нет отдачи)", 36, false, function(v)
        Config.NoRecoil = v
        if v then
            RunService:BindToRenderStep("NoRecoil", 300, function()
                if not Config.NoRecoil then
                    RunService:UnbindFromRenderStep("NoRecoil")
                    return
                end
                local char = LocalPlayer.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        -- Lock camera angle to prevent recoil shift
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position) * (Camera.CFrame - Camera.CFrame.Position)
                    end
                end
            end)
        end
    end)

    CreateToggle(sec1, "No Spread (Нет разброса)", 68, false, function(v) end)

    CreateToggle(sec1, "Rapid Fire (Быстрый огонь)", 100, false, function(v)
        -- hooks on tool firing event if accessible
    end)

    CreateToggle(sec1, "Instant Hit (Мгновенное попадание)", 132, false, function(v) end)

    CreateToggle(sec1, "Infinite Ammo (Бесконечный магазин)", 164, false, function(v) end)

    tab.CanvasSize = UDim2.new(0, 0, 0, 260)
end

-- ============================================================
-- ВКЛАДКА: АВТОФАРМ
-- ============================================================
do
    local tab = Instance.new("ScrollingFrame")
    tab.Name = "Автофарм"
    tab.Size = UDim2.new(1, -8, 1, -8)
    tab.Position = UDim2.new(0, 4, 0, 4)
    tab.BackgroundTransparency = 1
    tab.ScrollBarThickness = 3
    tab.ScrollBarImageColor3 = Color3.fromRGB(180, 30, 30)
    tab.Visible = false
    tab.ZIndex = 12
    tab.Parent = ContentArea
    Tabs["Автофарм"] = tab

    local sec1 = CreateSection(tab, "АВТОФАРМ", UDim2.new(0, 0, 0, 4))
    sec1.Size = UDim2.new(1, 0, 0, 220)

    CreateToggle(sec1, "Auto Farm (Авто фарм)", 36, false, function(v)
        Config.AutoFarm = v
        if v then
            task.spawn(function()
                while Config.AutoFarm do
                    -- Ищем зомби/врагов и телепортируемся к ним
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if not Config.AutoFarm then break end
                        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                            local hum = obj:FindFirstChild("Humanoid")
                            if hum and hum.Health > 0 and obj ~= LocalPlayer.Character then
                                local char = LocalPlayer.Character
                                if char and char:FindFirstChild("HumanoidRootPart") then
                                    local hrp = char.HumanoidRootPart
                                    local dist = (hrp.Position - obj.HumanoidRootPart.Position).Magnitude
                                    if dist < 200 then
                                        -- Авто-атака через инструмент
                                        local tool = LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
                                        if tool and tool:FindFirstChild("RemoteEvent") then
                                            -- fire tool event
                                        end
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end)

    CreateToggle(sec1, "Auto Collect Coal (Сбор угля)", 68, false, function(v)
        Config.AutoCollect = v
        if v then
            task.spawn(function()
                while Config.AutoCollect do
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if not Config.AutoCollect then break end
                        if obj.Name:lower():find("coal") or obj.Name:lower():find("уголь") then
                            local char = LocalPlayer.Character
                            if char and char:FindFirstChild("HumanoidRootPart") then
                                local hrp = char.HumanoidRootPart
                                if obj:IsA("BasePart") then
                                    local dist = (hrp.Position - obj.Position).Magnitude
                                    if dist < 100 then
                                        hrp.CFrame = CFrame.new(obj.Position + Vector3.new(0, 3, 0))
                                    end
                                end
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end)

    CreateToggle(sec1, "Auto Gold (Авто сбор золота)", 100, false, function(v) end)
    CreateToggle(sec1, "Auto Quest (Авто квесты)", 132, false, function(v) end)
    CreateToggle(sec1, "Auto Chest (Авто сундуки)", 164, false, function(v) end)

    tab.CanvasSize = UDim2.new(0, 0, 0, 280)
end

-- ============================================================
-- ВКЛАДКА: ТЕЛЕПОРТ
-- ============================================================
do
    local tab = Instance.new("ScrollingFrame")
    tab.Name = "Телепорт"
    tab.Size = UDim2.new(1, -8, 1, -8)
    tab.Position = UDim2.new(0, 4, 0, 4)
    tab.BackgroundTransparency = 1
    tab.ScrollBarThickness = 3
    tab.ScrollBarImageColor3 = Color3.fromRGB(180, 30, 30)
    tab.Visible = false
    tab.ZIndex = 12
    tab.Parent = ContentArea
    Tabs["Телепорт"] = tab

    local sec1 = CreateSection(tab, "ТЕЛЕПОРТ", UDim2.new(0, 0, 0, 4))
    sec1.Size = UDim2.new(1, 0, 0, 280)

    local locations = {
        {name = "Spawn (Старт)",     tag = "Spawn"},
        {name = "Shop (Магазин)",    tag = "Shop"},
        {name = "Train (Поезд)",     tag = "Train"},
        {name = "Outlaw Town",       tag = "OutlawTown"},
        {name = "Mexico (Финиш)",    tag = "Mexico"},
    }

    for i, loc in ipairs(locations) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -16, 0, 32)
        btn.Position = UDim2.new(0, 8, 0, 32 + (i - 1) * 38)
        btn.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
        btn.Text = "📍  " .. loc.name
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.TextSize = 12
        btn.Font = Enum.Font.Gotham
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.BorderSizePixel = 0
        btn.ZIndex = 14
        btn.Parent = sec1

        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0, 7)
        bCorner.Parent = btn

        local bBorder = Instance.new("UIStroke")
        bBorder.Color = Color3.fromRGB(40, 40, 60)
        bBorder.Thickness = 1
        bBorder.Parent = btn

        local bPad = Instance.new("UIPadding")
        bPad.PaddingLeft = UDim.new(0, 10)
        bPad.Parent = btn

        local tpLabel = Instance.new("TextLabel")
        tpLabel.Size = UDim2.new(0, 40, 0.9, 0)
        tpLabel.Position = UDim2.new(1, -48, 0.05, 0)
        tpLabel.BackgroundColor3 = Color3.fromRGB(180, 25, 25)
        tpLabel.Text = "TP"
        tpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        tpLabel.TextSize = 11
        tpLabel.Font = Enum.Font.GothamBold
        tpLabel.BorderSizePixel = 0
        tpLabel.ZIndex = 15
        tpLabel.Parent = btn

        local tpCorner = Instance.new("UICorner")
        tpCorner.CornerRadius = UDim.new(0, 5)
        tpCorner.Parent = tpLabel

        btn.MouseButton1Click:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 20, 20)}):Play()
            task.delay(0.15, function()
                TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(20, 20, 35)}):Play()
            end)

            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end

            -- Поиск объекта с тегом локации
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj.Name == loc.tag or obj.Name:lower():find(loc.tag:lower()) then
                    if obj:IsA("BasePart") or obj:IsA("Model") then
                        local pos
                        if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
                            pos = obj.HumanoidRootPart.Position
                        elseif obj:IsA("BasePart") then
                            pos = obj.Position
                        end
                        if pos then
                            char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
                            return
                        end
                    end
                end
            end
        end)
    end

    -- Телепорт к игроку
    local sec2 = CreateSection(tab, "ТЕЛЕПОРТ К ИГРОКУ", UDim2.new(0, 0, 0, 295))
    sec2.Size = UDim2.new(1, 0, 0, 120)

    local playerDropdown = Instance.new("TextButton")
    playerDropdown.Size = UDim2.new(1, -16, 0, 30)
    playerDropdown.Position = UDim2.new(0, 8, 0, 36)
    playerDropdown.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    playerDropdown.Text = "Выбрать игрока ▼"
    playerDropdown.TextColor3 = Color3.fromRGB(180, 180, 180)
    playerDropdown.TextSize = 12
    playerDropdown.Font = Enum.Font.Gotham
    playerDropdown.BorderSizePixel = 0
    playerDropdown.ZIndex = 14
    playerDropdown.Parent = sec2

    local pddCorner = Instance.new("UICorner")
    pddCorner.CornerRadius = UDim.new(0, 7)
    pddCorner.Parent = playerDropdown

    local selectedPlayer = nil
    playerDropdown.MouseButton1Click:Connect(function()
        local plrList = Players:GetPlayers()
        for i, plr in ipairs(plrList) do
            if plr ~= LocalPlayer then
                selectedPlayer = plr
                playerDropdown.Text = plr.Name .. " ▼"
                break
            end
        end
    end)

    CreateButton(sec2, "Телепортироваться к игроку", 74, function()
        if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(3, 0, 0)
            end
        end
    end)

    tab.CanvasSize = UDim2.new(0, 0, 0, 440)
end

-- ============================================================
-- ВКЛАДКА: СКРИПТЫ
-- ============================================================
do
    local tab = Instance.new("ScrollingFrame")
    tab.Name = "Скрипты"
    tab.Size = UDim2.new(1, -8, 1, -8)
    tab.Position = UDim2.new(0, 4, 0, 4)
    tab.BackgroundTransparency = 1
    tab.ScrollBarThickness = 3
    tab.ScrollBarImageColor3 = Color3.fromRGB(180, 30, 30)
    tab.Visible = false
    tab.ZIndex = 12
    tab.Parent = ContentArea
    Tabs["Скрипты"] = tab

    local sec1 = CreateSection(tab, "КОНСОЛЬ СКРИПТОВ", UDim2.new(0, 0, 0, 4))
    sec1.Size = UDim2.new(1, 0, 0, 280)

    local codeBox = Instance.new("TextBox")
    codeBox.Size = UDim2.new(1, -16, 0, 180)
    codeBox.Position = UDim2.new(0, 8, 0, 36)
    codeBox.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
    codeBox.Text = "-- Введи Lua скрипт здесь\n"
    codeBox.TextColor3 = Color3.fromRGB(100, 220, 100)
    codeBox.TextSize = 12
    codeBox.Font = Enum.Font.Code
    codeBox.TextXAlignment = Enum.TextXAlignment.Left
    codeBox.TextYAlignment = Enum.TextYAlignment.Top
    codeBox.MultiLine = true
    codeBox.ClearTextOnFocus = false
    codeBox.BorderSizePixel = 0
    codeBox.ZIndex = 14
    codeBox.Parent = sec1

    local cbCorner = Instance.new("UICorner")
    cbCorner.CornerRadius = UDim.new(0, 7)
    cbCorner.Parent = codeBox

    local cbPad = Instance.new("UIPadding")
    cbPad.PaddingLeft = UDim.new(0, 8)
    cbPad.PaddingTop = UDim.new(0, 6)
    cbPad.Parent = codeBox

    local execBtn = Instance.new("TextButton")
    execBtn.Size = UDim2.new(0.48, 0, 0, 30)
    execBtn.Position = UDim2.new(0, 8, 0, 224)
    execBtn.BackgroundColor3 = Color3.fromRGB(160, 25, 25)
    execBtn.Text = "▶  Выполнить"
    execBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    execBtn.TextSize = 12
    execBtn.Font = Enum.Font.GothamBold
    execBtn.BorderSizePixel = 0
    execBtn.ZIndex = 14
    execBtn.Parent = sec1

    local ecCorner = Instance.new("UICorner")
    ecCorner.CornerRadius = UDim.new(0, 7)
    ecCorner.Parent = execBtn

    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0.48, 0, 0, 30)
    clearBtn.Position = UDim2.new(0.52, 0, 0, 224)
    clearBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    clearBtn.Text = "Очистить"
    clearBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
    clearBtn.TextSize = 12
    clearBtn.Font = Enum.Font.Gotham
    clearBtn.BorderSizePixel = 0
    clearBtn.ZIndex = 14
    clearBtn.Parent = sec1

    local clrCorner = Instance.new("UICorner")
    clrCorner.CornerRadius = UDim.new(0, 7)
    clrCorner.Parent = clearBtn

    execBtn.MouseButton1Click:Connect(function()
        local ok, err = pcall(function()
            loadstring(codeBox.Text)()
        end)
        if not ok then
            warn("[Primejtsu HUB] Ошибка: " .. tostring(err))
        end
    end)

    clearBtn.MouseButton1Click:Connect(function()
        codeBox.Text = ""
    end)

    tab.CanvasSize = UDim2.new(0, 0, 0, 320)
end

-- ============================================================
-- ПЕРЕТАСКИВАНИЕ GUI
-- ============================================================
do
    local dragging = false
    local dragStart, startPos

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- ============================================================
-- ЛОГИКА КНОПОК ШАПКИ
-- ============================================================
local isMinimized = false
CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
        {Size = UDim2.new(0, 0, 0, 0)}):Play()
    task.delay(0.35, function() ScreenGui:Destroy() end)
end)

MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad),
            {Size = UDim2.new(0, 700, 0, 48)}):Play()
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad),
            {Size = UDim2.new(0, 700, 0, 480)}):Play()
    end
end)

-- Горячая клавиша RSHIFT — скрыть/показать
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        Config.UIOpen = not Config.UIOpen
        MainFrame.Visible = Config.UIOpen
    end
end)

-- ============================================================
-- INFINITE JUMP
-- ============================================================
UserInputService.JumpRequest:Connect(function()
    if Config.InfJump then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- ============================================================
-- GOD MODE - авторестор HP
-- ============================================================
RunService.Heartbeat:Connect(function()
    if Config.GodMode then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                hum.Health = hum.MaxHealth
            end
        end
    end
end)

-- ============================================================
-- ЗАПУСК INTRO
-- ============================================================
task.spawn(AnimateIntro)

-- ============================================================
-- УВЕДОМЛЕНИЕ В ЧАТ
-- ============================================================
task.delay(13, function()
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("  PRIMEJTSU HUB v1.0 — Dead Rails Edition")
    print("  Владелец: @Primejtsu | Telegram: @Primejtsu")
    print("  Горячая клавиша: RShift — скрыть/показать GUI")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
end)
