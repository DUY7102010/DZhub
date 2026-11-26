local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer

-- ==========================================
-- 1. GIỮ NGUYÊN LOGIC GIVE ITEM CỦA MÀY
-- ==========================================
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

-- ==========================================
-- 2. BIẾN TOÀN CỤC & TRẠNG THÁI
-- ==========================================
local States = {
    ESP = false,
    ESP_Health = true,
    ESP_Distance = true,
    ESP_Name = true,
    Farm = false,
    Noclip = false,
    Fly = false,
    Speed = 16,
    Jump = 50,
    FlySpeed = 5
}

local ESP_Objects = {}
local FlyConnection = nil
local BV = nil

-- ==========================================
-- 3. HIỆU ỨNG & TIỆN ÍCH UI
-- ==========================================
local function CreateRipple(parent, x, y)
    local ripple = Instance.new("Frame")
    ripple.Parent = parent
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.6
    ripple.Position = UDim2.new(0, x, 0, y)
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.BorderSizePixel = 0
    local corner = Instance.new("UICorner", ripple)
    corner.CornerRadius = UDim.new(1, 0)
    
    local tween = TweenService:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 100, 0, 100),
        BackgroundTransparency = 1
    })
    tween:Play()
    tween.Completed:Connect(function() ripple:Destroy() end)
end

local function CreateButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.Text = " " .. text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.Parent = parent
    
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(60, 60, 60)
    stroke.Thickness = 1
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255,255,255), TextColor3 = Color3.fromRGB(0,0,0)}):Play()
        stroke.Color = Color3.fromRGB(255,255,255)
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20,20,20), TextColor3 = Color3.fromRGB(200,200,200)}):Play()
        stroke.Color = Color3.fromRGB(60,60,60)
    end)
    
    btn.MouseButton1Click:Connect(function()
        CreateRipple(btn, btn.AbsoluteSize.X/2, btn.AbsoluteSize.Y/2)
        callback()
    end)
    return btn
end

