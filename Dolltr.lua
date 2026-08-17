--// ==========================================================
--//  💥 SNIPERS VS RUNNERS • FULL CHEAT
--//  author: @aLiNa_grnt • engine: gucci4080
--//  Delta / любой экзекутор • Rayfield UI
--// ==========================================================

local Players   = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Run       = game:GetService("RunService")
local UIS       = game:GetService("UserInputService")
local Light     = game:GetService("Lighting")
local VU        = game:GetService("VirtualUser")
local LP        = Players.LocalPlayer
local CAM       = Workspace.CurrentCamera
local MOUSE     = LP:GetMouse()

local AUTHOR = "@aLiNa_grnt"

--// ==========================================================
--//  COMPAT
--// ==========================================================
local Compat = {}
Compat.has_hook   = type(hookmetamethod) == "function"
Compat.has_caller = type(checkcaller) == "function"
Compat.has_nc     = type(newcclosure) == "function"
Compat.has_drawing = type(Drawing) ~= "nil"

local function safe(fn, ...)
    local ok, r = pcall(fn, ...)
    if ok then return r end
    return nil
end

--// ==========================================================
--//  НАСТРОЙКИ
--// ==========================================================
local S = {
    Aimbot     = false,
    Silent     = false,
    Wallcheck  = true,
    TeamCheck  = true,
    FovCircle  = true,
    Fov        = 120,
    Snap       = 60,
    Prediction = 0,
    TargetPart = "Head",
    AutoShot   = false,
    SmartShot  = true,
    FireRate   = 15,
    Esp        = false,
    Chams      = false,
    ShowHealth = true,
    EspEnemies = true,
    Speed      = 16,
    Jump       = 50,
    InfJump    = false,
    Fullbright = false,
}

--// ==========================================================
--//  ПЕРСОНАЖ
--// ==========================================================
local CH, HR, HU

local function bind(c)
    CH = c
    HR = safe(function() return c:WaitForChild("HumanoidRootPart", 10) end)
    HU = safe(function() return c:WaitForChild("Humanoid", 10) end)
end

if LP.Character then bind(LP.Character) end
LP.CharacterAdded:Connect(bind)

--// ==========================================================
--//  RAYFIELD
--// ==========================================================
local Rayfield = nil
local okLoad, r = pcall(function()
    return loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua"))()
end)
if okLoad and r then
    Rayfield = r
else
    local ok2, r2 = pcall(function()
        return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
    end)
    if ok2 and r2 then Rayfield = r2 end
end

if not Rayfield then
    warn("rayfield не встал — интернет мёртв")
    return
end

local Window = Rayfield:MakeWindow({
    Name = "💥 Snipers vs Runners | " .. AUTHOR,
    LoadingTitle = "Snipers vs Runners",
    LoadingSubtitle = "author: " .. AUTHOR,
    ConfigurationSaving = {
        Enabled = false,
    },
    KeySystem = false,
})

local function notify(t)
    pcall(function()
        Rayfield:Notify({
            Title = AUTHOR,
            Subtitle = "snipers vs runners",
            Content = t,
            Duration = 4,
        })
    end)
end

--// ==========================================================
--//  ЦЕЛИ
--// ==========================================================
local function isEnemy(pl)
    if pl == LP then return false end
    if not pl.Character then return false end
    local hum = pl.Character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if S.TeamCheck and LP.Team and pl.Team
        and pl.Team == LP.Team then
        return false
    end
    return true
end

local function targetPos(pl)
    local char = pl.Character
    if not char then return nil end
    local part = char:FindFirstChild(S.TargetPart)
        or char:FindFirstChild("Head")
    if not part then return nil end
    local pos = part.Position
    if S.Prediction > 0 then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            pos = pos + root.Velocity * (S.Prediction / 100)
        end
    end
    return pos
end

local function wallcheck(pos)
    if not S.Wallcheck then return true end
    if not HR then return true end
    local origin = CAM.CFrame.Position
    local dir = (pos - origin)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LP.Character, CAM }
    local hit = Workspace:Raycast(origin, dir, params)
    if not hit then return true end
    local m = hit.Instance
    while m do
        if m:IsA("Model") and Players:GetPlayerFromCharacter(m) then
            return true
        end
        m = m.Parent
    end
    return false
end

local currentTarget = nil

