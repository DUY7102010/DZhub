-- DZ MENU v2 | Delta Roblox (PC + Mobile)
-- Gộp: khung menu DZ + di chuyển (speed/jump/fly/noclip) + fix lag + treo màn hình đen + anti-AFK + auto rejoin
local Players         = game:GetService("Players")
local TweenService    = game:GetService("TweenService")
local UIS             = game:GetService("UserInputService")
local Lighting        = game:GetService("Lighting")
local RunService      = game:GetService("RunService")
local GuiService      = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer     = Players.LocalPlayer

local ENV = (getgenv and getgenv()) or _G
if ENV.DZ and ENV.DZ.Destroy then pcall(ENV.DZ.Destroy) end -- xoá bản cũ khi chạy lại

-- ===== CẤU HÌNH =====
local CFG = {
	SCRIPT_URL   = "",  -- raw URL của script này; điền để tự nạp lại sau rejoin (cần queue_on_teleport)
	REJOIN_DELAY = 8,   -- giây giữa các lần thử rejoin
	AFK_FPS      = 5,   -- FPS khi treo màn hình đen
	BATCH        = 400, -- số instance xử lý mỗi lượt khi fix lag (tránh đơ)
}

local function getGuiParent()
	local ok, h = pcall(function() return gethui and gethui() end)
	if ok and h then return h end
	local ok2 = pcall(function() return game:GetService("CoreGui"):GetChildren() end)
	if ok2 then return game:GetService("CoreGui") end
	return LocalPlayer:WaitForChild("PlayerGui")
end

-- ===== THEME =====
local CYAN   = Color3.fromRGB(0, 230, 255)
local BLUE   = Color3.fromRGB(0, 170, 255)
local PURPLE = Color3.fromRGB(176, 150, 255)
local GRAY   = Color3.fromRGB(90, 94, 110)
local MUTED  = Color3.fromRGB(150, 154, 170)
local BG1    = Color3.fromRGB(16, 20, 36)
local BG2    = Color3.fromRGB(34, 26, 62)
local WHITE  = Color3.new(1, 1, 1)
local FULL   = UDim.new(1, 0)
local function R(n) return UDim.new(0, n) end

local conns = {}
local function track(c) conns[#conns + 1] = c return c end

local function new(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	if parent then o.Parent = parent end
	return o
end
local function corner(p, r) return new("UICorner", {CornerRadius = r}, p) end

local CYCLE = ColorSequence.new{
	ColorSequenceKeypoint.new(0, CYAN),
	ColorSequenceKeypoint.new(0.5, PURPLE),
	ColorSequenceKeypoint.new(1, CYAN),
}

-- Viền trong suốt chạy như sóng (gradient trượt liên tục)
local function waveStroke(parent, th, speed)
	local s = new("UIStroke", {Thickness = th, Color = WHITE, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, parent)
	local g = new("UIGradient", {
		Color = CYCLE,
		Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0, 0.85),
			NumberSequenceKeypoint.new(0.5, 0.05),
			NumberSequenceKeypoint.new(1, 0.85),
		},
		Rotation = 25,
		Offset = Vector2.new(-1, 0),
	}, s)
	TweenService:Create(g, TweenInfo.new(speed or 2.6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {Offset = Vector2.new(1, 0)}):Play()
	return s
end

-- ===== GUI GỐC =====
local Gui = new("ScreenGui", {
	Name = "DZ_UI", ResetOnSpawn = false, IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999,
}, nil)
Gui.Parent = getGuiParent()

-- ===== CHỐNG VĂNG KHỎI MÀN HÌNH =====
local Clamp = {}
local function clampObj(obj)
	local s = Gui.AbsoluteSize
	local sz = Vector2.new(obj.Size.X.Offset, obj.Size.Y.Offset)
	local p = Vector2.new(obj.Position.X.Offset, obj.Position.Y.Offset)
	obj.Position = UDim2.fromOffset(
		math.clamp(p.X, 0, math.max(0, s.X - sz.X)),
		math.clamp(p.Y, 0, math.max(0, s.Y - sz.Y)))
end
local function register(obj) Clamp[obj] = true clampObj(obj) end
track(Gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	for obj in pairs(Clamp) do
		if obj.Parent then clampObj(obj) else Clamp[obj] = nil end
	end
end))

-- ===== KÉO THẢ (chuột + cảm ứng), phân biệt tap / kéo =====
local function makeDraggable(handle, target, onTap)
	local dragging, moved, startInput, startMouse, startPos = false, false
	handle.InputBegan:Connect(function(input)
		if dragging then return end
		local t = input.UserInputType
		if t ~= Enum.UserInputType.MouseButton1 and t ~= Enum.UserInputType.Touch then return end
		dragging, moved = true, false
		startInput = input
		startMouse = input.Position
		startPos = Vector2.new(target.Position.X.Offset, target.Position.Y.Offset)
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
				if not moved and onTap then onTap() end
			end
		end)
	end)
	track(UIS.InputChanged:Connect(function(input)
		if not dragging then return end
		if input ~= startInput and input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
		local d = input.Position - startMouse
		if not moved and d.Magnitude > 6 then moved = true end
		if moved then
			target.Position = UDim2.fromOffset(startPos.X + d.X, startPos.Y + d.Y)
			clampObj(target)
		end
	end))
end

-- ===== CẦN GẠT TRÒN =====
local function makeSwitch(parent, pos, anchor)
	local W, H, K = 46, 24, 18
	local track_ = new("Frame", {
		Size = UDim2.fromOffset(W, H), Position = pos, AnchorPoint = anchor or Vector2.zero,
		BackgroundColor3 = GRAY, BorderSizePixel = 0,
	}, parent)
	corner(track_, FULL)
	new("UIStroke", {Color = WHITE, Transparency = 0.8, Thickness = 1}, track_)
	local knob = new("Frame", {
		Size = UDim2.fromOffset(K, K), Position = UDim2.fromOffset(3, 3),
		BackgroundColor3 = WHITE, BorderSizePixel = 0,
	}, track_)
	corner(knob, FULL)
	local sw = {}
	function sw.Set(state, instant)
		local ti = instant and TweenInfo.new(0) or TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		TweenService:Create(knob, ti, {Position = UDim2.fromOffset(state and (W - K - 3) or 3, 3)}):Play()
		TweenService:Create(track_, ti, {BackgroundColor3 = state and BLUE or GRAY}):Play()
	end
	return sw
