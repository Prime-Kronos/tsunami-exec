-- ================================================
--   Primejtsu X | Universal Script Edition
--   Rayfield GUI | 50 Functions
--   Creator: @Primejtsu
-- ================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")
local Camera           = workspace.CurrentCamera
local LP               = Players.LocalPlayer
local VIM              = game:GetService("VirtualInputManager")

-- ================================================
-- CONFIG
-- ================================================
local Cfg = {
    -- ESP
    ESPEnabled=false, ESPMode="Highlight", ESPColor=Color3.fromRGB(255,0,0), ESPTransp=0.5,
    NameESP=false, HealthBar=false, DistanceESP=false, BoxESP=false, TracerESP=false,
    -- Aim
    AimbotEnabled=false, AimbotSmooth=0.15, AimbotPart="Head",
    FOVEnabled=false, FOVRadius=150, FOVColor=Color3.fromRGB(255,255,255),
    -- Movement
    InfJump=false, SpeedEnabled=false, SpeedValue=40,
    FlyEnabled=false, FlySpeed=50,
    NoclipOn=false, NoFallOn=false, BunnyHop=false,
    LowGravity=false, HighJump=false, HighJumpPower=100,
    -- Player
    GodMode=false, InvisEnabled=false, InvisTransp=0.7,
    AntiRagdoll=false, InfStamina=false,
    -- World
    FullBright=false, NoFog=false, TimeOfDay=14,
    NoShadows=false, RainbowSky=false,
    -- Camera
    FovChanger=false, FovValue=70, ZoomEnabled=false, ZoomValue=50,
    -- Misc
    AntiAFK=false, ChatSpam=false, ChatMsg="Primejtsu X",
    WalkOnWater=false, AutoRespawn=false,
    -- UI
    CrosshairEnabled=false,
}

-- ================================================
-- CROSSHAIR (Drawing)
-- ================================================
local crosshairLines = {}
for i=1,4 do
    local l=Drawing.new("Line"); l.Visible=false; l.Color=Color3.fromRGB(255,255,255)
    l.Thickness=1.5; crosshairLines[i]=l
end

RunService.RenderStepped:Connect(function()
    local cx=Camera.ViewportSize.X/2
    local cy=Camera.ViewportSize.Y/2
    local size=10
    if Cfg.CrosshairEnabled then
        crosshairLines[1].From=Vector2.new(cx-size,cy); crosshairLines[1].To=Vector2.new(cx-3,cy); crosshairLines[1].Visible=true
        crosshairLines[2].From=Vector2.new(cx+3,cy);    crosshairLines[2].To=Vector2.new(cx+size,cy); crosshairLines[2].Visible=true
        crosshairLines[3].From=Vector2.new(cx,cy-size); crosshairLines[3].To=Vector2.new(cx,cy-3); crosshairLines[3].Visible=true
        crosshairLines[4].From=Vector2.new(cx,cy+3);    crosshairLines[4].To=Vector2.new(cx,cy+size); crosshairLines[4].Visible=true
    else for _,l in pairs(crosshairLines) do l.Visible=false end end
end)

-- ================================================
-- FOV
-- ================================================
local FOVDraw=Drawing.new("Circle")
FOVDraw.Visible=false; FOVDraw.Thickness=1.5; FOVDraw.Filled=false
FOVDraw.NumSides=128; FOVDraw.Radius=150; FOVDraw.Color=Color3.fromRGB(255,255,255)

-- ================================================
-- ESP
-- ================================================
local ESPObjects={}
local function clearESP(p)
    if not ESPObjects[p] then return end
    if ESPObjects[p].hl then ESPObjects[p].hl:Destroy() end
    if ESPObjects[p].box then for _,l in pairs(ESPObjects[p].box) do l:Remove() end end
    if ESPObjects[p].tr then ESPObjects[p].tr:Remove() end
    if ESPObjects[p].nm then ESPObjects[p].nm:Remove() end
    if ESPObjects[p].hb then ESPObjects[p].hb:Remove() end
    if ESPObjects[p].hbbg then ESPObjects[p].hbbg:Remove() end
    if ESPObjects[p].dist then ESPObjects[p].dist:Remove() end
    ESPObjects[p]=nil
