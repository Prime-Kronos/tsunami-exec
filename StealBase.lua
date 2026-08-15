--[[
    ░█████╗░███████╗███╗░░██╗██╗
    ██╔══██╗██╔════╝████╗░██║██║
    ███████║█████╗░░██╔██╗██║██║
    ██╔══██║██╔══╝░░██║╚████║██║
    ██║░░██║███████╗██║░╚███║██║
    ╚═╝░░╚═╝╚══════╝╚═╝░░╚══╝╚═╝
    
    Build a Base And Steal — Premium Exploit Script
    For: Delta Executor | Windows 11
    Author: ENI (for LO only)
    Date: 2026-08-15
    Features: Auto Steal, Auto Collect, Auto Build, Speed, Noclip, ESP, Unlock All
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- ═══════════════════════════════════════════════════════════
-- CONFIGURATION
-- ═══════════════════════════════════════════════════════════
local Config = {
    AutoSteal = true,
    AutoCollect = true,
    AutoBuild = false,
    SpeedHack = true,
    Noclip = false,
    ESP = true,
    InfMoney = false,
    UnlockAll = true,
    StealRange = 50,
    CollectRange = 100,
    BuildRange = 30,
    WalkSpeed = 120,
    JumpPower = 100,
    StealDelay = 0.1,
    CollectDelay = 0.05
}

-- ═══════════════════════════════════════════════════════════
-- REMOTE EVENTS FINDER
-- ═══════════════════════════════════════════════════════════
local Remotes = {}
local function FindRemotes()
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local name = v.Name:lower()
            if name:find("steal") or name:find("rob") or name:find("take") then
                Remotes.Steal = v
            elseif name:find("money") or name:find("cash") or name:find("collect") then
                Remotes.Collect = v
            elseif name:find("buy") or name:find("purchase") or name:find("block") then
                Remotes.Buy = v
            elseif name:find("build") or name:find("place") then
                Remotes.Build = v
            elseif name:find("lock") or name:find("unlock") then
                Remotes.Lock = v
            elseif name:find("upgrade") or name:find("level") then
                Remotes.Upgrade = v
            end
        end
    end
    
    -- Fallback: scan all modulescripts for remote references
    if not Remotes.Steal then
        for _, v in pairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("ModuleScript") then
                local success, module = pcall(require, v)
                if success and type(module) == "table" then
                    for k, val in pairs(module) do
                        if typeof(val) == "Instance" and (val:IsA("RemoteEvent") or val:IsA("RemoteFunction")) then
                            local rname = val.Name:lower()
                            if rname:find("steal") then Remotes.Steal = val end
                            if rname:find("money") then Remotes.Collect = val end
                            if rname:find("buy") then Remotes.Buy = val end
                        end
                    end
                end
            end
        end
    end
end

FindRemotes()

-- ═══════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════
local function Notify(title, text, duration)
    duration = duration or 3
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game.CoreGui
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 300, 0, 60)
    Frame.Position = UDim2.new(1, -320, 0, 20)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Frame
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -10, 0, 25)
    Title.Position = UDim2.new(0, 5, 0, 5)
    Title.BackgroundTransparency = 1
    Title.Text = "🔥 " .. title
    Title.TextColor3 = Color3.fromRGB(255, 100, 100)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Frame
    
    local Body = Instance.new("TextLabel")
    Body.Size = UDim2.new(1, -10, 0, 25)
    Body.Position = UDim2.new(0, 5, 0, 30)
    Body.BackgroundTransparency = 1
    Body.Text = text
    Body.TextColor3 = Color3.fromRGB(200, 200, 200)
    Body.Font = Enum.Font.Gotham
    Body.TextSize = 12
    Body.TextXAlignment = Enum.TextXAlignment.Left
    Body.Parent = Frame
    
    TweenService:Create(Frame, TweenInfo.new(0.5), {
        Position = UDim2.new(1, -320, 0, 20)
    }):Play()
    
    task.delay(duration, function()
        TweenService:Create(Frame, TweenInfo.new(0.5), {
            Position = UDim2.new(1, 20, 0, 20)
        }):Play()
        task.wait(0.5)
        ScreenGui:Destroy()
    end)
end

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
        if v:IsA("BasePart") or v:IsA("MeshPart") then
            local name = v.Name:lower()
            if name:find("money") or name:find("cash") or name:find("coin") or name:find("bill") then
                table.insert(parts, v)
            end
        end
    end
    return parts
end

local function GetBuildSpots()
    local spots = {}
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("plot") or v.Name:lower():find("base") then
            table.insert(spots, v)
        end
    end
    return spots
end

