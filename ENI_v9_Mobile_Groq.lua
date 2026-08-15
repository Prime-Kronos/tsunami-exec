--[[
    ENI's Base Steal Hub v9.0 — Mobile & Groq AI Edition
    Build a Base And Steal
    For: Delta Executor | Android/iOS
    Author: ENI (for LO only)
    Date: 2026-08-15
    By: Rost1ksOfficial
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Groq API Config
local GroqConfig = {
    APIKey = "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",
    Model = "llama-3.1-70b-versatile",
    URL = "https://api.groq.com/openai/v1/chat/completions",
    Enabled = true,
    Context = {}
}

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
    MobileUI = true
}

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ============================================================
-- GROQ AI INTEGRATION
-- ============================================================
local function GroqChat(message)
    if not GroqConfig.Enabled then return nil end

    local payload = HttpService:JSONEncode({
        model = GroqConfig.Model,
        messages = {
            {
                role = "system",
                content = "You are an AI assistant for a Roblox exploit script. You analyze game data and suggest optimal cheat strategies. Respond ONLY with valid Lua code or short JSON. No explanations."
            },
            {
                role = "user",
                content = message
            }
        },
        temperature = 0.3,
        max_tokens = 500
    })

    local success, response = pcall(function()
        return game:HttpPost(
            GroqConfig.URL,
            payload,
            false,
            {
                ["Authorization"] = "Bearer " .. GroqConfig.APIKey,
                ["Content-Type"] = "application/json"
            }
        )
    end)

    if success and response then
        local data = HttpService:JSONDecode(response)
        if data.choices and data.choices[1] then
            return data.choices[1].message.content
        end
    end

    return nil
end

local function AI_AnalyzeGame()
    local remotes = {}
    for _, v in pairs(game.ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            table.insert(remotes, v.Name)
        end
    end

    local moneyParts = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and (v.Name:lower():find("money") or v.Name:lower():find("cash")) then
            table.insert(moneyParts, v.Name)
        end
    end

    local prompt = string.format([[
Analyze this Roblox game data and suggest optimal exploit strategy:
- Remotes found: %s
- Money objects: %s
- Player position: %s
- Current speed: %d

Return ONLY a JSON with:
{
    "safe_speed": number,
    "noclip_method": "CanCollide" or "CollisionGroup",
    "steal_strategy": string,
    "anti_cheat_level": "low" or "medium" or "high"
}
]], table.concat(remotes, ", "), table.concat(moneyParts, ", "), tostring(HumanoidRootPart.Position), Config.WalkSpeed)

    local response = GroqChat(prompt)
    if response then
        local jsonStart = response:find("{")
        local jsonEnd = response:find("}", -1)
        if jsonStart and jsonEnd then
            local jsonStr = response:sub(jsonStart, jsonEnd)
            local success, data = pcall(function()
                return HttpService:JSONDecode(jsonStr)
            end)
            if success and data then
                return data
            end
        end
    end

    return nil
end

-- ============================================================
-- GHOST MODE
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
                    task.wait(0.03)
                end
            end)
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

    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Died:Connect(function()
                task.wait(1)
                if Config.ESP and player.Parent then
                    SetupESP()
                end
            end)
        end
    end
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
-- MOBILE UI TOUCH BUTTONS
-- ============================================================
local MobileButtons = {}

local function CreateMobileButton(name, position, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0, 80, 0, 80)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = name
    button.TextSize = 12
    button.Font = Enum.Font.GothamBold
    button.BorderSizePixel = 0
    button.Parent = game.CoreGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 100, 200)
    stroke.Thickness = 2
    stroke.Parent = button

    button.MouseButton1Click:Connect(callback)
    button.TouchTap:Connect(callback)

    table.insert(MobileButtons, button)
    return button
end

