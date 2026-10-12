-- =========================================================
--  SYLE DEX GUI MADE BY ZEN - DANDY'S WORLD AUTOMATION
-- =========================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Configuration
local Config = {
    Running = false,
    CollectionMode = "IMPORTANT", -- "IMPORTANT", "ALL", "OFF"
    UndergroundDepth = 14,
    ThreatRadius = 40,
    HideDuration = 10,
    CurrentFloor = 1
}

-- Anti-AFK
player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Noclip Engine
local noclipConn = nil
local function setNoclip(enabled)
    if enabled then
        if noclipConn then noclipConn:Disconnect() end
        noclipConn = RunService.Stepped:Connect(function()
            if Config.Running and player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        if part.Name == "HumanoidRootPart" then
                            part.AssemblyLinearVelocity = Vector3.zero
                            part.AssemblyAngularVelocity = Vector3.zero
                        end
                    end
                end
            end
        end)
    else
        if noclipConn then
            noclipConn:Disconnect()
            noclipConn = nil
        end
    end
end

-- UI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SyleDexGui_Zen"
screenGui.ResetOnSpawn = false

pcall(function() screenGui.Parent = CoreGui end)
if not screenGui.Parent then screenGui.Parent = playerGui end

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 200, 0, 210)
mainFrame.Position = UDim2.new(0, 20, 0, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 32)
titleLabel.Position = UDim2.new(0, 0, 0, 4)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "syle dex gui made by zen"
titleLabel.TextColor3 = Color3.fromRGB(0, 230, 150)
titleLabel.TextSize = 13
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainFrame

-- 1. Main Autofarm Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 180, 0, 36)
toggleBtn.Position = UDim2.new(0, 10, 0, 40)
toggleBtn.BackgroundColor3 = Color3.fromRGB(120, 35, 35)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 13
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Text = "Autofarm: OFF"
toggleBtn.Parent = mainFrame

local c1 = Instance.new("UICorner")
c1.CornerRadius = UDim.new(0, 8)
c1.Parent = toggleBtn

toggleBtn.MouseButton1Click:Connect(function()
    Config.Running = not Config.Running
    if Config.Running then
        toggleBtn.Text = "Autofarm: ACTIVE"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
        setNoclip(true)
    else
        toggleBtn.Text = "Autofarm: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(120, 35, 35)
        setNoclip(false)
    end
end)

-- 2. Collection Mode Selector
local collectBtn = Instance.new("TextButton")
collectBtn.Size = UDim2.new(0, 180, 0, 36)
collectBtn.Position = UDim2.new(0, 10, 0, 84)
collectBtn.BackgroundColor3 = Color3.fromRGB(180, 130, 0)
collectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
collectBtn.TextSize = 11
collectBtn.Font = Enum.Font.GothamBold
collectBtn.Text = "Mode: IMPORTANT ONLY"
collectBtn.Parent = mainFrame

local c2 = Instance.new("UICorner")
c2.CornerRadius = UDim.new(0, 8)
c2.Parent = collectBtn

collectBtn.MouseButton1Click:Connect(function()
    if Config.CollectionMode == "IMPORTANT" then
        Config.CollectionMode = "ALL"
        collectBtn.Text = "Mode: ALL LOOT"
        collectBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 180)
    elseif Config.CollectionMode == "ALL" then
        Config.CollectionMode = "OFF"
        collectBtn.Text = "Mode: MACHINES ONLY"
        collectBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    else
        Config.CollectionMode = "IMPORTANT"
        collectBtn.Text = "Mode: IMPORTANT ONLY"
        collectBtn.BackgroundColor3 = Color3.fromRGB(180, 130, 0)
    end
end)

-- Status Panel
local statusBox = Instance.new("TextLabel")
statusBox.Size = UDim2.new(0, 180, 0, 36)
statusBox.Position = UDim2.new(0, 10, 0, 126)
statusBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
statusBox.TextColor3 = Color3.fromRGB(180, 180, 200)
statusBox.TextSize = 11
statusBox.Font = Enum.Font.Gotham
statusBox.Text = "Status: Idle | Floor 1"
statusBox.Parent = mainFrame

local c3 = Instance.new("UICorner")
c3.CornerRadius = UDim.new(0, 8)
c3.Parent = statusBox

-- 3. End Run Button
local endBtn = Instance.new("TextButton")
endBtn.Size = UDim2.new(0, 180, 0, 32)
endBtn.Position = UDim2.new(0, 10, 0, 168)
endBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
endBtn.TextColor3 = Color3.fromRGB(200, 70, 70)
endBtn.TextSize = 12
endBtn.Font = Enum.Font.GothamBold
endBtn.Text = "Close Script"
endBtn.Parent = mainFrame

local c4 = Instance.new("UICorner")
c4.CornerRadius = UDim.new(0, 8)
c4.Parent = endBtn

endBtn.MouseButton1Click:Connect(function()
    Config.Running = false
    setNoclip(false)
    screenGui:Destroy()
end)

