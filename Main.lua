-- =================================================================
-- SCRIPT: TAI HUB FIND FRUIT (PERFECT EDITION)
-- STRICT 1-5 PLAYERS - ANTI LOOP SAME SERVER - ANTI EXPLOITER SERVER
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

-- QUẢN LÝ CONNECTIONS & GC
local GC_Connections = {}
local function AddConnection(conn)
    table.insert(GC_Connections, conn)
    return conn
end

-- 1. QUEUE ON TELEPORT (TỰ RE-EXECUTE KHI HOP)
local queue_on_teleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
if queue_on_teleport and getgenv().TaiHubScriptSource then
    queue_on_teleport([[
        repeat task.wait() until game:IsLoaded()
        ]] .. getgenv().TaiHubScriptSource .. [[
    ]])
end

-- 2. HÀM LẤY CHARACTER CHUẨN XÁC & AN TOÀN
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

-- 3. CHỌN PHE NGAY LẬP TỨC
pcall(function()
    local commF = ReplicatedStorage:WaitForChild("Remotes", 3) and ReplicatedStorage.Remotes:WaitForChild("CommF_", 3)
    if commF then commF:InvokeServer("SetTeam", "Marines") end
end)

-- 4. GIAO DIỆN DEBUG UI - TAI HUB FIND FRUIT
if CoreGui:FindFirstChild("TaiHubFindFruit") then
    CoreGui.TaiHubFindFruit:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TaiHubFindFruit"
ScreenGui.Parent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 220)
MainFrame.Position = UDim2.new(0.5, -160, 0.3, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 22)
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
Header.BackgroundColor3 = Color3.fromRGB(22, 22, 34)
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

-- Debug Container
local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, -20, 0, 130)
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
local FruitLabel = CreateLabel(36, "🔍 Status: Initializing Cache...", Color3.fromRGB(250, 204, 21))
local DetailLabel = CreateLabel(54, "💡 Action: Standby", Color3.fromRGB(148, 163, 184))
local TargetLabel = CreateLabel(72, "🍎 Target: None", Color3.fromRGB(168, 85, 247))
local StoreAttemptLabel = CreateLabel(90, "📦 Store Attempts: 0", Color3.fromRGB(52, 211, 153))

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

-- UI Dragging
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

-- 5. BỘ ĐẾM VÀ BLACKLIST DATA LƯU GIỮ BỀN VỮNG
local RESET_TIMEOUT = 7200 -- 2 tiếng mới xóa bớt cache server cũ
if not getgenv().TaiHubData then
    getgenv().TaiHubData = { ServerCount = 1, StartTime = os.time(), LastActive = os.time(), BlacklistedServers = {} }
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

-- Đưa server hiện tại vào Blacklist ngay lập tức để không bao giờ bị hop lại
getgenv().TaiHubData.BlacklistedServers[game.JobId] = true

local function AddServerToBlacklist(jobId)
    if jobId then
        getgenv().TaiHubData.BlacklistedServers[jobId] = true
    end
end

_G.TaiHubActive = true
local isProcessing = false
local isHopping = false
local FruitCache = {}
local blacklistedFruits = {}
local currentPing = 0

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

-- Background Task Loop (Auto Dismiss Error Prompt & Sync)
AddConnection(task.spawn(function()
    while task.wait(0.3) do
        if _G.TaiHubActive then
            getgenv().TaiHubData.LastActive = os.time()
            local elapsed = os.time() - getgenv().TaiHubData.StartTime
            
            pcall(function()
                currentPing = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            end)

            TimeLabel.Text = string.format("⏳ Elapsed: %02d:%02d:%02d | 📶 Ping: %d ms", math.floor(elapsed/3600), math.floor((elapsed%3600)/60), elapsed%60, currentPing)
            ServerLabel.Text = "🌐 Server Checked: " .. getgenv().TaiHubData.ServerCount

            -- TỰ ĐỘNG BỎ POPUP LỖI KẾT NỐI MÃ LỖI 2
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
                                local btn = buttonArea:FindFirstChildOfClass("TextButton")
                                if btn then
                                    GuiService.SelectedObject = btn
                                    task.wait(0.05)
                                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end))