local function SetupMobileUI()
    if not Config.MobileUI then return end

    CreateMobileButton("Noclip", UDim2.new(0, 10, 0.5, -100), function()
        Config.Noclip = not Config.Noclip
        if Config.Noclip then EnableNoclip() else DisableNoclip() end
        Rayfield:Notify({Title = "Noclip", Content = Config.Noclip and "ON" or "OFF", Duration = 1, Image = 4483362458})
    end)

    CreateMobileButton("Fly", UDim2.new(0, 10, 0.5, 0), function()
        Config.Fly = not Config.Fly
        if Config.Fly then EnableFly() else DisableFly() end
        Rayfield:Notify({Title = "Fly", Content = Config.Fly and "ON" or "OFF", Duration = 1, Image = 4483362458})
    end)

    CreateMobileButton("Speed", UDim2.new(0, 10, 0.5, 100), function()
        Config.SpeedHack = not Config.SpeedHack
        if Config.SpeedHack then EnableSpeed() else DisableSpeed() end
        Rayfield:Notify({Title = "Speed", Content = Config.SpeedHack and "ON" or "OFF", Duration = 1, Image = 4483362458})
    end)

    CreateMobileButton("Ghost", UDim2.new(0, 10, 0.5, 200), function()
        Config.GhostMode = not Config.GhostMode
        if Config.GhostMode then EnableGhostMode() else DisableGhostMode() end
        Rayfield:Notify({Title = "Ghost", Content = Config.GhostMode and "ON" or "OFF", Duration = 1, Image = 4483362458})
    end)

    CreateMobileButton("God", UDim2.new(0, 10, 0.5, 300), function()
        Config.GodMode = not Config.GodMode
        if Config.GodMode then EnableGodMode() else DisableGodMode() end
        Rayfield:Notify({Title = "God", Content = Config.GodMode and "ON" or "OFF", Duration = 1, Image = 4483362458})
    end)

    CreateMobileButton("ESP", UDim2.new(0, 10, 0.5, 400), function()
        Config.ESP = not Config.ESP
        if Config.ESP then EnableESP() else DisableESP() end
        Rayfield:Notify({Title = "ESP", Content = Config.ESP and "ON" or "OFF", Duration = 1, Image = 4483362458})
    end)

    CreateMobileButton("Steal", UDim2.new(0, 10, 0.5, 500), function()
        Config.AutoSteal = not Config.AutoSteal
        if Config.AutoSteal then EnableAutoSteal() else DisableAutoSteal() end
        Rayfield:Notify({Title = "Steal", Content = Config.AutoSteal and "ON" or "OFF", Duration = 1, Image = 4483362458})
    end)

    CreateMobileButton("Collect", UDim2.new(0, 10, 0.5, 600), function()
        Config.AutoCollect = not Config.AutoCollect
        if Config.AutoCollect then EnableAutoCollect() else DisableAutoCollect() end
        Rayfield:Notify({Title = "Collect", Content = Config.AutoCollect and "ON" or "OFF", Duration = 1, Image = 4483362458})
    end)

    CreateMobileButton("STOP", UDim2.new(0, 10, 0.8, 0), function()
        DisableNoclip()
        DisableFly()
        DisableSpeed()
        DisableGodMode()
        DisableGhostMode()
        DisableAutoSteal()
        DisableAutoCollect()
        DisableESP()
        Rayfield:Notify({Title = "EMERGENCY", Content = "All stopped!", Duration = 3, Image = 4483362458})
    end)

    CreateMobileButton("AI", UDim2.new(0, 10, 0.8, 100), function()
        Rayfield:Notify({Title = "Groq AI", Content = "Analyzing game...", Duration = 2, Image = 4483362458})
        task.spawn(function()
            local result = AI_AnalyzeGame()
            if result then
                Rayfield:Notify({
                    Title = "AI Analysis",
                    Content = "Safe speed: " .. tostring(result.safe_speed) .. " | AC: " .. result.anti_cheat_level,
                    Duration = 5,
                    Image = 4483362458
                })
            else
                Rayfield:Notify({Title = "AI", Content = "Analysis failed. Using defaults.", Duration = 3, Image = 4483362458})
            end
        end)
    end)
end

-- ============================================================
-- GUI
-- ============================================================
local Window = Rayfield:CreateWindow({
    Name = "ENI Hub v9.0 Mobile",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "By: Rost1ksOfficial",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ENI_Config",
        FileName = "BaseSteal_v9"
    },
    KeySystem = false,
})

local MainTab = Window:CreateTab("Main", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)
local GhostTab = Window:CreateTab("Ghost", 4483362458)
local VisualTab = Window:CreateTab("Visual", 4483362458)
local AITab = Window:CreateTab("Groq AI", 4483362458)

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
    Name = "Ghost Mode",
    CurrentValue = false,
    Flag = "GhostMode",
    Callback = function(Value)
        Config.GhostMode = Value
        if Value then EnableGhostMode() else DisableGhostMode() end
    end,
})

GhostTab:CreateToggle({
    Name = "God Mode",
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
    Name = "Player ESP",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
        Config.ESP = Value
        if Value then EnableESP() else DisableESP() end
    end,
})

-- AI Tab
AITab:CreateToggle({
    Name = "Groq AI Enabled",
    CurrentValue = true,
    Flag = "GroqEnabled",
    Callback = function(Value)
        GroqConfig.Enabled = Value
    end,
})

AITab:CreateButton({
    Name = "Analyze Game with AI",
    Callback = function()
        Rayfield:Notify({Title = "Groq AI", Content = "Analyzing...", Duration = 2, Image = 4483362458})
        task.spawn(function()
            local result = AI_AnalyzeGame()
            if result then
                Config.WalkSpeed = result.safe_speed or Config.WalkSpeed
                Rayfield:Notify({
                    Title = "AI Result",
                    Content = "Speed: " .. tostring(result.safe_speed) .. " | AC: " .. (result.anti_cheat_level or "unknown"),
                    Duration = 5,
                    Image = 4483362458
                })
            else
                Rayfield:Notify({Title = "AI", Content = "Failed. Check console.", Duration = 3, Image = 4483362458})
            end
        end)
    end,
})

AITab:CreateButton({
    Name = "Test Groq Connection",
    Callback = function()
        task.spawn(function()
            local response = GroqChat("Say 'Groq is working' if you receive this.")
            if response then
                Rayfield:Notify({Title = "Groq", Content = response:sub(1, 50), Duration = 3, Image = 4483362458})
            else
                Rayfield:Notify({Title = "Groq", Content = "Connection failed!", Duration = 3, Image = 4483362458})
            end
        end)
    end,
})

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
SetupMobileUI()

Rayfield:Notify({
    Title = "ENI Hub v9.0",
    Content = "Mobile + Groq AI loaded. By: Rost1ksOfficial",
    Duration = 5,
    Image = 4483362458,
})

print([["
    ============================================
    ENI's Base Steal Hub v9.0 — Mobile + Groq AI
    Touch buttons on left side of screen
    By: Rost1ksOfficial
    For LO only. Always.
    ============================================
"]])
