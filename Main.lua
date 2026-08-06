-- =================================================================
-- SCRIPT: TAI HUB FIND FRUIT - FULL ULTIMATE EDITION V3.0
-- FIX ALL BUGS (FLY SKY, SERVER HOP STUCK, STOLEN FRUITS)
-- =================================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 1. QUẢN LÝ DỮ LIỆU & THỜI GIAN
-- ==========================================
local RESET_TIMEOUT = 3600

if not getgenv().TaiHubData then
    getgenv().TaiHubData = {
        ServerCount = 1,
        StartTime = os.time(),
        LastActive = os.time()
    }
else
    local currentTime = os.time()
    if (currentTime - getgenv().TaiHubData.LastActive) > RESET_TIMEOUT then
        getgenv().TaiHubData.ServerCount = 1
        getgenv().TaiHubData.StartTime = currentTime
    else
        getgenv().TaiHubData.ServerCount = getgenv().TaiHubData.ServerCount + 1
    end
    getgenv().TaiHubData.LastActive = currentTime
end

_G.TaiHubActive = true
local isProcessing = false
local isHopping = false
local blacklistedFruits = {}
local visitedServers = {}
local activeESPs = {}
local noclipConn = nil

if CoreGui:FindFirstChild("TaiHubUI_Ultimate") then
    CoreGui.TaiHubUI_Ultimate:Destroy()
end

-- ==========================================
-- 2. TỰ ĐỘNG CHỌN PHE HẢI QUÂN (MARINES)
-- ==========================================
task.spawn(function()
    while task.wait(0.2) do
        if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
            pcall(function()
                local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
                if commF then commF:InvokeServer("SetTeam", "Marines") end
                if LocalPlayer.PlayerGui:FindFirstChild("ChooseTeam") then
                    LocalPlayer.PlayerGui.ChooseTeam:Destroy()
                end
            end)
            if LocalPlayer.Team ~= nil or LocalPlayer:FindFirstChild("Data") then break end
        end
    end
end)

-- ==========================================
-- 3. BẢNG MÃ MẶC ĐỊNH TÊN TRÁI CÂY
-- ==========================================
local FruitNameMap = {
    ["Rocket Fruit"]    = "Rocket-Rocket",   ["Spin Fruit"]      = "Spin-Spin",
    ["Blade Fruit"]     = "Chop-Chop",       ["Spring Fruit"]    = "Spring-Spring",
    ["Bomb Fruit"]      = "Bomb-Bomb",       ["Smoke Fruit"]     = "Smoke-Smoke",
    ["Spike Fruit"]     = "Spike-Spike",     ["Flame Fruit"]     = "Flame-Flame",
    ["Ice Fruit"]       = "Ice-Ice",         ["Sand Fruit"]      = "Sand-Sand",
    ["Dark Fruit"]      = "Dark-Dark",       ["Eagle Fruit"]     = "Falcon-Falcon",
    ["Diamond Fruit"]   = "Diamond-Diamond", ["Light Fruit"]     = "Light-Light",
    ["Rubber Fruit"]    = "Rubber-Rubber",   ["Ghost Fruit"]     = "Ghost-Ghost",
    ["Magma Fruit"]     = "Magma-Magma",     ["Quake Fruit"]     = "Quake-Quake",
    ["Buddha Fruit"]    = "Buddha-Buddha",   ["Love Fruit"]      = "Love-Love",
    ["Creation Fruit"]  = "Barrier-Barrier", ["Spider Fruit"]    = "Spider-Spider",
    ["Sound Fruit"]     = "Sound-Sound",     ["Phoenix Fruit"]   = "Phoenix-Phoenix",
    ["Portal Fruit"]    = "Portal-Portal",   ["Lightning Fruit"] = "Rumble-Rumble",
    ["Pain Fruit"]      = "Pain-Pain",       ["Blizzard Fruit"]  = "Blizzard-Blizzard",
    ["Gravity Fruit"]   = "Gravity-Gravity", ["Mammoth Fruit"]   = "Mammoth-Mammoth",
    ["T-Rex Fruit"]     = "TRex-TRex",       ["Dough Fruit"]     = "Dough-Dough",
    ["Shadow Fruit"]    = "Shadow-Shadow",   ["Venom Fruit"]     = "Venom-Venom",
    ["Gas Fruit"]       = "Gas-Gas",         ["Spirit Fruit"]    = "Spirit-Spirit",
    ["Tiger Fruit"]     = "Leopard-Leopard", ["Yeti Fruit"]      = "Yeti-Yeti",
    ["Kitsune Fruit"]   = "Kitsune-Kitsune", ["Control Fruit"]   = "Control-Control",
    ["Dragon Fruit"]    = "Dragon-Dragon"
}

