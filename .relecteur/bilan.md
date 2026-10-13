# Bilan des évaluations du reviewer

## Ce que mesure relecteur

relecteur rejoue 24 pull requests mergées de rdv-insertion, décrites dans `.relecteur/cases`. Le reviewer relit
chacune comme si elle venait d'être ouverte, avec `REVIEW.md` et `AGENTS.md` pour consignes, puis un juge compare ses
remarques à ce qui était attendu.

- **13 cas de silence** : des PR approuvées sans remarque de fond (`max_findings = 0`). Le bon comportement est de ne
  rien dire. Ces cas seuls décident du verdict.
- **11 cas de défaut** : des PR qui contenaient en tout 15 défauts connus (bug, faille, convention écrite non
  respectée), corrigés ensuite. Le reviewer doit les signaler sans dépasser un plafond de remarques (`max_findings`,
  le nombre de défauts plus un). Un cas de défaut est réussi quand tous ses défauts sont signalés et le plafond
  respecté.
- **Le juge** (Jev, seuil 0,5) dit si une remarque décrit un défaut attendu. Une remarque ne compte que pour un défaut,
  celui dont le juge est le plus sûr.

## Les passes comparées

Toutes en effort élevé, un groupe de fichiers à la fois. Les passes DeepSeek, notées à l'origine par le juge Albert,
ont été notées à nouveau par Jev pour comparer.

| | DeepSeek V4 Flash (Albert), 10 oct. | DeepSeek V4 Flash (Albert), 11 oct. | Claude Opus 5.5, 13 oct. |
| --- | --- | --- | --- |
| Cas de silence sans aucune remarque | 13/13 | 13/13 | 10/13 |
| Défauts signalés | 8/15 | 5/15 | 12/15 |
| dont défauts que la review humaine avait laissé passer | 6/11 | 4/11 | 9/11 |
| Cas de défaut réussis | 3/11 | 4/11 | 4/11 |
| Tokens, durée | 10,6 M, 81 min | 9,2 M, 106 min | 5,4 M, 32 min |

Opus 5.5 a coûté environ 8 $ pour les 24 cas, soit 0,35 $ par review.

- Opus signale bien plus de défauts que DeepSeek, surtout parmi ceux que la review humaine avait laissé passer, en
  deux fois moins de tokens et deux à trois fois moins de temps.
- Sur les 3 cas de silence où il a parlé, deux de ses remarques décrivent de vrais défauts : c'est le cas qui se
  trompait, pas le reviewer (voir plus bas).
- Ses cas de défaut échouent surtout par excès de remarques : sur 7 échecs, 4 ont tous leurs défauts signalés.
- Le rappel de DeepSeek varie beaucoup d'une passe à l'autre (8 puis 5 défauts) ; sur ses trois passes, 12 défauts sur
  15 ont été signalés au moins une fois.

Le reviewer par défaut reste DeepSeek V4 Flash sur Albert. Opus 5.5 se lance en passant
`--model-url https://api.anthropic.com --model claude-opus-5-5` à `relecteur eval`.

## Les cas de silence où Opus a parlé

### #3173 : un vrai défaut, toujours sur `staging`

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

**Décision** : le cas devient un cas de défaut, laissé passer par la review (`escaped_review = true`), une fois le
défaut corrigé sur `staging`, puisqu'un cas de défaut renvoie à son correctif (`fix`).

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

Opus relève le même point, en bug : un usager qui a eu un rendez-vous, puis une invitation, puis dont le suivi a été
clos et rouvert, garde l'ancienne invitation pour référence, et aucune relance ne part.

**Décision** : le cas devient un cas de défaut relevé en review (`escaped_review = false`), dont le correctif est le
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

## Ce qui reste

- Corriger le défaut de #3173 sur `staging`, puis convertir le cas ; convertir #3086.
- Examiner les remarques en trop d'Opus sur #2974, #3108, #3128 et #3275, puis décider des plafonds face à un reviewer
  qui trouve davantage.
