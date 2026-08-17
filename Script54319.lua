--// ==========================================================
--//  💥 SNIPERS VS RUNNERS • FULL CHEAT • FINAL
--//  author: @aLiNa_grnt • engine: gucci4080
--//  Delta phone • Rayfield (по докам) + fallback GUI
--// ==========================================================

local Players   = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Run       = game:GetService("RunService")
local UIS       = game:GetService("UserInputService")
local Light     = game:GetService("Lighting")
local VU        = game:GetService("VirtualUser")
local LP        = Players.LocalPlayer
local CAM       = Workspace.CurrentCamera

local AUTHOR = "@aLiNa_grnt"

--// ==========================================================
--//  БАЗА
--// ==========================================================
local function toast(t)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "gucci4080",
            Text = t,
            Duration = 4,
        })
    end
end

local function safe(fn, ...)
    local ok, r = pcall(fn, ...)
    if ok then return r end
    return nil
end

local function fetch(url)
    local out = nil
    pcall(function() out = game:HttpGet(url) end)
    if out and #out > 100 then return out end
    local req = nil
    if type(request) == "function" then req = request end
    if not req and type(http_request) == "function" then
        req = http_request
    end
    if not req and type(http) == "table"
        and type(http.request) == "function" then
        req = http.request
    end
    if req then
        pcall(function()
            out = req({ Url = url, Method = "GET" }).Body
        end)
    end
    if out and #out > 100 then return out end
    return nil
end

local Compat = {}
Compat.has_hook    = type(hookmetamethod) == "function"
Compat.has_caller  = type(checkcaller) == "function"
Compat.has_nc      = type(newcclosure) == "function"
Compat.has_drawing = type(Drawing) ~= "nil"

local S = {
    Aimbot = false, Silent = false, Wallcheck = true,
    TeamCheck = true, FovCircle = true, Fov = 120,
    Snap = 60, Prediction = 0, TargetPart = "Head",
    AutoShot = false, SmartShot = true, FireRate = 15,
    Esp = false, Chams = false, ShowHealth = true,
    EspEnemies = true, Speed = 16, Jump = 50,
    InfJump = false, Fullbright = false,
}

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
toast("⏳ 1/3 качаю rayfield...")

local Rayfield = nil
local raySrc = fetch("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua")
    or fetch("https://sirius.menu/rayfield")
if raySrc then
    local fn = loadstring(raySrc)
    if fn then Rayfield = safe(fn) end
end

if Rayfield then
    toast("⏳ 2/3 rayfield жив, строю окно...")
else
    toast("⏳ 2/3 rayfield нет — ставлю своё гуи")
end

--// ==========================================================
--//  UI-СЛОЙ
--// ==========================================================
local UI = {}
local uiMode = "mobile"

if Rayfield then
    local okWin, Window = pcall(function()
        return Rayfield:MakeWindow({
            Name = "💥 Snipers vs Runners | " .. AUTHOR,
            LoadingTitle = "Snipers vs Runners",
            LoadingSubtitle = "author: " .. AUTHOR,
            ConfigurationSaving = { Enabled = false },
            KeySystem = false,
        })
    end)
    if okWin and Window then
        uiMode = "rayfield"
        local tabs = {}
        function UI.tab(name)
            pcall(function()
                tabs[name] = Window:MakeTab({
                    Name = name,
                    Icon = "rbxassetid://4483345998",
                    PremiumOnly = false,
                })
            end)
        end
        function UI.toggle(tab, title, key, extra)
            pcall(function()
                tabs[tab]:MakeToggle({
                    Name = title,
                    CurrentValue = S[key],
                    Flag = key,
                    Callback = function(v)
                        S[key] = v
                        if extra then extra(v) end
                    end,
                })
            end)
        end
        function UI.slider(tab, title, key, min, max, step)
            pcall(function()
                tabs[tab]:MakeSlider({
                    Name = title,
                    Range = { min, max },
                    Increment = step,
                    Suffix = "",
                    CurrentValue = S[key],
                    Flag = key,
                    Callback = function(v) S[key] = v end,
                })
            end)
        end
        function UI.button(tab, title, fn)
            pcall(function()
                tabs[tab]:MakeButton({ Name = title, Callback = fn })
            end)
        end
        function UI.label(tab, text)
            local ok = pcall(function()
                local l = tabs[tab]:MakeLabel({ Name = text })
                if not l then error("nil") end
            end)
            if not ok then
                pcall(function() tabs[tab]:MakeLabel(text) end)
            end
        end
        function UI.drop(tab, title, key, options)
            pcall(function()
                tabs[tab]:MakeDropdown({
                    Name = title,
                    Options = options,
                    CurrentOption = S[key],
                    MultipleOptions = false,
                    Flag = key,
                    Callback = function(opt) S[key] = opt end,
                })
            end)
        end
        function UI.hide()
            pcall(function() Rayfield:Toggle() end)
        end
        function UI.notify(t)
            pcall(function()
                Rayfield:Notify({
                    Title = AUTHOR,
                    Subtitle = "snipers vs runners",
                    Content = t,
                    Duration = 4,
                })
            end)
        end
    end
