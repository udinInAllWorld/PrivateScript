-- Inisialisasi Orion Library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Variabel Key System
local KeyValid = false
local KeyExpireTime = nil
local correctKey = "survival" -- Key yang valid
local saveFile = "KeyVoid_SurvivalOdyssey.txt"

-- Fungsi untuk memeriksa apakah key masih valid
local function checkKeyValid()
    if KeyExpireTime then
        if os.time() > KeyExpireTime then
            KeyValid = false
            OrionLib:MakeNotification({
                Name = "Key Expired",
                Content = "Your key has expired. Please enter a new key.",
                Time = 5
            })
        else
            KeyValid = true
        end
    end
    return KeyValid
end

-- Fungsi untuk menyimpan key dan waktu kadaluarsa ke file
local function saveKeyData()
    if KeyValid then
        local data = {
            key = correctKey,
            expireTime = KeyExpireTime
        }
        writefile(saveFile, game:GetService("HttpService"):JSONEncode(data))
    end
end

-- Fungsi untuk memuat data key dari file
local function loadKeyData()
    if isfile(saveFile) then
        local data = game:GetService("HttpService"):JSONDecode(readfile(saveFile))
        if data.key == correctKey and os.time() <= data.expireTime then
            KeyValid = true
            KeyExpireTime = data.expireTime
            return true
        end
    end
    return false
end

-- Memuat data key saat pertama kali script dijalankan
local keyLoaded = loadKeyData()

-- Membuat Window UI
local Window = OrionLib:MakeWindow({
    Name = "Survival Odyssey",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "SurvivalOdysseyConfig"
})

