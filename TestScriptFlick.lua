-- ================================================
--   Primejtsu X | Flick Script
--   AI Helper Edition
-- ================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera           = workspace.CurrentCamera
local LP               = Players.LocalPlayer

-- ================================================
-- CONFIG
-- ================================================
local Cfg = {
    -- ESP
    ESPEnabled   = false, ESPMode = "Highlight",
    ESPColor     = Color3.fromRGB(255,0,0), ESPTransp = 0.5,
    NameESP      = false, HealthBar = false,
    -- Aim
    AimbotEnabled = false, AimbotSmooth = 0.15, AimbotPart = "Head",
    FOVEnabled   = false, FOVRadius = 150,
    FOVColor     = Color3.fromRGB(255,255,255),
    -- Movement
    InfJump      = false, BunnyHop = false,
    FlyEnabled   = false, FlySpeed = 50,
    SpeedEnabled = false, SpeedValue = 40,
    NoclipOn     = false, NoFallOn = false,
    -- Misc
    FullBright   = false, AntiAFK = false,
    -- AI Helper
    AIHelper     = false,
    DodgeDist    = 3,   -- метры телепорта
}

-- ================================================
-- AI HELPER — детект выстрела + телепорт
-- ================================================
local aiCooldown    = false
local lastBulletTime = 0

-- Детектируем выстрел по нам через 2 метода:
-- 1) Попадание пули — ищем BasePart с именем "Bullet"/"Projectile" рядом с нами
-- 2) Резкое появление партикла/звука около персонажа

local function dodgeNow()
    if aiCooldown then return end
    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    aiCooldown = true

    -- Случайное направление для уклонения (влево или вправо)
    local directions = {
        Vector3.new(1,0,0),
        Vector3.new(-1,0,0),
        Vector3.new(0,0,1),
        Vector3.new(0,0,-1),
    }
    local dir = directions[math.random(1,4)]
    local dodgePos = root.Position + dir * Cfg.DodgeDist

    -- Телепортируем
    root.CFrame = CFrame.new(dodgePos) * (root.CFrame - root.CFrame.Position)

    -- Уведомление
    Rayfield:Notify({
        Title   = "AI Helper",
        Content = "Уклонение! Телепорт на " .. Cfg.DodgeDist .. "м",
        Duration = 1,
        Image   = 4483362458,
    })

    task.wait(0.4)
    aiCooldown = false
end

-- Метод 1: ищем пули/снаряды рядом с персонажем каждый кадр
RunService.Heartbeat:Connect(function()
    if not Cfg.AIHelper then return end
    if aiCooldown then return end

    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Ищем любой быстро движущийся объект рядом (пуля)
    local detected = false
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(char) then
            local name = obj.Name:lower()
            -- Общие названия пуль в Roblox играх
            if name:find("bullet") or name:find("proj") or name:find("shot")
            or name:find("pellet") or name:find("ammo") or name:find("ball")
            or name:find("laser") or name:find("ray") then
                local dist = (obj.Position - root.Position).Magnitude
                if dist < 12 then -- пуля в 12 метрах от нас
                    -- Проверяем что пуля летит В НАШУ сторону
                    local vel = obj.AssemblyLinearVelocity
                    if vel.Magnitude > 20 then
                        local toUs = (root.Position - obj.Position).Unit
                        local dot = vel.Unit:Dot(toUs)
                        if dot > 0.6 then -- летит к нам
                            detected = true
                            break
                        end
                    end
                end
            end
        end
    end

    if detected then
        dodgeNow()
    end
end)

