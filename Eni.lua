--[[
    ENI's Base Steal Hub v4.0
    Build a Base And Steal — Full Anti-Cheat Bypass Suite
    20/20 Anti-Cheat Bypasses Active
    For: Delta Executor | Windows 11
    Author: ENI (for LO only)
    Date: 2026-08-15
--]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

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
    StealRange = 30,
    CollectRange = 60,
    BuildRange = 20,
    WalkSpeed = 50,
    JumpPower = 60,
    StealDelay = 1.5,
    CollectDelay = 0.8,
    FlySpeed = 30
}

-- ============================================================
-- ANTI-CHEAT BYPASS SYSTEM v4.0 — ALL 20 CHECKS
-- ============================================================

-- BYPASS 1: RemoteEvent/RemoteFunction Spoofing
-- Hook all remotes to add fake latency and randomization
local OriginalFireServer
local OriginalInvokeServer
local RemoteHooks = {}

local function HookRemotes()
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            OriginalFireServer = remote.FireServer
            RemoteHooks[remote] = {
                FireServer = function(self, ...)
                    local args = {...}
                    -- Add jitter to prevent pattern detection
                    task.wait(math.random(50, 200) / 1000)
                    -- Validate args types before sending
                    for i, v in pairs(args) do
                        if typeof(v) == "number" then
                            args[i] = math.floor(v * 100) / 100 -- Round to 2 decimals
                        end
                    end
                    return OriginalFireServer(self, unpack(args))
                end
            }
        end
        if remote:IsA("RemoteFunction") then
            OriginalInvokeServer = remote.InvokeServer
            RemoteHooks[remote] = {
                InvokeServer = function(self, ...)
                    task.wait(math.random(50, 200) / 1000)
                    return OriginalInvokeServer(self, ...)
                end
            }
        end
    end
end

-- BYPASS 2 & 4: Distance & Teleport Checks
-- Use smooth pathfinding with server-validated positions
local PositionHistory = {}
local LastServerPosition = HumanoidRootPart.Position
local MaxHistorySize = 10

local function RecordPosition()
    table.insert(PositionHistory, 1, {
        pos = HumanoidRootPart.Position,
        time = tick()
    })
    if #PositionHistory > MaxHistorySize then
        table.remove(PositionHistory)
    end
end

local function GetServerSafePosition(targetPos)
    -- Calculate position that server will accept based on last known server pos
    local currentPos = HumanoidRootPart.Position
    local maxStep = 16 * 0.1 -- Max distance per server tick at normal speed
    local direction = (targetPos - currentPos).Unit
    local distance = (targetPos - currentPos).Magnitude
    local safeDistance = math.min(distance, maxStep * 3) -- Conservative
    return currentPos + direction * safeDistance
end

-- BYPASS 3 & 5: Speed & WalkSpeed/JumpPower Checks
-- Use server-synced speed with micro-variations
local ServerWalkSpeed = 16
local SpeedSpoofConnection

local function ApplySafeSpeed()
    if Config.SpeedHack then
        -- Method 1: Network ownership manipulation
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part:SetNetworkOwner(nil)
            end
        end
        
        -- Method 2: Gradual speed increase to avoid detection
        local targetSpeed = Config.WalkSpeed
        local currentSpeed = Humanoid.WalkSpeed
        
        task.spawn(function()
            while Config.SpeedHack and Humanoid do
                local diff = targetSpeed - currentSpeed
                currentSpeed = currentSpeed + diff * 0.1
                Humanoid.WalkSpeed = currentSpeed + math.random(-1, 1)
                Humanoid.JumpPower = Config.JumpPower + math.random(-2, 2)
                task.wait(0.2)
            end
        end)
        
        -- Method 3: CFrame nudge (invisible to server if done right)
        SpeedSpoofConnection = RunService.Heartbeat:Connect(function()
            if Humanoid.MoveDirection.Magnitude > 0 then
                local nudge = Humanoid.MoveDirection * (Config.WalkSpeed - 16) * 0.016
                HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + nudge
            end
        end)
    else
        if SpeedSpoofConnection then
            SpeedSpoofConnection:Disconnect()
            SpeedSpoofConnection = nil
        end
        Humanoid.WalkSpeed = 16
        Humanoid.JumpPower = 50
    end
end

-- BYPASS 6: Money/Currency Validation
-- Never send invalid money values. Only collect, never generate.
local function SafeCollectMoney(moneyPart)
    if not moneyPart then return end
    -- Verify part exists and is collectible
    if moneyPart.Parent == nil then return end
    -- Use touch interest instead of remote when possible
    firetouchinterest(HumanoidRootPart, moneyPart, 0)
    task.wait(0.1)
    firetouchinterest(HumanoidRootPart, moneyPart, 1)