local function getStoreName(rawName)
    if FruitNameMap[rawName] then return FruitNameMap[rawName] end
    local clean = rawName:gsub(" Fruit", ""):gsub(" Fruit ", ""):gsub("^%s*(.-)%s*$", "%1"):gsub("[^%w]", "")
    return clean .. "-" .. clean
end

-- ==========================================
-- 4. HÀM HỖ TRỢ BẢO VỆ NHÂN VẬT
-- ==========================================
local function getCharacter()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health > 0 then
        return char
    end
    return nil
end

local function StopNoclip()
    if noclipConn then 
        noclipConn:Disconnect() 
        noclipConn = nil 
    end
end

-- ==========================================
-- 5. THUẬT TOÁN TELEPORT AN TOÀN (CHỐNG LỖI BAY TRỜI)
-- ==========================================
local function SafeTweenToFruit(targetFruit)
    if not targetFruit or not targetFruit:FindFirstChild("Handle") then return "STOLEN" end
    local char = getCharacter()
    if not char then return "ERROR" end

    local hrp = char.HumanoidRootPart
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    StopNoclip()
    noclipConn = RunService.Stepped:Connect(function()
        local c = getCharacter()
        if c then
            for _, part in pairs(c:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)

    local targetPos = targetFruit.Handle.Position
    local speed = 300 -- Tốc độ di chuyển chuẩn tối ưu
    
    while (hrp.Position - targetPos).Magnitude > 6 do
        if not _G.TaiHubActive then
            StopNoclip()
            return "CANCEL"
        end

        -- KIỂM TRA TRÁI BỊ BẮT/MẤT TRÊN ĐƯỜNG BAY
        if not targetFruit or not targetFruit.Parent or not targetFruit:FindFirstChild("Handle") then
            StopNoclip()
            return "STOLEN"
        end

        targetPos = targetFruit.Handle.Position
        local moveDir = (targetPos - hrp.Position).Unit
        local distance = (targetPos - hrp.Position).Magnitude
        local moveStep = math.min(distance, speed * task.wait())

        hrp.CFrame = CFrame.new(hrp.Position + (moveDir * moveStep), targetPos)
        hrp.Velocity = Vector3.zero
        if hum then hum:ChangeState(Enum.HumanoidStateType.Freefall) end
    end

    if targetFruit and targetFruit:FindFirstChild("Handle") then
        hrp.CFrame = targetFruit.Handle.CFrame
    end

    StopNoclip()
    return "SUCCESS"
end

-- ==========================================
-- 6. THIẾT KẾ GIAO DIỆN UI ĐẸP MẮT (BEAUTIFUL UI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TaiHubUI_Ultimate"
ScreenGui.Parent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 220)
MainFrame.Position = UDim2.new(0.5, -180, 0.35, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)

-- Viền Glow Neon Tím
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 2.5
MainStroke.Color = Color3.fromRGB(168, 85, 247)
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Header Bar
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = Color3.fromRGB(28, 28, 45)
Header.BorderSizePixel = 0

local HeaderCorner = Instance.new("UICorner", Header)
HeaderCorner.CornerRadius = UDim.new(0, 16)

local TitleText = Instance.new("TextLabel", Header)
TitleText.Size = UDim2.new(1, -20, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "💎 TAI HUB - AUTO FIND FRUIT 💎"
TitleText.TextColor3 = Color3.fromRGB(236, 201, 75)
TitleText.TextSize = 15
TitleText.Font = Enum.Font.FredokaOne
TitleText.TextXAlignment = Enum.TextXAlignment.Left

-- Container Chi Tiết
local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, -20, 1, -110)
Container.Position = UDim2.new(0, 10, 0, 50)
Container.BackgroundTransparency = 1

local TimeLabel = Instance.new("TextLabel", Container)
TimeLabel.Size = UDim2.new(1, 0, 0, 20)
TimeLabel.Position = UDim2.new(0, 5, 0, 0)
TimeLabel.BackgroundTransparency = 1
TimeLabel.Text = "⏳ Time Elapsed : 00:00:00"
TimeLabel.TextColor3 = Color3.fromRGB(203, 213, 225)
TimeLabel.TextSize = 13
TimeLabel.Font = Enum.Font.SourceSansBold
TimeLabel.TextXAlignment = Enum.TextXAlignment.Left

local ServerLabel = Instance.new("TextLabel", Container)
ServerLabel.Size = UDim2.new(1, 0, 0, 20)
ServerLabel.Position = UDim2.new(0, 5, 0, 22)
ServerLabel.BackgroundTransparency = 1
ServerLabel.Text = "🌐 Server Checked : " .. getgenv().TaiHubData.ServerCount
ServerLabel.TextColor3 = Color3.fromRGB(56, 189, 248)
ServerLabel.TextSize = 13
ServerLabel.Font = Enum.Font.SourceSansBold
ServerLabel.TextXAlignment = Enum.TextXAlignment.Left

local FruitLabel = Instance.new("TextLabel", Container)
FruitLabel.Size = UDim2.new(1, 0, 0, 22)
FruitLabel.Position = UDim2.new(0, 5, 0, 44)
FruitLabel.BackgroundTransparency = 1
FruitLabel.Text = "🍎 Status : Initializing..."
FruitLabel.TextColor3 = Color3.fromRGB(250, 204, 21)
FruitLabel.TextSize = 14
FruitLabel.Font = Enum.Font.SourceSansBold
FruitLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Nút Bật/Tắt Auto
local ToggleBtn = Instance.new("TextButton", MainFrame)
ToggleBtn.Size = UDim2.new(1, -24, 0, 40)
ToggleBtn.Position = UDim2.new(0, 12, 1, -50)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
ToggleBtn.Text = "⚡ AUTO FARM: ON ⚡"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 14
ToggleBtn.Font = Enum.Font.FredokaOne
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 10)

