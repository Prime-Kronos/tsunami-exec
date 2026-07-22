-- ================================================
--   Primejtsu X | Flick Script
--   Custom GUI v3 - PJTSU Style
-- ================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Camera           = workspace.CurrentCamera
local LP               = Players.LocalPlayer

-- ================================================
-- SCRIPT CONFIG
-- ================================================
local Cfg = {
    ESPEnabled    = false, ESPMode = "Highlight",
    ESPFillColor  = Color3.fromRGB(255,0,0),
    ESPOutColor   = Color3.fromRGB(255,255,255),
    ESPTransp     = 0.5,
    FOVEnabled    = false, FOVRadius = 150,
    FOVColor      = Color3.fromRGB(255,255,255),
    AimbotEnabled = false, AimbotSmooth = 0.2, AimbotPart = "Head",
    InfJump       = false, SpeedEnabled = false, SpeedValue = 40,
    NoclipOn      = false, NoFallOn = false, FullBright = false,
}

-- ================================================
-- HELPERS
-- ================================================
local function tw(obj,props,t,style)
    TweenService:Create(obj,TweenInfo.new(t or 0.15, style or Enum.EasingStyle.Quad),props):Play()
end
local function corner(p,r) local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 8);c.Parent=p;return c end
local function stroke(p,col,t) local s=Instance.new("UIStroke");s.Color=col or Color3.fromRGB(60,65,90);s.Thickness=t or 1;s.Parent=p;return s end
local function newFrame(parent,size,pos,color,transp)
    local f=Instance.new("Frame")
    f.Size=size;f.Position=pos or UDim2.new(0,0,0,0)
    f.BackgroundColor3=color or Color3.fromRGB(25,25,35)
    f.BackgroundTransparency=transp or 0
    f.BorderSizePixel=0;f.Parent=parent;return f
end
local function newLabel(parent,text,size,color,font,pos,sz,xalign)
    local l=Instance.new("TextLabel")
    l.Text=text;l.TextSize=size or 14
    l.TextColor3=color or Color3.fromRGB(240,240,255)
    l.Font=font or Enum.Font.GothamBold
    l.BackgroundTransparency=1
    l.Position=pos or UDim2.new(0,0,0,0)
    l.Size=sz or UDim2.new(1,0,1,0)
    l.TextXAlignment=xalign or Enum.TextXAlignment.Left
    l.Parent=parent;return l
end

-- ================================================
-- FOV + ESP + AIM LOGIC
-- ================================================
local FOVDraw=Drawing.new("Circle")
FOVDraw.Visible=false;FOVDraw.Thickness=1.5;FOVDraw.Filled=false
FOVDraw.NumSides=128;FOVDraw.Radius=150;FOVDraw.Color=Color3.fromRGB(255,255,255)

local ESPObjects={}
local function clearESP(p)
    if not ESPObjects[p] then return end
    if ESPObjects[p].hl then ESPObjects[p].hl:Destroy() end
    if ESPObjects[p].box then for _,l in pairs(ESPObjects[p].box) do l:Remove() end end
    if ESPObjects[p].tr then ESPObjects[p].tr:Remove() end
    ESPObjects[p]=nil
end
local function applyESP(p)
    clearESP(p)
    if not Cfg.ESPEnabled or p==LP then return end
    if Cfg.ESPMode=="Highlight" then
        local hl=Instance.new("Highlight")
        hl.FillColor=Cfg.ESPFillColor;hl.OutlineColor=Cfg.ESPOutColor
        hl.FillTransparency=Cfg.ESPTransp
        hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
        if p.Character then hl.Parent=p.Character end
        p.CharacterAdded:Connect(function(c) hl.Parent=c end)
        ESPObjects[p]={hl=hl}
    elseif Cfg.ESPMode=="Box" then
        local lines={}
        for i=1,4 do local l=Drawing.new("Line");l.Visible=false;l.Color=Cfg.ESPFillColor;l.Thickness=1.5;lines[i]=l end
        ESPObjects[p]={box=lines}
    elseif Cfg.ESPMode=="Tracer" then
        local t=Drawing.new("Line");t.Visible=false;t.Color=Cfg.ESPFillColor;t.Thickness=1.5
        ESPObjects[p]={tr=t}
    end
