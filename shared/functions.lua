NA = NA or {}
NA.Server = {}
NA.Client = {}
NA.Players = NA.Players or {}
NA.Events = NA.Events or {}
NA.Timers = NA.Timers or {}

function NA.Debug(...)
    if NexusAftermath.Config.debug then
        print('[NA] ' .. table.concat({...}, ' '))
    end
end

function NA.Round(value, decimals)
    if decimals then return math.floor((value * 10^decimals) + 0.5) / (10^decimals) end
    return math.floor(value + 0.5)
end

function NA.Clamp(value, min, max)
    return math.min(math.max(value, min), max)
end

function NA.Lerp(a, b, t)
    return a + (b - a) * NA.Clamp(t, 0, 1)
end

function NA.RandomRange(min, max)
    return min + math.random() * (max - min)
end

function NA.RandomInt(min, max)
    return math.floor(NA.RandomRange(min, max + 1))
end

function NA.GetRandomString(length)
    local chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*'
    local result = ''
    for i = 1, length do
        result = result .. chars:sub(math.random(1, #chars), math.random(1, #chars))
    end
    return result
end

function NA.VectorToTable(vec)
    if type(vec) == 'table' then return vec end
    return { x = vec.x, y = vec.y, z = vec.z }
end

function NA.Distance(a, b)
    if type(a) == 'number' and type(b) == 'number' then
        return math.abs(a - b)
    end
    local function getCoords(v)
        local t = type(v)
        if t == 'vector3' then return v.x, v.y, v.z end
        if t == 'table' then return v.x or v[1] or 0, v.y or v[2] or 0, v.z or v[3] or 0 end
        return 0, 0, 0
    end
    local ax, ay, az = getCoords(a)
    local bx, by, bz = getCoords(b)
    local dx, dy, dz = bx - ax, by - ay, bz - az
    return math.sqrt(dx*dx + dy*dy + dz*dz)
end

function NA.TableSize(tbl)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
end

function NA.TableFind(tbl, value)
    for k, v in pairs(tbl) do
        if v == value then return k end
    end
    return nil
end

function NA.TableRandom(tbl)
    local keys = {}
    for k in pairs(tbl) do keys[#keys+1] = k end
    if #keys == 0 then return nil end
    return tbl[keys[math.random(#keys)]]
end

function NA.SerializeForDb(data)
    return json.encode(data)
end

function NA.DeserializeFromDb(data)
    if type(data) == 'string' then
        local success, result = pcall(json.decode, data)
        if success then return result end
    end
    return data or {}
end

function NA.FormatTime(seconds)
    local s = math.floor(seconds % 60)
    local m = math.floor((seconds / 60) % 60)
    local h = math.floor((seconds / 3600) % 24)
    local d = math.floor(seconds / 86400)
    if d > 0 then return string.format('%dd %dh %dm %ds', d, h, m, s) end
    if h > 0 then return string.format('%dh %dm %ds', h, m, s) end
    if m > 0 then return string.format('%dm %ds', m, s) end
    return string.format('%ds', s)
end

function NA.MergeTables(t1, t2)
    local result = {}
    for k, v in pairs(t1) do result[k] = type(v) == 'table' and NA.MergeTables(v, {}) or v end
    for k, v in pairs(t2) do result[k] = type(v) == 'table' and NA.MergeTables(result[k] or {}, v) or v end
    return result
end

function NA.Signature(data)
    local hash = 0
    local str = json.encode(data)
    for i = 1, #str do
        local byte = string.byte(str, i)
        hash = ((hash << 5) - hash) + byte
        hash = hash & 0xFFFFFFFF
    end
    return string.format('%08x', hash & 0x7FFFFFFF)
end

function NA.GetPlayer(source)
    return NA.Players[source]
end

function NA.GetPlayerByCitizenId(citizenId)
    for _, player in pairs(NA.Players) do
        if player.charData and player.charData.citizenId == citizenId then
            return player
        end
    end
    return nil
end

function NA.GetOnlinePlayers()
    local players = {}
    for src in pairs(NA.Players) do
        players[#players+1] = src
    end
    return players
end

function NA.GetPlayersInRange(coords, range)
    local nearby = {}
    for src, player in pairs(NA.Players) do
        if player.ped then
            local dist = NA.Distance(coords, GetEntityCoords(player.ped))
            if dist <= range then
                nearby[src] = { player = player, distance = dist }
            end
        end
    end
    return nearby
end

function NA.RegisterServerCallback(name, cb)
    NA.Events[name] = cb
    RegisterServerEvent('na:' .. name)
    AddEventHandler('na:' .. name, function(source, ...)
        local args = { ... }
        local cbId = table.remove(args)
        if cbId then
            cb(source, function(...)
                TriggerClientEvent('na:callback', source, cbId, { ... })
            end, table.unpack(args))
        end
    end)
end

function NA.RegisterNetEvent(name, cb)
    RegisterServerEvent('na:' .. name)
    AddEventHandler('na:' .. name, cb)
end

function NA.TriggerClientCallback(source, name, cb, ...)
    local cbId = NA.GetRandomString(16)
    if not NA.ClientCallbacks then NA.ClientCallbacks = {} end
    NA.ClientCallbacks[cbId] = cb
    TriggerClientEvent('na:' .. name, source, ..., cbId)
end

function NA.ShowNotification(source, msg, type, length)
    type = type or 'info'
    length = length or 4000
    TriggerClientEvent('na:notification', source, { message = msg, type = type, length = length })
end

function NA.ShowAdvancedNotif(source, title, subtitle, text, icon)
    TriggerClientEvent('na:advancedNotif', source, { title = title, subtitle = subtitle, text = text, icon = icon or 'CHAR_DEFAULT' })
end

function NA.Log(source, action, data)
    local player = NA.GetPlayer(source)
    local citizenId = player and player.charData and player.charData.citizenId or 'unknown'
    NA.Debug('[LOG] [' .. action .. '] Player: ' .. citizenId .. ' | Data: ' .. json.encode(data))
    TriggerEvent('na:log', { timestamp = os.time(), action = action, citizenId = citizenId, data = data, source = source })
end

function NA.BroadcastToStaff(msg)
    for src, player in pairs(NA.Players) do
        if player.charData and player.charData.isStaff then
            NA.ShowNotification(src, '[STAFF] ' .. msg, 'staff', 8000)
        end
    end
end
