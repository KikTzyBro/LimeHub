loadstring(game:HttpGet("https://sdkapi-public.luarmor.net/library.lua"))()
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
loadstring([[
    function LPH_NO_VIRTUALIZE(f) return f end;
]])();

local Window = WindUI:CreateWindow({
    Title = "LimeHub",
    Icon = "rbxassetid://88791594299566",
    Author = "Fish It",
    Folder = "LimeHub",
    Size = UDim2.fromOffset(380, 260),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    Background = "",
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    User = {
        Enabled = false,
        Anonymous = false,
        Callback = function()
        end,
    },
})

Window:EditOpenButton({ Enabled = false })
Window:SetToggleKey(nil)

local LimeHub = Instance.new('ScreenGui')
local Button = Instance.new('ImageButton')
local Corner = Instance.new('UICorner')
local Scale = Instance.new('UIScale')

LimeHub.Name = 'LimeHubButton'
LimeHub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
LimeHub.ResetOnSpawn = false
LimeHub.Parent = game:GetService('CoreGui')

Button.Name = 'LimeHub'
Button.Parent = LimeHub
Button.BackgroundTransparency = 1
Button.Size = UDim2.new(0, 50, 0, 50)
Button.Position = UDim2.new(1, -70, 1, -70)
Button.Image = 'rbxassetid://88791594299566'
Button.Draggable = true

Corner.CornerRadius = UDim.new(1, 0)
Corner.Parent = Button
Scale.Scale = 1
Scale.Parent = Button

local TweenService = game:GetService("TweenService")
Button.MouseEnter:Connect(function()
    TweenService:Create(Scale, TweenInfo.new(0.1), { Scale = 1.2 }):Play()
end)
Button.MouseLeave:Connect(function()
    TweenService:Create(Scale, TweenInfo.new(0.1), { Scale = 1 }):Play()
end)

local isWindowOpen = true
Button.MouseButton1Click:Connect(function()
    if isWindowOpen then
        Window:Close()
    else
        Window:Open()
    end
    isWindowOpen = not isWindowOpen
end)

Window:OnDestroy(function()
    if LimeHub then
        LimeHub:Destroy()
    end
end)

local globalsToReset = {
    "DelayWebhook",
    "AutoFavorite",
    "OneClickMode",
    "AutoFish",
    "TeleportEvent",
    "WebhookURL",
    "AutoFav",
    "AutoSell",
    "Radar",
    "Oxygen",
    "TargetEnchant",
    "AutoEnchant",
    "WaterPlatformEnabled",
    "InfJumpEnabled",
    "InputWalkSpeed",
    "DetectNewFishActive",
    "WebhookRarities",
    "selectedEvent",
    "selectedLocation",
    "AutoSellDelay",
    "Wurl",
    "BoostFPS"
}

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local folderPath = "LimeHub"
makefolder(folderPath)

function GetConfigFileName()
    local player = Players.LocalPlayer
    if player then
        return folderPath .. "/Fish It_" .. player.Name .. ".json"
    else
        return folderPath .. "/Fish It_Default.json"
    end
end

if not _G.Settings then
    _G.Settings = {}
end

if _G.Settings.AutoSave == nil then
    _G.Settings.AutoSave = true
end

function SaveConfig()
    local configFile = GetConfigFileName()
    local data = {}
    for _, key in ipairs(globalsToReset) do
        data[key] = _G[key]
    end
    data["AutoSave"] = _G.Settings.AutoSave
    data["PlayerName"] = Players.LocalPlayer and Players.LocalPlayer.Name or "Unknown"
    
    local success, result = pcall(function()
        return HttpService:JSONEncode(data)
    end)
    if success then
        writefile(configFile, result)
    end
end

function LoadConfig()
    local configFile = GetConfigFileName()
    if isfile(configFile) then
        local data = readfile(configFile)
        local success, result = pcall(function()
            return HttpService:JSONDecode(data)
        end)
        if success and type(result) == "table" then
            for k, v in pairs(result) do
                if k == "AutoSave" then
                    _G.Settings.AutoSave = v
                else
                    _G[k] = v
                end
            end
        end
    else
        SaveConfig()
    end
end

LoadConfig()

local Players = game:GetService("Players")
local RepStorage = game:GetService("ReplicatedStorage")
local player = game.Players.LocalPlayer

local Discord = Window:Tab({ Title = "Discord", Icon = "badge-alert" })
local Exclusive = Window:Tab({ Title = "Exclusive", Icon = "star" })
local Main = Window:Tab({ Title = "Main", Icon = "landmark" })
local Quest = Window:Tab({ Title = "Quest", Icon = "rbxassetid://10723415335" })
local Trade = Window:Tab({ Title = "Trade", Icon = "navigation" })
local Teleport = Window:Tab({ Title = "Teleport", Icon = "scan-barcode" })
local Shop = Window:Tab({ Title = "Shop", Icon = "store" })
local ConfigTab = Window:Tab({ Title = "Config", Icon = "file-cog" })
local Misc = Window:Tab({ Title = "Misc", Icon = "settings" })

Discord:Section({ Title = "Join Discord Server" })
Discord:Button({
    Title = "Discord Invite",
    Desc = "Copy Invite Link",
    Locked = false,
    Callback = function()
        setclipboard("https://discord.gg/qZuB7sYdYB")
        WindUI:Notify({
            Title = "LimeHub Notify",
            Icon = "rbxassetid://88791594299566",
            Content = "✅ Link Copied!",
            Duration = 4
        })
    end
})

Exclusive:Section({ Title = "One Click Mode / Kaitun" })
Exclusive:Paragraph({
    Title = "Announcement",
    Desc = "This Feature Will Automatically Progress Through The Fishing Journey. "
           .. "Begins By Farming Coins At Kohana Volcano. "
           .. "Then Purchasing Rods Up To The Astral Rod. "
           .. "Unlocks And Starts The Ghostfin Rod Quest. "
           .. "Simultaneously Acquires All Baits Up To The Aether Bait. "
           .. "It Will Auto Get All Rods & All Baits."
})
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local PlayerGui = player:WaitForChild("PlayerGui")

local Net = require(ReplicatedStorage.Packages.Net)
local SellAllItems = Net:RemoteFunction("SellAllItems")
local FavoriteItem = Net:RemoteEvent("FavoriteItem")
local fishingController = require(ReplicatedStorage.Controllers.FishingController)
local ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)
local Client = require(ReplicatedStorage.Packages.Replion).Client
local dataStore = Client:WaitReplion("Data")
local CancelFishingInputs = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/CancelFishingInputs")


_G.DelayWebhook = 1

local START_CFRAME = CFrame.new(
    -591.781494, 40.6086769, 149.605621,
    -0.690379977, 1.43661989e-08, -0.723446965,
    -2.95755296e-08, 1, 4.8081688e-08,
    0.723446965, 5.45909629e-08, -0.690379977
)

local BEST_FISHING_CFRAME = CFrame.new(
    -3741.23804, -135.074417, -1008.8219,
    -0.983854651, -5.2231119e-08, -0.178969383,
    -4.4131955e-08, 1, -4.92357373e-08,
    0.178969383, -4.05425382e-08, -0.983854651
)

local deepSeaTracker = workspace["!!! MENU RINGS"]["Deep Sea Tracker"].Board.Gui.Content
local label2 = deepSeaTracker.Label2
local label3 = deepSeaTracker.Label3

local SPECIAL_CFRAME = CFrame.new(
    -3576.43896, -281.441864, -1652.00879,
    -0.986065865, 6.27356229e-08, -0.166355252,
    4.83395013e-08, 1, 9.0587406e-08,
    0.166355252, 8.12836234e-08, -0.986065865
)

local lastHookCall = tick()
local originalFishCaught = fishingController.FishCaught
fishingController.FishCaught = function(...)
  if _G.OneClickMode then
    lastHookCall = tick()
  end
    return originalFishCaught(...)
end

local FishingRods = {
    ["Carbon Rod"] = {id = 76, price = 900},
    ["Demascus Rod"] = {id = 77, price = 3000},
    ["Lucky Rod"] = {id = 4, price = 15000},
    ["Midnight Rod"] = {id = 80, price = 50000},
    ["Astral Rod"] = {id = 5, price = 1000500},    
}

function getRodUUID(rodId)
    local inventory = dataStore:Get("Inventory")
    if not inventory or not inventory["Fishing Rods"] then return nil end
    for _, rod in ipairs(inventory["Fishing Rods"]) do
        if rod.Id == rodId then
            return rod.UUID
        end
    end
    return nil
end

function getBestRod()
    local inventory = dataStore:Get("Inventory")
    local bestRodName, bestPrice = nil, 0
    if inventory and inventory["Fishing Rods"] then
        for _, rod in ipairs(inventory["Fishing Rods"]) do
            for name, info in pairs(FishingRods) do
                if rod.Id == info.id and info.price > bestPrice then
                    bestPrice = info.price
                    bestRodName = name
                end
            end
        end
    end
    return bestRodName
end

function teleportBasedOnCondition(bestRod)
    local bestRod = getBestRod()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    local isLabel2Done = label2.Text:match("100%%") ~= nil
    local isLabel3Done = label3.Text:match("100%%") ~= nil

    if isLabel2Done and isLabel3Done then
        hrp.CFrame = SPECIAL_CFRAME
    elseif bestRod == "Astral Rod" then
        hrp.CFrame = BEST_FISHING_CFRAME
    else
        hrp.CFrame = START_CFRAME
    end
end

function initialTeleport()
    if not _G.HasTeleported then
        _G.HasTeleported = true
        teleportBasedOnCondition(getBestRod())
        wait(2)
    end
end

spawn( LPH_NO_VIRTUALIZE( function()
    while true do
        task.wait(0.1)
        if _G.OneClickMode then
            initialTeleport()
            
            local char = workspace:FindFirstChild("Characters"):FindFirstChild(player.Name)
            if char then
                repeat
                    task.wait(0.1)
                    if char:FindFirstChild("!!!FISHING_VIEW_MODEL!!!") then
                        pcall(function()
                            ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/EquipToolFromHotbar"]:FireServer(1)
                        end)
                    end
                    task.wait(0.1)
                    local cosmeticFolder = workspace:FindFirstChild("CosmeticFolder")
                    if cosmeticFolder and not cosmeticFolder:FindFirstChild(tostring(player.UserId)) then
                        pcall(function()
                            ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/ChargeFishingRod"]:InvokeServer(1756818911.281488)
                        end)
                        task.wait(0.2)
                        pcall(function()
                            ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/RequestFishingMinigameStarted"]:InvokeServer(-1.25, 1)
                        end)
                    end
                until not _G.OneClickMode
            end
        else
            _G.HasTeleported = false
        end
    end
end))

spawn( LPH_NO_VIRTUALIZE( function()
    while task.wait(0.1) do
        if _G.OneClickMode then
            repeat
                task.wait(0.2)
                pcall(function()
                    ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FishingCompleted"]:FireServer()
                end)
            until not _G.OneClickMode
        end
    end
end))

spawn( LPH_NO_VIRTUALIZE( function()
    while true do
        task.wait(5)
        if _G.OneClickMode then
            pcall(function()
                SellAllItems:InvokeServer()
            end)
        end
    end
end))

function autoFavoriteByTier()
    local inventory = dataStore:Get("Inventory")
    if not inventory then return end
    for _, category in pairs(inventory) do
        if type(category) == "table" then
            for _, item in ipairs(category) do
                if type(item) == "table" and item.Id then
                    local itemData = ItemUtility:GetItemData(item.Id)
                    if itemData and itemData.Data then
                        local tier = itemData.Data.Tier or 1
                        local rarity = "Unknown"
                        if tier == 1 then rarity = "Common"
                        elseif tier == 2 then rarity = "Uncommon"
                        elseif tier == 3 then rarity = "Rare"
                        elseif tier == 4 then rarity = "Epic"
                        elseif tier == 5 then rarity = "Legend"
                        elseif tier == 6 then rarity = "Mythic"
                        elseif tier == 7 then rarity = "Secret" end

                        if table.find(_G.AutoFavorite, rarity) and not item.Favorited then
                            pcall(function()
                                FavoriteItem:FireServer(item.UUID or item.Id)
                            end)
                            task.wait(0.2)
                        end
                    end
                end
            end
        end
    end
