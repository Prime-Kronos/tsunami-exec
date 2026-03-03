-- ╔══════════════════════════════════════════════════════════════╗
-- ║      PrimejTsuHub v8.0 | @Primejtsu | Nazar513000           ║
-- ║      MM2 MEGA UPDATE | Mobile Edition | 6400+ строк          ║
-- ║  CoinFarm v5 | Fly | Aimbot | SilentAim | BoxESP | Radar    ║
-- ║  Chams | Tracers | Crosshair | WallHack | ChatSpy | Trol v5 ║
-- ╚══════════════════════════════════════════════════════════════╝

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local Lighting     = game:GetService("Lighting")
local LP           = Players.LocalPlayer
local Camera       = workspace.CurrentCamera
local showGUI

local CFG = {
    -- Движение
    god=false, speed=false, bhop=false, noclip=false,
    infiniteJump=false, fly=false, superJump=false, lowGravity=false,
    alwaysSprint=false,
    -- Защита
    antiKnock=false, infAmmo=false, noDeathAnim=false,
    -- Фарм
    coinFarm=false, knife=false, autoReward=false, bringCoins=false,
    -- Визуал
    esp=false, chams=false, tracers=false, boxESP=false,
    fullbright=false, noFog=false, radarOn=false,
    crosshair=false, wallhack=false, showCoins=false,
    -- Байпас
    bypass=false, antiAfk=true,
    -- Скрытность
    hide=false, bigHead=false, spinBot=false,
    -- Aimbot
    aimbot=false, silentAim=false,
    -- Trol
    followVictim=false, blockVictim=false, annoyMurd=false,
    -- Misc
    chatSpy=false,
}
local coinCount      = 0
local farmPaused     = false
local espObjects     = {}
local chamObjects    = {}
local boxESPData     = {}
local victimName     = "Никто"
local noclipWasOn    = false
local flyActive      = false
local flyBV          = nil
local flyBG          = nil
local spinAngle      = 0
local aimbotFOV      = 200
local savedPositions = {}
local killCount      = 0
local deathCount     = 0
local function getChar() return LP.Character end
local function getHRP() local c=getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c=getChar() return c and c:FindFirstChildOfClass("Humanoid") end

-- GOD MODE
local function applyGod(on)
    pcall(function()
        local h=getHum() if not h then return end
        if on then h.MaxHealth=1e6 h.Health=1e6 h.BreakJointsOnDeath=false end
    end)
end
RunService.Heartbeat:Connect(function()
    if not CFG.god then return end
    local h=getHum() if not h then return end
    if h.Health<h.MaxHealth then h.Health=h.MaxHealth end
    h.BreakJointsOnDeath=false
end)
LP.CharacterAdded:Connect(function() task.wait(0.5) if CFG.god then applyGod(true) end end)

-- ANTI AFK
-- ANTI AFK — улучшенный
local afkConn
local function startAntiAfk()
    pcall(function() LP.Idled:Connect(function()
        if not CFG.antiAfk then return end
        local vu=game:GetService("VirtualUser")
        vu:Button2Down(Vector2.new(0,0),Camera.CFrame)
        task.wait(0.1)
        vu:Button2Up(Vector2.new(0,0),Camera.CFrame)
        -- Прыжок чтобы точно не кикнуло
        local h=getHum() if h then h.Jump=true end
    end) end)
end
startAntiAfk()
task.spawn(function()
    while true do
        task.wait(60) -- каждую минуту
        if not CFG.antiAfk then continue end
        pcall(function()
            local vu=game:GetService("VirtualUser")
            vu:Button2Down(Vector2.new(0,0),Camera.CFrame)
            task.wait(0.1)
            vu:Button2Up(Vector2.new(0,0),Camera.CFrame)
            local h=getHum() if h then h.Jump=true end
        end)
    end
end)

-- SPEED / BHOP / INF JUMP
RunService.Heartbeat:Connect(function()
    local h=getHum() if not h then return end
    if CFG.coinFarm then return end
    if CFG.alwaysSprint then h.WalkSpeed=45 return end
    if CFG.speed then h.WalkSpeed=50
    elseif CFG.bhop then h.WalkSpeed=28
    else if h.WalkSpeed~=16 then h.WalkSpeed=16 end end
    if CFG.bhop then if h.FloorMaterial~=Enum.Material.Air then h.Jump=true end end
    if CFG.superJump then h.JumpPower=200
    else if h.JumpPower~=50 then h.JumpPower=50 end end
end)

UIS.JumpRequest:Connect(function()
    if CFG.infiniteJump then
        local h=getHum() if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

RunService.Heartbeat:Connect(function()
    if not CFG.lowGravity then
        if workspace.Gravity~=196.2 then workspace.Gravity=196.2 end
        return
    end
    workspace.Gravity=40
end)

-- ════════════════════════════════════════════════════════════════
-- FLY MODE
-- ════════════════════════════════════════════════════════════════
local function enableFly(on)
    local hrp=getHRP()
    if on and hrp then
        flyActive=true
        local bv=Instance.new("BodyVelocity",hrp)
        bv.MaxForce=Vector3.new(1e9,1e9,1e9) bv.Velocity=Vector3.new(0,0,0) flyBV=bv
        local bg=Instance.new("BodyGyro",hrp)
        bg.MaxTorque=Vector3.new(1e9,1e9,1e9) bg.D=500 flyBG=bg
        local h=getHum() if h then h.PlatformStand=true end
        task.spawn(function()
            while flyActive do
                task.wait()
                if not flyBV or not flyBV.Parent then break end
                local cf=Camera.CFrame local spd=32
                local vel=Vector3.new(0,0,0)
                if UIS:IsKeyDown(Enum.KeyCode.W) then vel=vel+cf.LookVector*spd end
                if UIS:IsKeyDown(Enum.KeyCode.S) then vel=vel-cf.LookVector*spd end
                if UIS:IsKeyDown(Enum.KeyCode.A) then vel=vel-cf.RightVector*spd end
                if UIS:IsKeyDown(Enum.KeyCode.D) then vel=vel+cf.RightVector*spd end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then vel=vel+Vector3.new(0,spd,0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then vel=vel-Vector3.new(0,spd,0) end
                flyBV.Velocity=vel
                if flyBG then flyBG.CFrame=cf end
            end
        end)
    else
        flyActive=false
        if flyBV then pcall(function() flyBV:Destroy() end) flyBV=nil end
        if flyBG then pcall(function() flyBG:Destroy() end) flyBG=nil end
        local h=getHum() if h then h.PlatformStand=false end
    end
end

-- ════════════════════════════════════════════════════════════════
-- INF AMMO / ANTI KNOCK / BIG HEAD / SPIN / HIDE / ALWAYS SPRINT
-- ════════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    if not CFG.infAmmo then return end
    pcall(function()
        local c=getChar() if not c then return end
        for _,t in ipairs(c:GetChildren()) do
            if t:IsA("Tool") then
                local a=t:FindFirstChild("Ammo") if a then a.Value=999 end
                local b=t:FindFirstChild("AmmoValue") if b then b.Value=999 end
            end
        end
    end)
end)

RunService.Heartbeat:Connect(function()
    if not CFG.antiKnock then return end
    pcall(function()
        local hrp=getHRP() if not hrp then return end
        hrp.CustomPhysicalProperties=PhysicalProperties.new(0,0,0,0,0)
    end)
end)

RunService.Heartbeat:Connect(function()
    if not CFG.bigHead then return end
    pcall(function()
        local c=getChar() if not c then return end
        local h=c:FindFirstChild("Head") if h then h.Size=Vector3.new(5,5,5) end
    end)
end)

RunService.Heartbeat:Connect(function()
    if not CFG.spinBot then return end
    local hrp=getHRP() if not hrp then return end
    spinAngle=spinAngle+9
    pcall(function() hrp.CFrame=CFrame.new(hrp.Position)*CFrame.Angles(0,math.rad(spinAngle),0) end)
end)

local function hidePlayer(v)
    pcall(function()
        local c=getChar() if not c then return end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") or p:IsA("Decal") then
                p.LocalTransparencyModifier=v and 1 or 0
            end
        end
    end)
end

RunService.Heartbeat:Connect(function()
    if not CFG.alwaysSprint then return end
    local h=getHum() if not h or CFG.coinFarm then return end
    h.WalkSpeed=45
end)

-- ════════════════════════════════════════════════════════════════
-- NO FOG
-- ════════════════════════════════════════════════════════════════
local function setNoFog(v)
    pcall(function()
        local atmos=Lighting:FindFirstChildOfClass("Atmosphere")
        if atmos then atmos.Density=v and 0 or 0.395 end
        for _,fx in ipairs(Lighting:GetDescendants()) do
            if fx.ClassName=="DepthOfFieldEffect" then fx.Enabled=not v end
        end
    end)
end

-- ════════════════════════════════════════════════════════════════
-- CHAMS — подсвечивает игроков сквозь стены
-- ════════════════════════════════════════════════════════════════
local ROLE_COLORS2={Murderer=Color3.fromRGB(255,50,50),Sheriff=Color3.fromRGB(50,130,255),Innocent=Color3.fromRGB(50,220,100)}
local function applyChams(p,on)
    if p==LP then return end
    if chamObjects[p] then
        for _,s in ipairs(chamObjects[p]) do pcall(function() s:Destroy() end) end
        chamObjects[p]=nil
    end
    if not on then return end
    pcall(function()
        if not p.Character then return end
        chamObjects[p]={}
        for _,part in ipairs(p.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name~="HumanoidRootPart" then
                local sel=Instance.new("SelectionBox",game:GetService("CoreGui"))
                sel.Adornee=part sel.Color3=ROLE_COLORS2[getRole(p)] or Color3.new(1,1,0)
                sel.SurfaceTransparency=0.55 sel.LineThickness=0.04
                table.insert(chamObjects[p],sel)
            end
        end
    end)
end
RunService.Heartbeat:Connect(function()
    if not CFG.chams then
        for p2 in pairs(chamObjects) do applyChams(p2,false) end return
    end
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Character and not chamObjects[p] then applyChams(p,true) end
    end
end)

-- ════════════════════════════════════════════════════════════════
-- TRACERS
-- ════════════════════════════════════════════════════════════════
local tracerGui=Instance.new("ScreenGui",game:GetService("CoreGui"))
tracerGui.Name="PTH8Tracers" tracerGui.ResetOnSpawn=false tracerGui.Enabled=false
local tracerFrame=Instance.new("Frame",tracerGui)
tracerFrame.Size=UDim2.new(1,0,1,0) tracerFrame.BackgroundTransparency=1 tracerFrame.BorderSizePixel=0

RunService.RenderStepped:Connect(function()
    tracerGui.Enabled=CFG.tracers
    for _,v in ipairs(tracerFrame:GetChildren()) do v:Destroy() end
    if not CFG.tracers then return end
    local vp=Camera.ViewportSize
    local cx,cy=vp.X/2,vp.Y
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP or not p.Character then continue end
        local hrp=p.Character:FindFirstChild("HumanoidRootPart") if not hrp then continue end
        local pos,onScreen=Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen or pos.Z<0 then continue end
        local dx,dy=pos.X-cx,pos.Y-cy
        local len=math.sqrt(dx*dx+dy*dy) if len<1 then continue end
        local line=Instance.new("Frame",tracerFrame)
        line.Size=UDim2.new(0,len,0,2) line.Position=UDim2.new(0,cx,0,cy)
        line.Rotation=math.deg(math.atan2(dy,dx)) line.AnchorPoint=Vector2.new(0,0.5)
        line.BackgroundColor3=ROLE_COLORS2[getRole(p)] or Color3.new(1,1,0)
        line.BorderSizePixel=0
        Instance.new("UICorner",line).CornerRadius=UDim.new(1,0)
    end
end)

-- ════════════════════════════════════════════════════════════════
-- BOX ESP
-- ════════════════════════════════════════════════════════════════
local boxGui=Instance.new("ScreenGui",game:GetService("CoreGui"))
boxGui.Name="PTH8BoxESP" boxGui.ResetOnSpawn=false boxGui.Enabled=false

local function createBox(p)
    if p==LP or boxESPData[p] then return end
    local c=Instance.new("Frame",boxGui) c.BackgroundTransparency=1 c.BorderSizePixel=0
    local lines={}
    for _=1,4 do local l=Instance.new("Frame",c) l.BorderSizePixel=0 table.insert(lines,l) end
    boxESPData[p]={c=c,l=lines}
end

RunService.RenderStepped:Connect(function()
    boxGui.Enabled=CFG.boxESP
    if not CFG.boxESP then
        for _,d in pairs(boxESPData) do pcall(function() d.c.Visible=false end) end return
    end
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        if not p.Character then continue end
        createBox(p)
        local d=boxESPData[p] if not d then continue end
        local hrp=p.Character:FindFirstChild("HumanoidRootPart")
        local head=p.Character:FindFirstChild("Head")
        local hum=p.Character:FindFirstChildOfClass("Humanoid")
        if not hrp or not head or not hum or hum.Health<=0 then d.c.Visible=false continue end
        local hs,hon=Camera:WorldToScreenPoint(head.Position+Vector3.new(0,0.7,0))
        local fs,fon=Camera:WorldToScreenPoint(hrp.Position-Vector3.new(0,2.5,0))
        if not hon or not fon or hs.Z<0 then d.c.Visible=false continue end
        d.c.Visible=true
        local col=ROLE_COLORS2[getRole(p)]
        local top=math.min(hs.Y,fs.Y) local bot=math.max(hs.Y,fs.Y)
        local h2=bot-top local w2=h2*0.55 local left=hs.X-w2/2 local th=1.5
        for _,ln in ipairs(d.l) do ln.BackgroundColor3=col end
        d.l[1].Position=UDim2.new(0,left,0,top)      d.l[1].Size=UDim2.new(0,w2,0,th)
        d.l[2].Position=UDim2.new(0,left,0,bot)       d.l[2].Size=UDim2.new(0,w2,0,th)
        d.l[3].Position=UDim2.new(0,left,0,top)       d.l[3].Size=UDim2.new(0,th,0,h2)
        d.l[4].Position=UDim2.new(0,left+w2,0,top)    d.l[4].Size=UDim2.new(0,th,0,h2)
    end
    for p2,d2 in pairs(boxESPData) do
        if not p2 or not p2.Parent then pcall(function() d2.c:Destroy() end) boxESPData[p2]=nil end
    end
end)
for _,p in ipairs(Players:GetPlayers()) do createBox(p) end
Players.PlayerAdded:Connect(function(p) task.wait(1) createBox(p) end)
Players.PlayerRemoving:Connect(function(p)
    if boxESPData[p] then pcall(function() boxESPData[p].c:Destroy() end) boxESPData[p]=nil end
end)

-- ════════════════════════════════════════════════════════════════
-- AIMBOT v2
-- ════════════════════════════════════════════════════════════════
local aimbotGui=Instance.new("ScreenGui",game:GetService("CoreGui"))
aimbotGui.Name="PTH8Aimbot" aimbotGui.ResetOnSpawn=false aimbotGui.Enabled=false
local fovCircle=Instance.new("Frame",aimbotGui)
fovCircle.AnchorPoint=Vector2.new(0.5,0.5) fovCircle.BackgroundTransparency=1 fovCircle.BorderSizePixel=0
Instance.new("UICorner",fovCircle).CornerRadius=UDim.new(1,0)
local fovStroke=Instance.new("UIStroke",fovCircle)
fovStroke.Color=Color3.fromRGB(215,25,25) fovStroke.Thickness=1.5 fovStroke.Transparency=0.4

local function getBestTarget()
    local hrp=getHRP() if not hrp then return nil end
    local center=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
    local best,bestScore=nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP or not p.Character then continue end
        local hum=p.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health<=0 then continue end
        local head=p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
        if not head then continue end
        local sp,onS=Camera:WorldToScreenPoint(head.Position)
        if not onS or sp.Z<0 then continue end
        local dist2D=(Vector2.new(sp.X,sp.Y)-center).Magnitude
        if dist2D>aimbotFOV then continue end
        local score=getRole(p)=="Murderer" and dist2D*0.3 or dist2D
        if score<bestScore then bestScore=score best=p end
    end
    return best
end

RunService.RenderStepped:Connect(function()
    aimbotGui.Enabled=CFG.aimbot
    if not CFG.aimbot then return end
    local d=aimbotFOV*2
    fovCircle.Size=UDim2.new(0,d,0,d) fovCircle.Position=UDim2.new(0.5,0,0.5,0)
    local tgt=getBestTarget()
    if tgt and tgt.Character then
        local head=tgt.Character:FindFirstChild("Head") or tgt.Character:FindFirstChild("HumanoidRootPart")
        if head then
            Camera.CFrame=Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position,head.Position),0.18)
        end
    end
end)

