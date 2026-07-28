# Palgenesis Design KB

Cited knowledge base for designing Palgenesis content: evolution lines, evolved-form stats,
movesets, elements, visuals, economy placement, and the custom-model asset path. Built
2026-07-28 from seven parallel research passes (sources cited inline in each file).

**Gate rule: load the relevant lane file BEFORE authoring in that lane, and cite which rule
you are applying.** This KB exists so we never re-derive from scratch.

## LOCKED DECISIONS (Sayber, 2026-07-28)

1. **Palworld-native mechanics.** Pokemon is the design reference; balance lives in
   Palworld's own IV/passive/soul/condenser model. We do not port EVs/natures.
2. **Full custom models** are the ambition for evolved forms (staged path in
   [ASSET-PIPELINE.md](ASSET-PIPELINE.md); data-only/retexture rungs ship first).
3. **All design lanes are in scope** (evolution craft, stat math, movesets, elements,
   visuals, breeding/economy).
4. **Balance bar = deep min-max layer.** Evolution is a real optimization system layered
   on breeding/condensing, not a casual toggle. Consequence: every number is balanced
   against a FULLY BUILT pal (IV 100, max souls, 4-star, meta passives), never a naked one.
5. **Power philosophy (ratified 2026-07-28): vanilla-inline.** Nyx holds the dial; evolved
   forms live inside vanilla bands, and only the highest evolutions may creep slightly
   past, gated behind raid-tier acquisition cost. (Sayber: "keep it inline with vanilla
   power, with highest evolutions maybe creeping just a little but being hard to obtain.")

Derived locks (from the research, adopted as law unless Sayber overturns):
- **Never raise a ceiling; change identity.** Evolved forms stay inside vanilla stat bands
  (no stat above 150). Power fantasy comes from earlier access + identity, not bigger numbers.
- **Keep the vanilla 9x9 element chart untouched.** Its structural guarantees are load-bearing.
- **Branches are choices, never dice.** Every branch reachable deliberately; no hidden RNG.
- **Quadruped stays quadruped.** An evolution never changes the base form's posture class.
- **Preserve everything through the swap** (Palvolve already does); balance via gates and
  costs, never by resetting investment.

## Epistemic tags

- `[CONFIRMED]` - verifiable game data, official docs, or read-from-source.
- `[FIELD]` - proven in OUR harness/game (strongest tag; dated).
- `[COMMUNITY]` - widely-replicated community analysis/datamine.
- `[INFERENCE]` - synthesis; plausible, unverified.
- `[PROPOSAL]` - our own numbers awaiting Sayber's feel pass.

Any number that gates a ratified decision must be `[CONFIRMED]` or `[FIELD]`. Disputed
values live in [VERIFY-LEDGER.md](VERIFY-LEDGER.md) with an in-engine test each; do not
balance around a disputed value without running its gate.

## Files

| File | Load before... |
|---|---|
| [COMPENDIUM.md](COMPENDIUM.md) | anything - OUR build's roster/skills/combos ground truth (raw CSVs in kb/data/) |
| [EVOLUTION-DESIGN.md](EVOLUTION-DESIGN.md) | designing any line: stages, thresholds, methods, branches |
| [STAT-MATH.md](STAT-MATH.md) | assigning any base stat; both games' formulas + power-creep traps |
| [MOVESET-DESIGN.md](MOVESET-DESIGN.md) | authoring any waza grant/learnset/signature skill |
| [ELEMENT-DESIGN.md](ELEMENT-DESIGN.md) | assigning/shifting any element; niche map of the roster |
| [VISUAL-DESIGN.md](VISUAL-DESIGN.md) | any concept/texture/model pass (incl. Foxgloam brief) |
| [ECONOMY-DESIGN.md](ECONOMY-DESIGN.md) | pricing/gating any evolution; the 5 economy-breaking exploits |
| [ASSET-PIPELINE.md](ASSET-PIPELINE.md) | any custom-model work: FModel -> Blender -> UE 5.1.1 -> pak |
| [VERIFY-LEDGER.md](VERIFY-LEDGER.md) | trusting any disputed number (in-engine gates) |
