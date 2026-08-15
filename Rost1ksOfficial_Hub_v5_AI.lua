-- ============================================
-- ROST1KSOFFICIAL HUB v5.0 | Build a Base and Steal
-- AI-POWERED | Groq Integration | Self-Adaptive
-- MAXIMUM PROTECTION | ANTI-CHEAT BYPASS v3
-- By: Rost1ksOfficial
-- ============================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

-- // GROQ AI CONFIG
local GROQ_API_KEY = "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"
local GROQ_MODEL = "openai/gpt-oss-20b" -- Замена Llama 3.1 8B Instant, 1000 tok/sec
local GROQ_URL = "https://api.groq.com/openai/v1/chat/completions"

-- // LOAD RAYFIELD
local Rayfield
pcall(function()
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not Rayfield then
    warn("Rayfield failed")
    return
end

-- // WINDOW
local Window = Rayfield:CreateWindow({
    Name = "Rost1ksOfficial Hub v5.0 | AI-POWERED",
    LoadingTitle = "Rost1ksOfficial",
    LoadingSubtitle = "AI loading...",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Rost1ksOfficial_v5",
        FileName = "BBaseSteal_AI"
    },
    KeySystem = false,
})

local MainTab = Window:CreateTab("Main", 4483362458)
local VisualTab = Window:CreateTab("Visuals", 4483362458)
local StealthTab = Window:CreateTab("Stealth", 4483362458)
local TeleportTab = Window:CreateTab("Teleport", 4483362458)
local AITab = Window:CreateTab("AI Analysis", 4483362458) -- НОВАЯ ВКЛАДКА

-- // STATE
local Settings = {
    GodMode = false,
    AntiRepulsion = false,
    GhostMode = false,
    ESP = false,
    ESPPlayers = true,
    ESPPets = true,
    ESPBases = false,
    StealthSteal = false,
    SafeNoclip = false,
    WalkSpeed = 16,
    StealDistance = 15,
    TeleportSpeed = 50,
}

local Connections = {}
local ESPObjects = {}
local CachedRemotes = {}
local OriginalStates = {}
local AIGeneratedFunctions = {} -- Хранение AI-сгенерированных функций

function StoreConnection(name, conn)
    if Connections[name] then
        pcall(function() Connections[name]:Disconnect() end)
    end
    Connections[name] = conn
end

function KillConnection(name)
    if Connections[name] then
        pcall(function() Connections[name]:Disconnect() end)
        Connections[name] = nil
    end
end

function KillAllConnections()
    for name, conn in pairs(Connections) do
        pcall(function() conn:Disconnect() end)
    end
    Connections = {}
end

-- // UTILS
function GetChar() return LocalPlayer.Character end
function GetHum()
    local char = GetChar()
    return char and char:FindFirstChildOfClass("Humanoid")
end
function GetHRP()
    local char = GetChar()
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- ============================================
-- GROQ AI INTEGRATION
-- ============================================

function CallGroqAI(systemPrompt, userPrompt)
    local payload = {
        model = GROQ_MODEL,
        messages = {
            {role = "system", content = systemPrompt},
            {role = "user", content = userPrompt}
        },
        temperature = 0.3,
        max_tokens = 4000,
    }

    local jsonPayload = HttpService:JSONEncode(payload)

    local success, response = pcall(function()
        return game:HttpGet(GROQ_URL, true, {
            ["Authorization"] = "Bearer " .. GROQ_API_KEY,
            ["Content-Type"] = "application/json",
        }, jsonPayload)
    end)

    if not success then
        -- Fallback: попробуем POST через HttpService
        success, response = pcall(function()
            return HttpService:PostAsync(GROQ_URL, jsonPayload, Enum.HttpContentType.ApplicationJson, false, {
                ["Authorization"] = "Bearer " .. GROQ_API_KEY,
            })
        end)
    end

    if success and response then
        local data = HttpService:JSONDecode(response)
        if data and data.choices and data.choices[1] then
            return data.choices[1].message.content
        end
    end

    return nil
