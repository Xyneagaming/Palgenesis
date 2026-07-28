-- Palgenesis headless selftest (armed via PALGENESIS_SELFTEST=1, see main.lua).
-- Runs on the LOCAL dedicated server as the fast verify loop: boot server,
-- read verdict from UE4SS.log, kill server - no human, no GPU, no client.
--
-- Discipline (the frozen-clip lesson): the verdict line is narration; every
-- test prints its MEASURED numbers, and only tests that actually ran count.
-- Grep markers: [selftest] ... final line: SELFTEST_DONE pass=N fail=N
--
-- Tests:
--   T0 config-pair  : the Foxparks->Foxgloam pair exists in the config map
--   T1 waza-rows    : Foxgloam's level-move rows registered (expect 7)
--   T2 spawn        : SpawnNewCharacter materializes a Foxgloam actor
--   T3 spawn-ident  : the spawned actor's CharacterID reads Foxgloam

local M = {}

local function Log(msg)
    print(string.format("[Palvolve] [selftest] %s\n", msg))
end

local pass, fail = 0, 0
local function verdict(name, ok, detail)
    if ok then pass = pass + 1 else fail = fail + 1 end
    Log(string.format("%s %s: %s", ok and "PASS" or "FAIL", name, detail))
end

local function finish(note)
    Log(string.format("SELFTEST_DONE pass=%d fail=%d%s", pass, fail,
        note and (" (" .. note .. ")") or ""))
end

-- T0: config pair (pure Lua, no world needed)
local function testConfigPair()
    local ok, cfg = pcall(require, "config")
    if not (ok and cfg and cfg.map) then
        verdict("T0-config-pair", false, "config/map not loadable")
        return
    end
    local found = nil
    for _, p in ipairs(cfg.map) do
        if p.to == "Foxgloam" then found = p break end
    end
    verdict("T0-config-pair", found ~= nil, found
        and string.format("from=%s category=%s minLevel=%s enabled=%s",
            tostring(found.from), tostring(found.category), tostring(found.minLevel), tostring(found.enabled))
        or "no pair with to=Foxgloam in config map")
end

-- world-dependent tests, run once a world context exists
local function runWorldTests(wc)
    local util = StaticFindObject("/Script/Pal.Default__PalUtility")

    -- T1: waza rows
    local wazaCount = -1
    pcall(function()
        local db = util:GetWazaDatabase(wc)
        if db and db:IsValid() then
            local out = {}
            db:GetMasterrableWaza_BetweenLevel(FName("Foxgloam"), 1, 60, out)
            wazaCount = 0
            for _ in pairs(out) do wazaCount = wazaCount + 1 end
        end
    end)
    verdict("T1-waza-rows", wazaCount == 7,
        string.format("level-move rows for Foxgloam 1-60: %d (expected 7)", wazaCount))

    -- T2/T3: spawn a Foxgloam and identify it
    local charman = nil
    pcall(function() charman = util:GetCharacterManager(wc) end)
    if not (charman and charman:IsValid()) then
        verdict("T2-spawn", false, "no CharacterManager")
        finish("T3 skipped: no spawn")
        return
    end
    local before = {}
    for _, m in ipairs(FindAllOf("BP_MonsterBase_C") or {}) do
        if m:IsValid() then before[m:GetFullName()] = true end
    end
    local hp = 1000 * 400
    local init = {
        CharacterID = FName("Foxgloam"),
        Gender = 1, Level = 10,
        Talent_HP = 50, Talent_Melee = 50, Talent_Shot = 50, Talent_Defense = 50,
        FullStomach = 150.0,
        Hp = { Value = hp }, MaxHP = { Value = hp },
    }
    -- fixed ground coords in the starting-plateau region (measured from live
    -- roster logs 2026-07-28); floor adjustment on
    local spawnParam = {
        SpawnLocation = { X = -361900, Y = 270100, Z = 9000 },
        SpawnRotation = { Pitch = 0, Yaw = 0, Roll = 0 },
        SpawnScale = { X = 1, Y = 1, Z = 1 },
        SpawnCollisionHandlingOverride = 1,
        bAlwaysRelevant = false,
        bNeedAdjustToFloor = true,
        AdjustUpOffset = 50.0,
        bAdjustShortRayLength = false,
        bStartAsInactivePalCharacter = false,
    }
    local called = false
    for _, cbKind in ipairs({ "nil", "emptytable", "zero" }) do
        local okCall, errCall = pcall(function()
            if cbKind == "nil" then charman:SpawnNewCharacter(init, spawnParam, nil)
            elseif cbKind == "emptytable" then charman:SpawnNewCharacter(init, spawnParam, {})
            else charman:SpawnNewCharacter(init, spawnParam, 0) end
        end)
        Log(string.format("SpawnNewCharacter cb=%s ok=%s err=%s", cbKind, tostring(okCall), tostring(errCall)))
        if okCall then called = true break end
    end
    if not called then
        verdict("T2-spawn", false, "SpawnNewCharacter rejected every delegate form (errors above)")
        finish("T3 skipped: call rejected")
        return
    end

    -- watch for the newcomer (same guarded pattern as probes.spawnPal)
    local state = { finished = false, pending = false, tries = 0 }
    LoopAsync(500, function()
        if state.finished then return true end
        if state.pending then return false end
        state.pending = true
        ExecuteInGameThread(function()
            pcall(function()
                state.tries = state.tries + 1
                for _, m in ipairs(FindAllOf("BP_MonsterBase_C") or {}) do
                    if m:IsValid() and not before[m:GetFullName()] then
                        before[m:GetFullName()] = true
                        local id, lvl, moveCount = "?", -1, -1
                        pcall(function()
                            local p = m.CharacterParameterComponent:GetIndividualParameter()
                            id = p:GetCharacterID():ToString()
                            lvl = p:GetLevel()
                            moveCount = #p:GetMasteredWaza()
                        end)
                        local at = m:K2_GetActorLocation()
                        Log(string.format("newcomer id=%s lvl=%d moves=%d at (%.0f, %.0f, %.0f)",
                            id, lvl, moveCount, at.X, at.Y, at.Z))
                        if not state.finished and id == "Foxgloam" then
                            state.finished = true
                            verdict("T2-spawn", true, "actor materialized")
                            verdict("T3-spawn-ident", true,
                                string.format("CharacterID=%s level=%d masteredMoves=%d", id, lvl, moveCount))
                            finish()
                        end
                    end
                end
                if not state.finished and state.tries >= 20 then
                    state.finished = true
                    verdict("T2-spawn", false, "call accepted but no Foxgloam actor within ~10s")
                    finish("T3 skipped: nothing materialized")
                end
            end)
            state.pending = false
        end)
        return false
    end)
end

-- Arm: wait for a world context (the dedicated server loads its world
-- automatically; give it up to ~3 minutes)
Log("armed - waiting for world context")
testConfigPair()
local worldState = { started = false, tries = 0 }
LoopAsync(3000, function()
    if worldState.started then return true end
    worldState.tries = worldState.tries + 1
    ExecuteInGameThread(function()
        if worldState.started then return end
        pcall(function()
            local gs = FindFirstOf("PalGameStateInGame")
            if gs and gs:IsValid() then
                worldState.started = true
                Log(string.format("world context up after %d polls", worldState.tries))
                runWorldTests(gs)
            end
        end)
        if not worldState.started and worldState.tries >= 60 then
            worldState.started = true
            verdict("T-world", false, "no world context within ~3 minutes")
            finish("aborted: world never came up")
        end
    end)
    return false
end)

return M
