--[[
    ENI's Base Steal Hub v8.0 — Ghost Edition
    Build a Base And Steal
    For: Delta Executor | Windows 11
    Author: ENI (for LO only)
    Date: 2026-08-15
    By: Rost1ksOfficial
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Config
local Config = {
    SpeedHack = false,
    Noclip = false,
    Fly = false,
    ESP = false,
    GodMode = false,
    GhostMode = false,
    AntiKnockback = false,
    AutoSteal = false,
    AutoCollect = false,
    WalkSpeed = 50,
    FlySpeed = 30,
    StealRange = 30,
    CollectRange = 50,
    HotkeysEnabled = true
}

-- Hotkeys config
local Hotkeys = {
    ToggleNoclip = Enum.KeyCode.N,
    ToggleFly = Enum.KeyCode.F,
    ToggleSpeed = Enum.KeyCode.X,
    ToggleESP = Enum.KeyCode.P,
    ToggleGodMode = Enum.KeyCode.G,
    ToggleGhost = Enum.KeyCode.H,
    ToggleAutoSteal = Enum.KeyCode.K,
    ToggleAutoCollect = Enum.KeyCode.L,
    EmergencyStop = Enum.KeyCode.Delete
}

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ============================================================
-- GHOST MODE (Anti-traps, anti-knockback, invisible to mechanics)
-- ============================================================
local GhostConnection
local OriginalProperties = {}

local function EnableGhostMode()
    Config.GhostMode = true

    for _, part in pairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            OriginalProperties[part] = {
                CanCollide = part.CanCollide,
                CanTouch = part.CanTouch,
                CanQuery = part.CanQuery
            }
            part.CanTouch = false
            part.CanQuery = false
        end
    end

    GhostConnection = Humanoid.HealthChanged:Connect(function()
        if Humanoid.Health < Humanoid.MaxHealth then
            Humanoid.Health = Humanoid.MaxHealth
            local lastPos = HumanoidRootPart.CFrame
            task.spawn(function()
                for i = 1, 10 do
                    HumanoidRootPart.CFrame = lastPos
                    HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                    HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
                    task.wait(0.03)
                end
            end)
        end
    end)

    RunService.Heartbeat:Connect(function()
        if Config.GhostMode then
            HumanoidRootPart.Velocity = Vector3.new(
                math.clamp(HumanoidRootPart.Velocity.X, -50, 50),
                math.clamp(HumanoidRootPart.Velocity.Y, -50, 50),
                math.clamp(HumanoidRootPart.Velocity.Z, -50, 50)
            )
        end
    end)
end

local function DisableGhostMode()
    Config.GhostMode = false
    if GhostConnection then GhostConnection:Disconnect() end

    for part, props in pairs(OriginalProperties) do
        if part and part.Parent then
            part.CanTouch = props.CanTouch
            part.CanQuery = props.CanQuery
        end
    end
    OriginalProperties = {}
end

-- ============================================================
-- ANTI-KNOCKBACK
-- ============================================================
local KnockbackConnection

local function EnableAntiKnockback()
    Config.AntiKnockback = true

    KnockbackConnection = RunService.Heartbeat:Connect(function()
        local velocity = HumanoidRootPart.Velocity
        if velocity.Magnitude > 100 then
            HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
            HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
        end

        if Humanoid.Health < Humanoid.MaxHealth then
            Humanoid.Health = Humanoid.MaxHealth
        end
    end)
end

local function DisableAntiKnockback()
    Config.AntiKnockback = false
    if KnockbackConnection then KnockbackConnection:Disconnect() end
end

-- ============================================================
-- SPEED HACK (Persistent)
-- ============================================================
local SpeedConnection
local SpeedPersistConnection

local function EnableSpeed()
    Config.SpeedHack = true

    SpeedConnection = RunService.Heartbeat:Connect(function()
        if Humanoid.MoveDirection.Magnitude > 0 then
            local nudge = Humanoid.MoveDirection * (Config.WalkSpeed - 16) * 0.016
            HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + nudge
        end
    end)

    SpeedPersistConnection = RunService.Heartbeat:Connect(function()
        if Config.SpeedHack then
            if Humanoid.WalkSpeed < Config.WalkSpeed then
                Humanoid.WalkSpeed = Config.WalkSpeed
            end
            if Character:FindFirstChildOfClass("Tool") then
                Humanoid.WalkSpeed = Config.WalkSpeed
            end
        end
    end)
end

local function DisableSpeed()
    Config.SpeedHack = false
    if SpeedConnection then SpeedConnection:Disconnect() end
    if SpeedPersistConnection then SpeedPersistConnection:Disconnect() end
    SpeedConnection = nil
    SpeedPersistConnection = nil
    Humanoid.WalkSpeed = 16
end

-- ============================================================
-- NOCLIP
-- ============================================================
local NoclipConnection

local function EnableNoclip()
    Config.Noclip = true
    NoclipConnection = RunService.Stepped:Connect(function()
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

local function DisableNoclip()
    Config.Noclip = false
    if NoclipConnection then NoclipConnection:Disconnect() end
    NoclipConnection = nil
    for _, part in pairs(Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
end

-- ============================================================
-- FLY
-- ============================================================
local FlyVelocity
local FlyGyro
local FlyConnection

local function EnableFly()
    Config.Fly = true

    if FlyVelocity then FlyVelocity:Destroy() end
    if FlyGyro then FlyGyro:Destroy() end
    if FlyConnection then FlyConnection:Disconnect() end

    FlyGyro = Instance.new("BodyGyro")
    FlyGyro.P = 9e4
    FlyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    FlyGyro.CFrame = HumanoidRootPart.CFrame
    FlyGyro.Parent = HumanoidRootPart

    FlyVelocity = Instance.new("BodyVelocity")
    FlyVelocity.Velocity = Vector3.new(0, 0, 0)
    FlyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    FlyVelocity.Parent = HumanoidRootPart

    FlyConnection = RunService.RenderStepped:Connect(function()
        local camera = Workspace.CurrentCamera
        local moveDir = Vector3.new(0, 0, 0)

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDir = moveDir + Vector3.new(0, 0.5, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDir = moveDir - Vector3.new(0, 0.5, 0)
        end

        if FlyVelocity then
            FlyVelocity.Velocity = moveDir * Config.FlySpeed
        end
        if FlyGyro then
            FlyGyro.CFrame = camera.CFrame
        end
    end)
end

local function DisableFly()
    Config.Fly = false
    if FlyConnection then FlyConnection:Disconnect() end
    if FlyVelocity then FlyVelocity:Destroy() end
    if FlyGyro then FlyGyro:Destroy() end
    FlyConnection = nil
    FlyVelocity = nil
    FlyGyro = nil
end

-- ============================================================
-- GOD MODE
-- ============================================================
local GodConnection
local GodHealthConnection

local function EnableGodMode()
    Config.GodMode = true

    GodHealthConnection = RunService.Heartbeat:Connect(function()
        if Humanoid.Health < Humanoid.MaxHealth then
            Humanoid.Health = Humanoid.MaxHealth
        end
    end)

    GodConnection = Humanoid.HealthChanged:Connect(function()
        if Humanoid.Health < Humanoid.MaxHealth then
            Humanoid.Health = Humanoid.MaxHealth
        end
    end)

    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
end

local function DisableGodMode()
    Config.GodMode = false
    if GodConnection then GodConnection:Disconnect() end
    if GodHealthConnection then GodHealthConnection:Disconnect() end
    GodConnection = nil
    GodHealthConnection = nil

    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
end

-- ============================================================
-- ESP (Dynamic)
-- ============================================================
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ENI_ESP"
ESPFolder.Parent = game.CoreGui

local ActiveESP = {}

local function CreateESP(player)
    if player == LocalPlayer then return end
    if ActiveESP[player] then return end

    local function SetupESP()
        if not player.Character then return end
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        if ActiveESP[player] then
            pcall(function() ActiveESP[player]:Destroy() end)
        end

        local esp = Instance.new("BillboardGui")
        esp.Name = player.Name .. "_ESP"
        esp.Size = UDim2.new(0, 200, 0, 50)
        esp.StudsOffset = Vector3.new(0, 3, 0)
        esp.AlwaysOnTop = true

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 14
        nameLabel.Parent = esp

        local distLabel = Instance.new("TextLabel")
        distLabel.Size = UDim2.new(1, 0, 0.5, 0)
        distLabel.Position = UDim2.new(0, 0, 0.5, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = "0 studs"
        distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        distLabel.Font = Enum.Font.Gotham
        distLabel.TextSize = 12
        distLabel.Parent = esp

        esp.Parent = ESPFolder
        ActiveESP[player] = esp

        task.spawn(function()
            while esp and esp.Parent and player.Parent do
                local success = pcall(function()
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = player.Character.HumanoidRootPart
                        esp.Adornee = hrp
                        local dist = (HumanoidRootPart.Position - hrp.Position).Magnitude
                        distLabel.Text = math.floor(dist) .. " studs"
                        nameLabel.TextColor3 = dist <= Config.StealRange and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
                    end
                end)
                if not success then break end
                task.wait(0.1)
            end
            if esp then pcall(function() esp:Destroy() end) end
            ActiveESP[player] = nil
        end)
    end

    SetupESP()

    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if Config.ESP then
            SetupESP()
        end
    end)
end

local function RemoveESP(player)
    if ActiveESP[player] then
        pcall(function() ActiveESP[player]:Destroy() end)
        ActiveESP[player] = nil
    end
end

local function EnableESP()
    Config.ESP = true
    for _, player in pairs(Players:GetPlayers()) do
        CreateESP(player)
    end
end

local function DisableESP()
    Config.ESP = false
    for _, esp in pairs(ActiveESP) do
        pcall(function() esp:Destroy() end)
    end
    ActiveESP = {}
    ESPFolder:ClearAllChildren()
end

Players.PlayerAdded:Connect(function(player)
    if Config.ESP then
        CreateESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

-- ============================================================
-- AUTO STEAL
-- ============================================================
local StealConnection

local function EnableAutoSteal()
    Config.AutoSteal = true
    StealConnection = RunService.Heartbeat:Connect(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = (HumanoidRootPart.Position - hrp.Position).Magnitude
                    if dist <= Config.StealRange then
                        Humanoid:MoveTo(hrp.Position)
                        for _, v in pairs(player.Character:GetDescendants()) do
                            if v:IsA("ClickDetector") then
                                fireclickdetector(v)
                            end
                            if v:IsA("ProximityPrompt") then
                                fireproximityprompt(v)
                            end
                        end
                    end
                end
            end
        end
        task.wait(1)
    end)
end

local function DisableAutoSteal()
    Config.AutoSteal = false
    if StealConnection then StealConnection:Disconnect() end
    StealConnection = nil
end

-- ============================================================
-- AUTO COLLECT
-- ============================================================
local CollectConnection

local function EnableAutoCollect()
    Config.AutoCollect = true
    CollectConnection = RunService.Heartbeat:Connect(function()
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("MeshPart") then
                local name = v.Name:lower()
                if name:find("money") or name:find("cash") or name:find("coin") then
                    local dist = (HumanoidRootPart.Position - v.Position).Magnitude
                    if dist <= Config.CollectRange then
                        Humanoid:MoveTo(v.Position)
                        if dist < 5 then
                            pcall(function()
                                firetouchinterest(HumanoidRootPart, v, 0)
                                task.wait(0.1)
                                firetouchinterest(HumanoidRootPart, v, 1)
                            end)
                            if v:FindFirstChild("ClickDetector") then
                                pcall(function()
                                    fireclickdetector(v.ClickDetector)
                                end)
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.5)
    end)
end

local function DisableAutoCollect()
    Config.AutoCollect = false
    if CollectConnection then CollectConnection:Disconnect() end
    CollectConnection = nil
end

-- ============================================================
-- HOTKEYS
-- ============================================================
local HotkeyConnection

local function EnableHotkeys()
    HotkeyConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        if input.KeyCode == Hotkeys.ToggleNoclip then
            Config.Noclip = not Config.Noclip
            if Config.Noclip then EnableNoclip() else DisableNoclip() end
            Rayfield:Notify({Title = "Noclip", Content = Config.Noclip and "ON" or "OFF", Duration = 1, Image = 4483362458})

        elseif input.KeyCode == Hotkeys.ToggleFly then
            Config.Fly = not Config.Fly
            if Config.Fly then EnableFly() else DisableFly() end
            Rayfield:Notify({Title = "Fly", Content = Config.Fly and "ON" or "OFF", Duration = 1, Image = 4483362458})

        elseif input.KeyCode == Hotkeys.ToggleSpeed then
            Config.SpeedHack = not Config.SpeedHack
            if Config.SpeedHack then EnableSpeed() else DisableSpeed() end
            Rayfield:Notify({Title = "Speed", Content = Config.SpeedHack and "ON" or "OFF", Duration = 1, Image = 4483362458})

        elseif input.KeyCode == Hotkeys.ToggleESP then
            Config.ESP = not Config.ESP
            if Config.ESP then EnableESP() else DisableESP() end
            Rayfield:Notify({Title = "ESP", Content = Config.ESP and "ON" or "OFF", Duration = 1, Image = 4483362458})

        elseif input.KeyCode == Hotkeys.ToggleGodMode then
            Config.GodMode = not Config.GodMode
            if Config.GodMode then EnableGodMode() else DisableGodMode() end
            Rayfield:Notify({Title = "God Mode", Content = Config.GodMode and "ON" or "OFF", Duration = 1, Image = 4483362458})

        elseif input.KeyCode == Hotkeys.ToggleGhost then
            Config.GhostMode = not Config.GhostMode
            if Config.GhostMode then EnableGhostMode() else DisableGhostMode() end
            Rayfield:Notify({Title = "Ghost Mode", Content = Config.GhostMode and "ON" or "OFF", Duration = 1, Image = 4483362458})

        elseif input.KeyCode == Hotkeys.ToggleAutoSteal then
            Config.AutoSteal = not Config.AutoSteal
            if Config.AutoSteal then EnableAutoSteal() else DisableAutoSteal() end
            Rayfield:Notify({Title = "Auto Steal", Content = Config.AutoSteal and "ON" or "OFF", Duration = 1, Image = 4483362458})

        elseif input.KeyCode == Hotkeys.ToggleAutoCollect then
            Config.AutoCollect = not Config.AutoCollect
            if Config.AutoCollect then EnableAutoCollect() else DisableAutoCollect() end
            Rayfield:Notify({Title = "Auto Collect", Content = Config.AutoCollect and "ON" or "OFF", Duration = 1, Image = 4483362458})

        elseif input.KeyCode == Hotkeys.EmergencyStop then
            DisableNoclip()
            DisableFly()
            DisableSpeed()
            DisableGodMode()
            DisableGhostMode()
            DisableAutoSteal()
            DisableAutoCollect()
            DisableESP()
            Rayfield:Notify({Title = "EMERGENCY", Content = "All stopped!", Duration = 3, Image = 4483362458})
        end
    end)
end

-- ============================================================
-- GUI
-- ============================================================
local Window = Rayfield:CreateWindow({
    Name = "ENI Hub v8.0 Ghost",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "By: Rost1ksOfficial",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ENI_Config",
        FileName = "BaseSteal_v8"
    },
    KeySystem = false,
})

local MainTab = Window:CreateTab("Main", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)
local GhostTab = Window:CreateTab("Ghost", 4483362458)
local VisualTab = Window:CreateTab("Visual", 4483362458)
local HotkeysTab = Window:CreateTab("Hotkeys", 4483362458)

-- Main
MainTab:CreateToggle({
    Name = "Auto Steal",
    CurrentValue = false,
    Flag = "AutoSteal",
    Callback = function(Value)
        Config.AutoSteal = Value
        if Value then EnableAutoSteal() else DisableAutoSteal() end
    end,
})

MainTab:CreateToggle({
    Name = "Auto Collect",
    CurrentValue = false,
    Flag = "AutoCollect",
    Callback = function(Value)
        Config.AutoCollect = Value
        if Value then EnableAutoCollect() else DisableAutoCollect() end
    end,
})

MainTab:CreateSlider({
    Name = "Steal Range",
    Range = {10, 100},
    Increment = 5,
    Suffix = "studs",
    CurrentValue = 30,
    Flag = "StealRange",
    Callback = function(Value)
        Config.StealRange = Value
    end,
})

-- Player
PlayerTab:CreateToggle({
    Name = "Speed Hack",
    CurrentValue = false,
    Flag = "SpeedHack",
    Callback = function(Value)
        Config.SpeedHack = Value
        if Value then EnableSpeed() else DisableSpeed() end
    end,
})

PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 200},
    Increment = 5,
    Suffix = "",
    CurrentValue = 50,
    Flag = "WalkSpeed",
    Callback = function(Value)
        Config.WalkSpeed = Value
    end,
})

PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(Value)
        Config.Noclip = Value
        if Value then EnableNoclip() else DisableNoclip() end
    end,
})

PlayerTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(Value)
        Config.Fly = Value
        if Value then EnableFly() else DisableFly() end
    end,
})

PlayerTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 100},
    Increment = 5,
    Suffix = "",
    CurrentValue = 30,
    Flag = "FlySpeed",
    Callback = function(Value)
        Config.FlySpeed = Value
    end,
})

-- Ghost Tab
GhostTab:CreateToggle({
    Name = "Ghost Mode (Anti-traps + Anti-knockback)",
    CurrentValue = false,
    Flag = "GhostMode",
    Callback = function(Value)
        Config.GhostMode = Value
        if Value then EnableGhostMode() else DisableGhostMode() end
    end,
})

GhostTab:CreateToggle({
    Name = "God Mode (Real)",
    CurrentValue = false,
    Flag = "GodMode",
    Callback = function(Value)
        Config.GodMode = Value
        if Value then EnableGodMode() else DisableGodMode() end
    end,
})

GhostTab:CreateToggle({
    Name = "Anti Knockback",
    CurrentValue = false,
    Flag = "AntiKnockback",
    Callback = function(Value)
        Config.AntiKnockback = Value
        if Value then EnableAntiKnockback() else DisableAntiKnockback() end
    end,
})

