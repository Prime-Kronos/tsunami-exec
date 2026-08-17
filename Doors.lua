--// ==========================================================
--//  gucci4080 • DOORS • Delta • FULL BUILD • ЧАСТЬ 1/2
--//  склей с частью 2 в один файл → Execute
--// ==========================================================

--// анти-повтор
if getgenv and getgenv().gucci_doors then
    return
end
if getgenv then
    getgenv().gucci_doors = true
end

--// ==========================================================
--//  СЕРВИСЫ
--// ==========================================================
local Players   = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Run       = game:GetService("RunService")
local UIS       = game:GetService("UserInputService")
local Light     = game:GetService("Lighting")
local VU        = game:GetService("VirtualUser")
local TS        = game:GetService("TeleportService")
local Http      = game:GetService("HttpService")
local LP        = Players.LocalPlayer
local CAM       = Workspace.CurrentCamera

--// ==========================================================
--//  COMPAT-СЛОЙ (дельта/другие экзекуторы)
--// ==========================================================
local Compat = {}

Compat.has_prompt  = type(fireproximityprompt)  == "function"
Compat.has_click   = type(fireclickdetector)   == "function"
Compat.has_touch   = type(firetouchinterest)   == "function"
Compat.has_write   = type(writefile)           == "function"
Compat.has_read    = type(readfile)            == "function"
Compat.has_isfile  = type(isfile)              == "function"
Compat.has_folder  = type(makefolder)          == "function"
Compat.has_gethui  = type(gethui)              == "function"
Compat.has_drawing = type(Drawing)             ~= "nil"

function Compat.write(path, data)
    if not Compat.has_write then return end
    pcall(function() writefile(path, data) end)
end

function Compat.read(path)
    if not Compat.has_read then return nil end
    if Compat.has_isfile and not isfile(path) then return nil end
    local ok, d = pcall(function() return readfile(path) end)
    if ok then return d end
    return nil
end

function Compat.folder(name)
    if not Compat.has_folder then return end
    pcall(function()
        if not isfolder(name) then makefolder(name) end
    end)
end

--// ==========================================================
--//  КОНФИГ (живёт в файле дельты)
--// ==========================================================
local CFG_DIR  = "gucci4080"
local CFG_PATH = "gucci4080/doors_full.json"
Compat.folder(CFG_DIR)

local S = {
    Speed      = 16,
    Jump       = 50,
    FlySpeed   = 60,
    EspItems   = false,
    EspEnt     = false,
    EspPlayers = false,
    EspPuzzle  = false,
    EspDoors   = false,
    Fullbright = false,
    Fps        = false,
    Alerts     = true,
    AutoHide   = true,
    AutoTurn   = true,
    AutoLook   = true,
    AutoBack   = true,
    AutoFreeze = true,
    AutoRun    = true,
    FlickGuard = true,
    AutoLoot   = false,
    AutoDoors  = false,
    AutoShop   = false,
    AutoPuzzle = false,
    InfJump    = false,
    Fly        = false,
    Noclip     = false,
}

local function saveCfg()
    local ok, json = pcall(function()
        return Http:JSONEncode(S)
    end)
    if ok then
        Compat.write(CFG_PATH, json)
    end
end

local function loadCfg()
    local raw = Compat.read(CFG_PATH)
    if not raw then return end
    local ok, t = pcall(function()
        return Http:JSONDecode(raw)
    end)
    if not ok or type(t) ~= "table" then return end
    for k, v in pairs(t) do
        if S[k] ~= nil then
            S[k] = v
        end
    end
end

loadCfg()

--// ==========================================================
--//  УТИЛИТЫ
--// ==========================================================
local function safe(fn, ...)
    local ok, r = pcall(fn, ...)
    if ok then return r end
    return nil
end

local function lower(s)
    return string.lower(tostring(s))
end

local function has(s, list)
    s = lower(s)
    for _, w in ipairs(list) do
        if s:find(w, 1, true) then
            return true
        end
    end
    return false
end

local function rgb(r, g, b)
    return Color3.fromRGB(r, g, b)
end

local function instPos(o)
    return safe(function()
        return o:GetPivot().Position
    end)
end

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

local function tp(p)
    if not HR then return end
    HR.CFrame = CFrame.new(p)
    HR.Velocity = Vector3.zero
end

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
    warn("gucci4080: rayfield не встал, интернет мёртв")
    return
end

local Window = Rayfield:MakeWindow({
    Name = "🐀 gucci4080 • doors full",
    LoadingTitle = "DOORS",
    LoadingSubtitle = "gucci4080 • full build",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = nil,
        FileName = nil,
    },
    KeySystem = false,
})

local notifyQueue = {}
local notifying = false

