-- Initialize UI library
local ArrayField = loadstring(game:HttpGet("https://raw.githubusercontent.com/Enzo-YTscript/Ui-Library/main/ArrayfieldLibraryUI"))()

-- Create the main window
local Window = ArrayField:CreateWindow({
    Name = "Survival Oddesy VOID",
    LoadingTitle = "SUBSCRIBE ENZO-YT",
    LoadingSubtitle = "by ENZO-YT",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "EnzoYT",
        FileName = "Survival Oddesy VOIDScript"
    },
    Discord = {
        Enabled = true,
        Invite = "https://discord.gg/WFjWKwBv8p",
        RememberJoins = false
    },
    KeySystem = false,
    KeySettings = {
        Title = "Survival Oddesy",
        Subtitle = "Key System",
        Note = "Key In YT Description or in Discord",
        FileName = "SurvivalOddesyVOIDKeyEnzoYT",
        SaveKey = true,
        GrabKeyFromSite = true,
        Key = {"https://pastebin.com/raw/9n5jBW7v"},
        Actions = {
            [1] = {
                Text = 'Click here to copy the discord link',
                OnPress = function()
                    -- Copy Discord link to clipboard
                    setclipboard("https://discord.gg/WFjWKwBv8p")
                    
                    -- Display notification
                    game.StarterGui:SetCore("SendNotification", {
                        Title = "Link Copied";
                        Text = "The Discord link has been copied to your clipboard.";
                        Duration = 5;
                    })
                end,
            }
        },
    }
})

-- Anti-AFK and rejoin logic
game:GetService("GuiService").ErrorMessageChanged:Connect(function()
    wait(1)
    game:GetService("TeleportService"):Teleport(game.PlaceId)
end)

local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
    vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    wait(1)
    vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

-- Main Tab
local TabMain = Window:CreateTab("HOME", nil) -- Title, Image
local SectionMain = TabMain:CreateSection("Auto", false)

-- Fungsi untuk menghilangkan duplikat nama dalam list
local function removeDuplicates(list)
    local seen = {}
    local uniqueList = {}

    for _, item in ipairs(list) do
        if not seen[item] then
            seen[item] = true
            table.insert(uniqueList, item)
        end
    end

    return uniqueList
end

-- Fungsi untuk mencari resource di seluruh subfolder dari workspace.Map.Resources
local function findAllInstances(resourceName)
    local instances = {}
    local function scanFolder(folder)
        for _, item in ipairs(folder:GetChildren()) do
            if item:IsA("Folder") then
                scanFolder(item)
            elseif item:IsA("Model") and item.Name == resourceName then
                table.insert(instances, item)
            end
        end
    end
    scanFolder(workspace.Map.Resources)
    return instances
end

-- Dropdown untuk memilih Resource dari workspace.Map.Resources
-- Fungsi untuk menghasilkan dropdown Resources yang terurut
-- Fungsi untuk menghasilkan dropdown Resources dengan aturan khusus
-- Modified function to generate the resource list with a check for "Crystal Guardian"
local function generateDropdownResources()
    local resourceFolder = workspace.Map.Resources:GetChildren()
    local ResourceList = {}

    for _, folder in ipairs(resourceFolder) do
        -- Add all folders and models to ResourceList without additional checks
        if folder:IsA("Folder") or folder:IsA("Model") then
            table.insert(ResourceList, folder.Name)
            for _, item in ipairs(folder:GetChildren()) do
                if item:IsA("Model") or item:IsA("Folder") then
                    table.insert(ResourceList, item.Name)
                end
            end
        end
    end

    -- Check if "Crystal Guardian" exists before adding it to the ResourceList
    local crystalGuardian = workspace:FindFirstChild("Crystal Guardian", true)
    if crystalGuardian then
        table.insert(ResourceList, "Crystal Guardian")
    end

    -- Remove duplicate names from the dropdown
    ResourceList = removeDuplicates(ResourceList)

    -- Sort the ResourceList alphabetically
    table.sort(ResourceList)

    return ResourceList
end



local ResourceList = generateDropdownResources()
local SelectedResource = nil

-- Dropdown untuk memilih Resource
local DropdownResources = TabMain:CreateDropdown({
    Name = "Resources",
    SectionParent = SectionMain,
    Options = ResourceList,
    CurrentOption = "",
    Callback = function(option)
        SelectedResource = option
    end,
})

