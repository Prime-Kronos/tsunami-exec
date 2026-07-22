-- ================================================
--   Primejtsu X | Flick Script v4.0
--   Rayfield GUI + Auto Shoot + Full Features
-- ================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Camera           = workspace.CurrentCamera
local LP               = Players.LocalPlayer
local Mouse            = LP:GetMouse()

-- ================================================
-- CONFIG
-- ================================================
local Cfg = {
    -- ESP
    ESPEnabled   = false, ESPMode = "Highlight",
    ESPColor     = Color3.fromRGB(255,0,0),
    ESPTransp    = 0.5,
    NameESP      = false,
    HealthBar    = false,
    -- Aim
    AimbotEnabled = false, AimbotSmooth = 0.15, AimbotPart = "Head",
    FOVEnabled   = false, FOVRadius = 150, FOVColor = Color3.fromRGB(255,255,255),
    -- Auto Shoot
    AutoShoot    = false,
    -- Movement
    InfJump      = false, BunnyHop = false,
    FlyEnabled   = false, FlySpeed = 50,
    SpeedEnabled = false, SpeedValue = 40,
    NoclipOn     = false, NoFallOn = false,
    -- Misc
    FullBright   = false, AntiAFK = false,
}

-- ================================================
-- FOV
-- ================================================
local FOVDraw = Drawing.new("Circle")
FOVDraw.Visible=false; FOVDraw.Thickness=1.5; FOVDraw.Filled=false
FOVDraw.NumSides=128; FOVDraw.Radius=150; FOVDraw.Color=Color3.fromRGB(255,255,255)

-- ================================================
-- ESP STORAGE
-- ================================================
local ESPObjects = {}

local function clearESP(p)
    if not ESPObjects[p] then return end
    if ESPObjects[p].hl  then ESPObjects[p].hl:Destroy() end
    if ESPObjects[p].box then for _,l in pairs(ESPObjects[p].box) do l:Remove() end end
    if ESPObjects[p].tr  then ESPObjects[p].tr:Remove() end
    if ESPObjects[p].name then ESPObjects[p].name:Remove() end
    if ESPObjects[p].hbar then ESPObjects[p].hbar:Remove() end
    if ESPObjects[p].hbarbg then ESPObjects[p].hbarbg:Remove() end
    ESPObjects[p] = nil
end

local function applyESP(p)
    clearESP(p)
    if p == LP then return end
    local obj = {}

    if Cfg.ESPEnabled then
        if Cfg.ESPMode == "Highlight" then
            local hl = Instance.new("Highlight")
            hl.FillColor = Cfg.ESPColor
            hl.OutlineColor = Cfg.ESPColor
            hl.FillTransparency = Cfg.ESPTransp
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            if p.Character then hl.Parent = p.Character end
            p.CharacterAdded:Connect(function(c) hl.Parent = c end)
            obj.hl = hl
        elseif Cfg.ESPMode == "Box" then
            local lines = {}
            for i=1,4 do
                local l=Drawing.new("Line"); l.Visible=false
                l.Color=Cfg.ESPColor; l.Thickness=1.5; lines[i]=l
            end
            obj.box = lines
        elseif Cfg.ESPMode == "Tracer" then
            local t=Drawing.new("Line"); t.Visible=false
            t.Color=Cfg.ESPColor; t.Thickness=1.5
            obj.tr = t
        end
    end

    if Cfg.NameESP then
        local n = Drawing.new("Text")
        n.Visible=false; n.Size=14; n.Center=true
        n.Outline=true; n.Color=Color3.fromRGB(255,255,255)
        obj.name = n
    end

    if Cfg.HealthBar then
        local bg = Drawing.new("Line")
        bg.Visible=false; bg.Thickness=4
        bg.Color=Color3.fromRGB(60,60,60)
        local bar = Drawing.new("Line")
        bar.Visible=false; bar.Thickness=4
        bar.Color=Color3.fromRGB(0,255,80)
        obj.hbarbg = bg
        obj.hbar = bar
    end

    ESPObjects[p] = obj
end

local function refreshESP()
    for _,p in pairs(Players:GetPlayers()) do applyESP(p) end
end

Players.PlayerAdded:Connect(function(p) applyESP(p) end)
Players.PlayerRemoving:Connect(clearESP)

-- ================================================
-- GET TARGET
-- ================================================
local function isVisible(part)
    local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 500)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LP.Character, workspace.Terrain})
    if hit then
        return hit:IsDescendantOf(part.Parent)
    end
    return false