-- 6. EVENT-BASED FRUIT CACHE SYSTEM
local function RegisterFruit(obj)
    if (obj:IsA("Tool") or obj:IsA("Model")) and string.find(obj.Name, "Fruit") and obj:FindFirstChild("Handle") then
        if not blacklistedFruits[obj] and not table.find(FruitCache, obj) then
            table.insert(FruitCache, obj)
        end
    end
end

for _, child in pairs(Workspace:GetChildren()) do RegisterFruit(child) end

AddConnection(Workspace.ChildAdded:Connect(function(child)
    task.wait(0.1)
    RegisterFruit(child)
end))

AddConnection(Workspace.ChildRemoved:Connect(function(child)
    local idx = table.find(FruitCache, child)
    if idx then table.remove(FruitCache, idx) end
end))

local function GetSortedFruits()
    local validFruits = {}
    for i = #FruitCache, 1, -1 do
        local obj = FruitCache[i]
        if obj and obj.Parent and obj:FindFirstChild("Handle") and not blacklistedFruits[obj] then
            table.insert(validFruits, obj)
        else
            table.remove(FruitCache, i)
        end
    end

    local _, hrp = getCharacter()
    if hrp then
        local hrpPos = hrp.Position
        table.sort(validFruits, function(a, b)
            return (a.Handle.Position - hrpPos).Magnitude < (b.Handle.Position - hrpPos).Magnitude
        end)
    end
    return validFruits
end

-- 7. DIRECT LERP TWEEN ENGINE (BAY THẲNG TRỰC TIẾP TỚI TRÁI CÂY)
local function SafeLerpTween(targetFruit)
    if not targetFruit or not targetFruit:FindFirstChild("Handle") then return "STOLEN" end
    local char, hrp, hum = getCharacter()
    if not char then return "ERROR" end

    local noclipConn = AddConnection(RunService.Stepped:Connect(function()
        local c = getCharacter()
        if c then
            for _, partName in pairs({"HumanoidRootPart", "UpperTorso", "LowerTorso", "Head"}) do
                local p = c:FindFirstChild(partName)
                if p then p.CanCollide = false end
            end
        end
    end))

    local speed = 300

    while true do
        local currentChar, currentHrp, currentHum = getCharacter()
        if not currentChar or not currentHrp then
            if noclipConn then noclipConn:Disconnect() end
            return "RESET"
        end

        if not _G.TaiHubActive then
            if noclipConn then noclipConn:Disconnect() end
            return "CANCEL"
        end

        if not targetFruit or not targetFruit.Parent or not targetFruit:FindFirstChild("Handle") then
            if noclipConn then noclipConn:Disconnect() end
            return "STOLEN"
        end

        local currentPos = currentHrp.Position
        local currentTargetPos = targetFruit.Handle.Position
        local dist = (currentTargetPos - currentPos).Magnitude

        if dist <= 5 then break end

        local dt = RunService.Heartbeat:Wait()
        local moveStep = math.min(dist, speed * dt)
        local alpha = moveStep / dist

        local nextPos = currentPos:Lerp(currentTargetPos, alpha)
        currentHrp.CFrame = CFrame.new(nextPos, currentTargetPos)
        currentHrp.Velocity = Vector3.zero
        if currentHum then currentHum:ChangeState(Enum.HumanoidStateType.Freefall) end

        local displayDist = math.floor(dist / 3.57)
        DetailLabel.Text = string.format("🚀 Tweening... Distance: %dm", displayDist)
    end

    local finalChar, finalHrp = getCharacter()
    if finalHrp and targetFruit and targetFruit:FindFirstChild("Handle") then
        finalHrp.CFrame = targetFruit.Handle.CFrame
    end

    if noclipConn then noclipConn:Disconnect() end
    return "SUCCESS"
end

-- 8. OPTIMIZED ESP ENGINE
local activeESPFolder = Instance.new("Folder", ScreenGui)
activeESPFolder.Name = "FruitESPs"
local espTable = {}

