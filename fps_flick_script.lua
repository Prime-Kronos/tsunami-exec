-- ============================================
-- [FPS] ФЛИК — МОЩНЫЙ СКРИПТ
-- Функции: AimBot, ESP, Speed, Noclip, Fly
-- GUI: Перетаскиваемый, сворачиваемый
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- ============ СОСТОЯНИЯ ============
local states = {
    aimbot = false,
    esp = false,
    noclip = false,
    speed = false,
    fly = false,
    minimized = false,
}

local flySpeed = 60
local walkSpeed = 90
local bodyVelocity, bodyGyro
local highlights = {}

-- ============ GUI ============
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Name = "FlickHack"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player.PlayerGui

-- Главный фрейм
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 230, 0, 320)
main.Position = UDim2.new(0, 20, 0, 100)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

-- Обводка
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 80, 80)
stroke.Thickness = 1.5
stroke.Parent = main

-- ===== ШАПКА =====
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 42)
header.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
header.BorderSizePixel = 0
header.Parent = main
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)

local fix = Instance.new("Frame")
fix.Size = UDim2.new(1, 0, 0.5, 0)
fix.Position = UDim2.new(0, 0, 0.5, 0)
fix.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
fix.BorderSizePixel = 0
fix.Parent = header

local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "🎯 FPS ФЛИК HACK"
titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
titleLabel.Position = UDim2.new(0.03, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 13
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = header

-- Кнопка свернуть
local minBtn = Instance.new("TextButton")
minBtn.Text = "—"
minBtn.Size = UDim2.new(0, 28, 0, 28)
minBtn.Position = UDim2.new(1, -62, 0.5, -14)
minBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
minBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 16
minBtn.BorderSizePixel = 0
minBtn.Parent = header
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

-- Кнопка закрыть
local closeBtn = Instance.new("TextButton")
closeBtn.Text = "✕"
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -30, 0.5, -14)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.BorderSizePixel = 0
closeBtn.Parent = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

-- Контент
local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 1, -42)
content.Position = UDim2.new(0, 0, 0, 42)
content.BackgroundTransparency = 1
content.Parent = main

-- ===== КНОПКИ =====
local function makeBtn(icon, label, yPos, onColor)
    local btn = Instance.new("TextButton")
    btn.Text = icon .. "  " .. label .. ": ВЫКЛ ❌"
    btn.Size = UDim2.new(0.88, 0, 0, 44)
    btn.Position = UDim2.new(0.06, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.Parent = content

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 9)
    bc.Parent = btn

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 10, 0, 10)
    dot.Position = UDim2.new(1, -18, 0.5, -5)
    dot.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    dot.BorderSizePixel = 0
    dot.Parent = btn
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 10)
    pad.Parent = btn

    return btn, dot, icon, label
end

local aimbotBtn, aimbotDot, aimbotIcon, aimbotLabel = makeBtn("🎯", "AimBot", 8, Color3.fromRGB(255, 80, 80))
local espBtn, espDot = makeBtn("👁", "ESP", 60, Color3.fromRGB(0, 180, 255))
local noclipBtn, noclipDot = makeBtn("👻", "Noclip", 112, Color3.fromRGB(180, 0, 255))
local speedBtn, speedDot = makeBtn("⚡", "Speed", 164, Color3.fromRGB(255, 200, 0))
local flyBtn, flyDot = makeBtn("✈️", "Fly", 216, Color3.fromRGB(0, 220, 120))

local function toggleBtn(btn, dot, icon, label, state, activeColor)
    if state then
        btn.Text = icon .. "  " .. label .. ": ВКЛ ✅"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        dot.BackgroundColor3 = activeColor
    else
        btn.Text = icon .. "  " .. label .. ": ВЫКЛ ❌"
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        dot.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    end
end

-- ============ ПЕРЕТАСКИВАНИЕ ============
local dragging = false
local dragStart, startPos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
       input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ============ СВЕРНУТЬ/ЗАКРЫТЬ ============
