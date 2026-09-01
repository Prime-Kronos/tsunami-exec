--// PlayerSelect | @aLiNa_grnt | @Rost1ksOfficial
--// Rayfield GUI Library | Delta Exploit
--// Features: Unlock All + Auto-Win + God Mode + ESP + IMBA

--// Load Rayfield GUI
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--// Create Window
local Window = Rayfield:CreateWindow({
    Name = "PlayerSelect | @aLiNa_grnt",
    LoadingTitle = "@aLiNa_grnt",
    LoadingSubtitle = "Loading PlayerSelect IMBA...",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "PlayerSelect_IMBA",
        FileName = "Settings"
    },
    KeySystem = false
})

--// Create Tabs
local CharacterTab = Window:CreateTab("Characters", 4483345998)
local CombatTab = Window:CreateTab("Combat", 4483345998)
local ESPTab = Window:CreateTab("ESP", 4483345998)
local EventTab = Window:CreateTab("Events", 4483345998)
local IMBATab = Window:CreateTab("IMBA", 4483345998)

--// Settings
local Settings = {
    --// Characters
    UnlockAll = false,
    InstantAbilities = false,
    NoCooldown = false,
    
    --// Combat
    GodMode = false,
    OneHitKill = false,
    InfiniteHealth = false,
    AutoWin = false,
    AutoAttack = false,
    AttackRange = 50,
    
    --// ESP
    ESPEnabled = false,
    ESPPlayers = true,
    ESPBosses = true,
    ESPLoot = true,
    ESPDistance = 500,
    
    --// Events
    AutoFarm = false,
    AutoCollect = false,
    AutoEvent = false,
    
    --// Movement
    SpeedHack = false,
    SpeedValue = 50,
    Fly = false,
    FlySpeed = 50,
    NoClip = false,
    Teleport = false
}

--// ESP Storage
local ESPObjects = {}

--// Utility Functions
local function GetCharacter(player)
    return player.Character
end

local function GetHumanoid(character)
    return character:FindFirstChildOfClass("Humanoid")
end

--// ESP Functions
local function CreateESP(obj, name, color)
    if ESPObjects[obj] then return end
    
    local label = Drawing.new("Text")
    label.Visible = false
    label.Size = 14
    label.Center = true
    label.Outline = true
    label.Color = color
    label.Font = Drawing.Fonts.UI
    
    ESPObjects[obj] = {
        Label = label,
        Name = name,
        Color = color
    }
end

local function UpdateESP()
    for obj, data in pairs(ESPObjects) do
        if not obj or not obj.Parent or not Settings.ESPEnabled then
            data.Label.Visible = false
            continue
        end
        
        local pos, onScreen
        if obj:IsA("Model") then
            local hrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
            if not hrp then
                data.Label.Visible = false
                continue
            end
            pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        else
            pos, onScreen = Camera:WorldToViewportPoint(obj.Position)
        end
        
        if not onScreen then
            data.Label.Visible = false
            continue
        end
        
        local distance = 0
        if obj:IsA("Model") then
            local hrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
            if hrp then
                distance = (hrp.Position - Camera.CFrame.Position).Magnitude
            end
        else
            distance = (obj.Position - Camera.CFrame.Position).Magnitude
        end
        
        if distance > Settings.ESPMaxDistance then
            data.Label.Visible = false
            continue
        end
        
        data.Label.Position = Vector2.new(pos.X, pos.Y)
        data.Label.Text = data.Name .. " [" .. math.floor(distance) .. "m] | @aLiNa_grnt"
        data.Label.Color = data.Color
        data.Label.Visible = true
    end
end

--// God Mode
local function UpdateGodMode()
    if not Settings.GodMode then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = GetHumanoid(character)
    if not humanoid then return end
    
    humanoid.MaxHealth = math.huge
    humanoid.Health = math.huge
end

