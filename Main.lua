-- =================================================================
-- SCRIPT: TAI HUB FIND FRUIT (FAST PICK & INSTANT STORE EDITION)
-- SMOOTH FAST TWEEN -> INSTANT TOUCH PICK -> FAST STORE -> SMART HOP
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
local Stats = game:GetService("Stats")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer

-- QUEUE ON TELEPORT
local queue_on_teleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
if queue_on_teleport and getgenv().TaiHubScriptSource then
    queue_on_teleport([[
        repeat task.wait() until game:IsLoaded()
        ]] .. getgenv().TaiHubScriptSource .. [[
    ]])
end

-- GET CHARACTER
local function getCharacter()
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hrp and hum and hum.Health > 0 then
            if hum.Sit then hum.Sit = false end
            return char, hrp, hum
        end
    end
    return nil, nil, nil
end

-- AUTO SET TEAM MARINES
pcall(function()
    local commF = ReplicatedStorage:WaitForChild("Remotes", 3) and ReplicatedStorage.Remotes:WaitForChild("CommF_", 3)
    if commF then commF:InvokeServer("SetTeam", "Marines") end
end)

-- UI SYSTEM (TAI HUB FIND FRUIT)
if CoreGui:FindFirstChild("TaiHubFindFruit") then
    CoreGui.TaiHubFindFruit:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TaiHubFindFruit"
ScreenGui.Parent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 330, 0, 250)
MainFrame.Position = UDim2.new(0.5, -165, 0.25, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 1.5
MainStroke.Color = Color3.fromRGB(168, 85, 247)

-- Header
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 32)
Header.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Header.BorderSizePixel = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local TitleText = Instance.new("TextLabel", Header)
TitleText.Size = UDim2.new(1, -10, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "✨ TAI HUB FIND FRUIT ✨"
TitleText.TextColor3 = Color3.fromRGB(245, 208, 75)
TitleText.TextSize = 12
TitleText.Font = Enum.Font.FredokaOne
TitleText.TextXAlignment = Enum.TextXAlignment.Left

-- Container
local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, -20, 0, 160)
Container.Position = UDim2.new(0, 10, 0, 38)
Container.BackgroundTransparency = 1

local function CreateLabel(posY, text, color)
    local lbl = Instance.new("TextLabel", Container)
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.Position = UDim2.new(0, 0, 0, posY)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or Color3.fromRGB(203, 213, 225)
    lbl.TextSize = 10
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    return lbl
end