end
local function refreshESP() for _,p in pairs(Players:GetPlayers()) do applyESP(p) end end
Players.PlayerAdded:Connect(function(p) if Cfg.ESPEnabled then applyESP(p) end end)
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
    FOVDraw.Visible=Cfg.FOVEnabled;FOVDraw.Radius=Cfg.FOVRadius;FOVDraw.Color=Cfg.FOVColor
    FOVDraw.Position=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
    for p,obj in pairs(ESPObjects) do
        if p.Character then
            local root=p.Character:FindFirstChild("HumanoidRootPart")
            if obj.box and root then
                local pos,vis=Camera:WorldToViewportPoint(root.Position)
                if vis then
                    local sz=2000/pos.Z;local x,y=pos.X,pos.Y;local w,h=sz*0.4,sz*1.2
                    local c={{Vector2.new(x-w,y-h),Vector2.new(x+w,y-h)},{Vector2.new(x-w,y+h),Vector2.new(x+w,y+h)},{Vector2.new(x-w,y-h),Vector2.new(x-w,y+h)},{Vector2.new(x+w,y-h),Vector2.new(x+w,y+h)}}
                    for i,v in ipairs(c) do obj.box[i].From=v[1];obj.box[i].To=v[2];obj.box[i].Color=Cfg.ESPFillColor;obj.box[i].Visible=true end
                else for _,l in pairs(obj.box) do l.Visible=false end end
            end
            if obj.tr and root then
                local pos,vis=Camera:WorldToViewportPoint(root.Position)
                if vis then obj.tr.From=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y);obj.tr.To=Vector2.new(pos.X,pos.Y);obj.tr.Color=Cfg.ESPFillColor;obj.tr.Visible=true
                else obj.tr.Visible=false end
            end
        end
    end
    if Cfg.AimbotEnabled then
        local t=getTarget()
        if t then Camera.CFrame=Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position,t.Position),Cfg.AimbotSmooth) end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Cfg.InfJump and LP.Character then
        local h=LP.Character:FindFirstChild("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)
RunService.Heartbeat:Connect(function()
    if LP.Character then
        local h=LP.Character:FindFirstChild("Humanoid")
        if h then h.WalkSpeed=Cfg.SpeedEnabled and Cfg.SpeedValue or 16 end
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
        if Cfg.NoFallOn and new==Enum.HumanoidStateType.Freefall then h:ChangeState(Enum.HumanoidStateType.Running) end
    end)
end)
local Lighting=game:GetService("Lighting")
local function setFullBright(on)
    Lighting.Brightness=on and 10 or 1;Lighting.ClockTime=14
    Lighting.GlobalShadows=not on
    Lighting.Ambient=on and Color3.fromRGB(255,255,255) or Color3.fromRGB(127,127,127)
end

-- ================================================
-- GUI BUILD
-- ================================================
local ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name="PrimejtsuX";ScreenGui.ResetOnSpawn=false
ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
ScreenGui.Parent=LP.PlayerGui

-- ================================================
-- LOADING SCREEN
-- ================================================
local LoadBG=newFrame(ScreenGui,UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),Color3.fromRGB(10,10,16))
local LoadTitle=newLabel(LoadBG,"Primejtsu X | Project",26,Color3.fromRGB(255,255,255),Enum.Font.GothamBold,
    UDim2.new(0,0,0.38,0),UDim2.new(1,0,0,40),Enum.TextXAlignment.Center)
local LoadSub=newLabel(LoadBG,"Flick Script — Loading...",14,Color3.fromRGB(160,140,220),Enum.Font.Gotham,
    UDim2.new(0,0,0.5,0),UDim2.new(1,0,0,24),Enum.TextXAlignment.Center)

-- Loading bar
local LoadBarBG=newFrame(LoadBG,UDim2.new(0,300,0,4),UDim2.new(0.5,-150,0.6,0),Color3.fromRGB(30,30,45))
corner(LoadBarBG,2)
local LoadBar=newFrame(LoadBarBG,UDim2.new(0,0,1,0),UDim2.new(0,0,0,0),Color3.fromRGB(120,80,255))
corner(LoadBar,2)

