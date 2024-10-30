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
        -- Cek apakah key yang dimasukkan benar
        if EnteredKey == correctKey then
            KeyValid = true
            KeyExpireTime = os.time() + (120 * 60) -- Key berlaku selama 120 menit
            saveKeyData() -- Simpan key ke file
            OrionLib:MakeNotification({
                Name = "Key Accepted",
                Content = "Your key is valid for the next 120 minutes.",
                Time = 5
            })

            -- Unhide tab lain hanya jika key valid
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

    -- Variabel untuk menyimpan dropdown dan list GodOptions
    local GodOptions = {}
    local SelectedGod = nil
    local TpGodsDropdown

    -- Fungsi untuk memperbarui daftar Gods secara dinamis
    local function refreshGodOptions()
        -- Mengosongkan daftar sebelumnya
        GodOptions = {}

        -- Memeriksa keberadaan folder Gods dan God dan mengisi dropdown
        local resourcesFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Resources")
        
        if resourcesFolder then
            -- Periksa dan tambahkan dari folder "Gods" jika ada
            if resourcesFolder:FindFirstChild("Gods") then
                for _, god in pairs(resourcesFolder.Gods:GetChildren()) do
                    if god:IsA("Model") then
                        table.insert(GodOptions, god.Name)
                    end
                end
            end

            -- Periksa dan tambahkan dari folder "God" jika ada
            if resourcesFolder:FindFirstChild("God") then
                for _, god in pairs(resourcesFolder.God:GetChildren()) do
                    if god:IsA("Model") then
                        table.insert(GodOptions, god.Name)
                    end
                end
            end
        end

        -- Perbarui dropdown dengan daftar baru
        if TpGodsDropdown then
            TpGodsDropdown:Refresh(GodOptions, true)  -- Refresh dropdown dengan list baru, true untuk mempertahankan pilihan sebelumnya
        end
    end

    -- Membuat Dropdown Tp Gods di Tab God
    TpGodsDropdown = GodTab:AddDropdown({
        Name = "Tp Gods",
        Default = "Select God",
        Options = GodOptions,
        Callback = function(Value)
            SelectedGod = Value
        end
    })

    -- Jalankan refresh pertama kali untuk mengisi daftar
    refreshGodOptions()

    -- Membuat Toggle Teleport To Gods
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

    -- Fungsi untuk teleport ke model yang dipilih dalam Gods
    function teleportToGods()
        -- Coba cari di kedua folder, "Gods" dan "God"
        local godModel = workspace.Map.Resources:FindFirstChild("Gods") and workspace.Map.Resources.Gods:FindFirstChild(SelectedGod)
                        or workspace.Map.Resources:FindFirstChild("God") and workspace.Map.Resources.God:FindFirstChild(SelectedGod)
                        
        if godModel then
            local targetPosition

            -- Periksa apakah model memiliki PrimaryPart, jika tidak gunakan posisi keseluruhan model
            if godModel.PrimaryPart then
                targetPosition = godModel.PrimaryPart.Position + Vector3.new(0, 10, 0) -- Teleport ke posisi samping PrimaryPart
            else
                targetPosition = godModel:GetModelCFrame().Position + Vector3.new(0, 10, 0) -- Fallback ke GetModelCFrame
            end

            -- Teleport pemain ke targetPosition
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
        end
    end

    -- Menambahkan Toggle Pickup Essence
    local AutoPickupEssenceEnabled = false
    local pickupEssenceRadius = 100 -- Radius pengambilan essence dalam satuan unit
    GodTab:AddToggle({
        Name = "Pickup Essence",
        Default = false,
        Callback = function(Value)
            AutoPickupEssenceEnabled = Value
            if AutoPickupEssenceEnabled then
                spawn(pickupEssences) -- Menjalankan fungsi pickupEssences dalam thread terpisah
            end
        end
    })

    -- Fungsi untuk pickup Essence dan Big Essence di sekitar pemain dengan jarak tertentu
    function pickupEssences()
        while AutoPickupEssenceEnabled do
            local playerPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
            for _, item in pairs(workspace.Important.Items:GetChildren()) do
                if not AutoPickupEssenceEnabled then break end -- Berhenti jika toggle dimatikan
                local itemPosition = item.Position
                local distance = (playerPosition - itemPosition).Magnitude
                
                -- Mengambil item yang merupakan Essence atau Big Essence dan berada dalam jarak yang ditentukan
                if (item.Name == "Essence" or item.Name == "Big Essence") and distance <= pickupEssenceRadius then
                    pcall(function()
                        game:GetService("ReplicatedStorage").Events.Pickup:InvokeServer(item)
                    end)
                end
            end
            wait(0.00001) -- Waktu tunggu dipercepat agar essence dicek setiap 0.1 detik
        end
    end

    -- Refresh daftar Gods setiap 10 detik untuk memastikan list selalu up-to-date
    spawn(function()
        while true do
            wait(5) -- Interval 10 detik untuk refresh
            refreshGodOptions()
        end
    end)

    -- Menambahkan Section Teleport World di Tab God
    local TeleportWorldSection = GodTab:AddSection({
        Name = "Teleport World"
    })

    -- Button untuk teleport ke lokasi normal
    TeleportWorldSection:AddButton({
        Name = "Tp Normal",
        Callback = function()
            game:GetService("TeleportService"):Teleport(18629053284, game.Players.LocalPlayer)
        end
    })

    -- Button untuk teleport ke Void
    TeleportWorldSection:AddButton({
        Name = "Tp to Void",
        Callback = function()
            game:GetService("TeleportService"):Teleport(18629058177, game.Players.LocalPlayer)
        end
    })

    -- Button untuk teleport ke UnderWorld
    TeleportWorldSection:AddButton({
        Name = "Tp To UnderWorld",
        Callback = function()
            game:GetService("TeleportService"):Teleport(92039548740735, game.Players.LocalPlayer)
        end
    })