-- Метод 2: детект через RaycastParams — стреляет ли кто-то в нас
RunService.Heartbeat:Connect(function()
    if not Cfg.AIHelper then return end
    if aiCooldown then return end

    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Проверяем каждого врага — смотрит ли он в нашу сторону с оружием
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local eRoot = p.Character:FindFirstChild("HumanoidRootPart")
            if eRoot then
                local dist = (eRoot.Position - root.Position).Magnitude
                if dist < 60 then -- враг в 60 метрах
                    -- Смотрит ли враг на нас
                    local toUs = (root.Position - eRoot.Position).Unit
                    local enemyLook = eRoot.CFrame.LookVector
                    local dot = enemyLook:Dot(toUs)

                    if dot > 0.92 then -- враг почти точно смотрит на нас (прицел)
                        -- Делаем raycast от врага к нам
                        local rayParams = RaycastParams.new()
                        rayParams.FilterDescendantsInstances = {p.Character, workspace.Terrain}
                        rayParams.FilterType = Enum.RaycastFilterType.Exclude

                        local result = workspace:Raycast(
                            eRoot.Position,
                            (root.Position - eRoot.Position),
                            rayParams
                        )

                        -- Если raycast достиг нашего персонажа — враг целится в нас
                        if result and result.Instance and result.Instance:IsDescendantOf(char) then
                            dodgeNow()
                            break
                        end
                    end
                end
            end
        end
    end
end)

-- ================================================
-- FOV
-- ================================================
local FOVDraw = Drawing.new("Circle")
FOVDraw.Visible=false; FOVDraw.Thickness=1.5; FOVDraw.Filled=false
FOVDraw.NumSides=128; FOVDraw.Radius=150; FOVDraw.Color=Color3.fromRGB(255,255,255)

-- ================================================
-- ESP
-- ================================================
local ESPObjects = {}
local function clearESP(p)
    if not ESPObjects[p] then return end
    if ESPObjects[p].hl then ESPObjects[p].hl:Destroy() end
    if ESPObjects[p].box then for _,l in pairs(ESPObjects[p].box) do l:Remove() end end
    if ESPObjects[p].tr then ESPObjects[p].tr:Remove() end
    if ESPObjects[p].nm then ESPObjects[p].nm:Remove() end
    if ESPObjects[p].hb then ESPObjects[p].hb:Remove() end
    if ESPObjects[p].hbbg then ESPObjects[p].hbbg:Remove() end
    ESPObjects[p] = nil
end
local function applyESP(p)
    clearESP(p)
    if p == LP then return end
    local obj = {}
    if Cfg.ESPEnabled then
        if Cfg.ESPMode == "Highlight" then
            local hl = Instance.new("Highlight")
            hl.FillColor=Cfg.ESPColor; hl.OutlineColor=Cfg.ESPColor
            hl.FillTransparency=Cfg.ESPTransp
            hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
            if p.Character then hl.Parent=p.Character end
            p.CharacterAdded:Connect(function(c) hl.Parent=c end)
            obj.hl=hl
        elseif Cfg.ESPMode == "Box" then
            local lines={}
            for i=1,4 do local l=Drawing.new("Line");l.Visible=false;l.Color=Cfg.ESPColor;l.Thickness=1.5;lines[i]=l end
            obj.box=lines
        elseif Cfg.ESPMode == "Tracer" then
            local t=Drawing.new("Line");t.Visible=false;t.Color=Cfg.ESPColor;t.Thickness=1.5;obj.tr=t
        end
    end
    if Cfg.NameESP then
        local n=Drawing.new("Text");n.Visible=false;n.Size=13;n.Center=true
        n.Outline=true;n.Color=Color3.fromRGB(255,255,255);obj.nm=n
    end
    if Cfg.HealthBar then
        local bg=Drawing.new("Line");bg.Visible=false;bg.Thickness=3;bg.Color=Color3.fromRGB(50,50,50);obj.hbbg=bg
        local b=Drawing.new("Line");b.Visible=false;b.Thickness=3;b.Color=Color3.fromRGB(0,255,80);obj.hb=b
    end
    ESPObjects[p]=obj
end
local function refreshESP() for _,p in pairs(Players:GetPlayers()) do applyESP(p) end end
Players.PlayerAdded:Connect(function(p) applyESP(p) end)
Players.PlayerRemoving:Connect(clearESP)

local function getTarget()
    local best,bestD=nil,Cfg.FOVRadius
    local cx,cy=Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2
    for _,p in pairs(Players:GetPlayers()) do
        if p~=LP and p.Character then
            local hum=p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health>0 then
                local part=p.Character:FindFirstChild(Cfg.AimbotPart) or p.Character:FindFirstChild("HumanoidRootPart")
                if part then
                    local sp,vis=Camera:WorldToViewportPoint(part.Position)
                    if vis then
                        local d=math.sqrt((sp.X-cx)^2+(sp.Y-cy)^2)
                        if d<bestD then bestD=d;best=part end
                    end
                end
            end
        end
    end
    return best
