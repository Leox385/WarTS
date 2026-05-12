-- ==========================================================
-- WAR TYCOON SIMPLE SCRIPT
-- ==========================================================

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local workspace = game:GetService("Workspace")

local Settings = {
    AutoBuy = false
}

local Locations = {
    Alpha = Vector3.new(-878.41, 65.52, -4862.31), Bravo = Vector3.new(106.47, 65.59, -4906.35),
    Charlie = Vector3.new(1108.62, 67.42, -4642.21), Delta = Vector3.new(2265.50, 68.38, -3744.03),
    Echo = Vector3.new(2868.43, 67.69, -2730.49), Foxtrot = Vector3.new(3032.77, 65.64, -1462.30),
    Golf = Vector3.new(3363.51, 66.06, -236.40), Hotel = Vector3.new(3219.96, 66.57, 905.49),
    Juliet = Vector3.new(2858.39, 66.84, 2115.60), Kilo = Vector3.new(2395.14, 67.06, 3201.82),
    Lima = Vector3.new(865.17, 66.55, 3720.86), Omega = Vector3.new(-645.18, 66.19, 3919.50),
    Romeo = Vector3.new(-1769.61, 65.65, 3572.98), Sierra = Vector3.new(-2749.55, 65.52, 2309.63),
    Tango = Vector3.new(-3194.95, 65.61, 1228.21), Victor = Vector3.new(-3738.37, 65.72, 345.40),
    Yankee = Vector3.new(-4030.05, 65.85, -604.23), Zulu = Vector3.new(-4036.56, 65.78, -1659.56),
    CapturePoint = Vector3.new(-505.41, 177.04, -1019.41)
}

-- ==========================================================
-- UTILITIES
-- ==========================================================

local function getMyTycoon()
    local tycoonsFolder = workspace:FindFirstChild("Tycoon") and workspace.Tycoon:FindFirstChild("Tycoons") 
                          or workspace:FindFirstChild("Tycoons")
    if tycoonsFolder then
        for _, t in ipairs(tycoonsFolder:GetChildren()) do
            if t:GetAttribute("Owner") == lp.Name then return t end
        end
    end
    return nil
end

local function applyInfAmmo()
    local configs = game:GetService("ReplicatedStorage"):FindFirstChild("Configurations")
    if configs and configs:FindFirstChild("ACS_Guns") then
        for _, gun in ipairs(configs.ACS_Guns:GetChildren()) do
            local ammoValue = gun:FindFirstChild("Ammo")
            if ammoValue and ammoValue:IsA("NumberValue") then ammoValue.Value = 999999999 end
        end
        print("[War Tycoon] Infinite Ammo Applied.")
    end
end

-- ==========================================================
-- AUTO BUY
-- ==========================================================

local function isButtonSafe(btn)
    local rebirthReq = tonumber(btn:GetAttribute("RebirthRequirement")) or 0
    if rebirthReq > 0 then return false end
    
    local btnType = btn:GetAttribute("ButtonType")
    local forbidden = {"Gamepass", "DevProduct", "Robux", "Clothing", "Outfit", "Operation", "Reward", "Medal", "Group"}
    
    for _, typeName in ipairs(forbidden) do
        if btnType == typeName then return false end
    end
    return true
end

local function runAutoBuy()
    task.spawn(function()
        print("[War Tycoon] Auto Buy Activated.")
        while Settings.AutoBuy do
            local myTycoon = getMyTycoon()
            if myTycoon then
                local buttons = myTycoon:FindFirstChild("UnpurchasedButtons")
                if buttons then
                    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local savedPos = hrp.Position
                        local boughtSomething = false

                        for _, btn in ipairs(buttons:GetChildren()) do
                            if not Settings.AutoBuy then break end
                            if isButtonSafe(btn) then
                                local part = btn:FindFirstChild("Part") or btn:FindFirstChildWhichIsA("BasePart", true)
                                if part then
                                    hrp.CFrame = CFrame.new(part.Position.X, part.Position.Y + 2, part.Position.Z)
                                    task.wait(0.8)
                                    boughtSomething = true
                                end
                            end
                        end
                        if boughtSomething and Settings.AutoBuy then 
                            hrp.CFrame = CFrame.new(savedPos.X, savedPos.Y, savedPos.Z) 
                        end
                    end
                end
            end
            task.wait(2)
        end
    end)
end

-- ==========================================================
-- TELEPORT
-- ==========================================================

local function TeleportTo(pos)
    local char = lp.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(pos.X, pos.Y + 5, pos.Z)
    end
end

-- ==========================================================
-- USER INTERFACE
-- ==========================================================

UI.AddTab("War Tycoon", function(tab)
    local mainSec = tab:Section("Tycoon", "Left")
    
    mainSec:Toggle("ab_tgl", "Auto Buy", false, function(s) 
        Settings.AutoBuy = s 
        if s then runAutoBuy() end 
    end)

    local combatSec = tab:Section("Combat", "Right")
    combatSec:Button("Infinite Ammo", function() applyInfAmmo() end)
end)

UI.AddTab("Teleports", function(tab)
    local tpSec = tab:Section("Bases", "Left")
    for name, pos in pairs(Locations) do
        if name ~= "CapturePoint" then
            tpSec:Button(name, function() TeleportTo(pos) end)
        end
    end
    
    local captureSec = tab:Section("Objectives", "Right")
    captureSec:Button("Capture Point", function() TeleportTo(Locations.CapturePoint) end)
end)

print("[War Tycoon] Script loaded successfully.")
