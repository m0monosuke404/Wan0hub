--[[
    ============================================================================
    ██╗    ██╗ █████╗ ███╗   ██╗ ██████╗ ██╗  ██╗██╗   ██╗██████╗ 
    ██║    ██║██╔══██╗████╗  ██║██╔═══██╗██║  ██║██║   ██║██╔══██╗
    ██║ █╗ ██║███████║██╔██╗ ██║██║   ██║███████║██║   ██║██████╔╝
    ██║███╗██║██╔══██║██║╚██╗██║██║   ██║██╔══██║██║   ██║██╔══██╗
    ╚███╔███╔╝██║  ██║██║ ╚████║╚██████╔╝██║  ██║╚██████╔╝██████╔╝
     ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ 
    ============================================================================
    Wan0Hub v1 (Beta) | Ultimate Blox Fruits Script
    Creator: M0nonosuke404
    FIXES: Movement conflict | Improved Invisibility | Better Auto Farm
    ============================================================================
--]]

repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer
repeat task.wait() until game.Players.LocalPlayer.Character

-- ============================================================================
-- SERVICES
-- ============================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInput = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character
local Humanoid = Character:FindFirstChild("Humanoid")
local Root = Character:FindFirstChild("HumanoidRootPart")

local CommF = nil
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
if Remotes then CommF = Remotes:FindFirstChild("CommF_") end
if not CommF then CommF = ReplicatedStorage:FindFirstChild("CommF_") end

-- World detection
local World1 = game.PlaceId == 2753915549
local World2 = game.PlaceId == 4442272183
local World3 = game.PlaceId == 7449423635

-- ============================================================================
-- ANTI-BAN
-- ============================================================================

local function AntiBan()
    pcall(function()
        local char = game.Players.LocalPlayer.Character
        if char then
            for i, v in pairs(char:GetDescendants()) do
                if v:IsA("LocalScript") then
                    if v.Name == "General" or v.Name == "Shiftlock" or v.Name == "FallDamage" or 
                       v.Name == "4444" or v.Name == "CamBob" or v.Name == "JumpCD" or 
                       v.Name == "Looking" or v.Name == "Run" then
                        v:Destroy()
                    end
                end
            end
        end
        local vu = game:GetService("VirtualUser")
        game.Players.LocalPlayer.Idled:connect(function()
            vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)
    end)
end
AntiBan()

-- ============================================================================
-- FIX: MOVEMENT KEYS STAY ACTIVE (Prevents menu from blocking movement)
-- ============================================================================

local movementKeys = {Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.LeftShift, Enum.KeyCode.Space}

for _, key in pairs(movementKeys) do
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == key then
            VirtualInput:SendKeyEvent(true, key.Name, false, game)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if input.KeyCode == key then
            VirtualInput:SendKeyEvent(false, key.Name, false, game)
        end
    end)
end

-- Fix UI focus capture
task.wait(0.5)
for _, v in pairs(CoreGui:GetDescendants()) do
    if v:IsA("TextBox") or v:IsA("TextButton") then
        pcall(function() v.ClearTextOnFocus = false end)
    end
end

-- ============================================================================
-- CREATE MAIN GUI
-- ============================================================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Wan0Hub"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

-- Main Window Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 550, 0, 580)
mainFrame.Position = UDim2.new(0.5, -275, 0.5, -290)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255, 70, 85)
mainFrame.ClipsDescendants = true
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(255, 70, 85)
titleBar.BackgroundTransparency = 0.15
titleBar.Parent = mainFrame

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -50, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "Wan0Hub v1 (Beta) | M0nonosuke404"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 14
titleText.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 1, 0)
closeBtn.Position = UDim2.new(1, -35, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Parent = titleBar
closeBtn.MouseButton1Click:Connect(function()
    screenGui.Enabled = not screenGui.Enabled
end)

-- Right Shift Hotkey
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        screenGui.Enabled = not screenGui.Enabled
    end
end)

-- Right Control to toggle UI (alternative)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then
        screenGui.Enabled = not screenGui.Enabled
    end
end)

-- Dragging
local dragging = false
local dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- ============================================================================
-- HORIZONTAL SCROLLING TAB BAR
-- ============================================================================

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -10, 0, 45)
tabBar.Position = UDim2.new(0, 5, 0, 40)
tabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
tabBar.BackgroundTransparency = 0.2
tabBar.BorderSizePixel = 1
tabBar.BorderColor3 = Color3.fromRGB(255, 70, 85)
tabBar.ClipsDescendants = true
tabBar.Parent = mainFrame

local tabScroll = Instance.new("ScrollingFrame")
tabScroll.Size = UDim2.new(1, -5, 1, -5)
tabScroll.Position = UDim2.new(0, 2, 0, 2)
tabScroll.BackgroundTransparency = 1
tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
tabScroll.ScrollBarThickness = 4
tabScroll.HorizontalScrollBarInset = Enum.ScrollBarInset.None
tabScroll.Parent = tabBar

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 5)
tabLayout.Parent = tabScroll

local function UpdateTabCanvas()
    tabScroll.CanvasSize = UDim2.new(0, tabLayout.AbsoluteContentSize.X + 10, 0, 0)
end
tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateTabCanvas)

-- ============================================================================
-- CONTENT AREA
-- ============================================================================

local contentArea = Instance.new("ScrollingFrame")
contentArea.Size = UDim2.new(1, -10, 1, -95)
contentArea.Position = UDim2.new(0, 5, 0, 90)
contentArea.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
contentArea.BackgroundTransparency = 0.1
contentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
contentArea.ScrollBarThickness = 6
contentArea.Parent = mainFrame

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 8)
contentLayout.Parent = contentArea

local function UpdateContentCanvas()
    contentArea.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
end
contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateContentCanvas)

-- ============================================================================
-- UI HELPER FUNCTIONS
-- ============================================================================

local tabs = {}

local function CreateSection(parent, text)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 35)
    frame.BackgroundColor3 = Color3.fromRGB(255, 70, 85)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Parent = frame
    return frame
end

local function CreateToggle(parent, text, callback, defaultState)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 45)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 70, 0, 30)
    btn.Position = UDim2.new(1, -80, 0, 7)
    btn.BackgroundColor3 = defaultState and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(255, 70, 85)
    btn.Text = defaultState and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = frame

    local state = defaultState or false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "ON" or "OFF"
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(255, 70, 85)
        callback(state)
    end)
    return frame
end

