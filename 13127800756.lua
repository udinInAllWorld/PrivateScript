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

local OtherSection = OtherTab:AddSection({
    Name = "Garden"
})

-- Variabel Global untuk Auto Gardening
getgenv().AutoGarden = false
getgenv().AutoUpgradeSnacks = false

-- Fungsi untuk mendapatkan daftar seed dengan nama "/1"
local function getSeedList()
    local seedList = {}
    local seedsStorage = game:GetService("Players").LocalPlayer.PlayerGui.GameUI.Menus.Seeds.Display.Items.MainFrame.ScrollingFrame

    for _, seed in pairs(seedsStorage:GetChildren()) do
        if seed.Name:match("/1") then
            local seedName = seed.Name:match("([^/]+)") -- Mendapatkan nama seed tanpa "/1"
            table.insert(seedList, seedName)
        end
    end

    return seedList
end

-- Daftar seeds yang diperoleh secara otomatis
local seedList = getSeedList()

-- Fungsi untuk melakukan auto gardening
local function autoGarden()
    local harvestArgsList = {1, 2, 3, 4, 5, 6}

    while getgenv().AutoGarden do
        -- Melakukan Harvest
        for _, id in ipairs(harvestArgsList) do
            local success, err = pcall(function()
                local args = {[1] = tostring(id)}
                game:GetService("ReplicatedStorage").Packages.Knit.Services.ItemPlantingService.RF.Harvest:InvokeServer(unpack(args))
            end)
            if not success then
                warn("Error memanen item dengan ID:", id, "Error:", err)
            end
        end
        wait(0.00000000000001) -- Sesuaikan interval

        -- Melakukan Penanaman
        for _, seed in ipairs(seedList) do
            for i = 1, 6 do
                local success, err = pcall(function()
                    local plantArgs = {seed, tostring(1), tostring(i)}
                    game:GetService("ReplicatedStorage").Packages.Knit.Services.ItemPlantingService.RF.Plant:InvokeServer(unpack(plantArgs))
                end)
                if not success then
                    warn("Error menanam item:", seed, "di slot:", i, "Error:", err)
                end
            end
        end
        wait(0.00000000000001) -- Sesuaikan interval
    end
end

-- Menambahkan toggle Auto Garden ke UI
OtherSection:AddToggle({
    Name = "Auto Garden",
    Default = false,
    Callback = function(Value)
        getgenv().AutoGarden = Value
        if Value then
            spawn(autoGarden)
        end
    end
})

-- Fungsi untuk mendapatkan daftar snack
local function getSnackList()
    local snackList = {}
    local snacksStorage = game:GetService("Players").LocalPlayer.PlayerGui.GameUI.Menus.ItemCrafting.Logic.List.ScrollingFrame

    for _, snack in pairs(snacksStorage:GetChildren()) do
        if snack.Name:match("/1") then
            local snackName = snack.Name:match("([^/]+)") -- Mengambil nama snack tanpa "/1"
            table.insert(snackList, snackName)
        end
    end

    return snackList
end

-- Daftar snack yang diperoleh secara otomatis
local snackList = getSnackList()

-- Fungsi untuk melakukan auto upgrade snack
local function autoUpgradeSnacks()
    local tierList = {1, 2}

    while getgenv().AutoUpgradeSnacks do
        local coroutines = {}
        for _, snack in ipairs(snackList) do
            for _, tier in ipairs(tierList) do
                table.insert(coroutines, coroutine.create(function()
                    local args = {
                        {
                            ["Item"] = snack,
                            ["Tier"] = tier
                        }
                    }
                    local success, err = pcall(function()
                        game:GetService("ReplicatedStorage").Packages.Knit.Services.ItemCraftingService.RF.UpgradeSnack:InvokeServer(unpack(args))
                    end)
                    if not success then
                        warn("Error upgrade snack:", snack, "ke tier:", tier, "Error:", err)
                    end
                end))
            end
        end
        
        -- Jalankan semua coroutine
        for _, co in ipairs(coroutines) do
            coroutine.resume(co)
        end

        wait(0.0000001) -- Sesuaikan interval
    end
end

-- Menambahkan toggle Auto Upgrade Snacks ke UI
OtherSection:AddToggle({
    Name = "Auto Upgrade Snacks",
    Default = false,
    Callback = function(Value)
        getgenv().AutoUpgradeSnacks = Value
        if Value then
            spawn(autoUpgradeSnacks)
        end
    end
})

-- Membuat Tab untuk Teleport
local TeleportTab = Window:MakeTab({
    Name = "Teleport",
    Icon = "rbxassetid://4483345998", -- Ikon Tab (bisa diubah sesuai kebutuhan)
    PremiumOnly = false
})

