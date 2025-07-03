# RDV INSERTION

L'objectif de ce service numérique public est de faciliter la prise de 1er RDV RSA en permettant aux agents
de s'interfacer facilement avec [RDV-Solidarites](https://github.com/betagouv/rdv-solidarites.fr).

Le site est disponible

- En production sur [rdv-insertion.fr/](https://rdv-insertion.fr/).
- En démo sur [www.rdv-insertion-demo.fr](https://www.rdv-insertion-demo.fr).
- En staging sur [staging.rdv-insertion.fr](https://staging.rdv-insertion.fr).

## Installation

La procédure d'installation est disponible [ici](https://github.com/betagouv/rdv-insertion/blob/staging/docs/INSTALL.md)

## Contribuer

Pour contribuer les instructions sont disponibles [ici](https://github.com/betagouv/rdv-insertion/blob/staging/docs/CONTRIBUTE.md)

## Guide d'utilisation

La guide d'utilisation de l'application se trouve [ici](https://rdv-insertion.gitbook.io/guide-dutilisation-rdv-insertion/)

## Architecture

Ci-dessous le schéma de l'architecture de l'application ![schema rdv-insertion](https://github.com/betagouv/rdv-insertion/blob/staging/docs/architecture_rdv-insertion.png)

Ci-dessous le schéma de la base de donnée.
Pour le regénérer manuellement il faut lancer la commande `rake erd`.
![schema DB rdv-insertion](https://github.com/betagouv/rdv-insertion/blob/staging/docs/domain_model.png)

## Statistiques

Les statistiques d'utilisation de l'application sont consultables [ici](https://rdv-insertion.fr/stats)

## Déploiement

RDV-Insertion utilise [Scalingo](https://scalingo.com/) pour héberger les applis de staging et de production. Le déploiement se fait automatiquement avec Github:

- Une fois qu'une PR est mergé sur la branche `staging`, les changements sont automatiquements déployés sur [l'environnement de démo](https://www.rdv-insertion-demo.fr).

- Une fois les changements testés en demo, il faut lancer le script `./deploy.sh` qui se charge de pusher les changements sur la branche `main`, qui a pour effet de les déployer [en production](https://www.rdv-insertion.fr).

# Mise à jour Metabase

Pour mettre à jour Metabase, il suffit de lancer la commande suivante : 

```bash
scalingo --region osc-secnum-fr1 --app rdv-service-public-etl run "bundle exec ruby main.rb --app rdvi"
```

