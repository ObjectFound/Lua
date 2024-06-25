-- Services
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

local function createNotification(titleText, descriptionText, profileImage)
    local NotificationUI = Instance.new("ScreenGui", Players.LocalPlayer:WaitForChild("PlayerGui"))
    NotificationUI.Name = "NotificationUI"

    local Background = Instance.new("Frame", NotificationUI)
    Background.BorderSizePixel = 0
    Background.BackgroundColor3 = Color3.fromRGB(21, 21, 21) -- Updated background color
    Background.Size = UDim2.new(0, 276, 0, 88)
    Background.Position = UDim2.new(0.81395, 0, 0.8263, 0)
    Background.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Background.Name = "Background"
    Background.BackgroundTransparency = 1

    local UICorner = Instance.new("UICorner", Background)
    UICorner.CornerRadius = UDim.new(0, 5)

    local DropShadow = Instance.new("Frame", Background)
    DropShadow.Name = "DropShadow"
    DropShadow.BackgroundTransparency = 1.000
    DropShadow.Position = UDim2.new(-0.00999999978, 0, -0.0890000015, 0)
    DropShadow.Size = UDim2.new(1.02173913, 0, 1.06818187, 0)
    DropShadow.ZIndex = 0

    local umbraShadow = Instance.new("ImageLabel", DropShadow)
    umbraShadow.Name = "umbraShadow"
    umbraShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    umbraShadow.BackgroundTransparency = 1.000
    umbraShadow.Position = UDim2.new(0.5, 0, 0.5, 6)
    umbraShadow.Size = UDim2.new(1, 10, 1, 10)
    umbraShadow.ZIndex = 0
    umbraShadow.Image = "rbxassetid://1316045217"
    umbraShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    umbraShadow.ImageTransparency = 0.860
    umbraShadow.ScaleType = Enum.ScaleType.Slice
    umbraShadow.SliceCenter = Rect.new(10, 10, 118, 118)

    local penumbraShadow = Instance.new("ImageLabel", DropShadow)
    penumbraShadow.Name = "penumbraShadow"
    penumbraShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    penumbraShadow.BackgroundTransparency = 1.000
    penumbraShadow.Position = UDim2.new(0.5, 0, 0.5, 6)
    penumbraShadow.Size = UDim2.new(1, 10, 1, 10)
    penumbraShadow.ZIndex = 0
    penumbraShadow.Image = "rbxassetid://1316045217"
    penumbraShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    penumbraShadow.ImageTransparency = 0.880
    penumbraShadow.ScaleType = Enum.ScaleType.Slice
    penumbraShadow.SliceCenter = Rect.new(10, 10, 118, 118)

    local ambientShadow = Instance.new("ImageLabel", DropShadow)
    ambientShadow.Name = "ambientShadow"
    ambientShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    ambientShadow.BackgroundTransparency = 1.000
    ambientShadow.Position = UDim2.new(0.5, 0, 0.5, 6)
    ambientShadow.Size = UDim2.new(1, 10, 1, 10)
    ambientShadow.ZIndex = 0
    ambientShadow.Image = "rbxassetid://1316045217"
    ambientShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    ambientShadow.ImageTransparency = 0.880
    ambientShadow.ScaleType = Enum.ScaleType.Slice
    ambientShadow.SliceCenter = Rect.new(10, 10, 118, 118)

    local Title = Instance.new("TextLabel", Background)
    Title.TextWrapped = true
    Title.BorderSizePixel = 0
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextScaled = true
    Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14
    Title.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(0, 178, 0, 17)
    Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Title.Text = titleText
    Title.Name = "Title"
    Title.Position = UDim2.new(0.04301, 0, 0.09758, 0)
    Title.TextTransparency = 1

    local Description = Instance.new("TextLabel", Background)
    Description.TextWrapped = true
    Description.BorderSizePixel = 0
    Description.TextXAlignment = Enum.TextXAlignment.Left
    Description.TextYAlignment = Enum.TextYAlignment.Top
    Description.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Description.TextSize = 14
    Description.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    Description.TextColor3 = Color3.fromRGB(255, 255, 255)
    Description.BackgroundTransparency = 1
    Description.RichText = true
    Description.Size = UDim2.new(0, 184, 0, 52)
    Description.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Description.Text = descriptionText
    Description.Name = "Description"
    Description.Position = UDim2.new(0.04301, 0, 0.32835, 0)
    Description.TextTransparency = 1

    local Profile
    if profileImage then
        Profile = Instance.new("ImageLabel", Background)
        Profile.BorderSizePixel = 0
        Profile.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Profile.Image = profileImage
        Profile.Size = UDim2.new(0, 60, 0, 58)
        Profile.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Profile.Name = "Profile"
        Profile.Position = UDim2.new(0.74555, 0, 0.17421, 0)
        Profile.ImageTransparency = 1

        local ProfileUICorner = Instance.new("UICorner", Profile)
    end

    local function fadeIn()
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(Background, tweenInfo, {BackgroundTransparency = 0}):Play()
        task.wait(0.1)
        TweenService:Create(Title, tweenInfo, {TextTransparency = 0}):Play()
        task.wait(0.1)
        TweenService:Create(Description, tweenInfo, {TextTransparency = 0}):Play()
        if Profile then
            task.wait(0.1)
            TweenService:Create(Profile, tweenInfo, {ImageTransparency = 0}):Play()
        end
    end

    local function fadeOut()
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        if Profile then
            TweenService:Create(Profile, tweenInfo, {ImageTransparency = 1}):Play()
            task.wait(0.1)
        end
        TweenService:Create(Description, tweenInfo, {TextTransparency = 1}):Play()
        task.wait(0.1)
        TweenService:Create(Title, tweenInfo, {TextTransparency = 1}):Play()
        task.wait(0.1)
        TweenService:Create(Background, tweenInfo, {BackgroundTransparency = 1}):Play()
    end

    fadeIn()
    task.wait(3) -- Display the notification for 3 seconds
    fadeOut()
    task.wait(0.5)
    NotificationUI:Destroy()
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
                    createNotification("Aimlock Activated", "Target: " .. Victim.Name, victimProfileImage)
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