local function pushNotify(t)
    table.insert(notifyQueue, t)
    if notifying then return end
    notifying = true
    task.spawn(function()
        while #notifyQueue > 0 do
            local msg = table.remove(notifyQueue, 1)
            pcall(function()
                Rayfield:Notify({
                    Title = "gucci4080",
                    Subtitle = "doors",
                    Content = msg,
                    Duration = 4,
                })
            end)
            task.wait(0.4)
        end
        notifying = false
    end)
end

local function notify(t)
    pushNotify(t)
end

--// ==========================================================
--//  СКАНЕР
--// ==========================================================
local Scanner = {}

function Scanner.all(root)
    return safe(function()
        return root:GetDescendants()
    end) or {}
end

function Scanner.prompts()
    local out = {}
    for _, d in ipairs(Scanner.all(Workspace)) do
        if d:IsA("ProximityPrompt")
            or d:IsA("ClickDetector")
            or d:IsA("TouchTransmitter") then
            table.insert(out, d)
        end
    end
    return out
end

function Scanner.promptText(o)
    if o:IsA("ProximityPrompt") then
        return lower(o.Name
            .. " " .. o.ObjectText
            .. " " .. o.ActionText)
    end
    return lower(o.Name)
end

function Scanner.fire(o)
    if o:IsA("ProximityPrompt") and Compat.has_prompt then
        pcall(function() fireproximityprompt(o) end)
    elseif o:IsA("ClickDetector") and Compat.has_click then
        pcall(function() fireclickdetector(o) end)
    elseif o:IsA("TouchTransmitter") and Compat.has_touch then
        pcall(function()
            if HR then firetouchinterest(HR, o.Parent, 0) end
        end)
    end
end

function Scanner.nearestPrompt(matchFn)
    local best, bd = nil, math.huge
    for _, p in ipairs(Scanner.prompts()) do
        if matchFn(Scanner.promptText(p), p) then
            local pos = instPos(p.Adornee)
            if pos and HR then
                local d = (pos - HR.Position).Magnitude
                if d < bd then
                    bd, best = d, p
                end
            end
        end
    end
    return best, bd
end

--// ==========================================================
--//  СЧЁТЧИКИ СУЩНОСТЕЙ (контр-меры)
--// ==========================================================
local HIDE_WORDS   = { "hide", "closet", "bed", "шкаф" }
local function doHide()
    local p = Scanner.nearestPrompt(function(s)
        return has(s, HIDE_WORDS)
    end)
    if p then
        Scanner.fire(p)
        notify("🚪 в укрытии")
    else
        notify("укрытие не найдено")
    end
end

local function doTurn()
    CAM.CFrame = CAM.CFrame
        * CFrame.fromEulerAnglesXYZ(0, math.pi, 0)
    notify("🔄 разворот")
end

local function lookAwayFrom(pos)
    if not HR then return end
    local dir = HR.Position - pos
    dir = Vector3.new(dir.X, 0, dir.Z)
    if dir.Magnitude < 0.1 then
        dir = Vector3.new(0, 0, 1)
    end
    CAM.CFrame = CFrame.new(
        CAM.CFrame.Position,
        CAM.CFrame.Position + dir
    )
end

local function doBack()
    task.spawn(function()
        for _ = 1, 120 do
            if HR then
                HR.CFrame = HR.CFrame * CFrame.new(0, 0, 0.35)
            end
            task.wait(0.03)
        end
    end)
    notify("🚶 назад")
end

local function doFreeze()
    task.spawn(function()
        if not HU then return end
        local old = S.Speed
        S.Speed = 0
        if HR then HR.Velocity = Vector3.zero end
        task.wait(3)
        S.Speed = old
    end)
    notify("🧊 стоим тихо")
end

local function doRun(obj)
    task.spawn(function()
        local pos = instPos(obj)
        for _ = 1, 90 do
            if HR then
                local away = Vector3.new(0, 0, -1)
                if pos then
                    away = HR.Position - pos
                    away = Vector3.new(away.X, 0, away.Z)
                    if away.Magnitude > 0.1 then
                        away = away.Unit
                    end
                end
                HR.CFrame = HR.CFrame + away * 1.2
            end
            task.wait(0.03)
        end
    end)
    notify("🏃 рывок от seek")
end

