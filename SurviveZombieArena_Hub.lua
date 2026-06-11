-- ╔══════════════════════════════════════════════╗
-- ║     SURVIVE ZOMBIE ARENA - HUB SCRIPT        ║
-- ║     by Script Hub  |  Roblox Executor        ║
-- ╚══════════════════════════════════════════════╝

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- ══════════════════════════════════════
-- НАСТРОЙКИ (SETTINGS)
-- ══════════════════════════════════════
local Settings = {
    AutoFarm       = false,
    AutoCollect    = false,
    ESP            = false,
    InfiniteHealth = false,
    SpeedHack      = false,
    NoClip         = false,
    AutoDodge      = false,
    KillAura       = false,
    GodMode        = false,
    WalkSpeed      = 16,
    JumpPower      = 50,
}

-- ══════════════════════════════════════
-- УДАЛЕНИЕ СТАРОГО GUI
-- ══════════════════════════════════════
if game.CoreGui:FindFirstChild("ZombieHub") then
    game.CoreGui.ZombieHub:Destroy()
end

-- ══════════════════════════════════════
-- СОЗДАНИЕ GUI
-- ══════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZombieHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game.CoreGui

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 380, 0, 480)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Скруглённые углы
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

-- Граница/обводка
local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(180, 0, 0)
Stroke.Thickness = 2
Stroke.Parent = MainFrame

-- Градиент фона
local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 5, 5)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 18)),
})
Gradient.Rotation = 135
Gradient.Parent = MainFrame

-- ── ШАПКА (Header) ──────────────────────────────
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

-- Нижние углы шапки квадратные
local HeaderBottom = Instance.new("Frame")
HeaderBottom.Size = UDim2.new(1, 0, 0.5, 0)
HeaderBottom.Position = UDim2.new(0, 0, 0.5, 0)
HeaderBottom.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
HeaderBottom.BorderSizePixel = 0
HeaderBottom.Parent = Header

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -60, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🧟 ZOMBIE ARENA HUB"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 18
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

-- Кнопка закрыть X
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -76, 0.5, -15)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 14
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Parent = Header

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn

-- ── СТАТУС СТРОКА ──────────────────────────────
local StatusBar = Instance.new("Frame")
StatusBar.Size = UDim2.new(1, -20, 0, 28)
StatusBar.Position = UDim2.new(0, 10, 0, 56)
StatusBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
StatusBar.BorderSizePixel = 0
StatusBar.Parent = MainFrame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 6)
StatusCorner.Parent = StatusBar

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -10, 1, 0)
StatusLabel.Position = UDim2.new(0, 8, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "⚡ Статус: Ожидание..."
StatusLabel.TextColor3 = Color3.fromRGB(100, 220, 100)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = StatusBar

local function SetStatus(text, color)
    StatusLabel.Text = "⚡ " .. text
    StatusLabel.TextColor3 = color or Color3.fromRGB(100, 220, 100)
end

-- ── ВКЛАДКИ ──────────────────────────────────
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -20, 0, 35)
TabFrame.Position = UDim2.new(0, 10, 0, 90)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = MainFrame

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 5)
TabLayout.Parent = TabFrame

-- ── КОНТЕНТ (прокручиваемый) ──────────────────
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, -20, 1, -140)
ContentFrame.Position = UDim2.new(0, 10, 0, 132)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 3
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(180, 0, 0)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentFrame.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 8)
ContentLayout.Parent = ContentFrame

-- ══════════════════════════════════════
-- ФУНКЦИИ GUI
-- ══════════════════════════════════════

-- Создание вкладки
local ActiveTab = nil
local TabContents = {}

local function CreateTab(name, icon)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 80, 1, 0)
    TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    TabBtn.Text = icon .. " " .. name
    TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    TabBtn.TextSize = 11
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.BorderSizePixel = 0
    TabBtn.Parent = TabFrame

    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(0, 6)
    TCorner.Parent = TabBtn

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, 0, 1, 0)
    Content.BackgroundTransparency = 1
    Content.Visible = false
    Content.Parent = ContentFrame

    local CLayout = Instance.new("UIListLayout")
    CLayout.Padding = UDim.new(0, 8)
    CLayout.Parent = Content

    TabContents[name] = {Btn = TabBtn, Content = Content}

    TabBtn.MouseButton1Click:Connect(function()
        if ActiveTab then
            TabContents[ActiveTab].Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            TabContents[ActiveTab].Btn.TextColor3 = Color3.fromRGB(180, 180, 180)
            TabContents[ActiveTab].Content.Visible = false
        end
        ActiveTab = name
        TabBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Content.Visible = true
        ContentFrame.CanvasPosition = Vector2.new(0, 0)
    end)

    return Content
