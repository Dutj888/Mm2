-- Made by Dutj
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "DutjMM2Menu"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 260)
frame.Position = UDim2.new(0, 10, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Text = "Made by Dutj"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true

function createToggle(name, default, parent, callback)
	local toggle = Instance.new("TextButton", parent)
	toggle.Size = UDim2.new(1, -20, 0, 30)
	toggle.Position = UDim2.new(0, 10, 0, (#parent:GetChildren() - 1) * 35)
	toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggle.Text = name .. ": " .. (default and "ON" or "OFF")
	toggle.TextScaled = true

	local state = default
	toggle.MouseButton1Click:Connect(function()
		state = not state
		toggle.Text = name .. ": " .. (state and "ON" or "OFF")
		callback(state)
	end)

	return toggle
end

local settings = {
	ESP = false,
	SilentAim = false,
	KnifeAimbot = false
}

local function updateESP()
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
			if not player.Character:FindFirstChild("ESP") then
				local esp = Instance.new("BillboardGui", player.Character.Head)
				esp.Name = "ESP"
				esp.Size = UDim2.new(0, 100, 0, 20)
				esp.AlwaysOnTop = true
				local name = Instance.new("TextLabel", esp)
				name.Size = UDim2.new(1, 0, 1, 0)
				name.BackgroundTransparency = 1
				name.TextColor3 = Color3.new(1, 1, 1)
				name.TextScaled = true
				name.Text = player.Name
			end
			local esp = player.Character.Head:FindFirstChild("ESP")
			local label = esp and esp:FindFirstChildWhichIsA("TextLabel")
			if label then
				if player:FindFirstChild("Backpack"):FindFirstChild("Knife") or player.Character:FindFirstChild("Knife") then
					label.TextColor3 = Color3.fromRGB(255, 0, 0) -- Murder
				elseif player:FindFirstChild("Backpack"):FindFirstChild("Gun") or player.Character:FindFirstChild("Gun") then
					label.TextColor3 = Color3.fromRGB(0, 0, 255) -- Sheriff
				else
					label.TextColor3 = Color3.fromRGB(255, 255, 255) -- Innocent
				end
			end
		end
	end
end

local aimTarget = nil
RunService.RenderStepped:Connect(function()
	if settings.SilentAim then
		local closest, distance = nil, math.huge
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
				local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(player.Character.Head.Position)
				if onScreen then
					local diff = (Vector2.new(pos.X, pos.Y) - Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y/2)).Magnitude
					if diff < distance then
						distance = diff
						closest = player
					end
				end
			end
		end
		aimTarget = closest
	end
end)

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
	local args = {...}
	if settings.SilentAim and getnamecallmethod() == "FindPartOnRayWithIgnoreList" and aimTarget and aimTarget.Character then
		local head = aimTarget.Character:FindFirstChild("Head")
		if head then
			args[1] = Ray.new(workspace.CurrentCamera.CFrame.Position, (head.Position - workspace.CurrentCamera.CFrame.Position).Unit * 1000)
			return oldNamecall(self, unpack(args))
		end
	end
	return oldNamecall(self, ...)
end)

local function knifeAimbot()
	if not settings.KnifeAimbot then return end
	local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Knife")
	if tool and tool:IsA("Tool") then
		local closest = nil
		local dist = math.huge
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
				local mag = (player.Character.Head.Position - LocalPlayer.Character.Head.Position).Magnitude
				if mag < dist then
					dist = mag
					closest = player
				end
			end
		end
		if closest then
			tool:Activate()
			workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, closest.Character.Head.Position)
		end
	end
end

local function gunESP()
	for _, v in pairs(workspace:GetChildren()) do
		if v:IsA("Tool") and v.Name == "GunDrop" and not v:FindFirstChild("GunESP") then
			local esp = Instance.new("BillboardGui", v.Handle)
			esp.Name = "GunESP"
			esp.Size = UDim2.new(0, 100, 0, 20)
			esp.AlwaysOnTop = true
			local label = Instance.new("TextLabel", esp)
			label.Size = UDim2.new(1, 0, 1, 0)
			label.BackgroundTransparency = 1
			label.TextColor3 = Color3.fromRGB(0, 255, 0)
			label.TextScaled = true
			label.Text = "Gun Drop"
		end
	end
end

createToggle("ESP", false, frame, function(val)
	settings.ESP = val
end)

createToggle("Silent Aim", false, frame, function(val)
	settings.SilentAim = val
end)

createToggle("Knife Aimbot", false, frame, function(val)
	settings.KnifeAimbot = val
end)

RunService.RenderStepped:Connect(function()
	if settings.ESP then updateESP() end
	if settings.ESP then gunESP() end
	if settings.KnifeAimbot then knifeAimbot() end
end)
