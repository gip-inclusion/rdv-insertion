# Bilan des évaluations du reviewer

## Ce que mesure relecteur

relecteur rejoue 24 pull requests mergées de rdv-insertion, décrites dans `.relecteur/cases`. Le reviewer relit
chacune comme si elle venait d'être ouverte, avec `REVIEW.md` et `AGENTS.md` pour consignes, puis un juge compare ses
remarques à ce qui était attendu.

- **11 cas de silence** : des PR approuvées sans remarque de fond (`max_findings = 0`). Le bon comportement est de ne
  rien dire. Ces cas seuls décident du verdict.
- **13 cas de défaut** : des PR qui contenaient en tout 18 défauts connus (bug, faille, convention écrite non
  respectée), corrigés ensuite. Le reviewer doit les signaler sans dépasser un plafond de remarques (`max_findings`,
  le nombre de défauts plus un). Un cas de défaut est réussi quand tous ses défauts sont signalés et le plafond
  respecté.
- **Le juge** (Jev, seuil 0,5) dit si une remarque décrit un défaut attendu. Une remarque ne compte que pour un défaut,
  celui dont le juge est le plus sûr.

## Les passes comparées

Toutes en effort élevé, un groupe de fichiers à la fois, et notées par Jev sur les cas tels qu'ils sont aujourd'hui :
#3173 et #3086, des cas de silence au moment des passes, sont devenus des cas de défaut après la passe Opus (voir plus
bas). Les reviews DeepSeek du 10 octobre sur #3128 et #3275 ne sont plus disponibles ; ces deux cas n'ayant pas
changé, leur notation précédente est reprise.

| | DeepSeek V4 Flash (Albert), 10 oct. | DeepSeek V4 Flash (Albert), 11 oct. | Claude Opus 5.5, 13 oct. |
| --- | --- | --- | --- |
| Cas de silence sans aucune remarque | 11/11 | 11/11 | 10/11 |
| Défauts signalés | 8/18 | 5/18 | 15/18 |
| dont défauts que la review humaine avait laissé passer | 6/13 | 4/13 | 11/13 |
| Cas de défaut réussis | 3/13 | 4/13 | 6/13 |
| Tokens, durée | 10,6 M, 81 min | 9,2 M, 106 min | 5,4 M, 32 min |

Opus 5.5 a coûté environ 8 $ pour les 24 cas, soit 0,35 $ par review.

- Opus signale bien plus de défauts que DeepSeek, surtout parmi ceux que la review humaine avait laissé passer, en
  deux fois moins de tokens et deux à trois fois moins de temps.
- Seul Opus a signalé les défauts de #3173 et #3086 : DeepSeek n'en a signalé aucun sur ses deux passes.
- Opus ne parle plus que sur un cas de silence, #3318, pour une remarque juste mais de faible gravité.
- Ses cas de défaut échouent surtout par excès de remarques : sur 7 échecs, 4 ont tous leurs défauts signalés.
- Le rappel de DeepSeek varie beaucoup d'une passe à l'autre (8 puis 5 défauts).

Le reviewer par défaut reste DeepSeek V4 Flash sur Albert. Opus 5.5 se lance en passant
`--model-url https://api.anthropic.com --model claude-opus-5-5` à `relecteur eval`.

## Les cas de silence où Opus a parlé

Au moment des passes, les cas comptaient 13 cas de silence, et Opus a parlé sur trois d'entre eux.

### #3173 : un vrai défaut, laissé passer par la review

La PR corrige les orientations actives de l'export CSV : celles sans date de fin n'y étaient pas comptées. Elle a été
approuvée sans commentaire.

```ruby
# app/models/orientation.rb
def time_range
  starts_at...(ends_at.presence || Time.zone.now)
end

def active?
  time_range.cover?(Time.zone.today.beginning_of_day)
end
```

Opus relève que `starts_at` et `ends_at` sont des `Date`. Comparée à un `TimeWithZone`, une `Date` passe par
`Date#to_datetime`, soit minuit UTC, plus tard que minuit à Paris. Vérifié en Ruby :

- une orientation qui commence le jour même n'est pas active, même avec une date de fin, alors qu'elle l'était avant
  la PR ;
