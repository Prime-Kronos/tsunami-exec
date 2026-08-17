--// Snipers vs Runners | @aLiNa_grnt
--// Rayfield GUI Library | Delta Exploit
--// Features: Aimbot + ESP + IMBA Functions

--// Load Rayfield GUI
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--// Create Window
local Window = Rayfield:CreateWindow({
    Name = "Snipers vs Runners | @aLiNa_grnt",
    LoadingTitle = "@aLiNa_grnt",
    LoadingSubtitle = "Loading IMBA exploit...",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SvR_IMBA",
        FileName = "Settings"
    },
    KeySystem = false
})

--// Create Tabs
local ESPTab = Window:CreateTab("ESP", 4483345998)
local AimbotTab = Window:CreateTab("Aimbot", 4483345998)
local MovementTab = Window:CreateTab("Movement", 4483345998)
local IMBATab = Window:CreateTab("IMBA", 4483345998)

--// Settings
local Settings = {
    --// ESP
    ESPEnabled = false,
    ESPBoxes = true,
    ESPNames = true,
    ESPHealth = true,
    ESPTracers = false,
    ESPDistance = false,
    ESPColor = Color3.fromRGB(255, 50, 50),
    
    --// Aimbot
    AimbotEnabled = false,
    AimPart = "Head",
    AimFov = 150,
    AimSmooth = 3,
    TeamCheck = true,
    WallCheck = false,
    ShowFOV = true,
    TriggerBot = false,
    
    --// Movement
    SpeedHack = false,
    SpeedValue = 50,
    FlyEnabled = false,
    FlySpeed = 50,
    InfiniteJump = false,
    NoClip = false,
    AutoWin = false,
    
    --// IMBA
    GodMode = false,
    InstantRespawn = false,
    TeleportToFinish = false,
    TeleportToSnipers = false,
    AntiSniper = false,
    ESPWeapons = false,
    AutoCollect = false,
    FullBright = false
}

--// ESP Storage
local ESPObjects = {}
local WeaponESPObjects = {}

--// FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(180, 130, 220)
FOVCircle.Transparency = 0.6
FOVCircle.Filled = false
FOVCircle.NumSides = 64

--// Fly Variables
local FlyBodyGyro = nil
local FlyBodyVelocity = nil

--// NoClip Variables
local NoClipConnection = nil

--// Utility Functions
local function IsTeammate(player)
    if not Settings.TeamCheck then return false end
    return player.Team == LocalPlayer.Team
end

local function IsVisible(targetPart)
    if not Settings.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * (targetPart.Position - origin).Magnitude
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = Workspace:Raycast(origin, direction, raycastParams)
    return result == nil
end

local function GetClosestPlayer()
    local closest = nil
    local closestDist = math.huge
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if IsTeammate(player) then continue end
        
        local character = player.Character
        if not character then continue end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        
        local aimPart = character:FindFirstChild(Settings.AimPart)
        if not aimPart then continue end
        
        if not IsVisible(aimPart) then continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
        if not onScreen then continue end
        
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if dist < Settings.AimFov and dist < closestDist then
            closestDist = dist
            closest = {Player = player, Part = aimPart, ScreenPos = screenPos}
        end
    end
    
    return closest
end

--// ESP Functions
local function CreateESP(player)
    if ESPObjects[player] then return end
    
    local objects = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        HealthBar = Drawing.new("Square"),
        HealthBarBg = Drawing.new("Square"),
        Tracer = Drawing.new("Line"),
        Distance = Drawing.new("Text")
    }
    
    objects.Box.Visible = false
    objects.Box.Thickness = 1
    objects.Box.Color = Settings.ESPColor
    objects.Box.Transparency = 1
    objects.Box.Filled = false
    
    objects.Name.Visible = false
    objects.Name.Size = 13
    objects.Name.Center = true
    objects.Name.Outline = true
    objects.Name.Color = Color3.fromRGB(255, 255, 255)
    objects.Name.Font = Drawing.Fonts.UI
    
    objects.HealthBarBg.Visible = false
    objects.HealthBarBg.Thickness = 1
    objects.HealthBarBg.Color = Color3.fromRGB(50, 50, 50)
    objects.HealthBarBg.Filled = true
    objects.HealthBarBg.Transparency = 0.5
    
    objects.HealthBar.Visible = false
    objects.HealthBar.Thickness = 1
    objects.HealthBar.Color = Color3.fromRGB(50, 255, 50)
    objects.HealthBar.Filled = true
    objects.HealthBar.Transparency = 0.8
    
    objects.Tracer.Visible = false
    objects.Tracer.Thickness = 1
    objects.Tracer.Color = Settings.ESPColor
    objects.Tracer.Transparency = 0.7
    
    objects.Distance.Visible = false
    objects.Distance.Size = 11
    objects.Distance.Center = true
    objects.Distance.Outline = true
    objects.Distance.Color = Color3.fromRGB(200, 200, 200)
    objects.Distance.Font = Drawing.Fonts.UI
    
    ESPObjects[player] = objects