end

-- Chữ trạng thái có bước chuyển tiếp: "Đang bật" -> "BẬT"
local function setStateText(lbl, state, f)
	lbl.Text = state and "Đang bật" or "Đang tắt"
	TweenService:Create(lbl, TweenInfo.new(0.2), {TextColor3 = state and CYAN or MUTED}):Play()
	local tk = f.Token
	task.delay(0.3, function()
		if f.Token == tk and lbl.Parent then lbl.Text = state and "BẬT" or "TẮT" end
	end)
end

-- ===== NÚT TRÒN "DZ" =====
local Btn = new("TextButton", {
	Name = "OpenBtn", Size = UDim2.fromOffset(56, 56), Position = UDim2.fromOffset(20, 160),
	BackgroundColor3 = WHITE, Text = "", AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 30,
}, Gui)
corner(Btn, FULL)
local btnGrad = new("UIGradient", {Color = CYCLE, Rotation = 0}, Btn)
TweenService:Create(btnGrad, TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {Rotation = 360}):Play()
waveStroke(Btn, 2, 2.2)
local gloss = new("Frame", { -- mảng bóng kiểu nhựa
	Size = UDim2.new(0.62, 0, 0.3, 0), Position = UDim2.new(0.19, 0, 0.07, 0),
	BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 2,
}, Btn)
corner(gloss, FULL)
new("UIGradient", {
	Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 1)},
	Rotation = 90,
}, gloss)
new("TextLabel", {
	Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "DZ",
	Font = Enum.Font.GothamBlack, TextSize = 20, TextColor3 = WHITE,
	TextStrokeColor3 = Color3.fromRGB(40, 20, 90), TextStrokeTransparency = 0.5, ZIndex = 3,
}, Btn)
register(Btn)

-- ===== BẢNG MENU =====
local Menu = new("Frame", {
	Name = "Menu", Size = UDim2.fromOffset(290, 380), Position = UDim2.fromOffset(20, 224),
	BackgroundColor3 = WHITE, BackgroundTransparency = 0.04, BorderSizePixel = 0, Visible = false, ZIndex = 10,
}, Gui)
corner(Menu, R(22))
new("UIGradient", {Color = ColorSequence.new(BG1, BG2), Rotation = 60}, Menu)
waveStroke(Menu, 2, 3)
local MenuScale = new("UIScale", {Scale = 1}, Menu)

new("TextLabel", {
	Position = UDim2.fromOffset(18, 0), Size = UDim2.new(1, -70, 0, 46), BackgroundTransparency = 1,
	Text = "DZ  MENU", Font = Enum.Font.GothamBlack, TextSize = 16, TextColor3 = CYAN,
	TextXAlignment = Enum.TextXAlignment.Left,
}, Menu)
local Header = new("TextButton", { -- vùng kéo menu
	Size = UDim2.new(1, -48, 0, 46), BackgroundTransparency = 1, Text = "", ZIndex = 5, AutoButtonColor = false,
}, Menu)
local Close = new("TextButton", {
	Size = UDim2.fromOffset(28, 28), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 9),
	BackgroundColor3 = WHITE, BackgroundTransparency = 0.88, Text = "×", TextSize = 20,
	Font = Enum.Font.GothamBold, TextColor3 = WHITE, AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 10,
}, Menu)
corner(Close, FULL)

