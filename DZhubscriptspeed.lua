-- Chạy ở phía client trên Delta (Roblox Luau)
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer

local CONFIG = {
	Interval = 0.1, -- Chu kỳ lặp mỗi 0.1s
	AboveOffset = 2.0, -- Độ cao đặt nhân vật thật trên collider
	StepValue = 900000000000000000000000000000000000000000000000000009000000000000000000000000000000000000000000000000000090000000000000000000000000000000000000000000000000000900000000000000000000000000000000000000000000000000009000000000000000000000000000000000000000000000000000090000000000000000000000000000000000000000000000000000900000000000000000000000000000000000000000000000000009000000000000000000000000000000000000000000000000000090000000000000000000000000000000000000000000000000000900000000000000000000000000000000000000000000000000009000000000000000000000000000000000000000000000000000090000000000000000000000000000000000000000000000000000,
}

local isRunning = false
local isDestroyed = false
local loopThread = nil
local tickCount = 0

local function getUiParent()
	local ok, gui = pcall(function()
		return CoreGui
	end)
	if ok and gui then
		return gui
	end
	return localPlayer:WaitForChild("PlayerGui")
end

-- Tìm chính xác Worldspace -> ReturnButtons -> Button15 -> collider
local function findTargetCollider()
	local returnButtons = Workspace:FindFirstChild("ReturnButtons")
	if returnButtons then
		local btn15 = returnButtons:FindFirstChild("Button15")
		if btn15 then
			local collider = btn15:FindFirstChild("collider") or btn15:FindFirstChild("Collider")
			if collider and collider:IsA("BasePart") then
				return collider
			end
			if btn15:IsA("BasePart") then
				return btn15
			end
		end
	end

	for _, desc in ipairs(Workspace:GetDescendants()) do
		if desc:IsA("BasePart") and string.lower(desc.Name) == "collider" then
			local p = desc.Parent
			if p and string.lower(p.Name) == "button15" then
				return desc
			end
		end
	end

	return nil
end

-- Bắn remote StepTaken
local function fireStepRemote()
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	local stepTaken = remotes and remotes:FindFirstChild("StepTaken")
	if not stepTaken or not stepTaken:IsA("RemoteEvent") then
		return false
	end

	local args = {
		CONFIG.StepValue,
		false,
	}

	local ok = pcall(function()
		stepTaken:FireServer(unpack(args))
	end)
	return ok
end

-- TP nhân vật thật tới collider và kích hoạt chạm
local function tpRealPlayerToCollider(targetPart)
	if not targetPart or not targetPart.Parent then
		return false
	end

	local char = localPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not root or not root:IsA("BasePart") then
		return false
	end

	local yOffset = (targetPart.Size.Y * 0.5) + CONFIG.AboveOffset
	local dest = CFrame.new(targetPart.Position + Vector3.new(0, yOffset, 0))

	local ok = pcall(function()
		if hum then
			hum.Sit = false
		end
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		root.CFrame = dest
	end)

	if typeof(firetouchinterest) == "function" then
		pcall(function()
			firetouchinterest(root, targetPart, 0)
			task.wait(0.01)
			firetouchinterest(root, targetPart, 1)
		end)
	end

	return ok
end

local stopLoop, startLoop, cleanupScript, updateUi

stopLoop = function()
	isRunning = false
	if loopThread and coroutine.status(loopThread) == "suspended" then
		pcall(task.cancel, loopThread)
	end
	loopThread = nil
	if updateUi then
		pcall(updateUi, "Đã dừng")
	end
end

startLoop = function()
	if isDestroyed or isRunning then
		return
	end
	isRunning = true
	if updateUi then
		updateUi("Đang chạy vòng lặp 0.1s...")
	end

	loopThread = task.spawn(function()
		while isRunning and not isDestroyed do
			tickCount += 1
			local remoteOk = fireStepRemote()
			local collider = findTargetCollider()
			local tpOk = tpRealPlayerToCollider(collider)

			if updateUi then
				local rText = remoteOk and "Remote: OK" or "Remote: Lỗi"
				local tText = collider and (tpOk and "TP -> Button15: OK" or "TP: Lỗi") or "Thiếu Button15/collider"
				pcall(updateUi, string.format("#%d | %s | %s", tickCount, rText, tText))
			end

			task.wait(CONFIG.Interval)
		end
		isRunning = false
		loopThread = nil
	end)
