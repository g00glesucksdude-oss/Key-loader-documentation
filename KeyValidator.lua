-- CJK → Digit map
local REVERSE_CJK = {
    ["龉"] = "0", ["鬱"] = "1", ["龘"] = "2", ["霤"] = "3", ["颍"] = "4",
    ["煥"] = "5", ["縞"] = "6", ["鱻"] = "7", ["黷"] = "8", ["癵"] = "9"
}

-- Caesar reversal
local function reverseCaesar(text, shift)
    local result = {}
    for i = 1, #text do
        local c = text:sub(i, i)
        local byte = string.byte(c)
        if c:match("%a") then
            local base = (c:match("%u") and 65 or 97)
            table.insert(result, string.char((byte - base - shift) % 26 + base))
        elseif c:match("%d") then
            table.insert(result, tostring((tonumber(c) - shift) % 10))
        else
            table.insert(result, c)
        end
    end
    return table.concat(result)
end

-- Deobfuscate digits
local function deobfDigits(cjk)
    local result = {}
    for i = 1, #cjk do
        local sym = cjk:sub(i, i)
        table.insert(result, REVERSE_CJK[sym] or "?")
    end
    return table.concat(result)
end

-- Deobfuscate letters (numeric → text)
local function deobfLetters(numeric)
    local result = {}
    for i = 1, #numeric, 2 do
        local code = tonumber(numeric:sub(i, i+1))
        if code then
            table.insert(result, string.char(code + 64))
        end
    end
    return table.concat(result)
end

-- Nonce tracker
local usedNonces = {}

-- Main validator entry
return function(key)
    local parts = string.split(key, ":")
    if #parts ~= 2 then return false, "Invalid key format" end

    local ciphered, shift = parts[1], tonumber(parts[2])
    if not shift then return false, "Invalid Caesar shift" end

    local raw = reverseCaesar(ciphered, shift)
    local segments = string.split(raw, "_")
    if #segments ~= 4 then return false, "Malformed key payload" end

    local startUnix = tonumber(deobfDigits(segments[1]))
    local expiryUnix = tonumber(deobfDigits(segments[2]))
    local fileID = deobfLetters(segments[3])
    local nonce = deobfDigits(segments[4])

    if not startUnix or not expiryUnix then
        return false, "Invalid timestamps"
    end

    if usedNonces[nonce] then
        return false, "Replay detected: key already used"
    end

    local now = os.time()
    if now < startUnix then
        return false, "Key not yet valid"
    elseif now > expiryUnix then
        return false, "Key expired"
    end

    usedNonces[nonce] = true
    return true, "✅ Key is valid", {
        startTime = startUnix,
        expiryTime = expiryUnix,
        githubFileID = fileID,
        nonce = nonce
    }
end
