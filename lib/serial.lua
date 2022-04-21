-- Practically this whole file was stolen from textutils
-- All I did was modify it so it doesn't error and ignores fields that are functions
-- 
serial = {}

local g_tLuaKeywords = {
  [ "and" ] = true,
  [ "break" ] = true,
  [ "do" ] = true,
  [ "else" ] = true,
  [ "elseif" ] = true,
  [ "end" ] = true,
  [ "false" ] = true,
  [ "for" ] = true,
  [ "function" ] = true,
  [ "if" ] = true,
  [ "in" ] = true,
  [ "local" ] = true,
  [ "nil" ] = true,
  [ "not" ] = true,
  [ "or" ] = true,
  [ "repeat" ] = true,
  [ "return" ] = true,
  [ "then" ] = true,
  [ "true" ] = true,
  [ "until" ] = true,
  [ "while" ] = true,
}

local function serializeImpl( t, tTracking, sIndent )
    local sType = type(t)
    if sType == "table" then
        if tTracking[t] ~= nil then
            error( "Cannot serialize table with recursive entries", 0 )
        end
        tTracking[t] = true

        if next(t) == nil then
            -- Empty tables are simple
            return "{}"
        else
            -- Other tables take more work
            local sResult = "{\n"
            local sSubIndent = sIndent .. "  "
            local tSeen = {}
            for k,v in ipairs(t) do
                tSeen[k] = true
                sResult = sResult .. sSubIndent .. serializeImpl( v, tTracking, sSubIndent ) .. ",\n"
            end
            for k,v in pairs(t) do
                if not tSeen[k] then
                    local sEntry
                    if type(k) == "string" and not g_tLuaKeywords[k] and string.match( k, "^[%a_][%a%d_]*$" ) then
                        sEntry = k .. " = " .. serializeImpl( v, tTracking, sSubIndent ) .. ",\n"
                    else
                        sEntry = "[ " .. serializeImpl( k, tTracking, sSubIndent ) .. " ] = " .. serializeImpl( v, tTracking, sSubIndent ) .. ",\n"
                    end
                    sResult = sResult .. sSubIndent .. sEntry
                end
            end
            sResult = sResult .. sIndent .. "}"
            return sResult
        end
        
    elseif sType == "string" then
        return string.format( "%q", t )
    
    elseif sType == "number" or sType == "boolean" or sType == "nil" then
        return tostring(t)
      
    else
      return string.format("%q", type(t))

    end
end

empty_json_array = {}

local function serializeJSONImpl( t, tTracking, bNBTStyle )
    local sType = type(t)
    if t == empty_json_array then
        return "[]"

    elseif sType == "table" then
        if tTracking[t] ~= nil then
            error( "Cannot serialize table with recursive entries", 0 )
        end
        tTracking[t] = true

        if next(t) == nil then
            -- Empty tables are simple
            return "{}"
        else
            -- Other tables take more work
            local sObjectResult = "{"
            local sArrayResult = "["
            local nObjectSize = 0
            local nArraySize = 0
            for k,v in pairs(t) do
                if type(k) == "string" then
                    local sEntry
                    if bNBTStyle then
                        sEntry = tostring(k) .. ":" .. serializeJSONImpl( v, tTracking, bNBTStyle )
                    else
                        sEntry = string.format( "%q", k ) .. ":" .. serializeJSONImpl( v, tTracking, bNBTStyle )
                    end
                    if nObjectSize == 0 then
                        sObjectResult = sObjectResult .. sEntry
                    else
                        sObjectResult = sObjectResult .. "," .. sEntry
                    end
                    nObjectSize = nObjectSize + 1
                end
            end
            for n,v in ipairs(t) do
                local sEntry = serializeJSONImpl( v, tTracking, bNBTStyle )
                if nArraySize == 0 then
                    sArrayResult = sArrayResult .. sEntry
                else
                    sArrayResult = sArrayResult .. "," .. sEntry
                end
                nArraySize = nArraySize + 1
            end
            sObjectResult = sObjectResult .. "}"
            sArrayResult = sArrayResult .. "]"
            if nObjectSize > 0 or nArraySize == 0 then
                return sObjectResult
            else
                return sArrayResult
            end
        end

    elseif sType == "string" then
        return string.format( "%q", t )

    elseif sType == "number" or sType == "boolean" then
        return tostring(t)

    end
end

function serial.serialize( t )
    local tTracking = {}
    return serializeImpl( t, tTracking, "" )
end

function serial.unserialize( s )
    if type( s ) ~= "string" then
        error( "bad argument #1 (expected string, got " .. type( s ) .. ")", 2 )
    end
    local func = load( "return "..s, "unserialize", "t", {} )
    if func then
        local ok, result = pcall( func )
        if ok then
            return result
        end
    end
    return nil
end

return serial