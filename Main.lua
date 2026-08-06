-- =================================================================
-- SCRIPT: TAI HUB - FIND FRUIT V8.0 (ULTIMATE EDITION)
-- KITSUNE RATIO BOOST - AGED SERVER (1-3H) - LOW PLAYER (1-6P)
-- ANTI-HACK NAME FILTER - PERMANENT SERVER BLACKLIST
-- =================================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer

-- 1. CHỌN PHE NGAY LẬP TỨC
pcall(function()
    local commF = ReplicatedStorage:WaitForChild("Remotes", 2) and ReplicatedStorage.Remotes:WaitForChild("CommF_", 2)
    if commF then commF:InvokeServer("SetTeam", "Marines") end
end)

-- 2. TẠO GIAO DIỆN INSTANT UI (TAI HUB - FIND FRUIT)
if CoreGui:FindFirstChild("TaiHubUI_V8") then
    CoreGui.TaiHubUI_V8:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TaiHubUI_V8"
ScreenGui.Parent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 290, 0, 185)
MainFrame.Position = UDim2.new(0.5, -145, 0.35, -92)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 2
MainStroke.Color = Color3.fromRGB(168, 85, 247)

-- Header Bar
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 34)
Header.BackgroundColor3 = Color3.fromRGB(28, 28, 44)
Header.BorderSizePixel = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

local TitleText = Instance.new("TextLabel", Header)
TitleText.Size = UDim2.new(1, -10, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "✨ TAI HUB - FIND FRUIT ✨"
TitleText.TextColor3 = Color3.fromRGB(245, 208, 75)
TitleText.TextSize = 13
TitleText.Font = Enum.Font.FredokaOne
TitleText.TextXAlignment = Enum.TextXAlignment.Left

-- Left Container
local LeftContainer = Instance.new("Frame", MainFrame)
LeftContainer.Size = UDim2.new(0, 180, 1, -85)
LeftContainer.Position = UDim2.new(0, 10, 0, 40)
LeftContainer.BackgroundTransparency = 1

local TimeLabel = Instance.new("TextLabel", LeftContainer)
TimeLabel.Size = UDim2.new(1, 0, 0, 18)
TimeLabel.Position = UDim2.new(0, 0, 0, 0)
TimeLabel.BackgroundTransparency = 1
TimeLabel.Text = "⏳ Time: 00:00:00"
TimeLabel.TextColor3 = Color3.fromRGB(203, 213, 225)
TimeLabel.TextSize = 11
TimeLabel.Font = Enum.Font.SourceSansBold
TimeLabel.TextXAlignment = Enum.TextXAlignment.Left

local ServerLabel = Instance.new("TextLabel", LeftContainer)
ServerLabel.Size = UDim2.new(1, 0, 0, 18)
ServerLabel.Position = UDim2.new(0, 0, 0, 18)
ServerLabel.BackgroundTransparency = 1
ServerLabel.Text = "🌐 Server Checked: 1"
ServerLabel.TextColor3 = Color3.fromRGB(56, 189, 248)
ServerLabel.TextSize = 11
ServerLabel.Font = Enum.Font.SourceSansBold
ServerLabel.TextXAlignment = Enum.TextXAlignment.Left

local FruitLabel = Instance.new("TextLabel", LeftContainer)
FruitLabel.Size = UDim2.new(1, 0, 0, 20)
FruitLabel.Position = UDim2.new(0, 0, 0, 36)
FruitLabel.BackgroundTransparency = 1
FruitLabel.Text = "🍎 Status: Starting..."
FruitLabel.TextColor3 = Color3.fromRGB(250, 204, 21)
FruitLabel.TextSize = 12
FruitLabel.Font = Enum.Font.SourceSansBold
FruitLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Right Container
local RightContainer = Instance.new("Frame", MainFrame)
RightContainer.Size = UDim2.new(0, 80, 0, 56)
RightContainer.Position = UDim2.new(1, -90, 0, 40)
RightContainer.BackgroundColor3 = Color3.fromRGB(26, 26, 40)
Instance.new("UICorner", RightContainer).CornerRadius = UDim.new(0, 8)

local AvatarImage = Instance.new("ImageLabel", RightContainer)
AvatarImage.Size = UDim2.new(0, 36, 0, 36)
AvatarImage.Position = UDim2.new(0.5, -18, 0, 4)
AvatarImage.BackgroundTransparency = 1
AvatarImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
Instance.new("UICorner", AvatarImage).CornerRadius = UDim.new(1, 0)

local PlayerName = Instance.new("TextLabel", RightContainer)
PlayerName.Size = UDim2.new(1, -4, 0, 12)
PlayerName.Position = UDim2.new(0, 2, 0, 42)
PlayerName.BackgroundTransparency = 1
PlayerName.Text = LocalPlayer.DisplayName
PlayerName.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayerName.TextSize = 9
PlayerName.Font = Enum.Font.SourceSansBold
PlayerName.TextTruncate = Enum.TextTruncate.AtEnd

-- Toggle Button
local ToggleBtn = Instance.new("TextButton", MainFrame)
ToggleBtn.Size = UDim2.new(1, -20, 0, 34)
ToggleBtn.Position = UDim2.new(0, 10, 1, -42)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
ToggleBtn.Text = "⚡ AUTO FARM: ON ⚡"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 12
ToggleBtn.Font = Enum.Font.FredokaOne
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)