local TimeLabel = CreateLabel(0, "⏳ Elapsed: 00:00:00 | 📶 Ping: 0 ms")
local ServerLabel = CreateLabel(18, "🌐 Server Checked: 1", Color3.fromRGB(56, 189, 248))
local ApiLabel = CreateLabel(36, "📡 Server JobID: " .. string.sub(game.JobId, 1, 12) .. "...", Color3.fromRGB(192, 132, 252))
local PlayersOnlineLabel = CreateLabel(54, "👥 Players Online: " .. #Players:GetPlayers() .. " (Target: 1-5)", Color3.fromRGB(74, 222, 128))
local FruitLabel = CreateLabel(72, "🔍 Status: Initializing Engine...", Color3.fromRGB(250, 204, 21))
local DetailLabel = CreateLabel(90, "💡 Action: Scanning Map...", Color3.fromRGB(148, 163, 184))
local TargetLabel = CreateLabel(108, "🍎 Target: None", Color3.fromRGB(168, 85, 247))
local StoreAttemptLabel = CreateLabel(126, "📦 Store Attempts: 0", Color3.fromRGB(52, 211, 153))

-- Toggle Button
local ToggleBtn = Instance.new("TextButton", MainFrame)
ToggleBtn.Size = UDim2.new(1, -20, 0, 32)
ToggleBtn.Position = UDim2.new(0, 10, 1, -38)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
ToggleBtn.Text = "⚡ TAI HUB FIND FRUIT: ACTIVE ⚡"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 11
ToggleBtn.Font = Enum.Font.FredokaOne
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

-- Dragging UI
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

-- DATA PERSISTENCE & BLACKLIST
if not getgenv().TaiHubData then
    getgenv().TaiHubData = { ServerCount = 1, StartTime = os.time(), LastActive = os.time(), BlacklistedServers = {} }
else
    if (os.time() - getgenv().TaiHubData.LastActive) > 7200 then
        getgenv().TaiHubData.ServerCount = 1
        getgenv().TaiHubData.StartTime = os.time()
    else
        getgenv().TaiHubData.ServerCount = getgenv().TaiHubData.ServerCount + 1
    end
    getgenv().TaiHubData.LastActive = os.time()
end

getgenv().TaiHubData.BlacklistedServers[game.JobId] = true

_G.TaiHubActive = true
local isProcessing = false
local isHopping = false
local blacklistedFruits = {}

ToggleBtn.MouseButton1Click:Connect(function()
    _G.TaiHubActive = not _G.TaiHubActive
    if _G.TaiHubActive then
        ToggleBtn.Text = "⚡ TAI HUB FIND FRUIT: ACTIVE ⚡"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
    else
        ToggleBtn.Text = "⛔ TAI HUB FIND FRUIT: PAUSED ⛔"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
        FruitLabel.Text = "⏸️ Status: Paused"
        DetailLabel.Text = "💡 Action: Engine Halted"
        isProcessing = false
        isHopping = false
    end
end)

-- CHECK TRÁI CHUẨN
local function IsRealFruit(obj)
    if not obj or not obj.Parent or obj.Parent ~= Workspace then return false end
    if not (obj:IsA("Tool") or obj:IsA("Model")) then return false end
    if not string.find(obj.Name, "Fruit") then return false end
    if blacklistedFruits[obj] then return false end

    local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildOfClass("BasePart")
    if not handle then return false end

    return true, handle
end

-- ESP HIỆN TÊN & KHỎANG CÁCH
local function UpdateFruitESP()
    for _, obj in pairs(Workspace:GetChildren()) do
        local isReal, handle = IsRealFruit(obj)
        if isReal and handle then
            if not handle:FindFirstChild("FruitESP_UI") then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "FruitESP_UI"
                billboard.Adornee = handle
                billboard.Size = UDim2.new(0, 200, 0, 40)
                billboard.AlwaysOnTop = true
                billboard.ExtentsOffset = Vector3.new(0, 2.5, 0)
                billboard.Parent = handle

                local label = Instance.new("TextLabel", billboard)
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.TextColor3 = Color3.fromRGB(255, 40, 40)
                label.TextStrokeTransparency = 0
                label.TextSize = 14
                label.Font = Enum.Font.SourceSansBold

                local highlight = Instance.new("Highlight")
                highlight.Name = "FruitESP_Glow"
                highlight.Adornee = obj
                highlight.FillColor = Color3.fromRGB(255, 0, 100)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.4
                highlight.Parent = handle
            end

            local espUI = handle:FindFirstChild("FruitESP_UI")
            if espUI and espUI:FindFirstChildOfClass("TextLabel") then
                local _, hrp = getCharacter()
                local dist = hrp and math.floor((handle.Position - hrp.Position).Magnitude / 3.57) or 0
                espUI.TextLabel.Text = "🍎 " .. obj.Name .. "\n[" .. dist .. "m]"
            end
        end
    end
end

-- BACKGROUND SYSTEM LOOP
task.spawn(function()
    while task.wait(0.3) do
        if _G.TaiHubActive then
            getgenv().TaiHubData.LastActive = os.time()
            local elapsed = os.time() - getgenv().TaiHubData.StartTime
            
            local currentPing = 0
            pcall(function()
                currentPing = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            end)

            TimeLabel.Text = string.format("⏳ Elapsed: %02d:%02d:%02d | 📶 Ping: %d ms", math.floor(elapsed/3600), math.floor((elapsed%3600)/60), elapsed%60, currentPing)
            ServerLabel.Text = "🌐 Server Checked: " .. getgenv().TaiHubData.ServerCount
            PlayersOnlineLabel.Text = "👥 Players Online: " .. #Players:GetPlayers() .. " (Target: 1-5)"

            pcall(UpdateFruitESP)

            -- Clear Error Prompt
            pcall(function()
                local promptGui = CoreGui:FindFirstChild("RobloxPromptGui")
                if promptGui then
                    local promptOverlay = promptGui:FindFirstChild("promptOverlay")
                    if promptOverlay and promptOverlay:FindFirstChild("ErrorPrompt") and promptOverlay.ErrorPrompt.Visible then
                        GuiService:ClearSelectedObject()
                        local btn = promptOverlay.ErrorPrompt:FindFirstChild("ButtonArea") and promptOverlay.ErrorPrompt.ButtonArea:FindFirstChildOfClass("TextButton")
                        if btn then
                            GuiService.SelectedObject = btn
                            task.wait(0.05)
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                        end
                    end
                end
            end)
        end
    end
end)

-- GET VALID FRUITS ON MAP
local function GetValidFruitsOnMap()
    local validFruits = {}
    local _, hrp = getCharacter()
    if not hrp then return validFruits end

    for _, obj in pairs(Workspace:GetChildren()) do
        local isReal, handle = IsRealFruit(obj)
        if isReal and handle then
            local dist = (handle.Position - hrp.Position).Magnitude
            table.insert(validFruits, { object = obj, handle = handle, distance = dist })
        end
    end

    table.sort(validFruits, function(a, b) return a.distance < b.distance end)
    return validFruits
end

-- GET FRUIT IN INVENTORY
local function GetFruitInInventory()
    local char = getCharacter()
    for _, container in pairs({LocalPlayer.Backpack, char}) do
        if container then
            for _, item in pairs(container:GetChildren()) do
                if item:IsA("Tool") and string.find(item.Name, "Fruit") then
                    return item
                end
            end
        end
    end
    return nil
end

-- SMART HOP SERVER (1 - 5 PLAYERS)
local function SmartHopServer()
    if not _G.TaiHubActive or isHopping then return end
    isHopping = true
    isProcessing = true

    getgenv().TaiHubData.BlacklistedServers[game.JobId] = true
    FruitLabel.Text = "✈️ Status: API Scanning (1-5 Players)..."

    local function AttemptHop()
        local targetServerId = nil
        local targetPlayerCount = 0
        local cursor = ""
        local validCandidateServers = {}

        pcall(function()
            local randomStartPage = math.random(1, 4)
            for page = 1, 10 do
                if not _G.TaiHubActive then break end
                local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100" .. (cursor ~= "" and ("&cursor=" .. cursor) or "")
                local rawData = game:HttpGet(url)
                
                if rawData then
                    local decoded = HttpService:JSONDecode(rawData)
                    if decoded and decoded.data then
                        cursor = decoded.nextPageCursor or ""
                        if page >= randomStartPage then
                            for _, server in pairs(decoded.data) do
                                local playing = server.playing or 0
                                if server.id ~= game.JobId 
                                   and not getgenv().TaiHubData.BlacklistedServers[server.id] 
                                   and playing >= 1 and playing <= 5 then
                                    table.insert(validCandidateServers, { id = server.id, playing = playing })
                                end
                            end
                        end
                    end
                end
                if #validCandidateServers >= 3 then break end
                task.wait(0.05)
            end
        end)

        if #validCandidateServers > 0 then
            local chosen = validCandidateServers[math.random(1, #validCandidateServers)]
            targetServerId = chosen.id
            targetPlayerCount = chosen.playing
            getgenv().TaiHubData.BlacklistedServers[targetServerId] = true
        end

        if targetServerId and _G.TaiHubActive then
            FruitLabel.Text = "✈️ Status: Teleporting..."
            DetailLabel.Text = "🌐 Target Server: [" .. targetPlayerCount .. " Players]"
            ApiLabel.Text = "📡 Next Server: " .. string.sub(targetServerId, 1, 12) .. "..."
            task.wait(0.2)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServerId, LocalPlayer)
            return true
        end
        return false
    end

    local success = AttemptHop()
    if not success and _G.TaiHubActive then
        DetailLabel.Text = "⚠️ Searching Fallback Server..."
        task.wait(0.5)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end

    task.delay(8, function()
        isHopping = false
        isProcessing = false
    end)
end

-- TWEEN TỚI TRÁI CỰC MƯỢT (NOCLIP 350 KM/H)
local function SafeTweenToFruit(fruitData)
    local handle = fruitData.handle
    local targetFruit = fruitData.object

    local char, hrp = getCharacter()
    if not char or not hrp then return "ERROR" end

    local noclipConn = RunService.Stepped:Connect(function()
        local c = getCharacter()
        if c then
            for _, part in pairs(c:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)

    local speed = 350
    while true do
        local currentChar, currentHrp = getCharacter()
        if not currentChar or not currentHrp then
            if noclipConn then noclipConn:Disconnect() end
            return "RESET"
        end

        if not _G.TaiHubActive then
            if noclipConn then noclipConn:Disconnect() end
            return "CANCEL"
        end

        if not IsRealFruit(targetFruit) then
            if noclipConn then noclipConn:Disconnect() end
            return "STOLEN"
        end

        local currentPos = currentHrp.Position
        local targetPos = handle.Position
        local dist = (targetPos - currentPos).Magnitude

        if dist <= 2.5 then break end

        local dt = RunService.Heartbeat:Wait()
        local moveStep = math.min(dist, speed * dt)
        local alpha = moveStep / dist

        currentHrp.CFrame = CFrame.new(currentPos:Lerp(targetPos, alpha), targetPos)
        currentHrp.Velocity = Vector3.zero

        DetailLabel.Text = string.format("🚀 Tweening... Distance: %dm", math.floor(dist / 3.57))
    end

    if noclipConn then noclipConn:Disconnect() end
    return "SUCCESS"
end

-- LỤM BẬC CẤT LUÔN SIÊU TỐC
local function PickupAndStoreVerified(fruitData)
    local fruitObj = fruitData.object
    local handle = fruitData.handle
    local char, hrp, hum = getCharacter()
    if not char or not hrp or not handle then return end

    DetailLabel.Text = "🍎 Picking Fruit..."

    -- Đặt vị trí chính xác lên trái
    hrp.CFrame = handle.CFrame

    -- Ép va chạm lụm ngay lập tức
    if firetouchinterest then
        firetouchinterest(hrp, handle, 0)
        task.wait(0.01)
        firetouchinterest(hrp, handle, 1)
    end

    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then commF:InvokeServer("PickFruit", fruitObj) end
    end)

    local prompt = fruitObj:FindFirstChildOfClass("ProximityPrompt") or handle:FindFirstChildOfClass("ProximityPrompt")
    if prompt and fireproximityprompt then fireproximityprompt(prompt) end

    task.wait(0.15)

    local tool = GetFruitInInventory()
    if not tool then
        -- Thử lại lần cuối siêu tốc
        pcall(function()
            if commF then commF:InvokeServer("PickFruit", fruitObj) end
        end)
        task.wait(0.15)
        tool = GetFruitInInventory()
    end

    if not tool then
        blacklistedFruits[fruitObj] = true
        FruitLabel.Text = "⚠️ Fruit Gone / Unpickable!"
        SmartHopServer()
        return
    end

    -- Cầm trái lên tay ngay lập tức
    DetailLabel.Text = "🖐️ Equipping Fruit..."
    if char and tool.Parent ~= char then
        if hum then hum:EquipTool(tool) else tool.Parent = char end
    end
    task.wait(0.15)

    -- Cất vào rương siêu tốc
    FruitLabel.Text = "🔒 Storing Fruit..."
    local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")

    local storeAttempts = 0
    local storeStart = tick()
    
    while GetFruitInInventory() and (tick() - storeStart) < 4 do
        storeAttempts = storeAttempts + 1
        StoreAttemptLabel.Text = "📦 Store Attempts: " .. storeAttempts
        
        local currentTool = GetFruitInInventory()
        if currentTool and remote then
            remote:InvokeServer("StoreFruit", currentTool.Name, currentTool)
        end
        task.wait(0.15)
    end

    if not GetFruitInInventory() then
        FruitLabel.Text = "✅ Store Success!"
        DetailLabel.Text = "🎉 Stored into inventory!"
        task.wait(0.2)
    else
        FruitLabel.Text = "⚠️ Store Failed (Full Inventory)!"
        blacklistedFruits[fruitObj] = true
    end

    SmartHopServer()
end

-- MAIN ENGINE LOOP
task.spawn(function()
    while task.wait(0.2) do
        if _G.TaiHubActive and not isProcessing and not isHopping then
            local char, hrp = getCharacter()
            if char and hrp then
                local validFruits = GetValidFruitsOnMap()

                if #validFruits > 0 then
                    isProcessing = true
                    local targetData = validFruits[1]

                    FruitLabel.Text = "🔥 Target Locked!"
                    TargetLabel.Text = "🍎 Target: " .. targetData.object.Name

                    local flyResult = SafeTweenToFruit(targetData)
                    if flyResult == "SUCCESS" then
                        PickupAndStoreVerified(targetData)
                        isProcessing = false
                    elseif flyResult == "STOLEN" then
                        blacklistedFruits[targetData.object] = true
                        FruitLabel.Text = "⚠️ Target Gone!"
                        DetailLabel.Text = "🔄 Checking Next Target..."
                        isProcessing = false
                    else
                        isProcessing = false
                    end
                else
                    FruitLabel.Text = "🌐 Map Clean!"
                    TargetLabel.Text = "🍎 Target: None"
                    DetailLabel.Text = "✈️ No fruit found. Hopping..."
                    SmartHopServer()
                end
            end
        end
    end
end)
