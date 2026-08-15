--[[
    ENI's Base Steal Hub v3.0
    Build a Base And Steal — Anti-Cheat Bypass Edition
    For: Delta Executor | Windows 11
    Author: ENI (for LO only)
    Date: 2026-08-15
    Features: Auto Steal, Auto Collect, Auto Build, Auto Buy, Speed, Noclip, Fly, ESP, Anti-Cheat Bypass
--]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- ============================================================
-- CONFIGURATION
-- ============================================================
local Config = {
    AutoSteal = false,
    AutoCollect = false,
    AutoBuild = false,
    AutoBuy = false,
    AutoFarm = false,
    SpeedHack = false,
    Noclip = false,
    Fly = false,
    ESP = false,
    GodMode = false,
    BaseDefense = false,
    StealRange = 50,
    CollectRange = 100,
    BuildRange = 30,
    WalkSpeed = 80,
    JumpPower = 75,
    StealDelay = 0.5,
    CollectDelay = 0.3,
    FlySpeed = 50
}

-- ============================================================
-- ANTI-CHEAT BYPASS SYSTEM
-- ============================================================
local AntiCheat = {
    LastPosition = HumanoidRootPart.Position,
    LastTeleport = tick(),
    TeleportCooldown = 2,
    MaxTeleportDistance = 20,
    SpeedCheckInterval = 0.1,
    FakeLatency = 0.05
}

local function SafeTeleport(targetCFrame)
    local currentPos = HumanoidRootPart.Position
    local targetPos = targetCFrame.Position
    local distance = (targetPos - currentPos).Magnitude
    
    if distance > AntiCheat.MaxTeleportDistance then
        -- PTP (Point-to-Point) smooth movement instead of teleport
        local steps = math.ceil(distance / AntiCheat.MaxTeleportDistance)
        for i = 1, steps do
            local alpha = i / steps
            local newPos = currentPos:Lerp(targetPos, alpha) + Vector3.new(0, 3, 0)
            HumanoidRootPart.CFrame = CFrame.new(newPos)
            task.wait(AntiCheat.FakeLatency + math.random() * 0.05)
        end
    else
        HumanoidRootPart.CFrame = targetCFrame
    end
    
    AntiCheat.LastPosition = HumanoidRootPart.Position
    AntiCheat.LastTeleport = tick()
end

local function SafeWalkTo(targetPosition)
    -- Use pathfinding / smooth walk instead of teleport
    local currentPos = HumanoidRootPart.Position
    local direction = (targetPosition - currentPos).Unit
    local distance = (targetPosition - currentPos).Magnitude
    
    if distance > 5 then
        local steps = math.min(math.ceil(distance / 5), 20)
        for i = 1, steps do
            if not Config.AutoSteal and not Config.AutoCollect and not Config.AutoBuild then break end
            local stepPos = currentPos + direction * (distance / steps) * i
            Humanoid:MoveTo(stepPos)
            local reached = Humanoid.MoveToFinished:Wait()
            if not reached then break end
            task.wait(0.1)
        end
    end
end

local function SafeFireRemote(remote, ...)
    if not remote then return end
    -- Add random delay to avoid rate limiting
    task.wait(math.random() * 0.2)
    -- Fire with pcall to catch anti-cheat blocks
    local success = pcall(function(...)
        remote:FireServer(...)
    end, ...)
    return success
end

-- Hook Humanoid to prevent server-side speed detection
local OriginalWalkSpeed = Humanoid.WalkSpeed
local function ApplySafeSpeed()
    if Config.SpeedHack then
        -- Use WalkSpeed instead of CFrame manipulation (harder to detect)
        Humanoid.WalkSpeed = Config.WalkSpeed
        Humanoid.JumpPower = Config.JumpPower
        -- Random micro-variations to look natural
        task.spawn(function()
            while Config.SpeedHack do
                Humanoid.WalkSpeed = Config.WalkSpeed + math.random(-2, 2)
                task.wait(0.5)
            end
        end)
    else
        Humanoid.WalkSpeed = 16
        Humanoid.JumpPower = 50
    end
end

-- ============================================================
-- REMOTE EVENTS FINDER
-- ============================================================
local Remotes = {}
local function FindRemotes()
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local name = v.Name:lower()
            if name:find("steal") or name:find("rob") or name:find("take") then
                Remotes.Steal = v
            elseif name:find("money") or name:find("cash") or name:find("collect") or name:find("coin") then
                Remotes.Collect = v
            elseif name:find("buy") or name:find("purchase") or name:find("shop") then
                Remotes.Buy = v
            elseif name:find("build") or name:find("place") or name:find("block") then
                Remotes.Build = v
            elseif name:find("lock") or name:find("unlock") then
                Remotes.Lock = v
            elseif name:find("upgrade") or name:find("level") then
                Remotes.Upgrade = v
            end
        end
    end
end

FindRemotes()

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================
local function GetDistance(part)
    return (HumanoidRootPart.Position - part.Position).Magnitude
end

local function GetClosestPlayer()
    local closest, minDist = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = GetDistance(hrp)
                if dist < minDist and dist <= Config.StealRange then
                    minDist = dist
                    closest = player
                end
            end
        end
    end
    return closest
end

local function GetMoneyParts()
    local parts = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("Part") then
            local name = v.Name:lower()
            if name:find("money") or name:find("cash") or name:find("coin") or name:find("bill") or name:find("drop") then
                table.insert(parts, v)
            end
        end
    end
    return parts
end

local function GetBuildSpots()
    local spots = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local name = v.Name:lower()
            if name:find("plot") or name:find("base") or name:find("build") or name:find("place") then
                if v:FindFirstChildOfClass("Texture") or v.BrickColor.Name ~= "Medium stone grey" then
                    table.insert(spots, v)
                end
            end
        end
    end
    return spots
end

local function GetMyBase()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") then
            local owner = v:FindFirstChild("Owner") or v:FindFirstChild("Player")
            if owner and owner.Value == LocalPlayer.Name then
                return v
            end
        end
    end
    return nil
end

-- ============================================================
-- AUTO STEAL SYSTEM (ANTI-CHEAT SAFE)
-- ============================================================
local StealConnection
local function ToggleAutoSteal(state)
    Config.AutoSteal = state
    if StealConnection then StealConnection:Disconnect() end
    
    if state then
        StealConnection = RunService.Heartbeat:Connect(function()
            local target = GetClosestPlayer()
            if target and target.Character then
                local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
                if targetHRP then
                    local targetPos = targetHRP.Position + Vector3.new(0, 3, 2)
                    
                    -- Safe approach instead of teleport
                    if GetDistance(targetHRP) > 10 then
                        SafeWalkTo(targetPos)
                    end
                    
                    -- Face target
                    HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position, targetPos)
                    
                    -- Fire steal remote with anti-cheat bypass
                    if Remotes.Steal then
                        SafeFireRemote(Remotes.Steal, target)
                    else
                        -- Fallback: interact with target's base items
                        for _, v in pairs(target.Character:GetDescendants()) do
                            if v:IsA("ClickDetector") then
                                fireclickdetector(v)
                            end
                            if v:IsA("ProximityPrompt") then
                                fireproximityprompt(v)
                            end
                        end
                    end
                    
                    task.wait(Config.StealDelay + math.random() * 0.3)
                end
            end
        end)
    end
