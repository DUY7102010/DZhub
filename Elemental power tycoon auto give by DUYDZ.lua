-- UI Give Item - Elemental Powers Tycoon (DZ Neon Tech UI - Fixed)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

-- (Giữ nguyên phần ITEM_LIST như cũ)
local ITEM_LIST = {
    ["Bone (Xương)"] = {
        {Name="Blaster", Display="Súng xương"}, {Name="Bone Surge", Display="Dâng trào xương"},
        {Name="Bones Barrage", Display="Mưa xương"}, {Name="Flying Bone", Display="Xương bay"},
        {Name="Judgement Blast", Display="Vụ nổ phán xét"}, {Name="Twin Blasters", Display="Súng xương đôi"}
    },
    ["Crystal (Pha lê)"] = {
        {Name="Crystal Cleaver", Display="Rìu pha lê"}, {Name="Crystal Eruption", Display="Pha lê phun trào"},
        {Name="Crystal Mine", Display="Mìn pha lê"}, {Name="Crystal Surge", Display="Dâng trào pha lê"},
        {Name="Energy Crash", Display="Năng lượng va chạm"}, {Name="Energy Crown", Display="Vương miện năng lượng"},
        {Name="Energy Crystal", Display="Pha lê năng lượng"}
    },
    ["Darkness (Bóng tối)"] = {
        {Name="Abyss", Display="Vực thẳm"}, {Name="Dark Arc", Display="Cung bóng tối"},
        {Name="Dark Duo", Display="Cặp đôi bóng tối"}, {Name="Dark Hold", Display="Trói bóng tối"},
        {Name="Shadow Sword", Display="Kiếm bóng"}, {Name="Unseen Barrage", Display="Mưa đòn vô hình"},
        {Name="Unseen Hands", Display="Bàn tay vô hình"}
    },
    ["Devil (Ác quỷ)"] = {
        {Name="Dark Tsunami", Display="Sóng thần bóng tối"}, {Name="Demon Lock", Display="Khóa quỷ"},
        {Name="Demon Orb", Display="Cầu quỷ"}, {Name="Evil Bullet", Display="Đạn tà ác"},
        {Name="Evil Flash", Display="Chớp tà ác"}, {Name="Fangs Barrage", Display="Mưa nanh"}
    },
    ["Fire (Lửa)"] = {
        {Name="Combust", Display="Bốc cháy"}, {Name="Comet", Display="Sao chổi"},
        {Name="Fire Ball", Display="Cầu lửa"}, {Name="Fire Bomb", Display="Bom lửa"},
        {Name="Fire Fly", Display="Ruồi lửa"}, {Name="Fire Shower", Display="Mưa lửa"},
        {Name="Fire Sword", Display="Kiếm lửa"}
    },
    ["Space (Không gian)"] = {
        {Name="Asteroid Belt", Display="Vành đai tiểu hành tinh"}, {Name="Blackhole Orb", Display="Cầu hố đen"},
        {Name="Cosmic Remote", Display="Điều khiển vũ trụ"}, {Name="Meteor Jam", Display="Mưa thiên thạch"},
        {Name="Moon Splitter", Display="Xẻ đôi mặt trăng"}, {Name="Space Gun", Display="Súng không gian"},
        {Name="Space Saucer", Display="Đĩa bay"}
    },
    ["Super Sonic (Siêu thanh)"] = {
        {Name="Rebound Blast", Display="Nổ dội"}, {Name="Rebound Teleport", Display="Dịch chuyển dội"},
        {Name="Sonic Barrage", Display="Mưa âm thanh"}, {Name="Sonic Blaster", Display="Súng âm thanh"},
        {Name="Sonic Boom", Display="Nổ âm thanh"}, {Name="Sonic Twister", Display="Lốc xoáy âm thanh"},
        {Name="Super Sonic Wave", Display="Sóng siêu âm"}
    },
    ["Technology (Công nghệ)"] = {
        {Name="Hyper Slash", Display="Chém siêu tốc"}, {Name="Hyper Sword", Display="Kiếm siêu tốc"},
        {Name="Orbital", Display="Quỹ đạo"}, {Name="Photon Blast", Display="Nổ photon"},
        {Name="Tesla Turret", Display="Trụ súng Tesla"}, {Name="Tesseract", Display="Khối Tesseract"},
        {Name="Twin-Photon Blast", Display="Nổ song photon"}
    },
    ["Thunder (Sấm sét)"] = {
        {Name="Bolt", Display="Tia sét"}, {Name="Discharge", Display="Phóng điện"},
        {Name="Energy Beam", Display="Tia năng lượng"}, {Name="Flying Nimbus", Display="Mây bay"},
        {Name="Lightning Strike", Display="Sét đánh"}, {Name="Storm", Display="Bão tố"},
        {Name="Thunder Staff", Display="Trượng sấm sét"}
    },
    ["Time (Thời gian)"] = {
        {Name="Grand Clock", Display="Đồng hồ lớn"}, {Name="Tempo Beam", Display="Tia tiết tấu"},
        {Name="Temporal Gate", Display="Cổng thời gian"}, {Name="Time Trap", Display="Bẫy thời gian"},
        {Name="Warp Barrage", Display="Mưa biến dạng"}, {Name="Warp Bomb", Display="Bom biến dạng"}
    },
    ["Turret (Trụ súng)"] = {
        {Name="Energy Ball", Display="Cầu năng lượng"}, {Name="Guide Turret", Display="Trụ súng dẫn đường"},
        {Name="Security Guns", Display="Súng an ninh"}
    },
    ["Venom (Nọc độc)"] = {
        {Name="Acid Rain", Display="Mưa axit"}, {Name="Bubbling Venom", Display="Nọc độc sủi bọt"},
        {Name="Hardened Venom", Display="Nọc độc cứng"}, {Name="Poison Bullet", Display="Đạn độc"},
        {Name="Poison Demon", Display="Quỷ độc"}, {Name="Venom Stream", Display="Suối nọc độc"}
    },
    ["Water (Nước)"] = {
        {Name="Aqua Trident", Display="Đinh ba nước"}, {Name="Big Tsunami", Display="Sóng thần lớn"},
        {Name="Bubbles", Display="Bong bóng"}, {Name="Jellyfish", Display="Sứa"},
        {Name="Water Beam", Display="Tia nước"}, {Name="Whirlpool", Display="Xoáy nước"}
    },
    ["Rebirth (Tái sinh)"] = {
        {Name="Bubble Flail", Display="Chùy bong bóng"}, {Name="Crystalline Mirror", Display="Gương pha lê"},
        {Name="Dark Flames", Display="Lửa bóng tối"}, {Name="Draedon's Tech", Display="Công nghệ Draedon"},
        {Name="Elysian Beam", Display="Tia Elysian"}, {Name="Frost Step", Display="Bước băng"},
        {Name="Laser Beam", Display="Tia laser"}, {Name="Missile Volly", Display="Mưa tên lửa"},
        {Name="Nuclear Strike", Display="Tấn công hạt nhân"}
    },
    ["Special (Đặc biệt)"] = {
        {Name="Plasma Orbs", Display="Cầu plasma"}, {Name="Poison Serpent", Display="Rắn độc"},
        {Name="Rainbow Bomb", Display="Bom cầu vồng"}, {Name="Red Saucer", Display="Đĩa bay đỏ"},
        {Name="Sonar", Display="Sóng âm"}, {Name="The Void", Display="Hư không"},
        {Name="Undead Staff", Display="Trượng xác sống"}, {Name="Yoru", Display="Yoru"}
    },
    ["Lava (Dung nham)"] = {
        {Name="Lava Katana", Display="Kiếm Lava"}, {Name="Lava Ball", Display="Cầu Lava"},
        {Name="Magam Fists", Display="Nắm đấm Magma"}, {Name="Lava Dash", Display="Lướt Lava"},
        {Name="Volcano Sentry", Display="Lính canh núi lửa"}, {Name="Magma Spikes", Display="Gai Magma"},
        {Name="Nibiru", Display="Nibiru"}
    },
    ["Earth (Đất)"] = {
        {Name="Tectonic Hamer", Display="Búa địa chấn"}, {Name="Stone Throw", Display="Ném đá"},
        {Name="Rocks Barrage", Display="Mưa đá"}, {Name="Large Boulder", Display="Tảng đá lớn"},
        {Name="Burrow", Display="Đào hang"}, {Name="Stone Henge", Display="Đá tảng"},
        {Name="Earth Spikes", Display="Gai đất"}
    },
    ["Gravity (Trọng lực)"] = {
        {Name="Gravity Orb", Display="Cầu trọng lực"}, {Name="Tectonic Burst", Display="Bùng nổ địa chấn"},
        {Name="Zero Gravity", Display="Không trọng lực"}, {Name="Gravity Globe", Display="Quả địa cầu trọng lực"},
        {Name="Hyper Sword", Display="Kiếm siêu tốc"}, {Name="Hyper Speed", Display="Tốc độ siêu cấp"}
    },
    ["Ice (Băng)"] = {
        {Name="Frost Staff", Display="Trượng băng giá"}, {Name="Frost Fire Ball", Display="Cầu lửa băng giá"},
        {Name="Ice Disk", Display="Đĩa băng"}, {Name="Snow Ball", Display="Cầu tuyết"},
        {Name="Ultracold Aura", Display="Hào quang siêu lạnh"}, {Name="Ice Spikes", Display="Gai băng"}
    },
    ["Light (Ánh sáng)"] = {
        {Name="Light Saber", Display="Gươm ánh sáng"}, {Name="Light Ball", Display="Cầu ánh sáng"},
        {Name="Light Orbs", Display="Quả cầu ánh sáng"}, {Name="Blinding Light", Display="Ánh sáng chói lóa"},
        {Name="Shooting Star", Display="Sao băng"}, {Name="Light Speed", Display="Tốc độ ánh sáng"},
        {Name="Light Beam", Display="Tia sáng"}
    },
    ["Nature (Thiên nhiên)"] = {
        {Name="Christmas Tree Sword", Display="Kiếm cây thông"}, {Name="Plantoid", Display="Hình nhân cây"},
        {Name="Spore Bombs", Display="Bom bào tử"}, {Name="Nature's Blessing", Display="Ban phước của thiên nhiên"},
        {Name="Nuclear Spore", Display="Bào tử hạt nhân"}, {Name="Pine Burst", Display="Nổ thông"},
        {Name="Nature's Wrath", Display="Cơn thịnh nộ của thiên nhiên"}
    }
}

