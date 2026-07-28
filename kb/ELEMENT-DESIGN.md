# Element Design

The 9x9 chart, its structural guarantees, shift grammar, and the niche map. Load before
assigning or shifting any element.

## The chart [CONFIRMED — https://palworld.wiki.gg/wiki/Elements]

Nine elements. Structure: pentagon cycle **Fire>Grass>Ground>Electric>Water>Fire** plus a
tail off Fire: **Fire>Ice>Dragon>Dark>Neutral**. Strong = 2x, weak (attacking your predator)
= 0.5x, else 1x. Reverse-symmetric food chain: each element resists exactly what it beats.
No immunities, no self-resistance. Multiplier values disputed (2x/0.5x wiki vs 1.5x/0.65x
datamine) — gate G1. Same-element (STAB) bonus +20% [CONFIRMED].

Fire is the only element strong against two (Grass AND Ice); Neutral the only one with no
offensive strength.

## Structural guarantees [INFERENCE — verified exhaustively against the chart]

Because the chart is a strict food chain:
- **Zero-weakness duals are impossible.** Every pair keeps >=1 2x weakness. The chart
  polices itself; this is why it stays untouched (LOCKED).
- **0.25x is impossible** (no attack element is resisted by two elements).
- **Exactly ONE 4x-weak combo exists: Grass/Ice vs Fire** — and no vanilla pal has it.
- Dual composition is multiplicative; 2 x 0.5 cancels to 1x [CONFIRMED].
- Single-weakness "fortress" duals: Fire/Electric (only Ground), Grass/Electric (only Fire),
  Water/Ground (only Grass), Grass/Water (only Electric), Ice/Water (only Electric),
  Fire/Dragon (only Water), Ice/Dark (only Fire).

## Meta state [COMMUNITY]

- **Dark is the apex element**: 70 pals, best stats in class, beats Neutral (the overworld
  trash element). **RULE: Dark gets nothing — custom Dark forms rare and stat-conservative.**
- Dragon is the raid meta (both Bellanoirs are Dark); Ice earns its slot purely as
  anti-Dragon; Fire is the best offensive spread (two prey).
- Per-hit element swing is at most 4x (2x vs 0.5x) with no immunities — flatter than
  Pokemon, which is why raw stats dominate the meta. **Min-max hooks live in skills and
  passives, not chart edits.**

## Roster distribution [COMMUNITY — Fextralife count, ~287 pals; spot-check via G5]

Dark 70 · Water 47 · Grass 46 · Ground 44 · Fire 43 · Ice 38 · Neutral 36 (almost no duals) ·
**Electric 25 · Dragon 25 (both underserved; Dragon endgame-locked)**.

**Empty dual pairs (12 of 36, zero vanilla pals):** Fire/Grass, Fire/Electric, Fire/Neutral,
Grass/Electric, **Grass/Ice**, Electric/Ground, Electric/Ice, Electric/Neutral,
Ground/Dragon, Ground/Neutral, Ice/Neutral, Dragon/Neutral.
One-pal pairs: Water/Neutral, Ice/Dark, Fire/Ice, Dark/Neutral.

## Shift-on-evolution grammar [CONFIRMED patterns, COMMUNITY sentiment]

- **Anchor one element across the line.** Shift/add the secondary; never replace both.
- **The Scizor rule: the body announces the element.** Foreshadow the incoming element in
  the base form's design/habitat/skills; the evolved model carries it visibly.
- **Adding at the apex reads as growth; deleting reads as loss** — remove an element only
  via a branch where the other branch keeps the old identity (the Bellossom rule).
- **Type-shift = role-shift**: pair every element change with a stat redistribution
  (Scyther/Scizor equal-total side-grade is the branch gold standard).
- **Speak the native idiom**: players already accept element swaps via the Ignis/Cryst/Lux/
  Noct/Terra variants; use the same visual grammar and it reads as canon.
- The Eevee logic maps perfectly to Palworld: **Neutral is the natural base-form element**
  (blank canvas -> element on evolution), and Neutral bases shifting INTO underserved
  elements is a signature Palgenesis move.

## Target niches (highest value first)

1. **Electric anything** — 4 of the 12 empty pairs involve it; Fire/Electric (community-
   named best theoretical combo, single Ground weakness), Grass/Electric, Electric/Ground,
   Electric/Ice.
2. **Mid-game Dragon** — Ground/Dragon is empty and would be the first accessible tanky
   Dragon line.
3. **Grass/Ice** — the system's only possible 4x glass cannon; a genuinely novel niche
   vanilla never shipped. Highest offense/utility budget in the mod, paid for by the only
   double-weakness in the game. Use once, deliberately.
4. **Fire/Grass** — empty; thematically rich (ash/regrowth); covers Grass+Ice+Ground.
5. **Neutral duals** — five empty pairs; pairs with the Eevee-logic base forms.

Budget note: fortress duals sit at the defensive ceiling — give them modest stats. Fire
duals are the offense ceiling (3-element STAB coverage) — budget down accordingly.