-- ════════════════════════════════════════════════════════════════
-- SILENT AIM
-- ════════════════════════════════════════════════════════════════
local silentConn
local function enableSilentAim(on)
    if silentConn then silentConn:Disconnect() silentConn=nil end
    if not on then return end
    silentConn=RunService.RenderStepped:Connect(function()
        if not CFG.silentAim then return end
        local tgt=getBestTarget()
        if not tgt or not tgt.Character then return end
        local head=tgt.Character:FindFirstChild("Head") if not head then return end
        pcall(function()
            local sp,onS=Camera:WorldToScreenPoint(head.Position)
            if onS then
                local vu=game:GetService("VirtualUser")
                vu:MoveMouse(Vector2.new(sp.X,sp.Y))
            end
        end)
    end)
end

-- ════════════════════════════════════════════════════════════════
-- RADAR
-- ════════════════════════════════════════════════════════════════
local radarGui=Instance.new("ScreenGui",game:GetService("CoreGui"))
radarGui.Name="PTH8Radar" radarGui.ResetOnSpawn=false radarGui.Enabled=false
local radarBG=Instance.new("Frame",radarGui)
radarBG.Size=UDim2.new(0,170,0,170) radarBG.Position=UDim2.new(0,8,1,-178)
radarBG.BackgroundColor3=Color3.fromRGB(4,4,8) radarBG.BackgroundTransparency=0.2 radarBG.BorderSizePixel=0
Instance.new("UICorner",radarBG).CornerRadius=UDim.new(1,0)
Instance.new("UIStroke",radarBG).Color=Color3.fromRGB(215,25,25)
local radarTitle=Instance.new("TextLabel",radarBG)
radarTitle.Size=UDim2.new(1,0,0,18) radarTitle.BackgroundTransparency=1
radarTitle.Text="📡 RADAR" radarTitle.TextColor3=Color3.fromRGB(215,25,25)
radarTitle.Font=Enum.Font.GothamBold radarTitle.TextSize=10
local selfDot=Instance.new("Frame",radarBG)
selfDot.Size=UDim2.new(0,9,0,9) selfDot.AnchorPoint=Vector2.new(0.5,0.5)
selfDot.Position=UDim2.new(0.5,0,0.5,0) selfDot.BackgroundColor3=Color3.fromRGB(255,255,0) selfDot.BorderSizePixel=0
Instance.new("UICorner",selfDot).CornerRadius=UDim.new(1,0)
local radarDots={}
RunService.Heartbeat:Connect(function()
    radarGui.Enabled=CFG.radarOn
    if not CFG.radarOn then
        for _,d in pairs(radarDots) do pcall(function() d:Destroy() end) end radarDots={} return
    end
    local hrp=getHRP() if not hrp then return end
    local myPos=hrp.Position local scale=4
    for p2,d2 in pairs(radarDots) do
        if not p2 or not p2.Parent then pcall(function() d2:Destroy() end) radarDots[p2]=nil end
    end
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP or not p.Character then continue end
        local pHRP=p.Character:FindFirstChild("HumanoidRootPart") if not pHRP then continue end
        if not radarDots[p] then
            local dot=Instance.new("Frame",radarBG)
            dot.Size=UDim2.new(0,8,0,8) dot.AnchorPoint=Vector2.new(0.5,0.5) dot.BorderSizePixel=0
            Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
            local nl=Instance.new("TextLabel",dot)
            nl.Size=UDim2.new(0,55,0,12) nl.Position=UDim2.new(0.5,-27,1,1)
            nl.BackgroundTransparency=1 nl.Text=p.Name:sub(1,8)
            nl.TextColor3=Color3.fromRGB(200,200,200) nl.Font=Enum.Font.Code nl.TextSize=8
            radarDots[p]=dot
        end
        radarDots[p].BackgroundColor3=ROLE_COLORS2[getRole(p)] or Color3.fromRGB(200,200,200)
        local diff=pHRP.Position-myPos
        local rx=math.clamp(diff.X/scale,-80,80) local rz=math.clamp(diff.Z/scale,-80,80)
        radarDots[p].Position=UDim2.new(0.5,rx,0.5,rz)
    end
end)

-- ════════════════════════════════════════════════════════════════
-- CROSSHAIR
-- ════════════════════════════════════════════════════════════════
local crossGui=Instance.new("ScreenGui",game:GetService("CoreGui"))
crossGui.Name="PTH8Cross" crossGui.ResetOnSpawn=false crossGui.Enabled=false
local crosshairOn=false
local function buildCrosshair()
    crossGui:ClearAllChildren()
    local vp=Camera.ViewportSize local cx,cy=vp.X/2,vp.Y/2
    local sz,th,gap=18,2,5 local col=Color3.fromRGB(255,50,50)
    local function mkL(px,py,sw,sh)
        local f=Instance.new("Frame",crossGui) f.Position=UDim2.new(0,px,0,py)
        f.Size=UDim2.new(0,sw,0,sh) f.BackgroundColor3=col f.BorderSizePixel=0
        Instance.new("UICorner",f).CornerRadius=UDim.new(1,0)
    end
    mkL(cx-sz-gap,cy-th/2,sz,th) mkL(cx+gap,cy-th/2,sz,th)
    mkL(cx-th/2,cy-sz-gap,th,sz) mkL(cx-th/2,cy+gap,th,sz)
    local dot=Instance.new("Frame",crossGui) dot.Size=UDim2.new(0,4,0,4)
    dot.AnchorPoint=Vector2.new(0.5,0.5) dot.Position=UDim2.new(0.5,0,0.5,0)
    dot.BackgroundColor3=col dot.BorderSizePixel=0
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
end
local function toggleCrosshair(v)
    crosshairOn=v crossGui.Enabled=v if v then buildCrosshair() end
end
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    if crosshairOn then buildCrosshair() end
end)

-- ════════════════════════════════════════════════════════════════
-- WALLHACK
-- ════════════════════════════════════════════════════════════════
local whOrig={}
local function applyWallhack(on)
    if on then
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.CanCollide and obj.Transparency<0.5 then
                if not obj:IsDescendantOf(getChar() or game) then
                    if whOrig[obj]==nil then whOrig[obj]=obj.Transparency end
                    obj.Transparency=0.88
                end
            end
        end
    else
        for obj,t in pairs(whOrig) do pcall(function() if obj and obj.Parent then obj.Transparency=t end end) end
        whOrig={}
    end
end

-- ════════════════════════════════════════════════════════════════
-- CHAT SPY
-- ════════════════════════════════════════════════════════════════
pcall(function()
    for _,p in ipairs(Players:GetPlayers()) do
        p.Chatted:Connect(function(msg)
            if CFG.chatSpy and p~=LP then
                pcall(function()
                    game:GetService("StarterGui"):SetCore("SendNotification",
                        {Title="💬 "..p.Name, Text=msg:sub(1,80), Duration=4})
                end)
            end
        end)
    end
    Players.PlayerAdded:Connect(function(p)
        p.Chatted:Connect(function(msg)
            if CFG.chatSpy and p~=LP then
                pcall(function()
                    game:GetService("StarterGui"):SetCore("SendNotification",
                        {Title="💬 "..p.Name, Text=msg:sub(1,80), Duration=4})
                end)
            end
        end)
    end)
end)

-- ════════════════════════════════════════════════════════════════
-- HP БАР ВНИЗУ ЭКРАНА
-- ════════════════════════════════════════════════════════════════
local hpGui=Instance.new("ScreenGui",game:GetService("CoreGui"))
hpGui.Name="PTH8HP" hpGui.ResetOnSpawn=false
local hpFrame=Instance.new("Frame",hpGui)
hpFrame.Size=UDim2.new(0,180,0,14) hpFrame.Position=UDim2.new(0.5,-90,1,-60)
hpFrame.BackgroundColor3=Color3.fromRGB(20,5,5) hpFrame.BorderSizePixel=0
Instance.new("UICorner",hpFrame).CornerRadius=UDim.new(1,0)
local hpFill=Instance.new("Frame",hpFrame)
hpFill.BackgroundColor3=Color3.fromRGB(50,220,80) hpFill.BorderSizePixel=0
Instance.new("UICorner",hpFill).CornerRadius=UDim.new(1,0)
local hpText=Instance.new("TextLabel",hpFrame)
hpText.Size=UDim2.new(1,0,1,0) hpText.BackgroundTransparency=1
hpText.Font=Enum.Font.GothamBold hpText.TextSize=10 hpText.TextColor3=Color3.new(1,1,1)
hpText.TextStrokeTransparency=0 hpText.TextStrokeColor3=Color3.new(0,0,0)
RunService.Heartbeat:Connect(function()
    local hum=getHum() if not hum then return end
    local pct=math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1)
    hpFill.Size=UDim2.new(pct,0,1,0)
    hpFill.BackgroundColor3=pct>0.6 and Color3.fromRGB(50,220,80)
        or pct>0.3 and Color3.fromRGB(255,200,0) or Color3.fromRGB(255,50,50)
    hpText.Text="❤ "..math.floor(hum.Health)
end)

-- ════════════════════════════════════════════════════════════════
-- TROL v5 — дополнительные петли
-- ════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do task.wait(0.1)
        if not CFG.followVictim then continue end
        pcall(function()
            local hrp=getHRP() if not hrp then return end
            for _,p in ipairs(Players:GetPlayers()) do
                if p.Name==victimName and p.Character then
                    local t=p.Character:FindFirstChild("HumanoidRootPart")
                    if t then hrp.CFrame=t.CFrame*CFrame.new(0,0,2.2) end
                end
            end
        end)
    end
end)
task.spawn(function()
    while true do task.wait(0.08)
        if not CFG.blockVictim then continue end
        pcall(function()
            local hrp=getHRP() if not hrp then return end
            for _,p in ipairs(Players:GetPlayers()) do
                if p.Name==victimName and p.Character then
                    local t=p.Character:FindFirstChild("HumanoidRootPart")
                    if t then hrp.CFrame=CFrame.new(t.Position+t.CFrame.LookVector*2.5,t.Position) end
                end
            end
        end)
    end
end)
task.spawn(function()
    while true do task.wait(0.4)
        if not CFG.annoyMurd then continue end
        pcall(function()
            local hrp=getHRP() if not hrp then return end
            for _,p in ipairs(Players:GetPlayers()) do
                if p~=LP and getRole(p)=="Murderer" and p.Character then
                    local t=p.Character:FindFirstChild("HumanoidRootPart")
                    if t then hrp.CFrame=t.CFrame*CFrame.new(0,0,1) end
                end
            end
        end)
    end
end)

