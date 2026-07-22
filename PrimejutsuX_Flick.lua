-- ================================================
--   Primejtsu X | Flick Script
--   Rayfield GUI | Full Working Edition
-- ================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Services
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local Camera            = workspace.CurrentCamera
local LP                = Players.LocalPlayer

-- ================================================
-- Settings
-- ================================================
local Cfg = {
    -- ESP
    ESPEnabled      = false,
    ESPMode         = "Highlight",   -- "Highlight" | "Box" | "Tracer"
    ESPFillColor    = Color3.fromRGB(255, 0, 0),
    ESPOutlineColor = Color3.fromRGB(255, 255, 255),
    ESPFillTransp   = 0.5,

    -- FOV
    FOVEnabled  = false,
    FOVRadius   = 120,
    FOVColor    = Color3.fromRGB(255, 255, 0),
    FOVThick    = 1.5,

    -- Aimbot
    AimbotEnabled   = false,
    AimbotSmooth    = 0.15,
    AimbotPart      = "Head",
    AimbotKey       = Enum.UserInputType.MouseButton2,

    -- Silent Aim
    SilentEnabled   = false,

    -- Movement
    InfJump     = false,
    SpeedEnabled = false,
    SpeedValue  = 40,
    NoclipOn    = false,
    NoFallOn    = false,

    -- Misc
    FullBright  = false,
    AntiAFK     = false,
}

-- ================================================
-- FOV Circle (Drawing API)
-- ================================================
local FOVDraw = Drawing.new("Circle")
FOVDraw.Visible   = false
FOVDraw.Thickness = Cfg.FOVThick
FOVDraw.Color     = Cfg.FOVColor
FOVDraw.Filled    = false
FOVDraw.NumSides  = 128
FOVDraw.Radius    = Cfg.FOVRadius
FOVDraw.Position  = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

-- ================================================
-- ESP Storage
-- ================================================
local ESPObjects = {}    -- [player] = { highlight, boxLines, tracer }

local function clearESPForPlayer(player)
    if ESPObjects[player] then
        -- Highlight
        if ESPObjects[player].highlight then
            ESPObjects[player].highlight:Destroy()
        end
        -- Box
        if ESPObjects[player].box then
            for _, line in pairs(ESPObjects[player].box) do
                line:Remove()
            end
        end
        -- Tracer
        if ESPObjects[player].tracer then
            ESPObjects[player].tracer:Remove()
        end
        ESPObjects[player] = nil
    end
end

local function createHighlightESP(player)
    if player == LP then return end
    local hl = Instance.new("Highlight")
    hl.FillColor        = Cfg.ESPFillColor
    hl.OutlineColor     = Cfg.ESPOutlineColor
    hl.FillTransparency = Cfg.ESPFillTransp
    hl.DepthMode        = Enum.HighlightDepthMode.AlwaysOnTop
    if player.Character then hl.Parent = player.Character end
    player.CharacterAdded:Connect(function(char) hl.Parent = char end)
    ESPObjects[player] = { highlight = hl }
end

local function createBoxESP(player)
    if player == LP then return end
    local lines = {}
    for i = 1, 4 do
        local l = Drawing.new("Line")
        l.Visible   = false
        l.Color     = Cfg.ESPFillColor
        l.Thickness = 1.5
        lines[i] = l
    end
    ESPObjects[player] = { box = lines }
end

local function createTracerESP(player)
    if player == LP then return end
    local tracer = Drawing.new("Line")
    tracer.Visible   = false
    tracer.Color     = Cfg.ESPFillColor
    tracer.Thickness = 1.5
    ESPObjects[player] = { tracer = tracer }
end

local function applyESP(player)
    clearESPForPlayer(player)
    if not Cfg.ESPEnabled then return end
    if Cfg.ESPMode == "Highlight" then
        createHighlightESP(player)
    elseif Cfg.ESPMode == "Box" then
        createBoxESP(player)
    elseif Cfg.ESPMode == "Tracer" then
        createTracerESP(player)
    end
end

local function refreshAllESP()
    for _, p in pairs(Players:GetPlayers()) do
        applyESP(p)
    end
end

Players.PlayerAdded:Connect(function(p)
    if Cfg.ESPEnabled then applyESP(p) end
end)
Players.PlayerRemoving:Connect(function(p)
    clearESPForPlayer(p)
end)

