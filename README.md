# RDV INSERTION

L'objectif de ce service numérique public est de faciliter la prise de 1er RDV RSA en permettant aux agents
de s'interfacer facilement avec [RDV-Solidarites](https://github.com/betagouv/rdv-solidarites.fr).

Le site est disponible
- En production sur [rdv-insertion.fr/](https://rdv-insertion.fr/).
- En démo sur [rdv-insertion-demo.fr/](https://rdv-insertion-demo.fr/).

## Statistiques

- [Statistiques de rdv-insertion](https://rdv-insertion.fr/stats)

## Installation

La procédure d'installation [est disponible ici](https://github.com/betagouv/rdv-insertion/blob/staging/INSTALL.md)

## Déploiement

Une fois qu'une PR est mergé sur la branche `staging`, les changements sont automatiquements déployés sur [l'environnement de démo](https://www.rdv-insertion-demo.fr).

Une fois les changements testés en demo, il faut lancer le script `./deploy.sh` qui se charge de pusher les changements sur la branche `main`, qui a pour effet de les déployer [en production](https://www.rdv-insertion.fr).
