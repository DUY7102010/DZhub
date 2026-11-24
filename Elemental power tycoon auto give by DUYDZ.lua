-- UI Give Item - Elemental Powers Tycoon (DZ Final Ultimate Version)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

-- Cấu trúc: Name (Tên gửi Remote), Display (Tên hiển thị Tiếng Việt)
local ITEM_LIST = {
    ["Bone (Xương)"] = {
        {Name="Blaster", Display="Súng xương"},
        {Name="Bone Surge", Display="Dâng trào xương"},
        {Name="Bones Barrage", Display="Mưa xương"},
        {Name="Flying Bone", Display="Xương bay"},
        {Name="Judgement Blast", Display="Vụ nổ phán xét"},
        {Name="Twin Blasters", Display="Súng xương đôi"}
    },
    ["Crystal (Pha lê)"] = {
        {Name="Crystal Cleaver", Display="Rìu pha lê"},
        {Name="Crystal Eruption", Display="Pha lê phun trào"},
        {Name="Crystal Mine", Display="Mìn pha lê"},
        {Name="Crystal Surge", Display="Dâng trào pha lê"},
        {Name="Energy Crash", Display="Năng lượng va chạm"},
        {Name="Energy Crown", Display="Vương miện năng lượng"},
        {Name="Energy Crystal", Display="Pha lê năng lượng"}
    },
    ["Darkness (Bóng tối)"] = {
        {Name="Abyss", Display="Vực thẳm"},
        {Name="Dark Arc", Display="Cung bóng tối"},
        {Name="Dark Duo", Display="Cặp đôi bóng tối"},
        {Name="Dark Hold", Display="Trói bóng tối"},
        {Name="Shadow Sword", Display="Kiếm bóng"},
        {Name="Unseen Barrage", Display="Mưa đòn vô hình"},
        {Name="Unseen Hands", Display="Bàn tay vô hình"}
    },
    ["Devil (Ác quỷ)"] = {
        {Name="Dark Tsunami", Display="Sóng thần bóng tối"},
        {Name="Demon Lock", Display="Khóa quỷ"},
        {Name="Demon Orb", Display="Cầu quỷ"},
        {Name="Evil Bullet", Display="Đạn tà ác"},
        {Name="Evil Flash", Display="Chớp tà ác"},
        {Name="Fangs Barrage", Display="Mưa nanh"}
    },
    ["Fire (Lửa)"] = {
        {Name="Combust", Display="Bốc cháy"},
        {Name="Comet", Display="Sao chổi"},
        {Name="Fire Ball", Display="Cầu lửa"},
        {Name="Fire Bomb", Display="Bom lửa"},
        {Name="Fire Fly", Display="Ruồi lửa"},
        {Name="Fire Shower", Display="Mưa lửa"},
        {Name="Fire Sword", Display="Kiếm lửa"}
    },
    ["Space (Không gian)"] = {
        {Name="Asteroid Belt", Display="Vành đai tiểu hành tinh"},
        {Name="Blackhole Orb", Display="Cầu hố đen"},
        {Name="Cosmic Remote", Display="Điều khiển vũ trụ"},
        {Name="Meteor Jam", Display="Mưa thiên thạch"},
        {Name="Moon Splitter", Display="Xẻ đôi mặt trăng"},
        {Name="Space Gun", Display="Súng không gian"},
        {Name="Space Saucer", Display="Đĩa bay"}
    },
    ["Super Sonic (Siêu thanh)"] = {
        {Name="Rebound Blast", Display="Nổ dội"},
        {Name="Rebound Teleport", Display="Dịch chuyển dội"},
        {Name="Sonic Barrage", Display="Mưa âm thanh"},
        {Name="Sonic Blaster", Display="Súng âm thanh"},
        {Name="Sonic Boom", Display="Nổ âm thanh"},
        {Name="Sonic Twister", Display="Lốc xoáy âm thanh"},
        {Name="Super Sonic Wave", Display="Sóng siêu âm"}
    },
    ["Technology (Công nghệ)"] = {
        {Name="Hyper Slash", Display="Chém siêu tốc"},
        {Name="Hyper Sword", Display="Kiếm siêu tốc"},
        {Name="Orbital", Display="Quỹ đạo"},
        {Name="Photon Blast", Display="Nổ photon"},
        {Name="Tesla Turret", Display="Trụ súng Tesla"},
        {Name="Tesseract", Display="Khối Tesseract"},
        {Name="Twin-Photon Blast", Display="Nổ song photon"}
    },
    ["Thunder (Sấm sét)"] = {
        {Name="Bolt", Display="Tia sét"},
        {Name="Discharge", Display="Phóng điện"},
        {Name="Energy Beam", Display="Tia năng lượng"},
        {Name="Flying Nimbus", Display="Mây bay"},
        {Name="Lightning Strike", Display="Sét đánh"},
        {Name="Storm", Display="Bão tố"},
        {Name="Thunder Staff", Display="Trượng sấm sét"}
    },
    ["Time (Thời gian)"] = {
        {Name="Grand Clock", Display="Đồng hồ lớn"},
        {Name="Tempo Beam", Display="Tia tiết tấu"},
        {Name="Temporal Gate", Display="Cổng thời gian"},
        {Name="Time Trap", Display="Bẫy thời gian"},
        {Name="Warp Barrage", Display="Mưa biến dạng"},
        {Name="Warp Bomb", Display="Bom biến dạng"}
    },
    ["Turret (Trụ súng)"] = {
        {Name="Energy Ball", Display="Cầu năng lượng"},
        {Name="Guide Turret", Display="Trụ súng dẫn đường"},
        {Name="Security Guns", Display="Súng an ninh"}
    },
    ["Venom (Nọc độc)"] = {
        {Name="Acid Rain", Display="Mưa axit"},
        {Name="Bubbling Venom", Display="Nọc độc sủi bọt"},
        {Name="Hardened Venom", Display="Nọc độc cứng"},
        {Name="Poison Bullet", Display="Đạn độc"},
        {Name="Poison Demon", Display="Quỷ độc"},
        {Name="Venom Stream", Display="Suối nọc độc"}
    },
    ["Water (Nước)"] = {
        {Name="Aqua Trident", Display="Đinh ba nước"},
        {Name="Big Tsunami", Display="Sóng thần lớn"},
        {Name="Bubbles", Display="Bong bóng"},
        {Name="Jellyfish", Display="Sứa"},
        {Name="Water Beam", Display="Tia nước"},
        {Name="Whirlpool", Display="Xoáy nước"}
    },
    ["Rebirth (Tái sinh)"] = {
        {Name="Bubble Flail", Display="Chùy bong bóng"},
        {Name="Crystalline Mirror", Display="Gương pha lê"},
        {Name="Dark Flames", Display="Lửa bóng tối"},
        {Name="Draedon's Tech", Display="Công nghệ Draedon"},
        {Name="Elysian Beam", Display="Tia Elysian"},
        {Name="Frost Step", Display="Bước băng"},
        {Name="Laser Beam", Display="Tia laser"},
        {Name="Missile Volly", Display="Mưa tên lửa"},
        {Name="Nuclear Strike", Display="Tấn công hạt nhân"}
    },
    ["Special (Đặc biệt)"] = {
        {Name="Plasma Orbs", Display="Cầu plasma"},
        {Name="Poison Serpent", Display="Rắn độc"},
        {Name="Rainbow Bomb", Display="Bom cầu vồng"},
        {Name="Red Saucer", Display="Đĩa bay đỏ"},
        {Name="Sonar", Display="Sóng âm"},
        {Name="The Void", Display="Hư không"},
        {Name="Undead Staff", Display="Trượng xác sống"},
        {Name="Yoru", Display="Yoru"}
    },
    ["Lava (Dung nham)"] = {
        {Name="Lava Katana", Display="Kiếm Lava"},
        {Name="Lava Ball", Display="Cầu Lava"},
        {Name="Magam Fists", Display="Nắm đấm Magma"},
        {Name="Lava Dash", Display="Lướt Lava"},
        {Name="Volcano Sentry", Display="Lính canh núi lửa"},
        {Name="Magma Spikes", Display="Gai Magma"},
        {Name="Nibiru", Display="Nibiru"}
    },
    ["Earth (Đất)"] = {
        {Name="Tectonic Hamer", Display="Búa địa chấn"},
        {Name="Stone Throw", Display="Ném đá"},
        {Name="Rocks Barrage", Display="Mưa đá"},
        {Name="Large Boulder", Display="Tảng đá lớn"},
        {Name="Burrow", Display="Đào hang"},
        {Name="Stone Henge", Display="Đá tảng"},
        {Name="Earth Spikes", Display="Gai đất"}
    },
    ["Gravity (Trọng lực)"] = {
        {Name="Gravity Orb", Display="Cầu trọng lực"},
        {Name="Tectonic Burst", Display="Bùng nổ địa chấn"},
        {Name="Zero Gravity", Display="Không trọng lực"},
        {Name="Gravity Globe", Display="Quả địa cầu trọng lực"},
        {Name="Hyper Sword", Display="Kiếm siêu tốc"},
        {Name="Hyper Speed", Display="Tốc độ siêu cấp"}
    },
    ["Ice (Băng)"] = {
        {Name="Frost Staff", Display="Trượng băng giá"},
        {Name="Frost Fire Ball", Display="Cầu lửa băng giá"},
        {Name="Ice Disk", Display="Đĩa băng"},
        {Name="Snow Ball", Display="Cầu tuyết"},
        {Name="Ultracold Aura", Display="Hào quang siêu lạnh"},
        {Name="Ice Spikes", Display="Gai băng"}
    },
    ["Light (Ánh sáng)"] = {
        {Name="Light Saber", Display="Gươm ánh sáng"},
        {Name="Light Ball", Display="Cầu ánh sáng"},
        {Name="Light Orbs", Display="Quả cầu ánh sáng"},
        {Name="Blinding Light", Display="Ánh sáng chói lóa"},
        {Name="Shooting Star", Display="Sao băng"},
        {Name="Light Speed", Display="Tốc độ ánh sáng"},
        {Name="Light Beam", Display="Tia sáng"}
    },
    ["Nature (Thiên nhiên)"] = {
        {Name="Christmas Tree Sword", Display="Kiếm cây thông"},
        {Name="Plantoid", Display="Hình nhân cây"},
        {Name="Spore Bombs", Display="Bom bào tử"},
        {Name="Nature's Blessing", Display="Ban phước của thiên nhiên"},
        {Name="Nuclear Spore", Display="Bào tử hạt nhân"},
        {Name="Pine Burst", Display="Nổ thông"},
        {Name="Nature's Wrath", Display="Cơn thịnh nộ của thiên nhiên"}
    }
}