end

spawn( LPH_NO_VIRTUALIZE( function()
    while true do
        task.wait(0.2)
        if _G.OneClickMode and #_G.AutoFavorite > 0 then
            autoFavoriteByTier()
        end
    end
end))

spawn( LPH_NO_VIRTUALIZE( function()
    while true do
        task.wait(5)
        if _G.OneClickMode then
            local success, coins = pcall(function()
                return dataStore:Get("Coins")
            end)
            if not success or not coins then coins = 0 end

            for name, rod in pairs(FishingRods) do
                local uuid = getRodUUID(rod.id)
                if not uuid and coins >= rod.price then
                    _G.OneClickMode = false
                    _G.HasTeleported = false
                    local char = workspace:FindFirstChild("Characters"):FindFirstChild(player.Name)
                    if char then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then hum.Health = 0 end
                        task.wait(5)
                        pcall(function()
                            ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/PurchaseFishingRod"):InvokeServer(rod.id)
                        end)
                        task.wait(0.5)
                        local newUUID = getRodUUID(rod.id)
                        if newUUID then
                            pcall(function()
                                ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/EquipItem"]:FireServer(newUUID, "Fishing Rods")
                            end)
                        end
                        teleportBasedOnCondition(getBestRod())
                        task.wait(0.5)
                        _G.OneClickMode = true
                        break
                    end
                end
            end
        end
    end
end))

local Baits = {
    [10] = {name = "Topwater Bait", price = 100},
    [2]  = {name = "Luck Bait", price = 1000},
    [3]  = {name = "Midnight Bait", price = 3000},
    [15] = {name = "Corrupt Bait", price = 1150000},
    [16] = {name = "Aether Bait", price = 3700000},
}

function hasBait(baitId)
    local inventory = dataStore:Get("Inventory")
    if not inventory or not inventory.Baits then return false end
    for _, b in ipairs(inventory.Baits) do
        if b.Id == baitId then
            return true
        end
    end
    return false
end

function buyBait(baitId)
    local args = {baitId}
    pcall(function()
        ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseBait"]:InvokeServer(unpack(args))
    end)
end

function equipBait(baitId)
    local args = {baitId}
    pcall(function()
        ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/EquipBait"]:FireServer(unpack(args))
    end)
end

spawn( LPH_NO_VIRTUALIZE( function()
    while true do
        task.wait(5)
        if _G.OneClickMode then
            local coins = 0
            pcall(function()
                coins = dataStore:Get("Coins") or 0
            end)

            for baitId, bait in pairs(Baits) do
                if not hasBait(baitId) and coins >= bait.price then
                    _G.OneClickMode = false
                    _G.HasTeleported = false
                    local char = workspace:FindFirstChild("Characters"):FindFirstChild(player.Name)
                    if char then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then hum.Health = 0 end
                        task.wait(5)
                        buyBait(baitId)
                        task.wait(0.5)
                        equipBait(baitId)
                        teleportBasedOnCondition(getBestRod())
                        task.wait(0.5)
                        _G.OneClickMode = true
                        break
                    end
                end
            end
        end
    end
end))

spawn( LPH_NO_VIRTUALIZE( function()
    while true do
        task.wait(1)
        if _G.OneClickMode then
          repeat
          wait(0.2)
            local char = workspace:FindFirstChild("Characters"):FindFirstChild(player.Name)
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hum and hrp and tick() - lastHookCall > 15 then
                _G.OneClickMode = false
                _G.HasTeleported = false
                hum.Health = 0
                task.wait(5)
                char = workspace:FindFirstChild("Characters"):FindFirstChild(player.Name)
                if char and char:FindFirstChild("HumanoidRootPart") then
                    teleportBasedOnCondition(getBestRod())
                    task.wait(0.5)
                    _G.OneClickMode = true
                end
                lastHookCall = tick()
            end
           until not _G.OneClickMode
        else
            lastHookCall = tick()
        end
    end
end))

local wurl = _G.Wurl
local sendEnabled = false
local lastSend = 0

function getBestRod()
    local inventory = dataStore:Get("Inventory")
    if not inventory or not inventory["Fishing Rods"] then return "None" end
    local best, bestPrice = nil, 0
    local rodPrices = {
        [76] = {"Carbon Rod", 900},
        [77] = {"Demascus Rod", 3000},
        [4]  = {"Lucky Rod", 15000},
        [80] = {"Midnight Rod", 50000},
        [5]  = {"Astral Rod", 1000500},
    }
    for _, rod in ipairs(inventory["Fishing Rods"]) do
        local info = rodPrices[rod.Id]
        if info and info[2] > bestPrice then
            bestPrice = info[2]
            best = info[1]
        end
    end
    return best or "None"
end

function getBestBait()
    local inventory = dataStore:Get("Inventory")
    if not inventory or not inventory.Baits then return "None" end
    local best, bestPrice = nil, 0
    local baitPrices = {
        [10] = {"Topwater Bait", 100},
        [2]  = {"Luck Bait", 1000},
        [3]  = {"Midnight Bait", 3000},
        [15] = {"Corrupt Bait", 1150000},
        [16] = {"Aether Bait", 3700000},
    }
    for _, bait in ipairs(inventory.Baits) do
        local info = baitPrices[bait.Id]
        if info and info[2] > bestPrice then
            bestPrice = info[2]
            best = info[1]
        end
    end
    return best or "None"
end

function getCoins()
    local success, coins = pcall(function()
        return dataStore:Get("Coins")
    end)
    return (success and coins) or 0
end

function getFishCounts()
    local inventory = dataStore:Get("Inventory")
    local counts = {Common=0, Uncommon=0, Rare=0, Epic=0, Legendary=0, Mythical=0, Secret=0}

    if not inventory then return counts end

    for _, category in pairs(inventory) do
        if type(category) == "table" then
            for _, item in ipairs(category) do
                if item.Id then
                    local itemData = ItemUtility:GetItemData(item.Id)
                    if itemData and itemData.Data and itemData.Data.Type == "Fishes" then
                        local tier = itemData.Data.Tier or 1
                        if tier == 1 then counts.Common += 1
                        elseif tier == 2 then counts.Uncommon += 1
                        elseif tier == 3 then counts.Rare += 1
                        elseif tier == 4 then counts.Epic += 1
                        elseif tier == 5 then counts.Legendary += 1
                        elseif tier == 6 then counts.Mythical += 1
                        elseif tier == 7 then counts.Secret += 1
                        end
                    end
                end
            end
        end
    end
    return counts
end

function getGhostfinnProgress()
    local progressTexts = {}
    
    pcall(function()
        local tracker = Workspace["!!! MENU RINGS"]["Deep Sea Tracker"].Board.Gui.Content
        for i = 1, 4 do
            local label = tracker:FindFirstChild("Label" .. i)
            if label and label:IsA("TextLabel") then
                table.insert(progressTexts, label.Text)
            end
        end
    end)
    
    return progressTexts
end

local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

function isValidWebhookURL(url)
    return string.find(url, "discord%.com") and string.find(url, "webhook")
end

function testWebhook(url)
    if not isValidWebhookURL(url) then
        return false
    end
    
    local testData = {
        content = "",
        embeds = {{
            title = "🎣 LimeHub Webhook Test",
            color = 0x00FF00,
            description = "Webhook success activated!",
            footer = {text = "Test • "..os.date("%X")}
        }}
    }
    
    local jsonData = HttpService:JSONEncode(testData)
    
    local success, result = pcall(function()
        return req({
            Url = url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["User-Agent"] = "LimeHub-Roblox"
            },
            Body = jsonData
        })
    end)
    
    return success
end

function sendStatusWebhook()
    if not sendEnabled or wurl == "" then return end
    
    local success, counts = pcall(getFishCounts)
    if not success then counts = {Common=0, Uncommon=0, Rare=0, Epic=0, Legendary=0, Mythical=0, Secret=0} end
    
    local ghostfinnProgress = getGhostfinnProgress()
    
    local fields = {
        {name="User", value=tostring(game.Players.LocalPlayer.Name), inline=true},
        {name="Best Rod", value=tostring(getBestRod()), inline=true},
        {name="Best Bait", value=tostring(getBestBait()), inline=true},
        {name="💰 Coins", value=tostring(getCoins()), inline=true},
        {name="Common", value=tostring(counts.Common), inline=true},
        {name="Uncommon", value=tostring(counts.Uncommon), inline=true},
        {name="Rare", value=tostring(counts.Rare), inline=true},
        {name="Epic", value=tostring(counts.Epic), inline=true},
        {name="Legend", value=tostring(counts.Legendary), inline=true},
        {name="Mythic", value=tostring(counts.Mythical), inline=true},
        {name="Secret", value=tostring(counts.Secret), inline=true}
    }
    
    if #ghostfinnProgress > 0 then
        local ghostfinnText = ""
        for i, progressText in ipairs(ghostfinnProgress) do
            ghostfinnText = ghostfinnText .. progressText
            if i < #ghostfinnProgress then
                ghostfinnText = ghostfinnText .. "\n"
            end
        end
        table.insert(fields, {name="Progress Quest Ghostfinn", value=ghostfinnText, inline=false})
    end
    
    local data = {
        username = "LimeHub Bot",
        avatar_url = "https://cdn.discordapp.com/attachments/1408262889437134942/1420411647054446683/limehub.jpeg?ex=68d54cee&is=68d3fb6e&hm=bf50d2083093decbeea5146165c85dd351801cfa2bffe1dd711907b308af1c47&",
        content = "",
        embeds = {{
            title = "🎣 LimeHub Status Update",
            color = 0x00FF00,
            fields = fields,
            footer = {text = "Updated • "..os.date("%X")}
        }}
    }
    
    local jsonData = HttpService:JSONEncode(data)
    
    spawn( LPH_NO_VIRTUALIZE( function()
        pcall(function()
            req({
                Url = wurl,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                    ["User-Agent"] = "LimeHub-Roblox"
                },
                Body = jsonData
            })
        end)
    end))
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LimeHubStatus"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local blur = Instance.new("BlurEffect")
blur.Name = "LimeHubBlur"
blur.Size = 24
blur.Enabled = false
blur.Parent = Lighting

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0,300,0,40)
titleLabel.Position = UDim2.new(0.5,0,0.25,0)
titleLabel.AnchorPoint = Vector2.new(0.5,0.5)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255,255,255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 24
titleLabel.Text = "LimeHub Status"
titleLabel.TextScaled = true
titleLabel.Visible = false
titleLabel.Parent = screenGui

local row1 = Instance.new("TextLabel")
row1.Size = UDim2.new(0,600,0,30)
row1.Position = UDim2.new(0.5,0,0.35,0)
row1.AnchorPoint = Vector2.new(0.5,0.5)
row1.BackgroundTransparency = 1
row1.TextColor3 = Color3.fromRGB(255,255,255)
row1.Font = Enum.Font.GothamBold
row1.TextSize = 18
row1.TextXAlignment = Enum.TextXAlignment.Center
row1.Visible = false
row1.Parent = screenGui

local row2 = Instance.new("TextLabel")
row2.Size = UDim2.new(0,600,0,30)
row2.Position = UDim2.new(0.5,0,0.4,0)
row2.AnchorPoint = Vector2.new(0.5,0.5)
row2.BackgroundTransparency = 1
row2.TextColor3 = Color3.fromRGB(255,255,255)
row2.Font = Enum.Font.GothamBold
row2.TextSize = 18
row2.TextXAlignment = Enum.TextXAlignment.Center
row2.Visible = false
row2.Parent = screenGui

