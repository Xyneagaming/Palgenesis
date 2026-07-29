# The Foxfire Line (line spec #1)

Foxparks -> Foxgloam -> Foxfyre. First full Palgenesis evolution line, authored 2026-07-28
against the KB (rules cited per decision). Ratified frame: Sayber 2026-07-28 - stage 3
ridable, "similar to Blazehowl Noct"; power dial mine, vanilla-inline.

**The arc: kindled -> smothered -> reborn.** Foxparks' internal row name is Kitsunebi -
Japanese for *foxfire*, the ghost-light. The apex finally earns the name the game gave the
kit. Fire -> Dark -> Dark/Fire: the element leaves and returns transformed (ELEMENT rule:
element ADDED at apex reads as growth; the base's identity element is re-anchored).

## Stages

| | Foxparks | Foxgloam | Foxfyre |
|---|---|---|---|
| Row | Kitsunebi (vanilla) | Foxgloam | Foxfyre |
| Element | Fire | Dark | **Dark/Fire** |
| Stats H/M/S/D | 65/70/75/70 [FIELD] | **80/75/100/80** [PROPOSAL] | **105/85/115/95** [PROPOSAL] |
| Size/body | XS quadruped | XS quadruped | **M quadruped, RIDABLE** (ride sprint 1100) |
| Nocturnal | no | yes | yes |
| Evolves | L15 + night | L36 + night + knowsMove:Fire | - |
| BP reused | - | BP_Kitsunebi | **BP_AmaterasuWolf_Dark** (Blazehowl Noct) |

Reference frame [FIELD]: Blazehowl Noct (AmaterasuWolf_Dark) = mono-Dark, 100/70/115/105,
ride 1100, M, nocturnal, r6. Foxfyre sits a hair beside it (HSD 315 vs 320, more melee,
less bulk), differentiated by the Fire dual. Fire-dual = offense ceiling (ELEMENT rules),
so no stat exceeds 115 and nothing approaches the 130+ elite band: vanilla-inline per the
ratified dial. Stage budgets respect STAT rule 2 (+60..90 total, no stat >+30/stage).

## Rules applied (the citations)

- **Thresholds 15/36** = ~25%/~60% of cap 60 - EVOLUTION rule 2 (the 16/36 rhythm scaled).
  G4 (live cap) still open; these are grid-locked anyway.
- **night on both gates** - method tests (EVOLUTION rule 11): discoverable (shown in the
  evolve UI), thematic (the nocturnal flag on both evolved forms), effort-proportional.
- **knowsMove:Fire on the apex** - the Tyrogue steal (EVOLUTION rule 9) via existing
  Palvolve vocabulary: mastered waza persist through the swap [FIELD], so the flame
  survives from Foxparks unless the player discards it. The build steers the evolution.
- **Evolution-move moment** - MOVESET rule 4, now a FORK FEATURE: `grantMovesOnEvolve`
  (config.lua) masters the target species' rungs <= level at swap time (evolution.lua,
  same save-array write as !pg moves). The fire kit arrives WITH the new body.
- **Movesets on the vanilla grid** (MOVESET rule 1), bands per rung (rule 2), final trio
  staggered 30/20/12 (rule 6): Foxgloam - DarkBall 1, DarkArrow 7, GhostFlame 15,
  ShadowBall 22, Apocalypse 30, DarkLaser 40, DarkLegion 50. Foxfyre - FireBlast 1,
  FlareArrow 7, FlareTornado 15, FlameFunnel 22, Eruption 30, Inferno 40, FireBall 50
  (all-Fire ladder; the Dark kit rides across from Foxgloam via persistence, so the apex
  runs mixed rotations, e.g. FireBall 600/30 + DarkLaser 450/20 + GhostFlame 200/12).
  All waza names verified against our waza_data dump [FIELD].
- **No custom exclusive signature yet** - MOVESET rule 5 needs a custom waza row (asset
  work); deferred to the model/asset stage. Vanilla practice confirms the slot (>700
  power = Unique_* only).
- **CombiRank 9999 on both forms** - ECONOMY exploit #1 (species laundering): 9999 is
  vanilla's own formula-unreachable sentinel (ElecLion uses it). Evolution is the only
  route in. Same-species x same-species breeding remains (vanilla law); acceptable, same
  as legendaries.
- **Work suitability** - STAT trap 5: Foxfyre gets EmitFlame 2 + Collection 1 + Transport
  1 (modest, mount-flavored); no level-3+ suitability.
- **Foxgloam kit fix** - the shipped L7 MudShot (40/2) duplicated the filler slot
  (MOVESET rule 6); now DarkArrow (120/8), the L7-band spender.

## Open items / verify gates

- **G11 (client): ridability.** Foxfyre reuses Blazehowl Noct's BP AND its Tribe id, so
  the mount rig, saddle tech row, and partner-skill hooks should all key through. Palvolve's
  unlockCatchTech fires on the AmaterasuWolf_Dark tribe at evolve. VERIFY in client: evolve
  one, craft the Blazehowl Noct saddle, mount. Fallbacks if the saddle doesn't take: a
  PalSchema raw patch on the saddle tech row.
- **G12 (client): evolution-move grant** fires on the real evolve flow (headless can't
  evolve; the code path is the !pg moves core, field-proven, but the call site is new).
- **G13: icon/model** are Blazehowl Noct placeholders (like Foxgloam wears Foxparks').
  Concept pass next per VISUAL-DESIGN: Foxfyre = the M-size dusk-fox mount, ember-fleck
  constellation grown into full glowing seams, one ear still sparking. Anti-list applies
  (no moon motifs, no rings, no mane, no garb, quadruped forever).
- Stats/thresholds are [PROPOSAL] until Sayber's feel pass (the balance dial).
- Foxgloam z-suffix is 5C, Foxfyre 5D (paldeck family block; existing shipped pattern).

## Test state

Headless selftest (2026-07-28): both config pairs load with conditions, both species
register 7 waza-master rows, PalSchema adds both rows, native spawn returns a handle.
T3 (spawn identity readback) still red on the pre-existing init-recipe lane - unrelated,
template-clone remains the parked next move there.
