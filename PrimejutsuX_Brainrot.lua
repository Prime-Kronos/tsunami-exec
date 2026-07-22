-- ================================================
--   PJTSU UI | Primejtsu X | Steal a Brainrot Script
--   Custom GUI v1.0
-- ================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Camera           = workspace.CurrentCamera
local LP               = Players.LocalPlayer

local function tw(o,p,t,s) TweenService:Create(o,TweenInfo.new(t or 0.15,s or Enum.EasingStyle.Quad),p):Play() end
local function corner(p,r) local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 8);c.Parent=p;return c end
local function stroke(p,col,t) local s=Instance.new("UIStroke");s.Color=col or Color3.fromRGB(200,30,60);s.Thickness=t or 1;s.Parent=p;return s end
local function frame(parent,size,pos,color,transp)
    local f=Instance.new("Frame");f.Size=size;f.Position=pos or UDim2.new(0,0,0,0)
    f.BackgroundColor3=color or Color3.fromRGB(20,20,28);f.BackgroundTransparency=transp or 0
    f.BorderSizePixel=0;f.Parent=parent;return f
end
local function label(parent,text,size,color,font,pos,sz,xa)
    local l=Instance.new("TextLabel");l.Text=text;l.TextSize=size or 13
    l.TextColor3=color or Color3.fromRGB(255,255,255);l.Font=font or Enum.Font.GothamBold
    l.BackgroundTransparency=1;l.Position=pos or UDim2.new(0,0,0,0)
    l.Size=sz or UDim2.new(1,0,1,0);l.TextXAlignment=xa or Enum.TextXAlignment.Center
    l.Parent=parent;return l
end

-- ================================================
-- SCREEN GUI
-- ================================================
local SG=Instance.new("ScreenGui")
SG.Name="PJTSUI";SG.ResetOnSpawn=false
SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
SG.Parent=LP.PlayerGui

-- ================================================
-- LOADING SCREEN — RAIN + TITLE
-- ================================================
local LoadBG=frame(SG,UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),Color3.fromRGB(8,8,14))
LoadBG.ZIndex=100

-- Rain drops
local rainDrops={}
local function spawnRain()
    for i=1,60 do
        task.spawn(function()
            while LoadBG and LoadBG.Parent do
                local drop=Instance.new("Frame")
                drop.Size=UDim2.new(0,1,0,math.random(10,30))
                drop.Position=UDim2.new(math.random(0,100)/100,0,-0.05,0)
                drop.BackgroundColor3=Color3.fromRGB(
                    math.random(180,255),
                    math.random(10,50),
                    math.random(40,80))
                drop.BackgroundTransparency=math.random(30,70)/100
                drop.BorderSizePixel=0
                drop.ZIndex=101
                drop.Parent=LoadBG
                tw(drop,{Position=UDim2.new(drop.Position.X.Scale,0,1.1,0)},math.random(8,16)/10)
                task.wait(math.random(8,16)/10+0.1)
                drop:Destroy()
            end
        end)
        task.wait(0.05)
    end
end
task.spawn(spawnRain)

-- Glow circle behind title
local glow=Instance.new("ImageLabel")
glow.Size=UDim2.new(0,400,0,400)
glow.Position=UDim2.new(0.5,-200,0.5,-200)
glow.BackgroundTransparency=1
glow.Image="rbxassetid://5028857084"
glow.ImageColor3=Color3.fromRGB(220,30,60)
glow.ImageTransparency=0.6
glow.ScaleType=Enum.ScaleType.Slice
glow.SliceCenter=Rect.new(24,24,276,276)
glow.ZIndex=102
glow.Parent=LoadBG
glow.Size=UDim2.new(0,0,0,0)
glow.Position=UDim2.new(0.5,0,0.5,0)

-- Cat logo
local catFrame=frame(LoadBG,UDim2.new(0,80,0,80),UDim2.new(0.5,-40,0.35,-40),Color3.fromRGB(0,0,0),1)
catFrame.ZIndex=103
local catImg=Instance.new("ImageLabel")
catImg.Size=UDim2.new(1,0,1,0)
catImg.BackgroundTransparency=1
catImg.Image="rbxassetid://7072725450"
catImg.ImageColor3=Color3.fromRGB(220,30,60)
catImg.ScaleType=Enum.ScaleType.Fit
catImg.ZIndex=103
catImg.ImageTransparency=1
catImg.Parent=catFrame

