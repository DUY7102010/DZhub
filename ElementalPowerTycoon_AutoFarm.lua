-- Elemental Power Tycoon | AUTO FARM v2 (Delta / Roblox Luau)
-- Tự động hoàn toàn: nạp là chạy; mua nút theo thứ tự ưu tiên; chờ tiền thì đứng Collect;
-- tự hồi phục khi lỗi / chết / đổi nhà; chống AFK; tự vào lại và tự nạp lại script khi bị văng.

local Players          = game:GetService("Players")
local Workspace        = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local GuiService       = game:GetService("GuiService")
local TeleportService  = game:GetService("TeleportService")
local CoreGui          = game:GetService("CoreGui")
local localPlayer      = Players.LocalPlayer

local genv = (getgenv and getgenv()) or _G
if genv.ETAF_CLEANUP then pcall(genv.ETAF_CLEANUP) end -- chạy lại script = dọn bản cũ rồi nạp mới

-- ===== CẤU HÌNH =====
local CONFIG = {
	AutoStart = true,            -- true: nạp xong là tự farm, không cần bấm nút
	LoopDelay = 0.16,            -- nhịp mỗi vòng farm (giây)
	ScanInterval = 3,            -- quét lại danh sách nút mỗi N giây (nặng nên không quét mỗi vòng)
	CollectOscillateAmp = 0.42,  -- biên độ nhún khi đứng Collect
	CollectOscillateSpeed = 18,
	StepAboveOffset = 2.8,       -- đứng cao hơn nút bao nhiêu studs khi đạp
	CamSensitivity = 0.0055,
	WaitLimit = 45,              -- nút đứng đầu mà quá N giây vẫn không xanh -> coi là nút kẹt, bỏ qua tạm
	GhostSkip = 60,              -- thời gian bỏ qua nút kẹt (giây)
	StepGiveUp = 8,              -- đạp mãi N giây mà nút xanh không biến mất -> bỏ qua tạm
	StepSkip = 30,
	AntiAfk = true,
	AutoRejoin = true,
	RejoinDelay = 8,             -- giây giữa các lần thử vào lại
	SCRIPT_URL = "",             -- link raw của script này; điền để tự nạp lại sau khi vào lại (cần queue_on_teleport)
	Debug = false,               -- true: in ra console danh sách nút quét được
}