-- Animate loading bar
task.spawn(function()
    tw(LoadBar,{Size=UDim2.new(1,0,1,0)},1.5,Enum.EasingStyle.Quad)
    task.wait(1.6)
    tw(LoadBG,{BackgroundTransparency=1},0.4)
    tw(LoadTitle,{TextTransparency=1},0.4)
    tw(LoadSub,{TextTransparency=1},0.4)
    tw(LoadBarBG,{BackgroundTransparency=1},0.4)
    tw(LoadBar,{BackgroundTransparency=1},0.4)
    task.wait(0.45)
    LoadBG:Destroy()
end)

-- ================================================
-- TOP TOGGLE BAR
-- ================================================
local TopBar=newFrame(ScreenGui,UDim2.new(0,200,0,30),UDim2.new(0.5,-100,0,0),Color3.fromRGB(18,20,28))
corner(TopBar,10)
stroke(TopBar,Color3.fromRGB(55,55,80),1)

local TopBtn=Instance.new("TextButton")
TopBtn.Size=UDim2.new(1,0,1,0);TopBtn.BackgroundTransparency=1
TopBtn.Text="✦ Primejtsu X | Project ✦"
TopBtn.TextColor3=Color3.fromRGB(200,180,255)
TopBtn.Font=Enum.Font.GothamBold;TopBtn.TextSize=12
TopBtn.Parent=TopBar

-- RGB on TopBar stroke
local rgbStroke=stroke(TopBar,Color3.fromRGB(120,80,255),1.5)
local hue=0
RunService.Heartbeat:Connect(function()
    hue=(hue+0.003)%1
    rgbStroke.Color=Color3.fromHSV(hue,0.7,1)
end)

-- ================================================
-- MAIN WINDOW
-- ================================================
local Main=newFrame(ScreenGui,UDim2.new(0,600,0,420),UDim2.new(0.5,-300,0.5,-210),Color3.fromRGB(20,22,30))
corner(Main,14)
stroke(Main,Color3.fromRGB(50,50,75),1)

-- RGB border on main
local mainStroke=stroke(Main,Color3.fromRGB(120,80,255),1.5)
RunService.Heartbeat:Connect(function()
    mainStroke.Color=Color3.fromHSV(hue,0.7,1)
end)

-- Toggle
local guiOpen=true
TopBtn.MouseButton1Click:Connect(function()
    guiOpen=not guiOpen
    if guiOpen then
        Main.Visible=true
        tw(Main,{Size=UDim2.new(0,600,0,420)},0.2,Enum.EasingStyle.Back)
    else
        tw(Main,{Size=UDim2.new(0,600,0,0)},0.15)
        task.delay(0.16,function() Main.Visible=false end)
    end
end)

-- Drag
local drag,dragStart,startPos=false,nil,nil
Main.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        drag=true;dragStart=i.Position;startPos=Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        local d=i.Position-dragStart
        Main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
end)

-- ================================================
-- SIDEBAR (Left panel like screenshot)
-- ================================================
local Sidebar=newFrame(Main,UDim2.new(0,170,1,0),UDim2.new(0,0,0,0),Color3.fromRGB(15,16,24))
corner(Sidebar,14)
-- fix right corners
newFrame(Sidebar,UDim2.new(0,14,1,0),UDim2.new(1,-14,0,0),Color3.fromRGB(15,16,24))

-- Logo
local LogoBG=newFrame(Sidebar,UDim2.new(0,64,0,64),UDim2.new(0.5,-32,0,18),Color3.fromRGB(25,25,38))
corner(LogoBG,32)
stroke(LogoBG,Color3.fromRGB(80,60,140),1.5)
-- Rabbit logo image (using decal id for rabbit)
local LogoImg=Instance.new("ImageLabel")
LogoImg.Size=UDim2.new(0,64,0,64)
LogoImg.BackgroundTransparency=1
LogoImg.Image="rbxassetid://7072725450" -- white rabbit icon
LogoImg.ImageColor3=Color3.fromRGB(255,255,255)
LogoImg.ScaleType=Enum.ScaleType.Fit
LogoImg.Parent=LogoBG

newLabel(Sidebar,"PJTSU X",13,Color3.fromRGB(220,210,255),Enum.Font.GothamBold,
    UDim2.new(0,0,0,88),UDim2.new(1,0,0,20),Enum.TextXAlignment.Center)