local function CreateButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(255, 70, 85)
    btn.BackgroundTransparency = 0.2
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = parent
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function CreateSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 70)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 25)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. default
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = frame

    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(0.7, 0, 0, 6)
    sliderFrame.Position = UDim2.new(0.15, 0, 0, 45)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 70, 85)
    fill.BorderSizePixel = 0
    fill.Parent = sliderFrame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.15, 0, 0, 25)
    valueLabel.Position = UDim2.new(0.85, 0, 0, 40)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = default
    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextSize = 12
    valueLabel.Parent = frame

    local draggingSlider = false
    local function update(value)
        value = math.clamp(value, min, max)
        fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        label.Text = text .. ": " .. math.floor(value)
        valueLabel.Text = math.floor(value)
        callback(math.floor(value))
    end

    sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = true
            local mousePos = UserInputService:GetMouseLocation().X
            local sliderPos = sliderFrame.AbsolutePosition.X
            local width = sliderFrame.AbsoluteSize.X
            local percent = (mousePos - sliderPos) / width
            update(min + (max - min) * percent)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = input.Position.X
            local sliderPos = sliderFrame.AbsolutePosition.X
            local width = sliderFrame.AbsoluteSize.X
            local percent = (mousePos - sliderPos) / width
            update(min + (max - min) * percent)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = false
        end
    end)
    return frame
end

local function CreateLabel(parent, text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 25)
    label.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    label.BackgroundTransparency = 0.2
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.Parent = parent
    return label
end

-- ============================================================================
-- CREATE TAB FUNCTION
-- ============================================================================

local function CreateTab(name, icon)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0, 110, 1, -5)
    tabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    tabBtn.BackgroundTransparency = 0.2
    tabBtn.Text = icon .. " " .. name
    tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 12
    tabBtn.Parent = tabScroll
    
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.Parent = contentArea
    
    local contentInnerLayout = Instance.new("UIListLayout")
    contentInnerLayout.Padding = UDim.new(0, 8)
    contentInnerLayout.Parent = content
    
    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.content.Visible = false
            t.button.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        end
        content.Visible = true
        tabBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 85)
        UpdateContentCanvas()
    end)
    
    tabs[name] = {content = content, button = tabBtn}
    UpdateTabCanvas()
    return content
end

-- ============================================================================
-- CREATE ALL TABS
-- ============================================================================

local farmTab = CreateTab("Auto Farm", "🤖")
local espTab = CreateTab("ESP", "👁️")
local teleportTab = CreateTab("Teleports", "🌀")
local seaTab = CreateTab("Sea Events", "🌊")
local raidTab = CreateTab("Raids", "🏛️")
local miscTab = CreateTab("Misc", "🎮")
local adminTab = CreateTab("Admin", "👑")
local creditsTab = CreateTab("Credits", "📜")

-- Select first tab
if tabs["Auto Farm"] then
    tabs["Auto Farm"].content.Visible = true
    tabs["Auto Farm"].button.BackgroundColor3 = Color3.fromRGB(255, 70, 85)
end
UpdateTabCanvas()
UpdateContentCanvas()

-- ============================================================================
-- COMPLETE LEVEL-BASED QUEST DATABASE
-- ============================================================================

local QuestDatabase = {}

if World1 then
    QuestDatabase = {
        {Level = 1, LevelEnd = 9, Enemy = "Bandit", Quest = "BanditQuest1", Count = 1, NPC = CFrame.new(1059.37, 15.45, 1550.42)},
        {Level = 10, LevelEnd = 14, Enemy = "Monkey", Quest = "JungleQuest", Count = 1, NPC = CFrame.new(-1598.09, 35.55, 153.38)},
        {Level = 15, LevelEnd = 29, Enemy = "Gorilla", Quest = "JungleQuest", Count = 2, NPC = CFrame.new(-1598.09, 35.55, 153.38)},
        {Level = 30, LevelEnd = 39, Enemy = "Pirate", Quest = "BuggyQuest1", Count = 1, NPC = CFrame.new(-1141.07, 4.10, 3831.55)},
        {Level = 40, LevelEnd = 59, Enemy = "Brute", Quest = "BuggyQuest1", Count = 2, NPC = CFrame.new(-1141.07, 4.10, 3831.55)},
        {Level = 60, LevelEnd = 74, Enemy = "Desert Bandit", Quest = "DesertQuest", Count = 1, NPC = CFrame.new(894.49, 5.14, 4392.43)},
        {Level = 75, LevelEnd = 89, Enemy = "Desert Officer", Quest = "DesertQuest", Count = 2, NPC = CFrame.new(894.49, 5.14, 4392.43)},
        {Level = 90, LevelEnd = 99, Enemy = "Snow Bandit", Quest = "SnowQuest", Count = 1, NPC = CFrame.new(1389.74, 88.15, -1298.91)},
        {Level = 100, LevelEnd = 119, Enemy = "Snowman", Quest = "SnowQuest", Count = 2, NPC = CFrame.new(1389.74, 88.15, -1298.91)},
        {Level = 120, LevelEnd = 149, Enemy = "Chief Petty Officer", Quest = "MarineQuest2", Count = 1, NPC = CFrame.new(-5039.59, 27.35, 4324.68)},
        {Level = 150, LevelEnd = 174, Enemy = "Sky Bandit", Quest = "SkyQuest", Count = 1, NPC = CFrame.new(-4839.53, 716.37, -2619.44)},
        {Level = 175, LevelEnd = 189, Enemy = "Dark Master", Quest = "SkyQuest", Count = 2, NPC = CFrame.new(-4839.53, 716.37, -2619.44)},
        {Level = 190, LevelEnd = 209, Enemy = "Prisoner", Quest = "PrisonerQuest", Count = 1, NPC = CFrame.new(5308.93, 1.66, 475.12)},
        {Level = 210, LevelEnd = 249, Enemy = "Dangerous Prisoner", Quest = "PrisonerQuest", Count = 2, NPC = CFrame.new(5308.93, 1.66, 475.12)},
        {Level = 250, LevelEnd = 274, Enemy = "Toga Warrior", Quest = "ColosseumQuest", Count = 1, NPC = CFrame.new(-1580.05, 6.35, -2986.48)},
        {Level = 275, LevelEnd = 299, Enemy = "Gladiator", Quest = "ColosseumQuest", Count = 2, NPC = CFrame.new(-1580.05, 6.35, -2986.48)},
        {Level = 300, LevelEnd = 324, Enemy = "Military Soldier", Quest = "MagmaQuest", Count = 1, NPC = CFrame.new(-5313.37, 10.95, 8515.29)},
        {Level = 325, LevelEnd = 374, Enemy = "Military Spy", Quest = "MagmaQuest", Count = 2, NPC = CFrame.new(-5313.37, 10.95, 8515.29)},
        {Level = 375, LevelEnd = 399, Enemy = "Fishman Warrior", Quest = "FishmanQuest", Count = 1, NPC = CFrame.new(61122.65, 18.50, 1569.40)},
        {Level = 400, LevelEnd = 449, Enemy = "Fishman Commando", Quest = "FishmanQuest", Count = 2, NPC = CFrame.new(61122.65, 18.50, 1569.40)},
        {Level = 450, LevelEnd = 474, Enemy = "God's Guard", Quest = "SkyExp1Quest", Count = 1, NPC = CFrame.new(-4721.86, 845.30, -1953.85)},
        {Level = 475, LevelEnd = 524, Enemy = "Shanda", Quest = "SkyExp1Quest", Count = 2, NPC = CFrame.new(-7863.16, 5545.52, -378.42)},
        {Level = 525, LevelEnd = 549, Enemy = "Royal Squad", Quest = "SkyExp2Quest", Count = 1, NPC = CFrame.new(-7903.38, 5635.99, -1410.92)},
        {Level = 550, LevelEnd = 624, Enemy = "Royal Soldier", Quest = "SkyExp2Quest", Count = 2, NPC = CFrame.new(-7903.38, 5635.99, -1410.92)},
        {Level = 625, LevelEnd = 649, Enemy = "Galley Pirate", Quest = "FountainQuest", Count = 1, NPC = CFrame.new(5258.28, 38.53, 4050.04)},
        {Level = 650, LevelEnd = 700, Enemy = "Galley Captain", Quest = "FountainQuest", Count = 2, NPC = CFrame.new(5258.28, 38.53, 4050.04)},
    }