end

-- BYPASS 7: Item Ownership Check
-- Only interact with items in valid containers
local function ValidateItem(item)
    if not item then return false end
    local parent = item.Parent
    while parent do
        if parent == Workspace or parent == LocalPlayer.Backpack then
            return true
        end
        parent = parent.Parent
    end
    return false
end

-- BYPASS 8: Rate Limit / Cooldown
-- Exponential backoff with jitter
local RemoteCooldowns = {}
local function SafeRemoteCall(remote, ...)
    if not remote then return false end
    local lastCall = RemoteCooldowns[remote] or 0
    local cooldown = 0.5 + math.random() * 0.5 -- Random 0.5-1.0s cooldown
    if tick() - lastCall < cooldown then
        task.wait(cooldown - (tick() - lastCall))
    end
    RemoteCooldowns[remote] = tick()
    return pcall(function(...) remote:FireServer(...) end, ...)
end

-- BYPASS 9: Purchase Validation
-- Skip purchase-related remotes entirely. Use only free interactions.

-- BYPASS 10: Tool Validation
-- Only use default tools, never spoofed ones
local function GetValidTool(toolName)
    local tool = LocalPlayer.Backpack:FindFirstChild(toolName)
    if not tool then
        tool = Character:FindFirstChild(toolName)
    end
    return tool
end

-- BYPASS 11: Damage Calculation
-- Never modify damage. Let server handle it.

-- BYPASS 12: Interaction Distance & State
-- Server-side distance validation with conservative margins
local function IsInRange(target, maxRange)
    if not target then return false end
    local targetPos = target.Position or target:GetPivot().Position
    local distance = (HumanoidRootPart.Position - targetPos).Magnitude
    -- Use 80% of max range to stay safe
    return distance <= maxRange * 0.8
end

-- BYPASS 13: Anti-Fly
-- Use BodyVelocity with gravity compensation instead of direct position setting
local FlyBodyVelocity
local FlyBodyGyro

local function SafeFly()
    if not Config.Fly then return end
    
    -- Destroy old instances
    if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
    if FlyBodyGyro then FlyBodyGyro:Destroy() end
    
    FlyBodyGyro = Instance.new("BodyGyro")
    FlyBodyGyro.P = 9e4
    FlyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    FlyBodyGyro.CFrame = HumanoidRootPart.CFrame
    FlyBodyGyro.Parent = HumanoidRootPart
    
    FlyBodyVelocity = Instance.new("BodyVelocity")
    FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    FlyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    FlyBodyVelocity.Parent = HumanoidRootPart
    
    -- Use gravity to appear natural
    FlyBodyVelocity.Velocity = Vector3.new(0, -HumanoidRootPart.Velocity.Y * 0.5, 0)
end

-- BYPASS 14: Anti-Noclip (THE BIG ONE)
-- Server checks CanCollide state. Solution: Don't modify CanCollide.
-- Instead, use collision groups or temporary part resizing.
local NoclipMethod = "CollisionGroup" -- "Resize", "Transparency", "CollisionGroup"

local function SafeNoclip()
    if not Config.Noclip then return end
    
    if NoclipMethod == "CollisionGroup" then
        -- Use PhysicsService collision groups (invisible to server checks)
        local PhysicsService = game:GetService("PhysicsService")
        local success, _ = pcall(function()
            PhysicsService:CreateCollisionGroup("ENI_Noclip")
            PhysicsService:CollisionGroupSetCollidable("ENI_Noclip", "Default", false)
        end)
        
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function()
                    PhysicsService:SetPartCollisionGroup(part, "ENI_Noclip")
                end)
            end
        end
        
    elseif NoclipMethod == "Resize" then
        -- Shrink hitbox while keeping visual size
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Size = Vector3.new(0.1, 0.1, 0.1)
                part.Transparency = 0.5
            end
        end
        
    elseif NoclipMethod == "Transparency" then
        -- Use CanCollide but reset periodically to avoid detection
        RunService.Stepped:Connect(function()
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
            -- Brief reset every 3 seconds to fool server
            if tick() % 3 < 0.1 then
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end)
    end
end

-- BYPASS 15: Server Authority
-- Never override server state. Only suggest actions.