newLabel(Sidebar,"Flick Script",10,Color3.fromRGB(120,110,160),Enum.Font.Gotham,
    UDim2.new(0,0,0,106),UDim2.new(1,0,0,16),Enum.TextXAlignment.Center)

-- Divider
local div=newFrame(Sidebar,UDim2.new(0.7,0,0,1),UDim2.new(0.15,0,0,128),Color3.fromRGB(50,50,75))

-- Tab buttons
local TabContainer=newFrame(Sidebar,UDim2.new(1,0,1,-136),UDim2.new(0,0,0,136),Color3.fromRGB(0,0,0),1)
local TabLayout=Instance.new("UIListLayout")
TabLayout.Padding=UDim.new(0,3);TabLayout.Parent=TabContainer
local TabPad=Instance.new("UIPadding")
TabPad.PaddingLeft=UDim.new(0,10);TabPad.PaddingRight=UDim.new(0,10);TabPad.PaddingTop=UDim.new(0,6)
TabPad.Parent=TabContainer

-- ================================================
-- CONTENT AREA
-- ================================================
local ContentBG=newFrame(Main,UDim2.new(1,-170,1,0),UDim2.new(0,170,0,0),Color3.fromRGB(0,0,0),1)

local ContentTitle=newLabel(ContentBG,"ESP",20,Color3.fromRGB(230,220,255),Enum.Font.GothamBold,
    UDim2.new(0,16,0,14),UDim2.new(1,-20,0,30))

local ContentScroll=Instance.new("ScrollingFrame")
ContentScroll.Size=UDim2.new(1,-16,1,-56)
ContentScroll.Position=UDim2.new(0,8,0,50)
ContentScroll.BackgroundTransparency=1
ContentScroll.ScrollBarThickness=2
ContentScroll.ScrollBarImageColor3=Color3.fromRGB(120,80,220)
ContentScroll.BorderSizePixel=0
ContentScroll.Parent=ContentBG

local SL=Instance.new("UIListLayout")
SL.Padding=UDim.new(0,6);SL.Parent=ContentScroll
SL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentScroll.CanvasSize=UDim2.new(0,0,0,SL.AbsoluteContentSize.Y+10)
end)

-- Pages
local Pages={}
local function newPage(name)
    local f=Instance.new("Frame")
    f.Size=UDim2.new(1,0,0,0);f.BackgroundTransparency=1;f.Visible=false;f.Parent=ContentScroll
    local l=Instance.new("UIListLayout");l.Padding=UDim.new(0,6);l.Parent=f
    l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        f.Size=UDim2.new(1,0,0,l.AbsoluteContentSize.Y)
        ContentScroll.CanvasSize=UDim2.new(0,0,0,l.AbsoluteContentSize.Y+10)
    end)
    Pages[name]=f;return f
end

local activeTab=nil
local function showPage(name)
    ContentTitle.Text=name
    for n,f in pairs(Pages) do f.Visible=(n==name) end
    activeTab=name
end

-- Sidebar tab maker
local sideButtons={}
local function makeSideTab(name,icon)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,0,0,38)
    btn.BackgroundColor3=Color3.fromRGB(22,24,36)
    btn.BorderSizePixel=0
    btn.Text=icon.."  "..name
    btn.TextColor3=Color3.fromRGB(140,135,175)
    btn.Font=Enum.Font.GothamBold;btn.TextSize=13
    btn.TextXAlignment=Enum.TextXAlignment.Left
    btn.Parent=TabContainer
    corner(btn,8)
    local pad=Instance.new("UIPadding");pad.PaddingLeft=UDim.new(0,12);pad.Parent=btn
    table.insert(sideButtons,btn)
    btn.MouseButton1Click:Connect(function()
        for _,b in pairs(sideButtons) do
            tw(b,{BackgroundColor3=Color3.fromRGB(22,24,36),TextColor3=Color3.fromRGB(140,135,175)},0.12)
        end
        tw(btn,{BackgroundColor3=Color3.fromRGB(55,35,110),TextColor3=Color3.fromRGB(255,255,255)},0.12)
        showPage(name)
    end)
    return btn
end