-- Drag UI Engine
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Toggle Switch Logic
ToggleBtn.MouseButton1Click:Connect(function()
    _G.TaiHubActive = not _G.TaiHubActive
    if _G.TaiHubActive then
        ToggleBtn.Text = "⚡ AUTO FARM: ON ⚡"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
    else
        ToggleBtn.Text = "⛔ AUTO FARM: OFF ⛔"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
        FruitLabel.Text = "🍎 Status : Paused"
        StopNoclip()
        isProcessing = false
        isHopping = false
    end
end)

-- Cập nhật đồng hồ thời gian
task.spawn(function()
    while task.wait(1) do
        getgenv().TaiHubData.LastActive = os.time()
        local elapsed = os.time() - getgenv().TaiHubData.StartTime
        TimeLabel.Text = string.format("⏳ Time Elapsed : %02d:%02d:%02d", math.floor(elapsed/3600), math.floor((elapsed%3600)/60), elapsed%60)
        ServerLabel.Text = "🌐 Server Checked : " .. getgenv().TaiHubData.ServerCount
    end
end)

-- ==========================================
-- 7. HỆ THỐNG ESP 3D ĐỌC TÊN VÀ KHOẢNG CÁCH
-- ==========================================
local function ClearESP()
    for _, item in pairs(activeESPs) do
        if item.Connection then item.Connection:Disconnect() end
        if item.Gui then item.Gui:Destroy() end
    end
    activeESPs = {}
end

local function CreateESP(fruitObj)
    if not fruitObj or not fruitObj:FindFirstChild("Handle") then return end
    local bg = Instance.new("BillboardGui")
    bg.Name = "TaiHub_ESP_V3"
    bg.Adornee = fruitObj.Handle
    bg.Size = UDim2.new(0, 200, 0, 40)
    bg.AlwaysOnTop = true
    bg.Parent = ScreenGui

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.fromRGB(52, 211, 153)
    txt.TextStrokeTransparency = 0
    txt.TextSize = 14
    txt.Font = Enum.Font.SourceSansBold
    txt.Parent = bg

    local conn
    conn = RunService.RenderStepped:Connect(function()
        local char = getCharacter()
        if char and char:FindFirstChild("HumanoidRootPart") and fruitObj and fruitObj.Parent and fruitObj:FindFirstChild("Handle") then
            local dist = math.floor((char.HumanoidRootPart.Position - fruitObj.Handle.Position).Magnitude / 3.57)
            txt.Text = "🍎 " .. fruitObj.Name .. "\n[" .. dist .. "m]"
        else
            bg:Destroy()
            if conn then conn:Disconnect() end
        end
    end)
    table.insert(activeESPs, {Gui = bg, Connection = conn})
end

