-- ================================================
--   Primejtsu X | Murder Mystery 2
--   Rayfield UI Edition v2.0
--   Creator: @Primejtsu
-- ================================================

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera           = workspace.CurrentCamera
local LP               = Players.LocalPlayer

-- ================================================
-- РОЛИ
-- ================================================
local RoleColors = {
    Murderer = Color3.fromRGB(255, 50,  50),
    Sheriff  = Color3.fromRGB(50,  150, 255),
    Hero     = Color3.fromRGB(50,  150, 255),
    Innocent = Color3.fromRGB(80,  255, 80),
}

local function getRole(player)
    local char = player.Character
    if not char then return "Innocent" end

    local head = char:FindFirstChild("Head")
    if head then
        for _, v in pairs(head:GetChildren()) do
            if v:IsA("BillboardGui") then
                local lbl = v:FindFirstChildOfClass("TextLabel")
                if lbl then
                    local t = lbl.Text:lower()
                    if t:find("murder") then return "Murderer" end
                    if t:find("sheriff") then return "Sheriff"  end
                    if t:find("hero")    then return "Hero"     end
                end
            end
        end
    end

    for _, v in pairs(char:GetChildren()) do
        if v:IsA("StringValue") then
            local t = v.Value:lower()
            if t == "murderer" then return "Murderer" end
            if t == "sheriff"  then return "Sheriff"  end
            if t == "hero"     then return "Hero"     end
        end
    end

    local ls = player:FindFirstChild("leaderstats")
    if ls then
        local role = ls:FindFirstChild("Role") or ls:FindFirstChild("role")
        if role then
            local t = tostring(role.Value):lower()
            if t:find("murder")  then return "Murderer" end
            if t:find("sheriff") then return "Sheriff"  end
            if t:find("hero")    then return "Hero"     end
        end
    end

    return "Innocent"
end

-- ================================================
-- CONFIG
-- ================================================
local Cfg = {
    ESPEnabled    = false,
    ShowRoles     = true,
    ShowNames     = true,
    AimbotEnabled = false,
    SilentAim     = false,
    AimbotSmooth  = 0.2,
    AimbotPart    = "Head",
    AimbotTarget  = "Murderer",
    AIHelper      = false,
    AIDistance    = 15,
    AICooldown    = 1.5,
    AutoGrabGun   = false,
    AutoFarm      = false,
    MurderHelper  = false,
    SpeedEnabled  = false,
    SpeedValue    = 30,
    FlyEnabled    = false,
    FlySpeed      = 50,
    InfJump       = false,
    Noclip        = false,
    FullBright    = false,
    AntiAFK       = false,
}

-- ================================================
-- ESP
-- ================================================
local ESPObjects = {}

local function removeESP(p)
    if not ESPObjects[p] then return end
    pcall(function() ESPObjects[p].hl:Destroy() end)
    pcall(function() ESPObjects[p].bb:Destroy() end)
    ESPObjects[p] = nil
end

