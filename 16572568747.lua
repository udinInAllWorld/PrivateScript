-- Initialize UI library
local ArrayField = loadstring(game:HttpGet("https://raw.githubusercontent.com/Enzo-YTscript/Ui-Library/main/ArrayfieldLibraryUI"))()

-- Create the main window
local Window = ArrayField:CreateWindow({
    Name = "Pet Hatcher",
    LoadingTitle = "SUBSCRIBE ENZO-YT",
    LoadingSubtitle = "by ENZO-YT",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "EnzoYT",
        FileName = "Mystery Chest Simulator Script"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
        Title = "Mystery Chest Simulator",
        Subtitle = "Key System",
        Note = "Key In Description",
        FileName = "MysteryChestSimulatorKeyEnzoYT",
        SaveKey = true,
        GrabKeyFromSite = true,
        Key = {"https://pastebin.com/raw/iJCXgQGb"},
        Actions = {
            [1] = {
                Text = 'Click here to copy the key link',
                OnPress = function() end,
            }
        },
    }
})

-- Anti-AFK and rejoin logic
game:GetService("GuiService").ErrorMessageChanged:Connect(function()
    wait(0.1)
    game:GetService("TeleportService"):Teleport(game.PlaceId)
end)

local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
    vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    wait(1)
    vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

-- Existing Main Tab
local TabMain = Window:CreateTab("HOME", nil) -- Title, Image
local SectionMain = TabMain:CreateSection("Farm", false)
local SectionOrb = TabMain:CreateSection("Orbs", false)

local isSwipingOrbs = false
local orbSwipeCoroutine
local swipeRange = 50 -- default range

-- Function to get instances within the range
local function getOrbsInRange(range)
    local orbs = {}
    if workspace.Content and workspace.Content.Orbs then
        for _, world in pairs(workspace.Content.Orbs:GetChildren()) do
            for _, orb in pairs(world:GetChildren()) do
                if orb:IsA("Model") and orb.PrimaryPart and (orb.PrimaryPart.Position - game.Players.LocalPlayer.Character.PrimaryPart.Position).Magnitude <= range then
                    table.insert(orbs, orb)
                end
            end
        end
    else
        warn("Orbs or workspace.Content not found!")
    end
    return orbs
end

-- Function to create range visualization
local rangeVisualizer
local function createRangeVisualization()
    if not game.Players.LocalPlayer.Character or not game.Players.LocalPlayer.Character.PrimaryPart then
        warn("Player character or PrimaryPart not available!")
        return
    end
    
    -- If there was a previous visualizer, remove it
    if rangeVisualizer then 
        rangeVisualizer:Destroy() 
    end

    -- Create new range visualizer sphere
    rangeVisualizer = Instance.new("Part")
    rangeVisualizer.Shape = Enum.PartType.Ball
    rangeVisualizer.Anchored = true
    rangeVisualizer.CanCollide = false
    rangeVisualizer.Transparency = 0.5
    rangeVisualizer.Color = Color3.new(1, 0, 0) -- Red color
    rangeVisualizer.Size = Vector3.new(swipeRange * 2, swipeRange * 2, swipeRange * 2)
    rangeVisualizer.CFrame = game.Players.LocalPlayer.Character.PrimaryPart.CFrame
    rangeVisualizer.Parent = workspace
end

-- Input Text for Range
local InputRange = TabMain:CreateInput({
    Name = "Swipe Range (Enter a number)",
    SectionParent = SectionOrb,
    PlaceholderText = tostring(swipeRange),
    RemoveTextAfterFocusLost = false,
    Callback = function(value)
        local range = tonumber(value)
        if range then
            swipeRange = math.clamp(range, 10, 100) -- Clamps the range between 10 and 100
        else
            warn("Invalid range input. Please enter a valid number.")
        end
    end,
})

-- Toggle for showing range visualization
local ToggleShowRange = TabMain:CreateToggle({
    Name = "Show Swipe Range",
    SectionParent = SectionOrb,
    CurrentValue = false,
    Callback = function(v)
        if v then
            createRangeVisualization() -- Show the range
        else
            if rangeVisualizer then
                rangeVisualizer:Destroy() -- Hide the range
                rangeVisualizer = nil
            end
        end
    end,
})