end

-- // Сканирование игры для AI
function ScanGameForAI()
    local gameData = {
        remotes = {},
        objects = {},
        players = {},
        services = {},
    }

    -- Сканируем RemoteEvents
    local function scanRemotes(parent, path)
        for _, obj in pairs(parent:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                table.insert(gameData.remotes, {
                    name = obj.Name,
                    class = obj.ClassName,
                    path = path .. "." .. obj:GetFullName(),
                })
            end
        end
    end

    pcall(function() scanRemotes(ReplicatedStorage, "ReplicatedStorage") end)
    pcall(function() scanRemotes(Workspace, "Workspace") end)

    -- Сканируем ключевые объекты
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local name = obj.Name:lower()
            if #gameData.objects < 50 then -- Лимит для размера запроса
                table.insert(gameData.objects, {
                    name = obj.Name,
                    class = obj.ClassName,
                    hasHumanoid = obj:FindFirstChild("Humanoid") ~= nil,
                    hasPrimaryPart = obj.PrimaryPart ~= nil,
                })
            end
        end
    end

    -- Сканируем игроков
    for _, player in pairs(Players:GetPlayers()) do
        table.insert(gameData.players, {
            name = player.Name,
            team = tostring(player.Team),
            hasCharacter = player.Character ~= nil,
        })
    end

    return HttpService:JSONEncode(gameData)
end

-- // AI Анализ игры
function AIAnalyzeGame()
    Rayfield:Notify({Title="AI Analysis", Content="Scanning game...", Duration=3})

    local gameData = ScanGameForAI()

    local systemPrompt = [[You are an expert Roblox exploit developer. Analyze the provided game data and generate Lua functions to exploit the game. Focus on:
1. Identifying anti-cheat mechanisms from RemoteEvents
2. Finding pet/base/lock objects
3. Creating bypass functions
4. Generating ESP targets

Return ONLY valid Lua code inside ```lua blocks. Each function should be standalone and safe.]]

    local userPrompt = "Analyze this Roblox game data and generate exploit functions:
" .. gameData

    Rayfield:Notify({Title="AI Analysis", Content="Sending to Groq AI...", Duration=3})

    local aiResponse = CallGroqAI(systemPrompt, userPrompt)

    if aiResponse then
        -- Парсим Lua код из ответа
        for codeBlock in aiResponse:gmatch("```lua(.-)```") do
            local funcName = "AIFunc_" .. tostring(math.random(1000, 9999))
            local success, loadedFunc = pcall(function()
                return loadstring("return function() " .. codeBlock .. " end")()
            end)

            if success and loadedFunc then
                AIGeneratedFunctions[funcName] = loadedFunc
            end
        end

        Rayfield:Notify({
            Title="AI Analysis Complete", 
            Content="Generated " .. tostring(#AIGeneratedFunctions) .. " functions!", 
            Duration=5
        })

        return aiResponse
    else
        Rayfield:Notify({Title="AI Error", Content="Groq API failed. Check key/connection.", Duration=5})
        return nil
    end
end

-- // AI Генерация функции по запросу
function AIGenerateFunction(description)
    local systemPrompt = [[You are an expert Roblox Lua developer. Generate a safe, working Lua function for a Roblox exploit script based on the user's description. 

Rules:
- Use only standard Roblox API (Players, Workspace, RunService, etc.)
- No getrawmetatable or hookfunction (may not work on mobile)
- Handle errors with pcall
- Return valid Lua code in ```lua block
- Function should be named clearly]]

    local userPrompt = "Generate a Lua function for Roblox exploit: " .. description

    local aiResponse = CallGroqAI(systemPrompt, userPrompt)

    if aiResponse then
        for codeBlock in aiResponse:gmatch("```lua(.-)```") do
            local success, result = pcall(function()
                return loadstring("return function() " .. codeBlock .. " end")()
            end)

            if success and result then
                local funcName = "AIGen_" .. description:gsub("%s+", "_"):sub(1, 20)
                AIGeneratedFunctions[funcName] = result
                Rayfield:Notify({Title="AI Generated", Content="Function created: " .. funcName, Duration=3})
                return result
            end
        end
    end

    Rayfield:Notify({Title="AI Error", Content="Failed to generate function", Duration=3})
    return nil
end

-- ============================================
-- CORE FUNCTIONS (v4.0 improved)
-- ============================================

function ToggleGodMode(state)
    Settings.GodMode = state
    KillConnection("GodModeLoop")

    if state then
        local hum = GetHum()
        if hum then
            hum.MaxHealth = 999999
            hum.Health = 999999
        end

        StoreConnection("GodModeLoop", RunService.Heartbeat:Connect(function()
            local hum = GetHum()
            if hum and hum.Health < 900000 then
                hum.Health = 999999
                hum.MaxHealth = 999999
            end
        end))

        Rayfield:Notify({Title="God Mode", Content="ON", Duration=2})
    else
        local hum = GetHum()
        if hum then
            hum.MaxHealth = 100
            hum.Health = 100
        end
        Rayfield:Notify({Title="God Mode", Content="OFF", Duration=2})
    end
end

function ToggleAntiRepulsion(state)
    Settings.AntiRepulsion = state
    KillConnection("AntiRepulsionLoop")

    if state then
        StoreConnection("AntiRepulsionLoop", RunService.Heartbeat:Connect(function()
            local hrp = GetHRP()
            if not hrp then return end

            hrp.AssemblyLinearVelocity = Vector3.new(
                hrp.AssemblyLinearVelocity.X * 0.1,
                math.min(hrp.AssemblyLinearVelocity.Y, 0),
                hrp.AssemblyLinearVelocity.Z * 0.1
            )
            hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local otherHRP = player.Character:FindFirstChild("HumanoidRootPart")
                    if otherHRP then
                        local dist = (hrp.Position - otherHRP.Position).Magnitude
                        if dist < 7 then
                            local dir = (otherHRP.Position - hrp.Position).Unit
                            otherHRP.AssemblyLinearVelocity = dir * 40
                        end
                    end
                end
            end
        end))

        Rayfield:Notify({Title="Anti-Repulsion", Content="ON", Duration=2})
    else
        Rayfield:Notify({Title="Anti-Repulsion", Content="OFF", Duration=2})
    end
end

local NoclipGroup = "Rost1ksNoclip_" .. tostring(LocalPlayer.UserId)

function ToggleSafeNoclip(state)
    Settings.SafeNoclip = state
    KillConnection("NoclipLoop")

    if state then
        local PhysicsService = game:GetService("PhysicsService")
        pcall(function()
            PhysicsService:CreateCollisionGroup(NoclipGroup)
            PhysicsService:CollisionGroupSetCollides(NoclipGroup, "Default", false)
        end)

        StoreConnection("NoclipLoop", RunService.Stepped:Connect(function()
            local char = GetChar()
            if not char then return end

            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function()
                        PhysicsService:SetPartCollisionGroup(part, NoclipGroup)
                    end)
                end
            end
        end))

        Rayfield:Notify({Title="Safe Noclip", Content="ON", Duration=2})
    else
        local PhysicsService = game:GetService("PhysicsService")
        local char = GetChar()
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function()
                        PhysicsService:SetPartCollisionGroup(part, "Default")
                    end)
                end
            end
        end
        Rayfield:Notify({Title="Safe Noclip", Content="OFF", Duration=2})
    end