--// ==========================================================
--//  ДЕФИНИЦИИ СУЩНОСТЕЙ
--// ==========================================================
local ENTITY_DEFS = {
    { key = "rush",    patterns = { "rush" },              counter = "hide",     color = rgb(255, 60, 60) },
    { key = "ambush",  patterns = { "ambush" },            counter = "hide",     color = rgb(255, 90, 40) },
    { key = "jack",    patterns = { "jack" },              counter = "hide",     color = rgb(255, 120, 60) },
    { key = "screech", patterns = { "screech" },           counter = "turn",     color = rgb(200, 60, 255) },
    { key = "eyes",    patterns = { "eyes" },              counter = "lookaway", color = rgb(160, 60, 255) },
    { key = "halt",    patterns = { "halt" },              counter = "back",     color = rgb(60, 120, 255) },
    { key = "figure",  patterns = { "figure" },            counter = "freeze",   color = rgb(255, 40, 40) },
    { key = "seek",    patterns = { "seek" },              counter = "run",      color = rgb(20, 20, 20) },
    { key = "timothy", patterns = { "timothy", "spider" }, counter = "notify",   color = rgb(120, 80, 40) },
    { key = "lookman", patterns = { "lookman" },           counter = "notify",   color = rgb(255, 200, 60) },
    { key = "dread",   patterns = { "dread" },             counter = "notify",   color = rgb(90, 0, 120) },
    { key = "shadow",  patterns = { "shadow" },            counter = "notify",   color = rgb(40, 40, 60) },
    { key = "glitch",  patterns = { "glitch" },            counter = "notify",   color = rgb(0, 255, 255) },
}

local function matchDef(name)
    for _, def in ipairs(ENTITY_DEFS) do
        if has(name, def.patterns) then
            return def
        end
    end
    return nil
end

local seenEnts = {}

local function onEntity(def, obj)
    if seenEnts[obj] then return end
    seenEnts[obj] = true
    if S.Alerts then
        notify("👁 " .. def.key)
    end
    if S.EspEnt then
        pcall(function()
            local h = Instance.new("Highlight")
            h:SetAttribute("gz", true)
            h.FillColor = def.color
            h.FillTransparency = 0.5
            h.OutlineColor = rgb(255, 255, 255)
            h.Parent = obj
        end)
    end
    local c = def.counter
    if c == "hide"     and S.AutoHide   then doHide()   end
    if c == "turn"     and S.AutoTurn   then doTurn()   end
    if c == "lookaway" and S.AutoLook   then
        local p = instPos(obj)
        if p then lookAwayFrom(p) end
    end
    if c == "back"     and S.AutoBack   then doBack()   end
    if c == "freeze"   and S.AutoFreeze then doFreeze() end
    if c == "run"      and S.AutoRun    then doRun(obj) end
end

--// watcher: модели/части
Workspace.DescendantAdded:Connect(function(o)
    safe(function()
        if o:IsA("Model") or o:IsA("BasePart") then
            local def = matchDef(o.Name)
            if def then onEntity(def, o) end
        end
        --// watcher: звуки
        if o:IsA("Sound") then
            local def = matchDef(o.Name)
            if def then onEntity(def, o.Parent or o) end
        end
    end)
end)

--// watcher: мигание света = rush/ambush рядом
local flickTimes = {}
Light.Changed:Connect(function()
    if not S.FlickGuard then return end
    local t = os.clock()
    table.insert(flickTimes, t)
    while flickTimes[1] and t - flickTimes[1] > 1 do
        table.remove(flickTimes, 1)
    end
    if #flickTimes >= 6 then
        flickTimes = {}
        if S.Alerts then
            notify("💡 мигание — кто-то рядом")
        end
        if S.AutoHide then
            doHide()
        end
    end
end)

--// ==========================================================
--//  ESP ДВИЖОК
--// ==========================================================
local ITEM_WORDS = { "key", "lockpick", "flashlight", "crucifix",
    "vitamins", "lighter", "candle", "skeleton", "battery",
    "bandage", "coin", "gold" }
local PUZ_WORDS  = { "lever", "fuse", "valve", "keypad",
    "puzzle", "paper", "note", "book" }
local DOOR_WORDS = { "door" }

local function hl(root, col)
    if root:FindFirstChildOfClass("Highlight") then return end
    pcall(function()
        local h = Instance.new("Highlight")
        h:SetAttribute("gz", true)
        h.FillColor = col
        h.FillTransparency = 0.6
        h.OutlineColor = rgb(255, 255, 255)
        h.Parent = root
    end)
end

local function clearHL()
    for _, h in ipairs(Scanner.all(Workspace)) do
        if h:IsA("Highlight") and h:GetAttribute("gz") then
            h:Destroy()
        end
    end
end

--// drawing-подписи для сущностей
local drawLabels = {}

local function drawClear()
    for _, d in pairs(drawLabels) do
        pcall(function() d:Remove() end)
    end
    drawLabels = {}
end

