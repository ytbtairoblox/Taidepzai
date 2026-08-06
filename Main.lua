-- =================================================================
-- SCRIPT: TAI HUB FIND FRUIT (ULTIMATE EDITION)
-- FIX AUTO PICKUP - ADVANCED API SERVER FILTER - ANTI EXPLOITER SERVER
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
            return char, hrp, hum
        end
    end
    return nil, nil, nil
end

-- AUTO SET TEAM
pcall(function()
    local commF = ReplicatedStorage:WaitForChild("Remotes", 3) and ReplicatedStorage.Remotes:WaitForChild("CommF_", 3)
    if commF then commF:InvokeServer("SetTeam", "Marines") end
end)

-- UI SYSTEM WITH SERVER API DISPLAY
if CoreGui:FindFirstChild("TaiHubFindFruit") then
    CoreGui.TaiHubFindFruit:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TaiHubFindFruit"
ScreenGui.Parent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 260)
MainFrame.Position = UDim2.new(0.5, -170, 0.25, -130)
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
TitleText.Text = "✨ TAI HUB FIND FRUIT (API PRO) ✨"
TitleText.TextColor3 = Color3.fromRGB(245, 208, 75)
TitleText.TextSize = 12
TitleText.Font = Enum.Font.FredokaOne
TitleText.TextXAlignment = Enum.TextXAlignment.Left

