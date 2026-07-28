# Visual Design

Creature-design craft for evolved forms. Load before any concept, texture, or model pass.
Sibling of the vault-wide reference-first rule: gather refs BEFORE authoring.

## Sugimori-school core [CONFIRMED - sourced interviews]

1. **Silhouette first**: the design must read as a black shape (Hydreigon kept a
   many-headed silhouette with one head). (https://shmuplations.com/pokemon/,
   https://lavacutcontent.com/ken-sugimori-nintendo-dream/)
2. **1 main color + 1-2 accents; palette communicates element** (Pikachu is yellow because
   electricity is).
3. **Animal x one concept**, not three (Zoroark = kitsune x illusionist).
4. **Simple enough to symbolize** - drawable from memory.
5. **"Keep the balance"**: deliberately add something uncool to anything too cool; a
   humanizing flaw beats perfection. (https://www.nintendolife.com/news/2018/07/ken_sugimori_wants_pokemon_designs_to_be_as_memorable_as_possible)
6. **Design the apex form first, derive the babies** (Ohmura's workflow).

## Evolution visual grammar [COMMUNITY]

- The contract is **"same soul, grown up"**: baby ratios (big head/eyes, round) -> hero
  proportions, cute->cool by default.
- **Motif retention is what fans audit**: transforming props (Oshawott's scalchop becomes
  Samurott's swords), continuous color story, surviving shape motifs. Meowstic is the
  documented motif-abandonment failure; Dudunsparce the "just got bigger" one.
- **Quadruped->biped is the loudest resentment** (Skeledirge was celebrated for staying
  four-legged). **RULE (locked): posture class never changes across a line.**
- Radical change is accepted when lore earns it (Magikarp->Gyarados).

## Palworld-native style markers [COMMUNITY + INFERENCE from direct observation]

To read as Pocketpair, not Pokemon-pasted:
- Chunky rounded mass distribution; short thick limbs; mascot-toy proportions persist up
  the power curve. Soft PBR "vinyl toy" shading, NOT cel-shade.
- Eyes: large glossy simple ovals, big specular, slightly derpy even on strong pals.
- Surface detail VERY low: large uninterrupted color fields, 1-2 marking shapes max; detail
  lives in silhouette tufts, not painted texture.
- Saturation high, cream/white ventral fields, even on dark pals.
- Every pal has one goofy touch (Pocketpair shares Sugimori's balance rule).
- 1.0 redesigns pushed pals rounder/less humanoid - that's the house instinct.
- Variant convention [CONFIRMED]: same mesh + palette re-theme + element swap, suffix-coded
  (Cryst/Ignis/Lux/Noct/Terra/Aqua/Gild). An EVOLUTION must change silhouette too, or it
  reads as a cheap B-variant - new-mesh-with-motif-carryover is exactly our gap.

## Dark-creature palette conventions [COMMUNITY]

Umbreon formula: near-black base + ONE luminous marking system + one eye accent, sleek
silhouette, zero clutter. Zoroark: desaturated body + one big saturated feature + a tiny
jewel accent. Palworld codes Dark as violet-black base + magenta/violet glow (Katress/Nox
family). Night-creature cross-genre: bioluminescent markings as the readable feature; eyes
brightest point; wisps suggested by fur shapes, never particles (3D constraint below).

## Meshy/3D production constraints [CONFIRMED - Meshy docs]

- Input: single clean 3/4 or front view, plain background, strong contrast; multi-view mode
  (front/side/back orthos) for back fidelity.
- **Fails**: thin appendages, strand fur, floating/detached parts, overlapping limbs, fine
  surface detail, volumetric flame/smoke.
- **Survives**: chunky tapered masses, fur as sculpted tufts/wedges, thick ears/tails,
  neutral four-square stance, glow painted as flat emissive shapes (re-applied as emission
  material in Blender after).
- Happy accident: these constraints point the SAME direction as Palworld-native style.
- Deliverables per form: 3/4 hero render + front/side/back orthos on flat mid-grey +
  greyscale value study proving the marking hierarchy reads.

## Regional-variant grammar [COMMUNITY]

Same animal, same silhouette, new cultural/biome anchor, new palette, ONE new physical
feature (Alolan Ninetales, Hisuian Arcanine). **Write the one-line habitat story before
drawing** - it disciplines every choice.

## The eight-point checklist (every evolved form passes all)

1. Silhouette test: unique black shape at 64px AND recognizably the base grown up; posture
   class kept.
2. Palette: 1 base + 1 secondary field + 1 element-coded accent; max 3 colors before glow.
3. **Motif carryover minimum three**, each visibly evolved; the element-feature transforms
   rather than vanishes.
4. Recontextualize, never just resize ("bigger + spikier" = reject).
5. Palworld-native markers (above), incl. one goofy touch.
6. Not-Pokemon check: side-by-side vs the nearest Pokemon; different markings, eyes,
   proportions.
7. 3D constraints baked into the concept sheet.
8. One-line habitat/lore anchor written first.

## Foxgloam brief [PROPOSAL - ratify with Sayber before the concept pass]

1. **Concept**: Foxparks grown into a twilight kitsune-adolescent - the campfire that
   burned down to embers and learned to move in the dark. Rhymes with the Noct convention.
2. **Silhouette**: quadruped, ~1.6-1.8x Foxparks' mass, longer legs/neck (kit->adolescent),
   swept-back ears, one thick tapered tail (save multi-tail for a later stage).
3. **Palette**: deep charcoal-violet base; smoke-cream ventral field (Foxparks' cream,
   recolored); ember-magenta->violet emissive accents; saturation Palworld-high.
4. **Motif carryover x3**: neck-ruff flames -> plush dark ruff with emissive ember-flecks
   (same location); flame tail-tip -> coal-glow tail tip; round glossy eyes -> same shape,
   ember-orange/magenta (the one warm note proving the fire didn't die).
5. **Keep-the-balance flaw**: one ear-tip that still sparks ordinary orange fire it can't
   suppress (or a too-fluffy tail it trips over).
6. **Partner-skill hook**: stealth/night utility; ruff flecks brighten when active (lit
   emissive state = texture swap).
7. **Anti-Pokemon**: NO rings (Umbreon), NO mane (Zoroark); marking system = scattered
   ember-fleck constellation, literalizing "sparks."
8. **Sheet spec**: four-square stance, legs separated, mouth closed, tail clear of body;
   hero + orthos + greyscale pass; all glow as flat emissive shapes, no particle flames in
   anything fed to Meshy.