end

local function RemoveESP(player)
    local objects = ESPObjects[player]
    if not objects then return end
    for _, obj in pairs(objects) do
        if obj then obj:Remove() end
    end
    ESPObjects[player] = nil
end

local function UpdateESP()
    for player, objects in pairs(ESPObjects) do
        local character = player.Character
        if not character or not Settings.ESPEnabled then
            for _, obj in pairs(objects) do
                if obj then obj.Visible = false end
            end
            continue
        end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            for _, obj in pairs(objects) do
                if obj then obj.Visible = false end
            end
            continue
        end
        
        if IsTeammate(player) then
            for _, obj in pairs(objects) do
                if obj then obj.Visible = false end
            end
            continue
        end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
        local distance = (hrp.Position - Camera.CFrame.Position).Magnitude
        
        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then
            for _, obj in pairs(objects) do
                if obj then obj.Visible = false end
            end
            continue
        end
        
        local head = character:FindFirstChild("Head")
        local foot = character:FindFirstChild("LeftFoot") or character:FindFirstChild("LeftLowerLeg")
        if not head or not foot then continue end
        
        local headPos = Camera:WorldToViewportPoint(head.Position)
        local footPos = Camera:WorldToViewportPoint(foot.Position)
        local height = math.abs(headPos.Y - footPos.Y)
        local width = height * 0.5
        
        local boxX = pos.X - width / 2
        local boxY = pos.Y - height / 2
        
        if Settings.ESPBoxes then
            objects.Box.Size = Vector2.new(width, height)
            objects.Box.Position = Vector2.new(boxX, boxY)
            objects.Box.Color = Settings.ESPColor
            objects.Box.Visible = true
        else
            objects.Box.Visible = false
        end
        
        if Settings.ESPNames then
            objects.Name.Position = Vector2.new(pos.X, boxY - 18)
            objects.Name.Text = player.Name .. " | @aLiNa_grnt"
            objects.Name.Visible = true
        else
            objects.Name.Visible = false
        end
        
        if Settings.ESPHealth then
            local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
            local barHeight = height * healthPercent
            
            objects.HealthBarBg.Size = Vector2.new(4, height)
            objects.HealthBarBg.Position = Vector2.new(boxX - 10, boxY)
            objects.HealthBarBg.Visible = true
            
            objects.HealthBar.Size = Vector2.new(4, barHeight)
            objects.HealthBar.Position = Vector2.new(boxX - 10, boxY + height - barHeight)
            objects.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 50)
            objects.HealthBar.Visible = true
        else
            objects.HealthBar.Visible = false
            objects.HealthBarBg.Visible = false
        end
        
        if Settings.ESPTracers then
            objects.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            objects.Tracer.To = Vector2.new(pos.X, pos.Y + height / 2)
            objects.Tracer.Color = Settings.ESPColor
            objects.Tracer.Visible = true
        else
            objects.Tracer.Visible = false
        end
        
        if Settings.ESPDistance then
            objects.Distance.Position = Vector2.new(pos.X, boxY + height + 2)
            objects.Distance.Text = string.format("[%.0fm]", distance)
            objects.Distance.Visible = true
        else
            objects.Distance.Visible = false
        end
    end
end

--// Weapon ESP
local function CreateWeaponESP(weapon)
    if WeaponESPObjects[weapon] then return end
    
    local obj = Drawing.new("Text")
    obj.Visible = false
    obj.Size = 14
    obj.Center = true
    obj.Outline = true
    obj.Color = Color3.fromRGB(255, 215, 0)
    obj.Font = Drawing.Fonts.UI
    
    WeaponESPObjects[weapon] = obj
end

local function UpdateWeaponESP()
    for weapon, obj in pairs(WeaponESPObjects) do
        if not weapon or not weapon.Parent or not Settings.ESPWeapons then
            obj.Visible = false
            continue
        end
        
        local pos, onScreen = Camera:WorldToViewportPoint(weapon.Position)
        if not onScreen then
            obj.Visible = false
            continue
        end
        
        obj.Position = Vector2.new(pos.X, pos.Y)
        obj.Text = "🔫 Weapon | @aLiNa_grnt"
        obj.Visible = true
    end
