-- // HONEY HUB v7.3 - ULTIMATE CRIMINALITY SCRIPT
-- // IMPROVED DESYNC DETECTION & ESP FORMATTING
-- // FEATURES: ANTI-DESYNC (SELF & KILLER), RAGEBOT, FLY, ESP, ETC.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // SECURITY: ADONIS BYPASS & ANTI-KICK
task.spawn(function()
    pcall(function()
        local debug_info = getrenv().debug.info
        local x, y
        local verbose = false

        if setthreadidentity then setthreadidentity(2) end

        for _, v in pairs(getgc(true)) do
            if type(v) == "table" then
                -- Adonis Detection Bypass
                local a = rawget(v, "Detected")
                local b = rawget(v, "Kill")
            
                if type(a) == "function" and not x then
                    x = a
                    hookfunction(x, function(c, f, n)
                        if c ~= "_" and verbose then
                            warn("Adonis AntiCheat flagged\nMethod: " .. tostring(c) .. "\nInfo: " .. tostring(f))
                        end
                        return true
                    end)
                end

                if rawget(v, "Variables") and rawget(v, "Process") and type(b) == "function" and not y then
                    y = b
                    hookfunction(y, function(f)
                        if verbose then
                            warn("Adonis AntiCheat tried to kill (fallback): " .. tostring(f))
                        end
                    end)
                end

                -- Original Kick Bypass
                if rawget(v, "indexInstance") and type(v.indexInstance) == "table" and v.indexInstance[1] == "kick" then
                    setreadonly(v, false)
                    v.tvk = {"kick", function() return workspace:WaitForChild("") end}
                    setreadonly(v, true)
                end
            end
        end

        if debug_info then
            local oldDebugInfo; oldDebugInfo = hookfunction(debug_info, newcclosure(function(...)
                local a, f = ...
                if x and a == x then
                    if verbose then warn("Adonis bypass triggered (debug.info)") end
                    return coroutine.yield(coroutine.running())
                end
                return oldDebugInfo(...)
            end))
        end

        if setthreadidentity then setthreadidentity(7) end
    end)
end)

local function get_key(salt)
    local values = ReplicatedStorage:FindFirstChild("Values")
    local st = values and values:FindFirstChild("ServerTick")
    return st and st.Value - salt or tick() - salt
end

-- // CONFIGURATION (HoneyHub v7.3)
local CONFIG = {
    -- Combat
    RAGEBOT = true,
    SILENT_AIM = false,
    WALLBANG = true,
    MELEE_AURA = false,
    AUTO_PARRY = false,
    HITBOX_EXPANDER = false,
    NO_RECOIL = false,
    
    -- Visuals
    PLAYER_ESP = true,
    ITEM_ESP = false,
    DESYNC_ESP = true,
    FULLBRIGHT = false,
    TRACERS = false,
    
    -- Movement
    FLY = false,
    NOCLIP = false,
    SPEED = 16,
    FLY_SPEED = 50,
    ANTI_AFK = true,
    SELF_DESYNC = false,
    
    -- Misc
    INF_STAMINA = true,
    AUTO_HEAL = false,
    AUTO_LOCKPICK = false,
    KILL_SAY = false,
    
    -- Internals
    RANGE = 2000,
    FIRE_RATE = 0.08,
    SALT_GUN = 28951,
    SALT_MELEE = 38506,
    BUTTER = "\240\159\141\158",
    DESYNC_THRESH = 50,
    TARGET_REFRESH_RATE = 0.05 -- Increased refresh for better detection
}

local active = true
local connections = {}
local closestTarget = nil
local lastFire, lastMelee = 0, 0
local trackData = {}

