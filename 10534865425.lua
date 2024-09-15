-- Initialize UI library
local ArrayField = loadstring(game:HttpGet("https://raw.githubusercontent.com/Enzo-YTscript/Ui-Library/main/ArrayfieldLibraryUI"))()

-- Create the main window
local Window = ArrayField:CreateWindow({
    Name = "Hoop Simulator",
    LoadingTitle = "SUBSCRIBE ENZO-YT",
    LoadingSubtitle = "by ENZO-YT",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "EnzoYT",
        FileName = "Mystery Chest Simulator Script"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
        Title = "Mystery Chest Simulator",
        Subtitle = "Key System",
        Note = "Key In Description",
        FileName = "MysteryChestSimulatorKeyEnzoYT",
        SaveKey = true,
        GrabKeyFromSite = true,
        Key = {"https://pastebin.com/raw/iJCXgQGb"},
        Actions = {
            [1] = {
                Text = 'Click here to copy the key link',
                OnPress = function() end,
            }
        },
    }
})

-- Anti-AFK and rejoin logic
game:GetService("GuiService").ErrorMessageChanged:Connect(function()
    wait(0.1)
    game:GetService("TeleportService"):Teleport(game.PlaceId)
end)

local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
    vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    wait(1)
    vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

-- Existing Main Tab
local TabMain = Window:CreateTab("HOME", nil) -- Title, Image
local SectionGift = TabMain:CreateSection("Gift", false)
local SectionShoot = TabMain:CreateSection("Shoot", false) -- Section untuk Auto Shoot

local isGifting = false
local giftCoroutine

local ToggleAutoGift = TabMain:CreateToggle({
    Name = "Auto Gift",
    SectionParent = SectionGift,
    CurrentValue = false,
    Callback = function(v)
        isGifting = v
        if isGifting then
            giftCoroutine = coroutine.create(function()
                while isGifting do
                    for i = 1, 9 do 
                        if not isGifting then
                            return
                        end
                        local args = {[1] = i}
                        game:GetService("ReplicatedStorage"):FindFirstChild("events-V3x"):FindFirstChild("266b27ad-aa4c-48e4-8e52-d8a24bbe68ba"):FireServer(unpack(args))

                        wait(30) 
                    end
                end
            end)
            coroutine.resume(giftCoroutine)
        else
            -- Stop the coroutine when the toggle is turned off
            isGifting = false
            if giftCoroutine then
                coroutine.close(giftCoroutine)
            end
        end
    end,
})

-- Auto Shoot logic
local isShooting = false
local shootCoroutine

local ToggleAutoShoot = TabMain:CreateToggle({
    Name = "Auto Shoot",
    SectionParent = SectionShoot,
    CurrentValue = false,
    Callback = function(v)
        isShooting = v
        if isShooting then
            shootCoroutine = coroutine.create(function()
                while isShooting do
                    local args = {[1] = 1}
                    game:GetService("ReplicatedStorage"):FindFirstChild("events-V3x"):FindFirstChild("8eeeb218-a53f-4e8c-81d0-905cf9a7154f"):FireServer(unpack(args))

                    wait(10) -- Menunggu 1 detik sebelum menembak lagi
                end
            end)
            coroutine.resume(shootCoroutine)
        else
            -- Stop the coroutine when the toggle is turned off
            isShooting = false
            if shootCoroutine then
                coroutine.close(shootCoroutine)
            end
        end
    end,
})