end

if uiMode == "mobile" then
    local gui = Instance.new("ScreenGui")
    gui.Name = "gucci4080svr"
    gui.ResetOnSpawn = false
    gui.Parent = safe(function() return gethui() end)
        or LP:WaitForChild("PlayerGui")

    local main = Instance.new("Frame")
    main.Size = UDim2.fromOffset(200, 420)
    main.Position = UDim2.fromOffset(8, 90)
    main.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    main.BorderSizePixel = 0
    main.Active = true
    main.Parent = gui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

    local head = Instance.new("TextButton")
    head.Size = UDim2.new(1, 0, 0, 34)
    head.BackgroundColor3 = Color3.fromRGB(34, 34, 40)
    head.BorderSizePixel = 0
    head.Text = "💥 svr | " .. AUTHOR
    head.TextColor3 = Color3.fromRGB(255, 255, 255)
    head.TextSize = 12
    head.Parent = main
    Instance.new("UICorner", head).CornerRadius = UDim.new(0, 12)

    local scroll = Instance.new("ScrollingFrame")
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.Position = UDim2.fromOffset(6, 40)
    scroll.Size = UDim2.new(1, -12, 1, -46)
    scroll.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
    scroll.ScrollBarThickness = 3
    scroll.Parent = main
    local lay = Instance.new("UIListLayout")
    lay.Padding = UDim.new(0, 4)
    lay.Parent = scroll

    local dragPos = nil
    head.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch
            or i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragPos = i.Position
        end
    end)
    head.InputEnded:Connect(function() dragPos = nil end)
    UIS.InputChanged:Connect(function(i)
        if dragPos and (i.UserInputType == Enum.UserInputType.Touch
            or i.UserInputType == Enum.UserInputType.MouseMovement) then
            local d = i.Position - dragPos
            dragPos = i.Position
            main.Position = main.Position + UDim2.fromOffset(d.X, d.Y)
        end
    end)

    function UI.tab(name)
        local l = Instance.new("TextLabel")
        l.BackgroundTransparency = 1
        l.Size = UDim2.new(1, 0, 0, 22)
        l.Text = "— " .. name .. " —"
        l.TextColor3 = Color3.fromRGB(255, 200, 80)
        l.TextSize = 13
        l.Parent = scroll
    end
    function UI.toggle(tab, title, key, extra)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 30)
        b.BorderSizePixel = 0
        b.TextSize = 12
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.Parent = scroll
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        local function paint()
            b.BackgroundColor3 = S[key]
                and Color3.fromRGB(38, 110, 60)
                or Color3.fromRGB(52, 52, 58)
            b.Text = (S[key] and "✓ " or "✗ ") .. title
        end
        b.Activated:Connect(function()
            S[key] = not S[key]
            if extra then extra(S[key]) end
            paint()
        end)
        paint()
    end
    function UI.slider(tab, title, key, min, max, step)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, 0, 0, 30)
        f.BackgroundTransparency = 1
        f.Parent = scroll
        local t = Instance.new("TextLabel")
        t.BackgroundTransparency = 1
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Size = UDim2.new(0.45, 0, 1, 0)
        t.Text = title
        t.TextSize = 12
        t.TextColor3 = Color3.fromRGB(255, 255, 255)
        t.Parent = f
        local v = Instance.new("TextLabel")
        v.BackgroundTransparency = 1
        v.Size = UDim2.new(0.2, 0, 1, 0)
        v.Position = UDim2.new(0.45, 0, 0, 0)
        v.TextSize = 12
        v.TextColor3 = Color3.fromRGB(120, 255, 140)
        v.Parent = f
        local pm = Instance.new("TextButton")
        pm.Size = UDim2.new(0.15, 0, 1, 0)
        pm.Position = UDim2.new(0.66, 0, 0, 0)
        pm.Text = "−"
        pm.TextSize = 16
        pm.BackgroundColor3 = Color3.fromRGB(52, 52, 58)
        pm.TextColor3 = Color3.fromRGB(255, 255, 255)
        pm.Parent = f
        Instance.new("UICorner", pm).CornerRadius = UDim.new(0, 6)
        local pp = Instance.new("TextButton")
        pp.Size = UDim2.new(0.15, 0, 1, 0)
        pp.Position = UDim2.new(0.83, 0, 0, 0)
        pp.Text = "+"
        pp.TextSize = 16
        pp.BackgroundColor3 = Color3.fromRGB(52, 52, 58)
        pp.TextColor3 = Color3.fromRGB(255, 255, 255)
        pp.Parent = f
        Instance.new("UICorner", pp).CornerRadius = UDim.new(0, 6)
        local function paint() v.Text = tostring(S[key]) end
        pm.Activated:Connect(function()
            S[key] = math.max(min, S[key] - step)
            paint()
        end)
        pp.Activated:Connect(function()
            S[key] = math.min(max, S[key] + step)
            paint()
        end)
        paint()
    end
    function UI.button(tab, title, fn)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 30)
        b.BorderSizePixel = 0
        b.TextSize = 12
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.BackgroundColor3 = Color3.fromRGB(90, 70, 20)
        b.Text = title
        b.Parent = scroll
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        b.Activated:Connect(fn)
    end
    function UI.label(tab, text)
        local l = Instance.new("TextLabel")
        l.BackgroundTransparency = 1
        l.Size = UDim2.new(1, 0, 0, 20)
        l.Text = text
        l.TextColor3 = Color3.fromRGB(180, 180, 180)
        l.TextSize = 11
        l.Parent = scroll
    end
    function UI.drop(tab, title, key, options)
        local i = 1
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 30)
        b.BorderSizePixel = 0
        b.TextSize = 12
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.BackgroundColor3 = Color3.fromRGB(52, 52, 58)
        b.Parent = scroll
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        local function paint() b.Text = title .. ": " .. S[key] end
        b.Activated:Connect(function()
            i = i % #options + 1
            S[key] = options[i]
            paint()
        end)
        paint()
    end
    function UI.hide()
        main.Visible = not main.Visible
    end
    function UI.notify(t)
        toast(t)
    end