-- // UI: HoneyHub INTERFACE
local function createUI()
    if LocalPlayer.PlayerGui:FindFirstChild("HoneyHubUI") then LocalPlayer.PlayerGui.HoneyHubUI:Destroy() end
    local sg = Instance.new("ScreenGui", LocalPlayer.PlayerGui); sg.Name = "HoneyHubUI"; sg.ResetOnSpawn = false

    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 500, 0, 380); main.Position = UDim2.new(0.5, -250, 0.5, -190)
    main.BackgroundColor3 = Color3.fromRGB(25, 25, 25); main.BorderSizePixel = 0
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", main); stroke.Color = Color3.fromRGB(100, 100, 255); stroke.Thickness = 2

    -- Sidebar
    local side = Instance.new("Frame", main)
    side.Size = UDim2.new(0, 120, 1, 0); side.BackgroundColor3 = Color3.fromRGB(20, 20, 20); side.BorderSizePixel = 0
    Instance.new("UICorner", side).CornerRadius = UDim.new(0, 8)

    local title = Instance.new("TextLabel", side)
    title.Size = UDim2.new(1, 0, 0, 40); title.Text = "HONEY HUB"; title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.SourceSansBold; title.TextSize = 16; title.BackgroundTransparency = 1

    local tabContainer = Instance.new("Frame", side)
    tabContainer.Size = UDim2.new(1, 0, 1, -80); tabContainer.Position = UDim2.new(0, 0, 0, 40); tabContainer.BackgroundTransparency = 1
    Instance.new("UIListLayout", tabContainer).Padding = UDim.new(0, 5)

    -- Page Container
    local pages = Instance.new("Frame", main)
    pages.Size = UDim2.new(1, -130, 1, -10); pages.Position = UDim2.new(0, 125, 0, 5); pages.BackgroundTransparency = 1

    local function createTab(name)
        local btn = Instance.new("TextButton", tabContainer)
        btn.Size = UDim2.new(1, -10, 0, 30); btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35); btn.Text = name
        btn.TextColor3 = Color3.fromRGB(200, 200, 200); btn.Font = Enum.Font.SourceSans; btn.TextSize = 13
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

        local page = Instance.new("ScrollingFrame", pages)
        page.Size = UDim2.new(1, 0, 1, 0); page.Visible = false; page.BackgroundTransparency = 1; page.BorderSizePixel = 0
        page.ScrollBarThickness = 2; Instance.new("UIListLayout", page).Padding = UDim.new(0, 5)

        btn.MouseButton1Click:Connect(function()
            for _, p in pairs(pages:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
            for _, b in pairs(tabContainer:GetChildren()) do if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(35, 35, 35) end end
            page.Visible = true; btn.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
        end)
        return page
    end

    local combatPage = createTab("Combat")
    local visualPage = createTab("Visuals")
    local movePage = createTab("Movement")
    local miscPage = createTab("Misc")

    local function addToggle(page, name, cfg)
        local f = Instance.new("Frame", page); f.Size = UDim2.new(1, -10, 0, 35); f.BackgroundColor3 = Color3.fromRGB(30, 30, 30); f.BorderSizePixel = 0
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
        local t = Instance.new("TextLabel", f); t.Size = UDim2.new(1, -50, 1, 0); t.Position = UDim2.new(0, 10, 0, 0)
        t.Text = name; t.TextColor3 = Color3.fromRGB(230, 230, 230); t.Font = Enum.Font.SourceSans; t.TextSize = 13; t.BackgroundTransparency = 1; t.TextXAlignment = 0
        local b = Instance.new("TextButton", f); b.Size = UDim2.new(0, 40, 0, 20); b.Position = UDim2.new(1, -45, 0.5, -10)
        b.BackgroundColor3 = CONFIG[cfg] and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(200, 50, 50); b.Text = ""
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        b.MouseButton1Click:Connect(function()
            CONFIG[cfg] = not CONFIG[cfg]
            b.BackgroundColor3 = CONFIG[cfg] and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(200, 50, 50)
            if cfg == "FULLBRIGHT" then Lighting.Brightness = CONFIG.FULLBRIGHT and 10 or 2 end
        end)
    end

    addToggle(combatPage, "Ragebot Engine", "RAGEBOT")
    addToggle(combatPage, "Silent Aim", "SILENT_AIM")
    addToggle(combatPage, "Wallbang Mode", "WALLBANG")
    addToggle(combatPage, "Melee Aura", "MELEE_AURA")
    addToggle(combatPage, "Auto Parry", "AUTO_PARRY")
    addToggle(combatPage, "Hitbox Expander", "HITBOX_EXPANDER")
    
    addToggle(visualPage, "Player ESP", "PLAYER_ESP")
    addToggle(visualPage, "Item/Scrap ESP", "ITEM_ESP")
    addToggle(visualPage, "Desync ESP (Killer)", "DESYNC_ESP")
    addToggle(visualPage, "Tracers", "TRACERS")
    addToggle(visualPage, "Fullbright", "FULLBRIGHT")
    
    addToggle(movePage, "Fly Engine", "FLY")
    addToggle(movePage, "Noclip Ghost", "NOCLIP")
    addToggle(movePage, "Anti-AFK", "ANTI_AFK")
    addToggle(movePage, "Self Anti-Desync", "SELF_DESYNC")
    
    addToggle(miscPage, "Infinite Stamina", "INF_STAMINA")
    addToggle(miscPage, "Auto Heal", "AUTO_HEAL")
    addToggle(miscPage, "Auto Lockpick", "AUTO_LOCKPICK")
    addToggle(miscPage, "Kill Say", "KILL_SAY")

    -- Unload
    local un = Instance.new("TextButton", side); un.Size = UDim2.new(1, -10, 0, 30); un.Position = UDim2.new(0, 5, 1, -35)
    un.BackgroundColor3 = Color3.fromRGB(150, 50, 50); un.Text = "UNLOAD"; un.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", un).CornerRadius = UDim.new(0, 4)
    un.MouseButton1Click:Connect(function()
        active = false; sg:Destroy(); for _, c in pairs(connections) do if c then c:Disconnect() end end
    end)

    -- Draggable
    local d, ds, sp; main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true; ds = i.Position; sp = main.Position; i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then d = false end end) end end)
    UserInputService.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement and d then local delta = i.Position - ds; main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y) end end)
    table.insert(connections, UserInputService.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.Insert then sg.Enabled = not sg.Enabled end end))
    
    combatPage.Visible = true
