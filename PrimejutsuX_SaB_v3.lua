-- ================================================
--   Primejtsu X | Steal a Brainrot
--   Tools v3.0 — Lift + JumpBoost + Speed
--   Creator: @Primejtsu
-- ================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local LP               = Players.LocalPlayer

-- ================================================
-- СОСТОЯНИЯ
-- ================================================
local liftEnabled  = false
local jumpEnabled  = false
local speedEnabled = false

local liftPart     = nil
local liftConn     = nil

local LIFT_SPEED   = 10   -- studs/sec
local JUMP_POWER   = 120  -- сила прыжка (дефолт 50)
local SPEED_VALUE  = 35   -- скорость ходьбы

-- ================================================
-- УТИЛИТЫ
-- ================================================
local function getChar()
    return LP.Character
end

local function getRoot()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local c = getChar()
    return c and c:FindFirstChild("Humanoid")
end

-- ================================================
-- ЛИФТ — создание платформы
-- ================================================
local function createPlatform()
    local root = getRoot()
    if not root then return nil end

    -- Удаляем старую если есть
    local old = workspace:FindFirstChild("PX_LiftPlatform")
    if old then old:Destroy() end

    local part        = Instance.new("Part")
    part.Name         = "PX_LiftPlatform"
    part.Size         = Vector3.new(6, 0.5, 6)
    part.Anchored     = true
    part.CanCollide   = true
    part.CastShadow   = false
    part.Material     = Enum.Material.Neon
    part.Color        = Color3.fromRGB(0, 180, 255)
    part.Transparency = 0.2
    -- Ставим ПРЯМО под ноги
    part.CFrame       = CFrame.new(root.Position - Vector3.new(0, 3.5, 0))
    part.Parent       = workspace

    -- Обводка
    local sel             = Instance.new("SelectionBox")
    sel.Adornee           = part
    sel.Color3            = Color3.fromRGB(0, 220, 255)
    sel.LineThickness     = 0.05
    sel.SurfaceTransparency = 1
    sel.Parent            = part

    return part
end

-- ================================================
-- ЛИФТ — запуск
-- ================================================
local function startLift()
    if liftConn then liftConn:Disconnect(); liftConn = nil end
    if liftPart then liftPart:Destroy();   liftPart = nil end

    liftPart = createPlatform()
    if not liftPart then return end

    liftConn = RunService.Heartbeat:Connect(function(dt)
        if not liftEnabled then return end

        local root = getRoot()
        local hum  = getHum()
        if not root or not hum then return end
        if not liftPart or not liftPart.Parent then return end

        -- Двигаем платформу вверх
        liftPart.CFrame = liftPart.CFrame + Vector3.new(0, LIFT_SPEED * dt, 0)

        -- Держим игрока на платформе
        local topY = liftPart.Position.Y + liftPart.Size.Y / 2 + 3.0
        local _, yaw, _ = root.CFrame:ToEulerAnglesYXZ()
        root.CFrame = CFrame.new(root.Position.X, topY, root.Position.Z)
                    * CFrame.Angles(0, yaw, 0)

        -- Каждый кадр глушим падение
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)

        -- Не даём Roblox убить от высоты (MaxSlopeAngle trick)
        hum.AutoRotate = true
    end)
end

-- ================================================
-- ЛИФТ — стоп
-- ================================================
local function stopLift()
    if liftConn then liftConn:Disconnect(); liftConn = nil end
    if liftPart then liftPart:Destroy();   liftPart = nil end

    -- Восстанавливаем состояния
    local hum = getHum()
    if hum then
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
    end
end

-- ================================================
-- JUMP BOOST
-- ================================================
RunService.Heartbeat:Connect(function()
    local hum = getHum()
    if not hum then return end

    if jumpEnabled then
        hum.JumpPower  = JUMP_POWER
        hum.JumpHeight = 0  -- отключаем новую систему, юзаем JumpPower
    else
        -- Восстанавливаем дефолт только если мы его меняли
        if hum.JumpPower ~= 50 and not jumpEnabled then
            hum.JumpPower = 50
        end
    end

    -- Speed
    if speedEnabled then
        hum.WalkSpeed = SPEED_VALUE
    else
        if hum.WalkSpeed ~= 16 then
            hum.WalkSpeed = 16
        end
    end
end)