end

RunService.RenderStepped:Connect(function()
    FOVDraw.Visible=Cfg.FOVEnabled; FOVDraw.Radius=Cfg.FOVRadius
    FOVDraw.Color=Cfg.FOVColor
    FOVDraw.Position=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)

    for p,obj in pairs(ESPObjects) do
        if p.Character then
            local root=p.Character:FindFirstChild("HumanoidRootPart")
            local hum=p.Character:FindFirstChild("Humanoid")
            if obj.box and root then
                local pos,vis=Camera:WorldToViewportPoint(root.Position)
                if vis then
                    local sz=2000/pos.Z;local x,y=pos.X,pos.Y;local w,h=sz*0.4,sz*1.2
                    local c={{Vector2.new(x-w,y-h),Vector2.new(x+w,y-h)},{Vector2.new(x-w,y+h),Vector2.new(x+w,y+h)},{Vector2.new(x-w,y-h),Vector2.new(x-w,y+h)},{Vector2.new(x+w,y-h),Vector2.new(x+w,y+h)}}
                    for i,v in ipairs(c) do obj.box[i].From=v[1];obj.box[i].To=v[2];obj.box[i].Color=Cfg.ESPColor;obj.box[i].Visible=true end
                else for _,l in pairs(obj.box) do l.Visible=false end end
            end
            if obj.tr and root then
                local pos,vis=Camera:WorldToViewportPoint(root.Position)
                if vis then
                    obj.tr.From=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y)
                    obj.tr.To=Vector2.new(pos.X,pos.Y)
                    obj.tr.Color=Cfg.ESPColor;obj.tr.Visible=true
                else obj.tr.Visible=false end
            end
            if obj.nm and root then
                local pos,vis=Camera:WorldToViewportPoint(root.Position+Vector3.new(0,2.5,0))
                if vis then obj.nm.Text=p.Name;obj.nm.Position=Vector2.new(pos.X,pos.Y);obj.nm.Visible=true
                else obj.nm.Visible=false end
            end
            if obj.hb and obj.hbbg and root and hum then
                local pos,vis=Camera:WorldToViewportPoint(root.Position)
                if vis then
                    local sz=2000/pos.Z;local x,y=pos.X,pos.Y;local h=sz*1.2
                    local hp=hum.Health/hum.MaxHealth
                    obj.hbbg.From=Vector2.new(x-sz*0.5-6,y-h);obj.hbbg.To=Vector2.new(x-sz*0.5-6,y+h);obj.hbbg.Visible=true
                    obj.hb.From=Vector2.new(x-sz*0.5-6,y+h);obj.hb.To=Vector2.new(x-sz*0.5-6,y+h-h*2*hp)
                    obj.hb.Color=Color3.fromRGB(math.floor(255*(1-hp)),math.floor(255*hp),0);obj.hb.Visible=true
                else obj.hb.Visible=false;obj.hbbg.Visible=false end
            end
        end
    end

    if Cfg.AimbotEnabled then
        local t=getTarget()
        if t then Camera.CFrame=Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position,t.Position),Cfg.AimbotSmooth) end
    end
end)

-- Movement
local flyConn
local function toggleFly(on)
    if on then
        local char=LP.Character;if not char then return end
        local root=char:FindFirstChild("HumanoidRootPart")
        local hum=char:FindFirstChild("Humanoid")
        if not root or not hum then return end
        hum.PlatformStand=true
        local bp=Instance.new("BodyPosition");bp.MaxForce=Vector3.new(1e5,1e5,1e5);bp.Position=root.Position;bp.Parent=root
        local bg=Instance.new("BodyGyro");bg.MaxTorque=Vector3.new(1e5,1e5,1e5);bg.CFrame=Camera.CFrame;bg.Parent=root
        flyConn=RunService.Heartbeat:Connect(function()
            if not Cfg.FlyEnabled then return end
            local cf=Camera.CFrame;local dir=Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir=dir+cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir=dir-cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir=dir-cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir=dir+cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir=dir+Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir=dir-Vector3.new(0,1,0) end
            bp.Position=bp.Position+dir*Cfg.FlySpeed*0.016;bg.CFrame=cf
        end)
    else
        if flyConn then flyConn:Disconnect();flyConn=nil end
        local char=LP.Character;if not char then return end
        local root=char:FindFirstChild("HumanoidRootPart")
        local hum=char:FindFirstChild("Humanoid")
        if root then
            local b=root:FindFirstChild("BodyPosition");local g=root:FindFirstChild("BodyGyro")
            if b then b:Destroy() end;if g then g:Destroy() end
        end
        if hum then hum.PlatformStand=false end
    end
