# Economy Design

Where evolution sits in the optimization stack, and how it breaks. Load before pricing or
gating any evolution.

## The Palworld endgame pipeline [CONFIRMED/COMMUNITY]

Breed perfect -> condense -> souls -> level. Costs:
- **Breeding**: passive inheritance is a datamined two-roll table; clean-pool perfect-4 =
  **10%** (one junk passive in the pool collapses it under 2% — pool hygiene is the whole
  skill). IVs: per stat 30% father / 30% mother / 40% fresh roll; bred pals always have
  Melee IV = Ranged IV. Child species via CombiRank: `floor((A+B+1)/2)`, nearest rank wins,
  ties to lower index; ~27 rare species are same-species-breed-only (the scarcity
  backstop); ~28 fixed special combos. Cake is free once automated; the real cost is egg
  cycles. (https://palworld.wiki.gg/wiki/Breeding, https://palgenetics.com/palworld-breeding-passive-skills)
- **Condenser**: 1.0 reduced cost to **48 copies total for 4 stars** (was 116) — pin via
  gate G3. Breeding rejects are fodder, so grind stages overlap.
- **Souls**: +30%/stat; post-1.0 cheap to farm. **Souls and condense do NOT transfer through
  breeding — every rebred replacement restarts from zero.**
- Pokemon lesson [COMMUNITY]: grind that gates POWER gets designed out under community
  pressure (Bottle Caps, Mints erased IV/nature breeding); grind that gates
  IDENTITY/cosmetics endures (shiny hunting thrives). Watch which side each gate sits on.

## The core structural fact [INFERENCE, load-bearing]

Vanilla Palworld has **no investment-preserving transition whatsoever** — a better-bred pal
restarts condense and souls from scratch. Palvolve preserves EVERYTHING through the swap
(moves, passives, IVs, souls, **condenser rank**, Alpha/Lucky, nickname — [CONFIRMED from
repo README; harness-verify via gate G2]). Evolution is therefore the ONLY mechanic of its
kind: that is its legitimate niche AND its entire exploit surface.

## Palvolve stock-tree balance philosophy [CONFIRMED from scripts/config.lua + costs.lua]

143 transformations: chains (Pengullet->Penking L21, Sparkit->Grizzbolt L38,
Hoocrates->Shadowbeak L48) + 87 elemental adaptations (~L30, per-element stones). Costs =
1 crafted stone + drop-table materials in level bands (`count = clamp(ceil(avg_drop*4), 1,
30)`). `applyIvBonus`: **+5 IVs/stage, capped 100**; full heal on evolve; rollback exists.
Targets are always existing species at existing ceilings — stock Palvolve never raises a
ceiling; its exposure is **route-bypass** (a level gate + common materials is far cheaper
than the intended acquisition path for Shadowbeak-class species). Tuned for fun/identity,
not economy integrity. **That gap is our balance work.**

## Where evolution sits (the model)

1. **Pipeline extension (core):** breed -> condense -> souls -> **evolve**. Gate up-tier
   evolutions on completed investment (condense rank, ivTotal, trustRank) so evolution
   consumes a finished pal, never substitutes for finishing one.
2. **Endgame sink:** price up-tier evolutions in scarce endgame currency (Large/Giant souls,
   ancient parts, raid drops), scaled by target rarity x carried investment (an uninvested
   pal evolves cheap; carrying 4 stars + rank-10 souls pays a transfer tax). Stock
   common-material costs are fine only for the cheap lanes.
3. **Lateral respec lane:** element adaptations are same-species sidegrades — near-zero
   balance risk, high min-max value (raid retyping). Keep cheap; they're the safe fun.
4. **Mega lesson [COMMUNITY]:** permanent stat surplus is what creeps; identity/role
   transformation is what players love. Differentiate evolved forms by partner skill, work
   kit, and element — never by a raised ceiling (LOCKED).
5. **Scarcity respect:** no evolution target may be a same-species-only breedable, special-
   combo-only, or raid-exclusive species unless the evolution costs MORE than the intended
   route. Raid/event species are evolution-ineligible (or source-only). Stock pairs into
   Shadowbeak/Jormuntide-class targets need re-gating.

## The five economy-breaking exploits (design against each, test each)

1. **Species laundering**: evolve cheap pals into a rare species, then same-species breed
   infinite copies of a deliberately-scarce species. Fix: evolved pals breed as the PRE-
   evolution species, or are sterile, or evolution requires `inParty:<target>` (an already-
   owned specimen — Palvolve's own vocabulary, promoted to a global rule).
2. **Condense-fodder arbitrage**: 4-star a Chikipi-tier pal with 48 trivial copies, evolve,
   arrive at a 4-star endgame species. Fix: star-transfer tax (souls or copies-of-target
   per carried star) or cap carried stars by evolution tier.
3. **Rollback farming**: reversible evolution + refunds + any non-refunded side effect
   (IV bonus, full heal) = a loop. Rollback must strip the IV bonus and never refund
   consumed endgame currency.
4. **Breeding-chain bypass**: evolving mid-funnel jumps the CombiRank convergence steps —
   the main time cost of perfect breeding. Fix: trust-rank/level gates mean only long-held
   pals evolve; fresh funnel stock can't.
5. **Dead-content inversion**: if evolution is strictly the efficient path, catching and
   special combos become vestigial. The ratio to hold: evolution is the best path only for
   a pal you've ALREADY invested in; for a fresh pal, vanilla routes stay cheaper.
