-- Inisialisasi Orion Library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Variabel untuk menyimpan status key dan waktu aktif
local KeyValid = false
local KeyExpireTime = nil
local correctKey = "boss" -- Key yang valid dari pastebin
local saveFile = "KeySave.txt"

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

-- Membuat Jendela (Window) dengan judul Anime Strike Script
local Window = OrionLib:MakeWindow({
    Name = "Anime Strike Script", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "AnimeStrikeConfig"
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
        setclipboard('https://pastebin.com/raw/nhnwmB73') -- Link untuk mendapatkan key
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
        -- Debug sebelum pengecekan key
        print("Checking entered key...")

        -- Cek apakah key yang dimasukkan benar
        if EnteredKey == correctKey then
            print("Key accepted") -- Debug: Key benar
            KeyValid = true
            KeyExpireTime = os.time() + (120 * 60) -- Key berlaku selama 120 menit
            saveKeyData() -- Simpan key ke file
            OrionLib:MakeNotification({
                Name = "Key Accepted",
                Content = "Your key is valid for the next 120 minutes.",
                Time = 5
            })

            -- Unhide tab lain hanya jika key valid
            createTabs()
        else
            print("Invalid key entered") -- Debug: Key salah
            OrionLib:MakeNotification({
                Name = "Key Invalid",
                Content = "The key you entered is invalid. Please try again.",
                Time = 5
            })
        end
    end
})

-- Tombol untuk mengecek status key
KeySystemSection:AddButton({
    Name = "Check Key Status",
    Callback = function()
        if checkKeyValid() then
            local timeRemaining = KeyExpireTime - os.time()
            local minutesRemaining = math.floor(timeRemaining / 60)
            OrionLib:MakeNotification({
                Name = "Key Status",
                Content = "Your key is valid. Time remaining: " .. minutesRemaining .. " minutes.",
                Time = 5
            })
        else
            OrionLib:MakeNotification({
                Name = "Key Status",
                Content = "Your key is expired or invalid.",
                Time = 5
            })
        end
    end
})

