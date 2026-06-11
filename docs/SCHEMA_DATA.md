# Documentation du Schéma de Données - rdv-insertion

## Introduction

rdv-insertion est une application qui permet aux départements français de gérer le suivi des bénéficiaires du RSA et plus généralement tous les usagers qui sont dans un parcours d'insertion. L'application s'interface avec RDV-Solidarités pour la gestion des rendez-vous.

## Architecture Générale

L'application fonctionne selon le principe suivant :
1. Les **départements** contiennent des **organisations** (conseils départementaux, France Travail, etc.)
2. Les **users** (usagers) sont suivis dans des **organisations**
3. Un **follow_up** est créé pour chaque **motif_category** sur un **user** pour suivre l'avancement de l'usager sur cette catégorie
4. Des **invitations** sont envoyées pour prendre des rendez-vous
5. Les **rdvs** (rendez-vous) sont créés, avec des **participations** pour chaque usager
6. Les **agents** sont rattachés aux organisations via des **agent_roles**


---

## Tables Principales

### **users** - Usagers

Représente les usagers suivis dans l'application, souvent des bénéficaires du RSA.

**Rôle** : Centralise toutes les informations sur les usagers

**Champs clés** :
- `rdv_solidarites_user_id` : ID dans RDV-Solidarités (synchronisation)
- `first_name`, `last_name` : Identité
- `email`, `phone_number`, `address` : Coordonnées pour les contacter
- `affiliation_number` : Numéro d'allocataire CAF
- `department_internal_id` : ID de l'usager dans le SI du département
- `france_travail_id` : Identifiant France Travail
- `nir` : Numéro de sécurité sociale (encrypté)
- `role` : "demandeur" ou "conjoint"
- `deleted_at` : Soft delete pour RGPD
- `created_through` : Source de création ("rdv_insertion_upload_page", "rdv_solidarites_webhook", etc.)

**Relations** :
- Appartient à plusieurs `organisations` via `users_organisations`
- A plusieurs `follow_ups` (un par catégorie de motif)
- A plusieurs `invitations`
- A plusieurs `participations` (aux RDV)
- A plusieurs `tags` via `tag_users`
- A plusieurs `orientations`

---

### **organisations** - Structures Territoriales

Représente les structures qui suivent les usagers (CD, France Travail, SIAE, etc.)

**Rôle** : Structure organisationnelle qui regroupe agents, usagers et configuration

**Champs clés** :
- `rdv_solidarites_organisation_id` : ID dans RDV-Solidarités
- `name` : Nom de l'organisation
- `department_id` : Département de rattachement
- `organisation_type` : Type (conseil_departemental, delegataire_rsa, france_travail, siae, autre)
- `email`, `phone_number` : Coordonnées
- `safir_code` : Code SAFIR pour France Travail
- `archived_at` : Date d'archivage si inactive
- `data_retention_duration_in_months` : Durée de conservation des données (RGPD)

**Relations** :
- Appartient à un `department`
- A plusieurs `agents` via `agent_roles`
- A plusieurs `users` via `users_organisations`
- A plusieurs `category_configurations`
- A plusieurs `motifs`, `lieux`, `rdvs`

---

### **departments** - Départements

Représente les départements français.

**Rôle** : Niveau administratif supérieur qui regroupe les organisations d'un territoire

**Champs clés** :
- `name` : Nom du département
- `number` : Numéro (ex: "75", "93")
- `capital` : Préfecture
- `region` : Région administrative
- `email`, `phone_number` : Contact départemental
- `parcours_enabled` : Active/désactive le module "parcours"
- `disable_ft_webhooks` : Désactive les webhooks France Travail

---

### **follow_ups** - Suivis

**C'est LA table centrale du métier.** Représente le suivi d'un usager pour une catégorie de motif donnée.

**Rôle** : Suit l'état d'avancement d'un usager dans son parcours (orientation, accompagnement, etc.)