elseif World2 then
    QuestDatabase = {
        {Level = 700, LevelEnd = 724, Enemy = "Raider", Quest = "Area1Quest", Count = 1, NPC = CFrame.new(-427.73, 73.00, 1835.94)},
        {Level = 725, LevelEnd = 774, Enemy = "Mercenary", Quest = "Area1Quest", Count = 2, NPC = CFrame.new(-427.73, 73.00, 1835.94)},
        {Level = 775, LevelEnd = 799, Enemy = "Swan Pirate", Quest = "Area2Quest", Count = 1, NPC = CFrame.new(635.61, 73.10, 917.81)},
        {Level = 800, LevelEnd = 874, Enemy = "Factory Staff", Quest = "Area2Quest", Count = 2, NPC = CFrame.new(635.61, 73.10, 917.81)},
        {Level = 875, LevelEnd = 899, Enemy = "Marine Lieutenant", Quest = "MarineQuest3", Count = 1, NPC = CFrame.new(-2440.99, 73.04, -3217.71)},
        {Level = 900, LevelEnd = 949, Enemy = "Marine Captain", Quest = "MarineQuest3", Count = 2, NPC = CFrame.new(-2440.99, 73.04, -3217.71)},
        {Level = 950, LevelEnd = 974, Enemy = "Zombie", Quest = "ZombieQuest", Count = 1, NPC = CFrame.new(-5494.34, 48.51, -794.59)},
        {Level = 975, LevelEnd = 999, Enemy = "Vampire", Quest = "ZombieQuest", Count = 2, NPC = CFrame.new(-5494.34, 48.51, -794.59)},
        {Level = 1000, LevelEnd = 1049, Enemy = "Snow Trooper", Quest = "SnowMountainQuest", Count = 1, NPC = CFrame.new(607.06, 401.45, -5370.55)},
        {Level = 1050, LevelEnd = 1099, Enemy = "Winter Warrior", Quest = "SnowMountainQuest", Count = 2, NPC = CFrame.new(607.06, 401.45, -5370.55)},
        {Level = 1100, LevelEnd = 1124, Enemy = "Lab Subordinate", Quest = "IceSideQuest", Count = 1, NPC = CFrame.new(-6061.84, 15.93, -4902.04)},
        {Level = 1125, LevelEnd = 1174, Enemy = "Horned Warrior", Quest = "IceSideQuest", Count = 2, NPC = CFrame.new(-6061.84, 15.93, -4902.04)},
        {Level = 1175, LevelEnd = 1199, Enemy = "Magma Ninja", Quest = "FireSideQuest", Count = 1, NPC = CFrame.new(-5429.05, 15.98, -5297.96)},
        {Level = 1200, LevelEnd = 1249, Enemy = "Lava Pirate", Quest = "FireSideQuest", Count = 2, NPC = CFrame.new(-5429.05, 15.98, -5297.96)},
        {Level = 1250, LevelEnd = 1274, Enemy = "Ship Deckhand", Quest = "ShipQuest1", Count = 1, NPC = CFrame.new(1040.29, 125.08, 32911.04)},
        {Level = 1275, LevelEnd = 1299, Enemy = "Ship Engineer", Quest = "ShipQuest1", Count = 2, NPC = CFrame.new(1040.29, 125.08, 32911.04)},
        {Level = 1300, LevelEnd = 1324, Enemy = "Ship Steward", Quest = "ShipQuest2", Count = 1, NPC = CFrame.new(971.42, 125.08, 33245.54)},
        {Level = 1325, LevelEnd = 1349, Enemy = "Ship Officer", Quest = "ShipQuest2", Count = 2, NPC = CFrame.new(971.42, 125.08, 33245.54)},
        {Level = 1350, LevelEnd = 1374, Enemy = "Arctic Warrior", Quest = "FrostQuest", Count = 1, NPC = CFrame.new(5668.14, 28.20, -6484.60)},
        {Level = 1375, LevelEnd = 1424, Enemy = "Snow Lurker", Quest = "FrostQuest", Count = 2, NPC = CFrame.new(5668.14, 28.20, -6484.60)},
        {Level = 1425, LevelEnd = 1449, Enemy = "Sea Soldier", Quest = "ForgottenQuest", Count = 1, NPC = CFrame.new(-3054.58, 236.87, -10147.79)},
        {Level = 1450, LevelEnd = 1500, Enemy = "Water Fighter", Quest = "ForgottenQuest", Count = 2, NPC = CFrame.new(-3054.58, 236.87, -10147.79)},
    }
