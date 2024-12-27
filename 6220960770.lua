-- Skrip ini dibuat untuk game berjudul "Blades Sworld"
-- Pastikan pustaka Fluent, SaveManager, dan InterfaceManager sudah terhubung dengan benar.

repeat task.wait(0.25) until game:IsLoaded();
getgenv().Image = "rbxassetid://15298567397" -- Ganti dengan asset ID gambar Anda
getgenv().ToggleUI = "LeftControl" -- Tombol untuk toggle UI

-- Membuat UI Toggle untuk perangkat mobile
task.spawn(function()
    if not getgenv().LoadedMobileUI then
        getgenv().LoadedMobileUI = true
        local OpenUI = Instance.new("ScreenGui")
        local ImageButton = Instance.new("ImageButton")
        local UICorner = Instance.new("UICorner")
        OpenUI.Name = "OpenUI"
        OpenUI.Parent = game:GetService("CoreGui")
        OpenUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ImageButton.Parent = OpenUI
        ImageButton.BackgroundColor3 = Color3.fromRGB(105, 105, 105)
        ImageButton.BackgroundTransparency = 0.8
        ImageButton.Position = UDim2.new(0.9, 0, 0.1, 0)
        ImageButton.Size = UDim2.new(0, 50, 0, 50)
        ImageButton.Image = getgenv().Image
        ImageButton.Draggable = true
        ImageButton.Transparency = 1
        UICorner.CornerRadius = UDim.new(0, 200)
        UICorner.Parent = ImageButton
        ImageButton.MouseButton1Click:Connect(function()
            game:GetService("VirtualInputManager"):SendKeyEvent(true, getgenv().ToggleUI, false, game)
        end)
    end
end)

-- Memuat pustaka Fluent dan tambahan
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Blades Sworld UI",
    SubTitle = "by Your Name",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl -- Menggunakan Left Ctrl sebagai toggle UI
})

-- Membuat Tab
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Variabel untuk toggle dan input
local Options = Fluent.Options
getgenv().AutoTeleportEnabled = false
getgenv().AutoClickEnabled = false
getgenv().VirtualAutoClickEnabled = false
getgenv().TPMeteorsEnabled = false
getgenv().TPOrbsEnabled = false

-- Fungsi TP Present to Player
task.spawn(function()
    while task.wait(0.1) do
        if getgenv().AutoTeleportEnabled then
            local presents = workspace:FindFirstChild("activePresents")
            local player = game.Players.LocalPlayer
            if presents and player and player.Character then
                local playerPosition = player.Character.HumanoidRootPart.Position
                for _, present in pairs(presents:GetChildren()) do
                    if present:IsA("BasePart") then
                        present.CFrame = CFrame.new(playerPosition) -- Memindahkan Present tepat ke posisi pemain
                    end
                end
            end
        end
    end
end)

-- Fungsi TP Meteors to Player
task.spawn(function()
    while task.wait(0.1) do
        if getgenv().TPMeteorsEnabled then
            local meteors = workspace:FindFirstChild("ActiveMeteors")
            local player = game.Players.LocalPlayer
            if player and player.Character then
                local playerPosition = player.Character.HumanoidRootPart.Position
                if meteors then
                    for _, meteor in pairs(meteors:GetChildren()) do
                        if meteor:IsA("BasePart") then
                            meteor.CFrame = CFrame.new(playerPosition) -- Memindahkan Meteor tepat ke posisi pemain
                        end
                    end
                end
            end
        end
    end
end)

-- Fungsi TP Orbs to Player
task.spawn(function()
    while task.wait(0.1) do
        if getgenv().TPOrbsEnabled then
            local orbs = workspace:FindFirstChild("activeOrbs")
            local player = game.Players.LocalPlayer
            if player and player.Character then
                local playerPosition = player.Character.HumanoidRootPart.Position
                if orbs then
                    for _, orb in pairs(orbs:GetChildren()) do
                        if orb:IsA("BasePart") then
                            orb.CFrame = CFrame.new(playerPosition) -- Memindahkan Orb tepat ke posisi pemain
                        end
                    end
                end
            end
        end
    end
end)

-- Fungsi Auto Click
task.spawn(function()
    while task.wait(0.01) do
        if getgenv().AutoClickEnabled then
            local bladePowerGiver = workspace:FindFirstChild("BladePowerGiver")
            if bladePowerGiver and bladePowerGiver:FindFirstChild("RemoteEvent") then
                bladePowerGiver.RemoteEvent:FireServer()
            end
        end
    end
end)

-- Fungsi Virtual Auto Click
task.spawn(function()
    while task.wait(1) do -- Menunggu 1 detik sebelum klik berikutnya
        if getgenv().VirtualAutoClickEnabled then
            game:GetService("VirtualInputManager"):SendMouseButtonEvent(
                game.Workspace.CurrentCamera.ViewportSize.X - 10, -- Posisi x di pojok kanan atas
                10, -- Posisi y di pojok kanan atas
                0, -- Tombol kiri mouse
                true, -- Tekan tombol
                game,
                0
            )
            game:GetService("VirtualInputManager"):SendMouseButtonEvent(
                game.Workspace.CurrentCamera.ViewportSize.X - 10,
                10,
                0,
                false, -- Lepaskan tombol
                game,
                0
            )
        end
    end
end)

-- Tab Main
Tabs.Main:AddToggle("AutoTeleport", { Title = "TP Present to Player", Default = false }):OnChanged(function()
    getgenv().AutoTeleportEnabled = Options.AutoTeleport.Value
end)

Tabs.Main:AddToggle("TPMeteors", { Title = "TP Meteors to Player", Default = false }):OnChanged(function()
    getgenv().TPMeteorsEnabled = Options.TPMeteors.Value
end)

Tabs.Main:AddToggle("TPOrbs", { Title = "TP Orbs to Player", Default = false }):OnChanged(function()
    getgenv().TPOrbsEnabled = Options.TPOrbs.Value
end)

Tabs.Main:AddToggle("AutoClick", { Title = "Auto Click", Default = false }):OnChanged(function()
    getgenv().AutoClickEnabled = Options.AutoClick.Value
end)

Tabs.Main:AddToggle("VirtualAutoClick", { Title = "Virtual Auto Click", Default = false }):OnChanged(function()
    getgenv().VirtualAutoClickEnabled = Options.VirtualAutoClick.Value
end)

-- SaveManager dan InterfaceManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:SetIgnoreIndexes({})
SaveManager:SetFolder("BladesSworld/Configs")
InterfaceManager:SetFolder("BladesSworld")

-- Build Section untuk Settings
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- Memuat Config
SaveManager:LoadAutoloadConfig()

Fluent:Notify({
    Title = "Blades Sworld UI",
    Content = "UI telah berhasil dimuat.",
    Duration = 8
})
