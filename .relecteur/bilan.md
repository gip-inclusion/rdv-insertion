# Bilan des évaluations du reviewer

## Ce que mesure relecteur

relecteur rejoue 26 pull requests mergées de rdv-insertion, décrites dans `.relecteur/cases`. Le reviewer relit
chacune avec `REVIEW.md` et `AGENTS.md` pour consignes, puis un juge (Jev, seuil 0,5) compare ses remarques à ce qui
était attendu.

- **11 cas de silence** : des PR approuvées sans remarque de fond, où le reviewer doit se taire. Ces cas seuls décident
  du verdict.
- **15 cas de défaut**, pour 23 défauts connus, dont 5 failles de sécurité : le reviewer doit tous les signaler, sans
  dépasser un plafond de remarques (le nombre de défauts plus un).

## Les passes comparées

Toutes en effort élevé, un groupe de fichiers à la fois, et notées sur les 24 premiers cas tels qu'ils sont
aujourd'hui.

| | DeepSeek V4 Flash (Albert), 10 oct. | DeepSeek V4 Flash (Albert), 11 oct. | Claude Opus 5.5, 13 oct. |
| --- | --- | --- | --- |
| Cas de silence sans aucune remarque | 11/11 | 11/11 | 10/11 |
| Défauts signalés | 8/18 | 5/18 | 15/18 |
| dont défauts que la review humaine avait laissé passer | 6/13 | 4/13 | 11/13 |
| Cas de défaut réussis | 4/13 | 4/13 | 6/13 |
| Tokens, durée | 10,6 M, 81 min | 9,2 M, 106 min | 5,4 M, 32 min |

Opus 5.5 a coûté environ 8 $ pour les 24 cas.

- Opus signale bien plus de défauts que DeepSeek, en deux fois moins de tokens et deux à trois fois moins de temps.
- Il échoue sur 7 cas de défaut : 4 par excès de remarques (#2974, #3108, #3128, #3275), 3 par un défaut manqué.
- Le rappel de DeepSeek varie beaucoup d'une passe à l'autre (8 puis 5 défauts).

Le reviewer par défaut reste DeepSeek V4 Flash sur Albert. Opus 5.5 se lance en passant
`--model-url https://api.anthropic.com --model claude-opus-5-5` à `relecteur eval`.

## Les cas de sécurité

Deux cas ajoutés le 17 octobre, passés seulement avec DeepSeek, et notés par le juge Albert :

- **#2159** (3 failles d'autorisation) : DeepSeek en signale 2, l'agent basique qui modifie les autorisations d'export
  et les rôles d'autres organisations. Il manque l'admin repassé basique qui garde le droit d'exporter. 1,3 M de
  tokens, 24 min.
- **#2184** (2 failles XSS par le motif d'archivage) : pas de résultat. Albert a limité le débit (HTTP 429) avant la
  fin, avec 63 fichiers relus sur 74, après 12,8 M de tokens et 99 min. La politique pour les grosses PR se décidera
  avec la review déployée en CI.

## Les cas de silence où Opus a parlé

Au moment des passes, Opus a parlé sur trois des 13 cas de silence d'alors.

- **#3173** : un vrai défaut, laissé passer par la review. Une orientation qui commence le jour même n'est pas active,
  et la détection des chevauchements dépend de l'heure. Le cas est devenu un cas de défaut, corrigé par
  [#3408](https://github.com/gip-inclusion/rdv-insertion/pull/3408).
- **#3086** : le défaut qu'avait relevé la review humaine, et que le cas rangeait parmi les simplifications. Le cas est
  devenu un cas de défaut relevé en review.
- **#3318** : une remarque juste, mais de faible gravité. Le cas reste un cas de silence : `REVIEW.md` laisse ces
  remarques aux relecteurs humains.

## Ce qui a changé, et ce qui reste

- Le skill `build-eval-cases` de relecteur relit désormais chaque cas de silence comme le ferait le reviewer, pour ne
  plus garder des cas comme #3173 et #3086.
- Reste à examiner les remarques en trop d'Opus sur #2974, #3108, #3128 et #3275, puis à décider des plafonds face à un
  reviewer qui trouve davantage.