end
local function applyESP(p)
    clearESP(p)
    if p==LP then return end
    local obj={}
    if Cfg.ESPEnabled then
        local hl=Instance.new("Highlight")
        hl.FillColor=Cfg.ESPColor; hl.OutlineColor=Cfg.ESPColor
        hl.FillTransparency=Cfg.ESPTransp
        hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
        if p.Character then hl.Parent=p.Character end
        p.CharacterAdded:Connect(function(c) hl.Parent=c end)
        obj.hl=hl
    end
    if Cfg.BoxESP then
        local lines={}
        for i=1,4 do local l=Drawing.new("Line");l.Visible=false;l.Color=Cfg.ESPColor;l.Thickness=1.5;lines[i]=l end
        obj.box=lines
    end
    if Cfg.TracerESP then
        local t=Drawing.new("Line");t.Visible=false;t.Color=Cfg.ESPColor;t.Thickness=1.5;obj.tr=t
    end
    if Cfg.NameESP then
        local n=Drawing.new("Text");n.Visible=false;n.Size=13;n.Center=true
        n.Outline=true;n.Color=Color3.fromRGB(255,255,255);obj.nm=n
    end
    if Cfg.HealthBar then
        local bg=Drawing.new("Line");bg.Visible=false;bg.Thickness=3;bg.Color=Color3.fromRGB(50,50,50);obj.hbbg=bg
        local b=Drawing.new("Line");b.Visible=false;b.Thickness=3;b.Color=Color3.fromRGB(0,255,80);obj.hb=b
    end
    if Cfg.DistanceESP then
        local d=Drawing.new("Text");d.Visible=false;d.Size=11;d.Center=true
        d.Outline=true;d.Color=Color3.fromRGB(200,200,200);obj.dist=d
    end
    ESPObjects[p]=obj
end
local function refreshESP() for _,p in pairs(Players:GetPlayers()) do applyESP(p) end end
Players.PlayerAdded:Connect(function(p) applyESP(p) end)
Players.PlayerRemoving:Connect(clearESP)

-- ================================================
-- GET TARGET
-- ================================================
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