-- Fungsi untuk memulai farming
local function startFarming()
    if SelectedResource then
        farmCoroutine = coroutine.create(function()
            local instances = findAllInstances(SelectedResource)

            if #instances > 0 then
                for _, instance in ipairs(instances) do
                    if isFarming and instance:IsA("Model") then
                        local target = instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart")
                        if target then
                            local offsetPosition = target.Position + Vector3.new(0, 5, 0)
                            game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(offsetPosition))

                            while isFarming and instance.Parent do
                                local args = {
                                    [1] = {
                                        [1] = instance
                                    }
                                }
                                game:GetService("ReplicatedStorage").Events.SwingTool:FireServer(unpack(args))
                                wait(0.001)
                            end

                            wait(1)
                        end
                    end
                end
            end
        end)
        coroutine.resume(farmCoroutine)
    end
end

-- Toggle untuk memulai/berhenti farming
local ToggleFarmResources = TabMain:CreateToggle({
    Name = "Farm Resources",
    SectionParent = SectionMain,
    CurrentValue = false,
    Callback = function(v)
        isFarming = v
        if isFarming then
            startFarming()
        else
            if farmCoroutine then
                coroutine.close(farmCoroutine)
            end
        end
    end,
})

-- Fungsi untuk mendapatkan instance nil
local function getNil(name, class)
    for _, v in pairs(getnilinstances()) do
        if v.ClassName == class and v.Name == name then
            return v
        end
    end
end

local isPickingUp = false
local pickupCoroutine
local pickupRadius = 1000 -- Jarak maksimal untuk memungut item, dapat disesuaikan

-- Fungsi untuk memulai pickup items
local function startPickingUp()
    pickupCoroutine = coroutine.create(function()
        while isPickingUp do
            -- print("Checking for items to pickup...")
            local itemsFolder = workspace.Important.Items
            if itemsFolder then
                for _, item in ipairs(itemsFolder:GetChildren()) do
                    if not isPickingUp then
                        return
                    end
                    if item:IsA("BasePart") then
                        -- Cek jarak antara player dan item
                        local playerPosition = game.Players.LocalPlayer.Character.PrimaryPart.Position
                        local itemPosition = item.Position
                        local distance = (playerPosition - itemPosition).Magnitude
                        
                        if distance <= pickupRadius then
                          -- print("Found an item within radius:", item.Name)
                            local args = {
                                [1] = item -- Langsung gunakan item yang ditemukan
                            }
                            game:GetService("ReplicatedStorage").Events.Pickup:FireServer(unpack(args))
                        end
                    end
                end
            end
            wait(0.05) -- Mempercepat jeda sebelum memeriksa ulang item
        end
    end)
    coroutine.resume(pickupCoroutine)
end



-- Toggle untuk memulai/berhenti pickup items
local TogglePickupEverything = TabMain:CreateToggle({
    Name = "Pickup Everything",
    SectionParent = SectionMain,
    CurrentValue = false,
    Callback = function(v)
        isPickingUp = v
        if isPickingUp then
            startPickingUp()
        else
            if pickupCoroutine then
                coroutine.close(pickupCoroutine)
            end
        end
    end,
})

-- Slider untuk mengatur radius hit
local hitRadius = 20 -- Radius default
local SliderHitRadius = TabMain:CreateSlider({
    Name = "Hit Radius",
    SectionParent = SectionMain,
    Range = {1, 100},
    Increment = 1,
    Suffix = "Radius",
    CurrentValue = hitRadius,
    Flag = "HitRadiusSlider",
    Callback = function(Value)
        hitRadius = Value
    end,
})

-- Fungsi untuk memukul resource di depan pemain
local function hitNearbyResources()
    local player = game.Players.LocalPlayer
    local playerCharacter = player.Character
    local playerPosition = playerCharacter.PrimaryPart.Position
    local playerLookVector = playerCharacter.PrimaryPart.CFrame.LookVector -- Arah depan pemain
    local resources = workspace.Map.Resources:GetChildren()

    for _, resourceFolder in ipairs(resources) do
        if resourceFolder:IsA("Folder") then
            for _, resource in ipairs(resourceFolder:GetChildren()) do
                if resource:IsA("Model") then
                    local resourcePosition = resource.PrimaryPart and resource.PrimaryPart.Position or resource:GetModelCFrame().Position
                    local directionToResource = (resourcePosition - playerPosition).Unit
                    local distance = (playerPosition - resourcePosition).Magnitude

                    -- Hanya pukul resource yang berada dalam hitRadius dan di depan pemain
                    if distance <= hitRadius and playerLookVector:Dot(directionToResource) > 0 then
                        local args = {
                            [1] = {
                                [1] = resource,
                                [2] = resource
                            }
                        }
                        game:GetService("ReplicatedStorage").Events.SwingTool:FireServer(unpack(args))
                    end
                end
            end
        end
    end
