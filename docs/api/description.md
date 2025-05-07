L'API de rdv-insertion vous permet d'inviter des personnes en insertion à prendre rdv avec votre structure.
Quand l'usager aura pris rendez-vous suite à son invitation, vous pouvez récupérer les informations du rdv via les webhooks (API de notifications).

Toutes les fonctionnalités de rdv-insertion ne sont pas encore disponibles via l’API. Contactez-nous si vous avez besoin de fonctionnalités qui ne sont pas encore présentes.

# Requêtes

L'API adhère aux principes REST :

- requêtes `GET` : lecture sans modification
- requêtes `POST` : création de nouvelle ressource
- requêtes `PATCH` : mise à jour d'une ressource existante
- requêtes `DELETE` : suppression d'une ressource

Les paramètres des requêtes `GET` doivent être envoyés via les query string de la requête.

Les paramètres des requêtes `POST` doivent être transmis dans le corps de la requête sous un format JSON valide, et doivent contenir le header `Content-Type: application/json`.

# Routes

Les endpoints de l'API sont accessibles par une route de la forme : `https://<domain>/api/<version>/<endpoint>`.

Avec :

- `version` est la version de l'API
- `endpoint` est le nom de l'endpoint

Pour la version production, les requêtes doivent être adressées à **https://www.rdv-insertion.fr**.

Pour la version démo, les requêtes doivent être adressées à **https://demo.rdv-insertion.fr**.

# Authentification

Les endpoints sont réservés aux agents authentifiés, dans la limite de leur rôle au sein de l'application.

Comme sur l'interface web, l'authentification se fait via les identifiants rdv-solidarités. **Il est donc nécessaire pour l'authentification d'appeler un endpoint sur rdv-solidarités et non pas sur rdv-insertion**. Les modalités de cet endpoint sont décrits ci-dessous.

## Headers d'authentification

Tous les agents peuvent utiliser l'API. Les requêtes faites sur l'API sont authentifiées grace à des tokens d'accès associés à chaque agent. Chaque action faite via l'API est donc attribuable à un agent.

Pour récupérer le token d'accès d'un agent il faut faire une première requête `POST` à l'url `https://www.rdv-solidarites.fr/api/v1/auth/sign_in` en passant en paramètres JSON l'email et le mot de passe de l'agent. Par exemple (avec HTTPie) :

```httpie
http --json POST 'https://www.rdv-solidarites.fr/api/v1/auth/sign_in' \
  email='amine.dhobb@beta.gouv.fr' password='SOME_FAKE_PASSWORD_123456'
```

En cas de succès d'authentification, la réponse à cette requête contiendra dans le corps le détail de l'agent, et dans les headers les token d'accès à l'API. Par exemple :

```http
HTTP/1.1 200 OK
X-Frame-Options: SAMEORIGIN
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
X-Download-Options: noopen
X-Permitted-Cross-Domain-Policies: none
Referrer-Policy: strict-origin-when-cross-origin
Content-Type: application/json; charset=utf-8
access-token: SOME_FAKE_ACCESS_TOKEN_12345 token-type: Bearer
client: SOME_FAKE_CLIENT_12345 expiry: 1605600758
uid: amine.dhobb@beta.gouv.fr
ETag: W/"0fe52663d6745c922160384e13afe1e1"
Cache-Control: max-age=0, private, must-revalidate
X-Meta-Request-Version: 0.7.2
X-Request-Id: 291fab6a-043b-4b9c-b4b9-3c7fc9c9453a
X-Runtime: 0.194743< Transfer-Encoding: chunked
* Connection #0 to host rdv-solidarites.fr left intact
{
  "data": {
    "email": "amine.dhobb@beta.gouv.fr",
    "first_name": "Amine",
    "last_name": "DHOBB",
    "provider": "email",
    "uid": "amine.dhobb@beta.gouv.fr",
    "id": 7,
    "deleted_at": null,
    "service_id": 4,
    "email_original": null,
    "allow_password_change": false,
    "rdv_notifications_level": "soon",
    "unknown_past_rdv_count": 171,
    "display_saturdays": false,
    "display_cancelled_rdv": true,
    "plage_ouverture_notification_level": "all",
    "absence_notification_level": "all",
    "external_id": null,
    "calendar_uid": null,
    "microsoft_graph_token": null,
    "refresh_microsoft_graph_token": null,
    "cnfs_secondary_email": null,
    "outlook_disconnect_in_progress": false,
    "account_deletion_warning_sent_at": null
  }
}
* Closing connection 0
```