-- Title
local loadTitle=label(LoadBG,"Primejtsu X | Project",28,Color3.fromRGB(255,255,255),
    Enum.Font.GothamBold,UDim2.new(0,0,0.52,0),UDim2.new(1,0,0,40))
loadTitle.ZIndex=103
loadTitle.TextTransparency=1

local loadSub=label(LoadBG,"Steal a Brainrot Script",13,Color3.fromRGB(220,50,80),
    Enum.Font.GothamBold,UDim2.new(0,0,0.62,0),UDim2.new(1,0,0,24))
loadSub.ZIndex=103
loadSub.TextTransparency=1

-- Bottom progress bar
local barBG=frame(LoadBG,UDim2.new(0.6,0,0,3),UDim2.new(0.2,0,0.88,0),Color3.fromRGB(40,40,55))
barBG.ZIndex=103
corner(barBG,2)
local bar=frame(barBG,UDim2.new(0,0,1,0),UDim2.new(0,0,0,0),Color3.fromRGB(220,30,60))
corner(bar,2)
bar.ZIndex=104

-- RGB hue tracker
local hue=0
RunService.Heartbeat:Connect(function()
    hue=(hue+0.002)%1
end)

-- Animate loading
task.spawn(function()
    task.wait(0.3)

    -- Glow appears
    tw(glow,{Size=UDim2.new(0,500,0,500),Position=UDim2.new(0.5,-250,0.5,-250)},1.2,Enum.EasingStyle.Quad)
    task.wait(0.6)

    -- Cat + title fade in
    tw(catImg,{ImageTransparency=0},0.8)
    tw(loadTitle,{TextTransparency=0},0.8)
    task.wait(0.4)
    tw(loadSub,{TextTransparency=0},0.6)

    -- Progress bar fills over remaining time
    tw(bar,{Size=UDim2.new(1,0,1,0)},9,Enum.EasingStyle.Linear)

    -- RGB on bar
    task.spawn(function()
        while bar and bar.Parent do
            bar.BackgroundColor3=Color3.fromHSV(hue,0.8,1)
            task.wait(0.05)
        end
    end)

    task.wait(9.5)

    -- Fade out
    tw(LoadBG,{BackgroundTransparency=1},0.8)
    tw(loadTitle,{TextTransparency=1},0.8)
    tw(loadSub,{TextTransparency=1},0.8)
    tw(catImg,{ImageTransparency=1},0.8)
    tw(glow,{ImageTransparency=1},0.8)
    tw(barBG,{BackgroundTransparency=1},0.8)
    tw(bar,{BackgroundTransparency=1},0.8)
    task.wait(0.9)
    LoadBG:Destroy()

    -- Show main GUI
    MainGUI.Visible=true
    tw(MainGUI,{Size=UDim2.new(0,320,0,340)},0.3,Enum.EasingStyle.Back)
end)

-- ================================================
-- MAIN WINDOW (hidden until loading done)
-- ================================================
MainGUI=frame(SG,UDim2.new(0,0,0,0),UDim2.new(0.5,-160,0.5,-170),Color3.fromRGB(14,15,22))
MainGUI.Visible=false
MainGUI.ZIndex=10
corner(MainGUI,12)

-- RGB border
local mainStroke=stroke(MainGUI,Color3.fromRGB(220,30,60),1.5)
RunService.Heartbeat:Connect(function()
    mainStroke.Color=Color3.fromHSV(hue,0.85,1)
end)

-- Drag
local drag,dragStart,startPos=false,nil,nil
MainGUI.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        drag=true;dragStart=i.Position;startPos=MainGUI.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        local d=i.Position-dragStart
        MainGUI.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
end)

-- ================================================
-- TOP BAR
-- ================================================
local TopBar=frame(MainGUI,UDim2.new(1,0,0,36),UDim2.new(0,0,0,0),Color3.fromRGB(10,11,18))
TopBar.ZIndex=11
corner(TopBar,12)
-- fix bottom corners
local topFix=frame(TopBar,UDim2.new(1,0,0,12),UDim2.new(0,0,1,-12),Color3.fromRGB(10,11,18))
topFix.ZIndex=11

-- Cat icon in topbar
local topCat=Instance.new("ImageLabel")
topCat.Size=UDim2.new(0,22,0,22)
topCat.Position=UDim2.new(0,8,0.5,-11)
topCat.BackgroundTransparency=1
topCat.Image="rbxassetid://7072725450"
topCat.ImageColor3=Color3.fromRGB(220,30,60)
topCat.ScaleType=Enum.ScaleType.Fit
topCat.ZIndex=12
topCat.Parent=TopBar

