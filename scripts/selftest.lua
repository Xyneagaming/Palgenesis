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
    -- native bridge present: INACTIVE spawn (individual + handle, no actor).
    -- An empty dedicated server streams no terrain, and an active spawn into
    -- unloaded world killed the process (harness 2026-07-28). Actor-level
    -- proof lives client-side, where the world around a player is loaded.
    -- Identity comes from the native readback: the handle's own individual
    -- parameter reports its CharacterID in the message.
    -- EquipWaza: real spawns ALWAYS carry >=1 equipped move (the 18-call
    -- spawnhook capture); pass the species' first learnable waza. The db's
    -- TMap out-param marshals as a wrapper table keyed OutMap.
    local firstWaza, bestLvl = 0, 999
    pcall(function()
        local db = util:GetWazaDatabase(wc)
        local out = {}
        db:GetMasterrableWaza_BetweenLevel(FName("Foxgloam"), 1, 60, out)
        for k, v in pairs(out.OutMap or out) do
            local kk, vv = k, v
            if type(kk) == "userdata" then pcall(function() kk = kk:get() end) end
            if type(vv) == "userdata" then pcall(function() vv = vv:get() end) end
            kk, vv = tonumber(kk), tonumber(vv)
            if kk and vv and vv < bestLvl then bestLvl = vv; firstWaza = kk end
        end
    end)
    Log(string.format("first learnable waza enum=%d (at level %d)", firstWaza, bestLvl))
    local okNat, natOk, natMsg = pcall(PalgenesisNative_Spawn, "Foxgloam", 10, -361900, 270100, 9000, 1, firstWaza)
    Log(string.format("PalgenesisNative_Spawn ok=%s result=%s msg=%s",
        tostring(okNat), tostring(natOk), tostring(natMsg)))
    if not (okNat and natOk) then
        verdict("T2-spawn", false, "native spawn refused: " .. tostring(natMsg or natOk))
        finish("T3 skipped: call refused")
        return
    end
    verdict("T2-spawn", tostring(natMsg):find("handle") ~= nil,
        "native call ok: " .. tostring(natMsg))
    verdict("T3-spawn-ident", tostring(natMsg):find("id=Foxgloam") ~= nil,
        "identity readback from the spawned individual: " .. tostring(natMsg))
    finish()
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