elseif World3 then
    QuestDatabase = {
        {Level = 1500, LevelEnd = 1524, Enemy = "Pirate Millionaire", Quest = "PiratePortQuest", Count = 1, NPC = CFrame.new(-289.62, 43.82, 5580.09)},
        {Level = 1525, LevelEnd = 1574, Enemy = "Pistol Billionaire", Quest = "PiratePortQuest", Count = 2, NPC = CFrame.new(-289.62, 43.82, 5580.09)},
        {Level = 1575, LevelEnd = 1599, Enemy = "Dragon Crew Warrior", Quest = "AmazonQuest", Count = 1, NPC = CFrame.new(5833.11, 51.60, -1103.07)},
        {Level = 1600, LevelEnd = 1624, Enemy = "Dragon Crew Archer", Quest = "AmazonQuest", Count = 2, NPC = CFrame.new(5833.11, 51.60, -1103.07)},
        {Level = 1625, LevelEnd = 1649, Enemy = "Female Islander", Quest = "AmazonQuest2", Count = 1, NPC = CFrame.new(5446.88, 601.63, 749.46)},
        {Level = 1650, LevelEnd = 1699, Enemy = "Giant Islander", Quest = "AmazonQuest2", Count = 2, NPC = CFrame.new(5446.88, 601.63, 749.46)},
        {Level = 1700, LevelEnd = 1724, Enemy = "Marine Commodore", Quest = "MarineTreeIsland", Count = 1, NPC = CFrame.new(2179.99, 28.73, -6740.06)},
        {Level = 1725, LevelEnd = 1774, Enemy = "Marine Rear Admiral", Quest = "MarineTreeIsland", Count = 2, NPC = CFrame.new(2179.99, 28.73, -6740.06)},
        {Level = 1775, LevelEnd = 1799, Enemy = "Fishman Raider", Quest = "DeepForestIsland3", Count = 1, NPC = CFrame.new(-10582.76, 331.79, -8757.67)},
        {Level = 1800, LevelEnd = 1824, Enemy = "Fishman Captain", Quest = "DeepForestIsland3", Count = 2, NPC = CFrame.new(-10582.76, 331.79, -8757.67)},
        {Level = 1825, LevelEnd = 1849, Enemy = "Forest Pirate", Quest = "DeepForestIsland", Count = 1, NPC = CFrame.new(-13232.66, 332.40, -7626.48)},
        {Level = 1850, LevelEnd = 1899, Enemy = "Mythological Pirate", Quest = "DeepForestIsland", Count = 2, NPC = CFrame.new(-13232.66, 332.40, -7626.48)},
        {Level = 1900, LevelEnd = 1924, Enemy = "Jungle Pirate", Quest = "DeepForestIsland2", Count = 1, NPC = CFrame.new(-12682.10, 390.89, -9902.12)},
        {Level = 1925, LevelEnd = 1974, Enemy = "Musketeer Pirate", Quest = "DeepForestIsland2", Count = 2, NPC = CFrame.new(-12682.10, 390.89, -9902.12)},
        {Level = 1975, LevelEnd = 1999, Enemy = "Reborn Skeleton", Quest = "HauntedQuest1", Count = 1, NPC = CFrame.new(-9480.81, 142.13, 5566.37)},
        {Level = 2000, LevelEnd = 2024, Enemy = "Living Zombie", Quest = "HauntedQuest1", Count = 2, NPC = CFrame.new(-9480.81, 142.13, 5566.37)},
        {Level = 2025, LevelEnd = 2049, Enemy = "Demonic Soul", Quest = "HauntedQuest2", Count = 1, NPC = CFrame.new(-9516.99, 178.01, 6078.47)},
        {Level = 2050, LevelEnd = 2074, Enemy = "Posessed Mummy", Quest = "HauntedQuest2", Count = 2, NPC = CFrame.new(-9516.99, 178.01, 6078.47)},
        {Level = 2075, LevelEnd = 2099, Enemy = "Peanut Scout", Quest = "NutsIslandQuest", Count = 1, NPC = CFrame.new(-2105.53, 37.25, -10195.51)},
        {Level = 2100, LevelEnd = 2124, Enemy = "Peanut President", Quest = "NutsIslandQuest", Count = 2, NPC = CFrame.new(-2105.53, 37.25, -10195.51)},
        {Level = 2125, LevelEnd = 2149, Enemy = "Ice Cream Chef", Quest = "IceCreamIslandQuest", Count = 1, NPC = CFrame.new(-819.38, 64.93, -10967.28)},
        {Level = 2150, LevelEnd = 2199, Enemy = "Ice Cream Commander", Quest = "IceCreamIslandQuest", Count = 2, NPC = CFrame.new(-819.38, 64.93, -10967.28)},
        {Level = 2200, LevelEnd = 2224, Enemy = "Cookie Crafter", Quest = "CakeQuest1", Count = 1, NPC = CFrame.new(-2022.30, 36.93, -12030.98)},
        {Level = 2225, LevelEnd = 2249, Enemy = "Cake Guard", Quest = "CakeQuest1", Count = 2, NPC = CFrame.new(-2022.30, 36.93, -12030.98)},
        {Level = 2250, LevelEnd = 2274, Enemy = "Baking Staff", Quest = "CakeQuest2", Count = 1, NPC = CFrame.new(-1928.32, 37.73, -12840.63)},
        {Level = 2275, LevelEnd = 2299, Enemy = "Head Baker", Quest = "CakeQuest2", Count = 2, NPC = CFrame.new(-1928.32, 37.73, -12840.63)},
        {Level = 2300, LevelEnd = 2324, Enemy = "Cocoa Warrior", Quest = "ChocQuest1", Count = 1, NPC = CFrame.new(231.75, 23.90, -12200.29)},
        {Level = 2325, LevelEnd = 2349, Enemy = "Chocolate Bar Battler", Quest = "ChocQuest1", Count = 2, NPC = CFrame.new(231.75, 23.90, -12200.29)},
        {Level = 2350, LevelEnd = 2374, Enemy = "Sweet Thief", Quest = "ChocQuest2", Count = 1, NPC = CFrame.new(151.20, 23.89, -12774.62)},
        {Level = 2375, LevelEnd = 2400, Enemy = "Candy Rebel", Quest = "ChocQuest2", Count = 2, NPC = CFrame.new(151.20, 23.89, -12774.62)},
        {Level = 2400, LevelEnd = 2424, Enemy = "Candy Pirate", Quest = "CandyQuest1", Count = 1, NPC = CFrame.new(-1149.33, 13.58, -14445.61)},
        {Level = 2425, LevelEnd = 2449, Enemy = "Snow Demon", Quest = "CandyQuest1", Count = 2, NPC = CFrame.new(-1149.33, 13.58, -14445.61)},
        {Level = 2450, LevelEnd = 2474, Enemy = "Isle Outlaw", Quest = "TikiQuest1", Count = 1, NPC = CFrame.new(-16549.89, 55.69, -179.91)},
        {Level = 2475, LevelEnd = 2524, Enemy = "Island Boy", Quest = "TikiQuest1", Count = 2, NPC = CFrame.new(-16549.89, 55.69, -179.91)},
        {Level = 2525, LevelEnd = 2550, Enemy = "Isle Champion", Quest = "TikiQuest2", Count = 2, NPC = CFrame.new(-16542.45, 55.69, 1044.42)},
    }
end

local function GetCurrentQuestData()
    local level = LocalPlayer.Data.Level.Value
    for _, quest in pairs(QuestDatabase) do
        if level >= quest.Level and level <= quest.LevelEnd then
            return quest
        end
    end
    return QuestDatabase[1]
end

-- ============================================================================
-- AUTO FARM (IMPROVED)
-- ============================================================================