local function pickTarget()
    local best, bestD = nil, math.huge
    local center = Vector2.new(
        CAM.ViewportSize.X / 2,
        CAM.ViewportSize.Y / 2
    )
    for _, pl in ipairs(Players:GetPlayers()) do
        if isEnemy(pl) then
            local pos = targetPos(pl)
            if pos then
                local scr, onScr = CAM:WorldToViewportPoint(pos)
                if onScr then
                    local p2 = Vector2.new(scr.X, scr.Y)
                    local d = (p2 - center).Magnitude
                    if d <= S.Fov and d < bestD then
                        if wallcheck(pos) then
                            bestD, best = d, pl
                        end
                    end
                end
            end
        end
    end
    return best
end

--// ==========================================================
--//  FOV КРУГ
--// ==========================================================
local fovCircle = nil
if Compat.has_drawing then
    fovCircle = safe(function()
        local c = Drawing.new("Circle")
        c.Thickness = 1
        c.NumSides = 60
        c.Filled = false
        c.Color = Color3.fromRGB(255, 255, 255)
        return c
    end)
end

Run.RenderStepped:Connect(function()
    if fovCircle then
        fovCircle.Visible = S.FovCircle and (S.Aimbot or S.Silent)
        fovCircle.Radius = S.Fov
        fovCircle.Position = Vector2.new(
            CAM.ViewportSize.X / 2,
            CAM.ViewportSize.Y / 2
        )
    end
    currentTarget = (S.Aimbot or S.Silent) and pickTarget() or nil
    --// аимлок камерой
    if S.Aimbot and currentTarget then
        local pos = targetPos(currentTarget)
        if pos then
            local goal = CFrame.new(CAM.CFrame.Position, pos)
            CAM.CFrame = CAM.CFrame:Lerp(goal, S.Snap / 100)
        end
    end
end)

--// ==========================================================
--//  SILENT AIM (хук рекаста)
--// ==========================================================
if Compat.has_hook and Compat.has_caller and Compat.has_nc then
    pcall(function()
        local old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if not checkcaller() and S.Silent
                and (method == "Raycast"
                    or tostring(method):find("FindPartOnRay")) then
                if currentTarget then
                    local pos = targetPos(currentTarget)
                    if pos then
                        local args = { ... }
                        if method == "Raycast" then
                            local origin = args[1]
                            local dir = args[2]
                            if origin and dir then
                                local nd = (pos - origin)
                                nd = nd.Unit * dir.Magnitude
                                return old(self, origin, nd, args[3])
                            end
                        else
                            local ray = args[1]
                            if ray then
                                local nd = (pos - ray.Origin)
                                nd = nd.Unit * 1000
                                return old(self,
                                    Ray.new(ray.Origin, nd),
                                    args[2])
                            end
                        end
                    end
                end
            end
            return old(self, ...)
        end))
    end)
end

--// ==========================================================
--//  АВТО-ШОТ
--// ==========================================================
task.spawn(function()
    while task.wait(S.FireRate / 100) do
        if not S.AutoShot then continue end
        if S.SmartShot and not currentTarget then continue end
        if CH then
            local tool = CH:FindFirstChildOfClass("Tool")
            if tool then
                pcall(function() tool:Activate() end)
            end
        end
    end
end)

--// ==========================================================
--//  ESP
--// ==========================================================
local drawings = {}

local function espFree(d)
    for _, obj in pairs(d) do
        pcall(function() obj:Remove() end)
    end
end

local function espGet(pl)
    if not drawings[pl] then
        drawings[pl] = {
            box = safe(function()
                local q = Drawing.new("Square")
                q.Thickness = 1
                q.Filled = false
                q.Color = Color3.fromRGB(255, 60, 60)
                return q
            end),
            name = safe(function()
                local t = Drawing.new("Text")
                t.Size = 13
                t.Center = true
                t.Outline = true
                t.Color = Color3.fromRGB(255, 255, 255)
                return t
            end),
            info = safe(function()
                local t = Drawing.new("Text")
                t.Size = 12
                t.Center = true
                t.Outline = true
                t.Color = Color3.fromRGB(120, 255, 140)
                return t
            end),
        }
    end
    return drawings[pl]
end

Players.PlayerRemoving:Connect(function(pl)
    if drawings[pl] then
        espFree(drawings[pl])
        drawings[pl] = nil
    end
end)