local List = new("ScrollingFrame", {
	Position = UDim2.fromOffset(0, 50), Size = UDim2.new(1, 0, 1, -58), BackgroundTransparency = 1,
	BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = CYAN,
	CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, Menu)
new("UIListLayout", {Padding = R(8), SortOrder = Enum.SortOrder.LayoutOrder}, List)
new("UIPadding", {PaddingLeft = R(12), PaddingRight = R(12), PaddingTop = R(4), PaddingBottom = R(8)}, List)

makeDraggable(Header, Menu)
Clamp[Menu] = true

local menuOpen, menuPlaced = false, false
local function setMenu(open)
	if menuOpen == open then return end
	menuOpen = open
	if open then
		local s = Gui.AbsoluteSize
		Menu.Size = UDim2.fromOffset(math.min(290, s.X - 16), math.min(380, s.Y - 24))
		if not menuPlaced then
			menuPlaced = true
			Menu.Position = UDim2.fromOffset(Btn.Position.X.Offset, Btn.Position.Y.Offset + 64)
		end
		clampObj(Menu)
		MenuScale.Scale = 0.8
		Menu.Visible = true
		TweenService:Create(MenuScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
	else
		local t = TweenService:Create(MenuScale, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0.8})
		t:Play()
		t.Completed:Connect(function() if not menuOpen then Menu.Visible = false end end)
	end
end
makeDraggable(Btn, Btn, function() setMenu(not menuOpen) end)
Close.Activated:Connect(function() setMenu(false) end)
track(UIS.InputBegan:Connect(function(i, gp)
	if not gp and i.KeyCode == Enum.KeyCode.RightShift then setMenu(not menuOpen) end -- phím tắt PC
end))

-- ===== NÚT NỔI (tự sinh khi bật chức năng) =====
local features, order, floatCount = {}, 0, 0
local applyVisual, createFloat, destroyFloat

function createFloat(f)
	floatCount += 1
	local W, H = 124, 76
	local n = (floatCount - 1) % 6
	local fr = new("Frame", {
		Name = "Float_" .. f.Name, Size = UDim2.fromOffset(W, H),
		Position = UDim2.fromOffset(90 + n * 20, 120 + n * 20),
		BackgroundColor3 = WHITE, BackgroundTransparency = 0.06, BorderSizePixel = 0, ZIndex = 20,
	}, Gui)
	corner(fr, R(18))
	new("UIGradient", {Color = ColorSequence.new(BG1, BG2), Rotation = 60}, fr)
	waveStroke(fr, 1.6, 2.8)
	new("TextLabel", {
		Position = UDim2.fromOffset(10, 7), Size = UDim2.new(1, -36, 0, 18), BackgroundTransparency = 1,
		Text = f.Name, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = WHITE,
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
	}, fr)
	local sw = makeSwitch(fr, UDim2.fromOffset(10, 38))
	local st = new("TextLabel", {
		Position = UDim2.fromOffset(62, 38), Size = UDim2.new(1, -68, 0, 24), BackgroundTransparency = 1,
		Text = "TẮT", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = MUTED,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, fr)
	local hit = new("TextButton", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 5, AutoButtonColor = false,
	}, fr)
	local x = new("TextButton", {
		Size = UDim2.fromOffset(18, 18), Position = UDim2.new(1, -24, 0, 6), BackgroundColor3 = WHITE,
		BackgroundTransparency = 0.88, Text = "×", TextSize = 14, Font = Enum.Font.GothamBold,
		TextColor3 = WHITE, AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 10,
	}, fr)
	corner(x, FULL)

	f.Float = {Frame = fr, Switch = sw, State = st}
	register(fr)
	makeDraggable(hit, fr, function() f.Set(not f.State, true) end)
	x.Activated:Connect(function()
		if f.State then f.Set(false, true) end
		destroyFloat(f)
	end)
	local sc = new("UIScale", {Scale = 0.6}, fr)
	TweenService:Create(sc, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
end

function destroyFloat(f)
	if f.Float then
		Clamp[f.Float.Frame] = nil
		f.Float.Frame:Destroy()
		f.Float = nil
	end
end

function applyVisual(f, instant)
	f.RowSwitch.Set(f.State, instant)
	setStateText(f.RowState, f.State, f)
	if f.Float then
		f.Float.Switch.Set(f.State, instant)
		setStateText(f.Float.State, f.State, f)
	end
end

-- ===== API CÔNG KHAI =====
local DZ = {}
local function nextOrder() order += 1 return order end

function DZ.AddSection(text)
	new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = string.upper(text),
		Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = PURPLE,
		TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nextOrder(),
	}, List)
end

-- opts.Floating (mặc định true): bật thì sinh nút nổi kéo thả được
-- opts.Default: trạng thái ban đầu
function DZ.AddToggle(name, opts, callback)
	opts = opts or {}
	local f = {Name = name, State = false, Token = 0, Callback = callback, Floating = opts.Floating ~= false}
	local row = new("Frame", {
		Size = UDim2.new(1, 0, 0, 52), BackgroundColor3 = WHITE, BackgroundTransparency = 0.92,
		BorderSizePixel = 0, LayoutOrder = nextOrder(),
	}, List)
	corner(row, R(14))
	waveStroke(row, 1.2, 3.4)
	new("TextLabel", {
		Position = UDim2.fromOffset(14, 7), Size = UDim2.new(1, -84, 0, 20), BackgroundTransparency = 1,
		Text = name, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = WHITE,
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
	}, row)
	f.RowState = new("TextLabel", {
		Position = UDim2.fromOffset(14, 28), Size = UDim2.new(1, -84, 0, 16), BackgroundTransparency = 1,
		Text = "TẮT", Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = MUTED,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, row)
	f.RowSwitch = makeSwitch(row, UDim2.new(1, -12, 0.5, 0), Vector2.new(1, 0.5))
	local hit = new("TextButton", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 5, AutoButtonColor = false,
	}, row)

	function f.Set(state, fromFloat)
		if f.State == state then return end
		f.State = state
		f.Token += 1
		if f.Floating and state and not f.Float then createFloat(f) end
		if f.Floating and not state and f.Float and not fromFloat then destroyFloat(f) end
		applyVisual(f)
		if f.Callback then
			task.spawn(function()
				local ok, err = pcall(f.Callback, state)
				if not ok then warn("[DZ] " .. name .. ": " .. tostring(err)) end
			end)
		end
	end
	hit.Activated:Connect(function() f.Set(not f.State, false) end)
	features[name] = f
	if opts.Default then f.Set(true, false) end
	return f
end

function DZ.AddButton(name, callback)
	local row = new("Frame", {
		Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = WHITE, BackgroundTransparency = 0.92,
		BorderSizePixel = 0, LayoutOrder = nextOrder(),
	}, List)
	corner(row, R(14))
	waveStroke(row, 1.2, 3.4)
	new("TextLabel", {
		Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -100, 1, 0), BackgroundTransparency = 1,
		Text = name, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = WHITE,
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
	}, row)
	local pill = new("TextLabel", {
		Size = UDim2.fromOffset(74, 26), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
		BackgroundColor3 = BLUE, BackgroundTransparency = 0.25, Text = "CHẠY", Font = Enum.Font.GothamBold,
		TextSize = 11, TextColor3 = WHITE, BorderSizePixel = 0,
	}, row)
	corner(pill, FULL)
	local hit = new("TextButton", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 5, AutoButtonColor = false,
	}, row)
	local busy = false
	hit.Activated:Connect(function()
		if busy then return end
		busy = true
		pill.Text = "Đang chạy"
		TweenService:Create(pill, TweenInfo.new(0.2), {BackgroundColor3 = PURPLE}):Play()
		task.spawn(function()
			local ok, err = pcall(callback)
			if not ok then warn("[DZ] " .. name .. ": " .. tostring(err)) end
			pill.Text = ok and "XONG" or "LỖI"
			task.wait(0.9)
			if pill.Parent then
				pill.Text = "CHẠY"
				TweenService:Create(pill, TweenInfo.new(0.2), {BackgroundColor3 = BLUE}):Play()
			end
			busy = false
		end)
	end)
