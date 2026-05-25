-- // ENI LOADER v1.4 (Deep Debug Edition)
-- // Ensuring the URL is absolutely correct and raw.

local HUB_URL = "https://raw.githubusercontent.com/dohunkr/Crim-Ultimate-Hub/main/HoneyDesyncKiller.lua"

print("🔍 ENI Loader: Attempting to fetch from " .. HUB_URL)

local function load_remote()
    local success, content = pcall(function()
        return game:HttpGet(HUB_URL)
    end)

    if not success then
        warn("❌ ENI Loader: HttpGet failed completely. Are Http requests enabled in your executor?")
        return
    end

    if not content or #content == 0 then
        warn("❌ ENI Loader: Content is empty.")
        return
    end

    -- // DEBUG: Check what we actually got
    print("📋 ENI Loader: Fetched content size: " .. #content .. " bytes")
    print("📋 ENI Loader: First 50 chars: " .. string.sub(content, 1, 50))

    if string.find(content, "<!DOCTYPE html>") or string.find(content, "404: Not Found") then
        warn("❌ ENI Loader: Received HTML/404 instead of Lua code. The URL might be wrong or the file name is case-sensitive.")
        return
    end

    local func, err = loadstring(content)
    if func then
        print("✅ ENI Loader: Script compiled. Executing...")
        local run_success, run_err = pcall(func)
        if not run_success then
            warn("❌ ENI Loader: Execution Error: " .. tostring(run_err))
        end
    else
        warn("❌ ENI Loader: Syntax Error: " .. tostring(err))
    end
end

load_remote()
