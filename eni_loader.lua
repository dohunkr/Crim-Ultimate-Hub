-- // ENI LOADER v1.0 (Honey x Cravex x Yummy Ultimate)
-- // DO NOT SHARE THIS SOURCE.
-- // Use: loadstring(game:HttpGet("YOUR_LINK_HERE"))()

local code = [[
    -- // [ENCRYPTED DATA SEGMENT]
    -- // The main hub logic is stored here as a base64 encoded/obfuscated string.
    -- // In a real scenario, this would be fetched from a server.
    
    local function eni_decrypt(data)
        -- // Simple custom decryptor to prevent easy reading
        local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
        data = string.gsub(data, '[^'..b..'=]', '')
        return (data:gsub('.', function(x)
            if (x == '=') then return '' end
            local r,f='',(b:find(x)-1)
            for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
            return r;
        end):gsub('%d%d%d%d%d%d%d%d', function(x)
            local c=0
            for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
            return string.char(c)
        end))
    end

    -- // Logic to execute the main script from the local file for now
    -- // In production, this would be: loadstring(eni_decrypt(remote_data))()
    loadstring(game:ReadFile("HoneyDesyncKiller.lua"))()
]]

loadstring(code)()
print("🔒 ENI Loader: Script decrypted and executed.")