end

toast("⏳ 3/3 цели, есп, авто-огонь...")

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
    local dir = pos - origin
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
                    local d = (Vector2.new(scr.X, scr.Y) - center).Magnitude
                    if d <= S.Fov and d < bestD and wallcheck(pos) then
                        bestD, best = d, pl
                    end
                end
            end
        end
    end
    return best
end

--// ==========================================================
--//  FOV + АИМ
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
    safe(function()
        if fovCircle then
            fovCircle.Visible = S.FovCircle and (S.Aimbot or S.Silent)
            fovCircle.Radius = S.Fov
            fovCircle.Position = Vector2.new(
                CAM.ViewportSize.X / 2,
                CAM.ViewportSize.Y / 2
            )
        end
        currentTarget = (S.Aimbot or S.Silent) and pickTarget() or nil
        if S.Aimbot and currentTarget then
            local pos = targetPos(currentTarget)
            if pos then
                local goal = CFrame.new(CAM.CFrame.Position, pos)
                CAM.CFrame = CAM.CFrame:Lerp(goal, S.Snap / 100)
            end
        end
    end)
end)

--// ==========================================================
--//  SILENT AIM
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
                            local origin, dir = args[1], args[2]
                            if origin and dir then
                                local nd = (pos - origin).Unit * dir.Magnitude
                                return old(self, origin, nd, args[3])
                            end
                        else
                            local ray = args[1]
                            if ray then
                                local nd = (pos - ray.Origin).Unit * 1000
                                return old(self, Ray.new(ray.Origin, nd), args[2])
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
    while true do
        task.wait(math.max(0.05, S.FireRate / 100))
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
                        d.box.Position = Vector2.new(topScr.X - w / 2, topScr.Y)
                        d.box.Visible = true
                    end
                    if d.name then
                        d.name.Text = pl.Name
                        d.name.Position = Vector2.new(topScr.X, topScr.Y - 16)
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
                            line = line .. " | " .. math.floor(hum.Health) .. "hp"
                        end
                        d.info.Text = line
                        d.info.Position = Vector2.new(topScr.X, botScr.Y + 2)
                        d.info.Visible = true
                    end
                elseif d then
                    if d.box then d.box.Visible = false end
                    if d.name then d.name.Visible = false end
                    if d.info then d.info.Visible = false end
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
        safe(function()
            if S.Chams then
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl ~= LP and pl.Character
                        and (not S.EspEnemies or isEnemy(pl)) then
                        if not pl.Character:FindFirstChildOfClass("Highlight") then
                            pcall(function()
                                local h = Instance.new("Highlight")
                                h:SetAttribute("gz", true)
                                h.FillColor = Color3.fromRGB(255, 60, 60)
                                h.FillTransparency = 0.5
                                h.OutlineColor = Color3.fromRGB(255, 255, 255)
                                h.Parent = pl.Character
                            end)
                        end
                    end
                end
            else
                for _, o in ipairs(Workspace:GetDescendants()) do
                    if o:IsA("Highlight") and o:GetAttribute("gz") then
                        o:Destroy()
                    end
                end
            end
        end)
    end