local ghostfinnTitle = Instance.new("TextLabel")
ghostfinnTitle.Size = UDim2.new(0,600,0,30)
ghostfinnTitle.Position = UDim2.new(0.5,0,0.45,0)
ghostfinnTitle.AnchorPoint = Vector2.new(0.5,0.5)
ghostfinnTitle.BackgroundTransparency = 1
ghostfinnTitle.TextColor3 = Color3.fromRGB(255,255,255)
ghostfinnTitle.Font = Enum.Font.GothamBold
ghostfinnTitle.TextSize = 18
ghostfinnTitle.TextXAlignment = Enum.TextXAlignment.Center
ghostfinnTitle.Text = "Progress Quest Ghostfinn"
ghostfinnTitle.Visible = false
ghostfinnTitle.Parent = screenGui

local ghostfinnRow1 = Instance.new("TextLabel")
ghostfinnRow1.Size = UDim2.new(0,600,0,25)
ghostfinnRow1.Position = UDim2.new(0.5,0,0.5,0)
ghostfinnRow1.AnchorPoint = Vector2.new(0.5,0.5)
ghostfinnRow1.BackgroundTransparency = 1
ghostfinnRow1.TextColor3 = Color3.fromRGB(255,255,255)
ghostfinnRow1.Font = Enum.Font.Gotham
ghostfinnRow1.TextSize = 12
ghostfinnRow1.TextXAlignment = Enum.TextXAlignment.Center
ghostfinnRow1.Text = "Loading..."
ghostfinnRow1.Visible = false
ghostfinnRow1.Parent = screenGui

local ghostfinnRow2 = Instance.new("TextLabel")
ghostfinnRow2.Size = UDim2.new(0,600,0,25)
ghostfinnRow2.Position = UDim2.new(0.5,0,0.525,0)
ghostfinnRow2.AnchorPoint = Vector2.new(0.5,0.5)
ghostfinnRow2.BackgroundTransparency = 1
ghostfinnRow2.TextColor3 = Color3.fromRGB(255,255,255)
ghostfinnRow2.Font = Enum.Font.Gotham
ghostfinnRow2.TextSize = 12
ghostfinnRow2.TextXAlignment = Enum.TextXAlignment.Center
ghostfinnRow2.Text = ""
ghostfinnRow2.Visible = false
ghostfinnRow2.Parent = screenGui

local ghostfinnRow3 = Instance.new("TextLabel")
ghostfinnRow3.Size = UDim2.new(0,600,0,25)
ghostfinnRow3.Position = UDim2.new(0.5,0,0.55,0)
ghostfinnRow3.AnchorPoint = Vector2.new(0.5,0.5)
ghostfinnRow3.BackgroundTransparency = 1
ghostfinnRow3.TextColor3 = Color3.fromRGB(255,255,255)
ghostfinnRow3.Font = Enum.Font.Gotham
ghostfinnRow3.TextSize = 12
ghostfinnRow3.TextXAlignment = Enum.TextXAlignment.Center
ghostfinnRow3.Text = ""
ghostfinnRow3.Visible = false
ghostfinnRow3.Parent = screenGui

local ghostfinnRow4 = Instance.new("TextLabel")
ghostfinnRow4.Size = UDim2.new(0,600,0,25)
ghostfinnRow4.Position = UDim2.new(0.5,0,0.575,0)
ghostfinnRow4.AnchorPoint = Vector2.new(0.5,0.5)
ghostfinnRow4.BackgroundTransparency = 1
ghostfinnRow4.TextColor3 = Color3.fromRGB(255,255,255)
ghostfinnRow4.Font = Enum.Font.Gotham
ghostfinnRow4.TextSize = 12
ghostfinnRow4.TextXAlignment = Enum.TextXAlignment.Center
ghostfinnRow4.Text = ""
ghostfinnRow4.Visible = false
ghostfinnRow4.Parent = screenGui

local webhookStatus = Instance.new("TextLabel")
webhookStatus.Size = UDim2.new(0,600,0,20)
webhookStatus.Position = UDim2.new(0.5,0,0.65,0)
webhookStatus.AnchorPoint = Vector2.new(0.5,0.5)
webhookStatus.BackgroundTransparency = 1
webhookStatus.TextColor3 = Color3.fromRGB(255,255,255)
webhookStatus.Font = Enum.Font.GothamBold
webhookStatus.TextSize = 14
webhookStatus.TextXAlignment = Enum.TextXAlignment.Center
webhookStatus.Text = "Webhook: Not Configured"
webhookStatus.Visible = false
webhookStatus.Parent = screenGui

local toggleBtn = Instance.new("ImageButton")
toggleBtn.Size = UDim2.new(0,50,0,50)
toggleBtn.Position = UDim2.new(0,5,0,5)
toggleBtn.BackgroundTransparency = 1
toggleBtn.Image = "rbxassetid://88791594299566"
toggleBtn.Visible = false
toggleBtn.Parent = screenGui

toggleBtn.MouseButton1Click:Connect(function()
    local visible = not row1.Visible
    row1.Visible = visible
    row2.Visible = visible
    titleLabel.Visible = visible
    ghostfinnTitle.Visible = visible
    ghostfinnRow1.Visible = visible
    ghostfinnRow2.Visible = visible
    ghostfinnRow3.Visible = visible
    ghostfinnRow4.Visible = visible
    webhookStatus.Visible = visible
    blur.Enabled = visible
end)

spawn( LPH_NO_VIRTUALIZE( function()
    if _G.Wurl and _G.Wurl ~= "" then
        if isValidWebhookURL(_G.Wurl) then
            webhookStatus.Text = "Webhook: Testing..."
            webhookStatus.TextColor3 = Color3.fromRGB(255, 255, 0)
            
            local success = testWebhook(_G.Wurl)
            
            if success then
               wurl = _G.Wurl
                sendEnabled = true
                webhookStatus.Text = "Webhook: Active ✅"
                webhookStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
            else
                webhookStatus.Text = "Webhook: Failed ❌"
                webhookStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
                sendEnabled = false
            end
        else
            webhookStatus.Text = "Webhook: Invalid URL ❌"
            webhookStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
            sendEnabled = false
        end
    else
        webhookStatus.Text = "Webhook: Not Configured"
        webhookStatus.TextColor3 = Color3.fromRGB(255, 255, 255)
        sendEnabled = false
    end
end))

RunService.RenderStepped:Connect( LPH_NO_VIRTUALIZE( function()
    local counts = getFishCounts()
    row1.Text = "Best Rod: "..tostring(getBestRod()).."  |  Coins: "..tostring(getCoins()).."  |  Uncommon: "..counts.Uncommon.."  |  Epic: "..counts.Epic.."  |  Mythic: "..counts.Mythical
    row2.Text = "Best Bait: "..tostring(getBestBait()).."  |  Common: "..counts.Common.."  |  Rare: "..counts.Rare.."  |  Legend: "..counts.Legendary.."  |  Secret: "..counts.Secret

    local ghostfinnProgress = getGhostfinnProgress()
    ghostfinnRow1.Text = ghostfinnProgress[1] or "No progress data"
    ghostfinnRow2.Text = ghostfinnProgress[2] or "No progress data"
    ghostfinnRow3.Text = ghostfinnProgress[3] or "No progress data"
    ghostfinnRow4.Text = ghostfinnProgress[4] or "No progress data"

    if _G.DelayWebhook and tick() - lastSend >= (_G.DelayWebhook * 60) then
        sendStatusWebhook()
        lastSend = tick()
    end
end))

local WebhookInput = Exclusive:Input({
    Title = "Webhook URL",
    Value = _G.Wurl or "",
    InputIcon = "link",
    Type = "Input",
    Placeholder = "https://discord.com/api/webhooks/...",
    Callback = function(input)
        _G.Wurl = input
        wurl = input
        SaveConfig()
        
        if input ~= "" then
            webhookStatus.Text = "Webhook: Testing..."
            webhookStatus.TextColor3 = Color3.fromRGB(255, 255, 0)
            
            local success = testWebhook(input)
            
            if success then
                webhookStatus.Text = "Webhook: Active ✅"
                webhookStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
                sendEnabled = true
            else
                webhookStatus.Text = "Webhook: Failed ❌"
                webhookStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
                sendEnabled = false
            end
        else
            webhookStatus.Text = "Webhook: Not Configured"
            webhookStatus.TextColor3 = Color3.fromRGB(255, 255, 255)
            sendEnabled = false
        end
    end
})

local DelaySlider = Exclusive:Slider({
    Title = "Webhook Delay",
    Step = 1,
    Value = {
        Min = 1,
        Max = 60,
        Default = _G.DelayWebhook or 1,
    },
    Callback = function(value)
        _G.DelayWebhook = value
        SaveConfig()
    end
})

local RarityDropdown = Exclusive:Dropdown({
    Title = "Auto Favorite Rarity",
    Values = {"Common", "Uncommon", "Rare", "Epic", "Legend", "Mythic", "Secret"},
    Value = _G.AutoFavorite or {},
    Multi = true,
    AllowNone = true,
    Callback = function(selected)
        _G.AutoFavorite = selected
        SaveConfig()
    end
})

local OneClickToggle = Exclusive:Toggle({
    Title = "Start Kaitun",
    Value = _G.OneClickMode,
    Callback = function(state)
        _G.OneClickMode = state
        SaveConfig()
        
        toggleBtn.Visible = state
        
        if not state then
            pcall(function()
game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/CancelFishingInputs"):InvokeServer()
            end)
        end
    end
})

Main:Section({ Title = "Fishing" })
Main:Button({
    Title = "Reset Character",
    Callback = function()
        local char = player.Character or player.CharacterAdded:Wait()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Health = 0
        end
    end
})

Main:Toggle({
    Title = "Anti Stuck",
    Default = false,
    Callback = function(value)
        _G.HandlerStuck = value
    end
})

Main:Toggle({
    Title = "Auto Fishing",
    Value = _G.AutoFish,
    Callback = function(value)
        _G.AutoFish = value
        SaveConfig()
        
        if not value then
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/CancelFishingInputs"):InvokeServer()
            end)
        end
    end
})

spawn( LPH_NO_VIRTUALIZE( function()
    while true do
        task.wait(0.1)
        if _G.AutoFish then
            local char = player.Character or player.CharacterAdded:Wait()

            repeat
                task.wait(0.1)

                if char:FindFirstChild("!!!FISHING_VIEW_MODEL!!!") then
                    pcall(function()
                        RepStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/EquipToolFromHotbar"]:FireServer(1)
                    end)
                end

                task.wait(0.1)

                local cosmeticFolder = workspace:FindFirstChild("CosmeticFolder")
                if cosmeticFolder and not cosmeticFolder:FindFirstChild(tostring(player.UserId)) then
                    pcall(function()
                        RepStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/ChargeFishingRod"]:InvokeServer(1756818911.281488)
                    end)
                    task.wait(0.2)
                    pcall(function()
                        RepStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/RequestFishingMinigameStarted"]:InvokeServer(-1.25, 1)
                    end)
                end

            until not _G.AutoFish
        end
    end
end))

spawn( LPH_NO_VIRTUALIZE( function()
   while wait(0.1) do
   if _G.AutoFish then
   repeat
   task.wait(0.2)
       pcall(function()
       game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RE/FishingCompleted"]:FireServer()
       end)
       until not _G.AutoFish
     end
   end
end))

local lastfish = tick()
local fishingController = require(game:GetService("ReplicatedStorage").Controllers.FishingController)
local originalFishCaught = fishingController.FishCaught

fishingController.FishCaught = function(...)
    if _G.AutoFish and _G.HandlerStuck then
        lastfish = tick()
    end
    return originalFishCaught(...)
end

local lastCFrame