-- Update Box / Tracer each frame
RunService.RenderStepped:Connect(function()
    -- FOV Circle
    FOVDraw.Visible  = Cfg.FOVEnabled
    FOVDraw.Radius   = Cfg.FOVRadius
    FOVDraw.Color    = Cfg.FOVColor
    FOVDraw.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for player, obj in pairs(ESPObjects) do
        if player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")

            -- Box ESP
            if obj.box and root then
                local pos, vis = Camera:WorldToViewportPoint(root.Position)
                if vis then
                    local size = 2000 / pos.Z
                    local x, y = pos.X, pos.Y
                    local w, h = size * 0.4, size * 1.2
                    -- top, bottom, left, right
                    local corners = {
                        { Vector2.new(x - w, y - h), Vector2.new(x + w, y - h) },
                        { Vector2.new(x - w, y + h), Vector2.new(x + w, y + h) },
                        { Vector2.new(x - w, y - h), Vector2.new(x - w, y + h) },
                        { Vector2.new(x + w, y - h), Vector2.new(x + w, y + h) },
                    }
                    for i, c in ipairs(corners) do
                        obj.box[i].From    = c[1]
                        obj.box[i].To      = c[2]
                        obj.box[i].Color   = Cfg.ESPFillColor
                        obj.box[i].Visible = true
                    end
                else
                    for _, l in pairs(obj.box) do l.Visible = false end
                end
            end

            -- Tracer ESP
            if obj.tracer and root then
                local pos, vis = Camera:WorldToViewportPoint(root.Position)
                if vis then
                    obj.tracer.From    = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    obj.tracer.To      = Vector2.new(pos.X, pos.Y)
                    obj.tracer.Color   = Cfg.ESPFillColor
                    obj.tracer.Visible = true
                else
                    obj.tracer.Visible = false
                end
            end
        end
    end
end)

-- ================================================
-- Aimbot Helper
-- ================================================
local function getTarget()
    local best     = nil
    local bestDist = Cfg.FOVRadius   -- only lock inside FOV
    local cx = Camera.ViewportSize.X / 2
    local cy = Camera.ViewportSize.Y / 2

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local part = p.Character:FindFirstChild(Cfg.AimbotPart)
                          or p.Character:FindFirstChild("HumanoidRootPart")
                if part then
                    local sPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = math.sqrt((sPos.X - cx)^2 + (sPos.Y - cy)^2)
                        if dist < bestDist then
                            bestDist = dist
                            best     = part
                        end
                    end
                end
            end
        end
    end
    return best
end

-- ================================================
-- Aimbot Loop
-- ================================================
RunService.RenderStepped:Connect(function()
    if Cfg.AimbotEnabled and UserInputService:IsMouseButtonPressed(Cfg.AimbotKey) then
        local target = getTarget()
        if target then
            local goalCF = CFrame.lookAt(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(goalCF, Cfg.AimbotSmooth)
        end
    end
end)

-- ================================================
-- Silent Aim
-- ================================================
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args   = {...}
    local method = getnamecallmethod()

    if Cfg.SilentEnabled and method == "FireServer" then
        local target = getTarget()
        if target then
            -- Replace positional args that look like Vector3 hit positions
            for i, v in ipairs(args) do
                if typeof(v) == "Vector3" then
                    args[i] = target.Position
                elseif typeof(v) == "CFrame" then
                    args[i] = CFrame.new(target.Position)
                elseif typeof(v) == "Instance" and v:IsA("BasePart") then
                    args[i] = target
                end
            end
        end
    end
    return oldNamecall(self, table.unpack(args))
end)

