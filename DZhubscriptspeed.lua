-- Chạy ở phía client trên Delta (Roblox Luau)
-- 1. Noclip + bay thẳng lên +100 studs tại chỗ
-- 2. Bay thẳng mặt tốc độ 500 cho tới khi thấy Button15 xuất hiện thì dừng bay
-- 3. Tắt Fly + Noclip cho rơi tự nhiên chạm nút -> vào vòng lặp 0.1s bắn StepTaken + kéo collider
-- Kèm UI Hướng Dẫn khởi động đúng cách

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer

local CONFIG = {
	Interval = 0.1,
	ForwardOffset = 3.0,
	DownOffset = -1.5,
	ClimbHeight = 100,    -- Bay lên cao +100 studs tại chỗ trước
	FlySpeed = 500,       -- Tốc độ bay thẳng mặt cho đến khi thấy Button15
	MaxFlyTimeout = 25.0, -- Giới hạn an toàn để không bay vô tận nếu map lỗi
	StepValue = 900000000000000000000000000000000000000000000000000009000000000000000000000000000000000000000000000000000090000000000000000000000000000000000000000000000000000900000000000000000000000000000000000000000000000000009000000000000000000000000000000000000000000000000000090000000000000000000000000000000000000000000000000000900000000000000000000000000000000000000000000000000009000000000000000000000000000000000000000000000000000090000000000000000000000000000000000000000000000000000900000000000000000000000000000000000000000000000000009000000000000000000000000000000000000000000000000000090000000000000000000000000000000000000000000000000000,
}

local GUIDE_TEXT = "Vì nút kiếm tiền ở quá xa bạn cho nên để khởi động script đúng, bạn hãy hướng mặt về phía chính dữa cổng chơi để script fly đi tìm. Nếu bỏ qua bước này, script có thể bị lỗi!"

local isRunning = false
local isDestroyed = false
local loopThread = nil
local tickCount = 0
local originalCFrames = {}

local noclipConn = nil
local savedCanCollide = {}
local activeBodyVel = nil

local function getUiParent()
	local ok, gui = pcall(function()
		return CoreGui
	end)
	if ok and gui then
		return gui
	end
	return localPlayer:WaitForChild("PlayerGui")
end

local function getCharParts()
	local char = localPlayer.Character
	if not char or not char.Parent then
		return nil, nil, nil
	end
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	return char, root, hum
end

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
			local anyPart = btn15:FindFirstChildWhichIsA("BasePart", true)
			if anyPart then
				return anyPart
			end
		end
	end

	for _, desc in ipairs(Workspace:GetDescendants()) do
		local lowerName = string.lower(desc.Name)
		if desc:IsA("BasePart") and lowerName == "collider" then
			local p = desc.Parent
			if p and string.find(string.lower(p.Name), "button15", 1, true) then
				return desc
			end
		elseif desc:IsA("Model") and string.find(lowerName, "button15", 1, true) then
			local col = desc:FindFirstChild("collider", true) or desc:FindFirstChild("Collider", true)
			if col and col:IsA("BasePart") then
				return col
			end
			local anyPart = desc:FindFirstChildWhichIsA("BasePart", true)
			if anyPart then
				return anyPart
			end
		end
	end

	return nil
end

local function clearFlyMover()
	if activeBodyVel then
		pcall(function()
			activeBodyVel:Destroy()
		end)
		activeBodyVel = nil
	end
end

local function setNoclip(enable)
	if enable then
		if noclipConn then
			return
		end
		noclipConn = RunService.Stepped:Connect(function()
			local char = localPlayer.Character
			if not char then
				return
			end
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					if savedCanCollide[part] == nil then
						savedCanCollide[part] = part.CanCollide
					end
					part.CanCollide = false
				end
			end
		end)
	else
		if noclipConn then
			noclipConn:Disconnect()
			noclipConn = nil
		end
		for part, prev in pairs(savedCanCollide) do
			if part and part.Parent then
				pcall(function()
					part.CanCollide = prev
				end)
			end
		end
		savedCanCollide = {}
	end
end

local function stopIntroFlightAndNoclip()
	clearFlyMover()
	setNoclip(false)
end

