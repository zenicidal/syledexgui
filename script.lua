-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Automation Settings
local AutoConfig = {
    running = false,
    collection_mode = "ALL", -- Options: "ALL", "IMPORTANT", "OFF"
    current_floor = 1,
    is_hiding = false,
    underground_depth = 12,
}

-- Anti-AFK Protection
player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Robust Bulletproof Noclip
local noclipConnection = nil
local function toggleNoclip(state)
    if state then
        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = RunService.Stepped:Connect(function()
            if AutoConfig.running and player.Character then
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
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
    end
end

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SyleDexGui"
screenGui.ResetOnSpawn = false

local success = pcall(function()
    screenGui.Parent = CoreGui
end)
if not success then
    screenGui.Parent = playerGui
end

-- Main Container Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 160, 0, 165)
mainFrame.Position = UDim2.new(0, 20, 0, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = mainFrame

-- Title Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 5)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "syle dex gui"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainFrame

-- 1. Autofarm Toggle Button
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 140, 0, 34)
toggleButton.Position = UDim2.new(0, 10, 0, 40)
toggleButton.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 14
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Text = "autofarm OFF"
toggleButton.Parent = mainFrame

local uiCorner1 = Instance.new("UICorner")
uiCorner1.CornerRadius = UDim.new(0, 8)
uiCorner1.Parent = toggleButton

toggleButton.MouseButton1Click:Connect(function()
    AutoConfig.running = not AutoConfig.running
    if AutoConfig.running then
        toggleButton.Text = "autofarm ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        toggleNoclip(true)
        print("[syle dex gui] Underground Autofarm Enabled")
    else
        toggleButton.Text = "autofarm OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
        toggleNoclip(false)
        print("[syle dex gui] Autofarm Disabled")
    end
end)

-- 2. Collection Mode Cycle Button (ALL -> IMPORTANT -> OFF)
local collectionButton = Instance.new("TextButton")
collectionButton.Name = "CollectionButton"
collectionButton.Size = UDim2.new(0, 140, 0, 34)
collectionButton.Position = UDim2.new(0, 10, 0, 80)
collectionButton.BackgroundColor3 = Color3.fromRGB(35, 100, 35)
collectionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
collectionButton.TextSize = 12
collectionButton.Font = Enum.Font.GothamBold
collectionButton.Text = "collection: ALL"
collectionButton.Parent = mainFrame

local uiCornerColl = Instance.new("UICorner")
uiCornerColl.CornerRadius = UDim.new(0, 8)
uiCornerColl.Parent = collectionButton

collectionButton.MouseButton1Click:Connect(function()
    if AutoConfig.collection_mode == "ALL" then
        AutoConfig.collection_mode = "IMPORTANT"
        collectionButton.Text = "collection: IMPORTANT"
        collectionButton.BackgroundColor3 = Color3.fromRGB(100, 100, 35)
        print("[syle dex gui] Collection Mode: IMPORTANT (Capsules & Event Items Only)")
    elseif AutoConfig.collection_mode == "IMPORTANT" then
        AutoConfig.collection_mode = "OFF"
        collectionButton.Text = "collection: OFF"
        collectionButton.BackgroundColor3 = Color3.fromRGB(100, 35, 35)
        print("[syle dex gui] Collection Mode: OFF (Machines & Elevator Only)")
    else
        AutoConfig.collection_mode = "ALL"
        collectionButton.Text = "collection: ALL"
        collectionButton.BackgroundColor3 = Color3.fromRGB(35, 100, 35)
        print("[syle dex gui] Collection Mode: ALL (Collecting Everything)")
    end
end)

-- 3. End Run Button
local endRunButton = Instance.new("TextButton")
endRunButton.Name = "EndRunButton"
endRunButton.Size = UDim2.new(0, 140, 0, 34)
endRunButton.Position = UDim2.new(0, 10, 0, 120)
endRunButton.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
endRunButton.TextColor3 = Color3.fromRGB(255, 255, 255)
endRunButton.TextSize = 14
endRunButton.Font = Enum.Font.GothamBold
endRunButton.Text = "end run"
endRunButton.Parent = mainFrame

local uiCorner2 = Instance.new("UICorner")
uiCorner2.CornerRadius = UDim.new(0, 8)
uiCorner2.Parent = endRunButton

endRunButton.MouseButton1Click:Connect(function()
    AutoConfig.running = false
    toggleNoclip(false)
    print("[syle dex gui] Ending run and cleaning up...")
    screenGui:Destroy()
end)

-- Short-Range Micro-Teleportation
local function moveToTarget(targetPosition, surfaceMode)
    local character = player.Character
    if not character or not AutoConfig.running or AutoConfig.is_hiding then return false end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end

    local targetY = surfaceMode and (targetPosition.Y + 3) or (targetPosition.Y - AutoConfig.underground_depth)
    local destination = Vector3.new(targetPosition.X, targetY, targetPosition.Z)

    local startPos = rootPart.Position
    local distance = (startPos - destination).Magnitude
    local steps = math.clamp(math.floor(distance / 15), 2, 10)
    
    for i = 1, steps do
        if not AutoConfig.running or AutoConfig.is_hiding then return false end
        rootPart.CFrame = CFrame.new(startPos:Lerp(destination, i / steps))
        task.wait(0.01)
    end
    
    rootPart.CFrame = CFrame.new(destination)
    return true
end

-- Emergency Underground Hide
local function hideUnderground()
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    AutoConfig.is_hiding = true
    print("[Safety] Twisted spotted! Burrowing deeper...")

    rootPart.CFrame = rootPart.CFrame - Vector3.new(0, AutoConfig.underground_depth, 0)
    task.wait(10)

    AutoConfig.is_hiding = false
    print("[Safety] Resuming run.")
end

