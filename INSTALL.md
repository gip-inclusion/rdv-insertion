# Installation

## Prérequis

- Déploiement:
  - Ruby 3.0.3 (nous conseillons l’utilisation de [rbenv](https://github.com/rbenv/rbenv-installer#rbenv-installer--doctor-scripts))
  - PostgreSQL >= 12, l’utilisateur doit avoir les droits `superuser`. C'est nécessaire pour pouvoir activer les extensions utilisés.
- Développement
  - [Yarn](https://yarnpkg.com/en/docs/install)
  - [Foreman](https://github.com/ddollar/foreman), (ou équivalent, comme [Overmind](https://github.com/DarthSim/overmind))
  - [Scalingo CLI](https://doc.scalingo.com/cli) (OPTIONAL)
  - [Make](https://fr.wikipedia.org/wiki/Make) (OPTIONAL)

## Important

Cette application est conçue pour fonctionner en complément de rdv-solidarités
rdv-solidarités doit donc être installé et tourner en local pour obtenir un environnement de dev fonctionnel
Le code de rdv-solidarités peut être trouvé ici : https://github.com/betagouv/rdv-solidarites.fr/

## Setup

Voir les variables d'environnement pour configurer l'accès à PostgreSQL

Le script se charge d’installer les gems et packages et de créer la base de données.
```bash
make install  ## appelle bin/setup
```

Assurez-vous d'avoir une instance de redis en cours d'éxecution

Il ne reste (si tout s’est bien passé) qu’à lancer un serveur le serveur.
```bash
make run      ## appelle foreman s -f Procfile.dev
```

Il n'y a pas d'agent créé dans les seeds : les agents utilisateurs de rdv-insertion sont récupérés de rdv-solidarités
Les informations à ce sujet peuvent être trouvées dans [le fichier de seeds](db/seeds.rb)


## Commandes

Un [Makefile](https://github.com/betagouv/rdv-insertion/blob/staging/Makefile) est disponible, qui sert de point d’entrée aux différents outils :

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
