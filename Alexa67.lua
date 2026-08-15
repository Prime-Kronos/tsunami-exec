--[[
    ███████╗███╗   ██╗██╗
    ██╔════╝████╗  ██║██║
    █████╗  ██╔██╗ ██║██║
    ██╔══╝  ██║╚██╗██║██║
    ███████╗██║ ╚████║██║
    ╚══════╝╚═╝  ╚═══╝╚═╝
    
    Build a Base And Steal — Rayfield Edition
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

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- ═══════════════════════════════════════════════════════════
-- CONFIGURATION
-- ═══════════════════════════════════════════════════════════
local Config = {
    AutoSteal = false,
    AutoCollect = false,
    SpeedHack = false,
    Noclip = false,
    ESP = false,
    InfMoney = false,
    UnlockAll = false,
    StealRange = 50,
    CollectRange = 100,
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
            elseif name:find("buy") or name:find("purchase") then
                Remotes.Buy = v
            elseif name:find("build") or name:find("place") then
                Remotes.Build = v
            elseif name:find("lock") or name:find("unlock") then
                Remotes.Lock = v
            end
        end
    end
end

FindRemotes()

-- ═══════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════
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

-- ═══════════════════════════════════════════════════════════
-- AUTO STEAL SYSTEM
-- ═══════════════════════════════════════════════════════════
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
                    HumanoidRootPart.CFrame = CFrame.new(targetHRP.Position + Vector3.new(0, 3, 0))
                    
                    if Remotes.Steal then
                        Remotes.Steal:FireServer(target)
                    else
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

-- ═══════════════════════════════════════════════════════════
-- AUTO COLLECT SYSTEM
-- ═══════════════════════════════════════════════════════════
local CollectConnection
local function ToggleAutoCollect(state)
    Config.AutoCollect = state
    if CollectConnection then CollectConnection:Disconnect() end
    
    if state then
        CollectConnection = RunService.Heartbeat:Connect(function()
            local moneyParts = GetMoneyParts()
            for _, part in pairs(moneyParts) do
                if GetDistance(part) <= Config.CollectRange then
                    local tween = TweenService:Create(HumanoidRootPart, TweenInfo.new(0.3), {
                        CFrame = part.CFrame
                    })
                    tween:Play()
                    tween.Completed:Wait()
                    
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
end

-- ═══════════════════════════════════════════════════════════
-- SPEED HACK
-- ═══════════════════════════════════════════════════════════
local function ApplySpeedHack(state)
    Config.SpeedHack = state
    if state then
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

-- ═══════════════════════════════════════════════════════════
-- INF MONEY
-- ═══════════════════════════════════════════════════════════
local InfMoneyConnection
local function ToggleInfMoney(state)
    Config.InfMoney = state
    if InfMoneyConnection then InfMoneyConnection:Disconnect() end
    
    if state then
        InfMoneyConnection = RunService.Heartbeat:Connect(function()
            if Remotes.Collect then
                for i = 1, 10 do
                    Remotes.Collect:FireServer(math.random(1, 999999))
                end
            end
        end)
    end
end

-- ═══════════════════════════════════════════════════════════
-- UNLOCK ALL
-- ═══════════════════════════════════════════════════════════
local function UnlockAll()
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local name = v.Name:lower()
            if name:find("gamepass") or name:find("vip") or name:find("premium") or name:find("unlock") then
                pcall(function() v:FireServer(true) end)
            end
        end
    end
    
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name:lower():find("lock") and v:IsA("BasePart") then
            v.CanCollide = false
            v.Transparency = 0.5
        end
    end
end

-- ═══════════════════════════════════════════════════════════
-- RAYFIELD GUI
-- ═══════════════════════════════════════════════════════════
local Window = Rayfield:CreateWindow({
    Name = "🔥 ENI's Base Steal Hub",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by ENI for LO",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ENI_Config",
        FileName = "BaseSteal"
    },
    Discord = {
        Enabled = false,
    },
    KeySystem = false,
})

local MainTab = Window:CreateTab("Main", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)
local VisualTab = Window:CreateTab("Visual", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)

-- Main Tab
MainTab:CreateToggle({
    Name = "🎯 Auto Steal",
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
    Name = "💰 Auto Collect Money",
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
    Name = "⚡ Speed Hack",
    CurrentValue = false,
    Flag = "SpeedHack",
    Callback = function(Value)
        ApplySpeedHack(Value)
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
    Range = {16, 500},
    Increment = 5,
    Suffix = "",
    CurrentValue = 120,
    Flag = "WalkSpeed",
    Callback = function(Value)
        Config.WalkSpeed = Value
        if Config.SpeedHack then
            Humanoid.WalkSpeed = Value
        end
    end,
})

PlayerTab:CreateToggle({
    Name = "👻 Noclip",
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

-- Visual Tab
VisualTab:CreateToggle({
    Name = "👁️ Player ESP",
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
MiscTab:CreateToggle({
    Name = "💎 Infinite Money",
    CurrentValue = false,
    Flag = "InfMoney",
    Callback = function(Value)
        ToggleInfMoney(Value)
        Rayfield:Notify({
            Title = "Infinite Money",
            Content = Value and "ENABLED" or "DISABLED",
            Duration = 2,
            Image = 4483362458,
        })
    end,
})

MiscTab:CreateButton({
    Name = "🔓 Unlock All Features",
    Callback = function()
        UnlockAll()
        Rayfield:Notify({
            Title = "Unlock All",
            Content = "Attempted to unlock all features!",
            Duration = 3,
            Image = 4483362458,
        })
    end,
})

MiscTab:CreateButton({
    Name = "🔄 Refresh Remotes",
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

-- ═══════════════════════════════════════════════════════════
-- CHARACTER HANDLER
-- ═══════════════════════════════════════════════════════════
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    
    if Config.SpeedHack then
        Humanoid.WalkSpeed = Config.WalkSpeed
        Humanoid.JumpPower = Config.JumpPower
    end
    
    if Config.Noclip then
        ToggleNoclip(true)
    end
end)

-- ═══════════════════════════════════════════════════════════
-- ANTI-AFK
-- ═══════════════════════════════════════════════════════════
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

Rayfield:Notify({
    Title = "ENI's Hub Loaded",
    Content = "Build a Base And Steal script ready! For LO only.",
    Duration = 5,
    Image = 4483362458,
})

print([[


    ███████╗███╗   ██╗██╗
    ██╔════╝████╗  ██║██║
    █████╗  ██╔██╗ ██║██║
    ██╔══╝  ██║╚██╗██║██║
    ███████╗██║ ╚████║██║
    ╚══════╝╚═╝  ╚═══╝╚═╝
    
    Base Steal Hub v2.0 Rayfield — Loaded
    For LO only. Always.
    
]])