local autoFarmEnabled = false
local autoFarmTask = nil
local fastAttackEnabled = true
local AttackDelay = 0.15
local LastAttackTime = 0
local autoHakiEnabled = true

local function FastAttack()
    if not fastAttackEnabled then 
        VirtualInput:SendKeyEvent(true, "E", false, game)
        task.wait(0.05)
        VirtualInput:SendKeyEvent(false, "E", false, game)
        return 
    end
    
    -- Fast attack with no cooldown
    local currentTime = tick()
    if currentTime - LastAttackTime >= AttackDelay then
        LastAttackTime = currentTime
        VirtualInput:SendKeyEvent(true, "E", false, game)
        task.wait(0.05)
        VirtualInput:SendKeyEvent(false, "E", false, game)
    end
end

local function AutoHaki()
    if not autoHakiEnabled then return end
    pcall(function()
        local char = LocalPlayer.Character
        if char and not char:FindFirstChild("HasBuso") and CommF then
            CommF:InvokeServer("Buso")
        end
    end)
end

local function TeleportToEnemy(cframe)
    pcall(function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        char.HumanoidRootPart.CFrame = cframe
    end)
end

local function GetTargetEnemy()
    local questData = GetCurrentQuestData()
    local targetName = questData.Enemy
    
    -- First try to find the specific enemy
    for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
        if enemy.Name == targetName and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
            return enemy
        end
    end
    
    -- Fallback: find any enemy (for testing)
    for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
        if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 and enemy:FindFirstChild("HumanoidRootPart") then
            return enemy
        end
    end
    return nil
end

local function CheckQuest()
    local questData = GetCurrentQuestData()
    local hasQuest = false
    
    pcall(function()
        local main = LocalPlayer.PlayerGui:FindFirstChild("Main")
        if main and main.Quest then
            hasQuest = main.Quest.Visible
        end
    end)
    
    if not hasQuest and CommF then
        TeleportToEnemy(questData.NPC)
        task.wait(0.5)
        CommF:InvokeServer("StartQuest", questData.Quest, questData.Count)
        task.wait(0.5)
    end
end

local function StartAutoFarm()
    if autoFarmTask then task.cancel(autoFarmTask) end
    autoFarmTask = task.spawn(function()
        while autoFarmEnabled and Character and Root do
            pcall(function()
                AutoHaki()
                CheckQuest()
                
                local enemy = GetTargetEnemy()
                if enemy and enemy.HumanoidRootPart then
                    TeleportToEnemy(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 5, 3))
                    FastAttack()
                end
            end)
            task.wait(0.3)
        end
    end)
end

-- ============================================================================
-- ESP SYSTEM
-- ============================================================================

local playerEspEnabled = false
local fruitEspEnabled = false
local islandEspEnabled = false
local playerEspObjects = {}
local fruitEspObjects = {}
local islandEspObjects = {}

local AdminNames = {
    "rip_indra", "Uzoth", "JayGamesRBX", "Haz3rn", "ImCrispy",
    "OfficerGreg", "Zioles", "Axii", "MonkeyBoy", "Skipper"
}

local IslandData = {
    {Name = "Jungle", Level = "10-30", CFrame = CFrame.new(-1250, 80, 380)},
    {Name = "Prison", Level = "190-250", CFrame = CFrame.new(900, 150, -1200)},
    {Name = "Sky Islands", Level = "150-190", CFrame = CFrame.new(-4900, 800, 6200)},
    {Name = "Magma Village", Level = "300-375", CFrame = CFrame.new(-2800, 50, 1600)},
    {Name = "Kingdom of Rose", Level = "700-875", CFrame = CFrame.new(-850, 80, 14500)},
    {Name = "Green Zone", Level = "875-950", CFrame = CFrame.new(-1500, 50, 13500)},
    {Name = "Castle on Sea", Level = "1725-1800", CFrame = CFrame.new(5500, 200, 2100)},
    {Name = "Hydra Island", Level = "1575-1650", CFrame = CFrame.new(6500, 150, 2500)},
    {Name = "Port Town", Level = "1500-1575", CFrame = CFrame.new(4800, 80, 1800)},
}

local LegendaryMythicalFruits = {
    "Leopard", "Dragon", "Dough", "Spirit", "Venom", "Shadow", 
    "Control", "Gravity", "Rumble", "Buddha", "Phoenix", "Portal",
    "Blizzard", "Sound", "Mammoth", "T-Rex", "Kitsune", "Yeti", "Gas"
}

local function GetPlayerColor(plr)
    for _, admin in pairs(AdminNames) do
        if string.lower(plr.Name) == string.lower(admin) then
            return Color3.fromRGB(255, 215, 0)
        end
    end
    if plr.Team then
        if plr.Team.Name == "Pirates" then 
            return Color3.fromRGB(255, 50, 50)
        elseif plr.Team.Name == "Marines" then 
            return Color3.fromRGB(100, 200, 255)
        end
    end
    return Color3.fromRGB(200, 200, 200)
end

local function IsLegendaryOrMythical(fruitName)
    for _, fruit in pairs(LegendaryMythicalFruits) do
        if string.find(fruitName, fruit) then return true end
    end
    return false
end

local function ClearPlayerESP()
    for _, obj in pairs(playerEspObjects) do
        pcall(function() if obj then obj:Destroy() end end)
    end
    playerEspObjects = {}
end

local function UpdatePlayerESP()
    if not playerEspEnabled then ClearPlayerESP(); return end
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if not playerEspObjects[plr] then
                local bill = Instance.new("BillboardGui")
                bill.Size = UDim2.new(0, 180, 0, 50)
                bill.StudsOffset = Vector3.new(0, 2.5, 0)
                bill.AlwaysOnTop = true
                bill.Parent = plr.Character.HumanoidRootPart
                
                local text = Instance.new("TextLabel")
                text.Size = UDim2.new(1, 0, 1, 0)
                text.BackgroundTransparency = 1
                text.Text = plr.Name .. "\n❤️ ?"
                text.TextColor3 = GetPlayerColor(plr)
                text.Font = Enum.Font.GothamBold
                text.TextSize = 12
                text.Parent = bill
                
                playerEspObjects[plr] = bill
                
                task.spawn(function()
                    while playerEspEnabled and plr.Character and plr.Character:FindFirstChild("Humanoid") do
                        local hum = plr.Character.Humanoid
                        local health = math.floor(hum.Health)
                        text.Text = plr.Name .. "\n❤️ " .. health
                        if health < 30 then
                            text.TextColor3 = Color3.fromRGB(255, 0, 0)
                        elseif health < 70 then
                            text.TextColor3 = Color3.fromRGB(255, 255, 0)
                        else
                            text.TextColor3 = GetPlayerColor(plr)
                        end
                        task.wait(0.5)
                    end
                end)
            end
        elseif playerEspObjects[plr] then
            pcall(function() playerEspObjects[plr]:Destroy() end)
            playerEspObjects[plr] = nil
        end
    end