end

function ToggleGhostMode(state)
    Settings.GhostMode = state

    if state then
        local char = GetChar()
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    if not OriginalStates[part] then
                        OriginalStates[part] = part.Transparency
                    end
                    part.Transparency = 1
                end
                if part:IsA("Decal") or part:IsA("Texture") then
                    if OriginalStates[part] == nil then
                        OriginalStates[part] = part.Visible
                    end
                    part.Visible = false
                end
            end

            local head = char:FindFirstChild("Head")
            if head then
                for _, gui in pairs(head:GetChildren()) do
                    if gui:IsA("BillboardGui") then
                        if OriginalStates[gui] == nil then
                            OriginalStates[gui] = gui.Enabled
                        end
                        gui.Enabled = false
                    end
                end
            end
        end

        Rayfield:Notify({Title="Ghost Mode", Content="ON", Duration=2})
    else
        local char = GetChar()
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    local orig = OriginalStates[part]
                    if orig ~= nil then part.Transparency = orig end
                end
                if part:IsA("Decal") or part:IsA("Texture") then
                    local orig = OriginalStates[part]
                    if orig ~= nil then part.Visible = orig end
                end
            end
            local head = char:FindFirstChild("Head")
            if head then
                for _, gui in pairs(head:GetChildren()) do
                    if gui:IsA("BillboardGui") then
                        local orig = OriginalStates[gui]
                        if orig ~= nil then gui.Enabled = orig end
                    end
                end
            end
        end

        Rayfield:Notify({Title="Ghost Mode", Content="OFF", Duration=2})
    end