local function equipItem(realItemName)
    if game.PlaceId == 10253248401 then
        local remote = RS:FindFirstChild("RemoteEvent")
        if remote then 
            -- Spam 3 lần để chắc chắn server nhận lệnh
            for i = 1, 3 do
                remote:FireServer("equip_mystery_spell", realItemName)
                task.wait(0.1)
            end
        end
    end
end

-- ===== GIAO DIỆN (UI) =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DZ_GiveUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LP:WaitForChild("PlayerGui")

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 36, 0, 36)
ToggleBtn.Position = UDim2.new(0, 10, 0.2, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 38, 50)
ToggleBtn.Text = "DZ"
ToggleBtn.TextColor3 = Color3.fromRGB(150, 160, 190)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 12
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Visible = false
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 270)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -135)
MainFrame.BackgroundColor3 = Color3.fromRGB(22, 24, 32)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(60, 65, 85)
MainStroke.Thickness = 1.5

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 33, 45)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -70, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "DZ ULTIMATE MENU"
TitleText.TextColor3 = Color3.fromRGB(200, 210, 255)
TitleText.TextSize = 12
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 20, 0, 20)
MinBtn.Position = UDim2.new(1, -50, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(45, 50, 65)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 4)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(1, -25, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 10
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    ToggleBtn.Visible = true
end)
ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    ToggleBtn.Visible = false
end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local dragging, dragInput, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local TabBar = Instance.new("ScrollingFrame")
TabBar.Size = UDim2.new(0, 75, 1, -36)
TabBar.Position = UDim2.new(0, 6, 0, 34)
TabBar.BackgroundTransparency = 1
TabBar.ScrollBarThickness = 1
TabBar.ScrollBarImageColor3 = Color3.fromRGB(80, 90, 120)
TabBar.AutomaticCanvasSize = Enum.AutomaticSize.Y
TabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
TabBar.Parent = MainFrame
local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 3)