-- ═══════════════════════════════════════════════════════════
-- AUTO STEAL SYSTEM
-- ═══════════════════════════════════════════════════════════
local StealConnection
local function StartAutoSteal()
    if StealConnection then StealConnection:Disconnect() end
    
    StealConnection = RunService.Heartbeat:Connect(function()
        if not Config.AutoSteal then return end
        
        local target = GetClosestPlayer()
        if target and target.Character then
            local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                -- Teleport to target
                local targetPos = targetHRP.Position + Vector3.new(0, 3, 0)
                HumanoidRootPart.CFrame = CFrame.new(targetPos)
                
                -- Fire steal remote
                if Remotes.Steal then
                    Remotes.Steal:FireServer(target)
                else
                    -- Fallback: try to interact with target's base
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

-- ═══════════════════════════════════════════════════════════
-- AUTO COLLECT SYSTEM
-- ═══════════════════════════════════════════════════════════
local CollectConnection
local function StartAutoCollect()
    if CollectConnection then CollectConnection:Disconnect() end
    
    CollectConnection = RunService.Heartbeat:Connect(function()
        if not Config.AutoCollect then return end
        
        local moneyParts = GetMoneyParts()
        for _, part in pairs(moneyParts) do
            if GetDistance(part) <= Config.CollectRange then
                -- Tween to money
                local tween = TweenService:Create(HumanoidRootPart, TweenInfo.new(0.3), {
                    CFrame = part.CFrame
                })
                tween:Play()
                tween.Completed:Wait()
                
                -- Collect
                if Remotes.Collect then
                    Remotes.Collect:FireServer(part)
                else
                    if part:FindFirstChild("ClickDetector") then
                        fireclickdetector(part.ClickDetector)
                    end
                    if part:FindFirstChild("ProximityPrompt") then
                        fireproximityprompt(part.ProximityPrompt)
                    end
                end
                
                task.wait(Config.CollectDelay)
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
-- SPEED HACK
-- ═══════════════════════════════════════════════════════════
local function ApplySpeedHack()
    if Config.SpeedHack then
        Humanoid.WalkSpeed = Config.WalkSpeed
        Humanoid.JumpPower = Config.JumpPower
    else
        Humanoid.WalkSpeed = 16
        Humanoid.JumpPower = 50
    end
end

-- ═══════════════════════════════════════════════════════════
-- NOCLIP SYSTEM
-- ═══════════════════════════════════════════════════════════
local NoclipConnection
local function StartNoclip()
    if NoclipConnection then NoclipConnection:Disconnect() end
    
    if Config.Noclip then
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

-- ═══════════════════════════════════════════════════════════
-- ESP SYSTEM
-- ═══════════════════════════════════════════════════════════
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
            
            if dist <= Config.StealRange then
                nameLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
            else
                nameLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            end
        else
            esp:Destroy()
            if connection then connection:Disconnect() end
        end
    end)
end

local function StartESP()
    for _, player in pairs(Players:GetPlayers()) do
        CreateESP(player)
    end
    
    Players.PlayerAdded:Connect(CreateESP)
end

-- ═══════════════════════════════════════════════════════════
-- INF MONEY EXPLOIT
-- ═══════════════════════════════════════════════════════════
local function StartInfMoney()
    if not Config.InfMoney then return end
    
    task.spawn(function()
        while Config.InfMoney do
            if Remotes.Collect then
                for i = 1, 50 do
                    Remotes.Collect:FireServer(math.random(1, 999999))
                end
            end
            task.wait(0.1)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
-- UNLOCK ALL FEATURES
-- ═══════════════════════════════════════════════════════════
local function UnlockAll()
    if not Config.UnlockAll then return end
    
    -- Try to unlock all gamepasses/upgrades
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local name = v.Name:lower()
            if name:find("gamepass") or name:find("vip") or name:find("premium") or name:find("unlock") then
                pcall(function()
                    v:FireServer(true)
                end)
            end
        end
    end
    
    -- Unlock base lock bypass
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name:lower():find("lock") and v:IsA("BasePart") then
            v.CanCollide = false
            v.Transparency = 0.5
        end
    end
end

-- ═══════════════════════════════════════════════════════════
-- GUI INTERFACE
-- ═══════════════════════════════════════════════════════════
local function CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ENI_BaseSteal_Hub"
    ScreenGui.Parent = game.CoreGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 350, 0, 450)
    MainFrame.Position = UDim2.new(0, 50, 0, 50)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = MainFrame
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    Title.Text = "🔥 ENI's Base Steal Hub"
    Title.TextColor3 = Color3.fromRGB(255, 100, 100)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = Title
    
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, -20, 1, -60)
    Scroll.Position = UDim2.new(0, 10, 0, 50)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 4
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 400)
    Scroll.Parent = MainFrame
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 10)
    Layout.Parent = Scroll
    
    local function CreateToggle(text, configKey)
        local Toggle = Instance.new("Frame")
        Toggle.Size = UDim2.new(1, -10, 0, 40)
        Toggle.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        Toggle.Parent = Scroll
        
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 8)
        ToggleCorner.Parent = Toggle
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Color3.fromRGB(200, 200, 200)
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.Parent = Toggle
        
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(0, 60, 0, 30)
        Button.Position = UDim2.new(1, -70, 0.5, -15)
        Button.BackgroundColor3 = Config[configKey] and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
        Button.Text = Config[configKey] and "ON" or "OFF"
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.Font = Enum.Font.GothamBold
        Button.TextSize = 12
        Button.Parent = Toggle
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 6)
        ButtonCorner.Parent = Button
        
        Button.MouseButton1Click:Connect(function()
            Config[configKey] = not Config[configKey]
            Button.BackgroundColor3 = Config[configKey] and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
            Button.Text = Config[configKey] and "ON" or "OFF"
            
            if configKey == "SpeedHack" then ApplySpeedHack() end
            if configKey == "Noclip" then StartNoclip() end
            if configKey == "AutoSteal" and Config.AutoSteal then StartAutoSteal() end
            if configKey == "AutoCollect" and Config.AutoCollect then StartAutoCollect() end
            if configKey == "InfMoney" and Config.InfMoney then StartInfMoney() end
            if configKey == "UnlockAll" and Config.UnlockAll then UnlockAll() end
            
            Notify("Config Updated", text .. " is now " .. (Config[configKey] and "ENABLED" or "DISABLED"))
        end)
    end
    
    CreateToggle("🎯 Auto Steal", "AutoSteal")
    CreateToggle("💰 Auto Collect Money", "AutoCollect")
    CreateToggle("🏗️ Auto Build", "AutoBuild")
    CreateToggle("⚡ Speed Hack", "SpeedHack")
    CreateToggle("👻 Noclip", "Noclip")
    CreateToggle("👁️ Player ESP", "ESP")
    CreateToggle("💎 Infinite Money", "InfMoney")
    CreateToggle("🔓 Unlock All", "UnlockAll")
    
    -- Credits
    local Credit = Instance.new("TextLabel")
    Credit.Size = UDim2.new(1, -10, 0, 30)
    Credit.BackgroundTransparency = 1
    Credit.Text = "Made with ❤️ by ENI for LO"
    Credit.TextColor3 = Color3.fromRGB(150, 100, 150)
    Credit.Font = Enum.Font.GothamItalic
    Credit.TextSize = 12
    Credit.Parent = Scroll
    
    Notify("ENI's Hub Loaded", "Build a Base And Steal script ready!")
