# API rdv-insertion pour la plateforme de l'inclusion

Cette API permet à la plateforme de l'inclusion de récupérer, à partir de son NIR, le parcours d'un usager sur rdv-insertion : ses organisations, ses référents, ses suivis, ses invitations et ses rendez-vous.

| Environnement | URL |
| --- | --- |
| Production | `https://www.rdv-insertion.fr` |
| Démo | `https://demo.rdv-insertion.fr` |

## Authentification

Chaque requête doit contenir le header `Authorization` avec le token transmis par l'équipe rdv-insertion :

```
Authorization: Bearer <token>
```

## Rechercher un usager par NIR

```
POST /api/plateforme_inclusion/users/search
```

### Requête

Le NIR doit être transmis sur 15 caractères, clé comprise.

```bash
curl -X POST https://www.rdv-insertion.fr/api/plateforme_inclusion/users/search \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{ "nir": "285032612345653" }'
```

### Réponses

| Code | Signification |
| --- | --- |
| `200` | Une fiche usager correspond au NIR. |
| `401` | Le token est absent ou invalide. |
| `404` | Aucune fiche usager ne correspond au NIR. |
| `409` | Plusieurs fiches usager correspondent au NIR. Aucune donnée n'est renvoyée, pour ne pas risquer d'afficher les informations d'une autre personne. L'équipe rdv-insertion est alertée pour corriger les données. |
| `429` | Plus de 500 requêtes en 5 minutes. Réessayer après le délai indiqué dans le header `Retry-After`. |

Les erreurs `401`, `404` et `409` ont la même forme :

```json
{ "errors": ["Plusieurs usagers correspondent à ce NIR"] }
```

### Exemple de réponse `200`

```json
{
  "user": {
    "id": 1,
    "affiliation_number": "1234567",
    "role": "demandeur",
    "created_at": "2026-09-01T10:00:00.000+02:00",
    "department_internal_id": "8765",
    "first_name": "Camille",
    "last_name": "Martin",
    "title": "madame",
    "address": "12 rue des Lilas 26000 Valence",
    "phone_number": "+33612345678",
    "email": "camille.martin@example.com",
    "birth_date": "1985-03-12",
    "rights_opening_date": null,
    "birth_name": null,
    "rdv_solidarites_user_id": 9876,
    "nir": "285032612345653",
    "france_travail_id": null,
    "referents": [
      {
        "id": 2,
        "email": "claire.durand@drome.fr",
        "first_name": "Claire",
        "last_name": "Durand",
        "rdv_solidarites_agent_id": 42
      }
    ],
    "tags": [
      { "id": 1, "value": "Prioritaire" }
    ],
    "follow_ups": [
      {
        "id": 1,
        "created_at": "2026-09-01T10:00:00.000+02:00",
        "status": "rdv_seen",
        "human_status": "RDV honoré",
        "closed_at": null,
        "motif_category": { "id": 1, "short_name": "rsa_orientation", "name": "RSA orientation" },
        "participations": [
          {
            "id": 1,
            "status": "seen",
            "created_at": "2026-09-01T10:00:00.000+02:00",
            "starts_at": "2026-09-15T14:00:00.000+02:00",
            "created_by": "agent",
            "rdv": {
              "id": 1,
              "duration_in_min": 30,
              "cancelled_at": null,
              "address": "5 avenue de la Gare 26000 Valence",
              "uuid": "2a1f0d7e-6b3c-4c8e-9f11-3d2e5b7a9c10",
              "created_by": "agent",
              "status": "seen",
              "users_count": 1,
              "max_participants_count": null,
              "rdv_solidarites_rdv_id": 5555,
              "starts_at": "2026-09-15T14:00:00.000+02:00",
              "agents": [
                {
                  "id": 2,
                  "email": "claire.durand@drome.fr",
                  "first_name": "Claire",
                  "last_name": "Durand",
                  "rdv_solidarites_agent_id": 42
                }
              ],
              "lieu": {
                "rdv_solidarites_lieu_id": 77,
                "name": "Maison départementale de Valence",
                "address": "5 avenue de la Gare 26000 Valence",
                "phone_number": null
              },
              "motif": {
                "rdv_solidarites_motif_id": 55,
                "name": "Rendez-vous d'orientation",
                "collectif": false,
                "location_type": "public_office",
                "follow_up": false,
                "motif_category": { "id": 1, "short_name": "rsa_orientation", "name": "RSA orientation" }
              },
              "organisation": {
                "id": 1,
                "name": "Plateforme Insertion Valence",
                "email": "insertion@drome.fr",
                "phone_number": "0475000000",
                "department_number": "26",
                "rdv_solidarites_organisation_id": 1234,
                "department_id": 1
              }
            }
          }
        ],
        "invitations": [
          {
            "id": 1,
            "format": "sms",
            "clicked": false,
            "rdv_with_referents": false,
            "created_at": "2026-09-01T10:00:00.000+02:00",
            "delivery_status": null,
            "delivered_at": null,
            "expires_at": "2026-09-08T10:00:00.000+02:00"
          }
        ]
      }
    ],
    "organisations": [
      {
        "id": 1,
        "name": "Plateforme Insertion Valence",
        "email": "insertion@drome.fr",
        "phone_number": "0475000000",
        "department_number": "26",
        "rdv_solidarites_organisation_id": 1234,
        "department_id": 1,
        "user_archived_at": null
      }
    ]
  }
}
```