-- ════════════════════════════════════════════════════════════════
-- АВТОУВЕДОМЛЕНИЕ О УБИЙЦЕ
-- ════════════════════════════════════════════════════════════════
local lastMurd=""
task.spawn(function()
    while true do task.wait(3)
        pcall(function()
            for _,p in ipairs(Players:GetPlayers()) do
                if p~=LP and getRole(p)=="Murderer" and p.Name~=lastMurd then
                    lastMurd=p.Name
                    if CFG.esp then
                        game:GetService("StarterGui"):SetCore("SendNotification",
                            {Title="🔪 УБИЙЦА",Text=p.Name,Duration=5})
                    end
                end
            end
        end)
    end
end)

-- NOCLIP v2 — стабильный, без застревания
local noclipWasOn=false
local NOCLIP_SKIP={"HumanoidRootPart"} -- эти части НЕ трогаем при восстановлении
RunService.Stepped:Connect(function()
    if CFG.noclip then
        noclipWasOn=true
        local c=getChar() if not c then return end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=false end
        end
    elseif noclipWasOn then
        noclipWasOn=false
        pcall(function()
            local c=getChar() if not c then return end
            for _,p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then
                    local skip=false
                    for _,n in ipairs(NOCLIP_SKIP) do if p.Name==n then skip=true break end end
                    if not skip then p.CanCollide=true end
                end
            end
            -- Безопасный сброс позиции если под картой
            local hrp=getHRP()
            if hrp and hrp.Position.Y < -30 then
                task.wait(0.1)
                hrp.CFrame=CFrame.new(hrp.Position.X, 15, hrp.Position.Z)
            end
        end)
    end
end)

-- ════════════════════════════════════════
--   BYPASS v3 — МОЩНЫЙ АНТИКИК
-- ════════════════════════════════════════

-- Имитация движений мыши
task.spawn(function()
    while true do
        task.wait(math.random(8,18))
        if CFG.bypass then
            pcall(function()
                local vu=game:GetService("VirtualUser")
                local px,py=math.random(200,900),math.random(150,700)
                for _=1,math.random(2,5) do
                    vu:MoveMouse(Vector2.new(px+math.random(-40,40),py+math.random(-40,40)))
                    task.wait(math.random(1,3)/10)
                end
            end)
        end
    end
end)

-- Плавная смена скорости
task.spawn(function()
    while true do
        task.wait(math.random(20,40))
        if CFG.bypass then
            pcall(function()
                local h=getHum() if not h then return end
                local s=h.WalkSpeed
                for _=1,4 do h.WalkSpeed=math.random(12,18) task.wait(0.25) end
                if not CFG.speed then h.WalkSpeed=s end
            end)
        end
    end
end)

-- Паузы фарма (живой игрок)
task.spawn(function()
    while true do
        task.wait(math.random(25,55))
        if CFG.bypass and (CFG.coinFarm or CFG.bringCoins) then
            farmPaused=true
            task.wait(math.random(2,6))
            farmPaused=false
        end
    end
end)

-- Случайные прыжки
task.spawn(function()
    while true do
        task.wait(math.random(15,30))
        if CFG.bypass then pcall(function() local h=getHum() if h then h.Jump=true end end) end
    end
end)

-- ════════════════════════════════════════
--   COIN FARM — бежит к монете, ждёт сбора
-- ════════════════════════════════════════
-- ════════════════════════════════════════
--   COIN DETECTION v3 — ищем монеты правильно
-- ════════════════════════════════════════
local function isCoin(o)
    if not o or not o.Parent then return false end
    if not(o:IsA("BasePart") or o:IsA("MeshPart") or o:IsA("UnionOperation")) then return false end
    if o.Transparency >= 0.9 then return false end
    if o.Parent == LP.Character then return false end
    local n = o.Name:lower()
    return n=="coin" or n=="dropcoin" or n=="goldcoin" or n=="silvercoin"
        or n=="coinpart" or n=="coin_part" or n:sub(1,4)=="coin"
end

-- Метод 1: fireclickdetector (самый надёжный в MM2)
local function tryFireClick(obj)
    pcall(function()
        local cd = obj:FindFirstChildOfClass("ClickDetector")
        if cd then fireclickdetector(cd) return end
        if obj.Parent then
            local cd2 = obj.Parent:FindFirstChildOfClass("ClickDetector")
            if cd2 then fireclickdetector(cd2) end
        end
    end)
end

-- Метод 2: firetouchinterest (триггерим touch event)
local function tryTouchCoin(obj, hrp)
    pcall(function()
        firetouchinterest(hrp, obj, 0)
        task.wait(0.04)
        firetouchinterest(hrp, obj, 1)
    end)
end

task.spawn(function()
    while true do
        task.wait(0.08)
        if not CFG.coinFarm or farmPaused then continue end
        local hrp=getHRP() local hum=getHum()
        if not hrp or not hum or hum.Health<=0 then continue end

        -- Собираем все монеты
        local coins={}
        for _,o in ipairs(workspace:GetDescendants()) do
            if isCoin(o) then table.insert(coins,o) end
        end
        if #coins==0 then task.wait(0.5) continue end

        -- Выбираем ближайшую монету
        local target, bestDist=nil, math.huge
        for _,c in ipairs(coins) do
            local ok,dist=pcall(function() return (hrp.Position-c.Position).Magnitude end)
            if ok and dist<bestDist then bestDist=dist target=c end
        end
        if not target or not target.Parent then continue end

        local dist = (hrp.Position - target.Position).Magnitude

        if dist > 20 then
            -- Далеко — телепортируемся плавно через промежуточную точку
            pcall(function()
                local mid = (hrp.Position + target.Position)/2 + Vector3.new(0, 5, 0)
                hrp.CFrame = CFrame.new(mid)
                task.wait(0.08)
                hrp.CFrame = CFrame.new(target.Position)
            end)
        else
            -- Близко — просто бежим (WalkSpeed) чтобы выглядеть натурально
            hum.WalkSpeed = 50
            pcall(function() hum:MoveTo(target.Position) end)
            local t0 = tick()
            repeat task.wait(0.04) until
                not target or not target.Parent or
                (hrp.Position - target.Position).Magnitude < 3 or
                tick()-t0 > 2
            hum.WalkSpeed = 16
        end

        task.wait(0.04)

        -- Триггерим подбор несколько раз
        for _=1,4 do
            if not target or not target.Parent then break end
            tryFireClick(target)
            tryTouchCoin(target, hrp)
            pcall(function()
                if target.Parent and target.Parent~=workspace then
                    for _,p in ipairs(target.Parent:GetDescendants()) do
                        if p:IsA("BasePart") then
                            firetouchinterest(hrp, p, 0)
                            firetouchinterest(hrp, p, 1)
                        end
                    end
                end
            end)
            task.wait(0.03)
        end

        -- Небольшая пауза между монетами (выглядит как живой игрок)
        task.wait(math.random(5,15)/100)
    end
end)

task.spawn(function()
    while true do
        task.wait(0.15)
        if not CFG.bringCoins or farmPaused then continue end
        local hrp=getHRP() if not hrp then continue end
        for _,o in ipairs(workspace:GetDescendants()) do
            if isCoin(o) then pcall(function() o.CFrame=hrp.CFrame end) end
        end
    end
end)

-- Счётчик монет
task.spawn(function()
    local prev={}
    while task.wait(0.2) do
        if not CFG.coinFarm and not CFG.bringCoins then continue end
        for _,o in ipairs(workspace:GetDescendants()) do if isCoin(o) then prev[o]=true end end
        for obj in pairs(prev) do
            if not obj or not obj.Parent or obj.Transparency>=0.9 then coinCount=coinCount+1 prev[obj]=nil end
        end
    end
end)

-- KNIFE AURA
task.spawn(function()
    while task.wait(0.4) do
        if not CFG.knife then continue end
        local hum=getHum() local hrp=getHRP() if not hum or not hrp then continue end
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP and p.Character then
                local t=p.Character:FindFirstChild("HumanoidRootPart")
                local th=p.Character:FindFirstChildOfClass("Humanoid")
                if t and th and th.Health>0 and (hrp.Position-t.Position).Magnitude<=15 then hum:MoveTo(t.Position) end
            end
        end
    end
end)

-- AUTO REWARD
RunService.Heartbeat:Connect(function()
    if not CFG.autoReward then return end
    pcall(function()
        for _,g in ipairs(LP.PlayerGui:GetDescendants()) do
            if g:IsA("TextButton") then
                local t=g.Text:lower()
                if t:find("play") or t:find("vote") or t:find("again") or t:find("ok") or t:find("ready") then
                    pcall(function() g.MouseButton1Click:Fire() end)
                end
            end
        end
    end)
end)

-- FULLBRIGHT
local function setFB(v)
    if v then Lighting.Brightness=2.5 Lighting.ClockTime=14 Lighting.GlobalShadows=false Lighting.Ambient=Color3.new(1,1,1) Lighting.OutdoorAmbient=Color3.new(1,1,1)
    else Lighting.Brightness=1 Lighting.GlobalShadows=true Lighting.Ambient=Color3.fromRGB(127,127,127) Lighting.OutdoorAmbient=Color3.fromRGB(127,127,127) end
end

-- ESP
local ROLE_COLORS={Murderer=Color3.fromRGB(255,60,60),Sheriff=Color3.fromRGB(60,140,255),Innocent=Color3.fromRGB(60,230,110)}
local ROLE_LABELS={Murderer="🔪 УБИЙЦА",Sheriff="🔫 ШЕРИФ",Innocent="😇 НЕВИННЫЙ"}
local function getRole(player)
    local role="Innocent"
    pcall(function()
        local char=player.Character if not char then return end
        for _,item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") then
                local n=item.Name:lower()
                if n:find("knife") or n:find("murder") or n:find("blade") then role="Murderer" return
                elseif n:find("gun") or n:find("sheriff") or n:find("revolver") then role="Sheriff" return end
            end
        end
        local bp=player:FindFirstChild("Backpack")
        if bp then for _,item in ipairs(bp:GetChildren()) do if item:IsA("Tool") then
            local n=item.Name:lower()
            if n:find("knife") or n:find("murder") then role="Murderer" return
            elseif n:find("gun") or n:find("sheriff") then role="Sheriff" return end
        end end end
    end)
    return role
end
local function removeESP(p) if espObjects[p] then pcall(function() espObjects[p]:Destroy() end) espObjects[p]=nil end end
local function createESP(p)
    if p==LP then return end removeESP(p)
    local function setup(char)
        local hrp=char:WaitForChild("HumanoidRootPart",5)
        local hum=char:WaitForChild("Humanoid",5)
        if not hrp or not hum then return end
        local bb=Instance.new("BillboardGui") bb.Name="PTJESP" bb.AlwaysOnTop=true bb.Size=UDim2.new(0,120,0,70) bb.StudsOffset=Vector3.new(0,3.5,0) bb.Adornee=hrp bb.Parent=hrp bb.Enabled=false
        local nL=Instance.new("TextLabel",bb) nL.Size=UDim2.new(1,0,0,22) nL.BackgroundTransparency=1 nL.Font=Enum.Font.GothamBold nL.TextSize=13 nL.Text=p.Name nL.TextStrokeTransparency=0 nL.TextStrokeColor3=Color3.new(0,0,0)
        local rL=Instance.new("TextLabel",bb) rL.Size=UDim2.new(1,0,0,18) rL.Position=UDim2.new(0,0,0,22) rL.BackgroundTransparency=1 rL.Font=Enum.Font.GothamBold rL.TextSize=12 rL.TextStrokeTransparency=0 rL.TextStrokeColor3=Color3.new(0,0,0)
        local hL=Instance.new("TextLabel",bb) hL.Size=UDim2.new(1,0,0,14) hL.Position=UDim2.new(0,0,0,40) hL.BackgroundTransparency=1 hL.Font=Enum.Font.Code hL.TextSize=11 hL.TextColor3=Color3.fromRGB(200,200,200) hL.TextStrokeTransparency=0 hL.TextStrokeColor3=Color3.new(0,0,0)
        local dL=Instance.new("TextLabel",bb) dL.Size=UDim2.new(1,0,0,12) dL.Position=UDim2.new(0,0,0,54) dL.BackgroundTransparency=1 dL.Font=Enum.Font.Code dL.TextSize=10 dL.TextColor3=Color3.fromRGB(160,160,160) dL.TextStrokeTransparency=0 dL.TextStrokeColor3=Color3.new(0,0,0)
        local function upd()
            if not bb.Parent then return end
            local role=getRole(p) local col=ROLE_COLORS[role]
            nL.TextColor3=col rL.Text=ROLE_LABELS[role] rL.TextColor3=col
            hL.Text="❤ "..math.max(0,math.min(100,math.floor(hum.Health)))
            local myH=getHRP() if myH then dL.Text="📍 "..math.floor((myH.Position-hrp.Position).Magnitude).."st" end
            bb.Enabled=CFG.esp
        end
        hum:GetPropertyChangedSignal("Health"):Connect(function() pcall(upd) end)
        char.ChildAdded:Connect(function(ch) if ch:IsA("Tool") then task.wait(0.2) pcall(upd) end end)
        char.ChildRemoved:Connect(function(ch) if ch:IsA("Tool") then task.wait(0.2) pcall(upd) end end)
        RunService.Heartbeat:Connect(function() if bb and bb.Parent then bb.Enabled=CFG.esp end end)
        task.spawn(function() while bb and bb.Parent do pcall(upd) task.wait(1) end end)
        espObjects[p]=bb pcall(upd)
    end
    if p.Character then task.spawn(function() setup(p.Character) end) end
    p.CharacterAdded:Connect(function(c) task.wait(1) task.spawn(function() setup(c) end) end)