-- ================================================
-- Movement
-- ================================================
UserInputService.JumpRequest:Connect(function()
    if Cfg.InfJump and LP.Character then
        local h = LP.Character:FindFirstChild("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

RunService.Heartbeat:Connect(function()
    if LP.Character then
        local h = LP.Character:FindFirstChild("Humanoid")
        if h then
            if Cfg.SpeedEnabled then h.WalkSpeed = Cfg.SpeedValue
            else h.WalkSpeed = 16 end
        end
    end
end)

RunService.Stepped:Connect(function()
    if Cfg.NoclipOn and LP.Character then
        for _, p in pairs(LP.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

LP.CharacterAdded:Connect(function(char)
    local h = char:WaitForChild("Humanoid")
    h.StateChanged:Connect(function(_, new)
        if Cfg.NoFallOn and new == Enum.HumanoidStateType.Freefall then
            h:ChangeState(Enum.HumanoidStateType.Running)
        end
    end)
end)

-- ================================================
-- Fullbright
-- ================================================
local function setFullBright(on)
    local lighting = game:GetService("Lighting")
    if on then
        lighting.Brightness  = 10
        lighting.ClockTime   = 14
        lighting.FogEnd      = 100000
        lighting.GlobalShadows = false
        lighting.Ambient     = Color3.fromRGB(255,255,255)
    else
        lighting.Brightness  = 1
        lighting.ClockTime   = 14
        lighting.FogEnd      = 100000
        lighting.GlobalShadows = true
        lighting.Ambient     = Color3.fromRGB(127,127,127)
    end
end

-- ================================================
-- Anti-AFK
-- ================================================
local afkConn
local function toggleAntiAFK(on)
    if on then
        afkConn = RunService.Heartbeat:Connect(function()
            LP.Idled:Connect(function() end)
        end)
        local vrs = game:GetService("VirtualInputManager")
        task.spawn(function()
            while Cfg.AntiAFK do
                vrs:SendKeyEvent(true,  Enum.KeyCode.W, false, game)
                task.wait(60)
                vrs:SendKeyEvent(false, Enum.KeyCode.W, false, game)
                task.wait(1)
            end
        end)
    else
        if afkConn then afkConn:Disconnect() end
    end
end

-- ================================================
-- RAYFIELD GUI
-- ================================================
local Window = Rayfield:CreateWindow({
    Name              = "Primejtsu X | Flick Script",
    LoadingTitle      = "Primejtsu X",
    LoadingSubtitle   = "Flick Script - Loading...",
    Theme             = "Default",
    DisableRayfieldPrompts   = false,
    DisableBuildWarnings     = false,
})

-- ================================================
-- TAB: ESP
-- ================================================
local TabESP = Window:CreateTab("ESP", 4483362458)

TabESP:CreateToggle({
    Name         = "Enable ESP",
    CurrentValue = false,
    Flag         = "ESPToggle",
    Callback     = function(v)
        Cfg.ESPEnabled = v
        refreshAllESP()
    end,
})

TabESP:CreateDropdown({
    Name          = "ESP Mode",
    Options       = {"Highlight", "Box", "Tracer"},
    CurrentOption = {"Highlight"},
    Flag          = "ESPMode",
    Callback      = function(opt)
        Cfg.ESPMode = opt[1]
        refreshAllESP()
    end,
})

TabESP:CreateDropdown({
    Name          = "ESP Color",
    Options       = {"Red", "Green", "Blue", "Yellow", "Purple", "Cyan", "White", "Orange"},
    CurrentOption = {"Red"},
    Flag          = "ESPColor",
    Callback      = function(opt)
        local colors = {
            Red    = Color3.fromRGB(255, 0,   0),
            Green  = Color3.fromRGB(0,   255, 0),
            Blue   = Color3.fromRGB(0,   100, 255),
            Yellow = Color3.fromRGB(255, 255, 0),
            Purple = Color3.fromRGB(180, 0,   255),
            Cyan   = Color3.fromRGB(0,   255, 255),
            White  = Color3.fromRGB(255, 255, 255),
            Orange = Color3.fromRGB(255, 140, 0),
        }
        local c = colors[opt[1]]
        if c then
            Cfg.ESPFillColor    = c
            Cfg.ESPOutlineColor = c
            refreshAllESP()
        end
    end,
})

TabESP:CreateSlider({
    Name         = "Highlight Transparency",
    Range        = {0, 10},
    Increment    = 1,
    CurrentValue = 5,
    Flag         = "ESPTransp",
    Callback     = function(v)
        Cfg.ESPFillTransp = v / 10
        refreshAllESP()
    end,
})

-- ================================================
-- TAB: Aim
-- ================================================
local TabAim = Window:CreateTab("Aimbot", 4483362458)

TabAim:CreateToggle({
    Name         = "Aimbot (Hold RMB)",
    CurrentValue = false,
    Flag         = "AimbotToggle",
    Callback     = function(v) Cfg.AimbotEnabled = v end,
})

TabAim:CreateToggle({
    Name         = "Silent Aim",
    CurrentValue = false,
    Flag         = "SilentToggle",
    Callback     = function(v) Cfg.SilentEnabled = v end,
})

TabAim:CreateToggle({
    Name         = "FOV Circle",
    CurrentValue = false,
    Flag         = "FOVToggle",
    Callback     = function(v) Cfg.FOVEnabled = v end,
})

TabAim:CreateSlider({
    Name         = "FOV Radius",
    Range        = {30, 500},
    Increment    = 5,
    CurrentValue = 120,
    Flag         = "FOVRadius",
    Callback     = function(v) Cfg.FOVRadius = v end,
})

TabAim:CreateSlider({
    Name         = "Aim Smoothness (lower = faster)",
    Range        = {1, 100},
    Increment    = 1,
    CurrentValue = 15,
    Flag         = "AimSmooth",
    Callback     = function(v) Cfg.AimbotSmooth = v / 100 end,
})

TabAim:CreateDropdown({
    Name          = "Aim Part",
    Options       = {"Head", "HumanoidRootPart", "UpperTorso", "Torso"},
    CurrentOption = {"Head"},
    Flag          = "AimPart",
    Callback      = function(opt) Cfg.AimbotPart = opt[1] end,
})

TabAim:CreateDropdown({
    Name          = "FOV Color",
    Options       = {"Yellow", "Red", "Green", "Blue", "White", "Cyan"},
    CurrentOption = {"Yellow"},
    Flag          = "FOVColor",
    Callback      = function(opt)
        local colors = {
            Yellow = Color3.fromRGB(255,255,0),
            Red    = Color3.fromRGB(255,0,0),
            Green  = Color3.fromRGB(0,255,0),
            Blue   = Color3.fromRGB(0,100,255),
            White  = Color3.fromRGB(255,255,255),
            Cyan   = Color3.fromRGB(0,255,255),
        }
        if colors[opt[1]] then Cfg.FOVColor = colors[opt[1]] end
    end,
})

-- ================================================
-- TAB: Movement
-- ================================================
local TabMove = Window:CreateTab("Movement", 4483362458)

TabMove:CreateToggle({
    Name         = "Infinite Jump",
    CurrentValue = false,
    Flag         = "InfJump",
    Callback     = function(v) Cfg.InfJump = v end,
})

TabMove:CreateToggle({
    Name         = "Speed Hack",
    CurrentValue = false,
    Flag         = "SpeedHack",
    Callback     = function(v) Cfg.SpeedEnabled = v end,
})

TabMove:CreateSlider({
    Name         = "Walk Speed",
    Range        = {16, 200},
    Increment    = 1,
    CurrentValue = 40,
    Flag         = "WalkSpeed",
    Callback     = function(v) Cfg.SpeedValue = v end,
})

TabMove:CreateToggle({
    Name         = "Noclip",
    CurrentValue = false,
    Flag         = "Noclip",
    Callback     = function(v) Cfg.NoclipOn = v end,
})

TabMove:CreateToggle({
    Name         = "No Fall Damage",
    CurrentValue = false,
    Flag         = "NoFall",
    Callback     = function(v) Cfg.NoFallOn = v end,
})

-- ================================================
-- TAB: Misc
-- ================================================
local TabMisc = Window:CreateTab("Misc", 4483362458)

TabMisc:CreateToggle({
    Name         = "Fullbright",
    CurrentValue = false,
    Flag         = "Fullbright",
    Callback     = function(v)
        Cfg.FullBright = v
        setFullBright(v)
    end,
})

TabMisc:CreateToggle({
    Name         = "Anti-AFK",
    CurrentValue = false,
    Flag         = "AntiAFK",
    Callback     = function(v)
        Cfg.AntiAFK = v
        toggleAntiAFK(v)
    end,
})

TabMisc:CreateButton({
    Name     = "Teleport to Spawn",
    Callback = function()
        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            LP.Character.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
        end
    end,
})

TabMisc:CreateButton({
    Name     = "Respawn Character",
    Callback = function()
        if LP.Character then
            local h = LP.Character:FindFirstChild("Humanoid")
            if h then h.Health = 0 end
        end
    end,
})

TabMisc:CreateButton({
    Name     = "Copy Username",
    Callback = function()
        Rayfield:Notify({
            Title    = "Username",
            Content  = LP.Name,
            Duration = 3,
            Image    = 4483362458,
        })
    end,
})

TabMisc:CreateButton({
    Name     = "Rejoin Game",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        TeleportService:Teleport(game.PlaceId, LP)
    end,
})

-- ================================================
-- Startup Notification
-- ================================================
Rayfield:Notify({
    Title    = "Primejtsu X | Flick Script",
    Content  = "Loaded successfully. Good luck!",
    Duration = 5,
    Image    = 4483362458,
})

print("[Primejtsu X] Loaded.")