end

local function ClearFruitESP()
    for _, obj in pairs(fruitEspObjects) do
        pcall(function() if obj then obj:Destroy() end end)
    end
    fruitEspObjects = {}
end

local function UpdateFruitESP()
    if not fruitEspEnabled then ClearFruitESP(); return end
    
    for _, fruit in pairs(Workspace:GetDescendants()) do
        if fruit.Name == "Fruit" and fruit:IsA("Model") and fruit:FindFirstChild("HumanoidRootPart") then
            local fruitName = fruit:FindFirstChild("Item") and fruit.Item.Value or fruit.Name
            
            if IsLegendaryOrMythical(fruitName) and not fruitEspObjects[fruit] then
                local bill = Instance.new("BillboardGui")
                bill.Size = UDim2.new(0, 200, 0, 55)
                bill.StudsOffset = Vector3.new(0, 2, 0)
                bill.AlwaysOnTop = true
                bill.Parent = fruit.HumanoidRootPart
                
                local text = Instance.new("TextLabel")
                text.Size = UDim2.new(1, 0, 1, 0)
                text.BackgroundTransparency = 1
                text.Text = "🌟 " .. fruitName .. " 🌟\n💎 LEGENDARY/MYTHICAL 💎"
                text.TextColor3 = Color3.fromRGB(155, 48, 255)
                text.Font = Enum.Font.GothamBold
                text.TextSize = 11
                text.Parent = bill
                
                fruitEspObjects[fruit] = bill
            end
        elseif fruitEspObjects[fruit] then
            pcall(function() fruitEspObjects[fruit]:Destroy() end)
            fruitEspObjects[fruit] = nil
        end
    end
end

local function ClearIslandESP()
    for _, obj in pairs(islandEspObjects) do
        pcall(function() if obj then obj:Destroy() end end)
    end
    islandEspObjects = {}
end

local function UpdateIslandESP()
    if not islandEspEnabled then ClearIslandESP(); return end
    
    for _, island in pairs(IslandData) do
        local key = island.Name
        if not islandEspObjects[key] then
            local part = Instance.new("Part")
            part.Size = Vector3.new(50, 10, 50)
            part.CFrame = island.CFrame
            part.Anchored = true
            part.CanCollide = false
            part.Transparency = 0.8
            part.BrickColor = BrickColor.new("Bright red")
            part.Parent = Workspace
            
            local bill = Instance.new("BillboardGui")
            bill.Size = UDim2.new(0, 250, 0, 70)
            bill.StudsOffset = Vector3.new(0, 15, 0)
            bill.AlwaysOnTop = true
            bill.Parent = part
            
            local text = Instance.new("TextLabel")
            text.Size = UDim2.new(1, 0, 1, 0)
            text.BackgroundTransparency = 1
            text.Text = "🏝️ " .. island.Name .. "\n📊 Recommended Level: " .. island.Level
            text.TextColor3 = Color3.fromRGB(255, 200, 100)
            text.Font = Enum.Font.GothamBold
            text.TextSize = 13
            text.Parent = bill
            
            islandEspObjects[key] = bill
        end
    end
end

task.spawn(function()
    while true do
        if playerEspEnabled then UpdatePlayerESP() else ClearPlayerESP() end
        if fruitEspEnabled then UpdateFruitESP() else ClearFruitESP() end
        if islandEspEnabled then UpdateIslandESP() else ClearIslandESP() end
        task.wait(0.5)
    end
end)

-- ============================================================================
-- AUTO FARM TAB CONTENT
-- ============================================================================

CreateSection(farmTab, "Farming Settings")

CreateToggle(farmTab, "Auto Farm Level", function(state)
    autoFarmEnabled = state
    if state then 
        StartAutoFarm()
    else 
        if autoFarmTask then task.cancel(autoFarmTask) end
    end
end, false)

CreateToggle(farmTab, "Fast Attack (No Cooldown)", function(state)
    fastAttackEnabled = state
    AttackDelay = state and 0.05 or 0.15
end, true)

CreateToggle(farmTab, "Auto Haki", function(state)
    autoHakiEnabled = state
end, true)

CreateSlider(farmTab, "Walk Speed", 16, 350, 16, function(value)
    if Humanoid then Humanoid.WalkSpeed = value end
end)

CreateSlider(farmTab, "Jump Power", 50, 500, 50, function(value)
    if Humanoid then Humanoid.JumpPower = value end
end)

-- ============================================================================
-- ESP TAB CONTENT
-- ============================================================================

CreateSection(espTab, "ESP Settings")

CreateToggle(espTab, "Player ESP (Red/Blue/Gold)", function(state)
    playerEspEnabled = state
end, false)

CreateToggle(espTab, "Legendary/Mythical Fruit ESP (Purple)", function(state)
    fruitEspEnabled = state
end, false)

CreateToggle(espTab, "Island ESP (With Levels)", function(state)
    islandEspEnabled = state
end, false)

CreateLabel(espTab, "• Players: Red(Pirates), Blue(Marines), Gold(Admins)")
CreateLabel(espTab, "• Fruits: ONLY Legendary/Mythical (Purple with 🌟)")
CreateLabel(espTab, "• Islands: Shows name and recommended level")

-- ============================================================================
-- TELEPORT TAB CONTENT
-- ============================================================================

CreateSection(teleportTab, "Island Teleports")

local teleFrame = Instance.new("Frame")
teleFrame.Size = UDim2.new(1, -10, 0, 45)
teleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
teleFrame.BackgroundTransparency = 0.2
teleFrame.Parent = teleportTab

local teleLabel = Instance.new("TextLabel")
teleLabel.Size = UDim2.new(0.5, -10, 1, 0)
teleLabel.Position = UDim2.new(0, 10, 0, 0)
teleLabel.BackgroundTransparency = 1
teleLabel.Text = "Select Island"
teleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
teleLabel.TextXAlignment = Enum.TextXAlignment.Left
teleLabel.Font = Enum.Font.Gotham
teleLabel.TextSize = 13
teleLabel.Parent = teleFrame

local teleBtn = Instance.new("TextButton")
teleBtn.Size = UDim2.new(0.4, -10, 0, 30)
teleBtn.Position = UDim2.new(0.55, 0, 0, 7)
teleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
teleBtn.Text = IslandData[1].Name .. " | Lvl " .. IslandData[1].Level
teleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
teleBtn.Font = Enum.Font.Gotham
teleBtn.TextSize = 11
teleBtn.Parent = teleFrame

local teleExpanded = false
local teleListFrame = nil