end

--// Aimbot Logic
local function RunAimbot()
    if not Settings.AimbotEnabled then return end
    
    local target = GetClosestPlayer()
    if not target then return end
    
    local targetPos = Camera:WorldToViewportPoint(target.Part.Position)
    local mousePos = UserInputService:GetMouseLocation()
    local moveVec = (Vector2.new(targetPos.X, targetPos.Y) - mousePos) / Settings.AimSmooth
    
    mousemoverel(moveVec.X, moveVec.Y)
    
    --// Trigger Bot
    if Settings.TriggerBot then
        local dist = (Vector2.new(targetPos.X, targetPos.Y) - mousePos).Magnitude
        if dist < 10 then
            mouse1click()
        end
    end
end

--// Speed Hack
local function UpdateSpeed()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    if Settings.SpeedHack then
        humanoid.WalkSpeed = Settings.SpeedValue
    else
        humanoid.WalkSpeed = 16
    end
end

--// Fly Function
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
    
    while Settings.FlyEnabled and character and hrp do
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

--// NoClip Function
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

--// Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump then
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

--// God Mode
local function UpdateGodMode()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    if Settings.GodMode then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
    else
        humanoid.MaxHealth = 100
    end
end

--// Anti-Sniper (Bullet Dodge)
local function UpdateAntiSniper()
    if not Settings.AntiSniper then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    --// Detect bullets and dodge
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("bullet") or obj.Name:lower():find("projectile") then
            local dist = (obj.Position - hrp.Position).Magnitude
            if dist < 20 then
                hrp.Velocity = hrp.Velocity + Vector3.new(math.random(-50, 50), math.random(20, 50), math.random(-50, 50))
            end
        end
    end
end

--// Auto-Win (Teleport to finish)
local function AutoWin()
    if not Settings.AutoWin then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    --// Find finish area
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("finish") or obj.Name:lower():find("end") or obj.Name:lower():find("goal") then
            if obj:IsA("BasePart") then
                hrp.CFrame = obj.CFrame + Vector3.new(0, 5, 0)
                break
            end
        end
    end
end

--// Full Bright
local function UpdateFullBright()
    if Settings.FullBright then
        game:GetService("Lighting").Brightness = 10
        game:GetService("Lighting").GlobalShadows = false
    else
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").GlobalShadows = true
    end
end

--// Player Management
Players.PlayerAdded:Connect(function(player)
    CreateESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

--// Main Loop
RunService.RenderStepped:Connect(function()
    --// FOV Circle
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = Settings.AimFov
    FOVCircle.Visible = Settings.AimbotEnabled and Settings.ShowFOV
    
    --// ESP
    if Settings.ESPEnabled then
        UpdateESP()
    else
        for _, objects in pairs(ESPObjects) do
            for _, obj in pairs(objects) do
                if obj then obj.Visible = false end
            end
        end
    end
    
    --// Weapon ESP
    if Settings.ESPWeapons then
        UpdateWeaponESP()
    end
    
    --// Aimbot
    if Settings.AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        RunAimbot()
    end
    
    --// Anti-Sniper
    if Settings.AntiSniper then
        UpdateAntiSniper()
    end
    
    --// Auto-Win
    if Settings.AutoWin then
        AutoWin()
    end
    
    --// Full Bright
    UpdateFullBright()
end)

--// Character Added
LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    
    if Settings.SpeedHack then
        UpdateSpeed()
    end
    
    if Settings.GodMode then
        UpdateGodMode()
    end
    
    if Settings.NoClip then
        StartNoClip()
    end
end)

--// ==================== RAYFIELD GUI ====================

--// ESP Section
local ESPSection = ESPTab:CreateSection("ESP Settings")

ESPSection:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Flag = "ESP_Toggle",
    Callback = function(Value)
        Settings.ESPEnabled = Value
    end
})

ESPSection:CreateToggle({
    Name = "Boxes",
    CurrentValue = true,
    Flag = "ESP_Boxes",
    Callback = function(Value)
        Settings.ESPBoxes = Value
    end
})

ESPSection:CreateToggle({
    Name = "Names",
    CurrentValue = true,
    Flag = "ESP_Names",
    Callback = function(Value)
        Settings.ESPNames = Value
    end
})

