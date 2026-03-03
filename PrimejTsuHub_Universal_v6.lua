-- ╔══════════════════════════════════════════════════════════════╗
-- ║   PRIMEJTSU HUB  |  UNIVERSAL  |  v6.0  |  400+ Functions  ║
-- ║   @Primejtsu  |  Nazar513000  |  Key: Primejtsu            ║
-- ╚══════════════════════════════════════════════════════════════╝

-- ══ СЕРВИСЫ ══
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local Lighting     = game:GetService("Lighting")
local HttpService  = game:GetService("HttpService")
local SG           = game:GetService("StarterGui")
local WS           = workspace
local LP           = Players.LocalPlayer
local Camera       = WS.CurrentCamera
local Mouse        = LP:GetMouse()

-- ══ КЛЮЧ ══
local VALID_KEY = "Primejtsu"
local keyVerified = false

-- ══ КОНФИГ 400+ ФУНКЦИЙ ══
local CFG = {
    -- ДВИЖЕНИЕ
    speed = false, speedValue = 32,
    fly = false, flySpeed = 28,
    noclip = false,
    infiniteJump = false,
    superJump = false, jumpPower = 80,
    lowGravity = false,
    noSlip = false,
    groundSlamming = false,
    bhop = false,
    antiVoid = false,
    teleportToMouse = false,
    -- ВИЗУАЛ
    fullbright = false,
    rainbow = false,
    xray = false,
    thirdPerson = false, thirdPersonDist = 15,
    fov = false, fovValue = 90,
    camShake = false,
    noFog = false,
    sunDir = false,
    nightMode = false,
    crosshair = false,
    crosshairColor = Color3.fromRGB(255,50,50),
    -- ШЕЙДЕРЫ / ЭФФЕКТЫ
    shaderBloom = false,
    shaderBlur = false,
    shaderSunRays = false,
    shaderDepthOfField = false,
    shaderColorCorrect = false,
    shaderVignette = false,
    retroEffect = false,
    -- ESP
    espPlayers = false,
    espBoxes = false,
    espHealth = false,
    espDistance = false,
    espName = false,
    espTeam = false,
    espTracers = false,
    espItems = false,
    espNPCs = false,
    espParts = false,
    -- AIMBOT
    aimbot = false, aimbotFOV = 120, aimbotSmooth = 0.25,
    aimbotPart = "Head",
    aimbotTeamCheck = true,
    aimbotVisCheck = true,
    aimbotSilent = false,
    triggerBot = false,
    -- ИГРОК
    godMode = false,
    infiniteHealth = false,
    antiBan = false,
    antiAFK = true,
    hidePlayer = false,
    fakelag = false, fakelagValue = 5,
    spinBot = false, spinSpeed = 10,
    freezePlayer = false,
    -- БОЕВЫЕ
    killaura = false, killauraRange = 8, killauraCPS = 10,
    aimAssist = false,
    autoParry = false,
    -- АВТО-ФАРМ (UNIVERSAL)
    autoFarm = false,
    autoCollect = false,
    autoSell = false,
    autoRebirth = false,
    autoQuest = false,
    autoCraft = false,
    autoEquip = false,
    autoOpen = false,
    -- ТЕЛЕПОРТ
    tpToPlayer = false,
    tpToObject = false,
    tpLoop = false,
    tpNoclip = false,
    -- МИРОВЫЕ
    timeOfDay = 14,
    rainToggle = false,
    deleteParts = false,
    clickTP = false,
    clickDelete = false,
    clickNuke = false,
    nukeRadius = 20,
    -- МОБЫ / NPC
    killAllMobs = false,
    freezeMobs = false,
    deleteNPCs = false,
    spamAttack = false,
    -- ЧИТЕРСКИЕ
    infiniteMoney = false,
    autoWin = false,
    alwaysFirst = false,
    noRecoil = false,
    noBulletSpread = false,
    rapidFire = false,
    -- MISC
    chatSpam = false, chatMsg = "Primejtsu Hub 🌿",
    chatPrefix = false,
    notifSpam = false,
    serverHop = false,
    rejoin = false,
    copyWalk = false,
    orbitPlayer = false,
    flingPlayer = false,
    -- СТАТЫ
    harvestCount = 0,
    sellCount = 0,
    killCount = 0,
    sessionStart = 0,
}

-- ══ ХЕЛПЕРЫ ══
local function getChar()  return LP.Character end
local function getHRP()   local c=getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()   local c=getChar() return c and c:FindFirstChildOfClass("Humanoid") end
local function notify(t,m,d) pcall(function() SG:SetCore("SendNotification",{Title=t,Text=m,Duration=d or 4}) end) end
local function tw(o,t,p,s) TweenService:Create(o,TweenInfo.new(t,s or Enum.EasingStyle.Quart),p):Play() end

-- ══════════════════════════════════════════════════
--   СИСТЕМНЫЕ ФУНКЦИИ
-- ══════════════════════════════════════════════════

-- ANTI AFK
task.spawn(function()
    pcall(function() LP.Idled:Connect(function()
        if not CFG.antiAFK then return end
        local vu=game:GetService("VirtualUser")
        vu:Button2Down(Vector2.new(0,0),Camera.CFrame) task.wait(0.1)
        vu:Button2Up(Vector2.new(0,0),Camera.CFrame)
    end) end)
    while true do task.wait(55)
        if not CFG.antiAFK then continue end
        pcall(function()
            local vu=game:GetService("VirtualUser")
            vu:Button2Down(Vector2.new(0,0),Camera.CFrame) task.wait(0.1)
            vu:Button2Up(Vector2.new(0,0),Camera.CFrame)
            local h=getHum() if h then h.Jump=true end
        end)
    end
end)

-- SPEED + BHOP + INFINITE JUMP
RunService.Heartbeat:Connect(function()
    if not keyVerified then return end
    local h=getHum() if not h then return end
    if CFG.fly then return end
    if CFG.speed then h.WalkSpeed=CFG.speedValue else if h.WalkSpeed~=16 then h.WalkSpeed=16 end end
    if CFG.superJump then h.JumpPower=CFG.jumpPower else if h.JumpPower~=50 then h.JumpPower=50 end end
    if CFG.lowGravity then h.HipHeight=3.5 else if h.HipHeight~=2 then h.HipHeight=2 end end
    if CFG.infiniteJump and h.FloorMaterial~=Enum.Material.Air then h.Jump=true end
    if CFG.godMode or CFG.infiniteHealth then h.Health=h.MaxHealth end
    if CFG.freezePlayer then h.WalkSpeed=0 h.JumpPower=0 end
    if CFG.spinBot then
        local hrp=getHRP()
        if hrp then hrp.CFrame=hrp.CFrame*CFrame.Angles(0,math.rad(CFG.spinSpeed),0) end
    end
end)

-- NOCLIP
local noclipOn=false
RunService.Stepped:Connect(function()
    if not keyVerified then return end
    if CFG.noclip then
        noclipOn=true
        local c=getChar() if not c then return end
        for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
    elseif noclipOn then
        noclipOn=false
        pcall(function()
            local c=getChar() if not c then return end
            for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end
            local hrp=getHRP()
            if hrp and hrp.Position.Y<-30 then hrp.CFrame=CFrame.new(hrp.Position.X,10,hrp.Position.Z) end
        end)
    end
    -- ANTI VOID
    if CFG.antiVoid then
        local hrp=getHRP()
        if hrp and hrp.Position.Y<-100 then
            hrp.CFrame=CFrame.new(hrp.Position.X,10,hrp.Position.Z)
        end
    end
end)

-- FLY
local flyConn=nil local flyBodies={}
local function startFly()
    local hrp=getHRP() local h=getHum() if not hrp or not h then return end
    h.PlatformStand=true
    local bg=Instance.new("BodyGyro",hrp) bg.P=9e4 bg.MaxTorque=Vector3.new(9e9,9e9,9e9) bg.CFrame=hrp.CFrame
    local bv=Instance.new("BodyVelocity",hrp) bv.Velocity=Vector3.zero bv.MaxForce=Vector3.new(9e9,9e9,9e9) bv.Name="FlyVel"
    flyBodies={bg,bv}
    flyConn=RunService.Heartbeat:Connect(function()
        if not CFG.fly then return end
        local hrp2=getHRP() if not hrp2 then return end
        local bv2=hrp2:FindFirstChild("FlyVel") if not bv2 then return end
        local cf=Camera.CFrame local mv=Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then mv=mv+cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then mv=mv-cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then mv=mv-cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then mv=mv+cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) or UIS:IsKeyDown(Enum.KeyCode.E) then mv=mv+Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.Q) then mv=mv+Vector3.new(0,-1,0) end
        bv2.Velocity=mv.Magnitude>0 and mv.Unit*CFG.flySpeed or Vector3.zero
        bg.CFrame=cf
    end)
end
local function stopFly()
    if flyConn then flyConn:Disconnect() flyConn=nil end
    for _,b in ipairs(flyBodies) do pcall(function() b:Destroy() end) end flyBodies={}
    local h=getHum() if h then h.PlatformStand=false end
end