end

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
            h.WalkSpeed=Cfg.SpeedEnabled and Cfg.SpeedValue or 16
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

local Lighting=game:GetService("Lighting")
local function setFullBright(on)
    Lighting.Brightness=on and 10 or 1;Lighting.ClockTime=14
    Lighting.GlobalShadows=not on
    Lighting.Ambient=on and Color3.fromRGB(255,255,255) or Color3.fromRGB(127,127,127)
end

-- ================================================
-- RAYFIELD GUI
-- ================================================
local Window = Rayfield:CreateWindow({
    Name            = "Primejtsu X | Flick Script",
    LoadingTitle    = "Primejtsu X",
    LoadingSubtitle = "AI Helper Edition",
    Theme           = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings   = false,
})

-- TAB: AI Helper
local TabAI = Window:CreateTab("AI Helper", 4483362458)

TabAI:CreateSection("AI Helper — Авто Уклонение")

TabAI:CreateToggle({
    Name="AI Helper (Авто уклонение)", CurrentValue=false, Flag="AIHelper",
    Callback=function(v)
        Cfg.AIHelper=v
        Rayfield:Notify({
            Title="AI Helper",
            Content=v and "AI Helper включён! Буду уклоняться от выстрелов!" or "AI Helper выключен.",
            Duration=3,
            Image=4483362458,
        })
    end,
})

TabAI:CreateSlider({
    Name="Дистанция уклонения (метры)", Range={1,10}, Increment=1, CurrentValue=3, Flag="DodgeDist",
    Callback=function(v) Cfg.DodgeDist=v end,
})

TabAI:CreateSection("Что делает AI Helper:")
TabAI:CreateLabel("1. Сканирует пули рядом с тобой (12м)")
TabAI:CreateLabel("2. Если пуля летит к тебе - телепорт")
TabAI:CreateLabel("3. Детект: враг целится прямо в тебя")
TabAI:CreateLabel("4. Телепорт на случайное направление")
TabAI:CreateLabel("5. Кулдаун 0.4 сек между уклонениями")

-- TAB: ESP
local TabESP = Window:CreateTab("ESP", 4483362458)
TabESP:CreateToggle({
    Name="Enable ESP", CurrentValue=false, Flag="ESPToggle",
    Callback=function(v) Cfg.ESPEnabled=v;refreshESP() end,
})
TabESP:CreateDropdown({
    Name="ESP Mode", Options={"Highlight","Box","Tracer"},
    CurrentOption={"Highlight"}, Flag="ESPMode",
    Callback=function(o) Cfg.ESPMode=o[1];refreshESP() end,
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
        if c[o[1]] then Cfg.ESPColor=c[o[1]];refreshESP() end
    end,
})
TabESP:CreateSlider({
    Name="Transparency", Range={0,10}, Increment=1, CurrentValue=5, Flag="ESPTransp",
    Callback=function(v) Cfg.ESPTransp=v/10;refreshESP() end,
})
TabESP:CreateToggle({
    Name="Name ESP", CurrentValue=false, Flag="NameESP",
    Callback=function(v) Cfg.NameESP=v;refreshESP() end,
})
TabESP:CreateToggle({
    Name="Health Bar", CurrentValue=false, Flag="HealthBar",
    Callback=function(v) Cfg.HealthBar=v;refreshESP() end,
})