-- Title in topbar
label(TopBar,"Primejtsu X | Brainrot",12,Color3.fromRGB(220,215,255),
    Enum.Font.GothamBold,UDim2.new(0,36,0,0),UDim2.new(1,-80,1,0),Enum.TextXAlignment.Left).ZIndex=12

-- Close button top right
local closeBtn=Instance.new("TextButton")
closeBtn.Size=UDim2.new(0,26,0,26)
closeBtn.Position=UDim2.new(1,-32,0.5,-13)
closeBtn.BackgroundColor3=Color3.fromRGB(180,30,50)
closeBtn.Text="×";closeBtn.TextColor3=Color3.fromRGB(255,255,255)
closeBtn.Font=Enum.Font.GothamBold;closeBtn.TextSize=16
closeBtn.ZIndex=12;closeBtn.Parent=TopBar
corner(closeBtn,6)

local guiOpen=true
closeBtn.MouseButton1Click:Connect(function()
    guiOpen=not guiOpen
    if guiOpen then
        MainGUI.Visible=true
        tw(MainGUI,{Size=UDim2.new(0,320,0,340)},0.2,Enum.EasingStyle.Back)
    else
        tw(MainGUI,{Size=UDim2.new(0,320,0,0)},0.15)
        task.delay(0.16,function() MainGUI.Visible=false end)
    end
end)

-- Accent line under topbar
local accentLine=frame(MainGUI,UDim2.new(1,0,0,1),UDim2.new(0,0,0,36),Color3.fromRGB(220,30,60))
accentLine.ZIndex=11
RunService.Heartbeat:Connect(function()
    accentLine.BackgroundColor3=Color3.fromHSV(hue,0.85,1)
end)

-- ================================================
-- SIDEBAR
-- ================================================
local Sidebar=frame(MainGUI,UDim2.new(0,90,1,-37),UDim2.new(0,0,0,37),Color3.fromRGB(10,11,18))
Sidebar.ZIndex=11
-- fix right side
frame(Sidebar,UDim2.new(0,10,1,0),UDim2.new(1,-10,0,0),Color3.fromRGB(10,11,18)).ZIndex=11

-- Sidebar divider
local sDiv=frame(MainGUI,UDim2.new(0,1,1,-37),UDim2.new(0,90,0,37),Color3.fromRGB(30,30,45))
sDiv.ZIndex=11

-- Tab buttons
local tabBtns={}
local pages={}
local currentPage=nil

local tabList=frame(Sidebar,UDim2.new(1,0,1,0),UDim2.new(0,0,0,0),Color3.fromRGB(0,0,0),1)
tabList.ZIndex=12
local tLayout=Instance.new("UIListLayout")
tLayout.Padding=UDim.new(0,2);tLayout.Parent=tabList
local tPad=Instance.new("UIPadding")
tPad.PaddingTop=UDim.new(0,8);tPad.PaddingLeft=UDim.new(0,6);tPad.PaddingRight=UDim.new(0,6)
tPad.Parent=tabList

-- ================================================
-- CONTENT AREA
-- ================================================
local Content=frame(MainGUI,UDim2.new(1,-90,1,-44),UDim2.new(0,91,0,43),Color3.fromRGB(0,0,0),1)
Content.ZIndex=11

local contentScroll=Instance.new("ScrollingFrame")
contentScroll.Size=UDim2.new(1,-8,1,-8)
contentScroll.Position=UDim2.new(0,4,0,4)
contentScroll.BackgroundTransparency=1
contentScroll.ScrollBarThickness=2
contentScroll.ScrollBarImageColor3=Color3.fromRGB(220,30,60)
contentScroll.BorderSizePixel=0
contentScroll.ZIndex=12
contentScroll.Parent=Content

local cLayout=Instance.new("UIListLayout")
cLayout.Padding=UDim.new(0,5);cLayout.Parent=contentScroll
cLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    contentScroll.CanvasSize=UDim2.new(0,0,0,cLayout.AbsoluteContentSize.Y+8)
end)