end


local isHitting = false
local hitCoroutine

-- Toggle untuk memulai/berhenti hit everything
local ToggleHitEverything = TabMain:CreateToggle({
    Name = "Hit Everything",
    SectionParent = SectionMain,
    CurrentValue = false,
    Callback = function(v)
        isHitting = v
        if isHitting then
            hitCoroutine = coroutine.create(function()
                while isHitting do
                    hitNearbyResources()
                    wait(0.001) -- Tunggu sebentar sebelum hit lagi
                end
            end)
            coroutine.resume(hitCoroutine)
        else
            if hitCoroutine then
                coroutine.close(hitCoroutine)
            end
        end
    end,
})

-- Section for Auto Heal & Food
local SectionAutoHealFood = TabMain:CreateSection("Auto Heal & Food", false)

-- Variables to track the Auto Heal & Food status
local autoHealEnabled = false
local autoFoodEnabled = false
local healThreshold = 50
local foodThreshold = 50
local healItem = "Bloodfruit"  -- Default heal item
local foodItem = "Cooked Meat"  -- Default food item

-- Function to retrieve inventory list from PlayerGui
local function generateInventoryDropdown()
    local inventory = game:GetService("Players").LocalPlayer.PlayerGui.MainGui.RightPanel.Inventory.List:GetChildren()
    local inventoryList = {}

    for _, item in ipairs(inventory) do
        if item:IsA("TextButton") or item:IsA("ImageButton") then
            table.insert(inventoryList, item.Name)
        end
    end

    return inventoryList
end

local InventoryList = generateInventoryDropdown()

-- Dropdown for selecting Heal Item
local DropdownHealItem = TabMain:CreateDropdown({
    Name = "Heal Item Dropdown",
    SectionParent = SectionAutoHealFood,
    Options = InventoryList,
    CurrentOption = healItem,
    Callback = function(option)
        healItem = option
    end,
})

-- Dropdown for selecting Food Item
local DropdownFoodItem = TabMain:CreateDropdown({
    Name = "Food Item Dropdown",
    SectionParent = SectionAutoHealFood,
    Options = InventoryList,
    CurrentOption = foodItem,
    Callback = function(option)
        foodItem = option
    end,
})

-- Function to perform healing
local function performHeal()
    local stats = game:GetService("Players").LocalPlayer.PlayerGui.MainGui.Panels.Stats.List
    if stats and stats:FindFirstChild("Health") and stats.Health:FindFirstChild("NumberLabel") then
        local currentHealth = tonumber(stats.Health.NumberLabel.ContentText)
        if currentHealth < healThreshold then
            local args = {
                [1] = healItem
            }
            game:GetService("ReplicatedStorage").Events.UseBagItem:FireServer(unpack(args))
        end
    end
end

-- Function to perform eating
local function performFood()
    local stats = game:GetService("Players").LocalPlayer.PlayerGui.MainGui.Panels.Stats.List
    if stats and stats:FindFirstChild("Food") and stats.Food:FindFirstChild("NumberLabel") then
        local currentFood = tonumber(stats.Food.NumberLabel.ContentText)
        if currentFood < foodThreshold then
            local args = {
                [1] = foodItem
            }
            game:GetService("ReplicatedStorage").Events.UseBagItem:FireServer(unpack(args))
        end
    end
end

-- Monitor Auto Heal
local function monitorAutoHeal()
    while autoHealEnabled do
        performHeal()
        wait(1)  -- Check every 1 second
    end
end

-- Monitor Auto Food
local function monitorAutoFood()
    while autoFoodEnabled do
        performFood()
        wait(1)  -- Check every 1 second
    end
end

-- Toggle for Auto Heal
local ToggleAutoHeal = TabMain:CreateToggle({
    Name = "Auto Heal",
    SectionParent = SectionAutoHealFood,
    CurrentValue = false,
    Callback = function(v)
        autoHealEnabled = v
        if autoHealEnabled then
            spawn(monitorAutoHeal)
        end
    end,
})

-- Toggle for Auto Food
local ToggleAutoFood = TabMain:CreateToggle({
    Name = "Auto Food",
    SectionParent = SectionAutoHealFood,
    CurrentValue = false,
    Callback = function(v)
        autoFoodEnabled = v
        if autoFoodEnabled then
            spawn(monitorAutoFood)
        end
    end,
})

-- Slider for Heal Threshold
local SliderHealThreshold = TabMain:CreateSlider({
    Name = "Heal Threshold",
    SectionParent = SectionAutoHealFood,
    Range = {1, 100},
    Increment = 1,
    Suffix = "HP",
    CurrentValue = healThreshold,
    Callback = function(Value)
        healThreshold = Value
    end,
})