local function equipItem(realItemName)
    if game.PlaceId == 10253248401 then
        local remote = RS:FindFirstChild("RemoteEvent")
        if remote then 
            for i = 1, 3 do
                remote:FireServer("equip_mystery_spell", realItemName)
                task.wait(0.1)
            end
        end
    end
end

-- ===== HÀM KÉO THẢ TỐI ƯU =====
local function makeDraggable(frame, dragArea)
    local dragging, dragInput, dragStart, startPos
    local activeTouch = nil

    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            if input.UserInputType == Enum.UserInputType.Touch then activeTouch = input end
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if input == activeTouch then activeTouch = nil end
                end
            end)
        end
    end)
    
    dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if input == activeTouch or input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ===== GIAO DIỆN NEON TECH =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DZ_NeonGiveUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999 -- Luôn nổi lên trên
ScreenGui.Parent = LP:WaitForChild("PlayerGui")

-- Nút Toggle Nhỏ (Luôn hiển thị)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 40, 0, 40)
ToggleBtn.Position = UDim2.new(0, 20, 0.3, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
ToggleBtn.Text = "DZ"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
ToggleStroke.Color = Color3.fromRGB(0, 255, 255)
ToggleStroke.Thickness = 2
makeDraggable(ToggleBtn, ToggleBtn)

-- Bảng Chính
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 320)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 255, 255)
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.2