local function applyESP(p)
    removeESP(p)
    if p == LP or not Cfg.ESPEnabled then return end

    local obj  = {}
    local role = getRole(p)
    local col  = RoleColors[role] or RoleColors.Innocent

    local hl = Instance.new("Highlight")
    hl.DepthMode        = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillTransparency = 0.4
    hl.FillColor        = col
    hl.OutlineColor     = col
    if p.Character then hl.Parent = p.Character end
    p.CharacterAdded:Connect(function(c)
        hl.Parent       = c
        local r         = getRole(p)
        local c2        = RoleColors[r] or RoleColors.Innocent
        hl.FillColor    = c2
        hl.OutlineColor = c2
    end)
    obj.hl = hl

    if Cfg.ShowNames or Cfg.ShowRoles then
        local bb = Instance.new("BillboardGui")
        bb.AlwaysOnTop  = true
        bb.Size         = UDim2.new(0, 130, 0, 44)
        bb.StudsOffset  = Vector3.new(0, 2.8, 0)

        local char = p.Character
        if char and char:FindFirstChild("Head") then
            bb.Adornee = char.Head
        end
        p.CharacterAdded:Connect(function(c)
            bb.Adornee = c:WaitForChild("Head")
        end)

        local fr = Instance.new("Frame", bb)
        fr.BackgroundTransparency = 1
        fr.Size = UDim2.new(1, 0, 1, 0)

        local nameLbl = Instance.new("TextLabel", fr)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Size        = UDim2.new(1, 0, 0.5, 0)
        nameLbl.Position    = UDim2.new(0, 0, 0, 0)
        nameLbl.TextColor3  = Color3.fromRGB(255, 255, 255)
        nameLbl.TextStrokeTransparency = 0
        nameLbl.TextScaled  = true
        nameLbl.Font        = Enum.Font.GothamBold
        nameLbl.Text        = p.Name
        nameLbl.Visible     = Cfg.ShowNames

        local roleLbl = Instance.new("TextLabel", fr)
        roleLbl.BackgroundTransparency = 1
        roleLbl.Size        = UDim2.new(1, 0, 0.5, 0)
        roleLbl.Position    = UDim2.new(0, 0, 0.5, 0)
        roleLbl.TextColor3  = col
        roleLbl.TextStrokeTransparency = 0
        roleLbl.TextScaled  = true
        roleLbl.Font        = Enum.Font.Gotham
        roleLbl.Text        = role
        roleLbl.Visible     = Cfg.ShowRoles

        bb.Parent   = char or workspace
        obj.bb      = bb
        obj.nameLbl = nameLbl
        obj.roleLbl = roleLbl
    end

    ESPObjects[p] = obj
end

local function refreshESP()
    for p in pairs(ESPObjects) do removeESP(p) end
    if not Cfg.ESPEnabled then return end
    for _, p in pairs(Players:GetPlayers()) do applyESP(p) end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(1)
        applyESP(p)
    end)
end)
Players.PlayerRemoving:Connect(removeESP)

-- Обновление цветов ESP по роли каждые 2 сек
task.spawn(function()
    while true do
        task.wait(2)
        if Cfg.ESPEnabled then
            for p, obj in pairs(ESPObjects) do
                if p.Character then
                    local role = getRole(p)
                    local col  = RoleColors[role] or RoleColors.Innocent
                    pcall(function()
                        obj.hl.FillColor    = col
                        obj.hl.OutlineColor = col
                        if obj.roleLbl then
                            obj.roleLbl.Text       = role
                            obj.roleLbl.TextColor3 = col
                        end
                    end)
                end
            end
        end
    end
end)

-- ================================================
-- AIMBOT TARGET
-- ================================================
local function isVisible(part)
    local origin = Camera.CFrame.Position
    local ray    = Ray.new(origin, (part.Position - origin).Unit * 500)
    local hit    = workspace:FindPartOnRayWithIgnoreList(ray, {LP.Character, workspace.Terrain})
    if hit then return hit:IsDescendantOf(part.Parent) end
    return false
end

local function getTarget()
    local best, bestD = nil, math.huge
    local cx = Camera.ViewportSize.X / 2
    local cy = Camera.ViewportSize.Y / 2

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local role  = getRole(p)
                local match = Cfg.AimbotTarget == "All"
                    or (Cfg.AimbotTarget == "Murderer" and role == "Murderer")
                    or (Cfg.AimbotTarget == "Sheriff"  and (role == "Sheriff" or role == "Hero"))

                if match then
                    local part = p.Character:FindFirstChild(Cfg.AimbotPart)
                             or p.Character:FindFirstChild("HumanoidRootPart")
                    if part then
                        local sp, vis = Camera:WorldToViewportPoint(part.Position)
                        if vis then
                            local d = math.sqrt((sp.X - cx)^2 + (sp.Y - cy)^2)
                            if d < bestD then
                                bestD = d
                                best  = {part = part, player = p, role = role}
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

-- ================================================
-- SILENT AIM
-- ================================================
local silentTarget = nil

pcall(function()
    if hookmetamethod then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" and Cfg.SilentAim and silentTarget then
                local args = {...}
                if typeof(args[1]) == "Vector3" or typeof(args[1]) == "CFrame" then
                    args[1] = silentTarget.part.Position
                end
                return oldNamecall(self, table.unpack(args))
            end
            return oldNamecall(self, ...)
        end)
    end