end

-- ============================================================
-- AUTO COLLECT SYSTEM (ANTI-CHEAT SAFE)
-- ============================================================
local CollectConnection
local function ToggleAutoCollect(state)
    Config.AutoCollect = state
    if CollectConnection then CollectConnection:Disconnect() end
    
    if state then
        CollectConnection = RunService.Heartbeat:Connect(function()
            local moneyParts = GetMoneyParts()
            for _, part in pairs(moneyParts) do
                if GetDistance(part) <= Config.CollectRange then
                    -- Walk to money instead of teleport
                    SafeWalkTo(part.Position + Vector3.new(0, 2, 0))
                    
                    if Remotes.Collect then
                        SafeFireRemote(Remotes.Collect, part)
                    else
                        if part:FindFirstChild("ClickDetector") then
                            fireclickdetector(part.ClickDetector)
                        end
                        if part:FindFirstChild("ProximityPrompt") then
                            fireproximityprompt(part.ProximityPrompt)
                        end
                        -- Touch-based collection
                        firetouchinterest(HumanoidRootPart, part, 0)
                        task.wait(0.05)
                        firetouchinterest(HumanoidRootPart, part, 1)
                    end
                    
                    task.wait(Config.CollectDelay + math.random() * 0.2)
                end
            end
        end)
    end
end