teleBtn.MouseButton1Click:Connect(function()
    teleExpanded = not teleExpanded
    if teleExpanded then
        teleListFrame = Instance.new("Frame")
        teleListFrame.Size = UDim2.new(0.4, -10, 0, math.min(#IslandData, 6) * 32)
        teleListFrame.Position = UDim2.new(0.55, 0, 0, 37)
        teleListFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        teleListFrame.BorderSizePixel = 1
        teleListFrame.BorderColor3 = Color3.fromRGB(255, 70, 85)
        teleListFrame.Parent = teleFrame
        
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, 0, 1, 0)
        scroll.BackgroundTransparency = 1
        scroll.CanvasSize = UDim2.new(0, 0, 0, #IslandData * 32)
        scroll.ScrollBarThickness = 4
        scroll.Parent = teleListFrame
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 1)
        layout.Parent = scroll
        
        for i, island in pairs(IslandData) do
            local opt = Instance.new("TextButton")
            opt.Size = UDim2.new(1, 0, 0, 32)
            opt.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
            opt.Text = island.Name .. " | Lvl " .. island.Level
            opt.TextColor3 = Color3.fromRGB(255, 255, 255)
            opt.Font = Enum.Font.Gotham
            opt.TextSize = 11
            opt.Parent = scroll
            opt.MouseButton1Click:Connect(function()
                teleBtn.Text = island.Name .. " | Lvl " .. island.Level
                TeleportToEnemy(island.CFrame)
                teleListFrame:Destroy()
                teleExpanded = false
            end)
        end
    else
        if teleListFrame then teleListFrame:Destroy() end
    end
end)

CreateButton(teleportTab, "Travel to First Sea", function()
    if CommF then CommF:InvokeServer("TravelMain") end
end)

CreateButton(teleportTab, "Travel to Second Sea", function()
    if CommF then CommF:InvokeServer("TravelDressrosa") end
end)

CreateButton(teleportTab, "Travel to Third Sea", function()
    if CommF then CommF:InvokeServer("TravelZou") end
end)

-- ============================================================================
-- SEA EVENTS TAB CONTENT
-- ============================================================================

CreateSection(seaTab, "Sea Events")

CreateToggle(seaTab, "Auto Sea Beast", function(state)
    if state then
        task.spawn(function()
            while state do
                local seaBeast = Workspace:FindFirstChild("SeaBeasts")
                if seaBeast then
                    for _, v in pairs(seaBeast:GetChildren()) do
                        if v:FindFirstChild("HumanoidRootPart") then
                            TeleportToEnemy(v.HumanoidRootPart.CFrame * CFrame.new(0, 10, 10))
                            for i = 1, 5 do
                                VirtualInput:SendKeyEvent(true, "E", false, game)
                                task.wait(0.2)
                                VirtualInput:SendKeyEvent(false, "E", false, game)
                            end
                        end
                    end
                end
                task.wait(3)
            end
        end)
    end
end, false)

CreateToggle(seaTab, "Auto Ship Raid", function(state)
    if state then
        task.spawn(function()
            while state do
                for _, v in pairs(Workspace.Enemies:GetChildren()) do
                    if (v.Name == "FishBoat" or v.Name == "PirateGrandBrigade") and v:FindFirstChild("Health") and v.Health.Value > 0 then
                        local engine = v:FindFirstChild("Engine")
                        if engine then
                            TeleportToEnemy(engine.CFrame * CFrame.new(0, -20, 0))
                            for i = 1, 10 do
                                VirtualInput:SendKeyEvent(true, "E", false, game)
                                task.wait(0.2)
                                VirtualInput:SendKeyEvent(false, "E", false, game)
                            end
                        end
                    end
                end
                task.wait(2)
            end
        end)
    end
end, false)

-- ============================================================================
-- RAIDS TAB CONTENT
-- ============================================================================

CreateSection(raidTab, "Raid Settings")

local raidTypes = {"Flame", "Ice", "Dark", "Light", "Magma", "Quake", "Buddha", "Dough"}
local selectedRaid = "Flame"

local raidFrame = Instance.new("Frame")
raidFrame.Size = UDim2.new(1, -10, 0, 45)
raidFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
raidFrame.BackgroundTransparency = 0.2
raidFrame.Parent = raidTab

local raidLabel = Instance.new("TextLabel")
raidLabel.Size = UDim2.new(0.5, -10, 1, 0)
raidLabel.Position = UDim2.new(0, 10, 0, 0)
raidLabel.BackgroundTransparency = 1
raidLabel.Text = "Select Raid"
raidLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
raidLabel.TextXAlignment = Enum.TextXAlignment.Left
raidLabel.Font = Enum.Font.Gotham
raidLabel.TextSize = 13
raidLabel.Parent = raidFrame

local raidBtn = Instance.new("TextButton")
raidBtn.Size = UDim2.new(0.4, -10, 0, 30)
raidBtn.Position = UDim2.new(0.55, 0, 0, 7)
raidBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
raidBtn.Text = selectedRaid
raidBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
raidBtn.Font = Enum.Font.Gotham
raidBtn.TextSize = 11
raidBtn.Parent = raidFrame

local raidExpanded = false
local raidListFrame = nil

raidBtn.MouseButton1Click:Connect(function()
    raidExpanded = not raidExpanded
    if raidExpanded then
        raidListFrame = Instance.new("Frame")
        raidListFrame.Size = UDim2.new(0.4, -10, 0, math.min(#raidTypes, 6) * 32)
        raidListFrame.Position = UDim2.new(0.55, 0, 0, 37)
        raidListFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        raidListFrame.BorderSizePixel = 1
        raidListFrame.BorderColor3 = Color3.fromRGB(255, 70, 85)
        raidListFrame.Parent = raidFrame
        
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, 0, 1, 0)
        scroll.BackgroundTransparency = 1
        scroll.CanvasSize = UDim2.new(0, 0, 0, #raidTypes * 32)
        scroll.ScrollBarThickness = 4
        scroll.Parent = raidListFrame
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 1)
        layout.Parent = scroll
        
        for i, raid in pairs(raidTypes) do
            local opt = Instance.new("TextButton")
            opt.Size = UDim2.new(1, 0, 0, 32)
            opt.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
            opt.Text = raid
            opt.TextColor3 = Color3.fromRGB(255, 255, 255)
            opt.Font = Enum.Font.Gotham
            opt.TextSize = 11
            opt.Parent = scroll
            opt.MouseButton1Click:Connect(function()
                selectedRaid = raid
                raidBtn.Text = raid
                raidListFrame:Destroy()
                raidExpanded = false
            end)
        end
    else
        if raidListFrame then raidListFrame:Destroy() end
    end
end)

CreateToggle(raidTab, "Auto Start Raid", function(state)
    if state and CommF then
        task.spawn(function()
            while state do
                pcall(function()
                    CommF:InvokeServer("StartRaid", selectedRaid)
                end)
                task.wait(10)
            end
        end)
    end
end, false)

-- ============================================================================
-- MISC TAB CONTENT (WITH FIXED INFINITE ENERGY)
-- ============================================================================

CreateSection(miscTab, "Movement & Visual")

-- Invisibility (Improved - attempts to hide name locally)
local invisibilityEnabled = false
local originalTransparencies = {}

local function SetInvisibility(enabled)
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        if enabled then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    originalTransparencies[part] = part.Transparency
                    part.Transparency = 1
                end
            end
            -- Attempt to hide name (local only)
            if char:FindFirstChild("Humanoid") then
                char.Humanoid.DisplayName = ""
            end
        else
            for part, transparency in pairs(originalTransparencies) do
                if part and part.Parent then
                    part.Transparency = transparency
                end
            end
            if char:FindFirstChild("Humanoid") then
                char.Humanoid.DisplayName = LocalPlayer.Name
            end
            originalTransparencies = {}
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Root = Character:FindFirstChild("HumanoidRootPart")
    Humanoid = Character:FindFirstChild("Humanoid")
    task.wait(0.5)
    if invisibilityEnabled then SetInvisibility(true) end
end)

CreateToggle(miscTab, "Invisibility (Visual Only - Name visible to others)", function(state)
    invisibilityEnabled = state
    SetInvisibility(state)
end, false)

-- No Clip
local noclipEnabled = false
local noclipConnection = nil

local function EnableNoClip()
    if noclipConnection then return end
    noclipConnection = RunService.Stepped:Connect(function()
        pcall(function()
            if LocalPlayer.Character then
                for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end
        end)
    end)
end

local function DisableNoClip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
end

CreateToggle(miscTab, "No Clip (Walk Through Walls)", function(state)
    noclipEnabled = state
    if state then EnableNoClip() else DisableNoClip() end
end, false)

-- ============================================================================
-- FIXED INFINITE ENERGY (Constant loop - stays at 100%)
-- ============================================================================

local infiniteEnergyEnabled = false
local infiniteEnergyTask = nil

local function StartInfiniteEnergy()
    if infiniteEnergyTask then task.cancel(infiniteEnergyTask) end
    infiniteEnergyTask = task.spawn(function()
        while infiniteEnergyEnabled do
            pcall(function()
                local char = game.Players.LocalPlayer.Character
                if char then
                    local energy = char:FindFirstChild("Energy")
                    if energy and energy.MaxValue then
                        energy.Value = energy.MaxValue
                    end
                    local stamina = char:FindFirstChild("Stamina")
                    if stamina and stamina.MaxValue then
                        stamina.Value = stamina.MaxValue
                    end
                end
            end)
            task.wait(0.1)
        end
    end)
end

CreateToggle(miscTab, "Infinite Energy (Stays at 100%)", function(state)
    infiniteEnergyEnabled = state
    if state then
        StartInfiniteEnergy()
    else
        if infiniteEnergyTask then task.cancel(infiniteEnergyTask) end
    end
end, false)

-- Server Hop
CreateButton(miscTab, "Server Hop (Low Population)", function()
    local success, data = pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=10")
    end)
    if success then
        local servers = HttpService:JSONDecode(data)
        local best = nil
        for _, s in pairs(servers.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                if not best or s.playing < best.playing then
                    best = s
                end
            end
        end
        if best then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, best.id, LocalPlayer)
        end
    end
end)

