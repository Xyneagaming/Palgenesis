# Asset Pipeline (custom models)

The staged path from data-only rows to fully custom meshes. Load before any model/texture
work. Game engine: **UE 5.1.1** [CONFIRMED - all current guides, incl. post-1.0, target
`GAME_UE5_1`]. Palworld has NO loose-file model loading; everything visual ships as a
cooked pak.

## The proven chain [CONFIRMED - pwmodding.wiki + working mods]

1. **Extract**: FModel, `GAME_UE5_1`, community Mappings.usmap
   (https://www.nexusmods.com/palworld/mods/2854). Search `SK_<InternalName>` (Foxparks =
   `Kitsunebi`). Export Models (.psk) + Textures (.png).
2. **Blender**: DarklightGames `io_scene_psk_psa` addon. Scale 0.01 on import; armature
   object stays named `Armature`; FBX export without leaf bones.
3. **Cook**: blank UE 5.1.1 Blueprint project named **exactly `Pal`** (mounts as
   `/Game/Pal/...`). Disable Io Store, enable Generate Chunks + cook-everything. Recreate
   exact folder paths. Import FBX selecting the existing skeleton + physics asset.
4. **Pak**: PrimaryAssetLabel (chunk >=1000) -> package -> rename `Palgenesis_P.pak`,
   **UNCOMPRESSED** (compressed pak caused invisible pals in PalVariety2026 - their
   changelog is the receipt).
5. **Load**: our PalSchema mod's `paks/` subfolder - PalSchema hooks
   `FPakPlatformFile::GetPakFolders` and mounts it natively [CONFIRMED from PalSchema
   source]. Fallback if a game patch breaks the signature: `Pal/Content/Paks/~mods/`.

Key PalSchema facts [CONFIRMED from source + docs]:
- `BlueprintAssetPath` is a soft class path into DT_PalBPClass - **any mounted `/Game/...`
  path works, including our own pak**. `IconAssetPath` same for icons.
- Icons need no UE at all: loose PNG in `resources/images/`, referenced as
  `$resource/modname/imagename` (PalSchema 0.5+).
- Precedent at scale: **PalVariety2026** ships 438 new-row variant pals as PalSchema JSON +
  a ~3GB asset pak on 1.0/multiplayer. The official bow guide demonstrates JSON row ->
  custom cooked BP. No published mod yet pairs a fully NOVEL sculpt with a new pal row -
  every individual link is proven; the full chain for a creature is ours to walk first.

## Skeleton law [CONFIRMED as universal practice]

**Custom meshes are skinned to the vanilla pal skeleton** (pick the donor by body plan, not
species) and inherit the entire behavior stack free: anims, anim BP, AI montages, hitboxes,
sockets. Runtime skeleton replacement is unsupported (Altermatic). Weight transfer in
Blender from the imported vanilla mesh as donor; bone names untouched. Care points: physics
asset needs a pass if the silhouette changes much; extra bones (tails/ears) via Compatible
Skeletons + Kawaii Physics; faces are texture/material-driven (eye/mouth UV regions must be
replicated), not morphs.

**The community stops before new skeletons, almost universally - so do we.** A different
body plan means a different donor skeleton, never an authored one. This is also why the
visual rule "evolved forms keep the base body plan" is cheap: same donor, minimal cleanup.

## Staged path (each stage shippable)

- **Stage 0 - icon + data row** [DONE 2026-07-29 for both forms, v2 after Sayber's look
  review]: icons are RENDERS OF OUR OWN BODIES (recolored-vanilla-icon v1 read as the
  existing pal - never derive an icon from a vanilla icon). Extraction is OURS: **palex**
  (D:\Nyx\palex, CUE4Parse CLI - list/tex/raw/mesh vs Pal-Windows.pak, 185k files,
  unencrypted, Mappings.usmap 1.0 from PalworldModding/UsefulFiles). Recolor dial: vault
  tools/recolor_foxline.py v2 (smoothstep band BLENDING - hard HSV bands posterize; the
  flame/coat split is by HUE). Preview rig lessons (the "weirdly low quality" fix):
  **UE normal maps are DirectX-handed - flip green in Blender or everything looks chewed**;
  force smooth shading; soft sun angles; AgX look. Variant-albedo law: a _Dark/_Ice variant
  may have its OWN albedo in its OWN folder (AmaterasuWolf_Dark does) - recolor THAT, not
  the base form's (the base sun-wolf albedo is white/teal; the dark look lives in the
  variant assets). Preview renders: D:\Nyx\palex\out\render\*_preview2.png.
- **Stage 1 - custom in-game look [SHIPPED 2026-07-29, loose-file lane]:** body/eye PNGs as
  PalSchema image resources (`resources/images/`) -> transient UTexture2D -> fork
  `reskin.lua` finds by name and swaps "Base Texture" on a dynamic material instance per
  live pal (inherits the game's own MI_PalLit_CharacterBodyBase shader). No pak, no BPs,
  no PMK/Wwise. Event-armed via NotifyOnNewObject (boot-time poll loops trip the UE4SS
  callback-GC beside the selftest poll: 3 AV crashes root-caused via the new `-SoakSec`
  runner instrument - a kill at SELFTEST_DONE outraces the crash window and prints false
  greens). **PAK LANE PARKED:** the UE 5.1.1 cook + UnrealPak chain works (`ue-cook.ps1`,
  uncompressed, mount point verified via -List), but its NEW packages are invisible to
  UE4SS LoadAsset (asset registry never heard of them; vanilla assets load fine) and the
  Kismet soft-path load chain AV-crashes post-world (struct marshaling). Revisit for mips
  when a registry-free loader exists (native StaticLoadObject is NOT in the RE-UE4SS
  wrapper). $resource tradeoff: no mipmaps - acceptable at pal view distances, verify in
  client.
- **Stage 2 - kitbash**: sculpt/kitbash the evolution on the imported Foxparks armature,
  transfer weights, cook alongside Stage 1.
- **Stage 3 - fully new Meshy/Blender mesh** on the closest vanilla skeleton; budget real
  time for weight cleanup, facial UV/material replication, physics pass.
- **Stage 4 - avoid** (new skeleton/anim set).

## Tooling

FModel + Mappings.usmap · Blender + io_scene_psk_psa · UE 5.1.1 blank `Pal` project ·
repak / UnrealPak-With-Compression (uncompressed output) · UAssetGUI (inspection) ·
PalSchema `pals` + `paks` + `$resource`. **PMK (localcc/PalworldModdingKit) as a UE project**
only if a BP must inherit game C++ classes - heavy setup (VS2022 pin + Wwise 2021.1.11
manual integration); test whether the duplicate-vanilla-BP route sidesteps it in Stage 1.

## Risks

1. Pak compression -> invisible pals (ship uncompressed). 2. PalSchema `GetPakFolders` sig
break on game patch (fallback `~mods`). 3. Custom BP may force full PMK (test Stage 1).
4. Path/name discipline - collisions break silently. 5. Facial-material and physics-asset
mismatches on new silhouettes (ugly, not crashy).