-- Slider for Food Threshold
local SliderFoodThreshold = TabMain:CreateSlider({
    Name = "Food Threshold",
    SectionParent = SectionAutoHealFood,
    Range = {1, 100},
    Increment = 1,
    Suffix = "Hunger",
    CurrentValue = foodThreshold,
    Callback = function(Value)
        foodThreshold = Value
    end,
})

-- Input for Heal Item (Backup manual input)
local InputHealItem = TabMain:CreateInput({
    Name = "Heal Item (Manual Input)",
    SectionParent = SectionAutoHealFood,
    PlaceholderText = healItem,
    Callback = function(value)
        healItem = value
    end,
})

-- Input for Food Item (Backup manual input)
local InputFoodItem = TabMain:CreateInput({
    Name = "Food Item (Manual Input)",
    SectionParent = SectionAutoHealFood,
    PlaceholderText = foodItem,
    Callback = function(value)
        foodItem = value
    end,
})

-- Section untuk FLY
local SectionFly = TabMain:CreateSection("Fly", false)
-- Buat tombol Fly
TabMain:CreateButton({
    Name = "Fly",
    SectionParent = SectionFly,
    Callback = function()
        -- Jalankan loadstring saat tombol ditekan
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Enzo-YTscript/scrp/main/FlyGUIV3.lua"))()
    end,
})


local SectionWorld = TabMain:CreateSection("Button World", false)
-- Button Void
local TPToVoidButton = TabMain:CreateButton({
    Name = "TP to Void",  -- Label of the button
    SectionParent = SectionWorld,  -- Place it under the SectionWorld section
    Callback = function()
        -- Teleport the player to the specified place ID
        local TeleportService = game:GetService("TeleportService")
        local placeId = 18629058177  -- The place ID to teleport to

        -- Teleport to the specified place
        TeleportService:Teleport(placeId, game.Players.LocalPlayer)
    end,
})

-- Button Normal
local TPToNormalButton = TabMain:CreateButton({
    Name = "TP to Normal",  -- Label of the button
    SectionParent = SectionWorld,  -- Place it under the SectionWorld section
    Callback = function()
        -- Teleport the player to the specified place ID
        local TeleportService = game:GetService("TeleportService")
        local placeId = 18629053284  -- The place ID to teleport to

        -- Teleport to the specified place
        TeleportService:Teleport(placeId, game.Players.LocalPlayer)
    end,
})


-- Section untuk WalkSpeed
local SectionWalkSpeed = TabMain:CreateSection("WalkSpeed", false)

-- Slider untuk mengatur WalkSpeed
local walkSpeedValue = 16 -- Nilai default WalkSpeed di Roblox
local walkSpeedEnabled = false -- Status apakah WalkSpeed sedang aktif

local function maintainWalkSpeed()
    while walkSpeedEnabled do
        if game.Players.LocalPlayer and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = walkSpeedValue
        end
        wait(1) -- Memastikan speed diatur setiap 0.1 detik
    end
end

local SliderWalkSpeed = TabMain:CreateSlider({
    Name = "WalkSpeed",
    SectionParent = SectionWalkSpeed,
    Range = {1, 100},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = walkSpeedValue,
    Flag = "WalkSpeedSlider",
    Callback = function(Value)
        walkSpeedValue = Value
        if walkSpeedEnabled then
            maintainWalkSpeed() -- Mulai memastikan speed
        end
    end,
})

-- Toggle untuk mengaktifkan WalkSpeed
local ToggleWalkSpeed = TabMain:CreateToggle({
    Name = "Toggle WalkSpeed",
    SectionParent = SectionWalkSpeed,
    CurrentValue = false,
    Callback = function(v)
        walkSpeedEnabled = v
        if walkSpeedEnabled then
            maintainWalkSpeed() -- Mulai memastikan speed
        end
    end,
})

-- ESP Tab
local TabESP = Window:CreateTab("ESP", nil) -- Create the ESP tab
local ESPSection = TabESP:CreateSection("ESP Section", false)

-- Toggle variables
local espToggles = {}

-- List of entities for which ESP will be created
local espEntities = {
    "Adurite Shelly", "Baby Sand Mammoth", "Big Stone Shelly", "Coal Shelly", "Emerald Giant", "Fire Ant Mound",
    "Giant Shelly", "Gold Shelly", "Golden Banto", "Goldy Boi", "Goober", "Huge Ant Mound", "Iron Shelly",
    "Lil Banto", "Lurky Boi", "Peeper", "Pink Giant", "Queen Ant", "Rentae", "Rento", "Sand Mammoth",
    "Shelbert", "Shelby", "Sheldon", "Snow Mammoth", "Spirit Shelly", "Stone Shelly", "White Ant Mound"
}