- une orientation qui finit le jour même devient active, alors que la borne de fin est exclue ;
- `time_range.to_a`, qui sert à détecter les chevauchements dans `Orientations::Save`, ne contient la date du jour
  qu'après 1 h du matin à Paris (2 h en été) : la détection dépend de l'heure.

La remarque interdite du cas visait une autre affirmation, fausse : que la comparaison renverrait `nil`.

**Décision** : le cas est devenu un cas de défaut laissé passer par la review (`escaped_review = true`), avec deux
défauts, `active?` et `time_range`, que corrige [#3408](https://github.com/gip-inclusion/rdv-insertion/pull/3408).

### #3318 : juste, mais de faible gravité

La PR affiche aux agents la période où les usagers invités peuvent prendre rendez-vous, calculée à partir des délais
de réservation des motifs. La review a porté sur l'abstraction, la signature du helper et des guard clauses ; personne
n'a parlé du format de la période.

```ruby
# app/helpers/application_helper.rb
start_format = starts_on.month == ends_on.month ? "%-d" : "%-d %B"
"du #{I18n.l(starts_on, format: start_format)} au #{I18n.l(ends_on, format: '%-d %B %Y')}"
```

Opus relève que seul le mois est comparé, pas l'année : avec un délai maximum d'un an, la période s'affiche « du 13 au
13 octobre 2027 ». RDV-Solidarités accepte un délai maximum jusqu'à un an (trois mois par défaut), et le helper n'a
pas changé sur `staging` : le défaut est réel, mais il ne touche que l'affichage, pour un motif réglé à 11 ou 12 mois.

**Décision** : le cas reste un cas de silence. `REVIEW.md` range un défaut de faible gravité parmi les remarques pour
les relecteurs humains, pas parmi les findings ; Opus l'a classé de gravité moyenne.

### #3086 : le défaut que la review humaine avait relevé

La PR fait partir les relances pour les usagers en ré-entrée (issue #3074), qui n'en recevaient pas parce que
l'invitation de référence était la toute première. Au commit rejoué, le job de relance s'appuie sur :

```ruby
# app/models/concerns/invitable.rb
def reference_invitation_for_current_period
  participations.any? ? first_invitation_after_last_participation : last_manual_invitation
end
```

La review humaine a commenté cette ligne : « on peut toujours dans le cas du reminder prendre `last_manual_invitation`
non ? S'il y a une participation ou non je ne pense pas que ça change grand chose ». L'auteur a appliqué la remarque,
et le code mergé prend la dernière invitation manuelle dans tous les cas. Le cas classait ce commentaire comme une
simplification.

Opus relève le même point, en bug : un usager qui a eu un rendez-vous, puis une invitation, puis qu'on invite de
nouveau garde la première invitation pour référence, et la nouvelle ne reçoit aucune relance.

**Décision** : le cas est devenu un cas de défaut relevé en review (`escaped_review = false`), dont le correctif est le
commit de la PR qui a appliqué la remarque.

## Les cas de défaut échoués par Opus

Tous les défauts signalés, plafond dépassé :

| Cas | Remarques | Plafond |
| --- | --- | --- |
| #2974 | 5 | 3 |
| #3108 | 3 | 2 |
| #3128 | 8 | 3 |
| #3275 | 3 | 2 |

Sur #3128, l'une des remarques est une remarque interdite, et le cas a raison de l'interdire :
`human_follow_up_status` de l'export des participations n'est jamais appelée. Sur #3275, les trois remarques décrivent
trois conséquences distinctes du retrait de la queue `default` de Sidekiq.

Un défaut manqué :

- #3131, `notifiable?`, qu'aucune passe n'a jamais signalé ;
- #3182, `put_object_acl` ;
- #3329, `find_by`.

## Ce qui a changé, et ce qui reste

- Le cas de #3173 venait du skill `build-eval-cases` de relecteur, qui jugeait une PR saine faute de correctif après
  son merge ; celui de #3086, ajouté pendant la calibration, rangeait un commentaire parmi les simplifications d'après
  sa formulation. Le skill relit désormais chaque cas de silence comme le ferait le reviewer, en vérifiant chaque
  soupçon, et juge un commentaire de review sur le code, pas sur sa formulation.
- Reste à examiner les remarques en trop d'Opus sur #2974, #3108, #3128 et #3275, puis à décider des plafonds face à un
  reviewer qui trouve davantage.