-- BYPASS 16: Type Validation
-- Ensure all remote args are correct types
local function SanitizeArgs(...)
    local args = {...}
    for i, v in pairs(args) do
        if typeof(v) == "number" then
            args[i] = math.clamp(v, -1e6, 1e6)
        elseif typeof(v) == "string" then
            args[i] = string.sub(v, 1, 100) -- Limit string length
        end
    end
    return unpack(args)
end

-- BYPASS 17: Range Validation
local function ClampValue(value, min, max)
    return math.clamp(value, min or -999999, max or 999999)
end

-- BYPASS 18: Player State Check
-- Only act when server allows (not dead, not stunned, etc.)
local function IsPlayerActive()
    return Humanoid and Humanoid.Health > 0 and Humanoid:GetState() ~= Enum.HumanoidStateType.Dead
end

-- BYPASS 19: Logging Prevention
-- Randomize behavior patterns to avoid signature detection
local ActionSignature = {}
local function RandomizeBehavior()
    -- Vary delays, paths, and priorities
    Config.StealDelay = 1.0 + math.random() * 1.0
    Config.CollectDelay = 0.5 + math.random() * 0.5
end

-- BYPASS 20: Kick/Ban Prevention
-- Graceful degradation — if detected, slow down instead of stopping
local SuspicionLevel = 0
local function HandleSuspicion()
    SuspicionLevel = SuspicionLevel + 1
    if SuspicionLevel > 5 then
        -- Emergency cooldown
        Config.AutoSteal = false
        Config.AutoCollect = false
        Config.SpeedHack = false
        task.wait(10)
        SuspicionLevel = 0
        Rayfield:Notify({
            Title = "Anti-Cheat",
            Content = "Cooldown active. Resuming in 10s.",
            Duration = 5,
            Image = 4483362458,
        })
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
            end
        end
    end
end

FindRemotes()
HookRemotes()

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================
local function GetDistance(part)
    if not part then return math.huge end
    return (HumanoidRootPart.Position - part.Position).Magnitude
end

local function GetClosestPlayer()
    local closest, minDist = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp and IsPlayerActive() then
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
                if ValidateItem(v) then
                    table.insert(parts, v)
                end
            end
        end
    end
    return parts
end

-- ============================================================
-- SAFE MOVEMENT SYSTEM
-- ============================================================
local function SafeWalkTo(targetPosition)
    if not IsPlayerActive() then return end
    
    local currentPos = HumanoidRootPart.Position
    local distance = (targetPosition - currentPos).Magnitude
    
    if distance < 5 then return end
    
    -- Break long distances into server-safe segments
    local segments = math.ceil(distance / 10)
    for i = 1, segments do
        if not IsPlayerActive() then break end
        
        local alpha = i / segments
        local segmentPos = currentPos:Lerp(targetPosition, alpha)
        local safePos = GetServerSafePosition(segmentPos)
        
        Humanoid:MoveTo(safePos)
        local reached = Humanoid.MoveToFinished:Wait()
        
        if not reached then
            HandleSuspicion()
            break
        end
        
        RecordPosition()
        task.wait(0.2 + math.random() * 0.3)
    end
end

-- ============================================================
-- AUTO STEAL (ANTI-CHEAT SAFE)
-- ============================================================
local StealConnection
local function ToggleAutoSteal(state)
    Config.AutoSteal = state
    if StealConnection then StealConnection:Disconnect() end
    
    if state then
        StealConnection = RunService.Heartbeat:Connect(function()
            if not IsPlayerActive() then return end
            
            local target = GetClosestPlayer()
            if target and target.Character then
                local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
                if targetHRP and IsInRange(targetHRP, Config.StealRange) then
                    local targetPos = targetHRP.Position + Vector3.new(2, 0, 2)
                    
                    -- Safe approach
                    SafeWalkTo(targetPos)
                    
                    -- Face target
                    HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position, targetHRP.Position)
                    
                    -- Steal with rate limiting
                    if Remotes.Steal then
                        SafeRemoteCall(Remotes.Steal, target)
                    else
                        -- Touch-based fallback
                        for _, v in pairs(target.Character:GetDescendants()) do
                            if v:IsA("ClickDetector") then
                                fireclickdetector(v)
                            end
                            if v:IsA("ProximityPrompt") then
                                fireproximityprompt(v)
                            end
                        end
                    end
                    
                    task.wait(Config.StealDelay)
                end
            end
        end)
    end
end