-- Fungsi untuk menggambar dan memperbarui ESP
local function updateESP()
    local crittersFolder = workspace.Important.Critters
    local playerPosition = game.Players.LocalPlayer.Character.PrimaryPart.Position

    for _, critter in ipairs(crittersFolder:GetChildren()) do
        if critter:IsA("Model") then
            local critterName = critter.Name
            local primaryPart = critter.PrimaryPart
            if primaryPart then
                local critterPosition = primaryPart.Position
                local distance = (playerPosition - critterPosition).Magnitude

                -- Memeriksa apakah ESP untuk entitas diaktifkan
                if espToggles[critterName] then
                    -- Menampilkan nama dan jarak
                    local billboardGui = critter:FindFirstChild("ESP_GUI")
                    if not billboardGui then
                        billboardGui = Instance.new("BillboardGui", critter)
                        billboardGui.Name = "ESP_GUI"
                        billboardGui.Adornee = primaryPart
                        billboardGui.Size = UDim2.new(0, 70, 0, 50)
                        billboardGui.AlwaysOnTop = true

                        local textLabel = Instance.new("TextLabel", billboardGui)
                        textLabel.Size = UDim2.new(1, 0, 1, 0)
                        textLabel.BackgroundTransparency = 1
                        textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                        textLabel.TextScaled = true
                        textLabel.Text = critterName .. " | Distance: " .. math.floor(distance) .. " studs"
                    else
                        -- Perbarui teks jarak jika GUI sudah ada
                        local textLabel = billboardGui:FindFirstChildOfClass("TextLabel")
                        if textLabel then
                            textLabel.Text = critterName .. " | Distance: " .. math.floor(distance) .. " studs"
                        end
                    end
                else
                    -- Hapus ESP jika tidak lagi diperlukan
                    if critter:FindFirstChild("ESP_GUI") then
                        critter:FindFirstChild("ESP_GUI"):Destroy()
                    end
                end
            end
        end
    end
end

-- Fungsi untuk mengatur ESP
local function startESP()
    while next(espToggles) do
        updateESP()
        wait(5) -- Memperbarui ESP setiap detik
    end
    -- Hapus semua ESP ketika semua toggle dimatikan
    for _, critter in ipairs(workspace.Important.Critters:GetChildren()) do
        if critter:FindFirstChild("ESP_GUI") then
            critter:FindFirstChild("ESP_GUI"):Destroy()
        end
    end
end

-- Membuat toggle untuk setiap entitas ESP
for _, entity in ipairs(espEntities) do
    espToggles[entity] = false

    TabESP:CreateToggle({
        Name = "ESP " .. entity,
        SectionParent = ESPSection,
        CurrentValue = false,
        Callback = function(v)
            espToggles[entity] = v
            if next(espToggles) then
                startESP()
            end
        end,
    })
end



-- Pickup Tab
local TabPickup = Window:CreateTab("Pickup", nil) -- Create the Pickup tab
local SectionPickup = TabPickup:CreateSection("Pickup Item", false)

-- Slider untuk mengatur radius pickup
local SliderPickupRadius = TabPickup:CreateSlider({
    Name = "Pickup Radius",
    SectionParent = SectionPickup,
    Range = {1, 100},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = pickupRadius,
    Flag = "PickupRadiusSlider",
    Callback = function(Value)
        pickupRadius = Value
    end,
})

local pickupRadius = 50 -- Jarak maksimal untuk memungut item, dapat disesuaikan
local isPickingUp = {}

-- Fungsi untuk mendapatkan instance dari nil instances
local function getNil(name, class)
    for _, v in pairs(getnilinstances()) do
        if v.ClassName == class and v.Name == name then
            return v
        end
    end
end

