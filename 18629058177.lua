-- Inisialisasi Orion Library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Variabel Key System
local KeyValid = false
local KeyExpireTime = nil
local correctKey = "survival" -- Key yang valid
local saveFile = "KeySave_SurvivalOdyssey.txt"

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
            KeyExpireTime = os.time() + (120 * 60) -- Key berlaku selama 120 menit
            saveKeyData()
            OrionLib:MakeNotification({
                Name = "Key Accepted",
                Content = "Your key is valid for the next 120 minutes.",
                Time = 5
            })
            createGodTab()
            createFarmTab()
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

    -- Fungsi untuk memperbarui opsi Resource secara dinamis
    local function refreshResourceOptions()
        ResourceFolders = {}
        if resourcesFolder then
            for _, folder in pairs(resourcesFolder:GetChildren()) do
                if folder:IsA("Folder") and folder.Name ~= "Misc" and folder.Name ~= "God" and folder.Name ~= "Gods" then
                    table.insert(ResourceFolders, folder.Name)
                end
            end
        end
        -- Tambahkan opsi King Ant jika folder Misc ditemukan
        if resourcesFolder and resourcesFolder:FindFirstChild("Misc") and resourcesFolder.Misc:FindFirstChild("King Spawner") then
            table.insert(ResourceFolders, "King Ant")
        end

        table.sort(ResourceFolders)  -- Mengurutkan daftar ResourceFolders secara alfabetis

        if TpResourceDropdown then
            TpResourceDropdown:Refresh(ResourceFolders, true)  -- Refresh dropdown dengan list baru
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


-- Menjalankan script jika key valid
if keyLoaded or checkKeyValid() then
    createGodTab()
    createFarmTab()
end

-- Memulai UI
OrionLib:Init()