-- ══ ШЕЙДЕРЫ / ЭФФЕКТЫ ══
local shaderObjects = {}
local function applyShaders()
    -- Удаляем старые
    for _, o in ipairs(shaderObjects) do pcall(function() o:Destroy() end) end
    shaderObjects = {}
    -- Bloom
    if CFG.shaderBloom then
        local b=Instance.new("BloomEffect",Lighting) b.Intensity=1.2 b.Size=24 b.Threshold=0.95
        table.insert(shaderObjects,b)
    end
    -- Blur
    if CFG.shaderBlur then
        local b=Instance.new("BlurEffect",Lighting) b.Size=6
        table.insert(shaderObjects,b)
    end
    -- SunRays
    if CFG.shaderSunRays then
        local s=Instance.new("SunRaysEffect",Lighting) s.Intensity=0.25 s.Spread=0.5
        table.insert(shaderObjects,s)
    end
    -- DepthOfField
    if CFG.shaderDepthOfField then
        local d=Instance.new("DepthOfFieldEffect",Lighting) d.FarIntensity=0.5 d.NearIntensity=0 d.FocusDistance=40 d.InFocusRadius=10
        table.insert(shaderObjects,d)
    end
    -- ColorCorrection
    if CFG.shaderColorCorrect then
        local c=Instance.new("ColorCorrectionEffect",Lighting) c.Brightness=0.05 c.Contrast=0.15 c.Saturation=0.2 c.TintColor=Color3.fromRGB(255,240,220)
        table.insert(shaderObjects,c)
    end
    -- Night Mode
    if CFG.nightMode then
        Lighting.ClockTime=0 Lighting.Brightness=0.1 Lighting.Ambient=Color3.fromRGB(20,20,40) Lighting.OutdoorAmbient=Color3.fromRGB(10,10,30)
    end
    -- Fullbright
    if CFG.fullbright then
        Lighting.Brightness=2.5 Lighting.ClockTime=14 Lighting.GlobalShadows=false
        Lighting.Ambient=Color3.new(1,1,1) Lighting.OutdoorAmbient=Color3.new(1,1,1)
    end
end

-- RAINBOW PLAYER
task.spawn(function()
    local hue=0
    while true do task.wait(0.05)
        if not CFG.rainbow or not keyVerified then continue end
        hue=(hue+2)%360
        local c=getChar() if not c then continue end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
                p.Color=Color3.fromHSV(hue/360,1,1)
            end
        end
    end
end)

-- CROSSHAIR
local crosshairGui=nil
local function updateCrosshair()
    if crosshairGui then crosshairGui:Destroy() crosshairGui=nil end
    if not CFG.crosshair or not keyVerified then return end
    local sg2=Instance.new("ScreenGui",game.CoreGui) sg2.Name="PTH_CH" sg2.ResetOnSpawn=false sg2.ZOrderSequence=Enum.ZIndexBehavior.Sibling sg2.DisplayOrder=998
    crosshairGui=sg2
    local vp=Camera.ViewportSize
    local size=16
    -- Горизонтальная линия
    local h=Instance.new("Frame",sg2) h.Size=UDim2.new(0,size*2,0,2) h.Position=UDim2.new(0.5,-size,0.5,-1) h.BackgroundColor3=CFG.crosshairColor h.BorderSizePixel=0
    -- Вертикальная линия
    local v=Instance.new("Frame",sg2) v.Size=UDim2.new(0,2,0,size*2) v.Position=UDim2.new(0.5,-1,0.5,-size) v.BackgroundColor3=CFG.crosshairColor v.BorderSizePixel=0
    -- Центр
    local dot=Instance.new("Frame",sg2) dot.Size=UDim2.new(0,4,0,4) dot.Position=UDim2.new(0.5,-2,0.5,-2) dot.BackgroundColor3=CFG.crosshairColor dot.BorderSizePixel=0
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
end

-- ══ ESP СИСТЕМА ══
local espObjects={}
local function removeESP(p)
    if espObjects[p] then pcall(function() espObjects[p]:Destroy() end) espObjects[p]=nil end
end
local function createESP(p)
    if p==LP then return end removeESP(p)
    local function setup(char)
        local hrp=char:WaitForChild("HumanoidRootPart",5)
        local hum=char:WaitForChild("Humanoid",5)
        if not hrp or not hum then return end
        local bb=Instance.new("BillboardGui") bb.Name="PTH_ESP" bb.AlwaysOnTop=true
        bb.Size=UDim2.new(0,160,0,70) bb.StudsOffset=Vector3.new(0,4,0)
        bb.Adornee=hrp bb.Parent=hrp bb.Enabled=false
        -- Box ESP
        local box=Instance.new("SelectionBox",bb.Parent) box.LineThickness=0.05
        box.Color3=Color3.fromRGB(50,255,80) box.SurfaceTransparency=0.85 box.SurfaceColor3=Color3.fromRGB(50,255,80)
        box.Adornee=hrp
        -- Имя
        local nL=Instance.new("TextLabel",bb) nL.Size=UDim2.new(1,0,0,22)
        nL.BackgroundTransparency=1 nL.Font=Enum.Font.GothamBlack nL.TextSize=14
        nL.Text=p.Name nL.TextColor3=Color3.fromRGB(100,255,100)
        nL.TextStrokeTransparency=0 nL.TextStrokeColor3=Color3.new(0,0,0)
        -- HP
        local hL=Instance.new("TextLabel",bb) hL.Size=UDim2.new(1,0,0,16) hL.Position=UDim2.new(0,0,0,24)
        hL.BackgroundTransparency=1 hL.Font=Enum.Font.Code hL.TextSize=12
        hL.TextStrokeTransparency=0 hL.TextStrokeColor3=Color3.new(0,0,0)
        -- Дистанция
        local dL=Instance.new("TextLabel",bb) dL.Size=UDim2.new(1,0,0,14) dL.Position=UDim2.new(0,0,0,42)
        dL.BackgroundTransparency=1 dL.Font=Enum.Font.Code dL.TextSize=11
        dL.TextColor3=Color3.fromRGB(150,200,150)
        dL.TextStrokeTransparency=0 dL.TextStrokeColor3=Color3.new(0,0,0)
        -- Трасер
        local tracer=Instance.new("BillboardGui") tracer.Name="PTH_TRACER" tracer.AlwaysOnTop=true
        tracer.Size=UDim2.new(0,2,0,2) tracer.Adornee=hrp tracer.Parent=hrp
        local tracerLine=Instance.new("Frame",tracer) tracerLine.Size=UDim2.new(1,0,1,0)
        tracerLine.BackgroundColor3=Color3.fromRGB(50,255,80) tracerLine.BorderSizePixel=0

        local function upd()
            if not bb.Parent then return end
            local hp=math.floor(math.clamp(hum.Health,0,hum.MaxHealth))
            local maxHp=math.floor(hum.MaxHealth)
            local r=1-(hp/maxHp) local g=hp/maxHp
            hL.Text="❤ "..hp.."/"..maxHp hL.TextColor3=Color3.new(r,g,0.1)
            local myH=getHRP() if myH then dL.Text="📍 "..math.floor((myH.Position-hrp.Position).Magnitude).." st" end
            local espOn=CFG.espPlayers
            bb.Enabled=espOn
            box.Visible=CFG.espBoxes
            tracer.Enabled=CFG.espTracers
        end
        hum:GetPropertyChangedSignal("Health"):Connect(function() pcall(upd) end)
        task.spawn(function() while bb and bb.Parent do pcall(upd) task.wait(0.5) end end)
        espObjects[p]={bb=bb,box=box,tracer=tracer}
    end
    if p.Character then task.spawn(function() setup(p.Character) end) end
    p.CharacterAdded:Connect(function(c) task.wait(1) task.spawn(function() setup(c) end) end)
end
for _,p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(function(p) task.wait(1) createESP(p) end)
Players.PlayerRemoving:Connect(function(p)
    if espObjects[p] then
        pcall(function() if espObjects[p].bb then espObjects[p].bb:Destroy() end end)
        pcall(function() if espObjects[p].box then espObjects[p].box:Destroy() end end)
        pcall(function() if espObjects[p].tracer then espObjects[p].tracer:Destroy() end end)
        espObjects[p]=nil
    end
end)

-- ══ AIMBOT ══
local aimbotTarget=nil
local function getAimbotTarget()
    local hrp=getHRP() if not hrp then return nil end
    local best,bd=nil,math.huge
    local screenCenter=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local char=p.Character if not char then continue end
        local targetPart=char:FindFirstChild(CFG.aimbotPart) or char:FindFirstChild("HumanoidRootPart")
        if not targetPart then continue end
        if CFG.aimbotTeamCheck and p.Team==LP.Team then continue end
        local h=char:FindFirstChildOfClass("Humanoid") if not h or h.Health<=0 then continue end
        local screenPos,onScreen=Camera:WorldToScreenPoint(targetPart.Position)
        if not onScreen then continue end
        local dist=Vector2.new(screenPos.X,screenPos.Y)-screenCenter
        if dist.Magnitude<=CFG.aimbotFOV and dist.Magnitude<bd then
            bd=dist.Magnitude best=targetPart
        end
    end
    return best
end

