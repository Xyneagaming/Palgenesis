# Pal Compendium (our build)

[FIELD 2026-07-28] Dumped live from OUR local dedicated server (game build 619, 1.0), via
`tools/palserver-test.ps1 -Datamine` -> `scripts/datamine.lua`. Raw CSVs in `kb/data/`:
`pal_monster_parameter.csv` (754 rows, 90 cols), `waza_data.csv` (384), `waza_master_level.csv`
(5,779), `combi_unique.csv` (258), `_datatables.txt` (census of all 390 loaded DTs).
**This file supersedes every wiki number in the lane KBs where they disagree.**

## Roster shape

- 754 monster rows; **360 player-obtainable pal rows** after stripping BOSS_/GYM_/RAID_/
  SUMMON_/PREDATOR_ prefixed variants (includes our Foxgloam).
- Internal element names: Leaf=Grass, Earth=Ground, Normal=Neutral, Electricity=Electric.

## Element counts (obtainable, duals counted under both)

Dark **92** · Grass 54 · Water 52 · Fire 51 · Ground 50 · Neutral 49 · Ice 44 ·
**Electric 34 · Dragon 33**. Confirms the research lane: Dark is massively overserved,
Electric/Dragon underserved.

## Dual pairs: 27 of 36 exist (102 dual pals). The REAL empty list (9):

**Fire/Electric · Fire/Neutral · Electric/Ice · Electric/Grass · Electric/Neutral ·
Grass/Ice · Ice/Neutral · Dragon/Neutral · Ground/Neutral**

Corrections vs the research pass (which counted from wikis): Fire/Grass, Ground/Electric,
and Ground/Dragon are NOT empty (1-2 pals each). The two crown niches survive: Fire/Electric
and Grass/Ice (the system's only possible 4x) are both genuinely empty. Neutral appears in
5 of 9 empties (the Eevee-logic base-form space). Most-served dual: Dark/Fire (11 pals).

## Stat ceilings (obtainable rows)

- MeleeAttack cap **150** (Baphomet/Umihebi/KingBahamut families).
- ShotAttack: NightLady (Bellanoir) 150; **WorldTreeDragon 200** (1.0 apex, rarity 20).
- Defense: 145 standard cap (SaintCentaur); WorldTreeDragon/KingWhale **200**.
- HP: 150 standard (GrassMammoth); KingWhale 180, WorldTreeDragon 200.

Reading: the standard roster ceiling is **150**, and 1.0 added a single 200-band apex tier
(WorldTreeDragon; KingWhale defensively). STAT-MATH's rules updated accordingly.

## Skill economy (waza_data)

- 371 live damaging skills. **Power/CT: median 20.0, p10 13.3, p90 25.0** - the research's
  15-27 band is confirmed in the field.
- FireBall **600/30** (G7 headline: the 1.0 rebalance is live; wiki's 150/55 is dead).
  HolyBlast 700/30 = general-pool apex.
- **Everything above 700 is a species-locked `Unique_*` signature** (800-1000/30-99:
  KingWhale TidalBore 1000/30, WorldTreeDragon Supernova 1000/99, LegendDeer RadiantPurge
  1250/1 - likely boss-scripted). Vanilla already practices our signature rule.
- Skill identity lives in the **WazaType column, not RowName** (rows are NewRow_N).
  Effect riders captured (EffectType/Value pairs: Burn/Darkness/Muddy + chance).
- Foxgloam kit as shipped: DarkBall 50/2, MudShot 40/2, GhostFlame 200/12, ShadowBall
  300/16, DarkLaser 450/20, DarkLegion 600/30 + DarkWave 80/4. In-band; pending tweak per
  moveset rule 6: the L7 rung duplicates the filler slot (two 2s-CT skills), swap MudShot
  for a ~100-120/8 spender.

## Breeding fixed combos

`combi_unique.csv`: **258 fixed parent-pair recipes** in our build (community lore said
~28; most are elemental-variant recipes, e.g. LazyDragon+ElecCat -> LazyDragon_Electric).
Any evolved-form breeding rule must be checked against this table, not the wiki list.

## The fox family (Foxgloam's neighborhood)

| Row | English | El | Stats H/M/S/D | Body | Noct | Notes |
|---|---|---|---|---|---|---|
| Kitsunebi | Foxparks | Fire | 65/70/75/70 | XS quadruped | no | our base form |
| Kitsunebi_Ice | Foxparks Cryst | Ice | 65/70/80/70 | XS quadruped | no | variant convention |
| CuteFox | Vixy | Neutral | 70/70/70/70 | XS quadruped | no | |
| WoolFox | Cremis | Neutral | 70/100/70/75 | XS quadruped | no | |
| **NightFox** | (dark fox, EN name unconfirmed) | **Dark** | **75/70/85/70** | **XS quadruped** | **yes** | **nearest neighbor: mono-Dark nocturnal fox** |
| IceFox | Foxcicle | Ice | 90/100/95/105 | S quadruped | no | |
| FoxMage | Wixen | Fire | 90/50/110/80 | M humanoid | no | the fire-kitsune witch |
| FoxMage_Dark | Wixen Noct | Fire/Dark | 90/50/110/85 | M humanoid | yes | |
| DarkFlameFox | (1.0) | Dark/Fire | 110/100/115/90 | M humanoid | yes | dark-fire kitsune, r5 |
| FoxExorcist | (1.0) | Fire | 110/100/125/105 | M humanoid | no | r7 endgame kitsune |
| Foxgloam | ours | Dark | 80/75/100/80 | XS quadruped | yes | z5C |

**INTERNAL->ENGLISH NAME LAW (added 2026-07-30 after the AmaterasuWolf mislabel):** never map internal row names to English pal names by inference - AmaterasuWolf_Dark was labeled 'Blazehowl Noct' here for a full day and Foxfyre shipped on the wrong body (it is KITSUN NOCT, identified by Sayber in-game; the real Blazehowl = Manticore, Blazehowl Noct = Manticore_Dark, confirmed by trait triangulation + field eyes). English names come from Sayber's in-game identification or a verified icon match, never from mythology vibes.

**Differentiation verdict (Sayber's flag, answered with data):** the humanoid kitsune lane
(Wixen, Wixen Noct, DarkFlameFox, FoxExorcist) is crowded but orthogonal - Foxgloam stays a
quadruped and never goes witch/shrine/humanoid. The REAL collision is **Nox**: mono-Dark
nocturnal XS quadruped fox at nearly Foxgloam's statline. Foxgloam differentiates as: (1) an
EVOLUTION carrying Foxparks' motifs (ember-flecks, cream ventral, the sparking ear - an
ember story, not Nox's moonlight story), (2) role shape: shot-skewed dusk skirmisher vs
Nox's flat line, at stage-2 band once the balance dial runs, (3) VISUAL anti-list extended:
no moon/celestial motifs (Nox), no rings (Umbreon), no mane (Zoroark), no robes/garb
(the humanoid kitsunes). Full rules in VISUAL-DESIGN.md.