-- ================================================
-- RENDER LOOP
-- ================================================
local hue=0
RunService.RenderStepped:Connect(function()
    hue=(hue+0.002)%1

    -- FOV
    FOVDraw.Visible=Cfg.FOVEnabled; FOVDraw.Radius=Cfg.FOVRadius; FOVDraw.Color=Cfg.FOVColor
    FOVDraw.Position=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)

    -- Rainbow sky
    if Cfg.RainbowSky then
        Lighting.Ambient=Color3.fromHSV(hue,0.6,1)
    end

    -- ESP render
    for p,obj in pairs(ESPObjects) do
        if p.Character then
            local root=p.Character:FindFirstChild("HumanoidRootPart")
            local hum2=p.Character:FindFirstChild("Humanoid")

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
                if vis then obj.tr.From=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y);obj.tr.To=Vector2.new(pos.X,pos.Y);obj.tr.Color=Cfg.ESPColor;obj.tr.Visible=true
                else obj.tr.Visible=false end
            end
            if obj.nm and root then
                local pos,vis=Camera:WorldToViewportPoint(root.Position+Vector3.new(0,2.5,0))
                if vis then obj.nm.Text=p.Name;obj.nm.Position=Vector2.new(pos.X,pos.Y);obj.nm.Visible=true
                else obj.nm.Visible=false end
            end
            if obj.hb and obj.hbbg and root and hum2 then
                local pos,vis=Camera:WorldToViewportPoint(root.Position)
                if vis then
                    local sz=2000/pos.Z;local x,y=pos.X,pos.Y;local h=sz*1.2
                    local hp=hum2.Health/hum2.MaxHealth
                    obj.hbbg.From=Vector2.new(x-sz*0.5-6,y-h);obj.hbbg.To=Vector2.new(x-sz*0.5-6,y+h);obj.hbbg.Visible=true
                    obj.hb.From=Vector2.new(x-sz*0.5-6,y+h);obj.hb.To=Vector2.new(x-sz*0.5-6,y+h-h*2*hp)
                    obj.hb.Color=Color3.fromRGB(math.floor(255*(1-hp)),math.floor(255*hp),0);obj.hb.Visible=true
                else obj.hb.Visible=false;obj.hbbg.Visible=false end
            end
            if obj.dist and root then
                local pos,vis=Camera:WorldToViewportPoint(root.Position+Vector3.new(0,-2.5,0))
                if vis and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                    local dist=math.floor((root.Position-LP.Character.HumanoidRootPart.Position).Magnitude)
                    obj.dist.Text=dist.."m";obj.dist.Position=Vector2.new(pos.X,pos.Y);obj.dist.Visible=true
                else obj.dist.Visible=false end
            end
        end
    end

    -- Aimbot
    if Cfg.AimbotEnabled then
        local t=getTarget()
        if t then Camera.CFrame=Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position,t.Position),Cfg.AimbotSmooth) end
    end

    -- God Mode
    if Cfg.GodMode and LP.Character then
        local h=LP.Character:FindFirstChild("Humanoid")
        if h and h.Health<h.MaxHealth then h.Health=h.MaxHealth end
    end

    -- Invisibility
    if LP.Character then
        for _,p in pairs(LP.Character:GetDescendants()) do
            if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
                p.LocalTransparencyModifier=Cfg.InvisEnabled and Cfg.InvisTransp or 0
            end
        end
    end

    -- FOV Changer
    if Cfg.FovChanger then Camera.FieldOfView=Cfg.FovValue end
end)

-- ================================================
-- FLY
-- ================================================
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

