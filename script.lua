-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Dandy's World Automation Settings
local AutoConfig = {
    running = false,
    current_floor = 1,
    tween_speed = 20, -- Safe studs per second walking speed equivalent
    is_hiding = false,
    underground_depth = 10, -- Depth in studs below surface
}

-- Anti-AFK Protection
player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
    print("[Anti-AFK] Idle kick blocked.")
end)

-- Safe Client Noclip
local noclipConnection = nil
local function toggleNoclip(state)
    if state then
        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = RunService.Stepped:Connect(function()
            if AutoConfig.running and player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
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
    screenGui.Parent = player:WaitForChild("PlayerGui")
end

-- Main Container Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 160, 0, 140)
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

-- 1. Toggle Button
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 140, 0, 38)
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
        print("[syle dex gui] Dandy's World Underground Autofarm Enabled")
    else
        toggleButton.Text = "autofarm OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
        toggleNoclip(false)
        print("[syle dex gui] Autofarm Disabled")
    end
end)

-- 2. End Run Button
local endRunButton = Instance.new("TextButton")
endRunButton.Name = "EndRunButton"
endRunButton.Size = UDim2.new(0, 140, 0, 38)
endRunButton.Position = UDim2.new(0, 10, 0, 88)
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

-- Underground & Surface Movement Handler
local function moveToPosition(targetPosition, surfaceMode)
    local character = player.Character
    if not character or not AutoConfig.running or AutoConfig.is_hiding then return false end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not rootPart or not humanoid then return false end

    local yOffset = surfaceMode and 3 or -AutoConfig.underground_depth
    local finalPos = Vector3.new(targetPosition.X, targetPosition.Y + yOffset, targetPosition.Z)

    local distance = (rootPart.Position - finalPos).Magnitude
    local duration = distance / AutoConfig.tween_speed
    if duration < 0.2 then duration = 0.2 end

    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = CFrame.new(finalPos)})
    
    tween:Play()
    while tween.PlaybackState == Enum.PlaybackState.Playing do
        if not AutoConfig.running or AutoConfig.is_hiding then
            tween:Cancel()
            return false
        end
        task.wait(0.05)
    end
    return true
end

-- Emergency Underground Safety Pause
local function hideUnderground()
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    AutoConfig.is_hiding = true
    print("[Safety] Twisted spotted nearby! Staying deep underground...")

    rootPart.CFrame = rootPart.CFrame - Vector3.new(0, AutoConfig.underground_depth, 0)
    task.wait(10)

    AutoConfig.is_hiding = false
    print("[Safety] 10 seconds elapsed. Resuming run.")
end

-- Horizontal Twisted Threat Check
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
                    local dist = (flatPlayerPos - flatEnemyPos).Magnitude

                    if dist < 40 then
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- Dandy's World Accurate Object Scanner
local function getGameObjects()
    local objects = { 
        event_items = {},
        rarities_and_capsules = {}, 
        healing_items = {}, 
        machines = {}, 
        elevator = nil 
    }

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local name = obj.Name:lower()
            local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj

            if targetPart then
                -- 1. Event / Special Spawns (Tickets, Tokens, Presents, Candies, Ornaments)
                if name:find("event") or name:find("token") or name:find("ticket") or name:find("present") or name:find("candy") or name:find("ornament") or name:find("gift") then
                    table.insert(objects.event_items, targetPart)
                -- 2. Currency, Research Capsules, Tapes, and Standard Items
                elseif name:find("ichor") or name:find("capsule") or name:find("tape") or name:find("item") then
                    table.insert(objects.rarities_and_capsules, targetPart)
                -- 3. Healing (Medkits, Bandages)
                elseif name:find("medkit") or name:find("bandage") then
                    table.insert(objects.healing_items, targetPart)
                -- 4. Machine Extractors / Generators
                elseif name:find("machine") or name:find("generator") or name:find("extractor") then
                    table.insert(objects.machines, targetPart)
                -- 5. Floor Escape Elevator
                elseif name:find("elevator") or name:find("exit") then
                    objects.elevator = targetPart
                end
            end
        end
    end
    return objects
end

-- Helper to handle underground navigation and item pickup
local function collectItem(item)
    if item and item.Parent then
        moveToPosition(item.Position, false) -- Underground travel
        moveToPosition(item.Position, true)  -- Brief surface pop-up
        local prompt = item:FindFirstChildWhichIsA("ProximityPrompt") or item.Parent:FindFirstChildWhichIsA("ProximityPrompt")
        if prompt then
            pcall(function() fireproximityprompt(prompt) end)
        end
        task.wait(0.2)
        moveToPosition(item.Position, false) -- Dive back underground
    end
end

-- Main Gameplay Loop
local function startLoop()
    task.spawn(function()
        while true do
            while not AutoConfig.running do task.wait(0.5) end
            
            if checkThreats() then
                hideUnderground()
            end

            print("[syle dex gui] Entering Floor " .. AutoConfig.current_floor)
            local objects = getGameObjects()

            -- Step 1: Priority Event Items (Candy, Tokens, Tickets, Presents)
            for _, item in ipairs(objects.event_items) do
                if not AutoConfig.running then break end
                while checkThreats() do hideUnderground() end
                collectItem(item)
            end

            -- Step 2: Research Capsules, Tapes, and Ichor/Items
            for _, item in ipairs(objects.rarities_and_capsules) do
                if not AutoConfig.running then break end
                while checkThreats() do hideUnderground() end
                collectItem(item)
            end

            -- Step 3: Healing Items (Medkits & Bandages)
            for _, item in ipairs(objects.healing_items) do
                if not AutoConfig.running then break end
                while checkThreats() do hideUnderground() end
                collectItem(item)
            end

            -- Step 4: Machine Extractors (Pop up to surface to complete)
            for _, mach in ipairs(objects.machines) do
                if not AutoConfig.running then break end
                while checkThreats() do hideUnderground() end

                if mach and mach.Parent then
                    moveToPosition(mach.Position, false)
                    moveToPosition(mach.Position, true) -- Pop up to surface at machine
                    local prompt = mach:FindFirstChildWhichIsA("ProximityPrompt") or mach.Parent:FindFirstChildWhichIsA("ProximityPrompt")
                    if prompt then
                        pcall(function() fireproximityprompt(prompt) end)
                    end
                    task.wait(1.5)
                    moveToPosition(mach.Position, false) -- Submerge back underground
                end
            end

            -- Step 5: Escape via Floor Elevator
            if objects.elevator and AutoConfig.running then
                while checkThreats() do hideUnderground() end
                
                moveToPosition(objects.elevator.Position, false)
                moveToPosition(objects.elevator.Position, true)
                
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