end)

RunService.Heartbeat:Connect(function()
    if Cfg.SilentAim then
        silentTarget = getTarget()
    end
end)

-- ================================================
-- AIMBOT LOOP
-- ================================================
RunService.RenderStepped:Connect(function()
    if Cfg.AimbotEnabled and not Cfg.SilentAim then
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
-- AI HELPER
-- ================================================
local aiLastTp = 0

local function aiTeleport(root)
    local dirs = {
        Vector3.new(1,0,0),  Vector3.new(-1,0,0),
        Vector3.new(0,0,1),  Vector3.new(0,0,-1),
        Vector3.new(1,0,1).Unit,  Vector3.new(-1,0,-1).Unit,
        Vector3.new(1,0,-1).Unit, Vector3.new(-1,0,1).Unit,
    }
    local dir    = dirs[math.random(1, #dirs)]
    root.CFrame  = CFrame.new(root.Position + dir * 8 + Vector3.new(0, 0.5, 0))
end

RunService.Heartbeat:Connect(function()
    if not Cfg.AIHelper then return end
    local char   = LP.Character
    if not char  then return end
    local myRoot = char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local now = tick()
    if now - aiLastTp < Cfg.AICooldown then return end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and getRole(p) == "Murderer" then
            local eRoot = p.Character:FindFirstChild("HumanoidRootPart")
            if eRoot then
                local dist = (eRoot.Position - myRoot.Position).Magnitude
                if dist <= Cfg.AIDistance then
                    aiLastTp = now
                    aiTeleport(myRoot)
                    Rayfield:Notify({
                        Title   = "AI Helper",
                        Content = "Уклонился от " .. p.Name,
                        Duration = 2,
                        Image    = 4483362458,
                    })
                    break
                end
            end
        end
    end
end)

-- ================================================
-- MURDER HELPER (подсветка шерифа)
-- ================================================
local sheriffHL = {}

local function updateMurderHelper()
    for _, hl in pairs(sheriffHL) do pcall(function() hl:Destroy() end) end
    sheriffHL = {}
    if not Cfg.MurderHelper then return end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local role = getRole(p)
            if role == "Sheriff" or role == "Hero" then
                local hl = Instance.new("Highlight")
                hl.FillColor        = Color3.fromRGB(255, 215, 0)
                hl.OutlineColor     = Color3.fromRGB(255, 215, 0)
                hl.FillTransparency = 0.3
                hl.DepthMode        = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent           = p.Character
                table.insert(sheriffHL, hl)
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(2)
        updateMurderHelper()
    end
end)

-- ================================================
-- AUTO GRAB GUN
-- ================================================
local function findDroppedGun()
    for _, v in pairs(workspace:GetDescendants()) do
        local n = v.Name:lower()
        if (n:find("gun") or n:find("revolver")) and v:IsA("BasePart") then
            local inChar = false
            for _, pl in pairs(Players:GetPlayers()) do
                if pl.Character and v:IsDescendantOf(pl.Character) then
                    inChar = true; break
                end
            end
            if not inChar then return v end
        end
    end
    return nil
end

RunService.Heartbeat:Connect(function()
    if not Cfg.AutoGrabGun then return end
    local char   = LP.Character
    if not char  then return end
    local myRoot = char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local gun = findDroppedGun()
    if gun and (gun.Position - myRoot.Position).Magnitude > 3 then
        myRoot.CFrame = CFrame.new(gun.Position + Vector3.new(0, 2, 0))
    end
end)

-- ================================================
-- AUTO FARM МОНЕТ
-- ================================================
local farmConn
local function startFarm()
    if farmConn then farmConn:Disconnect() end
    farmConn = RunService.Heartbeat:Connect(function()
        if not Cfg.AutoFarm then
            farmConn:Disconnect(); farmConn = nil; return
        end
        local char   = LP.Character
        local myRoot = char and char:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        for _, v in pairs(workspace:GetDescendants()) do
            local n = v.Name:lower()
            if (n:find("coin") or n:find("gold") or n:find("token")) and v:IsA("BasePart") then
                if (v.Position - myRoot.Position).Magnitude > 2 then
                    myRoot.CFrame = CFrame.new(v.Position + Vector3.new(0, 1, 0))
                end
                task.wait(0.1)
            end
        end
        task.wait(0.4)
    end)
end

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
        bp.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bp.Position = root.Position
        bp.Parent   = root
        local bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        bg.CFrame    = Camera.CFrame
        bg.Parent    = root
        flyConn = RunService.Heartbeat:Connect(function()
            if not Cfg.FlyEnabled then return end
            local cf  = Camera.CFrame
            local dir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector  end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector  end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then dir = dir + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
            bp.Position = bp.Position + dir * Cfg.FlySpeed * 0.016
            bg.CFrame   = cf
        end)
    else
        if flyConn then flyConn:Disconnect(); flyConn = nil end
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
-- MOVEMENT LOOP
-- ================================================
RunService.Heartbeat:Connect(function()
    local char = LP.Character
    if not char then return end
    local h = char:FindFirstChild("Humanoid")
    if h then
        if Cfg.SpeedEnabled then
            h.WalkSpeed = Cfg.SpeedValue
        else
            if h.WalkSpeed ~= 16 and not Cfg.FlyEnabled then h.WalkSpeed = 16 end
        end
    end
    if Cfg.Noclip then
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Cfg.InfJump and LP.Character then
        local h = LP.Character:FindFirstChild("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

LP.CharacterAdded:Connect(function()
    if Cfg.FlyEnabled then task.wait(1); toggleFly(true) end
end)

-- ================================================
-- FULLBRIGHT
-- ================================================
local Lighting = game:GetService("Lighting")
local function setFullBright(on)
    Lighting.Brightness    = on and 10 or 1
    Lighting.ClockTime     = 14
    Lighting.GlobalShadows = not on
    Lighting.Ambient       = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(127,127,127)
end

-- ================================================
-- ANTI-AFK
-- ================================================
LP.Idled:Connect(function()
    if not Cfg.AntiAFK then return end
    local vu = game:GetService("VirtualUser")
    vu:Button1Down(Vector2.new(0,0), Camera.CFrame)
    task.wait(0.1)
    vu:Button1Up(Vector2.new(0,0), Camera.CFrame)
end)

-- ================================================
-- RAYFIELD GUI
-- ================================================
local Window = Rayfield:CreateWindow({
    Name                    = "Primejtsu X | Murder Mystery 2",
    LoadingTitle            = "Primejtsu X",
    LoadingSubtitle         = "Murder Mystery 2 | v2.0",
    Theme                   = "Default",
    DisableRayfieldPrompts  = false,
    DisableBuildWarnings    = false,
    ConfigurationSaving     = { Enabled = false },
})

-- ================================================
-- TAB: ESP
-- ================================================
local TabESP = Window:CreateTab("ESP", 4483362458)

TabESP:CreateSection("Player ESP")

TabESP:CreateToggle({
    Name         = "ESP Through Walls",
    CurrentValue = false,
    Flag         = "ESPEnabled",
    Callback     = function(v) Cfg.ESPEnabled = v; refreshESP() end,
})

TabESP:CreateToggle({
    Name         = "Show Roles",
    CurrentValue = true,
    Flag         = "ShowRoles",
    Callback     = function(v) Cfg.ShowRoles = v; refreshESP() end,
})

TabESP:CreateToggle({
    Name         = "Show Names",
    CurrentValue = true,
    Flag         = "ShowNames",
    Callback     = function(v) Cfg.ShowNames = v; refreshESP() end,
})

TabESP:CreateSection("Role Colors")
TabESP:CreateLabel("Murderer  —  Red")
TabESP:CreateLabel("Sheriff / Hero  —  Blue")
TabESP:CreateLabel("Innocent  —  Green")
TabESP:CreateLabel("Sheriff (Murder Helper)  —  Gold")

-- ================================================
-- TAB: Aimbot
-- ================================================
local TabAim = Window:CreateTab("Aimbot", 4483362458)

TabAim:CreateSection("Aimbot Settings")

TabAim:CreateToggle({
    Name         = "Enable Aimbot",
    CurrentValue = false,
    Flag         = "AimbotEnabled",
    Callback     = function(v)
        Cfg.AimbotEnabled = v
        if v then Cfg.SilentAim = false end
    end,
})

TabAim:CreateToggle({
    Name         = "Silent Aim",
    CurrentValue = false,
    Flag         = "SilentAim",
    Callback     = function(v)
        Cfg.SilentAim = v
        if v then Cfg.AimbotEnabled = false end
    end,
})

TabAim:CreateDropdown({
    Name          = "Aim Target",
    Options       = {"Murderer", "Sheriff", "All"},
    CurrentOption = {"Murderer"},
    Flag          = "AimTarget",
    Callback      = function(opt) Cfg.AimbotTarget = opt[1] end,
})

TabAim:CreateDropdown({
    Name          = "Aim Part",
    Options       = {"Head", "HumanoidRootPart", "UpperTorso", "Torso"},
    CurrentOption = {"Head"},
    Flag          = "AimPart",
    Callback      = function(opt) Cfg.AimbotPart = opt[1] end,
})

TabAim:CreateSlider({
    Name         = "Smoothness",
    Range        = {1, 20},
    Increment    = 1,
    CurrentValue = 4,
    Flag         = "AimSmooth",
    Callback     = function(v) Cfg.AimbotSmooth = v / 20 end,
})

-- ================================================
-- TAB: AI Helper
-- ================================================
local TabAI = Window:CreateTab("AI Helper", 4483362458)

TabAI:CreateSection("Auto Dodge")

TabAI:CreateToggle({
    Name         = "Enable AI Helper",
    CurrentValue = false,
    Flag         = "AIHelper",
    Callback     = function(v) Cfg.AIHelper = v end,
})

TabAI:CreateSlider({
    Name         = "Detect Distance (studs)",
    Range        = {5, 40},
    Increment    = 1,
    CurrentValue = 15,
    Flag         = "AIDistance",
    Callback     = function(v) Cfg.AIDistance = v end,
})

TabAI:CreateSlider({
    Name         = "Cooldown (sec)",
    Range        = {1, 10},
    Increment    = 1,
    CurrentValue = 2,
    Flag         = "AICooldown",
    Callback     = function(v) Cfg.AICooldown = v end,
})

TabAI:CreateSection("How It Works")
TabAI:CreateLabel("Detects Murderer distance every frame")
TabAI:CreateLabel("If closer than N studs — teleports 8 studs away")
TabAI:CreateLabel("Instant reaction, no delay")
TabAI:CreateLabel("Cooldown prevents spam teleports")

-- ================================================
-- TAB: Murder Helper
-- ================================================
local TabMurder = Window:CreateTab("Murder", 4483362458)

TabMurder:CreateSection("If You Are Murderer")

TabMurder:CreateToggle({
    Name         = "Highlight Sheriff",
    CurrentValue = false,
    Flag         = "MurderHelper",
    Callback     = function(v) Cfg.MurderHelper = v; updateMurderHelper() end,
})

TabMurder:CreateButton({
    Name     = "Print Who Is Sheriff",
    Callback = function()
        local found = false
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP then
                local role = getRole(p)
                if role == "Sheriff" or role == "Hero" then
                    print("[MM2] Sheriff: " .. p.Name)
                    found = true
                end
            end
        end
        Rayfield:Notify({
            Title    = "Sheriff Check",
            Content  = found and "Check console (F9)" or "No sheriff found",
            Duration = 3,
            Image    = 4483362458,
        })
    end,
})

TabMurder:CreateButton({
    Name     = "Print Who Is Murderer",
    Callback = function()
        local found = false
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP then
                local role = getRole(p)
                if role == "Murderer" then
                    print("[MM2] Murderer: " .. p.Name)
                    found = true
                end
            end
        end
        Rayfield:Notify({
            Title    = "Murderer Check",
            Content  = found and "Check console (F9)" or "No murderer found",
            Duration = 3,
            Image    = 4483362458,
        })
    end,
})

TabMurder:CreateSection("If You Are Sheriff")

TabMurder:CreateToggle({
    Name         = "Auto Grab Gun",
    CurrentValue = false,
    Flag         = "AutoGrabGun",
    Callback     = function(v) Cfg.AutoGrabGun = v end,
})

TabMurder:CreateButton({
    Name     = "Teleport To Gun",
    Callback = function()
        local gun    = findDroppedGun()
        local char   = LP.Character
        local myRoot = char and char:FindFirstChild("HumanoidRootPart")
        if gun and myRoot then
            myRoot.CFrame = CFrame.new(gun.Position + Vector3.new(0,2,0))
            Rayfield:Notify({ Title="Teleported", Content="Jumped to gun", Duration=2, Image=4483362458 })
        else
            Rayfield:Notify({ Title="Gun Not Found", Content="No dropped gun in workspace", Duration=2, Image=4483362458 })
        end
    end,
})

-- ================================================
-- TAB: Farm
-- ================================================
local TabFarm = Window:CreateTab("Farm", 4483362458)

TabFarm:CreateSection("Coin Farm")

TabFarm:CreateToggle({
    Name         = "Auto Collect Coins",
    CurrentValue = false,
    Flag         = "AutoFarm",
    Callback     = function(v)
        Cfg.AutoFarm = v
        if v then startFarm() end
    end,
})

TabFarm:CreateButton({
    Name     = "Collect Coins Once",
    Callback = function()
        local char   = LP.Character
        local myRoot = char and char:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        local count = 0
        for _, v in pairs(workspace:GetDescendants()) do
            local n = v.Name:lower()
            if (n:find("coin") or n:find("gold") or n:find("token")) and v:IsA("BasePart") then
                myRoot.CFrame = CFrame.new(v.Position + Vector3.new(0,1,0))
                count = count + 1
                task.wait(0.12)
            end
        end
        Rayfield:Notify({
            Title   = "Farm Done",
            Content = "Collected " .. count .. " coins",
            Duration = 3,
            Image    = 4483362458,
        })
    end,
})

TabFarm:CreateSection("Teleports")

TabFarm:CreateButton({
    Name     = "Teleport To Murderer",
    Callback = function()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and getRole(p) == "Murderer" and p.Character then
                local eRoot  = p.Character:FindFirstChild("HumanoidRootPart")
                local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if eRoot and myRoot then
                    myRoot.CFrame = eRoot.CFrame + Vector3.new(3,0,0)
                    Rayfield:Notify({ Title="Teleported", Content="Jumped to Murderer: "..p.Name, Duration=2, Image=4483362458 })
                    return
                end
            end
        end
        Rayfield:Notify({ Title="Not Found", Content="Murderer not detected", Duration=2, Image=4483362458 })
    end,
})

TabFarm:CreateButton({
    Name     = "Teleport To Sheriff",
    Callback = function()
        for _, p in pairs(Players:GetPlayers()) do
            local role = getRole(p)
            if p ~= LP and (role == "Sheriff" or role == "Hero") and p.Character then
                local eRoot  = p.Character:FindFirstChild("HumanoidRootPart")
                local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if eRoot and myRoot then
                    myRoot.CFrame = eRoot.CFrame + Vector3.new(3,0,0)
                    Rayfield:Notify({ Title="Teleported", Content="Jumped to Sheriff: "..p.Name, Duration=2, Image=4483362458 })
                    return
                end
            end
        end
        Rayfield:Notify({ Title="Not Found", Content="Sheriff not detected", Duration=2, Image=4483362458 })
    end,
})

TabFarm:CreateButton({
    Name     = "Teleport To Spawn",
    Callback = function()
        local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if myRoot then myRoot.CFrame = CFrame.new(0,10,0) end
    end,
})

-- ================================================
-- TAB: Movement
-- ================================================
local TabMove = Window:CreateTab("Movement", 4483362458)

TabMove:CreateSection("Speed")

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
    CurrentValue = 30,
    Flag         = "WalkSpeed",
    Callback     = function(v) Cfg.SpeedValue = v end,
})

TabMove:CreateSection("Fly")

TabMove:CreateToggle({
    Name         = "Fly (W A S D + Space)",
    CurrentValue = false,
    Flag         = "FlyEnabled",
    Callback     = function(v) Cfg.FlyEnabled = v; toggleFly(v) end,
})

TabMove:CreateSlider({
    Name         = "Fly Speed",
    Range        = {10, 200},
    Increment    = 5,
    CurrentValue = 50,
    Flag         = "FlySpeed",
    Callback     = function(v) Cfg.FlySpeed = v end,
})

TabMove:CreateSection("Other")

TabMove:CreateToggle({
    Name         = "Infinite Jump",
    CurrentValue = false,
    Flag         = "InfJump",
    Callback     = function(v) Cfg.InfJump = v end,
})

TabMove:CreateToggle({
    Name         = "Noclip",
    CurrentValue = false,
    Flag         = "Noclip",
    Callback     = function(v) Cfg.Noclip = v end,
})

-- ================================================
-- TAB: Misc
-- ================================================
local TabMisc = Window:CreateTab("Misc", 4483362458)

TabMisc:CreateSection("Visual")

TabMisc:CreateToggle({
    Name         = "Fullbright",
    CurrentValue = false,
    Flag         = "Fullbright",
    Callback     = function(v) setFullBright(v) end,
})

TabMisc:CreateSection("Utility")

TabMisc:CreateToggle({
    Name         = "Anti-AFK",
    CurrentValue = false,
    Flag         = "AntiAFK",
    Callback     = function(v) Cfg.AntiAFK = v end,
})

TabMisc:CreateButton({
    Name     = "Print All Roles",
    Callback = function()
        for _, p in pairs(Players:GetPlayers()) do
            print("[MM2] " .. p.Name .. " = " .. getRole(p))
        end
        Rayfield:Notify({ Title="Roles Printed", Content="Check console (F9)", Duration=3, Image=4483362458 })
    end,
})

TabMisc:CreateButton({
    Name     = "Rejoin",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
    end,
})

TabMisc:CreateButton({
    Name     = "Respawn",
    Callback = function()
        if LP.Character then
            local h = LP.Character:FindFirstChild("Humanoid")
            if h then h.Health = 0 end
        end
    end,
})

-- ================================================
-- TAB: About
-- ================================================
local TabAbout = Window:CreateTab("About", 4483362458)

TabAbout:CreateSection("Primejtsu X | Murder Mystery 2")
TabAbout:CreateLabel("Version: v2.0 — Rayfield Edition")
TabAbout:CreateLabel("Creator: @Primejtsu")
TabAbout:CreateLabel("UI: Rayfield by Sirius")
TabAbout:CreateLabel("Executor: Delta and others")

TabAbout:CreateSection("Features")
TabAbout:CreateLabel("ESP — roles through walls")
TabAbout:CreateLabel("Aimbot + Silent Aim")
TabAbout:CreateLabel("AI Helper — auto dodge murderer")
TabAbout:CreateLabel("Murder Helper — see sheriff as murderer")
TabAbout:CreateLabel("Auto Grab Gun — teleport to dropped gun")
TabAbout:CreateLabel("Auto Farm coins")
TabAbout:CreateLabel("Teleport to any player")
TabAbout:CreateLabel("Fly / Speed / Noclip / InfJump")
TabAbout:CreateLabel("Fullbright / Anti-AFK")

TabAbout:CreateButton({
    Name     = "Telegram: t.me/Primejtsu",
    Callback = function()
        Rayfield:Notify({
            Title   = "Telegram",
            Content = "t.me/Primejtsu",
            Duration = 4,
            Image    = 4483362458,
        })
    end,
})

-- ================================================
-- STARTUP
-- ================================================
task.wait(0.5)
refreshESP()

Rayfield:Notify({
    Title   = "Primejtsu X MM2 v2.0",
    Content = "Loaded. Enable features in the tabs.",
    Duration = 5,
    Image    = 4483362458,
})

print("[Primejtsu X] MM2 v2.0 Rayfield Loaded | Creator: @Primejtsu")
