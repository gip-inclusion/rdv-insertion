# Installation

## Outils à installer

- Ruby 3.0.3 (nous conseillons l’utilisation de [rbenv](https://github.com/rbenv/rbenv-installer#rbenv-installer--doctor-scripts))
- PostgreSQL >= 12, l’utilisateur doit avoir les droits `superuser`. C'est nécessaire pour pouvoir activer les extensions utilisés.
- [Yarn](https://yarnpkg.com/en/docs/install)
- [Foreman](https://github.com/ddollar/foreman), (ou équivalent, comme [Overmind](https://github.com/DarthSim/overmind))
- [Scalingo CLI](https://doc.scalingo.com/cli) (OPTIONAL)
- [Make](https://fr.wikipedia.org/wiki/Make) (OPTIONAL)

## Avant de commencer

### Installer RDV-Solidarités

Cette application est conçue pour fonctionner en complément de RDV-Solidarités.
RDV-Solidarités doit donc être installé et tourner en local pour obtenir un environnement de dev fonctionnel.

Le code source de RDV-Solidarités peut être trouvé [ici](https://github.com/betagouv/rdv-solidarites.fr/).

Les instructions d'installation sont [ici](https://github.com/betagouv/rdv-solidarites.fr/blob/production/docs/1-installation.md).

### Créer un territoire, une organisation et les webhook endpoints

**Les [seeds](https://github.com/betagouv/rdv-solidarites.fr/blob/production/db/seeds.rb) de RDV-Solidarités permettent de créer les différents éléments dont vous aurez besoin pour utiliser l'application en local.**

En effet pour utiliser RDV-Insertion proprement en local, il est nécessaire de créer sur RDV-Solidarités :

- Les territories et organisations correspondant aux départments et organisations que l'on va utiliser sur RDV-Insertion (voir [Setup](#Setup))

- Rattacher l'agent aux organisations via un `AgentRole` (de préférence avec le access_level `admin`)

- Configurer les webhooks de chaque organisation pour les envoyer vers l'appli RDV-Insertion en local (`POST http://localhost:8000/rdv_solidarites_webhooks`)

Ainsi le fichier [seeds](https://github.com/betagouv/rdv-solidarites.fr/blob/production/db/seeds.rb) permet de créer:

- Le territoire de la Drôme avec 2 organisations ("Plateforme mutualisée d'orientation" et "Plie Valence") et le territoire de l'Yonne avec une organisation ("UT Avallon")
- Un agent [`Alain Sertion`](https://github.com/betagouv/rdv-solidarites.fr/blob/feffeda72d4b07e7866b6f2b063fb448cd2be178/db/seeds.rb#L658) admin sur ces organisations avec des plages d'ouvertures préconfigurées

- Les webhooks qui pointent vers RDV-Insertion pour ces orgas

## Installer RDV-Insertion

### Seeds

Avant de le lancer les commandes suivantes, veuillez mettre à jour [le fichier de seeds](db/seeds.rb) pour que les organisations que l'on crée pointent vers les organisations créés précédemment sur RDV-Solidarités (en changeant le `rdv_solidarites_organisation_id` au niveau des organisations).
De la même facon, vérifier `rdv_solidarites_agent_id` pour notre agent de test et les `rdv_solidarites_motif_id` et `rdv_solidarites_service_id` pour les motifs.
Enfin, prenez soin de définir la variable `SHARED_SECRET_FOR_AGENTS_AUTH` à une valeur commune dans les fichiers `.env` des deux projets. Dans le cas contraire, les deux applications ne seront pas en mesure de communiquer et certaines fonctionnalités seront dysfonctionnelles (i.e, ajout de nouveaux usagers)

Se connecter sur RDV-Insertion avec les identifiants RDV-Solidarités crée automatiquement l'agent sur RDV-Insertion.

### Lancer l'appli

Le script suivant se charge d’installer les gems et packages et de créer la base de données.

```bash
make install  ## appelle bin/setup
```

Assurez-vous d'avoir une instance de redis en cours d'éxecution.

Il ne reste (si tout s’est bien passé) qu’à lancer un serveur le serveur.

```bash
make run      ## appelle foreman s -f Procfile.dev
```

### Dans l'appli

Vous trouverez dans le dossier [Resources](https://github.com/betagouv/rdv-insertion/tree/staging/docs/resources) 2 fichiers de test pour l'import des usagers via l'upload dans l'application : Un fichier xlsx contenant des usagers et un fichier csv de contacts.


### Installation du service de génération de pdf

Cloner en local le repo https://github.com/gip-inclusion/pdf-generator.
Assurez vous d'avoir ces valeurs dans vos variables d'environnement pour pdf-generator (`.env`)

```
API_KEY=your-secret-api-key
PORT=8501
```

Lancer le serveur Express avec `npm start`

Assurez vous d'avoir ces valeurs dans vos variables d'environnement pour rdv-insertion (`.env`)

```
PDF_GENERATOR_URL=http://localhost:8501
PDF_GENERATOR_API_KEY=your-secret-api-key
```

## Commandes

Un [Makefile](https://github.com/betagouv/rdv-insertion/blob/staging/Makefile) est disponible, qui sert de point d’entrée aux différents outils :

```bash
> make help
install              Setup development environment
run                  Start the application (web, jobs et webpack)
lint                 Run all linters
lint_rubocop         Ruby linter
lint_eslint          Javascript Linter
test                 Run all tests
autocorrect          Fix autocorrectable lint issues
clean                Clean temporary files (including weppacks) and logs
help                 Display available commands
```