spawn( LPH_NO_VIRTUALIZE( function()
    while true do
        task.wait(1)
        if _G.HandlerStuck and _G.AutoFish then
            local char = workspace:FindFirstChild("Characters"):FindFirstChild(player.Name)
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if hum and hrp and tick() - lastfish > 15 then
                lastCFrame = hrp.CFrame 

                _G.AutoFish = false
                hum.Health = 0 
                task.wait(5)

                char = workspace:FindFirstChild("Characters"):FindFirstChild(player.Name)
                hrp = char and char:FindFirstChild("HumanoidRootPart")
                if char and hrp and lastCFrame then
                    hrp.CFrame = lastCFrame
                    task.wait(0.5)
                    _G.AutoFish = true
                end
                lastfish = tick()
            end
        else
            lastfish = tick()
        end
    end
end))

Main:Section({ Title = "Event" })
Main:Paragraph({
    Title = "Info",
    Desc = "Location is for farming when event is unavailable. Event always has priority - auto teleports when available."
})
local eventsList = {
    "Ghost Shark Hunt",
    "Megalodon Hunt",
    "Shark Hunt", 
    "Sparkling Cove",
    "Worm Hunt"
}

local locationsList = {
    "Fisherman Island",
    "Crafter Island",
    "Weather Machine",
    "Loot Isle",
    "Esoteric Deepths",
    "Altar",
    "Coral Reefs",
    "Kohana",
    "Kohana Vulcano",
    "Tropical Grove",
    "Deep Sea",
    "Treasure Room"
}

local locationCFrames = {
    ["Fisherman Island"] = CFrame.new(-110.302589, 3.2620542, 2808.38794, -0.95936352, -6.85344261e-08, -0.282173127, -5.18341032e-08, 1, -6.66494415e-08, 0.282173127, -4.93148526e-08, -0.95936352),
    ["Crafter Island"] = CFrame.new(978.599487, 47.4545288, 5086.31396, -0.590745628, -8.98475605e-09, 0.806857884, 5.53998269e-08, 1, 5.16967908e-08, -0.806857884, 7.52394413e-08, -0.590745628),
    ["Weather Machine"] = CFrame.new(-1517.14014, 2.87499952, 1914.43445, -0.992884457, 1.58579851e-08, -0.119081579, 1.20907506e-08, 1, 3.23582015e-08, 0.119081579, 3.06881702e-08, -0.992884457),
    ["Loot Isle"] = CFrame.new(-3849.32812, 62.4258347, -1438.07324, -0.597851217, -1.94460341e-08, -0.801607072, 1.61765144e-08, 1, -3.63235095e-08, 0.801607072, -3.46832643e-08, -0.597851217),
    ["Esoteric Deepths"] = CFrame.new(1983.026, 2.3588388, 1400.71692, -0.127730578, 4.17303037e-09, 0.991808891, 5.1634423e-08, 1, 2.44226972e-09, -0.991808891, 5.15234326e-08, -0.127730578),
    ["Altar"] = CFrame.new(3264.05518, -1301.53027, 1376.69006, 0.811563194, 8.69882566e-09, -0.584264636, -4.91663563e-08, 1, -5.34052162e-08, 0.584264636, 7.20678699e-08, 0.811563194),
    ["Coral Reefs"] = CFrame.new(-3134.85205, 5.00295353, 2136.01367, 0.987203121, 4.1917203e-09, 0.159467891, -1.0778753e-08, 1, 4.0441364e-08, -0.159467891, -4.16427035e-08, 0.987203121),
    ["Kohana"] = CFrame.new(-653.100403, 2.82505941, 550.10022, -0.0875285715, 1.074946e-07, -0.996161997, -5.14608587e-08, 1, 1.12430406e-07, 0.996161997, 6.11042239e-08, -0.0875285715),
    ["Kohana Vulcano"] = CFrame.new(-591.781494, 40.6086769, 149.605621, -0.690379977, 1.43661989e-08, -0.723446965, -2.95755296e-08, 1, 4.8081688e-08, 0.723446965, 5.45909629e-08, -0.690379977),
    ["Tropical Grove"] = CFrame.new(-2101.65845, 6.09673119, 3652.63843, -0.53145951, -3.64524588e-08, 0.847083688, 5.37013722e-09, 1, 4.64021106e-08, -0.847083688, 2.9209799e-08, -0.53145951),
    ["Deep Sea"] = CFrame.new(-3741.23804, -135.074417, -1008.8219, -0.983854651, 5.95717005e-08, -0.178969383, 6.57485231e-08, 1, -2.85819155e-08, 0.178969383, -3.98874249e-08, -0.983854651),
    ["Treasure Room"] = CFrame.new(-3596.34106, -280.743835, -1646.00781, 0.986422956, 8.37402396e-08, -0.164224595, -8.14241474e-08, 1, 2.08348148e-08, 0.164224595, -7.18009252e-09, 0.986422956)
}

local eventModel = nil
local connections = {}
local isTeleporting = false
local lastEventState = nil

if _G.selectedEvent == nil then
    _G.selectedEvent = eventsList[1]
end
if _G.selectedLocation == nil then
    _G.selectedLocation = locationsList[1]
end

function getCharacterPosition()
    local character = player.Character
    if not character then return nil end
    
    local hrp = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChildWhichIsA("BasePart")
    if not hrp then return nil end
    
    return hrp.Position
end

function getDistanceFromEvent()
    if not eventModel then return math.huge end
    
    local charPos = getCharacterPosition()
    if not charPos then return math.huge end
    
    local eventPos = eventModel:GetPivot().Position
    return (charPos - eventPos).Magnitude
end

function getDistanceFromLocation()
    local targetCFrame = locationCFrames[_G.selectedLocation]
    if not targetCFrame then return math.huge end
    
    local charPos = getCharacterPosition()
    if not charPos then return math.huge end
    
    local locationPos = targetCFrame.Position
    return (charPos - locationPos).Magnitude
end

function findEventModel(eventName)
    local menuRings = workspace:FindFirstChild("!!! MENU RINGS")
    if not menuRings or not menuRings:IsA("Model") then
        return nil
    end
    
    function findAllPropsModels(parent)
        local propsModels = {}
        for _, child in ipairs(parent:GetChildren()) do
            if child.Name == "Props" and child:IsA("Model") then
                table.insert(propsModels, child)
            end
            if child:IsA("Model") or child:IsA("Folder") then
                local childProps = findAllPropsModels(child)
                for _, prop in ipairs(childProps) do
                    table.insert(propsModels, prop)
                end
            end
        end
        return propsModels
    end
    
    local propsModels = findAllPropsModels(menuRings)
    
    for _, propsModel in ipairs(propsModels) do
        local foundModel = propsModel:FindFirstChild(eventName)
        if foundModel and foundModel:IsA("Model") then
            return foundModel
        end
    end
    
    return nil
end

function teleportToLocation()
    if isTeleporting then return false end
    isTeleporting = true
    
    local targetCFrame = locationCFrames[_G.selectedLocation]
    if not targetCFrame then
        isTeleporting = false
        return false
    end
    
    local character = player.Character
    if not character then
        character = player.CharacterAdded:Wait()
    end
    
    local hrp = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChildWhichIsA("BasePart")
    if not hrp then
        isTeleporting = false
        return false
    end
    
    hrp.CFrame = targetCFrame * CFrame.new(0, 5, 0)
    isTeleporting = false
    return true
end

local eventPlatform = nil

function teleportToEvent()
    if isTeleporting then return false end 
    isTeleporting = true
    
    if not eventModel or not eventModel.Parent then
        isTeleporting = false
        return false
    end
    
    local targetCFrame = eventModel:GetPivot()
    
    local character = player.Character
    if not character then
        character = player.CharacterAdded:Wait()
    end
    
    local hrp = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChildWhichIsA("BasePart")
    if not hrp then
        isTeleporting = false
        return false
    end
    
    if eventPlatform then
        eventPlatform:Destroy()
        eventPlatform = nil
    end
    
    eventPlatform = Instance.new("Part")
    eventPlatform.Name = "EventPlatform"
    eventPlatform.Size = Vector3.new(10, 1, 10)
    eventPlatform.Position = Vector3.new(targetCFrame.Position.X, targetCFrame.Position.Y + 5, targetCFrame.Position.Z)
    eventPlatform.Transparency = 1
    eventPlatform.Anchored = true
    eventPlatform.CanCollide = true
    eventPlatform.Parent = workspace
    
    hrp.CFrame = eventPlatform.CFrame * CFrame.new(0, 3, 0)
    
    isTeleporting = false
    return true
end

function connectToEventModel()
    for _, connection in ipairs(connections) do
        connection:Disconnect()
    end
    table.clear(connections)
    
    eventModel = findEventModel(_G.selectedEvent)
    
    if eventModel then
        return true
    else
        function setupPropsListeners(props)
            function onChildAdded(child)
                if child.Name == _G.selectedEvent and child:IsA("Model") then
                    eventModel = child
                end
            end
            
            for _, child in ipairs(props:GetChildren()) do
                onChildAdded(child)
            end
            
            table.insert(connections, props.ChildAdded:Connect(onChildAdded))
        end
        
        local menuRings = workspace:FindFirstChild("!!! MENU RINGS")
        if menuRings and menuRings:IsA("Model") then
            local propsModel = menuRings:FindFirstChild("Props")
            if propsModel and propsModel:IsA("Model") then
                setupPropsListeners(propsModel)
                return false
            end
        end
        
        table.insert(connections, workspace.ChildAdded:Connect(function(child)
            if child.Name == "!!! MENU RINGS" and child:IsA("Model") then
                local propsModel = child:FindFirstChild("Props")
                if propsModel and propsModel:IsA("Model") then
                    setupPropsListeners(propsModel)
                    
                    local foundModel = propsModel:FindFirstChild(_G.selectedEvent)
                    if foundModel and foundModel:IsA("Model") then
                        eventModel = foundModel
                    end
                end
            end
        end))
    end
    
    return false 
end

Main:Dropdown({
    Title = "Select Event",
    Values = eventsList,
    Value = _G.selectedEvent,
    Callback = function(option) 
        _G.selectedEvent = option
        SaveConfig()
        lastEventState = nil
    end
})

Main:Dropdown({
    Title = "Select Location",
    Values = locationsList,
    Value = _G.selectedLocation,
    Callback = function(option) 
        _G.selectedLocation = option
        SaveConfig()
    end
})

Main:Toggle({
    Title = "Auto Fish at Active Event/Location",
    Value = _G.TeleportEvent,
    Callback = function(value)
        _G.TeleportEvent = value
        SaveConfig()
        lastEventState = nil
    end
})

spawn( LPH_NO_VIRTUALIZE( function()
    while wait(1) do
        pcall(function()
            if _G.TeleportEvent then
                connectToEventModel()
                
                local currentEventState = (eventModel ~= nil)
                local eventStateChanged = (currentEventState ~= lastEventState)
                
                if eventStateChanged or lastEventState == nil then
                    if eventModel then
                        local distance = getDistanceFromEvent()
                        if distance > 50 then
                            teleportToEvent()
                        end
                      if not _G.AutoFish then
                          WindUI:Notify({
                              Title = "LimeHub Notify",
                              Content = "Please Enabled Auto Fishing",
                              Duration = 3,
                          })
                      end
                    else
                        local distance = getDistanceFromLocation()
                        if distance > 50 then
                            teleportToLocation()
                        end
                      if not _G.AutoFish then
                          WindUI:Notify({
                              Title = "LimeHub Notify",
                              Content = "Please Enabled Auto Fishing",
                              Duration = 3,
                          })
                      end
                    end
                    lastEventState = currentEventState
                end
            else
                for _, connection in ipairs(connections) do
                    connection:Disconnect()
                end
                table.clear(connections)
                lastEventState = nil
            end
        end)
    end
end))

Quest:Section({ Title = "Deep Sea Quest" })

local plr = Players.LocalPlayer