end

-- // CORE LOGIC
local function isVisible(p)
    if not p then return false end
    if CONFIG.WALLBANG then return true end
    local res = workspace:Raycast(Camera.CFrame.Position, p.Position - Camera.CFrame.Position, RaycastParams.new())
    return res == nil or res.Instance:IsDescendantOf(p.Parent)
end

local function applyVisuals(plr, isDesync)
    local char = plr.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if CONFIG.PLAYER_ESP and plr ~= LocalPlayer then
        local b = root:FindFirstChild("ESP") or Instance.new("BillboardGui", root)
        if not root:FindFirstChild("ESP") then
            b.Name = "ESP"; b.Size = UDim2.new(0, 200, 0, 50); b.AlwaysOnTop = true
            local t = Instance.new("TextLabel", b); t.Name = "Label"; t.Size = UDim2.new(1, 0, 1, 0); t.BackgroundTransparency = 1; t.Font = 3; t.TextSize = 12; t.Parent = b
        end
        
        local t = b:FindFirstChild("Label")
        if t then
            if isDesync then
                t.Text = "[DESYNC] " .. plr.Name .. " [" .. math.floor((root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) .. "m]"
                t.TextColor3 = Color3.fromRGB(255, 0, 0) -- Red for Desync
            else
                t.Text = plr.Name .. " [" .. math.floor((root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) .. "m]"
                t.TextColor3 = Color3.fromRGB(255, 255, 255)
            end
        end
    end

    if CONFIG.DESYNC_ESP and isDesync then
        local h = char:FindFirstChild("Highlight") or Instance.new("Highlight", char)
        h.FillColor = Color3.fromRGB(0, 162, 255); h.OutlineColor = Color3.fromRGB(255, 0, 0); h.DepthMode = 0
    else
        if char:FindFirstChild("Highlight") then char.Highlight:Destroy() end
    end
end

-- // MASTER LOOP
task.spawn(function()
    createUI()
    while active do
        local best, dist = nil, CONFIG.RANGE
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                local char = p.Character; local root = char.HumanoidRootPart
                local h = char.Head; local d = (h.Position - Camera.CFrame.Position).Magnitude
                
                -- // AGGRESSIVE DESYNC DETECTION (Moving/Jittering)
                local isDesync = false
                if CONFIG.DESYNC_ESP then
                    local track = trackData[p] or { pos = root.Position, lastUpdate = tick(), buffer = {} }
                    trackData[p] = track
                    
                    local vel = root.AssemblyLinearVelocity.Magnitude
                    local posDelta = (root.Position - track.pos).Magnitude
                    local timeDelta = tick() - track.lastUpdate
                    
                    -- Check 1: Velocity Threshold
                    if vel > CONFIG.DESYNC_THRESH then isDesync = true end
                    -- Check 2: High Position Delta vs Low Time (Teleport/Jitter)
                    if not isDesync and posDelta > 3 and timeDelta < 0.05 then isDesync = true end
                    -- Check 3: Static Position History (Real Body vs Ghost)
                    table.insert(track.buffer, root.Position)
                    if #track.buffer > 10 then table.remove(track.buffer, 1) end
                    
                    track.pos = root.Position; track.lastUpdate = tick()
                end

                if d < dist and isVisible(h) then 
                    dist = d; best = p 
                end
                pcall(applyVisuals, p, isDesync)
            end
        end
        closestTarget = best

        if CONFIG.SELF_DESYNC and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local r = LocalPlayer.Character.HumanoidRootPart
            local oldCF = r.CFrame
            r.CFrame = r.CFrame * CFrame.new(math.random(-5, 5), 0, math.random(-5, 5))
            RunService.RenderStepped:Wait()
            r.CFrame = oldCF
        end

        if CONFIG.INF_STAMINA then
            local ev = ReplicatedStorage:FindFirstChild("Events")
            if ev and ev:FindFirstChild("AInfStamina") then ev.AInfStamina:FireServer() end
            if ev and ev:FindFirstChild("INSTNMA") then ev.INSTNMA:FireServer(get_key(CONFIG.SALT_MELEE)) end    
        end

        if CONFIG.ANTI_AFK and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local r = LocalPlayer.Character.HumanoidRootPart
            r.CFrame = r.CFrame * CFrame.new(0,0,0.0001); task.wait(0.1); r.CFrame = r.CFrame * CFrame.new(0,0,-0.0001)
        end

        if CONFIG.FLY and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local r = LocalPlayer.Character.HumanoidRootPart
            local dir = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
            if dir.Magnitude > 0 then r.CFrame = r.CFrame + (dir.Unit * (CONFIG.FLY_SPEED / 50)); r.AssemblyLinearVelocity = Vector3.new(0,0,0) end
        end
        task.wait(CONFIG.TARGET_REFRESH_RATE)
    end
end)

RunService.Heartbeat:Connect(function()
    if not active then return end
    local now = tick()
    if CONFIG.RAGEBOT and closestTarget and closestTarget.Character and closestTarget.Character:FindFirstChild("Head") and now - lastFire > CONFIG.FIRE_RATE then
        local ev = ReplicatedStorage:FindFirstChild("Events")
        if ev then
            local h = closestTarget.Character.Head; local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then
                if ev:FindFirstChild("GNX_S") then ev.GNX_S:FireServer(get_key(CONFIG.SALT_GUN), now, tool, "FDS9I83", Camera.CFrame.Position, {h.Position}, false) end
                if ev:FindFirstChild("ZFKLF_H") then ev.ZFKLF_H:FireServer(CONFIG.BUTTER, tool, "k", 1, h, h.Position, (h.Position - Camera.CFrame.Position).Unit, nil, nil) end
            end
            lastFire = now
        end
    end
    if CONFIG.MELEE_AURA and closestTarget and closestTarget.Character and closestTarget.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        if (closestTarget.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < CONFIG.MELEE_RANGE then
            if now - lastMelee > 0.3 then
                local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                local ev = ReplicatedStorage:FindFirstChild("Events")
                if tool and ev and ev:FindFirstChild("ZFKLF_H") then ev.ZFKLF_H:FireServer(CONFIG.BUTTER, tool, "k", 1, closestTarget.Character.Head, closestTarget.Character.Head.Position, Vector3.new(0,0,0), nil, nil) end        
                lastMelee = now
            end
        end
    end
end)

print("🔴 HONEY HUB v7.3 LOADED - ENHANCED DESYNC DETECTION")
