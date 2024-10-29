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
        print("Key entered: " .. EnteredKey) -- Debug: mencetak key yang dimasukkan
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

-- Fungsi untuk membuat tab Farm setelah key valid
function createFarmTab()
    local FarmTab = Window:MakeTab({
        Name = "Farm",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    -- Mengambil daftar folder di dalam workspace.Map.Resources dan mengurutkannya
    local ResourceFolders = {}
    for _, folder in pairs(workspace.Map.Resources:GetChildren()) do
        if folder:IsA("Folder") then
            table.insert(ResourceFolders, folder.Name)
        end
    end
    table.sort(ResourceFolders) -- Mengurutkan secara alfabetis

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

    -- Fungsi untuk teleport ke setiap Reference dalam folder yang dipilih
    function teleportToResources()
        local resourceFolder = workspace.Map.Resources:FindFirstChild(SelectedResource)
        if resourceFolder then
            for _, resource in pairs(resourceFolder:GetChildren()) do
                if stopTeleport then break end -- Berhenti jika toggle dimatikan
                if resource:FindFirstChild("Reference") then
                    -- Teleport ke posisi sedikit di atas Reference
                    local targetPosition = resource.Reference.Position + Vector3.new(0, 5, 0) -- Tambahkan 5 unit di atas
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
                    OrionLib:MakeNotification({
                        Name = "Teleporting",
                        Content = "Teleported to " .. resource.Name,
                        Time = 3
                    })
                    wait(10) -- Diam selama 10 detik
                end
            end
        else
            OrionLib:MakeNotification({
                Name = "Error",
                Content = "Selected resource folder not found.",
                Time = 5
            })
        end
    end

    -- Mengambil daftar elemen unik di dalam workspace.Important.Critters dan mengurutkannya
    local CritterOptions = {}
    local CritterNames = {}
    for _, item in pairs(workspace.Important.Critters:GetChildren()) do
        if not item:IsA("Folder") and not CritterNames[item.Name] then
            table.insert(CritterOptions, item.Name)
            CritterNames[item.Name] = true -- Tandai nama sebagai sudah dimasukkan
        end
    end
    table.sort(CritterOptions) -- Mengurutkan secara alfabetis

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
                -- Teleport ke posisi di samping HumanoidRootPart
                local targetPosition = critter.HumanoidRootPart.Position + Vector3.new(5, 0, 0) -- Tambahkan 5 unit di samping pada sumbu X
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
                OrionLib:MakeNotification({
                    Name = "Teleporting",
                    Content = "Teleported beside " .. critter.Name,
                    Time = 3
                })
                wait(10) -- Diam selama 10 detik
            end
        end
    end
end

-- Memulai script jika key valid saat pertama kali dijalankan
if keyLoaded or checkKeyValid() then
    createFarmTab()
end

-- Memulai UI
OrionLib:Init()