Les 3 headers essentiels pour l'authentification sont les suivants :

```http
access-token: SOME_FAKE_ACCESS_TOKEN_12345
client: SOME_FAKE_ACCESS_CLIENT_12345
uid: amine.dhobb@beta.gouv.fr
```

- `access-token` : c'est le jeton d'accès qui vous a été attribué. Il a une durée de vie de 24h, après ça il vous faudra reproduire cette procédure pour en récupérer un nouveau.
- `client` : un identifiant unique associé à l'appareil depuis lequel vous avez effectué la requête
- `uid` : l'identifiant de l'agent dans l'API, égal à l'email de l'agent.

**Ces 3 headers doivent être transmis avec chacune de vos requêtes successives à l'API**, peu importe la méthode HTTP.

## Permissions

Les rôles et permissions des agents sont les mêmes via l'API que depuis l'interface web.

# Sérialisation

L'API supporte uniquement le format JSON. Toutes les réponses envoyées par l'API contiendront le header `Content-Type: application/json` et leur contenu est présent dans le body dans un format JSON à désérialiser.

# Codes de retour

L'API est susceptible de retourner les codes suivants :

| Code  | Nom                   | Description                                                                   |
| ----- | --------------------- | ----------------------------------------------------------------------------- |
| `200` | Success               | Succès                                                                        |
| `204` | No Content            | Succès mais la réponse ne contient pas de données (exemple : suppression)     |
| `400` | Bad Request           | La requête est invalide                                                       |
| `401` | Unauthorized          | L'authentification a échoué                                                   |
| `403` | Forbidden             | Droits insuffisants pour réaliser l'action demandée                           |
| `404` | Not Found             | La ressource est introuvable                                                  |
| `422` | Unprocessable Entity  | La donnée transmise est mal formattée                                         |
| `429` | Too Many Requests     | Trop de requêtes ont été effectuées                                           |
| `500` | Internal Server Error | Une erreur serveur produite (l'équipe technique est notifiée automatiquement) |

# Erreurs

En cas d'erreur reconnue par le système (par exemple erreur 422), les champs suivants seront présents dans la réponse pour vous informer sur les problèmes :

- `errors` : [ERREUR] : liste d'erreurs groupées par attribut problèmatique au format machine.

# Endpoints

Les endpoints exposés par l'API se trouvent en bas de page. Pour chaque endpoint, vous trouverez en plus du schéma d'entrée et de sortie un exemple de payload envoyé à l'API et un exemple de réponse de l'API.
Le fonctionnement des endpoints de création et invitation des usagers est explicité dans la partie suivante.

# Création et invitations des usagers à prendre rdv

Il y a 2 façons d'inviter les usagers à prendre rdv:

- En envoyant dans une seule requête une liste d'usager à inviter (endpoint `POST https://www.rdv-insertion.fr/api/v1/organisations/{rdv_solidarites_organisation_id}/users/create_and_invite_many`). **La création des fiches d'usagers et l'envoi des invitations se fera alors de manière asynchrone**.

- En invitant une seule personne par requête (endpoint `POST https://www.rdv-insertion.fr/api/v1/organisations/{rdv_solidarites_organisation_id}/users/create_and_invite`). **La création de la fiche d'usager et l'envoi des invitations (mail et sms) se fera alors de manière synchrone**.

**Pour ces 2 endpoints, une invitation par mail sera envoyée que si le mail de l'usager est présent, et une invitation par SMS est envoyée que si le téléphone de l'usager est renseigné**.

## Paramètres de l'URL

- `rdv_solidarites_organisation_id`: c'est l'ID de l'organisation sur RDV-Solidarités dans laquelle on veut créer et inviter l'usager. Ces IDs peuvent être récupérés en requêtant l'endpoint `GET https://www.rdv-insertion.fr/api/v1/departments/{number}`. Le format de réponse est détaillé au bas de cette page.

## Paramètres dans le body de la requête

Le schéma détaillé avec exemple se trouve en bas de page. Ci-dessous on explique à quoi correspondent les attributs des usagers:

- `first_name`: STRING (requis): Prénom de l'usager
- `last_name`: STRING (requis): Nom de l'usager
- `title`: STRING (requis): Civilité de l'usager. Valeurs possibles: monsieur, madame.
- `affiliation_number`: STRING (requis) : Numéro CAF de l'usager.
- `role`: STRING (requis) : Le rôle de la personne au sein du dossier de demande RSA. Valeurs possibles: demandeur, conjoint.
- `email`: STRING (optionnel) : L'email e l'usager. S'il n'est pas présent l'invitation par email ne sera pas envoyée.
- `phone_number`: STRING (optionnel) : Le numéro de téléphone de l'usager. S'il n'est pas présent l'invitation par SMS ne sera pas envoyée.
- `birth_date`: STRING (optionnel) : Date de naissance de l'usager au format DD/MM/YYYY
- `nir` (optionnel) : NIR, Format à 13 chiffres : accepté, la clé NIR sera automatiquement calculée et ajoutée. Format complet à 15 chiffres : également accepté, dans ce cas la clé du NIR sera vérifiée.
- `france_travail_id` (optionnel) : numéro d'identification France Travail
- `rights_opening_date`: STRING (optionnel): Si l'usager est bénéficiaire du RSA, c'est la date de réception du 1er flux bénéficiaire quotidien qui montre que l'usager est un nouvel entrant). Au format DD/MM/YYYY.
- `address`: STRING (optionnel) : L'addresse de l'usager. Cette addresse comprend le code postal et la ville.
- `birth_name` : STRING (optionnel) : Le nom de naissance de l'usager
- `department_internal_id`: STRING (optionnel) : ID interne de la personne au sein du système d'information du département (cela peut être l'ID lié à l'éditeur comme l'ID de IODAS par exemple). Cet ID est nécessaire si l'on veut que rdv-insertion notifie de la prise/annulation de RDV sur une API côté département ou éditeur.
- `invitation`: OBJECT (optionnel): Contient les informations ci-dessous liées à l'invitation à prendre rdv:
  - `rdv_solidarites_lieu_id`: INTEGER (optionnel): L'ID du lieu dans lequel l'on veut que le RDV ait lieu. S'il est précisé l'usager sera invité directement à choisir un créneau sur ce lieu. Attention, il faut faire attention à ce qu'une plage d'ouverture pour le motif en question (voir attribut précédent) relie le motif au lieu en question. Ces valeurs peuvent être récupérérés en requêtant l'endpoint `GET https://www.rdv-insertion.fr/api/v1/departments/{number}`.
  - `motif_category: OBJECT (optionnel):
    - `name`: STRING: Le nom de la catégorie de motif pour laquelle on veut inviter l'usager. Il peut ne pas être précisé si l'organisation ne peut inviter que sur une seule catégorie. Ces valeurs peuvent être récupérérés en requêtant l'endpoint `GET https://www.rdv-insertion.fr/api/v1/departments/{number}`.
    - `short_name`: STRING: Alternativement au `name`, on peut préciser le nom court de la catégorie de motif pour laquelle on veut inviter l'usager. Il peut ne pas être précisé si l'organisation ne peut inviter que sur une seule catégorie. Il est présent dans la réponse de l'endpoint `GET https://www.rdv-insertion.fr/api/v1/departments/{number}`.
