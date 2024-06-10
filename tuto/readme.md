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

Pour réaliser cela, Nix installe les logiciels "à sa façon":

- Aucune connexion internet n’est autorisée lors du processus de compilation. Toutes les ressources nécessaires doivent être déclarées au préalable et sont téléchargées avant toute chose.
- Aucune dépendance non déclarée ne peut être utilisée. Si installer un logiciel X nécessite une dépendance Y, alors Y sera aussi installée avec Nix, même si une version de Y est déjà disponible sur la machine. Il en va de même pour les dépendances Z de Y.
- Aucune variable d’environnement ne peut-être utilisée: il faut les déclarer avec Nix aussi.

En conclusion, cela signifie que pour installer un logiciel, ou un environnement complet, il va falloir écrire un
script dans lequel nous déclarerons tout ce qui est nécessaire.

Si vous n’avez pas déjà installé Nix, c’est maintenant le moment de le faire, en utilisant l’installateur
de [Determinate Systems](https://github.com/DeterminateSystems/nix-installer). Lancez la commande depuis
la ligne de commande sous Linux ou macOS:
```
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

et pour Windows, lisez [ici](https://github.com/DeterminateSystems/nix-installer?tab=readme-ov-file#in-wsl2).

## default.nix

Un fichier `default.nix` est un fichier qui contient une expression écrite dans le langage Nix. Évaluer cette
expression résultera dans l’installation d’un logiciel, ou dans ce qui nous intéresse dans environnement 
de développement reproductible. Ouvrez le fichier `basic/default.nix`. Celui-ci contient à peu près tout ce
que vous devez connaître du langage pour pouvoir l’utiliser.

Vous pouvez installer l’environnement en utilisant la commande `nix-build` depuis la ligne de commande
(terminal sous Linux ou macOS, WSL2 depuis Windows). Cela va télécharger les logiciels depuis le cache
public de NixOS (une distribution Linux utilisant Nix comme gestionnaire de paquets) et installer 
l’environnement. Vous verrez un fichier `result` apparaître dans le même dossier. Il s’agit d’un raccourci
vers le dossier d’installation de l’environnement dans le *Nix store*. Pour récupérer de la place, si vous
n’avez plus besoin d’un environnement, vous pouvez effacer ce fichier `result` et ensuite appeler `nix-store --gc`.

Pour pouvoir utiliser l’environnement, utilisez `nix-shell`. Après quelques instants l’environnement est chargé
et vous pouvez l’utiliser. Lancer `which R` par exemple ou `which python`. Démarrez R dans ce shell avec `R`
et chargez le paquet `{reticulate}`:

```
library(reticulate)

py_run_string("print('coucou depuis Python')")
```

Ce fichier illustre les fonctionnalités principales qui nous intéressent: installer n’importe quel logiciel depuis les 
dépôts de Nix (cherchez des paquets [ici](https://search.nixos.org/packages)), installer des paquets depuis
Github et définir une commande à exécuter quand on démarre le *shell* Nix (à partir de maintenant, je vais utiliser
le mot *shell* pour parler d’environnement de développement).

## Générer des expressions avec rix()

Écrire ces expressions peut être assez complexe, c’est pourquoi on va utiliser la fonction `rix()` afin de les générer.
Pour l’instant, `{rix}` n’est pas disponible sur le CRAN, mais vous pouvez l’installer avec les commandes suivantes:

```
install.packages("rix", repos = c("https://b-rodrigues.r-universe.dev",
  "https://cloud.r-project.org"))
```

Ou si vous êtes sur un système sur lequel R n’est pas installé mais sur lequel Nix est installé, vous pouvez aussi
lancer cette commande:

```
nix-shell --expr "$(curl -sl https://raw.githubusercontent.com/b-rodrigues/rix/master/inst/extdata/default.nix)"
```

Cette commande va démarrer un shell avec R at `{rix}` installé. Une fois `{rix}` installé ouvrez `tuto/rix_intro/generate_env_vscode.R` et `tuto/rix_intro/generate_env_rstudio.R`.
Ces deux scripts montrent comment utiliser `rix()`; lancez la fonction et ouvrez le fichier `default.nix` qui est généré. Il faut
savoir qu’il est possible d’utiliser un environnement de développement Nix avec un IDE, néanmoins, RStudio est un peu particulier
et doit aussi être installé avec Nix pour fonctionner. Le problème est que RStudio n’est pas disponible ni pour macOS ni pour 
architecture ARM pour Linux via Nix. Il n’y a toutefois pas de soucis sous Linux ou si vous utilisez un autre environnement comme
VS Code ou Emacs ou Vim. Si vous utilisez WSL2, vous devez configurer WSL2 de sorte à ce qu’il soit possible de lancer des 
applications graphiques pour pouvoir utiliser une interface installée via Nix, voir [ici](https://learn.microsoft.com/en-us/windows/wsl/tutorials/gui-apps).

## Nix et {targets}