-- Membuat Section untuk Teleport
local TeleportSection = TeleportTab:AddSection({
    Name = "Teleportasi"
})

-- Fungsi untuk teleportasi ke zona menggunakan ZoneService
local function teleportToZone(zoneName)
    local zone = workspace.Zones:FindFirstChild(zoneName)
    if zone and zone.Interactables and zone.Interactables.Teleports and zone.Interactables.Teleports.Locations then
        local args = {
            [1] = zone.Interactables.Teleports.Locations.Spawn
        }
        game:GetService("ReplicatedStorage").Packages.Knit.Services.ZoneService.RE.teleport:FireServer(unpack(args))
    end
end

-- Fungsi untuk mendapatkan daftar zona dan mengurutkannya
local function getZoneList()
    local zones = {}
    local zoneParent = workspace:FindFirstChild("Zones")
    if zoneParent then
        for _, zone in pairs(zoneParent:GetChildren()) do
            table.insert(zones, zone.Name)
        end
        
        -- Mengurutkan daftar zona berdasarkan angka atau nama
        table.sort(zones, function(a, b)
            local numA = tonumber(a:match("%d+")) or math.huge
            local numB = tonumber(b:match("%d+")) or math.huge
            if numA == numB then
                return a < b
            else
                return numA < numB
            end
        end)
    end
    return zones
end

-- Fungsi untuk membuat tombol teleportasi ke zona
local function createTeleportButtons()
    local zoneNames = getZoneList()

    for _, zoneName in ipairs(zoneNames) do
        TeleportSection:AddButton({
            Name = "Teleport Ke " .. zoneName,
            Callback = function()
                teleportToZone(zoneName)
            end
        })
    end
end

-- Membuat tombol teleportasi saat script dijalankan
createTeleportButtons()

-- Menambahkan event listener untuk memperbarui tombol jika ada zona baru yang ditambahkan
workspace.Zones.ChildAdded:Connect(function()
    TeleportSection:Clear() -- Menghapus tombol sebelumnya
    createTeleportButtons()  -- Membuat ulang tombol
end)

workspace.Zones.ChildRemoved:Connect(function()
    TeleportSection:Clear() -- Menghapus tombol sebelumnya
    createTeleportButtons()  -- Membuat ulang tombol
end)

-- Menambahkan Dropdown untuk teleportasi
local selectedZone = "None"

local zoneDropdown = TeleportSection:AddDropdown({
    Name = "Pilih Zona",
    Default = "None",
    Options = getZoneList(),
    Callback = function(Value)
        selectedZone = Value
    end
})

-- Tombol untuk teleportasi ke zona yang dipilih dari dropdown
TeleportSection:AddButton({
    Name = "Teleport Ke Zona",
    Callback = function()
        if selectedZone ~= "None" then
            teleportToZone(selectedZone)
        else
            warn("Silakan pilih zona untuk teleportasi")
        end
    end
})


-- Membuat Tab untuk Egg
local EggTab = Window:MakeTab({
    Name = "Egg",
    Icon = "rbxassetid://4483345998", -- Ikon Tab (bisa diubah sesuai kebutuhan)
    PremiumOnly = false
})

-- Membuat Section untuk Egg
local EggSection = EggTab:AddSection({
    Name = "Egg Hatching"
})

-- Fungsi untuk mendapatkan daftar egg dari zona yang dipilih secara otomatis
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
    
    if #eggs == 0 then
        print("Tidak ada egg yang ditemukan di zona: " .. zone)
        table.insert(eggs, "Tidak ada Egg")
    end
    
    return eggs
end

-- Fungsi untuk mendapatkan daftar zona
local function getZoneList()
    local zones = {}
    local zoneParent = workspace:FindFirstChild("Zones")
    if zoneParent then
        for _, zone in pairs(zoneParent:GetChildren()) do
            print("Zona ditemukan: " .. zone.Name) -- Debugging
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
    else
        warn("Tidak ada Zones ditemukan di workspace.")
    end
    
    if #zones == 0 then
        table.insert(zones, "Tidak ada Zona")
    end
    
    return zones
end

-- Mendapatkan daftar zona dan egg secara otomatis
getgenv().selectedZoneForEgg = getZoneList()[1] -- Zona pertama secara default
getgenv().selectedEgg = getEggList(getgenv().selectedZoneForEgg)[1] -- Egg pertama dari zona terpilih

-- Inisialisasi variabel untuk eggDropdown
local eggDropdown = nil

