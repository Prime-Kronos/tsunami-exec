-- ================================================
--   Primejtsu X | Steal a Brainrot
--   Lift Platform v1.0
--   Creator: @Primejtsu
-- ================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local LP               = Players.LocalPlayer
local Mouse            = LP:GetMouse()

-- ================================================
-- ПЕРЕМЕННЫЕ
-- ================================================
local liftEnabled  = false
local liftPart     = nil
local liftConn     = nil
local LIFT_SPEED   = 17  -- studs/sec вверх

-- ================================================
-- СОЗДАЁМ ПЛАТФОРМУ
-- ================================================
local function createPlatform()
    local char   = LP.Character
    if not char  then return nil end
    local root   = char:FindFirstChild("HumanoidRootPart")
    if not root  then return nil end

    local part = Instance.new("Part")
    part.Name          = "LiftPlatform"
    part.Size          = Vector3.new(6, 0.4, 6)  -- квадрат под ногами
    part.Anchored      = true
    part.CanCollide    = true
    part.CastShadow    = false
    part.Material      = Enum.Material.Neon
    part.Color         = Color3.fromRGB(0, 180, 255)
    part.Transparency  = 0.25

    -- Ставим прямо под ноги
    local footPos = root.Position - Vector3.new(0, 3.2, 0)
    part.CFrame   = CFrame.new(footPos)
    part.Parent   = workspace

    -- Красивый outline (SelectionBox)
    local sel = Instance.new("SelectionBox")
    sel.Adornee      = part
    sel.Color3       = Color3.fromRGB(0, 220, 255)
    sel.LineThickness = 0.04
    sel.SurfaceTransparency = 1
    sel.Parent       = part

    return part
end

-- ================================================
-- NO FALL DAMAGE ПОКА ЛИФТ АКТИВЕН
-- ================================================
local function setNoFallDamage(on)
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    if on then
        -- Блокируем состояние свободного падения
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    else
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
    end
end

-- ================================================
-- УДАЛЯЕМ ПЛАТФОРМУ
-- ================================================
local function destroyPlatform()
    if liftConn then liftConn:Disconnect(); liftConn = nil end
    if liftPart then liftPart:Destroy();   liftPart = nil end
    setNoFallDamage(false)
end

-- ================================================
-- ЗАПУСКАЕМ ЛИФТ
-- ================================================
local function startLift()
    destroyPlatform()
    liftPart = createPlatform()
    if not liftPart then return end

    -- Выключаем урон от падения
    setNoFallDamage(true)

    liftConn = RunService.Heartbeat:Connect(function(dt)
        if not liftEnabled then return end
        if not liftPart or not liftPart.Parent then
            liftConn:Disconnect(); liftConn = nil; return
        end

        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum  = char:FindFirstChild("Humanoid")
        if not root or not hum then return end

        -- Двигаем платформу вверх
        local rise = LIFT_SPEED * dt
        liftPart.CFrame = liftPart.CFrame + Vector3.new(0, rise, 0)

        -- Держим игрока строго на платформе
        local platTop = liftPart.Position.Y + (liftPart.Size.Y / 2) + 3.1
        local yaw     = select(2, root.CFrame:ToEulerAnglesYXZ())
        root.CFrame   = CFrame.new(root.Position.X, platTop, root.Position.Z)
                      * CFrame.Angles(0, yaw, 0)

        -- Не даём умереть от высоты
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    end)
end

-- ================================================
-- МИНИ GUI (draggable)
-- ================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name             = "PrimejutsuLift"
ScreenGui.ResetOnSpawn     = false
ScreenGui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent           = LP.PlayerGui

-- Главный фрейм (окно)
local MainFrame = Instance.new("Frame")
MainFrame.Name              = "MainFrame"
MainFrame.Size              = UDim2.new(0, 200, 0, 110)
MainFrame.Position          = UDim2.new(0.5, -100, 0.75, 0)
MainFrame.BackgroundColor3  = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel   = 0
MainFrame.ClipsDescendants  = true
MainFrame.Parent            = ScreenGui

-- Скруглённые углы
local corner = Instance.new("UICorner", MainFrame)
corner.CornerRadius = UDim.new(0, 10)

-- Обводка
local stroke = Instance.new("UIStroke", MainFrame)
stroke.Color     = Color3.fromRGB(0, 180, 255)
stroke.Thickness = 1.5
stroke.Transparency = 0.3