-- Container
local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, -20, 0, 170)
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
local ApiLabel = CreateLabel(36, "📡 API Server ID: " .. string.sub(game.JobId, 1, 12) .. "...", Color3.fromRGB(192, 132, 252))
local PlayersOnlineLabel = CreateLabel(54, "👥 Server Players: " .. #Players:GetPlayers() .. " (Target: 1-5)", Color3.fromRGB(74, 222, 128))
local FruitLabel = CreateLabel(72, "🔍 Status: Initializing Engine...", Color3.fromRGB(250, 204, 21))
local DetailLabel = CreateLabel(90, "💡 Action: Scanning Fruits...", Color3.fromRGB(148, 163, 184))
local TargetLabel = CreateLabel(108, "🍎 Target: None", Color3.fromRGB(168, 85, 247))
local StoreAttemptLabel = CreateLabel(126, "📦 Store Attempts: 0", Color3.fromRGB(52, 211, 153))

-- Toggle Button
local ToggleBtn = Instance.new("TextButton", MainFrame)
ToggleBtn.Size = UDim2.new(1, -20, 0, 32)
ToggleBtn.Position = UDim2.new(0, 10, 1, -38)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
ToggleBtn.Text = "⚡ TAI HUB ENGINE: ACTIVE ⚡"
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
local FruitCache = {}
local blacklistedFruits = {}
local currentPing = 0

ToggleBtn.MouseButton1Click:Connect(function()
    _G.TaiHubActive = not _G.TaiHubActive
    if _G.TaiHubActive then
        ToggleBtn.Text = "⚡ TAI HUB ENGINE: ACTIVE ⚡"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
    else
        ToggleBtn.Text = "⛔ TAI HUB ENGINE: PAUSED ⛔"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
        FruitLabel.Text = "⏸️ Status: Paused"
        DetailLabel.Text = "💡 Action: Engine Halted"
        isProcessing = false
        isHopping = false
    end
end)

-- Background Task Loop
task.spawn(function()
    while task.wait(0.3) do
        if _G.TaiHubActive then
            getgenv().TaiHubData.LastActive = os.time()
            local elapsed = os.time() - getgenv().TaiHubData.StartTime
            
            pcall(function()
                currentPing = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            end)

            TimeLabel.Text = string.format("⏳ Elapsed: %02d:%02d:%02d | 📶 Ping: %d ms", math.floor(elapsed/3600), math.floor((elapsed%3600)/60), elapsed%60, currentPing)
            ServerLabel.Text = "🌐 Server Checked: " .. getgenv().TaiHubData.ServerCount
            PlayersOnlineLabel.Text = "👥 Server Players: " .. #Players:GetPlayers() .. " (Target: 1-5)"

            -- Clear Error Prompts
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

-- FRUIT REGISTRATION SYSTEM
local function RegisterFruit(obj)
    if (obj:IsA("Tool") or obj:IsA("Model")) and string.find(obj.Name, "Fruit") and (obj:FindFirstChild("Handle") or obj:FindFirstChildOfClass("Part")) then
        if not blacklistedFruits[obj] and not table.find(FruitCache, obj) then
            table.insert(FruitCache, obj)
        end
    end
end

for _, child in pairs(Workspace:GetChildren()) do RegisterFruit(child) end
Workspace.ChildAdded:Connect(function(child) task.wait(0.1); RegisterFruit(child) end)
Workspace.ChildRemoved:Connect(function(child)
    local idx = table.find(FruitCache, child)
    if idx then table.remove(FruitCache, idx) end
end)

local function GetSortedFruits()
    local validFruits = {}
    for i = #FruitCache, 1, -1 do
        local obj = FruitCache[i]
        local handle = obj and (obj:FindFirstChild("Handle") or obj:FindFirstChildOfClass("Part"))
        if obj and obj.Parent and handle and not blacklistedFruits[obj] then
            table.insert(validFruits, obj)
        else
            table.remove(FruitCache, i)
        end
    end

    local _, hrp = getCharacter()
    if hrp then
        table.sort(validFruits, function(a, b)
            local hA = a:FindFirstChild("Handle") or a:FindFirstChildOfClass("Part")
            local hB = b:FindFirstChild("Handle") or b:FindFirstChildOfClass("Part")
            return (hA.Position - hrp.Position).Magnitude < (hB.Position - hrp.Position).Magnitude
        end)
    end
    return validFruits
end

-- TWEEN TO FRUIT ENGINE
local function SafeLerpTween(targetFruit)
    local handle = targetFruit and (targetFruit:FindFirstChild("Handle") or targetFruit:FindFirstChildOfClass("Part"))
    if not handle then return "STOLEN" end
    local char, hrp, hum = getCharacter()
    if not char then return "ERROR" end

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

        if not targetFruit or not targetFruit.Parent or not (targetFruit:FindFirstChild("Handle") or targetFruit:FindFirstChildOfClass("Part")) then
            if noclipConn then noclipConn:Disconnect() end
            return "STOLEN"
        end

        local currentPos = currentHrp.Position
        local targetPos = handle.Position
        local dist = (targetPos - currentPos).Magnitude

        if dist <= 3 then break end

        local dt = RunService.Heartbeat:Wait()
        local moveStep = math.min(dist, speed * dt)
        local alpha = moveStep / dist

        currentHrp.CFrame = CFrame.new(currentPos:Lerp(targetPos, alpha), targetPos)
        currentHrp.Velocity = Vector3.zero

        DetailLabel.Text = string.format("🚀 Tweening... Distance: %dm", math.floor(dist / 3.57))
    end

    local finalChar, finalHrp = getCharacter()
    if finalHrp and handle then
        finalHrp.CFrame = handle.CFrame * CFrame.new(0, 0.5, 0)
    end

    if noclipConn then noclipConn:Disconnect() end
    return "SUCCESS"
end

-- ULTRA PICKUP & STORE ENGINE (SỬA LỖI ĐỨNG NHÌN)
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

local function DirectForcePickup(fruitObj)
    if not fruitObj then return end
    local char, hrp = getCharacter()
    if not hrp then return end
    local handle = fruitObj:FindFirstChild("Handle") or fruitObj:FindFirstChildOfClass("Part")
    if not handle then return end

    DetailLabel.Text = "🤏 Action: Direct Force Pickup..."

    -- 1. Teleport đè trực tiếp lên Part
    hrp.CFrame = handle.CFrame

    -- 2. Touch Interest
    if firetouchinterest then
        firetouchinterest(hrp, handle, 0)
        task.wait(0.05)
        firetouchinterest(hrp, handle, 1)
    end

    -- 3. ProximityPrompt
    local prompt = fruitObj:FindFirstChildOfClass("ProximityPrompt") or handle:FindFirstChildOfClass("ProximityPrompt")
    if prompt and fireproximityprompt then
        fireproximityprompt(prompt)
    end

    -- 4. Invoke Server pickup nếu có
    pcall(function()
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then
            commF:InvokeServer("PickFruit", fruitObj)
        end
    end)
end

local function PickupAndStoreVerified(fruitObj)
    DirectForcePickup(fruitObj)

    FruitLabel.Text = "📦 Status: Verifying Pickup..."
    local tool = nil
    local checkTime = tick()

    while (tick() - checkTime) < 2.5 do
        tool = GetFruitInInventory()
        if tool then break end
        DirectForcePickup(fruitObj)
        task.wait(0.1)
    end

    if not tool then
        blacklistedFruits[fruitObj] = true
        return
    end

    -- Trang bị trái lên tay
    DetailLabel.Text = "🖐️ Action: Equipping Fruit..."
    local char = getCharacter()
    if char and tool.Parent ~= char then 
        tool.Parent = char 
    end
    task.wait(0.2)

    -- Cất trái vào rương
    FruitLabel.Text = "🔒 Status: Storing Fruit..."
    local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")

    local storeAttempts = 0
    local storeStart = tick()
    
    while tool and tool.Parent and (tick() - storeStart) < 8 do
        storeAttempts = storeAttempts + 1
        StoreAttemptLabel.Text = "📦 Store Attempts: " .. storeAttempts
        DetailLabel.Text = "🔄 Storing " .. tool.Name .. "..."

        if remote then
            remote:InvokeServer("StoreFruit", tool.Name, tool)
        end
        task.wait(0.2)

        if not GetFruitInInventory() then
            FruitLabel.Text = "✅ Store Verified: Success!"
            DetailLabel.Text = "🎉 Fruit stored successfully!"
            task.wait(0.3)
            return
        end
    end

    if GetFruitInInventory() then
        FruitLabel.Text = "⚠️ Store Failed: Inventory Full!"
        blacklistedFruits[fruitObj] = true
    end
end

-- ADVANCED SMART HOP ENGINE (CHỈ SERVER 1-5 NGƯỜI, KHÔNG SERVER LÂU NĂM/HACK)
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
            -- Nhảy ngẫu nhiên trang để chống bị lặp server cũ
            local randomStartPage = math.random(1, 5)
            
            for page = 1, 12 do
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
                                
                                -- ĐIỀU KIỆN LỌC SERVER NGHIÊM NGẶT:
                                -- 1. Không trùng server hiện tại & Chưa vào bao giờ
                                -- 2. Số người chơi ĐÚNG TỪ 1 ĐẾN 5 NGƯỜI
                                -- 3. Ping ổn định (Tránh server giật/lag cày nát)
                                if server.id ~= game.JobId 
                                   and not getgenv().TaiHubData.BlacklistedServers[server.id] 
                                   and playing >= 1 and playing <= 5 then
                                    
                                    table.insert(validCandidateServers, { id = server.id, playing = playing })
                                end
                            end
                        end
                    end
                end
                
                if #validCandidateServers >= 4 then break end
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
            DetailLabel.Text = "🌐 Target API Server: [" .. targetPlayerCount .. " Players]"
            ApiLabel.Text = "📡 Next Server: " .. string.sub(targetServerId, 1, 12) .. "..."
            task.wait(0.3)
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

    task.delay(10, function()
        isHopping = false
        isProcessing = false
    end)
end

-- MAIN AUTOMATION LOOP
task.spawn(function()
    while task.wait(0.2) do
        if _G.TaiHubActive and not isProcessing and not isHopping then
            local char, hrp = getCharacter()
            if char and hrp then
                local sortedFruits = GetSortedFruits()

                if #sortedFruits > 0 then
                    isProcessing = true
                    local target = sortedFruits[1]

                    FruitLabel.Text = "🔥 Status: Target Locked!"
                    TargetLabel.Text = "🍎 Target: " .. target.Name

                    task.wait(0.05)
                    local handle = target and (target:FindFirstChild("Handle") or target:FindFirstChildOfClass("Part"))
                    if not target or not target.Parent or not handle then
                        isProcessing = false
                    else
                        local result = SafeLerpTween(target)

                        if result == "SUCCESS" then
                            PickupAndStoreVerified(target)
                            task.wait(0.2)
                            isProcessing = false
                        elseif result == "STOLEN" then
                            FruitLabel.Text = "⚠️ Target Disappeared!"
                            DetailLabel.Text = "🔄 Hop Server..."
                            task.wait(0.2)
                            SmartHopServer()
                        else
                            isProcessing = false
                        end
                    end
                else
                    FruitLabel.Text = "🌐 Status: Map Clean!"
                    TargetLabel.Text = "🍎 Target: None"
                    DetailLabel.Text = "✈️ No fruit in map. Hopping..."
                    SmartHopServer()
                end
            end
        end
    end
end)