-- Create Auto Swipe Toggle
local ToggleAutoSwipeOrb = TabMain:CreateToggle({
    Name = "Auto Swipe Orbs",
    SectionParent = SectionOrb,
    CurrentValue = false,
    Callback = function(v)
        isSwipingOrbs = v
        if isSwipingOrbs then
            orbSwipeCoroutine = coroutine.create(function()
                while isSwipingOrbs do
                    local orbsInRange = getOrbsInRange(swipeRange)
                    for _, orb in pairs(orbsInRange) do
                        if not isSwipingOrbs then
                            return
                        end
                        -- Enter and Leave swipe logic
                        local enterArgs = {
                            [1] = orb, -- The orb instance
                            [2] = "Enter"
                        }
                        game:GetService("ReplicatedStorage").Remotes.Misc.OrbSwipe:FireServer(unpack(enterArgs))

                        local leaveArgs = {
                            [1] = orb, -- The orb instance
                            [2] = "Leave"
                        }
                        game:GetService("ReplicatedStorage").Remotes.Misc.OrbSwipe:FireServer(unpack(leaveArgs))
                    end
                    wait(0.000001) -- Adjust delay as needed
                end
            end)
            coroutine.resume(orbSwipeCoroutine)
        else
            -- Stop the coroutine when the toggle is turned off
            isSwipingOrbs = false
            if orbSwipeCoroutine then
                coroutine.close(orbSwipeCoroutine)
            end
        end
    end,
})

-- Create Egg Tab and Auto Egg Section
local TabEgg = Window:CreateTab("Egg", nil) -- Title, Image
local SectionAutoEgg = TabEgg:CreateSection("AutoEgg", false)

-- Variables for Auto Hatch
local selectedEgg = ""
local selectedWorld = ""
local hatchMode = 1
local isAutoHatching = false
local hatchCoroutine

-- Get a list of all eggs in a hierarchical format
local function getEggList()
    local eggList = {}
    local eggWorlds = workspace.Content.Misc.Eggs:GetChildren()

    -- Sort by world names for consistency
    table.sort(eggWorlds, function(a, b) return a.Name < b.Name end)

    -- Loop through each world and gather the eggs
    for _, world in pairs(eggWorlds) do
        local worldName = world.Name
        for _, egg in pairs(world:GetChildren()) do
            if egg:IsA("Model") then
                -- Add each egg with its world name as a prefix
                table.insert(eggList, worldName .. " - " .. egg.Name)
            end
        end
    end
    return eggList
end

-- Parse egg dropdown option into world and egg name
local function parseEggSelection(selection)
    local splitIndex = string.find(selection, " - ")
    if splitIndex then
        local world = string.sub(selection, 1, splitIndex - 1)
        local egg = string.sub(selection, splitIndex + 3)
        return world, egg
    end
    return "", ""
end

-- Create Egg Dropdown
local EggDropdown = TabEgg:CreateDropdown({
    Name = "Select Egg",
    SectionParent = SectionAutoEgg,
    Options = getEggList(),
    CurrentOption = "",
    Callback = function(option)
        selectedWorld, selectedEgg = parseEggSelection(option)
    end,
})

-- Create Hatch Mode Dropdown
local HatchModeDropdown = TabEgg:CreateDropdown({
    Name = "Hatch Mode",
    SectionParent = SectionAutoEgg,
    Options = {"1", "3", "10", "20", "50",},
    CurrentOption = "1",
    Callback = function(option)
        if option == "max" then
            hatchMode = 100 -- Assuming max is handled as a high number
        else
            hatchMode = tonumber(option)
        end
    end,
})

-- Ensure the character is fully loaded
local function ensureCharacterLoaded()
    local player = game.Players.LocalPlayer
    while not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") do
        wait(0.1) -- Wait until character and PrimaryPart (HumanoidRootPart) are fully loaded
    end
    return player.Character.HumanoidRootPart
end

-- Function to teleport player to the egg's position or primary part
local function teleportToEggPosition(worldName, eggName)
    local eggWorld = workspace.Content.Misc.Eggs:FindFirstChild(worldName)
    if eggWorld then
        local eggModel = eggWorld:FindFirstChild(eggName)
        if eggModel then
            local eggPart = eggModel:FindFirstChild("Egg") -- Look for the "Egg" part inside the model
            if eggPart then
                local playerPrimaryPart = ensureCharacterLoaded()
                if playerPrimaryPart then
                    -- Teleport to the Egg part inside the selected egg model
                    playerPrimaryPart.CFrame = eggPart.CFrame
                    return true
                else
                    warn("Player's PrimaryPart (HumanoidRootPart) not found!")
                end
            else
                warn("Egg part not found inside the egg model: " .. eggName)
            end
        else
            warn("Egg model not found in world: " .. worldName)
        end
    else
        warn("Egg World not found!")
    end
    return false