-- Page system
local function newPage(name)
    local f=Instance.new("Frame")
    f.Size=UDim2.new(1,0,0,0);f.BackgroundTransparency=1;f.Visible=false;f.ZIndex=13;f.Parent=contentScroll
    local l=Instance.new("UIListLayout");l.Padding=UDim.new(0,5);l.Parent=f
    l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        f.Size=UDim2.new(1,0,0,l.AbsoluteContentSize.Y)
        contentScroll.CanvasSize=UDim2.new(0,0,0,l.AbsoluteContentSize.Y+8)
    end)
    pages[name]=f;return f
end

local function showPage(name)
    for n,f in pairs(pages) do f.Visible=(n==name) end
    currentPage=name
end

local function makeSideTab(name)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,0,0,42)
    btn.BackgroundColor3=Color3.fromRGB(16,17,26)
    btn.Text=name;btn.TextColor3=Color3.fromRGB(130,125,165)
    btn.Font=Enum.Font.GothamBold;btn.TextSize=11
    btn.BorderSizePixel=0;btn.ZIndex=13;btn.Parent=tabList
    corner(btn,7)
    table.insert(tabBtns,btn)

    btn.MouseButton1Click:Connect(function()
        for _,b in pairs(tabBtns) do
            tw(b,{BackgroundColor3=Color3.fromRGB(16,17,26),TextColor3=Color3.fromRGB(130,125,165)},0.12)
        end
        tw(btn,{BackgroundColor3=Color3.fromRGB(180,20,45),TextColor3=Color3.fromRGB(255,255,255)},0.12)
        showPage(name)
    end)
    return btn
end

-- ================================================
-- ELEMENT MAKERS
-- ================================================
local function makeToggle(parent,name,default,cb)
    local row=frame(parent,UDim2.new(1,0,0,40),nil,Color3.fromRGB(18,19,28))
    row.ZIndex=14;corner(row,7)
    label(row,name,11,Color3.fromRGB(210,205,240),Enum.Font.GothamBold,
        UDim2.new(0,10,0,0),UDim2.new(1,-52,1,0),Enum.TextXAlignment.Left).ZIndex=15
    local bg=frame(row,UDim2.new(0,36,0,20),UDim2.new(1,-44,0.5,-10),
        default and Color3.fromRGB(200,25,50) or Color3.fromRGB(35,35,52))
    bg.ZIndex=15;corner(bg,10)
    local dot=frame(bg,UDim2.new(0,14,0,14),default and UDim2.new(0,19,0.5,-7) or UDim2.new(0,3,0.5,-7),Color3.fromRGB(255,255,255))
    dot.ZIndex=16;corner(dot,7)
    local val=default or false
    local hit=Instance.new("TextButton");hit.Size=UDim2.new(1,0,1,0);hit.BackgroundTransparency=1;hit.Text="";hit.ZIndex=16;hit.Parent=row
    hit.MouseButton1Click:Connect(function()
        val=not val
        tw(bg,{BackgroundColor3=val and Color3.fromRGB(200,25,50) or Color3.fromRGB(35,35,52)},0.15)
        tw(dot,{Position=val and UDim2.new(0,19,0.5,-7) or UDim2.new(0,3,0.5,-7)},0.15)
        if cb then cb(val) end
    end)
end

local function makeSlider(parent,name,min,max,default,inc,cb)
    local row=frame(parent,UDim2.new(1,0,0,52),nil,Color3.fromRGB(18,19,28))
    row.ZIndex=14;corner(row,7)
    label(row,name,11,Color3.fromRGB(210,205,240),Enum.Font.GothamBold,
        UDim2.new(0,10,0,4),UDim2.new(1,-60,0,22),Enum.TextXAlignment.Left).ZIndex=15
    local valL=label(row,tostring(default),11,Color3.fromRGB(220,40,70),Enum.Font.GothamBold,
        UDim2.new(1,-52,0,4),UDim2.new(0,44,0,22),Enum.TextXAlignment.Right)
    valL.ZIndex=15
    local track=frame(row,UDim2.new(1,-20,0,5),UDim2.new(0,10,1,-16),Color3.fromRGB(32,32,48))
    track.ZIndex=15;corner(track,3)
    local fill=frame(track,UDim2.new((default-min)/(max-min),0,1,0),nil,Color3.fromRGB(200,25,50))
    fill.ZIndex=16;corner(fill,3)
    local dot=frame(fill,UDim2.new(0,12,0,12),UDim2.new(0,-6,0.5,-6),Color3.fromRGB(255,255,255))
    dot.ZIndex=17;corner(dot,6)
    RunService.Heartbeat:Connect(function() fill.BackgroundColor3=Color3.fromHSV(hue,0.85,1) end)
    local val=default;local sliding=false
    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sliding and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local a=track.AbsolutePosition;local s=track.AbsoluteSize
            local p=math.clamp((i.Position.X-a.X)/s.X,0,1)
            val=math.clamp(math.round((min+(max-min)*p)/inc)*inc,min,max)
            fill.Size=UDim2.new((val-min)/(max-min),0,1,0)
            valL.Text=tostring(val)
            if cb then cb(val) end
        end
    end)
