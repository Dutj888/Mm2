-- Dutj MM2 Script Optimized with ESP, Silent Aim, Knife Aimbot, Esp Gun
-- Supports PC & Mobile (menu có thể kéo)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- GUI setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DutjMM2GUI"
ScreenGui.Parent = game.CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.BackgroundColor3 = Color3.new(0,0,0)
mainFrame.BackgroundTransparency = 0.5
mainFrame.Size = UDim2.new(0, 220, 0, 250)
mainFrame.Position = UDim2.new(0, 10, 0.3, 0)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = ScreenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Dutj MM2 Script"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 22
title.Parent = mainFrame

local function createToggle(text, posY)
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Font = Enum.Font.SourceSans
    label.TextSize = 18
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, posY)
    label.Size = UDim2.new(0.6, 0, 0, 25)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = mainFrame

    local button = Instance.new("TextButton")
    button.Text = "OFF"
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 18
    button.TextColor3 = Color3.new(1, 1, 1)
    button.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    button.Size = UDim2.new(0.3, 0, 0, 25)
    button.Position = UDim2.new(0.65, 0, 0, posY)
    button.Parent = mainFrame

    local enabled = false
    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        button.Text = enabled and "ON" or "OFF"
        if text == "ESP" then
            Enabled.ESP = enabled
        elseif text == "Silent Aim" then
            Enabled.SilentAim = enabled
        elseif text == "Knife Aimbot" then
            Enabled.KnifeAimbot = enabled
        elseif text == "ESP Gun" then
            Enabled.ESPgun = enabled
        end
    end)

    return button
end

local function createSlider(text, posY, min, max, default)
    local label = Instance.new("TextLabel")
    label.Text = text..": "..default
    label.Font = Enum.Font.SourceSans
    label.TextSize = 18
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, posY)
    label.Size = UDim2.new(1, -20, 0, 25)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = mainFrame

    local slider = Instance.new("TextBox")
    slider.Text = tostring(default)
    slider.Font = Enum.Font.SourceSans
    slider.TextSize = 18
    slider.TextColor3 = Color3.new(1, 1, 1)
    slider.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    slider.Size = UDim2.new(0.3, 0, 0, 25)
    slider.Position = UDim2.new(0.65, 0, 0, posY)
    slider.ClearTextOnFocus = false
    slider.Parent = mainFrame

    slider.FocusLost:Connect(function(enterPressed)
        local val = tonumber(slider.Text)
        if val and val >= min and val <= max then
            label.Text = text..": "..val
            if text == "Aim Sensitivity" then
                AimSensitivity = val
            end
        else
            slider.Text = tostring(default)
        end
    end)

    return slider
end

local Enabled = {
    ESP = false,
    SilentAim = false,
    KnifeAimbot = false,
    ESPgun = false,
}

local AimSensitivity = 0.5

-- ESP code
local espObjects = {}

local function createBox(player, color)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = color
    box.Thickness = 2
    box.Transparency = 1
    box.Filled = false
    return box
end

local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local rootPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen and Enabled.ESP then
                if not espObjects[player] then
                    local team = player.Team
                    local color = Color3.new(1,1,1)
                    if team == LocalPlayer.Team then
                        color = Color3.new(1,1,1) -- innocent - white
                    elseif team.Name == "Murderer" then
                        color = Color3.new(1,0,0) -- murderer - red
                    elseif team.Name == "Sheriff" then
                        color = Color3.new(0,0,1) -- sheriff - blue
                    end
                    espObjects[player] = createBox(player, color)
                end
                local box = espObjects[player]
                local root = player.Character.HumanoidRootPart
                local size = 100 / rootPos.Z
                box.Size = Vector2.new(size, size)
                box.Position = Vector2.new(rootPos.X - size/2, rootPos.Y - size/2)
                box.Visible = true
            else
                if espObjects[player] then
                    espObjects[player].Visible = false
                end
            end
        elseif espObjects[player] then
            espObjects[player].Visible = false
        end
    end
end

-- Silent Aim (simplified example)
local mt = getrawmetatable(game)
local oldIndex = mt.__index
setreadonly(mt, false)

mt.__index = newcclosure(function(self, key)
    if Enabled.SilentAim and key == "Hit" and self == workspace.CurrentCamera then
        local closestPlayer
        local closestDist = math.huge
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                if player.Team ~= LocalPlayer.Team then
                    local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(player.Character.Head.Position)
                    if onScreen then
                        local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist < closestDist and dist < 150 then
                            closestDist = dist
                            closestPlayer = player
                        end
                    end
                end
            end
        end
        if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("Head") then
            return closestPlayer.Character.Head
        end
    end
    return oldIndex(self, key)
end)

setreadonly(mt, true)

-- Knife Aimbot (simple head lock)
local function KnifeAimbot()
    if not Enabled.KnifeAimbot then return end
    local closestPlayer
    local closestDist = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if player.Team ~= LocalPlayer.Team then
                local dist = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if dist < closestDist and dist < 20 then
                    closestDist = dist
                    closestPlayer = player
                end
            end
        end
    end
    if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("Head") then
        workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, closestPlayer.Character.Head.Position)
    end
end

-- ESP Gun (simplified)
local gunESP = {}

local function UpdateEspGun()
    for _, gun in pairs(workspace:GetChildren()) do
        if gun:IsA("Tool") and Enabled.ESPgun then
            if not gunESP[gun] then
                local box = Drawing.new("Square")
                box.Visible = true
                box.Color = Color3.new(1,1,0)
                box.Thickness = 2
                box.Transparency = 1
                box.Filled = false
                gunESP[gun] = box
            end
            local box = gunESP[gun]
            local rootPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(gun.Handle.Position)
            if onScreen then
                local size = 50 / rootPos.Z
                box.Size = Vector2.new(size, size)
                box.Position = Vector2.new(rootPos.X - size/2, rootPos.Y - size/2)
                box.Visible = true
            else
                box.Visible = false
            end
        elseif gunESP[gun] then
            gunESP[gun]:Remove()
            gunESP[gun] = nil
        end
    end
end

-- Create toggles
local espToggle = createToggle("ESP", 40)
local silentAimToggle = createToggle("Silent Aim", 75)
local knifeAimbotToggle = createToggle("Knife Aimbot", 110)
local espGunToggle = createToggle("ESP Gun", 145)

local aimSensitivitySlider = createSlider("Aim Sensitivity", 180, 0.1, 1, 0.5)

-- Main loop
RunService.RenderStepped:Connect(function()
    updateESP()
    UpdateEspGun()
    if Enabled.KnifeAimbot then
        KnifeAimbot()
    end
end)