-- Dropdown untuk memilih zona
local zoneDropdown = EggSection:AddDropdown({
    Name = "Select Zone",
    Default = getgenv().selectedZoneForEgg,
    Options = getZoneList(),
    Callback = function(option)
        getgenv().selectedZoneForEgg = option
        local eggOptions = getEggList(option)
        getgenv().selectedEgg = eggOptions[1] -- Pilih egg pertama saat zona berubah

        -- Hanya memanggil Refresh jika eggDropdown sudah terbuat
        if eggDropdown then
            eggDropdown:Refresh(eggOptions, getgenv().selectedEgg)
        else
            warn("eggDropdown tidak tersedia saat ini.")
        end
    end
})

-- Inisialisasi eggDropdown setelah zona dipilih pertama kali
local eggOptions = getEggList(getgenv().selectedZoneForEgg)
eggDropdown = EggSection:AddDropdown({
    Name = "Choose Egg",
    Default = getgenv().selectedEgg,
    Options = eggOptions,
    Callback = function(option)
        getgenv().selectedEgg = option
        print("Egg dipilih: " .. option) -- Debugging, untuk memastikan egg dipilih
    end
})

-- Dropdown untuk memilih jumlah egg yang di-hatch
local hatchAmountDropdown = EggSection:AddDropdown({
    Name = "Hatch Amount",
    Default = "1",
    Options = {"1", "3", "8"},
    Callback = function(option)
        getgenv().hatchAmount = tonumber(option)
    end
})

-- Fungsi untuk Auto Hatch
local function autoHatch()
    while getgenv().autoHatch do
        if getgenv().selectedEgg and getgenv().hatchAmount then
            local args
            if getgenv().hatchAmount == 1 then
                args = {
                    [1] = getgenv().selectedEgg,
                    [2] = {},
                    [4] = false
                }
            elseif getgenv().hatchAmount == 3 then
                args = {
                    [1] = getgenv().selectedEgg,
                    [2] = {},
                    [4] = true
                }
            elseif getgenv().hatchAmount == 8 then
                args = {
                    [1] = getgenv().selectedEgg,
                    [2] = {},
                    [4] = true,
                    [5] = true
                }
            end
            game:GetService("ReplicatedStorage").Packages.Knit.Services.EggService.RF.purchaseEgg:InvokeServer(unpack(args))
            wait(0.5) -- Jeda antar hatch, sesuaikan sesuai kebutuhan
        else
            warn("Egg atau jumlah hatch belum dipilih!")
        end
        wait(0.5)
    end
end

-- Menambahkan toggle untuk Auto Hatch ke UI
EggSection:AddToggle({
    Name = "Auto Hatch",
    Default = false,
    Callback = function(Value)
        getgenv().autoHatch = Value
        if Value then
            spawn(autoHatch)
        end
    end
})

-- Fungsi untuk mendapatkan daftar pets yang akan dihapus
local function getPetList()
    local pets = {}
    local petFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Pets") and game:GetService("ReplicatedStorage").Pets:FindFirstChild("Normal")
    
    if petFolder then
        for _, pet in pairs(petFolder:GetChildren()) do
            table.insert(pets, pet.Name)
        end
    end
    
    table.sort(pets)
    return pets
end

-- Mengisi daftar pets secara otomatis
getgenv().autoDeletePets = getPetList() -- Secara otomatis mengisi daftar pets yang bisa dihapus

-- Fungsi untuk Auto Delete Pets
local function autoDeletePets()
    while getgenv().autoDeletePetsEnabled do
        for _, petName in pairs(getgenv().autoDeletePets) do
            local args = {
                [1] = petName
            }
            game:GetService("ReplicatedStorage").Packages.Knit.Services.EggService.RE.changeDeleteState:FireServer(unpack(args))
        end
        wait(0.5) -- Sesuaikan jeda waktu
    end
end

-- Dropdown untuk memilih pets yang akan dihapus
local selectedPetToDelete = getgenv().autoDeletePets[1] or "Tidak ada Pets"

local autoDeletePetsDropdown = EggSection:AddDropdown({
    Name = "Select Delete Pets",
    Default = selectedPetToDelete,
    Options = getPetList(),
    Callback = function(option)
        selectedPetToDelete = option
        print("Pet dipilih untuk dihapus: " .. option)
    end
})

-- Tombol untuk membatalkan pilihan pet
EggSection:AddButton({
    Name = "Cancel Delete Pets",
    Callback = function()
        selectedPetToDelete = "Tidak ada Pets"
        autoDeletePetsDropdown:Refresh(getPetList(), selectedPetToDelete)
        print("Pilihan pet dibatalkan.")
    end
})

-- Menambahkan toggle untuk Auto Delete Pets
EggSection:AddToggle({
    Name = "Auto Delete Pets",
    Default = false,
    Callback = function(Value)
        getgenv().autoDeletePetsEnabled = Value
        if Value then
            spawn(autoDeletePets)
        end
    end
})


OrionLib:Init()