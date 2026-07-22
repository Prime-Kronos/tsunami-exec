-- ================================================
--   Primejtsu X | Flick Script
--   Mobile Edition - GUI Aimbot Button
-- ================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera           = workspace.CurrentCamera
local LP               = Players.LocalPlayer

local Cfg = {
    ESPEnabled      = false,
    ESPMode         = "Highlight",
    ESPFillColor    = Color3.fromRGB(255, 0, 0),
    ESPOutlineColor = Color3.fromRGB(255, 255, 255),
    ESPFillTransp   = 0.5,

    FOVEnabled  = false,
    FOVRadius   = 150,
    FOVColor    = Color3.fromRGB(255, 255, 0),

    AimbotEnabled = false,
    AimbotSmooth  = 0.2,
    AimbotPart    = "Head",

    InfJump      = false,
    SpeedEnabled = false,
    SpeedValue   = 40,
    NoclipOn     = false,
    NoFallOn     = false,
    FullBright   = false,
}

-- ================================================
-- FOV Circle
-- ================================================
local FOVDraw = Drawing.new("Circle")
FOVDraw.Visible   = false
FOVDraw.Thickness = 1.5
FOVDraw.Color     = Cfg.FOVColor
FOVDraw.Filled    = false
FOVDraw.NumSides  = 128
FOVDraw.Radius    = Cfg.FOVRadius
FOVDraw.Position  = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

-- ================================================
-- ESP
-- ================================================
local ESPObjects = {}

local function clearESP(player)
    if not ESPObjects[player] then return end
    if ESPObjects[player].highlight then ESPObjects[player].highlight:Destroy() end
    if ESPObjects[player].box then
        for _, l in pairs(ESPObjects[player].box) do l:Remove() end
    end
    if ESPObjects[player].tracer then ESPObjects[player].tracer:Remove() end
    ESPObjects[player] = nil
end

local function makeHighlight(player)
    if player == LP then return end
    local hl = Instance.new("Highlight")
    hl.FillColor        = Cfg.ESPFillColor
    hl.OutlineColor     = Cfg.ESPOutlineColor
    hl.FillTransparency = Cfg.ESPFillTransp
    hl.DepthMode        = Enum.HighlightDepthMode.AlwaysOnTop
    if player.Character then hl.Parent = player.Character end
    player.CharacterAdded:Connect(function(c) hl.Parent = c end)
    ESPObjects[player] = { highlight = hl }
end

local function makeBox(player)
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

local function makeTracer(player)
    if player == LP then return end
    local t = Drawing.new("Line")
    t.Visible   = false
    t.Color     = Cfg.ESPFillColor
    t.Thickness = 1.5
    ESPObjects[player] = { tracer = t }
end

local function applyESP(player)
    clearESP(player)
    if not Cfg.ESPEnabled then return end
    if Cfg.ESPMode == "Highlight" then makeHighlight(player)
    elseif Cfg.ESPMode == "Box"    then makeBox(player)
    elseif Cfg.ESPMode == "Tracer" then makeTracer(player) end
end

local function refreshAll()
    for _, p in pairs(Players:GetPlayers()) do applyESP(p) end
end

Players.PlayerAdded:Connect(function(p) if Cfg.ESPEnabled then applyESP(p) end end)
Players.PlayerRemoving:Connect(clearESP)

-- ================================================
-- Get closest target inside FOV
-- ================================================
local function getTarget()
    local best, bestDist = nil, Cfg.FOVRadius
    local cx = Camera.ViewportSize.X / 2
    local cy = Camera.ViewportSize.Y / 2
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local part = p.Character:FindFirstChild(Cfg.AimbotPart)
                          or p.Character:FindFirstChild("HumanoidRootPart")
                if part then
                    local sp, vis = Camera:WorldToViewportPoint(part.Position)
                    if vis then
                        local d = math.sqrt((sp.X-cx)^2 + (sp.Y-cy)^2)
                        if d < bestDist then bestDist = d; best = part end
                    end
                end
            end
        end
    end
    return best
end

