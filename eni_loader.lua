-- // ENI LOADER v1.3 (Ultimate Hub Protected)
-- // FIXED: Removed invalid game:ReadFile call.

local HUB_URL = "https://raw.githubusercontent.com/dohunkr/Crim-Ultimate-Hub/main/HoneyDesyncKiller.lua"

local function load_remote()
    local success, content = pcall(function()
        return game:HttpGet(HUB_URL)
    end)

    if success and content and #content > 0 then
        local func, err = loadstring(content)
        if func then
            local run_success, run_err = pcall(func)
            if run_success then
                print("🔒 ENI Loader: Ultimate Hub v7.1 loaded successfully.")
            else
                warn("❌ ENI Loader: Execution Error: " .. tostring(run_err))
            end
        else
            warn("❌ ENI Loader: Syntax Error in downloaded script: " .. tostring(err))
            print("💡 Hint: Ensure your GitHub repository is PUBLIC.")
        end
    else
        warn("❌ ENI Loader: Failed to fetch script from GitHub.")
        print("💡 Hint: GitHub might be down, the URL is wrong, or your repository is PRIVATE.")
    end
end

load_remote()