local function runIntroClimbAndFlyUntilButton15(updateStatus)
	local char, root, hum = getCharParts()
	if not char or not root then
		return false
	end

	setNoclip(true)

	pcall(function()
		if hum then
			hum.Sit = false
			hum.PlatformStand = true
		end
	end)

	clearFlyMover()
	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1e8, 1e8, 1e8)
	bv.Velocity = Vector3.zero
	bv.Parent = root
	activeBodyVel = bv

	-- Bước 1: Bay lên +100 studs tại chỗ
	local startPos = root.Position
	local targetAltitudeY = startPos.Y + CONFIG.ClimbHeight

	while isRunning and not isDestroyed do
		char, root, hum = getCharParts()
		if not char or not root or not bv.Parent then
			break
		end

		local remainY = targetAltitudeY - root.Position.Y
		if remainY <= 1.5 then
			pcall(function()
				bv.Velocity = Vector3.zero
				root.AssemblyLinearVelocity = Vector3.zero
				root.CFrame = CFrame.new(startPos.X, targetAltitudeY, startPos.Z) * root.CFrame.Rotation
			end)
			break
		end

		if updateStatus then
			local climbed = math.clamp(root.Position.Y - startPos.Y, 0, CONFIG.ClimbHeight)
			pcall(updateStatus, string.format("Bước 1: Fly lên %.0f/%d studs...", climbed, CONFIG.ClimbHeight))
		end

		local dt = RunService.Heartbeat:Wait()
		local stepY = math.min(remainY, CONFIG.FlySpeed * dt)
		pcall(function()
			bv.Velocity = Vector3.new(0, CONFIG.FlySpeed, 0)
			root.AssemblyLinearVelocity = Vector3.new(0, CONFIG.FlySpeed, 0)
			root.CFrame = CFrame.new(root.Position.X, root.Position.Y + stepY, root.Position.Z) * root.CFrame.Rotation
		end)
	end

	if not isRunning or isDestroyed then
		stopIntroFlightAndNoclip()
		return false
	end

	-- Bước 2: Bay thẳng mặt tốc độ 500 cho đến khi thấy Button15 load ra thì dừng bay
	local lookVec = root.CFrame.LookVector
	local straightDir = Vector3.new(lookVec.X, 0, lookVec.Z)
	if straightDir.Magnitude < 1e-4 then
		straightDir = Vector3.new(0, 0, -1)
	else
		straightDir = straightDir.Unit
	end

	local flyStart = os.clock()
	while isRunning and not isDestroyed and (os.clock() - flyStart) < CONFIG.MaxFlyTimeout do
		local found = findTargetCollider()
		if found then
			if updateStatus then
				pcall(updateStatus, "Đã thấy Button15 -> Dừng bay & rơi xuống...")
			end
			break
		end

		char, root, hum = getCharParts()
		if not char or not root or not bv.Parent then
			break
		end

		if updateStatus then
			pcall(updateStatus, string.format("Bước 2: Bay thẳng 500 tìm Button15 (%.1fs)...", os.clock() - flyStart))
		end

		local dt = RunService.Heartbeat:Wait()
		local moveVec = straightDir * CONFIG.FlySpeed * dt
		pcall(function()
			bv.Velocity = straightDir * CONFIG.FlySpeed
			root.AssemblyLinearVelocity = straightDir * CONFIG.FlySpeed
			root.CFrame = CFrame.new(root.Position + moveVec) * root.CFrame.Rotation
		end)
	end

	-- Bước 3: Tắt Fly + tắt Noclip để rơi tự nhiên xuống chạm Button15
	stopIntroFlightAndNoclip()
	pcall(function()
		if hum then
			hum.PlatformStand = false
			hum:ChangeState(Enum.HumanoidStateType.Freefall)
		end
	end)

	local fallStart = os.clock()
	while isRunning and not isDestroyed and (os.clock() - fallStart) < 2.0 do
		local collider = findTargetCollider()
		_, root = getCharParts()
		if collider and root and (root.Position - collider.Position).Magnitude <= 8.0 then
			break
		end
		task.wait(0.05)
	end

	return true
end

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

	return pcall(function()
		stepTaken:FireServer(unpack(args))
	end)
end

