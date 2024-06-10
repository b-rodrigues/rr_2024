# rix: environnements de développement reproductibles pour développeurs R

## Intro

Le but de ce tutoriel est de présenter le gestionnaire de paquets Nix et comment
celui-ci peu être utilisé pour créer des environnements de développement reproductibles
pour les utilisateurs du langage R.

Afin de simplifier la prise en main de Nix, j’ai développé un paquet (pas encore dispo
sur le CRAN) appelé {rix}. Vous pouvez trouver le dépôt Github du paquet 
[ici](https://github.com/b-rodrigues/rix) et le site pkgdown [ici](https://b-rodrigues.github.io/rix/).

{rix} est actuellement en train d’être évalué pour une éventuelle intégration à suite de paquets
rOpensci [ici](https://github.com/ropensci/software-review/issues/625).

## Fonctionnement de base

Nix est un gestionnaire de paquets fonctionnel et déclaratif. On peut l’utiliser de manière interactive
et impérative pour installer des logiciels, mais cela va à l’encontre de la philosophie de Nix.