-- Fungsi untuk memulai pickup item
local function startPickupItem()
    while true do
        -- Loop melalui semua toggle yang aktif
        for itemName, isActive in pairs(isPickingUp) do
            if isActive then
                -- Cari item yang sesuai dengan nama dari toggle yang aktif
                local foldersToCheck = {
                    workspace.Important.Items,
                    workspace.Important.Homeless
                }

                local itemFound = false

                -- Cek di folder-folder
                for _, folder in ipairs(foldersToCheck) do
                    for _, item in ipairs(folder:GetChildren()) do
                        if (item:IsA("Part") or item:IsA("UnionOperation")) and item.Name == itemName then
                            local playerPosition = game.Players.LocalPlayer.Character.PrimaryPart.Position
                            local itemPosition = item.Position
                            local distance = (playerPosition - itemPosition).Magnitude

                            if distance <= pickupRadius then
                                local args = {
                                    [1] = item
                                }
                                game:GetService("ReplicatedStorage").Events.Pickup:FireServer(unpack(args))
                                itemFound = true
                            end
                        end
                    end
                end

                -- Jika item tidak ditemukan di folder, coba menggunakan getNil untuk Part dan UnionOperation
                if not itemFound then
                    local nilInstancePart = getNil(itemName, "Part")
                    local nilInstanceUnion = getNil(itemName, "UnionOperation")

                    if nilInstancePart then
                        local args = {
                            [1] = nilInstancePart
                        }
                        game:GetService("ReplicatedStorage").Events.Pickup:FireServer(unpack(args))
                    end

                    if nilInstanceUnion then
                        local args = {
                            [1] = nilInstanceUnion
                        }
                        game:GetService("ReplicatedStorage").Events.Pickup:FireServer(unpack(args))
                    end
                end
            end
        end

        -- Tambahkan jeda untuk menghindari penggunaan sumber daya yang berlebihan
        wait(0.1)
    end
end


-- Fungsi untuk membuat toggle pickup item
local function createPickupToggle(itemName)
    TabPickup:CreateToggle({
        Name = "Pickup " .. itemName,
        SectionParent = SectionPickup,
        CurrentValue = false,
        Callback = function(v)
            isPickingUp[itemName] = v
            if v then
                startPickupItem(itemName)
            else
                isPickingUp[itemName] = false
            end
        end,
    })
end

-- Daftar item yang akan ditambahkan toggle-nya
local itemsToPickup = {
    "Essence", "Bloodfruit", "Heartfruit", "Gold", "Raw Gold", "Bar Gold", "Coal", 
    "Crystal Chunk", "Log", "Leaves", "Stick", "Stone", "Ice Cube", "Raw Adurite",
    "Adurite Bar", "Steel Bar", "Iron Bar", "Raw Iron", "Emerald", "Magnetite", 
    "Raw Magnetite", "Pink Diamond", "Spirit Key"
}

-- Membuat toggle untuk setiap item dalam daftar
for _, itemName in ipairs(itemsToPickup) do
    createPickupToggle(itemName)
end


-- Section untuk Farm Animal
local TabAnimal = Window:CreateTab("Animal", nil) -- Membuat Tab Animal
local SectionFarmAnimal = TabAnimal:CreateSection("Farm Animal", false)

-- Fungsi untuk menghasilkan dropdown Animal yang terurut dari workspace.Important.Critters
local function generateDropdownAnimals()
    local animalFolder = workspace.Important.Critters:GetChildren()
    local AnimalList = {}

    for _, animal in ipairs(animalFolder) do
        if animal:IsA("Model") then
            table.insert(AnimalList, animal.Name)
        end
    end

    -- Menghilangkan nama yang duplikat dalam dropdown
    AnimalList = removeDuplicates(AnimalList)

    -- Mengurutkan AnimalList secara alfabetis
    table.sort(AnimalList)

    return AnimalList
end

local AnimalList = generateDropdownAnimals()
local SelectedAnimal = nil

-- Dropdown untuk memilih Animal
local DropdownAnimals = TabAnimal:CreateDropdown({
    Name = "Animal",
    Options = AnimalList,
	SectionParent = SectionFarmAnimal,
    CurrentOption = "",
    Callback = function(option)
        SelectedAnimal = option
    end,
})

-- Variabel untuk menyimpan nilai hitRadius (bisa disesuaikan melalui slider)
local hitRadius = 20 -- Nilai default hitRadius
local isFlying = false -- Variabel untuk status terbang pemain
local currentBodyPosition -- Menyimpan BodyPosition saat terbang

-- Fungsi untuk menjaga pemain terbang di tempat (tetap melayang)
-- Fungsi untuk menjaga pemain terbang di tempat (tetap melayang)
local function startFlying(position)
    local player = game.Players.LocalPlayer
    local character = player.Character
    if character and character.PrimaryPart and not isFlying then
        -- Membuat BodyPosition untuk menjaga pemain tetap terbang
        currentBodyPosition = Instance.new("BodyPosition")
        currentBodyPosition.MaxForce = Vector3.new(0, math.huge, 0) -- Memberikan gaya hanya pada sumbu Y (vertikal)
        currentBodyPosition.Position = position -- Melayang di atas target
        currentBodyPosition.D = 10 -- Damping (untuk kestabilan melayang)
        currentBodyPosition.P = 10000 -- Power (untuk cepat mencapai posisi)
        currentBodyPosition.Parent = character.PrimaryPart

        isFlying = true -- Status terbang diaktifkan
    end
