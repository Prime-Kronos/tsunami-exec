-- ================================================
--   Primejtsu X | Lift
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
local bodyPos     = nil
local SPEED       = 10

-- ================================================
-- ЛИФТ
-- ================================================
local function stopLift()
    liftEnabled = false

    if liftConn then liftConn:Disconnect(); liftConn = nil end

    -- Убираем BodyPosition с персонажа
    if bodyPos then bodyPos:Destroy(); bodyPos = nil end

    -- Убираем платформу
    if liftPart then liftPart:Destroy(); liftPart = nil end

    -- Восстанавливаем гуманоида
    local char = LP.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
        end
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            local old = root:FindFirstChild("LiftBodyPos")
            if old then old:Destroy() end
        end
    end
end

local function startLift()
    stopLift()
    liftEnabled = true

    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChild("Humanoid")
    if not root or not hum then return end

    -- Создаём платформу под ногами
    liftPart              = Instance.new("Part")
    liftPart.Name         = "PX_Lift"
    liftPart.Size         = Vector3.new(6, 0.5, 6)
    liftPart.Anchored     = true
    liftPart.CanCollide   = true
    liftPart.CastShadow   = false
    liftPart.Material     = Enum.Material.Neon
    liftPart.Color        = Color3.fromRGB(0, 180, 255)
    liftPart.Transparency = 0.2
    liftPart.CFrame       = CFrame.new(root.Position - Vector3.new(0, 3.5, 0))
    liftPart.Parent       = workspace

    local sel                   = Instance.new("SelectionBox", liftPart)
    sel.Adornee                 = liftPart
    sel.Color3                  = Color3.fromRGB(0, 220, 255)
    sel.LineThickness           = 0.05
    sel.SurfaceTransparency     = 1

    -- BodyPosition на персонаже — он сам едет вверх плавно
    -- это НЕ телепорт, поэтому Roblox не считает это падением
    bodyPos          = Instance.new("BodyPosition")
    bodyPos.Name     = "LiftBodyPos"
    bodyPos.MaxForce = Vector3.new(0, 1e6, 0)  -- только по Y
    bodyPos.P        = 1e4
    bodyPos.D        = 500
    bodyPos.Position = root.Position
    bodyPos.Parent   = root

    -- Глушим падение
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)

    local targetY = root.Position.Y

    liftConn = RunService.Heartbeat:Connect(function(dt)
        if not liftEnabled then return end

        local c = LP.Character
        if not c then stopLift(); return end
        local r = c:FindFirstChild("HumanoidRootPart")
        local h = c:FindFirstChild("Humanoid")
        if not r or not h then stopLift(); return end

        -- Двигаем цель вверх
        targetY = targetY + SPEED * dt

        -- BodyPosition тянет персонажа вверх без телепорта
        bodyPos.Position = Vector3.new(r.Position.X, targetY, r.Position.Z)

        -- Двигаем платформу вместе с персонажем
        liftPart.CFrame = CFrame.new(r.Position.X, targetY - 3.5, r.Position.Z)

        -- Постоянно глушим fall states
        h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        h:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
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
Status.Text                 = "Speed: " .. SPEED .. " studs/sec"
Status.TextXAlignment       = Enum.TextXAlignment.Left

-- Логика кнопки
Btn.MouseButton1Click:Connect(function()
    -- Анимация
    TweenService:Create(Btn, TweenInfo.new(0.07), { Size = UDim2.new(1,-26,0,35) }):Play()
    task.wait(0.07)
    TweenService:Create(Btn, TweenInfo.new(0.07), { Size = UDim2.new(1,-20,0,38) }):Play()

    if not liftEnabled then
        startLift()
        Btn.BackgroundColor3 = Color3.fromRGB(0, 200, 90)
        Btn.Text             = "Lift  ON"
        Status.Text          = "Rising at " .. SPEED .. " studs/sec"
        Status.TextColor3    = Color3.fromRGB(100, 230, 130)
    else
        stopLift()
        Btn.BackgroundColor3 = Color3.fromRGB(0, 140, 210)
        Btn.Text             = "Lift  OFF"
        Status.Text          = "Speed: " .. SPEED .. " studs/sec"
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

-- При респавне
LP.CharacterAdded:Connect(function()
    if liftEnabled then
        task.wait(1.5)
        startLift()
    end
end)

print("[Primejtsu X] Lift Loaded!")