-- Element makers
local function makeToggle(parent,name,default,callback)
    local row=newFrame(parent,UDim2.new(1,0,0,44),UDim2.new(0,0,0,0),Color3.fromRGB(25,27,38))
    corner(row,8)
    newLabel(row,name,13,Color3.fromRGB(215,210,245),Enum.Font.GothamBold,UDim2.new(0,14,0,0),UDim2.new(1,-70,1,0))
    local bg=newFrame(row,UDim2.new(0,46,0,24),UDim2.new(1,-58,0.5,-12),default and Color3.fromRGB(100,65,220) or Color3.fromRGB(40,40,60))
    corner(bg,12)
    local circle=newFrame(bg,UDim2.new(0,18,0,18),default and UDim2.new(0,25,0.5,-9) or UDim2.new(0,3,0.5,-9),Color3.fromRGB(255,255,255))
    corner(circle,9)
    local val=default or false
    local hit=Instance.new("TextButton");hit.Size=UDim2.new(1,0,1,0);hit.BackgroundTransparency=1;hit.Text="";hit.Parent=row
    hit.MouseButton1Click:Connect(function()
        val=not val
        tw(bg,{BackgroundColor3=val and Color3.fromRGB(100,65,220) or Color3.fromRGB(40,40,60)},0.15)
        tw(circle,{Position=val and UDim2.new(0,25,0.5,-9) or UDim2.new(0,3,0.5,-9)},0.15)
        if callback then callback(val) end
    end)
end

local function makeSlider(parent,name,min,max,default,inc,callback)
    local row=newFrame(parent,UDim2.new(1,0,0,58),UDim2.new(0,0,0,0),Color3.fromRGB(25,27,38))
    corner(row,8)
    newLabel(row,name,13,Color3.fromRGB(215,210,245),Enum.Font.GothamBold,UDim2.new(0,14,0,4),UDim2.new(1,-80,0,26))
    local valL=newLabel(row,tostring(default),13,Color3.fromRGB(150,110,255),Enum.Font.GothamBold,
        UDim2.new(1,-70,0,4),UDim2.new(0,60,0,26),Enum.TextXAlignment.Right)
    local track=newFrame(row,UDim2.new(1,-28,0,6),UDim2.new(0,14,1,-18),Color3.fromRGB(38,38,58))
    corner(track,3)
    local pct0=(default-min)/(max-min)
    local fill=newFrame(track,UDim2.new(pct0,0,1,0),UDim2.new(0,0,0,0),Color3.fromRGB(100,65,220))
    corner(fill,3)
    local dot=newFrame(fill,UDim2.new(0,14,0,14),UDim2.new(0,-7,0.5,-7),Color3.fromRGB(255,255,255))
    corner(dot,7)
    local val=default;local sliding=false
    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sliding and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local abs=track.AbsolutePosition;local sz=track.AbsoluteSize
            local p=math.clamp((i.Position.X-abs.X)/sz.X,0,1)
            val=math.clamp(math.round((min+(max-min)*p)/inc)*inc,min,max)
            fill.Size=UDim2.new((val-min)/(max-min),0,1,0)
            valL.Text=tostring(val)
            if callback then callback(val) end
        end
    end)
end