end
for _,p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(function(p) task.wait(1) createESP(p) end)
Players.PlayerRemoving:Connect(function(p) removeESP(p) end)

-- ════════════════════════════════════════════════════════════
--   ЗАСТАВКА v5.7 — ПОЛНЫЙ ЭКРАН
-- ════════════════════════════════════════════════════════════
if game.CoreGui:FindFirstChild("PTH57") then game.CoreGui.PTH57:Destroy() end
local sg=Instance.new("ScreenGui",game.CoreGui)
sg.Name="PTH57" sg.ResetOnSpawn=false sg.DisplayOrder=999 sg.IgnoreGuiInset=true

local BG    = Color3.fromRGB(10,10,12)
local SIDE  = Color3.fromRGB(14,14,17)
local CARD  = Color3.fromRGB(20,20,24)
local BORDER= Color3.fromRGB(38,38,46)
local RED   = Color3.fromRGB(215,25,25)
local WHITE = Color3.fromRGB(228,228,228)
local MUTED = Color3.fromRGB(85,85,95)
local DIM   = Color3.fromRGB(30,30,36)
local GREEN = Color3.fromRGB(0,215,100)
local GOLD  = Color3.fromRGB(243,156,18)
local PURPLE= Color3.fromRGB(120,60,200)

local function twQ(o,t,p) TweenService:Create(o,TweenInfo.new(t,Enum.EasingStyle.Quart),p):Play() end
local function twB(o,t,p) TweenService:Create(o,TweenInfo.new(t,Enum.EasingStyle.Back,Enum.EasingDirection.Out),p):Play() end

local Splash=Instance.new("Frame",sg)
Splash.Size=UDim2.new(1,0,1,0) Splash.Position=UDim2.new(0,0,0,0)
Splash.BackgroundColor3=Color3.fromRGB(2,2,8) Splash.BorderSizePixel=0 Splash.ZIndex=100

local bgGrad=Instance.new("UIGradient",Splash)
bgGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(2,2,15)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(5,3,20)),ColorSequenceKeypoint.new(1,Color3.fromRGB(3,2,12))})
bgGrad.Rotation=45

-- Звёзды
math.randomseed(42)
for i=1,120 do
    local star=Instance.new("Frame",Splash) local sz=math.random(1,3)
    star.Size=UDim2.new(0,sz,0,sz) star.Position=UDim2.new(math.random(0,100)/100,0,math.random(0,100)/100,0)
    star.BackgroundColor3=Color3.fromRGB(220+math.random(0,35),220+math.random(0,35),255) star.BorderSizePixel=0 star.ZIndex=101
    Instance.new("UICorner",star).CornerRadius=UDim.new(1,0)
    task.spawn(function() task.wait(math.random()*5) while star and star.Parent do TweenService:Create(star,TweenInfo.new(math.random(8,20)/10),{BackgroundTransparency=math.random(10,90)/100}):Play() task.wait(math.random(8,20)/10) end end)
end
for i=1,22 do
    local bs=Instance.new("TextLabel",Splash) bs.Size=UDim2.new(0,14,0,14) bs.Position=UDim2.new(math.random(1,99)/100,0,math.random(1,99)/100,0)
    bs.BackgroundTransparency=1 bs.Text=(i%2==0 and "✦" or "✧") bs.TextColor3=Color3.fromRGB(200+math.random(0,55),200+math.random(0,55),255)
    bs.Font=Enum.Font.GothamBold bs.TextSize=math.random(8,16) bs.TextTransparency=math.random(30,60)/100 bs.ZIndex=101
    task.spawn(function() task.wait(math.random()*4) while bs and bs.Parent do TweenService:Create(bs,TweenInfo.new(math.random(10,25)/10),{TextTransparency=0}):Play() task.wait(math.random(10,25)/10) TweenService:Create(bs,TweenInfo.new(math.random(10,25)/10),{TextTransparency=0.9}):Play() task.wait(math.random(10,25)/10) end end)
end

-- Солнечная система
local SX=0.5 local SY=0.38
local sunGlow=Instance.new("Frame",Splash) sunGlow.Size=UDim2.new(0,140,0,140) sunGlow.Position=UDim2.new(SX,-70,SY,-70) sunGlow.BackgroundColor3=Color3.fromRGB(255,160,0) sunGlow.BackgroundTransparency=1 sunGlow.BorderSizePixel=0 sunGlow.ZIndex=103
Instance.new("UICorner",sunGlow).CornerRadius=UDim.new(1,0)
local sun=Instance.new("Frame",Splash) sun.Size=UDim2.new(0,80,0,80) sun.Position=UDim2.new(SX,-40,SY,-40) sun.BackgroundColor3=Color3.fromRGB(255,200,30) sun.BorderSizePixel=0 sun.ZIndex=105
Instance.new("UICorner",sun).CornerRadius=UDim.new(1,0)
local sunGrad=Instance.new("UIGradient",sun) sunGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,240,100)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,120,0))}) sunGrad.Rotation=45
local sunIcon=Instance.new("TextLabel",sun) sunIcon.Size=UDim2.new(1,0,1,0) sunIcon.BackgroundTransparency=1 sunIcon.Text="☀" sunIcon.TextColor3=Color3.fromRGB(255,255,200) sunIcon.Font=Enum.Font.GothamBlack sunIcon.TextSize=44 sunIcon.ZIndex=106
task.spawn(function() while sunGlow and sunGlow.Parent do TweenService:Create(sunGlow,TweenInfo.new(1.4,Enum.EasingStyle.Sine),{BackgroundTransparency=0.45,Size=UDim2.new(0,160,0,160),Position=UDim2.new(SX,-80,SY,-80)}):Play() task.wait(1.4) TweenService:Create(sunGlow,TweenInfo.new(1.4,Enum.EasingStyle.Sine),{BackgroundTransparency=0.75,Size=UDim2.new(0,130,0,130),Position=UDim2.new(SX,-65,SY,-65)}):Play() task.wait(1.4) end end)

local planets={{name="Mercury",color=Color3.fromRGB(180,160,140),size=12,orbit=90,speed=4},{name="Venus",color=Color3.fromRGB(230,200,120),size=18,orbit=128,speed=7},{name="Earth",color=Color3.fromRGB(60,130,230),size=20,orbit=168,speed=10},{name="Mars",color=Color3.fromRGB(210,80,50),size=16,orbit=208,speed=14},{name="Jupiter",color=Color3.fromRGB(200,160,100),size=32,orbit=258,speed=22},{name="Saturn",color=Color3.fromRGB(220,190,130),size=26,orbit=304,speed=30},}
for _,pd in ipairs(planets) do
    local ring=Instance.new("Frame",Splash) ring.Size=UDim2.new(0,pd.orbit*2,0,pd.orbit*0.76) ring.Position=UDim2.new(SX,-pd.orbit,SY,-pd.orbit*0.38) ring.BackgroundTransparency=1 ring.BorderSizePixel=0 ring.ZIndex=102
    Instance.new("UICorner",ring).CornerRadius=UDim.new(1,0)
    local rs=Instance.new("UIStroke",ring) rs.Color=Color3.fromRGB(50,50,75) rs.Thickness=1 rs.Transparency=0.55
end
for i,pd in ipairs(planets) do
    local planet=Instance.new("Frame",Splash) planet.Size=UDim2.new(0,pd.size,0,pd.size) planet.BackgroundColor3=pd.color planet.BorderSizePixel=0 planet.ZIndex=106
    Instance.new("UICorner",planet).CornerRadius=UDim.new(1,0)
    local satRing=nil
    if pd.name=="Saturn" then satRing=Instance.new("Frame",Splash) satRing.Size=UDim2.new(0,pd.size+24,0,pd.size//3) satRing.BackgroundColor3=Color3.fromRGB(210,185,120) satRing.BackgroundTransparency=0.45 satRing.BorderSizePixel=0 satRing.ZIndex=105 Instance.new("UICorner",satRing).CornerRadius=UDim.new(1,0) end
    local pName=Instance.new("TextLabel",Splash) pName.Size=UDim2.new(0,60,0,12) pName.BackgroundTransparency=1 pName.Text=pd.name pName.TextColor3=Color3.fromRGB(130,130,160) pName.Font=Enum.Font.Code pName.TextSize=9 pName.ZIndex=107
    local startAngle=(i-1)*(math.pi*2/#planets)
    task.spawn(function()
        local elapsed=0
        while planet and planet.Parent do
            elapsed=elapsed+task.wait(0.033)
            local angle=startAngle+(elapsed/pd.speed)*math.pi*2
            local rx=math.cos(angle)*pd.orbit local ry=math.sin(angle)*pd.orbit*0.38
            planet.Position=UDim2.new(SX,rx-pd.size/2,SY,ry-pd.size/2)
            pName.Position=UDim2.new(SX,rx-30,SY,ry+pd.size/2+2)
            if satRing then local sh=pd.size//3 satRing.Position=UDim2.new(SX,rx-(pd.size+24)/2,SY,ry-sh/2) end
        end
    end)
end

-- Метеорит
task.spawn(function()
    while true do
        task.wait(math.random(25,55)/10)
        local sy=math.random(5,55)/100
        local m=Instance.new("Frame",Splash) m.Size=UDim2.new(0,5,0,5) m.Position=UDim2.new(-0.02,0,sy,0) m.BackgroundColor3=Color3.fromRGB(255,255,220) m.BorderSizePixel=0 m.ZIndex=108
        Instance.new("UICorner",m).CornerRadius=UDim.new(1,0)
        local tl=Instance.new("Frame",Splash) tl.Size=UDim2.new(0,40,0,2) tl.Position=UDim2.new(-0.06,0,sy,1) tl.BackgroundColor3=Color3.fromRGB(200,200,255) tl.BackgroundTransparency=0.4 tl.BorderSizePixel=0 tl.ZIndex=107
        local dur=math.random(15,25)/10
        TweenService:Create(m,TweenInfo.new(dur,Enum.EasingStyle.Linear),{Position=UDim2.new(1.05,0,sy+0.35,0),BackgroundTransparency=1}):Play()
        TweenService:Create(tl,TweenInfo.new(dur,Enum.EasingStyle.Linear),{Position=UDim2.new(1.02,0,sy+0.35,1),BackgroundTransparency=1}):Play()
        task.delay(dur,function() pcall(function() m:Destroy() tl:Destroy() end) end)
    end
end)

-- ЛОГОТИП по центру нижней части
local bigP=Instance.new("TextLabel",Splash) bigP.Size=UDim2.new(0,80,0,80) bigP.Position=UDim2.new(0.5,-195,0.7,-40) bigP.BackgroundTransparency=1 bigP.Text="Ᵽ" bigP.TextColor3=RED bigP.Font=Enum.Font.GothamBlack bigP.TextSize=80 bigP.TextTransparency=1 bigP.ZIndex=111 bigP.TextStrokeTransparency=0.2 bigP.TextStrokeColor3=Color3.fromRGB(255,80,80)
local nameLetters={"R","I","M","E","J","T","S","U"} local nameLabels={}
for i,l in ipairs(nameLetters) do
    local lb=Instance.new("TextLabel",Splash) lb.Size=UDim2.new(0,30,0,80) lb.Position=UDim2.new(0.5,-84+(i-1)*30,0.7,-40) lb.BackgroundTransparency=1 lb.Text=l lb.TextColor3=WHITE lb.Font=Enum.Font.GothamBlack lb.TextSize=56 lb.TextTransparency=1 lb.ZIndex=111
    table.insert(nameLabels,lb)
end
local underline=Instance.new("Frame",Splash) underline.Size=UDim2.new(0,0,0,2) underline.Position=UDim2.new(0.5,0,0.7,46) underline.BackgroundColor3=RED underline.BorderSizePixel=0 underline.ZIndex=111
local ulGrad=Instance.new("UIGradient",underline) ulGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,80,80)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(255,200,60)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,80,80))})
local byLine=Instance.new("TextLabel",Splash) byLine.Size=UDim2.new(0,320,0,18) byLine.Position=UDim2.new(0.5,-160,0.7,56) byLine.BackgroundTransparency=1 byLine.Text="by  @Primejtsu  •  MM2  •  v8.0" byLine.TextColor3=Color3.fromRGB(140,110,220) byLine.Font=Enum.Font.GothamBold byLine.TextSize=13 byLine.TextTransparency=1 byLine.ZIndex=111
local nazarLine=Instance.new("TextLabel",Splash) nazarLine.Size=UDim2.new(0,200,0,14) nazarLine.Position=UDim2.new(0.5,-100,0.7,78) nazarLine.BackgroundTransparency=1 nazarLine.Text="Nazar513000" nazarLine.TextColor3=Color3.fromRGB(100,100,150) nazarLine.Font=Enum.Font.Code nazarLine.TextSize=11 nazarLine.TextTransparency=1 nazarLine.ZIndex=111
local lbBG=Instance.new("Frame",Splash) lbBG.Size=UDim2.new(0.55,0,0,6) lbBG.Position=UDim2.new(0.225,0,0.7,106) lbBG.BackgroundColor3=Color3.fromRGB(20,15,40) lbBG.BorderSizePixel=0 lbBG.ZIndex=111
Instance.new("UICorner",lbBG).CornerRadius=UDim.new(1,0)
local lbFill=Instance.new("Frame",lbBG) lbFill.Size=UDim2.new(0,0,1,0) lbFill.BackgroundColor3=PURPLE lbFill.BorderSizePixel=0 lbFill.ZIndex=112
Instance.new("UICorner",lbFill).CornerRadius=UDim.new(1,0)
local loadTxt=Instance.new("TextLabel",Splash) loadTxt.Size=UDim2.new(0.55,0,0,14) loadTxt.Position=UDim2.new(0.225,0,0.7,92) loadTxt.BackgroundTransparency=1 loadTxt.Text="Primejtsu Hub загружается..." loadTxt.TextColor3=Color3.fromRGB(120,120,160) loadTxt.Font=Enum.Font.Code loadTxt.TextSize=10 loadTxt.TextTransparency=1 loadTxt.ZIndex=111

