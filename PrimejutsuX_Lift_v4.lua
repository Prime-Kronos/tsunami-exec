-- ================================================
--   Primejtsu X | Lift v4
--   Creator: @Primejtsu
-- ================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local LP               = Players.LocalPlayer

local liftEnabled = false
local liftPart    = nil
local liftConn    = nil
local MAX_HEIGHT  = 7   -- максимум 7 метров вверх
local SPEED       = 8   -- studs/sec (медленно, плавно)

-- ================================================
-- СТОП
-- ================================================
local function stopLift()
    liftEnabled = false
    if liftConn then liftConn:Disconnect(); liftConn = nil end
    if liftPart then liftPart:Destroy();   liftPart = nil end
end

-- ================================================
-- СТАРТ
-- Платформа едет вверх сама.
-- Персонаж просто СТОИТ на ней — физика Roblox
-- сама толкает его вверх через коллизию.
-- Никаких изменений позиции/velocity персонажа.
-- ================================================
local function startLift()
    stopLift()
    liftEnabled = true

    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChild("Humanoid")
    if not root or not hum then return end

    -- Начальная Y платформы (прямо под ногами)
    local startY   = root.Position.Y - 3.2
    local targetY  = startY + MAX_HEIGHT

    -- Создаём платформу
    liftPart              = Instance.new("Part")
    liftPart.Name         = "PX_LiftPlatform"
    liftPart.Size         = Vector3.new(8, 0.6, 8)
    liftPart.Anchored     = false  -- НЕ anchored! Двигаем через velocity
    liftPart.CanCollide   = true
    liftPart.CastShadow   = false
    liftPart.Material     = Enum.Material.Neon
    liftPart.Color        = Color3.fromRGB(0, 180, 255)
    liftPart.Transparency = 0.2
    liftPart.CFrame       = CFrame.new(root.Position.X, startY, root.Position.Z)
    liftPart.Parent       = workspace

    -- Чтоб платформа не вращалась
    local bg          = Instance.new("BodyAngularVelocity", liftPart)
    bg.AngularVelocity = Vector3.new(0, 0, 0)
    bg.MaxTorque       = Vector3.new(1e6, 1e6, 1e6)

    -- Двигаем через BodyVelocity — плавно вверх
    local bv        = Instance.new("BodyVelocity", liftPart)
    bv.Velocity     = Vector3.new(0, SPEED, 0)
    bv.MaxForce     = Vector3.new(0, 1e6, 0)

    -- Обводка
    local sel               = Instance.new("SelectionBox", liftPart)
    sel.Adornee             = liftPart
    sel.Color3              = Color3.fromRGB(0, 220, 255)
    sel.LineThickness       = 0.05
    sel.SurfaceTransparency = 1

    -- Следим за высотой — останавливаем на MAX_HEIGHT
    liftConn = RunService.Heartbeat:Connect(function()
        if not liftEnabled then return end
        if not liftPart or not liftPart.Parent then stopLift(); return end

        -- Достигли максимума — останавливаем
        if liftPart.Position.Y >= targetY then
            bv.Velocity  = Vector3.new(0, 0, 0)
            bv.MaxForce  = Vector3.new(0, 1e9, 0)  -- держим на месте
            bv.Velocity  = Vector3.new(0, 0, 0)
        end

        -- Держим платформу по X/Z под персонажем чтоб не уплыла
        local r = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if r then
            liftPart.CFrame = CFrame.new(
                r.Position.X,
                liftPart.Position.Y,
                r.Position.Z
            )
            bv.Velocity = liftPart.Position.Y < targetY
                and Vector3.new(0, SPEED, 0)
                or  Vector3.new(0, 0, 0)
        end
    end)
end

-- ================================================
-- GUI
-- ================================================
local old = LP.PlayerGui:FindFirstChild("PX_LiftGui")
if old then old:Destroy() end

local Gui = Instance.new("ScreenGui")
Gui.Name           = "PX_LiftGui"
Gui.ResetOnSpawn   = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent         = LP.PlayerGui