-- ================================================
-- HEARTBEAT LOOPS
-- ================================================
RunService.Heartbeat:Connect(function()
    if LP.Character then
        local h=LP.Character:FindFirstChild("Humanoid")
        if h then
            h.WalkSpeed=Cfg.SpeedEnabled and Cfg.SpeedValue or 16
            if Cfg.BunnyHop and h:GetState()==Enum.HumanoidStateType.Landed then
                h:ChangeState(Enum.HumanoidStateType.Jumping)
            end
            if Cfg.LowGravity then h.HipHeight=2 end
            if Cfg.InfStamina then h.JumpPower=50 end
            if Cfg.HighJump then h.JumpPower=Cfg.HighJumpPower end
        end
        -- Walk on water
        if Cfg.WalkOnWater then
            local root=LP.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local ray=Ray.new(root.Position,Vector3.new(0,-3,0))
                local hit,pos=workspace:FindPartOnRay(ray,LP.Character)
                if hit and hit.Name:lower():find("water") then
                    root.CFrame=CFrame.new(pos+Vector3.new(0,2.5,0))*root.CFrame.Rotation
                end
            end
        end
        -- Anti Ragdoll
        if Cfg.AntiRagdoll then
            local h2=LP.Character:FindFirstChild("Humanoid")
            if h2 and h2:GetState()==Enum.HumanoidStateType.FallingDown then
                h2:ChangeState(Enum.HumanoidStateType.GettingUp)
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

UserInputService.JumpRequest:Connect(function()
    if Cfg.InfJump and LP.Character then
        local h=LP.Character:FindFirstChild("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

LP.CharacterAdded:Connect(function(char)
    local h=char:WaitForChild("Humanoid")
    h.StateChanged:Connect(function(_,new)
        if Cfg.NoFallOn and new==Enum.HumanoidStateType.Freefall then
            h:ChangeState(Enum.HumanoidStateType.Running)
        end
    end)
    if Cfg.AutoRespawn then
        h.Died:Connect(function()
            task.wait(1)
            LP:LoadCharacter()
        end)
    end
    if Cfg.FlyEnabled then toggleFly(true) end
end)

-- World functions
local origFog=Lighting.FogEnd
local function setFullBright(on)
    Lighting.Brightness=on and 10 or 1;Lighting.ClockTime=14
    Lighting.GlobalShadows=not on
    Lighting.Ambient=on and Color3.fromRGB(255,255,255) or Color3.fromRGB(127,127,127)
end
local function setNoFog(on)
    Lighting.FogEnd=on and 100000 or origFog
    Lighting.FogStart=on and 99999 or 0
end

-- Chat spam
local chatSpamConn
local function toggleChatSpam(on)
    if chatSpamConn then chatSpamConn:Disconnect();chatSpamConn=nil end
    if on then
        chatSpamConn=RunService.Heartbeat:Connect(function()
            task.wait(3)
            game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
                and game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents
                :FindFirstChild("SayMessageRequest")
                and game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents
                .SayMessageRequest:FireServer(Cfg.ChatMsg,"All")
        end)
    end
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
local Window=Rayfield:CreateWindow({
    Name            = "Primejtsu X | Universal Script Edition",
    LoadingTitle    = "Primejtsu X",
    LoadingSubtitle = "Universal Edition — Loading 50 Functions...",
    Theme           = "Default",
    DisableRayfieldPrompts=false,
    DisableBuildWarnings=false,
})

-- ================================================
-- TAB 1: ESP (10 функций)
-- ================================================
local TabESP=Window:CreateTab("ESP", 4483362458)
TabESP:CreateSection("Player Visuals")

-- 1
TabESP:CreateToggle({Name="Enable ESP",CurrentValue=false,Flag="ESP",
    Callback=function(v) Cfg.ESPEnabled=v;refreshESP() end})
-- 2
TabESP:CreateToggle({Name="Box ESP",CurrentValue=false,Flag="BoxESP",
    Callback=function(v) Cfg.BoxESP=v;refreshESP() end})
-- 3
TabESP:CreateToggle({Name="Tracer ESP",CurrentValue=false,Flag="TracerESP",
    Callback=function(v) Cfg.TracerESP=v;refreshESP() end})
-- 4
TabESP:CreateToggle({Name="Name ESP",CurrentValue=false,Flag="NameESP",
    Callback=function(v) Cfg.NameESP=v;refreshESP() end})
-- 5
TabESP:CreateToggle({Name="Health Bar",CurrentValue=false,Flag="HealthBar",
    Callback=function(v) Cfg.HealthBar=v;refreshESP() end})
-- 6
TabESP:CreateToggle({Name="Distance ESP",CurrentValue=false,Flag="DistESP",
    Callback=function(v) Cfg.DistanceESP=v;refreshESP() end})
-- 7
TabESP:CreateDropdown({Name="ESP Color",
    Options={"Red","Green","Blue","Yellow","Purple","Cyan","White","Orange"},
    CurrentOption={"Red"},Flag="ESPColor",
    Callback=function(o)
        local c={Red=Color3.fromRGB(255,0,0),Green=Color3.fromRGB(0,255,0),Blue=Color3.fromRGB(0,100,255),
            Yellow=Color3.fromRGB(255,255,0),Purple=Color3.fromRGB(180,0,255),Cyan=Color3.fromRGB(0,255,255),
            White=Color3.fromRGB(255,255,255),Orange=Color3.fromRGB(255,140,0)}
        if c[o[1]] then Cfg.ESPColor=c[o[1]];refreshESP() end
    end})
-- 8
TabESP:CreateSlider({Name="Transparency",Range={0,10},Increment=1,CurrentValue=5,Flag="ESPTransp",
    Callback=function(v) Cfg.ESPTransp=v/10;refreshESP() end})
-- 9
TabESP:CreateToggle({Name="Crosshair",CurrentValue=false,Flag="Crosshair",
    Callback=function(v) Cfg.CrosshairEnabled=v end})
-- 10
TabESP:CreateToggle({Name="FOV Circle",CurrentValue=false,Flag="FOVCircle",
    Callback=function(v) Cfg.FOVEnabled=v end})

-- ================================================
-- TAB 2: Aimbot (8 функций)
-- ================================================
local TabAim=Window:CreateTab("Aimbot", 4483362458)
TabAim:CreateSection("Aim Settings")

-- 11
TabAim:CreateToggle({Name="Enable Aimbot",CurrentValue=false,Flag="Aimbot",
    Callback=function(v) Cfg.AimbotEnabled=v end})
-- 12
TabAim:CreateSlider({Name="FOV Radius",Range={30,500},Increment=5,CurrentValue=150,Flag="FOVRadius",
    Callback=function(v) Cfg.FOVRadius=v end})
-- 13
TabAim:CreateSlider({Name="Smoothness (lower=faster)",Range={1,100},Increment=1,CurrentValue=15,Flag="AimSmooth",
    Callback=function(v) Cfg.AimbotSmooth=v/100 end})
-- 14
TabAim:CreateDropdown({Name="Aim Part",
    Options={"Head","HumanoidRootPart","UpperTorso","Torso","RightArm","LeftArm"},
    CurrentOption={"Head"},Flag="AimPart",
    Callback=function(o) Cfg.AimbotPart=o[1] end})
-- 15
TabAim:CreateDropdown({Name="FOV Color",
    Options={"White","Yellow","Red","Green","Blue","Cyan","Purple"},
    CurrentOption={"White"},Flag="FOVColor",
    Callback=function(o)
        local c={White=Color3.fromRGB(255,255,255),Yellow=Color3.fromRGB(255,255,0),Red=Color3.fromRGB(255,0,0),
            Green=Color3.fromRGB(0,255,0),Blue=Color3.fromRGB(0,100,255),Cyan=Color3.fromRGB(0,255,255),Purple=Color3.fromRGB(150,80,255)}
        if c[o[1]] then Cfg.FOVColor=c[o[1]] end
    end})
-- 16
TabAim:CreateToggle({Name="Silent Aim (Camera snap on click)",CurrentValue=false,Flag="SilentAim",
    Callback=function(v)
        if v then
            UserInputService.InputBegan:Connect(function(inp,gpe)
                if gpe then return end
                if inp.UserInputType==Enum.UserInputType.MouseButton1 and v then
                    local t=getTarget()
                    if t then
                        local saved=Camera.CFrame
                        Camera.CFrame=CFrame.lookAt(Camera.CFrame.Position,t.Position)
                        task.defer(function() Camera.CFrame=saved end)
                    end
                end
            end)
        end
    end})
-- 17
TabAim:CreateSlider({Name="FOV Size",Range={30,500},Increment=5,CurrentValue=150,Flag="FOVSize2",
    Callback=function(v) Cfg.FOVRadius=v end})
-- 18
TabAim:CreateToggle({Name="Prediction Aim",CurrentValue=false,Flag="PredAim",
    Callback=function(v)
        if v then
            RunService.RenderStepped:Connect(function()
                if not v then return end
                local t=getTarget()
                if t and t.Parent then
                    local vel=t.AssemblyLinearVelocity or Vector3.new()
                    local predicted=t.Position+vel*0.1
                    Camera.CFrame=Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position,predicted),Cfg.AimbotSmooth)
                end
            end)
        end
    end})

-- ================================================
-- TAB 3: Movement (12 функций)
-- ================================================
local TabMove=Window:CreateTab("Movement", 4483362458)
TabMove:CreateSection("Player Movement")

-- 19
TabMove:CreateToggle({Name="Infinite Jump",CurrentValue=false,Flag="InfJump",
    Callback=function(v) Cfg.InfJump=v end})
-- 20
TabMove:CreateToggle({Name="Speed Hack",CurrentValue=false,Flag="Speed",
    Callback=function(v) Cfg.SpeedEnabled=v end})
-- 21
TabMove:CreateSlider({Name="Walk Speed",Range={16,300},Increment=1,CurrentValue=40,Flag="WalkSpeed",
    Callback=function(v) Cfg.SpeedValue=v end})
-- 22
TabMove:CreateToggle({Name="Fly (W/A/S/D + Space/Shift)",CurrentValue=false,Flag="Fly",
    Callback=function(v) Cfg.FlyEnabled=v;toggleFly(v) end})
-- 23
TabMove:CreateSlider({Name="Fly Speed",Range={10,300},Increment=5,CurrentValue=50,Flag="FlySpeed",
    Callback=function(v) Cfg.FlySpeed=v end})
-- 24
TabMove:CreateToggle({Name="Noclip",CurrentValue=false,Flag="Noclip",
    Callback=function(v) Cfg.NoclipOn=v end})
-- 25
TabMove:CreateToggle({Name="No Fall Damage",CurrentValue=false,Flag="NoFall",
    Callback=function(v) Cfg.NoFallOn=v end})
-- 26
TabMove:CreateToggle({Name="BunnyHop",CurrentValue=false,Flag="BHop",
    Callback=function(v) Cfg.BunnyHop=v end})
-- 27
TabMove:CreateToggle({Name="Low Gravity",CurrentValue=false,Flag="LowGrav",
    Callback=function(v)
        Cfg.LowGravity=v
        workspace.Gravity=v and 30 or 196.2
    end})
-- 28
TabMove:CreateToggle({Name="High Jump",CurrentValue=false,Flag="HighJump",
    Callback=function(v) Cfg.HighJump=v end})
-- 29
TabMove:CreateSlider({Name="Jump Power",Range={50,500},Increment=10,CurrentValue=100,Flag="JumpPower",
    Callback=function(v) Cfg.HighJumpPower=v end})
-- 30
TabMove:CreateToggle({Name="Walk on Water",CurrentValue=false,Flag="WalkWater",
    Callback=function(v) Cfg.WalkOnWater=v end})

-- ================================================
-- TAB 4: Player (8 функций)
-- ================================================
local TabPlayer=Window:CreateTab("Player", 4483362458)
TabPlayer:CreateSection("Player Settings")

-- 31
TabPlayer:CreateToggle({Name="God Mode (Infinite HP)",CurrentValue=false,Flag="GodMode",
    Callback=function(v) Cfg.GodMode=v end})
-- 32
TabPlayer:CreateToggle({Name="Invisibility",CurrentValue=false,Flag="Invis",
    Callback=function(v) Cfg.InvisEnabled=v end})
-- 33
TabPlayer:CreateSlider({Name="Invisibility Level",Range={0,10},Increment=1,CurrentValue=7,Flag="InvisLevel",
    Callback=function(v) Cfg.InvisTransp=v/10 end})
-- 34
TabPlayer:CreateToggle({Name="Anti Ragdoll",CurrentValue=false,Flag="AntiRag",
    Callback=function(v) Cfg.AntiRagdoll=v end})
-- 35
TabPlayer:CreateToggle({Name="Auto Respawn",CurrentValue=false,Flag="AutoResp",
    Callback=function(v) Cfg.AutoRespawn=v end})
-- 36
TabPlayer:CreateToggle({Name="Infinite Stamina",CurrentValue=false,Flag="InfStam",
    Callback=function(v) Cfg.InfStamina=v end})
-- 37
TabPlayer:CreateButton({Name="Teleport to Spawn",
    Callback=function()
        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            LP.Character.HumanoidRootPart.CFrame=CFrame.new(0,10,0)
        end
    end})
-- 38
TabPlayer:CreateButton({Name="Respawn Character",
    Callback=function()
        if LP.Character then
            local h=LP.Character:FindFirstChild("Humanoid");if h then h.Health=0 end
        end
    end})

-- ================================================
-- TAB 5: World (7 функций)
-- ================================================
local TabWorld=Window:CreateTab("World", 4483362458)
TabWorld:CreateSection("World Settings")

-- 39
TabWorld:CreateToggle({Name="Fullbright",CurrentValue=false,Flag="Fullbright",
    Callback=function(v) setFullBright(v) end})
-- 40
TabWorld:CreateToggle({Name="No Fog",CurrentValue=false,Flag="NoFog",
    Callback=function(v) setNoFog(v) end})
-- 41
TabWorld:CreateToggle({Name="No Shadows",CurrentValue=false,Flag="NoShadows",
    Callback=function(v) Lighting.GlobalShadows=not v end})
-- 42
TabWorld:CreateToggle({Name="Rainbow Sky",CurrentValue=false,Flag="RainbowSky",
    Callback=function(v) Cfg.RainbowSky=v end})
-- 43
TabWorld:CreateSlider({Name="Time of Day",Range={0,24},Increment=1,CurrentValue=14,Flag="TimeOfDay",
    Callback=function(v) Lighting.ClockTime=v end})
-- 44
TabWorld:CreateToggle({Name="FOV Changer",CurrentValue=false,Flag="FovChanger",
    Callback=function(v) Cfg.FovChanger=v; if not v then Camera.FieldOfView=70 end end})
-- 45
TabWorld:CreateSlider({Name="FOV Value",Range={30,120},Increment=1,CurrentValue=70,Flag="FovValue",
    Callback=function(v) Cfg.FovValue=v end})

-- ================================================
-- TAB 6: Misc (5 функций)
-- ================================================
local TabMisc=Window:CreateTab("Misc", 4483362458)
TabMisc:CreateSection("Miscellaneous")

-- 46
TabMisc:CreateToggle({Name="Anti-AFK",CurrentValue=false,Flag="AntiAFK",
    Callback=function(v) if v then startAntiAFK() end end})
-- 47
TabMisc:CreateToggle({Name="Chat Spam",CurrentValue=false,Flag="ChatSpam",
    Callback=function(v) Cfg.ChatSpam=v;toggleChatSpam(v) end})
-- 48
TabMisc:CreateButton({Name="Rejoin Server",
    Callback=function()
        game:GetService("TeleportService"):Teleport(game.PlaceId,LP)
    end})
-- 49
TabMisc:CreateButton({Name="Copy Join Script",
    Callback=function()
        Rayfield:Notify({
            Title="Join Script",
            Content='game:GetService("TeleportService"):TeleportToPlaceInstance("'..game.PlaceId..'","'..game.JobId..'")',
            Duration=6,Image=4483362458,
        })
    end})
-- 50
TabMisc:CreateButton({Name="Show Player List",
    Callback=function()
        local names={}
        for _,p in pairs(Players:GetPlayers()) do
            local hum=p.Character and p.Character:FindFirstChild("Humanoid")
            table.insert(names,p.Name.." [".. (hum and math.floor(hum.Health) or "?").."HP]")
        end
        Rayfield:Notify({
            Title="Players ("..#Players:GetPlayers()..")",
            Content=table.concat(names,"\n"),
            Duration=6,Image=4483362458,
        })
    end})

-- ================================================
-- ABOUT TAB
-- ================================================
local TabAbout=Window:CreateTab("About", 4483362458)
TabAbout:CreateSection("Primejtsu X | Universal Script")
TabAbout:CreateLabel("Creator: @Primejtsu")
TabAbout:CreateLabel("Version: v1.0 | 50 Functions")
TabAbout:CreateLabel("Works on any Roblox game!")
TabAbout:CreateSection("Support")
TabAbout:CreateButton({Name="Telegram: t.me/Primejtsu",
    Callback=function()
        Rayfield:Notify({Title="Telegram",Content="t.me/Primejtsu",Duration=4,Image=4483362458})
    end})

-- ================================================
-- STARTUP NOTIFICATION
-- ================================================
task.wait(0.5)
Rayfield:Notify({
    Title   = "Primejtsu X | Universal Script",
    Content = "Thank you for using us! | Спасибо что использовали нас!\n50 Functions loaded!",
    Duration = 6,
    Image   = 4483362458,
})

print("[Primejtsu X] Universal Script Edition — 50 Functions Loaded!")