end

local function getTarget()
    local best, bestD = nil, Cfg.FOVRadius
    local cx, cy = Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local part = p.Character:FindFirstChild(Cfg.AimbotPart)
                          or p.Character:FindFirstChild("HumanoidRootPart")
                if part then
                    local sp, vis = Camera:WorldToViewportPoint(part.Position)
                    if vis then
                        local d = math.sqrt((sp.X-cx)^2+(sp.Y-cy)^2)
                        if d < bestD and isVisible(part) then
                            bestD=d; best={part=part, player=p}
                        end
                    end
                end
            end
        end
    end
    return best
end

-- ================================================
-- AUTO SHOOT
-- ================================================
-- Auto Shoot using VirtualInputManager
local VIM = game:GetService("VirtualInputManager")
local autoShootCooldown = false

RunService.Heartbeat:Connect(function()
    if not Cfg.AutoShoot then return end
    if autoShootCooldown then return end

    local t = getTarget()
    if t then
        autoShootCooldown = true

        task.spawn(function()
            -- Сохраняем камеру
            local savedCF = Camera.CFrame
            local savedCamType = Camera.CameraType

            -- Снапаем только на 1 кадр
            Camera.CameraType = Enum.CameraType.Scriptable
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, t.part.Position)

            -- Стреляем
            local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
            VIM:SendMouseButtonEvent(screenCenter.X, screenCenter.Y, 0, true, game, 0)
            task.wait(0.05)
            VIM:SendMouseButtonEvent(screenCenter.X, screenCenter.Y, 0, false, game, 0)

            -- Возвращаем камеру игроку
            Camera.CameraType = savedCamType

            task.wait(0.12)
            autoShootCooldown = false
        end)
    end
end)

-- ================================================
-- FLY
-- ================================================
local flyConn
local function toggleFly(on)
    if on then
        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum  = char:FindFirstChild("Humanoid")
        if not root or not hum then return end
        hum.PlatformStand = true
        local bp = Instance.new("BodyPosition")
        bp.MaxForce = Vector3.new(1e5,1e5,1e5)
        bp.Position = root.Position
        bp.Parent = root
        local bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
        bg.CFrame = Camera.CFrame
        bg.Parent = root
        flyConn = RunService.Heartbeat:Connect(function()
            if not Cfg.FlyEnabled then return end
            local cf = Camera.CFrame
            local dir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
            bp.Position = bp.Position + dir * Cfg.FlySpeed * 0.016
            bg.CFrame = cf
        end)
    else
        if flyConn then flyConn:Disconnect(); flyConn=nil end
        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum  = char:FindFirstChild("Humanoid")
        if root then
            local bp = root:FindFirstChild("BodyPosition")
            local bg = root:FindFirstChild("BodyGyro")
            if bp then bp:Destroy() end
            if bg then bg:Destroy() end
        end
        if hum then hum.PlatformStand = false end
    end
end

