-- // HONEY HUB LOADER v1.5 (Protected)
-- // DO NOT SHARE THIS LOADER SOURCE.

local HUB_URL = "https://raw.githubusercontent.com/dohunkr/Crim-Ultimate-Hub/main/HoneyDesyncKiller.lua"

print("🔍 HoneyHub: Loading...")

local function load_remote()
    local success, content = pcall(function()
        return game:HttpGet(HUB_URL)
    end)

    if not success or not content then
        warn("❌ HoneyHub: Failed to fetch script.")
        return
    end

    local func, err = loadstring(content)
    if func then
        pcall(func)
        print("✅ HoneyHub: Loaded successfully.")
    else
        warn("❌ HoneyHub: Syntax Error: " .. tostring(err))
    end
end

load_remote()
