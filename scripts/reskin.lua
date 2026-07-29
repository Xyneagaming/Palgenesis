-- Palgenesis runtime reskin: give custom-species pals their own look WITHOUT
-- cooking blueprints. The Stage-1 pak ships only cooked Texture2D assets;
-- here we create a dynamic material instance from the pal's live material
-- (inheriting the game's own shader via MI_PalLit_CharacterBodyBase) and swap
-- the "Base Texture" parameter (param name read from the MI dumps, see
-- kb/ASSET-PIPELINE.md). No pak -> module no-ops quietly.
--
-- Applied on a slow scan of live PalCharacters rather than a spawn hook:
-- reskin is cosmetic, a second of vanilla look is fine, and the scan is
-- immune to the callback-GC flake that kills long-lived hooks.

local Config = require("config")

local M = {}

local function Log(msg)
    print(string.format("[Palvolve] [reskin] %s\n", msg))
end

-- CharacterID -> texture sources. `res` = PalSchema $resource key fragment
-- (loose PNG in NyxForms/resources/images, loaded by PalSchema into a
-- transient UTexture2D - the loose-file lane that needs no pak, no cook, no
-- registry). `pak` = cooked-asset path, kept as the upgrade lane (mips) once
-- the pak-load question is solved.
local SKINS = {
    Foxgloam = {
        body = { res = "foxgloam_body", pak = "/Game/Pal/Palgenesis/T_Foxgloam_Body_B.T_Foxgloam_Body_B" },
        eye = { res = "foxgloam_eye", pak = "/Game/Pal/Palgenesis/T_Foxgloam_Eye_B.T_Foxgloam_Eye_B" },
    },
    Foxfyre = {
        body = { res = "foxfyre_body", pak = "/Game/Pal/Palgenesis/T_Foxfyre_Body_B.T_Foxfyre_Body_B" },
        eye = { res = "foxfyre_eye", pak = "/Game/Pal/Palgenesis/T_Foxfyre_Eye_B.T_Foxfyre_Eye_B" },
    },
}

local texCache = {}

-- PalSchema $resource textures are transient UTexture2D objects created from
-- loose PNGs; find them by scanning loaded textures for the resource key.
-- (Registration log: "Registered Image Resource 'PalSchema/Resources/NyxForms/<key>'".)
local function findResourceTex(key)
    local found = nil
    pcall(function()
        local all = FindAllOf("Texture2D") or {}
        for _, t in ipairs(all) do
            if t and t:IsValid() then
                local full = tostring(t:GetFullName()):lower()
                if full:find(key:lower(), 1, true) then found = t break end
            end
        end
    end)
    return found
end

local function loadTex(spec)
    local ck = spec.res or spec.pak
    if texCache[ck] ~= nil then return texCache[ck] end
    local tex = nil
    -- lane 1: PalSchema resource texture (loose PNG, no pak needed)
    if spec.res then tex = findResourceTex(spec.res) end
    -- lane 2: cooked pak asset, if already loaded (StaticFindObject sees only
    -- LOADED objects). The active loaders both failed here: UE4SS LoadAsset
    -- resolves via the asset registry (never heard of new mod packages) and
    -- the Kismet soft-path chain crashed the server (soak matrix 2026-07-29).
    if not tex and spec.pak then
        pcall(function()
            local obj = StaticFindObject(spec.pak)
            if obj and obj:IsValid() then tex = obj end
        end)
    end
    texCache[ck] = tex or false
    return tex
end

local seen = {}

local function applyTo(actor, skins, key)
    local mesh = nil
    pcall(function() mesh = actor.Mesh end)
    if not (mesh and mesh:IsValid()) then return false end
    local ok = false
    pcall(function()
        local num = mesh:GetNumMaterials()
        for i = 0, num - 1 do
            local cur = mesh:GetMaterial(i)
            if cur and cur:IsValid() then
                local name = cur:GetFullName():lower()
                local texPath = name:find("eye") and skins.eye or skins.body
                local tex = loadTex(texPath)
                if tex then
                    local mid = mesh:CreateDynamicMaterialInstance(i, cur, FName("NONE"))
                    if mid and mid:IsValid() then
                        mid:SetTextureParameterValue(FName("Base Texture"), tex)
                        ok = true
                    end
                end
            end
        end
    end)
    if ok then seen[key] = true end
    return ok
end

function M.start()
    -- EVENT-driven world wait, no boot-time polling: every polling variant
    -- (2s forever-loop, deferred probe, selftest-shaped self-terminating
    -- poll) AV-crashed the server at boot while running beside the selftest's
    -- own poll loop - two concurrent boot loops trip the UE4SS callback-GC
    -- flake ("-4" read; control run with reskin disabled was green,
    -- 2026-07-29). NotifyOnNewObject fires once per game state construction
    -- with no loop to collect.
    local armed = false
    Log("reskin armed - waiting for world (event)")
    NotifyOnNewObject("/Script/Pal.PalGameStateInGame", function(_)
        if armed then return end
        armed = true
        ExecuteWithDelay(5000, function()
            ExecuteInGameThread(function()
                pcall(function()
                    local any = false
                    for _, s in pairs(SKINS) do
                        if loadTex(s.body) then any = true end
                    end
                    if any then
                        Log("texture pak found - reskin scan active")
                        M.armScan()
                    else
                        -- diagnostic: list what PalSchema resource textures DO exist
                        local names = {}
                        pcall(function()
                            local all = FindAllOf("Texture2D") or {}
                            for _, t in ipairs(all) do
                                if t and t:IsValid() then
                                    local full = tostring(t:GetFullName())
                                    if full:lower():find("palschema", 1, true) or full:lower():find("fox", 1, true) then
                                        names[#names + 1] = full
                                    end
                                end
                            end
                        end)
                        Log("no reskin textures found - dormant. PalSchema/fox textures in memory: "
                            .. (#names > 0 and table.concat(names, " | ") or "(none)"))
                    end
                end)
            end)
        end)
    end)
end

function M.armScan()
    LoopAsync(2500, function()
        ExecuteInGameThread(function()
            pcall(function()
                local pals = FindAllOf("PalCharacter") or {}
                for _, actor in ipairs(pals) do
                    if actor and actor:IsValid() then
                        local id = ""
                        pcall(function()
                            local p = actor:GetParameterComponent().IndividualParameter
                            id = p:GetCharacterID():ToString()
                        end)
                        local skins = SKINS[id]
                        if skins then
                            local key = tostring(actor:GetFullName())
                            if not seen[key] then applyTo(actor, skins, key) end
                        end
                    end
                end
            end)
        end)
        return false
    end)
end

return M
