-- RIVALS OP Script with GUI
-- Только для образовательных целей

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ===================== GUI =====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RivalsHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 420)
MainFrame.Position = UDim2.new(0, 20, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(220, 40, 40)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 38)
TitleBar.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0, 6)
UICorner2.Parent = TitleBar

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0.5, 0)
TitleFix.Position = UDim2.new(0, 0, 0.5, 0)
TitleFix.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -10, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ RIVALS HUB"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local SubLabel = Instance.new("TextLabel")
SubLabel.Size = UDim2.new(1, -10, 1, 0)
SubLabel.Position = UDim2.new(0, 10, 0, 0)
SubLabel.BackgroundTransparency = 1
SubLabel.Text = "by Script Hub"
SubLabel.TextColor3 = Color3.fromRGB(255, 180, 180)
SubLabel.TextSize = 10
SubLabel.Font = Enum.Font.Gotham
SubLabel.TextXAlignment = Enum.TextXAlignment.Right
SubLabel.Parent = TitleBar

-- ===================== TOGGLE FUNCTION =====================
local yOffset = 50
local toggles = {}

local function createToggle(name, default, callback)
    local btn = Instance.new("Frame")
    btn.Size = UDim2.new(1, -20, 0, 38)
    btn.Position = UDim2.new(0, 10, 0, yOffset)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    btn.BorderSizePixel = 0
    btn.Parent = MainFrame

    local UICorner3 = Instance.new("UICorner")
    UICorner3.CornerRadius = UDim.new(0, 5)
    UICorner3.Parent = btn

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 12
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = btn

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 36, 0, 18)
    indicator.Position = UDim2.new(1, -46, 0.5, -9)
    indicator.BackgroundColor3 = default and Color3.fromRGB(220, 40, 40) or Color3.fromRGB(60, 60, 70)
    indicator.BorderSizePixel = 0
    indicator.Parent = btn

    local UICorner4 = Instance.new("UICorner")
    UICorner4.CornerRadius = UDim.new(1, 0)
    UICorner4.Parent = indicator

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 14, 0, 14)
    circle.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.BorderSizePixel = 0
    circle.Parent = indicator

    local UICorner5 = Instance.new("UICorner")
    UICorner5.CornerRadius = UDim.new(1, 0)
    UICorner5.Parent = circle

    local enabled = default
    toggles[name] = enabled
    callback(enabled)

    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.Parent = btn

    clickBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        toggles[name] = enabled
        indicator.BackgroundColor3 = enabled and Color3.fromRGB(220, 40, 40) or Color3.fromRGB(60, 60, 70)
        circle.Position = enabled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        callback(enabled)
    end)

    yOffset = yOffset + 46
end

-- ===================== FEATURES =====================

-- 1. Aimbot
local aimbotEnabled = false
local aimbotConnection

createToggle("🎯 Aimbot", false, function(state)
    aimbotEnabled = state
    if state then
        aimbotConnection = RunService.RenderStepped:Connect(function()
            if not aimbotEnabled then return end
            local closestPlayer = nil
            local closestDist = math.huge
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    local hum = player.Character:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                        if onScreen then
                            local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                            if dist < closestDist then
                                closestDist = dist
                                closestPlayer = player
                            end
                        end
                    end
                end
            end
            if closestPlayer and closestPlayer.Character then
                local head = closestPlayer.Character:FindFirstChild("Head")
                if head then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
                end
            end
        end)
    else
        if aimbotConnection then
            aimbotConnection:Disconnect()
            aimbotConnection = nil
        end
    end
end)

-- 2. ESP / Wallhack
local espEnabled = false
local espBoxes = {}

local function removeESP()
    for _, box in pairs(espBoxes) do
        if box and box.Parent then box:Destroy() end
    end
    espBoxes = {}
end

local function addESP(player)
    if player == LocalPlayer then return end
    RunService.RenderStepped:Connect(function()
        if not espEnabled then return end
        if player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local highlight = player.Character:FindFirstChild("ESPHighlight")
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "ESPHighlight"
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                    highlight.FillTransparency = 0.6
                    highlight.Parent = player.Character
                    table.insert(espBoxes, highlight)
                end
            end
        end
    end)
end

createToggle("👁️ ESP / Wallhack", false, function(state)
    espEnabled = state
    if state then
        for _, player in ipairs(Players:GetPlayers()) do
            addESP(player)
        end
        Players.PlayerAdded:Connect(function(p)
            if espEnabled then addESP(p) end
        end)
    else
        removeESP()
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                local h = player.Character:FindFirstChild("ESPHighlight")
                if h then h:Destroy() end
            end
        end
    end
end)

-- 3. Infinite Ammo (visual toggle)
createToggle("🔫 Infinite Ammo", false, function(state)
    -- Placeholder: hooks into tool reload logic
    if state then
        RunService.Heartbeat:Connect(function()
            if not toggles["🔫 Infinite Ammo"] then return end
            local char = LocalPlayer.Character
            if char then
                local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool then
                    local ammo = tool:FindFirstChild("Ammo") or tool:FindFirstChild("ammo")
                    if ammo and ammo:IsA("IntValue") then
                        ammo.Value = 999
                    end
                end
            end
        end)
    end
end)

-- 4. Speed Hack
local speedConnection
createToggle("🏃 Speed Hack", false, function(state)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = state and 40 or 16
    end
    LocalPlayer.CharacterAdded:Connect(function(c)
        local h = c:WaitForChild("Humanoid")
        if toggles["🏃 Speed Hack"] then
            h.WalkSpeed = 40
        end
    end)
end)

-- 5. No Clip
local noclipEnabled = false
local noclipConn

createToggle("👻 No Clip", false, function(state)
    noclipEnabled = state
    if state then
        noclipConn = RunService.Stepped:Connect(function()
            if not noclipEnabled then return end
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConn then
            noclipConn:Disconnect()
            noclipConn = nil
        end
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end)

-- 6. Anti AFK
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 24)
statusLabel.Position = UDim2.new(0, 10, 1, -30)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "✅ Anti-AFK активен | RIVALS HUB"
statusLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
statusLabel.TextSize = 10
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = MainFrame

print("✅ RIVALS HUB загружен успешно!")