AddConnection(task.spawn(function()
    while task.wait(0.2) do
        if not _G.TaiHubActive then
            activeESPFolder:ClearAllChildren()
            espTable = {}
        else
            for _, obj in pairs(FruitCache) do
                if obj and obj.Parent and obj:FindFirstChild("Handle") and not blacklistedFruits[obj] then
                    if not espTable[obj] then
                        local esp = Instance.new("BillboardGui")
                        esp.Name = obj:GetDebugId()
                        esp.Size = UDim2.new(0, 180, 0, 35)
                        esp.AlwaysOnTop = true
                        esp.Adornee = obj.Handle
                        esp.Parent = activeESPFolder

                        local txt = Instance.new("TextLabel", esp)
                        txt.Name = "ESPText"
                        txt.Size = UDim2.new(1, 0, 1, 0)
                        txt.BackgroundTransparency = 1
                        txt.TextColor3 = Color3.fromRGB(52, 211, 153)
                        txt.TextStrokeTransparency = 0
                        txt.TextSize = 12
                        txt.Font = Enum.Font.SourceSansBold

                        espTable[obj] = { Gui = esp, TextLabel = txt }
                    end
                else
                    if espTable[obj] then
                        if espTable[obj].Gui then espTable[obj].Gui:Destroy() end
                        espTable[obj] = nil
                    end
                end
            end
        end
    end
end))

AddConnection(RunService.RenderStepped:Connect(function()
    if not _G.TaiHubActive then return end
    local _, hrp = getCharacter()
    if not hrp then return end

    for obj, data in pairs(espTable) do
        if obj and obj.Parent and obj:FindFirstChild("Handle") and data.TextLabel then
            local dist = math.floor((hrp.Position - obj.Handle.Position).Magnitude / 3.57)
            data.TextLabel.Text = "🍎 " .. obj.Name .. "\n[" .. dist .. "m]"
        end
    end
end))

-- 9. PICKUP FALLBACK & VERIFIED BLOX FRUITS STORE
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

local function UniversalPickup(fruitObj)
    if not fruitObj or not fruitObj:FindFirstChild("Handle") then return end
    local char, hrp = getCharacter()
    if not hrp then return end
    local handle = fruitObj.Handle

    DetailLabel.Text = "🤏 Action: Universal Pickup..."

    if firetouchinterest then
        firetouchinterest(hrp, handle, 0)
        task.wait(0.02)
        firetouchinterest(hrp, handle, 1)
    end

    local prompt = fruitObj:FindFirstChildOfClass("ProximityPrompt") or handle:FindFirstChildOfClass("ProximityPrompt")
    if prompt and fireproximityprompt then
        fireproximityprompt(prompt)
    end

    hrp.CFrame = handle.CFrame
end

local function PickupAndStoreVerified(fruitObj)
    UniversalPickup(fruitObj)

    FruitLabel.Text = "📦 Status: Verifying Pickup..."
    local tool = nil
    local checkTime = tick()

    while (tick() - checkTime) < 3 do
        tool = GetFruitInInventory()
        if tool then break end
        task.wait(0.05)
    end

    if not tool then
        blacklistedFruits[fruitObj] = true
        return
    end

    DetailLabel.Text = "🖐️ Action: Equipping Tool..."
    local char = getCharacter()
    if char then tool.Parent = char end
    task.wait(0.15)

    FruitLabel.Text = "🔒 Status: Lock-Storing Fruit..."
    local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")

    local storeAttempts = 0
    local storeStart = tick()
    
    while tool and tool.Parent and (tick() - storeStart) < 10 do
        storeAttempts = storeAttempts + 1
        StoreAttemptLabel.Text = "📦 Store Attempts: " .. storeAttempts
        DetailLabel.Text = "🔄 Store " .. tool.Name .. " (" .. storeAttempts .. ")..."

        if remote then
            remote:InvokeServer("StoreFruit", tool.Name, tool)
        end
        task.wait(0.15)

        local currentTool = GetFruitInInventory()
        if not currentTool then
            FruitLabel.Text = "✅ Store Verified: Success!"
            DetailLabel.Text = "🎉 Fruit stored to Inventory!"
            task.wait(0.3)
            return
        end
    end

    if GetFruitInInventory() then
        FruitLabel.Text = "⚠️ Store Failed: Inventory Full!"
        blacklistedFruits[fruitObj] = true
    end