minBtn.MouseButton1Click:Connect(function()
    states.minimized = not states.minimized
    content.Visible = not states.minimized
    if states.minimized then
        main.Size = UDim2.new(0, 230, 0, 42)
        minBtn.Text = "+"
    else
        main.Size = UDim2.new(0, 230, 0, 320)
        minBtn.Text = "—"
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- ============ AIMBOT ============
local function getClosestPlayer()
    local closest = nil
    local minDist = math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local head = p.Character:FindFirstChild("Head")
            if head then
                local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closest = head
                    end
                end
            end
        end
    end
    return closest
end

aimbotBtn.MouseButton1Click:Connect(function()
    states.aimbot = not states.aimbot
    toggleBtn(aimbotBtn, aimbotDot, "🎯", "AimBot", states.aimbot, Color3.fromRGB(255, 80, 80))
end)

-- ============ ESP ============
local function addESP(p)
    if p == player then return end
    local function apply(char)
        if highlights[p] then highlights[p]:Destroy() end
        local hl = Instance.new("Highlight")
        hl.Adornee = char
        hl.FillColor = Color3.fromRGB(255, 50, 50)
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.55
        hl.Parent = char
        highlights[p] = hl
    end
    if p.Character then apply(p.Character) end
    p.CharacterAdded:Connect(apply)
end

local function removeESP(p)
    if highlights[p] then
        highlights[p]:Destroy()
        highlights[p] = nil
    end
end

espBtn.MouseButton1Click:Connect(function()
    states.esp = not states.esp
    toggleBtn(espBtn, espDot, "👁", "ESP", states.esp, Color3.fromRGB(0, 180, 255))
    if states.esp then
        for _, p in pairs(Players:GetPlayers()) do addESP(p) end
        Players.PlayerAdded:Connect(addESP)
    else
        for _, p in pairs(Players:GetPlayers()) do removeESP(p) end
    end
end)

-- ============ NOCLIP ============
noclipBtn.MouseButton1Click:Connect(function()
    states.noclip = not states.noclip
    toggleBtn(noclipBtn, noclipDot, "👻", "Noclip", states.noclip, Color3.fromRGB(180, 0, 255))
end)

-- ============ SPEED ============
speedBtn.MouseButton1Click:Connect(function()
    states.speed = not states.speed
    toggleBtn(speedBtn, speedDot, "⚡", "Speed", states.speed, Color3.fromRGB(255, 200, 0))
    humanoid.WalkSpeed = states.speed and walkSpeed or 16
end)

-- ============ FLY ============
local function startFly()
    humanoid.PlatformStand = true
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0,0,0)
    bodyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5)
    bodyVelocity.Parent = rootPart

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5)
    bodyGyro.P = 1e4
    bodyGyro.Parent = rootPart
end

local function stopFly()
    humanoid.PlatformStand = false
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
end

flyBtn.MouseButton1Click:Connect(function()
    states.fly = not states.fly
    toggleBtn(flyBtn, flyDot, "✈️", "Fly", states.fly, Color3.fromRGB(0, 220, 120))
    if states.fly then startFly() else stopFly() end
end)

-- ============ ГЛАВНЫЙ LOOP ============
RunService.Heartbeat:Connect(function()
    -- Noclip
    if states.noclip then
        for _, p in pairs(character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end

    -- Aimbot
    if states.aimbot then
        local target = getClosestPlayer()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end

    -- Fly
    if states.fly and bodyVelocity and bodyGyro then
        local dir = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
        bodyVelocity.Velocity = dir * flySpeed
        bodyGyro.CFrame = Camera.CFrame
    end
end)

-- Обновить при смерти
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    rootPart = char:WaitForChild("HumanoidRootPart")
    states.fly = false
    states.noclip = false
    states.speed = false
    toggleBtn(flyBtn, flyDot, "✈️", "Fly", false, Color3.fromRGB(0,220,120))
    toggleBtn(noclipBtn, noclipDot, "👻", "Noclip", false, Color3.fromRGB(180,0,255))
    toggleBtn(speedBtn, speedDot, "⚡", "Speed", false, Color3.fromRGB(255,200,0))
end)

print("✅ FPS ФЛИК HACK загружен успешно!")
