-- ============================================
--   [FPS] Флик - Advanced Script
--   GUI: Rayfield | by Grandpa 👴
-- ============================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Сервисы
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService   = game:GetService("TweenService")
local Camera         = workspace.CurrentCamera

local LP             = Players.LocalPlayer
local Mouse          = LP:GetMouse()

-- ============================================
-- Переменные состояния
-- ============================================
local Settings = {
    ESP           = false,
    Aimbot        = false,
    SilentAim     = false,
    FOVCircle     = false,
    FOVRadius     = 120,
    AimbotPart    = "Head",
    AimbotSmooth  = 0.2,
    NoFall        = false,
    InfJump       = false,
    SpeedHack     = false,
    SpeedValue    = 30,
    NoclipEnabled = false,
    ShowFPS       = false,
}

-- ============================================
-- Rayfield Window
-- ============================================
local Window = Rayfield:CreateWindow({
    Name             = "Флик Script 🔥 | by Grandpa",
    LoadingTitle     = "Загрузка...",
    LoadingSubtitle  = "Advanced Edition v3.0",
    Theme            = "Default",
    DisableRayfieldPrompts  = false,
    DisableBuildWarnings    = false,
})

-- ============================================
-- FOV CIRCLE
-- ============================================
local FOVCircleDrawing = Drawing.new("Circle")
FOVCircleDrawing.Visible   = false
FOVCircleDrawing.Thickness = 1.5
FOVCircleDrawing.Color     = Color3.fromRGB(255, 255, 0)
FOVCircleDrawing.Filled    = false
FOVCircleDrawing.NumSides  = 64
FOVCircleDrawing.Radius    = Settings.FOVRadius
FOVCircleDrawing.Position  = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

RunService.RenderStepped:Connect(function()
    FOVCircleDrawing.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircleDrawing.Radius   = Settings.FOVRadius
    FOVCircleDrawing.Visible  = Settings.FOVCircle
end)

-- ============================================
-- ESP
-- ============================================
local ESPHighlights = {}

local function addESP(player)
    if player == LP then return end
    local hl = Instance.new("Highlight")
    hl.FillColor        = Color3.fromRGB(255, 0, 0)
    hl.OutlineColor     = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.5
    ESPHighlights[player] = hl

    local function applyChar(char)
        hl.Parent = char
    end
    player.CharacterAdded:Connect(applyChar)
    if player.Character then applyChar(player.Character) end
end

local function removeESP(player)
    if ESPHighlights[player] then
        ESPHighlights[player]:Destroy()
        ESPHighlights[player] = nil
    end
end

Players.PlayerAdded:Connect(function(p)
    if Settings.ESP then addESP(p) end
end)
Players.PlayerRemoving:Connect(removeESP)

-- ============================================
-- ПОЛУЧИТЬ БЛИЖАЙШЕГО ВРАГА (для Aim)
-- ============================================
local function getClosestPlayer()
    local closestPlayer = nil
    local closestDist   = Settings.FOVRadius

    local centerX = Camera.ViewportSize.X / 2
    local centerY = Camera.ViewportSize.Y / 2

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP and player.Character then
            local targetPart = player.Character:FindFirstChild(Settings.AimbotPart)
                            or player.Character:FindFirstChild("HumanoidRootPart")
            if targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local dist = math.sqrt(
                        (screenPos.X - centerX)^2 + (screenPos.Y - centerY)^2
                    )
                    if dist < closestDist then
                        closestDist   = dist
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- ============================================
-- AIMBOT (обычный)
-- ============================================
RunService.RenderStepped:Connect(function()
    if Settings.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestPlayer()
        if target and target.Character then
            local part = target.Character:FindFirstChild(Settings.AimbotPart)
                      or target.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local targetPos = Camera:WorldToViewportPoint(part.Position)
                local currentCF = Camera.CFrame
                local targetCF  = CFrame.lookAt(
                    currentCF.Position,
                    part.Position
                )
                Camera.CFrame = currentCF:Lerp(targetCF, Settings.AimbotSmooth)
            end
        end
    end
end)

-- ============================================
-- SILENT AIM
-- ============================================
local silentAimConn
local function enableSilentAim()
    silentAimConn = RunService.RenderStepped:Connect(function()
        if not Settings.SilentAim then return end
        local target = getClosestPlayer()
        if target and target.Character then
            local part = target.Character:FindFirstChild(Settings.AimbotPart)
                      or target.Character:FindFirstChild("HumanoidRootPart")
            if part then
                Mouse.Hit = CFrame.new(part.Position)
                Mouse.Target = part
            end
        end
    end)
end
enableSilentAim()

-- ============================================
-- NO FALL DAMAGE
-- ============================================
LP.CharacterAdded:Connect(function(char)
    if Settings.NoFall then
        local hum = char:WaitForChild("Humanoid")
        hum.StateChanged:Connect(function(_, new)
            if new == Enum.HumanoidStateType.Freefall then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
        end)
    end
end)