task.spawn(function()
    task.wait(0.5)
    sun.BackgroundTransparency=1 sunGlow.BackgroundTransparency=1 sunIcon.TextTransparency=1
    twQ(sun,0.8,{BackgroundTransparency=0}) twQ(sunGlow,0.8,{BackgroundTransparency=0.6}) twQ(sunIcon,0.6,{TextTransparency=0})
    task.wait(0.8) twB(bigP,0.55,{TextTransparency=0}) task.wait(0.1)
    for _,lb in ipairs(nameLabels) do task.wait(0.06) twB(lb,0.42,{TextTransparency=0}) end
    task.wait(0.5)
    TweenService:Create(underline,TweenInfo.new(0.6,Enum.EasingStyle.Quart),{Size=UDim2.new(0,340,0,2),Position=UDim2.new(0.5,-170,0.7,46)}):Play()
    task.wait(0.3) twQ(byLine,0.4,{TextTransparency=0}) task.wait(0.15) twQ(nazarLine,0.4,{TextTransparency=0})
    task.wait(0.3) twQ(loadTxt,0.3,{TextTransparency=0})
    local steps={{txt="🪐 Запуск орбит...",pct=0.12,wait=0.70},{txt="⭐ Загрузка звёзд...",pct=0.25,wait=0.65},{txt="🌍 Инициализация ESP...",pct=0.38,wait=0.72},{txt="☀ CoinFarm v5 готов...",pct=0.52,wait=0.68},{txt="🛡 Bypass v5 активирован...",pct=0.65,wait=0.70},{txt="🎯 Aimbot & SilentAim...",pct=0.78,wait=0.65},{txt="📡 Radar & BoxESP...",pct=0.90,wait=0.65},{txt="✨ Primejtsu Hub v8.0 готов!",pct=1.00,wait=0.60},}
    for i,s in ipairs(steps) do
        task.wait(s.wait) loadTxt.Text=s.txt
        TweenService:Create(lbFill,TweenInfo.new(0.5,Enum.EasingStyle.Quart),{Size=UDim2.new(s.pct,0,1,0)}):Play()
        if i==#steps then task.wait(0.2) loadTxt.TextColor3=GREEN TweenService:Create(lbFill,TweenInfo.new(0.35),{BackgroundColor3=GREEN}):Play() end
    end
    task.wait(0.8) twQ(Splash,0.6,{BackgroundTransparency=1})
    for _,o in ipairs(Splash:GetDescendants()) do
        if o:IsA("TextLabel") then twQ(o,0.35,{TextTransparency=1})
        elseif o:IsA("Frame") and o~=Splash then twQ(o,0.4,{BackgroundTransparency=1}) end
    end
    task.wait(0.8) Splash:Destroy() showGUI()
    task.wait(0.4)
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title="✅ Primejtsu Hub v8.0",Text="MEGA MOBILE | Fly|Aimbot|SilentAim|BoxESP|Radar 🪐 @Primejtsu",Duration=5}) end)
end)

-- ═══════════════════════════════════════════════════════════
showGUI = function()

local iconFrame=Instance.new("Frame",sg) iconFrame.Size=UDim2.new(0,46,0,46) iconFrame.Position=UDim2.new(1,-56,0.5,-23) iconFrame.BackgroundColor3=Color3.fromRGB(0,0,0) iconFrame.BorderSizePixel=0 iconFrame.ZIndex=50
Instance.new("UICorner",iconFrame).CornerRadius=UDim.new(0,12)
local iconBG=Instance.new("Frame",iconFrame) iconBG.Size=UDim2.new(1,0,1,0) iconBG.BackgroundColor3=RED iconBG.BorderSizePixel=0 iconBG.ZIndex=51
Instance.new("UICorner",iconBG).CornerRadius=UDim.new(0,12)
local iconBot=Instance.new("Frame",iconFrame) iconBot.Size=UDim2.new(1,0,0.35,0) iconBot.Position=UDim2.new(0,0,0.65,0) iconBot.BackgroundColor3=Color3.fromRGB(140,15,15) iconBot.BorderSizePixel=0 iconBot.ZIndex=52
Instance.new("UICorner",iconBot).CornerRadius=UDim.new(0,12)
local ibf=Instance.new("Frame",iconBot) ibf.Size=UDim2.new(1,0,0.5,0) ibf.BackgroundColor3=Color3.fromRGB(140,15,15) ibf.BorderSizePixel=0 ibf.ZIndex=52
local iconLetter=Instance.new("TextLabel",iconFrame) iconLetter.Size=UDim2.new(1,0,1,0) iconLetter.BackgroundTransparency=1 iconLetter.Text="Ᵽ" iconLetter.TextColor3=Color3.new(1,1,1) iconLetter.Font=Enum.Font.GothamBlack iconLetter.TextSize=26 iconLetter.ZIndex=53
local dotIcon=Instance.new("Frame",iconFrame) dotIcon.Size=UDim2.new(0,10,0,10) dotIcon.Position=UDim2.new(1,-3,0,-3) dotIcon.BackgroundColor3=GREEN dotIcon.BorderSizePixel=0 dotIcon.ZIndex=54
Instance.new("UICorner",dotIcon).CornerRadius=UDim.new(1,0) Instance.new("UIStroke",dotIcon).Color=Color3.fromRGB(0,0,0)
task.spawn(function() while sg and sg.Parent do TweenService:Create(dotIcon,TweenInfo.new(0.8),{BackgroundTransparency=0.6}):Play() task.wait(0.8) TweenService:Create(dotIcon,TweenInfo.new(0.8),{BackgroundTransparency=0}):Play() task.wait(0.8) end end)

local drag=false local dSt=nil local sSt=nil
iconFrame.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true dSt=i.Position sSt=iconFrame.Position end end)
iconFrame.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
UIS.InputChanged:Connect(function(i) if drag and(i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMove) then local d=i.Position-dSt iconFrame.Position=UDim2.new(sSt.X.Scale,sSt.X.Offset+d.X,sSt.Y.Scale,sSt.Y.Offset+d.Y) end end)

-- ГЛАВНОЕ ОКНО — компактный размер для мобилы (85% ширины, 72% высоты)
local W=Instance.new("Frame",sg)
W.Size=UDim2.new(0.85,0,0.72,0) W.Position=UDim2.new(0.075,0,0.14,0)
W.BackgroundColor3=BG W.BorderSizePixel=0 W.Active=true W.Draggable=true W.ClipsDescendants=true W.Visible=false
Instance.new("UICorner",W).CornerRadius=UDim.new(0,12)
Instance.new("UIStroke",W).Color=BORDER

local guiOpen=false local tS2=Vector2.new(0,0) local tT2=0
local function openGUI()
    guiOpen=true W.Visible=true W.Size=UDim2.new(0,0,0,0) W.Position=UDim2.new(0.5,0,0.5,0)
    TweenService:Create(W,TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0.85,0,0.72,0),Position=UDim2.new(0.075,0,0.14,0)}):Play()
    TweenService:Create(iconFrame,TweenInfo.new(0.2),{Size=UDim2.new(0,38,0,38)}):Play()
end
local function closeGUI()
    guiOpen=false
    TweenService:Create(W,TweenInfo.new(0.2,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0)}):Play()
    task.wait(0.25) W.Visible=false
    TweenService:Create(iconFrame,TweenInfo.new(0.2),{Size=UDim2.new(0,46,0,46)}):Play()
end
iconFrame.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then tS2=Vector2.new(i.Position.X,i.Position.Y) tT2=tick() end end)
iconFrame.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
        local dist=(Vector2.new(i.Position.X,i.Position.Y)-tS2).Magnitude
        if dist<10 and tick()-tT2<0.4 then if guiOpen then closeGUI() else openGUI() end end
    end
end)

-- ХЕДЕР 44px
local Hdr=Instance.new("Frame",W) Hdr.Size=UDim2.new(1,0,0,44) Hdr.BackgroundColor3=SIDE Hdr.BorderSizePixel=0
Instance.new("UICorner",Hdr).CornerRadius=UDim.new(0,12)
local hf=Instance.new("Frame",Hdr) hf.Size=UDim2.new(1,0,0.5,0) hf.Position=UDim2.new(0,0,0.5,0) hf.BackgroundColor3=SIDE hf.BorderSizePixel=0
local topLine=Instance.new("Frame",Hdr) topLine.Size=UDim2.new(1,0,0,2) topLine.BackgroundColor3=RED topLine.BorderSizePixel=0
local lp2=Instance.new("TextLabel",Hdr) lp2.Size=UDim2.new(0,26,0,36) lp2.Position=UDim2.new(0,12,0.5,-18) lp2.BackgroundTransparency=1 lp2.Text="Ᵽ" lp2.TextColor3=RED lp2.Font=Enum.Font.GothamBlack lp2.TextSize=26
local lr2=Instance.new("TextLabel",Hdr) lr2.Size=UDim2.new(0,130,0,36) lr2.Position=UDim2.new(0,36,0.5,-18) lr2.BackgroundTransparency=1 lr2.Text="RIMEJTSU" lr2.TextColor3=WHITE lr2.Font=Enum.Font.GothamBlack lr2.TextSize=18 lr2.TextXAlignment=Enum.TextXAlignment.Left
local ls2=Instance.new("TextLabel",Hdr) ls2.Size=UDim2.new(1,-200,0,14) ls2.Position=UDim2.new(0,12,1,-16) ls2.BackgroundTransparency=1 ls2.Text="MM2  •  v5.7  •  @Primejtsu 🪐" ls2.TextColor3=GREEN ls2.Font=Enum.Font.Code ls2.TextSize=10 ls2.TextXAlignment=Enum.TextXAlignment.Left
local xBtn=Instance.new("TextButton",Hdr) xBtn.Size=UDim2.new(0,28,0,28) xBtn.Position=UDim2.new(1,-36,0.5,-14) xBtn.BackgroundColor3=RED xBtn.Text="✕" xBtn.TextColor3=WHITE xBtn.Font=Enum.Font.GothamBold xBtn.TextSize=12 xBtn.BorderSizePixel=0
Instance.new("UICorner",xBtn).CornerRadius=UDim.new(0,7) xBtn.MouseButton1Click:Connect(closeGUI)

-- BODY — заполняет всё оставшееся место
local Body=Instance.new("Frame",W) Body.Size=UDim2.new(1,0,1,-44) Body.Position=UDim2.new(0,0,0,44) Body.BackgroundColor3=BG Body.BorderSizePixel=0
-- Боковая панель 96px
local SB=Instance.new("Frame",Body) SB.Size=UDim2.new(0,96,1,0) SB.BackgroundColor3=SIDE SB.BorderSizePixel=0
local sdiv=Instance.new("Frame",Body) sdiv.Size=UDim2.new(0,1,1,0) sdiv.Position=UDim2.new(0,96,0,0) sdiv.BackgroundColor3=BORDER sdiv.BorderSizePixel=0
-- Контент — полная высота, нет чёрного низа
local CT=Instance.new("ScrollingFrame",Body)
CT.Size=UDim2.new(1,-97,1,-50) CT.Position=UDim2.new(0,97,0,0)
CT.BackgroundColor3=BG CT.BackgroundTransparency=0 CT.BorderSizePixel=0
CT.ScrollBarThickness=0 CT.CanvasSize=UDim2.new(0,0,0,0)
CT.ScrollingDirection=Enum.ScrollingDirection.Y
CT.ScrollingEnabled=true

-- Кнопки ▲▼ внизу контентной зоны
local scrollBtns=Instance.new("Frame",Body)
scrollBtns.Size=UDim2.new(1,-97,0,46) scrollBtns.Position=UDim2.new(0,97,1,-46)
scrollBtns.BackgroundColor3=SIDE scrollBtns.BorderSizePixel=0
local sbDiv=Instance.new("Frame",scrollBtns) sbDiv.Size=UDim2.new(1,0,0,1) sbDiv.BackgroundColor3=BORDER sbDiv.BorderSizePixel=0

local btnUp=Instance.new("TextButton",scrollBtns)
btnUp.Size=UDim2.new(0.5,0,1,0) btnUp.Position=UDim2.new(0,0,0,0)
btnUp.BackgroundColor3=SIDE btnUp.BorderSizePixel=0
btnUp.Text="▲  Вверх" btnUp.TextColor3=MUTED btnUp.Font=Enum.Font.GothamBold btnUp.TextSize=13

local btnDown=Instance.new("TextButton",scrollBtns)
btnDown.Size=UDim2.new(0.5,0,1,0) btnDown.Position=UDim2.new(0.5,0,0,0)
btnDown.BackgroundColor3=SIDE btnDown.BorderSizePixel=0
btnDown.Text="▼  Вниз" btnDown.TextColor3=WHITE btnDown.Font=Enum.Font.GothamBold btnDown.TextSize=13

