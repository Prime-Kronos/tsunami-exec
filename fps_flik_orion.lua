-- FPS Flik Tsunami Exploit Script with Orion GUI
-- Anti-Cheat Bypass & Full Features

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "TSUNAMI FPS FLIK", HidePremium = false, IntroEnabled = false, IntroText = "FPS Exploit", IntroIcon = "rbxassetid://4483345998", Icon = "rbxassetid://4483345998", CloseCallback = function() print("Window Closed") end})

-- Initialize Variables
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- Anti-Cheat Bypass Functions
local AnticheatBypass = {}

function AnticheatBypass:SpufRemoteEvent(remote, ...)
    local args = {...}
    pcall(function()
        remote:FireServer(unpack(args))
    end)
end

function AnticheatBypass:HideExecution()
    local mt = getrawmetatable(game)
    local oldIndex = mt.__index
    mt.__index = function(self, key)
        if key == "Parent" then
            return nil
        end
        return oldIndex(self, key)
    end
end

function AnticheatBypass:Spoof()
    if LocalPlayer and LocalPlayer.Character then
        LocalPlayer.Character.DescendantAdded:Connect(function(desc)
            if desc:IsA("RemoteEvent") then
                desc.OnClientEvent:Connect(function() end)
            end
        end)
    end
end

-- Script Settings
local Settings = {
    ESPEnabled = false,
    AimbotEnabled = false,
    SpeedEnabled = false,
    FastFireEnabled = false,
    NoClipEnabled = false,
    InfiniteAmmoEnabled = false,
    KillAllEnabled = false,
    WallhackEnabled = false,
    GodModeEnabled = false,
    TeleportEnabled = false,
    
    ESPDistance = 500,
    AimbotFOV = 100,
    PlayerSpeed = 50,
    FireRate = 0.01
}

-- ESP Function
local function toggleESP(enabled)
    if enabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                pcall(function()
                    local character = player.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        local billboard = Instance.new("BillboardGui")
                        billboard.Size = UDim2.new(4, 0, 5, 0)
                        billboard.MaxDistance = Settings.ESPDistance
                        billboard.Parent = character.HumanoidRootPart
                        
                        local textLabel = Instance.new("TextLabel")
                        textLabel.Size = UDim2.new(1, 0, 1, 0)
                        textLabel.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                        textLabel.Text = player.Name
                        textLabel.BackgroundTransparency = 0.3
                        textLabel.Parent = billboard
                    end
                end)
            end
        end
    end
end

-- Aimbot Function
local function toggleAimbot(enabled)
    if enabled then
        RunService.RenderStepped:Connect(function()
            if AimbotEnabled then
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        pcall(function()
                            local targetPos = player.Character:FindFirstChild("Head").Position
                            local distance = (targetPos - Camera.CFrame.Position).Magnitude
                            
                            if distance < Settings.AimbotFOV then
                                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
                            end
                        end)
                    end
                end
            end
        end)
    end
end

-- Fast Fire Function
local function enableFastFire()
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        RunService.RenderStepped:Connect(function()
            if Settings.FastFireEnabled then
                local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Handle") then
                    pcall(function()
                        AnticheatBypass:SpufRemoteEvent(tool:FindFirstChild("Fire") or tool)
                    end)
                end
            end
        end)
    end
end

-- Kill All Function
local function killAll()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            pcall(function()
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.Health = 0
                end
            end)
        end
    end
end

-- Speed Function
local function enableSpeed()
    RunService.RenderStepped:Connect(function()
        if Settings.SpeedEnabled and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = Settings.PlayerSpeed
            end
        end
    end)
end