local function makeDropdown(parent,name,options,default,callback)
    local row=newFrame(parent,UDim2.new(1,0,0,44),UDim2.new(0,0,0,0),Color3.fromRGB(25,27,38))
    row.ClipsDescendants=false;corner(row,8)
    newLabel(row,name,13,Color3.fromRGB(215,210,245),Enum.Font.GothamBold,UDim2.new(0,14,0,0),UDim2.new(0.45,0,1,0))
    local sel=default or options[1]
    local dropBtn=Instance.new("TextButton")
    dropBtn.Size=UDim2.new(0,148,0,30);dropBtn.Position=UDim2.new(1,-156,0.5,-15)
    dropBtn.BackgroundColor3=Color3.fromRGB(32,34,50)
    dropBtn.Text=sel.."  v";dropBtn.TextColor3=Color3.fromRGB(200,195,240)
    dropBtn.Font=Enum.Font.Gotham;dropBtn.TextSize=12;dropBtn.Parent=row
    corner(dropBtn,6);stroke(dropBtn,Color3.fromRGB(55,55,80),1)

    local dropFrame=newFrame(row,UDim2.new(0,148,0,#options*32+6),UDim2.new(1,-156,1,4),Color3.fromRGB(22,24,36))
    dropFrame.Visible=false;dropFrame.ZIndex=50;dropFrame.ClipsDescendants=false
    corner(dropFrame,8);stroke(dropFrame,Color3.fromRGB(55,55,80),1)
    local dL=Instance.new("UIListLayout");dL.Padding=UDim.new(0,2);dL.Parent=dropFrame
    local dP=Instance.new("UIPadding");dP.PaddingTop=UDim.new(0,3);dP.PaddingLeft=UDim.new(0,3);dP.PaddingRight=UDim.new(0,3);dP.Parent=dropFrame

    for _,opt in pairs(options) do
        local ob=Instance.new("TextButton")
        ob.Size=UDim2.new(1,0,0,28);ob.BackgroundColor3=Color3.fromRGB(30,32,48)
        ob.Text=opt;ob.TextColor3=Color3.fromRGB(200,195,240)
        ob.Font=Enum.Font.Gotham;ob.TextSize=12;ob.ZIndex=51
        ob.Parent=dropFrame;corner(ob,5)
        ob.MouseButton1Click:Connect(function()
            sel=opt;dropBtn.Text=opt.."  v";dropFrame.Visible=false
            tw(row,{Size=UDim2.new(1,0,0,44)},0.1)
            if callback then callback(opt) end
        end)
    end

    local open=false
    dropBtn.MouseButton1Click:Connect(function()
        open=not open;dropFrame.Visible=open
        tw(row,{Size=UDim2.new(1,0,0,open and 44+#options*32+10 or 44)},0.15)
    end)
    if callback then callback(sel) end
end

local function makeButton(parent,name,callback)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,0,0,40)
    btn.BackgroundColor3=Color3.fromRGB(70,45,150)
    btn.Text=name;btn.TextColor3=Color3.fromRGB(255,255,255)
    btn.Font=Enum.Font.GothamBold;btn.TextSize=13;btn.Parent=parent
    corner(btn,8)
    btn.MouseButton1Click:Connect(function()
        tw(btn,{BackgroundColor3=Color3.fromRGB(100,70,200)},0.08)
        task.delay(0.15,function() tw(btn,{BackgroundColor3=Color3.fromRGB(70,45,150)},0.08) end)
        if callback then callback() end
    end)
end

local function makeSection(parent,name)
    local f=newFrame(parent,UDim2.new(1,0,0,22),UDim2.new(0,0,0,0),Color3.fromRGB(0,0,0),1)
    newLabel(f,"— "..name.." —",10,Color3.fromRGB(110,90,180),Enum.Font.GothamBold,
        UDim2.new(0,0,0,0),UDim2.new(1,0,1,0),Enum.TextXAlignment.Left)
end

-- ================================================
-- BUILD PAGES
-- ================================================
local COLORS_MAP={
    Red=Color3.fromRGB(255,0,0),Green=Color3.fromRGB(0,255,0),
    Blue=Color3.fromRGB(0,100,255),Yellow=Color3.fromRGB(255,255,0),
    Purple=Color3.fromRGB(180,0,255),Cyan=Color3.fromRGB(0,255,255),
    White=Color3.fromRGB(255,255,255),Orange=Color3.fromRGB(255,140,0)
}

-- ESP
makeSideTab("ESP","[V]")
local espP=newPage("ESP")
makeSection(espP,"Player Visuals")
makeToggle(espP,"Enable ESP",false,function(v) Cfg.ESPEnabled=v;refreshESP() end)
makeDropdown(espP,"ESP Mode",{"Highlight","Box","Tracer"},"Highlight",function(v) Cfg.ESPMode=v;refreshESP() end)
makeDropdown(espP,"ESP Color",{"Red","Green","Blue","Yellow","Purple","Cyan","White","Orange"},"Red",function(v)
    if COLORS_MAP[v] then Cfg.ESPFillColor=COLORS_MAP[v];Cfg.ESPOutColor=COLORS_MAP[v];refreshESP() end
end)
makeSlider(espP,"Transparency",0,10,5,1,function(v) Cfg.ESPTransp=v/10;refreshESP() end)

-- AIMBOT
makeSideTab("Aimbot","[A]")
local aimP=newPage("Aimbot")
makeSection(aimP,"Aimbot Settings")
makeToggle(aimP,"Enable Aimbot",false,function(v) Cfg.AimbotEnabled=v end)
makeToggle(aimP,"FOV Circle",false,function(v) Cfg.FOVEnabled=v end)
makeSlider(aimP,"FOV Radius",30,500,150,5,function(v) Cfg.FOVRadius=v end)
makeSlider(aimP,"Smoothness",1,100,20,1,function(v) Cfg.AimbotSmooth=v/100 end)
makeDropdown(aimP,"Aim Part",{"Head","HumanoidRootPart","UpperTorso","Torso"},"Head",function(v) Cfg.AimbotPart=v end)
makeDropdown(aimP,"FOV Color",{"White","Yellow","Red","Green","Blue","Cyan","Purple"},"White",function(v)
    local c={White=Color3.fromRGB(255,255,255),Yellow=Color3.fromRGB(255,255,0),Red=Color3.fromRGB(255,0,0),
        Green=Color3.fromRGB(0,255,0),Blue=Color3.fromRGB(0,100,255),Cyan=Color3.fromRGB(0,255,255),Purple=Color3.fromRGB(150,80,255)}
    if c[v] then Cfg.FOVColor=c[v] end
end)

-- MOVEMENT
makeSideTab("Movement","[M]")
local moveP=newPage("Movement")
makeSection(moveP,"Player Movement")
makeToggle(moveP,"Infinite Jump",false,function(v) Cfg.InfJump=v end)
makeToggle(moveP,"Speed Hack",false,function(v) Cfg.SpeedEnabled=v end)
makeSlider(moveP,"Walk Speed",16,200,40,1,function(v) Cfg.SpeedValue=v end)
makeToggle(moveP,"Noclip",false,function(v) Cfg.NoclipOn=v end)
makeToggle(moveP,"No Fall Damage",false,function(v) Cfg.NoFallOn=v end)

-- MISC
makeSideTab("Misc","[X]")
local miscP=newPage("Misc")
makeSection(miscP,"Miscellaneous")
makeToggle(miscP,"Fullbright",false,function(v) setFullBright(v) end)
makeToggle(miscP,"Anti-AFK",false,function(v)
    if v then
        LP.Idled:Connect(function()
            local vu=game:GetService("VirtualUser")
            vu:Button1Down(Vector2.new(0,0),Camera.CFrame)
            task.wait(0.1)
            vu:Button1Up(Vector2.new(0,0),Camera.CFrame)
        end)
    end
end)
makeButton(miscP,"Teleport to Spawn",function()
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.CFrame=CFrame.new(0,10,0)
    end
end)
makeButton(miscP,"Respawn",function()
    if LP.Character then local h=LP.Character:FindFirstChild("Humanoid");if h then h.Health=0 end end
end)
makeButton(miscP,"Rejoin",function()
    game:GetService("TeleportService"):Teleport(game.PlaceId,LP)
end)

-- ABOUT
makeSideTab("About","[i]")
local aboutP=newPage("About")
makeSection(aboutP,"About Script")

local aboutCard=newFrame(aboutP,UDim2.new(1,0,0,120),UDim2.new(0,0,0,0),Color3.fromRGB(25,27,38))
corner(aboutCard,10)
stroke(aboutCard,Color3.fromRGB(80,55,160),1)

-- Rabbit logo in about
local aLogo=newFrame(aboutCard,UDim2.new(0,56,0,56),UDim2.new(0,14,0.5,-28),Color3.fromRGB(30,30,48))
corner(aLogo,28)
stroke(aLogo,Color3.fromRGB(100,70,200),1)
local aLogoImg=Instance.new("ImageLabel")
aLogoImg.Size=UDim2.new(1,0,1,0);aLogoImg.BackgroundTransparency=1
aLogoImg.Image="rbxassetid://7072725450"
aLogoImg.ImageColor3=Color3.fromRGB(200,180,255)
aLogoImg.ScaleType=Enum.ScaleType.Fit
aLogoImg.Parent=aLogo

newLabel(aboutCard,"Primejtsu X | Flick Script",14,Color3.fromRGB(220,210,255),Enum.Font.GothamBold,
    UDim2.new(0,82,0,18),UDim2.new(1,-96,0,22))
newLabel(aboutCard,"Creator: @Primejtsu",12,Color3.fromRGB(160,150,210),Enum.Font.Gotham,
    UDim2.new(0,82,0,42),UDim2.new(1,-96,0,20))
newLabel(aboutCard,"Version: v3.0",11,Color3.fromRGB(120,110,170),Enum.Font.Gotham,
    UDim2.new(0,82,0,62),UDim2.new(1,-96,0,18))

local tgBtn=Instance.new("TextButton")
tgBtn.Size=UDim2.new(1,-28,0,34);tgBtn.Position=UDim2.new(0,14,1,-46)
tgBtn.BackgroundColor3=Color3.fromRGB(30,80,160)
tgBtn.Text="Join Telegram Channel";tgBtn.TextColor3=Color3.fromRGB(255,255,255)
tgBtn.Font=Enum.Font.GothamBold;tgBtn.TextSize=12;tgBtn.Parent=aboutCard
corner(tgBtn,8)
tgBtn.MouseButton1Click:Connect(function()
    -- opens nothing but shows notification
    local notif=newFrame(ScreenGui,UDim2.new(0,260,0,56),UDim2.new(1,-270,1,-70),Color3.fromRGB(25,27,38))
    corner(notif,8);stroke(notif,Color3.fromRGB(30,80,160),1)
    newLabel(notif,"Telegram: t.me/Primejtsu",12,Color3.fromRGB(200,220,255),Enum.Font.GothamBold,
        UDim2.new(0,10,0,0),UDim2.new(1,-16,1,0))
    task.delay(3,function() tw(notif,{BackgroundTransparency=1},0.3);task.wait(0.3);notif:Destroy() end)
end)

-- ================================================
-- STARTUP NOTIFICATION (bottom right)
-- ================================================
task.wait(2)
local notifBG=newFrame(ScreenGui,UDim2.new(0,280,0,72),UDim2.new(1,300,1,-90),Color3.fromRGB(20,22,30))
corner(notifBG,10);stroke(notifBG,Color3.fromRGB(80,55,160),1)

-- Rabbit avatar in notif
local nLogo=newFrame(notifBG,UDim2.new(0,46,0,46),UDim2.new(0,10,0.5,-23),Color3.fromRGB(28,28,42))
corner(nLogo,23)
local nImg=Instance.new("ImageLabel")
nImg.Size=UDim2.new(1,0,1,0);nImg.BackgroundTransparency=1
nImg.Image="rbxassetid://7072725450"
nImg.ImageColor3=Color3.fromRGB(200,180,255)
nImg.ScaleType=Enum.ScaleType.Fit;nImg.Parent=nLogo

newLabel(notifBG,"Primejtsu X",13,Color3.fromRGB(220,210,255),Enum.Font.GothamBold,
    UDim2.new(0,64,0,10),UDim2.new(1,-74,0,22))
newLabel(notifBG,"Thank you for choosing us!",11,Color3.fromRGB(160,150,210),Enum.Font.Gotham,
    UDim2.new(0,64,0,32),UDim2.new(1,-74,0,18))
newLabel(notifBG,"Спасибо что выбрали нас!",10,Color3.fromRGB(120,110,165),Enum.Font.Gotham,
    UDim2.new(0,64,0,50),UDim2.new(1,-74,0,16))

-- RGB border on notif
local nStroke=stroke(notifBG,Color3.fromRGB(120,80,255),1.5)
RunService.Heartbeat:Connect(function() nStroke.Color=Color3.fromHSV(hue,0.7,1) end)

tw(notifBG,{Position=UDim2.new(1,-290,1,-90)},0.35,Enum.EasingStyle.Back)
task.delay(5,function()
    tw(notifBG,{Position=UDim2.new(1,300,1,-90)},0.3)
    task.wait(0.35);notifBG:Destroy()
end)

-- Show first page
showPage("ESP")
tw(sideButtons[1],{BackgroundColor3=Color3.fromRGB(55,35,110),TextColor3=Color3.fromRGB(255,255,255)},0)

print("[Primejtsu X] v3.0 Loaded.")
