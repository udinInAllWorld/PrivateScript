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


-- Daftar CFrame / Posisi yang diberikan
local positions = {
    CFrame.new(1305.81079, 5.93187714, -8554.60645, 0.945518553, 0, -0.325568169, 0, 1, 0, 0.325568169, 0, 0.945518553),
    CFrame.new(1325.74097, 5.93187714, -8501.61523, 0.992546201, 0, -0.121869117, 0, 1, 0, 0.121869117, 0, 0.992546201),
    CFrame.new(1358.74084, 5.93187714, -8475.31641, 0.587785363, 0, -0.809016943, 0, 1, 0, 0.809016943, 0, 0.587785363),
    CFrame.new(1272.11084, 5.93187714, -8611.42676, -0.945518613, 0, -0.32556811, 0, 1, 0, 0.32556811, 0, -0.945518613),
    CFrame.new(1270.54102, 5.93187714, -8475.81543, 0.838670492, 0, 0.544639111, 0, 1, 0, -0.544639111, 0, 0.838670492),
    CFrame.new(1202.31091, 5.93187714, -8482.39648, -0.104528464, 0, 0.994521916, 0, 1, 0, -0.994521916, 0, -0.104528464),
    CFrame.new(1077.69092, 5.93187714, -8497.17676, 0.99984771, 0, 0.0174523201, 0, 1, 0, -0.0174523201, 0, 0.99984771),
    CFrame.new(1182.87097, 32.4535561, -8652.02637, 0.587785065, 0, -0.809017122, 0, 1, 0, 0.809017122, 0, 0.587785065),
    CFrame.new(1088.44092, 32.8218765, -8668.17578, -0.190808997, 0, 0.981627166, 0, 1, 0, -0.981627166, 0, -0.190808997),
    CFrame.new(1253.84094, 32.8218765, -8668.17578, -0.681998312, 0, -0.73135376, 0, 1, 0, 0.73135376, 0, -0.681998312),
    CFrame.new(1317.04089, 32.8218765, -8668.17578, 0.819152117, 0, -0.573576331, 0, 1, 0, 0.573576331, 0, 0.819152117),
    CFrame.new(1028.46106, 5.93187714, -8408.5752, 0.656059086, 0, -0.754709542, 0, 1, 0, 0.754709542, 0, 0.656059086),
    CFrame.new(928.350952, 6.27187729, -8391.22656, -0.292371601, 0, -0.956304789, 0, 1, 0, 0.956304789, 0, -0.292371601),
    CFrame.new(845.140991, 5.93187714, -8303.21582, -0.74314487, 0, 0.669130564, 0, 1, 0, -0.669130564, 0, -0.74314487),
    CFrame.new(837.921021, 5.56355762, -8213.38574, -0.997564077, 0, 0.0697564706, 0, 1, 0, -0.0697564706, 0, -0.997564077),
    CFrame.new(889.140991, 5.56355762, -8186.61621, 0.945518553, 0, 0.32556814, 0, 1, 0, -0.32556814, 0, 0.945518553),
    CFrame.new(942.95105, 5.93187714, -8213.38574, -0.990268052, 0, -0.139173076, 0, 1, 0, 0.139173076, 0, -0.990268052),
    CFrame.new(985.540955, 5.93187714, -8257.41602, -0.848048091, 0, 0.529919267, 0, 1, 0, -0.529919267, 0, -0.848048091),
    CFrame.new(1061.67102, 5.93187714, -8337.45605, -0.913545489, 0, 0.406736612, 0, 1, 0, -0.406736612, 0, -0.913545489),
    CFrame.new(1179.95093, 32.8718796, -8274.02637, -0.978147626, 0, 0.207911655, 0, 1, 0, -0.207911655, 0, -0.978147626),
    CFrame.new(1438.08118, 34.4018784, -8022.81592, 0.0697563812, 0, 0.997564077, 0, 1, 0, -0.997564077, 0, 0.0697563812)
}

-- Fungsi untuk menghentikan Auto Hit
local function stopAutoHit()
    getgenv().autoHitActive = false
end

-- Fungsi untuk memulai Auto Hit di setiap posisi
local function autoHitBreakablesWithPositions()
    while getgenv().autoHitActive do
        for _, pos in ipairs(positions) do
            if not getgenv().autoHitActive then return end -- Hentikan jika toggle dimatikan

            -- Teleport ke posisi
            local player = game.Players.LocalPlayer
            local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

            if humanoidRootPart then
                humanoidRootPart.CFrame = pos
                wait(0.5) -- Tunggu sebentar setelah teleport

                -- Serang semua objek di sekitar posisi
                for _, obj in pairs(workspace.GameObjects.Breakables:GetChildren()) do
                    if (obj.Position - pos.Position).Magnitude < 10 then
                        local args = { [1] = obj.Name }
                        while getgenv().autoHitActive and workspace.GameObjects.Breakables:FindFirstChild(obj.Name) do
                            game:GetService("ReplicatedStorage").Packages.Knit.Services.BreakableService.RF.HitBreakable:InvokeServer(unpack(args))
                            wait(0.000000001) -- Interval antar hit
                        end
                    end
                end
            end
        end

        wait(1) -- Tunggu sebelum memulai loop lagi
    end