end

-- Создание переключателя (Toggle)
local function CreateToggle(parent, labelText, settingKey, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -10, 0, 40)
    Row.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    Row.BorderSizePixel = 0
    Row.Parent = parent

    local RCorner = Instance.new("UICorner")
    RCorner.CornerRadius = UDim.new(0, 8)
    RCorner.Parent = Row

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = labelText
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextSize = 13
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 44, 0, 22)
    ToggleBtn.Position = UDim2.new(1, -54, 0.5, -11)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    ToggleBtn.Text = ""
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Parent = Row

    local TBCorner = Instance.new("UICorner")
    TBCorner.CornerRadius = UDim.new(1, 0)
    TBCorner.Parent = ToggleBtn

    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 16, 0, 16)
    Circle.Position = UDim2.new(0, 3, 0.5, -8)
    Circle.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
    Circle.BorderSizePixel = 0
    Circle.Parent = ToggleBtn

    local CCorner = Instance.new("UICorner")
    CCorner.CornerRadius = UDim.new(1, 0)
    CCorner.Parent = Circle

    local state = Settings[settingKey] or false

    local function UpdateToggle()
        local tw = TweenService:Create(Circle, TweenInfo.new(0.15), {
            Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
        })
        tw:Play()
        ToggleBtn.BackgroundColor3 = state and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(50, 50, 60)
        Circle.BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
    end

    UpdateToggle()

    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        Settings[settingKey] = state
        UpdateToggle()
        if callback then callback(state) end
        SetStatus(labelText .. ": " .. (state and "ВКЛ ✅" or "ВЫКЛ ❌"),
            state and Color3.fromRGB(100, 220, 100) or Color3.fromRGB(220, 100, 100))
    end)

    return Row
end

-- Создание кнопки
local function CreateButton(parent, labelText, color, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 38)
    Btn.BackgroundColor3 = color or Color3.fromRGB(180, 0, 0)
    Btn.Text = labelText
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 13
    Btn.Font = Enum.Font.GothamBold
    Btn.BorderSizePixel = 0
    Btn.Parent = parent

    local BCorner = Instance.new("UICorner")
    BCorner.CornerRadius = UDim.new(0, 8)
    BCorner.Parent = Btn

    Btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    -- Hover эффект
    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(
                math.min(color.R * 255 + 30, 255),
                math.min(color.G * 255 + 30, 255),
                math.min(color.B * 255 + 30, 255)
            )
        }):Play()
    end)
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = color}):Play()
    end)

    return Btn
end

-- Секция-заголовок
local function CreateSection(parent, text)
    local Sec = Instance.new("TextLabel")
    Sec.Size = UDim2.new(1, -10, 0, 22)
    Sec.BackgroundTransparency = 1
    Sec.Text = "  ── " .. text .. " ──"
    Sec.TextColor3 = Color3.fromRGB(180, 0, 0)
    Sec.TextSize = 12
    Sec.Font = Enum.Font.GothamBold
    Sec.TextXAlignment = Enum.TextXAlignment.Left
    Sec.Parent = parent
    return Sec
end

-- ══════════════════════════════════════
-- ВКЛАДКИ
-- ══════════════════════════════════════

local TabMain    = CreateTab("Авто", "🤖")
local TabPlayer  = CreateTab("Игрок", "⚡")
local TabVisual  = CreateTab("Визуал", "👁")
local TabMisc    = CreateTab("Прочее", "⚙")

-- Активируем первую вкладку
TabContents["Авто"].Btn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
TabContents["Авто"].Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
TabContents["Авто"].Content.Visible = true
ActiveTab = "Авто"

