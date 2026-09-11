local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- 🧪 Wait for the RemoteEvent (10s timeout)
local eggUpdateEvent = ReplicatedStorage:WaitForChild("EggUpdate", 10)

local gui = Instance.new("ScreenGui")
gui.Name = "EggPanel"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(250, 340)
panel.Position = UDim2.new(1, -270, 0.5, -170)
panel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "🥚 EGG HUNTER"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = panel

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 16)
status.Position = UDim2.new(0, 10, 0, 36)
status.BackgroundTransparency = 1
status.Text = "..."
status.TextColor3 = Color3.fromRGB(140, 200, 255)
status.Font = Enum.Font.Gotham
status.TextSize = 13
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = panel

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -16, 1, -70)
list.Position = UDim2.new(0, 8, 0, 58)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.new()
list.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.Parent = list

-- 🎨 One row per egg type
local function updatePanel(eggListData)
    -- Clear old rows
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local available = 0
    for i, egg in ipairs(eggListData) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 44)
        row.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        row.LayoutOrder = i
        row.Parent = list
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

        local dot = Instance.new("Frame")
        dot.Size = UDim2.fromOffset(18, 18)
        dot.Position = UDim2.new(0, 10, 0.5, -9)
        dot.BackgroundColor3 = egg.color
        dot.Parent = row
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

        local name = Instance.new("TextLabel")
        name.Size = UDim2.new(1, -80, 0, 18)
        name.Position = UDim2.new(0, 36, 0, 5)
        name.BackgroundTransparency = 1
        name.Text = egg.name
        name.TextColor3 = Color3.new(1, 1, 1)
        name.Font = Enum.Font.GothamBold
        name.TextSize = 14
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.Parent = row

        local rarity = Instance.new("TextLabel")
        rarity.Size = UDim2.new(1, -80, 0, 14)
        rarity.Position = UDim2.new(0, 36, 0, 23)
        rarity.BackgroundTransparency = 1
        rarity.Text = egg.rarity
        rarity.TextColor3 = egg.color
        rarity.Font = Enum.Font.Gotham
        rarity.TextSize = 11
        rarity.TextXAlignment = Enum.TextXAlignment.Left
        rarity.Parent = row

        local count = Instance.new("TextLabel")
        count.Size = UDim2.fromOffset(40, 44)
        count.Position = UDim2.new(1, -48, 0, 0)
        count.BackgroundTransparency = 1
        count.Text = egg.count .. "x"
        count.TextColor3 = egg.count > 0 and Color3.fromRGB(120, 255, 140) or Color3.fromRGB(120, 120, 130)
        count.Font = Enum.Font.GothamBold
        count.TextSize = 16
        count.Parent = row

        available += egg.count
    end

    status.Text = available > 0 and ("🔍 " .. available .. " eggs on the map!") or "💤 No eggs..."
end

if eggUpdateEvent then
    -- ✅ Server found — go live!
    eggUpdateEvent.OnClientEvent:Connect(updatePanel)
    status.Text = "Connected! Waiting for eggs..."
else
    -- ⚠️ Server NOT found — run test mode so we can at least see the panel
    warn("🥚 EggUpdate RemoteEvent not found — is the Egg Manager script in ServerScriptService? Showing TEST DATA.")
    status.Text = "⚠️ TEST MODE (no server)"
    task.wait(1)
    updatePanel({
        {name = "Basic Egg",   rarity = "Common",    count = 3, color = Color3.fromRGB(200, 200, 200)},
        {name = "Spotted Egg", rarity = "Uncommon",  count = 1, color = Color3.fromRGB(85, 200, 120)},
        {name = "Crystal Egg", rarity = "Rare",      count = 0, color = Color3.fromRGB(80, 150, 255)},
        {name = "Golden Egg",  rarity = "Epic",      count = 1, color = Color3.fromRGB(255, 200, 40)},
        {name = "Void Egg",    rarity = "Legendary", count = 0, color = Color3.fromRGB(255, 60, 120)},
    })
end