local function CreateSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 15)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. default
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 4)
    bar.Position = UDim2.new(0, 0, 0, 25)
    bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    bar.BorderSizePixel = 0
    bar.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    fill.BorderSizePixel = 0
    fill.Parent = bar
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 8, 0, 8)
    circle.Position = UDim2.new(1, -4, 0.5, -4)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.BorderSizePixel = 0
    circle.Parent = fill
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1,0)
    
    local dragging = false
    local function update(input)
        local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        local val = math.floor(min + (max - min) * pos)
        label.Text = text .. ": " .. val
        callback(val)
    end
    
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end
-- ==========================================
-- 4. LOGIC ESP (HIGHLIGHT + BILLBOARD)
-- ==========================================
local function UpdateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not ESP_Objects[player] then
                local char = player.Character
                local highlight = Instance.new("Highlight")
                highlight.Adornee = char
                highlight.FillTransparency = 1
                highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineTransparency = 0
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = char
                
                local billboard = Instance.new("BillboardGui")
                billboard.Adornee = char.Head or char.HumanoidRootPart
                billboard.Size = UDim2.new(0, 150, 0, 60)
                billboard.StudsOffset = Vector3.new(0, 2.5, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = char
                
                local info = Instance.new("TextLabel")
                info.Size = UDim2.new(1, 0, 1, 0)
                info.BackgroundTransparency = 1
                info.TextColor3 = Color3.fromRGB(255, 255, 255)
                info.Font = Enum.Font.GothamBold
                info.TextSize = 10
                info.TextStrokeTransparency = 0
                info.Text = ""
                info.Parent = billboard
                
                ESP_Objects[player] = {Highlight = highlight, Billboard = billboard, Text = info}
            end
            
            local data = ESP_Objects[player]
            local char = player.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            
            if hum and hrp then
                local dist = math.floor((LP.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                local text = ""
                if States.ESP_Name then text = text .. player.Name .. "\n" end
                if States.ESP_Health then text = text .. "HP: " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth) .. "\n" end
                if States.ESP_Distance then text = text .. "[" .. dist .. "m]" end
                data.Text.Text = text
                
                data.Highlight.Enabled = States.ESP
                data.Billboard.Enabled = States.ESP
            end
        end
    end
end

RunService.RenderStepped:Connect(UpdateESP)

Players.PlayerRemoving:Connect(function(plr)
    if ESP_Objects[plr] then
        if ESP_Objects[plr].Highlight then ESP_Objects[plr].Highlight:Destroy() end
        if ESP_Objects[plr].Billboard then ESP_Objects[plr].Billboard:Destroy() end
        ESP_Objects[plr] = nil
    end
end)

-- ==========================================
-- 5. LOGIC AUTO FARM
-- ==========================================
local function GetClosestPlayer()
    local closest = nil
    local minDist = math.huge
    local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    
    if not myHRP then return nil end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hasFF = player.Character:FindFirstChildOfClass("ForceField") ~= nil
            if not hasFF then
                local hrp = player.Character.HumanoidRootPart
                local dist = (myHRP.Position - hrp.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    closest = player
                end
            end
        end
    end
    return closest
end

task.spawn(function()
    while task.wait(0.1) do
        if States.Farm and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            local target = GetClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local myHRP = LP.Character.HumanoidRootPart
                local targetHRP = target.Character.HumanoidRootPart
                
                local dir = (targetHRP.Position - myHRP.Position).Unit
                myHRP.CFrame = CFrame.new(targetHRP.Position - dir * 3, targetHRP.Position)
                
                local backpack = LP:FindFirstChild("Backpack")
                local char = LP.Character
                
                local function useTools(container)
                    for _, tool in ipairs(container:GetChildren()) do
                        if tool:IsA("Tool") then
                            if tool.Parent == backpack then
                                tool.Parent = char
                            end
                            if tool:FindFirstChild("Handle") then
                                pcall(function()
                                    tool:Activate()
                                    local mouse = LP:GetMouse()
                                    if mouse then
                                        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then 
                                            local vim = game:GetService("VirtualInputManager")
                                            vim:SendMouseButtonEvent(mouse.X, mouse.Y, 0, true, game, 1)
                                            vim:SendMouseButtonEvent(mouse.X, mouse.Y, 0, false, game, 1)
                                        end
                                    end
                                end)
                            end
                        end
                    end
                end
                
                useTools(backpack)
                useTools(char)
            end
        end
    end
end)

-- ==========================================
-- 6. LOGIC MOVEMENT (SPEED, JUMP, NOCLIP, FLY)
-- ==========================================
local function ApplyMovement()
    if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        hum.WalkSpeed = States.Speed
        hum.JumpPower = States.Jump
        hum.UseJumpPower = true
    end
end

LP.CharacterAdded:Connect(function(char)
    task.wait(1)
    ApplyMovement()
end)

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if MainFrame then MainFrame.Visible = not MainFrame.Visible end
    end
end)

RunService.Stepped:Connect(function()
    if States.Noclip and LP.Character then
        for _, v in pairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then
                v.CanCollide = false
            end
        end
    end
end)

local function ToggleFly()
    if States.Fly then
        local char = LP.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            
            BV = Instance.new("BodyVelocity")
            BV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            BV.Velocity = Vector3.zero
            BV.Parent = hrp
            
            local BG = Instance.new("BodyGyro")
            BG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
            BG.P = 1000
            BG.D = 50
            BG.Parent = hrp
            
            FlyConnection = RunService.RenderStepped:Connect(function()
                if not States.Fly then return end
                local cam = Workspace.CurrentCamera
                local moveDir = Vector3.zero
                
                if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0,1,0) end
                
                if moveDir.Magnitude > 0 then
                    BV.Velocity = moveDir.Unit * (States.FlySpeed * 10)
                else
                    BV.Velocity = Vector3.zero
                end
                BG.CFrame = cam.CFrame
            end)
        end
    else
        if BV then BV:Destroy() BV = nil end
        if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end
    end
end

-- ==========================================
-- 7. KHUNG UI CHÍNH & TABS
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DZ_PRO_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = LP:WaitForChild("PlayerGui")

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 20, 0.5, -25)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ToggleBtn.Text = "DZ"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBlack
ToggleBtn.TextSize = 16
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
ToggleStroke.Color = Color3.fromRGB(255, 255, 255)
ToggleStroke.Thickness = 2

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(255, 255, 255)
MainStroke.Thickness = 1
MainStroke.Transparency = 0.5

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -80, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "DZ | PROFESSIONAL HUB"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 14
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local dragging, dragInput, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(0, 120, 1, -50)
TabBar.Position = UDim2.new(0, 10, 0, 45)
TabBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 8)

local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 5)

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -140, 1, -50)
ContentArea.Position = UDim2.new(0, 130, 0, 45)
ContentArea.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ContentArea.BorderSizePixel = 0
ContentArea.Parent = MainFrame
Instance.new("UICorner", ContentArea).CornerRadius = UDim.new(0, 8)

local Pages = {}
local ActivePage = nil

local function CreateTab(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.LayoutOrder = order
    btn.Parent = TabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -20, 1, -20)
    page.Position = UDim2.new(0, 10, 0, 10)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.Parent = ContentArea
    
    local layout = Instance.new("UIListLayout", page)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    
    Pages[name] = page
    
    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        page.Visible = true
        ActivePage = name
        
        for _, b in pairs(TabBar:GetChildren()) do
            if b:IsA("TextButton") then
                b.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                b.TextColor3 = Color3.fromRGB(150, 150, 150)
            end
        end
        btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextColor3 = Color3.fromRGB(0, 0, 0)
    end)
    
    if not ActivePage then
        ActivePage = name
        page.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextColor3 = Color3.fromRGB(0, 0, 0)
    end
end

CreateTab("Movement", 1)
CreateTab("ESP & Visuals", 2)
CreateTab("Auto Farm", 3)
CreateTab("Give Item", 4)

-- ==========================================
-- 8. POPULATE TABS (MOVEMENT & ESP)
-- ==========================================
local movePage = Pages["Movement"]