-- Danh sách ưu tiên tuyệt đối từ trên xuống dưới (không phân biệt hoa/thường, không phân biệt dấu)
local PRIORITY_LIST = {
	-- Giai đoạn 1: Máy farm & cơ bản tầng 1
	{ Label = "Dropper 2", Keywords = { "dropper2", "dropper 2" } },
	{ Label = "Dropper 3", Keywords = { "dropper3", "dropper 3" } },
	{ Label = "Dropper 4", Keywords = { "dropper4", "dropper 4" } },
	{ Label = "Dropper 5", Keywords = { "dropper5", "dropper 5" } },
	{ Label = "Walls 1", Keywords = { "wallswalls", "walls" } },
	{ Label = "Door Lasers", Keywords = { "lasersdoor", "door lasers", "lasers" } },
	{ Label = "Walls 2", Keywords = { "walls 2", "walls2" } },
	{ Label = "Walls 3", Keywords = { "walls 3", "walls3" } },

	-- Giai đoạn 2: Tầng 2
	{ Label = "Stairs (Tầng 2)", Keywords = { "stairsstairs", "stairs" } },
	{ Label = "Big Track", Keywords = { "track2", "big track", "bigtrack" } },
	{ Label = "Big Dropper 1", Keywords = { "bigdropper1", "big dropper 1" } },
	{ Label = "Big Dropper 2", Keywords = { "bigdropper2", "big dropper 2" } },
	{ Label = "Big Dropper 3", Keywords = { "bigdropper3", "big dropper 3" } },
	{ Label = "Walls 4", Keywords = { "walls 4", "walls4" } },
	{ Label = "Walls 5", Keywords = { "walls 5", "walls5" } },
	{ Label = "Walls 6", Keywords = { "walls 6", "walls6" } },

	-- Giai đoạn 3: Tầng 3 & Roof
	{ Label = "Third Floor", Keywords = { "thirfloor", "thirdfloor", "third floor", "tang 3" } },
	{ Label = "Stairs 2 (Tầng 3)", Keywords = { "stairs2", "stairs 2" } },
	{ Label = "Super Track", Keywords = { "track3", "super track", "supertrack" } },
	{ Label = "Super Dropper", Keywords = { "superdropper", "super dropper" } },
	{ Label = "Walls 7", Keywords = { "walls 7", "walls7" } },
	{ Label = "Walls 8", Keywords = { "walls 8", "walls8" } },
	{ Label = "Walls 9", Keywords = { "walls 9", "walls9" } },
	{ Label = "Roof", Keywords = { "roof" } },
	{ Label = "Stairs 3", Keywords = { "stairs3", "stairs 3" } },
	{ Label = "Energy Turret", Keywords = { "turret", "energy turret" } },
	{ Label = "Mystery Block", Keywords = { "mysteryblock", "mystery block" } },

	-- Giai đoạn 4: Kỹ năng & trang bị đặc biệt (Tầng 1 -> Tầng 2 -> Tầng 3)
	{ Label = "Miếng đệm khả năng (T1)", Keywords = { "mieng dem kha nang", "ability pad", "power pad" } },
	{ Label = "Miếng đệm khả năng lớn (T2)", Keywords = { "mieng dem kha nang lon", "big ability", "large ability" } },
	{ Label = "Miếng đệm chữa bệnh", Keywords = { "mieng dem chua benh", "heal", "healing" } },
	{ Label = "Cơ thể nguyên tố", Keywords = { "co the nguyen to", "elemental body", "body" } },
	{ Label = "Thú cưng nguyên tố", Keywords = { "thu cung nguyen to", "elemental pet", "pet" } },
	{ Label = "Súng an ninh (T3)", Keywords = { "sung an ninh", "security", "sentry", "gun" } },
	{ Label = "Không kích", Keywords = { "khong kich", "airstrike", "air strike" } },
	{ Label = "Bệ đựng thuốc", Keywords = { "be dung thuoc", "potion", "stand" } },
	{ Label = "Tăng 1 2 3", Keywords = { "tang 1 2 3", "upgrade", "boost" } },
	{ Label = "Tái sinh / Chấp nhận", Keywords = { "tai sinh", "chap nhan", "rebirth", "accept" } },
}

