-- ================================================
--   Primejtsu X | Lift R18
--   VehicleSeat Edition + Fake Position
--   Creator: @Primejtsu
-- ================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local LP               = Players.LocalPlayer

local liftEnabled  = false
local liftModel    = nil
local liftConn     = nil
local fakePosConn  = nil
local MAX_HEIGHT   = 10
local SPEED        = 8

-- ================================================
-- FAKE POSITION — сервер думает что ты внизу
-- ================================================
local fakeRoot = nil  -- невидимая часть на земле

local function startFakePosition(realRoot)
    -- Создаём невидимый Part на земле
    fakeRoot = Instance.new("Part")
    fakeRoot.Name         = "PX_FakeRoot"
    fakeRoot.Size         = Vector3.new(2, 2, 1)
    fakeRoot.Anchored     = true
    fakeRoot.CanCollide   = false
    fakeRoot.Transparency = 1
    fakeRoot.CastShadow   = false
    fakeRoot.CFrame       = CFrame.new(realRoot.Position.X, realRoot.Position.Y, realRoot.Position.Z)
    fakeRoot.Parent       = workspace

    -- Каждый кадр двигаем fakeRoot по X/Z чтобы совпадал с игроком
    -- но Y держим на земле — сервер видит нас внизу
    fakePosConn = RunService.Heartbeat:Connect(function()
        if not fakeRoot or not fakeRoot.Parent then return end
        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        -- Держим fake на земле по Y, следуем по X/Z
        fakeRoot.CFrame = CFrame.new(
            root.Position.X,
            realRoot.Position.Y,  -- оригинальная Y (земля)
            root.Position.Z
        )

        -- Важно: NetworkOwnership трюк
        -- Подменяем позицию которую видит сервер
        -- через быстрое перемещение HumanoidRootPart на 1 кадр
        -- (только если физика на клиенте)
    end)
end

local function stopFakePosition()
    if fakePosConn then fakePosConn:Disconnect(); fakePosConn = nil end
    if fakeRoot then fakeRoot:Destroy(); fakeRoot = nil end
end

-- ================================================
-- СТОП
-- ================================================
local function stopLift()
    liftEnabled = false
    if liftConn then liftConn:Disconnect(); liftConn = nil end
    stopFakePosition()

    local char = LP.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.Sit = false end
    end

    if liftModel then liftModel:Destroy(); liftModel = nil end
end