end

-- Thanh trượt giá trị: callback(value) gọi mỗi khi giá trị đổi
function DZ.AddSlider(name, min, max, default, callback, suffix)
	local value = math.clamp(default, min, max)
	local row = new("Frame", {
		Size = UDim2.new(1, 0, 0, 56), BackgroundColor3 = WHITE, BackgroundTransparency = 0.92,
		BorderSizePixel = 0, LayoutOrder = nextOrder(),
	}, List)
	corner(row, R(14))
	waveStroke(row, 1.2, 3.4)
	new("TextLabel", {
		Position = UDim2.fromOffset(14, 6), Size = UDim2.new(1, -90, 0, 18), BackgroundTransparency = 1,
		Text = name, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = WHITE,
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
	}, row)
	local valLbl = new("TextLabel", {
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 6), Size = UDim2.fromOffset(70, 18),
		BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = CYAN,
		TextXAlignment = Enum.TextXAlignment.Right,
	}, row)
	local bar = new("Frame", {
		Position = UDim2.new(0, 14, 0, 36), Size = UDim2.new(1, -28, 0, 8),
		BackgroundColor3 = GRAY, BorderSizePixel = 0,
	}, row)
	corner(bar, FULL)
	local fill = new("Frame", {Size = UDim2.fromScale(0, 1), BackgroundColor3 = WHITE, BorderSizePixel = 0}, bar)
	corner(fill, FULL)
	new("UIGradient", {Color = ColorSequence.new(CYAN, BLUE)}, fill)
	local knob = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 2,
	}, bar)
	corner(knob, FULL)
	local function render(v)
		local pct = (v - min) / (max - min)
		fill.Size = UDim2.fromScale(pct, 1)
		knob.Position = UDim2.fromScale(pct, 0.5)
		valLbl.Text = tostring(v) .. (suffix or "")
	end
	local function setFromX(x)
		local pct = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
		local v = math.floor(min + (max - min) * pct + 0.5)
		if v ~= value then
			value = v
			render(v)
			task.spawn(function()
				local ok, err = pcall(callback, v)
				if not ok then warn("[DZ] " .. name .. ": " .. tostring(err)) end
			end)
		end
	end
	local hit = new("TextButton", {
		Position = UDim2.fromOffset(0, 24), Size = UDim2.new(1, 0, 1, -24), BackgroundTransparency = 1,
		Text = "", ZIndex = 5, AutoButtonColor = false,
	}, row)
	hit.InputBegan:Connect(function(input)
		local t = input.UserInputType
		if t ~= Enum.UserInputType.MouseButton1 and t ~= Enum.UserInputType.Touch then return end
		List.ScrollingEnabled = false -- chặn cuộn danh sách khi đang kéo thanh trượt
		setFromX(input.Position.X)
		local mc, ec
		mc = UIS.InputChanged:Connect(function(j)
			if j == input or (t == Enum.UserInputType.MouseButton1 and j.UserInputType == Enum.UserInputType.MouseMovement) then
				setFromX(j.Position.X)
			end
		end)
		ec = UIS.InputEnded:Connect(function(j)
			if j == input or (t == Enum.UserInputType.MouseButton1 and j.UserInputType == Enum.UserInputType.MouseButton1) then
				mc:Disconnect() ec:Disconnect()
				List.ScrollingEnabled = true
			end
		end)
	end)
	render(value)
end

function DZ.Open(v) setMenu(v ~= false) end

function DZ.Destroy()
	for _, f in pairs(features) do
		if f.State and f.Callback then pcall(f.Callback, false) end
	end
	for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
	Gui:Destroy()
	ENV.DZ = nil
end
DZ.Gui = Gui
ENV.DZ = DZ

-- =====================================================================
-- NHÂN VẬT (cập nhật khi respawn)
-- =====================================================================
local char, hum, root
local defSpeed, defJump = 16, 50
local onRespawn = {} -- hàm chạy lại sau khi respawn (fly, v.v.)

local function bindChar(c)
	char = c
	hum  = c:WaitForChild("Humanoid", 10)
	root = c:WaitForChild("HumanoidRootPart", 10)
	if hum then defSpeed, defJump = hum.WalkSpeed, hum.JumpPower end
	for _, fn in ipairs(onRespawn) do task.spawn(pcall, fn) end
end
track(LocalPlayer.CharacterAdded:Connect(bindChar))
if LocalPlayer.Character then task.spawn(bindChar, LocalPlayer.Character) end

-- =====================================================================
-- DI CHUYỂN (có nút nổi)
-- =====================================================================
DZ.AddSection("Di chuyển")

local val = {speed = 60, jump = 120, fly = 60}

-- Tốc độ
local speedConn
DZ.AddToggle("Tăng tốc độ", {Floating = true}, function(on)
	if speedConn then speedConn:Disconnect() speedConn = nil end
	if on then
		speedConn = RunService.Heartbeat:Connect(function()
			if hum and hum.Parent then hum.WalkSpeed = val.speed end -- ép lại mỗi frame vì game hay reset
		end)
	elseif hum then
		hum.WalkSpeed = defSpeed
	end
end)
DZ.AddSlider("Giá trị tốc độ", 16, 300, val.speed, function(v) val.speed = v end)

-- Nhảy cao
local jumpConn
DZ.AddToggle("Nhảy cao", {Floating = true}, function(on)
	if jumpConn then jumpConn:Disconnect() jumpConn = nil end
	if on then
		jumpConn = RunService.Heartbeat:Connect(function()
			if hum and hum.Parent then hum.UseJumpPower = true hum.JumpPower = val.jump end
		end)
	elseif hum then
		hum.UseJumpPower = true hum.JumpPower = defJump
	end
end)
DZ.AddSlider("Giá trị nhảy", 50, 400, val.jump, function(v) val.jump = v end)