end

-- Auto Hatch Toggle
local ToggleAutoHatch = TabEgg:CreateToggle({
    Name = "Auto Hatch",
    SectionParent = SectionAutoEgg,
    CurrentValue = false,
    Callback = function(v)
        isAutoHatching = v
        if isAutoHatching then
            -- Teleport to the egg's position or part
            if teleportToEggPosition(selectedWorld, selectedEgg) then
                -- Start the hatching process
                hatchCoroutine = coroutine.create(function()
                    while isAutoHatching do
                        -- Invoke the DetermineGems function
                        game:GetService("ReplicatedStorage").Remotes.Eggs.DetermineGems:InvokeServer()

                        -- Hatch the selected egg with the selected mode
                        local hatchArgs = {
                            [1] = selectedEgg,
                            [2] = hatchMode
                        }
                        game:GetService("ReplicatedStorage").Remotes.Eggs.Hatch:InvokeServer(unpack(hatchArgs))

                        -- Send hatch event multiple times based on hatch mode
                        for i = 1, hatchMode do
                            game:GetService("ReplicatedStorage").Remotes.Misc.sendHatch:FireServer()
                        end

                        -- Stop Hatching function, based on hatch mode
                        local stopHatchArgs = {[1] = {}}
                        for i = 1, hatchMode do
                            table.insert(stopHatchArgs[1], i)
                        end
                        game:GetService("ReplicatedStorage").Remotes.Eggs.StopHatching:InvokeServer(unpack(stopHatchArgs))

                        -- Wait before the next cycle (adjust as needed)
                        wait(1)
                    end
                end)
                coroutine.resume(hatchCoroutine)
            else
                warn("Failed to teleport to the selected egg's position!")
            end
        else
            -- Stop hatching when the toggle is deactivated
            if hatchCoroutine then
                coroutine.close(hatchCoroutine)
            end
        end
    end,
})

-- Auto Airdrops Toggle
local ToggleAutoAirdrops = TabMain:CreateToggle({
    Name = "Auto Airdrops",
    SectionParent = SectionMain,
    CurrentValue = false,
    Callback = function(v)
        if v then
            -- Check if there are any folders inside Airdrops
            local airdropsFolder = workspace.Content.LocalStorage:FindFirstChild("Airdrops")
            if airdropsFolder then
                -- Loop through the folders inside Airdrops and find the first valid one
                local foundAirdrop = false
                for _, airdropFolder in pairs(airdropsFolder:GetChildren()) do
                    if airdropFolder:IsA("Folder") and airdropFolder:FindFirstChild("PositionValue") then
                        -- Assume PositionValue is the part we want to teleport to
                        local targetPart = airdropFolder:FindFirstChild("PositionValue")
                        
                        -- Ensure the player's primary part is loaded
                        local playerPrimaryPart = ensureCharacterLoaded()
                        if playerPrimaryPart and targetPart then
                            -- Teleport player to the part inside the airdrop folder
                            playerPrimaryPart.CFrame = targetPart.CFrame
                            foundAirdrop = true

                            -- Simulate touch by firing TouchInterest if it exists
                            local touchInterest = airdropFolder:FindFirstChild("TouchInterest")
                            if touchInterest then
                                firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, targetPart, 0) -- Touch begin
                                wait(0.1) -- Small delay
                                firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, targetPart, 1) -- Touch end
                            else
                                warn("TouchInterest not found in the folder: " .. airdropFolder.Name)
                            end
                            break -- Exit loop after teleporting to the first valid airdrop
                        else
                            warn("Player's PrimaryPart (HumanoidRootPart) or target part not found!")
                        end
                    end
                end

                if not foundAirdrop then
                    warn("No valid Airdrop folder found!")
                end
            else
                warn("Airdrops folder not found in workspace!")
            end
        end
    end,
})

-- Function to ensure the player's character is fully loaded
function ensureCharacterLoaded()
    local player = game.Players.LocalPlayer
    while not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") do
        wait(0.1) -- Wait until the character and HumanoidRootPart are loaded
    end
    return player.Character.HumanoidRootPart
end