-- Threat Check
local function checkThreats()
    local character = player.Character
    if not character then return false end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local name = obj.Name:lower()
            if name:find("twisted") then
                local enemyPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if enemyPart then
                    local flatPlayerPos = Vector3.new(rootPart.Position.X, 0, rootPart.Position.Z)
                    local flatEnemyPos = Vector3.new(enemyPart.Position.X, 0, enemyPart.Position.Z)
                    if (flatPlayerPos - flatEnemyPos).Magnitude < 40 then
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- Entity Scanner
local function getGameObjects()
    local objects = { event_items = {}, capsules = {}, tapes_and_items = {}, healing = {}, machines = {}, elevator = nil }

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local name = obj.Name:lower()
            local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj

            if targetPart then
                if name:find("event") or name:find("token") or name:find("ticket") or name:find("present") or name:find("candy") or name:find("ornament") or name:find("gift") then
                    table.insert(objects.event_items, targetPart)
                elseif name:find("capsule") then
                    table.insert(objects.capsules, targetPart)
                elseif name:find("ichor") or name:find("tape") or name:find("item") then
                    table.insert(objects.tapes_and_items, targetPart)
                elseif name:find("medkit") or name:find("bandage") then
                    table.insert(objects.healing, targetPart)
                elseif name:find("machine") or name:find("generator") or name:find("extractor") then
                    table.insert(objects.machines, targetPart)
                elseif name:find("elevator") or name:find("exit") then
                    objects.elevator = targetPart
                end
            end
        end
    end
    return objects
end

-- Item Handler
local function processItem(item)
    if item and item.Parent then
        moveToTarget(item.Position, false)
        moveToTarget(item.Position, true)
        local prompt = item:FindFirstChildWhichIsA("ProximityPrompt") or item.Parent:FindFirstChildWhichIsA("ProximityPrompt")
        if prompt then
            pcall(function() fireproximityprompt(prompt) end)
        end
        task.wait(0.1)
        moveToTarget(item.Position, false)
    end
end

-- 100% Automatic Skill Check Solver
local function solveSkillChecks()
    local startTime = tick()
    while tick() - startTime < 6 and AutoConfig.running do
        if checkThreats() then break end
        
        for _, gui in ipairs(playerGui:GetDescendants()) do
            if gui:IsA("TextButton") or gui:IsA("ImageButton") then
                local gName = gui.Name:lower()
                local text = gui:IsA("TextButton") and gui.Text:lower() or ""
                
                if gName:find("skill") or gName:find("check") or gName:find("click") or gName:find("target") or text:find("click") or text:find("space") then
                    pcall(function()
                        for _, connection in ipairs(getconnections(gui.MouseButton1Click)) do
                            connection:Fire()
                        end
                        gui.Activated:Fire()
                    end)
                end
            end
        end
        task.wait(0.1)
    end
end

-- Main Gameplay Loop
local function startLoop()
    task.spawn(function()
        while true do
            while not AutoConfig.running do task.wait(0.5) end
            
            if checkThreats() then hideUnderground() end

            print("[syle dex gui] Entering Floor " .. AutoConfig.current_floor)
            local objects = getGameObjects()

            -- Collection Mode Handling
            if AutoConfig.collection_mode == "ALL" then
                -- Collect Everything
                for _, item in ipairs(objects.event_items) do
                    if not AutoConfig.running then break end
                    while checkThreats() do hideUnderground() end
                    processItem(item)
                end
                for _, item in ipairs(objects.capsules) do
                    if not AutoConfig.running then break end
                    while checkThreats() do hideUnderground() end
                    processItem(item)
                end
                for _, item in ipairs(objects.tapes_and_items) do
                    if not AutoConfig.running then break end
                    while checkThreats() do hideUnderground() end
                    processItem(item)
                end
                for _, item in ipairs(objects.healing) do
                    if not AutoConfig.running then break end
                    while checkThreats() do hideUnderground() end
                    processItem(item)
                end

            elseif AutoConfig.collection_mode == "IMPORTANT" then
                -- Collect ONLY Capsules and Event Items
                for _, item in ipairs(objects.event_items) do
                    if not AutoConfig.running then break end
                    while checkThreats() do hideUnderground() end
                    processItem(item)
                end
                for _, item in ipairs(objects.capsules) do
                    if not AutoConfig.running then break end
                    while checkThreats() do hideUnderground() end
                    processItem(item)
                end
            end
            -- If mode is "OFF", skips all item gathering entirely.

            -- Machines (Always run, uses 100% auto-skill check solver)
            for _, mach in ipairs(objects.machines) do
                if not AutoConfig.running then break end
                while checkThreats() do hideUnderground() end

                if mach and mach.Parent then
                    moveToTarget(mach.Position, false)
                    moveToTarget(mach.Position, true)
                    local prompt = mach:FindFirstChildWhichIsA("ProximityPrompt") or mach.Parent:FindFirstChildWhichIsA("ProximityPrompt")
                    if prompt then
                        pcall(function() fireproximityprompt(prompt) end)
                    end
                    
                    solveSkillChecks()
                    moveToTarget(mach.Position, false)
                end
            end

            -- Elevator Escape
            if objects.elevator and AutoConfig.running then
                while checkThreats() do hideUnderground() end
                
                moveToTarget(objects.elevator.Position, false)
                moveToTarget(objects.elevator.Position, true)
                
                local prompt = objects.elevator:FindFirstChildWhichIsA("ProximityPrompt") or objects.elevator.Parent:FindFirstChildWhichIsA("ProximityPrompt")
                if prompt then
                    pcall(function() fireproximityprompt(prompt) end)
                end
                AutoConfig.current_floor = AutoConfig.current_floor + 1
            end

            task.wait(2)
        end
    end)
end

startLoop()