**Champs clés** :
- `user_id` : Usager suivi
- `motif_category_id` : Catégorie de motif (orientation RSA, accompagnement, etc.)
- `status` : Statut du suivi (voir ci-dessous)
- `closed_at` : Date de clôture du suivi

**Statuts possibles** :
- `not_invited` : Pas encore invité
- `invitation_pending` : Invitation envoyée, en attente de RDV
- `rdv_pending` : RDV prévu
- `rdv_needs_status_update` : RDV passé, statut à mettre à jour
- `rdv_noshow` : Usager absent
- `rdv_revoked` : RDV annulé
- `rdv_excused` : Absence excusée
- `rdv_seen` : RDV honoré
- `closed` : Suivi terminé

**Relations** :
- Appartient à un `user`
- Appartient à une `motif_category`
- A plusieurs `invitations`
- A plusieurs `participations`

---

### **invitations** - Invitations à prendre RDV

Représente une invitation envoyée à un usager pour qu'il prenne rendez-vous.

**Rôle** : Trace les invitations (SMS, email, courrier) avec leur lien de prise de RDV

**Champs clés** :
- `user_id` : Usager invité
- `follow_up_id` : Suivi concerné
- `format` : "sms", "email" ou "postal"
- `link` : URL de prise de RDV sur RDV-Solidarités
- `rdv_solidarites_token` : Token d'authentification
- `uuid` : Identifiant court pour l'URL publique
- `expires_at` : Date d'expiration de l'invitation
- `clicked` : L'usager a-t-il cliqué sur le lien ?
- `trigger` : "manual" (manuelle) ou "reminder" (relance)
- `delivery_status` : Statut de livraison (Brevo)
- `rdv_with_referents` : Invitation à un rdv avec référent ?
- `help_phone_number` : Numéro d'aide affiché
- `created_by_agent_id` : Agent ayant initié l'envoi de l'invitation

**Relations** :
- Appartient à un `user`
- Appartient à un `follow_up`
- Appartient à un `department`
- Associée à plusieurs `organisations` (HABTM)

---

### **rdvs** - Rendez-vous

Représente un rendez-vous créé dans RDV-Solidarités.

**Rôle** : Synchronise les RDV depuis RDV-Solidarités pour le suivi local

**Champs clés** :
- `rdv_solidarites_rdv_id` : ID dans RDV-Solidarités
- `starts_at` : Date/heure de début
- `duration_in_min` : Durée en minutes
- `organisation_id` : Organisation concernée
- `motif_id` : Motif du RDV
- `lieu_id` : Lieu du RDV (optionnel si à distance)
- `status` : Statut du RDV
- `cancelled_at` : Date d'annulation
- `created_by` : Origine ("agent", "user", "prescripteur")
- `context` : Contexte/notes
- `users_count` : Nombre de participants
- `max_participants_count` : Nombre max de participants RDV collectifs

**Relations** :
- A plusieurs `participations` (usagers participants)
- A plusieurs `users` via `participations` (les rdvs pouvant être collectifs)
- Appartient à une `organisation`
- Appartient à un `motif`
- Appartient à un `lieu` (optionnel)
- A plusieurs `agents` via `agents_rdvs`

---

### **participations** - Participations aux RDV

**Table de jonction enrichie** entre users et rdvs.

**Rôle** : Lie un usager à un RDV avec son statut de participation

**Champs clés** :
- `user_id` : Usager participant
- `rdv_id` : Rendez-vous
- `follow_up_id` : Suivi associé
- `status` : Statut de la participation (unknown, excused, seen, noshow, revoked)
- `rdv_solidarites_participation_id` : ID dans RDV-Solidarités
- `convocable` : Est-ce une convocation obligatoire ?
- `created_by_type` : Qui a créé le RDV ("Agent", "User", "Prescripteur")
- `created_by_agent_prescripteur` : Créé par un agent prescripteur ?
- `france_travail_id` : ID France Travail de l'usager