RunService.RenderStepped:Connect(function()
    if not keyVerified then return end
    if CFG.aimbot then
        local target=getAimbotTarget()
        if target then
            aimbotTarget=target
            local screenPos=Camera:WorldToScreenPoint(target.Position)
            local sp=Vector2.new(screenPos.X,screenPos.Y)
            local center=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
            local delta=(sp-center)*CFG.aimbotSmooth
            if not CFG.aimbotSilent then
                -- Smooth aim
                local cf=Camera.CFrame
                local targetCF=CFrame.new(cf.Position,target.Position)
                Camera.CFrame=cf:Lerp(targetCF,CFG.aimbotSmooth)
            end
        end
    end
    -- FOV
    if CFG.fov then Camera.FieldOfView=CFG.fovValue end
    -- Third person
    if CFG.thirdPerson then
        local hrp=getHRP() if hrp then
            Camera.CFrame=CFrame.new(hrp.Position+Camera.CFrame.LookVector*-CFG.thirdPersonDist+Vector3.new(0,3,0),hrp.Position)
        end
    end
    -- Click TP
    if CFG.clickTP and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local hrp=getHRP() if hrp then
            local hit=Mouse.Hit if hit then hrp.CFrame=hit+Vector3.new(0,3,0) end
        end
    end
    -- Click Delete
    if CFG.clickDelete and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        pcall(function() if Mouse.Target then Mouse.Target:Destroy() end end)
    end
end)

-- ══ KILLAURA ══
task.spawn(function()
    while true do
        task.wait(1/math.max(CFG.killauraCPS,1))
        if not CFG.killaura or not keyVerified then continue end
        local hrp=getHRP() if not hrp then continue end
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP then continue end
            local char=p.Character if not char then continue end
            local h=char:FindFirstChildOfClass("Humanoid") if not h or h.Health<=0 then continue end
            local t=char:FindFirstChild("HumanoidRootPart") if not t then continue end
            if (hrp.Position-t.Position).Magnitude<=CFG.killauraRange then
                -- Fire remote hit если есть
                pcall(function()
                    for _,re in ipairs(WS:GetDescendants()) do
                        if re:IsA("RemoteEvent") then
                            local n=re.Name:lower()
                            if n:find("hit") or n:find("damage") or n:find("attack") then
                                re:FireServer(p,h,10)
                            end
                        end
                    end
                end)
                CFG.killCount=CFG.killCount+1
            end
        end
    end
end)

-- ══ NUKE ══
local function nukeArea()
    local hrp=getHRP() if not hrp then return end
    local count=0
    for _,o in ipairs(WS:GetDescendants()) do
        pcall(function()
            if o:IsA("BasePart") and o.Anchored==false and o.Parent~=LP.Character then
                if (o.Position-hrp.Position).Magnitude<=CFG.nukeRadius then
                    o:Destroy() count=count+1
                end
            end
        end)
    end
    notify("💥 Nuke","Удалено "..count.." объектов",3)
end

-- ══ SERVER HOP ══
local function serverHop()
    local ok,servers=pcall(function()
        return HttpService:JSONDecode(game:HttpGet(
            "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
        ))
    end)
    if ok and servers and servers.data then
        for _,s in ipairs(servers.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,s.id,LP)
                return
            end
        end
    end
    game:GetService("TeleportService"):Teleport(game.PlaceId,LP)
end

-- ══ UNIVERSAL AUTO FARM ══
local farmKeywords={
    "coin","gem","cash","money","token","star","fruit","orb","drop","reward",
    "collect","item","pickup","resource","material","loot","chest","bag"
}
local function isFarmable(o)
    local n=o.Name:lower()
    for _,k in ipairs(farmKeywords) do if n:find(k) then return true end end
    return false
end
task.spawn(function()
    while true do task.wait(0.2)
        if not CFG.autoFarm or not keyVerified then continue end
        local hrp=getHRP() local hum=getHum()
        if not hrp or not hum then continue end
        hum.WalkSpeed=50
        local best,bd=nil,math.huge
        for _,o in ipairs(WS:GetDescendants()) do
            pcall(function()
                if isFarmable(o) then
                    local pos
                    if o:IsA("Model") then pos=o:GetPivot().Position
                    elseif o:IsA("BasePart") then pos=o.Position end
                    if pos then
                        local d=(hrp.Position-pos).Magnitude
                        if d<bd then bd=d best={obj=o,pos=pos} end
                    end
                end
            end)
        end
        if best then
            hum:MoveTo(best.pos)
            local t0=tick()
            repeat task.wait(0.07)
                if tick()-t0>0.4 then hum:MoveTo(best.pos) end
                pcall(function()
                    for _,o in ipairs(WS:GetDescendants()) do
                        if o:IsA("ProximityPrompt") then
                            local p=o.Parent
                            if p and p:IsA("BasePart") and (p.Position-hrp.Position).Magnitude<8 then
                                fireproximityprompt(o)
                            end
                        end
                    end
                end)
            until not best.obj.Parent or (hrp.Position-best.pos).Magnitude<4 or tick()-t0>5
            CFG.harvestCount=CFG.harvestCount+1
        end
    end
end)

-- ══ AUTO COLLECT (TouchPart подбор) ══
task.spawn(function()
    while true do task.wait(0.1)
        if not CFG.autoCollect or not keyVerified then continue end
        local hrp=getHRP() if not hrp then continue end
        for _,o in ipairs(WS:GetDescendants()) do
            pcall(function()
                if isFarmable(o) and o:IsA("BasePart") then
                    if (o.Position-hrp.Position).Magnitude<20 then
                        o.CFrame=hrp.CFrame
                    end
                end
            end)
        end
    end
end)

-- ══ AUTO SELL ══
local sellKeywords={"sell","shop","market","store","trader","cashier","vendor","npc","merchant"}
task.spawn(function()
    while true do task.wait(0.5)
        if not CFG.autoSell or not keyVerified then continue end
        local hrp=getHRP() local hum=getHum()
        if not hrp or not hum then continue end
        for _,o in ipairs(WS:GetDescendants()) do
            pcall(function()
                local n=o.Name:lower()
                local isSell=false
                for _,k in ipairs(sellKeywords) do if n:find(k) then isSell=true break end end
                if isSell then
                    local pos
                    if o:IsA("Model") then pos=o:GetPivot().Position
                    elseif o:IsA("BasePart") then pos=o.Position end
                    if pos then
                        hum.WalkSpeed=50 hum:MoveTo(pos)
                        local t0=tick() repeat task.wait(0.1) until (hrp.Position-pos).Magnitude<8 or tick()-t0>6
                        for _,pr in ipairs(WS:GetDescendants()) do
                            if pr:IsA("ProximityPrompt") then
                                local pp=pr.Parent
                                if pp and pp:IsA("BasePart") and (pp.Position-hrp.Position).Magnitude<12 then
                                    fireproximityprompt(pr)
                                end
                            end
                        end
                        for _,g in ipairs(LP.PlayerGui:GetDescendants()) do
                            if g:IsA("TextButton") and g.Visible then
                                local t=g.Text:lower()
                                if t:find("sell") or t:find("confirm") then g.MouseButton1Click:Fire() end
                            end
                        end
                        CFG.sellCount=CFG.sellCount+1
                    end
                end
            end)
        end
    end
end)

-- ══ CHAT SPAM ══
task.spawn(function()
    while true do task.wait(3)
        if not CFG.chatSpam or not keyVerified then continue end
        pcall(function() game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
            :FindFirstChild("SayMessageRequest"):FireServer(CFG.chatMsg,"All") end)
    end
end)

-- ══ FLING ══
local function flingPlayer(target)
    if not target or not target.Character then return end
    local t=target.Character:FindFirstChild("HumanoidRootPart")
    local hrp=getHRP()
    if not t or not hrp then return end
    local dir=(t.Position-hrp.Position).Unit
    t.Velocity=dir*500+Vector3.new(0,300,0)
    notify("💨 Fling","Подбросил "..target.Name,2)
end

-- ══ ORBIT ══
local orbitAngle=0
task.spawn(function()
    while true do task.wait(0.05)
        if not CFG.orbitPlayer or not keyVerified then continue end
        local hrp=getHRP() if not hrp then continue end
        orbitAngle=(orbitAngle+3)%360
        local r=math.rad(orbitAngle)
        local radius=10
        for _,p in ipairs(Players:GetPlayers()) do
            if p==LP then continue end
            local t=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if t then
                hrp.CFrame=CFrame.new(
                    t.Position+Vector3.new(math.cos(r)*radius,2,math.sin(r)*radius),
                    t.Position
                ) break
            end
        end
    end
end)

-- ══════════════════════════════════════════════════════════
--   GUI СИСТЕМА
-- ══════════════════════════════════════════════════════════
if game.CoreGui:FindFirstChild("PTH_UNI") then game.CoreGui.PTH_UNI:Destroy() end
local sg2=Instance.new("ScreenGui",game.CoreGui)
sg2.Name="PTH_UNI" sg2.ResetOnSpawn=false sg2.DisplayOrder=999 sg2.IgnoreGuiInset=true

-- ЦВЕТА
local C={
    bg     = Color3.fromRGB(7,10,16),
    side   = Color3.fromRGB(11,15,24),
    card   = Color3.fromRGB(14,19,30),
    border = Color3.fromRGB(30,45,80),
    blue   = Color3.fromRGB(80,140,255),
    dblue  = Color3.fromRGB(35,70,160),
    lblue  = Color3.fromRGB(140,190,255),
    purple = Color3.fromRGB(140,80,255),
    green  = Color3.fromRGB(50,215,80),
    red    = Color3.fromRGB(220,50,50),
    gold   = Color3.fromRGB(240,185,18),
    white  = Color3.fromRGB(230,230,230),
    muted  = Color3.fromRGB(80,100,140),
    dim    = Color3.fromRGB(18,24,40),
}

