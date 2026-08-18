-- dps-rotations: deterministic location rotation for DB-backed rcore systems.
-- Runs once at resource start (server boot). If any pool's period changed since
-- the last application, the new location is written and the target resource is
-- restarted once so its caches reload.

local APPLIED_ANY = false

-- Deterministic index: FNV-1a over jobId + period key, so two jobs with the
-- same cadence don't move in lockstep.
local function poolIndex(jobId, periodKey, forcedOffset, poolSize)
    local hash = 2166136261
    local s = jobId .. '|' .. periodKey
    for i = 1, #s do
        hash = (hash ~ s:byte(i)) & 0xFFFFFFFF
        hash = (hash * 16777619) & 0xFFFFFFFF
    end
    return ((hash + (forcedOffset or 0)) % poolSize) + 1
end

local function periodKey(cadence)
    if cadence == 'weekly' then
        return os.date('%G-W%V')  -- ISO week
    end
    return os.date('%Y-%m-%d')    -- daily
end

-- One prop table placed just behind the dealer, from the dealer's heading —
-- keeps the scene dressed without hand-placing objects per pool entry.
local function dealerObjects(loc)
    local rad = math.rad((loc.h or 0) + 180.0)
    local ox = loc.x - math.sin(rad) * 1.2
    local oy = loc.y + math.cos(rad) * 1.2
    return json.encode({ { x = ox, y = oy, z = loc.z - 0.6, model = 'prop_rub_table_02', h = loc.h or 0 } })
end

local function applyDealer(job, loc)
    return MySQL.update.await(
        'UPDATE rcore_drugs_dealer_locations SET label = ?, marker_x = ?, marker_y = ?, marker_z = ?, dealer_x = ?, dealer_y = ?, dealer_z = ?, dealer_h = ?, objects = ? WHERE dealer_type = ?',
        { loc.label, loc.x, loc.y, loc.z, loc.x, loc.y, loc.z, loc.h or 0.0, dealerObjects(loc), job.dealer_type }
    )
end

local function applyHarvest(job, loc)
    return MySQL.update.await(
        'UPDATE rcore_drugs_harvests SET name = ?, coords = ? WHERE id = ?',
        { loc.label, json.encode({ { x = loc.x, y = loc.y, z = loc.z } }), job.row_id }
    )
end

local function ensureStateTable()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS dps_rotations_state (
            id VARCHAR(40) PRIMARY KEY,
            last_key VARCHAR(40) NOT NULL,
            forced_offset INT NOT NULL DEFAULT 0,
            applied_label VARCHAR(120) DEFAULT NULL,
            applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
    ]])
end

local function loadState(id)
    local rows = MySQL.query.await('SELECT last_key, forced_offset FROM dps_rotations_state WHERE id = ?', { id })
    return rows and rows[1] or nil
end

local function saveState(id, key, offset, label)
    MySQL.query.await(
        'INSERT INTO dps_rotations_state (id, last_key, forced_offset, applied_label) VALUES (?, ?, ?, ?) ' ..
        'ON DUPLICATE KEY UPDATE last_key = VALUES(last_key), forced_offset = VALUES(forced_offset), applied_label = VALUES(applied_label)',
        { id, key, offset, label }
    )
end

local function runJob(job, force)
    local key = periodKey(job.cadence)
    local state = loadState(job.id)
    local offset = state and state.forced_offset or 0

    if force then
        offset = offset + 1
    elseif state and state.last_key == key then
        return false -- already applied for this period
    end

    local idx = poolIndex(job.id, key, offset, #job.pool)
    local loc = job.pool[idx]

    local ok
    if job.target == 'dealer' then
        ok = applyDealer(job, loc)
    elseif job.target == 'harvest' then
        ok = applyHarvest(job, loc)
    end

    if ok and ok > 0 then
        saveState(job.id, key, offset, loc.label)
        print(('[dps-rotations] %s -> %s (period %s, slot %d/%d)'):format(job.id, loc.label, key, idx, #job.pool))
        return true
    end

    print(('[dps-rotations] WARNING: %s matched no rows — target missing? (period %s)'):format(job.id, key))
    return false
end

local function restartTarget()
    SetTimeout(Config.RestartDelayMs, function()
        print(('[dps-rotations] reloading %s to pick up rotated locations'):format(Config.RestartResource))
        ExecuteCommand('restart ' .. Config.RestartResource)
    end)
end

AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    CreateThread(function()
        ensureStateTable()
        local applied = false
        for _, job in ipairs(Config.Rotations) do
            if runJob(job, false) then applied = true end
        end
        if applied then
            APPLIED_ANY = true
            restartTarget()
        else
            print('[dps-rotations] all pools current for their periods — nothing to move')
        end
    end)
end)

-- /rotate <jobId|all> — force-advance a pool (ace: dps.rotations)
RegisterCommand('rotate', function(source, args)
    if source ~= 0 and not IsPlayerAceAllowed(source, Config.RotateAce) then
        print(('[dps-rotations] rotate denied for %s'):format(GetPlayerName(source) or source))
        return
    end
    local which = args[1] or 'all'
    CreateThread(function()
        local applied = false
        for _, job in ipairs(Config.Rotations) do
            if which == 'all' or job.id == which then
                if runJob(job, true) then applied = true end
            end
        end
        if applied then restartTarget() end
    end)
end, true)
