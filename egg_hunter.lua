local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local eggUpdateEvent = ReplicatedStorage:WaitForChild("EggUpdate")

local gui = Instance.new("ScreenGui")
gui.Name = "EggHunterPanel"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- 📋 Main panel
local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(250, 340)
panel.Position = UDim2.new(1, -270, 0.5, -170)
panel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
panel.BackgroundTransparency = 0.1
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
status.Text = "Scanning map..."
status.TextColor3 = Color3.fromRGB(140, 200, 255)
status.Font = Enum.Font.Gotham
status.TextSize = 13
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = panel

-- 📜 Scrollable egg list
local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -16, 1, -70)
list.Position = UDim2.new(0, 8, 0, 58)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 4
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.new()
list.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list

-- 🔘 Toggle button
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.fromOffset(44, 44)
toggle.Position = UDim2.new(1, -60, 0, 10)
toggle.Text = "🥚"
toggle.TextSize = 22
toggle.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
toggle.Parent = gui
Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)
toggle.MouseButton1Click:Connect(function()
    panel.Visible = not panel.Visible
end)

-- Row template
local rows = {}
local function makeRow(order)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    row.LayoutOrder = order
    row.Parent = list
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.fromOffset(18, 18)
    dot.Position = UDim2.new(0, 10, 0.5, -9)
    dot.Parent = row
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, -80, 0, 18)
    name.Position = UDim2.new(0, 36, 0, 5)
    name.BackgroundTransparency = 1
    name.TextColor3 = Color3.new(1, 1, 1)
    name.Font = Enum.Font.GothamBold
    name.TextSize = 14
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.Parent = row

    local rarity = Instance.new("TextLabel")
    rarity.Size = UDim2.new(1, -80, 0, 14)
    rarity.Position = UDim2.new(0, 36, 0, 23)
    rarity.BackgroundTransparency = 1
    rarity.Font = Enum.Font.Gotham
    rarity.TextSize = 11
    rarity.TextXAlignment = Enum.TextXAlignment.Left
    rarity.Parent = row

    local count = Instance.new("TextLabel")
    count.Size = UDim2.fromOffset(40, 44)
    count.Position = UDim2.new(1, -48, 0, 0)
    count.BackgroundTransparency = 1
    count.Font = Enum.Font.GothamBold
    count.TextSize = 16
    count.Parent = row

    return {dot = dot, name = name, rarity = rarity, count = count}
end

-- 🔄 Live update
eggUpdateEvent.OnClientEvent:Connect(function(eggList)
    local available = 0
    for i, egg in ipairs(eggList) do
        rows[i] = rows[i] or makeRow(i)
        local row = rows[i]

        row.name.Text = egg.name
        row.rarity.Text = egg.rarity
        row.rarity.TextColor3 = egg.color
        row.dot.BackgroundColor3 = egg.color
        row.count.Text = egg.count .. "x"
        row.count.TextColor3 = egg.count > 0
            and Color3.fromRGB(120, 255, 140)  -- green = available!
            or Color3.fromRGB(120, 120, 130)   -- gray = none left

        available += egg.count
    end
    status.Text = available > 0
        and ("🔍 " .. available .. " egg(s) on the map!")
        or "💤 No eggs on the map..."
end)