**Relations** :
- Appartient à un `user`
- Appartient à un `rdv`
- Appartient à un `follow_up`
- A plusieurs `notifications`

---

### **agents** - Agents

Représente les professionnels utilisant l'application.

**Rôle** : Compte utilisateur des agents (travailleurs sociaux, conseillers, etc.)

**Champs clés** :
- `rdv_solidarites_agent_id` : ID dans RDV-Solidarités
- `email` : Email (unique, identifiant de connexion)
- `first_name`, `last_name` : Identité
- `super_admin` : Est super-administrateur ?
- `last_sign_in_at` : Dernière connexion
- `cgu_accepted_at` : Date d'acceptation des CGU

**Relations** :
- A plusieurs `agent_roles` (un par organisation)
- A plusieurs `organisations` via `agent_roles`
- A plusieurs `referent_assignations` (usagers dont il est référent)
- A plusieurs `rdvs` via `agents_rdvs`

---

### **agent_roles** - Rôles des agents

**Table de jonction enrichie** entre agents et organisations.

**Rôle** : Définit les droits d'un agent dans une organisation

**Champs clés** :
- `agent_id` : Agent concerné
- `organisation_id` : Organisation
- `access_level` : "basic" ou "admin"
- `authorized_to_export_csv` : Droit d'export CSV (auto à true pour admin)
- `rdv_solidarites_agent_role_id` : ID dans RDV-Solidarités

---

### **motif_categories** - Catégories de motifs

Représente les grandes catégories de RDV (orientation RSA, accompagnement RSA, etc.)

**Rôle** : Classification des types de suivis

**Champs clés** :
- `rdv_solidarites_motif_category_id` : ID dans RDV-Solidarités
- `name` : Nom complet
- `short_name` : Nom court (unique)
- `motif_category_type` : Type (rsa_orientation, rsa_accompagnement, siae, autre)
- `template_id` : Template de messages associé

**Types** :
- `rsa_orientation` : Orientation RSA
- `rsa_accompagnement` : Accompagnement RSA
- `siae` : SIAE (Structures d'Insertion par l'Activité Économique)
- `autre` : Autres

---

### **motifs** - Motifs de RDV

Représente les motifs de RDV spécifiques dans RDV-Solidarités.

**Rôle** : Type précis de RDV (ex: "Entretien d'orientation", "Atelier CV")

**Champs clés** :
- `rdv_solidarites_motif_id` : ID dans RDV-Solidarités
- `organisation_id` : Organisation propriétaire
- `motif_category_id` : Catégorie de rattachement
- `name` : Nom du motif
- `location_type` : "public_office" (présentiel), "phone" (téléphone), "home" (domicile)
- `bookable_by` : Qui peut réserver ? (agents, agents_and_prescripteurs, agents_and_prescripteurs_and_invited_users, everyone)
- `collectif` : RDV collectif ou individuel ?
- `follow_up` : Est un motif de suivi avec référent ? (ne pas confondre avec la table **follow_up** de rdv-i)
- `deleted_at` : Date de suppression (soft delete)
- `instruction_for_rdv` : Instructions pour le RDV

---

### **category_configurations** - Configurations par organisation

**Table centrale de configuration.** Lie une organisation à une catégorie de motif avec sa configuration.

**Rôle** : Paramétrage des invitations et suivis pour un binôme organisation/catégorie

**Champs clés** :
- `organisation_id` : Organisation
- `motif_category_id` : Catégorie de motif
- `file_configuration_id` : Configuration des imports CSV
- `invitation_formats` : Formats autorisés ["sms", "email", "postal"]
- `convene_user` : Peut convoquer obligatoirement ?
- `number_of_days_before_invitations_expire` : Durée de validité des invitations
- `invite_to_user_organisations_only` : Inviter uniquement dans les orgas de l'usager ?
- `rdv_with_referents` : RDV avec les référents ?
- `phone_number` : Numéro de téléphone de contact
- `email_to_notify_no_available_slots` : Email de notification si pas de créneaux
- `email_to_notify_rdv_changes` : Email de notification des changements de RDV
- `template_*_override` : Surcharges des templates de messages