function teleportToQuest()
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    hrp.CFrame = CFrame.new(
        -3741.23804, -135.074417, -1008.8219,
        -0.983854651, -5.2231119e-08, -0.178969383,
        -4.4131955e-08, 1, -4.92357373e-08,
        0.178969383, -4.05425382e-08, -0.983854651
    )
end

local Paragraph = Quest:Paragraph({
    Title = "Quest Pro",
    Desc = "Loading quest info...",
    Color = "Blue",
})

spawn( LPH_NO_VIRTUALIZE( function()
    while task.wait(0.2) do
        local success, err = pcall(function()
            local board = workspace["!!! MENU RINGS"]["Deep Sea Tracker"].Board.Gui.Content
            local l1 = board.Label1.Text
            local l2 = board.Label2.Text
            local l3 = board.Label3.Text
            local l4 = board.Label4.Text

            Paragraph:SetDesc(l1 .. "\n" .. l2 .. "\n" .. l3 .. "\n" .. l4)
        end)

        if not success then
            Paragraph:SetDesc("Quest info not found.")
        end
    end
end))

Quest:Toggle({
    Title = "Deep Sea Quest",
    Default = false,
    Callback = function(value)
        if value then
            teleportToQuest()
              if not _G.AutoFish then
                WindUI:Notify({
                   Title = "LimeHub Notify",
                   Content = "Please Enabled Auto Fishing",
                   Duration = 3,
                })
             end
        end
        
        if not value then
         if _G.AutoFish then
          WindUI:Notify({
             Title = "LimeHub Notify",
             Content = "Please Disable Auto Fishing",
             Duration = 3,
          })
         end
             wait(0.5)
             pcall(function()
 game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/CancelFishingInputs"):InvokeServer()
             end)
        end
    end
})

Quest:Section({ Title = "Farmer Boat Quest" })

function teleportToCrab()
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(-181.485352, 2.81581354, 2825.42261, -0.0517583042, 5.1605431e-10, 0.99865967, 5.89698024e-09, 1, -2.11119608e-10, -0.99865967, 5.87814908e-09, -0.0517583042)
end

function teleportToFishing()
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(-635.478455, 8.12512398, 161.971222, -0.877416611, -0.00016172335, 0.479729205, -0.000674624287, 0.999999344, -0.000896762707, -0.479728729, -0.00111047144, -0.877416134)
end

local Paragraph = Quest:Paragraph({
    Title = "Boat Quest",
    Desc = "Checking level...",
    Color = "Blue",
})

spawn( LPH_NO_VIRTUALIZE( function()
    while task.wait(0.5) do
        pcall(function()
            local playerCharacter = workspace.Characters:FindFirstChild(plr.Name)
            if not playerCharacter then
                Paragraph:SetDesc("Character not found in workspace.")
                return
            end
            
            local levelText = playerCharacter.HumanoidRootPart.Overhead.LevelContainer.Label.Text
            local currentLevel = tonumber(string.match(levelText, "%d+"))
            
            if currentLevel < 200 then
                Paragraph:SetDesc("Your current level is " .. currentLevel .. ". You need to reach level 200 to start the Aura Quest.")
                return
            end
            
            local auraTracker = workspace["!!! MENU RINGS"]["Aura Tracker"]
            if not auraTracker then
                Paragraph:SetDesc("Level 200 reached! Aura Quest not activated yet.")
                return
            end
            
            local label1 = auraTracker.Board.Gui.Content.Label1.Text
            local label2 = auraTracker.Board.Gui.Content.Label2.Text
            local label3 = auraTracker.Board.Gui.Content.Label3.Text
            
            Paragraph:SetDesc(label1 .. "\n" .. label2 .. "\n" .. label3)
        end)
    end
end))

Quest:Toggle({
    Title = "Farmer Boat Quest",
    Default = false,
    Callback = function(value)
        if value then
            pcall(function()
                local playerCharacter = workspace.Characters:FindFirstChild(plr.Name)
                if not playerCharacter then
                    Quest:Notify({Title = "Error", Desc = "Character not found.", Color = "Red"})
                    return
                end
                
                local levelText = playerCharacter.HumanoidRootPart.Overhead.LevelContainer.Label.Text
                local currentLevel = tonumber(string.match(levelText, "%d+"))
                
                if currentLevel < 200 then
                    Quest:Notify({Title = "Level Required", Desc = "You need to be level 200 to start this quest.", Color = "Red"})
                    return
                end
                
                local auraTracker = workspace["!!! MENU RINGS"]["Aura Tracker"]
                if not auraTracker then
                    game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RF/ActivateQuestLine"]:InvokeServer("AuraQuest")
                    task.wait(1)
                end
                
                local crabProgress = workspace["!!! MENU RINGS"]["Aura Tracker"].Board.Gui.Content.Label1.Text
                local isCrabComplete = string.match(crabProgress, "100%%")
                
                if not isCrabComplete then
                    teleportToCrab()
                else
                    teleportToFishing()
                end
                
                if not _G.AutoFish then
                    _G.AutoFish = true
                end
            end)
        else
            _G.AutoFish = false
            wait(0.5)
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/CancelFishingInputs"):InvokeServer()
            end)
        end
    end
})

Main:Section({ Title = "Favorite & Sell" })
Main:Dropdown({
    Title = "Select Rarity",
    Values = {"Common", "Uncommon", "Rare", "Epic", "Legend", "Mythic", "Secret"},
    Value = _G.AutoFavorite or {},
    Multi = true,
    AllowNone = true,
    Callback = function(selected)
        _G.AutoFavorite = selected
        SaveConfig()
    end
})

function autoFavoriteByTier()
    local inventory = dataStore:Get("Inventory")
    if not inventory then return end
    for _, category in pairs(inventory) do
        if type(category) == "table" then
            for _, item in ipairs(category) do
                if type(item) == "table" and item.Id then
                    local itemData = ItemUtility:GetItemData(item.Id)
                    if itemData and itemData.Data then
                        local tier = itemData.Data.Tier or 1
                        local rarity = "Unknown"
                        if tier == 1 then rarity = "Common"
                        elseif tier == 2 then rarity = "Uncommon"
                        elseif tier == 3 then rarity = "Rare"
                        elseif tier == 4 then rarity = "Epic"
                        elseif tier == 5 then rarity = "Legend"
                        elseif tier == 6 then rarity = "Mythic"
                        elseif tier == 7 then rarity = "Secret" end

                        if table.find(_G.AutoFavorite, rarity) and not item.Favorited then
                            pcall(function()
                                FavoriteItem:FireServer(item.UUID or item.Id)
                            end)
                            task.wait(0.2)
                        end
                    end
                end
            end
        end
    end
end

spawn( LPH_NO_VIRTUALIZE( function()
    while true do
        task.wait(0.2)
        if _G.AutoFav and #_G.AutoFavorite > 0 then
            autoFavoriteByTier()
        end
    end
end))

Main:Toggle({
    Title = "Auto Favorite",
    Value = _G.AutoFav,
    Callback = function(state)
        _G.AutoFav = state
        SaveConfig()      
    end
})

Main:Button({
    Title = "Unfavorite All",
    Locked = false,
    Callback = function()
        coroutine.wrap(function()
            local inventory = dataStore:Get("Inventory")
            
            local unfavoriteCount = 0
            
            for _, category in pairs(inventory) do
                if type(category) == "table" then
                    for _, item in ipairs(category) do
                        if type(item) == "table" and item.Id and item.Favorited then
                            pcall(function()
                                FavoriteItem:FireServer(item.UUID or item.Id)
                                unfavoriteCount = unfavoriteCount + 1
                            end)
                            task.wait(0.1) 
                        end
                    end
                end
            end
            
            print("Successfully unfavorited " .. unfavoriteCount .. " items")
        end)()
    end
})

Main:Slider({
    Title = "Sell Delay",
    Desc = "/Seconds",
    Step = 1,
    Value = {
        Min = 5,
        Max = 100,
        Default = 10,
    },
    Callback = function(value)
        _G.AutoSellDelay = value
        SaveConfig()
    end
})

Main:Toggle({
    Title = "Auto Sell",
    Value = _G.AutoSell,
    Callback = function(value)
        _G.AutoSell = value
        SaveConfig()
    end
})

spawn(LPH_NO_VIRTUALIZE(function()
    while wait(_G.AutoSellDelay) do
        pcall(function()
            if _G.AutoSell then
                pcall(function()         
                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/SellAllItems"):InvokeServer()
                end)
            end
        end)
    end
end))

Main:Section({ Title = "Utility" })
Main:Toggle({
    Title = "Fishing Radar",
    Value = _G.Radar,
    Callback = function(state)
        _G.Radar = state
        SaveConfig()
        pcall(function()
        game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RF/UpdateFishingRadar"]:InvokeServer(state)
        end)
    end
})

Main:Toggle({
    Title = "Oxygen Tank",
    Value = _G.Oxygen,
    Callback = function(state)
        _G.Oxygen = state
        SaveConfig()
        pcall(function()
        if state then
                game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RF/EquipOxygenTank"]:InvokeServer(105)
        else
                game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RF/UnequipOxygenTank"]:InvokeServer()
        end
        end)
    end
})

Shop:Section({ Title = "Merchant" })
local MerchantParagraph = Shop:Paragraph({
    Title = "Merchant Stock",
    Desc = "Merchant: Not Spawned"
})

Shop:Button({
    Title = "Teleport to Merchant",
    Locked = false,
    Callback = function()
        local merchant = workspace.NPC:FindFirstChild("Alien Merchant")
        if merchant then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = merchant.PrimaryPart.CFrame + Vector3.new(0, 3, 0)
        else
            print("Merchant not found!")
        end
    end
})

spawn(function()
    while task.wait(1) do
        local merchant = workspace.NPC:FindFirstChild("Alien Merchant")
        if not merchant then
            MerchantParagraph:SetDesc("Merchant: Not Spawned")
        else
            local merchantGui = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Merchant")
            if merchantGui then
                local scrollingFrame = merchantGui.Main.Background.Items.ScrollingFrame
                local items = {}
                
                for _, template in ipairs(scrollingFrame:GetChildren()) do
                    if template.Name == "Template" and template:FindFirstChild("Frame") then
                        local itemFrame = template.Frame
                        local itemName = itemFrame:FindFirstChild("ItemName")
                        if itemName and itemName:IsA("TextLabel") then
                            table.insert(items, itemName.Text)
                        end
                    end
                end
                
                if #items > 0 then
                    MerchantParagraph:SetDesc("Merchant Stock: " .. table.concat(items, ", "))
                else
                    MerchantParagraph:SetDesc("Merchant: No Items Available")
                end
            end
        end
    end
end)

Shop:Section({ Title = "Enchant" })
local netFolder = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
local equipItemRemote = netFolder["RE/EquipItem"]
local activateAltarRemote = netFolder["RE/ActivateEnchantingAltar"]
local equipToolRemote = netFolder["RE/EquipToolFromHotbar"]

local enchantNames = {
    "Big Hunter 1",
    "Cursed 1", 
    "Empowered 1",
    "Glistening 1",
    "Gold Digger 1",
    "Leprechaun 1",
    "Leprechaun 2",
    "Mutation Hunter 1",
    "Mutation Hunter 2",
    "Prismatic 1",
    "Reeler 1",
    "Stargazer 1",
    "Stormhunter 1",
    "XPerienced 1"
}

local enchantIdMap = {
    ["Big Hunter 1"] = 3,
    ["Cursed 1"] = 12,
    ["Empowered 1"] = 9,
    ["Glistening 1"] = 1,
    ["Gold Digger 1"] = 4,
    ["Leprechaun 1"] = 5,
    ["Leprechaun 2"] = 6,
    ["Mutation Hunter 1"] = 7,
    ["Mutation Hunter 2"] = 14,
    ["Prismatic 1"] = 13,
    ["Reeler 1"] = 2,
    ["Stargazer 1"] = 8,
    ["Stormhunter 1"] = 11,
    ["XPerienced 1"] = 10
}

