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

-- CharacterID -> texture asset paths (body albedo; eye optional)
local SKINS = {
    Foxgloam = {
        body = "/Game/Pal/Palgenesis/T_Foxgloam_Body_B.T_Foxgloam_Body_B",
        eye = "/Game/Pal/Palgenesis/T_Foxgloam_Eye_B.T_Foxgloam_Eye_B",
    },
    Foxfyre = {
        body = "/Game/Pal/Palgenesis/T_Foxfyre_Body_B.T_Foxfyre_Body_B",
        eye = "/Game/Pal/Palgenesis/T_Foxfyre_Eye_B.T_Foxfyre_Eye_B",
    },
}

local texCache = {}
local function loadTex(path)
    if texCache[path] ~= nil then return texCache[path] end
    local tex = nil
    pcall(function()
        local obj = StaticFindObject(path)
        if obj and obj:IsValid() then tex = obj end
    end)
    if not tex then
        -- not in memory yet: ask the engine to load it (pak-mounted assets
        -- load on demand)
        pcall(function()
            local lib = StaticFindObject("/Script/Engine.Default__KismetSystemLibrary")
            -- LoadAsset needs latent context; fall back to LoadObject via
            -- FindObject after a StaticLoadObject-style call through
            -- UObjectGlobals is unavailable in Lua - use LoadAsset_Blocking
            local obj = LoadAsset(path)
            if obj and obj.IsValid and obj:IsValid() then tex = obj end
        end)
    end
    texCache[path] = tex or false
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
    -- pak presence probe: if neither body texture exists, stay dormant
    local any = false
    for _, s in pairs(SKINS) do
        if loadTex(s.body) then any = true end
    end
    if not any then
        Log("no Palgenesis texture pak mounted - reskin dormant (Stage 1 not cooked yet)")
        return
    end
    Log("texture pak found - reskin scan active")
    LoopAsync(2000, function()
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
