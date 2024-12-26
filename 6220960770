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

-- Variabel untuk toggle
local Options = Fluent.Options
getgenv().AutoTeleportEnabled = false
getgenv().AutoClickEnabled = false

-- Fungsi Teleport to Present
task.spawn(function()
    while task.wait(0.1) do
        if getgenv().AutoTeleportEnabled then
            local presents = workspace:FindFirstChild("activePresents")
            if presents then
                for _, present in pairs(presents:GetChildren()) do
                    if present:IsA("BasePart") then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = present.CFrame
                        break
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

-- Tab Main
Tabs.Main:AddToggle("AutoTeleport", { Title = "Teleport to Present", Default = false }):OnChanged(function()
    getgenv().AutoTeleportEnabled = Options.AutoTeleport.Value
end)

Tabs.Main:AddToggle("AutoClick", { Title = "Auto Click", Default = false }):OnChanged(function()
    getgenv().AutoClickEnabled = Options.AutoClick.Value
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