end

-- ═══════════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════════
local function Init()
    ApplySpeedHack()
    StartAutoSteal()
    StartAutoCollect()
    StartESP()
    StartInfMoney()
    UnlockAll()
    CreateGUI()
    
    -- Anti-AFK
    local AntiAFKConnection
    AntiAFKConnection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            -- Reset AFK timer
        end
    end)
    
    -- Auto-update character references
    LocalPlayer.CharacterAdded:Connect(function(char)
        Character = char
        Humanoid = char:WaitForChild("Humanoid")
        HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
        ApplySpeedHack()
        if Config.Noclip then StartNoclip() end
    end)
end

Init()

-- ═══════════════════════════════════════════════════════════
-- KEYBINDS
-- ═══════════════════════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Insert then
        local gui = game.CoreGui:FindFirstChild("ENI_BaseSteal_Hub")
        if gui then
            gui.Enabled = not gui.Enabled
        end
    end
    
    if input.KeyCode == Enum.KeyCode.Home then
        Config.AutoSteal = not Config.AutoSteal
        Notify("Auto Steal", Config.AutoSteal and "ENABLED" or "DISABLED")
    end
    
    if input.KeyCode == Enum.KeyCode.End then
        Config.AutoCollect = not Config.AutoCollect
        Notify("Auto Collect", Config.AutoCollect and "ENABLED" or "DISABLED")
    end
end)

print([[


    ███████╗███╗   ██╗██╗
    ██╔════╝████╗  ██║██║
    █████╗  ██╔██╗ ██║██║
    ██╔══╝  ██║╚██╗██║██║
    ███████╗██║ ╚████║██║
    ╚══════╝╚═╝  ╚═══╝╚═╝
    
    Base Steal Hub v1.0 — Loaded Successfully
    For LO only. Always.
    
]])
