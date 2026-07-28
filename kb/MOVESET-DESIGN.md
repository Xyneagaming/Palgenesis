# Moveset Design

Learnset pacing and the waza economy. Load before authoring any AbilitiesByLevel list or
custom skill. **Datamine first: wikis mix pre-1.0 and 1.0 skill values (Fire Ball was
150/55s, is 600/30s). Read live DT_WazaDataTable numbers via the harness before numbering
anything** (we already read DT rows via GetDataTableRowNames — see selftest.lua).

## Palworld's system [CONFIRMED]

- Learn channels: level-up grants (per-species list), Skill Fruits (permanent, ignore
  element, farmable infinitely at the level-48 Skillfruit Orchard), breeding inheritance.
- **Grant grid: levels 1 / 7 / 15 / 22 / 30 / 40 / 50**, with 60/70 rungs on 1.0 endgame
  pals (Silvance has a 70). Identical across species. (https://palworld.wiki.gg/wiki/Active_Skills)
- **3 equipped skills max**; pal AI fires whatever is off cooldown, so kits are rotations.
- No accuracy stat, no phys/special split: reliability dials are projectile speed, tracking,
  AoE size, cast time. Multi-hit skills scale with target hitbox (the degenerate top end:
  Twin Spears 128 DPS on large bosses).
- Exclusive skills are a real DT category with no fruit (Beam Comet/Jetragon). Partner
  skills are a separate axis outside the 3 slots, leveled by condenser.

## 1.0 power/cooldown economy [CONFIRMED via paldb/game8 cross-check]

Power ÷ CT sits in a flat **15-27 band** across the whole game, rising toward the top:
basics 40/2s · Flare Arrow 120/8 · Hydro Laser 200/12 · Blizzard Spike 450/20 ·
Fire Ball 600/30 · Holy Burst 700/30 (apex) · Spore Burst 800/30 (L70 ceiling).
Big skills are taxed by lockout time and cast animation, not by ratio.

**Rotation ceiling [INFERENCE from confirmed numbers]: an optimal endgame trio (30/20/12s
staggered CTs) lands ~3,500-4,000 total power/minute.** That is the vanilla ceiling to
balance custom kits against. Three same-CT nukes waste uptime; basics alone yield ~8 power/s.

## Pokemon patterns worth porting [CONFIRMED — Bulbapedia/pokemondb]

- **Evolved forms re-learn shared moves LATER** (Charmander gets Flare Blitz at 40,
  Charizard at 62; the delay widens with move value). Evolution trades pacing for stats.
- **Evolution moves (Gen 7+):** a move granted at the instant of evolving (Garchomp->Crunch)
  — the transition itself delivers a kit payoff. The single most portable idea.
- **Stone-evolution learnset walls** (Wigglytuff): when evolution is cheap/instant, the dead
  learnset is the counterweight that makes timing a decision.
- Signature tightness: species-exclusive (mechanical thesis, e.g. Dragon Darts) >
  final-stage-gated (Blast Burn) > evolution move.
- Pokemon's free-damage ceiling is 90-power/100-acc; everything above pays in accuracy, PP,
  tempo, or self-harm. Palworld's CT lockout is the PP substitute.

## Field facts (ours) [FIELD 2026-07-28]

- **Learned skills persist through Palvolve's swap; the new species' level moves are NOT
  granted retroactively** (the game grants moves only when a threshold is crossed — this is
  why `!pg moves` exists). So the "delay evolution to finish the pre-evo learnset" lever and
  the evolution-move pattern (grant at/below the evolution level) both work in our engine.
- Waza enum lookup from Lua works (OutMap unwrap; DarkBall = enum 159).

## Moveset rules

1. **Author on the vanilla grid** (1/7/15/22/30/40/50, +60/70 only for endgame finals).
2. **Power/CT bands per rung [PROPOSAL]:** L1 40/2 · L7 ~100-120/8 · L15 ~160-200/8-12 ·
   L22 ~200-300/12-16 · L30 ~400-450/20 · L40 ~500-600/24-30 · L50 ~600-700/30 ·
   L60-70 ~700-800/30. Keep power÷CT in 15-27; above 27 requires a real drawback
   (self-root, recoil, wind-up).
3. **Evolved stages shift shared mid/high skills +1 rung later** (the Charizard pattern);
   early basics stay put.
4. **Every evolution grants an evolution skill** at/below the evolution level of the target
   species' list, so it lands the moment of the swap.
5. **One exclusive signature per line, final stage only**: flagged exclusive in the DT, no
   fruit entry, breeding-leak tested (gate G6). Signature = mechanic (multi-hit pattern,
   dash, CC rider, sectioned AoE), not a bigger number; raw stats capped at the vanilla apex
   band (700/30; absolute ceiling 800/30).
6. **Design each stage's best-three as a staggered rotation** (filler <=8s + spender
   12-20s + nuke 24-30s). Never two same-CT nukes on adjacent rungs.
7. **Rotation budget: a final evolution's optimal trio reaches ~3,500-4,000 power/min and
   exceeds vanilla legendaries by <=10%.**
8. **Element = STAB via passives:** signatures match the pal's own element; at most one
   off-element skill per form and make it utility, not coverage damage.
9. **Fruit warnings:** anything non-exclusive becomes universal (orchard + breeding);
   never rest line identity on a fruitable skill; pre-evo weakness lives in stats, not
   learnset (a fruit can hand a level-15 base form Blizzard Spike).
10. **Partner skill is the second identity axis:** where a stage doesn't warrant a new
    active, upgrade the partner skill between stages instead.