--// One-Hit Kill
local function OneHitKill()
    if not Settings.OneHitKill then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local targetChar = GetCharacter(player)
            if targetChar then
                local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
                local targetHumanoid = GetHumanoid(targetChar)
                if targetHrp and targetHumanoid then
                    local dist = (targetHrp.Position - hrp.Position).Magnitude
                    if dist < Settings.AttackRange then
                        targetHumanoid.Health = 0
                    end
                end
            end
        end
    end
end

--// Auto-Win
local function AutoWin()
    if not Settings.AutoWin then return end
    
    --// Find all enemy players and kill them
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local targetChar = GetCharacter(player)
            if targetChar then
                local targetHumanoid = GetHumanoid(targetChar)
                if targetHumanoid then
                    targetHumanoid.Health = 0
                end
            end
        end
    end
end

--// Auto-Attack
local function AutoAttack()
    if not Settings.AutoAttack then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local targetChar = GetCharacter(player)
            if targetChar then
                local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
                local targetHumanoid = GetHumanoid(targetChar)
                if targetHrp and targetHumanoid and targetHumanoid.Health > 0 then
                    local dist = (targetHrp.Position - hrp.Position).Magnitude
                    if dist < Settings.AttackRange then
                        --// Simulate attack
                        local tool = character:FindFirstChildOfClass("Tool")
                        if tool then
                            tool:Activate()
                        end
                    end
                end
            end
        end
    end
end

--// Speed Hack
local function UpdateSpeed()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = GetHumanoid(character)
    if not humanoid then return end
    
    if Settings.SpeedHack then
        humanoid.WalkSpeed = Settings.SpeedValue
    else
        humanoid.WalkSpeed = 16
    end
end

--// Fly
local FlyBodyGyro = nil
local FlyBodyVelocity = nil

local function StartFly()
    local character = LocalPlayer.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    FlyBodyGyro = Instance.new("BodyGyro")
    FlyBodyGyro.P = 9e4
    FlyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    FlyBodyGyro.CFrame = hrp.CFrame
    FlyBodyGyro.Parent = hrp
    
    FlyBodyVelocity = Instance.new("BodyVelocity")
    FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    FlyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    FlyBodyVelocity.Parent = hrp
    
    while Settings.Fly and character and hrp do
        local direction = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            direction = direction + Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            direction = direction - Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            direction = direction - Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            direction = direction + Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            direction = direction + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            direction = direction - Vector3.new(0, 1, 0)
        end
        
        if direction.Magnitude > 0 then
            direction = direction.Unit * Settings.FlySpeed
        end
        
        FlyBodyVelocity.Velocity = direction
        FlyBodyGyro.CFrame = Camera.CFrame
        
        task.wait()
    end
    
    if FlyBodyGyro then FlyBodyGyro:Destroy() end
    if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
end

--// NoClip
local NoClipConnection = nil