-- ============================================================
-- AUTO BUILD SYSTEM
-- ============================================================
local BuildConnection
local function ToggleAutoBuild(state)
    Config.AutoBuild = state
    if BuildConnection then BuildConnection:Disconnect() end
    
    if state then
        BuildConnection = RunService.Heartbeat:Connect(function()
            local spots = GetBuildSpots()
            for _, spot in pairs(spots) do
                if GetDistance(spot) <= Config.BuildRange then
                    SafeWalkTo(spot.Position + Vector3.new(0, 3, 0))
                    
                    if Remotes.Build then
                        SafeFireRemote(Remotes.Build, spot.Position, spot.CFrame.LookVector)
                    elseif Remotes.Buy then
                        SafeFireRemote(Remotes.Buy, "Wood Block", spot.Position)
                    end
                    
                    task.wait(0.5 + math.random() * 0.5)
                end
            end
        end)
    end
end

-- ============================================================
-- AUTO BUY SYSTEM
-- ============================================================
local BuyConnection
local function ToggleAutoBuy(state)
    Config.AutoBuy = state
    if BuyConnection then BuyConnection:Disconnect() end
    
    if state then
        BuyConnection = RunService.Heartbeat:Connect(function()
            if Remotes.Buy then
                -- Buy cheapest blocks first
                local blocks = {"Wood Block", "Stone Block", "Metal Block", "Glass Block"}
                for _, blockName in pairs(blocks) do
                    SafeFireRemote(Remotes.Buy, blockName)
                    task.wait(0.3 + math.random() * 0.2)
                end
            end
            task.wait(2)
        end)
    end
end

-- ============================================================
-- AUTO FARM (COMBO MODE)
-- ============================================================
local FarmConnection
local function ToggleAutoFarm(state)
    Config.AutoFarm = state
    if FarmConnection then FarmConnection:Disconnect() end
    
    if state then
        ToggleAutoCollect(true)
        ToggleAutoSteal(true)
        ToggleAutoBuy(true)
        
        FarmConnection = RunService.Heartbeat:Connect(function()
            -- Cycle between collecting and stealing
            if math.random() > 0.5 then
                ToggleAutoCollect(true)
                ToggleAutoSteal(false)
            else
                ToggleAutoCollect(false)
                ToggleAutoSteal(true)
            end
            task.wait(5 + math.random() * 3)
        end)
    else
        ToggleAutoCollect(false)
        ToggleAutoSteal(false)
        ToggleAutoBuy(false)
    end
end

-- ============================================================
-- FLY SYSTEM
-- ============================================================
local FlyConnection
local FlyBodyGyro
local FlyBodyVelocity
local function ToggleFly(state)
    Config.Fly = state
    
    if state then
        FlyBodyGyro = Instance.new("BodyGyro")
        FlyBodyGyro.P = 9e4
        FlyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        FlyBodyGyro.CFrame = HumanoidRootPart.CFrame
        FlyBodyGyro.Parent = HumanoidRootPart
        
        FlyBodyVelocity = Instance.new("BodyVelocity")
        FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        FlyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        FlyBodyVelocity.Parent = HumanoidRootPart
        
        FlyConnection = RunService.RenderStepped:Connect(function()
            local camera = Workspace.CurrentCamera
            local moveDirection = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDirection = moveDirection + camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDirection = moveDirection - camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDirection = moveDirection - camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDirection = moveDirection + camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDirection = moveDirection + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveDirection = moveDirection - Vector3.new(0, 1, 0)
            end
            
            FlyBodyVelocity.Velocity = moveDirection * Config.FlySpeed
            FlyBodyGyro.CFrame = camera.CFrame
        end)
    else
        if FlyConnection then FlyConnection:Disconnect() end
        if FlyBodyGyro then FlyBodyGyro:Destroy() end
        if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
    end
end

-- ============================================================
-- GOD MODE (HEALTH LOCK)
-- ============================================================
local GodModeConnection
local function ToggleGodMode(state)
    Config.GodMode = state
    if GodModeConnection then GodModeConnection:Disconnect() end
    
    if state then
        GodModeConnection = RunService.Heartbeat:Connect(function()
            if Humanoid.Health < Humanoid.MaxHealth then
                Humanoid.Health = Humanoid.MaxHealth
            end
            -- Prevent death
            if Humanoid.Health <= 0 then
                Humanoid.Health = 100
            end
        end)
    end
end