-- Nhảy vô hạn
local ijConn
DZ.AddToggle("Nhảy vô hạn", {Floating = true}, function(on)
	if ijConn then ijConn:Disconnect() ijConn = nil end
	if on then
		ijConn = UIS.JumpRequest:Connect(function()
			if hum and hum.Parent then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
		end)
	end
end)

-- Xuyên tường
local ncConn
DZ.AddToggle("Xuyên tường", {Floating = true}, function(on)
	if ncConn then ncConn:Disconnect() ncConn = nil end
	if on then
		ncConn = RunService.Stepped:Connect(function()
			if not char then return end
			for _, p in ipairs(char:GetDescendants()) do
				if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
			end
		end)
	end
end)

-- Bay: BodyVelocity + BodyGyro, joystick mobile + nút LÊN/XUỐNG + Space/LeftShift trên PC
local flyBV, flyBG, flyConn, flyOn = nil, nil, nil, false
local hold = {up = false, down = false}
local ctrl
task.spawn(function()
	pcall(function()
		local pm = LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule", 10)
		ctrl = require(pm):GetControls()
	end)
end)

local Pad = new("Frame", {
	Size = UDim2.fromOffset(52, 112), Position = UDim2.fromOffset(math.max(Gui.AbsoluteSize.X, 400) - 72, 200),
	BackgroundTransparency = 1, Visible = false, ZIndex = 20,
}, Gui)
local function padBtn(txt, y, key)
	local b = new("TextButton", {
		Size = UDim2.fromOffset(52, 52), Position = UDim2.fromOffset(0, y), BackgroundColor3 = BG1,
		BackgroundTransparency = 0.1, AutoButtonColor = false, Text = txt, Font = Enum.Font.GothamBold,
		TextSize = 11, TextColor3 = WHITE, BorderSizePixel = 0, ZIndex = 21,
	}, Pad)
	corner(b, FULL)
	waveStroke(b, 1.5, 2.4)
	b.InputBegan:Connect(function(i)
		local t = i.UserInputType
		if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then hold[key] = true end
	end)
	b.InputEnded:Connect(function(i)
		local t = i.UserInputType
		if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then hold[key] = false end
	end)
end
padBtn("LÊN", 0, "up")
padBtn("XUỐNG", 60, "down")
register(Pad)

local function stopFly()
	if flyConn then flyConn:Disconnect() flyConn = nil end
	if flyBV then flyBV:Destroy() flyBV = nil end
	if flyBG then flyBG:Destroy() flyBG = nil end
	hold.up, hold.down = false, false
	if hum and hum.Parent then
		hum.PlatformStand = false
		pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
	end
end

local function startFly()
	stopFly()
	if not (hum and root) then return end
	flyBV = new("BodyVelocity", {MaxForce = Vector3.new(9e9, 9e9, 9e9), Velocity = Vector3.zero}, root)
	flyBG = new("BodyGyro", {MaxTorque = Vector3.new(9e9, 9e9, 9e9), P = 1e4, D = 1e3, CFrame = root.CFrame}, root)
	hum.PlatformStand = true
	flyConn = RunService.RenderStepped:Connect(function()
		if not (root and root.Parent and hum and hum.Health > 0 and flyBV) then return end
		local cam = workspace.CurrentCamera
		local dir
		if ctrl then
			local ok, mv = pcall(ctrl.GetMoveVector, ctrl)
			mv = ok and mv or Vector3.zero
			dir = cam.CFrame.RightVector * mv.X - cam.CFrame.LookVector * mv.Z
		else
			dir = hum.MoveDirection -- dự phòng khi không lấy được PlayerModule
		end
		local v = 0
		if hold.up or UIS:IsKeyDown(Enum.KeyCode.Space) then v += 1 end
		if hold.down or UIS:IsKeyDown(Enum.KeyCode.LeftShift) then v -= 1 end
		dir += Vector3.new(0, v, 0)
		flyBV.Velocity = dir.Magnitude > 0.05 and dir.Unit * val.fly or Vector3.zero
		flyBG.CFrame = cam.CFrame
	end)
end

onRespawn[#onRespawn + 1] = function() if flyOn then task.wait(0.3) startFly() end end

DZ.AddToggle("Bay", {Floating = true}, function(on)
	flyOn = on
	Pad.Visible = on
	if on then startFly() else stopFly() end
end)
DZ.AddSlider("Tốc độ bay", 20, 300, val.fly, function(v) val.fly = v end)

-- =====================================================================
-- HÌNH ẢNH
-- =====================================================================
DZ.AddSection("Hình ảnh")

local lightBackup
DZ.AddToggle("Sáng toàn map", {Floating = true}, function(on)
	if on then
		lightBackup = {
			Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime, FogEnd = Lighting.FogEnd,
			GlobalShadows = Lighting.GlobalShadows, Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
		}
		Lighting.Brightness, Lighting.ClockTime, Lighting.FogEnd = 2, 14, 9e9
		Lighting.GlobalShadows = false
		Lighting.Ambient, Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200), Color3.fromRGB(200, 200, 200)
	elseif lightBackup then
		for k, v in pairs(lightBackup) do Lighting[k] = v end
		lightBackup = nil
	end
end)

-- =====================================================================
-- TỐI ƯU / CHỐNG TREO (không sinh nút nổi)
-- =====================================================================
DZ.AddSection("Tối ưu / chống treo")

local fpsCap = 60
local function setFps(n) if setfpscap then pcall(setfpscap, n) end end

local function optimizeInstance(v)
	if v:IsA("BasePart") and not v:IsA("Terrain") then
		v.Material = Enum.Material.SmoothPlastic
		v.Reflectance = 0
		v.CastShadow = false
	elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
		v.Enabled = false
	elseif v:IsA("PostEffect") then
		v.Enabled = false
	end
end