local function StartNoClip()
    if NoClipConnection then return end
    
    NoClipConnection = RunService.Stepped:Connect(function()
        if not Settings.NoClip then return end
        local character = LocalPlayer.Character
        if not character then return end
        
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

--// Auto-Collect
local function AutoCollect()
    if not Settings.AutoCollect then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
            if obj.Name:lower():find("coin") or obj.Name:lower():find("gem") or obj.Name:lower():find("loot") or obj.Name:lower():find("drop") or obj.Name:lower():find("reward") then
                local dist = (obj.Position - hrp.Position).Magnitude
                if dist < 50 then
                    hrp.CFrame = obj.CFrame + Vector3.new(0, 2, 0)
                end
            end
        end
    end
end

--// Auto-Farm Events
local function AutoFarm()
    if not Settings.AutoFarm then return end
    
    --// Find event objectives and complete them
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local dist = (obj.Parent.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if dist < 20 then
                fireproximityprompt(obj)
            end
        end
    end
end

--// Unlock All Characters
local function UnlockAllCharacters()
    if not Settings.UnlockAll then return end
    
    --// Attempt to unlock all characters via remote events
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            if remote.Name:lower():find("unlock") or remote.Name:lower():find("character") or remote.Name:lower():find("hero") then
                pcall(function()
                    remote:FireServer(true)
                end)
            end
        end
    end
end

--// Instant Abilities / No Cooldown
local function NoCooldown()
    if not Settings.NoCooldown then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    for _, tool in ipairs(character:GetDescendants()) do
        if tool:IsA("Tool") then
            local cooldown = tool:FindFirstChild("Cooldown") or tool:FindFirstChild("cooldown")
            if cooldown and cooldown:IsA("NumberValue") then
                cooldown.Value = 0
            end
        end
    end
    
    for _, tool in ipairs(LocalPlayer.Backpack:GetDescendants()) do
        if tool:IsA("Tool") then
            local cooldown = tool:FindFirstChild("Cooldown") or tool:FindFirstChild("cooldown")
            if cooldown and cooldown:IsA("NumberValue") then
                cooldown.Value = 0
            end
        end
    end
end

--// Scan for ESP targets
local function ScanESPTargets()
    --// Players
    if Settings.ESPPlayers then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local character = GetCharacter(player)
                if character then
                    CreateESP(character, player.Name, Color3.fromRGB(255, 50, 50))
                end
            end
        end
    end
    
    --// Bosses
    if Settings.ESPBosses then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and (obj.Name:lower():find("boss") or obj.Name:lower():find("freddy") or obj.Name:lower():find("king") or obj.Name:lower():find("enemy")) then
                CreateESP(obj, "BOSS: " .. obj.Name, Color3.fromRGB(255, 0, 0))
            end
        end
    end
    
    --// Loot
    if Settings.ESPLoot then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                if obj.Name:lower():find("coin") or obj.Name:lower():find("gem") or obj.Name:lower():find("chest") or obj.Name:lower():find("reward") then
                    CreateESP(obj, "LOOT: " .. obj.Name, Color3.fromRGB(255, 215, 0))
                end
            end
        end
    end
end

--// Main Loop
RunService.RenderStepped:Connect(function()
    --// ESP
    if Settings.ESPEnabled then
        UpdateESP()
    else
        for _, data in pairs(ESPObjects) do
            data.Label.Visible = false
        end
    end
    
    --// Combat
    UpdateGodMode()
    OneHitKill()
    AutoAttack()
    AutoWin()
    
    --// Movement
    UpdateSpeed()
    AutoCollect()
    AutoFarm()
    
    --// Abilities
    NoCooldown()
    UnlockAllCharacters()
end)

--// Character Added
LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    
    if Settings.SpeedHack then
        UpdateSpeed()
    end
    
    if Settings.NoClip then
        StartNoClip()
    end
    
    if Settings.GodMode then
        UpdateGodMode()
    end
end)

--// ==================== RAYFIELD GUI ====================

--// Characters Section
local CharSection = CharacterTab:CreateSection("Character Hacks")

CharSection:CreateToggle({
    Name = "Unlock All Characters",
    CurrentValue = false,
    Flag = "Char_Unlock",
    Callback = function(Value)
        Settings.UnlockAll = Value
    end
})

CharSection:CreateToggle({
    Name = "Instant Abilities",
    CurrentValue = false,
    Flag = "Char_Instant",
    Callback = function(Value)
        Settings.InstantAbilities = Value
    end
})

CharSection:CreateToggle({
    Name = "No Cooldown",
    CurrentValue = false,
    Flag = "Char_Cooldown",
    Callback = function(Value)
        Settings.NoCooldown = Value
    end
})

--// Combat Section
local CombatSection = CombatTab:CreateSection("Combat Hacks")

CombatSection:CreateToggle({
    Name = "God Mode",
    CurrentValue = false,
    Flag = "Combat_God",
    Callback = function(Value)
        Settings.GodMode = Value
        if Value then
            UpdateGodMode()
        end
    end
})

CombatSection:CreateToggle({
    Name = "One-Hit Kill",
    CurrentValue = false,
    Flag = "Combat_OHK",
    Callback = function(Value)
        Settings.OneHitKill = Value
    end
})

CombatSection:CreateToggle({
    Name = "Infinite Health",
    CurrentValue = false,
    Flag = "Combat_Health",
    Callback = function(Value)
        Settings.InfiniteHealth = Value
    end
})

CombatSection:CreateToggle({
    Name = "Auto-Win",
    CurrentValue = false,
    Flag = "Combat_Win",
    Callback = function(Value)
        Settings.AutoWin = Value
    end
})

CombatSection:CreateToggle({
    Name = "Auto-Attack",
    CurrentValue = false,
    Flag = "Combat_Auto",
    Callback = function(Value)
        Settings.AutoAttack = Value
    end
})

CombatSection:CreateSlider({
    Name = "Attack Range",
    Range = {10, 200},
    Increment = 10,
    Suffix = " studs",
    CurrentValue = 50,
    Flag = "Combat_Range",
    Callback = function(Value)
        Settings.AttackRange = Value
    end
})

--// ESP Section
local ESPSection = ESPTab:CreateSection("ESP Settings")

ESPSection:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Flag = "ESP_Enable",
    Callback = function(Value)
        Settings.ESPEnabled = Value
        if Value then
            ScanESPTargets()
        end
    end
})