end

-- Fungsi untuk mengakhiri terbang dan menghapus BodyPosition (agar pemain turun)
local function stopFlying()
    if currentBodyPosition then
        currentBodyPosition:Destroy() -- Menghapus BodyPosition agar pemain turun
        currentBodyPosition = nil
        isFlying = false -- Status terbang dinonaktifkan
    end
end

-- Fungsi untuk teleport pemain ke atas target dan membuatnya tetap melayang di atas target
local function stayAboveTarget(target)
    local targetPart = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
    if targetPart then
        local player = game.Players.LocalPlayer
        local character = player.Character
        if character and character.PrimaryPart then
            -- Hitung posisi tepat di atas target (misalnya 20 studs di atas target)
            local abovePosition = targetPart.Position + Vector3.new(0, 20, 0) -- 20 studs di atas target
            
            -- Teleport pemain ke atas target
            character:SetPrimaryPartCFrame(CFrame.new(abovePosition))
            
            -- Aktifkan terbang di atas target
            startFlying(abovePosition)
        end
    end
end

-- Fungsi untuk memukul target yang berada di bawah pemain dalam radius yang disesuaikan
local function hitTargetsBelowPlayer()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if character and character.PrimaryPart then
        local playerPosition = character.PrimaryPart.Position

        -- Iterasi semua hewan di workspace
        for _, critter in ipairs(workspace.Important.Critters:GetChildren()) do
            if critter:IsA("Model") and critter.PrimaryPart then
                local critterPosition = critter.PrimaryPart.Position
                local distance = (playerPosition - critterPosition).Magnitude

                -- Memeriksa apakah hewan berada dalam radius hit dan di bawah pemain
                if distance <= hitRadius and critterPosition.Y < playerPosition.Y then
                    -- Menyerang hewan
                    local args = {
                        [1] = {
                            [1] = critter
                        }
                    }
                    game:GetService("ReplicatedStorage").Events.SwingTool:FireServer(unpack(args))
                end
            end
        end
    end
end

-- Fungsi untuk memulai farming hewan, teleport ke atas target, dan memukul target di bawah pemain
local function startFarmingAnimal()
    while isFarmingAnimal do
        -- Mencari semua Model dengan nama hewan yang dipilih
        local targets = {}
        for _, critter in ipairs(workspace.Important.Critters:GetChildren()) do
            if critter:IsA("Model") and critter.Name == SelectedAnimal then
                table.insert(targets, critter)
            end
        end

        -- Jika ada target, lanjutkan farming
        if #targets > 0 then
            for _, target in ipairs(targets) do
                if target and target.Parent then
                    -- Teleport dan tetap berada di atas target
                    stayAboveTarget(target)

                    -- Tetap di atas target dan terus memukul target di bawah sampai target hilang
                    while target and target.Parent and isFarmingAnimal do
                        hitTargetsBelowPlayer()
                        wait(0.001) -- Menambahkan jeda kecil antar pukulan
                    end
                end
            end
        else
            -- Jika tidak ada target yang tersisa, hentikan terbang dan turun
            stopFlying()
            wait(1)  -- Tambahkan jeda sebelum memeriksa kembali
        end
    end

    stopFlying() -- Pemain akan turun setelah farming dinonaktifkan
end

-- Toggle untuk memulai/menghentikan farming hewan
local ToggleFarmAnimal = TabAnimal:CreateToggle({
    Name = "Farm Animal",
    CurrentValue = false,
    SectionParent = SectionFarmAnimal,
    Callback = function(v)
        isFarmingAnimal = v
        if isFarmingAnimal then
            farmAnimalCoroutine = coroutine.create(startFarmingAnimal)
            coroutine.resume(farmAnimalCoroutine)
        else
            if farmAnimalCoroutine then
                coroutine.close(farmAnimalCoroutine)
            end
            stopFlying() -- Hentikan terbang dan pemain akan turun
        end
    end,
})

-- Slider untuk mengatur hitRadius
local SliderHitRadius = TabAnimal:CreateSlider({
    Name = "Hit Radius",
    SectionParent = SectionFarmAnimal,
    Range = {1, 100}, -- Batas minimal dan maksimal hitRadius
    Increment = 1, -- Inkrementasi nilai hitRadius
    Suffix = " studs", -- Satuan
    CurrentValue = hitRadius, -- Nilai awal hitRadius
    Flag = "HitRadiusSlider", -- ID Slider
    Callback = function(value)
        hitRadius = value -- Memperbarui hitRadius dengan nilai dari slider
    end,
})