-- ============================================
-- INFINITE JUMP
-- ============================================
UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump and LP.Character then
        local hum = LP.Character:FindFirstChild("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ============================================
-- SPEED HACK
-- ============================================
RunService.Heartbeat:Connect(function()
    if Settings.SpeedHack and LP.Character then
        local hum = LP.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = Settings.SpeedValue end
    end
end)

-- ============================================
-- NOCLIP
-- ============================================
RunService.Stepped:Connect(function()
    if Settings.NoclipEnabled and LP.Character then
        for _, part in pairs(LP.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- ============================================
-- RAYFIELD TABS
-- ============================================

-- TAB: Визуал
local VisualTab = Window:CreateTab("👁 Визуал", 4483362458)

VisualTab:CreateToggle({
    Name      = "ESP (видеть врагов через стены)",
    CurrentValue = false,
    Flag      = "ESP",
    Callback  = function(val)
        Settings.ESP = val
        if val then
            for _, p in pairs(Players:GetPlayers()) do addESP(p) end
        else
            for _, p in pairs(Players:GetPlayers()) do removeESP(p) end
        end
    end,
})

VisualTab:CreateToggle({
    Name      = "FOV Circle (круг прицела)",
    CurrentValue = false,
    Flag      = "FOVCircle",
    Callback  = function(val)
        Settings.FOVCircle = val
    end,
})

VisualTab:CreateSlider({
    Name    = "Размер FOV Circle",
    Range   = {50, 400},
    Increment = 10,
    CurrentValue = 120,
    Flag    = "FOVRadius",
    Callback = function(val)
        Settings.FOVRadius = val
    end,
})

-- TAB: Aim
local AimTab = Window:CreateTab("🎯 Aim", 4483362458)

AimTab:CreateToggle({
    Name      = "Aimbot (RMB для активации)",
    CurrentValue = false,
    Flag      = "Aimbot",
    Callback  = function(val)
        Settings.Aimbot = val
    end,
})

AimTab:CreateToggle({
    Name      = "Silent Aim (скрытый aim)",
    CurrentValue = false,
    Flag      = "SilentAim",
    Callback  = function(val)
        Settings.SilentAim = val
    end,
})

AimTab:CreateSlider({
    Name      = "Плавность Aim (меньше = быстрее)",
    Range     = {1, 100},
    Increment = 1,
    CurrentValue = 20,
    Flag      = "AimbotSmooth",
    Callback  = function(val)
        Settings.AimbotSmooth = val / 100
    end,
})

AimTab:CreateDropdown({
    Name    = "Часть тела для прицела",
    Options = {"Head", "HumanoidRootPart", "Torso", "UpperTorso"},
    CurrentOption = {"Head"},
    Flag    = "AimbotPart",
    Callback = function(option)
        Settings.AimbotPart = option[1]
    end,
})

-- TAB: Движение
local MoveTab = Window:CreateTab("🏃 Движение", 4483362458)

MoveTab:CreateToggle({
    Name      = "Infinite Jump (бесконечный прыжок)",
    CurrentValue = false,
    Flag      = "InfJump",
    Callback  = function(val)
        Settings.InfJump = val
    end,
})

MoveTab:CreateToggle({
    Name      = "Speed Hack (ускорение)",
    CurrentValue = false,
    Flag      = "SpeedHack",
    Callback  = function(val)
        Settings.SpeedHack = val
        if not val and LP.Character then
            local hum = LP.Character:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = 16 end
        end
    end,
})

MoveTab:CreateSlider({
    Name      = "Скорость бега",
    Range     = {16, 150},
    Increment = 1,
    CurrentValue = 30,
    Flag      = "SpeedValue",
    Callback  = function(val)
        Settings.SpeedValue = val
    end,
})

MoveTab:CreateToggle({
    Name      = "Noclip (нет коллизий)",
    CurrentValue = false,
    Flag      = "Noclip",
    Callback  = function(val)
        Settings.NoclipEnabled = val
    end,
})

MoveTab:CreateToggle({
    Name      = "No Fall Damage",
    CurrentValue = false,
    Flag      = "NoFall",
    Callback  = function(val)
        Settings.NoFall = val
    end,
})

-- TAB: Прочее
local MiscTab = Window:CreateTab("⚙️ Прочее", 4483362458)

MiscTab:CreateButton({
    Name     = "Телепорт в спавн",
    Callback = function()
        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            LP.Character.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
        end
    end,
})

MiscTab:CreateButton({
    Name     = "Убить себя (respawn)",
    Callback = function()
        if LP.Character then
            local hum = LP.Character:FindFirstChild("Humanoid")
            if hum then hum.Health = 0 end
        end
    end,
})

MiscTab:CreateButton({
    Name     = "Скопировать имя игрока",
    Callback = function()
        Rayfield:Notify({
            Title    = "Имя скопировано!",
            Content  = LP.Name,
            Duration = 3,
            Image    = 4483362458,
        })
    end,
})

-- ============================================
-- Уведомление при запуске
-- ============================================
Rayfield:Notify({
    Title    = "Флик Script загружен! 🔥",
    Content  = "Удачи на работе! 👴",
    Duration = 5,
    Image    = 4483362458,
})

print("[Флик Script] Загружен успешно!")
