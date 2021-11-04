# RDV INSERTION

L'objectif de ce service numérique public est de faciliter la prise de 1er RDV RSA en permettant aux agents
de s'interfacer facilement avec [RDV-Solidarites](https://github.com/betagouv/rdv-solidarites.fr).

## Installation

### Pré-requis

Veuillez installer les outils suivants pour pouvoir lancer le projet:

- **Ruby 3.0.2**: Nous conseillons l'utilisation de [Rbenv](https://github.com/rbenv/rbenv-installer#rbenv-installer--doctor-scripts).

- **bundler**: Vous pouvez l'installer avec la commande `gem install bundler`.
- **Node 15+**: Nous conseillons l'utilisation de [`nvm`](https://github.com/nvm-sh/nvm).
- **yarn**: Vous pouvez l'installer avec la commande `npm install yarn -g`.
- [**Overmind**](https://github.com/DarthSim/overmind) ou [**Foreman**](https://github.com/ddollar/foreman) pour lancer le Procfile.
- **POSTGRESQL >= 12**.

Pour pouvoir utiliser l'application convenablement veuillez au préalable créer un compte agent
sur votre environnement local de [RDV-Solidarites](https://github.com/betagouv/rdv-solidarites.fr).

### Base de données

Pour créer et migrer la base de données, veuillez lancer la commande suivante: `rails db:create db:migrate`.

Pour la peupler, veuillez lancer la commande `rails db:seed`.
Pour pouvoir utiliser l'application correctement, veuillez ajouter les ids des organisations correspondantes
à chaque organisation dans RDV-Solidarites au sein de la colonne `rdv_solidarites_organisation_id` de la table `organisations`.

### Variables d'environnements

Veuillez créer un ficher `.env` à la racine du projet et y ajouter les variables spécifiées dans le fichier `env.example`.

### Lancer le projet

Lancez ces commandes pour lancer le projet en local:

- `bundle install`

- `yarn install`

- `overmind start -f Procfile.dev`

Le site devrait être accessible à l'adresse suivante: `http://localhost:8000`