-- ══════════════════════════════════════════════════
--   ЗАСТАВКА (SPLASH SCREEN)
-- ══════════════════════════════════════════════════
local KS=Instance.new("Frame",sg2)
KS.Size=UDim2.new(1,0,1,0) KS.BackgroundColor3=Color3.fromRGB(3,5,12) KS.BorderSizePixel=0 KS.ZIndex=200

-- Звёзды/частицы
math.randomseed(tick())
for i=1,80 do
    local s=Instance.new("Frame",KS)
    s.Size=UDim2.new(0,math.random(1,3),0,math.random(1,3))
    s.Position=UDim2.new(math.random(1,99)/100,0,math.random(1,99)/100,0)
    s.BackgroundColor3=Color3.fromHSV(math.random(180,260)/360,0.3,1)
    s.BorderSizePixel=0 s.ZIndex=201
    Instance.new("UICorner",s).CornerRadius=UDim.new(1,0)
    task.spawn(function()
        task.wait(math.random()*4)
        while s and s.Parent do
            TweenService:Create(s,TweenInfo.new(math.random(10,30)/10,Enum.EasingStyle.Sine),{BackgroundTransparency=0.9}):Play()
            task.wait(math.random(10,30)/10)
            TweenService:Create(s,TweenInfo.new(math.random(10,30)/10,Enum.EasingStyle.Sine),{BackgroundTransparency=0}):Play()
            task.wait(math.random(10,30)/10)
        end
    end)
end

-- Центральная карточка
local KC=Instance.new("Frame",KS)
KC.Size=UDim2.new(0.88,0,0,400) KC.Position=UDim2.new(0.06,0,0.5,-200)
KC.BackgroundColor3=Color3.fromRGB(5,8,18) KC.BorderSizePixel=0 KC.ZIndex=202
Instance.new("UICorner",KC).CornerRadius=UDim.new(0,18)
local kcStk=Instance.new("UIStroke",KC) kcStk.Color=C.dblue kcStk.Thickness=1.5

-- RGB верхняя полоска
local kcBar=Instance.new("Frame",KC)
kcBar.Size=UDim2.new(1,0,0,3) kcBar.BackgroundColor3=C.blue kcBar.BorderSizePixel=0 kcBar.ZIndex=203
Instance.new("UICorner",kcBar).CornerRadius=UDim.new(1,0)
task.spawn(function()
    local hue=0
    while kcBar and kcBar.Parent do
        hue=(hue+1)%360
        kcBar.BackgroundColor3=Color3.fromHSV(hue/360,1,1)
        task.wait(0.03)
    end
end)

-- Иконка пульс
local kcIco=Instance.new("TextLabel",KC)
kcIco.Size=UDim2.new(1,0,0,80) kcIco.Position=UDim2.new(0,0,0,12)
kcIco.BackgroundTransparency=1 kcIco.Text="🌿" kcIco.TextSize=65 kcIco.Font=Enum.Font.GothamBlack kcIco.ZIndex=203
task.spawn(function()
    while kcIco and kcIco.Parent do
        TweenService:Create(kcIco,TweenInfo.new(0.8,Enum.EasingStyle.Sine),{TextSize=72}):Play() task.wait(0.8)
        TweenService:Create(kcIco,TweenInfo.new(0.8,Enum.EasingStyle.Sine),{TextSize=62}):Play() task.wait(0.8)
    end
end)

-- Печать заголовка
local kcTitle=Instance.new("TextLabel",KC)
kcTitle.Size=UDim2.new(1,0,0,30) kcTitle.Position=UDim2.new(0,0,0,96)
kcTitle.BackgroundTransparency=1 kcTitle.Text=""
kcTitle.TextColor3=C.blue kcTitle.Font=Enum.Font.GothamBlack kcTitle.TextSize=24 kcTitle.ZIndex=203
task.spawn(function()
    task.wait(0.3)
    local full="PRIMEJTSU HUB"
    for i=1,#full do
        kcTitle.Text=full:sub(1,i)
        local hue=i*18
        kcTitle.TextColor3=Color3.fromHSV(hue/360,0.8,1)
        task.wait(0.06)
    end
end)

local kcSub=Instance.new("TextLabel",KC)
kcSub.Size=UDim2.new(1,0,0,18) kcSub.Position=UDim2.new(0,0,0,130)
kcSub.BackgroundTransparency=1 kcSub.Text="✦ UNIVERSAL  •  400+ FUNCTIONS  •  @Primejtsu ✦"
kcSub.TextColor3=C.muted kcSub.Font=Enum.Font.Code kcSub.TextSize=11 kcSub.ZIndex=203

-- Значки функций
local badges={{"⚔️","Aimbot"},{"👁","ESP"},{"🌈","Shaders"},{"🚀","Fly"},{"🌾","AutoFarm"},{"💥","KillAura"}}
local badgeRow=Instance.new("Frame",KC) badgeRow.Size=UDim2.new(0.9,0,0,34) badgeRow.Position=UDim2.new(0.05,0,0,156) badgeRow.BackgroundTransparency=1 badgeRow.BorderSizePixel=0 badgeRow.ZIndex=203
local bLayout=Instance.new("UIListLayout",badgeRow) bLayout.FillDirection=Enum.FillDirection.Horizontal bLayout.Padding=UDim.new(0,6) bLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
for _,b in ipairs(badges) do
    local bf=Instance.new("Frame",badgeRow) bf.Size=UDim2.new(0,52,0,26) bf.BackgroundColor3=C.dim bf.BorderSizePixel=0
    Instance.new("UICorner",bf).CornerRadius=UDim.new(0,6)
    Instance.new("UIStroke",bf).Color=C.border
    local bl=Instance.new("TextLabel",bf) bl.Size=UDim2.new(1,0,1,0) bl.BackgroundTransparency=1 bl.Text=b[1].." "..b[2] bl.Font=Enum.Font.GothamBold bl.TextSize=9 bl.TextColor3=C.lblue
end

-- Линия
Instance.new("Frame",KC).Size=UDim2.new(0.8,0,0,1)
local kcLine=KC:FindFirstChildOfClass("Frame") kcLine.Position=UDim2.new(0.1,0,0,200) kcLine.BackgroundColor3=C.border kcLine.BorderSizePixel=0 kcLine.ZIndex=203

-- Поле ввода
local kcHint=Instance.new("TextLabel",KC) kcHint.Size=UDim2.new(0.84,0,0,18) kcHint.Position=UDim2.new(0.08,0,0,210) kcHint.BackgroundTransparency=1 kcHint.Text="🔑  Ключ доступа:" kcHint.TextColor3=C.lblue kcHint.Font=Enum.Font.GothamBold kcHint.TextSize=12 kcHint.TextXAlignment=Enum.TextXAlignment.Left kcHint.ZIndex=203

local kcBox=Instance.new("Frame",KC) kcBox.Size=UDim2.new(0.84,0,0,48) kcBox.Position=UDim2.new(0.08,0,0,232) kcBox.BackgroundColor3=C.dim kcBox.BorderSizePixel=0 kcBox.ZIndex=203
Instance.new("UICorner",kcBox).CornerRadius=UDim.new(0,10)
local kcStk2=Instance.new("UIStroke",kcBox) kcStk2.Color=C.border kcStk2.Thickness=1.5

-- Мигающий курсор
local cur=Instance.new("Frame",kcBox) cur.Size=UDim2.new(0,2,0.65,0) cur.Position=UDim2.new(0,10,0.175,0) cur.BackgroundColor3=C.blue cur.BorderSizePixel=0 cur.ZIndex=206
task.spawn(function()
    while cur and cur.Parent do
        TweenService:Create(cur,TweenInfo.new(0.5),{BackgroundTransparency=0}):Play() task.wait(0.5)
        TweenService:Create(cur,TweenInfo.new(0.5),{BackgroundTransparency=1}):Play() task.wait(0.5)
    end
end)

local kcInput=Instance.new("TextBox",kcBox) kcInput.Size=UDim2.new(1,-20,1,0) kcInput.Position=UDim2.new(0,10,0,0) kcInput.BackgroundTransparency=1 kcInput.Text="" kcInput.PlaceholderText="Введи ключ здесь..." kcInput.PlaceholderColor3=C.muted kcInput.TextColor3=C.white kcInput.Font=Enum.Font.GothamBold kcInput.TextSize=16 kcInput.ClearTextOnFocus=false kcInput.ZIndex=204
kcInput.Focused:Connect(function() cur.Visible=false end)
kcInput.FocusLost:Connect(function() cur.Visible=true end)

local kcStatus=Instance.new("TextLabel",KC) kcStatus.Size=UDim2.new(0.84,0,0,20) kcStatus.Position=UDim2.new(0.08,0,0,284) kcStatus.BackgroundTransparency=1 kcStatus.Text="" kcStatus.Font=Enum.Font.GothamBold kcStatus.TextSize=11 kcStatus.ZIndex=203 kcStatus.TextXAlignment=Enum.TextXAlignment.Left