-- TAB: Aimbot
local TabAim = Window:CreateTab("Aimbot", 4483362458)
TabAim:CreateToggle({
    Name="Enable Aimbot", CurrentValue=false, Flag="AimbotToggle",
    Callback=function(v) Cfg.AimbotEnabled=v end,
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
    Name="Smoothness", Range={1,100}, Increment=1, CurrentValue=15, Flag="AimSmooth",
    Callback=function(v) Cfg.AimbotSmooth=v/100 end,
})
TabAim:CreateDropdown({
    Name="Aim Part", Options={"Head","HumanoidRootPart","UpperTorso","Torso"},
    CurrentOption={"Head"}, Flag="AimPart",
    Callback=function(o) Cfg.AimbotPart=o[1] end,
})
TabAim:CreateDropdown({
    Name="FOV Color", Options={"White","Yellow","Red","Green","Blue","Cyan"},
    CurrentOption={"White"}, Flag="FOVColor",
    Callback=function(o)
        local c={White=Color3.fromRGB(255,255,255),Yellow=Color3.fromRGB(255,255,0),
            Red=Color3.fromRGB(255,0,0),Green=Color3.fromRGB(0,255,0),
            Blue=Color3.fromRGB(0,100,255),Cyan=Color3.fromRGB(0,255,255)}
        if c[o[1]] then Cfg.FOVColor=c[o[1]] end
    end,
})

-- TAB: Movement
local TabMove = Window:CreateTab("Movement", 4483362458)
TabMove:CreateToggle({Name="Infinite Jump",CurrentValue=false,Flag="InfJump",Callback=function(v) Cfg.InfJump=v end})
TabMove:CreateToggle({Name="BunnyHop",CurrentValue=false,Flag="BHop",Callback=function(v) Cfg.BunnyHop=v end})
TabMove:CreateToggle({Name="Fly (W/A/S/D)",CurrentValue=false,Flag="Fly",Callback=function(v) Cfg.FlyEnabled=v;toggleFly(v) end})
TabMove:CreateSlider({Name="Fly Speed",Range={10,200},Increment=5,CurrentValue=50,Flag="FlySpeed",Callback=function(v) Cfg.FlySpeed=v end})
TabMove:CreateToggle({Name="Speed Hack",CurrentValue=false,Flag="Speed",Callback=function(v) Cfg.SpeedEnabled=v end})
TabMove:CreateSlider({Name="Walk Speed",Range={16,200},Increment=1,CurrentValue=40,Flag="WalkSpeed",Callback=function(v) Cfg.SpeedValue=v end})
TabMove:CreateToggle({Name="Noclip",CurrentValue=false,Flag="Noclip",Callback=function(v) Cfg.NoclipOn=v end})
TabMove:CreateToggle({Name="No Fall Damage",CurrentValue=false,Flag="NoFall",Callback=function(v) Cfg.NoFallOn=v end})

-- TAB: Misc
local TabMisc = Window:CreateTab("Misc", 4483362458)
TabMisc:CreateToggle({Name="Fullbright",CurrentValue=false,Flag="FB",Callback=function(v) setFullBright(v) end})
TabMisc:CreateToggle({Name="Anti-AFK",CurrentValue=false,Flag="AFK",Callback=function(v)
    if v then
        LP.Idled:Connect(function()
            local vu=game:GetService("VirtualUser")
            vu:Button1Down(Vector2.new(0,0),Camera.CFrame)
            task.wait(0.1)
            vu:Button1Up(Vector2.new(0,0),Camera.CFrame)
        end)
    end
end})
TabMisc:CreateButton({Name="Teleport Spawn",Callback=function()
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.CFrame=CFrame.new(0,10,0)
    end
end})
TabMisc:CreateButton({Name="Respawn",Callback=function()
    if LP.Character then local h=LP.Character:FindFirstChild("Humanoid");if h then h.Health=0 end end
end})
TabMisc:CreateButton({Name="Rejoin",Callback=function()
    game:GetService("TeleportService"):Teleport(game.PlaceId,LP)
end})

-- Startup
Rayfield:Notify({
    Title   = "Primejtsu X | AI Helper",
    Content = "Loaded! Включи AI Helper во вкладке!",
    Duration = 5,
    Image   = 4483362458,
})

print("[Primejtsu X] AI Helper Edition Loaded.")