end

-- Menambahkan Toggle untuk mengaktifkan atau mematikan Auto Hit 🎃👻
EventTab:AddToggle({
    Name = "Auto Hit 🎃👻",
    Default = false,
    Callback = function(value)
        getgenv().autoHitActive = value
        if value then
            spawn(autoHitBreakablesWithPositions) -- Jalankan fungsi Auto Hit
        else
            stopAutoHit() -- Hentikan fungsi Auto Hit
        end
    end
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

-- Auto Spooky Pass
EventTab:AddToggle({
    Name = "Auto Spooky Pass!",
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

-- Membuat Tab Egg
local EggTab = Window:MakeTab({
    Name = "Egg",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Section untuk Egg Hatching
local EggSection = EggTab:AddSection({
    Name = "Egg Hatching"
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
                    local eggName = egg.Name:gsub(" Egg$", "") -- Hilangkan "Egg" dari nama
                    table.insert(eggs, eggName)
                end
            end

            if eggFolderMap then
                for _, egg in pairs(eggFolderMap:GetChildren()) do
                    local eggName = egg.Name:gsub(" Egg$", "") -- Hilangkan "Egg" dari nama
                    table.insert(eggs, eggName)
                end
            end
        end
    end

    -- Jika tidak ada egg yang ditemukan, tambahkan nilai default
    if #eggs == 0 then
        warn("Tidak ada egg yang ditemukan di zona: " .. (zone or "unknown"))
        table.insert(eggs, "Tidak ada Egg") -- Default value
    end

    return eggs
end

-- Fungsi untuk mendapatkan daftar zona
local function getZoneList()
    local zones = {}
    local zoneParent = workspace:FindFirstChild("Zones")

    if zoneParent then
        for _, zone in pairs(zoneParent:GetChildren()) do
            table.insert(zones, zone.Name)
        end

        -- Urutkan zona berdasarkan angka atau alfabetis
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

-- Fungsi untuk mendapatkan daftar pets
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

-- Mendapatkan zona dan egg pertama secara default
getgenv().selectedZoneForEgg = getZoneList()[1] -- Zona pertama
local eggOptions = getEggList(getgenv().selectedZoneForEgg)
if eggOptions and #eggOptions > 0 then
    getgenv().selectedEgg = eggOptions[1]
else
    getgenv().selectedEgg = "Tidak ada Egg"
end

-- Variabel untuk eggDropdown
local eggDropdown = nil

-- Dropdown untuk memilih zona
local zoneDropdown = EggSection:AddDropdown({
    Name = "Select Zone",
    Default = getgenv().selectedZoneForEgg,
    Options = getZoneList(),
    Callback = function(option)
        getgenv().selectedZoneForEgg = option
        local eggOptions = getEggList(option)
        if eggOptions and #eggOptions > 0 then
            getgenv().selectedEgg = eggOptions[1]
        else
            getgenv().selectedEgg = "Tidak ada Egg"
        end

        -- Pastikan dropdown egg tersedia sebelum refresh
        if eggDropdown then
            eggDropdown:Refresh(eggOptions, getgenv().selectedEgg)
        else
            warn("eggDropdown tidak tersedia saat ini.")
        end
    end
})

-- Dropdown untuk memilih egg
eggDropdown = EggSection:AddDropdown({
    Name = "Choose Egg",
    Default = getgenv().selectedEgg,
    Options = eggOptions,
    Callback = function(option)
        -- Hilangkan "Egg" di akhir nama jika ada
        getgenv().selectedEgg = option:gsub("Egg$", "")
        print("Egg dipilih: " .. getgenv().selectedEgg) -- Debugging
    end
})

-- Dropdown Jumlah Hatch
EggSection:AddDropdown({
    Name = "Jumlah Hatch",
    Default = "1",
    Options = { "1", "3", "8" },
    Callback = function(option)
        getgenv().hatchAmount = tonumber(option)
    end
})

-- Fungsi Auto Hatch (menggunakan egg tanpa "Egg" di akhir)
local function autoHatch()
    while getgenv().autoHatch do
        if getgenv().selectedEgg and getgenv().selectedEgg ~= "None" then
            local args = {
                [1] = getgenv().selectedEgg, -- Nama egg tanpa "Egg"
                [4] = false
            }
            game:GetService("ReplicatedStorage").Packages.Knit.Services.EggService.RF.purchaseEgg:InvokeServer(unpack(args))
            wait(0.51)
        else
            warn("Silakan pilih egg terlebih dahulu!")
        end
    end
end

-- Toggle Auto Hatch
EggSection:AddToggle({
    Name = "Auto Hatch",
    Default = false,
    Callback = function(Value)
        getgenv().autoHatch = Value
        if Value then spawn(autoHatch) end
    end
})

-- Daftar pets
local petList = getPetList()

-- Fungsi untuk menghapus pets otomatis
local function autoDeletePet(petName)
    local args = { [1] = petName }
    game:GetService("ReplicatedStorage").Packages.Knit.Services.PetService.RF.SetAutoDelete:InvokeServer(unpack(args))
end

-- Fungsi untuk mereset pilihan hanya pada dropdown yang ditentukan
local function resetSpecificAutoDeletePets(selectedPets)
    for _, pet in ipairs(selectedPets) do
        local args = { [1] = pet }
        game:GetService("ReplicatedStorage").Packages.Knit.Services.PetService.RF.SetAutoDelete:InvokeServer(unpack(args))
    end

    -- Kosongkan daftar pets yang dipilih untuk dropdown spesifik tanpa mempengaruhi opsi dropdown
    for i = #selectedPets, 1, -1 do
        table.remove(selectedPets, i)
    end
end

-- Variabel untuk menyimpan pets yang dipilih
getgenv().autoDeletePetsDropdown1 = {}

-- Dropdown pertama
local autoDeletePetsDropdown1 = EggSection:AddDropdown({
    Name = "Pilih Pets untuk Dihapus (Dropdown 1)",
    Default = "",  -- Awalnya kosong
    Options = petList,
    Callback = function(option)
        -- Tambahkan pet yang dipilih ke dalam daftar
        if not table.find(getgenv().autoDeletePetsDropdown1, option) then
            table.insert(getgenv().autoDeletePetsDropdown1, option)
            autoDeletePet(option) -- Jalankan fungsi auto-delete
            print("Pet ditambahkan untuk dihapus: " .. option)
        end
    end
})

-- Tombol reset untuk dropdown 1
EggSection:AddButton({
    Name = "Batalkan Semua Pilihan Pets (Dropdown 1)",
    Callback = function()
        resetSpecificAutoDeletePets(getgenv().autoDeletePetsDropdown1)
        print("All pet selections have been reset for dropdown 1.")
    end
})

-- Variabel untuk menyimpan pilihan pets dari dropdown kedua
getgenv().autoDeletePetsDropdown2 = {}

-- Dropdown kedua
local autoDeletePetsDropdown2 = EggSection:AddDropdown({
    Name = "Pilih Pets untuk Dihapus (Dropdown 2)",
    Default = "",  -- Awalnya kosong
    Options = petList,
    Callback = function(option)
        -- Tambahkan pet yang dipilih ke dalam daftar
        if not table.find(getgenv().autoDeletePetsDropdown2, option) then
            table.insert(getgenv().autoDeletePetsDropdown2, option)
            autoDeletePet(option) -- Jalankan fungsi auto-delete
            print("Pet ditambahkan untuk dihapus: " .. option)
        end
    end
})

-- Tombol reset untuk dropdown 2
EggSection:AddButton({
    Name = "Batalkan Semua Pilihan Pets (Dropdown 2)",
    Callback = function()
        resetSpecificAutoDeletePets(getgenv().autoDeletePetsDropdown2)
        print("All pet selections have been reset for dropdown 2.")
    end
})

-- Variabel untuk menyimpan pets yang dipilih
getgenv().autoDeletePetsDropdown3 = {}

-- Dropdown pertama
local autoDeletePetsDropdown3 = EggSection:AddDropdown({
    Name = "Pilih Pets untuk Dihapus (Dropdown 3)",
    Default = "",  -- Awalnya kosong
    Options = petList,
    Callback = function(option)
        -- Tambahkan pet yang dipilih ke dalam daftar
        if not table.find(getgenv().autoDeletePetsDropdown3, option) then
            table.insert(getgenv().autoDeletePetsDropdown3, option)
            autoDeletePet(option) -- Jalankan fungsi auto-delete
            print("Pet ditambahkan untuk dihapus: " .. option)
        end
    end
})

-- Tombol reset untuk dropdown 3
EggSection:AddButton({
    Name = "Batalkan Semua Pilihan Pets (Dropdown 3)",
    Callback = function()
        resetSpecificAutoDeletePets(getgenv().autoDeletePetsDropdown3)
        print("All pet selections have been reset for dropdown 3.")
    end
})

-- Variabel untuk menyimpan pets yang dipilih
getgenv().autoDeletePetsDropdown4 = {}

-- Dropdown pertama
local autoDeletePetsDropdown4 = EggSection:AddDropdown({
    Name = "Pilih Pets untuk Dihapus (Dropdown 4)",
    Default = "",  -- Awalnya kosong
    Options = petList,
    Callback = function(option)
        -- Tambahkan pet yang dipilih ke dalam daftar
        if not table.find(getgenv().autoDeletePetsDropdown4, option) then
            table.insert(getgenv().autoDeletePetsDropdown4, option)
            autoDeletePet(option) -- Jalankan fungsi auto-delete
            print("Pet ditambahkan untuk dihapus: " .. option)
        end
    end
})

-- Tombol reset untuk dropdown 4
EggSection:AddButton({
    Name = "Batalkan Semua Pilihan Pets (Dropdown 4)",
    Callback = function()
        resetSpecificAutoDeletePets(getgenv().autoDeletePetsDropdown4)
        print("All pet selections have been reset for dropdown 4.")
    end
})

-- Variabel untuk menyimpan pets yang dipilih
getgenv().autoDeletePetsDropdown5 = {}

-- Dropdown pertama
local autoDeletePetsDropdown5 = EggSection:AddDropdown({
    Name = "Pilih Pets untuk Dihapus (Dropdown 5)",
    Default = "",  -- Awalnya kosong
    Options = petList,
    Callback = function(option)
        -- Tambahkan pet yang dipilih ke dalam daftar
        if not table.find(getgenv().autoDeletePetsDropdown5, option) then
            table.insert(getgenv().autoDeletePetsDropdown5, option)
            autoDeletePet(option) -- Jalankan fungsi auto-delete
            print("Pet ditambahkan untuk dihapus: " .. option)
        end
    end
})

-- Tombol reset untuk dropdown 5
EggSection:AddButton({
    Name = "Batalkan Semua Pilihan Pets (Dropdown 5)",
    Callback = function()
        resetSpecificAutoDeletePets(getgenv().autoDeletePetsDropdown5)
        print("All pet selections have been reset for dropdown 5.")
    end
})

-- Variabel untuk menyimpan pets yang dipilih
getgenv().autoDeletePetsDropdown6 = {}

-- Dropdown pertama
local autoDeletePetsDropdown6 = EggSection:AddDropdown({
    Name = "Pilih Pets untuk Dihapus (Dropdown 6)",
    Default = "",  -- Awalnya kosong
    Options = petList,
    Callback = function(option)
        -- Tambahkan pet yang dipilih ke dalam daftar
        if not table.find(getgenv().autoDeletePetsDropdown6, option) then
            table.insert(getgenv().autoDeletePetsDropdown6, option)
            autoDeletePet(option) -- Jalankan fungsi auto-delete
            print("Pet ditambahkan untuk dihapus: " .. option)
        end
    end
})

-- Tombol reset untuk dropdown 6
EggSection:AddButton({
    Name = "Batalkan Semua Pilihan Pets (Dropdown 6)",
    Callback = function()
        resetSpecificAutoDeletePets(getgenv().autoDeletePetsDropdown6)
        print("All pet selections have been reset for dropdown 6.")
    end
})

-- Variabel untuk menyimpan status GUI Enchant dan Double Enchant
local isEnchantOpen = false
local isDoubleEnchantOpen = false

-- Fungsi untuk membuka/tutup GUI Enchant
local function toggleEnchantGUI()
    local enchantGUI = game:GetService("Players").LocalPlayer.PlayerGui.GameUI.Menus:FindFirstChild("Enchant")
    if enchantGUI then
        isEnchantOpen = not isEnchantOpen
        enchantGUI.Visible = isEnchantOpen
    else
        warn("GUI Enchant tidak ditemukan!")
    end
end

-- Fungsi untuk membuka/tutup GUI Double Enchant
local function toggleDoubleEnchantGUI()
    local doubleEnchantGUI = game:GetService("Players").LocalPlayer.PlayerGui.GameUI.Menus.Enchant:FindFirstChild("DoubleEnchants")
    if doubleEnchantGUI then
        isDoubleEnchantOpen = not isDoubleEnchantOpen
        doubleEnchantGUI.Visible = isDoubleEnchantOpen
    else
        warn("GUI Double Enchant tidak ditemukan!")
    end
end

-- Tambahkan Tab Enchant
local EnchantTab = Window:MakeTab({
    Name = "Enchant",
    Icon = "rbxassetid://4483345998", -- Sesuaikan ikon
    PremiumOnly = false
})

-- Tambahkan Tombol Enchant di Tab Enchant
EnchantTab:AddButton({
    Name = "Toggle Enchant",
    Callback = function()
        toggleEnchantGUI()
    end
})

-- Tambahkan Tombol Double Enchant di Tab Enchant
EnchantTab:AddButton({
    Name = "Toggle Double Enchant",
    Callback = function()
        toggleDoubleEnchantGUI()
    end
})


OrionLib:Init()