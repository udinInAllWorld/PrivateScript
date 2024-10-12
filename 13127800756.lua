local ArrayField = loadstring(game:HttpGet("https://raw.githubusercontent.com/Enzo-YTscript/Ui-Library/main/ArrayfieldLibraryUI"))()

local Window = ArrayField:CreateWindow({
    Name = "Arm Wrestle",
    LoadingTitle = "SUBSCRIBE ENZO-YT",
    LoadingSubtitle = "by ENZO-YT",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = nil,
        FileName = "Enzo-YT Script"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
        Title = "Arm Wrestle",
        Subtitle = "Key System",
        Note = "Key In Description",
        FileName = "NinjaLegendsKeyEnzoYT",
        SaveKey = false,
        GrabKeyFromSite = true,
        Key = {"https://pastebin.com/raw/iJCXgQGb"},
        Actions = {
            [1] = {
                Text = 'Click here to copy the key link',
                OnPress = function()
                end,
            }
        },
    }
})

---Rejoin
game:GetService("GuiService").ErrorMessageChanged:Connect(function()
wait (0.1) game:GetService("TeleportService"):Teleport(game.PlaceId)
    end);

-- Anti Afk
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
    vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    wait(1)
    vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

--- MAIN TAB    
local TabMain = Window:CreateTab("HOME", nil) -- Title, Image
local SectionMain = TabMain:CreateSection("Farm",false)

local isClaiming = false
local claimCoroutine