-- Helpers & Movement
local function tpTo(pos, surface)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end

    local targetY = surface and (pos.Y + 3.2) or (pos.Y - Config.UndergroundDepth)
    char.HumanoidRootPart.CFrame = CFrame.new(pos.X, targetY, pos.Z)
    task.wait(0.03)
    return true
end

local function isThreatNear()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    local root = char.HumanoidRootPart

    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name:lower():find("twisted") then
            local ePart = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
            if ePart then
                local dist = (Vector3.new(root.Position.X, 0, root.Position.Z) - Vector3.new(ePart.Position.X, 0, ePart.Position.Z)).Magnitude
                if dist <= Config.ThreatRadius then
                    return true
                end
            end
        end
    end
    return false
end

local function triggerLockdown()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    statusBox.Text = "Status: ⚠️ THREAT NEAR - HIDING"
    char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame - Vector3.new(0, Config.UndergroundDepth, 0)
    task.wait(Config.HideDuration)
end

local function interact(instance)
    if not instance then return end
    local prompt = instance:FindFirstChildWhichIsA("ProximityPrompt", true) or (instance.Parent and instance.Parent:FindFirstChildWhichIsA("ProximityPrompt", true))
    if prompt then pcall(function() fireproximityprompt(prompt) end) end
end

local function solveSkillCheck(maxDur)
    local start = tick()
    while (tick() - start) < (maxDur or 6) and Config.Running do
        if isThreatNear() then return false end
        for _, gui in ipairs(playerGui:GetDescendants()) do
            if gui:IsA("TextButton") or gui:IsA("ImageButton") then
                local name = gui.Name:lower()
                local text = gui:IsA("TextButton") and gui.Text:lower() or ""
                if name:find("skill") or name:find("check") or name:find("click") or text:find("click") or text:find("space") then
                    pcall(function()
                        for _, conn in ipairs(getconnections(gui.MouseButton1Click)) do conn:Fire() end
                        gui.Activated:Fire()
                    end)
                end
            end
        end
        task.wait(0.08)
    end
    return true
end

local function scanMap()
    local map = { Machines = {}, Capsules = {}, EventItems = {}, OtherLoot = {}, Elevator = nil }
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local name = obj.Name:lower()
        local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or (obj:IsA("BasePart") and obj or nil)
        if part then
            if name:find("machine") or name:find("generator") or name:find("extractor") then table.insert(map.Machines, part)
            elseif name:find("capsule") then table.insert(map.Capsules, part)
            elseif name:find("event") or name:find("token") or name:find("ticket") or name:find("present") or name:find("candy") or name:find("ornament") then table.insert(map.EventItems, part)
            elseif name:find("tape") or name:find("ichor") or name:find("medkit") or name:find("bandage") then table.insert(map.OtherLoot, part)
            elseif name:find("elevator") or name:find("exit") then map.Elevator = part end
        end
    end
    return map
end

local function processTarget(part)
    if not part or not part.Parent or not Config.Running then return end
    if isThreatNear() then triggerLockdown() return end
    tpTo(part.Position, false)
    tpTo(part.Position, true)
    interact(part)
    task.wait(0.15)
    tpTo(part.Position, false)
end

-- Main Loop
task.spawn(function()
    while true do
        while not Config.Running do task.wait(0.5) end
        statusBox.Text = "Status: Scanning Floor " .. Config.CurrentFloor

        if isThreatNear() then triggerLockdown() end
        local map = scanMap()

        -- Machines
        for _, mach in ipairs(map.Machines) do
            if not Config.Running then break end
            if isThreatNear() then triggerLockdown() end
            if mach and mach.Parent then
                statusBox.Text = "Status: Completing Machine"
                tpTo(mach.Position, false)
                tpTo(mach.Position, true)
                interact(mach)
                solveSkillCheck(7)
                tpTo(mach.Position, false)
            end
        end

        -- Collection
        if Config.CollectionMode == "IMPORTANT" or Config.CollectionMode == "ALL" then
            statusBox.Text = "Status: Collecting Important Items"
            for _, cap in ipairs(map.Capsules) do if not Config.Running or isThreatNear() then break end processTarget(cap) end
            for _, evt in ipairs(map.EventItems) do if not Config.Running or isThreatNear() then break end processTarget(evt) end
        end

        if Config.CollectionMode == "ALL" then
            statusBox.Text = "Status: Collecting All Items"
            for _, loot in ipairs(map.OtherLoot) do if not Config.Running or isThreatNear() then break end processTarget(loot) end
        end

        -- Elevator
        if map.Elevator and Config.Running then
            statusBox.Text = "Status: Exiting Floor"
            if isThreatNear() then triggerLockdown() end
            tpTo(map.Elevator.Position, false)
            tpTo(map.Elevator.Position, true)
            interact(map.Elevator)
            task.wait(1)
            Config.CurrentFloor = Config.CurrentFloor + 1
        end

        task.wait(1.5)
    end
end)
