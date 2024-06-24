-- Services
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local WS = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local Camera = WS.CurrentCamera
local Mouse = Players.LocalPlayer:GetMouse()

-- Variables
local LP = Players.LocalPlayer
local AimlockState = true
local Locked
local Victim
local Highlight

-- Convert the selected key to Enum.KeyCode
local function getKeyCode(key)
    key = key:upper()
    return Enum.KeyCode[key]
end

local SelectedKeyCode = getKeyCode(getgenv().SelectedKey)

-- Wait for FULLY_LOADED_CHAR folder
local function waitForFullyLoadedChar()
    while not LP.Character or not LP.Character:FindFirstChild("FULLY_LOADED_CHAR") do
        task.wait(0.1)
    end
end

waitForFullyLoadedChar()

-- Check if aimlock is already loaded
if getgenv().Loaded then
    print("Already Loaded!")
    return
end
getgenv().Loaded = true

-- Function to get the closest visible target within proximity threshold
local function getClosest()
    local closestPlayer
    local shortestDistance = getgenv().ProximityThreshold

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 and v.Character:FindFirstChild(getgenv().AimPart) then
            local pos = Camera:WorldToViewportPoint(v.Character[getgenv().AimPart].Position)
            local screenPos = Vector2.new(pos.X, pos.Y)
            local distance = (screenPos - Vector2.new(Mouse.X, Mouse.Y)).magnitude

            if distance < shortestDistance then
                closestPlayer = v
                shortestDistance = distance
            end
        end
    end
    return closestPlayer, shortestDistance
end

-- Function to create a rainbow color effect
local function getRainbowColor()
    local hue = tick() % 5 / 5
    return Color3.fromHSV(hue, 1, 1)
end

-- Function to update the Highlight color in a loop
local function updateHighlightColor()
    while Victim and Highlight do
        Highlight.FillColor = getRainbowColor()
        Highlight.OutlineColor = getRainbowColor()
        task.wait(0.1)
    end
end

-- Keybind to toggle aimlock
UIS.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == SelectedKeyCode then
        if AimlockState then
            Locked = not Locked
            if Locked then
                Victim = getClosest()
                if Victim then
                    if Highlight then
                        Highlight:Destroy()
                    end
                    Highlight = Instance.new("Highlight")
                    Highlight.Parent = Victim.Character
                    Highlight.Adornee = Victim.Character[getgenv().AimPart]
                    coroutine.wrap(updateHighlightColor)()  -- Start the color update loop
                end
            else
                if Victim then
                    Victim = nil
                    if Highlight then
                        Highlight:Destroy()
                        Highlight = nil
                    end
                end
            end
        end
    end
end)

-- Update camera to follow target
RS.RenderStepped:Connect(function()
    if AimlockState and Victim then
        local shakeOffset = Vector3.new(
            (math.random() - 0.5) * getgenv().ShakeValue,
            (math.random() - 0.5) * getgenv().ShakeValue,
            (math.random() - 0.5) * getgenv().ShakeValue
        )

        local targetPosition = Victim.Character[getgenv().AimPart].Position + (Victim.Character.HumanoidRootPart.Velocity * getgenv().Prediction)
        local lookAt = CFrame.new(Camera.CFrame.Position, targetPosition + shakeOffset)
        Camera.CFrame = lookAt  -- Directly set the camera CFrame for faster aiming
    end
end)

-- Auto adjust prediction based on ping
while task.wait() do
    if getgenv().AutoPred then
        local pingValue = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
        local ping = tonumber(string.match(pingValue, "%d+"))
        if ping < 50 then
            getgenv().Prediction = 0.1
        elseif ping < 100 then
            getgenv().Prediction = 0.125
        elseif ping < 150 then
            getgenv().Prediction = 0.15
        else
            getgenv().Prediction = 0.165
        end
    end
end