-- Thanh Tiêu Đề (Có viền phát sáng)
local TitleBarFrame = Instance.new("Frame")
TitleBarFrame.Size = UDim2.new(1, 0, 0, 35)
TitleBarFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TitleBarFrame.BorderSizePixel = 0
TitleBarFrame.Parent = MainFrame
Instance.new("UICorner", TitleBarFrame).CornerRadius = UDim.new(0, 8)
local TitleStroke = Instance.new("UIStroke", TitleBarFrame)
TitleStroke.Color = Color3.fromRGB(0, 255, 255)
TitleStroke.Thickness = 1.2
TitleStroke.Transparency = 0.5

makeDraggable(MainFrame, TitleBarFrame)

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -40, 1, 0)
TitleText.Position = UDim2.new(0, 12, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "DZ | NEON GIVE"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 13
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBarFrame

-- Nút Ẩn
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 24, 0, 24)
MinBtn.Position = UDim2.new(1, -30, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 16
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TitleBarFrame
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 4)

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)
ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Tab Bar (Cột Trái)
local TabBar = Instance.new("ScrollingFrame")
TabBar.Size = UDim2.new(0, 85, 1, -45)
TabBar.Position = UDim2.new(0, 8, 0, 40)
TabBar.BackgroundTransparency = 1
TabBar.ScrollBarThickness = 1
TabBar.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 255)
TabBar.AutomaticCanvasSize = Enum.AutomaticSize.Y
TabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
TabBar.Parent = MainFrame
local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 4)