local divLine=Instance.new("Frame",scrollBtns) divLine.Size=UDim2.new(0,1,1,0) divLine.Position=UDim2.new(0.5,0,0,0) divLine.BackgroundColor3=BORDER divLine.BorderSizePixel=0

-- Холд для скролла (Touch + Mouse)
-- ═══ КНОПКИ СКРОЛЛ ═══
local scrolling=false
local function doScroll(dir)
    task.spawn(function()
        while scrolling do
            local maxY=math.max(0,CT.AbsoluteCanvasSize.Y-CT.AbsoluteSize.Y)
            CT.CanvasPosition=Vector2.new(0,math.clamp(CT.CanvasPosition.Y+dir*30,0,maxY))
            task.wait(0.04)
        end
    end)
end
local function stopScroll() scrolling=false end

btnUp.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
        scrolling=true doScroll(-1)
    end
end)
btnUp.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then stopScroll() end
end)
btnDown.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
        scrolling=true doScroll(1)
    end
end)
btnDown.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then stopScroll() end
end)

-- ═══ СВАЙП ПАЛЬЦЕМ ПО КОНТЕНТУ (главное для мобилы) ═══
local swipeStartY = 0
local swipeStartCanvas = 0
local isSwiping = false

CT.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch then
        isSwiping = true
        swipeStartY = i.Position.Y
        swipeStartCanvas = CT.CanvasPosition.Y
    end
end)
CT.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch and isSwiping then
        local delta = swipeStartY - i.Position.Y
        local maxY = math.max(0, CT.AbsoluteCanvasSize.Y - CT.AbsoluteSize.Y)
        CT.CanvasPosition = Vector2.new(0, math.clamp(swipeStartCanvas + delta, 0, maxY))
    end
end)
CT.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch then isSwiping = false end
end)

-- Подсветка кнопок
btnUp.MouseButton1Down:Connect(function() TweenService:Create(btnUp,TweenInfo.new(0.1),{BackgroundColor3=DIM}):Play() end)
btnUp.MouseButton1Up:Connect(function() TweenService:Create(btnUp,TweenInfo.new(0.1),{BackgroundColor3=SIDE}):Play() end)
btnDown.MouseButton1Down:Connect(function() TweenService:Create(btnDown,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(60,10,10)}):Play() end)
btnDown.MouseButton1Up:Connect(function() TweenService:Create(btnDown,TweenInfo.new(0.1),{BackgroundColor3=SIDE}):Play() end)
local CTL=Instance.new("UIListLayout",CT) CTL.Padding=UDim.new(0,5) CTL.SortOrder=Enum.SortOrder.LayoutOrder
local CTP=Instance.new("UIPadding",CT) CTP.PaddingLeft=UDim.new(0,10) CTP.PaddingRight=UDim.new(0,10) CTP.PaddingTop=UDim.new(0,8) CTP.PaddingBottom=UDim.new(0,8)
CTL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() CT.CanvasSize=UDim2.new(0,0,0,CTL.AbsoluteContentSize.Y+16) end)

local tabContent={} local tabBtns={}
local TABS={"Info","Player","God","Farm","Visual","Bypass","TP","Trol","Extra","Misc"}
for _,n in ipairs(TABS) do tabContent[n]={} end
Instance.new("UIListLayout",SB).Padding=UDim.new(0,0)
Instance.new("UIPadding",SB).PaddingTop=UDim.new(0,4)

local function makeSideBtn(label,icon)
    local b=Instance.new("TextButton",SB) b.Size=UDim2.new(1,0,0,40) b.BackgroundTransparency=1 b.Text="" b.BorderSizePixel=0
    local d=Instance.new("Frame",b) d.Size=UDim2.new(0,3,0,22) d.Position=UDim2.new(0,0,0.5,-11) d.BackgroundColor3=RED d.BorderSizePixel=0 d.Visible=false
    Instance.new("UICorner",d).CornerRadius=UDim.new(1,0)
    local il=Instance.new("TextLabel",b) il.Size=UDim2.new(0,20,1,0) il.Position=UDim2.new(0,10,0,0) il.BackgroundTransparency=1 il.Text=icon il.TextColor3=MUTED il.Font=Enum.Font.Gotham il.TextSize=14
    local l=Instance.new("TextLabel",b) l.Size=UDim2.new(1,-32,1,0) l.Position=UDim2.new(0,32,0,0) l.BackgroundTransparency=1 l.Text=label l.TextColor3=MUTED l.Font=Enum.Font.GothamBold l.TextSize=11 l.TextXAlignment=Enum.TextXAlignment.Left
    tabBtns[label]={btn=b,dot=d,lbl=l,ico=il} return b
end

local curFrames={}
local function switchTab(name)
    for _,f in ipairs(curFrames) do f.Parent=nil end curFrames={}
    for k,t in pairs(tabBtns) do t.dot.Visible=false t.lbl.TextColor3=MUTED t.ico.TextColor3=MUTED end
    if tabBtns[name] then tabBtns[name].dot.Visible=true tabBtns[name].lbl.TextColor3=WHITE tabBtns[name].ico.TextColor3=RED end
    if tabContent[name] then for _,f in ipairs(tabContent[name]) do f.Parent=CT table.insert(curFrames,f) end end
    task.wait() CT.CanvasSize=UDim2.new(0,0,0,CTL.AbsoluteContentSize.Y+16) CT.CanvasPosition=Vector2.new(0,0)
end

local tabIcons={Info="ℹ",Player="🏃",God="🛡",Farm="💰",Bypass="🔓",TP="📍",Trol="😈",Misc="⚙"}
for _,n in ipairs(TABS) do local b=makeSideBtn(n,tabIcons[n]) local nn=n b.MouseButton1Click:Connect(function() switchTab(nn) end) end

local function mkSec(tab,title)
    local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,22) f.BackgroundTransparency=1 f.BorderSizePixel=0
    local l=Instance.new("TextLabel",f) l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1 l.Text=title l.TextColor3=Color3.fromRGB(130,130,140) l.Font=Enum.Font.GothamBold l.TextSize=11 l.TextXAlignment=Enum.TextXAlignment.Left
    local line=Instance.new("Frame",f) line.Size=UDim2.new(1,0,0,1) line.Position=UDim2.new(0,0,1,-1) line.BackgroundColor3=BORDER line.BorderSizePixel=0
    table.insert(tabContent[tab],f)
end

local function mkToggle(tab,title,cfgKey,onFn)
    local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,40) f.BackgroundColor3=CARD f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,8) Instance.new("UIStroke",f).Color=BORDER
    local lbl=Instance.new("TextLabel",f) lbl.Size=UDim2.new(1,-58,1,0) lbl.Position=UDim2.new(0,12,0,0) lbl.BackgroundTransparency=1 lbl.Text=title lbl.TextColor3=WHITE lbl.Font=Enum.Font.Gotham lbl.TextSize=12 lbl.TextXAlignment=Enum.TextXAlignment.Left
    local track=Instance.new("Frame",f) track.Size=UDim2.new(0,40,0,22) track.Position=UDim2.new(1,-48,0.5,-11) track.BackgroundColor3=DIM track.BorderSizePixel=0
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    local circle=Instance.new("Frame",track) circle.Size=UDim2.new(0,16,0,16) circle.Position=UDim2.new(0,3,0.5,-8) circle.BackgroundColor3=MUTED circle.BorderSizePixel=0
    Instance.new("UICorner",circle).CornerRadius=UDim.new(1,0)
    local btn=Instance.new("TextButton",track) btn.Size=UDim2.new(1,0,1,0) btn.BackgroundTransparency=1 btn.Text=""
    local on=false
    btn.MouseButton1Click:Connect(function()
        on=not on
        local t2=TweenInfo.new(0.15)
        if on then TweenService:Create(track,t2,{BackgroundColor3=RED}):Play() TweenService:Create(circle,t2,{Position=UDim2.new(0,22,0.5,-8),BackgroundColor3=WHITE}):Play()
        else TweenService:Create(track,t2,{BackgroundColor3=DIM}):Play() TweenService:Create(circle,t2,{Position=UDim2.new(0,3,0.5,-8),BackgroundColor3=MUTED}):Play() end
        if cfgKey then CFG[cfgKey]=on end
        if onFn then onFn(on) end
    end)
    table.insert(tabContent[tab],f)
end

local function mkButton(tab,title,col,fn)
    local bc=col or DIM
    local f=Instance.new("Frame") f.Size=UDim2.new(1,0,0,40) f.BackgroundColor3=bc f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,8) Instance.new("UIStroke",f).Color=BORDER
    local b=Instance.new("TextButton",f) b.Size=UDim2.new(1,0,1,0) b.BackgroundTransparency=1 b.Text=title b.TextColor3=WHITE b.Font=Enum.Font.GothamBold b.TextSize=12 b.BorderSizePixel=0
    b.MouseButton1Click:Connect(function()
        TweenService:Create(f,TweenInfo.new(0.1),{BackgroundColor3=RED}):Play()
        task.wait(0.15) TweenService:Create(f,TweenInfo.new(0.1),{BackgroundColor3=bc}):Play()
        if fn then fn() end
    end)
    table.insert(tabContent[tab],f)
end

-- ══ INFO ══
mkSec("Info","Информация")
local ic=Instance.new("Frame") ic.Size=UDim2.new(1,0,0,90) ic.BackgroundColor3=CARD ic.BorderSizePixel=0
Instance.new("UICorner",ic).CornerRadius=UDim.new(0,8) Instance.new("UIStroke",ic).Color=BORDER
local irt=Instance.new("Frame",ic) irt.Size=UDim2.new(1,0,0,2) irt.BackgroundColor3=RED irt.BorderSizePixel=0
local _lp=Instance.new("TextLabel",ic) _lp.Size=UDim2.new(0,36,0,44) _lp.Position=UDim2.new(0,12,0.5,-22) _lp.BackgroundTransparency=1 _lp.Text="Ᵽ" _lp.TextColor3=RED _lp.Font=Enum.Font.GothamBlack _lp.TextSize=40
local _n1=Instance.new("TextLabel",ic) _n1.Size=UDim2.new(1,-60,0,18) _n1.Position=UDim2.new(0,54,0,12) _n1.BackgroundTransparency=1 _n1.Text="Primejtsu Hub" _n1.TextColor3=WHITE _n1.Font=Enum.Font.GothamBlack _n1.TextSize=17 _n1.TextXAlignment=Enum.TextXAlignment.Left
local _n2=Instance.new("TextLabel",ic) _n2.Size=UDim2.new(1,-60,0,14) _n2.Position=UDim2.new(0,54,0,33) _n2.BackgroundTransparency=1 _n2.Text="✈ @Primejtsu | Nazar513000" _n2.TextColor3=Color3.fromRGB(50,150,220) _n2.Font=Enum.Font.Code _n2.TextSize=12 _n2.TextXAlignment=Enum.TextXAlignment.Left
local _n3=Instance.new("TextLabel",ic) _n3.Size=UDim2.new(1,0,0,14) _n3.Position=UDim2.new(0,12,1,-17) _n3.BackgroundTransparency=1 _n3.Text="v8.0 | Fly|Aim|BoxESP|Radar|Chams 🪐" _n3.TextColor3=GREEN _n3.Font=Enum.Font.Code _n3.TextSize=10 _n3.TextXAlignment=Enum.TextXAlignment.Left
table.insert(tabContent["Info"],ic)

-- Счётчик монет
local cd=Instance.new("Frame") cd.Size=UDim2.new(1,0,0,34) cd.BackgroundColor3=CARD cd.BorderSizePixel=0
Instance.new("UICorner",cd).CornerRadius=UDim.new(0,8) Instance.new("UIStroke",cd).Color=BORDER
local cdl=Instance.new("TextLabel",cd) cdl.Size=UDim2.new(0.55,0,1,0) cdl.Position=UDim2.new(0,12,0,0) cdl.BackgroundTransparency=1 cdl.Text="💰 Монет собрано" cdl.TextColor3=MUTED cdl.Font=Enum.Font.Gotham cdl.TextSize=12 cdl.TextXAlignment=Enum.TextXAlignment.Left
local cdv=Instance.new("TextLabel",cd) cdv.Size=UDim2.new(0.4,0,1,0) cdv.Position=UDim2.new(0.58,0,0,0) cdv.BackgroundTransparency=1 cdv.Text="0" cdv.TextColor3=GOLD cdv.Font=Enum.Font.GothamBold cdv.TextSize=16 cdv.TextXAlignment=Enum.TextXAlignment.Right
table.insert(tabContent["Info"],cd)
RunService.Heartbeat:Connect(function() if cdv and cdv.Parent then cdv.Text=tostring(coinCount) end end)