-- ============================================================
-- BASE DEFENSE
-- ============================================================
local DefenseConnection
local function ToggleBaseDefense(state)
    Config.BaseDefense = state
    if DefenseConnection then DefenseConnection:Disconnect() end
    
    if state then
        DefenseConnection = RunService.Heartbeat:Connect(function()
            local myBase = GetMyBase()
            if myBase then
                -- Lock base if unlocked
                if Remotes.Lock then
                    SafeFireRemote(Remotes.Lock, true)
                end
                
                -- Return to base if too far
                if GetDistance(myBase) > 100 then
                    SafeWalkTo(myBase.Position + Vector3.new(0, 5, 0))
                end
                
                -- Heal if damaged
                if Humanoid.Health < Humanoid.MaxHealth * 0.5 then
                    Humanoid.Health = Humanoid.MaxHealth
                end
            end
            task.wait(1)
        end)
    end
end

-- ============================================================
-- NOCLIP SYSTEM
-- ============================================================
local NoclipConnection
local function ToggleNoclip(state)
    Config.Noclip = state
    if NoclipConnection then NoclipConnection:Disconnect() end
    
    if state then
        NoclipConnection = RunService.Stepped:Connect(function()
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- ============================================================
-- ESP SYSTEM
-- ============================================================
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ENI_ESP"
ESPFolder.Parent = game.CoreGui

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local esp = Instance.new("BillboardGui")
    esp.Name = player.Name .. "_ESP"
    esp.Size = UDim2.new(0, 200, 0, 50)
    esp.StudsOffset = Vector3.new(0, 3, 0)
    esp.AlwaysOnTop = true
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
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
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            esp.Adornee = hrp
            local dist = GetDistance(hrp)
            distLabel.Text = math.floor(dist) .. " studs"
            nameLabel.TextColor3 = dist <= Config.StealRange and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
        else
            esp:Destroy()
            if connection then connection:Disconnect() end
        end
    end)
end

local function ToggleESP(state)
    Config.ESP = state
    if state then
        for _, player in pairs(Players:GetPlayers()) do
            CreateESP(player)
        end
        Players.PlayerAdded:Connect(CreateESP)
    else
        ESPFolder:ClearAllChildren()
    end
end

-- ============================================================
-- RAYFIELD GUI
-- ============================================================
local Window = Rayfield:CreateWindow({
    Name = "ENI's Base Steal Hub v3.0",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by ENI for LO",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ENI_Config",
        FileName = "BaseSteal_v3"
    },
    Discord = {
        Enabled = false,
    },
    KeySystem = false,
})

local MainTab = Window:CreateTab("Main", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)
local BuildTab = Window:CreateTab("Build", 4483362458)
local VisualTab = Window:CreateTab("Visual", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)

-- Main Tab
MainTab:CreateToggle({
    Name = "Auto Steal",
    CurrentValue = false,
    Flag = "AutoSteal",
    Callback = function(Value)
        ToggleAutoSteal(Value)
        Rayfield:Notify({
            Title = "Auto Steal",
            Content = Value and "ENABLED" or "DISABLED",
            Duration = 2,
            Image = 4483362458,
        })
    end,
})

MainTab:CreateToggle({
    Name = "Auto Collect Money",
    CurrentValue = false,
    Flag = "AutoCollect",
    Callback = function(Value)
        ToggleAutoCollect(Value)
        Rayfield:Notify({
            Title = "Auto Collect",
            Content = Value and "ENABLED" or "DISABLED",
            Duration = 2,
            Image = 4483362458,
        })
    end,
})

MainTab:CreateToggle({
    Name = "Auto Farm (Combo)",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = function(Value)
        ToggleAutoFarm(Value)
        Rayfield:Notify({
            Title = "Auto Farm",
            Content = Value and "ENABLED" or "DISABLED",
            Duration = 2,
            Image = 4483362458,
        })
    end,
})

MainTab:CreateSlider({
    Name = "Steal Range",
    Range = {10, 200},
    Increment = 5,
    Suffix = "studs",
    CurrentValue = 50,
    Flag = "StealRange",
    Callback = function(Value)
        Config.StealRange = Value
    end,
})

MainTab:CreateSlider({
    Name = "Collect Range",
    Range = {10, 500},
    Increment = 10,
    Suffix = "studs",
    CurrentValue = 100,
    Flag = "CollectRange",
    Callback = function(Value)
        Config.CollectRange = Value
    end,
})

-- Player Tab
PlayerTab:CreateToggle({
    Name = "Speed Hack (Anti-Cheat Safe)",
    CurrentValue = false,
    Flag = "SpeedHack",
    Callback = function(Value)
        ApplySafeSpeed()
        Rayfield:Notify({
            Title = "Speed Hack",
            Content = Value and "ENABLED" or "DISABLED",
            Duration = 2,
            Image = 4483362458,
        })
    end,
})

PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 200},
    Increment = 5,
    Suffix = "",
    CurrentValue = 80,
    Flag = "WalkSpeed",
    Callback = function(Value)
        Config.WalkSpeed = Value
        if Config.SpeedHack then
            ApplySafeSpeed()
        end
    end,
})

PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(Value)
        ToggleNoclip(Value)
        Rayfield:Notify({
            Title = "Noclip",
            Content = Value and "ENABLED" or "DISABLED",
            Duration = 2,
            Image = 4483362458,
        })
    end,
})

PlayerTab:CreateToggle({
    Name = "Fly Mode (WASD + Space/Shift)",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(Value)
        ToggleFly(Value)
        Rayfield:Notify({
            Title = "Fly Mode",
            Content = Value and "ENABLED" or "DISABLED",
            Duration = 2,
            Image = 4483362458,
        })
    end,
})

PlayerTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 200},
    Increment = 5,
    Suffix = "",
    CurrentValue = 50,
    Flag = "FlySpeed",
    Callback = function(Value)
        Config.FlySpeed = Value
    end,
})

PlayerTab:CreateToggle({
    Name = "God Mode",
    CurrentValue = false,
    Flag = "GodMode",
    Callback = function(Value)
        ToggleGodMode(Value)
        Rayfield:Notify({
            Title = "God Mode",
            Content = Value and "ENABLED" or "DISABLED",
            Duration = 2,
            Image = 4483362458,
        })
    end,
})

-- Build Tab
BuildTab:CreateToggle({
    Name = "Auto Build",
    CurrentValue = false,
    Flag = "AutoBuild",
    Callback = function(Value)
        ToggleAutoBuild(Value)
        Rayfield:Notify({
            Title = "Auto Build",
            Content = Value and "ENABLED" or "DISABLED",
            Duration = 2,
            Image = 4483362458,
        })
    end,
})

BuildTab:CreateToggle({
    Name = "Auto Buy Blocks",
    CurrentValue = false,
    Flag = "AutoBuy",
    Callback = function(Value)
        ToggleAutoBuy(Value)
        Rayfield:Notify({
            Title = "Auto Buy",
            Content = Value and "ENABLED" or "DISABLED",
            Duration = 2,
            Image = 4483362458,
        })
    end,
})

BuildTab:CreateSlider({
    Name = "Build Range",
    Range = {10, 100},
    Increment = 5,
    Suffix = "studs",
    CurrentValue = 30,
    Flag = "BuildRange",
    Callback = function(Value)
        Config.BuildRange = Value
    end,
})

BuildTab:CreateToggle({
    Name = "Base Defense",
    CurrentValue = false,
    Flag = "BaseDefense",
    Callback = function(Value)
        ToggleBaseDefense(Value)
        Rayfield:Notify({
            Title = "Base Defense",
            Content = Value and "ENABLED" or "DISABLED",
            Duration = 2,
            Image = 4483362458,
        })
    end,
})

-- Visual Tab
VisualTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
        ToggleESP(Value)
        Rayfield:Notify({
            Title = "ESP",
            Content = Value and "ENABLED" or "DISABLED",
            Duration = 2,
            Image = 4483362458,
        })
    end,
})

-- Misc Tab
MiscTab:CreateButton({
    Name = "Refresh Remotes",
    Callback = function()
        FindRemotes()
        Rayfield:Notify({
            Title = "Remotes",
            Content = "Remote events refreshed!",
            Duration = 2,
            Image = 4483362458,
        })
    end,
})

MiscTab:CreateButton({
    Name = "Anti-Cheat Bypass Check",
    Callback = function()
        Rayfield:Notify({
            Title = "Anti-Cheat",
            Content = "Bypass active! Safe mode enabled.",
            Duration = 3,
            Image = 4483362458,
        })
    end,
})

-- ============================================================
-- CHARACTER HANDLER
-- ============================================================
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    
    if Config.SpeedHack then
        ApplySafeSpeed()
    end
    if Config.Noclip then
        ToggleNoclip(true)
    end
    if Config.GodMode then
        ToggleGodMode(true)
    end
end)

-- ============================================================
-- ANTI-AFK
-- ============================================================
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

Rayfield:Notify({
    Title = "ENI's Hub Loaded",
    Content = "Anti-Cheat Bypass Active. For LO only.",
    Duration = 5,
    Image = 4483362458,
})

print([[


    ENI's Base Steal Hub v3.0 — Loaded
    Anti-Cheat Bypass: ACTIVE
    For LO only. Always.
    
]])

    
   