-- Membuat Tab Key
local KeyTab = Window:MakeTab({
    Name = "Key",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Fungsi untuk membuat tab lainnya hanya jika key valid
local function createTabs()
    createGodTab()
    createFarmTab()
    createFruitFarmTab()
    createPickupTab()
    createAutoFeaturesTab()
end

-- Membuat Section Key System
local KeySystemSection = KeyTab:AddSection({
    Name = "Key System"
})

KeySystemSection:AddButton({
    Name = "Get Key",
    Callback = function()
        setclipboard('https://pastebin.com/raw/survival') -- Link untuk mendapatkan key
        OrionLib:MakeNotification({
            Name = "Link Copied",
            Content = "The link has been copied to clipboard.",
            Time = 5
        })
    end
})

local EnteredKey = nil
KeySystemSection:AddTextbox({
    Name = "Enter Key",
    Default = "",
    TextDisappear = true,
    Callback = function(Value)
        EnteredKey = Value
    end
})

KeySystemSection:AddButton({
    Name = "Submit",
    Callback = function()
        if EnteredKey == correctKey then
            KeyValid = true
            KeyExpireTime = os.time() + (60 * 60) -- Key berlaku selama 60 menit
            saveKeyData()
            OrionLib:MakeNotification({
                Name = "Key Accepted",
                Content = "Your key is valid for the next 60 minutes.",
                Time = 5
            })
	createTabs() -- Membuat semua tab setelah key valid
        else
            OrionLib:MakeNotification({
                Name = "Key Invalid",
                Content = "The key you entered is invalid. Please try again.",
                Time = 5
            })
        end
    end
})

-- Fungsi untuk membuat tab God setelah key valid
function createGodTab()
    local GodTab = Window:MakeTab({
        Name = "God",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    local GodOptions = {}
    local SelectedGod = nil
    local TpGodsDropdown

    local function refreshGodOptions()
        GodOptions = {}
        local resourcesFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Resources")
        
        if resourcesFolder then
            if resourcesFolder:FindFirstChild("Gods") then
                for _, god in pairs(resourcesFolder.Gods:GetChildren()) do
                    if god:IsA("Model") then
                        table.insert(GodOptions, god.Name)
                    end
                end
            end

            if resourcesFolder:FindFirstChild("God") then
                for _, god in pairs(resourcesFolder.God:GetChildren()) do
                    if god:IsA("Model") then
                        table.insert(GodOptions, god.Name)
                    end
                end
            end
        end

        table.sort(GodOptions)
        
        if TpGodsDropdown then
            TpGodsDropdown:Refresh(GodOptions, true)
        end
    end

    TpGodsDropdown = GodTab:AddDropdown({
        Name = "Tp Gods",
        Default = "Select God",
        Options = GodOptions,
        Callback = function(Value)
            SelectedGod = Value
        end
    })

    refreshGodOptions()

    spawn(function()
        while true do
            wait(5)
            refreshGodOptions()
        end
    end)

    local AutoTeleportGodEnabled = false
    local stopTeleportGod = false

    GodTab:AddToggle({
        Name = "Teleport To Gods",
        Default = false,
        Callback = function(Value)
            AutoTeleportGodEnabled = Value
            stopTeleportGod = not Value
            if AutoTeleportGodEnabled and SelectedGod then
                teleportToGods()
            end
        end
    })

    function teleportToGods()
        local godModel = workspace.Map.Resources:FindFirstChild("Gods") and workspace.Map.Resources.Gods:FindFirstChild(SelectedGod)
                        or workspace.Map.Resources:FindFirstChild("God") and workspace.Map.Resources.God:FindFirstChild(SelectedGod)
                        
        if godModel then
            local targetPosition
            if godModel.PrimaryPart then
                targetPosition = godModel.PrimaryPart.Position + Vector3.new(0, 10, 0)
            else
                targetPosition = godModel:GetModelCFrame().Position + Vector3.new(0, 10, 0)
            end
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
        end
    end

    local AutoPickupEssenceEnabled = false
    local pickupEssenceRadius = 200

    GodTab:AddToggle({
        Name = "Pickup Essence",
        Default = false,
        Callback = function(Value)
            AutoPickupEssenceEnabled = Value
            if AutoPickupEssenceEnabled then
                spawn(pickupEssences)
            end
        end
    })

    function pickupEssences()
        while AutoPickupEssenceEnabled do
            local playerPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
            local nearbyItems = workspace.Important.Items:GetChildren()

            for _, item in pairs(nearbyItems) do
                if not AutoPickupEssenceEnabled then break end
                local itemPosition = item.Position
                local distance = (playerPosition - itemPosition).Magnitude
                
                if (item.Name == "Essence" or item.Name == "Big Essence") and distance <= pickupEssenceRadius then
                    spawn(function()
                        pcall(function()
                            game:GetService("ReplicatedStorage").Events.Pickup:InvokeServer(item)
                        end)
                    end)
                end
            end
            wait(0.01)
        end
    end

    local TeleportWorldSection = GodTab:AddSection({
        Name = "Teleport World"
    })

    TeleportWorldSection:AddButton({
        Name = "Tp Normal",
        Callback = function()
            game:GetService("TeleportService"):Teleport(18629053284, game.Players.LocalPlayer)
        end
    })

    TeleportWorldSection:AddButton({
        Name = "Tp to Void",
        Callback = function()
            game:GetService("TeleportService"):Teleport(18629058177, game.Players.LocalPlayer)
        end
    })

    TeleportWorldSection:AddButton({
        Name = "Tp To UnderWorld",
        Callback = function()
            game:GetService("TeleportService"):Teleport(92039548740735, game.Players.LocalPlayer)
        end
    })
end

-- Fungsi untuk membuat Tab Farm setelah key valid
function createFarmTab()
    local FarmTab = Window:MakeTab({
        Name = "Farm",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    -- Mengambil daftar folder di dalam workspace.Map.Resources, tanpa Misc dan God
    local ResourceFolders = {}
    local resourcesFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Resources")
    local TpResourceDropdown
    local SelectedResource = nil

-- Fungsi untuk memperbarui opsi Resource secara dinamis berdasarkan kehadiran objek
local function refreshResourceOptions()
    ResourceFolders = {}
    if resourcesFolder then
        for _, folder in pairs(resourcesFolder:GetChildren()) do
            if folder:IsA("Folder") and folder.Name ~= "Misc" and folder.Name ~= "God" and folder.Name ~= "Gods" then
                -- Periksa apakah folder memiliki setidaknya satu objek aktif
                local hasActiveObject = false
                for _, object in pairs(folder:GetChildren()) do
                    if object:IsA("Model") or object:IsA("Part") then
                        hasActiveObject = true
                        break
                    end
                end
                
                -- Tambahkan ke dropdown jika ada objek aktif dalam folder
                if hasActiveObject then
                    table.insert(ResourceFolders, folder.Name)
                end
            end
        end
    end

    -- Tambahkan opsi King Ant jika folder Misc ditemukan dan memiliki objek King Spawner
    if resourcesFolder and resourcesFolder:FindFirstChild("Misc") and resourcesFolder.Misc:FindFirstChild("King Spawner") then
        table.insert(ResourceFolders, "King Ant")
    end

    table.sort(ResourceFolders)  -- Mengurutkan daftar ResourceFolders secara alfabetis

    if TpResourceDropdown then
        TpResourceDropdown:Refresh(ResourceFolders, true)  -- Refresh dropdown dengan daftar yang diperbarui
    end
end

    -- Dropdown untuk Tp To di Tab Farm dengan fungsi Refresh
    TpResourceDropdown = FarmTab:AddDropdown({
        Name = "Tp To",
        Default = "Select Resource",
        Options = ResourceFolders,
        Callback = function(Value)
            SelectedResource = Value
        end
    })

    -- Refresh daftar pertama kali saat Tab Farm dibuat
    refreshResourceOptions()

    -- Refresh ResourceFolders setiap beberapa detik
    spawn(function()
        while true do
            wait(5)
            refreshResourceOptions()
        end
    end)

    -- Membuat Toggle Teleport Player
    local AutoTeleportEnabled = false
    local stopTeleport = false

    FarmTab:AddToggle({
        Name = "Teleport Player",
        Default = false,
        Callback = function(Value)
            AutoTeleportEnabled = Value
            stopTeleport = not Value
            if AutoTeleportEnabled and SelectedResource then
                teleportToResources()
            end
        end
    })

    -- Fungsi untuk teleport ke setiap Reference dalam folder yang dipilih atau ke King Ant jika dipilih
    function teleportToResources()
        if SelectedResource == "King Ant" then
            -- Teleport ke King Spawner jika King Ant dipilih
            local kingSpawner = workspace.Map.Resources.Misc:FindFirstChild("King Spawner")
            if kingSpawner then
                local targetPosition
                if kingSpawner.PrimaryPart then
                    targetPosition = kingSpawner.PrimaryPart.Position + Vector3.new(0, 5, 0)
                else
                    targetPosition = kingSpawner:GetModelCFrame().Position + Vector3.new(0, 5, 0)
                end
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
            end
        else
            -- Teleport ke folder yang dipilih jika bukan King Ant
            local resourceFolder = workspace.Map.Resources:FindFirstChild(SelectedResource)
            if resourceFolder then
                for _, resource in pairs(resourceFolder:GetChildren()) do
                    if stopTeleport then break end
                    if resource:FindFirstChild("Reference") then
                        local targetPosition = resource.Reference.Position + Vector3.new(0, 5, 0)
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
                        wait(5)
                    end
                end
            end
        end
    end

    -- Mengambil daftar Critters di dalam workspace.Important.Critters dan mengurutkannya
    local CritterOptions = {}
    local CritterDropdown
    local SelectedCritter = nil

    -- Fungsi untuk memperbarui opsi Critter secara dinamis
    local function refreshCritterOptions()
        CritterOptions = {}
        for _, critter in pairs(workspace.Important.Critters:GetChildren()) do
            if critter:IsA("Model") then
                if not table.find(CritterOptions, critter.Name) then
                    table.insert(CritterOptions, critter.Name)
                end
            end
        end

        table.sort(CritterOptions)

        if CritterDropdown then
            CritterDropdown:Refresh(CritterOptions, true)
        end
    end

    -- Dropdown untuk Tp Critters di Tab Farm dengan fungsi Refresh
    CritterDropdown = FarmTab:AddDropdown({
        Name = "Tp Critters",
        Default = "Select Critter",
        Options = CritterOptions,
        Callback = function(Value)
            SelectedCritter = Value
        end
    })

    -- Refresh daftar pertama kali saat Tab Farm dibuat
    refreshCritterOptions()

    -- Refresh CritterOptions setiap beberapa detik
    spawn(function()
        while true do
            wait(5)
            refreshCritterOptions()
        end
    end)

    -- Membuat Toggle Teleport To Critters
    local AutoTeleportCritterEnabled = false
    local stopTeleportCritter = false

    FarmTab:AddToggle({
        Name = "Teleport To Critters",
        Default = false,
        Callback = function(Value)
            AutoTeleportCritterEnabled = Value
            stopTeleportCritter = not Value
            if AutoTeleportCritterEnabled and SelectedCritter then
                teleportToCritters()
            end
        end
    })

    -- Fungsi untuk teleport ke semua objek dengan nama yang dipilih dalam Critters
    function teleportToCritters()
        while AutoTeleportCritterEnabled do
            for _, critter in pairs(workspace.Important.Critters:GetChildren()) do
                if not AutoTeleportCritterEnabled then break end
                if critter.Name == SelectedCritter and critter:FindFirstChild("HumanoidRootPart") then
                    local targetPosition = critter.HumanoidRootPart.Position + Vector3.new(5, 0, 0)
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
                    wait(5)
                end
            end
            wait(1) -- Tunggu sebentar sebelum mengulangi loop
        end
    end

    -- Menambahkan Toggle Pickup Everything
    local AutoPickupEnabled = false
    local pickupRadius = 200 -- Radius pengambilan item dalam satuan unit
    FarmTab:AddToggle({
        Name = "Pickup Everything",
        Default = false,
        Callback = function(Value)
            AutoPickupEnabled = Value
            if AutoPickupEnabled then
                spawn(pickupItems) -- Menjalankan fungsi pickupItems dalam thread terpisah
            end
        end
    })

    -- Fungsi untuk pickup item di sekitar pemain dengan jarak tertentu
    function pickupItems()
        while AutoPickupEnabled do
            local playerPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
            local nearbyItems = workspace.Important.Items:GetChildren()
            
            for _, item in pairs(nearbyItems) do
                if not AutoPickupEnabled then break end

                local itemPosition = item.Position
                local distance = (playerPosition - itemPosition).Magnitude
                
                if distance <= pickupRadius then
                    spawn(function()
                        pcall(function()
                            game:GetService("ReplicatedStorage").Events.Pickup:InvokeServer(item)
                        end)
                    end)
                end
            end
            wait(0.01)
        end
    end

    -- Menambahkan Toggle Pickup Special Items (Undead Stick, Serpent Tail, Zombie Flesh, Skeleton Bone) di Tab Farm
    local AutoPickupSpecialItemsEnabled = false
    local pickupSpecialItemRadius = 200

    FarmTab:AddToggle({
        Name = "Pickup Special Items",
        Default = false,
        Callback = function(Value)
            AutoPickupSpecialItemsEnabled = Value
            if AutoPickupSpecialItemsEnabled then
                spawn(pickupSpecialItems)
            end
        end
    })

    -- Fungsi untuk mengambil hanya item spesial di sekitar pemain dengan jarak tertentu
    function pickupSpecialItems()
        while AutoPickupSpecialItemsEnabled do
            local playerPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
            local nearbyItems = workspace.Important.Items:GetChildren()
            
            for _, item in pairs(nearbyItems) do
                if not AutoPickupSpecialItemsEnabled then break end
                
                local itemPosition = item.Position
                local distance = (playerPosition - itemPosition).Magnitude
                
                if (item.Name == "Undead Stick" or item.Name == "Serpent Tail" or item.Name == "Zombie Flesh" or item.Name == "Skeleton Bone") and distance <= pickupSpecialItemRadius then
                    spawn(function()
                        pcall(function()
                            game:GetService("ReplicatedStorage").Events.Pickup:InvokeServer(item)
                        end)
                    end)
                end
            end
            wait(0.01)
        end
    end

    -- Menambahkan Toggle Coin Press
    local AutoCoinPressEnabled = false

    FarmTab:AddToggle({
        Name = "Coin Press",
        Default = false,
        Callback = function(Value)
            AutoCoinPressEnabled = Value
            if AutoCoinPressEnabled then
                spawn(runCoinPress)
            end
        end
    })

    -- Fungsi untuk menjalankan Coin Press setiap 0.0001 detik
    function runCoinPress()
        while AutoCoinPressEnabled do
            local args = {
                [1] = workspace.Important.Deployables:FindFirstChild("Coin Press"),
                [2] = "Gold Bar"
            }
            game:GetService("ReplicatedStorage").Events.InteractStructure:FireServer(unpack(args))
            wait(0.0001) -- Interval 0.0001 detik
        end
    end
end

-- Fungsi untuk membuat Tab Fruit Farm setelah key valid
function createFruitFarmTab()
    local FruitFarmTab = Window:MakeTab({
        Name = "Fruit Farm",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    -- Section untuk Place Plant Box
    local PlantSection = FruitFarmTab:AddSection({
        Name = "Place Plant Box"
    })

    -- Slider untuk menentukan jumlah Plant Box
    local PlantBoxAmount = 1
    PlantSection:AddSlider({
        Name = "Amount of Plant Box",
        Min = 1,
        Max = 100,
        Default = 1,
        Color = Color3.fromRGB(255, 255, 255),
        Increment = 1,
        ValueName = "Boxes",
        Callback = function(Value)
            PlantBoxAmount = Value
        end
    })

    -- Button untuk Place Plant Box
    PlantSection:AddButton({
        Name = "Place Plant Box",
        Callback = function()
            placePlantBoxes("Plant Box")
        end
    })

    -- Button untuk Place Golden Plant Box
    PlantSection:AddButton({
        Name = "Place Golden Plant Box",
        Callback = function()
            placePlantBoxes("Golden Plant Box")
        end
    })

    -- Fungsi untuk menempatkan Plant Box berjejer dengan jarak kecil di sumbu Z
    function placePlantBoxes(boxType)
        local player = game.Players.LocalPlayer
        if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "Player or HumanoidRootPart not found.",
                Time = 5
            })
            return
        end

        -- Posisi awal di bawah pemain
        local playerCFrame = player.Character.HumanoidRootPart.CFrame
        local basePosition = playerCFrame.Position + Vector3.new(0, -3, 0) -- Di bawah pemain pada sumbu Y

        -- Offset kecil pada sumbu Z untuk memberikan jarak kecil antar Plant Box ke belakang
        local offset = Vector3.new(0, 0, 1) -- Jarak kecil ke belakang pada sumbu Z

        for i = 0, PlantBoxAmount - 1 do
            local positionOffset = offset * i
            local newCFrame = CFrame.new(basePosition + positionOffset)
            
            local args = {
                [1] = boxType,
                [2] = newCFrame,
                [3] = 0
            }

            -- Cek apakah event ada sebelum dipanggil
            if game:GetService("ReplicatedStorage").Events:FindFirstChild("PlaceStructure") then
                game:GetService("ReplicatedStorage").Events.PlaceStructure:FireServer(unpack(args))
            else
                OrionLib:MakeNotification({
                    Name = "Error",
                    Content = "Event PlaceStructure not found.",
                    Time = 5
                })
                break
            end

            wait(0.1) -- Penundaan untuk menghindari masalah performa
        end
    end

    -- Section untuk Plant/Harvest Fruit
    local FruitSection = FruitFarmTab:AddSection({
        Name = "Plant/Harvest Fruit"
    })

    -- Dropdown untuk memilih jenis buah
    local selectedFruit = "Bloodfruit"  -- Default selection
    FruitSection:AddDropdown({
        Name = "Select Fruit",
        Default = "Bloodfruit",
        Options = {"Bloodfruit", "Heartfruit", "Jelly", "Sunfruit", "Bluefruit", "Cloudberry", "Pumpkin", "Blight Fruit"},
        Callback = function(Value)
            selectedFruit = Value
        end
    })

    -- Fungsi untuk menanam buah hanya di Plant Box di sekitar pemain
    local function plantFruit()
        local player = game.Players.LocalPlayer
        if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "Player or HumanoidRootPart not found.",
                Time = 5
            })
            return
        end

        local playerPosition = player.Character.HumanoidRootPart.Position
        local maxDistance = 10  -- Batas jarak maksimum untuk menanam di Plant Box terdekat

        for _, plantBox in pairs(workspace.Important.Deployables:GetChildren()) do
            if plantBox.Name == "Plant Box" or plantBox.Name == "Golden Plant Box" then
                local plantBoxPosition = plantBox:GetModelCFrame().Position
                local distance = (plantBoxPosition - playerPosition).Magnitude
                if distance <= maxDistance then
                    local args = {
                        [1] = plantBox,
                        [2] = selectedFruit
                    }
                    game:GetService("ReplicatedStorage").Events.InteractStructure:FireServer(unpack(args))
                end
            end
        end
    end

    -- Toggle untuk menanam buah secara berulang selama toggle aktif
    local plantFruitToggle = false
    FruitSection:AddToggle({
        Name = "Plant Fruit",
        Default = false,
        Callback = function(Value)
            plantFruitToggle = Value
            if plantFruitToggle then
                spawn(function()  -- Menjalankan loop di thread terpisah
                    while plantFruitToggle do
                        plantFruit()  -- Jalankan fungsi tanam buah hanya pada Plant Box terdekat
                        wait(1)  -- Jeda 1 detik sebelum memeriksa kembali
                    end
                end)
            end
        end
    })

    -- Fungsi untuk memanen buah dari setiap model tanaman yang ditemukan di dalam Plant Box secara paralel
    local function harvestFruit()
        for _, plantBox in pairs(workspace.Important.Deployables:GetChildren()) do
            if plantBox.Name == "Plant Box" or plantBox.Name == "Golden Plant Box" then
                -- Menjalankan panen untuk setiap model di dalam Plant Box secara paralel
                for _, crop in pairs(plantBox:GetChildren()) do
                    if crop:IsA("Model") then
                        spawn(function()  -- Memanen setiap tanaman secara paralel
                            local args = { [1] = crop }
                            game:GetService("ReplicatedStorage").Events.Pickup:InvokeServer(unpack(args))
                        end)
                    end
                end
            end
        end
    end

    -- Toggle untuk memanen buah tanpa delay, menggunakan parallel processing untuk menghindari lag
    local harvestFruitToggle = false
    local harvestingInProgress = false  -- Flag untuk mencegah pemanggilan berulang

    FruitSection:AddToggle({
        Name = "Harvest Fruit",
        Default = false,
        Callback = function(Value)
            harvestFruitToggle = Value
            if harvestFruitToggle and not harvestingInProgress then
                harvestingInProgress = true
                spawn(function()
                    while harvestFruitToggle do
                        harvestFruit()  -- Jalankan fungsi panen buah dari semua Plant Box secara paralel
                        wait(1)  -- Delay kecil untuk mencegah lag
                    end
                    harvestingInProgress = false
                end)
            end
        end
    })
end

-- Fungsi untuk membuat tab Pickup
function createPickupTab()
    local PickupTab = Window:MakeTab({
        Name = "Pickup",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    -- Definisikan item pickup dan atur radius pickup
    local pickupRadius = 200
    local pickupFunctions = {}
    
    -- Tabel pickup dengan pengelompokan dan urutan alfabetis
    local pickupToggles = {
        Adurite = {"Big Raw Adurite", "Raw Adurite"},
	AduriteBar = {"Adurite Bar", "Big Adurite Bar"},
        Bloodfruit = {"Bloodfruit"},
        Coal = {"Coal", "Big Coal"},
        Coin = {"Coin"},
        CrystalChunk = {"Crystal Chunk"},
        Emerald = {"Emerald", "Big Emerald"},
        Essence = {"Essence", "Big Essence"},
        Gold = {"Raw Gold", "Big Raw Gold"},
	GoldBar = {"Gold Bar", "Big Gold Bar"},
        Heartfruit = {"Heartfruit"},
        Hellstone = {"Big Raw Hellstone", "Raw Hellstone"},
	HellstoneBar = {"Big Hellstone Bar", "Hellstone Bar"},
	Hide = {"Hide", "Fire Hide"},
        IceCube = {"Ice Cube"},
        Iron = {"Big Raw Iron", "Raw Iron", "Big Iron Bar", "Iron Bar"},
        KingHeart = {"King Heart"},
        Leaves = {"Leaves", "Big Leaves"},
        Log = {"Log"},
        Magnetite = {"Raw Magnetite", "Magnetite"},
        Meat = {"Cooked Meat", "Raw Meat","Raw Morsel","Cooked Morsel"},
        Phantomite = {"Big Raw Phantomite", "Raw Phantomite"},
	PhantomiteBar = {"Big Phantomite Bar", "Phantomite Bar"},
        PinkDiamond = {"Pink Diamond"},
        QueenHeart = {"Queen Heart"},
        SerpentTail = {"Serpent Tail"},
        SkeletonBone = {"Skeleton Bone"},
        Soulite = {"Big Raw Soulite", "Raw Soulite"},
	SouliteBar = {"Big Soulite Bar", "Soulite Bar"},
        SpiritKey = {"Spirit Key"},
        Steel = {"Steel Mix", "Steel Bar", "Big Steel Mix"},
        Stick = {"Stick", "Big Stick"},
        Stone = {"Big Stone", "Stone"},
        Undead = {"Undead Stick", "Undead Meat", "Undead Heart"},
	UnderworldMeat = {"Raw Underworld Meat", "Cooked Underworld Meat"},
	Void = {"Void Shard"},
        ZombieFlesh = {"Zombie Flesh"}
    }

    -- Sortir nama toggle secara alfabetis
    local sortedKeys = {}
    for key in pairs(pickupToggles) do
        table.insert(sortedKeys, key)
    end
    table.sort(sortedKeys)

    -- Fungsi untuk memulai pickup berdasarkan nama item
    local function pickupItems(itemNames)
        while pickupFunctions[itemNames] do
            local playerPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
            local nearbyItems = workspace.Important.Items:GetChildren()

            for _, item in pairs(nearbyItems) do
                if not pickupFunctions[itemNames] then break end
                if table.find(itemNames, item.Name) then
                    local itemPosition = item.Position
                    local distance = (playerPosition - itemPosition).Magnitude
                    
                    if distance <= pickupRadius then
                        spawn(function()
                            pcall(function()
                                game:GetService("ReplicatedStorage").Events.Pickup:InvokeServer(item)
                            end)
                        end)
                    end
                end
            end
            wait(0.1)
        end
    end

    -- Buat toggle pickup untuk setiap jenis item di pickupToggles, diurutkan secara alfabetis
    for _, name in ipairs(sortedKeys) do
        local items = pickupToggles[name]
        PickupTab:AddToggle({
            Name = "Pickup " .. name,
            Default = false,
            Callback = function(Value)
                pickupFunctions[items] = Value
                if Value then
                    spawn(function()
                        pickupItems(items)
                    end)
                end
            end
        })
    end
end

-- Fungsi untuk membuat tab Auto Features
function createAutoFeaturesTab()
    -- Membuat tab Auto Features
    local AutoFeaturesTab = Window:MakeTab({
        Name = "Auto Features",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    -- Debug jika tab gagal dibuat
    if not AutoFeaturesTab then
        error("Failed to create Auto Features tab. Ensure the Window is initialized.")
        return
    end

    -- Variabel untuk status Auto Features
    local autoHealthEnabled = false
    local autoFoodEnabled = false
    local autoVoodooEnabled = false
    local autoGodsEnabled = false
    local autoRebirthEnabled = false

    -- Fungsi Auto Health
    local function runAutoHealth()
        while autoHealthEnabled do
            local healthText = game.Players.LocalPlayer.PlayerGui.MainGui.Panels.Stats.List.Health.NumberLabel.Text
            local currentHealth = tonumber(healthText)
            if currentHealth and currentHealth <= 80 then
                -- Gunakan item kesehatan di bag slot 1
                local args = { [1] = 1 }
                game:GetService("ReplicatedStorage").Events.UseBagItem:FireServer(unpack(args))
            end
            wait(0.1)
        end
    end

    -- Fungsi Auto Food
    local function runAutoFood()
        while autoFoodEnabled do
            local foodText = game.Players.LocalPlayer.PlayerGui.MainGui.Panels.Stats.List.Food.NumberLabel.Text
            local currentFood = tonumber(foodText)
            if currentFood and currentFood <= 90 then
                -- Gunakan item makanan di bag slot 2
                local args = { [1] = 2 }
                game:GetService("ReplicatedStorage").Events.UseBagItem:FireServer(unpack(args))
            end
            wait(0.1)
        end
    end

    -- Fungsi Auto Voodoo
    local function runAutoVoodoo()
        while autoVoodooEnabled do
            local healthText = game.Players.LocalPlayer.PlayerGui.MainGui.Panels.Stats.List.Health.NumberLabel.Text
            local voodooText = game.Players.LocalPlayer.PlayerGui.MainGui.Panels.Stats.List.Voodoo.NumberLabel.Text
            local currentHealth = tonumber(healthText)
            local currentVoodoo = tonumber(voodooText)

            if currentHealth and currentVoodoo and currentHealth <= 50 and currentVoodoo == 100 then
                -- Gunakan Voodoo Spell
                local args = {
                    [1] = Vector3.new(628.7835083007812, -146.5078887939453, 44.465423583984375)
                }
                game:GetService("ReplicatedStorage").Events.VoodooSpell:FireServer(unpack(args))
            end
            wait(0.1)
        end
    end

    -- Fungsi Auto Gods
    local function runAutoGods()
        local godsFolder = workspace:FindFirstChild("Map") and workspace.Map.Resources:FindFirstChild("Gods")

        if not godsFolder then
            OrionLib:MakeNotification({
                Name = "Auto Gods",
                Content = "No Gods folder found in the workspace.",
                Time = 3
            })
            return
        end

        -- Loop utama Auto Gods
        while autoGodsEnabled do
            local godsModels = godsFolder:GetChildren()

            -- Jika tidak ada model, tunggu hingga ada
            if #godsModels == 0 then
                OrionLib:MakeNotification({
                    Name = "Auto Gods",
                    Content = "No gods available. Waiting for respawn...",
                    Time = 3
                })
                repeat
                    wait(2)
                    godsModels = godsFolder:GetChildren()
                until #godsModels > 0 or not autoGodsEnabled
            end

            -- Iterasi melalui semua model Gods
            for _, godModel in ipairs(godsModels) do
                if not autoGodsEnabled then break end

                -- Lewati model "Frozen Giant"
                if godModel.Name == "Frozen Giant" then
                    continue
                end

                if godModel:IsA("Model") then
                    -- Tentukan target posisi
                    local targetPosition
                    if godModel:FindFirstChild("PrimaryPart") then
                        targetPosition = godModel.PrimaryPart.Position + Vector3.new(0, 10, 0)
                    elseif godModel:GetPivot() then
                        targetPosition = godModel:GetPivot().Position + Vector3.new(0, 10, 0)
                    else
                        -- Hitung rata-rata posisi jika PrimaryPart dan Pivot tidak ada
                        local parts = godModel:GetDescendants()
                        local totalPosition = Vector3.new(0, 0, 0)
                        local count = 0

                        for _, part in ipairs(parts) do
                            if part:IsA("BasePart") then
                                totalPosition = totalPosition + part.Position
                                count = count + 1
                            end
                        end

                        if count > 0 then
                            targetPosition = (totalPosition / count) + Vector3.new(0, 10, 0)
                        else
                            continue
                        end
                    end

                    -- Teleport pemain ke posisi target
                    local player = game.Players.LocalPlayer
                    local character = player.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)

                        OrionLib:MakeNotification({
                            Name = "Auto Gods",
                            Content = "Teleported to " .. godModel.Name .. ". Waiting for removal.",
                            Time = 5
                        })

                        -- Tunggu hingga model dihapus atau toggle dimatikan
                        local startTime = os.time()
                        while godModel.Parent == godsFolder and autoGodsEnabled do
                            wait(1)
                        end

                        -- Tunggu tambahan 3 detik sebelum berpindah
                        wait(3)
                    end
                end
            end

            wait(1) -- Jeda antar iterasi loop utama
        end

        OrionLib:MakeNotification({
            Name = "Auto Gods",
            Content = "Auto Gods stopped.",
            Time = 3
        })
    end

-- Fungsi Auto Rebirth
local function runAutoRebirth()
    while autoRebirthEnabled do
        -- Coba mendapatkan referensi ke TextLabel
        local essenceLabel = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("MainGui")
            and game.Players.LocalPlayer.PlayerGui.MainGui.Panels.Topbar:FindFirstChild("EssenceBar")
            and game.Players.LocalPlayer.PlayerGui.MainGui.Panels.Topbar.EssenceBar:FindFirstChild("TextLabel")

        if essenceLabel then
            -- Ambil nilai teks dan hapus kata "Level" untuk mendapatkan angka
            local textContent = essenceLabel.Text
            local currentLevel = tonumber(textContent:match("%d+")) -- Menemukan angka dalam teks

            -- Jalankan fungsi rebirth jika level mencapai 100 atau lebih
            if currentLevel and currentLevel >= 100 then
                game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Rebirth"):FireServer()

                -- Notifikasi
                OrionLib:MakeNotification({
                    Name = "Auto Rebirth",
                    Content = "Rebirth executed at Level " .. currentLevel .. ".",
                    Time = 5
                })

                -- Tunggu beberapa detik sebelum memeriksa kembali untuk menghindari spam
                wait(5)
            end
        else
            -- Notifikasi jika TextLabel tidak ditemukan
            OrionLib:MakeNotification({
                Name = "Auto Rebirth",
                Content = "EssenceBar TextLabel not found. Check your UI structure.",
                Time = 3
            })
            break
        end

        wait(1) -- Jeda kecil sebelum memeriksa ulang level
    end

    OrionLib:MakeNotification({
        Name = "Auto Rebirth",
        Content = "Auto Rebirth stopped.",
        Time = 3
    })
end

    -- Tambahkan Toggle untuk Auto Health
    AutoFeaturesTab:AddToggle({
        Name = "Auto Health",
        Default = false,
        Callback = function(state)
            autoHealthEnabled = state
            if state then
                OrionLib:MakeNotification({
                    Name = "Auto Health",
                    Content = "Place your health item in bag slot 1.",
                    Time = 3
                })
                spawn(runAutoHealth)
            end
        end
    })

    -- Tambahkan Toggle untuk Auto Food
    AutoFeaturesTab:AddToggle({
        Name = "Auto Food",
        Default = false,
        Callback = function(state)
            autoFoodEnabled = state
            if state then
                OrionLib:MakeNotification({
                    Name = "Auto Food",
                    Content = "Place your food item in bag slot 2.",
                    Time = 3
                })
                spawn(runAutoFood)
            end
        end
    })

    -- Tambahkan Toggle untuk Auto Voodoo
    AutoFeaturesTab:AddToggle({
        Name = "Auto VoodooSpell",
        Default = false,
        Callback = function(state)
            autoVoodooEnabled = state
            if state then
                spawn(runAutoVoodoo)
            end
        end
    })

    -- Tambahkan Toggle untuk Auto Gods
    AutoFeaturesTab:AddToggle({
        Name = "Auto Gods",
        Default = false,
        Callback = function(state)
            autoGodsEnabled = state
            if state then
                spawn(runAutoGods)
            end
        end
    })

    -- Tambahkan Toggle untuk Auto Rebirth
    AutoFeaturesTab:AddToggle({
        Name = "Auto Rebirth",
        Default = false,
        Callback = function(state)
            autoRebirthEnabled = state
            if state then
                spawn(runAutoRebirth)
            end
        end
    })
end

-- Pastikan untuk memanggil fungsi createPickupTab setelah key valid
if keyLoaded or checkKeyValid() then
	createTabs()
end

-- Memulai UI
OrionLib:Init()
