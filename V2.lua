local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local WS = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local Camera = WS.CurrentCamera
local Mouse = Players.LocalPlayer:GetMouse()
local TweenService = game:GetService("TweenService")

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

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Function to fetch the profile image
local function getProfileImage(userId)
    local content, isReady = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    return content
end

-- Check if aimlock is already loaded
if getgenv().Loaded then
    local profileImage = getProfileImage(LP.UserId)
    createNotification("Deeplock", "<b>DeepLock</b> is already loaded!", profileImage)
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
                    local victimProfileImage = getProfileImage(Victim.UserId)
                    createNotification("Aimlock Activated", "Target: ".. Victim.Name, victimProfileImage)
                else
                    createNotification("Aimlock Activated", "No target found")
                end
            else
                if Victim then
                    Victim = nil
                    if Highlight then
                        Highlight:Destroy()
                        Highlight = nil
                    end
                    createNotification("Aimlock Deactivated", "Target lost")
                end
            end
        end
    end
end)

RS.RenderStepped:Connect(function()
    if AimlockState and Victim then
        local targetPart = Victim.Character[AimPart]
        if targetPart then
            -- Store the lastknown position of the victim
            table.insert(victimPositions, targetPart.Position)
            if #victimPositions > 10 then
                table.remove(victimPositions, 1)
            end
            
            -- Calculate the average velocity of the victim
            local velocity = Vector3.new(0, 0, 0)
            for i = 1, #victimPositions - 1 do
                velocity = velocity + (victimPositions[i + 1] - victimPositions[i])
            end
            velocity = velocity / (#victimPositions - 1)
            
            -- Predict the future position of the victim
            local targetPosition = targetPart.Position
            local predictedPosition = targetPosition + (velocity * Prediction)
            
            -- Use raycasting to ensure the target is hit accurately
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            raycastParams.FilterDescendantsInstances = {LP.Character}
            local rayDirection = (predictedPosition - Camera.CFrame.Position).Unit * 1000
            local rayResult = WS:Raycast(Camera.CFrame.Position, rayDirection, raycastParams)
            
            if rayResult and rayResult.Instance and rayResult.Instance:IsDescendantOf(Victim.Character) then
                -- Adjust the camera to aim at the exact hit position
                local hitPosition = rayResult.Position
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, hitPosition), Smoothness * RS.DeltaTime)
            else
                -- Fallback to predicted position if raycast fails
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, predictedPosition), Smoothness * RS.DeltaTime)
            end
        end
    end
end)

-- Auto adjust prediction based on ping
while task.wait() do
    if getgenv().AutoPred then
        local pingValue = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
        local ping = tonumber(string.match(pingValue, "%d+"))
        if ping < 5 then
            getgenv().Prediction = 0.08
        elseif ping < 10 then
            getgenv().Prediction = 0.09
        elseif ping < 20 then
            getgenv().Prediction = 0.1
        elseif ping < 30 then
            getgenv().Prediction = 0.11
        elseif ping < 40 then
            getgenv().Prediction = 0.12
        elseif ping < 50 then
            getgenv().Prediction = 0.13
        elseif ping < 60 then
            getgenv().Prediction = 0.14
        elseif ping < 70 then
            getgenv().Prediction = 0.15
        elseif ping < 80 then
            getgenv().Prediction = 0.16
        elseif ping < 90 then
            getgenv().Prediction = 0.17
        elseif ping < 100 then
            getgenv().Prediction = 0.18
        elseif ping < 150 then
            getgenv().Prediction = 0.19
        else
            getgenv().Prediction = 0.2
        end
    end
end