-- ================================================
-- RENDER LOOP
-- ================================================
RunService.RenderStepped:Connect(function()
    -- FOV
    FOVDraw.Visible  = Cfg.FOVEnabled
    FOVDraw.Radius   = Cfg.FOVRadius
    FOVDraw.Color    = Cfg.FOVColor
    FOVDraw.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    -- ESP loop
    for p, obj in pairs(ESPObjects) do
        if p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local hum  = p.Character:FindFirstChild("Humanoid")

            -- Box
            if obj.box and root then
                local pos,vis = Camera:WorldToViewportPoint(root.Position)
                if vis then
                    local sz=2000/pos.Z; local x,y=pos.X,pos.Y; local w,h=sz*0.4,sz*1.2
                    local c={{Vector2.new(x-w,y-h),Vector2.new(x+w,y-h)},{Vector2.new(x-w,y+h),Vector2.new(x+w,y+h)},{Vector2.new(x-w,y-h),Vector2.new(x-w,y+h)},{Vector2.new(x+w,y-h),Vector2.new(x+w,y+h)}}
                    for i,v in ipairs(c) do obj.box[i].From=v[1];obj.box[i].To=v[2];obj.box[i].Color=Cfg.ESPColor;obj.box[i].Visible=true end
                else for _,l in pairs(obj.box) do l.Visible=false end end
            end

            -- Tracer
            if obj.tr and root then
                local pos,vis = Camera:WorldToViewportPoint(root.Position)
                if vis then
                    obj.tr.From=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y)
                    obj.tr.To=Vector2.new(pos.X,pos.Y)
                    obj.tr.Color=Cfg.ESPColor; obj.tr.Visible=true
                else obj.tr.Visible=false end
            end

            -- Name ESP
            if obj.name and root then
                local pos,vis = Camera:WorldToViewportPoint(root.Position + Vector3.new(0,2.5,0))
                if vis then
                    obj.name.Text = p.Name
                    obj.name.Position = Vector2.new(pos.X, pos.Y)
                    obj.name.Visible = true
                else obj.name.Visible=false end
            end

            -- Health Bar
            if obj.hbar and obj.hbarbg and root and hum then
                local pos,vis = Camera:WorldToViewportPoint(root.Position)
                if vis then
                    local sz=2000/pos.Z; local x,y=pos.X,pos.Y; local h=sz*1.2
                    local hpct = hum.Health / hum.MaxHealth
                    obj.hbarbg.From = Vector2.new(x-sz*0.5-6, y-h)
                    obj.hbarbg.To   = Vector2.new(x-sz*0.5-6, y+h)
                    obj.hbarbg.Visible = true
                    obj.hbar.From = Vector2.new(x-sz*0.5-6, y+h)
                    obj.hbar.To   = Vector2.new(x-sz*0.5-6, y+h - h*2*hpct)
                    obj.hbar.Color = Color3.fromRGB(math.floor(255*(1-hpct)), math.floor(255*hpct), 0)
                    obj.hbar.Visible = true
                else
                    obj.hbar.Visible=false; obj.hbarbg.Visible=false
                end
            end
        end
    end

    -- Aimbot
    if Cfg.AimbotEnabled then
        local t = getTarget()
        if t then
            Camera.CFrame = Camera.CFrame:Lerp(
                CFrame.lookAt(Camera.CFrame.Position, t.part.Position),
                Cfg.AimbotSmooth
            )
        end
    end
end)