-- ══════════════════════════════════════
-- ВКЛАДКА: АВТО (AutoFarm)
-- ══════════════════════════════════════
do
    local p = TabContents["Авто"].Content

    CreateSection(p, "Авто-Фарм")

    CreateToggle(p, "🧟 Авто Убийство Зомби", "AutoFarm", function(v)
        Settings.AutoFarm = v
    end)

    CreateToggle(p, "💰 Авто Сбор Кредитов", "AutoCollect", function(v)
        Settings.AutoCollect = v
    end)

    CreateToggle(p, "🏃 Авто Уворот от Зомби", "AutoDodge", function(v)
        Settings.AutoDodge = v
    end)

    CreateToggle(p, "⚔️ Kill Aura (урон вокруг)", "KillAura", function(v)
        Settings.KillAura = v
    end)

    CreateSection(p, "Действия")

    CreateButton(p, "📦 Телепорт в Центр Арены", Color3.fromRGB(30, 100, 200), function()
        if RootPart then
            RootPart.CFrame = CFrame.new(0, 5, 0)
            SetStatus("Телепортирован в центр арены!", Color3.fromRGB(100, 200, 255))
        end
    end)

    CreateButton(p, "💀 Убить всех ближних зомби", Color3.fromRGB(160, 0, 0), function()
        local count = 0
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Humanoid") and obj.Parent ~= Character then
                local root = obj.Parent:FindFirstChild("HumanoidRootPart")
                if root then
                    local dist = (RootPart.Position - root.Position).Magnitude
                    if dist < 60 then
                        obj.Health = 0
                        count = count + 1
                    end
                end
            end
        end
        SetStatus("Уничтожено зомби: " .. count, Color3.fromRGB(255, 80, 80))
    end)
end

