-- Inisialisasi Orion Library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Variabel Key System
local KeyValid = false
local KeyExpireTime = nil
local correctKey = "animekey" -- Key yang valid
local saveFile = "KeySave_AnimeShadow.txt"

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
    Name = "Anime Shadow",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "AnimeShadowConfig"
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
        setclipboard('https://pastebin.com/raw/animekey') -- Link untuk mendapatkan key
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
            createTrialTab()
            createMainTab()
        else
            OrionLib:MakeNotification({
                Name = "Key Invalid",
                Content = "The key you entered is invalid. Please try again.",
                Time = 5
            })
        end
    end
})

-- Fungsi untuk membuat tab Trial setelah key valid
function createTrialTab()
    local TrialTab = Window:MakeTab({
        Name = "Trial",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    -- Section untuk Menampilkan Waktu dari Path yang Ditentukan
    local TrialSection = TrialTab:AddSection({
        Name = "Trial Time Display"
    })

    -- Label untuk menampilkan waktu
    local TimeLabel = TrialSection:AddLabel("Loading time...")

    -- Fungsi untuk memperbarui waktu
    local function updateTime()
        local timeValue = workspace:FindFirstChild("Server")
            and workspace.Server:FindFirstChild("Trial")
            and workspace.Server.Trial:FindFirstChild("Lobby")
            and workspace.Server.Trial.Lobby:FindFirstChild("Easy_Screen")
            and workspace.Server.Trial.Lobby.Easy_Screen:FindFirstChild("Frame")
            and workspace.Server.Trial.Lobby.Easy_Screen.Frame:FindFirstChild("Value")

        if timeValue then
            local contentTime = timeValue.Text or timeValue.Value or "N/A" -- Menyesuaikan properti yang tepat
            TimeLabel:Set(contentTime)
        else
            TimeLabel:Set("Time data not available")
        end
    end

    -- Memperbarui waktu setiap 1 detik
    spawn(function()
        while true do
            updateTime()
            wait(1)
        end
    end)
end

-- Fungsi untuk membuat Tab Main
function createMainTab()
    local MainTab = Window:MakeTab({
        Name = "Main",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    -- Toggle untuk Auto Click
    local AutoClickEnabled = false

    MainTab:AddToggle({
        Name = "Auto Click",
        Default = false,
        Callback = function(Value)
            AutoClickEnabled = Value
            if AutoClickEnabled then
                startAutoClick()
            end
        end
    })

    -- Fungsi untuk menjalankan Auto Click setiap 0.01 detik
    function startAutoClick()
        spawn(function()
            while AutoClickEnabled do
                local args = {
                    [1] = "Enemies",
                    [2] = "World",
                    [3] = "Click"
                }
                game:GetService("ReplicatedStorage").Remotes.Bridge:FireServer(unpack(args))
                wait(0.01)
            end
        end)
    end

    -- Section Auto Fight
    local AutoFightSection = MainTab:AddSection({
        Name = "Auto Fight"
    })

    -- Dropdown untuk Enemy Map
    local EnemyMapOptions = {}
    local SelectedMap = nil
    local SelectedEnemy = nil
    local EnemyDropdown

    -- Mengisi Dropdown Enemy Map dengan nama-nama map dari workspace.Server.Enemies
    for _, mapFolder in pairs(workspace.Server.Enemies:GetChildren()) do
        if mapFolder:IsA("Folder") then
            table.insert(EnemyMapOptions, mapFolder.Name)
        end
    end

    -- Dropdown untuk memilih map
    AutoFightSection:AddDropdown({
        Name = "Enemy Map",
        Default = "Select Map",
        Options = EnemyMapOptions,
        Callback = function(Value)
            SelectedMap = Value
            refreshEnemyDropdown()
        end
    })

    -- Fungsi untuk mengisi semua Enemies unik sebelum Map dipilih
    local function getAllUniqueEnemies()
        local uniqueEnemies = {}
        for _, mapFolder in pairs(workspace.Server.Enemies:GetChildren()) do
            if mapFolder:IsA("Folder") then
                for _, enemy in pairs(mapFolder:GetChildren()) do
                    if enemy:IsA("Part") and not table.find(uniqueEnemies, enemy.Name) then
                        table.insert(uniqueEnemies, enemy.Name)
                    end
                end
            end
        end
        return uniqueEnemies
    end

    -- Mengisi dropdown Enemies dengan daftar awal dari semua Enemies unik
    local InitialEnemiesList = getAllUniqueEnemies()
    EnemyDropdown = AutoFightSection:AddDropdown({
        Name = "Enemies",
        Default = "Select Enemy",
        Options = InitialEnemiesList,
        Callback = function(Value)
            SelectedEnemy = Value
        end
    })

    -- Fungsi untuk memperbarui Dropdown Enemies berdasarkan Map yang dipilih
    function refreshEnemyDropdown()
        if not SelectedMap then return end

        local uniqueEnemies = {}
        local enemiesFolder = workspace.Server.Enemies:FindFirstChild(SelectedMap)

        if enemiesFolder then
            for _, enemy in pairs(enemiesFolder:GetChildren()) do
                if enemy:IsA("Part") and not table.find(uniqueEnemies, enemy.Name) then
                    table.insert(uniqueEnemies, enemy.Name)
                end
            end
        end

        if EnemyDropdown then
            EnemyDropdown:Refresh(uniqueEnemies, true)
        end
    end

    -- Toggle untuk Auto Fight
    local AutoFightEnabled = false

    AutoFightSection:AddToggle({
        Name = "Auto Fight",
        Default = false,
        Callback = function(Value)
            AutoFightEnabled = Value
            if AutoFightEnabled then
                startAutoFight()
            end
        end
    })

    -- Fungsi untuk mendapatkan UUID dari pet ID
    local function getPetUUID(petID)
        return petID:match("%-%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x")
    end

    -- Fungsi untuk mendapatkan semua UUID pet dari player
    function getPlayerPetUUIDs()
        local petUUIDs = {}
        local playerName = game.Players.LocalPlayer.Name
        for _, petFolder in pairs(workspace.Server.Pets:GetChildren()) do
            if petFolder.Name:match(playerName) then
                local uuid = getPetUUID(petFolder.Name)
                if uuid then
                    table.insert(petUUIDs, uuid)
                end
            end
        end
        return petUUIDs
    end

    -- Fungsi untuk menjalankan Auto Fight
    function startAutoFight()
        spawn(function()
            local petUUIDs = getPlayerPetUUIDs()
            if #petUUIDs == 0 then
                OrionLib:MakeNotification({
                    Name = "No Pets Found",
                    Content = "No pet UUIDs could be found for the player.",
                    Time = 5
                })
                return
            end

            while AutoFightEnabled and SelectedMap and SelectedEnemy do
                for _, petUUID in ipairs(petUUIDs) do
                    local enemyInstance = workspace.Server.Enemies:FindFirstChild(SelectedMap)
                        and workspace.Server.Enemies[SelectedMap]:FindFirstChild(SelectedEnemy)

                    if enemyInstance then
                        local args = {
                            [1] = "General",
                            [2] = "Pets",
                            [3] = "Attack",
                            [4] = petUUID,
                            [5] = enemyInstance
                        }
                        game:GetService("ReplicatedStorage").Remotes.Bridge:FireServer(unpack(args))
                    end
                end

                -- Mengecek apakah pet sudah tidak ada dalam Info.Pets
                wait(0.5)  -- Delay untuk menghindari spam
                for _, petUUID in ipairs(petUUIDs) do
                    local enemyPetsFolder = workspace.Server.Enemies:FindFirstChild(SelectedMap)
                        and workspace.Server.Enemies[SelectedMap]:FindFirstChild(SelectedEnemy)
                        and workspace.Server.Enemies[SelectedMap][SelectedEnemy]:FindFirstChild("Info")
                        and workspace.Server.Enemies[SelectedMap][SelectedEnemy].Info:FindFirstChild("Pets")

                    if enemyPetsFolder and not enemyPetsFolder:FindFirstChild(petUUID) then
                        -- Jika petUUID tidak ada di folder Info.Pets, kirim pet untuk menyerang lagi
                        local args = {
                            [1] = "General",
                            [2] = "Pets",
                            [3] = "Attack",
                            [4] = petUUID,
                            [5] = workspace.Server.Enemies[SelectedMap][SelectedEnemy]
                        }
                        game:GetService("ReplicatedStorage").Remotes.Bridge:FireServer(unpack(args))
                    end
                end
                wait(0.5)
            end
        end)
    end
end

-- Memastikan fungsi createTrialTab dan createMainTab dipanggil setelah key valid
if keyLoaded or checkKeyValid() then
    createTrialTab()
    createMainTab()
end

-- Memulai UI
OrionLib:Init()