local function chamsTick()
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LP and pl.Character then
            local root = pl.Character
            if S.Chams and (not S.EspEnemies or isEnemy(pl)) then
                if not root:FindFirstChildOfClass("Highlight") then
                    pcall(function()
                        local h = Instance.new("Highlight")
                        h:SetAttribute("gz", true)
                        h.FillColor = Color3.fromRGB(255, 60, 60)
                        h.FillTransparency = 0.5
                        h.OutlineColor = Color3.fromRGB(255, 255, 255)
                        h.Parent = root
                    end)
                end
            end
        end
    end
    if not S.Chams then
        for _, o in ipairs(Workspace:GetDescendants()) do
            if o:IsA("Highlight") and o:GetAttribute("gz") then
                o:Destroy()
            end
        end
    end
end

local function espTick()
    if not Compat.has_drawing then return end
    for _, pl in ipairs(Players:GetPlayers()) do
        local d = drawings[pl]
        local show = S.Esp and pl ~= LP
            and (not S.EspEnemies or isEnemy(pl))
        if show and pl.Character then
            local char = pl.Character
            local head = char:FindFirstChild("Head")
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if head and root and hum then
                local topScr, topOn = CAM:WorldToViewportPoint(
                    head.Position + Vector3.new(0, 0.6, 0))
                local botScr, botOn = CAM:WorldToViewportPoint(
                    root.Position - Vector3.new(0, 3, 0))
                if topOn and botOn then
                    local h = math.abs(botScr.Y - topScr.Y)
                    local w = h / 2
                    d = espGet(pl)
                    if d.box then
                        d.box.Size = Vector2.new(w, h)
                        d.box.Position = Vector2.new(
                            topScr.X - w / 2, topScr.Y)
                        d.box.Visible = true
                    end
                    if d.name then
                        d.name.Text = pl.Name
                        d.name.Position = Vector2.new(
                            topScr.X, topScr.Y - 16)
                        d.name.Visible = true
                    end
                    if d.info then
                        local dist = 0
                        if HR then
                            dist = math.floor(
                                (root.Position - HR.Position).Magnitude)
                        end
                        local line = dist .. "m"
                        if S.ShowHealth then
                            line = line .. " | "
                                .. math.floor(hum.Health) .. "hp"
                        end
                        d.info.Text = line
                        d.info.Position = Vector2.new(
                            topScr.X, botScr.Y + 2)
                        d.info.Visible = true
                    end
                else
                    if d then
                        if d.box then d.box.Visible = false end
                        if d.name then d.name.Visible = false end
                        if d.info then d.info.Visible = false end
                    end
                end
            end
        elseif d then
            if d.box then d.box.Visible = false end
            if d.name then d.name.Visible = false end
            if d.info then d.info.Visible = false end
        end
    end
end

task.spawn(function()
    while task.wait(0.12) do
        safe(espTick)
    end
end)

task.spawn(function()
    while task.wait(1) do
        safe(chamsTick)
    end
end)

--// ==========================================================
--//  МУВМЕНТ / ВИЗУАЛ
--// ==========================================================
Run.Heartbeat:Connect(function()
    if HU then
        HU.WalkSpeed = S.Speed
        HU.JumpPower = S.Jump
    end
end)

