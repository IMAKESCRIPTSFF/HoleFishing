
local Players = game:GetService("Players")

if game.PlaceId ~= 80158232099900 then
    warn("[Auto Bait] Wrong game! Script cancelled.")
    return
end

print("[Auto Bait] Game verified. Starting...")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local BuyBait = ReplicatedStorage
    :WaitForChild("Remotes")
    :WaitForChild("BuyBait")

local baitNames = {
    "Classic", "Meadow", "Tide", "Frost",
    "Reef", "King", "Emerald", "Plasma",
    "Divine", "Ice", "Devil", "Holo"
}

local selected = {}
for _, bait in ipairs(baitNames) do
    selected[bait] = true
end

local autoBuy = true
local unloaded = false

local old = playerGui:FindFirstChild("AutoBuyBaitGUI")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "AutoBuyBaitGUI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(270, 400)
main.Position = UDim2.new(0.5, -135, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(27, 27, 36)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 9)

local function makeButton(parent, name, text, pos, size, color)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Text = text
    b.Position = pos
    b.Size = size
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 13
    b.BorderSizePixel = 0
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    return b
end

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 0, 35)
title.Position = UDim2.fromOffset(10, 0)
title.BackgroundTransparency = 1
title.Text = "Auto Buy Bait"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local minimize = makeButton(
    main, "Minimize", "-", UDim2.new(1, -58, 0, 5),
    UDim2.fromOffset(24, 25), Color3.fromRGB(65, 65, 80)
)

local close = makeButton(
    main, "Close", "X", UDim2.new(1, -30, 0, 5),
    UDim2.fromOffset(24, 25), Color3.fromRGB(175, 55, 55)
)

local list = Instance.new("ScrollingFrame")
list.Name = "BaitList"
list.Position = UDim2.fromOffset(10, 42)
list.Size = UDim2.new(1, -20, 0, 250)
list.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
list.BorderSizePixel = 0
list.ScrollBarThickness = 6
list.CanvasSize = UDim2.fromOffset(0, #baitNames * 34 + 8)
list.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 3)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 4)
padding.PaddingLeft = UDim.new(0, 4)
padding.PaddingRight = UDim.new(0, 4)
padding.Parent = list

local baitButtons = {}

local function refreshBait(bait)
    local b = baitButtons[bait]
    b.Text = bait .. (selected[bait] and "  [ON]" or "  [OFF]")
    b.BackgroundColor3 = selected[bait]
        and Color3.fromRGB(35, 135, 85)
        or Color3.fromRGB(60, 60, 75)
end

for i, bait in ipairs(baitNames) do
    local b = makeButton(
        list, bait, bait .. "  [ON]",
        UDim2.new(), UDim2.new(1, -8, 0, 31),
        Color3.fromRGB(35, 135, 85)
    )

    b.LayoutOrder = i
    baitButtons[bait] = b

    b.Activated:Connect(function()
        selected[bait] = not selected[bait]
        refreshBait(bait)
    end)
end

local autoButton = makeButton(
    main, "AutoBuy", "Auto Buy: ON",
    UDim2.fromOffset(10, 300), UDim2.new(1, -20, 0, 34),
    Color3.fromRGB(35, 135, 85)
)

local status = Instance.new("TextLabel")
status.Position = UDim2.fromOffset(10, 340)
status.Size = UDim2.new(1, -20, 0, 28)
status.BackgroundTransparency = 1
status.Text = "Starting..."
status.TextColor3 = Color3.fromRGB(220, 220, 220)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.Parent = main

autoButton.Activated:Connect(function()
    autoBuy = not autoBuy
    autoButton.Text = "Auto Buy: " .. (autoBuy and "ON" or "OFF")
    autoButton.BackgroundColor3 = autoBuy
        and Color3.fromRGB(35, 135, 85)
        or Color3.fromRGB(160, 55, 55)

    status.Text = autoBuy and "Auto buying..." or "Paused"
end)

local minimized = false
local fullSize = main.Size

minimize.Activated:Connect(function()
    minimized = not minimized
    list.Visible = not minimized
    autoButton.Visible = not minimized
    status.Visible = not minimized
    main.Size = minimized and UDim2.fromOffset(270, 40) or fullSize
    minimize.Text = minimized and "+" or "-"
end)

close.Activated:Connect(function()
    unloaded = true
    autoBuy = false
    gui:Destroy()
end)

gui.Parent = playerGui

task.spawn(function()
    while not unloaded and gui.Parent do
        if autoBuy then
            for _, bait in ipairs(baitNames) do
                if unloaded or not autoBuy then break end

                if selected[bait] then
                    status.Text = "Buying: " .. bait
                    print("[Auto Bait] Invoking BuyBait:", bait)

                    local ok, result = pcall(function()
                        return BuyBait:InvokeServer(bait)
                    end)

                    if not ok then
                        warn("[Auto Bait] Error for " .. bait .. ": " .. tostring(result))
                    else
                        print("[Auto Bait] Response for " .. bait .. ":", result)
                    end

                    task.wait(1)
                end
            end
        else
            task.wait(0.1)
        end
    end
end)

print("[Auto Bait] GUI loaded. Remote:", BuyBait:GetFullName())