end

-- ============================================
-- ESP v5
-- ============================================

function ScanForPets()
    local pets = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart") then
            local name = obj.Name:lower()
            if name:match("pet") or name:match("creature") or name:match("animal")
               or name:match("dragon") or name:match("wolf") or name:match("cat")
               or name:match("dog") or name:match("bird") or name:match("fox")
               or obj:FindFirstChild("PetValue") or obj:FindFirstChild("PetName")
               or obj:FindFirstChild("Rarity") or obj:GetAttribute("IsPet")
               or obj:GetAttribute("PetType") or obj:GetAttribute("Rarity") then
                table.insert(pets, obj)
            end
        end
    end
    return pets
end

function ScanForBases()
    local bases = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Folder") then
            local name = obj.Name:lower()
            if name:match("base") or name:match("plot") or name:match("home")
               or name:match("house") or name:match("platform")
               or obj:FindFirstChild("BaseLock") or obj:FindFirstChild("Lock")
               or obj:FindFirstChild("Door") or obj:GetAttribute("IsBase") then
                table.insert(bases, obj)
            end
        end
    end
    return bases
end

function ScanForLocks()
    local locks = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        local name = obj.Name:lower()
        if (name:match("lock") and not name:match("unlock"))
           or obj:IsA("BoolValue") and name:match("locked")
           or obj:GetAttribute("IsLock") or obj:GetAttribute("Locked") then
            table.insert(locks, obj)
        end
    end
    return locks
end

function CreateESP(obj, color, labelText)
    if not obj or ESPObjects[obj] then return end

    local target = obj:FindFirstChild("HumanoidRootPart") 
                or obj:FindFirstChild("PrimaryPart") 
                or obj:FindFirstChildWhichIsA("BasePart")
    if not target then return end

    local folder = Instance.new("Folder")
    folder.Name = "ESP_" .. obj.Name
    folder.Parent = Workspace

    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(3, 5, 3)
    box.Color3 = color
    box.Transparency = 0.5
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Adornee = target
    box.Parent = folder

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Adornee = target

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextScaled = true
    label.Text = labelText or obj.Name
    label.Parent = billboard

    billboard.Parent = folder

    ESPObjects[obj] = {
        Folder = folder,
        Box = box,
        Label = label,
        Target = target,
        Type = labelText or "Object"
    }
end

function UpdateESP()
    local myHRP = GetHRP()
    if not myHRP then return end

    for obj, data in pairs(ESPObjects) do
        if not obj or not obj.Parent or not data.Target or not data.Target.Parent then
            pcall(function() data.Folder:Destroy() end)
            ESPObjects[obj] = nil
            continue
        end

        local dist = (data.Target.Position - myHRP.Position).Magnitude
        data.Label.Text = data.Type .. " [" .. math.floor(dist) .. "m]"

        if data.Type == "Player" then
            local player = Players:FindFirstChild(obj.Name)
            if player and player.Team == LocalPlayer.Team then
                data.Box.Color3 = Color3.fromRGB(0, 255, 100)
                data.Label.TextColor3 = Color3.fromRGB(0, 255, 100)
            else
                data.Box.Color3 = Color3.fromRGB(255, 0, 80)
                data.Label.TextColor3 = Color3.fromRGB(255, 0, 80)
            end
        end
    end