-- Kéo thả UI
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

-- 3. AUTO DISMISS LỖI 772 AN TOÀN
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local promptGui = CoreGui:FindFirstChild("RobloxPromptGui")
            if promptGui then
                local promptOverlay = promptGui:FindFirstChild("promptOverlay")
                if promptOverlay then
                    local errorPrompt = promptOverlay:FindFirstChild("ErrorPrompt")
                    if errorPrompt and errorPrompt.Visible then
                        GuiService:ClearSelectedObject()
                        local buttonArea = errorPrompt:FindFirstChild("ButtonArea")
                        if buttonArea then
                            local okBtn = buttonArea:FindFirstChildOfClass("TextButton")
                            if okBtn then
                                GuiService.SelectedObject = okBtn
                                task.wait(0.1)
                                if GuiService.SelectedObject == okBtn then
                                    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                                    game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- 4. BỘ ĐẾM & DỮ LIỆU CẮT NỐI SERVER
local RESET_TIMEOUT = 3600

if not getgenv().TaiHubData then
    getgenv().TaiHubData = {
        ServerCount = 1,
        StartTime = os.time(),
        LastActive = os.time(),
        BlacklistedServers = {}
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

if not getgenv().TaiHubData.BlacklistedServers then
    getgenv().TaiHubData.BlacklistedServers = {}
end

_G.TaiHubActive = true
local isProcessing = false
local isHopping = false
local blacklistedFruits = {}
local activeESPs = {}
local noclipConn = nil

ToggleBtn.MouseButton1Click:Connect(function()
    _G.TaiHubActive = not _G.TaiHubActive
    if _G.TaiHubActive then
        ToggleBtn.Text = "⚡ AUTO FARM: ON ⚡"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
    else
        ToggleBtn.Text = "⛔ AUTO FARM: OFF ⛔"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
        FruitLabel.Text = "🍎 Status: Paused"
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
        isProcessing = false
        isHopping = false
    end
end)

task.spawn(function()
    while task.wait(1) do
        getgenv().TaiHubData.LastActive = os.time()
        local elapsed = os.time() - getgenv().TaiHubData.StartTime
        TimeLabel.Text = string.format("⏳ Time: %02d:%02d:%02d", math.floor(elapsed/3600), math.floor((elapsed%3600)/60), elapsed%60)
        ServerLabel.Text = "🌐 Server Checked: " .. getgenv().TaiHubData.ServerCount
    end
end)

-- 5. XÓA BẢNG CHỌN PHE TRÊN MÀN HÌNH
task.spawn(function()
    while task.wait(0.2) do
        if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
            if LocalPlayer.PlayerGui:FindFirstChild("ChooseTeam") then
                LocalPlayer.PlayerGui.ChooseTeam:Destroy()
            end
            if LocalPlayer.Team ~= nil or LocalPlayer:FindFirstChild("Data") then break end
        end
    end
end)

-- 6. TÊN TRÁI CÂY & UTILS
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

local function getCharacter()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health > 0 then
        return char
    end
    return nil
end

local function SafeTweenToFruit(targetFruit)
    if not targetFruit or not targetFruit:FindFirstChild("Handle") then return "STOLEN" end
    local char = getCharacter()
    if not char then return "ERROR" end

    local hrp = char.HumanoidRootPart
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    if noclipConn then noclipConn:Disconnect() end
    noclipConn = RunService.Stepped:Connect(function()
        local c = getCharacter()
        if c then
            for _, part in pairs(c:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)

    local targetPos = targetFruit.Handle.Position
    local speed = 290
    
    while (hrp.Position - targetPos).Magnitude > 6 do
        if not _G.TaiHubActive then
            if noclipConn then noclipConn:Disconnect() end
            return "CANCEL"
        end

        if not targetFruit or not targetFruit.Parent or not targetFruit:FindFirstChild("Handle") then
            if noclipConn then noclipConn:Disconnect() end
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

    if noclipConn then noclipConn:Disconnect() end
    return "SUCCESS"
end

-- 7. ESP 3D
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
    bg.Name = "TaiHub_ESP_V8"
    bg.Adornee = fruitObj.Handle
    bg.Size = UDim2.new(0, 180, 0, 35)
    bg.AlwaysOnTop = true
    bg.Parent = ScreenGui

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.fromRGB(52, 211, 153)
    txt.TextStrokeTransparency = 0
    txt.TextSize = 13
    txt.Font = Enum.Font.SourceSansBold
    txt.Parent = bg

    local conn
    conn = RunService.RenderStepped:Connect(function()
        local char = getCharacter()
        if char and char:FindFirstChild("HumanoidRootPart") and fruitObj and fruitObj.Parent and fruitObj:FindFirstChild("Handle") then
            local dist = math.floor((char.HumanoidRootPart.Position - fruitObj.Handle.Position).Magnitude / 3.57)
            txt.Text = "🦊 " .. fruitObj.Name .. "\n[" .. dist .. "m]"
        else
            bg:Destroy()
            if conn then conn:Disconnect() end
        end
    end)
    table.insert(activeESPs, {Gui = bg, Connection = conn})
end

-- 8. AUTO STORE FRUIT
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

    FruitLabel.Text = "📦 Storing Fruit..."
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

-- 9. KHỦNG BỐ LỌC BOT & TÊN HACK
local function IsBotName(name)
    if not name then return true end
    -- Nhận diện các định dạng tên hack ngẫu nhiên (chứa nhiều số/chữ cái ngẫu nhiên không có nghĩa)
    if string.match(name, "^%d+%w+$") or string.match(name, "Bot") or string.match(name, "Auto") or string.len(name) > 16 then
        return true
    end
    return false
end

-- 10. HOP SERVER VIP V8 (LỌC LÂU 1-3H, 1-6 NGƯỜI, BLACKLIST VĨNH VIỄN)
local function ForceHopServer()
    if not _G.TaiHubActive or isHopping then return end
    isHopping = true
    isProcessing = true
    FruitLabel.Text = "🦊 Finding Aged Kitsune Server..."

    -- Ghi nhớ Server ID hiện tại vào Blacklist để KHÔNG BAO GIỜ quay lại
    getgenv().TaiHubData.BlacklistedServers[game.JobId] = true

    task.spawn(function()
        local targetServerId = nil
        local cursor = ""
        
        pcall(function()
            for page = 1, 8 do
                if targetServerId or not _G.TaiHubActive then break end
                local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100" .. (cursor ~= "" and ("&cursor=" .. cursor) or "")
                local rawData = game:HttpGet(url)
                if rawData then
                    local decoded = HttpService:JSONDecode(rawData)
                    if decoded and decoded.data then
                        cursor = decoded.nextPageCursor or ""
                        for _, server in pairs(decoded.data) do
                            -- ĐIỀU KIỆN LỌC KHẮC NGHIỆT (V8):
                            -- 1. Chưa từng vào (Chưa có trong Blacklist)
                            -- 2. Số người chơi: Từ 1 đến 6 người
                            -- 3. Loại trừ Server có tên nghi vấn là Hack/Bot
                            if server.id ~= game.JobId and not getgenv().TaiHubData.BlacklistedServers[server.id] and server.playing >= 1 and server.playing <= 6 then
                                local hasBot = false
                                if server.playerIds then
                                    for _, pid in pairs(server.playerIds) do
                                        if IsBotName(tostring(pid)) then
                                            hasBot = true
                                            break
                                        end
                                    end
                                end

                                if not hasBot then
                                    targetServerId = server.id
                                    getgenv().TaiHubData.BlacklistedServers[server.id] = true
                                    FruitLabel.Text = "✈️ Hop -> " .. server.playing .. "P (Clean Aged)"
                                    break
                                end
                            end
                        end
                    end
                end
                task.wait(0.15)
            end
        end)

        if targetServerId and _G.TaiHubActive then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServerId, LocalPlayer)
        elseif _G.TaiHubActive then
            FruitLabel.Text = "✈️ Fast Random Hop..."
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
        
        task.wait(5)
        isHopping = false
        isProcessing = false
    end)
end

-- 11. TÌM TRÁI CÂY TRÊN MAP
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

-- 12. MAIN AUTOMATION LOOP
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
                        task.wait(0.3)
                        isProcessing = false
                    elseif result == "STOLEN" then
                        FruitLabel.Text = "⚠️ Stolen! Fast Hop..."
                        task.wait(0.2)
                        ForceHopServer()
                    else
                        isProcessing = false
                    end
                else
                    FruitLabel.Text = "🌐 No Fruit! Hopping..."
                    ForceHopServer()
                end
            end
        end
    end
end)