-- Список игроков
mkSec("Info","Игроки в сервере")
local plInfoF=Instance.new("Frame") plInfoF.Size=UDim2.new(1,0,0,10) plInfoF.BackgroundTransparency=1 plInfoF.AutomaticSize=Enum.AutomaticSize.Y plInfoF.BorderSizePixel=0
Instance.new("UIListLayout",plInfoF).Padding=UDim.new(0,3)
table.insert(tabContent["Info"],plInfoF)
local function rebuildInfoPlayers()
    for _,ch in ipairs(plInfoF:GetChildren()) do if ch:IsA("Frame") then ch:Destroy() end end
    for _,p in ipairs(Players:GetPlayers()) do
        local pf=Instance.new("Frame",plInfoF) pf.Size=UDim2.new(1,0,0,30) pf.BackgroundColor3=CARD pf.BorderSizePixel=0
        Instance.new("UICorner",pf).CornerRadius=UDim.new(0,6) Instance.new("UIStroke",pf).Color=BORDER
        local role=getRole(p) local col=ROLE_COLORS[role]
        local acc=Instance.new("Frame",pf) acc.Size=UDim2.new(0,3,0.6,0) acc.Position=UDim2.new(0,0,0.2,0) acc.BackgroundColor3=col acc.BorderSizePixel=0
        Instance.new("UICorner",acc).CornerRadius=UDim.new(1,0)
        local nm=Instance.new("TextLabel",pf) nm.Size=UDim2.new(0.7,0,1,0) nm.Position=UDim2.new(0,12,0,0) nm.BackgroundTransparency=1
        nm.Text=(p==LP and "★ " or "")..p.Name nm.TextColor3=(p==LP and GOLD or WHITE) nm.Font=Enum.Font.GothamBold nm.TextSize=11 nm.TextXAlignment=Enum.TextXAlignment.Left
        local rl=Instance.new("TextLabel",pf) rl.Size=UDim2.new(0.28,0,1,0) rl.Position=UDim2.new(0.7,0,0,0) rl.BackgroundTransparency=1
        rl.Text=(role=="Murderer" and "🔪" or role=="Sheriff" and "🔫" or "😇") rl.Font=Enum.Font.GothamBold rl.TextSize=16
    end
end
task.spawn(function() while sg and sg.Parent do pcall(rebuildInfoPlayers) task.wait(3) end end)

-- ══ PLAYER ══
mkSec("Player","Движение")
mkToggle("Player","⚡ Speed Hack","speed")
mkToggle("Player","🐇 Bunny Hop","bhop")
mkToggle("Player","👻 Noclip v2","noclip")
mkToggle("Player","♾ Infinite Jump","infiniteJump")
mkToggle("Player","🕊 Fly Mode","fly",function(v) enableFly(v) end)
mkToggle("Player","🦘 Super Jump (JumpPower 200)","superJump")
mkToggle("Player","🌌 Low Gravity","lowGravity")
mkToggle("Player","🏃 Always Sprint","alwaysSprint")
mkButton("Player","💉 Восстановить HP",Color3.fromRGB(15,40,15),function()
    pcall(function() local h=getHum() if h then h.Health=h.MaxHealth end end)
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title="💉",Text="HP восстановлен",Duration=2}) end)
end)
mkButton("Player","📍 Мои координаты",DIM,function()
    pcall(function()
        local hrp=getHRP() if not hrp then return end
        local p=hrp.Position
        game:GetService("StarterGui"):SetCore("SendNotification",{Title="📍 Позиция",Text="X:"..math.floor(p.X).." Y:"..math.floor(p.Y).." Z:"..math.floor(p.Z),Duration=5})
    end)
end)
mkButton("Player","💾 Сохранить позицию",Color3.fromRGB(10,30,50),function()
    pcall(function()
        local hrp=getHRP() if not hrp then return end
        local p=hrp.Position
        table.insert(savedPositions,p)
        game:GetService("StarterGui"):SetCore("SendNotification",{Title="💾 Позиция #"..#savedPositions,Text=math.floor(p.X)..","..math.floor(p.Y)..","..math.floor(p.Z),Duration=3})
    end)
end)
mkButton("Player","📌 TP к позиции #1",Color3.fromRGB(10,30,50),function()
    pcall(function()
        local hrp=getHRP() if not hrp then return end
        if savedPositions[1] then hrp.CFrame=CFrame.new(savedPositions[1])
        else game:GetService("StarterGui"):SetCore("SendNotification",{Title="📌",Text="Нет сохранённых позиций",Duration=2}) end
    end)
end)

-- ══ GOD ══
mkSec("God","Защита")
mkToggle("God","❤ God Mode (1e9 HP)","god",function(v) applyGod(v) end)
mkToggle("God","🛡 Anti Knock","antiKnock")
mkToggle("God","🔫 Inf Ammo","infAmmo")
mkToggle("God","🌀 Spin Bot","spinBot")
mkToggle("God","🗿 Big Head","bigHead")
mkToggle("God","🙈 Hide Player","hide",function(v) hidePlayer(v) end)
mkButton("God","💀 Перезапустить персонажа",Color3.fromRGB(40,10,10),function()
    pcall(function() LP:LoadCharacter() end)
end)
mkButton("God","💉 Восстановить HP",Color3.fromRGB(15,40,15),function()
    pcall(function() local h=getHum() if h then h.Health=h.MaxHealth end end)
end)

-- ══ FARM ══
mkSec("Farm","💰 Монеты")
mkToggle("Farm","🪙 Coin Farm v5","coinFarm")
mkToggle("Farm","🧲 Bring Coins (монеты к тебе)","bringCoins")
mkToggle("Farm","🔪 Knife Aura","knife")
mkToggle("Farm","🎁 Auto Reward","autoReward")
mkSec("Farm","АФК")
mkToggle("Farm","💤 Anti AFK","antiAfk")
mkButton("Farm","🔄 Сбросить счётчик монет",DIM,function()
    coinCount=0
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title="🔄",Text="Счётчик монет сброшен",Duration=2}) end)
end)

-- ══ VISUAL ══
mkSec("Visual","ESP")
mkToggle("Visual","👁 ESP (роли+HP+дист)","esp")
mkToggle("Visual","📦 Box ESP","boxESP")
mkToggle("Visual","🎨 Chams (подсветка сквозь стены)","chams")
mkToggle("Visual","📏 Tracers (линии к игрокам)","tracers")
mkSec("Visual","Окружение")
mkToggle("Visual","☀ Fullbright","fullbright",function(v) setFB(v) end)
mkToggle("Visual","🌫 No Fog","noFog",function(v) setNoFog(v) end)
mkToggle("Visual","🧱 Wallhack (стены прозрачные)","wallhack",function(v) applyWallhack(v) end)
mkSec("Visual","Прочее")
mkToggle("Visual","📡 Radar (мини-карта)","radarOn")
mkToggle("Visual","🎯 Custom Crosshair","crosshair",function(v) toggleCrosshair(v) end)
mkButton("Visual","🔪 Кто убийца?",Color3.fromRGB(70,10,10),function()
    for _,p in ipairs(Players:GetPlayers()) do
        if getRole(p)=="Murderer" then
            pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title="🔪 УБИЙЦА",Text=p.Name,Duration=5}) end) return
        end
    end
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title="🔪",Text="Убийца не найден",Duration=2}) end)
end)
mkButton("Visual","🔫 Кто шериф?",Color3.fromRGB(10,20,70),function()
    for _,p in ipairs(Players:GetPlayers()) do
        if getRole(p)=="Sheriff" then
            pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title="🔫 ШЕРИФ",Text=p.Name,Duration=5}) end) return
        end
    end
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title="🔫",Text="Шериф не найден",Duration=2}) end)
end)
mkButton("Visual","🎭 Роли всех игроков",Color3.fromRGB(30,15,60),function()
    local m,s,inn={},{},{}
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP then local r=getRole(p)
            if r=="Murderer" then table.insert(m,p.Name)
            elseif r=="Sheriff" then table.insert(s,p.Name)
            else table.insert(inn,p.Name) end
        end
    end
    local txt=""
    if #m>0 then txt=txt.."🔪 "..table.concat(m,", ").." | " end
    if #s>0 then txt=txt.."🔫 "..table.concat(s,", ").." | " end
    if #inn>0 then txt=txt.."😇 "..table.concat(inn,", ") end
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title="👁 Роли",Text=txt,Duration=7}) end)
end)

-- ══ BYPASS ══
mkSec("Bypass","🔓 Antikick Bypass v5")
local bypassInfo=Instance.new("Frame") bypassInfo.Size=UDim2.new(1,0,0,82) bypassInfo.BackgroundColor3=Color3.fromRGB(18,10,6) bypassInfo.BorderSizePixel=0
Instance.new("UICorner",bypassInfo).CornerRadius=UDim.new(0,8) Instance.new("UIStroke",bypassInfo).Color=Color3.fromRGB(200,100,0)
local bypassTxt=Instance.new("TextLabel",bypassInfo) bypassTxt.Size=UDim2.new(1,-16,1,0) bypassTxt.Position=UDim2.new(0,8,0,0) bypassTxt.BackgroundTransparency=1
bypassTxt.Text="Bypass v5:\n• Имитация мыши и камеры (VirtualUser)\n• Паузы 2-6 сек каждые 28-55 сек\n• Случайные прыжки и движения\n• Плавная смена WalkSpeed"
bypassTxt.TextColor3=Color3.fromRGB(210,160,80) bypassTxt.Font=Enum.Font.Code bypassTxt.TextSize=10 bypassTxt.TextWrapped=true bypassTxt.TextXAlignment=Enum.TextXAlignment.Left bypassTxt.TextYAlignment=Enum.TextYAlignment.Top
table.insert(tabContent["Bypass"],bypassInfo)
mkToggle("Bypass","🛡 Bypass v5 (включай с фармом)","bypass")
mkToggle("Bypass","💤 Anti AFK","antiAfk")
mkSec("Bypass","Утилиты")
mkButton("Bypass","🔄 Перезапустить персонажа",Color3.fromRGB(25,25,55),function()
    pcall(function() LP:LoadCharacter() end)
end)
mkButton("Bypass","🧹 Стелс — выключить всё",Color3.fromRGB(20,45,20),function()
    CFG.coinFarm=false CFG.bringCoins=false CFG.knife=false CFG.speed=false CFG.bhop=false
    CFG.bypass=false CFG.esp=false CFG.chams=false CFG.tracers=false CFG.boxESP=false
    CFG.aimbot=false CFG.silentAim=false CFG.noclip=false CFG.fly=false
    CFG.spinBot=false CFG.bigHead=false CFG.wallhack=false
    enableFly(false) enableSilentAim(false) applyWallhack(false)
    pcall(function() local h=getHum() if h then h.WalkSpeed=16 h.JumpPower=50 end end)
    workspace.Gravity=196.2
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title="🧹 Стелс",Text="Все читы выключены",Duration=3}) end)
end)