- `referents_to_add`: ARRAY(optionnel):
  - OBJECT:
    - `email` : STRING: email du referent à ajouter à l'usager. Si l'email ne correspond à aucun agent de l'organisation la requête échoue.
- `tags_to_add`: ARRAY(optionnel):
  - OBJECT:
    - `value` : STRING: nom du tag à ajouter à l'usager. Le tag doit exister au préalable dans l'organisation sinon la requête échoue.

## Idempotence

Ces 2 endpoints sont idempotents, ce qui veut dire que le fait de jouer ces requêtes plusieurs fois aura le même effet que de les jouer une seule fois. Plus précisément:

- Si l'usager que l'on essaie de créer est déjà présent dans l'application, il ne sera pas créé une deuxième fois. Il sera mis à jour si les attributs passés dans la requête sont changés par rapport à ce qui est enregistré en base de données.
- On ne renverra pas d'invitation à l'usager si une invitation a déjà été envoyée à l'usager il y a moins de 24 heures.

## Création et invitation asynchrone d'une liste d'usagers

- `POST https://www.rdv-insertion.fr/api/v1/organisations/{rdv_solidarites_organisation_id}/users/create_and_invite_many`

Cet endpoint permet de créer et inviter jusqu'à **25** usagers en une seule requête. La création de la fiche usager et son invitation à prendre rendez-vous se fait de manière asynchrone. Une requête aboutissant à un succès ne signifie donc pas forcément que les usagers seront créés et invités (voir détails ci-dessous).