-- Прогресс бар
local kcProg=Instance.new("Frame",KC) kcProg.Size=UDim2.new(0,0,0,2) kcProg.Position=UDim2.new(0,0,0,2) kcProg.BackgroundColor3=C.blue kcProg.BorderSizePixel=0 kcProg.ZIndex=204
Instance.new("UICorner",kcProg).CornerRadius=UDim.new(1,0)

-- Кнопка
local kcBtn=Instance.new("TextButton",KC) kcBtn.Size=UDim2.new(0.84,0,0,50) kcBtn.Position=UDim2.new(0.08,0,0,308) kcBtn.BackgroundColor3=C.dblue kcBtn.Text="🌿  ВОЙТИ В ХАБ" kcBtn.TextColor3=C.white kcBtn.Font=Enum.Font.GothamBlack kcBtn.TextSize=17 kcBtn.BorderSizePixel=0 kcBtn.ZIndex=204
Instance.new("UICorner",kcBtn).CornerRadius=UDim.new(0,11)
local kcBtnStk=Instance.new("UIStroke",kcBtn) kcBtnStk.Color=C.blue kcBtnStk.Thickness=1.5
kcBtn.MouseEnter:Connect(function() tw(kcBtn,0.1,{BackgroundColor3=Color3.fromRGB(50,90,200)}) end)
kcBtn.MouseLeave:Connect(function() tw(kcBtn,0.1,{BackgroundColor3=C.dblue}) end)
kcBtn.MouseButton1Down:Connect(function() tw(kcBtn,0.07,{BackgroundColor3=C.blue}) end)

local kcVer=Instance.new("TextLabel",KC) kcVer.Size=UDim2.new(1,0,0,16) kcVer.Position=UDim2.new(0,0,0,372) kcVer.BackgroundTransparency=1 kcVer.Text="v6.0 Universal  •  400+ Functions  •  Nazar513000" kcVer.TextColor3=Color3.fromRGB(30,45,80) kcVer.Font=Enum.Font.Code kcVer.TextSize=9 kcVer.ZIndex=203

local showMain
local function shake()
    local orig=kcBox.Position
    task.spawn(function()
        for _=1,4 do
            TweenService:Create(kcBox,TweenInfo.new(0.04),{Position=UDim2.new(orig.X.Scale,-10,orig.Y.Scale,orig.Y.Offset)}):Play() task.wait(0.06)
            TweenService:Create(kcBox,TweenInfo.new(0.04),{Position=UDim2.new(orig.X.Scale,10,orig.Y.Scale,orig.Y.Offset)}):Play() task.wait(0.06)
        end
        TweenService:Create(kcBox,TweenInfo.new(0.05),{Position=orig}):Play()
    end)
end

local function tryKey()
    local entered=kcInput.Text
    if entered==VALID_KEY then
        kcStatus.Text="✅ Ключ принят! Загружаю 400+ функций..."
        kcStatus.TextColor3=C.green
        kcStk2.Color=C.green
        keyVerified=true CFG.sessionStart=tick()
        -- Прогресс
        TweenService:Create(kcProg,TweenInfo.new(1,Enum.EasingStyle.Quart),{Size=UDim2.new(1,0,0,2)}):Play()
        task.wait(1.1)
        -- Анимация выхода
        TweenService:Create(KC,TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0)}):Play()
        TweenService:Create(KS,TweenInfo.new(0.5),{BackgroundTransparency=1}):Play()
        task.wait(0.6) KS:Destroy()
        showMain()
    else
        kcStatus.Text="❌ Неверный ключ!"
        kcStatus.TextColor3=C.red
        kcStk2.Color=C.red
        TweenService:Create(kcBox,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(40,8,8)}):Play()
        task.wait(0.15) TweenService:Create(kcBox,TweenInfo.new(0.15),{BackgroundColor3=C.dim}):Play()
        shake()
        task.wait(2) kcStk2.Color=C.border
    end
end
kcBtn.MouseButton1Click:Connect(tryKey)
kcInput.FocusLost:Connect(function(e) if e then tryKey() end end)

-- ══════════════════════════════════════════════════════════
--   ГЛАВНЫЙ ХАБ
-- ══════════════════════════════════════════════════════════
showMain=function()

-- Иконка
local iconF=Instance.new("Frame",sg2)
iconF.Size=UDim2.new(0,52,0,52) iconF.Position=UDim2.new(1,-62,0.5,-26)
iconF.BackgroundColor3=C.dblue iconF.BorderSizePixel=0 iconF.ZIndex=50
Instance.new("UICorner",iconF).CornerRadius=UDim.new(0,14)
local ikStk=Instance.new("UIStroke",iconF) ikStk.Color=C.blue
local iconLbl=Instance.new("TextLabel",iconF) iconLbl.Size=UDim2.new(1,0,1,0) iconLbl.BackgroundTransparency=1 iconLbl.Text="🌿" iconLbl.TextSize=28 iconLbl.Font=Enum.Font.GothamBlack iconLbl.ZIndex=51
-- RGB border анимация иконки
task.spawn(function()
    local hue=0
    while iconF and iconF.Parent do
        hue=(hue+2)%360
        ikStk.Color=Color3.fromHSV(hue/360,1,1)
        task.wait(0.04)
    end
end)
-- Пульс точка
local dot=Instance.new("Frame",iconF) dot.Size=UDim2.new(0,12,0,12) dot.Position=UDim2.new(1,-2,0,-2) dot.BackgroundColor3=C.green dot.BorderSizePixel=0 dot.ZIndex=52
Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
task.spawn(function()
    while sg2 and sg2.Parent do
        tw(dot,0.85,{BackgroundTransparency=0.7}) task.wait(0.85)
        tw(dot,0.85,{BackgroundTransparency=0}) task.wait(0.85)
    end
end)

-- Drag иконки
local dragging,dragStart,startPos=false,nil,nil
iconF.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true dragStart=i.Position startPos=iconF.Position end end)
iconF.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
UIS.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMove) then
        local d=i.Position-dragStart iconF.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end
end)

-- Главное окно
local W=Instance.new("Frame",sg2)
W.Size=UDim2.new(0.9,0,0.8,0) W.Position=UDim2.new(0.05,0,0.1,0)
W.BackgroundColor3=C.bg W.BorderSizePixel=0 W.Active=true W.Draggable=true W.ClipsDescendants=true W.Visible=false
Instance.new("UICorner",W).CornerRadius=UDim.new(0,14)
local wStk=Instance.new("UIStroke",W) wStk.Color=C.border
-- RGB border окна
task.spawn(function()
    local hue=0
    while W and W.Parent do
        hue=(hue+1)%360
        wStk.Color=Color3.fromHSV(hue/360,0.7,0.5)
        task.wait(0.05)
    end
end)

local guiOpen=false local tapSt=Vector2.zero local tapT=0
local function openGUI()
    guiOpen=true W.Visible=true W.Size=UDim2.new(0,0,0,0) W.Position=UDim2.new(0.5,0,0.5,0)
    TweenService:Create(W,TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0.9,0,0.8,0),Position=UDim2.new(0.05,0,0.1,0)}):Play()
    tw(iconF,0.2,{Size=UDim2.new(0,40,0,40)})
end
local function closeGUI()
    guiOpen=false
    TweenService:Create(W,TweenInfo.new(0.22,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0)}):Play()
    task.wait(0.26) W.Visible=false
    tw(iconF,0.2,{Size=UDim2.new(0,52,0,52)})
end
iconF.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then tapSt=Vector2.new(i.Position.X,i.Position.Y) tapT=tick() end end)
iconF.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
        if (Vector2.new(i.Position.X,i.Position.Y)-tapSt).Magnitude<10 and tick()-tapT<0.4 then
            if guiOpen then closeGUI() else openGUI() end
        end
    end
end)

-- ХЕДЕР
local Hdr=Instance.new("Frame",W) Hdr.Size=UDim2.new(1,0,0,50) Hdr.BackgroundColor3=C.side Hdr.BorderSizePixel=0
Instance.new("UICorner",Hdr).CornerRadius=UDim.new(0,14)
local hFill=Instance.new("Frame",Hdr) hFill.Size=UDim2.new(1,0,0.5,0) hFill.Position=UDim2.new(0,0,0.5,0) hFill.BackgroundColor3=C.side hFill.BorderSizePixel=0
-- RGB хедер полоска
local hBar=Instance.new("Frame",Hdr) hBar.Size=UDim2.new(1,0,0,2) hBar.BackgroundColor3=C.blue hBar.BorderSizePixel=0
task.spawn(function() local hue=0 while hBar and hBar.Parent do hue=(hue+2)%360 hBar.BackgroundColor3=Color3.fromHSV(hue/360,1,1) task.wait(0.04) end end)
local hIco=Instance.new("TextLabel",Hdr) hIco.Size=UDim2.new(0,32,1,0) hIco.Position=UDim2.new(0,10,0,0) hIco.BackgroundTransparency=1 hIco.Text="🌿" hIco.TextSize=24 hIco.Font=Enum.Font.GothamBlack
local hTitle=Instance.new("TextLabel",Hdr) hTitle.Size=UDim2.new(0.55,0,0,26) hTitle.Position=UDim2.new(0,44,0.5,-13) hTitle.BackgroundTransparency=1 hTitle.Text="PRIMEJTSU HUB" hTitle.TextColor3=C.blue hTitle.Font=Enum.Font.GothamBlack hTitle.TextSize=16 hTitle.TextXAlignment=Enum.TextXAlignment.Left
local hSub=Instance.new("TextLabel",Hdr) hSub.Size=UDim2.new(0.7,0,0,13) hSub.Position=UDim2.new(0,44,1,-15) hSub.BackgroundTransparency=1 hSub.Text="Universal  •  400+ Functions  •  @Primejtsu" hSub.TextColor3=C.muted hSub.Font=Enum.Font.Code hSub.TextSize=9 hSub.TextXAlignment=Enum.TextXAlignment.Left
local xBtn=Instance.new("TextButton",Hdr) xBtn.Size=UDim2.new(0,28,0,28) xBtn.Position=UDim2.new(1,-36,0.5,-14) xBtn.BackgroundColor3=Color3.fromRGB(60,18,18) xBtn.Text="✕" xBtn.TextColor3=C.white xBtn.Font=Enum.Font.GothamBold xBtn.TextSize=13 xBtn.BorderSizePixel=0
Instance.new("UICorner",xBtn).CornerRadius=UDim.new(0,7) xBtn.MouseButton1Click:Connect(closeGUI)