local Frame = Instance.new("Frame", Gui)
Frame.Size             = UDim2.new(0, 210, 0, 110)
Frame.Position         = UDim2.new(0.5, -105, 0.72, 0)
Frame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
Frame.BorderSizePixel  = 0
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke", Frame)
stroke.Color        = Color3.fromRGB(0, 160, 255)
stroke.Thickness    = 1.5
stroke.Transparency = 0.25

-- Тайтл
local Title = Instance.new("Frame", Frame)
Title.Size             = UDim2.new(1, 0, 0, 34)
Title.BackgroundColor3 = Color3.fromRGB(0, 130, 200)
Title.BorderSizePixel  = 0
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 12)

local titleFix = Instance.new("Frame", Title)
titleFix.Size             = UDim2.new(1, 0, 0.5, 0)
titleFix.Position         = UDim2.new(0, 0, 0.5, 0)
titleFix.BackgroundColor3 = Color3.fromRGB(0, 130, 200)
titleFix.BorderSizePixel  = 0

local TitleLbl = Instance.new("TextLabel", Title)
TitleLbl.Size                 = UDim2.new(1, -12, 1, 0)
TitleLbl.Position             = UDim2.new(0, 12, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.TextColor3           = Color3.fromRGB(255, 255, 255)
TitleLbl.TextSize             = 13
TitleLbl.Font                 = Enum.Font.GothamBold
TitleLbl.Text                 = "Primejtsu X | Lift"
TitleLbl.TextXAlignment       = Enum.TextXAlignment.Left

-- Кнопка
local Btn = Instance.new("TextButton", Frame)
Btn.Size             = UDim2.new(1, -20, 0, 38)
Btn.Position         = UDim2.new(0, 10, 0, 44)
Btn.BackgroundColor3 = Color3.fromRGB(0, 140, 210)
Btn.BorderSizePixel  = 0
Btn.TextColor3       = Color3.fromRGB(255, 255, 255)
Btn.TextSize         = 14
Btn.Font             = Enum.Font.GothamBold
Btn.Text             = "Lift  OFF"
Btn.AutoButtonColor  = false
Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

-- Статус
local Status = Instance.new("TextLabel", Frame)
Status.Size                 = UDim2.new(1, -20, 0, 18)
Status.Position             = UDim2.new(0, 10, 0, 88)
Status.BackgroundTransparency = 1
Status.TextColor3           = Color3.fromRGB(100, 100, 130)
Status.TextSize             = 11
Status.Font                 = Enum.Font.Gotham
Status.Text                 = "Max height: " .. MAX_HEIGHT .. " studs"
Status.TextXAlignment       = Enum.TextXAlignment.Left

Btn.MouseButton1Click:Connect(function()
    TweenService:Create(Btn, TweenInfo.new(0.07), { Size = UDim2.new(1,-26,0,35) }):Play()
    task.wait(0.07)
    TweenService:Create(Btn, TweenInfo.new(0.07), { Size = UDim2.new(1,-20,0,38) }):Play()

    if not liftEnabled then
        startLift()
        Btn.BackgroundColor3 = Color3.fromRGB(0, 200, 90)
        Btn.Text             = "Lift  ON"
        Status.Text          = "Rising... max " .. MAX_HEIGHT .. " studs"
        Status.TextColor3    = Color3.fromRGB(100, 230, 130)
    else
        stopLift()
        Btn.BackgroundColor3 = Color3.fromRGB(0, 140, 210)
        Btn.Text             = "Lift  OFF"
        Status.Text          = "Max height: " .. MAX_HEIGHT .. " studs"
        Status.TextColor3    = Color3.fromRGB(100, 100, 130)
    end
end)

-- ================================================
-- DRAGGABLE
-- ================================================
local dragging, dragStart, startPos = false, nil, nil

Title.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        dragging  = true
        dragStart = inp.Position
        startPos  = Frame.Position
    end
end)

UserInputService.InputChanged:Connect(function(inp)
    if not dragging then return end
    if inp.UserInputType == Enum.UserInputType.MouseMovement
    or inp.UserInputType == Enum.UserInputType.Touch then
        local d = inp.Position - dragStart
        Frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

LP.CharacterAdded:Connect(function()
    stopLift()
    if liftEnabled then
        task.wait(1.5)
        startLift()
    end
end)

print("[Primejtsu X] Lift v4 Loaded!")
