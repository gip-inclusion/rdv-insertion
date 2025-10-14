# Comment Contribuer

## Signaler un problème

Si vous rencontrez un problème, [contactez-nous par email](mailto:rdv-insertion@inclusion.gouv.fr).

## Soumettre une modification

Les pull requests sont bienvenues ! N’hésitez pas à [nous en parler à l’avance](mailto:rdv-insertion@inclusion.gouv.fr). La démarche est habituelle: faites un fork, créez une branche, faites un PR. Pour les petites corrections de fautes d’orthographe, n’hésitez pas à proposer une modification directement depuis github.com.

## Style de code

Au delà du style de syntaxe, nous essayons de suivre quelques principes.
Aujourd'hui nous essayons d’aller dans cette direction:

1. Plutôt du rails monolithique

- Minimiser le JS utilisant des API spécifiques: Nous avons une partie de l'application en React (qui s'occupe du chargement des fichiers des usagers), nous ne souhaitons pas étendre l'utilisation de React à d'autres parties de l'application et peut-être même enlever cette partie à terme
- Nous commençons à utiliser Hotwire lorsque l'on peut pour rendre les pages plus dynamiques en minimisant l'utilisation du JS

2. Tester le code

- Nous tenons à écrire des tests unitaires pour tous les services, les jobs et les controllers

3. Encapsuler la logique métier dans des services

- Nous cherchons à ne pas encombrer nos modèles et nos controllers par de la logique métier
- La logique métier est regroupé dans des services qui sont de simples classes `ruby` dans `app/services/`
- Chaque service a une fonctionnalité précise et implémente une méthode `call` **unique**
- Tous les services héritent de la classe [`BaseService`](https://github.com/betagouv/rdv-insertion/blob/staging/app/services/base_service.rb). La méthode `call` sur un service renvoie toujours un `OpenStruct` qui répond à `success?` et à `failure?`. On peut accéder à cette `OpenStruct` au sein de la classe par l'intermédiare de la variable `result`, ce qui peut être utile pour y attacher un objet auquel on voudra accéder une fois le service appelé.

## Linters

- Faire tourner tous les linters :

```bash
bundle exec rubocop       Ruby linter
yarn lint                 JS linter
```

## Tests

Nous utilisons [RSpec](https://rspec.info/) pour écrire nos tests. En principe, la base de données de tests est créée automatiquement.

- Lancer tous les tests

```bash
bundle exec rspec
```

- Lancer tous les tests d’un fichier

```bash
bundle exec rspec file_path/file_name_spec.rb
```

- Lancer un test en particulier

```bash
bundle exec rspec file_path/file_name_spec.rb:line_number
```

## Documentation API

Nous utilisons la libraire [rswag]() pour générer la documentation au format `openAPI` à partir des tests de requêtes (définis dans `/spec/request/`).

Pour mettre à jour le fichier swagger qui alimente la page de documentation de l'API, il faut lancer cette commande:

```bash
make rswag
```

La documentation est visible sur l'URL `/api-docs`.