end

local mainGui

local function createUi()
	local parentGui = getUiParent()
	local old = parentGui:FindFirstChild("StepRealTpGui")
	if old then
		old:Destroy()
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "StepRealTpGui"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = parentGui

	local panel = Instance.new("Frame")
	panel.Size = UDim2.new(0, 268, 0, 108)
	panel.Position = UDim2.new(0.5, -134, 0.15, 0)
	panel.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
	panel.BorderSizePixel = 0
	panel.Active = true
	panel.Draggable = true
	panel.Parent = gui

	local panelCorner = Instance.new("UICorner")
	panelCorner.CornerRadius = UDim.new(0, 10)
	panelCorner.Parent = panel

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(70, 125, 235)
	stroke.Thickness = 1.2
	stroke.Transparency = 0.35
	stroke.Parent = panel

	local accentBar = Instance.new("Frame")
	accentBar.Size = UDim2.new(1, 0, 0, 3)
	accentBar.Position = UDim2.new(0, 0, 0, 0)
	accentBar.BackgroundColor3 = Color3.fromRGB(75, 145, 255)
	accentBar.BorderSizePixel = 0
	accentBar.Parent = panel

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -40, 0, 24)
	title.Position = UDim2.new(0, 12, 0, 5)
	title.BackgroundTransparency = 1
	title.Text = "StepTaken + Player TP (0.1s)"
	title.TextColor3 = Color3.fromRGB(240, 244, 255)
	title.TextSize = 12
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextTruncate = Enum.TextTruncate.AtEnd
	title.Parent = panel

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 24, 0, 24)
	closeBtn.Position = UDim2.new(1, -30, 0, 6)
	closeBtn.BackgroundColor3 = Color3.fromRGB(190, 45, 60)
	closeBtn.Text = "X"
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.TextSize = 12
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.BorderSizePixel = 0
	closeBtn.Parent = panel
	Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Size = UDim2.new(1, -24, 0, 34)
	toggleBtn.Position = UDim2.new(0, 12, 0, 35)
	toggleBtn.BackgroundColor3 = Color3.fromRGB(36, 148, 92)
	toggleBtn.Text = "BẬT VÒNG LẶP"
	toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggleBtn.TextSize = 12
	toggleBtn.Font = Enum.Font.GothamBold
	toggleBtn.BorderSizePixel = 0
	toggleBtn.Parent = panel
	Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 7)

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Size = UDim2.new(1, -24, 0, 24)
	statusLabel.Position = UDim2.new(0, 12, 0, 75)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = "Sẵn sàng | Chu kỳ: 0.1s"
	statusLabel.TextColor3 = Color3.fromRGB(170, 185, 215)
	statusLabel.TextSize = 10
	statusLabel.Font = Enum.Font.Gotham
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.TextTruncate = Enum.TextTruncate.AtEnd
	statusLabel.Parent = panel

	updateUi = function(msg)
		if isDestroyed then
			return
		end
		if isRunning then
			toggleBtn.Text = "ĐANG BẬT (Bấm để Tắt)"
			toggleBtn.BackgroundColor3 = Color3.fromRGB(210, 115, 32)
			accentBar.BackgroundColor3 = Color3.fromRGB(255, 155, 45)
		else
			toggleBtn.Text = "BẬT VÒNG LẶP"
			toggleBtn.BackgroundColor3 = Color3.fromRGB(36, 148, 92)
			accentBar.BackgroundColor3 = Color3.fromRGB(75, 145, 255)
		end
		if msg then
			statusLabel.Text = tostring(msg)
		end
	end

	toggleBtn.MouseButton1Click:Connect(function()
		if isDestroyed then
			return
		end
		if isRunning then
			stopLoop()
		else
			startLoop()
		end
	end)

	closeBtn.MouseButton1Click:Connect(function()
		cleanupScript()
	end)

	updateUi("Sẵn sàng | Chu kỳ: 0.1s")
	return gui
end

cleanupScript = function()
	if isDestroyed then
		return
	end
	isDestroyed = true
	stopLoop()

	if mainGui and mainGui.Parent then
		mainGui:Destroy()
	end

	pcall(function()
		if script and script.Parent then
			script:Destroy()
		end
	end)
end

mainGui = createUi()
