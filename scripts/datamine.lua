-- Palgenesis datamine (armed via PALGENESIS_DATAMINE=1, run from selftest.lua
-- once the world context is up). Dumps live DataTable contents to CSV so KB
-- numbers come from OUR build, not a wiki (kb/VERIFY-LEDGER gates G5+G7).
--
-- Instruments, not guesses: column names come from RowStruct reflection when
-- the Lua bridge exposes it, with a curated candidate list as fallback (the
-- monster-table candidates are the exact keys PalSchema accepted for our
-- Foxgloam row, so they are field-proven names).
-- Output: D:/Nyx/Palworld-Palvolve/kb/data/*.csv + _datatables.txt
-- Markers: [selftest] DATAMINE ... final: DATAMINE_DONE tables=N rows=N

local M = {}

local OUT_DIR = "D:/Nyx/Palworld-Palvolve/kb/data/"

local function Log(msg)
    print(string.format("[Palvolve] [selftest] %s\n", msg))
end

-- Unwrap the bridge's holders (RemoteUnrealParam etc.): :get() until a plain
-- value or a stable userdata, then ToString if the userdata offers one.
local function fname_to_string(n)
    local guard = 0
    while type(n) == "userdata" and guard < 3 do
        local got = nil
        local ok = pcall(function() got = n:get() end)
        if ok and got ~= nil and got ~= n then n = got else break end
        guard = guard + 1
    end
    if type(n) == "userdata" then
        local s = tostring(n)
        pcall(function() s = n:ToString() end)
        return s
    end
    return tostring(n)
end

-- Normalize whatever shape the bridge hands back for an array (plain table,
-- wrapper table, or userdata TArray) into a Lua list of strings.
local function to_list(arr)
    local out = {}
    if arr == nil then return out end
    if type(arr) == "table" then
        -- wrapper tables key their payload (the OutMap lesson); prefer the
        -- numeric part, else the single wrapped value
        if #arr > 0 then
            for i = 1, #arr do out[#out + 1] = fname_to_string(arr[i]) end
            return out
        end
        for _, v in pairs(arr) do
            local inner = to_list(v)
            if #inner > 0 then return inner end
        end
        return out
    end
    if type(arr) == "userdata" then
        local n = nil
        pcall(function() n = arr:GetArrayNum() end)
        if n then
            for i = 1, n do
                local ok, v = pcall(function() return arr:GetArrayElement(i - 1) end)
                if not ok then ok, v = pcall(function() return arr[i] end) end
                if ok then out[#out + 1] = fname_to_string(v) end
            end
            return out
        end
        pcall(function()
            arr:ForEach(function(_, elem)
                local v = elem
                pcall(function() v = elem:get() end)
                out[#out + 1] = fname_to_string(v)
            end)
        end)
    end
    return out
end

local function csv_escape(s)
    s = tostring(s == nil and "" or s)
    if s:find('[",\r\n]') then
        s = '"' .. s:gsub('"', '""') .. '"'
    end
    return s
end

-- Field-proven monster-parameter columns (the keys PalSchema accepted for
-- Foxgloam) + waza candidates from the SDK headers. Reflection supersedes
-- these when available; they are the floor, not the ceiling.
local MONSTER_CANDIDATES = {
    "Tribe", "BPClass", "ZukanIndex", "ZukanIndexSuffix", "Size", "Rarity",
    "ElementType1", "ElementType2", "GenusCategory", "Organization",
    "HP", "MeleeAttack", "ShotAttack", "Defense", "Support", "CraftSpeed",
    "EnemyReceiveDamageRate", "CaptureRateCorrect", "ExpRatio", "Price",
    "AIResponse", "SlowWalkSpeed", "WalkSpeed", "RunSpeed", "RideSprintSpeed",
    "TransportSpeed", "IsBoss", "IsTowerBoss", "MaxFullStomach", "FoodAmount",
    "Nocturnal", "BiologicalGrade", "Predator", "Edible", "Stamina",
    "MaleProbability", "CombiRank",
    "WorkSuitability_EmitFlame", "WorkSuitability_Watering",
    "WorkSuitability_Seeding", "WorkSuitability_GenerateElectricity",
    "WorkSuitability_Handcraft", "WorkSuitability_Collection",
    "WorkSuitability_Deforest", "WorkSuitability_Mining",
    "WorkSuitability_OilExtraction", "WorkSuitability_ProductMedicine",
    "WorkSuitability_Cool", "WorkSuitability_Transport",
    "WorkSuitability_MonsterFarm",
    "PassiveSkill1", "PassiveSkill2", "PassiveSkill3", "PassiveSkill4",
}
local WAZA_CANDIDATES = {
    "WazaType", "TargetType", "Category", "Element", "Power", "CoolTime",
    "MinRange", "MaxRange", "BulletNum", "EffectType", "SpecialAttackRateType",
    "DisabledData", "IgnoreRandomDamage",
}
local LEVEL_CANDIDATES = { "PalID", "CharacterID", "WazaID", "Level" }

local function reflect_columns(dt)
    local cols = {}
    pcall(function()
        local rs = dt.RowStruct
        if rs and rs.ForEachProperty then
            rs:ForEachProperty(function(prop)
                local nm = nil
                pcall(function() nm = prop:GetFName():ToString() end)
                if not nm then pcall(function() nm = tostring(prop:GetFName()) end) end
                if nm and nm ~= "" then cols[#cols + 1] = nm end
            end)
        end
    end)
    return cols
end

local function dump_table(lib, dt, label, candidates)
    local names = {}
    local okNames = pcall(function() lib:GetDataTableRowNames(dt, names) end)
    local rows = to_list(okNames and names or {})
    if #rows == 0 then
        Log(string.format("DATAMINE %s: 0 rows readable, skipped", label))
        return 0
    end

    local cols = reflect_columns(dt)
    local colSource = "reflection"
    if #cols == 0 then
        cols = candidates
        colSource = "candidates"
    end

    -- pull each column across all rows; drop columns the engine returns empty
    local kept, data = {}, {}
    for _, col in ipairs(cols) do
        local vals = nil
        pcall(function() vals = lib:GetDataTableColumnAsString(dt, FName(col)) end)
        local list = to_list(vals)
        if #list == #rows then
            kept[#kept + 1] = col
            data[col] = list
        end
    end

    local path = OUT_DIR .. label .. ".csv"
    local f, err = io.open(path, "w")
    if not f then
        Log(string.format("DATAMINE %s: cannot open %s (%s)", label, path, tostring(err)))
        return 0
    end
    local header = { "RowName" }
    for _, c in ipairs(kept) do header[#header + 1] = c end
    f:write(table.concat(header, ",") .. "\n")
    for i = 1, #rows do
        local line = { csv_escape(rows[i]) }
        for _, c in ipairs(kept) do line[#line + 1] = csv_escape(data[c][i]) end
        f:write(table.concat(line, ",") .. "\n")
    end
    f:close()
    Log(string.format("DATAMINE %s: rows=%d cols=%d (%s) -> %s",
        label, #rows, #kept, colSource, path))
    return #rows
end

function M.run()
    Log("DATAMINE armed")
    local lib = StaticFindObject("/Script/Engine.Default__DataTableFunctionLibrary")
    if not (lib and lib:IsValid()) then
        Log("DATAMINE_DONE tables=0 rows=0 (no DataTableFunctionLibrary)")
        return
    end

    -- 1. census of every loaded DataTable (the map for all future digs)
    local tables = {}
    pcall(function()
        local all = FindAllOf("DataTable") or {}
        for _, dt in ipairs(all) do
            local full = tostring(dt:GetFullName())
            tables[#tables + 1] = { obj = dt, full = full }
        end
    end)
    local cf = io.open(OUT_DIR .. "_datatables.txt", "w")
    if cf then
        for _, t in ipairs(tables) do cf:write(t.full .. "\n") end
        cf:close()
    end
    Log(string.format("DATAMINE census: %d loaded DataTables -> _datatables.txt", #tables))

    -- 2. the gate-closing dumps, matched by short name from the census
    local plan = {
        { match = "DT_PalMonsterParameter%.", label = "pal_monster_parameter", cand = MONSTER_CANDIDATES },
        { match = "DT_WazaDataTable%.",       label = "waza_data",             cand = WAZA_CANDIDATES },
        { match = "DT_WazaMasterLevel%.",     label = "waza_master_level",     cand = LEVEL_CANDIDATES },
        { match = "DT_PalCombiUnique%.",      label = "combi_unique",          cand = { "ParentTribeA", "ParentTribeB", "ChildCharacterID" } },
        { match = "DT_PalBPClass_Common%.",   label = "bp_class",              cand = { "BPClassSoft" } },
        { match = "DT_PalCharacterIconDataTable_Common%.", label = "pal_icons", cand = { "Icon" } },
    }
    local dumped, totalRows = 0, 0
    for _, p in ipairs(plan) do
        local found = nil
        for _, t in ipairs(tables) do
            if t.full:find(p.match) then found = t break end
        end
        if found then
            local n = dump_table(lib, found.obj, p.label, p.cand)
            if n > 0 then dumped = dumped + 1 end
            totalRows = totalRows + n
        else
            Log(string.format("DATAMINE %s: no loaded table matches %s", p.label, p.match))
        end
    end
    Log(string.format("DATAMINE_DONE tables=%d rows=%d", dumped, totalRows))
end

return M