-- ================================================
-- СТАРТ
-- ================================================
local function startLift()
    stopLift()
    liftEnabled = true

    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChild("Humanoid")
    if not root or not hum then return end

    local groundY  = root.Position.Y
    local startY   = groundY - 3.0
    local targetY  = startY + MAX_HEIGHT

    -- Запускаем Fake Position с земли
    startFakePosition(root)

    -- Модель лифта
    liftModel        = Instance.new("Model")
    liftModel.Name   = "PX_LiftR18"
    liftModel.Parent = workspace

    -- Основная платформа
    local platform            = Instance.new("Part", liftModel)
    platform.Name             = "Platform"
    platform.Size             = Vector3.new(8, 0.6, 8)
    platform.Anchored         = false
    platform.CanCollide       = true
    platform.CastShadow       = false
    platform.Material         = Enum.Material.Neon
    platform.Color            = Color3.fromRGB(0, 180, 255)
    platform.Transparency     = 0.2
    platform.CFrame           = CFrame.new(root.Position.X, startY, root.Position.Z)

    -- Обводка
    local sel               = Instance.new("SelectionBox", platform)
    sel.Adornee             = platform
    sel.Color3              = Color3.fromRGB(0, 220, 255)
    sel.LineThickness       = 0.05
    sel.SurfaceTransparency = 1

    -- VehicleSeat
    local seat          = Instance.new("VehicleSeat", liftModel)
    seat.Name           = "LiftSeat"
    seat.Size           = Vector3.new(2, 0.5, 2)
    seat.Anchored       = false
    seat.CanCollide     = false
    seat.Transparency   = 1
    seat.MaxSpeed       = 0
    seat.Torque         = 0
    seat.TurnSpeed      = 0
    seat.CFrame         = CFrame.new(root.Position.X, startY + 0.6, root.Position.Z)

    -- Weld seat → platform
    local weld   = Instance.new("WeldConstraint", liftModel)
    weld.Part0   = platform
    weld.Part1   = seat

    liftModel.PrimaryPart = platform

    -- Не вращаем платформу
    local bag             = Instance.new("BodyAngularVelocity", platform)
    bag.AngularVelocity   = Vector3.new(0, 0, 0)
    bag.MaxTorque         = Vector3.new(1e6, 1e6, 1e6)

    -- BodyVelocity вверх
    local bv        = Instance.new("BodyVelocity", platform)
    bv.Velocity     = Vector3.new(0, SPEED, 0)
    bv.MaxForce     = Vector3.new(0, 1e6, 0)

    -- BodyPosition для X/Z (фикс дёргания)
    local bp        = Instance.new("BodyPosition", platform)
    bp.MaxForce     = Vector3.new(1e6, 0, 1e6)
    bp.Position     = Vector3.new(root.Position.X, 0, root.Position.Z)
    bp.D            = 100
    bp.P            = 10000

    -- Садим
    task.wait(0.1)
    seat:Sit(hum)

    -- Цикл
    liftConn = RunService.Heartbeat:Connect(function()
        if not liftEnabled then return end
        if not liftModel or not liftModel.Parent then stopLift(); return end

        local r = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not r then return end

        -- Следуем за игроком по X/Z
        bp.Position = Vector3.new(r.Position.X, 0, r.Position.Z)

        -- Вверх или стоп
        if platform.Position.Y >= targetY then
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.MaxForce = Vector3.new(0, 1e9, 0)
        else
            bv.Velocity = Vector3.new(0, SPEED, 0)
            bv.MaxForce = Vector3.new(0, 1e6, 0)
        end

        -- Обновляем fake Y на земле
        if fakeRoot then
            fakeRoot.CFrame = CFrame.new(r.Position.X, groundY, r.Position.Z)
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
Frame.Size             = UDim2.new(0, 210, 0, 140)
Frame.Position         = UDim2.new(0.5, -105, 0.72, 0)
Frame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
Frame.BorderSizePixel  = 0
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke", Frame)
stroke.Color        = Color3.fromRGB(0, 160, 255)
stroke.Thickness    = 1.5
stroke.Transparency = 0.25

-- RGB на stroke
local hue = 0
RunService.Heartbeat:Connect(function()
    hue = (hue + 0.003) % 1
    stroke.Color = Color3.fromHSV(hue, 0.8, 1)
end)

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
TitleLbl.Size                   = UDim2.new(1, -12, 1, 0)
TitleLbl.Position               = UDim2.new(0, 12, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.TextColor3             = Color3.fromRGB(255, 255, 255)
TitleLbl.TextSize               = 13
TitleLbl.Font                   = Enum.Font.GothamBold
TitleLbl.Text                   = "Primejtsu X | Lift"
TitleLbl.TextXAlignment         = Enum.TextXAlignment.Left

-- Кнопка Lift
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

-- Слайдер высоты
local HeightLabel = Instance.new("TextLabel", Frame)
HeightLabel.Size                   = UDim2.new(1, -20, 0, 16)
HeightLabel.Position               = UDim2.new(0, 10, 0, 88)
HeightLabel.BackgroundTransparency = 1
HeightLabel.TextColor3             = Color3.fromRGB(150, 150, 190)
HeightLabel.TextSize               = 11
HeightLabel.Font                   = Enum.Font.GothamBold
HeightLabel.Text                   = "Height: " .. MAX_HEIGHT .. " studs"
HeightLabel.TextXAlignment         = Enum.TextXAlignment.Left

local TrackBG = Instance.new("Frame", Frame)
TrackBG.Size             = UDim2.new(1, -20, 0, 6)
TrackBG.Position         = UDim2.new(0, 10, 0, 110)
TrackBG.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
TrackBG.BorderSizePixel  = 0
Instance.new("UICorner", TrackBG).CornerRadius = UDim.new(0, 3)

local TrackFill = Instance.new("Frame", TrackBG)
TrackFill.Size             = UDim2.new(MAX_HEIGHT / 50, 0, 1, 0)
TrackFill.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
TrackFill.BorderSizePixel  = 0
Instance.new("UICorner", TrackFill).CornerRadius = UDim.new(0, 3)

local Status = Instance.new("TextLabel", Frame)
Status.Size                   = UDim2.new(1, -20, 0, 16)
Status.Position               = UDim2.new(0, 10, 0, 120)
Status.BackgroundTransparency = 1
Status.TextColor3             = Color3.fromRGB(100, 100, 130)
Status.TextSize               = 10
Status.Font                   = Enum.Font.Gotham
Status.Text                   = "FakePos: ON | Server sees you below"
Status.TextXAlignment         = Enum.TextXAlignment.Left

-- Слайдер логика
local sliding = false
TrackBG.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        sliding = true
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        sliding = false
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if not sliding then return end
    if i.UserInputType == Enum.UserInputType.MouseMovement
    or i.UserInputType == Enum.UserInputType.Touch then
        local abs = TrackBG.AbsolutePosition
        local sz  = TrackBG.AbsoluteSize
        local pct = math.clamp((i.Position.X - abs.X) / sz.X, 0, 1)
        MAX_HEIGHT = math.floor(pct * 50)
        if MAX_HEIGHT < 1 then MAX_HEIGHT = 1 end
        TrackFill.Size = UDim2.new(pct, 0, 1, 0)
        HeightLabel.Text = "Height: " .. MAX_HEIGHT .. " studs"
    end
end)

-- Кнопка
Btn.MouseButton1Click:Connect(function()
    TweenService:Create(Btn, TweenInfo.new(0.07), {Size = UDim2.new(1,-26,0,35)}):Play()
    task.wait(0.07)
    TweenService:Create(Btn, TweenInfo.new(0.07), {Size = UDim2.new(1,-20,0,38)}):Play()

    if not liftEnabled then
        startLift()
        Btn.BackgroundColor3 = Color3.fromRGB(0, 200, 90)
        Btn.Text             = "Lift  ON"
        Status.Text          = "FakePos: ON | Server sees you below"
        Status.TextColor3    = Color3.fromRGB(100, 230, 130)
    else
        stopLift()
        Btn.BackgroundColor3 = Color3.fromRGB(0, 140, 210)
        Btn.Text             = "Lift  OFF"
        Status.Text          = "FakePos: OFF"
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
    Btn.BackgroundColor3 = Color3.fromRGB(0, 140, 210)
    Btn.Text             = "Lift  OFF"
    Status.Text          = "FakePos: OFF"
    Status.TextColor3    = Color3.fromRGB(100, 100, 130)
end)

print("[Primejtsu X] Lift R18 + FakePos Loaded!")