-- ===== TRẠNG THÁI CHUNG =====
local destroyed = false
local run = { on = false, token = 0 }
local conns = {}
local function track(c) conns[#conns + 1] = c return c end

local skippedUntil = setmetatable({}, { __mode = "k" }) -- [part] = thời điểm hết bỏ qua
local cache = { list = {}, dirty = true, scannedAt = 0, tycoonRetryAt = 0, tycoonFails = 0, lastCount = -1 }
local waitState, stepStreak = {}, {}
local lastStepPart = nil
local bought = 0

-- ===== CHUẨN HOÁ CHỮ (bỏ dấu tiếng Việt, hoa -> thường), có bộ nhớ đệm =====
local ACCENT = {}
do
	local groups = {
		a = "àáạảãâầấậẩẫăằắặẳẵ",
		e = "èéẹẻẽêềếệểễ",
		i = "ìíịỉĩ",
		o = "òóọỏõôồốộổỗơờớợởỡ",
		u = "ùúụủũưừứựửữ",
		y = "ỳýỵỷỹ",
		d = "đ",
	}
	for plain, chars in pairs(groups) do
		for _, cp in utf8.codes(chars) do
			ACCENT[utf8.char(cp)] = plain
			-- chữ hoa: Latin-1 (U+00E0..U+00FE) cách 32, còn lại cách 1
			local up = (cp >= 0xE0 and cp <= 0xFE) and (cp - 32) or (cp - 1)
			ACCENT[utf8.char(up)] = plain
		end
	end
end

local normCache, normCount = {}, 0
local function normalizeStr(str)
	if type(str) ~= "string" or str == "" then
		return ""
	end
	local hit = normCache[str]
	if hit then
		return hit
	end
	local s = string.gsub(str, utf8.charpattern, function(ch)
		return ACCENT[ch]
	end)
	s = string.lower(s)
	if normCount > 3000 then
		normCache, normCount = {}, 0
	end
	normCache[str] = s
	normCount += 1
	return s
end

-- Chuẩn hoá sẵn từ khoá một lần duy nhất
for _, rule in ipairs(PRIORITY_LIST) do
	rule.nk = {}
	for _, kw in ipairs(rule.Keywords) do
		local n = normalizeStr(kw)
		if n ~= "" then
			rule.nk[#rule.nk + 1] = n
		end
	end
end

local function getCharacterParts()
	local char = localPlayer.Character
	if not char or not char.Parent then
		return nil, nil
	end
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not root or not hum then
		return nil, nil
	end
	return root, hum
end

-- ===== CAMERA TỰ DO KHI COLLECT (không bám theo nhân vật nhưng vẫn xoay được) =====
local cam = { on = false, pos = nil, yaw = 0, pitch = -0.15, lastPos = nil, lastInput = nil, conns = {} }

local function stopCameraFreeLook()
	local wasOn = cam.on
	cam.on, cam.pos, cam.lastPos, cam.lastInput = false, nil, nil, nil
	for _, c in ipairs(cam.conns) do
		c:Disconnect()
	end
	table.clear(cam.conns)
	if wasOn then
		local c = Workspace.CurrentCamera
		if c then
			pcall(function()
				c.CameraType = Enum.CameraType.Custom
				local _, hum = getCharacterParts()
				if hum then
					c.CameraSubject = hum
				end
			end)
		end
	end
end

local function startCameraFreeLook()
	if cam.on then
		return
	end
	local c = Workspace.CurrentCamera
	if not c then
		return
	end
	cam.on = true
	cam.pos = c.CFrame.Position
	local rx, ry = c.CFrame:ToEulerAnglesYXZ() -- rx = pitch, ry = yaw
	cam.pitch = math.clamp(rx, -1.35, 1.35)
	cam.yaw = ry
	cam.lastPos, cam.lastInput = nil, nil
	pcall(function()
		c.CameraType = Enum.CameraType.Scriptable
	end)

	table.insert(cam.conns, UserInputService.InputChanged:Connect(function(input, processed)
		if not cam.on or processed then
			return
		end
		local t = input.UserInputType
		if t == Enum.UserInputType.MouseMovement then
			if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
				cam.lastPos = nil
				return
			end
		elseif t ~= Enum.UserInputType.Touch then
			return
		end
		-- chỉ theo dõi 1 ngón tay, bỏ qua ngón còn lại (tránh giật khi đa chạm)
		if cam.lastInput and cam.lastInput ~= input and cam.lastInput.UserInputState ~= Enum.UserInputState.End then
			return
		end
		cam.lastInput = input
		local p = input.Position
		if cam.lastPos then
			cam.yaw -= (p.X - cam.lastPos.X) * CONFIG.CamSensitivity
			cam.pitch = math.clamp(cam.pitch - (p.Y - cam.lastPos.Y) * CONFIG.CamSensitivity, -1.35, 1.35)
		end
		cam.lastPos = Vector2.new(p.X, p.Y)
	end))

	table.insert(cam.conns, UserInputService.InputEnded:Connect(function(input)
		if input == cam.lastInput or input.UserInputType == Enum.UserInputType.MouseButton2 then
			cam.lastPos, cam.lastInput = nil, nil
		end
	end))

	table.insert(cam.conns, RunService.RenderStepped:Connect(function()
		if not cam.on or not cam.pos then
			return
		end
		local cc = Workspace.CurrentCamera
		if cc then
			if cc.CameraType ~= Enum.CameraType.Scriptable then
				cc.CameraType = Enum.CameraType.Scriptable
			end
			cc.CFrame = CFrame.new(cam.pos) * CFrame.fromEulerAnglesYXZ(cam.pitch, cam.yaw, 0)
		end
	end))
end

-- ===== TÌM NHÀ (TYCOON) CỦA MÌNH =====
local myName = string.lower(localPlayer.Name)
local myDisplay = string.lower(localPlayer.DisplayName)

local function matchesMe(inst)
	local n = string.lower(inst.Name)
	if n == myName or n == myDisplay then
		return true
	end
	local ov = inst:FindFirstChild("Owner")
	if ov then
		if ov:IsA("ObjectValue") and ov.Value == localPlayer then
			return true
		end
		if ov:IsA("StringValue") and string.lower(ov.Value) == myName then
			return true
		end
	end
	return false
end

local function findMyTycoon()
	local char = localPlayer.Character
	-- Lưu ý: Character cũng mang tên người chơi, phải loại ra kẻo nhận nhầm là nhà
	local function ok(inst)
		return (inst:IsA("Model") or inst:IsA("Folder"))
			and inst ~= char
			and not inst:FindFirstChildOfClass("Humanoid")
			and matchesMe(inst)
	end
	-- Quét rẻ trước (cấp 1, cấp 2), cuối cùng mới quét toàn bộ
	local top = Workspace:GetChildren()
	for _, a in ipairs(top) do
		if ok(a) then
			return a
		end
	end
	for _, a in ipairs(top) do
		for _, b in ipairs(a:GetChildren()) do
			if ok(b) then
				return b
			end
		end
	end
	local n = 0
	for _, d in ipairs(Workspace:GetDescendants()) do
		n += 1
		if n % 3000 == 0 then
			task.wait()
		end
		if ok(d) then
			return d
		end
	end
	return nil
end

-- ===== QUÉT NÚT / COLLECT (chạy mỗi vài giây, KHÔNG chạy mỗi vòng) =====
local function underCollector(inst, root)
	local cur = inst.Parent
	for _ = 1, 3 do
		if not cur or cur == root then
			return false
		end
		local n = string.lower(cur.Name)
		if n == "collector" or n == "collect" then
			return true
		end
		cur = cur.Parent
	end
	return false
end

local function looksBought(part, root, soleButton)
	local cur, hops = part.Parent, 0
	while cur and cur ~= Workspace and hops < 5 do
		if cur:GetAttribute("Purchased") == true or cur:GetAttribute("Bought") == true
			or cur:GetAttribute("Owned") == true or cur:GetAttribute("Locked") == true
			or cur:GetAttribute("Hidden") == true then
			return true
		end
		if cur == root then
			break
		end
		cur = cur.Parent
		hops += 1
	end
	-- Chỉ soi BoolValue / nhãn "đã mua" khi khối chứa đúng 1 nút (tránh nhầm sang nút khác)
	if soleButton and part.Parent then
		for _, sub in ipairs(part.Parent:GetDescendants()) do
			if sub:IsA("BoolValue") then
				local b = normalizeStr(sub.Name)
				if (b == "purchased" or b == "bought" or b == "owned") and sub.Value == true then
					return true
				end
				if (b == "unlocked" or b == "visible") and sub.Value == false then
					return true
				end
			elseif sub:IsA("TextLabel") or sub:IsA("TextButton") then
				if sub.Visible then
					local t = normalizeStr(sub.Text)
					if string.find(t, "purchased", 1, true) or string.find(t, "owned", 1, true) or string.find(t, "da mua", 1, true) then
						return true
					end
				end
			end
		end
	end
	return false
end

local function textChunks(part, root, withLabels)
	local chunks = {}
	local own = normalizeStr(part.Name)
	if own ~= "button" then
		chunks[#chunks + 1] = own
	end
	local container = part.Parent
	local cur, depth = container, 0
	while cur and cur ~= root and cur ~= Workspace and depth < 3 do
		chunks[#chunks + 1] = normalizeStr(cur.Name)
		cur = cur.Parent
		depth += 1
	end
	if withLabels and container then
		local labels = {}
		for _, d in ipairs(container:GetDescendants()) do
			if (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Text ~= "" then
				labels[#labels + 1] = d.Text
			end
		end
		if #labels > 0 then
			chunks[#chunks + 1] = normalizeStr(table.concat(labels, " | "))
		end
	end
	return chunks
end

-- Khớp từ khoá có ranh giới: ký tự đứng trước không phải chữ cái (không dính "bigdropper2" vào "dropper2"),
-- ký tự đứng sau không phải chữ số (không dính "walls2" vào "walls")
local function kwFind(chunk, kw)
	local init = 1
	while true do
		local s, e = string.find(chunk, kw, init, true)
		if not s then
			return false
		end
		local before = s > 1 and string.sub(chunk, s - 1, s - 1) or ""
		local after = string.sub(chunk, e + 1, e + 1)
		if not string.find(before, "^%a") and not string.find(after, "^%d") then
			return true
		end
		init = s + 1
	end
end

-- Chọn luật có từ khoá DÀI nhất khớp được (cụ thể nhất); hoà thì ưu tiên chữ gần nút hơn, rồi luật đứng trước
local function classify(chunks)
	local bestRule, bestScore = nil, -1
	for idx, rule in ipairs(PRIORITY_LIST) do
		for _, kw in ipairs(rule.nk) do
			for ci, chunk in ipairs(chunks) do
				if kwFind(chunk, kw) then
					local score = #kw * 10 - ci
					if score > bestScore then
						bestRule, bestScore = idx, score
					end
					break
				end
			end
		end
	end
	return bestRule
end

local function scanTycoon(tycoon)
	local parts, perParent = {}, {}
	local collect, collectLoose
	local n = 0
	for _, d in ipairs(tycoon:GetDescendants()) do
		n += 1
		if n % 4000 == 0 then
			task.wait()
		end
		if d:IsA("BasePart") then
			local ln = string.lower(d.Name)
			if ln == "collect" then
				local pn = d.Parent and string.lower(d.Parent.Name) or ""
				if pn == "collector" then
					collect = collect or d
				else
					collectLoose = collectLoose or d
				end
			elseif string.find(ln, "button", 1, true) then
				if underCollector(d, tycoon) then
					collectLoose = collectLoose or d
				else
					parts[#parts + 1] = d
					perParent[d.Parent] = (perParent[d.Parent] or 0) + 1
				end
			end
		end
	end

	-- Dự phòng: không có part nào tên "Button" thì lấy các part có TouchTransmitter (trừ Collect / nhân vật)
	local relaxed = false
	if #parts == 0 then
		relaxed = true
		for _, d in ipairs(tycoon:GetDescendants()) do
			if d:IsA("TouchTransmitter") then
				local p = d.Parent
				if p and p:IsA("BasePart") and string.lower(p.Name) ~= "collect"
					and not underCollector(p, tycoon) and not p:FindFirstAncestorOfClass("Humanoid") then
					parts[#parts + 1] = p
					perParent[p.Parent] = (perParent[p.Parent] or 0) + 1
				end
			end
		end
	end

	local total = #PRIORITY_LIST
	local list = {}
	for i, part in ipairs(parts) do
		local sole = (perParent[part.Parent] or 0) <= 1
		if not looksBought(part, tycoon, sole) then
			local order = classify(textChunks(part, tycoon, sole)) or (total + 1)
			local label
			if order <= total then
				label = PRIORITY_LIST[order].Label
			else
				label = part.Parent and part.Parent.Name or part.Name
			end
			list[#list + 1] = { part = part, order = order, label = label, seq = i }
		end
	end
	table.sort(list, function(a, b)
		if a.order ~= b.order then
			return a.order < b.order
		end
		return a.seq < b.seq
	end)

	cache.list = list
	cache.collect = collect or collectLoose
	cache.dirty = false
	cache.scannedAt = os.clock()

	if #list ~= cache.lastCount then
		cache.lastCount = #list
		if #list == 0 then
			warn("[Farm] Không thấy nút mua nào trong " .. tycoon:GetFullName())
		elseif relaxed then
			warn("[Farm] Không có part tên 'Button', đang dùng chế độ dự phòng (TouchTransmitter)")
		end
	end
	if CONFIG.Debug then
		print(("[Farm] Quét: %d nút, collect = %s"):format(#list, cache.collect and cache.collect:GetFullName() or "không có"))
		for _, c in ipairs(list) do
			print(("  #%d  %s  ->  %s"):format(c.order, c.label, c.part:GetFullName()))
		end
	end
end

-- ===== KIỂM TRA NÚT (nhẹ, chạy mỗi vòng) =====
local function isLive(part)
	return part:IsDescendantOf(Workspace) and part.Transparency < 0.95 and part.CanTouch ~= false
end

local function isButtonGreen(part)
	local c = part.Color
	return c.G > 0.45 and c.G > (c.R + 0.15) and c.G > (c.B + 0.10)
end

-- ===== HÀNH ĐỘNG =====
local hasFTI = typeof(firetouchinterest) == "function"
local function touch(root, part, hold)
	if not hasFTI then
		return
	end
	pcall(function()
		firetouchinterest(root, part, 0)
		task.wait(hold)
		firetouchinterest(root, part, 1)
	end)
end

local oscPhase = 0
local function doCollect(collectPart)
	local root = getCharacterParts()
	if not root then
		return
	end
	startCameraFreeLook()
	oscPhase += CONFIG.CollectOscillateSpeed * CONFIG.LoopDelay
	local y = collectPart.Size.Y * 0.5 + 2.6 + math.sin(oscPhase) * CONFIG.CollectOscillateAmp
	pcall(function()
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		root.CFrame = CFrame.new(collectPart.Position + Vector3.new(0, y, 0))
	end)
	touch(root, collectPart, 0.025)
end

local function doStep(btnPart)
	local root, hum = getCharacterParts()
	if not root then
		return
	end
	stopCameraFreeLook()
	pcall(function()
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		root.CFrame = CFrame.new(btnPart.Position + Vector3.new(0, btnPart.Size.Y * 0.5 + CONFIG.StepAboveOffset, 0))
	end)
	touch(root, btnPart, 0.035)
	if hum then
		pcall(function()
			hum:Move(Vector3.new(0, 0, -1), true)
		end)
	end
end

-- ===== UI (khai báo trước, dựng ở cuối) =====
local ui = {}
local lastStatus = ""

local function setStatus(msg)
	local full = msg .. "  |  Đã mua: " .. bought
	if full == lastStatus then
		return
	end
	lastStatus = full
	if ui.status then
		ui.status.Text = full
	end
end

local function refreshToggle()
	if not ui.toggle then
		return
	end
	if run.on then
		ui.toggle.Text = "Auto Farm: ĐANG BẬT (chạm để tắt)"
		ui.toggle.BackgroundColor3 = Color3.fromRGB(195, 120, 35)
	else
		ui.toggle.Text = "Auto Farm: TẮT (chạm để bật)"
		ui.toggle.BackgroundColor3 = Color3.fromRGB(45, 135, 85)
	end
end

local function skipPart(cand, seconds, why)
	skippedUntil[cand.part] = os.clock() + seconds
	warn(("[Farm] Bỏ qua tạm %ds - %s: %s (%s)"):format(seconds, why, cand.label, cand.part:GetFullName()))
	setStatus("Bỏ qua tạm: " .. cand.label)
end

-- ===== MỘT VÒNG FARM (trả về số giây nghỉ) =====
local function farmTick()
	local now = os.clock()
	local root, hum = getCharacterParts()
	if not root or hum.Health <= 0 then
		stopCameraFreeLook()
		setStatus("Chờ nhân vật...")
		return 0.5
	end

	-- 1) Nhà của mình (có cache, chỉ tìm lại khi mất)
	local tycoon = cache.tycoon
	if not tycoon or not tycoon:IsDescendantOf(Workspace) then
		cache.tycoon = nil
		if now < cache.tycoonRetryAt then
			return 0.5
		end
		tycoon = findMyTycoon()
		if not tycoon then
			cache.tycoonFails += 1
			cache.tycoonRetryAt = os.clock() + math.min(1 + cache.tycoonFails, 5)
			stopCameraFreeLook()
			setStatus("Chưa thấy nhà mang tên: " .. localPlayer.Name)
			return 0.6
		end
		cache.tycoon, cache.dirty, cache.tycoonFails = tycoon, true, 0
	end

	-- 2) Quét lại danh sách nút khi cần
	if cache.dirty or (now - cache.scannedAt) > CONFIG.ScanInterval then
		scanTycoon(tycoon)
		now = os.clock()
	end

	-- 3) Đếm số nút đã mua (nút vừa đạp đã biến mất)
	if lastStepPart and not isLive(lastStepPart) then
		bought += 1
		lastStepPart = nil
		cache.dirty = true
	end

	-- 4) Chọn nút ưu tiên cao nhất còn dùng được
	local target
	for _, c in ipairs(cache.list) do
		local p = c.part
		if not p:IsDescendantOf(Workspace) then
			cache.dirty = true
		elseif isLive(p) then
			local exp = skippedUntil[p]
			if not exp or now >= exp then
				target = c
				break
			end
		end
	end

	local collectPart = cache.collect
	if collectPart and not collectPart:IsDescendantOf(Workspace) then
		collectPart, cache.collect, cache.dirty = nil, nil, true
	end

	local function collectOrIdle()
		if collectPart then
			doCollect(collectPart)
		else
			stopCameraFreeLook()
		end
	end

	-- 5) Quyết định hành động
	if not target then
		waitState, stepStreak = {}, {}
		setStatus("Không còn nút mở -> Collect...")
		collectOrIdle()
	elseif isButtonGreen(target.part) then
		waitState = {}
		if stepStreak.part ~= target.part then
			stepStreak = { part = target.part, since = now }
		end
		if (now - stepStreak.since) > CONFIG.StepGiveUp then
			skipPart(target, CONFIG.StepSkip, "đạp mãi không mua được")
			stepStreak = {}
		else
			setStatus("Đủ tiền -> Đạp: " .. target.label)
			lastStepPart = target.part
			doStep(target.part)
		end
	else
		stepStreak = {}
		if waitState.part ~= target.part then
			waitState = { part = target.part, since = now }
		end
		if (now - waitState.since) > CONFIG.WaitLimit then
			skipPart(target, CONFIG.GhostSkip, "chờ quá lâu không xanh")
			waitState = {}
		else
			setStatus("Chờ tiền (" .. target.label .. ") -> Collect...")
			collectOrIdle()
		end
	end

	return CONFIG.LoopDelay
end

-- ===== BẬT / TẮT FARM =====
local function stopFarm()
	run.on = false
	run.token += 1
	stopCameraFreeLook()
	lastStepPart = nil
	waitState, stepStreak = {}, {}
	setStatus("Đã dừng")
	refreshToggle()
end

local function startFarm()
	if destroyed or run.on then
		return
	end
	run.on = true
	run.token += 1
	local myToken = run.token
	cache.dirty = true
	setStatus("Đang chạy...")
	refreshToggle()

	task.spawn(function()
		while run.on and run.token == myToken and not destroyed do
			local ok, res = pcall(farmTick)
			local delay = CONFIG.LoopDelay
			if ok then
				if type(res) == "number" then
					delay = res
				end
			else
				-- Lỗi ở 1 vòng không làm chết cả script: ghi log, quét lại rồi chạy tiếp
				warn("[Farm] Lỗi vòng lặp: " .. tostring(res))
				setStatus("Lỗi, tự thử lại...")
				cache.dirty = true
				delay = 1
			end
			task.wait(delay)
		end
		if run.token == myToken then
			run.on = false
			stopCameraFreeLook()
			refreshToggle()
		end
	end)
end

-- ===== UI =====
local function getUiParent()
	local ok, h = pcall(function() return gethui and gethui() end)
	if ok and h then
		return h
	end
	if pcall(function() return CoreGui:GetChildren() end) then
		return CoreGui
	end
	return localPlayer:WaitForChild("PlayerGui")
end

local function makeDraggable(handle, target, gui)
	local dragging, startInput, startPos, startUi = false, nil, nil, nil
	handle.InputBegan:Connect(function(input)
		local t = input.UserInputType
		if t ~= Enum.UserInputType.MouseButton1 and t ~= Enum.UserInputType.Touch then
			return
		end
		dragging, startInput = true, input
		startPos, startUi = input.Position, target.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end)
	track(UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end
		if input ~= startInput and input.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end
		local d = input.Position - startPos
		target.Position = UDim2.new(startUi.X.Scale, startUi.X.Offset + d.X, startUi.Y.Scale, startUi.Y.Offset + d.Y)
		-- giữ UI luôn nằm trong màn hình
		local vp, ap, sz = gui.AbsoluteSize, target.AbsolutePosition, target.AbsoluteSize
		local dx = math.clamp(ap.X, 0, math.max(vp.X - sz.X, 0)) - ap.X
		local dy = math.clamp(ap.Y, 0, math.max(vp.Y - sz.Y, 0)) - ap.Y
		if dx ~= 0 or dy ~= 0 then
			target.Position += UDim2.fromOffset(dx, dy)
		end
	end))
end

local function createUi()
	local gui = Instance.new("ScreenGui")
	gui.Name = "ElementalTycoonAutoGui"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 999
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = getUiParent()

	local panel = Instance.new("Frame")
	panel.Size = UDim2.new(0, 260, 0, 98)
	panel.Position = UDim2.new(0.5, -130, 0.14, 0)
	panel.BackgroundColor3 = Color3.fromRGB(22, 24, 30)
	panel.BorderSizePixel = 0
	panel.Active = true
	panel.Parent = gui
	Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 8)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -40, 0, 22)
	title.Position = UDim2.new(0, 10, 0, 2)
	title.BackgroundTransparency = 1
	title.Text = "Auto Tycoon (" .. localPlayer.Name .. ")"
	title.TextColor3 = Color3.fromRGB(235, 238, 245)
	title.TextSize = 12
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextTruncate = Enum.TextTruncate.AtEnd
	title.Parent = panel

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 22, 0, 22)
	closeBtn.Position = UDim2.new(1, -26, 0, 3)
	closeBtn.BackgroundColor3 = Color3.fromRGB(180, 45, 55)
	closeBtn.Text = "X"
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.TextSize = 12
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.BorderSizePixel = 0
	closeBtn.AutoButtonColor = false
	closeBtn.Parent = panel
	Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(1, -20, 0, 30)
	toggle.Position = UDim2.new(0, 10, 0, 28)
	toggle.BackgroundColor3 = Color3.fromRGB(45, 135, 85)
	toggle.Text = ""
	toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggle.TextSize = 12
	toggle.Font = Enum.Font.GothamBold
	toggle.BorderSizePixel = 0
	toggle.AutoButtonColor = false
	toggle.Parent = panel
	Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

	local status = Instance.new("TextLabel")
	status.Size = UDim2.new(1, -20, 0, 32)
	status.Position = UDim2.new(0, 10, 0, 62)
	status.BackgroundTransparency = 1
	status.Text = "Sẵn sàng"
	status.TextColor3 = Color3.fromRGB(175, 185, 205)
	status.TextSize = 10
	status.Font = Enum.Font.Gotham
	status.TextXAlignment = Enum.TextXAlignment.Left
	status.TextYAlignment = Enum.TextYAlignment.Top
	status.TextWrapped = true
	status.Parent = panel

	ui.gui, ui.toggle, ui.status = gui, toggle, status
	makeDraggable(panel, panel, gui)

	toggle.Activated:Connect(function()
		if destroyed then
			return
		end
		if run.on then
			stopFarm()
		else
			startFarm()
		end
	end)
	closeBtn.Activated:Connect(function()
		if ui.destroy then
			ui.destroy()
		end
	end)
	refreshToggle()
end

local function destroyScript()
	if destroyed then
		return
	end
	destroyed = true
	stopFarm()
	for _, c in ipairs(conns) do
		pcall(function() c:Disconnect() end)
	end
	if ui.gui then
		ui.gui:Destroy()
	end
	if genv.ETAF_CLEANUP == destroyScript then
		genv.ETAF_CLEANUP = nil
	end
end
ui.destroy = destroyScript
genv.ETAF_CLEANUP = destroyScript

-- ===== CHỐNG AFK =====
if CONFIG.AntiAfk then
	track(localPlayer.Idled:Connect(function()
		pcall(function()
			local vu = game:GetService("VirtualUser")
			vu:CaptureController()
			vu:ClickButton2(Vector2.new())
		end)
	end))
end

-- ===== TỰ VÀO LẠI + TỰ NẠP LẠI SCRIPT =====
if CONFIG.SCRIPT_URL ~= "" and typeof(queue_on_teleport) == "function" then
	pcall(queue_on_teleport, ('loadstring(game:HttpGet("%s"))()'):format(CONFIG.SCRIPT_URL))
end

if CONFIG.AutoRejoin then
	local rejoining = false
	local function rejoin()
		if rejoining or destroyed then
			return
		end
		rejoining = true
		task.spawn(function()
			while not destroyed do
				pcall(function()
					if #Players:GetPlayers() <= 1 then
						TeleportService:Teleport(game.PlaceId, localPlayer)
					else
						TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, localPlayer)
					end
				end)
				task.wait(CONFIG.RejoinDelay)
			end
			rejoining = false
		end)
	end
	track(GuiService.ErrorMessageChanged:Connect(function(msg)
		if msg and msg ~= "" then
			rejoin()
		end
	end))
	pcall(function()
		local overlay = CoreGui.RobloxPromptGui.promptOverlay
		track(overlay.ChildAdded:Connect(function(c)
			if c.Name == "ErrorPrompt" then
				rejoin()
			end
		end))
	end)
end

-- ===== KHỞI ĐỘNG =====
createUi()
if CONFIG.AutoStart then
	task.defer(startFarm)
end