-- ================================================
-- MOVEMENT
-- ================================================
UserInputService.JumpRequest:Connect(function()
    if Cfg.InfJump and LP.Character then
        local h=LP.Character:FindFirstChild("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

RunService.Heartbeat:Connect(function()
    if LP.Character then
        local h=LP.Character:FindFirstChild("Humanoid")
        if h then
            h.WalkSpeed = Cfg.SpeedEnabled and Cfg.SpeedValue or 16
            if Cfg.BunnyHop and h:GetState()==Enum.HumanoidStateType.Landed then
                h:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

RunService.Stepped:Connect(function()
    if Cfg.NoclipOn and LP.Character then
        for _,p in pairs(LP.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=false end
        end
    end
end)

LP.CharacterAdded:Connect(function(char)
    local h=char:WaitForChild("Humanoid")
    h.StateChanged:Connect(function(_,new)
        if Cfg.NoFallOn and new==Enum.HumanoidStateType.Freefall then
            h:ChangeState(Enum.HumanoidStateType.Running)
        end
    end)
    if Cfg.FlyEnabled then toggleFly(true) end
end)

-- Fullbright
local Lighting=game:GetService("Lighting")
local function setFullBright(on)
    Lighting.Brightness=on and 10 or 1; Lighting.ClockTime=14
    Lighting.GlobalShadows=not on
    Lighting.Ambient=on and Color3.fromRGB(255,255,255) or Color3.fromRGB(127,127,127)
end

-- Anti-AFK
local function startAntiAFK()
    LP.Idled:Connect(function()
        local vu=game:GetService("VirtualUser")
        vu:Button1Down(Vector2.new(0,0),Camera.CFrame)
        task.wait(0.1)
        vu:Button1Up(Vector2.new(0,0),Camera.CFrame)
    end)
end

-- ================================================
-- RAYFIELD GUI
-- ================================================
local Window = Rayfield:CreateWindow({
    Name            = "Primejtsu X | Flick Script",
    LoadingTitle    = "Primejtsu X",
    LoadingSubtitle = "Loading v4.0...",
    Theme           = "Default",
    DisableRayfieldPrompts  = false,
    DisableBuildWarnings    = false,
    ConfigurationSaving = {
        Enabled = false,
    },
})

-- RGB accent on Rayfield (window border)
local hue = 0
RunService.Heartbeat:Connect(function()
    hue = (hue + 0.002) % 1
end)

-- ================================================
-- TAB: ESP
-- ================================================
local TabESP = Window:CreateTab("ESP", 4483362458)

TabESP:CreateToggle({
    Name="Enable ESP", CurrentValue=false, Flag="ESPToggle",
    Callback=function(v) Cfg.ESPEnabled=v; refreshESP() end,
})
TabESP:CreateDropdown({
    Name="ESP Mode", Options={"Highlight","Box","Tracer"},
    CurrentOption={"Highlight"}, Flag="ESPMode",
    Callback=function(o) Cfg.ESPMode=o[1]; refreshESP() end,
})
TabESP:CreateDropdown({
    Name="ESP Color",
    Options={"Red","Green","Blue","Yellow","Purple","Cyan","White","Orange"},
    CurrentOption={"Red"}, Flag="ESPColor",
    Callback=function(o)
        local c={Red=Color3.fromRGB(255,0,0),Green=Color3.fromRGB(0,255,0),
            Blue=Color3.fromRGB(0,100,255),Yellow=Color3.fromRGB(255,255,0),
            Purple=Color3.fromRGB(180,0,255),Cyan=Color3.fromRGB(0,255,255),
            White=Color3.fromRGB(255,255,255),Orange=Color3.fromRGB(255,140,0)}
        if c[o[1]] then Cfg.ESPColor=c[o[1]]; refreshESP() end
    end,
})
TabESP:CreateSlider({
    Name="Transparency", Range={0,10}, Increment=1, CurrentValue=5, Flag="ESPTransp",
    Callback=function(v) Cfg.ESPTransp=v/10; refreshESP() end,
})
TabESP:CreateToggle({
    Name="Name ESP", CurrentValue=false, Flag="NameESP",
    Callback=function(v) Cfg.NameESP=v; refreshESP() end,
})
TabESP:CreateToggle({
    Name="Health Bar", CurrentValue=false, Flag="HealthBar",
    Callback=function(v) Cfg.HealthBar=v; refreshESP() end,
})

-- ================================================
-- TAB: Aimbot
-- ================================================
local TabAim = Window:CreateTab("Aimbot", 4483362458)

TabAim:CreateToggle({
    Name="Enable Aimbot", CurrentValue=false, Flag="AimbotToggle",
    Callback=function(v) Cfg.AimbotEnabled=v end,
})
TabAim:CreateToggle({
    Name="Auto Shoot (видит - стреляет)", CurrentValue=false, Flag="AutoShoot",
    Callback=function(v) Cfg.AutoShoot=v end,
})
TabAim:CreateToggle({
    Name="FOV Circle", CurrentValue=false, Flag="FOVToggle",
    Callback=function(v) Cfg.FOVEnabled=v end,
})
TabAim:CreateSlider({
    Name="FOV Radius", Range={30,500}, Increment=5, CurrentValue=150, Flag="FOVRadius",
    Callback=function(v) Cfg.FOVRadius=v end,
})
TabAim:CreateSlider({
    Name="Smoothness (меньше = быстрее)", Range={1,100}, Increment=1, CurrentValue=15, Flag="AimSmooth",
    Callback=function(v) Cfg.AimbotSmooth=v/100 end,
})
TabAim:CreateDropdown({
    Name="Aim Part", Options={"Head","HumanoidRootPart","UpperTorso","Torso"},
    CurrentOption={"Head"}, Flag="AimPart",
    Callback=function(o) Cfg.AimbotPart=o[1] end,
})
TabAim:CreateDropdown({
    Name="FOV Color", Options={"White","Yellow","Red","Green","Blue","Cyan","Purple"},
    CurrentOption={"White"}, Flag="FOVColor",
    Callback=function(o)
        local c={White=Color3.fromRGB(255,255,255),Yellow=Color3.fromRGB(255,255,0),
            Red=Color3.fromRGB(255,0,0),Green=Color3.fromRGB(0,255,0),
            Blue=Color3.fromRGB(0,100,255),Cyan=Color3.fromRGB(0,255,255),
            Purple=Color3.fromRGB(150,80,255)}
        if c[o[1]] then Cfg.FOVColor=c[o[1]] end
    end,
})

-- ================================================
-- TAB: Movement
-- ================================================
local TabMove = Window:CreateTab("Movement", 4483362458)

TabMove:CreateToggle({
    Name="Infinite Jump", CurrentValue=false, Flag="InfJump",
    Callback=function(v) Cfg.InfJump=v end,
})
TabMove:CreateToggle({
    Name="BunnyHop", CurrentValue=false, Flag="BHop",
    Callback=function(v) Cfg.BunnyHop=v end,
})
TabMove:CreateToggle({
    Name="Fly (W/A/S/D + Space/Shift)", CurrentValue=false, Flag="Fly",
    Callback=function(v) Cfg.FlyEnabled=v; toggleFly(v) end,
})
TabMove:CreateSlider({
    Name="Fly Speed", Range={10,200}, Increment=5, CurrentValue=50, Flag="FlySpeed",
    Callback=function(v) Cfg.FlySpeed=v end,
})
TabMove:CreateToggle({
    Name="Speed Hack", CurrentValue=false, Flag="SpeedHack",
    Callback=function(v) Cfg.SpeedEnabled=v end,
})
TabMove:CreateSlider({
    Name="Walk Speed", Range={16,200}, Increment=1, CurrentValue=40, Flag="WalkSpeed",
    Callback=function(v) Cfg.SpeedValue=v end,
})
TabMove:CreateToggle({
    Name="Noclip", CurrentValue=false, Flag="Noclip",
    Callback=function(v) Cfg.NoclipOn=v end,
})
TabMove:CreateToggle({
    Name="No Fall Damage", CurrentValue=false, Flag="NoFall",
    Callback=function(v) Cfg.NoFallOn=v end,
})

-- ================================================
-- TAB: Misc
-- ================================================
local TabMisc = Window:CreateTab("Misc", 4483362458)

TabMisc:CreateToggle({
    Name="Fullbright", CurrentValue=false, Flag="Fullbright",
    Callback=function(v) setFullBright(v) end,
})
TabMisc:CreateToggle({
    Name="Anti-AFK", CurrentValue=false, Flag="AntiAFK",
    Callback=function(v) if v then startAntiAFK() end end,
})

-- Player List
TabMisc:CreateSection("Player List")
local function updatePlayerList()
    Rayfield:Notify({
        Title="Players in Server",
        Content=table.concat((function()
            local names={}
            for _,p in pairs(Players:GetPlayers()) do
                local hum = p.Character and p.Character:FindFirstChild("Humanoid")
                local hp = hum and math.floor(hum.Health) or "?"
                table.insert(names, p.Name.." ["..hp.." HP]")
            end
            return names
        end)(), "\n"),
        Duration=6,
        Image=4483362458,
    })
end
TabMisc:CreateButton({
    Name="Show Player List",
    Callback=updatePlayerList,
})

TabMisc:CreateButton({
    Name="Teleport to Spawn",
    Callback=function()
        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            LP.Character.HumanoidRootPart.CFrame=CFrame.new(0,10,0)
        end
    end,
})
TabMisc:CreateButton({
    Name="Respawn",
    Callback=function()
        if LP.Character then
            local h=LP.Character:FindFirstChild("Humanoid")
            if h then h.Health=0 end
        end
    end,
})
TabMisc:CreateButton({
    Name="Rejoin",
    Callback=function()
        game:GetService("TeleportService"):Teleport(game.PlaceId,LP)
    end,
})

-- ================================================
-- TAB: About
-- ================================================
local TabAbout = Window:CreateTab("About", 4483362458)

TabAbout:CreateSection("Primejtsu X | Flick Script")
TabAbout:CreateLabel("Creator: @Primejtsu")
TabAbout:CreateLabel("Version: v4.0")
TabAbout:CreateLabel("Game: [FPS] Flick")
TabAbout:CreateSection("Links")
TabAbout:CreateButton({
    Name="Telegram: t.me/Primejtsu",
    Callback=function()
        Rayfield:Notify({
            Title="Telegram",
            Content="t.me/Primejtsu",
            Duration=4,
            Image=4483362458,
        })
    end,
})
TabAbout:CreateSection("Credits")
TabAbout:CreateLabel("GUI: Rayfield by Sirius")
TabAbout:CreateLabel("Script: Primejtsu X Team")

-- ================================================
-- STARTUP NOTIFICATION
-- ================================================
task.wait(0.5)
Rayfield:Notify({
    Title    = "Primejtsu X | Flick Script",
    Content  = "Thank you for choosing us!\nСпасибо что выбрали нас!",
    Duration = 6,
    Image    = 4483362458,
})

print("[Primejtsu X] v4.0 Loaded.")