local function drawTick()
    if not Compat.has_drawing then return end
    if not S.EspEnt then
        drawClear()
        return
    end
    for obj, d in pairs(drawLabels) do
        if not obj.Parent then
            pcall(function() d:Remove() end)
            drawLabels[obj] = nil
        end
    end
    for _, o in ipairs(Scanner.all(Workspace)) do
        local def = matchDef(o.Name)
        if def and (o:IsA("Model") or o:IsA("BasePart")) then
            local pos = instPos(o)
            if pos then
                local scr, onScr = CAM:WorldToViewportPoint(pos)
                if onScr then
                    local d = drawLabels[o]
                    if not d then
                        d = safe(function()
                            local t = Drawing.new("Text")
                            t.Size = 14
                            t.Center = true
                            t.Outline = true
                            t.Color = def.color
                            return t
                        end)
                        drawLabels[o] = d
                    end
                    if d then
                        local dist = HR and math.floor(
                            (pos - HR.Position).Magnitude) or 0
                        d.Text = def.key .. " [" .. dist .. "m]"
                        d.Position = Vector2.new(scr.X, scr.Y - 20)
                        d.Visible = true
                    end
                end
            end
        end
    end
end

task.spawn(function()
    while task.wait(0.25) do
        safe(drawTick)
    end
end)

task.spawn(function()
    while task.wait(2) do
        local anyEsp = S.EspItems or S.EspEnt
            or S.EspPlayers or S.EspPuzzle or S.EspDoors
        if not anyEsp then
            clearHL()
            continue
        end
        for _, o in ipairs(Scanner.all(Workspace)) do
            local n = o.Name
            if S.EspItems and has(n, ITEM_WORDS) then
                hl(o, rgb(255, 210, 60))
            end
            if S.EspPuzzle and has(n, PUZ_WORDS) then
                hl(o, rgb(120, 200, 255))
            end
            if S.EspDoors and has(n, DOOR_WORDS) then
                hl(o, rgb(120, 255, 120))
            end
            if S.EspEnt then
                local def = matchDef(n)
                if def and (o:IsA("Model") or o:IsA("BasePart")) then
                    hl(o, def.color)
                end
            end
        end
        if S.EspPlayers then
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl ~= LP and pl.Character then
                    hl(pl.Character, rgb(70, 140, 255))
                end
            end
        end
    end
end)

--// ==========================================================
--//  ВИЗУАЛ
--// ==========================================================
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

local function killfx(o)
    if o:IsA("ParticleEmitter") or o:IsA("Fire")
        or o:IsA("Smoke") or o:IsA("Sparkles") then
        pcall(function()
            o.Enabled = false
            o.Rate = 0
        end)
    end
end

local function fpsBoost()
    Light.FogEnd = 1e7
    Light.GlobalShadows = false
    for _, o in ipairs(Scanner.all(Workspace)) do
        killfx(o)
    end
end

Workspace.DescendantAdded:Connect(function(o)
    if S.Fps then killfx(o) end
end)