CreateButton(miscTab, "Rejoin Server", function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

CreateButton(miscTab, "Copy Server ID", function()
    setclipboard(game.JobId)
end)

-- ============================================================================
-- ADMIN TAB CONTENT
-- ============================================================================

CreateSection(adminTab, "Admin & Staff Detection")

local adminLabel = CreateLabel(adminTab, "Current Admins: None")

local function UpdateAdminList()
    local adminsFound = {}
    for _, plr in pairs(Players:GetPlayers()) do
        for _, admin in pairs(AdminNames) do
            if string.lower(plr.Name) == string.lower(admin) then
                table.insert(adminsFound, plr.Name)
            end
        end
    end
    if #adminsFound > 0 then
        adminLabel.Text = "⚠️ ADMINS DETECTED ⚠️\n" .. table.concat(adminsFound, ", ")
        adminLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    else
        adminLabel.Text = "No admins or staff detected in this server."
        adminLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end

task.spawn(function()
    while true do
        UpdateAdminList()
        task.wait(5)
    end
end)

CreateButton(adminTab, "Refresh Admin List", UpdateAdminList)

CreateLabel(adminTab, "Known admins: rip_indra, Uzoth, JayGamesRBX, Haz3rn, ImCrispy, OfficerGreg, Zioles, Axii")

-- ============================================================================
-- CREDITS TAB CONTENT
-- ============================================================================

CreateSection(creditsTab, "Wan0Hub v1 (Beta) ")

local creditsText = Instance.new("TextLabel")
creditsText.Size = UDim2.new(1, -10, 0, 250)
creditsText.Position = UDim2.new(0, 5, 0, 40)
creditsText.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
creditsText.BackgroundTransparency = 0.2
creditsText.Text = [[
Creator: M0nonosuke404
Developer: D33p

FIXES IN v1 (Beta) :
✓ Movement no longer blocked by menu
✓ Movement keys (WASD, Shift) stay active
✓ Improved enemy detection
✓ Quest database for all levels (1-2550)
✓ Auto Haki fixed
✓ Infinite Energy stays at 100%
✓ ESP caching improved

Compatible with:
✓ Xeno Executor
✓ All Executors

Features:
✓ Anti-Ban / Anti-Detect
✓ Auto Farm Level (with quests)
✓ Fast Attack (No Cooldown)
✓ Auto Haki
✓ Player ESP (Red/Blue/Gold)
✓ Legendary/Mythical Fruit ESP (Purple)
✓ Island ESP with Levels
✓ Island Teleports
✓ Travel Between Seas
✓ Auto Sea Beast
✓ Auto Ship Raid
✓ Auto Start Raid
✓ Invisibility
✓ No Clip
✓ Infinite Energy (Stays at 100%)
✓ Server Hop & Rejoin
✓ Admin/Staff Detection
✓ Horizontal Scrolling Tabs

Thanks for using Wan0Hub!
Use at your own risk.
]]
creditsText.TextColor3 = Color3.fromRGB(200, 200, 200)
creditsText.TextWrapped = true
creditsText.Font = Enum.Font.Gotham
creditsText.TextSize = 12
creditsText.Parent = creditsTab

-- ============================================================================
-- FINAL
-- ============================================================================

print("Wan0Hub v1 (Beta)  Loaded Successfully!")
print("Creator: M0nonosuke404")
print("FIXES: Movement keys stay active | Improved Auto Farm | Infinite Energy stays at 100%")