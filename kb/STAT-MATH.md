# Stat Math

Both games at formula level, the mapping, and the power-creep traps. Load before assigning
any evolved-form base stat.

## Palworld stat formulas [COMMUNITY, widely replicated - wiki.gg canonical form]

Source: https://palworld.wiki.gg/wiki/Pal_Stats

```
HP      = FLOOR( FLOOR(500 + 5*Level + HP_Base  * 0.5   * Level * (1 + IV%))
                 * (1 + Passive%) * (1 + Soul%) * (1 + Condenser%) )
Attack  = FLOOR( FLOOR(100 + Atk_Base * 0.075 * Level * (1 + IV%)) * (same layers) )
Defense = FLOOR( FLOOR(50  + Def_Base * 0.075 * Level * (1 + IV%)) * (same layers) )
```

- Flat bases (500/100/50) are shared by every pal; **species identity lives entirely in the
  per-level growth term** - so base-stat differences matter more at high level.
- IV 0-100 -> `IV * 0.003` = 0% to **+30% on the growth term only**. Percentage-based, so
  IVs are worth more on high-base species (compounds with species choice; Pokemon IVs don't).
- Souls: +3%/rank, 10 ranks, **max +30%/stat** [CONFIRMED in-game].
- Condenser: +5%/star, **+20% at 4 stars**; partner skill 1->5; +1 all work suitability at
  4 stars [CONFIRMED in-game].
- Passives (4 slots) add within a layer then multiply: Legend+Demon God+Musclehead+Ferocious
  = **+100% Attack** [COMMUNITY - https://palworld.wiki.gg/wiki/Passive_Skills/List].
- Alpha/Lucky: HP x1.2 only; no hidden Atk/Def advantage [COMMUNITY].

**The full stack: a fresh-caught pal -> fully built is HP x1.93, Attack x3.9** (worked on
Jetragon L50: 625 naked Atk -> 2,439 built). Compare Pokemon's max spread of x1.48.
**Every balance judgment is made at full build (LOCKED, README).**

## Palworld damage model [COMMUNITY - FightingBread v0.7.0 datamine, 65/65 cases ±2%]

Source: https://note.com/fightingbread/n/nc970f1b76b2b

```
Damage = 0.8 * sqrt(Level+1) * (Attack/Defense) * SkillPower
         * ElementMatch(1.2) * PartnerSkillMult(<=2.5) * (1 + Dmg%bonuses)
         * Effectiveness * Random(0.9-1.1)
```

- **Attack/Defense is a pure ratio: no diminishing returns.** Doubling Attack doubles damage.
  Offense scales unbounded; defense only divides. This is why the Attack ceiling is sacred.
- STAB analogue = x1.2 element match (weaker than Pokemon's x1.5).
- Effectiveness: **DISPUTED** - wiki says 2x/0.5x, this datamine measured 1.5x/0.65x.
  Gate G1 in VERIFY-LEDGER before balancing around either.
- No native crit for pal skills; random roll ±10%.

## Pokemon reference formulas [CONFIRMED - Bulbapedia]

```
HP    = floor((2*Base + IV + floor(EV/4)) * L/100) + L + 10
Other = floor((floor((2*Base + IV + floor(EV/4)) * L/100) + 5) * Nature)   Nature 0.9/1.0/1.1
```

Base stat enters at 2x weight - +10 base = ~+20 stat at L100, dwarfing any IV. BST tiers:
NFE ~250-350, standard finals ~480-540, pseudo-legendary 600, box legendaries 670-720.

## The lever mapping

| Pokemon | Palworld | Note |
|---|---|---|
| IV breed (0-31, ~+10%) | IV breed (0-100, +0-30% of growth) | strong analogue, bigger swing |
| EV allocation (510 budget) | Souls (+30%/stat, no budget) | **weak - Palworld lacks allocation tension** |
| Nature | Passives (4 slots, ± rolls) | more depth: slot competition, negatives |
| Ability | Partner skill (condenser-leveled) | species-locked |
| - | Condenser (dupe sink) | Palworld-only |
| Type chart 0x-4x | Element chart ~1.5-2x/0.5-0.65x | much flatter |
| - | Work suitability axis | Palworld-only second value axis |

**Net [INFERENCE]:** Palworld = farming pyramid (everything maxes eventually); Pokemon =
allocation puzzle (choices exclusive). **Evolution should add allocation-style choice - the
axis Palworld lacks** (branch choices, exclusive gates, transfer taxes), not more farming.

## Species stat landscape [FIELD 2026-07-28 - our DT dump, COMPENDIUM.md; supersedes wiki bands]

360 obtainable pals. Bands hold: trash 60-75 (Foxparks 65/70/75/70) · early-mid 80-95 ·
strong regular 100-115 · elite 120-130 · legendary 135-150. Ceilings in OUR build:
MeleeAttack **150**, ShotAttack 150 (Bellanoir) with ONE 200 outlier (WorldTreeDragon,
1.0's rarity-20 apex), Defense 145 standard with a 200 band (WorldTreeDragon/KingWhale),
HP 150 standard (KingWhale 180, WorldTreeDragon 200). Note stats split Melee/Shot attack;
most combat math cares about ShotAttack. Roster spans ~2.5x per stat (Pokemon: 5-10x).

## Stat-design rules

1. **Stage bands [PROPOSAL]:** stage 1 = 60-75, stage 2 = 85-100, stage 3 = 105-125.
   130+ only for evolutions of already-elite lines. **Hard ceiling 150 on any stat**
   (the vanilla standard ceiling; the 200 band is WorldTreeDragon's alone and stays that
   way). **Ratified balance bar (Sayber 2026-07-28): vanilla-inline overall; the highest
   evolutions may creep slightly (<=155-160 on ONE flagship apex line) ONLY behind
   raid-tier acquisition costs.** Creep without the gate is a creep-trap violation.
2. **Budget per stage: total (HP+Atk+Def) gain +60 to +90, no single stat jumping >+30.**
   Weight Attack heaviest in value judgments (ratio damage model + big flat HP base).
   Final stages get a shaped statline (tank vs sweeper), not flat +30/+30/+30.
3. **Balance at full build** (x2.03 on HP layers, x4.06 on Attack incl. passives).
4. **Preservation policy:** IVs transfer cleanly by construction (percentages of growth).
   Condenser transfer is the dangerous one - see ECONOMY-DESIGN exploit #2.
5. **The five creep traps:** multiplicative stacking blindness (test every +10% at full
   build) · Attack-over-150 · element-passive doubling (no free element-damage passives on
   evolved forms) · partner-skill inflation (upgrade +10-20%/stage, never new x2+ mults) ·
   work-suitability creep (a level-4 suitability is Anubis-tier economic power; budget
   suitability totals like a second BST, +1/stage max).