-- Заголовок (drag bar)
local TitleBar = Instance.new("Frame")
TitleBar.Name             = "TitleBar"
TitleBar.Size             = UDim2.new(1, 0, 0, 32)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 140, 210)
TitleBar.BorderSizePixel  = 0
TitleBar.Parent           = MainFrame

local titleCorner = Instance.new("UICorner", TitleBar)
titleCorner.CornerRadius = UDim.new(0, 10)

-- Нижняя часть тайтла чтоб не было скруглений снизу
local titleFix = Instance.new("Frame")
titleFix.Size             = UDim2.new(1, 0, 0.5, 0)
titleFix.Position         = UDim2.new(0, 0, 0.5, 0)
titleFix.BackgroundColor3 = Color3.fromRGB(0, 140, 210)
titleFix.BorderSizePixel  = 0
titleFix.Parent           = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size               = UDim2.new(1, -10, 1, 0)
TitleLabel.Position           = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3         = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize           = 13
TitleLabel.Font               = Enum.Font.GothamBold
TitleLabel.Text               = "Primejtsu X | Lift"
TitleLabel.TextXAlignment     = Enum.TextXAlignment.Left
TitleLabel.Parent             = TitleBar

-- Кнопка включения лифта
local LiftButton = Instance.new("TextButton")
LiftButton.Name               = "LiftButton"
LiftButton.Size               = UDim2.new(1, -20, 0, 36)
LiftButton.Position           = UDim2.new(0, 10, 0, 42)
LiftButton.BackgroundColor3   = Color3.fromRGB(0, 160, 230)
LiftButton.BorderSizePixel    = 0
LiftButton.TextColor3         = Color3.fromRGB(255, 255, 255)
LiftButton.TextSize           = 14
LiftButton.Font               = Enum.Font.GothamBold
LiftButton.Text               = "Lift  OFF"
LiftButton.AutoButtonColor    = false
LiftButton.Parent             = MainFrame

local btnCorner = Instance.new("UICorner", LiftButton)
btnCorner.CornerRadius = UDim.new(0, 8)

-- Статус лейбл
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size                  = UDim2.new(1, -20, 0, 20)
StatusLabel.Position              = UDim2.new(0, 10, 0, 84)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3            = Color3.fromRGB(120, 120, 140)
StatusLabel.TextSize              = 11
StatusLabel.Font                  = Enum.Font.Gotham
StatusLabel.Text                  = "Speed: 22 studs/sec"
StatusLabel.TextXAlignment        = Enum.TextXAlignment.Left
StatusLabel.Parent                = MainFrame

-- ================================================
-- КНОПКА ЛОГИКА
-- ================================================
local function updateButton()
    if liftEnabled then
        LiftButton.Text           = "Lift  ON"
        LiftButton.BackgroundColor3 = Color3.fromRGB(0, 210, 100)
        StatusLabel.Text          = "Rising at " .. LIFT_SPEED .. " studs/sec"
        StatusLabel.TextColor3    = Color3.fromRGB(0, 210, 100)
    else
        LiftButton.Text           = "Lift  OFF"
        LiftButton.BackgroundColor3 = Color3.fromRGB(0, 160, 230)
        StatusLabel.Text          = "Speed: " .. LIFT_SPEED .. " studs/sec"
        StatusLabel.TextColor3    = Color3.fromRGB(120, 120, 140)
    end
end

LiftButton.MouseButton1Click:Connect(function()
    liftEnabled = not liftEnabled

    -- Анимация нажатия
    TweenService:Create(LiftButton, TweenInfo.new(0.08), {
        Size = UDim2.new(1, -24, 0, 33)
    }):Play()
    task.wait(0.08)
    TweenService:Create(LiftButton, TweenInfo.new(0.08), {
        Size = UDim2.new(1, -20, 0, 36)
    }):Play()

    if liftEnabled then
        startLift()
    else
        destroyPlatform()
    end

    updateButton()
end)

-- ================================================
-- DRAGGABLE (перетаскивание GUI)
-- ================================================
local dragging    = false
local dragStart   = nil
local startPos    = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging  = true
        dragStart = input.Position
        startPos  = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement or
        input.UserInputType == Enum.UserInputType.Touch
    ) then
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
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ================================================
-- ЧИСТИМ при смерти / респолне
-- ================================================
LP.CharacterAdded:Connect(function()
    if liftEnabled then
        task.wait(1)
        startLift()
    end
end)

print("[Primejtsu X] Lift v1.0 Loaded!")