ESPSection:CreateToggle({
    Name = "ESP Players",
    CurrentValue = true,
    Flag = "ESP_Players",
    Callback = function(Value)
        Settings.ESPPlayers = Value
    end
})

ESPSection:CreateToggle({
    Name = "ESP Bosses",
    CurrentValue = true,
    Flag = "ESP_Bosses",
    Callback = function(Value)
        Settings.ESPBosses = Value
    end
})

ESPSection:CreateToggle({
    Name = "ESP Loot",
    CurrentValue = true,
    Flag = "ESP_Loot",
    Callback = function(Value)
        Settings.ESPLoot = Value
    end
})

ESPSection:CreateSlider({
    Name = "ESP Distance",
    Range = {50, 2000},
    Increment = 50,
    Suffix = "m",
    CurrentValue = 500,
    Flag = "ESP_Distance",
    Callback = function(Value)
        Settings.ESPMaxDistance = Value
    end
})

--// Events Section
local EventSection = EventTab:CreateSection("Event Hacks")

EventSection:CreateToggle({
    Name = "Auto-Farm Events",
    CurrentValue = false,
    Flag = "Event_Farm",
    Callback = function(Value)
        Settings.AutoFarm = Value
    end
})

EventSection:CreateToggle({
    Name = "Auto-Collect Loot",
    CurrentValue = false,
    Flag = "Event_Collect",
    Callback = function(Value)
        Settings.AutoCollect = Value
    end
})

EventSection:CreateToggle({
    Name = "Auto-Complete Event",
    CurrentValue = false,
    Flag = "Event_Auto",
    Callback = function(Value)
        Settings.AutoEvent = Value
    end
})

--// Movement Section (in IMBA tab for space)
local MoveSection = IMBATab:CreateSection("Movement Hacks")

MoveSection:CreateToggle({
    Name = "Speed Hack",
    CurrentValue = false,
    Flag = "Move_Speed",
    Callback = function(Value)
        Settings.SpeedHack = Value
        UpdateSpeed()
    end
})

MoveSection:CreateSlider({
    Name = "Speed Value",
    Range = {16, 200},
    Increment = 5,
    Suffix = "",
    CurrentValue = 50,
    Flag = "Move_SpeedVal",
    Callback = function(Value)
        Settings.SpeedValue = Value
        if Settings.SpeedHack then
            UpdateSpeed()
        end
    end
})

MoveSection:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "Move_Fly",
    Callback = function(Value)
        Settings.Fly = Value
        if Value then
            StartFly()
        end
    end
})