ESPSection:CreateToggle({
    Name = "Health Bar",
    CurrentValue = true,
    Flag = "ESP_Health",
    Callback = function(Value)
        Settings.ESPHealth = Value
    end
})

ESPSection:CreateToggle({
    Name = "Tracers",
    CurrentValue = false,
    Flag = "ESP_Tracers",
    Callback = function(Value)
        Settings.ESPTracers = Value
    end
})

ESPSection:CreateToggle({
    Name = "Distance",
    CurrentValue = false,
    Flag = "ESP_Distance",
    Callback = function(Value)
        Settings.ESPDistance = Value
    end
})

ESPSection:CreateColorPicker({
    Name = "ESP Color",
    Color = Color3.fromRGB(255, 50, 50),
    Flag = "ESP_Color",
    Callback = function(Value)
        Settings.ESPColor = Value
    end
})

ESPSection:CreateToggle({
        Name = "Weapon ESP",
    CurrentValue = false,
    Flag = "ESP_Weapons",
    Callback = function(Value)
        Settings.ESPWeapons = Value
        if Value then
            --// Scan for weapons in workspace
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Tool") or obj:IsA("Model") then
                    if obj.Name:lower():find("gun") or obj.Name:lower():find("rifle") or obj.Name:lower():find("sniper") or obj.Name:lower():find("weapon") then
                        CreateWeaponESP(obj)
                    end
                end
            end
        else
            for weapon, obj in pairs(WeaponESPObjects) do
                if obj then obj:Remove() end
            end
            WeaponESPObjects = {}
        end
    end
})

--// Aimbot Section
local AimbotSection = AimbotTab:CreateSection("Aimbot Settings")

AimbotSection:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Flag = "Aimbot_Toggle",
    Callback = function(Value)
        Settings.AimbotEnabled = Value
    end
})

AimbotSection:CreateToggle({
    Name = "Show FOV",
    CurrentValue = true,
    Flag = "Aimbot_FOVShow",
    Callback = function(Value)
        Settings.ShowFOV = Value
    end
})

AimbotSection:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Flag = "Aimbot_TeamCheck",
    Callback = function(Value)
        Settings.TeamCheck = Value
    end
})

AimbotSection:CreateToggle({
    Name = "Wall Check",
    CurrentValue = false,
    Flag = "Aimbot_WallCheck",
    Callback = function(Value)
        Settings.WallCheck = Value
    end
})

AimbotSection:CreateToggle({
    Name = "Trigger Bot",
    CurrentValue = false,
    Flag = "Aimbot_Trigger",
    Callback = function(Value)
        Settings.TriggerBot = Value
    end
})

AimbotSection:CreateDropdown({
    Name = "Aim Part",
    Options = {"Head", "Torso", "HumanoidRootPart"},
    CurrentOption = "Head",
    Flag = "Aimbot_Part",
    Callback = function(Value)
        Settings.AimPart = Value
    end
})

AimbotSection:CreateSlider({
    Name = "FOV",
    Range = {10, 400},
    Increment = 10,
    Suffix = "px",
    CurrentValue = 150,
    Flag = "Aimbot_FOV",
    Callback = function(Value)
        Settings.AimFov = Value
    end
})

AimbotSection:CreateSlider({
    Name = "Smoothness",
    Range = {1, 20},
    Increment = 1,
    Suffix = "",
    CurrentValue = 3,
    Flag = "Aimbot_Smooth",
    Callback = function(Value)
        Settings.AimSmooth = Value
    end
})

--// Movement Section
local MoveSection = MovementTab:CreateSection("Movement Hacks")

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
        Settings.FlyEnabled = Value
        if Value then
            StartFly()
        end
    end
})

MoveSection:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 200},
    Increment = 5,
    Suffix = "",
    CurrentValue = 50,
    Flag = "Move_FlySpeed",
    Callback = function(Value)
        Settings.FlySpeed = Value
    end
})

MoveSection:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "Move_Jump",
    Callback = function(Value)
        Settings.InfiniteJump = Value
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

MoveSection:CreateToggle({
    Name = "Auto-Win (Teleport to Finish)",
    CurrentValue = false,
    Flag = "Move_AutoWin",
    Callback = function(Value)
        Settings.AutoWin = Value
    end
})

--// IMBA Section
local IMBASection = IMBATab:CreateSection("IMBA Functions")

IMBASection:CreateToggle({
    Name = "God Mode",
    CurrentValue = false,
    Flag = "IMBA_God",
    Callback = function(Value)
        Settings.GodMode = Value
        UpdateGodMode()
    end
})