DZ.AddButton("Fix lag (giảm đồ hoạ)", function()
	pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
	pcall(function() Lighting.GlobalShadows = false Lighting.FogEnd = 9e9 end)
	pcall(function()
		local t = workspace.Terrain
		t.WaterWaveSize, t.WaterWaveSpeed, t.WaterReflectance = 0, 0, 0
	end)
	for _, v in ipairs(Lighting:GetDescendants()) do pcall(optimizeInstance, v) end
	local n = 0
	for _, v in ipairs(workspace:GetDescendants()) do
		pcall(optimizeInstance, v)
		n += 1
		if n % CFG.BATCH == 0 then task.wait() end -- nhả luồng, tránh đơ máy khi quét map lớn
	end
	collectgarbage("collect")
end)

DZ.AddButton("Ultra: xoá texture (không hoàn lại)", function()
	local n = 0
	for _, v in ipairs(workspace:GetDescendants()) do
		pcall(function()
			if v:IsA("Decal") or v:IsA("Texture") or v:IsA("SurfaceAppearance") then v:Destroy()
			elseif v:IsA("MeshPart") then v.TextureID = "" end
		end)
		n += 1
		if n % CFG.BATCH == 0 then task.wait() end
	end
	collectgarbage("collect")
end)

local autoConn
DZ.AddToggle("Chống lag tự động", {Floating = false}, function(on)
	if autoConn then autoConn:Disconnect() autoConn = nil end
	if on then autoConn = workspace.DescendantAdded:Connect(function(v) pcall(optimizeInstance, v) end) end
end)

DZ.AddButton("Dọn RAM", function() collectgarbage("collect") end)

DZ.AddSlider("Giới hạn FPS", 15, 240, fpsCap, function(v) fpsCap = v setFps(v) end)

-- Anti-AFK
local afkConn
DZ.AddToggle("Chống AFK / văng game", {Floating = false, Default = true}, function(on)
	if afkConn then afkConn:Disconnect() afkConn = nil end
	if on then
		afkConn = LocalPlayer.Idled:Connect(function()
			local vu = game:GetService("VirtualUser")
			vu:CaptureController()
			vu:ClickButton2(Vector2.new())
		end)
	end
end)

-- Auto rejoin: phát hiện hộp thoại lỗi/kick/mất kết nối rồi tự vào lại
local rejoinConns, rejoining = {}, false
local rejoinOn = false
local function doRejoin()
	if rejoining or not rejoinOn then return end
	rejoining = true
	task.spawn(function()
		while rejoinOn and ENV.DZ == DZ do
			pcall(function()
				if #Players:GetPlayers() <= 1 then
					LocalPlayer:Kick("\nĐang vào lại server...")
					task.wait(1)
					TeleportService:Teleport(game.PlaceId, LocalPlayer)
				else
					TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
				end
			end)
			task.wait(CFG.REJOIN_DELAY)
		end
		rejoining = false
	end)
end
DZ.AddToggle("Tự vào lại khi bị văng", {Floating = false, Default = true}, function(on)
	rejoinOn = on
	for _, c in ipairs(rejoinConns) do c:Disconnect() end
	table.clear(rejoinConns)
	if on then
		if CFG.SCRIPT_URL ~= "" and queue_on_teleport then -- nạp lại script sau khi teleport
			pcall(queue_on_teleport, ('loadstring(game:HttpGet("%s"))()'):format(CFG.SCRIPT_URL))
		end
		rejoinConns[#rejoinConns + 1] = GuiService.ErrorMessageChanged:Connect(function(msg)
			if msg and msg ~= "" then doRejoin() end
		end)
		pcall(function()
			local overlay = game:GetService("CoreGui").RobloxPromptGui.promptOverlay
			rejoinConns[#rejoinConns + 1] = overlay.ChildAdded:Connect(function(c)
				if c.Name == "ErrorPrompt" then doRejoin() end
			end)
		end)
	end
end)

-- Chế độ treo: màn hình đen + tắt render 3D + FPS thấp + tắt tiếng, thoát bằng chấm mờ góc phải trên
local Black = new("Frame", {
	Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0,
	Active = true, Visible = false, ZIndex = 1000, -- Active = true: chặn chạm nhầm xuống menu bên dưới
}, Gui)
local Dot = new("TextButton", {
	Size = UDim2.fromOffset(30, 30), BackgroundColor3 = Color3.fromRGB(26, 26, 26), BackgroundTransparency = 0.4,
	Text = "", AutoButtonColor = false, Visible = false, ZIndex = 1001, BorderSizePixel = 0,
}, Gui)
corner(Dot, FULL)

local afkToken, oldVol = 0, nil
local afkFeature
afkFeature = DZ.AddToggle("Chế độ treo (màn hình đen)", {Floating = false}, function(on)
	afkToken += 1
	local tk = afkToken
	if on then
		Dot.Position = UDim2.fromOffset(Gui.AbsoluteSize.X - 40, 10)
		Black.Visible, Dot.Visible = true, true
		setMenu(false)
		pcall(function() RunService:Set3dRenderingEnabled(false) end)
		setFps(CFG.AFK_FPS)
		pcall(function()
			local g = UserSettings():GetService("UserGameSettings")
			oldVol = g.MasterVolume
			g.MasterVolume = 0
		end)
		task.spawn(function()
			while afkToken == tk do
				task.wait(60)
				if afkToken == tk then setFps(CFG.AFK_FPS) end -- ép lại FPS cap phòng game reset
			end
		end)
	else
		Black.Visible, Dot.Visible = false, false
		pcall(function() RunService:Set3dRenderingEnabled(true) end)
		setFps(fpsCap)
		pcall(function()
			if oldVol then UserSettings():GetService("UserGameSettings").MasterVolume = oldVol end
		end)
	end
end)
Dot.Activated:Connect(function() afkFeature.Set(false, false) end)

-- =====================================================================
-- CHỨC NĂNG KHÁC (có nút nổi) — thêm chức năng mới ở dưới đây
-- =====================================================================
DZ.AddSection("Chức năng")