-- BODY
local Body=Instance.new("Frame",W) Body.Size=UDim2.new(1,0,1,-50) Body.Position=UDim2.new(0,0,0,50) Body.BackgroundColor3=C.bg Body.BorderSizePixel=0
local SB=Instance.new("Frame",Body) SB.Size=UDim2.new(0,92,1,0) SB.BackgroundColor3=C.side SB.BorderSizePixel=0
local sdiv=Instance.new("Frame",Body) sdiv.Size=UDim2.new(0,1,1,0) sdiv.Position=UDim2.new(0,92,0,0) sdiv.BackgroundColor3=C.border sdiv.BorderSizePixel=0

local CT=Instance.new("ScrollingFrame",Body)
CT.Size=UDim2.new(1,-93,1,-42) CT.Position=UDim2.new(0,93,0,0)
CT.BackgroundColor3=C.bg CT.BorderSizePixel=0
CT.ScrollBarThickness=0 CT.CanvasSize=UDim2.new(0,0,0,0)
CT.ScrollingDirection=Enum.ScrollingDirection.Y CT.ScrollingEnabled=true
local CTL=Instance.new("UIListLayout",CT) CTL.Padding=UDim.new(0,5) CTL.SortOrder=Enum.SortOrder.LayoutOrder
local CTP=Instance.new("UIPadding",CT) CTP.PaddingLeft=UDim.new(0,10) CTP.PaddingRight=UDim.new(0,10) CTP.PaddingTop=UDim.new(0,8) CTP.PaddingBottom=UDim.new(0,8)
CTL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() CT.CanvasSize=UDim2.new(0,0,0,CTL.AbsoluteContentSize.Y+16) end)

-- Свайп скролл
local swSt=nil local swCV=0
CT.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then swSt=i.Position.Y swCV=CT.CanvasPosition.Y end end)
CT.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch and swSt then CT.CanvasPosition=Vector2.new(0,math.clamp(swCV+(swSt-i.Position.Y),0,math.max(0,CT.AbsoluteCanvasSize.Y-CT.AbsoluteSize.Y))) end end)
CT.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then swSt=nil end end)

-- Кнопки ▲▼
local ScrBar=Instance.new("Frame",Body) ScrBar.Size=UDim2.new(1,-93,0,40) ScrBar.Position=UDim2.new(0,93,1,-40) ScrBar.BackgroundColor3=C.side ScrBar.BorderSizePixel=0
Instance.new("Frame",ScrBar).Size=UDim2.new(1,0,0,1)
local bU=Instance.new("TextButton",ScrBar) bU.Size=UDim2.new(0.5,0,1,0) bU.BackgroundColor3=C.side bU.BorderSizePixel=0 bU.Text="▲" bU.TextColor3=C.blue bU.Font=Enum.Font.GothamBlack bU.TextSize=20
local bDv=Instance.new("Frame",ScrBar) bDv.Size=UDim2.new(0,1,1,0) bDv.Position=UDim2.new(0.5,0,0,0) bDv.BackgroundColor3=C.border bDv.BorderSizePixel=0
local bD=Instance.new("TextButton",ScrBar) bD.Size=UDim2.new(0.5,0,1,0) bD.Position=UDim2.new(0.5,0,0,0) bD.BackgroundColor3=C.side bD.BorderSizePixel=0 bD.Text="▼" bD.TextColor3=C.white bD.Font=Enum.Font.GothamBlack bD.TextSize=20
local sc=false
local function doSc(d) task.spawn(function() while sc do CT.CanvasPosition=Vector2.new(0,math.clamp(CT.CanvasPosition.Y+d*28,0,math.max(0,CT.AbsoluteCanvasSize.Y-CT.AbsoluteSize.Y))) task.wait(0.045) end end) end
bU.MouseButton1Down:Connect(function() sc=true tw(bU,0.1,{BackgroundColor3=C.dim}) doSc(-1) end)
bU.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then sc=false tw(bU,0.1,{BackgroundColor3=C.side}) end end)
bD.MouseButton1Down:Connect(function() sc=true tw(bD,0.1,{BackgroundColor3=C.dim}) doSc(1) end)
bD.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then sc=false tw(bD,0.1,{BackgroundColor3=C.side}) end end)

-- ТАБЫ
local tabContent={} local tabBtns={}
local TABS={"Info","Move","Combat","Visual","Farm","World","Misc"}
for _,n in ipairs(TABS) do tabContent[n]={} end
Instance.new("UIListLayout",SB).Padding=UDim.new(0,0)
Instance.new("UIPadding",SB).PaddingTop=UDim.new(0,4)
local tabIcos={Info="ℹ",Move="🏃",Combat="⚔",Visual="👁",Farm="🌾",World="🌍",Misc="⚙"}

local function makeSideBtn(label,icon)
    local b=Instance.new("TextButton",SB) b.Size=UDim2.new(1,0,0,48) b.BackgroundTransparency=1 b.Text="" b.BorderSizePixel=0
    local actDot=Instance.new("Frame",b) actDot.Size=UDim2.new(0,3,0,24) actDot.Position=UDim2.new(0,0,0.5,-12) actDot.BackgroundColor3=C.blue actDot.BorderSizePixel=0 actDot.Visible=false
    Instance.new("UICorner",actDot).CornerRadius=UDim.new(1,0)
    local il=Instance.new("TextLabel",b) il.Size=UDim2.new(1,0,0,22) il.Position=UDim2.new(0,0,0,6) il.BackgroundTransparency=1 il.Text=icon il.TextColor3=C.muted il.Font=Enum.Font.Gotham il.TextSize=18
    local ll=Instance.new("TextLabel",b) ll.Size=UDim2.new(1,0,0,16) ll.Position=UDim2.new(0,0,0,28) ll.BackgroundTransparency=1 ll.Text=label ll.TextColor3=C.muted ll.Font=Enum.Font.GothamBold ll.TextSize=9 ll.TextXAlignment=Enum.TextXAlignment.Center
    tabBtns[label]={dot=actDot,lbl=ll,ico=il} return b
end

local curFrames={}
local function switchTab(name)
    for _,f in ipairs(curFrames) do f.Parent=nil end curFrames={}
    for k,t in pairs(tabBtns) do t.dot.Visible=false t.lbl.TextColor3=C.muted t.ico.TextColor3=C.muted end
    if tabBtns[name] then tabBtns[name].dot.Visible=true tabBtns[name].lbl.TextColor3=C.white tabBtns[name].ico.TextColor3=C.blue end
    if tabContent[name] then for _,f in ipairs(tabContent[name]) do f.Parent=CT table.insert(curFrames,f) end end
    task.wait() CT.CanvasSize=UDim2.new(0,0,0,CTL.AbsoluteContentSize.Y+16) CT.CanvasPosition=Vector2.new(0,0)
end
for _,n in ipairs(TABS) do
    local b=makeSideBtn(n,tabIcos[n]) local nn=n
    b.MouseButton1Click:Connect(function() switchTab(nn) end)
end

-- UI ХЕЛПЕРЫ
local function mkSec(tab,title)
    local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,22) f.BackgroundTransparency=1 f.BorderSizePixel=0
    local l=Instance.new("TextLabel",f) l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1 l.Text=title l.TextColor3=C.blue l.Font=Enum.Font.GothamBold l.TextSize=11 l.TextXAlignment=Enum.TextXAlignment.Left
    local line=Instance.new("Frame",f) line.Size=UDim2.new(1,0,0,1) line.Position=UDim2.new(0,0,1,-1) line.BackgroundColor3=C.border line.BorderSizePixel=0
    table.insert(tabContent[tab],f)
end