-- ══════════════════════════════════════
-- ВКЛАДКА: ИГРОК
-- ══════════════════════════════════════
do
    local p = TabContents["Игрок"].Content

    CreateSection(p, "Выживаемость")

    CreateToggle(p, "❤️ Бесконечное HP (God Mode)", "GodMode", function(v)
        Settings.GodMode = v
        if v then
            SetStatus("God Mode АКТИВЕН!", Color3.fromRGB(255, 80, 80))
        end
    end)

    CreateToggle(p, "🚀 Ускорение (Speed Hack)", "SpeedHack", function(v)
        Settings.SpeedHack = v
        Humanoid.WalkSpeed = v and 50 or Settings.WalkSpeed
    end)

    CreateToggle(p, "🌊 NoClip (сквозь стены)", "NoClip", function(v)
        Settings.NoClip = v
    end)

    CreateSection(p, "Телепорт")

    CreateButton(p, "📍 ТП к случайному зомби", Color3.fromRGB(140, 60, 0), function()
        local zombies = {}
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Humanoid") and obj.Parent ~= Character and obj.Health > 0 then
                local root = obj.Parent:FindFirstChild("HumanoidRootPart")
                if root then table.insert(zombies, root) end
            end
        end
        if #zombies > 0 then
            local pick = zombies[math.random(1, #zombies)]
            RootPart.CFrame = pick.CFrame + Vector3.new(0, 5, 5)
            SetStatus("Телепортирован к зомби!", Color3.fromRGB(255, 160, 0))
        else
            SetStatus("Зомби не найдены!", Color3.fromRGB(220, 100, 100))
        end
    end)

    CreateButton(p, "📍 ТП в Лобби (Spawn)", Color3.fromRGB(0, 120, 60), function()
        local spawn = workspace:FindFirstChild("SpawnLocation") or workspace:FindFirstChild("Spawn")
        if spawn then
            RootPart.CFrame = spawn.CFrame + Vector3.new(0, 5, 0)
        else
            RootPart.CFrame = CFrame.new(0, 10, 0)
        end
        SetStatus("Телепортирован в Лобби!", Color3.fromRGB(100, 220, 100))
    end)

    CreateSection(p, "Стат-буст")

    CreateButton(p, "⚡ MAX скорость (WS 100)", Color3.fromRGB(200, 130, 0), function()
        Humanoid.WalkSpeed = 100
        SetStatus("Скорость: 100!", Color3.fromRGB(255, 200, 0))
    end)

    CreateButton(p, "🔄 Сбросить скорость", Color3.fromRGB(60, 60, 80), function()
        Humanoid.WalkSpeed = 16
        Humanoid.JumpPower = 50
        SetStatus("Скорость сброшена.", Color3.fromRGB(180, 180, 180))
    end)

    CreateButton(p, "🦘 MAX прыжок (JP 200)", Color3.fromRGB(0, 100, 180), function()
        Humanoid.JumpPower = 200
        SetStatus("Прыжок: 200!", Color3.fromRGB(100, 180, 255))
    end)
end

-- ══════════════════════════════════════
-- ВКЛАДКА: ВИЗУАЛ (ESP)
-- ══════════════════════════════════════
do
    local p = TabContents["Визуал"].Content
    local ESPBoxes = {}

    CreateSection(p, "ESP / Хайлайт")

    CreateToggle(p, "🔴 Зомби ESP (Billboard)", "ESP", function(v)
        Settings.ESP = v
        if not v then
            for _, bb in pairs(ESPBoxes) do
                if bb and bb.Parent then bb:Destroy() end
            end
            ESPBoxes = {}
        end
        SetStatus(v and "ESP включён!" or "ESP выключен.", v and Color3.fromRGB(100, 220, 100) or Color3.fromRGB(220, 100, 100))
    end)

    CreateButton(p, "🔦 Подсветить всех зомби", Color3.fromRGB(150, 0, 150), function()
        local count = 0
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Humanoid") and obj.Parent ~= Character and obj.Health > 0 then
                local root = obj.Parent:FindFirstChild("HumanoidRootPart")
                if root and not root:FindFirstChild("ZombieESP") then
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "ZombieESP"
                    bb.Size = UDim2.new(0, 80, 0, 30)
                    bb.StudsOffset = Vector3.new(0, 3, 0)
                    bb.AlwaysOnTop = true
                    bb.Parent = root
                    local lbl = Instance.new("TextLabel")
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
                    lbl.BackgroundTransparency = 0.3
                    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                    lbl.TextSize = 11
                    lbl.Font = Enum.Font.GothamBold
                    lbl.Text = "🧟 ZOMBIE"
                    lbl.Parent = bb
                    local lc = Instance.new("UICorner")
                    lc.CornerRadius = UDim.new(0, 4)
                    lc.Parent = lbl
                    table.insert(ESPBoxes, bb)
                    count = count + 1
                end
            end
        end
        SetStatus("ESP: найдено " .. count .. " зомби", Color3.fromRGB(255, 150, 255))
    end)

    CreateButton(p, "🗑 Убрать все ESP метки", Color3.fromRGB(60, 60, 80), function()
        local rem = 0
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == "ZombieESP" then obj:Destroy() rem = rem + 1 end
        end
        ESPBoxes = {}
        SetStatus("Удалено ESP меток: " .. rem, Color3.fromRGB(180, 180, 180))
    end)

    CreateSection(p, "Камера")

    CreateButton(p, "🔭 FOV Max (120)", Color3.fromRGB(0, 80, 160), function()
        game.Workspace.CurrentCamera.FieldOfView = 120
        SetStatus("FOV: 120", Color3.fromRGB(100, 180, 255))
    end)

    CreateButton(p, "🔄 FOV Сброс (70)", Color3.fromRGB(60, 60, 80), function()
        game.Workspace.CurrentCamera.FieldOfView = 70
        SetStatus("FOV сброшен: 70", Color3.fromRGB(180, 180, 180))
    end)
end

-- ══════════════════════════════════════
-- ВКЛАДКА: ПРОЧЕЕ
-- ══════════════════════════════════════
do
    local p = TabContents["Прочее"].Content

    CreateSection(p, "Инфо / Коды")

    CreateButton(p, "📋 Ввести код: zombies", Color3.fromRGB(0, 130, 60), function()
        -- Находим кнопку Shop / Code field
        SetStatus("Код 'zombies' = 2500 кредитов! (введи вручную в Shop)", Color3.fromRGB(100, 255, 150))
    end)

    CreateButton(p, "🔔 Показать кол-во зомби", Color3.fromRGB(100, 60, 0), function()
        local count = 0
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Humanoid") and obj.Parent ~= Character and obj.Health > 0 then
                count = count + 1
            end
        end
        SetStatus("Живых зомби на карте: " .. count, Color3.fromRGB(255, 160, 0))
    end)

    CreateButton(p, "📊 Мой HP / Скорость", Color3.fromRGB(0, 100, 160), function()
        local hp = math.floor(Humanoid.Health)
        local ws = Humanoid.WalkSpeed
        SetStatus("HP: " .. hp .. "  |  WS: " .. ws, Color3.fromRGB(100, 220, 255))
    end)

    CreateSection(p, "Системные")

    CreateButton(p, "🔄 Перезапустить скрипт", Color3.fromRGB(80, 80, 100), function()
        ScreenGui:Destroy()
        SetStatus("Перезапуск...", Color3.fromRGB(255, 255, 100))
    end)

    CreateButton(p, "❌ ЗАКРЫТЬ ХАБ", Color3.fromRGB(180, 0, 0), function()
        local tw = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
        })
        tw:Play()
        tw.Completed:Connect(function() ScreenGui:Destroy() end)
    end)