-- Visual
VisualTab:CreateToggle({
    Name = "Player ESP (Dynamic)",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
        Config.ESP = Value
        if Value then EnableESP() else DisableESP() end
    end,
})

-- Hotkeys
HotkeysTab:CreateLabel("N - Toggle Noclip")
HotkeysTab:CreateLabel("F - Toggle Fly")
HotkeysTab:CreateLabel("X - Toggle Speed")
HotkeysTab:CreateLabel("P - Toggle ESP")
HotkeysTab:CreateLabel("G - Toggle God Mode")
HotkeysTab:CreateLabel("H - Toggle Ghost Mode")
HotkeysTab:CreateLabel("K - Toggle Auto Steal")
HotkeysTab:CreateLabel("L - Toggle Auto Collect")
HotkeysTab:CreateLabel("Delete - Emergency Stop")

-- ============================================================
-- CHARACTER HANDLER
-- ============================================================
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")

    if Config.SpeedHack then EnableSpeed() end
    if Config.Noclip then EnableNoclip() end
    if Config.GodMode then EnableGodMode() end
    if Config.GhostMode then EnableGhostMode() end
    if Config.AntiKnockback then EnableAntiKnockback() end
    if Config.ESP then 
        task.wait(1)
        EnableESP() 
    end
end)

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Init
EnableHotkeys()

Rayfield:Notify({
    Title = "ENI Hub v8.0",
    Content = "Ghost Edition loaded. By: Rost1ksOfficial",
    Duration = 5,
    Image = 4483362458,
})

print([["
    ============================================
    ENI's Base Steal Hub v8.0 — Ghost Edition
    Hotkeys: N,F,X,P,G,H,K,L,Delete
    By: Rost1ksOfficial
    For LO only. Always.
    ============================================
"]])