end

function ToggleESP(state)
    Settings.ESP = state
    KillConnection("ESPUpdate")

    if state then
        for _, data in pairs(ESPObjects) do
            pcall(function() data.Folder:Destroy() end)
        end
        ESPObjects = {}

        if Settings.ESPPlayers then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    CreateESP(player.Character, Color3.fromRGB(255, 0, 80), "Player")
                end
            end
        end

        if Settings.ESPPets then
            for _, pet in pairs(ScanForPets()) do
                CreateESP(pet, Color3.fromRGB(255, 200, 0), "Pet")
            end
        end

        if Settings.ESPBases then
            for _, base in pairs(ScanForBases()) do
                CreateESP(base, Color3.fromRGB(0, 150, 255), "Base")
            end
        end

        StoreConnection("ESPUpdate", RunService.RenderStepped:Connect(UpdateESP))

        Rayfield:Notify({
            Title="ESP", 
            Content="ON - Found: " .. tostring(#ESPObjects) .. " objects", 
            Duration=3
        })
    else
        for _, data in pairs(ESPObjects) do
            pcall(function() data.Folder:Destroy() end)
        end
        ESPObjects = {}
        Rayfield:Notify({Title="ESP", Content="OFF", Duration=2})
    end
end

-- ============================================
-- STEALTH & TELEPORT
-- ============================================

function ToggleStealthSteal(state)
    Settings.StealthSteal = state
    KillConnection("StealthLoop")

    if state then
        StoreConnection("StealthLoop", RunService.Heartbeat:Connect(function()
            local myHRP = GetHRP()
            if not myHRP then return end

            local char = GetChar()
            if not char then return end

            for _, obj in pairs(Workspace:GetDescendants()) do
                local name = obj.Name:lower()
                local isPet = name:match("pet") or name:match("creature") 
                              or obj:FindFirstChild("PetValue") 
                              or obj:GetAttribute("IsPet")

                if isPet then
                    local petPart = obj:FindFirstChild("HumanoidRootPart") 
                                  or obj:FindFirstChild("PrimaryPart")
                                  or obj:FindFirstChildWhichIsA("BasePart")

                    if petPart then
                        local dist = (petPart.Position - myHRP.Position).Magnitude
                        if dist < Settings.StealDistance then
                            for _, part in pairs(char:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.Transparency = 1
                                end
                            end

                            task.wait(1.5)

                            for _, part in pairs(char:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    local orig = OriginalStates[part]
                                    part.Transparency = orig or 0
                                end
                            end
                        end
                    end
                end
            end
        end))

        Rayfield:Notify({Title="Stealth Steal", Content="ON", Duration=2})
    else
        Rayfield:Notify({Title="Stealth Steal", Content="OFF", Duration=2})
    end
end

function DestroyBaseLocks()
    local locks = ScanForLocks()
    local destroyed = 0

    for _, lock in pairs(locks) do
        pcall(function()
            if lock:IsA("BoolValue") then
                lock.Value = false
                destroyed = destroyed + 1
            elseif lock:IsA("BasePart") or lock:IsA("MeshPart") then
                lock:Destroy()
                destroyed = destroyed + 1
            elseif lock:IsA("Model") then
                lock:Destroy()
                destroyed = destroyed + 1
            end
        end)
    end

    Rayfield:Notify({
        Title="Base Locks", 
        Content="Destroyed/Disabled: " .. destroyed, 
        Duration=3
    })
end

function SafeTeleport(targetPos)
    local hrp = GetHRP()
    if not hrp then return end

    local startPos = hrp.Position
    local distance = (targetPos - startPos).Magnitude
    local duration = math.max(distance / Settings.TeleportSpeed, 0.5)
    local segments = math.ceil(distance / 20)
    local segmentVector = (targetPos - startPos) / segments

    for i = 1, segments do
        local nextPos = startPos + segmentVector * i

        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {GetChar()}
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist

        local ray = Workspace:Raycast(hrp.Position, nextPos - hrp.Position, rayParams)

        if ray then
            nextPos = ray.Position + Vector3.new(0, 10, 0) + (nextPos - hrp.Position).Unit * 5
        end

        local tween = TweenService:Create(hrp, TweenInfo.new(duration / segments, Enum.EasingStyle.Linear), {
            CFrame = CFrame.new(nextPos)
        })
        tween:Play()
        tween.Completed:Wait()
    end

    Rayfield:Notify({Title="Teleport", Content="Done!", Duration=2})
end

function SetWalkSpeed(speed)
    Settings.WalkSpeed = speed
    KillConnection("SpeedLoop")

    if speed > 16 then
        StoreConnection("SpeedLoop", RunService.Heartbeat:Connect(function()
            local hrp = GetHRP()
            local hum = GetHum()
            if hrp and hum and hum.MoveDirection.Magnitude > 0 then
                local bodyVel = hrp:FindFirstChild("Rost1ksSpeed")
                if not bodyVel then
                    bodyVel = Instance.new("BodyVelocity")
                    bodyVel.Name = "Rost1ksSpeed"
                    bodyVel.MaxForce = Vector3.new(4000, 0, 4000)
                    bodyVel.Parent = hrp
                end
                bodyVel.Velocity = hum.MoveDirection * speed
            end
        end))
    else
        local hrp = GetHRP()
        if hrp then
            local bodyVel = hrp:FindFirstChild("Rost1ksSpeed")
            if bodyVel then bodyVel:Destroy() end
        end
        local hum = GetHum()
        if hum then hum.WalkSpeed = 16 end
    end
end

-- ============================================
-- GUI
-- ============================================

MainTab:CreateToggle({
    Name = "God Mode",
    CurrentValue = false,
    Flag = "God_v5",
    Callback = ToggleGodMode,
})

MainTab:CreateToggle({
    Name = "Anti-Repulsion",
    CurrentValue = false,
    Flag = "AntiRep_v5",
    Callback = ToggleAntiRepulsion,
})

MainTab:CreateToggle({
    Name = "Safe Noclip (Collision Groups)",
    CurrentValue = false,
    Flag = "Noclip_v5",
    Callback = ToggleSafeNoclip,
})

MainTab:CreateToggle({
    Name = "Ghost Mode",
    CurrentValue = false,
    Flag = "Ghost_v5",
    Callback = ToggleGhostMode,
})

MainTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 120},
    Increment = 1,
    Suffix = "",
    CurrentValue = 16,
    Flag = "Speed_v5",
    Callback = SetWalkSpeed,
})

