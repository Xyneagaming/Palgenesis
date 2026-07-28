# Evolution-Line Design

How a line earns its stages. Load before designing any evolution line, threshold, or branch.
Level rules are written as fractions of the live level cap (pin the cap via VERIFY-LEDGER G4).

## Thresholds and pacing

- [CONFIRMED] Pokemon's flagship rhythm is 16/36 in a ~level-60 campaign: first evolution at
  ~25% of the cap (the first reward of commitment), final at ~60%. Mid-game lines shift to
  ~40%/~73% (24/44). Evolution levels cluster in the 20s-30s; the classic max is 55
  (Dragonair->Dragonite). (Smogon distribution analysis:
  https://www.smogon.com/forums/threads/a-look-at-the-distribution-of-evolutionary-levels-of-each-generations-pokemon.3676292/)
- [CONFIRMED] Palvolve's stock minLevels already follow this shape: 16-30 early pairs,
  32-42 most chains, 45-50 endgame (read from scripts/config.lua).
- **RULE: flagship 3-stage lines evolve at ~25% and ~60% of cap; mid-game lines ~40%/~73%;
  reserve >=85% of cap for pseudo-legendary-tier lines only.**
- [CONFIRMED] The named failure: species caught late carrying high thresholds create "dead
  levels" (an underpowered pal lugged far past fun). **RULE: prefer `level N OR +K levels
  since acquisition, whichever first`** (fixes Temtem's documented late-catch punishment;
  https://temtem.wiki.gg/wiki/Evolution).
- [CONFIRMED] Cocoon-style boring middles are tolerable only when short (Metapod is ~3
  levels). **RULE: a deliberately weak middle stage lasts <=5 levels or pays pseudo-legendary
  wages (see STAT-MATH).**

## Methods

- [CONFIRMED] Level-up is the backbone (~60-65% of all Pokemon evolution events); everything
  else is seasoning (stones ~10-12%, trade ~5%, friendship ~4-5%, gimmicks ~2%).
  (https://bulbapedia.bulbagarden.net/wiki/Evolution)
- [COMMUNITY] Players judge a method by three tests: **discoverable in-game, thematically
  expressed by the creature (Inkay passes, Runerigus fails), effort proportional to payoff
  (Crobat redeems Zubat's friendship tax).** Hidden, silently-resetting counters are the
  documented worst practice (the 1,000-step walkers).
- [COMMUNITY] **No trade-evolutions** - the single strongest community consensus found; in a
  mostly-solo/coop game convert that slot to rare-item, location, or sink-cost triggers.
- [CONFIRMED] Palvolve's condition vocabulary already covers the good methods: day/night,
  inDesert/inWater/inCave/inSanctuary, status, knowsMove:<Element>, inParty:<Species>,
  trustRank, ivTotal/ivEach, playerLevel, negation. **RULE: compose gates from this
  vocabulary before inventing new condition types.**
- [CONFIRMED] Cassette Beasts' remaster model: evolution triggers as a **player-confirmed
  ceremony** at the moment conditions are met - no accidental or missed evolutions, and the
  natural place to present a branch choice. Palvolve's manual trigger already behaves this
  way; keep it. (https://wiki.cassettebeasts.com/wiki/Fusion)

## Stage-count and BST shape

- [CONFIRMED] Pokemon bands: 3-stage ~300/405/480-540 BST (~+33%/+65-80% power); 2-stage one
  bigger jump (~+45%); strong single-stage species spend ~90% of a final form's budget up
  front. Palworld translation lives in STAT-MATH.md.
- [CONFIRMED] The pseudo-legendary contract: exactly one tier above everything else (flat
  600), painful middle stage, final threshold at ~85-90% of cap, **at most 1-2 such lines
  per content region.** (https://bulbapedia.bulbagarden.net/wiki/Pseudo-legendary_Pokemon)
- [CONFIRMED] Two growth archetypes: **uniform scaling** (Abra: +15 every stat per stage;
  safe, readable) and **identity pivot** (Magikarp->Gyarados: +340 concentrated into
  Attack; the line's story written in the stat delta). **RULE: default lines scale
  uniformly; signature lines pivot, concentrating the jump in the stats the final kit uses.**
- [CONFIRMED] Lateral evolutions are legal: Scyther->Scizor is 500->500, pure
  redistribution. **RULE: every evolution is a net win in some legible dimension, but not
  strictly better - give mid-stages an Eviolite-style reason to exist so "when do I evolve"
  is a real decision.**
- [INFERENCE] When NOT to evolve a species: the design is already complete (apex/legendary
  bodies), the niche IS the pre-evolution, or the story is done - a third stage bolted onto
  a finished two-beat arc is where "it just got bigger" criticism lives (Dudunsparce,
  Maushold).

## Branching

- [CONFIRMED] Branch condition taxonomy: player choice (Eevee stones, Applin items),
  trained-stat (Tyrogue: Atk vs Def at the threshold), gender+choice (Kirlia/Snorunt),
  hidden random (Wurmple - the resented kind).
  (https://bulbapedia.bulbagarden.net/wiki/List_of_Pokemon_with_branched_Evolutions)
- **RULE (locked): branches are choices, never dice.** Reachable deliberately, legible
  before the point of no return, both sides usable.
- [CONFIRMED] Branch siblings split ROLES, not power: shared partial statline, remainder
  redistributed (Hitmonlee/chan/top; Flapple fast vs Appletun bulk). A strictly-better
  branch is a trap, not a branch.
- [INFERENCE, flagship idea] **The Tyrogue steal:** branch at least one line on which stats
  the player actually invested (Atk-souls vs Def-souls / ivEach at the threshold). Palvolve's
  `ivTotal`/`ivEach` conditions make this buildable today; it converts Palworld's existing
  min-max currencies into an evolution steering wheel. Best single mechanical fit found in
  the research.

## Adjacent-genre steals

- [CONFIRMED] **Digimon (Cyber Sleuth):** evolution as a reversible optimization loop -
  de-digivolving earns ABI which unlocks deeper branches; the tree is explorable on one
  creature. Palvolve's rollback is our hook for this; see ECONOMY-DESIGN for the
  rollback-farming guard. (https://gamerant.com/digimon-story-cyber-sleuth-hackers-memory-get-ABI-tips-guide/)
- [CONFIRMED] **SMT fusion:** recipe-as-puzzle top-end chase, at the cost of attachment.
  Steal the recipe feel for rare evolutions (multi-condition gates); keep same-individual
  continuity - the condenser already occupies the "sacrifice copies" niche.
- [INFERENCE] **Regional variants** (Alolan/Galarian grammar) are the cheap sibling of
  evolution: same silhouette, element re-theme, biome-grounded story. Palvolve's 87 stock
  elemental adaptations are exactly this; our biome-flavored forms extend it.