IMBASection:CreateToggle({
    Name = "Anti-Sniper (Dodge Bullets)",
    CurrentValue = false,
    Flag = "IMBA_AntiSniper",
    Callback = function(Value)
        Settings.AntiSniper = Value
    end
})

IMBASection:CreateToggle({
    Name = "Full Bright",
    CurrentValue = false,
    Flag = "IMBA_Bright",
    Callback = function(Value)
        Settings.FullBright = Value
    end
})

IMBASection:CreateButton({
    Name = "Teleport to Snipers",
    Callback = function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Team and player.Team.Name:lower():find("sniper") then
                local character = player.Character
                if character then
                    local hrp = character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame + Vector3.new(0, 5, 0)
                        Rayfield:Notify({
                            Title = "@aLiNa_grnt",
                            Content = "Teleported to sniper: " .. player.Name,
                            Duration = 3
                        })
                        break
                    end
                end
            end
        end
    end
})

IMBASection:CreateButton({
    Name = "Teleport to Random Player",
    Callback = function()
        local players = Players:GetPlayers()
        local randomPlayer = players[math.random(1, #players)]
        if randomPlayer ~= LocalPlayer and randomPlayer.Character then
            local hrp = randomPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame + Vector3.new(0, 5, 0)
                Rayfield:Notify({
                    Title = "@aLiNa_grnt",
                    Content = "Teleported to: " .. randomPlayer.Name,
                    Duration = 3
                })
            end
        end
    end
})

IMBASection:CreateButton({
    Name = "Kill All (Melee)",
    Callback = function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.Health = 0
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

IMBASection:CreateButton({
    Name = "Respawn at Start",
    Callback = function()
        local character = LocalPlayer.Character
        if character then
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                --// Find spawn location
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj.Name:lower():find("spawn") or obj.Name:lower():find("start") then
                        if obj:IsA("BasePart") then
                            hrp.CFrame = obj.CFrame + Vector3.new(0, 5, 0)
                            Rayfield:Notify({
                                Title = "@aLiNa_grnt",
                                Content = "Respawned at start!",
                                Duration = 3
                            })
                            break
                        end
                    end
                end
            end
        end
    end
})

IMBASection:CreateButton({
    Name = "Unlock All Guns",
    Callback = function()
        --// Attempt to unlock all tools
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("Tool") then
                local clone = obj:Clone()
                clone.Parent = LocalPlayer.Backpack
            end
        end
        Rayfield:Notify({
            Title = "@aLiNa_grnt",
            Content = "All guns unlocked!",
            Duration = 3
        })
    end
})

IMBASection:CreateButton({
    Name = "ESP All Items",
    Callback = function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Tool") or obj:IsA("Model") or obj:IsA("Part") then
                if obj.Name:lower():find("item") or obj.Name:lower():find("coin") or obj.Name:lower():find("gem") or obj.Name:lower():find("collect") then
                    CreateWeaponESP(obj)
                end
            end
        end
        Rayfield:Notify({
            Title = "@aLiNa_grnt",
            Content = "All items ESP enabled!",
            Duration = 3
        })
    end
})

--// Delta Compatibility
if not getgenv then getgenv = function() return _G end end
if not mousemoverel then 
    mousemoverel = function(x, y)
        local vim = game:GetService("VirtualInputManager")
        local currentPos = UserInputService:GetMouseLocation()
        vim:SendMouseMoveEvent(currentPos.X + x, currentPos.Y + y, game)
    end 
end
if not mouse1click then
    mouse1click = function()
        local vim = game:GetService("VirtualInputManager")
        vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.05)
        vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end
end

--// Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

--// Final Notification
Rayfield:Notify({
    Title = "@aLiNa_grnt",
    Content = "Snipers vs Runners IMBA Loaded! All features ready.",
    Duration = 6.5,
    Image = 4483345998,
    Actions = {
        Ignore = {
            Name = "Dominate!",
            Callback = function()
                print("User ready to dominate | @aLiNa_grnt")
            end
        }
    }
})

print("╔══════════════════════════════════════╗")
print("║  Snipers vs Runners | @aLiNa_grnt   ║")
print("║  Rayfield GUI | Delta Exploit        ║")
print("║  IMBA Features Fully Loaded          ║")
print("║  Aimbot + ESP + Movement + IMBA      ║")
print("║  Author: @aLiNa_grnt                 ║")
print("╚══════════════════════════════════════╝")