local function pullColliderToPlayer(part)
	if not part or not part:IsA("BasePart") or not part.Parent then
		return false
	end

	local _, root = getCharParts()
	if not root or not root:IsA("BasePart") then
		return false
	end

	if originalCFrames[part] == nil then
		originalCFrames[part] = part.CFrame
	end

	local targetCF = root.CFrame * CFrame.new(0, CONFIG.DownOffset, -CONFIG.ForwardOffset)

	local ok = pcall(function()
		part.Anchored = false
		part.CanCollide = false
		part.CanTouch = true
		part.AssemblyLinearVelocity = Vector3.zero
		part.AssemblyAngularVelocity = Vector3.zero
		part.CFrame = targetCF
	end)

	if typeof(firetouchinterest) == "function" then
		pcall(function()
			firetouchinterest(root, part, 0)
			task.wait(0.01)
			firetouchinterest(root, part, 1)
		end)
	end

	return ok
end

local function restoreColliders()
	for part, cf in pairs(originalCFrames) do
		if part and part.Parent then
			pcall(function()
				part.CFrame = cf
			end)
		end
	end
end

local mainGui, updateUi, stopLoop, startLoop, cleanupScript

stopLoop = function()
	isRunning = false
	if loopThread and coroutine.status(loopThread) == "suspended" then
		pcall(task.cancel, loopThread)
	end
	loopThread = nil
	stopIntroFlightAndNoclip()
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
		updateUi("Đang bắt đầu...")
	end

	loopThread = task.spawn(function()
		runIntroClimbAndFlyUntilButton15(updateUi)

		while isRunning and not isDestroyed do
			tickCount += 1
			local remoteOk = fireStepRemote()
			local collider = findTargetCollider()
			local pullOk = pullColliderToPlayer(collider)

			if updateUi then
				local rText = remoteOk and "Remote: OK" or "Remote: Lỗi"
				local pText = collider and (pullOk and "Kéo collider: OK" or "Kéo: Lỗi") or "Chưa có collider"
				pcall(updateUi, string.format("#%d | %s | %s", tickCount, rText, pText))
			end

			task.wait(CONFIG.Interval)
		end

		stopIntroFlightAndNoclip()
		isRunning = false
		loopThread = nil
	end)
end