### Réponse

Lors de l'envoi, nous allons vérifier que pour chaque usager les attributs requis sont présents et que tous les attributs passés sont au bon format (email, téléphone etc). Si c'est le cas la requête sera un succès. Cela ne veut pas dire que la création et l'invitation des usagers et l'invitation ont été un succès car ces actions se feront de manière asynchrone.

#### En cas de succès

Si la requête est un succès, nous répondrons avec un statut 200 et un body en JSON notifiant le succès de la requête (voir détails du format de réponse en bas de page).

#### En cas d'échec

Si la requête est un échec (voir conditions plus haut), nous répondrons avec un statut 422 et un body en JSON contenant les erreurs de la requête, avec pour chaque entrée les erreurs (voir détails du format de réponse en bas de page).

### Notifications asynchrones

Lors du processus asynchrone de création et des invitations des usagers des erreurs peuvent avoir lieu, bien que la réponse à la requête ait été un succès. Il faut alors notifier l'organisation de ces échecs.

#### En cas de problèmes à la création de l'usager

En cas d'échec de la création de l'usager, un mail sera envoyé à la personne ayant fait la requête avec l'identité de l'usager en question et les erreurs associées à sa création.

![mail-notification](/api_doc/mail-notification.png)

#### En cas de problèmes à l'invitation de l'usager

S'il y a un problème lors de l'invitation d'un usager, l'organisation ne sera pas notifiée directement.
Pour voir si les personnes ont bien été invitées, on peut:

- Aller sur l'interface web RDV-I et vérifier dans la liste que les personnes ont bien été invitées (les coches sont cochées pour chaque format d'invitation dans la liste des usagers)
- Souscrire au webhook envoyé lorsqu'une invitation est envoyée. Les détails de ces webhooks sont explicités dans la partie webhooks ci-dessous.

## Création et invitation synchrone d'un usager

- `POST https://www.rdv-insertion.fr/api/v1/organisations/{rdv_solidarites_organisation_id}/users/create_and_invite`

Cet endpoint permet de créer et inviter un seul usager à prendre rdv. Contrairement à l'endpoint permettant d'inviter une liste d'usager, la réponse est ici synchrone: La requête est un succès que si la personne a été créée et invitée.

Les formats des réponses sont spécifiés en bas de page.

# Webhooks (API de notifications)

rdv-insertion peut notifier des évènements ayant lieu sur l'application dans votre système d’information à l’aide de webhooks.

rdv-insertion peut notifier n'importe quel système d'information accessible en ligne lors de **modifications** (création, modification, suppression) sur les **RDV** et les **invitations**.

Ainsi, lorsqu'un rdv est créé, modifié ou supprimé sur rdv-insertion, nous avons la possiblité de vous envoyer une requête à un endpoint de votre côté avec en payload les informations du rdv.

Pour cela, ce système d'informations doit :

- être accessible à une URL publique et accepter des requêtes HTTP POST à cette URL

## Configuration

