-- Memuat OrionLib
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Membuat Window dengan OrionLib
local Window = OrionLib:MakeWindow({
    Name = "Arm Wrestle", 
    HidePremium = false, 
    SaveConfig = true,
    ConfigFolder = "ArmWrestleScript"
})

-- Rejoin saat terjadi error
game:GetService("GuiService").ErrorMessageChanged:Connect(function()
    wait(0.1)
    game:GetService("TeleportService"):Teleport(game.PlaceId)
end)

-- Anti AFK
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- Tab Main
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998", -- Bisa diganti dengan icon yang diinginkan
    PremiumOnly = false
})

-- Section untuk Farming
local FarmingSection = MainTab:AddSection({
    Name = "Farming"
})

-- Auto Claim Gift
local isClaiming = false
local claimCoroutine

MainTab:AddToggle({
    Name = "Auto Claim Gift",
    Default = false,
    Callback = function(v)
        isClaiming = v
        if isClaiming then
            claimCoroutine = coroutine.create(function()
                while isClaiming do
                    for i = 1, 12 do
                        if not isClaiming then return end
                        local args = { [1] = i }
                        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit")
                            :WaitForChild("Services"):WaitForChild("TimedRewardService"):WaitForChild("RE")
                            :WaitForChild("onClaim"):FireServer(unpack(args))
                        wait(0.01)
                    end
                end
            end)
            coroutine.resume(claimCoroutine)
        else
            if claimCoroutine then coroutine.yield(claimCoroutine) end
        end
    end
})

-- Fungsi untuk mendapatkan daftar nama NPC dari setiap zona
local function getNPCList()
    local npcs = {}
    local armWrestling = workspace:WaitForChild("GameObjects"):WaitForChild("ArmWrestling")

    for _, zone in pairs(armWrestling:GetChildren()) do
        local npcParent = zone:FindFirstChild("NPC")
        if npcParent then
            for _, npc in pairs(npcParent:GetChildren()) do
                table.insert(npcs, "Zone: " .. zone.Name .. " || NPC Name: " .. npc.Name)
            end
        end
    end
    
    -- Mengurutkan daftar NPC berdasarkan zona dan nama NPC
    table.sort(npcs, function(a, b)
        local zoneA, nameA = a:match("Zone: (.+) || NPC Name: (.+)")
        local zoneB, nameB = b:match("Zone: (.+) || NPC Name: (.+)")
        
        if tonumber(zoneA) and tonumber(zoneB) then
            if tonumber(zoneA) == tonumber(zoneB) then
                return nameA < nameB
            else
                return tonumber(zoneA) < tonumber(zoneB)
            end
        elseif tonumber(zoneA) then
            return true
        elseif tonumber(zoneB) then
            return false
        else
            if zoneA == zoneB then
                return nameA < nameB
            else
                return zoneA < zoneB
            end
        end
    end)

    return npcs
end

-- Inisialisasi dropdown dengan daftar NPC
local npcDropdown
local function createNPCDropdown()
    npcDropdown = MainTab:AddDropdown({
        Name = "Select NPC",
        Default = "None",
        Options = getNPCList(),
        Callback = function(option)
            getgenv().selectedNPC = option:match("NPC Name: (.+)")
            getgenv().selectedZone = option:match("Zone: (.+) ||")  -- Menyimpan zona yang dipilih
        end
    })
end

createNPCDropdown()

-- Inisialisasi variabel global untuk auto farming
getgenv().AutoFarm = false
getgenv().selectedNPC = "None"
getgenv().selectedZone = "None"

