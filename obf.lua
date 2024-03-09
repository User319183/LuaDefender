local usedVarNames = {}
local luaKeywords = {
    "and", "break", "do", "else", "elseif", "end", "false", "for", "function", "if", "in", "local", "nil", "not", "or", "repeat", "return", "then", "true", "until", "while"
}

local function generateRandomVarName(maxLength)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"
    local varName
    repeat
        varName = ""
        local length = math.random(1, maxLength)  -- Generate names with length between 1 and maxLength
        for i = 1, length do
            local randIndex = math.random(#chars)
            varName = varName .. string.sub(chars, randIndex, randIndex)
        end
        -- Add random prefix and suffix
        local prefix = string.sub(chars, math.random(#chars), math.random(#chars))
        local suffix = string.sub(chars, math.random(#chars), math.random(#chars))
        varName = prefix .. varName .. suffix
        -- var cant start with a number
        if tonumber(string.sub(varName, 1, 1)) then
            varName = "_" .. varName
        end
    until not (usedVarNames[varName] or table.concat(luaKeywords, " "):find(varName))
    usedVarNames[varName] = true
    return varName
end

local function generateRandomCondition()
    local x = math.random(100)
    local conditions = {
        string.format("%d == %d", x, x),  -- always true
        string.format("%d < %d + 1", x, x),  -- always true
        string.format("%d > %d + 1", x, x),  -- always false
        string.format("%d ~= %d", x, x)  -- always false
    }
    return conditions[math.random(#conditions)]
end

local function obfuscate_require(code, identifier_map)
    return string.gsub(code, "require%s-%(%s-[\"'](%w+)[\"']%s-%)", function(module)
        local obfuscated_module = generateRandomVarName(10)
        identifier_map[module] = obfuscated_module
        return "require('" .. obfuscated_module .. "')"
    end)
end

-- WORK IN PROGRESS
-- local function obfuscate_goto(code, identifier_map)


local function obfuscate_code(code)
    local obfuscated_code = code
    local identifier_map = {}
    local identifier_counter = 0

    -- Add standard Lua functions to the identifier_map
    local luaFunctions = {"print", "io", "string", "math", "table", "os", "coroutine", "debug", "package", "utf8"}
    for _, func in ipairs(luaFunctions) do
        identifier_counter = identifier_counter + 1
        local obfuscated_identifier = generateRandomVarName(identifier_counter)
        identifier_map[func] = obfuscated_identifier
    end
    
    local function obfuscate_identifier(identifier)
        -- Skip obfuscation if the identifier is a standard Lua function or 'average'
        if not luaFunctions[identifier] and identifier ~= 'average' then
            if not identifier_map[identifier] then
                identifier_counter = identifier_counter + 1
                local obfuscated_identifier = generateRandomVarName(identifier_counter)
                identifier_map[identifier] = obfuscated_identifier
            end

            -- Use a global pattern match to replace all instances of the identifier
            obfuscated_code = string.gsub(obfuscated_code, "%f[%a]"..identifier.."%f[%A]", identifier_map[identifier])
        end
    end

    -- Obfuscate identifiers that are actually defined in the code
    for identifier in string.gmatch(code, "(%a+)%s-=%s-.+") do
        obfuscate_identifier(identifier)
    end

    -- Obfuscate table fields
    obfuscated_code = string.gsub(obfuscated_code, "(%w+)%s-%.%s-(%w+)", function(table, field)
        obfuscate_identifier(field)
        return table .. "." .. (identifier_map[field] or field)
    end)

    -- Obfuscate table keys
    obfuscated_code = string.gsub(obfuscated_code, "{%s-(%b[])%s-=%s-.-%s-}", function(key)
        local is_string = string.sub(key, 2, 2) == "\"" or string.sub(key, 2, 2) == "'"
        local is_variable = string.sub(key, 2, 2) ~= "\"" and string.sub(key, 2, 2) ~= "'"
        local identifier = is_string and string.sub(key, 3, -3) or string.sub(key, 2, -2)
        if is_variable then
            obfuscate_identifier(identifier)
        end
        local obfuscated_key = identifier_map[identifier] or identifier
        if is_string then
            return "{[\"" .. obfuscated_key .. "\"] = " .. key .. "}"
        else
            return "{[" .. obfuscated_key .. "] = " .. key .. "}"
        end
    end)

    for identifier in string.gmatch(code, "function%s+(%a+)") do
        obfuscate_identifier(identifier)
    end

    for identifier in string.gmatch(code, "(%a+)%s-=%s-.+") do
        obfuscate_identifier(identifier)
    end

    for identifier in string.gmatch(code, "function%s+(%a+)") do
        obfuscate_identifier(identifier)
    end

    for functionName in string.gmatch(code, "function%s+(%w+)") do
        obfuscate_identifier(functionName)
    end

    for varName in string.gmatch(code, "for%s+(%a+)%s-,") do
        obfuscate_identifier(varName)
    end

    -- Code Injection: Add dead code
    for i = 1, math.random(5) do
        local dead_code = "\ndo\n    local " .. generateRandomVarName(10) .. " = 0\nend\n"
        obfuscated_code = obfuscated_code .. dead_code
    end

    -- Code Injection: Add redundant code
    for i = 1, math.random(5) do
        local redundant_code = "\ndo\n    local " .. generateRandomVarName(10) .. " = 1 + 1\nend\n"
        obfuscated_code = obfuscated_code .. redundant_code
    end

    -- Obfuscate require statements
    obfuscated_code = obfuscate_require(obfuscated_code, identifier_map)

    -- Obfuscate goto statements - BROKEN
    -- obfuscated_code = obfuscate_goto(obfuscated_code, identifier_map)

    -- Control Flow Obfuscation: Add unnecessary conditional statements and loops
    for i = 1, math.random(5) do
        local control_flow_obfuscation = ""
        local control_flow_type = math.random(3)
        if control_flow_type == 1 then
            -- if-else chain
            control_flow_obfuscation = "\nif " .. generateRandomCondition() .. " then\n    local " .. generateRandomVarName(10) .. " = 1\nelse\n    local " .. generateRandomVarName(10) .. " = 2\nend\n"
        elseif control_flow_type == 2 then
            -- for loop
            control_flow_obfuscation = "\nfor i = 1, " .. math.random(5) .. " do\n    local " .. generateRandomVarName(10) .. " = i\nend\n"
        else
            -- while loop
            local varName = generateRandomVarName(10)
            control_flow_obfuscation = "\nlocal " .. varName .. " = " .. math.random(5) .. "\nwhile " .. varName .. " > 0 do\n    " .. varName .. " = " .. varName .. " - 1\nend\n"
        end
        obfuscated_code = obfuscated_code .. control_flow_obfuscation
    end
    

    -- Arithmetic Obfuscation: Replace '+' with '- -' or '* 2 -'
    local arithmetic_transformations = {
        function(a, b) return a .. " - -" .. b end,
        function(a, b) return "(" .. a .. " * 2) - " .. a .. " + " .. b end
    }
    obfuscated_code = string.gsub(obfuscated_code, "(%w+)%s-%+%s-(%w+)", function(a, b)
        local transformation = arithmetic_transformations[math.random(#arithmetic_transformations)]
        return transformation(a, b)
    end)

    -- Boolean Obfuscation: Replace 'true' with dynamically generated expressions
    obfuscated_code = string.gsub(obfuscated_code, "true", function()
        local x = math.random(100)
        local y = math.random(100)
        local expressions = {
            string.format("(%d == %d) or (%d < %d)", x, x, y, x),  -- always true
            string.format("(%d < %d) and not (%d > %d)", x, y, x, y),  -- always true
            string.format("not (%d > %d)", x, x),  -- always true
            string.format("(%d ~= %d) or (%d > %d)", x, y, x, y),  -- always true
            string.format("(%d == %d) and (%d < %d)", x, y, y, x),  -- always false
            string.format("(%d > %d) and not (%d < %d)", x, y, x, y),  -- always false
            string.format("not (%d == %d)", x, x),  -- always false
            string.format("(%d ~= %d) and (%d > %d)", x, x, x, y)  -- always false
        }
        return expressions[math.random(#expressions)]
    end)

    return obfuscated_code
end


local function read_file(filename)
    local file, err = io.open(filename, "r")
    if file == nil then
        error("Couldn't open " .. filename .. ": " .. err)
    end
    local code = file:read("*all")
    file:close()
    return code
end

local function write_file(filename, content)
    local file, err = io.open(filename, "w")
    if file == nil then
        error("Couldn't open " .. filename .. ": " .. err)
    end
    file:write("G = {}\n")
    file:write("G.ObfuscatedWithLuaDefender = true\n")
    file:write("G.ObfuscatedByUser319183sOpenSourceObfuscator = true\n")
    file:write("User319183OnTop = true\n")
    file:write(content)
    file:close()
end

local function minify_code(code)
    local minified_code = code

    -- Remove comments
    minified_code = string.gsub(minified_code, "%-%-[^\n]*", "")

    -- Remove unnecessary white spaces
    minified_code = string.gsub(minified_code, "%s+", " ")
    minified_code = string.gsub(minified_code, "%s*([%(%){}%[%]=,])%s*", "%1")

    -- Remove new lines, but not after 'do' or 'end'
    minified_code = string.gsub(minified_code, "([^\ndo])\n([^\nend])", "%1 %2")

    return minified_code
end

local code = read_file("script.lua")
local obfuscated_code = obfuscate_code(code)
local minified_code = minify_code(obfuscated_code)
write_file("obfs.lua", minified_code)