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

    -- T1: waza rows, read the TERRITORY: row names straight off the data
    -- table (first run's db-API count returned 1 with no loader errors -
    -- the TMap out-param marshaling is the suspect, so it is demoted to a
    -- secondary reading below).
    local rowCount = -1
    pcall(function()
        local dt = StaticFindObject("/Game/Pal/DataTable/Waza/DT_WazaMasterLevel.DT_WazaMasterLevel")
        local lib = StaticFindObject("/Script/Engine.Default__DataTableFunctionLibrary")
        if dt and dt:IsValid() and lib and lib:IsValid() then
            local names = {}
            lib:GetDataTableRowNames(dt, names)
            rowCount = 0
            for i = 1, #names do
                local n = names[i]
                if type(n) == "userdata" then pcall(function() n = n:get() end) end
                local s = tostring(n)
                pcall(function() s = n:ToString() end)
                if s:match("^Foxgloam%d+$") then rowCount = rowCount + 1 end
            end
        end
    end)
    verdict("T1-waza-rows", rowCount == 7,
        string.format("Foxgloam* rows in DT_WazaMasterLevel: %d (expected 7)", rowCount))
    -- secondary: the db API's view (known-suspect marshaling, logged for comparison)
    pcall(function()
        local db = util:GetWazaDatabase(wc)
        local out = {}
        db:GetMasterrableWaza_BetweenLevel(FName("Foxgloam"), 1, 60, out)
        local c = 0
        for k, v in pairs(out) do
            c = c + 1
            Log(string.format("T1-secondary db-api entry: k=%s v=%s", tostring(k), tostring(v)))
        end
        Log(string.format("T1-secondary db-api count=%d (table-read above is authoritative)", c))
    end)

    -- T2/T3: spawn a Foxgloam and identify it.
    -- STATUS 2026-07-28: SKIPPED pending the native bridge. The harness
    -- proved every Lua-side delegate form dead: nil, {} and 0 all fail-fast
    -- the process (0xC0000409, uncatchable), and omitting the argument is
    -- rejected (UFunction expected 4 parameters, received 2). Calling
    -- SpawnNewCharacter requires a properly constructed delegate, which only
    -- the C++ companion can supply (PalgenesisNative_Spawn, not yet built -
    -- needs VS2022+Rust+Epic-linked GitHub for the RE-UE4SS tree).
    -- Actor instantiation of custom pals is meanwhile field-proven via the
    -- evolve respawn path (client, 2026-07-28).
    if type(PalgenesisNative_Spawn) ~= "function" then
        Log("SKIP T2-spawn: needs PalgenesisNative_Spawn (native bridge not built)")
        Log("SKIP T3-spawn-ident: depends on T2")
        finish("T2/T3 skipped: native bridge pending")
        return
    end
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
    -- Delegate ladder v3: nil AND {} both fail-fast the process (0xC0000409,
    -- harness runs 1-2), uncatchable from Lua. Remaining candidates: omit
    -- the argument entirely (UE4SS may zero-init the missing param or raise
    -- a catchable error), then integer 0. Each attempt logs BEFORE the call
    -- so a crash names its rung.
    local called = false
    for _, cbKind in ipairs({ "omitted", "zero" }) do
        Log(string.format("SpawnNewCharacter attempting cb=%s ...", cbKind))
        local okCall, errCall = pcall(function()
            if cbKind == "omitted" then charman:SpawnNewCharacter(init, spawnParam)
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