---

### **lieux** - Lieux de RDV

Représente les lieux physiques où se déroulent les RDV.

**Rôle** : Adresses des permanences, agences, etc.

**Champs clés** :
- `rdv_solidarites_lieu_id` : ID dans RDV-Solidarités
- `organisation_id` : Organisation propriétaire
- `name` : Nom du lieu
- `address` : Adresse complète
- `phone_number` : Téléphone

---

### **archives** - Archives d'usagers

Représente l'archivage d'un usager dans une organisation.

**Rôle** : Indique qu'un usager n'est plus suivi par une organisation

**Champs clés** :
- `user_id` : Usager archivé
- `organisation_id` : Organisation
- `archiving_reason` : Raison de l'archivage

---

### **orientations** - Orientations

Représente une orientation d'un usager vers une organisation sur une période.

**Rôle** : Suit les orientations RSA (qui suit qui et quand)

**Champs clés** :
- `user_id` : Usager orienté
- `organisation_id` : Organisation d'orientation
- `agent_id` : Agent référent (optionnel)
- `orientation_type_id` : Type d'orientation
- `starts_at` : Date de début
- `ends_at` : Date de fin (null = en cours)

---

### **orientation_types** - Types d'orientation

Représente les types d'orientations possibles dans un département.

**Rôle** : Classification des orientations (ex: "Accompagnement socio-professionnel")