end


-- Fungsi untuk membuat tab Farm setelah key valid
function createFarmTab()
    local FarmTab = Window:MakeTab({
        Name = "Farm",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    -- Mengambil daftar folder di dalam workspace.Map.Resources, tanpa Misc dan God
    local ResourceFolders = {}
    local resourcesFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Resources")

    if resourcesFolder then
        for _, folder in pairs(resourcesFolder:GetChildren()) do
            if folder:IsA("Folder") and folder.Name ~= "Misc" and folder.Name ~= "God" then
                table.insert(ResourceFolders, folder.Name)
            end
        end
    end
    table.sort(ResourceFolders) -- Mengurutkan secara alfabetis

    -- Tambahkan opsi King Ant jika folder Misc ditemukan
    if resourcesFolder and resourcesFolder:FindFirstChild("Misc") and resourcesFolder.Misc:FindFirstChild("King Spawner") then
        table.insert(ResourceFolders, "King Ant")
    end

    -- Menambahkan Dropdown Tp To di Tab Farm
    local SelectedResource = nil
    FarmTab:AddDropdown({
        Name = "Tp To",
        Default = "Select Resource",
        Options = ResourceFolders,
        Callback = function(Value)
            SelectedResource = Value
        end
    })

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
                -- Menggunakan PrimaryPart atau GetModelCFrame untuk mendapatkan posisi
                local targetPosition
                if kingSpawner.PrimaryPart then
                    targetPosition = kingSpawner.PrimaryPart.Position + Vector3.new(0, 5, 0) -- Teleport ke 5 unit di atas PrimaryPart
                else
                    targetPosition = kingSpawner:GetModelCFrame().Position + Vector3.new(0, 5, 0) -- Fallback ke GetModelCFrame
                end
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
            end
        else
            -- Teleport ke folder yang dipilih jika bukan King Ant
            local resourceFolder = workspace.Map.Resources:FindFirstChild(SelectedResource)
            if resourceFolder then
                for _, resource in pairs(resourceFolder:GetChildren()) do
                    if stopTeleport then break end -- Berhenti jika toggle dimatikan
                    if resource:FindFirstChild("Reference") then
                        local targetPosition = resource.Reference.Position + Vector3.new(0, 5, 0) -- Tambahkan 5 unit di atas
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
                        wait(5) -- Waktu tunggu teleport
                    end
                end
            end
        end
    end

    -- Mengambil daftar Critters di dalam workspace.Important.Critters dan mengurutkannya
    local CritterOptions = {}
    local CritterNames = {}
    for _, critter in pairs(workspace.Important.Critters:GetChildren()) do
        if not critter:IsA("Folder") and not CritterNames[critter.Name] then
            table.insert(CritterOptions, critter.Name)
            CritterNames[critter.Name] = true
        end
    end
    table.sort(CritterOptions)

    -- Menambahkan Dropdown Tp Critters di Tab Farm
    local SelectedCritter = nil
    FarmTab:AddDropdown({
        Name = "Tp Critters",
        Default = "Select Critter",
        Options = CritterOptions,
        Callback = function(Value)
            SelectedCritter = Value
        end
    })

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
        for _, critter in pairs(workspace.Important.Critters:GetChildren()) do
            if stopTeleportCritter then break end -- Berhenti jika toggle dimatikan
            if critter.Name == SelectedCritter and critter:FindFirstChild("HumanoidRootPart") then
                local targetPosition = critter.HumanoidRootPart.Position + Vector3.new(5, 0, 0) -- Teleport ke posisi samping
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
                wait(5) -- Waktu tunggu teleport dipercepat
            end
        end
    end

    -- Menambahkan Toggle Pickup Everything
    local AutoPickupEnabled = false
    local pickupRadius = 100 -- Radius pengambilan item dalam satuan unit
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
            for _, item in pairs(workspace.Important.Items:GetChildren()) do
                if not AutoPickupEnabled then break end -- Berhenti jika toggle dimatikan
                local itemPosition = item.Position
                local distance = (playerPosition - itemPosition).Magnitude
                
                -- Hanya mengambil item yang berada dalam jarak yang ditentukan
                if distance <= pickupRadius then
                    pcall(function()
                        game:GetService("ReplicatedStorage").Events.Pickup:InvokeServer(item)
                    end)
                end
            end
            wait(0.0001) -- Waktu tunggu dipercepat agar item dicek setiap 0.1 detik
        end
    end

    -- Menambahkan Toggle Pickup Undead Stick di Tab Farm
    local AutoPickupUndeadStickEnabled = false
    local pickupUndeadStickRadius = 100 -- Radius pengambilan item Undead Stick dalam unit

    FarmTab:AddToggle({
        Name = "Pickup Undead Stick",
        Default = false,
        Callback = function(Value)
            AutoPickupUndeadStickEnabled = Value
            if AutoPickupUndeadStickEnabled then
                spawn(pickupUndeadSticks) -- Menjalankan fungsi pickupUndeadSticks dalam thread terpisah
            end
        end
    })

    -- Fungsi untuk mengambil hanya Undead Stick di sekitar pemain dengan jarak tertentu
    function pickupUndeadSticks()
        while AutoPickupUndeadStickEnabled do
            local playerPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
            for _, item in pairs(workspace.Important.Items:GetChildren()) do
                if not AutoPickupUndeadStickEnabled then break end -- Berhenti jika toggle dimatikan
                local itemPosition = item.Position
                local distance = (playerPosition - itemPosition).Magnitude
                
                -- Mengambil hanya item yang bernama "Undead Stick" dan berada dalam radius yang ditentukan
                if item.Name == "Undead Stick" and distance <= pickupUndeadStickRadius then
                    pcall(function()
                        game:GetService("ReplicatedStorage").Events.Pickup:InvokeServer(item)
                    end)
                end
            end
            wait(0.0001) -- Interval yang sangat kecil agar pengambilan item berlangsung cepat
        end
    end
end


-- Memulai script jika key valid saat pertama kali dijalankan
if keyLoaded or checkKeyValid() then
    createGodTab()
    createFarmTab()
end

-- Memulai UI
OrionLib:Init()