local DASH_DISTANCE    = 6
local AURA_RANGE       = 50
local SWORD_RADIUS     = 2.4
local SWORD_HEIGHT     = 0
local SWORD_SPIN_SPEED = 120
local SKY_HEIGHT       = 40
local FLY_SPEED_AURA   = 85

local auraArmed, auraEngineRunning = false, false
local spinAngle = 0
local watcherConn, swordConn, godConn, healthConn = nil, nil, nil, nil
local currentLockedTarget = nil
local detachedJoints = {}
local savedStateEnabled = {}

local skyFlyArmed = false
local hoverAnchorPos = nil
local skyFlyConn = nil
local savedPlatformStand = false

local function getHRP(character)
	if not character then return nil end
	return character:FindFirstChild("HumanoidRootPart")
		or character:FindFirstChild("UpperTorso")
		or character:FindFirstChild("Torso")
end

local function hasForceField(character)
	if not character then return false end
	if character:FindFirstChildOfClass("ForceField") then return true end
	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("ForceField") then return true end
	end
	return false
end

local function reattachGripJoints()
	for i = #detachedJoints, 1, -1 do
		local entry = detachedJoints[i]
		if entry.joint and entry.parent then
			pcall(function() entry.joint.Parent = entry.parent end)
		end
		detachedJoints[i] = nil
	end
end

local function detachGripJoints(c, blade)
	reattachGripJoints()
	for _, d in ipairs(blade:GetDescendants()) do
		if d:IsA("JointInstance") and d.Parent then
			table.insert(detachedJoints, { joint = d, parent = d.Parent })
			pcall(function() d.Parent = nil end)
		end
	end
	if c then
		for _, d in ipairs(c:GetDescendants()) do
			if d:IsA("JointInstance") and (d.Part0 == blade or d.Part1 == blade or d.Name == "RightGrip") then
				table.insert(detachedJoints, { joint = d, parent = d.Parent })
				pcall(function() d.Parent = nil end)
			end
		end
	end
end

local function enableStealthGodmode()
	if healthConn then healthConn:Disconnect(); healthConn = nil end
	if godConn then godConn:Disconnect(); godConn = nil end
	if not hum then return end

	local protectedStates = {
		Enum.HumanoidStateType.Dead,
		Enum.HumanoidStateType.FallingDown,
		Enum.HumanoidStateType.Ragdoll,
	}

	savedStateEnabled = {}
	for _, st in ipairs(protectedStates) do
		pcall(function()
			savedStateEnabled[st] = hum:GetStateEnabled(st)
			hum:SetStateEnabled(st, false)
		end)
	end

	pcall(function()
		if hum.MaxHealth > 0 and hum.Health < hum.MaxHealth then
			hum.Health = hum.MaxHealth
		end
	end)

	healthConn = hum.HealthChanged:Connect(function(newHealth)
		if not auraEngineRunning or not hum or not hum.Parent then return end
		pcall(function()
			if hum.MaxHealth > 0 and newHealth < hum.MaxHealth then
				hum.Health = hum.MaxHealth
			end
		end)
	end)

	godConn = hum.StateChanged:Connect(function(_oldState, newState)
		if not auraEngineRunning or not hum or not hum.Parent then return end
		if newState == Enum.HumanoidStateType.Dead
			or newState == Enum.HumanoidStateType.FallingDown
			or newState == Enum.HumanoidStateType.Ragdoll then
			pcall(function()
				if hum.MaxHealth > 0 then hum.Health = hum.MaxHealth end
				hum:ChangeState(Enum.HumanoidStateType.Running)
			end)
		end
	end)
end

local function disableStealthGodmode()
	if healthConn then healthConn:Disconnect(); healthConn = nil end
	if godConn then godConn:Disconnect(); godConn = nil end
	if hum and hum.Parent then
		for st, wasEnabled in pairs(savedStateEnabled) do
			pcall(function() hum:SetStateEnabled(st, wasEnabled) end)
		end
	end
	table.clear(savedStateEnabled)
end

local function findNearestHRPInRange(myRoot)
	local bestHRP, bestDist = nil, AURA_RANGE
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local tChar = plr.Character
			local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
			local tHRP = getHRP(tChar)
			if tHum and tHum.Health > 0 and tHRP then
				local d = (tHRP.Position - myRoot.Position).Magnitude
				if d <= bestDist then
					bestDist = d
					bestHRP = tHRP
				end
			end
		end
	end
	return bestHRP
end

local function getActiveSword()
	if not char or not hum or hum.Health <= 0 then return nil end
	for _, item in ipairs(char:GetChildren()) do
		if item:IsA("Tool") then return item end
	end
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	if backpack then
		for _, item in ipairs(backpack:GetChildren()) do
			if item:IsA("Tool") then
				pcall(function() hum:EquipTool(item) end)
				return item
			end
		end
	end
	return nil
end

local function getBladePart(tool)
	local handle = tool:FindFirstChild("Handle")
	if handle and handle:IsA("BasePart") then return handle end
	for _, d in ipairs(tool:GetDescendants()) do
		if d:IsA("BasePart") then return d end
	end
	return nil
end

local function stopAuraEngineOnly()
	auraEngineRunning = false
	currentLockedTarget = nil
	if swordConn then swordConn:Disconnect(); swordConn = nil end
	disableStealthGodmode()
	reattachGripJoints()
end