local function mkToggle(tab,title,desc,cfgKey,onFn)
    local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,48) f.BackgroundColor3=C.card f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,9)
    local fStk=Instance.new("UIStroke",f) fStk.Color=C.border fStk.Thickness=1
    local lbl=Instance.new("TextLabel",f) lbl.Size=UDim2.new(1,-58,0,22) lbl.Position=UDim2.new(0,12,0,6) lbl.BackgroundTransparency=1 lbl.Text=title lbl.TextColor3=C.white lbl.Font=Enum.Font.GothamBold lbl.TextSize=12 lbl.TextXAlignment=Enum.TextXAlignment.Left
    local dsc=Instance.new("TextLabel",f) dsc.Size=UDim2.new(1,-58,0,14) dsc.Position=UDim2.new(0,12,0,28) dsc.BackgroundTransparency=1 dsc.Text=desc or "" dsc.TextColor3=C.muted dsc.Font=Enum.Font.Code dsc.TextSize=10 dsc.TextXAlignment=Enum.TextXAlignment.Left
    local track=Instance.new("Frame",f) track.Size=UDim2.new(0,42,0,23) track.Position=UDim2.new(1,-52,0.5,-11.5) track.BackgroundColor3=C.dim track.BorderSizePixel=0
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    local circle=Instance.new("Frame",track) circle.Size=UDim2.new(0,17,0,17) circle.Position=UDim2.new(0,3,0.5,-8.5) circle.BackgroundColor3=C.muted circle.BorderSizePixel=0
    Instance.new("UICorner",circle).CornerRadius=UDim.new(1,0)
    local btn=Instance.new("TextButton",track) btn.Size=UDim2.new(1,0,1,0) btn.BackgroundTransparency=1 btn.Text=""
    local on=false
    btn.MouseButton1Click:Connect(function()
        on=not on
        local ti=TweenInfo.new(0.17)
        if on then
            TweenService:Create(track,ti,{BackgroundColor3=C.blue}):Play()
            TweenService:Create(circle,ti,{Position=UDim2.new(0,23,0.5,-8.5),BackgroundColor3=C.white}):Play()
            TweenService:Create(f,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(14,22,40)}):Play()
            fStk.Color=C.blue
        else
            TweenService:Create(track,ti,{BackgroundColor3=C.dim}):Play()
            TweenService:Create(circle,ti,{Position=UDim2.new(0,3,0.5,-8.5),BackgroundColor3=C.muted}):Play()
            TweenService:Create(f,TweenInfo.new(0.1),{BackgroundColor3=C.card}):Play()
            fStk.Color=C.border
        end
        if cfgKey then CFG[cfgKey]=on end
        if onFn then onFn(on) end
    end)
    table.insert(tabContent[tab],f)
end

local function mkButton(tab,title,col,fn)
    local bc=col or C.dim
    local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,44) f.BackgroundColor3=bc f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,9)
    Instance.new("UIStroke",f).Color=C.border
    local b=Instance.new("TextButton",f) b.Size=UDim2.new(1,0,1,0) b.BackgroundTransparency=1 b.Text=title b.TextColor3=C.white b.Font=Enum.Font.GothamBold b.TextSize=12 b.BorderSizePixel=0
    b.MouseButton1Click:Connect(function()
        TweenService:Create(f,TweenInfo.new(0.1),{BackgroundColor3=C.blue}):Play()
        task.wait(0.18) TweenService:Create(f,TweenInfo.new(0.15),{BackgroundColor3=bc}):Play()
        if fn then pcall(fn) end
    end)
    table.insert(tabContent[tab],f)
end

-- ═══════════════════════════════
--   ВКЛАДКА INFO
-- ═══════════════════════════════
mkSec("Info","🌿 Primejtsu Hub — Universal")
local ic=Instance.new("Frame") ic.Size=UDim2.new(1,0,0,95) ic.BackgroundColor3=C.card ic.BorderSizePixel=0
Instance.new("UICorner",ic).CornerRadius=UDim.new(0,9)
local icBar=Instance.new("Frame",ic) icBar.Size=UDim2.new(1,0,0,2) icBar.BackgroundColor3=C.blue icBar.BorderSizePixel=0
task.spawn(function() local hue=0 while icBar and icBar.Parent do hue=(hue+2)%360 icBar.BackgroundColor3=Color3.fromHSV(hue/360,1,1) task.wait(0.04) end end)
local icI=Instance.new("TextLabel",ic) icI.Size=UDim2.new(0,55,0,60) icI.Position=UDim2.new(0,8,0.5,-30) icI.BackgroundTransparency=1 icI.Text="🌿" icI.TextSize=48 icI.Font=Enum.Font.GothamBlack
local icN1=Instance.new("TextLabel",ic) icN1.Size=UDim2.new(1,-70,0,22) icN1.Position=UDim2.new(0,66,0,10) icN1.BackgroundTransparency=1 icN1.Text="Primejtsu Hub" icN1.TextColor3=C.blue icN1.Font=Enum.Font.GothamBlack icN1.TextSize=18 icN1.TextXAlignment=Enum.TextXAlignment.Left
local icN2=Instance.new("TextLabel",ic) icN2.Size=UDim2.new(1,-70,0,15) icN2.Position=UDim2.new(0,66,0,34) icN2.BackgroundTransparency=1 icN2.Text="✦ Universal — 400+ Functions" icN2.TextColor3=C.lblue icN2.Font=Enum.Font.Code icN2.TextSize=12 icN2.TextXAlignment=Enum.TextXAlignment.Left
local icN3=Instance.new("TextLabel",ic) icN3.Size=UDim2.new(1,-70,0,13) icN3.Position=UDim2.new(0,66,0,51) icN3.BackgroundTransparency=1 icN3.Text="✈ @Primejtsu | Nazar513000" icN3.TextColor3=Color3.fromRGB(50,150,220) icN3.Font=Enum.Font.Code icN3.TextSize=11 icN3.TextXAlignment=Enum.TextXAlignment.Left
local icN4=Instance.new("TextLabel",ic) icN4.Size=UDim2.new(1,0,0,14) icN4.Position=UDim2.new(0,10,1,-17) icN4.BackgroundTransparency=1 icN4.Text="v6.0  •  🔑 Primejtsu  •  Roblox Universal" icN4.TextColor3=C.muted icN4.Font=Enum.Font.Code icN4.TextSize=10 icN4.TextXAlignment=Enum.TextXAlignment.Left
table.insert(tabContent["Info"],ic)

mkSec("Info","📊 Сессия")
local stF=Instance.new("Frame") stF.Size=UDim2.new(1,0,0,70) stF.BackgroundColor3=C.card stF.BorderSizePixel=0
Instance.new("UICorner",stF).CornerRadius=UDim.new(0,9) Instance.new("UIStroke",stF).Color=C.border
local st1=Instance.new("TextLabel",stF) st1.Size=UDim2.new(0.5,0,0.5,0) st1.Position=UDim2.new(0,10,0,6) st1.BackgroundTransparency=1 st1.TextXAlignment=Enum.TextXAlignment.Left st1.Font=Enum.Font.GothamBold st1.TextSize=12
local st2=Instance.new("TextLabel",stF) st2.Size=UDim2.new(0.5,0,0.5,0) st2.Position=UDim2.new(0.5,0,0,6) st2.BackgroundTransparency=1 st2.TextXAlignment=Enum.TextXAlignment.Left st2.Font=Enum.Font.GothamBold st2.TextSize=12
local st3=Instance.new("TextLabel",stF) st3.Size=UDim2.new(0.5,0,0.5,0) st3.Position=UDim2.new(0,10,0.5,0) st3.BackgroundTransparency=1 st3.TextXAlignment=Enum.TextXAlignment.Left st3.Font=Enum.Font.Code st3.TextSize=11
local st4=Instance.new("TextLabel",stF) st4.Size=UDim2.new(0.5,0,0.5,0) st4.Position=UDim2.new(0.5,0,0.5,0) st4.BackgroundTransparency=1 st4.TextXAlignment=Enum.TextXAlignment.Left st4.Font=Enum.Font.Code st4.TextSize=11
table.insert(tabContent["Info"],stF)
RunService.Heartbeat:Connect(function()
    if st1 and st1.Parent then st1.Text="🌾 Фарм: "..CFG.harvestCount st1.TextColor3=C.green end
    if st2 and st2.Parent then st2.Text="💰 Продаж: "..CFG.sellCount st2.TextColor3=C.gold end
    if st3 and st3.Parent then st3.Text="⚔ Убийств: "..CFG.killCount st3.TextColor3=C.red end
    if st4 and st4.Parent then
        if CFG.sessionStart>0 then
            local s=tick()-CFG.sessionStart
            st4.Text="⏱ "..math.floor(s/60).."м "..math.floor(s%60).."с"
        end st4.TextColor3=C.muted
    end
end)

-- ═══════════════════════════════
--   ВКЛАДКА MOVE
-- ═══════════════════════════════
mkSec("Move","⚡ Скорость")
mkToggle("Move","⚡ Speed Hack","Ускоренный бег (по умолчанию x2)","speed")
mkToggle("Move","🐇 BHop","Автоматические прыжки","bhop")
mkToggle("Move","🐇 Infinite Jump","Бесконечные прыжки","infiniteJump")
mkToggle("Move","🚀 Super Jump","Огромный прыжок","superJump")
mkToggle("Move","🌙 Low Gravity","Уменьшенная гравитация","lowGravity")
mkSec("Move","🦅 Полёт")
mkToggle("Move","🦅 Fly","Полёт WASD + E/Q","fly",function(v) if v then startFly() else stopFly() end end)
mkToggle("Move","👻 Noclip","Сквозь стены","noclip")
mkToggle("Move","🛡 Anti Void","Защита от падения в void","antiVoid")
mkSec("Move","⚙ Действия")
mkButton("Move","🚀 Запустить вверх",C.dim,function()
    local hrp=getHRP() if hrp then hrp.Velocity=Vector3.new(0,120,0) end
end)
mkButton("Move","❄ Заморозить себя",C.dim,function()
    CFG.freezePlayer=not CFG.freezePlayer
    notify(CFG.freezePlayer and "❄ Заморожен" or "✅ Разморожен","",2)
end)
mkToggle("Move","🌀 SpinBot","Вращение персонажа","spinBot")
mkButton("Move","🔄 Respawn",C.dim,function() LP:LoadCharacter() end)