-- Fungsi untuk auto farming
local function autoFarm()
    while getgenv().AutoFarm do
        if getgenv().selectedNPC and getgenv().selectedNPC ~= "None" then
            local npcPath = workspace:WaitForChild("GameObjects"):WaitForChild("ArmWrestling"):WaitForChild(getgenv().selectedZone):WaitForChild("NPC"):FindFirstChild(getgenv().selectedNPC):WaitForChild("Table")
            if npcPath then
                local args = {
                    [1] = getgenv().selectedNPC,
                    [2] = npcPath,
                    [3] = getgenv().selectedZone
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ArmWrestleService"):WaitForChild("RE"):WaitForChild("onEnterNPCTable"):FireServer(unpack(args))
            end
        end
        wait(1) -- Interval waktu antara interaksi (dalam detik, sesuaikan dengan kebutuhan)
    end
end

-- Menambahkan toggle untuk auto farming ke UI
MainTab:AddToggle({
    Name = "Start Farming",
    Default = false,
    Callback = function(Value)
        getgenv().AutoFarm = Value
        if Value then
            autoFarm()
        end
    end
})

-- Menambahkan toggle untuk Auto Tap NPC ke UI
MainTab:AddToggle({
    Name = "Auto Tap NPC",
    Default = false,
    Callback = function(Value)
        getgenv().AutoTapNPC = Value
        while getgenv().AutoTapNPC do
            game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit")
                :WaitForChild("Services"):WaitForChild("ArmWrestleService"):WaitForChild("RE"):WaitForChild("onClickRequest"):FireServer()
            wait(0.01) -- Interval waktu antara interaksi (dalam detik, sesuaikan dengan kebutuhan)
        end
    end
})

-- Fungsi Trial
local isTrialActive = false
local trialCoroutine

MainTab:AddToggle({
    Name = "Trial",
    Default = false,
    Callback = function(value)
        isTrialActive = value
        if isTrialActive then
            -- Jalankan fungsi pertama dan kedua sekali
            local args = {
                [1] = "Medieval"
            }
            game:GetService("ReplicatedStorage").Packages.Knit.Services.ChampionshipService.RF.RequestJoin:InvokeServer(unpack(args))
            
            game:GetService("ReplicatedStorage").Packages.Knit.Services.TeleportService.RF.ShowTeleport:InvokeServer()

            -- Mulai menjalankan fungsi ketiga secara terus menerus
            trialCoroutine = coroutine.create(function()
                while isTrialActive do
                    game:GetService("ReplicatedStorage").Packages.Knit.Services.WrestleService.RF.OnClick:InvokeServer()
                    wait(0.000000000000000000000001)
                end
            end)
            coroutine.resume(trialCoroutine)
        else
            -- Hentikan coroutine ketika toggle dimatikan
            isTrialActive = false
            if trialCoroutine then
                coroutine.yield(trialCoroutine)
            end
        end
    end
})

-- Tab Event
local EventTab = Window:MakeTab({
    Name = "Event",
    Icon = "rbxassetid://4483345998", -- Bisa diganti dengan icon yang diinginkan
    PremiumOnly = false
})

-- Section untuk Halloween Event
local HalloweenSection = EventTab:AddSection({
    Name = "Halloween Event"
})

-- Auto TrickOrTreat
EventTab:AddToggle({
    Name = "Auto TrickOrTreat",
    Default = false,
    Callback = function(value)
        getgenv().autoTrickOrTreat = value
        if value then
            spawn(function()
                while getgenv().autoTrickOrTreat do
                    for i = 1, 48 do
                        if not getgenv().autoTrickOrTreat then return end -- Berhenti jika toggle dimatikan

                        -- Temukan folder berdasarkan nomor
                        local folder = workspace.GameObjects.TrickOrTreat:FindFirstChild(tostring(i))
                        if folder then
                            -- Tentukan posisi teleport (PrimaryPart atau WorldPivot)
                            local targetPosition = folder.PrimaryPart and folder.PrimaryPart.CFrame.Position or folder:GetPivot().Position

                            -- Teleport player ke folder
                            game.Players.LocalPlayer.Character:PivotTo(CFrame.new(targetPosition))

                            -- Tunggu sebentar agar teleportasi selesai
                            wait(1.5)

                            -- Eksekusi fungsi TrickOrTreat setelah teleport
                            local args = { [1] = tostring(i) }
                            game:GetService("ReplicatedStorage").Packages.Knit.Services.TrickOrTreatService.RF.TrickOrTreat:InvokeServer(unpack(args))
                        end

                        -- Jeda lebih lama antara perpindahan (misal 5 detik)
                        wait(5)
                    end

                    -- Jeda 60 detik setelah selesai 1-48
                    wait(60)
                end
            end)
        end
    end
})

-- Auto Tap NPC TrickOrTreat
EventTab:AddToggle({
    Name = "Auto Tap NPC TrickOrTreat",
    Default = false,
    Callback = function(value)
        getgenv().autoTapNPC = value
        if value then
            spawn(function()
                while getgenv().autoTapNPC do
                    -- Panggil fungsi OnClick
                    game:GetService("ReplicatedStorage").Packages.Knit.Services.WrestleService.RF.OnClick:InvokeServer()

                    -- Jeda 0,1 detik sebelum melakukan tap berikutnya
                    wait(0.000000001)
                end
            end)
        end
    end
})

-- Auto Hit 🎃👻
-- Fungsi untuk auto hit objek breakables
local function autoHitBreakables()
    while autoHitAktif do
        -- Dapatkan daftar breakables
        local breakables = workspace:WaitForChild("GameObjects"):WaitForChild("Breakables"):GetChildren()

        for _, breakable in pairs(breakables) do
            if not autoHitAktif then 
                return 
            end -- Berhenti jika toggle dimatikan

            -- Teleport pemain ke posisi objek breakable jika valid
            if breakable:IsA("MeshPart") then
                local targetPosition = breakable.Position -- Menggunakan posisi MeshPart

                -- Cek apakah pemain memiliki karakter dan dapat dipindahkan
                local character = game.Players.LocalPlayer.Character
                local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

                if humanoidRootPart then
                    -- Teleport menggunakan PivotTo untuk memindahkan seluruh karakter
                    character:PivotTo(CFrame.new(targetPosition))

                    -- Tunggu sebentar agar teleport selesai
                    wait(1)

                    -- Ambil ID dari objek breakable
                    local breakableID = breakable.Name
                    local args = { [1] = breakableID }

                    -- Eksekusi hit secara terus menerus selama 10 detik
                    local startTime = tick() -- Catat waktu mulai
                    while tick() - startTime < 10 and autoHitAktif do
                        -- Hit breakable
                        game:GetService("ReplicatedStorage").Packages.Knit.Services.BreakableService.RF.HitBreakable:InvokeServer(unpack(args))

                        -- Jeda kecil antara setiap pukulan
                        wait(0.0000000000000001)
                    end
                end
            end
        end

        -- Jeda antara setiap loop untuk mencari breakable lagi (opsional)
        wait(1)
    end
end

-- Toggle untuk Auto Hit 🎃👻 di Event Tab
EventTab:AddToggle({
    Name = "Auto Hit 🎃👻",
    Default = false,
    Callback = function(Value)
        autoHitAktif = Value
        if autoHitAktif then
            autoHitCoroutine = coroutine.create(autoHitBreakables)
            coroutine.resume(autoHitCoroutine)
        else
            -- Hentikan coroutine jika toggle dimatikan
            if autoHitCoroutine then
                coroutine.yield(autoHitCoroutine)
            end
        end
    end
})



-- Auto 🎃Spooky Pass
EventTab:AddToggle({
    Name = "Auto 🎃Spooky Pass!",
    Default = false,
    Callback = function(value)
        getgenv().autoSpookyPass = value
        if value then
            spawn(function()
                while getgenv().autoSpookyPass do
                    game:GetService("ReplicatedStorage").Packages.Knit.Services.HalloweenCrateService.RF.Roll:InvokeServer()
                    wait(0.1)
                end
            end)
        end
    end
})

-- Section untuk Event Stuff
local EventSection = EventTab:AddSection({
    Name = "Event Stuff"
})

-- Spin Event Summer
local isSpinEventActive = false
local spinEventCoroutine

EventTab:AddToggle({
    Name = "Spin Event Summer",
    Default = false,
    Callback = function(Value)
        isSpinEventActive = Value
        if isSpinEventActive then
            spinEventCoroutine = coroutine.create(function()
                local args = {
                    [1] = "Kraken's Fortune"
                }
                while isSpinEventActive do
                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("SpinnerService"):WaitForChild("RF"):WaitForChild("Spin"):InvokeServer(unpack(args))
                    wait(0.00000000000001) -- Interval waktu antara interaksi (dalam detik, sesuaikan dengan kebutuhan)
                end
            end)
            coroutine.resume(spinEventCoroutine)
        else
            if spinEventCoroutine then
                coroutine.yield(spinEventCoroutine)
            end
        end
    end
})

-- Spin Event Summer x10
local isSpinEventSummerx10Active = false
local spinEventSummerx10Coroutine

EventTab:AddToggle({
    Name = "Spin Event Summer x10",
    Default = false,
    Callback = function(Value)
        isSpinEventSummerx10Active = Value
        if isSpinEventSummerx10Active then
            spinEventSummerx10Coroutine = coroutine.create(function()
                local args = {
                    [1] = "Kraken's Fortune",
                    [2] = "x10"
                }
                while isSpinEventSummerx10Active do
                    game:GetService("ReplicatedStorage").Packages.Knit.Services.SpinnerService.RF.Spin:InvokeServer(unpack(args))
                    wait(0.01) -- Interval waktu antara interaksi (dalam detik, sesuaikan dengan kebutuhan)
                end
            end)
            coroutine.resume(spinEventSummerx10Coroutine)
        else
            if spinEventSummerx10Coroutine then
                coroutine.yield(spinEventSummerx10Coroutine)
            end
        end
    end
})

-- Spin Event Summer x25
local isSpinEventSummerx25Active = false
local spinEventSummerx25Coroutine

EventTab:AddToggle({
    Name = "Spin Event Summer x25",
    Default = false,
    Callback = function(Value)
        isSpinEventSummerx25Active = Value
        if isSpinEventSummerx25Active then
            spinEventSummerx25Coroutine = coroutine.create(function()
                local args = {
                    [1] = "Kraken's Fortune",
                    [2] = "x25"
                }
                while isSpinEventSummerx25Active do
                    game:GetService("ReplicatedStorage").Packages.Knit.Services.SpinnerService.RF.Spin:InvokeServer(unpack(args))
                    wait(0.01) -- Interval waktu antara interaksi (dalam detik, sesuaikan dengan kebutuhan)
                end
            end)
            coroutine.resume(spinEventSummerx25Coroutine)
        else
            if spinEventSummerx25Coroutine then
                coroutine.yield(spinEventSummerx25Coroutine)
            end
        end
    end
})

-- Spin Event Atlantis
local isSpinEventAtlantisActive = false
local spinEventAtlantisCoroutine

EventTab:AddToggle({
    Name = "Spin Event Atlantis",
    Default = false,
    Callback = function(Value)
        isSpinEventAtlantisActive = Value
        if isSpinEventAtlantisActive then
            spinEventAtlantisCoroutine = coroutine.create(function()
                local args = {
                    [1] = "Atlantis Fortune"
                }
                while isSpinEventAtlantisActive do
                    game:GetService("ReplicatedStorage").Packages.Knit.Services.SpinnerService.RF.Spin:InvokeServer(unpack(args))
                    wait(0.01) -- Interval waktu antara interaksi (dalam detik, sesuaikan dengan kebutuhan)
                end
            end)
            coroutine.resume(spinEventAtlantisCoroutine)
        else
            if spinEventAtlantisCoroutine then
                coroutine.yield(spinEventAtlantisCoroutine)
            end
        end
    end
})

-- Spin Event Atlantis x10
local isSpinEventAtlantisx10Active = false
local spinEventAtlantisx10Coroutine

EventTab:AddToggle({
    Name = "Spin Event Atlantis x10",
    Default = false,
    Callback = function(Value)
        isSpinEventAtlantisx10Active = Value
        if isSpinEventAtlantisx10Active then
            spinEventAtlantisx10Coroutine = coroutine.create(function()
                local args = {
                    [1] = "Atlantis Fortune",
                    [2] = "x10"
                }
                while isSpinEventAtlantisx10Active do
                    game:GetService("ReplicatedStorage").Packages.Knit.Services.SpinnerService.RF.Spin:InvokeServer(unpack(args))
                    wait(0.01)
                end
            end)
            coroutine.resume(spinEventAtlantisx10Coroutine)
        else
            if spinEventAtlantisx10Coroutine then
                coroutine.yield(spinEventAtlantisx10Coroutine)
            end
        end
    end
})

-- Spin Event Atlantis x25
local isSpinEventAtlantisx25Active = false
local spinEventAtlantisx25Coroutine

EventTab:AddToggle({
    Name = "Spin Event Atlantis x25",
    Default = false,
    Callback = function(Value)
        isSpinEventAtlantisx25Active = Value
        if isSpinEventAtlantisx25Active then
            spinEventAtlantisx25Coroutine = coroutine.create(function()
                local args = {
                    [1] = "Atlantis Fortune",
                    [2] = "x25"
                }
                while isSpinEventAtlantisx25Active do
                    game:GetService("ReplicatedStorage").Packages.Knit.Services.SpinnerService.RF.Spin:InvokeServer(unpack(args))
                    wait(0.01)
                end
            end)
            coroutine.resume(spinEventAtlantisx25Coroutine)
        else
            if spinEventAtlantisx25Coroutine then
                coroutine.yield(spinEventAtlantisx25Coroutine)
            end
        end
    end
})

-- Tab Other
local OtherTab = Window:MakeTab({
    Name = "Other",
    Icon = "rbxassetid://4483345998", -- Bisa diganti dengan icon yang diinginkan
    PremiumOnly = false
})

local OtherSection = OtherTab:AddSection({
    Name = "Other Stuff"
})

-- Spin Button
OtherTab:AddButton({
    Name = "Spin",
    Callback = function()
        local args = {
            [1] = false
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("SpinService"):WaitForChild("RE"):WaitForChild("onSpinRequest"):FireServer(unpack(args))
    end
})

-- Spin Toggle
OtherTab:AddToggle({
    Name = "Toggle Spin",
    Default = false,
    Callback = function(value)
        getgenv().spin = value
        if value then
            spawn(function()
                while getgenv().spin do
                    local args = {
                        [1] = false
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("SpinService"):WaitForChild("RE"):WaitForChild("onSpinRequest"):FireServer(unpack(args))
                    wait(0.000001) -- Interval waktu antar Spin
                end
            end)
        end
    end
})

-- Auto Buy Trails
OtherTab:AddToggle({
    Name = "Toggle Auto Buy Trails",
    Default = false,
    Callback = function(value)
        getgenv().autoBuyTrails = value
        if value then
            spawn(function()
                while getgenv().autoBuyTrails do
                    local trailsData = game:GetService("ReplicatedStorage").Data.Trails
                    local trailsList = game:GetService("ReplicatedStorage").Trails
                    local playerTrails = game:GetService("Players").LocalPlayer.PlayerGui.GameUI.Menus.CharacterMods.Windows.Trails

                    for _, trail in pairs(trailsList:GetChildren()) do
                        if not trailsData:FindFirstChild(trail.Name) then
                            local args = {
                                [1] = "Trails",
                                [2] = trail.Name
                            }
                            game:GetService("ReplicatedStorage").Packages.Knit.Services.PurchaseService.RE.onPurchaseRequest:FireServer(unpack(args))
                        end
                    end

                    -- Equip the last available trail
                    local lastTrail = playerTrails:GetChildren()[#playerTrails:GetChildren()]
                    if lastTrail then
                        local argsEquip = {
                            [1] = "Trails",
                            [2] = lastTrail.Name
                        }
                        game:GetService("ReplicatedStorage").Packages.Knit.Services.EquipService.RE.equip:FireServer(unpack(argsEquip))
                    end

                    wait(5) -- Interval waktu antar pembelian
                end
            end)
        end
    end
})

-- Auto Roll Auras
OtherTab:AddToggle({
    Name = "Auto Roll Auras",
    Default = false,
    Callback = function(value)
        getgenv().autoRollAuras = value
        if value then
            spawn(function()
                while getgenv().autoRollAuras do
                    game:GetService("ReplicatedStorage").Packages.Knit.Services.AuraService.RF.Roll:InvokeServer()
                    wait(0.0001) -- Interval antar roll
                end
            end)
        end
    end
})

-- Rebirth Section
local RebirthSection = OtherTab:AddSection({
    Name = "Rebirth"
})

-- Rebirth Toggle
local isRebirthActive = false
local rebirthCoroutine

OtherTab:AddToggle({
    Name = "Rebirth",
    Default = false,
    Callback = function(Value)
        isRebirthActive = Value
        if isRebirthActive then
            rebirthCoroutine = coroutine.create(function()
                while isRebirthActive do
                    game:GetService("ReplicatedStorage").Packages.Knit.Services.RebirthService.RE.onRebirthRequest:FireServer()
                    wait(0.1) -- Interval antara setiap request rebirth
                end
            end)
            coroutine.resume(rebirthCoroutine)
        else
            if rebirthCoroutine then
                coroutine.yield(rebirthCoroutine)
            end
        end
    end
})

-- Super Rebirth Toggle
local isSuperRebirthActive = false
local superRebirthCoroutine

OtherTab:AddToggle({
    Name = "Super Rebirth",
    Default = false,
    Callback = function(Value)
        isSuperRebirthActive = Value
        if isSuperRebirthActive then
            superRebirthCoroutine = coroutine.create(function()
                while isSuperRebirthActive do
                    game:GetService("ReplicatedStorage").Packages.Knit.Services.RebirthService.RE.onSuperRebirth:FireServer()
                    wait(1) -- Interval antara setiap request Super Rebirth
                end
            end)
            coroutine.resume(superRebirthCoroutine)
        else
            if superRebirthCoroutine then
                coroutine.yield(superRebirthCoroutine)
            end
        end
    end
})

-- Fungsi untuk mengambil daftar pets dari path yang diberikan
local function getPetList()
    local pets = {}
    
    -- Path pets dari ReplicatedStorage -> Pets -> Normal
    local petFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Pets"):FindFirstChild("Normal")
    
    if petFolder then
        for _, pet in pairs(petFolder:GetChildren()) do
            table.insert(pets, pet.Name) -- Tambahkan nama pet ke dalam daftar
        end
    else
        warn("Folder Pets/Normal tidak ditemukan di ReplicatedStorage")
    end
    
    -- Urutkan pets secara kombinasi angka dan alfabet (1-100, A-Z)
    table.sort(pets, function(a, b)
        local numA, numB = tonumber(a:match("%d+")), tonumber(b:match("%d+"))
        if numA and numB then
            return numA < numB
        elseif numA then
            return true
        elseif numB then
            return false
        else
            return a < b
        end
    end)
    
    return pets
end

-- Inisialisasi daftar pets untuk dropdownOptions
local dropdownOptions = getPetList()

-- Fungsi untuk mengambil daftar pets dari path yang diberikan
local function getPetList()
    local pets = {}
    
    -- Path pets dari ReplicatedStorage -> Pets -> Normal
    local petFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Pets"):FindFirstChild("Normal")
    
    if petFolder then
        for _, pet in pairs(petFolder:GetChildren()) do
            table.insert(pets, pet.Name) -- Tambahkan nama pet ke dalam daftar
        end
    else
        warn("Folder Pets/Normal tidak ditemukan di ReplicatedStorage")
    end
    
    -- Urutkan pets secara kombinasi angka dan alfabet (1-100, A-Z)
    table.sort(pets, function(a, b)
        local numA, numB = tonumber(a:match("%d+")), tonumber(b:match("%d+"))
        if numA and numB then
            return numA < numB
        elseif numA then
            return true
        elseif numB then
            return false
        else
            return a < b
        end
    end)
    
    return pets
end

-- Fungsi untuk mengambil daftar zona secara otomatis
local function getZoneList()
    local zones = {}
    local zoneParent = workspace:FindFirstChild("Zones")
    
    if zoneParent then
        for _, zone in pairs(zoneParent:GetChildren()) do
            table.insert(zones, zone.Name)
        end
        print("Daftar zona ditemukan: ", table.concat(zones, ", ")) -- Debugging
    else
        warn("Zones tidak ditemukan di workspace") -- Jika tidak ada folder Zones
    end

    -- Mengurutkan zona berdasarkan angka dan alfabet
    table.sort(zones, function(a, b)
        local numA, numB = tonumber(a:match("%d+")), tonumber(b:match("%d+"))
        if numA and numB then
            return numA < numB
        elseif numA then
            return true
        elseif numB then
            return false
        else
            return a < b
        end
    end)
    
    -- Pastikan selalu mengembalikan daftar meskipun kosong
    if #zones == 0 then
        warn("Tidak ada zona yang ditemukan.") -- Jika tidak ada zona yang ditemukan
        return {"None"}
    else
        return zones
    end
end

-- Fungsi untuk mengambil daftar eggs dari zona yang dipilih
local function getEggList(zone)
    local eggs = {}
    local zones = workspace:FindFirstChild("Zones")

    if zones then
        local selectedZone = zones:FindFirstChild(zone)
        if selectedZone then
            local eggFolderInteractables = selectedZone:FindFirstChild("Interactables") and selectedZone.Interactables:FindFirstChild("Eggs")
            local eggFolderMap = selectedZone:FindFirstChild("Map") and selectedZone.Map:FindFirstChild("Eggs")
            
            -- Tambahkan debugging untuk memastikan eggs ditemukan
            if eggFolderInteractables then
                for _, egg in pairs(eggFolderInteractables:GetChildren()) do
                    local eggName = egg.Name:gsub(" Egg$", "")
                    table.insert(eggs, eggName)
                    print("Ditemukan egg di Interactables: ", eggName) -- Debugging
                end
            end
            
            if eggFolderMap then
                for _, egg in pairs(eggFolderMap:GetChildren()) do
                    local eggName = egg.Name:gsub(" Egg$", "")
                    table.insert(eggs, eggName)
                    print("Ditemukan egg di Map: ", eggName) -- Debugging
                end
            end

            if #eggs == 0 then
                warn("Tidak ada eggs yang ditemukan di zona: " .. zone)
            end
        else
            warn("Zona yang dipilih tidak ditemukan: " .. tostring(zone))
        end
    else
        warn("Zones tidak ditemukan di workspace")
    end

    -- Urutkan eggs secara kombinasi angka dan alfabet (1-100, A-Z)
    table.sort(eggs, function(a, b)
        local numA, numB = tonumber(a:match("%d+")), tonumber(b:match("%d+"))
        if numA and numB then
            return numA < numB
        elseif numA then
            return true
        elseif numB then
            return false
        else
            return a < b
        end
    end)

    return eggs
end

-- Fungsi untuk memperbarui dropdown egg secara otomatis
local function updateEggDropdown(zone)
    if not zone then
        warn("Zona yang dipilih nil atau tidak valid")
        return
    end

    print("Zona yang dipilih untuk diperbarui: ", zone) -- Debugging

    local eggs = getEggList(zone)
    if eggs and #eggs > 0 then
        print("Dropdown egg diperbarui dengan eggs: ", table.concat(eggs, ", ")) -- Debugging
        
        -- Langsung mengganti opsi dropdown dengan opsi baru
        eggDropdown:SetOptions(eggs) -- Ganti opsi dropdown dengan eggs yang ditemukan
    else
        warn("Tidak ada eggs yang ditemukan untuk dropdown di zona: " .. zone)
        eggDropdown:SetOptions({"None"}) -- Reset ke None jika tidak ada eggs
    end
end

-- Tab Egg
local EggTab = Window:MakeTab({
    Name = "Egg",
    Icon = nil,
    PremiumOnly = false
})

local EggSection = EggTab:AddSection({
    Name = "EGG"
})

-- Fungsi untuk mendapatkan daftar egg dari zona yang dipilih
local function getEggList(zone)
    local eggs = {}
    local zones = workspace:FindFirstChild("Zones")

    if zones then
        local selectedZone = zones:FindFirstChild(zone)
        if selectedZone then
            local eggFolderInteractables = selectedZone:FindFirstChild("Interactables") and selectedZone.Interactables:FindFirstChild("Eggs")
            local eggFolderMap = selectedZone:FindFirstChild("Map") and selectedZone.Map:FindFirstChild("Eggs")
            
            if eggFolderInteractables then
                for _, egg in pairs(eggFolderInteractables:GetChildren()) do
                    local eggName = egg.Name:gsub(" Egg$", "")
                    table.insert(eggs, eggName)
                end
            end
            
            if eggFolderMap then
                for _, egg in pairs(eggFolderMap:GetChildren()) do
                    local eggName = egg.Name:gsub(" Egg$", "")
                    table.insert(eggs, eggName)
                end
            end
        end
    end
    
    table.sort(eggs)
    return eggs
end

-- Fungsi untuk memperbarui dropdown egg berdasarkan zona yang dipilih
local function updateEggDropdown(zone)
    local eggs = getEggList(zone)
    if eggDropdown then
        eggDropdown:Refresh(eggs, "None")
    end
end

-- Fungsi untuk mendapatkan daftar zona
local function getZoneList()
    local zones = {}
    local zoneParent = workspace:FindFirstChild("Zones")
    if zoneParent then
        for _, zone in pairs(zoneParent:GetChildren()) do
            table.insert(zones, zone.Name)
        end
        
        -- Mengurutkan daftar zona
        table.sort(zones, function(a, b)
            if tonumber(a) and tonumber(b) then
                return tonumber(a) < tonumber(b)
            elseif tonumber(a) then
                return true
            elseif tonumber(b) then
                return false
            else
                return a < b
            end
        end)
    end
    return zones
end

-- Inisialisasi dropdown untuk zone selection
local zoneDropdown = nil

zoneDropdown = EggTab:AddDropdown({
    Name = "Select Zone",
    Options = getZoneList(),
    CurrentOption = "None",
    Callback = function(option)
        getgenv().selectedZoneForEgg = option
        updateEggDropdown(option)
    end
})

-- Inisialisasi dropdown untuk egg selection
local eggDropdown = EggTab:AddDropdown({
    Name = "Choose Egg",
    Options = {}, -- Kosong pada awalnya, diisi setelah zona dipilih
    CurrentOption = "None",
    Callback = function(option)
        getgenv().selectedEgg = option
    end
})

-- Dropdown untuk "Hatch Amount"
local hatchAmountDropdown = EggTab:AddDropdown({
    Name = "Hatch Amount",
    Options = {"1", "3", "8"},
    CurrentOption = "1",
    Callback = function(option)
        getgenv().hatchAmount = tonumber(option)
    end
})

-- Auto Hatch Toggle
local autoHatchToggle = EggTab:AddToggle({
    Name = "Auto Hatch",
    Default = false,
    Callback = function(value)
        getgenv().autoHatch = value
        if value then
            startAutoHatch()
        end
    end
})

-- Fungsi untuk memulai auto hatching
function startAutoHatch()
    spawn(function()
        while getgenv().autoHatch do
            if not getgenv().selectedEgg or not getgenv().hatchAmount then
                return
            end

            local args = {
                [1] = getgenv().selectedEgg,
                [4] = getgenv().hatchAmount > 1
            }
            game:GetService("ReplicatedStorage").Packages.Knit.Services.EggService.RF.purchaseEgg:InvokeServer(unpack(args))
            wait(1) -- Waktu tunggu antar hatching
        end
    end)
end


-- Fungsi untuk mengatur Egg Animation
local function toggleEggAnimation(value)
    if value then
        -- Logic untuk menyalakan animasi egg
        print("Egg animation diaktifkan.")
    else
        -- Logic untuk mematikan animasi egg
        print("Egg animation dimatikan.")
    end
end

-- Toggle untuk mengaktifkan atau menonaktifkan Egg Animation
EggTab:AddToggle({
    Name = "Egg Animation",
    CurrentValue = false,
    Callback = function(value)
        toggleEggAnimation(value) -- Panggil fungsi untuk mengatur animasi
    end
})


OrionLib:Init()