-- ================================================
-- Респавн — восстанавливаем всё
-- ================================================
LP.CharacterAdded:Connect(function()
    task.wait(1)
    if liftEnabled then startLift() end
end)

-- ================================================
-- GUI
-- ================================================
-- Удаляем старый GUI если есть
local oldGui = LP.PlayerGui:FindFirstChild("PrimejutsuTools")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "PrimejutsuTools"
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent         = LP.PlayerGui

-- ================================================
-- ГЛАВНЫЙ ФРЕЙМ
-- ================================================
local W, H = 210, 210  -- ширина, высота окна

local MainFrame = Instance.new("Frame")
MainFrame.Name             = "Main"
MainFrame.Size             = UDim2.new(0, W, 0, H)
MainFrame.Position         = UDim2.new(0.5, -W/2, 0.7, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MainFrame.BorderSizePixel  = 0
MainFrame.ClipsDescendants = false
MainFrame.Parent           = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color       = Color3.fromRGB(0, 160, 255)
mainStroke.Thickness   = 1.5
mainStroke.Transparency = 0.25

-- ================================================
-- ТАЙТЛ БАР (draggable)
-- ================================================
local TitleBar = Instance.new("Frame")
TitleBar.Name             = "TitleBar"
TitleBar.Size             = UDim2.new(1, 0, 0, 34)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 130, 200)
TitleBar.BorderSizePixel  = 0
TitleBar.Parent           = MainFrame

local tc = Instance.new("UICorner", TitleBar)
tc.CornerRadius = UDim.new(0, 12)

-- Фикс нижних углов тайтла
local fix = Instance.new("Frame", TitleBar)
fix.Size             = UDim2.new(1, 0, 0.5, 0)
fix.Position         = UDim2.new(0, 0, 0.5, 0)
fix.BackgroundColor3 = Color3.fromRGB(0, 130, 200)
fix.BorderSizePixel  = 0