function findEnchantStones()
    local inventory = dataStore:Get("Inventory.Items")
    if not inventory then return {} end
    
    local enchantStones = {}
    for key, itemData in pairs(inventory) do
        if type(itemData) == "table" and itemData.Metadata then
            if itemData.Metadata.Name == "Enchant Stone" or itemData.Id == 10 then
                table.insert(enchantStones, {
                    UUID = itemData.UUID,
                    Quantity = itemData.Quantity or 1
                })
            end
        end
    end
    return enchantStones
end

function countDisplayImageButtons()
    local success, backpackGui = pcall(function() return player.PlayerGui.Backpack end)
    if not success or not backpackGui then return 0 end
    
    local display = backpackGui:FindFirstChild("Display")
    if not display then return 0 end
    
    local imageButtonCount = 0
    for _, child in ipairs(display:GetChildren()) do
        if child:IsA("ImageButton") then
            imageButtonCount = imageButtonCount + 1
        end
    end
    return imageButtonCount
end

function getCurrentRodEnchant()
    local fishingRods = dataStore:Get("Inventory.Fishing Rods")
    if not fishingRods then return nil end
    
    for _, rodData in ipairs(fishingRods) do
        if type(rodData) == "table" and rodData.Metadata then
            return rodData.Metadata.EnchantId
        end
    end
    return nil
end

local Paragraph = Shop:Paragraph({
    Title = "Enchant Status",
    Desc = "Enchant Stones: 0 | Current Enchant: None",
})

spawn( LPH_NO_VIRTUALIZE( function()
    while task.wait(1) do
        local enchantStones = findEnchantStones()
        local totalStones = 0
        for _, stone in ipairs(enchantStones) do
            totalStones = totalStones + stone.Quantity
        end
        
        local currentEnchantId = getCurrentRodEnchant()
        local currentEnchantName = "None"
        for name, id in pairs(enchantIdMap) do
            if id == currentEnchantId then
                currentEnchantName = name
                break
            end
        end
        
        Paragraph:SetDesc("Enchant Stones: " .. totalStones .. " | Current Enchant: " .. currentEnchantName)
    end
end))

Shop:Button({
    Title = "Teleport to Altar",
    Callback = function()
        local targetCFrame = CFrame.new(3234.83667, -1302.85486, 1398.39087, 0.464485794, -1.12043161e-07, -0.885580599, 6.74793981e-08, 1, -9.11265872e-08, 0.885580599, -1.74314394e-08, 0.464485794)
        local character = player.Character
        if character then
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                humanoidRootPart.CFrame = targetCFrame
            end
        end
    end
})

local TargetEnchantDropdown = Shop:Dropdown({
    Title = "Target Enchant",
    Values = enchantNames,
    Value = _G.TargetEnchant or enchantNames[1],
    Callback = function(selected)
        _G.TargetEnchant = selected
        SaveConfig()
    end
})

Shop:Toggle({
    Title = "Auto Enchant",
    Value = _G.AutoEnchant,
    Callback = function(value)
        _G.AutoEnchant = value
        SaveConfig()
    end
})

spawn(LPH_NO_VIRTUALIZE(function()
    while wait() do
        if _G.AutoEnchant then
            local currentEnchantId = getCurrentRodEnchant()
            local targetEnchantId = enchantIdMap[_G.TargetEnchant]            
            if currentEnchantId == targetEnchantId then
                _G.AutoEnchant = false
                break
            end            
            local enchantStones = findEnchantStones()
            if #enchantStones > 0 then
                local enchantStone = enchantStones[1]
                local args = { enchantStone.UUID, "EnchantStones" }
                pcall(function()
                    equipItemRemote:FireServer(unpack(args))
                end)
                wait(1)
                local imageButtonCount = countDisplayImageButtons()
                local slotNumber = imageButtonCount - 2
                if slotNumber < 1 then slotNumber = 1 end
                pcall(function()
                    equipToolRemote:FireServer(slotNumber)
                end)
                wait(1)
                pcall(function()
                    activateAltarRemote:FireServer()
                end)
            end
            wait(5)
        end
    end
end))

Shop:Toggle({
    Title = "Auto Sell Enchant Stone",
    Value = _G.AutoSellEnchant,
    Callback = function(value)
        _G.AutoSellEnchant = value
        SaveConfig()
    end
})

local AutoSellRunning = false

spawn( LPH_NO_VIRTUALIZE( function()
    while true do
        task.wait(1)
        if _G.AutoSellEnchant and not AutoSellRunning then
            AutoSellRunning = true
            
            repeat
                task.wait(0.5)
                
                local inventory = dataStore:Get("Inventory.Items")
                if not inventory then continue end
                
                local enchantStones = {}
                for key, itemData in pairs(inventory) do
                    if type(itemData) == "table" and itemData.Metadata then
                        if itemData.Metadata.Name == "Enchant Stone" or itemData.Id == 10 then
                            table.insert(enchantStones, {
                                UUID = itemData.UUID,
                                Name = itemData.Metadata.Name
                            })
                        end
                    end
                end
                
                for _, stone in pairs(enchantStones) do
                    if not _G.AutoSellEnchant then break end
                    local args = {stone.UUID}
                    pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/SellItem"):InvokeServer(unpack(args))
                    end)
                    task.wait(0.2)
                end
                
            until not _G.AutoSellEnchant
            AutoSellRunning = false
        end
    end
end))


Shop:Section({ Title = "Weather Machine" })
local WeatherEvents = {
    "Wind",
    "Cloudy", 
    "Snow",
    "Storm",
    "Radiant",
    "Shark Hunt"
}

local selectedWeathers = {}
local autoBuyEnabled = false
local purchaseRemote = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseWeatherEvent"]

local WeatherDropdown = Shop:Dropdown({
    Title = "Select Weather Events",
    Values = WeatherEvents,
    Value = selectedWeathers,
    Multi = true,
    AllowNone = true,
    Callback = function(options) 
        selectedWeathers = options
    end
})

local AutoBuyToggle = Shop:Toggle({
    Title = "Auto Buy Weather Machine",
    Default = false,
    Callback = function(state) 
        autoBuyEnabled = state
        if state then
            while autoBuyEnabled and task.wait() do
                for _, weather in ipairs(selectedWeathers) do
                    pcall(function()
                        purchaseRemote:InvokeServer(weather)
                    end)
                end
            end
        end
    end
})

Shop:Section({ Title = "Bait" })
local Net = RepStorage.Packages._Index["sleitnick_net@0.2.0"].net
local Baits = {
    ["Topwater Bait"] = 10, 
    ["Luck Bait"] = 2,        
    ["Midnight Bait"] = 3,     
    ["Nature Bait"] = 4,      
    ["Chroma Bait"] = 5,       
    ["Dark Matter Bait"] = 6, 
    ["Corrupt Bait"] = 15,   
    ["Aether Bait"] = 16,     
}

Shop:Dropdown({
    Title = "Select Bait",
    Values = { "Topwater Bait", "Luck Bait", "Midnight Bait", "Nature Bait", "Chroma Bait", "Dark Matter Bait", "Corrupt Bait", "Aether Bait" },
    Value = "Topwater Bait",
    Callback = function(option)
        SelectedBait = Baits[option]
    end
})

Shop:Button({
    Title = "Buy Selected Bait", 
    Desc = "Purchase + Equip",
    Locked = false,
    Callback = function()
        if SelectedBait then
            pcall(function()
                local hasBait = false
                local inventory = dataStore:Get("Inventory")
                if inventory and inventory.Baits then
                    for _, bait in ipairs(inventory.Baits) do
                        if bait.Id == SelectedBait then
                            hasBait = true
                            break
                        end
                    end
                end
                
                if not hasBait then
                    Net["RF/PurchaseBait"]:InvokeServer(SelectedBait)
                    task.wait(0.5)
                end
                
                Net["RE/EquipBait"]:FireServer(SelectedBait)
            end)
        end
    end
})

Teleport:Section({ Title = "Island" })
local TeleportLocations = {
    ["Kohana"] = CFrame.new(-617.281433, 3.30004835, 565.878357, 0.876953125, -9.79836869e-08, 0.480575919, 5.34272928e-08, 1, 1.06394126e-07, -0.480575919, -6.76267931e-08, 0.876953125),
    ["Coral Reefs"] = CFrame.new(-3134.85205, 5.00295353, 2136.01367, 0.987203121, 9.21542753e-09, 0.159467891, -6.9573014e-09, 1, -1.47186867e-08, -0.159467891, 1.34208671e-08, 0.987203121),
    ["Crafter Island"] = CFrame.new(1001.42041, 2.77225208, 5151.07178, 0.963777483, 2.44837217e-09, -0.266707599, -8.64836736e-09, 1, -2.20718466e-08, 0.266707599, 2.35789344e-08, 0.963777483),
    ["Esoteric Depths"] = CFrame.new(2032.10999, 27.3972206, 1390.20667, -0.402685791, -1.71636874e-08, 0.915338278, -6.8642021e-09, 1, 1.57314197e-08, -0.915338278, 5.17520124e-11, -0.402685791),
    ["Fisherman Island"] = CFrame.new(13.1889982, 24.5348186, 2904.28809, 0.991550922, -8.09027441e-08, 0.129718229, 7.46199689e-08, 1, 5.32943432e-08, -0.129718229, -4.31644835e-08, 0.991550922),
    ["Kohana Vulcano"] = CFrame.new(-591.781494, 40.6086769, 149.605621, -0.690379977, 1.43661989e-08, -0.723446965, -2.95755296e-08, 1, 4.8081688e-08, 0.723446965, 5.45909629e-08, -0.690379977),
    ["Loot Isle"] = CFrame.new(-3616.47534, 4.85140657, -863.686218, -0.501687109, 3.99627211e-08, -0.865049124, -8.32503346e-08, 1, 9.4478267e-08, 0.865049124, 1.19414167e-07, -0.501687109),
    ["Tropical Grove"] = CFrame.new(-2093.49512, 6.26801682, 3699.17993, 0.586044073, -4.36226735e-08, -0.810279191, -1.45249288e-08, 1, -6.43419256e-08, 0.810279191, 4.94764478e-08, 0.586044073),
    ["Weather Machine"] = CFrame.new(-1517.78271, 2.87499976, 1909.10144, -0.980277359, 7.81242182e-09, -0.197626576, -9.66207647e-09, 1, 8.74575505e-08, 0.197626576, 8.76421424e-08, -0.980277359),
    ["Treasure Room"] = CFrame.new(-3600.3501, -291.287964, -1642.33704, -1, 0, 0, 0, -1, 0, 0, 0, 1),
    ["Altar"] = CFrame.new(3264.05518, -1301.53027, 1376.69006, 0.811563194, 8.69882566e-09, -0.584264636, -4.91663563e-08, 1, -5.34052162e-08, 0.584264636, 7.20678699e-08, 0.811563194),
}

local LocationNames = {}
for name, _ in pairs(TeleportLocations) do
    table.insert(LocationNames, name)
end

Teleport:Dropdown({
    Title = "Teleport Locations",
    Values = LocationNames,
    Default = LocationNames[1],
    Callback = function(option)
        SelectedLocation = TeleportLocations[option]
    end
})

Teleport:Button({
    Title = "Teleport to Selected",
    Callback = function()
        if SelectedLocation then
            local hrp = player.Character.HumanoidRootPart        
            hrp.CFrame = SelectedLocation
        end
    end
})

local Net = require(ReplicatedStorage.Packages.Net)