end

local function makeDropdown(parent,name,options,default,cb)
    local row=frame(parent,UDim2.new(1,0,0,40),nil,Color3.fromRGB(18,19,28))
    row.ZIndex=14;row.ClipsDescendants=false;corner(row,7)
    label(row,name,11,Color3.fromRGB(210,205,240),Enum.Font.GothamBold,
        UDim2.new(0,10,0,0),UDim2.new(0.5,0,1,0),Enum.TextXAlignment.Left).ZIndex=15
    local sel=default or options[1]
    local dBtn=Instance.new("TextButton")
    dBtn.Size=UDim2.new(0,100,0,26);dBtn.Position=UDim2.new(1,-108,0.5,-13)
    dBtn.BackgroundColor3=Color3.fromRGB(24,25,36)
    dBtn.Text=sel.." v";dBtn.TextColor3=Color3.fromRGB(200,195,235)
    dBtn.Font=Enum.Font.Gotham;dBtn.TextSize=10;dBtn.ZIndex=15;dBtn.Parent=row
    corner(dBtn,5);stroke(dBtn,Color3.fromRGB(45,45,65),1)
    local dFrame=frame(row,UDim2.new(0,100,0,#options*28+6),UDim2.new(1,-108,1,4),Color3.fromRGB(18,19,30))
    dFrame.Visible=false;dFrame.ZIndex=50;dFrame.ClipsDescendants=false
    corner(dFrame,6);stroke(dFrame,Color3.fromRGB(45,45,65),1)
    local dl=Instance.new("UIListLayout");dl.Padding=UDim.new(0,2);dl.Parent=dFrame
    local dp=Instance.new("UIPadding");dp.PaddingTop=UDim.new(0,3);dp.PaddingLeft=UDim.new(0,3);dp.PaddingRight=UDim.new(0,3);dp.Parent=dFrame
    for _,opt in pairs(options) do
        local ob=Instance.new("TextButton")
        ob.Size=UDim2.new(1,0,0,24);ob.BackgroundColor3=Color3.fromRGB(24,25,36)
        ob.Text=opt;ob.TextColor3=Color3.fromRGB(200,195,235)
        ob.Font=Enum.Font.Gotham;ob.TextSize=10;ob.ZIndex=51;ob.Parent=dFrame
        corner(ob,4)
        ob.MouseButton1Click:Connect(function()
            sel=opt;dBtn.Text=opt.." v";dFrame.Visible=false
            tw(row,{Size=UDim2.new(1,0,0,40)},0.1)
            if cb then cb(opt) end
        end)
    end
    local open=false
    dBtn.MouseButton1Click:Connect(function()
        open=not open;dFrame.Visible=open
        tw(row,{Size=UDim2.new(1,0,0,open and 40+#options*28+10 or 40)},0.15)
    end)
    if cb then cb(sel) end
end

local function makeButton(parent,name,cb)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,0,0,34)
    btn.BackgroundColor3=Color3.fromRGB(180,20,45)
    btn.Text=name;btn.TextColor3=Color3.fromRGB(255,255,255)
    btn.Font=Enum.Font.GothamBold;btn.TextSize=11
    btn.BorderSizePixel=0;btn.ZIndex=14;btn.Parent=parent
    corner(btn,7)
    btn.MouseButton1Click:Connect(function()
        tw(btn,{BackgroundColor3=Color3.fromRGB(220,40,70)},0.08)
        task.delay(0.15,function() tw(btn,{BackgroundColor3=Color3.fromRGB(180,20,45)},0.08) end)
        if cb then cb() end
    end)
end

-- ================================================
-- SCRIPT CONFIG
-- ================================================
local Cfg={
    ESPEnabled=false,ESPMode="Highlight",ESPColor=Color3.fromRGB(255,0,0),ESPTransp=0.5,
    NameESP=false,HealthBar=false,
    AimbotEnabled=false,AimbotSmooth=0.15,AimbotPart="Head",
    FOVEnabled=false,FOVRadius=150,FOVColor=Color3.fromRGB(255,255,255),
    AutoShoot=false,
    InfJump=false,BunnyHop=false,
    FlyEnabled=false,FlySpeed=50,
    SpeedEnabled=false,SpeedValue=40,
    NoclipOn=false,NoFallOn=false,FullBright=false,AntiAFK=false,
}

-- FOV
local FOVDraw=Drawing.new("Circle")
FOVDraw.Visible=false;FOVDraw.Thickness=1.5;FOVDraw.Filled=false
FOVDraw.NumSides=128;FOVDraw.Radius=150;FOVDraw.Color=Color3.fromRGB(255,255,255)

-- ESP
local ESPObjects={}
local function clearESP(p)
    if not ESPObjects[p] then return end
    if ESPObjects[p].hl then ESPObjects[p].hl:Destroy() end
    if ESPObjects[p].box then for _,l in pairs(ESPObjects[p].box) do l:Remove() end end
    if ESPObjects[p].tr then ESPObjects[p].tr:Remove() end
    if ESPObjects[p].nm then ESPObjects[p].nm:Remove() end
    if ESPObjects[p].hb then ESPObjects[p].hb:Remove() end
    if ESPObjects[p].hbbg then ESPObjects[p].hbbg:Remove() end
    ESPObjects[p]=nil
end
local function applyESP(p)
    clearESP(p)
    if p==LP then return end
    local obj={}
    if Cfg.ESPEnabled then
        if Cfg.ESPMode=="Highlight" then
            local hl=Instance.new("Highlight")
            hl.FillColor=Cfg.ESPColor;hl.OutlineColor=Cfg.ESPColor
            hl.FillTransparency=Cfg.ESPTransp
            hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
            if p.Character then hl.Parent=p.Character end
            p.CharacterAdded:Connect(function(c) hl.Parent=c end)
            obj.hl=hl
        elseif Cfg.ESPMode=="Box" then
            local lines={}
            for i=1,4 do local l=Drawing.new("Line");l.Visible=false;l.Color=Cfg.ESPColor;l.Thickness=1.5;lines[i]=l end
            obj.box=lines
        elseif Cfg.ESPMode=="Tracer" then
            local t=Drawing.new("Line");t.Visible=false;t.Color=Cfg.ESPColor;t.Thickness=1.5;obj.tr=t
        end
    end
    if Cfg.NameESP then
        local n=Drawing.new("Text");n.Visible=false;n.Size=13;n.Center=true;n.Outline=true;n.Color=Color3.fromRGB(255,255,255);obj.nm=n
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

local function isVisible(part)
    local ray=Ray.new(Camera.CFrame.Position,(part.Position-Camera.CFrame.Position).Unit*500)
    local hit=workspace:FindPartOnRayWithIgnoreList(ray,{LP.Character,workspace.Terrain})
    return hit and hit:IsDescendantOf(part.Parent)
end

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
                        if d<bestD and isVisible(part) then bestD=d;best={part=part,player=p} end
                    end
                end
            end
        end
    end
    return best
end

-- Auto Shoot
local VIM=game:GetService("VirtualInputManager")
local asCooldown=false
RunService.Heartbeat:Connect(function()
    if not Cfg.AutoShoot or asCooldown then return end
    local t=getTarget()
    if t then
        asCooldown=true
        task.spawn(function()
            local sp,onScreen=Camera:WorldToScreenPoint(t.part.Position)
            if onScreen then
                VIM:SendMouseButtonEvent(sp.X,sp.Y,0,true,game,0)
                task.wait(0.05)
                VIM:SendMouseButtonEvent(sp.X,sp.Y,0,false,game,0)
            end
            task.wait(0.15)
            asCooldown=false
        end)
    end
end)

-- Fly
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

RunService.RenderStepped:Connect(function()
    FOVDraw.Visible=Cfg.FOVEnabled;FOVDraw.Radius=Cfg.FOVRadius;FOVDraw.Color=Cfg.FOVColor
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
                if vis then obj.tr.From=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y);obj.tr.To=Vector2.new(pos.X,pos.Y);obj.tr.Color=Cfg.ESPColor;obj.tr.Visible=true
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
        if t then Camera.CFrame=Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position,t.part.Position),Cfg.AimbotSmooth) end
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
        if h then
            h.WalkSpeed=Cfg.SpeedEnabled and Cfg.SpeedValue or 16
            if Cfg.BunnyHop and h:GetState()==Enum.HumanoidStateType.Landed then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)
RunService.Stepped:Connect(function()
    if Cfg.NoclipOn and LP.Character then
        for _,p in pairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
    end
end)
LP.CharacterAdded:Connect(function(char)
    local h=char:WaitForChild("Humanoid")
    h.StateChanged:Connect(function(_,new)
        if Cfg.NoFallOn and new==Enum.HumanoidStateType.Freefall then h:ChangeState(Enum.HumanoidStateType.Running) end
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
-- BUILD PAGES
-- ================================================
local CMAP={Red=Color3.fromRGB(255,0,0),Green=Color3.fromRGB(0,255,0),Blue=Color3.fromRGB(0,100,255),
    Yellow=Color3.fromRGB(255,255,0),Purple=Color3.fromRGB(180,0,255),Cyan=Color3.fromRGB(0,255,255),
    White=Color3.fromRGB(255,255,255),Orange=Color3.fromRGB(255,140,0)}

-- ESP
makeSideTab("ESP")
local espP=newPage("ESP")
makeToggle(espP,"Enable ESP",false,function(v) Cfg.ESPEnabled=v;refreshESP() end)
makeDropdown(espP,"Mode",{"Highlight","Box","Tracer"},"Highlight",function(v) Cfg.ESPMode=v;refreshESP() end)
makeDropdown(espP,"Color",{"Red","Green","Blue","Yellow","Purple","Cyan","White","Orange"},"Red",function(v)
    if CMAP[v] then Cfg.ESPColor=CMAP[v];refreshESP() end
end)
makeSlider(espP,"Transparency",0,10,5,1,function(v) Cfg.ESPTransp=v/10;refreshESP() end)
makeToggle(espP,"Name ESP",false,function(v) Cfg.NameESP=v;refreshESP() end)
makeToggle(espP,"Health Bar",false,function(v) Cfg.HealthBar=v;refreshESP() end)

-- Aimbot
makeSideTab("Aim")
local aimP=newPage("Aim")
makeToggle(aimP,"Aimbot",false,function(v) Cfg.AimbotEnabled=v end)
makeToggle(aimP,"Auto Shoot",false,function(v) Cfg.AutoShoot=v end)
makeToggle(aimP,"FOV Circle",false,function(v) Cfg.FOVEnabled=v end)
makeSlider(aimP,"FOV Size",30,500,150,5,function(v) Cfg.FOVRadius=v end)
makeSlider(aimP,"Smoothness",1,100,15,1,function(v) Cfg.AimbotSmooth=v/100 end)
makeDropdown(aimP,"Aim Part",{"Head","HumanoidRootPart","UpperTorso"},"Head",function(v) Cfg.AimbotPart=v end)
makeDropdown(aimP,"FOV Color",{"White","Yellow","Red","Green","Cyan"},"White",function(v)
    local c={White=Color3.fromRGB(255,255,255),Yellow=Color3.fromRGB(255,255,0),Red=Color3.fromRGB(255,0,0),Green=Color3.fromRGB(0,255,0),Cyan=Color3.fromRGB(0,255,255)}
    if c[v] then Cfg.FOVColor=c[v] end
end)

-- Move
makeSideTab("Move")
local moveP=newPage("Move")
makeToggle(moveP,"Inf Jump",false,function(v) Cfg.InfJump=v end)
makeToggle(moveP,"BunnyHop",false,function(v) Cfg.BunnyHop=v end)
makeToggle(moveP,"Fly",false,function(v) Cfg.FlyEnabled=v;toggleFly(v) end)
makeSlider(moveP,"Fly Speed",10,200,50,5,function(v) Cfg.FlySpeed=v end)
makeToggle(moveP,"Speed",false,function(v) Cfg.SpeedEnabled=v end)
makeSlider(moveP,"Walk Speed",16,200,40,1,function(v) Cfg.SpeedValue=v end)
makeToggle(moveP,"Noclip",false,function(v) Cfg.NoclipOn=v end)
makeToggle(moveP,"No Fall",false,function(v) Cfg.NoFallOn=v end)

-- Misc
makeSideTab("Misc")
local miscP=newPage("Misc")
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
makeButton(miscP,"Teleport Spawn",function()
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

-- About
makeSideTab("About")
local aboutP=newPage("About")
local aCard=frame(aboutP,UDim2.new(1,0,0,130),nil,Color3.fromRGB(18,19,28))
aCard.ZIndex=14;corner(aCard,8);stroke(aCard,Color3.fromRGB(180,20,45),1)
local aImg=Instance.new("ImageLabel")
aImg.Size=UDim2.new(0,50,0,50);aImg.Position=UDim2.new(0.5,-25,0,10)
aImg.BackgroundTransparency=1;aImg.Image="rbxassetid://7072725450"
aImg.ImageColor3=Color3.fromRGB(220,30,60);aImg.ScaleType=Enum.ScaleType.Fit
aImg.ZIndex=15;aImg.Parent=aCard
RunService.Heartbeat:Connect(function() aImg.ImageColor3=Color3.fromHSV(hue,0.85,1) end)
label(aCard,"@Primejtsu",12,Color3.fromRGB(220,215,255),Enum.Font.GothamBold,UDim2.new(0,0,0,66),UDim2.new(1,0,0,20)).ZIndex=15
label(aCard,"Steal a Brainrot Script",10,Color3.fromRGB(160,150,200),Enum.Font.Gotham,UDim2.new(0,0,0,84),UDim2.new(1,0,0,18)).ZIndex=15
label(aCard,"Version: v1.0",10,Color3.fromRGB(120,110,160),Enum.Font.Gotham,UDim2.new(0,0,0,100),UDim2.new(1,0,0,18)).ZIndex=15
makeButton(aboutP,"Telegram: t.me/Primejtsu",function()
    -- notify
    local n=frame(SG,UDim2.new(0,240,0,48),UDim2.new(1,10,1,-60),Color3.fromRGB(18,19,28))
    n.ZIndex=200;corner(n,8);stroke(n,Color3.fromRGB(30,80,180),1)
    label(n,"t.me/Primejtsu",12,Color3.fromRGB(200,220,255),Enum.Font.GothamBold,UDim2.new(0,10,0,0),UDim2.new(1,-16,1,0)).ZIndex=201
    tw(n,{Position=UDim2.new(1,-250,1,-60)},0.3,Enum.EasingStyle.Back)
    task.delay(3,function() tw(n,{Position=UDim2.new(1,10,1,-60)},0.3);task.wait(0.3);n:Destroy() end)
end)

-- Show first tab
showPage("ESP")
tw(tabBtns[1],{BackgroundColor3=Color3.fromRGB(180,20,45),TextColor3=Color3.fromRGB(255,255,255)},0)

-- ================================================
-- STARTUP NOTIFICATION
-- ================================================
task.wait(13.5)
local notif=frame(SG,UDim2.new(0,260,0,68),UDim2.new(1,280,1,-80),Color3.fromRGB(14,15,22))
notif.ZIndex=200;corner(notif,10)
local nStroke=stroke(notif,Color3.fromRGB(220,30,60),1.5)
RunService.Heartbeat:Connect(function() nStroke.Color=Color3.fromHSV(hue,0.85,1) end)
local nImg=Instance.new("ImageLabel")
nImg.Size=UDim2.new(0,44,0,44);nImg.Position=UDim2.new(0,10,0.5,-22)
nImg.BackgroundTransparency=1;nImg.Image="rbxassetid://7072725450"
nImg.ImageColor3=Color3.fromRGB(220,30,60);nImg.ScaleType=Enum.ScaleType.Fit
nImg.ZIndex=201;nImg.Parent=notif
label(notif,"Primejtsu X",13,Color3.fromRGB(220,215,255),Enum.Font.GothamBold,UDim2.new(0,60,0,8),UDim2.new(1,-68,0,22)).ZIndex=201
label(notif,"Thank you for choosing us!",10,Color3.fromRGB(160,150,200),Enum.Font.Gotham,UDim2.new(0,60,0,28),UDim2.new(1,-68,0,18)).ZIndex=201
label(notif,"Спасибо что выбрали нас!",10,Color3.fromRGB(120,110,160),Enum.Font.Gotham,UDim2.new(0,60,0,44),UDim2.new(1,-68,0,18)).ZIndex=201
tw(notif,{Position=UDim2.new(1,-270,1,-80)},0.4,Enum.EasingStyle.Back)
task.delay(5,function()
    tw(notif,{Position=UDim2.new(1,280,1,-80)},0.3)
    task.wait(0.35);notif:Destroy()
end)

print("[PJTSU UI] Steal a Brainrot Script v1.0 Loaded.")