MoveSection:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 200},
    Increment = 10,
    Suffix = "",
    CurrentValue = 50,
    Flag = "Move_FlySpeed",
    Callback = function(Value)
        Settings.FlySpeed = Value
    end
})

MoveSection:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Flag = "Move_NoClip",
    Callback = function(Value)
        Settings.NoClip = Value
        if Value then
            StartNoClip()
        end
    end
})

MoveSection:CreateButton({
    Name = "Teleport to Nearest Player",
    Callback = function()
        local character = LocalPlayer.Character
        if not character then return end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local nearest = nil
        local nearestDist = math.huge
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local targetChar = GetCharacter(player)
                if targetChar then
                    local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
                    if targetHrp then
                        local dist = (targetHrp.Position - hrp.Position).Magnitude
                        if dist < nearestDist then
                            nearestDist = dist
                            nearest = targetHrp
                        end
                    end
                end
            end
        end
        
        if nearest then
            hrp.CFrame = nearest.CFrame + Vector3.new(0, 5, 0)
            Rayfield:Notify({
                Title = "@aLiNa_grnt",
                Content = "Teleported to nearest player!",
                Duration = 2
            })
        end
    end
})

MoveSection:CreateButton({
    Name = "Teleport to Loot",
    Callback = function()
        local character = LocalPlayer.Character
        if not character then return end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                if obj.Name:lower():find("coin") or obj.Name:lower():find("gem") or obj.Name:lower():find("chest") then
                    hrp.CFrame = obj.CFrame + Vector3.new(0, 2, 0)
                    Rayfield:Notify({
                        Title = "@aLiNa_grnt",
                        Content = "Teleported to " .. obj.Name .. "!",
                        Duration = 2
                    })
                    return
                end
            end
        end
    end
})

MoveSection:CreateButton({
    Name = "Kill All Players",
    Callback = function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local targetChar = GetCharacter(player)
                if targetChar then
                    local targetHumanoid = GetHumanoid(targetChar)
                    if targetHumanoid then
                        targetHumanoid.Health = 0
                    end
                end
            end
        end
        Rayfield:Notify({
            Title = "@aLiNa_grnt",
            Content = "All players eliminated!",
            Duration = 3
        })
    end
})

MoveSection:CreateButton({
    Name = "Teleport to Boss",
    Callback = function()
        local character = LocalPlayer.Character
        if not character then return end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") then
                if obj.Name:lower():find("boss") or obj.Name:lower():find("freddy") or obj.Name:lower():find("king") then
                    local bossHrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
                    if bossHrp then
                        hrp.CFrame = bossHrp.CFrame + Vector3.new(0, 10, 0)
                        Rayfield:Notify({
                            Title = "@aLiNa_grnt",
                            Content = "Teleported to " .. obj.Name .. "!",
                            Duration = 2
                        })
                        return
                    end
                end
            end
        end
    end
})

MoveSection:CreateButton({
    Name = "Respawn at Start",
    Callback = function()
        local character = LocalPlayer.Character
        if not character then return end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name:lower():find("spawn") or obj.Name:lower():find("start") or obj.Name:lower():find("lobby") then
                if obj:IsA("BasePart") or obj:IsA("SpawnLocation") then
                    hrp.CFrame = obj.CFrame + Vector3.new(0, 5, 0)
                    Rayfield:Notify({
                        Title = "@aLiNa_grnt",
                        Content = "Respawned at start!",
                        Duration = 2
                    })
                    return
                end
            end
        end
    end
})

MoveSection:CreateButton({
    Name = "Heal to Full",
    Callback = function()
        local character = LocalPlayer.Character
        if not character then return end
        local humanoid = GetHumanoid(character)
        if humanoid then
            humanoid.Health = humanoid.MaxHealth
            Rayfield:Notify({
                Title = "@aLiNa_grnt",
                Content = "Fully healed!",
                Duration = 2
            })
        end
    end
})