end

-- ══════════════════════════════════════
-- ЛОГИКА КНОПОК ШАПКИ
-- ══════════════════════════════════════
CloseBtn.MouseButton1Click:Connect(function()
    local tw = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
        Size = UDim2.new(0, 380, 0, 0),
        Position = UDim2.new(0.5, -190, 0.5, 0),
    })
    tw:Play()
    tw.Completed:Connect(function() ScreenGui:Destroy() end)
end)

local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    local tw = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
        Size = minimized and UDim2.new(0, 380, 0, 50) or UDim2.new(0, 380, 0, 480),
    })
    tw:Play()
    MinimizeBtn.Text = minimized and "□" or "—"
end)

-- ══════════════════════════════════════
-- DRAG (перетаскивание окна)
-- ══════════════════════════════════════
do
    local dragging, dragStart, startPos = false, nil, nil
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ══════════════════════════════════════
-- ОСНОВНОЙ LOOP (RunService)
-- ══════════════════════════════════════
RunService.Heartbeat:Connect(function()
    -- Обновляем ссылки на персонажа (на случай смерти/возрождения)
    Character = LocalPlayer.Character
    if not Character then return end
    Humanoid = Character:FindFirstChild("Humanoid")
    RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not Humanoid or not RootPart then return end

    -- God Mode
    if Settings.GodMode and Humanoid.Health < Humanoid.MaxHealth then
        Humanoid.Health = Humanoid.MaxHealth
    end

    -- NoClip
    if Settings.NoClip then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    -- Kill Aura
    if Settings.KillAura then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Humanoid") and obj.Parent ~= Character then
                local root = obj.Parent:FindFirstChild("HumanoidRootPart")
                if root then
                    local dist = (RootPart.Position - root.Position).Magnitude
                    if dist < 30 then
                        obj.Health = 0
                    end
                end
            end
        end
    end

    -- Auto Dodge (убегать от ближайшего зомби)
    if Settings.AutoDodge then
        local nearest, nearDist = nil, math.huge
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Humanoid") and obj.Parent ~= Character and obj.Health > 0 then
                local root = obj.Parent:FindFirstChild("HumanoidRootPart")
                if root then
                    local d = (RootPart.Position - root.Position).Magnitude
                    if d < nearDist then nearDist = d; nearest = root end
                end
            end
        end
        if nearest and nearDist < 15 then
            local dir = (RootPart.Position - nearest.Position).Unit
            RootPart.Velocity = dir * 50
        end
    end

    -- Auto Collect Credits (примерная логика — собирать DropParts)
    if Settings.AutoCollect then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("credit") or obj.Name:lower():find("drop") or obj.Name:lower():find("coin") then
                if obj:IsA("BasePart") then
                    local dist = (RootPart.Position - obj.Position).Magnitude
                    if dist < 50 then
                        RootPart.CFrame = CFrame.new(obj.Position + Vector3.new(0, 3, 0))
                    end
                end
            end
        end
    end
end)

-- ══════════════════════════════════════
-- АНИМАЦИЯ ОТКРЫТИЯ
-- ══════════════════════════════════════
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
local openTw = TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 380, 0, 480),
    Position = UDim2.new(0.5, -190, 0.5, -240),
})
openTw:Play()

SetStatus("Хаб загружен! Survive Zombie Arena 🧟", Color3.fromRGB(100, 220, 100))

print("✅ [ZombieHub] Скрипт загружен успешно!")