local Toggle = TabMain:CreateToggle({
    Name = "Auto Claim Gift",
    SectionParent = SectionMain,
    CurrentValue = false,
    Callback = function(v)
        isClaiming = v
        if isClaiming then
            claimCoroutine = coroutine.create(function()
                while isClaiming do
                    for i = 1, 12 do
                        if not isClaiming then
                            return
                        end
                        local args = {[1] = i}
                        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("TimedRewardService"):WaitForChild("RE"):WaitForChild("onClaim"):FireServer(unpack(args))
                        wait(0.01)
                    end
                end
            end)
            coroutine.resume(claimCoroutine)
        else
            -- Stop the coroutine when the toggle is turned off
            isClaiming = false
            if claimCoroutine then
                coroutine.yield(claimCoroutine)
            end
        end
    end,
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
    npcDropdown = TabMain:CreateDropdown({
        Name = "Select NPC",
        SectionParent = SectionMain,
        Options = getNPCList(),
        CurrentOption = "None",
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
local AutoFarmToggle = TabMain:CreateToggle({
    Name = "Start Farming",
    SectionParent = SectionMain,
    CurrentValue = false,
    Callback = function(Value)
        getgenv().AutoFarm = Value
        if Value then
            autoFarm()
        end
    end
})

-- Menambahkan toggle untuk Auto Tap NPC ke UI
local AutoTapNPCToggle = TabMain:CreateToggle({
    Name = "Auto Tap NPC",
    SectionParent = SectionMain,
    CurrentValue = false,
    Callback = function(Value)
        getgenv().AutoTapNPC = Value
        while getgenv().AutoTapNPC do
            game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ArmWrestleService"):WaitForChild("RE"):WaitForChild("onClickRequest"):FireServer()
            wait(0.000000000000000000000001) -- Interval waktu antara interaksi (dalam detik, sesuaikan dengan kebutuhan)
        end
    end
})

-- Add the Trial toggle
local isTrialActive = false
local trialCoroutine

local TrialToggle = TabMain:CreateToggle({
    Name = "Trial",
    SectionParent = SectionMain,
    CurrentValue = false,
    Callback = function(value)
        isTrialActive = value
        if isTrialActive then
            -- Run the first and second functions once
            local args = {
                [1] = "Medieval"
            }
            game:GetService("ReplicatedStorage").Packages.Knit.Services.ChampionshipService.RF.RequestJoin:InvokeServer(unpack(args))
            
            game:GetService("ReplicatedStorage").Packages.Knit.Services.TeleportService.RF.ShowTeleport:InvokeServer()

            -- Start running the third function continuously
            trialCoroutine = coroutine.create(function()
                while isTrialActive do
                    game:GetService("ReplicatedStorage").Packages.Knit.Services.WrestleService.RF.OnClick:InvokeServer()
                    wait(0.000000000000000000000001)
                end
            end)
            coroutine.resume(trialCoroutine)
        else
            -- Stop the coroutine when the toggle is turned off
            isTrialActive = false
            if trialCoroutine then
                coroutine.yield(trialCoroutine)
            end
        end
    end,
})

--- Tab Event 
local EventTab = Window:CreateTab("Event", nil) -- Title, Image

-- Tambahkan Section Halloween Event
local HalloweenEventSection = EventTab:CreateSection("Halloween Event")

-- Toggle Auto TrickOrTreat
local autoTrickOrTreatToggle = EventTab:CreateToggle({
    Name = "Auto TrickOrTreat",
    SectionParent = HalloweenEventSection,
    CurrentValue = false,
    Callback = function(value)
        getgenv().autoTrickOrTreat = value
        if value then
            spawn(function()
                while getgenv().autoTrickOrTreat do
                    for i = 1, 48 do
                        if not getgenv().autoTrickOrTreat then return end  -- Berhenti jika toggle dimatikan
                        local args = { [1] = tostring(i) }
                        game:GetService("ReplicatedStorage").Packages.Knit.Services.TrickOrTreatService.RF.TrickOrTreat:InvokeServer(unpack(args))
                        wait(0.1) -- Interval kecil antara tiap panggilan
                    end
                    wait(60) -- Jeda 60 detik setelah loop 1-48 selesai
                end
            end)
        end
    end
})

-- Toggle Auto Hit 🎃👻
local autoHitToggle = EventTab:CreateToggle({
    Name = "Auto Hit 🎃👻",
    SectionParent = HalloweenEventSection,
    CurrentValue = false,
    Callback = function(value)
        getgenv().autoHit = value
        if value then
            spawn(function()
                while getgenv().autoHit do
                    local breakables = workspace.GameObjects:FindFirstChild("Breakables")
                    if breakables then
                        for _, breakable in ipairs(breakables:GetChildren()) do
                            if not getgenv().autoHit then return end -- Berhenti jika toggle dimatikan

                            -- Hit objek saat ditemukan
                            local args = { [1] = breakable.Name }
                            game:GetService("ReplicatedStorage").Packages.Knit.Services.BreakableService.RF.HitBreakable:InvokeServer(unpack(args))

                            -- Tunggu sampai objek hilang sebelum lanjut ke objek berikutnya
                            repeat
                                wait(0.1) -- Interval kecil untuk memeriksa status objek
                            until not breakable or not breakable.Parent

                            -- Cegah lag dengan jeda kecil
                            wait(0.1)
                        end
                    end
                    wait(1) -- Jeda sebelum memulai loop baru
                end
            end)
        end
    end
})



local EventSection = EventTab:CreateSection("Event Stuff")

local isSpinEventActive = false
local spinEventCoroutine

local SpinEventToggle = TabMain:CreateToggle({
    Name = "Spin Event Summer",
    SectionParent = EventSection,
    CurrentValue = false,
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

local SpinEventSummerx10Toggle = TabMain:CreateToggle({
    Name = "Spin Event Summer x10",
    SectionParent = EventSection,
    CurrentValue = false,
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

local SpinEventSummerx25Toggle = TabMain:CreateToggle({
    Name = "Spin Event Summer x25",
    SectionParent = EventSection,
    CurrentValue = false,
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



local isSpinEventAtlantisActive = false
local spinEventAtlantisCoroutine

local SpinEventAtlantisToggle = TabMain:CreateToggle({
    Name = "Spin Event Atlantis",
    SectionParent = EventSection,
    CurrentValue = false,
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

local isSpinEventAtlantisx10Active = false
local spinEventAtlantisx10Coroutine

local SpinEventAtlantisx10Toggle = TabMain:CreateToggle({
    Name = "Spin Event Atlantis x10",
    SectionParent = EventSection,
    CurrentValue = false,
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
                    wait(0.01) -- Interval waktu antara interaksi (dalam detik, sesuaikan dengan kebutuhan)
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

local isSpinEventAtlantisx25Active = false
local spinEventAtlantisx25Coroutine

local SpinEventAtlantisx25Toggle = TabMain:CreateToggle({
    Name = "Spin Event Atlantis x25",
    SectionParent = EventSection,
    CurrentValue = false,
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
                    wait(0.01) -- Interval waktu antara interaksi (dalam detik, sesuaikan dengan kebutuhan)
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





---local isSpinEvent4thofJulyFortuneActive = false
---local spinEvent4thofJulyFortuneCoroutine
---
---local SpinEventAtlantisToggle = TabMain:CreateToggle({
---    Name = "Spin Event 4th of July Fortune",
---    SectionParent = OtherSection,
---    CurrentValue = false,
---    Callback = function(Value)
---        isSpinEvent4thofJulyFortuneActive = Value
---        if isSpinEvent4thofJulyFortuneActive then
---            spinEvent4thofJulyFortuneCoroutine = coroutine.create(function()
---                local args = {
---                    [1] = "4th of July Fortune"
---                }
---                while isSpinEvent4thofJulyFortuneActive do
---                    game:GetService("ReplicatedStorage").Packages.Knit.Services.SpinnerService.RF.Spin:InvokeServer(unpack(args))
---                    wait(0.01) -- Interval waktu antara interaksi (dalam detik, sesuaikan dengan kebutuhan)
---                end
---            end)
---            coroutine.resume(spinEvent4thofJulyFortuneCoroutine)
---        else
---            if spinEvent4thofJulyFortuneCoroutine then
---                coroutine.yield(spinEvent4thofJulyFortuneCoroutine)
---            end
---        end
---    end
---})

-- Wizard Section
local WizardSection = EventTab:CreateSection("Event Wizard")

local isSpinWizardx10Active = false
local spinWizardx10Coroutine

local SpinWizardToggle = TabMain:CreateToggle({
    Name = "Spin Wizard",
    SectionParent = WizardSection,
    CurrentValue = false,
    Callback = function(Value)
        isSpinWizardActive = Value
        if isSpinWizardActive then
            spinWizardCoroutine = coroutine.create(function()
                local args = {
                    [1] = "Wizard Fortune"
                }
                while isSpinWizardActive do
                    game:GetService("ReplicatedStorage").Packages.Knit.Services.SpinnerService.RF.Spin:InvokeServer(unpack(args))
                    wait(0.01) -- Interval waktu antara interaksi (dalam detik, sesuaikan dengan kebutuhan)
                end
            end)
            coroutine.resume(spinWizardCoroutine)
        else
            if spinWizardCoroutine then
                coroutine.yield(spinWizardCoroutine)
            end
        end
    end
})

local SpinWizardx10Toggle = TabMain:CreateToggle({
    Name = "Spin Wizard x10",
    SectionParent = WizardSection,
    CurrentValue = false,
    Callback = function(Value)
        isSpinWizardx10Active = Value
        if isSpinWizardx10Active then
            spinWizardx10Coroutine = coroutine.create(function()
                local args = {
                    [1] = "Wizard Fortune",
                    [2] = "x10"
                }
                while isSpinWizardx10Active do
                    game:GetService("ReplicatedStorage").Packages.Knit.Services.SpinnerService.RF.Spin:InvokeServer(unpack(args))
                    wait(0.01) -- Interval waktu antara interaksi (dalam detik, sesuaikan dengan kebutuhan)
                end
            end)
            coroutine.resume(spinWizardx10Coroutine)
        else
            if spinWizardx10Coroutine then
                coroutine.yield(spinWizardx10Coroutine)
            end
        end
    end
})

local isSpinWizardx25Active = false
local spinWizardx25Coroutine

local SpinWizardx25Toggle = TabMain:CreateToggle({
    Name = "Spin Wizard x25",
    SectionParent = WizardSection,
    CurrentValue = false,
    Callback = function(Value)
        isSpinWizardx25Active = Value
        if isSpinWizardx25Active then
            spinWizardx25Coroutine = coroutine.create(function()
                local args = {
                    [1] = "Wizard Fortune",
                    [2] = "x25"
                }
                while isSpinWizardx25Active do
                    game:GetService("ReplicatedStorage").Packages.Knit.Services.SpinnerService.RF.Spin:InvokeServer(unpack(args))
                    wait(0.01) -- Interval waktu antara interaksi (dalam detik, sesuaikan dengan kebutuhan)
                end
            end)
            coroutine.resume(spinWizardx25Coroutine)
        else
            if spinWizardx25Coroutine then
                coroutine.yield(spinWizardx25Coroutine)
            end
        end
    end
})


--- Tab Other 
local OtherTab = Window:CreateTab("Other", nil) -- Title, Image
local OtherSection = OtherTab:CreateSection("Other Stuff")

local function createSpinButton()
    OtherTab:CreateButton({
        Name = "Spin",
        SectionParent = OtherSection,
        Callback = function()
            local args = {
                [1] = false
            }
            
        end
    })
end

createSpinButton()

-- Toggle for Spin
local spinToggle = OtherTab:CreateToggle({
    Name = "Toggle Spin",
    SectionParent = OtherSection,
    CurrentValue = false,
    Callback = function(value)
        getgenv().spin = value
        if value then
            spawn(function()
                while getgenv().spin do
                    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("SpinService"):WaitForChild("RE"):WaitForChild("onSpinRequest"):FireServer(unpack(args))
                    wait(0.000001) -- Adjusted interval
                end
            end)
        end
    end
})

---- Toggle for Auto Roll Title
--local autoRollTitleToggle = OtherTab:CreateToggle({
--    Name = "Toggle Auto Roll Title",
--    SectionParent = OtherSection,
--    CurrentValue = false,
--    Callback = function(value)
--        getgenv().autoRollTitle = value
--        if value then
--            spawn(function()
--                while getgenv().autoRollTitle do
--                    game:GetService("ReplicatedStorage").Packages.Knit.Services.TitleService.RF.Roll:InvokeServer()
--                    wait(0.000000001) -- Adjusted interval
--                end
--            end)
--        end
--    end
--})

local autoBuyTrailsToggle = OtherTab:CreateToggle({
    Name = "Toggle Auto Buy Trails",
    SectionParent = OtherSection,
    CurrentValue = false,
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

                    wait(5) -- Adjust the interval as necessary
                end
            end)
        end
    end
})

local autoRollAurasToggle = OtherTab:CreateToggle({
    Name = "Auto Roll Auras",
    SectionParent = OtherSection,
    CurrentValue = false,
    Callback = function(value)
        getgenv().autoRollAuras = value
        if value then
            spawn(function()
                while getgenv().autoRollAuras do
                    game:GetService("ReplicatedStorage").Packages.Knit.Services.AuraService.RF.Roll:InvokeServer()
                    wait(0.0001) -- Interval waktu yang diatur
                end
            end)
        end
    end
})

local autoSpookyPassToggle = OtherTab:CreateToggle({
    Name = "Auto 🎃Spooky Pass!",
    SectionParent = OtherSection,
    CurrentValue = false,
    Callback = function(value)
        getgenv().autoSpookyPass = value
        if value then
            spawn(function()
                while getgenv().autoSpookyPass do
                    game:GetService("ReplicatedStorage").Packages.Knit.Services.HalloweenCrateService.RF.Roll:InvokeServer()
                    wait(0.0001) -- Interval waktu yang diatur
                end
            end)
        end
    end
})


-- Fungsi untuk toggle Index
local function toggleIndex()
    local indexUI = game:GetService("Players").LocalPlayer.PlayerGui.GameUI.Menus.Index
    indexUI.Visible = not indexUI.Visible
end

-- Fungsi untuk memeriksa dan menambahkan pet ke index
local function checkAndAddToIndex()
    local args = {
        [1] = game:GetService("Players").LocalPlayer
    }
    game:GetService("ReplicatedStorage").Packages.Knit.Services.PetService.RF.getOwned:InvokeServer(unpack(args))
end

-- Fungsi untuk memeriksa pet yang sudah dimiliki
local function getOwnedPets()
    local args = {
        [1] = game:GetService("Players").LocalPlayer
    }
    return game:GetService("ReplicatedStorage").Packages.Knit.Services.PetService.RF.getOwned:InvokeServer(unpack(args))
end

-- Fungsi untuk auto hatch egg sampai semua pet di index didapatkan
local function autoIndex()
    local indexPath = game:GetService("ReplicatedStorage").Data.WorldEggIndexes
    local allEggs = indexPath:GetChildren()
    
    while getgenv().AutoIndex do
        for _, egg in pairs(allEggs) do
            if not getgenv().AutoIndex then break end
            
            local ownedPets = getOwnedPets()
            local missingPets = false
            
            for _, pet in pairs(egg:GetChildren()) do
                if not ownedPets[pet.Name] then
                    missingPets = true
                    break
                end
            end
            
            while missingPets and getgenv().AutoIndex do
                local args = {
                    [1] = egg.Name,
                    [2] = {},
                    [4] = false
                }
                game:GetService("ReplicatedStorage").Packages.Knit.Services.EggService.RF.purchaseEgg:InvokeServer(unpack(args))
                wait(5)  -- Jeda untuk mencegah lag
                checkAndAddToIndex()
                
                ownedPets = getOwnedPets()
                missingPets = false
                
                for _, pet in pairs(egg:GetChildren()) do
                    if not ownedPets[pet.Name] then
                        missingPets = true
                        break
                    end
                end
            end
        end
        wait(10)  -- Jeda antara loop untuk mengurangi beban
    end
end

-- Fungsi untuk menghapus pet yang sudah dimiliki
local function deleteOwnedPets()
    while getgenv().AutoDeleteOwnedPets do
        local ownedPets = getOwnedPets()
        
        for _, pet in pairs(ownedPets) do
            if pet.owned then
                local deleteArgs = {
                    [1] = pet.uuid
                }
                game:GetService("ReplicatedStorage").Packages.Knit.Services.PetService.RF.delete:InvokeServer(unpack(deleteArgs))
                wait(0.5)  -- Jeda lebih lama untuk mencegah lag
            end
        end
        wait(10)  -- Jeda antara loop untuk mengurangi beban
    end
end

-- Tambahkan section khusus untuk Index di tab Other
local IndexSection = OtherTab:CreateSection("Index")

-- Tambahkan tombol Open Index ke section Index
local function createOpenIndexButton()
    OtherTab:CreateButton({
        Name = "Open Index",
        SectionParent = IndexSection,
        Callback = function()
            toggleIndex()
        end
    })
end

createOpenIndexButton()

----- Tambahkan toggle untuk Auto Index
---local AutoIndexToggle = OtherTab:CreateToggle({
---    Name = "Auto Index",
---    SectionParent = IndexSection,
---    CurrentValue = false,
---    Callback = function(Value)
---        getgenv().AutoIndex = Value
---        if Value then
---            spawn(autoIndex)
---        end
---    end
---})
---
----- Tambahkan toggle untuk Automatically delete pets that you already own
---local AutoDeleteOwnedPetsToggle = OtherTab:CreateToggle({
---    Name = "Automatically delete pets that you already own",
---    SectionParent = IndexSection,
---    CurrentValue = false,
---    Callback = function(Value)
---        getgenv().AutoDeleteOwnedPets = Value
---        if Value then
---            spawn(deleteOwnedPets)
---        end
---    end
---})

local RebirthSection = OtherTab:CreateSection("Rebirth",false)
-- Rebirth function
local isRebirthActive = false
local rebirthCoroutine

local isSuperRebirthActive = false
local superRebirthCoroutine

local RebirthToggle = TabMain:CreateToggle({
    Name = "Rebirth",
    SectionParent = RebirthSection,
    CurrentValue = false,
    Callback = function(Value)
        isRebirthActive = Value
        if isRebirthActive then
            rebirthCoroutine = coroutine.create(function()
                while isRebirthActive do
                    game:GetService("ReplicatedStorage").Packages.Knit.Services.RebirthService.RE.onRebirthRequest:FireServer()
                    wait(0.1) -- Interval waktu antara interaksi (dalam detik, sesuaikan dengan kebutuhan)
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

local SuperRebirthToggle = TabMain:CreateToggle({
    Name = "Super Rebirth",
    SectionParent = RebirthSection,
    CurrentValue = false,
    Callback = function(Value)
        isSuperRebirthActive = Value
        if isSuperRebirthActive then
            superRebirthCoroutine = coroutine.create(function()
                while isSuperRebirthActive do
                    game:GetService("ReplicatedStorage").Packages.Knit.Services.RebirthService.RE.onSuperRebirth:FireServer()
                    wait(1) -- Interval waktu antara interaksi (dalam detik, sesuaikan dengan kebutuhan)
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

local FishSection = OtherTab:CreateSection("Fish", false)
-- Initialize global variables for auto features
getgenv().AutoFish = false
getgenv().FishingInterval = 0.0000001 -- Default interval time in seconds (adjust as needed)
getgenv().SelectedPond = "Regular"
getgenv().AutoSellFish = false
getgenv().AutoGarden = false
getgenv().AutoUpgradeSnacks = false

-- Function for auto fishing
local function autoFish()
    while getgenv().AutoFish do
        -- Start catching fish
        local argsStart = {
            [1] = getgenv().SelectedPond
        }
        game:GetService("ReplicatedStorage").Packages.Knit.Services.NetService.RF.StartCatching:InvokeServer(unpack(argsStart))
        
        -- Verify catch with provided arguments
        local verifyArgsList = {
            {42, 46.21813527867198},
            {35, 33.440803369507194},
            {296, 297.9361462816596},
            {158, 161.09991836175323},
            {285, 270.6669566780329},
            {271, 279.7603152282536}
        }

        for _, args in ipairs(verifyArgsList) do
            game:GetService("ReplicatedStorage").Packages.Knit.Services.NetService.RF.VerifyCatch:InvokeServer(unpack(args))
        end

        wait(getgenv().FishingInterval) -- Interval time between each fishing cycle (in seconds)
    end
end

-- Function for auto selling fish
local function autoSellFish()
    while getgenv().AutoSellFish do
        for i = 1, 3 do
            local argsSell = {
                [1] = "Fisherman",
                [2] = i
            }
            game:GetService("ReplicatedStorage").Packages.Knit.Services.MerchantService.RF.BuyItem:InvokeServer(unpack(argsSell))
            wait(0.00001) -- Interval time between sales
        end
    end
end

-- Fungsi untuk mengambil daftar seeds yang memiliki "/1" pada namanya
local function getSeedList()
    local seedList = {}
    local seedsStorage = game:GetService("Players").LocalPlayer.PlayerGui.GameUI.Menus.Inventory.Display.Items.MainFrame.ScrollingFrame.SeedsStorage.Objects

    for _, seed in pairs(seedsStorage:GetChildren()) do
        if seed.Name:match("/1") then
            local seedName = seed.Name:match("([^/]+)") -- Mengambil nama seed tanpa "/1"
            table.insert(seedList, seedName)
        end
    end

    return seedList
end

-- Daftar seeds yang diperoleh secara otomatis
local seedList = getSeedList()

-- Fungsi untuk auto gardening
local function autoGarden()
    local harvestArgsList = {1, 2, 3, 4, 5, 6}

    while getgenv().AutoGarden do
        -- Harvesting
        for _, id in ipairs(harvestArgsList) do
            local success, err = pcall(function()
                local args = {[1] = tostring(id)}
                game:GetService("ReplicatedStorage").Packages.Knit.Services.ItemPlantingService.RF.Harvest:InvokeServer(unpack(args))
            end)
            if not success then
                warn("Error harvesting item with ID:", id, "Error:", err)
            end
        end
        wait(0.00000000000001) -- Adjust the interval as needed
        
        -- Planting
        for _, seed in ipairs(seedList) do
            for i = 1, 6 do
                local success, err = pcall(function()
                    local plantArgs = {seed, tostring(1), tostring(i)}
                    game:GetService("ReplicatedStorage").Packages.Knit.Services.ItemPlantingService.RF.Plant:InvokeServer(unpack(plantArgs))
                end)
                if not success then
                    warn("Error planting item:", seed, "at slot:", i, "Error:", err)
                end
            end
        end
        wait(0.00000000000001) -- Adjust the interval as needed
    end
end

-- Fungsi untuk mengambil daftar snack yang memiliki "/1" pada namanya
local function getSnackList()
    local snackList = {}
    local snacksStorage = game:GetService("Players").LocalPlayer.PlayerGui.GameUI.Menus.Inventory.Display.Items.MainFrame.ScrollingFrame.SnacksStorage.Objects

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

-- Fungsi untuk auto upgrading snacks
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
                    -- Attempt to upgrade snack and catch any errors
                    local success, err = pcall(function()
                        game:GetService("ReplicatedStorage").Packages.Knit.Services.ItemCraftingService.RF.UpgradeSnack:InvokeServer(unpack(args))
                    end)
                    if not success then
                        warn("Error upgrading snack:", snack, "to tier:", tier, "Error:", err)
                    end
                end))
            end
        end
        
        -- Jalankan semua coroutine
        for _, co in ipairs(coroutines) do
            coroutine.resume(co)
        end

        wait(0.0000001) -- Interval yang sangat kecil untuk mempercepat proses (sesuaikan dengan kebutuhan)
    end
end


-- Adding toggles and dropdown to the UI
local AutoFishToggle = OtherTab:CreateToggle({
    Name = "Auto Fish",
    SectionParent = FishSection,
    CurrentValue = false,
    Callback = function(Value)
        getgenv().AutoFish = Value
        if Value then
            spawn(autoFish)
        end
    end
})

local AutoSellFishToggle = OtherTab:CreateToggle({
    Name = "Auto Sell Fish",
    SectionParent = FishSection,
    CurrentValue = false,
    Callback = function(Value)
        getgenv().AutoSellFish = Value
        if Value then
            spawn(autoSellFish)
        end
    end
})

-- Adding GardenSection and Auto Garden toggle
local GardenSection = OtherTab:CreateSection("Garden", false)

-- Menambahkan toggle untuk Auto Garden ke UI
local AutoGardenToggle = OtherTab:CreateToggle({
    Name = "Auto Garden",
    SectionParent = GardenSection,
    CurrentValue = false,
    Callback = function(Value)
        getgenv().AutoGarden = Value
        if Value then
            spawn(autoGarden)
        end
    end
})

-- Menambahkan toggle untuk Auto Upgrade Snacks ke UI
local AutoUpgradeSnacksToggle = OtherTab:CreateToggle({
    Name = "Auto Upgrade Snacks",
    SectionParent = GardenSection,
    CurrentValue = false,
    Callback = function(Value)
        getgenv().AutoUpgradeSnacks = Value
        if Value then
            spawn(autoUpgradeSnacks)
        end
    end
})


--- Tab teleport 
local TeleTab = Window:CreateTab("Teleport", nil) -- Title, Image
local TeleSection = TeleTab:CreateSection("Teleport")

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

-- Fungsi untuk membuat tombol teleportasi
local function createTeleportButtons()
    local gameTeleportButtons = {}
    local zoneNames = getZoneList()

    for i, zoneName in ipairs(zoneNames) do
        gameTeleportButtons[i] = TeleTab:CreateButton({
            Name = "Teleport To " .. zoneName,
            SectionParent = TeleSection,
            Callback = function()
                teleportToZone(zoneName)
            end
        })
    end
end

-- Membuat tombol teleportasi pada awalnya
createTeleportButtons()

-- Menambahkan event listener untuk memperbarui tombol ketika game diperbarui
workspace.Zones.ChildAdded:Connect(createTeleportButtons)
workspace.Zones.ChildRemoved:Connect(createTeleportButtons)

--- Tab Egg 
local EggTab = Window:CreateTab("Egg", nil) -- Title, Image
local EggSection = EggTab:CreateSection("EGG")

-- Inisialisasi dropdown untuk egg selection terlebih dahulu untuk menghindari masalah 'nil'
local eggDropdown = nil

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
    print("Eggs found in zone " .. zone .. ": " .. table.concat(eggs, ", ")) -- Debugging
    return eggs
end

-- Fungsi untuk memperbarui dropdown egg berdasarkan zona yang dipilih
local function updateEggDropdown(zone)
    local eggs = getEggList(zone)
    print("Updating egg dropdown for zone: " .. zone) -- Debugging
    if eggDropdown then
        eggDropdown:Refresh(eggs, "None")
    else
        print("Error: eggDropdown is nil")
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

local function createZoneDropdown()
    local zones = getZoneList()
    print("Zones available: " .. table.concat(zones, ", ")) -- Debugging

    zoneDropdown = EggTab:CreateDropdown({
        Name = "Select Zone",
        SectionParent = EggSection,
        Options = zones,
        CurrentOption = "None",
        Callback = function(option)
            getgenv().selectedZoneForEgg = option
            updateEggDropdown(option)
        end
    })
end

-- Panggil fungsi untuk inisialisasi zoneDropdown
createZoneDropdown()

-- Membuat dropdown untuk egg selection
local function createEggDropdown()
    eggDropdown = EggTab:CreateDropdown({
        Name = "Choose Egg",
        SectionParent = EggSection,
        Options = {},
        CurrentOption = "None",
        Callback = function(option)
            getgenv().selectedEgg = option
        end
    })
end

-- Panggil fungsi untuk inisialisasi eggDropdown
createEggDropdown()

-- Membuat dropdown untuk "Hatch Amount"
local hatchAmountDropdown = EggTab:CreateDropdown({
    Name = "Hatch Amount",
    SectionParent = EggSection,
    Options = {"1", "3", "8"},
    CurrentOption = "",
    Callback = function(option)
        getgenv().hatchAmount = tonumber(option)
    end
})



-- Membuat dropdown untuk "Auto Delete Pets"
local autoDeletePetsDropdown1 = EggTab:CreateDropdown({
    Name = "Auto Delete Pets 1",
    SectionParent = EggSection,
    Options = {}, -- Ini akan diisi nanti
    CurrentOption = "None",
    Callback = function(option)
        getgenv().autoDeletePet1 = option
    end
})

local autoDeletePetsDropdown2 = EggTab:CreateDropdown({
    Name = "Auto Delete Pets 2",
    SectionParent = EggSection,
    Options = {}, -- Ini akan diisi nanti
    CurrentOption = "None",
    Callback = function(option)
        getgenv().autoDeletePet2 = option
    end
})

local autoDeletePetsDropdown3 = EggTab:CreateDropdown({
    Name = "Auto Delete Pets 3",
    SectionParent = EggSection,
    Options = {}, -- Ini akan diisi nanti
    CurrentOption = "None",
    Callback = function(option)
        getgenv().autoDeletePet3 = option
    end
})

local autoDeletePetsDropdown4 = EggTab:CreateDropdown({
    Name = "Auto Delete Pets 4",
    SectionParent = EggSection,
    Options = {}, -- Ini akan diisi nanti
    CurrentOption = "None",
    Callback = function(option)
        getgenv().autoDeletePet4 = option
    end
})

local autoDeletePetsDropdown5 = EggTab:CreateDropdown({
    Name = "Auto Delete Pets 5",
    SectionParent = EggSection,
    Options = {}, -- Ini akan diisi nanti
    CurrentOption = "None",
    Callback = function(option)
        getgenv().autoDeletePet5 = option
    end
})

local autoDeletePetsDropdown6 = EggTab:CreateDropdown({
    Name = "Auto Delete Pets 6",
    SectionParent = EggSection,
    Options = {}, -- Ini akan diisi nanti
    CurrentOption = "None",
    Callback = function(option)
        getgenv().autoDeletePet6 = option
    end
})

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

-- Mengisi autoDeletePetsDropdown dengan daftar pets
local function updatePetDropdown()
    local pets = getPetList()
    autoDeletePetsDropdown1:Refresh(pets, "None")
    autoDeletePetsDropdown2:Refresh(pets, "None")
    autoDeletePetsDropdown3:Refresh(pets, "None")
	autoDeletePetsDropdown4:Refresh(pets, "None")
	autoDeletePetsDropdown5:Refresh(pets, "None")
	autoDeletePetsDropdown6:Refresh(pets, "None")
end

updatePetDropdown()

-- Menambahkan toggle untuk "Auto Hatch" ke UI
local autoHatchToggle = EggTab:CreateToggle({
    Name = "Auto Hatch",
    SectionParent = EggSection,
    CurrentValue = false,
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

            local deletePets = {}
            if getgenv().autoDeletePet1 and getgenv().autoDeletePet1 ~= "None" then
                deletePets[getgenv().autoDeletePet1] = true
            end
            if getgenv().autoDeletePet2 and getgenv().autoDeletePet2 ~= "None" then
                deletePets[getgenv().autoDeletePet2] = true
            end
            if getgenv().autoDeletePet3 and getgenv().autoDeletePet3 ~= "None" then
                deletePets[getgenv().autoDeletePet3] = true
            end
            if getgenv().autoDeletePet4 and getgenv().autoDeletePet4 ~= "None" then
                deletePets[getgenv().autoDeletePet4] = true
            end
            if getgenv().autoDeletePet5 and getgenv().autoDeletePet5 ~= "None" then
                deletePets[getgenv().autoDeletePet5] = true
            end
            if getgenv().autoDeletePet6 and getgenv().autoDeletePet6 ~= "None" then
                deletePets[getgenv().autoDeletePet6] = true
            end			
            local args
            if getgenv().hatchAmount == 1 then
                args = {
                    [1] = getgenv().selectedEgg,
                    [2] = deletePets,
                    [4] = false
                }
            elseif getgenv().hatchAmount == 3 then
                args = {
                    [1] = getgenv().selectedEgg,
                    [2] = deletePets,
                    [4] = true
                }
            elseif getgenv().hatchAmount == 8 then
                args = {
                    [1] = getgenv().selectedEgg,
                    [2] = deletePets,
                    [4] = true,
                    [5] = true
                }
            end

            game:GetService("ReplicatedStorage").Packages.Knit.Services.EggService.RF.purchaseEgg:InvokeServer(unpack(args))
            wait(0.00000000000001) -- Wait for 1 millisecond after hatching the selected amount
        end
    end)
end

-- EggEvent Section
local EggEventSection = EggTab:CreateSection("Event Egg")

-- Function to get delete pets configuration
local function getDeletePetsConfig()
    local deletePets = {}
    if getgenv().autoDeletePet1 and getgenv().autoDeletePet1 ~= "None" then
        table.insert(deletePets, getgenv().autoDeletePet1)
    end
    if getgenv().autoDeletePet2 and getgenv().autoDeletePet2 ~= "None" then
        table.insert(deletePets, getgenv().autoDeletePet2)
    end
    if getgenv().autoDeletePet3 and getgenv().autoDeletePet3 ~= "None" then
        table.insert(deletePets, getgenv().autoDeletePet3)
    end
    if getgenv().autoDeletePet4 and getgenv().autoDeletePet4 ~= "None" then
        table.insert(deletePets, getgenv().autoDeletePet4)
    end
    if getgenv().autoDeletePet5 and getgenv().autoDeletePet5 ~= "None" then
        table.insert(deletePets, getgenv().autoDeletePet5)
    end
    if getgenv().autoDeletePet6 and getgenv().autoDeletePet6 ~= "None" then
        table.insert(deletePets, getgenv().autoDeletePet6)
    end
    return deletePets
end

-- Function to change delete state for pets
local function changeDeleteStateOnce(pets)
    for _, pet in ipairs(pets) do
        local args = {
            [1] = pet
        }
        game:GetService("ReplicatedStorage").Packages.Knit.Services.EggService.RE.changeDeleteState:FireServer(unpack(args))
    end
end

-- Function to stop all events
local function stopAllEvents()
    getgenv().hatchEventTiki = false
    getgenv().hatchEventSpellBound = false
end

-- Function to start hatch event Tiki
function startHatchEventTiki()
    spawn(function()
        while getgenv().hatchEventTiki do
            if not getgenv().hatchAmountEvent then
                return
            end

            for i = 1, getgenv().hatchAmountEvent do
                local args = {
                    [1] = getgenv().hatchAmountEvent,
                    [2] = true
                }
                game:GetService("ReplicatedStorage").Packages.Knit.Services.EventService.RF.ClaimEgg:InvokeServer(unpack(args))
                wait(3) -- Short delay between hatches
            end
            wait(4) -- Wait for 4 seconds after hatching the selected amount
        end
    end)
end

-- Function to start hatch event SpellBound
function startHatchEventSpellBound()
    spawn(function()
        while getgenv().hatchEventSpellBound do
            if not getgenv().hatchAmountEvent then
                return
            end

            local args = {
                [1] = getgenv().hatchAmountEvent
            }
            game:GetService("ReplicatedStorage").Packages.Knit.Services.EventService.RF.ClaimEgg:InvokeServer(unpack(args))
            wait(1) -- Short delay between hatches
        end
    end)
end

-- Adding Auto Delete Pets dropdowns to EggEvent Section
local autoDeletePetsDropdown1Event = EggTab:CreateDropdown({
    Name = "Auto Delete Pets 1 (Event)",
    SectionParent = EggEventSection,
    Options = getPetList(),
    CurrentOption = "None",
    Callback = function(option)
        getgenv().autoDeletePet1 = option
    end
})

local autoDeletePetsDropdown2Event = EggTab:CreateDropdown({
    Name = "Auto Delete Pets 2 (Event)",
    SectionParent = EggEventSection,
    Options = getPetList(),
    CurrentOption = "None",
    Callback = function(option)
        getgenv().autoDeletePet2 = option
    end
})

local autoDeletePetsDropdown3Event = EggTab:CreateDropdown({
    Name = "Auto Delete Pets 3 (Event)",
    SectionParent = EggEventSection,
    Options = getPetList(),
    CurrentOption = "None",
    Callback = function(option)
        getgenv().autoDeletePet3 = option
    end
})

local autoDeletePetsDropdown4Event = EggTab:CreateDropdown({
    Name = "Auto Delete Pets 4 (Event)",
    SectionParent = EggEventSection,
    Options = getPetList(),
    CurrentOption = "None",
    Callback = function(option)
        getgenv().autoDeletePet4 = option
    end
})

local autoDeletePetsDropdown5Event = EggTab:CreateDropdown({
    Name = "Auto Delete Pets 5 (Event)",
    SectionParent = EggEventSection,
    Options = getPetList(),
    CurrentOption = "None",
    Callback = function(option)
        getgenv().autoDeletePet5 = option
    end
})

local autoDeletePetsDropdown6Event = EggTab:CreateDropdown({
    Name = "Auto Delete Pets 6 (Event)",
    SectionParent = EggEventSection,
    Options = getPetList(),
    CurrentOption = "None",
    Callback = function(option)
        getgenv().autoDeletePet6 = option
    end
})

-- Create toggle for "Remove Egg Animation"
local removeEggAnimationToggle = EggTab:CreateToggle({
    Name = "Remove Egg Animation",
    SectionParent = EggEventSection,
    CurrentValue = false,
    Callback = function(value)
        getgenv().removeEggAnimation = value
        toggleEggAnimation(value)
    end
})

-- Create dropdown for "Hatch Amount Event"
local hatchAmountEventDropdown = EggTab:CreateDropdown({
    Name = "Hatch Amount Event",
    SectionParent = EggEventSection,
    Options = {"1", "3", "8", "50", "100", "1000"},
    CurrentOption = "",
    Callback = function(option)
        getgenv().hatchAmountEvent = tonumber(option)
    end
})

-- Create toggle for "Hatch Event Tiki"
local hatchEventTikiToggle = EggTab:CreateToggle({
    Name = "Hatch Event Tiki",
    SectionParent = EggEventSection,
    CurrentValue = false,
    Callback = function(value)
        if value then
            local deletePets = getDeletePetsConfig()
            if #deletePets > 0 then
                changeDeleteStateOnce(deletePets)
            end
            getgenv().hatchEventTiki = true
            startHatchEventTiki()
        else
            stopAllEvents()
        end
    end
})

-- Create toggle for "Hatch Event SpellBound"
local hatchEventSpellBoundToggle = EggTab:CreateToggle({
    Name = "Hatch Event SpellBound",
    SectionParent = EggEventSection,
    CurrentValue = false,
    Callback = function(value)
        if value then
            local deletePets = getDeletePetsConfig()
            if #deletePets > 0 then
                changeDeleteStateOnce(deletePets)
            end
            getgenv().hatchEventSpellBound = true
            startHatchEventSpellBound()
        else
            stopAllEvents()
        end
    end
})

-- Function to toggle egg animation
function toggleEggAnimation(value)
    local eggOpeningUI = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("OpenerUI")
    if eggOpeningUI then
        eggOpeningUI.EggOpening.Visible = not value
    end
end