-- Fungsi untuk membuat tab hanya setelah key valid
function createTabs()
    -- Membuat Tab Misc
    local MiscTab = Window:MakeTab({
        Name = "Misc",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    -- Membuat Toggle Auto Rejoin di Tab Misc
    local AutoRejoinEnabled = false
    MiscTab:AddToggle({
        Name = "Auto Rejoin",
        Default = false,
        Save = true, -- Menyimpan toggle ini dalam konfigurasi
        Flag = "AutoRejoin", -- Nama flag untuk toggle ini
        Callback = function(Value)
            AutoRejoinEnabled = Value
            if AutoRejoinEnabled then
                -- Fungsi Auto Rejoin saat game disconnect
                game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(Child)
                    if Child.Name == "ErrorPrompt" then
                        wait(0.1) -- Tunggu sebentar sebelum melakukan rejoin
                        game:GetService("TeleportService"):Teleport(game.PlaceId) -- Rejoin ke game
                    end
                end)
            end
        end    
    })

-- Auto Redeem Code Feature (NEW ADDITION BELOW AUTO REJOIN TOGGLE)
local RedeemCodes = {
    "Release",
    "FixBugs",
    "1KLIKES",
    "2.5KLIKES",
    "5KLIKES",
    "THX10KLIKES",
    "UPDATE1",
    "THXFOR15KLIKES",
    "THXFOR20KLIKES",
    "THXFOR30KLIKES",
    "UPDATE2",
    "UPDATE3",
    "GrimoiresFixed",
    "Mini3.5",
    "UPDATE4",
    "FIXEDRAIDPATH",
    "UPDATE4FIXES",
    "UPDATE5",
    "UPDATE5FIXES",
    "UPDATE5FIXES2",
    "MINI5.5",
    "UPDATE6",
    "ALREADY50KLIKES?",
    "UPDATE6FIXES",
    "MINI6.5",
    "MINI6.5Fixes",
    "UPDATE7",
    "MINI7.5",
    "NerfedScrews",
    "UPDATE8",
    "UPDATE8FIXES",
    "UPDATE8PART2",
    "UPDATE9",
    "UPDATE9FIXES",
    "MINI9.5",
    "MINI9.5FIXES",
    "HALLOWEENSTARTSNOW",
    "FIXEDMOBS",
    "PATCH10.1",
    "MINI10.5",
    "FreddyBuff",
    "FixedRaidBoss",
    "HALLOWEENPART2",
    "FIXEDUPD11",
    "THXFOR75KLIKES",
    "MoreFixes",
    "MINI11.5",
    "SorryForShutdown",
	"Update12",
	"FixedSomeBugs",
	"Mini12.5",
	"UPD13",
	"OMG100KLIKES"
}

-- Add Auto Redeem Code Button Below Auto Rejoin Toggle
MiscTab:AddButton({
    Name = "Auto Redeem Codes",
    Callback = function()
        for _, code in ipairs(RedeemCodes) do
            local args = {
                [1] = "Codes",
                [2] = "Redeem",
                [3] = code
            }
            game:GetService("ReplicatedStorage").Bridge:FireServer(unpack(args))
            wait(1) -- Add a small delay between each code redeem to avoid issues
        end
        OrionLib:MakeNotification({
            Name = "Auto Redeem Complete",
            Content = "All codes have been redeemed!",
            Time = 5
        })
    end
})

    -- Membuat Tab Fight
    local FightTab = Window:MakeTab({
        Name = "Fight",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    -- Membuat Section Auto Click dalam Tab Fight
    local AutoClickSection = FightTab:AddSection({
        Name = "Auto Click"
    })

    -- Membuat Toggle Auto Click
    local AutoClickEnabled = false
    AutoClickSection:AddToggle({
        Name = "Auto Click",
        Default = false,
        Save = true, -- Menyimpan toggle ini dalam konfigurasi
        Flag = "AutoClick", -- Nama flag untuk toggle ini
        Callback = function(Value)
            AutoClickEnabled = Value
            if AutoClickEnabled then
                while AutoClickEnabled do
                    local args = {
                        [1] = "Attack",
                        [2] = "Click"
                    }
                    game:GetService("ReplicatedStorage").Bridge:FireServer(unpack(args))
                    wait(0.000000001) -- Jeda antar klik
                end
            end
        end    
    })

    -- Membuat Section Auto Fight
    local AutoFightEnabled = false
    local AutoFightSection = FightTab:AddSection({
        Name = "Auto Fight"
    })

    -- Membuat Dropdown untuk memilih World
    local SelectedWorld = nil
    local WorldOptions = {}
    for _, world in pairs(workspace.Server.WorldMobs:GetChildren()) do
        table.insert(WorldOptions, world.Name)
    end

    AutoFightSection:AddDropdown({
        Name = "Select World",
        Default = "Select World",
        Options = WorldOptions,
        Save = true,
        Flag = "SelectedWorld",
        Callback = function(Value)
            SelectedWorld = Value
            
            -- Memperbarui daftar musuh berdasarkan world yang dipilih
            local enemies = {}
            local worldFolder = workspace:WaitForChild("Server"):WaitForChild("WorldMobs"):FindFirstChild(SelectedWorld)
            if worldFolder then
                for _, enemy in pairs(worldFolder:GetChildren()) do
                    if not table.find(enemies, enemy.Name) then
                        table.insert(enemies, enemy.Name) -- Tambah enemy unik
                    end
                end
            end
            
            -- Perbarui dropdown Select Enemy
            OrionLib.Flags.SelectedEnemy:Refresh(enemies, true) -- Memperbarui opsi musuh
        end
    })

    -- Membuat Dropdown untuk memilih Enemy
    local SelectedEnemy = nil
    AutoFightSection:AddDropdown({
        Name = "Select Enemy",
        Default = "Select Enemy",
        Options = {},
        Save = true,
        Flag = "SelectedEnemy",
        Callback = function(Value)
            SelectedEnemy = Value
        end
    })

    -- Membuat Toggle Auto Fight
    AutoFightSection:AddToggle({
        Name = "Auto Fight",
        Default = false,
        Save = true,
        Flag = "AutoFight",
        Callback = function(Value)
            AutoFightEnabled = Value
            if AutoFightEnabled and SelectedWorld and SelectedEnemy then
                while AutoFightEnabled do
                    -- Menggunakan WaitForChild untuk mendapatkan world dan enemy berdasarkan pilihan
                    local worldFolder = workspace:WaitForChild("Server"):WaitForChild("WorldMobs"):WaitForChild(SelectedWorld)
                    local targetEnemy = worldFolder:WaitForChild(SelectedEnemy)

                    if targetEnemy then
                        -- Teleport ke posisi musuh berdasarkan Position
                        local targetPosition = targetEnemy.Position or targetEnemy:FindFirstChildWhichIsA("BasePart").Position
                        if targetPosition then
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
                        else
                            print("Unable to find a valid position for the enemy.")
                            AutoFightEnabled = false
                            return
                        end

                        repeat
                            -- Fungsi menyerang musuh yang dipilih
                            local args = {
                                [1] = "Attack",
                                [2] = "Click",
                                [3] = targetEnemy
                            }
                            game:GetService("ReplicatedStorage"):WaitForChild("Bridge"):FireServer(unpack(args))

                            wait(0.00000000001) -- Jeda serangan sangat kecil
                        until not targetEnemy or not targetEnemy.Parent or not AutoFightEnabled -- Berhenti jika musuh tidak ada atau toggle dimatikan
                    else
                        -- Musuh tidak ditemukan atau sudah kalah
                        AutoFightEnabled = false -- Berhenti jika musuh tidak ada
                    end
                    wait(0.1) -- Jeda sebelum mencari musuh berikutnya
                end
            elseif not SelectedWorld or not SelectedEnemy then
                OrionLib:MakeNotification({
                    Name = "Error",
                    Content = "Please select both World and Enemy before activating Auto Fight.",
                    Time = 5
                })
            end
        end    
    })

    -- Membuat Tab Summon
    local SummonTab = Window:MakeTab({
        Name = "Summon",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    -- Membuat Section Summon dalam Tab Summon
    local SummonSection = SummonTab:AddSection({
        Name = "Summon"
    })

    -- Variabel untuk menyimpan map yang dipilih
    local SelectedMap = nil

    -- Membuat Dropdown Map
    local MapOptions = {}
    for _, map in pairs(workspace:WaitForChild("Client"):WaitForChild("Maps"):GetChildren()) do
        table.insert(MapOptions, map.Name)
    end

    local MapDropdown = SummonSection:AddDropdown({
        Name = "Select Map",
        Default = "Select Map",
        Options = MapOptions,
        Save = true,
        Flag = "SelectedMap",
        Callback = function(Value)
            SelectedMap = Value
            print("Selected Map: ", SelectedMap) -- Debugging map yang dipilih

            -- Teleport ke lokasi map yang dipilih menggunakan WorldPivot
            local targetBase = workspace.Client.Maps[SelectedMap].Summon.Currency.WorldPivot.Position
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetBase)
        end
    })

    -- Tombol Refresh Dropdown Map
    SummonSection:AddButton({
        Name = "Refresh Map Dropdown",
        Callback = function()
            MapOptions = {}
            for _, map in pairs(workspace:WaitForChild("Client"):WaitForChild("Maps"):GetChildren()) do
                table.insert(MapOptions, map.Name)
            end
            MapDropdown:Refresh(MapOptions, true) -- Refresh dropdown dengan opsi terbaru
            OrionLib:MakeNotification({
                Name = "Dropdown Refreshed",
                Content = "Map dropdown has been refreshed.",
                Time = 5
            })
        end
    })

    -- Membuat Toggle Auto Summon
    local AutoSummonEnabled = false
    SummonSection:AddToggle({
        Name = "Auto Summon",
        Default = false,
        Save = true,
        Flag = "AutoSummon",
        Callback = function(Value)
            AutoSummonEnabled = Value
            if AutoSummonEnabled and SelectedMap then
                while AutoSummonEnabled do
                    local args = {
                        [1] = "Summon",
                        [2] = "Summon",
                        [3] = {
                            ["Instance"] = workspace:WaitForChild("Client"):WaitForChild("Maps"):WaitForChild(SelectedMap):WaitForChild("Summon"):WaitForChild("Currency"),
                            ["Map"] = SelectedMap
                        },
                        [4] = "Multi"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Bridge"):FireServer(unpack(args))
                    wait(0.1) -- Jeda antar summon
                end
            elseif not SelectedMap then
                OrionLib:MakeNotification({
                    Name = "Error",
                    Content = "Please select a map before activating Auto Summon.",
                    Time = 5
                })
            end
        end    
    })
end

-- Cek apakah key masih valid saat pertama kali dijalankan
if keyLoaded or checkKeyValid() then
    createTabs()
end

-- Memulai UI
OrionLib:Init()