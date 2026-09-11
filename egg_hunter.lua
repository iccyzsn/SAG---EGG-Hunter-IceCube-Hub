local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local eggUpdateEvent = ReplicatedStorage:WaitForChild("EggUpdate")

local gui = script.Parent
local main = gui:WaitForChild("Main")
local eggList = main:WaitForChild("EggList")
local status = main:WaitForChild("Status")
local toggle = gui:WaitForChild("Toggle")

-- 🎬 Slide in/out animation
local OPEN_POS = UDim2.new(1, -270, 0.5, 0)
local CLOSED_POS = UDim2.new(1, 0, 0.5, 0)
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local isOpen = true

toggle.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    local goal = {Position = isOpen and OPEN_POS or CLOSED_POS}
    TweenService:Create(main, tweenInfo, goal):Play()
end)

-- 🧱 Creates one row per egg type
local rows = {}
local function makeRow(order)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    row.LayoutOrder = order
    row.Parent = eggList
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.fromOffset(18, 18)
    dot.Position = UDim2.new(0, 10, 0.5, -9)
    dot.BackgroundColor3 = Color3.new(1, 1, 1)
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

    return {row = row, dot = dot, name = name, rarity = rarity, count = count}
end

-- 🔄 Live update (works with the server script from before)
eggUpdateEvent.OnClientEvent:Connect(function(eggListData)
    local available = 0

    for i, egg in ipairs(eggListData) do
        rows[i] = rows[i] or makeRow(i)
        local row = rows[i]

        row.name.Text = egg.name
        row.rarity.Text = egg.rarity
        row.rarity.TextColor3 = egg.color
        row.dot.BackgroundColor3 = egg.color
        row.count.Text = egg.count .. "x"

        local inStock = egg.count > 0
        row.count.TextColor3 = inStock
            and Color3.fromRGB(120, 255, 140)  -- 🟢 in stock
            or Color3.fromRGB(120, 120, 130)   -- ⚪ none left

        -- In-stock eggs float to the top of the list
        row.row.LayoutOrder = inStock and i or (100 + i)

        if inStock then available += egg.count end
    end

    status.Text = available > 0
        and ("🔍 " .. available .. " egg(s) on the map!")
        or "💤 No eggs on the map..."
end)