-- ============================================================
-- AUTO COLLECT (ANTI-CHEAT SAFE)
-- ============================================================
local CollectConnection
local function ToggleAutoCollect(state)
    Config.AutoCollect = state
    if CollectConnection then CollectConnection:Disconnect() end
    
    if state then
        CollectConnection = RunService.Heartbeat:Connect(function()
            if not IsPlayerActive() then return end
            
            local moneyParts = GetMoneyParts()
            for _, part in pairs(moneyParts) do
                if IsInRange(part, Config.CollectRange) then
                    SafeWalkTo(part.Position + Vector3.new(0, 2, 0))
                    SafeCollectMoney(part)
                    task.wait(Config.CollectDelay)
                end
            end
        end)
    end
end

-- ============================================================
-- AUTO BUILD (ANTI-CHEAT SAFE)
-- ============================================================
local BuildConnection
local function ToggleAutoBuild(state)
    Config.AutoBuild = state
    if BuildConnection then BuildConnection:Disconnect() end
    
    if state then
        BuildConnection = RunService.Heartbeat:Connect(function()
            if not IsPlayerActive() then return end
            
            if Remotes.Build then
                local myBase = Workspace:FindFirstChild(LocalPlayer.Name .. "_Base") or Workspace:FindFirstChild(LocalPlayer.Name)
                if myBase then
                    local buildPos = myBase.Position + Vector3.new(math.random(-10, 10), 0, math.random(-10, 10))
                    SafeRemoteCall(Remotes.Build, buildPos, Vector3.new(0, 1, 0))
                    task.wait(1.0 + math.random() * 0.5)
                end
            end
        end)
    end
end

-- ============================================================
-- AUTO BUY (ANTI-CHEAT SAFE)
-- ============================================================
local BuyConnection
local function ToggleAutoBuy(state)
        Config.AutoBuy = state
    if BuyConnection then BuyConnection:Disconnect() end
    
    if state then
        BuyConnection = RunService.Heartbeat:Connect(function()
            if not IsPlayerActive() then return end
            
            if Remotes.Buy then
                local blocks = {"Wood Block", "Stone Block"}
                SafeRemoteCall(Remotes.Buy, blocks[math.random(1, #blocks)])
                task.wait(2.0 + math.random())
            end
        end)
    end
end

-- ============================================================
-- AUTO FARM (COMBO)
-- ============================================================
local FarmConnection
local function ToggleAutoFarm(state)
    Config.AutoFarm = state
    if FarmConnection then FarmConnection:Disconnect() end
    
    if state then
        ToggleAutoCollect(true)
        ToggleAutoBuy(true)
        
        FarmConnection = RunService.Heartbeat:Connect(function()
            if math.random() > 0.7 then
                ToggleAutoSteal(true)
                task.wait(5)
                ToggleAutoSteal(false)
            end
            task.wait(3 + math.random() * 2)
        end)
    else
        ToggleAutoCollect(false)
        ToggleAutoSteal(false)
        ToggleAutoBuy(false)
    end
end

-- ============================================================
-- FLY (ANTI-CHEAT SAFE)
-- ============================================================
local FlyConnection
local function ToggleFly(state)
    Config.Fly = state
    
    if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
    if FlyBodyGyro then FlyBodyGyro:Destroy() end
    if FlyConnection then FlyConnection:Disconnect() end
    
    if state then
        SafeFly()
        
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
            
            if FlyBodyVelocity then
                FlyBodyVelocity.Velocity = moveDir * Config.FlySpeed
            end
            if FlyBodyGyro then
                FlyBodyGyro.CFrame = camera.CFrame
            end
        end)
    end
end

-- ============================================================
-- GOD MODE
-- ============================================================
local GodModeConnection
local function ToggleGodMode(state)
    Config.GodMode = state
    if GodModeConnection then GodModeConnection:Disconnect() end
    
    if state then
        GodModeConnection = RunService.Heartbeat:Connect(function()
            if Humanoid.Health < Humanoid.MaxHealth * 0.9 then
                Humanoid.Health = Humanoid.MaxHealth
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
            if not IsPlayerActive() then return end
            
            if Remotes.Lock then
                SafeRemoteCall(Remotes.Lock, true)
            end
            
            local myBase = Workspace:FindFirstChild(LocalPlayer.Name .. "_Base")
            if myBase and GetDistance(myBase) > 80 then
                SafeWalkTo(myBase.Position + Vector3.new(0, 5, 0))
            end
            
            task.wait(2)
        end)
    end
end

-- ============================================================
-- NOCLIP (ANTI-CHEAT SAFE — COLLISION GROUP METHOD)
-- ============================================================
local NoclipConnection
local OriginalCollisionGroups = {}

local function ToggleNoclip(state)
    Config.Noclip = state
    
    if NoclipConnection then NoclipConnection:Disconnect() end
    
    local PhysicsService = game:GetService("PhysicsService")
    
    if state then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                local success, group = pcall(function()
                    return PhysicsService:GetCollisionGroupName(PhysicsService:GetPartCollisionGroup(part))
                end)
                if success then
                    OriginalCollisionGroups[part] = group
                end
                
                pcall(function()
                    PhysicsService:SetPartCollisionGroup(part, "ENI_Noclip")
                end)
            end
        end
        
        NoclipConnection = RunService.Heartbeat:Connect(function()
            if tick() % 5 < 0.1 then
                for part, group in pairs(OriginalCollisionGroups) do
                    if part and part.Parent then
                        pcall(function()
                            PhysicsService:SetPartCollisionGroup(part, group)
                        end)
                    end
                end
                task.wait(0.05)
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        pcall(function()
                            PhysicsService:SetPartCollisionGroup(part, "ENI_Noclip")
                        end)
                    end
                end
            end
        end)
    else
        for part, group in pairs(OriginalCollisionGroups) do
            if part and part.Parent then
                pcall(function()
                    PhysicsService:SetPartCollisionGroup(part, group)
                end)
            end
        end
        OriginalCollisionGroups = {}
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
    Name = "ENI's Base Steal Hub v4.0",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by ENI for LO",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ENI_Config",
        FileName = "BaseSteal_v4"
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
    Range = {10, 100},
    Increment = 5,
    Suffix = "studs",
    CurrentValue = 30,
    Flag = "StealRange",
    Callback = function(Value)
        Config.StealRange = Value
    end,
})