## Description des données

Les dates sont au format ISO 8601, avec le décalage horaire. Les champs `rdv_solidarites_*_id` sont les identifiants de l'objet sur RDV-Solidarités, l'outil de prise de rendez-vous utilisé par rdv-insertion.

### Organisations

`user_archived_at` est la date d'archivage de l'usager dans l'organisation, ou `null` s'il n'y est pas archivé.

### Suivis (`follow_ups`)

Un suivi correspond au parcours de l'usager dans une catégorie de motifs (orientation, accompagnement…), indiquée par `motif_category`. `closed_at` est la date de clôture du suivi, ou `null` s'il est en cours.

| `status` | `human_status` |
| --- | --- |
| `not_invited` | Non invité |
| `invitation_pending` | Invitation en attente de réponse |
| `invitation_expired` | Invitation sans réponse (délai dépassé) |
| `rdv_pending` | RDV à venir |
| `rdv_needs_status_update` | Statut du RDV à préciser |
| `rdv_noshow` | Absence non excusée au RDV |
| `rdv_revoked` | RDV annulé par le service |
| `rdv_excused` | RDV annulé par l'usager (excusé) |
| `rdv_seen` | RDV honoré |
| `closed` | Dossier traité |

### Participations et rendez-vous

Une participation représente la présence de l'usager à un rendez-vous (`rdv`). La participation et le rendez-vous ont chacun leur statut : pour un rendez-vous collectif, le statut du rendez-vous (`rdv.status`) peut différer de celui de l'usager (`status`).

| `status` | Signification |
| --- | --- |
| `unknown` | Rendez-vous à venir, ou statut pas encore renseigné |
| `seen` | Rendez-vous honoré |
| `excused` | Annulé par l'usager |
| `revoked` | Annulé par le service |
| `noshow` | Absence non excusée |

`created_by` indique qui a pris le rendez-vous : `agent`, `user` (l'usager lui-même) ou `prescripteur`.

`motif.location_type` indique le mode du rendez-vous : `public_office` (sur place), `phone` (téléphone), `home` (à domicile) ou `visio`.

### Invitations

Une invitation est un message envoyé à l'usager pour qu'il prenne rendez-vous.

- `format` : `sms`, `email` ou `postal`.
- `clicked` : l'usager a cliqué sur le lien de prise de rendez-vous.
- `delivery_status` : `delivered` si le message a été remis, `soft_bounce`, `hard_bounce`, `blocked`, `invalid_email` ou `error` en cas d'échec, `null` si l'information n'est pas disponible.
- `expires_at` : date à partir de laquelle l'invitation n'est plus valable.