-- ═══════════════════════════════
--   ВКЛАДКА COMBAT
-- ═══════════════════════════════
mkSec("Combat","🎯 Aimbot")
mkToggle("Combat","🎯 Aimbot","Автоприцеливание на ближайшего врага","aimbot")
mkToggle("Combat","👻 Silent Aim","Невидимый aimbot","aimbotSilent")
mkToggle("Combat","🔫 TriggerBot","Авто выстрел при прицеле","triggerBot")
mkSec("Combat","⚔ Атака")
mkToggle("Combat","⚔ KillAura","Авто атака в радиусе","killaura")
mkToggle("Combat","💀 God Mode","Бессмертие","godMode")
mkToggle("Combat","❤ Infinite HP","Бесконечное здоровье","infiniteHealth")
mkToggle("Combat","💨 Fling игроков","Подбрасывать ближайших","flingPlayer",function(v)
    if v then
        task.spawn(function()
            while CFG.flingPlayer do
                task.wait(0.5)
                local hrp=getHRP() if not hrp then continue end
                for _,p in ipairs(Players:GetPlayers()) do
                    if p~=LP and p.Character then
                        local t=p.Character:FindFirstChild("HumanoidRootPart")
                        if t and (t.Position-hrp.Position).Magnitude<20 then
                            flingPlayer(p)
                        end
                    end
                end
            end
        end)
    end
end)
mkButton("Combat","💥 Nuke (взрыв вокруг)",C.dim,nukeArea)
mkButton("Combat","💀 Kill All Mobs",C.dim,function()
    local count=0
    for _,obj in ipairs(WS:GetDescendants()) do
        pcall(function()
            if obj:IsA("Humanoid") and obj.Parent~=LP.Character then
                obj.Health=0 count=count+1
            end
        end)
    end
    notify("💀 Kill All","Убито NPC: "..count,3)
end)

-- ═══════════════════════════════
--   ВКЛАДКА VISUAL
-- ═══════════════════════════════
mkSec("Visual","👁 ESP")
mkToggle("Visual","👥 ESP Игроки","Имя + HP + дистанция","espPlayers")
mkToggle("Visual","📦 ESP Boxes","Рамки вокруг игроков","espBoxes")
mkToggle("Visual","➡ ESP Tracers","Линии к игрокам","espTracers")
mkToggle("Visual","🌱 ESP Items","Предметы на карте","espItems")
mkSec("Visual","🌈 Шейдеры")
mkToggle("Visual","✨ Bloom","Свечение","shaderBloom",function() applyShaders() end)
mkToggle("Visual","🌫 Blur","Размытие фона","shaderBlur",function() applyShaders() end)
mkToggle("Visual","☀ Sun Rays","Лучи солнца","shaderSunRays",function() applyShaders() end)
mkToggle("Visual","📸 Depth of Field","Фокус камеры","shaderDepthOfField",function() applyShaders() end)
mkToggle("Visual","🎨 Color Correct","Коррекция цвета (тёплый)","shaderColorCorrect",function() applyShaders() end)
mkSec("Visual","🎮 Вид")
mkToggle("Visual","☀ Fullbright","Всегда день","fullbright",function() applyShaders() end)
mkToggle("Visual","🌙 Night Mode","Тёмная ночь","nightMode",function() applyShaders() end)
mkToggle("Visual","🌈 Rainbow Player","Переливающийся персонаж","rainbow")
mkToggle("Visual","➕ Crosshair","Прицел на экране","crosshair",function() updateCrosshair() end)
mkToggle("Visual","📷 Third Person","Вид от 3-го лица","thirdPerson")
mkToggle("Visual","🌫 No Fog","Убрать туман","noFog",function(v)
    for _,o in ipairs(Lighting:GetChildren()) do
        if o:IsA("Atmosphere") then o.Density=v and 0 or 0.395 end
    end
end)

-- ═══════════════════════════════
--   ВКЛАДКА FARM
-- ═══════════════════════════════
mkSec("Farm","🌾 Универсальный фарм")
mkToggle("Farm","🌾 Auto Farm","Авто сбор монет/ресурсов","autoFarm")
mkToggle("Farm","🧲 Auto Collect","Притягивать предметы к себе","autoCollect")
mkToggle("Farm","💰 Auto Sell","Авто продажа в магазине","autoSell")
mkToggle("Farm","🔄 Auto Rebirth","Авто перерождение","autoRebirth")
mkToggle("Farm","📋 Auto Quest","Авто выполнение квестов","autoQuest")
mkToggle("Farm","💤 Anti AFK","Защита от кика","antiAFK")
mkSec("Farm","⚡ Быстро")
mkButton("Farm","🧲 Собрать всё рядом (50st)",C.dim,function()
    task.spawn(function()
        local hrp=getHRP() if not hrp then return end
        local n=0
        for _,o in ipairs(WS:GetDescendants()) do
            pcall(function()
                if isFarmable(o) and o:IsA("BasePart") and (o.Position-hrp.Position).Magnitude<50 then
                    o.CFrame=hrp.CFrame n=n+1
                end
            end)
        end
        notify("🧲 Собрано",n.." предметов",3)
    end)
end)
mkButton("Farm","💰 TP к магазину",C.dim,function()
    local hrp=getHRP() if not hrp then return end
    for _,o in ipairs(WS:GetDescendants()) do
        pcall(function()
            local n=o.Name:lower()
            if n:find("sell") or n:find("shop") or n:find("market") then
                local pos
                if o:IsA("Model") then pos=o:GetPivot().Position
                elseif o:IsA("BasePart") then pos=o.Position end
                if pos then hrp.CFrame=CFrame.new(pos+Vector3.new(0,4,0)) notify("📍 TP","К магазину!",2) error("done") end
            end
        end)
    end
end)

-- ═══════════════════════════════
--   ВКЛАДКА WORLD
-- ═══════════════════════════════
mkSec("World","🌍 Мир")
mkToggle("World","🖱 Click TP","Тап/клик = телепорт","clickTP")
mkToggle("World","🗑 Click Delete","Тап = удалить объект","clickDelete")
mkToggle("World","💥 Click Nuke","Нюк вокруг объекта","clickNuke")
mkButton("World","💥 Nuke вокруг себя",C.dim,nukeArea)
mkButton("World","🗑 Удалить все незакреплённые",C.dim,function()
    local n=0
    for _,o in ipairs(WS:GetDescendants()) do
        pcall(function()
            if o:IsA("BasePart") and not o.Anchored and o.Parent~=LP.Character then
                o:Destroy() n=n+1
            end
        end)
    end
    notify("🗑 Удалено",n.." объектов",3)
end)
mkSec("World","🌐 Сервер")
mkButton("World","🔄 Server Hop",C.dim,serverHop)
mkButton("World","🔄 Rejoin",C.dim,function() game:GetService("TeleportService"):Teleport(game.PlaceId,LP) end)
mkSec("World","📍 Телепорт")
mkButton("World","📍 TP к случайному игроку",C.dim,function()
    local hrp=getHRP() if not hrp then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Character then
            local t=p.Character:FindFirstChild("HumanoidRootPart")
            if t then hrp.CFrame=t.CFrame+Vector3.new(3,3,0) notify("📍 TP","К: "..p.Name,2) return end
        end
    end
end)
mkToggle("World","🌀 Orbit игрока","Вращаться вокруг ближайшего","orbitPlayer")

-- ═══════════════════════════════
--   ВКЛАДКА MISC
-- ═══════════════════════════════
mkSec("Misc","⚙ Прочее")
mkToggle("Misc","💬 Chat Spam","Спам в чате","chatSpam")
mkToggle("Misc","👻 Скрыть персонажа","Невидимость","hidePlayer",function(v)
    pcall(function()
        local c=getChar() if not c then return end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") or p:IsA("Decal") then p.LocalTransparencyModifier=v and 1 or 0 end
        end
    end)
end)
mkToggle("Misc","🔒 Anti Ban","Защита от бана","antiBan")
mkButton("Misc","🔔 Уведомление",C.dim,function() notify("🌿 Primejtsu Hub","v6.0 | Universal | 400+ Functions",4) end)
mkButton("Misc","💀 Kill себя",C.dim,function()
    local h=getHum() if h then h.Health=0 end
end)
mkButton("Misc","🚀 Launch All Players",C.dim,function()
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP then pcall(function() flingPlayer(p) end) end
    end
end)

task.wait(0.1) switchTab("Info")
task.wait(0.35) openGUI()
notify("✅ Primejtsu Hub","Universal v6.0 | 400+ Functions | @Primejtsu 🌿",5)

end -- showMain

CFG.sessionStart=0
print("[Primejtsu Hub v6.0] Universal | 400+ Functions | @Primejtsu | Nazar513000 🌿")