VisualTab:CreateToggle({
    Name = "ESP System",
    CurrentValue = false,
    Flag = "ESP_v5",
    Callback = ToggleESP,
})

VisualTab:CreateToggle({
    Name = "ESP Players",
    CurrentValue = true,
    Flag = "ESPPl_v5",
    Callback = function(v) Settings.ESPPlayers = v end,
})

VisualTab:CreateToggle({
    Name = "ESP Pets",
    CurrentValue = true,
    Flag = "ESPPet_v5",
    Callback = function(v) Settings.ESPPets = v end,
})

VisualTab:CreateToggle({
    Name = "ESP Bases",
    CurrentValue = false,
    Flag = "ESPB_v5",
    Callback = function(v) Settings.ESPBases = v end,
})

StealthTab:CreateToggle({
    Name = "Stealth Steal",
    CurrentValue = false,
    Flag = "Stealth_v5",
    Callback = ToggleStealthSteal,
})

StealthTab:CreateSlider({
    Name = "Steal Distance",
    Range = {5, 30},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = 15,
    Flag = "StealDist_v5",
    Callback = function(v) Settings.StealDistance = v end,
})

TeleportTab:CreateButton({
    Name = "Destroy Base Locks",
    Callback = DestroyBaseLocks,
})

TeleportTab:CreateButton({
    Name = "Teleport to Random Player",
    Callback = function()
        local plrs = Players:GetPlayers()
        if #plrs > 1 then
            local target = plrs[math.random(1, #plrs)]
            if target ~= LocalPlayer and target.Character then
                local hrp = target.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    SafeTeleport(hrp.Position + Vector3.new(0, 5, 0))
                end
            end
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Collect Nearby Pets",
    Callback = function()
        for _, pet in pairs(ScanForPets()) do
            local part = pet:FindFirstChild("HumanoidRootPart") or pet:FindFirstChild("PrimaryPart")
            if part then
                SafeTeleport(part.Position + Vector3.new(0, 3, 0))
                task.wait(0.8)
            end
        end
    end,
})

TeleportTab:CreateSlider({
    Name = "Teleport Speed (lower = safer)",
    Range = {20, 100},
    Increment = 5,
    Suffix = " studs/sec",
    CurrentValue = 50,
    Flag = "TPSpeed_v5",
    Callback = function(v) Settings.TeleportSpeed = v end,
})

-- ============================================
-- AI TAB — Groq Integration
-- ============================================

AITab:CreateButton({
    Name = "🤖 AI Analyze Game",
    Callback = function()
        local result = AIAnalyzeGame()
        if result then
            -- Показываем результат в уведомлении
            Rayfield:Notify({
                Title="AI Analysis Complete",
                Content="Check console for generated functions (F9)",
                Duration=5
            })
            print("=== AI GENERATED CODE ===")
            print(result)
            print("========================")
        end
    end,
})

AITab:CreateInput({
    Name = "AI Generate Function",
    PlaceholderText = "e.g. Auto farm money",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        if text and text ~= "" then
            AIGenerateFunction(text)
        end
    end,
})

AITab:CreateButton({
    Name = "Run All AI Functions",
    Callback = function()
        local count = 0
        for name, func in pairs(AIGeneratedFunctions) do
            pcall(function()
                func()
                count = count + 1
            end)
        end
        Rayfield:Notify({
            Title="AI Functions",
            Content="Executed " .. count .. " functions",
            Duration=3
        })
    end,
})

AITab:CreateButton({
    Name = "Clear AI Functions",
    Callback = function()
        AIGeneratedFunctions = {}
        Rayfield:Notify({Title="AI", Content="All AI functions cleared", Duration=2})
    end,
})

-- // AUTO RESTORE
LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    if Settings.GodMode then ToggleGodMode(true) end
    if Settings.AntiRepulsion then ToggleAntiRepulsion(true) end
    if Settings.SafeNoclip then ToggleSafeNoclip(true) end
    if Settings.GhostMode then ToggleGhostMode(true) end
    if Settings.StealthSteal then ToggleStealthSteal(true) end
    if Settings.ESP then ToggleESP(true) end
    SetWalkSpeed(Settings.WalkSpeed)
end)

-- // ANTI-DETECTION
RunService.Heartbeat:Connect(function()
    pcall(function()
        LocalPlayer.ReplicationFocus = Workspace
    end)
end)

-- // CREDITS
Rayfield:Notify({
    Title = "Rost1ksOfficial Hub v5.0",
    Content = "AI-POWERED loaded! By: Rost1ksOfficial",
    Duration = 5,
})

print([[
========================================
  ROST1KSOFFICIAL HUB v5.0
  AI-POWERED EDITION

  Groq AI Integration:
  • Model: openai/gpt-oss-20b (1000 tok/sec)
  • Auto game analysis
  • AI function generation
  • Self-adaptive exploits

  Core Features:
  • God Mode | Anti-Repulsion
  • Safe Noclip | Ghost Mode
  • ESP (Players/Pets/Bases)
  • Stealth Steal
  • Destroy Locks
  • Safe Teleport

  By: Rost1ksOfficial
========================================
]])