end)

--// ==========================================================
--//  МУВМЕНТ
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
--//  КОНТРОЛЫ
--// ==========================================================
UI.tab("Aimbot")
UI.toggle("Aimbot", "Аимлок (камера)", "Aimbot")
UI.toggle("Aimbot", "Silent aim", "Silent")
UI.toggle("Aimbot", "Wallcheck", "Wallcheck")
UI.toggle("Aimbot", "Только враги", "TeamCheck")
UI.toggle("Aimbot", "FOV круг", "FovCircle")
UI.slider("Aimbot", "FOV", "Fov", 10, 500, 10)
UI.slider("Aimbot", "Резкость", "Snap", 1, 100, 5)
UI.slider("Aimbot", "Предикт", "Prediction", 0, 100, 5)
UI.drop("Aimbot", "Часть тела", "TargetPart", { "Head", "HumanoidRootPart" })

UI.tab("AutoShot")
UI.toggle("AutoShot", "Авто-огонь", "AutoShot")
UI.toggle("AutoShot", "Умный огонь", "SmartShot")
UI.slider("AutoShot", "Темп огня", "FireRate", 5, 100, 5)

UI.tab("ESP")
UI.toggle("ESP", "ESP игроков", "Esp")
UI.toggle("ESP", "Chams", "Chams")
UI.toggle("ESP", "Показывать HP", "ShowHealth")
UI.toggle("ESP", "Только враги", "EspEnemies")

UI.tab("Misc")
UI.slider("Misc", "Speed", "Speed", 16, 120, 4)
UI.slider("Misc", "Jump", "Jump", 50, 200, 10)
UI.toggle("Misc", "Инф-прыжок", "InfJump")
UI.toggle("Misc", "Fullbright", "Fullbright", function(v) fullbright(v) end)
UI.button("Misc", "🙈 скрыть гуи", function() UI.hide() end)

UI.tab("Credits")
UI.label("Credits", "author: " .. AUTHOR)
UI.label("Credits", "engine: gucci4080 • v4080")
UI.label("Credits", "gui: " .. uiMode)

--// ==========================================================
--//  ADDON
--// ==========================================================
local watermark = nil
if Compat.has_drawing then
    watermark = safe(function()
        local t = Drawing.new("Text")
        t.Size = 14
        t.Outline = true
        t.Color = Color3.fromRGB(255, 80, 120)
        t.Visible = true
        return t
    end)
end

task.spawn(function()
    while task.wait(0.5) do
        safe(function()
            if watermark then
                watermark.Text = "💥 svr • " .. AUTHOR
                watermark.Position = Vector2.new(10, 10)
                watermark.Visible = true
            end
        end)
    end
end)

local rejoining = false
pcall(function()
    LP.Kicked:Connect(function()
        if rejoining then return end
        rejoining = true
        pcall(function()
            game:GetService("TeleportService"):Teleport(game.PlaceId)
        end)
    end)
end)

if type(setfpscap) == "function" then
    pcall(function() setfpscap(999) end)
end

UIS.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.K then
        UI.hide()
    end
end)

--// ==========================================================
--//  САМОТЕСТ
--// ==========================================================
toast("✅ 3/3 готово • gui: " .. uiMode .. " • " .. AUTHOR)
UI.notify("💥 чит в стене. author: " .. AUTHOR)
print("💥 svr final • " .. AUTHOR .. " • gucci4080 • gui=" .. uiMode)
