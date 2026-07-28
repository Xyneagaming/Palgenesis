# Verify Ledger

Disputed or version-sensitive values the research could not pin. Each is a gate: **do not
balance around the value until its test has run in OUR build** (local dedicated server,
build 619, via tools/palserver-test.ps1 + selftest.lua, or in-client probes). Record the
measured value + date here when a gate closes; then update the lane files.

| # | Claim in dispute | Sources disagree | In-engine test | Status |
|---|---|---|---|---|
| G1 | Element effectiveness multipliers | wiki 2x/0.5x vs FightingBread datamine 1.5x/0.65x | Fixed attacker/defender pair, fixed skill, log damage across matchups (selftest pass: spawn/become two known pals, scripted hits, parse damage events) | OPEN |
| G2 | Condenser rank + souls survive Palvolve swap | README says yes [CONFIRMED-doc]; never field-tested by us | Condense + soul a test pal, `!pg evolve`, read back rank/souls via SaveParameter dump | OPEN |
| G3 | Condenser 4-star cost in 1.0 | 116 copies (pre-1.0) vs 48 (1.0 patch notes coverage) | Read live condenser config/DT, or count in-client | OPEN |
| G4 | Live level cap (1.0 build 619) | agents reported 60 / 65 / "~80-85" | Read from game config/DT; all threshold rules are %-of-cap until closed | OPEN |
| G5 | Species base stats + element roster counts | game8 vs Fextralife variance (±5-15); 1.0 added 72 pals after some counts | Dump DT_PalMonsterParameter rows via harness (row-name read already proven) — OUR numbers, not a wiki's | OPEN |
| G6 | Exclusive-flag blocks fruit + breeding leak | inferred from DT category; unverified | Flag a test skill exclusive; check orchard availability + breed-inheritance over N eggs | OPEN |
| G7 | Live 1.0 waza power/CT values | wikis mix pre-1.0 and 1.0 numbers (Fire Ball 150/55 vs 600/30) | Dump DT_WazaDataTable via harness before ANY moveset authoring | OPEN |
| G8 | Same-element (STAB) bonus = +20% | consistent across sources but same caveat as G1 | Same rig as G1, on/off element match | OPEN |
| G9 | Palvolve rollback refunds vs side effects (IV bonus kept?) | read from costs.lua/evolution.lua, not field-tested | Evolve + rollback a test pal; diff IVs and materials | OPEN |

Priority order: **G7 and G5 first** (they block moveset and stat authoring outright), then
G1/G8 (damage tuning), G2/G9 (economy rules), G3/G4 (thresholds), G6 (signature design).
G5 + G7 are pure DT dumps — one selftest pass can close both.