local function createUi()
	local parentGui = getUiParent()
	local old = parentGui:FindFirstChild("StepFlyPullGui")
	if old then
		old:Destroy()
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "StepFlyPullGui"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = parentGui

	-- Panel chính điều khiển
	local panel = Instance.new("Frame")
	panel.Size = UDim2.new(0, 276, 0, 110)
	panel.Position = UDim2.new(0.5, -138, 0.14, 0)
	panel.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
	panel.BorderSizePixel = 0
	panel.Active = true
	panel.Draggable = true
	panel.Parent = gui
	Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(70, 125, 235)
	stroke.Thickness = 1.2
	stroke.Transparency = 0.35
	stroke.Parent = panel

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -66, 0, 24)
	title.Position = UDim2.new(0, 12, 0, 4)
	title.BackgroundTransparency = 1
	title.Text = "Fly +100 -> Thấy Button15 -> Loop"
	title.TextColor3 = Color3.fromRGB(240, 244, 255)
	title.TextSize = 11
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextTruncate = Enum.TextTruncate.AtEnd
	title.Parent = panel

	local guideBtn = Instance.new("TextButton")
	guideBtn.Size = UDim2.new(0, 24, 0, 24)
	guideBtn.Position = UDim2.new(1, -58, 0, 5)
	guideBtn.BackgroundColor3 = Color3.fromRGB(55, 110, 205)
	guideBtn.Text = "?"
	guideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	guideBtn.TextSize = 12
	guideBtn.Font = Enum.Font.GothamBold
	guideBtn.BorderSizePixel = 0
	guideBtn.Parent = panel
	Instance.new("UICorner", guideBtn).CornerRadius = UDim.new(0, 6)

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 24, 0, 24)
	closeBtn.Position = UDim2.new(1, -30, 0, 5)
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
	statusLabel.Position = UDim2.new(0, 12, 0, 76)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = "Sẵn sàng"
	statusLabel.TextColor3 = Color3.fromRGB(170, 185, 215)
	statusLabel.TextSize = 10
	statusLabel.Font = Enum.Font.Gotham
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.TextTruncate = Enum.TextTruncate.AtEnd
	statusLabel.Parent = panel

	-- Panel UI Hướng Dẫn
	local guidePanel = Instance.new("Frame")
	guidePanel.Size = UDim2.new(0, 290, 0, 118)
	guidePanel.Position = UDim2.new(0.5, -145, 0.34, 0)
	guidePanel.BackgroundColor3 = Color3.fromRGB(22, 25, 36)
	guidePanel.BorderSizePixel = 0
	guidePanel.Active = true
	guidePanel.Draggable = true
	guidePanel.Parent = gui
	Instance.new("UICorner", guidePanel).CornerRadius = UDim.new(0, 10)

	local guideStroke = Instance.new("UIStroke")
	guideStroke.Color = Color3.fromRGB(245, 175, 55)
	guideStroke.Thickness = 1.2
	guideStroke.Transparency = 0.25
	guideStroke.Parent = guidePanel

	local guideTopBar = Instance.new("Frame")
	guideTopBar.Size = UDim2.new(1, 0, 0, 3)
	guideTopBar.Position = UDim2.new(0, 0, 0, 0)
	guideTopBar.BackgroundColor3 = Color3.fromRGB(245, 175, 55)
	guideTopBar.BorderSizePixel = 0
	guideTopBar.Parent = guidePanel

	local guideTitle = Instance.new("TextLabel")
	guideTitle.Size = UDim2.new(1, -60, 0, 24)
	guideTitle.Position = UDim2.new(0, 12, 0, 4)
	guideTitle.BackgroundTransparency = 1
	guideTitle.Text = "HƯỚNG DẪN KHỞI ĐỘNG"
	guideTitle.TextColor3 = Color3.fromRGB(255, 205, 95)
	guideTitle.TextSize = 11
	guideTitle.Font = Enum.Font.GothamBold
	guideTitle.TextXAlignment = Enum.TextXAlignment.Left
	guideTitle.Parent = guidePanel

	local hideGuideBtn = Instance.new("TextButton")
	hideGuideBtn.Size = UDim2.new(0, 42, 0, 20)
	hideGuideBtn.Position = UDim2.new(1, -50, 0, 6)
	hideGuideBtn.BackgroundColor3 = Color3.fromRGB(52, 58, 74)
	hideGuideBtn.Text = "Ẩn"
	hideGuideBtn.TextColor3 = Color3.fromRGB(235, 240, 252)
	hideGuideBtn.TextSize = 10
	hideGuideBtn.Font = Enum.Font.GothamBold
	hideGuideBtn.BorderSizePixel = 0
	hideGuideBtn.Parent = guidePanel
	Instance.new("UICorner", hideGuideBtn).CornerRadius = UDim.new(0, 6)

	local guideBody = Instance.new("TextLabel")
	guideBody.Size = UDim2.new(1, -24, 1, -34)
	guideBody.Position = UDim2.new(0, 12, 0, 28)
	guideBody.BackgroundTransparency = 1
	guideBody.Text = GUIDE_TEXT
	guideBody.TextColor3 = Color3.fromRGB(232, 236, 248)
	guideBody.TextSize = 11
	guideBody.Font = Enum.Font.Gotham
	guideBody.TextWrapped = true
	guideBody.TextXAlignment = Enum.TextXAlignment.Left
	guideBody.TextYAlignment = Enum.TextYAlignment.Top
	guideBody.Parent = guidePanel

	updateUi = function(msg)
		if isDestroyed then
			return
		end
		if isRunning then
			toggleBtn.Text = "ĐANG BẬT (Bấm để Tắt)"
			toggleBtn.BackgroundColor3 = Color3.fromRGB(210, 115, 32)
		else
			toggleBtn.Text = "BẬT VÒNG LẶP"
			toggleBtn.BackgroundColor3 = Color3.fromRGB(36, 148, 92)
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

	guideBtn.MouseButton1Click:Connect(function()
		if not isDestroyed and guidePanel then
			guidePanel.Visible = not guidePanel.Visible
		end
	end)

	hideGuideBtn.MouseButton1Click:Connect(function()
		if not isDestroyed and guidePanel then
			guidePanel.Visible = false
		end
	end)

	closeBtn.MouseButton1Click:Connect(function()
		cleanupScript()
	end)

	updateUi("Sẵn sàng")
	return gui
end

cleanupScript = function()
	if isDestroyed then
		return
	end
	isDestroyed = true
	stopLoop()
	restoreColliders()

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