**Champs clés** :
- `name` : Nom du type
- `casf_category` : Catégorie CASF (Code de l'Action Sociale et des Familles)
- `department_id` : Département

---

### **tags** - Étiquettes

Représente les tags/étiquettes à appliquer aux usagers.

**Rôle** : Permet de catégoriser les usagers (ex: "QPV", "Jeune", "Senior")

**Champs clés** :
- `value` : Valeur du tag

**Relations** :
- Associé à plusieurs `users` via `tag_users`
- Associé à plusieurs `organisations` via `tag_organisations`

---

### **notifications** - Notifications

Représente les notifications envoyées aux usagers concernant leurs RDVs de convocation.

**Rôle** : Trace les SMS/emails/courriers de rappel, confirmation, annulation de RDV

**Champs clés** :
- `participation_id` : Participation concernée
- `event` : Type d'événement (participation_created, participation_updated, participation_cancelled, participation_reminder)
- `format` : "sms", "email" ou "postal"
- `rdv_solidarites_rdv_id` : ID du RDV
- `delivery_status` : Statut de livraison
- `sms_provider` : Fournisseur SMS utilisé (pour les sms)

---

## Tables d'Import de Fichiers

### **user_list_uploads** - Imports de fichiers

Représente un import de fichier CSV/Excel d'usagers.

**Rôle** : Trace les imports en masse d'usagers

**Champs clés** :
- `agent_id` : Agent ayant importé
- `structure_type`, `structure_id` : Department ou Organisation (polymorphic)
- `category_configuration_id` : Configuration (si import avec invitation)
- `file_name` : Nom du fichier

---

### **user_list_upload_user_rows** - Lignes d'import

Représente chaque ligne d'un fichier importé.

**Rôle** : Stocke temporairement les données avant validation et création

**Champs clés** :
- `user_list_upload_id` : Import parent
- Tous les champs usager : `first_name`, `last_name`, `email`, etc.
- `matching_user_id` : Usager correspondant trouvé
- `cnaf_data` : Données de l'usager provenant du fichier données de contact de la CNAF
- `assigned_organisation_id` : Organisation assignée
- `selected_for_invitation` : Sélectionné pour invitation ?
- `selected_for_user_save` : Sélectionné pour sauvegarde ?

---

### **user_list_upload_user_save_attempts** - Tentatives de sauvegarde

Représente les tentatives de création/mise à jour d'usagers depuis un import.

**Champs clés** :
- `user_row_id` : Ligne d'import
- `user_id` : Usager créé/mis à jour
- `success` : Succès ou échec
- `error_type` : Type d'erreur
- `service_errors` : Messages d'erreur

---

### **user_list_upload_invitation_attempts** - Tentatives d'invitation

Représente les tentatives d'invitation depuis un import.

**Champs clés** :
- `user_row_id` : Ligne d'import
- `invitation_id` : Invitation créée
- `format` : Format d'invitation
- `success` : Succès ou échec
- `service_errors` : Messages d'erreur

---

## Tables de Configuration

### **file_configurations** - Configurations d'import

Représente la configuration de mapping des colonnes pour les imports CSV/Excel.

**Rôle** : Définit quelle colonne du fichier correspond à quel champ usager

**Champs clés** :
- Tous les champs `*_column` : mapping des colonnes (ex: `first_name_column`, `email_column`)
- `sheet_name` : Nom de l'onglet Excel
- `created_by_agent_id` : Agent créateur

---

### **templates** - Templates de messages

Représente les templates de messages pour les invitations et notifications.

**Rôle** : Textes types utilisés dans les communications

**Champs clés** :
- `model` : Nom du modèle
- `rdv_title` : Titre du RDV
- `rdv_title_by_phone` : Titre pour RDV téléphonique
- `rdv_purpose` : Objet du RDV
- `user_designation` : Désignation de l'usager
- `rdv_subject` : Sujet du RDV
- `custom_sentence` : Phrase personnalisée
- `punishable_warning` : Avertissement sur les sanctions

---

### **messages_configurations** - Configuration des messages

Configuration des en-têtes et signatures des messages par organisation.

**Rôle** : Personnalisation des communications

**Champs clés** :
- `organisation_id` : Organisation (optionnel, peut être au niveau département)
- `direction_names` : Noms des directions
- `sender_city` : Ville émettrice
- `letter_sender_name` : Nom de l'expéditeur courrier
- `signature_lines` : Lignes de signature
- `sms_sender_name` : Nom d'expéditeur SMS
- `logos_to_display` : Affichage des logos

---

### **dpa_agreements** - Accords DPA

Représente l'acceptation du DPA (Data Processing Agreement) par une organisation.

**Rôle** : Conformité RGPD

**Champs clés** :
- `organisation_id` : Organisation
- `agent_id` : Agent ayant accepté
- `agent_email`, `agent_full_name` : Infos de l'agent

---

## Tables Techniques

### **csv_exports** - Exports CSV

Trace les exports CSV effectués par les agents.

**Champs clés** :
- `agent_id` : Agent exportateur
- `structure_type`, `structure_id` : Department ou Organisation
- `kind` : Type d'export
- `request_params` : Paramètres de la requête
- `purged_at` : Date de purge du fichier

---

### **stats** - Statistiques

Statistiques calculées pour un département ou une organisation.

**Rôle** : Cache des métriques de performance (polymorphic sur `statable`)

**Champs clés** :
- `statable_type`, `statable_id` : Department ou Organisation
- Nombreuses métriques : `users_count`, `rdvs_count`, `rate_of_autonomous_users`, etc.
- Versions groupées par mois : `*_grouped_by_month`

---

### **versions** - Historique des modifications

Historique des modifications (gem paper_trail).

**Rôle** : Audit trail des changements sur certains modèles

---

### **webhook_endpoints** - Endpoints webhooks

Endpoints webhook pour notifier des systèmes externes.

**Champs clés** :
- `organisation_id` : Organisation (optionnel, peut être global)
- `url` : URL du webhook
- `secret` : Secret de signature
- `subscriptions` : Événements souscrits
- `signature_type` : Type de signature (HMAC)

---

### **webhook_receipts** - Réceptions webhook

Trace les webhooks envoyés depuis rdv-insertion.

**Champs clés** :
- `webhook_endpoint_id` : Endpoint
- `resource_model`, `resource_id` : Ressource concernée
- `timestamp` : Date d'envoi

---

### **blocked_users** - Usagers bloqués

Usagers dont le lien d'invitation renvoyait vers des créneaux indisponibles. On récupère tous les soirs ces usagers et on les insère dans cette table si l'usager n'a pas déjà été inséré les 30 derniers jours.

**Champs clés** :
- `user_id` : Usager bloqué

---

### **blocked_invitations_counters** - Compteurs d'invitations bloquées

Nombre des invitations dont le lien renvoie vers des créneaux indisponibles par organisation. Calculé tous les soirs.

---

### **creneau_availabilities** - Disponibilités de créneaux

Suivi du nombre de créneaux disponibles pour une configuration.

**Champs clés** :
- `category_configuration_id` : Configuration
- `number_of_creneaux_available` : Nombre de créneaux
- `number_of_pending_invitations` : Nombre d'invitations en attente

---

### **parcours_documents** - Documents parcours

Documents uploadés dans le module "parcours" (contrats, diagnostics).

**Champs clés** :
- `user_id` : Usager
- `department_id` : Département
- `agent_id` : Agent créateur
- `type` : Type de document (STI: "Diagnostic", "Contract")
- `document_date` : Date du document

---

### **referent_assignations** - Assignations de référents

Lie un usager à ses agents référents.

**Champs clés** :
- `user_id` : Usager
- `agent_id` : Agent référent

---

### **address_geocodings** - Géocodage d'adresses

Résultat du géocodage des adresses des usagers (API Adresse).

**Champs clés** :
- `user_id` : Usager
- `latitude`, `longitude` : Coordonnées GPS
- `post_code`, `city`, `city_code` : Localisation
- `street`, `house_number` : Détails adresse

---

### **cookies_consents** - Consentements cookies

Choix de consentement cookies des agents.

---

### **super_admin_authentication_requests** - Auth super-admin

Demandes d'authentification renforcée en tant que super-admin.

---

### **user_list_upload_processing_logs** - Log des temps de traitement d'une liste d'usager

Log les temps de traitement (sauvegarde d'usagers, invitations) d'une liste d'usagers

## Tables Active Storage

### **active_storage_attachments**
### **active_storage_blobs**
### **active_storage_variant_records**

Tables standard de ActiveStorage pour la gestion des fichiers (logos, CSV, etc.)

---

## Flux de Données Typiques

### 1. Ajout d'un usager et invitation

1. Création d'un `User`
2. Création d'une liaison `UsersOrganisation`
3. Création d'un `FollowUp` (statut: `not_invited`)
4. Création d'une `Invitation`
5. Le `FollowUp` passe en statut `invitation_pending`

### 2. Prise de RDV par l'usager

1. L'usager clique sur le lien d'invitation (update `clicked: true`)
2. Création du RDV dans RDV-Solidarités
3. Webhook reçu → création d'un `Rdv` local
4. Création d'une `Participation`
5. Le `FollowUp` passe en statut `rdv_pending`

### 3. Après le RDV

1. L'agent met à jour le statut de la `Participation` (seen, noshow, excused)
2. Le `FollowUp` se met à jour automatiquement (`rdv_seen`, `rdv_noshow`, etc.)

---

## Points d'Attention pour l'Analyse

### Synchronisation RDV-Solidarités
Beaucoup de tables ont un champ `rdv_solidarites_*_id` et `last_webhook_update_received_at` car elles sont synchronisées depuis RDV-Solidarités via webhooks.

### Soft Deletes
Les `users`, `motifs` utilisent `deleted_at` pour le soft delete (RGPD).

### Encryption
Les champs `nir` (numéro de sécurité sociale) sont encryptés.

### Polymorphisme
- `statable` (stats) : Department ou Organisation
- `structure` (exports, uploads) : Department ou Organisation
- `created_from_structure` (users) : Department ou Organisation

### Paper Trail
Les modifications sur certains modèles critiques (User, AgentRole, Archive, etc.) sont tracées dans `versions`.