-- ================================================
-- RenderStepped: FOV + ESP + Aimbot (always on when enabled)
-- ================================================
RunService.RenderStepped:Connect(function()
    -- FOV
    FOVDraw.Visible  = Cfg.FOVEnabled
    FOVDraw.Radius   = Cfg.FOVRadius
    FOVDraw.Color    = Cfg.FOVColor
    FOVDraw.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    -- Box / Tracer
    for player, obj in pairs(ESPObjects) do
        if player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if obj.box and root then
                local pos, vis = Camera:WorldToViewportPoint(root.Position)
                if vis then
                    local sz = 2000 / pos.Z
                    local x, y = pos.X, pos.Y
                    local w, h = sz*0.4, sz*1.2
                    local corners = {
                        {Vector2.new(x-w,y-h), Vector2.new(x+w,y-h)},
                        {Vector2.new(x-w,y+h), Vector2.new(x+w,y+h)},
                        {Vector2.new(x-w,y-h), Vector2.new(x-w,y+h)},
                        {Vector2.new(x+w,y-h), Vector2.new(x+w,y+h)},
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
            if obj.tracer and root then
                local pos, vis = Camera:WorldToViewportPoint(root.Position)
                if vis then
                    obj.tracer.From    = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    obj.tracer.To      = Vector2.new(pos.X, pos.Y)
                    obj.tracer.Color   = Cfg.ESPFillColor
                    obj.tracer.Visible = true
                else
                    obj.tracer.Visible = false
                end
            end
        end
    end

    -- Aimbot (на телефоне работает постоянно пока включен)
    if Cfg.AimbotEnabled then
        local t = getTarget()
        if t then
            Camera.CFrame = Camera.CFrame:Lerp(
                CFrame.lookAt(Camera.CFrame.Position, t.Position),
                Cfg.AimbotSmooth
            )
        end
    end
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
        if h then h.WalkSpeed = Cfg.SpeedEnabled and Cfg.SpeedValue or 16 end
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
local Lighting = game:GetService("Lighting")
local function setFullBright(on)
    if on then
        Lighting.Brightness    = 10
        Lighting.ClockTime     = 14
        Lighting.FogEnd        = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient       = Color3.fromRGB(255,255,255)
    else
        Lighting.Brightness    = 1
        Lighting.ClockTime     = 14
        Lighting.GlobalShadows = true
        Lighting.Ambient       = Color3.fromRGB(127,127,127)
    end
end

-- Anti-AFK
local function startAntiAFK()
    LP.Idled:Connect(function()
        local v = game:GetService("VirtualUser")
        v:Button1Down(Vector2.new(0,0), Camera.CFrame)
        task.wait(0.1)
        v:Button1Up(Vector2.new(0,0), Camera.CFrame)
    end)
end

-- ================================================
-- RAYFIELD GUI
-- ================================================
local Window = Rayfield:CreateWindow({
    Name            = "Primejtsu X | Flick Script",
    LoadingTitle    = "Primejtsu X",
    LoadingSubtitle = "Mobile Edition",
    Theme           = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings   = false,
})

-- TAB: ESP
local TabESP = Window:CreateTab("ESP", 4483362458)

TabESP:CreateToggle({
    Name = "Enable ESP", CurrentValue = false, Flag = "ESPToggle",
    Callback = function(v) Cfg.ESPEnabled = v; refreshAll() end,
})
TabESP:CreateDropdown({
    Name = "ESP Mode", Options = {"Highlight","Box","Tracer"},
    CurrentOption = {"Highlight"}, Flag = "ESPMode",
    Callback = function(o) Cfg.ESPMode = o[1]; refreshAll() end,
})
TabESP:CreateDropdown({
    Name = "ESP Color",
    Options = {"Red","Green","Blue","Yellow","Purple","Cyan","White","Orange"},
    CurrentOption = {"Red"}, Flag = "ESPColor",
    Callback = function(o)
        local c = {
            Red=Color3.fromRGB(255,0,0), Green=Color3.fromRGB(0,255,0),
            Blue=Color3.fromRGB(0,100,255), Yellow=Color3.fromRGB(255,255,0),
            Purple=Color3.fromRGB(180,0,255), Cyan=Color3.fromRGB(0,255,255),
            White=Color3.fromRGB(255,255,255), Orange=Color3.fromRGB(255,140,0),
        }
        if c[o[1]] then
            Cfg.ESPFillColor = c[o[1]]
            Cfg.ESPOutlineColor = c[o[1]]
            refreshAll()
        end
    end,
})
TabESP:CreateSlider({
    Name = "Transparency", Range = {0,10}, Increment = 1,
    CurrentValue = 5, Flag = "ESPTransp",
    Callback = function(v) Cfg.ESPFillTransp = v/10; refreshAll() end,
})

-- TAB: Aimbot
local TabAim = Window:CreateTab("Aimbot", 4483362458)

TabAim:CreateToggle({
    Name = "Aimbot (Auto - Mobile)", CurrentValue = false, Flag = "AimbotToggle",
    Callback = function(v) Cfg.AimbotEnabled = v end,
})
TabAim:CreateToggle({
    Name = "FOV Circle", CurrentValue = false, Flag = "FOVToggle",
    Callback = function(v) Cfg.FOVEnabled = v end,
})
TabAim:CreateSlider({
    Name = "FOV Radius", Range = {30,500}, Increment = 5,
    CurrentValue = 150, Flag = "FOVRadius",
    Callback = function(v) Cfg.FOVRadius = v end,
})
TabAim:CreateSlider({
    Name = "Aim Smoothness (lower = faster)", Range = {1,100}, Increment = 1,
    CurrentValue = 20, Flag = "AimSmooth",
    Callback = function(v) Cfg.AimbotSmooth = v/100 end,
})
TabAim:CreateDropdown({
    Name = "Aim Part", Options = {"Head","HumanoidRootPart","UpperTorso","Torso"},
    CurrentOption = {"Head"}, Flag = "AimPart",
    Callback = function(o) Cfg.AimbotPart = o[1] end,
})
TabAim:CreateDropdown({
    Name = "FOV Color", Options = {"Yellow","Red","Green","Blue","White","Cyan"},
    CurrentOption = {"Yellow"}, Flag = "FOVColor",
    Callback = function(o)
        local c = {
            Yellow=Color3.fromRGB(255,255,0), Red=Color3.fromRGB(255,0,0),
            Green=Color3.fromRGB(0,255,0), Blue=Color3.fromRGB(0,100,255),
            White=Color3.fromRGB(255,255,255), Cyan=Color3.fromRGB(0,255,255),
        }
        if c[o[1]] then Cfg.FOVColor = c[o[1]] end
    end,
})

-- TAB: Movement
local TabMove = Window:CreateTab("Movement", 4483362458)

TabMove:CreateToggle({
    Name = "Infinite Jump", CurrentValue = false, Flag = "InfJump",
    Callback = function(v) Cfg.InfJump = v end,
})
TabMove:CreateToggle({
    Name = "Speed Hack", CurrentValue = false, Flag = "SpeedHack",
    Callback = function(v) Cfg.SpeedEnabled = v end,
})
TabMove:CreateSlider({
    Name = "Walk Speed", Range = {16,200}, Increment = 1,
    CurrentValue = 40, Flag = "WalkSpeed",
    Callback = function(v) Cfg.SpeedValue = v end,
})
TabMove:CreateToggle({
    Name = "Noclip", CurrentValue = false, Flag = "Noclip",
    Callback = function(v) Cfg.NoclipOn = v end,
})
TabMove:CreateToggle({
    Name = "No Fall Damage", CurrentValue = false, Flag = "NoFall",
    Callback = function(v) Cfg.NoFallOn = v end,
})

-- TAB: Misc
local TabMisc = Window:CreateTab("Misc", 4483362458)

TabMisc:CreateToggle({
    Name = "Fullbright", CurrentValue = false, Flag = "Fullbright",
    Callback = function(v) setFullBright(v) end,
})
TabMisc:CreateToggle({
    Name = "Anti-AFK", CurrentValue = false, Flag = "AntiAFK",
    Callback = function(v) if v then startAntiAFK() end end,
})
TabMisc:CreateButton({
    Name = "Teleport to Spawn",
    Callback = function()
        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            LP.Character.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
        end
    end,
})
TabMisc:CreateButton({
    Name = "Respawn",
    Callback = function()
        if LP.Character then
            local h = LP.Character:FindFirstChild("Humanoid")
            if h then h.Health = 0 end
        end
    end,
})
TabMisc:CreateButton({
    Name = "Rejoin",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
    end,
})

Rayfield:Notify({
    Title   = "Primejtsu X | Flick Script",
    Content = "Mobile Edition loaded!",
    Duration = 5,
    Image   = 4483362458,
})

print("[Primejtsu X] Mobile Edition Loaded.")