UIS.JumpRequest:Connect(function()
    if S.InfJump and HU then
        HU:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

LP.Idled:Connect(function()
    VU:CaptureController()
    VU:ClickButton2(Vector2.new())
end)

local function fullbright(on)
    Light.Brightness = on and 2 or 1
    Light.ClockTime = on and 14 or 0
    Light.GlobalShadows = not on
    if on then
        Light.FogEnd = 1e7
        Light.Ambient = Color3.new(1, 1, 1)
        Light.OutdoorAmbient = Color3.new(1, 1, 1)
    end
end

--// ==========================================================
--//  ТАБЫ
--// ==========================================================
local TabAim = Window:MakeTab({
    Name = "Aimbot",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false,
})

TabAim:MakeToggle({
    Name = "Аимлок (камера)",
    CurrentValue = S.Aimbot,
    Flag = "Aimbot",
    Callback = function(v) S.Aimbot = v end,
})

TabAim:MakeToggle({
    Name = "Silent aim (хук рекаста)",
    CurrentValue = S.Silent,
    Flag = "Silent",
    Callback = function(v) S.Silent = v end,
})

TabAim:MakeToggle({
    Name = "Wallcheck (сквозь стены нет)",
    CurrentValue = S.Wallcheck,
    Flag = "Wallcheck",
    Callback = function(v) S.Wallcheck = v end,
})

TabAim:MakeToggle({
    Name = "Только враги (команды)",
    CurrentValue = S.TeamCheck,
    Flag = "TeamCheck",
    Callback = function(v) S.TeamCheck = v end,
})

TabAim:MakeToggle({
    Name = "FOV круг",
    CurrentValue = S.FovCircle,
    Flag = "FovCircle",
    Callback = function(v) S.FovCircle = v end,
})

TabAim:MakeSlider({
    Name = "FOV",
    Range = { 10, 500 },
    Increment = 10,
    Suffix = " px",
    CurrentValue = S.Fov,
    Flag = "Fov",
    Callback = function(v) S.Fov = v end,
})

TabAim:MakeSlider({
    Name = "Резкость (snap)",
    Range = { 1, 100 },
    Increment = 5,
    Suffix = " %",
    CurrentValue = S.Snap,
    Flag = "Snap",
    Callback = function(v) S.Snap = v end,
})

TabAim:MakeSlider({
    Name = "Предикт (упреждение)",
    Range = { 0, 100 },
    Increment = 5,
    Suffix = " ms",
    CurrentValue = S.Prediction,
    Flag = "Prediction",
    Callback = function(v) S.Prediction = v end,
})

TabAim:MakeDropdown({
    Name = "Часть тела",
    Options = { "Head", "HumanoidRootPart" },
    CurrentOption = "Head",
    MultipleOptions = false,
    Flag = "TargetPart",
    Callback = function(opt) S.TargetPart = opt end,
})

local TabShot = Window:MakeTab({
    Name = "AutoShot",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false,
})

TabShot:MakeToggle({
    Name = "Авто-огонь",
    CurrentValue = S.AutoShot,
    Flag = "AutoShot",
    Callback = function(v) S.AutoShot = v end,
})

TabShot:MakeToggle({
    Name = "Умный огонь (только по цели)",
    CurrentValue = S.SmartShot,
    Flag = "SmartShot",
    Callback = function(v) S.SmartShot = v end,
})

TabShot:MakeSlider({
    Name = "Темп огня",
    Range = { 5, 100 },
    Increment = 5,
    Suffix = " ms",
    CurrentValue = S.FireRate,
    Flag = "FireRate",
    Callback = function(v) S.FireRate = v end,
})

local TabEsp = Window:MakeTab({
    Name = "ESP",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false,
})

TabEsp:MakeToggle({
    Name = "ESP игроков (боксы)",
    CurrentValue = S.Esp,
    Flag = "Esp",
    Callback = function(v) S.Esp = v end,
})

TabEsp:MakeToggle({
    Name = "Chams (подсветка)",
    CurrentValue = S.Chams,
    Flag = "Chams",
    Callback = function(v) S.Chams = v end,
})

TabEsp:MakeToggle({
    Name = "Показывать HP",
    CurrentValue = S.ShowHealth,
    Flag = "ShowHealth",
    Callback = function(v) S.ShowHealth = v end,
})

TabEsp:MakeToggle({
    Name = "Только враги",
    CurrentValue = S.EspEnemies,
    Flag = "EspEnemies",
    Callback = function(v) S.EspEnemies = v end,
})

local TabMisc = Window:MakeTab({
    Name = "Misc",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false,
})

TabMisc:MakeSlider({
    Name = "Speed",
    Range = { 16, 120 },
    Increment = 4,
    Suffix = " spd",
    CurrentValue = S.Speed,
    Flag = "Speed",
    Callback = function(v) S.Speed = v end,
})

TabMisc:MakeSlider({
    Name = "Jump",
    Range = { 50, 200 },
    Increment = 10,
    Suffix = " pwr",
    CurrentValue = S.Jump,
    Flag = "Jump",
    Callback = function(v) S.Jump = v end,
})

TabMisc:MakeToggle({
    Name = "Инф-прыжок",
    CurrentValue = S.InfJump,
    Flag = "InfJump",
    Callback = function(v) S.InfJump = v end,
})

TabMisc:MakeToggle({
    Name = "Fullbright",
    CurrentValue = S.Fullbright,
    Flag = "Fullbright",
    Callback = function(v)
        S.Fullbright = v
        fullbright(v)
    end,
})

TabMisc:MakeButton({
    Name = "🙈 скрыть гуи",
    Callback = function()
        Rayfield:Toggle()
    end,
})

local TabCr = Window:MakeTab({
    Name = "Credits",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false,
})

TabCr:MakeLabel({
    Name = "author: " .. AUTHOR,
})

TabCr:MakeLabel({
    Name = "engine: gucci4080 • v4080",
})

TabCr:MakeLabel({
    Name = "snipers vs runners • full build",
})

notify("💥 чит в стене. author: " .. AUTHOR)
