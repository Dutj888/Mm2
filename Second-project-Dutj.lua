-- MM2 Ultimate Script by Dutj
-- GUI kéo được, toggle ESP, Silent Aim 100%, Knife Aimbot
-- ESP Innocent: trắng | Murder: đỏ | Sheriff: xanh

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- Variables
local espEnabled = false
local silentAimEnabled = false
local knifeAimbotEnabled = false

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DutjMM2Gui"
ScreenGui.Parent = game.CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 270, 0, 370)
mainFrame.Position = UDim2.new(0, 50, 0, 120)
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = ScreenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1,0,0,30)
titleLabel.BackgroundColor3 = Color3.new(0,0,0)
titleLabel.TextColor3 = Color3.new(1,1,1)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 20
titleLabel.Text = "MM2 Script - Dutj"
titleLabel.Parent = mainFrame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 80, 0, 25)
toggleButton.Position = UDim2.new(1, 5, 0, 5)
toggleButton.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Text = "Ẩn/Hiện"
toggleButton.Font = Enum.Font.Gotham
toggleButton.TextSize = 14
toggleButton.Parent = mainFrame

toggleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

local function createToggle(name, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.Text = name .. ": OFF"
    btn.Parent = mainFrame
    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.Text = name .. (enabled and ": ON" or ": OFF")
        btn.BackgroundColor3 = enabled and Color3.fromRGB(0, 150, 0) or Color3.new(0.15, 0.15, 0.15)
        if name == "ESP" then
            espEnabled = enabled
            if not enabled then
                for _, p in pairs(Players:GetPlayers()) do
                    if p.Character and p.Character:FindFirstChild("Highlight") then
                        p.Character.Highlight:Destroy()
                    end
                end
            end
        elseif name == "Silent Aim" then
            silentAimEnabled = enabled
        elseif name == "Knife Aimbot" then
            knifeAimbotEnabled = enabled
        end
    end)
    return function() return enabled end
end

local getESPEnabled = createToggle("ESP", 50)
local getSilentAimEnabled = createToggle("Silent Aim", 100)
local getKnifeAimbotEnabled = createToggle("Knife Aimbot", 150)

-- Highlight ESP
local function createHighlight(character, color)
    if character:FindFirstChild("Highlight") then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "Highlight"
    highlight.FillColor = color
    highlight.OutlineColor = Color3.new(0, 0, 0)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character
end

local function removeHighlight(character)
    local h = character:FindFirstChild("Highlight")
    if h then h:Destroy() end
end

local function getPlayerRole(player)
    local teamName = player.Team and player.Team.Name or ""
    if teamName:lower():find("murder") then
        return "Murder"
    elseif teamName:lower():find("sheriff") then
        return "Sheriff"
    elseif teamName:lower():find("innocent") then
        return "Innocent"
    else
        return "Unknown"
    end
end

-- ESP loop
spawn(function()
    while true do
        if espEnabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local role = getPlayerRole(player)
                    if not player.Character:FindFirstChild("Highlight") then
                        local color = Color3.new(1,1,1)
                        if role == "Murder" then
                            color = Color3.fromRGB(255, 0, 0)
                        elseif role == "Sheriff" then
                            color = Color3.fromRGB(0, 0, 255)
                        end
                        createHighlight(player.Character, color)
                    end
                elseif player.Character then
                    removeHighlight(player.Character)
                end
            end
        else
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character then
                    removeHighlight(player.Character)
                end
            end
        end
        wait(1)
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        wait(1)
        if espEnabled then
            local role = getPlayerRole(player)
            local color = Color3.new(1,1,1)
            if role == "Murder" then color = Color3.fromRGB(255, 0, 0) end
            if role == "Sheriff" then color = Color3.fromRGB(0, 0, 255) end
            createHighlight(char, color)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if player.Character then
        removeHighlight(player.Character)
    end
end)

-- Helper for wall check (simple raycast)
local function canSeeTarget(targetPart)
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * 500
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    if raycastResult then
        if raycastResult.Instance and raycastResult.Instance:IsDescendantOf(targetPart.Parent) then
            return true
        else
            return false
        end
    else
        return false
    end
end

-- Get closest target head for silent aim or knife aimbot
local function getClosestTarget()
    local closestDist = math.huge
    local target = nil
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            -- Team check
            local localTeam = LocalPlayer.Team and LocalPlayer.Team.Name or ""
            local playerTeam = player.Team and player.Team.Name or ""
            if localTeam == playerTeam then
                continue
            end
            -- Wall check
            if not canSeeTarget(player.Character.Head) then
                continue
            end
            -- Distance check
            local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                local targetPos = Vector2.new(screenPos.X, screenPos.Y)
                local dist = (mousePos - targetPos).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    target = player
                end
            end
        end
    end
    return target
end

-- Silent Aim
local mt = getrawmetatable(game)
local oldIndex = mt.__index
setreadonly(mt, false)

mt.__index = newcclosure(function(self, key)
    if silentAimEnabled and self == Mouse and key == "Hit" then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            return CFrame.new(target.Character.Head.Position)
        end
    end
    return oldIndex(self, key)
end)

setreadonly(mt, true)

-- Knife Aimbot
local UserInput = UserInputService
local KnifeRange = 15 -- Adjust range if needed

UserInput.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if knifeAimbotEnabled and input.UserInputType == Enum.UserInputType.MouseButton1 then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and target.Character:FindFirstChild("Head") then
            local headPos = Camera:WorldToViewportPoint(target.Character.Head.Position)
            if headPos.Z > 0 then
                -- Simulate moving mouse to target head
                -- This line may need to be replaced depending on exploit environment:
                mousemoverel(headPos.X - Mouse.X, headPos.Y - Mouse.Y)
            end
        end
    end
end)

print("MM2 Script by Dutj loaded! Enjoy!")