-- ══ TP ══
mkSec("TP","Быстрый TP")
mkButton("TP","🔪 TP к Убийце",Color3.fromRGB(75,10,10),function()
    pcall(function() local hrp=getHRP() if not hrp then return end
        for _,p in ipairs(Players:GetPlayers()) do if p~=LP and getRole(p)=="Murderer" and p.Character then
            local t=p.Character:FindFirstChild("HumanoidRootPart") if t then hrp.CFrame=t.CFrame+Vector3.new(0,0,3) return end
        end end
    end)
end)
mkButton("TP","🔫 TP к Шерифу",Color3.fromRGB(10,25,75),function()
    pcall(function() local hrp=getHRP() if not hrp then return end
        for _,p in ipairs(Players:GetPlayers()) do if p~=LP and getRole(p)=="Sheriff" and p.Character then
            local t=p.Character:FindFirstChild("HumanoidRootPart") if t then hrp.CFrame=t.CFrame+Vector3.new(0,0,3) return end
        end end
    end)
end)
mkButton("TP","😇 TP к случайному",Color3.fromRGB(20,30,20),function()
    pcall(function()
        local hrp=getHRP() if not hrp then return end
        local others={}
        for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then table.insert(others,p) end end
        if #others==0 then return end
        local p=others[math.random(1,#others)]
        local t=p.Character:FindFirstChild("HumanoidRootPart")
        if t then hrp.CFrame=t.CFrame+Vector3.new(3,0,0) end
    end)
end)
mkButton("TP","🏠 TP к спавну",DIM,function()
    pcall(function() local hrp=getHRP() if hrp then hrp.CFrame=CFrame.new(0,10,0) end end)
end)
mkSec("TP","Игроки")
local plf=Instance.new("Frame") plf.Size=UDim2.new(1,0,0,10) plf.BackgroundTransparency=1 plf.BorderSizePixel=0 plf.AutomaticSize=Enum.AutomaticSize.Y
Instance.new("UIListLayout",plf).Padding=UDim.new(0,4)
table.insert(tabContent["TP"],plf)
local function rebuildPL()
    for _,ch in ipairs(plf:GetChildren()) do if ch:IsA("Frame") then ch:Destroy() end end
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local pf=Instance.new("Frame",plf) pf.Size=UDim2.new(1,0,0,34) pf.BackgroundColor3=CARD pf.BorderSizePixel=0
        Instance.new("UICorner",pf).CornerRadius=UDim.new(0,7) Instance.new("UIStroke",pf).Color=BORDER
        local role=getRole(p) local col=ROLE_COLORS[role]
        local acc=Instance.new("Frame",pf) acc.Size=UDim2.new(0,3,0.6,0) acc.Position=UDim2.new(0,0,0.2,0) acc.BackgroundColor3=col acc.BorderSizePixel=0
        Instance.new("UICorner",acc).CornerRadius=UDim.new(1,0)
        local nm=Instance.new("TextLabel",pf) nm.Size=UDim2.new(1,-70,1,0) nm.Position=UDim2.new(0,14,0,0) nm.BackgroundTransparency=1 nm.Text=p.Name nm.TextColor3=WHITE nm.Font=Enum.Font.GothamBold nm.TextSize=12 nm.TextXAlignment=Enum.TextXAlignment.Left
        local rt=Instance.new("TextLabel",pf) rt.Size=UDim2.new(0,55,1,0) rt.Position=UDim2.new(1,-57,0,0) rt.BackgroundTransparency=1 rt.Text=(role=="Murderer" and "🔪" or role=="Sheriff" and "🔫" or "😇") rt.Font=Enum.Font.GothamBold rt.TextSize=16
        local tb=Instance.new("TextButton",pf) tb.Size=UDim2.new(1,0,1,0) tb.BackgroundTransparency=1 tb.Text=""
        tb.MouseButton1Click:Connect(function()
            pcall(function() local hrp=getHRP() if not hrp or not p.Character then return end
                local t=p.Character:FindFirstChild("HumanoidRootPart") if not t then return end
                TweenService:Create(pf,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(60,10,10)}):Play()
                task.wait(0.15) TweenService:Create(pf,TweenInfo.new(0.1),{BackgroundColor3=CARD}):Play()
                hrp.CFrame=t.CFrame+Vector3.new(0,0,3)
            end)
        end)
    end
end
task.spawn(function() while sg and sg.Parent do pcall(rebuildPL) task.wait(3) end end)
Players.PlayerAdded:Connect(function() task.wait(1) pcall(rebuildPL) end)
Players.PlayerRemoving:Connect(function() task.wait(0.5) pcall(rebuildPL) end)

-- ══ TROL v5 ══
mkSec("Trol","😈 Выбери жертву")
local victimLabel=Instance.new("Frame") victimLabel.Size=UDim2.new(1,0,0,34) victimLabel.BackgroundColor3=CARD victimLabel.BorderSizePixel=0
Instance.new("UICorner",victimLabel).CornerRadius=UDim.new(0,8) Instance.new("UIStroke",victimLabel).Color=Color3.fromRGB(200,50,50)
local vl=Instance.new("TextLabel",victimLabel) vl.Size=UDim2.new(1,0,1,0) vl.BackgroundTransparency=1 vl.Text="😈 Жертва: "..victimName vl.TextColor3=Color3.fromRGB(255,80,80) vl.Font=Enum.Font.GothamBold vl.TextSize=12
table.insert(tabContent["Trol"],victimLabel)
local trollPLF=Instance.new("Frame") trollPLF.Size=UDim2.new(1,0,0,10) trollPLF.BackgroundTransparency=1 trollPLF.AutomaticSize=Enum.AutomaticSize.Y trollPLF.BorderSizePixel=0
Instance.new("UIListLayout",trollPLF).Padding=UDim.new(0,3)
table.insert(tabContent["Trol"],trollPLF)
local function rebuildTrollList()
    for _,ch in ipairs(trollPLF:GetChildren()) do if ch:IsA("Frame") then ch:Destroy() end end
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP then continue end
        local pf=Instance.new("Frame",trollPLF) pf.Size=UDim2.new(1,0,0,30) pf.BackgroundColor3=CARD pf.BorderSizePixel=0
        Instance.new("UICorner",pf).CornerRadius=UDim.new(0,7) Instance.new("UIStroke",pf).Color=BORDER
        local nm=Instance.new("TextLabel",pf) nm.Size=UDim2.new(1,-55,1,0) nm.Position=UDim2.new(0,10,0,0) nm.BackgroundTransparency=1 nm.Text=p.Name nm.TextColor3=WHITE nm.Font=Enum.Font.GothamBold nm.TextSize=11 nm.TextXAlignment=Enum.TextXAlignment.Left
        local selLbl=Instance.new("TextLabel",pf) selLbl.Size=UDim2.new(0,44,1,0) selLbl.Position=UDim2.new(1,-46,0,0) selLbl.BackgroundTransparency=1 selLbl.Text="▶ Выбрать" selLbl.TextColor3=Color3.fromRGB(255,100,100) selLbl.Font=Enum.Font.GothamBold selLbl.TextSize=9
        local tb=Instance.new("TextButton",pf) tb.Size=UDim2.new(1,0,1,0) tb.BackgroundTransparency=1 tb.Text=""
        tb.MouseButton1Click:Connect(function()
            victimName=p.Name vl.Text="😈 Жертва: "..victimName
            TweenService:Create(pf,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(60,10,10)}):Play()
            task.wait(0.2) TweenService:Create(pf,TweenInfo.new(0.1),{BackgroundColor3=CARD}):Play()
            pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title="😈",Text=p.Name.." — выбран жертвой",Duration=2}) end)
        end)
    end
end
task.spawn(function() while sg and sg.Parent do pcall(rebuildTrollList) task.wait(4) end end)
mkSec("Trol","Действия")
mkToggle("Trol","👣 Следить за жертвой","followVictim")
mkToggle("Trol","🚧 Блокировать путь жертве","blockVictim")
mkToggle("Trol","🔪 Мешать Убийце","annoyMurd")
mkButton("Trol","💢 TP прямо на жертву",Color3.fromRGB(80,10,10),function()
    pcall(function() local hrp=getHRP() if not hrp then return end
        for _,p in ipairs(Players:GetPlayers()) do if p.Name==victimName and p.Character then
            local t=p.Character:FindFirstChild("HumanoidRootPart") if t then hrp.CFrame=t.CFrame end
        end end
    end)
end)
mkButton("Trol","💥 Спам TP (4 сек)",Color3.fromRGB(60,10,10),function()
    task.spawn(function()
        for i=1,25 do task.wait(0.16)
            pcall(function() local hrp=getHRP() if not hrp then return end
                for _,p in ipairs(Players:GetPlayers()) do if p.Name==victimName and p.Character then
                    local t=p.Character:FindFirstChild("HumanoidRootPart")
                    if t then hrp.CFrame=t.CFrame*CFrame.new(math.random(-3,3),0,math.random(-3,3)) end
                end end
            end)
        end
    end)
end)
mkButton("Trol","🚀 Прыгнуть на жертву сверху",Color3.fromRGB(50,20,80),function()
    pcall(function() local hrp=getHRP() if not hrp then return end
        for _,p in ipairs(Players:GetPlayers()) do if p.Name==victimName and p.Character then
            local t=p.Character:FindFirstChild("HumanoidRootPart")
            if t then hrp.CFrame=CFrame.new(t.Position+Vector3.new(0,25,0)) hrp.Velocity=Vector3.new(0,-60,0) end
        end end
    end)
end)
mkButton("Trol","😤 Вплотную к жертве",Color3.fromRGB(40,20,5),function()
    pcall(function() local hrp=getHRP() if not hrp then return end
        for _,p in ipairs(Players:GetPlayers()) do if p.Name==victimName and p.Character then
            local t=p.Character:FindFirstChild("HumanoidRootPart")
            if t then hrp.CFrame=CFrame.new(t.Position+Vector3.new(0,0,0.8),t.Position) end
        end end
    end)
end)
mkButton("Trol","🌀 Фриз ESP жертвы",Color3.fromRGB(30,10,60),function()
    task.spawn(function()
        local hrp=getHRP() if not hrp then return end
        local orig=hrp.CFrame
        for i=1,40 do task.wait(0.05)
            pcall(function() hrp.CFrame=orig*CFrame.new(math.random(-50,50),math.random(-5,30),math.random(-50,50)) end)
        end task.wait(0.1) hrp.CFrame=orig
    end)
end)
mkButton("Trol","👁 Роль жертвы",Color3.fromRGB(20,30,60),function()
    for _,p in ipairs(Players:GetPlayers()) do if p.Name==victimName then
        local r=getRole(p)
        pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title="👁 "..victimName,Text=(r=="Murderer" and "🔪 УБИЙЦА!" or r=="Sheriff" and "🔫 ШЕРИФ!" or "😇 Невинный"),Duration=5}) end)
        return
    end end
end)
mkButton("Trol","🎭 Роли всех",Color3.fromRGB(30,20,60),function()
    local m,s,inn={},{},{}
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP then local r=getRole(p)
            if r=="Murderer" then table.insert(m,p.Name)
            elseif r=="Sheriff" then table.insert(s,p.Name)
            else table.insert(inn,p.Name) end
        end
    end
    local txt=""
    if #m>0 then txt=txt.."🔪 "..table.concat(m,", ").." | " end
    if #s>0 then txt=txt.."🔫 "..table.concat(s,", ").." | " end
    if #inn>0 then txt=txt.."😇 "..table.concat(inn,", ") end
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title="🎭 Роли",Text=txt,Duration=7}) end)
end)

-- ══ EXTRA (имба функции) ══
mkSec("Extra","🎯 Aimbot")
mkToggle("Extra","🎯 Aimbot v2 (автоприцел)","aimbot")
mkToggle("Extra","💀 Silent Aim (пуля в голову)","silentAim",function(v) enableSilentAim(v) end)
mkSec("Extra","💬 Чат")
mkToggle("Extra","💬 Chat Spy (видеть чужой чат)","chatSpy")
mkSec("Extra","👁 Дополнительно")
mkToggle("Extra","🌀 Spin Bot","spinBot")
mkToggle("Extra","🗿 Big Head","bigHead")
mkToggle("Extra","🙈 Hide Player","hide",function(v) hidePlayer(v) end)
mkButton("Extra","🔪 TP к убийце мгновенно",Color3.fromRGB(100,10,10),function()
    pcall(function() local hrp=getHRP() if not hrp then return end
        for _,p in ipairs(Players:GetPlayers()) do if p~=LP and getRole(p)=="Murderer" and p.Character then
            local t=p.Character:FindFirstChild("HumanoidRootPart") if t then hrp.CFrame=t.CFrame+Vector3.new(0,0,3) end
        end end
    end)
end)
mkButton("Extra","🔫 TP к шерифу мгновенно",Color3.fromRGB(10,10,100),function()
    pcall(function() local hrp=getHRP() if not hrp then return end
        for _,p in ipairs(Players:GetPlayers()) do if p~=LP and getRole(p)=="Sheriff" and p.Character then
            local t=p.Character:FindFirstChild("HumanoidRootPart") if t then hrp.CFrame=t.CFrame+Vector3.new(0,0,3) end
        end end
    end)
end)
mkButton("Extra","💣 Телепорт всех монет ко мне",Color3.fromRGB(40,30,0),function()
    pcall(function()
        local hrp=getHRP() if not hrp then return end
        for _,o in ipairs(workspace:GetDescendants()) do
            if isCoin(o) then pcall(function() o.CFrame=hrp.CFrame+Vector3.new(math.random(-3,3),0,math.random(-3,3)) end) end
        end
        game:GetService("StarterGui"):SetCore("SendNotification",{Title="💣",Text="Все монеты телепортированы к тебе!",Duration=3})
    end)
end)
mkButton("Extra","🌊 Гравитация 0 (левитация)",DIM,function()
    workspace.Gravity=0
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title="🌊",Text="Гравитация = 0",Duration=2}) end)
end)
mkButton("Extra","⬇ Гравитация норма",DIM,function()
    workspace.Gravity=196.2
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title="⬇",Text="Гравитация восстановлена",Duration=2}) end)
end)
mkButton("Extra","🌙 Ночь (ClockTime 0)",Color3.fromRGB(5,5,30),function()
    Lighting.ClockTime=0 Lighting.Brightness=0.5
end)
mkButton("Extra","☀ День (ClockTime 14)",Color3.fromRGB(30,25,5),function()
    Lighting.ClockTime=14 Lighting.Brightness=2
end)
mkButton("Extra","🔴 Красный туман",Color3.fromRGB(40,5,5),function()
    Lighting.FogStart=0 Lighting.FogEnd=80 Lighting.FogColor=Color3.fromRGB(180,0,0)
end)
mkButton("Extra","🧹 Стелс-режим (выкл всё)",Color3.fromRGB(20,45,20),function()
    CFG.coinFarm=false CFG.bringCoins=false CFG.knife=false CFG.speed=false CFG.bhop=false
    CFG.bypass=false CFG.esp=false CFG.chams=false CFG.tracers=false CFG.boxESP=false
    CFG.aimbot=false CFG.silentAim=false CFG.noclip=false CFG.fly=false
    CFG.spinBot=false CFG.bigHead=false CFG.wallhack=false CFG.radarOn=false
    enableFly(false) enableSilentAim(false) applyWallhack(false) toggleCrosshair(false)
    pcall(function() local h=getHum() if h then h.WalkSpeed=16 h.JumpPower=50 end end)
    workspace.Gravity=196.2
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title="🧹 Стелс",Text="Все читы выключены",Duration=3}) end)
end)

-- ══ MISC ══
mkSec("Misc","Разное")
mkToggle("Misc","☀ Fullbright","fullbright",function(v) setFB(v) end)
mkToggle("Misc","🌫 No Fog","noFog",function(v) setNoFog(v) end)
mkToggle("Misc","💤 Anti AFK","antiAfk")
mkButton("Misc","📋 Версия",DIM,function()
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title="Primejtsu Hub v8.0",Text="MEGA MOBILE | @Primejtsu | Nazar513000",Duration=4}) end)
end)
mkButton("Misc","🔄 Перезапустить",Color3.fromRGB(25,25,55),function()
    pcall(function() LP:LoadCharacter() end)
end)
mkButton("Misc","📍 Мои координаты",DIM,function()
    pcall(function()
        local hrp=getHRP() if not hrp then return end local p=hrp.Position
        game:GetService("StarterGui"):SetCore("SendNotification",{Title="📍 Позиция",Text="X:"..math.floor(p.X).." Y:"..math.floor(p.Y).." Z:"..math.floor(p.Z),Duration=5})
    end)
end)

task.wait(0.15)
switchTab("Info")

end -- showGUI

print("╔══════════════════════════════════════════╗")
print("║  Primejtsu Hub v8.0 | MEGA MOBILE        ║")
print("║  @Primejtsu | Nazar513000 | MM2 🪐       ║")
print("║  Fly|Aim|SilentAim|BoxESP|Radar|Chams    ║")
print("╚══════════════════════════════════════════╝")