end

-- 10. SMART HOP SERVER ENGINE (CHỈ CHỌN SERVER 1 - 5 NGƯỜI, CHỐNG LẶP SỐ 1)
local function SmartHopServer()
    if not _G.TaiHubActive or isHopping then return end
    isHopping = true
    isProcessing = true

    AddServerToBlacklist(game.JobId)
    FruitLabel.Text = "✈️ Status: Searching Server (1-5 Players)..."

    local function AttemptHop()
        local targetServerId = nil
        local targetPlayerCount = 0
        local cursor = ""
        local validCandidateServers = {}

        pcall(function()
            -- Quét ngẫu nhiên sâu hơn để bỏ qua server cũ
            for page = 1, 10 do
                if not _G.TaiHubActive then break end
                local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100" .. (cursor ~= "" and ("&cursor=" .. cursor) or "")
                local rawData = game:HttpGet(url)
                if rawData then
                    local decoded = HttpService:JSONDecode(rawData)
                    if decoded and decoded.data then
                        cursor = decoded.nextPageCursor or ""
                        for _, server in pairs(decoded.data) do
                            local playing = server.playing or 0
                            
                            -- ĐIỀU KIỆN LỌC NGHIÊM NGẶT:
                            -- 1. Không trùng server hiện tại
                            -- 2. Chưa từng bị lưu trong Blacklist
                            -- 3. Số người chơi CHUẨN TỪ 1 ĐẾN 5 NGƯỜI
                            if server.id ~= game.JobId 
                               and not getgenv().TaiHubData.BlacklistedServers[server.id] 
                               and playing >= 1 and playing <= 5 then
                                
                                table.insert(validCandidateServers, { id = server.id, playing = playing })
                            end
                        end
                    end
                end
                
                -- Tìm thấy đủ danh sách ứng viên thì ngắt quét ngay
                if #validCandidateServers >= 3 then break end
                task.wait(0.05)
            end
        end)

        -- Chọn ngẫu nhiên 1 trong các server đạt tiêu chuẩn để tránh trùng lặp
        if #validCandidateServers > 0 then
            local chosen = validCandidateServers[math.random(1, #validCandidateServers)]
            targetServerId = chosen.id
            targetPlayerCount = chosen.playing
            AddServerToBlacklist(targetServerId)
        end

        if targetServerId and _G.TaiHubActive then
            FruitLabel.Text = "✈️ Status: Initiating Teleport..."
            DetailLabel.Text = "🌐 Target Server: [" .. targetPlayerCount .. " Players]"
            task.wait(0.3)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServerId, LocalPlayer)
            return true
        end
        return false
    end

    local teleportConn
    teleportConn = AddConnection(TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
        if player == LocalPlayer then
            DetailLabel.Text = "❌ Teleport Failed! Retrying hop..."
            task.wait(1)
            AttemptHop()
        end
    end))

    local success = AttemptHop()
    if not success and _G.TaiHubActive then
        DetailLabel.Text = "⚠️ Searching deep fallback server..."
        task.wait(0.5)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end

    task.delay(10, function()
        if teleportConn then teleportConn:Disconnect() end
        isHopping = false
        isProcessing = false
    end)
end

-- 11. MAIN AUTOMATION ENGINE LOOP
AddConnection(task.spawn(function()
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
                    if not target or not target.Parent or not target:FindFirstChild("Handle") then
                        isProcessing = false
                    else
                        local result = SafeLerpTween(target)

                        if result == "SUCCESS" then
                            PickupAndStoreVerified(target)
                            task.wait(0.2)
                            isProcessing = false
                        elseif result == "STOLEN" then
                            FruitLabel.Text = "⚠️ Target Disappeared!"
                            DetailLabel.Text = "🔄 Triggering Server Hop..."
                            task.wait(0.2)
                            SmartHopServer()
                        else
                            isProcessing = false
                        end
                    end
                else
                    FruitLabel.Text = "🌐 Status: Map Clean!"
                    TargetLabel.Text = "🍎 Target: None"
                    DetailLabel.Text = "✈️ No fruit in Map. Hopping..."
                    SmartHopServer()
                end
            end
        end
    end
end))