local function startAuraEngineForTarget(initialHRP)
	if auraEngineRunning then return end
	auraEngineRunning = true
	spinAngle = 0
	currentLockedTarget = initialHRP

	enableStealthGodmode()

	local sword = getActiveSword()
	local blade = sword and getBladePart(sword)
	if blade then
		detachGripJoints(char, blade)
	end

	swordConn = RunService.Heartbeat:Connect(function(dt)
		if not auraArmed or not auraEngineRunning then return end
		local myRoot = root or getHRP(char)
		if not myRoot or not hum then return end

		pcall(function()
			if hum.MaxHealth > 0 and hum.Health < hum.MaxHealth then
				hum.Health = hum.MaxHealth
			end
		end)

		local nearestHRP = findNearestHRPInRange(myRoot)
		if not nearestHRP then
			stopAuraEngineOnly()
			return
		end

		if nearestHRP ~= currentLockedTarget then
			currentLockedTarget = nearestHRP
			spinAngle = 0
		end

		local currentSword = getActiveSword()
		if not currentSword then return end
		local currentBlade = getBladePart(currentSword)
		if not currentBlade then return end

		local center = nearestHRP.Position + Vector3.new(0, SWORD_HEIGHT, 0)
		pcall(function()
			currentBlade.AssemblyLinearVelocity = Vector3.zero
			currentBlade.AssemblyAngularVelocity = Vector3.zero
			for stepIdx = 0, 1 do
				spinAngle += dt * SWORD_SPIN_SPEED * 0.5 + (stepIdx * math.pi * 0.25)
				local pos = center + Vector3.new(
					math.cos(spinAngle) * SWORD_RADIUS,
					0,
					math.sin(spinAngle) * SWORD_RADIUS
				)
				currentBlade.CFrame = CFrame.lookAt(pos, center)
			end
		end)
	end)
end

local function startAuraWatcher()
	if watcherConn then watcherConn:Disconnect(); watcherConn = nil end
	watcherConn = RunService.Heartbeat:Connect(function()
		if not auraArmed then
			if auraEngineRunning then stopAuraEngineOnly() end
			return
		end
		local myRoot = root or getHRP(char)
		if not myRoot then
			if auraEngineRunning then stopAuraEngineOnly() end
			return
		end
		local nearestHRP = findNearestHRPInRange(myRoot)
		if nearestHRP then
			if not auraEngineRunning then startAuraEngineForTarget(nearestHRP) end
		else
			if auraEngineRunning then stopAuraEngineOnly() end
		end
	end)
end

local function findNearestVulnerableHRP(myRoot)
	local bestHRP, bestDist = nil, math.huge
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local tChar = plr.Character
			local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
			local tHRP = getHRP(tChar)
			if tHum and tHum.Health > 0 and tHRP and not hasForceField(tChar) then
				local dist = (tHRP.Position - myRoot.Position).Magnitude
				if dist < bestDist then
					bestDist = dist
					bestHRP = tHRP
				end
			end
		end
	end
	return bestHRP
end

local function moveFlyTo(myRoot, desiredPos, lookAtPos, dt)
	local currentPos = myRoot.Position
	local delta = desiredPos - currentPos
	local dist = delta.Magnitude

	pcall(function()
		myRoot.AssemblyLinearVelocity = Vector3.zero
		myRoot.AssemblyAngularVelocity = Vector3.zero
		if dist <= 0.15 then
			myRoot.CFrame = CFrame.lookAt(desiredPos, lookAtPos)
			return
		end
		local step = math.min(dist, FLY_SPEED_AURA * dt)
		myRoot.CFrame = CFrame.lookAt(currentPos + delta.Unit * step, lookAtPos)
	end)
end

local function stopSkyFly()
	skyFlyArmed = false
	hoverAnchorPos = nil
	if skyFlyConn then skyFlyConn:Disconnect(); skyFlyConn = nil end
	if hum and hum.Parent then
		pcall(function() hum.PlatformStand = savedPlatformStand end)
	end
end

local function startSkyFly()
	stopSkyFly()
	skyFlyArmed = true
	if hum and hum.Parent then
		pcall(function()
			savedPlatformStand = hum.PlatformStand
			hum.PlatformStand = true
		end)
	end
	skyFlyConn = RunService.Heartbeat:Connect(function(dt)
		if not skyFlyArmed then return end
		local myRoot = root or getHRP(char)
		if not myRoot or not hum or hum.Health <= 0 then return end

		local targetHRP = findNearestVulnerableHRP(myRoot)
		if targetHRP then
			hoverAnchorPos = nil
			local skyPos = targetHRP.Position + Vector3.new(0, SKY_HEIGHT, 0)
			moveFlyTo(myRoot, skyPos, targetHRP.Position, dt)
		else
			if not hoverAnchorPos then hoverAnchorPos = myRoot.Position end
			moveFlyTo(myRoot, hoverAnchorPos, hoverAnchorPos + myRoot.CFrame.LookVector, dt)
		end
	end)
end

onRespawn[#onRespawn + 1] = function()
	if auraEngineRunning then stopAuraEngineOnly() end
	if skyFlyArmed then
		task.wait(0.25)
		if skyFlyArmed then startSkyFly() end
	end
end

DZ.AddToggle("Aura kiếm + Godmode", {Floating = true}, function(on)
	auraArmed = on
	if on then
		startAuraWatcher()
	else
		if watcherConn then watcherConn:Disconnect(); watcherConn = nil end
		stopAuraEngineOnly()
	end
end)

DZ.AddButton("Lướt tới trước (TP Wall)", function()
	local myRoot = root or getHRP(char)
	if not myRoot or not hum or hum.Health <= 0 then return end
	local flatLook = Vector3.new(myRoot.CFrame.LookVector.X, 0, myRoot.CFrame.LookVector.Z)
	if flatLook.Magnitude < 1e-4 then return end
	local dir = flatLook.Unit
	local targetPos = myRoot.Position + dir * DASH_DISTANCE
	local rot = myRoot.CFrame.Rotation
	pcall(function()
		myRoot.AssemblyLinearVelocity = Vector3.zero
		myRoot.AssemblyAngularVelocity = Vector3.zero
		myRoot.CFrame = CFrame.fromMatrix(targetPos, rot.XVector, rot.YVector, rot.ZVector)
	end)
end)

DZ.AddToggle("Bay trên đầu mục tiêu (Sky Fly)", {Floating = true}, function(on)
	if on then
		startSkyFly()
	else
		stopSkyFly()
	end
end)