local TitleLbl = Instance.new("TextLabel", TitleBar)
TitleLbl.Size                 = UDim2.new(1, -12, 1, 0)
TitleLbl.Position             = UDim2.new(0, 12, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.TextColor3           = Color3.fromRGB(255, 255, 255)
TitleLbl.TextSize             = 13
TitleLbl.Font                 = Enum.Font.GothamBold
TitleLbl.Text                 = "Primejtsu X | Tools"
TitleLbl.TextXAlignment       = Enum.TextXAlignment.Left

-- ================================================
-- ХЕЛПЕР: создать кнопку
-- ================================================
local function makeButton(parent, yOffset, labelText, colorOff)
    local btn = Instance.new("TextButton", parent)
    btn.Size             = UDim2.new(1, -20, 0, 38)
    btn.Position         = UDim2.new(0, 10, 0, yOffset)
    btn.BackgroundColor3 = colorOff
    btn.BorderSizePixel  = 0
    btn.TextColor3       = Color3.fromRGB(255, 255, 255)
    btn.TextSize         = 13
    btn.Font             = Enum.Font.GothamBold
    btn.Text             = labelText .. "  OFF"
    btn.AutoButtonColor  = false

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local sub = Instance.new("TextLabel", btn)
    sub.Size                 = UDim2.new(1, -10, 0, 14)
    sub.Position             = UDim2.new(0, 8, 1, -16)
    sub.BackgroundTransparency = 1
    sub.TextColor3           = Color3.fromRGB(200, 200, 220)
    sub.TextSize             = 10
    sub.Font                 = Enum.Font.Gotham
    sub.Text                 = ""
    sub.TextXAlignment       = Enum.TextXAlignment.Left

    return btn, sub
end

local COLOR_OFF_BLUE  = Color3.fromRGB(0, 140, 210)
local COLOR_OFF_PURP  = Color3.fromRGB(120, 60, 200)
local COLOR_OFF_TEAL  = Color3.fromRGB(0, 160, 130)
local COLOR_ON        = Color3.fromRGB(0, 200, 90)

-- Y позиции кнопок
local BtnLift,  SubLift  = makeButton(MainFrame, 44,  "Lift",       COLOR_OFF_BLUE)
local BtnJump,  SubJump  = makeButton(MainFrame, 92,  "JumpBoost",  COLOR_OFF_PURP)
local BtnSpeed, SubSpeed = makeButton(MainFrame, 140, "Speed",      COLOR_OFF_TEAL)

SubLift.Text  = "Speed: " .. LIFT_SPEED .. " studs/sec"
SubJump.Text  = "Power: " .. JUMP_POWER .. " (2x jump)"
SubSpeed.Text = "WalkSpeed: " .. SPEED_VALUE

-- Версия внизу
local VerLbl = Instance.new("TextLabel", MainFrame)
VerLbl.Size                 = UDim2.new(1, 0, 0, 16)
VerLbl.Position             = UDim2.new(0, 0, 1, -18)
VerLbl.BackgroundTransparency = 1
VerLbl.TextColor3           = Color3.fromRGB(60, 60, 80)
VerLbl.TextSize             = 10
VerLbl.Font                 = Enum.Font.Gotham
VerLbl.Text                 = "v3.0 | @Primejtsu"

-- ================================================
-- КНОПКА — анимация нажатия
-- ================================================
local function animPress(btn)
    TweenService:Create(btn, TweenInfo.new(0.07), {
        Size = UDim2.new(1, -26, 0, 35)
    }):Play()
    task.wait(0.07)
    TweenService:Create(btn, TweenInfo.new(0.07), {
        Size = UDim2.new(1, -20, 0, 38)
    }):Play()
end

local function setBtn(btn, sub, state, label, subText, colorOff)
    if state then
        btn.BackgroundColor3 = COLOR_ON
        btn.Text = label .. "  ON"
        sub.Text = subText
        sub.TextColor3 = Color3.fromRGB(180, 255, 180)
    else
        btn.BackgroundColor3 = colorOff
        btn.Text = label .. "  OFF"
        sub.Text = subText
        sub.TextColor3 = Color3.fromRGB(200, 200, 220)
    end
end

-- ================================================
-- ЛОГИКА КНОПОК
-- ================================================

-- LIFT
BtnLift.MouseButton1Click:Connect(function()
    liftEnabled = not liftEnabled
    task.spawn(function() animPress(BtnLift) end)

    if liftEnabled then
        startLift()
        setBtn(BtnLift, SubLift, true,  "Lift", "Rising " .. LIFT_SPEED .. " studs/sec", COLOR_OFF_BLUE)
    else
        stopLift()
        setBtn(BtnLift, SubLift, false, "Lift", "Speed: " .. LIFT_SPEED .. " studs/sec", COLOR_OFF_BLUE)
    end
end)

-- JUMPBOOST
BtnJump.MouseButton1Click:Connect(function()
    jumpEnabled = not jumpEnabled
    task.spawn(function() animPress(BtnJump) end)

    local hum = getHum()
    if jumpEnabled then
        if hum then
            hum.JumpPower  = JUMP_POWER
            hum.JumpHeight = 0
        end
        setBtn(BtnJump, SubJump, true,  "JumpBoost", "Power: " .. JUMP_POWER .. " active!", COLOR_OFF_PURP)
    else
        if hum then
            hum.JumpPower  = 50
            hum.JumpHeight = 7.2
        end
        setBtn(BtnJump, SubJump, false, "JumpBoost", "Power: " .. JUMP_POWER .. " (2x jump)", COLOR_OFF_PURP)
    end
end)

-- SPEED
BtnSpeed.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    task.spawn(function() animPress(BtnSpeed) end)

    local hum = getHum()
    if speedEnabled then
        if hum then hum.WalkSpeed = SPEED_VALUE end
        setBtn(BtnSpeed, SubSpeed, true,  "Speed", "WalkSpeed: " .. SPEED_VALUE .. " active!", COLOR_OFF_TEAL)
    else
        if hum then hum.WalkSpeed = 16 end
        setBtn(BtnSpeed, SubSpeed, false, "Speed", "WalkSpeed: " .. SPEED_VALUE, COLOR_OFF_TEAL)
    end
end)

-- ================================================
-- DRAGGABLE
-- ================================================
local dragging  = false
local dragStart = nil
local startPos  = nil

TitleBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        dragging  = true
        dragStart = inp.Position
        startPos  = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(inp)
    if not dragging then return end
    if inp.UserInputType == Enum.UserInputType.MouseMovement
    or inp.UserInputType == Enum.UserInputType.Touch then
        local d = inp.Position - dragStart
        MainFrame.Position = UDim2.new(
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

print("[Primejtsu X] Tools v3.0 Loaded!")