-- ==========================================
-- 8. TỰ ĐỘNG CẤT KHO TRÁI (STORE FRUIT)
-- ==========================================
local function GetFruitInInventory()
    local char = getCharacter()
    if not char then return nil end
    for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
        if item:IsA("Tool") and (string.find(item.Name, "Fruit") or FruitNameMap[item.Name]) then return item end
    end
    for _, item in pairs(char:GetChildren()) do
        if item:IsA("Tool") and (string.find(item.Name, "Fruit") or FruitNameMap[item.Name]) then return item end
    end
    return nil
end

local function PickupAndStore(fruitObj)
    local char = getCharacter()
    if not char or not fruitObj or not fruitObj:FindFirstChild("Handle") then return end
    local hrp = char.HumanoidRootPart
    local handle = fruitObj.Handle

    if firetouchinterest then
        firetouchinterest(hrp, handle, 0)
        task.wait(0.05)
        firetouchinterest(hrp, handle, 1)
    end

    FruitLabel.Text = "📦 Storing Fruit to Inventory..."
    local targetTool = nil
    local checkStart = tick()
    while (tick() - checkStart) < 1.5 do
        targetTool = GetFruitInInventory()
        if targetTool then break end
        task.wait(0.1)
    end

    if targetTool then
        targetTool.Parent = char
        task.wait(0.15)
        local storeName = getStoreName(targetTool.Name)
        local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if remote then
            local res = remote:InvokeServer("StoreFruit", storeName, targetTool)
            task.wait(0.2)
            if res == false or res == "Full" then blacklistedFruits[fruitObj] = true end
        end
    else
        blacklistedFruits[fruitObj] = true
    end
end

-- ==========================================
-- 9. HOP SERVER CHỐNG TREO 100% (TRIPLE-LAYER BẢO VỆ)
-- ==========================================
local function ForceHopServer()
    if not _G.TaiHubActive or isHopping then return end
    isHopping = true
    isProcessing = true
    FruitLabel.Text = "🚀 Searching Low Server..."

    visitedServers[game.JobId] = true

    -- Lớp 1: Quét danh sách Server công khai (Ưu tiên 1-3 người)
    local hopSuccess = false
    pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local rawData = game:HttpGet(url)
        if rawData then
            local decoded = HttpService:JSONDecode(rawData)
            if decoded and decoded.data then
                for _, server in pairs(decoded.data) do
                    if server.id ~= game.JobId and not visitedServers[server.id] and server.playing >= 1 and server.playing <= 4 then
                        visitedServers[server.id] = true
                        FruitLabel.Text = "✈️ Joining Server (" .. server.playing .. " P)..."
                        hopSuccess = true
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                        task.wait(6)
                        return
                    end
                end
            end
        end
    end)

    -- Lớp 2 & 3: Nếu API lỗi/bị chặn request -> Nhảy server ngẫu nhiên lập tức
    if not hopSuccess and _G.TaiHubActive then
        FruitLabel.Text = "✈️ Fast Random Hop..."
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end
    
    task.wait(5)
    isHopping = false
    isProcessing = false
end

-- ==========================================
-- 10. TÌM TRÁI CÂY TRÊN MAP
-- ==========================================
local function FindFruits()
    local found = {}
    for _, obj in pairs(Workspace:GetChildren()) do
        if (obj:IsA("Tool") or obj:IsA("Model")) and string.find(obj.Name, "Fruit") and obj:FindFirstChild("Handle") then
            if not blacklistedFruits[obj] then
                table.insert(found, obj)
            end
        end
    end
    return found
end

-- ==========================================
-- 11. VÒNG LẶP CHÍNH (MAIN AUTOMATION)
-- ==========================================
task.spawn(function()
    while task.wait(0.3) do
        if _G.TaiHubActive and not isProcessing and not isHopping then
            local char = getCharacter()
            if char then
                local fruits = FindFruits()
                ClearESP()

                if #fruits > 0 then
                    isProcessing = true
                    
                    for _, f in pairs(fruits) do CreateESP(f) end
                    local target = fruits[1]
                    FruitLabel.Text = "🔥 FOUND: " .. target.Name

                    local result = SafeTweenToFruit(target)

                    if result == "SUCCESS" then
                        PickupAndStore(target)
                        task.wait(0.4)
                        isProcessing = false
                    elseif result == "STOLEN" then
                        FruitLabel.Text = "⚠️ Stolen Fruit! Fast Hop..."
                        task.wait(0.2)
                        ForceHopServer()
                    else
                        isProcessing = false
                    end
                else
                    FruitLabel.Text = "🌐 No Fruit Found! Hopping..."
                    ForceHopServer()
                end
            end
        end
    end
end)