local ItemArea = Instance.new("ScrollingFrame")
ItemArea.Size = UDim2.new(1, -87, 1, -36)
ItemArea.Position = UDim2.new(0, 83, 0, 34)
ItemArea.BackgroundColor3 = Color3.fromRGB(26, 28, 38)
ItemArea.BorderSizePixel = 0
ItemArea.ScrollBarThickness = 2
ItemArea.ScrollBarImageColor3 = Color3.fromRGB(80, 90, 120)
ItemArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
ItemArea.CanvasSize = UDim2.new(0, 0, 0, 0)
ItemArea.Parent = MainFrame
Instance.new("UICorner", ItemArea).CornerRadius = UDim.new(0, 6)
local ItemLayout = Instance.new("UIListLayout", ItemArea)
ItemLayout.SortOrder = Enum.SortOrder.LayoutOrder
ItemLayout.Padding = UDim.new(0, 2)
ItemLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function createTab(tabName, items)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, -2, 0, 24)
    TabBtn.BackgroundColor3 = Color3.fromRGB(35, 38, 50)
    TabBtn.Text = tabName
    TabBtn.TextColor3 = Color3.fromRGB(160, 170, 190)
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.TextSize = 10
    TabBtn.BorderSizePixel = 0
    TabBtn.Parent = TabBar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 4)
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(TabBar:GetChildren()) do
            if v:IsA("TextButton") then
                v.BackgroundColor3 = Color3.fromRGB(35, 38, 50)
                v.TextColor3 = Color3.fromRGB(160, 170, 190)
            end
        end
        TabBtn.BackgroundColor3 = Color3.fromRGB(60, 70, 120)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        for _, v in pairs(ItemArea:GetChildren()) do
            if v:IsA("TextButton") or v:IsA("TextLabel") then v:Destroy() end
        end
        
        ItemArea.CanvasPosition = Vector2.new(0, 0)
        
        for i, itemData in ipairs(items) do
            local ItemBtn = Instance.new("TextButton")
            ItemBtn.Size = UDim2.new(1, -6, 0, 24)
            ItemBtn.BackgroundColor3 = Color3.fromRGB(40, 44, 58)
            ItemBtn.Text = itemData.Display -- Hiển thị tiếng Việt
            ItemBtn.TextColor3 = Color3.fromRGB(210, 220, 240)
            ItemBtn.Font = Enum.Font.Gotham
            ItemBtn.TextSize = 10
            ItemBtn.BorderSizePixel = 0
            ItemBtn.Parent = ItemArea
            Instance.new("UICorner", ItemBtn).CornerRadius = UDim.new(0, 4)
            
            ItemBtn.MouseEnter:Connect(function() ItemBtn.BackgroundColor3 = Color3.fromRGB(55, 60, 85) end)
            ItemBtn.MouseLeave:Connect(function() ItemBtn.BackgroundColor3 = Color3.fromRGB(40, 44, 58) end)
            
            ItemBtn.MouseButton1Click:Connect(function()
                equipItem(itemData.Name) -- Gửi tên tiếng Anh lên Remote
                ItemBtn.BackgroundColor3 = Color3.fromRGB(80, 100, 160)
                task.wait(0.15)
                ItemBtn.BackgroundColor3 = Color3.fromRGB(55, 60, 85)
            end)
        end
    end)
end

local sortedKeys = {}
for k in pairs(ITEM_LIST) do table.insert(sortedKeys, k) end
table.sort(sortedKeys)

for _, category in ipairs(sortedKeys) do
    createTab(category, ITEM_LIST[category])
end
