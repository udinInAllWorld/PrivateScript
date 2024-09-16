-- Initialize UI library
local ArrayField = loadstring(game:HttpGet("https://raw.githubusercontent.com/Enzo-YTscript/Ui-Library/main/ArrayfieldLibraryUI"))()

-- Create the main window
local Window = ArrayField:CreateWindow({
    Name = "Hoop Simulator",
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
local SectionGift = TabMain:CreateSection("Gift", false)
local SectionShoot = TabMain:CreateSection("Shoot", false) -- Section untuk Auto Shoot

local isGifting = false
local giftCoroutine

local ToggleAutoGift = TabMain:CreateToggle({
    Name = "Auto Gift",
    SectionParent = SectionGift,
    CurrentValue = false,
    Callback = function(v)
        isGifting = v
        if isGifting then
            giftCoroutine = coroutine.create(function()
                while isGifting do
                    for i = 1, 9 do 
                        if not isGifting then
                            return
                        end
                        local args = {[1] = i}
                        game:GetService("ReplicatedStorage"):FindFirstChild("events-V3x"):FindFirstChild("266b27ad-aa4c-48e4-8e52-d8a24bbe68ba"):FireServer(unpack(args))

                        wait(30) 
                    end
                end
            end)
            coroutine.resume(giftCoroutine)
        else
            -- Stop the coroutine when the toggle is turned off
            isGifting = false
            if giftCoroutine then
                coroutine.close(giftCoroutine)
            end
        end
    end,
})

-- Auto Shoot logic
local isShooting = false
local shootCoroutine

local ToggleAutoShoot = TabMain:CreateToggle({
    Name = "Auto Shoot",
    SectionParent = SectionShoot,
    CurrentValue = false,
    Callback = function(v)
        isShooting = v
        if isShooting then
            shootCoroutine = coroutine.create(function()
                while isShooting do
                    local args = {[1] = 1}
                    game:GetService("ReplicatedStorage"):FindFirstChild("events-V3x"):FindFirstChild("8eeeb218-a53f-4e8c-81d0-905cf9a7154f"):FireServer(unpack(args))

                    wait(7) -- Menunggu 1 detik sebelum menembak lagi
                end
            end)
            coroutine.resume(shootCoroutine)
        else
            -- Stop the coroutine when the toggle is turned off
            isShooting = false
            if shootCoroutine then
                coroutine.close(shootCoroutine)
            end
        end
    end,
})

-- New Capsules Tab
local TabCapsules = Window:CreateTab("CAPSULES", nil) -- Title, Image
local SectionCapsules = TabCapsules:CreateSection("Capsules", false)

-- List of chests
local chestList = {}
local selectedChest = nil
local isAutoOpening = false
local autoOpenCoroutine = nil

-- Helper function to create the dropdown list for specific worlds and handle GetChildren() cases
local function createDropdownListForWorlds()
    chestList = {}  -- Reset the chest list

    -- Define the specific paths and structure to add to the dropdown
    local pathsToAdd = {
        -- World0
        {worldName = "World0", chests = {
            "workspace.Map.World0.Capsules.CandyChest",
            "workspace.Map.World0.Capsules.CountryChest",
            "workspace.Map.World0.Capsules.FoodChest",
            "workspace.Map.World0.Capsules.FruitChest",
            "workspace.Map.World0.Capsules.IceChest",
            "workspace.Map.World0.Capsules.MagmaChest",
            "workspace.Map.World0.Capsules.MedalChest",
            "workspace.Map.World0.Capsules.PlanetChest",
            "workspace.Map.World0.Capsules.SportsChest",
            "workspace.Map.World0.Capsules.StarterChest",
            "workspace.Map.World0.Capsules.ToxicChest",
            "workspace.Map.World0.Capsules.WaterChest"
        }},
        -- World10
        {worldName = "World10", chests = {
            "workspace.Map.World10.DragonChest",
            "workspace.Map.World10.StarterChest",
            "workspace.Map.World10.YangChest",
            "workspace.Map.World10.YinChest",
            "workspace.Map.World10.TechChest",
            "workspace.Map.World0.Pets.PetEggs.PetHeavenChest",
            "workspace.Map.World0.Pets.PetEggs.PetJapanChest"
        }},
        -- World15
        {worldName = "World15", chests = {
            "workspace.Map.World15.Chests.SpaceChest",
            "workspace.Map.World15.Chests.MoonChest",
            "workspace.Map.World15.Chests.MarsChest",
            "workspace.Map.World15.Chests.SpacePirateChest",
            "workspace.Map.World15.Chests.SunChest",
            "workspace.Map.World15.Chests.UFOChest",
            "workspace.Map.World15.Chests.CosmicForestChest",
            "workspace.Map.World15.Chests.CryoChest",
            "workspace.Map.World15.Chests.PetCosmicChest",
            "workspace.Map.World15.Chests.PetCryoChest",
            "workspace.Map.World15.Chests.PetRobotChest",
            "workspace.Map.World15.Chests.PetUndeadChest",
            "workspace.Map.World15.GlitchEggChest"
        }},
        -- World25
        {worldName = "World25", chests = {
            "workspace.Map.World25.CircusChest",
            "workspace.Map.World25.PaperChest",
            "workspace.Map.World25.PetPaperChest"
        }},
        -- World29
        {worldName = "World29", chests = {
            "workspace.Map.World29.Chests.CartoonBallsChest",
            "workspace.Map.World29.Chests.KawaiiBallsChest",
            "workspace.Map.World29.Chests.SuperheroChest",
            "workspace.Map.World29.Chests.DinosaurChest"
        }},
        -- World37
        {worldName = "World37", chests = {
            "workspace.Map.World37.Chests.DreamChest",
            "workspace.Map.World37.Chests.BubbleChest"
        }}
    }

    -- Helper to transform paths into the desired format
    local function formatChestName(worldName, chestPath)
        -- Extract the chest name, remove "Chest" and world prefix, and convert to lowercase
        local chestName = chestPath:match("Capsules%.([^%.]+)Chest") or chestPath:match("Chests%.([^%.]+)Chest") or chestPath:match("Pets%.PetEggs%.([^%.]+)Chest") or chestPath:match("([^%.]+)Chest")
        
        if chestName then
            chestName = chestName:lower()  -- Convert to lowercase
        end
        
        return chestName -- Return the formatted name (e.g., "candy")
    end

    -- Loop through the paths and add them to chestList in the required format
    for _, world in pairs(pathsToAdd) do
        for _, chestPath in pairs(world.chests) do
            local formattedChestName = formatChestName(world.worldName, chestPath)
            if formattedChestName then
                table.insert(chestList, formattedChestName)  -- Add only the formatted name to chestList
            end
        end
    end

    -- Print chestList to verify contents
    print("Chest List Contents:", chestList)
end

-- Call the function to populate chest list
createDropdownListForWorlds()

-- Create a dropdown for Capsules
local DropdownCapsules = TabCapsules:CreateDropdown({
    Name = "Select Capsule",
    Options = chestList,  -- Use the populated chestList here
    SectionParent = SectionCapsules,
    CurrentOption = nil,
    Callback = function(selected)
        selectedChest = selected -- Nama yang dipilih dari dropdown sudah diformat
    end
})

-- Toggle AutoOpen logic
local ToggleAutoOpen = TabCapsules:CreateToggle({
    Name = "AutoOpen",
    SectionParent = SectionCapsules,
    CurrentValue = false,
    Callback = function(state)
        isAutoOpening = state
        if isAutoOpening and selectedChest then
            -- Start auto-open coroutine
            autoOpenCoroutine = coroutine.create(function()
                while isAutoOpening do
                    -- Nama chest sudah diformat di dropdown, langsung dikirim ke server
                    local args = {
                        [1] = selectedChest, -- Nama chest (misal: "candy")
                        [2] = false
                    }

                    -- Fire the server to open the chest
                    game:GetService("ReplicatedStorage"):WaitForChild("events-V3x"):WaitForChild("129822f0-7d5f-4903-b13a-901327707e68"):FireServer(unpack(args))

                    wait(5) -- Sesuaikan waktu jeda untuk membuka chest
                end
            end)
            coroutine.resume(autoOpenCoroutine)
        elseif not isAutoOpening then
            -- Stop the auto-open coroutine
            if autoOpenCoroutine then
                coroutine.close(autoOpenCoroutine)
            end
        end
    end
})


-- New Teleport Tab
local TabTeleport = Window:CreateTab("TELEPORT", nil) -- Title, Image
local SectionTeleport = TabTeleport:CreateSection("Teleport Worlds", false)

-- Helper function to teleport player using CFrame
local function teleportToLocation(cframe)
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = cframe
    end
end

-- Helper function to find and teleport using Cylinder.040 in specific paths
local function findAndTeleportCylinder(world)
    -- Mencari di dalam Portal
    local portalPart = world:FindFirstChild("Portal")
    if portalPart then
        local cylinder = portalPart:FindFirstChild("Cylinder.040")
        if cylinder then
            teleportToLocation(cylinder.CFrame)
            return true -- Berhasil teleport
        elseif portalPart:FindFirstChild("Portal") then
            local nestedPortal = portalPart.Portal:FindFirstChild("Cylinder.040")
            if nestedPortal then
                teleportToLocation(nestedPortal.CFrame)
                return true -- Berhasil teleport
            end
        end
    end

    -- Mencari di dalam Interact
    local interactPart = world:FindFirstChild("Interact")
    if interactPart then
        local cylinder = interactPart:FindFirstChild("Cylinder.040")
        if cylinder then
            teleportToLocation(cylinder.CFrame)
            return true -- Berhasil teleport
        end
    end

    -- Mencari di path lainnya
    for _, child in ipairs(world:GetChildren()) do
        local cylinder = child:FindFirstChild("Cylinder.040")
        if cylinder then
            teleportToLocation(cylinder.CFrame)
            return true -- Berhasil teleport
        end
    end

    -- Jika tidak ditemukan
    print("Warning: Cylinder.040 not found in", world.Name)
    return false
end

-- Custom handling for World33 to World38 using CFrame directly
local function customCFrameTeleport(world)
    if world.Name == "World35" then
        local portal = world:FindFirstChild("PortalPixel") and world.PortalPixel:FindFirstChild("Portal.003")
        if portal then
            teleportToLocation(portal.CFrame)
            return true
        end
    elseif world.Name == "World36" then
        local portal = world:FindFirstChild("PortalPixel") and world.PortalPixel:FindFirstChild("Portal.003")
        if portal then
            teleportToLocation(portal.CFrame)
            return true
        end
    elseif world.Name == "World37" then
        local interact = world:FindFirstChild("Interact")
        if interact and interact:GetChildren()[6] and interact:GetChildren()[6]["Cylinder.039"] then
            teleportToLocation(interact:GetChildren()[6]["Cylinder.039"].CFrame)
            return true
        end
    else
        local portal = world:FindFirstChild("Portal")
        if portal and portal.PrimaryPart then
            teleportToLocation(portal.PrimaryPart.CFrame)
            return true
        end
    end
    print("Warning: CFrame not found for", world.Name)
    return false
end

-- Sort the worlds numerically by name (World0, World1, etc.)
local worlds = {}
for _, world in pairs(workspace.Map:GetChildren()) do
    if world:IsA("Folder") and world.Name:match("^World%d+") then
        table.insert(worlds, world)
    end
end
table.sort(worlds, function(a, b)
    local aNum = tonumber(a.Name:match("%d+"))
    local bNum = tonumber(b.Name:match("%d+"))
    return aNum < bNum
end)

-- Create buttons for sorted worlds
for _, world in pairs(worlds) do
    TabTeleport:CreateButton({
        Name = world.Name,
        SectionParent = SectionTeleport,
        Callback = function()
            -- Custom handling for World33 to World38 (CFrame)
            if tonumber(world.Name:match("%d+")) >= 33 and tonumber(world.Name:match("%d+")) <= 38 then
                local success = customCFrameTeleport(world)
                if not success then
                    print("Teleport failed for", world.Name)
                end
            else
                -- Default handling for other worlds (Cylinder.040)
                local success = findAndTeleportCylinder(world)
                if not success then
                    print("Teleport failed for", world.Name)
                end
            end
        end
    })
end