-- Item Area (Cột Phải)
local ItemArea = Instance.new("ScrollingFrame")
ItemArea.Size = UDim2.new(1, -103, 1, -45)
ItemArea.Position = UDim2.new(0, 95, 0, 40)
ItemArea.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
ItemArea.BorderSizePixel = 0
ItemArea.ScrollBarThickness = 2
ItemArea.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 255)
ItemArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
ItemArea.CanvasSize = UDim2.new(0, 0, 0, 0)
ItemArea.Parent = MainFrame
Instance.new("UICorner", ItemArea).CornerRadius = UDim.new(0, 6)
local ItemLayout = Instance.new("UIListLayout", ItemArea)
ItemLayout.SortOrder = Enum.SortOrder.LayoutOrder
ItemLayout.Padding = UDim.new(0, 3)
ItemLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function createTab(tabName, items)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, -4, 0, 26)
    TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    TabBtn.Text = tabName
    TabBtn.TextColor3 = Color3.fromRGB(150, 150, 170)
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.TextSize = 10
    TabBtn.BorderSizePixel = 0
    TabBtn.Parent = TabBar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 4)
    local Stroke = Instance.new("UIStroke", TabBtn)
    Stroke.Color = Color3.fromRGB(50, 50, 70)
    Stroke.Thickness = 1
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, v in pairs(TabBar:GetChildren()) do
            if v:IsA("TextButton") then
                v.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
                v.TextColor3 = Color3.fromRGB(150, 150, 170)
                if v:FindFirstChildOfClass("UIStroke") then
                    v:FindFirstChildOfClass("UIStroke").Color = Color3.fromRGB(50, 50, 70)
                end
            end
        end
        TabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        TabBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
        Stroke.Color = Color3.fromRGB(0, 255, 255)
        Stroke.Thickness = 1.5
        
        for _, v in pairs(ItemArea:GetChildren()) do
            if v:IsA("TextButton") or v:IsA("TextLabel") then v:Destroy() end
        end
        ItemArea.CanvasPosition = Vector2.new(0, 0)
        
        for i, itemData in ipairs(items) do
            local ItemBtn = Instance.new("TextButton")
            ItemBtn.Size = UDim2.new(1, -8, 0, 26)
            ItemBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            ItemBtn.Text = itemData.Display
            ItemBtn.TextColor3 = Color3.fromRGB(220, 220, 240)
            ItemBtn.Font = Enum.Font.Gotham
            ItemBtn.TextSize = 10
            ItemBtn.BorderSizePixel = 0
            ItemBtn.Parent = ItemArea
            Instance.new("UICorner", ItemBtn).CornerRadius = UDim.new(0, 4)
            local ItemStroke = Instance.new("UIStroke", ItemBtn)
            ItemStroke.Color = Color3.fromRGB(60, 60, 80)
            ItemStroke.Thickness = 1
            
            ItemBtn.MouseEnter:Connect(function() 
                ItemBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55) 
                ItemStroke.Color = Color3.fromRGB(255, 0, 255)
            end)
            ItemBtn.MouseLeave:Connect(function() 
                ItemBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40) 
                ItemStroke.Color = Color3.fromRGB(60, 60, 80)
            end)
            
            ItemBtn.MouseButton1Click:Connect(function()
                equipItem(itemData.Name)
                task.spawn(function()
                    ItemBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
                    ItemBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
                    ItemStroke.Color = Color3.fromRGB(0, 255, 255)
                    task.wait(0.15)
                    ItemBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
                    ItemBtn.TextColor3 = Color3.fromRGB(220, 220, 240)
                    ItemStroke.Color = Color3.fromRGB(255, 0, 255)
                end)
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
