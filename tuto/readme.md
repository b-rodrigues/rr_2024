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

Qu’est-ce que cela veut dire que Nix est un gestionnaire de paquets "fonctionnel"? Cela signifie
que Nix utilise les principes de la programmation fonctionnelle pour installer des logiciels. Pour 
faire simple, dans la programmation fonctionnelle, `f(x)` va toujours retourner `y`. On dit que `f`
est une fonction "pure". Cela peut sembler évident, mais il existe en programmation beaucoup de fonctions
qui ne sont pas pures. Par exemple, `rnorm()` ou `install.packages()`. `install.packages("dplyr")` ne va 
pas toujours retourner le même résultat, selon la date à laquelle on exécute cette ligne (une version 
différente de `dplyr` sera installée) ou selon les dépôts CRAN configurés.

Et qu’est-ce que cela signifie que Nix est un gestionnaire de paquets déclaratif? Cela signifie qu’il 
suffit de déclarer comment un paquet doit s’installer plutôt que de détailler les étapes. Prenons 
l’exemple suivant: pour additionner les 100 premiers nombres entiers, en programmation fonctionnelle
on va écrire:

```
Reduce(sum, seq(1,100))
```

alors qu’en programmation non-fonctionnelle, il va falloir détailler les étapes:

```
result <- 0

for (i in 1:100){
  result <- result + i
}

print(result)
```

Dans l’approche fonctionnelle, il aura suffit de déclarer notre intention. L’implémentation de la fonction
`sum()` et `Reduce()` sont une donnée. Nix va utiliser ce concept pour installer des logiciels.

Mais qu’est-ce que cela signifie concrètement? Lorsque Nix va installer un logiciel (R, un paquet R ou 
n’importe quel autre logicile disponible dans ses dépôts), Nix va s’assurer d’installer toujours exactement
la même version des logiciels demandés. Autrement dit, si `f` est une fonction Nix qui installe un logiciel,
alors `f("logiciel")` va toujours installer exactement la même version de "logiciel" quelque soit la plateforme,
la date, bref, quelque soit "l’état du monde".


