---- Create the Dupe Tab
--local TabDupe = Window:CreateTab("Dupe", nil) -- Title, Image
--local SectionDupe = TabDupe:CreateSection("Inventory Dupe", false)
--
---- Function to generate inventory dropdown list
--local function generateInventoryDropdown()
--    local inventory = game:GetService("Players").LocalPlayer.PlayerGui.MainGui.RightPanel.Inventory.List:GetChildren()
--    local inventoryList = {}
--
--    for _, item in ipairs(inventory) do
--        if item:IsA("TextButton") or item:IsA("ImageButton") then
--            table.insert(inventoryList, item.Name)
--        end
--    end
--
--    return inventoryList
--end
--
--local InventoryList = generateInventoryDropdown()
--local SelectedItem = nil
--
---- Dropdown for selecting an item from the inventory
--local DropdownInventory = TabDupe:CreateDropdown({
--    Name = "Inventory Items",
--    SectionParent = SectionDupe,
--    Options = InventoryList,
--    CurrentOption = "",
--    Callback = function(option)
--        SelectedItem = option
--    end,
--})
--
---- Input for setting the quantity
--local InputQuantity = TabDupe:CreateInput({
--    Name = "Dupe Quantity",
--    SectionParent = SectionDupe,
--    PlaceholderText = "Enter Quantity",
--    Callback = function(value)
--        local quantity = tonumber(value)
--        if quantity and SelectedItem then
--            -- Find the selected item in the inventory
--            local inventory = game:GetService("Players").LocalPlayer.PlayerGui.MainGui.RightPanel.Inventory.List:GetChildren()
--            for _, item in ipairs(inventory) do
--                if item.Name == SelectedItem then
--                    -- Access QuantityText under QuantityImage and set the quantity permanently
--                    local quantityText = item:FindFirstChild("QuantityImage", true)
--                    if quantityText then
--                        local quantityLabel = quantityText:FindFirstChild("QuantityText")
--                        if quantityLabel then
--                            quantityLabel.Text = tostring(quantity)
--                            print("Quantity set to " .. quantity .. " for item: " .. SelectedItem)
--                        else
--                            print("QuantityText not found for item: " .. SelectedItem)
--                        end
--                    else
--                        print("QuantityImage not found for item: " .. SelectedItem)
--                    end
--                end
--            end
--        else
--            print("Invalid quantity or no item selected.")
--        end
--    end,
--})
--
---- Function to handle item drop and attempt to modify before the server processes it
--local function onItemDrop(item)
--    if item.Name == SelectedItem then
--        local quantityText = item:FindFirstChild("QuantityImage", true)
--        if quantityText then
--            local quantityLabel = quantityText:FindFirstChild("QuantityText")
--            if quantityLabel then
--                local currentQuantity = tonumber(quantityLabel.Text)
--                if currentQuantity and currentQuantity > 1 then
--                    -- Decrease the quantity by one
--                    currentQuantity = currentQuantity - 1
--                    quantityLabel.Text = tostring(currentQuantity)
--                    print("Quantity decreased to " .. currentQuantity .. " for item: " .. item.Name)
--
--                    -- Attempt to simulate the drop event
--                    local args = {
--                        [1] = item.Name
--                    }
--
--                    -- Fire the server event with the updated quantity
--                    game:GetService("ReplicatedStorage").Events.DropBagItem:FireServer(unpack(args))
--
--                    -- Delay or prevent the server from immediately overriding
--                    wait(0.1) -- Small delay to try and prevent immediate override
--                elseif currentQuantity == 1 then
--                    -- Remove the item if the quantity reaches 1 and it's dropped
--                    item:Destroy()
--                    print("Item " .. item.Name .. " removed from inventory.")
--                end
--            end
--        end
--    end
--end
--
---- Connect the drop event to the correct UI elements (TextButton or ImageButton)
--local function connectDropEvent()
--    local inventory = game:GetService("Players").LocalPlayer.PlayerGui.MainGui.RightPanel.Inventory.List:GetChildren()
--    for _, item in ipairs(inventory) do
--        if item:IsA("TextButton") or item:IsA("ImageButton") then
--            item.MouseButton1Click:Connect(function()
--                onItemDrop(item)
--            end)
--        end
--    end
--end
--
---- Call this function to ensure all items are tracked
--connectDropEvent()