local function CreateToggle(parent, text, stateKey, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.Text = " " .. text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.Parent = parent
    
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(60, 60, 60)
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 10, 0, 10)
    indicator.Position = UDim2.new(1, -20, 0.5, -5)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    indicator.BorderSizePixel = 0
    indicator.Parent = btn
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(1,0)
    
    btn.MouseButton1Click:Connect(function()
        States[stateKey] = not States[stateKey]
        indicator.BackgroundColor3 = States[stateKey] and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
        if callback then callback(States[stateKey]) end
    end)
end

CreateSlider(movePage, "WalkSpeed", 0, 500, 16, function(val) States.Speed = val ApplyMovement() end)
CreateSlider(movePage, "JumpPower", 0, 300, 50, function(val) States.Jump = val ApplyMovement() end)
CreateToggle(movePage, "Noclip", "Noclip")
CreateToggle(movePage, "Fly (WASD + Space/Ctrl)", "Fly", function(state) ToggleFly() end)
CreateSlider(movePage, "Fly Speed", 0, 10, 5, function(val) States.FlySpeed = val end)

local espPage = Pages["ESP & Visuals"]
CreateToggle(espPage, "Enable ESP", "ESP")
CreateToggle(espPage, "Show Health", "ESP_Health")
CreateToggle(espPage, "Show Distance", "ESP_Distance")
CreateToggle(espPage, "Show Name", "ESP_Name")

local farmPage = Pages["Auto Farm"]
CreateToggle(farmPage, "Auto Farm (Spam Skill + Aimbot)", "Farm")
-- ==========================================
-- 9. POPULATE TAB GIVE ITEM
-- ==========================================
local givePage = Pages["Give Item"]

local giveTabBar = Instance.new("ScrollingFrame")
giveTabBar.Size = UDim2.new(0, 100, 1, -10)
giveTabBar.Position = UDim2.new(0, 5, 0, 5)
giveTabBar.BackgroundTransparency = 1
giveTabBar.ScrollBarThickness = 1
giveTabBar.AutomaticCanvasSize = Enum.AutomaticSize.Y
giveTabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
giveTabBar.Parent = givePage

local giveLayout = Instance.new("UIListLayout", giveTabBar)
giveLayout.SortOrder = Enum.SortOrder.LayoutOrder
giveLayout.Padding = UDim.new(0, 3)

local giveItemList = Instance.new("ScrollingFrame")
giveItemList.Size = UDim2.new(1, -120, 1, -10)
giveItemList.Position = UDim2.new(0, 110, 0, 5)
giveItemList.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
giveItemList.BorderSizePixel = 0
giveItemList.ScrollBarThickness = 2
giveItemList.AutomaticCanvasSize = Enum.AutomaticSize.Y
giveItemList.CanvasSize = UDim2.new(0, 0, 0, 0)
giveItemList.Parent = givePage
Instance.new("UICorner", giveItemList).CornerRadius = UDim.new(0, 5)

local itemLayout = Instance.new("UIListLayout", giveItemList)
itemLayout.SortOrder = Enum.SortOrder.LayoutOrder
itemLayout.Padding = UDim.new(0, 3)

local function LoadCategory(catName, items)
    for _, v in pairs(giveItemList:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    for i, itemData in ipairs(items) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        btn.Text = itemData.Display
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 11
        btn.BorderSizePixel = 0
        btn.Parent = giveItemList
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        
        btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(50,50,50) end)
        btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(25,25,25) end)
        
        btn.MouseButton1Click:Connect(function()
            CreateRipple(btn, btn.AbsoluteSize.X/2, btn.AbsoluteSize.Y/2)
            equipItem(itemData.Name)
        end)
    end
end

local sortedKeys = {}
for k in pairs(ITEM_LIST) do table.insert(sortedKeys, k) end
table.sort(sortedKeys)

for i, catName in ipairs(sortedKeys) do
    local catBtn = Instance.new("TextButton")
    catBtn.Size = UDim2.new(1, -5, 0, 25)
    catBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    catBtn.Text = catName
    catBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    catBtn.Font = Enum.Font.Gotham
    catBtn.TextSize = 10
    catBtn.BorderSizePixel = 0
    catBtn.Parent = giveTabBar
    Instance.new("UICorner", catBtn).CornerRadius = UDim.new(0, 3)
    
    catBtn.MouseButton1Click:Connect(function()
        for _, b in pairs(giveTabBar:GetChildren()) do
            if b:IsA("TextButton") then 
                b.BackgroundColor3 = Color3.fromRGB(20,20,20) 
                b.TextColor3 = Color3.fromRGB(150,150,150) 
            end
        end
        catBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
        catBtn.TextColor3 = Color3.fromRGB(0,0,0)
        LoadCategory(catName, ITEM_LIST[catName])
    end)
    
    if i == 1 then
        catBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
        catBtn.TextColor3 = Color3.fromRGB(0,0,0)
        LoadCategory(catName, ITEM_LIST[catName])
    end
end

-- ==========================================
-- 10. KHỞI TẠO BAN ĐẦU
-- ==========================================
ApplyMovement()
print("DZ Hub Loaded Successfully!")
