-- By Volca --
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then return end

-- === VARIABLES ===
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local invis_on = false
local chams_enabled = false
local speed_enabled = false
local auto_collect = false
local tp_loop_enabled = false
local esp_enabled = false
local speed_val = 32 

-- Suara Notifikasi (Volume 0.7)
local NOTIF_SOUND_ID = "rbxassetid://174991419"
local notifSound = Instance.new("Sound", game.SoundService)
notifSound.SoundId = NOTIF_SOUND_ID
notifSound.Volume = 0.7 

-- === HELPER FUNCTIONS ===
local function playEffect(title, msg)
    notifSound:Play()
    Rayfield:Notify({Title = title, Content = msg, Duration = 2})
end

-- === CORE FUNCTIONS ===

-- 1. FE INVISIBLE (SEAT METHOD)
local function toggleInvisibility(state)
    invis_on = state
    local char = player.Character
    if not char then return end

    if invis_on then
        task.spawn(function()
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then v.Transparency = 0.75 end
            end
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local savedpos = root.CFrame
                task.wait(0.85)
                char:MoveTo(Vector3.new(-25.95, 480, 3535.55))
                task.wait(0.85)
                local Seat = Instance.new('Seat', workspace)
                Seat.Name = 'invischair'
                Seat.Transparency = 1
                Seat.CanCollide = false
                local Weld = Instance.new("Weld", Seat)
                Weld.Part0 = Seat
                Weld.Part1 = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
                task.wait()
                Seat.CFrame = savedpos
            end
        end)
        playEffect("Invisible", "Enable")
    else
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then v.Transparency = 0 end
        end
        if workspace:FindFirstChild('invischair') then workspace.invischair:Destroy() end
        playEffect("Invisible", "Disable")
    end
end

-- 2. INSTANT COIN COLLECT
local function instantCollect()
    task.spawn(function()
        while auto_collect do
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local tokens = workspace:FindFirstChild("GameTokens") or workspace
                for _, v in pairs(tokens:GetDescendants()) do
                    if not auto_collect then break end
                    if v.Name == "Credit" and v:IsA("BasePart") then
                        v.CFrame = root.CFrame
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end

-- 3. ULTRA FAST PLAYER TP
local function ultraFastTP()
    task.spawn(function()
        while tp_loop_enabled do
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                for _, target in pairs(game.Players:GetPlayers()) do
                    if not tp_loop_enabled then break end
                    if target ~= player and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                        root.CFrame = target.Character.HumanoidRootPart.CFrame
                        runService.Heartbeat:Wait() 
                    end
                end
            end
            task.wait()
        end
    end)
end

-- 4. DYNAMIC ESP
local function isPlayerIT(p)
    if p:GetAttribute("IsSeeker") then return true end
    if p.Team and (p.Team.Name == "Seeker" or p.Team.Name == "IT" or p.Team.Name == "Hunter") then return true end
    if p.Character and p.Character:FindFirstChild("IsIT") then return true end
    return false
end

local function updateESP()
    if not esp_enabled then return end
    local localIsIT = isPlayerIT(player)
    
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character then
            local targetIsIT = isPlayerIT(p)
            local shouldShowESP = false
            
            if localIsIT then
                shouldShowESP = true
            else
                if targetIsIT then
                    shouldShowESP = true
                end
            end
            
            local highlight = p.Character:FindFirstChild("ZO_ESP")
            
            if shouldShowESP then
                if not highlight then
                    highlight = Instance.new("Highlight", p.Character)
                    highlight.Name = "ZO_ESP"
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.OutlineTransparency = 0
                end
                
                if targetIsIT then
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                else
                    highlight.FillColor = Color3.fromRGB(0, 255, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
                highlight.FillTransparency = 0.5
                highlight.Enabled = true
            else
                if highlight then
                    highlight:Destroy()
                end
            end
        end
    end
end

-- === MAIN WINDOW ===
local Window = Rayfield:CreateWindow({
   Name = "Volca | HIDE AND SEEK",
   LoadingTitle = "Restoring All Features...",
   ConfigurationSaving = {Enabled = false}
})

local Tab = Window:CreateTab("Main Menu", 4483362587)

Tab:CreateSection("Farming")

Tab:CreateToggle({
   Name = "COIN",
   CurrentValue = false,
   Callback = function(v) 
        auto_collect = v 
        if v then playEffect("COIN", "Enable") instantCollect() end
   end,
})

Tab:CreateToggle({
   Name = "TELEPORT",
   CurrentValue = false,
   Callback = function(v) 
        tp_loop_enabled = v 
        if v then playEffect("TELEPORT", "Enable") ultraFastTP() end
   end,
})

Tab:CreateSection("Player")

Tab:CreateToggle({
   Name = "FE Invisible [Z]",
   CurrentValue = false,
   Callback = function(v) toggleInvisibility(v) end,
})

-- FITUR SPEED KEMBALI!
Tab:CreateToggle({
   Name = "Speed",
   CurrentValue = false,
   Callback = function(v) 
        speed_enabled = v 
        if not v and player.Character then player.Character.Humanoid.WalkSpeed = 16 end
        playEffect("Speed", v and "Enable" or "Disable")
   end,
})

Tab:CreateToggle({
   Name = "Smart ESP",
   CurrentValue = false,
   Callback = function(v) 
        esp_enabled = v 
        if not v then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("ZO_ESP") then
                    p.Character.ZO_ESP:Destroy()
                end
            end
        end
        playEffect("Smart ESP", v and "Enable" or "Disable")
   end,
})

-- === HANDLERS ===
runService.Heartbeat:Connect(function()
    -- Speed Logic (JAN DI ILANGIN LAGI)
    if speed_enabled and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = speed_val
    end

    -- Chams Logic
    if chams_enabled then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= player and p.Character then
                local h = p.Character:FindFirstChild("WQ_Cham") or Instance.new("Highlight", p.Character)
                h.Name = "WQ_Cham"
                h.FillColor = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                h.Enabled = true
            end
        end
    else
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("WQ_Cham") then
                p.Character.WQ_Cham:Destroy()
            end
        end
    end

    -- ESP Logic
    if esp_enabled then
        updateESP()
    end
end)

-- Hotkey Z
UserInputService.InputBegan:Connect(function(input, proc)
    if not proc and input.KeyCode == Enum.KeyCode.Z then
        invis_on = not invis_on
        toggleInvisibility(invis_on)
    end
end)

playEffect("Volca", "All Features Restored!")