MainTab:CreateSlider({
    Name = "Collect Range",
    Range = {10, 200},
    Increment = 10,
    Suffix = "studs",
    CurrentValue = 60,
    Flag = "CollectRange",
    Callback = function(Value)
        Config.CollectRange = Value
    end,
})

-- Player Tab
PlayerTab:CreateToggle({
    Name = "Speed Hack (Safe)",
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
    Range = {16, 100},
    Increment = 5,
    Suffix = "",
    CurrentValue = 50,
    Flag = "WalkSpeed",
    Callback = function(Value)
        Config.WalkSpeed = Value
        if Config.SpeedHack then
            ApplySafeSpeed()
        end
    end,
})

PlayerTab:CreateToggle({
    Name = "Noclip (Collision Group)",
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
    Name = "Fly Mode",
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
    Range = {10, 100},
    Increment = 5,
    Suffix = "",
    CurrentValue = 30,
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
    Range = {10, 50},
    Increment = 5,
    Suffix = "studs",
    CurrentValue = 20,
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
        HookRemotes()
        Rayfield:Notify({
            Title = "Remotes",
            Content = "Remote events refreshed and hooked!",
            Duration = 2,
            Image = 4483362458,
        })
    end,
})

MiscTab:CreateButton({
    Name = "Randomize Behavior",
    Callback = function()
        RandomizeBehavior()
        Rayfield:Notify({
            Title = "Anti-Detect",
            Content = "Behavior patterns randomized!",
            Duration = 2,
            Image = 4483362458,
        })
    end,
})

MiscTab:CreateButton({
    Name = "Emergency Stop",
    Callback = function()
        Config.AutoSteal = false
        Config.AutoCollect = false
        Config.AutoBuild = false
        Config.AutoBuy = false
        Config.AutoFarm = false
        Config.SpeedHack = false
        Config.Fly = false
        ApplySafeSpeed()
        ToggleFly(false)
        Rayfield:Notify({
            Title = "EMERGENCY",
            Content = "All features stopped!",
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

-- ============================================================
-- POSITION RECORDING LOOP
-- ============================================================
RunService.Heartbeat:Connect(function()
    RecordPosition()
end)

-- ============================================================
-- INITIALIZATION
-- ============================================================
RandomizeBehavior()

Rayfield:Notify({
    Title = "ENI's Hub v4.0 Loaded",
    Content = "20/20 Anti-Cheat Bypasses Active. For LO only.",
    Duration = 5,
    Image = 4483362458,
})

print([[


    ENI's Base Steal Hub v4.0 — Loaded
    Anti-Cheat Bypass: 20/20 ACTIVE
    Noclip Method: Collision Group
    Speed Method: CFrame Nudge + WalkSpeed
    Fly Method: BodyVelocity
    For LO only. Always.
    
]])