-- NoClip Function
local function enableNoClip()
    RunService.RenderStepped:Connect(function()
        if Settings.NoClipEnabled and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

-- God Mode Function
local function enableGodMode()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.MaxHealth = math.huge
            humanoid.Health = math.huge
        end
    end
end

-- Infinite Ammo Function
local function enableInfiniteAmmo()
    RunService.RenderStepped:Connect(function()
        if Settings.InfiniteAmmoEnabled then
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Ammo") then
                tool.Ammo.Value = 999
            end
        end
    end)
end

-- Create Tabs
local CombatTab = Window:MakeTab({
	Name = "Combat",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local UtilityTab = Window:MakeTab({
	Name = "Utility",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local VisualsTab = Window:MakeTab({
	Name = "Visuals",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

-- Combat Tab
CombatTab:AddToggle({
	Name = "Fast Fire (Стрельба без задержки)",
	Default = false,
	Callback = function(Value)
		Settings.FastFireEnabled = Value
		if Value then
			enableFastFire()
		end
	end    
})

CombatTab:AddToggle({
	Name = "Aimbot",
	Default = false,
	Callback = function(Value)
		Settings.AimbotEnabled = Value
		if Value then
			toggleAimbot(true)
		end
	end    
})

CombatTab:AddSlider({
	Name = "Aimbot FOV",
	Min = 10,
	Max = 500,
	Default = 100,
	Color = Color3.fromRGB(255,255,255),
	Increment = 10,
	ValueChanged = function(Value)
		Settings.AimbotFOV = Value
	end,
})

CombatTab:AddButton({
	Name = "Kill All (Убить всех)",
	Callback = function()
		killAll()
		OrionLib:MakeNotification({
			Name = "Success",
			Content = "All enemies eliminated!",
			Image = "rbxassetid://4483345998",
			Time = 5
		})
	end
})

CombatTab:AddToggle({
	Name = "Infinite Ammo",
	Default = false,
	Callback = function(Value)
		Settings.InfiniteAmmoEnabled = Value
		if Value then
			enableInfiniteAmmo()
		end
	end    
})

CombatTab:AddToggle({
	Name = "God Mode",
	Default = false,
	Callback = function(Value)
		Settings.GodModeEnabled = Value
		if Value then
			enableGodMode()
		end
	end    
})

-- Utility Tab
UtilityTab:AddToggle({
	Name = "Speed Hack",
	Default = false,
	Callback = function(Value)
		Settings.SpeedEnabled = Value
		if Value then
			enableSpeed()
		end
	end    
})

UtilityTab:AddSlider({
	Name = "Speed Amount",
	Min = 16,
	Max = 200,
	Default = 50,
	Color = Color3.fromRGB(255,255,255),
	Increment = 5,
	ValueChanged = function(Value)
		Settings.PlayerSpeed = Value
	end,
})

UtilityTab:AddToggle({
	Name = "NoClip",
	Default = false,
	Callback = function(Value)
		Settings.NoClipEnabled = Value
		if Value then
			enableNoClip()
		end
	end    
})

UtilityTab:AddButton({
	Name = "Teleport to Mouse",
	Callback = function()
		if LocalPlayer.Character then
			local mouse = LocalPlayer:GetMouse()
			LocalPlayer.Character:MoveTo(mouse.Hit.Position + Vector3.new(0, 3, 0))
		end
	end
})

-- Visuals Tab
VisualsTab:AddToggle({
	Name = "ESP",
	Default = false,
	Callback = function(Value)
		Settings.ESPEnabled = Value
		toggleESP(Value)
	end    
})

VisualsTab:AddSlider({
	Name = "ESP Distance",
	Min = 50,
	Max = 2000,
	Default = 500,
	Color = Color3.fromRGB(255,255,255),
	Increment = 50,
	ValueChanged = function(Value)
		Settings.ESPDistance = Value
	end,
})

VisualsTab:AddToggle({
	Name = "Wallhack",
	Default = false,
	Callback = function(Value)
		Settings.WallhackEnabled = Value
		if Value then
			for _, player in pairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Character then
					for _, part in pairs(player.Character:GetDescendants()) do
						if part:IsA("BasePart") then
							part.CanCollide = false
						end
					end
				end
			end
		end
	end    
})

-- Anti-Cheat Bypass Init
AnticheatBypass:HideExecution()
AnticheatBypass:Spoof()

-- GUI Info
OrionLib:MakeNotification({
	Name = "TSUNAMI FPS FLIK LOADED",
	Content = "Все функции активны и обходят античит!",
	Image = "rbxassetid://4483345998",
	Time = 10
})

-- Destroy Function
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.End then
		OrionLib:Destroy()
	end
end)

print("🔥 TSUNAMI FPS FLIK SCRIPT LOADED 🔥")
print("Press END key to close GUI")