--// ==========================================================
--//  ДВИЖЕНИЕ
--// ==========================================================
Run.Heartbeat:Connect(function(dt)
    if not (HR and HU and CH) then return end
    HU.WalkSpeed = S.Speed
    HU.JumpPower = S.Jump
    if S.Noclip then
        for _, p in ipairs(CH:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = false
            end
        end
    end
    if S.Fly then
        HR.Velocity = Vector3.zero
        HR.CFrame = HR.CFrame
            + HU.MoveDirection * S.FlySpeed * dt
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

--// ==========================================================
--//  ТАБЫ ЧАСТИ 1
--// ==========================================================
local TabEsp = Window:MakeTab({
    Name = "ESP",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false,
})

TabEsp:MakeToggle({
    Name = "ESP предметов",
    CurrentValue = S.EspItems,
    Flag = "EspItems",
    Callback = function(v) S.EspItems = v end,
})

TabEsp:MakeToggle({
    Name = "ESP сущностей + дистанция",
    CurrentValue = S.EspEnt,
    Flag = "EspEnt",
    Callback = function(v) S.EspEnt = v end,
})

TabEsp:MakeToggle({
    Name = "ESP игроков",
    CurrentValue = S.EspPlayers,
    Flag = "EspPlayers",
    Callback = function(v) S.EspPlayers = v end,
})

TabEsp:MakeToggle({
    Name = "ESP puzzles",
    CurrentValue = S.EspPuzzle,
    Flag = "EspPuzzle",
    Callback = function(v) S.EspPuzzle = v end,
})

TabEsp:MakeToggle({
    Name = "ESP дверей",
    CurrentValue = S.EspDoors,
    Flag = "EspDoors",
    Callback = function(v) S.EspDoors = v end,
})

local TabSurv = Window:MakeTab({
    Name = "Survive",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false,
})

TabSurv:MakeToggle({
    Name = "Алерт сущностей",
    CurrentValue = S.Alerts,
    Flag = "Alerts",
    Callback = function(v) S.Alerts = v end,
})

TabSurv:MakeToggle({
    Name = "Авто-шкаф (rush/ambush/jack)",
    CurrentValue = S.AutoHide,
    Flag = "AutoHide",
    Callback = function(v) S.AutoHide = v end,
})

TabSurv:MakeToggle({
    Name = "Анти-screech (разворот)",
    CurrentValue = S.AutoTurn,
    Flag = "AutoTurn",
    Callback = function(v) S.AutoTurn = v end,
})

TabSurv:MakeToggle({
    Name = "Анти-eyes (не смотреть)",
    CurrentValue = S.AutoLook,
    Flag = "AutoLook",
    Callback = function(v) S.AutoLook = v end,
})

TabSurv:MakeToggle({
    Name = "Анти-halt (ход назад)",
    CurrentValue = S.AutoBack,
    Flag = "AutoBack",
    Callback = function(v) S.AutoBack = v end,
})

TabSurv:MakeToggle({
    Name = "Анти-figure (стоять тихо)",
    CurrentValue = S.AutoFreeze,
    Flag = "AutoFreeze",
    Callback = function(v) S.AutoFreeze = v end,
})

TabSurv:MakeToggle({
    Name = "Анти-seek (рывок)",
    CurrentValue = S.AutoRun,
    Flag = "AutoRun",
    Callback = function(v) S.AutoRun = v end,
})

TabSurv:MakeToggle({
    Name = "Страж мигания ламп",
    CurrentValue = S.FlickGuard,
    Flag = "FlickGuard",
    Callback = function(v) S.FlickGuard = v end,
})

TabSurv:MakeButton({
    Name = "🚪 спрятаться сейчас",
    Callback = doHide,
})

local TabVis = Window:MakeTab({
    Name = "Visuals",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false,
})

TabVis:MakeToggle({
    Name = "Fullbright (без темноты)",
    CurrentValue = S.Fullbright,
    Flag = "Fullbright",
    Callback = function(v)
        S.Fullbright = v
        fullbright(v)
    end,
})

TabVis:MakeToggle({
    Name = "FPS-буст",
    CurrentValue = S.Fps,
    Flag = "Fps",
    Callback = function(v)
        S.Fps = v
        if v then fpsBoost() end
    end,
})

local TabMove = Window:MakeTab({
    Name = "Move",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false,
})

TabMove:MakeSlider({
    Name = "Speed",
    Range = { 16, 120 },
    Increment = 4,
    Suffix = " spd",
    CurrentValue = S.Speed,
    Flag = "Speed",
    Callback = function(v) S.Speed = v end,
})

TabMove:MakeSlider({
    Name = "Jump",
    Range = { 50, 200 },
    Increment = 10,
    Suffix = " pwr",
    CurrentValue = S.Jump,
    Flag = "Jump",
    Callback = function(v) S.Jump = v end,
})

TabMove:MakeSlider({
    Name = "Fly Speed",
    Range = { 20, 200 },
    Increment = 10,
    Suffix = " fly",
    CurrentValue = S.FlySpeed,
    Flag = "FlySpeed",
    Callback = function(v) S.FlySpeed = v end,
})

TabMove:MakeToggle({
    Name = "Инф-прыжок",
    CurrentValue = S.InfJump,
    Flag = "InfJump",
    Callback = function(v) S.InfJump = v end,
})

TabMove:MakeToggle({
    Name = "Флай",
    CurrentValue = S.Fly,
    Flag = "Fly",
    Callback = function(v) S.Fly = v end,
})

TabMove:MakeToggle({
    Name = "Noclip",
    CurrentValue = S.Noclip,
    Flag = "Noclip",
    Callback = function(v) S.Noclip = v end,
})

--// ==== ЧАСТЬ 2 НИЖЕ: loot, puzzle, shop, teleport, spy ====
--// ==========================================================
--//  gucci4080 • DOORS • ЧАСТЬ 2/2
--//  loot, puzzle, shop, teleport, players, spy, misc
--// ==========================================================

--// ==========================================================
--//  LOOT МОДУЛЬ
--// ==========================================================
local BOX_WORDS = { "drawer", "suitcase", "chest", "shelf",
    "cabinet", "locker", "box", "safe" }

local lootBusy = false

local function lootSweep()
    if lootBusy then return end
    lootBusy = true
    task.spawn(function()
        for _, p in ipairs(Scanner.prompts()) do
            local s = Scanner.promptText(p)
            if has(s, BOX_WORDS) or has(s, ITEM_WORDS) then
                Scanner.fire(p)
                task.wait(0.05)
            end
        end
        lootBusy = false
    end)
end

task.spawn(function()
    while task.wait(0.5) do
        if not S.AutoLoot then continue end
        safe(lootSweep)
    end
end)

task.spawn(function()
    while task.wait(0.4) do
        if not S.AutoDoors then continue end
        for _, p in ipairs(Scanner.prompts()) do
            local s = Scanner.promptText(p)
            if s:find("door", 1, true)
                or s:find("open", 1, true) then
                Scanner.fire(p)
            end
        end
    end
end)

--// ==========================================================
--//  SHOP МОДУЛЬ
--// ==========================================================
local shopItem = "flashlight"

local function buyNow()
    local p = Scanner.nearestPrompt(function(s)
        return s:find(shopItem, 1, true)
            or s:find("buy", 1, true)
            or s:find("purchase", 1, true)
    end)
    if p then
        Scanner.fire(p)
        notify("🛒 куплено: " .. shopItem)
    else
        notify("шоп не найден — ты в лобби?")
    end
end

task.spawn(function()
    while task.wait(0.6) do
        if not S.AutoShop then continue end
        safe(buyNow)
        task.wait(2)
    end
end)

--// ==========================================================
--//  PUZZLE МОДУЛЬ
--// ==========================================================
local function puzzleSweep()
    for _, p in ipairs(Scanner.prompts()) do
        if has(Scanner.promptText(p), PUZ_WORDS) then
            Scanner.fire(p)
            task.wait(0.05)
        end
    end
end

task.spawn(function()
    while task.wait(0.5) do
        if not S.AutoPuzzle then continue end
        safe(puzzleSweep)
    end
end)

--// читалка кода keypad с бумажек
local function readCodes()
    local found = {}
    for _, o in ipairs(Scanner.all(Workspace)) do
        if o:IsA("TextLabel") or o:IsA("TextButton") then
            safe(function()
                local t = o.Text
                if t and t:match("^%d%d%d%d?$") then
                    if #found < 3 then
                        table.insert(found, t)
                    end
                end
            end)
        end
    end
    if #found == 0 then
        notify("код не найден рядом")
    else
        for _, c in ipairs(found) do
            notify("🔢 код: " .. c)
        end
    end
end

--// ==========================================================
--//  TELEPORT МОДУЛЬ
--// ==========================================================
local roomIndex = {}

local function buildRooms()
    roomIndex = {}
    for _, o in ipairs(Scanner.all(Workspace)) do
        if o:IsA("Model") or o:IsA("BasePart") then
            local n = o.Name
            local num = tonumber(n)
                or tonumber(n:match("[Rr]oom%s*(%d+)") or "")
                or tonumber(n:match("[Dd]oor%s*(%d+)") or "")
            if num and not roomIndex[num] then
                roomIndex[num] = o
            end
        end
    end
    local count = 0
    for _ in pairs(roomIndex) do count = count + 1 end
    return count
end

local function goRoom(n)
    if not HR then return end
    local target = roomIndex[n]
    if not target then
        buildRooms()
        target = roomIndex[n]
    end
    if not target and n == 0 then
        for _, o in ipairs(Scanner.all(Workspace)) do
            if lower(o.Name):find("lobby", 1, true) then
                target = o
                break
            end
        end
    end
    if target then
        local pos = instPos(target)
        if pos then
            tp(pos + Vector3.new(0, 5, 0))
            notify("🚪 комната " .. n)
        end
    else
        notify("комната " .. n .. " не найдена")
    end
end

local function goExit()
    local maxN = 0
    for n in pairs(roomIndex) do
        if n > maxN then maxN = n end
    end
    if maxN == 0 then
        buildRooms()
        for n in pairs(roomIndex) do
            if n > maxN then maxN = n end
        end
    end
    if maxN > 0 then
        goRoom(maxN)
    else
        goRoom(100)
    end
end

--// ==========================================================
--//  PLAYERS МОДУЛЬ
--// ==========================================================
local targetPly = nil

local function playerNames()
    local out = {}
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LP then
            table.insert(out, pl.Name)
        end
    end
    if #out == 0 then
        table.insert(out, "никого")
    end
    return out
end

local function findPly(name)
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl.Name == name then return pl end
    end
    return nil
end

local function tpToPlayer(name)
    local pl = findPly(name)
    if not pl or not pl.Character then
        notify("игрок не найден")
        return
    end
    local pos = instPos(pl.Character)
    if pos then
        tp(pos + Vector3.new(0, 3, 0))
        notify(" к " .. name)
    end
end

local spectating = false

local function spectate(on)
    spectating = on
    if on then
        local pl = findPly(targetPly or "")
        if pl and pl.Character then
            local hum = pl.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                CAM.CameraSubject = hum
                notify("👁 слежу за " .. pl.Name)
            end
        end
    else
        if HU then CAM.CameraSubject = HU end
        notify("камера дома")
    end
end

task.spawn(function()
    while task.wait(1) do
        if not spectating then continue end
        local pl = findPly(targetPly or "")
        if pl and pl.Character then
            local hum = pl.Character:FindFirstChildOfClass("Humanoid")
            if hum and CAM.CameraSubject ~= hum then
                CAM.CameraSubject = hum
            end
        end
    end
end)

--// ==========================================================
--//  SPY МОДУЛЬ (сам учит имена игры)
--// ==========================================================
Compat.has_hook   = type(hookmetamethod) == "function"
Compat.has_caller = type(checkcaller) == "function"
Compat.has_nc     = type(newcclosure) == "function"

local spyNames   = {}
local spyPrompts = {}
local spyRemotes = {}
local spyOnNames   = false
local spyOnPrompts = false
local spyOnRemotes = false

Workspace.DescendantAdded:Connect(function(o)
    if spyOnNames then
        spyNames[o.Name] = (spyNames[o.Name] or 0) + 1
    end
    if spyOnPrompts and o:IsA("ProximityPrompt") then
        local s = Scanner.promptText(o)
        spyPrompts[s] = (spyPrompts[s] or 0) + 1
    end
end)

local remoteHooked = false

local function installRemoteSpy()
    if remoteHooked then return true end
    if not (Compat.has_hook and Compat.has_caller and Compat.has_nc) then
        notify("экзекутор без hookmetamethod")
        return false
    end
    local ok = pcall(function()
        local mt = getrawmetatable(game)
        local old = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local m = getnamecallmethod()
            if not checkcaller()
                and (m == "FireServer" or m == "InvokeServer") then
                local key = self.Name .. " [" .. m .. "]"
                spyRemotes[key] = (spyRemotes[key] or 0) + 1
            end
            return old(self, ...)
        end)
        setreadonly(mt, true)
    end)
    if ok then remoteHooked = true end
    return ok
end

local function dumpSpy()
    local lines = {}
    table.insert(lines, "== NAMES ==")
    for n, c in pairs(spyNames) do
        table.insert(lines, n .. " x" .. c)
    end
    table.insert(lines, "== PROMPTS ==")
    for n, c in pairs(spyPrompts) do
        table.insert(lines, n .. " x" .. c)
    end
    table.insert(lines, "== REMOTES ==")
    for n, c in pairs(spyRemotes) do
        table.insert(lines, n .. " x" .. c)
    end
    local text = table.concat(lines, "\n")
    Compat.write("gucci4080/doors_spy.txt", text)
    notify("📄 spy дамп в doors_spy.txt")
end

local function spySummary()
    local nCount, pCount, rCount = 0, 0, 0
    for _ in pairs(spyNames) do nCount = nCount + 1 end
    for _ in pairs(spyPrompts) do pCount = pCount + 1 end
    for _ in pairs(spyRemotes) do rCount = rCount + 1 end
    notify("spy: " .. nCount .. " имён, "
        .. pCount .. " промптов, "
        .. rCount .. " ремотов")
end

--// ==========================================================
--//  ТАБЫ ЧАСТИ 2
--// ==========================================================
local TabLoot = Window:MakeTab({
    Name = "Loot",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false,
})

TabLoot:MakeToggle({
    Name = "Авто-лут (ящики + предметы)",
    CurrentValue = S.AutoLoot,
    Flag = "AutoLoot",
    Callback = function(v) S.AutoLoot = v end,
})

TabLoot:MakeToggle({
    Name = "Авто-двери",
    CurrentValue = S.AutoDoors,
    Flag = "AutoDoors",
    Callback = function(v) S.AutoDoors = v end,
})

TabLoot:MakeButton({
    Name = "💰 обшарить всё сейчас",
    Callback = lootSweep,
})

TabLoot:MakeSection("шоп")

TabLoot:MakeDropdown({
    Name = "Предмет",
    Options = { "flashlight", "lockpick", "crucifix",
        "vitamins", "bandage", "lighter", "candle", "skeleton" },
    CurrentOption = "flashlight",
    MultipleOptions = false,
    Flag = "ShopItem",
    Callback = function(opt) shopItem = lower(opt) end,
})

TabLoot:MakeToggle({
    Name = "Авто-шоп",
    CurrentValue = S.AutoShop,
    Flag = "AutoShop",
    Callback = function(v) S.AutoShop = v end,
})

TabLoot:MakeButton({
    Name = "🛒 купить сейчас",
    Callback = buyNow,
})

local TabPuz = Window:MakeTab({
    Name = "Puzzle",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false,
})

TabPuz:MakeToggle({
    Name = "Авто-рычаги / fuse / вентили",
    CurrentValue = S.AutoPuzzle,
    Flag = "AutoPuzzle",
    Callback = function(v) S.AutoPuzzle = v end,
})

TabPuz:MakeButton({
    Name = "🧩 решить сейчас",
    Callback = puzzleSweep,
})

TabPuz:MakeButton({
    Name = "🔢 показать код keypad",
    Callback = readCodes,
})

local TabTp = Window:MakeTab({
    Name = "Teleport",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false,
})

local roomInput = "100"

TabTp:MakeTextbox({
    Name = "Номер комнаты",
    CurrentValue = "100",
    PlaceholderText = "0..100",
    RemoveOnFocus = false,
    Callback = function(v) roomInput = v end,
})

TabTp:MakeButton({
    Name = "🚪 в комнату",
    Callback = function()
        goRoom(tonumber(roomInput) or 100)
    end,
})

TabTp:MakeButton({
    Name = "🏁 выход (последняя)",
    Callback = goExit,
})

TabTp:MakeButton({
    Name = "🏠 лобби",
    Callback = function() goRoom(0) end,
})

TabTp:MakeButton({
    Name = "🗺 индекс комнат",
    Callback = function()
        local c = buildRooms()
        notify("🗺 комнат в индексе: " .. c)
    end,
})

local TabPly = Window:MakeTab({
    Name = "Players",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false,
})

local plyDrop = TabPly:MakeDropdown({
    Name = "Игрок",
    Options = playerNames(),
    CurrentOption = playerNames()[1],
    MultipleOptions = false,
    Flag = "TargetPly",
    Callback = function(n) targetPly = n end,
})

TabPly:MakeButton({
    Name = "🔄 обновить список",
    Callback = function()
        pcall(function()
            plyDrop:Refresh(playerNames(), true)
        end)
    end,
})

TabPly:MakeButton({
    Name = "🎯 телепорт к игроку",
    Callback = function()
        if targetPly then tpToPlayer(targetPly) end
    end,
})

TabPly:MakeToggle({
    Name = "Слежка (spectate)",
    CurrentValue = false,
    Flag = "Spectate",
    Callback = spectate,
})

local TabSpy = Window:MakeTab({
    Name = "Spy",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false,
})

TabSpy:MakeSection("училка имён")

TabSpy:MakeToggle({
    Name = "Spy имён моделей",
    CurrentValue = false,
    Flag = "SpyNames",
    Callback = function(v) spyOnNames = v end,
})

TabSpy:MakeToggle({
    Name = "Spy промптов",
    CurrentValue = false,
    Flag = "SpyPrompts",
    Callback = function(v)
        spyOnPrompts = v
        if v then
            for _, p in ipairs(Scanner.prompts()) do
                local s = Scanner.promptText(p)
                spyPrompts[s] = (spyPrompts[s] or 0) + 1
            end
        end
    end,
})

TabSpy:MakeToggle({
    Name = "Spy ремотов",
    CurrentValue = false,
    Flag = "SpyRemotes",
    Callback = function(v)
        if v then
            spyOnRemotes = installRemoteSpy()
        else
            spyOnRemotes = false
        end
    end,
})

TabSpy:MakeButton({
    Name = "📊 итог spy",
    Callback = spySummary,
})

TabSpy:MakeButton({
    Name = "📄 дамп в файл",
    Callback = dumpSpy,
})

local TabMisc = Window:MakeTab({
    Name = "Misc",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false,
})

TabMisc:MakeButton({
    Name = "💾 сохранить конфиг",
    Callback = function()
        saveCfg()
        notify("💾 конфиг в файле")
    end,
})

TabMisc:MakeButton({
    Name = "🗑 сброс конфига",
    Callback = function()
        S.Speed = 16
        S.Jump = 50
        S.FlySpeed = 60
        S.AutoLoot = false
        S.AutoDoors = false
        S.AutoShop = false
        S.AutoPuzzle = false
        S.InfJump = false
        S.Fly = false
        S.Noclip = false
        saveCfg()
        notify("🗑 конфиг сброшен")
    end,
})

TabMisc:MakeButton({
    Name = "⟳ реjoin",
    Callback = function()
        pcall(function() TS:Teleport(game.PlaceId) end)
    end,
})

TabMisc:MakeButton({
    Name = "🙈 скрыть гуи",
    Callback = function()
        Rayfield:Toggle()
    end,
})

TabMisc:MakeLabel({
    Name = "gucci4080 • doors full • v4080",
})

--// ==========================================================
--//  АВТО-СОХРАНЕНИЕ
--// ==========================================================
task.spawn(function()
    while task.wait(30) do
        safe(saveCfg)
    end
end)

--// ==========================================================
--//  СТАРТ
--// ==========================================================
task.spawn(function()
    local c = buildRooms()
    notify("🐀 doors full в стене. комнат: " .. c)
end)