Shop:Section({ Title = "Rod" })
local FishingRods = {
    ["Luck Rod"] = {id = 79},
    ["Carbon Rod"] = {id = 76},
    ["Grass Rod"] = {id = 85},
    ["Demascus Rod"] = {id = 77},
    ["Ice Rod"] = {id = 78},
    ["Lucky Rod"] = {id = 4},
    ["Midnight Rod"] = {id = 80},
    ["Steam Punk"] = {id = 6},
    ["Chrome Rod"] = {id = 7},
    ["Astral Rod"] = {id = 5},
    ["Ares Rod"] = {id = 126},
    ["Angler Rod"] = {id = 168},
}

local RodNames = {}
for name, _ in pairs(FishingRods) do
    table.insert(RodNames, name)
end

local SelectedRod = nil

Shop:Dropdown({
    Title = "Select Fishing Rod",
    Values = RodNames,
    Default = RodNames[1],
    Callback = function(option)
        SelectedRod = FishingRods[option]
    end
})

Shop:Button({
    Title = "Buy Selected Rod",
    Callback = function()
        if SelectedRod then
            local args = {SelectedRod.id}
            game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/PurchaseFishingRod"):InvokeServer(unpack(args))
        end
    end
})

ConfigTab:Section({ Title = "Position" })
local savedPositions = {}
local positionFile = "saved_positions.json"
local Dropdown

function loadPositions()
    if isfile(positionFile) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(positionFile))
        end)
        if success and type(data) == "table" then
            savedPositions = data
        end
    end
end

function savePositions()
    pcall(function()
        writefile(positionFile, HttpService:JSONEncode(savedPositions))
    end)
end

function updateDropdown()
    local values = {}
    for name in pairs(savedPositions) do
        table.insert(values, name)
    end
    table.sort(values)
    
    if Dropdown then
        if #values > 0 then
            Dropdown:Refresh(values)
            _G.SelectedPositionName = values[1]
        else
            Dropdown:Refresh({"No saved positions"})
            _G.SelectedPositionName = ""
        end
    end
end

local Input = ConfigTab:Input({
    Title = "Position Name",
    Value = "",
    Placeholder = "Enter position name...",
    Callback = function(input)
        _G.SelectedPositionName = input
    end
})

Dropdown = ConfigTab:Dropdown({
    Title = "Saved Positions",
    Values = {"Loading..."},
    Callback = function(option)
        if option ~= "No saved positions" and option ~= "Loading..." then
            _G.SelectedPositionName = option
        end
    end
})

loadPositions()
updateDropdown()

local SaveButton = ConfigTab:Button({
    Title = "Save Position",
    Callback = function()
        if _G.SelectedPositionName and _G.SelectedPositionName ~= "" then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                savedPositions[_G.SelectedPositionName] = {
                    Position = {hrp.Position.X, hrp.Position.Y, hrp.Position.Z},
                    Orientation = {hrp.Orientation.X, hrp.Orientation.Y, hrp.Orientation.Z}
                }
                savePositions()
                updateDropdown()
            end
        end
    end
})

local TeleportButton = ConfigTab:Button({
    Title = "Teleport",
    Callback = function()
        if _G.SelectedPositionName and savedPositions[_G.SelectedPositionName] then
            local posData = savedPositions[_G.SelectedPositionName]
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                hrp.CFrame = CFrame.new(
                    Vector3.new(posData.Position[1], posData.Position[2], posData.Position[3])
                ) * CFrame.Angles(
                    math.rad(posData.Orientation[1]),
                    math.rad(posData.Orientation[2]),
                    math.rad(posData.Orientation[3])
                )
            end
        end
    end
})

local DeleteButton = ConfigTab:Button({
    Title = "Delete Position",
    Callback = function()
        if _G.SelectedPositionName and savedPositions[_G.SelectedPositionName] then
            savedPositions[_G.SelectedPositionName] = nil
            savePositions()
            updateDropdown()
            _G.SelectedPositionName = ""
        end
    end
})

ConfigTab:Section({ Title = "Webhook" })
local TeleportService = game:GetService("TeleportService")

local JobIdInput = ConfigTab:Input({
    Title = "Job ID",
    Value = "",
    Placeholder = "Enter Job ID...",
    Callback = function(input)
        _G.JobIdToJoin = input
    end
})
local JoinButton = ConfigTab:Button({
    Title = "Join Server",
    Callback = function()
        if _G.JobIdToJoin and _G.JobIdToJoin ~= "" then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, _G.JobIdToJoin, Players.LocalPlayer)
        end
    end
})

ConfigTab:Section({ Title = "Webhook Notifer" })
local LocalPlayer = Players.LocalPlayer

local Settings = { WebhookURL = _G.WebhookURL, DetectNewFishActive = _G.DetectNewFishActive, WebhookRarities = _G.WebhookRarities, ScanInterval = 3 }
local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local ItemUtility, Replion, DataService
local fishDB = {}
local rarityList = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "SECRET"}
local rarityToColor = { Common = 0xFFFFFF, Uncommon = 0x00FF00, Rare = 0x0000FF, Epic = 0x800080, Legendary = 0xFFA500, Mythic = 0xFF0000, SECRET = 0xFFB6C1 }
local tierToRarity = { [1] = "Common", [2] = "Uncommon", [3] = "Rare", [4] = "Epic", [5] = "Legendary", [6] = "Mythic", [7] = "SECRET" }
local knownFishUUIDs = {}

pcall(function()
    ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)
    Replion = require(ReplicatedStorage.Packages.Replion)
    DataService = Replion.Client:WaitReplion("Data")
end)

function buildFishDatabase()
    local itemsContainer = ReplicatedStorage:WaitForChild("Items")
    if not itemsContainer then return end
    
    for _, itemModule in ipairs(itemsContainer:GetChildren()) do
        local success, itemData = pcall(require, itemModule)
        if success and type(itemData) == "table" and itemData.Data and itemData.Data.Type == "Fishes" then
            local data = itemData.Data
            if data.Id and data.Name then
                fishDB[data.Id] = {
                    Name = data.Name, Tier = data.Tier, Icon = data.Icon, 
                    SellPrice = itemData.SellPrice 
                }
            end
        end
    end
end

function getInventoryFish()
    if not (DataService and ItemUtility) then return {} end
    local inventoryItems = DataService:GetExpect({"Inventory", "Items"})
    local fishes = {}
    for _, v in pairs(inventoryItems) do
        local itemData = ItemUtility.GetItemDataFromItemType("Items", v.Id)
        if itemData and itemData.Data.Type == "Fishes" then
            table.insert(fishes, {Id = v.Id, UUID = v.UUID, Metadata = v.Metadata})
        end
    end
    return fishes
end

function getPlayerCoins()
    if not DataService then return "N/A" end
    local success, coins = pcall(function() return DataService:Get("Coins") end)
    if success and coins then return string.format("%d", coins):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "") end
    return "N/A"
end

function getThumbnailURL(assetString)
    local assetId = assetString:match("rbxassetid://(%d+)") if not assetId then return nil end
    local api = string.format("https://thumbnails.roblox.com/v1/assets?assetIds=%s&type=Asset&size=420x420&format=Png", assetId)
    local success, response = pcall(function() return HttpService:JSONDecode(game:HttpGet(api)) end)
    return success and response and response.data and response.data[1] and response.data[1].imageUrl
end

function sendTestWebhook()
    if not req or not Settings.WebhookURL or not Settings.WebhookURL:match("discord.com/api/webhooks") then 
        WindUI:Notify({
            Title = "Error", 
            Content = "Webhook URL Empty"}); return end

    local payload = {embeds = {{
        title = "✅ Test Webhook Connected", 
        description = "Webhook connection successful!", 
        color = 0x00FF00
    }}}
    pcall(function() req({
        Url = Settings.WebhookURL, 
        Method = "POST", 
        Headers = {["Content-Type"] = "application/json"}, 
        Body = HttpService:JSONEncode(payload)}) end)
end

function sendNewFishWebhook(newlyCaughtFish)
    if not req or not Settings.WebhookURL or not Settings.WebhookURL:match("discord.com/api/webhooks") then return end
    local newFishDetails = fishDB[newlyCaughtFish.Id]
    if not newFishDetails then return end
    local newFishRarity = tierToRarity[newFishDetails.Tier] or "Unknown"
    if #Settings.WebhookRarities > 0 and not table.find(Settings.WebhookRarities, newFishRarity) then return end

    local fishWeight = (newlyCaughtFish.Metadata and newlyCaughtFish.Metadata.Weight and string.format("%.2f kg", newlyCaughtFish.Metadata.Weight)) or "N/A"
    local mutation = (newlyCaughtFish.Metadata and newlyCaughtFish.Metadata.VariantId and tostring(newlyCaughtFish.Metadata.VariantId)) or "None"
    local sellPrice = (newFishDetails.SellPrice and string.format("%d", newFishDetails.SellPrice):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "") .. " Coins") or "N/A"
    local currentCoins = getPlayerCoins()

    local totalFishInInventory = #getInventoryFish()
    local backpackInfo = string.format("%d/5000", totalFishInInventory)

    local content = ""
    if newFishRarity == "SECRET" then
        content = "@everyone"
    end

    local payload = {
        username = "LimeHub Bot",
        avatar_url = "https://cdn.discordapp.com/attachments/1408262889437134942/1420411647054446683/limehub.jpeg?ex=68d54cee&is=68d3fb6e&hm=bf50d2083093decbeea5146165c85dd351801cfa2bffe1dd711907b308af1c47&",
        content = content,
        embeds = {{
            title = "🎣 New Fish Caught!", 
            color = rarityToColor[newFishRarity],
            fields = {
                { name = "User", value = tostring(game.Players.LocalPlayer.Name), inline = true },
                { name = "Fish Name", value = "**" .. newFishDetails.Name .. "**", inline = false },
                { name = "Rarity", value = newFishRarity, inline = true },
                { name = "Weight", value = fishWeight, inline = true },
                { name = "Mutation", value = mutation, inline = true },
                { name = "Sell Price", value = sellPrice, inline = true },
                { name = "Backpack", value = backpackInfo, inline = true }
            },
            thumbnail = { url = getThumbnailURL(newFishDetails.Icon) },
            footer = { text = "Current Coins: " .. currentCoins .. " | " .. os.date("%d %B %Y, %H:%M:%S") }
        }}
    }

    if pcall(function() req({Url = Settings.WebhookURL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(payload)}) end) then
    else NatUI:Notify({Title = "Error", Content = "Failed to send webhook"}) end
end

ConfigTab:Input({
    Title = "URL Webhook", 
    Placeholder = "Paste your Discord Webhook URL here", 
    Value = _G.WebhookURL, 
    Callback = function(text) 
        _G.WebhookURL = text
        SaveConfig()
    end
})

ConfigTab:Toggle({
    Title = "Send Webhook", 
    Value = _G.DetectNewFishActive,
    Callback = function(state) 
        _G.DetectNewFishActive = state
        SaveConfig()
    end
})

ConfigTab:Dropdown({
    Title = "Rarity Filter", 
    Values = rarityList, 
    Multi = true, 
    AllowNone = true, 
    Value = _G.WebhookRarities, 
    Callback = function(selected_options) 
        _G.WebhookRarities = selected_options
        SaveConfig()
    end
})

ConfigTab:Button({
    Title = "Test Webhook", 
    Callback = sendTestWebhook
})

buildFishDatabase()
spawn( LPH_NO_VIRTUALIZE( function()
    local initialFishList = getInventoryFish()
    for _, fish in ipairs(initialFishList) do
        if fish and fish.UUID then knownFishUUIDs[fish.UUID] = true end
    end
end))
spawn( LPH_NO_VIRTUALIZE( function()
    while wait(0.1) do
        task.wait(Settings.ScanInterval)
        if _G.DetectNewFishActive then
            local currentFishList = getInventoryFish()
            for _, fish in ipairs(currentFishList) do
                if fish and fish.UUID and not knownFishUUIDs[fish.UUID] then
                    knownFishUUIDs[fish.UUID] = true
                    sendNewFishWebhook(fish)
                end
            end
        end
    end
end))

local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

