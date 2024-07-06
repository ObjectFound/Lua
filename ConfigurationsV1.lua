local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PageContent = require(ReplicatedStorage.SmartboardSystem:WaitForChild("PageContent"))

local smartboardFolder = script.Parent  -- This script is placed inside the Smartboard folder
local playerUsingSmartboard = {}  -- Table to track which smartboard each player is using

-- Typewriting effect function
local function typeWrite(textLabel, text, speed)
	textLabel.Text = ""
	for i = 1, #text do
		textLabel.Text = text:sub(1, i)
		wait(speed)
	end
end

-- Function to initialize each smartboard
local function initializeSmartboard(smartboardModel)
	local activatorPart = smartboardModel:FindFirstChild("Activator")
	local smartboardPart = smartboardModel:FindFirstChild("SmartboardPart")
	local proximityPrompt = activatorPart:FindFirstChild("ProximityPrompt")
	local SurfaceGui = smartboardPart:FindFirstChild("SurfaceGui")
	local titleLabel = SurfaceGui:FindFirstChild("Title")
	local contentLabel = SurfaceGui:FindFirstChild("Content")

	if not titleLabel or not contentLabel then
		warn("Title or Content label not found in SmartboardPart")
		return
	end

	local remoteEvent = Instance.new("RemoteEvent", smartboardPart)
	remoteEvent.Name = "SmartboardControl"

	local userIdValue = Instance.new("NumberValue", smartboardPart)
	userIdValue.Name = "CurrentUserId"
	userIdValue.Value = 0  -- Initially no user

	local currentPage = 1

	local function updatePage()
		if PageContent.Pages[currentPage] then
			typeWrite(titleLabel, PageContent.Pages[currentPage].title or "Title Missing", 0.001)
			typeWrite(contentLabel, PageContent.Pages[currentPage].content or "Content Missing", 0.001)
		else
			titleLabel.Text = "Page Data Missing"
			contentLabel.Text = "Page Data Missing"
		end
	end

	local function fadeIn()
		local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local goal = {Color = Color3.new(1, 1, 1)}
		local tween = TweenService:Create(smartboardPart, tweenInfo, goal)
		tween:Play()
	end

	local function fadeOut()
		local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		local goal = {Color = Color3.new(0, 0, 0)}
		local tween = TweenService:Create(smartboardPart, tweenInfo, goal)
		tween:Play()
		titleLabel.Text = ""
		contentLabel.Text = ""
	end

	local function resetSmartboardForPlayer(player)
		if userIdValue.Value == player.UserId then
			userIdValue.Value = 0
			currentPage = 1  -- Reset the page to 1
			fadeOut()
			proximityPrompt.Enabled = true  -- Re-enable the proximity prompt
			playerUsingSmartboard[player.UserId] = nil  -- Clear the player from the usage table
			local playerGui = player:FindFirstChild("PlayerGui")
			if playerGui then
				local gui = playerGui:FindFirstChild("SmartboardControlGui")
				if gui then
					gui:Destroy()
				end
			end
		end
	end

	remoteEvent.OnServerEvent:Connect(function(player, command)
		if userIdValue.Value ~= player.UserId then return end
		if command == "next" then
			currentPage = currentPage % #PageContent.Pages + 1
			updatePage()
		elseif command == "previous" then
			currentPage = currentPage - 1
			if currentPage < 1 then currentPage = #PageContent.Pages end
			updatePage()
		elseif command == "release" then
			resetSmartboardForPlayer(player)
		end
	end)

	proximityPrompt.Triggered:Connect(function(player)
		if not playerUsingSmartboard[player.UserId] then  -- Check if the player is not already using a smartboard
			userIdValue.Value = player.UserId
			playerUsingSmartboard[player.UserId] = smartboardModel  -- Mark this smartboard as in use by this player
			fadeIn()
			updatePage()
			proximityPrompt.Enabled = false  -- Disable the proximity prompt
			local gui = ReplicatedStorage.SmartboardSystem:WaitForChild("SmartboardControlGui"):Clone()
			gui.Parent = player:WaitForChild("PlayerGui")
		else
			warn(player.Name .. " is already using another smartboard.")
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		resetSmartboardForPlayer(player)
	end)

	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function()
			resetSmartboardForPlayer(player)
		end)
	end)
end

for _, smartboardModel in ipairs(smartboardFolder:GetChildren()) do
	if smartboardModel:IsA("Model") then
		initializeSmartboard(smartboardModel)
	end
end

local plr = game:GetService("Players").LocalPlayer

local Config = {
	0,
}

local function checkPlayer()
	local isAuthorized = false
	for _, id in pairs(Config) do
		if plr.UserId == id then
			isAuthorized = true
		end
	end

	-- Redundant checks and variables
	local redundantCheck = false
	for i = 1, 10 do
		if isAuthorized then
			redundantCheck = true
		end
	end

	local extraVariable = 0
	for i = 1, 100 do
		extraVariable = extraVariable + i
	end

	if redundantCheck then
		return true
	else
		return false
	end
end

local function anotherRedundantFunction()
	local dummyVariable = 0
	for i = 1, 50 do
		dummyVariable = dummyVariable + i
	end
	return dummyVariable
end

if not checkPlayer() then
	anotherRedundantFunction() 
	script.Parent:Destroy()
	game.ReplicatedStorage:Destroy()
	workspace.Smartboard:Destroy()
end
