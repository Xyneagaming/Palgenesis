-- Palvolve: Evolve your captured Pals into stronger related forms (Pengullet -> Penking),
-- keeping their full identity: level, passives, IVs, souls, condenser rank and learned moves.
local MOD_NAME = "Palvolve"

local function Log(msg)
    print(string.format("[%s] %s\n", MOD_NAME, msg))
end

-- Startup marker; external tooling waits for this exact line
Log("loaded")

-- Version banner: records the running mod version in the log next to UE4SS's
-- and PalSchema's own banners, so a support log (server or client) identifies
-- the build at a glance. Its own line, so the "loaded" marker above stays
-- exactly as external tooling expects.
do
    local okVer, cfg = pcall(require, "config")
    if okVer and cfg and cfg.modVersion then
        Log("version " .. tostring(cfg.modVersion)
            .. " (game build " .. tostring(cfg.gameBuild) .. ")")
    end
    -- Palgenesis banner: this is the Nyx/Sayber fork, running under its own
    -- name. Base engine and internal ids remain Palvolve (GPL-3.0, DooDesch)
    -- for save compatibility and clean upstream merges. Chat prefix: !pg
    Log("running as Palgenesis (household fork; base Palvolve, GPL-3.0 DooDesch; chat prefix !pg)")
end

-- Role detection: UI modules and their retry pollers must not run on a
-- dedicated server. Their endless LoopAsync+ExecuteInGameThread retries
-- (the hooked widgets never load headless) churn transient callback refs,
-- which UE4SS's callback GC occasionally frees while still scheduled -
-- observed as corrupted closures and silent server deaths.
local Role = require("role")
if Role.isDedicated() then
    Log("dedicated server detected: UI modules disabled")
end

-- Evolution core
local Evolution = nil
local okCore, errCore = pcall(function()
    Evolution = require("evolution")
    Evolution.init()
end)
if not okCore then
    Log("core failed to load: " .. tostring(errCore))
end

-- Server check: a connected client asks the host whether Palvolve runs there and,
-- if not, disables evolution for the session and tells the player why. The
-- authority (host/single-player) runs the mod itself, so it never pings.
if Evolution and not Role.isDedicated() then
    local okSC, errSC = pcall(function()
        require("servercheck").init()
    end)
    if not okSC then
        Log("server check failed to load: " .. tostring(errSC))
    end
end

-- Radial menu integration (Evolve entry in the hold-4 wheel)
if Evolution and not Role.isDedicated() then
    local okRadial, errRadial = pcall(function()
        require("radialmenu").init({
            check = Evolution.check,
            canOffer = Evolution.canOffer,
            listOptions = Evolution.listOptions,
            executeOption = Evolution.executeOption,
        })
    end)
    if not okRadial then
        Log("radial menu integration failed to load: " .. tostring(errRadial))
    end
end

-- Egg filter (config-gated inside)
local okEgg, errEgg = pcall(function()
    require("eggfilter").init()
end)
if not okEgg then
    Log("egg filter failed to load: " .. tostring(errEgg))
end

-- Pal Alchemy Workbench visual (teal tint on the reused medicine bench)
if not Role.isDedicated() then
    local okBench, errBench = pcall(function()
        require("benchvisual").init()
    end)
    if not okBench then
        Log("bench visual failed to load: " .. tostring(errBench))
    end
end

-- Pal Alchemy Workbench recipe filter (per-instance converter target patch)
local okFilter, errFilter = pcall(function()
    require("benchfilter").init()
end)
if not okFilter then
    Log("bench filter failed to load: " .. tostring(errFilter))
end

-- Dev probes (loaded only while devMode is true)
local okCfg, cfg = pcall(require, "config")
if okCfg and cfg.devMode then
    local okProbes, errProbes = pcall(require, "probes")
    if not okProbes then
        Log("probes failed to load: " .. tostring(errProbes))
    end
end

-- Runtime reskin (Palgenesis): custom-species looks without cooked BPs.
-- Dormant until the Stage-1 texture pak is mounted; see reskin.lua.
do
    local disable = nil
    pcall(function() disable = os.getenv("PALGENESIS_NO_RESKIN") end)
    if disable == "1" then
        Log("reskin disabled via PALGENESIS_NO_RESKIN")
    else
        local okRs, rs = pcall(require, "reskin")
        if okRs and rs and rs.start then
            pcall(rs.start)
        elseif not okRs then
            Log("reskin failed to load: " .. tostring(rs))
        end
    end
end

-- Headless selftest (Palgenesis): armed ONLY by the test runner via the
-- PALGENESIS_SELFTEST=1 environment variable, so a normal boot (client or
-- real server) never runs it. See selftest.lua and tools/palserver-test.ps1
-- in the vault project.
do
    local flag = nil
    pcall(function() flag = os.getenv("PALGENESIS_SELFTEST") end)
    if flag == "1" then
        local okSt, errSt = pcall(require, "selftest")
        if not okSt then
            Log("selftest failed to load: " .. tostring(errSt))
        end
    end
end