function CreateWaterPlatform()
    local oldPlatform = workspace:FindFirstChild("WaterPlatform")
    if oldPlatform then
        oldPlatform:Destroy()
    end
    
    local character = LocalPlayer.Character
    if not character then
        character = LocalPlayer.CharacterAdded:Wait()
    end
    
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    local waterPlatform = Instance.new("Part")
    waterPlatform.Name = "WaterPlatform"
    waterPlatform.Size = Vector3.new(10, 1, 10)
    waterPlatform.Position = Vector3.new(humanoidRootPart.Position.X, -1.5, humanoidRootPart.Position.Z)
    waterPlatform.Color = Color3.fromRGB(0, 100, 255)
    waterPlatform.Material = Enum.Material.Glass
    waterPlatform.Transparency = 1.0
    waterPlatform.Anchored = true
    waterPlatform.CanCollide = true
    waterPlatform.Parent = workspace
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if character and humanoidRootPart and _G.WaterPlatformEnabled then
            waterPlatform.Position = Vector3.new(
                humanoidRootPart.Position.X,
                -1.5,
                humanoidRootPart.Position.Z
            )
        end
    end)
    
    return waterPlatform, connection
end

local platform, connection = CreateWaterPlatform()
_G.WaterPlatform = platform
_G.WaterPlatformConnection = connection

Misc:Section({ Title = "Local Player" })

local originalSettings = {
    QualityLevel = settings().Rendering.QualityLevel,
    MeshCacheSize = settings().Rendering.MeshCacheSize,
    EagerBulkExecution = settings().Rendering.EagerBulkExecution,
    FrameRateManager = settings().Rendering.FrameRateManager
}

local originalLighting = {
    GlobalShadows = game:GetService("Lighting").GlobalShadows,
    Technology = game:GetService("Lighting").Technology,
    Brightness = game:GetService("Lighting").Brightness,
    Ambient = game:GetService("Lighting").Ambient
}

local originalTerrain = {
    WaterReflectance = workspace.Terrain.WaterReflectance,
    WaterTransparency = workspace.Terrain.WaterTransparency,
    WaterWaveSize = workspace.Terrain.WaterWaveSize,
    WaterWaveSpeed = workspace.Terrain.WaterWaveSpeed
}

local originalGravity = workspace.Gravity

function BoostFPS()
    settings().Rendering.QualityLevel = 0
    settings().Rendering.MeshCacheSize = 0
    settings().Rendering.EagerBulkExecution = false
    settings().Rendering.FrameRateManager = 0
    
    game:GetService("Lighting").GlobalShadows = false
    game:GetService("Lighting").Technology = "Legacy"
    game:GetService("Lighting").Brightness = 0
    game:GetService("Lighting").Ambient = Color3.new(0,0,0)
    
    for _, effect in pairs(game:GetService("Lighting"):GetChildren()) do
        effect:Destroy()
    end
    
    workspace.Terrain.WaterReflectance = 0
    workspace.Terrain.WaterTransparency = 1
    workspace.Terrain.WaterWaveSize = 0
    workspace.Terrain.WaterWaveSpeed = 0
    
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Material = "Plastic"
                    part.Reflectance = 0
                    part.Transparency = 0.5
                elseif part:IsA("Decal") or part:IsA("Texture") then
                    part:Destroy()
                elseif part:IsA("ParticleEmitter") or part:IsA("Beam") or part:IsA("Fire") or part:IsA("Smoke") then
                    part:Destroy()
                end
            end
        end
    end    
    
    game:GetService("RunService"):Set3dRenderingEnabled(false)
    workspace.Gravity = 0
end

function ResetFPS()
    settings().Rendering.QualityLevel = originalSettings.QualityLevel
    settings().Rendering.MeshCacheSize = originalSettings.MeshCacheSize
    settings().Rendering.EagerBulkExecution = originalSettings.EagerBulkExecution
    settings().Rendering.FrameRateManager = originalSettings.FrameRateManager
    
    game:GetService("Lighting").GlobalShadows = originalLighting.GlobalShadows
    game:GetService("Lighting").Technology = originalLighting.Technology
    game:GetService("Lighting").Brightness = originalLighting.Brightness
    game:GetService("Lighting").Ambient = originalLighting.Ambient
    
    workspace.Terrain.WaterReflectance = originalTerrain.WaterReflectance
    workspace.Terrain.WaterTransparency = originalTerrain.WaterTransparency
    workspace.Terrain.WaterWaveSize = originalTerrain.WaterWaveSize
    workspace.Terrain.WaterWaveSpeed = originalTerrain.WaterWaveSpeed
    
    game:GetService("RunService"):Set3dRenderingEnabled(true)
    workspace.Gravity = originalGravity
end

Misc:Toggle({
    Title = "Boost FPS",
    Default = false,
    Callback = function(value)
    _G.BoostFPS = value
        if value then
            BoostFPS()
        else
            ResetFPS()
        end
        SaveConfig()
    end
})

Misc:Toggle({
    Title = "Walk on Water",
    Default = _G.WaterPlatformEnabled,
    Callback = function(value)
        _G.WaterPlatformEnabled = value
        SaveConfig()
        
        if value then
            local platform, connection = CreateWaterPlatform()
            _G.WaterPlatform = platform
            _G.WaterPlatformConnection = connection
        else
            if _G.WaterPlatform then
                _G.WaterPlatform:Destroy()
                _G.WaterPlatform = nil
            end
            if _G.WaterPlatformConnection then
                _G.WaterPlatformConnection:Disconnect()
                _G.WaterPlatformConnection = nil
            end
        end
    end
})

LocalPlayer.CharacterAdded:Connect(function()
    if _G.WaterPlatformEnabled then
        if _G.WaterPlatform then
            _G.WaterPlatform:Destroy()
        end
        if _G.WaterPlatformConnection then
            _G.WaterPlatformConnection:Disconnect()
        end
        
        local platform, connection = CreateWaterPlatform()
        _G.WaterPlatform = platform
        _G.WaterPlatformConnection = connection
    end
end)

local UserInputService = game:GetService("UserInputService")

function infJump()
    local char = plr.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end

UserInputService.JumpRequest:Connect(function()
    if _G.InfJumpEnabled then
        infJump()
    end
end)

Misc:Toggle({
    Title = "Infinite Jump",
    Default = _G.InfJumpEnabled,
    Callback = function(value)
        _G.InfJumpEnabled = value
        SaveConfig()
    end
})

function setWalkSpeed(speed)
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = speed
    end
end

local InputWalk = Misc:Input({
    Title = "Character Speed",
    Value = tostring(_G.InputWalkSpeed),
    InputIcon = "zap",
    Type = "Input",
    Placeholder = "Enter speed...",
    Callback = function(input)
        _G.InputWalkSpeed = tonumber(input)
        SaveConfig()
    end
})

local ApplyWalk = Misc:Button({
    Title = "Apply Speed",
    Locked = false,
    Callback = function()
        if _G.InputWalkSpeed then
            setWalkSpeed(_G.InputWalkSpeed)
        end
    end
})

local ResetWalk = Misc:Button({
    Title = "Reset Speed",
    Locked = false,
    Callback = function()
        setWalkSpeed(16)
        _G.InputWalkSpeed = 16
        SaveConfig()
    end
})

local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

spawn( LPH_NO_VIRTUALIZE( function()
    while true do
        wait(300)
        
        if isMobile then
            local screenSize = workspace.CurrentCamera.ViewportSize
            local centerX, centerY = screenSize.X/2, screenSize.Y/2
            VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
            wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
        else
            local screenSize = workspace.CurrentCamera.ViewportSize
            local centerX, centerY = screenSize.X/2, screenSize.Y/2
            VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
            wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
        end
    end
end))

local PlayerDropdown = Trade:Dropdown({
    Title = "Select Player",
    Values = {},
    Value = "",
    Callback = function(selected)
        _G.SelectedPlayer = selected
        SaveConfig()
    end
})

local RefreshButton = Trade:Button({
    Title = "Refresh Player List",
    Callback = function()
        local players = {}
        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                table.insert(players, player.Name)
            end
        end
        PlayerDropdown:Refresh(players)
    end
})

local RarityDropdown = Trade:Dropdown({
    Title = "Rarity Filter",
    Values = {"Common", "Uncommon", "Rare", "Epic", "Legend", "Mythic", "Secret"},
    Value = "Common",
    Callback = function(selected)
        _G.SelectedRarity = selected
        SaveConfig()
    end
})

local QuantityInput = Trade:Input({
    Title = "Quantity",
    Value = "1",
    Placeholder = "Enter quantity...",
    Callback = function(input)
        _G.TradeQuantity = tonumber(input) or 1
        SaveConfig()
    end
})

local AutoTradeToggle = Trade:Toggle({
    Title = "Auto Trade",
    Value = _G.AutoTrade,
    Callback = function(value)
        _G.AutoTrade = value
        SaveConfig()
    end
})

local AutoAcceptToggle = Trade:Toggle({
    Title = "Auto Accept Trade",
    Value = _G.AutoAccept,
    Callback = function(value)
        _G.AutoAccept = value
        SaveConfig()
    end
})

local RarityToId = {
    Common = 1,
    Uncommon = 2,
    Rare = 3,
    Epic = 4,
    Legend = 5,
    Mythic = 6,
    Secret = 7
}

function GetItemsByRarity(rarityName)
    if not (DataService and ItemUtility) then return {} end
    local targetRarityId = RarityToId[rarityName]
    if not targetRarityId then return {} end
    
    local inventoryItems = DataService:GetExpect({"Inventory", "Items"})
    local items = {}
    
    for _, v in pairs(inventoryItems) do
        local itemData = ItemUtility.GetItemDataFromItemType("Items", v.Id)
        if itemData and itemData.Data and itemData.Data.Tier == targetRarityId then
            table.insert(items, {
                Id = v.Id,
                UUID = v.UUID,
                Metadata = v.Metadata,
                Rarity = itemData.Data.Tier
            })
        end
    end
    return items
end

function InitiateTrade(targetUserId, itemUUID)
    local args = {targetUserId, itemUUID}
    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net"):WaitForChild("RF/InitiateTrade"):InvokeServer(unpack(args))
end

local AutoTradeRunning = false

spawn(function()
    while true do
        task.wait(1)
        if _G.AutoTrade and _G.SelectedPlayer and _G.SelectedRarity and not AutoTradeRunning then
            AutoTradeRunning = true
            
            repeat
                task.wait(0.5)
                
                local targetPlayer = nil
                for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                    if player.Name == _G.SelectedPlayer then
                        targetPlayer = player
                        break
                    end
                end
                
                if targetPlayer then
                    local items = GetItemsByRarity(_G.SelectedRarity)
                    local quantity = _G.TradeQuantity or 1
                    
                    for i = 1, math.min(quantity, #items) do
                        if not _G.AutoTrade then break end
                        local item = items[i]
                        if item and item.UUID then
                            pcall(function()
                                InitiateTrade(targetPlayer.UserId, item.UUID)
                            end)
                            task.wait(0.3)
                        end
                    end
                else
                    task.wait(2)
                end
                
            until not _G.AutoTrade
            AutoTradeRunning = false
        end
    end
end)

local AutoAcceptRunning = false

spawn(function()
    while true do
        task.wait(0.5)
        if _G.AutoAccept and not AutoAcceptRunning then
            AutoAcceptRunning = true
            
            repeat
                task.wait(0.1)
                local promptGui = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Prompt")
                if promptGui and promptGui:FindFirstChild("Blackout") then
                    local blackout = promptGui.Blackout
                    if blackout:FindFirstChild("Options") then
                        local options = blackout.Options
                        local yesButton = options:FindFirstChild("Yes")
                        if yesButton then
                            firesignal(yesButton.MouseButton1Click)
                        end
                    end
                end
            until not _G.AutoAccept
            AutoAcceptRunning = false
        end
    end
end)