Pour pouvoir configurer un endpoint prêt à recevoir les webhooks de rdv-insertion, [vous devez prendre contact avec l'équipe rdv-insertion](mailto:rdv-insertion@beta.gouv.fr) et leur donner l'URL qui les recevra et convenir d'un token `secret` partagé.

## Signatures des requêtes

Un **secret partagé** est associé à chacune de ces URLs pour vous permettre de vérifier que nous sommes bien à l'origine de l'envoi d'information. La requête envoyée en HTTP POST contient un entête `X-RDVI-Signature` qui contient une signature SHA256 hexadécimale du corps de la requête.

Par exemple, pour vérifier que la signature vient bien de notre application, cela donnerait en `ruby` :

![webhook-signature-check-example](/api_doc/webhook-signature-check-example.png)

## Format des données

Le payload des requêtes est envoyés sont un format JSON. Ce payload contient deux attributs:

- `data` : c'est le payload de la ressource au format JSON. Les payloads de chaque ressource sont disponibles en bas de page.
- `meta` : un objet contenant les trois attributs suivants:
  - `model` : Le nom de la ressource que l'on envoie. Pour les rdvs elle sera égale à `Rdv`
  - `event` : l'évènement ayant déclenché l'envoi du webhook. Il a trois valeurs possibles: `created`, `updated` et `destroyed`
  - `timestamp` : un string représentant le moment où le webhook est envoyé.

## Exemple

Ci-dessous un exemple de payload envoyé lorsqu'un rdv est créé:

```json
{
  "data": {
    "id": 325,
    "starts_at": "2023-11-14T09:00:00.000+01:00",
    "duration_in_min": 25,
    "cancelled_at": null,
    "address": "Die, 26150, 26, Drôme, Auvergne-Rhône-Alpes",
    "uuid": "2bc2393b-bf2c-47f0-9f84-e30a6b067138",
    "created_by": "agent",
    "status": "unknown",
    "users_count": 1,
    "max_participants_count": null,
    "rdv_solidarites_rdv_id": 344,
    "agents": [
      {
        "id": 2,
        "email": "amine.dhobb@beta.gouv.fr",
        "first_name": "Amine",
        "last_name": "DHOBB",
        "rdv_solidarites_agent_id": 7
      }
    ],
    "lieu": {
      "rdv_solidarites_lieu_id": 9,
      "name": "Batiment région Rhône-Alpes",
      "address": "Die, 26150, 26, Drôme, Auvergne-Rhône-Alpes",
      "phone_number": "0839230303"
    },
    "motif": {
      "rdv_solidarites_motif_id": 45,
      "name": "RSA Orientation : Convocation sur site",
      "collectif": false,
      "location_type": "public_office",
      "follow_up": false,
      "motif_category": {
        "id": 1,
        "short_name": "rsa_orientation",
        "name": "RSA orientation"
      }
    },
    "users": [
      {
        "id": 722,
        "uid": "Nzg2NzY4NyAtIGRlbWFuZGV1cg==",
        "affiliation_number": "7867687",
        "role": "demandeur",
        "created_at": "2023-07-26T12:19:08.522+02:00",
        "department_internal_id": null,
        "first_name": "Andreas",
        "last_name": "Kopke",
        "title": "monsieur",
        "address": "165 rue saint maur 75011 Paris",
        "phone_number": "+33664891033",
        "email": "remi.betagouv+demo67576567@gmail.com",
        "birth_date": "1987-12-20",
        "rights_opening_date": null,
        "birth_name": null,
        "rdv_solidarites_user_id": 468,
        "nir": null,
        "france_travail_id": null,
      }
    ],
    "organisation": {
      "id": 4,
      "name": "CD de DIE",
      "email": null,
      "phone_number": "01 01 01 01 01",
      "department_number": "26",
      "rdv_solidarites_organisation_id": 29,
      "motif_categories": [
        {
          "id": 1,
          "short_name": "rsa_orientation",
          "name": "RSA orientation"
        },
        {
          "id": 2,
          "short_name": "rsa_accompagnement",
          "name": "RSA accompagnement"
        },
        {
          "id": 4,
          "short_name": "rsa_cer_signature",
          "name": "RSA signature CER"
        },
        {
          "id": 17,
          "short_name": "psychologue",
          "name": "Psychologue"
        }
      ]
    },
    "participations": [
      {
        "id": 291,
        "status": "unknown",
        "created_by": "agent",
        "created_at": "2023-11-09T09:25:05.356+01:00",
        "starts_at": "2023-11-14T09:00:00.000+01:00",
        "user": {
          "id": 722,
          "uid": "Nzg2NzY4NyAtIGRlbWFuZGV1cg==",
          "affiliation_number": "7867687",
          "role": "demandeur",
          "created_at": "2023-07-26T12:19:08.522+02:00",
          "department_internal_id": null,
          "first_name": "Andreas",
          "last_name": "Kopke",
          "title": "monsieur",
          "address": "165 rue saint maur 75011 Paris",
          "phone_number": "+33664891033",
          "email": "andreas@kopke.com",
          "birth_date": "1987-12-20",
          "rights_opening_date": null,
          "birth_name": null,
          "rdv_solidarites_user_id": 468,
          "nir": null,
          "france_travail_id": null
        }
      }
    ]
  },
  "meta": {
    "model": "Rdv",
    "event": "created",
    "timestamp": "2023-11-13 19:53:07 +0100"
  }
}
```
